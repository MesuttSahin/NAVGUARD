package io.github.mesuttsahin.navguard

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.hardware.GeomagneticField
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import android.os.SystemClock
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.math.PI
import kotlin.math.atan2
import kotlin.math.ceil
import kotlin.math.cos
import kotlin.math.sin
import kotlin.math.sqrt

internal class BaselinePdrDiagnostic(
    private val applicationContext: Context,
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
        val rotationVector = getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
        val stepDetector = getDefaultSensor(Sensor.TYPE_STEP_DETECTOR)
        val permissionRequired = isActivityRecognitionPermissionRequired()
        val permissionGranted = hasActivityRecognitionPermission()
        val diagnosticRunning = isDiagnosticRunning()

        return linkedMapOf(
            "schemaVersion" to SCHEMA_VERSION,
            "snapshotKind" to SNAPSHOT_KIND_PREFLIGHT,
            "rotationVectorAvailable" to (rotationVector != null),
            "rotationVectorName" to rotationVector?.name,
            "stepDetectorAvailable" to (stepDetector != null),
            "stepDetectorName" to stepDetector?.name,
            "activityRecognitionPermissionRequired" to permissionRequired,
            "activityRecognitionPermissionGranted" to permissionGranted,
            "diagnosticRunning" to diagnosticRunning,
            "nativeSensorsReady" to
                (
                    rotationVector != null &&
                        stepDetector != null &&
                        (!permissionRequired || permissionGranted) &&
                        !diagnosticRunning
                ),
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
                ERROR_ANCHOR_REQUIRED,
                "A valid locked Stage 3A GNSS anchor is required.",
            )
            return
        }

        val rotationVector = getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
        if (rotationVector == null) {
            postError(
                callback,
                ERROR_ROTATION_VECTOR_UNAVAILABLE,
                "TYPE_ROTATION_VECTOR is unavailable on this device.",
            )
            return
        }

        val stepDetector = getDefaultSensor(Sensor.TYPE_STEP_DETECTOR)
        if (stepDetector == null) {
            postError(
                callback,
                ERROR_STEP_DETECTOR_UNAVAILABLE,
                "TYPE_STEP_DETECTOR is unavailable on this device.",
            )
            return
        }

        if (!hasActivityRecognitionPermission()) {
            postError(
                callback,
                ERROR_ACTIVITY_RECOGNITION_PERMISSION_REQUIRED,
                "Physical activity recognition permission is required.",
            )
            return
        }

        val declinationAltitudeSource =
            if (anchorAltitudeEllipsoidM == null) {
                DECLINATION_ALTITUDE_SOURCE_ZERO_FALLBACK
            } else {
                DECLINATION_ALTITUDE_SOURCE_ANCHOR
            }
        val declinationAltitudeM = anchorAltitudeEllipsoidM ?: 0.0
        val declinationRad =
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

        if (!declinationRad.isFinite()) {
            postError(
                callback,
                ERROR_INTERNAL,
                "Unable to calculate geomagnetic declination.",
            )
            return
        }

        val session =
            Session(
                rotationVector = rotationVector,
                stepDetector = stepDetector,
                declinationRad = declinationRad,
                declinationAltitudeSource = declinationAltitudeSource,
                callback = callback,
            )

        if (!reserveSession(session)) {
            postError(
                callback,
                ERROR_ALREADY_RUNNING,
                "A baseline PDR diagnostic is already running.",
            )
            return
        }

        session.start()
    }

    fun cancelActiveSession(
        message: String = "Baseline PDR diagnostic cancelled by the user.",
    ): Boolean {
        val session =
            synchronized(activeSessionLock) {
                activeSession
            } ?: return false

        return session.cancel(message)
    }

    private fun getDefaultSensor(type: Int): Sensor? =
        try {
            sensorManager.getDefaultSensor(type)
        } catch (_: Exception) {
            null
        }

    private fun isActivityRecognitionPermissionRequired(): Boolean =
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q

    private fun hasActivityRecognitionPermission(): Boolean {
        if (!isActivityRecognitionPermissionRequired()) {
            return true
        }

        return applicationContext.checkSelfPermission(
            Manifest.permission.ACTIVITY_RECOGNITION,
        ) == PackageManager.PERMISSION_GRANTED
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
        private val rotationVector: Sensor,
        private val stepDetector: Sensor,
        private val declinationRad: Double,
        private val declinationAltitudeSource: String,
        private val callback: Callback,
    ) : SensorEventListener {
        private val completed = AtomicBoolean(false)
        private val stateLock = Any()
        private val handlerThread = HandlerThread(HANDLER_THREAD_NAME)
        private val headingTimestamps = mutableSetOf<Long>()
        private val stepTimestamps = mutableSetOf<Long>()
        private val headingSamples = mutableListOf<HeadingSample>()
        private val acceptedStepTimestamps = mutableListOf<Long>()

        private var sensorHandler: Handler? = null
        private var listenersRegistered = false
        private var sessionStartElapsedRealtimeNanos = 0L
        private var sessionEndElapsedRealtimeNanos = 0L

        private var stepUpdateCount = 0L
        private var acceptedStepEventCount = 0L
        private var invalidStepEventCount = 0L
        private var outOfWindowStepEventCount = 0L
        private var duplicateStepTimestampCount = 0L
        private var nonMonotonicStepTimestampCount = 0L
        private var previousAcceptedStepTimestampNanos: Long? = null

        private var headingUpdateCount = 0L
        private var validHeadingSampleCount = 0L
        private var invalidHeadingSampleCount = 0L
        private var duplicateHeadingTimestampCount = 0L
        private var nonMonotonicHeadingTimestampCount = 0L
        private var previousAcceptedHeadingTimestampNanos: Long? = null

        private val timeoutRunnable = Runnable { finishSuccessfully() }

        fun start() {
            try {
                handlerThread.start()
                val callbackHandler = Handler(handlerThread.looper)
                sensorHandler = callbackHandler

                sessionStartElapsedRealtimeNanos = SystemClock.elapsedRealtimeNanos()
                sessionEndElapsedRealtimeNanos =
                    sessionStartElapsedRealtimeNanos + SESSION_DURATION_NANOS

                val headingRegistered =
                    sensorManager.registerListener(
                        this,
                        rotationVector,
                        HEADING_REQUESTED_SAMPLING_PERIOD_US,
                        MAX_REPORT_LATENCY_US,
                        callbackHandler,
                    )
                listenersRegistered = headingRegistered
                val stepRegistered =
                    headingRegistered &&
                        sensorManager.registerListener(
                            this,
                            stepDetector,
                            SensorManager.SENSOR_DELAY_NORMAL,
                            MAX_REPORT_LATENCY_US,
                            callbackHandler,
                        )

                if (!headingRegistered || !stepRegistered) {
                    finishWithError(
                        ERROR_SENSOR_REGISTRATION_FAILED,
                        "Android rejected a baseline PDR sensor listener registration.",
                    )
                    return
                }

                if (!callbackHandler.postDelayed(timeoutRunnable, SESSION_DURATION_MS)) {
                    finishWithError(
                        ERROR_INTERNAL,
                        "Unable to schedule baseline PDR diagnostic termination.",
                    )
                }
            } catch (_: SecurityException) {
                finishWithError(
                    ERROR_ACTIVITY_RECOGNITION_PERMISSION_REQUIRED,
                    "Physical activity recognition permission is required.",
                )
            } catch (_: Exception) {
                finishWithError(
                    ERROR_INTERNAL,
                    "Unable to start the baseline PDR diagnostic.",
                )
            }
        }

        fun cancel(message: String): Boolean =
            finishWithError(
                ERROR_CANCELLED,
                message,
            )

        override fun onSensorChanged(event: SensorEvent) {
            if (completed.get()) {
                return
            }

            when (event.sensor.type) {
                Sensor.TYPE_ROTATION_VECTOR -> handleHeadingEvent(event)
                Sensor.TYPE_STEP_DETECTOR -> handleStepEvent(event)
            }
        }

        override fun onAccuracyChanged(
            sensor: Sensor,
            accuracy: Int,
        ) {
            // Accuracy callbacks are metadata only and do not enter Stage 4 PDR.
        }

        private fun handleHeadingEvent(event: SensorEvent) {
            synchronized(stateLock) {
                if (completed.get()) {
                    return
                }

                headingUpdateCount += 1L
                val sample = createHeadingSample(event)

                if (
                    sample == null ||
                    sample.timestampNanos < sessionStartElapsedRealtimeNanos ||
                    sample.timestampNanos > sessionEndElapsedRealtimeNanos
                ) {
                    invalidHeadingSampleCount += 1L
                    return
                }

                if (headingTimestamps.contains(sample.timestampNanos)) {
                    duplicateHeadingTimestampCount += 1L
                    return
                }

                val previousTimestamp = previousAcceptedHeadingTimestampNanos
                if (previousTimestamp != null && sample.timestampNanos < previousTimestamp) {
                    nonMonotonicHeadingTimestampCount += 1L
                    return
                }

                headingTimestamps.add(sample.timestampNanos)
                headingSamples.add(sample)
                validHeadingSampleCount += 1L
                previousAcceptedHeadingTimestampNanos = sample.timestampNanos
            }
        }

        private fun createHeadingSample(event: SensorEvent): HeadingSample? {
            if (
                event.sensor.type != Sensor.TYPE_ROTATION_VECTOR ||
                    event.timestamp <= 0L ||
                    event.values.size < REQUIRED_ROTATION_VECTOR_COMPONENT_COUNT
            ) {
                return null
            }

            val componentCount = if (event.values.size >= 4) 4 else 3
            val rotationVectorValues = FloatArray(componentCount)

            for (index in 0 until componentCount) {
                val component = event.values[index]
                if (!component.isFinite()) {
                    return null
                }
                rotationVectorValues[index] = component
            }

            val rotationMatrix = FloatArray(9)
            try {
                SensorManager.getRotationMatrixFromVector(
                    rotationMatrix,
                    rotationVectorValues,
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
                !horizontalNorm.isFinite() ||
                    horizontalNorm <= HORIZONTAL_NORM_EPSILON
            ) {
                return null
            }

            val magneticHeadingRad = normalizeHeadingRadians(atan2(east, north))
            val trueHeadingRad =
                normalizeHeadingRadians(magneticHeadingRad + declinationRad)

            if (!trueHeadingRad.isFinite()) {
                return null
            }

            return HeadingSample(
                timestampNanos = event.timestamp,
                trueHeadingRad = trueHeadingRad,
            )
        }

        private fun handleStepEvent(event: SensorEvent) {
            synchronized(stateLock) {
                if (completed.get()) {
                    return
                }

                stepUpdateCount += 1L
                val timestampNanos = event.timestamp
                val stepValue = event.values.firstOrNull()
                val structurallyValid =
                    event.sensor.type == Sensor.TYPE_STEP_DETECTOR &&
                        timestampNanos > 0L &&
                        stepValue != null &&
                        stepValue.isFinite() &&
                        stepValue == STEP_EVENT_VALUE

                if (!structurallyValid) {
                    invalidStepEventCount += 1L
                    return
                }

                if (
                    timestampNanos < sessionStartElapsedRealtimeNanos ||
                    timestampNanos > sessionEndElapsedRealtimeNanos
                ) {
                    outOfWindowStepEventCount += 1L
                    return
                }

                if (stepTimestamps.contains(timestampNanos)) {
                    duplicateStepTimestampCount += 1L
                    return
                }

                val previousTimestamp = previousAcceptedStepTimestampNanos
                if (previousTimestamp != null && timestampNanos < previousTimestamp) {
                    nonMonotonicStepTimestampCount += 1L
                    return
                }

                stepTimestamps.add(timestampNanos)
                acceptedStepTimestamps.add(timestampNanos)
                acceptedStepEventCount += 1L
                previousAcceptedStepTimestampNanos = timestampNanos
            }
        }

        private fun finishSuccessfully() {
            if (!completed.compareAndSet(false, true)) {
                return
            }

            cleanup()

            val collected =
                synchronized(stateLock) {
                    CollectedSession(
                        stepUpdateCount = stepUpdateCount,
                        acceptedStepEventCount = acceptedStepEventCount,
                        invalidStepEventCount = invalidStepEventCount,
                        outOfWindowStepEventCount = outOfWindowStepEventCount,
                        uniqueStepTimestampCount = stepTimestamps.size.toLong(),
                        duplicateStepTimestampCount = duplicateStepTimestampCount,
                        nonMonotonicStepTimestampCount =
                            nonMonotonicStepTimestampCount,
                        headingUpdateCount = headingUpdateCount,
                        validHeadingSampleCount = validHeadingSampleCount,
                        invalidHeadingSampleCount = invalidHeadingSampleCount,
                        uniqueHeadingTimestampCount = headingTimestamps.size.toLong(),
                        duplicateHeadingTimestampCount =
                            duplicateHeadingTimestampCount,
                        nonMonotonicHeadingTimestampCount =
                            nonMonotonicHeadingTimestampCount,
                        headingSamples = headingSamples.toList(),
                        acceptedStepTimestamps = acceptedStepTimestamps.toList(),
                    )
                }

            val summary = createSummary(collected)
            releaseSession(this)
            postSuccess(callback, summary)
        }

        private fun createSummary(collected: CollectedSession): Map<String, Any?> {
            var headingIndex = 0
            var latestHeading: HeadingSample? = null
            var finalEastM = 0.0
            var finalNorthM = 0.0
            var associatedStepCount = 0L
            var unassociatedStepCount = 0L
            val associationAgesNanos = mutableListOf<Long>()

            for (stepTimestamp in collected.acceptedStepTimestamps) {
                while (
                    headingIndex < collected.headingSamples.size &&
                    collected.headingSamples[headingIndex].timestampNanos <= stepTimestamp
                ) {
                    latestHeading = collected.headingSamples[headingIndex]
                    headingIndex += 1
                }

                val associatedHeading = latestHeading
                if (associatedHeading == null) {
                    unassociatedStepCount += 1L
                    continue
                }

                val associationAgeNanos =
                    stepTimestamp - associatedHeading.timestampNanos
                associationAgesNanos.add(associationAgeNanos)
                finalEastM += BASELINE_STEP_LENGTH_METERS * sin(associatedHeading.trueHeadingRad)
                finalNorthM += BASELINE_STEP_LENGTH_METERS * cos(associatedHeading.trueHeadingRad)
                associatedStepCount += 1L
            }

            val sortedAssociationAgesNanos = associationAgesNanos.sorted()
            val ageStatistics = calculateAgeStatistics(sortedAssociationAgesNanos)
            val integratedStepCount = associatedStepCount
            val nominalIntegratedPathLengthM =
                integratedStepCount.toDouble() * BASELINE_STEP_LENGTH_METERS
            val netDisplacementM = sqrt((finalEastM * finalEastM) + (finalNorthM * finalNorthM))

            return linkedMapOf(
                "schemaVersion" to SCHEMA_VERSION,
                "snapshotKind" to SNAPSHOT_KIND_DIAGNOSTIC_RESULT,
                "success" to true,
                "sessionDurationMs" to SESSION_DURATION_MS,
                "coordinateFrame" to COORDINATE_FRAME,
                "headingConvention" to HEADING_CONVENTION,
                "deviceForwardAxis" to DEVICE_FORWARD_AXIS,
                "stepSource" to STEP_SOURCE,
                "headingSource" to HEADING_SOURCE,
                "stepSensorName" to stepDetector.name,
                "headingSensorName" to rotationVector.name,
                "stepTimestampAuthority" to SENSOR_TIMESTAMP_AUTHORITY,
                "headingTimestampAuthority" to SENSOR_TIMESTAMP_AUTHORITY,
                "operationWindowClock" to OPERATION_WINDOW_CLOCK,
                "wallClockUsedForSensorTiming" to false,
                "headingAssociationPolicy" to HEADING_ASSOCIATION_POLICY,
                "futureHeadingUsed" to false,
                "stepUpdateCount" to collected.stepUpdateCount,
                "acceptedStepEventCount" to collected.acceptedStepEventCount,
                "invalidStepEventCount" to collected.invalidStepEventCount,
                "outOfWindowStepEventCount" to
                    collected.outOfWindowStepEventCount,
                "uniqueStepTimestampCount" to
                    collected.uniqueStepTimestampCount,
                "duplicateStepTimestampCount" to
                    collected.duplicateStepTimestampCount,
                "nonMonotonicStepTimestampCount" to
                    collected.nonMonotonicStepTimestampCount,
                "associatedStepCount" to associatedStepCount,
                "unassociatedStepCount" to unassociatedStepCount,
                "integratedStepCount" to integratedStepCount,
                "headingUpdateCount" to collected.headingUpdateCount,
                "validHeadingSampleCount" to
                    collected.validHeadingSampleCount,
                "invalidHeadingSampleCount" to
                    collected.invalidHeadingSampleCount,
                "uniqueHeadingTimestampCount" to
                    collected.uniqueHeadingTimestampCount,
                "duplicateHeadingTimestampCount" to
                    collected.duplicateHeadingTimestampCount,
                "nonMonotonicHeadingTimestampCount" to
                    collected.nonMonotonicHeadingTimestampCount,
                "minHeadingAssociationAgeMs" to ageStatistics.minMs,
                "maxHeadingAssociationAgeMs" to ageStatistics.maxMs,
                "meanHeadingAssociationAgeMs" to ageStatistics.meanMs,
                "medianHeadingAssociationAgeMs" to ageStatistics.medianMs,
                "p95HeadingAssociationAgeMs" to ageStatistics.p95Ms,
                "stepLengthModel" to STEP_LENGTH_MODEL,
                "stepLengthM" to BASELINE_STEP_LENGTH_METERS,
                "stepLengthCalibrated" to false,
                "stepLengthValidated" to false,
                "originEastM" to 0.0,
                "originNorthM" to 0.0,
                "finalEastM" to finalEastM,
                "finalNorthM" to finalNorthM,
                "netDisplacementM" to netDisplacementM,
                "nominalIntegratedPathLengthM" to
                    nominalIntegratedPathLengthM,
                "declinationRad" to declinationRad,
                "declinationProvider" to DECLINATION_PROVIDER,
                "declinationModelVersion" to DECLINATION_MODEL_VERSION,
                "declinationModelFreshnessValidated" to false,
                "declinationAltitudeSource" to declinationAltitudeSource,
                "pdrPositionImplemented" to true,
                "stepDetectionAccuracyValidated" to false,
                "headingAccuracyValidated" to false,
                "trueNorthAccuracyValidated" to false,
                "distanceAccuracyValidated" to false,
                "bodyHeadingImplemented" to false,
                "arCoreFusionImplemented" to false,
                "qualityEngineImplemented" to false,
                "ekfImplemented" to false,
                "groundTruthFirewallImplemented" to false,
                "gnssDeniedNavigationImplemented" to false,
                "rawTrajectoryReturned" to false,
                "rawSensorSamplesReturned" to false,
                "rawTimestampsReturned" to false,
                "persistenceUsed" to false,
                "anchorUsedForDeclination" to true,
                "liveGnssUsed" to false,
            )
        }

        private fun finishWithError(
            code: String,
            message: String,
        ): Boolean {
            if (!completed.compareAndSet(false, true)) {
                return false
            }

            cleanup()
            releaseSession(this)
            postError(callback, code, message)
            return true
        }

        private fun cleanup() {
            runCatching {
                sensorHandler?.removeCallbacksAndMessages(null)
            }
            runCatching {
                if (listenersRegistered) {
                    sensorManager.unregisterListener(this)
                    listenersRegistered = false
                }
            }
            sensorHandler = null
            runCatching {
                if (handlerThread.isAlive) {
                    handlerThread.quitSafely()
                }
            }
        }
    }

    private data class HeadingSample(
        val timestampNanos: Long,
        val trueHeadingRad: Double,
    )

    private data class CollectedSession(
        val stepUpdateCount: Long,
        val acceptedStepEventCount: Long,
        val invalidStepEventCount: Long,
        val outOfWindowStepEventCount: Long,
        val uniqueStepTimestampCount: Long,
        val duplicateStepTimestampCount: Long,
        val nonMonotonicStepTimestampCount: Long,
        val headingUpdateCount: Long,
        val validHeadingSampleCount: Long,
        val invalidHeadingSampleCount: Long,
        val uniqueHeadingTimestampCount: Long,
        val duplicateHeadingTimestampCount: Long,
        val nonMonotonicHeadingTimestampCount: Long,
        val headingSamples: List<HeadingSample>,
        val acceptedStepTimestamps: List<Long>,
    )

    private data class AgeStatistics(
        val minMs: Double?,
        val maxMs: Double?,
        val meanMs: Double?,
        val medianMs: Double?,
        val p95Ms: Double?,
    )

    private companion object {
        const val SCHEMA_VERSION = 1
        const val SNAPSHOT_KIND_PREFLIGHT = "baseline_pdr_preflight"
        const val SNAPSHOT_KIND_DIAGNOSTIC_RESULT =
            "baseline_pdr_diagnostic_result"

        const val BASELINE_STEP_LENGTH_METERS = 0.75
        const val STEP_LENGTH_MODEL = "fixed_baseline"
        const val SESSION_DURATION_MS = 30_000L
        const val NANOS_PER_MILLISECOND_LONG = 1_000_000L
        const val NANOS_PER_MILLISECOND = 1_000_000.0
        const val SESSION_DURATION_NANOS =
            SESSION_DURATION_MS * NANOS_PER_MILLISECOND_LONG
        const val HEADING_REQUESTED_SAMPLING_PERIOD_US = 20_000
        const val MAX_REPORT_LATENCY_US = 0
        const val REQUIRED_ROTATION_VECTOR_COMPONENT_COUNT = 3
        const val HORIZONTAL_NORM_EPSILON = 1e-6
        const val STEP_EVENT_VALUE = 1.0f
        const val TWO_PI = 2.0 * PI
        const val HANDLER_THREAD_NAME = "NAVGUARD-BaselinePdr"

        const val COORDINATE_FRAME = "local_enu"
        const val HEADING_CONVENTION = "clockwise_from_north_0_to_2pi"
        const val DEVICE_FORWARD_AXIS = "device_positive_y_top_edge"
        const val STEP_SOURCE = "TYPE_STEP_DETECTOR"
        const val HEADING_SOURCE = "TYPE_ROTATION_VECTOR"
        const val SENSOR_TIMESTAMP_AUTHORITY = "SensorEvent.timestamp"
        const val OPERATION_WINDOW_CLOCK = "SystemClock.elapsedRealtimeNanos"
        const val HEADING_ASSOCIATION_POLICY =
            "latest_valid_heading_at_or_before_step_timestamp"
        const val DECLINATION_PROVIDER = "android.hardware.GeomagneticField"
        const val DECLINATION_MODEL_VERSION = "platform_managed"
        const val DECLINATION_ALTITUDE_SOURCE_ANCHOR =
            "anchor_ellipsoid_altitude"
        const val DECLINATION_ALTITUDE_SOURCE_ZERO_FALLBACK =
            "deterministic_zero_fallback"

        const val ERROR_ROTATION_VECTOR_UNAVAILABLE =
            "baseline_pdr_rotation_vector_unavailable"
        const val ERROR_STEP_DETECTOR_UNAVAILABLE =
            "baseline_pdr_step_detector_unavailable"
        const val ERROR_ACTIVITY_RECOGNITION_PERMISSION_REQUIRED =
            "activity_recognition_permission_required"
        const val ERROR_ANCHOR_REQUIRED = "baseline_pdr_anchor_required"
        const val ERROR_ALREADY_RUNNING = "baseline_pdr_already_running"
        const val ERROR_SENSOR_REGISTRATION_FAILED =
            "baseline_pdr_sensor_registration_failed"
        const val ERROR_CANCELLED = "baseline_pdr_cancelled"
        const val ERROR_INTERNAL = "internal_baseline_pdr_error"

        fun normalizeHeadingRadians(angle: Double): Double {
            var normalized = angle % TWO_PI
            if (normalized < 0.0) {
                normalized += TWO_PI
            }
            return if (normalized >= TWO_PI) 0.0 else normalized
        }

        fun calculateAgeStatistics(sortedAgesNanos: List<Long>): AgeStatistics {
            if (sortedAgesNanos.isEmpty()) {
                return AgeStatistics(null, null, null, null, null)
            }

            val middle = sortedAgesNanos.size / 2
            val medianNanos =
                if (sortedAgesNanos.size % 2 == 0) {
                    (
                        sortedAgesNanos[middle - 1].toDouble() +
                            sortedAgesNanos[middle].toDouble()
                    ) / 2.0
                } else {
                    sortedAgesNanos[middle].toDouble()
                }
            val p95Index =
                (ceil(sortedAgesNanos.size * 0.95).toInt() - 1)
                    .coerceIn(0, sortedAgesNanos.lastIndex)

            return AgeStatistics(
                minMs = sortedAgesNanos.first().toDouble() / NANOS_PER_MILLISECOND,
                maxMs = sortedAgesNanos.last().toDouble() / NANOS_PER_MILLISECOND,
                meanMs = sortedAgesNanos.average() / NANOS_PER_MILLISECOND,
                medianMs = medianNanos / NANOS_PER_MILLISECOND,
                p95Ms = sortedAgesNanos[p95Index].toDouble() / NANOS_PER_MILLISECOND,
            )
        }
    }
}
