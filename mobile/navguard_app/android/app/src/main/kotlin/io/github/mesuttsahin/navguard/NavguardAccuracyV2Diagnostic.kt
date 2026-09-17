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
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import android.os.SystemClock
import androidx.core.content.ContextCompat
import com.google.ar.core.ArCoreApk
import com.google.ar.core.Config
import com.google.ar.core.Pose
import com.google.ar.core.Session
import com.google.ar.core.TrackingState
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.atan2
import kotlin.math.ceil
import kotlin.math.cos
import kotlin.math.hypot
import kotlin.math.sin
import kotlin.math.sqrt

class NavguardAccuracyV2Diagnostic(
    private val applicationContext: Context,
    private val locationManager: LocationManager,
    private val sensorManager: SensorManager,
) {
    interface Callback {
        fun onSuccess(summary: Map<String, Any?>)

        fun onError(
            code: String,
            message: String,
            details: Map<String, Any?>?,
        )
    }

    private val mainHandler = Handler(Looper.getMainLooper())
    private val activeSessionLock = Any()
    private var activeSession: AccuracySession? = null

    fun isOperationRunning(): Boolean = synchronized(activeSessionLock) { activeSession != null }

    fun createPreflightSnapshot(anchorAvailable: Boolean): Map<String, Any?> {
        val availability = readArCoreAvailability()
        val fineLocation = hasPermission(Manifest.permission.ACCESS_FINE_LOCATION)
        val activityPermission =
            Build.VERSION.SDK_INT < Build.VERSION_CODES.Q || hasPermission(Manifest.permission.ACTIVITY_RECOGNITION)
        val cameraPermission = hasPermission(Manifest.permission.CAMERA)
        val gpsAvailable = runCatching { locationManager.allProviders.contains(LocationManager.GPS_PROVIDER) }.getOrDefault(false)
        val gpsEnabled = runCatching { locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER) }.getOrDefault(false)
        val rotationAvailable = sensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR) != null
        val stepAvailable = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_DETECTOR) != null
        val busy = isOperationRunning()
        val ready =
            fineLocation && gpsAvailable && gpsEnabled && rotationAvailable && stepAvailable && activityPermission &&
                availability.supported && availability.installed && cameraPermission && anchorAvailable && !busy
        val selfTests =
            LinkedHashMap<String, Boolean>().apply {
                putAll(NavguardAdaptiveFusionV2.runDeterministicSelfTests())
                putAll(NavguardCalibrationProfileStore.runDeterministicSelfTests())
                putAll(runTargetedLifecycleSelfTests())
            }
        return linkedMapOf(
            "schemaVersion" to SCHEMA_VERSION,
            "snapshotKind" to "navguard_accuracy_v2_preflight",
            "configId" to NavguardAdaptiveFusionV2.CONFIG_ID,
            "fineLocationPermissionGranted" to fineLocation,
            "gpsProviderAvailable" to gpsAvailable,
            "gpsProviderEnabled" to gpsEnabled,
            "rotationVectorAvailable" to rotationAvailable,
            "stepDetectorAvailable" to stepAvailable,
            "activityRecognitionPermissionGranted" to activityPermission,
            "arCoreSupported" to availability.supported,
            "arCoreInstalled" to availability.installed,
            "cameraPermissionGranted" to cameraPermission,
            "anchorAvailable" to anchorAvailable,
            "nativeReady" to ready,
            "operationBusy" to busy,
            "selfTests" to selfTests,
            "selfTestsPassed" to selfTests.values.all { it },
            "calibrationProfilePersistence" to "android_shared_preferences",
            "protectedGroundTruthEstimatorAccessAllowed" to false,
            "developmentOnly" to true,
            "accuracyValidated" to false,
            "aiModelImplemented" to false,
        )
    }

    fun getCalibrationProfile(): Map<String, Any?> = NavguardCalibrationProfileStore.readSanitizedMap()

    fun resetCalibrationProfile(): Map<String, Any?> = NavguardCalibrationProfileStore.reset().toSanitizedMap(false)

    fun createOperationStatusSnapshot(): Map<String, Any?> {
        val session = synchronized(activeSessionLock) { activeSession }
        return session?.createOperationStatusSnapshot()
            ?: linkedMapOf(
                "schemaVersion" to SCHEMA_VERSION,
                "snapshotKind" to "navguard_accuracy_v2_operation_status",
                "phase" to "IDLE",
                "finalDrainRemainingSeconds" to null,
            )
    }

    fun runCalibration(
        anchorLatitudeDeg: Double,
        anchorLongitudeDeg: Double,
        anchorAltitudeEllipsoidM: Double?,
        callback: Callback,
    ) = startSession(
        SessionKind.CALIBRATION,
        anchorLatitudeDeg,
        anchorLongitudeDeg,
        anchorAltitudeEllipsoidM,
        null,
        callback,
    )

    fun runDevelopmentBenchmark(
        anchorLatitudeDeg: Double,
        anchorLongitudeDeg: Double,
        anchorAltitudeEllipsoidM: Double?,
        developmentScenario: String,
        callback: Callback,
    ) = startSession(
        SessionKind.DEVELOPMENT_BENCHMARK,
        anchorLatitudeDeg,
        anchorLongitudeDeg,
        anchorAltitudeEllipsoidM,
        developmentScenario,
        callback,
    )

    private fun startSession(
        kind: SessionKind,
        anchorLatitudeDeg: Double,
        anchorLongitudeDeg: Double,
        anchorAltitudeEllipsoidM: Double?,
        developmentScenario: String?,
        callback: Callback,
    ) {
        if (!isValidAnchor(anchorLatitudeDeg, anchorLongitudeDeg, anchorAltitudeEllipsoidM)) {
            postError(callback, ERROR_ANCHOR_REQUIRED, "A valid locked Stage 3A GNSS anchor is required.")
            return
        }
        if (kind == SessionKind.DEVELOPMENT_BENCHMARK && developmentScenario !in DEVELOPMENT_SCENARIOS) {
            postError(callback, ERROR_INVALID_SCENARIO, "Select a valid development benchmark scenario.")
            return
        }
        val preflight = createPreflightSnapshot(anchorAvailable = true)
        if (preflight["nativeReady"] != true) {
            postError(callback, ERROR_NOT_READY, "NAVGUARD Accuracy v2 prerequisites are not ready.")
            return
        }
        val rotation = sensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
        val step = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_DETECTOR)
        if (rotation == null || step == null) {
            postError(callback, ERROR_NOT_READY, "Required sensors are unavailable.")
            return
        }
        val anchor = Wgs84Anchor(anchorLatitudeDeg, anchorLongitudeDeg, anchorAltitudeEllipsoidM)
        val declination =
            Math.toRadians(
                GeomagneticField(
                    anchorLatitudeDeg.toFloat(),
                    anchorLongitudeDeg.toFloat(),
                    (anchorAltitudeEllipsoidM ?: 0.0).toFloat(),
                    System.currentTimeMillis(),
                ).declination.toDouble(),
            )
        val session = AccuracySession(kind, anchor, declination, rotation, step, developmentScenario, callback)
        synchronized(activeSessionLock) {
            if (activeSession != null) {
                postError(callback, ERROR_ALREADY_RUNNING, "Another Accuracy v2 operation is already running.")
                return
            }
            activeSession = session
        }
        session.start()
    }

    private fun releaseSession(session: AccuracySession) {
        synchronized(activeSessionLock) {
            if (activeSession === session) activeSession = null
        }
    }

    private inner class AccuracySession(
        private val kind: SessionKind,
        private val anchor: Wgs84Anchor,
        private val declinationRad: Double,
        private val rotationVector: Sensor,
        private val stepDetector: Sensor,
        private val developmentScenario: String?,
        private val callback: Callback,
    ) : SensorEventListener, LocationListener {
        private val terminal = AtomicBoolean(false)
        private val workerThread = HandlerThread("NAVGUARD-Accuracy-v2")
        private val arThread = HandlerThread("NAVGUARD-Accuracy-v2-ARCore")
        private val glEnvironment = GlEnvironment()
        private var worker: Handler? = null
        private var arWorker: Handler? = null
        private var arSession: Session? = null
        private var arSessionResumed = false
        private var listenersRegistered = false
        private var locationRegistered = false
        @Volatile private var startedAtNs = 0L
        @Volatile private var denialStartNs = 0L
        @Volatile private var benchmarkDeniedEndTimestampNs = 0L
        @Volatile private var benchmarkFinalDrainEndTimestampNs = 0L
        private var calibrationFinalDrainStartNs = 0L
        private var stepsReceivedDuringFinalDrainCallbackDelivery = 0L
        private var benchmarkStepEventsReceivedTotal = 0L
        private var benchmarkStepEventsInFormalWindow = 0L
        private var benchmarkStepEventsDeliveredDuringFinalDrain = 0L
        private var benchmarkStepEventsIncludedFromFinalDrain = 0L
        private var benchmarkStepEventsExcludedPostWindow = 0L
        private val acceptedStepTimestamps = linkedSetOf<Long>()
        private var latestTrueEnuDevice: DoubleArray? = null
        private var initialArPose: Pose? = null
        private var frozenTrueEnuDevice: DoubleArray? = null
        private var previousArTimestampNs: Long? = null
        private var insertionSequence = 0L
        private val events = mutableListOf<ReplayEvent>()
        private val gnssStabilization = GnssStabilizationAccumulator()
        private var stableGnssOrigin: AdaptiveStableGnssOrigin? = null
        private var gnssStabilizationDecision: GnssStabilizationDecision? = null
        private val protectedGroundTruth = mutableListOf<GroundTruthPoint>()

        fun createOperationStatusSnapshot(): Map<String, Any?> {
            val nowNs = SystemClock.elapsedRealtimeNanos()
            val phase: String
            val remainingSeconds: Long?
            if (kind == SessionKind.CALIBRATION) {
                val drainStartNs = calibrationFinalDrainStartNs
                val calibrationEndNs = startedAtNs + CALIBRATION_TOTAL_DURATION_MS * 1_000_000L
                if (drainStartNs > 0L && nowNs >= drainStartNs && nowNs <= calibrationEndNs) {
                    phase = "CALIBRATION_FINAL_DRAIN"
                    remainingSeconds = remainingWholeSeconds(calibrationEndNs, nowNs)
                } else {
                    phase = "CALIBRATION_MOVEMENT"
                    remainingSeconds = null
                }
            } else {
                val deniedStart = denialStartNs
                val deniedEnd = benchmarkDeniedEndTimestampNs
                val drainEnd = benchmarkFinalDrainEndTimestampNs
                when {
                    deniedStart <= 0L -> {
                        phase = "GNSS_STABILIZATION"
                        remainingSeconds = null
                    }
                    deniedEnd > 0L && nowNs <= deniedEnd -> {
                        phase = "BENCHMARK_FORMAL_WINDOW"
                        remainingSeconds = null
                    }
                    drainEnd > 0L && nowNs <= drainEnd -> {
                        phase = "BENCHMARK_FINAL_DRAIN"
                        remainingSeconds = remainingWholeSeconds(drainEnd, nowNs)
                    }
                    else -> {
                        phase = "FINALIZING"
                        remainingSeconds = null
                    }
                }
            }
            return linkedMapOf(
                "schemaVersion" to SCHEMA_VERSION,
                "snapshotKind" to "navguard_accuracy_v2_operation_status",
                "phase" to phase,
                "finalDrainRemainingSeconds" to remainingSeconds,
            )
        }

        fun start() {
            try {
                workerThread.start()
                arThread.start()
                worker = Handler(workerThread.looper)
                arWorker = Handler(arThread.looper)
                worker?.post(::startOnWorker)
            } catch (_: Exception) {
                finishError(ERROR_INTERNAL, "Unable to create Accuracy v2 workers.")
            }
        }

        @Suppress("MissingPermission")
        private fun startOnWorker() {
            if (terminal.get()) return
            try {
                startedAtNs = SystemClock.elapsedRealtimeNanos()
                denialStartNs = if (kind == SessionKind.CALIBRATION) startedAtNs else 0L
                calibrationFinalDrainStartNs = startedAtNs + CALIBRATION_MOVEMENT_DURATION_MS * 1_000_000L
                val rotationRegistered =
                    sensorManager.registerListener(this, rotationVector, ROTATION_VECTOR_SAMPLING_PERIOD_US, 0, worker)
                val stepRegistered =
                    sensorManager.registerListener(this, stepDetector, SensorManager.SENSOR_DELAY_NORMAL, 0, worker)
                listenersRegistered = rotationRegistered || stepRegistered
                if (!rotationRegistered || !stepRegistered) {
                    finishError(ERROR_SENSOR_REGISTRATION, "Android rejected a required Accuracy v2 sensor registration.")
                    return
                }
                locationManager.requestLocationUpdates(
                    LocationManager.GPS_PROVIDER,
                    GNSS_MIN_TIME_MS,
                    0.0f,
                    this,
                    checkNotNull(worker).looper,
                )
                locationRegistered = true
                if (arWorker?.post(::initializeArCore) != true) {
                    finishError(ERROR_ARCORE_UNAVAILABLE, "Unable to start the Accuracy v2 ARCore worker.")
                    return
                }
                if (kind == SessionKind.CALIBRATION) {
                    worker?.postDelayed(::finishSuccess, CALIBRATION_TOTAL_DURATION_MS)
                } else {
                    worker?.postDelayed(
                        { completeGnssStabilization(timeoutReached = true) },
                        GNSS_STABILIZATION_TIMEOUT_MS + 1L,
                    )
                }
            } catch (_: SecurityException) {
                finishError(ERROR_PERMISSION_REQUIRED, "A required runtime permission is missing.")
            } catch (_: Exception) {
                finishError(ERROR_INTERNAL, "Unable to start the Accuracy v2 operation.")
            }
        }

        override fun onSensorChanged(event: SensorEvent) {
            if (terminal.get() || event.timestamp <= 0L) return
            when (event.sensor.type) {
                Sensor.TYPE_ROTATION_VECTOR -> createHeadingEvent(event)?.let { heading ->
                    latestTrueEnuDevice = heading.trueEnuDevice
                    events.add(heading)
                }
                Sensor.TYPE_STEP_DETECTOR -> {
                    val value = event.values.firstOrNull()
                    if (value != null && value.isFinite() && value == 1.0f) {
                        val callbackTimestampNs = SystemClock.elapsedRealtimeNanos()
                        when (kind) {
                            SessionKind.CALIBRATION -> {
                                val phase = calibrationPhaseForTimestamp(event.timestamp, startedAtNs)
                                if (
                                    shouldAcceptCalibrationStep(event.timestamp, callbackTimestampNs, startedAtNs) &&
                                    acceptedStepTimestamps.add(event.timestamp)
                                ) {
                                    events.add(StepReplayEvent(event.timestamp, nextInsertion(), phase))
                                    if (callbackTimestampNs >= calibrationFinalDrainStartNs) {
                                        stepsReceivedDuringFinalDrainCallbackDelivery += 1L
                                    }
                                }
                            }
                            SessionKind.DEVELOPMENT_BENCHMARK -> {
                                val deniedStart = denialStartNs
                                val deniedEnd = benchmarkDeniedEndTimestampNs
                                val drainEnd = benchmarkFinalDrainEndTimestampNs
                                if (deniedStart > 0L && deniedEnd >= deniedStart && callbackTimestampNs <= drainEnd) {
                                    benchmarkStepEventsReceivedTotal += 1L
                                    val deliveredDuringDrain =
                                        isBenchmarkFinalDrainDelivery(callbackTimestampNs, deniedEnd, drainEnd)
                                    if (deliveredDuringDrain) benchmarkStepEventsDeliveredDuringFinalDrain += 1L
                                    if (event.timestamp > deniedEnd) {
                                        benchmarkStepEventsExcludedPostWindow += 1L
                                    } else if (
                                        isWithinFormalBenchmarkWindow(event.timestamp, deniedStart, deniedEnd) &&
                                        acceptedStepTimestamps.add(event.timestamp)
                                    ) {
                                        events.add(StepReplayEvent(event.timestamp, nextInsertion(), null))
                                        benchmarkStepEventsInFormalWindow += 1L
                                        if (deliveredDuringDrain) benchmarkStepEventsIncludedFromFinalDrain += 1L
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        override fun onAccuracyChanged(
            sensor: Sensor,
            accuracy: Int,
        ) {
            // Rotation-vector payload accuracy is used when Android supplies it.
        }

        private fun createHeadingEvent(event: SensorEvent): HeadingReplayEvent? {
            if (event.values.size < 3) return null
            val count = if (event.values.size >= 4) 4 else 3
            val vector = FloatArray(count)
            for (index in 0 until count) {
                if (!event.values[index].isFinite()) return null
                vector[index] = event.values[index]
            }
            val matrix = FloatArray(9)
            return runCatching {
                SensorManager.getRotationMatrixFromVector(matrix, vector)
                require(matrix.all(Float::isFinite))
                val east = matrix[1].toDouble()
                val north = matrix[4].toDouble()
                require(hypot(east, north) > 1e-6)
                val reportedAccuracy =
                    if (event.values.size >= 5) event.values[4].toDouble().takeIf { it.isFinite() && it >= 0.0 } else null
                val quality = classifyHeadingQuality(reportedAccuracy)
                val trueMatrix =
                    multiplyMatrices(
                        declinationCorrectionMatrix(declinationRad),
                        DoubleArray(9) { matrix[it].toDouble() },
                    )
                HeadingReplayEvent(
                    timestampNs = event.timestamp,
                    insertionIndex = nextInsertion(),
                    headingRad = NavguardAdaptiveFusionV2.normalizeHeading(atan2(east, north) + declinationRad),
                    quality = quality,
                    reportedAccuracyRad = reportedAccuracy,
                    trueEnuDevice = trueMatrix,
                )
            }.getOrNull()
        }

        override fun onLocationChanged(location: Location) {
            if (terminal.get() || location.provider != LocationManager.GPS_PROVIDER) return
            val timestamp = location.elapsedRealtimeNanos
            val isMock = isMockLocation(location)
            if (kind == SessionKind.DEVELOPMENT_BENCHMARK && denialStartNs == 0L) {
                val structurallyValid =
                    timestamp > 0L &&
                        location.latitude.isFinite() && location.latitude in -90.0..90.0 &&
                        location.longitude.isFinite() && location.longitude in -180.0..180.0
                val enu = if (structurallyValid) Wgs84EnuConverter.toHorizontalEnu(anchor, location) else null
                val accuracy =
                    if (location.hasAccuracy() && location.accuracy.isFinite()) {
                        location.accuracy.toDouble()
                    } else {
                        null
                    }
                val accepted =
                    gnssStabilization.record(
                        GnssStabilizationObservation(
                            timestampNs = timestamp,
                            eastM = enu?.eastM,
                            northM = enu?.northM,
                            reportedAccuracyM = accuracy,
                            isMock = isMock,
                            structurallyValid = structurallyValid && enu != null,
                        ),
                    )
                if (accepted) completeGnssStabilization(timeoutReached = false)
                return
            }
            val valid =
                timestamp > 0L && location.hasAccuracy() && location.accuracy.isFinite() &&
                    location.accuracy > 0.0f && location.accuracy <= NavguardAdaptiveFusionV2.MAX_OPERATIONAL_GNSS_ACCURACY_M
            val enu = if (valid) Wgs84EnuConverter.toHorizontalEnu(anchor, location) else null
            if (enu == null || isMock) return
            if (
                kind == SessionKind.DEVELOPMENT_BENCHMARK &&
                isWithinFormalBenchmarkWindow(timestamp, denialStartNs, benchmarkDeniedEndTimestampNs)
            ) {
                protectedGroundTruth.add(
                    GroundTruthPoint(timestamp, enu.eastM, enu.northM, location.accuracy.toDouble()),
                )
            }
        }

        private fun completeGnssStabilization(timeoutReached: Boolean) {
            if (terminal.get() || kind != SessionKind.DEVELOPMENT_BENCHMARK || denialStartNs != 0L) return
            val nowNs = SystemClock.elapsedRealtimeNanos()
            val decision = gnssStabilization.decide(nowNs, timeoutReached) ?: return
            gnssStabilizationDecision = decision
            val origin = decision.origin
            if (origin == null) {
                finishError(
                    ERROR_GNSS_STABILIZATION,
                    "Not enough stable GNSS fixes were available. Accepted: ${decision.acceptedFixCount} / minimum $MIN_STABILIZATION_FIX_COUNT.",
                    decision.toSanitizedMap(),
                )
                return
            }
            stableGnssOrigin = origin
            denialStartNs = nowNs
            benchmarkDeniedEndTimestampNs = nowNs + DEVELOPMENT_CAPTURE_DURATION_MS * 1_000_000L
            benchmarkFinalDrainEndTimestampNs =
                benchmarkDeniedEndTimestampNs + DEVELOPMENT_BENCHMARK_FINAL_DRAIN_MS * 1_000_000L
            worker?.postDelayed(
                ::finishSuccess,
                DEVELOPMENT_CAPTURE_DURATION_MS + DEVELOPMENT_BENCHMARK_FINAL_DRAIN_MS,
            )
        }

        private fun initializeArCore() {
            if (terminal.get()) return
            val session =
                try {
                    Session(applicationContext).also { arSession = it }
                } catch (_: Exception) {
                    worker?.post { finishError(ERROR_ARCORE_UNAVAILABLE, "Unable to create an Accuracy v2 ARCore session.") }
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
                arWorker?.post(::runNextArFrame)
            } catch (_: SecurityException) {
                worker?.post { finishError(ERROR_PERMISSION_REQUIRED, "Camera permission is required.") }
            } catch (_: Exception) {
                worker?.post { finishError(ERROR_ARCORE_UNAVAILABLE, "Unable to configure the Accuracy v2 ARCore session.") }
            }
        }

        private fun runNextArFrame() {
            if (terminal.get()) return
            val session = arSession ?: return
            val frame =
                try {
                    session.update()
                } catch (_: Exception) {
                    worker?.post { finishError(ERROR_ARCORE_UNAVAILABLE, "The Accuracy v2 ARCore session failed.") }
                    return
                }
            val tracking = frame.camera.trackingState == TrackingState.TRACKING
            val pose = if (tracking) runCatching { frame.androidSensorPose }.getOrNull() else null
            if (pose != null && isFinitePose(pose)) {
                if (initialArPose == null) {
                    initialArPose = pose
                    frozenTrueEnuDevice = latestTrueEnuDevice?.copyOf()
                }
                val originPose = initialArPose
                val transform = frozenTrueEnuDevice
                if (originPose != null && transform != null) {
                    val relative = runCatching { originPose.inverse().compose(pose) }.getOrNull()
                    if (relative != null && isFinitePose(relative)) {
                        val translation = FloatArray(3)
                        relative.getTranslation(translation, 0)
                        if (translation.all(Float::isFinite)) {
                            val delta =
                                multiplyMatrixVector(
                                    transform,
                                    doubleArrayOf(translation[0].toDouble(), translation[1].toDouble(), translation[2].toDouble()),
                                )
                            if (delta.all(Double::isFinite)) {
                                val timestamp = SystemClock.elapsedRealtimeNanos()
                                val previous = previousArTimestampNs
                                val gapMs = previous?.let { (timestamp - it).coerceAtLeast(0L) / 1_000_000.0 }
                                previousArTimestampNs = timestamp
                                val quality = classifyArcoreQuality(gapMs)
                                worker?.post {
                                    events.add(
                                        ArcoreReplayEvent(timestamp, nextInsertion(), delta[0], delta[1], quality, gapMs),
                                    )
                                }
                            }
                        }
                    }
                }
            }
            if (!terminal.get()) arWorker?.post(::runNextArFrame)
        }

        private fun finishSuccess() {
            if (!terminal.compareAndSet(false, true)) return
            try {
                val summary =
                    when (kind) {
                        SessionKind.CALIBRATION -> buildCalibrationSummary()
                        SessionKind.DEVELOPMENT_BENCHMARK -> buildDevelopmentBenchmarkSummary()
                    }
                cleanup()
                releaseSession(this)
                postSuccess(callback, summary)
            } catch (_: InsufficientGnssException) {
                val details = gnssStabilizationDecision?.toSanitizedMap()
                cleanup()
                releaseSession(this)
                postError(
                    callback,
                    ERROR_GNSS_STABILIZATION,
                    "Not enough stable GNSS fixes were available.",
                    details,
                )
            } catch (_: Exception) {
                cleanup()
                releaseSession(this)
                postError(callback, ERROR_INTERNAL, "Unable to finalize the Accuracy v2 aggregate result.")
            }
        }

        private fun buildCalibrationSummary(): Map<String, Any?> {
            val sorted = events.sortedWith(REPLAY_COMPARATOR)
            val profileBefore = NavguardCalibrationProfileStore.read()
            val initialHeading = sorted.filterIsInstance<HeadingReplayEvent>().firstOrNull()?.headingRad ?: 0.0
            val core = NavguardAdaptiveFusionV2(0.0, 0.0, initialHeading, profileBefore)
            var positionAtStationaryEnd: Pair<Double, Double>? = null
            var arAccepted = 0L
            var arRejected = 0L
            var stepsReceived = 0L
            var stepsApplied = 0L
            var stationaryObserved = false
            for (event in sorted) {
                when (event) {
                    is HeadingReplayEvent -> core.updateHeading(event.timestampNs, event.headingRad, event.quality, event.reportedAccuracyRad)
                    is StepReplayEvent -> {
                        if (event.calibrationPhase?.isMovement != false) {
                            stepsReceived += 1L
                            if (core.predictStep(event.timestampNs)) stepsApplied += 1L
                        }
                    }
                    is ArcoreReplayEvent -> {
                        val result =
                            core.updateArcore(
                                event.timestampNs,
                                event.eastM,
                                event.northM,
                                event.quality,
                                event.frameGapMs,
                                allowCalibrationLearning =
                                    calibrationPhaseForTimestamp(event.timestampNs, startedAtNs) !=
                                        CalibrationPhase.FINAL_DRAIN,
                            )
                        if (result.accepted) arAccepted += 1L else arRejected += 1L
                    }
                }
                stationaryObserved = stationaryObserved || core.stationaryDetected
                if (positionAtStationaryEnd == null && event.timestampNs >= startedAtNs + CALIBRATION_STATIONARY_PHASE_NS) {
                    positionAtStationaryEnd = core.eastM to core.northM
                }
            }
            core.tick(startedAtNs + CALIBRATION_TOTAL_DURATION_MS * 1_000_000L)
            val profileAfter = NavguardCalibrationProfileStore.replace(core.calibrationProfile())
            val diagnostics = core.diagnostics()
            val stationaryPosition = positionAtStationaryEnd ?: (core.eastM to core.northM)
            val stationaryDrift = hypot(stationaryPosition.first, stationaryPosition.second)
            return linkedMapOf(
                "schemaVersion" to SCHEMA_VERSION,
                "snapshotKind" to "navguard_accuracy_v2_calibration_result",
                "configId" to NavguardAdaptiveFusionV2.CONFIG_ID,
                "sessionLabel" to "DEVELOPMENT_CALIBRATION_SESSION",
                "stationaryDetected" to stationaryObserved,
                "stationaryCurrentlyDetected" to core.stationaryDetected,
                "stationaryEverDetected" to
                    (stationaryObserved || (diagnostics["stationaryEntryCount"] as? Long ?: 0L) > 0L),
                "stationaryEntryCount" to diagnostics["stationaryEntryCount"],
                "stationaryDetectedDurationMs" to diagnostics["stationaryDurationMs"],
                "stationaryCandidateCount" to diagnostics["stationaryCandidateCount"],
                "stationaryBlockedRecentStepCount" to diagnostics["stationaryBlockedRecentStepCount"],
                "stationaryBlockedHeadingMotionCount" to diagnostics["stationaryBlockedHeadingMotionCount"],
                "stationaryBlockedArcoreMotionCount" to diagnostics["stationaryBlockedArcoreMotionCount"],
                "stationaryBlockedOtherMotionCount" to diagnostics["stationaryBlockedOtherMotionCount"],
                "stationaryDriftM" to finiteOrZero(stationaryDrift),
                "stepsReceived" to stepsReceived,
                "stepsApplied" to stepsApplied,
                "finalDrainDurationMs" to CALIBRATION_FINAL_DRAIN_MS,
                "stepsReceivedDuringFinalDrainCallbackDelivery" to stepsReceivedDuringFinalDrainCallbackDelivery,
                "strideEstimateBeforeM" to profileBefore.strideEstimateM,
                "strideEstimateAfterM" to profileAfter.strideEstimateM,
                "strideCalibrationSamples" to (profileAfter.strideSampleCount - profileBefore.strideSampleCount).coerceAtLeast(0L),
                "headingOffsetBeforeDeg" to Math.toDegrees(profileBefore.bodyHeadingOffsetRad),
                "headingOffsetAfterDeg" to Math.toDegrees(profileAfter.bodyHeadingOffsetRad),
                "headingOffsetSamples" to (profileAfter.headingOffsetSampleCount - profileBefore.headingOffsetSampleCount).coerceAtLeast(0L),
                "arcoreAccepted" to arAccepted,
                "arcoreRejected" to arRejected,
                "arcoreNisMean" to diagnostics["arcoreNisMean"],
                "arcoreNisMax" to diagnostics["arcoreNisMax"],
                "arcorePreRobustNisMean" to diagnostics["arcorePreRobustNisMean"],
                "arcorePreRobustNisMax" to diagnostics["arcorePreRobustNisMax"],
                "arcorePostRobustNisMean" to diagnostics["arcorePostRobustNisMean"],
                "arcorePostRobustNisMax" to diagnostics["arcorePostRobustNisMax"],
                "arcoreAcceptedAfterRobustInflationCount" to diagnostics["arcoreAcceptedAfterRobustInflationCount"],
                "arcoreRejectedAfterMaxInflationCount" to diagnostics["arcoreRejectedAfterMaxInflationCount"],
                "headingAccepted" to diagnostics["headingAcceptedCount"],
                "headingRejected" to diagnostics["headingRejectedCount"],
                "sourceDisagreementMeanM" to diagnostics["sourceDisagreementMeanM"],
                "sourceDisagreementMaxM" to diagnostics["sourceDisagreementMaxM"],
                "profilePersisted" to NavguardCalibrationProfileStore.isPersisted(),
                "profilePersistence" to "android_shared_preferences",
                "rawLocationReturned" to false,
                "rawSensorStreamReturned" to false,
                "rawArcorePoseReturned" to false,
                "rawTimestampsReturned" to false,
                "rawTrajectoryReturned" to false,
                "accuracyValidated" to false,
            )
        }

        private fun buildDevelopmentBenchmarkSummary(): Map<String, Any?> {
            val stableOrigin = stableGnssOrigin ?: throw InsufficientGnssException()
            val stabilization = gnssStabilizationDecision ?: throw InsufficientGnssException()
            val scenario = developmentScenario?.takeIf { it in DEVELOPMENT_SCENARIOS } ?: throw IllegalStateException()
            val deniedEnd = benchmarkDeniedEndTimestampNs
            val sorted =
                events
                    .filter { isWithinFormalBenchmarkWindow(it.timestampNs, denialStartNs, deniedEnd) }
                    .sortedWith(REPLAY_COMPARATOR)
            val initialHeading =
                events.filterIsInstance<HeadingReplayEvent>().filter { it.timestampNs <= denialStartNs }.maxByOrNull { it.timestampNs }?.headingRad
                    ?: sorted.filterIsInstance<HeadingReplayEvent>().firstOrNull()?.headingRad
                    ?: 0.0
            val arAtDenial =
                events.filterIsInstance<ArcoreReplayEvent>().filter { it.timestampNs <= denialStartNs }.maxByOrNull { it.timestampNs }
            val arOriginEast = arAtDenial?.eastM ?: 0.0
            val arOriginNorth = arAtDenial?.northM ?: 0.0
            val aReplay = replayConfigA(sorted, stableOrigin, initialHeading)
            val d1Replay = replayConfigD1(sorted, stableOrigin, initialHeading, arOriginEast, arOriginNorth)
            val d2Replay = replayConfigD2(sorted, stableOrigin, initialHeading, arOriginEast, arOriginNorth)
            val gt =
                protectedGroundTruth
                    .filter { isWithinFormalBenchmarkWindow(it.timestampNs, denialStartNs, deniedEnd) }
                    .sortedBy { it.timestampNs }
            val aMetrics = calculateMetrics(CONFIG_A_ID, aReplay.snapshots, gt)
            val d1Metrics = calculateMetrics(CONFIG_D1_ID, d1Replay.snapshots, gt)
            val d2Metrics = calculateMetrics(NavguardAdaptiveFusionV2.CONFIG_ID, d2Replay.snapshots, gt)
            val d2VsD1 = improvementPercent(d1Metrics.medianHorizontalErrorM, d2Metrics.medianHorizontalErrorM)
            val d2VsA = improvementPercent(aMetrics.medianHorizontalErrorM, d2Metrics.medianHorizontalErrorM)
            val d2VsD1Relative =
                improvementPercent(d1Metrics.relativeMedianHorizontalErrorM, d2Metrics.relativeMedianHorizontalErrorM)
            val d2VsARelative =
                improvementPercent(aMetrics.relativeMedianHorizontalErrorM, d2Metrics.relativeMedianHorizontalErrorM)
            val d2Diagnostics = d2Replay.diagnostics
            val mutatedGt =
                gt.mapIndexed { index, point ->
                    point.copy(
                        eastM = point.eastM + 10_000.0 + index * 10.0,
                        northM = point.northM - 10_000.0 - index * 5.0,
                    )
                }
            val mutationReplay = replayConfigD2(sorted, stableOrigin, initialHeading, arOriginEast, arOriginNorth)
            val removalReplay = replayConfigD2(sorted, stableOrigin, initialHeading, arOriginEast, arOriginNorth)
            val mutationMetrics = calculateMetrics(NavguardAdaptiveFusionV2.CONFIG_ID, mutationReplay.snapshots, mutatedGt)
            val removalMetrics = calculateMetrics(NavguardAdaptiveFusionV2.CONFIG_ID, removalReplay.snapshots, emptyList())
            val mutationChangedComparator =
                gt.isEmpty() ||
                    mutationMetrics.medianHorizontalErrorM != d2Metrics.medianHorizontalErrorM ||
                    mutationMetrics.relativeMedianHorizontalErrorM != d2Metrics.relativeMedianHorizontalErrorM
            val gtMutationInvariant = sameEstimatorSnapshots(d2Replay.snapshots, mutationReplay.snapshots) && mutationChangedComparator
            val gtRemovalInvariant =
                sameEstimatorSnapshots(d2Replay.snapshots, removalReplay.snapshots) &&
                    removalMetrics.matchedGtCount == 0 &&
                    removalMetrics.medianHorizontalErrorM == null
            return linkedMapOf(
                "schemaVersion" to SCHEMA_VERSION,
                "snapshotKind" to "navguard_accuracy_v2_development_benchmark_result",
                "sessionLabel" to "DEVELOPMENT_SESSION_NOT_FINAL_VALIDATION",
                "developmentScenario" to scenario,
                "sameSessionCapture" to true,
                "eventOrdering" to "HEADING_STEP_ARCORE_POSITION_INSERTION_SEQUENCE",
                "developmentBenchmarkFinalDrainMs" to DEVELOPMENT_BENCHMARK_FINAL_DRAIN_MS,
                "benchmarkStepEventsReceivedTotal" to benchmarkStepEventsReceivedTotal,
                "benchmarkStepEventsInFormalWindow" to benchmarkStepEventsInFormalWindow,
                "benchmarkStepEventsDeliveredDuringFinalDrain" to benchmarkStepEventsDeliveredDuringFinalDrain,
                "benchmarkStepEventsIncludedFromFinalDrain" to benchmarkStepEventsIncludedFromFinalDrain,
                "benchmarkStepEventsExcludedPostWindow" to benchmarkStepEventsExcludedPostWindow,
                "configAStepsApplied" to aReplay.stepsApplied,
                "configD1StepsApplied" to d1Replay.stepsApplied,
                "configD2StepsApplied" to d2Replay.stepsApplied,
                "configA" to aMetrics.toMap(),
                "configD1" to d1Metrics.toMap(),
                "configD2" to d2Metrics.toMap(),
                "d2VsD1MedianImprovementPercent" to d2VsD1,
                "d2VsAMedianImprovementPercent" to d2VsA,
                "d2VsD1RelativeMedianImprovementPercent" to d2VsD1Relative,
                "d2VsARelativeMedianImprovementPercent" to d2VsARelative,
                "configAInitialMatchedBiasM" to aMetrics.initialMatchedBiasM,
                "configD1InitialMatchedBiasM" to d1Metrics.initialMatchedBiasM,
                "configD2InitialMatchedBiasM" to d2Metrics.initialMatchedBiasM,
                "strideEstimateFinalM" to d2Diagnostics["strideEstimateM"],
                "strideEstimateMeanM" to d2Diagnostics["strideMeanM"],
                "strideCalibrationSampleCount" to d2Diagnostics["strideCalibrationSampleCount"],
                "bodyHeadingOffsetFinalDeg" to d2Diagnostics["walkingHeadingOffsetDeg"],
                "arcoreAcceptedCount" to d2Diagnostics["arcoreAcceptedCount"],
                "arcoreAcceptedNominalCount" to d2Diagnostics["arcoreAcceptedNominalCount"],
                "arcoreAcceptedInflatedCount" to d2Diagnostics["arcoreAcceptedInflatedCount"],
                "arcoreRejectedByQualityCount" to d2Diagnostics["arcoreRejectedByQualityCount"],
                "arcoreRejectedByInnovationCount" to d2Diagnostics["arcoreRejectedByInnovationCount"],
                "arcoreAcceptedAfterRobustInflationCount" to d2Diagnostics["arcoreAcceptedAfterRobustInflationCount"],
                "arcoreRejectedAfterMaxInflationCount" to d2Diagnostics["arcoreRejectedAfterMaxInflationCount"],
                "arcorePreRobustNisMean" to d2Diagnostics["arcorePreRobustNisMean"],
                "arcorePreRobustNisMax" to d2Diagnostics["arcorePreRobustNisMax"],
                "arcorePostRobustNisMean" to d2Diagnostics["arcorePostRobustNisMean"],
                "arcorePostRobustNisMax" to d2Diagnostics["arcorePostRobustNisMax"],
                "arcoreAdaptiveSigmaMeanM" to d2Diagnostics["adaptiveArcoreSigmaMeanM"],
                "arcoreAdaptiveSigmaMaxM" to d2Diagnostics["adaptiveArcoreSigmaMaxM"],
                "arcoreRobustSigmaMeanM" to d2Diagnostics["arcoreRobustSigmaMeanM"],
                "arcoreRobustSigmaMaxM" to d2Diagnostics["arcoreRobustSigmaMaxM"],
                "headingAcceptedCount" to d2Diagnostics["headingAcceptedCount"],
                "headingRejectedCount" to d2Diagnostics["headingRejectedCount"],
                "stationaryDetectedDurationMs" to d2Diagnostics["stationaryDurationMs"],
                "stationaryEntryCount" to d2Diagnostics["stationaryEntryCount"],
                "stationaryCandidateCount" to d2Diagnostics["stationaryCandidateCount"],
                "stationaryBlockedRecentStepCount" to d2Diagnostics["stationaryBlockedRecentStepCount"],
                "stationaryBlockedHeadingMotionCount" to d2Diagnostics["stationaryBlockedHeadingMotionCount"],
                "stationaryBlockedArcoreMotionCount" to d2Diagnostics["stationaryBlockedArcoreMotionCount"],
                "stationaryBlockedOtherMotionCount" to d2Diagnostics["stationaryBlockedOtherMotionCount"],
                "stationaryArcoreSuppressedCount" to d2Diagnostics["stationaryArcoreSuppressedCount"],
                "sourceDisagreementMeanM" to d2Diagnostics["sourceDisagreementMeanM"],
                "sourceDisagreementMaxM" to d2Diagnostics["sourceDisagreementMaxM"],
                "gnssStabilizationFixCount" to stableOrigin.fixCount,
                "gnssStabilizationReceivedFixCount" to stabilization.receivedFixCount,
                "gnssStabilizationAcceptedFixCount" to stabilization.acceptedFixCount,
                "gnssStabilizationRejectedStructuralCount" to stabilization.rejectedStructuralCount,
                "gnssStabilizationRejectedAccuracyCount" to stabilization.rejectedAccuracyCount,
                "gnssStabilizationRejectedMockCount" to stabilization.rejectedMockCount,
                "gnssStabilizationRejectedNonMonotonicCount" to stabilization.rejectedNonMonotonicCount,
                "gnssStabilizationReportedAccuracyMinM" to stabilization.reportedAccuracyMinM,
                "gnssStabilizationReportedAccuracyMaxM" to stabilization.reportedAccuracyMaxM,
                "gnssStabilizationObservedDurationMs" to stabilization.observedDurationMs,
                "gnssStabilizationTargetFixCount" to TARGET_STABILIZATION_FIX_COUNT,
                "gnssStabilizationMinimumFixCount" to MIN_STABILIZATION_FIX_COUNT,
                "gnssStabilizationDegraded" to stabilization.degraded,
                "gnssStabilizationReason" to stabilization.reason,
                "gnssStabilizationEastSpreadM" to stableOrigin.eastSpreadM,
                "gnssStabilizationNorthSpreadM" to stableOrigin.northSpreadM,
                "gnssStabilizationHorizontalSpreadM" to stableOrigin.horizontalSpreadM,
                "gnssStabilizationReportedAccuracyMedianM" to stabilization.reportedAccuracyMedianM,
                "protectedGtEstimatorAccessCount" to 0,
                "gtMutationInvariant" to gtMutationInvariant,
                "gtRemovalInvariant" to gtRemovalInvariant,
                "protectedGroundTruthComparatorOnly" to true,
                "rawLocationReturned" to false,
                "rawSensorStreamReturned" to false,
                "rawArcorePoseReturned" to false,
                "rawTimestampsReturned" to false,
                "rawTrajectoryReturned" to false,
                "developmentMetricsOnly" to true,
                "finalValidation" to false,
                "accuracyValidated" to false,
            )
        }

        private fun replayConfigA(
            sorted: List<ReplayEvent>,
            origin: AdaptiveStableGnssOrigin,
            initialHeading: Double,
        ): ReplayOutput {
            var east = origin.eastM
            var north = origin.northM
            var heading = initialHeading
            var stepsApplied = 0L
            val snapshots = mutableListOf(EstimatorPoint(denialStartNs, east, north))
            for (event in sorted) {
                when (event) {
                    is HeadingReplayEvent -> heading = event.headingRad
                    is StepReplayEvent -> {
                        east += FIXED_V1_STRIDE_M * sin(heading)
                        north += FIXED_V1_STRIDE_M * cos(heading)
                        stepsApplied += 1L
                    }
                    is ArcoreReplayEvent -> Unit
                }
                snapshots.add(EstimatorPoint(event.timestampNs, east, north))
            }
            return ReplayOutput(snapshots, emptyMap(), stepsApplied)
        }

        private fun replayConfigD1(
            sorted: List<ReplayEvent>,
            origin: AdaptiveStableGnssOrigin,
            initialHeading: Double,
            arOriginEast: Double,
            arOriginNorth: Double,
        ): ReplayOutput {
            val filter = V1Filter(origin.eastM, origin.northM, initialHeading)
            var stepsApplied = 0L
            val snapshots = mutableListOf(EstimatorPoint(denialStartNs, filter.eastM, filter.northM))
            for (event in sorted) {
                when (event) {
                    is HeadingReplayEvent -> if (event.quality.isUsable) filter.updateHeading(event.headingRad, event.quality.multiplier)
                    is StepReplayEvent -> {
                        filter.predictStep()
                        stepsApplied += 1L
                    }
                    is ArcoreReplayEvent -> if (event.quality.isUsable) {
                        filter.updateArcore(
                            origin.eastM + event.eastM - arOriginEast,
                            origin.northM + event.northM - arOriginNorth,
                            event.quality.multiplier,
                        )
                    }
                }
                snapshots.add(EstimatorPoint(event.timestampNs, filter.eastM, filter.northM))
            }
            return ReplayOutput(snapshots, emptyMap(), stepsApplied)
        }

        private fun replayConfigD2(
            sorted: List<ReplayEvent>,
            origin: AdaptiveStableGnssOrigin,
            initialHeading: Double,
            arOriginEast: Double,
            arOriginNorth: Double,
        ): ReplayOutput {
            val core = NavguardAdaptiveFusionV2(origin.eastM, origin.northM, initialHeading)
            var stepsApplied = 0L
            val snapshots = mutableListOf(EstimatorPoint(denialStartNs, core.eastM, core.northM))
            for (event in sorted) {
                when (event) {
                    is HeadingReplayEvent -> core.updateHeading(event.timestampNs, event.headingRad, event.quality, event.reportedAccuracyRad)
                    is StepReplayEvent -> if (core.predictStep(event.timestampNs)) stepsApplied += 1L
                    is ArcoreReplayEvent ->
                        core.updateArcore(
                            event.timestampNs,
                            origin.eastM + event.eastM - arOriginEast,
                            origin.northM + event.northM - arOriginNorth,
                            event.quality,
                            event.frameGapMs,
                        )
                }
                snapshots.add(EstimatorPoint(event.timestampNs, core.eastM, core.northM))
            }
            core.tick(benchmarkDeniedEndTimestampNs)
            return ReplayOutput(snapshots, core.diagnostics(), stepsApplied)
        }

        private fun calculateMetrics(
            configId: String,
            snapshots: List<EstimatorPoint>,
            gt: List<GroundTruthPoint>,
        ): ConfigMetrics = calculateComparatorMetrics(configId, snapshots, gt)

        private fun sameEstimatorSnapshots(
            first: List<EstimatorPoint>,
            second: List<EstimatorPoint>,
        ): Boolean =
            first.size == second.size &&
                first.indices.all { index ->
                    first[index].timestampNs == second[index].timestampNs &&
                        first[index].eastM == second[index].eastM &&
                        first[index].northM == second[index].northM
                }

        private fun finishError(
            code: String,
            message: String,
            details: Map<String, Any?>? = null,
        ) {
            if (!terminal.compareAndSet(false, true)) return
            cleanup()
            releaseSession(this)
            postError(callback, code, message, details)
        }

        private fun cleanup() {
            if (locationRegistered) runCatching { locationManager.removeUpdates(this) }
            locationRegistered = false
            if (listenersRegistered) runCatching { sensorManager.unregisterListener(this) }
            listenersRegistered = false
            worker?.removeCallbacksAndMessages(null)
            arWorker?.removeCallbacksAndMessages(null)
            arWorker?.post(::cleanupArCore)
            workerThread.quitSafely()
            events.clear()
            gnssStabilization.clear()
            acceptedStepTimestamps.clear()
            protectedGroundTruth.clear()
        }

        private fun cleanupArCore() {
            runCatching { if (arSessionResumed) arSession?.pause() }
            arSessionResumed = false
            runCatching { arSession?.close() }
            arSession = null
            initialArPose = null
            frozenTrueEnuDevice = null
            runCatching { glEnvironment.release() }
            if (arThread.isAlive) arThread.quitSafely()
        }

        private fun nextInsertion(): Long = insertionSequence++
    }

    private fun hasPermission(permission: String): Boolean =
        ContextCompat.checkSelfPermission(applicationContext, permission) == PackageManager.PERMISSION_GRANTED

    private fun readArCoreAvailability(): AvailabilitySnapshot {
        val availability = runCatching { ArCoreApk.getInstance().checkAvailability(applicationContext) }.getOrNull()
        return AvailabilitySnapshot(
            supported = availability != null && availability != ArCoreApk.Availability.UNSUPPORTED_DEVICE_NOT_CAPABLE,
            installed = availability == ArCoreApk.Availability.SUPPORTED_INSTALLED,
        )
    }

    private fun postSuccess(
        callback: Callback,
        summary: Map<String, Any?>,
    ) = mainHandler.post { callback.onSuccess(summary) }

    private fun postError(
        callback: Callback,
        code: String,
        message: String,
        details: Map<String, Any?>? = null,
    ) = mainHandler.post { callback.onError(code, message, details) }

    private enum class SessionKind {
        CALIBRATION,
        DEVELOPMENT_BENCHMARK,
    }

    private enum class CalibrationPhase(val isMovement: Boolean) {
        STATIONARY(false),
        STRAIGHT(true),
        TURN_AND_POST_TURN(true),
        FINAL_DRAIN(false),
        OUTSIDE(false),
    }

    private data class AvailabilitySnapshot(
        val supported: Boolean,
        val installed: Boolean,
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

    private data class GroundTruthPoint(
        val timestampNs: Long,
        val eastM: Double,
        val northM: Double,
        val reportedAccuracyM: Double,
    )

    private data class GnssStabilizationObservation(
        val timestampNs: Long,
        val eastM: Double?,
        val northM: Double?,
        val reportedAccuracyM: Double?,
        val isMock: Boolean,
        val structurallyValid: Boolean,
    )

    private data class GnssStabilizationDecision(
        val origin: AdaptiveStableGnssOrigin?,
        val receivedFixCount: Int,
        val acceptedFixCount: Int,
        val rejectedStructuralCount: Int,
        val rejectedAccuracyCount: Int,
        val rejectedMockCount: Int,
        val rejectedNonMonotonicCount: Int,
        val reportedAccuracyMinM: Double?,
        val reportedAccuracyMedianM: Double?,
        val reportedAccuracyMaxM: Double?,
        val observedDurationMs: Long,
        val degraded: Boolean,
        val reason: String,
    ) {
        fun toSanitizedMap(): Map<String, Any?> =
            linkedMapOf(
                "schemaVersion" to SCHEMA_VERSION,
                "snapshotKind" to "navguard_accuracy_v2_gnss_stabilization_diagnostics",
                "gnssStabilizationReceivedFixCount" to receivedFixCount,
                "gnssStabilizationAcceptedFixCount" to acceptedFixCount,
                "gnssStabilizationRejectedStructuralCount" to rejectedStructuralCount,
                "gnssStabilizationRejectedAccuracyCount" to rejectedAccuracyCount,
                "gnssStabilizationRejectedMockCount" to rejectedMockCount,
                "gnssStabilizationRejectedNonMonotonicCount" to rejectedNonMonotonicCount,
                "gnssStabilizationReportedAccuracyMinM" to reportedAccuracyMinM,
                "gnssStabilizationReportedAccuracyMedianM" to reportedAccuracyMedianM,
                "gnssStabilizationReportedAccuracyMaxM" to reportedAccuracyMaxM,
                "gnssStabilizationObservedDurationMs" to observedDurationMs,
                "gnssStabilizationTargetFixCount" to TARGET_STABILIZATION_FIX_COUNT,
                "gnssStabilizationMinimumFixCount" to MIN_STABILIZATION_FIX_COUNT,
                "gnssStabilizationDegraded" to degraded,
                "gnssStabilizationReason" to reason,
                "rawCoordinatesReturned" to false,
                "rawTimestampsReturned" to false,
            )
    }

    private class GnssStabilizationAccumulator {
        private val candidates = mutableListOf<AdaptiveGnssOriginCandidate>()
        private val reportedAccuracies = mutableListOf<Double>()
        private var lastAcceptedTimestampNs = 0L
        private var firstAcceptedTimestampNs = 0L
        private var receivedFixCount = 0
        private var rejectedStructuralCount = 0
        private var rejectedAccuracyCount = 0
        private var rejectedMockCount = 0
        private var rejectedNonMonotonicCount = 0

        fun record(observation: GnssStabilizationObservation): Boolean {
            receivedFixCount += 1
            if (!observation.structurallyValid || observation.timestampNs <= 0L ||
                observation.eastM?.isFinite() != true || observation.northM?.isFinite() != true
            ) {
                rejectedStructuralCount += 1
                return false
            }
            val accuracy = observation.reportedAccuracyM
            if (accuracy != null && accuracy.isFinite() && accuracy > 0.0) {
                reportedAccuracies.add(accuracy)
            }
            if (accuracy == null || !accuracy.isFinite() || accuracy <= 0.0 ||
                accuracy > NavguardAdaptiveFusionV2.MAX_OPERATIONAL_GNSS_ACCURACY_M
            ) {
                rejectedAccuracyCount += 1
                return false
            }
            if (observation.isMock) {
                rejectedMockCount += 1
                return false
            }
            if (lastAcceptedTimestampNs > 0L && observation.timestampNs <= lastAcceptedTimestampNs) {
                rejectedNonMonotonicCount += 1
                return false
            }
            if (firstAcceptedTimestampNs == 0L) firstAcceptedTimestampNs = observation.timestampNs
            lastAcceptedTimestampNs = observation.timestampNs
            candidates.add(
                AdaptiveGnssOriginCandidate(
                    observation.timestampNs,
                    checkNotNull(observation.eastM),
                    checkNotNull(observation.northM),
                    accuracy,
                    false,
                ),
            )
            while (candidates.size > MAX_GNSS_CANDIDATES) candidates.removeAt(0)
            return true
        }

        fun decide(
            nowNs: Long,
            timeoutReached: Boolean,
        ): GnssStabilizationDecision? {
            val durationMs = observedDurationMs()
            val targetMet =
                candidates.size >= TARGET_STABILIZATION_FIX_COUNT &&
                    durationMs >= MIN_STABILIZATION_OBSERVATION_MS
            if (!timeoutReached && !targetMet) return null
            val enoughForDegraded = candidates.size >= MIN_STABILIZATION_FIX_COUNT
            val origin =
                if (enoughForDegraded) {
                    NavguardAdaptiveFusionV2.computeStableGnssOrigin(
                        candidates,
                        lastAcceptedTimestampNs.coerceAtMost(nowNs),
                        GNSS_STABILIZATION_TIMEOUT_MS,
                        MIN_STABILIZATION_FIX_COUNT,
                    )
                } else {
                    null
                }
            val degraded = origin != null && candidates.size < TARGET_STABILIZATION_FIX_COUNT
            val reason =
                when {
                    origin == null -> "accepted_below_minimum"
                    degraded -> "accepted_less_than_target"
                    else -> "target_met"
                }
            val sortedAccuracy = reportedAccuracies.sorted()
            return GnssStabilizationDecision(
                origin = origin,
                receivedFixCount = receivedFixCount,
                acceptedFixCount = candidates.size,
                rejectedStructuralCount = rejectedStructuralCount,
                rejectedAccuracyCount = rejectedAccuracyCount,
                rejectedMockCount = rejectedMockCount,
                rejectedNonMonotonicCount = rejectedNonMonotonicCount,
                reportedAccuracyMinM = sortedAccuracy.firstOrNull(),
                reportedAccuracyMedianM = sortedAccuracy.takeIf { it.isNotEmpty() }?.let(::median),
                reportedAccuracyMaxM = sortedAccuracy.lastOrNull(),
                observedDurationMs = durationMs,
                degraded = degraded,
                reason = reason,
            )
        }

        fun clear() {
            candidates.clear()
            reportedAccuracies.clear()
        }

        private fun observedDurationMs(): Long =
            if (firstAcceptedTimestampNs == 0L || lastAcceptedTimestampNs < firstAcceptedTimestampNs) {
                0L
            } else {
                (lastAcceptedTimestampNs - firstAcceptedTimestampNs) / 1_000_000L
            }
    }

    private data class EstimatorPoint(
        val timestampNs: Long,
        val eastM: Double,
        val northM: Double,
    )

    private data class ReplayOutput(
        val snapshots: List<EstimatorPoint>,
        val diagnostics: Map<String, Any?>,
        val stepsApplied: Long,
    )

    private data class ConfigMetrics(
        val configId: String,
        val matchedGtCount: Int,
        val meanHorizontalErrorM: Double?,
        val medianHorizontalErrorM: Double?,
        val p95HorizontalErrorM: Double?,
        val maxHorizontalErrorM: Double?,
        val finalPreCorrectionHorizontalErrorM: Double?,
        val relativeMeanHorizontalErrorM: Double?,
        val relativeMedianHorizontalErrorM: Double?,
        val relativeP95HorizontalErrorM: Double?,
        val relativeMaxHorizontalErrorM: Double?,
        val relativeFinalHorizontalErrorM: Double?,
        val initialMatchedBiasM: Double?,
    ) {
        fun toMap(): Map<String, Any?> =
            linkedMapOf(
                "configId" to configId,
                "matchedGtCount" to matchedGtCount,
                "meanHorizontalErrorM" to meanHorizontalErrorM,
                "medianHorizontalErrorM" to medianHorizontalErrorM,
                "p95HorizontalErrorM" to p95HorizontalErrorM,
                "maxHorizontalErrorM" to maxHorizontalErrorM,
                "finalPreCorrectionHorizontalErrorM" to finalPreCorrectionHorizontalErrorM,
                "relativeMeanHorizontalErrorM" to relativeMeanHorizontalErrorM,
                "relativeMedianHorizontalErrorM" to relativeMedianHorizontalErrorM,
                "relativeP95HorizontalErrorM" to relativeP95HorizontalErrorM,
                "relativeMaxHorizontalErrorM" to relativeMaxHorizontalErrorM,
                "relativeFinalHorizontalErrorM" to relativeFinalHorizontalErrorM,
            )
    }

    private sealed class ReplayEvent(
        val timestampNs: Long,
        val insertionIndex: Long,
        val priority: Int,
    )

    private class HeadingReplayEvent(
        timestampNs: Long,
        insertionIndex: Long,
        val headingRad: Double,
        val quality: AdaptiveSourceQuality,
        val reportedAccuracyRad: Double?,
        val trueEnuDevice: DoubleArray,
    ) : ReplayEvent(timestampNs, insertionIndex, 0)

    private class StepReplayEvent(
        timestampNs: Long,
        insertionIndex: Long,
        val calibrationPhase: CalibrationPhase?,
    ) : ReplayEvent(timestampNs, insertionIndex, 1)

    private class ArcoreReplayEvent(
        timestampNs: Long,
        insertionIndex: Long,
        val eastM: Double,
        val northM: Double,
        val quality: AdaptiveSourceQuality,
        val frameGapMs: Double?,
    ) : ReplayEvent(timestampNs, insertionIndex, 2)

    private class V1Filter(
        initialEastM: Double,
        initialNorthM: Double,
        initialHeadingRad: Double,
    ) {
        private val x = doubleArrayOf(initialEastM, initialNorthM, NavguardAdaptiveFusionV2.normalizeHeading(initialHeadingRad))
        private var p = doubleArrayOf(0.01, 0.0, 0.0, 0.0, 0.01, 0.0, 0.0, 0.0, BASE_HEADING_SIGMA_RAD * BASE_HEADING_SIGMA_RAD)
        val eastM: Double get() = x[0]
        val northM: Double get() = x[1]

        fun predictStep() {
            val heading = x[2]
            x[0] += FIXED_V1_STRIDE_M * sin(heading)
            x[1] += FIXED_V1_STRIDE_M * cos(heading)
            p[0] += 0.04
            p[4] += 0.04
            p[8] += Math.toRadians(5.0).let { it * it }
        }

        fun updateHeading(
            measured: Double,
            multiplier: Double,
        ) {
            val r = BASE_HEADING_SIGMA_RAD * BASE_HEADING_SIGMA_RAD * multiplier
            val gain = p[8] / (p[8] + r)
            x[2] = NavguardAdaptiveFusionV2.normalizeHeading(x[2] + gain * NavguardAdaptiveFusionV2.circularDifference(measured, x[2]))
            p[8] = ((1.0 - gain) * p[8]).coerceAtLeast(0.0)
        }

        fun updateArcore(
            eastM: Double,
            northM: Double,
            multiplier: Double,
        ) {
            val r = BASE_ARCORE_SIGMA_M * BASE_ARCORE_SIGMA_M * multiplier
            val eastGain = p[0] / (p[0] + r)
            val northGain = p[4] / (p[4] + r)
            x[0] += eastGain * (eastM - x[0])
            x[1] += northGain * (northM - x[1])
            p[0] = ((1.0 - eastGain) * p[0]).coerceAtLeast(0.0)
            p[4] = ((1.0 - northGain) * p[4]).coerceAtLeast(0.0)
        }
    }

    private class InsufficientGnssException : RuntimeException()

    private class GlEnvironment {
        private var display: EGLDisplay = EGL14.EGL_NO_DISPLAY
        private var context: EGLContext = EGL14.EGL_NO_CONTEXT
        private var surface: EGLSurface = EGL14.EGL_NO_SURFACE
        private var textureName = 0

        fun initialize() {
            display = EGL14.eglGetDisplay(EGL14.EGL_DEFAULT_DISPLAY)
            check(display != EGL14.EGL_NO_DISPLAY)
            val versions = IntArray(2)
            check(EGL14.eglInitialize(display, versions, 0, versions, 1))
            val attributes =
                intArrayOf(
                    EGL14.EGL_RENDERABLE_TYPE, EGL14.EGL_OPENGL_ES2_BIT,
                    EGL14.EGL_SURFACE_TYPE, EGL14.EGL_PBUFFER_BIT,
                    EGL14.EGL_RED_SIZE, 8,
                    EGL14.EGL_GREEN_SIZE, 8,
                    EGL14.EGL_BLUE_SIZE, 8,
                    EGL14.EGL_ALPHA_SIZE, 8,
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
        }

        fun createExternalOesTexture(): Int {
            val textures = IntArray(1)
            GLES20.glGenTextures(1, textures, 0)
            textureName = textures[0]
            check(textureName != 0)
            GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, textureName)
            GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR)
            GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR)
            GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE)
            GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE)
            return textureName
        }

        fun release() {
            if (display != EGL14.EGL_NO_DISPLAY) {
                if (textureName != 0) GLES20.glDeleteTextures(1, intArrayOf(textureName), 0)
                EGL14.eglMakeCurrent(display, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_CONTEXT)
                if (surface != EGL14.EGL_NO_SURFACE) EGL14.eglDestroySurface(display, surface)
                if (context != EGL14.EGL_NO_CONTEXT) EGL14.eglDestroyContext(display, context)
                EGL14.eglTerminate(display)
            }
            EGL14.eglReleaseThread()
            display = EGL14.EGL_NO_DISPLAY
            context = EGL14.EGL_NO_CONTEXT
            surface = EGL14.EGL_NO_SURFACE
            textureName = 0
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
            val east = -sin(longitude) * dx + cos(longitude) * dy
            val north = -sin(latitude) * cos(longitude) * dx - sin(latitude) * sin(longitude) * dy + cos(latitude) * dz
            return if (east.isFinite() && north.isFinite()) EnuFix(location.elapsedRealtimeNanos, east, north) else null
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
                (radius * (1.0 - WGS84_ECCENTRICITY_SQUARED) + altitudeM) * sinLatitude,
            )
        }
    }

    private companion object {
        const val SCHEMA_VERSION = 1
        const val CONFIG_A_ID = "config_a_deterministic_pdr"
        const val CONFIG_D1_ID = "config_d_navguard_ekf_v1"
        const val FIXED_V1_STRIDE_M = 0.75
        const val BASE_ARCORE_SIGMA_M = 0.35
        val BASE_HEADING_SIGMA_RAD: Double = Math.toRadians(15.0)
        const val ROTATION_VECTOR_SAMPLING_PERIOD_US = 20_000
        const val GNSS_MIN_TIME_MS = 1_000L
        const val GNSS_STABILIZATION_TIMEOUT_MS = 20_000L
        const val TARGET_STABILIZATION_FIX_COUNT = 5
        const val MIN_STABILIZATION_FIX_COUNT = 3
        const val MIN_STABILIZATION_OBSERVATION_MS = 5_000L
        const val CALIBRATION_STATIONARY_PHASE_NS = 8_000_000_000L
        const val CALIBRATION_STRAIGHT_PHASE_END_MS = 28_000L
        const val CALIBRATION_MOVEMENT_DURATION_MS = 48_000L
        const val CALIBRATION_FINAL_DRAIN_MS = 12_000L
        const val CALIBRATION_TOTAL_DURATION_MS = CALIBRATION_MOVEMENT_DURATION_MS + CALIBRATION_FINAL_DRAIN_MS
        const val CALIBRATION_EVENT_HISTORY_MS = 12_000L
        const val DEVELOPMENT_CAPTURE_DURATION_MS = 30_000L
        const val DEVELOPMENT_BENCHMARK_FINAL_DRAIN_MS = 12_000L
        const val MAX_GNSS_CANDIDATES = 32
        const val WGS84_SEMI_MAJOR_AXIS_M = 6_378_137.0
        const val WGS84_ECCENTRICITY_SQUARED = 6.69437999014e-3
        const val TWO_PI = 2.0 * PI

        const val ERROR_ALREADY_RUNNING = "navguard_accuracy_v2_already_running"
        const val ERROR_ANCHOR_REQUIRED = "navguard_accuracy_v2_anchor_required"
        const val ERROR_NOT_READY = "navguard_accuracy_v2_not_ready"
        const val ERROR_PERMISSION_REQUIRED = "navguard_accuracy_v2_permission_required"
        const val ERROR_SENSOR_REGISTRATION = "navguard_accuracy_v2_sensor_registration_failed"
        const val ERROR_ARCORE_UNAVAILABLE = "navguard_accuracy_v2_arcore_unavailable"
        const val ERROR_GNSS_STABILIZATION = "navguard_accuracy_v2_gnss_stabilization_insufficient"
        const val ERROR_INVALID_SCENARIO = "navguard_accuracy_v2_invalid_development_scenario"
        const val ERROR_INTERNAL = "navguard_accuracy_v2_internal_error"

        val DEVELOPMENT_SCENARIOS = setOf("STRAIGHT", "L_TURN", "MIXED")

        val REPLAY_COMPARATOR =
            Comparator<ReplayEvent> { first, second ->
                val timestamp = first.timestampNs.compareTo(second.timestampNs)
                if (timestamp != 0) timestamp else {
                    val priority = first.priority.compareTo(second.priority)
                    if (priority != 0) priority else first.insertionIndex.compareTo(second.insertionIndex)
                }
            }

        fun calibrationPhaseForTimestamp(
            timestampNs: Long,
            startedAtNs: Long,
        ): CalibrationPhase {
            if (timestampNs < startedAtNs || startedAtNs <= 0L) return CalibrationPhase.OUTSIDE
            val elapsedNs = timestampNs - startedAtNs
            return when {
                elapsedNs < CALIBRATION_STATIONARY_PHASE_NS -> CalibrationPhase.STATIONARY
                elapsedNs < CALIBRATION_STRAIGHT_PHASE_END_MS * 1_000_000L -> CalibrationPhase.STRAIGHT
                elapsedNs <= CALIBRATION_MOVEMENT_DURATION_MS * 1_000_000L -> CalibrationPhase.TURN_AND_POST_TURN
                elapsedNs < CALIBRATION_TOTAL_DURATION_MS * 1_000_000L -> CalibrationPhase.FINAL_DRAIN
                else -> CalibrationPhase.OUTSIDE
            }
        }

        fun shouldAcceptCalibrationStep(
            eventTimestampNs: Long,
            callbackTimestampNs: Long,
            startedAtNs: Long,
        ): Boolean {
            val phase = calibrationPhaseForTimestamp(eventTimestampNs, startedAtNs)
            if (!phase.isMovement || callbackTimestampNs < eventTimestampNs) return false
            val latencyNs = callbackTimestampNs - eventTimestampNs
            val sessionEndNs = startedAtNs + CALIBRATION_TOTAL_DURATION_MS * 1_000_000L
            return latencyNs <= CALIBRATION_EVENT_HISTORY_MS * 1_000_000L && callbackTimestampNs <= sessionEndNs
        }

        fun isWithinFormalBenchmarkWindow(
            eventTimestampNs: Long,
            denialStartNs: Long,
            deniedEndTimestampNs: Long,
        ): Boolean =
            denialStartNs > 0L &&
                deniedEndTimestampNs >= denialStartNs &&
                eventTimestampNs in denialStartNs..deniedEndTimestampNs

        fun isBenchmarkFinalDrainDelivery(
            callbackTimestampNs: Long,
            deniedEndTimestampNs: Long,
            drainEndTimestampNs: Long,
        ): Boolean =
            deniedEndTimestampNs > 0L &&
                drainEndTimestampNs >= deniedEndTimestampNs &&
                callbackTimestampNs > deniedEndTimestampNs &&
                callbackTimestampNs <= drainEndTimestampNs

        fun remainingWholeSeconds(
            endTimestampNs: Long,
            nowTimestampNs: Long,
        ): Long = ceil((endTimestampNs - nowTimestampNs).coerceAtLeast(0L) / 1_000_000_000.0).toLong()

        fun runTargetedLifecycleSelfTests(): Map<String, Boolean> {
            val startNs = 1_000_000_000L
            val delayedStepNs = startNs + 45_000_000_000L
            val callbackNs = startNs + 55_500_000_000L
            val delayedAccepted = shouldAcceptCalibrationStep(delayedStepNs, callbackNs, startNs)
            val historicalPhase =
                calibrationPhaseForTimestamp(delayedStepNs, startNs) == CalibrationPhase.TURN_AND_POST_TURN &&
                    calibrationPhaseForTimestamp(callbackNs, startNs) == CalibrationPhase.FINAL_DRAIN
            val tooLateRejected =
                !shouldAcceptCalibrationStep(
                    startNs + 43_000_000_000L,
                    startNs + 55_500_000_000L,
                    startNs,
                )
            val seenSteps = linkedSetOf<Long>()
            val noDuplicate = seenSteps.add(delayedStepNs) && !seenSteps.add(delayedStepNs)
            val orderingEvents =
                listOf(
                    HeadingReplayEvent(delayedStepNs + 1L, 2L, 0.1, AdaptiveSourceQuality.GOOD, 0.1, DoubleArray(9)),
                    StepReplayEvent(delayedStepNs, 1L, CalibrationPhase.TURN_AND_POST_TURN),
                    HeadingReplayEvent(delayedStepNs - 1L, 0L, 0.0, AdaptiveSourceQuality.GOOD, 0.1, DoubleArray(9)),
                ).sortedWith(REPLAY_COMPARATOR)
            val noFutureHeading =
                orderingEvents[0] is HeadingReplayEvent &&
                    orderingEvents[1] is StepReplayEvent &&
                    orderingEvents[2] is HeadingReplayEvent
            val drainLearningSuppressed =
                calibrationPhaseForTimestamp(startNs + 50_000_000_000L, startNs) == CalibrationPhase.FINAL_DRAIN

            val benchmarkStartNs = startNs
            val benchmarkEndNs = benchmarkStartNs + DEVELOPMENT_CAPTURE_DURATION_MS * 1_000_000L
            val benchmarkDrainEndNs =
                benchmarkEndNs + DEVELOPMENT_BENCHMARK_FINAL_DRAIN_MS * 1_000_000L
            val delayedInWindowEventNs = benchmarkStartNs + 25_000_000_000L
            val delayedInWindowCallbackNs = benchmarkStartNs + 34_000_000_000L
            val benchmarkDelayedInWindow =
                isWithinFormalBenchmarkWindow(delayedInWindowEventNs, benchmarkStartNs, benchmarkEndNs) &&
                    isBenchmarkFinalDrainDelivery(
                        delayedInWindowCallbackNs,
                        benchmarkEndNs,
                        benchmarkDrainEndNs,
                    )
            val postWindowEventNs = benchmarkStartNs + 31_000_000_000L
            val benchmarkPostWindowExcluded =
                !isWithinFormalBenchmarkWindow(postWindowEventNs, benchmarkStartNs, benchmarkEndNs) &&
                    isBenchmarkFinalDrainDelivery(
                        benchmarkStartNs + 36_000_000_000L,
                        benchmarkEndNs,
                        benchmarkDrainEndNs,
                    )
            val delayedBenchmarkSteps =
                listOf(29L, 21L, 25L, 25L)
                    .map { seconds -> benchmarkStartNs + seconds * 1_000_000_000L }
                    .filter { timestamp ->
                        isWithinFormalBenchmarkWindow(timestamp, benchmarkStartNs, benchmarkEndNs)
                    }.distinct()
                    .sorted()
            val benchmarkMultipleDelayed =
                delayedBenchmarkSteps ==
                    listOf(
                        benchmarkStartNs + 21_000_000_000L,
                        benchmarkStartNs + 25_000_000_000L,
                        benchmarkStartNs + 29_000_000_000L,
                    )
            val benchmarkGtWindowBounded =
                isWithinFormalBenchmarkWindow(benchmarkEndNs, benchmarkStartNs, benchmarkEndNs) &&
                    !isWithinFormalBenchmarkWindow(
                        benchmarkEndNs + 1_000_000_000L,
                        benchmarkStartNs,
                        benchmarkEndNs,
                    )
            val fairStepInputCount = delayedBenchmarkSteps.size.toLong()
            val benchmarkFairStepInput =
                fairStepInputCount == 3L &&
                    listOf(fairStepInputCount, fairStepInputCount, fairStepInputCount).distinct().size == 1

            val offsetSnapshots =
                listOf(
                    EstimatorPoint(1_000_000_000L, 10.0, 0.0),
                    EstimatorPoint(2_000_000_000L, 11.0, 0.0),
                    EstimatorPoint(3_000_000_000L, 12.0, 0.0),
                    EstimatorPoint(4_000_000_000L, 999.0, 999.0),
                )
            val offsetGroundTruth =
                listOf(
                    GroundTruthPoint(1_000_000_000L, 0.0, 0.0, 5.0),
                    GroundTruthPoint(2_000_000_000L, 1.0, 0.0, 5.0),
                    GroundTruthPoint(3_000_000_000L, 2.0, 0.0, 5.0),
                )
            val offsetMetrics = calculateComparatorMetrics("relative_test", offsetSnapshots, offsetGroundTruth)
            val relativeConstantOffsetRemoved =
                offsetMetrics.medianHorizontalErrorM?.let { abs(it - 10.0) < 1e-9 } == true &&
                    offsetMetrics.relativeMedianHorizontalErrorM?.let { abs(it) < 1e-9 } == true &&
                    offsetMetrics.initialMatchedBiasM?.let { abs(it - 10.0) < 1e-9 } == true
            val relativeCausalMatching =
                offsetMetrics.matchedGtCount == 3 &&
                    offsetMetrics.relativeFinalHorizontalErrorM?.let { abs(it) < 1e-9 } == true
            val mutatedRelativeGroundTruth =
                offsetGroundTruth.mapIndexed { index, point ->
                    point.copy(eastM = point.eastM + index * 2.0)
                }
            val mutatedRelativeMetrics =
                calculateComparatorMetrics("relative_test", offsetSnapshots, mutatedRelativeGroundTruth)
            val removedRelativeMetrics = calculateComparatorMetrics("relative_test", offsetSnapshots, emptyList())
            val relativeGtFirewall =
                mutatedRelativeMetrics.relativeMedianHorizontalErrorM != offsetMetrics.relativeMedianHorizontalErrorM &&
                    removedRelativeMetrics.matchedGtCount == 0 &&
                    removedRelativeMetrics.relativeMedianHorizontalErrorM == null

            fun observation(
                seconds: Long,
                eastM: Double,
                northM: Double,
                accuracyM: Double = 5.0,
            ): GnssStabilizationObservation =
                GnssStabilizationObservation(
                    timestampNs = startNs + seconds * 1_000_000_000L,
                    eastM = eastM,
                    northM = northM,
                    reportedAccuracyM = accuracyM,
                    isMock = false,
                    structurallyValid = true,
                )

            val targetAccumulator = GnssStabilizationAccumulator()
            listOf(
                observation(0L, 1.0, 2.0),
                observation(1L, 1.1, 2.1),
                observation(2L, 0.9, 1.9),
                observation(3L, 100.0, -100.0),
                observation(5L, 1.05, 2.05),
            ).forEach(targetAccumulator::record)
            val targetDecision = targetAccumulator.decide(startNs + 5_000_000_000L, timeoutReached = false)
            val targetSuccess =
                targetDecision?.origin != null && !targetDecision.degraded && targetDecision.reason == "target_met"
            val robustMedian =
                targetDecision?.origin?.let { abs(it.eastM - 1.05) < 0.2 && abs(it.northM - 2.0) < 0.2 } == true

            val degradedAccumulator = GnssStabilizationAccumulator()
            listOf(observation(0L, 0.0, 0.0), observation(5L, 0.1, 0.1), observation(10L, -0.1, -0.1))
                .forEach(degradedAccumulator::record)
            val degradedDecision = degradedAccumulator.decide(startNs + 20_000_000_000L, timeoutReached = true)
            val degradedSuccess =
                degradedDecision?.origin != null &&
                    degradedDecision.degraded &&
                    degradedDecision.reason == "accepted_less_than_target"

            val insufficientAccumulator = GnssStabilizationAccumulator()
            insufficientAccumulator.record(observation(0L, 0.0, 0.0))
            insufficientAccumulator.record(observation(1L, 0.1, 0.1))
            repeat(4) { index ->
                insufficientAccumulator.record(observation(2L + index, 0.0, 0.0, accuracyM = 75.0))
            }
            val insufficientDecision =
                insufficientAccumulator.decide(startNs + 20_000_000_000L, timeoutReached = true)
            val insufficientFailure =
                insufficientDecision != null &&
                    insufficientDecision.origin == null &&
                    insufficientDecision.acceptedFixCount == 2 &&
                    insufficientDecision.reason == "accepted_below_minimum"
            val accuracyRejections = insufficientDecision?.rejectedAccuracyCount == 4

            return linkedMapOf(
                "calibrationDelayedCallbacks" to delayedAccepted,
                "calibrationHistoricalPhaseAssignment" to historicalPhase,
                "calibrationHistoryBound" to tooLateRejected,
                "calibrationDuplicateSuppression" to noDuplicate,
                "calibrationNoFutureHeading" to noFutureHeading,
                "calibrationDrainLearningSuppressed" to drainLearningSuppressed,
                "benchmarkDelayedInWindowCallback" to benchmarkDelayedInWindow,
                "benchmarkPostWindowExclusion" to benchmarkPostWindowExcluded,
                "benchmarkMultipleDelayedCallbacks" to benchmarkMultipleDelayed,
                "benchmarkGtWindowBounded" to benchmarkGtWindowBounded,
                "benchmarkFairStepInput" to benchmarkFairStepInput,
                "relativeConstantOffsetRemoved" to relativeConstantOffsetRemoved,
                "relativeCausalMatching" to relativeCausalMatching,
                "relativeGtFirewall" to relativeGtFirewall,
                "gnssTargetStabilization" to targetSuccess,
                "gnssDegradedStabilization" to degradedSuccess,
                "gnssInsufficientFailure" to insufficientFailure,
                "gnssAccuracyRejectionAccounting" to accuracyRejections,
                "gnssRobustMedianOrigin" to robustMedian,
            )
        }

        val AdaptiveSourceQuality.isUsable: Boolean
            get() = this == AdaptiveSourceQuality.GOOD || this == AdaptiveSourceQuality.USABLE || this == AdaptiveSourceQuality.DEGRADED

        val AdaptiveSourceQuality.multiplier: Double
            get() =
                when (this) {
                    AdaptiveSourceQuality.GOOD -> 1.0
                    AdaptiveSourceQuality.USABLE -> 2.0
                    AdaptiveSourceQuality.DEGRADED -> 6.0
                    else -> 10.0
                }

        fun classifyHeadingQuality(accuracyRad: Double?): AdaptiveSourceQuality {
            if (accuracyRad == null) return AdaptiveSourceQuality.USABLE
            if (!accuracyRad.isFinite() || accuracyRad < 0.0) return AdaptiveSourceQuality.UNRELIABLE
            return when {
                Math.toDegrees(accuracyRad) <= 15.0 -> AdaptiveSourceQuality.GOOD
                Math.toDegrees(accuracyRad) <= 30.0 -> AdaptiveSourceQuality.USABLE
                Math.toDegrees(accuracyRad) <= 45.0 -> AdaptiveSourceQuality.DEGRADED
                else -> AdaptiveSourceQuality.UNRELIABLE
            }
        }

        fun classifyArcoreQuality(frameGapMs: Double?): AdaptiveSourceQuality =
            when {
                frameGapMs == null -> AdaptiveSourceQuality.USABLE
                !frameGapMs.isFinite() || frameGapMs < 0.0 -> AdaptiveSourceQuality.UNRELIABLE
                frameGapMs <= 75.0 -> AdaptiveSourceQuality.GOOD
                frameGapMs <= 150.0 -> AdaptiveSourceQuality.USABLE
                frameGapMs <= 300.0 -> AdaptiveSourceQuality.DEGRADED
                else -> AdaptiveSourceQuality.UNRELIABLE
            }

        fun isMockLocation(location: Location): Boolean =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) location.isMock else {
                @Suppress("DEPRECATION")
                location.isFromMockProvider
            }

        fun isValidAnchor(
            latitudeDeg: Double,
            longitudeDeg: Double,
            altitudeM: Double?,
        ): Boolean =
            latitudeDeg.isFinite() && latitudeDeg in -90.0..90.0 &&
                longitudeDeg.isFinite() && longitudeDeg in -180.0..180.0 && altitudeM?.isFinite() != false

        private fun calculateComparatorMetrics(
            configId: String,
            snapshots: List<EstimatorPoint>,
            gt: List<GroundTruthPoint>,
        ): ConfigMetrics {
            val errors = mutableListOf<Double>()
            val relativeErrors = mutableListOf<Double>()
            var initialEstimate: EstimatorPoint? = null
            var initialReference: GroundTruthPoint? = null
            var index = 0
            for (reference in gt) {
                while (index + 1 < snapshots.size && snapshots[index + 1].timestampNs <= reference.timestampNs) index += 1
                val estimate = snapshots.getOrNull(index) ?: continue
                if (estimate.timestampNs <= reference.timestampNs) {
                    errors.add(hypot(estimate.eastM - reference.eastM, estimate.northM - reference.northM))
                    val estimateZero = initialEstimate ?: estimate.also { initialEstimate = it }
                    val referenceZero = initialReference ?: reference.also { initialReference = it }
                    relativeErrors.add(
                        hypot(
                            (estimate.eastM - estimateZero.eastM) - (reference.eastM - referenceZero.eastM),
                            (estimate.northM - estimateZero.northM) - (reference.northM - referenceZero.northM),
                        ),
                    )
                }
            }
            if (errors.isEmpty()) {
                return ConfigMetrics(
                    configId,
                    0,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                )
            }
            val sortedErrors = errors.sorted()
            val sortedRelativeErrors = relativeErrors.sorted()
            val p95Index = (ceil(sortedErrors.size * 0.95).toInt() - 1).coerceIn(0, sortedErrors.lastIndex)
            val relativeP95Index =
                (ceil(sortedRelativeErrors.size * 0.95).toInt() - 1).coerceIn(0, sortedRelativeErrors.lastIndex)
            return ConfigMetrics(
                configId,
                sortedErrors.size,
                sortedErrors.average(),
                median(sortedErrors),
                sortedErrors[p95Index],
                sortedErrors.last(),
                errors.last(),
                sortedRelativeErrors.average(),
                median(sortedRelativeErrors),
                sortedRelativeErrors[relativeP95Index],
                sortedRelativeErrors.last(),
                relativeErrors.last(),
                errors.first(),
            )
        }

        fun improvementPercent(
            baseline: Double?,
            candidate: Double?,
        ): Double? =
            if (baseline == null || candidate == null || !baseline.isFinite() || !candidate.isFinite() || baseline <= 0.0) {
                null
            } else {
                ((baseline - candidate) / baseline) * 100.0
            }

        fun median(values: List<Double>): Double {
            val sorted = values.sorted()
            val middle = sorted.size / 2
            return if (sorted.size % 2 == 1) sorted[middle] else (sorted[middle - 1] + sorted[middle]) / 2.0
        }

        fun finiteOrZero(value: Double): Double = if (value.isFinite()) value else 0.0

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
                matrix[row * 3] * vector[0] + matrix[row * 3 + 1] * vector[1] + matrix[row * 3 + 2] * vector[2]
            }

        fun multiplyMatrices(
            left: DoubleArray,
            right: DoubleArray,
        ): DoubleArray =
            DoubleArray(9) { index ->
                val row = index / 3
                val column = index % 3
                var value = 0.0
                for (inner in 0..2) value += left[row * 3 + inner] * right[inner * 3 + column]
                value
            }

        fun isFinitePose(pose: Pose): Boolean {
            val translation = FloatArray(3)
            val quaternion = FloatArray(4)
            pose.getTranslation(translation, 0)
            pose.getRotationQuaternion(quaternion, 0)
            return translation.all(Float::isFinite) && quaternion.all(Float::isFinite)
        }
    }
}
