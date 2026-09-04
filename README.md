# NAVGUARD

AI-Assisted GNSS-Denied Mobile Navigation & Sensor Fusion System.

NAVGUARD is an Android-based research and development project focused on pedestrian navigation continuity using smartphone sensors and on-device processing.

## Status

The technical documentation baseline and development-environment validation are complete. The Stage 1 Flutter Android bootstrap and Stage 2A SensorManager runtime capability inventory are implemented, tested, and physically verified on the Xiaomi Redmi Note 9 Pro. Stage 2B live `SensorEvent` timing diagnostics are also implemented and physically verified for the accelerometer, gyroscope, magnetometer, and rotation vector under the tested 20,000 µs (~50 Hz requested) configuration: all 12 sessions produced valid timing summaries and monotonic `SensorEvent.timestamp` sequences, with 0/12 sessions containing a gap above the provisional 60 ms threshold. Requested rate and timestamp-derived observed rate remain distinct; these results are scoped observations, not universal fixed sensor rates.

Overall physical verification remains partial and the device baseline is **NOT FROZEN**. GNSS runtime timing and ARCore runtime tracking remain pending. The production PDR acquisition pipeline, PDR, heading, Motion AI, Quality Engine, and EKF / Sensor Fusion are not implemented, and the final benchmark has not been run.

## Platform

* Android
* Xiaomi Redmi Note 9 Pro
* Flutter / Dart
* Kotlin
* Python

## Documentation

Project documentation is maintained under the `docs/` directory.
