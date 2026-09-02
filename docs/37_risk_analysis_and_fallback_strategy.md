# 37 — Risk Analysis & Fallback Strategy (Risk Analizi ve Fallback Stratejisi)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the technical, operational, experimental, platform, data-integrity, performance, and project-delivery risks of NAVGUARD and specifies the deterministic fallback behavior that will be used when those risks become active. *(Bu doküman NAVGUARD'ın teknik, operasyonel, deneysel, platform, veri bütünlüğü, performans ve proje teslim risklerini tanımlar ve bu riskler aktif hale geldiğinde kullanılacak deterministik fallback davranışını belirtir.)*

The objective is to prevent a single degraded subsystem from causing uncontrolled navigation behavior, hidden evidence corruption, or complete application failure when a safer reduced-capability mode remains possible. *(Amaç daha güvenli azaltılmış capability modu mümkünken tek bir degraded alt sistemin kontrolsüz navigasyon davranışına, gizli evidence corruption'a veya tam uygulama failure'ına neden olmasını önlemektir.)*

---

# 2. Risk Philosophy (Risk Felsefesi)

NAVGUARD will prefer explicit degradation over silent failure. *(NAVGUARD sessiz failure yerine explicit degradation tercih edecektir.)*

A subsystem that becomes unreliable must either be down-weighted, rejected, replaced by a defined fallback, or declared unavailable. *(Unreliable hale gelen alt sistem ya down-weight edilmeli, reddedilmeli, tanımlanmış fallback ile değiştirilmelidir ya da unavailable ilan edilmelidir.)*

---

# 3. Safety Before Continuity (Süreklilikten Önce Güvenlik)

NAVGUARD will not preserve continuous position output at any cost. *(NAVGUARD continuous position output'u her ne pahasına olursa olsun korumayacaktır.)*

If the remaining information is insufficient for a defensible estimate, the system will prefer `UNRELIABLE` or `UNAVAILABLE` over fabricating confident motion. *(Kalan bilgi savunulabilir estimate için yetersizse sistem confident motion uydurmak yerine `UNRELIABLE` veya `UNAVAILABLE` tercih edecektir.)*

---

# 4. Integrity Before Performance (Performanstan Önce Bütünlük)

Experimental integrity has higher priority than producing a visually successful demonstration. *(Deneysel bütünlük görsel olarak başarılı demonstration üretmekten daha yüksek önceliğe sahiptir.)*

A Ground Truth Firewall violation cannot be hidden by good position accuracy. *(Ground Truth Firewall violation iyi position accuracy ile gizlenemez.)*

---

# 5. Fallback Philosophy (Fallback Felsefesi)

Fallback behavior will be deterministic and documented. *(Fallback davranışı deterministik ve dokümante edilmiş olacaktır.)*

The same failure condition and frozen configuration should produce the same fallback decision. *(Aynı failure condition ve frozen configuration aynı fallback decision'ı üretmelidir.)*

---

# 6. Core Fallback Principle (Temel Fallback İlkesi)

NAVGUARD will degrade from more complex optional sources toward the minimum deterministic PDR capability whenever that capability remains physically valid. *(NAVGUARD fiziksel olarak geçerli kaldığı sürece daha kompleks optional source'lardan minimum deterministic PDR capability'ye doğru degrade olacaktır.)*

---

# 7. Minimum Navigation Backbone (Minimum Navigasyon Omurgası)

The minimum navigation backbone consists of accepted step events, a usable heading source, deterministic step-length fallback, local ENU propagation, and valid timing. *(Minimum navigasyon omurgası accepted step event'leri, usable heading source, deterministic step-length fallback, local ENU propagation ve valid timing'den oluşur.)*

---

# 8. Optional Enhancement Principle (İsteğe Bağlı Geliştirme İlkesi)

ARCore, AI motion context, and learned step length are enhancements rather than single points of total system failure. *(ARCore, AI motion context ve learned step length tam sistem için single point of failure olmak yerine enhancement'tır.)*

---

# 9. Risk Categories (Risk Kategorileri)

NAVGUARD risks will be organized into the following categories. *(NAVGUARD riskleri aşağıdaki kategorilerde düzenlenecektir.)*

```text
SENSOR
TIMING
HEADING
STEP DETECTION
STEP LENGTH
AI
ARCORE
EKF / FUSION
GNSS
GROUND TRUTH
RECOVERY
STORAGE / LOGGING
PERMISSION
PERFORMANCE
BATTERY
THERMAL
UI
MODEL / ARTIFACT
FIELD EXPERIMENT
PROJECT SCHEDULE
RESEARCH VALIDITY
```

---

# 10. Risk Severity Model (Risk Önem Modeli)

Risks will use four severity levels. *(Riskler dört severity level kullanacaktır.)*

```text
CRITICAL
HIGH
MEDIUM
LOW
```

---

# 11. CRITICAL Risk Meaning (CRITICAL Risk Anlamı)

A critical risk can invalidate the experiment, corrupt authoritative evidence, or make navigation behavior scientifically indefensible. *(Critical risk deneyi invalid hale getirebilir, authoritative evidence'ı bozabilir veya navigation behavior'ı bilimsel olarak savunulamaz hale getirebilir.)*

---

# 12. HIGH Risk Meaning (HIGH Risk Anlamı)

A high risk can materially degrade navigation or prevent completion of a planned formal session. *(High risk navigasyonu anlamlı şekilde degrade edebilir veya planlanmış formal session'ın tamamlanmasını önleyebilir.)*

---

# 13. MEDIUM Risk Meaning (MEDIUM Risk Anlamı)

A medium risk affects robustness, usability, or secondary subsystem performance but usually permits controlled fallback. *(Medium risk robustness, usability veya secondary subsystem performance'ı etkiler ancak genellikle controlled fallback'e izin verir.)*

---

# 14. LOW Risk Meaning (LOW Risk Anlamı)

A low risk affects convenience, diagnostics, or non-critical presentation without threatening estimator integrity. *(Low risk convenience, diagnostics veya non-critical presentation'ı etkiler ancak estimator integrity'yi tehdit etmez.)*

---

# 15. Risk Probability Model (Risk Olasılık Modeli)

Probability will be assessed qualitatively until sufficient implementation evidence exists. *(Yeterli implementation evidence mevcut olana kadar probability qualitative olarak değerlendirilecektir.)*

```text
UNLIKELY
POSSIBLE
LIKELY
OBSERVED
```

---

# 16. Risk Priority (Risk Önceliği)

Risk priority will consider both severity and probability. *(Risk priority hem severity hem probability'yi dikkate alacaktır.)*

No fabricated numerical risk score will be used before evidence exists. *(Evidence mevcut olmadan uydurulmuş numerical risk score kullanılmayacaktır.)*

---

# 17. Risk Lifecycle (Risk Yaşam Döngüsü)

Each major risk will move through an explicit lifecycle. *(Her major risk explicit lifecycle üzerinden ilerleyecektir.)*

```text
IDENTIFIED
MONITORED
MITIGATED
ACCEPTED
TRIGGERED
RESOLVED
RETIRED
```

---

# 18. Risk Register (Risk Kaydı)

A structured project risk register will be maintained. *(Structured project risk register tutulacaktır.)*

---

# 19. Candidate Risk Record (Aday Risk Kaydı)

```text
RiskRecord
- riskId
- category
- description
- severity
- probability
- detectionSignal
- mitigation
- fallback
- invalidationRule
- owner
- status
- evidence
```

---

# 20. Risk Detection Must Be Observable (Risk Tespiti Gözlemlenebilir Olmalıdır)

A runtime fallback should be triggered by measurable state rather than vague intuition whenever possible. *(Runtime fallback mümkün olduğunda belirsiz intuition yerine measurable state tarafından tetiklenmelidir.)*

---

# 21. Quality Engine Integration (Quality Engine Entegrasyonu)

Many sensor-related fallbacks will be driven through the quality states defined in Page 20. *(Sensörle ilişkili birçok fallback Page 20'de tanımlanan quality state'ler üzerinden yönlendirilecektir.)*

```text
UNKNOWN
GOOD
USABLE
DEGRADED
UNRELIABLE
UNAVAILABLE
```

---

# 22. Availability and Quality Remain Separate (Availability ve Quality Ayrı Kalır)

A sensor can be available but unreliable. *(Bir sensör available ancak unreliable olabilir.)*

A missing sensor can be unavailable without being assigned an artificial low confidence value. *(Missing sensor artificial low confidence value verilmeden unavailable olabilir.)*

---

# 23. General Source Fallback Sequence (Genel Kaynak Fallback Sırası)

The general source policy is to use valid high-quality information first, degraded information only with increased uncertainty when permitted, and reject invalid information completely. *(Genel source politikası önce valid high-quality information kullanmak, izin verildiğinde degraded information'ı increased uncertainty ile kullanmak ve invalid information'ı tamamen reddetmektir.)*

---

# 24. Hard Invalidity vs Soft Degradation (Sert Geçersizlik ile Yumuşak Bozulma)

Hard-invalid measurements will never be rescued merely by inflating covariance. *(Hard-invalid measurement'lar yalnızca covariance artırılarak hiçbir zaman kurtarılmayacaktır.)*

Soft-degraded measurements may remain usable with larger uncertainty when scientifically justified. *(Soft-degraded measurement'lar bilimsel olarak gerekçelendirildiğinde larger uncertainty ile usable kalabilir.)*

---

# 25. Sensor Availability Risk (Sensör Kullanılabilirlik Riski)

A required motion sensor may be unavailable at runtime despite being expected from the target device. *(Gerekli motion sensor target device'da beklenmesine rağmen runtime'da unavailable olabilir.)*

---

# 26. Accelerometer Failure Severity (İvmeölçer Hatası Önem Seviyesi)

Loss of the authoritative accelerometer is a high-to-critical navigation risk because step detection depends on it. *(Authoritative accelerometer kaybı step detection ona bağlı olduğu için high-to-critical navigation risk'tir.)*

---

# 27. Accelerometer Fallback (İvmeölçer Fallback'i)

If the accelerometer becomes unavailable, authoritative step-based PDR will stop propagating position. *(Accelerometer unavailable hale gelirse authoritative step-based PDR position propagation'ı durduracaktır.)*

The system will not fabricate steps from another unrelated source. *(Sistem başka unrelated source'dan step uydurmayacaktır.)*

---

# 28. Accelerometer Loss Navigation State (İvmeölçer Kaybı Navigasyon Durumu)

If no defensible displacement source remains, navigation quality will become `UNAVAILABLE`. *(Savunulabilir displacement source kalmazsa navigation quality `UNAVAILABLE` olacaktır.)*

---

# 29. Gyroscope Failure Risk (Jiroskop Hata Riski)

Gyroscope loss reduces short-term heading stability and motion-feature quality. *(Gyroscope kaybı short-term heading stability ve motion-feature quality'yi azaltır.)*

---

# 30. Gyroscope Fallback (Jiroskop Fallback'i)

If gyroscope data becomes unavailable, the heading subsystem may fall back to a magnetometer/accelerometer-based absolute heading method if that method remains usable. *(Gyroscope verisi unavailable hale gelirse heading subsystem yöntem usable kaldığı sürece magnetometer/accelerometer-based absolute heading method'a fallback yapabilir.)*

---

# 31. Gyroscope Fallback Quality (Jiroskop Fallback Kalitesi)

Gyroscope loss will lower heading quality and increase uncertainty rather than pretending no degradation occurred. *(Gyroscope kaybı degradation olmamış gibi davranmak yerine heading quality'yi düşürecek ve uncertainty'yi artıracaktır.)*

---

# 32. Magnetometer Failure Risk (Manyetometre Hata Riski)

Magnetometer failure removes an important absolute orientation reference. *(Magnetometer failure önemli absolute orientation reference'ı kaldırır.)*

---

# 33. Magnetometer Fallback (Manyetometre Fallback'i)

Short-term heading may continue through gyroscope propagation or a validated rotation-vector source if available. *(Short-term heading gyroscope propagation veya available ise validated rotation-vector source üzerinden devam edebilir.)*

---

# 34. Magnetometer Loss Long-Term Risk (Manyetometre Kaybının Uzun Vadeli Riski)

Without an Earth-referenced heading correction, heading drift may grow over time. *(Earth-referenced heading correction olmadan heading drift zamanla büyüyebilir.)*

---

# 35. Heading Unavailable Gate (Heading Unavailable Gate'i)

If no usable heading source remains, step-based ENU displacement will not continue as if heading were known. *(Usable heading source kalmazsa step-based ENU displacement heading biliniyormuş gibi devam etmeyecektir.)*

---

# 36. Rotation Vector Failure Risk (Rotation Vector Hata Riski)

Rotation Vector is a high-priority aid but is not the sole heading source. *(Rotation Vector high-priority aid'dir ancak sole heading source değildir.)*

---

# 37. Rotation Vector Fallback (Rotation Vector Fallback'i)

If Rotation Vector becomes unavailable or unreliable, NAVGUARD will revert to the underlying validated heading fusion path. *(Rotation Vector unavailable veya unreliable hale gelirse NAVGUARD underlying validated heading fusion path'e dönecektir.)*

---

# 38. Sensor Accuracy Flag Risk (Sensör Accuracy Flag Riski)

Android sensor accuracy flags may indicate degraded sensor calibration. *(Android sensor accuracy flag'leri degraded sensor calibration gösterebilir.)*

---

# 39. Accuracy Flag Handling (Accuracy Flag Yönetimi)

Sensor accuracy flags will inform quality but will not be the only quality criterion. *(Sensor accuracy flag'leri quality'yi bilgilendirecek ancak tek quality criterion olmayacaktır.)*

---

# 40. Sensor Freeze Risk (Sensör Donma Riski)

A sensor stream may remain technically registered while its timestamps stop advancing. *(Sensor stream teknik olarak registered kalırken timestamp'leri ilerlemeyi durdurabilir.)*

---

# 41. Sensor Freeze Detection (Sensör Donma Tespiti)

Freshness and timestamp progression checks will detect frozen streams. *(Freshness ve timestamp progression check'leri frozen stream'leri tespit edecektir.)*

---

# 42. Sensor Freeze Fallback (Sensör Donma Fallback'i)

Frozen measurements will not be reused indefinitely. *(Frozen measurement'lar sonsuza kadar yeniden kullanılmayacaktır.)*

The affected source will become stale and then unavailable according to the frozen freshness policy. *(Etkilenen source frozen freshness policy'ye göre stale ve ardından unavailable olacaktır.)*

---

# 43. Sensor Rate Degradation Risk (Sensör Rate Bozulma Riski)

Android may deliver motion sensors at a lower or more irregular rate than requested. *(Android motion sensor'ları requested'dan daha düşük veya daha irregular rate'te deliver edebilir.)*

---

# 44. Sensor Rate Fallback (Sensör Rate Fallback'i)

Preprocessing will use actual timestamps and tolerate bounded irregularity. *(Preprocessing actual timestamp'ları kullanacak ve bounded irregularity'yi tolere edecektir.)*

If gaps exceed allowed limits, affected windows or measurements will be invalidated. *(Gap'ler allowed limit'leri aşarsa affected window veya measurement'lar invalidated olacaktır.)*

---

# 45. Timing Risk (Zamanlama Riski)

Incorrect clock-domain assumptions can corrupt sensor fusion without producing obvious runtime errors. *(Yanlış clock-domain assumption'ları obvious runtime error üretmeden sensor fusion'ı bozabilir.)*

---

# 46. Timing Risk Severity (Zamanlama Riskinin Önem Seviyesi)

Timestamp-domain errors are high-to-critical risks because they can invalidate replay and fusion while leaving apparently plausible trajectories. *(Timestamp-domain error'ları apparently plausible trajectory bırakırken replay ve fusion'ı invalid hale getirebildiği için high-to-critical risk'tir.)*

---

# 47. Timing Fallback (Zamanlama Fallback'i)

A source whose clock mapping cannot be validated will not enter tightly synchronized fusion. *(Clock mapping'i validated edilemeyen source tightly synchronized fusion'a girmeyecektir.)*

---

# 48. ARCore Timing Risk (ARCore Zamanlama Riski)

ARCore frame timestamps will not be assumed to use the same clock domain as Android sensor timestamps without physical validation. *(ARCore frame timestamp'lerinin physical validation olmadan Android sensor timestamp'leriyle aynı clock domain kullandığı varsayılmayacaktır.)*

---

# 49. ARCore Timing Fallback (ARCore Zamanlama Fallback'i)

If ARCore timestamp mapping remains uncertain, ARCore may remain diagnostic-only until alignment is validated. *(ARCore timestamp mapping uncertain kalırsa ARCore alignment validated olana kadar diagnostic-only kalabilir.)*

---

# 50. Out-of-Order Event Risk (Sıra Dışı Event Riski)

Asynchronous sensor events may arrive out of processing order. *(Asynchronous sensor event'leri processing order dışında gelebilir.)*

---

# 51. Out-of-Order Fallback (Sıra Dışı Event Fallback'i)

The fusion pipeline will use timestamp ordering and a deterministic late-event policy. *(Fusion pipeline timestamp ordering ve deterministic late-event policy kullanacaktır.)*

Events that arrive too late for safe causal processing may be logged but rejected from live state updates. *(Safe causal processing için çok geç gelen event'ler logged edilebilir ancak live state update'lerden rejected olacaktır.)*

---

# 52. Heading Risk Category (Heading Risk Kategorisi)

Heading error is one of the highest-impact PDR risks because small angular bias accumulates into lateral position drift. *(Heading error küçük angular bias lateral position drift'e biriktiği için en yüksek etkili PDR risklerinden biridir.)*

---

# 53. Magnetic Disturbance Risk (Manyetik Bozulma Riski)

Nearby metal structures, electronics, or environmental magnetic anomalies may corrupt magnetometer-based heading. *(Yakındaki metal structure'lar, electronic cihazlar veya environmental magnetic anomaly'ler magnetometer-based heading'i bozabilir.)*

---

# 54. Magnetic Disturbance Detection (Manyetik Bozulma Tespiti)

The heading-quality subsystem will monitor magnetic plausibility, continuity, sensor accuracy, and cross-source consistency. *(Heading-quality subsystem magnetic plausibility, continuity, sensor accuracy ve cross-source consistency'yi izleyecektir.)*

---

# 55. Magnetic Disturbance Fallback (Manyetik Bozulma Fallback'i)

When magnetometer quality becomes unreliable, absolute magnetic corrections will be rejected or reduced while short-term gyro propagation continues if valid. *(Magnetometer quality unreliable hale geldiğinde absolute magnetic correction'lar rejected veya reduced edilirken valid ise short-term gyro propagation devam edecektir.)*

---

# 56. Magnetic Disturbance EKF Response (Manyetik Bozulma EKF Tepkisi)

Heading measurement covariance may be increased for soft degradation, but hard-invalid measurements will be rejected. *(Soft degradation için heading measurement covariance artırılabilir ancak hard-invalid measurement'lar rejected olacaktır.)*

---

# 57. Persistent Heading Degradation (Sürekli Heading Bozulması)

If heading remains unreliable for too long, position uncertainty must increase accordingly. *(Heading çok uzun süre unreliable kalırsa position uncertainty buna göre artmalıdır.)*

---

# 58. Heading Failure Stop Condition (Heading Hata Durdurma Koşulu)

If heading becomes unusable and no validated relative-direction source can compensate, step propagation may be suspended. *(Heading unusable hale gelir ve validated relative-direction source telafi edemezse step propagation suspend edilebilir.)*

---

# 59. Step Detection Risk (Adım Tespit Riski)

False positive or missed steps directly bias travelled distance. *(False positive veya missed step'ler travelled distance'ı doğrudan bias eder.)*

---

# 60. False Step Risk (False Step Riski)

Phone handling, shaking, or stationary vibration may create false peaks. *(Telefon handling, shaking veya stationary vibration false peak oluşturabilir.)*

---

# 61. False Step Fallback (False Step Fallback'i)

The deterministic detector will use refractory timing, waveform plausibility, and calibrated thresholds. *(Deterministic detector refractory timing, waveform plausibility ve calibrated threshold'lar kullanacaktır.)*

---

# 62. AI Stationary Support (AI Stationary Desteği)

Validated `STATIONARY` motion context may suppress false propagation but will not replace the deterministic step detector. *(Validated `STATIONARY` motion context false propagation'ı suppress edebilir ancak deterministic step detector'ın yerini almayacaktır.)*

---

# 63. Missed Step Risk (Kaçırılan Adım Riski)

Low-amplitude or unusual gait may cause missed detections. *(Low-amplitude veya unusual gait missed detection'a neden olabilir.)*

---

# 64. Missed Step Fallback Limitation (Kaçırılan Adım Fallback Sınırlaması)

NAVGUARD will not invent missed steps after the fact unless a validated alternative detector exists. *(Validated alternative detector mevcut değilse NAVGUARD kaçırılan step'leri sonradan uydurmayacaktır.)*

---

# 65. Android Built-In Step Sensor Role (Android Built-In Step Sensor Rolü)

Android step detector or counter may remain a diagnostic comparison source. *(Android step detector veya counter diagnostic comparison source olarak kalabilir.)*

It will not silently override the authoritative NAVGUARD detector. *(Authoritative NAVGUARD detector'ı sessizce override etmeyecektir.)*

---

# 66. Step-Length Risk (Adım Uzunluğu Riski)

Systematic step-length bias can accumulate into large distance error over long denied intervals. *(Systematic step-length bias uzun denied interval'larda büyük distance error'a birikebilir.)*

---

# 67. Learned Step-Length Failure (Learned Step-Length Failure)

A learned model may output NaN, infinity, negative length, implausible length, or out-of-distribution values. *(Learned model NaN, infinity, negative length, implausible length veya out-of-distribution value üretebilir.)*

---

# 68. Step-Length Fallback Hierarchy (Adım Uzunluğu Fallback Hiyerarşisi)

```text
LEARNED MODEL
      ↓
DETERMINISTIC VARIABLE MODEL
      ↓
CALIBRATED FIXED STEP LENGTH
```

---

# 69. Learned Model Rejection (Learned Model Reddetme)

Invalid learned outputs will be rejected before entering PDR or EKF propagation. *(Invalid learned output'lar PDR veya EKF propagation'a girmeden önce rejected olacaktır.)*

---

# 70. Deterministic Variable Fallback (Deterministic Variable Fallback)

A validated deterministic variable model such as a calibrated Weinberg-style method may be the first fallback. *(Validated deterministic variable model, örneğin calibrated Weinberg-style method, ilk fallback olabilir.)*

---

# 71. Fixed-Length Final Fallback (Sabit Uzunluk Final Fallback)

If the variable method is unavailable or unreliable, a calibrated fixed step length will remain the final deterministic fallback. *(Variable method unavailable veya unreliable ise calibrated fixed step length final deterministic fallback olarak kalacaktır.)*

---

# 72. Step-Length Uncertainty (Adım Uzunluğu Belirsizliği)

Fallback does not imply zero uncertainty. *(Fallback sıfır uncertainty anlamına gelmez.)*

Each step-length method will carry an empirically derived uncertainty profile when available. *(Her step-length method available olduğunda empirically derived uncertainty profile taşıyacaktır.)*

---

# 73. Motion AI Risk (Motion AI Riski)

The motion classifier may misclassify walking context, become stale, fail to load, or produce low-confidence output. *(Motion classifier walking context'i misclassify edebilir, stale hale gelebilir, load edemeyebilir veya low-confidence output üretebilir.)*

---

# 74. AI Is Not a Single Point of Failure (AI Single Point of Failure Değildir)

Core step detection and PDR must continue without Motion Classification when deterministic inputs remain valid. *(Deterministic input'lar valid kaldığında core step detection ve PDR Motion Classification olmadan devam etmelidir.)*

---

# 75. AI Failure Fallback (AI Hata Fallback'i)

```text
VALID AI CONTEXT
      ↓
UNKNOWN / LOW-CONFIDENCE AI CONTEXT
      ↓
DETERMINISTIC NAVIGATION POLICY
```

---

# 76. AI Low Confidence (AI Düşük Güven)

Low-confidence output may be converted to controller state `UNKNOWN` rather than forcing one of the four trained classes into navigation logic. *(Low-confidence output dört trained class'tan birini navigation logic'e zorlamak yerine controller state `UNKNOWN` haline getirilebilir.)*

---

# 77. AI Stale Output Risk (AI Stale Output Riski)

An old motion classification can become dangerous if reused after the physical context changes. *(Eski motion classification fiziksel context değiştikten sonra yeniden kullanılırsa riskli hale gelebilir.)*

---

# 78. AI Freshness Fallback (AI Freshness Fallback'i)

Stale AI context will expire according to the frozen freshness policy. *(Stale AI context frozen freshness policy'ye göre expire olacaktır.)*

---

# 79. AI Model Load Failure (AI Model Load Hatası)

If the model cannot be loaded or validated, navigation will fall back to deterministic policies. *(Model load veya validate edilemezse navigation deterministic policy'lere fallback yapacaktır.)*

---

# 80. AI Model Hash Failure (AI Model Hash Hatası)

A model hash mismatch in Benchmark Mode will block that model from navigation-enabled use. *(Benchmark Mode içerisinde model hash mismatch ilgili modelin navigation-enabled kullanımını block edecektir.)*

---

# 81. AI Runtime Exception (AI Runtime Exception)

Inference exceptions will not trigger uncontrolled immediate retry loops. *(Inference exception'ları uncontrolled immediate retry loop tetiklemeyecektir.)*

---

# 82. AI Retry Policy (AI Retry Politikası)

A bounded retry or controlled reinitialization policy may be used outside the critical sensor callback path. *(Bounded retry veya controlled reinitialization policy critical sensor callback path dışında kullanılabilir.)*

---

# 83. AI Performance Degradation Risk (AI Performans Bozulma Riski)

Thermal pressure or runtime contention may make inference too slow. *(Thermal pressure veya runtime contention inference'ı çok yavaş hale getirebilir.)*

---

# 84. AI Latency Fallback (AI Latency Fallback'i)

If AI cannot sustain causal operation, stale inference windows will be dropped and deterministic navigation will continue. *(AI causal operation'ı sürdüremezse stale inference window'lar dropped edilecek ve deterministic navigation devam edecektir.)*

---

# 85. AI Navigation Benefit Risk (AI Navigasyon Fayda Riski)

A model may achieve good classification metrics but provide no measurable navigation improvement. *(Model iyi classification metric üretirken measurable navigation improvement sağlamayabilir.)*

---

# 86. AI Retention Rule (AI Koruma Kuralı)

AI navigation influence will only remain enabled if replay and field evidence show defensible benefit or robustness value. *(AI navigation influence yalnızca replay ve field evidence savunulabilir benefit veya robustness value gösterirse enabled kalacaktır.)*

---

# 87. ARCore Risk Category (ARCore Risk Kategorisi)

ARCore introduces visual-tracking, camera, lifecycle, timestamp, performance, and coordinate-alignment risks. *(ARCore visual-tracking, camera, lifecycle, timestamp, performance ve coordinate-alignment riskleri getirir.)*

---

# 88. ARCore Unavailable Risk (ARCore Kullanılamama Riski)

ARCore may be unsupported, unavailable, not installed correctly, or blocked by camera permission. *(ARCore unsupported, unavailable, incorrectly installed veya camera permission tarafından blocked olabilir.)*

---

# 89. ARCore Availability Fallback (ARCore Kullanılabilirlik Fallback'i)

ARCore-dependent configurations will fall back to PDR-based navigation when the selected experiment policy permits it. *(Selected experiment policy izin verdiğinde ARCore-dependent configuration'lar PDR-based navigation'a fallback yapacaktır.)*

---

# 90. Configuration Integrity During ARCore Fallback (ARCore Fallback Sırasında Configuration Bütünlüğü)

A formal Configuration C or D benchmark must record that ARCore became unavailable rather than silently pretending the configuration remained fully active. *(Formal Configuration C veya D benchmark ARCore unavailable hale geldiğinde configuration tamamen active kalmış gibi davranmak yerine bunu kaydetmelidir.)*

---

# 91. ARCore Tracking Loss Risk (ARCore Tracking Kaybı Riski)

ARCore may enter `PAUSED` because of low visual texture, poor lighting, excessive motion, or camera problems. *(ARCore low visual texture, poor lighting, excessive motion veya camera problem nedeniyle `PAUSED` durumuna girebilir.)*

---

# 92. ARCore Tracking Loss Fallback (ARCore Tracking Kaybı Fallback'i)

`PAUSED` ARCore poses will not enter navigation fusion. *(`PAUSED` ARCore pose'ları navigation fusion'a girmeyecektir.)*

PDR will continue when its own inputs remain valid. *(PDR kendi input'ları valid kaldığında devam edecektir.)*

---

# 93. No Fake Zero Motion (Sahte Sıfır Hareket Olmaması)

Tracking loss will not be represented as zero visual motion measurement. *(Tracking loss zero visual motion measurement olarak temsil edilmeyecektir.)*

---

# 94. ARCore Recovery Risk (ARCore Recovery Riski)

Tracking recovery may introduce a discontinuity or new local world alignment. *(Tracking recovery discontinuity veya yeni local world alignment getirebilir.)*

---

# 95. ARCore Recovery Fallback (ARCore Recovery Fallback'i)

Recovered tracking will generally begin a new ARCore segment unless continuity is explicitly validated. *(Recovered tracking continuity explicitly validated değilse genellikle yeni ARCore segment başlatacaktır.)*

---

# 96. ARCore Segment Isolation (ARCore Segment İzolasyonu)

A new segment will not be connected to the previous segment with an assumed zero-offset transformation. *(Yeni segment previous segment'e assumed zero-offset transformation ile bağlanmayacaktır.)*

---

# 97. ARCore Coordinate Alignment Risk (ARCore Koordinat Hizalama Riski)

Incorrect axis mapping can rotate or mirror relative displacement. *(Incorrect axis mapping relative displacement'ı rotate veya mirror edebilir.)*

---

# 98. ARCore Alignment Fallback (ARCore Alignment Fallback'i)

If ARCore-to-ENU alignment is not validated, ARCore will remain excluded from formal fusion. *(ARCore-to-ENU alignment validated değilse ARCore formal fusion'dan excluded kalacaktır.)*

---

# 99. No Hardcoded Axis Assumption (Hardcoded Axis Varsayımı Olmaması)

NAVGUARD will not assume that ARCore X automatically equals East or that ARCore Z automatically equals North. *(NAVGUARD ARCore X'in otomatik olarak East veya ARCore Z'nin otomatik olarak North olduğunu varsaymayacaktır.)*

---

# 100. ARCore Drift Risk (ARCore Drift Riski)

Relative visual-inertial tracking can itself drift. *(Relative visual-inertial tracking kendisi de drift edebilir.)*

---

# 101. ARCore Drift Handling (ARCore Drift Yönetimi)

ARCore will be treated as a quality-weighted relative source rather than infallible truth. *(ARCore infallible truth yerine quality-weighted relative source olarak ele alınacaktır.)*

---

# 102. ARCore Resource Pressure Risk (ARCore Kaynak Baskısı Riski)

ARCore may materially increase CPU, battery, and thermal load. *(ARCore CPU, battery ve thermal load'u anlamlı şekilde artırabilir.)*

---

# 103. ARCore Resource Fallback (ARCore Kaynak Fallback'i)

If ARCore becomes operationally impractical, PDR remains the mandatory fallback navigation source. *(ARCore operationally impractical hale gelirse PDR mandatory fallback navigation source olarak kalır.)*

---

# 104. EKF Risk Category (EKF Risk Kategorisi)

The EKF can fail through numerical instability, poor noise calibration, stale measurements, outliers, or incorrect model assumptions. *(EKF numerical instability, poor noise calibration, stale measurement, outlier veya incorrect model assumption nedeniyle fail olabilir.)*

---

# 105. Covariance Miscalibration Risk (Covariance Yanlış Kalibrasyon Riski)

Underestimated covariance can make the filter dangerously overconfident. *(Underestimated covariance filter'ı tehlikeli şekilde overconfident hale getirebilir.)*

---

# 106. Conservative Covariance Preference (Temkinli Kovaryans Tercihi)

During early development, conservative uncertainty is preferable to unjustified overconfidence. *(Early development sırasında conservative uncertainty unjustified overconfidence'a tercih edilir.)*

---

# 107. EKF Invalid Covariance Risk (EKF Geçersiz Kovaryans Riski)

NaN, infinity, strong asymmetry, or materially invalid negative eigenvalues indicate a filter failure. *(NaN, infinity, strong asymmetry veya materially invalid negative eigenvalue filter failure gösterir.)*

---

# 108. EKF Numerical Fallback (EKF Sayısal Fallback'i)

Invalid EKF state will not be published as trustworthy fused navigation. *(Invalid EKF state trustworthy fused navigation olarak publish edilmeyecektir.)*

---

# 109. EKF Recovery Candidate (EKF Recovery Adayı)

A controlled filter reinitialization from the latest valid navigation state and conservative covariance may be used if scientifically justified. *(Scientifically justified ise latest valid navigation state ve conservative covariance'dan controlled filter reinitialization kullanılabilir.)*

---

# 110. EKF Failure Fallback (EKF Hata Fallback'i)

If fused-state recovery is unsafe, the system may continue with the independent PDR safety baseline. *(Fused-state recovery unsafe ise sistem independent PDR safety baseline ile devam edebilir.)*

---

# 111. Independent PDR Protection (Bağımsız PDR Koruması)

EKF output will not overwrite or destroy the independent baseline PDR trajectory. *(EKF output independent baseline PDR trajectory'yi overwrite veya destroy etmeyecektir.)*

---

# 112. Innovation Outlier Risk (Innovation Outlier Riski)

A bad measurement can cause an abrupt estimator jump. *(Bad measurement abrupt estimator jump'a neden olabilir.)*

---

# 113. Innovation Gating Fallback (Innovation Gating Fallback'i)

Measurements failing the frozen innovation gate will be rejected rather than forcibly assimilated. *(Frozen innovation gate'i geçemeyen measurement'lar forcibly assimilated edilmek yerine rejected olacaktır.)*

---

# 114. NIS Gate Risk (NIS Gate Riski)

An incorrectly tuned NIS threshold may reject too much data or accept too many outliers. *(Incorrectly tuned NIS threshold çok fazla data reject edebilir veya çok fazla outlier accept edebilir.)*

---

# 115. NIS Threshold Freeze (NIS Threshold Freeze)

The final gate threshold will be calibrated before final benchmark and will not be tuned after viewing benchmark outcomes. *(Final gate threshold final benchmark öncesinde calibrated edilecek ve benchmark outcome görüldükten sonra tune edilmeyecektir.)*

---

# 116. Measurement Correlation Risk (Measurement Correlation Riski)

PDR and ARCore pseudo-position inputs may contain correlated information. *(PDR ve ARCore pseudo-position input'ları correlated information içerebilir.)*

---

# 117. Correlation Handling (Correlation Yönetimi)

NAVGUARD will avoid claiming full statistical independence where it is not justified. *(NAVGUARD justified olmadığı durumda full statistical independence iddia etmeyecektir.)*

Conservative covariance or limited fusion influence may be used until correlation behavior is better characterized. *(Correlation behavior daha iyi characterize edilene kadar conservative covariance veya limited fusion influence kullanılabilir.)*

---

# 118. GNSS Risk Category (GNSS Risk Kategorisi)

GNSS can fail through poor quality, staleness, multipath, provider confusion, permission loss, or delayed callbacks. *(GNSS poor quality, staleness, multipath, provider confusion, permission loss veya delayed callback nedeniyle fail olabilir.)*

---

# 119. Poor Anchor Risk (Kötü Anchor Riski)

A bad initial anchor shifts the entire local coordinate frame. *(Bad initial anchor tüm local coordinate frame'i kaydırır.)*

---

# 120. Anchor Fallback (Anchor Fallback'i)

NAVGUARD will wait for a valid anchor rather than start a formal denied session from an unacceptable fix. *(NAVGUARD unacceptable fix'ten formal denied session başlatmak yerine valid anchor bekleyecektir.)*

---

# 121. First-Fix Risk (İlk Fix Riski)

The first callback after requesting GNSS may be stale or inaccurate. *(GNSS request sonrasındaki ilk callback stale veya inaccurate olabilir.)*

---

# 122. First-Fix Fallback (İlk Fix Fallback'i)

The first fix will not receive automatic anchor or recovery authority. *(İlk fix automatic anchor veya recovery authority almayacaktır.)*

---

# 123. GNSS Provider Confusion Risk (GNSS Provider Karışıklığı Riski)

Using a fused location source could introduce non-GNSS information into formal ground truth. *(Fused location source kullanmak formal ground truth içerisine non-GNSS information sokabilir.)*

---

# 124. GNSS Provider Mitigation (GNSS Provider Mitigation)

Formal ground truth will use the configured authoritative GNSS provider rather than an undeclared fused provider. *(Formal ground truth undeclared fused provider yerine configured authoritative GNSS provider kullanacaktır.)*

---

# 125. GNSS Ground Truth Quality Risk (GNSS Ground Truth Kalite Riski)

Ordinary smartphone GNSS is not perfect ground truth. *(Normal smartphone GNSS perfect ground truth değildir.)*

---

# 126. Ground Truth Quality Mitigation (Ground Truth Kalite Mitigation)

Reference quality will be evaluated independently and poor segments may be excluded according to frozen predeclared rules. *(Reference quality bağımsız olarak değerlendirilecek ve poor segment'ler frozen predeclared rule'lara göre excluded edilebilir.)*

---

# 127. No Ground Truth Repair by Guessing (Tahminle Ground Truth Onarımı Olmaması)

Large GNSS reference gaps will not be filled with arbitrary synthetic trajectories and treated as measured truth. *(Büyük GNSS reference gap'leri arbitrary synthetic trajectory ile doldurulup measured truth olarak ele alınmayacaktır.)*

---

# 128. Ground Truth Firewall Risk (Ground Truth Firewall Riski)

Ground Truth Firewall failure is one of the highest-severity NAVGUARD risks. *(Ground Truth Firewall failure en yüksek severity NAVGUARD risklerinden biridir.)*

---

# 129. Ground Truth Leakage Paths (Ground Truth Sızıntı Yolları)

Potential leakage paths include EKF updates, AI features, anchor updates, heading correction, step-length features, UI feedback, and hidden shared-state references. *(Potential leakage path'leri EKF update, AI feature, anchor update, heading correction, step-length feature, UI feedback ve hidden shared-state reference'ları içerir.)*

---

# 130. Ground Truth Firewall Mitigation (Ground Truth Firewall Mitigation)

Authorization checks will occur before estimator quality processing. *(Authorization check'leri estimator quality processing öncesinde gerçekleşecektir.)*

---

# 131. Ground Truth Firewall Runtime Counter (Ground Truth Firewall Runtime Counter'ı)

```text
unauthorizedGnssEstimatorUpdateCount
```

---

# 132. Ground Truth Firewall Required Value (Ground Truth Firewall Gerekli Değeri)

The required formal denied-session value is exactly zero. *(Gerekli formal denied-session değeri tam olarak sıfırdır.)*

---

# 133. Ground Truth Firewall Violation Fallback (Ground Truth Firewall İhlal Fallback'i)

A detected unauthorized GNSS estimator influence will invalidate the affected formal denied interval immediately. *(Detected unauthorized GNSS estimator influence etkilenen formal denied interval'ı anında invalid hale getirecektir.)*

---

# 134. No Salvaging a Leaked Benchmark (Sızmış Benchmark'ı Kurtarmama)

The session cannot remain a valid primary benchmark merely because the numerical result looks good. *(Session numerical result iyi görünüyor diye valid primary benchmark olarak kalamaz.)*

---

# 135. Ground Truth Leakage Diagnostic Preservation (Ground Truth Sızıntı Diagnostic Koruması)

The invalid session will be preserved for debugging and evidence rather than deleted. *(Invalid session debugging ve evidence için deleted edilmek yerine preserved olacaktır.)*

---

# 136. Recovery Risk Category (Recovery Risk Kategorisi)

GNSS recovery can corrupt experimental results if applied too early or before pre-correction error is captured. *(GNSS recovery çok erken uygulanırsa veya pre-correction error yakalanmadan yapılırsa experimental result'ı bozabilir.)*

---

# 137. Recovery Ordering Risk (Recovery Sıralama Riski)

Correction before evidence capture destroys the true denied-end error. *(Evidence capture öncesi correction gerçek denied-end error'ı yok eder.)*

---

# 138. Recovery Ordering Mitigation (Recovery Sıralama Mitigation)

The state machine will enforce pre-correction snapshot and error capture before relocalization. *(State machine relocalization öncesinde pre-correction snapshot ve error capture'ı enforce edecektir.)*

---

# 139. Recovery Candidate Quality Risk (Recovery Aday Kalite Riski)

The first available GNSS candidate after outage may still be poor. *(Outage sonrasındaki ilk available GNSS candidate yine poor olabilir.)*

---

# 140. Recovery Candidate Fallback (Recovery Aday Fallback'i)

Invalid recovery candidates will be rejected while recovery remains pending. *(Invalid recovery candidate'ları recovery pending kalırken rejected olacaktır.)*

---

# 141. Recovery Timeout Risk (Recovery Timeout Riski)

Acceptable GNSS may not become available within the expected period. *(Acceptable GNSS expected period içerisinde available hale gelmeyebilir.)*

---

# 142. Recovery Timeout Fallback (Recovery Timeout Fallback'i)

Timeout will not force acceptance of a bad fix. *(Timeout bad fix'in forced acceptance'ına neden olmayacaktır.)*

The system may remain denied, declare recovery failure, or end the formal session according to the frozen protocol. *(Sistem frozen protocol'e göre denied kalabilir, recovery failure ilan edebilir veya formal session'ı bitirebilir.)*

---

# 143. Recovery Jump Risk (Recovery Sıçrama Riski)

Relocalization can create a large map jump. *(Relocalization büyük map jump oluşturabilir.)*

---

# 144. Recovery Jump Handling (Recovery Sıçrama Yönetimi)

The correction will be explicitly labeled as relocalization rather than pedestrian movement. *(Correction pedestrian movement yerine relocalization olarak explicit label alacaktır.)*

---

# 145. Historical Trajectory Corruption Risk (Geçmiş Trajectory Bozulma Riski)

Applying recovery correction retroactively could make denied trajectory appear more accurate than it was. *(Recovery correction'ı retroactive uygulamak denied trajectory'yi olduğundan daha accurate gösterebilir.)*

---

# 146. Historical Integrity Fallback (Geçmiş Bütünlük Fallback'i)

Historical denied trajectory points will remain immutable after recovery. *(Historical denied trajectory point'leri recovery sonrasında immutable kalacaktır.)*

---

# 147. Storage Risk Category (Storage Risk Kategorisi)

Storage failure can destroy research evidence even when navigation itself remains functional. *(Storage failure navigation functional kalsa bile research evidence'ı yok edebilir.)*

---

# 148. Low Storage Risk (Düşük Depolama Alanı Riski)

Insufficient free storage may prevent completion of a formal session. *(Insufficient free storage formal session completion'ı önleyebilir.)*

---

# 149. Storage Readiness Fallback (Storage Hazırlık Fallback'i)

Formal sessions will be blocked when predicted free space is insufficient according to the frozen storage policy. *(Predicted free space frozen storage policy'ye göre insufficient ise formal session'lar blocked olacaktır.)*

---

# 150. Writer Failure Risk (Writer Hata Riski)

File or database writer failure can create incomplete evidence. *(File veya database writer failure incomplete evidence oluşturabilir.)*

---

# 151. Writer Failure Fallback (Writer Hata Fallback'i)

Critical writer failure will mark the session degraded or invalid according to affected evidence. *(Critical writer failure affected evidence'a göre session'ı degraded veya invalid işaretleyecektir.)*

---

# 152. Logging Backpressure Risk (Logging Backpressure Riski)

Slow storage may cause writer queues to grow. *(Slow storage writer queue'ların büyümesine neden olabilir.)*

---

# 153. Logging Backpressure Fallback (Logging Backpressure Fallback'i)

Queues will remain bounded and overflow will be observable. *(Queue'lar bounded kalacak ve overflow observable olacaktır.)*

---

# 154. Mandatory Evidence Drop Risk (Zorunlu Kanıt Drop Riski)

Dropped mandatory evidence may make a formal benchmark scientifically incomplete. *(Dropped mandatory evidence formal benchmark'ı scientifically incomplete hale getirebilir.)*

---

# 155. Mandatory Evidence Drop Policy (Zorunlu Kanıt Drop Politikası)

Mandatory-stream drops will be recorded explicitly and may invalidate the affected formal session. *(Mandatory-stream drop'ları explicitly recorded edilecek ve affected formal session'ı invalid hale getirebilir.)*

---

# 156. App Crash Risk (Uygulama Crash Riski)

A process crash may interrupt recording before finalization. *(Process crash recording'i finalization öncesinde interrupt edebilir.)*

---

# 157. Crash Fallback (Crash Fallback'i)

On next launch, interrupted sessions will be detected as `INCOMPLETE` rather than falsely marked completed. *(Sonraki launch'ta interrupted session'lar falsely completed işaretlenmek yerine `INCOMPLETE` olarak detected olacaktır.)*

---

# 158. Partial Evidence Preservation (Kısmi Kanıt Koruması)

Valid evidence written before the crash will be preserved where possible. *(Crash öncesinde written valid evidence mümkün olduğunda preserved olacaktır.)*

---

# 159. Finalization Failure Risk (Finalization Hata Riski)

A crash during finalization may leave partially closed artifacts or missing hashes. *(Finalization sırasında crash partially closed artifact veya missing hash bırakabilir.)*

---

# 160. Finalization Fallback (Finalization Fallback'i)

The session will remain incomplete until integrity checks can verify its final state. *(Session integrity check'ler final state'ini verify edene kadar incomplete kalacaktır.)*

---

# 161. Permission Risk Category (Permission Risk Kategorisi)

The user may deny or revoke permissions before or during a session. *(Kullanıcı session öncesinde veya sırasında permission'ları deny veya revoke edebilir.)*

---

# 162. Precise Location Loss (Kesin Konum Kaybı)

Loss of precise location prevents formal anchor, ground-truth, and recovery workflows. *(Precise location kaybı formal anchor, ground-truth ve recovery workflow'larını önler.)*

---

# 163. Precise Location Fallback (Kesin Konum Fallback'i)

A formal benchmark requiring GNSS will be blocked or marked invalid when required precise location becomes unavailable. *(GNSS gerektiren formal benchmark required precise location unavailable hale geldiğinde blocked veya invalid işaretlenecektir.)*

---

# 164. Camera Permission Loss (Kamera İzni Kaybı)

Camera permission loss disables ARCore. *(Camera permission loss ARCore'u disable eder.)*

---

# 165. Camera Permission Fallback (Kamera İzni Fallback'i)

PDR-capable navigation may continue while ARCore is declared unavailable. *(ARCore unavailable ilan edilirken PDR-capable navigation devam edebilir.)*

---

# 166. Activity Recognition Permission Loss (Activity Recognition İzni Kaybı)

Loss of optional Activity Recognition permission will only disable Android built-in step-sensor comparison. *(Optional Activity Recognition permission kaybı yalnızca Android built-in step-sensor comparison'ı disable edecektir.)*

---

# 167. No Core Dependency on Activity Recognition (Activity Recognition Üzerinde Core Bağımlılık Olmaması)

The independent NAVGUARD step detector will continue without this permission. *(Independent NAVGUARD step detector bu permission olmadan devam edecektir.)*

---

# 168. Performance Risk Category (Performans Risk Kategorisi)

Runtime contention may prevent components from meeting timing requirements even when all algorithms are logically correct. *(Runtime contention tüm algorithm'lar logically correct olsa bile component'lerin timing requirement'larını karşılamasını önleyebilir.)*

---

# 169. CPU Saturation Risk (CPU Saturation Riski)

High CPU use may delay AI, UI, logging, or sensor processing. *(High CPU use AI, UI, logging veya sensor processing'i geciktirebilir.)*

---

# 170. CPU Pressure Fallback Priority (CPU Baskısı Fallback Önceliği)

Non-critical diagnostics and visual refresh will be reduced before navigation-critical acquisition or integrity logging. *(Navigation-critical acquisition veya integrity logging azaltılmadan önce non-critical diagnostics ve visual refresh azaltılacaktır.)*

---

# 171. UI Rendering Fallback (UI Render Fallback'i)

Map and diagnostic update frequency may be throttled independently from estimator processing. *(Map ve diagnostic update frequency estimator processing'den bağımsız throttle edilebilir.)*

---

# 172. Logging Cannot Be Silently Disabled (Logging Sessizce Devre Dışı Bırakılamaz)

Mandatory evidence logging will not be silently disabled to improve frame rate. *(Mandatory evidence logging frame rate iyileştirmek için sessizce disable edilmeyecektir.)*

---

# 173. AI Performance Fallback (AI Performans Fallback'i)

If AI becomes too slow, deterministic navigation remains available. *(AI çok yavaş hale gelirse deterministic navigation available kalır.)*

---

# 174. ARCore Performance Fallback (ARCore Performans Fallback'i)

If ARCore creates unacceptable sustained resource pressure, the system may degrade to PDR according to the selected runtime profile. *(ARCore unacceptable sustained resource pressure oluşturursa sistem selected runtime profile'a göre PDR'a degrade olabilir.)*

---

# 175. Memory Risk (Memory Riski)

Unbounded buffers or leaked listeners may eventually crash the application. *(Unbounded buffer veya leaked listener sonunda application crash'ine neden olabilir.)*

---

# 176. Memory Fallback and Mitigation (Memory Fallback ve Mitigation)

All continuous buffers, trajectories, queues, and diagnostics must be bounded. *(Tüm continuous buffer, trajectory, queue ve diagnostic'ler bounded olmalıdır.)*

---

# 177. Memory Pressure Degradation (Memory Baskısı Degradation)

Diagnostic history may be shortened before navigation-critical state history required for evidence is sacrificed. *(Evidence için required navigation-critical state history sacrifice edilmeden önce diagnostic history kısaltılabilir.)*

---

# 178. Battery Risk Category (Batarya Risk Kategorisi)

Combined sensors, GNSS logging, camera, ARCore, AI, screen, and storage writes may consume significant battery. *(Combined sensor, GNSS logging, camera, ARCore, AI, screen ve storage write'lar significant battery tüketebilir.)*

---

# 179. Low Battery Pre-Run Risk (Run Öncesi Düşük Batarya Riski)

Starting a long formal session with insufficient battery can cause incomplete evidence. *(Insufficient battery ile long formal session başlatmak incomplete evidence oluşturabilir.)*

---

# 180. Low Battery Readiness Fallback (Düşük Batarya Hazırlık Fallback'i)

A battery readiness warning or block may be used once measured session requirements are known. *(Measured session requirement'ları bilindiğinde battery readiness warning veya block kullanılabilir.)*

---

# 181. Battery Drain During Session (Session Sırasında Batarya Tüketimi)

Unexpectedly fast battery drain will be logged as a performance anomaly. *(Unexpectedly fast battery drain performance anomaly olarak logged edilecektir.)*

---

# 182. Battery Fallback Priority (Batarya Fallback Önceliği)

Optional expensive subsystems may be reduced before mandatory estimator integrity is compromised. *(Mandatory estimator integrity compromise edilmeden önce optional expensive subsystem'ler reduced edilebilir.)*

---

# 183. Thermal Risk Category (Termal Risk Kategorisi)

Sustained ARCore, camera, AI, display, and CPU use may cause thermal throttling. *(Sustained ARCore, camera, AI, display ve CPU use thermal throttling'e neden olabilir.)*

---

# 184. Thermal Detection (Termal Tespit)

Available thermal-state signals and observed latency degradation will be monitored during endurance tests. *(Available thermal-state signal'ları ve observed latency degradation endurance testleri sırasında monitored olacaktır.)*

---

# 185. Thermal Degradation Fallback (Termal Degradation Fallback'i)

The first degradation targets will be non-essential rendering and diagnostics. *(İlk degradation target'ları non-essential rendering ve diagnostic'ler olacaktır.)*

---

# 186. Thermal ARCore Fallback (Termal ARCore Fallback'i)

If ARCore is the dominant sustained thermal burden and the runtime profile permits fallback, ARCore may be disabled while PDR continues. *(ARCore dominant sustained thermal burden ise ve runtime profile fallback'e izin veriyorsa PDR devam ederken ARCore disable edilebilir.)*

---

# 187. Thermal AI Fallback (Termal AI Fallback'i)

If inference latency becomes operationally stale under thermal throttling, AI context may be disabled and deterministic policy used. *(Inference latency thermal throttling altında operationally stale hale gelirse AI context disable edilip deterministic policy kullanılabilir.)*

---

# 188. Thermal Safety Stop (Termal Güvenlik Durdurma)

If the device becomes operationally unstable or unsafe to continue using, the session will be terminated rather than forcing completion. *(Cihaz operationally unstable veya kullanmaya devam etmek unsafe hale gelirse completion zorlamak yerine session terminate edilecektir.)*

---

# 189. UI Risk Category (UI Risk Kategorisi)

Incorrect UI state can mislead the operator even when the estimator is correct. *(Incorrect UI state estimator correct olsa bile operator'ı mislead edebilir.)*

---

# 190. Stale Marker Risk (Stale Marker Riski)

A stale last-known position could continue appearing as if it were current. *(Stale last-known position current'mış gibi görünmeye devam edebilir.)*

---

# 191. Stale Marker Fallback (Stale Marker Fallback'i)

The marker will visually communicate invalid or stale state rather than continuing as a normal trusted position. *(Marker normal trusted position olarak devam etmek yerine invalid veya stale state'i visually communicate edecektir.)*

---

# 192. Mode Display Risk (Mode Display Riski)

The UI may display the wrong navigation mode if state subscriptions become inconsistent. *(State subscription'lar inconsistent hale gelirse UI yanlış navigation mode gösterebilir.)*

---

# 193. Mode Authority (Mode Authority)

The UI will derive mode from the authoritative state machine rather than maintain a separate independent mode truth. *(UI separate independent mode truth tutmak yerine authoritative state machine'den mode derive edecektir.)*

---

# 194. Ground Truth UI Leakage Risk (Ground Truth UI Sızıntı Riski)

Displaying protected GNSS during blinded Evaluation Mode may influence operator behavior. *(Blinded Evaluation Mode sırasında protected GNSS göstermek operator behavior'ı etkileyebilir.)*

---

# 195. Ground Truth UI Fallback (Ground Truth UI Fallback'i)

Protected ground truth will remain hidden until the blinded interval ends. *(Protected ground truth blinded interval bitene kadar hidden kalacaktır.)*

---

# 196. Model and Artifact Risk (Model ve Artifact Riski)

Wrong, corrupted, or incompatible model files can silently change behavior. *(Wrong, corrupted veya incompatible model file'ları behavior'ı sessizce değiştirebilir.)*

---

# 197. Model Identity Mitigation (Model Kimlik Mitigation)

Navigation-enabled models will carry version, schema, preprocessing version, and cryptographic hash metadata. *(Navigation-enabled model'ler version, schema, preprocessing version ve cryptographic hash metadata taşıyacaktır.)*

---

# 198. Model Compatibility Failure (Model Compatibility Failure)

Input-shape, channel-order, class-order, or preprocessing mismatch will block model activation. *(Input-shape, channel-order, class-order veya preprocessing mismatch model activation'ı block edecektir.)*

---

# 199. Arbitrary Model Loading Risk (Keyfi Model Yükleme Riski)

User-selected arbitrary model artifacts will not be allowed to become Benchmark navigation models. *(User-selected arbitrary model artifact'ların Benchmark navigation model olmasına izin verilmeyecektir.)*

---

# 200. Corrupted Evidence Artifact Risk (Bozulmuş Evidence Artifact Riski)

A finalized session file may be modified accidentally after collection. *(Finalize edilmiş session file collection sonrasında accidentally modified olabilir.)*

---

# 201. Artifact Integrity Mitigation (Artifact Bütünlük Mitigation)

Finalized evidence may use hashes to make later modification observable. *(Finalize edilmiş evidence later modification'ı observable yapmak için hash kullanabilir.)*

---

# 202. Hash Limitation (Hash Sınırlaması)

Hashing detects change but does not provide confidentiality. *(Hashing change'i detect eder ancak confidentiality sağlamaz.)*

---

# 203. Field Experiment Risk Category (Saha Deneyi Risk Kategorisi)

Field experiments introduce route, environment, operator, GNSS-reference, and safety variability. *(Field experiment'ler route, environment, operator, GNSS-reference ve safety variability getirir.)*

---

# 204. Route Deviation Risk (Rota Sapma Riski)

The operator may deviate from the planned route because of obstacles, crowds, or traffic. *(Operator obstacle, crowd veya traffic nedeniyle planned route'tan deviate olabilir.)*

---

# 205. Route Deviation Fallback (Rota Sapma Fallback'i)

The session will be marked for review rather than silently treated as perfectly matched. *(Session silently perfectly matched olarak ele alınmak yerine review için marked olacaktır.)*

---

# 206. Field Safety Risk (Saha Güvenlik Riski)

A route condition may become unsafe during an experiment. *(Route condition experiment sırasında unsafe hale gelebilir.)*

---

# 207. Field Safety Fallback (Saha Güvenlik Fallback'i)

The operator will abort the route immediately when safety requires it. *(Safety gerektiriyorsa operator route'u immediate abort edecektir.)*

---

# 208. Safety Overrides Benchmark Completion (Güvenlik Benchmark Tamamlamanın Üzerindedir)

No benchmark completion requirement overrides pedestrian safety. *(Hiçbir benchmark completion requirement pedestrian safety'nin üzerine çıkmaz.)*

---

# 209. Poor Weather Risk (Kötü Hava Riski)

Weather may affect walking consistency, device handling, visibility, battery, and thermal behavior. *(Weather walking consistency, device handling, visibility, battery ve thermal behavior'ı etkileyebilir.)*

---

# 210. Weather Fallback (Hava Durumu Fallback'i)

A formal run may be postponed, aborted, or marked contextual if weather materially changes the protocol. *(Weather protocol'ü materially değiştirirse formal run postponed, aborted veya contextual marked olabilir.)*

---

# 211. Ground Truth Reference Failure in Field (Sahada Ground Truth Referans Hatası)

Outdoor GNSS reference may become unexpectedly poor. *(Outdoor GNSS reference unexpectedly poor hale gelebilir.)*

---

# 212. Reference Failure Fallback (Referans Hata Fallback'i)

The session may remain useful for subsystem metrics while being excluded from primary continuous position-error metrics. *(Session primary continuous position-error metric'lerinden excluded edilirken subsystem metric'leri için useful kalabilir.)*

---

# 213. Indoor Ground Truth Risk (Indoor Ground Truth Riski)

Indoor GNSS is particularly vulnerable to poor reference quality. *(Indoor GNSS poor reference quality'ye özellikle vulnerable'dır.)*

---

# 214. Indoor Fallback Reference (Indoor Fallback Referansı)

Indoor analysis will prefer known geometry, checkpoint, measured distance, or closure-error methods when GNSS reference is not defensible. *(GNSS reference defensible değilse indoor analysis known geometry, checkpoint, measured distance veya closure-error method'larını tercih edecektir.)*

---

# 215. Project Schedule Risk Category (Proje Takvim Riski Kategorisi)

NAVGUARD has a limited 24-business-day development window. *(NAVGUARD sınırlı 24-business-day development window'a sahiptir.)*

---

# 216. Scope Expansion Risk (Kapsam Genişleme Riski)

Adding too many optional features can prevent completion of the core research system. *(Çok fazla optional feature eklemek core research system'ın completion'ını önleyebilir.)*

---

# 217. Scope Fallback Principle (Kapsam Fallback İlkesi)

Optional complexity will be removed before core research requirements are sacrificed. *(Core research requirement'ları sacrifice edilmeden önce optional complexity removed olacaktır.)*

---

# 218. Minimum Viable Research Stack (Minimum Uygulanabilir Araştırma Stack'i)

The minimum deliverable research stack is defined below. *(Minimum deliverable research stack aşağıda tanımlanmıştır.)*

```text
Sensor acquisition
Timing
GNSS anchor
Ground Truth Firewall
Step detection
Heading
Deterministic step length
PDR
Logging
Replay
Evaluation metrics
Controlled field benchmark
```

---

# 219. First Optional Layer (İlk İsteğe Bağlı Katman)

ARCore is a target enhancement but PDR remains mandatory. *(ARCore target enhancement'tır ancak PDR mandatory kalır.)*

---

# 220. Second Optional Layer (İkinci İsteğe Bağlı Katman)

Learned step length is a target enhancement but deterministic step length remains sufficient for minimum success. *(Learned step length target enhancement'tır ancak deterministic step length minimum success için sufficient kalır.)*

---

# 221. AI Motion Classification Priority (AI Motion Classification Önceliği)

Motion Classification is mandatory as the primary AI component, but the complete project must still remain functional through deterministic fallback if runtime AI fails. *(Motion Classification primary AI component olarak mandatory'dir ancak runtime AI fail olursa tam proje deterministic fallback üzerinden functional kalmalıdır.)*

---

# 222. Optional Quantization Risk (İsteğe Bağlı Quantization Riski)

Quantization may consume development time while reducing accuracy or adding deployment complexity. *(Quantization development time tüketirken accuracy azaltabilir veya deployment complexity ekleyebilir.)*

---

# 223. Quantization Schedule Fallback (Quantization Takvim Fallback'i)

Quantization will be dropped from the minimum plan if the float model already meets practical latency requirements. *(Float model practical latency requirement'larını zaten karşılıyorsa quantization minimum plan'dan dropped edilecektir.)*

---

# 224. Delegate Optimization Risk (Delegate Optimizasyon Riski)

Hardware delegates may create device-specific compatibility issues. *(Hardware delegate'ler device-specific compatibility issue oluşturabilir.)*

---

# 225. Delegate Fallback (Delegate Fallback'i)

CPU inference remains the default baseline unless a delegate demonstrates measured reliable benefit. *(Delegate measured reliable benefit göstermedikçe CPU inference default baseline olarak kalacaktır.)*

---

# 226. Large Neural Model Risk (Büyük Neural Model Riski)

A larger model may improve offline metrics but fail mobile latency or memory requirements. *(Larger model offline metric'leri improve ederken mobile latency veya memory requirement'larını fail edebilir.)*

---

# 227. Model Complexity Fallback (Model Komplekslik Fallback'i)

The project will prefer the smallest model that satisfies the required accuracy and navigation-effect criteria. *(Proje required accuracy ve navigation-effect criterion'larını karşılayan en küçük modeli tercih edecektir.)*

---

# 228. Dataset Risk Category (Dataset Risk Kategorisi)

Insufficient, imbalanced, or poorly labelled data can invalidate ML conclusions. *(Insufficient, imbalanced veya poorly labelled data ML conclusion'larını invalid hale getirebilir.)*

---

# 229. Dataset Leakage Risk (Dataset Leakage Riski)

Random overlapping-window splits can leak nearly identical motion samples between train and test. *(Random overlapping-window split'ler nearly identical motion sample'ları train ve test arasında leak edebilir.)*

---

# 230. Dataset Leakage Mitigation (Dataset Leakage Mitigation)

Session-wise split is mandatory. *(Session-wise split mandatory'dir.)*

---

# 231. Motion Label Ambiguity Risk (Motion Label Belirsizliği Riski)

`TURNING` can overlap physically with walking. *(`TURNING` fiziksel olarak walking ile overlap edebilir.)*

---

# 232. Motion Label Mitigation (Motion Label Mitigation)

The annotation protocol will define `TURNING` as the dominant operational rotational context rather than as an absence of walking. *(Annotation protocol `TURNING`'i walking absence yerine dominant operational rotational context olarak tanımlayacaktır.)*

---

# 233. Running Data Scarcity Risk (Running Veri Azlığı Riski)

The project may collect insufficient running data for reliable navigation-specific behavior. *(Proje reliable navigation-specific behavior için insufficient running data toplayabilir.)*

---

# 234. Running Fallback (Running Fallback'i)

If running evidence is inadequate, running-specific navigation adaptation may remain disabled even if the classifier retains the class for research evaluation. *(Running evidence inadequate ise classifier research evaluation için class'ı korusa bile running-specific navigation adaptation disabled kalabilir.)*

---

# 235. Step-Length Label Risk (Adım Uzunluğu Label Riski)

Route-average distance divided by step count is not exact per-step ground truth. *(Route-average distance'ın step count'a bölünmesi exact per-step ground truth değildir.)*

---

# 236. Step-Length Label Mitigation (Adım Uzunluğu Label Mitigation)

Step-length evaluation will use the finest reference granularity that can be defended scientifically. *(Step-length evaluation scientifically defensible olan en ince reference granularity'yi kullanacaktır.)*

---

# 237. Research Validity Risk (Araştırma Geçerlilik Riski)

A project can produce technically correct software but still make invalid scientific claims. *(Proje technically correct software üretirken yine de invalid scientific claim yapabilir.)*

---

# 238. Cherry-Picking Risk (Cherry-Picking Riski)

Selecting only good sessions would bias the final result. *(Yalnızca good session seçmek final result'ı bias eder.)*

---

# 239. Cherry-Picking Mitigation (Cherry-Picking Mitigation)

Scientifically valid poor-performing sessions will remain in the benchmark. *(Scientifically valid poor-performing session'lar benchmark içerisinde kalacaktır.)*

---

# 240. Post-Hoc Tuning Risk (Post-Hoc Tuning Riski)

Tuning after viewing final benchmark outcomes can invalidate the claimed holdout evaluation. *(Final benchmark outcome görüldükten sonra tuning claimed holdout evaluation'ı invalid hale getirebilir.)*

---

# 241. Post-Hoc Tuning Mitigation (Post-Hoc Tuning Mitigation)

Parameters, models, thresholds, inclusion rules, and metric pipeline will be frozen before final benchmark interpretation. *(Parameter, model, threshold, inclusion rule ve metric pipeline final benchmark interpretation öncesinde frozen olacaktır.)*

---

# 242. Target Relaxation Risk (Hedef Gevşetme Riski)

Changing success criteria after observing weak results would undermine the research design. *(Weak result gözlemledikten sonra success criterion değiştirmek research design'ı zayıflatır.)*

---

# 243. Target Freeze Mitigation (Hedef Freeze Mitigation)

The predeclared `≥20%` primary research target remains frozen. It must not be changed merely through documented justification, device-audit findings, pilot performance, or development results. Any unavoidable change before final benchmark collection requires an explicit, versioned, superseding Technical Decision under the project's benchmark-governance process. *(Predeclared `≥%20` primary research target frozen olarak kalır. Yalnızca documented justification, device-audit bulguları, pilot performansı veya development sonuçları nedeniyle değiştirilemez. Final benchmark collection öncesinde kaçınılmaz bir değişiklik gerekirse projenin benchmark-governance süreci altında explicit, versioned ve superseding Technical Decision gerekir.)*

---

# 244. Statistical Overclaiming Risk (İstatistiksel Aşırı İddia Riski)

A small field sample may not justify strong statistical-generalization claims. *(Small field sample strong statistical-generalization claim'lerini justify etmeyebilir.)*

---

# 245. Statistical Mitigation (İstatistiksel Mitigation)

Engineering effect sizes and transparent matched-session results will be prioritized over unsupported significance claims. *(Engineering effect size ve transparent matched-session result'lar unsupported significance claim'lerine göre prioritized olacaktır.)*

---

# 246. Cross-Device Generalization Risk (Cihazlar Arası Genelleme Riski)

Results from the Redmi Note 9 Pro may not generalize directly to all Android phones. *(Redmi Note 9 Pro result'ları tüm Android telefonlara doğrudan generalize olmayabilir.)*

---

# 247. Cross-Device Claim Mitigation (Cihazlar Arası Claim Mitigation)

Final conclusions will be explicitly scoped to the tested device unless additional devices are evaluated. *(Additional device evaluate edilmezse final conclusion'lar explicitly tested device ile scoped olacaktır.)*

---

# 248. Risk-to-Fallback Matrix (Riskten Fallback'e Matrix)

The principal runtime fallback relationships are summarized below. *(Temel runtime fallback ilişkileri aşağıda özetlenmiştir.)*

| Risk (Risk)                                                | Primary Response (Temel Tepki)                                                   | Fallback (Fallback)                                                                       |
| ---------------------------------------------------------- | -------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| ARCore loss *(ARCore kaybı)*                               | Reject ARCore updates *(ARCore update'lerini reddet)*                            | PDR continues *(PDR devam eder)*                                                          |
| AI failure *(AI hatası)*                                   | Mark AI unavailable *(AI'ı unavailable işaretle)*                                | Deterministic policy *(Deterministic policy)*                                             |
| Learned step-length failure *(Learned step-length hatası)* | Reject prediction *(Prediction'ı reddet)*                                        | Variable deterministic → fixed calibrated *(Variable deterministic → fixed calibrated)*   |
| Magnetic disturbance *(Manyetik bozulma)*                  | Reject/down-weight magnetic heading *(Magnetic heading'i reject/down-weight et)* | Gyro propagation / other validated heading *(Gyro propagation / diğer validated heading)* |
| Gyroscope loss *(Jiroskop kaybı)*                          | Degrade heading *(Heading'i degrade et)*                                         | Absolute heading if usable *(Usable ise absolute heading)*                                |
| Heading unavailable *(Heading unavailable)*                | Stop directional PDR propagation *(Directional PDR propagation'ı durdur)*        | `UNAVAILABLE` if no alternative *(Alternatif yoksa `UNAVAILABLE`)*                        |
| GNSS poor before anchor *(Anchor öncesi kötü GNSS)*        | Reject anchor *(Anchor'ı reddet)*                                                | Wait for valid GNSS *(Valid GNSS bekle)*                                                  |
| Recovery fix poor *(Kötü recovery fix)*                    | Reject recovery candidate *(Recovery candidate'ı reddet)*                        | Remain pending/denied *(Pending/denied kal)*                                              |
| EKF invalid *(EKF invalid)*                                | Reject fused output *(Fused output'u reddet)*                                    | Independent PDR *(Independent PDR)*                                                       |
| Storage failure *(Storage hatası)*                         | Mark evidence failure *(Evidence failure işaretle)*                              | Abort/invalid formal session *(Formal session abort/invalid)*                             |
| Camera permission loss *(Camera izni kaybı)*               | Stop ARCore *(ARCore'u durdur)*                                                  | PDR *(PDR)*                                                                               |
| Thermal pressure *(Termal baskı)*                          | Reduce optional load *(Optional load'u azalt)*                                   | PDR-first reduced profile *(PDR-first reduced profile)*                                   |
| Ground Truth leakage *(Ground Truth sızıntısı)*            | Invalidate interval *(Interval'ı invalid et)*                                    | Preserve for debugging only *(Yalnızca debugging için koru)*                              |

---

# 249. Runtime Fallback Hierarchy (Runtime Fallback Hiyerarşisi)

The broad runtime hierarchy is defined below. *(Genel runtime hierarchy aşağıda tanımlanmıştır.)*

```text
FULL NAVGUARD
AI + ARCORE + HEADING + PDR + EKF
            ↓
PDR + ARCORE / IMPROVED HEADING
            ↓
PDR + USABLE HEADING
            ↓
PDR WITH DETERMINISTIC STEP LENGTH
            ↓
NO SAFE DIRECTIONAL PROPAGATION
            ↓
UNRELIABLE / UNAVAILABLE
```

---

# 250. No Fall-Through to Unsafe State (Unsafe State'e Fall-Through Olmaması)

Fallback will stop at `UNRELIABLE` or `UNAVAILABLE` instead of continuing to invent position after all trustworthy directional sources are gone. *(Fallback tüm trustworthy directional source'lar kaybolduktan sonra position uydurmaya devam etmek yerine `UNRELIABLE` veya `UNAVAILABLE` durumunda duracaktır.)*

---

# 251. Fallback Event Logging (Fallback Event Logging)

Every meaningful runtime fallback will generate a structured event. *(Her meaningful runtime fallback structured event üretecektir.)*

---

# 252. Candidate Fallback Event (Aday Fallback Event'i)

```text
FallbackEvent
- timestamp
- source
- previousMode
- newMode
- reason
- qualityBefore
- qualityAfter
- recoverable
- sessionId
```

---

# 253. Fallback Reason Codes (Fallback Reason Code'ları)

Candidate reason codes are defined below. *(Aday reason code'lar aşağıda tanımlanmıştır.)*

```text
SENSOR_UNAVAILABLE
SENSOR_STALE
MAGNETIC_DISTURBANCE
ARCORE_PAUSED
ARCORE_STOPPED
ARCORE_ALIGNMENT_INVALID
AI_LOAD_FAILED
AI_INFERENCE_FAILED
AI_STALE
AI_LOW_CONFIDENCE
STEP_LENGTH_INVALID
EKF_INVALID
GNSS_POOR
RECOVERY_TIMEOUT
PERMISSION_REVOKED
STORAGE_FAILURE
LOG_QUEUE_OVERFLOW
THERMAL_PRESSURE
GROUND_TRUTH_VIOLATION
```

---

# 254. Fallback Recovery (Fallback'ten Recovery)

A subsystem may return from degraded mode only after defined recovery criteria are satisfied. *(Subsystem yalnızca defined recovery criterion'lar satisfied olduktan sonra degraded mode'dan geri dönebilir.)*

---

# 255. No Immediate Oscillation (Anlık Oscillation Olmaması)

Hysteresis or minimum stable duration may be used to prevent rapid switching between normal and fallback states. *(Normal ve fallback state'ler arasında rapid switching'i önlemek için hysteresis veya minimum stable duration kullanılabilir.)*

---

# 256. Recovery Quality Gate (Recovery Kalite Gate'i)

A recovered sensor source must pass quality validation before regaining navigation influence. *(Recovered sensor source navigation influence'ı yeniden kazanmadan önce quality validation'ı geçmelidir.)*

---

# 257. ARCore Re-Entry Gate (ARCore Yeniden Giriş Gate'i)

ARCore must return to valid `TRACKING` and satisfy segment/alignment rules before fusion resumes. *(Fusion resume etmeden önce ARCore valid `TRACKING` durumuna dönmeli ve segment/alignment rule'larını sağlamalıdır.)*

---

# 258. AI Re-Entry Gate (AI Yeniden Giriş Gate'i)

AI must produce valid fresh outputs from the expected model and preprocessing schema before navigation influence resumes. *(Navigation influence resume etmeden önce AI expected model ve preprocessing schema'dan valid fresh output üretmelidir.)*

---

# 259. Heading Re-Entry Gate (Heading Yeniden Giriş Gate'i)

Heading correction must demonstrate acceptable quality before full trust is restored. *(Full trust restore edilmeden önce heading correction acceptable quality göstermelidir.)*

---

# 260. Risk Testing Strategy (Risk Test Stratejisi)

Major fallbacks will be tested deliberately rather than waiting for accidental real-world failure. *(Major fallback'lar accidental real-world failure beklemek yerine deliberately test edilecektir.)*

---

# 261. Failure Injection Requirement (Failure Injection Gereksinimi)

Development tests will inject or simulate ARCore loss, AI failure, poor GNSS, logging delay, permission revocation, invalid sensor samples, and recovery failure. *(Development testleri ARCore loss, AI failure, poor GNSS, logging delay, permission revocation, invalid sensor sample ve recovery failure inject veya simulate edecektir.)*

---

# 262. Ground Truth Firewall Test Requirement (Ground Truth Firewall Test Gereksinimi)

Ground Truth Firewall failure-injection testing is mandatory before final benchmark collection. *(Ground Truth Firewall failure-injection testing final benchmark collection öncesinde mandatory'dir.)*

---

# 263. Thermal Fallback Test (Termal Fallback Testi)

Thermal-pressure behavior will be validated during endurance testing where practical. *(Thermal-pressure behavior uygulanabilir olduğunda endurance testing sırasında validated olacaktır.)*

---

# 264. Fallback Determinism Test (Fallback Determinizm Testi)

Replay with identical failure events and configuration should produce the same fallback transition sequence. *(Identical failure event ve configuration ile replay aynı fallback transition sequence'i üretmelidir.)*

---

# 265. Fallback Timing Test (Fallback Zamanlama Testi)

Critical fallback latency will be measured where delayed response could allow bad data to affect navigation. *(Delayed response bad data'nın navigation'ı etkilemesine izin verebileceği durumlarda critical fallback latency ölçülecektir.)*

---

# 266. Risk Test IDs (Risk Test ID'leri)

```text
RSK-SEN-001   accelerometer loss
RSK-SEN-002   gyro loss
RSK-SEN-003   magnetometer degradation
RSK-SEN-004   sensor freeze
RSK-SEN-005   sensor gap

RSK-HDG-001   magnetic disturbance
RSK-HDG-002   stale heading
RSK-HDG-003   heading unavailable

RSK-STEP-001  false-step stress
RSK-STEP-002  missed-step stress
RSK-LEN-001   invalid learned step length
RSK-LEN-002   deterministic fallback

RSK-AI-001    model load failure
RSK-AI-002    invalid inference
RSK-AI-003    stale inference
RSK-AI-004    low confidence
RSK-AI-005    inference backlog

RSK-ARC-001   camera permission loss
RSK-ARC-002   ARCore PAUSED
RSK-ARC-003   ARCore STOPPED
RSK-ARC-004   segment recovery
RSK-ARC-005   alignment invalid

RSK-EKF-001   invalid covariance
RSK-EKF-002   innovation rejection
RSK-EKF-003   fused-state fallback

RSK-GN-001    poor anchor fix
RSK-GN-002    stale fix
RSK-GN-003    poor recovery candidate
RSK-GN-004    recovery timeout

RSK-GTF-001   protected GNSS injection
RSK-GTF-002   AI leakage attempt
RSK-GTF-003   EKF leakage attempt
RSK-GTF-004   anchor leakage attempt

RSK-STO-001   low storage
RSK-STO-002   writer failure
RSK-STO-003   queue overflow
RSK-STO-004   crash during recording
RSK-STO-005   crash during finalization

RSK-PER-001   CPU pressure
RSK-PER-002   memory growth
RSK-PER-003   thermal pressure
RSK-PER-004   battery depletion

RSK-FLD-001   route deviation
RSK-FLD-002   unsafe field condition
RSK-FLD-003   bad ground truth

RSK-SCH-001   schedule compression
RSK-SCH-002   optional feature removal
```

---

# 267. Risk Acceptance Criteria (Risk Kabul Kriterleri)

A risk is considered acceptably mitigated only when its detection, response, fallback, and evidence behavior are either tested or explicitly documented as pending physical validation. *(Risk detection, response, fallback ve evidence behavior test edilmedikçe veya explicitly pending physical validation olarak documented edilmedikçe acceptably mitigated sayılmaz.)*

---

# 268. Critical Risk Gate (Critical Risk Gate'i)

No unresolved critical research-integrity risk may remain before final benchmark collection. *(Final benchmark collection öncesinde unresolved critical research-integrity risk kalamaz.)*

---

# 269. Ground Truth Firewall Gate (Ground Truth Firewall Gate'i)

Ground Truth Firewall tests must pass before final benchmark collection. *(Ground Truth Firewall testleri final benchmark collection öncesinde pass etmelidir.)*

---

# 270. Recovery Ordering Gate (Recovery Sıralama Gate'i)

Pre-correction evidence capture must be verified before final benchmark collection. *(Pre-correction evidence capture final benchmark collection öncesinde verified olmalıdır.)*

---

# 271. Storage Integrity Gate (Storage Bütünlük Gate'i)

Formal sessions must demonstrate reliable required evidence logging before final benchmark collection. *(Formal session'lar final benchmark collection öncesinde reliable required evidence logging göstermelidir.)*

---

# 272. Fallback Availability Gate (Fallback Kullanılabilirlik Gate'i)

PDR must continue when optional AI or ARCore components fail, provided core PDR inputs remain valid. *(Core PDR input'ları valid kaldığı sürece optional AI veya ARCore component fail olduğunda PDR devam etmelidir.)*

---

# 273. Invalid Heading Gate (Geçersiz Heading Gate'i)

PDR must not continue directional propagation indefinitely with an invalid heading. *(PDR invalid heading ile directional propagation'a indefinitely devam etmemelidir.)*

---

# 274. AI Failure Gate (AI Hata Gate'i)

AI failure must not crash the application or stop deterministic minimum navigation. *(AI failure application'ı crash etmemeli veya deterministic minimum navigation'ı durdurmamalıdır.)*

---

# 275. ARCore Failure Gate (ARCore Hata Gate'i)

ARCore loss must not corrupt the PDR safety baseline. *(ARCore loss PDR safety baseline'ı corrupt etmemelidir.)*

---

# 276. Model Integrity Gate (Model Bütünlük Gate'i)

Invalid model identity must block Benchmark navigation-enabled activation. *(Invalid model identity Benchmark navigation-enabled activation'ı block etmelidir.)*

---

# 277. Thermal Gate (Termal Gate)

Thermal pressure must not silently degrade estimator integrity or evidence collection. *(Thermal pressure estimator integrity veya evidence collection'ı sessizce degrade etmemelidir.)*

---

# 278. Minimum Successful Risk Strategy (Minimum Başarılı Risk Stratejisi)

The minimum successful implementation will provide deterministic fallback from AI to non-AI navigation, from learned step length to deterministic step length, from ARCore to PDR, from fused EKF output to independent PDR when necessary, and from degraded sources to explicit unreliable or unavailable state when no safe estimate remains. *(Minimum successful implementation AI'dan non-AI navigation'a, learned step length'ten deterministic step length'e, ARCore'dan PDR'a, gerektiğinde fused EKF output'tan independent PDR'a ve safe estimate kalmadığında degraded source'lardan explicit unreliable veya unavailable state'e deterministik fallback sağlayacaktır.)*

---

# 279. Target Successful Risk Strategy (Hedef Başarılı Risk Stratejisi)

The target implementation will additionally provide automated risk counters, structured fallback events, hysteresis-based recovery, failure injection suites, runtime quality-driven source weighting, integrity self-tests, performance degradation profiles, and formal risk-evidence traceability. *(Hedef implementation ek olarak automated risk counter'ları, structured fallback event'leri, hysteresis-based recovery, failure injection suite'leri, runtime quality-driven source weighting, integrity self-test'leri, performance degradation profile'ları ve formal risk-evidence traceability sağlayacaktır.)*

---

# 280. Risk Strategy Non-Goals (Risk Stratejisi Olmayan Hedefler)

NAVGUARD will not guarantee uninterrupted navigation under every possible sensor or platform failure. *(NAVGUARD her possible sensor veya platform failure altında uninterrupted navigation guarantee etmeyecektir.)*

NAVGUARD will not fabricate motion when essential directional information is unavailable. *(NAVGUARD essential directional information unavailable olduğunda motion fabricate etmeyecektir.)*

NAVGUARD will not preserve optional AI or ARCore functionality at the expense of core system stability. *(NAVGUARD core system stability pahasına optional AI veya ARCore functionality'yi korumayacaktır.)*

---

# 281. Additional Risk Non-Goals (Ek Risk Olmayan Hedefler)

NAVGUARD will not use RF interference to simulate GNSS denial. *(NAVGUARD GNSS denial simulate etmek için RF interference kullanmayacaktır.)*

NAVGUARD will not claim protection against a fully compromised operating system. *(NAVGUARD fully compromised operating system'a karşı protection claim etmeyecektir.)*

NAVGUARD will not claim military-grade fault tolerance. *(NAVGUARD military-grade fault tolerance claim etmeyecektir.)*

---

# 282. Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kararlar)

NAVGUARD will prefer controlled degradation over silent failure. *(NAVGUARD silent failure yerine controlled degradation tercih edecektir.)*

---

# 283. Core Fallback Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Temel Fallback Kararları)

PDR remains the mandatory fallback when AI or ARCore becomes unavailable and core PDR inputs remain valid. *(AI veya ARCore unavailable olduğunda ve core PDR input'ları valid kaldığında PDR mandatory fallback olarak kalacaktır.)*

---

# 284. Step-Length Fallback Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Step-Length Fallback Kararları)

The step-length fallback order is learned model → validated deterministic variable model → calibrated fixed step length. *(Step-length fallback sırası learned model → validated deterministic variable model → calibrated fixed step length şeklindedir.)*

---

# 285. AI Fallback Decisions Frozen by This Document (Bu Dokümanla Sabitlenen AI Fallback Kararları)

AI failure will degrade navigation to deterministic policies rather than stop the application. *(AI failure application'ı durdurmak yerine navigation'ı deterministic policy'lere degrade edecektir.)*

---

# 286. ARCore Fallback Decisions Frozen by This Document (Bu Dokümanla Sabitlenen ARCore Fallback Kararları)

Only valid `TRACKING` ARCore data may enter fusion. *(Yalnızca valid `TRACKING` ARCore data fusion'a girebilir.)*

`PAUSED` or invalid ARCore data will be rejected. *(`PAUSED` veya invalid ARCore data rejected olacaktır.)*

---

# 287. ARCore Recovery Decisions Frozen by This Document (Bu Dokümanla Sabitlenen ARCore Recovery Kararları)

Recovered ARCore tracking will generally begin a new segment rather than assume seamless world-coordinate continuity. *(Recovered ARCore tracking seamless world-coordinate continuity varsaymak yerine genellikle new segment başlatacaktır.)*

---

# 288. Heading Fallback Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Heading Fallback Kararları)

Magnetic disturbance may reduce or remove magnetic heading influence while valid gyro propagation continues. *(Magnetic disturbance valid gyro propagation devam ederken magnetic heading influence'ı reduce veya remove edebilir.)*

---

# 289. Heading Stop Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Heading Stop Kararları)

If no defensible heading remains, directional PDR propagation will not continue indefinitely. *(Defensible heading kalmazsa directional PDR propagation indefinitely devam etmeyecektir.)*

---

# 290. EKF Fallback Decisions Frozen by This Document (Bu Dokümanla Sabitlenen EKF Fallback Kararları)

Independent PDR remains preserved even when EKF fusion is active. *(EKF fusion active olsa bile independent PDR preserved kalacaktır.)*

Invalid EKF output may fall back to independent PDR. *(Invalid EKF output independent PDR'a fallback yapabilir.)*

---

# 291. GNSS Fallback Decisions Frozen by This Document (Bu Dokümanla Sabitlenen GNSS Fallback Kararları)

Poor GNSS will be rejected rather than forced into anchor or recovery. *(Poor GNSS anchor veya recovery'ye forced edilmek yerine rejected olacaktır.)*

---

# 292. Ground Truth Firewall Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Ground Truth Firewall Kararları)

Any detected unauthorized GNSS estimator influence invalidates the affected formal denied interval. *(Detected herhangi bir unauthorized GNSS estimator influence affected formal denied interval'ı invalid hale getirir.)*

---

# 293. Recovery Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Recovery Kararları)

Recovery correction may occur only after pre-correction state and error evidence have been captured. *(Recovery correction yalnızca pre-correction state ve error evidence captured olduktan sonra gerçekleşebilir.)*

---

# 294. Historical Integrity Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Geçmiş Bütünlük Kararları)

Recovery will not retroactively modify historical denied trajectories. *(Recovery historical denied trajectory'leri retroactively modify etmeyecektir.)*

---

# 295. Storage Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Storage Kararları)

Critical logging failure may invalidate a formal session. *(Critical logging failure formal session'ı invalid hale getirebilir.)*

Interrupted sessions will remain `INCOMPLETE` until verified. *(Interrupted session'lar verified olana kadar `INCOMPLETE` kalacaktır.)*

---

# 296. Permission Fallback Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Permission Fallback Kararları)

Camera permission loss disables ARCore but does not disable valid PDR. *(Camera permission loss ARCore'u disable eder ancak valid PDR'ı disable etmez.)*

Activity Recognition loss affects only optional Android step-sensor comparison. *(Activity Recognition loss yalnızca optional Android step-sensor comparison'ı etkiler.)*

---

# 297. Performance Fallback Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Performans Fallback Kararları)

Non-critical UI and diagnostics will be reduced before navigation-critical acquisition or integrity evidence is sacrificed. *(Navigation-critical acquisition veya integrity evidence sacrifice edilmeden önce non-critical UI ve diagnostic'ler reduced olacaktır.)*

---

# 298. Thermal Fallback Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Termal Fallback Kararları)

Thermal pressure may disable optional ARCore or AI influence if necessary while preserving deterministic navigation where possible. *(Thermal pressure gerektiğinde optional ARCore veya AI influence'ı disable ederken mümkün olduğunda deterministic navigation'ı preserve edebilir.)*

---

# 299. Project Scope Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Proje Kapsam Kararları)

Optional features will be removed before core research deliverables are compromised by schedule pressure. *(Schedule pressure nedeniyle core research deliverable'lar compromise edilmeden önce optional feature'lar removed olacaktır.)*

---

# 300. Research Integrity Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Araştırma Bütünlük Kararları)

Valid poor-performing sessions will remain in the benchmark. *(Valid poor-performing session'lar benchmark içerisinde kalacaktır.)*

Final benchmark data will not be used for post-hoc tuning. *(Final benchmark data post-hoc tuning için kullanılmayacaktır.)*

---

# 301. Decisions Pending Physical Sensor Audit (Fiziksel Sensör Audit'ini Bekleyen Kararlar)

Final sensor freshness thresholds remain pending device evidence. *(Final sensor freshness threshold'ları device evidence'ını beklemektedir.)*

Final sensor-rate degradation thresholds remain pending device evidence. *(Final sensor-rate degradation threshold'ları device evidence'ını beklemektedir.)*

---

# 302. Decisions Pending Heading Calibration (Heading Kalibrasyonunu Bekleyen Kararlar)

The final magnetic-disturbance rejection threshold remains pending physical calibration. *(Final magnetic-disturbance rejection threshold physical calibration'ı beklemektedir.)*

The maximum tolerable open-loop gyro interval remains pending experiments. *(Maximum tolerable open-loop gyro interval experiment'leri beklemektedir.)*

---

# 303. Decisions Pending ARCore Validation (ARCore Validation'ı Bekleyen Kararlar)

The final ARCore recovery-stability duration remains pending physical tests. *(Final ARCore recovery-stability duration physical testleri beklemektedir.)*

The final ARCore-to-ENU alignment acceptance tolerance remains pending calibration. *(Final ARCore-to-ENU alignment acceptance tolerance calibration'ı beklemektedir.)*

---

# 304. Decisions Pending AI Profiling (AI Profiling'i Bekleyen Kararlar)

The final AI stale-output timeout remains pending end-to-end latency measurements. *(Final AI stale-output timeout end-to-end latency measurement'larını beklemektedir.)*

The final low-confidence navigation gate remains pending held-out validation. *(Final low-confidence navigation gate held-out validation'ı beklemektedir.)*

---

# 305. Decisions Pending EKF Calibration (EKF Kalibrasyonunu Bekleyen Kararlar)

Final NIS thresholds, `Q`, `R`, and fallback covariance settings remain pending calibration evidence. *(Final NIS threshold'ları, `Q`, `R` ve fallback covariance setting'leri calibration evidence'ını beklemektedir.)*

---

# 306. Decisions Pending Storage Profiling (Storage Profiling Bekleyen Kararlar)

The final pre-run free-space threshold remains pending measured bytes-per-minute. *(Final pre-run free-space threshold measured bytes-per-minute değerini beklemektedir.)*

The final writer queue size remains pending stress tests. *(Final writer queue size stress testlerini beklemektedir.)*

---

# 307. Decisions Pending Thermal Testing (Termal Testleri Bekleyen Kararlar)

The final thermal warning and fallback thresholds remain pending Redmi Note 9 Pro endurance testing. *(Final thermal warning ve fallback threshold'ları Redmi Note 9 Pro endurance testing'i beklemektedir.)*

---

# 308. Decisions Pending Battery Testing (Batarya Testlerini Bekleyen Kararlar)

The final low-battery readiness threshold remains pending representative session measurements. *(Final low-battery readiness threshold representative session measurement'larını beklemektedir.)*

---

# 309. Final Risk Analysis & Fallback Strategy Statement (Nihai Risk Analizi ve Fallback Stratejisi Bildirimi)

**NAVGUARD will treat failure handling as part of the navigation architecture rather than as an afterthought, with every major sensor, AI, ARCore, GNSS, fusion, storage, permission, performance, and field risk mapped to an explicit detection signal, quality transition, fallback path, and evidence record.** *(NAVGUARD failure handling'i sonradan eklenen unsur yerine navigation architecture'ın parçası olarak ele alacak ve her major sensor, AI, ARCore, GNSS, fusion, storage, permission, performance ve field risk'ini explicit detection signal, quality transition, fallback path ve evidence record ile eşleyecektir.)*

**The central runtime fallback philosophy will move from the full AI-assisted fusion stack toward increasingly deterministic and simpler navigation, preserving PDR whenever accepted steps, valid timing, defensible heading, and deterministic step length remain available, and stopping at `UNRELIABLE` or `UNAVAILABLE` rather than fabricating motion after those conditions fail.** *(Merkezi runtime fallback philosophy full AI-assisted fusion stack'ten giderek daha deterministic ve simpler navigation'a doğru ilerleyecek; accepted step, valid timing, defensible heading ve deterministic step length available olduğu sürece PDR'ı preserve edecek ve bu condition'lar fail olduktan sonra motion fabricate etmek yerine `UNRELIABLE` veya `UNAVAILABLE` durumunda duracaktır.)*

**Motion AI failure will fall back to deterministic navigation logic, learned step-length failure will fall back through deterministic variable estimation to calibrated fixed step length, and ARCore tracking loss will remove ARCore from fusion while leaving PDR active whenever its own inputs remain valid.** *(Motion AI failure deterministic navigation logic'e fallback yapacak, learned step-length failure deterministic variable estimation üzerinden calibrated fixed step length'e fallback yapacak ve ARCore tracking loss kendi input'ları valid kaldığında PDR'ı active bırakırken ARCore'u fusion'dan çıkaracaktır.)*

**Magnetic disturbance will reduce or reject absolute magnetic corrections while valid short-term gyro propagation continues, but NAVGUARD will not continue directional step propagation indefinitely when no defensible heading source remains.** *(Magnetic disturbance valid short-term gyro propagation devam ederken absolute magnetic correction'ları reduce veya reject edecek ancak defensible heading source kalmadığında NAVGUARD directional step propagation'a indefinitely devam etmeyecektir.)*

**EKF failure will never destroy the independent PDR safety baseline, poor GNSS will never be forced into an anchor or recovery update, and recovery will never overwrite the historical denied trajectory or occur before the pre-correction estimator state and recovery error have been preserved.** *(EKF failure independent PDR safety baseline'ı hiçbir zaman destroy etmeyecek, poor GNSS hiçbir zaman anchor veya recovery update'e forced edilmeyecek ve recovery historical denied trajectory'yi overwrite etmeyecek veya pre-correction estimator state ile recovery error preserved olmadan gerçekleşmeyecektir.)*

**Ground Truth Firewall failure remains a critical non-recoverable benchmark-integrity event: any detected unauthorized GNSS influence on PDR, AI, EKF, heading, anchor state, uncertainty, or fused position will invalidate the affected formal denied interval regardless of how accurate the resulting trajectory appears.** *(Ground Truth Firewall failure critical non-recoverable benchmark-integrity event olarak kalır; PDR, AI, EKF, heading, anchor state, uncertainty veya fused position üzerinde detected herhangi bir unauthorized GNSS influence, resulting trajectory ne kadar accurate görünürse görünsün affected formal denied interval'ı invalid hale getirecektir.)*

**Performance degradation will remove decorative UI load and optional expensive subsystems before navigation-critical acquisition, causal estimation, Ground Truth Firewall enforcement, or mandatory evidence logging is sacrificed, and severe thermal or operational instability will terminate the session rather than force unsafe completion.** *(Performance degradation navigation-critical acquisition, causal estimation, Ground Truth Firewall enforcement veya mandatory evidence logging sacrifice edilmeden önce decorative UI load ve optional expensive subsystem'leri kaldıracak ve severe thermal veya operational instability unsafe completion zorlamak yerine session'ı terminate edecektir.)*

**Project-schedule fallback will follow the same principle as runtime fallback: optional quantization, delegate optimization, broad device generalization, advanced uncertainty analysis, learned step length, or secondary stress features may be reduced or removed before the core 24-day research pipeline of acquisition, timing, GNSS isolation, PDR, logging, replay, evaluation, and field benchmark is compromised.** *(Project-schedule fallback runtime fallback ile aynı principle'ı izleyecek; optional quantization, delegate optimization, broad device generalization, advanced uncertainty analysis, learned step length veya secondary stress feature'lar core 24-day research pipeline olan acquisition, timing, GNSS isolation, PDR, logging, replay, evaluation ve field benchmark compromise edilmeden önce reduce veya remove edilebilecektir.)*

---

# 310. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development Risk Analysis & Fallback Strategy Completed *(Doküman Durumu: Geliştirme Öncesi Risk Analizi ve Fallback Stratejisi Tamamlandı)*

**Primary Failure Philosophy:** Explicit Degradation over Silent Failure *(Temel Hata Felsefesi: Sessiz Failure Yerine Explicit Degradation)*

**Primary Integrity Philosophy:** Integrity before Demo Performance *(Temel Bütünlük Felsefesi: Demo Performansından Önce Bütünlük)*

**Minimum Navigation Backbone:** Steps + Heading + Deterministic Step Length + Timing + ENU PDR *(Minimum Navigasyon Omurgası: Steps + Heading + Deterministic Step Length + Timing + ENU PDR)*

**AI as Single Point of Failure:** No *(AI Single Point of Failure: Hayır)*

**ARCore as Single Point of Failure:** No *(ARCore Single Point of Failure: Hayır)*

**EKF as Single Point of Failure:** No *(EKF Single Point of Failure: Hayır)*

**Independent PDR Baseline:** Always Preserved *(Independent PDR Baseline: Her Zaman Korunur)*

**AI Failure Fallback:** Deterministic Navigation *(AI Hata Fallback'i: Deterministic Navigation)*

**AI Low Confidence:** `UNKNOWN` / Deterministic Policy Candidate *(AI Low Confidence: `UNKNOWN` / Deterministic Policy Adayı)*

**AI Stale Output:** Rejected after Freshness Limit *(AI Stale Output: Freshness Limit Sonrası Reddedilir)*

**Learned Step-Length Fallback 1:** Deterministic Variable *(Learned Step-Length Fallback 1: Deterministic Variable)*

**Learned Step-Length Fallback 2:** Calibrated Fixed Step Length *(Learned Step-Length Fallback 2: Calibrated Fixed Step Length)*

**ARCore Valid Fusion State:** `TRACKING` Only *(ARCore Geçerli Fusion State: Yalnızca `TRACKING`)*

**ARCore `PAUSED`:** Rejected from Fusion *(ARCore `PAUSED`: Fusion'dan Reddedilir)*

**ARCore Tracking Loss:** PDR Continues *(ARCore Tracking Kaybı: PDR Devam Eder)*

**ARCore Recovery:** New Segment by Default *(ARCore Recovery: Varsayılan Olarak Yeni Segment)*

**ARCore-to-ENU Unvalidated:** ARCore Excluded from Formal Fusion *(ARCore-to-ENU Doğrulanmamışsa: ARCore Formal Fusion'dan Hariç)*

**Magnetic Disturbance Response:** Reject / Down-Weight Magnetic Heading *(Manyetik Bozulma Tepkisi: Magnetic Heading Reject / Down-Weight)*

**Gyroscope Loss Fallback:** Usable Absolute Heading if Available *(Jiroskop Kaybı Fallback'i: Varsa Usable Absolute Heading)*

**No Defensible Heading:** Directional PDR May Stop *(Defensible Heading Yoksa: Directional PDR Durabilir)*

**Accelerometer Loss:** Authoritative Step PDR Stops *(Accelerometer Kaybı: Authoritative Step PDR Durur)*

**Invalid Learned Step Length:** Rejected *(Invalid Learned Step Length: Reddedilir)*

**Invalid EKF State:** Not Published as Trusted *(Invalid EKF State: Trusted Olarak Publish Edilmez)*

**Invalid EKF Fallback:** Independent PDR *(Invalid EKF Fallback'i: Independent PDR)*

**Poor GNSS Anchor Candidate:** Rejected *(Poor GNSS Anchor Candidate: Reddedilir)*

**Poor GNSS Recovery Candidate:** Rejected *(Poor GNSS Recovery Candidate: Reddedilir)*

**Recovery Timeout:** Never Forces Bad Fix *(Recovery Timeout: Kötü Fix'i Asla Zorlamaz)*

**Recovery Correction Before Error Capture:** Forbidden *(Error Capture Öncesi Recovery Correction: Yasak)*

**Historical Denied Trajectory Rewrite:** Forbidden *(Historical Denied Trajectory Rewrite: Yasak)*

**Ground Truth Firewall Severity:** Critical *(Ground Truth Firewall Severity: Critical)*

**Unauthorized GNSS Estimator Update Required Count:** `0` *(Unauthorized GNSS Estimator Update Gerekli Count: `0`)*

**Ground Truth Firewall Violation:** Formal Denied Interval Invalid *(Ground Truth Firewall İhlali: Formal Denied Interval Invalid)*

**Leaked Benchmark Salvage:** Forbidden *(Sızmış Benchmark Kurtarma: Yasak)*

**Low Storage Response:** Block Formal Start / Abort if Necessary *(Low Storage Tepkisi: Formal Start'ı Block Et / Gerekirse Abort)*

**Critical Writer Failure:** May Invalidate Formal Session *(Critical Writer Failure: Formal Session'ı Invalid Hale Getirebilir)*

**Interrupted Session:** `INCOMPLETE` *(Interrupted Session: `INCOMPLETE`)*

**Camera Permission Loss:** ARCore Disabled, PDR Preserved *(Camera Permission Loss: ARCore Disabled, PDR Preserved)*

**Activity Recognition Loss:** Optional Step Comparison Only *(Activity Recognition Loss: Yalnızca Optional Step Comparison)*

**CPU Pressure First Reduction:** Diagnostics / UI *(CPU Pressure İlk Reduction: Diagnostics / UI)*

**Thermal Pressure Optional Reduction:** ARCore / AI if Necessary *(Thermal Pressure Optional Reduction: Gerekirse ARCore / AI)*

**Mandatory Evidence Logging Removed for Performance:** Forbidden *(Performans İçin Mandatory Evidence Logging Kaldırma: Yasak)*

**UI Rendering Rate:** May Be Throttled *(UI Rendering Rate: Throttle Edilebilir)*

**Estimator Processing Rate:** Independent from UI Throttling *(Estimator Processing Rate: UI Throttling'den Bağımsız)*

**Field Safety Priority:** Above Benchmark Completion *(Field Safety Önceliği: Benchmark Completion'ın Üzerinde)*

**Route Deviation:** Review Required *(Route Deviation: Review Gerekli)*

**Poor Valid Result:** Retained *(Kötü Geçerli Sonuç: Korunur)*

**Poor Ground Truth Session:** Metric-Specific Exclusion Possible *(Poor Ground Truth Session: Metric-Specific Exclusion Mümkün)*

**Session-Wise ML Split:** Mandatory *(Session-Wise ML Split: Zorunlu)*

**Final Benchmark Post-Hoc Tuning:** Forbidden *(Final Benchmark Post-Hoc Tuning: Yasak)*

**Primary ≥20% Target Relaxation after Results:** Forbidden *(Sonuçlardan Sonra Primary ≥%20 Hedef Gevşetme: Yasak)*

**Schedule Pressure Response:** Remove Optional Features First *(Schedule Pressure Tepkisi: Önce Optional Feature'ları Kaldır)*

**Quantization:** Optional *(Quantization: İsteğe Bağlı)*

**Hardware Delegate:** Optional / Measured Benefit Required *(Hardware Delegate: İsteğe Bağlı / Measured Benefit Gerekli)*

**Learned Step Length:** Target Enhancement, Not Minimum Dependency *(Learned Step Length: Target Enhancement, Minimum Dependency Değil)*

**Cross-Device Generalization:** Optional *(Cross-Device Generalization: İsteğe Bağlı)*

**Failure Injection Testing:** Mandatory *(Failure Injection Testing: Zorunlu)*

**Fallback Event Logging:** Mandatory for Meaningful Transitions *(Fallback Event Logging: Meaningful Transition'lar İçin Zorunlu)*

**Fallback Determinism:** Required *(Fallback Determinizmi: Gerekli)*

**Fallback Recovery Hysteresis:** Target *(Fallback Recovery Hysteresis: Hedef)*

**Final Sensor Freshness Thresholds:** Pending Physical Audit *(Final Sensor Freshness Threshold'ları: Fiziksel Audit Bekleniyor)*

**Final Magnetic Disturbance Thresholds:** Pending Calibration *(Final Magnetic Disturbance Threshold'ları: Calibration Bekleniyor)*

**Final ARCore Recovery Stability Rule:** Pending Device Tests *(Final ARCore Recovery Stability Rule: Device Testleri Bekleniyor)*

**Final AI Stale Timeout:** Pending Latency Profiling *(Final AI Stale Timeout: Latency Profiling Bekleniyor)*

**Final AI Confidence Gate:** Pending Held-Out Validation *(Final AI Confidence Gate: Held-Out Validation Bekleniyor)*

**Final EKF NIS Thresholds:** Pending Calibration *(Final EKF NIS Threshold'ları: Calibration Bekleniyor)*

**Final `Q` / `R` / Fallback Covariance:** Pending Calibration *(Final `Q` / `R` / Fallback Covariance: Calibration Bekleniyor)*

**Final Free-Storage Threshold:** Pending Storage Profiling *(Final Free-Storage Threshold: Storage Profiling Bekleniyor)*

**Final Writer Queue Size:** Pending Stress Testing *(Final Writer Queue Size: Stress Testing Bekleniyor)*

**Final Thermal Fallback Thresholds:** Pending Endurance Tests *(Final Thermal Fallback Threshold'ları: Endurance Testleri Bekleniyor)*

**Final Low-Battery Readiness Threshold:** Pending Battery Tests *(Final Low-Battery Readiness Threshold: Battery Testleri Bekleniyor)*

**Next Documentation Item:** 38 — 24-Day Development Roadmap *(Sonraki Dokümantasyon Öğesi: 38 — 24 Günlük Geliştirme Yol Haritası)*
