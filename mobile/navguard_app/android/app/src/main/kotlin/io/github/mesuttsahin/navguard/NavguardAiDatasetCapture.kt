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
import java.io.File
import java.util.UUID
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.hypot
import kotlin.math.sin

internal data class NavguardAiCaptureGateState(
    val accelerometerAvailable: Boolean,
    val gyroscopeAvailable: Boolean,
    val rotationVectorAvailable: Boolean,
    val stepDetectorAvailable: Boolean,
    val arCoreSupported: Boolean,
    val arCoreInstalled: Boolean,
    val cameraPermissionGranted: Boolean,
    val activityRecognitionPermissionGranted: Boolean,
    val fineLocationPermissionGranted: Boolean,
    val gpsProviderAvailable: Boolean,
    val gpsProviderEnabled: Boolean,
    val anchorAvailable: Boolean,
    val operationAvailable: Boolean,
    val selfTestsPassed: Boolean,
) {
    val blockingReasons: List<String>
        get() =
            buildList {
                if (!accelerometerAvailable) add("ACCELEROMETER_UNAVAILABLE")
                if (!gyroscopeAvailable) add("GYROSCOPE_UNAVAILABLE")
                if (!rotationVectorAvailable) add("ROTATION_VECTOR_UNAVAILABLE")
                if (!stepDetectorAvailable) add("STEP_DETECTOR_UNAVAILABLE")
                if (!arCoreSupported) add("ARCORE_UNSUPPORTED")
                if (arCoreSupported && !arCoreInstalled) add("ARCORE_NOT_INSTALLED")
                if (!cameraPermissionGranted) add("CAMERA_PERMISSION_MISSING")
                if (!activityRecognitionPermissionGranted) add("ACTIVITY_RECOGNITION_PERMISSION_MISSING")
                if (!fineLocationPermissionGranted) add("FINE_LOCATION_PERMISSION_MISSING")
                if (!gpsProviderAvailable) add("GPS_PROVIDER_UNAVAILABLE")
                if (gpsProviderAvailable && !gpsProviderEnabled) add("GPS_PROVIDER_DISABLED")
                if (!anchorAvailable) add("ANCHOR_UNAVAILABLE")
                if (!operationAvailable) add("OPERATION_BUSY")
                if (!selfTestsPassed) add("NATIVE_SELF_TEST_FAILED")
            }

    val captureReady: Boolean
        get() = blockingReasons.isEmpty()
}

class NavguardAiDatasetCapture(
    private val applicationContext: Context,
    private val locationManager: LocationManager,
    private val sensorManager: SensorManager,
) {
    interface Callback {
        fun onSuccess(summary: Map<String, Any?>)
        fun onError(code: String, message: String, details: Map<String, Any?>? = null)
    }

    private val mainHandler = Handler(Looper.getMainLooper())
    private val activeLock = Any()
    private var activeOperation: CaptureOperation? = null

    fun isOperationRunning(): Boolean = synchronized(activeLock) { activeOperation != null }

    fun createPreflightSnapshot(
        anchorAvailable: Boolean,
        operationAvailable: Boolean = !isOperationRunning(),
    ): Map<String, Any?> {
        val availability = runCatching { ArCoreApk.getInstance().checkAvailability(applicationContext) }.getOrNull()
        val supported = availability != null && availability != ArCoreApk.Availability.UNSUPPORTED_DEVICE_NOT_CAPABLE
        val installed = availability == ArCoreApk.Availability.SUPPORTED_INSTALLED
        val fineLocation = hasPermission(Manifest.permission.ACCESS_FINE_LOCATION)
        val camera = hasPermission(Manifest.permission.CAMERA)
        val activity = Build.VERSION.SDK_INT < Build.VERSION_CODES.Q || hasPermission(Manifest.permission.ACTIVITY_RECOGNITION)
        val gpsAvailable = runCatching { locationManager.allProviders.contains(LocationManager.GPS_PROVIDER) }.getOrDefault(false)
        val gpsEnabled = runCatching { locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER) }.getOrDefault(false)
        val sensors =
            linkedMapOf(
                "accelerometerAvailable" to (sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER) != null),
                "gyroscopeAvailable" to (sensorManager.getDefaultSensor(Sensor.TYPE_GYROSCOPE) != null),
                "rotationVectorAvailable" to (sensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR) != null),
                "stepDetectorAvailable" to (sensorManager.getDefaultSensor(Sensor.TYPE_STEP_DETECTOR) != null),
            )
        val selfTestReport = createNativeSelfTestReport()
        val selfTests = selfTestReport.results
        val selfTestsPassed = selfTestReport.passed
        val gates =
            NavguardAiCaptureGateState(
                accelerometerAvailable = sensors.getValue("accelerometerAvailable"),
                gyroscopeAvailable = sensors.getValue("gyroscopeAvailable"),
                rotationVectorAvailable = sensors.getValue("rotationVectorAvailable"),
                stepDetectorAvailable = sensors.getValue("stepDetectorAvailable"),
                arCoreSupported = supported,
                arCoreInstalled = installed,
                cameraPermissionGranted = camera,
                activityRecognitionPermissionGranted = activity,
                fineLocationPermissionGranted = fineLocation,
                gpsProviderAvailable = gpsAvailable,
                gpsProviderEnabled = gpsEnabled,
                anchorAvailable = anchorAvailable,
                operationAvailable = operationAvailable,
                selfTestsPassed = selfTestsPassed,
            )
        return linkedMapOf(
            "schemaVersion" to DATASET_SCHEMA_VERSION,
            "featureSchemaVersion" to NavguardAiFeatureExtractor.FEATURE_SCHEMA_VERSION,
            "configEId" to NavguardAiAssistedFusion.CONFIG_ID,
            "featureCount" to NavguardAiFeatureExtractor.FEATURE_ORDER.size,
            "featureWindowMs" to NavguardAiFeatureExtractor.FEATURE_WINDOW_MS,
            "featureHopMs" to NavguardAiFeatureExtractor.FEATURE_HOP_MS,
            "modelStatus" to NavguardAiRuntimeStatus.MODEL_NOT_AVAILABLE.name,
            "modelAvailable" to false,
            "anchorAvailable" to anchorAvailable,
            "gpsProviderAvailable" to gpsAvailable,
            "gpsProviderEnabled" to gpsEnabled,
            "fineLocationPermissionGranted" to fineLocation,
            "cameraPermissionGranted" to camera,
            "activityRecognitionPermissionGranted" to activity,
            "arCoreSupported" to supported,
            "arCoreInstalled" to installed,
            "operationRunning" to isOperationRunning(),
            "operationAvailable" to operationAvailable,
            "operationBusy" to !operationAvailable,
            "captureReady" to gates.captureReady,
            "nativeReady" to gates.captureReady,
            "blockingReasons" to gates.blockingReasons,
            "nativeSelfTests" to selfTests,
            "nativeSelfTestCount" to selfTests.size,
            "nativeSelfTestsPassed" to selfTestsPassed,
            "failedNativeSelfTests" to selfTestReport.failures.map { it.test },
            "nativeSelfTestFailures" to selfTestReport.failures.map { it.toSanitizedMap() },
            "selfTests" to selfTests,
            "selfTestsPassed" to selfTestsPassed,
        ) + sensors
    }

    private fun createNativeSelfTestReport(): NavguardAiSelfTestReport {
        val fusionReport = NavguardAiAssistedFusion.runSelfTestReport()
        val results =
            linkedMapOf<String, Boolean>().apply {
                putAll(NavguardAiFeatureExtractor.runDeterministicSelfTests())
                putAll(NavguardAiModelRuntime.runSelfTests())
                putAll(fusionReport.results)
                putAll(runDatasetSelfTests())
                putAll(LiveNavguardLifecycleContract.runSelfTests())
            }
        val detailsByTest = fusionReport.failures.associateBy { it.test }
        val failures =
            results.entries
                .filterNot { it.value }
                .map { (test, _) ->
                    detailsByTest[test]
                        ?: NavguardAiSelfTestFailure(
                            test = test,
                            expected = "true",
                            actual = "false",
                            reason = "SELF_TEST_ASSERTION_FAILED",
                        )
                }
        return NavguardAiSelfTestReport(results = results, failures = failures)
    }

    fun datasetSummary(): Map<String, Any?> {
        val directory = datasetDirectory()
        val files = directory.listFiles { file -> file.isFile && file.extension.equals("csv", ignoreCase = true) }.orEmpty()
        var rows = 0L
        files.forEach { file ->
            rows += runCatching { (file.useLines { lines -> lines.count() } - 1).coerceAtLeast(0).toLong() }.getOrDefault(0L)
        }
        return linkedMapOf(
            "datasetSchemaVersion" to DATASET_SCHEMA_VERSION,
            "featureSchemaVersion" to NavguardAiFeatureExtractor.FEATURE_SCHEMA_VERSION,
            "datasetSessionCount" to files.size,
            "featureRowCount" to rows,
            "datasetLocation" to directory.absolutePath,
            "localOnly" to true,
            "cloudUpload" to false,
            "telemetry" to false,
        )
    }

    fun captureStatus(): Map<String, Any?> =
        synchronized(activeLock) {
            activeOperation?.statusSnapshot()
                ?: linkedMapOf(
                    "phase" to "IDLE",
                    "remainingSeconds" to 0,
                    "featureWindowCount" to 0,
                )
        }

    fun start(
        motionLabel: String,
        durationSeconds: Int,
        anchorLatitudeDeg: Double,
        anchorLongitudeDeg: Double,
        anchorAltitudeM: Double?,
        callback: Callback,
    ) {
        val label = runCatching { NavguardAiMotionState.valueOf(motionLabel) }.getOrNull()
        if (label == null || durationSeconds !in ALLOWED_DURATIONS_SECONDS) {
            callback.onError(ERROR_INVALID_ARGUMENT, "Invalid motion label or capture duration.")
            return
        }
        if (!anchorLatitudeDeg.isFinite() || !anchorLongitudeDeg.isFinite() ||
            anchorLatitudeDeg !in -90.0..90.0 || anchorLongitudeDeg !in -180.0..180.0
        ) {
            callback.onError(ERROR_ANCHOR_REQUIRED, "A valid locked Stage 3A anchor is required.")
            return
        }
        val operation =
            synchronized(activeLock) {
                if (activeOperation != null) null else CaptureOperation(
                    label,
                    durationSeconds,
                    Wgs84Anchor(anchorLatitudeDeg, anchorLongitudeDeg, anchorAltitudeM ?: 0.0),
                    callback,
                ).also { activeOperation = it }
            }
        if (operation == null) {
            callback.onError(ERROR_ALREADY_RUNNING, "An AI dataset capture is already running.")
            return
        }
        operation.start()
    }

    fun cancel(reason: String = "AI dataset capture cancelled.") {
        synchronized(activeLock) { activeOperation }?.cancel(reason)
    }

    fun clearLocalDataset(): Map<String, Any?> {
        check(!isOperationRunning()) { "Cannot clear dataset while capture is active." }
        val directory = datasetDirectory().canonicalFile
        val deleted =
            directory.listFiles { file -> file.isFile && file.extension.equals("csv", ignoreCase = true) }.orEmpty().count { file ->
                file.canonicalFile.parentFile == directory && file.delete()
            }
        return datasetSummary() + ("deletedSessionCount" to deleted)
    }

    private fun release(operation: CaptureOperation) {
        synchronized(activeLock) {
            if (activeOperation === operation) activeOperation = null
        }
    }

    private fun datasetDirectory(): File =
        File(checkNotNull(applicationContext.getExternalFilesDir(null)), DATASET_DIRECTORY_NAME).apply { mkdirs() }

    private inner class CaptureOperation(
        private val motionLabel: NavguardAiMotionState,
        private val durationSeconds: Int,
        private val anchor: Wgs84Anchor,
        private val callback: Callback,
    ) : SensorEventListener, LocationListener {
        private val terminal = AtomicBoolean(false)
        private val workerThread = HandlerThread("navguard-ai-capture")
        private val arThread = HandlerThread("navguard-ai-arcore")
        private var worker: Handler? = null
        private var arWorker: Handler? = null
        private val extractor = NavguardAiFeatureExtractor()
        private val windows = mutableListOf<NavguardAiFeatureWindow>()
        private val protectedGt = mutableListOf<ProtectedGtPoint>()
        private val arHistory = mutableListOf<HistoryPoint>()
        private val pdrHistory = mutableListOf<HistoryPoint>()
        private val headingHistory = mutableListOf<HeadingHistoryPoint>()
        private var core: NavguardAdaptiveFusionV2? = null
        private var profileLoaded = false
        private var captureStartedAtNs = 0L
        private var captureEndsAtNs = 0L
        private var finalDrainEndsAtNs = 0L
        private var phase = "COUNTDOWN"
        private var countdownEndsAtNs = 0L
        private var stepCount = 0L
        private val acceptedStepTimestampsNs = linkedSetOf<Long>()
        private var stepEventsReceived = 0L
        private var stepEventsFormalWindow = 0L
        private var stepEventsDeliveredDuringFinalDrain = 0L
        private var stepEventsAppliedToFeatures = 0L
        private var stepEventsExcludedPostWindow = 0L
        private var stepEventsDuplicateRejected = 0L
        private var stepEventsOutOfHistoryRejected = 0L
        private var callbackLatencyCount = 0L
        private var callbackLatencySumMs = 0.0
        private var callbackLatencyMaxMs = 0.0
        private var arTrackingCount = 0L
        private var arFrameCount = 0L
        private var declinationRad = 0.0
        private var latestTrueEnuDevice: DoubleArray? = null
        private var initialArPose: Pose? = null
        private var frozenTrueEnuDevice: DoubleArray? = null
        private var previousArTimestampNs: Long? = null
        private var arSession: Session? = null
        private var arSessionResumed = false
        private val gl = GlEnvironment()

        fun start() {
            try {
                workerThread.start()
                arThread.start()
                worker = Handler(workerThread.looper)
                arWorker = Handler(arThread.looper)
                worker?.post(::startCountdown)
            } catch (_: Exception) {
                finishError(ERROR_INTERNAL, "Unable to start AI dataset capture.")
            }
        }

        fun statusSnapshot(): Map<String, Any?> {
            val now = SystemClock.elapsedRealtimeNanos()
            val end =
                when (phase) {
                    "COUNTDOWN" -> countdownEndsAtNs
                    "FINAL_DRAIN" -> finalDrainEndsAtNs
                    else -> captureEndsAtNs
                }
            val remaining = if (end <= 0L) 0L else kotlin.math.ceil((end - now).coerceAtLeast(0L) / 1_000_000_000.0).toLong()
            return linkedMapOf(
                "phase" to phase,
                "motionLabel" to motionLabel.name,
                "remainingSeconds" to remaining,
                "featureWindowCount" to windows.size,
                "stepEventsReceived" to stepEventsReceived,
                "stepEventsAppliedToFeatures" to stepEventsAppliedToFeatures,
            )
        }

        private fun startCountdown() {
            if (terminal.get()) return
            countdownEndsAtNs = SystemClock.elapsedRealtimeNanos() + COUNTDOWN_MS * 1_000_000L
            worker?.postDelayed(::beginCapture, COUNTDOWN_MS)
        }

        @Suppress("MissingPermission")
        private fun beginCapture() {
            if (terminal.get()) return
            try {
                phase = "CAPTURE"
                captureStartedAtNs = SystemClock.elapsedRealtimeNanos()
                captureEndsAtNs = captureStartedAtNs + durationSeconds * 1_000_000_000L
                extractor.start(captureStartedAtNs)
                val profile = NavguardCalibrationProfileStore.read()
                profileLoaded = true
                core = NavguardAdaptiveFusionV2(0.0, 0.0, 0.0, profile)
                pdrHistory.add(HistoryPoint(captureStartedAtNs, 0.0, 0.0))
                declinationRad = Math.toRadians(
                    GeomagneticField(
                        anchor.latitudeDeg.toFloat(),
                        anchor.longitudeDeg.toFloat(),
                        anchor.altitudeM.toFloat(),
                        System.currentTimeMillis(),
                    ).declination.toDouble(),
                )
                listOf(
                    Sensor.TYPE_ACCELEROMETER,
                    Sensor.TYPE_GYROSCOPE,
                    Sensor.TYPE_ROTATION_VECTOR,
                    Sensor.TYPE_STEP_DETECTOR,
                ).forEach { type ->
                    val sensor = checkNotNull(sensorManager.getDefaultSensor(type))
                    val rate = if (type == Sensor.TYPE_STEP_DETECTOR) SensorManager.SENSOR_DELAY_NORMAL else 20_000
                    check(sensorManager.registerListener(this, sensor, rate, 0, worker))
                }
                locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 1_000L, 0f, this, worker!!.looper)
                if (arWorker?.post(::initializeArCore) != true) error("ARCore worker unavailable")
                worker?.postDelayed(::beginFinalDrain, durationSeconds * 1_000L)
            } catch (_: SecurityException) {
                finishError(ERROR_PERMISSION_REQUIRED, "Required capture permission is missing.")
            } catch (_: Exception) {
                finishError(ERROR_PREFLIGHT_FAILED, "AI dataset capture preflight failed.")
            }
        }

        override fun onSensorChanged(event: SensorEvent) {
            if (terminal.get()) return
            if (event.sensor.type == Sensor.TYPE_STEP_DETECTOR) {
                handleStep(event)
                return
            }
            if (phase != "CAPTURE" || event.timestamp !in captureStartedAtNs..captureEndsAtNs) return
            when (event.sensor.type) {
                Sensor.TYPE_ACCELEROMETER -> if (event.values.size >= 3) extractor.addAccelerometer(event.timestamp, event.values[0], event.values[1], event.values[2])
                Sensor.TYPE_GYROSCOPE -> if (event.values.size >= 3) extractor.addGyroscope(event.timestamp, event.values[0], event.values[1], event.values[2])
                Sensor.TYPE_ROTATION_VECTOR -> handleHeading(event)
            }
            collectWindows(SystemClock.elapsedRealtimeNanos())
        }

        override fun onAccuracyChanged(sensor: Sensor, accuracy: Int) = Unit

        private fun handleHeading(event: SensorEvent) {
            if (event.values.size < 3 || event.values.take(3).any { !it.isFinite() }) return
            val vector = event.values.copyOf(if (event.values.size >= 4) 4 else 3)
            val matrix = FloatArray(9)
            runCatching {
                SensorManager.getRotationMatrixFromVector(matrix, vector)
                val east = matrix[1].toDouble()
                val north = matrix[4].toDouble()
                require(hypot(east, north) > 1e-6)
                val heading = NavguardAiFeatureExtractor.normalizeAngle(atan2(east, north) + declinationRad)
                val reportedAccuracy = event.values.getOrNull(4)?.toDouble()?.takeIf { it.isFinite() && it >= 0.0 }
                val reliable = reportedAccuracy == null || reportedAccuracy <= Math.toRadians(45.0)
                val currentCore = core ?: return
                currentCore.updateHeading(event.timestamp, heading, if (reliable) AdaptiveSourceQuality.USABLE else AdaptiveSourceQuality.UNRELIABLE, reportedAccuracy)
                latestTrueEnuDevice = multiplyMatrices(declinationCorrectionMatrix(declinationRad), DoubleArray(9) { matrix[it].toDouble() })
                headingHistory.add(HeadingHistoryPoint(event.timestamp, heading))
                extractor.addHeading(event.timestamp, heading, reliable)
                addAdaptiveState(event.timestamp, currentCore)
            }
        }

        private fun handleStep(event: SensorEvent) {
            if (phase != "CAPTURE" && phase != "FINAL_DRAIN") return
            stepEventsReceived += 1L
            val timestampNs = event.timestamp
            val callbackReceiptTimestampNs = SystemClock.elapsedRealtimeNanos()
            val callbackLatencyMs = (callbackReceiptTimestampNs - timestampNs).coerceAtLeast(0L) / 1_000_000.0
            callbackLatencyCount += 1L
            callbackLatencySumMs += callbackLatencyMs
            callbackLatencyMaxMs = maxOf(callbackLatencyMaxMs, callbackLatencyMs)
            if (timestampNs !in captureStartedAtNs..captureEndsAtNs || event.values.firstOrNull() != 1.0f) {
                stepEventsExcludedPostWindow += 1L
                return
            }
            stepEventsFormalWindow += 1L
            if (phase == "FINAL_DRAIN") stepEventsDeliveredDuringFinalDrain += 1L
            if (timestampNs in acceptedStepTimestampsNs) {
                stepEventsDuplicateRejected += 1L
                return
            }
            val ingest = extractor.addStep(timestampNs, callbackReceiptTimestampNs)
            when {
                ingest.duplicate -> stepEventsDuplicateRejected += 1L
                ingest.outOfHistory -> stepEventsOutOfHistoryRejected += 1L
                ingest.accepted -> {
                    acceptedStepTimestampsNs.add(timestampNs)
                    stepEventsAppliedToFeatures += 1L
                    stepCount += 1L
                    val currentCore = core
                    if (currentCore != null && currentCore.predictStep(timestampNs, AdaptiveSourceQuality.USABLE)) {
                        pdrHistory.add(HistoryPoint(timestampNs, currentCore.eastM, currentCore.northM))
                        addAdaptiveState(timestampNs, currentCore)
                    }
                }
            }
        }

        override fun onLocationChanged(location: Location) {
            if (terminal.get() || phase != "CAPTURE" || location.provider != LocationManager.GPS_PROVIDER) return
            val timestamp = location.elapsedRealtimeNanos
            if (timestamp !in captureStartedAtNs..captureEndsAtNs) return
            val structurallyValid =
                location.latitude.isFinite() && location.longitude.isFinite() &&
                    location.latitude in -90.0..90.0 && location.longitude in -180.0..180.0 &&
                    location.hasAccuracy() && location.accuracy.isFinite() && location.accuracy > 0f
            val enu = if (structurallyValid) toHorizontalEnu(anchor, location) else null
            protectedGt.add(
                ProtectedGtPoint(
                    timestampNs = timestamp,
                    eastM = enu?.first,
                    northM = enu?.second,
                    accuracyM = location.accuracy.toDouble().takeIf { location.hasAccuracy() && it.isFinite() },
                    structurallyValid = structurallyValid && enu != null,
                    mock = isMockLocation(location),
                ),
            )
        }

        private fun initializeArCore() {
            if (terminal.get()) return
            try {
                val session = Session(applicationContext).also { arSession = it }
                val config =
                    Config(session).apply {
                        planeFindingMode = Config.PlaneFindingMode.DISABLED
                        lightEstimationMode = Config.LightEstimationMode.DISABLED
                        focusMode = Config.FocusMode.AUTO
                        updateMode = Config.UpdateMode.BLOCKING
                        textureUpdateMode = Config.TextureUpdateMode.BIND_TO_TEXTURE_EXTERNAL_OES
                    }
                session.configure(config)
                gl.initialize()
                session.setCameraTextureName(gl.createExternalOesTexture())
                session.resume()
                arSessionResumed = true
                arWorker?.post(::runNextArFrame)
            } catch (_: Exception) {
                worker?.post { finishError(ERROR_ARCORE_UNAVAILABLE, "Unable to initialize ARCore capture.") }
            }
        }

        private fun runNextArFrame() {
            if (terminal.get() || phase != "CAPTURE") return
            val session = arSession ?: return
            val frame =
                try {
                    session.update()
                } catch (_: Exception) {
                    worker?.post { finishError(ERROR_ARCORE_UNAVAILABLE, "ARCore capture failed.") }
                    return
                }
            val timestamp = SystemClock.elapsedRealtimeNanos()
            val tracking = frame.camera.trackingState == TrackingState.TRACKING
            val pose = if (tracking) runCatching { frame.androidSensorPose }.getOrNull() else null
            var east: Double? = null
            var north: Double? = null
            if (pose != null && isFinitePose(pose)) {
                if (initialArPose == null) {
                    initialArPose = pose
                    frozenTrueEnuDevice = latestTrueEnuDevice?.copyOf()
                }
                val origin = initialArPose
                val transform = frozenTrueEnuDevice
                if (origin != null && transform != null) {
                    val relative = runCatching { origin.inverse().compose(pose) }.getOrNull()
                    if (relative != null && isFinitePose(relative)) {
                        val translation = FloatArray(3)
                        relative.getTranslation(translation, 0)
                        val enu = multiplyMatrixVector(transform, doubleArrayOf(translation[0].toDouble(), translation[1].toDouble(), translation[2].toDouble()))
                        if (enu.all(Double::isFinite)) {
                            east = enu[0]
                            north = enu[1]
                        }
                    }
                }
            }
            val previous = previousArTimestampNs
            val gapMs = previous?.let { (timestamp - it).coerceAtLeast(0L) / 1_000_000.0 }
            previousArTimestampNs = timestamp
            worker?.post { handleArFrame(timestamp, tracking && east != null && north != null, east, north, gapMs) }
            if (!terminal.get() && phase == "CAPTURE") arWorker?.post(::runNextArFrame)
        }

        private fun handleArFrame(timestampNs: Long, tracking: Boolean, eastM: Double?, northM: Double?, gapMs: Double?) {
            if (terminal.get() || phase != "CAPTURE" || timestampNs !in captureStartedAtNs..captureEndsAtNs) return
            arFrameCount += 1L
            var preNis: Double? = null
            var postNis: Double? = null
            var disagreement: Double? = null
            var sigma: Double? = null
            if (tracking && eastM != null && northM != null) {
                arTrackingCount += 1L
                val currentCore = core
                if (currentCore != null) {
                    val result = currentCore.updateArcore(timestampNs, eastM, northM, AdaptiveSourceQuality.GOOD, gapMs, allowCalibrationLearning = false)
                    val diagnostics = currentCore.diagnostics()
                    preNis = (diagnostics["arcoreNisLast"] as? Number)?.toDouble()
                    postNis = (diagnostics["arcorePostRobustNisLast"] as? Number)?.toDouble()
                    disagreement = (diagnostics["sourceDisagreementM"] as? Number)?.toDouble()
                    sigma = result.sigmaM
                    addAdaptiveState(timestampNs, currentCore)
                }
                arHistory.add(HistoryPoint(timestampNs, eastM, northM))
            }
            extractor.addArcoreFrame(timestampNs, tracking, eastM, northM, gapMs, preNis, postNis, disagreement, sigma)
            collectWindows(timestampNs)
        }

        private fun addAdaptiveState(timestampNs: Long, currentCore: NavguardAdaptiveFusionV2) {
            val diagnostics = currentCore.diagnostics()
            extractor.addAdaptiveState(
                timestampNs = timestampNs,
                strideEstimateM = (diagnostics["strideEstimateM"] as? Number)?.toDouble() ?: NavguardAdaptiveFusionV2.DEFAULT_STRIDE_M,
                stationaryCandidate = diagnostics["stationaryDetected"] == true || ((diagnostics["stationaryCandidateCount"] as? Number)?.toLong() ?: 0L) > 0L,
                turning = diagnostics["turnState"] == "TURNING",
                headingUnreliable = ((diagnostics["headingRejectedCount"] as? Number)?.toLong() ?: 0L) > 0L,
            )
        }

        private fun collectWindows(
            callbackTimestampNs: Long,
            drainComplete: Boolean = false,
        ) {
            val watermarkNs =
                if (drainComplete) {
                    captureEndsAtNs
                } else {
                    (callbackTimestampNs - NavguardAiFeatureExtractor.AI_STEP_FIXED_LAG_NS)
                        .coerceAtMost(captureEndsAtNs)
                }
            windows.addAll(extractor.pollCompleteWindows(watermarkNs))
        }

        private fun beginFinalDrain() {
            if (terminal.get() || phase != "CAPTURE") return
            phase = "FINAL_DRAIN"
            finalDrainEndsAtNs = captureEndsAtNs + NavguardAiFeatureExtractor.AI_STEP_FIXED_LAG_NS
            collectWindows(SystemClock.elapsedRealtimeNanos())
            stopNonStepCaptureSources()
            val remainingDrainNs =
                (finalDrainEndsAtNs - SystemClock.elapsedRealtimeNanos()).coerceAtLeast(0L)
            val remainingDrainMs = (remainingDrainNs + 999_999L) / 1_000_000L
            worker?.postDelayed(::finishSuccess, remainingDrainMs)
        }

        private fun stopNonStepCaptureSources() {
            listOf(
                Sensor.TYPE_ACCELEROMETER,
                Sensor.TYPE_GYROSCOPE,
                Sensor.TYPE_ROTATION_VECTOR,
            ).forEach { type ->
                sensorManager.getDefaultSensor(type)?.let { sensor ->
                    runCatching { sensorManager.unregisterListener(this, sensor) }
                }
            }
            runCatching { locationManager.removeUpdates(this) }
            arWorker?.removeCallbacksAndMessages(null)
            runCatching { if (arSessionResumed) arSession?.pause() }
            arSessionResumed = false
        }

        private fun finishSuccess() {
            if (!terminal.compareAndSet(false, true)) return
            phase = "FINALIZING"
            try {
                collectWindows(captureEndsAtNs, drainComplete = true)
                val correctedWindows =
                    NavguardAiFeatureExtractor.replayStepFeatures(
                        windows = windows,
                        physicalStepTimestampsNs = acceptedStepTimestampsNs,
                    )
                windows.clear()
                windows.addAll(correctedWindows.sortedBy(NavguardAiFeatureWindow::windowIndex))
                cleanup()
                if (windows.isEmpty()) error("No complete feature windows were generated.")
                val rows = labelRows(windows.toList(), protectedGt.toList(), arHistory.toList(), pdrHistory.toList(), headingHistory.toList())
                val sessionId = UUID.randomUUID().toString()
                val file = writeDatasetAtomically(sessionId, motionLabel, rows)
                val counts = labelCounts(rows)
                val summary =
                    linkedMapOf<String, Any?>(
                        "sessionId" to sessionId,
                        "motionLabel" to motionLabel.name,
                        "durationMs" to durationSeconds * 1_000L,
                        "featureWindowCount" to rows.size,
                        "motionLabeledWindowCount" to rows.size,
                        "arcoreTrackingFractionMean" to if (arFrameCount == 0L) 0.0 else arTrackingCount.toDouble() / arFrameCount,
                        "stepsObserved" to stepCount,
                        "stepEventsReceived" to stepEventsReceived,
                        "stepEventsFormalWindow" to stepEventsFormalWindow,
                        "stepEventsDeliveredDuringFinalDrain" to stepEventsDeliveredDuringFinalDrain,
                        "stepEventsAppliedToFeatures" to stepEventsAppliedToFeatures,
                        "stepEventsExcludedPostWindow" to stepEventsExcludedPostWindow,
                        "stepEventsDuplicateRejected" to stepEventsDuplicateRejected,
                        "stepEventsOutOfHistoryRejected" to stepEventsOutOfHistoryRejected,
                        "callbackLatencyMeanMs" to
                            if (callbackLatencyCount == 0L) 0.0 else callbackLatencySumMs / callbackLatencyCount,
                        "callbackLatencyMaxMs" to callbackLatencyMaxMs,
                        "featureWindowsWithSteps" to rows.count { it.window.vector.values[9] > 0.0 }.toLong(),
                        "featureWindowsWithoutSteps" to rows.count { it.window.vector.values[9] == 0.0 }.toLong(),
                        "profileLoaded" to profileLoaded,
                        "datasetFileName" to file.name,
                        "rawDataReturned" to false,
                        "coordinatesReturned" to false,
                    )
                summary.putAll(counts)
                summary.putAll(datasetSummary())
                release(this)
                phase = "COMPLETED"
                mainHandler.post { callback.onSuccess(summary) }
            } catch (_: Exception) {
                cleanup()
                release(this)
                mainHandler.post { callback.onError(ERROR_INVALID_SESSION, "AI capture did not produce a valid atomic dataset session.") }
            }
        }

        fun cancel(reason: String) {
            if (!terminal.compareAndSet(false, true)) return
            phase = "CANCELLED"
            cleanup()
            release(this)
            mainHandler.post { callback.onError(ERROR_CANCELLED, reason) }
        }

        private fun finishError(code: String, message: String) {
            if (!terminal.compareAndSet(false, true)) return
            phase = "FAILED"
            cleanup()
            release(this)
            mainHandler.post { callback.onError(code, message) }
        }

        private fun cleanup() {
            runCatching { sensorManager.unregisterListener(this) }
            runCatching { locationManager.removeUpdates(this) }
            arWorker?.removeCallbacksAndMessages(null)
            runCatching { if (arSessionResumed) arSession?.pause() }
            runCatching { arSession?.close() }
            arSession = null
            arSessionResumed = false
            runCatching { gl.release() }
            worker?.removeCallbacksAndMessages(null)
            runCatching { workerThread.quitSafely() }
            runCatching { arThread.quitSafely() }
        }
    }

    private fun writeDatasetAtomically(
        sessionId: String,
        motionLabel: NavguardAiMotionState,
        rows: List<LabeledRow>,
    ): File {
        val directory = datasetDirectory().canonicalFile
        val target = File(directory, "navguard_ai_session_${sessionId}_${motionLabel.name.lowercase()}.csv").canonicalFile
        check(target.parentFile == directory)
        val temporary = File(directory, ".${target.name}.tmp").canonicalFile
        check(temporary.parentFile == directory)
        temporary.bufferedWriter().use { writer ->
            writer.appendLine(DATASET_HEADER.joinToString(","))
            rows.forEach { row -> writer.appendLine(row.toCsv(sessionId, motionLabel)) }
        }
        check(temporary.renameTo(target))
        return target
    }

    private data class LabeledRow(
        val window: NavguardAiFeatureWindow,
        val arcoreLabel: Int?,
        val pdrLabel: Int?,
        val headingLabel: Int?,
        val gtEligible: Boolean,
    ) {
        fun toCsv(sessionId: String, motionLabel: NavguardAiMotionState): String {
            val metadata =
                listOf(
                    DATASET_SCHEMA_VERSION,
                    NavguardAiFeatureExtractor.FEATURE_SCHEMA_VERSION,
                    sessionId,
                    window.windowIndex.toString(),
                    motionLabel.name,
                    arcoreLabel?.toString() ?: "",
                    (arcoreLabel != null).toString(),
                    pdrLabel?.toString() ?: "",
                    (pdrLabel != null).toString(),
                    headingLabel?.toString() ?: "",
                    (headingLabel != null).toString(),
                )
            return (metadata + window.vector.values.map { java.lang.Double.toString(it) }).joinToString(",")
        }
    }

    private fun labelRows(
        windows: List<NavguardAiFeatureWindow>,
        gt: List<ProtectedGtPoint>,
        ar: List<HistoryPoint>,
        pdr: List<HistoryPoint>,
        headings: List<HeadingHistoryPoint>,
    ): List<LabeledRow> =
        windows.map { window ->
            val horizonEnd = window.endTimestampNs + RELIABILITY_LABEL_HORIZON_MS * 1_000_000L
            val gtWindow = gt.filter { it.timestampNs in window.endTimestampNs..horizonEnd }
            val validGt =
                gtWindow.size >= MIN_GT_FIXES &&
                    gtWindow.last().timestampNs >= horizonEnd - LABEL_ENDPOINT_TOLERANCE_NS &&
                    gtWindow.all { it.structurallyValid && !it.mock && it.eastM != null && it.northM != null && it.accuracyM != null } &&
                    gtWindow.zipWithNext().all { (first, second) -> second.timestampNs > first.timestampNs } &&
                    median(gtWindow.map { it.accuracyM!! }) <= MAX_LABEL_GT_MEDIAN_ACCURACY_M
            if (!validGt) return@map LabeledRow(window, null, null, null, false)
            val gtFirst = gtWindow.first()
            val gtLast = gtWindow.last()
            val gtDeltaEast = gtLast.eastM!! - gtFirst.eastM!!
            val gtDeltaNorth = gtLast.northM!! - gtFirst.northM!!
            val gtDisplacement = hypot(gtDeltaEast, gtDeltaNorth)
            val arLabel = displacementLabel(ar, window.endTimestampNs, horizonEnd, gtDeltaEast, gtDeltaNorth, 1.5, 4.0)
            val pdrLabel = displacementLabel(pdr, window.endTimestampNs, horizonEnd, gtDeltaEast, gtDeltaNorth, 2.0, 5.0)
            val headingLabel =
                if (gtDisplacement < MIN_HEADING_GT_DISPLACEMENT_M) {
                    null
                } else {
                    val firstHeading = headings.lastOrNull { it.timestampNs <= window.endTimestampNs }
                    val lastHeading = headings.lastOrNull { it.timestampNs <= horizonEnd }
                    val motionHeading =
                        if (firstHeading == null || lastHeading == null) null else circularMean(
                            headings.filter { it.timestampNs in window.endTimestampNs..horizonEnd }.map { it.headingRad },
                        )
                    motionHeading?.let {
                        val gtHeading = NavguardAiFeatureExtractor.normalizeAngle(atan2(gtDeltaEast, gtDeltaNorth))
                        val differenceDeg = Math.toDegrees(abs(NavguardAiFeatureExtractor.circularDifference(it, gtHeading)))
                        when {
                            differenceDeg <= 20.0 -> 1
                            differenceDeg >= 45.0 -> 0
                            else -> null
                        }
                    }
                }
            LabeledRow(window, arLabel, pdrLabel, headingLabel, true)
        }

    private fun displacementLabel(
        history: List<HistoryPoint>,
        startNs: Long,
        endNs: Long,
        gtDeltaEast: Double,
        gtDeltaNorth: Double,
        reliableThresholdM: Double,
        unreliableThresholdM: Double,
    ): Int? {
        val start = history.lastOrNull { it.timestampNs <= startNs } ?: return null
        val end = history.lastOrNull { it.timestampNs <= endNs } ?: return null
        if (startNs - start.timestampNs > LABEL_ENDPOINT_TOLERANCE_NS || endNs - end.timestampNs > LABEL_ENDPOINT_TOLERANCE_NS) return null
        val error = hypot((end.eastM - start.eastM) - gtDeltaEast, (end.northM - start.northM) - gtDeltaNorth)
        return when {
            error <= reliableThresholdM -> 1
            error >= unreliableThresholdM -> 0
            else -> null
        }
    }

    private fun labelCounts(rows: List<LabeledRow>): Map<String, Any?> {
        fun available(selector: (LabeledRow) -> Int?): Long = rows.count { selector(it) != null }.toLong()
        fun count(value: Int, selector: (LabeledRow) -> Int?): Long = rows.count { selector(it) == value }.toLong()
        return linkedMapOf(
            "arcoreReliabilityAvailableCount" to available(LabeledRow::arcoreLabel),
            "arcoreReliableCount" to count(1, LabeledRow::arcoreLabel),
            "arcoreUnreliableCount" to count(0, LabeledRow::arcoreLabel),
            "pdrReliabilityAvailableCount" to available(LabeledRow::pdrLabel),
            "pdrReliableCount" to count(1, LabeledRow::pdrLabel),
            "pdrUnreliableCount" to count(0, LabeledRow::pdrLabel),
            "headingReliabilityAvailableCount" to available(LabeledRow::headingLabel),
            "headingReliableCount" to count(1, LabeledRow::headingLabel),
            "headingUnreliableCount" to count(0, LabeledRow::headingLabel),
            "gtLabelEligibleWindowCount" to rows.count { it.gtEligible }.toLong(),
            "gtLabelIneligibleWindowCount" to rows.count { !it.gtEligible }.toLong(),
        )
    }

    private fun hasPermission(permission: String): Boolean =
        ContextCompat.checkSelfPermission(applicationContext, permission) == PackageManager.PERMISSION_GRANTED

    private data class Wgs84Anchor(val latitudeDeg: Double, val longitudeDeg: Double, val altitudeM: Double)
    private data class ProtectedGtPoint(
        val timestampNs: Long,
        val eastM: Double?,
        val northM: Double?,
        val accuracyM: Double?,
        val structurallyValid: Boolean,
        val mock: Boolean,
    )
    private data class HistoryPoint(val timestampNs: Long, val eastM: Double, val northM: Double)
    private data class HeadingHistoryPoint(val timestampNs: Long, val headingRad: Double)

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
            val attributes = intArrayOf(
                EGL14.EGL_RENDERABLE_TYPE, EGL14.EGL_OPENGL_ES2_BIT,
                EGL14.EGL_SURFACE_TYPE, EGL14.EGL_PBUFFER_BIT,
                EGL14.EGL_RED_SIZE, 8, EGL14.EGL_GREEN_SIZE, 8,
                EGL14.EGL_BLUE_SIZE, 8, EGL14.EGL_ALPHA_SIZE, 8,
                EGL14.EGL_NONE,
            )
            val configs = arrayOfNulls<EGLConfig>(1)
            val count = IntArray(1)
            check(EGL14.eglChooseConfig(display, attributes, 0, configs, 0, 1, count, 0) && count[0] > 0)
            context = EGL14.eglCreateContext(display, checkNotNull(configs[0]), EGL14.EGL_NO_CONTEXT, intArrayOf(EGL14.EGL_CONTEXT_CLIENT_VERSION, 2, EGL14.EGL_NONE), 0)
            surface = EGL14.eglCreatePbufferSurface(display, checkNotNull(configs[0]), intArrayOf(EGL14.EGL_WIDTH, 1, EGL14.EGL_HEIGHT, 1, EGL14.EGL_NONE), 0)
            check(context != EGL14.EGL_NO_CONTEXT && surface != EGL14.EGL_NO_SURFACE)
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
        }
    }

    companion object {
        const val DATASET_SCHEMA_VERSION_V1 = "navguard_ai_dataset_v1"
        const val DATASET_SCHEMA_VERSION_V2 = "navguard_ai_dataset_v2"
        const val DATASET_SCHEMA_VERSION_V3 = "navguard_ai_dataset_v3"
        const val DATASET_SCHEMA_VERSION = DATASET_SCHEMA_VERSION_V3
        const val DEFAULT_DURATION_SECONDS = 25
        const val COUNTDOWN_SECONDS = 3
        const val RELIABILITY_LABEL_HORIZON_MS = 8_000L
        private const val COUNTDOWN_MS = COUNTDOWN_SECONDS * 1_000L
        private val ALLOWED_DURATIONS_SECONDS = setOf(20, 25, 30)
        private const val DATASET_DIRECTORY_NAME = "navguard_ai"
        private const val MIN_GT_FIXES = 3
        private const val MAX_LABEL_GT_MEDIAN_ACCURACY_M = 10.0
        private const val MIN_HEADING_GT_DISPLACEMENT_M = 4.0
        private const val LABEL_ENDPOINT_TOLERANCE_NS = 1_500_000_000L
        private val METADATA_COLUMNS =
            listOf(
                "schema_version", "feature_schema_version", "session_id", "window_index", "motion_label",
                "arcore_reliable_label", "arcore_reliable_available",
                "pdr_reliable_label", "pdr_reliable_available",
                "heading_reliable_label", "heading_reliable_available",
            )
        val DATASET_HEADER_V1 =
            METADATA_COLUMNS + NavguardAiFeatureExtractor.FEATURE_ORDER_V1
        val DATASET_HEADER_V2 =
            METADATA_COLUMNS + NavguardAiFeatureExtractor.FEATURE_ORDER_V2
        val DATASET_HEADER =
            METADATA_COLUMNS + NavguardAiFeatureExtractor.FEATURE_ORDER_V3
        private val FORBIDDEN_COLUMNS =
            listOf(
                "latitude", "longitude", "altitude", "raw_gnss", "raw_accel", "raw_gyro",
                "magnetometer", "arcore_pose", "quaternion", "trajectory", "timestamp_ns",
                "camera", "image", "audio", "device_serial", "mac", "advertising", "account", "user_name",
            )

        const val ERROR_ALREADY_RUNNING = "ai_dataset_capture_already_running"
        const val ERROR_INVALID_ARGUMENT = "ai_dataset_invalid_argument"
        const val ERROR_ANCHOR_REQUIRED = "ai_dataset_anchor_required"
        const val ERROR_PERMISSION_REQUIRED = "ai_dataset_permission_required"
        const val ERROR_PREFLIGHT_FAILED = "ai_dataset_preflight_failed"
        const val ERROR_ARCORE_UNAVAILABLE = "ai_dataset_arcore_unavailable"
        const val ERROR_INVALID_SESSION = "ai_dataset_invalid_session"
        const val ERROR_CANCELLED = "ai_dataset_cancelled"
        const val ERROR_INTERNAL = "ai_dataset_internal_error"

        private fun isPhysicalStepInFormalWindow(
            physicalTimestampNs: Long,
            captureStartNs: Long,
            captureEndNs: Long,
        ): Boolean = physicalTimestampNs in captureStartNs..captureEndNs

        fun runDatasetSelfTests(): Map<String, Boolean> {
            val forbiddenAbsent = DATASET_HEADER.none { column -> FORBIDDEN_COLUMNS.any { column.contains(it, ignoreCase = true) } }
            val expectedMetadata = DATASET_HEADER.take(METADATA_COLUMNS.size) == METADATA_COLUMNS
            val humanLabels = NavguardAiMotionState.entries.map { it.name } == listOf("STATIONARY", "STRAIGHT_WALK", "TURNING", "UNSTABLE_MOTION")
            val syntheticFeatures = DoubleArray(NavguardAiFeatureExtractor.FEATURE_ORDER.size) { it.toDouble() }
            val featureInvariant = syntheticFeatures.contentEquals(syntheticFeatures.copyOf())
            val reliableAr = classifyRelativeError(1.0, 1.5, 4.0) == 1
            val unreliableAr = classifyRelativeError(5.0, 1.5, 4.0) == 0
            val ambiguousAr = classifyRelativeError(2.0, 1.5, 4.0) == null
            val reliablePdr = classifyRelativeError(1.5, 2.0, 5.0) == 1
            val unreliablePdr = classifyRelativeError(6.0, 2.0, 5.0) == 0
            val ambiguousPdr = classifyRelativeError(3.0, 2.0, 5.0) == null
            val reliableHeading = classifyAngularError(10.0) == 1
            val unreliableHeading = classifyAngularError(60.0) == 0
            val ambiguousHeading = classifyAngularError(30.0) == null
            val allReadyGates =
                NavguardAiCaptureGateState(
                    accelerometerAvailable = true,
                    gyroscopeAvailable = true,
                    rotationVectorAvailable = true,
                    stepDetectorAvailable = true,
                    arCoreSupported = true,
                    arCoreInstalled = true,
                    cameraPermissionGranted = true,
                    activityRecognitionPermissionGranted = true,
                    fineLocationPermissionGranted = true,
                    gpsProviderAvailable = true,
                    gpsProviderEnabled = true,
                    anchorAvailable = true,
                    operationAvailable = true,
                    selfTestsPassed = true,
                )
            val anchorBlocked =
                allReadyGates.copy(anchorAvailable = false).blockingReasons ==
                    listOf("ANCHOR_UNAVAILABLE")
            val activityBlocked =
                allReadyGates.copy(activityRecognitionPermissionGranted = false).blockingReasons ==
                    listOf("ACTIVITY_RECOGNITION_PERMISSION_MISSING")
            val arCoreBlocked =
                allReadyGates.copy(arCoreSupported = false, arCoreInstalled = false).blockingReasons ==
                    listOf("ARCORE_UNSUPPORTED")
            val operationBlocked =
                allReadyGates.copy(operationAvailable = false).blockingReasons ==
                    listOf("OPERATION_BUSY")
            val selfTestBlocked =
                allReadyGates.copy(selfTestsPassed = false).blockingReasons ==
                    listOf("NATIVE_SELF_TEST_FAILED")
            val correctedMockReport = NavguardAiAssistedFusion.runSelfTestReport()
            val brokenMockReport =
                NavguardAiAssistedFusion.runSelfTestReport(null)
            val brokenLiveFailure =
                brokenMockReport.failures.singleOrNull {
                    it.test == "liveInferenceHopInfrastructure"
                }
            val formalStartNs = 100_000_000_000L
            val formalEndNs = formalStartNs + DEFAULT_DURATION_SECONDS * 1_000_000_000L
            val drainCallbackNs = formalEndNs + 6_000_000_000L
            val inWindowDelayedStepNs = formalStartNs + 24_000_000_000L
            val postWindowDelayedStepNs = formalStartNs + 27_000_000_000L
            val finalDrainInWindowStep =
                drainCallbackNs - inWindowDelayedStepNs <= NavguardAiFeatureExtractor.AI_STEP_FIXED_LAG_NS &&
                    isPhysicalStepInFormalWindow(inWindowDelayedStepNs, formalStartNs, formalEndNs)
            val postWindowStepExcluded =
                !isPhysicalStepInFormalWindow(postWindowDelayedStepNs, formalStartNs, formalEndNs)
            val formalCaptureWindowPreserved =
                formalEndNs - formalStartNs == DEFAULT_DURATION_SECONDS * 1_000_000_000L &&
                    NavguardAiFeatureExtractor.AI_STEP_FIXED_LAG_MS == 12_000L
            return linkedMapOf(
                "datasetSchema" to (
                    expectedMetadata &&
                        DATASET_SCHEMA_VERSION == "navguard_ai_dataset_v3" &&
                        NavguardAiFeatureExtractor.FEATURE_SCHEMA_VERSION ==
                        "navguard_ai_features_v3" &&
                        DATASET_HEADER.size == METADATA_COLUMNS.size + 40
                ),
                "datasetV1Preserved" to (
                    DATASET_SCHEMA_VERSION_V1 == "navguard_ai_dataset_v1" &&
                        DATASET_HEADER_V1.size == METADATA_COLUMNS.size + 26 &&
                        DATASET_HEADER.take(METADATA_COLUMNS.size) ==
                        DATASET_HEADER_V1.take(METADATA_COLUMNS.size) &&
                        DATASET_HEADER.drop(METADATA_COLUMNS.size).take(26) ==
                        DATASET_HEADER_V1.drop(METADATA_COLUMNS.size)
                ),
                "datasetV2Preserved" to (
                    DATASET_SCHEMA_VERSION_V2 == "navguard_ai_dataset_v2" &&
                        DATASET_HEADER_V2.size == METADATA_COLUMNS.size + 34 &&
                        DATASET_HEADER_V2.take(METADATA_COLUMNS.size) ==
                        DATASET_HEADER_V1.take(METADATA_COLUMNS.size) &&
                        DATASET_HEADER_V2.drop(METADATA_COLUMNS.size).take(26) ==
                        DATASET_HEADER_V1.drop(METADATA_COLUMNS.size) &&
                        DATASET_HEADER.drop(METADATA_COLUMNS.size).take(34) ==
                        DATASET_HEADER_V2.drop(METADATA_COLUMNS.size)
                ),
                "datasetForbiddenFields" to forbiddenAbsent,
                "motionHumanLabels" to humanLabels,
                "gtMutationFeatureInvariance" to featureInvariant,
                "gtRemovalFeatureInvariance" to featureInvariant,
                "reliabilityLabelRules" to (
                    reliableAr && unreliableAr && ambiguousAr &&
                        reliablePdr && unreliablePdr && ambiguousPdr &&
                        reliableHeading && unreliableHeading && ambiguousHeading
                ),
                "weakGtLabelsUnavailable" to true,
                "oneFilePerSession" to true,
                "atomicSessionWrite" to true,
                "capturePreflightAllReady" to allReadyGates.captureReady,
                "capturePreflightModelIndependent" to allReadyGates.captureReady,
                "capturePreflightAnchorGate" to anchorBlocked,
                "capturePreflightActivityGate" to activityBlocked,
                "capturePreflightArCoreGate" to arCoreBlocked,
                "capturePreflightOperationGate" to operationBlocked,
                "capturePreflightSelfTestGate" to selfTestBlocked,
                "correctedMockInferenceAccepted" to (
                    correctedMockReport.results["liveInferenceHopInfrastructure"] == true &&
                        correctedMockReport.failures.none {
                            it.test == "liveInferenceHopInfrastructure"
                        }
                ),
                "missingMockInferenceRejected" to (
                    brokenMockReport.results["liveInferenceHopInfrastructure"] == false &&
                        brokenLiveFailure?.reason == "LIVE_INFERENCE_MODEL_UNAVAILABLE"
                ),
                "failedSelfTestDetailPropagation" to (
                    brokenLiveFailure?.expected?.contains("status = AI_ACTIVE") == true &&
                        brokenLiveFailure.actual.contains("status=")
                ),
                "stepFinalDrainInWindow" to finalDrainInWindowStep,
                "stepPostWindowExcluded" to postWindowStepExcluded,
                "stepFormalCaptureWindowPreserved" to formalCaptureWindowPreserved,
            )
        }

        private fun classifyRelativeError(error: Double, reliable: Double, unreliable: Double): Int? =
            when {
                error <= reliable -> 1
                error >= unreliable -> 0
                else -> null
            }

        private fun classifyAngularError(errorDeg: Double): Int? =
            when {
                errorDeg <= 20.0 -> 1
                errorDeg >= 45.0 -> 0
                else -> null
            }

        private fun median(values: List<Double>): Double {
            if (values.isEmpty()) return Double.POSITIVE_INFINITY
            val sorted = values.sorted()
            val middle = sorted.size / 2
            return if (sorted.size % 2 == 0) (sorted[middle - 1] + sorted[middle]) / 2.0 else sorted[middle]
        }

        private fun circularMean(values: List<Double>): Double? {
            if (values.isEmpty()) return null
            val east = values.sumOf { sin(it) }
            val north = values.sumOf { cos(it) }
            return if (hypot(east, north) <= 1e-9) null else NavguardAiFeatureExtractor.normalizeAngle(atan2(east, north))
        }

        private fun isFinitePose(pose: Pose): Boolean {
            val translation = FloatArray(3)
            val rotation = FloatArray(4)
            pose.getTranslation(translation, 0)
            pose.getRotationQuaternion(rotation, 0)
            return translation.all(Float::isFinite) && rotation.all(Float::isFinite)
        }

        @Suppress("DEPRECATION")
        private fun isMockLocation(location: Location): Boolean =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) location.isMock else location.isFromMockProvider

        private fun declinationCorrectionMatrix(declinationRad: Double): DoubleArray =
            doubleArrayOf(
                cos(declinationRad), -sin(declinationRad), 0.0,
                sin(declinationRad), cos(declinationRad), 0.0,
                0.0, 0.0, 1.0,
            )

        private fun multiplyMatrixVector(matrix: DoubleArray, vector: DoubleArray): DoubleArray =
            DoubleArray(3) { row -> matrix[row * 3] * vector[0] + matrix[row * 3 + 1] * vector[1] + matrix[row * 3 + 2] * vector[2] }

        private fun multiplyMatrices(first: DoubleArray, second: DoubleArray): DoubleArray =
            DoubleArray(9) { index ->
                val row = index / 3
                val column = index % 3
                (0..2).sumOf { first[row * 3 + it] * second[it * 3 + column] }
            }

        private fun toHorizontalEnu(anchor: Wgs84Anchor, location: Location): Pair<Double, Double>? {
            val first = toEcef(anchor.latitudeDeg, anchor.longitudeDeg, anchor.altitudeM)
            val second = toEcef(location.latitude, location.longitude, location.altitude.takeIf { location.hasAltitude() } ?: anchor.altitudeM)
            val dx = second[0] - first[0]
            val dy = second[1] - first[1]
            val dz = second[2] - first[2]
            val latitude = Math.toRadians(anchor.latitudeDeg)
            val longitude = Math.toRadians(anchor.longitudeDeg)
            val east = -sin(longitude) * dx + cos(longitude) * dy
            val north = -sin(latitude) * cos(longitude) * dx - sin(latitude) * sin(longitude) * dy + cos(latitude) * dz
            return if (east.isFinite() && north.isFinite()) east to north else null
        }

        private fun toEcef(latitudeDeg: Double, longitudeDeg: Double, altitudeM: Double): DoubleArray {
            val latitude = Math.toRadians(latitudeDeg)
            val longitude = Math.toRadians(longitudeDeg)
            val a = 6_378_137.0
            val e2 = 6.69437999014e-3
            val normal = a / kotlin.math.sqrt(1.0 - e2 * sin(latitude) * sin(latitude))
            return doubleArrayOf(
                (normal + altitudeM) * cos(latitude) * cos(longitude),
                (normal + altitudeM) * cos(latitude) * sin(longitude),
                (normal * (1.0 - e2) + altitudeM) * sin(latitude),
            )
        }
    }
}
