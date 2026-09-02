# 43 — Technical Decisions & Change Log (Teknik Kararlar ve Değişiklik Günlüğü)

## 1. Document Purpose (Dokümanın Amacı)

This document is the authoritative registry of architectural, algorithmic, experimental, data, platform, evaluation, and implementation decisions for NAVGUARD. *(Bu doküman NAVGUARD için architectural, algorithmic, experimental, data, platform, evaluation ve implementation kararlarının authoritative registry’sidir.)*

It records which decisions are frozen, which remain provisional, which are optional, which were superseded, and which require physical evidence before finalization. *(Hangi kararların frozen, hangilerinin provisional, hangilerinin optional, hangilerinin superseded olduğunu ve hangilerinin finalization öncesinde physical evidence gerektirdiğini kaydeder.)*

---

# 2. Why a Decision Log Is Required (Neden Karar Günlüğü Gereklidir)

NAVGUARD contains many interacting subsystems whose assumptions can affect research validity. *(NAVGUARD research validity’yi etkileyebilecek assumption’lara sahip birçok interacting subsystem içerir.)*

A decision log prevents implementation choices from changing silently during development or after final benchmark evidence becomes visible. *(Decision log implementation choice’larının development sırasında veya final benchmark evidence görünür hale geldikten sonra silently değişmesini önler.)*

---

# 3. Authoritative Decision Principle (Authoritative Karar İlkesi)

When a later approved decision explicitly supersedes an earlier candidate decision, the later approved decision becomes authoritative. *(Later approved decision earlier candidate decision’ı explicitly supersede ettiğinde later approved decision authoritative hale gelir.)*

A silent contradiction does not automatically replace a previously frozen decision. *(Silent contradiction previously frozen decision’ı otomatik olarak replace etmez.)*

---

# 4. Decision Status Vocabulary (Karar Durumu Vocabulary)

NAVGUARD will use the following decision states. *(NAVGUARD aşağıdaki decision state’lerini kullanacaktır.)*

```text id="ex2khk"
FROZEN
(SABİT)

APPROVED
(ONAYLI)

PROVISIONAL
(GEÇİCİ)

CANDIDATE
(ADAY)

OPTIONAL
(İSTEĞE BAĞLI)

PENDING_EVIDENCE
(KANIT BEKLİYOR)

SUPERSEDED
(YERİNE YENİ KARAR GELDİ)

REJECTED
(REDDEDİLDİ)

DEFERRED
(ERTELENDİ)
```

---

# 5. FROZEN Meaning (FROZEN Anlamı)

`FROZEN` means the decision is part of the current authoritative architecture and must not change silently. *(`FROZEN`, kararın current authoritative architecture’ın parçası olduğu ve silently değiştirilemeyeceği anlamına gelir.)*

---

# 6. APPROVED Meaning (APPROVED Anlamı)

`APPROVED` means the decision has been accepted but may still receive implementation-level detail later. *(`APPROVED`, kararın accepted edildiği ancak later implementation-level detail alabileceği anlamına gelir.)*

---

# 7. PROVISIONAL Meaning (PROVISIONAL Anlamı)

`PROVISIONAL` means the current value or method may change before formal freeze when evidence justifies revision. *(`PROVISIONAL`, mevcut value veya method’un formal freeze öncesinde evidence justify ederse değişebileceği anlamına gelir.)*

---

# 8. CANDIDATE Meaning (CANDIDATE Anlamı)

`CANDIDATE` means the approach is under consideration and is not yet authoritative. *(`CANDIDATE`, approach’un değerlendirme altında olduğunu ve henüz authoritative olmadığını ifade eder.)*

---

# 9. OPTIONAL Meaning (OPTIONAL Anlamı)

`OPTIONAL` means the capability is not required for the minimum accepted research prototype. *(`OPTIONAL`, capability’nin minimum accepted research prototype için required olmadığını ifade eder.)*

---

# 10. PENDING_EVIDENCE Meaning (PENDING_EVIDENCE Anlamı)

`PENDING_EVIDENCE` means the decision must wait for target-device measurement, pilot data, or benchmark evidence. *(`PENDING_EVIDENCE`, kararın target-device measurement, pilot data veya benchmark evidence beklemesi gerektiği anlamına gelir.)*

---

# 11. SUPERSEDED Meaning (SUPERSEDED Anlamı)

`SUPERSEDED` means a newer documented decision has explicitly replaced the old one. *(`SUPERSEDED`, newer documented decision’ın old decision’ı explicitly replace ettiği anlamına gelir.)*

---

# 12. REJECTED Meaning (REJECTED Anlamı)

`REJECTED` means the approach is intentionally excluded from the current architecture. *(`REJECTED`, approach’un current architecture’dan intentionally excluded edildiği anlamına gelir.)*

---

# 13. DEFERRED Meaning (DEFERRED Anlamı)

`DEFERRED` means the idea may be useful later but is outside the current 24-business-day scope. *(`DEFERRED`, idea’nın later useful olabileceğini ancak current 24 iş günlük scope dışında olduğunu ifade eder.)*

---

# 14. Decision Record Structure (Karar Kaydı Yapısı)

Each formal decision should use a structured record where practical. *(Her formal decision practical olduğunda structured record kullanmalıdır.)*

```text id="n6q8ts"
Decision ID
(Karar ID)

Title
(Başlık)

Status
(Durum)

Decision
(Karar)

Rationale
(Gerekçe)

Alternatives
(Alternatifler)

Evidence Required
(Gerekli Kanıt)

Affected Subsystems
(Etkilenen Alt Sistemler)

Change Conditions
(Değişiklik Koşulları)

Source Page
(Kaynak Sayfa)
```

---

# 15. Decision ID Convention (Karar ID Convention)

Technical decisions will use the prefix `TD`. *(Technical decision’lar `TD` prefix’ini kullanacaktır.)*

```text id="64dg46"
TD-001
TD-002
TD-003
...
```

---

# 16. Change Record ID Convention (Change Record ID Convention)

Material changes will use the prefix `CR`. *(Material change’ler `CR` prefix’ini kullanacaktır.)*

```text id="i3eoih"
CR-001
CR-002
CR-003
...
```

---

# 17. No Retroactive Decision Editing (Retroactive Karar Editing Yoktur)

Historical decision records should not be rewritten to make earlier uncertainty disappear. *(Historical decision record’lar earlier uncertainty’yi disappear ettirmek için rewrite edilmemelidir.)*

A superseding decision should instead create a new documented record. *(Superseding decision bunun yerine new documented record oluşturmalıdır.)*

---

# 18. No Post-Hoc Benchmark Decision Changes (Post-Hoc Benchmark Karar Değişikliği Yoktur)

Final benchmark outcomes must not be used to silently alter frozen estimator parameters, routes, inclusion rules, or metric definitions. *(Final benchmark outcome’ları frozen estimator parameter’larını, route’ları, inclusion rule’larını veya metric definition’larını silently alter etmek için kullanılmamalıdır.)*

---

# 19. Change Timing Classes (Değişiklik Zamanlama Sınıfları)

Changes are classified according to when they occur. *(Change’ler ne zaman gerçekleştiğine göre classified edilir.)*

```text id="duv9d6"
PRE-IMPLEMENTATION
(IMPLEMENTATION ÖNCESİ)

DEVELOPMENT
(GELİŞTİRME)

PILOT
(PİLOT)

PRE-BENCHMARK FREEZE
(BENCHMARK ÖNCESİ FREEZE)

POST-FREEZE
(FREEZE SONRASI)

POST-RESULT
(SONUÇ SONRASI)
```

---

# 20. Change Risk Classes (Değişiklik Risk Sınıfları)

Materiality will be classified using four levels. *(Materiality dört level kullanılarak classified edilecektir.)*

```text id="hd1r66"
LOW
(DÜŞÜK)

MEDIUM
(ORTA)

HIGH
(YÜKSEK)

CRITICAL
(KRİTİK)
```

---

# 21. Low-Risk Change (Düşük Riskli Değişiklik)

A low-risk change does not alter estimator behavior, benchmark metrics, evidence interpretation, or data compatibility. *(Low-risk change estimator behavior, benchmark metric, evidence interpretation veya data compatibility’yi değiştirmez.)*

---

# 22. Medium-Risk Change (Orta Riskli Değişiklik)

A medium-risk change may alter non-critical behavior and requires regression testing. *(Medium-risk change non-critical behavior’ı değiştirebilir ve regression testing gerektirir.)*

---

# 23. High-Risk Change (Yüksek Riskli Değişiklik)

A high-risk change can affect navigation output, AI behavior, fusion, timing, recovery, or benchmark metrics. *(High-risk change navigation output, AI behavior, fusion, timing, recovery veya benchmark metric’lerini etkileyebilir.)*

---

# 24. Critical Change (Kritik Değişiklik)

A critical change can affect Ground Truth Firewall integrity, final metric correctness, benchmark comparability, or evidence validity. *(Critical change Ground Truth Firewall integrity, final metric correctness, benchmark comparability veya evidence validity’yi etkileyebilir.)*

---

# 25. TD-001 — Project Identity (TD-001 — Proje Kimliği)

**Status: FROZEN.** *(Durum: FROZEN.)*

The project name is `NAVGUARD — AI-Assisted GNSS-Denied Mobile Navigation & Sensor Fusion System`. *(Proje adı `NAVGUARD — AI-Assisted GNSS-Denied Mobile Navigation & Sensor Fusion System` olarak sabitlenmiştir.)*

---

# 26. TD-002 — Research Domain (TD-002 — Araştırma Alanı)

**Status: FROZEN.** *(Durum: FROZEN.)*

NAVGUARD is a pedestrian smartphone navigation research prototype. *(NAVGUARD pedestrian smartphone navigation research prototype’tır.)*

---

# 27. TD-003 — Primary Device (TD-003 — Ana Cihaz)

**Status: FROZEN.** *(Durum: FROZEN.)*

The primary development and benchmark device is the Xiaomi Redmi Note 9 Pro. *(Primary development ve benchmark device Xiaomi Redmi Note 9 Pro’dur.)*

---

# 28. TD-004 — Platform (TD-004 — Platform)

**Status: FROZEN.** *(Durum: FROZEN.)*

The implementation targets Android only for the initial project. *(Implementation initial project için yalnızca Android’i target eder.)*

---

# 29. TD-005 — Development Duration (TD-005 — Geliştirme Süresi)

**Status: FROZEN.** *(Durum: FROZEN.)*

The implementation roadmap is constrained to 24 business days. *(Implementation roadmap 24 iş günü ile constrained edilmiştir.)*

---

# 30. TD-006 — Additional Hardware (TD-006 — Ek Donanım)

**Status: FROZEN.** *(Durum: FROZEN.)*

The initial implementation requires no additional navigation hardware. *(Initial implementation additional navigation hardware gerektirmez.)*

---

# 31. TD-007 — GNSS Denial Method (TD-007 — GNSS Kesintisi Yöntemi)

**Status: FROZEN.** *(Durum: FROZEN.)*

GNSS denial is software-defined at the estimator authorization boundary. *(GNSS denial estimator authorization boundary’de software-defined olarak uygulanır.)*

---

# 32. TD-008 — RF Interference Exclusion (TD-008 — RF Müdahalesi Hariç Tutma)

**Status: FROZEN.** *(Durum: FROZEN.)*

RF jamming, spoofing, and intentional interference are outside the current implementation and experiment scope. *(RF jamming, spoofing ve intentional interference current implementation ve experiment scope dışındadır.)*

---

# 33. TD-009 — Offline Core (TD-009 — Offline Core)

**Status: APPROVED.** *(Durum: APPROVED.)*

Core navigation must remain usable without cloud inference. *(Core navigation cloud inference olmadan usable kalmalıdır.)*

---

# 34. TD-010 — Flutter Responsibility (TD-010 — Flutter Sorumluluğu)

**Status: FROZEN.** *(Durum: FROZEN.)*

Flutter/Dart owns UI, high-level orchestration, and platform-independent logic where timing allows. *(Flutter/Dart timing izin verdiği yerlerde UI, high-level orchestration ve platform-independent logic’i own eder.)*

---

# 35. TD-011 — Kotlin Responsibility (TD-011 — Kotlin Sorumluluğu)

**Status: FROZEN.** *(Durum: FROZEN.)*

Kotlin/native Android owns timing-sensitive sensor acquisition, GNSS acquisition, ARCore integration, and on-device AI runtime. *(Kotlin/native Android timing-sensitive sensor acquisition, GNSS acquisition, ARCore integration ve on-device AI runtime’ı own eder.)*

---

# 36. TD-012 — Python Responsibility (TD-012 — Python Sorumluluğu)

**Status: FROZEN.** *(Durum: FROZEN.)*

Python owns dataset processing, model training, replay analysis, evaluation, and result generation. *(Python dataset processing, model training, replay analysis, evaluation ve result generation’ı own eder.)*

---

# 37. TD-013 — Primary Motion Sensors (TD-013 — Primary Motion Sensor’ları)

**Status: FROZEN.** *(Durum: FROZEN.)*

Accelerometer, gyroscope, and magnetometer are mandatory sensor sources. *(Accelerometer, gyroscope ve magnetometer mandatory sensor source’lardır.)*

---

# 38. TD-014 — Rotation Vector (TD-014 — Rotation Vector)

**Status: APPROVED.** *(Durum: APPROVED.)*

Rotation Vector is a high-priority candidate orientation source when the device audit confirms suitable behavior. *(Rotation Vector device audit suitable behavior’ı doğruladığında high-priority candidate orientation source’tur.)*

---

# 39. TD-015 — Barometer (TD-015 — Barometre)

**Status: OPTIONAL / PENDING_EVIDENCE.** *(Durum: OPTIONAL / PENDING_EVIDENCE.)*

Barometer use depends on physical device capability and measured usefulness. *(Barometer kullanımı physical device capability ve measured usefulness’a bağlıdır.)*

---

# 40. TD-016 — Nominal Sensor Rate (TD-016 — Nominal Sensör Rate)

**Status: PROVISIONAL.** *(Durum: PROVISIONAL.)*

Accelerometer and gyroscope initially target approximately 50 Hz. *(Accelerometer ve gyroscope initial olarak yaklaşık 50 Hz target eder.)*

---

# 41. TD-017 — Magnetometer Rate (TD-017 — Magnetometer Rate)

**Status: PROVISIONAL.** *(Durum: PROVISIONAL.)*

Magnetometer initially targets approximately 20–50 Hz. *(Magnetometer initial olarak yaklaşık 20–50 Hz target eder.)*

---

# 42. TD-018 — Actual Rate Authority (TD-018 — Actual Rate Authority)

**Status: FROZEN.** *(Durum: FROZEN.)*

Actual delivered sampling rates are measured from timestamps rather than assumed from requested frequencies. *(Actual delivered sampling rate’ler requested frequency’lerden assumed edilmek yerine timestamp’lerden measured edilir.)*

---

# 43. TD-019 — Sensor Timestamp Authority (TD-019 — Sensör Timestamp Authority)

**Status: FROZEN.** *(Durum: FROZEN.)*

Monotonic sensor timestamps are authoritative for event ordering. *(Monotonic sensor timestamp’leri event ordering için authoritative’dir.)*

---

# 44. TD-020 — Wall Clock Role (TD-020 — Wall Clock Rolü)

**Status: FROZEN.** *(Durum: FROZEN.)*

Wall-clock time is supplemental metadata and is not authoritative for estimator ordering. *(Wall-clock time supplemental metadata’dır ve estimator ordering için authoritative değildir.)*

---

# 45. TD-021 — GNSS Provider (TD-021 — GNSS Provider)

**Status: FROZEN.** *(Durum: FROZEN.)*

Formal GNSS acquisition uses Android `LocationManager` with `GPS_PROVIDER`. *(Formal GNSS acquisition Android `LocationManager` ile `GPS_PROVIDER` kullanır.)*

---

# 46. TD-022 — Fused Location Provider (TD-022 — Fused Location Provider)

**Status: REJECTED for formal ground-truth reference.** *(Durum: Formal ground-truth reference için REJECTED.)*

A fused provider is not used as the authoritative Evaluation Mode GNSS source because it may combine undeclared sources. *(Fused provider undeclared source’ları combine edebileceği için authoritative Evaluation Mode GNSS source olarak kullanılmaz.)*

---

# 47. TD-023 — GNSS Measurement Time (TD-023 — GNSS Measurement Time)

**Status: FROZEN.** *(Durum: FROZEN.)*

`Location.getElapsedRealtimeNanos()` is the authoritative GNSS measurement timing source. *(`Location.getElapsedRealtimeNanos()` authoritative GNSS measurement timing source’tur.)*

---

# 48. TD-024 — Initial Anchor Policy (TD-024 — Initial Anchor Politikası)

**Status: FROZEN.** *(Durum: FROZEN.)*

The first GNSS callback is not automatically accepted as the navigation anchor. *(İlk GNSS callback navigation anchor olarak otomatik accepted edilmez.)*

---

# 49. TD-025 — Anchor Validation (TD-025 — Anchor Validation)

**Status: FROZEN.** *(Durum: FROZEN.)*

An anchor must pass freshness and quality validation before ENU initialization. *(Anchor ENU initialization öncesinde freshness ve quality validation’ı geçmelidir.)*

---

# 50. TD-026 — Exact Anchor Thresholds (TD-026 — Exact Anchor Threshold’ları)

**Status: PENDING_EVIDENCE.** *(Durum: PENDING_EVIDENCE.)*

Exact fix-age and accuracy thresholds will be determined from target-device field evidence before benchmark freeze. *(Exact fix-age ve accuracy threshold’ları benchmark freeze öncesinde target-device field evidence’dan determine edilecektir.)*

---

# 51. TD-027 — Internal Coordinate Frame (TD-027 — Internal Coordinate Frame)

**Status: FROZEN.** *(Durum: FROZEN.)*

NAVGUARD uses local ENU as the authoritative internal navigation frame. *(NAVGUARD authoritative internal navigation frame olarak local ENU kullanır.)*

---

# 52. TD-028 — ENU Axis Convention (TD-028 — ENU Axis Convention)

**Status: FROZEN.** *(Durum: FROZEN.)*

`+E` means East, `+N` means true North, and `+U` means Up. *(`+E` East, `+N` true North ve `+U` Up anlamına gelir.)*

---

# 53. TD-029 — Heading Convention (TD-029 — Heading Convention)

**Status: FROZEN.** *(Durum: FROZEN.)*

Heading is clockwise from true north. *(Heading true north’tan clockwise ölçülür.)*

---

# 54. TD-030 — Internal Angle Unit (TD-030 — Internal Angle Unit)

**Status: FROZEN.** *(Durum: FROZEN.)*

Internal mathematical angles use radians. *(Internal mathematical angle’lar radian kullanır.)*

---

# 55. TD-031 — Geographic Conversion (TD-031 — Geographic Conversion)

**Status: FROZEN.** *(Durum: FROZEN.)*

WGS84 ↔ ECEF ↔ ENU is the authoritative geographic conversion path. *(WGS84 ↔ ECEF ↔ ENU authoritative geographic conversion path’tir.)*

---

# 56. TD-032 — Direct Flat-Earth Latitude/Longitude Approximation (TD-032 — Direct Flat-Earth Latitude/Longitude Approximation)

**Status: REJECTED as authoritative conversion.** *(Durum: Authoritative conversion olarak REJECTED.)*

Simplified local latitude/longitude approximations may only be used for diagnostics or tests when explicitly labeled. *(Simplified local latitude/longitude approximation’ları yalnızca explicitly labeled olduğunda diagnostic veya test için kullanılabilir.)*

---

# 57. TD-033 — Quaternion Convention (TD-033 — Quaternion Convention)

**Status: FROZEN.** *(Durum: FROZEN.)*

The canonical internal quaternion order is `[w,x,y,z]`. *(Canonical internal quaternion order `[w,x,y,z]`’dir.)*

---

# 58. TD-034 — ARCore Quaternion Adaptation (TD-034 — ARCore Quaternion Adaptation)

**Status: FROZEN.** *(Durum: FROZEN.)*

ARCore native quaternion order must be explicitly adapted to NAVGUARD’s canonical internal order. *(ARCore native quaternion order NAVGUARD’ın canonical internal order’ına explicitly adapt edilmelidir.)*

---

# 59. TD-035 — PDR Strategy (TD-035 — PDR Stratejisi)

**Status: FROZEN.** *(Durum: FROZEN.)*

NAVGUARD uses step-event-driven pedestrian dead reckoning. *(NAVGUARD step-event-driven pedestrian dead reckoning kullanır.)*

---

# 60. TD-036 — Raw Acceleration Double Integration (TD-036 — Raw Acceleration Double Integration)

**Status: REJECTED.** *(Durum: REJECTED.)*

Raw acceleration is not double-integrated directly to obtain long-term pedestrian position. *(Raw acceleration long-term pedestrian position elde etmek için directly double-integrate edilmez.)*

---

# 61. TD-037 — PDR Propagation Equation (TD-037 — PDR Propagation Equation)

**Status: FROZEN.** *(Durum: FROZEN.)*

The core horizontal PDR propagation is defined as follows. *(Core horizontal PDR propagation aşağıdaki şekilde defined edilmiştir.)*

```text id="mq2gr8"
ΔE = L sin(ψ)
ΔN = L cos(ψ)

E_k = E_(k-1) + ΔE
N_k = N_(k-1) + ΔN
```

---

# 62. TD-038 — Authoritative Step Detector (TD-038 — Authoritative Step Detector)

**Status: FROZEN.** *(Durum: FROZEN.)*

The primary step detector is an independent deterministic NAVGUARD detector. *(Primary step detector independent deterministic NAVGUARD detector’dır.)*

---

# 63. TD-039 — Android Step Counter Role (TD-039 — Android Step Counter Rolü)

**Status: APPROVED as diagnostic only.** *(Durum: Yalnızca diagnostic olarak APPROVED.)*

Android step detector or step counter APIs may be used for comparison but are not authoritative navigation inputs. *(Android step detector veya step counter API’leri comparison için kullanılabilir ancak authoritative navigation input değildir.)*

---

# 64. TD-040 — Step Detector Form (TD-040 — Step Detector Form)

**Status: CANDIDATE / PROVISIONAL.** *(Durum: CANDIDATE / PROVISIONAL.)*

Acceleration magnitude, filtering, peak detection, and minimum inter-step timing form the initial deterministic detector design. *(Acceleration magnitude, filtering, peak detection ve minimum inter-step timing initial deterministic detector design’ını oluşturur.)*

---

# 65. TD-041 — Step Detection Thresholds (TD-041 — Step Detection Threshold’ları)

**Status: PENDING_EVIDENCE.** *(Durum: PENDING_EVIDENCE.)*

Final detector thresholds will be calibrated using pilot data before final benchmark freeze. *(Final detector threshold’ları final benchmark freeze öncesinde pilot data kullanılarak calibrate edilecektir.)*

---

# 66. TD-042 — Step Count Target (TD-042 — Step Count Hedefi)

**Status: FROZEN as target.** *(Durum: Target olarak FROZEN.)*

Controlled absolute step-count percentage error target is `≤5%`. *(Controlled absolute step-count percentage error target `≤5%`’tir.)*

---

# 67. TD-043 — Fixed Step-Length Baseline (TD-043 — Fixed Step-Length Baseline)

**Status: FROZEN.** *(Durum: FROZEN.)*

A calibrated fixed step-length method is mandatory as the simplest deterministic fallback. *(Calibrated fixed step-length method simplest deterministic fallback olarak mandatory’dir.)*

---

# 68. TD-044 — Fixed Calibration Formula (TD-044 — Fixed Calibration Formula)

**Status: FROZEN.** *(Durum: FROZEN.)*

Fixed calibration uses known distance divided by verified step count when defensible. *(Fixed calibration defensible olduğunda known distance’ın verified step count’a bölünmesini kullanır.)*

```text id="bqf5z7"
L_avg = D_ref / N_steps
```

---

# 69. TD-045 — Deterministic Variable Step Length (TD-045 — Deterministic Variable Step Length)

**Status: APPROVED candidate baseline.** *(Durum: Candidate baseline olarak APPROVED.)*

A Weinberg-style deterministic variable formulation is retained as the primary variable baseline candidate. *(Weinberg-style deterministic variable formulation primary variable baseline candidate olarak retained edilmiştir.)*

---

# 70. TD-046 — Learned Step Length (TD-046 — Learned Step Length)

**Status: OPTIONAL / EVIDENCE-GATED.** *(Durum: OPTIONAL / EVIDENCE-GATED.)*

Learned step length is not mandatory for minimum project completion. *(Learned step length minimum proje completion için mandatory değildir.)*

---

# 71. TD-047 — Step-Length ML Retention Rule (TD-047 — Step-Length ML Retention Kuralı)

**Status: FROZEN.** *(Durum: FROZEN.)*

A learned step-length model is retained only if held-out evidence demonstrates measurable benefit over deterministic baselines. *(Learned step-length model yalnızca held-out evidence deterministic baseline’lara göre measurable benefit gösterirse retained edilir.)*

---

# 72. TD-048 — Step-Length ML Models (TD-048 — Step-Length ML Modelleri)

**Status: APPROVED candidates.** *(Durum: APPROVED candidate’lar.)*

Linear Regression and Random Forest Regressor are the primary learned step-length candidates. *(Linear Regression ve Random Forest Regressor primary learned step-length candidate’lardır.)*

---

# 73. TD-049 — Small Neural Step-Length Model (TD-049 — Small Neural Step-Length Model)

**Status: OPTIONAL.** *(Durum: OPTIONAL.)*

A small neural model may be tested only if dataset quantity and label quality justify additional complexity. *(Small neural model yalnızca dataset quantity ve label quality additional complexity’yi justify ederse test edilebilir.)*

---

# 74. TD-050 — Per-Step Ground Truth (TD-050 — Per-Step Ground Truth)

**Status: NOT ASSUMED.** *(Durum: ASSUMED EDİLMEZ.)*

Per-step step-length ground truth will not be fabricated from route-average labels. *(Per-step step-length ground truth route-average label’lardan fabricate edilmeyecektir.)*

---

# 75. TD-051 — Heading Reference (TD-051 — Heading Reference)

**Status: FROZEN.** *(Durum: FROZEN.)*

Operational heading is referenced to true north. *(Operational heading true north’a referenced edilir.)*

---

# 76. TD-052 — Heading Sources (TD-052 — Heading Sources)

**Status: APPROVED.** *(Durum: APPROVED.)*

Magnetometer absolute reference, gyroscope short-term propagation, and Rotation Vector are the main heading-source candidates. *(Magnetometer absolute reference, gyroscope short-term propagation ve Rotation Vector main heading-source candidate’lardır.)*

---

# 77. TD-053 — Magnetic Declination (TD-053 — Magnetic Declination)

**Status: FROZEN.** *(Durum: FROZEN.)*

Magnetic heading must be corrected to true north when the selected method requires it. *(Selected method gerektirdiğinde magnetic heading true north’a corrected edilmelidir.)*

---

# 78. TD-054 — GNSS Bearing (TD-054 — GNSS Bearing)

**Status: REJECTED as phone heading.** *(Durum: Phone heading olarak REJECTED.)*

GNSS movement or travel bearing is not equivalent to physical device or body heading. It may be inspected only as travel-direction diagnostic information in explicitly authorized GNSS Mode or during offline post-session evaluation. *(GNSS movement veya travel bearing fiziksel cihaz veya body heading'e eşdeğer değildir. Yalnızca açıkça authorized GNSS Mode içerisinde veya offline post-session evaluation sırasında travel-direction diagnostic bilgisi olarak incelenebilir.)*

During a denied Evaluation interval, protected GNSS bearing is not authorized to correct or reset heading, enter the estimator, influence heading confidence, influence the navigation Quality Engine, or alter controller behavior. Motion or quality gates cannot override this prohibition. *(Denied Evaluation interval sırasında protected GNSS bearing heading'i düzeltemez veya resetleyemez, estimator'a giremez, heading confidence'i etkileyemez, navigation Quality Engine'i etkileyemez veya controller behavior'ı değiştiremez. Motion veya quality gate'leri bu yasağı geçersiz kılamaz.)*

---

# 79. TD-055 — Heading Circular Mathematics (TD-055 — Heading Circular Mathematics)

**Status: FROZEN.** *(Durum: FROZEN.)*

Heading differences and innovations use circular mathematics. *(Heading difference ve innovation’lar circular mathematics kullanır.)*

---

# 80. TD-056 — Magnetic Disturbance Handling (TD-056 — Magnetic Disturbance Handling)

**Status: FROZEN at architectural level.** *(Durum: Architectural level’da FROZEN.)*

Hard-invalid magnetic measurements are rejected, while soft degradation may increase uncertainty. *(Hard-invalid magnetic measurement’lar rejected edilirken soft degradation uncertainty’yi artırabilir.)*

---

# 81. TD-057 — Motion Classification Mandatory AI (TD-057 — Mandatory Motion Classification AI)

**Status: FROZEN.** *(Durum: FROZEN.)*

Motion Classification is the mandatory AI component of NAVGUARD. *(Motion Classification NAVGUARD’ın mandatory AI component’idir.)*

---

# 82. TD-058 — Motion Class Set (TD-058 — Motion Class Set)

**Status: FROZEN.** *(Durum: FROZEN.)*

The trained classes are exactly `STATIONARY`, `WALKING`, `RUNNING`, and `TURNING`. *(Trained class’lar exactly `STATIONARY`, `WALKING`, `RUNNING` ve `TURNING` olarak sabitlenmiştir.)*

---

# 83. TD-059 — TURNING Semantics (TD-059 — TURNING Semantics)

**Status: FROZEN.** *(Durum: FROZEN.)*

`TURNING` represents a dominant rotational context and may overlap physically with walking. *(`TURNING` dominant rotational context’i represent eder ve physically walking ile overlap edebilir.)*

---

# 84. TD-060 — Motion AI Input Channels (TD-060 — Motion AI Input Channel’ları)

**Status: FROZEN as primary input.** *(Durum: Primary input olarak FROZEN.)*

The primary Motion Classification tensor uses accelerometer and gyroscope axes. *(Primary Motion Classification tensor accelerometer ve gyroscope axis’lerini kullanır.)*

---

# 85. TD-061 — Motion AI Optional Features (TD-061 — Motion AI Optional Feature’ları)

**Status: OPTIONAL / ABLATION ONLY.** *(Durum: OPTIONAL / YALNIZCA ABLATION.)*

Acceleration and gyroscope magnitudes may be added only through documented ablation evidence. *(Acceleration ve gyroscope magnitude’ları yalnızca documented ablation evidence üzerinden eklenebilir.)*

---

# 86. TD-062 — Magnetometer as Motion AI Input (TD-062 — Magnetometer’ın Motion AI Input Olması)

**Status: NOT DEFAULT.** *(Durum: DEFAULT DEĞİL.)*

Magnetometer is not part of the default Motion Classification feature set. *(Magnetometer default Motion Classification feature set’in parçası değildir.)*

---

# 87. TD-063 — Motion Window Duration (TD-063 — Motion Window Duration)

**Status: CANDIDATE.** *(Durum: CANDIDATE.)*

Candidate window durations are approximately 1.0, 1.5, and 2.0 seconds. *(Candidate window duration’ları yaklaşık 1.0, 1.5 ve 2.0 second’dır.)*

---

# 88. TD-064 — Motion Window Overlap (TD-064 — Motion Window Overlap)

**Status: CANDIDATE.** *(Durum: CANDIDATE.)*

Candidate overlap values include 0%, 50%, and 75%. *(Candidate overlap value’ları 0%, 50% ve 75% içerir.)*

---

# 89. TD-065 — ML Split Unit (TD-065 — ML Split Unit)

**Status: FROZEN.** *(Durum: FROZEN.)*

The physical recording session is the fundamental machine-learning split unit. *(Physical recording session fundamental machine-learning split unit’tir.)*

---

# 90. TD-066 — Window Leakage Prevention (TD-066 — Window Leakage Prevention)

**Status: FROZEN.** *(Durum: FROZEN.)*

Overlapping windows from the same physical session may not cross train, validation, and test partitions. *(Aynı physical session’dan overlapping window’lar train, validation ve test partition’ları arasında cross edemez.)*

---

# 91. TD-067 — Motion AI Classical Baselines (TD-067 — Motion AI Classical Baseline’ları)

**Status: APPROVED.** *(Durum: APPROVED.)*

Logistic Regression is a simple baseline and Random Forest is the primary nonlinear classical baseline. *(Logistic Regression simple baseline, Random Forest ise primary nonlinear classical baseline’dır.)*

---

# 92. TD-068 — Motion AI Neural Candidate (TD-068 — Motion AI Neural Candidate)

**Status: FROZEN as primary neural candidate.** *(Durum: Primary neural candidate olarak FROZEN.)*

A lightweight 1D-CNN is the primary neural Motion Classification candidate. *(Lightweight 1D-CNN primary neural Motion Classification candidate’dır.)*

---

# 93. TD-069 — Motion AI Primary Metric (TD-069 — Motion AI Primary Metric)

**Status: FROZEN.** *(Durum: FROZEN.)*

Held-out session-wise Macro F1 is the primary Motion Classification metric. *(Held-out session-wise Macro F1 primary Motion Classification metric’tir.)*

---

# 94. TD-070 — Motion AI Target (TD-070 — Motion AI Hedefi)

**Status: FROZEN as target.** *(Durum: Target olarak FROZEN.)*

The provisional held-out Macro F1 target is `≥0.90`. *(Provisional held-out Macro F1 target `≥0.90`’dır.)*

---

# 95. TD-071 — Softmax Interpretation (TD-071 — Softmax Yorumu)

**Status: FROZEN.** *(Durum: FROZEN.)*

Raw Softmax output is treated as a model score unless calibration evidence supports probability interpretation. *(Raw Softmax output calibration evidence probability interpretation’ı support etmedikçe model score olarak treated edilir.)*

---

# 96. TD-072 — AI Shadow Mode (TD-072 — AI Shadow Mode)

**Status: FROZEN.** *(Durum: FROZEN.)*

Motion AI must operate in shadow mode before it is allowed to influence navigation. *(Motion AI navigation’ı influence etmesine izin verilmeden önce shadow mode’da operate etmelidir.)*

---

# 97. TD-073 — AI Navigation Role (TD-073 — AI Navigation Rolü)

**Status: FROZEN.** *(Durum: FROZEN.)*

Motion Classification must affect validated navigation behavior and may not remain UI-only. *(Motion Classification validated navigation behavior’ı affect etmeli ve UI-only kalmamalıdır.)*

---

# 98. TD-074 — AI as Single Point of Failure (TD-074 — AI’ın Single Point of Failure Olması)

**Status: REJECTED.** *(Durum: REJECTED.)*

AI failure must not stop deterministic navigation. *(AI failure deterministic navigation’ı stop etmemelidir.)*

---

# 99. TD-075 — On-Device AI Format (TD-075 — On-Device AI Format)

**Status: APPROVED.** *(Durum: APPROVED.)*

Neural models are deployed through `.tflite` artifacts using Google LiteRT-compatible runtime. *(Neural model’lar Google LiteRT-compatible runtime kullanılarak `.tflite` artifact’ları üzerinden deploy edilir.)*

---

# 100. TD-076 — Classical Model Deployment (TD-076 — Classical Model Deployment)

**Status: APPROVED.** *(Durum: APPROVED.)*

A classical model may be deployed without LiteRT if it wins the final evidence-based model selection. *(Classical model final evidence-based model selection’ı kazanırsa LiteRT olmadan deploy edilebilir.)*

---

# 101. TD-077 — AI Runtime Owner (TD-077 — AI Runtime Owner)

**Status: FROZEN.** *(Durum: FROZEN.)*

Kotlin owns production on-device inference. *(Kotlin production on-device inference’ı own eder.)*

---

# 102. TD-078 — Preprocessing Parity (TD-078 — Preprocessing Parity)

**Status: FROZEN.** *(Durum: FROZEN.)*

Python training and Android inference preprocessing must match through golden parity tests. *(Python training ve Android inference preprocessing golden parity test’leri üzerinden match etmelidir.)*

---

# 103. TD-079 — Model Registry (TD-079 — Model Registry)

**Status: FROZEN.** *(Durum: FROZEN.)*

Each deployed model must have a version, hash, schema, dataset identity, and evaluation provenance. *(Her deployed model version, hash, schema, dataset identity ve evaluation provenance’a sahip olmalıdır.)*

---

# 104. TD-080 — AI Runtime Target (TD-080 — AI Runtime Hedefi)

**Status: PROVISIONAL TARGET.** *(Durum: PROVISIONAL TARGET.)*

The initial target is approximately below 50 ms per inference on the Redmi Note 9 Pro. *(Initial target Redmi Note 9 Pro üzerinde inference başına yaklaşık 50 ms altıdır.)*

---

# 105. TD-081 — AI Hardware Delegate (TD-081 — AI Hardware Delegate)

**Status: OPTIONAL / PENDING_EVIDENCE.** *(Durum: OPTIONAL / PENDING_EVIDENCE.)*

CPU is the baseline, while GPU or other delegates are retained only if measured target-device benefit exists. *(CPU baseline’dır; GPU veya other delegate’ler yalnızca measured target-device benefit mevcutsa retained edilir.)*

---

# 106. TD-082 — Quantization (TD-082 — Quantization)

**Status: OPTIONAL.** *(Durum: OPTIONAL.)*

Quantization is evaluated only after a float baseline exists. *(Quantization yalnızca float baseline mevcut olduktan sonra evaluate edilir.)*

---

# 107. TD-083 — ARCore Role (TD-083 — ARCore Rolü)

**Status: FROZEN.** *(Durum: FROZEN.)*

ARCore is a relative visual-inertial motion source and not a global latitude/longitude source. *(ARCore relative visual-inertial motion source’tur ve global latitude/longitude source değildir.)*

---

# 108. TD-084 — ARCore Optionality (TD-084 — ARCore Optionality)

**Status: FROZEN.** *(Durum: FROZEN.)*

ARCore is a target enhancement, while PDR remains the mandatory fallback. *(ARCore target enhancement’tır; PDR mandatory fallback olarak kalır.)*

---

# 109. TD-085 — ARCore Session Ownership (TD-085 — ARCore Session Ownership)

**Status: FROZEN.** *(Durum: FROZEN.)*

A dedicated native Android owner manages the ARCore session. *(Dedicated native Android owner ARCore session’ı manage eder.)*

---

# 110. TD-086 — ARCore Tracking Gate (TD-086 — ARCore Tracking Gate)

**Status: FROZEN.** *(Durum: FROZEN.)*

Only poses in `TRACKING` state may enter formal fusion. *(Yalnızca `TRACKING` state’teki pose’lar formal fusion’a girebilir.)*

---

# 111. TD-087 — ARCore PAUSED Handling (TD-087 — ARCore PAUSED Handling)

**Status: FROZEN.** *(Durum: FROZEN.)*

`PAUSED` poses are rejected from estimator updates. *(`PAUSED` pose’ları estimator update’lerinden rejected edilir.)*

---

# 112. TD-088 — ARCore Tracking Loss (TD-088 — ARCore Tracking Loss)

**Status: FROZEN.** *(Durum: FROZEN.)*

Tracking loss stops ARCore updates but does not stop valid PDR. *(Tracking loss ARCore update’lerini stop eder ancak valid PDR’ı stop etmez.)*

---

# 113. TD-089 — ARCore Segment Strategy (TD-089 — ARCore Segment Stratejisi)

**Status: APPROVED.** *(Durum: APPROVED.)*

Tracking recovery generally starts a new ARCore segment unless continuity is explicitly validated. *(Tracking recovery continuity explicitly validated değilse generally new ARCore segment başlatır.)*

---

# 114. TD-090 — ARCore Axis Mapping (TD-090 — ARCore Axis Mapping)

**Status: FROZEN.** *(Durum: FROZEN.)*

ARCore axes are not hardcoded directly as ENU axes. *(ARCore axis’leri directly ENU axis’leri olarak hardcode edilmez.)*

---

# 115. TD-091 — ARCore-to-ENU Alignment (TD-091 — ARCore-to-ENU Alignment)

**Status: FROZEN at architectural level.** *(Durum: Architectural level’da FROZEN.)*

An explicit transform maps ARCore relative displacement into NAVGUARD ENU. *(Explicit transform ARCore relative displacement’ı NAVGUARD ENU’ya map eder.)*

---

# 116. TD-092 — ARCore Timestamp Mapping (TD-092 — ARCore Timestamp Mapping)

**Status: PENDING_EVIDENCE.** *(Durum: PENDING_EVIDENCE.)*

ARCore frame timing must be physically validated before assuming direct equivalence with Android elapsed-realtime clocks. *(ARCore frame timing Android elapsed-realtime clock’larla direct equivalence assumed edilmeden önce physically validated edilmelidir.)*

---

# 117. TD-093 — ARCore Cloud Anchors (TD-093 — ARCore Cloud Anchors)

**Status: REJECTED from current scope.** *(Durum: Current scope için REJECTED.)*

Cloud Anchors are not required for the initial architecture. *(Cloud Anchors initial architecture için required değildir.)*

---

# 118. TD-094 — ARCore Geospatial (TD-094 — ARCore Geospatial)

**Status: REJECTED from current estimator.** *(Durum: Current estimator için REJECTED.)*

Geospatial APIs are not part of the current relative-tracking design. *(Geospatial API’ler current relative-tracking design’ın parçası değildir.)*

---

# 119. TD-095 — ARCore Depth (TD-095 — ARCore Depth)

**Status: DEFERRED.** *(Durum: DEFERRED.)*

Depth APIs are not required for the current navigation hypothesis. *(Depth API’ler current navigation hypothesis için required değildir.)*

---

# 120. TD-096 — Quality Engine State Vocabulary (TD-096 — Quality Engine State Vocabulary)

**Status: FROZEN.** *(Durum: FROZEN.)*

The canonical quality states are `UNKNOWN`, `GOOD`, `USABLE`, `DEGRADED`, `UNRELIABLE`, and `UNAVAILABLE`. *(Canonical quality state’leri `UNKNOWN`, `GOOD`, `USABLE`, `DEGRADED`, `UNRELIABLE` ve `UNAVAILABLE` olarak sabitlenmiştir.)*

---

# 121. TD-097 — Canonical Quality-State Correction (TD-097 — Canonical Quality-State Correction)

**Status: FROZEN CORRECTION.** *(Durum: FROZEN CORRECTION.)*

Any later use of temporary names such as `HIGH`, `POOR`, or `INVALID` must not replace the Page 20 canonical Quality Engine vocabulary. *(Later kullanılan `HIGH`, `POOR` veya `INVALID` gibi temporary name’ler Page 20 canonical Quality Engine vocabulary’sini replace etmemelidir.)*

---

# 122. TD-098 — Validity vs Quality (TD-098 — Validity vs Quality)

**Status: FROZEN.** *(Durum: FROZEN.)*

Hard validity and quality state are separate concepts. *(Hard validity ve quality state ayrı concept’lerdir.)*

---

# 123. TD-099 — Availability vs Quality (TD-099 — Availability vs Quality)

**Status: FROZEN.** *(Durum: FROZEN.)*

Source availability is represented separately from source quality. *(Source availability source quality’den separately represented edilir.)*

---

# 124. TD-100 — Quality Dimensions (TD-100 — Quality Dimensions)

**Status: APPROVED.** *(Durum: APPROVED.)*

Quality may consider availability, freshness, timing, plausibility, continuity, environmental reliability, internal consistency, and cross-sensor consistency. *(Quality availability, freshness, timing, plausibility, continuity, environmental reliability, internal consistency ve cross-sensor consistency’yi consider edebilir.)*

---

# 125. TD-101 — Hard Invalid Measurement Policy (TD-101 — Hard Invalid Measurement Politikası)

**Status: FROZEN.** *(Durum: FROZEN.)*

Hard-invalid measurements are rejected before covariance scaling or fusion. *(Hard-invalid measurement’lar covariance scaling veya fusion öncesinde rejected edilir.)*

---

# 126. TD-102 — Soft Degradation Policy (TD-102 — Soft Degradation Politikası)

**Status: FROZEN.** *(Durum: FROZEN.)*

Soft-degraded measurements may remain usable with increased uncertainty when justified. *(Soft-degraded measurement’lar justified olduğunda increased uncertainty ile usable kalabilir.)*

---

# 127. TD-103 — Quality to Covariance Mapping (TD-103 — Quality to Covariance Mapping)

**Status: PENDING_EVIDENCE.** *(Durum: PENDING_EVIDENCE.)*

Exact mapping from quality to `R` or other uncertainty adjustments requires calibration. *(Quality’den `R` veya other uncertainty adjustment’lara exact mapping calibration gerektirir.)*

---

# 128. TD-104 — Arbitrary Confidence-to-R Mapping (TD-104 — Arbitrary Confidence-to-R Mapping)

**Status: REJECTED.** *(Durum: REJECTED.)*

NAVGUARD will not use an undocumented rule such as `R = 1 / confidence` as the formal covariance model. *(NAVGUARD formal covariance model olarak `R = 1 / confidence` gibi undocumented rule kullanmayacaktır.)*

---

# 129. TD-105 — Quality Hysteresis (TD-105 — Quality Hysteresis)

**Status: APPROVED.** *(Durum: APPROVED.)*

Quality recovery and degradation may use hysteresis to avoid rapid state oscillation. *(Quality recovery ve degradation rapid state oscillation’dan kaçınmak için hysteresis kullanabilir.)*

---

# 130. TD-106 — EKF Minimum State (TD-106 — EKF Minimum State)

**Status: FROZEN.** *(Durum: FROZEN.)*

The authoritative initial EKF state is `[E,N,ψ]`. *(Authoritative initial EKF state `[E,N,ψ]`’dir.)*

---

# 131. TD-107 — Velocity-Extended EKF (TD-107 — Velocity-Extended EKF)

**Status: OPTIONAL / PENDING_EVIDENCE.** *(Durum: OPTIONAL / PENDING_EVIDENCE.)*

The state `[E,N,vE,vN,ψ]` is an optional future extension and is not the current frozen core. *(`[E,N,vE,vN,ψ]` state’i optional future extension’dır ve current frozen core değildir.)*

---

# 132. TD-108 — Page 28/29 EKF Clarification (TD-108 — Page 28/29 EKF Açıklaması)

**Status: FROZEN CORRECTION.** *(Durum: FROZEN CORRECTION.)*

Any `[E,N,vE,vN,ψ]` equations appearing in Pages 28 or 29 must be interpreted only as optional extended-state examples. *(Page 28 veya 29’da görünen `[E,N,vE,vN,ψ]` equation’ları yalnızca optional extended-state example olarak interpreted edilmelidir.)*

The Page 21 `[E,N,ψ]` definition remains authoritative. *(Page 21 `[E,N,ψ]` definition authoritative olarak kalır.)*

---

# 133. TD-109 — EKF Step Prediction (TD-109 — EKF Step Prediction)

**Status: FROZEN.** *(Durum: FROZEN.)*

The core prediction model is defined as follows. *(Core prediction model aşağıdaki şekilde defined edilmiştir.)*

```text id="rxy9qc"
E⁻ = E⁺ + L sin(ψ)
N⁻ = N⁺ + L cos(ψ)
ψ⁻ = ψ⁺
```

---

# 134. TD-110 — EKF Jacobian (TD-110 — EKF Jacobian)

**Status: FROZEN.** *(Durum: FROZEN.)*

The minimum-state Jacobian is fixed as follows. *(Minimum-state Jacobian aşağıdaki şekilde fixed edilmiştir.)*

```text id="ly4bpf"
F =
[1 0  L cosψ]
[0 1 -L sinψ]
[0 0      1  ]
```

---

# 135. TD-111 — Step-Length Noise Mapping (TD-111 — Step-Length Noise Mapping)

**Status: FROZEN.** *(Durum: FROZEN.)*

Step-length uncertainty maps through the following vector. *(Step-length uncertainty aşağıdaki vector üzerinden map edilir.)*

```text id="iz94h5"
G_L =
[sinψ
 cosψ
 0]
```

---

# 136. TD-112 — EKF Covariance Propagation (TD-112 — EKF Covariance Propagation)

**Status: FROZEN.** *(Durum: FROZEN.)*

Covariance propagation uses the standard form `P⁻ = F P⁺ Fᵀ + Q_step`. *(Covariance propagation standard form `P⁻ = F P⁺ Fᵀ + Q_step` kullanır.)*

---

# 137. TD-113 — Heading State Explicitness (TD-113 — Heading State Explicitness)

**Status: FROZEN.** *(Durum: FROZEN.)*

Heading remains an explicit state so heading uncertainty can propagate into position uncertainty. *(Heading explicit state olarak kalır ki heading uncertainty position uncertainty’ye propagate edebilsin.)*

---

# 138. TD-114 — Circular EKF Heading Innovation (TD-114 — Circular EKF Heading Innovation)

**Status: FROZEN.** *(Durum: FROZEN.)*

Heading innovation uses wrapped circular difference. *(Heading innovation wrapped circular difference kullanır.)*

---

# 139. TD-115 — Joseph Covariance Update (TD-115 — Joseph Covariance Update)

**Status: APPROVED / PREFERRED.** *(Durum: APPROVED / PREFERRED.)*

The Joseph form is preferred for the formal covariance update. *(Joseph form formal covariance update için preferred’dır.)*

---

# 140. TD-116 — EKF Measurement Authorization (TD-116 — EKF Measurement Authorization)

**Status: FROZEN.** *(Durum: FROZEN.)*

Measurements must pass authorization before they can enter estimator quality processing and fusion. *(Measurement’lar estimator quality processing ve fusion’a girmeden önce authorization’ı geçmelidir.)*

---

# 141. TD-117 — Authorized GNSS EKF Update (TD-117 — Authorized GNSS EKF Update)

**Status: FROZEN.** *(Durum: FROZEN.)*

Authorized GNSS may act as a horizontal ENU position measurement outside blocked denied phases. *(Authorized GNSS blocked denied phase’lerin dışında horizontal ENU position measurement olarak act edebilir.)*

---

# 142. TD-118 — Core GNSS Measurement Matrix (TD-118 — Core GNSS Measurement Matrix)

**Status: FROZEN CLARIFICATION.** *(Durum: FROZEN CLARIFICATION.)*

For core state `[E,N,ψ]`, horizontal position measurement uses the following `H`. *(Core state `[E,N,ψ]` için horizontal position measurement aşağıdaki `H`’yi kullanır.)*

```text id="1oferu"
H =
[1 0 0]
[0 1 0]
```

---

# 143. TD-119 — ARCore EKF Representation (TD-119 — ARCore EKF Representation)

**Status: CANDIDATE.** *(Durum: CANDIDATE.)*

Initial ARCore fusion uses segment-relative ENU pseudo-position with conservative covariance. *(Initial ARCore fusion segment-relative ENU pseudo-position ile conservative covariance kullanır.)*

---

# 144. TD-120 — ARCore/PDR Correlation Caveat (TD-120 — ARCore/PDR Correlation Caveat)

**Status: FROZEN as recognized limitation.** *(Durum: Recognized limitation olarak FROZEN.)*

Potential correlation between ARCore and other inertial sources must be acknowledged when interpreting covariance. *(ARCore ile other inertial source’lar arasındaki potential correlation covariance interpreted edilirken acknowledged edilmelidir.)*

---

# 145. TD-121 — Innovation Gate (TD-121 — Innovation Gate)

**Status: APPROVED candidate.** *(Durum: APPROVED candidate.)*

NIS-based innovation gating is the primary candidate outlier-rejection method. *(NIS-based innovation gating primary candidate outlier-rejection method’dur.)*

---

# 146. TD-122 — NIS Threshold (TD-122 — NIS Threshold)

**Status: PENDING_EVIDENCE.** *(Durum: PENDING_EVIDENCE.)*

The exact chi-square threshold must be frozen before final benchmark interpretation. *(Exact chi-square threshold final benchmark interpretation öncesinde frozen edilmelidir.)*

---

# 147. TD-123 — Ground Truth Firewall (TD-123 — Ground Truth Firewall)

**Status: CRITICAL FROZEN.** *(Durum: CRITICAL FROZEN.)*

Evaluation Mode GNSS reference is blocked from estimator updates throughout the denied interval. *(Evaluation Mode GNSS reference denied interval boyunca estimator update’lerinden blocked edilir.)*

---

# 148. TD-124 — Ground Truth Logging During Denial (TD-124 — Denial Sırasında Ground Truth Logging)

**Status: FROZEN.** *(Durum: FROZEN.)*

Physical GNSS may remain active and independently logged during Evaluation Mode denial. *(Physical GNSS Evaluation Mode denial sırasında active kalabilir ve independently logged edilebilir.)*

---

# 149. TD-125 — Ground Truth Live Visibility (TD-125 — Ground Truth Live Visibility)

**Status: FROZEN.** *(Durum: FROZEN.)*

Protected GNSS ground truth remains hidden from the main operator view during blinded denied navigation. *(Protected GNSS ground truth blinded denied navigation sırasında main operator view’dan hidden kalır.)*

---

# 150. TD-126 — Unauthorized GNSS Counter (TD-126 — Unauthorized GNSS Counter)

**Status: CRITICAL FROZEN.** *(Durum: CRITICAL FROZEN.)*

`unauthorizedGnssEstimatorUpdateCount` must remain exactly zero for every valid denied benchmark interval. *(`unauthorizedGnssEstimatorUpdateCount` every valid denied benchmark interval için exactly zero kalmalıdır.)*

---

# 151. TD-127 — Ground Truth Mutation Test (TD-127 — Ground Truth Mutation Test)

**Status: FROZEN.** *(Durum: FROZEN.)*

Changing protected GNSS values during replay must not alter denied estimator output. *(Replay sırasında protected GNSS value’larını değiştirmek denied estimator output’u alter etmemelidir.)*

---

# 152. TD-128 — Ground Truth as AI Feature (TD-128 — Ground Truth’un AI Feature Olması)

**Status: REJECTED.** *(Durum: REJECTED.)*

Protected GNSS reference cannot be used as a live Motion Classification or Step-Length Estimation feature during denial. *(Protected GNSS reference denial sırasında live Motion Classification veya Step-Length Estimation feature olarak kullanılamaz.)*

---

# 153. TD-129 — Navigation Modes (TD-129 — Navigation Modları)

**Status: FROZEN.** *(Durum: FROZEN.)*

NAVGUARD uses explicit GNSS, Evaluation, GNSS-Denied, Recovery, and restored-navigation states. *(NAVGUARD explicit GNSS, Evaluation, GNSS-Denied, Recovery ve restored-navigation state’lerini kullanır.)*

---

# 154. TD-130 — Denial State Continuity (TD-130 — Denial State Continuity)

**Status: FROZEN.** *(Durum: FROZEN.)*

Entering denial does not reset navigation state or covariance. *(Denial’a girmek navigation state veya covariance’i reset etmez.)*

---

# 155. TD-131 — Denial Covariance Behavior (TD-131 — Denial Covariance Behavior)

**Status: FROZEN.** *(Durum: FROZEN.)*

GNSS denial does not artificially shrink estimator covariance. *(GNSS denial estimator covariance’i artificially shrink etmez.)*

---

# 156. TD-132 — Recovery as Controlled Transition (TD-132 — Recovery’nin Controlled Transition Olması)

**Status: FROZEN.** *(Durum: FROZEN.)*

Recovery is a controlled state transition and not first-fix injection. *(Recovery controlled state transition’dır ve first-fix injection değildir.)*

---

# 157. TD-133 — Recovery First Fix (TD-133 — Recovery First Fix)

**Status: REJECTED as automatic reference.** *(Durum: Automatic reference olarak REJECTED.)*

The first returning GNSS fix is not automatically accepted as the recovery reference. *(İlk returning GNSS fix recovery reference olarak otomatik accepted edilmez.)*

---

# 158. TD-134 — Recovery Validation Strategy (TD-134 — Recovery Validation Stratejisi)

**Status: APPROVED, details pending.** *(Durum: APPROVED, detail’ler pending.)*

Recovery uses freshness, provider, quality, and preferably short-term stability checks. *(Recovery freshness, provider, quality ve preferably short-term stability check’leri kullanır.)*

---

# 159. TD-135 — Recovery Thresholds (TD-135 — Recovery Threshold’ları)

**Status: PENDING_EVIDENCE.** *(Durum: PENDING_EVIDENCE.)*

Exact recovery fix age, accuracy, stable count, stability window, and spread thresholds remain pending pilot evidence. *(Exact recovery fix age, accuracy, stable count, stability window ve spread threshold’ları pilot evidence beklemektedir.)*

---

# 160. TD-136 — Pre-Correction Snapshot (TD-136 — Pre-Correction Snapshot)

**Status: CRITICAL FROZEN.** *(Durum: CRITICAL FROZEN.)*

Estimator state and covariance must be preserved before any recovery correction. *(Estimator state ve covariance herhangi bir recovery correction öncesinde preserved edilmelidir.)*

---

# 161. TD-137 — Recovery Error Timing (TD-137 — Recovery Error Timing)

**Status: CRITICAL FROZEN.** *(Durum: CRITICAL FROZEN.)*

Recovery error is measured before correction. *(Recovery error correction öncesinde measured edilir.)*

---

# 162. TD-138 — Recovery Coordinate Frame (TD-138 — Recovery Coordinate Frame)

**Status: FROZEN.** *(Durum: FROZEN.)*

Recovery error is calculated in the original denied-session ENU frame. *(Recovery error original denied-session ENU frame içerisinde calculated edilir.)*

---

# 163. TD-139 — Historical Trajectory Immutability (TD-139 — Historical Trajectory Immutability)

**Status: CRITICAL FROZEN.** *(Durum: CRITICAL FROZEN.)*

Recovery must not rewrite the historical denied trajectory. *(Recovery historical denied trajectory’yi rewrite etmemelidir.)*

---

# 164. TD-140 — Recovery Correction Candidate (TD-140 — Recovery Correction Candidate)

**Status: APPROVED initial preference.** *(Durum: APPROVED initial preference.)*

A controlled hard position correction after evidence capture is the simplest initial recovery strategy. *(Evidence capture sonrasında controlled hard position correction simplest initial recovery strategy’dir.)*

---

# 165. TD-141 — EKF Recovery Update (TD-141 — EKF Recovery Update)

**Status: TARGET CANDIDATE.** *(Durum: TARGET CANDIDATE.)*

An estimator-consistent absolute-position EKF measurement update should be compared against direct correction. *(Estimator-consistent absolute-position EKF measurement update direct correction’a karşı compare edilmelidir.)*

---

# 166. TD-142 — Recovery Heading Reset (TD-142 — Recovery Heading Reset)

**Status: REJECTED.** *(Durum: REJECTED.)*

GNSS movement or travel bearing must never correct, reset, replace, or initialize phone/body heading during recovery. No manual action, justification, recovery condition, gate, operator action, controller decision, or non-default path can authorize it as a phone-heading input. *(GNSS movement veya travel bearing recovery sırasında phone/body heading’i hiçbir zaman düzeltemez, resetleyemez, değiştiremez veya initialize edemez. Hiçbir manual action, justification, recovery condition, gate, operator action, controller decision veya non-default path bu bilgiyi phone-heading input olarak authorize edemez.)*

---

# 167. TD-143 — Recovery Covariance Reset to Zero (TD-143 — Recovery Covariance Reset to Zero)

**Status: REJECTED.** *(Durum: REJECTED.)*

Recovery never resets covariance to zero. *(Recovery covariance’i hiçbir zaman zero’ya reset etmez.)*

---

# 168. TD-144 — Multiple Anchors (TD-144 — Multiple Anchors)

**Status: OPTIONAL / APPROVED architecture.** *(Durum: OPTIONAL / APPROVED architecture.)*

Multiple anchors may be versioned when re-anchoring is used, while historical points retain their original anchor identity. *(Re-anchoring kullanıldığında multiple anchor versioned olabilir ve historical point’ler original anchor identity’lerini retain eder.)*

---

# 169. TD-145 — Map Role (TD-145 — Map Rolü)

**Status: FROZEN.** *(Durum: FROZEN.)*

Map rendering consumes estimator output but does not feed estimator state. *(Map rendering estimator output’u consume eder ancak estimator state’e feed etmez.)*

---

# 170. TD-146 — Hidden Map Matching (TD-146 — Hidden Map Matching)

**Status: REJECTED.** *(Durum: REJECTED.)*

Hidden road snapping or map matching is forbidden in the current benchmark estimator. *(Hidden road snapping veya map matching current benchmark estimator’da forbidden’dır.)*

---

# 171. TD-147 — UI Smoothing (TD-147 — UI Smoothing)

**Status: OPTIONAL.** *(Durum: OPTIONAL.)*

Visual-only trajectory smoothing may be used if it does not modify logged estimator states or benchmark metrics. *(Visual-only trajectory smoothing logged estimator state’leri veya benchmark metric’lerini modify etmiyorsa kullanılabilir.)*

---

# 172. TD-148 — Storage Architecture (TD-148 — Storage Architecture)

**Status: FROZEN.** *(Durum: FROZEN.)*

NAVGUARD uses hybrid storage with SQLite metadata, append-oriented scientific streams, and JSON manifests. *(NAVGUARD SQLite metadata, append-oriented scientific stream’ler ve JSON manifest’lerle hybrid storage kullanır.)*

---

# 173. TD-149 — Raw Sensor Samples in SQLite (TD-149 — Raw Sensor Sample’ların SQLite’ta Tutulması)

**Status: REJECTED as default.** *(Durum: Default olarak REJECTED.)*

High-frequency sensor samples are not written as individual SQLite transactions. *(High-frequency sensor sample’lar individual SQLite transaction olarak written edilmez.)*

---

# 174. TD-150 — Raw Recording Mutability (TD-150 — Raw Recording Mutability)

**Status: FROZEN.** *(Durum: FROZEN.)*

Successfully finalized raw recordings are immutable. *(Successfully finalized raw recording’ler immutable’dır.)*

---

# 175. TD-151 — Processed Output Versioning (TD-151 — Processed Output Versioning)

**Status: FROZEN.** *(Durum: FROZEN.)*

Processed and replay outputs are versioned separately from raw data. *(Processed ve replay output’ları raw data’dan separately versioned edilir.)*

---

# 176. TD-152 — Replay Isolation (TD-152 — Replay Isolation)

**Status: FROZEN.** *(Durum: FROZEN.)*

Replay never writes into the raw session directory. *(Replay hiçbir zaman raw session directory’ye write etmez.)*

---

# 177. TD-153 — Logging Writer Ownership (TD-153 — Logging Writer Ownership)

**Status: FROZEN.** *(Durum: FROZEN.)*

Timing-critical raw logging remains close to native acquisition and uses asynchronous disk I/O. *(Timing-critical raw logging native acquisition’a close kalır ve asynchronous disk I/O kullanır.)*

---

# 178. TD-154 — Sensor Callback Blocking (TD-154 — Sensör Callback Blocking)

**Status: REJECTED.** *(Durum: REJECTED.)*

Sensor callbacks must not perform blocking disk writes. *(Sensor callback’lar blocking disk write gerçekleştirmemelidir.)*

---

# 179. TD-155 — Writer Queue (TD-155 — Writer Queue)

**Status: FROZEN.** *(Durum: FROZEN.)*

Logging queues must be bounded. *(Logging queue’lar bounded olmalıdır.)*

---

# 180. TD-156 — Silent Log Drops (TD-156 — Silent Log Drop’lar)

**Status: REJECTED.** *(Durum: REJECTED.)*

Dropped records must be counted and may affect session validity. *(Dropped record’lar counted edilmelidir ve session validity’yi affect edebilir.)*

---

# 181. TD-157 — Formal Benchmark Mandatory Log Target (TD-157 — Formal Benchmark Mandatory Log Hedefi)

**Status: FROZEN as target.** *(Durum: Target olarak FROZEN.)*

Mandatory benchmark streams target zero dropped records. *(Mandatory benchmark stream’leri zero dropped record target eder.)*

---

# 182. TD-158 — Active Compression (TD-158 — Active Compression)

**Status: DEFERRED by default.** *(Durum: Default olarak DEFERRED.)*

Active-session compression is not required unless profiling shows a storage bottleneck. *(Active-session compression profiling storage bottleneck göstermezse required değildir.)*

---

# 183. TD-159 — Session Lifecycle (TD-159 — Session Lifecycle)

**Status: FROZEN.** *(Durum: FROZEN.)*

Sessions use explicit creation, preparation, recording, stopping, finalization, completion, and failure states. *(Session’lar explicit creation, preparation, recording, stopping, finalization, completion ve failure state’lerini kullanır.)*

---

# 184. TD-160 — Interrupted Session Handling (TD-160 — Interrupted Session Handling)

**Status: FROZEN.** *(Durum: FROZEN.)*

A crashed or interrupted session may not silently become `COMPLETED`. *(Crashed veya interrupted session silently `COMPLETED` olamaz.)*

---

# 185. TD-161 — Session Purpose Classification (TD-161 — Session Purpose Classification)

**Status: FROZEN.** *(Durum: FROZEN.)*

Sessions distinguish development, calibration, pilot, final benchmark, stress, and demo purpose. *(Session’lar development, calibration, pilot, final benchmark, stress ve demo purpose’larını distinguish eder.)*

---

# 186. TD-162 — Session Manifest (TD-162 — Session Manifest)

**Status: FROZEN.** *(Durum: FROZEN.)*

Formal sessions preserve configuration, build, model, file inventory, counts, warnings, and integrity metadata in a manifest. *(Formal session’lar configuration, build, model, file inventory, count, warning ve integrity metadata’yı manifest içerisinde preserve eder.)*

---

# 187. TD-163 — Scientific Stream Format (TD-163 — Scientific Stream Format)

**Status: APPROVED initial implementation.** *(Durum: Initial implementation olarak APPROVED.)*

CSV is preferred for high-frequency research-readable streams, with NDJSON suitable for sparse events. *(CSV high-frequency research-readable stream’ler için preferred’dır; NDJSON sparse event’ler için suitable’dır.)*

---

# 188. TD-164 — Binary Storage (TD-164 — Binary Storage)

**Status: DEFERRED / PENDING_EVIDENCE.** *(Durum: DEFERRED / PENDING_EVIDENCE.)*

A binary format is considered only if measured storage or throughput limitations justify the added complexity. *(Binary format yalnızca measured storage veya throughput limitation added complexity’yi justify ederse considered edilir.)*

---

# 189. TD-165 — Replay Requirement (TD-165 — Replay Gereksinimi)

**Status: FROZEN.** *(Durum: FROZEN.)*

Replay is mandatory for reproducible estimator comparison. *(Replay reproducible estimator comparison için mandatory’dir.)*

---

# 190. TD-166 — Replay Determinism (TD-166 — Replay Determinism)

**Status: FROZEN.** *(Durum: FROZEN.)*

The same source session and configuration should reproduce identical or numerically equivalent outputs within tolerance. *(Aynı source session ve configuration tolerance içerisinde identical veya numerically equivalent output reproduce etmelidir.)*

---

# 191. TD-167 — Replay Ground Truth Firewall (TD-167 — Replay Ground Truth Firewall)

**Status: CRITICAL FROZEN.** *(Durum: CRITICAL FROZEN.)*

Replay enforces the same authorization rules as live execution. *(Replay live execution ile aynı authorization rule’larını enforce eder.)*

---

# 192. TD-168 — Evaluation Configurations (TD-168 — Evaluation Configuration’ları)

**Status: FROZEN.** *(Durum: FROZEN.)*

Final research uses Configurations A, B, C, and D. *(Final research Configuration A, B, C ve D’yi kullanır.)*

---

# 193. TD-169 — Configuration A (TD-169 — Configuration A)

**Status: FROZEN.** *(Durum: FROZEN.)*

Configuration A is the deterministic PDR baseline. It uses deterministic step detection, mandatory baseline step length, and the baseline true-north heading policy. It does not enable improved/fused heading, Motion AI navigation influence, ARCore relative tracking, full Quality Engine behavior, or fusion corrections. *(Configuration A deterministic PDR baseline'dır. Deterministic step detection, mandatory baseline step length ve baseline true-north heading policy kullanır. Improved/fused heading, Motion AI navigation influence, ARCore relative tracking, full Quality Engine behavior veya fusion correction etkinleştirmez.)*

---

# 194. TD-170 — Configuration B (TD-170 — Configuration B)

**Status: FROZEN at conceptual level.** *(Durum: Conceptual level’da FROZEN.)*

Configuration B is Configuration A plus the improved/fused heading method. All other Configuration A component policies remain unchanged. *(Configuration B, Configuration A'ya improved/fused heading method ekler. Diğer tüm Configuration A component policy'leri değişmeden kalır.)*

---

# 195. TD-171 — Configuration C (TD-171 — Configuration C)

**Status: FROZEN at conceptual level.** *(Durum: Conceptual level’da FROZEN.)*

Configuration C is Configuration A plus validated ARCore relative tracking. It preserves Configuration A's baseline heading, deterministic step detector, and baseline step-length policy; Configuration B's improved/fused heading is not enabled. Any minimum integration mechanism required for formal ARCore use is evidence-gated and must be explicitly documented without silently enabling other Configuration D components. *(Configuration C, Configuration A'ya validated ARCore relative tracking ekler. Configuration A'nın baseline heading, deterministic step detector ve baseline step-length policy'sini korur; Configuration B'nin improved/fused heading'i etkinleştirilmez. Formal ARCore kullanımı için gereken minimum integration mechanism evidence-gated'dir ve diğer Configuration D component'lerini sessizce etkinleştirmeden açıkça dokümante edilmelidir.)*

---

# 196. TD-172 — Configuration D (TD-172 — Configuration D)

**Status: FROZEN at conceptual level.** *(Durum: Conceptual level’da FROZEN.)*

Configuration D represents the full frozen NAVGUARD AI-assisted, quality-aware fusion configuration. Evidence-gated optional components are included only if retained in the frozen final component set before final benchmark collection. *(Configuration D tam frozen NAVGUARD AI-assisted, quality-aware fusion configuration'ını temsil eder. Evidence-gated optional component'ler yalnızca final benchmark collection öncesinde frozen final component set içerisinde tutulmuşsa dahil edilir.)*

| Component | Configuration A | Configuration B | Configuration C | Configuration D |
|---|---|---|---|---|
| Deterministic step detection | ON | ON | SAME AS BASELINE | ON |
| Baseline step length / mandatory fallback | ON | ON | SAME AS BASELINE | ON |
| Baseline heading | ON | ON — retained as fallback/reference | SAME AS BASELINE | ON — retained as fallback/reference |
| Improved/fused heading | OFF | ON | OFF | ON |
| Motion AI navigation influence | OFF | OFF | OFF | ON |
| ARCore relative tracking | OFF | OFF | EVIDENCE-GATED — ON only after validation | EVIDENCE-GATED — included only if retained before freeze |
| Full Quality Engine behavior | OFF | OFF | OFF — source-local hard validity checks still apply | ON |
| EKF/fusion | OFF | OFF | EVIDENCE-GATED — only the minimum mechanism required for validated ARCore integration | ON |
| GNSS estimator updates during denied interval | NOT AUTHORIZED | NOT AUTHORIZED | NOT AUTHORIZED | NOT AUTHORIZED |
| Protected GNSS evaluation logging | ON | ON | ON | ON |

Common timestamp, hard-validity, Ground Truth Firewall, logging, and replay-integrity checks apply to every configuration and do not count as full Quality Engine or fusion enablement. *(Ortak timestamp, hard-validity, Ground Truth Firewall, logging ve replay-integrity kontrolleri her configuration'a uygulanır ve full Quality Engine veya fusion enablement olarak sayılmaz.)*

The existing documentation requires a validated true-north reference for ARCore-to-ENU alignment but does not require Configuration B's improved/fused heading. Configuration A's validated baseline heading is therefore preserved in Configuration C. *(Mevcut dokümantasyon ARCore-to-ENU alignment için validated true-north reference gerektirir ancak Configuration B improved/fused heading'ini zorunlu kılmaz. Bu nedenle Configuration A'nın validated baseline heading'i Configuration C'de korunur.)*

If formal Configuration C integration uses the minimum EKF, that dependency must be frozen explicitly and must not enable improved heading, Motion AI, learned step length, or other Configuration D behavior. *(Formal Configuration C integration minimum EKF kullanırsa bu dependency açık biçimde frozen edilmeli ve improved heading, Motion AI, learned step length veya başka Configuration D davranışını etkinleştirmemelidir.)*

---

# 197. TD-173 — Matched Replay (TD-173 — Matched Replay)

**Status: FROZEN.** *(Durum: FROZEN.)*

The same physical session should feed A, B, C, and D whenever the required evidence is available. *(Required evidence available olduğunda same physical session A, B, C ve D’yi feed etmelidir.)*

---

# 198. TD-174 — Primary Research Question (TD-174 — Primary Research Question)

**Status: FROZEN.** *(Durum: FROZEN.)*

The primary question asks whether AI-assisted PDR and visual-inertial fusion reduce drift relative to PDR-only baseline during simulated GNSS outages. *(Primary question simulated GNSS outage sırasında AI-assisted PDR ve visual-inertial fusion’ın PDR-only baseline’a göre drift’i reduce edip etmediğini sorar.)*

---

# 199. TD-175 — Primary Research Metric (TD-175 — Primary Research Metric)

**Status: FROZEN.** *(Durum: FROZEN.)*

Aggregated matched-session median horizontal position error is the primary comparison metric. *(Aggregated matched-session median horizontal position error primary comparison metric’tir.)*

---

# 200. TD-176 — Primary Research Target (TD-176 — Primary Research Hedefi)

**Status: FROZEN as target.** *(Durum: Target olarak FROZEN.)*

Configuration D targets at least `20%` reduction relative to Configuration A. *(Configuration D Configuration A’ya göre en az `20%` reduction target eder.)*

---

# 201. TD-177 — Secondary Position Metrics (TD-177 — Secondary Position Metrics)

**Status: FROZEN.** *(Durum: FROZEN.)*

Mean error, RMSE, P95 error, final pre-correction error, drift per time, and drift per distance are secondary position metrics. *(Mean error, RMSE, P95 error, final pre-correction error, drift per time ve drift per distance secondary position metric’leridir.)*

---

# 202. TD-178 — Final Denied Error Timing (TD-178 — Final Denied Error Timing)

**Status: CRITICAL FROZEN.** *(Durum: CRITICAL FROZEN.)*

Final denied-navigation error is measured immediately before recovery correction. *(Final denied-navigation error recovery correction’dan immediately before measured edilir.)*

---

# 203. TD-179 — Post-Relocalization Error as Benchmark Metric (TD-179 — Post-Relocalization Error’ın Benchmark Metric Olması)

**Status: REJECTED.** *(Durum: REJECTED.)*

Post-relocalization position cannot be used as final denied-navigation accuracy. *(Post-relocalization position final denied-navigation accuracy olarak kullanılamaz.)*

---

# 204. TD-180 — Primary Aggregation Level (TD-180 — Primary Aggregation Level)

**Status: FROZEN.** *(Durum: FROZEN.)*

Required session-level position metrics are calculated per physical session before cross-session aggregation of the single project-level primary research metric. *(Gerekli session-level position metric'leri tek project-level primary research metric'in cross-session aggregation'ı öncesinde her physical session için hesaplanır.)*

---

# 205. TD-181 — Sample-Level Pooling Dominance (TD-181 — Sample-Level Pooling Dominance)

**Status: REJECTED for primary aggregation.** *(Durum: Primary aggregation için REJECTED.)*

Long sessions may not dominate the primary metric simply because they contain more timestamp samples. *(Long session’lar simply daha fazla timestamp sample içerdikleri için primary metric’e dominate edemez.)*

---

# 206. TD-182 — Route Families (TD-182 — Route Family’leri)

**Status: FROZEN.** *(Durum: FROZEN.)*

Principal routes include straight, turn-heavy, and closed or near-closed geometry. *(Principal route’lar straight, turn-heavy ve closed veya near-closed geometry içerir.)*

---

# 207. TD-183 — Route Repeat Target (TD-183 — Route Repeat Hedefi)

**Status: PROVISIONAL TARGET.** *(Durum: PROVISIONAL TARGET.)*

The preferred field target is at least three valid repeats for each principal route category where practical. *(Preferred field target practical olduğunda each principal route category için en az three valid repeat’tir.)*

---

# 208. TD-184 — Valid Poor Sessions (TD-184 — Valid Poor Session’lar)

**Status: FROZEN.** *(Durum: FROZEN.)*

Scientifically valid poor-performing sessions remain in the benchmark. *(Scientifically valid poor-performing session’lar benchmark içerisinde kalır.)*

---

# 209. TD-185 — Result-Based Exclusion (TD-185 — Result-Based Exclusion)

**Status: REJECTED.** *(Durum: REJECTED.)*

High navigation error is not itself a valid session-exclusion reason. *(High navigation error tek başına valid session-exclusion reason değildir.)*

---

# 210. TD-186 — Exclusion Rules (TD-186 — Exclusion Rule’ları)

**Status: FROZEN at governance level.** *(Durum: Governance level’da FROZEN.)*

Session exclusions must follow predefined integrity or reference-quality criteria. *(Session exclusion’ları predefined integrity veya reference-quality criterion’larını follow etmelidir.)*

---

# 211. TD-187 — Benchmark Freeze (TD-187 — Benchmark Freeze)

**Status: FROZEN.** *(Durum: FROZEN.)*

Final build, models, routes, inclusion rules, parameters, and metric pipeline freeze before final benchmark collection. *(Final build, model’ler, route’lar, inclusion rule’ları, parameter’lar ve metric pipeline final benchmark collection öncesinde freeze edilir.)*

---

# 212. TD-188 — Post-Freeze Tuning (TD-188 — Post-Freeze Tuning)

**Status: REJECTED.** *(Durum: REJECTED.)*

Final benchmark results may not be used to tune the frozen estimator. *(Final benchmark result’ları frozen estimator’ı tune etmek için kullanılamaz.)*

---

# 213. TD-189 — Research Outcome Categories (TD-189 — Research Outcome Category’leri)

**Status: FROZEN.** *(Durum: FROZEN.)*

Final outcomes are reported as `TARGET_MET`, `PARTIAL_IMPROVEMENT`, `NO_MEASURABLE_IMPROVEMENT`, `REGRESSION`, or `INCONCLUSIVE`. *(Final outcome’lar `TARGET_MET`, `PARTIAL_IMPROVEMENT`, `NO_MEASURABLE_IMPROVEMENT`, `REGRESSION` veya `INCONCLUSIVE` olarak raporlanır.)*

---

# 214. TD-190 — Software Completion vs Research Success (TD-190 — Software Completion vs Research Success)

**Status: FROZEN.** *(Durum: FROZEN.)*

Software Definition of Done and research-target achievement are separate outcomes. *(Software Definition of Done ve research-target achievement separate outcome’lardır.)*

---

# 215. TD-191 — Negative Research Result (TD-191 — Negative Research Result)

**Status: FROZEN.** *(Durum: FROZEN.)*

A valid negative or partial result does not make the software prototype technically incomplete. *(Valid negative veya partial result software prototype’ı technically incomplete yapmaz.)*

---

# 216. TD-192 — Final Results Before Measurement (TD-192 — Ölçüm Öncesi Final Sonuçlar)

**Status: REJECTED.** *(Durum: REJECTED.)*

No unmeasured final result may be fabricated or pre-filled. *(Hiçbir unmeasured final result fabricate veya pre-filled edilemez.)*

---

# 217. TD-193 — Result Placeholder Policy (TD-193 — Result Placeholder Politikası)

**Status: FROZEN.** *(Durum: FROZEN.)*

Unmeasured Page 41 values remain `TBD`. *(Unmeasured Page 41 value’ları `TBD` olarak kalır.)*

---

# 218. TD-194 — Uncertainty Representation (TD-194 — Uncertainty Representation)

**Status: FROZEN.** *(Durum: FROZEN.)*

Position uncertainty is reported separately from position estimate and separately from observed error. *(Position uncertainty position estimate’den ve observed error’dan separately raporlanır.)*

---

# 219. TD-195 — Formal 95% Confidence Claim (TD-195 — Formal 95% Confidence Claim)

**Status: EVIDENCE-GATED.** *(Durum: EVIDENCE-GATED.)*

A formal 95% uncertainty ellipse may only be claimed when calibration supports the probabilistic interpretation. *(Formal 95% uncertainty ellipse yalnızca calibration probabilistic interpretation’ı support ettiğinde claim edilebilir.)*

---

# 220. TD-196 — Approximate Chi-Square Ellipse Constant (TD-196 — Approximate Chi-Square Ellipse Constant)

**Status: APPROVED mathematical reference only.** *(Durum: Yalnızca mathematical reference olarak APPROVED.)*

The common two-dimensional 95% chi-square scaling value may be used only when the covariance interpretation is justified. *(Common two-dimensional 95% chi-square scaling value yalnızca covariance interpretation justified olduğunda kullanılabilir.)*

---

# 221. TD-197 — Performance Evaluation Device (TD-197 — Performans Evaluation Device)

**Status: FROZEN.** *(Durum: FROZEN.)*

Formal runtime measurements are performed on the Xiaomi Redmi Note 9 Pro. *(Formal runtime measurement’lar Xiaomi Redmi Note 9 Pro üzerinde gerçekleştirilir.)*

---

# 222. TD-198 — Debug Build as Final Performance Evidence (TD-198 — Debug Build’in Final Performance Evidence Olması)

**Status: REJECTED.** *(Durum: REJECTED.)*

Final performance conclusions may not rely solely on debug builds. *(Final performance conclusion’lar solely debug build’lere rely edemez.)*

---

# 223. TD-199 — Performance Dimensions (TD-199 — Performans Dimension’ları)

**Status: FROZEN.** *(Durum: FROZEN.)*

Performance evaluation covers AI latency, CPU, memory, logging throughput, storage growth, battery, thermal behavior, and stability. *(Performance evaluation AI latency, CPU, memory, logging throughput, storage growth, battery, thermal behavior ve stability’yi cover eder.)*

---

# 224. TD-200 — Composite Efficiency Score (TD-200 — Composite Efficiency Score)

**Status: REJECTED.** *(Durum: REJECTED.)*

Accuracy and resource cost are not collapsed into one subjective composite score. *(Accuracy ve resource cost tek subjective composite score’a collapse edilmez.)*

---

# 225. TD-201 — Endurance Test (TD-201 — Endurance Test)

**Status: FROZEN as required test.** *(Durum: Required test olarak FROZEN.)*

At least one dedicated full-stack endurance test is required before final acceptance. *(Final acceptance öncesinde en az one dedicated full-stack endurance test required’dır.)*

---

# 226. TD-202 — Failure Injection (TD-202 — Failure Injection)

**Status: FROZEN.** *(Durum: FROZEN.)*

Failure injection is a mandatory verification activity. *(Failure injection mandatory verification activity’dir.)*

---

# 227. TD-203 — Failure Injection Scope (TD-203 — Failure Injection Scope)

**Status: APPROVED.** *(Durum: APPROVED.)*

AI failure, ARCore loss, stale sensors, bad recovery fixes, logging slowdown, permission loss, and GNSS injection attempts are included in the failure suite. *(AI failure, ARCore loss, stale sensor’lar, bad recovery fix’ler, logging slowdown, permission loss ve GNSS injection attempt’leri failure suite içerisinde yer alır.)*

---

# 228. TD-204 — No Safe Estimate Policy (TD-204 — Safe Estimate Yok Politikası)

**Status: FROZEN.** *(Durum: FROZEN.)*

When no defensible estimate remains, `UNRELIABLE` or `UNAVAILABLE` is preferable to fabricated confident motion. *(Defensible estimate kalmadığında `UNRELIABLE` veya `UNAVAILABLE`, fabricated confident motion’dan preferable’dır.)*

---

# 229. TD-205 — App-Private Storage Preference (TD-205 — App-Private Storage Tercihi)

**Status: APPROVED candidate.** *(Durum: APPROVED candidate.)*

Sensitive research evidence should prefer app-specific private storage unless implementation constraints require another controlled option. *(Sensitive research evidence implementation constraint başka controlled option gerektirmedikçe app-specific private storage’u prefer etmelidir.)*

---

# 230. TD-206 — Public Shared Storage Default (TD-206 — Public Shared Storage Default)

**Status: REJECTED.** *(Durum: REJECTED.)*

Sensitive GNSS research logs are not stored in public shared storage by default. *(Sensitive GNSS research log’ları default olarak public shared storage’da stored edilmez.)*

---

# 231. TD-207 — Raw Camera Recording (TD-207 — Raw Kamera Recording)

**Status: REJECTED by default.** *(Durum: Default olarak REJECTED.)*

Raw camera frames are not continuously recorded for the current research pipeline. *(Raw camera frame’leri current research pipeline için continuously recorded edilmez.)*

---

# 232. TD-208 — Participant Identity (TD-208 — Participant Identity)

**Status: FROZEN.** *(Durum: FROZEN.)*

Participant codes are preferred over unnecessary personal identifiers. *(Participant code’ları unnecessary personal identifier’lara göre preferred’dır.)*

---

# 233. TD-209 — Single-Participant Initial Scope (TD-209 — Tek Participant Initial Scope)

**Status: APPROVED limitation.** *(Durum: APPROVED limitation.)*

The initial controlled dataset may primarily use one participant, but no population-generalization claim may follow from that design. *(Initial controlled dataset primarily one participant kullanabilir ancak bu design’dan population-generalization claim yapılamaz.)*

---

# 234. TD-210 — Controlled Phone Placement (TD-210 — Controlled Telefon Placement)

**Status: FROZEN for final benchmark.** *(Durum: Final benchmark için FROZEN.)*

Final principal benchmark sessions use one predefined controlled phone placement. *(Final principal benchmark session’ları one predefined controlled phone placement kullanır.)*

---

# 235. TD-211 — Multi-Placement Robustness (TD-211 — Multi-Placement Robustness)

**Status: DEFERRED.** *(Durum: DEFERRED.)*

Broad multi-placement robustness is future work and not part of minimum completion. *(Broad multi-placement robustness future work’tür ve minimum completion’ın parçası değildir.)*

---

# 236. TD-212 — Final Benchmark Session Purpose (TD-212 — Final Benchmark Session Purpose)

**Status: FROZEN.** *(Durum: FROZEN.)*

Final benchmark sessions must remain distinguishable from development, pilot, calibration, stress, and demo sessions. *(Final benchmark session’ları development, pilot, calibration, stress ve demo session’larından distinguishable kalmalıdır.)*

---

# 237. TD-213 — Demo Data as Benchmark Data (TD-213 — Demo Data’nın Benchmark Data Olması)

**Status: REJECTED by default.** *(Durum: Default olarak REJECTED.)*

Demo sessions do not silently enter the final benchmark dataset. *(Demo session’ları final benchmark dataset’e silently girmez.)*

---

# 238. TD-214 — Live Demo Ground Truth Visibility (TD-214 — Live Demo Ground Truth Görünürlüğü)

**Status: FROZEN.** *(Durum: FROZEN.)*

Protected GNSS ground truth remains hidden during the blinded live denied interval. *(Protected GNSS ground truth blinded live denied interval sırasında hidden kalır.)*

---

# 239. TD-215 — Demo Backup Order (TD-215 — Demo Backup Sırası)

**Status: APPROVED.** *(Durum: APPROVED.)*

Preferred fallback order is live physical demo, valid-session replay, and then clearly labeled pre-recorded demonstration. *(Preferred fallback order live physical demo, valid-session replay ve ardından clearly labeled pre-recorded demonstration’dır.)*

---

# 240. TD-216 — Presentation Primary Evidence (TD-216 — Sunum Primary Evidence)

**Status: FROZEN.** *(Durum: FROZEN.)*

Benchmark results remain the primary proof of performance rather than one live demonstration. *(Benchmark result’ları one live demonstration yerine primary proof of performance olarak kalır.)*

---

# 241. TD-217 — Presentation Primary Comparison (TD-217 — Sunum Primary Comparison)

**Status: FROZEN.** *(Durum: FROZEN.)*

Configuration A versus Configuration D is the primary result comparison in the main presentation. *(Configuration A versus Configuration D main presentation’daki primary result comparison’dır.)*

---

# 242. TD-218 — Target Before Result (TD-218 — Sonuçtan Önce Target)

**Status: FROZEN.** *(Durum: FROZEN.)*

The `≥20%` research target is shown before the final measured improvement is revealed. *(`≥20%` research target final measured improvement revealed edilmeden önce gösterilir.)*

---

# 243. TD-219 — Limitations Before Conclusion (TD-219 — Conclusion Öncesi Limitations)

**Status: FROZEN.** *(Durum: FROZEN.)*

Material limitations are presented before the final conclusion. *(Material limitation’lar final conclusion öncesinde presented edilir.)*

---

# 244. TD-220 — Military-Grade Claim (TD-220 — Military-Grade Claim)

**Status: REJECTED.** *(Durum: REJECTED.)*

NAVGUARD is not described as military-grade navigation. *(NAVGUARD military-grade navigation olarak described edilmez.)*

---

# 245. TD-221 — Permanent GNSS Replacement Claim (TD-221 — Permanent GNSS Replacement Claim)

**Status: REJECTED.** *(Durum: REJECTED.)*

NAVGUARD is not described as a permanent GNSS replacement. *(NAVGUARD permanent GNSS replacement olarak described edilmez.)*

---

# 246. TD-222 — Certified Navigation Claim (TD-222 — Certified Navigation Claim)

**Status: REJECTED.** *(Durum: REJECTED.)*

The prototype is not presented as certified safety-critical navigation. *(Prototype certified safety-critical navigation olarak presented edilmez.)*

---

# 247. TD-223 — Cross-Device Generalization (TD-223 — Cross-Device Generalization)

**Status: REJECTED for initial claims.** *(Durum: Initial claim’ler için REJECTED.)*

Results from the Redmi Note 9 Pro do not automatically generalize to all Android phones. *(Redmi Note 9 Pro’dan result’lar all Android phone’lara automatically generalize edilmez.)*

---

# 248. TD-224 — Population Generalization (TD-224 — Population Generalization)

**Status: REJECTED for initial claims.** *(Durum: Initial claim’ler için REJECTED.)*

A limited participant study does not support broad population-level claims. *(Limited participant study broad population-level claim’leri support etmez.)*

---

# 249. TD-225 — Smartphone GNSS Ground Truth Interpretation (TD-225 — Smartphone GNSS Ground Truth Yorumu)

**Status: FROZEN.** *(Durum: FROZEN.)*

Smartphone GNSS is treated as an imperfect protected evaluation reference rather than survey-grade physical truth. *(Smartphone GNSS survey-grade physical truth yerine imperfect protected evaluation reference olarak treated edilir.)*

---

# 250. TD-226 — Future Work Prioritization (TD-226 — Future Work Prioritization)

**Status: FROZEN.** *(Durum: FROZEN.)*

Future work priorities are selected from measured bottlenecks after Page 41 results rather than from architectural enthusiasm alone. *(Future work priority’leri architectural enthusiasm alone yerine Page 41 result’ları sonrasında measured bottleneck’lerden selected edilir.)*

---

# 251. TD-227 — Page 03 Documentation Gap Closure (TD-227 — Page 03 Dokümantasyon Boşluğunun Kapatılması)

**Status: RESOLVED DOCUMENTATION UPDATE.** *(Durum: RESOLVED DOCUMENTATION UPDATE.)*

`03 — Project Scope & Boundaries` exists in the repository, contains substantive scope and boundary definitions, and is marked completed. The earlier statement that Page 03 was missing or unwritten is stale and is superseded by the current repository state. *(`03 — Project Scope & Boundaries` repository'de mevcuttur, substantive scope ve boundary tanımları içerir ve completed olarak işaretlenmiştir. Page 03'ün missing veya unwritten olduğunu belirten eski ifade stale'dir ve current repository state tarafından supersede edilmiştir.)*

---

# 252. TD-228 — Page 03 Architecture Consistency (TD-228 — Page 03 Architecture Tutarlılığı)

**Status: DOCUMENTATION CONSISTENCY CONFIRMED.** *(Durum: DOCUMENTATION CONSISTENCY CONFIRMED.)*

The completed Page 03 is consistent with the current pre-implementation architecture and does not alter or invalidate the frozen technical decisions recorded in this page. *(Tamamlanmış Page 03 current pre-implementation architecture ile tutarlıdır ve bu page'deki frozen technical decision'ları değiştirmez veya geçersiz kılmaz.)*

---

# 253. Core Decision Summary Matrix (Temel Karar Özet Matrisi)

| Decision Area (Karar Alanı)                                                 | Authoritative Decision (Authoritative Karar)                        | Status (Durum)  |
| --------------------------------------------------------------------------- | ------------------------------------------------------------------- | --------------- |
| Platform *(Platform)*                                                       | Android only *(Yalnızca Android)*                                   | FROZEN          |
| Device *(Cihaz)*                                                            | Xiaomi Redmi Note 9 Pro                                             | FROZEN          |
| Internal Frame *(Internal Frame)*                                           | ENU                                                                 | FROZEN          |
| Heading *(Heading)*                                                         | True north, clockwise *(True north, clockwise)*                     | FROZEN          |
| PDR *(PDR)*                                                                 | Step-event driven *(Step-event driven)*                             | FROZEN          |
| Raw acceleration double integration *(Raw acceleration double integration)* | Rejected *(Reddedildi)*                                             | REJECTED        |
| Motion AI *(Motion AI)*                                                     | Mandatory four-class classifier *(Mandatory four-class classifier)* | FROZEN          |
| Step-Length ML *(Step-Length ML)*                                           | Evidence-gated *(Evidence-gated)*                                   | OPTIONAL        |
| ARCore *(ARCore)*                                                           | Relative source, PDR fallback *(Relative source, PDR fallback)*     | FROZEN          |
| EKF state *(EKF state)*                                                     | `[E,N,ψ]`                                                           | FROZEN          |
| Quality states *(Quality state’leri)*                                       | `UNKNOWN/GOOD/USABLE/DEGRADED/UNRELIABLE/UNAVAILABLE`               | FROZEN          |
| GNSS denied GT *(GNSS denied GT)*                                           | Logged but blocked *(Loglanır ancak blocked)*                       | CRITICAL FROZEN |
| Map *(Map)*                                                                 | Visualization only *(Yalnızca visualization)*                       | FROZEN          |
| Replay *(Replay)*                                                           | Mandatory *(Zorunlu)*                                               | FROZEN          |
| Primary comparison *(Primary comparison)*                                   | A vs D                                                              | FROZEN          |
| Primary target *(Primary target)*                                           | `≥20%` median-error reduction                                       | FROZEN TARGET   |

---

# 254. Pending Decision Registry (Bekleyen Kararlar Registry)

The following decisions still require measured evidence before final freeze. *(Aşağıdaki decision’lar final freeze öncesinde measured evidence gerektirir.)*

---

# 255. PD-001 — Final Sensor Request Rates (PD-001 — Final Sensör Request Rate’leri)

**Status: PENDING_EVIDENCE.** *(Durum: PENDING_EVIDENCE.)*

Exact requested sensor rates must be selected after physical device-rate and workload testing. *(Exact requested sensor rate’leri physical device-rate ve workload testing sonrasında selected edilmelidir.)*

---

# 256. PD-002 — Final Step Detector Thresholds (PD-002 — Final Step Detector Threshold’ları)

**Status: PENDING_EVIDENCE.** *(Durum: PENDING_EVIDENCE.)*

Peak threshold, filter parameters, and refractory timing require pilot calibration. *(Peak threshold, filter parameter’ları ve refractory timing pilot calibration gerektirir.)*

---

# 257. PD-003 — Final Heading Filter Parameters (PD-003 — Final Heading Filter Parameter’ları)

**Status: PENDING_EVIDENCE.** *(Durum: PENDING_EVIDENCE.)*

Gyroscope/magnetometer or Rotation Vector fusion weights require device evidence. *(Gyroscope/magnetometer veya Rotation Vector fusion weight’leri device evidence gerektirir.)*

---

# 258. PD-004 — Motion Window Configuration (PD-004 — Motion Window Configuration)

**Status: PENDING_EVIDENCE.** *(Durum: PENDING_EVIDENCE.)*

Final Motion Classification window duration and overlap will be selected using development data only. *(Final Motion Classification window duration ve overlap yalnızca development data kullanılarak selected edilecektir.)*

---

# 259. PD-005 — Final Motion Model (PD-005 — Final Motion Model)

**Status: PENDING_EVIDENCE.** *(Durum: PENDING_EVIDENCE.)*

Random Forest and 1D-CNN remain candidates until held-out evaluation and device-runtime evidence are available. *(Random Forest ve 1D-CNN held-out evaluation ve device-runtime evidence available olana kadar candidate olarak kalır.)*

---

# 260. PD-006 — Learned Step-Length Retention (PD-006 — Learned Step-Length Retention)

**Status: PENDING_EVIDENCE.** *(Durum: PENDING_EVIDENCE.)*

Learned step length will be retained or rejected after held-out downstream navigation comparison. *(Learned step length held-out downstream navigation comparison sonrasında retained veya rejected edilecektir.)*

---

# 261. PD-007 — ARCore Formal Fusion Enablement (PD-007 — ARCore Formal Fusion Enablement)

**Status: PENDING_EVIDENCE.** *(Durum: PENDING_EVIDENCE.)*

ARCore enters final fusion only if alignment, timing, tracking quality, and fallback behavior are validated. *(ARCore yalnızca alignment, timing, tracking quality ve fallback behavior validated edilirse final fusion’a girer.)*

---

# 262. PD-008 — Final Quality-to-Covariance Mapping (PD-008 — Final Quality-to-Covariance Mapping)

**Status: PENDING_EVIDENCE.** *(Durum: PENDING_EVIDENCE.)*

Exact uncertainty scaling requires calibration before benchmark freeze. *(Exact uncertainty scaling benchmark freeze öncesinde calibration gerektirir.)*

---

# 263. PD-009 — Final `Q` and `R` Values (PD-009 — Final `Q` ve `R` Values)

**Status: PENDING_EVIDENCE.** *(Durum: PENDING_EVIDENCE.)*

Process and measurement noise values must be calibrated with development and pilot evidence only. *(Process ve measurement noise value’ları yalnızca development ve pilot evidence ile calibrated edilmelidir.)*

---

# 264. PD-010 — Final NIS Threshold (PD-010 — Final NIS Threshold)

**Status: PENDING_EVIDENCE.** *(Durum: PENDING_EVIDENCE.)*

The final innovation-gate threshold must be chosen and frozen before final benchmark interpretation. *(Final innovation-gate threshold final benchmark interpretation öncesinde chosen ve frozen edilmelidir.)*

---

# 265. PD-011 — Recovery Stability Policy (PD-011 — Recovery Stability Politikası)

**Status: PENDING_EVIDENCE.** *(Durum: PENDING_EVIDENCE.)*

Final required fix count, stability window, and spread policy require pilot evidence. *(Final required fix count, stability window ve spread policy pilot evidence gerektirir.)*

---

# 266. PD-012 — Recovery Correction Method (PD-012 — Recovery Correction Yöntemi)

**Status: PENDING_EVIDENCE.** *(Durum: PENDING_EVIDENCE.)*

Direct hard correction and EKF measurement-update approaches should be compared before the final recovery policy is frozen. *(Direct hard correction ve EKF measurement-update approach’ları final recovery policy frozen edilmeden önce compare edilmelidir.)*

---

# 267. PD-013 — Re-Anchoring Policy (PD-013 — Re-Anchoring Politikası)

**Status: PENDING_EVIDENCE.** *(Durum: PENDING_EVIDENCE.)*

Whether recovery creates a new anchor remains dependent on implementation clarity and pilot behavior. *(Recovery’nin new anchor oluşturup oluşturmayacağı implementation clarity ve pilot behavior’a dependent olarak kalır.)*

---

# 268. PD-014 — ARCore Alignment Recovery Policy (PD-014 — ARCore Alignment Recovery Politikası)

**Status: PENDING_EVIDENCE.** *(Durum: PENDING_EVIDENCE.)*

ARCore alignment after GNSS relocalization requires physical testing. *(GNSS relocalization sonrasında ARCore alignment physical testing gerektirir.)*

---

# 269. PD-015 — Logging Queue Capacity (PD-015 — Logging Queue Capacity)

**Status: PENDING_EVIDENCE.** *(Durum: PENDING_EVIDENCE.)*

Exact bounded queue capacity depends on measured sensor and disk throughput. *(Exact bounded queue capacity measured sensor ve disk throughput’a bağlıdır.)*

---

# 270. PD-016 — Flush Interval (PD-016 — Flush Interval)

**Status: PENDING_EVIDENCE.** *(Durum: PENDING_EVIDENCE.)*

The final periodic flush policy requires performance and crash-loss tradeoff testing. *(Final periodic flush policy performance ve crash-loss tradeoff testing gerektirir.)*

---

# 271. PD-017 — Minimum Free Storage Threshold (PD-017 — Minimum Free Storage Threshold)

**Status: PENDING_EVIDENCE.** *(Durum: PENDING_EVIDENCE.)*

Formal session storage readiness threshold will be derived from measured data growth plus safety margin. *(Formal session storage readiness threshold measured data growth plus safety margin’den derive edilecektir.)*

---

# 272. PD-018 — Active Archive Compression (PD-018 — Active Archive Compression)

**Status: DEFERRED / PENDING_EVIDENCE.** *(Durum: DEFERRED / PENDING_EVIDENCE.)*

Compression policy will depend on measured storage needs and whether it affects acquisition performance. *(Compression policy measured storage need’lerine ve acquisition performance’ı affect edip etmediğine bağlı olacaktır.)*

---

# 273. PD-019 — Final App Storage Location (PD-019 — Final App Storage Location)

**Status: PENDING_IMPLEMENTATION.** *(Durum: PENDING_IMPLEMENTATION.)*

App-private storage is preferred, while exact Android storage placement will be finalized during implementation and privacy validation. *(App-private storage preferred’dır; exact Android storage placement implementation ve privacy validation sırasında finalize edilecektir.)*

---

# 274. PD-020 — Final Field Routes (PD-020 — Final Field Routes)

**Status: PENDING_PILOT.** *(Durum: PENDING_PILOT.)*

Exact route geometry, length, denial point, and recovery point will be frozen after pilot validation. *(Exact route geometry, length, denial point ve recovery point pilot validation sonrasında frozen edilecektir.)*

---

# 275. PD-021 — Final Phone Placement (PD-021 — Final Telefon Placement)

**Status: PENDING_PILOT.** *(Durum: PENDING_PILOT.)*

The controlled benchmark placement will be selected after practical pilot testing. *(Controlled benchmark placement practical pilot testing sonrasında selected edilecektir.)*

---

# 276. PD-022 — Exact Final AI Runtime Statistic (PD-022 — Exact Final AI Runtime Statistic)

**Status: PENDING_EVIDENCE.** *(Durum: PENDING_EVIDENCE.)*

The exact statistic used against the approximate 50 ms target must be frozen before final reporting. *(Approximately 50 ms target’a karşı kullanılan exact statistic final reporting öncesinde frozen edilmelidir.)*

---

# 277. PD-023 — Uncertainty Scalar for UI (PD-023 — UI için Uncertainty Scalar)

**Status: PENDING_EVIDENCE.** *(Durum: PENDING_EVIDENCE.)*

The exact scalar uncertainty displayed in UI remains pending calibration and usability evaluation. *(UI’da displayed exact scalar uncertainty calibration ve usability evaluation beklemektedir.)*

---

# 278. PD-024 — Formal Confidence Ellipse Label (PD-024 — Formal Confidence Ellipse Label)

**Status: PENDING_EVIDENCE.** *(Durum: PENDING_EVIDENCE.)*

A formal 95% label is enabled only if empirical calibration supports it. *(Formal 95% label yalnızca empirical calibration support ederse enabled edilir.)*

---

# 279. Rejected Alternatives Registry (Reddedilen Alternatifler Registry)

The following approaches are intentionally excluded from the current core design. *(Aşağıdaki approach’lar current core design’dan intentionally excluded edilmiştir.)*

---

# 280. RA-001 — Raw IMU Double Integration (RA-001 — Raw IMU Double Integration)

**Status: REJECTED.** *(Durum: REJECTED.)*

The architecture does not estimate long-term position by directly integrating raw accelerometer values twice. *(Architecture long-term position’ı raw accelerometer value’larını directly iki kez integrate ederek estimate etmez.)*

---

# 281. RA-002 — Automatic First GNSS Fix Anchor (RA-002 — Automatic First GNSS Fix Anchor)

**Status: REJECTED.** *(Durum: REJECTED.)*

The first callback does not automatically define the anchor. *(İlk callback anchor’ı automatically define etmez.)*

---

# 282. RA-003 — Ground Truth During Denial (RA-003 — Denial Sırasında Ground Truth Kullanımı)

**Status: REJECTED.** *(Durum: REJECTED.)*

Protected GNSS cannot update the denied estimator. *(Protected GNSS denied estimator’ı update edemez.)*

---

# 283. RA-004 — Hidden Road Snapping (RA-004 — Hidden Road Snapping)

**Status: REJECTED.** *(Durum: REJECTED.)*

Road geometry does not silently correct the benchmark estimator. *(Road geometry benchmark estimator’ı silently correct etmez.)*

---

# 284. RA-005 — ARCore Equals ENU (RA-005 — ARCore Equals ENU)

**Status: REJECTED.** *(Durum: REJECTED.)*

ARCore axes are not assumed to equal East/North/Up directly. *(ARCore axis’lerinin directly East/North/Up’a equal olduğu assumed edilmez.)*

---

# 285. RA-006 — ARCore as GPS (RA-006 — ARCore’un GPS Olarak Kullanılması)

**Status: REJECTED.** *(Durum: REJECTED.)*

ARCore is not treated as an absolute geographic positioning service. *(ARCore absolute geographic positioning service olarak treated edilmez.)*

---

# 286. RA-007 — `R = 1/confidence` (RA-007 — `R = 1/confidence`)

**Status: REJECTED.** *(Durum: REJECTED.)*

An arbitrary inverse-confidence covariance mapping is not accepted without calibration. *(Arbitrary inverse-confidence covariance mapping calibration olmadan accepted edilmez.)*

---

# 287. RA-008 — Post-Correction Final Error (RA-008 — Post-Correction Final Error)

**Status: REJECTED.** *(Durum: REJECTED.)*

Corrected recovery position is not used as final denied performance. *(Corrected recovery position final denied performance olarak kullanılmaz.)*

---

# 288. RA-009 — Random Window Train/Test Split (RA-009 — Random Window Train/Test Split)

**Status: REJECTED.** *(Durum: REJECTED.)*

Random splitting of windows from the same physical session is forbidden. *(Aynı physical session’dan window’ların random splitting’i forbidden’dır.)*

---

# 289. RA-010 — Model Training Accuracy as Final AI Result (RA-010 — Model Training Accuracy’nin Final AI Result Olması)

**Status: REJECTED.** *(Durum: REJECTED.)*

Training accuracy is not the primary final AI result. *(Training accuracy primary final AI result değildir.)*

---

# 290. RA-011 — AI as Navigation Single Point of Failure (RA-011 — AI’ın Navigation Single Point of Failure Olması)

**Status: REJECTED.** *(Durum: REJECTED.)*

Deterministic fallback must survive AI failure. *(Deterministic fallback AI failure’dan survive etmelidir.)*

---

# 291. RA-012 — ARCore as Mandatory Navigation Dependency (RA-012 — ARCore’un Mandatory Navigation Dependency Olması)

**Status: REJECTED.** *(Durum: REJECTED.)*

PDR must remain operational when ARCore is unavailable. *(ARCore unavailable olduğunda PDR operational kalmalıdır.)*

---

# 292. RA-013 — Covariance Reset to Zero on Recovery (RA-013 — Recovery’de Covariance Reset to Zero)

**Status: REJECTED.** *(Durum: REJECTED.)*

Recovery does not create artificial certainty. *(Recovery artificial certainty oluşturmaz.)*

---

# 293. RA-014 — Result-Based Session Exclusion (RA-014 — Result-Based Session Exclusion)

**Status: REJECTED.** *(Durum: REJECTED.)*

Poor NAVGUARD performance cannot be used as an exclusion reason. *(Poor NAVGUARD performance exclusion reason olarak kullanılamaz.)*

---

# 294. RA-015 — Final Benchmark Retuning (RA-015 — Final Benchmark Retuning)

**Status: REJECTED.** *(Durum: REJECTED.)*

Final benchmark results do not become tuning data. *(Final benchmark result’ları tuning data haline gelmez.)*

---

# 295. RA-016 — Uncalibrated Probability Claims (RA-016 — Uncalibrated Probability Claim’leri)

**Status: REJECTED.** *(Durum: REJECTED.)*

Uncalibrated model scores or covariance ellipses are not presented as guaranteed probabilities. *(Uncalibrated model score’lar veya covariance ellipse’ler guaranteed probability olarak presented edilmez.)*

---

# 296. Deferred Future Decisions (Ertelenmiş Gelecek Kararları)

The following ideas are intentionally deferred beyond the initial prototype. *(Aşağıdaki idea’lar intentionally initial prototype’ın beyond’una deferred edilmiştir.)*

---

# 297. FD-001 — Multi-Device Validation (FD-001 — Multi-Device Validation)

**Status: DEFERRED.** *(Durum: DEFERRED.)*

Cross-device generalization belongs to future work. *(Cross-device generalization future work’e aittir.)*

---

# 298. FD-002 — Multi-Placement AI (FD-002 — Multi-Placement AI)

**Status: DEFERRED.** *(Durum: DEFERRED.)*

Automatic robustness across many phone placements is not required for the first benchmark. *(Many phone placement across automatic robustness first benchmark için required değildir.)*

---

# 299. FD-003 — Wi-Fi / BLE / UWB Localization (FD-003 — Wi-Fi / BLE / UWB Localization)

**Status: DEFERRED.** *(Durum: DEFERRED.)*

External infrastructure localization is outside the current smartphone-only architecture. *(External infrastructure localization current smartphone-only architecture dışındadır.)*

---

# 300. FD-004 — Map Matching (FD-004 — Map Matching)

**Status: DEFERRED.** *(Durum: DEFERRED.)*

Map matching may later be evaluated as a separately controlled configuration. *(Map matching later separately controlled configuration olarak evaluate edilebilir.)*

---

# 301. FD-005 — Factor Graph (FD-005 — Factor Graph)

**Status: DEFERRED.** *(Durum: DEFERRED.)*

Factor-graph fusion is future comparative research rather than initial implementation scope. *(Factor-graph fusion initial implementation scope yerine future comparative research’tür.)*

---

# 302. FD-006 — Error-State Inertial Filter (FD-006 — Error-State Inertial Filter)

**Status: DEFERRED.** *(Durum: DEFERRED.)*

A higher-dimensional inertial error-state formulation requires evidence that the compact EKF is insufficient. *(Higher-dimensional inertial error-state formulation compact EKF’nin insufficient olduğuna dair evidence gerektirir.)*

---

# 303. FD-007 — Neural Inertial Odometry (FD-007 — Neural Inertial Odometry)

**Status: DEFERRED.** *(Durum: DEFERRED.)*

End-to-end learned inertial odometry requires more data and stronger reference infrastructure than the current schedule supports. *(End-to-end learned inertial odometry current schedule’ın support ettiğinden more data ve stronger reference infrastructure gerektirir.)*

---

# 304. FD-008 — Collaborative Navigation (FD-008 — Collaborative Navigation)

**Status: DEFERRED.** *(Durum: DEFERRED.)*

Multi-user or device-to-device cooperative localization is future work. *(Multi-user veya device-to-device cooperative localization future work’tür.)*

---

# 305. FD-009 — Real RF Jamming Experiments (FD-009 — Gerçek RF Jamming Deneyleri)

**Status: OUTSIDE CURRENT SCOPE.** *(Durum: CURRENT SCOPE DIŞINDA.)*

Any real RF-denial research would require separate legal, safety, and laboratory controls. *(Any real RF-denial research separate legal, safety ve laboratory control gerektirir.)*

---

# 306. FD-010 — GNSS Spoofing Detection (FD-010 — GNSS Spoofing Detection)

**Status: DEFERRED.** *(Durum: DEFERRED.)*

Spoofing detection is a separate future security-oriented research direction. *(Spoofing detection separate future security-oriented research direction’dır.)*

---

# 307. Known Documentation Corrections (Bilinen Dokümantasyon Düzeltmeleri)

This section records known cross-page consistency corrections that future implementation must follow. *(Bu bölüm future implementation’ın follow etmesi gereken known cross-page consistency correction’larını kaydeder.)*

---

# 308. COR-001 — EKF State Correction (COR-001 — EKF State Düzeltmesi)

**Status: FROZEN.** *(Durum: FROZEN.)*

Page 21 defines the authoritative minimum state as `[E,N,ψ]`. *(Page 21 authoritative minimum state’i `[E,N,ψ]` olarak define eder.)*

Any later velocity-state formulas are optional extension examples only. *(Any later velocity-state formula’lar yalnızca optional extension example’lardır.)*

---

# 309. COR-002 — Recovery H Matrix Correction (COR-002 — Recovery H Matrix Düzeltmesi)

**Status: FROZEN.** *(Durum: FROZEN.)*

For the core `[E,N,ψ]` state, recovery or authorized horizontal position measurement uses `H=[[1,0,0],[0,1,0]]`. *(Core `[E,N,ψ]` state için recovery veya authorized horizontal position measurement `H=[[1,0,0],[0,1,0]]` kullanır.)*

Any five-state `H` shown elsewhere belongs only to the optional velocity-state extension. *(Elsewhere shown any five-state `H` yalnızca optional velocity-state extension’a aittir.)*

---

# 310. COR-003 — Quality Vocabulary Correction (COR-003 — Quality Vocabulary Düzeltmesi)

**Status: FROZEN.** *(Durum: FROZEN.)*

Page 20 quality states remain canonical. *(Page 20 quality state’leri canonical olarak kalır.)*

Temporary terminology in later pages must be interpreted as validity or local status rather than replacement Quality Engine states. *(Later page’lerdeki temporary terminology replacement Quality Engine state yerine validity veya local status olarak interpreted edilmelidir.)*

---

# 311. COR-004 — ARCore Coordinate Correction (COR-004 — ARCore Coordinate Düzeltmesi)

**Status: FROZEN.** *(Durum: FROZEN.)*

No implementation may assume `ARCore X = East` without validated alignment. *(Hiçbir implementation validated alignment olmadan `ARCore X = East` assume edemez.)*

---

# 312. COR-005 — Recovery Error Correction (COR-005 — Recovery Error Düzeltmesi)

**Status: FROZEN.** *(Durum: FROZEN.)*

Final denied error must always use pre-correction estimator state. *(Final denied error her zaman pre-correction estimator state kullanmalıdır.)*

---

# 313. COR-006 — Ground Truth Terminology (COR-006 — Ground Truth Terminology)

**Status: FROZEN.** *(Durum: FROZEN.)*

Smartphone GNSS ground truth is an evaluation reference with known uncertainty and not perfect physical truth. *(Smartphone GNSS ground truth known uncertainty’ye sahip evaluation reference’tır ve perfect physical truth değildir.)*

---

# 314. Change Request Procedure (Değişiklik Talebi Prosedürü)

Any material deviation from a frozen decision should create a change request. *(Frozen decision’dan any material deviation change request oluşturmalıdır.)*

---

# 315. Required Change Request Fields (Gerekli Change Request Alanları)

```text id="m4jl41"
Change ID
(Change ID)

Affected Decision IDs
(Etkilenen Decision ID'leri)

Requested Change
(Talep Edilen Değişiklik)

Reason
(Sebep)

Evidence
(Kanıt)

Risk Level
(Risk Seviyesi)

Affected Tests
(Etkilenen Testler)

Affected Sessions
(Etkilenen Session'lar)

Benchmark Impact
(Benchmark Etkisi)

Approval Status
(Onay Durumu)
```

---

# 316. Pre-Implementation Change Rule (Implementation Öncesi Değişiklik Kuralı)

Before implementation begins, architectural decisions may change when the new decision is documented and internally consistent. *(Implementation başlamadan önce architectural decision’lar new decision documented ve internally consistent olduğunda değişebilir.)*

---

# 317. Development Change Rule (Development Değişiklik Kuralı)

During development, changes that affect navigation behavior require regression testing and decision-log update. *(Development sırasında navigation behavior’ı affect eden change’ler regression testing ve decision-log update gerektirir.)*

---

# 318. Pilot Change Rule (Pilot Değişiklik Kuralı)

Pilot evidence may justify parameter calibration or architecture adjustment before benchmark freeze. *(Pilot evidence benchmark freeze öncesinde parameter calibration veya architecture adjustment’ı justify edebilir.)*

---

# 319. Final Benchmark Freeze Rule (Final Benchmark Freeze Kuralı)

After formal benchmark freeze, high-risk estimator changes are prohibited unless a critical defect requires a new benchmark build. *(Formal benchmark freeze sonrasında high-risk estimator change’ler critical defect new benchmark build gerektirmedikçe prohibited’dır.)*

---

# 320. New Benchmark Build Rule (Yeni Benchmark Build Kuralı)

A material post-freeze estimator change creates a new build identity and may require recollection of affected final sessions. *(Material post-freeze estimator change new build identity oluşturur ve affected final session’ların recollection’ını gerektirebilir.)*

---

# 321. Metric Change Rule (Metrik Değişiklik Kuralı)

Changing a primary metric definition after seeing final results is prohibited unless correcting a proven implementation error. *(Final result’lar görüldükten sonra primary metric definition’ı change etmek proven implementation error’ı correct etmek dışında prohibited’dır.)*

---

# 322. Inclusion Rule Change (Inclusion Rule Değişikliği)

Changing session inclusion criteria after seeing outcome values is prohibited. *(Outcome value’lar görüldükten sonra session inclusion criterion’larını change etmek prohibited’dır.)*

---

# 323. AI Model Change After Freeze (Freeze Sonrası AI Model Değişikliği)

Replacing the final model after benchmark collection starts creates a new model/build evidence lineage. *(Benchmark collection başladıktan sonra final model’i replace etmek new model/build evidence lineage oluşturur.)*

---

# 324. Route Change After Freeze (Freeze Sonrası Rota Değişikliği)

A material route change must be documented and may prevent direct pooling with earlier sessions. *(Material route change documented edilmelidir ve earlier session’larla direct pooling’i prevent edebilir.)*

---

# 325. Logging Schema Change (Logging Schema Değişikliği)

Logging schema changes require explicit version increments when compatibility is affected. *(Logging schema change’leri compatibility affected olduğunda explicit version increment gerektirir.)*

---

# 326. Replay Schema Change (Replay Schema Değişikliği)

Replay readers must either support earlier schema versions or explicitly reject them with a clear compatibility reason. *(Replay reader’lar earlier schema version’ları either support etmeli veya clear compatibility reason ile explicitly reject etmelidir.)*

---

# 327. Database Migration Rule (Database Migration Kuralı)

SQLite metadata schema changes require versioned migration behavior. *(SQLite metadata schema change’leri versioned migration behavior gerektirir.)*

---

# 328. Model Schema Change (Model Schema Değişikliği)

Changing tensor shape, channel order, preprocessing, or class order creates a new model-schema version. *(Tensor shape, channel order, preprocessing veya class order’u change etmek new model-schema version oluşturur.)*

---

# 329. Coordinate Convention Change (Coordinate Convention Değişikliği)

Changing ENU orientation or heading convention is considered a critical breaking change. *(ENU orientation veya heading convention’ı change etmek critical breaking change olarak considered edilir.)*

---

# 330. Ground Truth Firewall Change (Ground Truth Firewall Değişikliği)

Any change to Ground Truth Firewall logic is classified as critical and requires dedicated mutation and authorization regression tests. *(Ground Truth Firewall logic’teki any change critical olarak classified edilir ve dedicated mutation ile authorization regression test’leri gerektirir.)*

---

# 331. Recovery Ordering Change (Recovery Ordering Değişikliği)

Any change that could move correction before evidence capture is prohibited. *(Correction’ı evidence capture öncesine taşıyabilecek any change prohibited’dır.)*

---

# 332. Documentation Synchronization Rule (Dokümantasyon Senkronizasyon Kuralı)

When implementation materially deviates from a frozen design, the relevant technical page and this decision log must both be updated. *(Implementation frozen design’dan materially deviate ettiğinde relevant technical page ve bu decision log birlikte updated edilmelidir.)*

---

# 333. Change Log Template (Değişiklik Günlüğü Şablonu)

```text id="frxvjr"
CR-XXX

Date:
(Tarih:)

Affected Decision:
(Etkilenen Karar:)

Old State:
(Eski Durum:)

New State:
(Yeni Durum:)

Reason:
(Sebep:)

Evidence:
(Kanıt:)

Risk:
(Risk:)

Regression Tests:
(Regression Testleri:)

Benchmark Impact:
(Benchmark Etkisi:)

Status:
(Durum:)
```

---

# 334. Current Change Log Status (Mevcut Change Log Durumu)

At the pre-development documentation stage, no implementation-derived material changes have yet been recorded. *(Pre-development documentation stage’de henüz implementation-derived material change recorded edilmemiştir.)*

---

# 335. CR-000 — Baseline Documentation Freeze (CR-000 — Baseline Dokümantasyon Freeze)

**Status: ACTIVE BASELINE.** *(Durum: ACTIVE BASELINE.)*

Pages completed before implementation establish the baseline design against which future deviations will be recorded. *(Implementation öncesinde completed page’ler future deviation’ların recorded edileceği baseline design’ı establish eder.)*

---

# 336. Initial Known Clarification Record (İlk Bilinen Clarification Kaydı)

The known EKF and quality-state consistency corrections in this page are clarifications of existing architecture rather than implementation-driven redesign. *(Bu page’deki known EKF ve quality-state consistency correction’ları implementation-driven redesign yerine existing architecture clarification’larıdır.)*

---

# 337. Decision Freeze Before Day 1 (Day 1 Öncesi Decision Freeze)

Not every provisional numeric parameter must be frozen before Day 1. *(Her provisional numeric parameter’ın Day 1 öncesinde frozen olması required değildir.)*

Architecture, conventions, integrity boundaries, and evaluation rules are frozen earlier, while device-dependent numerical parameters remain evidence-gated. *(Architecture, convention, integrity boundary ve evaluation rule’ları earlier frozen edilirken device-dependent numerical parameter’lar evidence-gated kalır.)*

---

# 338. Parameter Freeze Timing (Parameter Freeze Zamanlaması)

Final detector, filter, covariance, recovery, and route parameters must freeze before final benchmark collection. *(Final detector, filter, covariance, recovery ve route parameter’ları final benchmark collection öncesinde freeze edilmelidir.)*

---

# 339. Architecture vs Parameter Distinction (Architecture vs Parameter Ayrımı)

A change in a numeric threshold is not necessarily equivalent to changing the underlying architecture. *(Numeric threshold change’i underlying architecture’ı change etmekle necessarily equivalent değildir.)*

However, even parameter changes become high-risk after benchmark freeze. *(Ancak benchmark freeze sonrasında even parameter change’leri high-risk hale gelir.)*

---

# 340. Evidence Hierarchy for Decision Changes (Decision Değişiklikleri için Evidence Hiyerarşisi)

Decision changes should prefer evidence in the following order. *(Decision change’leri aşağıdaki order’daki evidence’ı prefer etmelidir.)*

```text id="m83o5y"
1. Reproducible target-device measurement
   (Reproducible target-device measurement)

2. Pilot field evidence
   (Pilot field evidence)

3. Controlled replay evidence
   (Controlled replay evidence)

4. Automated regression evidence
   (Automated regression evidence)

5. External technical references
   (External technical reference'lar)

6. Engineering intuition alone
   (Yalnızca engineering intuition)
```

---

# 341. Intuition-Only Change Rule (Yalnızca Intuition ile Değişiklik Kuralı)

Engineering intuition may generate a candidate but should not override measured contradictory evidence without justification. *(Engineering intuition candidate generate edebilir ancak justification olmadan measured contradictory evidence’ı override etmemelidir.)*

---

# 342. Negative Evidence Handling (Negatif Evidence Handling)

Evidence that an enhancement provides no benefit should be preserved rather than ignored. *(Enhancement’ın no benefit sağladığını gösteren evidence ignored edilmek yerine preserved edilmelidir.)*

---

# 343. Optional Feature Removal Rule (Optional Feature Removal Kuralı)

An optional subsystem may be removed from final Configuration D if it fails validation or harms reliability, provided the change occurs before final freeze and is documented. *(Optional subsystem validation fail ederse veya reliability’ye harm verirse, change final freeze öncesinde gerçekleştiği ve documented olduğu sürece final Configuration D’den removed edilebilir.)*

---

# 344. Mandatory Motion AI Removal Rule (Mandatory Motion AI Removal Kuralı)

Motion Classification cannot be silently removed from the research architecture because it is the mandatory AI component. *(Motion Classification mandatory AI component olduğu için research architecture’dan silently removed edilemez.)*

---

# 345. ARCore Removal Rule (ARCore Removal Kuralı)

ARCore may remain diagnostic-only or disabled if it cannot be validated safely. *(ARCore safely validated edilemezse diagnostic-only veya disabled kalabilir.)*

---

# 346. Learned Step-Length Removal Rule (Learned Step-Length Removal Kuralı)

Learned step length may be rejected without invalidating minimum project completion. *(Learned step length minimum proje completion’ı invalidate etmeden rejected edilebilir.)*

---

# 347. EKF Removal Consequence (EKF Removal Consequence)

If EKF cannot be validated, the project may still preserve a minimum reproducible PDR research system, but the full target Configuration D architecture would require explicit limitation and reclassification. *(EKF validated edilemezse proje minimum reproducible PDR research system’ı preserve edebilir ancak full target Configuration D architecture explicit limitation ve reclassification gerektirir.)*

---

# 348. Critical Integrity Feature Removal (Critical Integrity Feature Removal)

Ground Truth Firewall, replay integrity, and pre-correction recovery evidence cannot be removed without invalidating the intended research design. *(Ground Truth Firewall, replay integrity ve pre-correction recovery evidence intended research design’ı invalidate etmeden removed edilemez.)*

---

# 349. Final Decision Audit (Final Karar Audit’i)

Before Day 21 benchmark freeze, all `PENDING_EVIDENCE` decisions that affect final estimator behavior must be reviewed. *(Day 21 benchmark freeze öncesinde final estimator behavior’ı affect eden all `PENDING_EVIDENCE` decision’lar reviewed edilmelidir.)*

---

# 350. Final Decision Audit Output (Final Karar Audit Output’u)

The audit should produce a final list of frozen values, remaining optional features, rejected candidates, and unresolved limitations. *(Audit final frozen value list’i, remaining optional feature’lar, rejected candidate’lar ve unresolved limitation’lar üretmelidir.)*

---

# 351. Benchmark Configuration Snapshot (Benchmark Configuration Snapshot)

The final benchmark configuration should export all decision-dependent parameters in a machine-readable snapshot. *(Final benchmark configuration all decision-dependent parameter’ları machine-readable snapshot içerisinde export etmelidir.)*

---

# 352. Candidate Benchmark Snapshot Fields (Aday Benchmark Snapshot Alanları)

```text id="ohk29u"
buildId
modelIds
modelHashes
sensorRates
stepDetectorConfig
headingConfig
stepLengthConfig
qualityConfig
ekfConfig
arcoreConfig
recoveryConfig
routeProtocolVersion
inclusionPolicyVersion
metricPipelineVersion
```

---

# 353. Decision-to-Code Traceability (Decision-to-Code İzlenebilirliği)

Where practical, important runtime configuration fields should map back to their decision IDs. *(Practical olduğunda important runtime configuration field’ları decision ID’lerine back-map edilmelidir.)*

---

# 354. Decision-to-Test Traceability (Decision-to-Test İzlenebilirliği)

Critical frozen decisions should map to verification tests from Page 39. *(Critical frozen decision’lar Page 39’daki verification test’lerine map edilmelidir.)*

---

# 355. Decision-to-Result Traceability (Decision-to-Result İzlenebilirliği)

Final Page 41 findings should identify which frozen configuration and decisions produced the measured result. *(Final Page 41 finding’leri measured result’ı üreten frozen configuration ve decision’ları identify etmelidir.)*

---

# 356. Decision-to-Limitation Traceability (Decision-to-Limitation İzlenebilirliği)

If a decision creates a known scope limitation, Page 42 should reflect that limitation. *(Decision known scope limitation oluşturuyorsa Page 42 bu limitation’ı reflect etmelidir.)*

---

# 357. Decision-to-Presentation Traceability (Decision-to-Presentation İzlenebilirliği)

Presentation claims must follow the final decision state and not an outdated candidate design. *(Presentation claim’leri outdated candidate design yerine final decision state’i follow etmelidir.)*

---

# 358. No Silent Branch Behavior (Silent Branch Behavior Yoktur)

A hidden code branch must not change the benchmark estimator in a way that is absent from the configuration snapshot and decision log. *(Hidden code branch benchmark estimator’ı configuration snapshot ve decision log’da absent olan bir şekilde change etmemelidir.)*

---

# 359. Feature Flag Logging (Feature Flag Logging)

Estimator-relevant feature flags must be included in benchmark configuration evidence. *(Estimator-relevant feature flag’ler benchmark configuration evidence içerisinde included olmalıdır.)*

---

# 360. Default-Value Logging (Default-Value Logging)

Critical defaults should be serialized explicitly rather than omitted because they were not manually changed. *(Critical default’lar manually changed edilmedikleri için omitted edilmek yerine explicitly serialized edilmelidir.)*

---

# 361. Runtime Override Logging (Runtime Override Logging)

Any runtime override that changes navigation behavior must be recorded. *(Navigation behavior’ı change eden any runtime override recorded edilmelidir.)*

---

# 362. Manual Operator Override (Manual Operator Override)

Manual operator actions such as denial and recovery requests must be timestamped when they affect experiment boundaries. *(Denial ve recovery request gibi manual operator action’lar experiment boundary’lerini affect ettiğinde timestamped edilmelidir.)*

---

# 363. Calibration Data Separation (Calibration Data Separation)

Calibration sessions must remain distinguishable from final benchmark sessions. *(Calibration session’ları final benchmark session’larından distinguishable kalmalıdır.)*

---

# 364. Final Benchmark Data Isolation (Final Benchmark Data Isolation)

Final benchmark data must not be reused as development tuning data. *(Final benchmark data development tuning data olarak reused edilmemelidir.)*

---

# 365. Decision Log Ownership (Decision Log Ownership)

This page acts as the authoritative documentation location for final project-level decisions. *(Bu page final project-level decision’lar için authoritative documentation location olarak act eder.)*

Subsystem pages may contain implementation details but should not silently override this log. *(Subsystem page’leri implementation detail içerebilir ancak bu log’u silently override etmemelidir.)*

---

# 366. Change Log Update Frequency (Change Log Update Frequency)

The log should be updated whenever a material architectural, experimental, or benchmark decision changes. *(Material architectural, experimental veya benchmark decision değiştiğinde log updated edilmelidir.)*

---

# 367. Minor Implementation Notes (Minor Implementation Note’ları)

Pure refactoring that does not change observable behavior does not require a formal change record unless it affects evidence reproducibility. *(Observable behavior’ı change etmeyen pure refactoring evidence reproducibility’yi affect etmedikçe formal change record gerektirmez.)*

---

# 368. Bug Fix Classification (Bug Fix Classification)

A bug fix is classified according to its effect, not simply because it is called a bug fix. *(Bug fix simply bug fix olarak adlandırıldığı için değil effect’ine göre classified edilir.)*

---

# 369. Critical Bug Fix Example (Critical Bug Fix Örneği)

A fix that changes Ground Truth Firewall behavior is critical even if the code change is only one line. *(Ground Truth Firewall behavior’ını change eden fix code change yalnızca one line olsa bile critical’dır.)*

---

# 370. Low-Risk Bug Fix Example (Low-Risk Bug Fix Örneği)

Correcting a misspelled UI label without estimator impact is low risk. *(Estimator impact olmadan misspelled UI label’ı correct etmek low risk’tir.)*

---

# 371. Final Documentation Freeze (Final Dokümantasyon Freeze)

Documentation should be synchronized with the final implementation before the project is declared complete. *(Project complete declared edilmeden önce documentation final implementation ile synchronized edilmelidir.)*

---

# 372. Page 41 Update Dependency (Page 41 Update Dependency)

Page 41 remains results-pending until physical benchmark evidence exists. *(Page 41 physical benchmark evidence mevcut olana kadar results-pending kalır.)*

---

# 373. Page 42 Finalization Dependency (Page 42 Finalization Dependency)

Page 42 final limitation priorities should be updated after measured Page 41 results reveal the dominant bottlenecks. *(Page 42 final limitation priority’leri measured Page 41 result’ları dominant bottleneck’leri reveal ettikten sonra updated edilmelidir.)*

---

# 374. Page 43 Finalization Dependency (Page 43 Finalization Dependency)

This page will require a final implementation audit after Day 24 to record all actual deviations from the pre-development baseline. *(Bu page pre-development baseline’dan all actual deviation’ları record etmek için Day 24 sonrasında final implementation audit gerektirecektir.)*

---

# 375. Page 44 Dependency (Page 44 Dependency)

Page 44 will provide the external technical references supporting platform facts, algorithms, mathematical methods, and engineering choices. *(Page 44 platform fact’leri, algorithm’lar, mathematical method’lar ve engineering choice’ları support eden external technical reference’ları sağlayacaktır.)*

---

# 376. Final Change Log Table Template (Final Change Log Tablo Şablonu)

| Change ID | Date (Tarih) | Decision ID | Old (Eski) | New (Yeni) | Reason (Sebep) | Risk | Benchmark Impact |
| --------- | ------------ | ----------- | ---------- | ---------- | -------------- | ---- | ---------------- |
| TBD       | TBD          | TBD         | TBD        | TBD        | TBD            | TBD  | TBD              |

---

# 377. Final Frozen Decision Audit Table Template (Final Frozen Decision Audit Tablo Şablonu)

| Decision ID | Final Status | Final Value / Method | Evidence | Build |
| ----------- | ------------ | -------------------- | -------- | ----- |
| TBD         | TBD          | TBD                  | TBD      | TBD   |

---

# 378. Final Pending Decision Closure Table (Final Pending Decision Closure Tablosu)

| Pending Decision | Final Resolution | Evidence | Date |
| ---------------- | ---------------- | -------- | ---- |
| Sensor Rate      | TBD              | TBD      | TBD  |
| Step Thresholds  | TBD              | TBD      | TBD  |
| Heading Filter   | TBD              | TBD      | TBD  |
| Motion Window    | TBD              | TBD      | TBD  |
| Motion Model     | TBD              | TBD      | TBD  |
| Step-Length ML   | TBD              | TBD      | TBD  |
| ARCore Fusion    | TBD              | TBD      | TBD  |
| `Q/R`            | TBD              | TBD      | TBD  |
| NIS Gate         | TBD              | TBD      | TBD  |
| Recovery Policy  | TBD              | TBD      | TBD  |
| Route Set        | TBD              | TBD      | TBD  |
| Phone Placement  | TBD              | TBD      | TBD  |

---

# 379. Final Governance Principle (Final Governance Principle)

A frozen decision may be changed when evidence requires it, but the change itself must remain visible and traceable. *(Frozen decision evidence gerektirdiğinde change edilebilir ancak change’in kendisi visible ve traceable kalmalıdır.)*

---

# 380. No Architectural Pride Rule (Architectural Pride Kuralı Yoktur)

A design should not be retained merely because it was originally planned if controlled evidence shows that it is harmful. *(Controlled evidence harmful olduğunu gösterirse design yalnızca originally planned olduğu için retained edilmemelidir.)*

---

# 381. No Benchmark Optimization Rule (Benchmark Optimization Kuralı Yoktur)

A design should not be changed merely because the final benchmark score would look better. *(Design final benchmark score better görünsün diye change edilmemelidir.)*

---

# 382. Evidence-Based Rejection Rule (Evidence-Based Rejection Kuralı)

A candidate may be rejected without embarrassment when it fails to provide measurable value. *(Candidate measurable value sağlayamadığında embarrassment olmadan rejected edilebilir.)*

---

# 383. Evidence-Based Promotion Rule (Evidence-Based Promotion Kuralı)

A candidate becomes navigation-enabled only after passing its defined validation gates. *(Candidate yalnızca defined validation gate’lerini geçtikten sonra navigation-enabled hale gelir.)*

---

# 384. Scientific Integrity Priority (Scientific Integrity Önceliği)

Research integrity has higher priority than feature count. *(Research integrity feature count’tan higher priority’ye sahiptir.)*

---

# 385. Deterministic Baseline Priority (Deterministic Baseline Önceliği)

A reproducible deterministic baseline has higher priority than an unvalidated advanced model. *(Reproducible deterministic baseline unvalidated advanced model’dan higher priority’ye sahiptir.)*

---

# 386. Fallback Priority (Fallback Önceliği)

Graceful degradation has higher priority than pretending every source is always reliable. *(Graceful degradation every source’un always reliable olduğunu pretend etmekten higher priority’ye sahiptir.)*

---

# 387. Traceability Priority (Traceability Önceliği)

A measurable and traceable system has higher research value than an opaque system with unexplained performance. *(Measurable ve traceable system unexplained performance’a sahip opaque system’dan higher research value’ya sahiptir.)*

---

# 388. Final Technical Decisions Statement (Nihai Teknik Kararlar Bildirimi)

**NAVGUARD’s authoritative architecture is now governed by explicit decision states rather than informal assumptions, with the Android Redmi Note 9 Pro implementation centered on monotonic sensor acquisition, validated GNSS anchoring, ENU coordinates, true-north heading, deterministic step-driven PDR, mandatory Motion Classification, optional evidence-gated step-length learning, ARCore relative tracking, quality-aware fusion, and a minimum `[E,N,ψ]` EKF.** *(NAVGUARD’ın authoritative architecture’ı artık informal assumption’lar yerine explicit decision state’leri ile governed edilir; Android Redmi Note 9 Pro implementation monotonic sensor acquisition, validated GNSS anchoring, ENU coordinate’ları, true-north heading, deterministic step-driven PDR, mandatory Motion Classification, optional evidence-gated step-length learning, ARCore relative tracking, quality-aware fusion ve minimum `[E,N,ψ]` EKF merkezlidir.)*

**The Ground Truth Firewall remains the strongest non-negotiable integrity decision: Evaluation Mode GNSS may be logged independently during software-defined denial, but it cannot influence the estimator, Motion AI, step-length inference, or hidden correction pathways, and the required unauthorized GNSS update count remains exactly zero.** *(Ground Truth Firewall en güçlü non-negotiable integrity decision olarak kalır; Evaluation Mode GNSS software-defined denial sırasında independently logged edilebilir ancak estimator, Motion AI, step-length inference veya hidden correction pathway’leri influence edemez ve required unauthorized GNSS update count exactly zero olarak kalır.)*

**The previously frozen Page 21 EKF state `[E,N,ψ]` is explicitly reaffirmed as authoritative, while later five-state `[E,N,vE,vN,ψ]` examples are classified only as optional extensions and may not silently alter implementation or recovery measurement matrices.** *(Previously frozen Page 21 EKF state `[E,N,ψ]` explicitly authoritative olarak reaffirm edilirken later five-state `[E,N,vE,vN,ψ]` example’ları yalnızca optional extension olarak classified edilir ve implementation veya recovery measurement matrix’lerini silently alter edemez.)*

**The Page 20 Quality Engine vocabulary `UNKNOWN, GOOD, USABLE, DEGRADED, UNRELIABLE, UNAVAILABLE` is likewise reaffirmed as canonical, and later temporary validity labels must not replace this shared quality-state model.** *(Page 20 Quality Engine vocabulary’si `UNKNOWN, GOOD, USABLE, DEGRADED, UNRELIABLE, UNAVAILABLE` likewise canonical olarak reaffirm edilir ve later temporary validity label’ları bu shared quality-state model’i replace etmemelidir.)*

**Device-dependent numerical choices such as exact sensor rates, step thresholds, heading filters, AI window parameters, `Q/R`, NIS gates, ARCore fusion readiness, recovery stability thresholds, queue capacity, route geometry, and phone placement intentionally remain evidence-gated until physical audit or pilot testing provides defensible values.** *(Exact sensor rate’leri, step threshold’ları, heading filter’ları, AI window parameter’ları, `Q/R`, NIS gate’leri, ARCore fusion readiness, recovery stability threshold’ları, queue capacity, route geometry ve phone placement gibi device-dependent numerical choice’lar physical audit veya pilot testing defensible value sağlayana kadar intentionally evidence-gated kalır.)*

**Final benchmark governance remains frozen: Configuration A versus D is the primary matched comparison, the predefined primary target remains at least `20%` reduction in aggregated matched-session median horizontal position error, valid poor sessions cannot be excluded for poor performance, final denied error is measured before recovery correction, and no post-freeze tuning is permitted.** *(Final benchmark governance frozen kalır; Configuration A versus D primary matched comparison’dır, predefined primary target aggregated matched-session median horizontal position error’da en az `20%` reduction olarak kalır, valid poor session’lar poor performance nedeniyle excluded edilemez, final denied error recovery correction öncesinde measured edilir ve post-freeze tuning’e izin verilmez.)*

**Any future implementation deviation that changes estimator behavior, model semantics, timing, coordinate conventions, evidence integrity, benchmark configuration, or metric interpretation must be recorded through a versioned change record rather than being absorbed silently into the codebase.** *(Estimator behavior, model semantics, timing, coordinate convention, evidence integrity, benchmark configuration veya metric interpretation’ı change eden any future implementation deviation codebase’e silently absorbed edilmek yerine versioned change record üzerinden recorded edilmelidir.)*

**This decision log therefore becomes the central governance layer connecting NAVGUARD’s design, implementation, verification, benchmark, final results, limitations, and presentation into one traceable technical history.** *(Bu nedenle bu decision log NAVGUARD’ın design, implementation, verification, benchmark, final result, limitation ve presentation’ını one traceable technical history içerisinde connect eden central governance layer haline gelir.)*

---

# 389. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Implementation Technical Decision Baseline Completed *(Doküman Durumu: Implementation Öncesi Technical Decision Baseline Tamamlandı)*

**Authoritative Decision Registry:** Established *(Authoritative Decision Registry: Oluşturuldu)*

**Change Request Structure:** Established *(Change Request Structure: Oluşturuldu)*

**Technical Decision Prefix:** `TD` *(Technical Decision Prefix: `TD`)*

**Change Record Prefix:** `CR` *(Change Record Prefix: `CR`)*

**Decision States:** `FROZEN / APPROVED / PROVISIONAL / CANDIDATE / OPTIONAL / PENDING_EVIDENCE / SUPERSEDED / REJECTED / DEFERRED` *(Decision State’leri: `FROZEN / APPROVED / PROVISIONAL / CANDIDATE / OPTIONAL / PENDING_EVIDENCE / SUPERSEDED / REJECTED / DEFERRED`)*

**Primary Platform:** Android *(Primary Platform: Android)*

**Primary Device:** Xiaomi Redmi Note 9 Pro *(Primary Device: Xiaomi Redmi Note 9 Pro)*

**Project Duration:** 24 Business Days *(Proje Süresi: 24 İş Günü)*

**Additional Navigation Hardware:** Not Required *(Additional Navigation Hardware: Gerekli Değil)*

**GNSS Denial:** Software-Defined *(GNSS Denial: Software-Defined)*

**RF Jamming / Spoofing:** Outside Current Scope *(RF Jamming / Spoofing: Current Scope Dışında)*

**Internal Coordinate Frame:** ENU *(Internal Coordinate Frame: ENU)*

**Heading Convention:** Clockwise from True North *(Heading Convention: True North’tan Clockwise)*

**Internal Angle Unit:** Radians *(Internal Angle Unit: Radian)*

**Quaternion Convention:** `[w,x,y,z]` *(Quaternion Convention: `[w,x,y,z]`)*

**Formal GNSS Provider:** `GPS_PROVIDER` *(Formal GNSS Provider: `GPS_PROVIDER`)*

**GNSS Measurement Timing:** `Location.getElapsedRealtimeNanos()` *(GNSS Measurement Timing: `Location.getElapsedRealtimeNanos()`)*

**First GNSS Fix Auto-Anchor:** Rejected *(İlk GNSS Fix Auto-Anchor: Reddedildi)*

**PDR Strategy:** Step-Event Driven *(PDR Stratejisi: Step-Event Driven)*

**Raw Acceleration Double Integration:** Rejected *(Raw Acceleration Double Integration: Reddedildi)*

**Authoritative Step Detector:** Independent Deterministic NAVGUARD Detector *(Authoritative Step Detector: Independent Deterministic NAVGUARD Detector)*

**Controlled Step Error Target:** `≤5%` *(Controlled Step Error Hedefi: `≤5%`)*

**Fixed Step Length:** Mandatory Fallback *(Fixed Step Length: Mandatory Fallback)*

**Learned Step Length:** Optional / Evidence-Gated *(Learned Step Length: Optional / Evidence-Gated)*

**Operational Heading:** True North *(Operational Heading: True North)*

**GNSS Bearing as Phone Heading:** Rejected *(GNSS Bearing’in Phone Heading Olması: Reddedildi)*

**Mandatory AI Component:** Motion Classification *(Mandatory AI Component: Motion Classification)*

**Motion Classes:** `STATIONARY / WALKING / RUNNING / TURNING` *(Motion Class’ları: `STATIONARY / WALKING / RUNNING / TURNING`)*

**Motion AI Primary Metric:** Held-Out Session-Wise Macro F1 *(Motion AI Primary Metric: Held-Out Session-Wise Macro F1)*

**Motion AI Target:** `≥0.90` *(Motion AI Target: `≥0.90`)*

**Motion AI Primary Neural Candidate:** Lightweight 1D-CNN *(Motion AI Primary Neural Candidate: Lightweight 1D-CNN)*

**Random Forest:** Primary Classical Nonlinear Baseline *(Random Forest: Primary Classical Nonlinear Baseline)*

**On-Device Neural Runtime:** LiteRT-Compatible `.tflite` *(On-Device Neural Runtime: LiteRT-Compatible `.tflite`)*

**Production AI Runtime Owner:** Kotlin *(Production AI Runtime Owner: Kotlin)*

**AI Shadow Mode Before Navigation:** Mandatory *(Navigation Öncesi AI Shadow Mode: Mandatory)*

**Provisional AI Runtime Target:** Approximately `<50 ms` *(Provisional AI Runtime Target: Yaklaşık `<50 ms`)*

**ARCore Role:** Relative Visual-Inertial Source *(ARCore Role: Relative Visual-Inertial Source)*

**ARCore Global Lat/Lon Source:** No *(ARCore Global Lat/Lon Source: Hayır)*

**ARCore Formal Fusion State:** `TRACKING` Only *(ARCore Formal Fusion State: Yalnızca `TRACKING`)*

**ARCore `PAUSED`:** Rejected *(ARCore `PAUSED`: Reddedilir)*

**ARCore Loss Fallback:** PDR *(ARCore Loss Fallback: PDR)*

**ARCore Axis Equals ENU:** Rejected *(ARCore Axis Equals ENU: Reddedildi)*

**Canonical Quality States:** `UNKNOWN / GOOD / USABLE / DEGRADED / UNRELIABLE / UNAVAILABLE` *(Canonical Quality State’leri: `UNKNOWN / GOOD / USABLE / DEGRADED / UNRELIABLE / UNAVAILABLE`)*

**Hard Invalid Measurement:** Rejected Before Fusion *(Hard Invalid Measurement: Fusion Öncesi Reddedilir)*

**Quality-to-Covariance Mapping:** Pending Calibration *(Quality-to-Covariance Mapping: Calibration Bekliyor)*

**Formal EKF Core State:** `[E,N,ψ]` *(Formal EKF Core State: `[E,N,ψ]`)*

**Optional Velocity Extension:** `[E,N,vE,vN,ψ]` *(Optional Velocity Extension: `[E,N,vE,vN,ψ]`)*

**Velocity Extension Is Current Core:** No *(Velocity Extension Current Core mu: Hayır)*

**Joseph Covariance Update:** Preferred *(Joseph Covariance Update: Preferred)*

**NIS Innovation Gate:** Candidate / Threshold Pending *(NIS Innovation Gate: Candidate / Threshold Pending)*

**Ground Truth Firewall:** Critical Frozen Decision *(Ground Truth Firewall: Critical Frozen Decision)*

**Evaluation GNSS During Denial:** Loggable but Estimator-Blocked *(Evaluation GNSS During Denial: Loglanabilir ancak Estimator-Blocked)*

**Unauthorized GNSS Update Count:** Must Equal `0` *(Unauthorized GNSS Update Count: `0` Olmalı)*

**Protected GNSS as AI Feature:** Rejected *(Protected GNSS’in AI Feature Olması: Reddedildi)*

**Denial Resets EKF:** No *(Denial EKF’yi Resetler mi: Hayır)*

**Recovery First Fix Auto-Accept:** Rejected *(Recovery First Fix Auto-Accept: Reddedildi)*

**Pre-Correction Snapshot:** Critical Mandatory *(Pre-Correction Snapshot: Critical Mandatory)*

**Final Denied Error:** Pre-Correction *(Final Denied Error: Pre-Correction)*

**Historical Denied Trajectory Rewrite:** Rejected *(Historical Denied Trajectory Rewrite: Reddedildi)*

**Recovery Covariance Reset to Zero:** Rejected *(Recovery Covariance Reset to Zero: Reddedildi)*

**Map Role:** Visualization Only *(Map Role: Yalnızca Visualization)*

**Hidden Map Matching:** Rejected *(Hidden Map Matching: Reddedildi)*

**Storage Architecture:** SQLite Metadata + Append Streams + JSON Manifests *(Storage Architecture: SQLite Metadata + Append Streams + JSON Manifest’ler)*

**Raw Finalized Data:** Immutable *(Raw Finalized Data: Immutable)*

**High-Frequency Per-Sample SQLite Transactions:** Rejected *(High-Frequency Per-Sample SQLite Transaction’lar: Reddedildi)*

**Writer Queues:** Bounded *(Writer Queue’ları: Bounded)*

**Silent Log Drops:** Rejected *(Silent Log Drop’lar: Reddedildi)*

**Replay:** Mandatory *(Replay: Mandatory)*

**Replay Ground Truth Firewall:** Mandatory *(Replay Ground Truth Firewall: Mandatory)*

**Formal Configurations:** A / B / C / D *(Formal Configuration’lar: A / B / C / D)*

**Primary Comparison:** A vs D *(Primary Comparison: A vs D)*

**Primary Metric:** Aggregated Matched-Session Median Horizontal Position Error *(Primary Metric: Aggregated Matched-Session Median Horizontal Position Error)*

**Primary Target:** `≥20%` Reduction *(Primary Target: `≥20%` Reduction)*

**Primary Aggregation:** Session-Level First *(Primary Aggregation: Önce Session-Level)*

**Result-Based Session Exclusion:** Rejected *(Result-Based Session Exclusion: Reddedildi)*

**Final Benchmark Tuning:** Rejected *(Final Benchmark Tuning: Reddedildi)*

**Research Outcome Categories:** `TARGET_MET / PARTIAL_IMPROVEMENT / NO_MEASURABLE_IMPROVEMENT / REGRESSION / INCONCLUSIVE` *(Research Outcome Category’leri: `TARGET_MET / PARTIAL_IMPROVEMENT / NO_MEASURABLE_IMPROVEMENT / REGRESSION / INCONCLUSIVE`)*

**Software Completion vs Research Success:** Separate *(Software Completion vs Research Success: Separate)*

**Unmeasured Final Values:** `TBD` *(Unmeasured Final Value’lar: `TBD`)*

**Formal Performance Device:** Redmi Note 9 Pro *(Formal Performance Device: Redmi Note 9 Pro)*

**Failure Injection:** Mandatory *(Failure Injection: Mandatory)*

**Endurance Test:** Mandatory *(Endurance Test: Mandatory)*

**Participant Scope:** Controlled / Limited *(Participant Scope: Controlled / Limited)*

**Phone Placement:** One Controlled Final Placement *(Phone Placement: One Controlled Final Placement)*

**Cross-Device Generalization:** Not Claimed *(Cross-Device Generalization: Claim Edilmez)*

**Population-Level Generalization:** Not Claimed *(Population-Level Generalization: Claim Edilmez)*

**Smartphone GNSS:** Imperfect Evaluation Reference *(Smartphone GNSS: Imperfect Evaluation Reference)*

**Military-Grade Claim:** Rejected *(Military-Grade Claim: Reddedildi)*

**Permanent GNSS Replacement Claim:** Rejected *(Permanent GNSS Replacement Claim: Reddedildi)*

**Future Work Priority:** Measured Bottlenecks First *(Future Work Priority: Önce Measured Bottleneck’ler)*

**Known EKF Documentation Inconsistency:** Corrected in This Page *(Known EKF Documentation Inconsistency: Bu Page’de Düzeltildi)*

**Known Quality-State Terminology Inconsistency:** Corrected in This Page *(Known Quality-State Terminology Inconsistency: Bu Page’de Düzeltildi)*

**Page 03 — Project Scope & Boundaries:** Completed; Earlier Missing/Unwritten Status Resolved *(Page 03 — Project Scope & Boundaries: Tamamlandı; Önceki Missing/Unwritten Status Çözüldü)*

**Implementation-Derived Change Records:** None Yet *(Implementation-Derived Change Record’lar: Henüz Yok)*

**Next Documentation Item:** 44 — References & Technical Resources *(Sonraki Dokümantasyon Öğesi: 44 — Referanslar ve Teknik Kaynaklar)*
