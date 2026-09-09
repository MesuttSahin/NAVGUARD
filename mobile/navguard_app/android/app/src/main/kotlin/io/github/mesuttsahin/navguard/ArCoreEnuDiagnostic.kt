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
import kotlin.math.ceil
import kotlin.math.cos
import kotlin.math.sin
import kotlin.math.sqrt

internal class ArCoreEnuDiagnostic(
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
        val availability = readAvailability()
        val rotationVector = getRotationVectorSensor()
        val cameraPermissionGranted = hasCameraPermission()
        val diagnosticRunning = isDiagnosticRunning()

        return linkedMapOf(
            "schemaVersion" to SCHEMA_VERSION,
            "snapshotKind" to SNAPSHOT_KIND_PREFLIGHT,
            "arCoreSupported" to availability.supported,
            "arCoreInstalled" to availability.installedAndCurrent,
            "cameraPermissionGranted" to cameraPermissionGranted,
            "rotationVectorAvailable" to (rotationVector != null),
            "rotationVectorName" to rotationVector?.name,
            "diagnosticRunning" to diagnosticRunning,
            "nativeReady" to
                (
                    availability.supported &&
                        availability.installedAndCurrent &&
                        cameraPermissionGranted &&
                        rotationVector != null &&
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

        if (!hasCameraPermission()) {
            postError(
                callback,
                ERROR_CAMERA_PERMISSION_REQUIRED,
                "Camera permission is required for ARCore-to-ENU diagnostics.",
            )
            return
        }

        val availability = readAvailability()
        if (!availability.supported || !availability.installedAndCurrent) {
            postError(
                callback,
                ERROR_UNAVAILABLE,
                "ARCore is unavailable or not ready on this device.",
            )
            return
        }

        val rotationVector = getRotationVectorSensor()
        if (rotationVector == null) {
            postError(
                callback,
                ERROR_ROTATION_VECTOR_UNAVAILABLE,
                "TYPE_ROTATION_VECTOR is unavailable on this device.",
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

        val diagnosticSession =
            DiagnosticSession(
                rotationVector = rotationVector,
                declinationRad = declinationRad,
                declinationAltitudeSource = declinationAltitudeSource,
                callback = callback,
            )

        if (!reserveSession(diagnosticSession)) {
            postError(
                callback,
                ERROR_ALREADY_RUNNING,
                "An ARCore-to-ENU diagnostic is already running.",
            )
            return
        }

        diagnosticSession.start()
    }

    fun cancelActiveSession(
        message: String = "ARCore-to-ENU diagnostic cancelled by the user.",
    ): Boolean {
        val session =
            synchronized(activeSessionLock) {
                activeSession
            } ?: return false

        return session.cancel(message)
    }

    private fun getRotationVectorSensor(): Sensor? =
        try {
            sensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
        } catch (_: Exception) {
            null
        }

    private fun hasCameraPermission(): Boolean =
        applicationContext.checkSelfPermission(Manifest.permission.CAMERA) ==
            PackageManager.PERMISSION_GRANTED

    private fun readAvailability(): AvailabilitySnapshot {
        val availability =
            try {
                ArCoreApk.getInstance().checkAvailability(applicationContext)
            } catch (_: Exception) {
                return AvailabilitySnapshot(false, false)
            }

        return when (availability) {
            ArCoreApk.Availability.SUPPORTED_INSTALLED ->
                AvailabilitySnapshot(true, true)

            ArCoreApk.Availability.SUPPORTED_APK_TOO_OLD,
            ArCoreApk.Availability.SUPPORTED_NOT_INSTALLED,
            -> AvailabilitySnapshot(true, false)

            ArCoreApk.Availability.UNSUPPORTED_DEVICE_NOT_CAPABLE,
            ArCoreApk.Availability.UNKNOWN_CHECKING,
            ArCoreApk.Availability.UNKNOWN_ERROR,
            ArCoreApk.Availability.UNKNOWN_TIMED_OUT,
            -> AvailabilitySnapshot(false, false)
        }
    }

    private fun reserveSession(session: DiagnosticSession): Boolean =
        synchronized(activeSessionLock) {
            if (activeSession != null) {
                false
            } else {
                activeSession = session
                true
            }
        }

    private fun releaseSession(session: DiagnosticSession) {
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

    private inner class DiagnosticSession(
        private val rotationVector: Sensor,
        private val declinationRad: Double,
        private val declinationAltitudeSource: String,
        private val callback: Callback,
    ) : SensorEventListener {
        private val completed = AtomicBoolean(false)
        private val cancellationRequested = AtomicBoolean(false)
        private val rotationStateLock = Any()
        private val rotationState = RotationState()
        private val arState = ArState()
        private val arThread = HandlerThread(AR_HANDLER_THREAD_NAME)
        private val sensorThread = HandlerThread(SENSOR_HANDLER_THREAD_NAME)
        private val glEnvironment = DiagnosticGlEnvironment()

        @Volatile
        private var alignmentCompleted = false

        @Volatile
        private var cancellationMessage =
            "ARCore-to-ENU diagnostic cancelled by the user."

        private var arHandler: Handler? = null
        private var sensorHandler: Handler? = null
        private var arCoreSession: Session? = null
        private var referenceAnchor: Anchor? = null
        private var frozenEnuFromInitialDevice: DoubleArray? = null
        private var rotationListenerRegistered = false
        private var sessionResumed = false
        private var alignmentHoldStartedNs: Long? = null
        private var measurementStartedNs: Long? = null

        fun start() {
            try {
                sensorThread.start()
                val callbackHandler = Handler(sensorThread.looper)
                sensorHandler = callbackHandler

                val registered =
                    sensorManager.registerListener(
                        this,
                        rotationVector,
                        ROTATION_VECTOR_SAMPLING_PERIOD_US,
                        MAX_REPORT_LATENCY_US,
                        callbackHandler,
                    )
                rotationListenerRegistered = registered
                if (!registered) {
                    finishWithError(
                        ERROR_SESSION_FAILED,
                        "Android rejected the rotation-vector listener registration.",
                    )
                    return
                }

                arThread.start()
                val worker = Handler(arThread.looper)
                arHandler = worker
                if (!worker.post(::runDiagnostic)) {
                    finishWithError(
                        ERROR_SESSION_FAILED,
                        "Unable to start the ARCore-to-ENU worker.",
                    )
                }
            } catch (_: SecurityException) {
                finishWithError(
                    ERROR_CAMERA_PERMISSION_REQUIRED,
                    "Camera permission is required for ARCore-to-ENU diagnostics.",
                )
            } catch (_: Exception) {
                finishWithError(
                    ERROR_INTERNAL,
                    "Unable to start the ARCore-to-ENU diagnostic.",
                )
            }
        }

        fun cancel(message: String): Boolean {
            if (completed.get()) {
                return false
            }
            cancellationMessage = message
            cancellationRequested.set(true)
            return true
        }

        override fun onSensorChanged(event: SensorEvent) {
            if (completed.get() || alignmentCompleted) {
                return
            }

            synchronized(rotationStateLock) {
                if (completed.get() || alignmentCompleted) {
                    return
                }

                rotationState.updateCount += 1L
                val sample = createTrueEnuDeviceRotation(event)
                if (sample == null) {
                    rotationState.invalidSampleCount += 1L
                    return
                }

                if (rotationState.seenTimestamps.contains(sample.timestampNs)) {
                    rotationState.duplicateTimestampCount += 1L
                    return
                }

                val previousTimestamp = rotationState.previousAcceptedTimestampNs
                if (previousTimestamp != null && sample.timestampNs < previousTimestamp) {
                    rotationState.nonMonotonicTimestampCount += 1L
                    return
                }

                rotationState.seenTimestamps.add(sample.timestampNs)
                rotationState.previousAcceptedTimestampNs = sample.timestampNs
                rotationState.latestTrueEnuDeviceRotation = sample.matrix.copyOf()
                rotationState.validSampleCount += 1L
            }
        }

        override fun onAccuracyChanged(
            sensor: Sensor,
            accuracy: Int,
        ) {
            // Accuracy callbacks do not alter the frozen Stage 5 transform.
        }

        private fun createTrueEnuDeviceRotation(
            event: SensorEvent,
        ): RotationSample? {
            if (
                event.sensor.type != Sensor.TYPE_ROTATION_VECTOR ||
                    event.timestamp <= 0L ||
                    event.values.size < REQUIRED_ROTATION_VECTOR_COMPONENT_COUNT
            ) {
                return null
            }

            val componentCount = if (event.values.size >= 4) 4 else 3
            val values = FloatArray(componentCount)
            for (index in 0 until componentCount) {
                val component = event.values[index]
                if (!component.isFinite()) {
                    return null
                }
                values[index] = component
            }

            val magneticRotation = FloatArray(MATRIX_ELEMENT_COUNT)
            try {
                SensorManager.getRotationMatrixFromVector(magneticRotation, values)
            } catch (_: Exception) {
                return null
            }
            if (magneticRotation.any { !it.isFinite() }) {
                return null
            }

            val magneticDevice =
                DoubleArray(MATRIX_ELEMENT_COUNT) { index ->
                    magneticRotation[index].toDouble()
                }
            val trueEnuDevice =
                multiplyMatrices(
                    declinationCorrectionMatrix(declinationRad),
                    magneticDevice,
                )
            if (trueEnuDevice.any { !it.isFinite() }) {
                return null
            }

            return RotationSample(event.timestamp, trueEnuDevice)
        }

        private fun runDiagnostic() {
            if (cancellationRequested.get()) {
                finishWithError(ERROR_CANCELLED, cancellationMessage)
                return
            }

            val session =
                try {
                    Session(applicationContext).also { arCoreSession = it }
                } catch (_: Exception) {
                    finishWithError(
                        ERROR_SESSION_FAILED,
                        "Unable to create the local ARCore session.",
                    )
                    return
                }

            try {
                val config =
                    Config(session).apply {
                        planeFindingMode = Config.PlaneFindingMode.DISABLED
                        lightEstimationMode = Config.LightEstimationMode.DISABLED
                        focusMode = Config.FocusMode.AUTO
                        updateMode = Config.UpdateMode.BLOCKING
                        textureUpdateMode =
                            Config.TextureUpdateMode.BIND_TO_TEXTURE_EXTERNAL_OES
                    }
                session.configure(config)
                glEnvironment.initialize()
                val textureName = glEnvironment.createExternalOesTexture()
                session.setCameraTextureName(textureName)
                session.resume()
                sessionResumed = true
            } catch (_: CameraNotAvailableException) {
                finishWithError(
                    ERROR_SESSION_FAILED,
                    "The ARCore camera is unavailable.",
                )
                return
            } catch (_: Exception) {
                finishWithError(
                    ERROR_SESSION_FAILED,
                    "Unable to configure or resume the local ARCore session.",
                )
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
                    } catch (_: CameraNotAvailableException) {
                        if (cancellationRequested.get()) {
                            finishWithError(ERROR_CANCELLED, cancellationMessage)
                        } else {
                            finishWithError(
                                ERROR_SESSION_FAILED,
                                "The ARCore camera became unavailable.",
                            )
                        }
                        return
                    } catch (_: Exception) {
                        if (cancellationRequested.get()) {
                            finishWithError(ERROR_CANCELLED, cancellationMessage)
                        } else {
                            finishWithError(
                                ERROR_SESSION_FAILED,
                                "The local ARCore session failed.",
                            )
                        }
                        return
                    }

                val nowNs = SystemClock.elapsedRealtimeNanos()
                if (!alignmentCompleted) {
                    try {
                        tryCompleteAlignment(session, frame, nowNs)
                    } catch (_: Exception) {
                        finishWithError(
                            ERROR_SESSION_FAILED,
                            "Unable to establish the local ARCore reference anchor.",
                        )
                        return
                    }

                    if (
                        !alignmentCompleted &&
                            nowNs - acquisitionStartedNs >=
                            ALIGNMENT_ACQUISITION_TIMEOUT_NS
                    ) {
                        finishWithError(
                            ERROR_ALIGNMENT_TIMEOUT,
                            "ARCore tracking and rotation-vector alignment timed out.",
                        )
                        return
                    }
                    continue
                }

                val measurementStart = measurementStartedNs
                if (measurementStart == null) {
                    finishWithError(
                        ERROR_INTERNAL,
                        "The ARCore-to-ENU measurement window was not initialized.",
                    )
                    return
                }

                if (nowNs - measurementStart >= MEASUREMENT_WINDOW_NS) {
                    finishSuccessfully()
                    return
                }

                if (processFormalFrame(frame)) {
                    finishWithError(
                        ERROR_REFERENCE_ANCHOR_LOST,
                        "The local ARCore reference anchor became unusable.",
                    )
                    return
                }
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

            val trueEnuDeviceRotation =
                synchronized(rotationStateLock) {
                    rotationState.latestTrueEnuDeviceRotation?.copyOf()
                }
            if (trueEnuDeviceRotation == null) {
                alignmentHoldStartedNs = null
                return
            }

            val holdStarted = alignmentHoldStartedNs
            if (holdStarted == null) {
                alignmentHoldStartedNs = nowNs
                return
            }
            if (nowNs - holdStarted < ALIGNMENT_HOLD_NS) {
                return
            }

            // Kotlin exposes Frame.getAndroidSensorPose() as androidSensorPose.
            val initialAndroidSensorPose = frame.androidSensorPose
            if (!isFinitePose(initialAndroidSensorPose)) {
                alignmentHoldStartedNs = null
                return
            }

            val anchor = session.createAnchor(initialAndroidSensorPose)
            if (anchor.trackingState != TrackingState.TRACKING) {
                anchor.detach()
                alignmentHoldStartedNs = null
                return
            }

            referenceAnchor = anchor
            frozenEnuFromInitialDevice = trueEnuDeviceRotation
            measurementStartedNs = nowNs
            alignmentCompleted = true
            unregisterRotationListener()
        }

        private fun processFormalFrame(frame: Frame): Boolean {
            arState.arFrameUpdateCount += 1L

            when (frame.camera.trackingState) {
                TrackingState.TRACKING -> arState.trackingFrameCount += 1L
                TrackingState.PAUSED -> arState.pausedFrameCount += 1L
                TrackingState.STOPPED -> arState.stoppedFrameCount += 1L
            }

            val timestampAccepted = recordArFrameTimestamp(frame.timestamp)
            val anchor = referenceAnchor ?: return true
            if (anchor.trackingState == TrackingState.STOPPED) {
                return true
            }

            if (
                !timestampAccepted ||
                    frame.camera.trackingState != TrackingState.TRACKING ||
                    anchor.trackingState != TrackingState.TRACKING
            ) {
                return false
            }

            val currentSensorPose =
                try {
                    frame.androidSensorPose
                } catch (_: Exception) {
                    return false
                }
            if (!isFinitePose(currentSensorPose)) {
                return false
            }

            val relativePose =
                try {
                    anchor.pose.inverse().compose(currentSensorPose)
                } catch (_: Exception) {
                    return false
                }
            if (!isFinitePose(relativePose)) {
                return false
            }

            val relativeTranslation = FloatArray(VECTOR_ELEMENT_COUNT)
            relativePose.getTranslation(relativeTranslation, 0)
            if (relativeTranslation.any { !it.isFinite() }) {
                return false
            }

            val enuRotation = frozenEnuFromInitialDevice ?: return true
            val enu =
                multiplyMatrixVector(
                    enuRotation,
                    doubleArrayOf(
                        relativeTranslation[0].toDouble(),
                        relativeTranslation[1].toDouble(),
                        relativeTranslation[2].toDouble(),
                    ),
                )
            if (enu.any { !it.isFinite() }) {
                return false
            }

            val horizontal = sqrt((enu[0] * enu[0]) + (enu[1] * enu[1]))
            arState.finalEastM = enu[0]
            arState.finalNorthM = enu[1]
            arState.finalUpM = enu[2]
            arState.maxHorizontalDisplacementM =
                maxOf(arState.maxHorizontalDisplacementM, horizontal)
            arState.maxAbsUpM = maxOf(arState.maxAbsUpM, kotlin.math.abs(enu[2]))
            arState.usableEnuFrameCount += 1L
            return false
        }

        private fun recordArFrameTimestamp(timestampNs: Long): Boolean {
            if (timestampNs <= 0L) {
                return false
            }
            if (arState.seenFrameTimestamps.contains(timestampNs)) {
                arState.duplicateArFrameTimestampCount += 1L
                return false
            }
            arState.seenFrameTimestamps.add(timestampNs)

            val previousTimestamp = arState.previousAcceptedFrameTimestampNs
            if (previousTimestamp != null && timestampNs < previousTimestamp) {
                arState.nonMonotonicArFrameTimestampCount += 1L
                return false
            }

            if (previousTimestamp != null) {
                arState.frameDeltasNs.add(timestampNs - previousTimestamp)
            }
            arState.previousAcceptedFrameTimestampNs = timestampNs
            arState.uniqueArFrameTimestampCount += 1L
            return true
        }

        private fun finishSuccessfully() {
            if (!completed.compareAndSet(false, true)) {
                return
            }

            cleanup()
            val rotationSnapshot =
                synchronized(rotationStateLock) {
                    rotationState.snapshot(
                        declinationRad = declinationRad,
                        declinationAltitudeSource = declinationAltitudeSource,
                    )
                }
            val summary = createSummary(rotationSnapshot, arState)
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

        private fun unregisterRotationListener() {
            runCatching {
                if (rotationListenerRegistered) {
                    sensorManager.unregisterListener(this)
                    rotationListenerRegistered = false
                }
            }
        }

        private fun cleanup() {
            runCatching { arHandler?.removeCallbacksAndMessages(null) }
            runCatching { sensorHandler?.removeCallbacksAndMessages(null) }
            unregisterRotationListener()
            runCatching { referenceAnchor?.detach() }
            referenceAnchor = null
            runCatching {
                if (sessionResumed) {
                    arCoreSession?.pause()
                }
            }
            runCatching { arCoreSession?.close() }
            arCoreSession = null
            runCatching { glEnvironment.release() }
            runCatching {
                if (arThread.isAlive) {
                    arThread.quitSafely()
                }
            }
            runCatching {
                if (sensorThread.isAlive) {
                    sensorThread.quitSafely()
                }
            }
            arHandler = null
            sensorHandler = null
        }
    }

    private fun createSummary(
        rotation: RotationStateSnapshot,
        ar: ArState,
    ): Map<String, Any?> {
        val sortedFrameDeltasNs = ar.frameDeltasNs.sorted()
        val deltaCount = sortedFrameDeltasNs.size.toLong()
        val minFrameDeltaMs =
            sortedFrameDeltasNs.firstOrNull()?.toDouble()?.div(NANOS_PER_MILLISECOND)
        val maxFrameDeltaMs =
            sortedFrameDeltasNs.lastOrNull()?.toDouble()?.div(NANOS_PER_MILLISECOND)
        val meanFrameDeltaMs =
            if (sortedFrameDeltasNs.isEmpty()) {
                null
            } else {
                sortedFrameDeltasNs.average() / NANOS_PER_MILLISECOND
            }
        val medianFrameDeltaMs =
            calculateMedian(sortedFrameDeltasNs)?.div(NANOS_PER_MILLISECOND)
        val p95FrameDeltaMs =
            calculateNearestRankP95(sortedFrameDeltasNs)
                ?.toDouble()
                ?.div(NANOS_PER_MILLISECOND)
        val observedTrackingFrameRateHz =
            if (meanFrameDeltaMs != null && meanFrameDeltaMs > 0.0) {
                MILLIS_PER_SECOND / meanFrameDeltaMs
            } else {
                null
            }
        val trackingFraction =
            if (ar.arFrameUpdateCount == 0L) {
                0.0
            } else {
                ar.trackingFrameCount.toDouble() / ar.arFrameUpdateCount.toDouble()
            }
        val finalHorizontalDisplacementM =
            sqrt(
                (ar.finalEastM * ar.finalEastM) +
                    (ar.finalNorthM * ar.finalNorthM),
            )
        val final3dDisplacementM =
            sqrt(
                (ar.finalEastM * ar.finalEastM) +
                    (ar.finalNorthM * ar.finalNorthM) +
                    (ar.finalUpM * ar.finalUpM),
            )

        return linkedMapOf(
            "schemaVersion" to SCHEMA_VERSION,
            "snapshotKind" to SNAPSHOT_KIND_RESULT,
            "success" to true,
            "alignmentHoldMs" to ALIGNMENT_HOLD_MS,
            "measurementWindowMs" to MEASUREMENT_WINDOW_MS,
            "coordinateFrame" to COORDINATE_FRAME,
            "arcorePoseSource" to ARCORE_POSE_SOURCE,
            "referenceStrategy" to REFERENCE_STRATEGY,
            "relativePoseStrategy" to RELATIVE_POSE_STRATEGY,
            "enuAlignmentSource" to ENU_ALIGNMENT_SOURCE,
            "rotationVectorSource" to ROTATION_VECTOR_SOURCE,
            "rotationVectorTimestampAuthority" to SENSOR_TIMESTAMP_AUTHORITY,
            "arFrameTimestampAuthority" to AR_FRAME_TIMESTAMP_AUTHORITY,
            "arFrameTimestampTimeBase" to AR_FRAME_TIMESTAMP_TIME_BASE,
            "operationWindowClock" to OPERATION_WINDOW_CLOCK,
            "crossClockTimestampComparisonUsed" to false,
            "alignmentCompleted" to true,
            "alignmentStationarityAssumed" to true,
            "alignmentStationarityValidated" to false,
            "trueNorthAlignmentUsed" to true,
            "anchorUsedForDeclination" to true,
            "liveGnssUsed" to false,
            "declinationRad" to rotation.declinationRad,
            "declinationProvider" to DECLINATION_PROVIDER,
            "declinationModelVersion" to DECLINATION_MODEL_VERSION,
            "declinationModelFreshnessValidated" to false,
            "declinationAltitudeSource" to rotation.declinationAltitudeSource,
            "rotationVectorUpdateCount" to rotation.updateCount,
            "validRotationVectorSampleCount" to rotation.validSampleCount,
            "invalidRotationVectorSampleCount" to rotation.invalidSampleCount,
            "uniqueRotationVectorTimestampCount" to rotation.uniqueTimestampCount,
            "duplicateRotationVectorTimestampCount" to
                rotation.duplicateTimestampCount,
            "nonMonotonicRotationVectorTimestampCount" to
                rotation.nonMonotonicTimestampCount,
            "arFrameUpdateCount" to ar.arFrameUpdateCount,
            "trackingFrameCount" to ar.trackingFrameCount,
            "pausedFrameCount" to ar.pausedFrameCount,
            "stoppedFrameCount" to ar.stoppedFrameCount,
            "usableEnuFrameCount" to ar.usableEnuFrameCount,
            "uniqueArFrameTimestampCount" to ar.uniqueArFrameTimestampCount,
            "duplicateArFrameTimestampCount" to
                ar.duplicateArFrameTimestampCount,
            "nonMonotonicArFrameTimestampCount" to
                ar.nonMonotonicArFrameTimestampCount,
            "deltaCount" to deltaCount,
            "minFrameDeltaMs" to minFrameDeltaMs,
            "maxFrameDeltaMs" to maxFrameDeltaMs,
            "meanFrameDeltaMs" to meanFrameDeltaMs,
            "medianFrameDeltaMs" to medianFrameDeltaMs,
            "p95FrameDeltaMs" to p95FrameDeltaMs,
            "observedTrackingFrameRateHz" to observedTrackingFrameRateHz,
            "trackingFraction" to trackingFraction,
            "trackingFractionDenominator" to TRACKING_FRACTION_DENOMINATOR,
            "finalEastM" to ar.finalEastM,
            "finalNorthM" to ar.finalNorthM,
            "finalUpM" to ar.finalUpM,
            "finalHorizontalDisplacementM" to finalHorizontalDisplacementM,
            "final3dDisplacementM" to final3dDisplacementM,
            "maxHorizontalDisplacementM" to ar.maxHorizontalDisplacementM,
            "maxAbsUpM" to ar.maxAbsUpM,
            "arcoreRelativeMotionImplemented" to true,
            "arcoreToEnuImplemented" to true,
            "arcorePositionAccuracyValidated" to false,
            "arcoreDistanceAccuracyValidated" to false,
            "enuAlignmentAccuracyValidated" to false,
            "headingAccuracyValidated" to false,
            "trueNorthAccuracyValidated" to false,
            "pdrFusionImplemented" to false,
            "qualityEngineImplemented" to false,
            "ekfImplemented" to false,
            "groundTruthFirewallImplemented" to false,
            "gnssDeniedNavigationImplemented" to false,
            "rawTrajectoryReturned" to false,
            "rawArcorePosesReturned" to false,
            "rawRotationVectorSamplesReturned" to false,
            "rawTimestampsReturned" to false,
            "cameraImagesReturned" to false,
            "persistenceUsed" to false,
            "pathLengthCalculated" to false,
            "displayRotationRemappingUsed" to false,
            "cameraOpticalForwardUsed" to false,
            "geospatialApiUsed" to false,
            "cloudServiceUsed" to false,
        )
    }

    private data class AvailabilitySnapshot(
        val supported: Boolean,
        val installedAndCurrent: Boolean,
    )

    private data class RotationSample(
        val timestampNs: Long,
        val matrix: DoubleArray,
    )

    private data class RotationState(
        var updateCount: Long = 0L,
        var validSampleCount: Long = 0L,
        var invalidSampleCount: Long = 0L,
        var duplicateTimestampCount: Long = 0L,
        var nonMonotonicTimestampCount: Long = 0L,
        var previousAcceptedTimestampNs: Long? = null,
        var latestTrueEnuDeviceRotation: DoubleArray? = null,
        val seenTimestamps: MutableSet<Long> = mutableSetOf(),
    ) {
        fun snapshot(
            declinationRad: Double,
            declinationAltitudeSource: String,
        ) =
            RotationStateSnapshot(
                updateCount = updateCount,
                validSampleCount = validSampleCount,
                invalidSampleCount = invalidSampleCount,
                uniqueTimestampCount = seenTimestamps.size.toLong(),
                duplicateTimestampCount = duplicateTimestampCount,
                nonMonotonicTimestampCount = nonMonotonicTimestampCount,
                declinationRad = declinationRad,
                declinationAltitudeSource = declinationAltitudeSource,
            )
    }

    private data class RotationStateSnapshot(
        val updateCount: Long,
        val validSampleCount: Long,
        val invalidSampleCount: Long,
        val uniqueTimestampCount: Long,
        val duplicateTimestampCount: Long,
        val nonMonotonicTimestampCount: Long,
        val declinationRad: Double,
        val declinationAltitudeSource: String,
    )

    private data class ArState(
        var arFrameUpdateCount: Long = 0L,
        var trackingFrameCount: Long = 0L,
        var pausedFrameCount: Long = 0L,
        var stoppedFrameCount: Long = 0L,
        var usableEnuFrameCount: Long = 0L,
        var uniqueArFrameTimestampCount: Long = 0L,
        var duplicateArFrameTimestampCount: Long = 0L,
        var nonMonotonicArFrameTimestampCount: Long = 0L,
        var previousAcceptedFrameTimestampNs: Long? = null,
        val seenFrameTimestamps: MutableSet<Long> = mutableSetOf(),
        val frameDeltasNs: MutableList<Long> = mutableListOf(),
        var finalEastM: Double = 0.0,
        var finalNorthM: Double = 0.0,
        var finalUpM: Double = 0.0,
        var maxHorizontalDisplacementM: Double = 0.0,
        var maxAbsUpM: Double = 0.0,
    )

    private class DiagnosticGlEnvironment {
        private var display: EGLDisplay = EGL14.EGL_NO_DISPLAY
        private var context: EGLContext = EGL14.EGL_NO_CONTEXT
        private var surface: EGLSurface = EGL14.EGL_NO_SURFACE
        private var textureName = 0
        private var contextCurrent = false

        fun initialize() {
            display = EGL14.eglGetDisplay(EGL14.EGL_DEFAULT_DISPLAY)
            if (display == EGL14.EGL_NO_DISPLAY) {
                error("Unable to acquire the EGL display.")
            }

            val versions = IntArray(2)
            if (!EGL14.eglInitialize(display, versions, 0, versions, 1)) {
                error("Unable to initialize EGL.")
            }

            val configAttributes =
                intArrayOf(
                    EGL14.EGL_RENDERABLE_TYPE,
                    EGL14.EGL_OPENGL_ES2_BIT,
                    EGL14.EGL_SURFACE_TYPE,
                    EGL14.EGL_PBUFFER_BIT,
                    EGL14.EGL_RED_SIZE,
                    8,
                    EGL14.EGL_GREEN_SIZE,
                    8,
                    EGL14.EGL_BLUE_SIZE,
                    8,
                    EGL14.EGL_ALPHA_SIZE,
                    8,
                    EGL14.EGL_NONE,
                )
            val configs = arrayOfNulls<EGLConfig>(1)
            val configCount = IntArray(1)
            if (
                !EGL14.eglChooseConfig(
                    display,
                    configAttributes,
                    0,
                    configs,
                    0,
                    configs.size,
                    configCount,
                    0,
                ) || configCount[0] < 1
            ) {
                error("Unable to choose an EGL configuration.")
            }

            val config = configs[0] ?: error("EGL returned no configuration.")
            context =
                EGL14.eglCreateContext(
                    display,
                    config,
                    EGL14.EGL_NO_CONTEXT,
                    intArrayOf(
                        EGL14.EGL_CONTEXT_CLIENT_VERSION,
                        2,
                        EGL14.EGL_NONE,
                    ),
                    0,
                )
            if (context == EGL14.EGL_NO_CONTEXT) {
                error("Unable to create the EGL context.")
            }

            surface =
                EGL14.eglCreatePbufferSurface(
                    display,
                    config,
                    intArrayOf(
                        EGL14.EGL_WIDTH,
                        1,
                        EGL14.EGL_HEIGHT,
                        1,
                        EGL14.EGL_NONE,
                    ),
                    0,
                )
            if (surface == EGL14.EGL_NO_SURFACE) {
                error("Unable to create the EGL pbuffer surface.")
            }
            if (!EGL14.eglMakeCurrent(display, surface, surface, context)) {
                error("Unable to make the diagnostic EGL context current.")
            }
            contextCurrent = true
        }

        fun createExternalOesTexture(): Int {
            check(contextCurrent)
            val textures = IntArray(1)
            GLES20.glGenTextures(1, textures, 0)
            textureName = textures[0]
            if (textureName == 0) {
                error("OpenGL did not create a camera texture.")
            }

            GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, textureName)
            GLES20.glTexParameteri(
                GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
                GLES20.GL_TEXTURE_MIN_FILTER,
                GLES20.GL_LINEAR,
            )
            GLES20.glTexParameteri(
                GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
                GLES20.GL_TEXTURE_MAG_FILTER,
                GLES20.GL_LINEAR,
            )
            GLES20.glTexParameteri(
                GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
                GLES20.GL_TEXTURE_WRAP_S,
                GLES20.GL_CLAMP_TO_EDGE,
            )
            GLES20.glTexParameteri(
                GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
                GLES20.GL_TEXTURE_WRAP_T,
                GLES20.GL_CLAMP_TO_EDGE,
            )
            if (GLES20.glGetError() != GLES20.GL_NO_ERROR) {
                error("OpenGL rejected the external OES camera texture.")
            }
            return textureName
        }

        fun release() {
            if (display != EGL14.EGL_NO_DISPLAY && contextCurrent) {
                if (textureName != 0) {
                    GLES20.glDeleteTextures(1, intArrayOf(textureName), 0)
                    textureName = 0
                }
                EGL14.eglMakeCurrent(
                    display,
                    EGL14.EGL_NO_SURFACE,
                    EGL14.EGL_NO_SURFACE,
                    EGL14.EGL_NO_CONTEXT,
                )
                contextCurrent = false
            }
            if (
                display != EGL14.EGL_NO_DISPLAY &&
                    surface != EGL14.EGL_NO_SURFACE
            ) {
                EGL14.eglDestroySurface(display, surface)
                surface = EGL14.EGL_NO_SURFACE
            }
            if (
                display != EGL14.EGL_NO_DISPLAY &&
                    context != EGL14.EGL_NO_CONTEXT
            ) {
                EGL14.eglDestroyContext(display, context)
                context = EGL14.EGL_NO_CONTEXT
            }
            if (display != EGL14.EGL_NO_DISPLAY) {
                EGL14.eglTerminate(display)
                display = EGL14.EGL_NO_DISPLAY
            }
            EGL14.eglReleaseThread()
        }
    }

    private companion object {
        const val SCHEMA_VERSION = 1
        const val SNAPSHOT_KIND_PREFLIGHT = "arcore_enu_preflight"
        const val SNAPSHOT_KIND_RESULT = "arcore_enu_diagnostic_result"
        const val ALIGNMENT_HOLD_MS = 2_000L
        const val ALIGNMENT_ACQUISITION_TIMEOUT_MS = 15_000L
        const val MEASUREMENT_WINDOW_MS = 30_000L
        const val NANOS_PER_MILLISECOND_LONG = 1_000_000L
        const val NANOS_PER_MILLISECOND = 1_000_000.0
        const val MILLIS_PER_SECOND = 1_000.0
        const val ALIGNMENT_HOLD_NS =
            ALIGNMENT_HOLD_MS * NANOS_PER_MILLISECOND_LONG
        const val ALIGNMENT_ACQUISITION_TIMEOUT_NS =
            ALIGNMENT_ACQUISITION_TIMEOUT_MS * NANOS_PER_MILLISECOND_LONG
        const val MEASUREMENT_WINDOW_NS =
            MEASUREMENT_WINDOW_MS * NANOS_PER_MILLISECOND_LONG
        const val ROTATION_VECTOR_SAMPLING_PERIOD_US = 20_000
        const val MAX_REPORT_LATENCY_US = 0
        const val REQUIRED_ROTATION_VECTOR_COMPONENT_COUNT = 3
        const val MATRIX_ELEMENT_COUNT = 9
        const val VECTOR_ELEMENT_COUNT = 3
        const val AR_HANDLER_THREAD_NAME = "NAVGUARD-ArCoreEnu"
        const val SENSOR_HANDLER_THREAD_NAME = "NAVGUARD-ArCoreEnu-Rotation"

        const val COORDINATE_FRAME = "local_enu"
        const val ARCORE_POSE_SOURCE = "Frame.getAndroidSensorPose"
        const val REFERENCE_STRATEGY = "local_arcore_anchor"
        const val RELATIVE_POSE_STRATEGY =
            "anchor_inverse_compose_android_sensor_pose"
        const val ENU_ALIGNMENT_SOURCE =
            "rotation_vector_plus_geomagnetic_declination"
        const val ROTATION_VECTOR_SOURCE = "TYPE_ROTATION_VECTOR"
        const val SENSOR_TIMESTAMP_AUTHORITY = "SensorEvent.timestamp"
        const val AR_FRAME_TIMESTAMP_AUTHORITY = "Frame.getTimestamp"
        const val AR_FRAME_TIMESTAMP_TIME_BASE = "undefined_by_arcore_api"
        const val OPERATION_WINDOW_CLOCK = "SystemClock.elapsedRealtimeNanos"
        const val TRACKING_FRACTION_DENOMINATOR =
            "arFrameUpdateCount_formal_window"
        const val DECLINATION_PROVIDER = "android.hardware.GeomagneticField"
        const val DECLINATION_MODEL_VERSION = "platform_managed"
        const val DECLINATION_ALTITUDE_SOURCE_ANCHOR =
            "anchor_ellipsoid_altitude"
        const val DECLINATION_ALTITUDE_SOURCE_ZERO_FALLBACK =
            "deterministic_zero_fallback"

        const val ERROR_UNAVAILABLE = "arcore_enu_unavailable"
        const val ERROR_CAMERA_PERMISSION_REQUIRED =
            "arcore_enu_camera_permission_required"
        const val ERROR_ROTATION_VECTOR_UNAVAILABLE =
            "arcore_enu_rotation_vector_unavailable"
        const val ERROR_ANCHOR_REQUIRED = "arcore_enu_anchor_required"
        const val ERROR_ALREADY_RUNNING = "arcore_enu_already_running"
        const val ERROR_ALIGNMENT_TIMEOUT = "arcore_enu_alignment_timeout"
        const val ERROR_REFERENCE_ANCHOR_LOST =
            "arcore_enu_reference_anchor_lost"
        const val ERROR_SESSION_FAILED = "arcore_enu_session_failed"
        const val ERROR_CANCELLED = "arcore_enu_cancelled"
        const val ERROR_INTERNAL = "internal_arcore_enu_error"

        fun declinationCorrectionMatrix(declinationRad: Double): DoubleArray =
            doubleArrayOf(
                cos(declinationRad),
                sin(declinationRad),
                0.0,
                -sin(declinationRad),
                cos(declinationRad),
                0.0,
                0.0,
                0.0,
                1.0,
            )

        fun multiplyMatrices(
            left: DoubleArray,
            right: DoubleArray,
        ): DoubleArray {
            require(left.size == MATRIX_ELEMENT_COUNT)
            require(right.size == MATRIX_ELEMENT_COUNT)
            return DoubleArray(MATRIX_ELEMENT_COUNT) { index ->
                val row = index / VECTOR_ELEMENT_COUNT
                val column = index % VECTOR_ELEMENT_COUNT
                var value = 0.0
                for (inner in 0 until VECTOR_ELEMENT_COUNT) {
                    value +=
                        left[(row * VECTOR_ELEMENT_COUNT) + inner] *
                        right[(inner * VECTOR_ELEMENT_COUNT) + column]
                }
                value
            }
        }

        fun multiplyMatrixVector(
            matrix: DoubleArray,
            vector: DoubleArray,
        ): DoubleArray {
            require(matrix.size == MATRIX_ELEMENT_COUNT)
            require(vector.size == VECTOR_ELEMENT_COUNT)
            return DoubleArray(VECTOR_ELEMENT_COUNT) { row ->
                var value = 0.0
                for (column in 0 until VECTOR_ELEMENT_COUNT) {
                    value +=
                        matrix[(row * VECTOR_ELEMENT_COUNT) + column] *
                        vector[column]
                }
                value
            }
        }

        fun isFinitePose(pose: Pose): Boolean {
            val translation = FloatArray(VECTOR_ELEMENT_COUNT)
            val quaternion = FloatArray(4)
            pose.getTranslation(translation, 0)
            pose.getRotationQuaternion(quaternion, 0)
            return translation.all { it.isFinite() } &&
                quaternion.all { it.isFinite() }
        }

        fun calculateMedian(sortedValues: List<Long>): Double? {
            if (sortedValues.isEmpty()) {
                return null
            }
            val middle = sortedValues.size / 2
            return if (sortedValues.size % 2 == 0) {
                (
                    sortedValues[middle - 1].toDouble() +
                        sortedValues[middle].toDouble()
                ) / 2.0
            } else {
                sortedValues[middle].toDouble()
            }
        }

        fun calculateNearestRankP95(sortedValues: List<Long>): Long? {
            if (sortedValues.isEmpty()) {
                return null
            }
            val oneBasedRank = ceil(0.95 * sortedValues.size).toInt()
            return sortedValues[(oneBasedRank - 1).coerceIn(0, sortedValues.lastIndex)]
        }
    }
}
