package io.github.mesuttsahin.navguard

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.hardware.GeomagneticField
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.os.Bundle
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

internal class EvaluationModeDiagnostic(
    private val applicationContext: Context,
    private val locationManager: LocationManager,
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
        val gpsAvailable = readGpsProviderAvailable()
        val gpsEnabled = gpsAvailable && readGpsProviderEnabled()
        val fineLocationGranted = hasFineLocationPermission()
        val rotationVector = getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
        val stepDetector = getDefaultSensor(Sensor.TYPE_STEP_DETECTOR)
        val activityPermissionGranted = hasActivityRecognitionPermission()
        val firewallSelfTestPassed = runFirewallMutationSelfTest()
        val diagnosticRunning = isDiagnosticRunning()

        return linkedMapOf(
            "schemaVersion" to SCHEMA_VERSION,
            "snapshotKind" to SNAPSHOT_KIND_PREFLIGHT,
            "gpsProviderAvailable" to gpsAvailable,
            "gpsProviderEnabled" to gpsEnabled,
            "fineLocationPermissionGranted" to fineLocationGranted,
            "rotationVectorAvailable" to (rotationVector != null),
            "rotationVectorName" to rotationVector?.name,
            "stepDetectorAvailable" to (stepDetector != null),
            "stepDetectorName" to stepDetector?.name,
            "activityRecognitionPermissionRequired" to
                isActivityRecognitionPermissionRequired(),
            "activityRecognitionPermissionGranted" to activityPermissionGranted,
            "firewallMutationSelfTestPassed" to firewallSelfTestPassed,
            "diagnosticRunning" to diagnosticRunning,
            "nativeReady" to
                (
                    gpsAvailable &&
                        gpsEnabled &&
                        fineLocationGranted &&
                        rotationVector != null &&
                        stepDetector != null &&
                        activityPermissionGranted &&
                        firewallSelfTestPassed &&
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
        if (!isValidAnchor(anchorLatitudeDeg, anchorLongitudeDeg, anchorAltitudeEllipsoidM)) {
            postError(callback, ERROR_ANCHOR_REQUIRED, "A valid locked pre-denial GNSS anchor is required.")
            return
        }
        if (!readGpsProviderAvailable()) {
            postError(callback, ERROR_GPS_UNAVAILABLE, "GPS_PROVIDER is unavailable on this device.")
            return
        }
        if (!readGpsProviderEnabled()) {
            postError(callback, ERROR_GPS_DISABLED, "GPS_PROVIDER is disabled.")
            return
        }
        if (!hasFineLocationPermission()) {
            postError(callback, ERROR_LOCATION_PERMISSION_REQUIRED, "Precise foreground location permission is required.")
            return
        }

        val rotationVector = getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
        if (rotationVector == null) {
            postError(callback, ERROR_ROTATION_VECTOR_UNAVAILABLE, "TYPE_ROTATION_VECTOR is unavailable on this device.")
            return
        }
        val stepDetector = getDefaultSensor(Sensor.TYPE_STEP_DETECTOR)
        if (stepDetector == null) {
            postError(callback, ERROR_STEP_DETECTOR_UNAVAILABLE, "TYPE_STEP_DETECTOR is unavailable on this device.")
            return
        }
        if (!hasActivityRecognitionPermission()) {
            postError(callback, ERROR_ACTIVITY_PERMISSION_REQUIRED, "Physical activity recognition permission is required.")
            return
        }
        if (!runFirewallMutationSelfTest()) {
            postError(callback, ERROR_FIREWALL_SELF_TEST, "The Ground Truth Firewall self-test failed.")
            return
        }

        val declinationAltitudeM = anchorAltitudeEllipsoidM ?: 0.0
        val declinationRad =
            runCatching {
                Math.toRadians(
                    GeomagneticField(
                        anchorLatitudeDeg.toFloat(),
                        anchorLongitudeDeg.toFloat(),
                        declinationAltitudeM.toFloat(),
                        System.currentTimeMillis(),
                    ).declination.toDouble(),
                )
            }.getOrDefault(Double.NaN)
        if (!declinationRad.isFinite()) {
            postError(callback, ERROR_INTERNAL, "Unable to calculate geomagnetic declination.")
            return
        }

        val session =
            Session(
                anchor =
                    ProtectedAnchor(
                        latitudeDeg = anchorLatitudeDeg,
                        longitudeDeg = anchorLongitudeDeg,
                        altitudeEllipsoidM = anchorAltitudeEllipsoidM,
                    ),
                rotationVector = rotationVector,
                stepDetector = stepDetector,
                declinationRad = declinationRad,
                callback = callback,
            )
        if (!reserveSession(session)) {
            postError(callback, ERROR_ALREADY_RUNNING, "An Evaluation Mode diagnostic is already running.")
            return
        }
        session.start()
    }

    fun cancelActiveSession(
        message: String = "Evaluation Mode diagnostic cancelled by the user.",
    ): Boolean {
        val session = synchronized(activeSessionLock) { activeSession } ?: return false
        return session.cancel(message)
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

    private fun getDefaultSensor(type: Int): Sensor? =
        runCatching { sensorManager.getDefaultSensor(type) }.getOrNull()

    private fun readGpsProviderAvailable(): Boolean =
        runCatching { locationManager.allProviders.contains(LocationManager.GPS_PROVIDER) }
            .getOrDefault(false)

    private fun readGpsProviderEnabled(): Boolean =
        runCatching { locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER) }
            .getOrDefault(false)

    private fun hasFineLocationPermission(): Boolean =
        applicationContext.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) ==
            PackageManager.PERMISSION_GRANTED

    private fun isActivityRecognitionPermissionRequired(): Boolean =
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q

    private fun hasActivityRecognitionPermission(): Boolean =
        !isActivityRecognitionPermissionRequired() ||
            applicationContext.checkSelfPermission(Manifest.permission.ACTIVITY_RECOGNITION) ==
            PackageManager.PERMISSION_GRANTED

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
        private val anchor: ProtectedAnchor,
        private val rotationVector: Sensor,
        private val stepDetector: Sensor,
        private val declinationRad: Double,
        private val callback: Callback,
    ) : LocationListener, SensorEventListener {
        private val completed = AtomicBoolean(false)
        private val stateLock = Any()
        private val handlerThread = HandlerThread(HANDLER_THREAD_NAME)
        private val protectedGroundTruthCollector = ProtectedGroundTruthCollector()
        private val protectedGtTimestamps = mutableSetOf<Long>()
        private val headingTimestamps = mutableSetOf<Long>()
        private val stepTimestamps = mutableSetOf<Long>()

        private var handler: Handler? = null
        private var locationUpdatesRegistered = false
        private var sensorListenersRegistered = false
        private var phase = Phase.STARTING
        private var formalStartNanos = 0L
        private var formalEndNanos = 0L
        private var estimator: DeniedEstimatorCore? = null

        private var protectedGtUpdateCount = 0L
        private var acceptedProtectedGtFixCount = 0L
        private var invalidProtectedGtFixCount = 0L
        private var outOfWindowProtectedGtFixCount = 0L
        private var duplicateProtectedGtTimestampCount = 0L
        private var nonMonotonicProtectedGtTimestampCount = 0L
        private var mockProtectedGtFixCount = 0L
        private var previousProtectedGtTimestampNanos: Long? = null

        private var stepUpdateCount = 0L
        private var acceptedStepEventCount = 0L
        private var invalidStepEventCount = 0L
        private var outOfWindowStepEventCount = 0L
        private var duplicateStepTimestampCount = 0L
        private var nonMonotonicStepTimestampCount = 0L
        private var previousStepTimestampNanos: Long? = null

        private var headingUpdateCount = 0L
        private var validHeadingSampleCount = 0L
        private var invalidHeadingSampleCount = 0L
        private var duplicateHeadingTimestampCount = 0L
        private var nonMonotonicHeadingTimestampCount = 0L
        private var previousHeadingTimestampNanos: Long? = null

        private val firstFixTimeoutRunnable =
            Runnable {
                finishWithError(
                    ERROR_FIRST_FIX_TIMEOUT,
                    "No structurally valid protected GPS fix was received before the timeout.",
                )
            }
        private val evaluationTimeoutRunnable = Runnable { finishSuccessfully() }

        fun start() {
            val sessionHandler =
                try {
                    handlerThread.start()
                    Handler(handlerThread.looper)
                } catch (_: Exception) {
                    finishWithError(ERROR_INTERNAL, "Unable to start the Evaluation Mode worker.")
                    return
                }
            handler = sessionHandler
            if (!sessionHandler.post { initializeProtectedGroundTruth(sessionHandler) }) {
                finishWithError(ERROR_INTERNAL, "Unable to initialize Evaluation Mode.")
            }
        }

        @Suppress("MissingPermission")
        private fun initializeProtectedGroundTruth(sessionHandler: Handler) {
            if (completed.get()) {
                return
            }
            try {
                locationManager.requestLocationUpdates(
                    LocationManager.GPS_PROVIDER,
                    PROTECTED_GT_MIN_TIME_MS,
                    PROTECTED_GT_MIN_DISTANCE_M,
                    this,
                    handlerThread.looper,
                )
                locationUpdatesRegistered = true
                phase = Phase.WAITING_FOR_FIRST_PROTECTED_FIX
                if (!sessionHandler.postDelayed(firstFixTimeoutRunnable, PROTECTED_GT_FIRST_FIX_TIMEOUT_MS)) {
                    finishWithError(ERROR_INTERNAL, "Unable to schedule the protected GPS first-fix timeout.")
                }
            } catch (_: SecurityException) {
                finishWithError(ERROR_LOCATION_PERMISSION_REQUIRED, "Precise foreground location permission is required.")
            } catch (_: IllegalArgumentException) {
                finishWithError(ERROR_GPS_UNAVAILABLE, "GPS_PROVIDER could not be registered.")
            } catch (_: Exception) {
                finishWithError(ERROR_INTERNAL, "Unable to register protected GPS updates.")
            }
        }

        override fun onLocationChanged(location: Location) {
            if (completed.get()) {
                return
            }
            synchronized(stateLock) {
                protectedGtUpdateCount += 1L
                val mock = isMockLocation(location)
                if (mock) {
                    mockProtectedGtFixCount += 1L
                }
                val fix = createProtectedGroundTruthFix(location)
                if (fix == null || mock) {
                    invalidProtectedGtFixCount += 1L
                    return
                }

                if (phase == Phase.WAITING_FOR_FIRST_PROTECTED_FIX) {
                    outOfWindowProtectedGtFixCount += 1L
                    handler?.removeCallbacks(firstFixTimeoutRunnable)
                    beginFormalEvaluation()
                    return
                }
                if (phase != Phase.FORMAL_EVALUATION) {
                    outOfWindowProtectedGtFixCount += 1L
                    return
                }
                if (fix.elapsedRealtimeNanos < formalStartNanos || fix.elapsedRealtimeNanos > formalEndNanos) {
                    outOfWindowProtectedGtFixCount += 1L
                    return
                }
                if (protectedGtTimestamps.contains(fix.elapsedRealtimeNanos)) {
                    duplicateProtectedGtTimestampCount += 1L
                    return
                }
                val previous = previousProtectedGtTimestampNanos
                if (previous != null && fix.elapsedRealtimeNanos < previous) {
                    nonMonotonicProtectedGtTimestampCount += 1L
                    return
                }
                protectedGtTimestamps.add(fix.elapsedRealtimeNanos)
                protectedGroundTruthCollector.accept(fix)
                acceptedProtectedGtFixCount += 1L
                previousProtectedGtTimestampNanos = fix.elapsedRealtimeNanos
            }
        }

        private fun beginFormalEvaluation() {
            if (completed.get() || phase != Phase.WAITING_FOR_FIRST_PROTECTED_FIX) {
                return
            }
            val sessionHandler = handler
            if (sessionHandler == null) {
                finishWithError(ERROR_INTERNAL, "Evaluation Mode worker is unavailable.")
                return
            }

            formalStartNanos = SystemClock.elapsedRealtimeNanos()
            formalEndNanos = formalStartNanos + EVALUATION_WINDOW_NANOS
            estimator = DeniedEstimatorCore(declinationRad, formalStartNanos)
            try {
                val headingRegistered =
                    sensorManager.registerListener(
                        this,
                        rotationVector,
                        HEADING_REQUESTED_SAMPLING_PERIOD_US,
                        MAX_REPORT_LATENCY_US,
                        sessionHandler,
                    )
                if (!headingRegistered) {
                    finishWithError(ERROR_SENSOR_REGISTRATION_FAILED, "Android rejected the rotation-vector registration.")
                    return
                }
                sensorListenersRegistered = true
                val stepRegistered =
                    sensorManager.registerListener(
                        this,
                        stepDetector,
                        SensorManager.SENSOR_DELAY_NORMAL,
                        MAX_REPORT_LATENCY_US,
                        sessionHandler,
                    )
                if (!stepRegistered) {
                    finishWithError(ERROR_SENSOR_REGISTRATION_FAILED, "Android rejected the step-detector registration.")
                    return
                }
            } catch (_: SecurityException) {
                finishWithError(ERROR_ACTIVITY_PERMISSION_REQUIRED, "Physical activity recognition permission is required.")
                return
            } catch (_: Exception) {
                finishWithError(ERROR_SENSOR_REGISTRATION_FAILED, "Android rejected an Evaluation Mode sensor registration.")
                return
            }
            phase = Phase.FORMAL_EVALUATION
            if (!sessionHandler.postDelayed(evaluationTimeoutRunnable, EVALUATION_WINDOW_MS)) {
                finishWithError(ERROR_INTERNAL, "Unable to schedule Evaluation Mode completion.")
            }
        }

        override fun onSensorChanged(event: SensorEvent) {
            if (completed.get() || phase != Phase.FORMAL_EVALUATION) {
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
        ) = Unit

        private fun handleHeadingEvent(event: SensorEvent) {
            synchronized(stateLock) {
                headingUpdateCount += 1L
                val sample = createTrueHeadingSample(event)
                if (sample == null || sample.timestampNanos < formalStartNanos || sample.timestampNanos > formalEndNanos) {
                    invalidHeadingSampleCount += 1L
                    return
                }
                if (headingTimestamps.contains(sample.timestampNanos)) {
                    duplicateHeadingTimestampCount += 1L
                    return
                }
                val previous = previousHeadingTimestampNanos
                if (previous != null && sample.timestampNanos < previous) {
                    nonMonotonicHeadingTimestampCount += 1L
                    return
                }
                headingTimestamps.add(sample.timestampNanos)
                validHeadingSampleCount += 1L
                previousHeadingTimestampNanos = sample.timestampNanos
                estimator?.acceptHeading(sample.timestampNanos, sample.trueHeadingRad)
            }
        }

        private fun handleStepEvent(event: SensorEvent) {
            synchronized(stateLock) {
                stepUpdateCount += 1L
                val timestamp = event.timestamp
                val stepValue = event.values.firstOrNull()
                if (
                    timestamp <= 0L ||
                        stepValue == null ||
                        !stepValue.isFinite() ||
                        stepValue != STEP_EVENT_VALUE
                ) {
                    invalidStepEventCount += 1L
                    return
                }
                if (timestamp < formalStartNanos || timestamp > formalEndNanos) {
                    outOfWindowStepEventCount += 1L
                    return
                }
                if (stepTimestamps.contains(timestamp)) {
                    duplicateStepTimestampCount += 1L
                    return
                }
                val previous = previousStepTimestampNanos
                if (previous != null && timestamp < previous) {
                    nonMonotonicStepTimestampCount += 1L
                    return
                }
                stepTimestamps.add(timestamp)
                acceptedStepEventCount += 1L
                previousStepTimestampNanos = timestamp
                estimator?.acceptStep(timestamp)
            }
        }

        private fun createTrueHeadingSample(event: SensorEvent): HeadingSample? {
            if (event.timestamp <= 0L || event.values.size < REQUIRED_ROTATION_VECTOR_COMPONENT_COUNT) {
                return null
            }
            val count = if (event.values.size >= 4) 4 else 3
            val values = FloatArray(count)
            for (index in 0 until count) {
                val value = event.values[index]
                if (!value.isFinite()) {
                    return null
                }
                values[index] = value
            }
            val matrix = FloatArray(9)
            return try {
                SensorManager.getRotationMatrixFromVector(matrix, values)
                if (matrix.any { !it.isFinite() }) {
                    null
                } else {
                    val east = matrix[1].toDouble()
                    val north = matrix[4].toDouble()
                    val norm = sqrt((east * east) + (north * north))
                    if (!norm.isFinite() || norm <= HORIZONTAL_NORM_EPSILON) {
                        null
                    } else {
                        HeadingSample(
                            timestampNanos = event.timestamp,
                            trueHeadingRad = normalizeHeading(atan2(east, north) + declinationRad),
                        )
                    }
                }
            } catch (_: Exception) {
                null
            }
        }

        private fun createProtectedGroundTruthFix(location: Location): ProtectedGroundTruthFix? {
            if (location.provider != LocationManager.GPS_PROVIDER) {
                return null
            }
            val latitude = location.latitude
            val longitude = location.longitude
            val timestamp = location.elapsedRealtimeNanos
            val accuracy =
                if (location.hasAccuracy()) {
                    location.accuracy.toDouble()
                } else {
                    null
                }
            if (
                !latitude.isFinite() || latitude !in -90.0..90.0 ||
                !longitude.isFinite() || longitude !in -180.0..180.0 ||
                timestamp <= 0L ||
                (accuracy != null && (!accuracy.isFinite() || accuracy < 0.0))
            ) {
                return null
            }
            val altitude =
                if (location.hasAltitude()) {
                    location.altitude.takeIf { it.isFinite() }
                } else {
                    null
                }
            return ProtectedGroundTruthFix(
                latitudeDeg = latitude,
                longitudeDeg = longitude,
                altitudeEllipsoidM = altitude,
                horizontalAccuracyReportedM = accuracy,
                elapsedRealtimeNanos = timestamp,
            )
        }

        @Suppress("DEPRECATION")
        private fun isMockLocation(location: Location): Boolean =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                location.isMock
            } else {
                location.isFromMockProvider
            }

        override fun onProviderDisabled(provider: String) {
            if (provider == LocationManager.GPS_PROVIDER) {
                finishWithError(ERROR_GPS_DISABLED, "GPS_PROVIDER was disabled during Evaluation Mode.")
            }
        }

        override fun onProviderEnabled(provider: String) = Unit

        @Suppress("DEPRECATION")
        override fun onStatusChanged(
            provider: String?,
            status: Int,
            extras: Bundle?,
        ) = Unit

        fun cancel(message: String): Boolean = finishWithError(ERROR_CANCELLED, message)

        private fun finishSuccessfully() {
            if (!completed.compareAndSet(false, true)) {
                return
            }
            phase = Phase.COMPLETED
            cleanupRegistrations()
            val collected =
                synchronized(stateLock) {
                    val deniedEstimator = estimator
                    val value =
                        if (deniedEstimator == null) {
                            null
                        } else {
                            val finalizedEstimator = deniedEstimator.finalizeState()
                            CollectedSession(
                                protectedFixes = protectedGroundTruthCollector.snapshot(),
                                estimatorSnapshots = finalizedEstimator.snapshots,
                                associatedStepCount = finalizedEstimator.associatedStepCount,
                                unassociatedStepCount = finalizedEstimator.unassociatedStepCount,
                                protectedGtUpdateCount = protectedGtUpdateCount,
                                acceptedProtectedGtFixCount = acceptedProtectedGtFixCount,
                                invalidProtectedGtFixCount = invalidProtectedGtFixCount,
                                outOfWindowProtectedGtFixCount = outOfWindowProtectedGtFixCount,
                                duplicateProtectedGtTimestampCount = duplicateProtectedGtTimestampCount,
                                nonMonotonicProtectedGtTimestampCount = nonMonotonicProtectedGtTimestampCount,
                                mockProtectedGtFixCount = mockProtectedGtFixCount,
                                stepUpdateCount = stepUpdateCount,
                                acceptedStepEventCount = acceptedStepEventCount,
                                invalidStepEventCount = invalidStepEventCount,
                                outOfWindowStepEventCount = outOfWindowStepEventCount,
                                duplicateStepTimestampCount = duplicateStepTimestampCount,
                                nonMonotonicStepTimestampCount = nonMonotonicStepTimestampCount,
                                headingUpdateCount = headingUpdateCount,
                                validHeadingSampleCount = validHeadingSampleCount,
                                invalidHeadingSampleCount = invalidHeadingSampleCount,
                                duplicateHeadingTimestampCount = duplicateHeadingTimestampCount,
                                nonMonotonicHeadingTimestampCount = nonMonotonicHeadingTimestampCount,
                                reportedAccuraciesM =
                                    protectedGroundTruthCollector.snapshot().mapNotNull {
                                        it.horizontalAccuracyReportedM
                                    },
                            )
                        }
                    clearPrivateData()
                    value
                }

            if (collected == null) {
                releaseSession(this)
                postError(callback, ERROR_INTERNAL, "Denied estimator state was unavailable.")
                return
            }
            val groundTruthEnu =
                collected.protectedFixes.mapNotNull { fix ->
                    ProtectedWgs84EnuConverter.toHorizontalEnu(anchor, fix)
                }
            val comparison = EvaluationComparator.compare(collected.estimatorSnapshots, groundTruthEnu)
            if (comparison == null || comparison.matchedCount <= 0L) {
                releaseSession(this)
                postError(callback, ERROR_NO_MATCHED_GROUND_TRUTH, "No protected ground-truth fix could be causally matched.")
                return
            }

            val summary = createSummary(collected, comparison)
            releaseSession(this)
            postSuccess(callback, summary)
        }

        private fun createSummary(
            collected: CollectedSession,
            comparison: ComparisonSummary,
        ): Map<String, Any?> {
            val finalState = collected.estimatorSnapshots.last()
            val horizontal = sqrt((finalState.eastM * finalState.eastM) + (finalState.northM * finalState.northM))
            val accuracyStatistics = calculateDoubleStatistics(collected.reportedAccuraciesM)

            return linkedMapOf(
                "schemaVersion" to SCHEMA_VERSION,
                "snapshotKind" to SNAPSHOT_KIND_RESULT,
                "success" to true,
                "evaluationWindowMs" to EVALUATION_WINDOW_MS,
                "protectedGtFirstFixTimeoutMs" to PROTECTED_GT_FIRST_FIX_TIMEOUT_MS,
                "coordinateFrame" to COORDINATE_FRAME,
                "physicalGnssAvailable" to true,
                "physicalGnssRole" to PHYSICAL_GNSS_ROLE,
                "evaluationModeImplemented" to true,
                "groundTruthFirewallImplemented" to true,
                "protectedGroundTruthGnssActive" to true,
                "softwareDefinedEstimatorGnssDenial" to true,
                "protectedGnssAvailableToEstimatorApi" to false,
                "protectedGnssUsedByDeniedEstimator" to false,
                "protectedGnssUsedByHeading" to false,
                "protectedGnssUsedByStepLength" to false,
                "protectedGnssUsedByQualityEngine" to false,
                "protectedGnssUsedByController" to false,
                "gnssCorrectionApplied" to false,
                "firewallMutationSelfTestPassed" to true,
                "liveGnssPhysicallyActive" to true,
                "liveGnssUsedByDeniedEstimator" to false,
                "liveGnssUsedForProtectedGroundTruth" to true,
                "protectedGtUpdateCount" to collected.protectedGtUpdateCount,
                "acceptedProtectedGtFixCount" to collected.acceptedProtectedGtFixCount,
                "invalidProtectedGtFixCount" to collected.invalidProtectedGtFixCount,
                "outOfWindowProtectedGtFixCount" to collected.outOfWindowProtectedGtFixCount,
                "uniqueProtectedGtTimestampCount" to collected.acceptedProtectedGtFixCount,
                "duplicateProtectedGtTimestampCount" to collected.duplicateProtectedGtTimestampCount,
                "nonMonotonicProtectedGtTimestampCount" to collected.nonMonotonicProtectedGtTimestampCount,
                "mockProtectedGtFixCount" to collected.mockProtectedGtFixCount,
                "matchedGroundTruthFixCount" to comparison.matchedCount,
                "unmatchedGroundTruthFixCount" to comparison.unmatchedCount,
                "minReportedGtAccuracyM" to accuracyStatistics?.min,
                "maxReportedGtAccuracyM" to accuracyStatistics?.max,
                "meanReportedGtAccuracyM" to accuracyStatistics?.mean,
                "medianReportedGtAccuracyM" to accuracyStatistics?.median,
                "minHorizontalErrorM" to comparison.errorStatistics.min,
                "maxHorizontalErrorM" to comparison.errorStatistics.max,
                "meanHorizontalErrorM" to comparison.errorStatistics.mean,
                "medianHorizontalErrorM" to comparison.errorStatistics.median,
                "p95HorizontalErrorM" to comparison.errorStatistics.p95,
                "finalDeniedPreCorrectionErrorM" to comparison.finalErrorM,
                "minEstimatorAgeAtGtMs" to comparison.ageStatistics.min,
                "maxEstimatorAgeAtGtMs" to comparison.ageStatistics.max,
                "meanEstimatorAgeAtGtMs" to comparison.ageStatistics.mean,
                "medianEstimatorAgeAtGtMs" to comparison.ageStatistics.median,
                "p95EstimatorAgeAtGtMs" to comparison.ageStatistics.p95,
                "stepUpdateCount" to collected.stepUpdateCount,
                "acceptedStepEventCount" to collected.acceptedStepEventCount,
                "invalidStepEventCount" to collected.invalidStepEventCount,
                "outOfWindowStepEventCount" to collected.outOfWindowStepEventCount,
                "uniqueStepTimestampCount" to collected.acceptedStepEventCount,
                "duplicateStepTimestampCount" to collected.duplicateStepTimestampCount,
                "nonMonotonicStepTimestampCount" to collected.nonMonotonicStepTimestampCount,
                "associatedStepCount" to collected.associatedStepCount,
                "unassociatedStepCount" to collected.unassociatedStepCount,
                "integratedStepCount" to collected.associatedStepCount,
                "headingUpdateCount" to collected.headingUpdateCount,
                "validHeadingSampleCount" to collected.validHeadingSampleCount,
                "invalidHeadingSampleCount" to collected.invalidHeadingSampleCount,
                "uniqueHeadingTimestampCount" to collected.validHeadingSampleCount,
                "duplicateHeadingTimestampCount" to collected.duplicateHeadingTimestampCount,
                "nonMonotonicHeadingTimestampCount" to collected.nonMonotonicHeadingTimestampCount,
                "finalDeniedEastM" to finalState.eastM,
                "finalDeniedNorthM" to finalState.northM,
                "finalDeniedHorizontalDisplacementM" to horizontal,
                "nominalDeniedIntegratedPathLengthM" to
                    collected.associatedStepCount.toDouble() * BASELINE_STEP_LENGTH_METERS,
                "deniedEstimatorProfile" to DENIED_ESTIMATOR_PROFILE,
                "stepSource" to STEP_SOURCE,
                "headingSource" to HEADING_SOURCE,
                "headingConvention" to HEADING_CONVENTION,
                "deviceForwardAxis" to DEVICE_FORWARD_AXIS,
                "stepLengthModel" to STEP_LENGTH_MODEL,
                "stepLengthM" to BASELINE_STEP_LENGTH_METERS,
                "stepLengthCalibrated" to false,
                "stepLengthValidated" to false,
                "headingAssociationPolicy" to HEADING_ASSOCIATION_POLICY,
                "futureHeadingUsed" to false,
                "stepTimestampAuthority" to SENSOR_TIMESTAMP_AUTHORITY,
                "headingTimestampAuthority" to SENSOR_TIMESTAMP_AUTHORITY,
                "protectedGroundTruthTimestampAuthority" to PROTECTED_GT_TIMESTAMP_AUTHORITY,
                "operationWindowClock" to OPERATION_WINDOW_CLOCK,
                "elapsedRealtimeSharedTimeBaseUsed" to true,
                "gnssSensorElapsedRealtimeComparisonUsed" to true,
                "unsupportedCrossClockComparisonUsed" to false,
                "baselinePdrAccuracyValidated" to false,
                "stepDetectionAccuracyValidated" to false,
                "headingAccuracyValidated" to false,
                "trueNorthAccuracyValidated" to false,
                "protectedGnssGroundTruthAccuracyValidated" to false,
                "qualityEngineImplemented" to false,
                "ekfImplemented" to false,
                "pdrArcoreFusionImplemented" to false,
                "gnssRecoveryImplemented" to false,
                "fullGnssDeniedNavigationImplemented" to false,
                "rawGroundTruthTrajectoryReturned" to false,
                "rawDeniedTrajectoryReturned" to false,
                "rawGnssCoordinatesReturned" to false,
                "rawTimestampsReturned" to false,
                "persistenceUsed" to false,
            )
        }

        private fun finishWithError(
            code: String,
            message: String,
        ): Boolean {
            if (!completed.compareAndSet(false, true)) {
                return false
            }
            phase = Phase.COMPLETED
            cleanupRegistrations()
            synchronized(stateLock) { clearPrivateData() }
            releaseSession(this)
            postError(callback, code, message)
            return true
        }

        private fun clearPrivateData() {
            protectedGroundTruthCollector.clear()
            protectedGtTimestamps.clear()
            headingTimestamps.clear()
            stepTimestamps.clear()
            estimator?.clear()
            estimator = null
        }

        private fun cleanupRegistrations() {
            runCatching { handler?.removeCallbacksAndMessages(null) }
            runCatching {
                if (sensorListenersRegistered) {
                    sensorManager.unregisterListener(this)
                    sensorListenersRegistered = false
                }
            }
            runCatching {
                if (locationUpdatesRegistered) {
                    locationManager.removeUpdates(this)
                    locationUpdatesRegistered = false
                }
            }
            handler = null
            runCatching {
                if (handlerThread.isAlive) {
                    handlerThread.quitSafely()
                }
            }
        }
    }

    // This deterministic estimator is contract-locked to the frozen Stage 4
    // Config A behavior. Its API intentionally contains no Location or
    // protected-ground-truth type.
    private class DeniedEstimatorCore(
        private val preDenialDeclinationRad: Double,
        formalWindowStartNanos: Long,
    ) {
        private val initialState = EstimatorSnapshot(formalWindowStartNanos, 0.0, 0.0, 0L)
        private val headingSamples = mutableListOf<HeadingSample>()
        private val acceptedStepTimestamps = mutableListOf<Long>()

        fun acceptHeading(
            timestampNanos: Long,
            trueHeadingRad: Double,
        ) {
            require(timestampNanos > 0L && trueHeadingRad.isFinite() && preDenialDeclinationRad.isFinite())
            headingSamples.add(HeadingSample(timestampNanos, normalizeHeading(trueHeadingRad)))
        }

        fun acceptStep(timestampNanos: Long) {
            require(timestampNanos > 0L)
            acceptedStepTimestamps.add(timestampNanos)
        }

        fun finalizeState(): FinalizedDeniedEstimator {
            val states = mutableListOf(initialState)
            var headingIndex = 0
            var latestHeading: HeadingSample? = null
            var eastM = 0.0
            var northM = 0.0
            var associatedStepCount = 0L
            var unassociatedStepCount = 0L

            for (stepTimestamp in acceptedStepTimestamps) {
                while (
                    headingIndex < headingSamples.size &&
                        headingSamples[headingIndex].timestampNanos <= stepTimestamp
                ) {
                    latestHeading = headingSamples[headingIndex]
                    headingIndex += 1
                }

                val associatedHeading = latestHeading
                if (associatedHeading == null) {
                    unassociatedStepCount += 1L
                    continue
                }

                eastM += BASELINE_STEP_LENGTH_METERS * sin(associatedHeading.trueHeadingRad)
                northM += BASELINE_STEP_LENGTH_METERS * cos(associatedHeading.trueHeadingRad)
                associatedStepCount += 1L
                states.add(EstimatorSnapshot(stepTimestamp, eastM, northM, associatedStepCount))
            }

            return FinalizedDeniedEstimator(
                snapshots = states.toList(),
                associatedStepCount = associatedStepCount,
                unassociatedStepCount = unassociatedStepCount,
            )
        }

        fun clear() {
            headingSamples.clear()
            acceptedStepTimestamps.clear()
        }
    }

    private class ProtectedGroundTruthCollector {
        private val fixes = mutableListOf<ProtectedGroundTruthFix>()

        fun accept(fix: ProtectedGroundTruthFix) {
            fixes.add(fix)
        }

        fun snapshot(): List<ProtectedGroundTruthFix> = fixes.toList()

        fun clear() {
            fixes.clear()
        }
    }

    private object EvaluationComparator {
        fun compare(
            estimatorStates: List<EstimatorSnapshot>,
            groundTruthFixes: List<GroundTruthEnuFix>,
        ): ComparisonSummary? {
            if (estimatorStates.isEmpty() || groundTruthFixes.isEmpty()) {
                return null
            }
            var stateIndex = 0
            var latestState: EstimatorSnapshot? = null
            var unmatched = 0L
            val errors = mutableListOf<Double>()
            val agesMs = mutableListOf<Double>()

            for (groundTruth in groundTruthFixes.sortedBy { it.timestampNanos }) {
                while (
                    stateIndex < estimatorStates.size &&
                    estimatorStates[stateIndex].timestampNanos <= groundTruth.timestampNanos
                ) {
                    latestState = estimatorStates[stateIndex]
                    stateIndex += 1
                }
                val state = latestState
                if (state == null) {
                    unmatched += 1L
                    continue
                }
                val ageNs = groundTruth.timestampNanos - state.timestampNanos
                if (ageNs < 0L) {
                    unmatched += 1L
                    continue
                }
                val errorE = state.eastM - groundTruth.eastM
                val errorN = state.northM - groundTruth.northM
                errors.add(sqrt((errorE * errorE) + (errorN * errorN)))
                agesMs.add(ageNs.toDouble() / NANOS_PER_MILLISECOND)
            }
            if (errors.isEmpty()) {
                return null
            }
            return ComparisonSummary(
                matchedCount = errors.size.toLong(),
                unmatchedCount = unmatched,
                errorStatistics = calculateDoubleStatistics(errors)!!,
                ageStatistics = calculateDoubleStatistics(agesMs)!!,
                finalErrorM = errors.last(),
            )
        }
    }

    private object ProtectedWgs84EnuConverter {
        fun toHorizontalEnu(
            anchor: ProtectedAnchor,
            fix: ProtectedGroundTruthFix,
        ): GroundTruthEnuFix? {
            val anchorAltitude = anchor.altitudeEllipsoidM ?: 0.0
            val fixAltitude = fix.altitudeEllipsoidM ?: anchorAltitude
            val anchorEcef = toEcef(anchor.latitudeDeg, anchor.longitudeDeg, anchorAltitude)
            val fixEcef = toEcef(fix.latitudeDeg, fix.longitudeDeg, fixAltitude)
            val dx = fixEcef[0] - anchorEcef[0]
            val dy = fixEcef[1] - anchorEcef[1]
            val dz = fixEcef[2] - anchorEcef[2]
            val latitude = Math.toRadians(anchor.latitudeDeg)
            val longitude = Math.toRadians(anchor.longitudeDeg)
            val east = (-sin(longitude) * dx) + (cos(longitude) * dy)
            val north =
                (-sin(latitude) * cos(longitude) * dx) -
                    (sin(latitude) * sin(longitude) * dy) +
                    (cos(latitude) * dz)
            if (!east.isFinite() || !north.isFinite()) {
                return null
            }
            return GroundTruthEnuFix(fix.elapsedRealtimeNanos, east, north)
        }

        private fun toEcef(
            latitudeDeg: Double,
            longitudeDeg: Double,
            altitudeM: Double,
        ): DoubleArray {
            val latitude = Math.toRadians(latitudeDeg)
            val longitude = Math.toRadians(longitudeDeg)
            val sinLatitude = sin(latitude)
            val cosLatitude = cos(latitude)
            val primeVerticalRadius = WGS84_SEMI_MAJOR_AXIS_M / sqrt(1.0 - WGS84_ECCENTRICITY_SQUARED * sinLatitude * sinLatitude)
            return doubleArrayOf(
                (primeVerticalRadius + altitudeM) * cosLatitude * cos(longitude),
                (primeVerticalRadius + altitudeM) * cosLatitude * sin(longitude),
                ((primeVerticalRadius * (1.0 - WGS84_ECCENTRICITY_SQUARED)) + altitudeM) * sinLatitude,
            )
        }
    }

    private enum class Phase {
        STARTING,
        WAITING_FOR_FIRST_PROTECTED_FIX,
        FORMAL_EVALUATION,
        COMPLETED,
    }

    private data class ProtectedAnchor(
        val latitudeDeg: Double,
        val longitudeDeg: Double,
        val altitudeEllipsoidM: Double?,
    )

    private data class ProtectedGroundTruthFix(
        val latitudeDeg: Double,
        val longitudeDeg: Double,
        val altitudeEllipsoidM: Double?,
        val horizontalAccuracyReportedM: Double?,
        val elapsedRealtimeNanos: Long,
    )

    private data class GroundTruthEnuFix(
        val timestampNanos: Long,
        val eastM: Double,
        val northM: Double,
    )

    private data class EstimatorSnapshot(
        val timestampNanos: Long,
        val eastM: Double,
        val northM: Double,
        val integratedStepCount: Long,
    )

    private data class HeadingSample(
        val timestampNanos: Long,
        val trueHeadingRad: Double,
    )

    private data class DoubleStatistics(
        val min: Double,
        val max: Double,
        val mean: Double,
        val median: Double,
        val p95: Double,
    )

    private data class ComparisonSummary(
        val matchedCount: Long,
        val unmatchedCount: Long,
        val errorStatistics: DoubleStatistics,
        val ageStatistics: DoubleStatistics,
        val finalErrorM: Double,
    )

    private data class FinalizedDeniedEstimator(
        val snapshots: List<EstimatorSnapshot>,
        val associatedStepCount: Long,
        val unassociatedStepCount: Long,
    )

    private data class CollectedSession(
        val protectedFixes: List<ProtectedGroundTruthFix>,
        val estimatorSnapshots: List<EstimatorSnapshot>,
        val associatedStepCount: Long,
        val unassociatedStepCount: Long,
        val protectedGtUpdateCount: Long,
        val acceptedProtectedGtFixCount: Long,
        val invalidProtectedGtFixCount: Long,
        val outOfWindowProtectedGtFixCount: Long,
        val duplicateProtectedGtTimestampCount: Long,
        val nonMonotonicProtectedGtTimestampCount: Long,
        val mockProtectedGtFixCount: Long,
        val stepUpdateCount: Long,
        val acceptedStepEventCount: Long,
        val invalidStepEventCount: Long,
        val outOfWindowStepEventCount: Long,
        val duplicateStepTimestampCount: Long,
        val nonMonotonicStepTimestampCount: Long,
        val headingUpdateCount: Long,
        val validHeadingSampleCount: Long,
        val invalidHeadingSampleCount: Long,
        val duplicateHeadingTimestampCount: Long,
        val nonMonotonicHeadingTimestampCount: Long,
        val reportedAccuraciesM: List<Double>,
    )

    private companion object {
        const val SCHEMA_VERSION = 1
        const val SNAPSHOT_KIND_PREFLIGHT = "evaluation_mode_preflight"
        const val SNAPSHOT_KIND_RESULT = "evaluation_mode_diagnostic_result"
        const val EVALUATION_WINDOW_MS = 30_000L
        const val PROTECTED_GT_FIRST_FIX_TIMEOUT_MS = 15_000L
        const val NANOS_PER_MILLISECOND_LONG = 1_000_000L
        const val NANOS_PER_MILLISECOND = 1_000_000.0
        const val EVALUATION_WINDOW_NANOS = EVALUATION_WINDOW_MS * NANOS_PER_MILLISECOND_LONG
        const val PROTECTED_GT_MIN_TIME_MS = 0L
        const val PROTECTED_GT_MIN_DISTANCE_M = 0.0f
        const val HEADING_REQUESTED_SAMPLING_PERIOD_US = 20_000
        const val MAX_REPORT_LATENCY_US = 0
        const val REQUIRED_ROTATION_VECTOR_COMPONENT_COUNT = 3
        const val HORIZONTAL_NORM_EPSILON = 1e-6
        const val STEP_EVENT_VALUE = 1.0f
        const val BASELINE_STEP_LENGTH_METERS = 0.75
        const val TWO_PI = 2.0 * PI
        const val HANDLER_THREAD_NAME = "NAVGUARD-EvaluationMode"
        const val COORDINATE_FRAME = "local_enu"
        const val PHYSICAL_GNSS_ROLE = "protected_ground_truth_only"
        const val DENIED_ESTIMATOR_PROFILE = "config_a_baseline_pdr"
        const val STEP_SOURCE = "TYPE_STEP_DETECTOR"
        const val HEADING_SOURCE = "TYPE_ROTATION_VECTOR"
        const val HEADING_CONVENTION = "clockwise_from_north_0_to_2pi"
        const val DEVICE_FORWARD_AXIS = "device_positive_y_top_edge"
        const val STEP_LENGTH_MODEL = "fixed_baseline"
        const val HEADING_ASSOCIATION_POLICY = "latest_valid_heading_at_or_before_step_timestamp"
        const val SENSOR_TIMESTAMP_AUTHORITY = "SensorEvent.timestamp"
        const val PROTECTED_GT_TIMESTAMP_AUTHORITY = "Location.getElapsedRealtimeNanos"
        const val OPERATION_WINDOW_CLOCK = "SystemClock.elapsedRealtimeNanos"
        const val WGS84_SEMI_MAJOR_AXIS_M = 6_378_137.0
        const val WGS84_FLATTENING = 1.0 / 298.257223563
        const val WGS84_ECCENTRICITY_SQUARED = WGS84_FLATTENING * (2.0 - WGS84_FLATTENING)

        const val ERROR_GPS_UNAVAILABLE = "evaluation_gps_unavailable"
        const val ERROR_GPS_DISABLED = "evaluation_gps_disabled"
        const val ERROR_LOCATION_PERMISSION_REQUIRED = "evaluation_location_permission_required"
        const val ERROR_ROTATION_VECTOR_UNAVAILABLE = "evaluation_rotation_vector_unavailable"
        const val ERROR_STEP_DETECTOR_UNAVAILABLE = "evaluation_step_detector_unavailable"
        const val ERROR_ACTIVITY_PERMISSION_REQUIRED = "activity_recognition_permission_required"
        const val ERROR_ANCHOR_REQUIRED = "evaluation_anchor_required"
        const val ERROR_ALREADY_RUNNING = "evaluation_already_running"
        const val ERROR_FIREWALL_SELF_TEST = "ground_truth_firewall_self_test_failed"
        const val ERROR_FIRST_FIX_TIMEOUT = "evaluation_protected_gt_first_fix_timeout"
        const val ERROR_SENSOR_REGISTRATION_FAILED = "evaluation_sensor_registration_failed"
        const val ERROR_NO_MATCHED_GROUND_TRUTH = "evaluation_no_matched_ground_truth"
        const val ERROR_CANCELLED = "evaluation_cancelled"
        const val ERROR_INTERNAL = "internal_evaluation_error"

        fun isValidAnchor(
            latitudeDeg: Double,
            longitudeDeg: Double,
            altitudeM: Double?,
        ): Boolean =
            latitudeDeg.isFinite() &&
                latitudeDeg in -90.0..90.0 &&
                longitudeDeg.isFinite() &&
                longitudeDeg in -180.0..180.0 &&
                altitudeM?.isFinite() != false

        fun normalizeHeading(angle: Double): Double {
            var normalized = angle % TWO_PI
            if (normalized < 0.0) {
                normalized += TWO_PI
            }
            return if (normalized >= TWO_PI) 0.0 else normalized
        }

        fun calculateDoubleStatistics(values: List<Double>): DoubleStatistics? {
            if (values.isEmpty() || values.any { !it.isFinite() || it < 0.0 }) {
                return null
            }
            val sorted = values.sorted()
            val middle = sorted.size / 2
            val median =
                if (sorted.size % 2 == 0) {
                    (sorted[middle - 1] + sorted[middle]) / 2.0
                } else {
                    sorted[middle]
                }
            val p95Index = (ceil(sorted.size * 0.95).toInt() - 1).coerceIn(0, sorted.lastIndex)
            return DoubleStatistics(sorted.first(), sorted.last(), sorted.average(), median, sorted[p95Index])
        }

        fun runFirewallMutationSelfTest(): Boolean =
            runCatching {
                fun runEstimator(): List<EstimatorSnapshot> {
                    val estimator = DeniedEstimatorCore(0.0, 1_000_000_000L)
                    estimator.acceptHeading(1_100_000_000L, 0.0)
                    estimator.acceptStep(1_200_000_000L)
                    estimator.acceptHeading(1_300_000_000L, PI / 2.0)
                    estimator.acceptStep(1_400_000_000L)
                    return estimator.finalizeState().snapshots
                }

                val statesA = runEstimator()
                val statesB = runEstimator()
                if (statesA != statesB) {
                    return@runCatching false
                }
                val groundTruthA =
                    listOf(
                        GroundTruthEnuFix(1_250_000_000L, 0.0, 0.0),
                        GroundTruthEnuFix(1_450_000_000L, 0.0, 0.0),
                    )
                val groundTruthB =
                    listOf(
                        GroundTruthEnuFix(1_250_000_000L, 100.0, -100.0),
                        GroundTruthEnuFix(1_450_000_000L, -200.0, 200.0),
                    )
                val resultA = EvaluationComparator.compare(statesA, groundTruthA)
                val resultB = EvaluationComparator.compare(statesB, groundTruthB)
                resultA != null && resultB != null && resultA.errorStatistics != resultB.errorStatistics
            }.getOrDefault(false)
    }
}
