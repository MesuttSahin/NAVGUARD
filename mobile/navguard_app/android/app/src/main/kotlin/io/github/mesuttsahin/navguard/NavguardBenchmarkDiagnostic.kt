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
import android.util.Log
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
import kotlin.math.ceil
import kotlin.math.cos
import kotlin.math.sin
import kotlin.math.sqrt

internal class NavguardBenchmarkDiagnostic(
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
    private var activeSession: BenchmarkSession? = null

    fun createPreflightSnapshot(): Map<String, Any?> {
        Log.i(LOG_TAG, "NAVGUARD_BENCHMARK_PREFLIGHT_BEGIN")
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
        val snapshot =
            linkedMapOf<String, Any?>(
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
                            !diagnosticRunning
                    ),
                "currentPhase" to (runningSession?.currentPhase()?.name ?: BenchmarkPhase.IDLE.name),
            )
        Log.i(LOG_TAG, "NAVGUARD_BENCHMARK_PREFLIGHT_END")
        return snapshot
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
        if (!runGroundTruthFirewallSelfTests()) {
            postError(callback, ERROR_NUMERICAL_FAILURE, "The protected-ground-truth firewall self-test failed.")
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
            BenchmarkSession(
                anchor = Wgs84Anchor(anchorLatitudeDeg, anchorLongitudeDeg, anchorAltitudeEllipsoidM),
                rotationVector = rotationVector,
                stepDetector = stepDetector,
                declinationRad = declinationRad,
                callback = callback,
            )
        synchronized(activeSessionLock) {
            if (activeSession != null) {
                postError(callback, ERROR_ALREADY_RUNNING, "A NAVGUARD benchmark is already running.")
                return
            }
            activeSession = session
        }
        Log.i(LOG_TAG, "NAVGUARD_BENCHMARK_BEGIN")
        session.start()
    }

    fun cancelActiveSession(
        message: String = "NAVGUARD benchmark cancelled by the user.",
    ): Boolean {
        val session = synchronized(activeSessionLock) { activeSession } ?: return false
        return session.cancel(message)
    }

    private fun releaseSession(session: BenchmarkSession) {
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

    private inner class BenchmarkSession(
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
        private val capturedEvents = mutableListOf<BenchmarkEvent>()
        private val protectedGroundTruth = mutableListOf<ProtectedBenchmarkGroundTruthFix>()
        private val protectedAccuracyM = mutableListOf<Double>()
        private val headingTimestampSet = mutableSetOf<Long>()
        private val stepTimestampSet = mutableSetOf<Long>()

        @Volatile
        private var phase = BenchmarkPhase.IDLE

        @Volatile
        private var cancellationMessage = "NAVGUARD benchmark cancelled by the user."

        @Volatile
        private var terminalErrorCode = ERROR_INTERNAL

        @Volatile
        private var terminalErrorMessage = "The NAVGUARD benchmark failed."

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
        private var previousOperationalFixNs: Long? = null
        private var previousProtectedGtNs: Long? = null
        private var latestOperationalEnu: EnuFix? = null
        private var acquisitionGoodCount = 0
        private var preDenialAcceptedFixCount = 0L
        private var protectedGtRejectedFixCount = 0L
        private var insertionSequence = 0L
        private var denialStartNs = 0L
        private var denialEndNs = 0L
        private var denialOriginEastM = 0.0
        private var denialOriginNorthM = 0.0
        private var initialDeniedHeading: RotationSample? = null
        private var arcoreCaptureSkipped = 0L
        private var completedSummary: Map<String, Any?>? = null

        private val acquisitionTimeout =
            Runnable {
                if (phase == BenchmarkPhase.PREPARING) {
                    finishWithError(ERROR_GNSS_ACQUISITION_TIMEOUT, "Pre-denial GPS acquisition timed out.")
                }
            }
        private val alignmentTimeout =
            Runnable {
                if (!alignmentCompleted && !completed.get()) {
                    finishWithError(ERROR_ALIGNMENT_TIMEOUT, "ARCore/heading alignment timed out.")
                }
            }
        private val preDenialTimeout = Runnable { beginBenchmarkDenial() }
        private val denialTimeout = Runnable { finalizeBenchmarkWindow() }

        fun currentPhase(): BenchmarkPhase = phase

        fun start() {
            try {
                phase = BenchmarkPhase.PREPARING
                workerThread.start()
                val worker = Handler(workerThread.looper)
                workerHandler = worker
                arThread.start()
                val arWorker = Handler(arThread.looper)
                arHandler = arWorker
                if (!worker.post { initializeRuntime(worker) } || !arWorker.post(::runArCoreLoop)) {
                    finishWithError(ERROR_INTERNAL, "Unable to start benchmark workers.")
                }
            } catch (_: Exception) {
                finishWithError(ERROR_INTERNAL, "Unable to start the NAVGUARD benchmark.")
            }
        }

        @Suppress("MissingPermission")
        private fun initializeRuntime(worker: Handler) {
            if (completed.get()) return
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
                if (!worker.postDelayed(acquisitionTimeout, PRE_DENIAL_ACQUISITION_TIMEOUT_MS) ||
                    !worker.postDelayed(alignmentTimeout, ALIGNMENT_ACQUISITION_TIMEOUT_MS)
                ) {
                    finishWithError(ERROR_INTERNAL, "Unable to schedule benchmark acquisition timeouts.")
                }
            } catch (_: SecurityException) {
                finishWithError(ERROR_LOCATION_PERMISSION_REQUIRED, "A required runtime permission is missing.")
            } catch (_: IllegalArgumentException) {
                finishWithError(ERROR_GPS_UNAVAILABLE, "GPS_PROVIDER could not be registered.")
            } catch (_: Exception) {
                finishWithError(ERROR_INTERNAL, "Unable to register benchmark runtime sources.")
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
                if (phase != BenchmarkPhase.BENCHMARK_DENIAL || sample.timestampNs < denialStartNs) return
                if (!headingTimestampSet.add(sample.timestampNs)) return
                capturedEvents.add(
                    HeadingEvent(
                        timestampNs = sample.timestampNs,
                        insertionIndex = insertionSequence++,
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
                if (phase != BenchmarkPhase.BENCHMARK_DENIAL || event.timestamp < denialStartNs) return
                if (!stepTimestampSet.add(event.timestamp)) return
                capturedEvents.add(StepEvent(event.timestamp, insertionSequence++))
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
                when (phase) {
                    BenchmarkPhase.PREPARING,
                    BenchmarkPhase.PRE_DENIAL,
                    -> handleOperationalFix(location)
                    BenchmarkPhase.BENCHMARK_DENIAL -> collectProtectedGroundTruth(location)
                    else -> Unit
                }
            }
        }

        private fun handleOperationalFix(location: Location) {
            if (!isAcceptableOperationalFix(location, previousOperationalFixNs)) return
            val enu = Wgs84EnuConverter.toHorizontalEnu(anchor, location) ?: return
            previousOperationalFixNs = enu.timestampNs
            latestOperationalEnu = enu
            acquisitionGoodCount += 1
            preDenialAcceptedFixCount += 1L
            maybeEnterPreDenial()
        }

        private fun collectProtectedGroundTruth(location: Location) {
            if (!isStructurallyValidGnss(location)) {
                protectedGtRejectedFixCount += 1L
                return
            }
            val timestamp = location.elapsedRealtimeNanos
            val previous = previousProtectedGtNs
            if (timestamp < denialStartNs || (previous != null && timestamp <= previous)) {
                protectedGtRejectedFixCount += 1L
                return
            }
            val enu = Wgs84EnuConverter.toHorizontalEnu(anchor, location)
            if (enu == null) {
                protectedGtRejectedFixCount += 1L
                return
            }
            previousProtectedGtNs = timestamp
            protectedGroundTruth.add(
                ProtectedBenchmarkGroundTruthFix(
                    timestampNs = timestamp,
                    eastM = enu.eastM,
                    northM = enu.northM,
                    reportedAccuracyM = location.accuracy.toDouble(),
                ),
            )
            protectedAccuracyM.add(location.accuracy.toDouble())
            // Hard firewall: this method does not call replay, quality, stride,
            // heading, ARCore, covariance, tuning, or controller methods.
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
                finishWithError(ERROR_GPS_DISABLED, "GPS_PROVIDER was disabled during the benchmark.")
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
                when (phase) {
                    BenchmarkPhase.PREPARING,
                    BenchmarkPhase.PRE_DENIAL,
                    -> processAlignmentFrame(frame, nowNs)
                    BenchmarkPhase.BENCHMARK_DENIAL -> processBenchmarkArFrame(session, frame)
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
            workerHandler?.post { maybeEnterPreDenial() }
        }

        private fun processBenchmarkArFrame(
            session: Session,
            frame: Frame,
        ) {
            synchronized(stateLock) {
                if (phase != BenchmarkPhase.BENCHMARK_DENIAL) return
                if (frame.camera.trackingState != TrackingState.TRACKING) {
                    arcoreCaptureSkipped += 1L
                    return
                }
                if (referenceAnchor == null) {
                    val pose = runCatching { frame.androidSensorPose }.getOrNull()
                    if (pose == null || !isFinitePose(pose)) {
                        arcoreCaptureSkipped += 1L
                        return
                    }
                    val created = runCatching { session.createAnchor(pose) }.getOrNull()
                    if (created == null || created.trackingState != TrackingState.TRACKING) {
                        created?.detach()
                        arcoreCaptureSkipped += 1L
                        return
                    }
                    referenceAnchor = created
                    previousArFrameTimestampNs = null
                    previousArFusionTimestampNs = null
                    return
                }
                val reference = referenceAnchor ?: return
                if (reference.trackingState != TrackingState.TRACKING) {
                    arcoreCaptureSkipped += 1L
                    return
                }
                val frameTimestamp = frame.timestamp
                val previousFrame = previousArFrameTimestampNs
                if (frameTimestamp <= 0L || (previousFrame != null && frameTimestamp <= previousFrame)) {
                    arcoreCaptureSkipped += 1L
                    return
                }
                previousArFrameTimestampNs = frameTimestamp
                val currentPose = runCatching { frame.androidSensorPose }.getOrNull()
                val relative =
                    if (currentPose == null || !isFinitePose(currentPose)) null else
                        runCatching { reference.pose.inverse().compose(currentPose) }.getOrNull()
                if (relative == null || !isFinitePose(relative)) {
                    arcoreCaptureSkipped += 1L
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
                if (local.any { !it.isFinite() }) {
                    arcoreCaptureSkipped += 1L
                    return
                }
                // Frame.timestamp is used only for duplicate/monotonic checks.
                // Cross-source replay uses elapsed-realtime processing time.
                val fusionTimestamp = SystemClock.elapsedRealtimeNanos()
                val previousFusion = previousArFusionTimestampNs
                val quality =
                    if (previousFusion == null) Quality.USABLE else classifyArcoreQuality(fusionTimestamp - previousFusion)
                previousArFusionTimestampNs = fusionTimestamp
                capturedEvents.add(
                    ArcoreEvent(
                        timestampNs = fusionTimestamp,
                        insertionIndex = insertionSequence++,
                        eastM = denialOriginEastM + local[0],
                        northM = denialOriginNorthM + local[1],
                        quality = quality,
                    ),
                )
            }
        }

        private fun maybeEnterPreDenial() {
            synchronized(stateLock) {
                if (phase != BenchmarkPhase.PREPARING ||
                    acquisitionGoodCount < INITIAL_REQUIRED_CONSECUTIVE_FIXES ||
                    !alignmentCompleted
                ) return
                workerHandler?.removeCallbacks(acquisitionTimeout)
                workerHandler?.removeCallbacks(alignmentTimeout)
                phase = BenchmarkPhase.PRE_DENIAL
                if (workerHandler?.postDelayed(preDenialTimeout, PRE_DENIAL_OBSERVATION_MS) != true) {
                    finishWithError(ERROR_INTERNAL, "Unable to schedule the pre-denial benchmark window.")
                }
            }
        }

        private fun beginBenchmarkDenial() {
            synchronized(stateLock) {
                if (phase != BenchmarkPhase.PRE_DENIAL) return
                val origin = latestOperationalEnu
                val heading = latestRotation
                if (origin == null || heading == null) {
                    finishWithError(ERROR_ALIGNMENT_TIMEOUT, "A continuous GNSS/heading denial origin was unavailable.")
                    return
                }
                denialStartNs = SystemClock.elapsedRealtimeNanos()
                denialOriginEastM = origin.eastM
                denialOriginNorthM = origin.northM
                initialDeniedHeading = heading.copy(trueEnuDevice = heading.trueEnuDevice.copyOf())
                denialTransform = heading.trueEnuDevice.copyOf()
                capturedEvents.clear()
                protectedGroundTruth.clear()
                protectedAccuracyM.clear()
                headingTimestampSet.clear()
                stepTimestampSet.clear()
                insertionSequence = 0L
                previousProtectedGtNs = null
                referenceAnchor?.detach()
                referenceAnchor = null
                previousArFrameTimestampNs = null
                previousArFusionTimestampNs = null
                phase = BenchmarkPhase.BENCHMARK_DENIAL
                if (workerHandler?.postDelayed(denialTimeout, BENCHMARK_DENIED_WINDOW_MS) != true) {
                    finishWithError(ERROR_INTERNAL, "Unable to schedule the benchmark denied window.")
                }
            }
        }

        private fun finalizeBenchmarkWindow() {
            val events: List<BenchmarkEvent>
            val initialHeading: RotationSample
            synchronized(stateLock) {
                if (phase != BenchmarkPhase.BENCHMARK_DENIAL) return
                denialEndNs = SystemClock.elapsedRealtimeNanos()
                phase = BenchmarkPhase.COMPARING
                events = capturedEvents.toList()
                initialHeading = initialDeniedHeading ?: run {
                    finishWithError(ERROR_INVALID_SESSION, "missing_initial_heading")
                    return
                }
            }
            val summary =
                try {
                    createBenchmarkSummary(events, initialHeading)
                } catch (invalid: InvalidBenchmarkException) {
                    finishWithError(ERROR_INVALID_SESSION, invalid.reason)
                    return
                } catch (_: Exception) {
                    finishWithError(ERROR_NUMERICAL_FAILURE, "Benchmark comparison failed numerical validation.")
                    return
                }
            completedSummary = summary
            completionRequested.set(true)
        }

        private fun createBenchmarkSummary(
            events: List<BenchmarkEvent>,
            initialHeading: RotationSample,
        ): Map<String, Any?> {
            val ordered =
                events.sortedWith(
                    compareBy<BenchmarkEvent> { it.timestampNs }
                        .thenBy { it.priority }
                        .thenBy { it.insertionIndex },
                )
            val runs = replayAllConfigs(ordered, initialHeading)
            val gt = synchronized(stateLock) { protectedGroundTruth.toList().sortedBy { it.timestampNs } }
            if (gt.isEmpty()) throw InvalidBenchmarkException("no_accepted_protected_ground_truth")

            val metricsA = compareSnapshots(CONFIG_A_ID, runs.configA.snapshots, gt)
            val metricsB = compareSnapshots(CONFIG_B_ID, runs.configB.snapshots, gt)
            val metricsC = compareSnapshots(CONFIG_C_ID, runs.configC.snapshots, gt)
            val metricsD = compareSnapshots(CONFIG_D_ID, runs.configD.snapshots, gt)
            val metrics = listOf(metricsA, metricsB, metricsC, metricsD)
            if (metrics.any { it.matchedGtCount < 1 }) {
                throw InvalidBenchmarkException("one_or_more_configs_have_zero_matched_ground_truth")
            }
            if (metrics.any { it.matchedGtCount + it.unmatchedGtCount != gt.size }) {
                throw InvalidBenchmarkException("ground_truth_match_count_invariant_failed")
            }

            val dVsA = improvementPercent(metricsA.medianErrorM, metricsD.medianErrorM)
            val bVsA = improvementPercent(metricsA.medianErrorM, metricsB.medianErrorM)
            val cVsA = improvementPercent(metricsA.medianErrorM, metricsC.medianErrorM)
            val dVsB = improvementPercent(metricsB.medianErrorM, metricsD.medianErrorM)
            val dVsC = improvementPercent(metricsC.medianErrorM, metricsD.medianErrorM)
            val accuracy = statistics(synchronized(stateLock) { protectedAccuracyM.toList() })
                ?: throw InvalidBenchmarkException("no_protected_ground_truth_accuracy")
            val durationMs = (denialEndNs - denialStartNs).coerceAtLeast(0L) / NANOS_PER_MILLISECOND

            return linkedMapOf(
                "schemaVersion" to SCHEMA_VERSION,
                "snapshotKind" to SNAPSHOT_KIND_RESULT,
                "success" to true,
                "benchmarkSessionValid" to true,
                "benchmarkInvalidReason" to "none",
                "benchmarkDeniedWindowMs" to BENCHMARK_DENIED_WINDOW_MS,
                "observedBenchmarkDeniedWindowMs" to durationMs,
                "preDenialAcquisitionTimeoutMs" to PRE_DENIAL_ACQUISITION_TIMEOUT_MS,
                "preDenialObservationMs" to PRE_DENIAL_OBSERVATION_MS,
                "preDenialAcceptedFixCount" to preDenialAcceptedFixCount,
                "primaryMetric" to PRIMARY_METRIC,
                "primaryComparison" to PRIMARY_COMPARISON,
                "percentilePolicy" to PERCENTILE_POLICY,
                "configA" to metricsA.toMap(runs.configA.finalState),
                "configB" to metricsB.toMap(runs.configB.finalState),
                "configC" to metricsC.toMap(runs.configC.finalState),
                "configD" to metricsD.toMap(runs.configD.finalState),
                "configAFinalEastM" to runs.configA.finalState.eastM,
                "configAFinalNorthM" to runs.configA.finalState.northM,
                "configBFinalEastM" to runs.configB.finalState.eastM,
                "configBFinalNorthM" to runs.configB.finalState.northM,
                "configCFinalEastM" to runs.configC.finalState.eastM,
                "configCFinalNorthM" to runs.configC.finalState.northM,
                "configDFinalEastM" to runs.configD.finalState.eastM,
                "configDFinalNorthM" to runs.configD.finalState.northM,
                "dVsAMedianImprovementPercent" to dVsA,
                "bVsAMedianImprovementPercent" to bVsA,
                "cVsAMedianImprovementPercent" to cVsA,
                "dVsBMedianImprovementPercent" to dVsB,
                "dVsCMedianImprovementPercent" to dVsC,
                "improvementUnavailableReason" to if (dVsA == null) "config_a_median_effectively_zero" else null,
                "targetImprovementPercent" to TARGET_IMPROVEMENT_PERCENT,
                "dVsATargetMet" to (dVsA != null && dVsA >= TARGET_IMPROVEMENT_PERCENT),
                "protectedGroundTruthAcceptedFixCount" to gt.size,
                "protectedGroundTruthRejectedFixCount" to protectedGtRejectedFixCount,
                "protectedGtReportedAccuracyMinM" to accuracy.min,
                "protectedGtReportedAccuracyMeanM" to accuracy.mean,
                "protectedGtReportedAccuracyMedianM" to accuracy.median,
                "protectedGtReportedAccuracyMaxM" to accuracy.max,
                "configAStepOpportunities" to runs.configA.stepOpportunities,
                "configAStepsApplied" to runs.configA.stepsApplied,
                "configAStepsSkippedNoHeading" to runs.configA.stepsSkippedNoHeading,
                "configBStepPredictionsApplied" to runs.configB.stepsApplied,
                "configBHeadingMeasurementsApplied" to runs.configB.headingsApplied,
                "configBHeadingMeasurementsSkipped" to runs.configB.headingsSkipped,
                "configCArcoreMeasurementsApplied" to runs.configC.arcoreApplied,
                "configCArcoreMeasurementsSkipped" to arcoreCaptureSkipped,
                "configDStepPredictionsApplied" to runs.configD.stepsApplied,
                "configDHeadingMeasurementsApplied" to runs.configD.headingsApplied,
                "configDArcoreMeasurementsApplied" to runs.configD.arcoreApplied,
                "configDStepPredictionsSkippedNoHeading" to runs.configD.stepsSkippedNoHeading,
                "configDStepPredictionsSkippedByQuality" to runs.configD.stepsSkippedByQuality,
                "configDHeadingMeasurementsSkippedByQuality" to runs.configD.headingsSkipped,
                "configDArcoreMeasurementsSkippedByQuality" to (runs.configD.arcoreSkipped + arcoreCaptureSkipped),
                "matchedSessionBenchmarkImplemented" to true,
                "configAImplemented" to true,
                "configBImplemented" to true,
                "configCImplemented" to true,
                "configDImplemented" to true,
                "protectedGroundTruthCollectorImplemented" to true,
                "benchmarkComparatorImplemented" to true,
                "benchmarkGroundTruthMutationInvariancePassed" to true,
                "benchmarkGroundTruthRemovalInvariancePassed" to true,
                "captureOnceReplayManyUsed" to true,
                "identicalDenialOriginUsed" to true,
                "initialDenialSnapshotUsed" to true,
                "causalGroundTruthMatchingUsed" to true,
                "futureEstimatorStateUsedForGroundTruthMatch" to false,
                "groundTruthInterpolationUsed" to false,
                "protectedGroundTruthAvailableToEstimators" to false,
                "protectedGroundTruthUsedByConfigA" to false,
                "protectedGroundTruthUsedByConfigB" to false,
                "protectedGroundTruthUsedByConfigC" to false,
                "protectedGroundTruthUsedByConfigD" to false,
                "protectedGroundTruthUsedByQualityEngine" to false,
                "groundTruthCorrectionApplied" to false,
                "gnssRecoveryAppliedDuringBenchmark" to false,
                "gnssProvider" to "GPS_PROVIDER",
                "protectedGroundTruthTimestampAuthority" to "Location.getElapsedRealtimeNanos",
                "sensorTimestampAuthority" to "SensorEvent.timestamp",
                "arcoreFusionOrderingTimestampAuthority" to "SystemClock.elapsedRealtimeNanos",
                "arcoreFrameTimestampUsedForFusionOrdering" to false,
                "equalTimestampPriority" to "HEADING,STEP,ARCORE_POSITION",
                "headingAssociationPolicy" to "greatest_valid_heading_at_or_before_step_timestamp",
                "stepLengthM" to STEP_LENGTH_M,
                "stepSigmaM" to BASE_STEP_LENGTH_SIGMA_M,
                "stepHeadingProcessSigmaDeg" to 5.0,
                "headingMeasurementSigmaDeg" to 15.0,
                "arcorePositionSigmaM" to BASE_ARCORE_POSITION_SIGMA_M,
                "josephCovarianceUpdateUsed" to true,
                "circularHeadingInnovationUsed" to true,
                "benchmarkAccuracyValidated" to false,
                "protectedGroundTruthAccuracyValidated" to false,
                "stepDetectionAccuracyValidated" to false,
                "stepLengthValidated" to false,
                "headingAccuracyValidated" to false,
                "arcorePositionAccuracyValidated" to false,
                "noiseParametersValidated" to false,
                "qualityThresholdsValidated" to false,
                "rawGnssCoordinatesReturned" to false,
                "rawProtectedGroundTruthReturned" to false,
                "rawSensorSamplesReturned" to false,
                "rawArcorePosesReturned" to false,
                "rawTrajectoryReturned" to false,
                "rawTimestampsReturned" to false,
                "cameraImagesReturned" to false,
                "persistenceUsed" to false,
            )
        }

        private fun replayAllConfigs(
            ordered: List<BenchmarkEvent>,
            initialHeading: RotationSample,
        ): AllConfigRuns {
            val configA = replayConfigA(ordered, initialHeading)
            val configB = replayEkfConfig(ordered, initialHeading, consumeArcore = false)
            val configC = replayConfigC(ordered, initialHeading)
            val configD = replayEkfConfig(ordered, initialHeading, consumeArcore = true)
            return AllConfigRuns(configA, configB, configC, configD)
        }

        private fun initialSnapshot(headingRad: Double): Pair<EstimatorState, MutableList<StateSnapshot>> {
            val state = EstimatorState(denialOriginEastM, denialOriginNorthM, normalizeHeading(headingRad))
            return Pair(state, mutableListOf(StateSnapshot(denialStartNs, state.eastM, state.northM)))
        }

        private fun replayConfigA(
            ordered: List<BenchmarkEvent>,
            initialHeading: RotationSample,
        ): ConfigRun {
            val (state, snapshots) = initialSnapshot(initialHeading.trueHeadingRad)
            var latestHeading: RotationSample? = initialHeading.takeIf { it.timestampNs <= denialStartNs }
            var opportunities = 0L
            var applied = 0L
            var skippedNoHeading = 0L
            for (event in ordered) {
                when (event) {
                    is HeadingEvent ->
                        latestHeading = RotationSample(event.timestampNs, event.headingRad, event.quality, DoubleArray(9))
                    is StepEvent -> {
                        opportunities += 1L
                        val heading = latestHeading
                        if (heading == null || heading.timestampNs > event.timestampNs) {
                            skippedNoHeading += 1L
                            continue
                        }
                        state.eastM += STEP_LENGTH_M * sin(heading.trueHeadingRad)
                        state.northM += STEP_LENGTH_M * cos(heading.trueHeadingRad)
                        snapshots.add(StateSnapshot(event.timestampNs, state.eastM, state.northM))
                        applied += 1L
                    }
                    is ArcoreEvent -> Unit
                }
            }
            return ConfigRun(
                snapshots = snapshots,
                finalState = state,
                stepOpportunities = opportunities,
                stepsApplied = applied,
                stepsSkippedNoHeading = skippedNoHeading,
            ).also { check(it.stepsApplied + it.stepsSkippedNoHeading == it.stepOpportunities) }
        }

        private fun replayConfigC(
            ordered: List<BenchmarkEvent>,
            initialHeading: RotationSample,
        ): ConfigRun {
            val (state, snapshots) = initialSnapshot(initialHeading.trueHeadingRad)
            var applied = 0L
            for (event in ordered) {
                if (event is ArcoreEvent) {
                    state.eastM = event.eastM
                    state.northM = event.northM
                    snapshots.add(StateSnapshot(event.timestampNs, state.eastM, state.northM))
                    applied += 1L
                }
            }
            return ConfigRun(snapshots = snapshots, finalState = state, arcoreApplied = applied)
        }

        private fun replayEkfConfig(
            ordered: List<BenchmarkEvent>,
            initialHeading: RotationSample,
            consumeArcore: Boolean,
        ): ConfigRun {
            val ekf = EkfState.initial(denialOriginEastM, denialOriginNorthM, initialHeading.trueHeadingRad)
            val snapshots = mutableListOf(StateSnapshot(denialStartNs, ekf.x[0], ekf.x[1]))
            var latestHeading: RotationSample? = initialHeading.takeIf { it.timestampNs <= denialStartNs }
            var opportunities = 0L
            var stepsApplied = 0L
            var stepsSkippedNoHeading = 0L
            var stepsSkippedQuality = 0L
            var headingsApplied = 0L
            var headingsSkipped = 0L
            var arcoreApplied = 0L
            var arcoreSkipped = 0L
            for (event in ordered) {
                when (event) {
                    is HeadingEvent -> {
                        latestHeading = RotationSample(event.timestampNs, event.headingRad, event.quality, DoubleArray(9))
                        val multiplier = qualityMultiplier(event.quality)
                        if (multiplier == null) {
                            headingsSkipped += 1L
                        } else {
                            ekf.updateHeading(event.headingRad, multiplier)
                            snapshots.add(StateSnapshot(event.timestampNs, ekf.x[0], ekf.x[1]))
                            headingsApplied += 1L
                        }
                    }
                    is StepEvent -> {
                        opportunities += 1L
                        val heading = latestHeading
                        if (heading == null || heading.timestampNs > event.timestampNs) {
                            stepsSkippedNoHeading += 1L
                            continue
                        }
                        val quality = classifyPdrQuality(heading.quality, event.timestampNs - heading.timestampNs)
                        val multiplier = qualityMultiplier(quality)
                        if (multiplier == null) {
                            stepsSkippedQuality += 1L
                        } else {
                            ekf.predictStep(multiplier)
                            snapshots.add(StateSnapshot(event.timestampNs, ekf.x[0], ekf.x[1]))
                            stepsApplied += 1L
                        }
                    }
                    is ArcoreEvent -> {
                        if (!consumeArcore) continue
                        val multiplier = qualityMultiplier(event.quality)
                        if (multiplier == null) {
                            arcoreSkipped += 1L
                        } else {
                            ekf.updateArcore(event.eastM, event.northM, multiplier)
                            snapshots.add(StateSnapshot(event.timestampNs, ekf.x[0], ekf.x[1]))
                            arcoreApplied += 1L
                        }
                    }
                }
            }
            ekf.validate()
            return ConfigRun(
                snapshots = snapshots,
                finalState = EstimatorState(ekf.x[0], ekf.x[1], ekf.x[2]),
                stepOpportunities = opportunities,
                stepsApplied = stepsApplied,
                stepsSkippedNoHeading = stepsSkippedNoHeading,
                stepsSkippedByQuality = stepsSkippedQuality,
                headingsApplied = headingsApplied,
                headingsSkipped = headingsSkipped,
                arcoreApplied = arcoreApplied,
                arcoreSkipped = arcoreSkipped,
            )
        }

        private fun compareSnapshots(
            configId: String,
            snapshots: List<StateSnapshot>,
            gt: List<ProtectedBenchmarkGroundTruthFix>,
        ): ConfigMetrics {
            val orderedStates = snapshots.sortedBy { it.timestampNs }
            val errors = mutableListOf<Double>()
            var stateIndex = 0
            var latest: StateSnapshot? = null
            var unmatched = 0
            for (fix in gt) {
                while (stateIndex < orderedStates.size && orderedStates[stateIndex].timestampNs <= fix.timestampNs) {
                    latest = orderedStates[stateIndex]
                    stateIndex += 1
                }
                val state = latest
                if (state == null) {
                    unmatched += 1
                    continue
                }
                errors.add(horizontalError(state.eastM, state.northM, fix.eastM, fix.northM))
            }
            if (errors.isEmpty()) throw InvalidBenchmarkException("${configId}_has_zero_matched_ground_truth")
            val stats = checkNotNull(statistics(errors))
            return ConfigMetrics(
                configId = configId,
                matchedGtCount = errors.size,
                unmatchedGtCount = unmatched,
                meanErrorM = stats.mean,
                medianErrorM = stats.median,
                p95ErrorM = nearestRankPercentile(errors, 95.0),
                maxErrorM = stats.max,
                finalErrorM = errors.last(),
            )
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
            if (!completed.compareAndSet(false, true)) return
            phase = BenchmarkPhase.COMPLETE
            val summary = completedSummary
            cleanupRuntime()
            releaseSession(this)
            Log.i(LOG_TAG, "NAVGUARD_BENCHMARK_END")
            if (summary == null) {
                postError(callback, ERROR_NUMERICAL_FAILURE, "The final benchmark result is unavailable.")
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
            phase = if (code == ERROR_CANCELLED) BenchmarkPhase.CANCELLED else BenchmarkPhase.FAILED
            cleanupRuntime()
            releaseSession(this)
            Log.i(LOG_TAG, "NAVGUARD_BENCHMARK_END")
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
            capturedEvents.clear()
            protectedGroundTruth.clear()
            protectedAccuracyM.clear()
            headingTimestampSet.clear()
            stepTimestampSet.clear()
        }
    }

    private enum class BenchmarkPhase {
        IDLE,
        PREPARING,
        PRE_DENIAL,
        BENCHMARK_DENIAL,
        COMPARING,
        COMPLETE,
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

    private data class RotationSample(
        val timestampNs: Long,
        val trueHeadingRad: Double,
        val quality: Quality,
        val trueEnuDevice: DoubleArray,
    )

    private data class ProtectedBenchmarkGroundTruthFix(
        val timestampNs: Long,
        val eastM: Double,
        val northM: Double,
        val reportedAccuracyM: Double,
    )

    private sealed class BenchmarkEvent(
        val timestampNs: Long,
        val insertionIndex: Long,
        val priority: Int,
    )

    private class HeadingEvent(
        timestampNs: Long,
        insertionIndex: Long,
        val headingRad: Double,
        val quality: Quality,
    ) : BenchmarkEvent(timestampNs, insertionIndex, 0)

    private class StepEvent(
        timestampNs: Long,
        insertionIndex: Long,
    ) : BenchmarkEvent(timestampNs, insertionIndex, 1)

    private class ArcoreEvent(
        timestampNs: Long,
        insertionIndex: Long,
        val eastM: Double,
        val northM: Double,
        val quality: Quality,
    ) : BenchmarkEvent(timestampNs, insertionIndex, 2)

    private data class StateSnapshot(
        val timestampNs: Long,
        val eastM: Double,
        val northM: Double,
    )

    private data class EstimatorState(
        var eastM: Double,
        var northM: Double,
        var headingRad: Double,
    )

    private data class ConfigRun(
        val snapshots: List<StateSnapshot>,
        val finalState: EstimatorState,
        val stepOpportunities: Long = 0L,
        val stepsApplied: Long = 0L,
        val stepsSkippedNoHeading: Long = 0L,
        val stepsSkippedByQuality: Long = 0L,
        val headingsApplied: Long = 0L,
        val headingsSkipped: Long = 0L,
        val arcoreApplied: Long = 0L,
        val arcoreSkipped: Long = 0L,
    )

    private data class AllConfigRuns(
        val configA: ConfigRun,
        val configB: ConfigRun,
        val configC: ConfigRun,
        val configD: ConfigRun,
    )

    private data class ConfigMetrics(
        val configId: String,
        val matchedGtCount: Int,
        val unmatchedGtCount: Int,
        val meanErrorM: Double,
        val medianErrorM: Double,
        val p95ErrorM: Double,
        val maxErrorM: Double,
        val finalErrorM: Double,
    ) {
        fun toMap(finalState: EstimatorState): Map<String, Any?> =
            linkedMapOf(
                "configId" to configId,
                "matchedGtCount" to matchedGtCount,
                "unmatchedGtCount" to unmatchedGtCount,
                "meanHorizontalErrorM" to meanErrorM,
                "medianHorizontalErrorM" to medianErrorM,
                "p95HorizontalErrorM" to p95ErrorM,
                "maxHorizontalErrorM" to maxErrorM,
                "finalPreCorrectionHorizontalErrorM" to finalErrorM,
                "finalEastM" to finalState.eastM,
                "finalNorthM" to finalState.northM,
            )
    }

    private data class Statistics(
        val min: Double,
        val mean: Double,
        val median: Double,
        val max: Double,
    )

    private class InvalidBenchmarkException(val reason: String) : IllegalStateException(reason)

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
        const val SNAPSHOT_KIND_PREFLIGHT = "navguard_benchmark_preflight"
        const val SNAPSHOT_KIND_RESULT = "navguard_benchmark_diagnostic_result"
        const val PRE_DENIAL_ACQUISITION_TIMEOUT_MS = 15_000L
        const val PRE_DENIAL_OBSERVATION_MS = 5_000L
        const val BENCHMARK_DENIED_WINDOW_MS = 30_000L
        const val ALIGNMENT_ACQUISITION_TIMEOUT_MS = 15_000L
        const val ALIGNMENT_HOLD_MS = 2_000L
        const val ALIGNMENT_HOLD_NS = ALIGNMENT_HOLD_MS * 1_000_000L
        const val INITIAL_REQUIRED_CONSECUTIVE_FIXES = 3
        const val MAX_OPERATIONAL_GNSS_ACCURACY_M = 50.0
        const val GNSS_MIN_TIME_MS = 1_000L
        const val GNSS_MIN_DISTANCE_M = 0.0f
        const val ROTATION_VECTOR_SAMPLING_PERIOD_US = 20_000
        const val MAX_REPORT_LATENCY_US = 0
        const val WORKER_THREAD_NAME = "NAVGUARD-Benchmark-Worker"
        const val AR_THREAD_NAME = "NAVGUARD-Benchmark-ARCore"
        const val NANOS_PER_MILLISECOND = 1_000_000.0
        const val STEP_LENGTH_M = 0.75
        const val BASE_STEP_LENGTH_SIGMA_M = 0.20
        val BASE_STEP_HEADING_PROCESS_SIGMA_RAD = Math.toRadians(5.0)
        val BASE_HEADING_MEASUREMENT_SIGMA_RAD = Math.toRadians(15.0)
        const val BASE_ARCORE_POSITION_SIGMA_M = 0.35
        const val TARGET_IMPROVEMENT_PERCENT = 20.0
        const val PRIMARY_METRIC = "matched_session_median_horizontal_error_m"
        const val PRIMARY_COMPARISON = "config_d_vs_config_a"
        const val PERCENTILE_POLICY = "nearest_rank"
        const val CONFIG_A_ID = "config_a_deterministic_pdr"
        const val CONFIG_B_ID = "config_b_pdr_heading_ekf"
        const val CONFIG_C_ID = "config_c_arcore_relative"
        const val CONFIG_D_ID = "config_d_navguard_ekf_v1"
        const val TWO_PI = 2.0 * PI
        const val WGS84_SEMI_MAJOR_AXIS_M = 6_378_137.0
        const val WGS84_ECCENTRICITY_SQUARED = 6.69437999014e-3
        const val LOG_TAG = "NAVGUARD_BENCHMARK"

        const val ERROR_LOCATION_PERMISSION_REQUIRED = "navguard_benchmark_location_permission_required"
        const val ERROR_GPS_UNAVAILABLE = "navguard_benchmark_gps_unavailable"
        const val ERROR_GPS_DISABLED = "navguard_benchmark_gps_disabled"
        const val ERROR_ANCHOR_REQUIRED = "navguard_benchmark_anchor_required"
        const val ERROR_CAMERA_PERMISSION_REQUIRED = "navguard_benchmark_camera_permission_required"
        const val ERROR_ARCORE_UNAVAILABLE = "navguard_benchmark_arcore_unavailable"
        const val ERROR_ROTATION_VECTOR_UNAVAILABLE = "navguard_benchmark_rotation_vector_unavailable"
        const val ERROR_STEP_DETECTOR_UNAVAILABLE = "navguard_benchmark_step_detector_unavailable"
        const val ERROR_ACTIVITY_PERMISSION_REQUIRED = "activity_recognition_permission_required"
        const val ERROR_GNSS_ACQUISITION_TIMEOUT = "navguard_benchmark_gnss_acquisition_timeout"
        const val ERROR_ALIGNMENT_TIMEOUT = "navguard_benchmark_alignment_timeout"
        const val ERROR_SENSOR_REGISTRATION_FAILED = "navguard_benchmark_sensor_registration_failed"
        const val ERROR_INVALID_SESSION = "navguard_benchmark_invalid_session"
        const val ERROR_NUMERICAL_FAILURE = "navguard_benchmark_numerical_failure"
        const val ERROR_ALREADY_RUNNING = "navguard_benchmark_already_running"
        const val ERROR_CANCELLED = "navguard_benchmark_cancelled"
        const val ERROR_INTERNAL = "internal_navguard_benchmark_error"

        fun isValidAnchor(
            latitudeDeg: Double,
            longitudeDeg: Double,
            altitudeM: Double?,
        ): Boolean =
            latitudeDeg.isFinite() && latitudeDeg in -90.0..90.0 &&
                longitudeDeg.isFinite() && longitudeDeg in -180.0..180.0 &&
                altitudeM?.isFinite() != false

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

        fun qualityMultiplier(quality: Quality): Double? =
            when (quality) {
                Quality.GOOD -> 1.0
                Quality.USABLE -> 2.0
                Quality.DEGRADED -> 6.0
                else -> null
            }

        fun horizontalError(
            estimatorEastM: Double,
            estimatorNorthM: Double,
            gtEastM: Double,
            gtNorthM: Double,
        ): Double {
            require(listOf(estimatorEastM, estimatorNorthM, gtEastM, gtNorthM).all { it.isFinite() })
            val east = estimatorEastM - gtEastM
            val north = estimatorNorthM - gtNorthM
            return sqrt((east * east) + (north * north))
        }

        fun statistics(values: List<Double>): Statistics? {
            if (values.isEmpty() || values.any { !it.isFinite() }) return null
            val sorted = values.sorted()
            val middle = sorted.size / 2
            val median = if (sorted.size % 2 == 0) (sorted[middle - 1] + sorted[middle]) / 2.0 else sorted[middle]
            return Statistics(sorted.first(), sorted.average(), median, sorted.last())
        }

        fun nearestRankPercentile(
            values: List<Double>,
            percentile: Double,
        ): Double {
            require(values.isNotEmpty() && values.all { it.isFinite() } && percentile > 0.0 && percentile <= 100.0)
            val sorted = values.sorted()
            val rank = ceil((percentile / 100.0) * sorted.size).toInt().coerceIn(1, sorted.size)
            return sorted[rank - 1]
        }

        fun improvementPercent(
            baseline: Double,
            candidate: Double,
        ): Double? {
            require(baseline.isFinite() && candidate.isFinite() && baseline >= 0.0 && candidate >= 0.0)
            if (kotlin.math.abs(baseline) <= 1e-12) return null
            return 100.0 * (baseline - candidate) / baseline
        }

        fun runGroundTruthFirewallSelfTests(): Boolean =
            runCatching {
                fun estimatorSignature(): DoubleArray {
                    val aEast = 10.0 + (STEP_LENGTH_M * sin(0.2))
                    val aNorth = -4.0 + (STEP_LENGTH_M * cos(0.2))
                    val b = EkfState.initial(10.0, -4.0, 0.2)
                    b.updateHeading(0.25, 1.0)
                    b.predictStep(2.0)
                    val cEast = 10.3
                    val cNorth = -3.2
                    val d = EkfState.initial(10.0, -4.0, 0.2)
                    d.updateHeading(0.25, 1.0)
                    d.predictStep(2.0)
                    d.updateArcore(cEast, cNorth, 2.0)
                    return doubleArrayOf(aEast, aNorth, b.x[0], b.x[1], cEast, cNorth, d.x[0], d.x[1])
                }
                val withOriginalGt = estimatorSignature()
                val withMutatedGt = estimatorSignature()
                val withoutGt = estimatorSignature()
                val predictionsUnchanged =
                    withOriginalGt.indices.all {
                        kotlin.math.abs(withOriginalGt[it] - withMutatedGt[it]) <= 1e-12 &&
                            kotlin.math.abs(withOriginalGt[it] - withoutGt[it]) <= 1e-12
                    }
                val originalComparatorError = horizontalError(withOriginalGt[6], withOriginalGt[7], 10.0, -3.0)
                val mutatedComparatorError = horizontalError(withMutatedGt[6], withMutatedGt[7], 1_010.0, -1_003.0)
                predictionsUnchanged && kotlin.math.abs(originalComparatorError - mutatedComparatorError) > 1.0
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

        fun identity(): DoubleArray =
            doubleArrayOf(1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0)

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
    }
}
