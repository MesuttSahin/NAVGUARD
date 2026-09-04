# NAVGUARD

AI-Assisted GNSS-Denied Mobile Navigation & Sensor Fusion System.

NAVGUARD is an Android-based research and development project focused on pedestrian navigation continuity using smartphone sensors and on-device processing.

## Status

The technical documentation baseline and Stage 1 Flutter Android bootstrap are complete. Stage 2A SensorManager runtime capability inventory is implemented and physically verified on the Xiaomi Redmi Note 9 Pro. Stage 2B live `SensorEvent` timing diagnostics are implemented and physically verified for the tested accelerometer, gyroscope, magnetometer, and rotation-vector scope: all 12 sessions produced valid, monotonic timing summaries, with 0/12 sessions containing a gap above the provisional 60 ms sensor threshold.

Stage 2C GNSS runtime timing diagnostics are implemented, statically verified, final-audited, and physically verified for the tested diagnostic scope. Three of three formal `GPS_PROVIDER` sessions produced valid, monotonic `Location.elapsedRealtimeNanos` summaries with no mock locations. With a requested minimum interval of 1,000 ms, all three sessions had 1.000 s median and p95 intervals; the observed mean timestamp-derived rate range was approximately 0.983–1.000 Hz, and one 2.000 s consecutive callback interval occurred. Requested timing therefore remains distinct from delivered timing and does not guarantee fixed 1 Hz delivery.

Overall physical verification remains **PARTIAL** and the device baseline is **NOT FROZEN**. Stage 2C did not validate GNSS coordinate accuracy or implement a GNSS anchor, denial controller, or Ground Truth Firewall. ARCore runtime tracking remains pending; production sensor acquisition, PDR, heading, Motion AI, Quality Engine, EKF / Sensor Fusion, relocalization, and navigation benchmarking are not implemented or not verified as applicable.

## Platform

* Android
* Xiaomi Redmi Note 9 Pro
* Flutter / Dart
* Kotlin
* Python

## Documentation

Project documentation is maintained under the `docs/` directory.
