# NAVGUARD — Project Status

## English Version

### Current State

**Project Phase:** Stage 6 — Evaluation Mode + Ground Truth Firewall Implemented, Statically Validated, and Physically Verified — Documentation Synchronization Complete; Commit-Readiness Audit Pending

**Repository Status:** Six Stage 6 Implementation/Test Paths and Four Documentation Paths Unstaged — Final Combined 10-Path Commit-Readiness Audit Pending

**Technical Documentation:** Baseline Completed

**Application Development:** Started — Bootstrap + SensorManager Capability Inventory + Four-Sensor Live Timing Diagnostics + GNSS Runtime Timing Diagnostics + ARCore Runtime Tracking Diagnostics + GNSS Anchor / WGS84 Local ENU Foundation + Handset Heading / True-North Correction Foundation + Step-Event Foundation + Deterministic Baseline PDR + ARCore Relative Motion → ENU Foundation + Evaluation Mode + Ground Truth Firewall

**Experimental Evaluation:** Partial — Device/runtime diagnostic characterization and Stage 3A–6 scoped flow verification only; navigation and metrological accuracy are not validated

---

### Current Milestone

Stage 6 implementation, post-fix 169/169-test static validation, scoped physical Evaluation Mode and Ground Truth Firewall verification, cancellation verification, and documentation synchronization are complete. Preparation for the final combined 10-path commit-readiness audit is in progress.
---

### Completed

* GitHub repository created.
* Initial repository directory structure created.
* Root `.gitignore` configured.
* Technical documentation baseline completed under `docs/`.
* Initial public `README.md` prepared.
* Development environment validated.
* Flutter Android bootstrap implemented and tested.
* Debug APK identity and minimum SDK verified.
* Bootstrap application installed, run, and interactively checked on the Xiaomi Redmi Note 9 Pro.
* Stage 2A native SensorManager runtime capability inventory implemented.
* Flutter–Kotlin MethodChannel physically verified.
* Fourteen deterministic requested sensor records returned on the tested Xiaomi Redmi Note 9 Pro.
* The verified Stage 2A runtime snapshot contained 13 available default sensor records and one unavailable record; the `TYPE_PRESSURE` default sensor was unavailable in that snapshot.
* Stage 2A analysis, tests, debug build, and physical-run verification passed.
* Stage 2B added a single native live timing diagnostic for the accelerometer, gyroscope, magnetometer, and rotation vector, using a dedicated `HandlerThread` and `SensorEvent.timestamp` as the timing authority.
* Stage 2B analysis, widget tests, diff-integrity checks, and physical timing verification passed for the tested four-sensor diagnostic scope.
* Three 10-second sessions per sensor produced 12/12 valid timing summaries and monotonic timestamp sequences; 0/12 sessions contained a gap above the provisional 60 ms threshold.
* Under the tested 20,000 µs (~50 Hz requested) configuration, timestamp-derived aggregate mean rates were observed at approximately 52.10 Hz for the accelerometer, 51.07 Hz for the gyroscope, 50.00 Hz for the magnetometer, and 51.10 Hz for the rotation vector. These are tested-device/session observations, not fixed hardware rates.
* Stage 2C implemented a foreground-only native GNSS timing diagnostic using `LocationManager`, `GPS_PROVIDER`, a dedicated `HandlerThread`, `LocationListener`, `GnssStatus.Callback`, and `Location.elapsedRealtimeNanos` as the timing authority.
* Stage 2C foreground precise-location permission flow and GNSS preflight were physically verified. The implementation added `ACCESS_COARSE_LOCATION` and `ACCESS_FINE_LOCATION`; it added no background-location permission, location foreground service, Flutter dependency, or Android dependency.
* Stage 2C formatting, analysis, widget tests, debug APK build, and diff-integrity checks passed, followed by a successful final source and physical audit.
* Three formal GNSS timing sessions completed normally with 3/3 valid summaries, 3/3 monotonic timestamp sequences, and 0/3 mock-location sessions. Median and p95 callback intervals were 1.000 s in all three sessions; observed mean timestamp-derived rates ranged from approximately 0.983 to 1.000 Hz.
* One 2.000 s consecutive GPS callback interval was observed in Session 3. No GNSS large-gap threshold is defined; the observation demonstrates that a requested 1,000 ms minimum interval does not guarantee fixed 1 Hz delivery.
* `GnssStatus.onFirstFix` metadata and sanitized satellite-count aggregates were observed. Android-reported horizontal-accuracy metadata was present for every recorded callback, but GNSS coordinate accuracy was not validated.
* Stage 2D implemented an AR-optional native ARCore runtime tracking diagnostic using `com.google.ar:core:1.54.0`, camera permission, and an optional `com.google.ar.core` manifest declaration.
* Stage 2D formatting, analysis, widget tests, debug APK build, diff-integrity checks, and the final source and physical audit passed.
* Three formal physical ARCore sessions completed with 3/3 valid summaries, 3/3 real `TrackingState.TRACKING` observations, 3/3 local-session pose availability, 3/3 monotonic `Frame.timestamp` sequences, 3/3 terminal-error-free results, and no `STOPPED` frames.
* ARCore session creation, configuration, resume, dedicated GL/EGL initialization, and camera-texture setup passed in 3/3 sessions. The observed unique-frame rate was approximately 30.0295–30.0304 Hz and the tracking fraction was approximately 98.15%–98.36% in the tested sessions.
* The three exercised scenarios were approximately stationary, approximately 120-degree handheld/camera rotation with pauses, and approximately 2–3 steps of rightward walking. They verified live local-session pose response, not rotation accuracy, distance accuracy, absolute accuracy, or a formal drift benchmark.
* Stage 3A implemented real foreground, pre-denial GNSS-anchor acquisition from Android `LocationManager.GPS_PROVIDER` only, with no background location, fused provider, or network provider.
* Formal candidate validation requires a non-mock GPS location, finite valid latitude/longitude, positive `Location.elapsedRealtimeNanos`, and finite positive reported horizontal accuracy. Altitude and vertical accuracy are optional.
* The first structurally valid fix has a 120-second timeout and establishes a 10-second monotonic GNSS measurement-time window. At least three valid candidates are required; selection uses the lowest reported horizontal accuracy with newer `Location.elapsedRealtimeNanos` as the tie-break. Handler timing controls operation termination only and does not define physical GNSS measurement time.
* Stage 3A added the WGS84 geodetic → ECEF → anchor-relative local ENU foundation. Full 3D ENU requires anchor and target ellipsoid altitudes; otherwise the same deterministic `h = 0` reference is used for both points and only horizontal E/N is returned, without a fabricated Up component.
* Stage 3A changed eight source/test paths. `flutter analyze`, all 32/32 tests, `flutter build apk --debug`, and `git diff --check` passed.
* Three independent physical anchor sessions completed successfully with candidate counts 10 / 11 / 10. The selected Android-reported horizontal-accuracy metadata was approximately 17.98 / 15.32 / 34.79 m. These values are not independently measured position errors and do not validate GNSS absolute coordinate accuracy.
* Explicit runtime clear/reacquire was verified through the sanitized `anchor_locked` → `no_anchor` state transition, and explicit cancellation returned `success = false` with `errorCategory = acquisition_cancelled` on the tested device.
* Raw anchor coordinates were not printed in the shared formal sanitized diagnostic logs and are not persisted by Stage 3A. A successful anchor remains immutable for its runtime reference session; replacement requires Clear Anchor followed by Acquire GNSS Anchor.
* Stage 3B implemented a deterministic handset-heading foundation using `Sensor.TYPE_ROTATION_VECTOR` as its only heading source. The physical top edge / device +Y axis is forward; heading is expressed in radians, clockwise from North, and normalized into `[0, 2π)`.
* Rotation-vector samples are converted with `SensorManager.getRotationMatrixFromVector(...)`; the device +Y direction is projected into horizontal East/North components and magnetic handset heading is calculated with `atan2(East, North)`. Circular signed deltas preserve continuity across the 0 / 2π boundary.
* True-north correction uses `android.hardware.GeomagneticField` with the current locked Stage 3A GNSS anchor as the only position source. Available anchor ellipsoid altitude is used; otherwise a deterministic 0 m fallback is explicitly identified as `deterministic_zero_fallback`, not as a measured altitude. The platform-managed geomagnetic model version/freshness is not independently validated.
* Stage 3B sensor measurement timing uses `SensorEvent.timestamp`; `System.currentTimeMillis` is used only as the geomagnetic-model time input and `wallClockUsedForSensorTiming = false`. The formal diagnostic has a 10-second first-valid-sample timeout and a 30-second sensor-timestamp measurement window.
* Stage 3B changed six source/test paths: three new and three modified. `flutter analyze`, all 61/61 tests, `flutter build apk --debug`, and `git diff --check` passed. No Flutter/Android dependency or manifest change was required.
* A fresh Stage 3A anchor was acquired before physical heading tests with 11 candidates, approximately 43.7262 m Android-reported horizontal-accuracy metadata, and altitude available. The value is metadata, not independently measured position error; raw coordinates were not included in the shared sanitized formal logs.
* Heading preflight found the real `TYPE_ROTATION_VECTOR` source available as `Rotation Vector Non-wakeup` under the 20,000 µs request. Three of three formal 30-second physical sessions succeeded on the Xiaomi Redmi Note 9 Pro running Android 12 / API 31.
* Across the three formal sessions, all timestamp sequences were monotonic, all duplicate-timestamp counts were zero, the observed delivery rate was approximately 51.137–51.138 Hz, and median delta was approximately 19.555 ms. This is observed delivery under a nominal 50 Hz request, not a guaranteed rate.
* The stationary session produced approximately -0.05827 rad cumulative true-heading change with approximately 0.00676 rad maximum consecutive circular delta. This is observational stability evidence, not heading-accuracy validation.
* The approximate manual clockwise-rotation session produced approximately +1.14196 rad (+65.4°) cumulative change, physically supporting the clockwise-positive convention without validating rotation scale or an independently measured angle.
* The wrap session accumulated approximately +10.56496 rad, exceeding 2π, while maximum consecutive circular delta remained approximately 0.07181 rad. This physically supports circular continuity across one or more 0 / 2π boundaries without claiming an exact physical rotation angle.
* The tested declination correction was approximately 0.112255 rad (6.43°), used `android.hardware.GeomagneticField`, and used `anchor_ellipsoid_altitude`. This verifies execution of the locked-anchor correction path, not true-north absolute accuracy. Rotation-vector reported heading-accuracy metadata was unavailable in all three sessions and remains optional metadata, not measured heading error.
* Explicit Stage 3B cancellation was physically verified with `errorCategory = heading_diagnostic_cancelled`. Anchor coordinates are used internally only for geomagnetic declination calculation and are not included in sanitized formal logs; raw rotation-vector streams are not returned or persisted.
* Stage 3C implemented the step-event foundation using `Sensor.TYPE_STEP_DETECTOR` as its primary and only formal step source. On Android 10 / API 29 and later, the runtime path requests `android.permission.ACTIVITY_RECOGNITION`; this permission was required on the tested Android 12 / API 31 device.
* Stage 3C step measurement timing uses `SensorEvent.timestamp`; `SystemClock.elapsedRealtimeNanos()` controls the formal operation window and wall clock is not a step-timing authority. The 30-second diagnostic returns aggregate counts, interval statistics, and observed cadence without returning raw timestamps or raw samples and without persistence. A zero-step session is a valid result.
* Stage 3C changed seven implementation paths: three new and four modified. `flutter analyze --no-pub`, all 97/97 tests, `flutter build apk --debug`, and `git diff --check` passed; unexpected implementation paths were absent and the staging area remained empty.
* The stationary physical session manually counted zero steps and accepted zero events, with no false event observed during that single 30-second session. This does not establish a global zero-false-positive result.
* The controlled 20-step walk delivered 21 updates: 16 accepted events and five events excluded by the formal session-window filter, with zero invalid, duplicate, or non-monotonic accepted events. This is a limited observation, not an 80% validated accuracy measurement, and the excluded events are not mapped one-for-one to manually counted steps.
* The controlled 30-step walk delivered and accepted 30 events, matching the manual count in that session, with zero out-of-window, invalid, duplicate, or non-monotonic events. This does not validate general step-detection accuracy.
* Across the two walking sessions, duplicate and non-monotonic accepted timestamp counts were zero. The observed cadence was approximately 91.28 steps/min for the accepted 20-step-session events and 93.65 steps/min for the 30-step session; these are session observations, not universal gait rates.
* Explicit Stage 3C cancellation was physically verified with `step_diagnostic_cancelled` and the Flutter message `Step-event diagnostic failed (step_diagnostic_cancelled).` Cancellation passed as an operation-control behavior and is not a successful measurement result.
* Stage 4 implemented deterministic horizontal local-ENU PDR using only `Sensor.TYPE_STEP_DETECTOR` and true-north-corrected `Sensor.TYPE_ROTATION_VECTOR` handset heading. The physical top edge / device +Y axis is forward; heading is clockwise from North in `[0, 2π)`.
* Every accepted step uses the latest valid heading whose `SensorEvent.timestamp` is at or before the step timestamp (`latest_valid_heading_at_or_before_step_timestamp`). Future headings and interpolation are prohibited. `SystemClock.elapsedRealtimeNanos()` controls the 30-second operation window but is not the heading-step association authority.
* Each associated step uses the fixed research-baseline assumption `L = 0.75 m`, with `ΔE = L × sin(ψ)` and `ΔN = L × cos(ψ)`, from local origin `E = 0, N = 0`. The step length is neither calibrated nor validated.
* The locked Stage 3A anchor is used only to obtain `android.hardware.GeomagneticField` declination. The model is `platform_managed`, freshness is not validated, and live GNSS is not used during Stage 4 integration.
* Stage 4 changed exactly six implementation/test paths. `flutter analyze --no-pub`, all 118/118 tests, `flutter build apk --debug`, and `git diff --check` passed; no manifest or dependency change was required.
* A stationary 30-second session accepted and integrated zero steps, with 1,527/1,527 valid heading samples and zero final displacement. This single observation does not establish universal zero false positives.
* Two manually counted 20-step straight walks each accepted, associated, and integrated 20 steps with no unassociated step. Their final local-ENU results were approximately `(-14.601, 2.639) m` and `(3.715, 14.458) m`; association ages remained within approximately 0.34–19.47 ms. The first walk's assumed geographic direction was later found to have been physically selected incorrectly, so its absolute E/N direction is not evidence of a heading defect.
* An intended 10 + turn + 10 L-shaped walk accepted, associated, and integrated 22 events, ending at approximately `(-6.621, 11.423) m` with 13.203 m net displacement and 16.5 m nominal path length. The two-event difference is recorded without assigning a proven cause or claiming step-detection accuracy.
* A targeted independent north check after correcting the physical orientation produced first/last true-north-corrected headings of approximately 0.1036/0.1242 rad with 1,535 valid samples, resolving the earlier direction concern without validating heading or true-north absolute accuracy.
* Explicit Stage 4 cancellation returned `baseline_pdr_cancelled`. No raw trajectory, sensor samples, sensor timestamps, anchor coordinates, or live GNSS data is returned or persisted by the Stage 4 result.
* Stage 5 implemented segment-relative local ENU displacement from ARCore `Frame.getAndroidSensorPose()` using the Android sensor frame: +X physical device right, +Y physical top edge, and +Z outward from the screen. Display-rotation remapping and camera optical forward are not used.
* After a 2-second stationary-assumed alignment with a 15-second acquisition timeout, Stage 5 creates a local ARCore anchor at the initial Android sensor pose. Formal relative pose is `anchor.pose.inverse().compose(currentAndroidSensorPose)`, and the 30-second movement window is controlled by `SystemClock.elapsedRealtimeNanos()`.
* Initial device-to-true-ENU alignment uses `TYPE_ROTATION_VECTOR` plus locked-anchor `android.hardware.GeomagneticField` declination. The locked Stage 3A anchor is used only for declination; no live GNSS, travel bearing, Geospatial API, cloud anchor, or fallback motion estimator is used.
* Rotation-vector timing uses `SensorEvent.timestamp`; ARCore ordering and aggregate frame timing use `Frame.getTimestamp()`. ARCore defines no shared timestamp epoch with sensor events, so `crossClockTimestampComparisonUsed = false` and no cross-clock latency is calculated.
* Stage 5 changed exactly six implementation/test paths. `flutter analyze --no-pub`, all 141/141 tests, `flutter build apk --debug`, and `git diff --check` passed; no manifest or dependency change was required.
* The stationary formal session ended approximately 0.081 m horizontally from the origin with approximately 0.100 m maximum horizontal excursion. The north-like walk ended near `(E, N) = (1.507, 8.223) m`; the east-like walk ended near `(9.129, -1.176) m` with one duplicate and zero non-monotonic AR frame timestamps.
* The approximate 90-degree in-place rotation ended at approximately 0.503 m horizontal displacement, substantially below the approximately 8–9 m straight-walk results. This is a qualitative axis/translation observation, not a validated error threshold. Explicit cancellation returned `arcore_enu_cancelled`.
* Completed Stage 5 formal measurement sessions reported `trackingFraction = 1.0` and no `PAUSED` or `STOPPED` frames. No universal tracking guarantee or tracking-loss recovery validation follows. Raw ARCore poses, trajectories, rotation-vector samples, timestamps, camera images, and anchor coordinates are not returned or persisted.
* Stage 6 implemented Evaluation Mode with physical GNSS isolated as `protected_ground_truth_only` and Config A operating under software-defined estimator GNSS denial. The denied estimator API receives step and heading data only; protected GNSS does not enter estimator state, heading, step length, Quality Engine, or controller logic, and no GNSS correction is applied.
* Config A remains the frozen `config_a_baseline_pdr` profile: `TYPE_STEP_DETECTOR`, true-north-corrected `TYPE_ROTATION_VECTOR`, fixed uncalibrated and unvalidated 0.75 m step length, `ΔE = 0.75 × sin(ψ)`, and `ΔN = 0.75 × cos(ψ)`.
* Step and heading association uses nanosecond `SensorEvent.timestamp`. Protected GNSS uses `Location.getElapsedRealtimeNanos`, and the operation window uses `SystemClock.elapsedRealtimeNanos`. The shared elapsed-realtime contract passed without an unsupported cross-clock comparison; ARCore frame timestamps are not involved.
* For each accepted step, Config A selects the valid heading with the greatest timestamp satisfying `T_heading <= T_step`. The protected-GT comparator separately selects the latest finalized estimator state at or before the GT timestamp. Neither lookup uses a future value, interpolation, post-step correction, or protected-GT influence on estimator state.
* Stage 6 changed exactly six implementation/test paths. Post-fix static validation passed: `flutter analyze --no-pub`, all 169/169 tests, `flutter build apk --debug`, and `git diff --check`; unexpected paths were absent and the staging area remained empty.
* The stationary physical evaluation accepted and matched 30/30 protected-GT fixes, accepted and integrated zero steps, remained at local origin, and reported approximately 0.526 m median horizontal error, 2.445 m p95 error, and 0.506 m final denied pre-correction error. These values are not survey-grade accuracy measurements.
* The initial moving test found a real Stage 6 defect: 11 accepted steps were all unassociated despite 1,531 valid headings. Only the latest delivered heading was retained, so callback-delivery timing could leave a future-dated heading while older causal samples were unavailable. Stage 4 was unaffected because it buffered the two streams and associated them by timestamps.
* The two-file bug fix buffered valid heading samples and accepted step timestamps, then finalized association with the Stage 4 causal policy. Regression tests for the previous heading, future-heading rejection, multi-step counters, and GT mutation invariance passed; Stage 4 and the Ground Truth Firewall were unchanged.
* In the post-fix moving retest, the user manually walked 20 steps. Sixteen step updates were observed, five were outside the formal window, and all 11 accepted steps were associated and integrated with zero unassociated steps. The final denied state was approximately `(E, N) = (8.108, -1.311) m`, with 8.213 m displacement and 8.25 m nominal integrated path length. This is not 20/20 step-detection accuracy evidence.
* The moving retest accepted and matched 30/30 protected-GT fixes. Android-reported horizontal-accuracy metadata ranged from approximately 17.36 m to 57.12 m, so the approximately 19.99 m median error, 48.24 m p95 error, and 19.78 m final pre-correction error validate the evaluation/firewall flow, not Config A accuracy or survey-grade ground truth. Protected-GNSS ground-truth accuracy remains not validated.
* Successful physical results preserved all firewall flags: protected GNSS remained unavailable to and unused by estimator, heading, step length, Quality Engine, and controller APIs; `gnssCorrectionApplied = false` and `firewallMutationSelfTestPassed = true`. Explicit `evaluation_cancelled` cancellation passed. Raw GNSS coordinates, protected-GT/denied trajectories, timestamps, and device identifiers are not returned or persisted.

---

### In Progress

* The six Stage 6 implementation/test paths and four synchronized documentation paths remain unstaged while the final combined 10-path commit-readiness audit is prepared.

---

### Next

* Run the final combined Stage 6 implementation and documentation commit-readiness audit.
* If that gate passes, perform controlled staging of the approved 10-path Stage 6 scope.
* Continue with the planned Stage 7 — Quality Engine + EKF Sensor Fusion. Stage 7 is not implemented.
* Complete the remaining device/runtime checks before freezing the device baseline.

---

### Implementation Status

| Component                                   | Status                                                            |
| ------------------------------------------- | ----------------------------------------------------------------- |
| Development Environment                     | Completed                                                         |
| Android / Flutter Project                   | Implemented — Bootstrap                                           |
| Device Capability Verification              | Partial — Stage 2A Metadata + Stage 2B Sensor Timing + Stage 2C GNSS Timing + Stage 2D ARCore Tracking + Stage 3A GNSS Anchor Flow + Stage 3B Heading Foundation + Stage 3C Step Events + Stage 4 Baseline PDR + Stage 5 ARCore-to-ENU + Stage 6 Evaluation/Firewall Flow |
| SensorManager Capability Inventory          | Implemented and Physically Verified                               |
| Continuous Sensor Acquisition               | Implemented — Stage 2B Diagnostic Timing Scope Only               |
| Sensor Rate / Timestamp Characterization    | Physically Verified — Tested Stage 2B Scope                       |
| GNSS Runtime Timing Diagnostics             | Implemented and Physically Verified — Tested Stage 2C Scope       |
| GNSS Runtime Timing Characterization        | Physically Verified — Three Formal Stage 2C Sessions              |
| GNSS Coordinate Accuracy                    | Not Validated                                                     |
| GNSS Anchor                                 | Implemented and Physically Verified — Stage 3A Runtime Scope      |
| WGS84 / Local ENU Foundation                | Implemented and Unit-Tested — Physical Distance Accuracy Not Validated |
| GNSS Denial Controller / Ground Truth Firewall | Software-Defined Estimator Denial + Ground Truth Firewall Implemented and Physically Verified — Stage 6 Scope; Recovery Not Implemented |
| Evaluation Mode                             | Implemented and Physically Verified — Stage 6 Config A Scope; Accuracy Not Validated |
| ARCore Runtime Tracking Diagnostics         | Implemented and Physically Verified — Tested Stage 2D Scope       |
| ARCore Distance / Absolute Accuracy         | Not Validated                                                     |
| ARCore-to-ENU Transform                     | Implemented and Physically Verified — Stage 5 Scope; Accuracy Not Validated |
| PDR                                         | Baseline Position Implemented and Physically Verified — Accuracy Not Validated |
| Handset Heading / True-North Foundation     | Implemented and Physically Verified — Stage 3B Runtime Scope; Absolute Accuracy Not Validated |
| Body Heading / Handset-to-Body Calibration  | Not Implemented                                                   |
| Step-Event Foundation                       | Implemented and Physically Verified — Stage 3C Runtime Scope      |
| Step Detection Accuracy                     | Not Validated                                                     |
| Step Length / Heading-Step Association      | Fixed 0.75 m Baseline + Causal Association Implemented — Accuracy Not Validated |
| Motion AI                                   | Not Implemented                                                   |
| Quality Engine                              | Not Implemented                                                   |
| EKF / Sensor Fusion                         | Not Implemented                                                   |
| Testing                                     | Stage 1 + Stage 2A + Stage 2B + Stage 2C + Stage 2D + Stage 3A + Stage 3B + Stage 3C + Stage 4 + Stage 5 + Stage 6 Defined Scopes Passed; 169/169 Current Tests Passed |
| Field Experiments                           | Partial — Scoped Foundation Verification Only                     |
| Final Benchmark / Evaluation                | Stage 6 Evaluation Flow Run; Navigation Accuracy Benchmark Not Validated |

---

### Documentation Status

| Area                       | Status              |
| -------------------------- | ------------------- |
| Project Definition         | Complete            |
| Requirements               | Complete            |
| Architecture               | Complete            |
| Navigation Design          | Complete            |
| AI Design                  | Complete            |
| Testing Strategy           | Complete            |
| Experiment Planning        | Complete            |
| Evaluation Planning        | Complete            |
| Risk & Limitation Analysis | Complete            |
| Technical References       | Complete            |
| Final Experimental Results | Pending Experiments |

---

### Repository Visibility

**Public**

Raw experimental data, precise location logs, credentials, secrets, and other sensitive local files are excluded from version control.

---

### Current Development Rule

Flutter Android bootstrap, Stage 2A SensorManager runtime capability inventory, Stage 2B four-sensor live timing diagnostics, Stage 2C GNSS runtime timing diagnostics, Stage 2D ARCore runtime tracking diagnostics, Stage 3A — GNSS Anchor + Local ENU Reference Foundation, Stage 3B — Heading / True-North Reference Foundation, Stage 3C — Step-Event Foundation, Stage 4 — Baseline PDR, Stage 5 — ARCore Relative Motion → ENU Foundation, and Stage 6 — Evaluation Mode + Ground Truth Firewall are implemented and verified for their defined scopes.

Stage 2B physically verified live event delivery and timestamp-derived timing behavior for the accelerometer, gyroscope, magnetometer, and rotation vector in 12 tested sessions under a 20,000 µs request. Requested and observed rates remain distinct, the 60 ms gap threshold remains provisional, and these results do not verify sensor noise, bias, calibration, heading, or navigation performance.

Stage 2C physically characterized `GPS_PROVIDER` callback timing in three formal sessions using `Location.elapsedRealtimeNanos`. All three sessions were valid, monotonic, and mock-free. The requested 1,000 ms minimum interval remained separate from observed delivery: median and p95 intervals were 1.000 s in all sessions, the observed mean rate range was approximately 0.983–1.000 Hz, and one 2.000 s consecutive interval occurred. No GNSS gap threshold is defined. TTFF, satellite counts, and horizontal accuracy are diagnostic metadata only; GNSS coordinate accuracy was not validated.

Stage 2D physically verified ARCore readiness and live tracking in three formal sessions. All three sessions were valid, observed real `TrackingState.TRACKING`, exposed local-session pose, used monotonic `Frame.timestamp` sequences, completed without terminal errors or `STOPPED` frames, and successfully exercised session creation/configuration/resume plus dedicated GL/EGL and camera-texture setup. The observed unique-frame rate was approximately 30.0295–30.0304 Hz and the tested-session tracking fraction was approximately 98.15%–98.36%. No ARCore frame-gap threshold is defined, and these values are not universal guarantees or navigation-quality scores.

Stage 3A physically verified `GPS_PROVIDER` preflight/readiness, three of three independent pre-denial anchor acquisitions, explicit clear/reacquire, and explicit cancellation on the tested device. Formal acquisition uses `Location.elapsedRealtimeNanos` as physical measurement-time authority: the first valid candidate starts a 10-second window, at least three candidates are required, and selection uses lowest reported horizontal accuracy with a newer measurement timestamp tie-break. The 10 / 11 / 10 candidate sessions selected reported-accuracy metadata of approximately 17.98 / 15.32 / 34.79 m. These Android-reported values are not measured ground-truth error. The runtime anchor is immutable until explicitly cleared and is not persisted. WGS84 → ECEF → local ENU math is implemented and unit-tested; horizontal ENU is available without fabricating Up when altitude is absent. Formal shared logs were sanitized and did not print raw anchor coordinates.

Stage 3B physically verified the runtime availability and formal use of `TYPE_ROTATION_VECTOR`, three of three 30-second handset-heading sessions, `SensorEvent.timestamp` timing, monotonic and duplicate-free timestamp sequences, clockwise-positive response, circular accumulation beyond 2π without a consecutive ±2π discontinuity, locked-anchor `android.hardware.GeomagneticField` correction, and explicit cancellation. Observed delivery was approximately 51.14 Hz under the 20,000 µs nominal request. The platform geomagnetic model remains `platform_managed` with freshness not independently validated; heading-accuracy metadata was unavailable in all tested sessions.

Stage 3C physically verified the `TYPE_STEP_DETECTOR`-only formal step-event path on Android 12 / API 31. A stationary 30-second session accepted zero events; a controlled 20-step walk accepted 16 events while five delivered events were excluded by the formal window; and a controlled 30-step walk accepted 30 events. The walking sessions had zero duplicate and zero non-monotonic accepted timestamps, and explicit cancellation passed. These are limited physical observations and do not validate general step-detection accuracy.

Stage 4 physically verified the deterministic baseline-PDR runtime path. The stationary session integrated zero steps; both manually counted 20-step straight walks integrated 20 steps; and the intended 20-step L-shaped pattern integrated 22 detected events. All walking events were causally associated without future headings, and explicit cancellation passed. A corrected independent north check resolved the earlier physically misidentified direction reference. No accuracy percentage or metrological accuracy claim follows from these scoped observations.

Stage 5 physically verified the defined ARCore-to-ENU runtime path. The stationary, independently identified north-like, independently identified east-like, and approximate 90-degree in-place rotation sessions completed; the straight-walk outputs had the expected dominant positive ENU axes, the rotation displacement remained much smaller than the straight-walk displacements, and explicit cancellation passed. All completed formal sessions reported full camera tracking in their observed windows. These observations validate the scoped runtime flow and qualitative axis/sign behavior, not metrological accuracy.

Stage 6 physically verified the Evaluation Mode and Ground Truth Firewall data flow on the same device. A stationary session remained at the denied-estimator origin. The initial moving test exposed the delivered-callback-order heading-retention bug; the timestamp-buffering fix was then validated when all 11 accepted formal-window steps were causally associated and integrated during the 20-manual-step retest. Thirty protected-GT fixes were accepted and matched in each successful session, firewall flags remained isolated, and explicit cancellation passed. Large Android-reported protected-GNSS uncertainty prevents the moving error metrics from serving as validated Config A performance evidence.

Physical verification remains partial and the device baseline is not frozen. PDR accuracy, step-detection accuracy, step-length accuracy, heading absolute accuracy, true-north absolute accuracy, protected-GNSS ground-truth accuracy, GNSS absolute coordinate accuracy, survey-grade anchor quality, physical ENU distance accuracy, same-location anchor repeatability, ARCore position/distance/vertical accuracy, and ENU-alignment accuracy were not validated. Body heading and handset-to-body calibration are not implemented. ARCore-to-ENU, Evaluation Mode, software-defined estimator denial, and the Ground Truth Firewall are implemented, but ARCore/PDR fusion, GNSS recovery, Motion AI, Quality Engine, EKF / Sensor Fusion, relocalization, and full GNSS-denied navigation are not. Other required device checks remain pending; the 20% improvement target is unmeasured and no validated navigation-accuracy benchmark has been established.

---

### Last Status Update

**2026-09-10**

---

# NAVGUARD — Proje Durumu

## Türkçe Sürüm

### Mevcut Durum

**Proje Aşaması:** Aşama 6 — Değerlendirme Modu + Ground Truth Güvenlik Duvarı Uygulandı, Statik Olarak Doğrulandı ve Fiziksel Olarak Doğrulandı — Dokümantasyon Senkronizasyonu Tamamlandı; Commit-Readiness Denetimi Bekliyor

**Repository Durumu:** Altı Stage 6 Uygulama/Test Yolu ve Dört Dokümantasyon Yolu Unstaged — Nihai Birleşik 10-Yolluk Commit-Readiness Denetimi Bekliyor

**Teknik Dokümantasyon:** Baseline Tamamlandı

**Uygulama Geliştirme:** Başladı — Bootstrap + SensorManager Yetenek Envanteri + Dört Sensörlü Canlı Zamanlama Tanıları + GNSS Çalışma Zamanı Zamanlama Tanıları + ARCore Çalışma Zamanı Takip Tanıları + GNSS Anchor / WGS84 Yerel ENU Temeli + Handset Heading / Gerçek Kuzey Düzeltme Temeli + Adım Olayı Temeli + Deterministik Temel PDR + ARCore Göreli Hareket → ENU Temeli + Değerlendirme Modu + Ground Truth Güvenlik Duvarı

**Deneysel Değerlendirme:** Kısmi — Cihaz/çalışma zamanı tanı karakterizasyonu ve Stage 3A–6 kapsamlı akış doğrulamaları; navigasyon ve metrolojik doğruluk doğrulanmadı

---

### Mevcut Kilometre Taşı

Stage 6 uygulaması, düzeltme-sonrası 169/169 testli statik doğrulaması, kapsamı belirli fiziksel Değerlendirme Modu ve Ground Truth Firewall doğrulaması, iptal doğrulaması ve dokümantasyon senkronizasyonu tamamlandı. Nihai birleşik 10-yolluk commit-readiness denetimi için hazırlık devam ediyor.

---

### Tamamlananlar

* GitHub repository oluşturuldu.
* İlk repository klasör yapısı oluşturuldu.
* Root `.gitignore` yapılandırıldı.
* Teknik dokümantasyon baseline'ı `docs/` klasörü altında tamamlandı.
* İlk public `README.md` hazırlandı.
* Geliştirme ortamı doğrulandı.
* Flutter Android bootstrap uygulandı ve test edildi.
* Debug APK kimliği ve minimum SDK değeri doğrulandı.
* Bootstrap uygulaması Xiaomi Redmi Note 9 Pro üzerine kuruldu, çalıştırıldı ve etkileşimli olarak kontrol edildi.
* Stage 2A native SensorManager çalışma zamanı yetenek envanteri uygulandı.
* Flutter–Kotlin MethodChannel fiziksel olarak doğrulandı.
* Test edilen Xiaomi Redmi Note 9 Pro üzerinde deterministik 14 istenen sensör kaydı döndürüldü.
* Doğrulanan Stage 2A çalışma zamanı snapshot'ında 13 kullanılabilir varsayılan sensör kaydı ve bir kullanılamayan kayıt vardı; `TYPE_PRESSURE` varsayılan sensörü bu snapshot'ta kullanılamıyordu.
* Stage 2A analiz, test, debug build ve fiziksel çalıştırma doğrulamaları geçti.
* Stage 2B; ivmeölçer, jiroskop, manyetometre ve dönüş vektörü için özel bir `HandlerThread` ile çalışan ve zamanlama otoritesi olarak `SensorEvent.timestamp` kullanan tek bir native canlı zamanlama tanısı ekledi.
* Stage 2B analiz, widget testleri, diff bütünlüğü kontrolleri ve fiziksel zamanlama doğrulaması, test edilen dört sensörlü tanı kapsamı için geçti.
* Sensör başına üç adet 10 saniyelik oturum; 12/12 geçerli zamanlama özeti ve monoton zaman damgası dizisi üretti, 0/12 oturumda geçici 60 ms eşiğinin üzerinde boşluk gözlendi.
* Test edilen 20.000 µs (~50 Hz talep edilen) yapılandırmada timestamp-türevli birleşik ortalama hızlar ivmeölçer için yaklaşık 52,10 Hz, jiroskop için 51,07 Hz, manyetometre için 50,00 Hz ve dönüş vektörü için 51,10 Hz olarak gözlendi. Bunlar sabit donanım hızları değil, test edilen cihaz ve oturumlara ait gözlemlerdir.
* Stage 2C; `LocationManager`, yalnızca `GPS_PROVIDER`, özel bir `HandlerThread`, `LocationListener`, `GnssStatus.Callback` ve zamanlama otoritesi olarak `Location.elapsedRealtimeNanos` kullanan yalnızca ön planda çalışan native GNSS zamanlama tanısını uyguladı.
* Stage 2C hassas ön plan konum izni akışı ve GNSS preflight fiziksel olarak doğrulandı. Uygulama `ACCESS_COARSE_LOCATION` ve `ACCESS_FINE_LOCATION` izinlerini ekledi; arka plan konum izni, konum foreground service'i, Flutter dependency'si veya Android dependency'si eklemedi.
* Stage 2C formatlama, analiz, widget testleri, debug APK build'i ve diff bütünlüğü kontrolleri geçti; ardından nihai kaynak ve fiziksel denetim başarıyla tamamlandı.
* Üç resmî GNSS zamanlama oturumu normal tamamlandı; 3/3 özet geçerli, 3/3 zaman damgası dizisi monotonik ve 0/3 oturum mock konumluydu. Üç oturumun tümünde medyan ve p95 callback aralığı 1,000 s; gözlenen timestamp-türevli ortalama hız aralığı yaklaşık 0,983–1,000 Hz idi.
* Oturum 3'te ardışık bir 2,000 s GPS callback aralığı gözlendi. Tanımlı bir GNSS büyük-boşluk eşiği yoktur; bu gözlem talep edilen 1.000 ms minimum aralığın sabit 1 Hz teslimi garanti etmediğini gösterir.
* `GnssStatus.onFirstFix` metadata'sı ve sanitize edilmiş uydu sayısı özetleri gözlendi. Android tarafından bildirilen yatay doğruluk metadata'sı kaydedilen her callback'te mevcuttu ancak GNSS koordinat doğruluğu doğrulanmadı.
* Stage 2D; `com.google.ar:core:1.54.0`, kamera izni ve isteğe bağlı `com.google.ar.core` manifest bildirimi kullanan AR-optional native ARCore çalışma zamanı takip tanısını uyguladı.
* Stage 2D formatlama, analiz, widget testleri, debug APK build'i, diff bütünlüğü kontrolleri ve nihai kaynak ile fiziksel denetimi geçti.
* Üç resmî fiziksel ARCore oturumu; 3/3 geçerli özet, 3/3 gerçek `TrackingState.TRACKING` gözlemi, 3/3 yerel-oturum pozu kullanılabilirliği, 3/3 monotonik `Frame.timestamp` dizisi, 3/3 terminal-error-free sonuç ve sıfır `STOPPED` kare ile tamamlandı.
* ARCore oturum oluşturma, yapılandırma, resume, özel GL/EGL başlatma ve kamera texture kurulumu 3/3 oturumda geçti. Test edilen oturumlarda gözlenen benzersiz-kare hızı yaklaşık 30,0295–30,0304 Hz, tracking fraction yaklaşık %98,15–%98,36 idi.
* Üç senaryo yaklaşık sabit durma, duraklamalarla yaklaşık 120 derecelik elde telefon/kamera dönüşü ve sağa doğru yaklaşık 2–3 adım yürüyüş idi. Bunlar canlı yerel-oturum poz tepkisini doğruladı; dönüş doğruluğunu, mesafe doğruluğunu, mutlak doğruluğu veya resmî bir sürüklenme benchmark'ını doğrulamadı.
* Stage 3A, Android `LocationManager.GPS_PROVIDER` kaynağından gerçek, yalnızca ön planda ve gelecekteki yazılım tanımlı GNSS kesintisinden önce çalışan GNSS anchor edinimini uyguladı; arka plan konumu, fused provider veya network provider kullanılmadı.
* Resmî aday doğrulaması mock olmayan GPS konumu, sonlu ve geçerli enlem/boylam, pozitif `Location.elapsedRealtimeNanos` ve sonlu pozitif bildirilen yatay doğruluk gerektirir. Yükseklik ve dikey doğruluk isteğe bağlıdır.
* İlk yapısal olarak geçerli fix için timeout 120 saniyedir ve bu fix 10 saniyelik monotonik GNSS ölçüm-zamanı penceresini başlatır. En az üç geçerli aday gerekir; seçim en düşük bildirilen yatay doğruluğu, eşitlik bozucu olarak daha yeni `Location.elapsedRealtimeNanos` değerini kullanır. Handler zamanlaması yalnızca operasyonun sonlandırılmasını yönetir ve fiziksel GNSS ölçüm zamanını tanımlamaz.
* Stage 3A, WGS84 jeodezik → ECEF → anchor-göreli yerel ENU temelini ekledi. Tam 3B ENU için anchor ve hedef elipsoit yükseklikleri gerekir; aksi halde iki nokta için aynı deterministik `h = 0` referansı kullanılır ve uydurma Up bileşeni olmadan yalnızca yatay E/N döndürülür.
* Stage 3A sekiz kaynak/test yolunu değiştirdi. `flutter analyze`, 32/32 testin tamamı, `flutter build apk --debug` ve `git diff --check` geçti.
* Üç bağımsız fiziksel anchor oturumu 10 / 11 / 10 aday sayılarıyla başarılı tamamlandı. Seçilen Android-bildirilen yatay doğruluk metadata değerleri yaklaşık 17,98 / 15,32 / 34,79 m idi. Bunlar bağımsız ölçülmüş konum hataları değildir ve GNSS mutlak koordinat doğruluğunu doğrulamaz.
* Açık çalışma zamanı clear/reacquire davranışı sanitize edilmiş `anchor_locked` → `no_anchor` durum geçişiyle doğrulandı; açık iptal işlemi test cihazında `success = false` ve `errorCategory = acquisition_cancelled` döndürdü.
* Ham anchor koordinatları paylaşılan resmî sanitize edilmiş tanı loglarında yazdırılmadı ve Stage 3A tarafından kalıcılaştırılmadı. Başarılı anchor kendi çalışma zamanı referans oturumunda değişmez kalır; değiştirmek için Clear Anchor ve ardından Acquire GNSS Anchor gerekir.
* Stage 3B, tek heading kaynağı olarak `Sensor.TYPE_ROTATION_VECTOR` kullanan deterministik bir handset-heading temeli uyguladı. Fiziksel üst kenar / cihaz +Y ekseni ileri yöndür; heading radyan cinsinden, Kuzeyden saat yönünde pozitif ve `[0, 2π)` aralığına normalize edilmiştir.
* Rotation-vector örnekleri `SensorManager.getRotationMatrixFromVector(...)` ile dönüştürülür; cihaz +Y yönü yatay Doğu/Kuzey bileşenlerine izdüşürülür ve manyetik handset heading `atan2(Doğu, Kuzey)` ile hesaplanır. Dairesel işaretli deltalar 0 / 2π sınırındaki sürekliliği korur.
* Gerçek-kuzey düzeltmesi, tek konum kaynağı olarak mevcut kilitli Stage 3A GNSS anchor ile `android.hardware.GeomagneticField` kullanır. Anchor elipsoit yüksekliği varsa kullanılır; yoksa deterministik 0 m fallback'i ölçülmüş yükseklik olarak değil, açıkça `deterministic_zero_fallback` olarak tanımlanır. Platform tarafından yönetilen geomanyetik model sürümü/güncelliği bağımsız doğrulanmamıştır.
* Stage 3B sensör ölçüm zamanlaması `SensorEvent.timestamp` kullanır; `System.currentTimeMillis` yalnızca geomanyetik modelin zaman girdisidir ve `wallClockUsedForSensorTiming = false` değeridir. Resmî tanının ilk geçerli örnek timeout'u 10 saniye, sensör-zaman-damgası ölçüm penceresi 30 saniyedir.
* Stage 3B üç yeni ve üç değiştirilmiş olmak üzere altı kaynak/test yolunu değiştirdi. `flutter analyze`, 61/61 testin tamamı, `flutter build apk --debug` ve `git diff --check` geçti. Flutter/Android dependency veya manifest değişikliği gerekmedi.
* Fiziksel heading testlerinden önce 11 aday, yaklaşık 43,7262 m Android-bildirilen yatay doğruluk metadata'sı ve mevcut yükseklik ile yeni bir Stage 3A anchor edinildi. Bu değer bağımsız ölçülmüş konum hatası değil metadata'dır; ham koordinatlar paylaşılan sanitize edilmiş resmî loglara dahil edilmedi.
* Heading preflight, gerçek `TYPE_ROTATION_VECTOR` kaynağını 20.000 µs talep altında `Rotation Vector Non-wakeup` adıyla kullanılabilir buldu. Android 12 / API 31 çalıştıran Xiaomi Redmi Note 9 Pro üzerindeki üç resmî 30 saniyelik fiziksel oturumun 3/3'ü başarılı oldu.
* Üç resmî oturumun tüm zaman damgası dizileri monotonikti, tüm duplicate zaman damgası sayıları sıfırdı, gözlenen teslim hızı yaklaşık 51,137–51,138 Hz ve medyan delta yaklaşık 19,555 ms idi. Bu, nominal 50 Hz talep altındaki gözlenen teslimdir; garanti edilen hız değildir.
* Sabit oturum yaklaşık -0,05827 rad birleşik gerçek-heading değişimi ve yaklaşık 0,00676 rad maksimum ardışık dairesel delta üretti. Bu, heading doğruluğu doğrulaması değil gözlemsel kararlılık kanıtıdır.
* Yaklaşık manuel saat yönü dönüşü oturumu yaklaşık +1,14196 rad (+65,4°) birleşik değişim üreterek saat yönünde pozitif convention'ı fiziksel olarak destekledi; dönüş ölçeğini veya bağımsız ölçülmüş bir açıyı doğrulamadı.
* Wrap oturumu 2π değerini aşan yaklaşık +10,56496 rad birleşik değişim üretirken maksimum ardışık dairesel delta yaklaşık 0,07181 rad kaldı. Bu, kesin fiziksel dönüş açısı iddia etmeden bir veya daha fazla 0 / 2π sınırındaki dairesel sürekliliği fiziksel olarak destekler.
* Test edilen declination düzeltmesi yaklaşık 0,112255 rad (6,43°) idi, `android.hardware.GeomagneticField` ve `anchor_ellipsoid_altitude` kullandı. Bu sonuç kilitli-anchor düzeltme yolunun çalıştığını doğrular, gerçek-kuzey mutlak doğruluğunu değil. Rotation-vector bildirilen heading-doğruluk metadata'sı üç oturumun tamamında kullanılamıyordu ve ölçülmüş heading hatası değil isteğe bağlı metadata olarak kalır.
* Açık Stage 3B iptali `errorCategory = heading_diagnostic_cancelled` ile fiziksel olarak doğrulandı. Anchor koordinatları yalnızca geomanyetik declination hesabı için içeride kullanılır ve sanitize edilmiş resmî loglara dahil edilmez; ham rotation-vector akışları döndürülmez veya kalıcılaştırılmaz.
* Stage 3C, birincil ve tek resmî adım kaynağı olarak `Sensor.TYPE_STEP_DETECTOR` kullanan adım-olayı temelini uyguladı. Android 10 / API 29 ve sonrasında çalışma zamanı yolu `android.permission.ACTIVITY_RECOGNITION` iznini ister; bu izin test edilen Android 12 / API 31 cihazında gerekliydi.
* Stage 3C adım ölçüm zamanlaması `SensorEvent.timestamp` kullanır; `SystemClock.elapsedRealtimeNanos()` resmî operasyon penceresini yönetir ve wall clock adım-zamanlaması otoritesi değildir. 30 saniyelik tanı, ham zaman damgaları veya ham örnekleri döndürmeden ve kalıcılaştırma kullanmadan birleşik sayıları, aralık istatistiklerini ve gözlenen kadansı döndürür. Sıfır-adımlı oturum geçerli bir sonuçtur.
* Stage 3C üç yeni ve dört değiştirilmiş toplam yedi uygulama yolunu değiştirdi. `flutter analyze --no-pub`, 97/97 testin tamamı, `flutter build apk --debug` ve `git diff --check` geçti; beklenmeyen uygulama yolu yoktu ve staging alanı boş kaldı.
* Sabit fiziksel oturumda manuel olarak sıfır adım sayıldı ve sıfır olay kabul edildi; bu tek 30 saniyelik oturumda false olay gözlenmedi. Bu sonuç global sıfır-false-positive sonucu oluşturmaz.
* Kontrollü 20 adımlık yürüyüş 21 update teslim etti: 16 olay kabul edildi, beş olay resmî oturum-penceresi filtresiyle dışlandı; geçersiz, duplicate veya monotonik olmayan kabul edilmiş olay yoktu. Bu sınırlı bir gözlemdir; doğrulanmış %80 doğruluk ölçümü değildir ve dışlanan olaylar manuel adımlarla bire bir eşlenemez.
* Kontrollü 30 adımlık yürüyüş 30 olay teslim etti ve kabul etti; bu oturumdaki manuel sayımla eşleşti ve pencere dışı, geçersiz, duplicate veya monotonik olmayan olay yoktu. Bu, genel adım-algılama doğruluğunu doğrulamaz.
* İki yürüyüş oturumunda da kabul edilen zaman damgalarının duplicate ve monotonik olmayan sayıları sıfırdı. Gözlenen kadans, 20-adımlık oturumun kabul edilen olayları için yaklaşık 91,28 adım/dakika, 30-adımlık oturum için yaklaşık 93,65 adım/dakika idi; bunlar evrensel yürüme hızları değil, oturum gözlemleridir.
* Açık Stage 3C iptali `step_diagnostic_cancelled` ve Flutter'daki `Step-event diagnostic failed (step_diagnostic_cancelled).` mesajıyla fiziksel olarak doğrulandı. İptal bir operasyon-denetimi davranışı olarak geçti ve başarılı ölçüm sonucu değildir.
* Stage 4, yalnızca `Sensor.TYPE_STEP_DETECTOR` ile gerçek-kuzey-düzeltilmiş `Sensor.TYPE_ROTATION_VECTOR` handset heading kullanarak deterministik yatay yerel-ENU PDR uyguladı. Fiziksel üst kenar / cihaz +Y ekseni ileridir; heading Kuzeyden saat yönünde pozitif ve `[0, 2π)` aralığındadır.
* Her kabul edilen adım, `SensorEvent.timestamp` değeri adım zaman damgasında veya öncesinde olan en yeni geçerli heading ile (`latest_valid_heading_at_or_before_step_timestamp`) ilişkilendirilir. Gelecek heading ve interpolasyon yasaktır. `SystemClock.elapsedRealtimeNanos()` 30 saniyelik operasyon penceresini yönetir ancak heading-adım ilişkilendirmesi otoritesi değildir.
* Her ilişkilendirilmiş adım, yerel `E = 0, N = 0` başlangıcından `ΔE = L × sin(ψ)` ve `ΔN = L × cos(ψ)` ile sabit araştırma-baseline varsayımı `L = 0,75 m` kullanır. Adım uzunluğu ne kalibre edilmiş ne de doğrulanmıştır.
* Kilitli Stage 3A anchor yalnızca `android.hardware.GeomagneticField` declination değeri için kullanılır. Model `platform_managed` durumundadır, güncelliği doğrulanmamıştır ve Stage 4 entegrasyonu sırasında canlı GNSS kullanılmaz.
* Stage 4 tam altı uygulama/test yolunu değiştirdi. `flutter analyze --no-pub`, 118/118 testin tamamı, `flutter build apk --debug` ve `git diff --check` geçti; manifest veya dependency değişikliği gerekmedi.
* Sabit 30 saniyelik oturum sıfır adım kabul edip entegre etti; 1.527/1.527 geçerli heading örneği ve sıfır nihai yer değiştirme üretti. Bu tek gözlem evrensel sıfır false-positive sonucu oluşturmaz.
* Manuel sayılan iki 20-adımlık düz yürüyüşün her biri 20 adımı kabul etti, ilişkilendirdi ve entegre etti; ilişkilendirilmemiş adım yoktu. Nihai yerel-ENU sonuçları yaklaşık `(-14,601, 2,639) m` ve `(3,715, 14,458) m` idi; ilişkilendirme yaşları yaklaşık 0,34–19,47 ms aralığında kaldı. İlk yürüyüşün varsayılan coğrafi yönünün daha sonra fiziksel olarak yanlış seçildiği belirlendiğinden mutlak E/N yönü heading hatası kanıtı değildir.
* Hedeflenen 10 + dönüş + 10 L-biçimli yürüyüş 22 olayı kabul etti, ilişkilendirdi ve entegre etti; yaklaşık `(-6,621, 11,423) m`, 13,203 m net yer değiştirme ve 16,5 m nominal yol uzunluğu üretti. İki olaylık fark, kanıtlanmış neden veya adım-algılama doğruluğu iddiası olmadan kaydedilir.
* Fiziksel yön düzeltildikten sonraki hedefli bağımsız kuzey kontrolü, 1.535 geçerli örnekle yaklaşık 0,1036/0,1242 rad ilk/son gerçek-kuzey-düzeltilmiş heading üretti; bu, heading veya gerçek-kuzey mutlak doğruluğunu doğrulamadan önceki yön endişesini çözdü.
* Açık Stage 4 iptali `baseline_pdr_cancelled` döndürdü. Stage 4 sonucu ham rota, sensör örneği, sensör zaman damgası, anchor koordinatı veya canlı GNSS verisi döndürmez ya da kalıcılaştırmaz.
* Stage 5, Android sensör çerçevesinde ARCore `Frame.getAndroidSensorPose()` kullanarak segment-göreli yerel ENU yer değiştirmesini uyguladı: +X cihazın fiziksel sağı, +Y fiziksel üst kenar ve +Z ekrandan dışarıdır. Ekran-dönüşü remapping'i ve kamera optik ileri yönü kullanılmaz.
* Sabitliğin varsayıldığı 2 saniyelik hizalama ve 15 saniyelik edinim timeout'undan sonra Stage 5 ilk Android sensör pozunda yerel ARCore anchor'ı oluşturur. Resmî göreli poz `anchor.pose.inverse().compose(currentAndroidSensorPose)` ile hesaplanır ve 30 saniyelik hareket penceresi `SystemClock.elapsedRealtimeNanos()` ile yönetilir.
* İlk cihazdan gerçek ENU'ya hizalama, `TYPE_ROTATION_VECTOR` ile kilitli-anchor `android.hardware.GeomagneticField` declination değerini kullanır. Kilitli Stage 3A anchor yalnızca declination için kullanılır; canlı GNSS, travel bearing, Geospatial API, cloud anchor veya fallback hareket tahmin motoru kullanılmaz.
* Rotation-vector zamanlaması `SensorEvent.timestamp`; ARCore sıralama ve birleşik kare zamanlaması `Frame.getTimestamp()` kullanır. ARCore, sensör olaylarıyla ortak zaman damgası epoch'u tanımlamadığından `crossClockTimestampComparisonUsed = false` değeridir ve cross-clock gecikmesi hesaplanmaz.
* Stage 5 tam altı uygulama/test yolunu değiştirdi. `flutter analyze --no-pub`, 141/141 testin tamamı, `flutter build apk --debug` ve `git diff --check` geçti; manifest veya dependency değişikliği gerekmedi.
* Sabit resmî oturum başlangıçtan yaklaşık 0,081 m yatay uzaklıkta, yaklaşık 0,100 m maksimum yatay sapmayla sonlandı. Kuzey-benzeri yürüyüş yaklaşık `(E, N) = (1,507, 8,223) m`; doğu-benzeri yürüyüş bir duplicate ve sıfır monotonik-olmayan AR kare zaman damgasıyla yaklaşık `(9,129, -1,176) m` sonucunu verdi.
* Yaklaşık 90 derecelik yerinde dönüş yaklaşık 0,503 m yatay yer değiştirmeyle, yaklaşık 8–9 m düz-yürüyüş sonuçlarından belirgin biçimde düşük kaldı. Bu nitel bir eksen/öteleme gözlemidir; doğrulanmış hata eşiği değildir. Açık iptal `arcore_enu_cancelled` döndürdü.
* Tamamlanan Stage 5 resmî ölçüm oturumları `trackingFraction = 1.0` ve sıfır `PAUSED`/`STOPPED` kare bildirdi. Bundan evrensel takip garantisi veya tracking-loss recovery doğrulaması çıkarılamaz. Ham ARCore pozları, rotalar, rotation-vector örnekleri, zaman damgaları, kamera görüntüleri ve anchor koordinatları döndürülmez veya kalıcılaştırılmaz.
* Stage 6, fiziksel GNSS'in `protected_ground_truth_only` olarak izole edildiği ve Yapılandırma A'nın yazılım-tanımlı tahmin motoru GNSS kesintisi altında çalıştığı Değerlendirme Modu'nu uyguladı. Kesintili tahmin motoru API'si yalnızca adım ve heading verisi alır; korumalı GNSS tahmin motoru durumu, heading, adım uzunluğu, Quality Engine veya denetleyici mantığına girmez ve GNSS düzeltmesi uygulanmaz.
* Yapılandırma A, sabitlenen `config_a_baseline_pdr` profili olarak kalır: `TYPE_STEP_DETECTOR`, gerçek-kuzey-düzeltilmiş `TYPE_ROTATION_VECTOR`, sabit kalibre edilmemiş ve doğrulanmamış 0,75 m adım uzunluğu, `ΔE = 0,75 × sin(ψ)` ve `ΔN = 0,75 × cos(ψ)`.
* Adım ve heading ilişkilendirmesi nanosaniye `SensorEvent.timestamp` kullanır. Korumalı GNSS `Location.getElapsedRealtimeNanos`, operasyon penceresi `SystemClock.elapsedRealtimeNanos` kullanır. Paylaşılan elapsed-realtime sözleşmesi desteklenmeyen cross-clock karşılaştırması olmadan geçti; ARCore kare zaman damgaları bu eşleştirmeye katılmaz.
* Her kabul edilen adım için Yapılandırma A, `T_heading <= T_step` koşulunu sağlayan en büyük zaman damgalı geçerli heading'i seçer. Korumalı-GT karşılaştırıcısı ayrı olarak GT zaman damgasında veya öncesindeki en yeni finalize edilmiş tahmin motoru durumunu seçer. İki arama da gelecek değer, interpolasyon, adım-sonrası düzeltme veya tahmin motoru durumuna korumalı-GT etkisi kullanmaz.
* Stage 6 tam altı uygulama/test yolunu değiştirdi. Düzeltme-sonrası statik doğrulama geçti: `flutter analyze --no-pub`, 169/169 testin tamamı, `flutter build apk --debug` ve `git diff --check`; beklenmeyen yol yoktu ve staging alanı boş kaldı.
* Sabit fiziksel değerlendirme 30/30 korumalı-GT fix'ini kabul edip eşleştirdi, sıfır adım kabul edip entegre etti, yerel başlangıçta kaldı ve yaklaşık 0,526 m medyan yatay hata, 2,445 m p95 hata ve 0,506 m nihai kesintili düzeltme-öncesi hata bildirdi. Bu değerler survey-grade doğruluk ölçümleri değildir.
* İlk hareketli test gerçek bir Stage 6 hatası buldu: 1.531 geçerli heading'e rağmen kabul edilen 11 adımın tamamı ilişkilendirilemedi. Yalnızca en son teslim edilen heading tutulduğundan callback-teslim zamanlaması gelecek-zaman-damgalı bir heading bırakırken eski nedensel örnekler kullanılamıyordu. Stage 4, iki akışı tamponlayıp zaman damgalarıyla ilişkilendirdiği için etkilenmedi.
* İki dosyalık bug fix, geçerli heading örnekleriyle kabul edilen adım zaman damgalarını tamponladı ve ilişkilendirmeyi Stage 4 nedensel politikasıyla finalize etti. Önceki heading, gelecek-heading reddi, çoklu-adım sayaçları ve GT mutasyon değişmezliği regresyon testleri geçti; Stage 4 ve Ground Truth Firewall değişmedi.
* Düzeltme-sonrası hareketli yeniden testte kullanıcı manuel olarak 20 adım yürüdü. On altı adım update'i gözlendi, beşi resmî pencerenin dışındaydı ve kabul edilen 11 adımın tamamı sıfır ilişkilendirilmemiş adımla ilişkilendirilip entegre edildi. Nihai kesintili durum yaklaşık `(E, N) = (8,108, -1,311) m`, 8,213 m yer değiştirme ve 8,25 m nominal entegre yol uzunluğu verdi. Bu, 20/20 adım-algılama doğruluğu kanıtı değildir.
* Hareketli yeniden test 30/30 korumalı-GT fix'ini kabul edip eşleştirdi. Android-bildirilen yatay doğruluk metadata'sı yaklaşık 17,36 m ile 57,12 m arasında olduğundan yaklaşık 19,99 m medyan hata, 48,24 m p95 hata ve 19,78 m nihai düzeltme-öncesi hata, Yapılandırma A doğruluğunu veya survey-grade ground truth'u değil değerlendirme/firewall akışını doğrular. Korumalı-GNSS ground-truth doğruluğu doğrulanmamış olarak kalır.
* Başarılı fiziksel sonuçlar tüm firewall bayraklarını korudu: korumalı GNSS tahmin motoru, heading, adım uzunluğu, Quality Engine ve denetleyici API'leri için kullanılamaz ve kullanılmamış durumda kaldı; `gnssCorrectionApplied = false` ve `firewallMutationSelfTestPassed = true` idi. Açık `evaluation_cancelled` iptali geçti. Ham GNSS koordinatları, korumalı-GT/kesintili rotalar, zaman damgaları ve cihaz kimlikleri döndürülmez veya kalıcılaştırılmaz.

---

### Devam Edenler

* Altı Stage 6 uygulama/test yolu ve dört senkronize dokümantasyon yolu unstaged durumdadır; nihai birleşik 10-yolluk commit-readiness denetimi hazırlanmaktadır.

---

### Sonraki Adımlar

* Nihai birleşik Stage 6 uygulama ve dokümantasyon commit-readiness denetimini çalıştır.
* Bu kapı geçerse onaylanan 10-yolluk Stage 6 kapsamını kontrollü biçimde stage et.
* Planlanan Aşama 7 — Quality Engine + EKF Sensör Füzyonu ile devam et. Stage 7 uygulanmamıştır.
* Cihaz baseline'ını sabitlemeden önce kalan cihaz/çalışma zamanı kontrollerini tamamla.

---

### Uygulama Durumu

| Bileşen                                     | Durum                                                             |
| ------------------------------------------- | ----------------------------------------------------------------- |
| Geliştirme Ortamı                           | Tamamlandı                                                        |
| Android / Flutter Projesi                   | Uygulandı — Bootstrap                                             |
| Cihaz Yetenek Doğrulaması                   | Kısmi — Stage 2A Metadata + Stage 2B Sensör Zamanlaması + Stage 2C GNSS Zamanlaması + Stage 2D ARCore Takibi + Stage 3A GNSS Anchor Akışı + Stage 3B Heading Temeli + Stage 3C Adım Olayları + Stage 4 Temel PDR + Stage 5 ARCore-to-ENU + Stage 6 Değerlendirme/Firewall Akışı |
| SensorManager Yetenek Envanteri             | Uygulandı ve Fiziksel Olarak Doğrulandı                           |
| Sürekli Sensör Verisi Alımı                 | Uygulandı — Yalnızca Stage 2B Tanı Zamanlaması Kapsamı             |
| Sensör Hızı / Zaman Damgası Karakterizasyonu | Fiziksel Olarak Doğrulandı — Test Edilen Stage 2B Kapsamı       |
| GNSS Çalışma Zamanı Zamanlama Tanıları      | Uygulandı ve Fiziksel Olarak Doğrulandı — Test Edilen Stage 2C Kapsamı |
| GNSS Çalışma Zamanı Zamanlama Karakterizasyonu | Fiziksel Olarak Doğrulandı — Üç Resmî Stage 2C Oturumu          |
| GNSS Koordinat Doğruluğu                    | Doğrulanmadı                                                      |
| GNSS Anchor                                 | Uygulandı ve Fiziksel Olarak Doğrulandı — Stage 3A Çalışma Zamanı Kapsamı |
| WGS84 / Yerel ENU Temeli                    | Uygulandı ve Birim Testlerinden Geçti — Fiziksel Mesafe Doğruluğu Doğrulanmadı |
| GNSS Kesinti Denetleyicisi / Ground Truth Firewall | Yazılım-Tanımlı Tahmin Motoru Kesintisi + Ground Truth Firewall Uygulandı ve Fiziksel Olarak Doğrulandı — Stage 6 Kapsamı; Recovery Uygulanmadı |
| Değerlendirme Modu                          | Uygulandı ve Fiziksel Olarak Doğrulandı — Stage 6 Yapılandırma A Kapsamı; Doğruluk Doğrulanmadı |
| ARCore Çalışma Zamanı Takip Tanıları        | Uygulandı ve Fiziksel Olarak Doğrulandı — Test Edilen Stage 2D Kapsamı |
| ARCore Mesafe / Mutlak Doğruluğu            | Doğrulanmadı                                                      |
| ARCore-to-ENU Dönüşümü                      | Uygulandı ve Fiziksel Olarak Doğrulandı — Stage 5 Kapsamı; Doğruluk Doğrulanmadı |
| PDR                                         | Baseline Konumu Uygulandı ve Fiziksel Olarak Doğrulandı — Doğruluk Doğrulanmadı |
| Handset Heading / Gerçek Kuzey Temeli       | Uygulandı ve Fiziksel Olarak Doğrulandı — Stage 3B Çalışma Zamanı Kapsamı; Mutlak Doğruluk Doğrulanmadı |
| Body Heading / Telefon-Vücut Kalibrasyonu   | Uygulanmadı                                                       |
| Adım Olayı Temeli                           | Uygulandı ve Fiziksel Olarak Doğrulandı — Stage 3C Çalışma Zamanı Kapsamı |
| Adım Algılama Doğruluğu                     | Doğrulanmadı                                                      |
| Adım Uzunluğu / Heading-Adım İlişkilendirmesi | Sabit 0,75 m Baseline + Nedensel İlişkilendirme Uygulandı — Doğruluk Doğrulanmadı |
| Motion AI                                   | Uygulanmadı                                                       |
| Quality Engine                              | Uygulanmadı                                                       |
| EKF / Sensör Füzyonu                        | Uygulanmadı                                                       |
| Test                                        | Stage 1 + Stage 2A + Stage 2B + Stage 2C + Stage 2D + Stage 3A + Stage 3B + Stage 3C + Stage 4 + Stage 5 + Stage 6 Tanımlı Kapsamları Geçti; Güncel 169/169 Test Geçti |
| Saha Deneyleri                              | Kısmi — Yalnızca Kapsamı Belirli Temel Doğrulaması                |
| Nihai Benchmark / Değerlendirme             | Stage 6 Değerlendirme Akışı Çalıştırıldı; Navigasyon Doğruluk Benchmark'ı Doğrulanmadı |

---

### Dokümantasyon Durumu

| Alan                      | Durum              |
| ------------------------- | ------------------ |
| Proje Tanımı              | Tamamlandı         |
| Gereksinimler             | Tamamlandı         |
| Mimari                    | Tamamlandı         |
| Navigasyon Tasarımı       | Tamamlandı         |
| Yapay Zekâ Tasarımı       | Tamamlandı         |
| Test Stratejisi           | Tamamlandı         |
| Deney Planlaması          | Tamamlandı         |
| Değerlendirme Planlaması  | Tamamlandı         |
| Risk ve Sınırlama Analizi | Tamamlandı         |
| Teknik Referanslar        | Tamamlandı         |
| Nihai Deneysel Sonuçlar   | Deneyleri Bekliyor |

---

### Repository Görünürlüğü

**Herkese Açık**

Ham deneysel veriler, hassas konum logları, kimlik bilgileri, gizli bilgiler ve diğer hassas yerel dosyalar version control dışında tutulur.

---

### Mevcut Geliştirme Kuralı

Flutter Android bootstrap, Stage 2A SensorManager çalışma zamanı yetenek envanteri, Stage 2B dört sensörlü canlı zamanlama tanıları, Stage 2C GNSS çalışma zamanı zamanlama tanıları, Stage 2D ARCore çalışma zamanı takip tanıları, Aşama 3A — GNSS Anchor + Yerel ENU Referans Temeli, Aşama 3B — Heading / Gerçek Kuzey Referans Temeli, Aşama 3C — Adım Olayı Temeli, Aşama 4 — Temel PDR, Aşama 5 — ARCore Göreli Hareket → ENU Temeli ve Aşama 6 — Değerlendirme Modu + Ground Truth Güvenlik Duvarı tanımlı kapsamlarında uygulandı ve doğrulandı.

Stage 2B, 20.000 µs talep altında 12 test oturumunda ivmeölçer, jiroskop, manyetometre ve dönüş vektörü için canlı olay iletimini ve timestamp-türevli zamanlama davranışını fiziksel olarak doğruladı. Talep edilen ve gözlenen hızlar ayrı kalır, 60 ms boşluk eşiği geçicidir ve bu sonuçlar sensör gürültüsünü, bias'ı, kalibrasyonu, heading'i veya navigasyon performansını doğrulamaz.

Stage 2C, üç resmî oturumda `Location.elapsedRealtimeNanos` kullanarak `GPS_PROVIDER` callback zamanlamasını fiziksel olarak karakterize etti. Üç oturum da geçerli, monotonik ve mock içermeyen sonuçlar verdi. Talep edilen 1.000 ms minimum aralık gözlenen teslimden ayrı kaldı: medyan ve p95 aralıkları tüm oturumlarda 1,000 s, gözlenen ortalama hız aralığı yaklaşık 0,983–1,000 Hz idi ve ardışık bir 2,000 s aralık gözlendi. Tanımlı bir GNSS boşluk eşiği yoktur. TTFF, uydu sayıları ve yatay doğruluk yalnızca tanısal metadata'dır; GNSS koordinat doğruluğu doğrulanmadı.

Stage 2D, üç resmî oturumda ARCore hazır olma durumunu ve canlı takibi fiziksel olarak doğruladı. Üç oturumun tamamı geçerliydi; gerçek `TrackingState.TRACKING` gözlendi, yerel-oturum pozu sağlandı, monotonik `Frame.timestamp` dizileri kullanıldı, terminal hatası veya `STOPPED` kare olmadan tamamlandı ve oturum oluşturma/yapılandırma/resume ile özel GL/EGL ve kamera texture kurulumu başarıyla çalıştırıldı. Gözlenen benzersiz-kare hızı yaklaşık 30,0295–30,0304 Hz, test edilen oturumlardaki tracking fraction yaklaşık %98,15–%98,36 idi. Tanımlı bir ARCore kare-boşluk eşiği yoktur ve bu değerler evrensel garanti veya navigasyon kalite skoru değildir.

Stage 3A, test edilen cihazda `GPS_PROVIDER` preflight/hazır olma durumunu, üç bağımsız kesinti-öncesi anchor ediniminin 3/3'ünü, açık clear/reacquire ve açık iptal akışını fiziksel olarak doğruladı. Resmî edinim fiziksel ölçüm-zamanı otoritesi olarak `Location.elapsedRealtimeNanos` kullanır: ilk geçerli aday 10 saniyelik pencereyi başlatır, en az üç aday gerekir ve seçim en düşük bildirilen yatay doğruluğu daha yeni ölçüm zaman damgası eşitlik bozucusuyla kullanır. 10 / 11 / 10 adaylı oturumlarda yaklaşık 17,98 / 15,32 / 34,79 m bildirilen doğruluk metadata'sı seçildi. Android tarafından bildirilen bu değerler ölçülmüş ground-truth hatası değildir. Çalışma zamanı anchor'ı açıkça temizlenene kadar değişmezdir ve kalıcılaştırılmaz. WGS84 → ECEF → yerel ENU matematiği uygulandı ve birim testlerinden geçti; yükseklik yokken Up uydurulmadan yatay ENU sağlanır. Paylaşılan resmî loglar sanitize edilmişti ve ham anchor koordinatlarını yazdırmadı.

Stage 3B; `TYPE_ROTATION_VECTOR` çalışma zamanı kullanılabilirliğini ve resmî kullanımını, üç adet 30 saniyelik handset-heading oturumunun 3/3'ünü, `SensorEvent.timestamp` zamanlamasını, monotonik ve duplicate içermeyen zaman damgası dizilerini, saat yönünde pozitif tepkiyi, ardışık ±2π süreksizliği olmadan 2π üzerindeki dairesel birikimi, kilitli-anchor `android.hardware.GeomagneticField` düzeltmesini ve açık iptali fiziksel olarak doğruladı. 20.000 µs nominal talep altında yaklaşık 51,14 Hz teslim gözlendi. Platform geomanyetik modeli, güncelliği bağımsız doğrulanmamış `platform_managed` durumunda kalır; heading-doğruluk metadata'sı test edilen tüm oturumlarda kullanılamıyordu.

Stage 3C, Android 12 / API 31 üzerinde yalnızca `TYPE_STEP_DETECTOR` kullanan resmî adım-olayı yolunu fiziksel olarak doğruladı. Sabit 30 saniyelik oturum sıfır olay kabul etti; kontrollü 20 adımlık yürüyüş 16 olay kabul ederken teslim edilen beş olay resmî pencere dışında bırakıldı; kontrollü 30 adımlık yürüyüş ise 30 olay kabul etti. Yürüyüş oturumlarında duplicate veya monotonik olmayan kabul edilmiş zaman damgası yoktu ve açık iptal geçti. Bunlar sınırlı fiziksel gözlemlerdir ve genel adım-algılama doğruluğunu doğrulamaz.

Stage 4, deterministik baseline-PDR çalışma zamanı yolunu fiziksel olarak doğruladı. Sabit oturum sıfır adım entegre etti; manuel sayılan iki 20-adımlık düz yürüyüşün her biri 20 adım entegre etti; hedeflenen 20-adımlık L-biçimli desen ise algılanan 22 olayı entegre etti. Tüm yürüyüş olayları gelecek heading kullanmadan nedensel olarak ilişkilendirildi ve açık iptal geçti. Düzeltilmiş bağımsız kuzey kontrolü, daha önce fiziksel olarak yanlış tanımlanan yön referansına ilişkin endişeyi çözdü. Bu kapsamlı olmayan gözlemlerden doğruluk yüzdesi veya metrolojik doğruluk iddiası çıkarılmaz.

Stage 5, tanımlı ARCore-to-ENU çalışma zamanı yolunu fiziksel olarak doğruladı. Sabit, bağımsız tanımlanmış kuzey-benzeri, bağımsız tanımlanmış doğu-benzeri ve yaklaşık 90 derecelik yerinde dönüş oturumları tamamlandı; düz-yürüyüş çıktılarında beklenen pozitif ENU eksenleri baskındı, dönüş yer değiştirmesi düz-yürüyüş yer değiştirmelerinden çok daha düşük kaldı ve açık iptal geçti. Tamamlanan tüm resmî oturumlarda gözlenen pencereler boyunca tam kamera takibi bildirildi. Bu gözlemler kapsamı belirli çalışma zamanı akışını ve nitel eksen/işaret davranışını doğrular; metrolojik doğruluğu doğrulamaz.

Stage 6, aynı cihazda Değerlendirme Modu ve Ground Truth Firewall veri akışını fiziksel olarak doğruladı. Sabit oturum kesintili tahmin motoru başlangıcında kaldı. İlk hareketli test, teslim-callback-sırası heading saklama hatasını açığa çıkardı; ardından zaman damgası tamponlama düzeltmesi, 20-manuel-adımlı yeniden testte kabul edilen 11 resmî-pencere adımının tamamı nedensel olarak ilişkilendirilip entegre edildiğinde doğrulandı. Her başarılı oturumda 30 korumalı-GT fix'i kabul edilip eşleştirildi, firewall bayrakları izolasyonu korudu ve açık iptal geçti. Android-bildirilen yüksek korumalı-GNSS belirsizliği, hareketli hata metriklerinin doğrulanmış Yapılandırma A performans kanıtı olmasını engeller.

Fiziksel doğrulama kısmi durumdadır ve cihaz baseline'ı sabitlenmemiştir. PDR doğruluğu, adım-algılama doğruluğu, adım-uzunluğu doğruluğu, heading mutlak doğruluğu, gerçek-kuzey mutlak doğruluğu, korumalı-GNSS ground-truth doğruluğu, GNSS mutlak koordinat doğruluğu, survey-grade anchor niteliği, fiziksel ENU mesafe doğruluğu, aynı-konum anchor tekrarlanabilirliği, ARCore konum/mesafe/dikey doğruluğu ve ENU-hizalama doğruluğu doğrulanmadı. Body heading ve telefon-vücut kalibrasyonu uygulanmadı. ARCore-to-ENU, Değerlendirme Modu, yazılım-tanımlı tahmin motoru kesintisi ve Ground Truth Firewall uygulandı; ancak ARCore/PDR füzyonu, GNSS recovery, Motion AI, Quality Engine, EKF / Sensör Füzyonu, relocalization ve tam GNSS-kesintili navigasyon uygulanmadı. Diğer gerekli cihaz kontrolleri beklemektedir; %20 iyileştirme hedefi ölçülmemiştir ve doğrulanmış navigasyon-doğruluğu benchmark'ı oluşturulmamıştır.

---

### Son Durum Güncellemesi

**2026-09-10**
