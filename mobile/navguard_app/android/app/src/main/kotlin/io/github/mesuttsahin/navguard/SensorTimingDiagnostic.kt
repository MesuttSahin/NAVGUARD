package io.github.mesuttsahin.navguard

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.math.ceil

internal class SensorTimingDiagnostic(
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

    fun start(
        sensorKey: String?,
        callback: Callback,
    ) {
        if (hasActiveSession()) {
            postError(
                callback = callback,
                code = ERROR_ALREADY_RUNNING,
                message = "A sensor timing diagnostic is already running.",
            )
            return
        }

        val sensorDefinition =
            if (sensorKey == null) {
                null
            } else {
                SUPPORTED_SENSORS[sensorKey]
            }

        if (sensorDefinition == null) {
            postError(
                callback = callback,
                code = ERROR_UNSUPPORTED_SENSOR_KEY,
                message = "A supported sensorKey is required.",
            )
            return
        }

        val sensor =
            try {
                sensorManager.getDefaultSensor(sensorDefinition.sensorTypeId)
            } catch (_: Exception) {
                postError(
                    callback = callback,
                    code = ERROR_TIMING_FAILED,
                    message = "Unable to access the selected Android sensor.",
                )
                return
            }

        if (sensor == null) {
            postError(
                callback = callback,
                code = ERROR_SENSOR_UNAVAILABLE,
                message = "The selected default sensor is unavailable.",
            )
            return
        }

        val session =
            Session(
                sensorDefinition = sensorDefinition,
                selectedSensor = sensor,
                callback = callback,
            )

        if (!reserveSession(session)) {
            postError(
                callback = callback,
                code = ERROR_ALREADY_RUNNING,
                message = "A sensor timing diagnostic is already running.",
            )
            return
        }

        session.start()
    }

    fun cancelActiveSession(message: String) {
        val session =
            synchronized(activeSessionLock) {
                activeSession
            }

        session?.cancel(message)
    }

    private fun hasActiveSession(): Boolean {
        return synchronized(activeSessionLock) {
            activeSession != null
        }
    }

    private fun reserveSession(session: Session): Boolean {
        return synchronized(activeSessionLock) {
            if (activeSession != null) {
                false
            } else {
                activeSession = session
                true
            }
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
        resultHandler.post {
            callback.onSuccess(summary)
        }
    }

    private fun postError(
        callback: Callback,
        code: String,
        message: String,
    ) {
        resultHandler.post {
            callback.onError(code, message)
        }
    }

    private inner class Session(
        private val sensorDefinition: SupportedSensor,
        private val selectedSensor: Sensor,
        private val callback: Callback,
    ) : SensorEventListener {
        private val completed = AtomicBoolean(false)
        private val timingStateLock = Any()
        private val timestampDeltasNs = mutableListOf<Long>()

        private val handlerThread =
            HandlerThread("NAVGUARD-SensorTiming-${sensorDefinition.key}")

        private var sensorHandler: Handler? = null
        private var eventCount = 0L
        private var firstTimestampNs: Long? = null
        private var previousTimestampNs: Long? = null
        private var lastTimestampNs: Long? = null
        private var nonMonotonicTimestampCount = 0L
        private var accuracyChangeCount = 0L
        private var lastAccuracy: Int? = null

        private val timeoutRunnable =
            Runnable {
                finishSuccessfully()
            }

        fun start() {
            try {
                handlerThread.start()

                val callbackHandler = Handler(handlerThread.looper)
                sensorHandler = callbackHandler

                val registrationSucceeded =
                    sensorManager.registerListener(
                        this,
                        selectedSensor,
                        REQUESTED_SAMPLING_PERIOD_US,
                        MAX_REPORT_LATENCY_US,
                        callbackHandler,
                    )

                if (!registrationSucceeded) {
                    finishWithError(
                        code = ERROR_REGISTRATION_FAILED,
                        message = "Android rejected the sensor listener registration.",
                    )
                    return
                }

                val timeoutScheduled =
                    callbackHandler.postDelayed(
                        timeoutRunnable,
                        COLLECTION_DURATION_TARGET_MS,
                    )

                if (!timeoutScheduled) {
                    finishWithError(
                        code = ERROR_TIMEOUT_SCHEDULE_FAILED,
                        message = "Unable to schedule the sensor diagnostic timeout.",
                    )
                }
            } catch (_: Exception) {
                finishWithError(
                    code = ERROR_TIMING_FAILED,
                    message = "Unable to start the sensor timing diagnostic.",
                )
            }
        }

        fun cancel(message: String) {
            finishWithError(
                code = ERROR_CANCELLED,
                message = message,
            )
        }

        override fun onSensorChanged(event: SensorEvent) {
            if (completed.get() || event.sensor.type != selectedSensor.type) {
                return
            }

            val currentTimestampNs = event.timestamp

            synchronized(timingStateLock) {
                if (completed.get()) {
                    return
                }

                val previousTimestamp = previousTimestampNs

                if (firstTimestampNs == null) {
                    firstTimestampNs = currentTimestampNs
                }

                if (previousTimestamp != null) {
                    val deltaNs = currentTimestampNs - previousTimestamp
                    timestampDeltasNs.add(deltaNs)

                    if (deltaNs <= 0L) {
                        nonMonotonicTimestampCount += 1L
                    }
                }

                eventCount += 1L
                previousTimestampNs = currentTimestampNs
                lastTimestampNs = currentTimestampNs
            }
        }

        override fun onAccuracyChanged(
            sensor: Sensor,
            accuracy: Int,
        ) {
            if (completed.get() || sensor.type != selectedSensor.type) {
                return
            }

            synchronized(timingStateLock) {
                if (completed.get()) {
                    return
                }

                accuracyChangeCount += 1L
                lastAccuracy = accuracy
            }
        }

        private fun finishSuccessfully() {
            if (!completed.compareAndSet(false, true)) {
                return
            }

            cleanup()

            val collectedTiming =
                synchronized(timingStateLock) {
                    CollectedTiming(
                        eventCount = eventCount,
                        firstTimestampNs = firstTimestampNs,
                        lastTimestampNs = lastTimestampNs,
                        timestampDeltasNs = timestampDeltasNs.toList(),
                        nonMonotonicTimestampCount =
                            nonMonotonicTimestampCount,
                        accuracyChangeCount = accuracyChangeCount,
                        lastAccuracy = lastAccuracy,
                    )
                }

            val summary = createSummary(collectedTiming)

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
            runCatching {
                sensorHandler?.removeCallbacks(timeoutRunnable)
            }

            runCatching {
                sensorManager.unregisterListener(this)
            }

            runCatching {
                if (handlerThread.isAlive) {
                    handlerThread.quitSafely()
                }
            }
        }

        private fun createSummary(
            timing: CollectedTiming,
        ): Map<String, Any?> {
            val sortedDeltasNs = timing.timestampDeltasNs.sorted()
            val deltaCount = sortedDeltasNs.size.toLong()

            val firstTimestamp = timing.firstTimestampNs
            val lastTimestamp = timing.lastTimestampNs

            val durationNs =
                if (
                    timing.eventCount >= 2L &&
                    firstTimestamp != null &&
                    lastTimestamp != null
                ) {
                    lastTimestamp - firstTimestamp
                } else {
                    null
                }

            val minDeltaNs = sortedDeltasNs.minOrNull()
            val maxDeltaNs = sortedDeltasNs.maxOrNull()

            val meanDeltaNs =
                if (sortedDeltasNs.isEmpty()) {
                    null
                } else {
                    sortedDeltasNs.sumOf { delta ->
                        delta.toDouble()
                    } / sortedDeltasNs.size.toDouble()
                }

            val medianDeltaNs = calculateMedian(sortedDeltasNs)
            val p95DeltaNs = calculateNearestRankP95(sortedDeltasNs)

            val validTimingSummary =
                timing.eventCount >= 2L &&
                    deltaCount == timing.eventCount - 1L &&
                    timing.nonMonotonicTimestampCount == 0L &&
                    durationNs != null &&
                    durationNs > 0L &&
                    meanDeltaNs != null &&
                    meanDeltaNs > 0.0 &&
                    medianDeltaNs != null &&
                    medianDeltaNs > 0.0

            val meanDeliveredHz =
                if (validTimingSummary && meanDeltaNs != null) {
                    NANOS_PER_SECOND / meanDeltaNs
                } else {
                    null
                }

            val medianIntervalDerivedHz =
                if (validTimingSummary && medianDeltaNs != null) {
                    NANOS_PER_SECOND / medianDeltaNs
                } else {
                    null
                }

            // Informational only. This provisional threshold is not a PASS/FAIL
            // criterion and must be reviewed after repeated physical sessions.
            val largeGapCount =
                sortedDeltasNs.count { deltaNs ->
                    deltaNs > PROVISIONAL_GAP_THRESHOLD_NS
                }.toLong()

            val sensorSummary =
                linkedMapOf<String, Any?>(
                    "requestedType" to sensorDefinition.requestedType,
                    "requestedTypeId" to sensorDefinition.sensorTypeId,
                    "type" to selectedSensor.type,
                    "name" to selectedSensor.name,
                    "vendor" to selectedSensor.vendor,
                )

            return linkedMapOf(
                "schemaVersion" to 1,
                "snapshotKind" to "sensor_event_timing_diagnostic",
                "capabilityMetadataOnly" to false,
                "liveEventTimingDiagnostic" to true,
                "status" to "completed",
                "completionReason" to "duration_completed",
                "validTimingSummary" to validTimingSummary,
                "sensor" to sensorSummary,
                "timestampSource" to "SensorEvent.timestamp",
                "timestampDomain" to "elapsed_realtime_nanoseconds",
                "requestedSamplingPeriodUs" to
                    REQUESTED_SAMPLING_PERIOD_US,
                "requestedNominalRateHz" to
                    REQUESTED_NOMINAL_RATE_HZ,
                "collectionDurationTargetMs" to
                    COLLECTION_DURATION_TARGET_MS,
                "maxReportLatencyUs" to MAX_REPORT_LATENCY_US,
                "registrationSucceeded" to true,
                "eventCount" to timing.eventCount,
                "firstTimestampNs" to firstTimestamp,
                "lastTimestampNs" to lastTimestamp,
                "durationNs" to durationNs,
                "deltaCount" to deltaCount,
                "minDeltaNs" to minDeltaNs,
                "maxDeltaNs" to maxDeltaNs,
                "meanDeltaNs" to meanDeltaNs,
                "medianDeltaNs" to medianDeltaNs,
                "p95DeltaNs" to p95DeltaNs,
                "meanDeliveredHz" to meanDeliveredHz,
                "medianIntervalDerivedHz" to
                    medianIntervalDerivedHz,
                "nonMonotonicTimestampCount" to
                    timing.nonMonotonicTimestampCount,
                "gapThresholdMultiplier" to GAP_THRESHOLD_MULTIPLIER,
                "provisionalGapThresholdNs" to
                    PROVISIONAL_GAP_THRESHOLD_NS,
                "gapThresholdStatus" to "provisional",
                "largeGapCount" to largeGapCount,
                "accuracyChangeCount" to timing.accuracyChangeCount,
                "lastAccuracy" to timing.lastAccuracy,
            )
        }
    }

    private data class SupportedSensor(
        val key: String,
        val requestedType: String,
        val sensorTypeId: Int,
    )

    private data class CollectedTiming(
        val eventCount: Long,
        val firstTimestampNs: Long?,
        val lastTimestampNs: Long?,
        val timestampDeltasNs: List<Long>,
        val nonMonotonicTimestampCount: Long,
        val accuracyChangeCount: Long,
        val lastAccuracy: Int?,
    )

    private companion object {
        const val REQUESTED_SAMPLING_PERIOD_US = 20_000
        const val COLLECTION_DURATION_TARGET_MS = 10_000L
        const val MAX_REPORT_LATENCY_US = 0
        const val GAP_THRESHOLD_MULTIPLIER = 3.0

        const val REQUESTED_NOMINAL_RATE_HZ =
            1_000_000.0 / REQUESTED_SAMPLING_PERIOD_US

        const val NANOS_PER_SECOND = 1_000_000_000.0

        val PROVISIONAL_GAP_THRESHOLD_NS =
            (
                REQUESTED_SAMPLING_PERIOD_US.toLong() *
                    1_000L *
                    GAP_THRESHOLD_MULTIPLIER
            ).toLong()

        const val ERROR_UNSUPPORTED_SENSOR_KEY =
            "unsupported_sensor_key"

        const val ERROR_ALREADY_RUNNING =
            "sensor_timing_already_running"

        const val ERROR_SENSOR_UNAVAILABLE =
            "sensor_timing_sensor_unavailable"

        const val ERROR_REGISTRATION_FAILED =
            "sensor_timing_registration_failed"

        const val ERROR_TIMEOUT_SCHEDULE_FAILED =
            "sensor_timing_timeout_schedule_failed"

        const val ERROR_CANCELLED =
            "sensor_timing_cancelled"

        const val ERROR_TIMING_FAILED =
            "sensor_timing_failed"

        val SUPPORTED_SENSORS =
            listOf(
                SupportedSensor(
                    key = "accelerometer",
                    requestedType = "TYPE_ACCELEROMETER",
                    sensorTypeId = Sensor.TYPE_ACCELEROMETER,
                ),
                SupportedSensor(
                    key = "gyroscope",
                    requestedType = "TYPE_GYROSCOPE",
                    sensorTypeId = Sensor.TYPE_GYROSCOPE,
                ),
                SupportedSensor(
                    key = "magnetometer",
                    requestedType = "TYPE_MAGNETIC_FIELD",
                    sensorTypeId = Sensor.TYPE_MAGNETIC_FIELD,
                ),
                SupportedSensor(
                    key = "rotation_vector",
                    requestedType = "TYPE_ROTATION_VECTOR",
                    sensorTypeId = Sensor.TYPE_ROTATION_VECTOR,
                ),
            ).associateBy { sensor ->
                sensor.key
            }

        fun calculateMedian(sortedValues: List<Long>): Double? {
            if (sortedValues.isEmpty()) {
                return null
            }

            val middleIndex = sortedValues.size / 2

            return if (sortedValues.size % 2 == 1) {
                sortedValues[middleIndex].toDouble()
            } else {
                (
                    sortedValues[middleIndex - 1].toDouble() +
                        sortedValues[middleIndex].toDouble()
                ) / 2.0
            }
        }

        fun calculateNearestRankP95(sortedValues: List<Long>): Long? {
            if (sortedValues.isEmpty()) {
                return null
            }

            // Nearest-rank p95 uses ceil(0.95 * N), converted to zero-based index.
            val oneBasedRank =
                ceil(0.95 * sortedValues.size.toDouble())
                    .toInt()
                    .coerceIn(1, sortedValues.size)

            return sortedValues[oneBasedRank - 1]
        }
    }
}