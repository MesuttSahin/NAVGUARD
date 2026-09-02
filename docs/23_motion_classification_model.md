# 23 — Motion Classification Model (Hareket Sınıflandırma Modeli)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the detailed design, dataset structure, class semantics, window construction, preprocessing, feature representation, baseline models, 1D-CNN architecture, training procedure, validation strategy, class-imbalance handling, model selection, temporal smoothing, confidence handling, LiteRT deployment preparation, Android parity testing, navigation integration, failure behavior, experiment protocol, metrics, and acceptance criteria of the NAVGUARD Motion Classification Model. *(Bu doküman, NAVGUARD Hareket Sınıflandırma Modelinin ayrıntılı tasarımını, veri seti yapısını, sınıf semantiğini, pencere oluşturmayı, ön işlemeyi, özellik temsilini, temel modelleri, 1D-CNN mimarisini, eğitim prosedürünü, doğrulama stratejisini, sınıf dengesizliği yönetimini, model seçimini, zamansal smoothing'i, güven yönetimini, LiteRT deployment hazırlığını, Android eşdeğerlik testini, navigasyon entegrasyonunu, hata davranışını, deney protokolünü, metrikleri ve kabul kriterlerini tanımlar.)*

The Motion Classification Model is the mandatory artificial-intelligence component of NAVGUARD. *(Hareket Sınıflandırma Modeli NAVGUARD'ın zorunlu yapay zekâ bileşenidir.)*

Its purpose is to infer the current pedestrian motion context from recent inertial sensor history and provide that context to deterministic navigation components. *(Amacı son ataletsel sensör geçmişinden mevcut yaya hareket bağlamını çıkarmak ve bu bağlamı deterministik navigasyon bileşenlerine sağlamaktır.)*

---

# 2. Research Objective (Araştırma Hedefi)

The primary model-level research objective is to determine whether smartphone inertial sensor windows can classify NAVGUARD motion contexts with sufficient accuracy for real-time navigation support. *(Temel model seviyesi araştırma hedefi akıllı telefon ataletsel sensör pencerelerinin NAVGUARD hareket bağlamlarını gerçek zamanlı navigasyon desteği için yeterli doğrulukla sınıflandırıp sınıflandıramayacağını belirlemektir.)*

The primary held-out performance target is Macro F1 of at least `0.90`. *(Temel ayrılmış performans hedefi en az `0.90` Macro F1 değeridir.)*

This value is a predefined target and not a measured project result. *(Bu değer önceden tanımlanmış bir hedeftir ve ölçülmüş proje sonucu değildir.)*

---

# 3. Navigation-Level Objective (Navigasyon Seviyesi Hedefi)

The model must provide operational context that improves or stabilizes navigation behavior. *(Model navigasyon davranışını iyileştiren veya kararlı hale getiren operasyonel bağlam sağlamalıdır.)*

A model with high classification metrics but no useful navigation effect will not automatically be considered successful at the system level. *(Yüksek sınıflandırma metriklerine sahip ancak kullanışlı navigasyon etkisi olmayan bir model sistem seviyesinde otomatik olarak başarılı kabul edilmeyecektir.)*

---

# 4. Target Classes (Hedef Sınıflar)

The initial final-class candidate set contains four motion contexts. *(İlk nihai sınıf aday seti dört hareket bağlamı içerir.)*

```text
STATIONARY
WALKING
RUNNING
TURNING
```

The trained class set is frozen as `STATIONARY`, `WALKING`, `RUNNING`, and `TURNING`. Data quality or class-separability findings may limit a class's validated navigation influence, but they do not authorize silent removal or schema simplification. Any class-set change requires an explicit Technical Decision and versioned Change Record that supersedes TD-058 before dataset freeze. *(Trained class set `STATIONARY`, `WALKING`, `RUNNING` ve `TURNING` olarak frozen'dır. Data quality veya class-separability bulguları bir sınıfın doğrulanmış navigation etkisini sınırlayabilir ancak sessiz removal veya schema simplification yetkisi vermez. Herhangi bir class-set değişikliği dataset freeze öncesinde TD-058'i supersede eden explicit Technical Decision ve versioned Change Record gerektirir.)*

---

# 5. Class Semantics Must Be Frozen Before Labeling (Sınıf Semantiği Etiketlemeden Önce Sabitlenmelidir)

Motion-class definitions must be established before large-scale dataset labeling begins. *(Hareket sınıfı tanımları büyük ölçekli veri seti etiketleme başlamadan önce oluşturulmalıdır.)*

Changing class meaning after seeing model errors can invalidate comparisons between dataset versions. *(Model hataları görüldükten sonra sınıf anlamını değiştirmek veri seti sürümleri arasındaki karşılaştırmaları geçersiz kılabilir.)*

---

# 6. STATIONARY Definition (STATIONARY Tanımı)

`STATIONARY` represents a period in which the pedestrian is intentionally remaining at approximately the same physical location. *(`STATIONARY`, yayanın bilinçli olarak yaklaşık aynı fiziksel konumda kaldığı bir dönemi temsil eder.)*

Small hand, arm, or phone-orientation changes are allowed inside this class. *(Bu sınıf içerisinde küçük el, kol veya telefon yönelim değişikliklerine izin verilir.)*

The class therefore represents absence of pedestrian translation rather than mathematical zero sensor activity. *(Bu nedenle sınıf matematiksel sıfır sensör aktivitesi yerine yaya yer değiştirmesinin olmamasını temsil eder.)*

---

# 7. WALKING Definition (WALKING Tanımı)

`WALKING` represents ordinary forward pedestrian locomotion using a normal walking gait. *(`WALKING`, normal yürüyüş gait'i kullanan sıradan ileri yaya hareketini temsil eder.)*

Natural minor heading changes may occur without converting every window into `TURNING`. *(Her pencereyi `TURNING` durumuna dönüştürmeden doğal küçük yön değişiklikleri meydana gelebilir.)*

---

# 8. RUNNING Definition (RUNNING Tanımı)

`RUNNING` represents pedestrian locomotion whose cadence and inertial characteristics are materially faster or more dynamic than ordinary walking. *(`RUNNING`, kadansı ve ataletsel özellikleri normal yürüyüşten anlamlı şekilde daha hızlı veya daha dinamik olan yaya hareketini temsil eder.)*

The exact collection protocol will define a safe controlled running pace rather than an athletic-performance requirement. *(Kesin veri toplama protokolü atletik performans gereksinimi yerine güvenli kontrollü koşu temposunu tanımlayacaktır.)*

---

# 9. TURNING Definition (TURNING Tanımı)

`TURNING` represents a short interval in which heading change is the dominant navigation-relevant motion characteristic. *(`TURNING`, yön değişiminin navigasyon açısından baskın hareket özelliği olduğu kısa bir aralığı temsil eder.)*

The pedestrian may continue stepping while the class is `TURNING`. *(Sınıf `TURNING` iken yaya adım atmaya devam edebilir.)*

`TURNING` must therefore not be interpreted as mutually exclusive with physical gait at the lowest biomechanical level. *(Bu nedenle `TURNING` en düşük biyomekanik seviyede fiziksel gait ile karşılıklı dışlayıcı olarak yorumlanmamalıdır.)*

---

# 10. Hierarchical Meaning of TURNING (TURNING Sınıfının Hiyerarşik Anlamı)

The four-class formulation intentionally treats `TURNING` as the dominant short-term navigation context when rotational motion exceeds the defined transition criteria. *(Dört sınıflı formülasyon, dönme hareketi tanımlanan geçiş kriterlerini aştığında `TURNING` durumunu bilinçli olarak baskın kısa dönem navigasyon bağlamı olarak ele alır.)*

This converts a potentially multi-label physical situation into a single-label operational classification problem. *(Bu potansiyel olarak çok etiketli fiziksel durumu tek etiketli operasyonel sınıflandırma problemine dönüştürür.)*

---

# 11. Turning Label Threshold Must Be Protocol-Based (Dönüş Etiketi Eşiği Protokol Tabanlı Olmalıdır)

The dataset protocol will define how much directional change constitutes a `TURNING` segment. *(Veri seti protokolü ne kadar yön değişiminin bir `TURNING` segmenti oluşturduğunu tanımlayacaktır.)*

The final angular and temporal thresholds will be selected during pilot annotation work. *(Nihai açısal ve zamansal eşikler pilot anotasyon çalışması sırasında seçilecektir.)*

They will be frozen before final model training. *(Nihai model eğitiminden önce sabitleneceklerdir.)*

---

# 12. Primary Sensor Inputs (Temel Sensör Girdileri)

The primary model input will use accelerometer and gyroscope channels. *(Temel model girdisi ivmeölçer ve jiroskop kanallarını kullanacaktır.)*

```text
Accelerometer:
ax
ay
az

Gyroscope:
gx
gy
gz
```

All channels will preserve the unit conventions defined by the acquisition and preprocessing architecture. *(Tüm kanallar veri toplama ve ön işleme mimarisinde tanımlanan birim kurallarını koruyacaktır.)*

---

# 13. Minimum Input Tensor (Minimum Girdi Tensor'u)

The minimum six-channel raw time-series tensor will have the conceptual structure below. *(Minimum altı kanallı ham zaman serisi tensor'u aşağıdaki kavramsal yapıya sahip olacaktır.)*

```text
X ∈ R^(T × 6)
```

`T` represents the number of synchronized time samples inside one model window. *(`T`, bir model penceresi içerisindeki senkronize zaman örneği sayısını temsil eder.)*

The six channels correspond to `[ax, ay, az, gx, gy, gz]`. *(Altı kanal `[ax, ay, az, gx, gy, gz]` değerlerine karşılık gelir.)*

---

# 14. Batch Tensor Shape (Batch Tensor Şekli)

During training, multiple windows may be represented as follows. *(Eğitim sırasında birden fazla pencere aşağıdaki şekilde temsil edilebilir.)*

```text
X_batch ∈ R^(B × T × C)
```

`B` is batch size. *(`B`, batch boyutudur.)*

`T` is samples per window. *(`T`, pencere başına örnek sayısıdır.)*

`C` is the number of input channels. *(`C`, girdi kanal sayısıdır.)*

---

# 15. Optional Derived Channels (İsteğe Bağlı Türetilmiş Kanallar)

Acceleration magnitude may be evaluated as an additional model channel. *(İvme büyüklüğü ek model kanalı olarak değerlendirilebilir.)*

```text
a_mag =
√(ax² + ay² + az²)
```

Gyroscope magnitude may also be evaluated. *(Jiroskop büyüklüğü de değerlendirilebilir.)*

```text
g_mag =
√(gx² + gy² + gz²)
```

---

# 16. Derived Channels Require Ablation Evidence (Türetilmiş Kanallar Ablation Kanıtı Gerektirir)

Derived channels will not automatically be added to the final model. *(Türetilmiş kanallar nihai modele otomatik olarak eklenmeyecektir.)*

An ablation experiment must determine whether they improve held-out performance enough to justify additional preprocessing. *(Bir ablation deneyi ek ön işlemeyi gerekçelendirecek kadar ayrılmış performansı iyileştirip iyileştirmediklerini belirlemelidir.)*

---

# 17. Magnetometer Is Not a Default Input (Manyetometre Varsayılan Girdi Değildir)

Magnetometer measurements will not be included in the default motion-classification tensor. *(Manyetometre ölçümleri varsayılan hareket sınıflandırma tensor'una dahil edilmeyecektir.)*

The model should not become dependent on environmentally unstable magnetic conditions unless experiments show a strong reason. *(Deneyler güçlü bir neden göstermediği sürece model çevresel olarak kararsız manyetik koşullara bağımlı hale gelmemelidir.)*

---

# 18. Rotation Vector Is Not a Default Input (Rotation Vector Varsayılan Girdi Değildir)

Android rotation-vector output will not be required by the minimum classifier. *(Android rotation-vector çıktısı minimum sınıflandırıcı tarafından gerektirilmeyecektir.)*

This keeps the mandatory model dependent primarily on physical inertial channels that are available in the minimum architecture. *(Bu zorunlu modeli temel olarak minimum mimaride mevcut fiziksel ataletsel kanallara bağımlı tutar.)*

---

# 19. Input Sampling Target (Girdi Örnekleme Hedefi)

The current default research target is approximately `50 Hz` accelerometer and `50 Hz` gyroscope acquisition. *(Mevcut varsayılan araştırma hedefi yaklaşık `50 Hz` ivmeölçer ve `50 Hz` jiroskop veri toplamadır.)*

This remains a requested operating target rather than an assumption of exact delivery. *(Bu kesin teslim varsayımı yerine talep edilmiş çalışma hedefi olarak kalır.)*

---

# 20. Measured Timing Is Authoritative (Ölçülmüş Zamanlama Esastır)

Actual sensor timestamps will determine real temporal spacing. *(Gerçek sensör zaman damgaları gerçek zamansal aralığı belirleyecektir.)*

The AI pipeline will not assume that every consecutive raw sensor event is exactly `20 ms` apart merely because `50 Hz` was requested. *(Yapay zekâ hattı yalnızca `50 Hz` talep edildiği için her ardışık ham sensör olayının tam olarak `20 ms` aralıklı olduğunu varsaymayacaktır.)*

---

# 21. Regular Model Grid (Düzenli Model Zaman Grid'i)

If the neural network requires a fixed-size tensor, synchronized sensor data may be resampled onto a regular model grid. *(Sinir ağı sabit boyutlu tensor gerektirirse senkronize sensör verisi düzenli model zaman grid'ine yeniden örneklenebilir.)*

The resampling procedure will be identical in Python and Android. *(Yeniden örnekleme prosedürü Python ve Android'de aynı olacaktır.)*

---

# 22. Resampling Candidate (Yeniden Örnekleme Adayı)

Linear interpolation is the initial candidate for small timing irregularities in continuous inertial channels. *(Doğrusal interpolasyon sürekli ataletsel kanallardaki küçük zamanlama düzensizlikleri için ilk adaydır.)*

Large data gaps will invalidate the window instead of being hidden through long interpolation. *(Büyük veri boşlukları uzun interpolasyonla gizlenmek yerine pencereyi geçersiz kılacaktır.)*

---

# 23. Final Sampling Frequency (Nihai Örnekleme Frekansı)

The final model-grid frequency will be frozen only after Device Capability Audit data confirms stable delivered sensor behavior. *(Nihai model grid frekansı yalnızca Cihaz Yetenek Denetimi verisi kararlı teslim edilen sensör davranışını doğruladıktan sonra sabitlenecektir.)*

The initial candidate remains `50 Hz`. *(İlk aday `50 Hz` olarak kalmaktadır.)*

---

# 24. Window Duration Candidates (Pencere Süresi Adayları)

The model will compare multiple short causal window durations during development. *(Model geliştirme sırasında birden fazla kısa nedensel pencere süresini karşılaştıracaktır.)*

Initial candidates may include approximately `1.0 s`, `1.5 s`, and `2.0 s`. *(İlk adaylar yaklaşık `1.0 s`, `1.5 s` ve `2.0 s` değerlerini içerebilir.)*

These values are experiment candidates rather than frozen specifications. *(Bu değerler sabitlenmiş spesifikasyonlar yerine deney adaylarıdır.)*

---

# 25. Example Tensor Sizes at 50 Hz (50 Hz'de Örnek Tensor Boyutları)

A `1.0 s` six-channel window at a `50 Hz` model grid would contain approximately `50 × 6` values. *(`50 Hz` model grid'inde `1.0 s` altı kanallı pencere yaklaşık `50 × 6` değer içerir.)*

A `1.5 s` window would contain approximately `75 × 6` values. *(`1.5 s` pencere yaklaşık `75 × 6` değer içerir.)*

A `2.0 s` window would contain approximately `100 × 6` values. *(`2.0 s` pencere yaklaşık `100 × 6` değer içerir.)*

These shapes apply only if the final resampling grid is frozen at `50 Hz`. *(Bu şekiller yalnızca nihai yeniden örnekleme grid'i `50 Hz` olarak sabitlenirse geçerlidir.)*

---

# 26. Window Selection Objective (Pencere Seçim Hedefi)

Window selection will optimize the trade-off between classification quality and operational delay. *(Pencere seçimi sınıflandırma kalitesi ile operasyonel gecikme arasındaki trade-off'u optimize edecektir.)*

A longer window is not automatically better. *(Daha uzun pencere otomatik olarak daha iyi değildir.)*

---

# 27. Window Overlap Candidates (Pencere Örtüşme Adayları)

Candidate overlap ratios may include `0%`, `50%`, and `75%`. *(Aday örtüşme oranları `%0`, `%50` ve `%75` değerlerini içerebilir.)*

Higher overlap produces more frequent predictions but increases inference workload and dataset correlation. *(Daha yüksek örtüşme daha sık tahmin üretir ancak çıkarım yükünü ve veri seti korelasyonunu artırır.)*

---

# 28. Split Before Window Leakage Can Occur (Pencere Sızıntısı Oluşmadan Önce Ayrım)

Physical recording sessions will be assigned to train, validation, or test groups before model evaluation uses their windows. *(Fiziksel kayıt oturumları model değerlendirmesi onların pencerelerini kullanmadan önce train, validation veya test gruplarına atanacaktır.)*

Windows will then inherit their parent session's split. *(Pencereler daha sonra ana oturumlarının ayrımını miras alacaktır.)*

---

# 29. Forbidden Random Window Split (Yasak Rastgele Pencere Ayrımı)

NAVGUARD will not randomly shuffle all overlapping windows and then perform a train-test split. *(NAVGUARD tüm örtüşen pencereleri rastgele karıştırıp ardından train-test ayrımı yapmayacaktır.)*

Such a procedure could place nearly identical neighbouring windows from one physical session into both training and test sets. *(Böyle bir prosedür tek fiziksel oturumdan neredeyse aynı komşu pencereleri hem eğitim hem de test setine yerleştirebilir.)*

---

# 30. Session-Level Dataset Structure (Oturum Seviyesi Veri Seti Yapısı)

```text
Dataset
│
├── Session 001
│   ├── raw sensors
│   ├── labels
│   └── metadata
│
├── Session 002
│
├── Session 003
│
└── ...
```

Each session will have one immutable split assignment for a specific dataset version. *(Her oturum belirli bir veri seti sürümü için tek değişmez ayrım atamasına sahip olacaktır.)*

---

# 31. Recommended Dataset Split Principle (Önerilen Veri Seti Ayrım İlkesi)

The dataset should preserve independent sessions in all three development groups where data volume permits. *(Veri miktarı izin verdiğinde veri seti üç geliştirme grubunun tamamında bağımsız oturumları korumalıdır.)*

The exact percentage split will depend on the number of collected sessions. *(Kesin yüzde ayrımı toplanan oturum sayısına bağlı olacaktır.)*

A fixed percentage will not be frozen before the dataset size is known. *(Veri seti boyutu bilinmeden sabit yüzde sabitlenmeyecektir.)*

---

# 32. Route Diversity (Rota Çeşitliliği)

Motion data should be collected across more than one route or physical environment. *(Hareket verisi birden fazla rota veya fiziksel ortamda toplanmalıdır.)*

This reduces the risk that the model learns one route's vibration or handling pattern rather than the intended motion class. *(Bu modelin amaçlanan hareket sınıfı yerine tek bir rotanın titreşim veya tutuş örüntüsünü öğrenmesi riskini azaltır.)*

---

# 33. Session Diversity (Oturum Çeşitliliği)

Each class should be represented across multiple independent recording sessions. *(Her sınıf birden fazla bağımsız kayıt oturumunda temsil edilmelidir.)*

One long continuous recording divided into thousands of windows is not equivalent to thousands of independent observations. *(Binlerce pencereye bölünmüş tek uzun sürekli kayıt binlerce bağımsız gözleme eşdeğer değildir.)*

---

# 34. Collection-Day Diversity (Toplama Günü Çeşitliliği)

Where practical, important motion classes should be recorded on more than one collection day. *(Uygulanabilir olduğunda önemli hareket sınıfları birden fazla veri toplama gününde kaydedilmelidir.)*

This introduces natural variation in handling and gait. *(Bu tutuş ve gait içerisinde doğal çeşitlilik oluşturur.)*

---

# 35. Formal Placement Consistency (Resmî Yerleşim Tutarlılığı)

The primary model will use the formal controlled phone placement selected for NAVGUARD benchmarks. *(Temel model NAVGUARD benchmark'ları için seçilen resmî kontrollü telefon yerleşimini kullanacaktır.)*

Arbitrary pocket, bag, or free-hand generalization will not be claimed unless explicitly tested. *(Keyfi cep, çanta veya serbest el genellemesi açıkça test edilmedikçe iddia edilmeyecektir.)*

---

# 36. Label Source (Etiket Kaynağı)

Ground-truth motion labels will come from the experiment protocol and session annotation records. *(Ground truth hareket etiketleri deney protokolünden ve oturum anotasyon kayıtlarından gelecektir.)*

The model's previous predictions will not be used as final ground-truth labels for its own training data. *(Modelin önceki tahminleri kendi eğitim verisi için nihai ground truth etiketleri olarak kullanılmayacaktır.)*

---

# 37. Protocol-Controlled Sessions (Protokol Kontrollü Oturumlar)

The easiest high-confidence training sessions will contain intentionally executed activity segments. *(En kolay yüksek güvenli eğitim oturumları bilinçli olarak gerçekleştirilen aktivite segmentlerini içerecektir.)*

```text
Example:

STATIONARY
→ WALKING
→ STATIONARY
→ TURNING
→ WALKING
→ RUNNING
→ STATIONARY
```

Segment start and end events will be logged or annotated. *(Segment başlangıç ve bitiş olayları kaydedilecek veya annotate edilecektir.)*

---

# 38. Label Boundary Uncertainty (Etiket Sınırı Belirsizliği)

Human movement does not transition between states instantaneously. *(İnsan hareketi durumlar arasında anlık olarak geçiş yapmaz.)*

The exact transition boundary may therefore contain uncertain examples. *(Bu nedenle kesin geçiş sınırı belirsiz örnekler içerebilir.)*

---

# 39. Transition Exclusion Zone Candidate (Geçiş Hariç Tutma Bölgesi Adayı)

The initial dataset may exclude a short interval around manually defined class transitions. *(İlk veri seti manuel olarak tanımlanan sınıf geçişlerinin çevresindeki kısa aralığı hariç tutabilir.)*

The exact exclusion duration will be determined during pilot annotation. *(Kesin hariç tutma süresi pilot anotasyon sırasında belirlenecektir.)*

This can produce cleaner initial class definitions. *(Bu daha temiz ilk sınıf tanımları üretebilir.)*

---

# 40. Dominant-Label Alternative (Baskın Etiket Alternatifi)

A later dataset version may label transition windows according to the activity occupying the majority of the window. *(Daha sonraki veri seti sürümü geçiş pencerelerini pencerenin çoğunluğunu kaplayan aktiviteye göre etiketleyebilir.)*

This policy must be tested rather than silently introduced. *(Bu politika sessizce dahil edilmek yerine test edilmelidir.)*

---

# 41. TURNING Annotation Challenge (TURNING Anotasyon Zorluğu)

`TURNING` requires particular care because ordinary walking routes contain continuous minor directional corrections. *(`TURNING`, normal yürüyüş rotaları sürekli küçük yön düzeltmeleri içerdiği için özel dikkat gerektirir.)*

The annotation protocol must distinguish deliberate navigation turns from natural small heading variation. *(Anotasyon protokolü bilinçli navigasyon dönüşlerini doğal küçük yön değişiminden ayırt etmelidir.)*

---

# 42. TURNING Reference Evidence (TURNING Referans Kanıtı)

Gyroscope activity and the independently derived heading-change record may assist offline annotation of turning intervals. *(Jiroskop aktivitesi ve bağımsız türetilmiş yön değişim kaydı dönüş aralıklarının çevrimdışı anotasyonuna yardımcı olabilir.)*

These signals may support label construction without becoming hidden ground-truth position inputs to the deployed classifier. *(Bu sinyaller deployment sınıflandırıcısına gizli ground truth konum girdisi haline gelmeden etiket oluşturmayı destekleyebilir.)*

---

# 43. GNSS Is Not Required for Motion Labels (Hareket Etiketleri İçin GNSS Gerekli Değildir)

GNSS position is not required to determine whether a controlled collection segment was stationary, walking, running, or turning. *(Kontrollü veri toplama segmentinin sabit, yürüme, koşma veya dönme olup olmadığını belirlemek için GNSS konumu gerekli değildir.)*

The motion model will therefore remain independent of live GNSS. *(Bu nedenle hareket modeli canlı GNSS'ten bağımsız kalacaktır.)*

---

# 44. Raw Dataset Fields (Ham Veri Seti Alanları)

Each session should preserve raw timestamped inertial data before model-specific transformations. *(Her oturum modele özgü dönüşümlerden önce ham zaman damgalı ataletsel veriyi korumalıdır.)*

```text
session_id
timestamp_ns
ax
ay
az
gx
gy
gz
sensor_accuracy
sequence_number
```

Additional metadata may be stored outside the high-frequency table. *(Ek metadata yüksek frekanslı tablonun dışında saklanabilir.)*

---

# 45. Session Metadata (Oturum Metadata Bilgisi)

```text
session_id
device_id
device_model
collection_date
placement_protocol
route_id
activity_protocol
sensor_profile
label_version
notes
```

This information supports reproducibility and error analysis. *(Bu bilgi tekrarlanabilirliği ve hata analizini destekler.)*

---

# 46. Window Dataset Record (Pencere Veri Seti Kaydı)

Each generated model window should retain traceability to its parent session. *(Üretilen her model penceresi ana oturumuna izlenebilirliği korumalıdır.)*

```text
window_id
session_id
window_start_ns
window_end_ns
label
split
preprocessing_version
```

---

# 47. No Anonymous Window Origin (Anonim Pencere Kökeni Olmaması)

Model-ready windows must not lose their session identity after preprocessing. *(Modele hazır pencereler ön işlemeden sonra oturum kimliğini kaybetmemelidir.)*

This is necessary to audit data leakage. *(Bu veri sızıntısını denetlemek için gereklidir.)*

---

# 48. Data Quality Gate Before Window Generation (Pencere Üretiminden Önce Veri Kalite Kapısı)

A physical session must pass basic integrity checks before its windows enter the AI dataset. *(Fiziksel bir oturum pencereleri yapay zekâ veri setine girmeden önce temel bütünlük kontrollerini geçmelidir.)*

Mandatory channels must exist. *(Zorunlu kanallar mevcut olmalıdır.)*

Timestamps must be sufficiently valid. *(Zaman damgaları yeterince geçerli olmalıdır.)*

The label record must be interpretable. *(Etiket kaydı yorumlanabilir olmalıdır.)*

---

# 49. Window Completeness (Pencere Bütünlüğü)

A model window must contain enough valid sensor coverage for the frozen model-grid construction. *(Bir model penceresi sabitlenmiş model grid oluşturma için yeterli geçerli sensör kapsamı içermelidir.)*

Windows with major acquisition gaps will be excluded rather than fabricated. *(Büyük veri toplama boşluklarına sahip pencereler uydurulmak yerine hariç tutulacaktır.)*

---

# 50. Preprocessing Pipeline (Ön İşleme Hattı)

```text
Raw Accelerometer + Gyroscope
          ↓
Timestamp Validation
          ↓
Time Synchronization
          ↓
Optional Light Filtering
          ↓
Resampling
          ↓
Window Extraction
          ↓
Normalization
          ↓
Tensor Construction
          ↓
Model
```

Every transformation will be versioned. *(Her dönüşüm sürümlenecektir.)*

---

# 51. Filtering Policy (Filtreleme Politikası)

The neural classifier will initially be tested with minimal filtering. *(Sinir ağı sınıflandırıcı başlangıçta minimum filtreleme ile test edilecektir.)*

The objective is to avoid removing useful gait dynamics before evidence shows that filtering improves performance. *(Amaç filtrelemenin performansı iyileştirdiğine dair kanıt oluşmadan kullanışlı gait dinamiklerini kaldırmaktan kaçınmaktır.)*

---

# 52. Filter Ablation (Filtre Ablation)

A simple low-pass or comparable lightweight filter may be compared against raw synchronized signals. *(Basit low-pass veya benzer hafif filtre ham senkronize sinyallerle karşılaştırılabilir.)*

Filtering will be retained only if validation results justify it. *(Filtreleme yalnızca doğrulama sonuçları gerekçelendirirse korunacaktır.)*

---

# 53. No Offline-Only Preprocessing (Yalnızca Çevrimdışı Ön İşleme Olmaması)

A transformation required by the final model must be practical to reproduce on Android in real time. *(Nihai model tarafından gereken bir dönüşüm Android üzerinde gerçek zamanlı olarak yeniden üretilebilir olmalıdır.)*

An offline feature that cannot be causally computed on the phone cannot be used by the deployed model. *(Telefonda nedensel olarak hesaplanamayan çevrimdışı bir özellik deployment edilen model tarafından kullanılamaz.)*

---

# 54. Normalization Strategy (Normalizasyon Stratejisi)

Per-channel standardization is the preferred initial normalization candidate. *(Kanal başına standardizasyon tercih edilen ilk normalizasyon adayıdır.)*

```text
x' =
(x - μ_train,c) / σ_train,c
```

The statistics will be calculated from training windows only. *(İstatistikler yalnızca eğitim pencerelerinden hesaplanacaktır.)*

---

# 55. Channel-Specific Statistics (Kanala Özgü İstatistikler)

Each input channel may have its own training mean and standard deviation. *(Her girdi kanalı kendi eğitim ortalamasına ve standart sapmasına sahip olabilir.)*

Accelerometer and gyroscope channels will not share normalization parameters merely for convenience. *(İvmeölçer ve jiroskop kanalları yalnızca kolaylık için normalizasyon parametrelerini paylaşmayacaktır.)*

---

# 56. Zero-Variance Protection (Sıfır Varyans Koruması)

A channel with near-zero training standard deviation must trigger preprocessing validation rather than division by an invalid value. *(Sıfıra yakın eğitim standart sapmasına sahip kanal geçersiz değere bölme yerine ön işleme doğrulaması tetiklemelidir.)*

---

# 57. Orientation Dependence (Yönelime Bağımlılık)

Raw accelerometer and gyroscope axes depend on phone orientation. *(Ham ivmeölçer ve jiroskop eksenleri telefon yönelimine bağlıdır.)*

The formal controlled placement therefore forms part of the model's deployment assumptions. *(Bu nedenle resmî kontrollü yerleşim modelin deployment varsayımlarının bir parçasını oluşturur.)*

---

# 58. Orientation-Invariant Experiment Candidate (Yönelimden Bağımsız Deney Adayı)

Magnitude-derived channels may reduce some sensitivity to device orientation. *(Büyüklük türetilmiş kanallar cihaz yönelimine olan bazı hassasiyetleri azaltabilir.)*

This benefit must be evaluated experimentally rather than assumed. *(Bu fayda varsayılmak yerine deneysel olarak değerlendirilmelidir.)*

---

# 59. Baseline Model 1 — Logistic Regression (Temel Model 1 — Logistic Regression)

Logistic Regression will provide a simple linear classification baseline using engineered window features rather than raw sequence convolution. *(Logistic Regression ham dizi convolution yerine engineered pencere özelliklerini kullanarak basit doğrusal sınıflandırma temeli sağlayacaktır.)*

Its purpose is primarily to establish how much performance can be achieved with a low-complexity linear decision boundary. *(Amacı temel olarak düşük karmaşıklıklı doğrusal karar sınırıyla ne kadar performans elde edilebildiğini belirlemektir.)*

---

# 60. Baseline Model 2 — Random Forest (Temel Model 2 — Random Forest)

Random Forest will serve as the primary classical nonlinear baseline. *(Random Forest temel klasik doğrusal olmayan model olacaktır.)*

It will use interpretable statistical features extracted from the same training sessions. *(Aynı eğitim oturumlarından çıkarılan yorumlanabilir istatistiksel özellikleri kullanacaktır.)*

---

# 61. Classical Feature Candidates (Klasik Özellik Adayları)

Classical models may use features such as per-channel mean, standard deviation, minimum, maximum, range, RMS, and energy-like statistics. *(Klasik modeller kanal başına ortalama, standart sapma, minimum, maksimum, aralık, RMS ve enerji benzeri istatistikler gibi özellikleri kullanabilir.)*

Cadence-related or peak-count features may also be evaluated. *(Kadansla ilişkili veya peak-count özellikleri de değerlendirilebilir.)*

---

# 62. Feature Definition Must Be Causal (Özellik Tanımı Nedensel Olmalıdır)

Every classical feature used by a navigation-enabled model must be computable from the current and past samples inside the active window. *(Navigasyon etkin model tarafından kullanılan her klasik özellik aktif pencere içerisindeki mevcut ve geçmiş örneklerden hesaplanabilir olmalıdır.)*

---

# 63. Classical Features Are Versioned (Klasik Özellikler Sürümlenir)

The exact feature list and ordering will be stored as a feature-schema version. *(Kesin özellik listesi ve sırası özellik şema sürümü olarak saklanacaktır.)*

---

# 64. Primary Neural Architecture (Birincil Sinir Ağı Mimarisi)

A lightweight 1D-CNN will be the primary neural candidate. *(Hafif bir 1D-CNN birincil sinir ağı adayı olacaktır.)*

The convolution axis will represent time. *(Convolution ekseni zamanı temsil edecektir.)*

Input channels will represent synchronized inertial measurements. *(Girdi kanalları senkronize ataletsel ölçümleri temsil edecektir.)*

---

# 65. Initial 1D-CNN Design Philosophy (İlk 1D-CNN Tasarım Felsefesi)

The network will start small. *(Ağ küçük başlayacaktır.)*

The first architecture will use a limited number of convolution blocks and a small classification head. *(İlk mimari sınırlı sayıda convolution block ve küçük sınıflandırma head'i kullanacaktır.)*

Model depth will increase only if validation evidence justifies it. *(Model derinliği yalnızca doğrulama kanıtı gerekçelendirirse artırılacaktır.)*

---

# 66. Candidate 1D-CNN Architecture A (Aday 1D-CNN Mimarisi A)

```text
Input
[T × C]

↓
Conv1D
32 filters
kernel size 5

↓
ReLU

↓
MaxPooling1D

↓
Conv1D
64 filters
kernel size 3

↓
ReLU

↓
GlobalAveragePooling1D

↓
Dense
32 units

↓
ReLU

↓
Output Dense
4 units
Softmax
```

This is an initial experiment candidate rather than the frozen final architecture. *(Bu sabitlenmiş nihai mimari yerine ilk deney adayıdır.)*

---

# 67. Candidate 1D-CNN Architecture B (Aday 1D-CNN Mimarisi B)

A slightly smaller architecture may use one convolution block followed by global pooling and a compact dense classifier. *(Biraz daha küçük mimari tek convolution block ardından global pooling ve kompakt dense sınıflandırıcı kullanabilir.)*

This candidate will test whether the second convolution stage provides meaningful benefit. *(Bu aday ikinci convolution aşamasının anlamlı fayda sağlayıp sağlamadığını test edecektir.)*

---

# 68. Candidate 1D-CNN Architecture C (Aday 1D-CNN Mimarisi C)

A slightly larger architecture may use three compact convolution stages. *(Biraz daha büyük mimari üç kompakt convolution aşaması kullanabilir.)*

It will be retained only if the performance gain justifies added latency and parameter count. *(Yalnızca performans artışı ek gecikmeyi ve parametre sayısını gerekçelendirirse korunacaktır.)*

---

# 69. Kernel Size Search (Kernel Boyutu Araması)

Small temporal kernels such as `3`, `5`, and potentially `7` samples may be compared. *(`3`, `5` ve potansiyel olarak `7` örnek gibi küçük zamansal kernel'ler karşılaştırılabilir.)*

The final kernel configuration will be selected on validation sessions. *(Nihai kernel yapılandırması doğrulama oturumlarında seçilecektir.)*

---

# 70. Filter Count Search (Filter Sayısı Araması)

Candidate filter counts will remain intentionally modest. *(Aday filter sayıları bilinçli olarak makul seviyede kalacaktır.)*

Typical experiment values may include `16`, `32`, and `64` filters per block. *(Tipik deney değerleri block başına `16`, `32` ve `64` filter içerebilir.)*

These are search candidates rather than requirements. *(Bunlar gereksinimler yerine arama adaylarıdır.)*

---

# 71. Pooling Strategy (Pooling Stratejisi)

Max pooling may be evaluated for local temporal downsampling. *(Max pooling yerel zamansal downsampling için değerlendirilebilir.)*

Global average pooling is preferred over a large flattened representation when it reduces parameters without harming validation performance. *(Global average pooling doğrulama performansına zarar vermeden parametreleri azaltıyorsa büyük flattened temsile göre tercih edilir.)*

---

# 72. Dense Head (Dense Head)

The classification head will remain compact. *(Sınıflandırma head'i kompakt kalacaktır.)*

A small hidden dense layer may be used before the four-class output layer. *(Dört sınıflı çıktı katmanından önce küçük hidden dense katmanı kullanılabilir.)*

---

# 73. Output Layer (Çıktı Katmanı)

The final classifier output will contain one score for each retained motion class. *(Nihai sınıflandırıcı çıktısı korunan her hareket sınıfı için bir skor içerecektir.)*

For the four-class formulation, the output dimension will be four. *(Dört sınıflı formülasyon için çıktı boyutu dört olacaktır.)*

---

# 74. Softmax Output (Softmax Çıktısı)

The neural model may use a Softmax output for mutually exclusive operational motion classes. *(Sinir ağı modeli karşılıklı dışlayıcı operasyonel hareket sınıfları için Softmax çıktı kullanabilir.)*

The resulting values will be treated as model scores unless confidence calibration demonstrates stronger probabilistic interpretation. *(Ortaya çıkan değerler güven kalibrasyonu daha güçlü olasılıksal yorum göstermediği sürece model skorları olarak ele alınacaktır.)*

---

# 75. Loss Function Candidate (Loss Fonksiyonu Adayı)

Categorical cross-entropy or sparse categorical cross-entropy is the expected initial neural-training loss depending on label encoding. *(Categorical cross-entropy veya sparse categorical cross-entropy etiket kodlamasına bağlı olarak beklenen ilk sinir ağı eğitim loss'udur.)*

The exact implementation will remain consistent across training runs being compared. *(Kesin uygulama karşılaştırılan eğitim çalışmaları arasında tutarlı kalacaktır.)*

---

# 76. Optimizer Candidate (Optimizer Adayı)

Adam is the initial optimizer candidate for the 1D-CNN. *(Adam 1D-CNN için ilk optimizer adayıdır.)*

The learning rate will be treated as a tunable training parameter. *(Learning rate ayarlanabilir eğitim parametresi olarak ele alınacaktır.)*

---

# 77. Learning-Rate Candidates (Learning Rate Adayları)

Initial learning-rate experiments may compare values around `1e-3` and lower values when needed. *(İlk learning-rate deneyleri yaklaşık `1e-3` ve gerektiğinde daha düşük değerleri karşılaştırabilir.)*

The final learning rate will be selected using validation performance. *(Nihai learning rate doğrulama performansı kullanılarak seçilecektir.)*

---

# 78. Batch Size (Batch Boyutu)

Batch size will be selected according to training stability and available development-computer memory. *(Batch boyutu eğitim kararlılığına ve mevcut geliştirme bilgisayarı belleğine göre seçilecektir.)*

Batch size is not a mobile inference parameter. *(Batch boyutu mobil çıkarım parametresi değildir.)*

On-device inference will normally operate with one current window at a time. *(Cihaz üzeri çıkarım normalde bir seferde bir mevcut pencereyle çalışacaktır.)*

---

# 79. Epoch Limit (Epoch Sınırı)

A maximum epoch count may be defined for reproducibility. *(Tekrarlanabilirlik için maksimum epoch sayısı tanımlanabilir.)*

Early stopping may terminate training earlier when validation performance stops improving. *(Validation performansı iyileşmeyi durdurduğunda early stopping eğitimi daha erken sonlandırabilir.)*

---

# 80. Early Stopping Monitor (Early Stopping Monitörü)

Validation Macro F1 or validation loss may be considered as stopping evidence depending on training implementation. *(Eğitim uygulamasına bağlı olarak validation Macro F1 veya validation loss durdurma kanıtı olarak değerlendirilebilir.)*

The monitored quantity will be frozen in the training configuration. *(İzlenen büyüklük eğitim yapılandırmasında sabitlenecektir.)*

---

# 81. Best-Checkpoint Policy (En İyi Checkpoint Politikası)

The final candidate from a training run will use the best validation checkpoint according to the predefined selection metric rather than automatically the final epoch. *(Bir eğitim çalışmasındaki nihai aday otomatik olarak son epoch yerine önceden tanımlanmış seçim metriğine göre en iyi validation checkpoint'i kullanacaktır.)*

---

# 82. Regularization (Regularization)

Dropout may be evaluated if the 1D-CNN exhibits overfitting. *(1D-CNN overfitting gösterirse dropout değerlendirilebilir.)*

Weight regularization may also be evaluated if justified. *(Gerekçelendirilirse weight regularization da değerlendirilebilir.)*

Regularization will not be added without evidence merely because it is common practice. *(Regularization yalnızca yaygın uygulama olduğu için kanıt olmadan eklenmeyecektir.)*

---

# 83. Class Imbalance Audit (Sınıf Dengesizliği Denetimi)

The number of windows and independent sessions per class will be calculated after dataset construction. *(Veri seti oluşturulduktan sonra sınıf başına pencere ve bağımsız oturum sayısı hesaplanacaktır.)*

Both values matter. *(Her iki değer de önemlidir.)*

---

# 84. Window Count Can Be Misleading (Pencere Sayısı Yanıltıcı Olabilir)

A class may contain many overlapping windows from very few independent sessions. *(Bir sınıf çok az bağımsız oturumdan çok sayıda örtüşen pencere içerebilir.)*

NAVGUARD will therefore report both window count and session coverage. *(Bu nedenle NAVGUARD hem pencere sayısını hem de oturum kapsamını raporlayacaktır.)*

---

# 85. Class Weighting (Class Weighting)

Class weighting may be used during training when class imbalance is meaningful. *(Sınıf dengesizliği anlamlı olduğunda eğitim sırasında class weighting kullanılabilir.)*

Weights will be calculated from the training split only. *(Ağırlıklar yalnızca eğitim ayrımından hesaplanacaktır.)*

---

# 86. Balanced Sampling (Dengeli Sampling)

Balanced batch sampling may be evaluated as an alternative to class weighting. *(Dengeli batch sampling class weighting'e alternatif olarak değerlendirilebilir.)*

The two strategies will not be combined automatically without validation evidence. *(İki strateji doğrulama kanıtı olmadan otomatik olarak birleştirilmeyecektir.)*

---

# 87. No Test-Driven Class Balancing (Test Güdümlü Sınıf Dengeleme Olmaması)

Final test-class performance will not be used to retroactively modify training class weights for the same final evaluation. *(Nihai test sınıf performansı aynı nihai değerlendirme için eğitim class weight'lerini geriye dönük değiştirmek amacıyla kullanılmayacaktır.)*

---

# 88. Random Seed Management (Random Seed Yönetimi)

Important training runs will record random seeds used by Python, NumPy, and the relevant ML framework where practical. *(Önemli eğitim çalışmaları uygulanabilir olduğunda Python, NumPy ve ilgili ML framework tarafından kullanılan random seed'leri kaydedecektir.)*

Reproducibility will be pursued while acknowledging that some low-level operations may not be perfectly deterministic across environments. *(Bazı düşük seviyeli işlemlerin ortamlar arasında tamamen deterministik olmayabileceği kabul edilirken tekrarlanabilirlik hedeflenecektir.)*

---

# 89. Multiple Training Runs (Birden Fazla Eğitim Çalışması)

A promising neural architecture should be evaluated across more than one training seed before final selection when project time permits. *(Umut verici sinir ağı mimarisi proje süresi izin verdiğinde nihai seçimden önce birden fazla eğitim seed'i üzerinde değerlendirilmelidir.)*

This reduces the chance of selecting a model because of one unusually favorable initialization. *(Bu bir modelin tek olağan dışı avantajlı başlatma nedeniyle seçilmesi olasılığını azaltır.)*

---

# 90. Model Selection Hierarchy (Model Seçim Hiyerarşisi)

The final model will first need to satisfy basic correctness and leakage requirements. *(Nihai model önce temel doğruluk ve veri sızıntısı gereksinimlerini karşılamalıdır.)*

It will then be compared using held-out classification quality, runtime latency, model size, and navigation value. *(Daha sonra ayrılmış sınıflandırma kalitesi, çalışma zamanı gecikmesi, model boyutu ve navigasyon değeri kullanılarak karşılaştırılacaktır.)*

---

# 91. Primary Selection Metric (Temel Seçim Metriği)

Macro F1 will be the primary classification-quality metric. *(Macro F1 temel sınıflandırma kalite metriği olacaktır.)*

Accuracy will remain a secondary global metric. *(Accuracy ikincil global metrik olarak kalacaktır.)*

---

# 92. Per-Class Metrics (Sınıf Başına Metrikler)

For each of the four frozen trained classes, precision will be reported. *(Dört frozen trained class'ın her biri için precision raporlanacaktır.)*

Recall will be reported. *(Recall raporlanacaktır.)*

F1 will be reported. *(F1 raporlanacaktır.)*

Support will be reported. *(Support raporlanacaktır.)*

---

# 93. Confusion Matrix (Confusion Matrix)

The formal final test report must include a four-class confusion matrix covering the frozen trained classes `STATIONARY`, `WALKING`, `RUNNING`, and `TURNING`. *(Formal nihai test raporu frozen trained class'lar `STATIONARY`, `WALKING`, `RUNNING` ve `TURNING`'i kapsayan four-class confusion matrix içermelidir.)*

If valid evaluation evidence for `RUNNING` is insufficient, this acceptance criterion remains unmet or incomplete rather than permitting a three-class report. *(Valid `RUNNING` evaluation evidence yetersizse bu acceptance criterion three-class report'a izin vermek yerine karşılanmamış veya incomplete kalır.)*

Raw counts and normalized views may both be retained. *(Ham sayılar ve normalize edilmiş görünümler birlikte korunabilir.)*

---

# 94. STATIONARY Recall Importance (STATIONARY Recall Önemi)

High `STATIONARY` recall is important for detecting non-translation periods. *(Yüksek `STATIONARY` recall yer değiştirmesiz dönemleri tespit etmek için önemlidir.)*

However, maximizing stationary recall by falsely labeling walking as stationary would damage navigation. *(Ancak yürüyüşü yanlış şekilde sabit olarak etiketleyerek stationary recall değerini maksimize etmek navigasyona zarar verir.)*

Precision and confusion patterns must therefore be examined together. *(Bu nedenle precision ve confusion örüntüleri birlikte incelenmelidir.)*

---

# 95. WALKING Performance Importance (WALKING Performans Önemi)

`WALKING` is expected to be a common operational class. *(`WALKING` durumunun yaygın operasyonel sınıf olması beklenmektedir.)*

Its performance is important but must not dominate model selection merely because it has more samples. *(Performansı önemlidir ancak yalnızca daha fazla örneğe sahip olduğu için model seçimine baskın olmamalıdır.)*

---

# 96. RUNNING Performance Importance (RUNNING Performans Önemi)

`RUNNING` performance determines whether the system can safely activate any running-specific step or process model. *(`RUNNING` performansı sistemin koşmaya özgü herhangi bir adım veya süreç modelini güvenli şekilde etkinleştirip etkinleştiremeyeceğini belirler.)*

If running performance remains weak, the navigation effect of the class may be disabled even if the class remains diagnostically visible. *(Koşma performansı zayıf kalırsa sınıf tanısal olarak görünür kalsa bile navigasyon etkisi devre dışı bırakılabilir.)*

---

# 97. TURNING Performance Importance (TURNING Performans Önemi)

`TURNING` performance will be evaluated particularly on turn-heavy held-out sessions. *(`TURNING` performansı özellikle dönüş yoğun ayrılmış oturumlarda değerlendirilecektir.)*

A model that performs well only on stationary and straight walking may not be sufficient for NAVGUARD. *(Yalnızca sabit ve düz yürüyüşte iyi performans gösteren model NAVGUARD için yeterli olmayabilir.)*

---

# 98. Balanced Accuracy Candidate (Balanced Accuracy Adayı)

Balanced Accuracy may be reported as an additional diagnostic metric if class imbalance is substantial. *(Sınıf dengesizliği önemliyse Balanced Accuracy ek tanısal metrik olarak raporlanabilir.)*

Macro F1 will remain the primary target unless the project specification is formally changed. *(Proje spesifikasyonu resmî olarak değiştirilmedikçe Macro F1 temel hedef olarak kalacaktır.)*

---

# 99. Confidence Analysis (Güven Analizi)

For the neural classifier, the maximum output score may be logged as raw model confidence. *(Sinir ağı sınıflandırıcısı için maksimum çıktı skoru ham model güveni olarak kaydedilebilir.)*

```text
confidence =
max(p_class)
```

This value will not automatically be described as calibrated correctness probability. *(Bu değer otomatik olarak kalibre edilmiş doğruluk olasılığı olarak açıklanmayacaktır.)*

---

# 100. Confidence Distribution (Güven Dağılımı)

Confidence distributions will be compared between correct and incorrect predictions. *(Güven dağılımları doğru ve yanlış tahminler arasında karşılaştırılacaktır.)*

This will help determine whether confidence is useful for operational gating. *(Bu güvenin operasyonel gating için kullanışlı olup olmadığını belirlemeye yardımcı olacaktır.)*

---

# 101. Confidence Threshold Candidate (Güven Eşiği Adayı)

A minimum confidence threshold may be introduced before AI predictions are allowed to change navigation context. *(Yapay zekâ tahminlerinin navigasyon bağlamını değiştirmesine izin verilmeden önce minimum güven eşiği eklenebilir.)*

The threshold will be selected using validation data rather than the final test set. *(Eşik nihai test seti yerine doğrulama verisi kullanılarak seçilecektir.)*

---

# 102. UNKNOWN Operational Context Candidate (UNKNOWN Operasyonel Bağlam Adayı)

If no class prediction satisfies the operational confidence rule, the controller may temporarily use an `UNKNOWN` motion context. *(Hiçbir sınıf tahmini operasyonel güven kuralını karşılamazsa controller geçici olarak `UNKNOWN` hareket bağlamı kullanabilir.)*

`UNKNOWN` would be a controller state rather than a fifth trained class. *(`UNKNOWN`, beşinci eğitilmiş sınıf yerine controller durumu olacaktır.)*

---

# 103. Deterministic Fallback Under UNKNOWN (UNKNOWN Altında Deterministik Geri Dönüş)

When AI context is `UNKNOWN`, deterministic motion and step-detection logic will retain control. *(Yapay zekâ bağlamı `UNKNOWN` olduğunda deterministik hareket ve adım tespit mantığı kontrolü koruyacaktır.)*

---

# 104. Temporal Smoothing Requirement (Zamansal Smoothing Gereksinimi)

The final navigation-enabled classifier will not necessarily apply every window prediction immediately. *(Nihai navigasyon etkin sınıflandırıcı her pencere tahminini mutlaka anında uygulamayacaktır.)*

A causal smoothing layer may stabilize state transitions. *(Nedensel smoothing katmanı durum geçişlerini kararlı hale getirebilir.)*

---

# 105. Majority-Vote Candidate (Çoğunluk Oyu Adayı)

A short rolling majority vote over recent predictions may be evaluated. *(Son tahminler üzerinde kısa kayan çoğunluk oyu değerlendirilebilir.)*

The window count must remain small enough to avoid excessive transition delay. *(Pencere sayısı aşırı geçiş gecikmesini önlemek için yeterince küçük kalmalıdır.)*

---

# 106. Consecutive-Prediction Candidate (Ardışık Tahmin Adayı)

A transition may require the same new class to appear in several consecutive model predictions. *(Bir geçiş aynı yeni sınıfın birkaç ardışık model tahmininde görünmesini gerektirebilir.)*

This is a simple hysteresis strategy. *(Bu basit bir hysteresis stratejisidir.)*

---

# 107. Confidence-Weighted Smoothing Candidate (Güven Ağırlıklı Smoothing Adayı)

A short causal average of class scores may be evaluated. *(Sınıf skorlarının kısa nedensel ortalaması değerlendirilebilir.)*

The final strategy will be selected according to transition accuracy and latency. *(Nihai strateji geçiş doğruluğuna ve gecikmeye göre seçilecektir.)*

---

# 108. Transition Latency Metric (Geçiş Gecikmesi Metriği)

The delay between known activity transition and accepted operational motion-context transition will be measured. *(Bilinen aktivite geçişi ile kabul edilen operasyonel hareket bağlamı geçişi arasındaki gecikme ölçülecektir.)*

A classifier that is accurate but several seconds late may be unsuitable for navigation control. *(Doğru ancak birkaç saniye geç kalan sınıflandırıcı navigasyon kontrolü için uygun olmayabilir.)*

---

# 109. Transition Error Metric (Geçiş Hata Metriği)

False rapid transitions between classes will also be counted. *(Sınıflar arasındaki yanlış hızlı geçişler de sayılacaktır.)*

This is particularly important for walk-stop-walk behavior. *(Bu özellikle yürü-dur-yürü davranışı için önemlidir.)*

---

# 110. Live Shadow Mode First (Önce Canlı Gölge Modu)

The first Android integration of the final candidate model will operate in shadow mode. *(Nihai aday modelin ilk Android entegrasyonu gölge modunda çalışacaktır.)*

Predictions will be logged while deterministic navigation remains authoritative. *(Deterministik navigasyon ana kontrolü korurken tahminler kaydedilecektir.)*

---

# 111. Shadow Mode Objectives (Gölge Modu Hedefleri)

Shadow mode will verify mobile inference stability. *(Gölge modu mobil çıkarım kararlılığını doğrulayacaktır.)*

It will verify preprocessing parity. *(Ön işleme eşdeğerliğini doğrulayacaktır.)*

It will verify real-time transition behavior. *(Gerçek zamanlı geçiş davranışını doğrulayacaktır.)*

It will verify inference latency. *(Çıkarım gecikmesini doğrulayacaktır.)*

---

# 112. Navigation Enablement Gate (Navigasyon Etkinleştirme Kapısı)

The model may affect navigation only after passing offline held-out evaluation and Android shadow-mode validation. *(Model yalnızca çevrimdışı ayrılmış değerlendirmeyi ve Android gölge modu doğrulamasını geçtikten sonra navigasyonu etkileyebilir.)*

---

# 113. Navigation Effect Mapping (Navigasyon Etki Eşlemesi)

```text
STATIONARY
→ suppress false propagation
→ stationary process profile

WALKING
→ normal PDR profile
→ walking step-length profile

RUNNING
→ running-capable PDR profile if validated

TURNING
→ turning-aware heading / process profile
```

Every enabled effect must have its own test. *(Etkinleştirilen her etki kendi testine sahip olmalıdır.)*

---

# 114. AI Does Not Directly Accept or Reject Steps Alone (Yapay Zekâ Tek Başına Adımları Doğrudan Kabul veya Reddetmez)

The deterministic step detector remains the authoritative source of step events. *(Deterministik adım algılayıcı adım olaylarının ana kaynağı olarak kalır.)*

Motion AI may provide context that modifies thresholds or validation behavior only if the corresponding integration is experimentally validated. *(Hareket yapay zekâsı yalnızca ilgili entegrasyon deneysel olarak doğrulanırsa eşikleri veya doğrulama davranışını değiştiren bağlam sağlayabilir.)*

---

# 115. STATIONARY Suppression Safety (STATIONARY Bastırma Güvenliği)

A single `STATIONARY` prediction must not delete an already valid historical step. *(Tek bir `STATIONARY` tahmini zaten geçerli olan geçmiş bir adımı silmemelidir.)*

Motion context affects current or future processing according to timestamp alignment. *(Hareket bağlamı zaman damgası hizalamasına göre mevcut veya gelecekteki işlemeyi etkiler.)*

---

# 116. RUNNING Activation Safety (RUNNING Aktivasyon Güvenliği)

Running-specific navigation parameters will not be enabled until `RUNNING` classification has sufficient held-out performance. *(Koşmaya özgü navigasyon parametreleri `RUNNING` sınıflandırması yeterli ayrılmış performansa ulaşana kadar etkinleştirilmeyecektir.)*

---

# 117. TURNING Context and Heading (TURNING Bağlamı ve Yön)

The `TURNING` context may justify different heading-confidence or process-noise treatment because rapid orientation change is expected. *(`TURNING` bağlamı hızlı yönelim değişimi beklendiği için farklı yön güveni veya süreç gürültüsü yönetimini gerekçelendirebilir.)*

This effect will be implemented only through documented configuration rather than hidden model-specific logic. *(Bu etki gizli modele özgü mantık yerine yalnızca dokümante edilmiş yapılandırma üzerinden geliştirilecektir.)*

---

# 118. Motion AI and Quality Engine (Hareket Yapay Zekâsı ve Kalite Motoru)

The model will expose prediction confidence and freshness to the Sensor Confidence & Quality Engine. *(Model tahmin güvenini ve güncelliğini Sensör Güven ve Kalite Motoruna sunacaktır.)*

The quality engine may mark motion context as degraded if predictions become stale or unstable. *(Tahminler eski veya kararsız hale gelirse kalite motoru hareket bağlamını bozulmuş olarak işaretleyebilir.)*

---

# 119. Motion Context Quality (Hareket Bağlamı Kalitesi)

A navigation context may have a quality state separate from its class label. *(Bir navigasyon bağlamı sınıf etiketinden ayrı bir kalite durumuna sahip olabilir.)*

```text
class = WALKING
quality = GOOD
```

or *(veya)*

```text
class = WALKING
quality = DEGRADED
```

This prevents class identity from being confused with prediction trust. *(Bu sınıf kimliğinin tahmin güveniyle karıştırılmasını önler.)*

---

# 120. Prediction Freshness (Tahmin Güncelliği)

An AI prediction must remain associated with its window end timestamp. *(Bir yapay zekâ tahmini pencere sonu zaman damgasıyla ilişkili kalmalıdır.)*

A stale prediction will not remain active indefinitely. *(Eski bir tahmin süresiz aktif kalmayacaktır.)*

---

# 121. AI Inference Pipeline (Yapay Zekâ Çıkarım Hattı)

```text
Native Sensor Stream
       ↓
Synchronized Buffer
       ↓
Causal Window Builder
       ↓
Preprocessing
       ↓
Tensor Builder
       ↓
LiteRT Model
       ↓
Raw Prediction
       ↓
Output Validation
       ↓
Temporal Smoothing
       ↓
Motion Context
       ↓
Quality Engine / Navigation Controller
```

---

# 122. Tensor Builder Ownership (Tensor Builder Sahipliği)

The Android AI subsystem will own construction of the exact inference tensor expected by the deployed model. *(Android yapay zekâ alt sistemi deployment edilen modelin beklediği kesin çıkarım tensor'unu oluşturmanın sahibi olacaktır.)*

This logic will be tested against the Python reference implementation. *(Bu mantık Python referans uygulamasına karşı test edilecektir.)*

---

# 123. Model Metadata Bundle (Model Metadata Paketi)

The deployment artifact will be accompanied by metadata describing its exact input and output contract. *(Deployment artifact'ına kesin girdi ve çıktı sözleşmesini açıklayan metadata eşlik edecektir.)*

```text
model_id
model_version
input_shape
channel_order
sample_rate
window_duration
normalization_mean
normalization_std
class_order
preprocessing_version
```

---

# 124. Model Hash Verification (Model Hash Doğrulaması)

The application or benchmark evidence will preserve the hash of the loaded `.tflite` artifact. *(Uygulama veya benchmark kanıtı yüklenen `.tflite` artifact'ının hash değerini koruyacaktır.)*

This prevents ambiguity when multiple candidate files exist. *(Bu birden fazla aday dosya mevcut olduğunda belirsizliği önler.)*

---

# 125. Python-to-Android Golden Dataset (Python-Android Golden Veri Seti)

A small set of fixed sensor windows will be retained as golden parity examples. *(Küçük bir sabit sensör pencere seti golden eşdeğerlik örnekleri olarak korunacaktır.)*

Each example will contain raw input, expected preprocessed tensor, and expected model output. *(Her örnek ham girdiyi, beklenen ön işlenmiş tensor'u ve beklenen model çıktısını içerecektir.)*

---

# 126. Golden Input Test (Golden Girdi Testi)

Android preprocessing of a golden raw window must match the stored Python tensor within numerical tolerance. *(Golden ham pencerenin Android ön işlemesi sayısal tolerans içerisinde saklanan Python tensor'uyla eşleşmelidir.)*

---

# 127. Golden Output Test (Golden Çıktı Testi)

For the same deployment model and equivalent input tensor, Android and Python outputs must match within an accepted numerical tolerance. *(Aynı deployment modeli ve eşdeğer girdi tensor'u için Android ve Python çıktıları kabul edilmiş sayısal tolerans içerisinde eşleşmelidir.)*

---

# 128. Quantization Parity (Quantization Eşdeğerliği)

If quantization is later enabled, parity thresholds may differ from the floating-point model. *(Daha sonra quantization etkinleştirilirse eşdeğerlik toleransları floating-point modelden farklı olabilir.)*

The quantized model will receive its own parity evidence. *(Quantize edilmiş model kendi eşdeğerlik kanıtını alacaktır.)*

---

# 129. CPU Baseline (CPU Temeli)

The first final-candidate on-device benchmark will use the standard CPU execution path. *(İlk nihai aday cihaz üzeri benchmark standart CPU çalıştırma yolunu kullanacaktır.)*

This baseline will establish inference latency before optional delegates are evaluated. *(Bu temel isteğe bağlı delegate'ler değerlendirilmeden önce çıkarım gecikmesini belirleyecektir.)*

---

# 130. Latency Metric (Gecikme Metriği)

Per-inference model runtime will be measured. *(Çıkarım başına model çalışma süresi ölçülecektir.)*

```text
latency_model =
t_output_ready -
t_inference_start
```

---

# 131. End-to-End Motion Latency (Uçtan Uca Hareket Gecikmesi)

The system will additionally consider total delay from window completion to accepted navigation context. *(Sistem ayrıca pencere tamamlanmasından kabul edilmiş navigasyon bağlamına kadar toplam gecikmeyi değerlendirecektir.)*

```text
latency_e2e =
t_context_accepted -
t_window_end
```

---

# 132. Provisional Runtime Target (Geçici Çalışma Zamanı Hedefi)

The model inference target remains below `50 ms` per inference on the Redmi Note 9 Pro. *(Model çıkarım hedefi Redmi Note 9 Pro üzerinde çıkarım başına `50 ms` altı olarak kalmaktadır.)*

End-to-end context latency will be reported separately because windowing and smoothing may dominate model runtime. *(Pencereleme ve smoothing model çalışma süresine baskın olabileceği için uçtan uca bağlam gecikmesi ayrı raporlanacaktır.)*

---

# 133. Latency Distribution (Gecikme Dağılımı)

Mean inference latency alone is insufficient. *(Yalnızca ortalama çıkarım gecikmesi yeterli değildir.)*

Median and upper-percentile latency may also be reported. *(Medyan ve üst yüzdelik gecikme de raporlanabilir.)*

---

# 134. Warm-Up Inference (Warm-Up Çıkarımı)

Initial model warm-up behavior will be distinguished from steady-state inference. *(İlk model warm-up davranışı steady-state çıkarımdan ayrılacaktır.)*

The model may perform one or more non-benchmark warm-up inferences before formal sustained latency measurement. *(Model resmî sürekli gecikme ölçümünden önce bir veya daha fazla benchmark dışı warm-up çıkarımı gerçekleştirebilir.)*

---

# 135. Sustained Inference Test (Sürekli Çıkarım Testi)

The classifier must remain stable during a representative continuous navigation session. *(Sınıflandırıcı temsili sürekli navigasyon oturumu boyunca kararlı kalmalıdır.)*

The test will detect queue growth, memory leaks, runtime exceptions, and thermal degradation. *(Test kuyruk büyümesini, bellek sızıntılarını, çalışma zamanı exception'larını ve termal bozulmayı tespit edecektir.)*

---

# 136. Model Size (Model Boyutu)

The final `.tflite` model file size will be recorded. *(Nihai `.tflite` model dosya boyutu kaydedilecektir.)*

Model size will be considered alongside classification quality and latency. *(Model boyutu sınıflandırma kalitesi ve gecikmeyle birlikte değerlendirilecektir.)*

---

# 137. Parameter Count (Parametre Sayısı)

The 1D-CNN parameter count will be recorded for candidate comparison. *(1D-CNN parametre sayısı aday karşılaştırması için kaydedilecektir.)*

A large increase in parameter count requires measurable benefit. *(Parametre sayısındaki büyük artış ölçülebilir fayda gerektirir.)*

---

# 138. Quantization Candidate (Quantization Adayı)

Post-training quantization may be evaluated after a stable floating-point model exists. *(Kararlı floating-point model mevcut olduktan sonra post-training quantization değerlendirilebilir.)*

The floating-point model remains the reference baseline. *(Floating-point model referans temel olarak kalır.)*

---

# 139. Quantization Acceptance (Quantization Kabulü)

A quantized model will be retained only if the reduction in model cost does not cause unacceptable held-out or mobile prediction degradation. *(Quantize edilmiş model yalnızca model maliyetindeki azalma kabul edilemez ayrılmış veya mobil tahmin bozulmasına neden olmazsa korunacaktır.)*

---

# 140. Model Comparison Table Structure (Model Karşılaştırma Tablosu Yapısı)

The final analysis will compare candidate models using the following dimensions. *(Nihai analiz aday modelleri aşağıdaki boyutlar kullanılarak karşılaştıracaktır.)*

```text
Model
Macro F1
Accuracy
Stationary F1
Walking F1
Running F1
Turning F1
Model Size
Median Mobile Latency
P95 Mobile Latency
Navigation Effect
```

---

# 141. Model Selection Priority (Model Seçim Önceliği)

A tiny latency improvement will not justify a major reduction in classification reliability. *(Küçük bir gecikme iyileştirmesi sınıflandırma güvenilirliğinde büyük azalmayı gerekçelendirmeyecektir.)*

Similarly, a negligible Macro F1 gain will not justify a dramatically larger mobile model without navigation benefit. *(Benzer şekilde ihmal edilebilir Macro F1 artışı navigasyon faydası olmadan çok daha büyük mobil modeli gerekçelendirmeyecektir.)*

---

# 142. Model Selection Must Be Frozen Before Final Test Interpretation (Model Seçimi Nihai Test Yorumundan Önce Sabitlenmelidir)

Architecture and hyperparameter decisions will be based on training and validation evidence. *(Mimari ve hiperparametre kararları eğitim ve doğrulama kanıtına dayanacaktır.)*

The held-out test set will confirm final generalization rather than drive repeated tuning. *(Ayrılmış test seti tekrarlanan ayarı yönlendirmek yerine nihai genellemeyi doğrulayacaktır.)*

---

# 143. Held-Out Test Procedure (Ayrılmış Test Prosedürü)

The selected final candidate will be evaluated once under the frozen preprocessing, class mapping, and decision policy for the formal test report. *(Seçilen nihai aday resmî test raporu için sabitlenmiş ön işleme, sınıf eşleme ve karar politikası altında değerlendirilecektir.)*

If major changes follow, the resulting model will be considered a new model version. *(Ardından büyük değişiklikler yapılırsa ortaya çıkan model yeni model sürümü olarak kabul edilecektir.)*

---

# 144. Test Prediction Preservation (Test Tahminlerinin Korunması)

Every held-out test prediction will be stored with its true class, predicted class, confidence, session ID, and window ID. *(Her ayrılmış test tahmini gerçek sınıfı, tahmin edilen sınıfı, güveni, oturum ID'si ve pencere ID'si ile saklanacaktır.)*

This permits independent metric recalculation. *(Bu bağımsız metrik yeniden hesaplamasına izin verir.)*

---

# 145. Session-Level Metrics (Oturum Seviyesi Metrikler)

In addition to pooled window metrics, NAVGUARD may report Macro F1 or accuracy per independent test session. *(Birleştirilmiş pencere metriklerine ek olarak NAVGUARD bağımsız test oturumu başına Macro F1 veya accuracy raporlayabilir.)*

This reveals whether one session performs much worse than the aggregate result suggests. *(Bu bir oturumun aggregate sonucun ima ettiğinden çok daha kötü performans gösterip göstermediğini ortaya çıkarır.)*

---

# 146. Environment-Level Metrics (Ortam Seviyesi Metrikler)

Where sufficient sessions exist, performance may be summarized by indoor and outdoor context. *(Yeterli oturum mevcut olduğunda performans iç mekân ve dış mekân bağlamına göre özetlenebilir.)*

Such analysis is secondary to the main held-out result. *(Böyle analiz temel ayrılmış sonuca göre ikincildir.)*

---

# 147. False Transition Analysis (Yanlış Geçiş Analizi)

The system will analyze short isolated class predictions that disagree with surrounding windows. *(Sistem çevredeki pencerelerle uyuşmayan kısa izole sınıf tahminlerini analiz edecektir.)*

These errors directly inform the temporal smoothing design. *(Bu hatalar zamansal smoothing tasarımını doğrudan yönlendirir.)*

---

# 148. Error Review Is Diagnostic, Not Test Tuning (Hata İncelemesi Tanısaldır, Test Ayarı Değildir)

Held-out test errors may be analyzed to understand limitations. *(Ayrılmış test hataları sınırlamaları anlamak için analiz edilebilir.)*

The same test set must not then be repeatedly used as validation data for model redesign while still being reported as untouched final evidence. *(Aynı test seti hâlâ dokunulmamış nihai kanıt olarak raporlanırken model yeniden tasarımı için tekrar tekrar validation verisi olarak kullanılmamalıdır.)*

---

# 149. Motion Model Deployment Artifact (Hareket Modeli Deployment Artifact'ı)

The selected neural model will be converted into a `.tflite` deployment artifact for the Android runtime. *(Seçilen sinir ağı modeli Android çalışma zamanı için `.tflite` deployment artifact'ına dönüştürülecektir.)*

The exact conversion configuration will be stored with the model version. *(Kesin conversion yapılandırması model sürümüyle birlikte saklanacaktır.)*

---

# 150. Conversion Validation (Conversion Doğrulaması)

Predictions from the exported deployment model will be compared with the original training-model predictions on fixed validation windows. *(Export edilen deployment modelinin tahminleri sabit doğrulama pencerelerinde orijinal eğitim modeli tahminleriyle karşılaştırılacaktır.)*

Material conversion-induced degradation will block deployment. *(Conversion kaynaklı anlamlı bozulma deployment'ı engelleyecektir.)*

---

# 151. LiteRT Model Input Contract (LiteRT Model Girdi Sözleşmesi)

The deployed model will use a fixed tensor shape. *(Deployment edilen model sabit tensor şekli kullanacaktır.)*

The exact shape will depend on the frozen window duration, model-grid frequency, and channel set. *(Kesin şekil sabitlenmiş pencere süresine, model-grid frekansına ve kanal setine bağlı olacaktır.)*

---

# 152. Example Final Tensor Candidate (Örnek Nihai Tensor Adayı)

If the selected design uses `1.5 s`, `50 Hz`, and six raw channels, the candidate model input would contain `75 × 6` temporal values. *(Seçilen tasarım `1.5 s`, `50 Hz` ve altı ham kanal kullanırsa aday model girdisi `75 × 6` zamansal değer içerecektir.)*

This is an example candidate and is not yet frozen. *(Bu örnek adaydır ve henüz sabitlenmemiştir.)*

---

# 153. Android Model Load Test (Android Model Yükleme Testi)

The Redmi Note 9 Pro must load the final `.tflite` artifact successfully. *(Redmi Note 9 Pro nihai `.tflite` artifact'ını başarıyla yüklemelidir.)*

Input and output tensor metadata must match the model registry. *(Girdi ve çıktı tensor metadata bilgisi model registry ile eşleşmelidir.)*

---

# 154. Android Continuous Inference Test (Android Sürekli Çıkarım Testi)

The model must execute repeatedly over live sensor windows without interpreter recreation per window. *(Model pencere başına interpreter yeniden oluşturmadan canlı sensör pencereleri üzerinde tekrar tekrar çalışmalıdır.)*

---

# 155. Android Error Fallback Test (Android Hata Geri Dönüş Testi)

A simulated model-loading failure must cause the motion AI subsystem to become unavailable while baseline navigation continues. *(Simüle edilmiş model yükleme hatası temel navigasyon devam ederken hareket yapay zekâ alt sisteminin kullanılamaz hale gelmesine neden olmalıdır.)*

---

# 156. Android Shape-Mismatch Test (Android Şekil Uyuşmazlığı Testi)

An intentionally incorrect tensor configuration must be rejected before invalid inference affects navigation. *(Bilinçli olarak yanlış tensor yapılandırması geçersiz çıkarım navigasyonu etkilemeden önce reddedilmelidir.)*

---

# 157. Android Class-Order Test (Android Sınıf Sırası Testi)

A fixed output vector must map to the same class label in Python and Android. *(Sabit çıktı vektörü Python ve Android'de aynı sınıf etiketine eşlenmelidir.)*

---

# 158. Android Timestamp Test (Android Zaman Damgası Testi)

A prediction must retain the timestamp of the window it describes rather than only the time at which the UI receives the result. *(Bir tahmin yalnızca UI'ın sonucu aldığı zamanı değil açıkladığı pencerenin zaman damgasını korumalıdır.)*

---

# 159. Android Stale-Result Test (Android Eski Sonuç Testi)

A delayed old prediction must not overwrite a newer accepted motion context. *(Gecikmiş eski tahmin daha yeni kabul edilmiş hareket bağlamının üzerine yazmamalıdır.)*

---

# 160. Navigation Shadow Comparison (Navigasyon Gölge Karşılaştırması)

During shadow mode, deterministic navigation and AI-predicted motion context will be recorded simultaneously. *(Gölge modu sırasında deterministik navigasyon ve yapay zekâ tarafından tahmin edilen hareket bağlamı aynı anda kaydedilecektir.)*

This enables post-session analysis without risk to the active estimator. *(Bu aktif tahmin motoruna risk oluşturmadan oturum sonrası analize izin verir.)*

---

# 161. Navigation Enablement Test (Navigasyon Etkinleştirme Testi)

After AI is enabled, logs must show exactly when a model prediction changes the active motion context. *(Yapay zekâ etkinleştirildikten sonra kayıtlar bir model tahmininin aktif hareket bağlamını tam olarak ne zaman değiştirdiğini göstermelidir.)*

---

# 162. STATIONARY Navigation Test (STATIONARY Navigasyon Testi)

A walk-stop-walk session will evaluate whether `STATIONARY` recognition reduces false step-based displacement during the stop interval. *(Yürü-dur-yürü oturumu `STATIONARY` tanımanın durma aralığı sırasında yanlış adım tabanlı yer değiştirmeyi azaltıp azaltmadığını değerlendirecektir.)*

---

# 163. WALKING Navigation Test (WALKING Navigasyon Testi)

Normal walking must not be excessively suppressed by conservative stationary logic. *(Normal yürüyüş temkinli stationary mantığı tarafından aşırı bastırılmamalıdır.)*

---

# 164. RUNNING Navigation Test (RUNNING Navigasyon Testi)

If running-specific PDR behavior is enabled, it will be compared against the normal walking profile on controlled running sessions. *(Koşmaya özgü PDR davranışı etkinleştirilirse kontrollü koşu oturumlarında normal yürüyüş profiliyle karşılaştırılacaktır.)*

---

# 165. TURNING Navigation Test (TURNING Navigasyon Testi)

Turn-heavy walking will verify that `TURNING` detection improves context without suppressing legitimate step propagation. *(Dönüş yoğun yürüyüş `TURNING` tespitinin geçerli adım ilerletmesini bastırmadan bağlamı iyileştirdiğini doğrulayacaktır.)*

---

# 166. Navigation-Level Ablation (Navigasyon Seviyesi Ablation)

The same recorded session may be replayed with AI navigation effects disabled and enabled. *(Aynı kaydedilmiş oturum yapay zekâ navigasyon etkileri kapalı ve açık olarak replay edilebilir.)*

The deterministic sensor data, accepted steps, and evaluation reference will remain identical. *(Deterministik sensör verisi, kabul edilmiş adımlar ve değerlendirme referansı aynı kalacaktır.)*

---

# 167. Motion AI Benefit Metrics (Hareket Yapay Zekâ Fayda Metrikleri)

Candidate system-level metrics include false step propagation during stationary periods. *(Aday sistem seviyesi metrikler sabit dönemler sırasında yanlış adım ilerletmeyi içerir.)*

Candidate metrics include total step-count error. *(Aday metrikler toplam adım sayısı hatasını içerir.)*

Candidate metrics include final position error. *(Aday metrikler nihai konum hatasını içerir.)*

Candidate metrics include median denied-navigation position error. *(Aday metrikler medyan kesintili navigasyon konum hatasını içerir.)*

---

# 168. Model Success Is Two-Level (Model Başarısı İki Seviyelidir)

The classifier must first demonstrate acceptable machine-learning performance. *(Sınıflandırıcı önce kabul edilebilir makine öğrenmesi performansı göstermelidir.)*

It should then demonstrate useful navigation behavior when enabled. *(Daha sonra etkinleştirildiğinde kullanışlı navigasyon davranışı göstermelidir.)*

---

# 169. Model-Level Success Gate (Model Seviyesi Başarı Kapısı)

The provisional primary gate is held-out Macro F1 `≥ 0.90`. *(Geçici temel kapı ayrılmış Macro F1 `≥ 0.90` değeridir.)*

Per-class results must still be inspected even when the global gate is passed. *(Global kapı geçilse bile sınıf başına sonuçlar yine de incelenmelidir.)*

---

# 170. Critical-Class Failure (Kritik Sınıf Hatası)

A model may fail operational deployment despite Macro F1 above the target if one navigation-critical class has unacceptable behavior. *(Bir model bir navigasyon açısından kritik sınıf kabul edilemez davranışa sahipse hedefin üzerinde Macro F1 değerine rağmen operasyonel deployment'da başarısız olabilir.)*

This decision must be documented rather than hidden behind the aggregate score. *(Bu karar aggregate skorun arkasına gizlenmek yerine dokümante edilmelidir.)*

---

# 171. Model Comparison Against Random Forest (Random Forest'a Karşı Model Karşılaştırması)

The 1D-CNN must be compared against the Random Forest baseline using the same session splits. *(1D-CNN aynı oturum ayrımlarını kullanarak Random Forest temeliyle karşılaştırılmalıdır.)*

If Random Forest provides comparable classification quality with substantially simpler deployment, it remains a valid candidate. *(Random Forest anlamlı şekilde daha basit deployment ile karşılaştırılabilir sınıflandırma kalitesi sağlarsa geçerli aday olarak kalır.)*

---

# 172. Classical Model Android Deployment Consideration (Klasik Model Android Deployment Değerlendirmesi)

Classical models are not automatically preferred for deployment merely because training is simpler. *(Klasik modeller yalnızca eğitim daha basit olduğu için deployment için otomatik olarak tercih edilmez.)*

Deployment complexity, conversion path, inference consistency, and runtime cost must also be considered. *(Deployment karmaşıklığı, conversion yolu, çıkarım tutarlılığı ve çalışma zamanı maliyeti de değerlendirilmelidir.)*

---

# 173. Final Motion Model May Still Be Classical (Nihai Hareket Modeli Yine de Klasik Olabilir)

The project does not require the final navigation-enabled classifier to be neural if a classical model performs better overall. *(Proje klasik model genel olarak daha iyi performans gösterirse nihai navigasyon etkin sınıflandırıcının sinir ağı olmasını gerektirmez.)*

The project requires evidence-based AI selection. *(Proje kanıta dayalı yapay zekâ seçimi gerektirir.)*

---

# 174. Research Integrity for Architecture Selection (Mimari Seçiminde Araştırma Bütünlüğü)

The final report will state which model won and why. *(Nihai rapor hangi modelin kazandığını ve nedenini belirtecektir.)*

A 1D-CNN will not be declared superior before experiments are completed. *(Deneyler tamamlanmadan 1D-CNN üstün ilan edilmeyecektir.)*

---

# 175. Model Artifact Directory Candidate (Model Artifact Klasör Adayı)

```text
models/
└── motion/
    ├── registry.json
    ├── motion_model_v001.tflite
    ├── motion_model_v001_metadata.json
    └── parity/
```

The final project layout may change without altering the architectural requirements. *(Nihai proje dizilimi mimari gereksinimleri değiştirmeden değişebilir.)*

---

# 176. Training Artifact Directory Candidate (Eğitim Artifact Klasör Adayı)

```text
ml/
└── motion_classification/
    ├── configs/
    ├── datasets/
    ├── training/
    ├── evaluation/
    ├── exports/
    └── parity/
```

---

# 177. Model Registry Status (Model Registry Durumu)

Each trained candidate will have a lifecycle status. *(Her eğitilmiş aday yaşam döngüsü durumuna sahip olacaktır.)*

```text
EXPERIMENTAL
VALIDATION_CANDIDATE
OFFLINE_VALIDATED
SHADOW_VALIDATED
NAVIGATION_ENABLED
RETIRED
```

---

# 178. Promotion Rule (Promotion Kuralı)

A model may move from `EXPERIMENTAL` to `VALIDATION_CANDIDATE` after basic training sanity checks. *(Bir model temel eğitim sanity kontrollerinden sonra `EXPERIMENTAL` durumundan `VALIDATION_CANDIDATE` durumuna geçebilir.)*

It may move to `OFFLINE_VALIDATED` after frozen validation requirements are satisfied. *(Sabitlenmiş doğrulama gereksinimleri karşılandıktan sonra `OFFLINE_VALIDATED` durumuna geçebilir.)*

It may become `NAVIGATION_ENABLED` only after Android validation. *(Yalnızca Android doğrulamasından sonra `NAVIGATION_ENABLED` olabilir.)*

---

# 179. Retired Models Remain Traceable (Emekli Modeller İzlenebilir Kalır)

A retired model file may remain archived if it produced historical experiment results. *(Emekli model dosyası geçmiş deney sonuçları ürettiyse arşivde kalabilir.)*

Historical benchmark references must not break when a new model is introduced. *(Yeni model eklendiğinde geçmiş benchmark referansları bozulmamalıdır.)*

---

# 180. Reproducibility Package (Tekrarlanabilirlik Paketi)

The final motion model should be reproducible from a package containing dataset manifest, split manifest, preprocessing configuration, model configuration, training configuration, and evaluation evidence. *(Nihai hareket modeli veri seti manifest'i, ayrım manifest'i, ön işleme yapılandırması, model yapılandırması, eğitim yapılandırması ve değerlendirme kanıtını içeren paket üzerinden yeniden üretilebilir olmalıdır.)*

---

# 181. Split Manifest (Ayrım Manifest'i)

```text
session_id,split

S001,train
S002,train
S003,validation
S004,test
...
```

The same dataset version will preserve this mapping. *(Aynı veri seti sürümü bu eşlemeyi koruyacaktır.)*

---

# 182. No Silent Split Regeneration (Sessiz Ayrım Yeniden Üretimi Olmaması)

Final experiment splits will not be randomly regenerated every time the training script runs. *(Nihai deney ayrımları eğitim script'i her çalıştığında rastgele yeniden oluşturulmayacaktır.)*

The split manifest will be stored explicitly. *(Ayrım manifest'i açıkça saklanacaktır.)*

---

# 183. Dataset Leakage Audit (Veri Seti Sızıntı Denetimi)

An automated audit will verify that no `session_id` exists in more than one split. *(Otomatik denetim hiçbir `session_id` değerinin birden fazla ayrımda bulunmadığını doğrulayacaktır.)*

The audit will also verify that every model-ready window belongs to exactly one declared parent session. *(Denetim ayrıca modele hazır her pencerenin tam olarak bir tanımlanmış ana oturuma ait olduğunu doğrulayacaktır.)*

---

# 184. Duplicate Window Audit (Yinelenen Pencere Denetimi)

Exact duplicate model windows should be detected where practical. *(Tam yinelenen model pencereleri uygulanabilir olduğunda tespit edilmelidir.)*

Duplicates across dataset splits are forbidden. *(Veri seti ayrımları arasında duplicate pencereler yasaktır.)*

---

# 185. Normalization Leakage Audit (Normalizasyon Sızıntı Denetimi)

An automated check will verify that normalization statistics were calculated only from training-session windows. *(Otomatik kontrol normalizasyon istatistiklerinin yalnızca eğitim oturumu pencerelerinden hesaplandığını doğrulayacaktır.)*

---

# 186. Test Isolation Audit (Test İzolasyon Denetimi)

The training pipeline must not import test metrics into hyperparameter-selection logic. *(Eğitim hattı test metriklerini hiperparametre seçim mantığına dahil etmemelidir.)*

---

# 187. Motion Model Test IDs (Hareket Modeli Test ID'leri)

```text
MC-DATA-001   Session split integrity
MC-DATA-002   Window-parent integrity
MC-DATA-003   Label validity
MC-DATA-004   Normalization leakage

MC-PRE-001    Resampling correctness
MC-PRE-002    Window shape
MC-PRE-003    Channel order
MC-PRE-004    Unit consistency

MC-ML-001     Logistic Regression baseline
MC-ML-002     Random Forest baseline
MC-ML-003     1D-CNN candidate
MC-ML-004     Class imbalance evaluation
MC-ML-005     Confusion analysis

MC-EXP-001    Held-out Macro F1
MC-EXP-002    Per-class metrics
MC-EXP-003    Transition latency
MC-EXP-004    Model size and latency

MC-MOB-001    TFLite load
MC-MOB-002    Python/Android tensor parity
MC-MOB-003    Python/Android output parity
MC-MOB-004    Sustained inference
MC-MOB-005    Fallback behavior

MC-NAV-001    Stationary suppression
MC-NAV-002    Walking continuity
MC-NAV-003    Running context
MC-NAV-004    Turning context
MC-NAV-005    AI-disabled vs AI-enabled replay
```

---

# 188. Dataset Acceptance Criteria (Veri Seti Kabul Kriterleri)

Each of the four frozen trained classes must contain valid labeled data from multiple independent sessions. *(Dört frozen trained class'ın her biri birden fazla independent session'dan valid labeled data içermelidir.)*

No session may exist in multiple train-validation-test splits. *(Hiçbir oturum birden fazla train-validation-test ayrımında bulunamaz.)*

All model windows must remain traceable to parent sessions. *(Tüm model pencereleri ana oturumlara izlenebilir kalmalıdır.)*

---

# 189. Preprocessing Acceptance Criteria (Ön İşleme Kabul Kriterleri)

The final preprocessing pipeline must be causal. *(Nihai ön işleme hattı nedensel olmalıdır.)*

It must have a version identifier. *(Bir sürüm tanımlayıcısına sahip olmalıdır.)*

It must produce fixed-shape model input. *(Sabit şekilli model girdisi üretmelidir.)*

It must be reproducible in Python and Android. *(Python ve Android'de yeniden üretilebilir olmalıdır.)*

---

# 190. Baseline Acceptance Criteria (Temel Model Kabul Kriterleri)

At least one classical baseline must be trained and evaluated. *(En az bir klasik temel model eğitilmeli ve değerlendirilmelidir.)*

Random Forest is the preferred required comparison candidate unless implementation evidence later provides a stronger alternative. *(Uygulama kanıtı daha sonra daha güçlü alternatif sağlamadığı sürece Random Forest tercih edilen gerekli karşılaştırma adayıdır.)*

---

# 191. 1D-CNN Acceptance Criteria (1D-CNN Kabul Kriterleri)

At least one lightweight 1D-CNN candidate must be trained and evaluated under the same dataset split used by the primary classical baseline. *(En az bir hafif 1D-CNN adayı temel klasik model tarafından kullanılan aynı veri seti ayrımı altında eğitilmeli ve değerlendirilmelidir.)*

---

# 192. Final Model Acceptance Criteria (Nihai Model Kabul Kriterleri)

The final model must have complete held-out classification metrics. *(Nihai model tam ayrılmış sınıflandırma metriklerine sahip olmalıdır.)*

It must have a stored confusion matrix. *(Saklanmış confusion matrix'e sahip olmalıdır.)*

It must have a model registry entry. *(Model registry girdisine sahip olmalıdır.)*

It must have a stored model hash. *(Saklanmış model hash'ine sahip olmalıdır.)*

---

# 193. Primary Metric Acceptance Criterion (Temel Metrik Kabul Kriteri)

The provisional formal target is held-out Macro F1 `≥ 0.90`. *(Geçici resmî hedef ayrılmış Macro F1 `≥ 0.90` değeridir.)*

If this threshold is not reached, the actual result will be reported without manipulating the test protocol. *(Bu eşiğe ulaşılamazsa gerçek sonuç test protokolü manipüle edilmeden raporlanacaktır.)*

---

# 194. Per-Class Acceptance Review (Sınıf Başına Kabul İncelemesi)

No navigation-critical class may be ignored solely because aggregate Macro F1 is high. *(Hiçbir navigasyon açısından kritik sınıf yalnızca aggregate Macro F1 yüksek olduğu için göz ardı edilemez.)*

The final navigation effect of each class may be limited according to its validated reliability. *(Her sınıfın nihai navigasyon etkisi doğrulanmış güvenilirliğine göre sınırlandırılabilir.)*

---

# 195. Mobile Acceptance Criteria (Mobil Kabul Kriterleri)

The final deployment artifact must load on the Redmi Note 9 Pro. *(Nihai deployment artifact'ı Redmi Note 9 Pro üzerinde yüklenmelidir.)*

Python-to-Android preprocessing parity must pass. *(Python-Android ön işleme eşdeğerliği geçmelidir.)*

Output parity must pass within the configured numerical tolerance. *(Çıktı eşdeğerliği yapılandırılmış sayısal tolerans içerisinde geçmelidir.)*

---

# 196. Runtime Acceptance Criteria (Çalışma Zamanı Kabul Kriterleri)

The model must execute repeatedly without unbounded inference queue growth. *(Model sınırsız çıkarım kuyruğu büyümesi olmadan tekrar tekrar çalışmalıdır.)*

The provisional inference target is `< 50 ms` per inference. *(Geçici çıkarım hedefi çıkarım başına `< 50 ms` değeridir.)*

Stale predictions must be rejected from current navigation context. *(Eski tahminler mevcut navigasyon bağlamından reddedilmelidir.)*

---

# 197. Fallback Acceptance Criteria (Geri Dönüş Kabul Kriterleri)

Model-load failure must not terminate baseline PDR. *(Model yükleme hatası temel PDR'yi sonlandırmamalıdır.)*

Invalid output must not change navigation state. *(Geçersiz çıktı navigasyon durumunu değiştirmemelidir.)*

Low-confidence or unavailable AI must allow deterministic motion logic to remain authoritative. *(Düşük güvenli veya kullanılamayan yapay zekâ deterministik hareket mantığının ana kontrolü korumasına izin vermelidir.)*

---

# 198. Navigation Acceptance Criteria (Navigasyon Kabul Kriterleri)

Every enabled motion-class effect must be traceable in runtime logs. *(Etkinleştirilmiş her hareket sınıfı etkisi çalışma zamanı kayıtlarında izlenebilir olmalıdır.)*

AI must not directly update East, North, latitude, or longitude. *(Yapay zekâ Doğu, Kuzey, enlem veya boylamı doğrudan güncellememelidir.)*

AI must not bypass the deterministic step detector or Ground Truth Firewall. *(Yapay zekâ deterministik adım algılayıcıyı veya Ground Truth Firewall'u atlamamalıdır.)*

---

# 199. Research Integrity Acceptance Criteria (Araştırma Bütünlüğü Kabul Kriterleri)

The final test set must remain session-wise isolated. *(Nihai test seti oturum bazlı izole kalmalıdır.)*

Final model-selection logic must not be tuned repeatedly using the held-out test score. *(Nihai model seçim mantığı ayrılmış test skoru kullanılarak tekrar tekrar ayarlanmamalıdır.)*

Negative results must remain visible. *(Negatif sonuçlar görünür kalmalıdır.)*

---

# 200. Minimum Successful Motion Classifier (Minimum Başarılı Hareket Sınıflandırıcı)

The minimum successful implementation may use a small model with the four target classes and deterministic fallback. *(Minimum başarılı uygulama dört hedef sınıfa ve deterministik geri dönüşe sahip küçük bir model kullanabilir.)*

It does not require automatic arbitrary-phone-placement generalization. *(Otomatik keyfi telefon yerleşimi genellemesi gerektirmez.)*

It does not require quantization or hardware acceleration. *(Quantization veya donanım hızlandırma gerektirmez.)*

---

# 201. Target Motion Classifier (Hedef Hareket Sınıflandırıcı)

The target implementation will provide high-quality four-class prediction, causal temporal smoothing, model confidence, Android on-device inference, navigation integration, and full reproducibility evidence. *(Hedef uygulama yüksek kaliteli dört sınıflı tahmin, nedensel zamansal smoothing, model güveni, Android cihaz üzeri çıkarım, navigasyon entegrasyonu ve tam tekrarlanabilirlik kanıtı sağlayacaktır.)*

---

# 202. Optional Enhancements (İsteğe Bağlı İyileştirmeler)

Optional future improvements may include confidence calibration. *(İsteğe bağlı gelecek iyileştirmeleri güven kalibrasyonunu içerebilir.)*

Optional future improvements may include broader phone-placement robustness. *(İsteğe bağlı gelecek iyileştirmeleri daha geniş telefon yerleşimi dayanıklılığını içerebilir.)*

Optional future improvements may include multi-user generalization. *(İsteğe bağlı gelecek iyileştirmeleri çok kullanıcılı genellemeyi içerebilir.)*

Optional future improvements may include quantized models. *(İsteğe bağlı gelecek iyileştirmeleri quantize edilmiş modelleri içerebilir.)*

---

# 203. Motion Classification Non-Goals (Hareket Sınıflandırma Olmayan Hedefler)

The model will not identify a person. *(Model kişiyi tanımlamayacaktır.)*

The model will not infer user identity from gait. *(Model gait üzerinden kullanıcı kimliği çıkarmayacaktır.)*

The model will not directly estimate geographic coordinates. *(Model doğrudan coğrafi koordinat tahmin etmeyecektir.)*

The model will not replace the deterministic navigation system. *(Model deterministik navigasyon sisteminin yerini almayacaktır.)*

---

# 204. Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kararlar)

The mandatory NAVGUARD motion classifier's trained class set is frozen as exactly `STATIONARY`, `WALKING`, `RUNNING`, and `TURNING`. *(Zorunlu NAVGUARD hareket sınıflandırıcısının trained class set'i exactly `STATIONARY`, `WALKING`, `RUNNING` ve `TURNING` olarak frozen'dır.)*

The minimum neural input will use synchronized accelerometer and gyroscope channels. *(Minimum sinir ağı girdisi senkronize ivmeölçer ve jiroskop kanallarını kullanacaktır.)*

The canonical initial raw channel order will be `[ax, ay, az, gx, gy, gz]`. *(Kanonik ilk ham kanal sırası `[ax, ay, az, gx, gy, gz]` olacaktır.)*

---

# 205. Dataset Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Veri Seti Kararları)

Dataset splitting will occur at the physical-session level. *(Veri seti ayrımı fiziksel oturum seviyesinde gerçekleşecektir.)*

Overlapping windows from one session will never cross train, validation, and test boundaries. *(Tek bir oturumdan örtüşen pencereler train, validation ve test sınırlarını hiçbir zaman geçmeyecektir.)*

Window records will preserve parent-session identity. *(Pencere kayıtları ana oturum kimliğini koruyacaktır.)*

---

# 206. Preprocessing Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Ön İşleme Kararları)

The final model input will be fixed-size and causal. *(Nihai model girdisi sabit boyutlu ve nedensel olacaktır.)*

Actual sensor timestamps will be authoritative. *(Gerçek sensör zaman damgaları esas olacaktır.)*

Python and Android preprocessing must remain equivalent. *(Python ve Android ön işleme eşdeğer kalmalıdır.)*

Training normalization statistics will come from the training split only. *(Eğitim normalizasyon istatistikleri yalnızca eğitim ayrımından gelecektir.)*

---

# 207. Model Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Model Kararları)

Random Forest will be the preferred strong classical baseline. *(Random Forest tercih edilen güçlü klasik temel olacaktır.)*

A lightweight 1D-CNN will be the primary neural candidate. *(Hafif bir 1D-CNN birincil sinir ağı adayı olacaktır.)*

The final classifier will be chosen by evidence rather than architecture prestige. *(Nihai sınıflandırıcı mimari prestiji yerine kanıta göre seçilecektir.)*

---

# 208. Metric Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Metrik Kararları)

Macro F1 will be the primary model-selection quality metric. *(Macro F1 temel model seçim kalite metriği olacaktır.)*

Accuracy, per-class precision, recall, F1, and confusion matrix will also be reported. *(Accuracy, sınıf başına precision, recall, F1 ve confusion matrix de raporlanacaktır.)*

The provisional held-out target remains Macro F1 `≥ 0.90`. *(Geçici ayrılmış hedef Macro F1 `≥ 0.90` olarak kalmaktadır.)*

---

# 209. Runtime Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Çalışma Zamanı Kararları)

The final model will run locally on the Redmi Note 9 Pro. *(Nihai model Redmi Note 9 Pro üzerinde yerel olarak çalışacaktır.)*

The model will infer from complete sensor windows rather than individual accelerometer events. *(Model bireysel ivmeölçer olayları yerine tam sensör pencerelerinden çıkarım yapacaktır.)*

The first deployment performance baseline will use CPU execution. *(İlk deployment performans temeli CPU çalıştırmayı kullanacaktır.)*

---

# 210. Deployment Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Deployment Kararları)

A neural deployment model will use a versioned `.tflite` artifact. *(Sinir ağı deployment modeli sürümlenmiş `.tflite` artifact'ı kullanacaktır.)*

The model file hash, class order, preprocessing version, input shape, and normalization parameters will be stored with the deployment metadata. *(Model dosya hash'i, sınıf sırası, ön işleme sürümü, girdi şekli ve normalizasyon parametreleri deployment metadata bilgisiyle birlikte saklanacaktır.)*

Python-to-Android golden parity tests will be mandatory. *(Python-Android golden eşdeğerlik testleri zorunlu olacaktır.)*

---

# 211. Navigation Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Navigasyon Kararları)

Motion predictions will first pass validation and temporal decision logic before changing operational navigation context. *(Hareket tahminleri operasyonel navigasyon bağlamını değiştirmeden önce doğrulama ve zamansal karar mantığından geçecektir.)*

Low-confidence or unavailable AI will fall back to deterministic motion logic. *(Düşük güvenli veya kullanılamayan yapay zekâ deterministik hareket mantığına geri dönecektir.)*

The model will never directly update position coordinates. *(Model konum koordinatlarını hiçbir zaman doğrudan güncellemeyecektir.)*

---

# 212. Decisions Pending Dataset Collection (Veri Toplama Bekleyen Kararlar)

The final motion-window duration remains pending pilot experiments. *(Nihai hareket pencere süresi pilot deneyleri beklemektedir.)*

The final overlap ratio remains pending latency and transition evaluation. *(Nihai örtüşme oranı gecikme ve geçiş değerlendirmesini beklemektedir.)*

The final resampling frequency remains pending measured device sensor behavior. *(Nihai yeniden örnekleme frekansı ölçülmüş cihaz sensör davranışını beklemektedir.)*

---

# 213. Decisions Pending Model Experiments (Model Deneyleri Bekleyen Kararlar)

The final 1D-CNN depth remains pending validation results. *(Nihai 1D-CNN derinliği doğrulama sonuçlarını beklemektedir.)*

The final kernel sizes remain pending architecture comparison. *(Nihai kernel boyutları mimari karşılaştırmayı beklemektedir.)*

The final filter counts remain pending architecture comparison. *(Nihai filter sayıları mimari karşılaştırmayı beklemektedir.)*

The final regularization strategy remains pending overfitting analysis. *(Nihai regularization stratejisi overfitting analizini beklemektedir.)*

---

# 214. Decisions Pending Navigation Validation (Navigasyon Doğrulaması Bekleyen Kararlar)

The final temporal smoothing strategy remains pending transition tests. *(Nihai zamansal smoothing stratejisi geçiş testlerini beklemektedir.)*

The final AI confidence gate remains pending validation confidence analysis. *(Nihai yapay zekâ güven kapısı validation güven analizini beklemektedir.)*

The final `RUNNING` navigation effect remains pending class reliability. *(Nihai `RUNNING` navigasyon etkisi sınıf güvenilirliğini beklemektedir.)*

The final `TURNING` process-noise effect remains pending navigation ablation. *(Nihai `TURNING` süreç gürültüsü etkisi navigasyon ablation'ını beklemektedir.)*

---

# 215. Decisions Pending Mobile Benchmarking (Mobil Benchmark Bekleyen Kararlar)

The final LiteRT execution delegate remains pending CPU measurements. *(Nihai LiteRT çalışma delegate'i CPU ölçümlerini beklemektedir.)*

The final quantization decision remains pending model-size and latency experiments. *(Nihai quantization kararı model boyutu ve gecikme deneylerini beklemektedir.)*

The final operational inference cadence remains pending window-overlap selection. *(Nihai operasyonel çıkarım kadansı pencere örtüşme seçimini beklemektedir.)*

---

# 216. Final Motion Classification Architecture Statement (Nihai Hareket Sınıflandırma Mimarisi Bildirimi)

**NAVGUARD will implement a mandatory on-device motion classifier that infers the operational contexts `STATIONARY`, `WALKING`, `RUNNING`, and `TURNING` from synchronized recent accelerometer and gyroscope history.** *(NAVGUARD senkronize son ivmeölçer ve jiroskop geçmişinden `STATIONARY`, `WALKING`, `RUNNING` ve `TURNING` operasyonel bağlamlarını çıkaran zorunlu cihaz üzeri hareket sınıflandırıcı geliştirecektir.)*

**The model will consume fixed-duration causal time windows, and the exact window duration, overlap, and regular model-grid frequency will be selected from pilot experiments before final training.** *(Model sabit süreli nedensel zaman pencerelerini kullanacak ve kesin pencere süresi, örtüşme ve düzenli model-grid frekansı nihai eğitimden önce pilot deneylerden seçilecektir.)*

**All train, validation, and test separation will occur at the physical recording-session level so that overlapping or temporally adjacent windows from one session cannot leak across experimental splits.** *(Tüm train, validation ve test ayrımı fiziksel kayıt oturumu seviyesinde gerçekleşecek; böylece tek bir oturumdan örtüşen veya zamansal olarak komşu pencereler deneysel ayrımlar arasında sızamayacaktır.)*

**Random Forest will provide the primary classical baseline, while a lightweight 1D-CNN will be the primary neural candidate, and the final classifier will be selected using Macro F1, per-class behavior, latency, model size, and downstream navigation value rather than neural-network complexity alone.** *(Random Forest temel klasik modeli sağlarken hafif bir 1D-CNN birincil sinir ağı adayı olacak ve nihai sınıflandırıcı yalnızca sinir ağı karmaşıklığı yerine Macro F1, sınıf başına davranış, gecikme, model boyutu ve aşağı akış navigasyon değeri kullanılarak seçilecektir.)*

**The provisional held-out model target will remain Macro F1 `≥ 0.90`, but the project will report the measured result transparently if this target is not achieved.** *(Geçici ayrılmış model hedefi Macro F1 `≥ 0.90` olarak kalacak ancak bu hedefe ulaşılamazsa proje ölçülmüş sonucu şeffaf şekilde raporlayacaktır.)*

**Training preprocessing and Android inference preprocessing will share an explicit versioned contract covering sensor timing, channel order, resampling, units, normalization, window structure, and output-class ordering.** *(Eğitim ön işlemesi ve Android çıkarım ön işlemesi sensör zamanlamasını, kanal sırasını, yeniden örneklemeyi, birimleri, normalizasyonu, pencere yapısını ve çıktı sınıf sırasını kapsayan açık sürümlenmiş sözleşmeyi paylaşacaktır.)*

**Before the classifier can influence navigation, the exported deployment model must pass Python-to-Android tensor parity, output parity, live-device stability, latency, stale-prediction, class-mapping, and deterministic-fallback tests on the Redmi Note 9 Pro.** *(Sınıflandırıcı navigasyonu etkileyebilmeden önce export edilen deployment modeli Redmi Note 9 Pro üzerinde Python-Android tensor eşdeğerliği, çıktı eşdeğerliği, canlı cihaz kararlılığı, gecikme, eski tahmin, sınıf eşleme ve deterministik geri dönüş testlerini geçmelidir.)*

**The classifier will never directly estimate geographic position, create navigation steps, or bypass deterministic validity rules; instead, its accepted output will provide motion context to PDR, step-length selection, the Quality Engine, and EKF process configuration.** *(Sınıflandırıcı hiçbir zaman doğrudan coğrafi konum tahmin etmeyecek, navigasyon adımları oluşturmayacak veya deterministik geçerlilik kurallarını atlamayacak; bunun yerine kabul edilmiş çıktısı PDR'ye, adım uzunluğu seçimine, Kalite Motoruna ve EKF süreç yapılandırmasına hareket bağlamı sağlayacaktır.)*

---

# 217. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development Motion Classification Model Design Completed *(Doküman Durumu: Geliştirme Öncesi Hareket Sınıflandırma Model Tasarımı Tamamlandı)*

**AI Requirement Level:** Mandatory *(Yapay Zekâ Gereksinim Seviyesi: Zorunlu)*

**Target Classes:** `STATIONARY / WALKING / RUNNING / TURNING` *(Hedef Sınıflar: `STATIONARY / WALKING / RUNNING / TURNING`)*

**Primary Raw Inputs:** Accelerometer + Gyroscope *(Temel Ham Girdiler: İvmeölçer + Jiroskop)*

**Canonical Initial Channel Order:** `[ax, ay, az, gx, gy, gz]` *(Kanonik İlk Kanal Sırası: `[ax, ay, az, gx, gy, gz]`)*

**Initial Model-Grid Candidate:** Approximately `50 Hz` *(İlk Model-Grid Adayı: Yaklaşık `50 Hz`)*

**Window Duration:** Pending Pilot Comparison *(Pencere Süresi: Pilot Karşılaştırma Bekleniyor)*

**Initial Window Candidates:** Approximately `1.0 s / 1.5 s / 2.0 s` *(İlk Pencere Adayları: Yaklaşık `1.0 s / 1.5 s / 2.0 s`)*

**Overlap:** Pending Experiment *(Örtüşme: Deney Bekleniyor)*

**Initial Overlap Candidates:** `0% / 50% / 75%` *(İlk Örtüşme Adayları: `%0 / %50 / %75`)*

**Strong Classical Baseline:** Random Forest *(Güçlü Klasik Temel: Random Forest)*

**Simple Classical Baseline:** Logistic Regression *(Basit Klasik Temel: Logistic Regression)*

**Primary Neural Candidate:** Lightweight 1D-CNN *(Birincil Sinir Ağı Adayı: Hafif 1D-CNN)*

**Primary Metric:** Macro F1 *(Temel Metrik: Macro F1)*

**Provisional Held-Out Target:** Macro F1 `≥ 0.90` *(Geçici Ayrılmış Hedef: Macro F1 `≥ 0.90`)*

**Required Secondary Metrics:** Accuracy + Per-Class Precision / Recall / F1 + Confusion Matrix *(Gerekli İkincil Metrikler: Accuracy + Sınıf Başına Precision / Recall / F1 + Confusion Matrix)*

**Dataset Split:** Session-Wise *(Veri Seti Ayrımı: Oturum Bazlı)*

**Overlapping Window Cross-Split Leakage:** Forbidden *(Örtüşen Pencerelerin Ayrımlar Arası Sızıntısı: Yasak)*

**Normalization Statistics:** Training Split Only *(Normalizasyon İstatistikleri: Yalnızca Eğitim Ayrımı)*

**Training-Mobile Preprocessing Parity:** Mandatory *(Eğitim-Mobil Ön İşleme Eşdeğerliği: Zorunlu)*

**Deployment Artifact:** Versioned `.tflite` Candidate for Neural Model *(Deployment Artifact'ı: Sinir Ağı Modeli İçin Sürümlenmiş `.tflite` Adayı)*

**Model Hash:** Required *(Model Hash'i: Gerekli)*

**Android Runtime Owner:** Kotlin AI Component *(Android Çalışma Zamanı Sahibi: Kotlin Yapay Zekâ Bileşeni)*

**Initial Mobile Execution Baseline:** CPU *(İlk Mobil Çalıştırma Temeli: CPU)*

**Provisional Inference Target:** `< 50 ms` per inference *(Geçici Çıkarım Hedefi: Çıkarım Başına `< 50 ms`)*

**Temporal Smoothing:** Required Candidate, Final Method Pending *(Zamansal Smoothing: Gerekli Aday, Nihai Yöntem Bekleniyor)*

**Low-Confidence Fallback:** Deterministic Motion Logic *(Düşük Güven Geri Dönüşü: Deterministik Hareket Mantığı)*

**Direct Position Prediction:** Forbidden *(Doğrudan Konum Tahmini: Yasak)*

**Direct Step Creation:** Forbidden *(Doğrudan Adım Oluşturma: Yasak)*

**Live GNSS Ground Truth Feature:** Forbidden During Denied Navigation *(Canlı GNSS Ground Truth Özelliği: Kesintili Navigasyon Sırasında Yasak)*

**Final Window:** Pending Dataset Experiments *(Nihai Pencere: Veri Seti Deneyleri Bekleniyor)*

**Final 1D-CNN Architecture:** Pending Validation Comparison *(Nihai 1D-CNN Mimarisi: Doğrulama Karşılaştırması Bekleniyor)*

**Final Confidence Gate:** Pending Validation Analysis *(Nihai Güven Kapısı: Doğrulama Analizi Bekleniyor)*

**Final Temporal Hysteresis:** Pending Transition Tests *(Nihai Zamansal Hysteresis: Geçiş Testleri Bekleniyor)*

**Final Delegate / Quantization:** Pending Redmi Note 9 Pro Benchmark *(Nihai Delegate / Quantization: Redmi Note 9 Pro Benchmark'ı Bekleniyor)*

**Next Documentation Item:** 24 — Step Length Estimation Model *(Sonraki Dokümantasyon Öğesi: 24 — Adım Uzunluğu Tahmin Modeli)*
