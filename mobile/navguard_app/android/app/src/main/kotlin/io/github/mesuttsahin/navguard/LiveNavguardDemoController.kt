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
import com.google.ar.core.Anchor
import com.google.ar.core.ArCoreApk
import com.google.ar.core.Config
import com.google.ar.core.Pose
import com.google.ar.core.Session
import com.google.ar.core.TrackingState
import com.google.ar.core.exceptions.CameraNotAvailableException
import io.flutter.plugin.common.EventChannel
import java.util.PriorityQueue
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.math.PI
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.hypot
import kotlin.math.sin
import kotlin.math.sqrt

class LiveNavguardDemoController(
    private val applicationContext: Context,
    private val locationManager: LocationManager,
    private val sensorManager: SensorManager,
) {
    interface CommandCallback {
        fun onSuccess(snapshot: Map<String, Any?>)

        fun onError(
            code: String,
            message: String,
        )
    }

    private val mainHandler = Handler(Looper.getMainLooper())
    private val activeSessionLock = Any()

    @Volatile
    private var eventSink: EventChannel.EventSink? = null

    @Volatile
    private var lastState = DemoState.IDLE

    private var activeSession: LiveSession? = null

    fun setEventSink(sink: EventChannel.EventSink?) {
        eventSink = sink
        if (sink != null) emitState(lastState, "Live event stream attached.")
    }

    fun isDemoRunning(): Boolean = synchronized(activeSessionLock) { activeSession != null }

    fun createPreflightSnapshot(anchorAvailable: Boolean): Map<String, Any?> {
        val rotation = sensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
        val step = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_DETECTOR)
        val availability = readArCoreAvailability()
        val gpsAvailable = runCatching { locationManager.allProviders.contains(LocationManager.GPS_PROVIDER) }.getOrDefault(false)
        val gpsEnabled = runCatching { locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER) }.getOrDefault(false)
        val locationGranted = hasPermission(Manifest.permission.ACCESS_FINE_LOCATION)
        val cameraGranted = hasPermission(Manifest.permission.CAMERA)
        val activityGranted =
            Build.VERSION.SDK_INT < Build.VERSION_CODES.Q ||
                hasPermission(Manifest.permission.ACTIVITY_RECOGNITION)
        val ready =
            gpsAvailable && gpsEnabled && locationGranted &&
                rotation != null && step != null && activityGranted &&
                availability.supported && availability.installed &&
                cameraGranted && anchorAvailable && !isDemoRunning()
        return linkedMapOf(
            "schemaVersion" to SCHEMA_VERSION,
            "snapshotKind" to "live_navguard_demo_preflight",
            "gpsProviderAvailable" to gpsAvailable,
            "gpsProviderEnabled" to gpsEnabled,
            "fineLocationPermissionGranted" to locationGranted,
            "rotationVectorAvailable" to (rotation != null),
            "stepDetectorAvailable" to (step != null),
            "activityRecognitionPermissionGranted" to activityGranted,
            "arCoreSupported" to availability.supported,
            "arCoreInstalled" to availability.installed,
            "cameraPermissionGranted" to cameraGranted,
            "anchorAvailable" to anchorAvailable,
            "nativeReady" to ready,
            "demoRunning" to isDemoRunning(),
            "mapNetworkRequiredForEstimator" to false,
            "softwareDefinedGnssDenial" to true,
            "rfInterferenceUsed" to false,
            "gnssSpoofingUsed" to false,
            "protectedGroundTruthAccessed" to false,
            "mapUsedAsEstimatorInput" to false,
            "liveDemoAccuracyValidated" to false,
            "stepLengthValidated" to false,
            "headingAccuracyValidated" to false,
            "arcorePositionAccuracyValidated" to false,
            "noiseParametersValidated" to false,
            "qualityThresholdsValidated" to false,
            "availableFusionModes" to listOf(CONFIG_D1_ID, NavguardAdaptiveFusionV2.CONFIG_ID),
            "defaultFusionMode" to CONFIG_D1_ID,
            "adaptiveModeExperimental" to true,
        )
    }

    fun start(
        anchorLatitudeDeg: Double,
        anchorLongitudeDeg: Double,
        anchorAltitudeEllipsoidM: Double?,
        fusionModeId: String = CONFIG_D1_ID,
        callback: CommandCallback,
    ) {
        if (!isValidAnchor(anchorLatitudeDeg, anchorLongitudeDeg, anchorAltitudeEllipsoidM)) {
            postError(callback, ERROR_ANCHOR_REQUIRED, "A valid locked Stage 3A GNSS anchor is required.")
            return
        }
        val preflight = createPreflightSnapshot(anchorAvailable = true)
        if (preflight["nativeReady"] != true) {
            postError(callback, ERROR_NOT_READY, "Live NAVGUARD native prerequisites are not ready.")
            return
        }
        val rotation = sensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
        val step = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_DETECTOR)
        if (rotation == null || step == null) {
            postError(callback, ERROR_NOT_READY, "Required sensors are unavailable.")
            return
        }
        val anchor = Wgs84Anchor(anchorLatitudeDeg, anchorLongitudeDeg, anchorAltitudeEllipsoidM)
        val altitude = anchorAltitudeEllipsoidM ?: 0.0
        val declination =
            Math.toRadians(
                GeomagneticField(
                    anchorLatitudeDeg.toFloat(),
                    anchorLongitudeDeg.toFloat(),
                    altitude.toFloat(),
                    System.currentTimeMillis(),
                ).declination.toDouble(),
            )
        val fusionMode = FusionMode.fromId(fusionModeId)
        if (fusionMode == null) {
            postError(callback, ERROR_INVALID_STATE, "Unknown live NAVGUARD fusion mode.")
            return
        }
        val session = LiveSession(anchor, declination, rotation, step, fusionMode)
        synchronized(activeSessionLock) {
            if (activeSession != null) {
                postError(callback, ERROR_ALREADY_RUNNING, "A live NAVGUARD demo is already running.")
                return
            }
            activeSession = session
        }
        session.start(callback)
    }

    fun beginDenial(callback: CommandCallback) {
        val session = synchronized(activeSessionLock) { activeSession }
        if (session == null) {
            postError(callback, ERROR_INVALID_STATE, "The live demo is not running.")
        } else {
            session.beginDenial(callback)
        }
    }

    fun requestRecovery(callback: CommandCallback) {
        val session = synchronized(activeSessionLock) { activeSession }
        if (session == null) {
            postError(callback, ERROR_INVALID_STATE, "The live demo is not running.")
        } else {
            session.requestRecovery(callback)
        }
    }

    fun stop(
        callback: CommandCallback? = null,
        reason: String = "Live NAVGUARD demo stopped.",
    ) {
        val session = synchronized(activeSessionLock) { activeSession }
        if (session == null) {
            callback?.let { postSuccess(it, commandSnapshot(DemoState.STOPPED)) }
        } else {
            session.stop(reason, callback)
        }
    }

    private fun releaseSession(session: LiveSession) {
        synchronized(activeSessionLock) {
            if (activeSession === session) activeSession = null
        }
    }

    private fun emit(event: Map<String, Any?>) {
        mainHandler.post { eventSink?.success(event) }
    }

    private fun emitState(
        state: DemoState,
        message: String,
    ) {
        lastState = state
        emit(
            linkedMapOf(
                "schemaVersion" to SCHEMA_VERSION,
                "kind" to "state",
                "state" to state.name,
                "message" to message,
                "navigationSource" to navigationSource(state),
                "softwareDefinedGnssDenial" to true,
                "softwareDefinedGnssDenialActive" to
                    (state == DemoState.NAVGUARD_ACTIVE || state == DemoState.RECOVERY_PENDING),
                "estimatorGnssAccessBlocked" to
                    (state == DemoState.NAVGUARD_ACTIVE || state == DemoState.RECOVERY_PENDING),
                "rfInterferenceUsed" to false,
                "gnssSpoofingUsed" to false,
                "protectedGroundTruthAccessed" to false,
                "mapUsedAsEstimatorInput" to false,
                "liveDemoAccuracyValidated" to false,
                "stepLengthValidated" to false,
                "headingAccuracyValidated" to false,
                "arcorePositionAccuracyValidated" to false,
                "noiseParametersValidated" to false,
                "qualityThresholdsValidated" to false,
                "liveMapDemoImplemented" to true,
                "liveResearchValidationCompleted" to false,
                "formalOutdoorBenchmarkCompleted" to false,
                "finalAccuracyClaimAuthorized" to false,
                "routePersisted" to false,
                "routeUploaded" to false,
                "rawSensorDataStreamedToFlutter" to false,
                "rawArcorePoseStreamedToFlutter" to false,
                "rawTimestampsStreamedToFlutter" to false,
            ),
        )
    }

    private inner class LiveSession(
        private val anchor: Wgs84Anchor,
        private val declinationRad: Double,
        private val rotationVector: Sensor,
        private val stepDetector: Sensor,
        private val fusionMode: FusionMode,
    ) : SensorEventListener, LocationListener {
        private val terminal = AtomicBoolean(false)
        private val workerThread = HandlerThread(WORKER_THREAD_NAME)
        private val arThread = HandlerThread(AR_THREAD_NAME)
        private val glEnvironment = LiveGlEnvironment()
        private val pendingEvents = PriorityQueue(INTERNAL_EVENT_COMPARATOR)
        private val eventHistory = mutableListOf<HistoryEntry>()
        private val seenStepEventTimestamps = mutableSetOf<Long>()
        private val gnssStabilizationCandidates = mutableListOf<AdaptiveGnssOriginCandidate>()

        private var worker: Handler? = null
        private var arWorker: Handler? = null
        private var arCoreSession: Session? = null
        private var referenceAnchor: Anchor? = null
        private var arSessionResumed = false
        private var listenersRegistered = false
        private var locationRegistered = false
        private var denialStartPending = false
        private var state = DemoState.IDLE
        private var latestRotation: RotationSample? = null
        private var latestOperationalGnss: EnuFix? = null
        private var latestArPose: Pose? = null
        private var arTrackingHoldStartNs: Long? = null
        private var arTrackingReady = false
        private var denialOrigin: EnuFix? = null
        private var frozenEnuFromInitialDevice: DoubleArray? = null
        private var ekf: EkfState? = null
        private var adaptiveFusion: NavguardAdaptiveFusionV2? = null
        private var stableGnssOrigin: AdaptiveStableGnssOrigin? = null
        private var committedWatermarkNs = -1L
        private var historyStartTimestampNs = -1L
        private var historyBaseWatermarkNs = -1L
        private var historyBaseSnapshot: EstimatorSnapshot? = null
        private var latestCausalHeading: HeadingSample? = null
        private var insertionSequence = 0L
        private var streamSequence = 0L
        private var lastStreamEmitNs = 0L
        private var previousArFusionTimestampNs: Long? = null
        private var initialGoodFixes = 0
        private var recoveryGateNs = -1L
        private var recoveryGoodFixes = 0
        private var normalGnssAcceptedFixCount = 0L
        private var deniedGnssQuarantinedFixCount = 0L
        private var deniedGnssUsedByEstimatorCount = 0L
        private var lateHeadingEventCount = 0L
        private var lateStepEventCount = 0L
        private var lateArcoreEventCount = 0L
        private var headingUpdateCount = 0L
        private var pdrPredictionCount = 0L
        private var arCoreUpdateCount = 0L
        private var receivedStepEventCount = 0L
        private var stepEventsRejectedNoCausalHeading = 0L
        private var duplicateStepEventCount = 0L
        private var stepCallbackLatencyLastMs: Double? = null
        private var stepCallbackLatencyMaxMs: Double? = null
        private var stepCallbackLatencyTotalMs = 0.0
        private var stepCallbackLatencySampleCount = 0L
        private var historicalStepReplayCount = 0L
        private var fixedLagReplayCount = 0L
        private var headingQuality = Quality.UNKNOWN
        private var pdrQuality = Quality.UNKNOWN
        private var arCoreQuality = Quality.UNKNOWN
        private var fusionQuality = Quality.UNKNOWN
        private var recoveryCorrectionM: Double? = null

        fun start(callback: CommandCallback) {
            try {
                workerThread.start()
                arThread.start()
                worker = Handler(workerThread.looper)
                arWorker = Handler(arThread.looper)
                worker?.post { startOnWorker(callback) }
            } catch (_: Exception) {
                fail(ERROR_INTERNAL, "Unable to create live NAVGUARD workers.")
                postError(callback, ERROR_INTERNAL, "Unable to create live NAVGUARD workers.")
            }
        }

        @Suppress("MissingPermission")
        private fun startOnWorker(callback: CommandCallback) {
            if (terminal.get()) return
            transition(DemoState.PREPARING, "Preparing sensors, GNSS, and ARCore.")
            try {
                val rotationRegistered =
                    sensorManager.registerListener(
                        this,
                        rotationVector,
                        ROTATION_VECTOR_SAMPLING_PERIOD_US,
                        0,
                        worker,
                    )
                val stepRegistered =
                    sensorManager.registerListener(
                        this,
                        stepDetector,
                        SensorManager.SENSOR_DELAY_NORMAL,
                        0,
                        worker,
                    )
                listenersRegistered = rotationRegistered || stepRegistered
                if (!rotationRegistered || !stepRegistered) {
                    fail(ERROR_SENSOR_REGISTRATION, "Android rejected a required sensor registration.")
                    postError(callback, ERROR_SENSOR_REGISTRATION, "Android rejected a required sensor registration.")
                    return
                }
                locationManager.requestLocationUpdates(
                    LocationManager.GPS_PROVIDER,
                    GNSS_MIN_TIME_MS,
                    GNSS_MIN_DISTANCE_M,
                    this,
                    checkNotNull(worker).looper,
                )
                locationRegistered = true
                if (arWorker?.post(::initializeArCore) != true) {
                    fail(ERROR_ARCORE_UNAVAILABLE, "Unable to start the ARCore worker.")
                    postError(callback, ERROR_ARCORE_UNAVAILABLE, "Unable to start the ARCore worker.")
                    return
                }
                scheduleReorderFlush()
                postSuccess(callback, commandSnapshot(state))
            } catch (_: SecurityException) {
                fail(ERROR_PERMISSION_REQUIRED, "A required runtime permission is missing.")
                postError(callback, ERROR_PERMISSION_REQUIRED, "A required runtime permission is missing.")
            } catch (_: Exception) {
                fail(ERROR_INTERNAL, "Unable to start the live NAVGUARD demo.")
                postError(callback, ERROR_INTERNAL, "Unable to start the live NAVGUARD demo.")
            }
        }

        fun beginDenial(callback: CommandCallback) {
            val accepted = worker?.post { beginDenialOnWorker(callback) } == true
            if (!accepted) postError(callback, ERROR_INVALID_STATE, "The live demo worker is unavailable.")
        }

        private fun beginDenialOnWorker(callback: CommandCallback) {
            if (state != DemoState.NAVGUARD_READY || denialStartPending) {
                postError(callback, ERROR_INVALID_STATE, "GNSS denial requires NAVGUARD_READY state.")
                return
            }
            val latestGnss = latestOperationalGnss
            val rotation = latestRotation
            val robustOrigin =
                if (fusionMode == FusionMode.ADAPTIVE_V2) {
                    NavguardAdaptiveFusionV2.computeStableGnssOrigin(
                        gnssStabilizationCandidates,
                        SystemClock.elapsedRealtimeNanos(),
                    )
                } else {
                    null
                }
            val gnss =
                if (fusionMode == FusionMode.ADAPTIVE_V2 && robustOrigin != null) {
                    EnuFix(
                        generationNs = gnssStabilizationCandidates.maxOfOrNull { it.timestampNs } ?: SystemClock.elapsedRealtimeNanos(),
                        eastM = robustOrigin.eastM,
                        northM = robustOrigin.northM,
                    )
                } else {
                    latestGnss
                }
            if (gnss == null || rotation == null || qualityMultiplier(rotation.quality) == null || !arTrackingReady ||
                (fusionMode == FusionMode.ADAPTIVE_V2 && robustOrigin == null)
            ) {
                postError(callback, ERROR_NOT_READY, "GNSS, true-north heading, and ARCore alignment must all be ready.")
                return
            }
            stableGnssOrigin = robustOrigin
            denialStartPending = true
            val posted =
                arWorker?.post {
                    val session = arCoreSession
                    val pose = latestArPose
                    val created =
                        if (session != null && pose != null && isFinitePose(pose)) {
                            runCatching { session.createAnchor(pose) }.getOrNull()
                        } else {
                            null
                        }
                    if (created == null || created.trackingState != TrackingState.TRACKING) {
                        runCatching { created?.detach() }
                        worker?.post {
                            denialStartPending = false
                            postError(callback, ERROR_NOT_READY, "ARCore tracking was lost before denial start.")
                        }
                    } else {
                        runCatching { referenceAnchor?.detach() }
                        referenceAnchor = created
                        frozenEnuFromInitialDevice = rotation.trueEnuDevice.copyOf()
                        denialOrigin = gnss.copy()
                        worker?.post { completeDenialStart(gnss, rotation, callback) }
                    }
                } == true
            if (!posted) {
                denialStartPending = false
                postError(callback, ERROR_ARCORE_UNAVAILABLE, "ARCore worker is unavailable.")
            }
        }

        private fun completeDenialStart(
            gnss: EnuFix,
            rotation: RotationSample,
            callback: CommandCallback,
        ) {
            denialStartPending = false
            if (state != DemoState.NAVGUARD_READY || terminal.get()) {
                postError(callback, ERROR_INVALID_STATE, "Denial start was cancelled by a state change.")
                return
            }
            denialOrigin = gnss.copy()
            if (fusionMode == FusionMode.ADAPTIVE_V2) {
                adaptiveFusion =
                    NavguardAdaptiveFusionV2(
                        gnss.eastM,
                        gnss.northM,
                        rotation.trueHeadingRad,
                        NavguardCalibrationProfileStore.read(),
                    )
                ekf = null
            } else {
                ekf = EkfState.initial(gnss.eastM, gnss.northM, rotation.trueHeadingRad)
                adaptiveFusion = null
            }
            pendingEvents.clear()
            eventHistory.clear()
            seenStepEventTimestamps.clear()
            gnssStabilizationCandidates.clear()
            committedWatermarkNs = -1L
            historyStartTimestampNs = SystemClock.elapsedRealtimeNanos()
            historyBaseWatermarkNs = historyStartTimestampNs
            latestCausalHeading =
                HeadingSample(rotation.timestampNs, rotation.trueHeadingRad, rotation.quality)
            previousArFusionTimestampNs = null
            receivedStepEventCount = 0L
            pdrPredictionCount = 0L
            stepEventsRejectedNoCausalHeading = 0L
            lateStepEventCount = 0L
            duplicateStepEventCount = 0L
            stepCallbackLatencyLastMs = null
            stepCallbackLatencyMaxMs = null
            stepCallbackLatencyTotalMs = 0.0
            stepCallbackLatencySampleCount = 0L
            historicalStepReplayCount = 0L
            fixedLagReplayCount = 0L
            historyBaseSnapshot = captureEstimatorSnapshot()
            transition(
                DemoState.NAVGUARD_ACTIVE,
                if (fusionMode == FusionMode.ADAPTIVE_V2) {
                    "GNSS denied; experimental adaptive NAVGUARD v2 navigation is active."
                } else {
                    "GNSS denied; NAVGUARD v1 navigation is active."
                },
            )
            emitPosition(force = true)
            postSuccess(callback, commandSnapshot(state))
        }

        fun requestRecovery(callback: CommandCallback) {
            val accepted = worker?.post {
                if (state != DemoState.NAVGUARD_ACTIVE) {
                    postError(callback, ERROR_INVALID_STATE, "GNSS recovery requires NAVGUARD_ACTIVE state.")
                    return@post
                }
                recoveryGateNs = SystemClock.elapsedRealtimeNanos()
                recoveryGoodFixes = 0
                transition(DemoState.RECOVERY_PENDING, "GNSS recovery requested; NAVGUARD remains active.")
                emitRecoveryProgress()
                postSuccess(callback, commandSnapshot(state))
            } == true
            if (!accepted) postError(callback, ERROR_INVALID_STATE, "The live demo worker is unavailable.")
        }

        fun stop(
            reason: String,
            callback: CommandCallback?,
        ) {
            val accepted = worker?.post { finishStopped(reason, callback) } == true
            if (!accepted) {
                cleanupArCore()
                terminal.set(true)
                releaseSession(this)
                callback?.let { postSuccess(it, commandSnapshot(DemoState.STOPPED)) }
            }
        }

        override fun onSensorChanged(event: SensorEvent) {
            if (terminal.get()) return
            when (event.sensor.type) {
                Sensor.TYPE_ROTATION_VECTOR -> handleRotationVector(event)
                Sensor.TYPE_STEP_DETECTOR -> handleStep(event)
            }
        }

        override fun onAccuracyChanged(
            sensor: Sensor,
            accuracy: Int,
        ) {
            // Rotation-vector payload accuracy is the frozen quality authority.
        }

        private fun handleRotationVector(event: SensorEvent) {
            val sample = createRotationSample(event)
            if (sample == null) {
                headingQuality = Quality.UNRELIABLE
                return
            }
            latestRotation = sample
            updateReadyState()
            if (state == DemoState.NAVGUARD_ACTIVE || state == DemoState.RECOVERY_PENDING) {
                enqueueEvent(HeadingEvent(sample.timestampNs, nextInsertion(), sample.trueHeadingRad, sample.quality))
            }
        }

        private fun handleStep(event: SensorEvent) {
            if (state != DemoState.NAVGUARD_ACTIVE && state != DemoState.RECOVERY_PENDING) return
            val value = event.values.firstOrNull()
            if (event.timestamp <= 0L || value == null || !value.isFinite() || value != 1.0f) return
            receivedStepEventCount += 1L
            val callbackTimestampNs = SystemClock.elapsedRealtimeNanos()
            val callbackLatencyMs =
                (callbackTimestampNs - event.timestamp).coerceAtLeast(0L) / 1_000_000.0
            stepCallbackLatencyLastMs = callbackLatencyMs
            stepCallbackLatencyMaxMs = maxOf(stepCallbackLatencyMaxMs ?: 0.0, callbackLatencyMs)
            stepCallbackLatencyTotalMs += callbackLatencyMs
            stepCallbackLatencySampleCount += 1L
            if (event.timestamp < historyStartTimestampNs ||
                callbackTimestampNs - event.timestamp > FIXED_LAG_HISTORY_NS
            ) {
                lateStepEventCount += 1L
                emitPosition()
                return
            }
            if (!seenStepEventTimestamps.add(event.timestamp)) {
                duplicateStepEventCount += 1L
                emitPosition()
                return
            }
            val step = StepEvent(event.timestamp, nextInsertion())
            if (step.timestampNs <= committedWatermarkNs) {
                try {
                    if (!replayDelayedStep(step, callbackTimestampNs)) {
                        lateStepEventCount += 1L
                        emitPosition()
                    }
                } catch (_: Exception) {
                    fail(ERROR_EKF_NUMERICAL, "The live NAVGUARD fixed-lag replay failed.")
                }
            } else {
                enqueueEvent(step)
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
            return runCatching {
                SensorManager.getRotationMatrixFromVector(matrix, vector)
                require(matrix.all { it.isFinite() })
                val east = matrix[1].toDouble()
                val north = matrix[4].toDouble()
                require(hypot(east, north) > 1e-6)
                val accuracy =
                    if (event.values.size >= 5) {
                        event.values[4].toDouble().takeIf { it.isFinite() && it >= 0.0 }
                    } else {
                        null
                    }
                val trueHeading = normalizeHeading(atan2(east, north) + declinationRad)
                val trueMatrix =
                    multiplyMatrices(
                        declinationCorrectionMatrix(declinationRad),
                        DoubleArray(9) { matrix[it].toDouble() },
                    )
                RotationSample(event.timestamp, trueHeading, classifyHeadingQuality(accuracy), trueMatrix)
            }.getOrNull()
        }

        override fun onLocationChanged(location: Location) {
            if (terminal.get() || location.provider != LocationManager.GPS_PROVIDER) return
            val generation = location.elapsedRealtimeNanos
            val valid =
                generation > 0L && location.hasAccuracy() && location.accuracy.isFinite() &&
                    location.accuracy >= 0.0f && location.accuracy <= MAX_OPERATIONAL_GNSS_ACCURACY_M
            val enu = if (valid) Wgs84EnuConverter.toHorizontalEnu(anchor, location) else null
            if (enu != null && location.accuracy > 0.0f && !isMockLocation(location) &&
                (state == DemoState.PREPARING || state == DemoState.GNSS_ACTIVE || state == DemoState.NAVGUARD_READY)
            ) {
                gnssStabilizationCandidates.add(
                    AdaptiveGnssOriginCandidate(
                        timestampNs = generation,
                        eastM = enu.eastM,
                        northM = enu.northM,
                        reportedAccuracyM = location.accuracy.toDouble(),
                    ),
                )
                val cutoff = generation - NavguardAdaptiveFusionV2.GNSS_STABILIZATION_WINDOW_MS * 1_000_000L
                gnssStabilizationCandidates.removeAll { it.timestampNs <= cutoff }
                while (gnssStabilizationCandidates.size > MAX_GNSS_STABILIZATION_CANDIDATES) {
                    gnssStabilizationCandidates.removeAt(0)
                }
            }
            when (state) {
                DemoState.PREPARING -> {
                    if (enu == null) {
                        initialGoodFixes = 0
                        return
                    }
                    initialGoodFixes += 1
                    normalGnssAcceptedFixCount += 1
                    latestOperationalGnss = enu
                    emitGnssPosition(enu, force = initialGoodFixes >= REQUIRED_CONSECUTIVE_FIXES)
                    if (initialGoodFixes >= REQUIRED_CONSECUTIVE_FIXES) {
                        transition(DemoState.GNSS_ACTIVE, "GNSS is active; waiting for NAVGUARD readiness.")
                        updateReadyState()
                    }
                }
                DemoState.GNSS_ACTIVE, DemoState.NAVGUARD_READY -> {
                    if (enu != null) {
                        normalGnssAcceptedFixCount += 1
                        latestOperationalGnss = enu
                        emitGnssPosition(enu)
                    }
                }
                DemoState.NAVGUARD_ACTIVE -> {
                    deniedGnssQuarantinedFixCount += 1
                    emitPosition()
                }
                DemoState.RECOVERY_PENDING -> {
                    deniedGnssQuarantinedFixCount += 1
                    if (generation < recoveryGateNs) {
                        emitRecoveryProgress()
                        return
                    }
                    if (enu == null) {
                        recoveryGoodFixes = 0
                        emitRecoveryProgress()
                        return
                    }
                    recoveryGoodFixes += 1
                    emitRecoveryProgress()
                    if (recoveryGoodFixes >= REQUIRED_CONSECUTIVE_FIXES) recoverWith(enu, location.accuracy.toDouble())
                }
                DemoState.GNSS_RECOVERED -> {
                    if (enu != null) {
                        normalGnssAcceptedFixCount += 1
                        latestOperationalGnss = enu
                        emitGnssPosition(enu)
                    }
                }
                else -> Unit
            }
        }

        private fun recoverWith(
            recovered: EnuFix,
            accuracyM: Double,
        ) {
            flushReorderBuffer(Long.MAX_VALUE)
            val adaptive = adaptiveFusion
            val filter = ekf
            val preEast = adaptive?.eastM ?: filter?.x?.get(0) ?: return
            val preNorth = adaptive?.northM ?: filter?.x?.get(1) ?: return
            val correction = hypot(recovered.eastM - preEast, recovered.northM - preNorth)
            if (adaptive != null) {
                adaptive.resetPosition(recovered.eastM, recovered.northM, accuracyM)
            } else {
                checkNotNull(filter).resetPosition(recovered.eastM, recovered.northM, accuracyM)
            }
            recoveryCorrectionM = correction
            latestOperationalGnss = recovered
            pendingEvents.clear()
            transition(DemoState.GNSS_RECOVERED, "GNSS recovered after three post-request valid fixes.")
            emitPosition(force = true, sourceOverride = "GNSS")
            emit(
                linkedMapOf(
                    "schemaVersion" to SCHEMA_VERSION,
                    "kind" to "completed",
                    "state" to state.name,
                    "navigationSource" to "GNSS",
                    "preRecoveryEastM" to preEast,
                    "preRecoveryNorthM" to preNorth,
                    "recoveredEastM" to recovered.eastM,
                    "recoveredNorthM" to recovered.northM,
                    "recoveryCorrectionM" to correction,
                    "recoveryGoodFixCount" to recoveryGoodFixes,
                    "recoveryRequiredFixCount" to REQUIRED_CONSECUTIVE_FIXES,
                    "deniedGnssUsedByEstimatorCount" to deniedGnssUsedByEstimatorCount,
                    "softwareDefinedGnssDenial" to true,
                    "rfInterferenceUsed" to false,
                    "gnssSpoofingUsed" to false,
                    "protectedGroundTruthAccessed" to false,
                    "mapUsedAsEstimatorInput" to false,
                    "liveDemoAccuracyValidated" to false,
                    "stepLengthValidated" to false,
                    "headingAccuracyValidated" to false,
                    "arcorePositionAccuracyValidated" to false,
                    "noiseParametersValidated" to false,
                    "qualityThresholdsValidated" to false,
                    "routePersisted" to false,
                    "routeUploaded" to false,
                    "finalAccuracyClaimAuthorized" to false,
                ),
            )
        }

        private fun initializeArCore() {
            if (terminal.get()) return
            val session =
                try {
                    Session(applicationContext).also { arCoreSession = it }
                } catch (_: Exception) {
                    worker?.post { fail(ERROR_ARCORE_UNAVAILABLE, "Unable to create an ARCore session.") }
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
            } catch (_: CameraNotAvailableException) {
                worker?.post { fail(ERROR_ARCORE_UNAVAILABLE, "The ARCore camera is unavailable.") }
            } catch (_: SecurityException) {
                worker?.post { fail(ERROR_PERMISSION_REQUIRED, "Camera permission is required.") }
            } catch (_: Exception) {
                worker?.post { fail(ERROR_ARCORE_UNAVAILABLE, "Unable to configure the ARCore session.") }
            }
        }

        private fun runNextArFrame() {
            if (terminal.get()) return
            val session = arCoreSession ?: return
            val frame =
                try {
                    session.update()
                } catch (_: Exception) {
                    worker?.post { fail(ERROR_ARCORE_UNAVAILABLE, "The ARCore session failed.") }
                    return
                }
            val tracking = frame.camera.trackingState == TrackingState.TRACKING
            val pose = if (tracking) runCatching { frame.androidSensorPose }.getOrNull() else null
            if (pose != null && isFinitePose(pose)) latestArPose = pose
            val now = SystemClock.elapsedRealtimeNanos()
            worker?.post { observeArTracking(tracking && pose != null, now) }
            val arAnchor = referenceAnchor
            val transform = frozenEnuFromInitialDevice
            val origin = denialOrigin
            if (tracking && pose != null && arAnchor != null && transform != null && origin != null &&
                arAnchor.trackingState == TrackingState.TRACKING
            ) {
                val relative = runCatching { arAnchor.pose.inverse().compose(pose) }.getOrNull()
                if (relative != null && isFinitePose(relative)) {
                    val translation = FloatArray(3)
                    relative.getTranslation(translation, 0)
                    if (translation.all { it.isFinite() }) {
                        val delta =
                            multiplyMatrixVector(
                                transform,
                                doubleArrayOf(
                                    translation[0].toDouble(),
                                    translation[1].toDouble(),
                                    translation[2].toDouble(),
                                ),
                            )
                        if (delta.all { it.isFinite() }) {
                            val fusionTimestamp = SystemClock.elapsedRealtimeNanos()
                            worker?.post {
                                if (state == DemoState.NAVGUARD_ACTIVE || state == DemoState.RECOVERY_PENDING) {
                                    val previous = previousArFusionTimestampNs
                                    val quality =
                                        if (previous == null) Quality.USABLE else classifyArcoreQuality(fusionTimestamp - previous)
                                    previousArFusionTimestampNs = fusionTimestamp
                                    enqueueEvent(
                                        ArcoreEvent(
                                            fusionTimestamp,
                                            nextInsertion(),
                                            origin.eastM + delta[0],
                                            origin.northM + delta[1],
                                            quality,
                                        ),
                                    )
                                }
                            }
                        }
                    }
                }
            }
            if (!terminal.get()) arWorker?.post(::runNextArFrame)
        }

        private fun observeArTracking(
            tracking: Boolean,
            nowNs: Long,
        ) {
            if (!tracking) {
                arTrackingHoldStartNs = null
                arTrackingReady = false
                if (state == DemoState.NAVGUARD_READY) {
                    transition(DemoState.GNSS_ACTIVE, "ARCore tracking was lost; NAVGUARD readiness paused.")
                }
                return
            }
            val start = arTrackingHoldStartNs
            if (start == null) {
                arTrackingHoldStartNs = nowNs
            } else if (nowNs - start >= ALIGNMENT_HOLD_NS) {
                arTrackingReady = true
                updateReadyState()
            }
        }

        private fun updateReadyState() {
            val stableOriginReady =
                fusionMode == FusionMode.V1 ||
                    NavguardAdaptiveFusionV2.computeStableGnssOrigin(
                        gnssStabilizationCandidates,
                        SystemClock.elapsedRealtimeNanos(),
                    ) != null
            if ((state == DemoState.GNSS_ACTIVE || state == DemoState.NAVGUARD_READY) &&
                latestOperationalGnss != null && arTrackingReady &&
                latestRotation?.let { qualityMultiplier(it.quality) } != null && stableOriginReady
            ) {
                if (state != DemoState.NAVGUARD_READY) {
                    transition(DemoState.NAVGUARD_READY, "NAVGUARD is ready; GNSS denial may begin.")
                }
            } else if (state == DemoState.NAVGUARD_READY) {
                transition(DemoState.GNSS_ACTIVE, "GNSS active; NAVGUARD readiness is incomplete.")
            }
        }

        private fun enqueueEvent(event: InternalEvent) {
            if (event.timestampNs < committedWatermarkNs) {
                when (event) {
                    is HeadingEvent -> lateHeadingEventCount += 1L
                    is StepEvent -> lateStepEventCount += 1L
                    is ArcoreEvent -> lateArcoreEventCount += 1L
                }
                return
            }
            pendingEvents.add(event)
        }

        private fun scheduleReorderFlush() {
            worker?.postDelayed(
                {
                    if (!terminal.get()) {
                        flushReorderBuffer(SystemClock.elapsedRealtimeNanos())
                        scheduleReorderFlush()
                    }
                },
                REORDER_FLUSH_PERIOD_MS,
            )
        }

        private fun flushReorderBuffer(nowNs: Long) {
            val threshold = nowNs - LIVE_REORDER_WINDOW_NS
            while (pendingEvents.isNotEmpty() && pendingEvents.peek().timestampNs <= threshold) {
                val event = pendingEvents.remove()
                if (event.timestampNs < committedWatermarkNs) {
                    when (event) {
                        is HeadingEvent -> lateHeadingEventCount += 1L
                        is StepEvent -> lateStepEventCount += 1L
                        is ArcoreEvent -> lateArcoreEventCount += 1L
                    }
                    continue
                }
                committedWatermarkNs = event.timestampNs
                applyEvent(event)
            }
            pruneFixedLagHistory(nowNs)
        }

        private fun applyEvent(event: InternalEvent) {
            if (state != DemoState.NAVGUARD_ACTIVE && state != DemoState.RECOVERY_PENDING) return
            try {
                val before = captureEstimatorSnapshot() ?: return
                applyEventMutation(event)
                eventHistory.add(HistoryEntry(event, before))
                pruneFixedLagHistory(SystemClock.elapsedRealtimeNanos())
                emitPosition()
            } catch (_: Exception) {
                fail(ERROR_EKF_NUMERICAL, "The live NAVGUARD EKF produced an invalid numerical state.")
            }
        }

        private fun applyEventMutation(event: InternalEvent) {
            if (fusionMode == FusionMode.ADAPTIVE_V2) {
                applyAdaptiveEventMutation(event)
            } else {
                applyV1EventMutation(event)
            }
            fusionQuality =
                classifyFusionQuality(
                    headingQuality,
                    pdrQuality,
                    arCoreQuality,
                    pdrPredictionCount + arCoreUpdateCount > 0,
                    headingUpdateCount + pdrPredictionCount + arCoreUpdateCount > 0,
                )
        }

        private fun applyV1EventMutation(event: InternalEvent) {
            val filter = ekf ?: error("Missing live v1 estimator state.")
            when (event) {
                is HeadingEvent -> {
                    headingQuality = event.quality
                    latestCausalHeading =
                        HeadingSample(event.timestampNs, event.headingRad, event.quality)
                    val multiplier = qualityMultiplier(event.quality)
                    if (multiplier != null) {
                        filter.updateHeading(event.headingRad, multiplier)
                        headingUpdateCount += 1L
                    }
                }
                is StepEvent -> {
                    val heading = latestCausalHeading?.takeIf { it.timestampNs <= event.timestampNs }
                    if (heading == null) {
                        pdrQuality = Quality.UNAVAILABLE
                        stepEventsRejectedNoCausalHeading += 1L
                    } else {
                        val quality = classifyPdrQuality(heading.quality, event.timestampNs - heading.timestampNs)
                        pdrQuality = quality
                        val multiplier = qualityMultiplier(quality)
                        if (multiplier != null) {
                            filter.predictStep(multiplier)
                            pdrPredictionCount += 1L
                        } else {
                            stepEventsRejectedNoCausalHeading += 1L
                        }
                    }
                }
                is ArcoreEvent -> {
                    arCoreQuality = event.quality
                    val multiplier = qualityMultiplier(event.quality)
                    if (multiplier != null) {
                        filter.updateArcore(event.eastM, event.northM, multiplier)
                        arCoreUpdateCount += 1L
                    }
                }
            }
        }

        private fun applyAdaptiveEventMutation(event: InternalEvent) {
            val filter = adaptiveFusion ?: error("Missing live v2 estimator state.")
            when (event) {
                is HeadingEvent -> {
                    headingQuality = event.quality
                    latestCausalHeading = HeadingSample(event.timestampNs, event.headingRad, event.quality)
                    if (filter.updateHeading(event.timestampNs, event.headingRad, event.quality.toAdaptive())) {
                        headingUpdateCount += 1L
                    }
                }
                is StepEvent -> {
                    val heading = latestCausalHeading?.takeIf { it.timestampNs <= event.timestampNs }
                    if (heading == null) {
                        pdrQuality = Quality.UNAVAILABLE
                        stepEventsRejectedNoCausalHeading += 1L
                    } else {
                        val quality = classifyPdrQuality(heading.quality, event.timestampNs - heading.timestampNs)
                        pdrQuality = quality
                        if (qualityMultiplier(quality) != null && filter.predictStep(event.timestampNs, quality.toAdaptive())) {
                            pdrPredictionCount += 1L
                        } else {
                            stepEventsRejectedNoCausalHeading += 1L
                        }
                    }
                }
                is ArcoreEvent -> {
                    arCoreQuality = event.quality
                    val result =
                        filter.updateArcore(
                            event.timestampNs,
                            event.eastM,
                            event.northM,
                            event.quality.toAdaptive(),
                        )
                    if (result.accepted) arCoreUpdateCount += 1L
                }
            }
        }

        // Only the corrected current estimate is emitted; prior Flutter route points are not rewritten.
        private fun replayDelayedStep(
            step: StepEvent,
            nowNs: Long,
        ): Boolean {
            val base = historyBaseSnapshot ?: return false
            if (nowNs - step.timestampNs > FIXED_LAG_HISTORY_NS ||
                step.timestampNs <= historyBaseWatermarkNs
            ) {
                return false
            }
            val replayEvents = eventHistory.map { it.event }.toMutableList()
            replayEvents.add(step)
            replayEvents.sortWith(INTERNAL_EVENT_COMPARATOR)
            val appliedBefore = pdrPredictionCount
            restoreEstimatorSnapshot(base)
            eventHistory.clear()
            for (event in replayEvents) {
                val before = captureEstimatorSnapshot() ?: return false
                applyEventMutation(event)
                eventHistory.add(HistoryEntry(event, before))
            }
            fixedLagReplayCount += 1L
            if (pdrPredictionCount > appliedBefore) historicalStepReplayCount += 1L
            pruneFixedLagHistory(nowNs)
            emitPosition(force = true)
            return true
        }

        private fun captureEstimatorSnapshot(): EstimatorSnapshot? {
            val adaptive = adaptiveFusion
            val filter = ekf
            if (fusionMode == FusionMode.ADAPTIVE_V2 && adaptive == null) return null
            if (fusionMode == FusionMode.V1 && filter == null) return null
            return EstimatorSnapshot(
                x =
                    if (adaptive != null) {
                        doubleArrayOf(adaptive.eastM, adaptive.northM, adaptive.headingRad)
                    } else {
                        checkNotNull(filter).x.copyOf()
                    },
                p = filter?.p?.copyOf() ?: DoubleArray(9),
                adaptiveSnapshot = adaptive?.snapshot(),
                headingQuality = headingQuality,
                pdrQuality = pdrQuality,
                arCoreQuality = arCoreQuality,
                fusionQuality = fusionQuality,
                latestCausalHeading = latestCausalHeading,
                headingUpdateCount = headingUpdateCount,
                pdrPredictionCount = pdrPredictionCount,
                arCoreUpdateCount = arCoreUpdateCount,
                stepEventsRejectedNoCausalHeading = stepEventsRejectedNoCausalHeading,
            )
        }

        private fun restoreEstimatorSnapshot(snapshot: EstimatorSnapshot) {
            if (fusionMode == FusionMode.ADAPTIVE_V2) {
                val adaptiveSnapshot = checkNotNull(snapshot.adaptiveSnapshot)
                val filter = adaptiveFusion ?: NavguardAdaptiveFusionV2(snapshot.x[0], snapshot.x[1], snapshot.x[2])
                filter.restore(adaptiveSnapshot)
                adaptiveFusion = filter
                ekf = null
            } else {
                ekf = EkfState(snapshot.x.copyOf(), snapshot.p.copyOf())
                adaptiveFusion = null
            }
            headingQuality = snapshot.headingQuality
            pdrQuality = snapshot.pdrQuality
            arCoreQuality = snapshot.arCoreQuality
            fusionQuality = snapshot.fusionQuality
            latestCausalHeading = snapshot.latestCausalHeading
            headingUpdateCount = snapshot.headingUpdateCount
            pdrPredictionCount = snapshot.pdrPredictionCount
            arCoreUpdateCount = snapshot.arCoreUpdateCount
            stepEventsRejectedNoCausalHeading = snapshot.stepEventsRejectedNoCausalHeading
        }

        private fun pruneFixedLagHistory(nowNs: Long) {
            val cutoffNs = nowNs - FIXED_LAG_HISTORY_NS
            val timePruneCount = eventHistory.indexOfFirst { it.event.timestampNs >= cutoffNs }.let {
                if (it < 0) eventHistory.size else it
            }
            val countPruneCount = (eventHistory.size - MAX_FIXED_LAG_HISTORY_EVENTS).coerceAtLeast(0)
            val removeCount = maxOf(timePruneCount, countPruneCount)
            if (removeCount > 0) {
                historyBaseWatermarkNs =
                    maxOf(historyBaseWatermarkNs, eventHistory[removeCount - 1].event.timestampNs)
                historyBaseSnapshot =
                    if (removeCount < eventHistory.size) {
                        eventHistory[removeCount].beforeSnapshot
                    } else {
                        captureEstimatorSnapshot()
                    }
                eventHistory.subList(0, removeCount).clear()
            }
            seenStepEventTimestamps.removeAll { it < cutoffNs }
        }

        private fun emitGnssPosition(
            enu: EnuFix,
            force: Boolean = false,
        ) {
            val now = SystemClock.elapsedRealtimeNanos()
            if (!force && now - lastStreamEmitNs < STREAM_PERIOD_NS) return
            lastStreamEmitNs = now
            streamSequence += 1L
            val heading = latestRotation?.trueHeadingRad ?: 0.0
            emit(
                positionEvent(
                    source = "GNSS",
                    eastM = enu.eastM,
                    northM = enu.northM,
                    headingRad = heading,
                    displacementM = hypot(enu.eastM, enu.northM),
                ),
            )
        }

        private fun emitPosition(
            force: Boolean = false,
            sourceOverride: String? = null,
        ) {
            val adaptive = adaptiveFusion
            val filter = ekf
            val east = adaptive?.eastM ?: filter?.x?.get(0) ?: return
            val north = adaptive?.northM ?: filter?.x?.get(1) ?: return
            val heading = adaptive?.headingRad ?: filter?.x?.get(2) ?: return
            val now = SystemClock.elapsedRealtimeNanos()
            if (!force && now - lastStreamEmitNs < STREAM_PERIOD_NS) return
            lastStreamEmitNs = now
            streamSequence += 1L
            emit(
                positionEvent(
                    source = sourceOverride ?: navigationSource(state),
                    eastM = east,
                    northM = north,
                    headingRad = heading,
                    displacementM = hypot(east, north),
                ),
            )
        }

        private fun positionEvent(
            source: String,
            eastM: Double,
            northM: Double,
            headingRad: Double,
            displacementM: Double,
        ): Map<String, Any?> {
            val pendingStepEventCount = pendingStepEventCount()
            val snapshot = linkedMapOf<String, Any?>(
                "schemaVersion" to SCHEMA_VERSION,
                "kind" to "position",
                "sequence" to streamSequence,
                "state" to state.name,
                "navigationSource" to source,
                "eastM" to eastM,
                "northM" to northM,
                "headingRad" to headingRad,
                "displacementM" to displacementM,
                "headingQuality" to headingQuality.name,
                "pdrQuality" to pdrQuality.name,
                "arCoreQuality" to arCoreQuality.name,
                "fusionQuality" to fusionQuality.name,
                "headingUpdateCount" to headingUpdateCount,
                "pdrPredictionCount" to pdrPredictionCount,
                "pdrPredictionsApplied" to pdrPredictionCount,
                "arCoreUpdateCount" to arCoreUpdateCount,
                "receivedStepEventCount" to receivedStepEventCount,
                "stepEventsRejectedNoCausalHeading" to stepEventsRejectedNoCausalHeading,
                "duplicateStepEventCount" to duplicateStepEventCount,
                "pendingStepEventCount" to pendingStepEventCount,
                "stepCounterInvariantHolds" to
                    (pdrPredictionCount + stepEventsRejectedNoCausalHeading + lateStepEventCount +
                        duplicateStepEventCount + pendingStepEventCount == receivedStepEventCount),
                "stepCallbackLatencyLastMs" to stepCallbackLatencyLastMs,
                "stepCallbackLatencyMaxMs" to stepCallbackLatencyMaxMs,
                "stepCallbackLatencyMeanMs" to
                    if (stepCallbackLatencySampleCount == 0L) {
                        null
                    } else {
                        stepCallbackLatencyTotalMs / stepCallbackLatencySampleCount
                    },
                "historicalStepReplayCount" to historicalStepReplayCount,
                "fixedLagReplayCount" to fixedLagReplayCount,
                "fixedLagHistoryEventCount" to eventHistory.size,
                "fixedLagHistoryWindowMs" to FIXED_LAG_HISTORY_NS / 1_000_000L,
                "fixedLagHistoryBounded" to true,
                "normalGnssAcceptedFixCount" to normalGnssAcceptedFixCount,
                "deniedGnssQuarantinedFixCount" to deniedGnssQuarantinedFixCount,
                "deniedGnssUsedByEstimatorCount" to deniedGnssUsedByEstimatorCount,
                "lateHeadingEventCount" to lateHeadingEventCount,
                "lateStepEventCount" to lateStepEventCount,
                "lateArcoreEventCount" to lateArcoreEventCount,
                "recoveryGoodFixCount" to recoveryGoodFixes,
                "recoveryCorrectionM" to recoveryCorrectionM,
                "fusionMode" to fusionMode.id,
                "adaptiveMode" to (fusionMode == FusionMode.ADAPTIVE_V2),
            )
            stableGnssOrigin?.toSanitizedMap()?.let(snapshot::putAll)
            adaptiveFusion?.diagnostics()?.let(snapshot::putAll)
            return snapshot
        }

        private fun emitRecoveryProgress() {
            emit(
                linkedMapOf(
                    "schemaVersion" to SCHEMA_VERSION,
                    "kind" to "recovery_progress",
                    "state" to state.name,
                    "navigationSource" to "NAVGUARD",
                    "recoveryGoodFixCount" to recoveryGoodFixes,
                    "recoveryRequiredFixCount" to REQUIRED_CONSECUTIVE_FIXES,
                    "deniedGnssQuarantinedFixCount" to deniedGnssQuarantinedFixCount,
                    "deniedGnssUsedByEstimatorCount" to deniedGnssUsedByEstimatorCount,
                ),
            )
        }

        private fun transition(
            next: DemoState,
            message: String,
        ) {
            check(isValidTransition(state, next)) { "Invalid live state transition: $state -> $next" }
            state = next
            emitState(next, message)
        }

        private fun finishStopped(
            reason: String,
            callback: CommandCallback?,
        ) {
            if (!terminal.get() &&
                (state == DemoState.NAVGUARD_ACTIVE || state == DemoState.RECOVERY_PENDING)
            ) {
                flushReorderBuffer(Long.MAX_VALUE)
            }
            if (!terminal.compareAndSet(false, true)) {
                callback?.let { postSuccess(it, commandSnapshot(DemoState.STOPPED)) }
                return
            }
            if (state != DemoState.STOPPED) {
                state = DemoState.STOPPED
                emitState(state, reason)
            }
            cleanupRuntime()
            releaseSession(this)
            callback?.let { postSuccess(it, commandSnapshot(state)) }
        }

        private fun fail(
            code: String,
            message: String,
        ) {
            if (!terminal.compareAndSet(false, true)) return
            state = DemoState.ERROR
            lastState = state
            emit(
                linkedMapOf(
                    "schemaVersion" to SCHEMA_VERSION,
                    "kind" to "error",
                    "state" to state.name,
                    "navigationSource" to navigationSource(state),
                    "message" to message,
                    "errorCode" to code,
                    "routePersisted" to false,
                    "routeUploaded" to false,
                ),
            )
            cleanupRuntime()
            releaseSession(this)
        }

        private fun cleanupRuntime() {
            if (locationRegistered) runCatching { locationManager.removeUpdates(this) }
            locationRegistered = false
            if (listenersRegistered) runCatching { sensorManager.unregisterListener(this) }
            listenersRegistered = false
            pendingEvents.clear()
            eventHistory.clear()
            seenStepEventTimestamps.clear()
            historyBaseSnapshot = null
            historyBaseWatermarkNs = -1L
            latestCausalHeading = null
            historyStartTimestampNs = -1L
            latestRotation = null
            latestOperationalGnss = null
            latestArPose = null
            ekf = null
            adaptiveFusion = null
            stableGnssOrigin = null
            denialOrigin = null
            worker?.removeCallbacksAndMessages(null)
            arWorker?.removeCallbacksAndMessages(null)
            arWorker?.post(::cleanupArCore)
            workerThread.quitSafely()
        }

        private fun cleanupArCore() {
            runCatching { referenceAnchor?.detach() }
            referenceAnchor = null
            runCatching { if (arSessionResumed) arCoreSession?.pause() }
            arSessionResumed = false
            runCatching { arCoreSession?.close() }
            arCoreSession = null
            latestArPose = null
            frozenEnuFromInitialDevice = null
            denialOrigin = null
            runCatching { glEnvironment.release() }
            if (arThread.isAlive) arThread.quitSafely()
        }

        private fun nextInsertion(): Long = insertionSequence++

        private fun pendingStepEventCount(): Long = pendingEvents.count { it is StepEvent }.toLong()
    }

    private fun hasPermission(permission: String): Boolean =
        ContextCompat.checkSelfPermission(applicationContext, permission) == PackageManager.PERMISSION_GRANTED

    private fun readArCoreAvailability(): AvailabilitySnapshot {
        val availability = runCatching { ArCoreApk.getInstance().checkAvailability(applicationContext) }.getOrNull()
        return when (availability) {
            ArCoreApk.Availability.SUPPORTED_INSTALLED -> AvailabilitySnapshot(true, true)
            ArCoreApk.Availability.SUPPORTED_APK_TOO_OLD,
            ArCoreApk.Availability.SUPPORTED_NOT_INSTALLED,
            -> AvailabilitySnapshot(true, false)
            else -> AvailabilitySnapshot(false, false)
        }
    }

    private fun postSuccess(
        callback: CommandCallback,
        snapshot: Map<String, Any?>,
    ) {
        mainHandler.post { callback.onSuccess(snapshot) }
    }

    private fun postError(
        callback: CommandCallback,
        code: String,
        message: String,
    ) {
        mainHandler.post { callback.onError(code, message) }
    }

    private fun commandSnapshot(state: DemoState): Map<String, Any?> =
        linkedMapOf(
            "schemaVersion" to SCHEMA_VERSION,
            "snapshotKind" to "live_navguard_demo_command",
            "state" to state.name,
            "demoRunning" to state.isActive,
        )

    private enum class DemoState {
        IDLE,
        PREPARING,
        GNSS_ACTIVE,
        NAVGUARD_READY,
        NAVGUARD_ACTIVE,
        RECOVERY_PENDING,
        GNSS_RECOVERED,
        STOPPED,
        ERROR,
        ;

        val isActive: Boolean
            get() = this != IDLE && this != STOPPED && this != ERROR
    }

    private enum class FusionMode(val id: String) {
        V1(CONFIG_D1_ID),
        ADAPTIVE_V2(NavguardAdaptiveFusionV2.CONFIG_ID),
        ;

        companion object {
            fun fromId(id: String): FusionMode? = entries.firstOrNull { it.id == id }
        }
    }

    private enum class Quality {
        GOOD,
        USABLE,
        DEGRADED,
        UNRELIABLE,
        UNAVAILABLE,
        UNKNOWN,
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
        val generationNs: Long,
        val eastM: Double,
        val northM: Double,
    )

    private data class RotationSample(
        val timestampNs: Long,
        val trueHeadingRad: Double,
        val quality: Quality,
        val trueEnuDevice: DoubleArray,
    )

    private data class HeadingSample(
        val timestampNs: Long,
        val headingRad: Double,
        val quality: Quality,
    )

    private data class EstimatorSnapshot(
        val x: DoubleArray,
        val p: DoubleArray,
        val adaptiveSnapshot: NavguardAdaptiveFusionV2.Snapshot?,
        val headingQuality: Quality,
        val pdrQuality: Quality,
        val arCoreQuality: Quality,
        val fusionQuality: Quality,
        val latestCausalHeading: HeadingSample?,
        val headingUpdateCount: Long,
        val pdrPredictionCount: Long,
        val arCoreUpdateCount: Long,
        val stepEventsRejectedNoCausalHeading: Long,
    )

    private data class HistoryEntry(
        val event: InternalEvent,
        val beforeSnapshot: EstimatorSnapshot,
    )

    private sealed class InternalEvent(
        val timestampNs: Long,
        val insertionIndex: Long,
        val priority: Int,
    )

    private class HeadingEvent(
        timestampNs: Long,
        insertionIndex: Long,
        val headingRad: Double,
        val quality: Quality,
    ) : InternalEvent(timestampNs, insertionIndex, 0)

    private class StepEvent(
        timestampNs: Long,
        insertionIndex: Long,
    ) : InternalEvent(timestampNs, insertionIndex, 1)

    private class ArcoreEvent(
        timestampNs: Long,
        insertionIndex: Long,
        val eastM: Double,
        val northM: Double,
        val quality: Quality,
    ) : InternalEvent(timestampNs, insertionIndex, 2)

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
            x[2] = normalizeHeading(x[2] + k[2] * innovation)
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
            val determinant = s00 * s11 - s01 * s10
            require(determinant.isFinite() && determinant > 0.0)
            val inverse = doubleArrayOf(s11 / determinant, -s01 / determinant, -s10 / determinant, s00 / determinant)
            val k = DoubleArray(6)
            for (row in 0..2) {
                k[row * 2] = p[row * 3] * inverse[0] + p[(row * 3) + 1] * inverse[2]
                k[(row * 2) + 1] = p[row * 3] * inverse[1] + p[(row * 3) + 1] * inverse[3]
            }
            val innovationEast = eastM - x[0]
            val innovationNorth = northM - x[1]
            x[0] += k[0] * innovationEast + k[1] * innovationNorth
            x[1] += k[2] * innovationEast + k[3] * innovationNorth
            x[2] = normalizeHeading(x[2] + k[4] * innovationEast + k[5] * innovationNorth)
            val ikh = identity()
            for (row in 0..2) {
                ikh[row * 3] -= k[row * 2]
                ikh[(row * 3) + 1] -= k[(row * 2) + 1]
            }
            val krkt =
                DoubleArray(9) { index ->
                    val row = index / 3
                    val column = index % 3
                    r * (k[row * 2] * k[column * 2] + k[(row * 2) + 1] * k[(column * 2) + 1])
                }
            p = symmetrize(addMatrices(multiplyMatrices(multiplyMatrices(ikh, p), transpose(ikh)), krkt))
            validate()
        }

        fun resetPosition(
            eastM: Double,
            northM: Double,
            accuracyM: Double,
        ) {
            require(eastM.isFinite() && northM.isFinite() && accuracyM.isFinite() && accuracyM > 0.0)
            val headingVariance = p[8]
            x[0] = eastM
            x[1] = northM
            val variance = accuracyM * accuracyM
            p = doubleArrayOf(variance, 0.0, 0.0, 0.0, variance, 0.0, 0.0, 0.0, headingVariance)
            validate()
        }

        private fun validate() {
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

    private class LiveGlEnvironment {
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

    private companion object {
        const val SCHEMA_VERSION = 1
        const val GNSS_MIN_TIME_MS = 1_000L
        const val GNSS_MIN_DISTANCE_M = 0.0f
        const val MAX_OPERATIONAL_GNSS_ACCURACY_M = 50.0f
        const val REQUIRED_CONSECUTIVE_FIXES = 3
        const val ROTATION_VECTOR_SAMPLING_PERIOD_US = 20_000
        const val ALIGNMENT_HOLD_NS = 2_000_000_000L
        const val LIVE_REORDER_WINDOW_NS = 250_000_000L
        const val REORDER_FLUSH_PERIOD_MS = 50L
        const val STREAM_PERIOD_NS = 200_000_000L
        const val FIXED_LAG_HISTORY_NS = 12_000_000_000L
        const val MAX_FIXED_LAG_HISTORY_EVENTS = 4096
        const val MAX_GNSS_STABILIZATION_CANDIDATES = 32
        const val WORKER_THREAD_NAME = "NAVGUARD-Live-Worker"
        const val AR_THREAD_NAME = "NAVGUARD-Live-ARCore"
        const val STEP_LENGTH_M = 0.75
        const val BASE_STEP_LENGTH_SIGMA_M = 0.20
        val BASE_STEP_HEADING_PROCESS_SIGMA_RAD = Math.toRadians(5.0)
        val BASE_HEADING_MEASUREMENT_SIGMA_RAD = Math.toRadians(15.0)
        const val BASE_ARCORE_POSITION_SIGMA_M = 0.35
        const val CONFIG_D1_ID = "config_d_navguard_ekf_v1"
        const val TWO_PI = 2.0 * PI
        const val WGS84_SEMI_MAJOR_AXIS_M = 6_378_137.0
        const val WGS84_ECCENTRICITY_SQUARED = 6.69437999014e-3

        const val ERROR_ALREADY_RUNNING = "live_navguard_demo_already_running"
        const val ERROR_INVALID_STATE = "live_navguard_demo_invalid_state"
        const val ERROR_NOT_READY = "live_navguard_demo_not_ready"
        const val ERROR_ANCHOR_REQUIRED = "live_navguard_demo_anchor_required"
        const val ERROR_PERMISSION_REQUIRED = "live_navguard_demo_permission_required"
        const val ERROR_SENSOR_REGISTRATION = "live_navguard_demo_sensor_registration_failed"
        const val ERROR_ARCORE_UNAVAILABLE = "live_navguard_demo_arcore_unavailable"
        const val ERROR_EKF_NUMERICAL = "live_navguard_demo_ekf_numerical_failure"
        const val ERROR_INTERNAL = "internal_live_navguard_demo_error"

        val INTERNAL_EVENT_COMPARATOR =
            Comparator<InternalEvent> { first, second ->
                val timestamp = first.timestampNs.compareTo(second.timestampNs)
                if (timestamp != 0) {
                    timestamp
                } else {
                    val priority = first.priority.compareTo(second.priority)
                    if (priority != 0) priority else first.insertionIndex.compareTo(second.insertionIndex)
                }
            }

        fun isValidAnchor(
            latitudeDeg: Double,
            longitudeDeg: Double,
            altitudeM: Double?,
        ): Boolean =
            latitudeDeg.isFinite() && latitudeDeg in -90.0..90.0 &&
                longitudeDeg.isFinite() && longitudeDeg in -180.0..180.0 &&
                altitudeM?.isFinite() != false

        fun isValidTransition(
            from: DemoState,
            to: DemoState,
        ): Boolean {
            if (to == DemoState.ERROR) return from != DemoState.STOPPED
            if (to == DemoState.STOPPED) return from != DemoState.IDLE && from != DemoState.ERROR
            return when (from) {
                DemoState.IDLE -> to == DemoState.PREPARING
                DemoState.PREPARING -> to == DemoState.GNSS_ACTIVE
                DemoState.GNSS_ACTIVE -> to == DemoState.NAVGUARD_READY
                DemoState.NAVGUARD_READY -> to == DemoState.GNSS_ACTIVE || to == DemoState.NAVGUARD_ACTIVE
                DemoState.NAVGUARD_ACTIVE -> to == DemoState.RECOVERY_PENDING
                DemoState.RECOVERY_PENDING -> to == DemoState.GNSS_RECOVERED
                else -> false
            }
        }

        fun navigationSource(state: DemoState): String =
            if (state == DemoState.NAVGUARD_ACTIVE || state == DemoState.RECOVERY_PENDING) "NAVGUARD" else "GNSS"

        fun classifyHeadingQuality(accuracyRad: Double?): Quality {
            if (accuracyRad == null) return Quality.USABLE
            if (!accuracyRad.isFinite() || accuracyRad < 0.0) return Quality.UNRELIABLE
            val degrees = Math.toDegrees(accuracyRad)
            return when {
                degrees <= 15.0 -> Quality.GOOD
                degrees <= 30.0 -> Quality.USABLE
                degrees <= 45.0 -> Quality.DEGRADED
                else -> Quality.UNRELIABLE
            }
        }

        fun classifyPdrQuality(
            heading: Quality,
            ageNs: Long,
        ): Quality {
            if (ageNs < 0L || heading == Quality.UNAVAILABLE) return Quality.UNAVAILABLE
            if (heading == Quality.UNRELIABLE || heading == Quality.UNKNOWN) return Quality.UNRELIABLE
            val ageMs = ageNs / 1_000_000.0
            if (ageMs > 150.0) return Quality.UNRELIABLE
            if (heading == Quality.DEGRADED || ageMs > 50.0) return Quality.DEGRADED
            return Quality.USABLE
        }

        fun classifyArcoreQuality(gapNs: Long): Quality =
            when {
                gapNs < 0L -> Quality.UNRELIABLE
                gapNs / 1_000_000.0 <= 75.0 -> Quality.GOOD
                gapNs / 1_000_000.0 <= 150.0 -> Quality.USABLE
                gapNs / 1_000_000.0 <= 300.0 -> Quality.DEGRADED
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

        fun Quality.toAdaptive(): AdaptiveSourceQuality =
            when (this) {
                Quality.GOOD -> AdaptiveSourceQuality.GOOD
                Quality.USABLE -> AdaptiveSourceQuality.USABLE
                Quality.DEGRADED -> AdaptiveSourceQuality.DEGRADED
                Quality.UNRELIABLE -> AdaptiveSourceQuality.UNRELIABLE
                Quality.UNAVAILABLE -> AdaptiveSourceQuality.UNAVAILABLE
                Quality.UNKNOWN -> AdaptiveSourceQuality.UNKNOWN
            }

        fun isMockLocation(location: Location): Boolean =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                location.isMock
            } else {
                @Suppress("DEPRECATION")
                location.isFromMockProvider
            }

        fun normalizeHeading(angle: Double): Double {
            var value = angle % TWO_PI
            if (value < 0.0) value += TWO_PI
            return if (value >= TWO_PI) 0.0 else value
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
                for (inner in 0..2) value += left[row * 3 + inner] * right[inner * 3 + column]
                value
            }

        fun transpose(matrix: DoubleArray): DoubleArray =
            DoubleArray(9) { index -> matrix[(index % 3) * 3 + index / 3] }

        fun addMatrices(
            left: DoubleArray,
            right: DoubleArray,
        ): DoubleArray = DoubleArray(9) { left[it] + right[it] }

        fun symmetrize(matrix: DoubleArray): DoubleArray {
            val result = matrix.copyOf()
            for (row in 0..2) {
                for (column in (row + 1)..2) {
                    val average = (matrix[row * 3 + column] + matrix[column * 3 + row]) / 2.0
                    result[row * 3 + column] = average
                    result[column * 3 + row] = average
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
                matrix[row * 3] * vector[0] + matrix[row * 3 + 1] * vector[1] + matrix[row * 3 + 2] * vector[2]
            }

        fun isFinitePose(pose: Pose): Boolean {
            val translation = FloatArray(3)
            val quaternion = FloatArray(4)
            pose.getTranslation(translation, 0)
            pose.getRotationQuaternion(quaternion, 0)
            return translation.all { it.isFinite() } && quaternion.all { it.isFinite() }
        }
    }
}
