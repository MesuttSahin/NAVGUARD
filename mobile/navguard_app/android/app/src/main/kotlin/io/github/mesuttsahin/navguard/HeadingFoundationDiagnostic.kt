package io.github.mesuttsahin.navguard

import android.hardware.GeomagneticField
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.math.PI
import kotlin.math.atan2
import kotlin.math.ceil
import kotlin.math.sqrt

internal class HeadingFoundationDiagnostic(
    private val sensorManager: SensorManager,
    private val resultHandler: Handler = Handler(Looper.getMainLooper()),
) {
    internal interface Callback {
        fun onSuccess(summary: Map<String, Any?>)

        fun onError(
            code: String,
            message: String,
        )
    }

    private val activeSessionLock = Any()
    private var activeSession: Session? = null

    fun createPreflightSnapshot(): Map<String, Any?> {
        val rotationVectorSensor =
            try {
                sensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
            } catch (_: Exception) {
                null
            }

        return linkedMapOf(
            "schemaVersion" to SCHEMA_VERSION,
            "snapshotKind" to SNAPSHOT_KIND_PREFLIGHT,
            "rotationVectorAvailable" to (rotationVectorSensor != null),
            "rotationVectorName" to rotationVectorSensor?.name,
            "requestedSamplingPeriodUs" to REQUESTED_SAMPLING_PERIOD_US,
            "diagnosticRunning" to isDiagnosticRunning(),
        )
    }

    fun isDiagnosticRunning(): Boolean =
        synchronized(activeSessionLock) {
            activeSession != null
        }

    fun start(
        anchorLatitudeDeg: Double,
        anchorLongitudeDeg: Double,
        anchorAltitudeEllipsoidM: Double?,
        callback: Callback,
    ) {
        if (
            !anchorLatitudeDeg.isFinite() ||
                anchorLatitudeDeg !in -90.0..90.0 ||
                !anchorLongitudeDeg.isFinite() ||
                anchorLongitudeDeg !in -180.0..180.0 ||
                anchorAltitudeEllipsoidM?.isFinite() == false
        ) {
            postError(
                callback,
                ERROR_INVALID_ANCHOR_ARGUMENT,
                "The locked GNSS anchor arguments are invalid.",
            )
            return
        }

        val rotationVectorSensor =
            try {
                sensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
            } catch (_: Exception) {
                null
            }

        if (rotationVectorSensor == null) {
            postError(
                callback,
                ERROR_ROTATION_VECTOR_UNAVAILABLE,
                "TYPE_ROTATION_VECTOR is unavailable on this device.",
            )
            return
        }

        val altitudeSource =
            if (anchorAltitudeEllipsoidM == null) {
                DECLINATION_ALTITUDE_SOURCE_ZERO_FALLBACK
            } else {
                DECLINATION_ALTITUDE_SOURCE_ANCHOR
            }
        val declinationAltitudeM = anchorAltitudeEllipsoidM ?: 0.0
        val declinationRadians =
            try {
                Math.toRadians(
                    GeomagneticField(
                        anchorLatitudeDeg.toFloat(),
                        anchorLongitudeDeg.toFloat(),
                        declinationAltitudeM.toFloat(),
                        System.currentTimeMillis(),
                    ).declination.toDouble(),
                )
            } catch (_: Exception) {
                Double.NaN
            }

        if (!declinationRadians.isFinite()) {
            postError(
                callback,
                ERROR_INTERNAL_HEADING,
                "Unable to calculate geomagnetic declination.",
            )
            return
        }

        val session =
            Session(
                selectedSensor = rotationVectorSensor,
                declinationRadians = declinationRadians,
                declinationAltitudeSource = altitudeSource,
                callback = callback,
            )

        if (!reserveSession(session)) {
            postError(
                callback,
                ERROR_ALREADY_RUNNING,
                "A heading foundation diagnostic is already running.",
            )
            return
        }

        session.start()
    }

    fun cancelActiveSession(
        message: String = "Heading foundation diagnostic cancelled.",
    ): Boolean {
        val session =
            synchronized(activeSessionLock) {
                activeSession
            }

        session?.cancel(message)
        return session != null
    }

    private fun reserveSession(session: Session): Boolean =
        synchronized(activeSessionLock) {
            if (activeSession != null) {
                false
            } else {
                activeSession = session
                true
            }
        }

    private fun releaseSession(session: Session) {
        synchronized(activeSessionLock) {
            if (activeSession === session) {
                activeSession = null
            }
        }
    }

    private fun postSuccess(
        callback: Callback,
        summary: Map<String, Any?>,
    ) {
        if (!resultHandler.post { callback.onSuccess(summary) }) {
            callback.onSuccess(summary)
        }
    }

    private fun postError(
        callback: Callback,
        code: String,
        message: String,
    ) {
        if (!resultHandler.post { callback.onError(code, message) }) {
            callback.onError(code, message)
        }
    }

    private inner class Session(
        private val selectedSensor: Sensor,
        private val declinationRadians: Double,
        private val declinationAltitudeSource: String,
        private val callback: Callback,
    ) : SensorEventListener {
        private val completed = AtomicBoolean(false)
        private val stateLock = Any()
        private val handlerThread = HandlerThread(HANDLER_THREAD_NAME)
        private val uniqueTimestamps = mutableSetOf<Long>()
        private val positiveTimestampDeltasNanos = mutableListOf<Long>()

        private var sensorHandler: Handler? = null
        private var listenerRegistered = false
        private var updateCount = 0L
        private var validHeadingSampleCount = 0L
        private var duplicateTimestampCount = 0L
        private var nonMonotonicTimestampCount = 0L
        private var measurementWindowStartTimestampNanos: Long? = null
        private var previousAcceptedTimestampNanos: Long? = null
        private var lastAcceptedTimestampNanos: Long? = null
        private var firstMagneticHeadingRad: Double? = null
        private var lastMagneticHeadingRad: Double? = null
        private var firstTrueNorthCorrectedHeadingRad: Double? = null
        private var lastTrueNorthCorrectedHeadingRad: Double? = null
        private var previousTrueNorthCorrectedHeadingRad: Double? = null
        private var cumulativeUnwrappedTrueHeadingDeltaRad = 0.0
        private var maxConsecutiveCircularDeltaRad = 0.0
        private var reportedHeadingAccuracyAvailable = false
        private var lastReportedHeadingAccuracyRad: Double? = null

        private val firstValidSampleTimeoutRunnable =
            Runnable {
                finishWithError(
                    ERROR_FIRST_VALID_TIMEOUT,
                    "No structurally valid heading sample was received before the timeout.",
                )
            }

        private val measurementWindowControlRunnable =
            Runnable {
                completeMeasurementWindow()
            }

        fun start() {
            val handler =
                try {
                    handlerThread.start()
                    Handler(handlerThread.looper)
                } catch (_: Exception) {
                    finishWithError(
                        ERROR_INTERNAL_HEADING,
                        "Unable to start the heading diagnostic worker.",
                    )
                    return
                }

            sensorHandler = handler

            val registrationSucceeded =
                try {
                    sensorManager.registerListener(
                        this,
                        selectedSensor,
                        REQUESTED_SAMPLING_PERIOD_US,
                        MAX_REPORT_LATENCY_US,
                        handler,
                    )
                } catch (_: Exception) {
                    false
                }

            if (!registrationSucceeded) {
                finishWithError(
                    ERROR_SENSOR_REGISTRATION_FAILED,
                    "Android rejected the rotation-vector listener registration.",
                )
                return
            }

            listenerRegistered = true

            if (
                !handler.postDelayed(
                    firstValidSampleTimeoutRunnable,
                    FIRST_VALID_SAMPLE_TIMEOUT_MS,
                )
            ) {
                finishWithError(
                    ERROR_INTERNAL_HEADING,
                    "Unable to schedule the first heading sample timeout.",
                )
            }
        }

        override fun onSensorChanged(event: SensorEvent?) {
            if (event == null || completed.get()) {
                return
            }

            synchronized(stateLock) {
                updateCount += 1L
            }

            val sample = createStructurallyValidSample(event) ?: return
            var shouldComplete = false
            var measurementTimeoutScheduleFailed = false

            synchronized(stateLock) {
                if (completed.get()) {
                    return
                }

                val windowStart = measurementWindowStartTimestampNanos
                val previousTimestamp = previousAcceptedTimestampNanos

                if (windowStart != null && previousTimestamp != null) {
                    if (sample.timestampNanos < previousTimestamp) {
                        nonMonotonicTimestampCount += 1L
                        return
                    }

                    if (
                        sample.timestampNanos - windowStart >
                            MEASUREMENT_WINDOW_NANOS
                    ) {
                        shouldComplete = true
                        return@synchronized
                    }
                }

                if (windowStart == null) {
                    measurementWindowStartTimestampNanos = sample.timestampNanos
                    sensorHandler?.removeCallbacks(firstValidSampleTimeoutRunnable)
                    measurementTimeoutScheduleFailed =
                        sensorHandler?.postDelayed(
                            measurementWindowControlRunnable,
                            MEASUREMENT_WINDOW_CONTROL_TIMEOUT_MS,
                        ) != true
                }

                acceptSample(sample)
            }

            when {
                measurementTimeoutScheduleFailed ->
                    finishWithError(
                        ERROR_INTERNAL_HEADING,
                        "Unable to schedule heading measurement termination.",
                    )
                shouldComplete -> completeMeasurementWindow()
            }
        }

        override fun onAccuracyChanged(
            sensor: Sensor?,
            accuracy: Int,
        ) = Unit

        private fun createStructurallyValidSample(
            event: SensorEvent,
        ): HeadingSample? {
            if (
                event.sensor.type != Sensor.TYPE_ROTATION_VECTOR ||
                    event.timestamp <= 0L ||
                    event.values.size < REQUIRED_ROTATION_VECTOR_COMPONENT_COUNT
            ) {
                return null
            }

            val rotationVectorComponentCount =
                if (event.values.size >= 4) 4 else 3
            val rotationVector = FloatArray(rotationVectorComponentCount)

            for (index in 0 until rotationVectorComponentCount) {
                val component = event.values[index]

                if (!component.isFinite()) {
                    return null
                }

                rotationVector[index] = component
            }

            val rotationMatrix = FloatArray(9)

            try {
                SensorManager.getRotationMatrixFromVector(
                    rotationMatrix,
                    rotationVector,
                )
            } catch (_: Exception) {
                return null
            }

            if (rotationMatrix.any { component -> !component.isFinite() }) {
                return null
            }

            val east = rotationMatrix[1].toDouble()
            val north = rotationMatrix[4].toDouble()
            val horizontalNorm = sqrt((east * east) + (north * north))

            if (
                !east.isFinite() ||
                    !north.isFinite() ||
                    !horizontalNorm.isFinite() ||
                    horizontalNorm <= HORIZONTAL_NORM_EPSILON
            ) {
                return null
            }

            val magneticHeadingRad = normalizeHeadingRadians(atan2(east, north))
            val trueNorthCorrectedHeadingRad =
                normalizeHeadingRadians(magneticHeadingRad + declinationRadians)

            if (
                !magneticHeadingRad.isFinite() ||
                    !trueNorthCorrectedHeadingRad.isFinite()
            ) {
                return null
            }

            val reportedHeadingAccuracyRad =
                if (event.values.size > HEADING_ACCURACY_VALUE_INDEX) {
                    event.values[HEADING_ACCURACY_VALUE_INDEX]
                        .toDouble()
                        .takeIf { accuracy ->
                            accuracy.isFinite() && accuracy >= 0.0
                        }
                } else {
                    null
                }

            return HeadingSample(
                timestampNanos = event.timestamp,
                magneticHeadingRad = magneticHeadingRad,
                trueNorthCorrectedHeadingRad = trueNorthCorrectedHeadingRad,
                reportedHeadingAccuracyRad = reportedHeadingAccuracyRad,
            )
        }

        private fun acceptSample(sample: HeadingSample) {
            val previousTimestamp = previousAcceptedTimestampNanos

            if (uniqueTimestamps.add(sample.timestampNanos)) {
                if (previousTimestamp != null) {
                    val deltaNanos = sample.timestampNanos - previousTimestamp

                    if (deltaNanos > 0L) {
                        positiveTimestampDeltasNanos += deltaNanos
                    }
                }
            } else {
                duplicateTimestampCount += 1L
            }

            validHeadingSampleCount += 1L
            previousAcceptedTimestampNanos = sample.timestampNanos
            lastAcceptedTimestampNanos = sample.timestampNanos

            if (firstMagneticHeadingRad == null) {
                firstMagneticHeadingRad = sample.magneticHeadingRad
                firstTrueNorthCorrectedHeadingRad =
                    sample.trueNorthCorrectedHeadingRad
            }

            lastMagneticHeadingRad = sample.magneticHeadingRad
            lastTrueNorthCorrectedHeadingRad =
                sample.trueNorthCorrectedHeadingRad

            val previousTrueHeading = previousTrueNorthCorrectedHeadingRad

            if (previousTrueHeading != null) {
                val circularDelta =
                    shortestSignedHeadingDeltaRadians(
                        previousTrueHeading,
                        sample.trueNorthCorrectedHeadingRad,
                    )

                cumulativeUnwrappedTrueHeadingDeltaRad += circularDelta
                maxConsecutiveCircularDeltaRad =
                    maxOf(maxConsecutiveCircularDeltaRad, kotlin.math.abs(circularDelta))
            }

            previousTrueNorthCorrectedHeadingRad =
                sample.trueNorthCorrectedHeadingRad

            sample.reportedHeadingAccuracyRad?.let { accuracy ->
                reportedHeadingAccuracyAvailable = true
                lastReportedHeadingAccuracyRad = accuracy
            }
        }

        private fun completeMeasurementWindow() {
            val summary =
                synchronized(stateLock) {
                    createSummaryOrNull()
                }

            if (summary == null) {
                finishWithError(
                    ERROR_INSUFFICIENT_VALID_SAMPLES,
                    "At least two unique structurally valid heading samples are required.",
                )
            } else {
                finishSuccessfully(summary)
            }
        }

        private fun createSummaryOrNull(): Map<String, Any?>? {
            val startTimestamp = measurementWindowStartTimestampNanos ?: return null
            val endTimestamp = lastAcceptedTimestampNanos ?: return null
            val firstMagnetic = firstMagneticHeadingRad ?: return null
            val lastMagnetic = lastMagneticHeadingRad ?: return null
            val firstTrue = firstTrueNorthCorrectedHeadingRad ?: return null
            val lastTrue = lastTrueNorthCorrectedHeadingRad ?: return null
            val deltaCount = positiveTimestampDeltasNanos.size
            val durationNanos = endTimestamp - startTimestamp

            if (
                validHeadingSampleCount < MINIMUM_VALID_SAMPLE_COUNT ||
                    uniqueTimestamps.size < MINIMUM_VALID_SAMPLE_COUNT ||
                    deltaCount < 1 ||
                    durationNanos <= 0L
            ) {
                return null
            }

            val sortedDeltas = positiveTimestampDeltasNanos.sorted()
            val minDeltaNanos = sortedDeltas.first().toDouble()
            val maxDeltaNanos = sortedDeltas.last().toDouble()
            val meanDeltaNanos = sortedDeltas.average()
            val medianDeltaNanos = median(sortedDeltas)
            val p95DeltaNanos = percentile95(sortedDeltas).toDouble()
            val observedSampleRateHz =
                deltaCount.toDouble() * NANOS_PER_SECOND / durationNanos.toDouble()

            return linkedMapOf(
                "schemaVersion" to SCHEMA_VERSION,
                "snapshotKind" to SNAPSHOT_KIND_DIAGNOSTIC,
                "success" to true,
                "sensorType" to SENSOR_TYPE_NAME,
                "sensorName" to selectedSensor.name,
                "requestedSamplingPeriodUs" to REQUESTED_SAMPLING_PERIOD_US,
                "firstValidSampleTimeoutMs" to FIRST_VALID_SAMPLE_TIMEOUT_MS,
                "measurementWindowMs" to MEASUREMENT_WINDOW_MS,
                "sensorTimestampAuthority" to SENSOR_TIMESTAMP_AUTHORITY,
                "wallClockUsedForSensorTiming" to false,
                "declinationTimeSource" to DECLINATION_TIME_SOURCE,
                "updateCount" to updateCount,
                "validHeadingSampleCount" to validHeadingSampleCount,
                "uniqueTimestampCount" to uniqueTimestamps.size.toLong(),
                "deltaCount" to deltaCount.toLong(),
                "nonMonotonicTimestampCount" to nonMonotonicTimestampCount,
                "duplicateTimestampCount" to duplicateTimestampCount,
                "durationNanos" to durationNanos,
                "minDeltaMs" to nanosToMillis(minDeltaNanos),
                "maxDeltaMs" to nanosToMillis(maxDeltaNanos),
                "meanDeltaMs" to nanosToMillis(meanDeltaNanos),
                "medianDeltaMs" to nanosToMillis(medianDeltaNanos),
                "p95DeltaMs" to nanosToMillis(p95DeltaNanos),
                "observedSampleRateHz" to observedSampleRateHz,
                "firstMagneticHeadingRad" to firstMagnetic,
                "lastMagneticHeadingRad" to lastMagnetic,
                "firstTrueNorthCorrectedHeadingRad" to firstTrue,
                "lastTrueNorthCorrectedHeadingRad" to lastTrue,
                "cumulativeUnwrappedTrueHeadingDeltaRad" to
                    cumulativeUnwrappedTrueHeadingDeltaRad,
                "maxConsecutiveCircularDeltaRad" to
                    maxConsecutiveCircularDeltaRad,
                "reportedHeadingAccuracyAvailable" to
                    reportedHeadingAccuracyAvailable,
                "lastReportedHeadingAccuracyRad" to
                    lastReportedHeadingAccuracyRad,
                "declinationRadians" to declinationRadians,
                "declinationProvider" to DECLINATION_PROVIDER,
                "declinationModelVersion" to DECLINATION_MODEL_VERSION,
                "declinationModelFreshnessValidated" to false,
                "declinationAltitudeSource" to declinationAltitudeSource,
                "headingAccuracyValidated" to false,
                "trueNorthAccuracyValidated" to false,
                "bodyHeadingImplemented" to false,
                "deviceForwardAxis" to DEVICE_FORWARD_AXIS,
                "headingConvention" to HEADING_CONVENTION,
            )
        }

        fun cancel(message: String) {
            finishWithError(ERROR_DIAGNOSTIC_CANCELLED, message)
        }

        private fun finishSuccessfully(summary: Map<String, Any?>) {
            if (!completed.compareAndSet(false, true)) {
                return
            }

            cleanup()
            releaseSession(this)
            postSuccess(callback, summary)
        }

        private fun finishWithError(
            code: String,
            message: String,
        ) {
            if (!completed.compareAndSet(false, true)) {
                return
            }

            cleanup()
            releaseSession(this)
            postError(callback, code, message)
        }

        private fun cleanup() {
            sensorHandler?.removeCallbacksAndMessages(null)

            if (listenerRegistered) {
                try {
                    sensorManager.unregisterListener(this)
                } catch (_: Exception) {
                    // Completion remains exact-once even if platform cleanup fails.
                }
                listenerRegistered = false
            }

            sensorHandler = null

            try {
                handlerThread.quitSafely()
            } catch (_: Exception) {
                // The result has already been resolved; no raw state is exposed.
            }
        }
    }

    private data class HeadingSample(
        val timestampNanos: Long,
        val magneticHeadingRad: Double,
        val trueNorthCorrectedHeadingRad: Double,
        val reportedHeadingAccuracyRad: Double?,
    )

    private companion object {
        const val SCHEMA_VERSION = 1
        const val SNAPSHOT_KIND_PREFLIGHT = "heading_foundation_preflight"
        const val SNAPSHOT_KIND_DIAGNOSTIC = "heading_foundation_diagnostic"
        const val SENSOR_TYPE_NAME = "TYPE_ROTATION_VECTOR"
        const val REQUESTED_SAMPLING_PERIOD_US = 20_000
        const val MAX_REPORT_LATENCY_US = 0
        const val FIRST_VALID_SAMPLE_TIMEOUT_MS = 10_000L
        const val MEASUREMENT_WINDOW_MS = 30_000L
        const val MEASUREMENT_WINDOW_CONTROL_TIMEOUT_MS = 31_000L
        const val MEASUREMENT_WINDOW_NANOS =
            MEASUREMENT_WINDOW_MS * 1_000_000L
        const val MINIMUM_VALID_SAMPLE_COUNT = 2L
        const val REQUIRED_ROTATION_VECTOR_COMPONENT_COUNT = 3
        const val HEADING_ACCURACY_VALUE_INDEX = 4
        const val HORIZONTAL_NORM_EPSILON = 1e-6
        const val NANOS_PER_SECOND = 1_000_000_000.0
        const val NANOS_PER_MILLISECOND = 1_000_000.0
        const val TWO_PI = 2.0 * PI
        const val HANDLER_THREAD_NAME = "NAVGUARD-HeadingFoundation"
        const val SENSOR_TIMESTAMP_AUTHORITY = "SensorEvent.timestamp"
        const val DECLINATION_TIME_SOURCE = "System.currentTimeMillis"
        const val DECLINATION_PROVIDER = "android.hardware.GeomagneticField"
        const val DECLINATION_MODEL_VERSION = "platform_managed"
        const val DECLINATION_ALTITUDE_SOURCE_ANCHOR =
            "anchor_ellipsoid_altitude"
        const val DECLINATION_ALTITUDE_SOURCE_ZERO_FALLBACK =
            "deterministic_zero_fallback"
        const val DEVICE_FORWARD_AXIS = "device_positive_y_top_edge"
        const val HEADING_CONVENTION = "clockwise_from_north_0_to_2pi"

        const val ERROR_ROTATION_VECTOR_UNAVAILABLE =
            "rotation_vector_unavailable"
        const val ERROR_ALREADY_RUNNING =
            "heading_diagnostic_already_running"
        const val ERROR_FIRST_VALID_TIMEOUT = "first_valid_heading_timeout"
        const val ERROR_INSUFFICIENT_VALID_SAMPLES =
            "insufficient_valid_heading_samples"
        const val ERROR_DIAGNOSTIC_CANCELLED = "heading_diagnostic_cancelled"
        const val ERROR_SENSOR_REGISTRATION_FAILED =
            "sensor_registration_failed"
        const val ERROR_INVALID_ANCHOR_ARGUMENT = "invalid_anchor_argument"
        const val ERROR_INTERNAL_HEADING = "internal_heading_error"

        fun normalizeHeadingRadians(angle: Double): Double {
            var normalized = angle % TWO_PI

            if (normalized < 0.0) {
                normalized += TWO_PI
            }

            return if (normalized >= TWO_PI) 0.0 else normalized
        }

        fun shortestSignedHeadingDeltaRadians(
            from: Double,
            to: Double,
        ): Double {
            var delta = (to - from + PI) % TWO_PI

            if (delta < 0.0) {
                delta += TWO_PI
            }

            return delta - PI
        }

        fun median(sortedValues: List<Long>): Double {
            val middle = sortedValues.size / 2

            return if (sortedValues.size % 2 == 0) {
                (sortedValues[middle - 1].toDouble() +
                    sortedValues[middle].toDouble()) / 2.0
            } else {
                sortedValues[middle].toDouble()
            }
        }

        fun percentile95(sortedValues: List<Long>): Long {
            val index =
                (ceil(sortedValues.size * 0.95).toInt() - 1)
                    .coerceIn(0, sortedValues.lastIndex)
            return sortedValues[index]
        }

        fun nanosToMillis(value: Double): Double =
            value / NANOS_PER_MILLISECOND
    }
}
