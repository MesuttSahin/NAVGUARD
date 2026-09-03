package io.github.mesuttsahin.navguard

import android.content.Context
import android.hardware.SensorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_GET_SENSOR_CAPABILITY_INVENTORY -> {
                    try {
                        val sensorManager =
                            getSystemService(Context.SENSOR_SERVICE) as? SensorManager

                        if (sensorManager == null) {
                            result.error(
                                ERROR_SENSOR_MANAGER_UNAVAILABLE,
                                "Android SensorManager service is unavailable.",
                                null,
                            )
                        } else {
                            val snapshot =
                                SensorCapabilityInventory(sensorManager).createSnapshot()

                            result.success(snapshot)
                        }
                    } catch (exception: Exception) {
                        result.error(
                            ERROR_SENSOR_INVENTORY_FAILED,
                            "Unable to create the sensor capability inventory.",
                            null,
                        )
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    private companion object {
        const val CHANNEL_NAME =
            "io.github.mesuttsahin.navguard/sensor_diagnostics"

        const val METHOD_GET_SENSOR_CAPABILITY_INVENTORY =
            "getSensorCapabilityInventory"

        const val ERROR_SENSOR_MANAGER_UNAVAILABLE =
            "sensor_manager_unavailable"

        const val ERROR_SENSOR_INVENTORY_FAILED =
            "sensor_inventory_failed"
    }
}