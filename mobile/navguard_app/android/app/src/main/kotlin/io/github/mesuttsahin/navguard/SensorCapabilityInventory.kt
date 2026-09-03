package io.github.mesuttsahin.navguard

import android.hardware.Sensor
import android.hardware.SensorManager
import android.os.Build

internal class SensorCapabilityInventory(
    private val sensorManager: SensorManager,
) {
    fun createSnapshot(): Map<String, Any?> {
        val sensorRecords = requestedSensors().map { request ->
            createSensorRecord(request)
        }

        return linkedMapOf(
            "schemaVersion" to 1,
            "snapshotKind" to "sensor_capability_inventory",
            "capabilityMetadataOnly" to true,
            "sensors" to sensorRecords,
        )
    }

    private fun createSensorRecord(
        request: RequestedSensor,
    ): Map<String, Any?> {
        val platformApiSupported =
            Build.VERSION.SDK_INT >= request.minimumApiLevel

        val sensor = if (platformApiSupported) {
            sensorManager.getDefaultSensor(request.requestedTypeId)
        } else {
            null
        }

        return linkedMapOf(
            "requestedType" to request.requestedType,
            "requestedTypeId" to request.requestedTypeId,
            "platformApiSupported" to platformApiSupported,
            "available" to (sensor != null),
            "name" to sensor?.name,
            "vendor" to sensor?.vendor,
            "version" to sensor?.version,
            "type" to sensor?.type,
            "stringType" to sensor?.stringType,
            "maximumRange" to sensor?.maximumRange?.toDouble(),
            "resolution" to sensor?.resolution?.toDouble(),
            "power" to sensor?.power?.toDouble(),
            "minDelayUs" to sensor?.minDelay,
            "maxDelayUs" to sensor?.maxDelay,
            "fifoReservedEventCount" to sensor?.fifoReservedEventCount,
            "fifoMaxEventCount" to sensor?.fifoMaxEventCount,
            "reportingMode" to sensor?.reportingMode,
            "isWakeUpSensor" to sensor?.isWakeUpSensor,
        )
    }

    private fun requestedSensors(): List<RequestedSensor> {
        return listOf(
            RequestedSensor(
                requestedType = "TYPE_ACCELEROMETER",
                requestedTypeId = Sensor.TYPE_ACCELEROMETER,
            ),
            RequestedSensor(
                requestedType = "TYPE_ACCELEROMETER_UNCALIBRATED",
                requestedTypeId = TYPE_ACCELEROMETER_UNCALIBRATED_ID,
                minimumApiLevel = Build.VERSION_CODES.O,
            ),
            RequestedSensor(
                requestedType = "TYPE_GYROSCOPE",
                requestedTypeId = Sensor.TYPE_GYROSCOPE,
            ),
            RequestedSensor(
                requestedType = "TYPE_GYROSCOPE_UNCALIBRATED",
                requestedTypeId = Sensor.TYPE_GYROSCOPE_UNCALIBRATED,
            ),
            RequestedSensor(
                requestedType = "TYPE_MAGNETIC_FIELD",
                requestedTypeId = Sensor.TYPE_MAGNETIC_FIELD,
            ),
            RequestedSensor(
                requestedType = "TYPE_MAGNETIC_FIELD_UNCALIBRATED",
                requestedTypeId = Sensor.TYPE_MAGNETIC_FIELD_UNCALIBRATED,
            ),
            RequestedSensor(
                requestedType = "TYPE_ROTATION_VECTOR",
                requestedTypeId = Sensor.TYPE_ROTATION_VECTOR,
            ),
            RequestedSensor(
                requestedType = "TYPE_GAME_ROTATION_VECTOR",
                requestedTypeId = Sensor.TYPE_GAME_ROTATION_VECTOR,
            ),
            RequestedSensor(
                requestedType = "TYPE_GEOMAGNETIC_ROTATION_VECTOR",
                requestedTypeId = Sensor.TYPE_GEOMAGNETIC_ROTATION_VECTOR,
            ),
            RequestedSensor(
                requestedType = "TYPE_GRAVITY",
                requestedTypeId = Sensor.TYPE_GRAVITY,
            ),
            RequestedSensor(
                requestedType = "TYPE_LINEAR_ACCELERATION",
                requestedTypeId = Sensor.TYPE_LINEAR_ACCELERATION,
            ),
            RequestedSensor(
                requestedType = "TYPE_STEP_DETECTOR",
                requestedTypeId = Sensor.TYPE_STEP_DETECTOR,
            ),
            RequestedSensor(
                requestedType = "TYPE_STEP_COUNTER",
                requestedTypeId = Sensor.TYPE_STEP_COUNTER,
            ),
            RequestedSensor(
                requestedType = "TYPE_PRESSURE",
                requestedTypeId = Sensor.TYPE_PRESSURE,
            ),
        )
    }

    private data class RequestedSensor(
        val requestedType: String,
        val requestedTypeId: Int,
        val minimumApiLevel: Int = Build.VERSION_CODES.N,
    )

    private companion object {
        // Sensor.TYPE_ACCELEROMETER_UNCALIBRATED was added in API 26.
        // Keeping its stable framework ID here lets API 24/25 retain the
        // requested record without querying an unsupported sensor type.
        const val TYPE_ACCELEROMETER_UNCALIBRATED_ID = 35
    }
}