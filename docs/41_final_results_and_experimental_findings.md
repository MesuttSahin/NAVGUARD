# 41 — Final Results & Experimental Findings (Final Sonuçlar ve Deneysel Bulgular)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the structure in which NAVGUARD’s final experimental results will be recorded, validated, interpreted, and reported after the frozen benchmark is complete. *(Bu doküman NAVGUARD’ın final deneysel sonuçlarının frozen benchmark tamamlandıktan sonra kaydedileceği, doğrulanacağı, yorumlanacağı ve raporlanacağı yapıyı tanımlar.)*

No measured result will be inserted into this document before the corresponding physical experiment, replay analysis, and integrity checks have been completed. *(İlgili fiziksel deney, replay analysis ve integrity check’ler tamamlanmadan bu dokümana hiçbir measured result eklenmeyecektir.)*

---

# 2. Current Result State (Mevcut Sonuç Durumu)

At the time of writing, final benchmark measurements do not yet exist. *(Bu doküman yazılırken final benchmark ölçümleri henüz mevcut değildir.)*

Therefore, every numerical field in this page remains `TBD` until supported by real evidence. *(Bu nedenle bu sayfadaki her sayısal alan gerçek evidence ile desteklenene kadar `TBD` olarak kalacaktır.)*

---

# 3. No Fabricated Results Rule (Uydurma Sonuç Kuralı)

NAVGUARD will not pre-fill plausible-looking accuracy, drift, latency, battery, AI, or ARCore results. *(NAVGUARD plausible görünen accuracy, drift, latency, battery, AI veya ARCore result’larını önceden doldurmayacaktır.)*

Unmeasured values will remain unknown rather than being estimated for presentation convenience. *(Ölçülmemiş value’lar presentation kolaylığı için tahmin edilmek yerine unknown kalacaktır.)*

---

# 4. Evidence-First Reporting (Önce Evidence Raporlama)

Every final numerical result must trace back to a frozen build, a valid session or test set, a known configuration, and a frozen analysis pipeline. *(Her final numerical result frozen build’e, valid session veya test set’e, known configuration’a ve frozen analysis pipeline’a trace edebilmelidir.)*

---

# 5. Result Source Hierarchy (Sonuç Kaynağı Hiyerarşisi)

Final findings will be derived from the following evidence hierarchy. *(Final bulgular aşağıdaki evidence hierarchy’den türetilecektir.)*

```text id="3ax3es"
PHYSICAL DEVICE EVIDENCE
(Fiziksel cihaz kanıtı)

        ↓

VALID SESSION MANIFESTS
(Geçerli session manifest'leri)

        ↓

FROZEN REPLAY OUTPUTS
(Frozen replay output'ları)

        ↓

FROZEN METRIC PIPELINE
(Frozen metric pipeline)

        ↓

FINAL RESULT TABLES
(Final sonuç tabloları)

        ↓

INTERPRETATION
(Yorum)
```

---

# 6. Result Categories (Sonuç Kategorileri)

Final findings will be grouped into distinct categories rather than one aggregate score. *(Final bulgular tek aggregate score yerine distinct category’lerde gruplanacaktır.)*

```text id="a4g8ql"
NAVIGATION ACCURACY
(Navigasyon doğruluğu)

PDR PERFORMANCE
(PDR performansı)

MOTION AI
(Motion AI)

STEP LENGTH
(Adım uzunluğu)

HEADING
(Heading)

ARCORE
(ARCore)

EKF / FUSION
(EKF / Füzyon)

RECOVERY
(Recovery)

UNCERTAINTY
(Belirsizlik)

PERFORMANCE
(Performans)

BATTERY
(Batarya)

THERMAL
(Termal)

FAILURE / FALLBACK
(Hata / Fallback)

RESEARCH INTEGRITY
(Araştırma bütünlüğü)
```

---

# 7. Result Interpretation Order (Sonuç Yorumlama Sırası)

Results will be interpreted in the following order: integrity, data validity, baseline performance, enhanced configurations, primary target, secondary findings, and limitations. *(Sonuçlar şu sırayla yorumlanacaktır: integrity, data validity, baseline performance, enhanced configuration’lar, primary target, secondary finding’ler ve limitation’lar.)*

---

# 8. Integrity Before Accuracy (Accuracy’den Önce Integrity)

No accuracy result will be treated as authoritative before Ground Truth Firewall, session integrity, and metric-pipeline checks pass. *(Ground Truth Firewall, session integrity ve metric-pipeline check’leri pass etmeden hiçbir accuracy result authoritative kabul edilmeyecektir.)*

---

# 9. Final Benchmark Build Identity (Final Benchmark Build Kimliği)

The exact frozen application build used for final benchmark collection will be recorded here. *(Final benchmark collection için kullanılan exact frozen application build burada kaydedilecektir.)*

```text id="y7olgn"
Final Build ID: TBD
(Final Build ID: TBD)

Commit / Revision: TBD
(Commit / Revision: TBD)

Build Type: TBD
(Build Type: TBD)

Android Version: TBD
(Android Version: TBD)
```

---

# 10. Final Device Identity (Final Cihaz Kimliği)

The primary benchmark device will be recorded explicitly. *(Primary benchmark cihazı explicit olarak kaydedilecektir.)*

```text id="95ja60"
Device: Xiaomi Redmi Note 9 Pro
(Cihaz: Xiaomi Redmi Note 9 Pro)

Device Variant: TBD
(Cihaz Variantı: TBD)

Android Version: TBD
(Android Sürümü: TBD)
```

---

# 11. Final Model Identity (Final Model Kimliği)

The exact Motion Classification model used in the benchmark will be recorded. *(Benchmark’ta kullanılan exact Motion Classification model kaydedilecektir.)*

```text id="2awjhm"
Motion Model ID: TBD
(Motion Model ID: TBD)

Model Hash: TBD
(Model Hash: TBD)

Dataset Version: TBD
(Dataset Version: TBD)

Preprocessing Version: TBD
(Preprocessing Version: TBD)
```

---

# 12. Step-Length Model Identity (Step-Length Model Kimliği)

If a learned step-length model is retained, its identity will be recorded separately. *(Learned step-length model retained edilirse identity’si ayrı olarak kaydedilecektir.)*

```text id="05165k"
Step-Length Model: TBD / NOT RETAINED
(Step-Length Model: TBD / RETAIN EDİLMEDİ)

Model ID: TBD
(Model ID: TBD)

Model Hash: TBD
(Model Hash: TBD)
```

---

# 13. Final Configuration Identity (Final Configuration Kimliği)

All four benchmark configurations will be frozen and described explicitly. *(Dört benchmark configuration da frozen ve explicit şekilde tanımlanacaktır.)*

---

# 14. Configuration A Definition (Configuration A Tanımı)

Configuration A represents the baseline deterministic PDR-only system. *(Configuration A baseline deterministic PDR-only sistemi temsil eder.)*

---

# 15. Configuration B Definition (Configuration B Tanımı)

Configuration B represents PDR with the frozen improved-heading configuration. *(Configuration B frozen improved-heading configuration ile PDR’ı temsil eder.)*

---

# 16. Configuration C Definition (Configuration C Tanımı)

Configuration C represents Configuration A enhanced by validated ARCore relative tracking while preserving Configuration A's baseline heading, deterministic step detector, and baseline step-length policy. Configuration B's improved/fused heading remains disabled. Any unavoidable ARCore integration dependency must be recorded explicitly in the frozen Configuration C profile. *(Configuration C, Configuration A'nın baseline heading, deterministic step detector ve baseline step-length policy'sini korurken Configuration A'ya validated ARCore relative tracking ekler. Configuration B'nin improved/fused heading'i devre dışı kalır. Kaçınılmaz bir ARCore integration dependency frozen Configuration C profilinde açıkça kaydedilmelidir.)*

---

# 17. Configuration D Definition (Configuration D Tanımı)

Configuration D represents the complete frozen NAVGUARD system. *(Configuration D complete frozen NAVGUARD sistemini temsil eder.)*

---

# 18. Final Configuration Matrix (Final Configuration Matrisi)

| Component (Bileşen)                         |              A |                 B |                 C |   D |
| ------------------------------------------- | -------------: | ----------------: | ----------------: | --: |
| Deterministic PDR *(Deterministik PDR)*     |              ✓ |                 ✓ |                 ✓ |   ✓ |
| Improved Heading *(Geliştirilmiş Heading)*  | Baseline / TBD |                 ✓ |     Frozen policy |   ✓ |
| Motion AI *(Motion AI)*                     |              — | — / Frozen policy | — / Frozen policy |   ✓ |
| ARCore *(ARCore)*                           |              — |                 — |                 ✓ |   ✓ |
| EKF Fusion *(EKF Füzyon)*                   |   — / Baseline | Frozen definition | Frozen definition |   ✓ |
| Learned Step Length *(Learned Step Length)* |              — |                 — |                 — | TBD |

---

# 19. Final Route Set (Final Rota Seti)

The final benchmark route set will be listed after Day 21 freeze. *(Final benchmark route set Day 21 freeze sonrasında listelenecektir.)*

```text id="5oqk7a"
STRAIGHT ROUTE ID: TBD
(DÜZ ROTA ID: TBD)

TURN-HEAVY ROUTE ID: TBD
(DÖNÜŞ YOĞUN ROTA ID: TBD)

CLOSED / NEAR-CLOSED ROUTE ID: TBD
(KAPALI / YAKIN KAPALI ROTA ID: TBD)
```

---

# 20. Final Session Inventory (Final Session Envanteri)

Every collected final benchmark session will appear in an inventory table. *(Toplanan her final benchmark session inventory table’da yer alacaktır.)*

| Session ID | Route Type (Rota Türü) | Validity (Geçerlilik) | Build | Ground Truth (Ground Truth) | Notes (Notlar) |
| ---------- | ---------------------- | --------------------- | ----- | --------------------------- | -------------- |
| TBD        | TBD                    | TBD                   | TBD   | TBD                         | TBD            |

---

# 21. Session Validity Categories (Session Geçerlilik Kategorileri)

Final sessions will be classified using explicit validity categories. *(Final session’lar explicit validity category’leri kullanılarak classified edilecektir.)*

```text id="t70287"
VALID
(Geçerli)

VALID_WITH_LIMITATION
(Sınırlamayla Geçerli)

EXCLUDED
(Hariç Tutuldu)

PENDING_REVIEW
(İnceleme Bekliyor)
```

---

# 22. Exclusion Transparency (Exclusion Şeffaflığı)

Any excluded final session must preserve the exact predeclared reason for exclusion. *(Excluded edilen herhangi bir final session exact predeclared exclusion reason’ını preserve etmelidir.)*

---

# 23. Result-Based Exclusion Is Forbidden (Sonuca Göre Exclusion Yasaktır)

A session will never be excluded merely because NAVGUARD performed poorly. *(Bir session yalnızca NAVGUARD kötü performans gösterdiği için hiçbir zaman excluded edilmeyecektir.)*

---

# 24. Final Valid Session Count (Final Geçerli Session Sayısı)

The number of valid sessions contributing to each metric will be reported. *(Her metric’e katkıda bulunan valid session sayısı raporlanacaktır.)*

```text id="z7da3t"
Straight valid sessions: TBD
(Düz geçerli session sayısı: TBD)

Turn-heavy valid sessions: TBD
(Dönüş yoğun geçerli session sayısı: TBD)

Closed valid sessions: TBD
(Kapalı geçerli session sayısı: TBD)

Total valid sessions: TBD
(Toplam geçerli session sayısı: TBD)
```

---

# 25. Ground Truth Firewall Result (Ground Truth Firewall Sonucu)

The Ground Truth Firewall result is one of the first findings to be reported. *(Ground Truth Firewall sonucu raporlanacak ilk finding’lerden biridir.)*

```text id="j5gm5x"
unauthorizedGnssEstimatorUpdateCount = TBD
```

---

# 26. Required Firewall Outcome (Gerekli Firewall Sonucu)

For every valid final denied interval, the required result is exactly zero unauthorized GNSS estimator updates. *(Her valid final denied interval için gerekli sonuç tam olarak zero unauthorized GNSS estimator update’tir.)*

---

# 27. Firewall Violation Interpretation (Firewall İhlali Yorumu)

Any value above zero invalidates the affected denied interval for primary research claims. *(Zero üzerindeki herhangi bir value affected denied interval’ı primary research claim’leri için invalid hale getirir.)*

---

# 28. Ground Truth Mutation Test Result (Ground Truth Mutation Test Sonucu)

The replay mutation test result will be recorded here. *(Replay mutation test sonucu burada kaydedilecektir.)*

```text id="84ce0i"
Protected GNSS modified during replay: YES / NO / TBD
(Protected GNSS replay sırasında değiştirildi: YES / NO / TBD)

Denied estimator changed: YES / NO / TBD
(Denied estimator değişti: YES / NO / TBD)

Expected result: NO
(Beklenen sonuç: NO)
```

---

# 29. Ground Truth Integrity Finding (Ground Truth Integrity Bulgusu)

The final finding will state whether estimator-ground-truth isolation was successfully maintained. *(Final finding estimator-ground-truth isolation’ın başarıyla korunup korunmadığını belirtecektir.)*

```text id="uezaoj"
Ground Truth Firewall Status:
(Ground Truth Firewall Durumu:)

TBD
```

---

# 30. Baseline PDR Result Section (Baseline PDR Sonuç Bölümü)

Configuration A results will be reported before any enhanced configuration. *(Herhangi bir enhanced configuration’dan önce Configuration A result’ları raporlanacaktır.)*

---

# 31. Why Baseline Comes First (Baseline Neden Önce Gelir)

NAVGUARD improvement cannot be interpreted without knowing how the deterministic PDR baseline behaves under the same sessions. *(Deterministic PDR baseline’ın aynı session’larda nasıl davrandığı bilinmeden NAVGUARD improvement yorumlanamaz.)*

---

# 32. Configuration A Session Metrics (Configuration A Session Metrikleri)

| Session ID | Median Error m (Median Hata m) | Mean Error m (Ortalama Hata m) | RMSE m | P95 m | Final Error m (Final Hata m) |
| ---------- | -----------------------------: | -----------------------------: | -----: | ----: | ---------------------------: |
| TBD        |                            TBD |                            TBD |    TBD |   TBD |                          TBD |

---

# 33. Configuration A Aggregate Metrics (Configuration A Aggregate Metrikleri)

```text id="0u1dvy"
A Aggregated Median Error: TBD m
(A Aggregated Median Error: TBD m)

A Mean Session Median Error: TBD m
(A Mean Session Median Error: TBD m)

A Aggregated Final Error: TBD m
(A Aggregated Final Error: TBD m)

A Drift per Minute: TBD
(A Dakika Başına Drift: TBD)
```

---

# 34. Configuration B Result Section (Configuration B Sonuç Bölümü)

Configuration B will quantify the effect of the improved-heading pathway relative to the baseline. *(Configuration B improved-heading pathway’in baseline’a göre etkisini quantify edecektir.)*

---

# 35. Configuration B Metrics (Configuration B Metrikleri)

| Session ID | A Median m | B Median m | Change % (Değişim %) |
| ---------- | ---------: | ---------: | -------------------: |
| TBD        |        TBD |        TBD |                  TBD |

---

# 36. Improved Heading Contribution (Geliştirilmiş Heading Katkısı)

The final interpretation will state whether improved heading reduced, increased, or did not materially change navigation error. *(Final interpretation improved heading’in navigation error’ı azaltıp azaltmadığını, artırıp artırmadığını veya materially değiştirmediğini belirtecektir.)*

---

# 37. Configuration C Result Section (Configuration C Sonuç Bölümü)

Configuration C will quantify the contribution of ARCore relative tracking under the frozen ablation definition. *(Configuration C frozen ablation definition altında ARCore relative tracking contribution’ını quantify edecektir.)*

---

# 38. Configuration C Metrics (Configuration C Metrikleri)

| Session ID | A Median m | C Median m | Change % (Değişim %) | ARCore Tracking Availability % |
| ---------- | ---------: | ---------: | -------------------: | -----------------------------: |
| TBD        |        TBD |        TBD |                  TBD |                            TBD |

---

# 39. ARCore Contribution Interpretation (ARCore Katkı Yorumu)

ARCore will only be described as beneficial if matched evidence demonstrates a defensible improvement. *(ARCore yalnızca matched evidence defensible improvement gösterirse beneficial olarak tanımlanacaktır.)*

---

# 40. Configuration D Result Section (Configuration D Sonuç Bölümü)

Configuration D represents the full NAVGUARD system and provides the primary research comparison against Configuration A. *(Configuration D full NAVGUARD sistemini temsil eder ve Configuration A’ya karşı primary research comparison’ı sağlar.)*

---

# 41. Configuration D Session Metrics (Configuration D Session Metrikleri)

| Session ID | Median Error m | Mean Error m | RMSE m | P95 m | Final Error m |
| ---------- | -------------: | -----------: | -----: | ----: | ------------: |
| TBD        |            TBD |          TBD |    TBD |   TBD |           TBD |

---

# 42. Primary A-versus-D Table (Temel A-versus-D Tablosu)

| Metric (Metrik)                                          | A — PDR | D — NAVGUARD | Relative Change (Göreli Değişim) |
| -------------------------------------------------------- | ------: | -----------: | -------------------------------: |
| Aggregated Median Error *(Aggregated Median Hata)*       |     TBD |          TBD |                              TBD |
| Mean Error *(Ortalama Hata)*                             |     TBD |          TBD |                              TBD |
| RMSE                                                     |     TBD |          TBD |                              TBD |
| P95 Error *(P95 Hata)*                                   |     TBD |          TBD |                              TBD |
| Final Pre-Correction Error *(Final Pre-Correction Hata)* |     TBD |          TBD |                              TBD |
| Drift / Minute *(Drift / Dakika)*                        |     TBD |          TBD |                              TBD |
| Drift / Distance *(Drift / Mesafe)*                      |     TBD |          TBD |                              TBD |

---

# 43. Primary Improvement Formula (Temel İyileştirme Formülü)

The primary relative improvement will be calculated from the frozen aggregated matched-session median-error metric. *(Primary relative improvement frozen aggregated matched-session median-error metric’ten hesaplanacaktır.)*

```text id="u9xgij"
Improvement_% =
100 ×
(Error_A - Error_D)
/
Error_A
```

---

# 44. Primary Research Target (Temel Araştırma Hedefi)

The predefined primary target is at least `20%` reduction in Configuration D relative to Configuration A. *(Predefined primary target Configuration D’nin Configuration A’ya göre en az `20%` reduction sağlamasıdır.)*

---

# 45. Primary Target Result Field (Temel Hedef Sonuç Alanı)

```text id="qpql1u"
Observed Improvement: TBD %
(Gözlenen İyileşme: TBD %)

Primary Target ≥20%:
(Primary Hedef ≥20%:)

TBD
```

---

# 46. Primary Outcome Categories (Temel Sonuç Kategorileri)

The final research outcome will be assigned to one of the frozen categories. *(Final research outcome frozen category’lerden birine atanacaktır.)*

```text id="2hyyss"
TARGET_MET
(HEDEF_KARŞILANDI)

PARTIAL_IMPROVEMENT
(KISMİ_İYİLEŞME)

NO_MEASURABLE_IMPROVEMENT
(ÖLÇÜLEBİLİR_İYİLEŞME_YOK)

REGRESSION
(GERİLEME)

INCONCLUSIVE
(SONUÇSUZ)
```

---

# 47. Final Primary Outcome (Final Temel Sonuç)

```text id="9zlxsn"
Primary Research Outcome:
(Temel Araştırma Sonucu:)

TBD
```

---

# 48. Route-Specific Results (Rota Özel Sonuçlar)

Results will be reported separately for straight, turn-heavy, and closed or near-closed routes. *(Result’lar straight, turn-heavy ve closed veya near-closed route’lar için ayrı raporlanacaktır.)*

---

# 49. Straight Route Result Table (Düz Rota Sonuç Tablosu)

| Metric                           |   A |   B |   C |   D |
| -------------------------------- | --: | --: | --: | --: |
| Median Error m *(Median Hata m)* | TBD | TBD | TBD | TBD |
| Final Error m *(Final Hata m)*   | TBD | TBD | TBD | TBD |
| Drift / min *(Drift / dk)*       | TBD | TBD | TBD | TBD |

---

# 50. Turn-Heavy Route Result Table (Dönüş Yoğun Rota Sonuç Tablosu)

| Metric                           |   A |   B |   C |   D |
| -------------------------------- | --: | --: | --: | --: |
| Median Error m *(Median Hata m)* | TBD | TBD | TBD | TBD |
| Final Error m *(Final Hata m)*   | TBD | TBD | TBD | TBD |
| Drift / min *(Drift / dk)*       | TBD | TBD | TBD | TBD |

---

# 51. Closed Route Result Table (Kapalı Rota Sonuç Tablosu)

| Metric                             |   A |   B |   C |   D |
| ---------------------------------- | --: | --: | --: | --: |
| Median Error m *(Median Hata m)*   | TBD | TBD | TBD | TBD |
| Closure Error m *(Closure Hata m)* | TBD | TBD | TBD | TBD |
| Final Error m *(Final Hata m)*     | TBD | TBD | TBD | TBD |

---

# 52. Straight Route Interpretation (Düz Rota Yorumu)

The final report will assess whether NAVGUARD provides benefit on relatively low-turn motion. *(Final report NAVGUARD’ın relatively low-turn motion üzerinde benefit sağlayıp sağlamadığını değerlendirecektir.)*

---

# 53. Turn-Heavy Route Interpretation (Dönüş Yoğun Rota Yorumu)

The final report will assess whether improved heading and ARCore have larger value on turn-heavy motion. *(Final report improved heading ve ARCore’un turn-heavy motion üzerinde daha büyük value sağlayıp sağlamadığını değerlendirecektir.)*

---

# 54. Closed Route Interpretation (Kapalı Rota Yorumu)

Closed routes will provide additional insight through closure error and accumulated drift behavior. *(Closed route’lar closure error ve accumulated drift behavior üzerinden additional insight sağlayacaktır.)*

---

# 55. Error-over-Time Results (Zamana Göre Hata Sonuçları)

Horizontal position error will be plotted from denial start to the pre-correction recovery boundary. *(Horizontal position error denial start’tan pre-correction recovery boundary’ye kadar plot edilecektir.)*

---

# 56. Error-over-Time Figure Placeholder (Zamana Göre Hata Figure Placeholder)

```text id="cgjw0k"
FIGURE 41-01
Error vs Time — Configuration A vs D
(Hata vs Zaman — Configuration A vs D)

Status: TBD
(Durum: TBD)
```

---

# 57. Trajectory Comparison Figure (Trajectory Karşılaştırma Figure)

At least one representative valid route will show ground truth, Configuration A, and Configuration D together. *(En az bir representative valid route ground truth, Configuration A ve Configuration D’yi birlikte gösterecektir.)*

---

# 58. Representative Trajectory Figure Placeholder (Representative Trajectory Figure Placeholder)

```text id="tpk3ha"
FIGURE 41-02
Ground Truth vs Configuration A vs Configuration D
(Ground Truth vs Configuration A vs Configuration D)

Route ID: TBD
(Rota ID: TBD)

Selection Rule: Representative / predeclared
(Seçim Kuralı: Representative / predeclared)
```

---

# 59. No Best-Case Cherry-Picking (Best-Case Cherry-Picking Yoktur)

The representative trajectory will not be selected solely because it shows the best NAVGUARD performance. *(Representative trajectory yalnızca en iyi NAVGUARD performance’ı gösterdiği için seçilmeyecektir.)*

---

# 60. Position Error Distribution (Konum Hata Dağılımı)

Position-error distributions may be shown using box plots, empirical cumulative distributions, or session-level summary charts. *(Position-error distribution’ları box plot, empirical cumulative distribution veya session-level summary chart kullanılarak gösterilebilir.)*

---

# 61. Distribution Figure Placeholder (Dağılım Figure Placeholder)

```text id="z8wz6d"
FIGURE 41-03
Session-Level Median Error Distribution
(Session-Level Median Hata Dağılımı)

Status: TBD
(Durum: TBD)
```

---

# 62. Final Error Result (Final Hata Sonucu)

Final position error is defined as the horizontal error immediately before recovery correction. *(Final position error recovery correction’dan hemen önceki horizontal error olarak tanımlanmıştır.)*

---

# 63. Final Error Formula (Final Hata Formülü)

```text id="hih0k3"
e_final =
sqrt(
(e_E)^2 +
(e_N)^2
)
```

---

# 64. Final Error Table (Final Hata Tablosu)

| Session ID | A Final Error m | D Final Error m | Difference m (Fark m) |
| ---------- | --------------: | --------------: | --------------------: |
| TBD        |             TBD |             TBD |                   TBD |

---

# 65. No Post-Correction Inflation (Post-Correction Sonuç Şişirme Yoktur)

Post-relocalization coordinates will never be used as denied-navigation final accuracy. *(Post-relocalization coordinate’lar denied-navigation final accuracy olarak hiçbir zaman kullanılmayacaktır.)*

---

# 66. Drift-per-Time Results (Zamana Göre Drift Sonuçları)

Drift normalized by denied duration will be reported. *(Denied duration’a normalize edilmiş drift raporlanacaktır.)*

---

# 67. Drift-per-Time Formula (Zamana Göre Drift Formülü)

```text id="4z1m7f"
DriftRate_time =
FinalError /
DeniedDuration
```

---

# 68. Drift-per-Distance Results (Mesafeye Göre Drift Sonuçları)

Drift normalized by reference travel distance will be reported when reference distance is defensible. *(Reference distance defensible olduğunda drift reference travel distance’a normalize edilerek raporlanacaktır.)*

---

# 69. Drift-per-Distance Formula (Mesafeye Göre Drift Formülü)

```text id="aqw0e2"
DriftRate_distance =
FinalError /
ReferenceTravelDistance
```

---

# 70. Step Detection Result Section (Adım Tespit Sonuç Bölümü)

The deterministic step detector will be evaluated separately from navigation accuracy. *(Deterministic step detector navigation accuracy’den ayrı evaluate edilecektir.)*

---

# 71. Controlled Step Test Inventory (Controlled Step Test Envanteri)

| Test ID | Reference Steps (Referans Adım) | Detected Steps (Tespit Edilen Adım) | Absolute Error | Percentage Error |
| ------- | ------------------------------: | ----------------------------------: | -------------: | ---------------: |
| TBD     |                             TBD |                                 TBD |            TBD |              TBD |

---

# 72. Step Count Error Formula (Adım Sayısı Hata Formülü)

```text id="h3dh32"
StepError_% =
100 ×
abs(
N_detected - N_reference
)
/
N_reference
```

---

# 73. Step Count Target Result (Adım Sayısı Hedef Sonucu)

```text id="akx0x5"
Controlled Step Error Target ≤5%:
(Kontrollü Adım Hata Hedefi ≤5%:)

Observed: TBD
(Gözlenen: TBD)

Status: TBD
(Durum: TBD)
```

---

# 74. Stationary False-Step Result (Stationary False-Step Sonucu)

False accepted steps during stationary test sessions will be reported separately. *(Stationary test session’ları sırasında false accepted step’ler ayrı raporlanacaktır.)*

```text id="98effv"
Stationary Test Duration: TBD
(Stationary Test Süresi: TBD)

False Accepted Steps: TBD
(False Accepted Step: TBD)
```

---

# 75. Step Detector Interpretation (Step Detector Yorumu)

The final analysis will distinguish missed-step bias from false-step bias. *(Final analysis missed-step bias ile false-step bias’ı ayıracaktır.)*

---

# 76. Step-Length Baseline Results (Step-Length Baseline Sonuçları)

Fixed calibrated and deterministic variable methods will be compared before learned models. *(Learned model’lerden önce fixed calibrated ve deterministic variable method’lar karşılaştırılacaktır.)*

---

# 77. Step-Length Baseline Table (Step-Length Baseline Tablosu)

| Method (Yöntem)                                   | Distance Error | Bias | Downstream PDR Effect |
| ------------------------------------------------- | -------------: | ---: | --------------------: |
| Calibrated Fixed *(Kalibre Sabit)*                |            TBD |  TBD |                   TBD |
| Deterministic Variable *(Deterministik Değişken)* |            TBD |  TBD |                   TBD |

---

# 78. Learned Step-Length Result Section (Learned Step-Length Sonuç Bölümü)

Learned step length will only have a final result section if sufficient defensible label quality exists. *(Learned step length yalnızca sufficient defensible label quality mevcutsa final result section’a sahip olacaktır.)*

---

# 79. Learned Step-Length Candidate Table (Learned Step-Length Aday Tablosu)

| Model                   | Label Granularity | MAE | RMSE | Bias | Downstream Benefit |
| ----------------------- | ----------------- | --: | ---: | ---: | -----------------: |
| Linear Regression       | TBD               | TBD |  TBD |  TBD |                TBD |
| Random Forest Regressor | TBD               | TBD |  TBD |  TBD |                TBD |
| Small Neural Candidate  | TBD / N/A         | TBD |  TBD |  TBD |                TBD |

---

# 80. Learned Step-Length Retention Decision (Learned Step-Length Retention Kararı)

```text id="lphwta"
Final Learned Step-Length Status:
(Final Learned Step-Length Durumu:)

RETAINED / REJECTED / NOT_EVALUATED / TBD
```

---

# 81. Learned Model Retention Rule (Learned Model Retention Kuralı)

A learned model will not be retained merely because it has lower training error. *(Learned model yalnızca lower training error’a sahip olduğu için retained edilmeyecektir.)*

---

# 82. Heading Result Section (Heading Sonuç Bölümü)

Heading performance will be reported only where a defensible heading reference exists. *(Heading performance yalnızca defensible heading reference mevcut olduğunda raporlanacaktır.)*

---

# 83. Heading Metrics Candidate (Heading Metrik Adayları)

```text id="cl3z0y"
Heading MAE: TBD
(Heading MAE: TBD)

Heading RMSE: TBD
(Heading RMSE: TBD)

Magnetic Disturbance Rejection Events: TBD
(Magnetic Disturbance Rejection Event'leri: TBD)
```

---

# 84. Heading Quality Result (Heading Quality Sonucu)

The report will describe how often heading remained `GOOD`, `USABLE`, `DEGRADED`, or worse during valid benchmark intervals. *(Report valid benchmark interval’larda heading’in ne kadar süre `GOOD`, `USABLE`, `DEGRADED` veya daha kötü durumda kaldığını açıklayacaktır.)*

---

# 85. Motion Classification Result Section (Motion Classification Sonuç Bölümü)

Motion Classification results will be reported from the frozen held-out session-wise test set. *(Motion Classification result’ları frozen held-out session-wise test set’ten raporlanacaktır.)*

---

# 86. Motion AI Dataset Summary (Motion AI Dataset Özeti)

```text id="8nfefa"
Dataset ID: TBD
(Dataset ID: TBD)

Participants: TBD
(Katılımcılar: TBD)

Sessions: TBD
(Session: TBD)

Train Sessions: TBD
(Train Session: TBD)

Validation Sessions: TBD
(Validation Session: TBD)

Test Sessions: TBD
(Test Session: TBD)
```

---

# 87. Motion AI Class Distribution (Motion AI Class Dağılımı)

| Class (Sınıf) | Train | Validation | Test |
| ------------- | ----: | ---------: | ---: |
| STATIONARY    |   TBD |        TBD |  TBD |
| WALKING       |   TBD |        TBD |  TBD |
| RUNNING       |   TBD |        TBD |  TBD |
| TURNING       |   TBD |        TBD |  TBD |

---

# 88. Motion AI Model Comparison (Motion AI Model Karşılaştırması)

| Model               | Macro F1 | Accuracy | Size | Mobile Runtime |
| ------------------- | -------: | -------: | ---: | -------------: |
| Logistic Regression |      TBD |      TBD |  TBD |            TBD |
| Random Forest       |      TBD |      TBD |  TBD |            TBD |
| 1D-CNN              |      TBD |      TBD |  TBD |            TBD |

---

# 89. Primary Motion AI Result (Primary Motion AI Sonucu)

```text id="q0gpbm"
Selected Motion Model: TBD
(Selected Motion Model: TBD)

Held-Out Macro F1: TBD
(Held-Out Macro F1: TBD)

Target ≥0.90:
(Hedef ≥0.90:)

TBD
```

---

# 90. Per-Class Motion Metrics (Class Başına Motion Metrikleri)

| Class      | Precision | Recall |  F1 |
| ---------- | --------: | -----: | --: |
| STATIONARY |       TBD |    TBD | TBD |
| WALKING    |       TBD |    TBD | TBD |
| RUNNING    |       TBD |    TBD | TBD |
| TURNING    |       TBD |    TBD | TBD |

---

# 91. Motion AI Confusion Matrix Placeholder (Motion AI Confusion Matrix Placeholder)

```text id="0c240b"
FIGURE 41-04
Held-Out Motion Classification Confusion Matrix
(Held-Out Motion Classification Confusion Matrix)

Status: TBD
(Durum: TBD)
```

---

# 92. Motion AI Interpretation (Motion AI Yorumu)

The final interpretation will discuss which classes are strongest and weakest rather than reporting only one aggregate score. *(Final interpretation yalnızca tek aggregate score raporlamak yerine hangi class’ların strongest ve weakest olduğunu tartışacaktır.)*

---

# 93. Motion AI Operational Effect (Motion AI Operational Etkisi)

The report will state whether motion context produced measurable navigation benefit beyond classification accuracy. *(Report motion context’in classification accuracy’nin ötesinde measurable navigation benefit üretip üretmediğini belirtecektir.)*

---

# 94. AI Navigation Contribution Table (AI Navigasyon Katkı Tablosu)

| Behavior (Davranış)                                   | Enabled? | Evidence | Result |
| ----------------------------------------------------- | -------- | -------- | ------ |
| Stationary suppression *(Stationary suppression)*     | TBD      | TBD      | TBD    |
| Turn-aware profile *(Turn-aware profile)*             | TBD      | TBD      | TBD    |
| Running-specific profile *(Running-specific profile)* | TBD      | TBD      | TBD    |

---

# 95. AI Preprocessing Parity Result (AI Preprocessing Parity Sonucu)

The final Android and Python preprocessing parity result will be recorded. *(Final Android ve Python preprocessing parity sonucu kaydedilecektir.)*

```text id="b8tm4j"
Golden Tensor Parity:
(Golden Tensor Parity:)

TBD
```

---

# 96. AI Output Parity Result (AI Output Parity Sonucu)

```text id="7vnt5k"
Python vs LiteRT Output Parity:
(Python vs LiteRT Output Parity:)

TBD
```

---

# 97. AI Runtime Result Section (AI Runtime Sonuç Bölümü)

Model loading, warm-up, isolated inference, and full-stack inference will be reported separately. *(Model loading, warm-up, isolated inference ve full-stack inference ayrı raporlanacaktır.)*

---

# 98. AI Runtime Table (AI Runtime Tablosu)

| Metric                        | Result |
| ----------------------------- | -----: |
| Model Load Time ms            |    TBD |
| Warm-Up Inference ms          |    TBD |
| Median Inference ms           |    TBD |
| P95 Inference ms              |    TBD |
| Full-Stack Median ms          |    TBD |
| Full-Stack P95 ms             |    TBD |
| End-to-End Context Latency ms |    TBD |

---

# 99. AI Runtime Target Result (AI Runtime Hedef Sonucu)

```text id="do8ucg"
Frozen AI Runtime Target Statistic: TBD
(Frozen AI Runtime Hedef Statistic'i: TBD)

Target: approximately <50 ms
(Hedef: yaklaşık <50 ms)

Observed: TBD
(Gözlenen: TBD)

Status: TBD
(Durum: TBD)
```

---

# 100. AI Runtime Interpretation (AI Runtime Yorumu)

The final report will not confuse model inference time with complete window-based response latency. *(Final report model inference time ile complete window-based response latency’yi karıştırmayacaktır.)*

---

# 101. ARCore Result Section (ARCore Sonuç Bölümü)

ARCore results will cover availability, tracking quality, drift behavior, recovery, and navigation contribution. *(ARCore result’ları availability, tracking quality, drift behavior, recovery ve navigation contribution’ı kapsayacaktır.)*

---

# 102. ARCore Device Availability Result (ARCore Cihaz Availability Sonucu)

```text id="hwd3fv"
ARCore Supported: TBD
(ARCore Supported: TBD)

ARCore Runtime Ready: TBD
(ARCore Runtime Ready: TBD)
```

---

# 103. ARCore Tracking Availability (ARCore Tracking Availability)

```text id="zz0cad"
Valid TRACKING Time: TBD s
(Valid TRACKING Süresi: TBD s)

Denied Interval Duration: TBD s
(Denied Interval Süresi: TBD s)

Tracking Availability: TBD %
(Tracking Availability: TBD %)
```

---

# 104. ARCore Tracking Availability Formula (ARCore Tracking Availability Formülü)

```text id="u3sbi5"
TrackingAvailability_% =
100 ×
TrackingDuration
/
DeniedDuration
```

---

# 105. ARCore Tracking-Loss Events (ARCore Tracking-Loss Event’leri)

```text id="c0t6m2"
TRACKING → PAUSED transitions: TBD
(TRACKING → PAUSED transition sayısı: TBD)

New segments created: TBD
(Oluşturulan yeni segment sayısı: TBD)
```

---

# 106. ARCore Relative Drift Test (ARCore Relative Drift Testi)

Stationary, straight, turn, and closed-loop ARCore tests will be summarized separately. *(Stationary, straight, turn ve closed-loop ARCore test’leri ayrı summarized edilecektir.)*

---

# 107. ARCore Test Table (ARCore Test Tablosu)

| Test Type                   | Metric                      | Result |
| --------------------------- | --------------------------- | -----: |
| Stationary *(Stationary)*   | Drift                       |    TBD |
| Straight *(Straight)*       | Relative displacement error |    TBD |
| Turn *(Turn)*               | Alignment behavior          |    TBD |
| Closed Loop *(Closed Loop)* | Closure drift               |    TBD |

---

# 108. ARCore-to-ENU Alignment Result (ARCore-to-ENU Hizalama Sonucu)

```text id="fsp2s2"
Alignment Validation Status:
(Alignment Validation Durumu:)

TBD
```

---

# 109. ARCore Formal Fusion Status (ARCore Formal Fusion Durumu)

```text id="2t29wj"
ARCore in Final Fusion:
(ARCore Final Fusion'da:)

ENABLED / DISABLED / DIAGNOSTIC_ONLY / TBD
```

---

# 110. ARCore Navigation Benefit (ARCore Navigasyon Faydası)

The final result will state whether Configuration C improves navigation relative to Configuration A. *(Final result Configuration C’nin Configuration A’ya göre navigation’ı improve edip etmediğini belirtecektir.)*

---

# 111. ARCore Negative Finding Rule (ARCore Negatif Bulgusu Kuralı)

If ARCore does not improve the final metric, that result will be preserved as a legitimate negative finding. *(ARCore final metric’i improve etmezse bu result legitimate negative finding olarak preserved edilecektir.)*

---

# 112. Quality Engine Result Section (Quality Engine Sonuç Bölümü)

The Quality Engine will be evaluated by source-state behavior, invalid-measurement rejection, and fallback correctness. *(Quality Engine source-state behavior, invalid-measurement rejection ve fallback correctness üzerinden evaluate edilecektir.)*

---

# 113. Quality State Distribution (Quality State Dağılımı)

| Source        | GOOD % | USABLE % | DEGRADED % | UNRELIABLE % | UNAVAILABLE % |
| ------------- | -----: | -------: | ---------: | -----------: | ------------: |
| Heading       |    TBD |      TBD |        TBD |          TBD |           TBD |
| ARCore        |    TBD |      TBD |        TBD |          TBD |           TBD |
| AI            |    TBD |      TBD |        TBD |          TBD |           TBD |
| GNSS Recovery |    TBD |      TBD |        TBD |          TBD |           TBD |

---

# 114. Hard Invalid Rejection Result (Hard Invalid Rejection Sonucu)

```text id="j93bc2"
Hard-invalid measurements incorrectly accepted: TBD
(Hard-invalid yanlış accepted measurement sayısı: TBD)

Required result: 0
(Gerekli sonuç: 0)
```

---

# 115. Fallback Hysteresis Result (Fallback Hysteresis Sonucu)

The final report will record whether quality transitions showed unacceptable rapid oscillation. *(Final report quality transition’ların unacceptable rapid oscillation gösterip göstermediğini kaydedecektir.)*

---

# 116. EKF Result Section (EKF Sonuç Bölümü)

EKF results will cover correctness, stability, covariance behavior, and contribution to navigation accuracy. *(EKF result’ları correctness, stability, covariance behavior ve navigation accuracy contribution’ını kapsayacaktır.)*

---

# 117. EKF Final State Definition (EKF Final State Tanımı)

The authoritative initial benchmark state remains `[E,N,ψ]`. *(Authoritative initial benchmark state `[E,N,ψ]` olarak kalır.)*

---

# 118. EKF Numerical Stability Table (EKF Numerical Stabilite Tablosu)

| Check                                                  | Required Result | Observed |
| ------------------------------------------------------ | --------------- | -------- |
| Finite state *(Finite state)*                          | PASS            | TBD      |
| Finite covariance *(Finite covariance)*                | PASS            | TBD      |
| Covariance symmetry *(Covariance symmetry)*            | PASS            | TBD      |
| NaN outputs *(NaN output)*                             | 0               | TBD      |
| Invalid covariance events *(Invalid covariance event)* | 0 / handled     | TBD      |

---

# 119. EKF Outlier Rejection Result (EKF Outlier Rejection Sonucu)

```text id="qsi4zs"
Innovation-gated rejections: TBD
(Innovation-gated rejection sayısı: TBD)

Incorrectly accepted injected outliers: TBD
(Yanlış accepted injected outlier sayısı: TBD)
```

---

# 120. EKF Contribution Result (EKF Katkı Sonucu)

The final report will compare fused output against independent PDR output on the same sessions. *(Final report fused output’u same session’larda independent PDR output’a karşı compare edecektir.)*

---

# 121. Independent PDR Integrity Result (Independent PDR Integrity Sonucu)

```text id="j6p3r0"
Independent PDR preserved during EKF:
(EKF sırasında Independent PDR korundu:)

TBD
```

---

# 122. EKF Fallback Result (EKF Fallback Sonucu)

If injected EKF invalidity tests are performed, the result will verify whether the system falls back safely. *(Injected EKF invalidity test’leri yapılırsa result sistemin safe şekilde fallback yapıp yapmadığını verify edecektir.)*

---

# 123. Recovery Result Section (Recovery Sonuç Bölümü)

Recovery findings will be reported separately from denied-navigation accuracy. *(Recovery finding’leri denied-navigation accuracy’den ayrı raporlanacaktır.)*

---

# 124. Recovery Attempt Inventory (Recovery Attempt Envanteri)

| Attempt ID | Session ID | Accepted Reference? | Pre-Correction Error m | Result |
| ---------- | ---------- | ------------------- | ---------------------: | ------ |
| TBD        | TBD        | TBD                 |                    TBD | TBD    |

---

# 125. Recovery Candidate Rejection Count (Recovery Candidate Rejection Sayısı)

```text id="5hhp2u"
Rejected Recovery Candidates: TBD
(Reddedilen Recovery Candidate Sayısı: TBD)
```

---

# 126. Recovery Validation Latency (Recovery Validation Latency)

```text id="wxyhpl"
Recovery Validation Latency: TBD ms
(Recovery Validation Latency: TBD ms)
```

---

# 127. Relocalization Latency (Relocalization Latency)

```text id="a0nd5v"
Relocalization Latency: TBD ms
(Relocalization Latency: TBD ms)
```

---

# 128. Total Recovery Latency (Toplam Recovery Latency)

```text id="kznyoa"
Total Recovery Latency: TBD ms
(Toplam Recovery Latency: TBD ms)
```

---

# 129. Recovery Error Table (Recovery Hata Tablosu)

| Session | East Error m | North Error m | Horizontal Error m |
| ------- | -----------: | ------------: | -----------------: |
| TBD     |          TBD |           TBD |                TBD |

---

# 130. Recovery Ordering Result (Recovery Sıralama Sonucu)

```text id="yb6s72"
Pre-correction state captured before correction:
(Correction öncesi pre-correction state captured:)

TBD
```

---

# 131. Historical Trajectory Integrity Result (Historical Trajectory Integrity Sonucu)

```text id="3i2w82"
Historical denied trajectory modified after recovery:
(Recovery sonrası historical denied trajectory değiştirildi:)

Expected: NO
(Beklenen: NO)

Observed: TBD
(Gözlenen: TBD)
```

---

# 132. Recovery Failure Result (Recovery Failure Sonucu)

The report will record any failed or timed-out recovery attempts without hiding them. *(Report failed veya timed-out recovery attempt’leri gizlemeden kaydedecektir.)*

---

# 133. Uncertainty Result Section (Belirsizlik Sonuç Bölümü)

Position uncertainty will be evaluated separately from observed position error. *(Position uncertainty observed position error’dan ayrı evaluate edilecektir.)*

---

# 134. Covariance Validity Result (Covariance Validity Sonucu)

```text id="dqqg8p"
Finite Horizontal Covariance: TBD
(Finite Horizontal Covariance: TBD)

Symmetric Within Tolerance: TBD
(Tolerance İçinde Symmetric: TBD)

PSD Check: TBD
(PSD Check: TBD)
```

---

# 135. Uncertainty Growth Result (Belirsizlik Büyüme Sonucu)

The report will describe how uncertainty evolves during GNSS denial. *(Report uncertainty’nin GNSS denial sırasında nasıl evolve ettiğini açıklayacaktır.)*

---

# 136. Uncertainty vs Observed Error (Belirsizlik vs Gözlenen Hata)

If sufficient evidence exists, estimated uncertainty will be compared with observed position error. *(Sufficient evidence mevcutsa estimated uncertainty observed position error ile compare edilecektir.)*

---

# 137. No False Probability Claim (Yanlış Probability Claim Yoktur)

A formal `95%` confidence interpretation will only be used if empirical calibration supports it. *(Formal `95%` confidence interpretation yalnızca empirical calibration desteklerse kullanılacaktır.)*

---

# 138. Performance Result Section (Performans Sonuç Bölümü)

Runtime performance findings will summarize the cost of the final system on the target device. *(Runtime performance finding’leri final sistemin target device üzerindeki cost’unu summarize edecektir.)*

---

# 139. CPU Result Table (CPU Sonuç Tablosu)

| Configuration | CPU Avg % | CPU P95 % | CPU Peak % |
| ------------- | --------: | --------: | ---------: |
| A             |       TBD |       TBD |        TBD |
| B             |       TBD |       TBD |        TBD |
| C             |       TBD |       TBD |        TBD |
| D             |       TBD |       TBD |        TBD |

---

# 140. Memory Result Table (Memory Sonuç Tablosu)

| Configuration | Start MB | Peak MB | End MB | Growth MB |
| ------------- | -------: | ------: | -----: | --------: |
| A             |      TBD |     TBD |    TBD |       TBD |
| D             |      TBD |     TBD |    TBD |       TBD |

---

# 141. Memory Stability Finding (Memory Stabilite Bulgusu)

The final finding will state whether long-duration operation showed bounded or unbounded memory growth. *(Final finding long-duration operation’ın bounded veya unbounded memory growth gösterip göstermediğini belirtecektir.)*

---

# 142. Logging Throughput Result (Logging Throughput Sonucu)

```text id="y35f83"
Records Produced: TBD
(Üretilen Record Sayısı: TBD)

Records Written: TBD
(Yazılan Record Sayısı: TBD)

Records Dropped: TBD
(Dropped Record Sayısı: TBD)

Max Queue Depth: TBD
(Maksimum Queue Depth: TBD)
```

---

# 143. Mandatory Log Drop Result (Mandatory Log Drop Sonucu)

```text id="tzqhah"
Mandatory Benchmark Log Drops:
(Mandatory Benchmark Log Drop Sayısı:)

TBD

Target:
(Hedef:)

0
```

---

# 144. Storage Growth Result (Storage Growth Sonucu)

```text id="egpgpg"
Storage MB / Minute: TBD
(Storage MB / Dakika: TBD)

Representative Session Size MB: TBD
(Representative Session Boyutu MB: TBD)
```

---

# 145. Finalization Performance Result (Finalization Performans Sonucu)

```text id="4a60yx"
Median Finalization Latency: TBD
(Median Finalization Latency: TBD)

P95 Finalization Latency: TBD
(P95 Finalization Latency: TBD)
```

---

# 146. Battery Result Section (Batarya Sonuç Bölümü)

Battery consumption will be reported only from controlled non-charging sessions. *(Battery consumption yalnızca controlled non-charging session’lardan raporlanacaktır.)*

---

# 147. Battery Result Table (Batarya Sonuç Tablosu)

| Configuration | Duration | Battery Drop % | % / Hour |
| ------------- | -------: | -------------: | -------: |
| A             |      TBD |            TBD |      TBD |
| C             |      TBD |            TBD |      TBD |
| D             |      TBD |            TBD |      TBD |

---

# 148. Battery Interpretation (Batarya Yorumu)

The report will compare accuracy benefit against battery cost without combining them into one subjective score. *(Report accuracy benefit ile battery cost’u tek subjective score’a birleştirmeden compare edecektir.)*

---

# 149. Thermal Result Section (Termal Sonuç Bölümü)

Thermal findings will summarize device behavior during sustained full-stack operation. *(Thermal finding’ler sustained full-stack operation sırasında device behavior’ı summarize edecektir.)*

---

# 150. Thermal Result Table (Termal Sonuç Tablosu)

| Metric                | Start | End | Peak / Worst |
| --------------------- | ----: | --: | -----------: |
| Thermal State         |   TBD | TBD |          TBD |
| Temperature Indicator |   TBD | TBD |          TBD |
| AI P95 Latency        |   TBD | TBD |          TBD |

---

# 151. Thermal Throttling Finding (Thermal Throttling Bulgusu)

The report will state whether measurable throttling or runtime degradation occurred. *(Report measurable throttling veya runtime degradation oluşup oluşmadığını belirtecektir.)*

---

# 152. Long-Duration Stability Result (Uzun Süreli Stabilite Sonucu)

```text id="46etr7"
Endurance Duration: TBD
(Endurance Süresi: TBD)

Crash: TBD
(Crash: TBD)

Unbounded Memory Growth: TBD
(Unbounded Memory Growth: TBD)

Unbounded Writer Queue: TBD
(Unbounded Writer Queue: TBD)

Unbounded AI Queue: TBD
(Unbounded AI Queue: TBD)
```

---

# 153. Full-Stack Stability Finding (Full-Stack Stabilite Bulgusu)

The final report will classify full-stack operation as stable, stable with limitation, or unstable under the tested duration. *(Final report full-stack operation’ı tested duration altında stable, stable with limitation veya unstable olarak classify edecektir.)*

---

# 154. Failure Injection Result Section (Failure Injection Sonuç Bölümü)

Failure-injection results will demonstrate whether planned fallback paths behaved correctly. *(Failure-injection result’ları planned fallback path’lerin doğru behave edip etmediğini gösterecektir.)*

---

# 155. Failure Injection Matrix (Failure Injection Matrisi)

| Failure (Hata)           | Expected Response (Beklenen Tepki) | Observed (Gözlenen) | Status |
| ------------------------ | ---------------------------------- | ------------------- | ------ |
| AI load failure          | Deterministic fallback             | TBD                 | TBD    |
| AI stale output          | Expire AI context                  | TBD                 | TBD    |
| ARCore PAUSED            | Reject ARCore update               | TBD                 | TBD    |
| ARCore loss              | Continue PDR                       | TBD                 | TBD    |
| Invalid step length      | Deterministic fallback             | TBD                 | TBD    |
| Invalid EKF              | Independent PDR                    | TBD                 | TBD    |
| Bad recovery fix         | Reject candidate                   | TBD                 | TBD    |
| Sensor stale             | Quality degrade / reject           | TBD                 | TBD    |
| Writer slowdown          | Bounded queue                      | TBD                 | TBD    |
| Permission loss          | Subsystem degrade                  | TBD                 | TBD    |
| Protected GNSS injection | Block / invalidate                 | TBD                 | TBD    |

---

# 156. Fallback Determinism Result (Fallback Determinizm Sonucu)

Repeated replay with identical injected failures will be compared for identical fallback transitions. *(Identical injected failure’lara sahip repeated replay aynı fallback transition’lar açısından compare edilecektir.)*

---

# 157. AI Fallback Finding (AI Fallback Bulgusu)

The report will state whether deterministic navigation continued after AI failure. *(Report AI failure sonrasında deterministic navigation’ın continue edip etmediğini belirtecektir.)*

---

# 158. ARCore Fallback Finding (ARCore Fallback Bulgusu)

The report will state whether PDR remained valid after ARCore loss. *(Report ARCore loss sonrasında PDR’ın valid kalıp kalmadığını belirtecektir.)*

---

# 159. Heading Failure Finding (Heading Failure Bulgusu)

The report will state whether NAVGUARD correctly avoided confident directional propagation after complete heading loss. *(Report NAVGUARD’ın complete heading loss sonrasında confident directional propagation’dan correctly kaçınıp kaçınmadığını belirtecektir.)*

---

# 160. Storage Failure Finding (Storage Failure Bulgusu)

The report will state whether critical writer failures were observable and whether affected sessions were correctly degraded or invalidated. *(Report critical writer failure’ların observable olup olmadığını ve affected session’ların correctly degraded veya invalidated edilip edilmediğini belirtecektir.)*

---

# 161. Permission Failure Finding (Permission Failure Bulgusu)

The report will state whether permission loss disabled only the dependent subsystem rather than causing uncontrolled application failure. *(Report permission loss’un uncontrolled application failure yerine yalnızca dependent subsystem’i disable edip etmediğini belirtecektir.)*

---

# 162. Field Experiment Finding Section (Saha Deneyi Bulguları Bölümü)

The field section will summarize route execution quality, environment, GNSS reference quality, and operator deviations. *(Field section route execution quality, environment, GNSS reference quality ve operator deviation’ları summarize edecektir.)*

---

# 163. Field Session Summary Table (Field Session Özet Tablosu)

| Session | Route | Environment | Reference Quality | Route Deviation | Validity |
| ------- | ----- | ----------- | ----------------- | --------------- | -------- |
| TBD     | TBD   | TBD         | TBD               | TBD             | TBD      |

---

# 164. Environmental Context (Çevresel Context)

Environmental notes will be reported when they materially affect interpretation. *(Environmental note’lar interpretation’ı materially etkilediğinde raporlanacaktır.)*

---

# 165. Phone Placement Finding (Telefon Placement Bulgusu)

The final controlled phone placement used during benchmark sessions will be documented. *(Benchmark session’larında kullanılan final controlled phone placement documented edilecektir.)*

---

# 166. Participant Scope Finding (Katılımcı Scope Bulgusu)

The number and characteristics of participants relevant to the experiment will be reported without overstating generalization. *(Experiment ile relevant participant sayısı ve characteristic’leri generalization’ı overstate etmeden raporlanacaktır.)*

---

# 167. No Population-Generalization Claim (Population-Generalization Claim Yoktur)

Results from a limited participant set will not be generalized to the broader population without evidence. *(Limited participant set’ten elde edilen result’lar evidence olmadan broader population’a generalize edilmeyecektir.)*

---

# 168. GNSS Reference Quality Findings (GNSS Reference Quality Bulguları)

Reference-quality statistics will be reported separately from estimator accuracy. *(Reference-quality statistic’leri estimator accuracy’den ayrı raporlanacaktır.)*

---

# 169. Reference Quality Table (Reference Quality Tablosu)

| Session | GNSS Reference Status | Coverage % | Major Gaps | Used for Primary Position Metrics? |
| ------- | --------------------- | ---------: | ---------: | ---------------------------------- |
| TBD     | TBD                   |        TBD |        TBD | TBD                                |

---

# 170. Reference Limitation Interpretation (Reference Limitation Yorumu)

Poor GNSS reference quality may limit which metrics can be calculated without necessarily invalidating all subsystem findings. *(Poor GNSS reference quality tüm subsystem finding’lerini necessarily invalid hale getirmeden hangi metric’lerin hesaplanabileceğini limit edebilir.)*

---

# 171. Final Benchmark Inclusion Table (Final Benchmark Inclusion Tablosu)

| Session | Included? | Reason | Metrics Allowed |
| ------- | --------- | ------ | --------------- |
| TBD     | TBD       | TBD    | TBD             |

---

# 172. Statistical Summary Section (İstatistiksel Özet Bölümü)

The final report will emphasize engineering effect sizes and transparent session-level results. *(Final report engineering effect size’ları ve transparent session-level result’ları vurgulayacaktır.)*

---

# 173. Statistical Significance Rule (İstatistiksel Anlamlılık Kuralı)

Formal significance testing will only be reported if the number and structure of valid sessions justify it. *(Formal significance testing yalnızca valid session sayısı ve structure’ı bunu justify ederse raporlanacaktır.)*

---

# 174. Effect Size Priority (Effect Size Önceliği)

Observed error reduction will remain more important than unsupported significance claims. *(Observed error reduction unsupported significance claim’lerinden daha önemli kalacaktır.)*

---

# 175. Session-Level Difference Table (Session-Level Difference Tablosu)

| Session | A Median | D Median | D − A | Relative Change % |
| ------- | -------: | -------: | ----: | ----------------: |
| TBD     |      TBD |      TBD |   TBD |               TBD |

---

# 176. Session Win/Loss Count (Session Win/Loss Sayısı)

```text id="8d3qrx"
D better than A: TBD sessions
(D, A'dan daha iyi: TBD session)

A better than D: TBD sessions
(A, D'den daha iyi: TBD session)

Approximately tied: TBD sessions
(Yaklaşık eşit: TBD session)
```

---

# 177. Consistency Finding (Tutarlılık Bulgusu)

The final report will distinguish consistent small improvement from improvement driven by only one or two sessions. *(Final report consistent small improvement ile yalnızca one or two session tarafından driven improvement’ı ayıracaktır.)*

---

# 178. Ablation Finding Section (Ablation Bulguları Bölümü)

The final report will interpret what each enhancement contributes. *(Final report her enhancement’ın ne contribute ettiğini yorumlayacaktır.)*

---

# 179. Heading Ablation Finding (Heading Ablation Bulgusu)

```text id="3w0xlf"
A → B effect:
(A → B etkisi:)

TBD
```

---

# 180. ARCore Ablation Finding (ARCore Ablation Bulgusu)

```text id="9xvefi"
A → C effect:
(A → C etkisi:)

TBD
```

---

# 181. Full-System Ablation Finding (Full-System Ablation Bulgusu)

```text id="glo0cj"
A → D effect:
(A → D etkisi:)

TBD
```

---

# 182. Non-Additivity Interpretation (Non-Additivity Yorumu)

The report will not assume that heading and ARCore improvements add linearly. *(Report heading ve ARCore improvement’larının linearly add olduğunu varsaymayacaktır.)*

---

# 183. AI-vs-Navigation Finding (AI-vs-Navigation Bulgusu)

The final report will explicitly distinguish high classification accuracy from actual navigation benefit. *(Final report high classification accuracy ile actual navigation benefit’i explicitly ayıracaktır.)*

---

# 184. Learned Step-Length-vs-Navigation Finding (Learned Step-Length-vs-Navigation Bulgusu)

The final report will explicitly distinguish lower regression error from downstream PDR improvement. *(Final report lower regression error ile downstream PDR improvement’ı explicitly ayıracaktır.)*

---

# 185. ARCore-vs-Navigation Finding (ARCore-vs-Navigation Bulgusu)

The final report will explicitly distinguish ARCore tracking availability from actual drift reduction. *(Final report ARCore tracking availability ile actual drift reduction’ı explicitly ayıracaktır.)*

---

# 186. Uncertainty-vs-Accuracy Finding (Belirsizlik-vs-Accuracy Bulgusu)

The final report will explicitly distinguish uncertainty estimation quality from point-estimate accuracy. *(Final report uncertainty estimation quality ile point-estimate accuracy’yi explicitly ayıracaktır.)*

---

# 187. Performance-vs-Accuracy Finding (Performans-vs-Accuracy Bulgusu)

The final report will compare resource cost and navigation benefit without collapsing them into one score. *(Final report resource cost ile navigation benefit’i tek score’a collapse etmeden compare edecektir.)*

---

# 188. Configuration Resource Comparison (Configuration Kaynak Karşılaştırması)

| Metric             |   A |   B |   C |   D |
| ------------------ | --: | --: | --: | --: |
| CPU Avg %          | TBD | TBD | TBD | TBD |
| Peak Memory MB     | TBD | TBD | TBD | TBD |
| Battery % / h      | TBD | TBD | TBD | TBD |
| Storage MB / min   | TBD | TBD | TBD | TBD |
| Thermal Escalation | TBD | TBD | TBD | TBD |

---

# 189. Full-System Practicality Finding (Full-System Practicality Bulgusu)

The final report will state whether Configuration D is practically sustainable on the Redmi Note 9 Pro under the tested duration. *(Final report Configuration D’nin tested duration altında Redmi Note 9 Pro üzerinde practically sustainable olup olmadığını belirtecektir.)*

---

# 190. Reduced-Configuration Finding (Reduced-Configuration Bulgusu)

If Configuration D is too expensive or unstable, the report may identify a lighter configuration with a better operational tradeoff. *(Configuration D çok expensive veya unstable ise report better operational tradeoff’a sahip lighter configuration identify edebilir.)*

---

# 191. Verification Result Summary (Verification Sonuç Özeti)

The final results page will include a condensed acceptance summary from Page 39. *(Final results page Page 39’dan condensed acceptance summary içerecektir.)*

---

# 192. Mandatory Gate Summary (Mandatory Gate Özeti)

| Gate                  | Status |
| --------------------- | ------ |
| Device Integration    | TBD    |
| Sensor Acquisition    | TBD    |
| Timing                | TBD    |
| Ground Truth Firewall | TBD    |
| PDR                   | TBD    |
| Motion AI             | TBD    |
| Logging               | TBD    |
| Replay                | TBD    |
| Recovery              | TBD    |
| Failure Fallback      | TBD    |
| Final Benchmark       | TBD    |

---

# 193. Target Result Summary (Target Sonuç Özeti)

| Target                     |     Threshold | Observed | Status |
| -------------------------- | ------------: | -------: | ------ |
| Motion Macro F1            |         ≥0.90 |      TBD | TBD    |
| Step Count Error           |           ≤5% |      TBD | TBD    |
| A→D Median Error Reduction |          ≥20% |      TBD | TBD    |
| AI Runtime                 |       ~<50 ms |      TBD | TBD    |
| ARCore Usable Tracking     |        Target |      TBD | TBD    |
| Endurance Stability        | Required test |      TBD | TBD    |

---

# 194. Software Completion Result (Software Tamamlanma Sonucu)

```text id="opnafy"
Software Definition of Done:
(Software Definition of Done:)

TBD
```

---

# 195. Research Target Result (Research Hedef Sonucu)

```text id="1t3xnu"
Primary Research Target:
(Primary Research Target:)

TBD
```

---

# 196. Overall Project Acceptance Result (Genel Proje Kabul Sonucu)

```text id="deifnx"
Overall Project Status:
(Genel Proje Durumu:)

ACCEPTED / ACCEPTED_WITH_LIMITATIONS / NOT_ACCEPTED / TBD
```

---

# 197. Research Outcome Result (Research Outcome Sonucu)

```text id="sw79vi"
Research Outcome:
(Araştırma Sonucu:)

TARGET_MET /
PARTIAL_IMPROVEMENT /
NO_MEASURABLE_IMPROVEMENT /
REGRESSION /
INCONCLUSIVE /
TBD
```

---

# 198. Positive Result Interpretation (Pozitif Sonuç Yorumu)

If the `≥20%` target is met, the conclusion will state that full NAVGUARD reduced the selected matched-session median-error metric by the measured amount under the tested conditions. *(Eğer `≥20%` target karşılanırsa conclusion full NAVGUARD’ın tested condition’lar altında selected matched-session median-error metric’i measured amount kadar azalttığını belirtecektir.)*

---

# 199. Partial Improvement Interpretation (Kısmi İyileşme Yorumu)

If Configuration D improves over Configuration A but does not reach `20%`, the result will be classified as partial improvement. *(Configuration D Configuration A’ya göre improve eder ancak `20%`’ye ulaşamazsa result partial improvement olarak classified edilecektir.)*

---

# 200. No Improvement Interpretation (İyileşme Yok Yorumu)

If no meaningful difference is observed, the report will state that the tested full system did not demonstrate measurable improvement over the baseline. *(Meaningful difference gözlenmezse report tested full system’ın baseline’a göre measurable improvement demonstrate etmediğini belirtecektir.)*

---

# 201. Regression Interpretation (Regression Yorumu)

If Configuration D consistently performs worse than Configuration A, the result will be reported as regression. *(Configuration D consistently Configuration A’dan worse perform ederse result regression olarak raporlanacaktır.)*

---

# 202. Inconclusive Interpretation (Inconclusive Yorumu)

If evidence quality or sample count is insufficient for the primary claim, the result will be reported as inconclusive. *(Evidence quality veya sample count primary claim için insufficient ise result inconclusive olarak raporlanacaktır.)*

---

# 203. Negative Result Is Still Valid Research (Negatif Sonuç Yine Valid Research’tür)

A negative result does not invalidate the project when the experiment, integrity controls, and evaluation remain sound. *(Experiment, integrity control’ler ve evaluation sound kaldığında negative result projeyi invalid hale getirmez.)*

---

# 204. Final Findings Narrative (Final Bulgular Narrative)

The final narrative will summarize only conclusions directly supported by measured evidence. *(Final narrative yalnızca measured evidence tarafından directly supported conclusion’ları summarize edecektir.)*

---

# 205. Claim Scope Rule (Claim Scope Kuralı)

Every final claim must remain within the tested device, route, participant, placement, and environmental scope. *(Her final claim tested device, route, participant, placement ve environmental scope içerisinde kalmalıdır.)*

---

# 206. Forbidden Overclaim 1 (Yasak Overclaim 1)

NAVGUARD will not claim universal Android performance from Redmi Note 9 Pro evidence alone. *(NAVGUARD yalnızca Redmi Note 9 Pro evidence’ından universal Android performance claim etmeyecektir.)*

---

# 207. Forbidden Overclaim 2 (Yasak Overclaim 2)

NAVGUARD will not claim permanent GNSS replacement from short-term denied-navigation experiments. *(NAVGUARD short-term denied-navigation experiment’lerden permanent GNSS replacement claim etmeyecektir.)*

---

# 208. Forbidden Overclaim 3 (Yasak Overclaim 3)

NAVGUARD will not claim military-grade navigation from the experimental prototype. *(NAVGUARD experimental prototype’tan military-grade navigation claim etmeyecektir.)*

---

# 209. Forbidden Overclaim 4 (Yasak Overclaim 4)

NAVGUARD will not describe smartphone GNSS reference as perfect ground truth. *(NAVGUARD smartphone GNSS reference’ı perfect ground truth olarak tanımlamayacaktır.)*

---

# 210. Forbidden Overclaim 5 (Yasak Overclaim 5)

NAVGUARD will not describe AI accuracy alone as proof of navigation improvement. *(NAVGUARD AI accuracy’yi tek başına navigation improvement proof’u olarak tanımlamayacaktır.)*

---

# 211. Final Result Figure Inventory (Final Sonuç Figure Envanteri)

The final report should contain only figures supported by actual evidence. *(Final report yalnızca actual evidence tarafından supported figure’ları içermelidir.)*

---

# 212. Planned Figure 41-01 (Planlanan Figure 41-01)

```text id="cwwn8q"
Error vs Time — A vs D
(Hata vs Zaman — A vs D)

Status: TBD
(Durum: TBD)
```

---

# 213. Planned Figure 41-02 (Planlanan Figure 41-02)

```text id="xnc341"
Representative Trajectory Comparison
(Representative Trajectory Comparison)

Status: TBD
(Durum: TBD)
```

---

# 214. Planned Figure 41-03 (Planlanan Figure 41-03)

```text id="lkqr10"
Session-Level Median Error Distribution
(Session-Level Median Hata Dağılımı)

Status: TBD
(Durum: TBD)
```

---

# 215. Planned Figure 41-04 (Planlanan Figure 41-04)

```text id="kg9tdz"
Motion Classification Confusion Matrix
(Motion Classification Confusion Matrix)

Status: TBD
(Durum: TBD)
```

---

# 216. Planned Figure 41-05 (Planlanan Figure 41-05)

```text id="g5edsp"
AI Inference Latency Distribution
(AI Inference Latency Dağılımı)

Status: TBD
(Durum: TBD)
```

---

# 217. Planned Figure 41-06 (Planlanan Figure 41-06)

```text id="aau511"
ARCore Tracking Availability over Time
(ARCore Tracking Availability over Time)

Status: TBD
(Durum: TBD)
```

---

# 218. Planned Figure 41-07 (Planlanan Figure 41-07)

```text id="mml7qo"
Uncertainty vs Observed Position Error
(Belirsizlik vs Gözlenen Konum Hatası)

Status: TBD
(Durum: TBD)
```

---

# 219. Planned Figure 41-08 (Planlanan Figure 41-08)

```text id="9qsn1g"
CPU / Memory / Thermal Endurance Trend
(CPU / Memory / Thermal Endurance Trend)

Status: TBD
(Durum: TBD)
```

---

# 220. Planned Figure 41-09 (Planlanan Figure 41-09)

```text id="dv6r99"
A-B-C-D Route-Level Comparison
(A-B-C-D Rota Seviyesi Karşılaştırması)

Status: TBD
(Durum: TBD)
```

---

# 221. Planned Figure 41-10 (Planlanan Figure 41-10)

```text id="3pqhef"
Recovery Pre-Correction Error Distribution
(Recovery Pre-Correction Hata Dağılımı)

Status: TBD
(Durum: TBD)
```

---

# 222. Final Result Table Inventory (Final Sonuç Tablo Envanteri)

The final report will retain a compact set of authoritative result tables rather than duplicating the same metrics repeatedly. *(Final report aynı metric’leri repeatedly duplicate etmek yerine compact authoritative result table set’i koruyacaktır.)*

---

# 223. Required Result Table 1 (Gerekli Sonuç Tablosu 1)

The A-D primary comparison table is mandatory. *(A-D primary comparison table mandatory’dir.)*

---

# 224. Required Result Table 2 (Gerekli Sonuç Tablosu 2)

The route-specific result table is mandatory. *(Route-specific result table mandatory’dir.)*

---

# 225. Required Result Table 3 (Gerekli Sonuç Tablosu 3)

The Motion Classification metric table is mandatory. *(Motion Classification metric table mandatory’dir.)*

---

# 226. Required Result Table 4 (Gerekli Sonuç Tablosu 4)

The step-detection result table is mandatory. *(Step-detection result table mandatory’dir.)*

---

# 227. Required Result Table 5 (Gerekli Sonuç Tablosu 5)

The failure-injection and fallback result table is mandatory. *(Failure-injection ve fallback result table mandatory’dir.)*

---

# 228. Required Result Table 6 (Gerekli Sonuç Tablosu 6)

The performance summary table is mandatory. *(Performance summary table mandatory’dir.)*

---

# 229. Required Result Table 7 (Gerekli Sonuç Tablosu 7)

The final acceptance and target-status table is mandatory. *(Final acceptance ve target-status table mandatory’dir.)*

---

# 230. Evidence Linking Rule (Evidence Linking Kuralı)

Each major figure and table should include internal provenance to source sessions and analysis outputs. *(Her major figure ve table source session’lara ve analysis output’larına internal provenance içermelidir.)*

---

# 231. Result Reproducibility Rule (Sonuç Reproducibility Kuralı)

The final values must be reproducible from preserved session data and the frozen analysis pipeline. *(Final value’lar preserved session data ve frozen analysis pipeline’dan reproducible olmalıdır.)*

---

# 232. Result Regeneration Test (Sonuç Regeneration Testi)

The final analysis package should regenerate the authoritative tables and figures without manual editing of numeric values. *(Final analysis package numeric value’ların manual editing’i olmadan authoritative table ve figure’ları regenerate etmelidir.)*

---

# 233. Manual Copy Error Prevention (Manual Copy Hatası Önleme)

Where practical, charts and summary tables should be generated programmatically from accepted results. *(Practical olduğunda chart ve summary table’lar accepted result’lardan programmatically generate edilmelidir.)*

---

# 234. Result Freeze (Sonuç Freeze)

Once final accepted results are generated, the analysis version and exported results should be frozen. *(Final accepted result’lar generated edildikten sonra analysis version ve exported result’lar frozen edilmelidir.)*

---

# 235. Post-Result Parameter Changes (Sonuç Sonrası Parametre Değişiklikleri)

Any estimator parameter change after final result freeze will require a new result version and potentially new benchmark collection. *(Final result freeze sonrasındaki herhangi bir estimator parameter change new result version ve potentially new benchmark collection gerektirecektir.)*

---

# 236. Final Result Revision History (Final Sonuç Revision History)

Material corrections to this page after benchmark completion will be documented. *(Benchmark completion sonrasında bu sayfadaki material correction’lar documented edilecektir.)*

```text id="xvmroi"
Result Revision: TBD
(Result Revision: TBD)

Reason: TBD
(Sebep: TBD)

Affected Metrics: TBD
(Etkilenen Metrikler: TBD)
```

---

# 237. Final Results Executive Summary Placeholder (Final Sonuçlar Executive Summary Placeholder)

The final executive summary will be written only after all primary evidence is available. *(Final executive summary yalnızca tüm primary evidence available olduktan sonra yazılacaktır.)*

```text id="i6kxdc"
FINAL RESULTS EXECUTIVE SUMMARY
(FINAL SONUÇLAR EXECUTIVE SUMMARY)

Status: PENDING FINAL BENCHMARK
(Durum: FINAL BENCHMARK BEKLENİYOR)
```

---

# 238. Primary Research Question Answer Placeholder (Temel Araştırma Sorusu Cevap Placeholder)

```text id="22lfrd"
Research Question:
(Araştırma Sorusu:)

Can AI-assisted pedestrian dead reckoning and visual-inertial
sensor fusion reduce position drift during simulated GNSS outages
on the Xiaomi Redmi Note 9 Pro compared with baseline PDR?
(Yapay zekâ destekli yaya dead reckoning ve visual-inertial
sensor fusion, Xiaomi Redmi Note 9 Pro üzerinde simüle edilen GNSS
kesintileri sırasında baseline PDR'a göre position drift'i azaltabilir mi?)

Final Answer:
(Final Cevap:)

TBD
```

---

# 239. Final Motion AI Answer Placeholder (Final Motion AI Cevap Placeholder)

```text id="qh51qi"
Did Motion Classification meet Macro F1 ≥0.90?
(Motion Classification Macro F1 ≥0.90 hedefini karşıladı mı?)

TBD
```

---

# 240. Final Step Detection Answer Placeholder (Final Step Detection Cevap Placeholder)

```text id="yz9u65"
Did controlled step-count error meet ≤5%?
(Kontrollü step-count error ≤5% hedefini karşıladı mı?)

TBD
```

---

# 241. Final ARCore Answer Placeholder (Final ARCore Cevap Placeholder)

```text id="i36yhj"
Did ARCore provide measurable navigation benefit?
(ARCore measurable navigation benefit sağladı mı?)

TBD
```

---

# 242. Final Learned Step-Length Answer Placeholder (Final Learned Step-Length Cevap Placeholder)

```text id="bckd2r"
Was learned step length retained?
(Learned step length retained edildi mi?)

TBD
```

---

# 243. Final Runtime Answer Placeholder (Final Runtime Cevap Placeholder)

```text id="jiypg5"
Was full NAVGUARD practically sustainable on Redmi Note 9 Pro
for the tested session duration?
(Full NAVGUARD tested session duration boyunca Redmi Note 9 Pro
üzerinde practically sustainable mıydı?)

TBD
```

---

# 244. Final Integrity Answer Placeholder (Final Integrity Cevap Placeholder)

```text id="3zke14"
Was Ground Truth Firewall integrity preserved?
(Ground Truth Firewall integrity korundu mu?)

TBD
```

---

# 245. Final Software Acceptance Placeholder (Final Software Kabul Placeholder)

```text id="71xj9o"
Software Definition of Done:
(Software Definition of Done:)

TBD
```

---

# 246. Final Research Acceptance Placeholder (Final Research Kabul Placeholder)

```text id="581r36"
Research Target:
(Research Target:)

TBD
```

---

# 247. Final Project Outcome Placeholder (Final Proje Outcome Placeholder)

```text id="9j2c1a"
Overall Outcome:
(Genel Outcome:)

TBD
```

---

# 248. Results-to-Limitations Bridge (Sonuçlardan Limitation’lara Geçiş)

The final findings will directly inform the limitation statements in Page 42. *(Final finding’ler Page 42’deki limitation statement’ları doğrudan inform edecektir.)*

---

# 249. Results-to-Change-Log Bridge (Sonuçlardan Change Log’a Geçiş)

Any final implementation decisions revealed by the experiments will be recorded in Page 43. *(Experiment’lerin ortaya çıkardığı herhangi bir final implementation decision Page 43’te recorded edilecektir.)*

---

# 250. Results-to-References Bridge (Sonuçlardan References’a Geçiş)

External technical interpretation that requires citation will be supported through Page 44 references. *(Citation gerektiren external technical interpretation Page 44 references üzerinden supported edilecektir.)*

---

# 251. Result Reporting Non-Goals (Sonuç Raporlama Non-Goal’ları)

This page will not invent success where the benchmark does not support it. *(Bu sayfa benchmark desteklemediği yerde success uydurmayacaktır.)*

---

# 252. Additional Result Reporting Non-Goals (Ek Sonuç Raporlama Non-Goal’ları)

This page will not hide valid poor-performing sessions. *(Bu sayfa valid poor-performing session’ları gizlemeyecektir.)*

This page will not present training metrics as final field performance. *(Bu sayfa training metric’lerini final field performance olarak sunmayacaktır.)*

This page will not use post-correction coordinates as denied-navigation accuracy. *(Bu sayfa post-correction coordinate’ları denied-navigation accuracy olarak kullanmayacaktır.)*

---

# 253. Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kararlar)

All currently unmeasured final results remain `TBD`. *(Şu anda unmeasured olan tüm final result’lar `TBD` olarak kalacaktır.)*

---

# 254. Result Integrity Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Sonuç Bütünlüğü Kararları)

No final navigation metric may be reported before Ground Truth Firewall and session-integrity checks pass. *(Ground Truth Firewall ve session-integrity check’leri pass etmeden hiçbir final navigation metric raporlanamaz.)*

---

# 255. Primary Comparison Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Temel Karşılaştırma Kararları)

Configuration A versus Configuration D remains the primary final research comparison. *(Configuration A versus Configuration D primary final research comparison olarak kalır.)*

---

# 256. Primary Metric Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Primary Metric Kararları)

Aggregated matched-session median horizontal position error remains the primary research metric. *(Aggregated matched-session median horizontal position error primary research metric olarak kalır.)*

---

# 257. Primary Target Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Primary Target Kararları)

The predefined primary target remains at least `20%` reduction for Configuration D relative to Configuration A. *(Predefined primary target Configuration D’nin Configuration A’ya göre en az `20%` reduction sağlaması olarak kalır.)*

---

# 258. Result Category Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Sonuç Kategorisi Kararları)

Final research outcome categories remain `TARGET_MET`, `PARTIAL_IMPROVEMENT`, `NO_MEASURABLE_IMPROVEMENT`, `REGRESSION`, and `INCONCLUSIVE`. *(Final research outcome category’leri `TARGET_MET`, `PARTIAL_IMPROVEMENT`, `NO_MEASURABLE_IMPROVEMENT`, `REGRESSION` ve `INCONCLUSIVE` olarak kalır.)*

---

# 259. Motion AI Result Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Motion AI Sonuç Kararları)

Motion AI will be judged primarily by held-out session-wise Macro F1 and operational navigation effect. *(Motion AI primarily held-out session-wise Macro F1 ve operational navigation effect üzerinden değerlendirilecektir.)*

---

# 260. Step Detection Result Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Step Detection Sonuç Kararları)

Controlled absolute step-count percentage error will remain the primary step-detection performance measure. *(Controlled absolute step-count percentage error primary step-detection performance measure olarak kalır.)*

---

# 261. Learned Step-Length Result Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Learned Step-Length Sonuç Kararları)

Learned step length will only be retained if held-out evidence demonstrates measurable benefit over deterministic baselines. *(Learned step length yalnızca held-out evidence deterministic baseline’lara göre measurable benefit gösterirse retained edilecektir.)*

---

# 262. ARCore Result Decisions Frozen by This Document (Bu Dokümanla Sabitlenen ARCore Sonuç Kararları)

ARCore tracking availability alone will not be treated as proof of navigation benefit. *(ARCore tracking availability tek başına navigation benefit proof’u olarak kabul edilmeyecektir.)*

---

# 263. Recovery Result Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Recovery Sonuç Kararları)

Recovery error will always be measured before correction. *(Recovery error her zaman correction öncesinde measured edilecektir.)*

---

# 264. Performance Result Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Performans Sonuç Kararları)

Runtime, battery, thermal, and storage results will be reported separately from navigation accuracy. *(Runtime, battery, thermal ve storage result’ları navigation accuracy’den ayrı raporlanacaktır.)*

---

# 265. Failure Result Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Failure Sonuç Kararları)

Failure-injection results will remain part of the final experimental findings rather than being hidden as development-only events. *(Failure-injection result’ları development-only event olarak gizlenmek yerine final experimental finding’lerin parçası olarak kalacaktır.)*

---

# 266. Negative Result Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Negative Result Kararları)

A valid negative result will be preserved and reported honestly. *(Valid negative result preserved edilecek ve dürüstçe raporlanacaktır.)*

---

# 267. Final Results Statement (Nihai Sonuçlar Bildirimi)

**Page 41 will serve as the authoritative experimental-results layer of NAVGUARD and will remain intentionally incomplete until the frozen benchmark has generated real physical-device evidence.** *(Page 41 NAVGUARD’ın authoritative experimental-results layer’ı olarak görev yapacak ve frozen benchmark gerçek physical-device evidence üretmeden intentional olarak incomplete kalacaktır.)*

**Every navigation, AI, ARCore, step-detection, recovery, uncertainty, performance, battery, thermal, and fallback result will be connected to an identifiable build, session, model, configuration, and analysis version before it is accepted as a final finding.** *(Her navigation, AI, ARCore, step-detection, recovery, uncertainty, performance, battery, thermal ve fallback result final finding olarak accepted edilmeden önce identifiable build, session, model, configuration ve analysis version ile bağlantılı olacaktır.)*

**The principal experimental comparison will remain Configuration A versus Configuration D on matched final sessions, using aggregated median horizontal position error as the primary metric and the predefined `≥20%` reduction as the primary research target.** *(Principal experimental comparison matched final session’larda Configuration A versus Configuration D olarak kalacak, primary metric olarak aggregated median horizontal position error ve primary research target olarak predefined `≥20%` reduction kullanılacaktır.)*

**Configurations B and C will provide ablation evidence for improved heading and ARCore, while Motion Classification, step detection, step length, recovery, uncertainty, and runtime performance will each be evaluated independently so no single aggregate score hides subsystem behavior.** *(Configuration B ve C improved heading ve ARCore için ablation evidence sağlayacak; Motion Classification, step detection, step length, recovery, uncertainty ve runtime performance ise her biri independently evaluate edilecek ve hiçbir single aggregate score subsystem behavior’ı gizlemeyecektir.)*

**A final positive research claim will only be made when the measured evidence supports it, while partial improvement, no measurable improvement, regression, or inconclusive findings will be reported with equal integrity when those outcomes are observed.** *(Final positive research claim yalnızca measured evidence desteklediğinde yapılacak; partial improvement, no measurable improvement, regression veya inconclusive finding’ler gözlendiğinde aynı integrity ile raporlanacaktır.)*

**The project will therefore distinguish successful software implementation from successful research outcome, allowing NAVGUARD to remain a technically complete and scientifically valid prototype even if one or more predefined performance targets are not achieved.** *(Bu nedenle proje successful software implementation ile successful research outcome’ı ayıracak; NAVGUARD bir veya daha fazla predefined performance target achieve edilmese bile technically complete ve scientifically valid prototype olarak kalabilecektir.)*

---

# 268. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Final Results Framework Completed — Experimental Values Pending *(Doküman Durumu: Final Sonuçlar Framework’ü Tamamlandı — Deneysel Değerler Bekleniyor)*

**Final Physical Benchmark Completed:** No *(Final Fiziksel Benchmark Tamamlandı mı: Hayır)*

**Measured Navigation Results Available:** No *(Measured Navigation Result Mevcut mu: Hayır)*

**Measured AI Results Available:** No *(Measured AI Result Mevcut mu: Hayır)*

**Measured ARCore Results Available:** No *(Measured ARCore Result Mevcut mu: Hayır)*

**Measured Performance Results Available:** No *(Measured Performance Result Mevcut mu: Hayır)*

**Fabricated Values Allowed:** No *(Uydurulmuş Değerler İzinli mi: Hayır)*

**Current Numerical Fields:** `TBD` *(Mevcut Sayısal Alanlar: `TBD`)*

**Primary Final Comparison:** Configuration A vs Configuration D *(Primary Final Comparison: Configuration A vs Configuration D)*

**Primary Metric:** Aggregated Matched-Session Median Horizontal Position Error *(Primary Metric: Aggregated Matched-Session Median Horizontal Position Error)*

**Primary Research Target:** `≥20%` Error Reduction *(Primary Research Target: `≥20%` Hata Azalması)*

**Primary Outcome Categories:** `TARGET_MET / PARTIAL_IMPROVEMENT / NO_MEASURABLE_IMPROVEMENT / REGRESSION / INCONCLUSIVE` *(Primary Outcome Categories: `TARGET_MET / PARTIAL_IMPROVEMENT / NO_MEASURABLE_IMPROVEMENT / REGRESSION / INCONCLUSIVE`)*

**Final Error Timing:** Pre-Correction *(Final Error Timing: Pre-Correction)*

**Post-Correction Accuracy Use:** Forbidden *(Post-Correction Accuracy Kullanımı: Yasak)*

**Ground Truth Firewall Result Required:** `unauthorizedGnssEstimatorUpdateCount = 0` *(Ground Truth Firewall Gerekli Sonucu: `unauthorizedGnssEstimatorUpdateCount = 0`)*

**Valid Poor Sessions:** Retained *(Valid Poor Session’lar: Korunur)*

**Result-Based Exclusion:** Forbidden *(Result-Based Exclusion: Yasak)*

**Motion AI Primary Metric:** Held-Out Session-Wise Macro F1 *(Motion AI Primary Metric: Held-Out Session-Wise Macro F1)*

**Motion AI Target:** `≥0.90` *(Motion AI Hedefi: `≥0.90`)*

**Step Detection Target:** Controlled Absolute Percentage Error `≤5%` *(Step Detection Hedefi: Controlled Absolute Percentage Error `≤5%`)*

**AI Runtime Target:** Approximately `<50 ms`, Final Statistic Pending Freeze *(AI Runtime Hedefi: Yaklaşık `<50 ms`, Final Statistic Freeze Bekliyor)*

**Learned Step Length:** Evidence-Gated *(Learned Step Length: Evidence-Gated)*

**ARCore Benefit:** Must Be Demonstrated, Not Assumed *(ARCore Benefit: Demonstrate Edilmeli, Assumed Edilmemeli)*

**Independent PDR Comparison:** Mandatory *(Independent PDR Comparison: Zorunlu)*

**Recovery Error:** Pre-Correction Only *(Recovery Error: Yalnızca Pre-Correction)*

**Uncertainty:** Reported Separately from Observed Error *(Uncertainty: Observed Error’dan Ayrı Raporlanır)*

**Performance Metrics:** CPU + Memory + AI Latency + Logging + Storage + Battery + Thermal *(Performance Metrics: CPU + Memory + AI Latency + Logging + Storage + Battery + Thermal)*

**Failure Injection Findings:** Included in Final Results *(Failure Injection Findings: Final Results İçerisinde)*

**Final Result Figures:** Planned, `TBD` Until Evidence Exists *(Final Result Figure’ları: Planlandı, Evidence Oluşana Kadar `TBD`)*

**Final Result Tables:** Planned, `TBD` Until Evidence Exists *(Final Result Table’ları: Planlandı, Evidence Oluşana Kadar `TBD`)*

**Software Completion and Research Success:** Separate Outcomes *(Software Completion ve Research Success: Ayrı Outcome’lar)*

**Negative Research Result:** Valid if Evidence Is Valid *(Negative Research Result: Evidence Valid ise Geçerli)*

**Next Documentation Item:** 42 — Limitations & Future Work *(Sonraki Dokümantasyon Öğesi: 42 — Sınırlamalar ve Gelecek Çalışmalar)*
