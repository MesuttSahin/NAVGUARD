package io.github.mesuttsahin.navguard

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.hardware.SensorManager
import android.location.LocationManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var sensorTimingDiagnostic: SensorTimingDiagnostic? = null
    private var gnssTimingDiagnostic: GnssTimingDiagnostic? = null
    private var locationManager: LocationManager? = null

    private val permissionResultLock = Any()
    private var pendingGnssPermissionResult: MethodChannel.Result? = null

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

        configureSensorChannel(flutterEngine, sensorManager)
        configureGnssChannel(flutterEngine)
    }

    private fun configureSensorChannel(
        flutterEngine: FlutterEngine,
        sensorManager: SensorManager?,
    ) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SENSOR_CHANNEL_NAME,
        ).setMethodCallHandler { call, result ->
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

                        diagnostic.start(
                            sensorKey = sensorKey,
                            callback =
                                object : SensorTimingDiagnostic.Callback {
                                    override fun onSuccess(
                                        summary: Map<String, Any?>,
                                    ) {
                                        result.success(summary)
                                    }

                                    override fun onError(
                                        code: String,
                                        message: String,
                                    ) {
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

        diagnostic.start(
            object : GnssTimingDiagnostic.Callback {
                override fun onSuccess(summary: Map<String, Any?>) {
                    result.success(summary)
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

        if (requestCode != GNSS_PERMISSION_REQUEST_CODE) {
            return
        }

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

    override fun onPause() {
        sensorTimingDiagnostic?.cancelActiveSession(
            "Sensor timing diagnostic cancelled because the activity paused.",
        )
        gnssTimingDiagnostic?.cancelActiveSession(
            "GNSS timing diagnostic cancelled because the activity paused.",
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

        sensorTimingDiagnostic = null
        gnssTimingDiagnostic = null
        locationManager = null

        takePendingPermissionResult()?.error(
            ERROR_PERMISSION_REQUEST_CANCELLED,
            "GNSS foreground permission request cancelled because the activity was destroyed.",
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

    private companion object {
        const val SCHEMA_VERSION = 1

        const val SENSOR_CHANNEL_NAME =
            "io.github.mesuttsahin.navguard/sensor_diagnostics"
        const val GNSS_CHANNEL_NAME =
            "io.github.mesuttsahin.navguard/gnss_diagnostics"

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

        const val SNAPSHOT_KIND_GNSS_PREFLIGHT =
            "gnss_diagnostic_preflight"
        const val SNAPSHOT_KIND_GNSS_PERMISSION_RESULT =
            "gnss_foreground_permission_result"

        const val PERMISSION_STATE_PRECISE_GRANTED = "precise_granted"
        const val PERMISSION_STATE_APPROXIMATE_ONLY = "approximate_only"
        const val PERMISSION_STATE_NOT_GRANTED = "not_granted"

        const val PERMISSION_OUTCOME_ALREADY_PRECISE_GRANTED =
            "already_precise_granted"
        const val PERMISSION_OUTCOME_PRECISE_GRANTED = "precise_granted"
        const val PERMISSION_OUTCOME_APPROXIMATE_ONLY = "approximate_only"
        const val PERMISSION_OUTCOME_DENIED = "denied"

        const val GNSS_PERMISSION_REQUEST_CODE = 42_021

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
    }
}