# 39 — Verification, Acceptance Criteria & Definition of Done (Doğrulama, Kabul Kriterleri ve Tamamlanma Tanımı)

## 1. Document Purpose (Dokümanın Amacı)

This document defines how NAVGUARD requirements, subsystems, integrations, experiments, benchmark results, fallback behavior, performance, research integrity, and final deliverables will be verified before the project is considered complete. *(Bu doküman NAVGUARD gereksinimlerinin, alt sistemlerinin, entegrasyonlarının, deneylerinin, benchmark sonuçlarının, fallback davranışının, performansının, araştırma bütünlüğünün ve final deliverable'larının proje tamamlanmış sayılmadan önce nasıl doğrulanacağını tanımlar.)*

The document also defines the formal acceptance criteria and Definition of Done for the complete research prototype. *(Doküman ayrıca tam araştırma prototipi için resmî kabul kriterlerini ve Definition of Done'u tanımlar.)*

---

# 2. Verification Philosophy (Doğrulama Felsefesi)

NAVGUARD is not considered complete merely because the application launches or a demonstration route can be walked successfully. *(NAVGUARD yalnızca uygulama açıldığı veya bir demonstration rotası başarıyla yürünebildiği için tamamlanmış sayılmaz.)*

Completion requires traceable evidence that critical requirements work under normal, degraded, replay, and field conditions. *(Tamamlanma kritik gereksinimlerin normal, degraded, replay ve saha koşullarında çalıştığını gösteren izlenebilir kanıt gerektirir.)*

---

# 3. Verification vs Validation (Verification ile Validation)

Verification asks whether the system was built according to its technical specification. *(Verification sistemin teknik spesifikasyonuna göre geliştirilip geliştirilmediğini sorar.)*

Validation asks whether the resulting system meaningfully supports the intended research question and field use case. *(Validation ortaya çıkan sistemin amaçlanan araştırma sorusunu ve saha use case'ini anlamlı şekilde destekleyip desteklemediğini sorar.)*

---

# 4. Acceptance Philosophy (Kabul Felsefesi)

A component is accepted only when its required implementation, tests, evidence, and failure behavior satisfy the applicable criteria. *(Bir component yalnızca gerekli implementation, test, evidence ve failure behavior uygulanabilir kriterleri karşıladığında kabul edilir.)*

---

# 5. No Evidence, No PASS (Kanıt Yoksa PASS Yoktur)

A requirement without supporting evidence cannot be marked `PASS`. *(Supporting evidence olmayan bir requirement `PASS` işaretlenemez.)*

---

# 6. Acceptance States (Kabul Durumları)

NAVGUARD verification will use explicit acceptance states. *(NAVGUARD verification açık kabul durumları kullanacaktır.)*

```text
NOT_TESTED
IN_PROGRESS
PASS
PASS_WITH_LIMITATION
FAIL
BLOCKED
NOT_APPLICABLE
```

---

# 7. PASS Meaning (PASS Anlamı)

`PASS` means the requirement has been implemented and verified with the required evidence. *(`PASS`, requirement'ın uygulanmış ve gerekli evidence ile verified olduğu anlamına gelir.)*

---

# 8. PASS_WITH_LIMITATION Meaning (PASS_WITH_LIMITATION Anlamı)

`PASS_WITH_LIMITATION` means the requirement works within a documented limited scope that does not invalidate the project. *(`PASS_WITH_LIMITATION`, requirement'ın projeyi invalid hale getirmeyen documented sınırlı scope içerisinde çalıştığı anlamına gelir.)*

---

# 9. FAIL Meaning (FAIL Anlamı)

`FAIL` means the requirement does not satisfy the defined acceptance condition. *(`FAIL`, requirement'ın tanımlanmış acceptance condition'ı karşılamadığı anlamına gelir.)*

---

# 10. BLOCKED Meaning (BLOCKED Anlamı)

`BLOCKED` means verification cannot proceed because a prerequisite is unavailable. *(`BLOCKED`, bir prerequisite unavailable olduğu için verification'ın ilerleyemediği anlamına gelir.)*

---

# 11. NOT_APPLICABLE Meaning (NOT_APPLICABLE Anlamı)

`NOT_APPLICABLE` may only be used when the requirement genuinely does not apply to the selected final configuration. *(`NOT_APPLICABLE` yalnızca requirement gerçekten selected final configuration'a uygulanmıyorsa kullanılabilir.)*

---

# 12. Criticality Levels (Kritiklik Seviyeleri)

Requirements will be assigned one of three verification criticality levels. *(Requirement'lara üç verification criticality level'dan biri atanacaktır.)*

```text
MANDATORY
TARGET
OPTIONAL
```

---

# 13. MANDATORY Requirement (MANDATORY Gereksinim)

A mandatory requirement must pass for the corresponding project capability to be considered complete. *(Mandatory requirement ilgili proje capability'sinin complete sayılması için pass etmelidir.)*

---

# 14. TARGET Requirement (TARGET Gereksinim)

A target requirement is strongly desired but may finish as `PASS_WITH_LIMITATION` when the minimum research objective remains intact and the limitation is explicitly documented. *(Target requirement güçlü şekilde istenir ancak minimum research objective intact kalıyor ve limitation açık şekilde documented ise `PASS_WITH_LIMITATION` olarak tamamlanabilir.)*

---

# 15. OPTIONAL Requirement (OPTIONAL Gereksinim)

Optional requirements improve scope or robustness but are not necessary for minimum project completion. *(Optional requirement'lar scope veya robustness'ı geliştirir ancak minimum proje completion için gerekli değildir.)*

---

# 16. Verification Layers (Doğrulama Katmanları)

NAVGUARD will be verified through multiple complementary layers. *(NAVGUARD birbirini tamamlayan birden fazla layer üzerinden verified olacaktır.)*

```text
L1 — UNIT VERIFICATION
L2 — SUBSYSTEM VERIFICATION
L3 — INTEGRATION VERIFICATION
L4 — REPLAY VERIFICATION
L5 — DEVICE VERIFICATION
L6 — FIELD VALIDATION
L7 — BENCHMARK VALIDATION
L8 — RESEARCH-INTEGRITY VERIFICATION
```

---

# 17. Unit Verification Purpose (Unit Verification Amacı)

Unit verification confirms deterministic mathematical and software components in isolation. *(Unit verification deterministic mathematical ve software component'leri isolation içerisinde doğrular.)*

---

# 18. Subsystem Verification Purpose (Alt Sistem Verification Amacı)

Subsystem verification confirms complete functional components such as step detection, heading, GNSS, ARCore, AI, or EKF. *(Subsystem verification step detection, heading, GNSS, ARCore, AI veya EKF gibi complete functional component'leri doğrular.)*

---

# 19. Integration Verification Purpose (Entegrasyon Verification Amacı)

Integration verification confirms correct communication and state transitions between subsystems. *(Integration verification subsystem'ler arasındaki doğru communication ve state transition'ları doğrular.)*

---

# 20. Replay Verification Purpose (Replay Verification Amacı)

Replay verification confirms determinism, reproducibility, and comparison fairness. *(Replay verification determinism, reproducibility ve comparison fairness'i doğrular.)*

---

# 21. Device Verification Purpose (Cihaz Verification Amacı)

Device verification confirms actual operation on the Xiaomi Redmi Note 9 Pro. *(Device verification Xiaomi Redmi Note 9 Pro üzerinde actual operation'ı doğrular.)*

---

# 22. Field Validation Purpose (Saha Validation Amacı)

Field validation confirms behavior under real pedestrian motion and real environmental conditions. *(Field validation gerçek yaya hareketi ve gerçek environmental condition'lar altında behavior'ı doğrular.)*

---

# 23. Benchmark Validation Purpose (Benchmark Validation Amacı)

Benchmark validation determines whether NAVGUARD improves navigation relative to the defined baseline. *(Benchmark validation NAVGUARD'ın defined baseline'a göre navigation'ı iyileştirip iyileştirmediğini belirler.)*

---

# 24. Research-Integrity Verification Purpose (Araştırma Bütünlüğü Verification Amacı)

Research-integrity verification ensures final results are scientifically defensible and free from prohibited ground-truth leakage. *(Research-integrity verification final result'ların bilimsel olarak savunulabilir ve prohibited ground-truth leakage'dan arınmış olduğunu sağlar.)*

---

# 25. Evidence Types (Kanıt Türleri)

Verification evidence may include automated test results, replay outputs, field sessions, logs, manifests, metric tables, hashes, screenshots, profiler traces, and code-version records. *(Verification evidence automated test result'ları, replay output'ları, field session'ları, log'lar, manifest'ler, metric table'ları, hash'ler, screenshot'lar, profiler trace'leri ve code-version record'larını içerebilir.)*

---

# 26. Verification Record (Doğrulama Kaydı)

Every formal acceptance item should have a traceable verification record. *(Her formal acceptance item traceable verification record'a sahip olmalıdır.)*

```text
VerificationRecord
- verificationId
- requirementId
- subsystem
- criticality
- method
- buildId
- configurationId
- evidenceRefs
- expectedResult
- actualResult
- status
- limitation
- notes
```

---

# 27. Requirement-to-Test Traceability (Requirement-to-Test İzlenebilirliği)

Every mandatory requirement should map to at least one verification method. *(Her mandatory requirement en az bir verification method'a map edilmelidir.)*

---

# 28. Requirement-to-Evidence Traceability (Requirement-to-Evidence İzlenebilirliği)

Every passed mandatory requirement should map to preserved evidence. *(Pass edilen her mandatory requirement preserved evidence'a map edilmelidir.)*

---

# 29. Verification Matrix (Doğrulama Matrisi)

A master verification matrix will connect requirements to tests, evidence, and acceptance state. *(Master verification matrix requirement'ları test'lere, evidence'a ve acceptance state'e bağlayacaktır.)*

---

# 30. Candidate Verification Matrix Schema (Aday Doğrulama Matrisi Schema)

```text
Requirement
Subsystem
Criticality
Verification Method
Evidence
Acceptance Condition
Status
```

---

# 31. Build Identity Requirement (Build Kimliği Gereksinimi)

Every formal verification result must identify the build that produced it. *(Her formal verification result onu üreten build'i identify etmelidir.)*

---

# 32. Configuration Identity Requirement (Configuration Kimliği Gereksinimi)

Every replay, benchmark, or field result must identify the active configuration. *(Her replay, benchmark veya field result active configuration'ı identify etmelidir.)*

---

# 33. Model Identity Requirement (Model Kimliği Gereksinimi)

AI verification evidence must identify the exact model version and hash. *(AI verification evidence exact model version ve hash'i identify etmelidir.)*

---

# 34. Analysis Version Requirement (Analiz Sürümü Gereksinimi)

Benchmark result evidence must identify the evaluation pipeline version. *(Benchmark result evidence evaluation pipeline version'ı identify etmelidir.)*

---

# 35. Device Baseline Acceptance (Cihaz Baseline Kabulü)

The physical Xiaomi Redmi Note 9 Pro capability audit must complete before device-dependent verification is accepted. *(Device-dependent verification kabul edilmeden önce fiziksel Xiaomi Redmi Note 9 Pro capability audit tamamlanmalıdır.)*

---

# 36. Accelerometer Availability Acceptance (İvmeölçer Kullanılabilirlik Kabulü)

The accelerometer must be detected and must produce timestamped samples continuously during a representative device session. *(Accelerometer detected olmalı ve representative device session sırasında continuous timestamped sample üretmelidir.)*

**Criticality:** `MANDATORY`. *(Kritiklik: `MANDATORY`.)*

---

# 37. Gyroscope Availability Acceptance (Jiroskop Kullanılabilirlik Kabulü)

The gyroscope must be detected and must produce usable timestamped samples. *(Gyroscope detected olmalı ve usable timestamped sample üretmelidir.)*

**Criticality:** `MANDATORY`. *(Kritiklik: `MANDATORY`.)*

---

# 38. Magnetometer Availability Acceptance (Manyetometre Kullanılabilirlik Kabulü)

The magnetometer must be detected and must produce samples and Android accuracy metadata. *(Magnetometer detected olmalı ve sample ile Android accuracy metadata üretmelidir.)*

**Criticality:** `MANDATORY`. *(Kritiklik: `MANDATORY`.)*

---

# 39. Rotation Vector Acceptance (Rotation Vector Kabulü)

Rotation Vector support must be audited and may be used when physically available and validated. *(Rotation Vector support audited edilmeli ve fiziksel olarak available ve validated olduğunda kullanılabilir.)*

**Criticality:** `TARGET`. *(Kritiklik: `TARGET`.)*

---

# 40. Barometer Acceptance (Barometre Kabulü)

Barometer support is accepted only if the physical audit confirms availability and the project chooses to use it. *(Barometer support yalnızca fiziksel audit availability'yi doğrular ve proje onu kullanmayı seçerse kabul edilir.)*

**Criticality:** `OPTIONAL`. *(Kritiklik: `OPTIONAL`.)*

---

# 41. Sensor Timestamp Acceptance (Sensör Timestamp Kabulü)

Motion sensor timestamps must be monotonic within each authoritative stream. *(Motion sensor timestamp'leri her authoritative stream içerisinde monotonic olmalıdır.)*

---

# 42. Sensor Effective Rate Acceptance (Sensör Efektif Rate Kabulü)

Actual delivered rates must be measured from timestamps rather than assumed from requested rates. *(Actual delivered rate'ler requested rate'lerden assumed edilmek yerine timestamp'lardan measured edilmelidir.)*

---

# 43. Sensor Gap Detection Acceptance (Sensör Gap Detection Kabulü)

The preprocessing pipeline must detect gaps that exceed the frozen allowable interval. *(Preprocessing pipeline frozen allowable interval'ı aşan gap'leri detect etmelidir.)*

---

# 44. Sensor Staleness Acceptance (Sensör Staleness Kabulü)

A stale sample must not remain indefinitely valid. *(Stale sample indefinitely valid kalmamalıdır.)*

---

# 45. Sensor Freeze Acceptance (Sensör Freeze Kabulü)

A registered sensor stream whose timestamp stops advancing must transition to stale or unavailable according to policy. *(Timestamp'i ilerlemeyi durduran registered sensor stream policy'ye göre stale veya unavailable durumuna geçmelidir.)*

---

# 46. Timing Architecture Acceptance (Timing Mimarisi Kabulü)

All estimator-relevant events must be represented on a common monotonic experiment timeline or through explicitly validated clock mapping. *(Estimator-relevant tüm event'ler common monotonic experiment timeline üzerinde veya explicitly validated clock mapping üzerinden represented edilmelidir.)*

---

# 47. Out-of-Order Event Acceptance (Sıra Dışı Event Kabulü)

Out-of-order events must follow a deterministic processing or rejection policy. *(Out-of-order event'ler deterministic processing veya rejection policy izlemelidir.)*

---

# 48. Deterministic Timing Replay Acceptance (Deterministik Timing Replay Kabulü)

The same timing fixture must produce the same ordering result across repeated replay. *(Aynı timing fixture repeated replay boyunca aynı ordering result'ı üretmelidir.)*

---

# 49. Coordinate System Acceptance (Koordinat Sistemi Kabulü)

Internal navigation coordinates must use ENU with East, North, and Up axes as defined in Page 14. *(Internal navigation coordinate'ları Page 14'te defined edildiği şekilde East, North ve Up axis'leriyle ENU kullanmalıdır.)*

---

# 50. Heading Convention Acceptance (Heading Convention Kabulü)

Internal heading must be clockwise from true north and normalized consistently. *(Internal heading true north'tan clockwise olmalı ve consistently normalized edilmelidir.)*

---

# 51. WGS84-to-ENU Acceptance (WGS84-to-ENU Kabulü)

Known coordinate fixtures must convert into expected ENU values within numerical tolerance. *(Known coordinate fixture'ları numerical tolerance içerisinde expected ENU value'lara convert edilmelidir.)*

---

# 52. ENU-to-WGS84 Acceptance (ENU-to-WGS84 Kabulü)

ENU positions must convert back to WGS84 consistently. *(ENU position'ları WGS84'e consistently geri convert edilmelidir.)*

---

# 53. Coordinate Round-Trip Acceptance (Koordinat Round-Trip Kabulü)

WGS84 → ECEF → ENU → ECEF → WGS84 round-trip error must remain within implementation-level numerical tolerance. *(WGS84 → ECEF → ENU → ECEF → WGS84 round-trip error implementation-level numerical tolerance içerisinde kalmalıdır.)*

---

# 54. Cardinal PDR North Test (Cardinal PDR North Testi)

A synthetic step at heading `0°` must increase North without introducing material East movement. *(Heading `0°` olan synthetic step North'u artırmalı ve material East movement oluşturmamalıdır.)*

---

# 55. Cardinal PDR East Test (Cardinal PDR East Testi)

A synthetic step at heading `90°` must increase East. *(Heading `90°` olan synthetic step East'i artırmalıdır.)*

---

# 56. Cardinal PDR South Test (Cardinal PDR South Testi)

A synthetic step at heading `180°` must reduce North. *(Heading `180°` olan synthetic step North'u azaltmalıdır.)*

---

# 57. Cardinal PDR West Test (Cardinal PDR West Testi)

A synthetic step at heading `270°` must reduce East. *(Heading `270°` olan synthetic step East'i azaltmalıdır.)*

---

# 58. Circular Heading Difference Acceptance (Circular Heading Difference Kabulü)

A predicted heading of `359°` and reference of `1°` must evaluate to approximately `2°` error rather than `358°`. *(Predicted heading `359°` ve reference `1°`, `358°` yerine yaklaşık `2°` error olarak evaluate edilmelidir.)*

---

# 59. GNSS Provider Acceptance (GNSS Provider Kabulü)

Formal GNSS acquisition must use the configured authoritative GNSS provider and must not silently substitute an undeclared fused provider. *(Formal GNSS acquisition configured authoritative GNSS provider kullanmalı ve undeclared fused provider'ı sessizce substitute etmemelidir.)*

---

# 60. GNSS Timestamp Acceptance (GNSS Timestamp Kabulü)

Formal GNSS samples must retain monotonic elapsed-realtime-based timestamps. *(Formal GNSS sample'ları monotonic elapsed-realtime-based timestamp'leri korumalıdır.)*

---

# 61. Anchor Validation Acceptance (Anchor Validation Kabulü)

The first GNSS callback must not automatically become the anchor. *(İlk GNSS callback otomatik olarak anchor olmamalıdır.)*

---

# 62. Anchor Quality Acceptance (Anchor Kalite Kabulü)

An anchor may only be created after the candidate passes the frozen GNSS quality and freshness policy. *(Anchor yalnızca candidate frozen GNSS quality ve freshness policy'yi geçtikten sonra oluşturulabilir.)*

---

# 63. Anchor Immutability Acceptance (Anchor Immutability Kabulü)

The active local frame anchor must not change silently during a denied interval. *(Active local frame anchor denied interval sırasında sessizce değişmemelidir.)*

---

# 64. Ground Truth Firewall Acceptance (Ground Truth Firewall Kabulü)

Protected GNSS used as Evaluation Mode reference must never become an estimator update during denial. *(Evaluation Mode reference olarak kullanılan protected GNSS denied sırasında hiçbir zaman estimator update haline gelmemelidir.)*

---

# 65. Ground Truth Firewall Counter Acceptance (Ground Truth Firewall Counter Kabulü)

The following counter must equal zero for every valid formal denied interval. *(Aşağıdaki counter her valid formal denied interval için zero olmalıdır.)*

```text
unauthorizedGnssEstimatorUpdateCount = 0
```

---

# 66. Ground Truth Firewall Mutation Acceptance (Ground Truth Firewall Mutation Kabulü)

Changing protected GNSS reference values during replay must not alter denied estimator output. *(Replay sırasında protected GNSS reference value'larını değiştirmek denied estimator output'u değiştirmemelidir.)*

---

# 67. Ground Truth Firewall AI Acceptance (Ground Truth Firewall AI Kabulü)

Protected GNSS must not appear among Motion Classification or Step Length Estimation live model features. *(Protected GNSS Motion Classification veya Step Length Estimation live model feature'ları arasında bulunmamalıdır.)*

---

# 68. Ground Truth Firewall UI Acceptance (Ground Truth Firewall UI Kabulü)

Protected reference position must remain hidden from the operator during the blinded denied interval. *(Protected reference position blinded denied interval sırasında operator'dan hidden kalmalıdır.)*

---

# 69. Firewall Violation Acceptance Rule (Firewall İhlali Kabul Kuralı)

Any proven unauthorized GNSS influence changes the affected formal interval status to `FAIL`. *(Proven herhangi bir unauthorized GNSS influence affected formal interval status'unu `FAIL` yapar.)*

---

# 70. Step Detector Causality Acceptance (Adım Detector Causality Kabulü)

The step detector must operate causally and must not depend on future route information. *(Step detector causal çalışmalı ve future route information'a bağlı olmamalıdır.)*

---

# 71. Step Event Timestamp Acceptance (Step Event Timestamp Kabulü)

Every accepted step must contain a valid monotonic timestamp. *(Her accepted step valid monotonic timestamp içermelidir.)*

---

# 72. Step Detector Determinism Acceptance (Step Detector Determinizm Kabulü)

The same sensor replay must produce the same accepted step sequence under the same configuration. *(Aynı sensor replay aynı configuration altında aynı accepted step sequence'i üretmelidir.)*

---

# 73. Step Count Metric Acceptance (Adım Sayısı Metrik Kabulü)

Controlled step-count sessions must calculate absolute and percentage error against verified physical steps. *(Controlled step-count session'ları verified physical step'lere karşı absolute ve percentage error hesaplamalıdır.)*

---

# 74. Step Count Target Acceptance (Adım Sayısı Hedef Kabulü)

The provisional target is absolute step-count percentage error at or below `5%` on the frozen controlled protocol. *(Geçici hedef frozen controlled protocol üzerinde absolute step-count percentage error'ın `5%` veya altında olmasıdır.)*

---

# 75. Step Count Target Criticality (Adım Sayısı Hedef Kritiklik)

The `≤5%` value is a target performance criterion rather than a Ground Truth Firewall-style integrity gate. *(`≤5%` değeri Ground Truth Firewall-style integrity gate yerine target performance criterion'dır.)*

---

# 76. False-Step Stationary Acceptance (Stationary False-Step Kabulü)

Stationary test sessions must be evaluated for false accepted steps. *(Stationary test session'ları false accepted step açısından evaluate edilmelidir.)*

---

# 77. Step Detector Fallback Acceptance (Step Detector Fallback Kabulü)

The system must not fabricate step events when the authoritative detector is unavailable. *(Authoritative detector unavailable olduğunda sistem step event fabricate etmemelidir.)*

---

# 78. Fixed Step-Length Acceptance (Sabit Adım Uzunluğu Kabulü)

A calibrated fixed step-length fallback must be implemented before learned step length can become navigation-critical. *(Learned step length navigation-critical hale gelmeden önce calibrated fixed step-length fallback uygulanmalıdır.)*

---

# 79. Fixed Calibration Acceptance (Sabit Kalibrasyon Kabulü)

The calibration formula must use an independently known reference distance and verified step count. *(Calibration formula independently known reference distance ve verified step count kullanmalıdır.)*

---

# 80. Deterministic Variable Step-Length Acceptance (Deterministik Değişken Step-Length Kabulü)

If the deterministic variable method is retained, its parameters must be calibrated using development or calibration data only. *(Deterministic variable method retained edilirse parameter'ları yalnızca development veya calibration data kullanılarak calibrated edilmelidir.)*

---

# 81. No Final Benchmark Calibration Acceptance (Final Benchmark ile Kalibrasyon Olmaması Kabulü)

Step-length calibration constants must not be tuned using final benchmark true distance. *(Step-length calibration constant'ları final benchmark true distance kullanılarak tune edilmemelidir.)*

---

# 82. Learned Step-Length Valid Output Acceptance (Learned Step-Length Geçerli Output Kabulü)

Learned output must reject NaN, infinity, negative, or physically implausible values before PDR propagation. *(Learned output NaN, infinity, negative veya physically implausible value'ları PDR propagation öncesinde reject etmelidir.)*

---

# 83. Learned Step-Length Fallback Acceptance (Learned Step-Length Fallback Kabulü)

Invalid learned step-length output must fall back deterministically to the validated non-ML method. *(Invalid learned step-length output validated non-ML method'a deterministic şekilde fallback yapmalıdır.)*

---

# 84. Learned Step-Length Retention Acceptance (Learned Step-Length Retention Kabulü)

A learned model may remain navigation-enabled only if held-out evidence demonstrates measurable advantage over deterministic baselines. *(Learned model yalnızca held-out evidence deterministic baseline'lara karşı measurable advantage gösterirse navigation-enabled kalabilir.)*

---

# 85. Learned Step-Length Minimum Project Role (Learned Step-Length Minimum Proje Rolü)

Failure to retain a learned step-length model does not make the minimum project incomplete when deterministic step length remains functional. *(Deterministic step length functional kaldığında learned step-length model'in retained edilememesi minimum projeyi incomplete yapmaz.)*

---

# 86. Heading True-North Acceptance (Heading True-North Kabulü)

The operational heading pipeline must output true-north-referenced heading rather than magnetic north alone. *(Operational heading pipeline yalnızca magnetic north yerine true-north-referenced heading output etmelidir.)*

---

# 87. Declination Acceptance (Declination Kabulü)

Geomagnetic declination correction must be applied when required by the selected absolute-heading method. *(Selected absolute-heading method gerektiriyorsa geomagnetic declination correction uygulanmalıdır.)*

---

# 88. Heading Circularity Acceptance (Heading Circularity Kabulü)

All heading innovations and errors must use circular mathematics. *(Tüm heading innovation ve error'lar circular mathematics kullanmalıdır.)*

---

# 89. Magnetic Disturbance Acceptance (Manyetik Bozulma Kabulü)

Detected hard-invalid magnetic heading must not be accepted merely by assigning larger covariance. *(Detected hard-invalid magnetic heading yalnızca larger covariance atanarak accept edilmemelidir.)*

---

# 90. Soft Heading Degradation Acceptance (Soft Heading Degradation Kabulü)

Soft-degraded heading may remain usable only with appropriately increased uncertainty. *(Soft-degraded heading yalnızca appropriately increased uncertainty ile usable kalabilir.)*

---

# 91. Heading Loss Fallback Acceptance (Heading Kaybı Fallback Kabulü)

When no defensible heading remains, directional PDR propagation must not continue indefinitely as if heading were valid. *(Defensible heading kalmadığında directional PDR propagation heading valid'miş gibi indefinitely devam etmemelidir.)*

---

# 92. Motion AI Class Acceptance (Motion AI Class Kabulü)

The trained motion classifier must use exactly the frozen operational class set. *(Trained motion classifier exactly frozen operational class set'i kullanmalıdır.)*

```text
STATIONARY
WALKING
RUNNING
TURNING
```

---

# 93. Motion AI Channel Acceptance (Motion AI Channel Kabulü)

The primary model input must preserve the frozen canonical channel ordering. *(Primary model input frozen canonical channel ordering'i korumalıdır.)*

---

# 94. Motion AI Session-Wise Split Acceptance (Motion AI Session-Wise Split Kabulü)

Train, validation, and test partitions must be created by session before overlapping windows are generated. *(Train, validation ve test partition'ları overlapping window'lar oluşturulmadan önce session'a göre oluşturulmalıdır.)*

---

# 95. AI Leakage Rejection Acceptance (AI Leakage Reddetme Kabulü)

Overlapping windows from the same physical session must never be split across train and test. *(Aynı physical session'dan overlapping window'lar hiçbir zaman train ve test arasında split edilmemelidir.)*

---

# 96. Motion AI Baseline Acceptance (Motion AI Baseline Kabulü)

At least one classical baseline must be trained and evaluated. *(En az bir classical baseline train edilmeli ve evaluate edilmelidir.)*

---

# 97. Random Forest Baseline Acceptance (Random Forest Baseline Kabulü)

Random Forest should serve as the principal nonlinear classical comparison unless a documented reason changes that decision before freeze. *(Freeze öncesinde documented reason ile karar değişmezse Random Forest principal nonlinear classical comparison olarak kullanılmalıdır.)*

---

# 98. 1D-CNN Acceptance (1D-CNN Kabulü)

A lightweight 1D-CNN candidate must be trained and evaluated as the primary neural approach. *(Primary neural approach olarak lightweight 1D-CNN candidate train edilmeli ve evaluate edilmelidir.)*

---

# 99. Motion AI Macro F1 Acceptance (Motion AI Macro F1 Kabulü)

Held-out session-wise Macro F1 must be calculated from the frozen test set. *(Held-out session-wise Macro F1 frozen test set'ten hesaplanmalıdır.)*

---

# 100. Motion AI Target Acceptance (Motion AI Hedef Kabulü)

The provisional target remains `Macro F1 ≥ 0.90`. *(Geçici hedef `Macro F1 ≥ 0.90` olarak kalır.)*

---

# 101. AI Confusion Matrix Acceptance (AI Confusion Matrix Kabulü)

A full four-class confusion matrix must be preserved for the held-out test set. *(Held-out test set için full four-class confusion matrix preserved edilmelidir.)*

---

# 102. AI Per-Class Metric Acceptance (AI Per-Class Metrik Kabulü)

Precision, recall, and F1 must be reported per class. *(Precision, recall ve F1 class başına raporlanmalıdır.)*

---

# 103. AI Accuracy Acceptance (AI Accuracy Kabulü)

Overall accuracy must be reported as a secondary metric. *(Overall accuracy secondary metric olarak raporlanmalıdır.)*

---

# 104. AI Softmax Acceptance (AI Softmax Kabulü)

Uncalibrated softmax output must not be described as a guaranteed probability of correctness. *(Uncalibrated softmax output guaranteed probability of correctness olarak tanımlanmamalıdır.)*

---

# 105. AI Metadata Acceptance (AI Metadata Kabulü)

The deployed model must include model ID, version, file hash, input schema, class order, and preprocessing version. *(Deployed model model ID, version, file hash, input schema, class order ve preprocessing version içermelidir.)*

---

# 106. AI Preprocessing Parity Acceptance (AI Preprocessing Parity Kabulü)

Golden raw sensor windows must produce matching Python and Android preprocessing tensors within tolerance. *(Golden raw sensor window'lar tolerance içerisinde matching Python ve Android preprocessing tensor'ları üretmelidir.)*

---

# 107. AI Output Parity Acceptance (AI Output Parity Kabulü)

Golden model inputs must produce sufficiently matching Python and on-device model outputs. *(Golden model input'lar sufficiently matching Python ve on-device model output'ları üretmelidir.)*

---

# 108. AI Shadow-Mode Acceptance (AI Shadow-Mode Kabulü)

The model must operate successfully in shadow mode before it is allowed to influence navigation. *(Model navigation'ı influence etmesine izin verilmeden önce shadow mode içerisinde successfully çalışmalıdır.)*

---

# 109. AI Failure Fallback Acceptance (AI Failure Fallback Kabulü)

Model-load or inference failure must not crash deterministic navigation. *(Model-load veya inference failure deterministic navigation'ı crash etmemelidir.)*

---

# 110. AI Staleness Acceptance (AI Staleness Kabulü)

Stale AI outputs must expire and must not continue influencing navigation indefinitely. *(Stale AI output'lar expire olmalı ve navigation'ı indefinitely influence etmeye devam etmemelidir.)*

---

# 111. AI Low-Confidence Acceptance (AI Low-Confidence Kabulü)

Low-confidence outputs may become controller state `UNKNOWN` according to the frozen policy instead of forcing an operational class. *(Low-confidence output'lar operational class'ı force etmek yerine frozen policy'ye göre controller state `UNKNOWN` olabilir.)*

---

# 112. AI Navigation-Effect Acceptance (AI Navigation-Effect Kabulü)

Motion Classification must affect at least one validated navigation behavior rather than existing only as a UI label. *(Motion Classification yalnızca UI label olarak var olmak yerine en az bir validated navigation behavior'ı etkilemelidir.)*

---

# 113. AI Latency Acceptance (AI Latency Kabulü)

Median and P95 on-device inference latency must be measured on the Redmi Note 9 Pro. *(Median ve P95 on-device inference latency Redmi Note 9 Pro üzerinde measured edilmelidir.)*

---

# 114. AI Provisional Runtime Target (AI Geçici Runtime Hedefi)

The provisional target remains approximately below `50 ms` per inference according to the statistic frozen before final reporting. *(Geçici hedef final reporting öncesinde frozen edilen statistic'e göre inference başına yaklaşık `50 ms` altında kalmaktır.)*

---

# 115. AI End-to-End Latency Acceptance (AI Uçtan Uca Latency Kabulü)

Model execution latency must remain separate from complete motion-context latency. *(Model execution latency complete motion-context latency'den ayrı kalmalıdır.)*

---

# 116. ARCore Support Acceptance (ARCore Support Kabulü)

Runtime support and installation status must be checked explicitly. *(Runtime support ve installation status explicit şekilde checked edilmelidir.)*

---

# 117. ARCore Optional Architecture Acceptance (ARCore İsteğe Bağlı Mimari Kabulü)

The application must remain operational through PDR when ARCore is unavailable. *(ARCore unavailable olduğunda application PDR üzerinden operational kalmalıdır.)*

---

# 118. ARCore Tracking-State Acceptance (ARCore Tracking-State Kabulü)

Only poses obtained in valid `TRACKING` state may enter formal fusion. *(Yalnızca valid `TRACKING` state içerisinde obtained pose'lar formal fusion'a girebilir.)*

---

# 119. ARCore PAUSED Acceptance (ARCore PAUSED Kabulü)

`PAUSED` poses must be rejected from navigation updates. *(`PAUSED` pose'ları navigation update'lerinden rejected edilmelidir.)*

---

# 120. ARCore STOPPED Acceptance (ARCore STOPPED Kabulü)

A stopped ARCore session must no longer provide active navigation measurements. *(Stopped ARCore session artık active navigation measurement sağlamamalıdır.)*

---

# 121. ARCore Segment Acceptance (ARCore Segment Kabulü)

ARCore tracking must use explicit local segment identity. *(ARCore tracking explicit local segment identity kullanmalıdır.)*

---

# 122. ARCore Recovery Segment Acceptance (ARCore Recovery Segment Kabulü)

After tracking loss, recovered tracking should create a new segment unless continuity is explicitly validated. *(Tracking loss sonrasında recovered tracking continuity explicitly validated değilse new segment oluşturmalıdır.)*

---

# 123. ARCore No Fake Motion Acceptance (ARCore Sahte Motion Olmaması Kabulü)

Tracking loss must not be converted into an artificial zero-motion measurement. *(Tracking loss artificial zero-motion measurement'a convert edilmemelidir.)*

---

# 124. ARCore Axis Acceptance (ARCore Axis Kabulü)

ARCore axes must not be hardcoded directly as ENU axes. *(ARCore axis'leri doğrudan ENU axis'leri olarak hardcode edilmemelidir.)*

---

# 125. ARCore-to-ENU Alignment Acceptance (ARCore-to-ENU Hizalama Kabulü)

A documented transform must align ARCore relative displacement with the NAVGUARD ENU frame. *(Documented transform ARCore relative displacement'ı NAVGUARD ENU frame ile align etmelidir.)*

---

# 126. ARCore Alignment Failure Acceptance (ARCore Alignment Hatası Kabulü)

If alignment cannot be validated, ARCore must remain excluded from formal fusion. *(Alignment validated edilemiyorsa ARCore formal fusion'dan excluded kalmalıdır.)*

---

# 127. ARCore Timing Acceptance (ARCore Timing Kabulü)

ARCore timing must be validated against the common experiment timeline before tightly synchronized fusion is enabled. *(Tightly synchronized fusion enabled olmadan önce ARCore timing common experiment timeline'a karşı validated edilmelidir.)*

---

# 128. ARCore Tracking-Loss Fallback Acceptance (ARCore Tracking-Loss Fallback Kabulü)

PDR must continue when ARCore tracking is lost and PDR inputs remain valid. *(ARCore tracking kaybolduğunda ve PDR input'ları valid kaldığında PDR devam etmelidir.)*

---

# 129. ARCore Resource Acceptance (ARCore Kaynak Kabulü)

ARCore resource cost must be measured rather than assumed. *(ARCore resource cost assumed edilmek yerine measured edilmelidir.)*

---

# 130. Quality Engine Acceptance (Quality Engine Kabulü)

Every estimator-relevant source must expose availability and quality separately. *(Estimator-relevant her source availability ve quality'yi ayrı expose etmelidir.)*

---

# 131. Quality State Acceptance (Quality State Kabulü)

The common quality state vocabulary must be implemented consistently. *(Common quality state vocabulary consistently uygulanmalıdır.)*

```text
UNKNOWN
GOOD
USABLE
DEGRADED
UNRELIABLE
UNAVAILABLE
```

---

# 132. Quality Metadata Acceptance (Quality Metadata Kabulü)

Measurements entering estimator logic should preserve source, timestamp, quality, and reason metadata. *(Estimator logic'e giren measurement'lar source, timestamp, quality ve reason metadata'yı preserve etmelidir.)*

---

# 133. Hard Invalidity Acceptance (Hard Invalidity Kabulü)

Hard-invalid measurements must be rejected before covariance scaling. *(Hard-invalid measurement'lar covariance scaling öncesinde rejected edilmelidir.)*

---

# 134. Soft Degradation Acceptance (Soft Degradation Kabulü)

Soft-degraded measurements may only remain usable when uncertainty is increased according to the selected policy. *(Soft-degraded measurement'lar yalnızca selected policy'ye göre uncertainty increased edildiğinde usable kalabilir.)*

---

# 135. Authorization-before-Quality Acceptance (Authorization-before-Quality Kabulü)

Source authorization must occur before quality processing when Ground Truth Firewall rules apply. *(Ground Truth Firewall rule'ları uygulandığında source authorization quality processing öncesinde gerçekleşmelidir.)*

---

# 136. Hysteresis Acceptance (Hysteresis Kabulü)

Quality recovery should avoid rapid oscillation between usable and unusable states. *(Quality recovery usable ve unusable state'ler arasında rapid oscillation'dan kaçınmalıdır.)*

---

# 137. EKF State Acceptance (EKF State Kabulü)

The initial formal EKF state must use the frozen minimum state `[E,N,ψ]`. *(Initial formal EKF state frozen minimum state `[E,N,ψ]` kullanmalıdır.)*

---

# 138. Extended EKF State Acceptance (Genişletilmiş EKF State Kabulü)

Velocity states may only be introduced if measured evidence demonstrates a meaningful benefit. *(Velocity state'leri yalnızca measured evidence meaningful benefit gösterirse eklenebilir.)*

---

# 139. EKF Step Prediction Acceptance (EKF Step Prediction Kabulü)

The EKF process model must propagate accepted step length through the frozen nonlinear PDR equations. *(EKF process model accepted step length'i frozen nonlinear PDR equation'ları üzerinden propagate etmelidir.)*

---

# 140. EKF Jacobian Acceptance (EKF Jacobian Kabulü)

The implementation must match the frozen Jacobian for the `[E,N,ψ]` state. *(Implementation `[E,N,ψ]` state için frozen Jacobian ile match etmelidir.)*

---

# 141. Step-Length Noise Mapping Acceptance (Step-Length Noise Mapping Kabulü)

Step-length uncertainty must affect position covariance through the defined process-noise mapping. *(Step-length uncertainty defined process-noise mapping üzerinden position covariance'ı etkilemelidir.)*

---

# 142. Heading Uncertainty Propagation Acceptance (Heading Uncertainty Propagation Kabulü)

Heading uncertainty must propagate into position uncertainty through the nonlinear process model. *(Heading uncertainty nonlinear process model üzerinden position uncertainty'ye propagate etmelidir.)*

---

# 143. Circular Heading Innovation Acceptance (Circular Heading Innovation Kabulü)

Heading measurement innovation must use circular difference. *(Heading measurement innovation circular difference kullanmalıdır.)*

---

# 144. Joseph Update Acceptance (Joseph Update Kabulü)

Covariance update should use the Joseph form in the formal implementation. *(Covariance update formal implementation içerisinde Joseph form kullanmalıdır.)*

---

# 145. EKF Finite-State Acceptance (EKF Finite-State Kabulü)

Published fused state values must remain finite. *(Published fused state value'lar finite kalmalıdır.)*

---

# 146. EKF Covariance Symmetry Acceptance (EKF Covariance Symmetry Kabulü)

Covariance must remain symmetric within numerical tolerance. *(Covariance numerical tolerance içerisinde symmetric kalmalıdır.)*

---

# 147. EKF Invalid Covariance Acceptance (EKF Invalid Covariance Kabulü)

NaN, infinite, or materially invalid covariance must trigger rejection or controlled fallback. *(NaN, infinite veya materially invalid covariance rejection veya controlled fallback tetiklemelidir.)*

---

# 148. Innovation Gate Acceptance (Innovation Gate Kabulü)

Outlier measurements failing the frozen innovation gate must not update the fused state. *(Frozen innovation gate'i fail eden outlier measurement'lar fused state'i update etmemelidir.)*

---

# 149. NIS Freeze Acceptance (NIS Freeze Kabulü)

The final NIS threshold must be frozen before final benchmark interpretation. *(Final NIS threshold final benchmark interpretation öncesinde frozen edilmelidir.)*

---

# 150. Independent PDR Acceptance (Independent PDR Kabulü)

The independent PDR baseline trajectory must remain preserved while EKF fusion is active. *(EKF fusion active iken independent PDR baseline trajectory preserved kalmalıdır.)*

---

# 151. EKF Fallback Acceptance (EKF Fallback Kabulü)

Invalid fused output must be able to fall back to independent PDR when PDR remains valid. *(Invalid fused output PDR valid kaldığında independent PDR'a fallback yapabilmelidir.)*

---

# 152. Navigation Mode Acceptance (Navigasyon Mode Kabulü)

The navigation state machine must represent GNSS Mode, Evaluation Mode, denied navigation, recovery, and restored operation explicitly. *(Navigation state machine GNSS Mode, Evaluation Mode, denied navigation, recovery ve restored operation'ı explicit şekilde represent etmelidir.)*

---

# 153. Denial Boundary Acceptance (Denial Boundary Kabulü)

Entering denied mode must create an explicit timestamped authorization boundary. *(Denied mode'a girmek explicit timestamped authorization boundary oluşturmalıdır.)*

---

# 154. Denial Continuity Acceptance (Denial Continuity Kabulü)

The estimator must not reset merely because GNSS authorization is removed. *(Estimator yalnızca GNSS authorization removed olduğu için reset olmamalıdır.)*

---

# 155. Denial Covariance Acceptance (Denial Covariance Kabulü)

GNSS denial must not artificially reduce estimator uncertainty. *(GNSS denial estimator uncertainty'yi artificially reduce etmemelidir.)*

---

# 156. Recovery Request Acceptance (Recovery Request Kabulü)

Recovery must begin through an explicit recovery event or defined state-machine condition. *(Recovery explicit recovery event veya defined state-machine condition üzerinden başlamalıdır.)*

---

# 157. Recovery Fix Quality Acceptance (Recovery Fix Kalite Kabulü)

The first recovery GNSS fix must not automatically be accepted. *(İlk recovery GNSS fix otomatik olarak accepted edilmemelidir.)*

---

# 158. Recovery Pre-Correction Snapshot Acceptance (Recovery Pre-Correction Snapshot Kabulü)

The active estimator state must be saved before any recovery correction. *(Active estimator state herhangi bir recovery correction öncesinde saved edilmelidir.)*

---

# 159. Recovery Error Acceptance (Recovery Error Kabulü)

East, North, and horizontal recovery error must be calculated in the original denied-session ENU frame before correction. *(East, North ve horizontal recovery error correction öncesinde original denied-session ENU frame içerisinde calculated edilmelidir.)*

---

# 160. Recovery Relocalization Acceptance (Recovery Relocalization Kabulü)

Relocalization may occur only after pre-correction evidence has been preserved. *(Relocalization yalnızca pre-correction evidence preserved edildikten sonra gerçekleşebilir.)*

---

# 161. Historical Trajectory Acceptance (Historical Trajectory Kabulü)

Recovery must not retroactively alter historical denied trajectory points. *(Recovery historical denied trajectory point'lerini retroactively alter etmemelidir.)*

---

# 162. Recovery Timeout Acceptance (Recovery Timeout Kabulü)

Timeout must not force acceptance of a poor GNSS fix. *(Timeout poor GNSS fix'in acceptance'ını force etmemelidir.)*

---

# 163. Recovery Failure Acceptance (Recovery Failure Kabulü)

A failed recovery must be represented explicitly rather than silently returning to normal mode. *(Failed recovery silently normal mode'a dönmek yerine explicit şekilde represented edilmelidir.)*

---

# 164. Session Identity Acceptance (Session Kimliği Kabulü)

Every recorded session must have an immutable unique internal identifier. *(Recorded her session immutable unique internal identifier'a sahip olmalıdır.)*

---

# 165. Session Purpose Acceptance (Session Purpose Kabulü)

Every session must identify whether it is development, calibration, pilot, final benchmark, stress, or demo evidence. *(Her session development, calibration, pilot, final benchmark, stress veya demo evidence olup olmadığını identify etmelidir.)*

---

# 166. Session Lifecycle Acceptance (Session Lifecycle Kabulü)

Session lifecycle states must distinguish running, stopping, finalizing, completed, incomplete, and failed conditions where implemented. *(Session lifecycle state'leri implemented olduğu yerlerde running, stopping, finalizing, completed, incomplete ve failed condition'ları ayırmalıdır.)*

---

# 167. Interrupted Session Acceptance (Interrupted Session Kabulü)

A session interrupted by crash must not later appear as a clean completed session without integrity verification. *(Crash ile interrupted olan session integrity verification olmadan daha sonra clean completed session gibi görünmemelidir.)*

---

# 168. Manifest Acceptance (Manifest Kabulü)

Each formal session must produce a manifest that identifies build, configuration, route, timing, artifacts, and integrity state. *(Her formal session build, configuration, route, timing, artifact ve integrity state'i identify eden manifest üretmelidir.)*

---

# 169. Mandatory Evidence Stream Acceptance (Mandatory Evidence Stream Kabulü)

Required formal streams must be present for the metrics that depend on them. *(Required formal stream'ler onlara bağlı metric'ler için present olmalıdır.)*

---

# 170. Logging Drop Acceptance (Logging Drop Kabulü)

Mandatory benchmark streams target zero dropped records in valid formal sessions. *(Mandatory benchmark stream'leri valid formal session'larda zero dropped record hedefler.)*

---

# 171. Logging Drop Failure Acceptance (Logging Drop Failure Kabulü)

A mandatory-stream drop that prevents scientific reconstruction may invalidate the affected session. *(Scientific reconstruction'ı engelleyen mandatory-stream drop affected session'ı invalid hale getirebilir.)*

---

# 172. Writer Queue Acceptance (Writer Queue Kabulü)

Writer queues must remain bounded. *(Writer queue'lar bounded kalmalıdır.)*

---

# 173. Backpressure Acceptance (Backpressure Kabulü)

Artificially slowed storage must not create unbounded memory growth. *(Artificially slowed storage unbounded memory growth oluşturmamalıdır.)*

---

# 174. No Silent Writer Failure Acceptance (Sessiz Writer Failure Olmaması Kabulü)

Writer failure must create visible diagnostics and session-integrity consequences. *(Writer failure visible diagnostics ve session-integrity consequence oluşturmalıdır.)*

---

# 175. Storage Readiness Acceptance (Storage Readiness Kabulü)

Formal sessions must check writable storage before start. *(Formal session'lar start öncesinde writable storage check etmelidir.)*

---

# 176. Storage Capacity Acceptance (Storage Capacity Kabulü)

The final free-space requirement must be derived from measured logging volume and safety margin. *(Final free-space requirement measured logging volume ve safety margin'den derive edilmelidir.)*

---

# 177. Finalization Acceptance (Finalization Kabulü)

Stopping recording must not immediately mark a session complete before writers and integrity checks finish. *(Recording'i stop etmek writer ve integrity check'ler finish olmadan session'ı immediate complete işaretlememelidir.)*

---

# 178. Export Acceptance (Export Kabulü)

Exported evidence must preserve the session identity and expected artifact set. *(Exported evidence session identity ve expected artifact set'i preserve etmelidir.)*

---

# 179. Artifact Hash Acceptance (Artifact Hash Kabulü)

If hashes are enabled, modification of a finalized artifact must become detectable. *(Hash'ler enabled ise finalized artifact modification'ı detectable hale gelmelidir.)*

---

# 180. Replay Engine Acceptance (Replay Engine Kabulü)

The replay engine must reconstruct estimator inputs in timestamp order from stored session evidence. *(Replay engine stored session evidence'dan estimator input'larını timestamp order içerisinde reconstruct etmelidir.)*

---

# 181. Replay Determinism Acceptance (Replay Determinizm Kabulü)

Identical session evidence and configuration must produce identical or numerically equivalent output within frozen tolerance. *(Identical session evidence ve configuration frozen tolerance içerisinde identical veya numerically equivalent output üretmelidir.)*

---

# 182. Replay Configuration Acceptance (Replay Configuration Kabulü)

Replay must support the formal A-D comparison when required evidence exists. *(Required evidence mevcut olduğunda replay formal A-D comparison'ı support etmelidir.)*

---

# 183. Replay No Ground Truth Leakage Acceptance (Replay Ground Truth Sızıntısı Olmaması Kabulü)

Replay of denied configurations must enforce the same Ground Truth Firewall as live execution. *(Denied configuration replay'i live execution ile aynı Ground Truth Firewall'u enforce etmelidir.)*

---

# 184. Replay Parameter Identity Acceptance (Replay Parameter Kimliği Kabulü)

Replay output must identify the parameter and model versions used. *(Replay output kullanılan parameter ve model version'larını identify etmelidir.)*

---

# 185. Metric Pipeline Acceptance (Metrik Pipeline Kabulü)

The final Python metric pipeline must reproduce the mathematical definitions frozen in Page 35. *(Final Python metric pipeline Page 35'te frozen edilen mathematical definition'ları reproduce etmelidir.)*

---

# 186. Zero-Error Metric Test Acceptance (Zero-Error Metric Test Kabulü)

Identical estimator and reference trajectories must produce zero position error within numerical tolerance. *(Identical estimator ve reference trajectory'ler numerical tolerance içerisinde zero position error üretmelidir.)*

---

# 187. Constant Offset Metric Acceptance (Constant Offset Metric Kabulü)

A synthetic constant spatial offset must produce the analytically expected error. *(Synthetic constant spatial offset analytically expected error'ı üretmelidir.)*

---

# 188. RMSE Metric Acceptance (RMSE Metric Kabulü)

Synthetic error sequences with known RMSE must reproduce the expected RMSE. *(Known RMSE'ye sahip synthetic error sequence'leri expected RMSE'yi reproduce etmelidir.)*

---

# 189. Missing Reference Acceptance (Eksik Referans Kabulü)

Missing reference samples must be excluded rather than replaced with zero coordinates. *(Missing reference sample'lar zero coordinate ile replace edilmek yerine excluded edilmelidir.)*

---

# 190. Final Error Timing Acceptance (Final Error Timing Kabulü)

Final denied-navigation error must use the pre-correction state. *(Final denied-navigation error pre-correction state'i kullanmalıdır.)*

---

# 191. Post-Correction Leakage Metric Test (Post-Correction Leakage Metric Testi)

A regression test must prevent post-relocalization position from being used as final denied error. *(Regression test post-relocalization position'ın final denied error olarak kullanılmasını önlemelidir.)*

---

# 192. Session-Level Aggregation Acceptance (Session-Level Aggregation Kabulü)

Primary benchmark aggregation must compute metrics per session before cross-session aggregation. *(Primary benchmark aggregation cross-session aggregation öncesinde metric'leri session başına hesaplamalıdır.)*

---

# 193. No Long-Session Dominance Acceptance (Uzun Session Dominance Olmaması Kabulü)

A long session must not dominate the primary result solely because it contains more timestamp samples. *(Long session yalnızca daha fazla timestamp sample içerdiği için primary result'a dominate etmemelidir.)*

---

# 194. Matched Comparison Acceptance (Matched Comparison Kabulü)

A-D comparisons should use the same physical session when replay evidence permits. *(Replay evidence izin verdiğinde A-D comparison aynı physical session'ı kullanmalıdır.)*

---

# 195. Primary Baseline Acceptance (Primary Baseline Kabulü)

Configuration A must remain a reproducible PDR-only baseline throughout the final benchmark. *(Configuration A final benchmark boyunca reproducible PDR-only baseline olarak kalmalıdır.)*

---

# 196. Configuration B Acceptance (Configuration B Kabulü)

Configuration B must isolate the effect of improved heading without accidentally incorporating prohibited full-system features. *(Configuration B improved heading effect'ini isolate etmeli ve yanlışlıkla prohibited full-system feature'ları incorporate etmemelidir.)*

---

# 197. Configuration C Acceptance (Configuration C Kabulü)

Configuration C must evaluate ARCore-enhanced PDR according to the frozen ablation definition. *(Configuration C frozen ablation definition'a göre ARCore-enhanced PDR'ı evaluate etmelidir.)*

---

# 198. Configuration D Acceptance (Configuration D Kabulü)

Configuration D must represent the frozen full NAVGUARD configuration. *(Configuration D frozen full NAVGUARD configuration'ı represent etmelidir.)*

---

# 199. Configuration Identity Audit (Configuration Kimlik Audit'i)

All final configuration differences must be documented rather than inferred from code branches. *(Tüm final configuration difference'ları code branch'lerden inferred edilmek yerine documented olmalıdır.)*

---

# 200. Field Route Acceptance (Saha Rota Kabulü)

Final principal routes must be predefined and documented before benchmark collection. *(Final principal route'lar benchmark collection öncesinde predefined ve documented olmalıdır.)*

---

# 201. Principal Route Set Acceptance (Temel Rota Seti Kabulü)

The final principal route set must include straight, turn-heavy, and closed or near-closed geometry. *(Final principal route set straight, turn-heavy ve closed veya near-closed geometry içermelidir.)*

---

# 202. Route Repeat Acceptance (Rota Tekrar Kabulü)

The current target remains at least three valid physical repeats per principal route category where practical. *(Mevcut target uygulanabilir olduğunda principal route category başına en az üç valid physical repeat olarak kalır.)*

---

# 203. Phone Placement Acceptance (Telefon Placement Kabulü)

Final principal benchmark sessions must use the frozen controlled phone placement. *(Final principal benchmark session'ları frozen controlled phone placement kullanmalıdır.)*

---

# 204. Anchor-before-Denial Acceptance (Anchor-before-Denial Kabulü)

Every principal denied field session must begin from a valid accepted anchor. *(Her principal denied field session valid accepted anchor'dan başlamalıdır.)*

---

# 205. Explicit Denial Acceptance (Explicit Denial Kabulü)

The denial start must be explicit and timestamped. *(Denial start explicit ve timestamped olmalıdır.)*

---

# 206. Protected Reference Logging Acceptance (Protected Reference Logging Kabulü)

Evaluation Mode may log GNSS reference throughout denial while estimator access remains blocked. *(Evaluation Mode estimator access blocked kalırken denial boyunca GNSS reference loglayabilir.)*

---

# 207. Recovery Boundary Acceptance (Recovery Boundary Kabulü)

The recovery condition must be predefined according to the frozen route protocol. *(Recovery condition frozen route protocol'e göre predefined olmalıdır.)*

---

# 208. Field Session Integrity Acceptance (Field Session Integrity Kabulü)

Every final session must pass manifest, logging, timing, firewall, and route-integrity review before contributing to the required metric set or the project-level primary research comparison. *(Her final session gerekli metric set'ine veya project-level primary research comparison'a katkıda bulunmadan önce manifest, logging, timing, firewall ve route-integrity review'u geçmelidir.)*

---

# 209. Poor Result Acceptance (Kötü Sonuç Kabulü)

A scientifically valid poor-performing session must remain in the benchmark. *(Scientifically valid poor-performing session benchmark içerisinde kalmalıdır.)*

---

# 210. Session Exclusion Acceptance (Session Exclusion Kabulü)

A session may only be excluded through frozen predeclared integrity or reference-quality rules. *(Session yalnızca frozen predeclared integrity veya reference-quality rule'ları üzerinden excluded edilebilir.)*

---

# 211. Exclusion Reason Acceptance (Exclusion Reason Kabulü)

Every excluded final session must preserve an explicit reason. *(Excluded edilen her final session explicit reason preserve etmelidir.)*

---

# 212. No Result-Based Exclusion Acceptance (Result-Based Exclusion Olmaması Kabulü)

High position error alone is not a valid exclusion reason. *(High position error tek başına valid exclusion reason değildir.)*

---

# 213. Ground Truth Quality Acceptance (Ground Truth Kalite Kabulü)

The required position-metric set requires reference quality that satisfies the frozen inclusion policy. *(Required position-metric set frozen inclusion policy'yi sağlayan reference quality gerektirir.)*

---

# 214. Reference-Gap Acceptance (Reference-Gap Kabulü)

Large reference gaps must not be fabricated through arbitrary interpolation. *(Large reference gap'ler arbitrary interpolation üzerinden fabricate edilmemelidir.)*

---

# 215. Ground Truth Accuracy Claim Acceptance (Ground Truth Accuracy Claim Kabulü)

Ordinary smartphone GNSS must not be described as centimeter-accurate ground truth. *(Normal smartphone GNSS centimeter-accurate ground truth olarak tanımlanmamalıdır.)*

---

# 216. Required Position Metric Set Acceptance (Required Position Metric Set Kabulü)

For valid final sessions with usable reference, the evaluation pipeline must provide mean, median, RMSE, P95, and final pre-correction horizontal error. These values form the required position-metric set, but only aggregated matched-session median horizontal position error for Configuration D versus Configuration A is the project-level primary research metric. *(Usable reference'e sahip valid final session'lar için evaluation pipeline mean, median, RMSE, P95 ve final pre-correction horizontal error sağlamalıdır. Bu değerler required position-metric set'i oluşturur ancak yalnızca Configuration D ile Configuration A için aggregated matched-session median horizontal position error project-level primary research metric'tir.)*

---

# 217. Drift Metric Acceptance (Drift Metric Kabulü)

Drift per minute must be computed for valid denied intervals. *(Drift per minute valid denied interval'lar için computed edilmelidir.)*

---

# 218. Drift per Distance Acceptance (Mesafe Başına Drift Kabulü)

Drift per distance must be computed when reference travel distance is defensible. *(Reference travel distance defensible olduğunda drift per distance computed edilmelidir.)*

---

# 219. Closure Error Acceptance (Closure Error Kabulü)

Closed-route sessions should report closure error when the starting and ending reference geometry is defensible. *(Starting ve ending reference geometry defensible olduğunda closed-route session'lar closure error raporlamalıdır.)*

---

# 220. Heading Metric Acceptance (Heading Metric Kabulü)

Heading MAE or RMSE may only be reported when the reference heading is defensible. *(Heading MAE veya RMSE yalnızca reference heading defensible olduğunda raporlanabilir.)*

---

# 221. Step-Length Metric Acceptance (Step-Length Metric Kabulü)

Per-step step-length error must not be reported unless defensible per-step reference exists. *(Defensible per-step reference yoksa per-step step-length error raporlanmamalıdır.)*

---

# 222. Route-Average Label Acceptance (Route-Average Label Kabulü)

Route-average step-length labels must remain identified as route-average or segment-average rather than exact per-step truth. *(Route-average step-length label'ları exact per-step truth yerine route-average veya segment-average olarak identified kalmalıdır.)*

---

# 223. ARCore Availability Metric Acceptance (ARCore Availability Metric Kabulü)

ARCore-enabled final sessions should report tracking availability. *(ARCore-enabled final session'lar tracking availability raporlamalıdır.)*

---

# 224. Recovery Metric Acceptance (Recovery Metric Kabulü)

Recovery validation latency, relocalization latency, total recovery latency, and pre-correction recovery error should be recorded where applicable. *(Applicable olduğunda recovery validation latency, relocalization latency, total recovery latency ve pre-correction recovery error recorded edilmelidir.)*

---

# 225. Uncertainty Acceptance (Belirsizlik Kabulü)

The system must expose position uncertainty separately from position estimate. *(Sistem position uncertainty'yi position estimate'den ayrı expose etmelidir.)*

---

# 226. Covariance Validity Acceptance (Covariance Validity Kabulü)

Horizontal covariance must remain finite and numerically valid. *(Horizontal covariance finite ve numerically valid kalmalıdır.)*

---

# 227. Confidence Label Acceptance (Confidence Label Kabulü)

A user-facing formal probability such as `95%` must not be claimed unless empirical calibration justifies it. *(Empirical calibration justify etmedikçe `95%` gibi user-facing formal probability claim edilmemelidir.)*

---

# 228. NEES/NIS Acceptance (NEES/NIS Kabulü)

NEES and NIS may be reported as advanced diagnostics when assumptions and reference quality are adequate. *(Assumption'lar ve reference quality adequate olduğunda NEES ve NIS advanced diagnostic olarak raporlanabilir.)*

---

# 229. Performance Device Acceptance (Performans Cihaz Kabulü)

Formal performance measurements must be taken on the Xiaomi Redmi Note 9 Pro. *(Formal performance measurement'lar Xiaomi Redmi Note 9 Pro üzerinde alınmalıdır.)*

---

# 230. Debug-Only Performance Acceptance (Debug-Only Performans Kabulü)

Final performance conclusions must not rely solely on debug builds. *(Final performance conclusion'lar yalnızca debug build'lere dayanmamalıdır.)*

---

# 231. AI Latency Performance Acceptance (AI Latency Performans Kabulü)

AI median and P95 inference latency must be measured under isolated and full-stack conditions where feasible. *(Feasible olduğunda AI median ve P95 inference latency isolated ve full-stack condition'larda measured edilmelidir.)*

---

# 232. Memory Acceptance (Memory Kabulü)

Continuous operation must not show clearly unbounded memory growth. *(Continuous operation açıkça unbounded memory growth göstermemelidir.)*

---

# 233. Queue Acceptance (Queue Kabulü)

Sensor, AI, and writer queues must remain bounded. *(Sensor, AI ve writer queue'ları bounded kalmalıdır.)*

---

# 234. Long-Duration Stability Acceptance (Uzun Süreli Stabilite Kabulü)

At least one dedicated long-duration combined-stack test must complete without resource-driven crash or uncontrolled queue growth. *(En az bir dedicated long-duration combined-stack test resource-driven crash veya uncontrolled queue growth olmadan tamamlanmalıdır.)*

---

# 235. Battery Acceptance (Batarya Kabulü)

Battery consumption must be measured under controlled representative sessions. *(Battery consumption controlled representative session'lar altında measured edilmelidir.)*

---

# 236. Battery Threshold Acceptance (Batarya Threshold Kabulü)

The project will not invent a final battery threshold before physical evidence exists. *(Proje physical evidence mevcut olmadan final battery threshold uydurmayacaktır.)*

---

# 237. Thermal Acceptance (Termal Kabulü)

Longer full-stack sessions must be evaluated for thermal degradation and throttling effects. *(Longer full-stack session'lar thermal degradation ve throttling effect'leri açısından evaluate edilmelidir.)*

---

# 238. Thermal Integrity Acceptance (Termal Bütünlük Kabulü)

Thermal pressure must not silently disable mandatory logging or corrupt estimator integrity. *(Thermal pressure mandatory logging'i sessizce disable etmemeli veya estimator integrity'yi corrupt etmemelidir.)*

---

# 239. UI Responsiveness Acceptance (UI Responsiveness Kabulü)

Critical navigation controls must remain responsive under representative full-stack load. *(Critical navigation control'lar representative full-stack load altında responsive kalmalıdır.)*

---

# 240. UI Rate Separation Acceptance (UI Rate Ayrımı Kabulü)

UI refresh may be throttled independently without changing estimator execution or evidence. *(UI refresh estimator execution veya evidence'ı değiştirmeden independently throttle edilebilir.)*

---

# 241. Map Input Isolation Acceptance (Harita Input İzolasyonu Kabulü)

Map data must remain visualization-only and must not influence estimator state. *(Map data visualization-only kalmalı ve estimator state'i influence etmemelidir.)*

---

# 242. Permission Acceptance (Permission Kabulü)

Required permissions must be checked before enabling dependent features. *(Required permission'lar dependent feature'lar enabled edilmeden önce checked edilmelidir.)*

---

# 243. Camera Permission Fallback Acceptance (Camera Permission Fallback Kabulü)

Camera permission loss must disable ARCore while preserving valid PDR operation. *(Camera permission loss valid PDR operation'ı preserve ederken ARCore'u disable etmelidir.)*

---

# 244. Location Permission Acceptance (Location Permission Kabulü)

Formal GNSS anchor, Evaluation ground truth, and recovery workflows must not proceed when required precise location access is unavailable. *(Required precise location access unavailable olduğunda formal GNSS anchor, Evaluation ground truth ve recovery workflow'ları proceed etmemelidir.)*

---

# 245. Activity Recognition Acceptance (Activity Recognition Kabulü)

Loss of optional Activity Recognition permission must not disable the independent NAVGUARD step detector. *(Optional Activity Recognition permission kaybı independent NAVGUARD step detector'ı disable etmemelidir.)*

---

# 246. Fallback Event Acceptance (Fallback Event Kabulü)

Meaningful runtime fallback transitions must be logged with timestamp and reason. *(Meaningful runtime fallback transition'lar timestamp ve reason ile logged edilmelidir.)*

---

# 247. AI Fallback Acceptance (AI Fallback Kabulü)

AI failure must fall back to deterministic navigation. *(AI failure deterministic navigation'a fallback yapmalıdır.)*

---

# 248. ARCore Fallback Acceptance (ARCore Fallback Kabulü)

ARCore failure must fall back to PDR when PDR remains valid. *(PDR valid kaldığında ARCore failure PDR'a fallback yapmalıdır.)*

---

# 249. Step-Length Fallback Acceptance (Step-Length Fallback Kabulü)

The final fallback chain must operate in the frozen order. *(Final fallback chain frozen order içerisinde çalışmalıdır.)*

```text
Learned
→ Deterministic Variable
→ Calibrated Fixed
```

---

# 250. EKF Fallback Acceptance (EKF Fallback Kabulü)

Invalid EKF output must not destroy the independent PDR baseline. *(Invalid EKF output independent PDR baseline'ı destroy etmemelidir.)*

---

# 251. No-Heading Fallback Acceptance (No-Heading Fallback Kabulü)

When no defensible heading remains, the system must stop claiming reliable directional propagation. *(Defensible heading kalmadığında sistem reliable directional propagation claim etmeyi durdurmalıdır.)*

---

# 252. Unavailable-State Acceptance (Unavailable-State Kabulü)

If no safe navigation estimate remains, `UNRELIABLE` or `UNAVAILABLE` is an acceptable and preferred state over fabricated motion. *(Safe navigation estimate kalmadığında `UNRELIABLE` veya `UNAVAILABLE`, fabricated motion'a göre acceptable ve preferred state'tir.)*

---

# 253. Failure Injection Acceptance (Failure Injection Kabulü)

The final integration suite must deliberately test major fallback conditions. *(Final integration suite major fallback condition'ları deliberately test etmelidir.)*

---

# 254. Required Failure Injection Set (Gerekli Failure Injection Seti)

The required set should cover AI failure, ARCore loss, stale sensor input, bad recovery fix, logging delay, permission loss, and Ground Truth Firewall injection attempts. *(Required set AI failure, ARCore loss, stale sensor input, bad recovery fix, logging delay, permission loss ve Ground Truth Firewall injection attempt'lerini kapsamalıdır.)*

---

# 255. Fallback Determinism Acceptance (Fallback Determinizm Kabulü)

Repeated replay of identical injected failures must produce the same fallback sequence. *(Identical injected failure'ların repeated replay'i aynı fallback sequence'i üretmelidir.)*

---

# 256. Field Safety Acceptance (Saha Güvenlik Kabulü)

Formal field sessions may be aborted whenever pedestrian safety requires it. *(Formal field session'lar pedestrian safety gerektirdiğinde abort edilebilir.)*

---

# 257. Safety-over-Completion Acceptance (Güvenlik-over-Completion Kabulü)

A safe abort is not considered a project failure. *(Safe abort proje failure'ı olarak değerlendirilmez.)*

---

# 258. Pilot Acceptance (Pilot Kabulü)

Pilot sessions must confirm route practicality, GNSS reference usability, device placement, denial control, recovery control, and evidence completeness before final freeze. *(Pilot session'lar final freeze öncesinde route practicality, GNSS reference usability, device placement, denial control, recovery control ve evidence completeness'i doğrulamalıdır.)*

---

# 259. Benchmark Freeze Acceptance (Benchmark Freeze Kabulü)

The final benchmark build, models, parameters, routes, inclusion rules, and metric pipeline must be frozen before final benchmark collection. *(Final benchmark build, model, parameter, route, inclusion rule ve metric pipeline final benchmark collection öncesinde frozen edilmelidir.)*

---

# 260. Post-Freeze Tuning Acceptance (Post-Freeze Tuning Kabulü)

Final benchmark outcomes must not be used to retune the frozen estimator. *(Final benchmark outcome'ları frozen estimator'ı retune etmek için kullanılmamalıdır.)*

---

# 261. Material Build Change Acceptance (Material Build Change Kabulü)

A material estimator change after freeze must create a new benchmark build identity. *(Freeze sonrasındaki material estimator change new benchmark build identity oluşturmalıdır.)*

---

# 262. Benchmark Recollection Acceptance (Benchmark Recollection Kabulü)

Affected sessions must be recollected or clearly separated when a material estimator change occurs. *(Material estimator change gerçekleştiğinde affected session'lar recollected edilmeli veya clearly separated olmalıdır.)*

---

# 263. Primary Research Metric Acceptance (Primary Research Metric Kabulü)

The final report must compare Configuration D against Configuration A using aggregated matched-session median horizontal position error as the single project-level primary research metric. *(Final report Configuration D'yi Configuration A'ya karşı tek project-level primary research metric olarak aggregated matched-session median horizontal position error kullanarak karşılaştırmalıdır.)*

---

# 264. Primary Research Target (Primary Research Hedefi)

The predeclared primary research target is frozen as at least a `20%` reduction in aggregated matched-session median horizontal position error for Configuration D relative to Configuration A. It remains an unmeasured target until the final benchmark is completed. *(Predeclared primary research target Configuration D için Configuration A'ya göre aggregated matched-session median horizontal position error'da en az `%20` reduction olarak frozen'dır. Final benchmark tamamlanana kadar unmeasured target olarak kalır.)*

---

# 265. Primary Target Result Categories (Primary Target Sonuç Kategorileri)

The result must be reported honestly as target met, partial improvement, no measurable improvement, regression, or inconclusive. *(Sonuç dürüstçe target met, partial improvement, no measurable improvement, regression veya inconclusive olarak raporlanmalıdır.)*

---

# 266. Failure to Reach 20% Acceptance (20%'ye Ulaşamama Kabulü)

Failure to reach the `20%` research target does not by itself mean the software prototype is incomplete. *(`20%` research target'a ulaşamamak tek başına software prototype'ın incomplete olduğu anlamına gelmez.)*

It means the predefined research-success target was not met. *(Bu, predefined research-success target'ın karşılanmadığı anlamına gelir.)*

---

# 267. Software Completion vs Research Target (Software Tamamlanması ile Research Target)

Software Definition of Done and research-outcome success are separate acceptance dimensions. *(Software Definition of Done ve research-outcome success ayrı acceptance dimension'lardır.)*

---

# 268. Minimum Research Prototype Acceptance (Minimum Araştırma Prototipi Kabulü)

A minimum acceptable NAVGUARD research prototype must include the following core capabilities. *(Minimum acceptable NAVGUARD research prototype aşağıdaki core capability'leri içermelidir.)*

```text
Physical sensor acquisition
Common timing
GNSS anchor
Ground Truth Firewall
Software GNSS denial
Deterministic step detection
True-north heading
Deterministic step length
PDR
Motion Classification AI
Session logging
Replay
Recovery
Metric pipeline
Controlled field benchmark
```

---

# 269. Target Full-System Acceptance (Hedef Full-System Kabulü)

The target full system additionally includes quality-aware EKF fusion and validated ARCore relative tracking. *(Target full system ek olarak quality-aware EKF fusion ve validated ARCore relative tracking içerir.)*

---

# 270. Learned Step-Length Acceptance Role (Learned Step-Length Kabul Rolü)

Learned step length is retained only if evidence justifies it and is not mandatory for minimum completion. *(Learned step length yalnızca evidence justify ederse retained edilir ve minimum completion için mandatory değildir.)*

---

# 271. Advanced Uncertainty Acceptance Role (Advanced Uncertainty Kabul Rolü)

Formal NEES-style uncertainty analysis is a target enhancement rather than a minimum completion dependency. *(Formal NEES-style uncertainty analysis minimum completion dependency yerine target enhancement'tır.)*

---

# 272. Quantization Acceptance Role (Quantization Kabul Rolü)

Quantization is optional and should only be accepted when accuracy and runtime tradeoffs are favorable. *(Quantization optional'dır ve yalnızca accuracy ve runtime tradeoff'ları favorable olduğunda accepted edilmelidir.)*

---

# 273. Delegate Acceptance Role (Delegate Kabul Rolü)

Hardware acceleration delegates are optional and require measured target-device benefit. *(Hardware acceleration delegate'leri optional'dır ve measured target-device benefit gerektirir.)*

---

# 274. Cross-Device Acceptance Role (Cross-Device Kabul Rolü)

Cross-device support is optional for the initial project. *(Cross-device support initial project için optional'dır.)*

---

# 275. Documentation Acceptance (Dokümantasyon Kabulü)

The project documentation must describe the final implemented system rather than only the original design intent. *(Project documentation yalnızca original design intent'i değil final implemented system'i describe etmelidir.)*

---

# 276. Decision Log Acceptance (Decision Log Kabulü)

Material deviations from the design must be recorded in Page 43. *(Design'dan material deviation'lar Page 43 içerisinde recorded edilmelidir.)*

---

# 277. Result Documentation Acceptance (Sonuç Dokümantasyonu Kabulü)

Measured results must be inserted into Page 41 only after final benchmark evidence exists. *(Measured result'lar yalnızca final benchmark evidence mevcut olduktan sonra Page 41'e inserted edilmelidir.)*

---

# 278. Limitation Documentation Acceptance (Limitation Dokümantasyonu Kabulü)

Known limitations must be documented explicitly in Page 42. *(Known limitation'lar Page 42 içerisinde explicitly documented edilmelidir.)*

---

# 279. Reference Acceptance (Referans Kabulü)

Technical claims requiring external references should be supported in Page 44. *(External reference gerektiren technical claim'ler Page 44 içerisinde supported edilmelidir.)*

---

# 280. No Fabricated Results Acceptance (Uydurulmuş Sonuç Olmaması Kabulü)

Unmeasured metrics must remain `TBD`, unavailable, or explicitly pending. *(Unmeasured metric'ler `TBD`, unavailable veya explicitly pending kalmalıdır.)*

---

# 281. Final Evidence Package Acceptance (Final Evidence Package Kabulü)

The final project package should contain sufficient evidence to reproduce the benchmark conclusions. *(Final project package benchmark conclusion'larını reproduce etmek için sufficient evidence içermelidir.)*

---

# 282. Minimum Final Evidence Package (Minimum Final Evidence Package)

```text
Frozen source/build identity
Frozen configuration
Model artifact + hash
Session manifests
Raw sensor logs
Protected GNSS reference logs
Step events
Heading outputs
PDR outputs
Fused outputs when applicable
ARCore outputs when applicable
AI outputs
Recovery events
Integrity reports
Replay outputs
Metric tables
Final benchmark summary
```

---

# 283. Source Reproducibility Acceptance (Source Reproducibility Kabulü)

The source revision used for the final benchmark must remain identifiable. *(Final benchmark için kullanılan source revision identifiable kalmalıdır.)*

---

# 284. Model Reproducibility Acceptance (Model Reproducibility Kabulü)

The final AI model must remain associated with the dataset version and training configuration that produced it. *(Final AI model onu üreten dataset version ve training configuration ile associated kalmalıdır.)*

---

# 285. Replay Reproducibility Acceptance (Replay Reproducibility Kabulü)

A final benchmark session should be replayable without requiring hidden manually supplied parameters. *(Final benchmark session hidden manually supplied parameter gerektirmeden replayable olmalıdır.)*

---

# 286. Metric Reproducibility Acceptance (Metric Reproducibility Kabulü)

The same final replay outputs and metric configuration must reproduce the final reported values within numerical tolerance. *(Aynı final replay output'ları ve metric configuration final reported value'ları numerical tolerance içerisinde reproduce etmelidir.)*

---

# 287. Definition of Done — Level 1 (Definition of Done — Seviye 1)

Level 1 means the application skeleton and device integration work. *(Level 1 application skeleton ve device integration work anlamına gelir.)*

It is not sufficient for project completion. *(Project completion için sufficient değildir.)*

---

# 288. Definition of Done — Level 2 (Definition of Done — Seviye 2)

Level 2 means deterministic PDR works from a valid GNSS anchor during software denial. *(Level 2 deterministic PDR'ın valid GNSS anchor'dan software denial sırasında çalıştığı anlamına gelir.)*

It is still not sufficient for full project completion. *(Full project completion için yine sufficient değildir.)*

---

# 289. Definition of Done — Level 3 (Definition of Done — Seviye 3)

Level 3 means deterministic navigation is fully logged and replayable. *(Level 3 deterministic navigation'ın fully logged ve replayable olduğu anlamına gelir.)*

This is the minimum reproducible navigation baseline. *(Bu minimum reproducible navigation baseline'dır.)*

---

# 290. Definition of Done — Level 4 (Definition of Done — Seviye 4)

Level 4 means the mandatory Motion Classification AI is trained, evaluated, deployed on-device, and integrated through validated fallback behavior. *(Level 4 mandatory Motion Classification AI'ın trained, evaluated, on-device deployed ve validated fallback behavior üzerinden integrated olduğu anlamına gelir.)*

---

# 291. Definition of Done — Level 5 (Definition of Done — Seviye 5)

Level 5 means the full target architecture including EKF and ARCore is operational or every unavailable target enhancement has a documented limitation and fallback. *(Level 5 EKF ve ARCore dahil full target architecture'ın operational olduğu veya unavailable her target enhancement'ın documented limitation ve fallback'e sahip olduğu anlamına gelir.)*

---

# 292. Definition of Done — Level 6 (Definition of Done — Seviye 6)

Level 6 means pilot testing, failure injection, freeze, and final benchmark collection have completed with preserved integrity. *(Level 6 pilot testing, failure injection, freeze ve final benchmark collection'ın preserved integrity ile completed olduğu anlamına gelir.)*

---

# 293. Definition of Done — Level 7 (Definition of Done — Seviye 7)

Level 7 means final results, limitations, acceptance status, and reproducible evidence have been documented. *(Level 7 final result, limitation, acceptance status ve reproducible evidence'ın documented olduğu anlamına gelir.)*

---

# 294. Final Project Definition of Done (Final Proje Definition of Done)

NAVGUARD is considered complete only when Level 7 has been reached. *(NAVGUARD yalnızca Level 7'ye ulaşıldığında complete kabul edilir.)*

---

# 295. Mandatory Completion Gates (Zorunlu Tamamlama Gate'leri)

The following gates must pass for overall project completion. *(Aşağıdaki gate'ler overall project completion için pass etmelidir.)*

```text
GATE-01  Target device executable
GATE-02  Mandatory sensors verified
GATE-03  Common timing verified
GATE-04  GNSS anchor verified
GATE-05  Ground Truth Firewall verified
GATE-06  Deterministic PDR verified
GATE-07  Step detector verified
GATE-08  Heading verified
GATE-09  Deterministic step length verified
GATE-10  Motion AI verified
GATE-11  Logging verified
GATE-12  Replay verified
GATE-13  Recovery verified
GATE-14  Failure fallback verified
GATE-15  Pilot completed
GATE-16  Benchmark freeze completed
GATE-17  Final field benchmark completed
GATE-18  Final metrics reproduced
GATE-19  Limitations documented
GATE-20  Final evidence package verified
```

---

# 296. Critical Integrity Gates (Kritik Bütünlük Gate'leri)

Some gates are stricter than ordinary feature acceptance. *(Bazı gate'ler ordinary feature acceptance'tan daha strict'tir.)*

---

# 297. Critical Gate — Ground Truth Firewall (Kritik Gate — Ground Truth Firewall)

A Ground Truth Firewall failure prevents a valid final denied benchmark. *(Ground Truth Firewall failure valid final denied benchmark'ı önler.)*

---

# 298. Critical Gate — Recovery Ordering (Kritik Gate — Recovery Ordering)

Pre-correction recovery evidence must be preserved before any estimator correction. *(Pre-correction recovery evidence herhangi bir estimator correction öncesinde preserved edilmelidir.)*

---

# 299. Critical Gate — Benchmark Freeze (Kritik Gate — Benchmark Freeze)

Final benchmark tuning after the formal freeze is prohibited. *(Formal freeze sonrasında final benchmark tuning prohibited'dır.)*

---

# 300. Critical Gate — Evidence Integrity (Kritik Gate — Evidence Integrity)

The project cannot claim reproducible benchmark results if required session evidence cannot be reconstructed. *(Required session evidence reconstruct edilemiyorsa proje reproducible benchmark result claim edemez.)*

---

# 301. Critical Gate — Metric Integrity (Kritik Gate — Metric Integrity)

Final reported values must come from the frozen metric pipeline. *(Final reported value'lar frozen metric pipeline'dan gelmelidir.)*

---

# 302. Target Completion Gates (Hedef Tamamlama Gate'leri)

The following targets improve the final result but do not all individually determine software completion. *(Aşağıdaki target'lar final result'ı geliştirir ancak her biri individually software completion'ı belirlemez.)*

```text
TARGET-01  Motion Macro F1 ≥ 0.90
TARGET-02  Step count absolute error ≤ 5%
TARGET-03  Configuration D vs A aggregated matched-session median horizontal position error reduction ≥ 20%
TARGET-04  AI inference approximately < 50 ms
TARGET-05  ARCore contributes usable tracking
TARGET-06  Long-duration full-stack stability
```

---

# 303. Target Failure Interpretation (Target Failure Yorumu)

A target failure must be reported honestly but does not automatically invalidate unrelated completed subsystems. *(Target failure dürüstçe raporlanmalı ancak unrelated completed subsystem'leri otomatik olarak invalid hale getirmez.)*

---

# 304. Software PASS, Research Target FAIL Scenario (Software PASS, Research Target FAIL Senaryosu)

The system may satisfy the software Definition of Done while failing to demonstrate the predefined `20%` improvement target. *(Sistem predefined `20%` improvement target'ı demonstrate edemese bile software Definition of Done'u sağlayabilir.)*

That outcome must be reported as a valid negative or partial research result rather than hidden. *(Bu outcome hidden edilmek yerine valid negative veya partial research result olarak raporlanmalıdır.)*

---

# 305. AI Target FAIL Scenario (AI Target FAIL Senaryosu)

If Motion Classification fails the frozen Macro F1 target, the AI research target is not met. *(Motion Classification frozen Macro F1 target'ı fail ederse AI research target karşılanmamıştır.)*

The project must not falsely report the target as achieved. *(Proje target'ı achieved olarak falsely report etmemelidir.)*

---

# 306. ARCore Target FAIL Scenario (ARCore Target FAIL Senaryosu)

If ARCore cannot be validated reliably, it may remain disabled or diagnostic-only while PDR preserves the minimum navigation path. *(ARCore reliably validated edilemezse PDR minimum navigation path'i preserve ederken disabled veya diagnostic-only kalabilir.)*

---

# 307. Learned Step-Length FAIL Scenario (Learned Step-Length FAIL Senaryosu)

If learned step length fails to improve held-out performance, deterministic step length remains the accepted final implementation. *(Learned step length held-out performance'ı improve edemezse deterministic step length accepted final implementation olarak kalır.)*

---

# 308. Performance Target FAIL Scenario (Performans Target FAIL Senaryosu)

If full NAVGUARD creates excessive resource pressure, a documented reduced configuration may be necessary for practical operation. *(Full NAVGUARD excessive resource pressure oluşturursa practical operation için documented reduced configuration gerekli olabilir.)*

---

# 309. Benchmark Inconclusive Scenario (Benchmark Inconclusive Senaryosu)

If too few valid final sessions remain after frozen integrity exclusions, the research conclusion may be `INCONCLUSIVE`. *(Frozen integrity exclusion'larından sonra çok az valid final session kalırsa research conclusion `INCONCLUSIVE` olabilir.)*

---

# 310. No Forced Positive Conclusion (Zorla Pozitif Sonuç Olmaması)

The project does not require a positive research result to be technically and scientifically complete. *(Projenin technically ve scientifically complete olması için positive research result gerekli değildir.)*

It requires an honest, reproducible, correctly evaluated result. *(Dürüst, reproducible ve correctly evaluated result gerektirir.)*

---

# 311. Final Acceptance Review (Final Kabul Review)

The final acceptance review will inspect all mandatory gates, target outcomes, known limitations, and unresolved defects. *(Final acceptance review tüm mandatory gate'leri, target outcome'ları, known limitation'ları ve unresolved defect'leri inceleyecektir.)*

---

# 312. Defect Classification (Defect Sınıflandırması)

Remaining defects will be classified by severity. *(Remaining defect'ler severity'ye göre classified edilecektir.)*

```text
CRITICAL
MAJOR
MINOR
DOCUMENTATION
```

---

# 313. Critical Defect Acceptance Rule (Critical Defect Kabul Kuralı)

No unresolved critical defect may remain in the final benchmark build. *(Final benchmark build içerisinde unresolved critical defect kalamaz.)*

---

# 314. Major Defect Acceptance Rule (Major Defect Kabul Kuralı)

A major defect may require correction, scope reduction, or explicit `PASS_WITH_LIMITATION` handling before final completion. *(Major defect final completion öncesinde correction, scope reduction veya explicit `PASS_WITH_LIMITATION` handling gerektirebilir.)*

---

# 315. Minor Defect Acceptance Rule (Minor Defect Kabul Kuralı)

Minor issues may remain if they do not threaten estimator correctness, evidence integrity, or the primary research workflow. *(Estimator correctness, evidence integrity veya primary research workflow'u tehdit etmiyorsa minor issue'lar kalabilir.)*

---

# 316. Documentation Defect Acceptance Rule (Dokümantasyon Defect Kabul Kuralı)

Documentation inconsistencies must be corrected when they would misrepresent the implemented system or benchmark result. *(Implemented system veya benchmark result'ı misrepresent edecek documentation inconsistency'leri corrected edilmelidir.)*

---

# 317. Acceptance Review Inputs (Kabul Review Girdileri)

The final acceptance review will use the following evidence. *(Final acceptance review aşağıdaki evidence'ı kullanacaktır.)*

```text
Verification matrix
Automated test report
Device audit
Failure-injection report
Pilot report
Benchmark freeze record
Final session integrity table
A-D replay results
Metric tables
AI evaluation
Performance evaluation
Known limitations
Change log
```

---

# 318. Acceptance Review Outputs (Kabul Review Çıktıları)

The final acceptance review will produce a signed or versioned project acceptance summary. *(Final acceptance review signed veya versioned project acceptance summary üretecektir.)*

---

# 319. Candidate Acceptance Summary (Aday Kabul Özeti)

```text
ProjectAcceptanceSummary
- finalBuildId
- finalModelId
- finalAnalysisVersion
- mandatoryGatePassCount
- mandatoryGateFailCount
- targetResults
- criticalDefectsOpen
- limitations
- researchOutcome
- softwareDefinitionOfDone
- overallStatus
```

---

# 320. Overall Acceptance States (Genel Kabul Durumları)

The final project may receive one of the following overall states. *(Final project aşağıdaki overall state'lerden birini alabilir.)*

```text
ACCEPTED
ACCEPTED_WITH_LIMITATIONS
NOT_ACCEPTED
INCONCLUSIVE_RESEARCH_RESULT
```

---

# 321. ACCEPTED Meaning (ACCEPTED Anlamı)

`ACCEPTED` means all mandatory completion gates pass and no unresolved critical defect remains. *(`ACCEPTED`, tüm mandatory completion gate'lerin pass ettiği ve unresolved critical defect kalmadığı anlamına gelir.)*

---

# 322. ACCEPTED_WITH_LIMITATIONS Meaning (ACCEPTED_WITH_LIMITATIONS Anlamı)

`ACCEPTED_WITH_LIMITATIONS` means the mandatory research prototype is complete but one or more target enhancements remain limited. *(`ACCEPTED_WITH_LIMITATIONS`, mandatory research prototype'ın complete olduğu ancak bir veya daha fazla target enhancement'ın limited kaldığı anlamına gelir.)*

---

# 323. NOT_ACCEPTED Meaning (NOT_ACCEPTED Anlamı)

`NOT_ACCEPTED` means at least one mandatory critical completion gate remains failed. *(`NOT_ACCEPTED`, en az bir mandatory critical completion gate'in failed kaldığı anlamına gelir.)*

---

# 324. INCONCLUSIVE_RESEARCH_RESULT Meaning (INCONCLUSIVE_RESEARCH_RESULT Anlamı)

`INCONCLUSIVE_RESEARCH_RESULT` may coexist with a technically accepted prototype when the final field evidence is insufficient for the primary research claim. *(`INCONCLUSIVE_RESEARCH_RESULT`, final field evidence primary research claim için insufficient olduğunda technically accepted prototype ile coexist edebilir.)*

---

# 325. Final Software DoD Checklist (Final Software DoD Checklist)

The software Definition of Done requires the following conditions. *(Software Definition of Done aşağıdaki condition'ları gerektirir.)*

```text
[ ] Builds and runs on Redmi Note 9 Pro
[ ] Mandatory sensors verified
[ ] Timing verified
[ ] Coordinate math verified
[ ] GNSS anchor verified
[ ] Ground Truth Firewall verified
[ ] Step detector verified
[ ] Heading verified
[ ] Deterministic step length verified
[ ] PDR verified
[ ] Motion AI deployed and evaluated
[ ] Session logging verified
[ ] Replay deterministic
[ ] EKF verified if retained
[ ] ARCore verified if retained
[ ] Recovery verified
[ ] Fallbacks verified
[ ] Failure injection completed
[ ] Performance qualification completed
[ ] Final build frozen
```

---

# 326. Final Research DoD Checklist (Final Research DoD Checklist)

The research Definition of Done requires the following conditions. *(Research Definition of Done aşağıdaki condition'ları gerektirir.)*

```text
[ ] Pilot routes validated
[ ] Final routes frozen
[ ] Final inclusion policy frozen
[ ] Final metric pipeline frozen
[ ] Final benchmark sessions collected
[ ] Ground truth integrity checked
[ ] Valid sessions identified
[ ] A-D matched replay completed
[ ] Required position metrics calculated
[ ] Project-level primary research comparison calculated
[ ] AI metrics calculated
[ ] Step metrics calculated
[ ] Recovery metrics calculated
[ ] Performance metrics summarized
[ ] Limitations documented
[ ] Research outcome classified
```

---

# 327. Final Evidence DoD Checklist (Final Evidence DoD Checklist)

The evidence Definition of Done requires the following conditions. *(Evidence Definition of Done aşağıdaki condition'ları gerektirir.)*

```text
[ ] Build identity preserved
[ ] Model hashes preserved
[ ] Session manifests preserved
[ ] Raw logs preserved
[ ] Ground truth logs preserved
[ ] Navigation outputs preserved
[ ] Integrity reports preserved
[ ] Replay outputs preserved
[ ] Metric outputs preserved
[ ] Change log updated
[ ] Final report traceability verified
```

---

# 328. Final Documentation DoD Checklist (Final Dokümantasyon DoD Checklist)

The documentation Definition of Done requires the following conditions. *(Documentation Definition of Done aşağıdaki condition'ları gerektirir.)*

```text
[ ] Final architecture matches implementation
[ ] Final decisions recorded
[ ] Final results inserted
[ ] Limitations inserted
[ ] Future work documented
[ ] References completed
[ ] Demo flow documented
[ ] Verification matrix completed
```

---

# 329. Final Demo DoD Checklist (Final Demo DoD Checklist)

The demonstration Definition of Done requires the following conditions. *(Demonstration Definition of Done aşağıdaki condition'ları gerektirir.)*

```text
[ ] Safe demo route selected
[ ] Readiness screen works
[ ] Anchor acquisition works
[ ] Denial transition works
[ ] Estimated route visible
[ ] Quality/uncertainty visible
[ ] Recovery works
[ ] Demo does not reveal protected ground truth during denial
[ ] Session evidence saved
```

---

# 330. Demonstration Is Not Benchmark Acceptance (Demonstration Benchmark Kabulü Değildir)

Passing the demo checklist does not replace the research benchmark checklist. *(Demo checklist'i pass etmek research benchmark checklist'inin yerini almaz.)*

---

# 331. Final Gate Ordering (Final Gate Sıralaması)

Final acceptance will follow a strict order. *(Final acceptance strict order izleyecektir.)*

```text
TECHNICAL INTEGRITY
        ↓
GROUND TRUTH INTEGRITY
        ↓
REPLAY INTEGRITY
        ↓
FIELD SESSION VALIDITY
        ↓
METRIC VALIDITY
        ↓
RESEARCH OUTCOME
        ↓
FINAL DOCUMENTATION
```

---

# 332. No Benchmark Before Technical Integrity (Technical Integrity Öncesi Benchmark Olmaması)

A benchmark collected from a technically invalid build is not authoritative evidence. *(Technically invalid build'den collected benchmark authoritative evidence değildir.)*

---

# 333. No Research Claim Before Ground Truth Integrity (Ground Truth Integrity Öncesi Research Claim Olmaması)

A denied-navigation research claim cannot be accepted when protected GNSS leakage is unresolved. *(Protected GNSS leakage unresolved olduğunda denied-navigation research claim accepted edilemez.)*

---

# 334. No Final Number Before Metric Integrity (Metric Integrity Öncesi Final Number Olmaması)

Final result numbers cannot be accepted until metric unit tests and analysis-version identity pass. *(Metric unit test'leri ve analysis-version identity pass etmeden final result number'lar accepted edilemez.)*

---

# 335. No Final Report Before Limitation Review (Limitation Review Öncesi Final Report Olmaması)

The final report must not omit material known limitations. *(Final report material known limitation'ları omit etmemelidir.)*

---

# 336. Verification Test ID Structure (Verification Test ID Yapısı)

Verification IDs will use subsystem prefixes where useful. *(Verification ID'leri kullanışlı olduğunda subsystem prefix kullanacaktır.)*

```text
VER-DEV
VER-SEN
VER-TIM
VER-COORD
VER-GNSS
VER-GTF
VER-STEP
VER-LEN
VER-HDG
VER-AI
VER-ARC
VER-QLT
VER-EKF
VER-REC
VER-STO
VER-RPL
VER-MET
VER-PERF
VER-FLD
VER-RES
```

---

# 337. Critical Verification Test Set (Kritik Verification Test Seti)

The following tests form the minimum critical verification suite. *(Aşağıdaki testler minimum critical verification suite'i oluşturur.)*

```text
VER-GTF-001  Protected GNSS blocked during denial
VER-GTF-002  Ground truth mutation does not alter denied estimator
VER-STEP-001 Deterministic step replay
VER-HDG-001  Cardinal orientation behavior
VER-COORD-001 ENU round-trip
VER-PDR-001  Cardinal step propagation
VER-AI-001   Python/Android preprocessing parity
VER-AI-002   LiteRT output parity
VER-ARC-001  PAUSED rejected
VER-EKF-001  Finite covariance
VER-EKF-002  Circular heading update
VER-REC-001  Pre-correction snapshot
VER-REC-002  Historical trajectory immutable
VER-STO-001  Interrupted session remains incomplete
VER-RPL-001  Replay determinism
VER-MET-001  Final error uses pre-correction state
VER-FLD-001  Final route protocol integrity
```

---

# 338. Final Benchmark Gate Matrix (Final Benchmark Gate Matrisi)

| Gate (Gate)                                     | Required Before Final Benchmark? (Final Benchmark Öncesi Gerekli mi?) | Failure Effect (Failure Etkisi)                   |
| ----------------------------------------------- | --------------------------------------------------------------------- | ------------------------------------------------- |
| Device Audit *(Cihaz Audit)*                    | Yes *(Evet)*                                                          | Benchmark blocked *(Benchmark blocked)*           |
| Ground Truth Firewall *(Ground Truth Firewall)* | Yes *(Evet)*                                                          | Benchmark invalid *(Benchmark invalid)*           |
| Replay Determinism *(Replay Determinizmi)*      | Yes *(Evet)*                                                          | A-D comparison invalid *(A-D comparison invalid)* |
| Recovery Ordering *(Recovery Sıralaması)*       | Yes *(Evet)*                                                          | Final error invalid *(Final error invalid)*       |
| Logging Integrity *(Logging Bütünlüğü)*         | Yes *(Evet)*                                                          | Evidence incomplete *(Evidence incomplete)*       |
| AI Target ≥0.90 *(AI Hedefi ≥0.90)*             | No, target *(Hayır, target)*                                          | AI target not met *(AI target karşılanmaz)*       |
| ARCore Validated *(ARCore Validated)*           | Target *(Hedef)*                                                      | PDR fallback *(PDR fallback)*                     |
| Learned Step Length *(Learned Step Length)*     | No *(Hayır)*                                                          | Deterministic fallback *(Deterministic fallback)* |

---

# 339. Final Acceptance Matrix (Final Kabul Matrisi)

| Area (Alan)                                             |                 Mandatory? (Zorunlu mu?) | Acceptance (Kabul)                                            |
| ------------------------------------------------------- | ---------------------------------------: | ------------------------------------------------------------- |
| Sensor Acquisition *(Sensör Acquisition)*               |                             Yes *(Evet)* | PASS required *(PASS gerekli)*                                |
| Timing *(Timing)*                                       |                             Yes *(Evet)* | PASS required *(PASS gerekli)*                                |
| GNSS Anchor *(GNSS Anchor)*                             |                             Yes *(Evet)* | PASS required *(PASS gerekli)*                                |
| Ground Truth Firewall *(Ground Truth Firewall)*         |                             Yes *(Evet)* | PASS required *(PASS gerekli)*                                |
| Step Detection *(Step Detection)*                       |                             Yes *(Evet)* | PASS required *(PASS gerekli)*                                |
| Heading *(Heading)*                                     |                             Yes *(Evet)* | PASS required *(PASS gerekli)*                                |
| Deterministic Step Length *(Deterministic Step Length)* |                             Yes *(Evet)* | PASS required *(PASS gerekli)*                                |
| PDR *(PDR)*                                             |                             Yes *(Evet)* | PASS required *(PASS gerekli)*                                |
| Motion AI *(Motion AI)*                                 |                             Yes *(Evet)* | Functional PASS required *(Functional PASS gerekli)*          |
| Motion AI ≥0.90 *(Motion AI ≥0.90)*                     |                         Target *(Hedef)* | Measured outcome *(Measured outcome)*                         |
| ARCore *(ARCore)*                                       |                         Target *(Hedef)* | PASS or documented fallback *(PASS veya documented fallback)* |
| Learned Step Length *(Learned Step Length)*             |   Optional/Target *(İsteğe bağlı/Hedef)* | Evidence-based retain/reject *(Evidence-based retain/reject)* |
| EKF *(EKF)*                                             | Target Full System *(Hedef Full System)* | PASS if retained *(Retained ise PASS)*                        |
| Logging *(Logging)*                                     |                             Yes *(Evet)* | PASS required *(PASS gerekli)*                                |
| Replay *(Replay)*                                       |                             Yes *(Evet)* | PASS required *(PASS gerekli)*                                |
| Recovery *(Recovery)*                                   |                             Yes *(Evet)* | PASS required *(PASS gerekli)*                                |
| Field Benchmark *(Field Benchmark)*                     |                             Yes *(Evet)* | Completed and valid *(Tamamlanmış ve valid)*                  |
| ≥20% Improvement *(≥20% İyileştirme)*                   |      Research Target *(Research Hedefi)* | Measured outcome *(Measured outcome)*                         |

---

# 340. Definition of Done Principle (Definition of Done İlkesi)

NAVGUARD is done when the complete research process is reproducible, not when the code stops changing. *(NAVGUARD kod değişmeyi durdurduğunda değil complete research process reproducible olduğunda done kabul edilir.)*

---

# 341. Final Acceptance Principle (Final Kabul İlkesi)

A technically complete prototype may produce a positive, partial, negative, or inconclusive research result and still be scientifically valuable when the evaluation was honest and reproducible. *(Technically complete prototype evaluation dürüst ve reproducible olduğunda positive, partial, negative veya inconclusive research result üretebilir ve yine de scientifically valuable olabilir.)*

---

# 342. Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kararlar)

NAVGUARD completion will be based on explicit evidence-backed verification rather than demonstration success alone. *(NAVGUARD completion yalnızca demonstration success yerine explicit evidence-backed verification'a dayanacaktır.)*

---

# 343. Acceptance-State Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Acceptance-State Kararları)

Formal verification states are `NOT_TESTED`, `IN_PROGRESS`, `PASS`, `PASS_WITH_LIMITATION`, `FAIL`, `BLOCKED`, and `NOT_APPLICABLE`. *(Formal verification state'leri `NOT_TESTED`, `IN_PROGRESS`, `PASS`, `PASS_WITH_LIMITATION`, `FAIL`, `BLOCKED` ve `NOT_APPLICABLE` olarak belirlenmiştir.)*

---

# 344. Requirement Criticality Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Requirement Kritiklik Kararları)

Requirements will be classified as `MANDATORY`, `TARGET`, or `OPTIONAL`. *(Requirement'lar `MANDATORY`, `TARGET` veya `OPTIONAL` olarak classified edilecektir.)*

---

# 345. Ground Truth Firewall Acceptance Frozen by This Document (Bu Dokümanla Sabitlenen Ground Truth Firewall Kabulü)

Every valid denied benchmark interval requires `unauthorizedGnssEstimatorUpdateCount = 0`. *(Her valid denied benchmark interval `unauthorizedGnssEstimatorUpdateCount = 0` gerektirir.)*

---

# 346. Step Detection Acceptance Frozen by This Document (Bu Dokümanla Sabitlenen Step Detection Kabulü)

Controlled step-count absolute percentage error target remains `≤5%`. *(Controlled step-count absolute percentage error target `≤5%` olarak kalır.)*

---

# 347. Motion AI Acceptance Frozen by This Document (Bu Dokümanla Sabitlenen Motion AI Kabulü)

Motion Classification remains mandatory and the provisional held-out Macro F1 target remains `≥0.90`. *(Motion Classification mandatory kalır ve geçici held-out Macro F1 target `≥0.90` olarak kalır.)*

---

# 348. ARCore Acceptance Frozen by This Document (Bu Dokümanla Sabitlenen ARCore Kabulü)

ARCore remains a target enhancement with mandatory PDR fallback. *(ARCore mandatory PDR fallback'e sahip target enhancement olarak kalır.)*

---

# 349. Learned Step-Length Acceptance Frozen by This Document (Bu Dokümanla Sabitlenen Learned Step-Length Kabulü)

Learned step length is not required for minimum completion and is retained only with measured benefit. *(Learned step length minimum completion için required değildir ve yalnızca measured benefit ile retained edilir.)*

---

# 350. EKF Acceptance Frozen by This Document (Bu Dokümanla Sabitlenen EKF Kabulü)

The formal initial EKF state remains `[E,N,ψ]`, and independent PDR must remain preserved. *(Formal initial EKF state `[E,N,ψ]` olarak kalır ve independent PDR preserved kalmalıdır.)*

---

# 351. Recovery Acceptance Frozen by This Document (Bu Dokümanla Sabitlenen Recovery Kabulü)

Pre-correction state and error must be preserved before relocalization. *(Pre-correction state ve error relocalization öncesinde preserved edilmelidir.)*

---

# 352. Historical Integrity Acceptance Frozen by This Document (Bu Dokümanla Sabitlenen Historical Integrity Kabulü)

Recovery must not rewrite the historical denied trajectory. *(Recovery historical denied trajectory'yi rewrite etmemelidir.)*

---

# 353. Replay Acceptance Frozen by This Document (Bu Dokümanla Sabitlenen Replay Kabulü)

Replay determinism is mandatory for final A-D comparison. *(Replay determinism final A-D comparison için mandatory'dir.)*

---

# 354. Benchmark Acceptance Frozen by This Document (Bu Dokümanla Sabitlenen Benchmark Kabulü)

Final benchmark collection may only begin after build, model, route, inclusion, and metric freeze. *(Final benchmark collection yalnızca build, model, route, inclusion ve metric freeze sonrasında başlayabilir.)*

---

# 355. Research Target Acceptance Frozen by This Document (Bu Dokümanla Sabitlenen Research Target Kabulü)

The predeclared primary research target is frozen as at least a `20%` reduction in aggregated matched-session median horizontal position error for Configuration D relative to Configuration A. It remains unmeasured until the final benchmark is completed. *(Predeclared primary research target Configuration D için Configuration A'ya göre aggregated matched-session median horizontal position error'da en az `%20` reduction olarak frozen'dır. Final benchmark tamamlanana kadar unmeasured kalır.)*

---

# 356. Software vs Research Acceptance Frozen by This Document (Bu Dokümanla Sabitlenen Software vs Research Kabulü)

Software completion and research-target achievement are formally separate outcomes. *(Software completion ve research-target achievement formal olarak ayrı outcome'lardır.)*

---

# 357. Final Project Acceptance Frozen by This Document (Bu Dokümanla Sabitlenen Final Proje Kabulü)

No unresolved critical integrity defect may remain for the project to be accepted. *(Projenin accepted olması için unresolved critical integrity defect kalamaz.)*

---

# 358. Final Definition of Done Statement (Nihai Definition of Done Bildirimi)

**NAVGUARD will not be considered complete because a single live route succeeds; completion requires verified sensor acquisition, validated timing, correct coordinate mathematics, controlled GNSS anchoring, a proven Ground Truth Firewall, deterministic step detection, defensible true-north heading, deterministic step-length fallback, reproducible PDR, mandatory Motion Classification, evidence logging, replay, controlled recovery, fallback validation, field experiments, benchmark analysis, and traceable final documentation.** *(NAVGUARD tek live route başarılı olduğu için complete kabul edilmeyecek; completion verified sensor acquisition, validated timing, doğru coordinate mathematics, controlled GNSS anchoring, proven Ground Truth Firewall, deterministic step detection, defensible true-north heading, deterministic step-length fallback, reproducible PDR, mandatory Motion Classification, evidence logging, replay, controlled recovery, fallback validation, field experiment'ler, benchmark analysis ve traceable final documentation gerektirecektir.)*

**Mandatory requirements will require evidence-backed `PASS`, while target enhancements such as validated ARCore, learned step length, advanced uncertainty analysis, and optimization features may finish with documented limitations when the minimum research architecture remains scientifically valid.** *(Mandatory requirement'lar evidence-backed `PASS` gerektirirken validated ARCore, learned step length, advanced uncertainty analysis ve optimization feature'ları gibi target enhancement'lar minimum research architecture scientifically valid kaldığında documented limitation ile tamamlanabilir.)*

**The Ground Truth Firewall is a critical non-negotiable acceptance gate: every valid denied benchmark interval must preserve exactly zero unauthorized GNSS estimator updates, and any demonstrated leakage invalidates the affected interval regardless of the resulting navigation accuracy.** *(Ground Truth Firewall critical ve non-negotiable acceptance gate'tir; her valid denied benchmark interval exactly zero unauthorized GNSS estimator update preserve etmeli ve demonstrated herhangi bir leakage resulting navigation accuracy'den bağımsız olarak affected interval'ı invalid hale getirmelidir.)*

**The system must preserve an independent deterministic PDR path even when AI, ARCore, or EKF are active, and failure of optional or advanced components must trigger explicit fallback rather than crash, silent corruption, or fabricated motion.** *(Sistem AI, ARCore veya EKF active olsa bile independent deterministic PDR path'i preserve etmeli ve optional veya advanced component failure'ı crash, silent corruption veya fabricated motion yerine explicit fallback tetiklemelidir.)*

**Final benchmark acceptance requires a frozen build, frozen models, frozen routes, frozen inclusion rules, frozen metric logic, valid session evidence, matched A-D replay, and honest reporting of the predefined research outcome without post-hoc tuning or result-based session exclusion.** *(Final benchmark acceptance frozen build, frozen model'ler, frozen route'lar, frozen inclusion rule'ları, frozen metric logic, valid session evidence, matched A-D replay ve post-hoc tuning veya result-based session exclusion olmadan predefined research outcome'ın dürüstçe raporlanmasını gerektirir.)*

**The final software Definition of Done is intentionally separate from the predeclared `20%` primary research target: NAVGUARD can be technically complete even if it does not achieve that target, provided the system, evidence, evaluation, limitations, and resulting negative or partial research conclusion are all valid and reproducible.** *(Final software Definition of Done predeclared `%20` primary research target'tan bilinçli olarak ayrıdır; NAVGUARD bu target'ı karşılamasa bile system, evidence, evaluation, limitation ve resulting negative veya partial research conclusion valid ve reproducible ise technically complete olabilir.)*

**The final project will therefore be accepted only when another reviewer can trace the implemented behavior from source and model identity through session evidence, replay configuration, metric pipeline, acceptance matrix, and final research conclusion without relying on undocumented assumptions or demonstration-only claims.** *(Bu nedenle final proje yalnızca başka bir reviewer implemented behavior'ı source ve model identity'den session evidence, replay configuration, metric pipeline, acceptance matrix ve final research conclusion'a kadar undocumented assumption veya demonstration-only claim'e dayanmadan trace edebildiğinde accepted edilecektir.)*

---

# 359. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development Verification, Acceptance Criteria & Definition of Done Completed *(Doküman Durumu: Geliştirme Öncesi Verification, Acceptance Criteria ve Definition of Done Tamamlandı)*

**Verification Philosophy:** Evidence-Backed *(Verification Felsefesi: Evidence-Backed)*

**Demo Alone Equals Completion:** No *(Demo Tek Başına Completion Demektir: Hayır)*

**Formal Acceptance States:** `NOT_TESTED / IN_PROGRESS / PASS / PASS_WITH_LIMITATION / FAIL / BLOCKED / NOT_APPLICABLE` *(Formal Acceptance State'leri: `NOT_TESTED / IN_PROGRESS / PASS / PASS_WITH_LIMITATION / FAIL / BLOCKED / NOT_APPLICABLE`)*

**Requirement Criticalities:** `MANDATORY / TARGET / OPTIONAL` *(Requirement Kritiklikleri: `MANDATORY / TARGET / OPTIONAL`)*

**Mandatory Requirements Need Evidence:** Yes *(Mandatory Requirement'lar Evidence Gerektirir: Evet)*

**Mandatory Sensors:** Accelerometer + Gyroscope + Magnetometer *(Mandatory Sensörler: Accelerometer + Gyroscope + Magnetometer)*

**Common Monotonic Timing:** Mandatory *(Common Monotonic Timing: Zorunlu)*

**ENU Coordinate Convention:** Mandatory *(ENU Coordinate Convention: Zorunlu)*

**True-North Clockwise Heading:** Mandatory *(True-North Clockwise Heading: Zorunlu)*

**GNSS First-Fix Auto-Anchor:** Forbidden *(GNSS First-Fix Auto-Anchor: Yasak)*

**Ground Truth Firewall:** Critical Mandatory Gate *(Ground Truth Firewall: Critical Mandatory Gate)*

**Required Unauthorized GNSS Update Count:** `0` *(Gerekli Unauthorized GNSS Update Count: `0`)*

**Ground Truth Mutation Must Affect Denied Estimator:** No *(Ground Truth Mutation Denied Estimator'ı Etkilemeli mi: Hayır)*

**Deterministic Step Detection:** Mandatory *(Deterministic Step Detection: Zorunlu)*

**Controlled Step Count Target:** `≤5%` Absolute Percentage Error *(Controlled Step Count Hedefi: `≤5%` Absolute Percentage Error)*

**Deterministic Step-Length Fallback:** Mandatory *(Deterministic Step-Length Fallback: Zorunlu)*

**Learned Step Length:** Optional / Evidence-Gated *(Learned Step Length: İsteğe Bağlı / Evidence-Gated)*

**Motion Classification:** Mandatory *(Motion Classification: Zorunlu)*

**Motion Classes:** `STATIONARY / WALKING / RUNNING / TURNING` *(Motion Class'ları: `STATIONARY / WALKING / RUNNING / TURNING`)*

**Motion AI Primary Metric:** Macro F1 *(Motion AI Primary Metric: Macro F1)*

**Motion AI Provisional Target:** `≥0.90` *(Motion AI Geçici Hedefi: `≥0.90`)*

**AI Session-Wise Split:** Mandatory *(AI Session-Wise Split: Zorunlu)*

**Python / Android Preprocessing Parity:** Mandatory *(Python / Android Preprocessing Parity: Zorunlu)*

**On-Device AI Output Parity:** Mandatory *(On-Device AI Output Parity: Zorunlu)*

**AI Shadow Mode Before Navigation Influence:** Mandatory *(Navigation Influence Öncesi AI Shadow Mode: Zorunlu)*

**AI Failure Fallback:** Deterministic Navigation *(AI Failure Fallback: Deterministic Navigation)*

**AI Provisional Latency Target:** Approximately `<50 ms` *(AI Geçici Latency Hedefi: Yaklaşık `<50 ms`)*

**ARCore:** Target Enhancement *(ARCore: Target Enhancement)*

**ARCore Valid Fusion State:** `TRACKING` Only *(ARCore Valid Fusion State: Yalnızca `TRACKING`)*

**ARCore `PAUSED`:** Rejected *(ARCore `PAUSED`: Reddedilir)*

**ARCore Loss Fallback:** PDR *(ARCore Loss Fallback: PDR)*

**ARCore Axis Hardcoding:** Forbidden *(ARCore Axis Hardcoding: Yasak)*

**Unvalidated ARCore-to-ENU Fusion:** Forbidden *(Unvalidated ARCore-to-ENU Fusion: Yasak)*

**Quality Engine:** Mandatory for Full Fusion *(Quality Engine: Full Fusion İçin Zorunlu)*

**Hard Invalid Measurements:** Rejected Before Fusion *(Hard Invalid Measurement'lar: Fusion Öncesi Reddedilir)*

**Formal EKF Initial State:** `[E,N,ψ]` *(Formal EKF Initial State: `[E,N,ψ]`)*

**Independent PDR During EKF:** Preserved *(EKF Sırasında Independent PDR: Korunur)*

**Joseph Covariance Update:** Preferred Formal Implementation *(Joseph Covariance Update: Tercih Edilen Formal Implementation)*

**Recovery First Fix Auto-Accept:** Forbidden *(Recovery First Fix Auto-Accept: Yasak)*

**Pre-Correction Recovery Snapshot:** Mandatory *(Pre-Correction Recovery Snapshot: Zorunlu)*

**Historical Denied Trajectory Rewrite:** Forbidden *(Historical Denied Trajectory Rewrite: Yasak)*

**Session Identity:** Mandatory *(Session Identity: Zorunlu)*

**Session Purpose Classification:** Mandatory *(Session Purpose Classification: Zorunlu)*

**Interrupted Session Auto-Complete:** Forbidden *(Interrupted Session Auto-Complete: Yasak)*

**Mandatory Evidence Logging:** Mandatory *(Mandatory Evidence Logging: Zorunlu)*

**Writer Queues:** Bounded *(Writer Queue'ları: Bounded)*

**Replay:** Mandatory *(Replay: Zorunlu)*

**Replay Determinism:** Mandatory *(Replay Determinizmi: Zorunlu)*

**Final A-D Comparison:** Matched Replay Preferred *(Final A-D Comparison: Matched Replay Tercih Edilir)*

**Final Error:** Pre-Correction *(Final Error: Pre-Correction)*

**Post-Correction Final Error:** Forbidden *(Post-Correction Final Error: Yasak)*

**Primary Benchmark Aggregation:** Session-Level First *(Primary Benchmark Aggregation: Önce Session-Level)*

**Primary Research Comparison:** Configuration A vs Configuration D *(Primary Research Comparison: Configuration A vs Configuration D)*

**Predeclared Frozen Primary Research Target:** `≥20%` Aggregated Matched-Session Median Horizontal Position Error Reduction, Configuration D vs Configuration A *(Önceden Belirlenmiş Frozen Primary Research Hedefi: Configuration D vs Configuration A için `≥20%` Aggregated Matched-Session Median Horizontal Position Error Azalması)*

**Failure to Achieve 20% Means Software Incomplete:** No *(20%'ye Ulaşamamak Software Incomplete Demektir: Hayır)*

**Failure to Achieve 20% Means Research Target Not Met:** Yes *(20%'ye Ulaşamamak Research Target Karşılanmadı Demektir: Evet)*

**Valid Poor Sessions:** Retained *(Valid Poor Session'lar: Korunur)*

**Result-Based Session Exclusion:** Forbidden *(Result-Based Session Exclusion: Yasak)*

**Final Build Freeze:** Mandatory *(Final Build Freeze: Zorunlu)*

**Final Model Freeze:** Mandatory *(Final Model Freeze: Zorunlu)*

**Final Route Freeze:** Mandatory *(Final Route Freeze: Zorunlu)*

**Final Inclusion Policy Freeze:** Mandatory *(Final Inclusion Policy Freeze: Zorunlu)*

**Final Metric Pipeline Freeze:** Mandatory *(Final Metric Pipeline Freeze: Zorunlu)*

**Post-Freeze Benchmark Tuning:** Forbidden *(Post-Freeze Benchmark Tuning: Yasak)*

**Failure Injection:** Mandatory *(Failure Injection: Zorunlu)*

**Dedicated Endurance Test:** Mandatory *(Dedicated Endurance Test: Zorunlu)*

**Unbounded Memory Growth:** Failure *(Unbounded Memory Growth: Hata)*

**Unbounded Writer / AI Queue Growth:** Failure *(Unbounded Writer / AI Queue Growth: Hata)*

**Ground Truth Leakage:** Critical Failure *(Ground Truth Leakage: Critical Failure)*

**Unresolved Critical Defects at Final Acceptance:** `0` *(Final Acceptance Sırasında Unresolved Critical Defect: `0`)*

**Final Software DoD:** Separate from Research Outcome *(Final Software DoD: Research Outcome'dan Ayrı)*

**Final Project Completion Level:** Definition of Done Level 7 *(Final Proje Completion Seviyesi: Definition of Done Level 7)*

**Final Project May Be Accepted with Negative Research Result:** Yes, if Evidence and Evaluation Are Valid *(Final Proje Negative Research Result ile Accepted Olabilir mi: Evet, Evidence ve Evaluation Valid ise)*

**Next Documentation Item:** 40 — Demo & Presentation Plan *(Sonraki Dokümantasyon Öğesi: 40 — Demo ve Sunum Planı)*
