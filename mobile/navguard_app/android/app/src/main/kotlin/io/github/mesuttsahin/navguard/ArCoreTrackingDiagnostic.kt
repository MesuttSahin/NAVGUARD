package io.github.mesuttsahin.navguard

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
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
import com.google.ar.core.ArCoreApk
import com.google.ar.core.Config
import com.google.ar.core.Session
import com.google.ar.core.TrackingState
import com.google.ar.core.exceptions.CameraNotAvailableException
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.math.ceil
import kotlin.math.sqrt

internal class ArCoreTrackingDiagnostic(
    private val applicationContext: Context,
    private val resultHandler: Handler = Handler(Looper.getMainLooper()),
) {
    internal interface Callback {
        fun onSuccess(summary: Map<String, Any?>)

        fun onError(code: String, message: String)
    }

    private val activeSessionLock = Any()
    private var activeSession: DiagnosticSession? = null

    fun createPreflightSnapshot(): Map<String, Any?> {
        val cameraPermissionGranted = hasCameraPermission()
        val availability = readAvailability()

        return linkedMapOf(
            "schemaVersion" to SCHEMA_VERSION,
            "snapshotKind" to SNAPSHOT_KIND_PREFLIGHT,
            "cameraPermissionGranted" to cameraPermissionGranted,
            "availabilityRaw" to availability.raw,
            "availabilityCategory" to availability.category,
            "arCoreSupported" to availability.supported,
            "arCoreInstalledAndCurrent" to availability.installedAndCurrent,
            "canRunFormalDiagnostic" to
                (cameraPermissionGranted && availability.ready),
        )
    }

    fun createCameraPermissionResultSnapshot(
        requestOutcome: String,
    ): Map<String, Any?> {
        val snapshot = LinkedHashMap(createPreflightSnapshot())
        snapshot["snapshotKind"] = SNAPSHOT_KIND_PERMISSION_RESULT
        snapshot["requestOutcome"] = requestOutcome
        return snapshot
    }

    fun start(
        activity: Activity,
        callback: Callback,
    ) {
        if (hasActiveSession()) {
            postError(
                callback,
                ERROR_ALREADY_RUNNING,
                "An ARCore tracking diagnostic is already running.",
            )
            return
        }

        val preflight = createPreflightSnapshot()

        if (!hasCameraPermission()) {
            postSuccess(
                callback,
                createEmptySummary(
                    COMPLETION_CAMERA_PERMISSION_MISSING,
                    preflight,
                ),
            )
            return
        }

        val availabilityRaw = preflight["availabilityRaw"] as? String

        if (availabilityRaw != AVAILABILITY_SUPPORTED_INSTALLED) {
            if (
                availabilityRaw == AVAILABILITY_SUPPORTED_NOT_INSTALLED ||
                    availabilityRaw == AVAILABILITY_SUPPORTED_APK_TOO_OLD
            ) {
                val installStatus =
                    try {
                        ArCoreApk.getInstance().requestInstall(activity, true)
                    } catch (_: Exception) {
                        postSuccess(
                            callback,
                            createEmptySummary(
                                COMPLETION_ARCORE_NOT_READY,
                                createPreflightSnapshot(),
                            ),
                        )
                        return
                    }

                if (installStatus == ArCoreApk.InstallStatus.INSTALL_REQUESTED) {
                    postSuccess(
                        callback,
                        createEmptySummary(
                            COMPLETION_ARCORE_INSTALL_REQUESTED,
                            createPreflightSnapshot(),
                        ),
                    )
                    return
                }
            } else {
                postSuccess(
                    callback,
                    createEmptySummary(
                        COMPLETION_ARCORE_NOT_READY,
                        preflight,
                    ),
                )
                return
            }
        }

        val refreshedPreflight = createPreflightSnapshot()

        if (refreshedPreflight["canRunFormalDiagnostic"] != true) {
            postSuccess(
                callback,
                createEmptySummary(
                    COMPLETION_ARCORE_NOT_READY,
                    refreshedPreflight,
                ),
            )
            return
        }

        val session = DiagnosticSession(callback, refreshedPreflight)

        if (!reserveSession(session)) {
            postError(
                callback,
                ERROR_ALREADY_RUNNING,
                "An ARCore tracking diagnostic is already running.",
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

    private fun hasCameraPermission(): Boolean =
        applicationContext.checkSelfPermission(Manifest.permission.CAMERA) ==
            PackageManager.PERMISSION_GRANTED

    private fun readAvailability(): AvailabilitySnapshot {
        val availability =
            try {
                ArCoreApk.getInstance().checkAvailability(applicationContext)
            } catch (_: Exception) {
                return AvailabilitySnapshot(
                    raw = AVAILABILITY_QUERY_ERROR,
                    category = AVAILABILITY_CATEGORY_UNKNOWN_ERROR,
                    supported = null,
                    installedAndCurrent = null,
                    ready = false,
                )
            }

        return when (availability) {
            ArCoreApk.Availability.SUPPORTED_INSTALLED ->
                AvailabilitySnapshot(
                    raw = availability.name,
                    category = AVAILABILITY_CATEGORY_READY,
                    supported = true,
                    installedAndCurrent = true,
                    ready = true,
                )

            ArCoreApk.Availability.SUPPORTED_APK_TOO_OLD,
            ArCoreApk.Availability.SUPPORTED_NOT_INSTALLED,
            ->
                AvailabilitySnapshot(
                    raw = availability.name,
                    category =
                        AVAILABILITY_CATEGORY_INSTALL_OR_UPDATE_REQUIRED,
                    supported = true,
                    installedAndCurrent = false,
                    ready = false,
                )

            ArCoreApk.Availability.UNSUPPORTED_DEVICE_NOT_CAPABLE ->
                AvailabilitySnapshot(
                    raw = availability.name,
                    category = AVAILABILITY_CATEGORY_UNSUPPORTED,
                    supported = false,
                    installedAndCurrent = null,
                    ready = false,
                )

            ArCoreApk.Availability.UNKNOWN_CHECKING ->
                AvailabilitySnapshot(
                    raw = availability.name,
                    category = AVAILABILITY_CATEGORY_CHECKING,
                    supported = null,
                    installedAndCurrent = null,
                    ready = false,
                )

            ArCoreApk.Availability.UNKNOWN_ERROR,
            ArCoreApk.Availability.UNKNOWN_TIMED_OUT,
            ->
                AvailabilitySnapshot(
                    raw = availability.name,
                    category = AVAILABILITY_CATEGORY_UNKNOWN_ERROR,
                    supported = null,
                    installedAndCurrent = null,
                    ready = false,
                )
        }
    }

    private fun hasActiveSession(): Boolean =
        synchronized(activeSessionLock) {
            activeSession != null
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

    private fun createEmptySummary(
        completionReason: String,
        preflight: Map<String, Any?>,
    ): Map<String, Any?> =
        createSummary(
            completionReason = completionReason,
            preflight = preflight,
            state = CollectedState(),
            sessionCreationSucceeded = false,
            sessionConfigurationSucceeded = false,
            sessionResumeSucceeded = false,
            glInitializationSucceeded = false,
            cameraTextureSetupSucceeded = false,
            terminalSessionError = false,
        )

    private inner class DiagnosticSession(
        private val callback: Callback,
        private val preflight: Map<String, Any?>,
    ) {
        private val completed = AtomicBoolean(false)
        private val cancellationRequested = AtomicBoolean(false)
        private val handlerThread = HandlerThread(HANDLER_THREAD_NAME)
        private val glEnvironment = DiagnosticGlEnvironment()
        private val collectedState = CollectedState()

        @Volatile
        private var cancellationMessage: String? = null

        private var workerHandler: Handler? = null
        private var arCoreSession: Session? = null
        private var sessionCreationSucceeded = false
        private var sessionConfigurationSucceeded = false
        private var sessionResumeSucceeded = false
        private var glInitializationSucceeded = false
        private var cameraTextureSetupSucceeded = false

        fun start() {
            try {
                handlerThread.start()
                val handler = Handler(handlerThread.looper)
                workerHandler = handler

                if (!handler.post(::runDiagnostic)) {
                    finish(
                        COMPLETION_PROVIDER_RUNTIME_ERROR,
                        terminalSessionError = true,
                    )
                }
            } catch (_: Exception) {
                finish(
                    COMPLETION_PROVIDER_RUNTIME_ERROR,
                    terminalSessionError = true,
                )
            }
        }

        fun cancel(message: String) {
            cancellationMessage = message
            cancellationRequested.set(true)
        }

        private fun runDiagnostic() {
            if (cancellationRequested.get()) {
                finish(COMPLETION_CANCELLED, terminalSessionError = false)
                return
            }

            val session =
                try {
                    Session(applicationContext).also {
                        arCoreSession = it
                        sessionCreationSucceeded = true
                    }
                } catch (_: Exception) {
                    finish(
                        COMPLETION_SESSION_CREATION_FAILED,
                        terminalSessionError = true,
                    )
                    return
                }

            try {
                val config =
                    Config(session).apply {
                        planeFindingMode = Config.PlaneFindingMode.DISABLED
                        lightEstimationMode =
                            Config.LightEstimationMode.DISABLED
                        focusMode = Config.FocusMode.AUTO
                        updateMode = Config.UpdateMode.BLOCKING
                        textureUpdateMode =
                            Config.TextureUpdateMode
                                .BIND_TO_TEXTURE_EXTERNAL_OES
                    }
                session.configure(config)
                sessionConfigurationSucceeded = true
            } catch (_: Exception) {
                finish(
                    COMPLETION_SESSION_CREATION_FAILED,
                    terminalSessionError = true,
                )
                return
            }

            try {
                glEnvironment.initialize()
                glInitializationSucceeded = true
            } catch (_: Exception) {
                finish(
                    COMPLETION_GL_INITIALIZATION_FAILED,
                    terminalSessionError = true,
                )
                return
            }

            try {
                val textureName = glEnvironment.createExternalOesTexture()
                session.setCameraTextureName(textureName)
                cameraTextureSetupSucceeded = true
            } catch (_: Exception) {
                finish(
                    COMPLETION_CAMERA_TEXTURE_SETUP_FAILED,
                    terminalSessionError = true,
                )
                return
            }

            try {
                session.resume()
                sessionResumeSucceeded = true
            } catch (_: CameraNotAvailableException) {
                finish(
                    COMPLETION_CAMERA_NOT_AVAILABLE,
                    terminalSessionError = true,
                )
                return
            } catch (_: Exception) {
                finish(
                    COMPLETION_SESSION_RESUME_FAILED,
                    terminalSessionError = true,
                )
                return
            }

            val acquisitionStartedNs = SystemClock.elapsedRealtimeNanos()

            while (!completed.get()) {
                if (cancellationRequested.get()) {
                    finish(COMPLETION_CANCELLED, terminalSessionError = false)
                    return
                }

                val frame =
                    try {
                        session.update()
                    } catch (_: CameraNotAvailableException) {
                        val reason =
                            if (cancellationRequested.get()) {
                                COMPLETION_CANCELLED
                            } else {
                                COMPLETION_CAMERA_NOT_AVAILABLE
                            }
                        finish(
                            reason,
                            terminalSessionError =
                                reason != COMPLETION_CANCELLED,
                        )
                        return
                    } catch (_: Exception) {
                        val reason =
                            if (cancellationRequested.get()) {
                                COMPLETION_CANCELLED
                            } else {
                                COMPLETION_PROVIDER_RUNTIME_ERROR
                            }
                        finish(
                            reason,
                            terminalSessionError =
                                reason != COMPLETION_CANCELLED,
                        )
                        return
                    }

                collectedState.sessionUpdateCallCount += 1
                val nowNs = SystemClock.elapsedRealtimeNanos()
                processFrame(frame.timestamp, frame.camera)

                val firstTrackingElapsedNs =
                    collectedState.firstTrackingObservationElapsedNs

                if (firstTrackingElapsedNs == null) {
                    if (
                        nowNs - acquisitionStartedNs >=
                            TRACKING_ACQUISITION_TIMEOUT_NS
                    ) {
                        finish(
                            COMPLETION_TRACKING_ACQUISITION_TIMEOUT,
                            terminalSessionError = false,
                        )
                        return
                    }
                } else if (
                    nowNs - firstTrackingElapsedNs >=
                    TRACKING_COLLECTION_DURATION_NS
                ) {
                    finish(
                        COMPLETION_MEASUREMENT_WINDOW_COMPLETED,
                        terminalSessionError = false,
                    )
                    return
                }
            }
        }

        private fun processFrame(
            timestampNs: Long,
            camera: com.google.ar.core.Camera,
        ) {
            if (timestampNs <= 0L) {
                return
            }

            val previousTimestampNs = collectedState.previousFrameTimestampNs

            if (previousTimestampNs == timestampNs) {
                collectedState.duplicateFrameTimestampCount += 1
                return
            }

            if (previousTimestampNs == null) {
                collectedState.firstFrameTimestampNs = timestampNs
            } else {
                val deltaNs = timestampNs - previousTimestampNs
                collectedState.frameDeltasNs.add(deltaNs)

                if (deltaNs <= 0L) {
                    collectedState.nonMonotonicTimestampCount += 1
                }
            }

            collectedState.previousFrameTimestampNs = timestampNs
            collectedState.lastFrameTimestampNs = timestampNs
            collectedState.uniqueFrameCount += 1

            val trackingState = camera.trackingState
            val previousTrackingState = collectedState.previousTrackingState

            if (
                previousTrackingState != null &&
                    previousTrackingState != trackingState
            ) {
                collectedState.trackingTransitionCount += 1
            }

            collectedState.previousTrackingState = trackingState

            val failureReason = camera.trackingFailureReason.name
            collectedState.trackingFailureReasonCounts[failureReason] =
                (collectedState.trackingFailureReasonCounts[failureReason] ?: 0L) +
                1L

            when (trackingState) {
                TrackingState.TRACKING -> {
                    collectedState.trackingFrameCount += 1

                    if (
                        collectedState.firstTrackingFrameTimestampNs == null
                    ) {
                        collectedState.firstTrackingFrameTimestampNs =
                            timestampNs
                        collectedState.firstTrackingObservationElapsedNs =
                            SystemClock.elapsedRealtimeNanos()
                    }

                    collectedState.lastTrackingFrameTimestampNs = timestampNs
                    processTrackingPose(camera.pose)
                }

                TrackingState.PAUSED -> {
                    collectedState.pausedFrameCount += 1
                }

                TrackingState.STOPPED -> {
                    collectedState.stoppedFrameCount += 1
                }
            }
        }

        private fun processTrackingPose(pose: com.google.ar.core.Pose) {
            val translation = FloatArray(3)
            pose.getTranslation(translation, 0)

            if (translation.any { !it.isFinite() }) {
                return
            }

            val sample =
                Translation(
                    x = translation[0].toDouble(),
                    y = translation[1].toDouble(),
                    z = translation[2].toDouble(),
                )
            val first = collectedState.firstTrackingTranslation

            if (first == null) {
                collectedState.firstTrackingTranslation = sample
                collectedState.maxDisplacementFromFirstTrackingPoseM = 0.0
            } else {
                val displacement = distance(first, sample)
                collectedState.maxDisplacementFromFirstTrackingPoseM =
                    maxOf(
                        collectedState.maxDisplacementFromFirstTrackingPoseM,
                        displacement,
                    )
            }

            collectedState.lastTrackingTranslation = sample
            collectedState.trackingPoseSampleCount += 1
        }

        private fun finish(
            completionReason: String,
            terminalSessionError: Boolean,
        ) {
            if (!completed.compareAndSet(false, true)) {
                return
            }

            cleanup()

            val summary =
                createSummary(
                    completionReason = completionReason,
                    preflight = preflight,
                    state = collectedState,
                    sessionCreationSucceeded = sessionCreationSucceeded,
                    sessionConfigurationSucceeded =
                        sessionConfigurationSucceeded,
                    sessionResumeSucceeded = sessionResumeSucceeded,
                    glInitializationSucceeded = glInitializationSucceeded,
                    cameraTextureSetupSucceeded =
                        cameraTextureSetupSucceeded,
                    terminalSessionError = terminalSessionError,
                ).toMutableMap()

            if (
                completionReason == COMPLETION_CANCELLED &&
                    cancellationMessage != null
            ) {
                summary["cancellationContext"] = "activity_lifecycle"
            }

            releaseSession(this)
            postSuccess(callback, summary)
        }

        private fun cleanup() {
            runCatching {
                workerHandler?.removeCallbacksAndMessages(null)
            }
            runCatching {
                if (sessionResumeSucceeded) {
                    arCoreSession?.pause()
                }
            }
            runCatching {
                arCoreSession?.close()
            }
            arCoreSession = null
            runCatching {
                glEnvironment.release()
            }
            runCatching {
                if (handlerThread.isAlive) {
                    handlerThread.quitSafely()
                }
            }
        }
    }

    private fun createSummary(
        completionReason: String,
        preflight: Map<String, Any?>,
        state: CollectedState,
        sessionCreationSucceeded: Boolean,
        sessionConfigurationSucceeded: Boolean,
        sessionResumeSucceeded: Boolean,
        glInitializationSucceeded: Boolean,
        cameraTextureSetupSucceeded: Boolean,
        terminalSessionError: Boolean,
    ): Map<String, Any?> {
        val sortedDeltasNs = state.frameDeltasNs.sorted()
        val deltaCount = sortedDeltasNs.size.toLong()
        val firstFrameTimestampNs = state.firstFrameTimestampNs
        val lastFrameTimestampNs = state.lastFrameTimestampNs
        val durationNs =
            if (
                firstFrameTimestampNs != null &&
                    lastFrameTimestampNs != null &&
                    state.uniqueFrameCount >= 2
            ) {
                lastFrameTimestampNs - firstFrameTimestampNs
            } else {
                null
            }
        val meanDeltaNs =
            if (sortedDeltasNs.isEmpty()) {
                null
            } else {
                sortedDeltasNs.sumOf { it.toDouble() } /
                    sortedDeltasNs.size.toDouble()
            }
        val medianDeltaNs = calculateMedian(sortedDeltasNs)
        val p95DeltaNs = calculateNearestRankP95(sortedDeltasNs)
        val sufficientUniqueFrames =
            state.uniqueFrameCount >= MINIMUM_UNIQUE_FRAME_COUNT &&
                deltaCount == state.uniqueFrameCount - 1L &&
                durationNs != null &&
                durationNs > 0L &&
                meanDeltaNs != null &&
                meanDeltaNs > 0.0 &&
                medianDeltaNs != null &&
                medianDeltaNs > 0.0
        val validTrackingSummary =
            completionReason == COMPLETION_MEASUREMENT_WINDOW_COMPLETED &&
                sessionCreationSucceeded &&
                sessionConfigurationSucceeded &&
                sessionResumeSucceeded &&
                glInitializationSucceeded &&
                cameraTextureSetupSucceeded &&
                state.trackingFrameCount > 0L &&
                state.trackingPoseSampleCount > 0L &&
                sufficientUniqueFrames &&
                state.nonMonotonicTimestampCount == 0L &&
                !terminalSessionError
        val meanUniqueFrameRateHz =
            if (sufficientUniqueFrames && durationNs != null) {
                (state.uniqueFrameCount - 1L).toDouble() *
                    NANOSECONDS_PER_SECOND / durationNs.toDouble()
            } else {
                null
            }
        val medianIntervalDerivedHz =
            if (sufficientUniqueFrames && medianDeltaNs != null) {
                NANOSECONDS_PER_SECOND / medianDeltaNs
            } else {
                null
            }
        val trackingFraction =
            if (state.uniqueFrameCount > 0L) {
                state.trackingFrameCount.toDouble() /
                    state.uniqueFrameCount.toDouble()
            } else {
                null
            }
        val firstTranslation = state.firstTrackingTranslation
        val lastTranslation = state.lastTrackingTranslation
        val netTranslationM =
            if (firstTranslation != null && lastTranslation != null) {
                distance(firstTranslation, lastTranslation)
            } else {
                null
            }

        return linkedMapOf(
            "schemaVersion" to SCHEMA_VERSION,
            "snapshotKind" to SNAPSHOT_KIND_TRACKING,
            "status" to STATUS_COMPLETED,
            "completionReason" to completionReason,
            "validTrackingSummary" to validTrackingSummary,
            "cameraPermissionGranted" to
                preflight["cameraPermissionGranted"],
            "availabilityRaw" to preflight["availabilityRaw"],
            "availabilityCategory" to preflight["availabilityCategory"],
            "arCoreSupported" to preflight["arCoreSupported"],
            "arCoreInstalledAndCurrent" to
                preflight["arCoreInstalledAndCurrent"],
            "sessionCreationSucceeded" to sessionCreationSucceeded,
            "sessionConfigurationSucceeded" to
                sessionConfigurationSucceeded,
            "sessionResumeSucceeded" to sessionResumeSucceeded,
            "glInitializationSucceeded" to glInitializationSucceeded,
            "cameraTextureSetupSucceeded" to
                cameraTextureSetupSucceeded,
            "trackingAcquisitionTimeoutMs" to
                TRACKING_ACQUISITION_TIMEOUT_MS,
            "trackingCollectionDurationTargetMs" to
                TRACKING_COLLECTION_DURATION_MS,
            "timestampSource" to TIMESTAMP_SOURCE,
            "timestampDomain" to TIMESTAMP_DOMAIN,
            "frameGapThresholdApplied" to false,
            "sessionUpdateCallCount" to state.sessionUpdateCallCount,
            "uniqueFrameCount" to state.uniqueFrameCount,
            "deltaCount" to deltaCount,
            "durationNs" to durationNs,
            "minDeltaNs" to sortedDeltasNs.firstOrNull(),
            "maxDeltaNs" to sortedDeltasNs.lastOrNull(),
            "meanDeltaNs" to meanDeltaNs,
            "medianDeltaNs" to medianDeltaNs,
            "p95DeltaNs" to p95DeltaNs,
            "meanUniqueFrameRateHz" to meanUniqueFrameRateHz,
            "medianIntervalDerivedHz" to medianIntervalDerivedHz,
            "nonMonotonicTimestampCount" to
                state.nonMonotonicTimestampCount,
            "duplicateFrameTimestampCount" to
                state.duplicateFrameTimestampCount,
            "trackingFrameCount" to state.trackingFrameCount,
            "pausedFrameCount" to state.pausedFrameCount,
            "stoppedFrameCount" to state.stoppedFrameCount,
            "firstTrackingFrameTimestampNs" to
                state.firstTrackingFrameTimestampNs,
            "lastTrackingFrameTimestampNs" to
                state.lastTrackingFrameTimestampNs,
            "trackingTransitionCount" to
                state.trackingTransitionCount,
            "trackingFraction" to trackingFraction,
            "trackingFailureReasonCounts" to
                state.trackingFailureReasonCounts.toSortedMap(),
            "trackingPoseSampleCount" to
                state.trackingPoseSampleCount,
            "firstTrackingPoseAvailable" to (firstTranslation != null),
            "lastTrackingPoseAvailable" to (lastTranslation != null),
            "netSessionRelativeTranslationM" to netTranslationM,
            "maxDisplacementFromFirstTrackingPoseM" to
                if (firstTranslation == null) {
                    null
                } else {
                    state.maxDisplacementFromFirstTrackingPoseM
                },
            "poseCoordinateFrame" to ARCORE_SESSION_COORDINATE_FRAME,
            "rawCameraFramesPersisted" to false,
            "rawPoseTrajectoryPersisted" to false,
            "terminalSessionError" to terminalSessionError,
        )
    }

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
            val contextAttributes =
                intArrayOf(
                    EGL14.EGL_CONTEXT_CLIENT_VERSION,
                    2,
                    EGL14.EGL_NONE,
                )

            context =
                EGL14.eglCreateContext(
                    display,
                    config,
                    EGL14.EGL_NO_CONTEXT,
                    contextAttributes,
                    0,
                )

            if (context == EGL14.EGL_NO_CONTEXT) {
                error("Unable to create the EGL context.")
            }

            val surfaceAttributes =
                intArrayOf(
                    EGL14.EGL_WIDTH,
                    1,
                    EGL14.EGL_HEIGHT,
                    1,
                    EGL14.EGL_NONE,
                )

            surface =
                EGL14.eglCreatePbufferSurface(
                    display,
                    config,
                    surfaceAttributes,
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
            check(contextCurrent) {
                "The EGL context must be current before texture creation."
            }

            val textures = IntArray(1)
            GLES20.glGenTextures(1, textures, 0)
            textureName = textures[0]

            if (textureName == 0) {
                error("OpenGL did not create a camera texture.")
            }

            GLES20.glBindTexture(
                GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
                textureName,
            )
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
                    GLES20.glDeleteTextures(
                        1,
                        intArrayOf(textureName),
                        0,
                    )
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

    private data class AvailabilitySnapshot(
        val raw: String,
        val category: String,
        val supported: Boolean?,
        val installedAndCurrent: Boolean?,
        val ready: Boolean,
    )

    private data class Translation(
        val x: Double,
        val y: Double,
        val z: Double,
    )

    private data class CollectedState(
        var sessionUpdateCallCount: Long = 0L,
        var uniqueFrameCount: Long = 0L,
        var firstFrameTimestampNs: Long? = null,
        var previousFrameTimestampNs: Long? = null,
        var lastFrameTimestampNs: Long? = null,
        val frameDeltasNs: MutableList<Long> = mutableListOf(),
        var nonMonotonicTimestampCount: Long = 0L,
        var duplicateFrameTimestampCount: Long = 0L,
        var trackingFrameCount: Long = 0L,
        var pausedFrameCount: Long = 0L,
        var stoppedFrameCount: Long = 0L,
        var firstTrackingFrameTimestampNs: Long? = null,
        var lastTrackingFrameTimestampNs: Long? = null,
        var trackingTransitionCount: Long = 0L,
        var previousTrackingState: TrackingState? = null,
        val trackingFailureReasonCounts: MutableMap<String, Long> =
            linkedMapOf(),
        var firstTrackingObservationElapsedNs: Long? = null,
        var trackingPoseSampleCount: Long = 0L,
        var firstTrackingTranslation: Translation? = null,
        var lastTrackingTranslation: Translation? = null,
        var maxDisplacementFromFirstTrackingPoseM: Double = 0.0,
    )

    private companion object {
        const val SCHEMA_VERSION = 1
        const val SNAPSHOT_KIND_PREFLIGHT = "arcore_diagnostic_preflight"
        const val SNAPSHOT_KIND_PERMISSION_RESULT =
            "arcore_camera_permission_result"
        const val SNAPSHOT_KIND_TRACKING =
            "arcore_runtime_tracking_diagnostic"
        const val STATUS_COMPLETED = "completed"

        const val TRACKING_ACQUISITION_TIMEOUT_MS = 30_000L
        const val TRACKING_COLLECTION_DURATION_MS = 30_000L
        const val NANOSECONDS_PER_MILLISECOND = 1_000_000L
        const val NANOSECONDS_PER_SECOND = 1_000_000_000.0
        const val TRACKING_ACQUISITION_TIMEOUT_NS =
            TRACKING_ACQUISITION_TIMEOUT_MS * NANOSECONDS_PER_MILLISECOND
        const val TRACKING_COLLECTION_DURATION_NS =
            TRACKING_COLLECTION_DURATION_MS * NANOSECONDS_PER_MILLISECOND
        const val MINIMUM_UNIQUE_FRAME_COUNT = 2L
        const val HANDLER_THREAD_NAME = "NAVGUARD-ArCoreTracking"

        const val TIMESTAMP_SOURCE = "Frame.timestamp"
        const val TIMESTAMP_DOMAIN = "arcore_frame_timebase_undefined"
        const val ARCORE_SESSION_COORDINATE_FRAME =
            "arcore_local_session_coordinates"

        const val AVAILABILITY_SUPPORTED_INSTALLED = "SUPPORTED_INSTALLED"
        const val AVAILABILITY_SUPPORTED_APK_TOO_OLD =
            "SUPPORTED_APK_TOO_OLD"
        const val AVAILABILITY_SUPPORTED_NOT_INSTALLED =
            "SUPPORTED_NOT_INSTALLED"
        const val AVAILABILITY_QUERY_ERROR = "AVAILABILITY_QUERY_ERROR"

        const val AVAILABILITY_CATEGORY_READY = "ready"
        const val AVAILABILITY_CATEGORY_INSTALL_OR_UPDATE_REQUIRED =
            "install_or_update_required"
        const val AVAILABILITY_CATEGORY_UNSUPPORTED = "unsupported"
        const val AVAILABILITY_CATEGORY_CHECKING = "checking"
        const val AVAILABILITY_CATEGORY_UNKNOWN_ERROR = "unknown_error"

        const val COMPLETION_MEASUREMENT_WINDOW_COMPLETED =
            "measurement_window_completed"
        const val COMPLETION_TRACKING_ACQUISITION_TIMEOUT =
            "tracking_acquisition_timeout"
        const val COMPLETION_CAMERA_PERMISSION_MISSING =
            "camera_permission_missing"
        const val COMPLETION_ARCORE_NOT_READY = "arcore_not_ready"
        const val COMPLETION_ARCORE_INSTALL_REQUESTED =
            "arcore_install_requested"
        const val COMPLETION_CAMERA_NOT_AVAILABLE =
            "camera_not_available"
        const val COMPLETION_SESSION_CREATION_FAILED =
            "session_creation_failed"
        const val COMPLETION_SESSION_RESUME_FAILED =
            "session_resume_failed"
        const val COMPLETION_GL_INITIALIZATION_FAILED =
            "gl_initialization_failed"
        const val COMPLETION_CAMERA_TEXTURE_SETUP_FAILED =
            "camera_texture_setup_failed"
        const val COMPLETION_PROVIDER_RUNTIME_ERROR =
            "provider_runtime_error"
        const val COMPLETION_CANCELLED = "cancelled"

        const val ERROR_ALREADY_RUNNING =
            "arcore_tracking_diagnostic_already_running"

        fun distance(first: Translation, second: Translation): Double {
            val dx = second.x - first.x
            val dy = second.y - first.y
            val dz = second.z - first.z
            return sqrt(dx * dx + dy * dy + dz * dz)
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

            val oneBasedRank = ceil(0.95 * sortedValues.size).toInt()
            val zeroBasedIndex =
                (oneBasedRank - 1).coerceIn(0, sortedValues.lastIndex)
            return sortedValues[zeroBasedIndex]
        }
    }
}
