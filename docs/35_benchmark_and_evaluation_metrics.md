# 35 — Benchmark & Evaluation Metrics (Benchmark ve Değerlendirme Metrikleri)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the mathematical metrics, aggregation rules, comparison logic, benchmark reporting conventions, uncertainty-evaluation methods, recovery metrics, AI metrics, PDR metrics, ARCore metrics, performance metrics, and statistical summaries used to evaluate NAVGUARD. *(Bu doküman NAVGUARD'ı değerlendirmek için kullanılacak matematiksel metrikleri, aggregation kurallarını, karşılaştırma mantığını, benchmark raporlama kurallarını, belirsizlik değerlendirme yöntemlerini, recovery metriklerini, AI metriklerini, PDR metriklerini, ARCore metriklerini, performans metriklerini ve istatistiksel özetleri tanımlar.)*

The objective is to ensure that every reported NAVGUARD result is calculated consistently from traceable evidence rather than selected ad-hoc measurements. *(Amaç raporlanan her NAVGUARD sonucunun seçilmiş ad-hoc ölçümler yerine izlenebilir kanıttan tutarlı şekilde hesaplanmasını sağlamaktır.)*

---

# 2. Evaluation Philosophy (Değerlendirme Felsefesi)

NAVGUARD will use multiple complementary metrics rather than relying on one headline number. *(NAVGUARD tek headline number'a dayanmak yerine birbirini tamamlayan birden fazla metrik kullanacaktır.)*

Median error, mean error, RMSE, P95 error, final error, drift rate, recovery error, and system availability describe different aspects of navigation behavior. *(Median error, mean error, RMSE, P95 error, final error, drift rate, recovery error ve sistem availability navigasyon davranışının farklı yönlerini açıklar.)*

---

# 3. Primary Research Comparison (Temel Araştırma Karşılaştırması)

The primary research comparison will evaluate full NAVGUARD against the reproducible PDR-only baseline on matched final sessions. *(Temel araştırma karşılaştırması tam NAVGUARD'ı eşleşmiş final oturumlarında tekrarlanabilir PDR-only baseline'a karşı değerlendirecektir.)*

---

# 4. Formal Configurations (Resmî Yapılandırmalar)

```text
A — PDR Only
(A — Yalnızca PDR)

B — PDR + Improved / Fused Heading
(B — PDR + Geliştirilmiş / Füzyonlu Yön)

C — PDR + ARCore
(C — PDR + ARCore)

D — Full NAVGUARD AI-Assisted Fusion
(D — Tam NAVGUARD Yapay Zekâ Destekli Füzyon)
```

---

# 5. Primary Baseline (Temel Baseline)

Configuration A is the primary navigation baseline. *(Configuration A temel navigasyon baseline'ıdır.)*

---

# 6. Primary Full System (Temel Tam Sistem)

Configuration D is the primary full-system candidate. *(Configuration D temel full-system adaydır.)*

---

# 7. Ablation Role of B and C (B ve C'nin Ablation Rolü)

Configuration B estimates the value of improved heading handling. *(Configuration B geliştirilmiş heading yönetiminin değerini tahmin eder.)*

Configuration C estimates the value of validated ARCore relative tracking by adding it to Configuration A while preserving Configuration A's baseline heading, deterministic step detector, and baseline step-length policy. *(Configuration C, Configuration A'nın baseline heading, deterministic step detector ve baseline step-length policy'sini korurken validated ARCore relative tracking'i Configuration A'ya ekleyerek katkısını ölçer.)*

---

# 8. Matched Evidence Principle (Eşleşmiş Kanıt İlkesi)

Whenever possible, configurations A through D will be evaluated using the same physical raw session through replay. *(Mümkün olduğunda Configuration A-D aynı fiziksel ham oturum üzerinden replay kullanılarak değerlendirilecektir.)*

---

# 9. Why Matched Evaluation Matters (Eşleşmiş Değerlendirme Neden Önemlidir)

Using identical evidence reduces the confounding effect of different walking trajectories, different phone motions, different GNSS conditions, and different ARCore observations. *(Aynı kanıtı kullanmak farklı yürüyüş trajectory'lerinin, farklı telefon hareketlerinin, farklı GNSS koşullarının ve farklı ARCore gözlemlerinin confounding etkisini azaltır.)*

---

# 10. Evaluation Timeline (Değerlendirme Zaman Çizgisi)

Formal GNSS-denied position metrics will be calculated over the declared denied interval. *(Resmî GNSS kesintili konum metrikleri tanımlanmış kesintili aralık üzerinde hesaplanacaktır.)*

---

# 11. Denied Interval Definition (Kesintili Aralık Tanımı)

Let the denied interval start at time `t_d` and end at the pre-correction recovery evaluation time `t_r`. *(Kesintili aralık `t_d` zamanında başlasın ve düzeltme öncesi recovery değerlendirme zamanı `t_r` anında sona ersin.)*

```text
Denied interval = [t_d, t_r]
(Kesintili aralık = [t_d, t_r])
```

---

# 12. No Post-Correction Samples in Denied Error Metrics (Kesintili Hata Metriklerinde Post-Correction Örneği Olmaması)

Samples after relocalization will not be mixed into pre-recovery denied-navigation error metrics. *(Relocalization sonrasındaki örnekler pre-recovery kesintili navigasyon hata metriklerine karıştırılmayacaktır.)*

---

# 13. Evaluation Coordinate Frame (Değerlendirme Koordinat Frame'i)

Primary positional error will be calculated in the common local ENU frame associated with the original anchor. *(Temel positional error orijinal anchor ile ilişkili ortak yerel ENU frame içerisinde hesaplanacaktır.)*

---

# 14. Why ENU Is Preferred for Error Calculation (Hata Hesabı İçin ENU Neden Tercih Edilir)

ENU expresses horizontal errors directly in metres and avoids repeatedly interpreting small latitude-longitude differences. *(ENU yatay hataları doğrudan metre cinsinden ifade eder ve küçük latitude-longitude farklarının tekrar tekrar yorumlanmasını önler.)*

---

# 15. Estimated Position (Tahmini Konum)

At evaluation time `t_i`, the estimated horizontal position is defined as follows. *(Değerlendirme zamanı `t_i` için tahmini yatay konum aşağıdaki gibi tanımlanır.)*

```text
p̂_i =
[Ê_i, N̂_i]ᵀ
```

---

# 16. Reference Position (Referans Konum)

At the same aligned time, the reference horizontal position is defined as follows. *(Aynı hizalanmış zamanda referans yatay konum aşağıdaki gibi tanımlanır.)*

```text
p_i^ref =
[E_i^ref, N_i^ref]ᵀ
```

---

# 17. East Error (East Hatası)

```text
e_E,i = Ê_i - E_i^ref
```

Positive East error means the estimate lies east of the reference position. *(Pozitif East error tahminin referans konumun doğusunda olduğunu gösterir.)*

---

# 18. North Error (North Hatası)

```text
e_N,i = N̂_i - N_i^ref
```

Positive North error means the estimate lies north of the reference position. *(Pozitif North error tahminin referans konumun kuzeyinde olduğunu gösterir.)*

---

# 19. Horizontal Position Error (Yatay Konum Hatası)

The primary instantaneous horizontal position error is Euclidean distance in the ENU plane. *(Temel anlık yatay konum hatası ENU düzlemindeki Euclidean distance'dır.)*

```text
e_i =
sqrt(
  e_E,i² +
  e_N,i²
)
```

---

# 20. Units (Birimler)

Horizontal position error will be reported in metres. *(Yatay konum hatası metre cinsinden raporlanacaktır.)*

---

# 21. Reference Alignment Requirement (Referans Hizalama Gereksinimi)

An estimated point will only be scored against a reference point when the timing alignment satisfies the frozen benchmark alignment policy. *(Tahmini nokta yalnızca zaman hizalaması sabitlenmiş benchmark alignment politikasını karşıladığında referans noktaya karşı skorlanacaktır.)*

---

# 22. No Arbitrary Nearest-Point Matching (Keyfi En Yakın Nokta Eşlemesi Olmaması)

The evaluator will not blindly match each estimator point to whichever ground-truth point minimizes spatial error. *(Evaluator her estimator noktasını spatial error'ı minimize eden herhangi bir ground-truth noktaya kör şekilde eşlemeyecektir.)*

That would artificially improve the measured result. *(Bu ölçülen sonucu yapay şekilde iyileştirir.)*

---

# 23. Time Alignment Is Primary (Zaman Hizalama Temeldir)

Position estimates will be compared with the reference at corresponding experiment times rather than spatially nearest locations. *(Konum tahminleri spatially nearest location'lar yerine karşılık gelen deney zamanlarındaki referansla karşılaştırılacaktır.)*

---

# 24. Alignment Interpolation (Hizalama Interpolation'ı)

Bounded interpolation of reference position may be used when the timestamp gap is sufficiently small and the interpolation rule has been frozen before final evaluation. *(Timestamp gap yeterince küçükse ve interpolation kuralı final değerlendirme öncesinde sabitlenmişse referans konumda sınırlı interpolation kullanılabilir.)*

---

# 25. Large Reference Gaps (Büyük Referans Boşlukları)

Large ground-truth gaps will not be silently filled and scored as if measured reference existed continuously. *(Büyük ground-truth boşlukları sessizce doldurulup sürekli measured reference varmış gibi skorlanmayacaktır.)*

---

# 26. Valid Evaluation Sample Set (Geçerli Değerlendirme Sample Seti)

Let `V` denote the set of evaluation timestamps where both estimator and valid aligned reference are available. *(`V`, hem estimator hem geçerli hizalanmış referansın kullanılabilir olduğu evaluation timestamp setini göstersin.)*

```text
V = {i | estimator valid ∧ reference valid ∧ alignment valid}
```

---

# 27. Number of Valid Samples (Geçerli Sample Sayısı)

```text
n = |V|
```

---

# 28. Mean Position Error (Ortalama Konum Hatası)

Mean position error is defined as follows. *(Ortalama konum hatası aşağıdaki gibi tanımlanır.)*

```text
Mean Error =
(1 / n) Σ e_i
```

---

# 29. Interpretation of Mean Error (Mean Error Yorumu)

Mean error summarizes average instantaneous horizontal error over the evaluated interval. *(Mean error değerlendirilen aralık boyunca ortalama anlık yatay hatayı özetler.)*

---

# 30. Median Position Error (Medyan Konum Hatası)

Median position error is the median of all valid instantaneous horizontal errors. *(Median position error tüm geçerli anlık yatay hataların medyanıdır.)*

```text
Median Error =
median(e_i)
```

---

# 31. Why Median Is Important (Median Neden Önemlidir)

Median error is less affected by a small number of extreme error spikes than mean error. *(Median error az sayıdaki extreme error spike'tan mean error'a göre daha az etkilenir.)*

---

# 32. Primary NAVGUARD Research Metric (Temel NAVGUARD Araştırma Metriği)

The single project-level primary research metric is aggregated matched-session median horizontal position error for Configuration D versus Configuration A. *(Tek project-level primary research metric Configuration D ile Configuration A için aggregated matched-session median horizontal position error'dır.)*

Mean error, RMSE, P95 error, final pre-correction error, drift per time, and drift per distance remain required secondary or diagnostic position metrics. *(Mean error, RMSE, P95 error, final pre-correction error, drift per time ve drift per distance gerekli secondary veya diagnostic position metric'leri olarak kalır.)*

---

# 33. Root Mean Square Error (Kök Ortalama Kare Hata)

RMSE is defined as follows. *(RMSE aşağıdaki gibi tanımlanır.)*

```text
RMSE =
sqrt(
  (1 / n) Σ e_i²
)
```

---

# 34. RMSE Interpretation (RMSE Yorumu)

RMSE penalizes larger errors more strongly than mean absolute horizontal error. *(RMSE büyük hataları mean absolute horizontal error'a göre daha güçlü cezalandırır.)*

---

# 35. Maximum Position Error (Maksimum Konum Hatası)

Maximum observed error may be reported as a diagnostic metric. *(Maksimum gözlemlenen hata diagnostic metrik olarak raporlanabilir.)*

```text
Max Error = max(e_i)
```

---

# 36. Maximum Error Is Not a Stable Primary Metric (Maximum Error Kararlı Temel Metrik Değildir)

Maximum error is highly sensitive to a single outlier and therefore will not be the primary success metric. *(Maximum error tek outlier'a çok hassastır ve bu nedenle temel başarı metriği olmayacaktır.)*

---

# 37. P95 Position Error (P95 Konum Hatası)

The 95th percentile of instantaneous position error will be reported. *(Anlık konum hatasının 95. percentile değeri raporlanacaktır.)*

```text
P95 Error =
percentile_95(e_i)
```

---

# 38. P95 Interpretation (P95 Yorumu)

P95 describes high-error behavior without depending entirely on the single worst sample. *(P95 tek en kötü sample'a tamamen bağlı olmadan high-error behavior'ı açıklar.)*

---

# 39. P50 Position Error (P50 Konum Hatası)

P50 is equivalent to the median. *(P50 median ile eşdeğerdir.)*

```text
P50 = Median Error
```

---

# 40. Additional Percentiles (Ek Percentile'lar)

P25, P75, or P90 may be reported for detailed analysis if useful. *(P25, P75 veya P90 kullanışlı olduğunda ayrıntılı analiz için raporlanabilir.)*

They will remain secondary metrics. *(İkincil metrik olarak kalacaktır.)*

---

# 41. Final Position Error (Nihai Konum Hatası)

Final position error is the horizontal estimator error immediately before controlled recovery correction. *(Final position error kontrollü recovery correction'dan hemen önceki yatay estimator hatasıdır.)*

```text
e_final =
sqrt(
  (Ê_r^- - E_r^ref)² +
  (N̂_r^- - N_r^ref)²
)
```

---

# 42. Superscript Minus in Final Error (Final Error İçerisinde Minus Üst Simgesi)

The minus sign denotes the pre-correction estimator state. *(Minus işareti düzeltme öncesi estimator state'i ifade eder.)*

---

# 43. No Corrected Final Error as Denied Drift Metric (Kesintili Drift Metriği Olarak Düzeltilmiş Final Error Olmaması)

The post-relocalization near-zero error will not be reported as the final denied-navigation error. *(Post-relocalization near-zero error final kesintili navigasyon hatası olarak raporlanmayacaktır.)*

---

# 44. East Final Error (East Final Hatası)

```text
e_E,final =
Ê_r^- - E_r^ref
```

---

# 45. North Final Error (North Final Hatası)

```text
e_N,final =
N̂_r^- - N_r^ref
```

---

# 46. Directional Error Reporting (Yönlü Hata Raporlama)

East and North final error components may be reported alongside horizontal magnitude. *(East ve North final error component'ları yatay magnitude ile birlikte raporlanabilir.)*

---

# 47. Denied Duration (Kesintili Süre)

```text
T_denied =
t_r - t_d
```

Denied duration will normally be reported in seconds and minutes. *(Kesintili süre normalde saniye ve dakika cinsinden raporlanacaktır.)*

---

# 48. Drift per Minute (Dakika Başına Drift)

A simple normalized endpoint drift rate may be reported as follows. *(Basit normalize endpoint drift rate aşağıdaki gibi raporlanabilir.)*

```text
DriftPerMinute =
e_final /
(T_denied / 60)
```

---

# 49. Drift per Minute Units (Dakika Başına Drift Birimleri)

The unit is metres per minute. *(Birim metre/dakikadır.)*

---

# 50. Drift Rate Is a Summary, Not a Physical Velocity (Drift Rate Fiziksel Hız Değildir)

Drift per minute is a normalized error-growth summary and is not the physical velocity of the estimation error. *(Drift per minute normalize error-growth summary'dir ve estimation error'ın fiziksel velocity'si değildir.)*

---

# 51. Reference Travel Distance (Referans Kat Edilen Mesafe)

Let the reference horizontal travel distance across the denied interval be defined as follows. *(Kesintili aralık üzerindeki referans yatay travel distance aşağıdaki gibi tanımlansın.)*

```text
D_ref =
Σ ||p_i^ref - p_(i-1)^ref||
```

---

# 52. Reference Distance Requires Valid Sampling (Referans Mesafe Geçerli Sampling Gerektirir)

Reference path distance will only be calculated from sufficiently valid and temporally consistent reference data. *(Referans path distance yalnızca yeterince geçerli ve temporal olarak tutarlı referans veriden hesaplanacaktır.)*

---

# 53. Drift per Distance (Mesafe Başına Drift)

```text
DriftPerDistance =
e_final /
D_ref
```

---

# 54. Percentage Drift per Distance (Mesafe Başına Yüzde Drift)

The ratio may also be expressed as a percentage. *(Oran yüzde olarak da ifade edilebilir.)*

```text
DriftPercent =
100 × e_final / D_ref
```

---

# 55. Drift per Distance Interpretation (Mesafe Başına Drift Yorumu)

This metric helps compare sessions of different route lengths. *(Bu metrik farklı rota uzunluklarındaki oturumları karşılaştırmaya yardımcı olur.)*

---

# 56. Path Length Estimate (Path Uzunluğu Tahmini)

The estimator's accumulated path length during denial is defined as follows. *(Estimator'ın kesinti sırasındaki accumulated path length değeri aşağıdaki gibi tanımlanır.)*

```text
D̂ =
Σ L̂_k
```

for accepted steps during the interval. *(Bu toplam aralık içerisindeki kabul edilmiş adımlar için hesaplanır.)*

---

# 57. Distance Error (Mesafe Hatası)

```text
e_D =
D̂ - D_ref
```

---

# 58. Absolute Distance Error (Mutlak Mesafe Hatası)

```text
|e_D| =
|D̂ - D_ref|
```

---

# 59. Relative Distance Error (Göreli Mesafe Hatası)

```text
RelativeDistanceError =
|D̂ - D_ref| /
D_ref
```

---

# 60. Percentage Distance Error (Yüzde Mesafe Hatası)

```text
DistanceErrorPercent =
100 ×
|D̂ - D_ref| /
D_ref
```

---

# 61. Signed Distance Bias (İmzalı Mesafe Bias'ı)

The signed distance error will also be retained because systematic overestimation and underestimation are different failure modes. *(Signed distance error da korunacaktır çünkü sistematik overestimation ve underestimation farklı failure mode'lardır.)*

---

# 62. Positive Distance Bias (Pozitif Mesafe Bias'ı)

Positive `e_D` means estimated travel distance is larger than reference distance. *(Pozitif `e_D`, tahmini travel distance'ın referans mesafeden büyük olduğunu gösterir.)*

---

# 63. Negative Distance Bias (Negatif Mesafe Bias'ı)

Negative `e_D` means estimated travel distance is smaller than reference distance. *(Negatif `e_D`, tahmini travel distance'ın referans mesafeden küçük olduğunu gösterir.)*

---

# 64. Closure Error (Closure Error)

For a closed route, closure error is the distance between the estimator's final position and the declared starting location. *(Kapalı rota için closure error estimator'ın final konumu ile tanımlanmış başlangıç konumu arasındaki mesafedir.)*

```text
e_closure =
sqrt(
  (Ê_end - E_start)² +
  (N̂_end - N_start)²
)
```

---

# 65. Closure Error Is Not Always Ground Truth Position Error (Closure Error Her Zaman Ground Truth Konum Hatası Değildir)

Closure error can be calculated even when continuous precise ground truth is unavailable. *(Closure error continuous precise ground truth kullanılamadığında bile hesaplanabilir.)*

---

# 66. Closure Error Percentage (Closure Error Yüzdesi)

A normalized closure error may be reported as follows. *(Normalize closure error aşağıdaki gibi raporlanabilir.)*

```text
ClosureErrorPercent =
100 ×
e_closure /
D_ref
```

---

# 67. Cross-Track Error Candidate (Cross-Track Error Adayı)

For a known straight reference segment, lateral deviation from the reference line may be evaluated as a secondary heading-drift metric. *(Bilinen düz referans segmenti için referans çizgiden lateral deviation ikincil heading-drift metriği olarak değerlendirilebilir.)*

---

# 68. Along-Track Error Candidate (Along-Track Error Adayı)

For a known straight segment, error parallel to the intended route may be evaluated as an accumulated-distance metric. *(Bilinen düz segment için amaçlanan rotaya paralel hata accumulated-distance metriği olarak değerlendirilebilir.)*

---

# 69. Cross-Track Metrics Are Route-Specific (Cross-Track Metrikleri Rotaya Özgüdür)

Cross-track and along-track decomposition will only be used when route geometry is sufficiently well defined. *(Cross-track ve along-track decomposition yalnızca rota geometrisi yeterince iyi tanımlandığında kullanılacaktır.)*

---

# 70. Heading Error Definition (Heading Hata Tanımı)

Heading error must use circular angular difference. *(Heading error circular angular difference kullanmalıdır.)*

```text
Δψ_i =
atan2(
  sin(ψ̂_i - ψ_i^ref),
  cos(ψ̂_i - ψ_i^ref)
)
```

---

# 71. Absolute Heading Error (Mutlak Heading Hatası)

```text
e_ψ,i =
|Δψ_i|
```

---

# 72. Heading Units (Heading Birimleri)

Internal calculations use radians. *(Dahili hesaplamalar radian kullanır.)*

Human-readable reporting may also show degrees. *(İnsan tarafından okunabilir raporlama derece de gösterebilir.)*

---

# 73. Heading MAE (Heading MAE)

```text
HeadingMAE =
(1 / n_ψ) Σ e_ψ,i
```

---

# 74. Heading RMSE (Heading RMSE)

```text
HeadingRMSE =
sqrt(
  (1 / n_ψ) Σ Δψ_i²
)
```

---

# 75. Heading Bias (Heading Bias)

Circular mean signed heading error may be reported when a meaningful reference exists. *(Anlamlı referans mevcut olduğunda circular mean signed heading error raporlanabilir.)*

---

# 76. Heading Reference Must Be Defensible (Heading Referansı Savunulabilir Olmalıdır)

NAVGUARD will not calculate formal heading MAE from an unreliable proxy and present it as exact orientation ground truth. *(NAVGUARD güvenilmez proxy'den formal heading MAE hesaplayıp exact orientation ground truth olarak sunmayacaktır.)*

---

# 77. Step Count Reference (Adım Sayısı Referansı)

Controlled step-count experiments will use manually verified reference steps or another defensible reference method. *(Kontrollü step-count deneyleri manually verified reference steps veya başka savunulabilir referans yöntemi kullanacaktır.)*

---

# 78. Detected Step Count (Tespit Edilen Adım Sayısı)

```text
N̂_step =
number of accepted NAVGUARD StepEvents
```

---

# 79. Reference Step Count (Referans Adım Sayısı)

```text
N_step^ref =
verified physical step count
```

---

# 80. Step Count Signed Error (Adım Sayısı İmzalı Hata)

```text
e_step =
N̂_step -
N_step^ref
```

---

# 81. Step Count Absolute Error (Adım Sayısı Mutlak Hata)

```text
|e_step| =
|N̂_step - N_step^ref|
```

---

# 82. Step Count Percentage Error (Adım Sayısı Yüzde Hata)

```text
StepCountErrorPercent =
100 ×
|N̂_step - N_step^ref| /
N_step^ref
```

---

# 83. Step Count Target (Adım Sayısı Hedefi)

The provisional controlled step-count target remains absolute percentage error at or below 5%. *(Geçici kontrollü step-count hedefi absolute percentage error'ın %5 veya altında olmasıdır.)*

---

# 84. False Positive Step Count (False Positive Adım Sayısı)

Where step-level annotation exists, false positive step events may be counted. *(Step-level annotation mevcut olduğunda false positive step event'leri sayılabilir.)*

---

# 85. Missed Step Count (Kaçırılan Adım Sayısı)

Where step-level annotation exists, missed physical steps may be counted. *(Step-level annotation mevcut olduğunda kaçırılan fiziksel adımlar sayılabilir.)*

---

# 86. Step Precision Candidate (Step Precision Adayı)

```text
StepPrecision =
TP_step /
(TP_step + FP_step)
```

---

# 87. Step Recall Candidate (Step Recall Adayı)

```text
StepRecall =
TP_step /
(TP_step + FN_step)
```

---

# 88. Step F1 Candidate (Step F1 Adayı)

```text
StepF1 =
2 ×
StepPrecision × StepRecall /
(StepPrecision + StepRecall)
```

---

# 89. Step Event Matching Tolerance (Step Event Eşleme Toleransı)

A time tolerance will be required to match detected and reference steps in step-level evaluation. *(Step-level evaluation içerisinde detected ve reference step'leri eşlemek için zaman toleransı gerekecektir.)*

The exact tolerance remains pending annotation protocol validation. *(Kesin tolerans annotation protocol validation'ı beklemektedir.)*

---

# 90. Step Length Ground Truth Challenge (Adım Uzunluğu Ground Truth Zorluğu)

Exact per-step physical length is difficult to obtain using only the target smartphone. *(Yalnızca hedef smartphone kullanarak exact per-step fiziksel uzunluğu elde etmek zordur.)*

---

# 91. Step Length Evaluation Levels (Adım Uzunluğu Değerlendirme Seviyeleri)

Step-length evaluation will distinguish per-step, segment-average, and route-average references. *(Step-length evaluation per-step, segment-average ve route-average referansları ayıracaktır.)*

---

# 92. Per-Step MAE (Adım Başına MAE)

If defensible per-step reference labels exist, per-step MAE may be calculated. *(Savunulabilir per-step reference label'lar mevcutsa per-step MAE hesaplanabilir.)*

```text
StepLengthMAE =
(1 / K) Σ |L̂_k - L_k^ref|
```

---

# 93. Per-Step RMSE (Adım Başına RMSE)

```text
StepLengthRMSE =
sqrt(
  (1 / K) Σ (L̂_k - L_k^ref)²
)
```

---

# 94. Step Length Bias (Adım Uzunluğu Bias'ı)

```text
StepLengthBias =
(1 / K) Σ (L̂_k - L_k^ref)
```

---

# 95. Segment-Level Step Length Error (Segment Seviyesi Adım Uzunluğu Hatası)

When only segment-level reference is defensible, model quality will be evaluated using accumulated segment distance rather than pretending exact per-step truth exists. *(Yalnızca segment-level referans savunulabilir olduğunda model kalitesi exact per-step truth varmış gibi davranmak yerine accumulated segment distance üzerinden değerlendirilecektir.)*

---

# 96. Baseline Step Length Models (Baseline Adım Uzunluğu Modelleri)

Formal comparison will include calibrated fixed step length and deterministic variable step length where implemented. *(Resmî karşılaştırma uygulandığında calibrated fixed step length ve deterministic variable step length'i içerecektir.)*

---

# 97. Learned Step Length Retention Rule (Öğrenilmiş Adım Uzunluğu Koruma Kuralı)

A learned step-length model will only remain navigation-enabled if it measurably improves held-out results over deterministic baselines. *(Learned step-length model yalnızca deterministic baseline'lar üzerinde held-out sonuçları ölçülebilir şekilde iyileştirirse navigation-enabled kalacaktır.)*

---

# 98. No Artificial Step-Length Win Threshold Yet (Henüz Yapay Step-Length Kazanç Eşiği Yoktur)

No fixed improvement percentage will be invented before development evidence exists. *(Development evidence mevcut olmadan sabit improvement percentage uydurulmayacaktır.)*

---

# 99. Motion Classification Evaluation (Hareket Sınıflandırma Değerlendirmesi)

Motion Classification uses four trained classes. *(Motion Classification dört trained class kullanır.)*

```text
STATIONARY
WALKING
RUNNING
TURNING
```

---

# 100. Confusion Matrix (Confusion Matrix)

A four-by-four confusion matrix will be reported on the held-out session-wise test set. *(Held-out session-wise test set üzerinde dört-dörde confusion matrix raporlanacaktır.)*

---

# 101. Per-Class Precision (Sınıf Başına Precision)

For class `c`, precision is defined as follows. *(Sınıf `c` için precision aşağıdaki gibi tanımlanır.)*

```text
Precision_c =
TP_c /
(TP_c + FP_c)
```

---

# 102. Per-Class Recall (Sınıf Başına Recall)

```text
Recall_c =
TP_c /
(TP_c + FN_c)
```

---

# 103. Per-Class F1 (Sınıf Başına F1)

```text
F1_c =
2 ×
Precision_c × Recall_c /
(Precision_c + Recall_c)
```

---

# 104. Macro F1 (Macro F1)

Macro F1 is defined as the unweighted average of class F1 scores. *(Macro F1 class F1 score'larının eşit ağırlıklı ortalaması olarak tanımlanır.)*

```text
MacroF1 =
(1 / C) Σ F1_c
```

---

# 105. Motion Classification Target (Hareket Sınıflandırma Hedefi)

The provisional held-out Macro F1 target remains at least 0.90. *(Geçici held-out Macro F1 hedefi en az 0.90 olarak kalmaktadır.)*

---

# 106. Accuracy (Accuracy)

Overall classification accuracy will also be reported. *(Genel classification accuracy de raporlanacaktır.)*

```text
Accuracy =
CorrectPredictions /
TotalPredictions
```

---

# 107. Accuracy Is Secondary to Macro F1 (Accuracy Macro F1'e Göre İkincildir)

Accuracy will not replace Macro F1 as the primary motion-model metric. *(Accuracy temel motion-model metriği olarak Macro F1'in yerini almayacaktır.)*

---

# 108. Balanced Accuracy Candidate (Balanced Accuracy Adayı)

Balanced accuracy may be reported if class imbalance is material. *(Class imbalance anlamlıysa balanced accuracy raporlanabilir.)*

---

# 109. Transition Detection Metrics (Transition Detection Metrikleri)

Motion-state transition latency may be evaluated separately from window classification accuracy. *(Motion-state transition latency window classification accuracy'den ayrı değerlendirilebilir.)*

---

# 110. Transition Latency (Transition Latency)

For a known transition time `t_ref` and accepted operational transition `t_pred`, transition latency is defined as follows. *(Bilinen transition time `t_ref` ve accepted operational transition `t_pred` için transition latency aşağıdaki gibi tanımlanır.)*

```text
TransitionLatency =
t_pred - t_ref
```

---

# 111. False Transition Count (False Transition Sayısı)

The number of spurious operational motion-state transitions may be reported. *(Spurious operational motion-state transition sayısı raporlanabilir.)*

---

# 112. AI Confidence Calibration Candidate (AI Güven Kalibrasyonu Adayı)

If model confidence calibration is implemented, Expected Calibration Error or reliability plots may be used. *(Model confidence calibration uygulanırsa Expected Calibration Error veya reliability plot'ları kullanılabilir.)*

---

# 113. Raw Softmax Is Not Calibrated Probability (Ham Softmax Kalibre Olasılık Değildir)

Uncalibrated softmax output will not be described as guaranteed probability of correctness. *(Kalibre edilmemiş softmax çıktısı guaranteed probability of correctness olarak tanımlanmayacaktır.)*

---

# 114. AI Inference Latency (AI Inference Latency)

On-device inference latency will be measured from model invocation to model output. *(On-device inference latency model invocation'dan model output'a kadar ölçülecektir.)*

---

# 115. Median AI Latency (Median AI Latency)

Median inference latency will be reported over repeated measurements. *(Median inference latency tekrarlanan measurement'lar üzerinde raporlanacaktır.)*

---

# 116. P95 AI Latency (P95 AI Latency)

P95 inference latency will also be reported to capture slower executions. *(P95 inference latency daha yavaş execution'ları yakalamak için ayrıca raporlanacaktır.)*

---

# 117. AI Latency Target (AI Latency Hedefi)

The provisional target remains below approximately 50 ms per inference on the Redmi Note 9 Pro. *(Geçici hedef Redmi Note 9 Pro üzerinde inference başına yaklaşık 50 ms'nin altında kalmaktadır.)*

---

# 118. End-to-End Motion Context Latency (Uçtan Uca Motion Context Latency)

End-to-end latency from final required sample arrival to accepted operational motion context may be reported separately. *(Son gerekli sample'ın gelişinden accepted operational motion context'e kadar uçtan uca latency ayrı raporlanabilir.)*

---

# 119. Model Runtime Availability (Model Runtime Availability)

The percentage of required inference opportunities that produce valid accepted model outputs may be measured. *(Geçerli accepted model output üreten gerekli inference opportunity yüzdesi ölçülebilir.)*

---

# 120. AI Fallback Count (AI Fallback Sayısı)

The number of inference failures or confidence-gated fallbacks will be retained. *(Inference failure veya confidence-gated fallback sayısı korunacaktır.)*

---

# 121. ARCore Availability Metric (ARCore Availability Metriği)

ARCore availability will be measured over the period in which ARCore is expected to contribute. *(ARCore availability ARCore'un katkı sağlamasının beklendiği dönem üzerinde ölçülecektir.)*

---

# 122. Tracking Availability (Tracking Availability)

```text
ARCoreTrackingAvailability =
T_TRACKING /
T_AR_required
```

---

# 123. ARCore Availability Percentage (ARCore Availability Yüzdesi)

```text
ARCoreAvailabilityPercent =
100 ×
ARCoreTrackingAvailability
```

---

# 124. PAUSED Time (PAUSED Süresi)

Time spent in `PAUSED` will be reported separately where useful. *(`PAUSED` içerisinde geçirilen süre kullanışlı olduğunda ayrı raporlanacaktır.)*

---

# 125. Tracking Loss Count (Tracking Loss Sayısı)

The number of transitions out of valid `TRACKING` may be reported. *(Geçerli `TRACKING` dışına geçiş sayısı raporlanabilir.)*

---

# 126. Mean Tracking Segment Length (Ortalama Tracking Segment Uzunluğu)

Mean duration of continuous valid ARCore tracking segments may be calculated. *(Sürekli geçerli ARCore tracking segmentlerinin mean duration değeri hesaplanabilir.)*

---

# 127. ARCore Relative Drift Candidate (ARCore Relative Drift Adayı)

Controlled known-displacement tests may report ARCore relative displacement error independently of the fused navigation result. *(Kontrollü known-displacement testleri fused navigation result'tan bağımsız olarak ARCore relative displacement error raporlayabilir.)*

---

# 128. ARCore Is Not Evaluated as Absolute GNSS Replacement (ARCore Mutlak GNSS Yerine Geçme Olarak Değerlendirilmez)

ARCore will be scored as a relative-motion source, not as an independent global-position provider. *(ARCore bağımsız global-position provider yerine relative-motion source olarak skorlanacaktır.)*

---

# 129. Recovery Metrics (Recovery Metrikleri)

Recovery evaluation will begin at the explicit recovery request. *(Recovery değerlendirmesi açık recovery request ile başlayacaktır.)*

---

# 130. Recovery Request Time (Recovery Request Zamanı)

```text
t_req
```

---

# 131. Accepted Reference Time (Kabul Edilen Referans Zamanı)

```text
t_accept
```

---

# 132. Relocalization Completion Time (Relocalization Tamamlanma Zamanı)

```text
t_reloc
```

---

# 133. Recovery Validation Latency (Recovery Validation Latency)

```text
T_validation =
t_accept - t_req
```

---

# 134. Relocalization Latency (Relocalization Latency)

```text
T_relocalization =
t_reloc - t_accept
```

---

# 135. Total Recovery Latency (Toplam Recovery Latency)

```text
T_recovery =
t_reloc - t_req
```

---

# 136. Recovery Success Rate (Recovery Başarı Oranı)

If multiple controlled recovery attempts are performed, recovery success rate may be calculated. *(Birden fazla kontrollü recovery attempt gerçekleştirilirse recovery success rate hesaplanabilir.)*

```text
RecoverySuccessRate =
SuccessfulRecoveries /
ValidRecoveryAttempts
```

---

# 137. Recovery Pre-Correction Error (Recovery Düzeltme Öncesi Hatası)

Recovery pre-correction error is the final denied-navigation position error defined earlier. *(Recovery pre-correction error daha önce tanımlanan final denied-navigation position error'dır.)*

---

# 138. Recovery Correction Magnitude (Recovery Correction Magnitude)

The displacement applied during relocalization may be recorded separately. *(Relocalization sırasında uygulanan displacement ayrı kaydedilebilir.)*

---

# 139. Recovery Correction Is Not Walked Distance (Recovery Correction Yürünmüş Mesafe Değildir)

Relocalization correction magnitude will never be counted as pedestrian travel distance. *(Relocalization correction magnitude hiçbir zaman pedestrian travel distance olarak sayılmayacaktır.)*

---

# 140. Ground Truth Firewall Integrity Metric (Ground Truth Firewall Bütünlük Metriği)

```text
unauthorizedGnssEstimatorUpdateCount
```

---

# 141. Required Firewall Result (Gerekli Firewall Sonucu)

For every valid formal denied interval, the required value is exactly zero. *(Her geçerli resmî kesintili aralık için gerekli değer tam olarak sıfırdır.)*

```text
unauthorizedGnssEstimatorUpdateCount = 0
```

---

# 142. Firewall Is a Gate, Not a Performance Metric (Firewall Bir Performans Metriği Değil Gate'tir)

A session with unauthorized GNSS estimator influence is invalid rather than merely lower scoring. *(Yetkisiz GNSS estimator influence içeren oturum yalnızca düşük skor almak yerine invalid olur.)*

---

# 143. Uncertainty Evaluation (Belirsizlik Değerlendirmesi)

NAVGUARD uncertainty will be evaluated separately from position accuracy. *(NAVGUARD uncertainty position accuracy'den ayrı değerlendirilecektir.)*

---

# 144. Why Accuracy Alone Is Not Enough (Neden Yalnızca Accuracy Yeterli Değildir)

A navigation system can occasionally be accurate while being overconfident or inaccurate while correctly reporting high uncertainty. *(Navigasyon sistemi bazen overconfident iken doğru veya yüksek uncertainty'yi doğru bildirirken inaccurate olabilir.)*

---

# 145. Horizontal Covariance (Yatay Kovaryans)

Let the horizontal covariance be defined as follows. *(Yatay covariance aşağıdaki gibi tanımlansın.)*

```text
P_EN =
[ P_EE  P_EN
  P_NE  P_NN ]
```

---

# 146. Estimated Horizontal Standard Deviations (Tahmini Yatay Standard Deviation'lar)

```text
σ_E =
sqrt(P_EE)

σ_N =
sqrt(P_NN)
```

---

# 147. Ellipse Axes (Ellipse Eksenleri)

The eigenvalues of the horizontal covariance determine the principal uncertainty axes. *(Yatay covariance'ın eigenvalue'ları temel uncertainty axis'lerini belirler.)*

```text
λ_max ≥ λ_min
```

---

# 148. One-Sigma Principal Axes (Bir Sigma Temel Eksenleri)

```text
a_1σ = sqrt(λ_max)
b_1σ = sqrt(λ_min)
```

---

# 149. Confidence Scaling Requires Calibration (Confidence Scaling Kalibrasyon Gerektirir)

A numerical confidence level such as 95% will only be attached to an ellipse if the covariance calibration justifies that interpretation. *(%95 gibi numerical confidence level yalnızca covariance calibration bu yorumu doğrularsa ellipse'e bağlanacaktır.)*

---

# 150. NEES Candidate (NEES Adayı)

For intervals with valid reference and consistent state definition, normalized estimation error squared may be used as an advanced covariance-consistency diagnostic. *(Geçerli referans ve tutarlı state definition bulunan aralıklarda normalized estimation error squared gelişmiş covariance-consistency diagnostic'i olarak kullanılabilir.)*

---

# 151. Position NEES Candidate (Position NEES Adayı)

```text
NEES_pos =
e_ENᵀ
P_EN⁻¹
e_EN
```

where:

```text
e_EN =
[e_E, e_N]ᵀ
```

---

# 152. NEES Requires Careful Interpretation (NEES Dikkatli Yorum Gerektirir)

NEES will not be used casually if covariance independence assumptions or reference quality are poor. *(Covariance independence assumptions veya reference quality zayıfsa NEES gelişigüzel kullanılmayacaktır.)*

---

# 153. NIS Metric (NIS Metriği)

Normalized Innovation Squared may be retained for measurement-update diagnostics. *(Normalized Innovation Squared measurement-update diagnostics için korunabilir.)*

```text
NIS =
νᵀ S⁻¹ ν
```

---

# 154. NIS Is an Internal Fusion Diagnostic (NIS Dahili Fusion Diagnostic'idir)

NIS is primarily a filter-consistency and gating diagnostic rather than a headline field-navigation metric. *(NIS temel olarak filter-consistency ve gating diagnostic'idir, headline field-navigation metriği değildir.)*

---

# 155. Innovation Rejection Rate (Innovation Reddetme Oranı)

```text
InnovationRejectionRate =
RejectedMeasurements /
EligibleMeasurements
```

---

# 156. Rejection Rate Interpretation (Reddetme Oranı Yorumu)

A very high rejection rate may indicate poor sensor quality, poor covariance calibration, or overly strict gating. *(Çok yüksek rejection rate zayıf sensor quality, zayıf covariance calibration veya aşırı strict gating gösterebilir.)*

---

# 157. Quality-State Availability (Quality-State Availability)

The proportion of denied time spent in each navigation-quality state may be reported. *(Her navigation-quality state içerisinde geçirilen denied-time oranı raporlanabilir.)*

---

# 158. Candidate Quality Distribution (Aday Kalite Dağılımı)

```text
GOOD %
USABLE %
DEGRADED %
UNRELIABLE %
UNAVAILABLE %
```

---

# 159. Valid Navigation Availability (Geçerli Navigasyon Availability)

```text
ValidNavigationAvailability =
T_valid_estimator /
T_denied
```

---

# 160. Valid Availability Percentage (Geçerli Availability Yüzdesi)

```text
ValidNavigationAvailabilityPercent =
100 ×
ValidNavigationAvailability
```

---

# 161. Unreliable Duration (Güvenilmez Süre)

Total time spent in `UNRELIABLE` may be reported. *(`UNRELIABLE` içerisinde geçirilen toplam süre raporlanabilir.)*

---

# 162. Unavailable Duration (Kullanılamaz Süre)

Total time spent in `UNAVAILABLE` may be reported. *(`UNAVAILABLE` içerisinde geçirilen toplam süre raporlanabilir.)*

---

# 163. False Confidence Analysis (Yanlış Güven Analizi)

Sessions in which actual error is large while reported uncertainty remains small will receive explicit analysis. *(Gerçek error büyükken raporlanan uncertainty küçük kalan oturumlar açık analysis alacaktır.)*

---

# 164. Conservative Uncertainty Analysis (Temkinli Belirsizlik Analizi)

Sessions where uncertainty grows faster than actual error may indicate conservative estimation. *(Uncertainty'nin actual error'dan daha hızlı büyüdüğü oturumlar conservative estimation gösterebilir.)*

---

# 165. No Accuracy Claim from Uncertainty Alone (Yalnızca Uncertainty'den Accuracy İddiası Olmaması)

Small covariance does not prove the position is accurate. *(Küçük covariance position'ın accurate olduğunu kanıtlamaz.)*

---

# 166. Baseline PDR Metrics (Baseline PDR Metrikleri)

Configuration A will be scored using the same positional metrics as Configuration D. *(Configuration A Configuration D ile aynı positional metrics kullanılarak skorlanacaktır.)*

---

# 167. Same Evaluator Requirement (Aynı Evaluator Gereksinimi)

The same metric implementation and reference alignment logic must evaluate every compared configuration. *(Aynı metric implementation ve reference alignment logic karşılaştırılan her yapılandırmayı değerlendirmelidir.)*

---

# 168. No Separate Favorable Evaluator (Ayrı Favorable Evaluator Olmaması)

NAVGUARD and baseline will not use different smoothing or scoring rules that favor one configuration. *(NAVGUARD ve baseline bir yapılandırmayı kayıran farklı smoothing veya scoring rule'ları kullanmayacaktır.)*

---

# 169. Session-Level Metric Record (Oturum Seviyesi Metrik Kaydı)

Each evaluated configuration will produce a session-level metric record. *(Değerlendirilen her yapılandırma session-level metric record üretecektir.)*

```text
SessionMetricRecord
- sessionId
- configuration
- validSampleCount
- validReferenceDuration
- meanErrorM
- medianErrorM
- rmseM
- p95ErrorM
- finalErrorM
- eastFinalErrorM
- northFinalErrorM
- driftPerMinute
- driftPerDistance
- distanceErrorM
- distanceErrorPercent
- closureErrorM
- headingMAE
- stepCountErrorPercent
- arcoreAvailability
- aiMedianLatencyMs
- recoveryLatencyMs
- integrityState
```

---

# 170. Missing Metrics (Eksik Metrikler)

Metrics that cannot be defensibly calculated will be stored as unavailable rather than zero. *(Savunulabilir şekilde hesaplanamayan metrikler sıfır yerine unavailable olarak saklanacaktır.)*

---

# 171. No Zero-Filling Missing Metrics (Eksik Metriklere Sıfır Doldurmama)

Missing `headingMAE`, for example, must not become `0°`. *(Örneğin missing `headingMAE`, `0°` haline gelmemelidir.)*

---

# 172. Route-Level Aggregation (Rota Seviyesi Aggregation)

Session metrics will be grouped by route category. *(Session metrics rota kategorisine göre gruplanacaktır.)*

---

# 173. Route-Level Median (Rota Seviyesi Median)

For each configuration and route type, the median of session-level metric values may be reported. *(Her configuration ve route type için session-level metric value'ların medyanı raporlanabilir.)*

---

# 174. Route-Level Mean (Rota Seviyesi Mean)

The mean across valid repeated sessions may also be reported. *(Geçerli tekrarlanan oturumlar üzerindeki mean de raporlanabilir.)*

---

# 175. Session-Level Before Sample-Level Aggregation (Sample Seviyesinden Önce Session Seviyesi Aggregation)

The primary cross-session comparison will avoid letting one unusually long session dominate the benchmark simply because it has more timestamp samples. *(Temel cross-session karşılaştırma yalnızca daha fazla timestamp sample'a sahip olduğu için olağandışı uzun bir oturumun benchmark'a hakim olmasını önleyecektir.)*

---

# 176. Preferred Hierarchical Aggregation (Tercih Edilen Hiyerarşik Aggregation)

Primary comparison will first compute metrics per session and then aggregate those session-level metrics across matched sessions. *(Temel karşılaştırma önce metric'leri session başına hesaplayacak ve ardından bu session-level metric'leri matched session'lar boyunca aggregate edecektir.)*

---

# 177. Why Hierarchical Aggregation Matters (Hiyerarşik Aggregation Neden Önemlidir)

This gives each physical session a more interpretable contribution to the final benchmark. *(Bu her fiziksel oturumun final benchmark'a daha yorumlanabilir katkı sağlamasını sağlar.)*

---

# 178. Global Sample-Pooled Metrics (Global Sample-Pooled Metrikler)

Sample-pooled statistics may be reported as supplementary analysis. *(Sample-pooled statistics tamamlayıcı analysis olarak raporlanabilir.)*

They will not replace session-level matched comparisons. *(Session-level matched comparison'ların yerini almayacaktır.)*

---

# 179. Matched Session Pair (Eşleşmiş Session Pair)

For a physical session `s`, Configuration A and Configuration D outputs form a matched comparison pair. *(Fiziksel session `s` için Configuration A ve Configuration D çıktıları matched comparison pair oluşturur.)*

---

# 180. Session-Level Absolute Improvement (Session Seviyesi Mutlak İyileştirme)

For a selected metric where lower is better, absolute improvement is defined as follows. *(Düşük değerin daha iyi olduğu seçilen metrik için absolute improvement aşağıdaki gibi tanımlanır.)*

```text
Δ_s =
Metric_A,s -
Metric_D,s
```

---

# 181. Positive Absolute Improvement (Pozitif Mutlak İyileştirme)

A positive value means Configuration D performed better than Configuration A for that metric. *(Pozitif değer Configuration D'nin ilgili metrikte Configuration A'dan daha iyi performans gösterdiğini belirtir.)*

---

# 182. Session-Level Relative Improvement (Session Seviyesi Göreli İyileştirme)

```text
RelativeImprovement_s =
100 ×
(Metric_A,s - Metric_D,s) /
Metric_A,s
```

---

# 183. Relative Improvement Requires Non-Zero Baseline (Göreli İyileştirme Sıfır Olmayan Baseline Gerektirir)

Relative improvement will not be calculated when the baseline denominator is zero or numerically meaningless. *(Baseline denominator sıfır veya sayısal olarak anlamsız olduğunda relative improvement hesaplanmayacaktır.)*

---

# 184. Primary Improvement Calculation (Temel İyileştirme Hesabı)

The preferred primary improvement statement will compare aggregated matched session-level median position errors for Configuration D versus Configuration A. *(Tercih edilen temel improvement ifadesi Configuration D ve Configuration A için aggregate edilmiş matched session-level median position error değerlerini karşılaştıracaktır.)*

---

# 185. Primary Target Formula (Temel Hedef Formülü)

Let:

```text
M_A =
aggregated matched-session median horizontal position error for Configuration A

M_D =
aggregated matched-session median horizontal position error for Configuration D
```

Then:

```text
ImprovementPercent =
100 ×
(M_A - M_D) /
M_A
```

---

# 186. Predeclared Primary Research Target (Önceden Belirlenmiş Primary Research Hedefi)

The predeclared target is frozen as at least a `20%` reduction in aggregated matched-session median horizontal position error for Configuration D relative to Configuration A. It is not a measured result or a success guarantee. *(Predeclared target Configuration D için Configuration A'ya göre aggregated matched-session median horizontal position error'da en az `%20` reduction olarak frozen'dır. Bu değer measured result veya başarı garantisi değildir.)*

```text
ImprovementPercent ≥ 20%
```

---

# 187. Target Is Frozen Before Final Results (Hedef Final Sonuçlardan Önce Sabitlenir)

The predeclared primary research target is frozen before final benchmark collection and must not be revised in response to measured benchmark results. *(Predeclared primary research target final benchmark collection öncesinde frozen'dır ve measured benchmark result'larına yanıt olarak revised edilmemelidir.)*

---

# 188. No Target Relaxation After Seeing Results (Sonuçları Gördükten Sonra Hedef Gevşetme Olmaması)

The success criterion will not be weakened merely because final results fail to reach it. *(Success criterion yalnızca final sonuçlar hedefe ulaşamadığı için zayıflatılmayacaktır.)*

---

# 189. Improvement Reporting for B and C (B ve C İçin İyileştirme Raporlama)

Configurations B and C may also be compared with A and D using the same formulas. *(Configuration B ve C de aynı formüller kullanılarak A ve D ile karşılaştırılabilir.)*

---

# 190. Ablation Interpretation (Ablation Yorumu)

A → B improvement estimates the contribution of improved heading. *(A → B improvement geliştirilmiş heading katkısını tahmin eder.)*

A → C improvement estimates the contribution of ARCore-enhanced PDR. *(A → C improvement ARCore-enhanced PDR katkısını tahmin eder.)*

A → D improvement estimates the combined full-system gain. *(A → D improvement birleşik full-system gain'i tahmin eder.)*

---

# 191. Interaction Effects (Interaction Etkileri)

Improvements from B and C are not assumed to add linearly to D. *(B ve C'den gelen iyileştirmelerin D'ye linear şekilde toplandığı varsayılmayacaktır.)*

---

# 192. Number of Better Matched Sessions (Daha İyi Matched Session Sayısı)

The benchmark may report how many matched sessions show lower error for D than A. *(Benchmark kaç matched session'da D'nin A'dan daha düşük error gösterdiğini raporlayabilir.)*

```text
WinCount_D_vs_A
```

---

# 193. Win Rate (Kazanma Oranı)

```text
WinRate =
SessionsWhereDImproves /
MatchedValidSessions
```

---

# 194. Win Rate Is Secondary (Win Rate İkincildir)

Win rate will supplement but not replace magnitude-based error metrics. *(Win rate magnitude-based error metric'lerin yerini almak yerine onları tamamlayacaktır.)*

---

# 195. Route-Specific Improvement (Rota Özel İyileştirme)

Improvement percentages may be reported separately for straight, turn-heavy, and closed routes. *(Improvement percentage'ları düz, dönüş yoğun ve kapalı rotalar için ayrı raporlanabilir.)*

---

# 196. No Route Cherry-Picking (Rota Cherry-Picking Olmaması)

The overall conclusion will not be based only on the route type where NAVGUARD improves most. *(Genel sonuç yalnızca NAVGUARD'ın en fazla iyileştiği route type'a dayanmayacaktır.)*

---

# 197. Confidence Intervals Candidate (Confidence Interval Adayı)

Because the final sample count is expected to be small, nonparametric bootstrap confidence intervals may be reported for selected aggregated metrics if implementation time permits. *(Final sample count'un küçük olması beklendiği için implementation time izin verirse seçilen aggregate metric'ler için nonparametric bootstrap confidence interval raporlanabilir.)*

---

# 198. Confidence Interval Reporting Is Optional (Confidence Interval Raporlama İsteğe Bağlıdır)

Confidence intervals are desirable but are not required for the minimum project completion. *(Confidence interval'lar tercih edilir ancak minimum proje tamamlanması için zorunlu değildir.)*

---

# 199. No Unsupported Parametric Claims (Desteklenmeyen Parametrik İddia Olmaması)

NAVGUARD will not assume normality of small field-test samples without evidence. *(NAVGUARD küçük field-test sample'larının normal dağılım gösterdiğini kanıt olmadan varsaymayacaktır.)*

---

# 200. Statistical Significance Is Secondary to Engineering Effect (İstatistiksel Anlamlılık Mühendislik Etkisine Göre İkincildir)

The project will prioritize transparent effect size and repeatable engineering evidence over unsupported claims of statistical significance. *(Proje desteklenmeyen statistical significance iddiaları yerine şeffaf effect size ve tekrarlanabilir engineering evidence'a öncelik verecektir.)*

---

# 201. Paired Statistical Test Candidate (Paired Statistical Test Adayı)

If enough matched sessions exist, a paired nonparametric test such as Wilcoxon signed-rank may be considered as supplementary analysis. *(Yeterli matched session mevcutsa Wilcoxon signed-rank gibi paired nonparametric test tamamlayıcı analysis olarak değerlendirilebilir.)*

---

# 202. No Significance Claim Without Suitable Sample (Uygun Sample Olmadan Significance İddiası Olmaması)

A p-value will not be emphasized when the number of matched sessions is too small for meaningful inference. *(Matched session sayısı anlamlı inference için çok küçük olduğunda p-value vurgulanmayacaktır.)*

---

# 203. Effect Size Candidate (Effect Size Adayı)

Matched median absolute improvement and relative improvement will serve as practical engineering effect-size summaries even if formal statistical testing is not used. *(Formal statistical testing kullanılmasa bile matched median absolute improvement ve relative improvement pratik engineering effect-size summary olarak kullanılacaktır.)*

---

# 204. Benchmark Inclusion Rule (Benchmark Inclusion Kuralı)

Only sessions passing the frozen integrity and reference-quality policy may contribute to the primary quantitative positional benchmark. *(Yalnızca frozen integrity ve reference-quality policy'yi geçen oturumlar temel quantitative positional benchmark'a katkıda bulunabilir.)*

---

# 205. Invalid Session Treatment (Invalid Session Yönetimi)

Invalid sessions will be reported separately and excluded from primary metric aggregation. *(Invalid session'lar ayrı raporlanacak ve primary metric aggregation'dan hariç tutulacaktır.)*

---

# 206. Poor but Valid Sessions (Kötü ama Geçerli Oturumlar)

Poor-performing but valid sessions will remain in primary aggregation. *(Kötü performans gösteren ancak geçerli oturumlar primary aggregation içerisinde kalacaktır.)*

---

# 207. Included with Limitations (Sınırlamalarla Dahil)

A session may be included for some metrics but excluded from others if a specific reference channel is unavailable. *(Belirli reference channel kullanılamıyorsa bir oturum bazı metric'ler için dahil edilip diğerleri için hariç tutulabilir.)*

---

# 208. Example Partial Inclusion (Kısmi Inclusion Örneği)

A session with poor continuous GNSS reference may still contribute to step-count or runtime metrics while being excluded from continuous position-error evaluation. *(Zayıf continuous GNSS reference içeren oturum continuous position-error evaluation'dan hariç tutulurken step-count veya runtime metric'lerine katkıda bulunabilir.)*

---

# 209. Metric-Specific Validity (Metrik Özel Geçerlilik)

Each metric will have its own required evidence prerequisites. *(Her metric kendi gerekli evidence prerequisite'larına sahip olacaktır.)*

---

# 210. Metric Prerequisite Table (Metrik Önkoşul Tablosu)

| Metric (Metrik)                                   | Required Evidence (Gerekli Kanıt)                                                                           |
| ------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| Position Error *(Konum Hatası)*                   | Valid aligned estimator + reference position *(Geçerli hizalanmış estimator + reference position)*          |
| Final Error *(Nihai Hata)*                        | Valid pre-correction estimate + recovery reference *(Geçerli pre-correction estimate + recovery reference)* |
| Heading MAE *(Heading MAE)*                       | Defensible heading reference *(Savunulabilir heading referansı)*                                            |
| Step Count Error *(Adım Sayısı Hatası)*           | Verified step count *(Doğrulanmış adım sayısı)*                                                             |
| Step Length MAE *(Adım Uzunluğu MAE)*             | Defensible step-length reference *(Savunulabilir adım uzunluğu referansı)*                                  |
| ARCore Availability *(ARCore Kullanılabilirliği)* | ARCore-enabled session *(ARCore etkin oturum)*                                                              |
| AI Macro F1 *(AI Macro F1)*                       | Frozen held-out labeled test set *(Sabitlenmiş held-out etiketli test seti)*                                |
| Battery Usage *(Batarya Kullanımı)*               | Controlled duration + start/end battery *(Kontrollü süre + başlangıç/bitiş batarya)*                        |

---

# 211. Performance Metrics (Performans Metrikleri)

System performance metrics will be reported separately from navigation accuracy metrics. *(Sistem performance metric'leri navigation accuracy metric'lerinden ayrı raporlanacaktır.)*

---

# 212. CPU Usage (CPU Kullanımı)

Average and peak CPU use may be recorded during representative runs if reliable profiling data is available. *(Güvenilir profiling data mevcutsa temsili run'lar sırasında average ve peak CPU use kaydedilebilir.)*

---

# 213. Memory Usage (Memory Kullanımı)

Memory behavior will focus on boundedness and long-session growth. *(Memory davranışı boundedness ve long-session growth üzerine odaklanacaktır.)*

---

# 214. Memory Growth Metric (Memory Growth Metriği)

A simple memory growth rate may be calculated over a controlled endurance session. *(Kontrollü endurance session üzerinde basit memory growth rate hesaplanabilir.)*

```text
MemoryGrowthRate =
(Memory_end - Memory_start) /
SessionDuration
```

---

# 215. Memory Growth Interpretation (Memory Growth Yorumu)

A positive growth rate does not automatically prove a leak, but sustained unbounded growth requires investigation. *(Pozitif growth rate otomatik olarak leak kanıtlamaz ancak sustained unbounded growth investigation gerektirir.)*

---

# 216. Battery Consumption (Batarya Tüketimi)

Battery percentage change will be recorded over controlled sessions. *(Battery percentage change kontrollü oturumlarda kaydedilecektir.)*

---

# 217. Battery Usage per Hour (Saat Başına Batarya Kullanımı)

```text
BatteryUsePerHour =
BatteryPercentDrop /
(SessionDurationHours)
```

---

# 218. Battery Metric Limitations (Batarya Metriği Sınırlamaları)

Phone battery percentage is coarse and affected by device conditions, so it will be interpreted as a practical engineering metric rather than laboratory-grade energy measurement. *(Telefon battery percentage coarse'dur ve cihaz koşullarından etkilenir, bu nedenle laboratory-grade energy measurement yerine pratik engineering metric olarak yorumlanacaktır.)*

---

# 219. Thermal Metrics (Termal Metrikler)

Available device temperature and thermal-throttling state may be logged during endurance testing. *(Kullanılabilir cihaz sıcaklığı ve thermal-throttling state endurance testing sırasında loglanabilir.)*

---

# 220. Storage Throughput (Depolama Throughput)

```text
StorageRate =
BytesWritten /
SessionDuration
```

---

# 221. Storage Growth per Minute (Dakika Başına Depolama Büyümesi)

```text
StorageMBPerMinute =
TotalBytesWritten /
(1024² × SessionDurationMinutes)
```

---

# 222. Logging Drop Rate (Logging Drop Oranı)

```text
LogDropRate =
DroppedRecords /
ProducedRecords
```

---

# 223. Required Benchmark Logging Drop Result (Gerekli Benchmark Logging Drop Sonucu)

Mandatory logging streams should have zero dropped records in valid formal benchmark sessions. *(Zorunlu logging stream'leri geçerli resmî benchmark oturumlarında sıfır dropped record'a sahip olmalıdır.)*

---

# 224. Sensor Delivery Metrics (Sensör Delivery Metrikleri)

Actual sensor sampling rate will be reported using timestamps. *(Gerçek sensor sampling rate timestamps kullanılarak raporlanacaktır.)*

---

# 225. Effective Sampling Frequency (Efektif Sampling Frekansı)

```text
f_eff =
1 /
median(Δt)
```

for a stable sensor interval if expressed in seconds. *(Stabil sensör aralığı saniye cinsinden ifade edildiğinde bu formül kullanılabilir.)*

---

# 226. Sampling Jitter (Sampling Jitter)

Variation in inter-sample timing may be summarized with standard deviation, median absolute deviation, or percentiles. *(Inter-sample timing variation standard deviation, median absolute deviation veya percentile'larla özetlenebilir.)*

---

# 227. Sensor Gap Count (Sensör Gap Sayısı)

The number of intervals exceeding the frozen gap threshold will be reported where relevant. *(Frozen gap threshold'u aşan interval sayısı ilgili olduğunda raporlanacaktır.)*

---

# 228. End-to-End Navigation Latency Candidate (Uçtan Uca Navigasyon Latency Adayı)

For selected events, latency from sensor measurement to resulting navigation-state update may be profiled. *(Seçilen event'ler için sensor measurement'tan resulting navigation-state update'e kadar latency profile edilebilir.)*

---

# 229. UI Latency Is Separate (UI Latency Ayrıdır)

UI rendering latency will not be confused with estimator latency. *(UI rendering latency estimator latency ile karıştırılmayacaktır.)*

---

# 230. Benchmark Summary Hierarchy (Benchmark Summary Hiyerarşisi)

Results will be presented in layers rather than as one oversized table only. *(Sonuçlar yalnızca tek aşırı büyük tablo yerine katmanlar halinde sunulacaktır.)*

---

# 231. Level 1 — Primary Research Result (Seviye 1 — Temel Araştırma Sonucu)

The primary result will summarize Configuration A versus Configuration D on matched final sessions. *(Temel sonuç Configuration A ve Configuration D'yi matched final session'larda özetleyecektir.)*

---

# 232. Level 2 — Ablation Results (Seviye 2 — Ablation Sonuçları)

Configurations B and C will show which subsystems contribute to improvement. *(Configuration B ve C hangi alt sistemlerin improvement'a katkıda bulunduğunu gösterecektir.)*

---

# 233. Level 3 — Route-Specific Results (Seviye 3 — Rota Özel Sonuçlar)

Straight, turn-heavy, and closed-route results will be shown separately. *(Düz, dönüş yoğun ve kapalı rota sonuçları ayrı gösterilecektir.)*

---

# 234. Level 4 — Subsystem Results (Seviye 4 — Alt Sistem Sonuçları)

Step detection, heading, ARCore, AI, uncertainty, recovery, and runtime metrics will be reported separately. *(Step detection, heading, ARCore, AI, uncertainty, recovery ve runtime metrics ayrı raporlanacaktır.)*

---

# 235. Primary Benchmark Table Candidate (Temel Benchmark Tablosu Adayı)

| Metric (Metrik)                  |              A — PDR |          B — Heading |           C — ARCore |    D — Full NAVGUARD |
| -------------------------------- | -------------------: | -------------------: | -------------------: | -------------------: |
| Median Error m *(Medyan Hata m)* | TBD *(Belirlenecek)* | TBD *(Belirlenecek)* | TBD *(Belirlenecek)* | TBD *(Belirlenecek)* |
| Mean Error m *(Ortalama Hata m)* | TBD *(Belirlenecek)* | TBD *(Belirlenecek)* | TBD *(Belirlenecek)* | TBD *(Belirlenecek)* |
| RMSE m *(RMSE m)*                | TBD *(Belirlenecek)* | TBD *(Belirlenecek)* | TBD *(Belirlenecek)* | TBD *(Belirlenecek)* |
| P95 Error m *(P95 Hata m)*       | TBD *(Belirlenecek)* | TBD *(Belirlenecek)* | TBD *(Belirlenecek)* | TBD *(Belirlenecek)* |
| Final Error m *(Nihai Hata m)*   | TBD *(Belirlenecek)* | TBD *(Belirlenecek)* | TBD *(Belirlenecek)* | TBD *(Belirlenecek)* |
| Drift % *(Drift %)*              | TBD *(Belirlenecek)* | TBD *(Belirlenecek)* | TBD *(Belirlenecek)* | TBD *(Belirlenecek)* |

---

# 236. No Placeholder Results Will Be Presented as Measured (Placeholder Sonuçlar Ölçülmüş Gibi Sunulmayacak)

`TBD` values remain explicitly unmeasured until field experiments produce evidence. *(`TBD` değerleri field experiment'ler kanıt üretmeden açık şekilde ölçülmemiş kalacaktır.)*

---

# 237. Session-Level Result Table Candidate (Session Seviyesi Sonuç Tablosu Adayı)

| Session (Oturum) | Route (Rota) | Config (Yapılandırma) | Median Error (Medyan Hata) | Final Error (Nihai Hata) | P95 | Validity (Geçerlilik) |
| ---------------- | ------------ | --------------------- | -------------------------: | -----------------------: | --: | --------------------- |
| `...`            | `...`        | `...`                 |                        TBD |                      TBD | TBD | TBD                   |

---

# 238. Improvement Table Candidate (İyileştirme Tablosu Adayı)

| Session (Oturum) | A Median (A Medyan) | D Median (D Medyan) | Absolute Improvement (Mutlak İyileştirme) | Relative Improvement (Göreli İyileştirme) |
| ---------------- | ------------------: | ------------------: | ----------------------------------------: | ----------------------------------------: |
| `...`            |                 TBD |                 TBD |                                       TBD |                                       TBD |

---

# 239. AI Result Table Candidate (AI Sonuç Tablosu Adayı)

| Metric (Metrik)                         | Result (Sonuç) |
| --------------------------------------- | -------------: |
| Macro F1                                |            TBD |
| Accuracy                                |            TBD |
| Stationary F1                           |            TBD |
| Walking F1                              |            TBD |
| Running F1                              |            TBD |
| Turning F1                              |            TBD |
| Median Latency ms *(Medyan Latency ms)* |            TBD |
| P95 Latency ms *(P95 Latency ms)*       |            TBD |

---

# 240. ARCore Result Table Candidate (ARCore Sonuç Tablosu Adayı)

| Metric (Metrik)                                                 | Result (Sonuç) |
| --------------------------------------------------------------- | -------------: |
| Tracking Availability % *(Tracking Kullanılabilirliği %)*       |            TBD |
| Tracking Loss Count *(Tracking Kayıp Sayısı)*                   |            TBD |
| Mean Valid Segment Duration *(Ortalama Geçerli Segment Süresi)* |            TBD |

---

# 241. Recovery Result Table Candidate (Recovery Sonuç Tablosu Adayı)

| Metric (Metrik)                                        | Result (Sonuç) |
| ------------------------------------------------------ | -------------: |
| Pre-Correction Error m *(Düzeltme Öncesi Hata m)*      |            TBD |
| Validation Latency s *(Validation Latency s)*          |            TBD |
| Relocalization Latency s *(Relocalization Latency s)*  |            TBD |
| Total Recovery Latency s *(Toplam Recovery Latency s)* |            TBD |
| Recovery Success *(Recovery Başarısı)*                 |            TBD |

---

# 242. Performance Table Candidate (Performans Tablosu Adayı)

| Metric (Metrik)                               | Result (Sonuç) |
| --------------------------------------------- | -------------: |
| AI Median Latency ms *(AI Medyan Latency ms)* |            TBD |
| Battery Use / h *(Batarya Kullanımı / saat)*  |            TBD |
| Storage MB / min *(Depolama MB / dk)*         |            TBD |
| Peak Memory *(Peak Memory)*                   |            TBD |
| Mandatory Log Drops *(Zorunlu Log Drop)*      |            TBD |

---

# 243. Result Precision (Sonuç Hassasiyeti)

Reported numeric precision will reflect measurement quality and will not imply unrealistic accuracy. *(Raporlanan numeric precision measurement quality'yi yansıtacak ve gerçek dışı accuracy ima etmeyecektir.)*

---

# 244. Excessive Decimal Places (Aşırı Ondalık Basamak)

A smartphone navigation error of several metres will not be reported with meaningless micrometre-level decimal precision. *(Birkaç metre seviyesindeki smartphone navigation error anlamsız micrometre-level decimal precision ile raporlanmayacaktır.)*

---

# 245. Units Must Be Explicit (Birimler Açık Olmalıdır)

Every metric table and chart will include units where applicable. *(Her metric table ve chart uygulanabilir olduğunda birimleri içerecektir.)*

---

# 246. Metric Versioning (Metrik Sürümleme)

The evaluation pipeline will have an explicit metric-code or analysis-version identifier. *(Evaluation pipeline açık metric-code veya analysis-version identifier'a sahip olacaktır.)*

---

# 247. Why Metric Versioning Matters (Metrik Sürümleme Neden Önemlidir)

Changing interpolation, reference filtering, or metric calculation can change results even when estimator output remains identical. *(Interpolation, reference filtering veya metric calculation değiştirmek estimator output aynı kalsa bile sonuçları değiştirebilir.)*

---

# 248. Frozen Metric Pipeline (Sabitlenmiş Metrik Hattı)

The primary final benchmark will use one frozen evaluation pipeline version. *(Temel final benchmark tek frozen evaluation pipeline sürümü kullanacaktır.)*

---

# 249. Metric Recalculation (Metrik Yeniden Hesaplama)

If the evaluation pipeline changes after results are generated, the new results must receive a new analysis version rather than silently replacing the original benchmark record. *(Evaluation pipeline sonuçlar üretildikten sonra değişirse yeni sonuçlar orijinal benchmark kaydını sessizce değiştirmek yerine yeni analysis version almalıdır.)*

---

# 250. Reproducibility Requirement (Tekrarlanabilirlik Gereksinimi)

Given the same session artifacts and analysis configuration, metric calculation must be reproducible. *(Aynı session artifact'ları ve analysis configuration verildiğinde metric calculation tekrarlanabilir olmalıdır.)*

---

# 251. Python as Primary Offline Metric Environment (Temel Offline Metrik Ortamı Olarak Python)

Python will be the primary environment for final benchmark metric calculation and statistical analysis. *(Python final benchmark metric calculation ve statistical analysis için temel ortam olacaktır.)*

---

# 252. Mobile Metrics Are Supplementary (Mobil Metrikler Tamamlayıcıdır)

The Android application may display summary metrics, but final report values will preferably be reproduced independently in the offline analysis pipeline. *(Android uygulaması summary metrics gösterebilir ancak final report değerleri tercihen offline analysis pipeline içerisinde bağımsız şekilde yeniden üretilecektir.)*

---

# 253. Cross-Check Requirement (Cross-Check Gereksinimi)

Important mobile-computed summary values may be cross-checked against Python results. *(Önemli mobile-computed summary value'lar Python sonuçlarına karşı cross-check edilebilir.)*

---

# 254. Automated Metric Tests (Otomatik Metrik Testleri)

Metric functions will receive deterministic unit tests using known synthetic trajectories. *(Metric function'lar bilinen synthetic trajectory'ler kullanılarak deterministik unit test alacaktır.)*

---

# 255. Zero-Error Trajectory Test (Sıfır Hata Trajectory Testi)

Identical estimator and reference trajectories must produce zero position error metrics within numerical tolerance. *(Aynı estimator ve reference trajectory'ler sayısal tolerans içerisinde sıfır position error metric üretmelidir.)*

---

# 256. Constant Offset Test (Sabit Offset Testi)

A trajectory shifted exactly 3 m East from reference should produce approximately 3 m horizontal error at every valid sample. *(Reference'tan tam 3 m East kaydırılmış trajectory her valid sample'da yaklaşık 3 m horizontal error üretmelidir.)*

---

# 257. Known RMSE Test (Bilinen RMSE Testi)

Synthetic error sequences with analytically known RMSE will verify the metric implementation. *(Analitik olarak bilinen RMSE'ye sahip synthetic error sequence'leri metric implementation'ı doğrulayacaktır.)*

---

# 258. Circular Heading Test (Circular Heading Testi)

A predicted heading of 359° and reference heading of 1° must produce approximately 2° error. *(Predicted heading 359° ve reference heading 1° yaklaşık 2° error üretmelidir.)*

---

# 259. Missing Reference Test (Eksik Referans Testi)

A missing reference sample must be excluded rather than replaced with zero coordinates. *(Missing reference sample sıfır koordinatla değiştirilmek yerine hariç tutulmalıdır.)*

---

# 260. Recovery Pre-Correction Test (Recovery Pre-Correction Testi)

The metric evaluator must use pre-correction state for final denied error. *(Metric evaluator final denied error için pre-correction state kullanmalıdır.)*

---

# 261. Post-Correction Leakage Test (Post-Correction Sızıntı Testi)

Using the post-relocalization state as final denied error must fail a dedicated regression test. *(Post-relocalization state'i final denied error olarak kullanmak dedicated regression test'i geçememelidir.)*

---

# 262. Route Distance Test (Rota Mesafe Testi)

Known simple straight reference paths will verify path-distance integration. *(Bilinen basit straight reference path'ler path-distance integration'ı doğrulayacaktır.)*

---

# 263. Metric Integrity Test IDs (Metrik Bütünlük Test ID'leri)

```text
MET-POS-001   Instantaneous horizontal error
MET-POS-002   Mean error
MET-POS-003   Median error
MET-POS-004   RMSE
MET-POS-005   P95 error
MET-POS-006   Final pre-correction error
MET-POS-007   East/North error components

MET-DRIFT-001 Drift per minute
MET-DRIFT-002 Drift per distance
MET-DRIFT-003 Distance error
MET-DRIFT-004 Closure error

MET-HDG-001   Circular heading difference
MET-HDG-002   Heading MAE
MET-HDG-003   Heading RMSE

MET-STEP-001  Step count absolute error
MET-STEP-002  Step count percentage error
MET-STEP-003  Step precision / recall
MET-STEP-004  Step-length MAE
MET-STEP-005  Step-length bias

MET-AI-001    Confusion matrix
MET-AI-002    Macro F1
MET-AI-003    Accuracy
MET-AI-004    Inference latency
MET-AI-005    Transition latency

MET-ARC-001   ARCore availability
MET-ARC-002   Tracking loss count
MET-ARC-003   Tracking segment duration

MET-REC-001   Recovery pre-correction error
MET-REC-002   Recovery validation latency
MET-REC-003   Relocalization latency
MET-REC-004   Total recovery latency

MET-UNC-001   Horizontal covariance extraction
MET-UNC-002   Ellipse eigenvalues
MET-UNC-003   Invalid covariance rejection
MET-UNC-004   NEES diagnostic
MET-UNC-005   NIS diagnostic

MET-PERF-001  Battery usage
MET-PERF-002  Storage rate
MET-PERF-003  Memory growth
MET-PERF-004  Logging drop rate

MET-CMP-001   A-D absolute improvement
MET-CMP-002   A-D relative improvement
MET-CMP-003   Matched win rate
MET-CMP-004   Route-level aggregation
MET-CMP-005   Overall aggregation
```

---

# 264. Benchmark Acceptance Metric Set (Benchmark Kabul Metrik Seti)

A final valid benchmark must provide the project-level primary research metric, the required secondary or diagnostic position metrics, the Configuration A–D comparison, the Ground Truth Firewall integrity state, and enough supporting subsystem metrics to interpret the result. *(Final valid benchmark project-level primary research metric'i, gerekli secondary veya diagnostic position metric'lerini, Configuration A–D comparison'ını, Ground Truth Firewall integrity state'ini ve sonucu yorumlamak için yeterli supporting subsystem metric'i sağlamalıdır.)*

---

# 265. Minimum Required Navigation Metrics (Minimum Gerekli Navigasyon Metrikleri)

```text
Median Position Error
Mean Position Error
RMSE
P95 Position Error
Final Position Error
Drift per Minute
Drift per Distance
```

---

# 266. Minimum Required Subsystem Metrics (Minimum Gerekli Alt Sistem Metrikleri)

```text
Step Count Error
Motion Macro F1
AI Inference Latency
ARCore Availability when enabled
Recovery Pre-Correction Error
Ground Truth Firewall Count
```

---

# 267. Conditional Metrics (Koşullu Metrikler)

Heading MAE, step-length MAE, covariance consistency, and ARCore relative displacement metrics are required only when defensible references exist. *(Heading MAE, step-length MAE, covariance consistency ve ARCore relative displacement metric'leri yalnızca savunulabilir referanslar mevcut olduğunda gereklidir.)*

---

# 268. No Metric Without Evidence (Kanıt Olmadan Metrik Olmaması)

NAVGUARD will prefer an unavailable metric over a fabricated metric. *(NAVGUARD uydurulmuş metric yerine unavailable metric'i tercih edecektir.)*

---

# 269. Primary Success Decision (Temel Başarı Kararı)

NAVGUARD meets the predeclared primary research target if the frozen final matched-session benchmark shows at least a `20%` reduction in aggregated matched-session median horizontal position error for Configuration D relative to Configuration A. This statement defines the decision rule and does not report a measured result. *(Frozen final matched-session benchmark Configuration D için Configuration A'ya göre aggregated matched-session median horizontal position error'da en az `%20` reduction gösterirse NAVGUARD predeclared primary research target'ı karşılar. Bu ifade decision rule'u tanımlar ve measured result raporlamaz.)*

---

# 270. AI Success Decision (AI Başarı Kararı)

The Motion Classification component meets its provisional standalone target if the frozen held-out session-wise test set produces Macro F1 of at least 0.90. *(Motion Classification component frozen held-out session-wise test set üzerinde en az 0.90 Macro F1 üretirse geçici standalone hedefini karşılar.)*

---

# 271. Step Count Success Decision (Adım Sayısı Başarı Kararı)

The deterministic step-detection subsystem meets its provisional controlled target if absolute step-count percentage error is at or below 5% on the defined controlled evaluation protocol. *(Deterministic step-detection subsystem tanımlanmış controlled evaluation protocol üzerinde absolute step-count percentage error %5 veya altında olursa geçici controlled hedefini karşılar.)*

---

# 272. AI Runtime Success Decision (AI Runtime Başarı Kararı)

The on-device AI runtime meets the provisional latency target if representative inference performance remains below approximately 50 ms per inference according to the frozen latency statistic. *(On-device AI runtime temsili inference performance frozen latency statistic'e göre inference başına yaklaşık 50 ms'nin altında kalırsa geçici latency hedefini karşılar.)*

---

# 273. Final Success Is Multidimensional (Nihai Başarı Çok Boyutludur)

Meeting one metric does not override a Ground Truth Firewall violation, critical integrity failure, or inability to complete the navigation workflow. *(Tek metriği karşılamak Ground Truth Firewall violation, critical integrity failure veya navigasyon workflow'unu tamamlayamama durumunun üzerine yazmaz.)*

---

# 274. Scientific Interpretation Rule (Bilimsel Yorum Kuralı)

Results will distinguish between accuracy improvement, robustness improvement, uncertainty quality, runtime efficiency, and subsystem availability. *(Sonuçlar accuracy improvement, robustness improvement, uncertainty quality, runtime efficiency ve subsystem availability arasındaki farkı ayıracaktır.)*

---

# 275. Example Interpretation Pattern (Örnek Yorumlama Deseni)

A system may reduce median position error but increase battery consumption. *(Bir sistem median position error'ı azaltırken battery consumption'ı artırabilir.)*

That tradeoff will be reported rather than hidden. *(Bu tradeoff gizlenmek yerine raporlanacaktır.)*

---

# 276. Another Interpretation Pattern (Başka Yorumlama Deseni)

A configuration may improve average error while producing worse P95 error. *(Bir configuration average error'ı iyileştirirken daha kötü P95 error üretebilir.)*

Both behaviors will be visible in the benchmark. *(Her iki davranış benchmark içerisinde görünür olacaktır.)*

---

# 277. No Single-Metric Overclaiming (Tek Metrik Üzerinden Aşırı İddia Olmaması)

NAVGUARD will not describe itself as universally superior based only on one favorable metric. *(NAVGUARD yalnızca tek favorable metric'e dayanarak kendisini universally superior olarak tanımlamayacaktır.)*

---

# 278. Benchmark Result Categories (Benchmark Sonuç Kategorileri)

The final benchmark conclusion may classify the project result into broad engineering categories. *(Final benchmark conclusion proje sonucunu genel engineering category'lere sınıflandırabilir.)*

```text
TARGET MET
(HEDEF KARŞILANDI)

PARTIAL IMPROVEMENT
(KISMİ İYİLEŞME)

NO MEASURABLE IMPROVEMENT
(ÖLÇÜLEBİLİR İYİLEŞME YOK)

REGRESSION
(GERİLEME)

INCONCLUSIVE
(SONUÇSUZ)
```

---

# 279. Target Met Definition (Hedef Karşılandı Tanımı)

`TARGET MET` requires the primary success criterion and all critical integrity gates to pass. *(`TARGET MET`, temel success criterion ve tüm critical integrity gate'lerin geçmesini gerektirir.)*

---

# 280. Partial Improvement Definition (Kısmi İyileşme Tanımı)

`PARTIAL IMPROVEMENT` may be used when NAVGUARD improves the baseline measurably but does not reach the frozen target. *(`PARTIAL IMPROVEMENT`, NAVGUARD baseline'ı ölçülebilir şekilde iyileştirirken frozen target'a ulaşmadığında kullanılabilir.)*

---

# 281. No Measurable Improvement Definition (Ölçülebilir İyileşme Yok Tanımı)

`NO MEASURABLE IMPROVEMENT` means the benchmark does not demonstrate a meaningful advantage over the baseline. *(`NO MEASURABLE IMPROVEMENT`, benchmark'ın baseline üzerinde anlamlı advantage göstermediği anlamına gelir.)*

---

# 282. Regression Definition (Gerileme Tanımı)

`REGRESSION` means the full NAVGUARD configuration performs worse than the baseline on the primary metric. *(`REGRESSION`, tam NAVGUARD configuration'ın primary metric üzerinde baseline'dan daha kötü performans göstermesi anlamına gelir.)*

---

# 283. Inconclusive Definition (Sonuçsuz Tanımı)

`INCONCLUSIVE` may be used if too little valid evidence remains after predeclared integrity or reference-quality exclusions. *(`INCONCLUSIVE`, önceden tanımlanmış integrity veya reference-quality exclusion'larından sonra çok az valid evidence kalırsa kullanılabilir.)*

---

# 284. Benchmark Report Reproducibility (Benchmark Raporu Tekrarlanabilirliği)

Every final reported metric will be traceable to session IDs, configuration IDs, analysis version, and evidence artifacts. *(Raporlanan her final metric session ID'lerine, configuration ID'lerine, analysis version'a ve evidence artifact'larına izlenebilir olacaktır.)*

---

# 285. Charts (Grafikler)

The final results may include trajectory plots, position-error-over-time plots, cumulative distribution plots, box plots, and uncertainty-versus-error plots. *(Final sonuçlar trajectory plot'ları, position-error-over-time plot'ları, cumulative distribution plot'ları, box plot'ları ve uncertainty-versus-error plot'larını içerebilir.)*

---

# 286. Trajectory Plot Requirement (Trajectory Plot Gereksinimi)

Trajectory plots will clearly distinguish baseline, full NAVGUARD, and ground-truth tracks. *(Trajectory plot'ları baseline, full NAVGUARD ve ground-truth track'lerini açık şekilde ayıracaktır.)*

---

# 287. Error-over-Time Plot (Zamana Göre Hata Grafiği)

A time-series plot may show horizontal position error during the denied interval. *(Time-series plot kesintili aralık boyunca yatay position error'ı gösterebilir.)*

---

# 288. Denial and Recovery Markers on Charts (Grafiklerde Denial ve Recovery Marker'ları)

The denial start and recovery boundary will be marked clearly on relevant plots. *(Denial start ve recovery boundary ilgili plot'larda açık şekilde işaretlenecektir.)*

---

# 289. CDF Candidate (CDF Adayı)

A cumulative distribution function of position error may supplement percentile reporting. *(Position error cumulative distribution function percentile reporting'i tamamlayabilir.)*

---

# 290. Box Plot Candidate (Box Plot Adayı)

Box plots may summarize session-level error distributions across configurations. *(Box plot'ları configuration'lar arasındaki session-level error distribution'ları özetleyebilir.)*

---

# 291. No Misleading Axis Scaling (Yanıltıcı Eksen Ölçekleme Olmaması)

Charts will not use axis manipulation that exaggerates small improvements without disclosure. *(Chart'lar açıklama olmadan küçük improvement'ları abartacak axis manipulation kullanmayacaktır.)*

---

# 292. Comparable Plot Scale (Karşılaştırılabilir Plot Ölçeği)

When configurations are compared visually, equivalent plots should use consistent axis scales where practical. *(Configuration'lar görsel olarak karşılaştırıldığında eşdeğer plot'lar uygulanabilir olduğunda tutarlı axis scale kullanmalıdır.)*

---

# 293. Metric Naming Consistency (Metrik İsimlendirme Tutarlılığı)

The same metric name will represent the same mathematical definition throughout the report, mobile UI, and Python analysis. *(Aynı metric adı rapor, mobil UI ve Python analysis boyunca aynı matematiksel tanımı temsil edecektir.)*

---

# 294. Example Naming Rule (Örnek İsimlendirme Kuralı)

`Final Position Error` always means pre-correction denied-end horizontal error. *(`Final Position Error` her zaman pre-correction denied-end horizontal error anlamına gelir.)*

---

# 295. Metric Dictionary (Metrik Sözlüğü)

A final metric dictionary may be generated from this document for implementation use. *(Implementation kullanımı için bu dokümandan final metric dictionary üretilebilir.)*

---

# 296. Metric Dictionary Candidate (Metrik Sözlüğü Adayı)

```text
position_error_m
mean_error_m
median_error_m
rmse_m
p95_error_m
final_error_m
east_final_error_m
north_final_error_m
drift_m_per_min
drift_ratio
drift_percent
distance_error_m
distance_error_percent
closure_error_m
heading_mae_deg
step_count_error_percent
step_length_mae_m
motion_macro_f1
ai_latency_median_ms
ai_latency_p95_ms
arcore_tracking_percent
recovery_latency_s
recovery_error_m
```

---

# 297. Metric Schema Version (Metrik Schema Sürümü)

The final metric dictionary will receive an explicit schema or analysis version. *(Final metric dictionary açık schema veya analysis version alacaktır.)*

---

# 298. Minimum Successful Benchmark System (Minimum Başarılı Benchmark Sistemi)

The minimum successful benchmark system will calculate per-session ENU position error, mean, median, RMSE, P95, final pre-correction error, drift per time, drift per distance, step-count error, motion Macro F1, AI latency, recovery error, and A-D matched improvement. *(Minimum başarılı benchmark sistemi session başına ENU position error, mean, median, RMSE, P95, final pre-correction error, drift per time, drift per distance, step-count error, motion Macro F1, AI latency, recovery error ve A-D matched improvement hesaplayacaktır.)*

---

# 299. Target Successful Benchmark System (Hedef Başarılı Benchmark Sistemi)

The target system will additionally evaluate uncertainty consistency, ARCore availability, heading accuracy, learned step-length performance, route-level effects, session win rate, confidence intervals, failure-specific metrics, and richer visualizations. *(Hedef sistem ek olarak uncertainty consistency, ARCore availability, heading accuracy, learned step-length performance, route-level effect'ler, session win rate, confidence interval'lar, failure-specific metric'ler ve daha zengin visualization'ları değerlendirecektir.)*

---

# 300. Optional Benchmark Enhancements (İsteğe Bağlı Benchmark İyileştirmeleri)

Optional enhancements may include bootstrap confidence intervals. *(İsteğe bağlı iyileştirmeler bootstrap confidence interval'ları içerebilir.)*

Optional enhancements may include paired nonparametric significance testing. *(İsteğe bağlı iyileştirmeler paired nonparametric significance testing içerebilir.)*

Optional enhancements may include richer uncertainty calibration plots. *(İsteğe bağlı iyileştirmeler daha zengin uncertainty calibration plot'larını içerebilir.)*

---

# 301. Benchmark Non-Goals (Benchmark Olmayan Hedefler)

NAVGUARD will not claim centimetre-level positional accuracy from ordinary smartphone GNSS reference data. *(NAVGUARD normal smartphone GNSS referans verisinden centimetre-level positional accuracy iddia etmeyecektir.)*

NAVGUARD will not report unavailable metrics as zero. *(NAVGUARD unavailable metric'leri sıfır olarak raporlamayacaktır.)*

NAVGUARD will not select favorable time intervals after seeing the results. *(NAVGUARD sonuçları gördükten sonra favorable time interval seçmeyecektir.)*

---

# 302. Additional Benchmark Non-Goals (Ek Benchmark Olmayan Hedefler)

NAVGUARD will not use corrected recovery position to hide pre-recovery drift. *(NAVGUARD pre-recovery drift'i gizlemek için corrected recovery position kullanmayacaktır.)*

NAVGUARD will not calculate configuration improvement with different evaluator rules. *(NAVGUARD configuration improvement'ı farklı evaluator rule'larıyla hesaplamayacaktır.)*

NAVGUARD will not treat one successful field run as sufficient evidence of general superiority. *(NAVGUARD tek başarılı field run'ı genel superiority için yeterli kanıt olarak ele almayacaktır.)*

---

# 303. Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kararlar)

Horizontal navigation error will be evaluated primarily in metres in the ENU frame. *(Yatay navigation error temel olarak ENU frame içerisinde metre cinsinden değerlendirilecektir.)*

---

# 304. Position Metric Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Konum Metrik Kararları)

Mean, median, RMSE, P95, and final pre-correction horizontal error will form the core position metric set. *(Mean, median, RMSE, P95 ve final pre-correction horizontal error temel position metric setini oluşturacaktır.)*

---

# 305. Final Error Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Final Error Kararları)

Final denied-navigation error is measured before relocalization correction. *(Final kesintili navigasyon hatası relocalization correction öncesinde ölçülür.)*

Post-correction position is not the denied-navigation final error. *(Post-correction position kesintili navigasyon final error değildir.)*

---

# 306. Drift Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Drift Kararları)

NAVGUARD will report both drift per time and drift per travel distance where valid reference distance exists. *(NAVGUARD geçerli reference distance mevcut olduğunda hem drift per time hem drift per travel distance raporlayacaktır.)*

---

# 307. Heading Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Heading Kararları)

Heading error will use circular angular difference. *(Heading error circular angular difference kullanacaktır.)*

---

# 308. Step Metric Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Step Metrik Kararları)

Step-count percentage error will remain the primary controlled step detector metric. *(Step-count percentage error temel controlled step detector metriği olarak kalacaktır.)*

The provisional target remains at or below 5%. *(Geçici hedef %5 veya altında kalmaktadır.)*

---

# 309. Step-Length Metric Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Step-Length Metrik Kararları)

Step-length metrics will only use the reference granularity that the collected data can defensibly support. *(Step-length metric'leri yalnızca toplanan verinin savunulabilir şekilde destekleyebildiği reference granularity'yi kullanacaktır.)*

Route-average labels will not be presented as exact per-step truth. *(Route-average label'lar exact per-step truth olarak sunulmayacaktır.)*

---

# 310. AI Metric Decisions Frozen by This Document (Bu Dokümanla Sabitlenen AI Metrik Kararları)

Motion Classification will use Macro F1 as its primary standalone quality metric. *(Motion Classification temel standalone quality metriği olarak Macro F1 kullanacaktır.)*

Accuracy remains secondary. *(Accuracy ikincil kalacaktır.)*

---

# 311. AI Target Decisions Frozen by This Document (Bu Dokümanla Sabitlenen AI Hedef Kararları)

The provisional held-out Motion Classification target remains Macro F1 ≥ 0.90. *(Geçici held-out Motion Classification hedefi Macro F1 ≥ 0.90 olarak kalmaktadır.)*

---

# 312. ARCore Metric Decisions Frozen by This Document (Bu Dokümanla Sabitlenen ARCore Metrik Kararları)

ARCore will be evaluated as a relative-motion source using tracking availability and controlled relative-motion diagnostics. *(ARCore tracking availability ve kontrollü relative-motion diagnostics kullanılarak relative-motion source olarak değerlendirilecektir.)*

---

# 313. Recovery Metric Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Recovery Metrik Kararları)

Recovery error will always use the pre-correction estimator state. *(Recovery error her zaman pre-correction estimator state kullanacaktır.)*

Recovery validation, relocalization, and total latency will remain separate metrics. *(Recovery validation, relocalization ve total latency ayrı metric'ler olarak kalacaktır.)*

---

# 314. Uncertainty Metric Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Uncertainty Metrik Kararları)

Uncertainty quality will be evaluated independently from position accuracy. *(Uncertainty quality position accuracy'den bağımsız değerlendirilecektir.)*

Formal confidence percentages will not be claimed without calibration evidence. *(Calibration evidence olmadan formal confidence percentage iddia edilmeyecektir.)*

---

# 315. Aggregation Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Aggregation Kararları)

Primary overall comparison will use session-level metrics aggregated across matched sessions rather than one globally pooled timestamp set. *(Temel overall comparison tek globally pooled timestamp set yerine matched session'lar arasında aggregate edilmiş session-level metric'leri kullanacaktır.)*

---

# 316. Comparison Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Karşılaştırma Kararları)

Configurations A-D will be evaluated with the same metric pipeline. *(Configuration A-D aynı metric pipeline ile değerlendirilecektir.)*

---

# 317. Primary Success Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Temel Başarı Kararları)

The predeclared primary research target is frozen as at least a `20%` reduction in aggregated matched-session median horizontal position error for Configuration D relative to Configuration A and remains unmeasured until the final benchmark is completed. *(Predeclared primary research target Configuration D için Configuration A'ya göre aggregated matched-session median horizontal position error'da en az `%20` reduction olarak frozen'dır ve final benchmark tamamlanana kadar unmeasured kalır.)*

---

# 318. Integrity Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Integrity Kararları)

A Ground Truth Firewall violation invalidates the affected formal denied interval and cannot be compensated by good accuracy metrics. *(Ground Truth Firewall violation etkilenen resmî kesintili aralığı invalid hale getirir ve iyi accuracy metric'leriyle telafi edilemez.)*

---

# 319. Missing Data Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Eksik Veri Kararları)

Unavailable metrics will remain unavailable rather than being replaced with fabricated zero values. *(Unavailable metric'ler uydurulmuş sıfır değerlerle değiştirilmek yerine unavailable kalacaktır.)*

---

# 320. Report Integrity Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Rapor Bütünlük Kararları)

Valid poor-performing sessions will remain in the benchmark. *(Geçerli kötü performanslı oturumlar benchmark içerisinde kalacaktır.)*

Metrics will not be recalculated with favorable alternate rules after final results are seen. *(Final sonuçlar görüldükten sonra metric'ler favorable alternate rule'larla yeniden hesaplanmayacaktır.)*

---

# 321. Decisions Pending Pilot Data (Pilot Veriyi Bekleyen Kararlar)

The exact timestamp alignment tolerance remains pending pilot GNSS and estimator timing evidence. *(Kesin timestamp alignment tolerance pilot GNSS ve estimator timing evidence'ını beklemektedir.)*

---

# 322. Decisions Pending Reference Quality Calibration (Referans Kalite Kalibrasyonunu Bekleyen Kararlar)

The final GNSS reference inclusion thresholds remain pending field evidence. *(Nihai GNSS reference inclusion threshold'ları field evidence'ını beklemektedir.)*

---

# 323. Decisions Pending Step Annotation Validation (Step Annotation Validation Bekleyen Kararlar)

The final step-event temporal matching tolerance remains pending controlled annotation experiments. *(Nihai step-event temporal matching tolerance controlled annotation experiment'lerini beklemektedir.)*

---

# 324. Decisions Pending Step-Length Dataset Quality (Step-Length Dataset Kalitesini Bekleyen Kararlar)

The final level of step-length evaluation will depend on whether per-step, segment-level, or only route-level references are defensible. *(Nihai step-length evaluation seviyesi per-step, segment-level veya yalnızca route-level reference'ların hangisinin savunulabilir olduğuna bağlı olacaktır.)*

---

# 325. Decisions Pending Covariance Calibration (Covariance Kalibrasyonunu Bekleyen Kararlar)

The final mapping from covariance ellipse to user-facing statistical confidence remains pending empirical consistency analysis. *(Covariance ellipse'ten user-facing statistical confidence'a final mapping empirical consistency analysis'i beklemektedir.)*

---

# 326. Decisions Pending Final Sample Size (Final Sample Size'ı Bekleyen Kararlar)

Bootstrap confidence intervals or paired significance tests will only be retained if the final valid matched-session count makes them informative. *(Bootstrap confidence interval veya paired significance test'ler yalnızca final valid matched-session count onları informative hale getirirse korunacaktır.)*

---

# 327. Final Benchmark & Evaluation Metrics Statement (Nihai Benchmark ve Değerlendirme Metrikleri Bildirimi)

**NAVGUARD will evaluate pedestrian GNSS-denied navigation through time-aligned horizontal ENU position error, with mean, median, RMSE, P95, final pre-correction error, drift per minute, and drift per travelled distance forming the required secondary or diagnostic position-metric set.** *(NAVGUARD yaya GNSS kesintili navigasyonu time-aligned horizontal ENU position error üzerinden değerlendirecek ve mean, median, RMSE, P95, final pre-correction error, drift per minute ve drift per travelled distance gerekli secondary veya diagnostic position-metric set'ini oluşturacaktır.)*

**The final denied-navigation error will always be captured before GNSS relocalization, preventing the recovery correction itself from hiding the position drift accumulated during the outage.** *(Final kesintili navigasyon hatası her zaman GNSS relocalization öncesinde yakalanacak ve recovery correction'ın kendisinin kesinti sırasında biriken position drift'i gizlemesi önlenecektir.)*

**Configurations A, B, C, and D will be scored with the same frozen evaluation pipeline, and matched replay sessions will be preferred so each configuration receives identical raw sensor, ARCore, timing, denial-boundary, and protected-reference evidence.** *(Configuration A, B, C ve D aynı frozen evaluation pipeline ile skorlanacak ve her configuration'ın aynı raw sensor, ARCore, timing, denial-boundary ve protected-reference evidence alması için matched replay session'lar tercih edilecektir.)*

**The single project-level primary research metric is aggregated matched-session median horizontal position error for Configuration D versus Configuration A, and the predeclared frozen target is at least a `20%` reduction for Configuration D relative to Configuration A. The target remains unmeasured until the final benchmark is completed.** *(Tek project-level primary research metric Configuration D ile Configuration A için aggregated matched-session median horizontal position error'dır ve predeclared frozen target Configuration D için Configuration A'ya göre en az `%20` reduction'dır. Target final benchmark tamamlanana kadar unmeasured kalır.)*

**Motion Classification will be evaluated primarily with held-out session-wise Macro F1, step detection with controlled step-count percentage error, ARCore with tracking availability and relative-motion diagnostics, recovery with pre-correction error and latency, and AI deployment with on-device median and P95 inference latency.** *(Motion Classification temel olarak held-out session-wise Macro F1 ile, step detection kontrollü step-count percentage error ile, ARCore tracking availability ve relative-motion diagnostics ile, recovery pre-correction error ve latency ile, AI deployment ise on-device median ve P95 inference latency ile değerlendirilecektir.)*

**Position uncertainty will be evaluated separately from position accuracy so NAVGUARD cannot appear trustworthy merely because covariance values are small, and statistical confidence labels will only be used when empirical calibration demonstrates that the uncertainty representation is consistent with observed errors.** *(Position uncertainty position accuracy'den ayrı değerlendirilecek, böylece NAVGUARD yalnızca covariance değerleri küçük olduğu için trustworthy görünemeyecek ve statistical confidence label'ları yalnızca empirical calibration uncertainty representation'ın observed error'larla tutarlı olduğunu gösterdiğinde kullanılacaktır.)*

**Primary benchmark aggregation will operate first at the physical-session level and then across matched sessions, preventing unusually long recordings from dominating the final result merely because they contain more timestamp samples.** *(Primary benchmark aggregation önce fiziksel session seviyesinde ve ardından matched session'lar arasında çalışacak, böylece olağandışı uzun recording'lerin yalnızca daha fazla timestamp sample içerdikleri için final sonuca hakim olması önlenecektir.)*

**Scientifically valid poor-performing sessions will remain in the benchmark, invalid sessions will be excluded only through frozen evidence-quality rules, unavailable metrics will remain explicitly unavailable, and every final number will remain traceable to a session, configuration, analysis version, and underlying evidence artifact.** *(Bilimsel olarak geçerli kötü performanslı session'lar benchmark içerisinde kalacak, invalid session'lar yalnızca frozen evidence-quality rule'ları üzerinden hariç tutulacak, unavailable metric'ler açık şekilde unavailable kalacak ve her final number session'a, configuration'a, analysis version'a ve underlying evidence artifact'a izlenebilir olacaktır.)*

---

# 328. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development Benchmark & Evaluation Metrics Specification Completed *(Doküman Durumu: Geliştirme Öncesi Benchmark ve Değerlendirme Metrikleri Spesifikasyonu Tamamlandı)*

**Primary Position Coordinate Frame:** ENU *(Temel Konum Koordinat Frame'i: ENU)*

**Primary Position Unit:** Metres *(Temel Konum Birimi: Metre)*

**Primary Instantaneous Error:** Horizontal Euclidean ENU Error *(Temel Anlık Hata: Yatay Euclidean ENU Hatası)*

**Core Position Metrics:** Mean + Median + RMSE + P95 + Final Error *(Temel Konum Metrikleri: Mean + Median + RMSE + P95 + Final Error)*

**Final Error Timing:** Pre-Correction Recovery Boundary *(Final Error Zamanı: Düzeltme Öncesi Recovery Boundary)*

**Post-Relocalization Position as Denied Final Error:** Forbidden *(Post-Relocalization Konumu Kesintili Final Error Olarak Kullanma: Yasak)*

**Drift Normalization:** Per Minute + Per Travel Distance *(Drift Normalization: Dakika Başına + Kat Edilen Mesafe Başına)*

**Distance Bias:** Signed + Absolute + Percentage *(Mesafe Bias'ı: Signed + Absolute + Percentage)*

**Closure Error:** Supported *(Closure Error: Destekleniyor)*

**Heading Error:** Circular *(Heading Hatası: Circular)*

**Heading Metrics:** MAE + RMSE when Reference Is Defensible *(Heading Metrikleri: Referans Savunulabilirse MAE + RMSE)*

**Primary Step Detector Metric:** Step Count Percentage Error *(Temel Step Detector Metriği: Adım Sayısı Yüzde Hatası)*

**Provisional Step Count Target:** ≤5% Absolute Error *(Geçici Adım Sayısı Hedefi: ≤%5 Absolute Error)*

**Per-Step Step-Length Metrics:** Only with Defensible Labels *(Per-Step Step-Length Metrikleri: Yalnızca Savunulabilir Label ile)*

**Route-Average Label as Exact Per-Step Truth:** Forbidden *(Route-Average Label'ı Exact Per-Step Truth Olarak Kullanma: Yasak)*

**Primary Motion AI Metric:** Macro F1 *(Temel Motion AI Metriği: Macro F1)*

**Provisional Motion AI Target:** ≥0.90 Macro F1 *(Geçici Motion AI Hedefi: ≥0.90 Macro F1)*

**AI Secondary Metric:** Accuracy *(AI İkincil Metriği: Accuracy)*

**AI Runtime Metrics:** Median Latency + P95 Latency *(AI Runtime Metrikleri: Median Latency + P95 Latency)*

**Provisional AI Latency Target:** <50 ms / Inference *(Geçici AI Latency Hedefi: <50 ms / Inference)*

**ARCore Primary Runtime Metric:** Tracking Availability *(ARCore Temel Runtime Metriği: Tracking Availability)*

**ARCore Absolute Global Position Metric:** Not Applicable *(ARCore Mutlak Global Konum Metriği: Uygulanmaz)*

**Recovery Error:** Pre-Correction Horizontal Error *(Recovery Hatası: Düzeltme Öncesi Yatay Hata)*

**Recovery Latency:** Validation + Relocalization + Total *(Recovery Latency: Validation + Relocalization + Total)*

**Ground Truth Firewall Metric:** Unauthorized GNSS Estimator Update Count *(Ground Truth Firewall Metriği: Unauthorized GNSS Estimator Update Count)*

**Required Firewall Value:** `0` *(Gerekli Firewall Değeri: `0`)*

**Firewall Violation:** Session / Interval Invalidating *(Firewall İhlali: Session / Interval Geçersizleştirici)*

**Uncertainty Evaluation:** Separate from Position Accuracy *(Uncertainty Değerlendirmesi: Position Accuracy'den Ayrı)*

**Formal Confidence Region Without Calibration:** Forbidden *(Calibration Olmadan Formal Confidence Region: Yasak)*

**NEES / NIS:** Advanced Diagnostic Candidates *(NEES / NIS: Gelişmiş Diagnostic Adayları)*

**Primary Comparison:** Configuration A vs D *(Temel Karşılaştırma: Configuration A vs D)*

**Formal Ablation Configurations:** A / B / C / D *(Resmî Ablation Yapılandırmaları: A / B / C / D)*

**Primary Aggregation Level:** Session First, Then Cross-Session *(Temel Aggregation Seviyesi: Önce Session, Sonra Cross-Session)*

**Globally Pooled Samples as Primary Benchmark:** Forbidden *(Globally Pooled Sample'ları Temel Benchmark Olarak Kullanma: Yasak)*

**Primary Improvement Formula:** Relative Reduction in Matched-Session Median Error *(Temel İyileştirme Formülü: Matched-Session Median Error'da Göreli Azalma)*

**Predeclared Frozen Primary Research Target:** ≥20% Aggregated Matched-Session Median Horizontal Position Error Reduction, Configuration D vs Configuration A *(Önceden Belirlenmiş Frozen Primary Research Hedefi: Configuration D vs Configuration A için ≥%20 Aggregated Matched-Session Median Horizontal Position Error Azalması)*

**Target Relaxation After Final Results:** Forbidden *(Final Sonuçlar Sonrası Hedef Gevşetme: Yasak)*

**Poor Valid Sessions:** Retained *(Kötü Geçerli Oturumlar: Korunur)*

**Invalid Sessions:** Excluded by Frozen Rules + Preserved *(Invalid Oturumlar: Frozen Rule ile Hariç + Korunur)*

**Unavailable Metric Filled with Zero:** Forbidden *(Unavailable Metric'i Sıfırla Doldurma: Yasak)*

**Metric Pipeline Versioning:** Mandatory *(Metric Pipeline Sürümleme: Zorunlu)*

**Primary Offline Analysis Environment:** Python *(Temel Offline Analysis Ortamı: Python)*

**Mobile Summary Metrics:** Supplementary *(Mobil Summary Metrics: Tamamlayıcı)*

**Metric Reproducibility:** Mandatory *(Metrik Tekrarlanabilirliği: Zorunlu)*

**Final Timestamp Alignment Tolerance:** Pending Pilot Evidence *(Nihai Timestamp Alignment Tolerance: Pilot Evidence Bekleniyor)*

**Final GNSS Reference Inclusion Thresholds:** Pending Field Calibration *(Nihai GNSS Reference Inclusion Threshold'ları: Saha Kalibrasyonu Bekleniyor)*

**Final Step Event Matching Tolerance:** Pending Annotation Validation *(Nihai Step Event Matching Tolerance: Annotation Validation Bekleniyor)*

**Final Step-Length Reference Granularity:** Pending Dataset Quality *(Nihai Step-Length Reference Granularity: Dataset Quality Bekleniyor)*

**Final Statistical Confidence Mapping:** Pending Covariance Calibration *(Nihai Statistical Confidence Mapping: Covariance Calibration Bekleniyor)*

**Optional Bootstrap Confidence Intervals:** Pending Final Sample Size *(İsteğe Bağlı Bootstrap Confidence Interval'lar: Final Sample Size Bekleniyor)*

**Optional Paired Significance Test:** Pending Final Matched Sample Count *(İsteğe Bağlı Paired Significance Test: Final Matched Sample Count Bekleniyor)*

**Next Documentation Item:** 36 — Performance, Battery & Resource Testing *(Sonraki Dokümantasyon Öğesi: 36 — Performans, Batarya ve Kaynak Testleri)*
