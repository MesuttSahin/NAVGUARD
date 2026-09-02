# 38 — 24-Day Development Roadmap (24 Günlük Geliştirme Yol Haritası)

## 1. Document Purpose (Dokümanın Amacı)

This document converts the complete NAVGUARD architecture into a practical 24-business-day development, validation, field-testing, and benchmark roadmap. *(Bu doküman tam NAVGUARD mimarisini pratik 24 iş günlük geliştirme, doğrulama, saha testi ve benchmark yol haritasına dönüştürür.)*

The roadmap prioritizes research-critical functionality before optional enhancements so that a scientifically defensible minimum system can still be completed if schedule pressure occurs. *(Yol haritası optional enhancement'lardan önce research-critical functionality'ye öncelik verir; böylece takvim baskısı oluşsa bile bilimsel olarak savunulabilir minimum sistem tamamlanabilir.)*

---

# 2. Roadmap Philosophy (Yol Haritası Felsefesi)

NAVGUARD will not be developed by implementing all subsystems independently and integrating them only at the end. *(NAVGUARD tüm alt sistemleri bağımsız geliştirip yalnızca sonunda entegre ederek geliştirilmeyecektir.)*

Integration, replay, automated testing, logging, and field validation will be introduced progressively throughout the 24 days. *(Integration, replay, automated testing, logging ve saha validation 24 gün boyunca aşamalı olarak eklenecektir.)*

---

# 3. Core Development Principle (Temel Geliştirme İlkesi)

The implementation order will follow dependency order rather than documentation order alone. *(Implementation sırası yalnızca dokümantasyon sırasını değil dependency sırasını izleyecektir.)*

---

# 4. Minimum Research System First (Önce Minimum Araştırma Sistemi)

A functioning GNSS-anchor → software denial → PDR → logging → recovery → evaluation pipeline will be established before optional full-stack optimization. *(Çalışan GNSS-anchor → software denial → PDR → logging → recovery → evaluation pipeline optional full-stack optimization öncesinde kurulacaktır.)*

---

# 5. Progressive Complexity Principle (Aşamalı Karmaşıklık İlkesi)

The development sequence will progress through deterministic navigation, reproducible evidence, AI assistance, ARCore assistance, EKF fusion, and final benchmark validation. *(Geliştirme sırası deterministic navigation, reproducible evidence, AI assistance, ARCore assistance, EKF fusion ve final benchmark validation üzerinden ilerleyecektir.)*

---

# 6. Roadmap Phases (Yol Haritası Fazları)

The 24-day roadmap is divided into six phases. *(24 günlük yol haritası altı faza ayrılmıştır.)*

```text
PHASE 1 — FOUNDATION & DEVICE AUDIT
Days 1–4
(Faz 1 — Temel Altyapı ve Cihaz Denetimi
Gün 1–4)

PHASE 2 — DETERMINISTIC NAVIGATION CORE
Days 5–9
(Faz 2 — Deterministik Navigasyon Çekirdeği
Gün 5–9)

PHASE 3 — AI & ARCORE ENHANCEMENTS
Days 10–14
(Faz 3 — AI ve ARCore Geliştirmeleri
Gün 10–14)

PHASE 4 — EKF, RECOVERY & FULL INTEGRATION
Days 15–18
(Faz 4 — EKF, Recovery ve Tam Entegrasyon
Gün 15–18)

PHASE 5 — PILOT, CALIBRATION & FREEZE
Days 19–21
(Faz 5 — Pilot, Kalibrasyon ve Freeze
Gün 19–21)

PHASE 6 — FINAL BENCHMARK & DELIVERY
Days 22–24
(Faz 6 — Final Benchmark ve Teslim
Gün 22–24)
```

---

# 7. Daily Completion Rule (Günlük Tamamlama Kuralı)

Each day will end with a demonstrable artifact, passing test set, collected evidence, or explicit documented blocker. *(Her gün demonstrable artifact, geçen test seti, toplanmış evidence veya açık şekilde documented blocker ile sona erecektir.)*

---

# 8. No “Code Written” Completion Criterion (`Code Written` Tamamlama Kriteri Değildir)

Writing code alone does not count as completion. *(Yalnızca kod yazmak completion sayılmaz.)*

A feature is considered complete only when its relevant validation and logging behavior also work. *(Bir feature yalnızca ilgili validation ve logging behavior da çalıştığında complete kabul edilir.)*

---

# 9. Daily Test Discipline (Günlük Test Disiplini)

Automated tests will be run continuously rather than postponed until Day 23. *(Automated testler Day 23'e ertelenmek yerine sürekli çalıştırılacaktır.)*

---

# 10. Daily Documentation Discipline (Günlük Dokümantasyon Disiplini)

Important architecture changes and parameter decisions will be recorded as development progresses. *(Önemli architecture change ve parameter decision'lar development ilerledikçe kaydedilecektir.)*

---

# 11. Scope Protection Rule (Kapsam Koruma Kuralı)

Optional features will be removed before core benchmark integrity is compromised. *(Core benchmark integrity compromise edilmeden önce optional feature'lar kaldırılacaktır.)*

---

# 12. Critical Path (Kritik Yol)

The project critical path is defined below. *(Projenin critical path'i aşağıda tanımlanmıştır.)*

```text
DEVICE AUDIT
    ↓
SENSOR ACQUISITION
    ↓
TIMING / SYNCHRONIZATION
    ↓
GNSS ANCHOR + FIREWALL
    ↓
STEP DETECTION
    ↓
HEADING
    ↓
DETERMINISTIC STEP LENGTH
    ↓
PDR
    ↓
LOGGING + REPLAY
    ↓
AI / ARCORE
    ↓
EKF
    ↓
RECOVERY
    ↓
PILOT
    ↓
FREEZE
    ↓
FINAL BENCHMARK
```

---

# 13. Day 1 — Project Skeleton & Device Capability Audit (Gün 1 — Proje İskeleti ve Cihaz Yeteneği Denetimi)

Day 1 establishes the executable project structure and verifies the real capabilities of the Xiaomi Redmi Note 9 Pro. *(Gün 1 executable proje yapısını kurar ve Xiaomi Redmi Note 9 Pro'nun gerçek capability'lerini doğrular.)*

---

# 14. Day 1 Flutter Tasks (Gün 1 Flutter Görevleri)

Create the Flutter application shell and core navigation structure. *(Flutter application shell ve core navigation yapısını oluştur.)*

Create basic screens for readiness, live navigation, diagnostics, and session review. *(Readiness, live navigation, diagnostics ve session review için basic screen'ler oluştur.)*

---

# 15. Day 1 Native Android Tasks (Gün 1 Native Android Görevleri)

Create the Kotlin platform layer for sensors, GNSS, and capability checks. *(Sensörler, GNSS ve capability check'leri için Kotlin platform layer oluştur.)*

---

# 16. Day 1 Device Audit Tasks (Gün 1 Cihaz Audit Görevleri)

Enumerate accelerometer, gyroscope, magnetometer, Rotation Vector, GNSS availability, camera capability, and any available pressure sensor. *(Accelerometer, gyroscope, magnetometer, Rotation Vector, GNSS availability, camera capability ve available pressure sensor'ları enumerate et.)*

---

# 17. Day 1 ARCore Audit (Gün 1 ARCore Audit'i)

Verify ARCore support and installation state on the Redmi Note 9 Pro. *(Redmi Note 9 Pro üzerinde ARCore support ve installation state'i doğrula.)*

---

# 18. Day 1 Sensor Metadata (Gün 1 Sensör Metadata)

Record sensor names, vendors, resolution, reported maximum range, minimum delay, and Android sensor identifiers where available. *(Available olduğunda sensor name, vendor, resolution, reported maximum range, minimum delay ve Android sensor identifier'larını kaydet.)*

---

# 19. Day 1 Deliverable (Gün 1 Teslimi)

A device-capability report must be generated from the physical phone rather than from assumptions. *(Device-capability report assumption'lardan değil fiziksel telefondan üretilmelidir.)*

---

# 20. Day 1 Exit Criteria (Gün 1 Çıkış Kriterleri)

The application must launch on the Redmi Note 9 Pro. *(Uygulama Redmi Note 9 Pro üzerinde başlamalıdır.)*

Flutter-to-Kotlin communication must work. *(Flutter-to-Kotlin communication çalışmalıdır.)*

Required sensors must be enumerated successfully. *(Gerekli sensörler başarıyla enumerate edilmelidir.)*

---

# 21. Day 2 — Sensor Acquisition Infrastructure (Gün 2 — Sensör Toplama Altyapısı)

Day 2 builds the authoritative raw motion-sensor acquisition layer. *(Gün 2 authoritative raw motion-sensor acquisition layer'ı kurar.)*

---

# 22. Day 2 Accelerometer Implementation (Gün 2 İvmeölçer Implementation)

Implement timestamped accelerometer acquisition through Android `SensorManager`. *(Android `SensorManager` üzerinden timestamped accelerometer acquisition uygula.)*

---

# 23. Day 2 Gyroscope Implementation (Gün 2 Jiroskop Implementation)

Implement timestamped gyroscope acquisition through Android `SensorManager`. *(Android `SensorManager` üzerinden timestamped gyroscope acquisition uygula.)*

---

# 24. Day 2 Magnetometer Implementation (Gün 2 Manyetometre Implementation)

Implement timestamped magnetometer acquisition and sensor-accuracy reporting. *(Timestamped magnetometer acquisition ve sensor-accuracy reporting uygula.)*

---

# 25. Day 2 Rotation Vector Implementation (Gün 2 Rotation Vector Implementation)

Add Rotation Vector acquisition as a candidate high-priority orientation source. *(Rotation Vector acquisition'ı candidate high-priority orientation source olarak ekle.)*

---

# 26. Day 2 Sequence Numbers (Gün 2 Sequence Number'ları)

Every sensor stream should receive monotonic sequence counters for diagnostics. *(Her sensor stream diagnostic için monotonic sequence counter almalıdır.)*

---

# 27. Day 2 Raw Logging (Gün 2 Raw Logging)

Implement initial append-oriented raw sensor logging. *(Initial append-oriented raw sensor logging uygula.)*

---

# 28. Day 2 Sampling Test (Gün 2 Sampling Testi)

Measure actual delivered rates at candidate request configurations such as approximately 20 Hz, 50 Hz, and 100 Hz where useful. *(Kullanışlı olduğunda yaklaşık 20 Hz, 50 Hz ve 100 Hz gibi candidate request configuration'larda actual delivered rate'leri ölç.)*

---

# 29. Day 2 Deliverable (Gün 2 Teslimi)

Produce physical sensor-rate and timing evidence from the Redmi Note 9 Pro. *(Redmi Note 9 Pro'dan fiziksel sensor-rate ve timing evidence üret.)*

---

# 30. Day 2 Exit Criteria (Gün 2 Çıkış Kriterleri)

Accelerometer, gyroscope, and magnetometer streams must record continuously without unexplained callback failure. *(Accelerometer, gyroscope ve magnetometer stream'leri açıklanamayan callback failure olmadan continuous record etmelidir.)*

---

# 31. Day 3 — Timing, Synchronization & Preprocessing (Gün 3 — Zamanlama, Senkronizasyon ve Ön İşleme)

Day 3 establishes the common timing model required by every later fusion stage. *(Gün 3 sonraki tüm fusion stage'lerin gerektirdiği common timing model'i kurar.)*

---

# 32. Day 3 Timestamp Validation (Gün 3 Timestamp Validation)

Verify sensor timestamp monotonicity and inter-sample intervals. *(Sensor timestamp monotonicity ve inter-sample interval'ları doğrula.)*

---

# 33. Day 3 Common Event Model (Gün 3 Ortak Event Model'i)

Create timestamped domain objects for sensor, GNSS, step, heading, ARCore, AI, and estimator events. *(Sensor, GNSS, step, heading, ARCore, AI ve estimator event'leri için timestamped domain object'ler oluştur.)*

---

# 34. Day 3 Synchronization Buffers (Gün 3 Senkronizasyon Buffer'ları)

Implement bounded synchronization buffers for multi-sensor processing. *(Multi-sensor processing için bounded synchronization buffer'lar uygula.)*

---

# 35. Day 3 Gap Detection (Gün 3 Gap Detection)

Implement detection of stale, missing, duplicate, and out-of-order samples. *(Stale, missing, duplicate ve out-of-order sample detection uygula.)*

---

# 36. Day 3 Resampling Infrastructure (Gün 3 Resampling Altyapısı)

Create bounded interpolation and resampling utilities needed by AI windows. *(AI window'larının gerektirdiği bounded interpolation ve resampling utility'lerini oluştur.)*

---

# 37. Day 3 Golden Timing Tests (Gün 3 Golden Timing Testleri)

Create synthetic timestamp sequences and deterministic synchronization tests. *(Synthetic timestamp sequence'leri ve deterministic synchronization testleri oluştur.)*

---

# 38. Day 3 Exit Criteria (Gün 3 Çıkış Kriterleri)

Sensor timing must be reproducible in offline test fixtures. *(Sensor timing offline test fixture'larında reproducible olmalıdır.)*

Invalid gaps must be detectable. *(Invalid gap'ler detectable olmalıdır.)*

---

# 39. Day 4 — GNSS, Anchor & Ground Truth Firewall (Gün 4 — GNSS, Anchor ve Ground Truth Firewall)

Day 4 establishes GNSS acquisition and the most important research-integrity boundary in NAVGUARD. *(Gün 4 GNSS acquisition'ı ve NAVGUARD'daki en önemli research-integrity boundary'yi kurar.)*

---

# 40. Day 4 GNSS Provider (Gün 4 GNSS Provider)

Implement formal GNSS acquisition with Android `LocationManager` and the configured `GPS_PROVIDER`. *(Android `LocationManager` ve configured `GPS_PROVIDER` ile formal GNSS acquisition uygula.)*

---

# 41. Day 4 GNSS Timing (Gün 4 GNSS Timing)

Use monotonic GNSS timestamps based on the Android elapsed-realtime timing field. *(Android elapsed-realtime timing field'e dayanan monotonic GNSS timestamp'leri kullan.)*

---

# 42. Day 4 Anchor Manager (Gün 4 Anchor Manager)

Implement candidate anchor validation rather than accepting the first fix automatically. *(İlk fix'i otomatik kabul etmek yerine candidate anchor validation uygula.)*

---

# 43. Day 4 ENU Anchor Creation (Gün 4 ENU Anchor Oluşturma)

Create the local ENU coordinate origin from the accepted WGS84 anchor. *(Accepted WGS84 anchor'dan local ENU coordinate origin oluştur.)*

---

# 44. Day 4 Ground Truth Firewall (Gün 4 Ground Truth Firewall)

Implement estimator authorization that prevents protected Evaluation GNSS from reaching denied navigation. *(Protected Evaluation GNSS'in denied navigation'a ulaşmasını önleyen estimator authorization uygula.)*

---

# 45. Day 4 Firewall Counter (Gün 4 Firewall Counter)

Implement `unauthorizedGnssEstimatorUpdateCount`. *(`unauthorizedGnssEstimatorUpdateCount` uygula.)*

---

# 46. Day 4 Evaluation Logging (Gün 4 Evaluation Logging)

Protected GNSS must remain independently loggable while estimator authorization is blocked. *(Estimator authorization blocked iken protected GNSS independently loggable kalmalıdır.)*

---

# 47. Day 4 Firewall Mutation Test (Gün 4 Firewall Mutation Testi)

Replay or synthetic tests should change protected GNSS values and verify that denied estimator state remains unchanged. *(Replay veya synthetic testler protected GNSS value'larını değiştirmeli ve denied estimator state'in unchanged kaldığını doğrulamalıdır.)*

---

# 48. Day 4 Exit Criteria (Gün 4 Çıkış Kriterleri)

The Ground Truth Firewall must pass before subsequent formal estimator development is trusted. *(Sonraki formal estimator development trusted edilmeden önce Ground Truth Firewall pass etmelidir.)*

---

# 49. Phase 1 Completion Gate (Faz 1 Tamamlama Gate'i)

At the end of Day 4, NAVGUARD must have verified device capabilities, authoritative sensor streams, validated timing infrastructure, GNSS acquisition, anchor creation, and estimator-ground-truth isolation. *(Day 4 sonunda NAVGUARD verified device capability, authoritative sensor stream, validated timing infrastructure, GNSS acquisition, anchor creation ve estimator-ground-truth isolation'a sahip olmalıdır.)*

---

# 50. Day 5 — Coordinate Mathematics & PDR Foundations (Gün 5 — Koordinat Matematiği ve PDR Temelleri)

Day 5 implements the deterministic mathematical backbone. *(Gün 5 deterministic mathematical backbone'u uygular.)*

---

# 51. Day 5 WGS84/ECEF/ENU Utilities (Gün 5 WGS84/ECEF/ENU Utility'leri)

Implement authoritative WGS84 ↔ ECEF ↔ ENU conversion functions. *(Authoritative WGS84 ↔ ECEF ↔ ENU conversion function'larını uygula.)*

---

# 52. Day 5 Round-Trip Tests (Gün 5 Round-Trip Testleri)

Add coordinate round-trip unit tests and known-reference tests. *(Coordinate round-trip unit test ve known-reference test'leri ekle.)*

---

# 53. Day 5 Heading Convention Utilities (Gün 5 Heading Convention Utility'leri)

Implement true-north clockwise heading normalization and circular difference functions. *(True-north clockwise heading normalization ve circular difference function'larını uygula.)*

---

# 54. Day 5 PDR State (Gün 5 PDR State)

Implement the local PDR state in East and North metres. *(Local PDR state'i East ve North metre cinsinden uygula.)*

---

# 55. Day 5 PDR Propagation (Gün 5 PDR Propagation)

Implement the core step propagation equations. *(Core step propagation equation'larını uygula.)*

```text
ΔE = L sin(ψ)
ΔN = L cos(ψ)

E_k = E_(k-1) + ΔE
N_k = N_(k-1) + ΔN
```

---

# 56. Day 5 Cardinal Tests (Gün 5 Cardinal Testleri)

Create North, East, South, West, and synthetic closed-loop PDR tests. *(North, East, South, West ve synthetic closed-loop PDR testleri oluştur.)*

---

# 57. Day 5 Exit Criteria (Gün 5 Çıkış Kriterleri)

Synthetic step sequences must produce mathematically correct deterministic trajectories. *(Synthetic step sequence'leri matematiksel olarak doğru deterministic trajectory üretmelidir.)*

---

# 58. Day 6 — Step Detection System (Gün 6 — Adım Tespit Sistemi)

Day 6 implements the independent deterministic step detector. *(Gün 6 independent deterministic step detector'ı uygular.)*

---

# 59. Day 6 Acceleration Representation (Gün 6 İvme Representation)

Implement candidate acceleration-magnitude preprocessing and filtered signal representation. *(Candidate acceleration-magnitude preprocessing ve filtered signal representation uygula.)*

---

# 60. Day 6 Peak Detector (Gün 6 Peak Detector)

Implement a deterministic candidate peak-based step detector with configurable thresholds. *(Configurable threshold'lara sahip deterministic candidate peak-based step detector uygula.)*

---

# 61. Day 6 Refractory Timing (Gün 6 Refractory Timing)

Add minimum inter-step timing protection against duplicate peaks. *(Duplicate peak'lere karşı minimum inter-step timing protection ekle.)*

---

# 62. Day 6 StepEvent (Gün 6 StepEvent)

Every accepted step must produce a timestamped `StepEvent`. *(Her accepted step timestamped `StepEvent` üretmelidir.)*

---

# 63. Day 6 Controlled Walking Test (Gün 6 Kontrollü Yürüyüş Testi)

Perform short known-step walking sessions on the target device. *(Target device üzerinde kısa known-step walking session'ları gerçekleştir.)*

---

# 64. Day 6 Step Error Baseline (Gün 6 Step Error Baseline)

Calculate initial controlled step-count percentage error. *(Initial controlled step-count percentage error hesapla.)*

---

# 65. Day 6 Exit Criteria (Gün 6 Çıkış Kriterleri)

The detector must operate causally and replay deterministically. *(Detector causal şekilde çalışmalı ve replay deterministically olmalıdır.)*

---

# 66. Day 7 — Heading Estimation System (Gün 7 — Heading Estimation Sistemi)

Day 7 builds a true-north heading pipeline independent from GNSS movement bearing. *(Gün 7 GNSS movement bearing'den bağımsız true-north heading pipeline kurar.)*

---

# 67. Day 7 Magnetometer Heading (Gün 7 Magnetometer Heading)

Implement accelerometer/magnetometer-based Earth-referenced orientation. *(Accelerometer/magnetometer-based Earth-referenced orientation uygula.)*

---

# 68. Day 7 Gyroscope Propagation (Gün 7 Gyroscope Propagation)

Implement short-term gyroscope heading propagation. *(Short-term gyroscope heading propagation uygula.)*

---

# 69. Day 7 Rotation Vector Candidate (Gün 7 Rotation Vector Adayı)

Integrate Rotation Vector as a candidate orientation source if device tests support it. *(Device testleri desteklerse Rotation Vector'ı candidate orientation source olarak entegre et.)*

---

# 70. Day 7 Declination Correction (Gün 7 Declination Correction)

Implement geomagnetic declination correction to true north. *(True north'a geomagnetic declination correction uygula.)*

---

# 71. Day 7 Magnetic Quality (Gün 7 Magnetic Quality)

Create the first magnetic-disturbance and heading-quality diagnostics. *(İlk magnetic-disturbance ve heading-quality diagnostic'lerini oluştur.)*

---

# 72. Day 7 Cardinal Field Test (Gün 7 Cardinal Field Testi)

Physically test North, East, South, and West orientation behavior. *(North, East, South ve West orientation behavior'ı fiziksel olarak test et.)*

---

# 73. Day 7 Exit Criteria (Gün 7 Çıkış Kriterleri)

Heading sign, coordinate convention, and circular normalization must be validated on-device. *(Heading sign, coordinate convention ve circular normalization on-device validated olmalıdır.)*

---

# 74. Day 8 — Step Length Baselines & Complete PDR (Gün 8 — Adım Uzunluğu Baseline'ları ve Tam PDR)

Day 8 completes the deterministic PDR baseline required for Configuration A. *(Gün 8 Configuration A için gerekli deterministic PDR baseline'ı tamamlar.)*

---

# 75. Day 8 Fixed Step Length (Gün 8 Sabit Adım Uzunluğu)

Implement calibrated fixed step-length estimation. *(Calibrated fixed step-length estimation uygula.)*

---

# 76. Day 8 Calibration Formula (Gün 8 Kalibrasyon Formülü)

Use controlled known-distance calibration when defensible. *(Savunulabilir olduğunda controlled known-distance calibration kullan.)*

```text
L_avg = D_ref / N_steps
```

---

# 77. Day 8 Deterministic Variable Step Length (Gün 8 Deterministik Değişken Adım Uzunluğu)

Implement a configurable deterministic variable candidate such as the calibrated Weinberg-style formulation. *(Calibrated Weinberg-style formulation gibi configurable deterministic variable candidate uygula.)*

```text
L = K(a_max - a_min)^(1/4)
```

---

# 78. Day 8 Step-Length Fallback Chain (Gün 8 Step-Length Fallback Zinciri)

Implement deterministic variable → fixed calibrated fallback. *(Deterministic variable → fixed calibrated fallback uygula.)*

---

# 79. Day 8 Full PDR Runtime (Gün 8 Tam PDR Runtime)

Connect accepted step event + heading-at-step-time + step length into live PDR propagation. *(Accepted step event + heading-at-step-time + step length'i live PDR propagation'a bağla.)*

---

# 80. Day 8 Baseline Map Output (Gün 8 Baseline Harita Çıktısı)

Convert local ENU state back to WGS84 for map visualization. *(Local ENU state'i map visualization için tekrar WGS84'e dönüştür.)*

---

# 81. Day 8 Exit Criteria (Gün 8 Çıkış Kriterleri)

Configuration A must be capable of GNSS anchor → denial → step-based PDR motion without AI, ARCore, or EKF. *(Configuration A AI, ARCore veya EKF olmadan GNSS anchor → denial → step-based PDR motion yapabilmelidir.)*

---

# 82. Day 9 — Session Storage, Replay & Evaluation Backbone (Gün 9 — Session Storage, Replay ve Evaluation Omurgası)

Day 9 makes the deterministic system scientifically reproducible. *(Gün 9 deterministic sistemi bilimsel olarak reproducible hale getirir.)*

---

# 83. Day 9 Session Manager (Gün 9 Session Manager)

Implement immutable session IDs and session lifecycle states. *(Immutable session ID ve session lifecycle state'lerini uygula.)*

---

# 84. Day 9 Artifact Structure (Gün 9 Artifact Yapısı)

Create structured per-session evidence directories and manifests. *(Structured per-session evidence directory ve manifest'leri oluştur.)*

---

# 85. Day 9 SQLite Metadata (Gün 9 SQLite Metadata)

Implement SQLite session metadata where required. *(Gerekli yerlerde SQLite session metadata uygula.)*

---

# 86. Day 9 Append-Oriented Evidence (Gün 9 Append-Oriented Evidence)

Finalize append-oriented CSV/JSON logging for high-rate evidence streams. *(High-rate evidence stream'leri için append-oriented CSV/JSON logging'i finalize et.)*

---

# 87. Day 9 Replay Engine (Gün 9 Replay Engine)

Create the first offline replay engine capable of reconstructing Configuration A. *(Configuration A'yı reconstruct edebilen ilk offline replay engine'i oluştur.)*

---

# 88. Day 9 Replay Determinism (Gün 9 Replay Determinizmi)

Run the same session twice and compare resulting trajectory and event outputs. *(Aynı session'ı iki kez çalıştır ve resulting trajectory ile event output'larını karşılaştır.)*

---

# 89. Day 9 Metric Backbone (Gün 9 Metric Omurgası)

Implement initial Python metric functions for ENU horizontal error, mean, median, RMSE, P95, and final error. *(ENU horizontal error, mean, median, RMSE, P95 ve final error için initial Python metric function'larını uygula.)*

---

# 90. Day 9 Phase 2 Gate (Gün 9 Faz 2 Gate'i)

By the end of Day 9, NAVGUARD must possess a fully replayable deterministic PDR baseline. *(Day 9 sonunda NAVGUARD tamamen replayable deterministic PDR baseline'a sahip olmalıdır.)*

---

# 91. Day 10 — Motion Dataset Collection Pipeline (Gün 10 — Hareket Dataset Toplama Pipeline'ı)

Day 10 begins the mandatory AI subsystem with structured data collection rather than immediate model training. *(Gün 10 mandatory AI subsystem'i immediate model training yerine structured data collection ile başlatır.)*

---

# 92. Day 10 Dataset Session Schema (Gün 10 Dataset Session Schema)

Implement data export containing session ID, timestamps, raw accelerometer, raw gyroscope, labels, and traceability metadata. *(Session ID, timestamp, raw accelerometer, raw gyroscope, label ve traceability metadata içeren data export uygula.)*

---

# 93. Day 10 Motion Classes (Gün 10 Motion Class'ları)

Use the frozen four-class target. *(Frozen dört-class target'ı kullan.)*

```text
STATIONARY
WALKING
RUNNING
TURNING
```

---

# 94. Day 10 Annotation Protocol (Gün 10 Annotation Protokolü)

Create operational annotation rules for each motion class. *(Her motion class için operational annotation rule'ları oluştur.)*

---

# 95. Day 10 Transition Handling (Gün 10 Transition Yönetimi)

Mark ambiguous transitions explicitly rather than forcing unreliable labels. *(Unreliable label zorlamak yerine ambiguous transition'ları explicitly işaretle.)*

---

# 96. Day 10 Initial Data Collection (Gün 10 Initial Veri Toplama)

Collect multiple independent controlled motion sessions. *(Birden fazla independent controlled motion session topla.)*

---

# 97. Day 10 Session-Wise Dataset Identity (Gün 10 Session-Wise Dataset Kimliği)

Ensure every window can be traced back to its parent session. *(Her window'un parent session'ına trace edilebildiğini sağla.)*

---

# 98. Day 10 Exit Criteria (Gün 10 Çıkış Kriterleri)

The dataset pipeline must prevent accidental window-level train/test leakage by design. *(Dataset pipeline accidental window-level train/test leakage'i design gereği önlemelidir.)*

---

# 99. Day 11 — Motion Classifier Baselines & 1D-CNN (Gün 11 — Motion Classifier Baseline'ları ve 1D-CNN)

Day 11 creates the first measurable Motion Classification candidates. *(Gün 11 ilk measurable Motion Classification candidate'larını oluşturur.)*

---

# 100. Day 11 Preprocessing Pipeline (Gün 11 Preprocessing Pipeline)

Implement the Python version of the frozen candidate sensor-window preprocessing. *(Frozen candidate sensor-window preprocessing'in Python version'ını uygula.)*

---

# 101. Day 11 Logistic Regression Baseline (Gün 11 Logistic Regression Baseline)

Train a simple Logistic Regression baseline if useful for reference. *(Reference için kullanışlıysa simple Logistic Regression baseline train et.)*

---

# 102. Day 11 Random Forest Baseline (Gün 11 Random Forest Baseline)

Train the primary classical Random Forest baseline. *(Primary classical Random Forest baseline'ı train et.)*

---

# 103. Day 11 1D-CNN Candidate (Gün 11 1D-CNN Adayı)

Train a lightweight candidate 1D-CNN. *(Lightweight candidate 1D-CNN train et.)*

---

# 104. Day 11 Split Discipline (Gün 11 Split Disiplini)

Create train, validation, and test partitions by physical session before generating overlapping windows. *(Overlapping window üretmeden önce train, validation ve test partition'larını fiziksel session'a göre oluştur.)*

---

# 105. Day 11 Metrics (Gün 11 Metrikleri)

Calculate Macro F1, per-class precision, recall, F1, accuracy, and confusion matrix. *(Macro F1, per-class precision, recall, F1, accuracy ve confusion matrix hesapla.)*

---

# 106. Day 11 Model Registry (Gün 11 Model Registry)

Create versioned model-registry records containing model ID, hash, dataset version, preprocessing version, and metrics. *(Model ID, hash, dataset version, preprocessing version ve metric'leri içeren versioned model-registry record'ları oluştur.)*

---

# 107. Day 11 Exit Criteria (Gün 11 Çıkış Kriterleri)

At least one reproducible baseline and one neural candidate must exist. *(En az bir reproducible baseline ve bir neural candidate mevcut olmalıdır.)*

---

# 108. Day 12 — On-Device AI Deployment (Gün 12 — Cihaz Üzerinde AI Deployment)

Day 12 moves the selected neural candidate from Python into Android LiteRT inference. *(Gün 12 selected neural candidate'ı Python'dan Android LiteRT inference'a taşır.)*

---

# 109. Day 12 Model Export (Gün 12 Model Export)

Export the selected candidate into the expected `.tflite` artifact. *(Selected candidate'ı expected `.tflite` artifact'a export et.)*

---

# 110. Day 12 Kotlin LiteRT Runtime (Gün 12 Kotlin LiteRT Runtime)

Implement model loading and inference in the native Android layer. *(Native Android layer içerisinde model loading ve inference uygula.)*

---

# 111. Day 12 Preprocessing Parity (Gün 12 Preprocessing Parity)

Implement exactly the same channel ordering, resampling, normalization, and tensor layout on-device. *(Aynı channel ordering, resampling, normalization ve tensor layout'u on-device exactly uygula.)*

---

# 112. Day 12 Golden Parity Tests (Gün 12 Golden Parity Testleri)

Compare Python tensors and Android tensors from frozen raw windows. *(Frozen raw window'lardan Python tensor'ları ve Android tensor'larını karşılaştır.)*

---

# 113. Day 12 Output Parity Tests (Gün 12 Output Parity Testleri)

Compare Python and LiteRT model output on identical golden inputs. *(Identical golden input'lar üzerinde Python ve LiteRT model output'unu karşılaştır.)*

---

# 114. Day 12 Shadow Mode (Gün 12 Shadow Mode)

Run Motion Classification in shadow mode without navigation influence. *(Motion Classification'ı navigation influence olmadan shadow mode'da çalıştır.)*

---

# 115. Day 12 Latency Profiling (Gün 12 Latency Profiling)

Measure model-load, warm-up, median inference, and P95 inference latency on the Redmi Note 9 Pro. *(Redmi Note 9 Pro üzerinde model-load, warm-up, median inference ve P95 inference latency ölç.)*

---

# 116. Day 12 Exit Criteria (Gün 12 Çıkış Kriterleri)

The mobile AI pipeline must pass preprocessing and output parity before navigation influence is enabled. *(Mobile AI pipeline navigation influence enabled olmadan önce preprocessing ve output parity'yi geçmelidir.)*

---

# 117. Day 13 — Step-Length ML Evaluation (Gün 13 — Step-Length ML Değerlendirmesi)

Day 13 evaluates whether learned step length deserves to enter the final system. *(Gün 13 learned step length'in final system'a girmeyi hak edip etmediğini değerlendirir.)*

---

# 118. Day 13 Reference Preparation (Gün 13 Referans Hazırlığı)

Use only defensible known-distance or segment-level reference labels. *(Yalnızca defensible known-distance veya segment-level reference label'ları kullan.)*

---

# 119. Day 13 Baseline Comparison (Gün 13 Baseline Karşılaştırması)

Compare fixed calibrated and deterministic variable step-length baselines first. *(Önce fixed calibrated ve deterministic variable step-length baseline'larını karşılaştır.)*

---

# 120. Day 13 Linear Regression (Gün 13 Linear Regression)

Train a simple Linear Regression candidate. *(Simple Linear Regression candidate train et.)*

---

# 121. Day 13 Random Forest Regressor (Gün 13 Random Forest Regressor)

Train a Random Forest Regressor candidate if the data volume supports it. *(Data volume destekliyorsa Random Forest Regressor candidate train et.)*

---

# 122. Day 13 Optional Small Neural Model (Gün 13 İsteğe Bağlı Küçük Neural Model)

A small neural step-length model may be tested only if classical models justify further complexity. *(Small neural step-length model yalnızca classical model'ler further complexity'yi justify ederse test edilebilir.)*

---

# 123. Day 13 Evaluation Metrics (Gün 13 Değerlendirme Metrikleri)

Evaluate distance bias, accumulated distance error, MAE or RMSE when defensible, and downstream PDR effect. *(Defensible olduğunda distance bias, accumulated distance error, MAE veya RMSE ve downstream PDR effect'i değerlendir.)*

---

# 124. Day 13 Retention Gate (Gün 13 Retention Gate'i)

If learned step length does not measurably outperform deterministic baselines, it will remain disabled. *(Learned step length deterministic baseline'ları measurably outperform etmiyorsa disabled kalacaktır.)*

---

# 125. Day 13 Schedule Fallback (Gün 13 Takvim Fallback'i)

If step-length labels prove too weak, Day 13 will be redirected toward deterministic step-length calibration and PDR robustness rather than forcing a weak ML model. *(Step-length label'ları çok weak çıkarsa Day 13 weak ML model zorlamak yerine deterministic step-length calibration ve PDR robustness'a yönlendirilecektir.)*

---

# 126. Day 14 — ARCore Relative Tracking Integration (Gün 14 — ARCore Göreli Tracking Entegrasyonu)

Day 14 introduces the visual-inertial enhancement. *(Gün 14 visual-inertial enhancement'ı ekler.)*

---

# 127. Day 14 ARCore Session Owner (Gün 14 ARCore Session Owner)

Implement one authoritative native ARCore session owner. *(Tek authoritative native ARCore session owner uygula.)*

---

# 128. Day 14 Pose Acquisition (Gün 14 Pose Acquisition)

Acquire timestamped camera or selected sensor pose while tracking is valid. *(Tracking valid iken timestamped camera veya selected sensor pose acquire et.)*

---

# 129. Day 14 Tracking-State Gate (Gün 14 Tracking-State Gate'i)

Only `TRACKING` poses may enter the navigation candidate stream. *(Yalnızca `TRACKING` pose'ları navigation candidate stream'e girebilir.)*

---

# 130. Day 14 Segment Model (Gün 14 Segment Model'i)

Implement local ARCore tracking segments with explicit segment IDs. *(Explicit segment ID'lere sahip local ARCore tracking segment'leri uygula.)*

---

# 131. Day 14 ARCore-to-ENU Alignment (Gün 14 ARCore-to-ENU Hizalama)

Implement an explicit rotation mapping from ARCore displacement coordinates into NAVGUARD ENU. *(ARCore displacement coordinate'larından NAVGUARD ENU'ya explicit rotation mapping uygula.)*

---

# 132. Day 14 No Hardcoded Axis Mapping (Gün 14 Hardcoded Axis Mapping Olmaması)

Do not use a hardcoded `ARCore X = East` assumption. *(Hardcoded `ARCore X = East` varsayımı kullanma.)*

---

# 133. Day 14 Tracking Loss Test (Gün 14 Tracking Loss Testi)

Deliberately induce ARCore degradation and confirm that PDR continues. *(ARCore degradation'ı deliberately oluştur ve PDR'ın devam ettiğini doğrula.)*

---

# 134. Day 14 Exit Criteria (Gün 14 Çıkış Kriterleri)

ARCore must provide segment-relative motion evidence without becoming a mandatory navigation dependency. *(ARCore mandatory navigation dependency olmadan segment-relative motion evidence sağlamalıdır.)*

---

# 135. Phase 3 Completion Gate (Faz 3 Tamamlama Gate'i)

At the end of Day 14, Motion AI should run on-device, learned step length should have a retention decision, and ARCore should provide validated relative tracking or remain explicitly diagnostic-only. *(Day 14 sonunda Motion AI on-device çalışmalı, learned step length retention decision'a sahip olmalı ve ARCore validated relative tracking sağlamalı veya explicitly diagnostic-only kalmalıdır.)*

---

# 136. Day 15 — Quality Engine & Uncertainty Inputs (Gün 15 — Quality Engine ve Uncertainty Input'ları)

Day 15 integrates sensor health and source trust into one common quality model. *(Gün 15 sensor health ve source trust'ı tek common quality model'e entegre eder.)*

---

# 137. Day 15 Quality States (Gün 15 Quality State'leri)

Implement the frozen quality-state enum. *(Frozen quality-state enum'u uygula.)*

```text
UNKNOWN
GOOD
USABLE
DEGRADED
UNRELIABLE
UNAVAILABLE
```

---

# 138. Day 15 Freshness Logic (Gün 15 Freshness Logic)

Implement source freshness and stale-data handling. *(Source freshness ve stale-data handling uygula.)*

---

# 139. Day 15 Plausibility Checks (Gün 15 Plausibility Check'leri)

Add hard validity and soft degradation rules for GNSS, heading, AI, ARCore, and step length. *(GNSS, heading, AI, ARCore ve step length için hard validity ve soft degradation rule'ları ekle.)*

---

# 140. Day 15 Quality Metadata (Gün 15 Quality Metadata)

Attach quality, confidence, and reason flags to estimator-relevant measurements. *(Estimator-relevant measurement'lara quality, confidence ve reason flag'leri ekle.)*

---

# 141. Day 15 Hysteresis Infrastructure (Gün 15 Hysteresis Altyapısı)

Create configurable quality recovery hysteresis. *(Configurable quality recovery hysteresis oluştur.)*

---

# 142. Day 15 Exit Criteria (Gün 15 Çıkış Kriterleri)

Invalid measurements must be rejected before they reach covariance scaling or fusion. *(Invalid measurement'lar covariance scaling veya fusion'a ulaşmadan önce rejected olmalıdır.)*

---

# 143. Day 16 — EKF Sensor Fusion Core (Gün 16 — EKF Sensör Füzyon Çekirdeği)

Day 16 implements the minimum EKF state `[E,N,ψ]`. *(Gün 16 minimum EKF state `[E,N,ψ]` uygular.)*

---

# 144. Day 16 State Initialization (Gün 16 State Initialization)

Implement initial state and covariance creation from the accepted anchor and heading state. *(Accepted anchor ve heading state'den initial state ve covariance creation uygula.)*

---

# 145. Day 16 Step Prediction (Gün 16 Step Prediction)

Implement nonlinear PDR step prediction. *(Nonlinear PDR step prediction uygula.)*

```text
E^- = E^+ + L sin(ψ)
N^- = N^+ + L cos(ψ)
ψ^- = ψ^+
```

---

# 146. Day 16 Jacobian (Gün 16 Jacobian)

Implement the frozen state Jacobian. *(Frozen state Jacobian'ı uygula.)*

```text
F =
[1 0  L cosψ]
[0 1 -L sinψ]
[0 0      1  ]
```

---

# 147. Day 16 Step-Length Noise Mapping (Gün 16 Step-Length Noise Mapping)

Implement the step-length noise mapping. *(Step-length noise mapping'i uygula.)*

```text
G_L =
[sinψ
 cosψ
 0]
```

---

# 148. Day 16 Heading Update (Gün 16 Heading Update)

Implement circular heading measurement innovation. *(Circular heading measurement innovation uygula.)*

---

# 149. Day 16 Joseph Update (Gün 16 Joseph Update)

Use the Joseph covariance update form. *(Joseph covariance update form'unu kullan.)*

---

# 150. Day 16 Numerical Tests (Gün 16 Numerical Testler)

Add covariance symmetry, finite-state, synthetic update, and circular-heading tests. *(Covariance symmetry, finite-state, synthetic update ve circular-heading testleri ekle.)*

---

# 151. Day 16 Exit Criteria (Gün 16 Çıkış Kriterleri)

Synthetic EKF sequences must remain numerically stable and deterministic. *(Synthetic EKF sequence'leri numerically stable ve deterministic kalmalıdır.)*

---

# 152. Day 17 — ARCore Fusion, Innovation Gating & Fallbacks (Gün 17 — ARCore Fusion, Innovation Gating ve Fallback'ler)

Day 17 connects optional sources to the EKF conservatively. *(Gün 17 optional source'ları EKF'ye conservative şekilde bağlar.)*

---

# 153. Day 17 ARCore Pseudo-Position (Gün 17 ARCore Pseudo-Position)

Implement segment-relative ENU pseudo-position measurement integration. *(Segment-relative ENU pseudo-position measurement integration uygula.)*

---

# 154. Day 17 Conservative ARCore Covariance (Gün 17 Conservative ARCore Covariance)

Begin with conservative ARCore measurement uncertainty. *(Conservative ARCore measurement uncertainty ile başla.)*

---

# 155. Day 17 NIS Gate (Gün 17 NIS Gate)

Implement candidate NIS-based innovation gating. *(Candidate NIS-based innovation gating uygula.)*

---

# 156. Day 17 Outlier Tests (Gün 17 Outlier Testleri)

Inject large synthetic measurement outliers and verify rejection behavior. *(Büyük synthetic measurement outlier'ları inject et ve rejection behavior'ı doğrula.)*

---

# 157. Day 17 Fallback Events (Gün 17 Fallback Event'leri)

Implement structured fallback event logging. *(Structured fallback event logging uygula.)*

---

# 158. Day 17 AI Navigation Influence (Gün 17 AI Navigation Influence)

Enable validated Motion AI effects such as stationary suppression or context-specific process profiles only after shadow-mode evidence. *(Stationary suppression veya context-specific process profile gibi validated Motion AI effect'lerini yalnızca shadow-mode evidence sonrasında enable et.)*

---

# 159. Day 17 Independent PDR Preservation (Gün 17 Independent PDR Koruması)

Ensure fused navigation never overwrites the independent baseline trajectory. *(Fused navigation'ın independent baseline trajectory'yi hiçbir zaman overwrite etmediğini sağla.)*

---

# 160. Day 17 Exit Criteria (Gün 17 Çıkış Kriterleri)

Configuration D must be able to lose ARCore or AI without destroying deterministic PDR continuity. *(Configuration D ARCore veya AI kaybederken deterministic PDR continuity'yi destroy etmeden çalışabilmelidir.)*

---

# 161. Day 18 — Navigation State Machine, Recovery & Full Integration (Gün 18 — Navigasyon State Machine, Recovery ve Tam Entegrasyon)

Day 18 completes the full navigation workflow. *(Gün 18 tam navigation workflow'u tamamlar.)*

---

# 162. Day 18 State Machine (Gün 18 State Machine)

Complete transitions between GNSS Mode, Evaluation Mode, denied navigation, recovery pending, relocalization, and restored state. *(GNSS Mode, Evaluation Mode, denied navigation, recovery pending, relocalization ve restored state arasındaki transition'ları tamamla.)*

---

# 163. Day 18 Recovery Candidate Validation (Gün 18 Recovery Candidate Validation)

Implement quality validation for returning GNSS fixes. *(Geri dönen GNSS fix'leri için quality validation uygula.)*

---

# 164. Day 18 Pre-Correction Snapshot (Gün 18 Pre-Correction Snapshot)

Persist estimator state before any recovery correction. *(Herhangi bir recovery correction öncesinde estimator state'i persist et.)*

---

# 165. Day 18 Recovery Error (Gün 18 Recovery Error)

Calculate East, North, and horizontal pre-correction recovery error in the original ENU frame. *(Original ENU frame içerisinde East, North ve horizontal pre-correction recovery error hesapla.)*

---

# 166. Day 18 Relocalization (Gün 18 Relocalization)

Implement controlled estimator correction or reinitialization after evidence capture. *(Evidence capture sonrasında controlled estimator correction veya reinitialization uygula.)*

---

# 167. Day 18 Historical Immutability (Gün 18 Historical Immutability)

Ensure prior denied trajectory points remain unchanged. *(Önceki denied trajectory point'lerinin unchanged kaldığını sağla.)*

---

# 168. Day 18 Full Workflow Test (Gün 18 Full Workflow Testi)

Run a complete physical sequence of anchor → walk → denial → PDR/fusion → recovery → finalization. *(Tam fiziksel anchor → walk → denial → PDR/fusion → recovery → finalization sequence'i çalıştır.)*

---

# 169. Phase 4 Completion Gate (Faz 4 Tamamlama Gate'i)

By the end of Day 18, the full NAVGUARD architecture must operate end-to-end on the target phone. *(Day 18 sonunda tam NAVGUARD architecture target phone üzerinde end-to-end çalışmalıdır.)*

---

# 170. Day 19 — Integration Testing & Failure Injection (Gün 19 — Entegrasyon Testleri ve Failure Injection)

Day 19 is dedicated to breaking the system deliberately before field benchmark preparation. *(Gün 19 field benchmark preparation öncesinde sistemi deliberately kırmaya ayrılmıştır.)*

---

# 171. Day 19 AI Failure Test (Gün 19 AI Failure Testi)

Simulate model-load and inference failures and verify deterministic fallback. *(Model-load ve inference failure'ları simulate et ve deterministic fallback'i doğrula.)*

---

# 172. Day 19 ARCore Failure Test (Gün 19 ARCore Failure Testi)

Force ARCore `PAUSED` or tracking loss and verify PDR continuity. *(ARCore `PAUSED` veya tracking loss oluştur ve PDR continuity'yi doğrula.)*

---

# 173. Day 19 Sensor Failure Tests (Gün 19 Sensör Hata Testleri)

Test stale, frozen, missing, duplicate, and out-of-order samples. *(Stale, frozen, missing, duplicate ve out-of-order sample'ları test et.)*

---

# 174. Day 19 Storage Failure Test (Gün 19 Storage Failure Testi)

Inject writer delay and test bounded backpressure behavior. *(Writer delay inject et ve bounded backpressure behavior'ı test et.)*

---

# 175. Day 19 Permission Failure Test (Gün 19 Permission Failure Testi)

Revoke relevant runtime permissions and verify subsystem degradation. *(Relevant runtime permission'ları revoke et ve subsystem degradation'ı doğrula.)*

---

# 176. Day 19 Ground Truth Firewall Attack Tests (Gün 19 Ground Truth Firewall Saldırı Testleri)

Attempt protected GNSS injection into EKF, AI, anchor, and denied-state pathways. *(Protected GNSS'i EKF, AI, anchor ve denied-state path'lerine inject etmeyi dene.)*

---

# 177. Day 19 Crash Recovery Test (Gün 19 Crash Recovery Testi)

Terminate the application during recording and verify `INCOMPLETE` session recovery. *(Recording sırasında uygulamayı terminate et ve `INCOMPLETE` session recovery'yi doğrula.)*

---

# 178. Day 19 Exit Criteria (Gün 19 Çıkış Kriterleri)

No unresolved critical integrity defect may remain. *(Unresolved critical integrity defect kalmamalıdır.)*

---

# 179. Day 20 — Pilot Field Experiments & Calibration (Gün 20 — Pilot Saha Deneyleri ve Kalibrasyon)

Day 20 validates the field protocol before final parameter freeze. *(Gün 20 final parameter freeze öncesinde field protocol'ü validate eder.)*

---

# 180. Day 20 Straight Pilot (Gün 20 Düz Pilot)

Perform at least one pilot straight-route session. *(En az bir pilot straight-route session gerçekleştir.)*

---

# 181. Day 20 Turn Pilot (Gün 20 Dönüş Pilot)

Perform at least one pilot turn-heavy session. *(En az bir pilot turn-heavy session gerçekleştir.)*

---

# 182. Day 20 Closed Pilot (Gün 20 Kapalı Pilot)

Perform at least one pilot closed or near-closed session. *(En az bir pilot closed veya near-closed session gerçekleştir.)*

---

# 183. Day 20 Route Practicality Review (Gün 20 Rota Practicality Review)

Verify start point, denial point, recovery point, route length practicality, and checkpoint visibility. *(Start point, denial point, recovery point, route length practicality ve checkpoint visibility'yi doğrula.)*

---

# 184. Day 20 GNSS Reference Review (Gün 20 GNSS Referans Review)

Inspect actual GNSS reference quality on the proposed routes. *(Proposed route'larda actual GNSS reference quality'yi incele.)*

---

# 185. Day 20 Phone Placement Decision (Gün 20 Telefon Placement Kararı)

Select the controlled phone placement for final benchmark sessions. *(Final benchmark session'ları için controlled phone placement seç.)*

---

# 186. Day 20 Parameter Calibration (Gün 20 Parametre Kalibrasyonu)

Use pilot evidence to calibrate step thresholds, heading filters, step-length constants, uncertainty profiles, and candidate gating parameters. *(Pilot evidence kullanarak step threshold, heading filter, step-length constant, uncertainty profile ve candidate gating parameter'larını calibrate et.)*

---

# 187. Day 20 No Final Benchmark Data Yet (Gün 20 Henüz Final Benchmark Verisi Yoktur)

Day 20 data remains development or pilot evidence and may be used for tuning. *(Day 20 verisi development veya pilot evidence olarak kalır ve tuning için kullanılabilir.)*

---

# 188. Day 20 Exit Criteria (Gün 20 Çıkış Kriterleri)

The final field protocol must be practical enough to repeat consistently. *(Final field protocol consistently repeat edilecek kadar practical olmalıdır.)*

---

# 189. Day 21 — Final Pre-Benchmark Freeze & Performance Qualification (Gün 21 — Final Benchmark Öncesi Freeze ve Performans Qualification)

Day 21 is the most important governance checkpoint before final evaluation. *(Gün 21 final evaluation öncesindeki en önemli governance checkpoint'tir.)*

---

# 190. Day 21 Build Freeze (Gün 21 Build Freeze)

Freeze the application build used for the final benchmark. *(Final benchmark'ta kullanılacak application build'i freeze et.)*

---

# 191. Day 21 Algorithm Freeze (Gün 21 Algorithm Freeze)

Freeze PDR, step detection, heading, AI, ARCore, EKF, recovery, and quality logic. *(PDR, step detection, heading, AI, ARCore, EKF, recovery ve quality logic'i freeze et.)*

---

# 192. Day 21 Model Freeze (Gün 21 Model Freeze)

Freeze the Motion Classification artifact and any retained learned step-length artifact. *(Motion Classification artifact'ı ve retained learned step-length artifact varsa onu freeze et.)*

---

# 193. Day 21 Metric Pipeline Freeze (Gün 21 Metric Pipeline Freeze)

Freeze the primary metric and reference-alignment pipeline. *(Primary metric ve reference-alignment pipeline'ı freeze et.)*

---

# 194. Day 21 Route Freeze (Gün 21 Rota Freeze)

Freeze the principal route definitions and repeat protocol. *(Principal route definition ve repeat protocol'ü freeze et.)*

---

# 195. Day 21 Inclusion Policy Freeze (Gün 21 Inclusion Policy Freeze)

Freeze session inclusion and exclusion criteria. *(Session inclusion ve exclusion criterion'larını freeze et.)*

---

# 196. Day 21 Ground Truth Firewall Gate (Gün 21 Ground Truth Firewall Gate)

Re-run the mandatory Ground Truth Firewall integrity suite. *(Mandatory Ground Truth Firewall integrity suite'i yeniden çalıştır.)*

---

# 197. Day 21 Performance Qualification (Gün 21 Performance Qualification)

Measure representative full-stack AI latency, memory behavior, logging throughput, storage growth, and short combined-stack thermal behavior. *(Representative full-stack AI latency, memory behavior, logging throughput, storage growth ve short combined-stack thermal behavior ölç.)*

---

# 198. Day 21 Endurance Candidate (Gün 21 Endurance Adayı)

Perform the dedicated endurance run if scheduling and earlier stability permit. *(Takvim ve earlier stability izin verirse dedicated endurance run gerçekleştir.)*

---

# 199. Day 21 Final Readiness Gate (Gün 21 Final Readiness Gate)

No known critical defect may remain open before Day 22 begins. *(Day 22 başlamadan önce known critical defect açık kalmamalıdır.)*

---

# 200. Day 21 Change-Control Rule (Gün 21 Change-Control Kuralı)

Any material change after this point must be documented and may invalidate previously collected final benchmark sessions. *(Bu noktadan sonraki herhangi bir material change documented edilmeli ve previously collected final benchmark session'ları invalid hale getirebilir.)*

---

# 201. Day 22 — Final Benchmark Collection I (Gün 22 — Final Benchmark Veri Toplama I)

Day 22 begins frozen final benchmark collection. *(Gün 22 frozen final benchmark collection'ı başlatır.)*

---

# 202. Day 22 Straight Sessions (Gün 22 Düz Session'lar)

Collect the planned final straight-route repeats. *(Planlanan final straight-route repeat'leri topla.)*

---

# 203. Day 22 Turn Sessions (Gün 22 Dönüş Session'lar)

Collect as many planned turn-heavy repeats as field time safely permits. *(Field time güvenli şekilde izin verdiği kadar planned turn-heavy repeat topla.)*

---

# 204. Day 22 Integrity Review (Gün 22 Integrity Review)

After each important session, verify evidence completeness, Ground Truth Firewall status, session finalization, and route execution. *(Her önemli session sonrasında evidence completeness, Ground Truth Firewall status, session finalization ve route execution'ı doğrula.)*

---

# 205. Day 22 No Algorithm Tuning (Gün 22 Algoritma Tuning Yoktur)

Observed benchmark performance will not be used to adjust the frozen estimator. *(Observed benchmark performance frozen estimator'ı adjust etmek için kullanılmayacaktır.)*

---

# 206. Day 22 Session Validity Only (Gün 22 Yalnızca Session Geçerliliği)

Review may determine whether a session is valid according to frozen rules, but it may not optimize NAVGUARD from the result. *(Review frozen rule'lara göre session'ın valid olup olmadığını belirleyebilir ancak result'tan NAVGUARD'ı optimize edemez.)*

---

# 207. Day 23 — Final Benchmark Collection II & Replay Evaluation (Gün 23 — Final Benchmark Veri Toplama II ve Replay Evaluation)

Day 23 completes the principal field evidence and begins final matched analysis. *(Gün 23 principal field evidence'ı tamamlar ve final matched analysis'i başlatır.)*

---

# 208. Day 23 Remaining Turn Sessions (Gün 23 Kalan Dönüş Session'ları)

Complete any remaining planned turn-heavy repeats. *(Kalan planned turn-heavy repeat'leri tamamla.)*

---

# 209. Day 23 Closed Sessions (Gün 23 Kapalı Session'lar)

Collect the planned closed or near-closed route repeats. *(Planlanan closed veya near-closed route repeat'leri topla.)*

---

# 210. Day 23 Principal Target (Gün 23 Temel Hedef)

The provisional field target is at least three valid repeats for each principal route category where practical. *(Geçici field target uygulanabilir olduğunda her principal route category için en az üç valid repeat'tir.)*

---

# 211. Day 23 Same-Session Replay (Gün 23 Same-Session Replay)

Replay each suitable frozen physical recording through Configurations A, B, C, and D. *(Her suitable frozen physical recording'i Configuration A, B, C ve D üzerinden replay et.)*

---

# 212. Day 23 Metric Computation (Gün 23 Metric Hesaplama)

Calculate session-level mean, median, RMSE, P95, final error, drift per time, drift per distance, and other available metrics. *(Session-level mean, median, RMSE, P95, final error, drift per time, drift per distance ve other available metric'leri hesapla.)*

---

# 213. Day 23 Primary A-D Comparison (Gün 23 Temel A-D Karşılaştırması)

Calculate matched Configuration A versus D improvement. *(Matched Configuration A versus D improvement hesapla.)*

---

# 214. Day 23 Ablation Comparison (Gün 23 Ablation Karşılaştırması)

Evaluate A → B, A → C, and A → D differences. *(A → B, A → C ve A → D difference'larını değerlendir.)*

---

# 215. Day 23 Benchmark Integrity Report (Gün 23 Benchmark Integrity Report)

Generate a table of included, excluded, limited, and pending sessions with reasons. *(Reason'larıyla included, excluded, limited ve pending session tablosu oluştur.)*

---

# 216. Day 23 Bug Policy (Gün 23 Bug Politikası)

Only bugs that invalidate analysis or evidence may justify a build change after freeze. *(Freeze sonrasında yalnızca analysis veya evidence'ı invalidate eden bug'lar build change'i justify edebilir.)*

---

# 217. Day 23 Re-Test Rule (Gün 23 Yeniden Test Kuralı)

If a material fix changes estimator behavior, affected benchmark sessions must be recollected or clearly separated by build version. *(Material fix estimator behavior'ı değiştirirse affected benchmark session'lar recollected edilmeli veya build version'a göre açık şekilde separated edilmelidir.)*

---

# 218. Day 24 — Final Analysis, Acceptance & Demo Preparation (Gün 24 — Final Analiz, Acceptance ve Demo Hazırlığı)

Day 24 converts the complete evidence into final project conclusions and demonstration artifacts. *(Gün 24 complete evidence'ı final project conclusion ve demonstration artifact'larına dönüştürür.)*

---

# 219. Day 24 Final Metric Tables (Gün 24 Final Metric Tabloları)

Produce the final A-D benchmark tables. *(Final A-D benchmark tablolarını üret.)*

---

# 220. Day 24 Primary Success Evaluation (Gün 24 Temel Başarı Değerlendirmesi)

Determine whether Configuration D achieved the frozen primary target relative to Configuration A. *(Configuration D'nin Configuration A'ya göre frozen primary target'ı achieve edip etmediğini belirle.)*

---

# 221. Day 24 AI Evaluation (Gün 24 AI Değerlendirmesi)

Report held-out Motion Classification Macro F1, confusion matrix, per-class metrics, and mobile latency. *(Held-out Motion Classification Macro F1, confusion matrix, per-class metric'ler ve mobile latency raporla.)*

---

# 222. Day 24 PDR Evaluation (Gün 24 PDR Değerlendirmesi)

Report step-count error and step-length baseline results. *(Step-count error ve step-length baseline result'larını raporla.)*

---

# 223. Day 24 ARCore Evaluation (Gün 24 ARCore Değerlendirmesi)

Report tracking availability, tracking-loss behavior, and navigation contribution where valid. *(Valid olduğunda tracking availability, tracking-loss behavior ve navigation contribution raporla.)*

---

# 224. Day 24 Recovery Evaluation (Gün 24 Recovery Değerlendirmesi)

Report pre-correction recovery error and recovery latency. *(Pre-correction recovery error ve recovery latency raporla.)*

---

# 225. Day 24 Performance Evaluation (Gün 24 Performans Değerlendirmesi)

Summarize AI latency, storage growth, memory behavior, battery observations, thermal behavior, and full-stack stability. *(AI latency, storage growth, memory behavior, battery observation, thermal behavior ve full-stack stability'yi özetle.)*

---

# 226. Day 24 Limitations (Gün 24 Limitations)

Document unresolved limitations explicitly rather than hiding them from the final presentation. *(Unresolved limitation'ları final presentation'dan gizlemek yerine explicitly document et.)*

---

# 227. Day 24 Demo Route Selection (Gün 24 Demo Rota Seçimi)

Select a safe representative demonstration route without presenting it as the only benchmark evidence. *(Onu tek benchmark evidence gibi göstermeden safe representative demonstration route seç.)*

---

# 228. Day 24 Demo Workflow (Gün 24 Demo Workflow)

Prepare a reproducible demonstration of anchor acquisition → GNSS denial → NAVGUARD estimate → uncertainty → recovery. *(Anchor acquisition → GNSS denial → NAVGUARD estimate → uncertainty → recovery reproducible demonstration hazırla.)*

---

# 229. Day 24 Final Evidence Backup (Gün 24 Final Evidence Backup)

Verify integrity of final model artifacts, benchmark sessions, manifests, metric outputs, charts, and documentation. *(Final model artifact'ları, benchmark session'lar, manifest'ler, metric output'lar, chart'lar ve documentation integrity'sini doğrula.)*

---

# 230. Day 24 Exit Criteria (Gün 24 Çıkış Kriterleri)

The project must end with reproducible evidence even if the primary accuracy target is not achieved. *(Primary accuracy target achieve edilmese bile proje reproducible evidence ile sona ermelidir.)*

---

# 231. 24-Day Summary Table (24 Günlük Özet Tablo)

| Day (Gün) | Primary Goal (Temel Hedef)                               | Required Output (Gerekli Çıktı)                                       |
| --------- | -------------------------------------------------------- | --------------------------------------------------------------------- |
| 1         | Project + Device Audit *(Proje + Cihaz Audit)*           | Capability report *(Capability raporu)*                               |
| 2         | Sensors *(Sensörler)*                                    | Raw acquisition + timing logs *(Raw acquisition + timing logları)*    |
| 3         | Timing / Sync *(Timing / Sync)*                          | Common event timeline *(Ortak event timeline)*                        |
| 4         | GNSS + Firewall *(GNSS + Firewall)*                      | Protected Evaluation Mode boundary *(Korunan Evaluation Mode sınırı)* |
| 5         | Coordinates + PDR Math *(Koordinatlar + PDR Matematiği)* | Deterministic math core *(Deterministik matematik çekirdeği)*         |
| 6         | Step Detection *(Adım Tespiti)*                          | Timestamped StepEvents *(Timestamped StepEvent'ler)*                  |
| 7         | Heading *(Heading)*                                      | True-north heading pipeline *(True-north heading pipeline)*           |
| 8         | Step Length + PDR *(Step Length + PDR)*                  | Configuration A live *(Configuration A live)*                         |
| 9         | Storage + Replay *(Storage + Replay)*                    | Replayable PDR evidence *(Replayable PDR evidence)*                   |
| 10        | AI Dataset *(AI Dataset)*                                | Session-wise labeled data *(Session-wise labeled data)*               |
| 11        | AI Training *(AI Training)*                              | RF + 1D-CNN candidates *(RF + 1D-CNN adayları)*                       |
| 12        | Edge AI *(Edge AI)*                                      | LiteRT shadow-mode model *(LiteRT shadow-mode model)*                 |
| 13        | Step-Length ML *(Step-Length ML)*                        | Retain/reject decision *(Koruma/reddetme kararı)*                     |
| 14        | ARCore *(ARCore)*                                        | Relative tracking + PDR fallback *(Relative tracking + PDR fallback)* |
| 15        | Quality Engine *(Quality Engine)*                        | Source quality states *(Kaynak quality state'leri)*                   |
| 16        | EKF Core *(EKF Çekirdeği)*                               | `[E,N,ψ]` fusion *( `[E,N,ψ]` fusion)*                                |
| 17        | Fusion + Fallback *(Fusion + Fallback)*                  | ARCore/AI integration *(ARCore/AI integration)*                       |
| 18        | Recovery *(Recovery)*                                    | End-to-end navigation workflow *(Uçtan uca navigasyon workflow)*      |
| 19        | Failure Injection *(Failure Injection)*                  | Critical fallback validation *(Critical fallback validation)*         |
| 20        | Pilot Field *(Pilot Saha)*                               | Calibration + route validation *(Calibration + rota validation)*      |
| 21        | Freeze + Performance *(Freeze + Performans)*             | Frozen benchmark build *(Frozen benchmark build)*                     |
| 22        | Final Benchmark I *(Final Benchmark I)*                  | Straight + turn evidence *(Düz + dönüş evidence)*                     |
| 23        | Final Benchmark II *(Final Benchmark II)*                | Closed routes + A-D replay *(Kapalı rotalar + A-D replay)*            |
| 24        | Final Analysis *(Final Analiz)*                          | Results + demo + acceptance *(Sonuçlar + demo + acceptance)*          |

---

# 232. Critical Daily Dependencies (Kritik Günlük Dependency'ler)

Some days cannot begin meaningfully until specific earlier work passes. *(Bazı günler belirli earlier work geçmeden meaningful şekilde başlayamaz.)*

---

# 233. AI Dependency (AI Dependency)

On-device AI deployment depends on a validated sensor acquisition and timing pipeline. *(On-device AI deployment validated sensor acquisition ve timing pipeline'a bağlıdır.)*

---

# 234. ARCore Fusion Dependency (ARCore Fusion Dependency)

ARCore fusion depends on explicit coordinate alignment and timestamp validation. *(ARCore fusion explicit coordinate alignment ve timestamp validation'a bağlıdır.)*

---

# 235. EKF Dependency (EKF Dependency)

EKF integration depends on deterministic PDR, heading, uncertainty inputs, and timestamp ordering. *(EKF integration deterministic PDR, heading, uncertainty input'ları ve timestamp ordering'e bağlıdır.)*

---

# 236. Final Benchmark Dependency (Final Benchmark Dependency)

Final benchmark collection depends on successful pilot testing, freeze, integrity tests, and logging stability. *(Final benchmark collection successful pilot testing, freeze, integrity test'leri ve logging stability'ye bağlıdır.)*

---

# 237. Parallelizable Work (Paralel Yapılabilecek İşler)

Some tasks may overlap when implementation time allows. *(Implementation time izin verdiğinde bazı task'ler overlap olabilir.)*

---

# 238. Documentation and Code Parallelism (Dokümantasyon ve Kod Paralelliği)

Implementation notes and test evidence can be updated while longer model-training or field-data analysis tasks run locally. *(Implementation note'ları ve test evidence daha uzun model-training veya field-data analysis task'leri local olarak çalışırken update edilebilir.)*

---

# 239. Python and Android Parallelism (Python ve Android Paralelliği)

Offline metric and model code may be developed alongside Kotlin runtime adapters when dependencies are clear. *(Dependency'ler clear olduğunda offline metric ve model code Kotlin runtime adapter'larıyla birlikte geliştirilebilir.)*

---

# 240. Non-Parallelizable Critical Sections (Paralel Olmaması Gereken Kritik Bölümler)

Ground Truth Firewall validation, parameter freeze, and final benchmark interpretation must occur in strict sequence. *(Ground Truth Firewall validation, parameter freeze ve final benchmark interpretation strict sequence içerisinde gerçekleşmelidir.)*

---

# 241. Schedule Compression Strategy (Takvim Sıkıştırma Stratejisi)

If development falls behind schedule, NAVGUARD will use a predetermined reduction order. *(Development schedule'ın gerisine düşerse NAVGUARD predetermined reduction order kullanacaktır.)*

---

# 242. First Feature to Remove Under Pressure (Baskı Altında İlk Kaldırılacak Özellik)

Optional quantization and hardware-delegate experiments are among the first features that may be removed. *(Optional quantization ve hardware-delegate experiment'leri kaldırılabilecek ilk feature'lar arasındadır.)*

---

# 243. Second Reduction Layer (İkinci Azaltma Katmanı)

Broad phone-placement robustness and cross-device testing may be removed. *(Broad phone-placement robustness ve cross-device testing kaldırılabilir.)*

---

# 244. Third Reduction Layer (Üçüncü Azaltma Katmanı)

Advanced uncertainty calibration such as full NEES analysis may be reduced to basic covariance validation. *(Full NEES analysis gibi advanced uncertainty calibration basic covariance validation'a reduce edilebilir.)*

---

# 245. Fourth Reduction Layer (Dördüncü Azaltma Katmanı)

Learned step-length deployment may be removed if deterministic step length remains valid. *(Deterministic step length valid kalıyorsa learned step-length deployment kaldırılabilir.)*

---

# 246. Fifth Reduction Layer (Beşinci Azaltma Katmanı)

Secondary stress tests may be reduced after the principal straight, turn-heavy, and closed benchmark remains protected. *(Principal straight, turn-heavy ve closed benchmark korunurken secondary stress test'ler azaltılabilir.)*

---

# 247. Motion Classification Cannot Be Removed (Motion Classification Kaldırılamaz)

Motion Classification remains the mandatory AI component for the intended research design. *(Motion Classification intended research design için mandatory AI component olarak kalır.)*

---

# 248. PDR Cannot Be Removed (PDR Kaldırılamaz)

Deterministic PDR is the mandatory navigation backbone. *(Deterministic PDR mandatory navigation backbone'dur.)*

---

# 249. Ground Truth Firewall Cannot Be Removed (Ground Truth Firewall Kaldırılamaz)

Ground Truth Firewall is mandatory for scientific validity. *(Ground Truth Firewall scientific validity için mandatory'dir.)*

---

# 250. Replay Cannot Be Removed (Replay Kaldırılamaz)

Replay is mandatory for reproducible A-D comparison. *(Replay reproducible A-D comparison için mandatory'dir.)*

---

# 251. Final Benchmark Cannot Be Replaced by Demo (Final Benchmark Demo ile Değiştirilemez)

A successful live demonstration cannot replace quantitative benchmark evidence. *(Successful live demonstration quantitative benchmark evidence'ın yerini alamaz.)*

---

# 252. Minimum Completion Path (Minimum Tamamlama Yolu)

If serious schedule pressure occurs, the project minimum path is defined below. *(Serious schedule pressure oluşursa project minimum path aşağıda tanımlanmıştır.)*

```text
Sensors
→ Timing
→ GNSS Anchor
→ Ground Truth Firewall
→ Step Detection
→ Heading
→ Fixed / Deterministic Step Length
→ PDR
→ Motion Classification
→ Logging
→ Replay
→ Metrics
→ Pilot
→ Frozen Benchmark
→ Final Results
```

---

# 253. Target Completion Path (Hedef Tamamlama Yolu)

The preferred full target adds ARCore, EKF, quality-aware uncertainty, advanced recovery, learned step length if justified, and extensive stress testing. *(Preferred full target ARCore, EKF, quality-aware uncertainty, advanced recovery, justified ise learned step length ve extensive stress testing ekler.)*

---

# 254. Daily Source-Control Discipline (Günlük Source-Control Disiplini)

Each significant development milestone should be associated with a version-controlled commit or equivalent traceable snapshot. *(Her significant development milestone version-controlled commit veya equivalent traceable snapshot ile associated olmalıdır.)*

---

# 255. Build Identity (Build Kimliği)

Formal test and field evidence must record the build or commit identity that produced it. *(Formal test ve field evidence onu üreten build veya commit identity'yi kaydetmelidir.)*

---

# 256. Model Identity (Model Kimliği)

AI-related evidence must record model identity and hash. *(AI-related evidence model identity ve hash'i kaydetmelidir.)*

---

# 257. Configuration Identity (Yapılandırma Kimliği)

Every replay and field result must identify the configuration used. *(Her replay ve field result kullanılan configuration'ı identify etmelidir.)*

---

# 258. Parameter Snapshot (Parametre Snapshot'ı)

Important runtime thresholds should be exported with the session or benchmark configuration. *(Önemli runtime threshold'lar session veya benchmark configuration ile export edilmelidir.)*

---

# 259. Development Data vs Benchmark Data (Development Data ile Benchmark Data)

Development, calibration, pilot, and final benchmark sessions must remain distinguishable. *(Development, calibration, pilot ve final benchmark session'ları birbirinden distinguishable kalmalıdır.)*

---

# 260. Candidate Session Purpose Enum (Aday Session Purpose Enum'u)

```text
DEVELOPMENT
CALIBRATION
PILOT
FINAL_BENCHMARK
STRESS
DEMO
```

---

# 261. Final Benchmark Data Lock (Final Benchmark Veri Kilidi)

Once a session is classified as final benchmark evidence, it must not later be silently reclassified as training or tuning data. *(Session final benchmark evidence olarak classified edildikten sonra daha sonra sessizce training veya tuning data olarak reclassified edilmemelidir.)*

---

# 262. Day-Level Risk Buffer (Gün Seviyesi Risk Buffer)

The roadmap intentionally places pilot and integration work before the final three days so that critical failures are discovered before the benchmark window. *(Yol haritası critical failure'ların benchmark window öncesinde discovered olması için pilot ve integration work'ü final üç günden önce intentionally yerleştirir.)*

---

# 263. No Feature Development During Final Benchmark by Default (Varsayılan Olarak Final Benchmark Sırasında Feature Development Yoktur)

Days 22–24 are not intended for adding new major navigation functionality. *(Days 22–24 yeni major navigation functionality eklemek için tasarlanmamıştır.)*

---

# 264. Emergency Fix Exception (Acil Fix İstisnası)

A critical defect may require a fix, but the resulting build must be treated as a new benchmark build. *(Critical defect fix gerektirebilir ancak resulting build new benchmark build olarak ele alınmalıdır.)*

---

# 265. Final Benchmark Restart Rule (Final Benchmark Yeniden Başlatma Kuralı)

Sessions collected with materially different estimator builds should not be pooled as if they came from one frozen system. *(Materially different estimator build'lerle collected session'lar tek frozen system'den gelmiş gibi pooled edilmemelidir.)*

---

# 266. Daily Testing Minimum (Günlük Minimum Test)

Every implementation day should include at least relevant unit or integration tests for the code changed that day. *(Her implementation day o gün changed code için en az relevant unit veya integration test içermelidir.)*

---

# 267. End-of-Phase Regression (Faz Sonu Regression)

Each phase boundary should trigger a regression run covering all previous critical functionality. *(Her phase boundary önceki tüm critical functionality'yi kapsayan regression run tetiklemelidir.)*

---

# 268. Phase 1 Regression (Faz 1 Regression)

Verify sensors, timing, GNSS, anchor, and firewall. *(Sensors, timing, GNSS, anchor ve firewall'ı doğrula.)*

---

# 269. Phase 2 Regression (Faz 2 Regression)

Verify coordinate math, step detection, heading, PDR, storage, replay, and metrics. *(Coordinate math, step detection, heading, PDR, storage, replay ve metric'leri doğrula.)*

---

# 270. Phase 3 Regression (Faz 3 Regression)

Add AI parity and ARCore fallback tests. *(AI parity ve ARCore fallback testlerini ekle.)*

---

# 271. Phase 4 Regression (Faz 4 Regression)

Add EKF, recovery, quality, and Ground Truth Firewall revalidation. *(EKF, recovery, quality ve Ground Truth Firewall revalidation ekle.)*

---

# 272. Phase 5 Regression (Faz 5 Regression)

Run the complete benchmark-readiness suite. *(Complete benchmark-readiness suite'i çalıştır.)*

---

# 273. Final Regression (Final Regression)

Re-run critical deterministic tests before final report generation. *(Final report generation öncesinde critical deterministic testleri yeniden çalıştır.)*

---

# 274. Research Milestone M1 (Araştırma Milestone M1)

**M1 — Sensor & GNSS Foundation Complete by Day 4.** *(M1 — Sensör ve GNSS Foundation Day 4'e Kadar Tamamlanmış Olmalıdır.)*

---

# 275. Research Milestone M2 (Araştırma Milestone M2)

**M2 — Replayable PDR Baseline Complete by Day 9.** *(M2 — Replayable PDR Baseline Day 9'a Kadar Tamamlanmış Olmalıdır.)*

---

# 276. Research Milestone M3 (Araştırma Milestone M3)

**M3 — AI and ARCore Candidates Operational by Day 14.** *(M3 — AI ve ARCore Candidate'ları Day 14'e Kadar Operational Olmalıdır.)*

---

# 277. Research Milestone M4 (Araştırma Milestone M4)

**M4 — Full NAVGUARD End-to-End Workflow Complete by Day 18.** *(M4 — Full NAVGUARD End-to-End Workflow Day 18'e Kadar Tamamlanmış Olmalıdır.)*

---

# 278. Research Milestone M5 (Araştırma Milestone M5)

**M5 — Pilot Validation and Benchmark Freeze Complete by Day 21.** *(M5 — Pilot Validation ve Benchmark Freeze Day 21'e Kadar Tamamlanmış Olmalıdır.)*

---

# 279. Research Milestone M6 (Araştırma Milestone M6)

**M6 — Final Benchmark, Analysis, and Demo Evidence Complete by Day 24.** *(M6 — Final Benchmark, Analysis ve Demo Evidence Day 24'e Kadar Tamamlanmış Olmalıdır.)*

---

# 280. Definition of Day 24 Success (Day 24 Başarı Tanımı)

Day 24 success does not require NAVGUARD to meet every aspirational performance target. *(Day 24 success NAVGUARD'ın her aspirational performance target'ı karşılamasını gerektirmez.)*

It requires a working, tested, reproducible research prototype with honest measured conclusions. *(Çalışan, test edilmiş, reproducible research prototype ve dürüst measured conclusion gerektirir.)*

---

# 281. Primary Scientific Success Condition (Temel Bilimsel Başarı Koşulu)

The primary target remains a frozen matched-session comparison showing at least a 20% median position-error reduction for full NAVGUARD relative to PDR-only baseline. *(Primary target full NAVGUARD'ın PDR-only baseline'a göre en az %20 median position-error reduction gösterdiği frozen matched-session comparison olarak kalır.)*

---

# 282. Failure to Reach 20% Is Still Reportable (20%'ye Ulaşamamak Yine de Raporlanabilir)

If the target is not met, the project will report partial improvement, no measurable improvement, regression, or inconclusive evidence according to Page 35. *(Target karşılanmazsa proje Page 35'e göre partial improvement, no measurable improvement, regression veya inconclusive evidence raporlayacaktır.)*

---

# 283. Motion AI Success Condition (Motion AI Başarı Koşulu)

The provisional Motion Classification target remains held-out session-wise Macro F1 ≥ 0.90. *(Geçici Motion Classification target held-out session-wise Macro F1 ≥ 0.90 olarak kalır.)*

---

# 284. Step Detection Success Condition (Adım Tespit Başarı Koşulu)

The provisional controlled absolute step-count error target remains ≤5%. *(Geçici controlled absolute step-count error target ≤%5 olarak kalır.)*

---

# 285. Edge AI Success Condition (Edge AI Başarı Koşulu)

The provisional inference target remains approximately below 50 ms per inference on the target device, with the final statistic frozen after profiling. *(Geçici inference target target device üzerinde inference başına yaklaşık 50 ms'nin altında kalır ve final statistic profiling sonrasında freeze edilir.)*

---

# 286. Critical Integrity Success Condition (Kritik Bütünlük Başarı Koşulu)

`unauthorizedGnssEstimatorUpdateCount` must remain zero in every valid final denied interval. *(`unauthorizedGnssEstimatorUpdateCount` her valid final denied interval içerisinde zero kalmalıdır.)*

---

# 287. Roadmap Non-Goals (Yol Haritası Olmayan Hedefler)

The roadmap does not attempt to develop every possible navigation enhancement within 24 days. *(Yol haritası 24 gün içerisinde mümkün olan her navigation enhancement'ı geliştirmeye çalışmaz.)*

---

# 288. Additional Roadmap Non-Goals (Ek Yol Haritası Olmayan Hedefler)

The roadmap does not include RF jamming or spoofing experiments. *(Yol haritası RF jamming veya spoofing experiment'leri içermez.)*

The roadmap does not require additional navigation hardware. *(Yol haritası additional navigation hardware gerektirmez.)*

The roadmap does not promise military-grade navigation performance. *(Yol haritası military-grade navigation performance vaat etmez.)*

---

# 289. Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kararlar)

The project implementation duration is 24 business days. *(Proje implementation süresi 24 iş günüdür.)*

---

# 290. Phase Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Faz Kararları)

The roadmap will use six phases: foundation, deterministic navigation, AI/ARCore enhancement, fusion/recovery, pilot/freeze, and final benchmark/delivery. *(Yol haritası altı faz kullanacaktır: foundation, deterministic navigation, AI/ARCore enhancement, fusion/recovery, pilot/freeze ve final benchmark/delivery.)*

---

# 291. Baseline Timing Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Baseline Zamanlama Kararları)

A replayable Configuration A baseline is targeted for completion by Day 9. *(Replayable Configuration A baseline Day 9'a kadar tamamlanması hedeflenmektedir.)*

---

# 292. AI Timing Decisions Frozen by This Document (Bu Dokümanla Sabitlenen AI Zamanlama Kararları)

Motion AI dataset, training, and on-device deployment are scheduled for Days 10–12. *(Motion AI dataset, training ve on-device deployment Days 10–12 için planlanmıştır.)*

---

# 293. Step-Length Timing Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Step-Length Zamanlama Kararları)

Learned step-length evaluation is scheduled as a bounded Day 13 experiment rather than an open-ended research task. *(Learned step-length evaluation open-ended research task yerine bounded Day 13 experiment olarak planlanmıştır.)*

---

# 294. ARCore Timing Decisions Frozen by This Document (Bu Dokümanla Sabitlenen ARCore Zamanlama Kararları)

ARCore relative tracking integration is targeted for Day 14. *(ARCore relative tracking integration Day 14 için hedeflenmiştir.)*

---

# 295. EKF Timing Decisions Frozen by This Document (Bu Dokümanla Sabitlenen EKF Zamanlama Kararları)

EKF core and advanced fusion integration are scheduled for Days 16–17 after deterministic navigation and quality infrastructure exist. *(EKF core ve advanced fusion integration deterministic navigation ve quality infrastructure mevcut olduktan sonra Days 16–17 için planlanmıştır.)*

---

# 296. Recovery Timing Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Recovery Zamanlama Kararları)

Complete GNSS recovery and relocalization integration is targeted for Day 18. *(Complete GNSS recovery ve relocalization integration Day 18 için hedeflenmiştir.)*

---

# 297. Failure Testing Timing Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Failure Testing Zamanlama Kararları)

Dedicated failure-injection testing occurs before pilot freeze rather than after final benchmark collection. *(Dedicated failure-injection testing final benchmark collection sonrasında değil pilot freeze öncesinde gerçekleşir.)*

---

# 298. Pilot Timing Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Pilot Zamanlama Kararları)

Pilot field experiments and calibration occur on Day 20 before final freeze. *(Pilot field experiment'ler ve calibration final freeze öncesinde Day 20'de gerçekleşir.)*

---

# 299. Freeze Timing Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Freeze Zamanlama Kararları)

The formal benchmark configuration is frozen by the end of Day 21. *(Formal benchmark configuration Day 21 sonunda freeze edilir.)*

---

# 300. Benchmark Timing Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Benchmark Zamanlama Kararları)

Final benchmark collection begins only after the freeze and occupies Days 22–23. *(Final benchmark collection yalnızca freeze sonrasında başlar ve Days 22–23'ü kapsar.)*

---

# 301. Final Analysis Timing Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Final Analiz Zamanlama Kararları)

Final analysis, acceptance review, demo preparation, and evidence verification are completed on Day 24. *(Final analysis, acceptance review, demo preparation ve evidence verification Day 24'te tamamlanır.)*

---

# 302. Scope Reduction Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kapsam Azaltma Kararları)

Quantization, delegates, cross-device generalization, broad placement robustness, advanced uncertainty analysis, learned step length, and secondary stress tests may be reduced before core PDR, Motion AI, Ground Truth Firewall, replay, or benchmark work is removed. *(Quantization, delegate'ler, cross-device generalization, broad placement robustness, advanced uncertainty analysis, learned step length ve secondary stress test'ler core PDR, Motion AI, Ground Truth Firewall, replay veya benchmark work kaldırılmadan önce reduce edilebilir.)*

---

# 303. Final Benchmark Integrity Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Final Benchmark Bütünlük Kararları)

No final benchmark tuning is allowed after the Day 21 freeze. *(Day 21 freeze sonrasında final benchmark tuning'e izin verilmez.)*

---

# 304. Build Change Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Build Change Kararları)

Material estimator changes after benchmark freeze require explicit change logging and may require benchmark recollection. *(Benchmark freeze sonrasındaki material estimator change'ler explicit change logging gerektirir ve benchmark recollection gerektirebilir.)*

---

# 305. Data Classification Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Data Classification Kararları)

Development, calibration, pilot, final benchmark, stress, and demo sessions must remain explicitly distinguishable. *(Development, calibration, pilot, final benchmark, stress ve demo session'ları explicitly distinguishable kalmalıdır.)*

---

# 306. Final Roadmap Statement (Nihai Yol Haritası Bildirimi)

**NAVGUARD will use a dependency-driven 24-business-day implementation strategy that establishes device evidence, authoritative sensor acquisition, common timing, GNSS isolation, deterministic PDR, logging, replay, and evaluation before introducing AI, ARCore, and EKF complexity.** *(NAVGUARD AI, ARCore ve EKF complexity eklenmeden önce device evidence, authoritative sensor acquisition, common timing, GNSS isolation, deterministic PDR, logging, replay ve evaluation oluşturan dependency-driven 24 iş günlük implementation strategy kullanacaktır.)*

**The first nine days are designed to create a complete replayable PDR-only research baseline so the project already possesses a scientifically useful navigation and evidence pipeline before optional full-system capabilities are added.** *(İlk dokuz gün complete replayable PDR-only research baseline oluşturmak için tasarlanmıştır; böylece optional full-system capability'ler eklenmeden önce proje bilimsel olarak useful navigation ve evidence pipeline'a sahip olacaktır.)*

**Days 10 through 14 add the mandatory Motion Classification system, perform bounded learned step-length research, deploy edge AI, and integrate ARCore as an optional relative-motion enhancement without allowing any of those components to become a single point of failure.** *(Days 10–14 mandatory Motion Classification system'i ekler, bounded learned step-length research gerçekleştirir, edge AI deploy eder ve bu component'lerin hiçbirinin single point of failure olmasına izin vermeden ARCore'u optional relative-motion enhancement olarak integrate eder.)*

**Days 15 through 18 combine source quality, the minimum `[E,N,ψ]` EKF, conservative ARCore fusion, fallback behavior, the navigation state machine, protected GNSS recovery, pre-correction error capture, and controlled relocalization into the complete NAVGUARD runtime workflow.** *(Days 15–18 source quality, minimum `[E,N,ψ]` EKF, conservative ARCore fusion, fallback behavior, navigation state machine, protected GNSS recovery, pre-correction error capture ve controlled relocalization'ı complete NAVGUARD runtime workflow içerisinde birleştirir.)*

**Days 19 through 21 deliberately attempt to break the system, validate the actual field protocol, calibrate only with development and pilot evidence, qualify target-device performance, and then freeze the build, models, routes, thresholds, inclusion rules, and metric pipeline before the final benchmark begins.** *(Days 19–21 sistemi deliberately kırmayı dener, actual field protocol'ü validate eder, yalnızca development ve pilot evidence ile calibrate eder, target-device performance'ı qualify eder ve final benchmark başlamadan önce build, model, rota, threshold, inclusion rule ve metric pipeline'ı freeze eder.)*

**Days 22 and 23 collect the frozen final physical evidence and replay matched recordings through Configurations A, B, C, and D, while Day 24 converts those results into final metrics, acceptance decisions, limitations, demonstration material, and reproducible research evidence.** *(Days 22 ve 23 frozen final physical evidence'ı toplar ve matched recording'leri Configuration A, B, C ve D üzerinden replay eder; Day 24 ise bu result'ları final metric, acceptance decision, limitation, demonstration material ve reproducible research evidence'a dönüştürür.)*

**If schedule pressure occurs, NAVGUARD will reduce optional complexity in a predefined order rather than sacrificing deterministic PDR, Motion Classification, Ground Truth Firewall isolation, evidence logging, replay reproducibility, metric correctness, or final field evaluation.** *(Schedule pressure oluşursa NAVGUARD deterministic PDR, Motion Classification, Ground Truth Firewall isolation, evidence logging, replay reproducibility, metric correctness veya final field evaluation'ı sacrifice etmek yerine optional complexity'yi predefined order içerisinde azaltacaktır.)*

**The project will therefore finish Day 24 not merely with an application that can be demonstrated, but with a versioned and testable navigation prototype whose algorithms, datasets, models, field sessions, benchmark configurations, failures, and final conclusions can be traced back to reproducible technical evidence.** *(Bu nedenle proje Day 24'ü yalnızca demonstration yapılabilen application ile değil; algorithm'ları, dataset'leri, model'leri, field session'ları, benchmark configuration'ları, failure'ları ve final conclusion'ları reproducible technical evidence'a trace edilebilen versioned ve testable navigation prototype ile tamamlayacaktır.)*

---

# 307. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development 24-Day Roadmap Completed *(Doküman Durumu: Geliştirme Öncesi 24 Günlük Yol Haritası Tamamlandı)*

**Total Development Duration:** 24 Business Days *(Toplam Geliştirme Süresi: 24 İş Günü)*

**Roadmap Structure:** 6 Phases *(Yol Haritası Yapısı: 6 Faz)*

**Phase 1:** Days 1–4 — Foundation & Device Audit *(Faz 1: Gün 1–4 — Foundation ve Device Audit)*

**Phase 2:** Days 5–9 — Deterministic Navigation Core *(Faz 2: Gün 5–9 — Deterministic Navigation Core)*

**Phase 3:** Days 10–14 — AI & ARCore Enhancements *(Faz 3: Gün 10–14 — AI ve ARCore Enhancement'ları)*

**Phase 4:** Days 15–18 — EKF, Recovery & Integration *(Faz 4: Gün 15–18 — EKF, Recovery ve Integration)*

**Phase 5:** Days 19–21 — Failure Testing, Pilot & Freeze *(Faz 5: Gün 19–21 — Failure Testing, Pilot ve Freeze)*

**Phase 6:** Days 22–24 — Final Benchmark & Delivery *(Faz 6: Gün 22–24 — Final Benchmark ve Delivery)*

**Physical Device Audit:** Day 1 *(Fiziksel Cihaz Audit: Gün 1)*

**Sensor Acquisition Target:** Day 2 *(Sensör Acquisition Hedefi: Gün 2)*

**Timing Infrastructure Target:** Day 3 *(Timing Infrastructure Hedefi: Gün 3)*

**Ground Truth Firewall Target:** Day 4 *(Ground Truth Firewall Hedefi: Gün 4)*

**Coordinate / PDR Mathematics Target:** Day 5 *(Coordinate / PDR Mathematics Hedefi: Gün 5)*

**Step Detector Target:** Day 6 *(Step Detector Hedefi: Gün 6)*

**Heading Target:** Day 7 *(Heading Hedefi: Gün 7)*

**Configuration A Live Target:** Day 8 *(Configuration A Live Hedefi: Gün 8)*

**Replayable PDR Baseline Target:** Day 9 *(Replayable PDR Baseline Hedefi: Gün 9)*

**Motion Dataset Target:** Day 10 *(Motion Dataset Hedefi: Gün 10)*

**Motion Model Training Target:** Day 11 *(Motion Model Training Hedefi: Gün 11)*

**LiteRT Deployment Target:** Day 12 *(LiteRT Deployment Hedefi: Gün 12)*

**Step-Length ML Retention Decision:** Day 13 *(Step-Length ML Retention Kararı: Gün 13)*

**ARCore Integration Target:** Day 14 *(ARCore Integration Hedefi: Gün 14)*

**Quality Engine Target:** Day 15 *(Quality Engine Hedefi: Gün 15)*

**Minimum `[E,N,ψ]` EKF Target:** Day 16 *(Minimum `[E,N,ψ]` EKF Hedefi: Gün 16)*

**ARCore / AI Fusion Target:** Day 17 *(ARCore / AI Fusion Hedefi: Gün 17)*

**Full Recovery Workflow Target:** Day 18 *(Tam Recovery Workflow Hedefi: Gün 18)*

**Failure Injection Day:** Day 19 *(Failure Injection Günü: Gün 19)*

**Pilot Field Day:** Day 20 *(Pilot Saha Günü: Gün 20)*

**Benchmark Freeze Day:** Day 21 *(Benchmark Freeze Günü: Gün 21)*

**Final Benchmark Collection:** Days 22–23 *(Final Benchmark Veri Toplama: Gün 22–23)*

**Final Analysis & Demo:** Day 24 *(Final Analiz ve Demo: Gün 24)*

**Replayable PDR Deadline:** Day 9 *(Replayable PDR Deadline: Gün 9)*

**Full NAVGUARD Runtime Deadline:** Day 18 *(Full NAVGUARD Runtime Deadline: Gün 18)*

**Critical Integrity Defects Allowed at Day 21 Freeze:** `0` *(Day 21 Freeze Sırasında İzin Verilen Critical Integrity Defect: `0`)*

**Final Benchmark Post-Hoc Tuning:** Forbidden *(Final Benchmark Post-Hoc Tuning: Yasak)*

**Development / Pilot Data for Tuning:** Allowed *(Development / Pilot Data ile Tuning: İzinli)*

**Final Benchmark Data for Tuning:** Forbidden *(Final Benchmark Data ile Tuning: Yasak)*

**Final Benchmark Build:** Frozen on Day 21 *(Final Benchmark Build: Day 21'de Freeze)*

**Final Metric Pipeline:** Frozen on Day 21 *(Final Metric Pipeline: Day 21'de Freeze)*

**Final Route Protocol:** Frozen on Day 21 *(Final Route Protocol: Day 21'de Freeze)*

**Final Inclusion Rules:** Frozen on Day 21 *(Final Inclusion Rule'ları: Day 21'de Freeze)*

**Primary PDR Baseline:** Mandatory *(Primary PDR Baseline: Zorunlu)*

**Motion Classification:** Mandatory *(Motion Classification: Zorunlu)*

**Ground Truth Firewall:** Mandatory *(Ground Truth Firewall: Zorunlu)*

**Replay:** Mandatory *(Replay: Zorunlu)*

**Final Field Benchmark:** Mandatory *(Final Field Benchmark: Zorunlu)*

**ARCore:** Target Enhancement with PDR Fallback *(ARCore: PDR Fallback'li Target Enhancement)*

**Learned Step Length:** Optional Retention after Evidence *(Learned Step Length: Evidence Sonrası İsteğe Bağlı Koruma)*

**Quantization:** Optional *(Quantization: İsteğe Bağlı)*

**Hardware Delegate:** Optional *(Hardware Delegate: İsteğe Bağlı)*

**Cross-Device Testing:** Optional *(Cross-Device Testing: İsteğe Bağlı)*

**Broad Placement Robustness:** Optional *(Broad Placement Robustness: İsteğe Bağlı)*

**Advanced Statistical Tests:** Optional *(Advanced Statistical Tests: İsteğe Bağlı)*

**Primary NAVGUARD Research Target:** ≥20% Matched-Session Median Position Error Reduction vs Configuration A *(Primary NAVGUARD Research Hedefi: Configuration A'ya Göre ≥%20 Matched-Session Median Position Error Azalması)*

**Motion AI Provisional Target:** Macro F1 ≥0.90 *(Motion AI Geçici Hedefi: Macro F1 ≥0.90)*

**Controlled Step Count Target:** Absolute Error ≤5% *(Kontrollü Step Count Hedefi: Absolute Error ≤%5)*

**Provisional AI Inference Target:** Approximately <50 ms *(Geçici AI Inference Hedefi: Yaklaşık <50 ms)*

**Ground Truth Firewall Required Counter:** `0` *(Ground Truth Firewall Gerekli Counter: `0`)*

**Final Deliverable Philosophy:** Reproducible Research Prototype, Not Demo-Only Application *(Final Deliverable Felsefesi: Yalnızca Demo Uygulaması Değil Reproducible Research Prototype)*

**Next Documentation Item:** 39 — Verification, Acceptance Criteria & Definition of Done *(Sonraki Dokümantasyon Öğesi: 39 — Verification, Acceptance Criteria ve Definition of Done)*
