# 44 — References & Technical Resources (Referanslar ve Teknik Kaynaklar)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the authoritative technical and academic reference base used to design, implement, verify, evaluate, and document NAVGUARD. *(Bu doküman NAVGUARD'ı tasarlamak, uygulamak, doğrulamak, değerlendirmek ve dokümante etmek için kullanılan authoritative teknik ve akademik reference base'i tanımlar.)*

The objective is not merely to create a bibliography, but to connect each important external source to the specific NAVGUARD subsystem, technical assumption, mathematical method, platform behavior, or research decision that it supports. *(Amaç yalnızca bir bibliography oluşturmak değil, her önemli external source'u desteklediği specific NAVGUARD subsystem, technical assumption, mathematical method, platform behavior veya research decision ile bağlamaktır.)*

---

# 2. Reference Validation Date (Referans Doğrulama Tarihi)

Platform-dependent references in this document were rechecked against currently available official documentation on `2026-09-01`. *(Bu dokümandaki platform-dependent reference'lar `2026-09-01` tarihinde currently available official documentation üzerinden yeniden kontrol edilmiştir.)*

Platform documentation can change after this date, so dependency versions and API behavior must be revalidated again during environment bootstrap and final benchmark freeze. *(Platform documentation bu tarihten sonra değişebileceği için dependency version'ları ve API behavior environment bootstrap ve final benchmark freeze sırasında yeniden validated edilmelidir.)*

---

# 3. Reference Authority Hierarchy (Referans Otorite Hiyerarşisi)

NAVGUARD will prefer primary and authoritative sources whenever they are available. *(NAVGUARD available olduğunda primary ve authoritative source'ları tercih edecektir.)*

The preferred evidence hierarchy is shown below. *(Preferred evidence hierarchy aşağıda gösterilmiştir.)*

```text
LEVEL A — Official Platform / Standards Documentation
(SEVİYE A — Resmî Platform / Standart Dokümantasyonu)

LEVEL B — Original Peer-Reviewed Research / Publisher Source
(SEVİYE B — Orijinal Hakemli Araştırma / Publisher Kaynağı)

LEVEL C — Academic Books / Established Technical Surveys
(SEVİYE C — Akademik Kitaplar / Yerleşik Teknik Survey'ler)

LEVEL D — Reputable Secondary Technical Resources
(SEVİYE D — Güvenilir İkincil Teknik Kaynaklar)

LEVEL E — Blogs / Forums / Community Discussions
(SEVİYE E — Bloglar / Forumlar / Community Discussion'lar)
```

---

# 4. Level A Usage Rule (Seviye A Kullanım Kuralı)

Official Android, Flutter, ARCore, LiteRT, standards-body, and library documentation should be used as the primary source for current API semantics. *(Current API semantic'leri için official Android, Flutter, ARCore, LiteRT, standards-body ve library documentation primary source olarak kullanılmalıdır.)*

---

# 5. Level B Usage Rule (Seviye B Kullanım Kuralı)

Original research papers should be preferred when documenting the theoretical basis or empirical background of PDR, step detection, human-activity recognition, and state estimation. *(PDR, step detection, human-activity recognition ve state estimation'ın theoretical basis veya empirical background'u dokümante edilirken original research paper'lar tercih edilmelidir.)*

---

# 6. Secondary Source Rule (Secondary Source Kuralı)

A secondary source should not override an official API definition or original research publication when the primary source is available. *(Primary source available olduğunda secondary source official API definition veya original research publication'ı override etmemelidir.)*

---

# 7. Version-Sensitive Reference Rule (Version-Sensitive Referans Kuralı)

Any source describing Android, ARCore, LiteRT, Flutter, TensorFlow/Keras, or scikit-learn behavior is considered version-sensitive. *(Android, ARCore, LiteRT, Flutter, TensorFlow/Keras veya scikit-learn behavior tanımlayan herhangi bir source version-sensitive kabul edilir.)*

---

# 8. Benchmark Version Rule (Benchmark Version Kuralı)

The actual versions used by the final benchmark must be stored in the session and build configuration rather than inferred later from this documentation page. *(Final benchmark tarafından kullanılan actual version'lar daha sonra bu documentation page'den inferred edilmek yerine session ve build configuration içerisinde stored edilmelidir.)*

---

# 9. Source Categories (Kaynak Kategorileri)

The NAVGUARD reference library is divided into the following categories. *(NAVGUARD reference library aşağıdaki category'lere ayrılmıştır.)*

```text
A — ANDROID SENSOR & LOCATION PLATFORM
(A — ANDROID SENSOR & LOCATION PLATFORMU)

B — FLUTTER / NATIVE ANDROID INTEGRATION
(B — FLUTTER / NATIVE ANDROID ENTEGRASYONU)

C — ARCORE VISUAL-INERTIAL TRACKING
(C — ARCORE GÖRSEL-ATALETSEL TRACKING)

D — LITERT / ON-DEVICE EDGE AI
(D — LITERT / ON-DEVICE EDGE AI)

E — MACHINE LEARNING & MODEL EVALUATION
(E — MACHINE LEARNING & MODEL EVALUATION)

F — GEODESY, WGS84, ECEF & ENU
(F — JEODEZİ, WGS84, ECEF & ENU)

G — PEDESTRIAN DEAD RECKONING
(G — YAYA DEAD RECKONING)

H — STEP DETECTION & STEP LENGTH
(H — STEP DETECTION & STEP LENGTH)

I — HUMAN ACTIVITY RECOGNITION
(I — HUMAN ACTIVITY RECOGNITION)

J — KALMAN FILTERING & STATE ESTIMATION
(J — KALMAN FILTERING & STATE ESTIMATION)

K — STORAGE, REPLAY & REPRODUCIBILITY
(K — STORAGE, REPLAY & REPRODUCIBILITY)

L — NAVGUARD INTERNAL TECHNICAL EVIDENCE
(L — NAVGUARD INTERNAL TECHNICAL EVIDENCE)
```

---

# 10. Reference ID Convention (Referans ID Convention)

Each external reference is assigned a stable NAVGUARD reference identifier. *(Her external reference stable NAVGUARD reference identifier alır.)*

```text
ANDROID-XX
FLUTTER-XX
ARCORE-XX
LITERT-XX
ML-XX
GEO-XX
PDR-XX
STEP-XX
HAR-XX
KF-XX
DATA-XX
```

---

# 11. Citation Use in Future Pages (Gelecek Sayfalarda Citation Kullanımı)

Future revisions should reference the stable NAVGUARD reference identifier together with the formal bibliographic source when practical. *(Future revision'lar practical olduğunda formal bibliographic source ile birlikte stable NAVGUARD reference identifier'ı kullanmalıdır.)*

---

# 12. Android Platform Reference Group (Android Platform Referans Grubu)

The Android platform documentation is the primary reference for sensor coordinate systems, timestamps, GNSS APIs, permissions, and geomagnetic utilities. *(Android platform documentation sensor coordinate system'leri, timestamp'ler, GNSS API'leri, permission'lar ve geomagnetic utility'ler için primary reference'tır.)*

---

# 13. ANDROID-01 — Sensors Overview (ANDROID-01 — Sensors Overview)

**Source:** Android Developers — *Sensors Overview*. *(Kaynak: Android Developers — Sensors Overview.)*

Android defines a standard device-relative three-axis sensor coordinate system in which X points right, Y points upward, and Z points outward from the screen in the device's natural orientation. *(Android, device natural orientation içerisindeyken X'in sağa, Y'nin yukarı ve Z'nin ekranın dışına doğru baktığı standard device-relative three-axis sensor coordinate system tanımlar.)*

**NAVGUARD relevance:** Device-frame accelerometer, gyroscope, and magnetometer interpretation. *(NAVGUARD ilişkisi: Device-frame accelerometer, gyroscope ve magnetometer interpretation.)*

---

# 14. ANDROID-01 Decision Support (ANDROID-01 Karar Desteği)

ANDROID-01 supports the rule that Android sensor axes must never be assumed to equal NAVGUARD ENU axes directly. *(ANDROID-01 Android sensor axis'lerinin NAVGUARD ENU axis'lerine directly equal olduğunun hiçbir zaman assumed edilmemesi kuralını destekler.)*

---

# 15. ANDROID-02 — SensorEvent Timestamp (ANDROID-02 — SensorEvent Timestamp)

**Source:** Android Developers — `SensorEvent`. *(Kaynak: Android Developers — `SensorEvent`.)*

Android documents `SensorEvent.timestamp` in nanoseconds and states that events for a given sensor should be monotonically increasing using the same time base as `SystemClock.elapsedRealtimeNanos()`. *(Android `SensorEvent.timestamp` değerini nanosecond olarak tanımlar ve given sensor için event'lerin `SystemClock.elapsedRealtimeNanos()` ile aynı time base'i kullanarak monotonically increasing olması gerektiğini belirtir.)*

---

# 16. ANDROID-02 Decision Support (ANDROID-02 Karar Desteği)

ANDROID-02 directly supports NAVGUARD's use of monotonic sensor timestamps as the authoritative timing source for IMU ordering. *(ANDROID-02 NAVGUARD'ın IMU ordering için monotonic sensor timestamp'leri authoritative timing source olarak kullanmasını doğrudan destekler.)*

---

# 17. ANDROID-03 — SensorEventListener (ANDROID-03 — SensorEventListener)

**Source:** Android Developers — `SensorEventListener`. *(Kaynak: Android Developers — `SensorEventListener`.)*

Android notes that a sensor callback can occur even when the measured values remain equal because a new reading with a newer timestamp has arrived. *(Android measured value'lar equal kalsa bile newer timestamp'e sahip new reading geldiği için sensor callback oluşabileceğini belirtir.)*

---

# 18. ANDROID-03 Decision Support (ANDROID-03 Karar Desteği)

NAVGUARD must therefore treat timestamp progression rather than value changes alone as evidence that a sensor stream is alive. *(Bu nedenle NAVGUARD sensor stream'in alive olduğuna dair evidence olarak yalnızca value change yerine timestamp progression'ı kullanmalıdır.)*

---

# 19. ANDROID-04 — Motion Sensors (ANDROID-04 — Motion Sensors)

**Source:** Android Developers — *Motion Sensors*. *(Kaynak: Android Developers — Motion Sensors.)*

Android defines gyroscope output as angular velocity around the device axes in radians per second. *(Android gyroscope output'unu device axis'leri etrafındaki angular velocity olarak radian per second biriminde tanımlar.)*

---

# 20. ANDROID-04 Decision Support (ANDROID-04 Karar Desteği)

ANDROID-04 supports the use of gyroscope measurements for short-term heading propagation and rotational motion features. *(ANDROID-04 gyroscope measurement'larının short-term heading propagation ve rotational motion feature'ları için kullanılmasını destekler.)*

---

# 21. ANDROID-05 — Rotation Vector Sensor (ANDROID-05 — Rotation Vector Sensörü)

**Source:** Android Developers — *Motion Sensors / Position Sensors*. *(Kaynak: Android Developers — Motion Sensors / Position Sensors.)*

Android's Rotation Vector represents device orientation using rotation-vector components related to a unit quaternion and provides a world-oriented reference frame. *(Android Rotation Vector, device orientation'ı unit quaternion ile ilişkili rotation-vector component'leri kullanarak represent eder ve world-oriented reference frame sağlar.)*

---

# 22. ANDROID-05 Decision Support (ANDROID-05 Karar Desteği)

Rotation Vector remains a high-priority heading candidate, but NAVGUARD will still audit its physical behavior on the target device. *(Rotation Vector high-priority heading candidate olarak kalır ancak NAVGUARD target device üzerindeki physical behavior'ını yine de audit edecektir.)*

---

# 23. ANDROID-06 — SensorManager Rotation Utilities (ANDROID-06 — SensorManager Rotation Utility'leri)

**Source:** Android Developers — `SensorManager`. *(Kaynak: Android Developers — `SensorManager`.)*

`SensorManager.getRotationMatrixFromVector()` provides the standard Android conversion from a rotation vector to a rotation matrix. *(`SensorManager.getRotationMatrixFromVector()` rotation vector'den rotation matrix'e standard Android conversion sağlar.)*

---

# 24. ANDROID-06 Decision Support (ANDROID-06 Karar Desteği)

This API may be used during heading and coordinate-frame conversion instead of reimplementing the Android rotation-vector convention without justification. *(Bu API heading ve coordinate-frame conversion sırasında Android rotation-vector convention'ı justification olmadan yeniden implement etmek yerine kullanılabilir.)*

---

# 25. ANDROID-07 — GeomagneticField (ANDROID-07 — GeomagneticField)

**Source:** Android Developers — `GeomagneticField`. *(Kaynak: Android Developers — `GeomagneticField`.)*

Android provides `GeomagneticField.getDeclination()` to estimate the horizontal magnetic-field declination relative to true north at a geographic position and time. *(Android geographic position ve time için horizontal magnetic-field declination'ı true north'a relative olarak estimate etmek üzere `GeomagneticField.getDeclination()` sağlar.)*

---

# 26. ANDROID-07 Decision Support (ANDROID-07 Karar Desteği)

ANDROID-07 supports NAVGUARD's magnetic-to-true-north declination correction. *(ANDROID-07 NAVGUARD'ın magnetic-to-true-north declination correction'ını destekler.)*

---

# 27. ANDROID-07 Implementation Caution (ANDROID-07 Implementation Uyarısı)

The geomagnetic model used internally by Android may evolve across platform releases, so the final build should record the Android version rather than assuming one fixed model forever. *(Android tarafından internally kullanılan geomagnetic model platform release'leri arasında evolve edebileceği için final build one fixed model'i forever assume etmek yerine Android version'ı kaydetmelidir.)*

---

# 28. ANDROID-08 — LocationManager (ANDROID-08 — LocationManager)

**Source:** Android Developers — `LocationManager`. *(Kaynak: Android Developers — `LocationManager`.)*

Android defines `GPS_PROVIDER` as the standard GNSS location provider and notes that `FUSED_PROVIDER`, where present, may combine inputs from multiple location providers. *(Android `GPS_PROVIDER`'ı standard GNSS location provider olarak tanımlar ve `FUSED_PROVIDER` mevcut olduğunda multiple location provider'dan input combine edebileceğini belirtir.)*

---

# 29. ANDROID-08 Decision Support (ANDROID-08 Karar Desteği)

ANDROID-08 directly supports NAVGUARD's decision to use `GPS_PROVIDER` as the formal GNSS source instead of a fused provider for Evaluation Mode reference logging. *(ANDROID-08 NAVGUARD'ın Evaluation Mode reference logging için fused provider yerine `GPS_PROVIDER`'ı formal GNSS source olarak kullanma kararını doğrudan destekler.)*

---

# 30. ANDROID-09 — Location Elapsed Realtime (ANDROID-09 — Location Elapsed Realtime)

**Source:** Android Developers — `Location.getElapsedRealtimeNanos()`. *(Kaynak: Android Developers — `Location.getElapsedRealtimeNanos()`.)*

Android states that `Location.getElapsedRealtimeNanos()` represents the fix time in nanoseconds since boot, is monotonic, and can reliably be compared with `SystemClock.elapsedRealtimeNanos()` within the same boot cycle. *(Android `Location.getElapsedRealtimeNanos()` değerinin boot'tan itibaren nanosecond cinsinden fix time'ı represent ettiğini, monotonic olduğunu ve same boot cycle içerisinde `SystemClock.elapsedRealtimeNanos()` ile reliably compare edilebildiğini belirtir.)*

---

# 31. ANDROID-09 Decision Support (ANDROID-09 Karar Desteği)

ANDROID-09 is the primary platform reference for NAVGUARD's authoritative GNSS measurement timestamp. *(ANDROID-09 NAVGUARD'ın authoritative GNSS measurement timestamp'i için primary platform reference'tır.)*

---

# 32. ANDROID-10 — GNSS Status (ANDROID-10 — GNSS Status)

**Source:** Android Developers — `GnssStatus`. *(Kaynak: Android Developers — `GnssStatus`.)*

Android exposes satellite status information and elapsed-realtime timing that can be used for optional GNSS diagnostics. *(Android optional GNSS diagnostic'leri için kullanılabilecek satellite status information ve elapsed-realtime timing expose eder.)*

---

# 33. ANDROID-10 Decision Support (ANDROID-10 Karar Desteği)

GNSS satellite diagnostics may support quality analysis but are not required to become estimator inputs during denied Evaluation Mode. *(GNSS satellite diagnostic'leri quality analysis'i destekleyebilir ancak denied Evaluation Mode sırasında estimator input'u olmak zorunda değildir.)*

---

# 34. ANDROID-11 — Location Permissions (ANDROID-11 — Location Permission'ları)

**Source:** Android Developers — *Request Location Permissions*. *(Kaynak: Android Developers — Request Location Permissions.)*

Android distinguishes foreground versus background location and precise versus approximate location access. *(Android foreground versus background location ile precise versus approximate location access arasında ayrım yapar.)*

---

# 35. ANDROID-11 Decision Support (ANDROID-11 Karar Desteği)

NAVGUARD's formal GNSS anchor and Evaluation Mode reference require precise location access rather than silently accepting an approximate-only mode. *(NAVGUARD'ın formal GNSS anchor ve Evaluation Mode reference'ı approximate-only mode'u silently accept etmek yerine precise location access gerektirir.)*

---

# 36. ANDROID-12 — Runtime Location Permission Behavior (ANDROID-12 — Runtime Location Permission Behavior)

**Source:** Android Developers — *Request Location Access at Runtime*. *(Kaynak: Android Developers — Request Location Access at Runtime.)*

Android 12 and later allow the user to grant approximate location even when an application requests fine location. *(Android 12 ve later, application fine location request etse bile user'ın approximate location vermesine izin verir.)*

---

# 37. ANDROID-12 Decision Support (ANDROID-12 Karar Desteği)

NAVGUARD must verify the actual granted permission level before enabling formal GNSS-dependent workflows. *(NAVGUARD formal GNSS-dependent workflow'ları enable etmeden önce actual granted permission level'ı verify etmelidir.)*

---

# 38. Flutter Integration Reference Group (Flutter Integration Referans Grubu)

Flutter official documentation is used to support the separation between Dart UI/orchestration and Kotlin platform-specific functionality. *(Flutter official documentation Dart UI/orchestration ile Kotlin platform-specific functionality arasındaki separation'ı desteklemek için kullanılır.)*

---

# 39. FLUTTER-01 — Platform Channels (FLUTTER-01 — Platform Channel'ları)

**Source:** Flutter Documentation — *Writing Custom Platform-Specific Code*. *(Kaynak: Flutter Documentation — Writing Custom Platform-Specific Code.)*

Flutter supports asynchronous platform-channel communication between Dart and native Android Kotlin/Java implementations. *(Flutter Dart ile native Android Kotlin/Java implementation arasında asynchronous platform-channel communication destekler.)*

---

# 40. FLUTTER-01 Decision Support (FLUTTER-01 Karar Desteği)

FLUTTER-01 supports NAVGUARD's Flutter/Kotlin hybrid architecture. *(FLUTTER-01 NAVGUARD'ın Flutter/Kotlin hybrid architecture'ını destekler.)*

---

# 41. FLUTTER-02 — Platform Channel Threading (FLUTTER-02 — Platform Channel Threading)

**Source:** Flutter Documentation — *Platform Channel Threading*. *(Kaynak: Flutter Documentation — Platform Channel Threading.)*

Flutter documents task-queue and background-thread mechanisms for platform-side handlers while maintaining required UI-thread behavior for channel calls that target Flutter. *(Flutter, Flutter'ı target eden channel call'lar için required UI-thread behavior'ı korurken platform-side handler'lar için task-queue ve background-thread mechanism'lerini document eder.)*

---

# 42. FLUTTER-02 Decision Support (FLUTTER-02 Karar Desteği)

Time-critical sensor acquisition, inference, and disk writing should therefore not be forced through Flutter's UI execution path. *(Bu nedenle time-critical sensor acquisition, inference ve disk writing Flutter'ın UI execution path'i üzerinden forced edilmemelidir.)*

---

# 43. FLUTTER-03 — Flutter Android Integration (FLUTTER-03 — Flutter Android Entegrasyonu)

**Source:** Flutter Documentation — Android platform integration. *(Kaynak: Flutter Documentation — Android platform integration.)*

The current Flutter documentation explicitly supports Android-specific native integration and Kotlin host code. *(Current Flutter documentation Android-specific native integration ve Kotlin host code'u explicitly destekler.)*

---

# 44. ARCore Reference Group (ARCore Referans Grubu)

Google's ARCore documentation is the authoritative platform source for tracking state, pose semantics, coordinate conventions, device support, and frame timing. *(Google'ın ARCore documentation'ı tracking state, pose semantic'leri, coordinate convention'lar, device support ve frame timing için authoritative platform source'tur.)*

---

# 45. ARCORE-01 — Supported Devices (ARCORE-01 — Supported Devices)

**Source:** Google for Developers — *ARCore Supported Devices*. *(Kaynak: Google for Developers — ARCore Supported Devices.)*

The official supported-device list currently includes the Xiaomi Redmi Note 9 Pro. *(Official supported-device list currently Xiaomi Redmi Note 9 Pro'yu içerir.)*

---

# 46. ARCORE-01 Decision Support (ARCORE-01 Karar Desteği)

ARCORE-01 supports retaining ARCore as a realistic target-device enhancement for NAVGUARD. *(ARCORE-01 ARCore'un NAVGUARD için realistic target-device enhancement olarak retained edilmesini destekler.)*

---

# 47. ARCORE-01 Physical Audit Rule (ARCORE-01 Fiziksel Audit Kuralı)

Published support does not replace the physical runtime audit on the actual project phone. *(Published support actual project phone üzerindeki physical runtime audit'in yerini almaz.)*

---

# 48. ARCORE-02 — TrackingState (ARCORE-02 — TrackingState)

**Source:** Google ARCore — `TrackingState`. *(Kaynak: Google ARCore — `TrackingState`.)*

ARCore defines `TRACKING` as current valid tracking, `PAUSED` as temporarily paused tracking whose properties may be inaccurate, and `STOPPED` as permanently stopped tracking. *(ARCore `TRACKING`'i current valid tracking, `PAUSED`'ı property'leri inaccurate olabilecek temporarily paused tracking ve `STOPPED`'ı permanently stopped tracking olarak tanımlar.)*

---

# 49. ARCORE-02 Decision Support (ARCORE-02 Karar Desteği)

ARCORE-02 directly supports the rule that only `TRACKING` poses may enter formal NAVGUARD fusion. *(ARCORE-02 yalnızca `TRACKING` pose'larının formal NAVGUARD fusion'a girebilmesi kuralını doğrudan destekler.)*

---

# 50. ARCORE-03 — Camera Pose (ARCORE-03 — Camera Pose)

**Source:** Google ARCore — `Camera.getPose()`. *(Kaynak: Google ARCore — `Camera.getPose()`.)*

ARCore's physical-camera pose uses a right-handed OpenGL-style camera coordinate convention with `+X` to the right, `+Y` upward, and `-Z` in the viewing direction. *(ARCore'un physical-camera pose'u `+X` sağa, `+Y` yukarı ve `-Z` viewing direction olacak şekilde right-handed OpenGL-style camera coordinate convention kullanır.)*

---

# 51. ARCORE-03 Decision Support (ARCORE-03 Karar Desteği)

ARCORE-03 is a primary reference for the rule that ARCore axes cannot be hardcoded as East, North, and Up. *(ARCORE-03 ARCore axis'lerinin East, North ve Up olarak hardcode edilememesi kuralı için primary reference'tır.)*

---

# 52. ARCORE-04 — Pose Semantics (ARCORE-04 — Pose Semantics)

**Source:** Google ARCore — `Pose`. *(Kaynak: Google ARCore — `Pose`.)*

ARCore `Pose` represents an immutable rigid transform using a quaternion rotation and translation in meters in a right-handed coordinate system. *(ARCore `Pose`, right-handed coordinate system içerisinde quaternion rotation ve meter biriminde translation kullanarak immutable rigid transform represent eder.)*

---

# 53. ARCORE-04 Decision Support (ARCORE-04 Karar Desteği)

ARCORE-04 supports explicit quaternion adaptation and transform-based ARCore-to-ENU alignment. *(ARCORE-04 explicit quaternion adaptation ve transform-based ARCore-to-ENU alignment'ı destekler.)*

---

# 54. ARCORE-05 — World Coordinates and Anchors (ARCORE-05 — World Coordinate'ları ve Anchor'lar)

**Source:** Google ARCore — `Pose` and `Anchor`. *(Kaynak: Google ARCore — `Pose` ve `Anchor`.)*

ARCore documentation warns that world-space numerical poses may adjust as ARCore improves its understanding of the environment, while anchors provide persistent tracked references. *(ARCore documentation ARCore environment understanding'ini improve ettikçe world-space numerical pose'ların adjust olabileceğini ve anchor'ların persistent tracked reference sağladığını belirtir.)*

---

# 55. ARCORE-05 Decision Support (ARCORE-05 Karar Desteği)

This supports NAVGUARD's local segment and anchor-relative ARCore design rather than assuming an immutable global visual coordinate system. *(Bu source immutable global visual coordinate system assume etmek yerine NAVGUARD'ın local segment ve anchor-relative ARCore design'ını destekler.)*

---

# 56. ARCORE-06 — Frame Timestamp (ARCORE-06 — Frame Timestamp)

**Source:** Google ARCore — `Frame.getTimestamp()`. *(Kaynak: Google ARCore — `Frame.getTimestamp()`.)*

ARCore states that `Frame.getTimestamp()` is in nanoseconds but explicitly does not define its time base. *(ARCore `Frame.getTimestamp()` değerinin nanosecond olduğunu ancak time base'ini explicitly define etmediğini belirtir.)*

---

# 57. ARCORE-06 Decision Support (ARCORE-06 Karar Desteği)

ARCORE-06 directly justifies NAVGUARD's decision not to assume that `Frame.getTimestamp()` is identical to `SystemClock.elapsedRealtimeNanos()`. *(ARCORE-06 NAVGUARD'ın `Frame.getTimestamp()` ile `SystemClock.elapsedRealtimeNanos()` değerlerinin identical olduğunu assume etmeme kararını doğrudan justify eder.)*

---

# 58. ARCORE-07 — Android Camera Timestamp (ARCORE-07 — Android Camera Timestamp)

**Source:** Google ARCore — `Frame.getAndroidCameraTimestamp()`. *(Kaynak: Google ARCore — `Frame.getAndroidCameraTimestamp()`.)*

ARCore separately exposes an Android camera timestamp for the frame's image. *(ARCore frame image için ayrıca Android camera timestamp expose eder.)*

---

# 59. ARCORE-07 Decision Support (ARCORE-07 Karar Desteği)

NAVGUARD may investigate this timestamp together with Android camera timestamp-source metadata when validating cross-clock synchronization. *(NAVGUARD cross-clock synchronization'ı validate ederken bu timestamp'i Android camera timestamp-source metadata ile birlikte investigate edebilir.)*

---

# 60. ARCORE-08 — Android Camera Timestamp Source (ARCORE-08 — Android Camera Timestamp Source)

**Source:** Android Camera2 — `CaptureResult.SENSOR_TIMESTAMP`. *(Kaynak: Android Camera2 — `CaptureResult.SENSOR_TIMESTAMP`.)*

Android documents that camera timestamps are comparable with `elapsedRealtimeNanos()` only when the camera reports a `REALTIME` timestamp source; otherwise the starting point may be unspecified. *(Android camera `REALTIME` timestamp source report ettiğinde camera timestamp'lerinin `elapsedRealtimeNanos()` ile comparable olduğunu, aksi durumda starting point'in unspecified olabileceğini document eder.)*

---

# 61. ARCORE-08 Decision Support (ARCORE-08 Karar Desteği)

Cross-domain camera and IMU synchronization must therefore be experimentally validated rather than inferred from units alone. *(Bu nedenle cross-domain camera ve IMU synchronization yalnızca unit'lerden inferred edilmek yerine experimentally validated edilmelidir.)*

---

# 62. LiteRT Reference Group (LiteRT Referans Grubu)

Google AI Edge documentation is the authoritative current source for NAVGUARD's neural on-device deployment path. *(Google AI Edge documentation NAVGUARD'ın neural on-device deployment path'i için authoritative current source'tur.)*

---

# 63. LITERT-01 — LiteRT Overview (LITERT-01 — LiteRT Overview)

**Source:** Google AI Edge — *LiteRT Overview*. *(Kaynak: Google AI Edge — LiteRT Overview.)*

Current LiteRT documentation describes LiteRT as Google's framework for on-device machine-learning deployment and identifies the newer `CompiledModel` API as the modern high-performance runtime interface. *(Current LiteRT documentation LiteRT'i Google's on-device machine-learning deployment framework'ü olarak tanımlar ve newer `CompiledModel` API'yi modern high-performance runtime interface olarak identify eder.)*

---

# 64. LITERT-02 — LiteRT Android (LITERT-02 — LiteRT Android)

**Source:** Google AI Edge — *LiteRT for Android*. *(Kaynak: Google AI Edge — LiteRT for Android.)*

Google currently documents both `CompiledModel` and the backward-compatible `Interpreter` API for Android. *(Google currently Android için hem `CompiledModel` hem backward-compatible `Interpreter` API'yi document eder.)*

---

# 65. LITERT-02 Decision Support (LITERT-02 Karar Desteği)

NAVGUARD will prefer `CompiledModel` for new Kotlin integration while retaining the `Interpreter` path as a compatibility fallback if project constraints require it. *(NAVGUARD new Kotlin integration için `CompiledModel`'ı prefer edecek ancak project constraint'ler gerektirirse `Interpreter` path'ini compatibility fallback olarak retained edecektir.)*

---

# 66. LITERT-03 — CompiledModel Kotlin API (LITERT-03 — CompiledModel Kotlin API)

**Source:** Google AI Edge — *LiteRT CompiledModel Kotlin API*. *(Kaynak: Google AI Edge — LiteRT CompiledModel Kotlin API.)*

The current Kotlin API documentation provides direct Android model loading, hardware selection, input/output buffer creation, and inference through `CompiledModel`. *(Current Kotlin API documentation `CompiledModel` üzerinden direct Android model loading, hardware selection, input/output buffer creation ve inference sağlar.)*

---

# 67. LITERT-03 Dependency Rule (LITERT-03 Dependency Kuralı)

The exact LiteRT Maven version must be selected during environment bootstrap rather than frozen permanently in this pre-development document. *(Exact LiteRT Maven version bu pre-development document içerisinde permanently frozen edilmek yerine environment bootstrap sırasında selected edilmelidir.)*

---

# 68. LITERT-04 — Migration Guidance (LITERT-04 — Migration Guidance)

**Source:** Google AI Edge — *Migrate to LiteRT from TensorFlow Lite*. *(Kaynak: Google AI Edge — Migrate to LiteRT from TensorFlow Lite.)*

Google's current migration guidance recommends the v2 `CompiledModel` API for new work while retaining an `Interpreter` migration path for compatibility. *(Google'ın current migration guidance'ı compatibility için `Interpreter` migration path'ini retained ederken new work için v2 `CompiledModel` API'yi recommend eder.)*

---

# 69. LITERT-05 — Model Conversion (LITERT-05 — Model Conversion)

**Source:** Google AI Edge — `TFLiteConverter`. *(Kaynak: Google AI Edge — `TFLiteConverter`.)*

Google documents conversion of TensorFlow or Keras models into `.tflite` artifacts using `TFLiteConverter`. *(Google TensorFlow veya Keras model'larının `TFLiteConverter` kullanılarak `.tflite` artifact'larına conversion'ını document eder.)*

---

# 70. LITERT-05 Decision Support (LITERT-05 Karar Desteği)

LITERT-05 supports NAVGUARD's training → conversion → parity validation → Android deployment chain. *(LITERT-05 NAVGUARD'ın training → conversion → parity validation → Android deployment chain'ini destekler.)*

---

# 71. LITERT-06 — CPU / GPU / NPU Strategy (LITERT-06 — CPU / GPU / NPU Stratejisi)

**Source:** Google AI Edge — LiteRT Android acceleration documentation. *(Kaynak: Google AI Edge — LiteRT Android acceleration documentation.)*

LiteRT supports hardware acceleration, but accelerator availability and benefit depend on model, runtime, and device capabilities. *(LiteRT hardware acceleration destekler ancak accelerator availability ve benefit model, runtime ve device capability'lerine bağlıdır.)*

---

# 72. LITERT-06 Decision Support (LITERT-06 Karar Desteği)

NAVGUARD therefore keeps CPU as the benchmark baseline and promotes GPU or NPU only after measured device benefit. *(Bu nedenle NAVGUARD CPU'yu benchmark baseline olarak tutar ve GPU veya NPU'yu yalnızca measured device benefit sonrasında promote eder.)*

---

# 73. LITERT-07 — Benchmark Tooling (LITERT-07 — Benchmark Tooling)

**Source:** Google AI Edge — *Benchmark CompiledModel API*. *(Kaynak: Google AI Edge — Benchmark CompiledModel API.)*

LiteRT's benchmark tooling distinguishes initialization, warm-up, steady-state inference, and memory measurements. *(LiteRT benchmark tooling initialization, warm-up, steady-state inference ve memory measurement'ları arasında ayrım yapar.)*

---

# 74. LITERT-07 Decision Support (LITERT-07 Karar Desteği)

This supports NAVGUARD's decision to report model load time, warm-up, median inference, P95 inference, and end-to-end context latency separately. *(Bu source NAVGUARD'ın model load time, warm-up, median inference, P95 inference ve end-to-end context latency'yi separately report etme kararını destekler.)*

---

# 75. Machine Learning Reference Group (Machine Learning Referans Grubu)

scikit-learn and Keras documentation provide implementation references for grouped evaluation, baseline models, metrics, and the lightweight 1D-CNN candidate. *(scikit-learn ve Keras documentation grouped evaluation, baseline model'lar, metric'ler ve lightweight 1D-CNN candidate için implementation reference sağlar.)*

---

# 76. ML-01 — GroupKFold (ML-01 — GroupKFold)

**Source:** scikit-learn — `GroupKFold`. *(Kaynak: scikit-learn — `GroupKFold`.)*

`GroupKFold` provides non-overlapping groups across cross-validation folds. *(`GroupKFold` cross-validation fold'ları arasında non-overlapping group'lar sağlar.)*

---

# 77. ML-01 Decision Support (ML-01 Karar Desteği)

ML-01 supports using physical session IDs as grouping variables when group-aware cross-validation is needed. *(ML-01 group-aware cross-validation gerektiğinde physical session ID'lerinin grouping variable olarak kullanılmasını destekler.)*

---

# 78. ML-02 — StratifiedGroupKFold (ML-02 — StratifiedGroupKFold)

**Source:** scikit-learn — `StratifiedGroupKFold`. *(Kaynak: scikit-learn — `StratifiedGroupKFold`.)*

`StratifiedGroupKFold` attempts to preserve class proportions while keeping groups non-overlapping between folds. *(`StratifiedGroupKFold` group'ları fold'lar arasında non-overlapping tutarken class proportion'ları preserve etmeye çalışır.)*

---

# 79. ML-02 Decision Support (ML-02 Karar Desteği)

This is suitable for NAVGUARD development cross-validation when motion-class balance and physical-session isolation must both be respected. *(Bu yaklaşım motion-class balance ve physical-session isolation'ın birlikte respected edilmesi gerektiğinde NAVGUARD development cross-validation için suitable'dır.)*

---

# 80. ML-03 — Grouped Cross-Validation Guidance (ML-03 — Grouped Cross-Validation Guidance)

**Source:** scikit-learn — *Cross-validation: Evaluating Estimator Performance*. *(Kaynak: scikit-learn — Cross-validation: Evaluating Estimator Performance.)*

scikit-learn explicitly notes that dependent samples grouped by a common source should be separated so groups in validation do not also appear in training. *(scikit-learn common source tarafından grouped dependent sample'ların validation'daki group'lar training'de de appear etmeyecek şekilde separated edilmesi gerektiğini explicitly belirtir.)*

---

# 81. ML-03 Decision Support (ML-03 Karar Desteği)

ML-03 reinforces NAVGUARD's prohibition on random overlapping-window train/test splitting. *(ML-03 NAVGUARD'ın random overlapping-window train/test splitting prohibition'ını reinforce eder.)*

---

# 82. ML-04 — F1 Score (ML-04 — F1 Score)

**Source:** scikit-learn — `f1_score`. *(Kaynak: scikit-learn — `f1_score`.)*

scikit-learn defines F1 as the harmonic mean of precision and recall and supports multiclass averaging strategies. *(scikit-learn F1'ı precision ve recall'un harmonic mean'i olarak tanımlar ve multiclass averaging strategy'lerini destekler.)*

---

# 83. ML-04 Decision Support (ML-04 Karar Desteği)

NAVGUARD's Motion Classification primary metric uses Macro F1 so each retained motion class contributes equally to the aggregate class-level score. *(NAVGUARD'ın Motion Classification primary metric'i Macro F1 kullanır; böylece retained her motion class aggregate class-level score'a equally contribute eder.)*

---

# 84. ML-05 — Random Forest (ML-05 — Random Forest)

**Source:** scikit-learn — ensemble API / `RandomForestClassifier` and `RandomForestRegressor`. *(Kaynak: scikit-learn — ensemble API / `RandomForestClassifier` ve `RandomForestRegressor`.)*

scikit-learn provides Random Forest implementations for both classification and regression. *(scikit-learn hem classification hem regression için Random Forest implementation sağlar.)*

---

# 85. ML-05 Decision Support (ML-05 Karar Desteği)

Random Forest remains the primary nonlinear classical baseline for Motion Classification and a principal candidate for learned step-length regression. *(Random Forest Motion Classification için primary nonlinear classical baseline ve learned step-length regression için principal candidate olarak kalır.)*

---

# 86. ML-06 — Keras Conv1D (ML-06 — Keras Conv1D)

**Source:** Keras — `Conv1D`. *(Kaynak: Keras — `Conv1D`.)*

Keras defines `Conv1D` as a convolution over one spatial or temporal dimension with inputs commonly represented as `(batch, steps, features)`. *(Keras `Conv1D`'yi one spatial veya temporal dimension üzerinde convolution olarak tanımlar ve input'lar commonly `(batch, steps, features)` şeklinde represent edilir.)*

---

# 87. ML-06 Decision Support (ML-06 Karar Desteği)

ML-06 directly supports NAVGUARD's `B × T × C` motion-classification tensor and lightweight temporal 1D-CNN candidate. *(ML-06 NAVGUARD'ın `B × T × C` motion-classification tensor'ını ve lightweight temporal 1D-CNN candidate'ını doğrudan destekler.)*

---

# 88. ML-07 — GlobalAveragePooling1D (ML-07 — GlobalAveragePooling1D)

**Source:** Keras — `GlobalAveragePooling1D`. *(Kaynak: Keras — `GlobalAveragePooling1D`.)*

Keras provides global average pooling for temporal representations. *(Keras temporal representation'lar için global average pooling sağlar.)*

---

# 89. ML-07 Decision Support (ML-07 Karar Desteği)

ML-07 supports the compact candidate architecture that converts temporal convolution features into a fixed-size representation before dense classification. *(ML-07 temporal convolution feature'larını dense classification öncesinde fixed-size representation'a convert eden compact candidate architecture'ı destekler.)*

---

# 90. ML-08 — Adam Optimizer (ML-08 — Adam Optimizer)

**Source:** TensorFlow/Keras — `tf.keras.optimizers.Adam`. *(Kaynak: TensorFlow/Keras — `tf.keras.optimizers.Adam`.)*

TensorFlow provides Adam as an adaptive stochastic-gradient optimizer and currently documents a default learning rate of `0.001`. *(TensorFlow Adam'ı adaptive stochastic-gradient optimizer olarak sağlar ve currently default learning rate'i `0.001` olarak document eder.)*

---

# 91. ML-08 Decision Support (ML-08 Karar Desteği)

Adam with an initial learning-rate candidate near `1e-3` is therefore a reasonable development starting point but not a frozen final hyperparameter. *(Bu nedenle initial learning-rate candidate yaklaşık `1e-3` olan Adam reasonable development starting point'tir ancak frozen final hyperparameter değildir.)*

---

# 92. ML-09 — Early Stopping (ML-09 — Early Stopping)

**Source:** TensorFlow/Keras — `EarlyStopping`. *(Kaynak: TensorFlow/Keras — `EarlyStopping`.)*

Keras provides validation-monitored early stopping with configurable patience and optional restoration of best weights. *(Keras configurable patience ve optional best-weight restoration ile validation-monitored early stopping sağlar.)*

---

# 93. ML-09 Decision Support (ML-09 Karar Desteği)

NAVGUARD may use early stopping on validation evidence while keeping the final test set untouched. *(NAVGUARD final test set'i untouched tutarken validation evidence üzerinde early stopping kullanabilir.)*

---

# 94. Geodesy Reference Group (Jeodezi Referans Grubu)

Geodetic references support NAVGUARD's WGS84 anchor, ECEF conversion, local ENU frame, and horizontal position-error calculations. *(Geodetic reference'lar NAVGUARD'ın WGS84 anchor, ECEF conversion, local ENU frame ve horizontal position-error calculation'larını destekler.)*

---

# 95. GEO-01 — WGS84 (GEO-01 — WGS84)

**Source:** United States National Geospatial-Intelligence Agency — WGS 84 resources. *(Kaynak: United States National Geospatial-Intelligence Agency — WGS 84 resources.)*

NGA describes WGS84 as a three-dimensional global coordinate reference frame for latitude, longitude, heights, positioning, and navigation. *(NGA WGS84'ü latitude, longitude, height, positioning ve navigation için three-dimensional global coordinate reference frame olarak tanımlar.)*

---

# 96. GEO-01 Decision Support (GEO-01 Karar Desteği)

GEO-01 supports NAVGUARD's use of WGS84 for global GNSS anchors and derived map coordinates. *(GEO-01 NAVGUARD'ın global GNSS anchor ve derived map coordinate'ları için WGS84 kullanmasını destekler.)*

---

# 97. GEO-02 — ECEF and ENU Transformations (GEO-02 — ECEF ve ENU Transformation'ları)

**Source:** ESA Navipedia — *Transformations between ECEF and ENU Coordinates*. *(Kaynak: ESA Navipedia — Transformations between ECEF and ENU Coordinates.)*

ESA Navipedia provides explicit rotation matrices for conversion between Earth-Centered Earth-Fixed coordinates and the local East-North-Up frame. *(ESA Navipedia Earth-Centered Earth-Fixed coordinate'ları ile local East-North-Up frame arasındaki conversion için explicit rotation matrix'leri sağlar.)*

---

# 98. GEO-02 Decision Support (GEO-02 Karar Desteği)

GEO-02 is the main external mathematical reference for NAVGUARD's ECEF ↔ ENU conversion. *(GEO-02 NAVGUARD'ın ECEF ↔ ENU conversion'ı için main external mathematical reference'tır.)*

---

# 99. GEO-03 — Horizontal Position Error and ENU Covariance (GEO-03 — Horizontal Position Error ve ENU Covariance)

**Source:** ESA Navipedia — *Positioning Error*. *(Kaynak: ESA Navipedia — Positioning Error.)*

ESA describes position uncertainty in East, North, and Up components and derives horizontal error quantities from the ENU covariance matrix. *(ESA position uncertainty'yi East, North ve Up component'leri içerisinde tanımlar ve horizontal error quantity'lerini ENU covariance matrix'ten derive eder.)*

---

# 100. GEO-03 Decision Support (GEO-03 Karar Desteği)

GEO-03 supports NAVGUARD's use of the East/North covariance block for horizontal uncertainty analysis and ellipse construction. *(GEO-03 NAVGUARD'ın horizontal uncertainty analysis ve ellipse construction için East/North covariance block'u kullanmasını destekler.)*

---

# 101. PDR Academic Reference Group (PDR Akademik Referans Grubu)

The PDR references provide the academic foundation for step-and-heading-based pedestrian tracking and accumulated-drift limitations. *(PDR reference'ları step-and-heading-based pedestrian tracking ve accumulated-drift limitation'ları için academic foundation sağlar.)*

---

# 102. PDR-01 — Harle 2013 Survey (PDR-01 — Harle 2013 Survey)

**Reference:** Harle, R., “A Survey of Indoor Inertial Positioning Systems for Pedestrians,” *IEEE Communications Surveys & Tutorials*, 15(3), 1281–1293, 2013. *(Referans: Harle, R., “A Survey of Indoor Inertial Positioning Systems for Pedestrians,” IEEE Communications Surveys & Tutorials, 15(3), 1281–1293, 2013.)*

**DOI:** `10.1109/SURV.2012.121912.00075`. *(DOI: `10.1109/SURV.2012.121912.00075`.)*

The survey reviews step detection, step characterization, inertial navigation, and step-and-heading-based pedestrian dead reckoning and discusses the need for periodic absolute corrections for longer-term operation. *(Survey step detection, step characterization, inertial navigation ve step-and-heading-based pedestrian dead reckoning'i review eder ve longer-term operation için periodic absolute correction ihtiyacını tartışır.)*

---

# 103. PDR-01 Decision Support (PDR-01 Karar Desteği)

PDR-01 supports NAVGUARD's step-event-driven architecture and its explicit recognition that dead-reckoning drift grows without absolute correction. *(PDR-01 NAVGUARD'ın step-event-driven architecture'ını ve absolute correction olmadan dead-reckoning drift'in büyüdüğünü explicit olarak recognize etmesini destekler.)*

---

# 104. PDR-02 — Smartphone PDR Example (PDR-02 — Smartphone PDR Örneği)

**Reference:** Geng, J., Xia, L., Xia, J., Li, Q., Zhu, H., and Cai, Y., “Smartphone-Based Pedestrian Dead Reckoning for 3D Indoor Positioning,” *Sensors*, 21(24), 8180, 2021. *(Referans: Geng, J., Xia, L., Xia, J., Li, Q., Zhu, H. ve Cai, Y., “Smartphone-Based Pedestrian Dead Reckoning for 3D Indoor Positioning,” Sensors, 21(24), 8180, 2021.)*

**DOI:** `10.3390/s21248180`. *(DOI: `10.3390/s21248180`.)*

This work illustrates contemporary smartphone PDR using built-in MEMS sensors, heading estimation, step-length modeling, and filtering. *(Bu çalışma built-in MEMS sensor'ları, heading estimation, step-length modeling ve filtering kullanan contemporary smartphone PDR örneği sunar.)*

---

# 105. PDR-02 Usage Rule (PDR-02 Kullanım Kuralı)

PDR-02 is contextual literature and does not define NAVGUARD's exact algorithm or performance target. *(PDR-02 contextual literature'dır ve NAVGUARD'ın exact algorithm veya performance target'ını define etmez.)*

---

# 106. STEP-01 — Weinberg AN-602 (STEP-01 — Weinberg AN-602)

**Reference:** Weinberg, H., *Using the ADXL202 in Pedometer and Personal Navigation Applications*, Analog Devices Application Note AN-602, 2002. *(Referans: Weinberg, H., Using the ADXL202 in Pedometer and Personal Navigation Applications, Analog Devices Application Note AN-602, 2002.)*

Analog Devices lists AN-602 as an official application note for pedometer and personal-navigation applications. *(Analog Devices AN-602'yi pedometer ve personal-navigation application'ları için official application note olarak listeler.)*

---

# 107. STEP-01 Decision Support (STEP-01 Karar Desteği)

STEP-01 is the historical reference associated with Weinberg-style acceleration-based variable step-length estimation. *(STEP-01 Weinberg-style acceleration-based variable step-length estimation ile associated historical reference'tır.)*

---

# 108. STEP-02 — Smartphone Step Counting (STEP-02 — Smartphone Step Counting)

**Reference:** Brajdic, A. and Harle, R., “Walk Detection and Step Counting on Unconstrained Smartphones,” *Proceedings of UbiComp 2013*, 225–234, 2013. *(Referans: Brajdic, A. ve Harle, R., “Walk Detection and Step Counting on Unconstrained Smartphones,” Proceedings of UbiComp 2013, 225–234, 2013.)*

**DOI:** `10.1145/2493432.2493449`. *(DOI: `10.1145/2493432.2493449`.)*

The study evaluates smartphone walk detection and step-counting algorithms across multiple participants and phone placements and reports placement-dependent behavior. *(Çalışma multiple participant ve phone placement arasında smartphone walk detection ve step-counting algorithm'larını evaluate eder ve placement-dependent behavior raporlar.)*

---

# 109. STEP-02 Decision Support (STEP-02 Karar Desteği)

STEP-02 supports NAVGUARD's use of controlled phone placement in the initial benchmark and its plan to measure false and missed steps rather than assuming placement invariance. *(STEP-02 NAVGUARD'ın initial benchmark'ta controlled phone placement kullanmasını ve placement invariance assume etmek yerine false ve missed step'leri measure etme planını destekler.)*

---

# 110. STEP-03 — Sensor Placement Sensitivity (STEP-03 — Sensör Placement Sensitivity)

**Reference:** Tietsch, M. et al., “Robust Step Detection from Different Waist-Worn Sensor Positions: Implications for Clinical Studies,” 2020. *(Referans: Tietsch, M. vd., “Robust Step Detection from Different Waist-Worn Sensor Positions: Implications for Clinical Studies,” 2020.)*

The study demonstrates that sensor-wearing position can alter acceleration signals and affect step detection. *(Çalışma sensor-wearing position'ın acceleration signal'larını değiştirebildiğini ve step detection'ı affect edebildiğini gösterir.)*

---

# 111. STEP-03 Decision Support (STEP-03 Karar Desteği)

STEP-03 reinforces the limitation that one calibrated placement cannot automatically represent arbitrary phone placements. *(STEP-03 one calibrated placement'ın arbitrary phone placement'ları automatically represent edemeyeceği limitation'ını reinforce eder.)*

---

# 112. HAR Academic Reference Group (HAR Akademik Referans Grubu)

Human-activity-recognition literature provides theoretical context for the mandatory NAVGUARD Motion Classification subsystem. *(Human-activity-recognition literature mandatory NAVGUARD Motion Classification subsystem'i için theoretical context sağlar.)*

---

# 113. HAR-01 — Ignatov 2018 (HAR-01 — Ignatov 2018)

**Reference:** Ignatov, A., “Real-time Human Activity Recognition from Accelerometer Data Using Convolutional Neural Networks,” *Applied Soft Computing*, 62, 915–922, 2018. *(Referans: Ignatov, A., “Real-time Human Activity Recognition from Accelerometer Data Using Convolutional Neural Networks,” Applied Soft Computing, 62, 915–922, 2018.)*

**DOI:** `10.1016/j.asoc.2017.09.027`. *(DOI: `10.1016/j.asoc.2017.09.027`.)*

The paper demonstrates a lightweight convolutional approach for real-time activity recognition from mobile inertial time series and examines the effect of temporal window length. *(Paper mobile inertial time series üzerinden real-time activity recognition için lightweight convolutional approach gösterir ve temporal window length'in effect'ini examine eder.)*

---

# 114. HAR-01 Decision Support (HAR-01 Karar Desteği)

HAR-01 supports the selection of a lightweight temporal CNN as a serious neural baseline for smartphone motion recognition. *(HAR-01 lightweight temporal CNN'in smartphone motion recognition için serious neural baseline olarak selection'ını destekler.)*

---

# 115. HAR-01 Scope Rule (HAR-01 Scope Kuralı)

NAVGUARD's exact four-class taxonomy, sensor channels, window duration, and architecture remain project-specific decisions and are not copied directly from HAR-01. *(NAVGUARD'ın exact four-class taxonomy, sensor channel'ları, window duration ve architecture'ı project-specific decision olarak kalır ve HAR-01'den directly copied edilmez.)*

---

# 116. HAR-02 — Context-Aware PDR Literature (HAR-02 — Context-Aware PDR Literature)

**Reference:** A context-aware smartphone PDR study published in *Sensors*, 2022, demonstrates the broader concept of adapting PDR behavior according to motion state and phone-carrying context. *(Referans: Sensors'ta 2022 yılında yayımlanan context-aware smartphone PDR çalışması, PDR behavior'ını motion state ve phone-carrying context'e göre adapt etme broader concept'ini gösterir.)*

---

# 117. HAR-02 Decision Support (HAR-02 Karar Desteği)

HAR-02 provides contextual support for NAVGUARD's requirement that Motion Classification must affect navigation behavior rather than exist only as a UI label. *(HAR-02 NAVGUARD'ın Motion Classification'ın yalnızca UI label olarak exist etmek yerine navigation behavior'ı affect etmesi requirement'ı için contextual support sağlar.)*

---

# 118. Kalman Filtering Reference Group (Kalman Filtering Referans Grubu)

Kalman-filter references provide the theoretical basis for recursive state estimation, covariance propagation, nonlinear extension, and measurement fusion. *(Kalman-filter reference'ları recursive state estimation, covariance propagation, nonlinear extension ve measurement fusion için theoretical basis sağlar.)*

---

# 119. KF-01 — Kalman 1960 (KF-01 — Kalman 1960)

**Reference:** Kalman, R. E., “A New Approach to Linear Filtering and Prediction Problems,” *Journal of Basic Engineering*, 82(1), 35–45, 1960. *(Referans: Kalman, R. E., “A New Approach to Linear Filtering and Prediction Problems,” Journal of Basic Engineering, 82(1), 35–45, 1960.)*

**DOI:** `10.1115/1.3662552`. *(DOI: `10.1115/1.3662552`.)*

Kalman's original work establishes the recursive state-estimation and covariance framework underlying the Kalman filter. *(Kalman'ın original work'ü Kalman filter'ın temelindeki recursive state-estimation ve covariance framework'ünü establish eder.)*

---

# 120. KF-01 Decision Support (KF-01 Karar Desteği)

KF-01 provides the foundational theoretical reference for NAVGUARD's recursive fusion architecture. *(KF-01 NAVGUARD'ın recursive fusion architecture'ı için foundational theoretical reference sağlar.)*

---

# 121. KF-02 — Welch & Bishop (KF-02 — Welch & Bishop)

**Reference:** Welch, G. and Bishop, G., *An Introduction to the Kalman Filter*, UNC Chapel Hill Technical Report TR 95-041. *(Referans: Welch, G. ve Bishop, G., An Introduction to the Kalman Filter, UNC Chapel Hill Technical Report TR 95-041.)*

The report provides a practical introduction to both the discrete Kalman Filter and Extended Kalman Filter. *(Report hem discrete Kalman Filter hem Extended Kalman Filter için practical introduction sağlar.)*

---

# 122. KF-02 Decision Support (KF-02 Karar Desteği)

KF-02 is a useful implementation-oriented reference for EKF prediction, linearization, measurement update, and covariance reasoning. *(KF-02 EKF prediction, linearization, measurement update ve covariance reasoning için useful implementation-oriented reference'tır.)*

---

# 123. KF-03 — Dan Simon (KF-03 — Dan Simon)

**Reference:** Simon, D., *Optimal State Estimation: Kalman, H∞, and Nonlinear Approaches*, Wiley, 2006. *(Referans: Simon, D., Optimal State Estimation: Kalman, H∞, and Nonlinear Approaches, Wiley, 2006.)*

**DOI:** `10.1002/0470045345`. *(DOI: `10.1002/0470045345`.)*

The book provides rigorous coverage of state-estimation theory, including discrete Kalman filtering, nonlinear estimation, covariance behavior, and practical implementation considerations. *(Kitap discrete Kalman filtering, nonlinear estimation, covariance behavior ve practical implementation consideration'ları dahil olmak üzere state-estimation theory için rigorous coverage sağlar.)*

---

# 124. KF-03 Decision Support (KF-03 Karar Desteği)

KF-03 is the preferred deep technical reference when NAVGUARD implementation questions exceed the level covered by introductory EKF material. *(NAVGUARD implementation question'ları introductory EKF material'ın level'ını aştığında KF-03 preferred deep technical reference'tır.)*

---

# 125. KF-04 — Bayesian Filtering and Smoothing (KF-04 — Bayesian Filtering and Smoothing)

**Reference:** Särkkä, S., *Bayesian Filtering and Smoothing*, Cambridge University Press. *(Referans: Särkkä, S., Bayesian Filtering and Smoothing, Cambridge University Press.)*

The book presents nonlinear Kalman filtering and broader Bayesian state-estimation techniques in a unified framework. *(Kitap nonlinear Kalman filtering ve broader Bayesian state-estimation technique'lerini unified framework içerisinde sunar.)*

---

# 126. KF-04 Usage Rule (KF-04 Kullanım Kuralı)

KF-04 is especially useful for future comparisons involving alternative nonlinear filters, smoothing, or more advanced uncertainty analysis. *(KF-04 özellikle alternative nonlinear filter, smoothing veya more advanced uncertainty analysis içeren future comparison'lar için useful'dır.)*

---

# 127. EKF State-Specific Note (EKF State-Specific Notu)

None of the general Kalman references mandates NAVGUARD's exact state vector. *(General Kalman reference'ların hiçbiri NAVGUARD'ın exact state vector'ını mandate etmez.)*

The project-specific frozen minimum state remains `[E,N,ψ]`. *(Project-specific frozen minimum state `[E,N,ψ]` olarak kalır.)*

---

# 128. EKF Jacobian Ownership (EKF Jacobian Ownership)

NAVGUARD's specific process Jacobian is derived from its own nonlinear step propagation model and must be verified analytically and numerically. *(NAVGUARD'ın specific process Jacobian'ı own nonlinear step propagation model'ından derive edilir ve analytically ve numerically verify edilmelidir.)*

---

# 129. EKF Noise Ownership (EKF Noise Ownership)

External references define the roles of process and measurement uncertainty but do not provide universally correct `Q` and `R` values for the Redmi Note 9 Pro. *(External reference'lar process ve measurement uncertainty'nin role'lerini define eder ancak Redmi Note 9 Pro için universally correct `Q` ve `R` value'ları sağlamaz.)*

---

# 130. Q/R Calibration Rule (Q/R Calibration Kuralı)

The actual `Q`, `R`, and initialization covariance values therefore remain experiment-derived NAVGUARD parameters. *(Bu nedenle actual `Q`, `R` ve initialization covariance value'ları experiment-derived NAVGUARD parameter'ları olarak kalır.)*

---

# 131. Storage Reference Group (Storage Referans Grubu)

Android storage references support the use of local structured metadata and private application databases. *(Android storage reference'ları local structured metadata ve private application database kullanımını destekler.)*

---

# 132. DATA-01 — Android SQLite (DATA-01 — Android SQLite)

**Source:** Android Developers — SQLite storage documentation. *(Kaynak: Android Developers — SQLite storage documentation.)*

Android provides SQLite database APIs for application-private structured data. *(Android application-private structured data için SQLite database API'leri sağlar.)*

---

# 133. DATA-01 Decision Support (DATA-01 Karar Desteği)

DATA-01 supports NAVGUARD's decision to use SQLite for session metadata and indexable structured records. *(DATA-01 NAVGUARD'ın session metadata ve indexable structured record'lar için SQLite kullanma kararını destekler.)*

---

# 134. DATA-02 — Room as SQLite Abstraction (DATA-02 — SQLite Abstraction Olarak Room)

**Source:** Android Developers — *Save Data in a Local Database Using Room*. *(Kaynak: Android Developers — Save Data in a Local Database Using Room.)*

Android recommends Room as an abstraction over SQLite because it provides compile-time SQL verification and migration support. *(Android compile-time SQL verification ve migration support sağladığı için Room'u SQLite üzerinde abstraction olarak recommend eder.)*

---

# 135. DATA-02 Implementation Decision (DATA-02 Implementation Kararı)

NAVGUARD may use Room or another controlled SQLite abstraction for metadata, but the architectural requirement is SQLite-backed structured metadata rather than one specific ORM. *(NAVGUARD metadata için Room veya another controlled SQLite abstraction kullanabilir ancak architectural requirement one specific ORM yerine SQLite-backed structured metadata'dır.)*

---

# 136. High-Frequency Logging Rule (High-Frequency Logging Kuralı)

Neither Android's SQLite documentation nor Room implies that individual 50 Hz sensor samples should be written as synchronous database transactions. *(Android'ın SQLite documentation'ı veya Room, individual 50 Hz sensor sample'ların synchronous database transaction olarak written edilmesini imply etmez.)*

NAVGUARD therefore retains append-oriented files for high-frequency scientific streams. *(Bu nedenle NAVGUARD high-frequency scientific stream'ler için append-oriented file'ları retained eder.)*

---

# 137. Internal Evidence Reference Group (Internal Evidence Referans Grubu)

Not every NAVGUARD decision should be justified by an external publication. *(Her NAVGUARD decision'ı external publication ile justify edilmek zorunda değildir.)*

Device-specific thresholds and benchmark values must be supported by NAVGUARD's own measurements rather than borrowed from unrelated studies. *(Device-specific threshold ve benchmark value'ları unrelated study'lerden borrowed edilmek yerine NAVGUARD'ın own measurement'ları tarafından supported edilmelidir.)*

---

# 138. INT-01 — Device Capability Audit (INT-01 — Device Capability Audit)

The physical device capability audit is the authoritative source for whether accelerometer, gyroscope, magnetometer, Rotation Vector, barometer, GNSS, and ARCore actually operate as required on the project phone. *(Physical device capability audit accelerometer, gyroscope, magnetometer, Rotation Vector, barometer, GNSS ve ARCore'un project phone üzerinde required şekilde actually operate edip etmediği için authoritative source'tur.)*

---

# 139. INT-02 — Sensor Rate Audit (INT-02 — Sensor Rate Audit)

Measured timestamp distributions are the authoritative source for actual delivered sensor rates. *(Measured timestamp distribution'ları actual delivered sensor rate'leri için authoritative source'tur.)*

---

# 140. INT-03 — Step Detector Calibration (INT-03 — Step Detector Calibration)

Pilot controlled-walking sessions are the authoritative source for final peak thresholds, filter parameters, and refractory timing. *(Pilot controlled-walking session'ları final peak threshold, filter parameter ve refractory timing için authoritative source'tur.)*

---

# 141. INT-04 — Heading Calibration (INT-04 — Heading Calibration)

Controlled orientation and walking tests are the authoritative source for final heading-filter parameters and disturbance thresholds. *(Controlled orientation ve walking test'leri final heading-filter parameter'ları ve disturbance threshold'ları için authoritative source'tur.)*

---

# 142. INT-05 — ARCore Clock Validation (INT-05 — ARCore Clock Validation)

Physical cross-timestamp experiments are the authoritative source for NAVGUARD's final ARCore-to-experiment-time mapping. *(Physical cross-timestamp experiment'leri NAVGUARD'ın final ARCore-to-experiment-time mapping'i için authoritative source'tur.)*

---

# 143. INT-06 — ARCore-to-ENU Alignment (INT-06 — ARCore-to-ENU Alignment)

Controlled straight-line and turn experiments are the authoritative source for validating the chosen ARCore-to-ENU transform. *(Controlled straight-line ve turn experiment'leri chosen ARCore-to-ENU transform'ı validate etmek için authoritative source'tur.)*

---

# 144. INT-07 — EKF Noise Calibration (INT-07 — EKF Noise Calibration)

Development and pilot evidence are the authoritative source for final `Q`, `R`, and quality-to-covariance mappings. *(Development ve pilot evidence final `Q`, `R` ve quality-to-covariance mapping'leri için authoritative source'tur.)*

---

# 145. INT-08 — AI Dataset (INT-08 — AI Dataset)

NAVGUARD's versioned physical-session dataset is the authoritative evidence for the final Motion Classification model. *(NAVGUARD'ın versioned physical-session dataset'i final Motion Classification model için authoritative evidence'tır.)*

---

# 146. INT-09 — AI Held-Out Evaluation (INT-09 — AI Held-Out Evaluation)

The frozen held-out test sessions are the authoritative source for the final Macro F1 and per-class AI metrics. *(Frozen held-out test session'ları final Macro F1 ve per-class AI metric'leri için authoritative source'tur.)*

---

# 147. INT-10 — On-Device AI Parity (INT-10 — On-Device AI Parity)

Golden Python-versus-Android tensor and output comparisons are the authoritative source for deployment parity. *(Golden Python-versus-Android tensor ve output comparison'ları deployment parity için authoritative source'tur.)*

---

# 148. INT-11 — AI Runtime (INT-11 — AI Runtime)

Release-mode Redmi Note 9 Pro benchmarks are the authoritative source for final inference latency. *(Release-mode Redmi Note 9 Pro benchmark'ları final inference latency için authoritative source'tur.)*

---

# 149. INT-12 — Ground Truth Firewall (INT-12 — Ground Truth Firewall)

Runtime authorization logs, mutation replay tests, and the `unauthorizedGnssEstimatorUpdateCount` counter are the authoritative evidence for denied-mode GNSS isolation. *(Runtime authorization log'ları, mutation replay test'leri ve `unauthorizedGnssEstimatorUpdateCount` counter'ı denied-mode GNSS isolation için authoritative evidence'tır.)*

---

# 150. INT-13 — Primary Navigation Result (INT-13 — Primary Navigation Sonucu)

Matched A-versus-D final benchmark sessions are the authoritative evidence for the primary `≥20%` error-reduction research target. *(Matched A-versus-D final benchmark session'ları primary `≥20%` error-reduction research target için authoritative evidence'tır.)*

---

# 151. External Source vs Internal Evidence Rule (External Source vs Internal Evidence Kuralı)

External literature explains what methods are plausible and how related systems behave. *(External literature hangi method'ların plausible olduğunu ve related system'lerin nasıl behave ettiğini açıklar.)*

Internal NAVGUARD evidence determines whether those methods work on the actual device and within the actual project configuration. *(Internal NAVGUARD evidence bu method'ların actual device ve actual project configuration içerisinde çalışıp çalışmadığını determine eder.)*

---

# 152. No Borrowed Threshold Rule (Borrowed Threshold Olmaması Kuralı)

NAVGUARD must not copy a published sensor threshold, step threshold, covariance value, or confidence threshold and present it as target-device calibration without measurement. *(NAVGUARD published sensor threshold, step threshold, covariance value veya confidence threshold'u copy edip measurement olmadan target-device calibration olarak present etmemelidir.)*

---

# 153. No Borrowed Accuracy Rule (Borrowed Accuracy Olmaması Kuralı)

Accuracy results reported by other PDR systems must never be reused as NAVGUARD performance evidence. *(Other PDR system'ler tarafından reported accuracy result'ları NAVGUARD performance evidence olarak hiçbir zaman reused edilmemelidir.)*

---

# 154. Android Sensor Coordinate System Cross-Reference (Android Sensor Coordinate System Cross-Reference)

Relevant NAVGUARD pages include Pages 12, 13, 14, 17, 18, 23, and 25. *(Relevant NAVGUARD page'leri Page 12, 13, 14, 17, 18, 23 ve 25'i içerir.)*

Primary external references are ANDROID-01 through ANDROID-06. *(Primary external reference'lar ANDROID-01 ile ANDROID-06 arasındadır.)*

---

# 155. GNSS Cross-Reference (GNSS Cross-Reference)

Relevant NAVGUARD pages include Pages 11, 15, 28, 29, 34, and 35. *(Relevant NAVGUARD page'leri Page 11, 15, 28, 29, 34 ve 35'i içerir.)*

Primary external references are ANDROID-08 through ANDROID-12. *(Primary external reference'lar ANDROID-08 ile ANDROID-12 arasındadır.)*

---

# 156. Coordinate Mathematics Cross-Reference (Coordinate Mathematics Cross-Reference)

Relevant NAVGUARD pages include Pages 14, 15, 16, 21, 28, 29, and 35. *(Relevant NAVGUARD page'leri Page 14, 15, 16, 21, 28, 29 ve 35'i içerir.)*

Primary external references are GEO-01 through GEO-03. *(Primary external reference'lar GEO-01 ile GEO-03 arasındadır.)*

---

# 157. PDR Cross-Reference (PDR Cross-Reference)

Relevant NAVGUARD pages include Pages 16, 17, 18, 24, 28, and 35. *(Relevant NAVGUARD page'leri Page 16, 17, 18, 24, 28 ve 35'i içerir.)*

Primary academic references are PDR-01, PDR-02, STEP-01, STEP-02, and STEP-03. *(Primary academic reference'lar PDR-01, PDR-02, STEP-01, STEP-02 ve STEP-03'tür.)*

---

# 158. Motion AI Cross-Reference (Motion AI Cross-Reference)

Relevant NAVGUARD pages include Pages 22, 23, 25, 26, 27, 35, 39, and 41. *(Relevant NAVGUARD page'leri Page 22, 23, 25, 26, 27, 35, 39 ve 41'i içerir.)*

Primary references are HAR-01, HAR-02, ML-01 through ML-09, and LITERT-01 through LITERT-07. *(Primary reference'lar HAR-01, HAR-02, ML-01 ile ML-09 ve LITERT-01 ile LITERT-07 arasındadır.)*

---

# 159. ARCore Cross-Reference (ARCore Cross-Reference)

Relevant NAVGUARD pages include Pages 19, 20, 21, 27, 28, 29, 34, 36, 37, 39, and 41. *(Relevant NAVGUARD page'leri Page 19, 20, 21, 27, 28, 29, 34, 36, 37, 39 ve 41'i içerir.)*

Primary references are ARCORE-01 through ARCORE-08. *(Primary reference'lar ARCORE-01 ile ARCORE-08 arasındadır.)*

---

# 160. EKF Cross-Reference (EKF Cross-Reference)

Relevant NAVGUARD pages include Pages 20, 21, 28, 29, 35, 37, 39, and 41. *(Relevant NAVGUARD page'leri Page 20, 21, 28, 29, 35, 37, 39 ve 41'i içerir.)*

Primary theoretical references are KF-01 through KF-04 and GEO-03. *(Primary theoretical reference'lar KF-01 ile KF-04 ve GEO-03'tür.)*

---

# 161. Storage Cross-Reference (Storage Cross-Reference)

Relevant NAVGUARD pages include Pages 25, 27, 30, 33, 35, 39, and 41. *(Relevant NAVGUARD page'leri Page 25, 27, 30, 33, 35, 39 ve 41'i içerir.)*

Primary platform references are DATA-01 and DATA-02. *(Primary platform reference'lar DATA-01 ve DATA-02'dir.)*

---

# 162. Flutter/Kotlin Cross-Reference (Flutter/Kotlin Cross-Reference)

Relevant NAVGUARD pages include Pages 08, 09, 10, 12, 15, 19, 27, 30, and 31. *(Relevant NAVGUARD page'leri Page 08, 09, 10, 12, 15, 19, 27, 30 ve 31'i içerir.)*

Primary platform references are FLUTTER-01 through FLUTTER-03. *(Primary platform reference'lar FLUTTER-01 ile FLUTTER-03 arasındadır.)*

---

# 163. Reference Freshness Policy (Referans Güncellik Politikası)

Academic foundations such as Kalman filtering and classical PDR may remain valid for many years, while platform APIs can change rapidly. *(Kalman filtering ve classical PDR gibi academic foundation'lar uzun yıllar valid kalabilirken platform API'leri rapidly değişebilir.)*

---

# 164. Android Reference Refresh Rule (Android Referans Refresh Kuralı)

Android references should be rechecked when the target SDK, Android OS version, or permission model changes materially. *(Target SDK, Android OS version veya permission model materially değiştiğinde Android reference'lar yeniden checked edilmelidir.)*

---

# 165. ARCore Reference Refresh Rule (ARCore Referans Refresh Kuralı)

ARCore references should be rechecked when the ARCore SDK version or device-support state changes. *(ARCore SDK version veya device-support state değiştiğinde ARCore reference'lar yeniden checked edilmelidir.)*

---

# 166. LiteRT Reference Refresh Rule (LiteRT Referans Refresh Kuralı)

LiteRT references must be checked again before dependency installation because the runtime and acceleration APIs are actively evolving. *(Runtime ve acceleration API'leri actively evolve ettiği için LiteRT reference'lar dependency installation öncesinde yeniden checked edilmelidir.)*

---

# 167. Current LiteRT Architecture Note (Current LiteRT Architecture Notu)

At the current validation date, Google's official guidance positions `CompiledModel` as the modern recommended path for new LiteRT work while maintaining `Interpreter` compatibility. *(Current validation date itibarıyla Google'ın official guidance'ı `Interpreter` compatibility'yi maintain ederken `CompiledModel`'ı new LiteRT work için modern recommended path olarak position eder.)*

---

# 168. Current LiteRT Version Rule (Current LiteRT Version Kuralı)

The documentation examples currently show LiteRT v2 dependencies, but NAVGUARD will not freeze an exact artifact version until the implementation environment is bootstrapped and tested. *(Documentation example'ları currently LiteRT v2 dependency'leri gösterir ancak NAVGUARD implementation environment bootstrap edilip tested edilene kadar exact artifact version'ı freeze etmeyecektir.)*

---

# 169. Current ARCore Support Note (Current ARCore Support Notu)

The Redmi Note 9 Pro is currently present in Google's ARCore-supported device list. *(Redmi Note 9 Pro currently Google'ın ARCore-supported device list'inde bulunmaktadır.)*

---

# 170. ARCore Support Interpretation (ARCore Support Yorumu)

This confirms published compatibility but does not guarantee perfect tracking in all lighting, texture, thermal, camera, or motion conditions. *(Bu durum published compatibility'yi doğrular ancak all lighting, texture, thermal, camera veya motion condition'larda perfect tracking guarantee etmez.)*

---

# 171. Android Heading API Caution (Android Heading API Uyarısı)

Android platform behavior and available orientation-related sensor types can evolve, so NAVGUARD's frozen heading architecture should rely on explicit sensor data and validated conversions rather than assuming one convenience API will remain identical forever. *(Android platform behavior ve available orientation-related sensor type'ları evolve edebileceği için NAVGUARD'ın frozen heading architecture'ı one convenience API'nin forever identical kalacağını assume etmek yerine explicit sensor data ve validated conversion'lara rely etmelidir.)*

---

# 172. Scientific Citation Style (Bilimsel Citation Stili)

Final academic reporting should use one consistent citation format such as IEEE or APA rather than mixing citation styles. *(Final academic reporting citation style'ları mix etmek yerine IEEE veya APA gibi one consistent citation format kullanmalıdır.)*

---

# 173. Recommended NAVGUARD Citation Style (Önerilen NAVGUARD Citation Stili)

IEEE numeric citation style is recommended for the final technical report because the project contains many engineering and platform references. *(Project many engineering ve platform reference içerdiği için final technical report için IEEE numeric citation style recommended'dır.)*

---

# 174. DOI Preservation Rule (DOI Koruma Kuralı)

Where a DOI exists, it should be preserved in the final bibliography because it provides a stable publication identifier. *(DOI mevcut olduğunda stable publication identifier sağladığı için final bibliography içerisinde preserved edilmelidir.)*

---

# 175. Platform URL Preservation Rule (Platform URL Koruma Kuralı)

Official web documentation entries should preserve the page title, platform owner, and retrieval or validation date because URLs and page content may change. *(Official web documentation entry'leri URL ve page content değişebileceği için page title, platform owner ve retrieval veya validation date'i preserve etmelidir.)*

---

# 176. Access Date Rule (Access Date Kuralı)

An access date is particularly important for Android, ARCore, Flutter, and LiteRT documentation. *(Access date özellikle Android, ARCore, Flutter ve LiteRT documentation için önemlidir.)*

---

# 177. Suggested Platform Citation Format (Önerilen Platform Citation Formatı)

```text
Organization, “Page Title,” Official Documentation,
accessed 2026-09-01.
(Organizasyon, “Sayfa Başlığı,” Resmî Dokümantasyon,
erişim tarihi 2026-09-01.)
```

---

# 178. Suggested Journal Citation Format (Önerilen Journal Citation Formatı)

```text
Author(s), “Paper Title,” Journal,
vol., no., pp., year, DOI.
(Yazar(lar), “Makale Başlığı,” Dergi,
cilt, sayı, sayfa, yıl, DOI.)
```

---

# 179. Suggested Conference Citation Format (Önerilen Conference Citation Formatı)

```text
Author(s), “Paper Title,” in Proceedings of Conference,
pages, year, DOI.
(Yazar(lar), “Makale Başlığı,” Conference Proceedings,
sayfalar, yıl, DOI.)
```

---

# 180. Suggested Technical Report Citation Format (Önerilen Technical Report Citation Formatı)

```text
Author(s), Report Title,
Institution, Report Number, year.
(Yazar(lar), Rapor Başlığı,
Kurum, Rapor Numarası, yıl.)
```

---

# 181. Recommended Core Reading Set (Önerilen Core Reading Set)

A developer does not need to read every source before implementation begins. *(Developer implementation başlamadan önce every source'u okumak zorunda değildir.)*

The following subset is sufficient as the first technical reading path. *(Aşağıdaki subset first technical reading path olarak sufficient'tır.)*

```text
1. Android Sensors Overview
   (Android Sensors Overview)

2. SensorEvent timestamp documentation
   (SensorEvent timestamp dokümantasyonu)

3. Android Location / LocationManager
   (Android Location / LocationManager)

4. ARCore Camera / Pose / TrackingState / Frame
   (ARCore Camera / Pose / TrackingState / Frame)

5. LiteRT Android + CompiledModel Kotlin
   (LiteRT Android + CompiledModel Kotlin)

6. Harle 2013 PDR Survey
   (Harle 2013 PDR Survey)

7. Brajdic & Harle 2013 Step Counting
   (Brajdic & Harle 2013 Step Counting)

8. ESA ECEF ↔ ENU Transformations
   (ESA ECEF ↔ ENU Transformations)

9. Welch & Bishop EKF Introduction
   (Welch & Bishop EKF Introduction)

10. Ignatov 2018 HAR CNN
    (Ignatov 2018 HAR CNN)
```

---

# 182. Day 1 Reading Priority (Day 1 Reading Önceliği)

Before implementing sensor acquisition, ANDROID-01 through ANDROID-04 should be reviewed. *(Sensor acquisition implement edilmeden önce ANDROID-01 ile ANDROID-04 arasındaki reference'lar reviewed edilmelidir.)*

---

# 183. GNSS Implementation Reading Priority (GNSS Implementation Reading Önceliği)

Before implementing formal GNSS logging, ANDROID-08 through ANDROID-12 should be reviewed. *(Formal GNSS logging implement edilmeden önce ANDROID-08 ile ANDROID-12 arasındaki reference'lar reviewed edilmelidir.)*

---

# 184. ARCore Implementation Reading Priority (ARCore Implementation Reading Önceliği)

Before implementing ARCore fusion, ARCORE-02 through ARCORE-08 should be reviewed in full. *(ARCore fusion implement edilmeden önce ARCORE-02 ile ARCORE-08 arasındaki reference'lar fully reviewed edilmelidir.)*

---

# 185. AI Deployment Reading Priority (AI Deployment Reading Önceliği)

Before Android AI deployment, LITERT-01 through LITERT-07 and ML-06 should be reviewed. *(Android AI deployment öncesinde LITERT-01 ile LITERT-07 ve ML-06 reviewed edilmelidir.)*

---

# 186. EKF Implementation Reading Priority (EKF Implementation Reading Önceliği)

Before implementing EKF code, KF-02 and KF-03 should be reviewed together with Page 21's project-specific equations. *(EKF code implement edilmeden önce KF-02 ve KF-03, Page 21'in project-specific equation'ları ile birlikte reviewed edilmelidir.)*

---

# 187. PDR Calibration Reading Priority (PDR Calibration Reading Önceliği)

Before calibrating step detection and step length, PDR-01, STEP-01, STEP-02, and STEP-03 should be reviewed. *(Step detection ve step length calibrate edilmeden önce PDR-01, STEP-01, STEP-02 ve STEP-03 reviewed edilmelidir.)*

---

# 188. Result Interpretation Reading Priority (Sonuç Yorumlama Reading Önceliği)

Before final analysis, PDR-01, KF-03, GEO-03, and the final NAVGUARD benchmark protocol should be reviewed together. *(Final analysis öncesinde PDR-01, KF-03, GEO-03 ve final NAVGUARD benchmark protocol birlikte reviewed edilmelidir.)*

---

# 189. Source Exclusion Rule (Kaynak Hariç Tutma Kuralı)

A source that cannot be traced to a reliable publisher, official platform owner, standards body, or identifiable academic publication should not be used as a primary justification. *(Reliable publisher, official platform owner, standards body veya identifiable academic publication'a trace edilemeyen source primary justification olarak kullanılmamalıdır.)*

---

# 190. Blog Usage Rule (Blog Kullanım Kuralı)

Blogs may be useful for implementation hints but should not define NAVGUARD's frozen mathematical or scientific claims. *(Blog'lar implementation hint'leri için useful olabilir ancak NAVGUARD'ın frozen mathematical veya scientific claim'lerini define etmemelidir.)*

---

# 191. Forum Usage Rule (Forum Kullanım Kuralı)

Forum answers may be useful for troubleshooting but must not override current official documentation. *(Forum answer'ları troubleshooting için useful olabilir ancak current official documentation'ı override etmemelidir.)*

---

# 192. Stack Overflow Rule (Stack Overflow Kuralı)

Stack Overflow can be used for debugging ideas but not as the authoritative source for sensor timing, GNSS isolation, coordinate mathematics, or benchmark methodology. *(Stack Overflow debugging idea'ları için kullanılabilir ancak sensor timing, GNSS isolation, coordinate mathematics veya benchmark methodology için authoritative source olarak kullanılmamalıdır.)*

---

# 193. AI-Generated Source Rule (AI-Generated Source Kuralı)

AI-generated explanations must not be cited as scientific evidence when the underlying authoritative source can be cited directly. *(Underlying authoritative source directly cite edilebiliyorsa AI-generated explanation scientific evidence olarak cited edilmemelidir.)*

---

# 194. Code Example Rule (Code Example Kuralı)

Official code examples are implementation guidance and do not automatically establish the scientific correctness of NAVGUARD's estimator. *(Official code example'ları implementation guidance'dır ve NAVGUARD estimator'ının scientific correctness'ını automatically establish etmez.)*

---

# 195. Research Paper Code Rule (Research Paper Code Kuralı)

Even when academic source code is available, NAVGUARD must independently verify unit conventions, coordinate systems, timestamps, dataset assumptions, and evaluation methodology before reuse. *(Academic source code available olsa bile NAVGUARD reuse öncesinde unit convention, coordinate system, timestamp, dataset assumption ve evaluation methodology'yi independently verify etmelidir.)*

---

# 196. Reproducibility Resource Rule (Reproducibility Kaynak Kuralı)

Whenever a paper provides code or data, those artifacts may be used to understand the method but should remain separately identified from NAVGUARD's own implementation and evidence. *(Paper code veya data sağladığında bu artifact'lar method'u understand etmek için kullanılabilir ancak NAVGUARD'ın own implementation ve evidence'ından separately identified kalmalıdır.)*

---

# 197. Research Novelty Rule (Research Novelty Kuralı)

This reference list demonstrates that PDR, inertial sensor fusion, HAR, AR tracking, and Kalman filtering are established research areas. *(Bu reference list PDR, inertial sensor fusion, HAR, AR tracking ve Kalman filtering'in established research area'lar olduğunu gösterir.)*

NAVGUARD must therefore avoid claiming that these individual techniques were invented by the project. *(Bu nedenle NAVGUARD bu individual technique'lerin project tarafından invented edildiğini claim etmekten kaçınmalıdır.)*

---

# 198. NAVGUARD Contribution Framing (NAVGUARD Contribution Framing)

The defensible project contribution is the integrated design, controlled GNSS-denial architecture, smartphone implementation, Ground Truth Firewall, matched A-D evaluation, and reproducible evidence workflow. *(Defensible project contribution integrated design, controlled GNSS-denial architecture, smartphone implementation, Ground Truth Firewall, matched A-D evaluation ve reproducible evidence workflow'dur.)*

---

# 199. Literature Review Expansion Rule (Literature Review Genişletme Kuralı)

If the final academic report requires a formal related-work section, additional literature searches should be performed specifically for smartphone GNSS-denied PDR, visual-inertial fusion, motion-context-aware PDR, and learned inertial navigation. *(Final academic report formal related-work section gerektirirse smartphone GNSS-denied PDR, visual-inertial fusion, motion-context-aware PDR ve learned inertial navigation için specifically additional literature search yapılmalıdır.)*

---

# 200. Literature Search Cutoff Rule (Literature Search Cutoff Kuralı)

A final literature search should be repeated close to report submission so important 2025–2026 or later work is not accidentally omitted. *(Important 2025–2026 veya later work accidentally omitted edilmesin diye report submission'a close zamanda final literature search repeat edilmelidir.)*

---

# 201. Reference-to-Decision Matrix (Referans-to-Decision Matrisi)

| NAVGUARD Decision (NAVGUARD Kararı)                                   | Primary Reference (Primary Referans) |
| --------------------------------------------------------------------- | ------------------------------------ |
| Android sensor axes *(Android sensor axis'leri)*                      | ANDROID-01                           |
| IMU monotonic timestamps *(IMU monotonic timestamp'leri)*             | ANDROID-02                           |
| GNSS `GPS_PROVIDER` *(GNSS `GPS_PROVIDER`)*                           | ANDROID-08                           |
| GNSS elapsed-realtime timestamp *(GNSS elapsed-realtime timestamp)*   | ANDROID-09                           |
| True-north magnetic correction *(True-north magnetic correction)*     | ANDROID-07                           |
| Flutter/Kotlin bridge *(Flutter/Kotlin bridge)*                       | FLUTTER-01                           |
| ARCore TRACKING-only fusion *(ARCore TRACKING-only fusion)*           | ARCORE-02                            |
| ARCore camera axes *(ARCore camera axis'leri)*                        | ARCORE-03                            |
| ARCore pose transform *(ARCore pose transform)*                       | ARCORE-04                            |
| ARCore undefined Frame time base *(ARCore undefined Frame time base)* | ARCORE-06                            |
| Redmi Note 9 Pro ARCore support *(Redmi Note 9 Pro ARCore support)*   | ARCORE-01                            |
| LiteRT deployment *(LiteRT deployment)*                               | LITERT-01–04                         |
| `.tflite` conversion *(`.tflite` conversion)*                         | LITERT-05                            |
| Group-wise ML split *(Group-wise ML split)*                           | ML-01–03                             |
| Macro F1 *(Macro F1)*                                                 | ML-04                                |
| Random Forest baseline *(Random Forest baseline)*                     | ML-05                                |
| 1D-CNN candidate *(1D-CNN candidate)*                                 | ML-06–07, HAR-01                     |
| WGS84 *(WGS84)*                                                       | GEO-01                               |
| ECEF ↔ ENU *(ECEF ↔ ENU)*                                             | GEO-02                               |
| Horizontal covariance *(Horizontal covariance)*                       | GEO-03                               |
| Step-and-heading PDR *(Step-and-heading PDR)*                         | PDR-01                               |
| Weinberg step length *(Weinberg step length)*                         | STEP-01                              |
| Smartphone step detection *(Smartphone step detection)*               | STEP-02                              |
| Placement sensitivity *(Placement sensitivity)*                       | STEP-02–03                           |
| EKF theoretical basis *(EKF theoretical basis)*                       | KF-01–04                             |

---

# 202. Reference-to-Internal-Evidence Matrix (Referans-to-Internal-Evidence Matrisi)

| External Topic (External Konu)                                        | NAVGUARD Internal Evidence Required (Gerekli NAVGUARD Internal Evidence) |
| --------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| Sensor availability *(Sensor availability)*                           | Device Capability Audit                                                  |
| Requested 50 Hz rate *(Requested 50 Hz rate)*                         | Delivered-rate timestamp analysis                                        |
| Step threshold *(Step threshold)*                                     | Controlled pilot sessions                                                |
| Heading filter *(Heading filter)*                                     | Orientation and field calibration                                        |
| Rotation Vector reliability *(Rotation Vector reliability)*           | Device audit                                                             |
| ARCore timing *(ARCore timing)*                                       | Clock-mapping experiment                                                 |
| ARCore alignment *(ARCore alignment)*                                 | Straight / turn field test                                               |
| Motion CNN architecture *(Motion CNN architecture)*                   | Validation + held-out performance                                        |
| Motion model deployment *(Motion model deployment)*                   | Golden parity + runtime test                                             |
| `Q/R` values *(`Q/R` value'ları)*                                     | Development calibration                                                  |
| NIS threshold *(NIS threshold)*                                       | Frozen development calibration                                           |
| Recovery thresholds *(Recovery threshold'ları)*                       | Pilot recovery evidence                                                  |
| `≥20%` performance target result *(`≥20%` performance target sonucu)* | Final matched A-D benchmark                                              |

---

# 203. Bibliographic Core — Official Platform Sources (Bibliographic Core — Resmî Platform Kaynakları)

The following official sources form the minimum platform bibliography. *(Aşağıdaki official source'lar minimum platform bibliography'yi oluşturur.)*

```text
Android Developers — Sensors Overview
(Android Developers — Sensors Overview)

Android Developers — SensorEvent
(Android Developers — SensorEvent)

Android Developers — Motion Sensors
(Android Developers — Motion Sensors)

Android Developers — SensorManager
(Android Developers — SensorManager)

Android Developers — GeomagneticField
(Android Developers — GeomagneticField)

Android Developers — LocationManager
(Android Developers — LocationManager)

Android Developers — Location
(Android Developers — Location)

Android Developers — Location Permissions
(Android Developers — Location Permissions)

Flutter Documentation — Platform Channels
(Flutter Documentation — Platform Channels)

Google ARCore — Supported Devices
(Google ARCore — Supported Devices)

Google ARCore — Camera
(Google ARCore — Camera)

Google ARCore — Pose
(Google ARCore — Pose)

Google ARCore — TrackingState
(Google ARCore — TrackingState)

Google ARCore — Frame
(Google ARCore — Frame)

Google AI Edge — LiteRT Overview
(Google AI Edge — LiteRT Overview)

Google AI Edge — LiteRT for Android
(Google AI Edge — LiteRT for Android)

Google AI Edge — CompiledModel Kotlin API
(Google AI Edge — CompiledModel Kotlin API)

Google AI Edge — Migrate to LiteRT
(Google AI Edge — Migrate to LiteRT)
```

---

# 204. Bibliographic Core — Academic Sources (Bibliographic Core — Akademik Kaynaklar)

The following publications form the current minimum academic bibliography. *(Aşağıdaki publication'lar current minimum academic bibliography'yi oluşturur.)*

```text
Kalman, R. E. (1960).
A New Approach to Linear Filtering and Prediction Problems.
(Kalman, R. E. (1960).
A New Approach to Linear Filtering and Prediction Problems.)

Welch, G. & Bishop, G.
An Introduction to the Kalman Filter.
(Welch, G. & Bishop, G.
An Introduction to the Kalman Filter.)

Simon, D. (2006).
Optimal State Estimation.
(Simon, D. (2006).
Optimal State Estimation.)

Harle, R. (2013).
A Survey of Indoor Inertial Positioning Systems for Pedestrians.
(Harle, R. (2013).
A Survey of Indoor Inertial Positioning Systems for Pedestrians.)

Weinberg, H. (2002).
Using the ADXL202 in Pedometer and Personal Navigation Applications.
(Weinberg, H. (2002).
Using the ADXL202 in Pedometer and Personal Navigation Applications.)

Brajdic, A. & Harle, R. (2013).
Walk Detection and Step Counting on Unconstrained Smartphones.
(Brajdic, A. & Harle, R. (2013).
Walk Detection and Step Counting on Unconstrained Smartphones.)

Ignatov, A. (2018).
Real-time Human Activity Recognition from Accelerometer Data Using Convolutional Neural Networks.
(Ignatov, A. (2018).
Real-time Human Activity Recognition from Accelerometer Data Using Convolutional Neural Networks.)

Geng, J. et al. (2021).
Smartphone-Based Pedestrian Dead Reckoning for 3D Indoor Positioning.
(Geng, J. vd. (2021).
Smartphone-Based Pedestrian Dead Reckoning for 3D Indoor Positioning.)
```

---

# 205. DOI Registry (DOI Registry)

```text
Kalman 1960
10.1115/1.3662552

Harle 2013
10.1109/SURV.2012.121912.00075

Brajdic & Harle 2013
10.1145/2493432.2493449

Ignatov 2018
10.1016/j.asoc.2017.09.027

Geng et al. 2021
10.3390/s21248180

Simon 2006
10.1002/0470045345
```

---

# 206. Academic Source Verification Rule (Akademik Kaynak Doğrulama Kuralı)

Final bibliography metadata should be checked once more against the publisher or DOI record before submission. *(Final bibliography metadata submission öncesinde publisher veya DOI record üzerinden one more time checked edilmelidir.)*

---

# 207. Reference Management Recommendation (Referans Yönetimi Önerisi)

The final report should store references in a machine-readable citation manager or BibTeX file to prevent inconsistent author, title, year, and DOI formatting. *(Final report inconsistent author, title, year ve DOI formatting'i prevent etmek için reference'ları machine-readable citation manager veya BibTeX file içerisinde stored etmelidir.)*

---

# 208. Suggested BibTeX Key Pattern (Önerilen BibTeX Key Pattern)

```text
Kalman1960
WelchBishop2006
Simon2006
Harle2013PDRSurvey
Weinberg2002Pedometer
BrajdicHarle2013
Ignatov2018HAR
Geng2021SmartphonePDR
```

---

# 209. Platform Reference Key Pattern (Platform Referans Key Pattern)

```text
AndroidSensorEvent2026
AndroidLocationManager2026
AndroidGeomagneticField2026
FlutterPlatformChannels2026
ARCoreTrackingState2026
ARCoreFrame2026
ARCoreSupportedDevices2026
LiteRTAndroid2026
LiteRTCompiledModel2026
```

---

# 210. No Citation to Final Result Rule (Final Sonuca Citation Olmaması Kuralı)

NAVGUARD's own final performance values should cite project experiment evidence, not external research papers. *(NAVGUARD'ın own final performance value'ları external research paper'ları değil project experiment evidence'ı cite etmelidir.)*

---

# 211. Comparison with Literature Rule (Literature ile Comparison Kuralı)

External performance results may be discussed only as contextual comparisons when differences in device, route, reference system, placement, participants, and methodology are made explicit. *(External performance result'ları yalnızca device, route, reference system, placement, participant ve methodology difference'ları explicit hale getirildiğinde contextual comparison olarak discussed edilebilir.)*

---

# 212. No Direct Accuracy Ranking Rule (Direct Accuracy Ranking Olmaması Kuralı)

NAVGUARD should not claim to outperform another published system solely because two reported error numbers differ under incomparable experiments. *(NAVGUARD incomparable experiment'ler altındaki two reported error number farklı olduğu için another published system'ı outperform ettiğini claim etmemelidir.)*

---

# 213. Reference Integrity Audit (Referans Bütünlük Audit'i)

Before final report submission, every in-text citation should map to one bibliography entry and every bibliography entry should be used or intentionally marked as background reading. *(Final report submission öncesinde every in-text citation one bibliography entry'ye map edilmeli ve every bibliography entry used edilmeli veya intentionally background reading olarak marked edilmelidir.)*

---

# 214. Dead-Link Mitigation (Dead-Link Mitigation)

Important platform sources should be recorded by title and organization, not by URL alone, so they remain discoverable if site paths change. *(Important platform source'lar site path değişse bile discoverable kalmaları için URL alone yerine title ve organization ile recorded edilmelidir.)*

---

# 215. Archived Evidence Rule (Archived Evidence Kuralı)

If a platform API changes materially during the project, a snapshot or release-specific documentation reference may be preserved in the final evidence package. *(Platform API project sırasında materially değişirse snapshot veya release-specific documentation reference final evidence package içerisinde preserved edilebilir.)*

---

# 216. Dependency Manifest Link (Dependency Manifest Bağlantısı)

Page 44 documents why technologies were selected, while the final dependency manifest will document the exact versions that were actually built. *(Page 44 technology'lerin neden selected edildiğini document ederken final dependency manifest actually built edilen exact version'ları document edecektir.)*

---

# 217. Change Log Link (Change Log Bağlantısı)

If a major technology changes after implementation begins, Page 43 must record the change and Page 44 must update the corresponding reference set. *(Implementation başladıktan sonra major technology değişirse Page 43 change'i record etmeli ve Page 44 corresponding reference set'i update etmelidir.)*

---

# 218. Page 41 Link (Page 41 Bağlantısı)

Page 41 will contain measured NAVGUARD results and should not be populated using numerical claims from any external reference listed here. *(Page 41 measured NAVGUARD result'larını içerecek ve burada listed herhangi bir external reference'tan numerical claim kullanılarak populate edilmemelidir.)*

---

# 219. Page 42 Link (Page 42 Bağlantısı)

Page 42 may use the literature to contextualize limitations, but the final priority of those limitations must come from measured project behavior. *(Page 42 limitation'ları contextualize etmek için literature kullanabilir ancak those limitation'ların final priority'si measured project behavior'dan gelmelidir.)*

---

# 220. Reference Set Freeze (Referans Set Freeze)

The reference set itself does not need to freeze as early as estimator parameters. *(Reference set'in kendisinin estimator parameter'ları kadar early freeze olması gerekmez.)*

New relevant literature may be added until the final report is submitted, provided it does not become a justification for post-hoc benchmark tuning. *(New relevant literature final report submitted edilene kadar added edilebilir; ancak post-hoc benchmark tuning için justification haline gelmemelidir.)*

---

# 221. Literature After Benchmark Rule (Benchmark Sonrası Literature Kuralı)

A newly discovered paper after benchmark completion may improve discussion and interpretation but must not retroactively change the frozen benchmark algorithm. *(Benchmark completion sonrasında newly discovered paper discussion ve interpretation'ı improve edebilir ancak frozen benchmark algorithm'ı retroactively change etmemelidir.)*

---

# 222. Reproducible Citation Package (Reproducible Citation Package)

The final repository should ideally contain a bibliography file, dependency manifest, benchmark configuration snapshot, model registry, and documentation revision identifier. *(Final repository ideally bibliography file, dependency manifest, benchmark configuration snapshot, model registry ve documentation revision identifier içermelidir.)*

---

# 223. Minimum Reference Acceptance Criteria (Minimum Referans Kabul Kriterleri)

A final Page 44 is considered complete when all platform-critical claims have authoritative sources and all major algorithms have an identifiable theoretical or research reference. *(All platform-critical claim'ler authoritative source'a ve all major algorithm'lar identifiable theoretical veya research reference'a sahip olduğunda final Page 44 complete kabul edilir.)*

---

# 224. Platform-Critical Coverage (Platform-Critical Coverage)

Android sensor timestamps, GNSS provider behavior, GNSS elapsed-realtime timing, ARCore tracking state, ARCore pose axes, ARCore frame timing, target-device ARCore support, Flutter platform integration, and LiteRT Android deployment are now covered by official references. *(Android sensor timestamp'leri, GNSS provider behavior, GNSS elapsed-realtime timing, ARCore tracking state, ARCore pose axis'leri, ARCore frame timing, target-device ARCore support, Flutter platform integration ve LiteRT Android deployment artık official reference'lar ile covered durumdadır.)*

---

# 225. Mathematical Coverage (Mathematical Coverage)

WGS84, ECEF/ENU conversion, horizontal covariance interpretation, PDR, and Kalman filtering are covered by authoritative standards-oriented or academic sources. *(WGS84, ECEF/ENU conversion, horizontal covariance interpretation, PDR ve Kalman filtering authoritative standards-oriented veya academic source'lar ile covered durumdadır.)*

---

# 226. AI Coverage (AI Coverage)

Grouped model evaluation, Macro F1, Random Forest baselines, temporal Conv1D layers, early stopping, model conversion, and Android edge inference are covered by official machine-learning framework documentation and selected academic literature. *(Grouped model evaluation, Macro F1, Random Forest baseline'ları, temporal Conv1D layer'ları, early stopping, model conversion ve Android edge inference official machine-learning framework documentation ve selected academic literature ile covered durumdadır.)*

---

# 227. Remaining Evidence-Gated Areas (Kalan Evidence-Gated Alanlar)

The reference base does not yet determine final step thresholds, heading-filter coefficients, AI window duration, AI winning model, `Q/R`, NIS gate, ARCore alignment, ARCore clock mapping, recovery thresholds, route geometry, logging buffer size, or final performance values. *(Reference base henüz final step threshold'larını, heading-filter coefficient'lerini, AI window duration'ı, AI winning model'i, `Q/R`, NIS gate'i, ARCore alignment'ı, ARCore clock mapping'i, recovery threshold'larını, route geometry'yi, logging buffer size'ı veya final performance value'larını determine etmez.)*

---

# 228. Why These Remain Pending (Bunlar Neden Pending Kalır)

These values depend on the physical Redmi Note 9 Pro, actual participant data, implementation behavior, and pilot experiments rather than universal literature constants. *(Bu value'lar universal literature constant'ları yerine physical Redmi Note 9 Pro, actual participant data, implementation behavior ve pilot experiment'lere bağlıdır.)*

---

# 229. Final Reference Governance Decision (Final Referans Governance Kararı)

External sources define platform semantics and research context, while internal evidence defines target-device parameterization and final claims. *(External source'lar platform semantic'lerini ve research context'i define ederken internal evidence target-device parameterization ve final claim'leri define eder.)*

---

# 230. Final References Statement (Nihai Referans Bildirimi)

**NAVGUARD's reference base combines official Android, Flutter, ARCore, LiteRT, Keras, scikit-learn, NGA, and ESA documentation with foundational and application-oriented literature covering pedestrian dead reckoning, step detection, activity recognition, and Kalman state estimation.** *(NAVGUARD'ın reference base'i official Android, Flutter, ARCore, LiteRT, Keras, scikit-learn, NGA ve ESA documentation'ını pedestrian dead reckoning, step detection, activity recognition ve Kalman state estimation'ı cover eden foundational ve application-oriented literature ile combine eder.)*

**Official platform documentation remains authoritative for runtime semantics such as Android sensor timestamps, `GPS_PROVIDER`, `Location.getElapsedRealtimeNanos()`, ARCore `TRACKING` validity, ARCore camera axes, undefined `Frame.getTimestamp()` time base, Flutter-native communication, and LiteRT deployment APIs.** *(Android sensor timestamp'leri, `GPS_PROVIDER`, `Location.getElapsedRealtimeNanos()`, ARCore `TRACKING` validity, ARCore camera axis'leri, undefined `Frame.getTimestamp()` time base, Flutter-native communication ve LiteRT deployment API'leri gibi runtime semantic'ler için official platform documentation authoritative kalır.)*

**Academic literature provides the theoretical foundation for step-and-heading PDR, smartphone pedometry, Motion Classification with temporal convolutional models, and recursive state estimation, but published algorithms and thresholds will not be copied blindly into the target-device implementation.** *(Academic literature step-and-heading PDR, smartphone pedometry, temporal convolutional model'larla Motion Classification ve recursive state estimation için theoretical foundation sağlar ancak published algorithm ve threshold'lar target-device implementation'a blindly copied edilmeyecektir.)*

**WGS84 and ECEF-to-ENU mathematics are grounded in geodetic references, while NAVGUARD's specific ENU anchor, `[E,N,ψ]` EKF state, process equations, Ground Truth Firewall, A-D configurations, and benchmark methodology remain project-specific engineering and research decisions.** *(WGS84 ve ECEF-to-ENU mathematics geodetic reference'lara grounded iken NAVGUARD'ın specific ENU anchor'ı, `[E,N,ψ]` EKF state'i, process equation'ları, Ground Truth Firewall'u, A-D configuration'ları ve benchmark methodology'si project-specific engineering ve research decision olarak kalır.)*

**No external publication will substitute for physical evidence when determining final sampling behavior, detector thresholds, model selection, ARCore alignment, timestamp mapping, covariance parameters, recovery policy, runtime performance, or final navigation accuracy on the Xiaomi Redmi Note 9 Pro.** *(Xiaomi Redmi Note 9 Pro üzerinde final sampling behavior, detector threshold'ları, model selection, ARCore alignment, timestamp mapping, covariance parameter'ları, recovery policy, runtime performance veya final navigation accuracy determine edilirken hiçbir external publication physical evidence'ın yerini almayacaktır.)*

**The final benchmark will therefore remain evidence-first: literature explains the methods, official documentation defines the APIs, and NAVGUARD's own frozen experiments determine whether the implementation actually satisfies its research question.** *(Bu nedenle final benchmark evidence-first kalacaktır; literature method'ları açıklar, official documentation API'leri define eder ve NAVGUARD'ın own frozen experiment'leri implementation'ın research question'ını actually satisfy edip etmediğini determine eder.)*

---

# 231. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Initial Authoritative References & Technical Resources Baseline Completed *(Doküman Durumu: Initial Authoritative References & Technical Resources Baseline Tamamlandı)*

**Reference Validation Date:** `2026-09-01` *(Referans Doğrulama Tarihi: `2026-09-01`)*

**Official Android References:** Included *(Official Android Reference'lar: Dahil Edildi)*

**Official Flutter References:** Included *(Official Flutter Reference'lar: Dahil Edildi)*

**Official ARCore References:** Included *(Official ARCore Reference'lar: Dahil Edildi)*

**Official LiteRT References:** Included *(Official LiteRT Reference'lar: Dahil Edildi)*

**Official scikit-learn References:** Included *(Official scikit-learn Reference'lar: Dahil Edildi)*

**Official Keras / TensorFlow References:** Included *(Official Keras / TensorFlow Reference'lar: Dahil Edildi)*

**WGS84 Reference:** NGA *(WGS84 Referansı: NGA)*

**ECEF ↔ ENU Reference:** ESA Navipedia *(ECEF ↔ ENU Referansı: ESA Navipedia)*

**Primary PDR Survey:** Harle 2013 *(Primary PDR Survey: Harle 2013)*

**Primary Step-Length Historical Reference:** Weinberg AN-602 *(Primary Step-Length Historical Referansı: Weinberg AN-602)*

**Smartphone Step-Detection Reference:** Brajdic & Harle 2013 *(Smartphone Step-Detection Referansı: Brajdic & Harle 2013)*

**Motion CNN Reference:** Ignatov 2018 *(Motion CNN Referansı: Ignatov 2018)*

**Kalman Foundation:** Kalman 1960 *(Kalman Foundation: Kalman 1960)*

**EKF Practical Reference:** Welch & Bishop *(EKF Practical Referansı: Welch & Bishop)*

**Advanced State-Estimation Reference:** Dan Simon 2006 *(Advanced State-Estimation Referansı: Dan Simon 2006)*

**ARCore Redmi Note 9 Pro Published Support:** Confirmed in Current Google Device List *(ARCore Redmi Note 9 Pro Published Support: Current Google Device List'te Doğrulandı)*

**ARCore Physical Runtime Validation:** Still Required *(ARCore Physical Runtime Validation: Hâlâ Gerekli)*

**Android Sensor Timestamp Time Base:** `elapsedRealtimeNanos()` compatible *(Android Sensor Timestamp Time Base: `elapsedRealtimeNanos()` compatible)*

**GNSS Measurement Timestamp:** `Location.getElapsedRealtimeNanos()` *(GNSS Measurement Timestamp: `Location.getElapsedRealtimeNanos()`)*

**ARCore `Frame.getTimestamp()` Time Base:** Explicitly Undefined by ARCore *(ARCore `Frame.getTimestamp()` Time Base: ARCore Tarafından Explicitly Undefined)*

**Formal GNSS Provider:** `GPS_PROVIDER` *(Formal GNSS Provider: `GPS_PROVIDER`)*

**Fused Provider as Formal Ground Truth:** Rejected *(Fused Provider'ın Formal Ground Truth Olması: Reddedildi)*

**LiteRT Preferred New-Work Direction:** `CompiledModel` *(LiteRT Preferred New-Work Direction: `CompiledModel`)*

**LiteRT Compatibility Fallback:** `Interpreter` *(LiteRT Compatibility Fallback: `Interpreter`)*

**Exact LiteRT Dependency Version:** Pending Environment Bootstrap *(Exact LiteRT Dependency Version: Environment Bootstrap Bekliyor)*

**AI Split Principle:** Physical-Session Grouping *(AI Split Principle: Physical-Session Grouping)*

**AI Primary Metric Reference:** Macro F1 *(AI Primary Metric Referansı: Macro F1)*

**1D-CNN Technical Reference:** Keras Conv1D + HAR Literature *(1D-CNN Teknik Referansı: Keras Conv1D + HAR Literature)*

**WGS84 → ECEF → ENU Architecture:** Externally Supported *(WGS84 → ECEF → ENU Architecture: External Source ile Desteklendi)*

**External Threshold Copying:** Forbidden *(External Threshold Copying: Yasak)*

**External Accuracy Reuse as NAVGUARD Result:** Forbidden *(External Accuracy'nin NAVGUARD Result Olarak Reuse Edilmesi: Yasak)*

**Final Device Parameters:** Internal Evidence Required *(Final Device Parameter'ları: Internal Evidence Gerekli)*

**Final Page 41 Results:** Internal Benchmark Evidence Only *(Final Page 41 Result'ları: Yalnızca Internal Benchmark Evidence)*

**Final Reference Refresh:** Required Before Report Submission *(Final Reference Refresh: Report Submission Öncesi Gerekli)*

**Master Structure Page 44:** Completed *(Master Structure Page 44: Tamamlandı)*


