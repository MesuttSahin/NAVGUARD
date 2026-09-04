package io.github.mesuttsahin.navguard

import android.content.Context
import android.hardware.SensorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var sensorTimingDiagnostic: SensorTimingDiagnostic? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val sensorManager =
            getSystemService(Context.SENSOR_SERVICE) as? SensorManager

        sensorTimingDiagnostic =
            sensorManager?.let { availableSensorManager ->
                SensorTimingDiagnostic(availableSensorManager)
            }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME,
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

    override fun onPause() {
        sensorTimingDiagnostic?.cancelActiveSession(
            "Sensor timing diagnostic cancelled because the activity paused.",
        )

        super.onPause()
    }

    override fun onDestroy() {
        sensorTimingDiagnostic?.cancelActiveSession(
            "Sensor timing diagnostic cancelled because the activity was destroyed.",
        )

        sensorTimingDiagnostic = null

        super.onDestroy()
    }

    private companion object {
        const val CHANNEL_NAME =
            "io.github.mesuttsahin.navguard/sensor_diagnostics"

        const val METHOD_GET_SENSOR_CAPABILITY_INVENTORY =
            "getSensorCapabilityInventory"

        const val METHOD_RUN_SENSOR_TIMING_DIAGNOSTIC =
            "runSensorTimingDiagnostic"

        const val ERROR_SENSOR_MANAGER_UNAVAILABLE =
            "sensor_manager_unavailable"

        const val ERROR_SENSOR_INVENTORY_FAILED =
            "sensor_inventory_failed"
    }
}