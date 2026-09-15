package io.github.mesuttsahin.navguard

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.hardware.SensorManager
import android.location.LocationManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var sensorTimingDiagnostic: SensorTimingDiagnostic? = null
    private var gnssTimingDiagnostic: GnssTimingDiagnostic? = null
    private var gnssAnchorAcquisition: GnssAnchorAcquisition? = null
    private var headingFoundationDiagnostic: HeadingFoundationDiagnostic? = null
    private var stepEventDiagnostic: StepEventDiagnostic? = null
    private var baselinePdrDiagnostic: BaselinePdrDiagnostic? = null
    private var arCoreTrackingDiagnostic: ArCoreTrackingDiagnostic? = null
    private var arCoreEnuDiagnostic: ArCoreEnuDiagnostic? = null
    private var evaluationModeDiagnostic: EvaluationModeDiagnostic? = null
    private var navguardFusionDiagnostic: NavguardFusionDiagnostic? = null
    private var fullNavguardFlowDiagnostic: FullNavguardFlowDiagnostic? = null
    private var navguardBenchmarkDiagnostic: NavguardBenchmarkDiagnostic? = null
    private var liveNavguardDemoController: LiveNavguardDemoController? = null
    private var locationManager: LocationManager? = null

    private val permissionResultLock = Any()
    private val standaloneOperationLock = Any()
    private var standaloneOperationRunning = false
    private var pendingGnssPermissionResult: MethodChannel.Result? = null
    private var pendingStepPermissionResult: MethodChannel.Result? = null
    private var pendingArCoreCameraPermissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val sensorManager =
            getSystemService(Context.SENSOR_SERVICE) as? SensorManager
        val availableLocationManager =
            getSystemService(Context.LOCATION_SERVICE) as? LocationManager

        locationManager = availableLocationManager

        sensorTimingDiagnostic =
            sensorManager?.let { availableSensorManager ->
                SensorTimingDiagnostic(availableSensorManager)
            }

        gnssTimingDiagnostic =
            availableLocationManager?.let { manager ->
                GnssTimingDiagnostic(manager)
            }

        gnssAnchorAcquisition =
            availableLocationManager?.let { manager ->
                GnssAnchorAcquisition(manager)
            }

        headingFoundationDiagnostic =
            sensorManager?.let { availableSensorManager ->
                HeadingFoundationDiagnostic(availableSensorManager)
            }

        stepEventDiagnostic =
            sensorManager?.let { availableSensorManager ->
                StepEventDiagnostic(
                    applicationContext = applicationContext,
                    sensorManager = availableSensorManager,
                )
            }

        baselinePdrDiagnostic =
            sensorManager?.let { availableSensorManager ->
                BaselinePdrDiagnostic(
                    applicationContext = applicationContext,
                    sensorManager = availableSensorManager,
                )
            }

        arCoreTrackingDiagnostic = ArCoreTrackingDiagnostic(applicationContext)
        arCoreEnuDiagnostic =
            sensorManager?.let { availableSensorManager ->
                ArCoreEnuDiagnostic(
                    applicationContext = applicationContext,
                    sensorManager = availableSensorManager,
                )
            }

        evaluationModeDiagnostic =
            if (sensorManager != null && availableLocationManager != null) {
                EvaluationModeDiagnostic(
                    applicationContext = applicationContext,
                    locationManager = availableLocationManager,
                    sensorManager = sensorManager,
                )
            } else {
                null
            }

        navguardFusionDiagnostic =
            sensorManager?.let { availableSensorManager ->
                NavguardFusionDiagnostic(
                    applicationContext = applicationContext,
                    sensorManager = availableSensorManager,
                )
            }

        fullNavguardFlowDiagnostic =
            if (sensorManager != null && availableLocationManager != null) {
                FullNavguardFlowDiagnostic(
                    applicationContext = applicationContext,
                    locationManager = availableLocationManager,
                    sensorManager = sensorManager,
                )
            } else {
                null
            }

        navguardBenchmarkDiagnostic =
            if (sensorManager != null && availableLocationManager != null) {
                NavguardBenchmarkDiagnostic(
                    applicationContext = applicationContext,
                    locationManager = availableLocationManager,
                    sensorManager = sensorManager,
                )
            } else {
                null
            }

        liveNavguardDemoController =
            if (sensorManager != null && availableLocationManager != null) {
                LiveNavguardDemoController(
                    applicationContext = applicationContext,
                    locationManager = availableLocationManager,
                    sensorManager = sensorManager,
                )
            } else {
                null
            }

        configureSensorChannel(flutterEngine, sensorManager)
        configureGnssChannel(flutterEngine)
        configureGnssAnchorChannel(flutterEngine)
        configureHeadingFoundationChannel(flutterEngine)
        configureStepEventChannel(flutterEngine)
        configureBaselinePdrChannel(flutterEngine)
        configureArCoreChannel(flutterEngine)
        configureArCoreEnuChannel(flutterEngine)
        configureEvaluationModeChannel(flutterEngine)
        configureNavguardFusionChannel(flutterEngine)
        configureFullNavguardFlowChannel(flutterEngine)
        configureNavguardBenchmarkChannel(flutterEngine)
        configureLiveNavguardDemoChannels(flutterEngine)
    }

    private fun configureSensorChannel(
        flutterEngine: FlutterEngine,
        sensorManager: SensorManager?,
    ) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SENSOR_CHANNEL_NAME,
        ).setMethodCallHandler { call, result ->
            if (call.method == METHOD_RUN_SENSOR_TIMING_DIAGNOSTIC && rejectIfLiveDemoRunning(result)) {
                return@setMethodCallHandler
            }
            when (call.method) {
                METHOD_GET_SENSOR_CAPABILITY_INVENTORY -> {
                    if (sensorManager == null) {
                        result.error(
                            ERROR_SENSOR_MANAGER_UNAVAILABLE,
                            "Android SensorManager service is unavailable.",
                            null,
                        )
                    } else {
                        try {
                            val snapshot =
                                SensorCapabilityInventory(
                                    sensorManager,
                                ).createSnapshot()

                            result.success(snapshot)
                        } catch (_: Exception) {
                            result.error(
                                ERROR_SENSOR_INVENTORY_FAILED,
                                "Unable to create the sensor capability inventory.",
                                null,
                            )
                        }
                    }
                }

                METHOD_RUN_SENSOR_TIMING_DIAGNOSTIC -> {
                    val diagnostic = sensorTimingDiagnostic

                    if (diagnostic == null) {
                        result.error(
                            ERROR_SENSOR_MANAGER_UNAVAILABLE,
                            "Android SensorManager service is unavailable.",
                            null,
                        )
                    } else {
                        val sensorKey =
                            (
                                call.arguments as? Map<*, *>
                            )?.get("sensorKey") as? String

                        if (!reserveStandaloneOperation(result)) {
                            return@setMethodCallHandler
                        }
                        diagnostic.start(
                            sensorKey = sensorKey,
                            callback =
                                object : SensorTimingDiagnostic.Callback {
                                    override fun onSuccess(
                                        summary: Map<String, Any?>,
                                    ) {
                                        releaseStandaloneOperation()
                                        result.success(summary)
                                    }

                                    override fun onError(
                                        code: String,
                                        message: String,
                                    ) {
                                        releaseStandaloneOperation()
                                        result.error(
                                            code,
                                            message,
                                            null,
                                        )
                                    }
                                },
                        )
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun configureGnssChannel(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            GNSS_CHANNEL_NAME,
        ).setMethodCallHandler { call, result ->
            if (call.method == METHOD_RUN_GNSS_TIMING_DIAGNOSTIC && rejectIfLiveDemoRunning(result)) {
                return@setMethodCallHandler
            }
            when (call.method) {
                METHOD_GET_GNSS_DIAGNOSTIC_PREFLIGHT -> {
                    val manager = locationManager

                    if (manager == null) {
                        result.error(
                            ERROR_LOCATION_MANAGER_UNAVAILABLE,
                            "Android LocationManager service is unavailable.",
                            null,
                        )
                    } else {
                        result.success(createGnssPreflightSnapshot(manager))
                    }
                }

                METHOD_REQUEST_GNSS_FOREGROUND_PERMISSION -> {
                    requestGnssForegroundPermission(result)
                }

                METHOD_RUN_GNSS_TIMING_DIAGNOSTIC -> {
                    runGnssTimingDiagnostic(result)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun configureGnssAnchorChannel(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            GNSS_ANCHOR_CHANNEL_NAME,
        ).setMethodCallHandler { call, result ->
            if (call.method == METHOD_ACQUIRE_GNSS_ANCHOR && rejectIfLiveDemoRunning(result)) {
                return@setMethodCallHandler
            }
            when (call.method) {
                METHOD_GET_GNSS_ANCHOR_PREFLIGHT -> {
                    val manager = locationManager

                    if (manager == null) {
                        result.error(
                            ERROR_LOCATION_MANAGER_UNAVAILABLE,
                            "Android LocationManager service is unavailable.",
                            null,
                        )
                    } else {
                        result.success(
                            createGnssAnchorPreflightSnapshot(manager),
                        )
                    }
                }

                METHOD_ACQUIRE_GNSS_ANCHOR -> {
                    acquireGnssAnchor(result)
                }

                METHOD_CANCEL_GNSS_ANCHOR_ACQUISITION -> {
                    val acquisition = gnssAnchorAcquisition

                    if (acquisition == null) {
                        result.error(
                            ERROR_LOCATION_MANAGER_UNAVAILABLE,
                            "GNSS anchor acquisition is unavailable.",
                            null,
                        )
                    } else {
                        val cancellationRequested =
                            acquisition.cancelActiveAcquisition()

                        result.success(
                            linkedMapOf(
                                "schemaVersion" to SCHEMA_VERSION,
                                "snapshotKind" to
                                    SNAPSHOT_KIND_GNSS_ANCHOR_CANCELLATION,
                                "cancellationRequested" to
                                    cancellationRequested,
                                "acquisitionRunning" to
                                    acquisition.isAcquisitionRunning(),
                            ),
                        )
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun configureHeadingFoundationChannel(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            HEADING_FOUNDATION_CHANNEL_NAME,
        ).setMethodCallHandler { call, result ->
            if (call.method == METHOD_RUN_HEADING_FOUNDATION_DIAGNOSTIC && rejectIfLiveDemoRunning(result)) {
                return@setMethodCallHandler
            }
            when (call.method) {
                METHOD_GET_HEADING_FOUNDATION_PREFLIGHT -> {
                    val diagnostic = headingFoundationDiagnostic

                    if (diagnostic == null) {
                        result.success(
                            linkedMapOf(
                                "schemaVersion" to SCHEMA_VERSION,
                                "snapshotKind" to
                                    SNAPSHOT_KIND_HEADING_FOUNDATION_PREFLIGHT,
                                "rotationVectorAvailable" to false,
                                "rotationVectorName" to null,
                                "requestedSamplingPeriodUs" to
                                    HEADING_REQUESTED_SAMPLING_PERIOD_US,
                                "diagnosticRunning" to false,
                            ),
                        )
                    } else {
                        result.success(diagnostic.createPreflightSnapshot())
                    }
                }

                METHOD_RUN_HEADING_FOUNDATION_DIAGNOSTIC -> {
                    runHeadingFoundationDiagnostic(call.arguments, result)
                }

                METHOD_CANCEL_HEADING_FOUNDATION_DIAGNOSTIC -> {
                    val diagnostic = headingFoundationDiagnostic
                    val cancellationRequested =
                        diagnostic?.cancelActiveSession() == true

                    result.success(
                        linkedMapOf(
                            "schemaVersion" to SCHEMA_VERSION,
                            "snapshotKind" to
                                SNAPSHOT_KIND_HEADING_FOUNDATION_CANCELLATION,
                            "cancellationRequested" to cancellationRequested,
                            "diagnosticRunning" to
                                (diagnostic?.isDiagnosticRunning() == true),
                        ),
                    )
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun runHeadingFoundationDiagnostic(
        rawArguments: Any?,
        result: MethodChannel.Result,
    ) {
        val diagnostic = headingFoundationDiagnostic

        if (diagnostic == null) {
            result.error(
                ERROR_ROTATION_VECTOR_UNAVAILABLE,
                "TYPE_ROTATION_VECTOR diagnostics are unavailable.",
                null,
            )
            return
        }

        val arguments = rawArguments as? Map<*, *>

        if (arguments == null) {
            result.error(
                ERROR_ANCHOR_REQUIRED,
                "A locked Stage 3A GNSS anchor is required.",
                null,
            )
            return
        }

        val latitudeDeg = (arguments["latitudeDeg"] as? Number)?.toDouble()
        val longitudeDeg = (arguments["longitudeDeg"] as? Number)?.toDouble()
        val rawAltitude = arguments["altitudeEllipsoidM"]
        val altitudeEllipsoidM = (rawAltitude as? Number)?.toDouble()

        if (
            latitudeDeg == null ||
                !latitudeDeg.isFinite() ||
                latitudeDeg !in -90.0..90.0 ||
                longitudeDeg == null ||
                !longitudeDeg.isFinite() ||
                longitudeDeg !in -180.0..180.0 ||
                (rawAltitude != null && altitudeEllipsoidM == null) ||
                altitudeEllipsoidM?.isFinite() == false
        ) {
            result.error(
                ERROR_INVALID_ANCHOR_ARGUMENT,
                "The locked GNSS anchor arguments are invalid.",
                null,
            )
            return
        }

        diagnostic.start(
            anchorLatitudeDeg = latitudeDeg,
            anchorLongitudeDeg = longitudeDeg,
            anchorAltitudeEllipsoidM = altitudeEllipsoidM,
            callback =
                object : HeadingFoundationDiagnostic.Callback {
                    override fun onSuccess(summary: Map<String, Any?>) {
                        result.success(summary)
                    }

                    override fun onError(code: String, message: String) {
                        result.error(code, message, null)
                    }
                },
        )
    }

    private fun configureStepEventChannel(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            STEP_EVENT_CHANNEL_NAME,
        ).setMethodCallHandler { call, result ->
            if (call.method == METHOD_RUN_STEP_EVENT_DIAGNOSTIC && rejectIfLiveDemoRunning(result)) {
                return@setMethodCallHandler
            }
            when (call.method) {
                METHOD_GET_STEP_EVENT_PREFLIGHT -> {
                    val diagnostic = stepEventDiagnostic

                    if (diagnostic == null) {
                        result.success(
                            createUnavailableStepEventPreflightSnapshot(),
                        )
                    } else {
                        result.success(diagnostic.createPreflightSnapshot())
                    }
                }

                METHOD_REQUEST_ACTIVITY_RECOGNITION_PERMISSION -> {
                    requestActivityRecognitionPermission(result)
                }

                METHOD_RUN_STEP_EVENT_DIAGNOSTIC -> {
                    runStepEventDiagnostic(result)
                }

                METHOD_CANCEL_STEP_EVENT_DIAGNOSTIC -> {
                    val diagnostic = stepEventDiagnostic
                    val cancellationRequested =
                        diagnostic?.cancelActiveSession() == true

                    result.success(
                        linkedMapOf(
                            "schemaVersion" to SCHEMA_VERSION,
                            "snapshotKind" to
                                SNAPSHOT_KIND_STEP_EVENT_CANCELLATION,
                            "cancellationRequested" to
                                cancellationRequested,
                            "diagnosticRunning" to
                                (diagnostic?.isDiagnosticRunning() == true),
                        ),
                    )
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun requestActivityRecognitionPermission(
        result: MethodChannel.Result,
    ) {
        val diagnostic = stepEventDiagnostic

        if (diagnostic == null) {
            result.error(
                ERROR_STEP_DETECTOR_UNAVAILABLE,
                "Step-event diagnostics are unavailable.",
                null,
            )
            return
        }

        val hasPendingRequest =
            synchronized(permissionResultLock) {
                pendingStepPermissionResult != null
            }

        if (hasPendingRequest) {
            result.error(
                ERROR_STEP_PERMISSION_REQUEST_ALREADY_RUNNING,
                "A physical activity permission request is already running.",
                null,
            )
            return
        }

        if (
            !isActivityRecognitionPermissionRequired() ||
                hasActivityRecognitionPermission()
        ) {
            result.success(diagnostic.createPreflightSnapshot())
            return
        }

        val reserved =
            synchronized(permissionResultLock) {
                if (pendingStepPermissionResult != null) {
                    false
                } else {
                    pendingStepPermissionResult = result
                    true
                }
            }

        if (!reserved) {
            result.error(
                ERROR_STEP_PERMISSION_REQUEST_ALREADY_RUNNING,
                "A physical activity permission request is already running.",
                null,
            )
            return
        }

        try {
            requestPermissions(
                arrayOf(Manifest.permission.ACTIVITY_RECOGNITION),
                STEP_ACTIVITY_PERMISSION_REQUEST_CODE,
            )
        } catch (_: Exception) {
            val pendingResult =
                clearPendingStepPermissionResult(result)

            pendingResult?.error(
                ERROR_STEP_PERMISSION_REQUEST_FAILED,
                "Unable to start the physical activity permission request.",
                null,
            )
        }
    }

    private fun runStepEventDiagnostic(result: MethodChannel.Result) {
        val diagnostic = stepEventDiagnostic

        if (diagnostic == null) {
            result.error(
                ERROR_STEP_DETECTOR_UNAVAILABLE,
                "Step-event diagnostics are unavailable.",
                null,
            )
            return
        }

        diagnostic.start(
            object : StepEventDiagnostic.Callback {
                override fun onSuccess(summary: Map<String, Any?>) {
                    result.success(summary)
                }

                override fun onError(code: String, message: String) {
                    result.error(code, message, null)
                }
            },
        )
    }

    private fun createUnavailableStepEventPreflightSnapshot():
        Map<String, Any?> {
        val permissionRequired =
            isActivityRecognitionPermissionRequired()

        return linkedMapOf(
            "schemaVersion" to SCHEMA_VERSION,
            "snapshotKind" to SNAPSHOT_KIND_STEP_EVENT_PREFLIGHT,
            "stepDetectorAvailable" to false,
            "stepDetectorName" to null,
            "activityRecognitionPermissionRequired" to
                permissionRequired,
            "activityRecognitionPermissionGranted" to
                hasActivityRecognitionPermission(),
            "diagnosticRunning" to false,
            "canRunStepDiagnostic" to false,
        )
    }

    private fun configureBaselinePdrChannel(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            BASELINE_PDR_CHANNEL_NAME,
        ).setMethodCallHandler { call, result ->
            if (call.method == METHOD_RUN_BASELINE_PDR_DIAGNOSTIC && rejectIfLiveDemoRunning(result)) {
                return@setMethodCallHandler
            }
            when (call.method) {
                METHOD_GET_BASELINE_PDR_PREFLIGHT -> {
                    val diagnostic = baselinePdrDiagnostic
                    result.success(
                        diagnostic?.createPreflightSnapshot()
                            ?: createUnavailableBaselinePdrPreflightSnapshot(),
                    )
                }

                METHOD_RUN_BASELINE_PDR_DIAGNOSTIC -> {
                    runBaselinePdrDiagnostic(call.arguments, result)
                }

                METHOD_CANCEL_BASELINE_PDR_DIAGNOSTIC -> {
                    val diagnostic = baselinePdrDiagnostic
                    val cancellationRequested =
                        diagnostic?.cancelActiveSession() == true

                    result.success(
                        linkedMapOf(
                            "schemaVersion" to SCHEMA_VERSION,
                            "snapshotKind" to
                                SNAPSHOT_KIND_BASELINE_PDR_CANCELLATION,
                            "cancellationRequested" to cancellationRequested,
                            "diagnosticRunning" to
                                (diagnostic?.isDiagnosticRunning() == true),
                        ),
                    )
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun runBaselinePdrDiagnostic(
        rawArguments: Any?,
        result: MethodChannel.Result,
    ) {
        val diagnostic = baselinePdrDiagnostic
        if (diagnostic == null) {
            result.error(
                ERROR_BASELINE_PDR_ROTATION_VECTOR_UNAVAILABLE,
                "Baseline PDR diagnostics are unavailable.",
                null,
            )
            return
        }

        val arguments = rawArguments as? Map<*, *>
        if (arguments == null) {
            result.error(
                ERROR_BASELINE_PDR_ANCHOR_REQUIRED,
                "A locked Stage 3A GNSS anchor is required.",
                null,
            )
            return
        }

        val latitudeDeg = (arguments["latitudeDeg"] as? Number)?.toDouble()
        val longitudeDeg = (arguments["longitudeDeg"] as? Number)?.toDouble()
        val rawAltitude = arguments["altitudeEllipsoidM"]
        val altitudeEllipsoidM = (rawAltitude as? Number)?.toDouble()

        if (
            latitudeDeg == null ||
                !latitudeDeg.isFinite() ||
                latitudeDeg !in -90.0..90.0 ||
                longitudeDeg == null ||
                !longitudeDeg.isFinite() ||
                longitudeDeg !in -180.0..180.0 ||
                (rawAltitude != null && altitudeEllipsoidM == null) ||
                altitudeEllipsoidM?.isFinite() == false
        ) {
            result.error(
                ERROR_BASELINE_PDR_ANCHOR_REQUIRED,
                "The locked Stage 3A GNSS anchor arguments are invalid.",
                null,
            )
            return
        }

        diagnostic.start(
            anchorLatitudeDeg = latitudeDeg,
            anchorLongitudeDeg = longitudeDeg,
            anchorAltitudeEllipsoidM = altitudeEllipsoidM,
            callback =
                object : BaselinePdrDiagnostic.Callback {
                    override fun onSuccess(summary: Map<String, Any?>) {
                        result.success(summary)
                    }

                    override fun onError(code: String, message: String) {
                        result.error(code, message, null)
                    }
                },
        )
    }

    private fun createUnavailableBaselinePdrPreflightSnapshot():
        Map<String, Any?> {
        val permissionRequired = isActivityRecognitionPermissionRequired()
        val permissionGranted = hasActivityRecognitionPermission()

        return linkedMapOf(
            "schemaVersion" to SCHEMA_VERSION,
            "snapshotKind" to SNAPSHOT_KIND_BASELINE_PDR_PREFLIGHT,
            "rotationVectorAvailable" to false,
            "rotationVectorName" to null,
            "stepDetectorAvailable" to false,
            "stepDetectorName" to null,
            "activityRecognitionPermissionRequired" to permissionRequired,
            "activityRecognitionPermissionGranted" to permissionGranted,
            "diagnosticRunning" to false,
            "nativeSensorsReady" to false,
        )
    }

    private fun configureArCoreChannel(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            ARCORE_CHANNEL_NAME,
        ).setMethodCallHandler { call, result ->
            if (call.method == METHOD_RUN_ARCORE_TRACKING_DIAGNOSTIC && rejectIfLiveDemoRunning(result)) {
                return@setMethodCallHandler
            }
            when (call.method) {
                METHOD_GET_ARCORE_DIAGNOSTIC_PREFLIGHT -> {
                    val diagnostic = arCoreTrackingDiagnostic

                    if (diagnostic == null) {
                        result.error(
                            ERROR_ARCORE_DIAGNOSTIC_UNAVAILABLE,
                            "ARCore diagnostics are unavailable.",
                            null,
                        )
                    } else {
                        result.success(diagnostic.createPreflightSnapshot())
                    }
                }

                METHOD_REQUEST_ARCORE_CAMERA_PERMISSION -> {
                    requestArCoreCameraPermission(result)
                }

                METHOD_RUN_ARCORE_TRACKING_DIAGNOSTIC -> {
                    runArCoreTrackingDiagnostic(result)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun requestArCoreCameraPermission(result: MethodChannel.Result) {
        val diagnostic = arCoreTrackingDiagnostic

        if (diagnostic == null) {
            result.error(
                ERROR_ARCORE_DIAGNOSTIC_UNAVAILABLE,
                "ARCore diagnostics are unavailable.",
                null,
            )
            return
        }

        val hasPendingRequest =
            synchronized(permissionResultLock) {
                pendingArCoreCameraPermissionResult != null
            }

        if (hasPendingRequest) {
            result.error(
                ERROR_ARCORE_CAMERA_PERMISSION_ALREADY_RUNNING,
                "An ARCore camera permission request is already running.",
                null,
            )
            return
        }

        if (hasCameraPermission()) {
            result.success(
                diagnostic.createCameraPermissionResultSnapshot(
                    ARCORE_PERMISSION_OUTCOME_ALREADY_GRANTED,
                ),
            )
            return
        }

        val reserved =
            synchronized(permissionResultLock) {
                if (pendingArCoreCameraPermissionResult != null) {
                    false
                } else {
                    pendingArCoreCameraPermissionResult = result
                    true
                }
            }

        if (!reserved) {
            result.error(
                ERROR_ARCORE_CAMERA_PERMISSION_ALREADY_RUNNING,
                "An ARCore camera permission request is already running.",
                null,
            )
            return
        }

        try {
            requestPermissions(
                arrayOf(Manifest.permission.CAMERA),
                ARCORE_CAMERA_PERMISSION_REQUEST_CODE,
            )
        } catch (_: Exception) {
            val pendingResult = clearPendingArCoreCameraPermissionResult(result)

            pendingResult?.error(
                ERROR_ARCORE_CAMERA_PERMISSION_REQUEST_FAILED,
                "Unable to start the ARCore camera permission request.",
                null,
            )
        }
    }

    private fun runArCoreTrackingDiagnostic(result: MethodChannel.Result) {
        val diagnostic = arCoreTrackingDiagnostic

        if (diagnostic == null) {
            result.error(
                ERROR_ARCORE_DIAGNOSTIC_UNAVAILABLE,
                "ARCore diagnostics are unavailable.",
                null,
            )
            return
        }

        diagnostic.start(
            activity = this,
            callback =
                object : ArCoreTrackingDiagnostic.Callback {
                    override fun onSuccess(summary: Map<String, Any?>) {
                        result.success(summary)
                    }

                    override fun onError(code: String, message: String) {
                        result.error(code, message, null)
                    }
                },
        )
    }

    private fun configureArCoreEnuChannel(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            ARCORE_ENU_CHANNEL_NAME,
        ).setMethodCallHandler { call, result ->
            if (call.method == METHOD_RUN_ARCORE_ENU_DIAGNOSTIC && rejectIfLiveDemoRunning(result)) {
                return@setMethodCallHandler
            }
            when (call.method) {
                METHOD_GET_ARCORE_ENU_PREFLIGHT -> {
                    result.success(
                        arCoreEnuDiagnostic?.createPreflightSnapshot()
                            ?: createUnavailableArCoreEnuPreflightSnapshot(),
                    )
                }

                METHOD_RUN_ARCORE_ENU_DIAGNOSTIC -> {
                    runArCoreEnuDiagnostic(call.arguments, result)
                }

                METHOD_CANCEL_ARCORE_ENU_DIAGNOSTIC -> {
                    val diagnostic = arCoreEnuDiagnostic
                    val cancellationRequested =
                        diagnostic?.cancelActiveSession() == true
                    result.success(
                        linkedMapOf(
                            "schemaVersion" to SCHEMA_VERSION,
                            "snapshotKind" to SNAPSHOT_KIND_ARCORE_ENU_CANCELLATION,
                            "cancellationRequested" to cancellationRequested,
                            "diagnosticRunning" to
                                (diagnostic?.isDiagnosticRunning() == true),
                        ),
                    )
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun runArCoreEnuDiagnostic(
        rawArguments: Any?,
        result: MethodChannel.Result,
    ) {
        val diagnostic = arCoreEnuDiagnostic
        if (diagnostic == null) {
            result.error(
                ERROR_ARCORE_ENU_UNAVAILABLE,
                "ARCore-to-ENU diagnostics are unavailable.",
                null,
            )
            return
        }

        val arguments = rawArguments as? Map<*, *>
        if (arguments == null) {
            result.error(
                ERROR_ARCORE_ENU_ANCHOR_REQUIRED,
                "A locked Stage 3A GNSS anchor is required.",
                null,
            )
            return
        }

        val latitudeDeg = (arguments["latitudeDeg"] as? Number)?.toDouble()
        val longitudeDeg = (arguments["longitudeDeg"] as? Number)?.toDouble()
        val rawAltitude = arguments["altitudeEllipsoidM"]
        val altitudeEllipsoidM = (rawAltitude as? Number)?.toDouble()
        if (
            latitudeDeg == null ||
                !latitudeDeg.isFinite() ||
                latitudeDeg !in -90.0..90.0 ||
                longitudeDeg == null ||
                !longitudeDeg.isFinite() ||
                longitudeDeg !in -180.0..180.0 ||
                (rawAltitude != null && altitudeEllipsoidM == null) ||
                altitudeEllipsoidM?.isFinite() == false
        ) {
            result.error(
                ERROR_ARCORE_ENU_ANCHOR_REQUIRED,
                "The locked Stage 3A GNSS anchor arguments are invalid.",
                null,
            )
            return
        }

        if (!reserveStandaloneOperation(result)) return
        diagnostic.start(
            anchorLatitudeDeg = latitudeDeg,
            anchorLongitudeDeg = longitudeDeg,
            anchorAltitudeEllipsoidM = altitudeEllipsoidM,
            callback =
                object : ArCoreEnuDiagnostic.Callback {
                    override fun onSuccess(summary: Map<String, Any?>) {
                        releaseStandaloneOperation()
                        result.success(summary)
                    }

                    override fun onError(code: String, message: String) {
                        releaseStandaloneOperation()
                        result.error(code, message, null)
                    }
                },
        )
    }

    private fun createUnavailableArCoreEnuPreflightSnapshot():
        Map<String, Any?> =
        linkedMapOf(
            "schemaVersion" to SCHEMA_VERSION,
            "snapshotKind" to SNAPSHOT_KIND_ARCORE_ENU_PREFLIGHT,
            "arCoreSupported" to false,
            "arCoreInstalled" to false,
            "cameraPermissionGranted" to hasCameraPermission(),
            "rotationVectorAvailable" to false,
            "rotationVectorName" to null,
            "diagnosticRunning" to false,
            "nativeReady" to false,
        )

    private fun configureEvaluationModeChannel(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVALUATION_MODE_CHANNEL_NAME,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_GET_EVALUATION_MODE_PREFLIGHT -> {
                    result.success(
                        evaluationModeDiagnostic?.createPreflightSnapshot()
                            ?: createUnavailableEvaluationModePreflightSnapshot(),
                    )
                }

                METHOD_RUN_EVALUATION_MODE_DIAGNOSTIC -> {
                    runEvaluationModeDiagnostic(call.arguments, result)
                }

                METHOD_CANCEL_EVALUATION_MODE_DIAGNOSTIC -> {
                    val diagnostic = evaluationModeDiagnostic
                    val cancellationRequested =
                        diagnostic?.cancelActiveSession() == true
                    result.success(
                        linkedMapOf(
                            "schemaVersion" to SCHEMA_VERSION,
                            "snapshotKind" to SNAPSHOT_KIND_EVALUATION_CANCELLATION,
                            "cancellationRequested" to cancellationRequested,
                            "diagnosticRunning" to
                                (diagnostic?.isDiagnosticRunning() == true),
                        ),
                    )
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun runEvaluationModeDiagnostic(
        rawArguments: Any?,
        result: MethodChannel.Result,
    ) {
        val diagnostic = evaluationModeDiagnostic
        if (diagnostic == null) {
            result.error(
                ERROR_EVALUATION_UNAVAILABLE,
                "Evaluation Mode diagnostics are unavailable.",
                null,
            )
            return
        }
        if (isAnotherEvaluationExclusiveOperationRunning()) {
            result.error(
                ERROR_EVALUATION_ALREADY_RUNNING,
                "Another mutually exclusive NAVGUARD operation is running.",
                null,
            )
            return
        }

        val arguments = rawArguments as? Map<*, *>
        val latitudeDeg = (arguments?.get("latitudeDeg") as? Number)?.toDouble()
        val longitudeDeg = (arguments?.get("longitudeDeg") as? Number)?.toDouble()
        val rawAltitude = arguments?.get("altitudeEllipsoidM")
        val altitudeEllipsoidM = (rawAltitude as? Number)?.toDouble()
        if (
            latitudeDeg == null ||
                !latitudeDeg.isFinite() ||
                latitudeDeg !in -90.0..90.0 ||
                longitudeDeg == null ||
                !longitudeDeg.isFinite() ||
                longitudeDeg !in -180.0..180.0 ||
                (rawAltitude != null && altitudeEllipsoidM == null) ||
                altitudeEllipsoidM?.isFinite() == false
        ) {
            result.error(
                ERROR_EVALUATION_ANCHOR_REQUIRED,
                "A valid locked Stage 3A GNSS anchor is required.",
                null,
            )
            return
        }

        diagnostic.start(
            anchorLatitudeDeg = latitudeDeg,
            anchorLongitudeDeg = longitudeDeg,
            anchorAltitudeEllipsoidM = altitudeEllipsoidM,
            callback =
                object : EvaluationModeDiagnostic.Callback {
                    override fun onSuccess(summary: Map<String, Any?>) {
                        result.success(summary)
                    }

                    override fun onError(code: String, message: String) {
                        result.error(code, message, null)
                    }
                },
        )
    }

    private fun isAnotherEvaluationExclusiveOperationRunning(): Boolean =
        isLegacyExclusiveOperationRunning() ||
            liveNavguardDemoController?.isDemoRunning() == true

    private fun isLegacyExclusiveOperationRunning(): Boolean =
        isStandaloneOperationRunning() ||
            gnssAnchorAcquisition?.isAcquisitionRunning() == true ||
            headingFoundationDiagnostic?.isDiagnosticRunning() == true ||
            stepEventDiagnostic?.isDiagnosticRunning() == true ||
            baselinePdrDiagnostic?.isDiagnosticRunning() == true ||
            arCoreEnuDiagnostic?.isDiagnosticRunning() == true ||
            evaluationModeDiagnostic?.isDiagnosticRunning() == true ||
            navguardFusionDiagnostic?.isDiagnosticRunning() == true ||
            fullNavguardFlowDiagnostic?.isDiagnosticRunning() == true ||
            navguardBenchmarkDiagnostic?.isDiagnosticRunning() == true

    private fun isStandaloneOperationRunning(): Boolean =
        synchronized(standaloneOperationLock) { standaloneOperationRunning }

    private fun reserveStandaloneOperation(result: MethodChannel.Result): Boolean =
        synchronized(standaloneOperationLock) {
            if (standaloneOperationRunning) {
                result.error(
                    ERROR_LIVE_NAVGUARD_DEMO_ALREADY_RUNNING,
                    "Another mutually exclusive runtime operation is running.",
                    null,
                )
                false
            } else {
                standaloneOperationRunning = true
                true
            }
        }

    private fun releaseStandaloneOperation() {
        synchronized(standaloneOperationLock) { standaloneOperationRunning = false }
    }

    private fun createUnavailableEvaluationModePreflightSnapshot():
        Map<String, Any?> {
        val activityPermissionRequired = isActivityRecognitionPermissionRequired()
        return linkedMapOf(
            "schemaVersion" to SCHEMA_VERSION,
            "snapshotKind" to SNAPSHOT_KIND_EVALUATION_PREFLIGHT,
            "gpsProviderAvailable" to false,
            "gpsProviderEnabled" to false,
            "fineLocationPermissionGranted" to hasFineLocationPermission(),
            "rotationVectorAvailable" to false,
            "rotationVectorName" to null,
            "stepDetectorAvailable" to false,
            "stepDetectorName" to null,
            "activityRecognitionPermissionRequired" to activityPermissionRequired,
            "activityRecognitionPermissionGranted" to
                hasActivityRecognitionPermission(),
            "firewallMutationSelfTestPassed" to false,
            "diagnosticRunning" to false,
            "nativeReady" to false,
        )
    }

    private fun configureNavguardFusionChannel(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            NAVGUARD_FUSION_CHANNEL_NAME,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_GET_NAVGUARD_FUSION_PREFLIGHT -> {
                    result.success(
                        navguardFusionDiagnostic?.createPreflightSnapshot()
                            ?: createUnavailableNavguardFusionPreflightSnapshot(),
                    )
                }

                METHOD_RUN_NAVGUARD_FUSION_DIAGNOSTIC -> {
                    runNavguardFusionDiagnostic(call.arguments, result)
                }

                METHOD_CANCEL_NAVGUARD_FUSION_DIAGNOSTIC -> {
                    val diagnostic = navguardFusionDiagnostic
                    val cancellationRequested =
                        diagnostic?.cancelActiveSession() == true
                    result.success(
                        linkedMapOf(
                            "schemaVersion" to SCHEMA_VERSION,
                            "snapshotKind" to SNAPSHOT_KIND_NAVGUARD_FUSION_CANCELLATION,
                            "cancellationRequested" to cancellationRequested,
                            "diagnosticRunning" to
                                (diagnostic?.isDiagnosticRunning() == true),
                        ),
                    )
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun runNavguardFusionDiagnostic(
        rawArguments: Any?,
        result: MethodChannel.Result,
    ) {
        val diagnostic = navguardFusionDiagnostic
        if (diagnostic == null) {
            result.error(
                ERROR_NAVGUARD_FUSION_UNAVAILABLE,
                "NAVGUARD fusion diagnostics are unavailable.",
                null,
            )
            return
        }
        if (isAnotherEvaluationExclusiveOperationRunning()) {
            result.error(
                ERROR_NAVGUARD_FUSION_ALREADY_RUNNING,
                "Another mutually exclusive NAVGUARD operation is running.",
                null,
            )
            return
        }

        val arguments = rawArguments as? Map<*, *>
        val latitudeDeg = (arguments?.get("latitudeDeg") as? Number)?.toDouble()
        val longitudeDeg = (arguments?.get("longitudeDeg") as? Number)?.toDouble()
        val rawAltitude = arguments?.get("altitudeEllipsoidM")
        val altitudeEllipsoidM = (rawAltitude as? Number)?.toDouble()
        if (
            latitudeDeg == null ||
                !latitudeDeg.isFinite() ||
                latitudeDeg !in -90.0..90.0 ||
                longitudeDeg == null ||
                !longitudeDeg.isFinite() ||
                longitudeDeg !in -180.0..180.0 ||
                (rawAltitude != null && altitudeEllipsoidM == null) ||
                altitudeEllipsoidM?.isFinite() == false
        ) {
            result.error(
                ERROR_NAVGUARD_FUSION_ANCHOR_REQUIRED,
                "A valid locked Stage 3A GNSS anchor is required.",
                null,
            )
            return
        }

        diagnostic.start(
            anchorLatitudeDeg = latitudeDeg,
            anchorLongitudeDeg = longitudeDeg,
            anchorAltitudeEllipsoidM = altitudeEllipsoidM,
            callback =
                object : NavguardFusionDiagnostic.Callback {
                    override fun onSuccess(summary: Map<String, Any?>) {
                        result.success(summary)
                    }

                    override fun onError(code: String, message: String) {
                        result.error(code, message, null)
                    }
                },
        )
    }

    private fun createUnavailableNavguardFusionPreflightSnapshot():
        Map<String, Any?> =
        linkedMapOf(
            "schemaVersion" to SCHEMA_VERSION,
            "snapshotKind" to SNAPSHOT_KIND_NAVGUARD_FUSION_PREFLIGHT,
            "arCoreSupported" to false,
            "arCoreInstalled" to false,
            "cameraPermissionGranted" to hasCameraPermission(),
            "rotationVectorAvailable" to false,
            "rotationVectorName" to null,
            "stepDetectorAvailable" to false,
            "stepDetectorName" to null,
            "activityRecognitionPermissionGranted" to
                hasActivityRecognitionPermission(),
            "diagnosticRunning" to false,
            "nativeReady" to false,
        )

    private fun configureFullNavguardFlowChannel(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            FULL_NAVGUARD_FLOW_CHANNEL_NAME,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_GET_FULL_NAVGUARD_FLOW_PREFLIGHT -> {
                    result.success(
                        fullNavguardFlowDiagnostic?.createPreflightSnapshot()
                            ?: createUnavailableFullNavguardFlowPreflightSnapshot(),
                    )
                }

                METHOD_RUN_FULL_NAVGUARD_FLOW_DIAGNOSTIC -> {
                    runFullNavguardFlowDiagnostic(call.arguments, result)
                }

                METHOD_CANCEL_FULL_NAVGUARD_FLOW_DIAGNOSTIC -> {
                    val diagnostic = fullNavguardFlowDiagnostic
                    val cancellationRequested = diagnostic?.cancelActiveSession() == true
                    result.success(
                        linkedMapOf(
                            "schemaVersion" to SCHEMA_VERSION,
                            "snapshotKind" to SNAPSHOT_KIND_FULL_NAVGUARD_FLOW_CANCELLATION,
                            "cancellationRequested" to cancellationRequested,
                            "diagnosticRunning" to (diagnostic?.isDiagnosticRunning() == true),
                        ),
                    )
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun runFullNavguardFlowDiagnostic(
        rawArguments: Any?,
        result: MethodChannel.Result,
    ) {
        val diagnostic = fullNavguardFlowDiagnostic
        if (diagnostic == null) {
            result.error(
                ERROR_FULL_NAVGUARD_FLOW_UNAVAILABLE,
                "Full NAVGUARD flow diagnostics are unavailable.",
                null,
            )
            return
        }
        if (isAnotherEvaluationExclusiveOperationRunning()) {
            result.error(
                ERROR_FULL_NAVGUARD_FLOW_ALREADY_RUNNING,
                "Another mutually exclusive NAVGUARD operation is running.",
                null,
            )
            return
        }

        val arguments = rawArguments as? Map<*, *>
        val latitudeDeg = (arguments?.get("latitudeDeg") as? Number)?.toDouble()
        val longitudeDeg = (arguments?.get("longitudeDeg") as? Number)?.toDouble()
        val rawAltitude = arguments?.get("altitudeEllipsoidM")
        val altitudeEllipsoidM = (rawAltitude as? Number)?.toDouble()
        if (
            latitudeDeg == null ||
                !latitudeDeg.isFinite() ||
                latitudeDeg !in -90.0..90.0 ||
                longitudeDeg == null ||
                !longitudeDeg.isFinite() ||
                longitudeDeg !in -180.0..180.0 ||
                (rawAltitude != null && altitudeEllipsoidM == null) ||
                altitudeEllipsoidM?.isFinite() == false
        ) {
            result.error(
                ERROR_FULL_NAVGUARD_FLOW_ANCHOR_REQUIRED,
                "A valid locked Stage 3A GNSS anchor is required.",
                null,
            )
            return
        }

        diagnostic.start(
            anchorLatitudeDeg = latitudeDeg,
            anchorLongitudeDeg = longitudeDeg,
            anchorAltitudeEllipsoidM = altitudeEllipsoidM,
            callback =
                object : FullNavguardFlowDiagnostic.Callback {
                    override fun onSuccess(summary: Map<String, Any?>) {
                        result.success(summary)
                    }

                    override fun onError(code: String, message: String) {
                        result.error(code, message, null)
                    }
                },
        )
    }

    private fun createUnavailableFullNavguardFlowPreflightSnapshot(): Map<String, Any?> =
        linkedMapOf(
            "schemaVersion" to SCHEMA_VERSION,
            "snapshotKind" to SNAPSHOT_KIND_FULL_NAVGUARD_FLOW_PREFLIGHT,
            "gpsProviderAvailable" to false,
            "gpsProviderEnabled" to false,
            "fineLocationPermissionGranted" to hasFineLocationPermission(),
            "rotationVectorAvailable" to false,
            "rotationVectorName" to null,
            "stepDetectorAvailable" to false,
            "stepDetectorName" to null,
            "activityRecognitionPermissionGranted" to hasActivityRecognitionPermission(),
            "arCoreSupported" to false,
            "arCoreInstalled" to false,
            "cameraPermissionGranted" to hasCameraPermission(),
            "diagnosticRunning" to false,
            "nativeReady" to false,
            "currentState" to "IDLE",
        )

    private fun configureNavguardBenchmarkChannel(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            NAVGUARD_BENCHMARK_CHANNEL_NAME,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_GET_NAVGUARD_BENCHMARK_PREFLIGHT -> {
                    result.success(
                        navguardBenchmarkDiagnostic?.createPreflightSnapshot()
                            ?: createUnavailableNavguardBenchmarkPreflightSnapshot(),
                    )
                }

                METHOD_RUN_NAVGUARD_BENCHMARK_DIAGNOSTIC -> {
                    runNavguardBenchmarkDiagnostic(call.arguments, result)
                }

                METHOD_CANCEL_NAVGUARD_BENCHMARK_DIAGNOSTIC -> {
                    val diagnostic = navguardBenchmarkDiagnostic
                    val cancellationRequested = diagnostic?.cancelActiveSession() == true
                    result.success(
                        linkedMapOf(
                            "schemaVersion" to SCHEMA_VERSION,
                            "snapshotKind" to SNAPSHOT_KIND_NAVGUARD_BENCHMARK_CANCELLATION,
                            "cancellationRequested" to cancellationRequested,
                            "diagnosticRunning" to (diagnostic?.isDiagnosticRunning() == true),
                        ),
                    )
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun runNavguardBenchmarkDiagnostic(
        rawArguments: Any?,
        result: MethodChannel.Result,
    ) {
        val diagnostic = navguardBenchmarkDiagnostic
        if (diagnostic == null) {
            result.error(
                ERROR_NAVGUARD_BENCHMARK_UNAVAILABLE,
                "NAVGUARD benchmark diagnostics are unavailable.",
                null,
            )
            return
        }
        if (isAnotherEvaluationExclusiveOperationRunning()) {
            result.error(
                ERROR_NAVGUARD_BENCHMARK_ALREADY_RUNNING,
                "Another mutually exclusive NAVGUARD operation is running.",
                null,
            )
            return
        }

        val arguments = rawArguments as? Map<*, *>
        val latitudeDeg = (arguments?.get("latitudeDeg") as? Number)?.toDouble()
        val longitudeDeg = (arguments?.get("longitudeDeg") as? Number)?.toDouble()
        val rawAltitude = arguments?.get("altitudeEllipsoidM")
        val altitudeEllipsoidM = (rawAltitude as? Number)?.toDouble()
        if (
            latitudeDeg == null ||
                !latitudeDeg.isFinite() ||
                latitudeDeg !in -90.0..90.0 ||
                longitudeDeg == null ||
                !longitudeDeg.isFinite() ||
                longitudeDeg !in -180.0..180.0 ||
                (rawAltitude != null && altitudeEllipsoidM == null) ||
                altitudeEllipsoidM?.isFinite() == false
        ) {
            result.error(
                ERROR_NAVGUARD_BENCHMARK_ANCHOR_REQUIRED,
                "A valid locked Stage 3A GNSS anchor is required.",
                null,
            )
            return
        }

        diagnostic.start(
            anchorLatitudeDeg = latitudeDeg,
            anchorLongitudeDeg = longitudeDeg,
            anchorAltitudeEllipsoidM = altitudeEllipsoidM,
            callback =
                object : NavguardBenchmarkDiagnostic.Callback {
                    override fun onSuccess(summary: Map<String, Any?>) {
                        result.success(summary)
                    }

                    override fun onError(code: String, message: String) {
                        result.error(code, message, null)
                    }
                },
        )
    }

    private fun createUnavailableNavguardBenchmarkPreflightSnapshot(): Map<String, Any?> =
        linkedMapOf(
            "schemaVersion" to SCHEMA_VERSION,
            "snapshotKind" to SNAPSHOT_KIND_NAVGUARD_BENCHMARK_PREFLIGHT,
            "gpsProviderAvailable" to false,
            "gpsProviderEnabled" to false,
            "fineLocationPermissionGranted" to hasFineLocationPermission(),
            "rotationVectorAvailable" to false,
            "rotationVectorName" to null,
            "stepDetectorAvailable" to false,
            "stepDetectorName" to null,
            "activityRecognitionPermissionGranted" to hasActivityRecognitionPermission(),
            "arCoreSupported" to false,
            "arCoreInstalled" to false,
            "cameraPermissionGranted" to hasCameraPermission(),
            "diagnosticRunning" to false,
            "nativeReady" to false,
            "currentPhase" to "IDLE",
        )

    private fun configureLiveNavguardDemoChannels(flutterEngine: FlutterEngine) {
        val controller = liveNavguardDemoController
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            LIVE_NAVGUARD_DEMO_EVENT_CHANNEL_NAME,
        ).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(
                    arguments: Any?,
                    events: EventChannel.EventSink?,
                ) {
                    controller?.setEventSink(events)
                }

                override fun onCancel(arguments: Any?) {
                    controller?.setEventSink(null)
                    controller?.stop(reason = "Live event stream closed.")
                }
            },
        )

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            LIVE_NAVGUARD_DEMO_METHOD_CHANNEL_NAME,
        ).setMethodCallHandler { call, result ->
            if (controller == null) {
                result.error(
                    ERROR_LIVE_NAVGUARD_DEMO_UNAVAILABLE,
                    "Live NAVGUARD demo services are unavailable.",
                    null,
                )
                return@setMethodCallHandler
            }
            when (call.method) {
                METHOD_GET_LIVE_NAVGUARD_DEMO_PREFLIGHT -> {
                    val anchor = parseLiveAnchor(call.arguments)
                    result.success(
                        controller.createPreflightSnapshot(anchorAvailable = anchor != null),
                    )
                }

                METHOD_START_LIVE_NAVGUARD_DEMO -> {
                    if (isLegacyExclusiveOperationRunning()) {
                        result.error(
                            ERROR_LIVE_NAVGUARD_DEMO_ALREADY_RUNNING,
                            "Another mutually exclusive NAVGUARD operation is running.",
                            null,
                        )
                        return@setMethodCallHandler
                    }
                    val anchor = parseLiveAnchor(call.arguments)
                    if (anchor == null) {
                        result.error(
                            ERROR_LIVE_NAVGUARD_DEMO_ANCHOR_REQUIRED,
                            "A valid locked Stage 3A GNSS anchor is required.",
                            null,
                        )
                        return@setMethodCallHandler
                    }
                    controller.start(
                        anchorLatitudeDeg = anchor.latitudeDeg,
                        anchorLongitudeDeg = anchor.longitudeDeg,
                        anchorAltitudeEllipsoidM = anchor.altitudeEllipsoidM,
                        callback = liveCommandCallback(result),
                    )
                }

                METHOD_BEGIN_LIVE_GNSS_DENIAL -> {
                    controller.beginDenial(liveCommandCallback(result))
                }

                METHOD_REQUEST_LIVE_GNSS_RECOVERY -> {
                    controller.requestRecovery(liveCommandCallback(result))
                }

                METHOD_STOP_LIVE_NAVGUARD_DEMO -> {
                    controller.stop(callback = liveCommandCallback(result))
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun rejectIfLiveDemoRunning(result: MethodChannel.Result): Boolean {
        if (liveNavguardDemoController?.isDemoRunning() != true) return false
        result.error(
            ERROR_LIVE_NAVGUARD_DEMO_ALREADY_RUNNING,
            "The live NAVGUARD demo is running; diagnostics are mutually exclusive.",
            null,
        )
        return true
    }

    private fun liveCommandCallback(result: MethodChannel.Result):
        LiveNavguardDemoController.CommandCallback =
        object : LiveNavguardDemoController.CommandCallback {
            override fun onSuccess(snapshot: Map<String, Any?>) {
                result.success(snapshot)
            }

            override fun onError(
                code: String,
                message: String,
            ) {
                result.error(code, message, null)
            }
        }

    private fun parseLiveAnchor(rawArguments: Any?): LiveAnchorArguments? {
        val arguments = rawArguments as? Map<*, *> ?: return null
        if (arguments["anchorAvailable"] != true) return null
        val latitudeDeg = (arguments["latitudeDeg"] as? Number)?.toDouble() ?: return null
        val longitudeDeg = (arguments["longitudeDeg"] as? Number)?.toDouble() ?: return null
        val rawAltitude = arguments["altitudeEllipsoidM"]
        val altitudeEllipsoidM = (rawAltitude as? Number)?.toDouble()
        if (
            !latitudeDeg.isFinite() || latitudeDeg !in -90.0..90.0 ||
                !longitudeDeg.isFinite() || longitudeDeg !in -180.0..180.0 ||
                (rawAltitude != null && altitudeEllipsoidM == null) ||
                altitudeEllipsoidM?.isFinite() == false
        ) return null
        return LiveAnchorArguments(latitudeDeg, longitudeDeg, altitudeEllipsoidM)
    }

    private fun requestGnssForegroundPermission(result: MethodChannel.Result) {
        val manager = locationManager

        if (manager == null) {
            result.error(
                ERROR_LOCATION_MANAGER_UNAVAILABLE,
                "Android LocationManager service is unavailable.",
                null,
            )
            return
        }

        val hasPendingRequest =
            synchronized(permissionResultLock) {
                pendingGnssPermissionResult != null
            }

        if (hasPendingRequest) {
            result.error(
                ERROR_PERMISSION_REQUEST_ALREADY_RUNNING,
                "A GNSS foreground permission request is already running.",
                null,
            )
            return
        }

        if (hasFineLocationPermission()) {
            result.success(
                createGnssPermissionResultSnapshot(
                    manager,
                    PERMISSION_OUTCOME_ALREADY_PRECISE_GRANTED,
                ),
            )
            return
        }

        val reserved =
            synchronized(permissionResultLock) {
                if (pendingGnssPermissionResult != null) {
                    false
                } else {
                    pendingGnssPermissionResult = result
                    true
                }
            }

        if (!reserved) {
            result.error(
                ERROR_PERMISSION_REQUEST_ALREADY_RUNNING,
                "A GNSS foreground permission request is already running.",
                null,
            )
            return
        }

        try {
            requestPermissions(
                arrayOf(
                    Manifest.permission.ACCESS_FINE_LOCATION,
                    Manifest.permission.ACCESS_COARSE_LOCATION,
                ),
                GNSS_PERMISSION_REQUEST_CODE,
            )
        } catch (_: Exception) {
            val pendingResult = clearPendingPermissionResult(result)

            pendingResult?.error(
                ERROR_PERMISSION_REQUEST_FAILED,
                "Unable to start the GNSS foreground permission request.",
                null,
            )
        }
    }

    private fun runGnssTimingDiagnostic(result: MethodChannel.Result) {
        val manager = locationManager

        if (manager == null) {
            result.error(
                ERROR_LOCATION_MANAGER_UNAVAILABLE,
                "Android LocationManager service is unavailable.",
                null,
            )
            return
        }

        val readiness = readGnssReadiness(manager)

        if (!readiness.fineLocationGranted) {
            result.error(
                ERROR_GNSS_PRECISE_PERMISSION_REQUIRED,
                "Precise foreground location permission is required for the formal GNSS diagnostic.",
                null,
            )
            return
        }

        if (!readiness.gpsProviderAvailable) {
            result.error(
                ERROR_GNSS_PROVIDER_UNAVAILABLE,
                "GPS_PROVIDER is unavailable on this device.",
                null,
            )
            return
        }

        if (!readiness.gpsProviderEnabled) {
            result.error(
                ERROR_GNSS_PROVIDER_DISABLED,
                "GPS_PROVIDER is disabled.",
                null,
            )
            return
        }

        val diagnostic = gnssTimingDiagnostic

        if (diagnostic == null) {
            result.error(
                ERROR_LOCATION_MANAGER_UNAVAILABLE,
                "GNSS timing diagnostics are unavailable.",
                null,
            )
            return
        }

        if (!reserveStandaloneOperation(result)) return
        diagnostic.start(
            object : GnssTimingDiagnostic.Callback {
                override fun onSuccess(summary: Map<String, Any?>) {
                    releaseStandaloneOperation()
                    result.success(summary)
                }

                override fun onError(code: String, message: String) {
                    releaseStandaloneOperation()
                    result.error(code, message, null)
                }
            },
        )
    }

    private fun acquireGnssAnchor(result: MethodChannel.Result) {
        val manager = locationManager
        val acquisition = gnssAnchorAcquisition

        if (manager == null || acquisition == null) {
            result.error(
                ERROR_LOCATION_MANAGER_UNAVAILABLE,
                "GNSS anchor acquisition is unavailable.",
                null,
            )
            return
        }

        val readiness = readGnssAnchorReadiness(manager)

        if (!readiness.fineLocationPermissionGranted) {
            result.error(
                ERROR_ANCHOR_FINE_LOCATION_PERMISSION_MISSING,
                "Precise foreground location permission is required.",
                null,
            )
            return
        }

        if (readiness.locationServicesEnabled == false) {
            result.error(
                ERROR_ANCHOR_LOCATION_SERVICES_DISABLED,
                "Android location services are disabled.",
                null,
            )
            return
        }

        if (readiness.gpsProviderAvailable == false) {
            result.error(
                ERROR_GNSS_PROVIDER_UNAVAILABLE,
                "GPS_PROVIDER is unavailable on this device.",
                null,
            )
            return
        }

        if (
            readiness.gpsProviderAvailable == null ||
                readiness.gpsProviderEnabled == null
        ) {
            result.error(
                ERROR_ANCHOR_LOCATION_MANAGER,
                "Unable to determine GPS provider readiness.",
                null,
            )
            return
        }

        if (!readiness.gpsProviderEnabled) {
            result.error(
                ERROR_ANCHOR_GPS_PROVIDER_DISABLED,
                "GPS_PROVIDER is disabled.",
                null,
            )
            return
        }

        acquisition.start(
            object : GnssAnchorAcquisition.Callback {
                override fun onSuccess(anchor: Map<String, Any?>) {
                    result.success(anchor)
                }

                override fun onError(code: String, message: String) {
                    result.error(code, message, null)
                }
            },
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(
            requestCode,
            permissions,
            grantResults,
        )

        when (requestCode) {
            GNSS_PERMISSION_REQUEST_CODE -> {
                val pendingResult = takePendingPermissionResult() ?: return
                val manager = locationManager

                if (manager == null) {
                    pendingResult.error(
                        ERROR_LOCATION_MANAGER_UNAVAILABLE,
                        "Android LocationManager service is unavailable.",
                        null,
                    )
                    return
                }

                val requestOutcome =
                    when {
                        hasFineLocationPermission() ->
                            PERMISSION_OUTCOME_PRECISE_GRANTED
                        hasCoarseLocationPermission() ->
                            PERMISSION_OUTCOME_APPROXIMATE_ONLY
                        else -> PERMISSION_OUTCOME_DENIED
                    }

                pendingResult.success(
                    createGnssPermissionResultSnapshot(
                        manager,
                        requestOutcome,
                    ),
                )
            }

            STEP_ACTIVITY_PERMISSION_REQUEST_CODE -> {
                val pendingResult =
                    takePendingStepPermissionResult() ?: return
                val diagnostic = stepEventDiagnostic

                if (diagnostic == null) {
                    pendingResult.error(
                        ERROR_STEP_DETECTOR_UNAVAILABLE,
                        "Step-event diagnostics are unavailable.",
                        null,
                    )
                    return
                }

                pendingResult.success(
                    diagnostic.createPreflightSnapshot(),
                )
            }

            ARCORE_CAMERA_PERMISSION_REQUEST_CODE -> {
                val pendingResult =
                    takePendingArCoreCameraPermissionResult() ?: return
                val diagnostic = arCoreTrackingDiagnostic

                if (diagnostic == null) {
                    pendingResult.error(
                        ERROR_ARCORE_DIAGNOSTIC_UNAVAILABLE,
                        "ARCore diagnostics are unavailable.",
                        null,
                    )
                    return
                }

                val requestOutcome =
                    if (hasCameraPermission()) {
                        ARCORE_PERMISSION_OUTCOME_GRANTED
                    } else {
                        ARCORE_PERMISSION_OUTCOME_DENIED
                    }

                pendingResult.success(
                    diagnostic.createCameraPermissionResultSnapshot(
                        requestOutcome,
                    ),
                )
            }
        }
    }

    override fun onPause() {
        sensorTimingDiagnostic?.cancelActiveSession(
            "Sensor timing diagnostic cancelled because the activity paused.",
        )
        gnssTimingDiagnostic?.cancelActiveSession(
            "GNSS timing diagnostic cancelled because the activity paused.",
        )
        gnssAnchorAcquisition?.cancelForActivityPause()
        headingFoundationDiagnostic?.cancelActiveSession(
            "Heading foundation diagnostic cancelled because the activity paused.",
        )
        stepEventDiagnostic?.cancelActiveSession(
            "Step-event diagnostic cancelled because the activity paused.",
        )
        baselinePdrDiagnostic?.cancelActiveSession(
            "Baseline PDR diagnostic cancelled because the activity paused.",
        )
        arCoreTrackingDiagnostic?.cancelActiveSession(
            "ARCore tracking diagnostic cancelled because the activity paused.",
        )
        arCoreEnuDiagnostic?.cancelActiveSession(
            "ARCore-to-ENU diagnostic cancelled because the activity paused.",
        )
        evaluationModeDiagnostic?.cancelActiveSession(
            "Evaluation Mode diagnostic cancelled because the activity paused.",
        )
        navguardFusionDiagnostic?.cancelActiveSession(
            "NAVGUARD fusion diagnostic cancelled because the activity paused.",
        )
        fullNavguardFlowDiagnostic?.cancelActiveSession(
            "Full NAVGUARD flow cancelled because the activity paused.",
        )
        navguardBenchmarkDiagnostic?.cancelActiveSession(
            "NAVGUARD benchmark cancelled because the activity paused.",
        )
        liveNavguardDemoController?.stop(
            reason = "Live NAVGUARD demo stopped because the activity paused.",
        )

        super.onPause()
    }

    override fun onDestroy() {
        sensorTimingDiagnostic?.cancelActiveSession(
            "Sensor timing diagnostic cancelled because the activity was destroyed.",
        )
        gnssTimingDiagnostic?.cancelActiveSession(
            "GNSS timing diagnostic cancelled because the activity was destroyed.",
        )
        gnssAnchorAcquisition?.cancelForActivityDestroy()
        headingFoundationDiagnostic?.cancelActiveSession(
            "Heading foundation diagnostic cancelled because the activity was destroyed.",
        )
        stepEventDiagnostic?.cancelActiveSession(
            "Step-event diagnostic cancelled because the activity was destroyed.",
        )
        baselinePdrDiagnostic?.cancelActiveSession(
            "Baseline PDR diagnostic cancelled because the activity was destroyed.",
        )
        arCoreTrackingDiagnostic?.cancelActiveSession(
            "ARCore tracking diagnostic cancelled because the activity was destroyed.",
        )
        arCoreEnuDiagnostic?.cancelActiveSession(
            "ARCore-to-ENU diagnostic cancelled because the activity was destroyed.",
        )
        evaluationModeDiagnostic?.cancelActiveSession(
            "Evaluation Mode diagnostic cancelled because the activity was destroyed.",
        )
        navguardFusionDiagnostic?.cancelActiveSession(
            "NAVGUARD fusion diagnostic cancelled because the activity was destroyed.",
        )
        fullNavguardFlowDiagnostic?.cancelActiveSession(
            "Full NAVGUARD flow cancelled because the activity was destroyed.",
        )
        navguardBenchmarkDiagnostic?.cancelActiveSession(
            "NAVGUARD benchmark cancelled because the activity was destroyed.",
        )
        liveNavguardDemoController?.stop(
            reason = "Live NAVGUARD demo stopped because the activity was destroyed.",
        )

        sensorTimingDiagnostic = null
        gnssTimingDiagnostic = null
        gnssAnchorAcquisition = null
        headingFoundationDiagnostic = null
        stepEventDiagnostic = null
        baselinePdrDiagnostic = null
        arCoreTrackingDiagnostic = null
        arCoreEnuDiagnostic = null
        evaluationModeDiagnostic = null
        navguardFusionDiagnostic = null
        fullNavguardFlowDiagnostic = null
        navguardBenchmarkDiagnostic = null
        liveNavguardDemoController = null
        locationManager = null

        takePendingPermissionResult()?.error(
            ERROR_PERMISSION_REQUEST_CANCELLED,
            "GNSS foreground permission request cancelled because the activity was destroyed.",
            null,
        )
        takePendingStepPermissionResult()?.error(
            ERROR_STEP_PERMISSION_REQUEST_CANCELLED,
            "Physical activity permission request cancelled because the activity was destroyed.",
            null,
        )
        takePendingArCoreCameraPermissionResult()?.error(
            ERROR_ARCORE_CAMERA_PERMISSION_REQUEST_CANCELLED,
            "ARCore camera permission request cancelled because the activity was destroyed.",
            null,
        )

        super.onDestroy()
    }

    private fun createGnssPreflightSnapshot(
        manager: LocationManager,
    ): Map<String, Any?> {
        val readiness = readGnssReadiness(manager)

        return linkedMapOf(
            "schemaVersion" to SCHEMA_VERSION,
            "snapshotKind" to SNAPSHOT_KIND_GNSS_PREFLIGHT,
            "foregroundOnly" to true,
            "coarseLocationGranted" to
                readiness.coarseLocationGranted,
            "fineLocationGranted" to readiness.fineLocationGranted,
            "preciseLocationGranted" to
                readiness.preciseLocationGranted,
            "permissionState" to readiness.permissionState,
            "gpsProviderAvailable" to readiness.gpsProviderAvailable,
            "gpsProviderEnabled" to readiness.gpsProviderEnabled,
            "locationServicesEnabled" to
                readiness.locationServicesEnabled,
            "canRunFormalDiagnostic" to
                readiness.canRunFormalDiagnostic,
        )
    }

    private fun createGnssPermissionResultSnapshot(
        manager: LocationManager,
        requestOutcome: String,
    ): Map<String, Any?> {
        val readiness = readGnssReadiness(manager)

        return linkedMapOf(
            "schemaVersion" to SCHEMA_VERSION,
            "snapshotKind" to SNAPSHOT_KIND_GNSS_PERMISSION_RESULT,
            "requestOutcome" to requestOutcome,
            "coarseLocationGranted" to
                readiness.coarseLocationGranted,
            "fineLocationGranted" to readiness.fineLocationGranted,
            "preciseLocationGranted" to
                readiness.preciseLocationGranted,
            "permissionState" to readiness.permissionState,
            "gpsProviderAvailable" to readiness.gpsProviderAvailable,
            "gpsProviderEnabled" to readiness.gpsProviderEnabled,
            "locationServicesEnabled" to
                readiness.locationServicesEnabled,
            "canRunFormalDiagnostic" to
                readiness.canRunFormalDiagnostic,
        )
    }

    private fun createGnssAnchorPreflightSnapshot(
        manager: LocationManager,
    ): Map<String, Any?> {
        val readiness = readGnssAnchorReadiness(manager)
        val acquisitionRunning =
            gnssAnchorAcquisition?.isAcquisitionRunning() == true

        return linkedMapOf(
            "schemaVersion" to SCHEMA_VERSION,
            "snapshotKind" to SNAPSHOT_KIND_GNSS_ANCHOR_PREFLIGHT,
            "foregroundOnly" to true,
            "provider" to "gps",
            "fineLocationPermissionGranted" to
                readiness.fineLocationPermissionGranted,
            "locationServicesEnabled" to
                readiness.locationServicesEnabled,
            "gpsProviderAvailable" to readiness.gpsProviderAvailable,
            "gpsProviderEnabled" to readiness.gpsProviderEnabled,
            "acquisitionRunning" to acquisitionRunning,
            "canAcquireAnchor" to
                (
                    readiness.fineLocationPermissionGranted &&
                        readiness.gpsProviderAvailable == true &&
                        readiness.gpsProviderEnabled == true &&
                        readiness.locationServicesEnabled != false &&
                        !acquisitionRunning
                ),
        )
    }

    private fun readGnssAnchorReadiness(
        manager: LocationManager,
    ): GnssAnchorReadiness {
        val gpsProviderAvailable: Boolean? =
            try {
                manager.allProviders.contains(LocationManager.GPS_PROVIDER)
            } catch (_: Exception) {
                null
            }

        val gpsProviderEnabled: Boolean? =
            when (gpsProviderAvailable) {
                true ->
                    try {
                        manager.isProviderEnabled(LocationManager.GPS_PROVIDER)
                    } catch (_: Exception) {
                        null
                    }
                false -> false
                null -> null
            }

        val locationServicesEnabled: Boolean? =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                try {
                    manager.isLocationEnabled
                } catch (_: Exception) {
                    null
                }
            } else {
                null
            }

        return GnssAnchorReadiness(
            fineLocationPermissionGranted = hasFineLocationPermission(),
            locationServicesEnabled = locationServicesEnabled,
            gpsProviderAvailable = gpsProviderAvailable,
            gpsProviderEnabled = gpsProviderEnabled,
        )
    }

    private fun readGnssReadiness(
        manager: LocationManager,
    ): GnssReadiness {
        val coarseLocationGranted = hasCoarseLocationPermission()
        val fineLocationGranted = hasFineLocationPermission()
        val gpsProviderAvailable =
            try {
                manager.allProviders.contains(LocationManager.GPS_PROVIDER)
            } catch (_: Exception) {
                false
            }
        val gpsProviderEnabled =
            if (gpsProviderAvailable) {
                try {
                    manager.isProviderEnabled(LocationManager.GPS_PROVIDER)
                } catch (_: Exception) {
                    false
                }
            } else {
                false
            }
        val locationServicesEnabled =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                try {
                    manager.isLocationEnabled
                } catch (_: Exception) {
                    null
                }
            } else {
                null
            }
        val permissionState =
            when {
                fineLocationGranted -> PERMISSION_STATE_PRECISE_GRANTED
                coarseLocationGranted -> PERMISSION_STATE_APPROXIMATE_ONLY
                else -> PERMISSION_STATE_NOT_GRANTED
            }

        return GnssReadiness(
            coarseLocationGranted = coarseLocationGranted,
            fineLocationGranted = fineLocationGranted,
            preciseLocationGranted = fineLocationGranted,
            permissionState = permissionState,
            gpsProviderAvailable = gpsProviderAvailable,
            gpsProviderEnabled = gpsProviderEnabled,
            locationServicesEnabled = locationServicesEnabled,
            canRunFormalDiagnostic =
                fineLocationGranted &&
                    gpsProviderAvailable &&
                    gpsProviderEnabled,
        )
    }

    private fun hasCoarseLocationPermission(): Boolean =
        checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION) ==
            PackageManager.PERMISSION_GRANTED

    private fun hasFineLocationPermission(): Boolean =
        checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) ==
            PackageManager.PERMISSION_GRANTED

    private fun hasCameraPermission(): Boolean =
        checkSelfPermission(Manifest.permission.CAMERA) ==
            PackageManager.PERMISSION_GRANTED

    private fun isActivityRecognitionPermissionRequired(): Boolean =
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q

    private fun hasActivityRecognitionPermission(): Boolean {
        if (!isActivityRecognitionPermissionRequired()) {
            return true
        }

        return checkSelfPermission(
            Manifest.permission.ACTIVITY_RECOGNITION,
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun takePendingPermissionResult(): MethodChannel.Result? =
        synchronized(permissionResultLock) {
            val result = pendingGnssPermissionResult
            pendingGnssPermissionResult = null
            result
        }

    private fun clearPendingPermissionResult(
        expectedResult: MethodChannel.Result,
    ): MethodChannel.Result? =
        synchronized(permissionResultLock) {
            if (pendingGnssPermissionResult === expectedResult) {
                pendingGnssPermissionResult = null
                expectedResult
            } else {
                null
            }
        }

    private fun takePendingStepPermissionResult(): MethodChannel.Result? =
        synchronized(permissionResultLock) {
            val result = pendingStepPermissionResult
            pendingStepPermissionResult = null
            result
        }

    private fun clearPendingStepPermissionResult(
        expectedResult: MethodChannel.Result,
    ): MethodChannel.Result? =
        synchronized(permissionResultLock) {
            if (pendingStepPermissionResult === expectedResult) {
                pendingStepPermissionResult = null
                expectedResult
            } else {
                null
            }
        }

    private fun takePendingArCoreCameraPermissionResult(): MethodChannel.Result? =
        synchronized(permissionResultLock) {
            val result = pendingArCoreCameraPermissionResult
            pendingArCoreCameraPermissionResult = null
            result
        }

    private fun clearPendingArCoreCameraPermissionResult(
        expectedResult: MethodChannel.Result,
    ): MethodChannel.Result? =
        synchronized(permissionResultLock) {
            if (pendingArCoreCameraPermissionResult === expectedResult) {
                pendingArCoreCameraPermissionResult = null
                expectedResult
            } else {
                null
            }
        }

    private data class GnssAnchorReadiness(
        val fineLocationPermissionGranted: Boolean,
        val locationServicesEnabled: Boolean?,
        val gpsProviderAvailable: Boolean?,
        val gpsProviderEnabled: Boolean?,
    )

    private data class GnssReadiness(
        val coarseLocationGranted: Boolean,
        val fineLocationGranted: Boolean,
        val preciseLocationGranted: Boolean,
        val permissionState: String,
        val gpsProviderAvailable: Boolean,
        val gpsProviderEnabled: Boolean,
        val locationServicesEnabled: Boolean?,
        val canRunFormalDiagnostic: Boolean,
    )

    private data class LiveAnchorArguments(
        val latitudeDeg: Double,
        val longitudeDeg: Double,
        val altitudeEllipsoidM: Double?,
    )

    private companion object {
        const val SCHEMA_VERSION = 1

        const val SENSOR_CHANNEL_NAME =
            "io.github.mesuttsahin.navguard/sensor_diagnostics"
        const val GNSS_CHANNEL_NAME =
            "io.github.mesuttsahin.navguard/gnss_diagnostics"
        const val GNSS_ANCHOR_CHANNEL_NAME =
            "io.github.mesuttsahin.navguard/gnss_anchor"
        const val HEADING_FOUNDATION_CHANNEL_NAME =
            "io.github.mesuttsahin.navguard/heading_foundation"
        const val STEP_EVENT_CHANNEL_NAME =
            "io.github.mesuttsahin.navguard/step_event"
        const val BASELINE_PDR_CHANNEL_NAME =
            "io.github.mesuttsahin.navguard/baseline_pdr"
        const val ARCORE_CHANNEL_NAME =
            "io.github.mesuttsahin.navguard/arcore_diagnostics"
        const val ARCORE_ENU_CHANNEL_NAME =
            "io.github.mesuttsahin.navguard/arcore_enu"
        const val EVALUATION_MODE_CHANNEL_NAME =
            "io.github.mesuttsahin.navguard/evaluation_mode"
        const val NAVGUARD_FUSION_CHANNEL_NAME =
            "io.github.mesuttsahin.navguard/navguard_fusion"
        const val FULL_NAVGUARD_FLOW_CHANNEL_NAME =
            "io.github.mesuttsahin.navguard/full_navguard_flow"
        const val NAVGUARD_BENCHMARK_CHANNEL_NAME =
            "io.github.mesuttsahin.navguard/navguard_benchmark"
        const val LIVE_NAVGUARD_DEMO_METHOD_CHANNEL_NAME =
            "io.github.mesuttsahin.navguard/live_navguard_demo"
        const val LIVE_NAVGUARD_DEMO_EVENT_CHANNEL_NAME =
            "io.github.mesuttsahin.navguard/live_navguard_demo/events"

        const val METHOD_GET_SENSOR_CAPABILITY_INVENTORY =
            "getSensorCapabilityInventory"
        const val METHOD_RUN_SENSOR_TIMING_DIAGNOSTIC =
            "runSensorTimingDiagnostic"

        const val METHOD_GET_GNSS_DIAGNOSTIC_PREFLIGHT =
            "getGnssDiagnosticPreflight"
        const val METHOD_REQUEST_GNSS_FOREGROUND_PERMISSION =
            "requestGnssForegroundPermission"
        const val METHOD_RUN_GNSS_TIMING_DIAGNOSTIC =
            "runGnssTimingDiagnostic"

        const val METHOD_GET_GNSS_ANCHOR_PREFLIGHT =
            "getGnssAnchorPreflight"
        const val METHOD_ACQUIRE_GNSS_ANCHOR =
            "acquireGnssAnchor"
        const val METHOD_CANCEL_GNSS_ANCHOR_ACQUISITION =
            "cancelGnssAnchorAcquisition"

        const val METHOD_GET_HEADING_FOUNDATION_PREFLIGHT =
            "getHeadingFoundationPreflight"
        const val METHOD_RUN_HEADING_FOUNDATION_DIAGNOSTIC =
            "runHeadingFoundationDiagnostic"
        const val METHOD_CANCEL_HEADING_FOUNDATION_DIAGNOSTIC =
            "cancelHeadingFoundationDiagnostic"

        const val METHOD_GET_STEP_EVENT_PREFLIGHT =
            "getStepEventPreflight"
        const val METHOD_REQUEST_ACTIVITY_RECOGNITION_PERMISSION =
            "requestActivityRecognitionPermission"
        const val METHOD_RUN_STEP_EVENT_DIAGNOSTIC =
            "runStepEventDiagnostic"
        const val METHOD_CANCEL_STEP_EVENT_DIAGNOSTIC =
            "cancelStepEventDiagnostic"

        const val METHOD_GET_BASELINE_PDR_PREFLIGHT =
            "getBaselinePdrPreflight"
        const val METHOD_RUN_BASELINE_PDR_DIAGNOSTIC =
            "runBaselinePdrDiagnostic"
        const val METHOD_CANCEL_BASELINE_PDR_DIAGNOSTIC =
            "cancelBaselinePdrDiagnostic"

        const val METHOD_GET_ARCORE_DIAGNOSTIC_PREFLIGHT =
            "getArCoreDiagnosticPreflight"
        const val METHOD_REQUEST_ARCORE_CAMERA_PERMISSION =
            "requestArCoreCameraPermission"
        const val METHOD_RUN_ARCORE_TRACKING_DIAGNOSTIC =
            "runArCoreTrackingDiagnostic"
        const val METHOD_GET_ARCORE_ENU_PREFLIGHT =
            "getArCoreEnuPreflight"
        const val METHOD_RUN_ARCORE_ENU_DIAGNOSTIC =
            "runArCoreEnuDiagnostic"
        const val METHOD_CANCEL_ARCORE_ENU_DIAGNOSTIC =
            "cancelArCoreEnuDiagnostic"
        const val METHOD_GET_EVALUATION_MODE_PREFLIGHT =
            "getEvaluationModePreflight"
        const val METHOD_RUN_EVALUATION_MODE_DIAGNOSTIC =
            "runEvaluationModeDiagnostic"
        const val METHOD_CANCEL_EVALUATION_MODE_DIAGNOSTIC =
            "cancelEvaluationModeDiagnostic"
        const val METHOD_GET_NAVGUARD_FUSION_PREFLIGHT =
            "getNavguardFusionPreflight"
        const val METHOD_RUN_NAVGUARD_FUSION_DIAGNOSTIC =
            "runNavguardFusionDiagnostic"
        const val METHOD_CANCEL_NAVGUARD_FUSION_DIAGNOSTIC =
            "cancelNavguardFusionDiagnostic"
        const val METHOD_GET_FULL_NAVGUARD_FLOW_PREFLIGHT =
            "getFullNavguardFlowPreflight"
        const val METHOD_RUN_FULL_NAVGUARD_FLOW_DIAGNOSTIC =
            "runFullNavguardFlowDiagnostic"
        const val METHOD_CANCEL_FULL_NAVGUARD_FLOW_DIAGNOSTIC =
            "cancelFullNavguardFlowDiagnostic"
        const val METHOD_GET_NAVGUARD_BENCHMARK_PREFLIGHT =
            "getNavguardBenchmarkPreflight"
        const val METHOD_RUN_NAVGUARD_BENCHMARK_DIAGNOSTIC =
            "runNavguardBenchmarkDiagnostic"
        const val METHOD_CANCEL_NAVGUARD_BENCHMARK_DIAGNOSTIC =
            "cancelNavguardBenchmarkDiagnostic"
        const val METHOD_GET_LIVE_NAVGUARD_DEMO_PREFLIGHT =
            "getLiveNavguardDemoPreflight"
        const val METHOD_START_LIVE_NAVGUARD_DEMO =
            "startLiveNavguardDemo"
        const val METHOD_BEGIN_LIVE_GNSS_DENIAL =
            "beginLiveGnssDenial"
        const val METHOD_REQUEST_LIVE_GNSS_RECOVERY =
            "requestLiveGnssRecovery"
        const val METHOD_STOP_LIVE_NAVGUARD_DEMO =
            "stopLiveNavguardDemo"

        const val SNAPSHOT_KIND_GNSS_PREFLIGHT =
            "gnss_diagnostic_preflight"
        const val SNAPSHOT_KIND_GNSS_PERMISSION_RESULT =
            "gnss_foreground_permission_result"
        const val SNAPSHOT_KIND_GNSS_ANCHOR_PREFLIGHT =
            "gnss_anchor_preflight"
        const val SNAPSHOT_KIND_GNSS_ANCHOR_CANCELLATION =
            "gnss_anchor_cancellation"
        const val SNAPSHOT_KIND_HEADING_FOUNDATION_PREFLIGHT =
            "heading_foundation_preflight"
        const val SNAPSHOT_KIND_HEADING_FOUNDATION_CANCELLATION =
            "heading_foundation_cancellation"
        const val SNAPSHOT_KIND_STEP_EVENT_PREFLIGHT =
            "step_event_preflight"
        const val SNAPSHOT_KIND_STEP_EVENT_CANCELLATION =
            "step_event_cancellation"
        const val SNAPSHOT_KIND_BASELINE_PDR_PREFLIGHT =
            "baseline_pdr_preflight"
        const val SNAPSHOT_KIND_BASELINE_PDR_CANCELLATION =
            "baseline_pdr_cancellation"
        const val SNAPSHOT_KIND_ARCORE_ENU_PREFLIGHT =
            "arcore_enu_preflight"
        const val SNAPSHOT_KIND_ARCORE_ENU_CANCELLATION =
            "arcore_enu_cancellation"
        const val SNAPSHOT_KIND_EVALUATION_PREFLIGHT =
            "evaluation_mode_preflight"
        const val SNAPSHOT_KIND_EVALUATION_CANCELLATION =
            "evaluation_mode_cancellation"
        const val SNAPSHOT_KIND_NAVGUARD_FUSION_PREFLIGHT =
            "navguard_fusion_preflight"
        const val SNAPSHOT_KIND_NAVGUARD_FUSION_CANCELLATION =
            "navguard_fusion_cancellation"
        const val SNAPSHOT_KIND_FULL_NAVGUARD_FLOW_PREFLIGHT =
            "full_navguard_flow_preflight"
        const val SNAPSHOT_KIND_FULL_NAVGUARD_FLOW_CANCELLATION =
            "full_navguard_flow_cancellation"
        const val SNAPSHOT_KIND_NAVGUARD_BENCHMARK_PREFLIGHT =
            "navguard_benchmark_preflight"
        const val SNAPSHOT_KIND_NAVGUARD_BENCHMARK_CANCELLATION =
            "navguard_benchmark_cancellation"

        const val HEADING_REQUESTED_SAMPLING_PERIOD_US = 20_000

        const val PERMISSION_STATE_PRECISE_GRANTED = "precise_granted"
        const val PERMISSION_STATE_APPROXIMATE_ONLY = "approximate_only"
        const val PERMISSION_STATE_NOT_GRANTED = "not_granted"

        const val PERMISSION_OUTCOME_ALREADY_PRECISE_GRANTED =
            "already_precise_granted"
        const val PERMISSION_OUTCOME_PRECISE_GRANTED = "precise_granted"
        const val PERMISSION_OUTCOME_APPROXIMATE_ONLY = "approximate_only"
        const val PERMISSION_OUTCOME_DENIED = "denied"

        const val GNSS_PERMISSION_REQUEST_CODE = 42_021
        const val ARCORE_CAMERA_PERMISSION_REQUEST_CODE = 42_022
        const val STEP_ACTIVITY_PERMISSION_REQUEST_CODE = 42_023

        const val ARCORE_PERMISSION_OUTCOME_ALREADY_GRANTED =
            "already_granted"
        const val ARCORE_PERMISSION_OUTCOME_GRANTED = "granted"
        const val ARCORE_PERMISSION_OUTCOME_DENIED = "denied"

        const val ERROR_SENSOR_MANAGER_UNAVAILABLE =
            "sensor_manager_unavailable"
        const val ERROR_SENSOR_INVENTORY_FAILED =
            "sensor_inventory_failed"
        const val ERROR_LOCATION_MANAGER_UNAVAILABLE =
            "location_manager_unavailable"
        const val ERROR_PERMISSION_REQUEST_ALREADY_RUNNING =
            "gnss_permission_request_already_running"
        const val ERROR_PERMISSION_REQUEST_FAILED =
            "gnss_permission_request_failed"
        const val ERROR_PERMISSION_REQUEST_CANCELLED =
            "gnss_permission_request_cancelled"
        const val ERROR_GNSS_PRECISE_PERMISSION_REQUIRED =
            "gnss_precise_permission_required"
        const val ERROR_GNSS_PROVIDER_UNAVAILABLE =
            "gnss_provider_unavailable"
        const val ERROR_GNSS_PROVIDER_DISABLED = "gnss_provider_disabled"
        const val ERROR_ANCHOR_FINE_LOCATION_PERMISSION_MISSING =
            "fine_location_permission_missing"
        const val ERROR_ANCHOR_LOCATION_SERVICES_DISABLED =
            "location_services_disabled"
        const val ERROR_ANCHOR_GPS_PROVIDER_DISABLED =
            "gps_provider_disabled"
        const val ERROR_ANCHOR_LOCATION_MANAGER =
            "location_manager_error"
        const val ERROR_ROTATION_VECTOR_UNAVAILABLE =
            "rotation_vector_unavailable"
        const val ERROR_ANCHOR_REQUIRED = "anchor_required"
        const val ERROR_INVALID_ANCHOR_ARGUMENT = "invalid_anchor_argument"
        const val ERROR_STEP_DETECTOR_UNAVAILABLE =
            "step_detector_unavailable"
        const val ERROR_STEP_PERMISSION_REQUEST_ALREADY_RUNNING =
            "activity_recognition_permission_request_already_running"
        const val ERROR_STEP_PERMISSION_REQUEST_FAILED =
            "activity_recognition_permission_request_failed"
        const val ERROR_STEP_PERMISSION_REQUEST_CANCELLED =
            "activity_recognition_permission_request_cancelled"
        const val ERROR_BASELINE_PDR_ROTATION_VECTOR_UNAVAILABLE =
            "baseline_pdr_rotation_vector_unavailable"
        const val ERROR_BASELINE_PDR_ANCHOR_REQUIRED =
            "baseline_pdr_anchor_required"
        const val ERROR_ARCORE_DIAGNOSTIC_UNAVAILABLE =
            "arcore_diagnostic_unavailable"
        const val ERROR_ARCORE_CAMERA_PERMISSION_ALREADY_RUNNING =
            "arcore_camera_permission_request_already_running"
        const val ERROR_ARCORE_CAMERA_PERMISSION_REQUEST_FAILED =
            "arcore_camera_permission_request_failed"
        const val ERROR_ARCORE_CAMERA_PERMISSION_REQUEST_CANCELLED =
            "arcore_camera_permission_request_cancelled"
        const val ERROR_ARCORE_ENU_UNAVAILABLE = "arcore_enu_unavailable"
        const val ERROR_ARCORE_ENU_ANCHOR_REQUIRED =
            "arcore_enu_anchor_required"
        const val ERROR_EVALUATION_UNAVAILABLE =
            "evaluation_gps_unavailable"
        const val ERROR_EVALUATION_ANCHOR_REQUIRED =
            "evaluation_anchor_required"
        const val ERROR_EVALUATION_ALREADY_RUNNING =
            "evaluation_already_running"
        const val ERROR_NAVGUARD_FUSION_UNAVAILABLE =
            "navguard_fusion_arcore_unavailable"
        const val ERROR_NAVGUARD_FUSION_ANCHOR_REQUIRED =
            "navguard_fusion_anchor_required"
        const val ERROR_NAVGUARD_FUSION_ALREADY_RUNNING =
            "navguard_fusion_already_running"
        const val ERROR_FULL_NAVGUARD_FLOW_UNAVAILABLE =
            "full_navguard_flow_gps_unavailable"
        const val ERROR_FULL_NAVGUARD_FLOW_ANCHOR_REQUIRED =
            "full_navguard_flow_anchor_required"
        const val ERROR_FULL_NAVGUARD_FLOW_ALREADY_RUNNING =
            "full_navguard_flow_already_running"
        const val ERROR_NAVGUARD_BENCHMARK_UNAVAILABLE =
            "navguard_benchmark_gps_unavailable"
        const val ERROR_NAVGUARD_BENCHMARK_ANCHOR_REQUIRED =
            "navguard_benchmark_anchor_required"
        const val ERROR_NAVGUARD_BENCHMARK_ALREADY_RUNNING =
            "navguard_benchmark_already_running"
        const val ERROR_LIVE_NAVGUARD_DEMO_UNAVAILABLE =
            "live_navguard_demo_unavailable"
        const val ERROR_LIVE_NAVGUARD_DEMO_ALREADY_RUNNING =
            "live_navguard_demo_already_running"
        const val ERROR_LIVE_NAVGUARD_DEMO_ANCHOR_REQUIRED =
            "live_navguard_demo_anchor_required"
    }
}
