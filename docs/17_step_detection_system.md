# 17 — Step Detection System (Adım Tespit Sistemi)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the signal-processing architecture, candidate-step generation, peak-detection logic, adaptive threshold strategy, temporal validation, stationary suppression, walking and running handling, step-event representation, ground-truth labeling, evaluation metrics, fallback behavior, logging requirements, and acceptance criteria of the NAVGUARD Step Detection System. *(Bu doküman, NAVGUARD Adım Tespit Sisteminin sinyal işleme mimarisini, aday adım üretimini, peak tespit mantığını, adaptif eşik stratejisini, zamansal doğrulamayı, sabit durum bastırmasını, yürüme ve koşma yönetimini, adım olayı temsilini, gerçek referans etiketlemeyi, değerlendirme metriklerini, geri dönüş davranışını, kayıt gereksinimlerini ve kabul kriterlerini tanımlar.)*

The step detector converts continuous accelerometer measurements into discrete pedestrian step events that can drive the baseline PDR engine. *(Adım algılayıcı, sürekli ivmeölçer ölçümlerini temel PDR motorunu ilerletebilecek ayrık yaya adım olaylarına dönüştürür.)*

Reliable step detection is essential because every missed or falsely detected step directly affects estimated travelled distance and position. *(Güvenilir adım tespiti önemlidir çünkü kaçırılan veya yanlış tespit edilen her adım tahmini kat edilen mesafeyi ve konumu doğrudan etkiler.)*

---

# 2. Primary Step Detection Objective (Temel Adım Tespit Hedefi)

The primary objective is to identify real pedestrian steps from smartphone accelerometer measurements while minimizing false detections caused by non-step motion. *(Temel amaç, adım olmayan hareketlerden kaynaklanan yanlış tespitleri en aza indirirken akıllı telefon ivmeölçer ölçümlerinden gerçek yaya adımlarını belirlemektir.)*

The detector must operate online using only data available up to the current time. *(Algılayıcı yalnızca mevcut zamana kadar kullanılabilir veriyi kullanarak çevrimiçi çalışmalıdır.)*

The detector must remain functional without artificial intelligence. *(Algılayıcı yapay zekâ olmadan çalışabilir kalmalıdır.)*

---

# 3. Role in the NAVGUARD Pipeline (NAVGUARD Hattındaki Rolü)

The step detector sits between accelerometer preprocessing and PDR propagation. *(Adım algılayıcı ivmeölçer ön işleme ile PDR ilerletmesi arasında bulunur.)*

```
Accelerometer
     ↓
Preprocessing
     ↓
Step Signal
     ↓
Candidate Detection
     ↓
Candidate Validation
     ↓
Accepted Step Event
     ↓
PDR
```

Only accepted step events may trigger baseline PDR displacement. *(Yalnızca kabul edilmiş adım olayları temel PDR yer değiştirmesini tetikleyebilir.)*

---

# 4. Baseline Independence Principle (Temel Bağımsızlık İlkesi)

The baseline step detector will be deterministic and will not depend on the motion-classification neural network. *(Temel adım algılayıcı deterministik olacak ve hareket sınıflandırma sinir ağına bağımlı olmayacaktır.)*

Artificial intelligence may later improve context awareness, but failure of AI must not disable step detection. *(Yapay zekâ daha sonra bağlam farkındalığını iyileştirebilir ancak yapay zekânın başarısız olması adım tespitini devre dışı bırakmamalıdır.)*

---

# 5. Primary Sensor Source (Temel Sensör Kaynağı)

The authoritative physical input for baseline step detection will be the Android accelerometer stream acquired through the native sensor layer. *(Temel adım tespiti için ana fiziksel girdi native sensör katmanı üzerinden elde edilen Android ivmeölçer akışı olacaktır.)*

The detector will consume timestamped processed acceleration rather than Flutter UI values. *(Algılayıcı Flutter UI değerleri yerine zaman damgalı işlenmiş ivme verisini kullanacaktır.)*

---

# 6. Accelerometer Vector (İvmeölçer Vektörü)

Each raw accelerometer observation is represented as follows. *(Her ham ivmeölçer gözlemi aşağıdaki şekilde temsil edilir.)*

```
aᴰ =
[a_x, a_y, a_z]ᵀ
```

The values remain expressed in the Android device frame before optional coordinate transformation. *(Değerler isteğe bağlı koordinat dönüşümünden önce Android cihaz çerçevesinde ifade edilmiş olarak kalır.)*

---

# 7. Acceleration Magnitude (İvme Büyüklüğü)

The primary baseline step signal candidate will be acceleration magnitude. *(Temel adım sinyali için birincil aday ivme büyüklüğü olacaktır.)*

```
|a| =
√(a_x² + a_y² + a_z²)
```

Acceleration magnitude reduces dependence on the instantaneous orientation of the phone relative to its own axes. *(İvme büyüklüğü telefonun kendi eksenlerine göre anlık yönelimine olan bağımlılığı azaltır.)*

---

# 8. Magnitude Is Not Completely Orientation Independent (Büyüklük Tamamen Yönelimden Bağımsız Değildir)

Using acceleration magnitude removes direct axis selection but does not eliminate every phone-placement effect. *(İvme büyüklüğünün kullanılması doğrudan eksen seçimini ortadan kaldırır ancak tüm telefon yerleşimi etkilerini ortadan kaldırmaz.)*

Different carrying styles can still change the shape and amplitude of the measured walking signal. *(Farklı taşıma biçimleri ölçülen yürüyüş sinyalinin şeklini ve genliğini yine de değiştirebilir.)*

Formal experiments will therefore use a controlled phone-placement protocol. *(Bu nedenle resmî deneyler kontrollü bir telefon yerleşim protokolü kullanacaktır.)*

---

# 9. Gravity Contribution (Yerçekimi Katkısı)

Raw acceleration magnitude contains the effect of gravity. *(Ham ivme büyüklüğü yerçekimi etkisini içerir.)*

A stationary device therefore produces a magnitude close to gravitational acceleration rather than a value near zero. *(Bu nedenle sabit bir cihaz sıfıra yakın bir değer yerine yerçekimi ivmesine yakın bir büyüklük üretir.)*

The step detector must account for this baseline before detecting walking oscillations. *(Adım algılayıcı yürüyüş salınımlarını tespit etmeden önce bu temel seviyeyi dikkate almalıdır.)*

---

# 10. Gravity-Centered Magnitude Candidate (Yerçekimi Merkezli Büyüklük Adayı)

A simple derived signal may subtract an estimated gravity magnitude from acceleration magnitude. *(Basit bir türetilmiş sinyal ivme büyüklüğünden tahmini yerçekimi büyüklüğünü çıkarabilir.)*

```
s_k =
|a_k| - g_est
```

The exact gravity estimate will depend on the preprocessing strategy selected in **13 — Sensor Timing, Synchronization & Preprocessing**. *(Kesin yerçekimi tahmini **13 — Sensor Timing, Synchronization & Preprocessing** içerisinde seçilen ön işleme stratejisine bağlı olacaktır.)*

---

# 11. Mean-Centered Step Signal Candidate (Ortalama Merkezli Adım Sinyali Adayı)

A short-term local baseline may alternatively be removed from the acceleration magnitude. *(Alternatif olarak ivme büyüklüğünden kısa süreli yerel bir temel seviye çıkarılabilir.)*

```
s_k =
|a_k| - baseline_k
```

The baseline may be produced by a low-pass or moving-average component if experiments demonstrate suitable behavior. *(Deneyler uygun davranış gösterirse temel seviye low-pass veya hareketli ortalama bileşeni tarafından üretilebilir.)*

---

# 12. Step Signal Selection Policy (Adım Sinyali Seçim Politikası)

Multiple candidate step signals may be compared during pilot analysis. *(Pilot analiz sırasında birden fazla aday adım sinyali karşılaştırılabilir.)*

Candidates may include filtered acceleration magnitude, gravity-centered magnitude, linear-acceleration magnitude, or selected world-frame components. *(Adaylar filtrelenmiş ivme büyüklüğünü, yerçekimi merkezli büyüklüğü, doğrusal ivme büyüklüğünü veya seçilen dünya çerçevesi bileşenlerini içerebilir.)*

The final signal will be selected using measured step-detection performance rather than visual appearance alone. *(Nihai sinyal yalnızca görsel görünüm yerine ölçülen adım tespit performansı kullanılarak seçilecektir.)*

---

# 13. Baseline Signal Preference (Temel Sinyal Tercihi)

Filtered acceleration magnitude will be the initial baseline candidate because it provides a simple orientation-robust input for controlled phone placement. *(Filtrelenmiş ivme büyüklüğü kontrollü telefon yerleşimi için basit ve yönelime dayanıklı bir girdi sağladığından ilk temel aday olacaktır.)*

This choice remains provisional until the Redmi Note 9 Pro walking recordings are inspected. *(Bu seçim Redmi Note 9 Pro yürüyüş kayıtları incelenene kadar geçici kalacaktır.)*

---

# 14. Step Detection Processing Pipeline (Adım Tespit İşleme Hattı)

```
Raw Accelerometer
      ↓
Timestamp Validation
      ↓
Acceleration Magnitude
      ↓
Noise Filtering
      ↓
Baseline / Gravity Handling
      ↓
Candidate Peak Detection
      ↓
Adaptive Threshold Validation
      ↓
Temporal Validation
      ↓
Motion / Stationary Validation
      ↓
Accepted Step Event
```

Each stage will produce derived data while the original accelerometer measurements remain unchanged. *(Her aşama türetilmiş veri üretecek ve orijinal ivmeölçer ölçümleri değişmeden kalacaktır.)*

---

# 15. Filtering Objective (Filtreleme Hedefi)

The step-detection filter will suppress unwanted sensor noise while preserving the temporal structure of pedestrian steps. *(Adım tespit filtresi yaya adımlarının zamansal yapısını korurken istenmeyen sensör gürültüsünü bastıracaktır.)*

The filter must not smooth the signal so aggressively that neighboring steps merge into one event. *(Filtre sinyali komşu adımların tek bir olaya birleşeceği kadar agresif şekilde yumuşatmamalıdır.)*

---

# 16. Initial Filter Candidates (İlk Filtre Adayları)

Candidate filters may include a moving average, a first-order low-pass filter, or a lightweight Butterworth-style filter. *(Aday filtreler hareketli ortalamayı, birinci derece low-pass filtreyi veya hafif bir Butterworth tarzı filtreyi içerebilir.)*

The final filter will be selected after frequency and time-domain analysis of recorded stationary, walking, and running signals. *(Nihai filtre kaydedilmiş sabit, yürüyüş ve koşu sinyallerinin frekans ve zaman alanı analizinden sonra seçilecektir.)*

---

# 17. Real-Time Filter Requirement (Gerçek Zamanlı Filtre Gereksinimi)

The filter used by live step detection must be implementable online without using future samples. *(Canlı adım tespiti tarafından kullanılan filtre gelecekteki örnekleri kullanmadan çevrimiçi uygulanabilir olmalıdır.)*

Zero-phase offline filtering may be used for diagnostic comparison but will not represent the real-time detector. *(Zero-phase çevrimdışı filtreleme tanısal karşılaştırma için kullanılabilir ancak gerçek zamanlı algılayıcıyı temsil etmeyecektir.)*

---

# 18. Filter Parameter Policy (Filtre Parametresi Politikası)

Cutoff frequency or smoothing-window length will not be fixed before physical data is analyzed. *(Cutoff frekansı veya yumuşatma pencere uzunluğu fiziksel veri analiz edilmeden sabitlenmeyecektir.)*

The chosen parameter must preserve walking and running step peaks while reducing stationary noise. *(Seçilen parametre sabit durum gürültüsünü azaltırken yürüyüş ve koşu adım peak’lerini korumalıdır.)*

---

# 19. Effective Sampling Rate Dependency (Etkin Örnekleme Hızı Bağımlılığı)

Filter coefficients will be derived using the measured effective sampling configuration. *(Filtre katsayıları ölçülen etkin örnekleme yapılandırması kullanılarak türetilecektir.)*

The detector will not assume that the sensor produces exactly 50 samples every second merely because approximately 50 Hz was requested. *(Algılayıcı yalnızca yaklaşık 50 Hz talep edildiği için sensörün her saniye tam olarak 50 örnek ürettiğini varsaymayacaktır.)*

---

# 20. Peak-Based Detection Principle (Peak Tabanlı Tespit İlkesi)

The baseline detector will initially use peak-based candidate generation on the processed step signal. *(Temel algılayıcı başlangıçta işlenmiş adım sinyali üzerinde peak tabanlı aday üretimi kullanacaktır.)*

A local maximum becomes a candidate only when it satisfies configured signal conditions. *(Bir yerel maksimum yalnızca yapılandırılmış sinyal koşullarını karşıladığında aday haline gelir.)*

---

# 21. Local Maximum Definition (Yerel Maksimum Tanımı)

For a simple three-sample example, a local peak candidate may satisfy the following relation. *(Basit üç örnekli bir örnek için yerel peak adayı aşağıdaki ilişkiyi karşılayabilir.)*

```
s_(k-1) < s_k
and
s_k ≥ s_(k+1)
```

The actual detector may use a larger neighborhood or state-machine logic for better noise robustness. *(Gerçek algılayıcı daha iyi gürültü dayanıklılığı için daha büyük bir komşuluk veya durum makinesi mantığı kullanabilir.)*

---

# 22. Peak Confirmation Delay (Peak Doğrulama Gecikmesi)

A local maximum cannot be confirmed until enough later samples arrive to show that the signal has begun decreasing. *(Bir yerel maksimum sinyalin azalmaya başladığını gösterecek kadar sonraki örnek ulaşana kadar doğrulanamaz.)*

The resulting detection latency must be bounded and measured. *(Ortaya çıkan tespit gecikmesi sınırlı ve ölçülmüş olmalıdır.)*

---

# 23. Threshold Requirement (Eşik Gereksinimi)

A local maximum alone is insufficient because sensor noise can create many small peaks. *(Yerel maksimum tek başına yeterli değildir çünkü sensör gürültüsü birçok küçük peak oluşturabilir.)*

A candidate peak must exceed a minimum signal threshold or satisfy an equivalent prominence condition. *(Bir aday peak minimum sinyal eşiğini aşmalı veya eşdeğer bir prominence koşulunu karşılamalıdır.)*

---

# 24. Static Threshold Baseline (Sabit Eşik Temel Yöntemi)

A simple first implementation may use a static threshold. *(Basit bir ilk uygulama sabit bir eşik kullanabilir.)*

```
candidate if
peakValue > T_static
```

The static threshold will be calibrated from recorded data rather than guessed arbitrarily. *(Sabit eşik keyfi olarak tahmin edilmek yerine kaydedilmiş veriden kalibre edilecektir.)*

---

# 25. Static Threshold Limitation (Sabit Eşik Sınırlaması)

A single fixed threshold may perform poorly when walking intensity, running intensity, phone orientation, or user movement amplitude changes. *(Tek bir sabit eşik yürüyüş şiddeti, koşu şiddeti, telefon yönelimi veya kullanıcı hareket genliği değiştiğinde kötü performans gösterebilir.)*

NAVGUARD will therefore evaluate an adaptive threshold as the target deterministic approach. *(Bu nedenle NAVGUARD hedef deterministik yaklaşım olarak adaptif bir eşiği değerlendirecektir.)*

---

# 26. Adaptive Threshold Concept (Adaptif Eşik Kavramı)

An adaptive threshold changes according to recent signal statistics. *(Adaptif eşik son sinyal istatistiklerine göre değişir.)*

A generic candidate formulation may use a local baseline plus a scaled variability term. *(Genel bir aday formülasyon yerel temel seviye ile ölçeklenmiş değişkenlik terimi kullanabilir.)*

```
T_k =
μ_window + α · σ_window
```

`μ_window` represents the recent signal mean. *(`μ_window`, son sinyal ortalamasını temsil eder.)*

`σ_window` represents recent signal variability. *(`σ_window`, son sinyal değişkenliğini temsil eder.)*

`α` is a tunable sensitivity coefficient. *(`α`, ayarlanabilir bir hassasiyet katsayısıdır.)*

---

# 27. Adaptive Threshold Alternative (Adaptif Eşik Alternatifi)

Another candidate may use recent local minimum and maximum amplitudes. *(Başka bir aday son yerel minimum ve maksimum genlikleri kullanabilir.)*

```
T_k =
s_min +
β(s_max - s_min)
```

The exact adaptive formulation will be selected through validation experiments. *(Kesin adaptif formülasyon doğrulama deneyleri üzerinden seçilecektir.)*

---

# 28. No Arbitrary Threshold Freeze (Keyfi Eşik Sabitleme Olmaması)

No numerical peak threshold will be frozen before Redmi Note 9 Pro data is collected. *(Redmi Note 9 Pro verisi toplanmadan hiçbir sayısal peak eşiği sabitlenmeyecektir.)*

Thresholds selected during development will be treated as provisional until validation results are available. *(Geliştirme sırasında seçilen eşikler doğrulama sonuçları mevcut olana kadar geçici kabul edilecektir.)*

---

# 29. Peak Prominence (Peak Belirginliği)

NAVGUARD may evaluate peak prominence in addition to absolute peak height. *(NAVGUARD mutlak peak yüksekliğine ek olarak peak prominence değerini değerlendirebilir.)*

Prominence describes how strongly a peak rises relative to its surrounding local baseline. *(Prominence bir peak’in çevresindeki yerel temel seviyeye göre ne kadar güçlü yükseldiğini açıklar.)*

This may help reject small high-frequency noise peaks. *(Bu küçük yüksek frekanslı gürültü peak’lerini reddetmeye yardımcı olabilir.)*

---

# 30. Minimum Peak Width Candidate (Minimum Peak Genişliği Adayı)

A minimum temporal peak-width condition may be evaluated if noise produces extremely narrow spikes. *(Gürültü son derece dar sıçramalar üretiyorsa minimum zamansal peak genişliği koşulu değerlendirilebilir.)*

The requirement will be retained only if real recordings show measurable benefit. *(Gereksinim yalnızca gerçek kayıtlar ölçülebilir fayda gösterirse korunacaktır.)*

---

# 31. Temporal Validation Principle (Zamansal Doğrulama İlkesi)

Human steps cannot occur at arbitrarily small time intervals. *(İnsan adımları keyfi derecede küçük zaman aralıklarında gerçekleşemez.)*

The detector will therefore apply a minimum accepted time between consecutive navigation steps. *(Bu nedenle algılayıcı ardışık navigasyon adımları arasında minimum kabul edilen bir süre uygulayacaktır.)*

---

# 32. Refractory Period (Refractory Süresi)

After accepting a step, the detector will temporarily reject additional candidate peaks that occur within the configured refractory interval. *(Bir adım kabul edildikten sonra algılayıcı yapılandırılmış refractory aralığı içerisinde meydana gelen ek aday peak’leri geçici olarak reddedecektir.)*

```
accept candidate only if

t_candidate - t_lastStep
≥
T_refractory
```

This prevents one physical step from being counted multiple times because of oscillatory sub-peaks. *(Bu salınımlı alt peak’ler nedeniyle tek bir fiziksel adımın birden fazla sayılmasını önler.)*

---

# 33. Refractory Period Must Support Running (Refractory Süresi Koşmayı Desteklemelidir)

A refractory interval that works for normal walking may be too long for running. *(Normal yürüyüş için çalışan bir refractory aralığı koşma için fazla uzun olabilir.)*

The final detector may therefore use motion-dependent or cadence-adaptive temporal limits. *(Bu nedenle nihai algılayıcı harekete bağlı veya kadans adaptif zamansal sınırlar kullanabilir.)*

---

# 34. Minimum Step Interval Policy (Minimum Adım Aralığı Politikası)

No fixed minimum step interval will be invented before walking and running sessions are analyzed. *(Yürüyüş ve koşu oturumları analiz edilmeden sabit minimum adım aralığı uydurulmayacaktır.)*

The selected interval must suppress duplicate detections without discarding legitimate fast steps. *(Seçilen aralık geçerli hızlı adımları atmadan yinelenen tespitleri bastırmalıdır.)*

---

# 35. Maximum Step Interval (Maksimum Adım Aralığı)

A maximum interval may be used when estimating active cadence or determining whether a previous walking sequence has ended. *(Aktif kadansı tahmin ederken veya önceki bir yürüyüş dizisinin bitip bitmediğini belirlerken maksimum bir aralık kullanılabilir.)*

A long interval without accepted steps may transition the detector toward a stationary or waiting state. *(Kabul edilmiş adım olmadan uzun bir aralık algılayıcının sabit veya bekleme durumuna geçmesine neden olabilir.)*

---

# 36. Cadence Definition (Kadans Tanımı)

Cadence represents step frequency over time. *(Kadans zaman içerisindeki adım frekansını temsil eder.)*

A simple instantaneous estimate may be calculated from consecutive accepted steps. *(Basit bir anlık tahmin ardışık kabul edilmiş adımlardan hesaplanabilir.)*

```
cadenceHz =
1 /
(t_k - t_(k-1))
```

A smoothed cadence will generally be more stable than a single interval estimate. *(Yumuşatılmış kadans genellikle tek aralık tahmininden daha kararlı olacaktır.)*

---

# 37. Cadence Use (Kadans Kullanımı)

Cadence may help distinguish plausible walking or running rhythm from isolated random movement. *(Kadans makul yürüyüş veya koşu ritmini izole rastgele hareketten ayırt etmeye yardımcı olabilir.)*

Cadence may also become a feature for step-length estimation. *(Kadans ayrıca adım uzunluğu tahmini için bir özellik haline gelebilir.)*

---

# 38. Cadence Is Not the Primary Step Detector (Kadans Temel Adım Algılayıcı Değildir)

Cadence is derived from previously accepted steps and cannot independently prove that a new candidate is a real step. *(Kadans daha önce kabul edilmiş adımlardan türetilir ve yeni bir adayın gerçek adım olduğunu bağımsız olarak kanıtlayamaz.)*

It will therefore be used as supporting temporal evidence rather than as the sole detection rule. *(Bu nedenle tek tespit kuralı yerine destekleyici zamansal kanıt olarak kullanılacaktır.)*

---

# 39. Step Detector State Machine (Adım Algılayıcı Durum Makinesi)

The deterministic detector may use a small state machine. *(Deterministik algılayıcı küçük bir durum makinesi kullanabilir.)*

```
WAITING
   ↓
RISING
   ↓
PEAK_CANDIDATE
   ↓
FALLING
   ↓
VALIDATE
   ↓
ACCEPTED / REJECTED
```

The exact implementation may differ while preserving equivalent behavior. *(Kesin uygulama eşdeğer davranışı korurken farklı olabilir.)*

---

# 40. WAITING State (WAITING Durumu)

In `WAITING`, the detector observes the processed signal for sufficient evidence of a rising step waveform. *(`WAITING` durumunda algılayıcı işlenmiş sinyali yükselen bir adım dalga biçimine ilişkin yeterli kanıt açısından gözlemler.)*

Noise around the baseline should not immediately create candidates. *(Temel seviye çevresindeki gürültü hemen aday oluşturmamalıdır.)*

---

# 41. RISING State (RISING Durumu)

`RISING` indicates that the signal has crossed the candidate activation level and continues toward a possible local maximum. *(`RISING`, sinyalin aday aktivasyon seviyesini geçtiğini ve olası yerel maksimuma doğru devam ettiğini gösterir.)*

The detector stores candidate peak information while the signal rises. *(Algılayıcı sinyal yükselirken aday peak bilgisini saklar.)*

---

# 42. PEAK_CANDIDATE State (PEAK_CANDIDATE Durumu)

A candidate peak is identified after a local maximum becomes observable. *(Yerel maksimum gözlemlenebilir hale geldikten sonra aday peak tanımlanır.)*

The event has not yet become an accepted navigation step. *(Olay henüz kabul edilmiş bir navigasyon adımı haline gelmemiştir.)*

---

# 43. FALLING State (FALLING Durumu)

The falling portion of the waveform provides evidence that a genuine peak has occurred rather than a temporary noisy fluctuation. *(Dalga biçiminin düşen kısmı geçici gürültülü dalgalanma yerine gerçek bir peak oluştuğuna dair kanıt sağlar.)*

Optional valley or amplitude-range information may also be collected at this stage. *(Bu aşamada isteğe bağlı valley veya genlik aralığı bilgisi de toplanabilir.)*

---

# 44. VALIDATE State (VALIDATE Durumu)

The candidate will be evaluated against amplitude, time, motion, signal-quality, and duplication rules. *(Aday genlik, zaman, hareket, sinyal kalitesi ve yinelenme kurallarına karşı değerlendirilecektir.)*

Only candidates passing the required rules become accepted steps. *(Yalnızca gerekli kuralları geçen adaylar kabul edilmiş adım haline gelir.)*

---

# 45. Candidate Validation Inputs (Aday Doğrulama Girdileri)

Candidate validation may use peak height. *(Aday doğrulama peak yüksekliğini kullanabilir.)*

Candidate validation may use prominence. *(Aday doğrulama prominence kullanabilir.)*

Candidate validation may use time since the previous accepted step. *(Aday doğrulama önceki kabul edilmiş adımdan itibaren geçen süreyi kullanabilir.)*

Candidate validation may use recent signal variance. *(Aday doğrulama son sinyal varyansını kullanabilir.)*

Candidate validation may use motion-state evidence. *(Aday doğrulama hareket durumu kanıtını kullanabilir.)*

Candidate validation may use sensor-quality information. *(Aday doğrulama sensör kalite bilgisini kullanabilir.)*

---

# 46. Candidate Rejection Reasons (Aday Red Nedenleri)

```
BELOW_THRESHOLD
LOW_PROMINENCE
WITHIN_REFRACTORY_PERIOD
STATIONARY_SUPPRESSION
INVALID_SIGNAL
TIMING_GAP
DUPLICATE_EVENT
MOTION_INCONSISTENT
```

Every rejection reason may be recorded during development or diagnostic sessions. *(Her red nedeni geliştirme veya tanısal oturumlar sırasında kaydedilebilir.)*

---

# 47. Stationary False Positive Suppression (Sabit Durum Yanlış Pozitif Bastırma)

The detector must strongly suppress step events when the phone is stationary. *(Algılayıcı telefon sabitken adım olaylarını güçlü şekilde bastırmalıdır.)*

Stationary false positives are especially damaging because they produce movement from a physically stationary state. *(Sabit durum yanlış pozitifleri özellikle zararlıdır çünkü fiziksel olarak sabit bir durumdan hareket üretirler.)*

---

# 48. Stationary Signal Statistics (Sabit Durum Sinyal İstatistikleri)

Stationary recordings will be used to characterize accelerometer magnitude noise and short-term variance. *(Sabit durum kayıtları ivme büyüklüğü gürültüsünü ve kısa süreli varyansı karakterize etmek için kullanılacaktır.)*

These statistics will help determine whether a candidate peak is meaningfully larger than normal stationary noise. *(Bu istatistikler bir aday peak’in normal sabit durum gürültüsünden anlamlı şekilde daha büyük olup olmadığını belirlemeye yardımcı olacaktır.)*

---

# 49. Stationary Detector Candidate (Sabit Durum Algılayıcı Adayı)

A deterministic stationary condition may use low recent acceleration variance and low gyroscope activity. *(Deterministik bir sabit durum koşulu düşük son ivme varyansı ve düşük jiroskop aktivitesi kullanabilir.)*

The exact thresholds will be determined experimentally. *(Kesin eşikler deneysel olarak belirlenecektir.)*

---

# 50. Gyroscope as Supporting Evidence (Destekleyici Kanıt Olarak Jiroskop)

The baseline step detector may use gyroscope activity as supporting motion evidence without making gyroscope a mandatory primary step signal. *(Temel adım algılayıcı jiroskobu zorunlu temel adım sinyali haline getirmeden jiroskop aktivitesini destekleyici hareket kanıtı olarak kullanabilir.)*

This may help reject accelerometer disturbances caused by handling the phone while standing still. *(Bu, sabit dururken telefonu elle hareket ettirmekten kaynaklanan ivmeölçer bozulmalarını reddetmeye yardımcı olabilir.)*

---

# 51. Stationary AI Assistance (Sabit Durum Yapay Zekâ Desteği)

The motion classifier may later provide a `STATIONARY` prediction. *(Hareket sınıflandırıcı daha sonra bir `STATIONARY` tahmini sağlayabilir.)*

This prediction may strengthen step suppression but will not become the sole stationary gate. *(Bu tahmin adım bastırmayı güçlendirebilir ancak tek sabit durum kapısı haline gelmeyecektir.)*

---

# 52. Walking Mode (Yürüme Modu)

During ordinary walking, the detector will use its standard threshold and timing configuration. *(Normal yürüyüş sırasında algılayıcı standart eşik ve zamanlama yapılandırmasını kullanacaktır.)*

The goal is to detect each physical step once and only once. *(Amaç her fiziksel adımı bir kez ve yalnızca bir kez tespit etmektir.)*

---

# 53. Running Mode (Koşma Modu)

Running may produce larger accelerations and shorter intervals between steps. *(Koşma daha büyük ivmeler ve adımlar arasında daha kısa aralıklar üretebilir.)*

The final detector may therefore use running-specific temporal or amplitude parameters. *(Bu nedenle nihai algılayıcı koşmaya özgü zamansal veya genlik parametreleri kullanabilir.)*

---

# 54. Running Mode Activation (Koşma Modu Aktivasyonu)

Running context may be inferred from deterministic cadence and signal features. *(Koşma bağlamı deterministik kadans ve sinyal özelliklerinden çıkarılabilir.)*

The AI motion classifier may additionally provide supporting `RUNNING` information. *(Yapay zekâ hareket sınıflandırıcı ayrıca destekleyici `RUNNING` bilgisi sağlayabilir.)*

Baseline running detection must still have a deterministic fallback. *(Temel koşma tespiti yine de deterministik bir geri dönüşe sahip olmalıdır.)*

---

# 55. Walking-to-Running Transition (Yürümeden Koşmaya Geçiş)

The detector must avoid losing several legitimate steps merely because the temporal rhythm changes during a walking-to-running transition. *(Algılayıcı yürümeden koşmaya geçiş sırasında zamansal ritim değiştiği için birden fazla geçerli adımı kaçırmamalıdır.)*

Adaptive timing rules may therefore change gradually rather than switch based on one isolated interval. *(Bu nedenle adaptif zamanlama kuralları tek bir izole aralığa göre değişmek yerine kademeli olarak değişebilir.)*

---

# 56. Running-to-Walking Transition (Koşmadan Yürümeye Geçiş)

The detector must also recover from fast running cadence back to normal walking cadence without generating artificial steps. *(Algılayıcı hızlı koşma kadansından normal yürüyüş kadansına yapay adımlar oluşturmadan geri dönebilmelidir.)*

---

# 57. Turning and Step Detection (Dönüş ve Adım Tespiti)

A pedestrian may continue taking steps while turning. *(Bir yaya dönerken adım atmaya devam edebilir.)*

The detector should therefore not suppress every acceleration pattern merely because angular velocity is elevated. *(Bu nedenle algılayıcı yalnızca açısal hız yükseldiği için her ivme örüntüsünü bastırmamalıdır.)*

Turning information is primarily a heading context rather than an automatic step rejection condition. *(Dönüş bilgisi otomatik adım red koşulundan ziyade temel olarak yön bağlamıdır.)*

---

# 58. Walk-Stop-Walk Transition (Yürü-Dur-Yürü Geçişi)

When walking stops, the detector should stop accepting steps after the final physical step. *(Yürüyüş durduğunda algılayıcı son fiziksel adımdan sonra adım kabul etmeyi durdurmalıdır.)*

When walking resumes, the detector should recover without requiring a full navigation reset. *(Yürüyüş yeniden başladığında algılayıcı tam navigasyon sıfırlaması gerektirmeden devam edebilmelidir.)*

---

# 59. Phone Handling Disturbances (Telefon Elle Hareket Ettirme Bozulmaları)

The user may rotate, tilt, raise, lower, or reposition the phone without actually walking. *(Kullanıcı gerçekten yürümeden telefonu döndürebilir, eğebilir, kaldırabilir, indirebilir veya yeniden konumlandırabilir.)*

Such motions can create large accelerometer peaks. *(Bu hareketler büyük ivmeölçer peak’leri oluşturabilir.)*

The detector must be tested specifically against non-step handling motions. *(Algılayıcı özellikle adım olmayan elle hareket ettirme hareketlerine karşı test edilmelidir.)*

---

# 60. Non-Step Motion Test Set (Adım Olmayan Hareket Test Seti)

Candidate non-step tests may include lifting the phone while standing. *(Aday adım olmayan testler sabit dururken telefonu kaldırmayı içerebilir.)*

Candidate non-step tests may include rotating the phone while standing. *(Aday adım olmayan testler sabit dururken telefonu döndürmeyi içerebilir.)*

Candidate non-step tests may include small arm movements while standing. *(Aday adım olmayan testler sabit dururken küçük kol hareketlerini içerebilir.)*

Candidate non-step tests may include placing the phone on a table. *(Aday adım olmayan testler telefonu masaya koymayı içerebilir.)*

Candidate non-step tests may include picking the phone up from a table. *(Aday adım olmayan testler telefonu masadan almayı içerebilir.)*

---

# 61. Impact Events (Darbe Olayları)

A short external impact can create an acceleration peak larger than a normal step. *(Kısa bir dış darbe normal bir adımdan daha büyük ivme peak’i oluşturabilir.)*

Peak height alone must therefore not guarantee step acceptance. *(Bu nedenle peak yüksekliği tek başına adım kabulünü garanti etmemelidir.)*

Temporal shape and movement context may be required to reject such events. *(Bu tür olayları reddetmek için zamansal şekil ve hareket bağlamı gerekebilir.)*

---

# 62. Signal Clipping Awareness (Sinyal Kırpılması Farkındalığı)

The Device Capability Audit will determine the available accelerometer range and whether high-intensity motion approaches sensor limits. *(Cihaz Yetenek Denetimi mevcut ivmeölçer aralığını ve yüksek şiddetli hareketin sensör sınırlarına yaklaşıp yaklaşmadığını belirleyecektir.)*

A clipped signal must not be interpreted as an ordinary high-quality step waveform. *(Kırpılmış bir sinyal normal yüksek kaliteli adım dalga biçimi olarak yorumlanmamalıdır.)*

---

# 63. Timing Gap Handling (Zamanlama Boşluğu Yönetimi)

A candidate spanning a large accelerometer timing gap may not contain enough information for reliable step detection. *(Büyük bir ivmeölçer zamanlama boşluğunu kapsayan aday güvenilir adım tespiti için yeterli bilgi içermeyebilir.)*

The detector may reject candidates near excessive gaps or lower their quality. *(Algılayıcı aşırı boşlukların yakınındaki adayları reddedebilir veya kalitelerini düşürebilir.)*

---

# 64. Filter Reset After Large Gap (Büyük Boşluktan Sonra Filtre Sıfırlama)

If the preprocessing filter is reset after a large timing gap, the step detector must be informed that the signal context has been interrupted. *(Ön işleme filtresi büyük bir zamanlama boşluğundan sonra sıfırlanırsa adım algılayıcı sinyal bağlamının kesildiği konusunda bilgilendirilmelidir.)*

A transient created by filter reinitialization must not become a false step. *(Filtre yeniden başlatmasından oluşan geçici sinyal yanlış bir adım haline gelmemelidir.)*

---

# 65. Step Event Timestamp Definition (Adım Olayı Zaman Damgası Tanımı)

The authoritative step timestamp will correspond to the accepted peak or another explicitly defined waveform reference point. *(Ana adım zaman damgası kabul edilen peak’e veya açıkça tanımlanmış başka bir dalga biçimi referans noktasına karşılık gelecektir.)*

The same convention must be used in live detection, offline replay, and evaluation. *(Aynı kural canlı tespit, çevrimdışı replay ve değerlendirmede kullanılmalıdır.)*

---

# 66. Detection Timestamp Versus Confirmation Timestamp (Tespit Zamanı ile Doğrulama Zamanı)

The physical step-event timestamp and the time at which the detector confirms the event may differ. *(Fiziksel adım olayı zaman damgası ile algılayıcının olayı doğruladığı zaman farklı olabilir.)*

Both values may be retained for latency analysis. *(Her iki değer gecikme analizi için korunabilir.)*

```
stepEventTimestampNs
confirmationTimestampNs
```

---

# 67. Detection Latency (Tespit Gecikmesi)

Step-detection latency may be calculated as follows. *(Adım tespit gecikmesi aşağıdaki şekilde hesaplanabilir.)*

```
latency =
confirmationTimestamp
-
stepEventTimestamp
```

The final detector will balance reliable peak confirmation against low navigation latency. *(Nihai algılayıcı güvenilir peak doğrulama ile düşük navigasyon gecikmesi arasında denge kuracaktır.)*

---

# 68. Accepted Step Event Model (Kabul Edilmiş Adım Olay Modeli)

```
AcceptedStepEvent
- eventId
- eventTimestampNs
- confirmationTimestampNs
- stepIndex
- peakValue
- prominence
- signalRange
- cadenceHz
- detectionConfidence
- motionContext
- detectorVersion
```

Fields not used by the final detector may be omitted from the production model while remaining available in research logs. *(Nihai algılayıcı tarafından kullanılmayan alanlar araştırma kayıtlarında kullanılabilir kalırken üretim modelinden çıkarılabilir.)*

---

# 69. Unique Step Identity (Benzersiz Adım Kimliği)

Every accepted step will have a unique event identifier within the session. *(Kabul edilen her adım oturum içerisinde benzersiz bir olay tanımlayıcısına sahip olacaktır.)*

This prevents accidental duplicate propagation into PDR. *(Bu PDR’ye yanlışlıkla yinelenen ilerletmeyi önler.)*

---

# 70. Step Sequence Number (Adım Sıra Numarası)

Accepted steps will receive monotonically increasing sequence numbers. *(Kabul edilen adımlar monotonik olarak artan sıra numaraları alacaktır.)*

Rejected candidates will not increment the accepted navigation-step counter. *(Reddedilen adaylar kabul edilmiş navigasyon adım sayacını artırmayacaktır.)*

---

# 71. Candidate Event Logging (Aday Olay Kaydı)

Development builds may log both accepted and rejected candidate peaks. *(Geliştirme build’leri hem kabul edilen hem de reddedilen aday peak’leri kaydedebilir.)*

This provides evidence for threshold tuning and false-positive analysis. *(Bu eşik ayarı ve yanlış pozitif analizi için kanıt sağlar.)*

---

# 72. Production Logging Reduction (Üretim Kayıt Azaltımı)

The final app may reduce detailed rejected-candidate logging if it creates unnecessary storage or processing overhead. *(Nihai uygulama gereksiz depolama veya işleme yükü oluşturuyorsa ayrıntılı reddedilmiş aday kaydını azaltabilir.)*

Formal research sessions should retain enough information to reproduce step-detector behavior. *(Resmî araştırma oturumları adım algılayıcı davranışını yeniden üretmek için yeterli bilgiyi korumalıdır.)*

---

# 73. Step Detector Configuration (Adım Algılayıcı Yapılandırması)

A frozen detector configuration may contain the following fields. *(Sabitlenmiş bir algılayıcı yapılandırması aşağıdaki alanları içerebilir.)*

```
detectorVersion
inputSignalType
filterConfig
thresholdMode
thresholdParameters
refractoryPeriod
prominenceRequirement
stationarySuppressionEnabled
runningAdaptationEnabled
```

Every formal benchmark must reference the active configuration. *(Her resmî benchmark aktif yapılandırmaya referans vermelidir.)*

---

# 74. Detector Versioning (Algılayıcı Sürümleme)

Any change that alters which physical events are accepted as steps must increment the detector or preprocessing version. *(Hangi fiziksel olayların adım olarak kabul edildiğini değiştiren herhangi bir değişiklik algılayıcı veya ön işleme sürümünü artırmalıdır.)*

This includes changes to thresholds, filters, refractory timing, or validation logic. *(Bu eşikler, filtreler, refractory zamanlaması veya doğrulama mantığındaki değişiklikleri içerir.)*

---

# 75. Parameter Freeze Policy (Parametre Sabitleme Politikası)

Detector parameters may be tuned using development and validation recordings. *(Algılayıcı parametreleri geliştirme ve doğrulama kayıtları kullanılarak ayarlanabilir.)*

They must be frozen before the final held-out benchmark. *(Nihai ayrılmış benchmark’tan önce sabitlenmelidir.)*

Final test routes must not be repeatedly used to optimize thresholds. *(Nihai test rotaları eşikleri optimize etmek için tekrar tekrar kullanılmamalıdır.)*

---

# 76. Ground-Truth Step Labels (Gerçek Referans Adım Etiketleri)

Step-detector evaluation requires reference information describing when real steps occurred. *(Adım algılayıcı değerlendirmesi gerçek adımların ne zaman gerçekleştiğini açıklayan referans bilgi gerektirir.)*

NAVGUARD will create manual or controlled ground-truth step labels for selected recordings. *(NAVGUARD seçilen kayıtlar için manuel veya kontrollü gerçek referans adım etiketleri oluşturacaktır.)*

---

# 77. Ground-Truth Label Model (Gerçek Referans Etiket Modeli)

```
ReferenceStep
- referenceStepId
- timestampNs
- sessionId
- annotationMethod
- confidence
```

Reference labels must remain separate from detector outputs. *(Referans etiketleri algılayıcı çıktılarından ayrı kalmalıdır.)*

---

# 78. Manual Step Counting (Manuel Adım Sayımı)

For simple controlled routes, manual counting may provide a reliable total number of steps. *(Basit kontrollü rotalar için manuel sayım güvenilir toplam adım sayısı sağlayabilir.)*

Total count alone is not sufficient for event-level timing evaluation. *(Toplam sayı tek başına olay seviyesinde zamanlama değerlendirmesi için yeterli değildir.)*

---

# 79. Event-Level Ground Truth (Olay Seviyesinde Gerçek Referans)

Event-level evaluation requires approximate timestamps for individual real steps. *(Olay seviyesinde değerlendirme bireysel gerçek adımlar için yaklaşık zaman damgaları gerektirir.)*

These labels may be created through synchronized video, manual annotation, or another documented method available to the project. *(Bu etiketler senkronize video, manuel anotasyon veya proje için kullanılabilir başka bir dokümante edilmiş yöntem üzerinden oluşturulabilir.)*

---

# 80. Ground-Truth Method Must Be Documented (Gerçek Referans Yöntemi Dokümante Edilmelidir)

The labeling method used for each evaluation dataset must be recorded. *(Her değerlendirme veri seti için kullanılan etiketleme yöntemi kaydedilmelidir.)*

Reference labels generated by one method must not be silently mixed with labels generated under a materially different protocol. *(Bir yöntemle üretilen referans etiketleri anlamlı şekilde farklı bir protokol altında üretilen etiketlerle sessizce karıştırılmamalıdır.)*

---

# 81. Step Matching Tolerance (Adım Eşleştirme Toleransı)

A detected step will be considered matched to a reference step only when their timestamps fall within an allowed temporal tolerance. *(Tespit edilen bir adım yalnızca zaman damgaları izin verilen zamansal tolerans içerisinde olduğunda bir referans adımla eşleşmiş kabul edilecektir.)*

The final tolerance will be selected based on annotation precision and detector latency. *(Nihai tolerans anotasyon hassasiyeti ve algılayıcı gecikmesine göre seçilecektir.)*

---

# 82. One-to-One Matching Rule (Bire Bir Eşleştirme Kuralı)

One detected step may match at most one reference step. *(Bir tespit edilen adım en fazla bir referans adımla eşleşebilir.)*

One reference step may match at most one detected step. *(Bir referans adım en fazla bir tespit edilen adımla eşleşebilir.)*

This prevents one detector event from receiving multiple true-positive credits. *(Bu bir algılayıcı olayının birden fazla true-positive kredisi almasını önler.)*

---

# 83. True Positive Definition (True Positive Tanımı)

A true positive is a detected step successfully matched to a real reference step. *(True positive, gerçek bir referans adımla başarıyla eşleştirilen tespit edilmiş adımdır.)*

```
TP =
Matched Detected Steps
```

---

# 84. False Positive Definition (False Positive Tanımı)

A false positive is an accepted detector step that does not match any reference step. *(False positive, hiçbir referans adımla eşleşmeyen kabul edilmiş algılayıcı adımıdır.)*

```
FP =
Unmatched Detected Steps
```

False positives create artificial PDR displacement. *(False positive’ler yapay PDR yer değiştirmesi oluşturur.)*

---

# 85. False Negative Definition (False Negative Tanımı)

A false negative is a real reference step for which no detector event was matched. *(False negative, hiçbir algılayıcı olayıyla eşleşmeyen gerçek referans adımdır.)*

```
FN =
Unmatched Reference Steps
```

False negatives cause PDR to miss real displacement. *(False negative’ler PDR’nin gerçek yer değiştirmeyi kaçırmasına neden olur.)*

---

# 86. Precision (Precision)

Step-detection precision will be calculated as follows. *(Adım tespit precision değeri aşağıdaki şekilde hesaplanacaktır.)*

```
Precision =
TP
───────
TP + FP
```

High precision indicates that accepted detector steps are usually real steps. *(Yüksek precision kabul edilmiş algılayıcı adımlarının genellikle gerçek adımlar olduğunu gösterir.)*

---

# 87. Recall (Recall)

Step-detection recall will be calculated as follows. *(Adım tespit recall değeri aşağıdaki şekilde hesaplanacaktır.)*

```
Recall =
TP
───────
TP + FN
```

High recall indicates that most real steps are detected. *(Yüksek recall gerçek adımların çoğunun tespit edildiğini gösterir.)*

---

# 88. F1 Score (F1 Skoru)

F1 will summarize the balance between precision and recall. *(F1 precision ile recall arasındaki dengeyi özetleyecektir.)*

```
F1 =
2 × Precision × Recall
──────────────────────
Precision + Recall
```

F1 will be one of the primary event-level step-detection metrics. *(F1 temel olay seviyesi adım tespit metriklerinden biri olacaktır.)*

---

# 89. Step Count Error (Adım Sayısı Hatası)

Total count error will also be reported for practical PDR interpretation. *(Toplam sayım hatası pratik PDR yorumu için ayrıca raporlanacaktır.)*

```
CountError =
DetectedSteps - ReferenceSteps
```

Absolute count error may additionally be reported. *(Mutlak sayım hatası ayrıca raporlanabilir.)*

---

# 90. Step Count Percentage Error (Adım Sayısı Yüzde Hatası)

When reference step count is nonzero, percentage error may be calculated as follows. *(Referans adım sayısı sıfırdan farklı olduğunda yüzde hata aşağıdaki şekilde hesaplanabilir.)*

```
CountErrorPercent =
|Detected - Reference|
────────────────────── × 100
Reference
```

---

# 91. Detection Timing Error (Tespit Zamanlama Hatası)

For every matched step pair, timing error may be calculated as follows. *(Eşleşen her adım çifti için zamanlama hatası aşağıdaki şekilde hesaplanabilir.)*

```
e_t =
t_detected - t_reference
```

The distribution of timing errors will characterize detector latency and consistency. *(Zamanlama hatalarının dağılımı algılayıcı gecikmesini ve tutarlılığını karakterize edecektir.)*

---

# 92. Mean Absolute Timing Error (Ortalama Mutlak Zamanlama Hatası)

```
TimingMAE =
1/n · Σ |e_t_i|
```

This metric is useful when heading must later be associated with the detected step timestamp. *(Bu metrik yönün daha sonra tespit edilen adım zaman damgasıyla ilişkilendirilmesi gerektiğinde kullanışlıdır.)*

---

# 93. Stationary False Positive Rate (Sabit Durum Yanlış Pozitif Oranı)

Stationary recordings will receive a dedicated false-step metric. *(Sabit durum kayıtları özel bir yanlış adım metriği alacaktır.)*

One candidate representation is false accepted steps per minute of stationary recording. *(Aday temsillerden biri sabit kayıt dakikası başına yanlış kabul edilmiş adım sayısıdır.)*

```
StationaryFalseStepsPerMin =
FalseSteps
───────────────
StationaryMinutes
```

---

# 94. Why Stationary Metric Is Separate (Sabit Durum Metriğinin Neden Ayrı Olduğu)

A detector may achieve acceptable overall F1 while still producing harmful false steps during long stationary periods. *(Bir algılayıcı uzun sabit dönemlerde zararlı yanlış adımlar üretmeye devam ederken kabul edilebilir toplam F1 elde edebilir.)*

NAVGUARD will therefore evaluate stationary false positives separately. *(Bu nedenle NAVGUARD sabit durum yanlış pozitiflerini ayrı olarak değerlendirecektir.)*

---

# 95. Walking Evaluation Dataset (Yürüyüş Değerlendirme Veri Seti)

The detector will be evaluated on normal walking sessions. *(Algılayıcı normal yürüyüş oturumlarında değerlendirilecektir.)*

Sessions should include multiple continuous walking intervals rather than only one short example. *(Oturumlar yalnızca tek kısa örnek yerine birden fazla sürekli yürüyüş aralığı içermelidir.)*

---

# 96. Running Evaluation Dataset (Koşma Değerlendirme Veri Seti)

If running remains within the final motion scope, the detector will also be evaluated on running sessions. *(Koşma nihai hareket kapsamı içerisinde kalırsa algılayıcı koşu oturumlarında da değerlendirilecektir.)*

Walking and running performance will be reported separately when their signal characteristics differ materially. *(Sinyal özellikleri anlamlı şekilde farklı olduğunda yürüyüş ve koşu performansı ayrı raporlanacaktır.)*

---

# 97. Turn-Heavy Evaluation (Dönüş Yoğun Değerlendirme)

Step detection will be evaluated during routes containing frequent turns. *(Adım tespiti sık dönüş içeren rotalarda değerlendirilecektir.)*

This will test whether changing device orientation or body dynamics creates false or missed steps. *(Bu değişen cihaz yöneliminin veya vücut dinamiklerinin yanlış veya kaçırılmış adımlar oluşturup oluşturmadığını test edecektir.)*

---

# 98. Walk-Stop-Walk Evaluation (Yürü-Dur-Yürü Değerlendirmesi)

The detector must be evaluated on walking followed by stationary periods and renewed walking. *(Algılayıcı yürüyüşü takip eden sabit dönemler ve yeniden yürüyüş üzerinde değerlendirilmelidir.)*

The main risk is accepting residual oscillations after stopping or missing the first steps after movement resumes. *(Temel risk durduktan sonra kalan salınımları kabul etmek veya hareket yeniden başladığında ilk adımları kaçırmaktır.)*

---

# 99. Non-Step Disturbance Evaluation (Adım Olmayan Bozulma Değerlendirmesi)

The detector will be tested with deliberate non-step phone movements. *(Algılayıcı bilinçli adım olmayan telefon hareketleriyle test edilecektir.)*

The objective is to measure robustness rather than only accuracy during ideal walking. *(Amaç yalnızca ideal yürüyüş sırasındaki doğruluk yerine dayanıklılığı ölçmektir.)*

---

# 100. Device Placement Evaluation (Cihaz Yerleşimi Değerlendirmesi)

The formal baseline may use one controlled placement, but exploratory tests may compare additional placements. *(Resmî temel sistem tek kontrollü yerleşim kullanabilir ancak keşifsel testler ek yerleşimleri karşılaştırabilir.)*

If performance changes substantially, the limitation will be documented rather than hidden. *(Performans önemli ölçüde değişirse sınırlama gizlenmek yerine dokümante edilecektir.)*

---

# 101. Session-Wise Evaluation Split (Oturum Bazlı Değerlendirme Ayrımı)

If detector parameters are optimized from recorded sessions, final evaluation must use separate sessions. *(Algılayıcı parametreleri kaydedilmiş oturumlardan optimize edilirse nihai değerlendirme ayrı oturumları kullanmalıdır.)*

Overlapping samples from the same physical session must not be split across calibration and final test sets. *(Aynı fiziksel oturumdan örtüşen örnekler kalibrasyon ve nihai test setleri arasında bölünmemelidir.)*

---

# 102. Parameter Optimization Objective (Parametre Optimizasyon Hedefi)

Threshold and timing parameters will be selected using a balanced evaluation objective. *(Eşik ve zamanlama parametreleri dengeli bir değerlendirme hedefi kullanılarak seçilecektir.)*

Optimizing only raw detected-step count may hide false positives and timing problems. *(Yalnızca ham tespit edilen adım sayısını optimize etmek yanlış pozitifleri ve zamanlama sorunlarını gizleyebilir.)*

Precision, recall, F1, stationary false positives, and downstream PDR distance error will all be considered. *(Precision, recall, F1, sabit durum yanlış pozitifleri ve aşağı akış PDR mesafe hatası birlikte değerlendirilecektir.)*

---

# 103. No Final-Test Tuning (Nihai Test Üzerinde Ayar Olmaması)

Final held-out detector results must not be used repeatedly to retune the detector and then reported as independent performance. *(Nihai ayrılmış algılayıcı sonuçları algılayıcıyı tekrar tekrar yeniden ayarlamak için kullanılmamalı ve daha sonra bağımsız performans olarak raporlanmamalıdır.)*

---

# 104. Comparison With Android Step Detector (Android Adım Algılayıcı ile Karşılaştırma)

If the Redmi Note 9 Pro exposes Android’s native step detector, its output may be recorded as an optional comparison baseline. *(Redmi Note 9 Pro Android’in native adım algılayıcısını sunuyorsa çıktısı isteğe bağlı karşılaştırma temeli olarak kaydedilebilir.)*

The custom NAVGUARD detector will remain the authoritative baseline algorithm because its processing and thresholds are experimentally observable and reproducible. *(Özel NAVGUARD algılayıcı işleme ve eşikleri deneysel olarak gözlemlenebilir ve tekrarlanabilir olduğu için ana temel algoritma olarak kalacaktır.)*

---

# 105. Native Step Detector Must Not Become Hidden Dependency (Native Adım Algılayıcı Gizli Bağımlılık Olmamalıdır)

The custom detector must continue working when the Android native step-detector sensor is absent or disabled. *(Android native adım algılayıcı sensörü mevcut olmadığında veya devre dışı olduğunda özel algılayıcı çalışmaya devam etmelidir.)*

---

# 106. Step Counter Comparison (Adım Sayacı Karşılaştırması)

Android’s step-counter output may also be logged for coarse total-count comparison when available. *(Mevcut olduğunda Android adım sayacı çıktısı kaba toplam sayım karşılaştırması için de kaydedilebilir.)*

It will not replace event-level NAVGUARD detection because PDR requires timestamped individual step events. *(PDR zaman damgalı bireysel adım olaylarına ihtiyaç duyduğu için olay seviyesindeki NAVGUARD tespitinin yerini almayacaktır.)*

---

# 107. Step Detector and PDR Boundary (Adım Algılayıcı ve PDR Sınırı)

The step detector decides whether a physical step event occurred. *(Adım algılayıcı fiziksel bir adım olayının gerçekleşip gerçekleşmediğine karar verir.)*

The step detector does not update East or North position. *(Adım algılayıcı Doğu veya Kuzey konumunu güncellemez.)*

The accepted step event is passed to the PDR engine, which performs displacement propagation. *(Kabul edilmiş adım olayı yer değiştirme ilerletmesini gerçekleştiren PDR motoruna iletilir.)*

---

# 108. Step Detector and Step Length Boundary (Adım Algılayıcı ve Adım Uzunluğu Sınırı)

The step detector identifies the existence and timestamp of a step. *(Adım algılayıcı bir adımın varlığını ve zaman damgasını belirler.)*

The step-length estimator decides how much horizontal distance should be assigned to that step. *(Adım uzunluğu tahmin motoru o adıma ne kadar yatay mesafe atanacağına karar verir.)*

These responsibilities must remain logically separated. *(Bu sorumluluklar mantıksal olarak ayrı kalmalıdır.)*

---

# 109. Step Detector and Heading Boundary (Adım Algılayıcı ve Yön Sınırı)

The step detector does not determine true-north heading. *(Adım algılayıcı gerçek kuzey yönünü belirlemez.)*

After a step is accepted, the PDR pipeline obtains the appropriate heading estimate for that step timestamp. *(Bir adım kabul edildikten sonra PDR hattı o adım zaman damgası için uygun yön tahminini elde eder.)*

---

# 110. Step Detector and AI Boundary (Adım Algılayıcı ve Yapay Zekâ Sınırı)

The motion AI may provide context such as `STATIONARY`, `WALKING`, `RUNNING`, or `TURNING`. *(Hareket yapay zekâsı `STATIONARY`, `WALKING`, `RUNNING` veya `TURNING` gibi bağlam sağlayabilir.)*

The baseline detector will not require the AI result to generate steps. *(Temel algılayıcı adım üretmek için yapay zekâ sonucuna ihtiyaç duymayacaktır.)*

AI context may later alter confidence or parameter selection. *(Yapay zekâ bağlamı daha sonra güveni veya parametre seçimini değiştirebilir.)*

---

# 111. Step Detector and Sensor Confidence Boundary (Adım Algılayıcı ve Sensör Güveni Sınırı)

The Sensor Confidence and Quality Engine may inform the detector about degraded accelerometer timing or quality. *(Sensör Güven ve Kalite Motoru algılayıcıyı bozulmuş ivmeölçer zamanlaması veya kalitesi hakkında bilgilendirebilir.)*

The detector may reject or mark uncertain candidates when critical input quality is poor. *(Algılayıcı kritik girdi kalitesi düşük olduğunda adayları reddedebilir veya belirsiz olarak işaretleyebilir.)*

---

# 112. Step Detection Confidence (Adım Tespit Güveni)

The target detector may produce a confidence score for each accepted step. *(Hedef algılayıcı kabul edilen her adım için bir güven skoru üretebilir.)*

Candidate inputs may include peak amplitude, prominence, temporal consistency, cadence consistency, and stationary evidence. *(Aday girdiler peak genliğini, prominence değerini, zamansal tutarlılığı, kadans tutarlılığını ve sabit durum kanıtını içerebilir.)*

---

# 113. Confidence Is Not Probability (Güven Olasılık Değildir)

A detector confidence score must not be presented as a calibrated probability unless a calibration experiment demonstrates that interpretation. *(Bir algılayıcı güven skoru kalibrasyon deneyi bu yorumu göstermediği sürece kalibre edilmiş olasılık olarak sunulmamalıdır.)*

The score may initially represent relative quality only. *(Skor başlangıçta yalnızca göreli kaliteyi temsil edebilir.)*

---

# 114. Confidence Use in PDR (PDR’de Güven Kullanımı)

Baseline PDR may propagate all accepted steps equally. *(Temel PDR tüm kabul edilmiş adımları eşit şekilde ilerletebilir.)*

Advanced fusion may use step confidence to adjust measurement uncertainty. *(Gelişmiş füzyon adım güvenini ölçüm belirsizliğini ayarlamak için kullanabilir.)*

The confidence mechanism will not be allowed to silently change baseline Configuration A unless explicitly defined. *(Güven mekanizmasının açıkça tanımlanmadıkça temel Yapılandırma A’yı sessizce değiştirmesine izin verilmeyecektir.)*

---

# 115. Detector Runtime Health (Algılayıcı Çalışma Zamanı Sağlığı)

The detector may expose the following health states. *(Algılayıcı aşağıdaki sağlık durumlarını sunabilir.)*

```
STARTING
READY
ACTIVE
STATIONARY
DEGRADED
ERROR
```

`STATIONARY` is a valid operating state rather than a failure. *(`STATIONARY` bir hata yerine geçerli çalışma durumudur.)*

---

# 116. Detector Degraded State (Algılayıcı Bozulmuş Durumu)

The detector may enter `DEGRADED` when accelerometer timing gaps become excessive. *(İvmeölçer zamanlama boşlukları aşırı hale geldiğinde algılayıcı `DEGRADED` durumuna geçebilir.)*

It may enter `DEGRADED` when preprocessing becomes unstable or critical quality conditions are violated. *(Ön işleme kararsız hale geldiğinde veya kritik kalite koşulları ihlal edildiğinde `DEGRADED` durumuna geçebilir.)*

---

# 117. Detector Failure Codes (Algılayıcı Hata Kodları)

```
STEP_ACCELEROMETER_UNAVAILABLE
STEP_SIGNAL_INVALID
STEP_TIMING_GAP
STEP_FILTER_ERROR
STEP_NON_MONOTONIC_TIME
STEP_DUPLICATE_EVENT
STEP_CONFIGURATION_ERROR
STEP_NUMERICAL_ERROR
```

Structured error codes will support debugging and replay analysis. *(Yapılandırılmış hata kodları hata ayıklamayı ve replay analizini destekleyecektir.)*

---

# 118. No Sample-Level UI Dependency (Örnek Seviyesinde UI Bağımlılığı Olmaması)

Step detection will not depend on Flutter chart rendering or screen refresh timing. *(Adım tespiti Flutter grafik render’ına veya ekran yenileme zamanlamasına bağımlı olmayacaktır.)*

Diagnostic plots will observe detector data without controlling the algorithm. *(Tanısal grafikler algoritmayı kontrol etmeden algılayıcı verisini gözlemleyecektir.)*

---

# 119. Detector Logging Schema (Algılayıcı Kayıt Şeması)

A processed step-event file may use the following schema. *(İşlenmiş bir adım olayı dosyası aşağıdaki şemayı kullanabilir.)*

```
event_timestamp_ns,
confirmation_timestamp_ns,
step_index,
peak_value,
prominence,
cadence_hz,
confidence,
motion_context,
detector_version
```

This file will remain separate from raw accelerometer measurements. *(Bu dosya ham ivmeölçer ölçümlerinden ayrı kalacaktır.)*

---

# 120. Candidate Diagnostic Schema (Aday Tanısal Şema)

A development-only candidate log may use the following fields. *(Yalnızca geliştirme için aday kaydı aşağıdaki alanları kullanabilir.)*

```
timestamp_ns,
candidate_peak_value,
threshold_value,
prominence,
time_since_last_step,
decision,
rejection_reason
```

This information will help tune detector parameters reproducibly. *(Bu bilgi algılayıcı parametrelerini tekrarlanabilir şekilde ayarlamaya yardımcı olacaktır.)*

---

# 121. Raw-to-Step Provenance (Ham Veriden Adıma Kaynak İzlenebilirliği)

Every accepted step must be traceable to the preprocessing and detector versions that produced it. *(Kabul edilen her adım onu üreten ön işleme ve algılayıcı sürümlerine kadar izlenebilir olmalıdır.)*

This allows a recorded raw session to be reprocessed with a newer detector without overwriting historical results. *(Bu kaydedilmiş ham bir oturumun geçmiş sonuçların üzerine yazmadan daha yeni bir algılayıcıyla yeniden işlenmesine olanak sağlar.)*

---

# 122. Deterministic Replay Requirement (Deterministik Replay Gereksinimi)

Identical raw accelerometer data and identical frozen detector parameters must produce the same accepted step-event sequence within deterministic numerical behavior. *(Aynı ham ivmeölçer verisi ve aynı sabitlenmiş algılayıcı parametreleri deterministik sayısal davranış içerisinde aynı kabul edilmiş adım olayı dizisini üretmelidir.)*

---

# 123. Cross-Language Reference Validation (Diller Arası Referans Doğrulama)

Python may be used to implement and inspect the reference detector during development. *(Python geliştirme sırasında referans algılayıcıyı geliştirmek ve incelemek için kullanılabilir.)*

The mobile implementation must reproduce equivalent event decisions for the same test signal. *(Mobil uygulama aynı test sinyali için eşdeğer olay kararlarını yeniden üretmelidir.)*

---

# 124. Synthetic Step Signal Tests (Sentetik Adım Sinyali Testleri)

Synthetic waveforms will be used to test threshold crossing and peak detection. *(Sentetik dalga biçimleri eşik geçişini ve peak tespitini test etmek için kullanılacaktır.)*

Known peaks will allow deterministic expected event locations. *(Bilinen peak’ler deterministik beklenen olay konumlarına izin verecektir.)*

---

# 125. Duplicate Peak Test (Yinelenen Peak Testi)

A synthetic waveform containing multiple sub-peaks inside one physical-step interval will test refractory behavior. *(Tek bir fiziksel adım aralığı içerisinde birden fazla alt peak içeren sentetik dalga biçimi refractory davranışını test edecektir.)*

Only one navigation step should be accepted when the waveform represents one physical step. *(Dalga biçimi tek bir fiziksel adımı temsil ettiğinde yalnızca bir navigasyon adımı kabul edilmelidir.)*

---

# 126. Stationary Noise Test (Sabit Durum Gürültü Testi)

A stationary accelerometer recording will be replayed through the detector. *(Sabit bir ivmeölçer kaydı algılayıcı üzerinden replay edilecektir.)*

The detector should produce zero or sufficiently low false-step output according to the frozen acceptance requirement. *(Algılayıcı sabitlenmiş kabul gereksinimine göre sıfır veya yeterince düşük yanlış adım çıktısı üretmelidir.)*

The exact quantitative threshold will be defined after pilot data. *(Kesin nicel eşik pilot veriden sonra tanımlanacaktır.)*

---

# 127. Walking Replay Test (Yürüyüş Replay Testi)

A labeled walking session will be replayed and compared against reference steps. *(Etiketlenmiş bir yürüyüş oturumu replay edilecek ve referans adımlarla karşılaştırılacaktır.)*

Precision, recall, F1, count error, and timing error will be calculated. *(Precision, recall, F1, sayım hatası ve zamanlama hatası hesaplanacaktır.)*

---

# 128. Running Replay Test (Koşma Replay Testi)

A labeled running session will test whether the detector’s refractory and adaptive threshold behavior remains suitable at faster cadence. *(Etiketlenmiş bir koşu oturumu algılayıcının refractory ve adaptif eşik davranışının daha hızlı kadansta uygun kalıp kalmadığını test edecektir.)*

---

# 129. Handling-Motion Replay Test (Elle Hareket Ettirme Replay Testi)

Non-step handling recordings will be replayed to quantify false positives. *(Adım olmayan elle hareket ettirme kayıtları yanlış pozitifleri nicel olarak belirlemek için replay edilecektir.)*

---

# 130. Live Device Test (Canlı Cihaz Testi)

The final detector must be tested live on the Redmi Note 9 Pro and not only in offline Python analysis. *(Nihai algılayıcı yalnızca çevrimdışı Python analizinde değil Redmi Note 9 Pro üzerinde canlı olarak test edilmelidir.)*

The live test will verify latency, event continuity, CPU impact, and integration with PDR. *(Canlı test gecikmeyi, olay sürekliliğini, CPU etkisini ve PDR entegrasyonunu doğrulayacaktır.)*

---

# 131. Live PDR Integration Test (Canlı PDR Entegrasyon Testi)

A live walking session will verify that every accepted step produces exactly one PDR update. *(Canlı bir yürüyüş oturumu kabul edilen her adımın tam olarak bir PDR güncellemesi ürettiğini doğrulayacaktır.)*

No rejected candidate may propagate position. *(Hiçbir reddedilmiş aday konumu ilerletemez.)*

---

# 132. Detector Performance Measurements (Algılayıcı Performans Ölçümleri)

The mobile detector will measure processing latency under the expected accelerometer rate. *(Mobil algılayıcı beklenen ivmeölçer hızı altında işleme gecikmesini ölçecektir.)*

CPU and memory overhead will also be profiled. *(CPU ve bellek yükü ayrıca profillenecektir.)*

The baseline algorithm should remain lightweight enough for continuous pedestrian use during experiments. *(Temel algoritma deneyler sırasında sürekli yaya kullanımı için yeterince hafif kalmalıdır.)*

---

# 133. No Unnecessary Neural Network for Basic Steps (Temel Adımlar İçin Gereksiz Sinir Ağı Olmaması)

NAVGUARD will not use a neural network merely to perform a task that the deterministic detector can already solve reliably. *(NAVGUARD deterministik algılayıcının zaten güvenilir şekilde çözebildiği bir görevi yalnızca gerçekleştirmek için sinir ağı kullanmayacaktır.)*

AI will be retained where it provides measurable improvement or useful motion context. *(Yapay zekâ ölçülebilir iyileştirme veya kullanışlı hareket bağlamı sağladığı yerde tutulacaktır.)*

---

# 134. Detector Simplicity Principle (Algılayıcı Basitlik İlkesi)

The preferred detector will be the simplest algorithm that reaches stable, reproducible performance on held-out sessions. *(Tercih edilen algılayıcı ayrılmış oturumlarda kararlı ve tekrarlanabilir performansa ulaşan en basit algoritma olacaktır.)*

Additional rules will not be added unless they solve a measured failure mode. *(Ölçülmüş bir hata modunu çözmedikleri sürece ek kurallar eklenmeyecektir.)*

---

# 135. Minimum Step Detector (Minimum Adım Algılayıcı)

The minimum detector must calculate an orientation-robust step signal. *(Minimum algılayıcı yönelime dayanıklı bir adım sinyali hesaplamalıdır.)*

It must filter the signal sufficiently for stable candidate generation. *(Kararlı aday üretimi için sinyali yeterince filtrelemelidir.)*

It must detect local step candidates. *(Yerel adım adaylarını tespit etmelidir.)*

It must apply an amplitude threshold. *(Bir genlik eşiği uygulamalıdır.)*

It must apply a minimum step interval. *(Minimum bir adım aralığı uygulamalıdır.)*

It must emit timestamped accepted step events. *(Zaman damgalı kabul edilmiş adım olayları üretmelidir.)*

---

# 136. Target Step Detector (Hedef Adım Algılayıcı)

The target detector will additionally support adaptive thresholds. *(Hedef algılayıcı ayrıca adaptif eşikleri destekleyecektir.)*

It will support stationary false-positive suppression. *(Sabit durum yanlış pozitif bastırmayı destekleyecektir.)*

It will support cadence-aware walking and running behavior. *(Kadans farkındalıklı yürüyüş ve koşu davranışını destekleyecektir.)*

It will expose event confidence and detailed diagnostics. *(Olay güvenini ve ayrıntılı tanıyı sunacaktır.)*

---

# 137. Optional Enhancements (İsteğe Bağlı İyileştirmeler)

Optional enhancements may include gyroscope-assisted motion validation. *(İsteğe bağlı iyileştirmeler jiroskop destekli hareket doğrulamayı içerebilir.)*

Optional enhancements may include AI motion-context gating. *(İsteğe bağlı iyileştirmeler yapay zekâ hareket bağlamı kapısını içerebilir.)*

Optional enhancements may include user-adaptive thresholds. *(İsteğe bağlı iyileştirmeler kullanıcıya adaptif eşikleri içerebilir.)*

These enhancements must not make the baseline detector fragile. *(Bu iyileştirmeler temel algılayıcıyı kırılgan hale getirmemelidir.)*

---

# 138. Step Detection Non-Goals (Adım Tespit Olmayan Hedefler)

The step detector will not estimate geographic position. *(Adım algılayıcı coğrafi konum tahmin etmeyecektir.)*

The step detector will not determine true-north heading. *(Adım algılayıcı gerçek kuzey yönünü belirlemeyecektir.)*

The step detector will not estimate global route geometry. *(Adım algılayıcı global rota geometrisini tahmin etmeyecektir.)*

The step detector will not directly correct PDR drift. *(Adım algılayıcı PDR sürüklenmesini doğrudan düzeltmeyecektir.)*

---

# 139. Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kararlar)

Baseline step detection will primarily use the smartphone accelerometer. *(Temel adım tespiti öncelikle akıllı telefon ivmeölçerini kullanacaktır.)*

The initial signal candidate will be filtered acceleration magnitude. *(İlk sinyal adayı filtrelenmiş ivme büyüklüğü olacaktır.)*

Baseline detection will use deterministic peak-based candidate generation. *(Temel tespit deterministik peak tabanlı aday üretimi kullanacaktır.)*

A candidate peak will not automatically become an accepted step. *(Bir aday peak otomatik olarak kabul edilmiş adım haline gelmeyecektir.)*

Temporal validation and a refractory rule will be mandatory. *(Zamansal doğrulama ve refractory kuralı zorunlu olacaktır.)*

---

# 140. Additional Frozen Decisions (Ek Sabitlenmiş Kararlar)

The detector will remain operational without AI. *(Algılayıcı yapay zekâ olmadan çalışabilir kalacaktır.)*

Stationary false positives will be evaluated separately. *(Sabit durum yanlış pozitifleri ayrı olarak değerlendirilecektir.)*

Accepted steps will have explicit event timestamps. *(Kabul edilmiş adımlar açık olay zaman damgalarına sahip olacaktır.)*

Only accepted steps will reach baseline PDR. *(Yalnızca kabul edilmiş adımlar temel PDR’ye ulaşacaktır.)*

Precision, recall, and F1 will be primary event-level evaluation metrics. *(Precision, recall ve F1 temel olay seviyesi değerlendirme metrikleri olacaktır.)*

---

# 141. Decisions Pending Physical Measurement (Fiziksel Ölçüm Bekleyen Kararlar)

The final filter type remains pending Redmi Note 9 Pro signal analysis. *(Nihai filtre türü Redmi Note 9 Pro sinyal analizini beklemektedir.)*

The final filter parameters remain pending recorded data. *(Nihai filtre parametreleri kaydedilmiş veriyi beklemektedir.)*

The final peak threshold remains pending calibration and validation sessions. *(Nihai peak eşiği kalibrasyon ve doğrulama oturumlarını beklemektedir.)*

The final adaptive-threshold formula remains pending comparative evaluation. *(Nihai adaptif eşik formülü karşılaştırmalı değerlendirmeyi beklemektedir.)*

The final refractory interval remains pending walking and running measurements. *(Nihai refractory aralığı yürüyüş ve koşu ölçümlerini beklemektedir.)*

The final event-matching tolerance remains pending annotation-quality analysis. *(Nihai olay eşleştirme toleransı anotasyon kalite analizini beklemektedir.)*

---

# 142. Unit-Test Acceptance Criteria (Birim Test Kabul Kriterleri)

A synthetic isolated step waveform must produce one accepted event. *(Sentetik izole bir adım dalga biçimi bir kabul edilmiş olay üretmelidir.)*

Two valid sufficiently separated synthetic steps must produce two accepted events. *(Yeterince ayrılmış iki geçerli sentetik adım iki kabul edilmiş olay üretmelidir.)*

Sub-peaks inside the refractory interval must not create duplicate accepted steps. *(Refractory aralığı içerisindeki alt peak’ler yinelenen kabul edilmiş adımlar oluşturmamalıdır.)*

A constant stationary signal must not create step events. *(Sabit bir sabit durum sinyali adım olayı oluşturmamalıdır.)*

---

# 143. Data-Integrity Acceptance Criteria (Veri Bütünlüğü Kabul Kriterleri)

Accepted step timestamps must be monotonically increasing. *(Kabul edilmiş adım zaman damgaları monotonik olarak artmalıdır.)*

Accepted step event identifiers must be unique. *(Kabul edilmiş adım olay tanımlayıcıları benzersiz olmalıdır.)*

Every event must identify the detector and preprocessing version that produced it. *(Her olay onu üreten algılayıcı ve ön işleme sürümünü tanımlamalıdır.)*

Raw accelerometer data must remain unchanged. *(Ham ivmeölçer verisi değişmeden kalmalıdır.)*

---

# 144. Evaluation Acceptance Criteria (Değerlendirme Kabul Kriterleri)

The final detector must be evaluated against labeled walking sessions. *(Nihai algılayıcı etiketlenmiş yürüyüş oturumlarına karşı değerlendirilmelidir.)*

The detector must be evaluated against stationary recordings. *(Algılayıcı sabit durum kayıtlarına karşı değerlendirilmelidir.)*

The detector must be evaluated against turn-containing movement. *(Algılayıcı dönüş içeren harekete karşı değerlendirilmelidir.)*

Running must also be evaluated if it remains a supported final motion class. *(Koşma desteklenen nihai hareket sınıfı olarak kalırsa ayrıca değerlendirilmelidir.)*

---

# 145. PDR Integration Acceptance Criteria (PDR Entegrasyon Kabul Kriterleri)

Every accepted step must produce no more than one baseline PDR propagation. *(Kabul edilmiş her adım en fazla bir temel PDR ilerletmesi üretmelidir.)*

Rejected candidates must produce no PDR displacement. *(Reddedilmiş adaylar hiçbir PDR yer değiştirmesi üretmemelidir.)*

The PDR step counter must equal the number of accepted navigation-step events consumed by PDR. *(PDR adım sayacı PDR tarafından kullanılan kabul edilmiş navigasyon adım olaylarının sayısına eşit olmalıdır.)*

---

# 146. Research Success Definition (Araştırma Başarı Tanımı)

Step detection is successful when it produces reproducible event-level measurements with sufficiently low false positives and missed steps to support measurable PDR navigation. *(Adım tespiti ölçülebilir PDR navigasyonunu destekleyecek kadar düşük yanlış pozitif ve kaçırılmış adımlarla tekrarlanabilir olay seviyesi ölçümleri ürettiğinde başarılıdır.)*

Success does not require perfect detection on every movement pattern. *(Başarı her hareket örüntüsünde kusursuz tespit gerektirmez.)*

Observed limitations will be documented and compared quantitatively. *(Gözlemlenen sınırlamalar dokümante edilecek ve nicel olarak karşılaştırılacaktır.)*

---

# 147. Final Step Detection Architecture Statement (Nihai Adım Tespit Mimarisi Bildirimi)

**NAVGUARD will use a deterministic accelerometer-based step detector as the authoritative baseline source of discrete pedestrian step events for PDR.** *(NAVGUARD PDR için ayrık yaya adım olaylarının ana temel kaynağı olarak deterministik ivmeölçer tabanlı bir adım algılayıcı kullanacaktır.)*

**The initial detector will derive an orientation-robust signal from filtered acceleration magnitude, identify candidate peaks, and validate them using amplitude, timing, refractory, stationary, and signal-quality rules.** *(İlk algılayıcı filtrelenmiş ivme büyüklüğünden yönelime dayanıklı bir sinyal türetecek, aday peak’leri belirleyecek ve bunları genlik, zamanlama, refractory, sabit durum ve sinyal kalite kuralları kullanarak doğrulayacaktır.)*

**A detected peak will update navigation only after it becomes an explicit accepted step event with a preserved event timestamp and unique identity.** *(Tespit edilen bir peak yalnızca korunmuş olay zaman damgasına ve benzersiz kimliğe sahip açık bir kabul edilmiş adım olayı haline geldikten sonra navigasyonu güncelleyecektir.)*

**The detector will remain independent from the neural motion classifier, while AI, gyroscope context, and sensor-confidence information may later improve validation without becoming mandatory dependencies.** *(Algılayıcı sinir ağı hareket sınıflandırıcısından bağımsız kalırken yapay zekâ, jiroskop bağlamı ve sensör güven bilgisi daha sonra zorunlu bağımlılıklar haline gelmeden doğrulamayı iyileştirebilir.)*

**The final algorithm and parameters will be selected from Redmi Note 9 Pro recordings using session-separated evaluation with precision, recall, F1, step-count error, timing error, stationary false positives, and downstream PDR performance.** *(Nihai algoritma ve parametreler precision, recall, F1, adım sayısı hatası, zamanlama hatası, sabit durum yanlış pozitifleri ve aşağı akış PDR performansıyla oturum bazlı ayrılmış değerlendirme kullanılarak Redmi Note 9 Pro kayıtlarından seçilecektir.)*

---

# 148. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development Step Detection Architecture Completed *(Doküman Durumu: Geliştirme Öncesi Adım Tespit Mimarisi Tamamlandı)*

**Primary Physical Input:** Accelerometer *(Temel Fiziksel Girdi: İvmeölçer)*

**Initial Step Signal:** Filtered Acceleration Magnitude *(İlk Adım Sinyali: Filtrelenmiş İvme Büyüklüğü)*

**Baseline Algorithm:** Deterministic Peak Detection *(Temel Algoritma: Deterministik Peak Tespiti)*

**Threshold Strategy:** Static Baseline + Adaptive Target *(Eşik Stratejisi: Sabit Temel + Adaptif Hedef)*

**Temporal Protection:** Refractory / Minimum Step Interval *(Zamansal Koruma: Refractory / Minimum Adım Aralığı)*

**Stationary Policy:** Explicit False-Step Suppression *(Sabit Durum Politikası: Açık Yanlış Adım Bastırma)*

**Walking Support:** Mandatory *(Yürüyüş Desteği: Zorunlu)*

**Running Support:** Target / To Be Validated *(Koşma Desteği: Hedef / Doğrulanacak)*

**AI Dependency:** None for Baseline *(Yapay Zekâ Bağımlılığı: Temel Sistem İçin Yok)*

**Primary Event Metrics:** Precision / Recall / F1 *(Temel Olay Metrikleri: Precision / Recall / F1)*

**Additional Metrics:** Count Error / Timing Error / Stationary False Positives *(Ek Metrikler: Sayım Hatası / Zamanlama Hatası / Sabit Durum Yanlış Pozitifleri)*

**Final Filter:** Pending Physical Data Analysis *(Nihai Filtre: Fiziksel Veri Analizi Bekleniyor)*

**Final Threshold:** Pending Calibration and Validation *(Nihai Eşik: Kalibrasyon ve Doğrulama Bekleniyor)*

**Final Refractory Interval:** Pending Walking and Running Measurements *(Nihai Refractory Aralığı: Yürüyüş ve Koşu Ölçümleri Bekleniyor)*

**Next Documentation Item:** 18 — Heading Estimation System *(Sonraki Dokümantasyon Öğesi: 18 — Yön Tahmin Sistemi)*