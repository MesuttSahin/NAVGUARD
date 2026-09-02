# 22 — Artificial Intelligence System (Yapay Zekâ Sistemi)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the overall artificial-intelligence architecture, supported AI tasks, training and inference boundaries, dataset isolation, model lifecycle, preprocessing parity, model registry, deployment strategy, fallback behavior, confidence handling, navigation integration, logging, reproducibility, evaluation, and acceptance criteria of NAVGUARD. *(Bu doküman, NAVGUARD'ın genel yapay zekâ mimarisini, desteklenen yapay zekâ görevlerini, eğitim ve çıkarım sınırlarını, veri seti izolasyonunu, model yaşam döngüsünü, ön işleme eşdeğerliğini, model kayıt sistemini, deployment stratejisini, geri dönüş davranışını, güven yönetimini, navigasyon entegrasyonunu, kaydı, tekrarlanabilirliği, değerlendirmeyi ve kabul kriterlerini tanımlar.)*

The artificial-intelligence layer will support the physical navigation system rather than replace the underlying navigation mathematics. *(Yapay zekâ katmanı temel navigasyon matematiğinin yerini almak yerine fiziksel navigasyon sistemini destekleyecektir.)*

NAVGUARD will use AI only where measurable experimental value can be demonstrated. *(NAVGUARD yapay zekâyı yalnızca ölçülebilir deneysel faydanın gösterilebildiği yerlerde kullanacaktır.)*

---

# 2. Primary AI Objectives (Temel Yapay Zekâ Hedefleri)

NAVGUARD will use artificial intelligence for motion-context classification. *(NAVGUARD hareket bağlamı sınıflandırması için yapay zekâ kullanacaktır.)*

NAVGUARD may additionally use machine learning for step-length estimation. *(NAVGUARD ayrıca adım uzunluğu tahmini için makine öğrenmesi kullanabilir.)*

The AI layer will not directly predict global geographic coordinates. *(Yapay zekâ katmanı doğrudan global coğrafi koordinat tahmin etmeyecektir.)*

---

# 3. AI System Scope (Yapay Zekâ Sistemi Kapsamı)

The mandatory AI capability is Motion Classification. *(Zorunlu yapay zekâ yeteneği Hareket Sınıflandırmasıdır.)*

The target secondary AI capability is Step Length Estimation. *(Hedef ikincil yapay zekâ yeteneği Adım Uzunluğu Tahminidir.)*

Additional AI tasks are outside the minimum project unless experiments identify a clear need. *(Deneyler açık bir ihtiyaç belirlemediği sürece ek yapay zekâ görevleri minimum projenin dışındadır.)*

---

# 4. AI Architecture Overview (Yapay Zekâ Mimarisi Genel Görünümü)

```text id="3xyy8e"
Sensor Streams
(Sensör Akışları)
      ↓
Preprocessing
(Ön İşleme)
      ↓
Window / Feature Construction
(Pencere / Özellik Oluşturma)
      ↓
 ┌─────────────────────┐
 │ Motion Classifier   │
 │ Hareket Sınıflayıcı │
 └─────────────────────┘
      ↓
Motion Context
(Hareket Bağlamı)
      │
      ├──────────────► Step Detection Context
      │                (Adım Tespit Bağlamı)
      │
      ├──────────────► Step Length Model
      │                (Adım Uzunluğu Modeli)
      │
      ├──────────────► Quality Engine
      │                (Kalite Motoru)
      │
      └──────────────► EKF Process Configuration
                       (EKF Süreç Yapılandırması)

Step Features
(Adım Özellikleri)
      ↓
 ┌─────────────────────┐
 │ Step Length Model   │
 │ Adım Uzunluğu Modeli│
 └─────────────────────┘
      ↓
Estimated Step Length
(Tahmini Adım Uzunluğu)
      ↓
PDR / EKF
```

---

# 5. AI Is a Supporting Layer (Yapay Zekâ Destekleyici Bir Katmandır)

AI will not become the only mechanism capable of operating NAVGUARD. *(Yapay zekâ NAVGUARD'ı çalıştırabilen tek mekanizma haline gelmeyecektir.)*

Deterministic fallback logic will remain available for every navigation-critical AI output. *(Navigasyon açısından kritik her yapay zekâ çıktısı için deterministik geri dönüş mantığı kullanılabilir kalacaktır.)*

---

# 6. AI Failure Must Not Stop Baseline Navigation (Yapay Zekâ Hatası Temel Navigasyonu Durdurmamalıdır)

If the motion model fails, deterministic step detection and baseline PDR must continue. *(Hareket modeli başarısız olursa deterministik adım tespiti ve temel PDR devam etmelidir.)*

If the learned step-length model fails, a deterministic step-length method must remain available. *(Öğrenilmiş adım uzunluğu modeli başarısız olursa deterministik bir adım uzunluğu yöntemi kullanılabilir kalmalıdır.)*

---

# 7. No AI Latitude-Longitude Predictor (Yapay Zekâ Enlem-Boylam Tahmincisi Olmaması)

NAVGUARD will not train a model whose direct output is latitude and longitude during GNSS-denied navigation. *(NAVGUARD GNSS kesintili navigasyon sırasında doğrudan enlem ve boylam çıktısı veren bir model eğitmeyecektir.)*

Such an approach would reduce physical interpretability and make reliable ground-truth isolation more difficult. *(Böyle bir yaklaşım fiziksel yorumlanabilirliği azaltır ve güvenilir ground truth izolasyonunu zorlaştırır.)*

---

# 8. Physics-Guided AI Principle (Fizik Güdümlü Yapay Zekâ İlkesi)

AI outputs will modify physically interpretable variables or operational context. *(Yapay zekâ çıktıları fiziksel olarak yorumlanabilir değişkenleri veya çalışma bağlamını değiştirecektir.)*

Examples include motion class and estimated pedestrian step length. *(Örnekler hareket sınıfını ve tahmini yaya adım uzunluğunu içerir.)*

The physical navigation equations remain explicit. *(Fiziksel navigasyon denklemleri açık kalır.)*

---

# 9. AI Task 1 — Motion Classification (Yapay Zekâ Görevi 1 — Hareket Sınıflandırması)

The primary model will classify short sensor windows into pedestrian motion contexts. *(Birincil model kısa sensör pencerelerini yaya hareket bağlamlarına sınıflandıracaktır.)*

The initial target classes are `STATIONARY`, `WALKING`, `RUNNING`, and `TURNING`. *(İlk hedef sınıflar `STATIONARY`, `WALKING`, `RUNNING` ve `TURNING` şeklindedir.)*

---

# 10. Motion Class Definition — STATIONARY (Hareket Sınıfı Tanımı — STATIONARY)

`STATIONARY` represents periods in which the pedestrian is not intentionally translating through the environment. *(`STATIONARY`, yayanın ortam içerisinde kasıtlı olarak yer değiştirmediği dönemleri temsil eder.)*

Small phone movements may still occur inside this class. *(Bu sınıf içerisinde küçük telefon hareketleri yine de meydana gelebilir.)*

---

# 11. Motion Class Definition — WALKING (Hareket Sınıfı Tanımı — WALKING)

`WALKING` represents ordinary pedestrian locomotion using normal walking gait. *(`WALKING`, normal yürüyüş gait'i kullanan sıradan yaya hareketini temsil eder.)*

This will be the standard PDR operating context. *(Bu standart PDR çalışma bağlamı olacaktır.)*

---

# 12. Motion Class Definition — RUNNING (Hareket Sınıfı Tanımı — RUNNING)

`RUNNING` represents faster locomotion with motion characteristics materially different from ordinary walking. *(`RUNNING`, normal yürüyüşten anlamlı şekilde farklı hareket özelliklerine sahip daha hızlı hareketi temsil eder.)*

Running may require different step timing or step-length behavior. *(Koşma farklı adım zamanlaması veya adım uzunluğu davranışı gerektirebilir.)*

---

# 13. Motion Class Definition — TURNING (Hareket Sınıfı Tanımı — TURNING)

`TURNING` represents periods in which rotational movement is a dominant short-term motion characteristic. *(`TURNING`, dönme hareketinin baskın kısa dönem hareket özelliği olduğu dönemleri temsil eder.)*

Turning may occur while the pedestrian continues taking steps. *(Dönüş yaya adım atmaya devam ederken meydana gelebilir.)*

---

# 14. Motion Classes Are Operational Contexts (Hareket Sınıfları Çalışma Bağlamlarıdır)

Motion classes are not top-level navigation modes. *(Hareket sınıfları üst seviye navigasyon modları değildir.)*

They provide context to the navigation pipeline while GNSS Mode, Evaluation Mode, or NAVGUARD Mode remains active independently. *(GNSS Modu, Değerlendirme Modu veya NAVGUARD Modu bağımsız olarak aktif kalırken navigasyon hattına bağlam sağlarlar.)*

---

# 15. Motion Classification Must Affect Navigation (Hareket Sınıflandırması Navigasyonu Etkilemelidir)

The motion classifier will not exist only to display labels on the screen. *(Hareket sınıflandırıcı yalnızca ekranda etiket göstermek için bulunmayacaktır.)*

Its output must influence at least one validated navigation behavior. *(Çıktısı en az bir doğrulanmış navigasyon davranışını etkilemelidir.)*

---

# 16. STATIONARY Navigation Effect (STATIONARY Navigasyon Etkisi)

A validated `STATIONARY` context may strengthen suppression of false step propagation. *(Doğrulanmış bir `STATIONARY` bağlamı yanlış adım ilerletmesini bastırmayı güçlendirebilir.)*

It may also influence process-noise selection or quality interpretation. *(Ayrıca süreç gürültüsü seçimini veya kalite yorumunu etkileyebilir.)*

---

# 17. WALKING Navigation Effect (WALKING Navigasyon Etkisi)

A validated `WALKING` context will permit normal pedestrian PDR behavior. *(Doğrulanmış bir `WALKING` bağlamı normal yaya PDR davranışına izin verecektir.)*

The normal walking step-length profile may be selected. *(Normal yürüyüş adım uzunluğu profili seçilebilir.)*

---

# 18. RUNNING Navigation Effect (RUNNING Navigasyon Etkisi)

A validated `RUNNING` context may select a faster-cadence step-detector configuration or running-specific step-length profile. *(Doğrulanmış bir `RUNNING` bağlamı daha hızlı kadanslı adım algılayıcı yapılandırmasını veya koşmaya özgü adım uzunluğu profilini seçebilir.)*

Any such effect must be validated before being enabled in the final benchmark. *(Böyle herhangi bir etki nihai benchmark'ta etkinleştirilmeden önce doğrulanmalıdır.)*

---

# 19. TURNING Navigation Effect (TURNING Navigasyon Etkisi)

A validated `TURNING` context may influence heading-confidence interpretation or process-noise configuration. *(Doğrulanmış bir `TURNING` bağlamı yön güven yorumunu veya süreç gürültüsü yapılandırmasını etkileyebilir.)*

It must not automatically suppress legitimate walking steps during a turn. *(Dönüş sırasında geçerli yürüyüş adımlarını otomatik olarak bastırmamalıdır.)*

---

# 20. Motion Model Input Philosophy (Hareket Modeli Girdi Felsefesi)

The motion classifier will primarily use inertial sensor information available on the smartphone. *(Hareket sınıflandırıcı temel olarak akıllı telefonda mevcut ataletsel sensör bilgisini kullanacaktır.)*

The minimum candidate input will use accelerometer and gyroscope data. *(Minimum aday girdi ivmeölçer ve jiroskop verisini kullanacaktır.)*

Magnetometer input will not be mandatory for motion classification because local magnetic disturbance does not inherently describe pedestrian motion. *(Yerel manyetik bozulma doğrudan yaya hareketini açıklamadığı için manyetometre girdisi hareket sınıflandırması için zorunlu olmayacaktır.)*

---

# 21. Motion Model Sensor Channels (Hareket Modeli Sensör Kanalları)

Candidate input channels may include the following values. *(Aday girdi kanalları aşağıdaki değerleri içerebilir.)*

```text id="8xdzve"
accel_x
accel_y
accel_z
gyro_x
gyro_y
gyro_z
```

Derived acceleration magnitude may additionally be included. *(Türetilmiş ivme büyüklüğü ayrıca dahil edilebilir.)*

---

# 22. Derived Motion Features (Türetilmiş Hareket Özellikleri)

Candidate derived channels may include acceleration magnitude. *(Aday türetilmiş kanallar ivme büyüklüğünü içerebilir.)*

Candidate derived channels may include gyroscope magnitude. *(Aday türetilmiş kanallar jiroskop büyüklüğünü içerebilir.)*

Candidate derived channels may include simple filtered versions where training and mobile inference can reproduce them identically. *(Aday türetilmiş kanallar eğitim ve mobil çıkarımın bunları aynı şekilde yeniden üretebildiği durumlarda basit filtrelenmiş sürümleri içerebilir.)*

---

# 23. Motion Windowing (Hareket Pencereleme)

The classifier will operate on bounded time windows rather than one sensor sample at a time. *(Sınıflandırıcı bir seferde tek sensör örneği yerine sınırlı zaman pencereleri üzerinde çalışacaktır.)*

A motion class is a temporal pattern and cannot be robustly inferred from one isolated acceleration vector. *(Bir hareket sınıfı zamansal bir örüntüdür ve tek izole ivme vektöründen robust şekilde çıkarılamaz.)*

---

# 24. Motion Window Length (Hareket Pencere Uzunluğu)

The final window duration will be determined experimentally. *(Nihai pencere süresi deneysel olarak belirlenecektir.)*

The window must be long enough to capture useful gait dynamics while remaining short enough for responsive real-time navigation. *(Pencere kullanışlı gait dinamiklerini yakalayacak kadar uzun ancak duyarlı gerçek zamanlı navigasyon için yeterince kısa olmalıdır.)*

---

# 25. Window Overlap (Pencere Örtüşmesi)

Overlapping inference windows may be used to produce smoother and more frequent motion updates. *(Daha düzgün ve daha sık hareket güncellemeleri üretmek için örtüşen çıkarım pencereleri kullanılabilir.)*

The overlap ratio will be selected after latency and classification experiments. *(Örtüşme oranı gecikme ve sınıflandırma deneylerinden sonra seçilecektir.)*

---

# 26. No Window Leakage Across Sessions (Oturumlar Arasında Pencere Sızıntısı Olmaması)

Windows derived from the same physical recording session must remain in the same dataset split. *(Aynı fiziksel kayıt oturumundan türetilen pencereler aynı veri seti ayrımında kalmalıdır.)*

Overlapping windows from one session must never be randomly distributed across training and test sets. *(Tek bir oturumdan örtüşen pencereler eğitim ve test setlerine hiçbir zaman rastgele dağıtılmamalıdır.)*

---

# 27. Session-Wise Split Requirement (Oturum Bazlı Bölme Gereksinimi)

Motion-classification training, validation, and test datasets will be split by complete recording session or route session. *(Hareket sınıflandırma eğitim, doğrulama ve test veri setleri tam kayıt oturumu veya rota oturumu bazında bölünecektir.)*

This reduces temporal leakage and overly optimistic performance estimates. *(Bu zamansal veri sızıntısını ve aşırı iyimser performans tahminlerini azaltır.)*

---

# 28. Participant Scope (Katılımcı Kapsamı)

The primary prototype may initially use data collected from the project's main test user. *(Temel prototip başlangıçta projenin ana test kullanıcısından toplanan veriyi kullanabilir.)*

Such a model must be described as user-specific or limited-scope rather than universally generalized. *(Böyle bir model evrensel olarak genellenmiş yerine kullanıcıya özgü veya sınırlı kapsamlı olarak açıklanmalıdır.)*

---

# 29. Device Scope (Cihaz Kapsamı)

The physical training and benchmark device will primarily be the Xiaomi Redmi Note 9 Pro. *(Fiziksel eğitim ve benchmark cihazı öncelikle Xiaomi Redmi Note 9 Pro olacaktır.)*

Cross-device generalization will not be assumed without additional experiments. *(Ek deneyler olmadan cihazlar arası genelleme varsayılmayacaktır.)*

---

# 30. Phone Placement Scope (Telefon Yerleşimi Kapsamı)

Formal AI data collection will use the same controlled phone-placement protocol as the navigation experiments unless placement generalization is explicitly being studied. *(Resmî yapay zekâ veri toplama, yerleşim genellemesi açıkça araştırılmadığı sürece navigasyon deneyleriyle aynı kontrollü telefon yerleşim protokolünü kullanacaktır.)*

---

# 31. Motion Labeling (Hareket Etiketleme)

Each training window must receive a clearly defined motion label. *(Her eğitim penceresi açıkça tanımlanmış bir hareket etiketi almalıdır.)*

Labels must come from the data-collection protocol or documented annotation process rather than the model's own previous predictions. *(Etiketler modelin kendi önceki tahminleri yerine veri toplama protokolünden veya dokümante edilmiş anotasyon sürecinden gelmelidir.)*

---

# 32. Transition Labels (Geçiş Etiketleri)

Transitions between motion classes require explicit handling. *(Hareket sınıfları arasındaki geçişler açık yönetim gerektirir.)*

A window containing substantial portions of two different activities should not receive an arbitrary label without a documented rule. *(İki farklı aktivitenin anlamlı bölümlerini içeren bir pencere dokümante edilmiş kural olmadan keyfi bir etiket almamalıdır.)*

---

# 33. Transition Handling Candidates (Geçiş Yönetimi Adayları)

A transition window may be excluded from initial training. *(Bir geçiş penceresi ilk eğitimden çıkarılabilir.)*

It may be labeled according to the dominant-duration activity. *(Baskın süreli aktiviteye göre etiketlenebilir.)*

A dedicated transition label may be considered only if data quantity justifies the additional class. *(Özel geçiş etiketi yalnızca veri miktarı ek sınıfı gerekçelendirirse değerlendirilebilir.)*

---

# 34. Motion Model Baseline (Hareket Modeli Temel Yöntemi)

NAVGUARD will evaluate at least one classical machine-learning baseline before accepting a neural-network solution. *(NAVGUARD bir sinir ağı çözümünü kabul etmeden önce en az bir klasik makine öğrenmesi temel yöntemini değerlendirecektir.)*

A Random Forest classifier is the preferred stronger classical baseline candidate. *(Random Forest sınıflandırıcı tercih edilen daha güçlü klasik temel adaydır.)*

A Logistic Regression classifier may be retained as a simpler linear baseline. *(Logistic Regression sınıflandırıcı daha basit doğrusal temel olarak korunabilir.)*

---

# 35. Primary Neural Model Candidate (Birincil Sinir Ağı Model Adayı)

A lightweight one-dimensional convolutional neural network is the primary candidate for the final motion classifier. *(Hafif bir tek boyutlu evrişimli sinir ağı nihai hareket sınıflandırıcı için birincil adaydır.)*

The architecture is suitable for short multichannel time-series windows while remaining compatible with on-device inference goals. *(Mimari cihaz üzerinde çıkarım hedefleriyle uyumlu kalırken kısa çok kanallı zaman serisi pencereleri için uygundur.)*

---

# 36. Why 1D-CNN Is Preferred (1D-CNN Neden Tercih Edilir)

A 1D-CNN can learn local temporal patterns associated with gait and turning. *(Bir 1D-CNN gait ve dönüşle ilişkili yerel zamansal örüntüleri öğrenebilir.)*

It can remain substantially smaller than unnecessarily complex sequence architectures. *(Gereksiz karmaşık dizi mimarilerinden anlamlı şekilde daha küçük kalabilir.)*

The final architecture will still require empirical comparison. *(Nihai mimari yine de ampirik karşılaştırma gerektirecektir.)*

---

# 37. No Complexity for Its Own Sake (Karmaşıklık Uğruna Karmaşıklık Olmaması)

NAVGUARD will not use an LSTM, Transformer, or other larger model merely because the architecture appears more advanced. *(NAVGUARD yalnızca mimari daha gelişmiş göründüğü için LSTM, Transformer veya başka daha büyük bir model kullanmayacaktır.)*

A more complex model will be retained only if it provides a meaningful improvement that justifies mobile cost and development complexity. *(Daha karmaşık model yalnızca mobil maliyeti ve geliştirme karmaşıklığını gerekçelendiren anlamlı bir iyileştirme sağlarsa korunacaktır.)*

---

# 38. Motion Model Candidate Hierarchy (Hareket Modeli Aday Hiyerarşisi)

```text id="ui8x6u"
Logistic Regression
        ↓
Random Forest
        ↓
Lightweight 1D-CNN
        ↓
Larger Architecture Only If Justified
(Yalnızca Gerekçelendirilirse Daha Büyük Mimari)
```

---

# 39. Model Selection Criterion (Model Seçim Kriteri)

The final motion model will not be selected by accuracy alone. *(Nihai hareket modeli yalnızca accuracy değerine göre seçilmeyecektir.)*

Macro F1, per-class performance, confusion matrix, latency, model size, and navigation impact will also be considered. *(Macro F1, sınıf başına performans, confusion matrix, gecikme, model boyutu ve navigasyon etkisi de değerlendirilecektir.)*

---

# 40. Motion Classification Metrics (Hareket Sınıflandırma Metrikleri)

Primary classification metrics will include Accuracy. *(Temel sınıflandırma metrikleri Accuracy değerini içerecektir.)*

Primary classification metrics will include Macro F1. *(Temel sınıflandırma metrikleri Macro F1 değerini içerecektir.)*

Per-class precision, recall, and F1 will also be reported. *(Sınıf başına precision, recall ve F1 de raporlanacaktır.)*

---

# 41. Why Macro F1 Is Important (Macro F1 Neden Önemlidir)

Class frequencies may not be balanced. *(Sınıf frekansları dengeli olmayabilir.)*

Macro F1 gives every motion class equal importance in the final average. *(Macro F1 nihai ortalamada her hareket sınıfına eşit önem verir.)*

This prevents a frequent `WALKING` class from hiding weak `TURNING` or `RUNNING` performance. *(Bu sık `WALKING` sınıfının zayıf `TURNING` veya `RUNNING` performansını gizlemesini önler.)*

---

# 42. Motion AI Success Target (Hareket Yapay Zekâ Başarı Hedefi)

The provisional project target for the held-out motion classifier is Macro F1 of at least `0.90`. *(Ayrılmış hareket sınıflandırıcı için geçici proje hedefi en az `0.90` Macro F1 değeridir.)*

This remains a target and not a measured result. *(Bu ölçülmüş sonuç değil hedef olarak kalmaktadır.)*

---

# 43. Confusion Matrix Requirement (Confusion Matrix Gereksinimi)

A confusion matrix will be reported for the final held-out test set. *(Nihai ayrılmış test seti için confusion matrix raporlanacaktır.)*

The confusion matrix will identify which motion contexts are confused with one another. *(Confusion matrix hangi hareket bağlamlarının birbiriyle karıştırıldığını belirleyecektir.)*

---

# 44. Navigation-Relevant Confusions (Navigasyon Açısından Önemli Karışıklıklar)

`STATIONARY → WALKING` errors may create false navigation propagation if the prediction is trusted too strongly. *(`STATIONARY → WALKING` hataları tahmine fazla güvenilirse yanlış navigasyon ilerletmesi oluşturabilir.)*

`WALKING → RUNNING` errors may affect step-length selection. *(`WALKING → RUNNING` hataları adım uzunluğu seçimini etkileyebilir.)*

`TURNING → WALKING` errors may reduce useful heading context. *(`TURNING → WALKING` hataları kullanışlı yön bağlamını azaltabilir.)*

---

# 45. Motion Prediction Model (Hareket Tahmin Modeli)

```text id="7p6og4"
MotionPrediction
- timestampNs
- modelId
- modelVersion
- predictedClass
- confidence
- classProbabilities
- inferenceLatencyUs
```

Model confidence will not automatically be interpreted as calibrated probability. *(Model güveni otomatik olarak kalibre edilmiş olasılık olarak yorumlanmayacaktır.)*

---

# 46. Motion Prediction Timestamp (Hareket Tahmini Zaman Damgası)

The prediction timestamp will correspond to the defined temporal location of the inference window. *(Tahmin zaman damgası çıkarım penceresinin tanımlanmış zamansal konumuna karşılık gelecektir.)*

A window-end timestamp is the initial preferred causal convention. *(Pencere sonu zaman damgası ilk tercih edilen nedensel kuraldır.)*

The convention will remain identical in training evaluation and mobile inference. *(Kural eğitim değerlendirmesinde ve mobil çıkarımda aynı kalacaktır.)*

---

# 47. Motion Smoothing (Hareket Yumuşatma)

Raw per-window predictions may fluctuate between classes. *(Ham pencere başına tahminler sınıflar arasında dalgalanabilir.)*

The target system may apply lightweight temporal smoothing or hysteresis before changing operational motion context. *(Hedef sistem çalışma hareket bağlamını değiştirmeden önce hafif zamansal smoothing veya hysteresis uygulayabilir.)*

---

# 48. Motion Hysteresis (Hareket Hysteresis'i)

A single isolated class prediction should not necessarily switch the complete navigation configuration. *(Tek izole sınıf tahmini tam navigasyon yapılandırmasını mutlaka değiştirmemelidir.)*

Several consistent predictions or a minimum confidence condition may be required for transition. *(Geçiş için birkaç tutarlı tahmin veya minimum güven koşulu gerekebilir.)*

The exact rule will be tuned on validation sessions. *(Kesin kural doğrulama oturumlarında ayarlanacaktır.)*

---

# 49. No Future-Prediction Smoothing (Gelecek Tahminli Smoothing Olmaması)

Real-time motion smoothing must remain causal. *(Gerçek zamanlı hareket smoothing işlemi nedensel kalmalıdır.)*

Future windows must not alter previously consumed real-time motion decisions. *(Gelecekteki pencereler daha önce kullanılmış gerçek zamanlı hareket kararlarını değiştirmemelidir.)*

---

# 50. AI Task 2 — Step Length Estimation (Yapay Zekâ Görevi 2 — Adım Uzunluğu Tahmini)

The secondary target model will estimate horizontal distance associated with an accepted step. *(İkincil hedef model kabul edilmiş bir adımla ilişkili yatay mesafeyi tahmin edecektir.)*

This is a regression problem rather than a classification problem. *(Bu sınıflandırma yerine bir regresyon problemidir.)*

---

# 51. Step Length Output (Adım Uzunluğu Çıktısı)

```text id="1j0t7k"
L_hat_k
```

The output will be expressed in metres per accepted step. *(Çıktı kabul edilmiş adım başına metre cinsinden ifade edilecektir.)*

---

# 52. Step Length Model Inputs (Adım Uzunluğu Modeli Girdileri)

Candidate inputs may include acceleration amplitude. *(Aday girdiler ivme genliğini içerebilir.)*

Candidate inputs may include peak-to-valley range. *(Aday girdiler peak-to-valley aralığını içerebilir.)*

Candidate inputs may include cadence. *(Aday girdiler kadansı içerebilir.)*

Candidate inputs may include recent signal statistics. *(Aday girdiler son sinyal istatistiklerini içerebilir.)*

Candidate inputs may include motion class. *(Aday girdiler hareket sınıfını içerebilir.)*

---

# 53. Step-Level Versus Window-Level Features (Adım Seviyesi ile Pencere Seviyesi Özellikler)

Some step-length features will correspond to an individual accepted step waveform. *(Bazı adım uzunluğu özellikleri bireysel kabul edilmiş adım dalga biçimine karşılık gelecektir.)*

Other features may summarize a short local context around the step. *(Diğer özellikler adım çevresindeki kısa yerel bağlamı özetleyebilir.)*

The feature definition must remain causal for real-time use. *(Özellik tanımı gerçek zamanlı kullanım için nedensel kalmalıdır.)*

---

# 54. Step Length Baselines (Adım Uzunluğu Temel Yöntemleri)

The learned model must be compared with a calibrated fixed-step baseline. *(Öğrenilmiş model kalibre edilmiş sabit adım temeliyle karşılaştırılmalıdır.)*

It must also be compared with the selected deterministic variable-step baseline where available. *(Mevcut olduğunda seçilen deterministik değişken adım temeliyle de karşılaştırılmalıdır.)*

---

# 55. Classical Step Length Models (Klasik Adım Uzunluğu Modelleri)

Linear Regression will be evaluated as a simple regression baseline. *(Linear Regression basit regresyon temeli olarak değerlendirilecektir.)*

Random Forest Regressor will be evaluated as a nonlinear classical model. *(Random Forest Regressor doğrusal olmayan klasik model olarak değerlendirilecektir.)*

---

# 56. Neural Step Length Model (Sinir Ağı Adım Uzunluğu Modeli)

A small neural regressor may be evaluated only if classical models leave meaningful performance available. *(Küçük bir sinir ağı regresörü yalnızca klasik modeller anlamlı performans fırsatı bırakırsa değerlendirilebilir.)*

A neural model is not mandatory for this task. *(Bu görev için sinir ağı modeli zorunlu değildir.)*

---

# 57. Step Length Model Selection Philosophy (Adım Uzunluğu Modeli Seçim Felsefesi)

The simplest model producing consistent held-out improvement will be preferred. *(Ayrılmış veride tutarlı iyileştirme üreten en basit model tercih edilecektir.)*

A learned model that fails to outperform the deterministic baseline will not be retained merely to increase the AI content of the project. *(Deterministik temeli geçemeyen öğrenilmiş model yalnızca projenin yapay zekâ içeriğini artırmak için korunmayacaktır.)*

---

# 58. Step Length Ground Truth Challenge (Adım Uzunluğu Ground Truth Zorluğu)

Accurate per-step ground truth is more difficult to obtain than route-level total distance. *(Doğru adım başına ground truth elde etmek rota seviyesinde toplam mesafeden daha zordur.)*

NAVGUARD must therefore clearly document how step-length labels are constructed. *(Bu nedenle NAVGUARD adım uzunluğu etiketlerinin nasıl oluşturulduğunu açıkça dokümante etmelidir.)*

---

# 59. Step Length Label Candidates (Adım Uzunluğu Etiket Adayları)

A controlled route with known distance and verified step count may provide average step-length labels. *(Bilinen mesafe ve doğrulanmış adım sayısına sahip kontrollü rota ortalama adım uzunluğu etiketleri sağlayabilir.)*

More detailed per-step labels may be used only if a sufficiently reliable annotation method is available. *(Daha ayrıntılı adım başına etiketler yalnızca yeterince güvenilir anotasyon yöntemi mevcutsa kullanılabilir.)*

---

# 60. No False Per-Step Precision (Yanlış Adım Başına Hassasiyet İddiası Olmaması)

Route-average step length must not be presented as exact ground truth for every individual step without acknowledging the approximation. *(Rota ortalama adım uzunluğu yaklaşık olduğu belirtilmeden her bireysel adım için kesin ground truth olarak sunulmamalıdır.)*

---

# 61. Step Length Metrics (Adım Uzunluğu Metrikleri)

Where valid per-step or segment-level targets exist, Mean Absolute Error will be reported. *(Geçerli adım başına veya segment seviyesinde hedefler mevcut olduğunda Mean Absolute Error raporlanacaktır.)*

RMSE may additionally be reported. *(RMSE ayrıca raporlanabilir.)*

Route-level travelled-distance error will remain an important practical metric. *(Rota seviyesinde kat edilen mesafe hatası önemli pratik bir metrik olarak kalacaktır.)*

---

# 62. Step Length MAE (Adım Uzunluğu MAE)

```text id="7rv79c"
MAE_L =
1/n · Σ |L_hat_i - L_ref_i|
```

The metric will only be reported where `L_ref` has a defensible definition. *(Metrik yalnızca `L_ref` savunulabilir bir tanıma sahip olduğunda raporlanacaktır.)*

---

# 63. Route-Level Distance Evaluation (Rota Seviyesi Mesafe Değerlendirmesi)

A learned step-length method will also be judged by accumulated route-distance error. *(Öğrenilmiş adım uzunluğu yöntemi ayrıca birikmiş rota mesafe hatasıyla değerlendirilecektir.)*

A model with slightly better per-step MAE but worse route-level bias may not be preferable for navigation. *(Biraz daha iyi adım başına MAE ancak daha kötü rota seviyesi bias'ına sahip model navigasyon için tercih edilmeyebilir.)*

---

# 64. AI Training Boundary (Yapay Zekâ Eğitim Sınırı)

Model training will occur off-device using Python. *(Model eğitimi cihaz dışında Python kullanılarak gerçekleştirilecektir.)*

The Android phone will collect data and execute final on-device inference but will not be required to perform full model training. *(Android telefon veri toplayacak ve nihai cihaz üzeri çıkarımı çalıştıracak ancak tam model eğitimini gerçekleştirmesi gerekmeyecektir.)*

---

# 65. Python AI Environment (Python Yapay Zekâ Ortamı)

The training environment will use Python with TensorFlow/Keras-compatible tooling for neural models. *(Eğitim ortamı sinir ağı modelleri için TensorFlow/Keras uyumlu araçlarla Python kullanacaktır.)*

scikit-learn will be used for classical machine-learning baselines. *(scikit-learn klasik makine öğrenmesi temel yöntemleri için kullanılacaktır.)*

NumPy, pandas, and related scientific libraries will support preprocessing and evaluation. *(NumPy, pandas ve ilişkili bilimsel kütüphaneler ön işleme ve değerlendirmeyi destekleyecektir.)*

---

# 66. Mobile AI Runtime (Mobil Yapay Zekâ Çalışma Zamanı)

Final neural models intended for Android will be exported to the `.tflite` model format for LiteRT-compatible on-device inference. *(Android için amaçlanan nihai sinir ağı modelleri LiteRT uyumlu cihaz üzeri çıkarım için `.tflite` model formatına aktarılacaktır.)*

The native Kotlin AI component will own the mobile inference runtime. *(Native Kotlin yapay zekâ bileşeni mobil çıkarım çalışma zamanının sahibi olacaktır.)*

---

# 67. AI Platform Boundary (Yapay Zekâ Platform Sınırı)

Flutter will request high-level AI results through the defined platform abstraction. *(Flutter tanımlanan platform abstraction üzerinden yüksek seviyeli yapay zekâ sonuçlarını isteyecektir.)*

Flutter widgets will not directly manage the LiteRT interpreter. *(Flutter widget'ları LiteRT interpreter'ını doğrudan yönetmeyecektir.)*

---

# 68. Native AI Owner (Native Yapay Zekâ Sahibi)

The Kotlin AI component will own model loading. *(Kotlin yapay zekâ bileşeni model yüklemenin sahibi olacaktır.)*

It will own tensor preparation. *(Tensor hazırlamanın sahibi olacaktır.)*

It will own inference execution. *(Çıkarım çalıştırmanın sahibi olacaktır.)*

It will own interpreter lifecycle and error handling. *(Interpreter yaşam döngüsünün ve hata yönetiminin sahibi olacaktır.)*

---

# 69. Model Load Policy (Model Yükleme Politikası)

A production model should be loaded once and reused rather than reopened for every inference window. *(Bir üretim modeli her çıkarım penceresinde yeniden açılmak yerine bir kez yüklenip yeniden kullanılmalıdır.)*

Repeated model initialization would create unnecessary latency and resource overhead. *(Tekrarlanan model başlatma gereksiz gecikme ve kaynak yükü oluşturur.)*

---

# 70. Lazy Model Initialization (Tembel Model Başlatma)

Expensive model initialization may be performed only when the corresponding AI feature is required. *(Maliyetli model başlatma yalnızca ilgili yapay zekâ özelliği gerektiğinde gerçekleştirilebilir.)*

This supports the wider NAVGUARD lazy-start architecture. *(Bu daha geniş NAVGUARD tembel başlatma mimarisini destekler.)*

---

# 71. AI Runtime States (Yapay Zekâ Çalışma Zamanı Durumları)

```text id="9no4nu"
UNAVAILABLE
LOADING
READY
ACTIVE
DEGRADED
ERROR
```

Each model instance may have its own runtime state. *(Her model örneği kendi çalışma zamanı durumuna sahip olabilir.)*

---

# 72. AI Failure Codes (Yapay Zekâ Hata Kodları)

```text id="fay4y4"
AI_MODEL_NOT_FOUND
AI_MODEL_LOAD_FAILED
AI_SCHEMA_MISMATCH
AI_INPUT_SHAPE_ERROR
AI_PREPROCESSING_MISMATCH
AI_INFERENCE_FAILED
AI_OUTPUT_INVALID
AI_LATENCY_EXCEEDED
AI_CONFIGURATION_ERROR
```

---

# 73. Training-Inference Parity (Eğitim-Çıkarım Eşdeğerliği)

The preprocessing used during mobile inference must reproduce the preprocessing used during model training. *(Mobil çıkarım sırasında kullanılan ön işleme model eğitimi sırasında kullanılan ön işlemeyi yeniden üretmelidir.)*

This is one of the most important AI deployment requirements. *(Bu en önemli yapay zekâ deployment gereksinimlerinden biridir.)*

---

# 74. Preprocessing Parity Scope (Ön İşleme Eşdeğerliği Kapsamı)

Parity includes sensor-channel ordering. *(Eşdeğerlik sensör kanal sırasını içerir.)*

Parity includes units. *(Eşdeğerlik birimleri içerir.)*

Parity includes window length. *(Eşdeğerlik pencere uzunluğunu içerir.)*

Parity includes filtering. *(Eşdeğerlik filtrelemeyi içerir.)*

Parity includes normalization. *(Eşdeğerlik normalizasyonu içerir.)*

Parity includes padding or resampling rules where used. *(Eşdeğerlik kullanıldığı durumda padding veya yeniden örnekleme kurallarını içerir.)*

---

# 75. Channel Order Contract (Kanal Sırası Sözleşmesi)

The exact input tensor channel order will be explicitly frozen with the model. *(Kesin girdi tensor kanal sırası modelle birlikte açıkça sabitlenecektir.)*

```text id="o6tw37"
Example:
[ax, ay, az, gx, gy, gz]
```

The mobile application must not infer channel order from source-code assumptions. *(Mobil uygulama kanal sırasını kaynak kod varsayımlarından çıkarmamalıdır.)*

---

# 76. Unit Contract (Birim Sözleşmesi)

Every model input feature must have an explicitly documented unit or dimensionless normalization. *(Her model girdi özelliği açıkça dokümante edilmiş birime veya boyutsuz normalizasyona sahip olmalıdır.)*

A model trained on radians per second must not receive degrees per second during mobile inference. *(Radyan/saniye ile eğitilen model mobil çıkarım sırasında derece/saniye almamalıdır.)*

---

# 77. Normalization Contract (Normalizasyon Sözleşmesi)

If standardization is used, training-set statistics will be frozen with the model. *(Standardizasyon kullanılırsa eğitim seti istatistikleri modelle birlikte sabitlenecektir.)*

```text id="9m88wc"
x_norm =
(x - μ_train) / σ_train
```

Validation or test statistics must not be used to normalize the training pipeline. *(Doğrulama veya test istatistikleri eğitim hattını normalize etmek için kullanılmamalıdır.)*

---

# 78. Training Statistics Only (Yalnızca Eğitim İstatistikleri)

Normalization mean and standard deviation must be calculated from the training split only. *(Normalizasyon ortalaması ve standart sapması yalnızca eğitim ayrımından hesaplanmalıdır.)*

The same frozen values will then be used for validation, test, and mobile inference. *(Aynı sabitlenmiş değerler daha sonra doğrulama, test ve mobil çıkarım için kullanılacaktır.)*

---

# 79. No Test Leakage Through Preprocessing (Ön İşleme Üzerinden Test Sızıntısı Olmaması)

The test dataset must not influence scaling parameters, feature selection, threshold tuning, or architecture selection. *(Test veri seti ölçekleme parametrelerini, özellik seçimini, eşik ayarını veya mimari seçimini etkilememelidir.)*

---

# 80. Resampling Policy (Yeniden Örnekleme Politikası)

If AI requires a regular tensor time grid, irregular sensor timestamps may be resampled according to the frozen preprocessing policy. *(Yapay zekâ düzenli tensor zaman grid'i gerektirirse düzensiz sensör zaman damgaları sabitlenmiş ön işleme politikasına göre yeniden örneklenebilir.)*

The model will not assume a perfect sensor sampling rate without measured timestamp handling. *(Model ölçülmüş zaman damgası yönetimi olmadan kusursuz sensör örnekleme hızı varsaymayacaktır.)*

---

# 81. Missing Sample Policy (Eksik Örnek Politikası)

Small timing gaps may be handled through the defined interpolation or resampling strategy. *(Küçük zamanlama boşlukları tanımlanan interpolasyon veya yeniden örnekleme stratejisiyle yönetilebilir.)*

Large gaps must not be silently filled as if reliable sensor data existed. *(Büyük boşluklar güvenilir sensör verisi varmış gibi sessizce doldurulmamalıdır.)*

A window with excessive missing data may be rejected from inference. *(Aşırı eksik veriye sahip bir pencere çıkarımdan reddedilebilir.)*

---

# 82. Window Validity (Pencere Geçerliliği)

Each AI window will have a validity status. *(Her yapay zekâ penceresi geçerlilik durumuna sahip olacaktır.)*

Invalid timing, missing mandatory channels, or numerical corruption may invalidate a window. *(Geçersiz zamanlama, eksik zorunlu kanallar veya sayısal bozulma bir pencereyi geçersiz kılabilir.)*

---

# 83. Model Input Schema (Model Girdi Şeması)

```text id="c8krgh"
ModelInputSchema
- modelId
- samplingPolicy
- windowDuration
- sampleCount
- channelOrder
- units
- normalizationVersion
- preprocessingVersion
```

---

# 84. Model Output Schema (Model Çıktı Şeması)

```text id="dg2tep"
ModelOutputSchema
- outputType
- outputShape
- classOrder
- outputUnits
- postprocessingVersion
```

The model and application must agree exactly on this schema. *(Model ve uygulama bu şema üzerinde tam olarak anlaşmalıdır.)*

---

# 85. Class Index Contract (Sınıf İndeks Sözleşmesi)

The output class order will be explicitly stored with the motion model. *(Çıktı sınıf sırası hareket modeliyle birlikte açıkça saklanacaktır.)*

```text id="rqnx2k"
Example:
0 = STATIONARY
1 = WALKING
2 = RUNNING
3 = TURNING
```

The mobile application must not hard-code a different order. *(Mobil uygulama farklı bir sırayı hard-code etmemelidir.)*

---

# 86. Model Registry (Model Kayıt Sistemi)

NAVGUARD will maintain a model registry describing every AI artifact permitted for experiments or deployment. *(NAVGUARD deney veya deployment için izin verilen her yapay zekâ artifact'ını açıklayan bir model kayıt sistemi tutacaktır.)*

---

# 87. Model Registry Entry (Model Kayıt Girdisi)

```text id="ee970u"
ModelRegistryEntry
- modelId
- task
- version
- fileName
- fileHash
- architecture
- inputSchemaVersion
- preprocessingVersion
- outputSchemaVersion
- trainingDatasetId
- trainingRunId
- validationMetrics
- deploymentStatus
```

---

# 88. Model File Hash (Model Dosya Hash'i)

Each deployment model should have a cryptographic file hash recorded. *(Her deployment modeli kaydedilmiş bir kriptografik dosya hash'ine sahip olmalıdır.)*

This allows the project to prove which exact model binary produced a benchmark result. *(Bu projenin hangi kesin model binary'sinin bir benchmark sonucu ürettiğini kanıtlamasına olanak sağlar.)*

---

# 89. Model Versioning (Model Sürümleme)

A new model version will be created when architecture, weights, input schema, preprocessing, or output semantics materially change. *(Mimari, ağırlıklar, girdi şeması, ön işleme veya çıktı semantiği anlamlı şekilde değiştiğinde yeni model sürümü oluşturulacaktır.)*

---

# 90. Preprocessing Versioning (Ön İşleme Sürümleme)

A model cannot be considered reproducible without its preprocessing version. *(Bir model ön işleme sürümü olmadan tekrarlanabilir kabul edilemez.)*

Changing normalization or filtering while keeping the same model file may materially alter predictions. *(Aynı model dosyasını tutarken normalizasyonu veya filtrelemeyi değiştirmek tahminleri anlamlı şekilde değiştirebilir.)*

---

# 91. Training Dataset Identity (Eğitim Veri Seti Kimliği)

Every final model will reference the exact dataset version used for training. *(Her nihai model eğitim için kullanılan kesin veri seti sürümüne referans verecektir.)*

Dataset modifications will produce a new dataset identity or manifest version. *(Veri seti değişiklikleri yeni veri seti kimliği veya manifest sürümü üretecektir.)*

---

# 92. Dataset Manifest (Veri Seti Manifesti)

```text id="6q1tnc"
DatasetManifest
- datasetId
- sourceSessions
- device
- placementProtocol
- labelProtocol
- preprocessingVersion
- splitDefinition
- classCounts
- exclusionRules
```

---

# 93. Training Run Identity (Eğitim Çalışması Kimliği)

Each important model-training run will receive a unique run identifier. *(Her önemli model eğitim çalışması benzersiz run tanımlayıcısı alacaktır.)*

Training configuration and resulting metrics will be stored under this identifier. *(Eğitim yapılandırması ve ortaya çıkan metrikler bu tanımlayıcı altında saklanacaktır.)*

---

# 94. Reproducible Training Configuration (Tekrarlanabilir Eğitim Yapılandırması)

The training configuration will record random seed where relevant. *(Eğitim yapılandırması ilgili olduğunda random seed'i kaydedecektir.)*

It will record optimizer and learning-rate configuration for neural models. *(Sinir ağı modelleri için optimizer ve learning-rate yapılandırmasını kaydedecektir.)*

It will record epochs or stopping criteria. *(Epoch sayısını veya durdurma kriterlerini kaydedecektir.)*

It will record model architecture parameters. *(Model mimarisi parametrelerini kaydedecektir.)*

---

# 95. Train / Validation / Test Split (Train / Validation / Test Ayrımı)

The training split will be used to fit model parameters. *(Training ayrımı model parametrelerini fit etmek için kullanılacaktır.)*

The validation split will be used for model and hyperparameter selection. *(Validation ayrımı model ve hiperparametre seçimi için kullanılacaktır.)*

The test split will be used only for final held-out evaluation. *(Test ayrımı yalnızca nihai ayrılmış değerlendirme için kullanılacaktır.)*

---

# 96. No Repeated Test Optimization (Tekrarlanan Test Optimizasyonu Olmaması)

A test result that causes additional model tuning effectively stops being an independent final test. *(Ek model ayarına neden olan bir test sonucu etkili olarak bağımsız nihai test olmaktan çıkar.)*

If major tuning is required after test inspection, a new held-out evaluation set should be collected where practical. *(Test incelendikten sonra büyük ayar gerekiyorsa uygulanabilir olduğunda yeni ayrılmış değerlendirme seti toplanmalıdır.)*

---

# 97. Class Imbalance Handling (Sınıf Dengesizliği Yönetimi)

Motion-class frequencies will be measured before training. *(Hareket sınıf frekansları eğitimden önce ölçülecektir.)*

Class weighting or balanced sampling may be used if imbalance materially affects performance. *(Dengesizlik performansı anlamlı şekilde etkilerse class weighting veya dengeli sampling kullanılabilir.)*

The selected method will use training data only. *(Seçilen yöntem yalnızca eğitim verisini kullanacaktır.)*

---

# 98. Data Augmentation Policy (Veri Artırma Politikası)

Sensor data augmentation will not be added automatically. *(Sensör veri artırma otomatik olarak eklenmeyecektir.)*

Any augmentation must represent physically plausible sensor variation and demonstrate validation benefit. *(Her augmentation fiziksel olarak makul sensör değişimini temsil etmeli ve doğrulama faydası göstermelidir.)*

---

# 99. No Unrealistic Sensor Augmentation (Gerçekçi Olmayan Sensör Augmentation Olmaması)

Arbitrary transformations that destroy the physical meaning of accelerometer or gyroscope axes will not be used merely to increase dataset size. *(İvmeölçer veya jiroskop eksenlerinin fiziksel anlamını bozan keyfi dönüşümler yalnızca veri seti boyutunu artırmak için kullanılmayacaktır.)*

---

# 100. Model Calibration (Model Kalibrasyonu)

Classification confidence calibration may be evaluated if raw model confidence is later used by navigation logic. *(Ham model güveni daha sonra navigasyon mantığı tarafından kullanılacaksa sınıflandırma güven kalibrasyonu değerlendirilebilir.)*

Calibration is optional for the minimum classifier. *(Kalibrasyon minimum sınıflandırıcı için isteğe bağlıdır.)*

---

# 101. Uncalibrated Confidence Policy (Kalibre Edilmemiş Güven Politikası)

If confidence is not calibrated, the application will treat it as a relative model score rather than a true correctness probability. *(Güven kalibre edilmemişse uygulama onu gerçek doğruluk olasılığı yerine göreli model skoru olarak ele alacaktır.)*

---

# 102. AI Confidence and Quality Engine (Yapay Zekâ Güveni ve Kalite Motoru)

AI confidence may enter the Sensor Confidence & Quality Engine as one piece of evidence. *(Yapay zekâ güveni Sensör Güven ve Kalite Motoruna bir kanıt parçası olarak girebilir.)*

The quality engine will not treat AI confidence as absolute truth. *(Kalite motoru yapay zekâ güvenini mutlak gerçek olarak ele almayacaktır.)*

---

# 103. Low AI Confidence Behavior (Düşük Yapay Zekâ Güveni Davranışı)

Low-confidence motion predictions may be prevented from changing navigation context immediately. *(Düşük güvenli hareket tahminlerinin navigasyon bağlamını hemen değiştirmesi engellenebilir.)*

The deterministic motion pipeline may retain control until additional evidence appears. *(Ek kanıt ortaya çıkana kadar deterministik hareket hattı kontrolü koruyabilir.)*

---

# 104. AI-Derived Context Is Advisory Until Validated (Yapay Zekâ Kaynaklı Bağlam Doğrulanana Kadar Danışma Niteliğindedir)

The initial integration will first log AI predictions alongside deterministic navigation behavior. *(İlk entegrasyon önce yapay zekâ tahminlerini deterministik navigasyon davranışının yanında kaydedecektir.)*

Only after offline and live validation will AI outputs be allowed to alter navigation-critical parameters. *(Yalnızca çevrimdışı ve canlı doğrulamadan sonra yapay zekâ çıktılarının navigasyon açısından kritik parametreleri değiştirmesine izin verilecektir.)*

---

# 105. Shadow Mode (Gölge Modu)

NAVGUARD may initially run new AI models in a shadow mode. *(NAVGUARD yeni yapay zekâ modellerini başlangıçta gölge modunda çalıştırabilir.)*

In shadow mode, predictions are logged but do not affect the active estimator. *(Gölge modunda tahminler kaydedilir ancak aktif tahmin motorunu etkilemez.)*

This allows safe validation before operational integration. *(Bu operasyonel entegrasyondan önce güvenli doğrulamaya olanak sağlar.)*

---

# 106. AI Activation Gate (Yapay Zekâ Aktivasyon Kapısı)

A model must pass offline evaluation before live shadow deployment. *(Bir model canlı gölge deployment'ından önce çevrimdışı değerlendirmeyi geçmelidir.)*

It must pass live-device inference validation before affecting navigation. *(Navigasyonu etkilemeden önce canlı cihaz çıkarım doğrulamasını geçmelidir.)*

---

# 107. Model Deployment Status (Model Deployment Durumu)

```text id="p6ts2e"
EXPERIMENTAL
OFFLINE_VALIDATED
SHADOW
NAVIGATION_ENABLED
RETIRED
```

A model will not enter `NAVIGATION_ENABLED` status automatically after training. *(Bir model eğitimden sonra otomatik olarak `NAVIGATION_ENABLED` durumuna girmeyecektir.)*

---

# 108. Motion Model Navigation Gate (Hareket Modeli Navigasyon Kapısı)

The final motion model must satisfy the predefined held-out quality requirement before it can influence formal benchmark navigation. *(Nihai hareket modeli resmî benchmark navigasyonunu etkileyebilmeden önce önceden tanımlanmış ayrılmış kalite gereksinimini karşılamalıdır.)*

The provisional Macro F1 target is `≥ 0.90`. *(Geçici Macro F1 hedefi `≥ 0.90` değeridir.)*

---

# 109. Step Length Navigation Gate (Adım Uzunluğu Navigasyon Kapısı)

A learned step-length model must demonstrate measurable improvement over the selected deterministic baseline before it becomes the preferred estimator. *(Öğrenilmiş adım uzunluğu modeli tercih edilen tahmin motoru haline gelmeden önce seçilen deterministik temele göre ölçülebilir iyileştirme göstermelidir.)*

No predetermined percentage improvement will be invented before data exists. *(Veri mevcut olmadan önceden belirlenmiş yüzde iyileştirme uydurulmayacaktır.)*

---

# 110. On-Device Inference Requirement (Cihaz Üzeri Çıkarım Gereksinimi)

The final navigation-enabled AI models must execute locally on the Redmi Note 9 Pro. *(Nihai navigasyon etkin yapay zekâ modelleri Redmi Note 9 Pro üzerinde yerel olarak çalışmalıdır.)*

Core AI inference will not require a cloud API. *(Temel yapay zekâ çıkarımı bulut API'si gerektirmeyecektir.)*

---

# 111. Offline-First AI (Çevrimdışı Öncelikli Yapay Zekâ)

Once model files are included in the application, NAVGUARD should be able to perform motion inference without network access. *(Model dosyaları uygulamaya dahil edildiğinde NAVGUARD ağ erişimi olmadan hareket çıkarımı gerçekleştirebilmelidir.)*

This is consistent with the offline-first navigation objective. *(Bu çevrimdışı öncelikli navigasyon hedefiyle uyumludur.)*

---

# 112. Inference Latency (Çıkarım Gecikmesi)

Every important AI inference will have measurable latency. *(Her önemli yapay zekâ çıkarımı ölçülebilir gecikmeye sahip olacaktır.)*

```text id="e87n3l"
inferenceLatency =
t_inference_end -
t_inference_start
```

The measurement will exclude unrelated UI rendering where practical. *(Ölçüm uygulanabilir olduğunda ilgisiz UI render süresini hariç tutacaktır.)*

---

# 113. Provisional Latency Target (Geçici Gecikme Hedefi)

The provisional project target for AI inference is below `50 ms` per inference on the Redmi Note 9 Pro. *(Yapay zekâ çıkarımı için geçici proje hedefi Redmi Note 9 Pro üzerinde çıkarım başına `50 ms` altıdır.)*

This remains a target until profile or release-mode measurements are collected. *(Bu profile veya release-mode ölçümleri toplanana kadar hedef olarak kalacaktır.)*

---

# 114. End-to-End AI Latency (Uçtan Uca Yapay Zekâ Gecikmesi)

Model inference time alone does not represent complete operational latency. *(Yalnızca model çıkarım süresi tam operasyonel gecikmeyi temsil etmez.)*

End-to-end latency also includes window completion, preprocessing, inference, postprocessing, and navigation-context application. *(Uçtan uca gecikme ayrıca pencere tamamlanmasını, ön işlemeyi, çıkarımı, son işlemeyi ve navigasyon bağlamı uygulamasını içerir.)*

---

# 115. Window Latency Trade-Off (Pencere Gecikmesi Trade-Off'u)

A longer AI window may improve classification stability while increasing response delay. *(Daha uzun yapay zekâ penceresi tepki gecikmesini artırırken sınıflandırma kararlılığını iyileştirebilir.)*

The final window configuration must therefore balance classification accuracy and navigation responsiveness. *(Bu nedenle nihai pencere yapılandırması sınıflandırma doğruluğu ile navigasyon duyarlılığını dengelemelidir.)*

---

# 116. Inference Scheduling (Çıkarım Zamanlama)

The motion model will not execute once for every accelerometer sample. *(Hareket modeli her ivmeölçer örneğinde bir kez çalıştırılmayacaktır.)*

Inference will occur only when a complete configured sensor window is ready. *(Çıkarım yalnızca tam yapılandırılmış sensör penceresi hazır olduğunda gerçekleşecektir.)*

---

# 117. Inference Backpressure (Çıkarım Backpressure Yönetimi)

If inference cannot keep up with incoming windows, NAVGUARD must not create an unbounded queue. *(Çıkarım gelen pencerelere yetişemezse NAVGUARD sınırsız kuyruk oluşturmamalıdır.)*

The runtime may drop obsolete inference requests or reduce overlap according to a documented policy. *(Çalışma zamanı dokümante edilmiş politikaya göre eski çıkarım isteklerini düşürebilir veya örtüşmeyi azaltabilir.)*

---

# 118. Stale AI Prediction (Eski Yapay Zekâ Tahmini)

A motion prediction that arrives too late to describe the current navigation state must not be applied as if it were fresh. *(Mevcut navigasyon durumunu açıklamak için fazla geç gelen hareket tahmini yeniymiş gibi uygulanmamalıdır.)*

Prediction age will be measurable. *(Tahmin yaşı ölçülebilir olacaktır.)*

---

# 119. AI Prediction Freshness (Yapay Zekâ Tahmin Güncelliği)

```text id="15e8nw"
predictionAge =
t_current -
t_prediction_reference
```

The final maximum acceptable age will depend on the motion-context use case. *(Nihai maksimum kabul edilebilir yaş hareket bağlamı kullanım durumuna bağlı olacaktır.)*

---

# 120. CPU Delegate Baseline (CPU Delegate Temeli)

The first mobile performance baseline will use the standard CPU execution path. *(İlk mobil performans temeli standart CPU çalıştırma yolunu kullanacaktır.)*

This provides a simple and reproducible baseline before optional acceleration is considered. *(Bu isteğe bağlı hızlandırma değerlendirilmeden önce basit ve tekrarlanabilir bir temel sağlar.)*

---

# 121. Optional Hardware Acceleration (İsteğe Bağlı Donanım Hızlandırma)

GPU or other delegate acceleration may be evaluated only if the CPU baseline fails to meet latency or resource requirements or if clear measured benefit exists. *(GPU veya diğer delegate hızlandırması yalnızca CPU temeli gecikme veya kaynak gereksinimlerini karşılayamazsa ya da açık ölçülmüş fayda varsa değerlendirilebilir.)*

---

# 122. Delegate Selection by Measurement (Ölçümle Delegate Seçimi)

The project will not assume that GPU execution is automatically faster or more energy efficient for a small model. *(Proje küçük bir model için GPU çalıştırmanın otomatik olarak daha hızlı veya daha enerji verimli olduğunu varsaymayacaktır.)*

Delegate selection will use measured performance on the Redmi Note 9 Pro. *(Delegate seçimi Redmi Note 9 Pro üzerinde ölçülmüş performansı kullanacaktır.)*

---

# 123. Quantization (Quantization)

Model quantization may be evaluated if it materially reduces model size, latency, or memory use. *(Model quantization model boyutunu, gecikmeyi veya bellek kullanımını anlamlı şekilde azaltırsa değerlendirilebilir.)*

Any quantized model must be re-evaluated for predictive performance. *(Quantize edilmiş her model tahmin performansı açısından yeniden değerlendirilmelidir.)*

---

# 124. Quantized Model Is a New Artifact (Quantize Model Yeni Bir Artifact'tır)

A quantized model will receive its own model version or artifact identity. *(Quantize edilmiş model kendi model sürümünü veya artifact kimliğini alacaktır.)*

It will not silently replace the floating-point model under the same registry entry. *(Aynı registry girdisi altında floating-point modelin sessizce yerini almayacaktır.)*

---

# 125. Model Size Metric (Model Boyutu Metriği)

The deployed model file size will be recorded. *(Deployment edilen model dosya boyutu kaydedilecektir.)*

Large increases in model size must be justified by measurable performance benefit. *(Model boyutundaki büyük artışlar ölçülebilir performans faydasıyla gerekçelendirilmelidir.)*

---

# 126. Memory Metric (Bellek Metriği)

Runtime memory cost will be measured during AI-enabled navigation. *(Çalışma zamanı bellek maliyeti yapay zekâ etkin navigasyon sırasında ölçülecektir.)*

The measurement should include the combined application workload rather than AI in isolation only. *(Ölçüm yalnızca yapay zekâyı izole olarak değil birleşik uygulama yükünü içermelidir.)*

---

# 127. Battery and Thermal Impact (Batarya ve Termal Etki)

AI-enabled sessions will be compared with equivalent non-AI sessions where practical. *(Yapay zekâ etkin oturumlar uygulanabilir olduğunda eşdeğer yapay zekâsız oturumlarla karşılaştırılacaktır.)*

Battery and thermal cost will be part of deployment evaluation. *(Batarya ve termal maliyet deployment değerlendirmesinin parçası olacaktır.)*

---

# 128. Combined Runtime Test (Birleşik Çalışma Zamanı Testi)

The final AI runtime must be tested together with sensor acquisition, logging, PDR, heading, ARCore, and EKF where enabled. *(Nihai yapay zekâ çalışma zamanı etkin olduğu durumda sensör toplama, kayıt, PDR, yön, ARCore ve EKF ile birlikte test edilmelidir.)*

An AI model that is fast in an isolated benchmark may still create unacceptable load in the complete navigation stack. *(İzole benchmark'ta hızlı olan bir yapay zekâ modeli tam navigasyon yığını içerisinde yine de kabul edilemez yük oluşturabilir.)*

---

# 129. AI Logging (Yapay Zekâ Kaydı)

Formal AI-enabled sessions will log model predictions and model identity. *(Resmî yapay zekâ etkin oturumlar model tahminlerini ve model kimliğini kaydedecektir.)*

The logs will preserve enough information to determine exactly which model influenced navigation. *(Kayıtlar navigasyonu tam olarak hangi modelin etkilediğini belirlemek için yeterli bilgiyi koruyacaktır.)*

---

# 130. Motion Prediction Log (Hareket Tahmin Kaydı)

```text id="k0koca"
timestamp_ns,
window_start_ns,
window_end_ns,
model_id,
model_version,
predicted_class,
confidence,
p_stationary,
p_walking,
p_running,
p_turning,
inference_latency_us,
runtime_state
```

Class-probability fields will be stored only when the selected model exposes them. *(Sınıf olasılık alanları yalnızca seçilen model bunları sunuyorsa saklanacaktır.)*

---

# 131. Step Length Prediction Log (Adım Uzunluğu Tahmin Kaydı)

```text id="s6no03"
timestamp_ns,
step_id,
model_id,
model_version,
estimated_step_length_m,
prediction_confidence,
fallback_used,
inference_latency_us
```

---

# 132. AI Navigation Decision Log (Yapay Zekâ Navigasyon Karar Kaydı)

The system may separately record how an AI prediction affected navigation. *(Sistem ayrıca bir yapay zekâ tahmininin navigasyonu nasıl etkilediğini ayrı olarak kaydedebilir.)*

```text id="c3cur0"
timestamp_ns,
prediction_id,
decision_type,
previous_value,
new_value,
reason
```

This separates prediction output from operational effect. *(Bu tahmin çıktısını operasyonel etkiden ayırır.)*

---

# 133. AI Prediction Does Not Equal Navigation Decision (Yapay Zekâ Tahmini Navigasyon Kararına Eşit Değildir)

A model may predict `RUNNING` without the controller immediately changing every running-specific parameter. *(Bir model controller hemen tüm koşmaya özgü parametreleri değiştirmeden `RUNNING` tahmin edebilir.)*

Prediction validation and hysteresis may occur before operational state changes. *(Operasyonel durum değişikliklerinden önce tahmin doğrulama ve hysteresis gerçekleşebilir.)*

---

# 134. AI Configuration Snapshot (Yapay Zekâ Yapılandırma Anlık Görüntüsü)

```text id="m6f13o"
motionModelId
motionModelVersion
stepLengthModelId
stepLengthModelVersion
preprocessingVersion
windowConfig
normalizationConfig
runtimeDelegate
motionSmoothingConfig
navigationEffectConfig
```

Every formal benchmark will preserve this snapshot. *(Her resmî benchmark bu anlık görüntüyü koruyacaktır.)*

---

# 135. Model Replacement Policy (Model Değiştirme Politikası)

A new AI model will not silently replace the model used by an ongoing formal experiment. *(Yeni yapay zekâ modeli devam eden resmî deneyde kullanılan modelin sessizce yerini almayacaktır.)*

Model selection will remain frozen for the complete benchmark configuration. *(Model seçimi tam benchmark yapılandırması için sabit kalacaktır.)*

---

# 136. AI Replay (Yapay Zekâ Replay)

Recorded sensor data should allow AI preprocessing and inference to be replayed offline. *(Kaydedilmiş sensör verisi yapay zekâ ön işleme ve çıkarımının çevrimdışı replay edilmesine izin vermelidir.)*

The same model artifact and preprocessing configuration should reproduce equivalent predictions within runtime numerical tolerance. *(Aynı model artifact'ı ve ön işleme yapılandırması çalışma zamanı sayısal toleransı içerisinde eşdeğer tahminler üretmelidir.)*

---

# 137. Mobile-versus-Python Parity Test (Mobil-Python Eşdeğerlik Testi)

A fixed set of validation windows will be processed by both the reference Python pipeline and the Android inference pipeline. *(Sabit bir doğrulama penceresi seti hem referans Python hattı hem de Android çıkarım hattı tarafından işlenecektir.)*

Their model inputs and outputs will be compared. *(Model girdileri ve çıktıları karşılaştırılacaktır.)*

---

# 138. Input Tensor Parity Test (Girdi Tensor Eşdeğerlik Testi)

For a known raw window, the normalized Android input tensor should match the Python input tensor within numerical tolerance. *(Bilinen ham pencere için normalize edilmiş Android girdi tensor'u sayısal tolerans içerisinde Python girdi tensor'uyla eşleşmelidir.)*

This test is mandatory before trusting on-device accuracy. *(Bu test cihaz üzeri doğruluğa güvenmeden önce zorunludur.)*

---

# 139. Output Parity Test (Çıktı Eşdeğerlik Testi)

For identical model input, Python and Android inference should produce equivalent output within expected numerical tolerance. *(Aynı model girdisi için Python ve Android çıkarımı beklenen sayısal tolerans içerisinde eşdeğer çıktı üretmelidir.)*

---

# 140. Model Schema Validation (Model Şema Doğrulaması)

The Android runtime must verify that the configured input and output tensor shapes match the application's expected schema. *(Android çalışma zamanı yapılandırılmış girdi ve çıktı tensor şekillerinin uygulamanın beklenen şemasıyla eşleştiğini doğrulamalıdır.)*

A mismatch must fail safely. *(Bir uyuşmazlık güvenli şekilde başarısız olmalıdır.)*

---

# 141. Invalid AI Output (Geçersiz Yapay Zekâ Çıktısı)

NaN, infinite, malformed, or out-of-schema AI outputs will be rejected. *(NaN, sonsuz, bozuk veya şema dışı yapay zekâ çıktıları reddedilecektir.)*

The deterministic fallback will remain active. *(Deterministik geri dönüş aktif kalacaktır.)*

---

# 142. Motion Class Output Validation (Hareket Sınıfı Çıktı Doğrulaması)

The predicted class index must map to a valid model registry class. *(Tahmin edilen sınıf indeksi geçerli model registry sınıfına eşlenmelidir.)*

Unknown class indices will not be silently converted to `WALKING`. *(Bilinmeyen sınıf indeksleri sessizce `WALKING` durumuna dönüştürülmeyecektir.)*

---

# 143. Step Length Output Validation (Adım Uzunluğu Çıktı Doğrulaması)

A learned step-length prediction must be finite and physically plausible. *(Öğrenilmiş adım uzunluğu tahmini sonlu ve fiziksel olarak makul olmalıdır.)*

Out-of-range predictions will trigger fallback or clipping only according to a documented policy. *(Aralık dışı tahminler yalnızca dokümante edilmiş politikaya göre geri dönüş veya clipping tetikleyecektir.)*

---

# 144. Fallback Is Preferred to Hidden Clipping (Gizli Clipping Yerine Geri Dönüş Tercihi)

A severely invalid learned step-length prediction should generally trigger deterministic fallback rather than silently become an arbitrary boundary value. *(Ciddi şekilde geçersiz öğrenilmiş adım uzunluğu tahmini genel olarak sessizce keyfi sınır değerine dönüşmek yerine deterministik geri dönüş tetiklemelidir.)*

---

# 145. Motion Model Fallback (Hareket Modeli Geri Dönüşü)

If the motion model is unavailable, deterministic motion evidence and step-detection logic will continue. *(Hareket modeli kullanılamazsa deterministik hareket kanıtı ve adım tespit mantığı devam edecektir.)*

```text id="hdg0ht"
Motion AI Available
      ↓ No
Deterministic Motion Context
      ↓
Baseline Navigation Continues
```

---

# 146. Step Length Model Fallback (Adım Uzunluğu Modeli Geri Dönüşü)

```text id="2xwx27"
ML Step Length
      ↓ unavailable
Deterministic Variable Step Length
      ↓ unavailable
Calibrated Fixed Step Length
```

This hierarchy preserves PDR availability. *(Bu hiyerarşi PDR kullanılabilirliğini korur.)*

---

# 147. AI Latency Fallback (Yapay Zekâ Gecikme Geri Dönüşü)

An inference result that exceeds the useful timing deadline may be logged but not applied to the current navigation decision. *(Kullanışlı zamanlama sınırını aşan çıkarım sonucu kaydedilebilir ancak mevcut navigasyon kararına uygulanmayabilir.)*

The navigation pipeline must continue using deterministic fallback. *(Navigasyon hattı deterministik geri dönüş kullanarak devam etmelidir.)*

---

# 148. AI Runtime Error Isolation (Yapay Zekâ Çalışma Zamanı Hata İzolasyonu)

A LiteRT runtime exception must not crash the complete navigation session if safe recovery is possible. *(Bir LiteRT çalışma zamanı exception'ı güvenli geri kazanım mümkünse tam navigasyon oturumunu çökertmemelidir.)*

The AI subsystem may transition to `ERROR` while navigation falls back to deterministic behavior. *(Yapay zekâ alt sistemi `ERROR` durumuna geçerken navigasyon deterministik davranışa geri dönebilir.)*

---

# 149. AI and EKF Boundary (Yapay Zekâ ve EKF Sınırı)

AI models will not directly call EKF state-update functions. *(Yapay zekâ modelleri EKF durum update fonksiyonlarını doğrudan çağırmayacaktır.)*

AI outputs will be transformed into documented navigation context or process parameters before reaching the fusion layer. *(Yapay zekâ çıktıları füzyon katmanına ulaşmadan önce dokümante edilmiş navigasyon bağlamına veya süreç parametrelerine dönüştürülecektir.)*

---

# 150. Motion AI to EKF Path (Hareket Yapay Zekâsından EKF'ye Yol)

```text id="b0n044"
Motion AI
   ↓
Validated Motion Context
(Doğrulanmış Hareket Bağlamı)
   ↓
Process Configuration
(Süreç Yapılandırması)
   ↓
Q / Step Policy / Stationary Policy
(Q / Adım Politikası / Sabit Durum Politikası)
   ↓
EKF
```

---

# 151. Step Length AI to EKF Path (Adım Uzunluğu Yapay Zekâsından EKF'ye Yol)

```text id="ukv7x0"
Accepted Step
      +
Step Features
      ↓
Step Length Model
      ↓
Validated L_k
      +
Step-Length Uncertainty
      ↓
EKF PDR Process Model
```

---

# 152. AI Cannot Bypass Step Detection (Yapay Zekâ Adım Tespitini Atlayamaz)

A step-length model will operate only for accepted pedestrian steps. *(Bir adım uzunluğu modeli yalnızca kabul edilmiş yaya adımları için çalışacaktır.)*

It must not invent navigation steps independently. *(Bağımsız olarak navigasyon adımları uydurmamalıdır.)*

---

# 153. AI Cannot Bypass Ground Truth Firewall (Yapay Zekâ Ground Truth Firewall'u Atlayamaz)

No AI input may include GNSS ground-truth position during the protected GNSS-denied interval if the resulting prediction can affect navigation. *(Ortaya çıkan tahmin navigasyonu etkileyebiliyorsa korunan GNSS kesintili aralık sırasında hiçbir yapay zekâ girdisi GNSS ground truth konumunu içeremez.)*

This includes indirect engineered features derived from ground-truth GNSS. *(Bu ground truth GNSS'ten türetilmiş dolaylı engineered feature'ları da içerir.)*

---

# 154. No GNSS Leakage Into Motion AI (Hareket Yapay Zekâsına GNSS Sızıntısı Olmaması)

Motion classification will not use GNSS speed or GNSS bearing as live inference features during denied navigation. *(Hareket sınıflandırması kesintili navigasyon sırasında canlı çıkarım özelliği olarak GNSS hızı veya GNSS bearing kullanmayacaktır.)*

---

# 155. No GNSS Leakage Into Step Length AI (Adım Uzunluğu Yapay Zekâsına GNSS Sızıntısı Olmaması)

The deployed step-length model will not use live ground-truth GNSS displacement as an inference feature. *(Deployment edilen adım uzunluğu modeli canlı ground truth GNSS yer değiştirmesini çıkarım özelliği olarak kullanmayacaktır.)*

GNSS may be used offline to construct training or evaluation labels where scientifically appropriate. *(GNSS bilimsel olarak uygun olduğunda eğitim veya değerlendirme etiketleri oluşturmak için çevrimdışı kullanılabilir.)*

---

# 156. Offline Label Generation Versus Online Features (Çevrimdışı Etiket Üretimi ile Çevrimiçi Özellikler)

A signal may be permissible for offline ground-truth construction while being forbidden as a live model input. *(Bir sinyal çevrimdışı ground truth oluşturma için izinli olurken canlı model girdisi olarak yasak olabilir.)*

These roles must remain explicitly separated. *(Bu roller açık şekilde ayrı kalmalıdır.)*

---

# 157. AI Dataset Collection Mode (Yapay Zekâ Veri Toplama Modu)

AI dataset collection sessions may record more information than the final model consumes. *(Yapay zekâ veri toplama oturumları nihai modelin kullandığından daha fazla bilgi kaydedebilir.)*

This permits later feature analysis without making every recorded channel a deployment dependency. *(Bu kaydedilen her kanalı deployment bağımlılığı haline getirmeden daha sonra özellik analizine izin verir.)*

---

# 158. Raw Data Preservation (Ham Veri Koruma)

Raw sensor data used to build AI datasets will remain preserved separately from processed model-ready tensors. *(Yapay zekâ veri setlerini oluşturmak için kullanılan ham sensör verisi işlenmiş modele hazır tensor'lardan ayrı korunacaktır.)*

This allows preprocessing changes to be evaluated without recollecting every physical session. *(Bu her fiziksel oturumu yeniden toplamadan ön işleme değişikliklerinin değerlendirilmesine olanak sağlar.)*

---

# 159. Dataset Generation Pipeline (Veri Seti Üretim Hattı)

```text id="7nmjql"
Raw Session Data
(Ham Oturum Verisi)
      ↓
Session Validation
(Oturum Doğrulama)
      ↓
Synchronization / Resampling
(Senkronizasyon / Yeniden Örnekleme)
      ↓
Label Alignment
(Etiket Hizalama)
      ↓
Window / Feature Generation
(Pencere / Özellik Üretimi)
      ↓
Session-Wise Split
(Oturum Bazlı Ayrım)
      ↓
Training Dataset
(Eğitim Veri Seti)
```

---

# 160. Dataset Generation Is Versioned (Veri Seti Üretimi Sürümlenir)

Changes to label rules, windowing, preprocessing, or exclusion criteria will create a new dataset-processing version. *(Etiket kuralları, pencereleme, ön işleme veya hariç tutma kriterlerindeki değişiklikler yeni veri seti işleme sürümü oluşturacaktır.)*

---

# 161. Data Exclusion Rules (Veri Hariç Tutma Kuralları)

Corrupted sessions may be excluded. *(Bozuk oturumlar hariç tutulabilir.)*

Sessions with missing mandatory sensor channels may be excluded from models requiring those channels. *(Eksik zorunlu sensör kanallarına sahip oturumlar bu kanalları gerektiren modellerden hariç tutulabilir.)*

Exclusions must be documented rather than silently removed. *(Hariç tutmalar sessizce kaldırılmak yerine dokümante edilmelidir.)*

---

# 162. No Performance-Based Session Deletion (Performansa Göre Oturum Silme Olmaması)

A session must not be removed merely because the model performs badly on it. *(Bir oturum yalnızca model üzerinde kötü performans gösterdiği için kaldırılmamalıdır.)*

Exclusion requires a protocol or data-integrity reason. *(Hariç tutma protokol veya veri bütünlüğü nedeni gerektirir.)*

---

# 163. Training Data Audit (Eğitim Verisi Denetimi)

Before training, NAVGUARD will inspect class counts, session counts, missing values, sensor-rate distributions, and label integrity. *(Eğitimden önce NAVGUARD sınıf sayılarını, oturum sayılarını, eksik değerleri, sensör hız dağılımlarını ve etiket bütünlüğünü inceleyecektir.)*

---

# 164. Model Overfitting Monitoring (Model Overfitting İzleme)

Training and validation curves will be inspected for neural models. *(Sinir ağı modelleri için eğitim ve doğrulama eğrileri incelenecektir.)*

A large persistent gap may indicate overfitting. *(Büyük kalıcı fark overfitting'i gösterebilir.)*

---

# 165. Early Stopping Candidate (Early Stopping Adayı)

Early stopping may be used for neural training when validation performance stops improving. *(Doğrulama performansı iyileşmeyi bıraktığında sinir ağı eğitimi için early stopping kullanılabilir.)*

The selected policy will be stored in the training configuration. *(Seçilen politika eğitim yapılandırmasında saklanacaktır.)*

---

# 166. Hyperparameter Tuning (Hiperparametre Ayarı)

Hyperparameter tuning will use only the training and validation data. *(Hiperparametre ayarı yalnızca eğitim ve doğrulama verisini kullanacaktır.)*

The final held-out test set will not become a hyperparameter search objective. *(Nihai ayrılmış test seti hiperparametre arama hedefi haline gelmeyecektir.)*

---

# 167. Classical Model Feature Selection (Klasik Model Özellik Seçimi)

If manual features are used for classical baselines, feature selection must be based on training data. *(Klasik temel yöntemler için manuel özellikler kullanılırsa özellik seçimi eğitim verisine dayanmalıdır.)*

Features should remain interpretable where practical. *(Özellikler uygulanabilir olduğunda yorumlanabilir kalmalıdır.)*

---

# 168. Neural Input Feature Minimalism (Sinir Ağı Girdi Özelliği Minimalizmi)

The neural model will begin with a compact set of sensor channels. *(Sinir ağı modeli kompakt bir sensör kanal setiyle başlayacaktır.)*

Additional channels will be added only if ablation experiments show useful improvement. *(Ek kanallar yalnızca ablation deneyleri kullanışlı iyileştirme gösterirse eklenecektir.)*

---

# 169. Feature Ablation (Özellik Ablation)

Candidate experiments may compare accelerometer-only input with accelerometer-plus-gyroscope input. *(Aday deneyler yalnızca ivmeölçer girdisini ivmeölçer-artı-jiroskop girdisiyle karşılaştırabilir.)*

This will determine whether the additional gyroscope channels justify their model complexity and power cost. *(Bu ek jiroskop kanallarının model karmaşıklığı ve güç maliyetini gerekçelendirip gerekçelendirmediğini belirleyecektir.)*

---

# 170. Model Ablation (Model Ablation)

Motion-classifier comparison may include Logistic Regression, Random Forest, and 1D-CNN under the same session split. *(Hareket sınıflandırıcı karşılaştırması aynı oturum ayrımı altında Logistic Regression, Random Forest ve 1D-CNN'i içerebilir.)*

This ensures that model comparisons are fair. *(Bu model karşılaştırmalarının adil olmasını sağlar.)*

---

# 171. Navigation Ablation (Navigasyon Ablation)

AI value will also be measured at the navigation level. *(Yapay zekâ değeri navigasyon seviyesinde de ölçülecektir.)*

A high classification score is not sufficient if the AI produces no measurable navigation benefit. *(Yapay zekâ ölçülebilir navigasyon faydası üretmiyorsa yüksek sınıflandırma skoru yeterli değildir.)*

---

# 172. Motion AI Navigation Comparison (Hareket Yapay Zekâsı Navigasyon Karşılaştırması)

A candidate comparison will run identical navigation inputs with motion-AI effects disabled and enabled. *(Aday karşılaştırma aynı navigasyon girdilerini hareket yapay zekâ etkileri kapalı ve açık olarak çalıştıracaktır.)*

The comparison may evaluate false stationary movement, step-count behavior, and position drift. *(Karşılaştırma yanlış sabit durum hareketini, adım sayısı davranışını ve konum sürüklenmesini değerlendirebilir.)*

---

# 173. Step Length AI Navigation Comparison (Adım Uzunluğu Yapay Zekâsı Navigasyon Karşılaştırması)

A candidate comparison will use identical accepted steps and heading while changing only the step-length estimator. *(Aday karşılaştırma yalnızca adım uzunluğu tahmin motorunu değiştirirken aynı kabul edilmiş adımları ve yönü kullanacaktır.)*

This isolates the contribution of learned step length. *(Bu öğrenilmiş adım uzunluğunun katkısını izole eder.)*

---

# 174. Model Value Threshold (Model Değer Eşiği)

NAVGUARD will retain a learned model only when its measurable benefit justifies added complexity, latency, and maintenance cost. *(NAVGUARD öğrenilmiş modeli yalnızca ölçülebilir faydası ek karmaşıklığı, gecikmeyi ve bakım maliyetini gerekçelendirdiğinde koruyacaktır.)*

---

# 175. Motion Model Failure Does Not Invalidate Project (Hareket Modeli Başarısızlığı Projeyi Geçersiz Kılmaz)

If the motion model fails to reach the provisional target, NAVGUARD may still complete the navigation research using deterministic motion logic. *(Hareket modeli geçici hedefe ulaşamazsa NAVGUARD yine de deterministik hareket mantığını kullanarak navigasyon araştırmasını tamamlayabilir.)*

The failed AI result itself remains a valid experimental finding. *(Başarısız yapay zekâ sonucu kendi başına geçerli deneysel bulgu olarak kalır.)*

---

# 176. Step Length AI Failure Does Not Invalidate Project (Adım Uzunluğu Yapay Zekâsı Başarısızlığı Projeyi Geçersiz Kılmaz)

If learned step length does not outperform deterministic estimation, the deterministic model will remain active. *(Öğrenilmiş adım uzunluğu deterministik tahmini geçemezse deterministik model aktif kalacaktır.)*

The comparison will still be reported. *(Karşılaştırma yine de raporlanacaktır.)*

---

# 177. AI Research Integrity (Yapay Zekâ Araştırma Bütünlüğü)

Negative results will not be hidden. *(Negatif sonuçlar gizlenmeyecektir.)*

A simpler baseline outperforming AI is an acceptable research result. *(Daha basit bir temel yöntemin yapay zekâyı geçmesi kabul edilebilir bir araştırma sonucudur.)*

---

# 178. Model Training Logs (Model Eğitim Kayıtları)

Important training runs will preserve configuration and metrics. *(Önemli eğitim çalışmaları yapılandırmayı ve metrikleri koruyacaktır.)*

Neural runs may additionally preserve epoch-level loss and validation metrics. *(Sinir ağı çalışmaları ayrıca epoch seviyesinde loss ve doğrulama metriklerini koruyabilir.)*

---

# 179. Final Test Evidence (Nihai Test Kanıtı)

The final model evaluation will preserve predictions for the held-out test sessions. *(Nihai model değerlendirmesi ayrılmış test oturumları için tahminleri koruyacaktır.)*

This permits independent recalculation of confusion matrices and classification metrics. *(Bu confusion matrix ve sınıflandırma metriklerinin bağımsız yeniden hesaplanmasına izin verir.)*

---

# 180. Motion Test Prediction Schema (Hareket Test Tahmin Şeması)

```text id="zpt42n"
session_id,
window_id,
true_class,
predicted_class,
confidence,
model_id
```

---

# 181. Step Length Test Prediction Schema (Adım Uzunluğu Test Tahmin Şeması)

```text id="hy3eml"
session_id,
step_id,
reference_length_m,
predicted_length_m,
model_id
```

Reference values will be included only where a defensible reference exists. *(Referans değerleri yalnızca savunulabilir referans mevcut olduğunda dahil edilecektir.)*

---

# 182. AI Unit Test — Normalization (Yapay Zekâ Birim Testi — Normalizasyon)

Known input values must produce expected normalized output according to frozen training statistics. *(Bilinen girdi değerleri sabitlenmiş eğitim istatistiklerine göre beklenen normalize edilmiş çıktıyı üretmelidir.)*

---

# 183. AI Unit Test — Channel Ordering (Yapay Zekâ Birim Testi — Kanal Sırası)

The Android tensor builder must place sensor channels in exactly the order declared by the model schema. *(Android tensor builder sensör kanallarını model şeması tarafından bildirilen sırayla tam olarak yerleştirmelidir.)*

---

# 184. AI Unit Test — Window Shape (Yapay Zekâ Birim Testi — Pencere Şekli)

A valid sensor window must produce the exact tensor dimensions expected by the model. *(Geçerli sensör penceresi modelin beklediği kesin tensor boyutlarını üretmelidir.)*

---

# 185. AI Unit Test — Missing Channel (Yapay Zekâ Birim Testi — Eksik Kanal)

A missing mandatory sensor channel must invalidate the inference window rather than silently fill the complete channel with zeros unless the model schema explicitly defines such behavior. *(Eksik zorunlu sensör kanalı model şeması açıkça böyle davranışı tanımlamadıkça tüm kanalı sessizce sıfırlarla doldurmak yerine çıkarım penceresini geçersiz kılmalıdır.)*

---

# 186. AI Unit Test — Class Mapping (Yapay Zekâ Birim Testi — Sınıf Eşleme)

Known output indices must map to the correct motion classes. *(Bilinen çıktı indeksleri doğru hareket sınıflarına eşlenmelidir.)*

---

# 187. AI Unit Test — Invalid Output (Yapay Zekâ Birim Testi — Geçersiz Çıktı)

NaN or malformed model output must trigger deterministic fallback. *(NaN veya bozuk model çıktısı deterministik geri dönüşü tetiklemelidir.)*

---

# 188. AI Integration Test — Python Parity (Yapay Zekâ Entegrasyon Testi — Python Eşdeğerliği)

The same validation window will be passed through Python preprocessing and Android preprocessing. *(Aynı doğrulama penceresi Python ön işlemeden ve Android ön işlemeden geçirilecektir.)*

The resulting tensors must agree within tolerance. *(Ortaya çıkan tensor'lar tolerans içerisinde uyuşmalıdır.)*

---

# 189. AI Integration Test — Mobile Prediction (Yapay Zekâ Entegrasyon Testi — Mobil Tahmin)

The Android application must successfully load the deployment model and produce predictions on the Redmi Note 9 Pro. *(Android uygulaması deployment modelini başarıyla yüklemeli ve Redmi Note 9 Pro üzerinde tahmin üretmelidir.)*

---

# 190. AI Integration Test — Fallback (Yapay Zekâ Entegrasyon Testi — Geri Dönüş)

A deliberately unavailable AI model must cause the pipeline to use deterministic fallback without stopping navigation. *(Bilinçli olarak kullanılamaz yapay zekâ modeli navigasyonu durdurmadan hattın deterministik geri dönüşü kullanmasına neden olmalıdır.)*

---

# 191. AI Integration Test — Stale Prediction (Yapay Zekâ Entegrasyon Testi — Eski Tahmin)

A deliberately delayed prediction must not overwrite a newer operational motion context. *(Bilinçli olarak geciktirilmiş tahmin daha yeni operasyonel hareket bağlamının üzerine yazmamalıdır.)*

---

# 192. AI Integration Test — Navigation Effect (Yapay Zekâ Entegrasyon Testi — Navigasyon Etkisi)

When motion AI is navigation-enabled, the application must be able to demonstrate which navigation parameter or rule was affected by each accepted AI state transition. *(Hareket yapay zekâsı navigasyon etkin olduğunda uygulama kabul edilen her yapay zekâ durum geçişi tarafından hangi navigasyon parametresi veya kuralın etkilendiğini gösterebilmelidir.)*

---

# 193. Physical Motion Test — Stationary (Fiziksel Hareket Testi — Sabit)

A controlled stationary recording will test `STATIONARY` recognition and false activity transitions. *(Kontrollü sabit kayıt `STATIONARY` tanımayı ve yanlış aktivite geçişlerini test edecektir.)*

---

# 194. Physical Motion Test — Walking (Fiziksel Hareket Testi — Yürüyüş)

Normal walking recordings will test `WALKING` classification under the formal phone-placement protocol. *(Normal yürüyüş kayıtları resmî telefon yerleşim protokolü altında `WALKING` sınıflandırmasını test edecektir.)*

---

# 195. Physical Motion Test — Running (Fiziksel Hareket Testi — Koşma)

Controlled running recordings will test `RUNNING` classification if the class remains in the final project scope. *(Kontrollü koşu kayıtları sınıf nihai proje kapsamında kalırsa `RUNNING` sınıflandırmasını test edecektir.)*

---

# 196. Physical Motion Test — Turning (Fiziksel Hareket Testi — Dönüş)

Turn-heavy movement will test whether `TURNING` is recognized without destroying normal step behavior. *(Dönüş yoğun hareket `TURNING` durumunun normal adım davranışını bozmadan tanınıp tanınmadığını test edecektir.)*

---

# 197. Transition Test (Geçiş Testi)

Walk-stop-walk sessions will evaluate `WALKING → STATIONARY → WALKING` transitions. *(Yürü-dur-yürü oturumları `WALKING → STATIONARY → WALKING` geçişlerini değerlendirecektir.)*

Walk-run-walk sessions may evaluate transitions involving `RUNNING`. *(Yürü-koş-yürü oturumları `RUNNING` içeren geçişleri değerlendirebilir.)*

---

# 198. AI Performance Test — Latency (Yapay Zekâ Performans Testi — Gecikme)

Inference latency will be measured in profile or release-like builds on the Redmi Note 9 Pro. *(Çıkarım gecikmesi Redmi Note 9 Pro üzerinde profile veya release benzeri build'lerde ölçülecektir.)*

Debug build latency will not be the only performance evidence. *(Debug build gecikmesi tek performans kanıtı olmayacaktır.)*

---

# 199. AI Performance Test — Sustained Execution (Yapay Zekâ Performans Testi — Sürekli Çalışma)

The motion model will run continuously during a representative navigation session. *(Hareket modeli temsili bir navigasyon oturumu sırasında sürekli çalışacaktır.)*

The test will check inference queue growth, memory stability, CPU use, and thermal behavior. *(Test çıkarım kuyruk büyümesini, bellek kararlılığını, CPU kullanımını ve termal davranışı kontrol edecektir.)*

---

# 200. AI Performance Test — Combined Stack (Yapay Zekâ Performans Testi — Birleşik Yığın)

The final model must also be tested while ARCore, logging, PDR, heading, and EKF are active. *(Nihai model ARCore, kayıt, PDR, yön ve EKF aktifken de test edilmelidir.)*

---

# 201. AI Acceptance Criteria — Motion Model (Yapay Zekâ Kabul Kriterleri — Hareket Modeli)

The motion model must support all retained final motion classes. *(Hareket modeli korunan tüm nihai hareket sınıflarını desteklemelidir.)*

The final held-out evaluation must report Accuracy and Macro F1. *(Nihai ayrılmış değerlendirme Accuracy ve Macro F1 raporlamalıdır.)*

Per-class metrics and a confusion matrix must be preserved. *(Sınıf başına metrikler ve confusion matrix korunmalıdır.)*

---

# 202. AI Acceptance Criteria — Leakage (Yapay Zekâ Kabul Kriterleri — Veri Sızıntısı)

The same recording session must never appear in both training and final test sets. *(Aynı kayıt oturumu hem eğitim hem de nihai test setinde hiçbir zaman bulunmamalıdır.)*

Overlapping windows from the same session must remain in the same split. *(Aynı oturumdan örtüşen pencereler aynı ayrımda kalmalıdır.)*

Training statistics must not use validation or test samples. *(Eğitim istatistikleri doğrulama veya test örneklerini kullanmamalıdır.)*

---

# 203. AI Acceptance Criteria — Deployment Parity (Yapay Zekâ Kabul Kriterleri — Deployment Eşdeğerliği)

Android preprocessing must match reference training preprocessing. *(Android ön işleme referans eğitim ön işlemesiyle eşleşmelidir.)*

Android model input shape and class order must match the model registry. *(Android model girdi şekli ve sınıf sırası model registry ile eşleşmelidir.)*

Known parity samples must produce equivalent Python and Android inference outputs within tolerance. *(Bilinen eşdeğerlik örnekleri tolerans içerisinde eşdeğer Python ve Android çıkarım çıktıları üretmelidir.)*

---

# 204. AI Acceptance Criteria — Fallback (Yapay Zekâ Kabul Kriterleri — Geri Dönüş)

Motion-model failure must not stop baseline navigation. *(Hareket modeli hatası temel navigasyonu durdurmamalıdır.)*

Step-length model failure must trigger deterministic fallback. *(Adım uzunluğu modeli hatası deterministik geri dönüşü tetiklemelidir.)*

Invalid AI output must not reach PDR or EKF as a valid numerical input. *(Geçersiz yapay zekâ çıktısı PDR veya EKF'ye geçerli sayısal girdi olarak ulaşmamalıdır.)*

---

# 205. AI Acceptance Criteria — Runtime (Yapay Zekâ Kabul Kriterleri — Çalışma Zamanı)

The deployment model must load successfully on the Redmi Note 9 Pro. *(Deployment modeli Redmi Note 9 Pro üzerinde başarıyla yüklenmelidir.)*

Inference must remain stable during a sustained navigation session. *(Çıkarım sürekli navigasyon oturumu boyunca kararlı kalmalıdır.)*

The provisional motion-inference latency target is below `50 ms` per inference. *(Geçici hareket çıkarım gecikme hedefi çıkarım başına `50 ms` altıdır.)*

---

# 206. AI Acceptance Criteria — Navigation Integration (Yapay Zekâ Kabul Kriterleri — Navigasyon Entegrasyonu)

Every AI output that changes navigation behavior must have a documented operational effect. *(Navigasyon davranışını değiştiren her yapay zekâ çıktısı dokümante edilmiş operasyonel etkiye sahip olmalıdır.)*

AI may not directly overwrite East, North, latitude, or longitude. *(Yapay zekâ Doğu, Kuzey, enlem veya boylam değerlerinin doğrudan üzerine yazamaz.)*

---

# 207. AI Acceptance Criteria — Research Integrity (Yapay Zekâ Kabul Kriterleri — Araştırma Bütünlüğü)

Final model selection must occur before final benchmark results are interpreted. *(Nihai model seçimi nihai benchmark sonuçları yorumlanmadan önce gerçekleşmelidir.)*

Negative AI results must remain part of the research record. *(Negatif yapay zekâ sonuçları araştırma kaydının parçası olarak kalmalıdır.)*

---

# 208. Minimum AI System (Minimum Yapay Zekâ Sistemi)

The minimum AI system consists of one motion-classification model. *(Minimum yapay zekâ sistemi bir hareket sınıflandırma modelinden oluşur.)*

The model must run locally on Android. *(Model Android üzerinde yerel olarak çalışmalıdır.)*

The model must classify retained motion contexts from sensor windows. *(Model sensör pencerelerinden korunan hareket bağlamlarını sınıflandırmalıdır.)*

---

# 209. Target AI System (Hedef Yapay Zekâ Sistemi)

The target AI system additionally includes learned step-length estimation if it improves deterministic baselines. *(Hedef yapay zekâ sistemi deterministik temel yöntemleri iyileştirirse ayrıca öğrenilmiş adım uzunluğu tahminini içerir.)*

It includes navigation-aware motion context. *(Navigasyon farkındalıklı hareket bağlamını içerir.)*

It includes model registry and mobile parity validation. *(Model registry ve mobil eşdeğerlik doğrulamasını içerir.)*

---

# 210. Optional AI Enhancements (İsteğe Bağlı Yapay Zekâ İyileştirmeleri)

Optional enhancements may include confidence calibration. *(İsteğe bağlı iyileştirmeler güven kalibrasyonunu içerebilir.)*

Optional enhancements may include quantized models. *(İsteğe bağlı iyileştirmeler quantize edilmiş modelleri içerebilir.)*

Optional enhancements may include user-adaptive models. *(İsteğe bağlı iyileştirmeler kullanıcıya adaptif modelleri içerebilir.)*

Optional enhancements may include automatic model-selection logic only if strongly justified. *(İsteğe bağlı iyileştirmeler yalnızca güçlü şekilde gerekçelendirilirse otomatik model seçim mantığını içerebilir.)*

---

# 211. AI Non-Goals (Yapay Zekâ Olmayan Hedefler)

NAVGUARD will not build a large generative model. *(NAVGUARD büyük bir generative model geliştirmeyecektir.)*

NAVGUARD will not require cloud inference. *(NAVGUARD bulut çıkarımı gerektirmeyecektir.)*

NAVGUARD will not directly predict GNSS-denied latitude and longitude with AI. *(NAVGUARD GNSS kesintili enlem ve boylamı yapay zekâyla doğrudan tahmin etmeyecektir.)*

NAVGUARD will not use AI to bypass missing physical navigation information. *(NAVGUARD eksik fiziksel navigasyon bilgisini atlamak için yapay zekâ kullanmayacaktır.)*

---

# 212. Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kararlar)

NAVGUARD will include a mandatory AI-assisted motion-classification capability. *(NAVGUARD zorunlu yapay zekâ destekli hareket sınıflandırma yeteneği içerecektir.)*

The target motion classes are `STATIONARY`, `WALKING`, `RUNNING`, and `TURNING`. *(Hedef hareket sınıfları `STATIONARY`, `WALKING`, `RUNNING` ve `TURNING` şeklindedir.)*

The primary neural candidate will be a lightweight 1D-CNN. *(Birincil sinir ağı adayı hafif bir 1D-CNN olacaktır.)*

Random Forest will serve as a strong classical baseline candidate. *(Random Forest güçlü klasik temel aday olarak kullanılacaktır.)*

---

# 213. Additional Frozen Decisions (Ek Sabitlenmiş Kararlar)

Motion AI must influence validated navigation behavior and will not be UI-only. *(Hareket yapay zekâsı doğrulanmış navigasyon davranışını etkilemeli ve yalnızca UI amaçlı olmamalıdır.)*

The AI system will remain optional to baseline PDR operation. *(Yapay zekâ sistemi temel PDR çalışması için isteğe bağlı kalacaktır.)*

No AI model will directly output global navigation coordinates. *(Hiçbir yapay zekâ modeli doğrudan global navigasyon koordinatları üretmeyecektir.)*

---

# 214. Dataset Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Veri Seti Kararları)

AI train, validation, and test splits will be session-wise. *(Yapay zekâ train, validation ve test ayrımları oturum bazlı olacaktır.)*

Overlapping windows from one session will remain in one split. *(Tek bir oturumdan örtüşen pencereler tek bir ayrımda kalacaktır.)*

Training preprocessing statistics will be calculated only from training data. *(Eğitim ön işleme istatistikleri yalnızca eğitim verisinden hesaplanacaktır.)*

---

# 215. Deployment Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Deployment Kararları)

Neural training will occur off-device using Python. *(Sinir ağı eğitimi cihaz dışında Python kullanılarak gerçekleştirilecektir.)*

Deployment models will use the `.tflite` format with the selected LiteRT-compatible Android runtime. *(Deployment modelleri seçilen LiteRT uyumlu Android çalışma zamanı ile `.tflite` formatını kullanacaktır.)*

The Kotlin native layer will own inference runtime management. *(Kotlin native katmanı çıkarım çalışma zamanı yönetiminin sahibi olacaktır.)*

---

# 216. Preprocessing Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Ön İşleme Kararları)

Training and mobile preprocessing must remain equivalent. *(Eğitim ve mobil ön işleme eşdeğer kalmalıdır.)*

Channel order, units, normalization, windowing, and class order will be versioned with the model. *(Kanal sırası, birimler, normalizasyon, pencereleme ve sınıf sırası modelle birlikte sürümlenecektir.)*

Mobile-versus-Python tensor parity testing will be mandatory. *(Mobil-Python tensor eşdeğerlik testi zorunlu olacaktır.)*

---

# 217. Step Length Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Adım Uzunluğu Kararları)

Learned step-length estimation is a target enhancement rather than a minimum dependency. *(Öğrenilmiş adım uzunluğu tahmini minimum bağımlılık yerine hedef iyileştirmedir.)*

Linear Regression and Random Forest Regressor will be candidate classical models. *(Linear Regression ve Random Forest Regressor aday klasik modeller olacaktır.)*

A neural regressor will be considered only if justified by experiments. *(Sinir ağı regresörü yalnızca deneylerle gerekçelendirilirse değerlendirilecektir.)*

---

# 218. Fallback Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Geri Dönüş Kararları)

AI runtime failure will not stop baseline navigation. *(Yapay zekâ çalışma zamanı hatası temel navigasyonu durdurmayacaktır.)*

Motion-model failure will fall back to deterministic motion logic. *(Hareket modeli hatası deterministik hareket mantığına geri dönecektir.)*

Step-length AI failure will fall back to deterministic step-length estimation. *(Adım uzunluğu yapay zekâ hatası deterministik adım uzunluğu tahminine geri dönecektir.)*

---

# 219. Ground Truth Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Ground Truth Kararları)

Ground-truth GNSS may be used offline for model labeling or evaluation when scientifically appropriate. *(Ground truth GNSS bilimsel olarak uygun olduğunda model etiketleme veya değerlendirme için çevrimdışı kullanılabilir.)*

Ground-truth GNSS will not be available as a live AI inference feature during the protected GNSS-denied interval. *(Ground truth GNSS korunan GNSS kesintili aralık sırasında canlı yapay zekâ çıkarım özelliği olarak kullanılabilir olmayacaktır.)*

---

# 220. Decisions Pending Data (Veri Bekleyen Kararlar)

The final motion window duration remains pending dataset experiments. *(Nihai hareket pencere süresi veri seti deneylerini beklemektedir.)*

The final window overlap remains pending latency and classification analysis. *(Nihai pencere örtüşmesi gecikme ve sınıflandırma analizini beklemektedir.)*

The final motion model architecture remains pending baseline comparison. *(Nihai hareket modeli mimarisi temel yöntem karşılaştırmasını beklemektedir.)*

---

# 221. Additional Pending Decisions (Ek Bekleyen Kararlar)

The final motion-smoothing hysteresis remains pending transition tests. *(Nihai hareket smoothing hysteresis'i geçiş testlerini beklemektedir.)*

The final AI confidence threshold remains pending validation and calibration. *(Nihai yapay zekâ güven eşiği doğrulama ve kalibrasyonu beklemektedir.)*

The final step-length model remains pending collected walking data. *(Nihai adım uzunluğu modeli toplanmış yürüyüş verisini beklemektedir.)*

---

# 222. Runtime Decisions Pending Measurement (Ölçüm Bekleyen Çalışma Zamanı Kararları)

The final LiteRT delegate remains pending CPU-baseline measurements. *(Nihai LiteRT delegate CPU temel ölçümlerini beklemektedir.)*

The final quantization decision remains pending mobile benchmarks. *(Nihai quantization kararı mobil benchmark'ları beklemektedir.)*

The final sustained inference cadence remains pending device profiling. *(Nihai sürekli çıkarım kadansı cihaz profillemesini beklemektedir.)*

---

# 223. Final AI Architecture Statement (Nihai Yapay Zekâ Mimarisi Bildirimi)

**NAVGUARD will use artificial intelligence as a supporting navigation layer whose outputs remain physically interpretable and whose failure cannot disable the deterministic baseline navigation system.** *(NAVGUARD yapay zekâyı çıktıları fiziksel olarak yorumlanabilir kalan ve hatası deterministik temel navigasyon sistemini devre dışı bırakamayan destekleyici navigasyon katmanı olarak kullanacaktır.)*

**The mandatory AI task will classify sensor windows into `STATIONARY`, `WALKING`, `RUNNING`, and `TURNING` motion contexts, and those predictions must influence validated navigation behavior rather than serve only as user-interface labels.** *(Zorunlu yapay zekâ görevi sensör pencerelerini `STATIONARY`, `WALKING`, `RUNNING` ve `TURNING` hareket bağlamlarına sınıflandıracak ve bu tahminler yalnızca kullanıcı arayüzü etiketleri olarak hizmet etmek yerine doğrulanmış navigasyon davranışını etkilemelidir.)*

**A lightweight 1D-CNN will be the primary neural motion-classification candidate, while classical methods such as Random Forest will provide meaningful baselines under the same session-wise data split.** *(Hafif bir 1D-CNN birincil sinir ağı hareket sınıflandırma adayı olacak, Random Forest gibi klasik yöntemler aynı oturum bazlı veri ayrımı altında anlamlı temel yöntemler sağlayacaktır.)*

**A learned step-length estimator will remain a target enhancement and will be retained only if it produces measurable improvement over calibrated deterministic step-length methods.** *(Öğrenilmiş adım uzunluğu tahmin motoru hedef iyileştirme olarak kalacak ve yalnızca kalibre edilmiş deterministik adım uzunluğu yöntemlerine göre ölçülebilir iyileştirme üretirse korunacaktır.)*

**Model training will occur off-device in Python, while navigation-enabled neural inference will execute locally on Android through the native Kotlin AI layer using versioned `.tflite` deployment artifacts.** *(Model eğitimi cihaz dışında Python içerisinde gerçekleşirken navigasyon etkin sinir ağı çıkarımı sürümlenmiş `.tflite` deployment artifact'ları kullanılarak native Kotlin yapay zekâ katmanı üzerinden Android üzerinde yerel olarak çalışacaktır.)*

**Training and mobile inference will share a strict preprocessing contract covering sensor channels, units, timing, windowing, normalization, class order, and model schemas, and Python-to-Android parity testing will be mandatory before field deployment.** *(Eğitim ve mobil çıkarım sensör kanallarını, birimleri, zamanlamayı, pencerelemeyi, normalizasyonu, sınıf sırasını ve model şemalarını kapsayan katı ön işleme sözleşmesini paylaşacak ve saha deployment'ından önce Python-Android eşdeğerlik testi zorunlu olacaktır.)*

**AI datasets will use session-wise train, validation, and test separation so that overlapping windows from the same physical recording cannot leak across experimental splits.** *(Yapay zekâ veri setleri oturum bazlı train, validation ve test ayrımı kullanacak; böylece aynı fiziksel kayıttan örtüşen pencereler deneysel ayrımlar arasında sızamayacaktır.)*

**GNSS ground truth may support offline labeling and evaluation but will never become a live AI input capable of indirectly leaking reference position into the protected GNSS-denied estimator.** *(GNSS ground truth çevrimdışı etiketleme ve değerlendirmeyi destekleyebilir ancak referans konumu korunan GNSS kesintili tahmin motoruna dolaylı olarak sızdırabilecek canlı yapay zekâ girdisi haline hiçbir zaman gelmeyecektir.)*

**Every deployed model will be explicitly versioned with its preprocessing configuration, input and output schema, training dataset identity, file hash, and benchmark evidence so that every AI-assisted navigation result remains reproducible.** *(Deployment edilen her model ön işleme yapılandırması, girdi ve çıktı şeması, eğitim veri seti kimliği, dosya hash'i ve benchmark kanıtıyla açıkça sürümlenecek; böylece yapay zekâ destekli her navigasyon sonucu tekrarlanabilir kalacaktır.)*

---

# 224. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development Artificial Intelligence Architecture Completed *(Doküman Durumu: Geliştirme Öncesi Yapay Zekâ Mimarisi Tamamlandı)*

**Mandatory AI Task:** Motion Classification *(Zorunlu Yapay Zekâ Görevi: Hareket Sınıflandırması)*

**Target Motion Classes:** `STATIONARY / WALKING / RUNNING / TURNING` *(Hedef Hareket Sınıfları: `STATIONARY / WALKING / RUNNING / TURNING`)*

**Primary Neural Candidate:** Lightweight 1D-CNN *(Birincil Sinir Ağı Adayı: Hafif 1D-CNN)*

**Classical Baseline:** Random Forest *(Klasik Temel: Random Forest)*

**Simple Baseline:** Logistic Regression *(Basit Temel: Logistic Regression)*

**Motion AI Primary Metric:** Macro F1 *(Hareket Yapay Zekâsı Temel Metriği: Macro F1)*

**Provisional Motion Target:** Macro F1 `≥ 0.90` *(Geçici Hareket Hedefi: Macro F1 `≥ 0.90`)*

**Secondary AI Task:** Step Length Estimation *(İkincil Yapay Zekâ Görevi: Adım Uzunluğu Tahmini)*

**Step Length Baselines:** Fixed + Deterministic Variable Model *(Adım Uzunluğu Temelleri: Sabit + Deterministik Değişken Model)*

**Classical Step Length Models:** Linear Regression + Random Forest Regressor *(Klasik Adım Uzunluğu Modelleri: Linear Regression + Random Forest Regressor)*

**Neural Step Length Model:** Optional, Only if Justified *(Sinir Ağı Adım Uzunluğu Modeli: İsteğe Bağlı, Yalnızca Gerekçelendirilirse)*

**Training Platform:** Python *(Eğitim Platformu: Python)*

**Mobile AI Runtime Owner:** Kotlin Native Layer *(Mobil Yapay Zekâ Çalışma Zamanı Sahibi: Kotlin Native Katmanı)*

**Deployment Model Format:** `.tflite` *(Deployment Model Formatı: `.tflite`)*

**Core AI Connectivity:** Offline / On-Device *(Temel Yapay Zekâ Bağlantısı: Çevrimdışı / Cihaz Üzeri)*

**Dataset Split:** Session-Wise *(Veri Seti Ayrımı: Oturum Bazlı)*

**Overlapping Window Leakage:** Forbidden *(Örtüşen Pencere Sızıntısı: Yasak)*

**Training/Test Preprocessing Leakage:** Forbidden *(Eğitim/Test Ön İşleme Sızıntısı: Yasak)*

**Training-Mobile Preprocessing Parity:** Mandatory *(Eğitim-Mobil Ön İşleme Eşdeğerliği: Zorunlu)*

**Model Registry:** Mandatory *(Model Registry: Zorunlu)*

**Model File Hash:** Required for Final Deployment Artifacts *(Model Dosya Hash'i: Nihai Deployment Artifact'ları İçin Gerekli)*

**AI Direct Latitude/Longitude Prediction:** Forbidden *(Yapay Zekâ ile Doğrudan Enlem/Boylam Tahmini: Yasak)*

**GNSS Ground Truth as Live AI Feature:** Forbidden During Denial *(Canlı Yapay Zekâ Özelliği Olarak GNSS Ground Truth: Kesinti Sırasında Yasak)*

**Motion AI Fallback:** Deterministic Motion Logic *(Hareket Yapay Zekâsı Geri Dönüşü: Deterministik Hareket Mantığı)*

**Step Length AI Fallback:** Deterministic Step Length *(Adım Uzunluğu Yapay Zekâsı Geri Dönüşü: Deterministik Adım Uzunluğu)*

**Provisional Inference Latency Target:** `< 50 ms` on Redmi Note 9 Pro *(Geçici Çıkarım Gecikme Hedefi: Redmi Note 9 Pro Üzerinde `< 50 ms`)*

**Final Motion Window:** Pending Dataset Experiments *(Nihai Hareket Penceresi: Veri Seti Deneyleri Bekleniyor)*

**Final Motion Model:** Pending Baseline Comparison *(Nihai Hareket Modeli: Temel Yöntem Karşılaştırması Bekleniyor)*

**Final Step Length Model:** Pending Dataset and Navigation Evaluation *(Nihai Adım Uzunluğu Modeli: Veri Seti ve Navigasyon Değerlendirmesi Bekleniyor)*

**Final LiteRT Delegate:** Pending Device Benchmark *(Nihai LiteRT Delegate: Cihaz Benchmark'ı Bekleniyor)*

**Final Quantization Decision:** Pending Device Benchmark *(Nihai Quantization Kararı: Cihaz Benchmark'ı Bekleniyor)*

**Next Documentation Item:** 23 — Motion Classification Model *(Sonraki Dokümantasyon Öğesi: 23 — Hareket Sınıflandırma Modeli)*
