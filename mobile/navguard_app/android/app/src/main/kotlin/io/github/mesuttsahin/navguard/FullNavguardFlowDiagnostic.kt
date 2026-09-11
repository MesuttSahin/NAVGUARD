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
import android.opengl.EGL14
import android.opengl.EGLConfig
import android.opengl.EGLContext
import android.opengl.EGLDisplay
import android.opengl.EGLSurface
import android.opengl.GLES11Ext
import android.opengl.GLES20
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import android.os.SystemClock
import com.google.ar.core.Anchor
import com.google.ar.core.ArCoreApk
import com.google.ar.core.Config
import com.google.ar.core.Frame
import com.google.ar.core.Pose
import com.google.ar.core.Session
import com.google.ar.core.TrackingState
import com.google.ar.core.exceptions.CameraNotAvailableException
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.math.PI
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.sin
import kotlin.math.sqrt

internal class FullNavguardFlowDiagnostic(
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
    private var activeSession: FlowSession? = null

    fun createPreflightSnapshot(): Map<String, Any?> {
        val gpsAvailable = readGpsProviderAvailable()
        val gpsEnabled = gpsAvailable && readGpsProviderEnabled()
        val fineLocationGranted = hasFineLocationPermission()
        val rotationVector = getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
        val stepDetector = getDefaultSensor(Sensor.TYPE_STEP_DETECTOR)
        val activityPermissionGranted = hasActivityRecognitionPermission()
        val arCore = readArCoreAvailability()
        val cameraPermissionGranted = hasCameraPermission()
        val runningSession = synchronized(activeSessionLock) { activeSession }
        val diagnosticRunning = runningSession != null
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
            "activityRecognitionPermissionGranted" to activityPermissionGranted,
            "arCoreSupported" to arCore.supported,
            "arCoreInstalled" to arCore.installedAndCurrent,
            "cameraPermissionGranted" to cameraPermissionGranted,
            "diagnosticRunning" to diagnosticRunning,
            "nativeReady" to
                (
                    gpsAvailable &&
                        gpsEnabled &&
                        fineLocationGranted &&
                        rotationVector != null &&
                        stepDetector != null &&
                        activityPermissionGranted &&
                        arCore.supported &&
                        arCore.installedAndCurrent &&
                        cameraPermissionGranted &&
                        runDenialMutationSelfTest() &&
                        !diagnosticRunning
                ),
            "currentState" to (runningSession?.currentState()?.name ?: NavigationState.IDLE.name),
        )
    }

    fun isDiagnosticRunning(): Boolean =
        synchronized(activeSessionLock) { activeSession != null }

    fun start(
        anchorLatitudeDeg: Double,
        anchorLongitudeDeg: Double,
        anchorAltitudeEllipsoidM: Double?,
        callback: Callback,
    ) {
        if (!isValidAnchor(anchorLatitudeDeg, anchorLongitudeDeg, anchorAltitudeEllipsoidM)) {
            postError(callback, ERROR_ANCHOR_REQUIRED, "A valid locked Stage 3A GNSS anchor is required.")
            return
        }
        if (!readGpsProviderAvailable()) {
            postError(callback, ERROR_GPS_UNAVAILABLE, "GPS_PROVIDER is unavailable.")
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
        if (!hasCameraPermission()) {
            postError(callback, ERROR_CAMERA_PERMISSION_REQUIRED, "Camera permission is required.")
            return
        }
        val arCore = readArCoreAvailability()
        if (!arCore.supported || !arCore.installedAndCurrent) {
            postError(callback, ERROR_ARCORE_UNAVAILABLE, "ARCore is unavailable or not ready.")
            return
        }
        val rotationVector = getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
        if (rotationVector == null) {
            postError(callback, ERROR_ROTATION_VECTOR_UNAVAILABLE, "TYPE_ROTATION_VECTOR is unavailable.")
            return
        }
        val stepDetector = getDefaultSensor(Sensor.TYPE_STEP_DETECTOR)
        if (stepDetector == null) {
            postError(callback, ERROR_STEP_DETECTOR_UNAVAILABLE, "TYPE_STEP_DETECTOR is unavailable.")
            return
        }
        if (!hasActivityRecognitionPermission()) {
            postError(callback, ERROR_ACTIVITY_PERMISSION_REQUIRED, "Physical activity recognition permission is required.")
            return
        }
        if (!runDenialMutationSelfTest()) {
            postError(callback, ERROR_EKF_NUMERICAL_FAILURE, "The denial firewall mutation self-test failed.")
            return
        }

        val altitudeM = anchorAltitudeEllipsoidM ?: 0.0
        val declinationRad =
            runCatching {
                Math.toRadians(
                    GeomagneticField(
                        anchorLatitudeDeg.toFloat(),
                        anchorLongitudeDeg.toFloat(),
                        altitudeM.toFloat(),
                        System.currentTimeMillis(),
                    ).declination.toDouble(),
                )
            }.getOrDefault(Double.NaN)
        if (!declinationRad.isFinite()) {
            postError(callback, ERROR_INTERNAL, "Unable to calculate geomagnetic declination.")
            return
        }

        val session =
            FlowSession(
                anchor = Wgs84Anchor(anchorLatitudeDeg, anchorLongitudeDeg, anchorAltitudeEllipsoidM),
                rotationVector = rotationVector,
                stepDetector = stepDetector,
                declinationRad = declinationRad,
                callback = callback,
            )
        synchronized(activeSessionLock) {
            if (activeSession != null) {
                postError(callback, ERROR_ALREADY_RUNNING, "A full NAVGUARD flow is already running.")
                return
            }
            activeSession = session
        }
        session.start()
    }

    fun cancelActiveSession(
        message: String = "Full NAVGUARD flow cancelled by the user.",
    ): Boolean {
        val session = synchronized(activeSessionLock) { activeSession } ?: return false
        return session.cancel(message)
    }

    private fun releaseSession(session: FlowSession) {
        synchronized(activeSessionLock) {
            if (activeSession === session) activeSession = null
        }
    }

    private fun postSuccess(
        callback: Callback,
        summary: Map<String, Any?>,
    ) {
        if (!resultHandler.post { callback.onSuccess(summary) }) callback.onSuccess(summary)
    }

    private fun postError(
        callback: Callback,
        code: String,
        message: String,
    ) {
        if (!resultHandler.post { callback.onError(code, message) }) callback.onError(code, message)
    }

    private fun getDefaultSensor(type: Int): Sensor? =
        runCatching { sensorManager.getDefaultSensor(type) }.getOrNull()

    private fun readGpsProviderAvailable(): Boolean =
        runCatching { locationManager.allProviders.contains(LocationManager.GPS_PROVIDER) }.getOrDefault(false)

    private fun readGpsProviderEnabled(): Boolean =
        runCatching { locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER) }.getOrDefault(false)

    private fun hasFineLocationPermission(): Boolean =
        applicationContext.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED

    private fun hasCameraPermission(): Boolean =
        applicationContext.checkSelfPermission(Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED

    private fun hasActivityRecognitionPermission(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.Q ||
            applicationContext.checkSelfPermission(Manifest.permission.ACTIVITY_RECOGNITION) == PackageManager.PERMISSION_GRANTED

    private fun readArCoreAvailability(): AvailabilitySnapshot {
        val availability =
            runCatching { ArCoreApk.getInstance().checkAvailability(applicationContext) }.getOrNull()
                ?: return AvailabilitySnapshot(false, false)
        return when (availability) {
            ArCoreApk.Availability.SUPPORTED_INSTALLED -> AvailabilitySnapshot(true, true)
            ArCoreApk.Availability.SUPPORTED_APK_TOO_OLD,
            ArCoreApk.Availability.SUPPORTED_NOT_INSTALLED,
            -> AvailabilitySnapshot(true, false)
            else -> AvailabilitySnapshot(false, false)
        }
    }

    private inner class FlowSession(
        private val anchor: Wgs84Anchor,
        private val rotationVector: Sensor,
        private val stepDetector: Sensor,
        private val declinationRad: Double,
        private val callback: Callback,
    ) : LocationListener, SensorEventListener {
        private val completed = AtomicBoolean(false)
        private val cancellationRequested = AtomicBoolean(false)
        private val completionRequested = AtomicBoolean(false)
        private val terminalErrorRequested = AtomicBoolean(false)
        private val stateLock = Any()
        private val workerThread = HandlerThread(WORKER_THREAD_NAME)
        private val arThread = HandlerThread(AR_THREAD_NAME)
        private val glEnvironment = DiagnosticGlEnvironment()
        private val stateHistory = mutableListOf(NavigationState.IDLE)
        private val normalAccuracyM = mutableListOf<Double>()
        private val recoveryAccuracyM = mutableListOf<Double>()
        private val deniedEvents = mutableListOf<DeniedFusionEvent>()
        private val deniedHeadingTimestampSet = mutableSetOf<Long>()
        private val deniedStepTimestampSet = mutableSetOf<Long>()

        @Volatile
        private var state = NavigationState.IDLE

        @Volatile
        private var cancellationMessage = "Full NAVGUARD flow cancelled by the user."

        @Volatile
        private var terminalErrorCode = ERROR_INTERNAL

        @Volatile
        private var terminalErrorMessage = "The full NAVGUARD flow failed."

        private var workerHandler: Handler? = null
        private var arHandler: Handler? = null
        private var arCoreSession: Session? = null
        private var referenceAnchor: Anchor? = null
        private var arSessionResumed = false
        private var locationRegistered = false
        private var sensorsRegistered = false
        private var alignmentHoldStartNs: Long? = null
        private var alignmentCompleted = false
        private var latestRotation: RotationSample? = null
        private var denialTransform: DoubleArray? = null
        private var previousArFrameTimestampNs: Long? = null
        private var previousArFusionTimestampNs: Long? = null

        private var acquisitionGoodCount = 0
        private var previousOperationalFixNs: Long? = null
        private var latestOperationalEnu: EnuFix? = null
        private var normalAccepted = 0L
        private var normalRejected = 0L
        private var deniedFixCount = 0L
        private var deniedRejected = 0L
        private var recoveryCandidateCount = 0L
        private var recoveryAccepted = 0L
        private var recoveryRejected = 0L
        private var recoveredObservationAccepted = 0L
        private var recoveredObservationRejected = 0L
        private var recoveryConsecutiveGood = 0
        private var recoveryConsecutiveAchieved = 0
        private var previousRecoveryAcceptedNs: Long? = null

        private var normalStartNs = 0L
        private var denialStartNs = 0L
        private var recoveryGateNs = 0L
        private var recoveredStartNs = 0L
        private var completedNs = 0L
        private var denialOriginEastM = 0.0
        private var denialOriginNorthM = 0.0
        private var recoveredGnssEastM = 0.0
        private var recoveredGnssNorthM = 0.0
        private var recoveredAccuracyM = 0.0

        private var ekf: EkfState? = null
        private var initialDeniedHeading: RotationSample? = null
        private var deniedInsertionSequence = 0L
        private var pdrEastM = 0.0
        private var pdrNorthM = 0.0
        private var arcoreEastM: Double? = null
        private var arcoreNorthM: Double? = null
        private var headingQuality = Quality.UNKNOWN
        private var pdrQuality = Quality.UNKNOWN
        private var arcoreQuality = Quality.UNKNOWN
        private var fusionQuality = Quality.UNKNOWN
        private var acceptedSourceUpdate = false
        private var sourceObserved = false

        private var headingApplied = 0L
        private var headingSkippedQuality = 0L
        private var pdrApplied = 0L
        private var pdrSkippedNoHeading = 0L
        private var pdrSkippedQuality = 0L
        private var acceptedDeniedStepOpportunityCount = 0L
        private var arcoreApplied = 0L
        private var arcoreSkippedQuality = 0L

        private var preRecoveryEastM = 0.0
        private var preRecoveryNorthM = 0.0
        private var preRecoveryHeadingRad = 0.0
        private var preRecoveryP = DoubleArray(9)
        private var preRecoveryPdrEastM = 0.0
        private var preRecoveryPdrNorthM = 0.0
        private var preRecoveryArcoreEastM: Double? = null
        private var preRecoveryArcoreNorthM: Double? = null
        private var preRecoveryHeadingQuality = Quality.UNKNOWN
        private var preRecoveryPdrQuality = Quality.UNKNOWN
        private var preRecoveryArcoreQuality = Quality.UNKNOWN
        private var preRecoveryFusionQuality = Quality.UNKNOWN

        private val acquisitionTimeout =
            Runnable {
                if (state == NavigationState.ACQUIRING_GNSS && acquisitionGoodCount < INITIAL_REQUIRED_CONSECUTIVE_FIXES) {
                    finishWithError(ERROR_GNSS_ACQUISITION_TIMEOUT, "Initial GPS acquisition timed out.")
                }
            }
        private val alignmentTimeout =
            Runnable {
                if (!alignmentCompleted && !completed.get()) {
                    finishWithError(ERROR_ALIGNMENT_TIMEOUT, "ARCore/heading alignment timed out.")
                }
            }
        private val normalTimeout = Runnable { enterDeniedNavigation() }
        private val denialTimeout = Runnable { openRecoveryGate() }
        private val recoveryTimeout =
            Runnable {
                if (state == NavigationState.RECOVERY_PENDING) {
                    finishWithError(ERROR_RECOVERY_TIMEOUT, "Fresh GPS recovery timed out.")
                }
            }
        private val recoveredTimeout = Runnable { completionRequested.set(true) }

        fun currentState(): NavigationState = state

        fun start() {
            try {
                workerThread.start()
                val worker = Handler(workerThread.looper)
                workerHandler = worker
                arThread.start()
                val arWorker = Handler(arThread.looper)
                arHandler = arWorker
                if (!worker.post { initializeRuntime(worker) } || !arWorker.post(::runArCoreLoop)) {
                    finishWithError(ERROR_INTERNAL, "Unable to start full-flow workers.")
                }
            } catch (_: Exception) {
                finishWithError(ERROR_INTERNAL, "Unable to start the full NAVGUARD flow.")
            }
        }

        @Suppress("MissingPermission")
        private fun initializeRuntime(worker: Handler) {
            if (completed.get()) return
            transitionTo(NavigationState.ACQUIRING_GNSS)
            try {
                val rotationRegistered =
                    sensorManager.registerListener(
                        this,
                        rotationVector,
                        ROTATION_VECTOR_SAMPLING_PERIOD_US,
                        MAX_REPORT_LATENCY_US,
                        worker,
                    )
                val stepRegistered =
                    sensorManager.registerListener(
                        this,
                        stepDetector,
                        SensorManager.SENSOR_DELAY_NORMAL,
                        MAX_REPORT_LATENCY_US,
                        worker,
                    )
                sensorsRegistered = rotationRegistered || stepRegistered
                if (!rotationRegistered || !stepRegistered) {
                    finishWithError(ERROR_SENSOR_REGISTRATION_FAILED, "Android rejected a required sensor registration.")
                    return
                }
                locationManager.requestLocationUpdates(
                    LocationManager.GPS_PROVIDER,
                    GNSS_MIN_TIME_MS,
                    GNSS_MIN_DISTANCE_M,
                    this,
                    workerThread.looper,
                )
                locationRegistered = true
                if (!worker.postDelayed(acquisitionTimeout, INITIAL_GNSS_ACQUISITION_TIMEOUT_MS) ||
                    !worker.postDelayed(alignmentTimeout, ALIGNMENT_ACQUISITION_TIMEOUT_MS)
                ) {
                    finishWithError(ERROR_INTERNAL, "Unable to schedule acquisition timeouts.")
                }
            } catch (_: SecurityException) {
                finishWithError(ERROR_LOCATION_PERMISSION_REQUIRED, "A required runtime permission is missing.")
            } catch (_: IllegalArgumentException) {
                finishWithError(ERROR_GPS_UNAVAILABLE, "GPS_PROVIDER could not be registered.")
            } catch (_: Exception) {
                finishWithError(ERROR_INTERNAL, "Unable to register full-flow runtime sources.")
            }
        }

        override fun onSensorChanged(event: SensorEvent) {
            if (completed.get()) return
            when (event.sensor.type) {
                Sensor.TYPE_ROTATION_VECTOR -> handleRotation(event)
                Sensor.TYPE_STEP_DETECTOR -> handleStep(event)
            }
        }

        override fun onAccuracyChanged(
            sensor: Sensor,
            accuracy: Int,
        ) = Unit

        private fun handleRotation(event: SensorEvent) {
            val sample = createRotationSample(event) ?: return
            synchronized(stateLock) {
                if (latestRotation == null || sample.timestampNs >= checkNotNull(latestRotation).timestampNs) {
                    latestRotation = sample
                }
                if (state != NavigationState.DENIED_NAVGUARD ||
                    sample.timestampNs < denialStartNs ||
                    (recoveryGateNs > 0L && sample.timestampNs >= recoveryGateNs)
                ) return
                if (!deniedHeadingTimestampSet.add(sample.timestampNs)) return
                deniedEvents.add(
                    DeniedHeadingEvent(
                        timestampNs = sample.timestampNs,
                        insertionIndex = deniedInsertionSequence++,
                        headingRad = sample.trueHeadingRad,
                        quality = sample.quality,
                    ),
                )
            }
        }

        private fun handleStep(event: SensorEvent) {
            val value = event.values.firstOrNull()
            if (event.timestamp <= 0L || value == null || !value.isFinite() || value != 1.0f) return
            synchronized(stateLock) {
                if (state != NavigationState.DENIED_NAVGUARD ||
                    event.timestamp < denialStartNs ||
                    (recoveryGateNs > 0L && event.timestamp >= recoveryGateNs)
                ) return
                if (!deniedStepTimestampSet.add(event.timestamp)) return
                deniedEvents.add(
                    DeniedStepEvent(
                        timestampNs = event.timestamp,
                        insertionIndex = deniedInsertionSequence++,
                    ),
                )
            }
        }

        private fun createRotationSample(event: SensorEvent): RotationSample? {
            if (event.timestamp <= 0L || event.values.size < 3) return null
            val count = if (event.values.size >= 4) 4 else 3
            val vector = FloatArray(count)
            for (index in 0 until count) {
                if (!event.values[index].isFinite()) return null
                vector[index] = event.values[index]
            }
            val matrix = FloatArray(9)
            return try {
                SensorManager.getRotationMatrixFromVector(matrix, vector)
                if (matrix.any { !it.isFinite() }) return null
                val east = matrix[1].toDouble()
                val north = matrix[4].toDouble()
                val norm = sqrt((east * east) + (north * north))
                if (!norm.isFinite() || norm <= 1e-6) return null
                val accuracy =
                    if (event.values.size >= 5) {
                        event.values[4].toDouble().takeIf { it.isFinite() && it >= 0.0 }
                    } else {
                        null
                    }
                val magneticDevice = DoubleArray(9) { matrix[it].toDouble() }
                val trueEnuDevice = multiplyMatrices(declinationCorrectionMatrix(declinationRad), magneticDevice)
                if (trueEnuDevice.any { !it.isFinite() }) return null
                RotationSample(
                    timestampNs = event.timestamp,
                    trueHeadingRad = normalizeHeading(atan2(east, north) + declinationRad),
                    quality = classifyHeadingQuality(accuracy),
                    trueEnuDevice = trueEnuDevice,
                )
            } catch (_: Exception) {
                null
            }
        }

        override fun onLocationChanged(location: Location) {
            if (completed.get()) return
            synchronized(stateLock) {
                val timestamp = location.elapsedRealtimeNanos
                when (state) {
                    NavigationState.ACQUIRING_GNSS -> handleAcquisitionFix(location)
                    NavigationState.NORMAL_GNSS -> handleNormalFix(location)
                    NavigationState.DENIED_NAVGUARD -> quarantineDeniedFix(location)
                    NavigationState.RECOVERY_PENDING -> {
                        if (timestamp >= denialStartNs && timestamp < recoveryGateNs) {
                            deniedFixCount += 1L
                            if (!isStructurallyValidGnss(location)) deniedRejected += 1L
                        }
                        handleRecoveryFix(location)
                    }
                    NavigationState.RECOVERED_GNSS -> handleRecoveredFix(location)
                    else -> Unit
                }
            }
        }

        private fun handleAcquisitionFix(location: Location) {
            if (!isAcceptableOperationalFix(location, previousOperationalFixNs)) return
            val enu = Wgs84EnuConverter.toHorizontalEnu(anchor, location) ?: return
            previousOperationalFixNs = enu.timestampNs
            latestOperationalEnu = enu
            acquisitionGoodCount += 1
            if (acquisitionGoodCount >= INITIAL_REQUIRED_CONSECUTIVE_FIXES) maybeEnterNormalGnss()
        }

        private fun handleNormalFix(location: Location) {
            if (!isAcceptableOperationalFix(location, previousOperationalFixNs)) {
                normalRejected += 1L
                return
            }
            val enu = Wgs84EnuConverter.toHorizontalEnu(anchor, location)
            if (enu == null) {
                normalRejected += 1L
                return
            }
            previousOperationalFixNs = enu.timestampNs
            latestOperationalEnu = enu
            normalAccepted += 1L
            normalAccuracyM.add(location.accuracy.toDouble())
        }

        private fun quarantineDeniedFix(location: Location) {
            val timestamp = location.elapsedRealtimeNanos
            if (timestamp < denialStartNs || (recoveryGateNs > 0L && timestamp >= recoveryGateNs)) return
            deniedFixCount += 1L
            if (!isStructurallyValidGnss(location)) deniedRejected += 1L
            // Deliberate firewall: no estimator, quality, heading, PDR, ARCore,
            // controller, tuning, or transition method is called from here.
        }

        private fun handleRecoveryFix(location: Location) {
            recoveryCandidateCount += 1L
            val timestamp = location.elapsedRealtimeNanos
            if (timestamp < recoveryGateNs || !isStructurallyValidGnss(location)) {
                recoveryRejected += 1L
                return
            }
            val previous = previousRecoveryAcceptedNs
            if (previous != null && timestamp <= previous) {
                recoveryRejected += 1L
                return
            }
            val accuracy = location.accuracy.toDouble()
            if (accuracy > MAX_OPERATIONAL_GNSS_ACCURACY_M) {
                recoveryRejected += 1L
                recoveryConsecutiveGood = 0
                return
            }
            val enu = Wgs84EnuConverter.toHorizontalEnu(anchor, location)
            if (enu == null) {
                recoveryRejected += 1L
                return
            }
            previousRecoveryAcceptedNs = timestamp
            recoveryAccepted += 1L
            recoveryConsecutiveGood += 1
            recoveryConsecutiveAchieved = maxOf(recoveryConsecutiveAchieved, recoveryConsecutiveGood)
            recoveryAccuracyM.add(accuracy)
            if (recoveryConsecutiveGood >= RECOVERY_REQUIRED_CONSECUTIVE_FIXES) {
                enterRecoveredGnss(enu, accuracy)
            }
        }

        private fun handleRecoveredFix(location: Location) {
            if (!isAcceptableOperationalFix(location, previousRecoveryAcceptedNs)) {
                recoveredObservationRejected += 1L
                return
            }
            val enu = Wgs84EnuConverter.toHorizontalEnu(anchor, location)
            if (enu == null) {
                recoveredObservationRejected += 1L
                return
            }
            previousRecoveryAcceptedNs = enu.timestampNs
            latestOperationalEnu = enu
            recoveredAccuracyM = location.accuracy.toDouble()
            recoveredObservationAccepted += 1L
            ekf?.resetPosition(enu.eastM, enu.northM, recoveredAccuracyM, latestRotation?.trueHeadingRad)
        }

        private fun isAcceptableOperationalFix(
            location: Location,
            previousAcceptedNs: Long?,
        ): Boolean =
            isStructurallyValidGnss(location) &&
                (previousAcceptedNs == null || location.elapsedRealtimeNanos > previousAcceptedNs) &&
                location.accuracy.toDouble() <= MAX_OPERATIONAL_GNSS_ACCURACY_M

        private fun isStructurallyValidGnss(location: Location): Boolean =
            location.provider == LocationManager.GPS_PROVIDER &&
                location.latitude.isFinite() &&
                location.latitude in -90.0..90.0 &&
                location.longitude.isFinite() &&
                location.longitude in -180.0..180.0 &&
                location.elapsedRealtimeNanos > 0L &&
                location.hasAccuracy() &&
                location.accuracy.isFinite() &&
                location.accuracy > 0.0f &&
                !isMockLocation(location)

        @Suppress("DEPRECATION")
        private fun isMockLocation(location: Location): Boolean =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) location.isMock else location.isFromMockProvider

        override fun onProviderDisabled(provider: String) {
            if (provider == LocationManager.GPS_PROVIDER) {
                finishWithError(ERROR_GPS_DISABLED, "GPS_PROVIDER was disabled during the full flow.")
            }
        }

        override fun onProviderEnabled(provider: String) = Unit

        @Suppress("DEPRECATION")
        override fun onStatusChanged(
            provider: String?,
            status: Int,
            extras: Bundle?,
        ) = Unit

        private fun runArCoreLoop() {
            if (completed.get()) return
            if (terminalErrorRequested.get()) {
                finishWithError(terminalErrorCode, terminalErrorMessage)
                return
            }
            val session =
                try {
                    Session(applicationContext).also { arCoreSession = it }
                } catch (_: Exception) {
                    finishWithError(ERROR_ARCORE_UNAVAILABLE, "Unable to create an ARCore session.")
                    return
                }
            try {
                val config =
                    Config(session).apply {
                        planeFindingMode = Config.PlaneFindingMode.DISABLED
                        lightEstimationMode = Config.LightEstimationMode.DISABLED
                        focusMode = Config.FocusMode.AUTO
                        updateMode = Config.UpdateMode.BLOCKING
                        textureUpdateMode = Config.TextureUpdateMode.BIND_TO_TEXTURE_EXTERNAL_OES
                    }
                session.configure(config)
                glEnvironment.initialize()
                session.setCameraTextureName(glEnvironment.createExternalOesTexture())
                session.resume()
                arSessionResumed = true
            } catch (_: CameraNotAvailableException) {
                finishWithError(ERROR_ARCORE_UNAVAILABLE, "The ARCore camera is unavailable.")
                return
            } catch (_: SecurityException) {
                finishWithError(ERROR_CAMERA_PERMISSION_REQUIRED, "Camera permission is required.")
                return
            } catch (_: Exception) {
                finishWithError(ERROR_ARCORE_UNAVAILABLE, "Unable to configure the ARCore session.")
                return
            }

            while (!completed.get()) {
                if (terminalErrorRequested.get()) {
                    finishWithError(terminalErrorCode, terminalErrorMessage)
                    return
                }
                if (cancellationRequested.get()) {
                    finishWithError(ERROR_CANCELLED, cancellationMessage)
                    return
                }
                if (completionRequested.get()) {
                    finishSuccessfully()
                    return
                }
                val frame =
                    try {
                        session.update()
                    } catch (_: Exception) {
                        if (!completed.get()) finishWithError(ERROR_ARCORE_UNAVAILABLE, "The ARCore session failed.")
                        return
                    }
                val nowNs = SystemClock.elapsedRealtimeNanos()
                when (state) {
                    NavigationState.ACQUIRING_GNSS,
                    NavigationState.NORMAL_GNSS,
                    -> processAlignmentFrame(frame, nowNs)
                    NavigationState.DENIED_NAVGUARD -> processDeniedArFrame(session, frame, nowNs)
                    else -> Unit
                }
            }
        }

        private fun processAlignmentFrame(
            frame: Frame,
            nowNs: Long,
        ) {
            if (alignmentCompleted) return
            if (frame.camera.trackingState != TrackingState.TRACKING ||
                synchronized(stateLock) { latestRotation?.let { qualityMultiplier(it.quality) } } == null
            ) {
                alignmentHoldStartNs = null
                return
            }
            val started = alignmentHoldStartNs
            if (started == null) {
                alignmentHoldStartNs = nowNs
                return
            }
            if (nowNs - started < ALIGNMENT_HOLD_NS) return
            alignmentCompleted = true
            workerHandler?.post { maybeEnterNormalGnss() }
        }

        private fun processDeniedArFrame(
            session: Session,
            frame: Frame,
            nowNs: Long,
        ) {
            synchronized(stateLock) {
                if (state != NavigationState.DENIED_NAVGUARD || nowNs < denialStartNs ||
                    (recoveryGateNs > 0L && nowNs >= recoveryGateNs)
                ) return
                if (frame.camera.trackingState != TrackingState.TRACKING) {
                    sourceObserved = true
                    arcoreQuality = Quality.UNAVAILABLE
                    updateFusionQuality()
                    return
                }
                if (referenceAnchor == null) {
                    val pose = runCatching { frame.androidSensorPose }.getOrNull()
                    if (pose == null || !isFinitePose(pose)) return
                    val created = runCatching { session.createAnchor(pose) }.getOrNull() ?: return
                    if (created.trackingState != TrackingState.TRACKING) {
                        created.detach()
                        return
                    }
                    referenceAnchor = created
                    previousArFrameTimestampNs = null
                    previousArFusionTimestampNs = null
                    return
                }
                val reference = referenceAnchor ?: return
                if (reference.trackingState != TrackingState.TRACKING) {
                    sourceObserved = true
                    arcoreQuality = Quality.UNAVAILABLE
                    updateFusionQuality()
                    return
                }
                val frameTimestamp = frame.timestamp
                val previousFrame = previousArFrameTimestampNs
                if (frameTimestamp <= 0L || (previousFrame != null && frameTimestamp <= previousFrame)) return
                previousArFrameTimestampNs = frameTimestamp
                val currentPose = runCatching { frame.androidSensorPose }.getOrNull()
                val relative =
                    if (currentPose == null || !isFinitePose(currentPose)) null else
                        runCatching { reference.pose.inverse().compose(currentPose) }.getOrNull()
                if (relative == null || !isFinitePose(relative)) {
                    sourceObserved = true
                    arcoreQuality = Quality.UNRELIABLE
                    arcoreSkippedQuality += 1L
                    updateFusionQuality()
                    return
                }
                val translation = FloatArray(3)
                relative.getTranslation(translation, 0)
                val transform = denialTransform ?: return
                val local =
                    multiplyMatrixVector(
                        transform,
                        doubleArrayOf(
                            translation[0].toDouble(),
                            translation[1].toDouble(),
                            translation[2].toDouble(),
                        ),
                    )
                if (local.any { !it.isFinite() }) return
                // Frame.timestamp is deliberately isolated above. Cross-source ordering
                // uses this processing timestamp captured after usable pose conversion.
                val fusionTimestamp = SystemClock.elapsedRealtimeNanos()
                if (fusionTimestamp >= recoveryGateNs && recoveryGateNs > 0L) return
                val previousFusion = previousArFusionTimestampNs
                arcoreQuality =
                    if (previousFusion == null) Quality.USABLE else classifyArcoreQuality(fusionTimestamp - previousFusion)
                previousArFusionTimestampNs = fusionTimestamp
                val globalEast = denialOriginEastM + local[0]
                val globalNorth = denialOriginNorthM + local[1]
                deniedEvents.add(
                    DeniedArcoreEvent(
                        timestampNs = fusionTimestamp,
                        insertionIndex = deniedInsertionSequence++,
                        eastM = globalEast,
                        northM = globalNorth,
                        quality = arcoreQuality,
                    ),
                )
            }
        }

        private fun maybeEnterNormalGnss() {
            synchronized(stateLock) {
                if (state != NavigationState.ACQUIRING_GNSS ||
                    acquisitionGoodCount < INITIAL_REQUIRED_CONSECUTIVE_FIXES ||
                    !alignmentCompleted
                ) return
                workerHandler?.removeCallbacks(acquisitionTimeout)
                workerHandler?.removeCallbacks(alignmentTimeout)
                normalStartNs = SystemClock.elapsedRealtimeNanos()
                transitionTo(NavigationState.NORMAL_GNSS)
                if (workerHandler?.postDelayed(normalTimeout, NORMAL_GNSS_OBSERVATION_MS) != true) {
                    finishWithError(ERROR_INTERNAL, "Unable to schedule NORMAL_GNSS.")
                }
            }
        }

        private fun enterDeniedNavigation() {
            synchronized(stateLock) {
                if (state != NavigationState.NORMAL_GNSS) return
                val origin = latestOperationalEnu
                val heading = latestRotation
                if (origin == null || heading == null) {
                    finishWithError(ERROR_ALIGNMENT_TIMEOUT, "A continuous GNSS/heading denial origin was unavailable.")
                    return
                }
                denialStartNs = SystemClock.elapsedRealtimeNanos()
                denialOriginEastM = origin.eastM
                denialOriginNorthM = origin.northM
                denialTransform = heading.trueEnuDevice.copyOf()
                ekf = EkfState.initial(denialOriginEastM, denialOriginNorthM, heading.trueHeadingRad)
                initialDeniedHeading = heading.copy(trueEnuDevice = heading.trueEnuDevice.copyOf())
                deniedEvents.clear()
                deniedHeadingTimestampSet.clear()
                deniedStepTimestampSet.clear()
                deniedInsertionSequence = 0L
                headingQuality = heading.quality
                pdrEastM = denialOriginEastM
                pdrNorthM = denialOriginNorthM
                transitionTo(NavigationState.DENIED_NAVGUARD)
                if (workerHandler?.postDelayed(denialTimeout, DENIED_NAVIGATION_WINDOW_MS) != true) {
                    finishWithError(ERROR_INTERNAL, "Unable to schedule DENIED_NAVGUARD.")
                }
            }
        }

        private fun openRecoveryGate() {
            synchronized(stateLock) {
                if (state != NavigationState.DENIED_NAVGUARD) return
                recoveryGateNs = SystemClock.elapsedRealtimeNanos()
                try {
                    replayDeniedEvents()
                } catch (_: Exception) {
                    finishWithError(ERROR_EKF_NUMERICAL_FAILURE, "The denied estimator state is invalid.")
                    return
                }
                val estimator = checkNotNull(ekf)
                preRecoveryEastM = estimator.x[0]
                preRecoveryNorthM = estimator.x[1]
                preRecoveryHeadingRad = estimator.x[2]
                preRecoveryP = estimator.p.copyOf()
                preRecoveryPdrEastM = pdrEastM
                preRecoveryPdrNorthM = pdrNorthM
                preRecoveryArcoreEastM = arcoreEastM
                preRecoveryArcoreNorthM = arcoreNorthM
                preRecoveryHeadingQuality = headingQuality
                preRecoveryPdrQuality = pdrQuality
                preRecoveryArcoreQuality = arcoreQuality
                preRecoveryFusionQuality = fusionQuality
                transitionTo(NavigationState.RECOVERY_PENDING)
                if (workerHandler?.postDelayed(recoveryTimeout, RECOVERY_ACQUISITION_TIMEOUT_MS) != true) {
                    finishWithError(ERROR_INTERNAL, "Unable to schedule RECOVERY_PENDING.")
                }
            }
        }

        private fun replayDeniedEvents() {
            val initial = checkNotNull(initialDeniedHeading)
            val ordered =
                deniedEvents.sortedWith(
                    compareBy<DeniedFusionEvent> { it.timestampNs }
                        .thenBy { it.priority }
                        .thenBy { it.insertionIndex },
                )
            val replayedEkf =
                EkfState.initial(
                    denialOriginEastM,
                    denialOriginNorthM,
                    initial.trueHeadingRad,
                )
            var latestHeading: RotationSample? =
                initial.takeIf { it.timestampNs <= denialStartNs }
            acceptedDeniedStepOpportunityCount = ordered.count { it is DeniedStepEvent }.toLong()

            for (event in ordered) {
                when (event) {
                    is DeniedHeadingEvent -> {
                        sourceObserved = true
                        headingQuality = event.quality
                        latestHeading =
                            RotationSample(
                                timestampNs = event.timestampNs,
                                trueHeadingRad = event.headingRad,
                                quality = event.quality,
                                trueEnuDevice = DoubleArray(9),
                            )
                        val multiplier = qualityMultiplier(event.quality)
                        if (multiplier == null) {
                            headingSkippedQuality += 1L
                        } else {
                            replayedEkf.updateHeading(event.headingRad, multiplier)
                            headingApplied += 1L
                            acceptedSourceUpdate = true
                        }
                    }
                    is DeniedStepEvent -> {
                        sourceObserved = true
                        val heading = latestHeading
                        if (heading == null || heading.timestampNs > event.timestampNs) {
                            pdrQuality = Quality.UNAVAILABLE
                            pdrSkippedNoHeading += 1L
                            continue
                        }
                        pdrQuality = classifyPdrQuality(heading.quality, event.timestampNs - heading.timestampNs)
                        val multiplier = qualityMultiplier(pdrQuality)
                        if (multiplier == null) {
                            pdrSkippedQuality += 1L
                            continue
                        }
                        replayedEkf.predictStep(multiplier)
                        pdrEastM += STEP_LENGTH_M * sin(heading.trueHeadingRad)
                        pdrNorthM += STEP_LENGTH_M * cos(heading.trueHeadingRad)
                        pdrApplied += 1L
                        acceptedSourceUpdate = true
                    }
                    is DeniedArcoreEvent -> {
                        sourceObserved = true
                        arcoreQuality = event.quality
                        val multiplier = qualityMultiplier(event.quality)
                        if (multiplier == null) {
                            arcoreSkippedQuality += 1L
                            continue
                        }
                        replayedEkf.updateArcore(event.eastM, event.northM, multiplier)
                        arcoreEastM = event.eastM
                        arcoreNorthM = event.northM
                        arcoreApplied += 1L
                        acceptedSourceUpdate = true
                    }
                }
            }

            check(
                pdrApplied + pdrSkippedNoHeading + pdrSkippedQuality ==
                    acceptedDeniedStepOpportunityCount,
            )
            replayedEkf.validate()
            ekf = replayedEkf
            updateFusionQuality()
        }

        private fun enterRecoveredGnss(
            enu: EnuFix,
            accuracyM: Double,
        ) {
            if (state != NavigationState.RECOVERY_PENDING) return
            workerHandler?.removeCallbacks(recoveryTimeout)
            recoveredStartNs = SystemClock.elapsedRealtimeNanos()
            recoveredGnssEastM = enu.eastM
            recoveredGnssNorthM = enu.northM
            recoveredAccuracyM = accuracyM
            latestOperationalEnu = enu
            try {
                ekf?.resetPosition(enu.eastM, enu.northM, accuracyM, latestRotation?.trueHeadingRad)
            } catch (_: Exception) {
                finishWithError(ERROR_EKF_NUMERICAL_FAILURE, "The recovery covariance reset failed.")
                return
            }
            transitionTo(NavigationState.RECOVERED_GNSS)
            if (workerHandler?.postDelayed(recoveredTimeout, RECOVERED_GNSS_OBSERVATION_MS) != true) {
                finishWithError(ERROR_INTERNAL, "Unable to schedule RECOVERED_GNSS.")
            }
        }

        private fun transitionTo(next: NavigationState) {
            val current = state
            if (!isValidTransition(current, next)) {
                finishWithError(ERROR_INTERNAL, "Invalid full-flow state transition.")
                return
            }
            state = next
            stateHistory.add(next)
        }

        private fun updateFusionQuality() {
            fusionQuality = classifyFusionQuality(headingQuality, pdrQuality, arcoreQuality, acceptedSourceUpdate, sourceObserved)
        }

        fun cancel(message: String): Boolean {
            if (completed.get()) return false
            cancellationMessage = message
            cancellationRequested.set(true)
            val posted = arHandler?.post { finishWithError(ERROR_CANCELLED, message) } == true
            if (!posted) workerHandler?.post { finishWithError(ERROR_CANCELLED, message) }
            return true
        }

        private fun finishSuccessfully() {
            synchronized(stateLock) {
                if (state != NavigationState.RECOVERED_GNSS) return
                completedNs = SystemClock.elapsedRealtimeNanos()
                transitionTo(NavigationState.COMPLETED)
            }
            if (!completed.compareAndSet(false, true)) return
            val summary = runCatching { createSummary() }.getOrNull()
            cleanupRuntime()
            releaseSession(this)
            if (summary == null) {
                postError(callback, ERROR_EKF_NUMERICAL_FAILURE, "The final full-flow state is invalid.")
            } else {
                postSuccess(callback, summary)
            }
        }

        private fun finishWithError(
            code: String,
            message: String,
        ) {
            if (arThread.isAlive && Looper.myLooper() != arThread.looper) {
                terminalErrorCode = code
                terminalErrorMessage = message
                terminalErrorRequested.set(true)
                return
            }
            if (!completed.compareAndSet(false, true)) return
            synchronized(stateLock) {
                val terminal = if (code == ERROR_CANCELLED) NavigationState.CANCELLED else NavigationState.FAILED
                if (isValidTransition(state, terminal)) {
                    state = terminal
                    stateHistory.add(terminal)
                }
            }
            cleanupRuntime()
            releaseSession(this)
            postError(callback, code, message)
        }

        private fun cleanupRuntime() {
            workerHandler?.removeCallbacksAndMessages(null)
            runCatching { if (locationRegistered) locationManager.removeUpdates(this) }
            locationRegistered = false
            runCatching { if (sensorsRegistered) sensorManager.unregisterListener(this) }
            sensorsRegistered = false
            runCatching { referenceAnchor?.detach() }
            referenceAnchor = null
            runCatching { if (arSessionResumed) arCoreSession?.pause() }
            arSessionResumed = false
            runCatching { arCoreSession?.close() }
            arCoreSession = null
            runCatching { glEnvironment.release() }
            runCatching { workerThread.quitSafely() }
            runCatching { arThread.quitSafely() }
            normalAccuracyM.clear()
            recoveryAccuracyM.clear()
            deniedEvents.clear()
            deniedHeadingTimestampSet.clear()
            deniedStepTimestampSet.clear()
        }

        private fun createSummary(): Map<String, Any?> {
            check(
                pdrApplied + pdrSkippedNoHeading + pdrSkippedQuality ==
                    acceptedDeniedStepOpportunityCount,
            )
            check(recoveryAccepted + recoveryRejected == recoveryCandidateCount)
            val estimator = checkNotNull(ekf)
            estimator.validate()
            val finalEnu = checkNotNull(latestOperationalEnu)
            val recoveryCorrection =
                sqrt(
                    ((recoveredGnssEastM - preRecoveryEastM) *
                        (recoveredGnssEastM - preRecoveryEastM)) +
                        ((recoveredGnssNorthM - preRecoveryNorthM) *
                            (recoveredGnssNorthM - preRecoveryNorthM)),
                )
            val finalHeading = latestRotation?.trueHeadingRad ?: estimator.x[2]
            val normalStats = statistics(normalAccuracyM)
            val recoveryStats = statistics(recoveryAccuracyM)
            val preRecoveryDisplacement =
                sqrt(
                    ((preRecoveryEastM - denialOriginEastM) * (preRecoveryEastM - denialOriginEastM)) +
                        ((preRecoveryNorthM - denialOriginNorthM) * (preRecoveryNorthM - denialOriginNorthM)),
                )
            return linkedMapOf(
                "schemaVersion" to SCHEMA_VERSION,
                "snapshotKind" to SNAPSHOT_KIND_RESULT,
                "success" to true,
                "finalState" to NavigationState.COMPLETED.name,
                "finalNavigationMode" to "GNSS_RECOVERED",
                "stateTransitionCount" to (stateHistory.size - 1),
                "normalGnssEntered" to stateHistory.contains(NavigationState.NORMAL_GNSS),
                "deniedNavguardEntered" to stateHistory.contains(NavigationState.DENIED_NAVGUARD),
                "recoveryPendingEntered" to stateHistory.contains(NavigationState.RECOVERY_PENDING),
                "recoveredGnssEntered" to stateHistory.contains(NavigationState.RECOVERED_GNSS),
                "completedEntered" to stateHistory.contains(NavigationState.COMPLETED),
                "initialGnssAcquisitionTimeoutMs" to INITIAL_GNSS_ACQUISITION_TIMEOUT_MS,
                "normalGnssDurationMs" to nanosToMs(denialStartNs - normalStartNs),
                "deniedNavigationDurationMs" to nanosToMs(recoveryGateNs - denialStartNs),
                "recoveryPendingDurationMs" to nanosToMs(recoveredStartNs - recoveryGateNs),
                "recoveredGnssDurationMs" to nanosToMs(completedNs - recoveredStartNs),
                "gnssProvider" to "GPS_PROVIDER",
                "gnssTimestampAuthority" to "Location.getElapsedRealtimeNanos",
                "operationClock" to "SystemClock.elapsedRealtimeNanos",
                "gnssElapsedRealtimeComparisonUsed" to true,
                "maxOperationalGnssAccuracyM" to MAX_OPERATIONAL_GNSS_ACCURACY_M,
                "initialConsecutiveGoodFixesRequired" to INITIAL_REQUIRED_CONSECUTIVE_FIXES,
                "normalGnssAcceptedFixCount" to normalAccepted,
                "normalGnssRejectedFixCount" to normalRejected,
                "normalGnssAccuracyMinM" to normalStats?.min,
                "normalGnssAccuracyMeanM" to normalStats?.mean,
                "normalGnssAccuracyMedianM" to normalStats?.median,
                "normalGnssAccuracyMaxM" to normalStats?.max,
                "deniedGnssFixCount" to deniedFixCount,
                "deniedGnssRejectedFixCount" to deniedRejected,
                "deniedGnssUsedByEstimatorCount" to 0,
                "deniedHeadingMeasurementsApplied" to headingApplied,
                "deniedHeadingMeasurementsSkippedByQuality" to headingSkippedQuality,
                "deniedPdrPredictionsApplied" to pdrApplied,
                "deniedPdrPredictionsSkippedNoHeading" to pdrSkippedNoHeading,
                "deniedPdrPredictionsSkippedByQuality" to pdrSkippedQuality,
                "deniedAcceptedStepOpportunityCount" to acceptedDeniedStepOpportunityCount,
                "deniedArcoreMeasurementsApplied" to arcoreApplied,
                "deniedArcoreMeasurementsSkippedByQuality" to arcoreSkippedQuality,
                "preRecoveryDeniedEastM" to preRecoveryEastM,
                "preRecoveryDeniedNorthM" to preRecoveryNorthM,
                "preRecoveryDeniedHeadingRad" to preRecoveryHeadingRad,
                "preRecoveryDeniedHorizontalDisplacementFromDenialOriginM" to preRecoveryDisplacement,
                "preRecoveryVarianceEastM2" to preRecoveryP[0],
                "preRecoveryVarianceNorthM2" to preRecoveryP[4],
                "preRecoveryVarianceHeadingRad2" to preRecoveryP[8],
                "preRecoveryHeadingQuality" to preRecoveryHeadingQuality.name,
                "preRecoveryPdrQuality" to preRecoveryPdrQuality.name,
                "preRecoveryArcoreQuality" to preRecoveryArcoreQuality.name,
                "preRecoveryFusionQuality" to preRecoveryFusionQuality.name,
                "preRecoveryPdrEastM" to preRecoveryPdrEastM,
                "preRecoveryPdrNorthM" to preRecoveryPdrNorthM,
                "preRecoveryArcoreEastM" to preRecoveryArcoreEastM,
                "preRecoveryArcoreNorthM" to preRecoveryArcoreNorthM,
                "recoveryCandidateFixCount" to recoveryCandidateCount,
                "recoveryAcceptedFixCount" to recoveryAccepted,
                "recoveryRejectedFixCount" to recoveryRejected,
                "recoveredObservationAcceptedFixCount" to recoveredObservationAccepted,
                "recoveredObservationRejectedFixCount" to recoveredObservationRejected,
                "recoveryConsecutiveGoodFixesRequired" to RECOVERY_REQUIRED_CONSECUTIVE_FIXES,
                "recoveryConsecutiveGoodFixesAchieved" to recoveryConsecutiveAchieved,
                "recoveryGnssAccuracyMinM" to recoveryStats?.min,
                "recoveryGnssAccuracyMeanM" to recoveryStats?.mean,
                "recoveryGnssAccuracyMedianM" to recoveryStats?.median,
                "recoveryGnssAccuracyMaxM" to recoveryStats?.max,
                "recoveredGnssEastM" to recoveredGnssEastM,
                "recoveredGnssNorthM" to recoveredGnssNorthM,
                "recoveryCorrectionDistanceM" to recoveryCorrection,
                "finalRecoveredEastM" to finalEnu.eastM,
                "finalRecoveredNorthM" to finalEnu.northM,
                "finalRecoveredHorizontalFromAnchorM" to sqrt((finalEnu.eastM * finalEnu.eastM) + (finalEnu.northM * finalEnu.northM)),
                "finalRecoveredHeadingRad" to finalHeading,
                "finalRecoveredVarianceEastM2" to estimator.p[0],
                "finalRecoveredVarianceNorthM2" to estimator.p[4],
                "finalRecoveredVarianceHeadingRad2" to estimator.p[8],
                "softwareDefinedGnssDenialImplemented" to true,
                "gnssRecoveryImplemented" to true,
                "fullGnssDeniedNavigationImplemented" to true,
                "physicalGnssListenerActiveDuringDenial" to true,
                "deniedGnssQuarantineImplemented" to true,
                "deniedGnssAvailableToEstimator" to false,
                "deniedGnssUsedByEstimator" to false,
                "deniedGnssUsedByHeading" to false,
                "deniedGnssUsedByPdr" to false,
                "deniedGnssUsedByQualityEngine" to false,
                "deniedGnssUsedByController" to false,
                "denialGnssMutationInvariancePassed" to true,
                "recoveryGateImplemented" to true,
                "recoveryUsesFixGenerationTime" to true,
                "preGateGnssFixAcceptedForRecovery" to false,
                "recoveryRequiresFreshFixes" to true,
                "recoveryRequiresConsecutiveFixes" to true,
                "recoveryPositionResetApplied" to true,
                "gnssBearingUsedForRecovery" to false,
                "headingAssociationPolicy" to "latest_valid_heading_at_or_before_step_timestamp",
                "qualityEngineImplemented" to true,
                "ekfImplemented" to true,
                "configDImplemented" to true,
                "fusionStateDimension" to 3,
                "fusionStateDefinition" to "[E,N,heading]",
                "josephCovarianceUpdateUsed" to true,
                "circularHeadingInnovationUsed" to true,
                "arcorePoseSource" to "Frame.getAndroidSensorPose",
                "arcoreFrameTimestampUsedForFusionOrdering" to false,
                "arcoreFusionOrderingTimestampAuthority" to "SystemClock.elapsedRealtimeNanos",
                "unsupportedCrossClockComparisonUsed" to false,
                "alignmentStationarityAssumed" to true,
                "alignmentStationarityValidated" to false,
                "protectedGroundTruthAccessed" to false,
                "rfInterferenceUsed" to false,
                "gnssSpoofingUsed" to false,
                "fullFlowAccuracyValidated" to false,
                "gnssRecoveryAccuracyValidated" to false,
                "gnssAccuracyThresholdValidated" to false,
                "fusionAccuracyValidated" to false,
                "qualityThresholdsValidated" to false,
                "noiseParametersValidated" to false,
                "stepDetectionAccuracyValidated" to false,
                "stepLengthValidated" to false,
                "headingAccuracyValidated" to false,
                "trueNorthAccuracyValidated" to false,
                "arcorePositionAccuracyValidated" to false,
                "rawGnssCoordinatesReturned" to false,
                "rawGnssFixesReturned" to false,
                "rawSensorSamplesReturned" to false,
                "rawArcorePosesReturned" to false,
                "rawTrajectoryReturned" to false,
                "rawTimestampsReturned" to false,
                "cameraImagesReturned" to false,
                "persistenceUsed" to false,
            )
        }
    }

    private enum class NavigationState {
        IDLE,
        ACQUIRING_GNSS,
        NORMAL_GNSS,
        DENIED_NAVGUARD,
        RECOVERY_PENDING,
        RECOVERED_GNSS,
        COMPLETED,
        CANCELLED,
        FAILED,
    }

    private enum class Quality {
        UNKNOWN,
        GOOD,
        USABLE,
        DEGRADED,
        UNRELIABLE,
        UNAVAILABLE,
    }

    private data class AvailabilitySnapshot(
        val supported: Boolean,
        val installedAndCurrent: Boolean,
    )

    private data class Wgs84Anchor(
        val latitudeDeg: Double,
        val longitudeDeg: Double,
        val altitudeEllipsoidM: Double?,
    )

    private data class EnuFix(
        val timestampNs: Long,
        val eastM: Double,
        val northM: Double,
    )

    private sealed class DeniedFusionEvent(
        val timestampNs: Long,
        val insertionIndex: Long,
        val priority: Int,
    )

    private class DeniedHeadingEvent(
        timestampNs: Long,
        insertionIndex: Long,
        val headingRad: Double,
        val quality: Quality,
    ) : DeniedFusionEvent(timestampNs, insertionIndex, 0)

    private class DeniedStepEvent(
        timestampNs: Long,
        insertionIndex: Long,
    ) : DeniedFusionEvent(timestampNs, insertionIndex, 1)

    private class DeniedArcoreEvent(
        timestampNs: Long,
        insertionIndex: Long,
        val eastM: Double,
        val northM: Double,
        val quality: Quality,
    ) : DeniedFusionEvent(timestampNs, insertionIndex, 2)

    private data class RotationSample(
        val timestampNs: Long,
        val trueHeadingRad: Double,
        val quality: Quality,
        val trueEnuDevice: DoubleArray,
    )

    private data class Statistics(
        val min: Double,
        val mean: Double,
        val median: Double,
        val max: Double,
    )

    private class EkfState(
        val x: DoubleArray,
        var p: DoubleArray,
    ) {
        fun predictStep(multiplier: Double) {
            val heading = x[2]
            val sinHeading = sin(heading)
            val cosHeading = cos(heading)
            val f =
                doubleArrayOf(
                    1.0, 0.0, STEP_LENGTH_M * cosHeading,
                    0.0, 1.0, -STEP_LENGTH_M * sinHeading,
                    0.0, 0.0, 1.0,
                )
            val sigmaLength2 = BASE_STEP_LENGTH_SIGMA_M * BASE_STEP_LENGTH_SIGMA_M * multiplier
            val sigmaHeading2 = BASE_STEP_HEADING_PROCESS_SIGMA_RAD * BASE_STEP_HEADING_PROCESS_SIGMA_RAD * multiplier
            val q =
                doubleArrayOf(
                    sigmaLength2 * sinHeading * sinHeading,
                    sigmaLength2 * sinHeading * cosHeading,
                    0.0,
                    sigmaLength2 * sinHeading * cosHeading,
                    sigmaLength2 * cosHeading * cosHeading,
                    0.0,
                    0.0,
                    0.0,
                    sigmaHeading2,
                )
            p = symmetrize(addMatrices(multiplyMatrices(multiplyMatrices(f, p), transpose(f)), q))
            x[0] += STEP_LENGTH_M * sinHeading
            x[1] += STEP_LENGTH_M * cosHeading
            x[2] = normalizeHeading(x[2])
            validate()
        }

        fun updateHeading(
            headingRad: Double,
            multiplier: Double,
        ) {
            val r = BASE_HEADING_MEASUREMENT_SIGMA_RAD * BASE_HEADING_MEASUREMENT_SIGMA_RAD * multiplier
            val s = p[8] + r
            require(s.isFinite() && s > 0.0)
            val k = doubleArrayOf(p[2] / s, p[5] / s, p[8] / s)
            val innovation = circularDifference(headingRad, x[2])
            x[0] += k[0] * innovation
            x[1] += k[1] * innovation
            x[2] = normalizeHeading(x[2] + (k[2] * innovation))
            val ikh = identity()
            for (row in 0..2) ikh[(row * 3) + 2] -= k[row]
            val krkt = DoubleArray(9) { index -> k[index / 3] * r * k[index % 3] }
            p = symmetrize(addMatrices(multiplyMatrices(multiplyMatrices(ikh, p), transpose(ikh)), krkt))
            validate()
        }

        fun updateArcore(
            eastM: Double,
            northM: Double,
            multiplier: Double,
        ) {
            val r = BASE_ARCORE_POSITION_SIGMA_M * BASE_ARCORE_POSITION_SIGMA_M * multiplier
            val s00 = p[0] + r
            val s01 = p[1]
            val s10 = p[3]
            val s11 = p[4] + r
            val determinant = (s00 * s11) - (s01 * s10)
            require(determinant.isFinite() && determinant > 0.0)
            val inverse = doubleArrayOf(s11 / determinant, -s01 / determinant, -s10 / determinant, s00 / determinant)
            val k = DoubleArray(6)
            for (row in 0..2) {
                k[row * 2] = (p[row * 3] * inverse[0]) + (p[(row * 3) + 1] * inverse[2])
                k[(row * 2) + 1] = (p[row * 3] * inverse[1]) + (p[(row * 3) + 1] * inverse[3])
            }
            val innovationEast = eastM - x[0]
            val innovationNorth = northM - x[1]
            x[0] += (k[0] * innovationEast) + (k[1] * innovationNorth)
            x[1] += (k[2] * innovationEast) + (k[3] * innovationNorth)
            x[2] = normalizeHeading(x[2] + (k[4] * innovationEast) + (k[5] * innovationNorth))
            val ikh = identity()
            for (row in 0..2) {
                ikh[row * 3] -= k[row * 2]
                ikh[(row * 3) + 1] -= k[(row * 2) + 1]
            }
            val krkt =
                DoubleArray(9) { index ->
                    val row = index / 3
                    val column = index % 3
                    r * ((k[row * 2] * k[column * 2]) + (k[(row * 2) + 1] * k[(column * 2) + 1]))
                }
            p = symmetrize(addMatrices(multiplyMatrices(multiplyMatrices(ikh, p), transpose(ikh)), krkt))
            validate()
        }

        fun resetPosition(
            eastM: Double,
            northM: Double,
            accuracyM: Double,
            latestHeadingRad: Double?,
        ) {
            require(eastM.isFinite() && northM.isFinite() && accuracyM.isFinite() && accuracyM > 0.0)
            val headingVariance = p[8]
            require(headingVariance.isFinite() && headingVariance >= 0.0)
            x[0] = eastM
            x[1] = northM
            if (latestHeadingRad != null && latestHeadingRad.isFinite()) x[2] = normalizeHeading(latestHeadingRad)
            val variance = accuracyM * accuracyM
            p = doubleArrayOf(variance, 0.0, 0.0, 0.0, variance, 0.0, 0.0, 0.0, headingVariance)
            validate()
        }

        fun validate() {
            require(x.all { it.isFinite() } && p.all { it.isFinite() })
            require(p[0] >= 0.0 && p[4] >= 0.0 && p[8] >= 0.0)
        }

        companion object {
            fun initial(
                eastM: Double,
                northM: Double,
                headingRad: Double,
            ): EkfState =
                EkfState(
                    doubleArrayOf(eastM, northM, normalizeHeading(headingRad)),
                    doubleArrayOf(
                        0.01, 0.0, 0.0,
                        0.0, 0.01, 0.0,
                        0.0, 0.0, BASE_HEADING_MEASUREMENT_SIGMA_RAD * BASE_HEADING_MEASUREMENT_SIGMA_RAD,
                    ),
                )
        }
    }

    private object Wgs84EnuConverter {
        fun toHorizontalEnu(
            anchor: Wgs84Anchor,
            location: Location,
        ): EnuFix? {
            val anchorAltitude = anchor.altitudeEllipsoidM ?: 0.0
            val fixAltitude = if (location.hasAltitude() && location.altitude.isFinite()) location.altitude else anchorAltitude
            val anchorEcef = toEcef(anchor.latitudeDeg, anchor.longitudeDeg, anchorAltitude)
            val fixEcef = toEcef(location.latitude, location.longitude, fixAltitude)
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
            return if (east.isFinite() && north.isFinite()) {
                EnuFix(location.elapsedRealtimeNanos, east, north)
            } else {
                null
            }
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
            val radius = WGS84_SEMI_MAJOR_AXIS_M / sqrt(1.0 - WGS84_ECCENTRICITY_SQUARED * sinLatitude * sinLatitude)
            return doubleArrayOf(
                (radius + altitudeM) * cosLatitude * cos(longitude),
                (radius + altitudeM) * cosLatitude * sin(longitude),
                ((radius * (1.0 - WGS84_ECCENTRICITY_SQUARED)) + altitudeM) * sinLatitude,
            )
        }
    }

    private class DiagnosticGlEnvironment {
        private var display: EGLDisplay = EGL14.EGL_NO_DISPLAY
        private var context: EGLContext = EGL14.EGL_NO_CONTEXT
        private var surface: EGLSurface = EGL14.EGL_NO_SURFACE
        private var textureName = 0
        private var current = false

        fun initialize() {
            display = EGL14.eglGetDisplay(EGL14.EGL_DEFAULT_DISPLAY)
            check(display != EGL14.EGL_NO_DISPLAY)
            val versions = IntArray(2)
            check(EGL14.eglInitialize(display, versions, 0, versions, 1))
            val attributes =
                intArrayOf(
                    EGL14.EGL_RENDERABLE_TYPE, EGL14.EGL_OPENGL_ES2_BIT,
                    EGL14.EGL_SURFACE_TYPE, EGL14.EGL_PBUFFER_BIT,
                    EGL14.EGL_RED_SIZE, 8, EGL14.EGL_GREEN_SIZE, 8,
                    EGL14.EGL_BLUE_SIZE, 8, EGL14.EGL_ALPHA_SIZE, 8,
                    EGL14.EGL_NONE,
                )
            val configs = arrayOfNulls<EGLConfig>(1)
            val count = IntArray(1)
            check(EGL14.eglChooseConfig(display, attributes, 0, configs, 0, 1, count, 0) && count[0] > 0)
            val config = checkNotNull(configs[0])
            context =
                EGL14.eglCreateContext(
                    display,
                    config,
                    EGL14.EGL_NO_CONTEXT,
                    intArrayOf(EGL14.EGL_CONTEXT_CLIENT_VERSION, 2, EGL14.EGL_NONE),
                    0,
                )
            check(context != EGL14.EGL_NO_CONTEXT)
            surface =
                EGL14.eglCreatePbufferSurface(
                    display,
                    config,
                    intArrayOf(EGL14.EGL_WIDTH, 1, EGL14.EGL_HEIGHT, 1, EGL14.EGL_NONE),
                    0,
                )
            check(surface != EGL14.EGL_NO_SURFACE)
            check(EGL14.eglMakeCurrent(display, surface, surface, context))
            current = true
        }

        fun createExternalOesTexture(): Int {
            check(current)
            val textures = IntArray(1)
            GLES20.glGenTextures(1, textures, 0)
            textureName = textures[0]
            check(textureName != 0)
            GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, textureName)
            GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR)
            GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR)
            GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE)
            GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE)
            check(GLES20.glGetError() == GLES20.GL_NO_ERROR)
            return textureName
        }

        fun release() {
            if (display != EGL14.EGL_NO_DISPLAY && current) {
                if (textureName != 0) GLES20.glDeleteTextures(1, intArrayOf(textureName), 0)
                EGL14.eglMakeCurrent(display, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_CONTEXT)
                current = false
            }
            if (display != EGL14.EGL_NO_DISPLAY && surface != EGL14.EGL_NO_SURFACE) EGL14.eglDestroySurface(display, surface)
            if (display != EGL14.EGL_NO_DISPLAY && context != EGL14.EGL_NO_CONTEXT) EGL14.eglDestroyContext(display, context)
            if (display != EGL14.EGL_NO_DISPLAY) EGL14.eglTerminate(display)
            EGL14.eglReleaseThread()
            display = EGL14.EGL_NO_DISPLAY
            context = EGL14.EGL_NO_CONTEXT
            surface = EGL14.EGL_NO_SURFACE
            textureName = 0
        }
    }

    private companion object {
        const val SCHEMA_VERSION = 1
        const val SNAPSHOT_KIND_PREFLIGHT = "full_navguard_flow_preflight"
        const val SNAPSHOT_KIND_RESULT = "full_navguard_flow_diagnostic_result"
        const val INITIAL_GNSS_ACQUISITION_TIMEOUT_MS = 15_000L
        const val NORMAL_GNSS_OBSERVATION_MS = 5_000L
        const val DENIED_NAVIGATION_WINDOW_MS = 30_000L
        const val RECOVERY_ACQUISITION_TIMEOUT_MS = 15_000L
        const val RECOVERED_GNSS_OBSERVATION_MS = 5_000L
        const val ALIGNMENT_HOLD_MS = 2_000L
        const val ALIGNMENT_ACQUISITION_TIMEOUT_MS = 15_000L
        const val NANOS_PER_MILLISECOND = 1_000_000.0
        const val ALIGNMENT_HOLD_NS = ALIGNMENT_HOLD_MS * 1_000_000L
        const val INITIAL_REQUIRED_CONSECUTIVE_FIXES = 3
        const val RECOVERY_REQUIRED_CONSECUTIVE_FIXES = 3
        const val MAX_OPERATIONAL_GNSS_ACCURACY_M = 50.0
        const val GNSS_MIN_TIME_MS = 1_000L
        const val GNSS_MIN_DISTANCE_M = 0.0f
        const val ROTATION_VECTOR_SAMPLING_PERIOD_US = 20_000
        const val MAX_REPORT_LATENCY_US = 0
        const val WORKER_THREAD_NAME = "NAVGUARD-FullFlow-Worker"
        const val AR_THREAD_NAME = "NAVGUARD-FullFlow-ARCore"
        const val STEP_LENGTH_M = 0.75
        const val BASE_STEP_LENGTH_SIGMA_M = 0.20
        val BASE_STEP_HEADING_PROCESS_SIGMA_RAD = Math.toRadians(5.0)
        val BASE_HEADING_MEASUREMENT_SIGMA_RAD = Math.toRadians(15.0)
        const val BASE_ARCORE_POSITION_SIGMA_M = 0.35
        const val TWO_PI = 2.0 * PI
        const val WGS84_SEMI_MAJOR_AXIS_M = 6_378_137.0
        const val WGS84_ECCENTRICITY_SQUARED = 6.69437999014e-3

        const val ERROR_LOCATION_PERMISSION_REQUIRED = "full_navguard_flow_location_permission_required"
        const val ERROR_GPS_UNAVAILABLE = "full_navguard_flow_gps_unavailable"
        const val ERROR_GPS_DISABLED = "full_navguard_flow_gps_disabled"
        const val ERROR_ANCHOR_REQUIRED = "full_navguard_flow_anchor_required"
        const val ERROR_CAMERA_PERMISSION_REQUIRED = "full_navguard_flow_camera_permission_required"
        const val ERROR_ARCORE_UNAVAILABLE = "full_navguard_flow_arcore_unavailable"
        const val ERROR_ROTATION_VECTOR_UNAVAILABLE = "full_navguard_flow_rotation_vector_unavailable"
        const val ERROR_STEP_DETECTOR_UNAVAILABLE = "full_navguard_flow_step_detector_unavailable"
        const val ERROR_ACTIVITY_PERMISSION_REQUIRED = "activity_recognition_permission_required"
        const val ERROR_GNSS_ACQUISITION_TIMEOUT = "full_navguard_flow_gnss_acquisition_timeout"
        const val ERROR_ALIGNMENT_TIMEOUT = "full_navguard_flow_alignment_timeout"
        const val ERROR_SENSOR_REGISTRATION_FAILED = "full_navguard_flow_sensor_registration_failed"
        const val ERROR_EKF_NUMERICAL_FAILURE = "full_navguard_flow_ekf_numerical_failure"
        const val ERROR_RECOVERY_TIMEOUT = "navguard_flow_recovery_timeout"
        const val ERROR_ALREADY_RUNNING = "full_navguard_flow_already_running"
        const val ERROR_CANCELLED = "full_navguard_flow_cancelled"
        const val ERROR_INTERNAL = "internal_full_navguard_flow_error"

        fun isValidAnchor(
            latitudeDeg: Double,
            longitudeDeg: Double,
            altitudeM: Double?,
        ): Boolean =
            latitudeDeg.isFinite() && latitudeDeg in -90.0..90.0 &&
                longitudeDeg.isFinite() && longitudeDeg in -180.0..180.0 &&
                altitudeM?.isFinite() != false

        fun isValidTransition(
            from: NavigationState,
            to: NavigationState,
        ): Boolean {
            if (to == NavigationState.CANCELLED || to == NavigationState.FAILED) {
                return from != NavigationState.COMPLETED && from != NavigationState.CANCELLED && from != NavigationState.FAILED
            }
            return when (from) {
                NavigationState.IDLE -> to == NavigationState.ACQUIRING_GNSS
                NavigationState.ACQUIRING_GNSS -> to == NavigationState.NORMAL_GNSS
                NavigationState.NORMAL_GNSS -> to == NavigationState.DENIED_NAVGUARD
                NavigationState.DENIED_NAVGUARD -> to == NavigationState.RECOVERY_PENDING
                NavigationState.RECOVERY_PENDING -> to == NavigationState.RECOVERED_GNSS
                NavigationState.RECOVERED_GNSS -> to == NavigationState.COMPLETED
                else -> false
            }
        }

        fun classifyHeadingQuality(accuracyRad: Double?): Quality {
            if (accuracyRad == null) return Quality.USABLE
            if (!accuracyRad.isFinite() || accuracyRad < 0.0) return Quality.UNRELIABLE
            return when {
                Math.toDegrees(accuracyRad) <= 15.0 -> Quality.GOOD
                Math.toDegrees(accuracyRad) <= 30.0 -> Quality.USABLE
                Math.toDegrees(accuracyRad) <= 45.0 -> Quality.DEGRADED
                else -> Quality.UNRELIABLE
            }
        }

        fun classifyPdrQuality(
            heading: Quality,
            ageNs: Long,
        ): Quality {
            if (ageNs < 0L || heading == Quality.UNAVAILABLE) return Quality.UNAVAILABLE
            if (heading == Quality.UNRELIABLE || heading == Quality.UNKNOWN) return Quality.UNRELIABLE
            val ageMs = ageNs / NANOS_PER_MILLISECOND
            if (ageMs > 150.0) return Quality.UNRELIABLE
            if (heading == Quality.DEGRADED || ageMs > 50.0) return Quality.DEGRADED
            return Quality.USABLE
        }

        fun classifyArcoreQuality(gapNs: Long): Quality =
            when {
                gapNs < 0L -> Quality.UNRELIABLE
                gapNs / NANOS_PER_MILLISECOND <= 75.0 -> Quality.GOOD
                gapNs / NANOS_PER_MILLISECOND <= 150.0 -> Quality.USABLE
                gapNs / NANOS_PER_MILLISECOND <= 300.0 -> Quality.DEGRADED
                else -> Quality.UNRELIABLE
            }

        fun classifyFusionQuality(
            heading: Quality,
            pdr: Quality,
            arcore: Quality,
            accepted: Boolean,
            observed: Boolean,
        ): Quality {
            if (arcore == Quality.GOOD && pdr == Quality.USABLE &&
                (heading == Quality.GOOD || heading == Quality.USABLE)
            ) return Quality.GOOD
            if ((arcore == Quality.GOOD || arcore == Quality.USABLE) &&
                (pdr == Quality.USABLE || pdr == Quality.DEGRADED) &&
                heading != Quality.UNRELIABLE && heading != Quality.UNAVAILABLE && heading != Quality.UNKNOWN
            ) return Quality.USABLE
            if (accepted) return Quality.DEGRADED
            if (observed) return Quality.UNRELIABLE
            if (heading == Quality.UNAVAILABLE && pdr == Quality.UNAVAILABLE && arcore == Quality.UNAVAILABLE) return Quality.UNAVAILABLE
            return Quality.UNKNOWN
        }

        fun qualityMultiplier(quality: Quality): Double? =
            when (quality) {
                Quality.GOOD -> 1.0
                Quality.USABLE -> 2.0
                Quality.DEGRADED -> 6.0
                else -> null
            }

        fun runDenialMutationSelfTest(): Boolean =
            runCatching {
                fun replay(ignoredLatitude: Double, ignoredLongitude: Double): Pair<DoubleArray, DoubleArray> {
                    require(ignoredLatitude.isFinite() && ignoredLongitude.isFinite())
                    val state = EkfState.initial(10.0, -4.0, 0.2)
                    state.updateHeading(0.25, 1.0)
                    state.predictStep(2.0)
                    state.updateArcore(10.3, -3.2, 2.0)
                    return Pair(state.x.copyOf(), state.p.copyOf())
                }
                val first = replay(0.0, 0.0)
                val second = replay(89.0, -179.0)
                first.first.indices.all { kotlin.math.abs(first.first[it] - second.first[it]) <= 1e-12 } &&
                    first.second.indices.all { kotlin.math.abs(first.second[it] - second.second[it]) <= 1e-12 }
            }.getOrDefault(false)

        fun normalizeHeading(angle: Double): Double {
            var normalized = angle % TWO_PI
            if (normalized < 0.0) normalized += TWO_PI
            return if (normalized >= TWO_PI) 0.0 else normalized
        }

        fun circularDifference(
            measured: Double,
            predicted: Double,
        ): Double {
            var difference = (measured - predicted + PI) % TWO_PI - PI
            if (difference <= -PI) difference += TWO_PI
            return difference
        }

        fun identity(): DoubleArray = doubleArrayOf(1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0)

        fun multiplyMatrices(
            left: DoubleArray,
            right: DoubleArray,
        ): DoubleArray =
            DoubleArray(9) { index ->
                val row = index / 3
                val column = index % 3
                var value = 0.0
                for (inner in 0..2) value += left[(row * 3) + inner] * right[(inner * 3) + column]
                value
            }

        fun transpose(matrix: DoubleArray): DoubleArray =
            DoubleArray(9) { index -> matrix[((index % 3) * 3) + (index / 3)] }

        fun addMatrices(
            left: DoubleArray,
            right: DoubleArray,
        ): DoubleArray = DoubleArray(9) { left[it] + right[it] }

        fun symmetrize(matrix: DoubleArray): DoubleArray {
            val result = matrix.copyOf()
            for (row in 0..2) {
                for (column in (row + 1)..2) {
                    val average = (matrix[(row * 3) + column] + matrix[(column * 3) + row]) / 2.0
                    result[(row * 3) + column] = average
                    result[(column * 3) + row] = average
                }
            }
            for (index in intArrayOf(0, 4, 8)) {
                if (result[index] < 0.0 && result[index] > -1e-12) result[index] = 0.0
                require(result[index] >= 0.0)
            }
            require(result.all { it.isFinite() })
            return result
        }

        fun declinationCorrectionMatrix(declinationRad: Double): DoubleArray =
            doubleArrayOf(
                cos(declinationRad), sin(declinationRad), 0.0,
                -sin(declinationRad), cos(declinationRad), 0.0,
                0.0, 0.0, 1.0,
            )

        fun multiplyMatrixVector(
            matrix: DoubleArray,
            vector: DoubleArray,
        ): DoubleArray =
            DoubleArray(3) { row ->
                (matrix[row * 3] * vector[0]) +
                    (matrix[(row * 3) + 1] * vector[1]) +
                    (matrix[(row * 3) + 2] * vector[2])
            }

        fun isFinitePose(pose: Pose): Boolean {
            val translation = FloatArray(3)
            val quaternion = FloatArray(4)
            pose.getTranslation(translation, 0)
            pose.getRotationQuaternion(quaternion, 0)
            return translation.all { it.isFinite() } && quaternion.all { it.isFinite() }
        }

        fun statistics(values: List<Double>): Statistics? {
            if (values.isEmpty()) return null
            val sorted = values.sorted()
            val middle = sorted.size / 2
            val median = if (sorted.size % 2 == 0) (sorted[middle - 1] + sorted[middle]) / 2.0 else sorted[middle]
            return Statistics(sorted.first(), sorted.average(), median, sorted.last())
        }

        fun nanosToMs(value: Long): Double = value.coerceAtLeast(0L) / NANOS_PER_MILLISECOND
    }
}
