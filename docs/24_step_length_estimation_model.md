# 24 — Step Length Estimation Model (Adım Uzunluğu Tahmin Modeli)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the detailed architecture, baseline methods, label-construction strategy, feature engineering, deterministic estimation, machine-learning regression candidates, training protocol, validation design, motion-class conditioning, uncertainty estimation, mobile deployment strategy, PDR integration, EKF integration, fallback behavior, evaluation metrics, ablation experiments, reproducibility requirements, and acceptance criteria of the NAVGUARD Step Length Estimation Model. *(Bu doküman, NAVGUARD Adım Uzunluğu Tahmin Modelinin ayrıntılı mimarisini, temel yöntemlerini, etiket oluşturma stratejisini, özellik mühendisliğini, deterministik tahmini, makine öğrenmesi regresyon adaylarını, eğitim protokolünü, doğrulama tasarımını, hareket sınıfı koşullandırmasını, belirsizlik tahminini, mobil deployment stratejisini, PDR entegrasyonunu, EKF entegrasyonunu, geri dönüş davranışını, değerlendirme metriklerini, ablation deneylerini, tekrarlanabilirlik gereksinimlerini ve kabul kriterlerini tanımlar.)*

The step-length model is a target enhancement rather than a mandatory dependency of minimum NAVGUARD navigation. *(Adım uzunluğu modeli minimum NAVGUARD navigasyonunun zorunlu bağımlılığı yerine hedef bir iyileştirmedir.)*

A learned model will be retained only if it provides measurable improvement over deterministic baselines. *(Öğrenilmiş bir model yalnızca deterministik temel yöntemlere göre ölçülebilir iyileştirme sağlarsa korunacaktır.)*

---

# 2. Primary Objective (Temel Hedef)

The primary objective is to estimate the horizontal distance associated with each accepted pedestrian step. *(Temel hedef kabul edilmiş her yaya adımıyla ilişkili yatay mesafeyi tahmin etmektir.)*

The estimate will be used by the PDR process model to propagate East and North position. *(Tahmin PDR süreç modeli tarafından Doğu ve Kuzey konumunu ilerletmek için kullanılacaktır.)*

---

# 3. Step Length as a Physical Quantity (Fiziksel Bir Büyüklük Olarak Adım Uzunluğu)

For an accepted step `k`, NAVGUARD will represent estimated step length as follows. *(Kabul edilmiş bir `k` adımı için NAVGUARD tahmini adım uzunluğunu aşağıdaki şekilde temsil edecektir.)*

```text id="r24s01"
L_k
```

`L_k` will be expressed in metres. *(`L_k` metre cinsinden ifade edilecektir.)*

---

# 4. Step Length in PDR (PDR İçerisinde Adım Uzunluğu)

The PDR displacement equations remain as follows. *(PDR yer değiştirme denklemleri aşağıdaki gibi kalacaktır.)*

```text id="r24s02"
ΔE_k = L_k sin(ψ_k)

ΔN_k = L_k cos(ψ_k)
```

An error in `L_k` directly produces travelled-distance error. *(`L_k` içerisindeki bir hata doğrudan kat edilen mesafe hatası üretir.)*

---

# 5. Why Step Length Matters (Adım Uzunluğu Neden Önemlidir)

A constant step-length assumption is simple but cannot represent natural changes caused by walking speed, cadence, gait, and motion context. *(Sabit adım uzunluğu varsayımı basittir ancak yürüyüş hızı, kadans, gait ve hareket bağlamından kaynaklanan doğal değişimleri temsil edemez.)*

A more adaptive estimator may reduce accumulated PDR distance error. *(Daha adaptif bir tahmin motoru birikmiş PDR mesafe hatasını azaltabilir.)*

---

# 6. Complexity Must Be Justified (Karmaşıklık Gerekçelendirilmelidir)

A more complicated step-length estimator is not automatically better. *(Daha karmaşık bir adım uzunluğu tahmin motoru otomatik olarak daha iyi değildir.)*

NAVGUARD will compare increasingly sophisticated approaches under the same evaluation protocol. *(NAVGUARD giderek daha gelişmiş yaklaşımları aynı değerlendirme protokolü altında karşılaştıracaktır.)*

---

# 7. Step Length Method Hierarchy (Adım Uzunluğu Yöntem Hiyerarşisi)

```text id="r24s03"
Calibrated Fixed Step Length
(Kalibre Edilmiş Sabit Adım Uzunluğu)
          ↓
Deterministic Variable Step Length
(Deterministik Değişken Adım Uzunluğu)
          ↓
Linear Regression
          ↓
Random Forest Regressor
          ↓
Small Neural Regressor Only If Justified
(Yalnızca Gerekçelendirilirse Küçük Sinir Ağı Regresörü)
```

The simplest method that provides sufficient performance will be preferred. *(Yeterli performans sağlayan en basit yöntem tercih edilecektir.)*

---

# 8. Baseline 1 — Calibrated Fixed Step Length (Temel 1 — Kalibre Edilmiş Sabit Adım Uzunluğu)

The minimum step-length estimator will use one calibrated constant value for ordinary walking. *(Minimum adım uzunluğu tahmin motoru normal yürüyüş için tek kalibre edilmiş sabit değer kullanacaktır.)*

```text id="r24s04"
L_k = L_fixed
```

This provides a stable reference against which every adaptive method can be compared. *(Bu her adaptif yöntemin karşılaştırılabileceği kararlı bir referans sağlar.)*

---

# 9. Fixed-Step Calibration (Sabit Adım Kalibrasyonu)

A controlled route with independently known horizontal distance may be used to calibrate `L_fixed`. *(Bağımsız olarak bilinen yatay mesafeye sahip kontrollü rota `L_fixed` değerini kalibre etmek için kullanılabilir.)*

If `N_steps` verified steps occur over reference distance `D_ref`, the route-average step length may be estimated as follows. *(Referans `D_ref` mesafesi boyunca doğrulanmış `N_steps` adım gerçekleşirse rota ortalama adım uzunluğu aşağıdaki şekilde tahmin edilebilir.)*

```text id="r24s05"
L_fixed =
D_ref / N_steps
```

---

# 10. Fixed-Step Calibration Data Must Be Separate (Sabit Adım Kalibrasyon Verisi Ayrı Olmalıdır)

Final benchmark routes must not be used to choose the fixed-step calibration value and then also be reported as completely independent evaluation data. *(Nihai benchmark rotaları sabit adım kalibrasyon değerini seçmek için kullanılıp daha sonra tamamen bağımsız değerlendirme verisi olarak raporlanmamalıdır.)*

Calibration and final evaluation will remain separated. *(Kalibrasyon ve nihai değerlendirme ayrı kalacaktır.)*

---

# 11. Fixed-Step Interpretation (Sabit Adım Yorumlaması)

A route-average step length does not mean that every individual physical step has exactly the same length. *(Rota ortalama adım uzunluğu her bireysel fiziksel adımın tam olarak aynı uzunlukta olduğu anlamına gelmez.)*

The fixed-step model is intentionally a simplified baseline. *(Sabit adım modeli bilinçli olarak sadeleştirilmiş bir temel yöntemdir.)*

---

# 12. Baseline 2 — Deterministic Variable Step Length (Temel 2 — Deterministik Değişken Adım Uzunluğu)

The second baseline will estimate step length from measurable inertial characteristics without machine learning. *(İkinci temel yöntem adım uzunluğunu makine öğrenmesi olmadan ölçülebilir ataletsel özelliklerden tahmin edecektir.)*

This approach provides an adaptive but interpretable comparison for learned regressors. *(Bu yaklaşım öğrenilmiş regresörler için adaptif ancak yorumlanabilir bir karşılaştırma sağlar.)*

---

# 13. Weinberg-Style Candidate (Weinberg-Style Adayı)

A Weinberg-style relationship is the preferred initial deterministic variable-step candidate. *(Weinberg-style ilişki tercih edilen ilk deterministik değişken adım adayıdır.)*

A generic form is as follows. *(Genel biçim aşağıdaki gibidir.)*

```text id="r24s06"
L_k =
K · (a_max,k - a_min,k)^(1/4)
```

`K` is a calibration coefficient. *(`K` bir kalibrasyon katsayısıdır.)*

`a_max,k` and `a_min,k` describe acceleration extrema associated with the accepted step. *(`a_max,k` ve `a_min,k` kabul edilmiş adımla ilişkili ivme ekstremumlarını açıklar.)*

---

# 14. Weinberg-Style Is a Candidate, Not a Frozen Final Formula (Weinberg-Style Bir Adaydır, Sabitlenmiş Nihai Formül Değildir)

NAVGUARD will evaluate the Weinberg-style model against the fixed-step baseline before retaining it. *(NAVGUARD Weinberg-style modeli korumadan önce sabit adım temeline karşı değerlendirecektir.)*

The exact signal definition used for `a_max` and `a_min` will be frozen experimentally. *(`a_max` ve `a_min` için kullanılan kesin sinyal tanımı deneysel olarak sabitlenecektir.)*

---

# 15. Acceleration Signal Candidate (İvme Sinyali Adayı)

The initial deterministic candidate may use acceleration magnitude. *(İlk deterministik aday ivme büyüklüğünü kullanabilir.)*

```text id="r24s07"
a_mag =
√(
ax² + ay² + az²
)
```

The selected preprocessing must match the Step Detection System. *(Seçilen ön işleme Adım Tespit Sistemiyle uyumlu olmalıdır.)*

---

# 16. Step-Local Extrema (Adıma Yerel Ekstremumlar)

`a_max,k` and `a_min,k` should be calculated from a bounded step-associated signal interval rather than the complete session. *(`a_max,k` ve `a_min,k` tam oturum yerine sınırlı adımla ilişkili sinyal aralığından hesaplanmalıdır.)*

This ensures that each estimate describes the current accepted step. *(Bu her tahminin mevcut kabul edilmiş adımı açıklamasını sağlar.)*

---

# 17. Deterministic Calibration Coefficient (Deterministik Kalibrasyon Katsayısı)

The coefficient `K` will be estimated from calibration or training sessions only. *(`K` katsayısı yalnızca kalibrasyon veya eğitim oturumlarından tahmin edilecektir.)*

Final benchmark ground truth will not be used to retune `K`. *(Nihai benchmark ground truth verisi `K` değerini yeniden ayarlamak için kullanılmayacaktır.)*

---

# 18. Motion-Specific Deterministic Coefficients (Harekete Özgü Deterministik Katsayılar)

Walking and running may require different deterministic calibration coefficients. *(Yürüyüş ve koşma farklı deterministik kalibrasyon katsayıları gerektirebilir.)*

Separate coefficients will be introduced only if validation data demonstrates meaningful benefit. *(Ayrı katsayılar yalnızca doğrulama verisi anlamlı fayda gösterirse eklenecektir.)*

---

# 19. Step Length Estimation Starts After Step Acceptance (Adım Uzunluğu Tahmini Adım Kabulünden Sonra Başlar)

The step-length subsystem will operate only on steps already accepted by the Step Detection System. *(Adım uzunluğu alt sistemi yalnızca Adım Tespit Sistemi tarafından zaten kabul edilmiş adımlar üzerinde çalışacaktır.)*

It will not independently create pedestrian steps. *(Bağımsız olarak yaya adımları oluşturmayacaktır.)*

---

# 20. Step Event Contract (Adım Olayı Sözleşmesi)

A step-length estimator will receive a structured accepted-step event. *(Bir adım uzunluğu tahmin motoru yapılandırılmış kabul edilmiş adım olayı alacaktır.)*

```text id="r24s08"
AcceptedStep
- stepId
- timestampNs
- stepStartNs
- stepEndNs
- detectorConfidence
- motionContext
```

Additional local signal features may be attached or derived. *(Ek yerel sinyal özellikleri eklenebilir veya türetilebilir.)*

---

# 21. Step Length Output Contract (Adım Uzunluğu Çıktı Sözleşmesi)

```text id="r24s09"
StepLengthEstimate
- stepId
- timestampNs
- methodId
- lengthM
- uncertaintyVariance
- qualityState
- fallbackUsed
```

The output will be consumed by PDR and EKF. *(Çıktı PDR ve EKF tarafından kullanılacaktır.)*

---

# 22. Per-Step Uncertainty (Adım Başına Belirsizlik)

The target estimator will associate each step length with an uncertainty estimate when experimentally supportable. *(Hedef tahmin motoru deneysel olarak desteklenebildiğinde her adım uzunluğunu bir belirsizlik tahminiyle ilişkilendirecektir.)*

```text id="r24s10"
σL,k²
```

This value may enter EKF process noise. *(Bu değer EKF süreç gürültüsüne girebilir.)*

---

# 23. No Fake Uncertainty (Uydurma Belirsizlik Olmaması)

NAVGUARD will not invent per-step variance values simply to satisfy the EKF interface. *(NAVGUARD yalnızca EKF arayüzünü karşılamak için adım başına varyans değerleri uydurmayacaktır.)*

If a method does not provide calibrated per-step uncertainty, a validated method-level variance profile may be used instead. *(Bir yöntem kalibre edilmiş adım başına belirsizlik sağlamıyorsa bunun yerine doğrulanmış yöntem seviyesinde varyans profili kullanılabilir.)*

---

# 24. Ground Truth Is the Central Challenge (Ground Truth Temel Zorluktur)

Step-length modeling depends critically on the quality of distance labels. *(Adım uzunluğu modelleme mesafe etiketlerinin kalitesine kritik şekilde bağlıdır.)*

Per-step distance is substantially more difficult to measure accurately than total route distance with a standard smartphone-only setup. *(Standart yalnızca akıllı telefon kurulumunda adım başına mesafeyi doğru ölçmek toplam rota mesafesini ölçmekten anlamlı şekilde daha zordur.)*

---

# 25. Ground Truth Hierarchy (Ground Truth Hiyerarşisi)

NAVGUARD will distinguish between several levels of step-length reference quality. *(NAVGUARD birkaç adım uzunluğu referans kalite seviyesi arasında ayrım yapacaktır.)*

```text id="r24s11"
Level A:
Reliable per-step distance reference
(Güvenilir adım başına mesafe referansı)

Level B:
Reliable segment-level distance reference
(Güvenilir segment seviyesi mesafe referansı)

Level C:
Reliable route-level distance + verified step count
(Güvenilir rota seviyesi mesafe + doğrulanmış adım sayısı)
```

The available level will determine which regression claims are scientifically justified. *(Mevcut seviye hangi regresyon iddialarının bilimsel olarak gerekçelendirildiğini belirleyecektir.)*

---

# 26. Route-Average Labels (Rota Ortalama Etiketleri)

With route distance `D_ref` and verified step count `N`, an average route step length can be calculated. *(Rota mesafesi `D_ref` ve doğrulanmış `N` adım sayısıyla ortalama rota adım uzunluğu hesaplanabilir.)*

```text id="r24s12"
L_route_avg =
D_ref / N
```

This is an average label, not exact per-step truth. *(Bu ortalama etikettir, kesin adım başına gerçek değildir.)*

---

# 27. Segment-Average Labels (Segment Ortalama Etiketleri)

A route may be divided into controlled segments with known or independently measured distances. *(Bir rota bilinen veya bağımsız ölçülmüş mesafelere sahip kontrollü segmentlere bölünebilir.)*

Each segment can then provide its own average step-length reference. *(Her segment daha sonra kendi ortalama adım uzunluğu referansını sağlayabilir.)*

---

# 28. Why Segment Labels Are Better Than One Route Average (Segment Etiketleri Neden Tek Rota Ortalamasından Daha İyidir)

Segment-level labels can preserve some variation between slow walking, normal walking, fast walking, and running. *(Segment seviyesi etiketler yavaş yürüyüş, normal yürüyüş, hızlı yürüyüş ve koşma arasındaki bazı değişimleri koruyabilir.)*

A single route-average label would hide these differences. *(Tek rota ortalama etiketi bu farkları gizler.)*

---

# 29. Per-Step Ground Truth Candidate (Adım Başına Ground Truth Adayı)

If a reliable experimental method later provides individual footfall-to-footfall distance, per-step regression may be used directly. *(Güvenilir deneysel yöntem daha sonra bireysel ayak basma arası mesafe sağlarsa doğrudan adım başına regresyon kullanılabilir.)*

No such reference will be assumed before it is actually available. *(Böyle bir referans gerçekten mevcut olmadan varsayılmayacaktır.)*

---

# 30. No Pseudo-Precision (Sahte Hassasiyet Olmaması)

NAVGUARD will not assign the same route-average value to every step and then report small per-step MAE as if exact individual ground truth existed. *(NAVGUARD aynı rota ortalama değerini her adıma atayıp daha sonra kesin bireysel ground truth varmış gibi küçük adım başına MAE raporlamayacaktır.)*

The evaluation metric must match the actual label quality. *(Değerlendirme metriği gerçek etiket kalitesiyle uyumlu olmalıdır.)*

---

# 31. Label Source Documentation (Etiket Kaynağı Dokümantasyonu)

Every training target will record how its distance reference was produced. *(Her eğitim hedefi mesafe referansının nasıl üretildiğini kaydedecektir.)*

```text id="r24s13"
label_source:
PER_STEP
SEGMENT_AVERAGE
ROUTE_AVERAGE
```

---

# 32. Label Confidence (Etiket Güveni)

Dataset generation may preserve a qualitative or quantitative label-confidence field. *(Veri seti üretimi nitel veya nicel etiket güveni alanı koruyabilir.)*

Lower-quality labels may be excluded from final model training if they create unacceptable ambiguity. *(Daha düşük kaliteli etiketler kabul edilemez belirsizlik oluşturursa nihai model eğitiminden çıkarılabilir.)*

---

# 33. Training Labels Must Not Use Final Test Information (Eğitim Etiketleri Nihai Test Bilgisini Kullanmamalıdır)

Any calibration or route-derived labels used for training must come only from training-designated sessions. *(Eğitim için kullanılan herhangi bir kalibrasyon veya rota kaynaklı etiket yalnızca training olarak belirlenen oturumlardan gelmelidir.)*

---

# 34. GNSS as Offline Reference (Çevrimdışı Referans Olarak GNSS)

GNSS may assist offline distance labeling where its quality is sufficient and the labeling method is scientifically defensible. *(GNSS kalitesi yeterli ve etiketleme yöntemi bilimsel olarak savunulabilir olduğunda çevrimdışı mesafe etiketlemeye yardımcı olabilir.)*

GNSS will never be a live inference feature for the deployed step-length model during denied navigation. *(GNSS kesintili navigasyon sırasında deployment edilen adım uzunluğu modeli için hiçbir zaman canlı çıkarım özelliği olmayacaktır.)*

---

# 35. Known Route Geometry (Bilinen Rota Geometrisi)

Controlled straight routes with measured physical distance are preferred for baseline step-length calibration. *(Ölçülmüş fiziksel mesafeye sahip kontrollü düz rotalar temel adım uzunluğu kalibrasyonu için tercih edilir.)*

This reduces uncertainty caused by route-shape estimation. *(Bu rota şekli tahmininden kaynaklanan belirsizliği azaltır.)*

---

# 36. Step Count Validation (Adım Sayısı Doğrulaması)

Route-average labels require trustworthy step count. *(Rota ortalama etiketleri güvenilir adım sayısı gerektirir.)*

The independent Step Detection System must therefore be validated before its output is used to construct step-length labels. *(Bu nedenle bağımsız Adım Tespit Sistemi çıktısı adım uzunluğu etiketi oluşturmak için kullanılmadan önce doğrulanmalıdır.)*

---

# 37. Manual Reference Count Candidate (Manuel Referans Sayım Adayı)

Controlled calibration sessions may use independently counted steps as reference evidence. *(Kontrollü kalibrasyon oturumları referans kanıt olarak bağımsız sayılmış adımları kullanabilir.)*

This count may be manually verified from the experiment protocol. *(Bu sayım deney protokolünden manuel olarak doğrulanabilir.)*

---

# 38. Step Length Dataset Unit (Adım Uzunluğu Veri Seti Birimi)

The final dataset may operate at either individual-step or segment level depending on available reference quality. *(Nihai veri seti mevcut referans kalitesine bağlı olarak bireysel adım veya segment seviyesinde çalışabilir.)*

The project will not force a per-step formulation if only segment-level labels are scientifically reliable. *(Proje yalnızca segment seviyesi etiketler bilimsel olarak güvenilir olduğunda adım başına formülasyonu zorlamayacaktır.)*

---

# 39. Feature Engineering Objective (Özellik Mühendisliği Hedefi)

Features should describe measurable relationships between inertial gait dynamics and travelled distance. *(Özellikler ataletsel gait dinamikleri ile kat edilen mesafe arasındaki ölçülebilir ilişkileri açıklamalıdır.)*

Features must remain causal and computable on the phone. *(Özellikler nedensel ve telefonda hesaplanabilir kalmalıdır.)*

---

# 40. Acceleration Peak Amplitude (İvme Peak Genliği)

Peak amplitude around the accepted step is a primary feature candidate. *(Kabul edilmiş adım çevresindeki peak genliği temel özellik adayıdır.)*

```text id="r24s14"
A_peak =
a_peak - a_baseline
```

The exact baseline definition will follow the selected preprocessing method. *(Kesin baseline tanımı seçilen ön işleme yöntemini izleyecektir.)*

---

# 41. Peak-to-Valley Range (Peak-to-Valley Aralığı)

```text id="r24s15"
A_range =
a_max - a_min
```

This feature is directly related to the deterministic Weinberg-style baseline. *(Bu özellik deterministik Weinberg-style temel yöntemle doğrudan ilişkilidir.)*

---

# 42. Step Duration (Adım Süresi)

Step duration may be measured between accepted step boundaries or events. *(Adım süresi kabul edilmiş adım sınırları veya olayları arasında ölçülebilir.)*

```text id="r24s16"
T_step =
t_end - t_start
```

---

# 43. Cadence (Kadans)

Recent cadence is a candidate feature. *(Son kadans aday bir özelliktir.)*

```text id="r24s17"
cadence =
steps / unit_time
```

The exact averaging interval will be frozen experimentally. *(Kesin ortalama aralığı deneysel olarak sabitlenecektir.)*

---

# 44. Recent Step Interval (Son Adım Aralığı)

```text id="r24s18"
Δt_step =
t_k - t_(k-1)
```

This feature may help distinguish slower and faster locomotion. *(Bu özellik daha yavaş ve daha hızlı hareketi ayırt etmeye yardımcı olabilir.)*

---

# 45. Acceleration RMS (İvme RMS)

Acceleration RMS over the step-local interval may be evaluated. *(Adıma yerel aralık üzerindeki ivme RMS değeri değerlendirilebilir.)*

---

# 46. Acceleration Standard Deviation (İvme Standart Sapması)

Step-local acceleration standard deviation may describe motion intensity. *(Adıma yerel ivme standart sapması hareket yoğunluğunu açıklayabilir.)*

---

# 47. Gyroscope Features (Jiroskop Özellikleri)

Gyroscope magnitude and local rotation statistics may be considered when turning motion affects the step waveform. *(Dönüş hareketi adım dalga biçimini etkilediğinde jiroskop büyüklüğü ve yerel dönüş istatistikleri değerlendirilebilir.)*

They will not be added automatically without validation evidence. *(Doğrulama kanıtı olmadan otomatik olarak eklenmeyeceklerdir.)*

---

# 48. Motion Class Feature (Hareket Sınıfı Özelliği)

The validated motion class may be used as an input feature or model-selection context. *(Doğrulanmış hareket sınıfı girdi özelliği veya model seçim bağlamı olarak kullanılabilir.)*

```text id="r24s19"
motion_class ∈ {
WALKING,
RUNNING,
TURNING,
STATIONARY
}
```

No step-length estimate should normally be required for a truly stationary state with no accepted step. *(Hiçbir kabul edilmiş adım olmayan gerçek sabit durumda normalde adım uzunluğu tahmini gerekmemelidir.)*

---

# 49. Motion Class Must Be Timestamp-Aligned (Hareket Sınıfı Zaman Damgasıyla Hizalanmalıdır)

The motion context used for a step must correspond to that step's time interval. *(Bir adım için kullanılan hareket bağlamı o adımın zaman aralığına karşılık gelmelidir.)*

A future motion prediction must not be used to estimate a past real-time step. *(Gelecekteki hareket tahmini geçmiş gerçek zamanlı adımı tahmin etmek için kullanılmamalıdır.)*

---

# 50. Detector Confidence Feature (Algılayıcı Güveni Özelliği)

Step-detector confidence may be evaluated as an input to a learned estimator or uncertainty model. *(Adım algılayıcı güveni öğrenilmiş tahmin motoruna veya belirsizlik modeline girdi olarak değerlendirilebilir.)*

A weakly detected step may justify higher step-length uncertainty. *(Zayıf tespit edilmiş adım daha yüksek adım uzunluğu belirsizliğini gerekçelendirebilir.)*

---

# 51. Feature Minimalism (Özellik Minimalizmi)

The first regression model will use a compact feature set. *(İlk regresyon modeli kompakt özellik seti kullanacaktır.)*

Additional features will be retained only if ablation experiments show useful held-out improvement. *(Ek özellikler yalnızca ablation deneyleri kullanışlı ayrılmış iyileştirme gösterirse korunacaktır.)*

---

# 52. Feature Leakage Prevention (Özellik Sızıntısı Önleme)

No feature may use future sensor observations unavailable at the step's real-time estimation moment. *(Hiçbir özellik adımın gerçek zamanlı tahmin anında kullanılamayan gelecekteki sensör gözlemlerini kullanamaz.)*

---

# 53. GNSS-Derived Live Features Are Forbidden (GNSS Kaynaklı Canlı Özellikler Yasaktır)

GNSS speed, GNSS displacement, GNSS bearing, and ground-truth distance will not be deployed as live step-length model features during GNSS-denied navigation. *(GNSS hızı, GNSS yer değiştirmesi, GNSS bearing değeri ve ground truth mesafesi GNSS kesintili navigasyon sırasında canlı adım uzunluğu model özellikleri olarak deployment edilmeyecektir.)*

---

# 54. Feature Schema (Özellik Şeması)

```text id="r24s20"
StepLengthFeatureVector
- stepId
- accelRange
- accelPeak
- accelRms
- accelStd
- stepDuration
- cadence
- previousStepInterval
- motionClass
- detectorConfidence
```

The final feature list will be shorter or longer depending on validation evidence. *(Nihai özellik listesi doğrulama kanıtına bağlı olarak daha kısa veya daha uzun olabilir.)*

---

# 55. Feature Versioning (Özellik Sürümleme)

Any material change to feature definition or order will increment the feature-schema version. *(Özellik tanımında veya sırasında anlamlı herhangi bir değişiklik özellik şema sürümünü artıracaktır.)*

---

# 56. Feature Normalization (Özellik Normalizasyonu)

Linear and neural regression candidates may require feature scaling. *(Doğrusal ve sinir ağı regresyon adayları özellik ölçekleme gerektirebilir.)*

Training-derived scaling values will be frozen and reused for validation, test, and mobile inference. *(Eğitimden türetilen ölçekleme değerleri sabitlenecek ve doğrulama, test ve mobil çıkarım için yeniden kullanılacaktır.)*

---

# 57. Random Forest Scaling (Random Forest Ölçekleme)

Random Forest Regressor generally does not require the same feature standardization as linear or neural models. *(Random Forest Regressor genel olarak doğrusal veya sinir ağı modelleriyle aynı özellik standardizasyonunu gerektirmez.)*

The pipeline will still preserve exact feature units and ordering. *(Hattın yine de kesin özellik birimlerini ve sırasını koruması gerekecektir.)*

---

# 58. Linear Regression Baseline (Linear Regression Temeli)

Linear Regression will provide the simplest learned step-length baseline. *(Linear Regression en basit öğrenilmiş adım uzunluğu temelini sağlayacaktır.)*

A generic model may be written as follows. *(Genel model aşağıdaki şekilde yazılabilir.)*

```text id="r24s21"
L_hat =
β0
+
β1 x1
+
β2 x2
+
...
+
βp xp
```

---

# 59. Why Linear Regression Is Valuable (Linear Regression Neden Değerlidir)

Linear Regression provides a highly interpretable relationship between features and predicted step length. *(Linear Regression özellikler ile tahmini adım uzunluğu arasında yüksek derecede yorumlanabilir ilişki sağlar.)*

If it performs competitively, a more complex model may not be justified. *(Rekabetçi performans gösterirse daha karmaşık model gerekçelendirilmeyebilir.)*

---

# 60. Linear Regression Failure Modes (Linear Regression Hata Modları)

The relationship between inertial gait features and step length may be nonlinear. *(Ataletsel gait özellikleri ile adım uzunluğu arasındaki ilişki doğrusal olmayabilir.)*

Strong feature interactions may therefore limit linear performance. *(Bu nedenle güçlü özellik etkileşimleri doğrusal performansı sınırlayabilir.)*

---

# 61. Random Forest Regressor (Random Forest Regressor)

Random Forest Regressor will be the primary nonlinear classical candidate. *(Random Forest Regressor temel doğrusal olmayan klasik aday olacaktır.)*

It can model nonlinear relationships and interactions without requiring a large neural architecture. *(Büyük sinir ağı mimarisi gerektirmeden doğrusal olmayan ilişkileri ve etkileşimleri modelleyebilir.)*

---

# 62. Random Forest Hyperparameters (Random Forest Hiperparametreleri)

Candidate hyperparameters include number of trees. *(Aday hiperparametreler ağaç sayısını içerir.)*

Candidate hyperparameters include maximum tree depth. *(Aday hiperparametreler maksimum ağaç derinliğini içerir.)*

Candidate hyperparameters include minimum samples per leaf. *(Aday hiperparametreler leaf başına minimum örnek sayısını içerir.)*

The final values will be selected using validation data. *(Nihai değerler doğrulama verisi kullanılarak seçilecektir.)*

---

# 63. No Test-Set Hyperparameter Tuning (Test Setiyle Hiperparametre Ayarı Olmaması)

The held-out final test set will not be used to select Random Forest hyperparameters. *(Ayrılmış nihai test seti Random Forest hiperparametrelerini seçmek için kullanılmayacaktır.)*

---

# 64. Small Neural Regressor Candidate (Küçük Sinir Ağı Regresörü Adayı)

A compact multilayer perceptron may be evaluated only if classical regressors leave meaningful unexplained performance. *(Kompakt multilayer perceptron yalnızca klasik regresörler anlamlı açıklanmamış performans bırakırsa değerlendirilebilir.)*

---

# 65. Neural Regressor Input (Sinir Ağı Regresörü Girdisi)

The first neural-regression candidate would use the same engineered feature vector rather than raw multi-second sensor sequences. *(İlk sinir ağı regresyon adayı ham çok saniyelik sensör dizileri yerine aynı engineered özellik vektörünü kullanacaktır.)*

This keeps the task lightweight and interpretable. *(Bu görevi hafif ve yorumlanabilir tutar.)*

---

# 66. Raw-Sequence Neural Regression Is Not a Priority (Ham Dizi Sinir Ağı Regresyonu Öncelik Değildir)

A raw-sensor sequence model for direct step-length regression is outside the initial target. *(Doğrudan adım uzunluğu regresyonu için ham sensör dizi modeli ilk hedefin dışındadır.)*

It will be investigated only if feature-based approaches fail and project time permits. *(Yalnızca özellik tabanlı yaklaşımlar başarısız olur ve proje süresi izin verirse araştırılacaktır.)*

---

# 67. Model Selection Dataset Split (Model Seçim Veri Seti Ayrımı)

Step-length datasets will use session-wise or route-session-wise train, validation, and test separation. *(Adım uzunluğu veri setleri oturum bazlı veya rota-oturumu bazlı train, validation ve test ayrımı kullanacaktır.)*

The same physical route recording must not contribute derived samples to both training and final test sets. *(Aynı fiziksel rota kaydı türetilmiş örnekleri hem eğitim hem de nihai test setine sağlayamaz.)*

---

# 68. Same Principle as Motion Classification (Hareket Sınıflandırmayla Aynı İlke)

The leakage-prevention policy from the Motion Classification Model applies equally to step-length modeling. *(Hareket Sınıflandırma Modelindeki veri sızıntısı önleme politikası adım uzunluğu modellemeye de eşit şekilde uygulanır.)*

Correlated samples from one physical session stay in one split. *(Bir fiziksel oturumdan korelasyonlu örnekler tek bir ayrımda kalır.)*

---

# 69. Split Before Feature Normalization (Özellik Normalizasyonundan Önce Ayrım)

Dataset splitting must occur before training normalization statistics are calculated. *(Veri seti ayrımı eğitim normalizasyon istatistikleri hesaplanmadan önce gerçekleşmelidir.)*

---

# 70. Walking-Speed Diversity (Yürüyüş Hızı Çeşitliliği)

Calibration data should contain controlled slow, normal, and faster walking when safe and practical. *(Kalibrasyon verisi güvenli ve uygulanabilir olduğunda kontrollü yavaş, normal ve daha hızlı yürüyüş içermelidir.)*

This provides step-length variation for regression. *(Bu regresyon için adım uzunluğu çeşitliliği sağlar.)*

---

# 71. Running Data (Koşma Verisi)

`RUNNING` remains part of the frozen Motion Classification schema regardless of whether a running-specific learned step-length experiment is retained. Running-specific step-length data collection and regression form a separate optional experiment and do not control Motion Classification class membership. *(`RUNNING`, running-specific learned step-length experiment korunup korunmadığından bağımsız olarak frozen Motion Classification schema'nın parçası olarak kalır. Running-specific step-length data collection ve regression ayrı bir optional experiment oluşturur ve Motion Classification class membership'i kontrol etmez.)*

Running may be modeled separately if its gait relationship differs materially from walking. *(Gait ilişkisi yürüyüşten anlamlı şekilde farklıysa koşma ayrı modellenebilir.)*

---

# 72. Separate Models Versus One Unified Model (Ayrı Modeller ile Tek Birleşik Model)

NAVGUARD will compare two strategies if sufficient data exists. *(Yeterli veri mevcutsa NAVGUARD iki stratejiyi karşılaştıracaktır.)*

The first strategy is one unified regression model conditioned on motion features. *(İlk strateji hareket özellikleriyle koşullandırılmış tek birleşik regresyon modelidir.)*

The second strategy is separate walking and running estimators. *(İkinci strateji ayrı yürüyüş ve koşma tahmin motorlarıdır.)*

---

# 73. Unified Model Candidate (Birleşik Model Adayı)

```text id="r24s22"
L_hat =
f(
step_features,
motion_class
)
```

This approach is simpler to manage if the model can represent both gait regimes reliably. *(Model her iki gait rejimini güvenilir şekilde temsil edebiliyorsa bu yaklaşım yönetim açısından daha basittir.)*

---

# 74. Separate Model Candidate (Ayrı Model Adayı)

```text id="r24s23"
if motion == WALKING:
    L_hat = f_walk(features)

if motion == RUNNING:
    L_hat = f_run(features)
```

This strategy will be used only if validation evidence demonstrates clear benefit. *(Bu strateji yalnızca doğrulama kanıtı açık fayda gösterirse kullanılacaktır.)*

---

# 75. TURNING Step Length (TURNING Adım Uzunluğu)

A turning step may have different effective horizontal displacement than a straight walking step. *(Bir dönüş adımı düz yürüyüş adımından farklı etkili yatay yer değiştirmeye sahip olabilir.)*

NAVGUARD will initially test whether the same walking estimator remains adequate during turns. *(NAVGUARD başlangıçta aynı yürüyüş tahmin motorunun dönüşler sırasında yeterli kalıp kalmadığını test edecektir.)*

---

# 76. Turning-Specific Model Is Optional (Dönüşe Özgü Model İsteğe Bağlıdır)

A separate turning step-length estimator will not be created unless experiments demonstrate meaningful systematic error. *(Ayrı dönüş adım uzunluğu tahmin motoru deneyler anlamlı sistematik hata göstermedikçe oluşturulmayacaktır.)*

---

# 77. Stationary Steps Should Not Exist (Sabit Durum Adımları Olmamalıdır)

A valid `STATIONARY` interval should normally produce no accepted steps. *(Geçerli bir `STATIONARY` aralığı normalde kabul edilmiş adım üretmemelidir.)*

If a false step is accepted, the step-length subsystem should not hide the Step Detection System's error by assigning arbitrary distance. *(Yanlış adım kabul edilirse adım uzunluğu alt sistemi keyfi mesafe atayarak Adım Tespit Sisteminin hatasını gizlememelidir.)*

---

# 78. Step-Length Range Plausibility (Adım Uzunluğu Aralık Makullüğü)

Predicted step length must be physically plausible for the project participant and motion context. *(Tahmin edilen adım uzunluğu proje katılımcısı ve hareket bağlamı için fiziksel olarak makul olmalıdır.)*

The final numerical bounds will be derived from calibration data rather than invented in advance. *(Nihai sayısal sınırlar önceden uydurulmak yerine kalibrasyon verisinden türetilecektir.)*

---

# 79. Out-of-Range Prediction Policy (Aralık Dışı Tahmin Politikası)

A severely implausible learned prediction will normally trigger deterministic fallback. *(Ciddi şekilde fiziksel olarak mantıksız öğrenilmiş tahmin normalde deterministik geri dönüş tetikleyecektir.)*

Silent clipping to an arbitrary minimum or maximum is not the preferred default. *(Keyfi minimum veya maksimuma sessiz clipping tercih edilen varsayılan değildir.)*

---

# 80. Mild Out-of-Distribution Input (Hafif Dağılım Dışı Girdi)

A feature vector lying outside much of the training range may receive lower quality or trigger fallback. *(Eğitim aralığının büyük kısmının dışında kalan özellik vektörü daha düşük kalite alabilir veya geri dönüş tetikleyebilir.)*

The exact out-of-distribution policy will be determined experimentally. *(Kesin dağılım dışı politika deneysel olarak belirlenecektir.)*

---

# 81. Feature Range Metadata (Özellik Aralık Metadata Bilgisi)

The final model may store training-range summaries for important features. *(Nihai model önemli özellikler için eğitim aralığı özetlerini saklayabilir.)*

These values are diagnostics and not guaranteed hard physical bounds. *(Bu değerler tanısaldır ve garantili sert fiziksel sınırlar değildir.)*

---

# 82. Regression Output Quality (Regresyon Çıktı Kalitesi)

Each learned prediction may receive a quality state based on input validity, model availability, motion context, and plausibility. *(Her öğrenilmiş tahmin girdi geçerliliği, model kullanılabilirliği, hareket bağlamı ve makullüğe dayalı bir kalite durumu alabilir.)*

---

# 83. Regression Confidence Is Not Automatically Available (Regresyon Güveni Otomatik Olarak Mevcut Değildir)

Linear Regression and standard Random Forest prediction do not automatically provide a calibrated probability-like confidence for each step. *(Linear Regression ve standart Random Forest tahmini her adım için otomatik olarak kalibre edilmiş olasılık benzeri güven sağlamaz.)*

NAVGUARD will therefore distinguish prediction value from uncertainty estimation. *(Bu nedenle NAVGUARD tahmin değerini belirsizlik tahmininden ayıracaktır.)*

---

# 84. Method-Level Residual Variance (Yöntem Seviyesi Residual Varyansı)

The simplest EKF uncertainty input may use residual variance measured on validation data for the selected method. *(En basit EKF belirsizlik girdisi seçilen yöntem için doğrulama verisinde ölçülen residual varyansını kullanabilir.)*

```text id="r24s24"
σL,method² =
Var(
L_ref - L_hat
)
```

---

# 85. Motion-Conditioned Residual Variance (Harekete Koşullu Residual Varyansı)

If sufficient data exists, separate uncertainty profiles may be estimated for walking and running. *(Yeterli veri mevcutsa yürüyüş ve koşma için ayrı belirsizlik profilleri tahmin edilebilir.)*

```text id="r24s25"
σL,walk²

σL,run²
```

---

# 86. Quality-Conditioned Uncertainty (Kaliteye Koşullu Belirsizlik)

A low-quality step or out-of-distribution feature vector may receive larger step-length variance. *(Düşük kaliteli adım veya dağılım dışı özellik vektörü daha büyük adım uzunluğu varyansı alabilir.)*

The mapping will be calibrated rather than guessed. *(Eşleme tahmin edilmek yerine kalibre edilecektir.)*

---

# 87. Random Forest Ensemble Spread Candidate (Random Forest Ensemble Spread Adayı)

The distribution of individual tree predictions may be investigated as one heuristic uncertainty signal. *(Bireysel ağaç tahminlerinin dağılımı bir heuristic belirsizlik sinyali olarak araştırılabilir.)*

It will not be treated as calibrated uncertainty without validation. *(Doğrulama olmadan kalibre edilmiş belirsizlik olarak ele alınmayacaktır.)*

---

# 88. Prediction Interval Is Optional (Tahmin Aralığı İsteğe Bağlıdır)

Formal per-step prediction intervals are not required for the minimum project. *(Resmî adım başına tahmin aralıkları minimum proje için gerekli değildir.)*

The primary requirement is a defensible process-noise estimate for EKF. *(Temel gereksinim EKF için savunulabilir süreç gürültüsü tahminidir.)*

---

# 89. Regression Metrics Depend on Label Quality (Regresyon Metrikleri Etiket Kalitesine Bağlıdır)

Per-step regression metrics will be reported only if the reference labels support per-step interpretation. *(Adım başına regresyon metrikleri yalnızca referans etiketler adım başına yorumu destekliyorsa raporlanacaktır.)*

Otherwise, segment or route-level error will be emphasized. *(Aksi durumda segment veya rota seviyesi hata vurgulanacaktır.)*

---

# 90. Mean Absolute Error (Mean Absolute Error)

Where defensible references exist, step-length MAE will be calculated as follows. *(Savunulabilir referanslar mevcut olduğunda adım uzunluğu MAE değeri aşağıdaki şekilde hesaplanacaktır.)*

```text id="r24s26"
MAE =
1/n · Σ |L_hat_i - L_ref_i|
```

---

# 91. Root Mean Squared Error (Root Mean Squared Error)

```text id="r24s27"
RMSE =
√(
1/n · Σ (L_hat_i - L_ref_i)²
)
```

RMSE will provide greater sensitivity to larger regression errors. *(RMSE daha büyük regresyon hatalarına daha fazla hassasiyet sağlayacaktır.)*

---

# 92. Mean Error / Bias (Ortalama Hata / Bias)

```text id="r24s28"
Bias =
1/n · Σ (L_hat_i - L_ref_i)
```

Systematic bias is particularly important because small errors can accumulate over many steps. *(Sistematik bias özellikle önemlidir çünkü küçük hatalar çok sayıda adım boyunca birikebilir.)*

---

# 93. Percentage Error (Yüzde Hata)

Where reference distance is sufficiently reliable, percentage error may also be reported. *(Referans mesafe yeterince güvenilir olduğunda yüzde hata da raporlanabilir.)*

---

# 94. Route Distance Error (Rota Mesafe Hatası)

For a route containing `N` accepted steps, predicted total travelled distance is as follows. *(`N` kabul edilmiş adım içeren bir rota için tahmin edilen toplam kat edilen mesafe aşağıdaki gibidir.)*

```text id="r24s29"
D_hat =
Σ(k=1..N) L_hat_k
```

---

# 95. Route-Level Absolute Error (Rota Seviyesi Mutlak Hata)

```text id="r24s30"
E_route =
|D_hat - D_ref|
```

This metric remains valid even when exact per-step labels are unavailable. *(Bu metrik kesin adım başına etiketler kullanılamadığında bile geçerli kalır.)*

---

# 96. Route-Level Percentage Error (Rota Seviyesi Yüzde Hata)

```text id="r24s31"
E_route_% =
|D_hat - D_ref|
─────────────── × 100
D_ref
```

---

# 97. Why Route Error Is Critical (Rota Hatası Neden Kritiktir)

NAVGUARD ultimately uses accumulated step length to estimate travelled distance. *(NAVGUARD sonuçta kat edilen mesafeyi tahmin etmek için birikmiş adım uzunluğu kullanır.)*

A model with good local metrics but strong cumulative bias may be poor for navigation. *(İyi yerel metriklere ancak güçlü birikimli bias'a sahip model navigasyon için kötü olabilir.)*

---

# 98. Model Selection Will Include Bias (Model Seçimi Bias'ı İçerecektir)

The final step-length method will not be selected using MAE alone. *(Nihai adım uzunluğu yöntemi yalnızca MAE kullanılarak seçilmeyecektir.)*

Cumulative route error and signed bias will also be examined. *(Birikimli rota hatası ve işaretli bias da incelenecektir.)*

---

# 99. PDR-Level Evaluation (PDR Seviyesi Değerlendirme)

Each step-length method will also be evaluated inside PDR using the same accepted steps and heading sequence. *(Her adım uzunluğu yöntemi aynı kabul edilmiş adımları ve yön dizisini kullanarak PDR içerisinde de değerlendirilecektir.)*

This isolates the contribution of step-length estimation. *(Bu adım uzunluğu tahmininin katkısını izole eder.)*

---

# 100. Controlled Step-Length Ablation (Kontrollü Adım Uzunluğu Ablation)

```text id="r24s32"
Same:
accepted steps
heading
route
GNSS-denied interval

Change only:
step-length estimator
```

This design directly measures step-length contribution. *(Bu tasarım adım uzunluğu katkısını doğrudan ölçer.)*

---

# 101. Candidate Ablation Methods (Aday Ablation Yöntemleri)

```text id="r24s33"
A:
Fixed Step Length

B:
Deterministic Variable Step Length

C:
Linear Regression

D:
Random Forest Regressor

E:
Small Neural Regressor if retained
```

---

# 102. No AI Retention Without Benefit (Fayda Olmadan Yapay Zekâ Korunmaması)

A learned model will not become the final method merely because it is an AI model. *(Öğrenilmiş model yalnızca yapay zekâ modeli olduğu için nihai yöntem olmayacaktır.)*

It must outperform or otherwise clearly improve upon the selected deterministic baseline under held-out evaluation. *(Ayrılmış değerlendirme altında seçilen deterministik temel yöntemi geçmeli veya başka şekilde açıkça iyileştirmelidir.)*

---

# 103. What Counts as Improvement (Neyin İyileştirme Sayıldığı)

Improvement may include lower route-distance error. *(İyileştirme daha düşük rota mesafe hatasını içerebilir.)*

Improvement may include lower valid MAE or RMSE. *(İyileştirme daha düşük geçerli MAE veya RMSE içerebilir.)*

Improvement may include reduced signed bias. *(İyileştirme azaltılmış işaretli bias'ı içerebilir.)*

Improvement may include improved downstream PDR position error. *(İyileştirme geliştirilmiş aşağı akış PDR konum hatasını içerebilir.)*

---

# 104. No Arbitrary Percentage Retention Gate (Keyfi Yüzde Koruma Kapısı Olmaması)

NAVGUARD will not invent a required percentage improvement before step-length data exists. *(NAVGUARD adım uzunluğu verisi mevcut olmadan gerekli yüzde iyileştirme uydurmayacaktır.)*

The model must show consistent and practically meaningful benefit across held-out sessions. *(Model ayrılmış oturumlar genelinde tutarlı ve pratik olarak anlamlı fayda göstermelidir.)*

---

# 105. Consistency Across Sessions (Oturumlar Arası Tutarlılık)

A model that improves one route greatly but worsens most other routes may not be retained. *(Bir rotayı büyük ölçüde iyileştirip diğer rotaların çoğunu kötüleştiren model korunmayabilir.)*

Session-level results will therefore be inspected. *(Bu nedenle oturum seviyesi sonuçlar incelenecektir.)*

---

# 106. Regression Dataset Manifest (Regresyon Veri Seti Manifest'i)

```text id="r24s34"
StepLengthDatasetManifest
- datasetId
- sourceSessions
- labelSourceType
- routeReferences
- splitManifest
- featureSchemaVersion
- preprocessingVersion
- motionClassifierVersion
- exclusionRules
```

---

# 107. Dependency on Motion Classifier Version (Hareket Sınıflandırıcı Sürümüne Bağımlılık)

If predicted motion class is used as a regression feature, the step-length dataset must record which motion-classifier version produced that feature. *(Tahmin edilen hareket sınıfı regresyon özelliği olarak kullanılırsa adım uzunluğu veri seti bu özelliği hangi hareket sınıflandırıcı sürümünün ürettiğini kaydetmelidir.)*

---

# 108. Ground Truth Motion Label Versus Predicted Motion Class (Ground Truth Hareket Etiketi ile Tahmin Edilen Hareket Sınıfı)

Training experiments may compare use of true annotated motion class and deployed predicted motion class. *(Eğitim deneyleri gerçek annotate edilmiş hareket sınıfı ile deployment edilen tahmin edilmiş hareket sınıfının kullanımını karşılaştırabilir.)*

A model that relies on perfect ground-truth motion labels during training may perform differently when deployed with imperfect classifier predictions. *(Eğitim sırasında kusursuz ground truth hareket etiketlerine dayanan model kusurlu sınıflandırıcı tahminleriyle deployment edildiğinde farklı performans gösterebilir.)*

---

# 109. Deployment-Realistic Training (Deployment Gerçekçi Eğitim)

The final navigation evaluation should use the same motion-context source that will exist in the real application. *(Nihai navigasyon değerlendirmesi gerçek uygulamada bulunacak aynı hareket bağlamı kaynağını kullanmalıdır.)*

This avoids unrealistic performance caused by perfect labels unavailable online. *(Bu çevrimiçi kullanılamayan kusursuz etiketlerden kaynaklanan gerçekçi olmayan performansı önler.)*

---

# 110. Step Length Training Pipeline (Adım Uzunluğu Eğitim Hattı)

```text id="r24s35"
Validated Sessions
      ↓
Accepted Step Events
      ↓
Reference Distance Alignment
      ↓
Feature Extraction
      ↓
Session-Wise Split
      ↓
Training-Only Normalization
      ↓
Baseline Models
      ↓
Regression Models
      ↓
Validation Comparison
      ↓
Held-Out Test
```

---

# 111. Baseline Before ML (ML'den Önce Temel Yöntem)

The fixed and deterministic variable-step baselines will be evaluated before the learned model is accepted. *(Sabit ve deterministik değişken adım temel yöntemleri öğrenilmiş model kabul edilmeden önce değerlendirilecektir.)*

---

# 112. Hyperparameter Tuning (Hiperparametre Ayarı)

Regression hyperparameters will be selected using training and validation data only. *(Regresyon hiperparametreleri yalnızca eğitim ve doğrulama verisi kullanılarak seçilecektir.)*

The final test set will remain held out. *(Nihai test seti ayrılmış kalacaktır.)*

---

# 113. Cross-Validation Candidate (Cross-Validation Adayı)

If the number of independent training sessions is small, group-aware cross-validation may be used within development data. *(Bağımsız eğitim oturumu sayısı küçükse geliştirme verisi içerisinde group-aware cross-validation kullanılabilir.)*

Groups will correspond to recording sessions or route sessions. *(Gruplar kayıt oturumlarına veya rota oturumlarına karşılık gelecektir.)*

---

# 114. No Random Step-Level Cross-Validation (Rastgele Adım Seviyesi Cross-Validation Olmaması)

Randomly splitting individual steps from one session across folds is forbidden when those samples are strongly correlated. *(Tek bir oturumdan bireysel adımları güçlü şekilde korelasyonlu olduklarında fold'lar arasında rastgele bölmek yasaktır.)*

---

# 115. Feature Importance (Özellik Önemi)

Random Forest feature importance may be inspected as diagnostic evidence. *(Random Forest özellik önemi tanısal kanıt olarak incelenebilir.)*

It will not automatically be interpreted as causal importance. *(Otomatik olarak nedensel önem şeklinde yorumlanmayacaktır.)*

---

# 116. Linear Coefficient Analysis (Doğrusal Katsayı Analizi)

Linear Regression coefficients may be inspected after proper feature scaling. *(Linear Regression katsayıları uygun özellik ölçeklemesinden sonra incelenebilir.)*

This may help identify whether cadence or acceleration amplitude contributes meaningfully to the learned model. *(Bu kadans veya ivme genliğinin öğrenilmiş modele anlamlı şekilde katkıda bulunup bulunmadığını belirlemeye yardımcı olabilir.)*

---

# 117. Residual Analysis (Residual Analizi)

The final regression evaluation will examine prediction residuals. *(Nihai regresyon değerlendirmesi tahmin residual'larını inceleyecektir.)*

```text id="r24s36"
e_i =
L_hat_i - L_ref_i
```

---

# 118. Residual Versus Speed Context (Residual ile Hız Bağlamı)

Residuals may be analyzed across slow, normal, fast walking, and running segments where labels permit. *(Etiketler izin verdiğinde residual'lar yavaş, normal, hızlı yürüyüş ve koşma segmentleri genelinde analiz edilebilir.)*

This may reveal systematic model bias by motion intensity. *(Bu hareket yoğunluğuna göre sistematik model bias'ını ortaya çıkarabilir.)*

---

# 119. Residual Versus Turning (Residual ile Dönüş)

Residuals may also be analyzed for straight and turning steps. *(Residual'lar düz ve dönüş adımları için de analiz edilebilir.)*

This will determine whether turning requires separate treatment. *(Bu dönüşün ayrı yönetim gerektirip gerektirmediğini belirleyecektir.)*

---

# 120. Residual Versus Feature Range (Residual ile Özellik Aralığı)

Large errors at extreme cadence or acceleration values may indicate out-of-distribution behavior. *(Aşırı kadans veya ivme değerlerinde büyük hatalar dağılım dışı davranışı gösterebilir.)*

---

# 121. Error Distribution (Hata Dağılımı)

Mean error alone is insufficient. *(Yalnızca ortalama hata yeterli değildir.)*

Median, standard deviation, selected percentiles, and extreme residuals may also be reported. *(Medyan, standart sapma, seçilmiş yüzdelikler ve aşırı residual değerleri de raporlanabilir.)*

---

# 122. Model Failure Cases Remain Visible (Model Hata Durumları Görünür Kalır)

Difficult sessions will not be silently removed because they worsen the model score. *(Zor oturumlar model skorunu kötüleştirdiği için sessizce kaldırılmayacaktır.)*

Exclusion requires a documented data-integrity or protocol reason. *(Hariç tutma dokümante edilmiş veri bütünlüğü veya protokol nedeni gerektirir.)*

---

# 123. Training Artifact Structure (Eğitim Artifact Yapısı)

```text id="r24s37"
ml/
└── step_length/
    ├── configs/
    ├── datasets/
    ├── features/
    ├── baselines/
    ├── models/
    ├── evaluation/
    └── exports/
```

The exact folder names may change without altering the design. *(Kesin klasör isimleri tasarımı değiştirmeden değişebilir.)*

---

# 124. Model Registry Entry (Model Registry Girdisi)

```text id="r24s38"
StepLengthModelRegistryEntry
- modelId
- version
- algorithm
- featureSchemaVersion
- preprocessingVersion
- trainingDatasetId
- trainingRunId
- labelSourceType
- validationMetrics
- testMetrics
- deploymentStatus
```

---

# 125. Classical Model Serialization (Klasik Model Serialization)

If the final estimator is Linear Regression or Random Forest, NAVGUARD will use a deterministic documented deployment representation. *(Nihai tahmin motoru Linear Regression veya Random Forest ise NAVGUARD deterministik dokümante edilmiş deployment temsili kullanacaktır.)*

The model does not need to be forced into a neural runtime if a simpler implementation is safer and reproducible. *(Daha basit uygulama daha güvenli ve tekrarlanabilir ise model sinir ağı çalışma zamanına zorlanmak zorunda değildir.)*

---

# 126. Linear Model Mobile Deployment (Doğrusal Model Mobil Deployment)

A final Linear Regression model could be implemented directly from frozen coefficients and normalization metadata. *(Nihai Linear Regression modeli sabitlenmiş katsayılardan ve normalizasyon metadata bilgisinden doğrudan uygulanabilir.)*

This would avoid unnecessary inference-runtime overhead. *(Bu gereksiz çıkarım çalışma zamanı yükünü önler.)*

---

# 127. Random Forest Mobile Deployment (Random Forest Mobil Deployment)

Random Forest deployment strategy will depend on the selected final implementation path. *(Random Forest deployment stratejisi seçilen nihai uygulama yoluna bağlı olacaktır.)*

Deployment complexity will form part of model selection. *(Deployment karmaşıklığı model seçiminin parçasını oluşturacaktır.)*

---

# 128. Neural Regressor Deployment (Sinir Ağı Regresörü Deployment)

If a small neural regressor is selected, it may be exported as a versioned `.tflite` artifact for LiteRT inference. *(Küçük sinir ağı regresörü seçilirse LiteRT çıkarımı için sürümlenmiş `.tflite` artifact'ı olarak export edilebilir.)*

The same Python-to-Android parity requirements defined for Motion Classification will apply. *(Hareket Sınıflandırma için tanımlanan aynı Python-Android eşdeğerlik gereksinimleri uygulanacaktır.)*

---

# 129. No Mandatory Neural Deployment (Zorunlu Sinir Ağı Deployment Olmaması)

Step-length estimation does not need a neural model to satisfy project requirements. *(Adım uzunluğu tahmini proje gereksinimlerini karşılamak için sinir ağı modeline ihtiyaç duymaz.)*

---

# 130. Mobile Runtime Cost (Mobil Çalışma Zamanı Maliyeti)

Step-length inference occurs once per accepted step rather than at raw sensor frequency. *(Adım uzunluğu çıkarımı ham sensör frekansında değil kabul edilmiş adım başına bir kez gerçekleşir.)*

This keeps runtime cost relatively small for classical or compact learned models. *(Bu klasik veya kompakt öğrenilmiş modeller için çalışma zamanı maliyetini nispeten düşük tutar.)*

---

# 131. Step Timestamp (Adım Zaman Damgası)

Each step-length estimate will retain the timestamp of the accepted step it describes. *(Her adım uzunluğu tahmini açıkladığı kabul edilmiş adımın zaman damgasını koruyacaktır.)*

---

# 132. Late Estimate Policy (Geç Tahmin Politikası)

A step-length estimate arriving after the PDR process has already committed the step must not silently rewrite past live navigation state. *(PDR süreci adımı zaten kesinleştirdikten sonra gelen adım uzunluğu tahmini geçmiş canlı navigasyon durumunu sessizce yeniden yazmamalıdır.)*

The inference path must therefore complete before the step propagation deadline or fall back deterministically. *(Bu nedenle çıkarım hattı adım ilerletme deadline'ından önce tamamlanmalı veya deterministik geri dönüşe geçmelidir.)*

---

# 133. Prediction Deadline (Tahmin Deadline'ı)

The maximum useful prediction latency will be determined from measured step-event processing behavior. *(Maksimum kullanışlı tahmin gecikmesi ölçülmüş adım olayı işleme davranışından belirlenecektir.)*

---

# 134. Fallback Hierarchy (Geri Dönüş Hiyerarşisi)

```text id="r24s39"
Preferred Learned Model
(Tercih Edilen Öğrenilmiş Model)
        ↓ unavailable / invalid
Deterministic Variable Step
(Deterministik Değişken Adım)
        ↓ unavailable / invalid
Calibrated Fixed Step
(Kalibre Edilmiş Sabit Adım)
```

The hierarchy guarantees a usable `L_k` when a valid step exists. *(Hiyerarşi geçerli bir adım mevcut olduğunda kullanılabilir `L_k` sağlar.)*

---

# 135. Fallback Must Be Logged (Geri Dönüş Kaydedilmelidir)

Every fallback event during formal experiments will be identifiable in logs. *(Resmî deneyler sırasında her geri dönüş olayı kayıtlarda tanımlanabilir olacaktır.)*

---

# 136. Fallback Does Not Mean Failure of PDR (Geri Dönüş PDR Hatası Anlamına Gelmez)

A learned model failure merely changes the step-length method. *(Öğrenilmiş model hatası yalnızca adım uzunluğu yöntemini değiştirir.)*

PDR can continue with deterministic estimation. *(PDR deterministik tahminle devam edebilir.)*

---

# 137. Invalid Learned Output (Geçersiz Öğrenilmiş Çıktı)

NaN, infinite, malformed, or severely implausible predictions will be rejected. *(NaN, sonsuz, bozuk veya ciddi şekilde fiziksel olarak mantıksız tahminler reddedilecektir.)*

---

# 138. Missing Features (Eksik Özellikler)

A learned estimator requiring mandatory features will not receive fabricated zeros when those features are unavailable unless the model was explicitly trained for that missing-data behavior. *(Zorunlu özellikler gerektiren öğrenilmiş tahmin motoru bu özellikler kullanılamadığında model açıkça bu eksik veri davranışı için eğitilmedikçe uydurulmuş sıfırlar almayacaktır.)*

---

# 139. Motion Class Unavailable (Hareket Sınıfı Kullanılamaz)

If the selected learned model requires motion class but the motion classifier is unavailable, the system may fall back to a model variant that does not require the class or to the deterministic estimator. *(Seçilen öğrenilmiş model hareket sınıfı gerektirir ancak hareket sınıflandırıcı kullanılamazsa sistem sınıf gerektirmeyen model varyantına veya deterministik tahmin motoruna geri dönebilir.)*

The final fallback path will be frozen after model selection. *(Nihai geri dönüş yolu model seçiminden sonra sabitlenecektir.)*

---

# 140. Step Length Quality Engine Integration (Adım Uzunluğu Kalite Motoru Entegrasyonu)

The Step Length Estimation Model will expose validity and uncertainty information to the Sensor Confidence & Quality Engine. *(Adım Uzunluğu Tahmin Modeli geçerlilik ve belirsizlik bilgisini Sensör Güven ve Kalite Motoruna sunacaktır.)*

---

# 141. Step Length Quality Inputs (Adım Uzunluğu Kalite Girdileri)

Candidate quality inputs include estimator type. *(Aday kalite girdileri tahmin motoru türünü içerir.)*

Candidate quality inputs include detector confidence. *(Aday kalite girdileri algılayıcı güvenini içerir.)*

Candidate quality inputs include motion-class confidence. *(Aday kalite girdileri hareket sınıfı güvenini içerir.)*

Candidate quality inputs include feature-range plausibility. *(Aday kalite girdileri özellik aralığı makullüğünü içerir.)*

Candidate quality inputs include model residual profile. *(Aday kalite girdileri model residual profilini içerir.)*

---

# 142. Step Length Quality States (Adım Uzunluğu Kalite Durumları)

```text id="r24s40"
GOOD
USABLE
DEGRADED
UNRELIABLE
UNAVAILABLE
```

These will map into the common Quality Engine state model. *(Bunlar ortak Kalite Motoru durum modeline eşlenecektir.)*

---

# 143. EKF Integration (EKF Entegrasyonu)

The accepted step-length estimate will enter the nonlinear PDR process model as `L_k`. *(Kabul edilmiş adım uzunluğu tahmini doğrusal olmayan PDR süreç modeline `L_k` olarak girecektir.)*

The associated validated variance will influence process noise. *(İlişkili doğrulanmış varyans süreç gürültüsünü etkileyecektir.)*

---

# 144. EKF Step-Length Noise Mapping (EKF Adım Uzunluğu Gürültü Eşlemesi)

The EKF process-noise contribution remains as defined in the fusion architecture. *(EKF süreç gürültüsü katkısı füzyon mimarisinde tanımlandığı gibi kalır.)*

```text id="r24s41"
G_L =

[ sin(ψ) ]
[ cos(ψ) ]
[   0    ]
```

---

# 145. Step-Length Covariance Contribution (Adım Uzunluğu Kovaryans Katkısı)

```text id="r24s42"
Q_L =
G_L σL,k² G_Lᵀ
```

This propagates step-length uncertainty into East and North covariance. *(Bu adım uzunluğu belirsizliğini Doğu ve Kuzey kovaryansına ilerletir.)*

---

# 146. Different Methods May Have Different Q (Farklı Yöntemler Farklı Q Değerlerine Sahip Olabilir)

The fixed-step baseline, deterministic variable estimator, and learned estimator may have different validated residual variance. *(Sabit adım temeli, deterministik değişken tahmin motoru ve öğrenilmiş tahmin motoru farklı doğrulanmış residual varyanslarına sahip olabilir.)*

The EKF should reflect this difference. *(EKF bu farkı yansıtmalıdır.)*

---

# 147. Lower Error Does Not Mean Zero Uncertainty (Daha Düşük Hata Sıfır Belirsizlik Anlamına Gelmez)

Even the best learned model will retain nonzero prediction uncertainty. *(En iyi öğrenilmiş model bile sıfır olmayan tahmin belirsizliğini koruyacaktır.)*

---

# 148. Step Length Does Not Correct Heading (Adım Uzunluğu Yönü Düzeltmez)

The step-length estimator controls displacement magnitude, not global direction. *(Adım uzunluğu tahmin motoru yer değiştirme büyüklüğünü kontrol eder, global yönü değil.)*

Heading remains the responsibility of the Heading Estimation System and EKF heading state. *(Yön, Yön Tahmin Sistemi ve EKF yön durumunun sorumluluğunda kalır.)*

---

# 149. Step Length Does Not Correct GNSS Drift (Adım Uzunluğu GNSS Sürüklenmesini Düzeltmez)

Step-length estimation is a local PDR component and does not provide an absolute geographic correction. *(Adım uzunluğu tahmini yerel PDR bileşenidir ve mutlak coğrafi düzeltme sağlamaz.)*

---

# 150. Step Length and ARCore (Adım Uzunluğu ve ARCore)

ARCore may independently constrain local displacement in the fused architecture. *(ARCore füzyon mimarisinde yerel yer değiştirmeyi bağımsız olarak sınırlayabilir.)*

This does not remove the value of accurate step length because PDR remains active during ARCore degradation or loss. *(Bu doğru adım uzunluğunun değerini ortadan kaldırmaz çünkü PDR ARCore bozulması veya kaybı sırasında aktif kalır.)*

---

# 151. Step Length Model Logging (Adım Uzunluğu Model Kaydı)

Formal sessions will record every accepted step-length estimate. *(Resmî oturumlar her kabul edilmiş adım uzunluğu tahminini kaydedecektir.)*

```text id="r24s43"
timestamp_ns,
step_id,
method_id,
estimated_length_m,
uncertainty_variance,
quality_state,
motion_context,
fallback_used
```

---

# 152. Feature Logging (Özellik Kaydı)

Development or diagnostic sessions may additionally log the feature vector used for each prediction. *(Geliştirme veya tanı oturumları ayrıca her tahmin için kullanılan özellik vektörünü kaydedebilir.)*

This will support offline reproduction. *(Bu çevrimdışı yeniden üretimi destekleyecektir.)*

---

# 153. Formal Benchmark Logging Balance (Resmî Benchmark Kayıt Dengesi)

Feature logging may be reduced if it creates unnecessary runtime overhead and the same features can be deterministically reconstructed from stored raw data. *(Özellik kaydı gereksiz çalışma zamanı yükü oluşturur ve aynı özellikler saklanan ham veriden deterministik olarak yeniden oluşturulabilirse azaltılabilir.)*

---

# 154. Method ID (Yöntem ID'si)

Each estimator will have a stable method identifier. *(Her tahmin motoru kararlı bir yöntem tanımlayıcısına sahip olacaktır.)*

```text id="r24s44"
FIXED
WEINBERG
LINEAR_REGRESSION
RANDOM_FOREST
NEURAL_REGRESSOR
```

---

# 155. Model Version (Model Sürümü)

Learned estimators will additionally carry a model version. *(Öğrenilmiş tahmin motorları ayrıca model sürümü taşıyacaktır.)*

---

# 156. Configuration Snapshot (Yapılandırma Anlık Görüntüsü)

```text id="r24s45"
stepLengthMethod
modelId
modelVersion
featureSchemaVersion
preprocessingVersion
motionContextPolicy
fallbackPolicy
uncertaintyProfile
plausibilityPolicy
```

---

# 157. Replay Support (Replay Desteği)

Stored sensor and step data should allow step-length estimation to be replayed offline. *(Saklanan sensör ve adım verisi adım uzunluğu tahmininin çevrimdışı replay edilmesine izin vermelidir.)*

---

# 158. Replay Determinism (Replay Determinizmi)

The same accepted steps, features, method configuration, and model artifact should produce equivalent step-length estimates within numerical tolerance. *(Aynı kabul edilmiş adımlar, özellikler, yöntem yapılandırması ve model artifact'ı sayısal tolerans içerisinde eşdeğer adım uzunluğu tahminleri üretmelidir.)*

---

# 159. PDR Replay Comparison (PDR Replay Karşılaştırması)

One recorded session may be replayed with several step-length methods while keeping step detection and heading fixed. *(Tek kaydedilmiş oturum adım tespiti ve yön sabit tutulurken birkaç adım uzunluğu yöntemiyle replay edilebilir.)*

This will be the preferred method for clean ablation. *(Bu temiz ablation için tercih edilen yöntem olacaktır.)*

---

# 160. Unit Test — Fixed Step (Birim Testi — Sabit Adım)

Given `L_fixed = L`, every accepted walking step must return exactly `L` within floating-point tolerance. *(`L_fixed = L` verildiğinde her kabul edilmiş yürüyüş adımı floating-point toleransı içerisinde tam olarak `L` döndürmelidir.)*

---

# 161. Unit Test — Weinberg Formula (Birim Testi — Weinberg Formülü)

Known acceleration extrema and coefficient `K` must produce the expected deterministic result. *(Bilinen ivme ekstremumları ve `K` katsayısı beklenen deterministik sonucu üretmelidir.)*

---

# 162. Unit Test — Feature Extraction (Birim Testi — Özellik Çıkarma)

A known accepted-step waveform must produce the expected feature vector. *(Bilinen kabul edilmiş adım dalga biçimi beklenen özellik vektörünü üretmelidir.)*

---

# 163. Unit Test — Feature Order (Birim Testi — Özellik Sırası)

The feature vector order must match the frozen model schema exactly. *(Özellik vektörü sırası sabitlenmiş model şemasıyla tam olarak eşleşmelidir.)*

---

# 164. Unit Test — Missing Feature (Birim Testi — Eksik Özellik)

A missing mandatory feature must trigger invalidation or fallback according to policy. *(Eksik zorunlu özellik politikaya göre geçersiz kılma veya geri dönüş tetiklemelidir.)*

---

# 165. Unit Test — Invalid Prediction (Birim Testi — Geçersiz Tahmin)

NaN or infinite regression output must never reach PDR. *(NaN veya sonsuz regresyon çıktısı PDR'ye hiçbir zaman ulaşmamalıdır.)*

---

# 166. Unit Test — Out-of-Range Prediction (Birim Testi — Aralık Dışı Tahmin)

A synthetic severely implausible step-length prediction must trigger the frozen fallback behavior. *(Sentetik ciddi şekilde fiziksel olarak mantıksız adım uzunluğu tahmini sabitlenmiş geri dönüş davranışını tetiklemelidir.)*

---

# 167. Unit Test — Uncertainty Mapping (Birim Testi — Belirsizlik Eşleme)

The selected method and quality state must produce the configured `σL²` profile. *(Seçilen yöntem ve kalite durumu yapılandırılmış `σL²` profilini üretmelidir.)*

---

# 168. Integration Test — Step Detection to Step Length (Entegrasyon Testi — Adım Tespitinden Adım Uzunluğuna)

Only accepted steps must create step-length estimation events. *(Yalnızca kabul edilmiş adımlar adım uzunluğu tahmin olayları oluşturmalıdır.)*

Rejected detector candidates must not receive normal navigation displacement. *(Reddedilmiş algılayıcı adayları normal navigasyon yer değiştirmesi almamalıdır.)*

---

# 169. Integration Test — Step Length to PDR (Entegrasyon Testi — Adım Uzunluğundan PDR'ye)

A known `L_k` and heading must generate the expected East and North displacement. *(Bilinen `L_k` ve yön beklenen Doğu ve Kuzey yer değiştirmesini üretmelidir.)*

---

# 170. Integration Test — Step Length to EKF (Entegrasyon Testi — Adım Uzunluğundan EKF'ye)

Changing `σL²` while keeping the nominal step length fixed must affect predicted position covariance without changing nominal displacement. *(Nominal adım uzunluğu sabit tutulurken `σL²` değerini değiştirmek nominal yer değiştirmeyi değiştirmeden tahmin edilen konum kovaryansını etkilemelidir.)*

---

# 171. Integration Test — Motion Context (Entegrasyon Testi — Hareket Bağlamı)

A motion-conditioned model must use the motion context aligned with the accepted step timestamp. *(Hareket koşullu model kabul edilmiş adım zaman damgasıyla hizalanmış hareket bağlamını kullanmalıdır.)*

---

# 172. Integration Test — Motion AI Failure (Entegrasyon Testi — Hareket Yapay Zekâ Hatası)

If a learned step-length model requires motion context and the motion classifier fails, deterministic fallback must remain available. *(Öğrenilmiş adım uzunluğu modeli hareket bağlamı gerektirir ve hareket sınıflandırıcı başarısız olursa deterministik geri dönüş kullanılabilir kalmalıdır.)*

---

# 173. Integration Test — Late Prediction (Entegrasyon Testi — Geç Tahmin)

A deliberately delayed learned prediction must not retroactively rewrite an already committed real-time PDR step. *(Bilinçli olarak geciktirilmiş öğrenilmiş tahmin zaten kesinleşmiş gerçek zamanlı PDR adımını geriye dönük yeniden yazmamalıdır.)*

---

# 174. Physical Test — Known Straight Distance (Fiziksel Test — Bilinen Düz Mesafe)

A controlled straight route with known distance will compare all retained step-length methods. *(Bilinen mesafeye sahip kontrollü düz rota korunan tüm adım uzunluğu yöntemlerini karşılaştıracaktır.)*

---

# 175. Physical Test — Slow Walking (Fiziksel Test — Yavaş Yürüyüş)

A slow walking route will test whether adaptive models reduce bias compared with one fixed value. *(Yavaş yürüyüş rotası adaptif modellerin tek sabit değere göre bias'ı azaltıp azaltmadığını test edecektir.)*

---

# 176. Physical Test — Normal Walking (Fiziksel Test — Normal Yürüyüş)

A normal walking route will establish the primary pedestrian baseline. *(Normal yürüyüş rotası temel yaya referansını oluşturacaktır.)*

---

# 177. Physical Test — Faster Walking (Fiziksel Test — Daha Hızlı Yürüyüş)

A safely faster walking route will test whether cadence and acceleration features capture increased step length. *(Güvenli şekilde daha hızlı yürüyüş rotası kadans ve ivme özelliklerinin artan adım uzunluğunu yakalayıp yakalamadığını test edecektir.)*

---

# 178. Physical Test — Running (Fiziksel Test — Koşma)

Controlled running remains required for Motion Classification coverage. A separate controlled-running step-length evaluation is required only when the optional running-specific learned step-length experiment is executed; omitting that experiment does not change the frozen Motion Classification schema. *(Kontrollü koşma Motion Classification coverage için zorunlu kalır. Ayrı controlled-running step-length evaluation yalnızca optional running-specific learned step-length experiment yürütüldüğünde gereklidir; bu experiment'ın yapılmaması frozen Motion Classification schema'yı değiştirmez.)*

---

# 179. Physical Test — Turn-Heavy Route (Fiziksel Test — Dönüş Yoğun Rota)

A turn-heavy route will test whether straight-walking calibration remains adequate during turns. *(Dönüş yoğun rota düz yürüyüş kalibrasyonunun dönüşler sırasında yeterli kalıp kalmadığını test edecektir.)*

---

# 180. Physical Test — Walk-Stop-Walk (Fiziksel Test — Yürü-Dur-Yürü)

A walk-stop-walk session will verify that no spurious step-length predictions cause displacement during true stationary periods when no valid steps exist. *(Yürü-dur-yürü oturumu hiçbir geçerli adım bulunmadığında gerçek sabit dönemlerde sahte adım uzunluğu tahminlerinin yer değiştirme oluşturmadığını doğrulayacaktır.)*

---

# 181. Step Length Evaluation Table (Adım Uzunluğu Değerlendirme Tablosu)

```text id="r24s46"
Method
Label Level
MAE
RMSE
Bias
Route Distance Error
Route Distance Error %
PDR Final Position Error
Runtime Cost
Fallback Rate
```

Metrics unsupported by label quality will be marked unavailable rather than fabricated. *(Etiket kalitesi tarafından desteklenmeyen metrikler uydurulmak yerine kullanılamaz olarak işaretlenecektir.)*

---

# 182. Runtime Cost Metric (Çalışma Zamanı Maliyeti Metriği)

Prediction runtime may be measured for learned methods. *(Tahmin çalışma süresi öğrenilmiş yöntemler için ölçülebilir.)*

The model executes once per accepted step, so latency requirements are less strict than high-frequency sensor processing but must remain operationally safe. *(Model kabul edilmiş adım başına bir kez çalıştığı için gecikme gereksinimleri yüksek frekanslı sensör işlemeye göre daha gevşektir ancak operasyonel olarak güvenli kalmalıdır.)*

---

# 183. Fallback Rate Metric (Geri Dönüş Oranı Metriği)

```text id="r24s47"
FallbackRate =
fallback_steps
────────────── × 100
accepted_steps
```

A high fallback rate may indicate a model or feature-availability problem. *(Yüksek geri dönüş oranı model veya özellik kullanılabilirlik problemi gösterebilir.)*

---

# 184. Prediction Coverage (Tahmin Kapsamı)

The percentage of accepted steps receiving valid learned predictions may be reported. *(Geçerli öğrenilmiş tahmin alan kabul edilmiş adımların yüzdesi raporlanabilir.)*

---

# 185. Model Retention Gate (Model Koruma Kapısı)

A learned step-length model will be retained only if it provides consistent held-out benefit over the selected deterministic baseline. *(Öğrenilmiş adım uzunluğu modeli yalnızca seçilen deterministik temele göre tutarlı ayrılmış fayda sağlarsa korunacaktır.)*

---

# 186. Practical Benefit Matters (Pratik Fayda Önemlidir)

A tiny statistical improvement that adds deployment complexity and unstable fallback behavior may not justify retention. *(Deployment karmaşıklığı ve kararsız geri dönüş davranışı ekleyen çok küçük istatistiksel iyileştirme modelin korunmasını gerekçelendirmeyebilir.)*

---

# 187. Deterministic Model May Win (Deterministik Model Kazanabilir)

If the deterministic variable-step model performs as well as or better than learned regressors, NAVGUARD will use the deterministic model. *(Deterministik değişken adım modeli öğrenilmiş regresörler kadar iyi veya daha iyi performans gösterirse NAVGUARD deterministik modeli kullanacaktır.)*

This remains a scientifically valid outcome. *(Bu bilimsel olarak geçerli bir sonuç olarak kalır.)*

---

# 188. Linear Regression May Win (Linear Regression Kazanabilir)

If Linear Regression provides comparable accuracy with better interpretability and deployment simplicity, it may become the final model. *(Linear Regression daha iyi yorumlanabilirlik ve deployment basitliğiyle karşılaştırılabilir doğruluk sağlarsa nihai model olabilir.)*

---

# 189. Random Forest May Win (Random Forest Kazanabilir)

Random Forest Regressor may become the final learned method if it produces meaningful nonlinear improvement without unacceptable deployment cost. *(Random Forest Regressor kabul edilemez deployment maliyeti olmadan anlamlı doğrusal olmayan iyileştirme üretirse nihai öğrenilmiş yöntem olabilir.)*

---

# 190. Neural Model May Win (Sinir Ağı Modeli Kazanabilir)

A neural regressor may become final only if its improvement clearly exceeds the simpler alternatives after accounting for mobile cost. *(Sinir ağı regresörü yalnızca mobil maliyet dikkate alındıktan sonra iyileştirmesi daha basit alternatifleri açık şekilde aşarsa nihai olabilir.)*

---

# 191. Negative Result Reporting (Negatif Sonuç Raporlama)

If learned step-length estimation fails to improve PDR, that result will be documented. *(Öğrenilmiş adım uzunluğu tahmini PDR'yi iyileştiremezse bu sonuç dokümante edilecektir.)*

The feature will then remain disabled in the final navigation profile. *(Özellik daha sonra nihai navigasyon profilinde devre dışı kalacaktır.)*

---

# 192. Minimum Successful Implementation (Minimum Başarılı Uygulama)

The minimum successful step-length subsystem requires a calibrated fixed-step baseline. *(Minimum başarılı adım uzunluğu alt sistemi kalibre edilmiş sabit adım temeli gerektirir.)*

It should additionally evaluate at least one deterministic variable-step method. *(Ayrıca en az bir deterministik değişken adım yöntemini değerlendirmelidir.)*

---

# 193. Target Successful Implementation (Hedef Başarılı Uygulama)

The target system will compare fixed, deterministic variable, Linear Regression, and Random Forest methods. *(Hedef sistem sabit, deterministik değişken, Linear Regression ve Random Forest yöntemlerini karşılaştıracaktır.)*

The best validated method will provide `L_k` and an uncertainty profile to EKF. *(En iyi doğrulanmış yöntem EKF'ye `L_k` ve belirsizlik profili sağlayacaktır.)*

---

# 194. Optional Enhancements (İsteğe Bağlı İyileştirmeler)

Optional enhancements may include a small neural regressor. *(İsteğe bağlı iyileştirmeler küçük sinir ağı regresörünü içerebilir.)*

Optional enhancements may include motion-specific model ensembles. *(İsteğe bağlı iyileştirmeler harekete özgü model ensemble'larını içerebilir.)*

Optional enhancements may include personalized online calibration outside formal benchmark intervals. *(İsteğe bağlı iyileştirmeler resmî benchmark aralıklarının dışında kişiselleştirilmiş çevrimiçi kalibrasyonu içerebilir.)*

---

# 195. Online Learning Is Not Required (Çevrimiçi Öğrenme Gerekli Değildir)

The final step-length estimator will not be required to retrain itself on the smartphone. *(Nihai adım uzunluğu tahmin motorunun akıllı telefon üzerinde kendini yeniden eğitmesi gerekmeyecektir.)*

---

# 196. No Ground Truth Adaptation During Evaluation (Değerlendirme Sırasında Ground Truth Adaptasyonu Olmaması)

The model must not adapt its coefficients using hidden Evaluation Mode GNSS ground truth during the denied interval. *(Model kesintili aralık sırasında gizli Değerlendirme Modu GNSS ground truth verisini kullanarak katsayılarını adapte etmemelidir.)*

---

# 197. Step Length Non-Goals (Adım Uzunluğu Olmayan Hedefler)

The model will not detect absolute geographic position. *(Model mutlak coğrafi konum tespit etmeyecektir.)*

The model will not correct heading. *(Model yönü düzeltmeyecektir.)*

The model will not create steps independently of Step Detection. *(Model Adım Tespitinden bağımsız adımlar oluşturmayacaktır.)*

The model will not require cloud inference. *(Model bulut çıkarımı gerektirmeyecektir.)*

---

# 198. Test IDs (Test ID'leri)

```text id="r24s48"
SL-DATA-001   Reference-distance integrity
SL-DATA-002   Step-count integrity
SL-DATA-003   Session split integrity
SL-DATA-004   Label-source traceability

SL-FEAT-001   Feature extraction correctness
SL-FEAT-002   Feature ordering
SL-FEAT-003   Training-only normalization
SL-FEAT-004   Missing-feature handling

SL-BASE-001   Fixed-step baseline
SL-BASE-002   Weinberg-style baseline

SL-ML-001     Linear Regression
SL-ML-002     Random Forest Regressor
SL-ML-003     Neural regressor if retained

SL-EVAL-001   MAE / RMSE where valid
SL-EVAL-002   Bias
SL-EVAL-003   Route distance error
SL-EVAL-004   Session-level consistency
SL-EVAL-005   PDR ablation

SL-NAV-001    Step Length → PDR
SL-NAV-002    Step Length → EKF Q
SL-NAV-003    Motion-conditioned estimation
SL-NAV-004    Fallback hierarchy

SL-MOB-001    Runtime prediction
SL-MOB-002    Invalid output fallback
SL-MOB-003    Late prediction handling
SL-MOB-004    Sustained navigation
```

---

# 199. Data Acceptance Criteria (Veri Kabul Kriterleri)

Reference distances used for calibration or evaluation must have documented origin. *(Kalibrasyon veya değerlendirme için kullanılan referans mesafeler dokümante edilmiş kökene sahip olmalıdır.)*

Step counts used for route-average labels must be independently validated. *(Rota ortalama etiketleri için kullanılan adım sayıları bağımsız olarak doğrulanmalıdır.)*

Session-wise split integrity must pass. *(Oturum bazlı ayrım bütünlüğü geçmelidir.)*

---

# 200. Label Acceptance Criteria (Etiket Kabul Kriterleri)

The dataset must explicitly distinguish per-step, segment-average, and route-average reference quality. *(Veri seti adım başına, segment ortalama ve rota ortalama referans kalitesini açıkça ayırt etmelidir.)*

Per-step MAE must not be reported from route-average labels as though exact step labels existed. *(Kesin adım etiketleri varmış gibi rota ortalama etiketlerinden adım başına MAE raporlanmamalıdır.)*

---

# 201. Baseline Acceptance Criteria (Temel Yöntem Kabul Kriterleri)

A calibrated fixed-step baseline must exist. *(Kalibre edilmiş sabit adım temeli mevcut olmalıdır.)*

A deterministic variable-step candidate must be evaluated. *(Deterministik değişken adım adayı değerlendirilmelidir.)*

---

# 202. Learned Model Acceptance Criteria (Öğrenilmiş Model Kabul Kriterleri)

At least Linear Regression and Random Forest Regressor will be evaluated if label quality is sufficient for supervised regression. *(Etiket kalitesi supervised regresyon için yeterliyse en az Linear Regression ve Random Forest Regressor değerlendirilecektir.)*

---

# 203. Learned Model Retention Criterion (Öğrenilmiş Model Koruma Kriteri)

The learned estimator must demonstrate consistent held-out improvement over the selected deterministic baseline before becoming navigation-enabled. *(Öğrenilmiş tahmin motoru navigasyon etkin hale gelmeden önce seçilen deterministik temele göre tutarlı ayrılmış iyileştirme göstermelidir.)*

---

# 204. Feature Acceptance Criteria (Özellik Kabul Kriterleri)

Every final feature must be causal. *(Her nihai özellik nedensel olmalıdır.)*

Every final feature must have documented units and definition. *(Her nihai özellik dokümante edilmiş birime ve tanıma sahip olmalıdır.)*

Every final feature must be reproducible on Android if used by the deployed model. *(Deployment edilen model tarafından kullanılıyorsa her nihai özellik Android üzerinde yeniden üretilebilir olmalıdır.)*

---

# 205. Fallback Acceptance Criteria (Geri Dönüş Kabul Kriterleri)

Learned-model failure must not stop PDR. *(Öğrenilmiş model hatası PDR'yi durdurmamalıdır.)*

The deterministic fallback hierarchy must always remain available for valid accepted steps. *(Deterministik geri dönüş hiyerarşisi geçerli kabul edilmiş adımlar için her zaman kullanılabilir kalmalıdır.)*

---

# 206. EKF Acceptance Criteria (EKF Kabul Kriterleri)

Every accepted step-length estimate must provide either validated per-step uncertainty or a validated method-level uncertainty profile. *(Her kabul edilmiş adım uzunluğu tahmini ya doğrulanmış adım başına belirsizlik ya da doğrulanmış yöntem seviyesi belirsizlik profili sağlamalıdır.)*

Changing the uncertainty profile must affect EKF process covariance. *(Belirsizlik profilini değiştirmek EKF süreç kovaryansını etkilemelidir.)*

---

# 207. Research Integrity Acceptance Criteria (Araştırma Bütünlüğü Kabul Kriterleri)

Final benchmark sessions must remain excluded from training and parameter calibration. *(Nihai benchmark oturumları eğitimden ve parametre kalibrasyonundan hariç kalmalıdır.)*

Ground truth must not become a hidden live feature. *(Ground truth gizli canlı özellik haline gelmemelidir.)*

Negative learned-model results must remain visible. *(Negatif öğrenilmiş model sonuçları görünür kalmalıdır.)*

---

# 208. Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kararlar)

NAVGUARD will always maintain a calibrated fixed-step baseline. *(NAVGUARD her zaman kalibre edilmiş sabit adım temelini koruyacaktır.)*

A deterministic variable-step method will be evaluated before learned regression is accepted. *(Öğrenilmiş regresyon kabul edilmeden önce deterministik değişken adım yöntemi değerlendirilecektir.)*

A Weinberg-style acceleration-amplitude relationship is the preferred first deterministic variable-step candidate. *(Weinberg-style ivme genliği ilişkisi tercih edilen ilk deterministik değişken adım adayıdır.)*

---

# 209. Model Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Model Kararları)

Linear Regression will be the simple learned regression baseline. *(Linear Regression basit öğrenilmiş regresyon temeli olacaktır.)*

Random Forest Regressor will be the primary nonlinear classical candidate. *(Random Forest Regressor temel doğrusal olmayan klasik aday olacaktır.)*

A neural regressor will be optional and will require experimental justification. *(Sinir ağı regresörü isteğe bağlı olacak ve deneysel gerekçe gerektirecektir.)*

---

# 210. Label Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Etiket Kararları)

NAVGUARD will explicitly distinguish exact per-step labels from segment-average and route-average labels. *(NAVGUARD kesin adım başına etiketleri segment ortalama ve rota ortalama etiketlerinden açıkça ayırt edecektir.)*

Evaluation claims will match the actual reference quality. *(Değerlendirme iddiaları gerçek referans kalitesiyle uyumlu olacaktır.)*

---

# 211. Leakage Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Veri Sızıntısı Kararları)

Train, validation, and test separation will occur at the physical session or route-session level. *(Train, validation ve test ayrımı fiziksel oturum veya rota-oturumu seviyesinde gerçekleşecektir.)*

GNSS ground truth will not be a live deployed feature during GNSS-denied navigation. *(GNSS ground truth GNSS kesintili navigasyon sırasında canlı deployment özelliği olmayacaktır.)*

---

# 212. Navigation Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Navigasyon Kararları)

Step-length estimation will operate only after Step Detection accepts a step. *(Adım uzunluğu tahmini yalnızca Adım Tespiti bir adımı kabul ettikten sonra çalışacaktır.)*

The output will provide displacement magnitude `L_k` rather than direction. *(Çıktı yön yerine `L_k` yer değiştirme büyüklüğü sağlayacaktır.)*

Heading will remain external to the step-length model. *(Yön adım uzunluğu modelinin dışında kalacaktır.)*

---

# 213. EKF Decisions Frozen by This Document (Bu Dokümanla Sabitlenen EKF Kararları)

The accepted step length will feed the EKF PDR process model. *(Kabul edilmiş adım uzunluğu EKF PDR süreç modeline girecektir.)*

Step-length uncertainty will contribute to `Q` through the defined `G_L σL² G_Lᵀ` relationship. *(Adım uzunluğu belirsizliği tanımlanan `G_L σL² G_Lᵀ` ilişkisi üzerinden `Q` değerine katkıda bulunacaktır.)*

---

# 214. Fallback Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Geri Dönüş Kararları)

The preferred fallback hierarchy will be learned estimator, deterministic variable estimator, and calibrated fixed estimator. *(Tercih edilen geri dönüş hiyerarşisi öğrenilmiş tahmin motoru, deterministik değişken tahmin motoru ve kalibre edilmiş sabit tahmin motoru şeklinde olacaktır.)*

Invalid learned predictions will not be silently applied. *(Geçersiz öğrenilmiş tahminler sessizce uygulanmayacaktır.)*

---

# 215. Decisions Pending Data (Veri Bekleyen Kararlar)

The final fixed walking step length remains pending physical calibration. *(Nihai sabit yürüyüş adım uzunluğu fiziksel kalibrasyonu beklemektedir.)*

The final Weinberg coefficient `K` remains pending calibration data. *(Nihai Weinberg `K` katsayısı kalibrasyon verisini beklemektedir.)*

The final feature set remains pending feature-ablation results. *(Nihai özellik seti özellik ablation sonuçlarını beklemektedir.)*

---

# 216. Additional Pending Decisions (Ek Bekleyen Kararlar)

The final label granularity remains pending the achievable reference method. *(Nihai etiket granülerliği elde edilebilir referans yöntemini beklemektedir.)*

The final regression model remains pending held-out comparison. *(Nihai regresyon modeli ayrılmış karşılaştırmayı beklemektedir.)*

The final motion-conditioned model strategy remains pending walking and running data. *(Nihai harekete koşullu model stratejisi yürüyüş ve koşma verisini beklemektedir.)*

---

# 217. Uncertainty Decisions Pending Calibration (Kalibrasyon Bekleyen Belirsizlik Kararları)

The final method-level `σL²` values remain pending residual analysis. *(Nihai yöntem seviyesi `σL²` değerleri residual analizini beklemektedir.)*

The final quality-to-uncertainty mapping remains pending validation data. *(Nihai kalite-belirsizlik eşlemesi doğrulama verisini beklemektedir.)*

---

# 218. Deployment Decisions Pending Model Selection (Model Seçimini Bekleyen Deployment Kararları)

The final mobile execution strategy depends on which estimator wins. *(Nihai mobil çalıştırma stratejisi hangi tahmin motorunun kazandığına bağlıdır.)*

A linear model may be implemented directly. *(Doğrusal model doğrudan uygulanabilir.)*

A Random Forest may require a dedicated deterministic runtime representation. *(Random Forest özel deterministik çalışma zamanı temsili gerektirebilir.)*

A neural model would use LiteRT-compatible deployment. *(Sinir ağı modeli LiteRT uyumlu deployment kullanacaktır.)*

---

# 219. Final Step Length Architecture Statement (Nihai Adım Uzunluğu Mimarisi Bildirimi)

**NAVGUARD will treat step length as a physically interpretable per-step displacement magnitude that is estimated only after the deterministic Step Detection System has accepted a pedestrian step.** *(NAVGUARD adım uzunluğunu yalnızca deterministik Adım Tespit Sistemi bir yaya adımını kabul ettikten sonra tahmin edilen fiziksel olarak yorumlanabilir adım başına yer değiştirme büyüklüğü olarak ele alacaktır.)*

**The subsystem will always preserve a calibrated fixed-step baseline and will evaluate a deterministic variable-step model, with a Weinberg-style acceleration-amplitude relationship serving as the preferred first adaptive baseline candidate.** *(Alt sistem her zaman kalibre edilmiş sabit adım temelini koruyacak ve Weinberg-style ivme genliği ilişkisi tercih edilen ilk adaptif temel aday olarak hizmet ederken deterministik değişken adım modelini değerlendirecektir.)*

**Linear Regression and Random Forest Regressor will be evaluated as the primary learned regression methods, while a neural regressor will remain optional and will be retained only if simpler approaches leave meaningful measurable performance available.** *(Linear Regression ve Random Forest Regressor temel öğrenilmiş regresyon yöntemleri olarak değerlendirilecek, sinir ağı regresörü ise isteğe bağlı kalacak ve yalnızca daha basit yaklaşımlar anlamlı ölçülebilir performans fırsatı bırakırsa korunacaktır.)*

**The project will explicitly distinguish exact per-step ground truth from segment-average and route-average distance labels, and no metric will claim greater reference precision than the data collection method actually provides.** *(Proje kesin adım başına ground truth ile segment ortalama ve rota ortalama mesafe etiketlerini açıkça ayırt edecek ve hiçbir metrik veri toplama yönteminin gerçekten sağladığından daha yüksek referans hassasiyeti iddia etmeyecektir.)*

**All supervised model development will use session-wise or route-session-wise train, validation, and test separation so that correlated steps from one physical recording cannot leak across experimental splits.** *(Tüm supervised model geliştirme oturum bazlı veya rota-oturumu bazlı train, validation ve test ayrımı kullanacak; böylece tek fiziksel kayıttan korelasyonlu adımlar deneysel ayrımlar arasında sızamayacaktır.)*

**A learned estimator will become navigation-enabled only if it demonstrates consistent held-out benefit over the selected deterministic baseline in step-length error, cumulative route-distance error, or downstream PDR performance without introducing unacceptable deployment complexity.** *(Öğrenilmiş tahmin motoru yalnızca adım uzunluğu hatasında, birikimli rota mesafe hatasında veya aşağı akış PDR performansında seçilen deterministik temele göre tutarlı ayrılmış fayda gösterir ve kabul edilemez deployment karmaşıklığı oluşturmazsa navigasyon etkin hale gelecektir.)*

**Every accepted estimate will provide `L_k` together with a validated step-specific or method-level uncertainty profile so that EKF process covariance can reflect uncertainty in travelled-distance propagation.** *(Her kabul edilmiş tahmin `L_k` ile birlikte doğrulanmış adım özelinde veya yöntem seviyesinde belirsizlik profili sağlayacak; böylece EKF süreç kovaryansı kat edilen mesafe ilerletmesindeki belirsizliği yansıtabilecektir.)*

**If the learned estimator becomes unavailable, stale, invalid, or unsupported by the current motion context, NAVGUARD will fall back to the deterministic variable-step estimator and then to the calibrated fixed-step baseline without stopping PDR navigation.** *(Öğrenilmiş tahmin motoru kullanılamaz, eski, geçersiz veya mevcut hareket bağlamı tarafından desteklenmeyen hale gelirse NAVGUARD PDR navigasyonunu durdurmadan deterministik değişken adım tahmin motoruna ve ardından kalibre edilmiş sabit adım temeline geri dönecektir.)*

---

# 220. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development Step Length Estimation Model Design Completed *(Doküman Durumu: Geliştirme Öncesi Adım Uzunluğu Tahmin Modeli Tasarımı Tamamlandı)*

**Requirement Level:** Target Enhancement *(Gereksinim Seviyesi: Hedef İyileştirme)*

**Minimum Baseline:** Calibrated Fixed Step Length *(Minimum Temel: Kalibre Edilmiş Sabit Adım Uzunluğu)*

**Adaptive Deterministic Candidate:** Weinberg-Style Variable Step Length *(Adaptif Deterministik Aday: Weinberg-Style Değişken Adım Uzunluğu)*

**Simple Learned Baseline:** Linear Regression *(Basit Öğrenilmiş Temel: Linear Regression)*

**Primary Nonlinear Learned Candidate:** Random Forest Regressor *(Temel Doğrusal Olmayan Öğrenilmiş Aday: Random Forest Regressor)*

**Neural Regressor:** Optional *(Sinir Ağı Regresörü: İsteğe Bağlı)*

**Primary Output:** `L_k` in metres *(Temel Çıktı: Metre Cinsinden `L_k`)*

**Uncertainty Output:** `σL²` or Method-Level Variance Profile *(Belirsizlik Çıktısı: `σL²` veya Yöntem Seviyesi Varyans Profili)*

**Step Source:** Accepted Step Events Only *(Adım Kaynağı: Yalnızca Kabul Edilmiş Adım Olayları)*

**Direction Source:** Heading Estimation System *(Yön Kaynağı: Yön Tahmin Sistemi)*

**GNSS as Live Feature During Denial:** Forbidden *(Kesinti Sırasında Canlı Özellik Olarak GNSS: Yasak)*

**Dataset Split:** Session-Wise / Route-Session-Wise *(Veri Seti Ayrımı: Oturum Bazlı / Rota-Oturumu Bazlı)*

**Label Types:** Per-Step / Segment-Average / Route-Average *(Etiket Türleri: Adım Başına / Segment Ortalama / Rota Ortalama)*

**False Per-Step Precision:** Forbidden *(Yanlış Adım Başına Hassasiyet İddiası: Yasak)*

**Primary Valid Regression Metric:** MAE Where Reference Quality Permits *(Temel Geçerli Regresyon Metriği: Referans Kalitesi İzin Verdiğinde MAE)*

**Additional Metrics:** RMSE / Bias / Route Distance Error / PDR Error *(Ek Metrikler: RMSE / Bias / Rota Mesafe Hatası / PDR Hatası)*

**Model Retention Rule:** Must Beat or Meaningfully Improve Deterministic Baseline *(Model Koruma Kuralı: Deterministik Temeli Geçmeli veya Anlamlı Şekilde İyileştirmeli)*

**Fallback 1:** Deterministic Variable Step *(Geri Dönüş 1: Deterministik Değişken Adım)*

**Fallback 2:** Calibrated Fixed Step *(Geri Dönüş 2: Kalibre Edilmiş Sabit Adım)*

**EKF Integration:** `L_k + σL² → Q` *(EKF Entegrasyonu: `L_k + σL² → Q`)*

**Final Fixed Step Length:** Pending Physical Calibration *(Nihai Sabit Adım Uzunluğu: Fiziksel Kalibrasyon Bekleniyor)*

**Final Weinberg Coefficient:** Pending Calibration *(Nihai Weinberg Katsayısı: Kalibrasyon Bekleniyor)*

**Final Feature Set:** Pending Ablation *(Nihai Özellik Seti: Ablation Bekleniyor)*

**Final Label Granularity:** Pending Reference-Method Capability *(Nihai Etiket Granülerliği: Referans Yöntem Yeteneği Bekleniyor)*

**Final Regression Model:** Pending Held-Out Comparison *(Nihai Regresyon Modeli: Ayrılmış Karşılaştırma Bekleniyor)*

**Final `σL²` Profiles:** Pending Residual Analysis *(Nihai `σL²` Profilleri: Residual Analizi Bekleniyor)*

**Final Mobile Deployment Strategy:** Pending Winning Model *(Nihai Mobil Deployment Stratejisi: Kazanan Model Bekleniyor)*

**Next Documentation Item:** 25 — Dataset Collection & Labeling Plan *(Sonraki Dokümantasyon Öğesi: 25 — Veri Seti Toplama ve Etiketleme Planı)*
