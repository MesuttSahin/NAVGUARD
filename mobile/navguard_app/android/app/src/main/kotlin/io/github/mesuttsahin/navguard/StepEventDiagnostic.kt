package io.github.mesuttsahin.navguard

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
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
import kotlin.math.ceil

internal class StepEventDiagnostic(
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
        val stepDetector = getStepDetector()
        val permissionRequired = isActivityRecognitionPermissionRequired()
        val permissionGranted = hasActivityRecognitionPermission()
        val diagnosticRunning = isDiagnosticRunning()

        return linkedMapOf(
            "schemaVersion" to SCHEMA_VERSION,
            "snapshotKind" to SNAPSHOT_KIND_PREFLIGHT,
            "stepDetectorAvailable" to (stepDetector != null),
            "stepDetectorName" to stepDetector?.name,
            "activityRecognitionPermissionRequired" to permissionRequired,
            "activityRecognitionPermissionGranted" to permissionGranted,
            "diagnosticRunning" to diagnosticRunning,
            "canRunStepDiagnostic" to
                (
                    stepDetector != null &&
                        permissionGranted &&
                        !diagnosticRunning
                ),
        )
    }

    fun start(callback: Callback) {
        if (isDiagnosticRunning()) {
            postError(
                callback = callback,
                code = ERROR_ALREADY_RUNNING,
                message = "A step-event diagnostic is already running.",
            )
            return
        }

        val stepDetector = getStepDetector()

        if (stepDetector == null) {
            postError(
                callback = callback,
                code = ERROR_STEP_DETECTOR_UNAVAILABLE,
                message = "TYPE_STEP_DETECTOR is unavailable.",
            )
            return
        }

        if (!hasActivityRecognitionPermission()) {
            postError(
                callback = callback,
                code = ERROR_ACTIVITY_RECOGNITION_PERMISSION_REQUIRED,
                message = "Physical activity recognition permission is required.",
            )
            return
        }

        val session =
            Session(
                selectedSensor = stepDetector,
                callback = callback,
            )

        if (!reserveSession(session)) {
            postError(
                callback = callback,
                code = ERROR_ALREADY_RUNNING,
                message = "A step-event diagnostic is already running.",
            )
            return
        }

        session.start()
    }

    fun cancelActiveSession(
        message: String = "Step-event diagnostic cancelled by the user.",
    ): Boolean {
        val session =
            synchronized(activeSessionLock) {
                activeSession
            } ?: return false

        return session.cancel(message)
    }

    fun isDiagnosticRunning(): Boolean =
        synchronized(activeSessionLock) {
            activeSession != null
        }

    private fun getStepDetector(): Sensor? =
        try {
            sensorManager.getDefaultSensor(Sensor.TYPE_STEP_DETECTOR)
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
        private val selectedSensor: Sensor,
        private val callback: Callback,
    ) : SensorEventListener {
        private val completed = AtomicBoolean(false)
        private val stateLock = Any()
        private val uniqueTimestampsNanos = mutableSetOf<Long>()
        private val positiveStepIntervalsNanos = mutableListOf<Long>()

        private val handlerThread =
            HandlerThread("NAVGUARD-StepEventDiagnostic")

        private var sensorHandler: Handler? = null
        private var sessionStartElapsedRealtimeNanos = 0L
        private var sessionEndElapsedRealtimeNanos = 0L
        private var updateCount = 0L
        private var acceptedStepEventCount = 0L
        private var invalidStepEventCount = 0L
        private var outOfWindowStepEventCount = 0L
        private var duplicateTimestampCount = 0L
        private var nonMonotonicTimestampCount = 0L
        private var previousAcceptedTimestampNanos: Long? = null

        private val timeoutRunnable =
            Runnable {
                finishSuccessfully()
            }

        fun start() {
            try {
                handlerThread.start()

                val callbackHandler = Handler(handlerThread.looper)
                sensorHandler = callbackHandler

                sessionStartElapsedRealtimeNanos =
                    SystemClock.elapsedRealtimeNanos()
                sessionEndElapsedRealtimeNanos =
                    sessionStartElapsedRealtimeNanos +
                    SESSION_DURATION_NANOS

                val registrationSucceeded =
                    sensorManager.registerListener(
                        this,
                        selectedSensor,
                        SensorManager.SENSOR_DELAY_NORMAL,
                        MAX_REPORT_LATENCY_US,
                        callbackHandler,
                    )

                if (!registrationSucceeded) {
                    finishWithError(
                        code = ERROR_SENSOR_REGISTRATION_FAILED,
                        message =
                            "Android rejected the step-detector listener registration.",
                    )
                    return
                }

                val timeoutScheduled =
                    callbackHandler.postDelayed(
                        timeoutRunnable,
                        SESSION_DURATION_MS,
                    )

                if (!timeoutScheduled) {
                    finishWithError(
                        code = ERROR_INTERNAL,
                        message =
                            "Unable to schedule step diagnostic termination.",
                    )
                }
            } catch (_: SecurityException) {
                finishWithError(
                    code = ERROR_ACTIVITY_RECOGNITION_PERMISSION_REQUIRED,
                    message =
                        "Physical activity recognition permission is required.",
                )
            } catch (_: Exception) {
                finishWithError(
                    code = ERROR_INTERNAL,
                    message = "Unable to start the step-event diagnostic.",
                )
            }
        }

        fun cancel(message: String): Boolean =
            finishWithError(
                code = ERROR_CANCELLED,
                message = message,
            )

        override fun onSensorChanged(event: SensorEvent) {
            if (completed.get()) {
                return
            }

            synchronized(stateLock) {
                if (completed.get()) {
                    return
                }

                updateCount += 1L

                val timestampNanos = event.timestamp
                val stepValue =
                    if (event.values.isNotEmpty()) {
                        event.values[0]
                    } else {
                        null
                    }

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

                if (uniqueTimestampsNanos.contains(timestampNanos)) {
                    duplicateTimestampCount += 1L
                    return
                }

                val previousTimestamp = previousAcceptedTimestampNanos

                if (
                    previousTimestamp != null &&
                    timestampNanos < previousTimestamp
                ) {
                    nonMonotonicTimestampCount += 1L
                    return
                }

                if (previousTimestamp != null) {
                    positiveStepIntervalsNanos.add(
                        timestampNanos - previousTimestamp,
                    )
                }

                uniqueTimestampsNanos.add(timestampNanos)
                acceptedStepEventCount += 1L
                previousAcceptedTimestampNanos = timestampNanos
            }
        }

        override fun onAccuracyChanged(
            sensor: Sensor,
            accuracy: Int,
        ) {
            // TYPE_STEP_DETECTOR accuracy callbacks are not estimator input.
        }

        private fun finishSuccessfully() {
            if (!completed.compareAndSet(false, true)) {
                return
            }

            cleanup()

            val collectedSteps =
                synchronized(stateLock) {
                    CollectedSteps(
                        updateCount = updateCount,
                        acceptedStepEventCount = acceptedStepEventCount,
                        invalidStepEventCount = invalidStepEventCount,
                        outOfWindowStepEventCount =
                            outOfWindowStepEventCount,
                        uniqueTimestampCount =
                            uniqueTimestampsNanos.size.toLong(),
                        duplicateTimestampCount =
                            duplicateTimestampCount,
                        nonMonotonicTimestampCount =
                            nonMonotonicTimestampCount,
                        positiveStepIntervalsNanos =
                            positiveStepIntervalsNanos.toList(),
                    )
                }

            val summary = createSummary(collectedSteps)

            releaseSession(this)
            postSuccess(callback, summary)
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
            steps: CollectedSteps,
        ): Map<String, Any?> {
            val sortedIntervalsNanos =
                steps.positiveStepIntervalsNanos.sorted()
            val deltaCount = sortedIntervalsNanos.size.toLong()

            val minStepIntervalMs =
                sortedIntervalsNanos.firstOrNull()?.let(::nanosToMillis)
            val maxStepIntervalMs =
                sortedIntervalsNanos.lastOrNull()?.let(::nanosToMillis)
            val meanStepIntervalMs =
                if (sortedIntervalsNanos.isEmpty()) {
                    null
                } else {
                    sortedIntervalsNanos
                        .sumOf { interval -> interval.toDouble() }
                        .div(sortedIntervalsNanos.size.toDouble())
                        .div(NANOS_PER_MILLISECOND)
                }
            val medianStepIntervalMs =
                calculateMedian(sortedIntervalsNanos)
                    ?.div(NANOS_PER_MILLISECOND)
            val p95StepIntervalMs =
                calculateNearestRankP95(sortedIntervalsNanos)
                    ?.let(::nanosToMillis)
            val observedCadenceStepsPerMinute =
                meanStepIntervalMs?.let { meanIntervalMs ->
                    MILLISECONDS_PER_MINUTE / meanIntervalMs
                }

            return linkedMapOf(
                "schemaVersion" to SCHEMA_VERSION,
                "snapshotKind" to SNAPSHOT_KIND_DIAGNOSTIC_RESULT,
                "success" to true,
                "sensorType" to SENSOR_TYPE_NAME,
                "sensorName" to selectedSensor.name,
                "sessionDurationMs" to SESSION_DURATION_MS,
                "stepTimestampAuthority" to STEP_TIMESTAMP_AUTHORITY,
                "operationWindowClock" to OPERATION_WINDOW_CLOCK,
                "wallClockUsedForStepTiming" to false,
                "updateCount" to steps.updateCount,
                "acceptedStepEventCount" to
                    steps.acceptedStepEventCount,
                "invalidStepEventCount" to
                    steps.invalidStepEventCount,
                "outOfWindowStepEventCount" to
                    steps.outOfWindowStepEventCount,
                "uniqueTimestampCount" to
                    steps.uniqueTimestampCount,
                "duplicateTimestampCount" to
                    steps.duplicateTimestampCount,
                "nonMonotonicTimestampCount" to
                    steps.nonMonotonicTimestampCount,
                "deltaCount" to deltaCount,
                "minStepIntervalMs" to minStepIntervalMs,
                "maxStepIntervalMs" to maxStepIntervalMs,
                "meanStepIntervalMs" to meanStepIntervalMs,
                "medianStepIntervalMs" to medianStepIntervalMs,
                "p95StepIntervalMs" to p95StepIntervalMs,
                "observedCadenceStepsPerMinute" to
                    observedCadenceStepsPerMinute,
                "stepDetectionAccuracyValidated" to false,
                "stepLengthImplemented" to false,
                "pdrPositionImplemented" to false,
                "rawStepEventsReturned" to false,
                "rawSensorSamplesReturned" to false,
                "persistenceUsed" to false,
            )
        }
    }

    private data class CollectedSteps(
        val updateCount: Long,
        val acceptedStepEventCount: Long,
        val invalidStepEventCount: Long,
        val outOfWindowStepEventCount: Long,
        val uniqueTimestampCount: Long,
        val duplicateTimestampCount: Long,
        val nonMonotonicTimestampCount: Long,
        val positiveStepIntervalsNanos: List<Long>,
    )

    private companion object {
        const val SCHEMA_VERSION = 1
        const val SNAPSHOT_KIND_PREFLIGHT = "step_event_preflight"
        const val SNAPSHOT_KIND_DIAGNOSTIC_RESULT =
            "step_event_diagnostic_result"

        const val SENSOR_TYPE_NAME = "TYPE_STEP_DETECTOR"
        const val STEP_TIMESTAMP_AUTHORITY = "SensorEvent.timestamp"
        const val OPERATION_WINDOW_CLOCK =
            "SystemClock.elapsedRealtimeNanos"

        const val SESSION_DURATION_MS = 30_000L
        const val NANOS_PER_MILLISECOND_LONG = 1_000_000L
        const val SESSION_DURATION_NANOS =
            SESSION_DURATION_MS * NANOS_PER_MILLISECOND_LONG
        const val NANOS_PER_MILLISECOND = 1_000_000.0
        const val MILLISECONDS_PER_MINUTE = 60_000.0
        const val MAX_REPORT_LATENCY_US = 0
        const val STEP_EVENT_VALUE = 1.0f

        const val ERROR_STEP_DETECTOR_UNAVAILABLE =
            "step_detector_unavailable"
        const val ERROR_ACTIVITY_RECOGNITION_PERMISSION_REQUIRED =
            "activity_recognition_permission_required"
        const val ERROR_ALREADY_RUNNING =
            "step_diagnostic_already_running"
        const val ERROR_SENSOR_REGISTRATION_FAILED =
            "sensor_registration_failed"
        const val ERROR_CANCELLED =
            "step_diagnostic_cancelled"
        const val ERROR_INTERNAL =
            "internal_step_diagnostic_error"

        fun nanosToMillis(value: Long): Double =
            value.toDouble() / NANOS_PER_MILLISECOND

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

        fun calculateNearestRankP95(
            sortedValues: List<Long>,
        ): Long? {
            if (sortedValues.isEmpty()) {
                return null
            }

            val oneBasedRank =
                ceil(0.95 * sortedValues.size.toDouble())
                    .toInt()
                    .coerceIn(1, sortedValues.size)

            return sortedValues[oneBasedRank - 1]
        }
    }
}