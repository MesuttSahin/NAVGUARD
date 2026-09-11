package io.github.mesuttsahin.navguard

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.hardware.GeomagneticField
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
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
import kotlin.math.abs
import kotlin.math.atan2
import kotlin.math.ceil
import kotlin.math.cos
import kotlin.math.sin
import kotlin.math.sqrt

internal class NavguardFusionDiagnostic(
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
    private var activeSession: DiagnosticSession? = null

    fun createPreflightSnapshot(): Map<String, Any?> {
        val availability = readArCoreAvailability()
        val rotationVector = getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
        val stepDetector = getDefaultSensor(Sensor.TYPE_STEP_DETECTOR)
        val cameraPermissionGranted = hasCameraPermission()
        val activityPermissionGranted = hasActivityRecognitionPermission()
        val diagnosticRunning = isDiagnosticRunning()
        return linkedMapOf(
            "schemaVersion" to SCHEMA_VERSION,
            "snapshotKind" to SNAPSHOT_KIND_PREFLIGHT,
            "arCoreSupported" to availability.supported,
            "arCoreInstalled" to availability.installedAndCurrent,
            "cameraPermissionGranted" to cameraPermissionGranted,
            "rotationVectorAvailable" to (rotationVector != null),
            "rotationVectorName" to rotationVector?.name,
            "stepDetectorAvailable" to (stepDetector != null),
            "stepDetectorName" to stepDetector?.name,
            "activityRecognitionPermissionGranted" to activityPermissionGranted,
            "diagnosticRunning" to diagnosticRunning,
            "nativeReady" to
                (
                    availability.supported &&
                        availability.installedAndCurrent &&
                        cameraPermissionGranted &&
                        rotationVector != null &&
                        stepDetector != null &&
                        activityPermissionGranted &&
                        !diagnosticRunning
                ),
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
        if (
            !anchorLatitudeDeg.isFinite() ||
                anchorLatitudeDeg !in -90.0..90.0 ||
                !anchorLongitudeDeg.isFinite() ||
                anchorLongitudeDeg !in -180.0..180.0 ||
                anchorAltitudeEllipsoidM?.isFinite() == false
        ) {
            postError(callback, ERROR_ANCHOR_REQUIRED, "A valid locked Stage 3A GNSS anchor is required.")
            return
        }
        if (!hasCameraPermission()) {
            postError(callback, ERROR_CAMERA_PERMISSION_REQUIRED, "Camera permission is required.")
            return
        }
        val availability = readArCoreAvailability()
        if (!availability.supported || !availability.installedAndCurrent) {
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
            postError(
                callback,
                ERROR_ACTIVITY_RECOGNITION_PERMISSION_REQUIRED,
                "Activity Recognition permission is required.",
            )
            return
        }

        val altitudeSource =
            if (anchorAltitudeEllipsoidM == null) {
                DECLINATION_ALTITUDE_SOURCE_ZERO_FALLBACK
            } else {
                DECLINATION_ALTITUDE_SOURCE_ANCHOR
            }
        val declinationRad =
            runCatching {
                Math.toRadians(
                    GeomagneticField(
                        anchorLatitudeDeg.toFloat(),
                        anchorLongitudeDeg.toFloat(),
                        (anchorAltitudeEllipsoidM ?: 0.0).toFloat(),
                        System.currentTimeMillis(),
                    ).declination.toDouble(),
                )
            }.getOrDefault(Double.NaN)
        if (!declinationRad.isFinite()) {
            postError(callback, ERROR_INTERNAL, "Unable to calculate geomagnetic declination.")
            return
        }

        val session =
            DiagnosticSession(
                rotationVector = rotationVector,
                stepDetector = stepDetector,
                declinationRad = declinationRad,
                declinationAltitudeSource = altitudeSource,
                callback = callback,
            )
        synchronized(activeSessionLock) {
            if (activeSession != null) {
                postError(callback, ERROR_ALREADY_RUNNING, "A NAVGUARD fusion diagnostic is already running.")
                return
            }
            activeSession = session
        }
        session.start()
    }

    fun cancelActiveSession(
        message: String = "NAVGUARD fusion diagnostic cancelled by the user.",
    ): Boolean {
        val session = synchronized(activeSessionLock) { activeSession } ?: return false
        return session.cancel(message)
    }

    private fun releaseSession(session: DiagnosticSession) {
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

    private fun hasCameraPermission(): Boolean =
        applicationContext.checkSelfPermission(Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED

    private fun hasActivityRecognitionPermission(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.Q ||
            applicationContext.checkSelfPermission(Manifest.permission.ACTIVITY_RECOGNITION) ==
            PackageManager.PERMISSION_GRANTED

    private fun readArCoreAvailability(): AvailabilitySnapshot {
        val availability =
            runCatching { ArCoreApk.getInstance().checkAvailability(applicationContext) }
                .getOrNull() ?: return AvailabilitySnapshot(false, false)
        return when (availability) {
            ArCoreApk.Availability.SUPPORTED_INSTALLED -> AvailabilitySnapshot(true, true)
            ArCoreApk.Availability.SUPPORTED_APK_TOO_OLD,
            ArCoreApk.Availability.SUPPORTED_NOT_INSTALLED,
            -> AvailabilitySnapshot(true, false)
            else -> AvailabilitySnapshot(false, false)
        }
    }

    private inner class DiagnosticSession(
        private val rotationVector: Sensor,
        private val stepDetector: Sensor,
        private val declinationRad: Double,
        private val declinationAltitudeSource: String,
        private val callback: Callback,
    ) : SensorEventListener {
        private val completed = AtomicBoolean(false)
        private val cancellationRequested = AtomicBoolean(false)
        private val stateLock = Any()
        private val sensorThread = HandlerThread(SENSOR_THREAD_NAME)
        private val arThread = HandlerThread(AR_THREAD_NAME)
        private val glEnvironment = DiagnosticGlEnvironment()
        private val events = mutableListOf<FusionEvent>()
        private val headingTimestampSet = mutableSetOf<Long>()
        private val stepTimestampSet = mutableSetOf<Long>()
        private val arFrameTimestampSet = mutableSetOf<Long>()
        private val counters = FusionCounters()

        @Volatile
        private var cancellationMessage = "NAVGUARD fusion diagnostic cancelled by the user."

        private var sensorHandler: Handler? = null
        private var arHandler: Handler? = null
        private var arCoreSession: Session? = null
        private var referenceAnchor: Anchor? = null
        private var sessionResumed = false
        private var listenersRegistered = false
        private var alignmentHoldStartedNs: Long? = null
        private var fusionStartedNs: Long? = null
        private var fusionEndedNs: Long? = null
        private var latestAlignmentRotation: RotationSample? = null
        private var frozenEnuFromInitialDevice: DoubleArray? = null
        private var initialHeading: RotationSample? = null
        private var previousHeadingTimestampNs: Long? = null
        private var previousStepTimestampNs: Long? = null
        private var previousArFrameTimestampNs: Long? = null
        private var previousArFusionTimestampNs: Long? = null
        private var insertionSequence = 0L
        private var finalHeadingQuality = Quality.UNKNOWN
        private var finalPdrQuality = Quality.UNKNOWN
        private var finalArcoreQuality = Quality.UNKNOWN
        private var finalArEastM: Double? = null
        private var finalArNorthM: Double? = null

        fun start() {
            try {
                sensorThread.start()
                val sensorWorker = Handler(sensorThread.looper)
                sensorHandler = sensorWorker
                val rotationRegistered =
                    sensorManager.registerListener(
                        this,
                        rotationVector,
                        ROTATION_VECTOR_SAMPLING_PERIOD_US,
                        MAX_REPORT_LATENCY_US,
                        sensorWorker,
                    )
                val stepRegistered =
                    sensorManager.registerListener(
                        this,
                        stepDetector,
                        SensorManager.SENSOR_DELAY_NORMAL,
                        MAX_REPORT_LATENCY_US,
                        sensorWorker,
                    )
                listenersRegistered = rotationRegistered || stepRegistered
                if (!rotationRegistered || !stepRegistered) {
                    finishWithError(
                        ERROR_SENSOR_REGISTRATION_FAILED,
                        "Android rejected a required sensor listener registration.",
                    )
                    return
                }

                arThread.start()
                val arWorker = Handler(arThread.looper)
                arHandler = arWorker
                if (!arWorker.post(::runArCoreLoop)) {
                    finishWithError(ERROR_INTERNAL, "Unable to start the fusion worker.")
                }
            } catch (_: SecurityException) {
                finishWithError(
                    ERROR_ACTIVITY_RECOGNITION_PERMISSION_REQUIRED,
                    "A required runtime permission is missing.",
                )
            } catch (_: Exception) {
                finishWithError(ERROR_INTERNAL, "Unable to start the NAVGUARD fusion diagnostic.")
            }
        }

        fun cancel(message: String): Boolean {
            if (completed.get()) return false
            cancellationMessage = message
            cancellationRequested.set(true)
            return true
        }

        override fun onSensorChanged(event: SensorEvent) {
            if (completed.get()) return
            when (event.sensor.type) {
                Sensor.TYPE_ROTATION_VECTOR -> handleRotationVector(event)
                Sensor.TYPE_STEP_DETECTOR -> handleStep(event)
            }
        }

        override fun onAccuracyChanged(
            sensor: Sensor,
            accuracy: Int,
        ) {
            // The frozen quality contract uses the rotation-vector payload accuracy.
        }

        private fun handleRotationVector(event: SensorEvent) {
            val sample = createRotationSample(event)
            synchronized(stateLock) {
                counters.headingEventCount += 1L
                if (sample == null) {
                    counters.headingQuality.increment(Quality.UNRELIABLE)
                    finalHeadingQuality = Quality.UNRELIABLE
                    return
                }
                latestAlignmentRotation = sample
                val startNs = fusionStartedNs ?: return
                val endNs = fusionEndedNs ?: return
                if (sample.timestampNs < startNs || sample.timestampNs > endNs) return
                if (!headingTimestampSet.add(sample.timestampNs)) {
                    counters.duplicateHeadingTimestampCount += 1L
                    return
                }
                val previous = previousHeadingTimestampNs
                if (previous != null && sample.timestampNs < previous) {
                    counters.nonMonotonicHeadingTimestampCount += 1L
                    return
                }
                previousHeadingTimestampNs = sample.timestampNs
                counters.headingQuality.increment(sample.quality)
                finalHeadingQuality = sample.quality
                events.add(
                    HeadingEvent(
                        timestampNs = sample.timestampNs,
                        insertionIndex = insertionSequence++,
                        headingRad = sample.trueHeadingRad,
                        quality = sample.quality,
                    ),
                )
            }
        }

        private fun createRotationSample(event: SensorEvent): RotationSample? {
            if (event.timestamp <= 0L || event.values.size < 3) return null
            val componentCount = if (event.values.size >= 4) 4 else 3
            val vector = FloatArray(componentCount)
            for (index in 0 until componentCount) {
                val value = event.values[index]
                if (!value.isFinite()) return null
                vector[index] = value
            }
            val matrix = FloatArray(9)
            try {
                SensorManager.getRotationMatrixFromVector(matrix, vector)
            } catch (_: Exception) {
                return null
            }
            if (matrix.any { !it.isFinite() }) return null
            val east = matrix[1].toDouble()
            val north = matrix[4].toDouble()
            val horizontalNorm = sqrt((east * east) + (north * north))
            if (!horizontalNorm.isFinite() || horizontalNorm <= 1e-6) return null
            val trueHeading = normalizeHeading(atan2(east, north) + declinationRad)
            val reportedAccuracy =
                if (event.values.size >= 5) {
                    val value = event.values[4].toDouble()
                    if (!value.isFinite()) return null
                    value.takeIf { it >= 0.0 }
                } else {
                    null
                }
            val quality = classifyHeadingQuality(reportedAccuracy)
            val magneticDevice = DoubleArray(9) { matrix[it].toDouble() }
            val trueEnuDevice = multiplyMatrices(declinationCorrectionMatrix(declinationRad), magneticDevice)
            if (trueEnuDevice.any { !it.isFinite() }) return null
            return RotationSample(event.timestamp, trueHeading, reportedAccuracy, quality, trueEnuDevice)
        }

        private fun handleStep(event: SensorEvent) {
            synchronized(stateLock) {
                counters.stepEventCount += 1L
                val value = event.values.firstOrNull()
                if (
                    event.timestamp <= 0L ||
                        value == null ||
                        !value.isFinite() ||
                        value != 1.0f
                ) {
                    counters.invalidStepEventCount += 1L
                    return
                }
                val startNs = fusionStartedNs ?: return
                val endNs = fusionEndedNs ?: return
                if (event.timestamp < startNs || event.timestamp > endNs) return
                if (!stepTimestampSet.add(event.timestamp)) {
                    counters.duplicateStepTimestampCount += 1L
                    return
                }
                val previous = previousStepTimestampNs
                if (previous != null && event.timestamp < previous) {
                    counters.nonMonotonicStepTimestampCount += 1L
                    return
                }
                previousStepTimestampNs = event.timestamp
                events.add(StepEvent(event.timestamp, insertionSequence++))
            }
        }

        private fun runArCoreLoop() {
            if (cancellationRequested.get()) {
                finishWithError(ERROR_CANCELLED, cancellationMessage)
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
                sessionResumed = true
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

            val acquisitionStartedNs = SystemClock.elapsedRealtimeNanos()
            while (!completed.get()) {
                if (cancellationRequested.get()) {
                    finishWithError(ERROR_CANCELLED, cancellationMessage)
                    return
                }
                val frame =
                    try {
                        session.update()
                    } catch (_: Exception) {
                        if (cancellationRequested.get()) {
                            finishWithError(ERROR_CANCELLED, cancellationMessage)
                        } else {
                            finishWithError(ERROR_ARCORE_UNAVAILABLE, "The ARCore session failed.")
                        }
                        return
                    }
                val nowNs = SystemClock.elapsedRealtimeNanos()
                if (fusionStartedNs == null) {
                    tryCompleteAlignment(session, frame, nowNs)
                    if (
                        fusionStartedNs == null &&
                            nowNs - acquisitionStartedNs >= ALIGNMENT_ACQUISITION_TIMEOUT_NS
                    ) {
                        finishWithError(ERROR_ALIGNMENT_TIMEOUT, "NAVGUARD fusion alignment timed out.")
                        return
                    }
                    continue
                }
                val endNs = fusionEndedNs ?: continue
                if (nowNs >= endNs) {
                    finishSuccessfully()
                    return
                }
                processFormalFrame(frame)
            }
        }

        private fun tryCompleteAlignment(
            session: Session,
            frame: Frame,
            nowNs: Long,
        ) {
            if (frame.camera.trackingState != TrackingState.TRACKING) {
                alignmentHoldStartedNs = null
                return
            }
            val rotation = synchronized(stateLock) { latestAlignmentRotation?.copy() }
            if (rotation == null || navguardQualityMultiplier(rotation.quality) == null) {
                alignmentHoldStartedNs = null
                return
            }
            val holdStart = alignmentHoldStartedNs
            if (holdStart == null) {
                alignmentHoldStartedNs = nowNs
                return
            }
            if (nowNs - holdStart < ALIGNMENT_HOLD_NS) return
            val pose = frame.androidSensorPose
            if (!isFinitePose(pose)) {
                alignmentHoldStartedNs = null
                return
            }
            val anchor = session.createAnchor(pose)
            if (anchor.trackingState != TrackingState.TRACKING) {
                anchor.detach()
                alignmentHoldStartedNs = null
                return
            }
            synchronized(stateLock) {
                referenceAnchor = anchor
                frozenEnuFromInitialDevice = rotation.trueEnuDevice.copyOf()
                initialHeading = rotation.copy()
                finalHeadingQuality = rotation.quality
                fusionStartedNs = nowNs
                fusionEndedNs = nowNs + FUSION_WINDOW_NS
            }
        }

        private fun processFormalFrame(frame: Frame) {
            counters.arFrameUpdateCount += 1L
            val cameraTracking = frame.camera.trackingState == TrackingState.TRACKING
            if (cameraTracking) counters.arTrackingFrameCount += 1L
            val anchor = referenceAnchor
            val referenceTracking = anchor?.trackingState == TrackingState.TRACKING
            if (!cameraTracking || !referenceTracking) {
                finalArcoreQuality = Quality.UNAVAILABLE
                counters.arcoreQuality.increment(Quality.UNAVAILABLE)
                return
            }
            val frameTimestamp = frame.timestamp
            if (frameTimestamp <= 0L || !arFrameTimestampSet.add(frameTimestamp)) {
                counters.duplicateArFrameTimestampCount += 1L
                return
            }
            val previousFrameTimestamp = previousArFrameTimestampNs
            if (previousFrameTimestamp != null && frameTimestamp < previousFrameTimestamp) {
                counters.nonMonotonicArFrameTimestampCount += 1L
                return
            }
            previousArFrameTimestampNs = frameTimestamp

            val currentPose = runCatching { frame.androidSensorPose }.getOrNull()
            val relativePose =
                if (currentPose == null || !isFinitePose(currentPose)) {
                    null
                } else {
                    runCatching { anchor.pose.inverse().compose(currentPose) }.getOrNull()
                }
            if (relativePose == null || !isFinitePose(relativePose)) {
                finalArcoreQuality = Quality.UNRELIABLE
                counters.arcoreQuality.increment(Quality.UNRELIABLE)
                return
            }
            val translation = FloatArray(3)
            relativePose.getTranslation(translation, 0)
            if (translation.any { !it.isFinite() }) {
                finalArcoreQuality = Quality.UNRELIABLE
                counters.arcoreQuality.increment(Quality.UNRELIABLE)
                return
            }
            val transform = frozenEnuFromInitialDevice ?: return
            val enu =
                multiplyMatrixVector(
                    transform,
                    doubleArrayOf(
                        translation[0].toDouble(),
                        translation[1].toDouble(),
                        translation[2].toDouble(),
                    ),
                )
            if (enu.any { !it.isFinite() }) {
                finalArcoreQuality = Quality.UNRELIABLE
                counters.arcoreQuality.increment(Quality.UNRELIABLE)
                return
            }

            // This is deliberately captured after pose transformation. Frame.timestamp
            // remains isolated to duplicate/monotonic frame diagnostics above.
            val fusionTimestampNs = SystemClock.elapsedRealtimeNanos()
            val previousFusionTimestamp = previousArFusionTimestampNs
            val quality =
                if (previousFusionTimestamp == null) {
                    Quality.USABLE
                } else {
                    classifyArcoreQuality(fusionTimestampNs - previousFusionTimestamp)
                }
            previousArFusionTimestampNs = fusionTimestampNs
            finalArcoreQuality = quality
            counters.arcoreQuality.increment(quality)
            finalArEastM = enu[0]
            finalArNorthM = enu[1]
            synchronized(stateLock) {
                events.add(
                    ArcoreEvent(
                        timestampNs = fusionTimestampNs,
                        insertionIndex = insertionSequence++,
                        eastM = enu[0],
                        northM = enu[1],
                        upM = enu[2],
                        quality = quality,
                    ),
                )
            }
        }

        private fun finishSuccessfully() {
            if (!completed.compareAndSet(false, true)) return
            cleanupRuntime()
            val captured = synchronized(stateLock) { events.toList() }
            val heading = synchronized(stateLock) { initialHeading?.copy() }
            if (heading == null) {
                clearEventBuffers()
                releaseSession(this)
                postError(callback, ERROR_EKF_NUMERICAL_FAILURE, "No valid initial heading was available.")
                return
            }
            val summary =
                try {
                    replayAndCreateSummary(captured, heading)
                } catch (_: Exception) {
                    null
                }
            clearEventBuffers()
            releaseSession(this)
            if (summary == null) {
                postError(callback, ERROR_EKF_NUMERICAL_FAILURE, "The EKF produced an invalid numerical state.")
            } else {
                postSuccess(callback, summary)
            }
        }

        private fun finishWithError(
            code: String,
            message: String,
        ) {
            if (!completed.compareAndSet(false, true)) return
            cleanupRuntime()
            clearEventBuffers()
            releaseSession(this)
            postError(callback, code, message)
        }

        private fun cleanupRuntime() {
            runCatching { arHandler?.removeCallbacksAndMessages(null) }
            runCatching { sensorHandler?.removeCallbacksAndMessages(null) }
            runCatching {
                if (listenersRegistered) {
                    sensorManager.unregisterListener(this)
                    listenersRegistered = false
                }
            }
            runCatching { referenceAnchor?.detach() }
            referenceAnchor = null
            runCatching { if (sessionResumed) arCoreSession?.pause() }
            runCatching { arCoreSession?.close() }
            arCoreSession = null
            runCatching { glEnvironment.release() }
            runCatching { if (sensorThread.isAlive) sensorThread.quitSafely() }
            runCatching { if (arThread.isAlive) arThread.quitSafely() }
            sensorHandler = null
            arHandler = null
        }

        private fun clearEventBuffers() {
            synchronized(stateLock) {
                events.clear()
                headingTimestampSet.clear()
                stepTimestampSet.clear()
                arFrameTimestampSet.clear()
            }
        }

        private fun replayAndCreateSummary(
            capturedEvents: List<FusionEvent>,
            initial: RotationSample,
        ): Map<String, Any?> {
            val ordered =
                capturedEvents.sortedWith(
                    compareBy<FusionEvent> { it.timestampNs }
                        .thenBy { it.priority }
                        .thenBy { it.insertionIndex },
                )
            var ekf = EkfState.initial(initial.trueHeadingRad)
            var latestHeading = initial
            var pdrEastM = 0.0
            var pdrNorthM = 0.0
            val headingInnovations = mutableListOf<Double>()
            val arcoreInnovations = mutableListOf<Double>()
            var acceptedSourceUpdate = false
            var sourceObserved = false

            for (event in ordered) {
                when (event) {
                    is HeadingEvent -> {
                        sourceObserved = true
                        latestHeading =
                            RotationSample(
                                event.timestampNs,
                                event.headingRad,
                                null,
                                event.quality,
                                DoubleArray(9),
                            )
                        val multiplier = navguardQualityMultiplier(event.quality)
                        if (multiplier == null) {
                            counters.headingMeasurementsSkippedByQuality += 1L
                        } else {
                            val innovation = ekf.updateHeading(event.headingRad, multiplier)
                            headingInnovations.add(abs(innovation))
                            counters.headingMeasurementsApplied += 1L
                            acceptedSourceUpdate = true
                        }
                    }
                    is StepEvent -> {
                        sourceObserved = true
                        val headingAgeNs = event.timestampNs - latestHeading.timestampNs
                        val quality = classifyPdrQuality(latestHeading.quality, headingAgeNs)
                        finalPdrQuality = quality
                        counters.pdrQuality.increment(quality)
                        if (headingAgeNs < 0L) {
                            counters.pdrPredictionsSkippedNoHeading += 1L
                            continue
                        }
                        val multiplier = navguardQualityMultiplier(quality)
                        if (multiplier == null) {
                            if (quality == Quality.UNAVAILABLE) {
                                counters.pdrPredictionsSkippedNoHeading += 1L
                            } else {
                                counters.pdrPredictionsSkippedByQuality += 1L
                            }
                            continue
                        }
                        ekf.predictStep(multiplier)
                        pdrEastM += STEP_LENGTH_M * sin(latestHeading.trueHeadingRad)
                        pdrNorthM += STEP_LENGTH_M * cos(latestHeading.trueHeadingRad)
                        counters.pdrPredictionsApplied += 1L
                        acceptedSourceUpdate = true
                    }
                    is ArcoreEvent -> {
                        sourceObserved = true
                        val multiplier = navguardQualityMultiplier(event.quality)
                        if (multiplier == null) {
                            counters.arcoreMeasurementsSkippedByQuality += 1L
                        } else {
                            val innovation = ekf.updateArcore(event.eastM, event.northM, multiplier)
                            arcoreInnovations.add(sqrt((innovation.first * innovation.first) + (innovation.second * innovation.second)))
                            counters.arcoreMeasurementsApplied += 1L
                            acceptedSourceUpdate = true
                        }
                    }
                }
            }

            ekf.validate()
            val fusionQuality =
                classifyFusionQuality(
                    finalHeadingQuality,
                    finalPdrQuality,
                    finalArcoreQuality,
                    acceptedSourceUpdate,
                    sourceObserved,
                )
            val pdrHorizontal = sqrt((pdrEastM * pdrEastM) + (pdrNorthM * pdrNorthM))
            val arHorizontal =
                if (finalArEastM == null || finalArNorthM == null) {
                    null
                } else {
                    sqrt((finalArEastM!! * finalArEastM!!) + (finalArNorthM!! * finalArNorthM!!))
                }
            val fusedHorizontal = sqrt((ekf.x[0] * ekf.x[0]) + (ekf.x[1] * ekf.x[1]))
            return linkedMapOf(
                "schemaVersion" to SCHEMA_VERSION,
                "snapshotKind" to SNAPSHOT_KIND_RESULT,
                "success" to true,
                "fusionWindowMs" to FUSION_WINDOW_MS,
                "alignmentHoldMs" to ALIGNMENT_HOLD_MS,
                "alignmentAcquisitionTimeoutMs" to ALIGNMENT_ACQUISITION_TIMEOUT_MS,
                "coordinateFrame" to COORDINATE_FRAME,
                "estimatorProfile" to ESTIMATOR_PROFILE,
                "headingConvention" to HEADING_CONVENTION,
                "alignmentCompleted" to true,
                "alignmentStationarityAssumed" to true,
                "alignmentStationarityValidated" to false,
                "arcorePoseSource" to ARCORE_POSE_SOURCE,
                "referenceStrategy" to REFERENCE_STRATEGY,
                "relativePoseStrategy" to RELATIVE_POSE_STRATEGY,
                "headingTimestampAuthority" to SENSOR_TIMESTAMP_AUTHORITY,
                "stepTimestampAuthority" to SENSOR_TIMESTAMP_AUTHORITY,
                "arcoreFrameTimestampAuthority" to AR_FRAME_TIMESTAMP_AUTHORITY,
                "arcoreFrameTimestampTimeBase" to AR_FRAME_TIMESTAMP_TIME_BASE,
                "operationWindowClock" to OPERATION_WINDOW_CLOCK,
                "arcoreFrameTimestampUsedForFusionOrdering" to false,
                "arcoreFusionOrderingTimestampAuthority" to OPERATION_WINDOW_CLOCK,
                "arcoreFusionTimestampSemantics" to AR_FUSION_TIMESTAMP_SEMANTICS,
                "elapsedRealtimeFusionOrderingUsed" to true,
                "unsupportedCrossClockComparisonUsed" to false,
                "deterministicOfflineReplayUsed" to true,
                "equalTimestampPriority" to "heading,step,arcore",
                "headingAssociationPolicy" to "latest_valid_heading_at_or_before_step_timestamp",
                "preDenialAnchorUsedForDeclination" to true,
                "declinationProvider" to DECLINATION_PROVIDER,
                "declinationModelVersion" to "platform_managed",
                "declinationAltitudeSource" to declinationAltitudeSource,
                "declinationRad" to declinationRad,
                "baseStepLengthM" to STEP_LENGTH_M,
                "baseStepLengthSigmaM" to BASE_STEP_LENGTH_SIGMA_M,
                "baseStepHeadingProcessSigmaRad" to BASE_STEP_HEADING_PROCESS_SIGMA_RAD,
                "baseHeadingMeasurementSigmaRad" to BASE_HEADING_MEASUREMENT_SIGMA_RAD,
                "baseArcorePositionSigmaM" to BASE_ARCORE_POSITION_SIGMA_M,
                "headingGoodCount" to counters.headingQuality.good,
                "headingUsableCount" to counters.headingQuality.usable,
                "headingDegradedCount" to counters.headingQuality.degraded,
                "headingUnreliableCount" to counters.headingQuality.unreliable,
                "headingUnavailableCount" to counters.headingQuality.unavailable,
                "pdrGoodCount" to counters.pdrQuality.good,
                "pdrUsableCount" to counters.pdrQuality.usable,
                "pdrDegradedCount" to counters.pdrQuality.degraded,
                "pdrUnreliableCount" to counters.pdrQuality.unreliable,
                "pdrUnavailableCount" to counters.pdrQuality.unavailable,
                "arcoreGoodCount" to counters.arcoreQuality.good,
                "arcoreUsableCount" to counters.arcoreQuality.usable,
                "arcoreDegradedCount" to counters.arcoreQuality.degraded,
                "arcoreUnreliableCount" to counters.arcoreQuality.unreliable,
                "arcoreUnavailableCount" to counters.arcoreQuality.unavailable,
                "finalHeadingQuality" to finalHeadingQuality.name,
                "finalPdrQuality" to finalPdrQuality.name,
                "finalArcoreQuality" to finalArcoreQuality.name,
                "finalFusionQuality" to fusionQuality.name,
                "headingMeasurementsApplied" to counters.headingMeasurementsApplied,
                "headingMeasurementsSkippedByQuality" to counters.headingMeasurementsSkippedByQuality,
                "pdrPredictionsApplied" to counters.pdrPredictionsApplied,
                "pdrPredictionsSkippedNoHeading" to counters.pdrPredictionsSkippedNoHeading,
                "pdrPredictionsSkippedByQuality" to counters.pdrPredictionsSkippedByQuality,
                "arcoreMeasurementsApplied" to counters.arcoreMeasurementsApplied,
                "arcoreMeasurementsSkippedByQuality" to counters.arcoreMeasurementsSkippedByQuality,
                "headingEventCount" to counters.headingEventCount,
                "stepEventCount" to counters.stepEventCount,
                "invalidStepEventCount" to counters.invalidStepEventCount,
                "arFrameUpdateCount" to counters.arFrameUpdateCount,
                "arTrackingFrameCount" to counters.arTrackingFrameCount,
                "duplicateHeadingTimestampCount" to counters.duplicateHeadingTimestampCount,
                "nonMonotonicHeadingTimestampCount" to counters.nonMonotonicHeadingTimestampCount,
                "duplicateStepTimestampCount" to counters.duplicateStepTimestampCount,
                "nonMonotonicStepTimestampCount" to counters.nonMonotonicStepTimestampCount,
                "duplicateArFrameTimestampCount" to counters.duplicateArFrameTimestampCount,
                "nonMonotonicArFrameTimestampCount" to counters.nonMonotonicArFrameTimestampCount,
                "finalFusedEastM" to ekf.x[0],
                "finalFusedNorthM" to ekf.x[1],
                "finalFusedHeadingRad" to ekf.x[2],
                "finalFusedHorizontalDisplacementM" to fusedHorizontal,
                "finalVarianceEastM2" to ekf.p[0],
                "finalVarianceNorthM2" to ekf.p[4],
                "finalVarianceHeadingRad2" to ekf.p[8],
                "finalCovarianceEastNorth" to ekf.p[1],
                "finalCovarianceEastHeading" to ekf.p[2],
                "finalCovarianceNorthHeading" to ekf.p[5],
                "finalPdrEastM" to pdrEastM,
                "finalPdrNorthM" to pdrNorthM,
                "finalPdrHorizontalDisplacementM" to pdrHorizontal,
                "finalArcoreEastM" to finalArEastM,
                "finalArcoreNorthM" to finalArNorthM,
                "finalArcoreHorizontalDisplacementM" to arHorizontal,
                "headingInnovationCount" to headingInnovations.size.toLong(),
                "meanAbsHeadingInnovationRad" to meanOrNull(headingInnovations),
                "medianAbsHeadingInnovationRad" to medianOrNull(headingInnovations),
                "maxAbsHeadingInnovationRad" to headingInnovations.maxOrNull(),
                "arcoreInnovationCount" to arcoreInnovations.size.toLong(),
                "meanArcoreInnovationNormM" to meanOrNull(arcoreInnovations),
                "medianArcoreInnovationNormM" to medianOrNull(arcoreInnovations),
                "maxArcoreInnovationNormM" to arcoreInnovations.maxOrNull(),
                "qualityEngineImplemented" to true,
                "ekfImplemented" to true,
                "pdrArcoreFusionImplemented" to true,
                "fusionStateDimension" to 3,
                "fusionStateDefinition" to "E,N,heading",
                "josephCovarianceUpdateUsed" to true,
                "circularHeadingInnovationUsed" to true,
                "configDImplemented" to true,
                "fusionAccuracyValidated" to false,
                "qualityThresholdsValidated" to false,
                "noiseParametersValidated" to false,
                "stepDetectionAccuracyValidated" to false,
                "stepLengthValidated" to false,
                "headingAccuracyValidated" to false,
                "trueNorthAccuracyValidated" to false,
                "arcorePositionAccuracyValidated" to false,
                "arcoreDistanceAccuracyValidated" to false,
                "protectedGroundTruthAccessed" to false,
                "liveGnssRequested" to false,
                "gnssRecoveryImplemented" to false,
                "fullGnssDeniedNavigationImplemented" to false,
                "rawSensorSamplesReturned" to false,
                "rawArcorePosesReturned" to false,
                "rawTrajectoryReturned" to false,
                "rawTimestampsReturned" to false,
                "cameraImagesReturned" to false,
                "persistenceUsed" to false,
            )
        }
    }

    private enum class Quality {
        UNKNOWN,
        GOOD,
        USABLE,
        DEGRADED,
        UNRELIABLE,
        UNAVAILABLE,
    }

    private sealed class FusionEvent(
        val timestampNs: Long,
        val insertionIndex: Long,
        val priority: Int,
    )

    private class HeadingEvent(
        timestampNs: Long,
        insertionIndex: Long,
        val headingRad: Double,
        val quality: Quality,
    ) : FusionEvent(timestampNs, insertionIndex, 0)

    private class StepEvent(
        timestampNs: Long,
        insertionIndex: Long,
    ) : FusionEvent(timestampNs, insertionIndex, 1)

    private class ArcoreEvent(
        timestampNs: Long,
        insertionIndex: Long,
        val eastM: Double,
        val northM: Double,
        val upM: Double,
        val quality: Quality,
    ) : FusionEvent(timestampNs, insertionIndex, 2)

    private data class RotationSample(
        val timestampNs: Long,
        val trueHeadingRad: Double,
        val reportedAccuracyRad: Double?,
        val quality: Quality,
        val trueEnuDevice: DoubleArray,
    ) {
        fun copy(): RotationSample =
            RotationSample(
                timestampNs,
                trueHeadingRad,
                reportedAccuracyRad,
                quality,
                trueEnuDevice.copyOf(),
            )
    }

    private data class AvailabilitySnapshot(
        val supported: Boolean,
        val installedAndCurrent: Boolean,
    )

    private class QualityCounts {
        var good = 0L
        var usable = 0L
        var degraded = 0L
        var unreliable = 0L
        var unavailable = 0L

        fun increment(quality: Quality) {
            when (quality) {
                Quality.GOOD -> good += 1L
                Quality.USABLE -> usable += 1L
                Quality.DEGRADED -> degraded += 1L
                Quality.UNRELIABLE -> unreliable += 1L
                Quality.UNAVAILABLE -> unavailable += 1L
                Quality.UNKNOWN -> Unit
            }
        }
    }

    private class FusionCounters {
        val headingQuality = QualityCounts()
        val pdrQuality = QualityCounts()
        val arcoreQuality = QualityCounts()
        var headingEventCount = 0L
        var stepEventCount = 0L
        var invalidStepEventCount = 0L
        var arFrameUpdateCount = 0L
        var arTrackingFrameCount = 0L
        var duplicateHeadingTimestampCount = 0L
        var nonMonotonicHeadingTimestampCount = 0L
        var duplicateStepTimestampCount = 0L
        var nonMonotonicStepTimestampCount = 0L
        var duplicateArFrameTimestampCount = 0L
        var nonMonotonicArFrameTimestampCount = 0L
        var headingMeasurementsApplied = 0L
        var headingMeasurementsSkippedByQuality = 0L
        var pdrPredictionsApplied = 0L
        var pdrPredictionsSkippedNoHeading = 0L
        var pdrPredictionsSkippedByQuality = 0L
        var arcoreMeasurementsApplied = 0L
        var arcoreMeasurementsSkippedByQuality = 0L
    }

    private class EkfState(
        val x: DoubleArray,
        var p: DoubleArray,
    ) {
        fun predictStep(qualityMultiplier: Double) {
            val heading = x[2]
            val sinHeading = sin(heading)
            val cosHeading = cos(heading)
            val f =
                doubleArrayOf(
                    1.0, 0.0, STEP_LENGTH_M * cosHeading,
                    0.0, 1.0, -STEP_LENGTH_M * sinHeading,
                    0.0, 0.0, 1.0,
                )
            val sigmaLength2 = BASE_STEP_LENGTH_SIGMA_M * BASE_STEP_LENGTH_SIGMA_M * qualityMultiplier
            val sigmaHeading2 =
                BASE_STEP_HEADING_PROCESS_SIGMA_RAD *
                    BASE_STEP_HEADING_PROCESS_SIGMA_RAD * qualityMultiplier
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
            measuredHeadingRad: Double,
            qualityMultiplier: Double,
        ): Double {
            val r = BASE_HEADING_MEASUREMENT_SIGMA_RAD * BASE_HEADING_MEASUREMENT_SIGMA_RAD * qualityMultiplier
            val s = p[8] + r
            require(s.isFinite() && s > 0.0)
            val k = doubleArrayOf(p[2] / s, p[5] / s, p[8] / s)
            val innovation = circularDifference(measuredHeadingRad, x[2])
            x[0] += k[0] * innovation
            x[1] += k[1] * innovation
            x[2] = normalizeHeading(x[2] + (k[2] * innovation))
            val ikh = identity()
            for (row in 0..2) ikh[(row * 3) + 2] -= k[row]
            val krkt = DoubleArray(9) { index -> k[index / 3] * r * k[index % 3] }
            p = symmetrize(addMatrices(multiplyMatrices(multiplyMatrices(ikh, p), transpose(ikh)), krkt))
            validate()
            return innovation
        }

        fun updateArcore(
            eastM: Double,
            northM: Double,
            qualityMultiplier: Double,
        ): Pair<Double, Double> {
            val r = BASE_ARCORE_POSITION_SIGMA_M * BASE_ARCORE_POSITION_SIGMA_M * qualityMultiplier
            val s00 = p[0] + r
            val s01 = p[1]
            val s10 = p[3]
            val s11 = p[4] + r
            val determinant = (s00 * s11) - (s01 * s10)
            require(determinant.isFinite() && determinant > 0.0)
            val inverseS = doubleArrayOf(s11 / determinant, -s01 / determinant, -s10 / determinant, s00 / determinant)
            val k = DoubleArray(6)
            for (row in 0..2) {
                k[row * 2] = (p[row * 3] * inverseS[0]) + (p[(row * 3) + 1] * inverseS[2])
                k[(row * 2) + 1] = (p[row * 3] * inverseS[1]) + (p[(row * 3) + 1] * inverseS[3])
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
            return Pair(innovationEast, innovationNorth)
        }

        fun validate() {
            require(x.all { it.isFinite() })
            require(p.all { it.isFinite() })
            for (index in intArrayOf(0, 4, 8)) require(p[index] >= 0.0)
        }

        companion object {
            fun initial(headingRad: Double): EkfState =
                EkfState(
                    doubleArrayOf(0.0, 0.0, normalizeHeading(headingRad)),
                    doubleArrayOf(
                        0.01, 0.0, 0.0,
                        0.0, 0.01, 0.0,
                        0.0, 0.0, BASE_HEADING_MEASUREMENT_SIGMA_RAD * BASE_HEADING_MEASUREMENT_SIGMA_RAD,
                    ),
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
        const val SNAPSHOT_KIND_PREFLIGHT = "navguard_fusion_preflight"
        const val SNAPSHOT_KIND_RESULT = "navguard_fusion_diagnostic_result"
        const val ESTIMATOR_PROFILE = "config_d_navguard_ekf_v1"
        const val COORDINATE_FRAME = "local_enu"
        const val HEADING_CONVENTION = "clockwise_from_north_0_to_2pi"
        const val ALIGNMENT_HOLD_MS = 2_000L
        const val ALIGNMENT_ACQUISITION_TIMEOUT_MS = 15_000L
        const val FUSION_WINDOW_MS = 30_000L
        const val NANOS_PER_MILLISECOND_LONG = 1_000_000L
        const val NANOS_PER_MILLISECOND = 1_000_000.0
        const val ALIGNMENT_HOLD_NS = ALIGNMENT_HOLD_MS * NANOS_PER_MILLISECOND_LONG
        const val ALIGNMENT_ACQUISITION_TIMEOUT_NS = ALIGNMENT_ACQUISITION_TIMEOUT_MS * NANOS_PER_MILLISECOND_LONG
        const val FUSION_WINDOW_NS = FUSION_WINDOW_MS * NANOS_PER_MILLISECOND_LONG
        const val ROTATION_VECTOR_SAMPLING_PERIOD_US = 20_000
        const val MAX_REPORT_LATENCY_US = 0
        const val SENSOR_THREAD_NAME = "NAVGUARD-Fusion-Sensors"
        const val AR_THREAD_NAME = "NAVGUARD-Fusion-ARCore"
        const val STEP_LENGTH_M = 0.75
        const val BASE_STEP_LENGTH_SIGMA_M = 0.20
        val BASE_STEP_HEADING_PROCESS_SIGMA_RAD = Math.toRadians(5.0)
        val BASE_HEADING_MEASUREMENT_SIGMA_RAD = Math.toRadians(15.0)
        const val BASE_ARCORE_POSITION_SIGMA_M = 0.35
        const val TWO_PI = 2.0 * PI
        const val ARCORE_POSE_SOURCE = "Frame.getAndroidSensorPose"
        const val REFERENCE_STRATEGY = "local_arcore_anchor"
        const val RELATIVE_POSE_STRATEGY = "anchor_inverse_compose_android_sensor_pose"
        const val OPERATION_WINDOW_CLOCK = "SystemClock.elapsedRealtimeNanos"
        const val SENSOR_TIMESTAMP_AUTHORITY = "SensorEvent.timestamp"
        const val AR_FRAME_TIMESTAMP_AUTHORITY = "Frame.getTimestamp"
        const val AR_FRAME_TIMESTAMP_TIME_BASE = "undefined_by_arcore_api"
        const val AR_FUSION_TIMESTAMP_SEMANTICS = "processing_time_after_frame_update_not_camera_capture_time"
        const val DECLINATION_PROVIDER = "android.hardware.GeomagneticField"
        const val DECLINATION_ALTITUDE_SOURCE_ANCHOR = "anchor_ellipsoid_altitude"
        const val DECLINATION_ALTITUDE_SOURCE_ZERO_FALLBACK = "deterministic_zero_fallback"

        const val ERROR_ARCORE_UNAVAILABLE = "navguard_fusion_arcore_unavailable"
        const val ERROR_CAMERA_PERMISSION_REQUIRED = "navguard_fusion_camera_permission_required"
        const val ERROR_ROTATION_VECTOR_UNAVAILABLE = "navguard_fusion_rotation_vector_unavailable"
        const val ERROR_STEP_DETECTOR_UNAVAILABLE = "navguard_fusion_step_detector_unavailable"
        const val ERROR_ACTIVITY_RECOGNITION_PERMISSION_REQUIRED = "activity_recognition_permission_required"
        const val ERROR_ANCHOR_REQUIRED = "navguard_fusion_anchor_required"
        const val ERROR_ALREADY_RUNNING = "navguard_fusion_already_running"
        const val ERROR_ALIGNMENT_TIMEOUT = "navguard_fusion_alignment_timeout"
        const val ERROR_SENSOR_REGISTRATION_FAILED = "navguard_fusion_sensor_registration_failed"
        const val ERROR_EKF_NUMERICAL_FAILURE = "navguard_fusion_ekf_numerical_failure"
        const val ERROR_CANCELLED = "navguard_fusion_cancelled"
        const val ERROR_INTERNAL = "internal_navguard_fusion_error"

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
            headingQuality: Quality,
            headingAgeNs: Long,
        ): Quality {
            if (headingAgeNs < 0L || headingQuality == Quality.UNAVAILABLE) return Quality.UNAVAILABLE
            if (headingQuality == Quality.UNRELIABLE || headingQuality == Quality.UNKNOWN) return Quality.UNRELIABLE
            val ageMs = headingAgeNs.toDouble() / NANOS_PER_MILLISECOND
            if (ageMs > 150.0) return Quality.UNRELIABLE
            if (headingQuality == Quality.DEGRADED || ageMs > 50.0) return Quality.DEGRADED
            return Quality.USABLE
        }

        fun classifyArcoreQuality(gapNs: Long): Quality {
            if (gapNs < 0L) return Quality.UNRELIABLE
            val gapMs = gapNs.toDouble() / NANOS_PER_MILLISECOND
            return when {
                gapMs <= 75.0 -> Quality.GOOD
                gapMs <= 150.0 -> Quality.USABLE
                gapMs <= 300.0 -> Quality.DEGRADED
                else -> Quality.UNRELIABLE
            }
        }

        fun classifyFusionQuality(
            heading: Quality,
            pdr: Quality,
            arcore: Quality,
            accepted: Boolean,
            observed: Boolean,
        ): Quality {
            if (
                arcore == Quality.GOOD &&
                    pdr == Quality.USABLE &&
                    (heading == Quality.GOOD || heading == Quality.USABLE)
            ) return Quality.GOOD
            if (
                (arcore == Quality.GOOD || arcore == Quality.USABLE) &&
                    (pdr == Quality.USABLE || pdr == Quality.DEGRADED) &&
                    heading != Quality.UNRELIABLE &&
                    heading != Quality.UNAVAILABLE &&
                    heading != Quality.UNKNOWN
            ) return Quality.USABLE
            if (accepted) return Quality.DEGRADED
            if (observed) return Quality.UNRELIABLE
            if (heading == Quality.UNAVAILABLE && pdr == Quality.UNAVAILABLE && arcore == Quality.UNAVAILABLE) return Quality.UNAVAILABLE
            return Quality.UNKNOWN
        }

        fun navguardQualityMultiplier(quality: Quality): Double? =
            when (quality) {
                Quality.GOOD -> 1.0
                Quality.USABLE -> 2.0
                Quality.DEGRADED -> 6.0
                Quality.UNRELIABLE, Quality.UNAVAILABLE, Quality.UNKNOWN -> null
            }

        fun normalizeHeading(angle: Double): Double {
            var normalized = angle % TWO_PI
            if (normalized < 0.0) normalized += TWO_PI
            return if (normalized >= TWO_PI) 0.0 else normalized
        }

        fun circularDifference(measured: Double, predicted: Double): Double {
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

        fun meanOrNull(values: List<Double>): Double? =
            if (values.isEmpty()) null else values.average()

        fun medianOrNull(values: List<Double>): Double? {
            if (values.isEmpty()) return null
            val sorted = values.sorted()
            val middle = sorted.size / 2
            return if (sorted.size % 2 == 0) (sorted[middle - 1] + sorted[middle]) / 2.0 else sorted[middle]
        }
    }
}
