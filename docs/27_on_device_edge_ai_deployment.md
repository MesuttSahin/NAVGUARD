# 27 — On-Device Edge AI Deployment (Cihaz Üzeri Edge AI Deployment)

## 1. Document Purpose (Dokümanın Amacı)

This document defines how NAVGUARD machine-learning models will be converted, packaged, verified, loaded, executed, monitored, benchmarked, versioned, isolated from failures, and integrated with the Android navigation runtime. *(Bu doküman NAVGUARD makine öğrenmesi modellerinin nasıl dönüştürüleceğini, paketleneceğini, doğrulanacağını, yükleneceğini, çalıştırılacağını, izleneceğini, benchmark edileceğini, sürümleneceğini, hatalardan izole edileceğini ve Android navigasyon çalışma zamanıyla entegre edileceğini tanımlar.)*

The deployment architecture covers Motion Classification and any Step Length Estimation model that survives the model-retention process. *(Deployment mimarisi Hareket Sınıflandırmasını ve model koruma sürecini geçen herhangi bir Adım Uzunluğu Tahmin modelini kapsar.)*

The primary objective is reliable offline inference on the Xiaomi Redmi Note 9 Pro without making cloud connectivity a navigation dependency. *(Temel hedef bulut bağlantısını navigasyon bağımlılığı haline getirmeden Xiaomi Redmi Note 9 Pro üzerinde güvenilir çevrimdışı çıkarımdır.)*

---

# 2. Deployment Principle (Deployment İlkesi)

Training performance alone does not make a model deployable. *(Yalnızca eğitim performansı bir modeli deployment'a uygun hale getirmez.)*

A NAVGUARD model must preserve its numerical meaning, preprocessing contract, output semantics, runtime stability, and fallback behavior after moving from Python to Android. *(Bir NAVGUARD modeli Python'dan Android'e taşındıktan sonra sayısal anlamını, ön işleme sözleşmesini, çıktı semantiğini, çalışma zamanı kararlılığını ve geri dönüş davranışını korumalıdır.)*

---

# 3. Offline-First Requirement (Çevrimdışı Öncelikli Gereksinim)

Navigation-enabled AI inference will execute locally on the smartphone. *(Navigasyon etkin yapay zekâ çıkarımı akıllı telefon üzerinde yerel olarak çalışacaktır.)*

No network request will be required to classify motion or estimate step length during normal NAVGUARD operation. *(Normal NAVGUARD çalışması sırasında hareket sınıflandırmak veya adım uzunluğu tahmin etmek için ağ isteği gerekmeyecektir.)*

---

# 4. Current LiteRT Platform Baseline (Mevcut LiteRT Platform Temeli)

As of September 1, 2026, Google documents LiteRT as its on-device machine-learning framework and recommends the newer `CompiledModel` API for new high-performance Android work, while the older `Interpreter` API remains available for backward compatibility. *(1 Eylül 2026 itibarıyla Google, LiteRT'yi cihaz üzeri makine öğrenmesi framework'ü olarak dokümante etmekte ve yeni yüksek performanslı Android çalışmaları için daha yeni `CompiledModel` API'sini önermekte, eski `Interpreter` API'si ise geriye dönük uyumluluk için kullanılabilir kalmaktadır.)*

---

# 5. Current Android Compatibility Note (Mevcut Android Uyumluluk Notu)

Google's current Android documentation lists LiteRT `2.2.0` as the latest release as of August 14, 2026 and lists Android API level `23` as the minimum SDK level for that release. *(Google'ın mevcut Android dokümantasyonu 14 Ağustos 2026 itibarıyla LiteRT `2.2.0` sürümünü en güncel sürüm olarak ve bu sürüm için Android API seviyesi `23` değerini minimum SDK seviyesi olarak listelemektedir.)*

NAVGUARD's previously planned minimum Android API level of approximately `24` is therefore compatible with this documented minimum, but the exact project dependency version will still be frozen during environment bootstrap rather than hard-coded from this planning document. *(NAVGUARD'ın daha önce planlanan yaklaşık `24` minimum Android API seviyesi bu dokümante edilmiş minimumla uyumludur ancak kesin proje dependency sürümü yine de bu planlama dokümanından hard-code edilmek yerine ortam bootstrap sırasında sabitlenecektir.)*

---

# 6. LiteRT Model Format (LiteRT Model Formatı)

Google's LiteRT conversion documentation continues to use the `.tflite` extension for converted LiteRT FlatBuffer models. *(Google'ın LiteRT conversion dokümantasyonu dönüştürülmüş LiteRT FlatBuffer modelleri için `.tflite` uzantısını kullanmaya devam etmektedir.)*

NAVGUARD neural deployment artifacts will therefore use versioned `.tflite` files. *(Bu nedenle NAVGUARD sinir ağı deployment artifact'ları sürümlenmiş `.tflite` dosyaları kullanacaktır.)*

---

# 7. Primary Runtime Direction (Temel Runtime Yönü)

The preferred new-work runtime direction for NAVGUARD neural models will be the Kotlin LiteRT `CompiledModel` API. *(NAVGUARD sinir ağı modelleri için tercih edilen yeni geliştirme runtime yönü Kotlin LiteRT `CompiledModel` API'si olacaktır.)*

Google currently provides a Kotlin `CompiledModel` API intended for accelerator-first Android inference. *(Google şu anda accelerator-first Android çıkarımı için tasarlanmış Kotlin `CompiledModel` API'si sağlamaktadır.)*

---

# 8. Interpreter Compatibility Path (Interpreter Uyumluluk Yolu)

The `Interpreter` API may remain available as a fallback implementation path if a specific deployment limitation, compatibility issue, or project constraint makes it more appropriate. *(`Interpreter` API'si belirli bir deployment sınırlaması, uyumluluk problemi veya proje kısıtı onu daha uygun hale getirirse geri dönüş uygulama yolu olarak kullanılabilir.)*

The final runtime choice will be recorded explicitly in the deployment configuration. *(Nihai runtime seçimi deployment yapılandırmasında açık şekilde kaydedilecektir.)*

---

# 9. No API Choice by Fashion (Trend Uğruna API Seçimi Olmaması)

NAVGUARD will not switch runtime APIs merely because one API is newer. *(NAVGUARD yalnızca bir API daha yeni olduğu için runtime API'sini değiştirmeyecektir.)*

The selected path must successfully support the chosen model, device, reproducibility requirements, and measured runtime behavior. *(Seçilen yol seçilen modeli, cihazı, tekrarlanabilirlik gereksinimlerini ve ölçülmüş çalışma zamanı davranışını başarıyla desteklemelidir.)*

---

# 10. Application-Bundled Runtime Preference (Uygulama İçine Dahil Runtime Tercihi)

The preferred initial architecture will bundle the required LiteRT dependency with the Android application rather than make dynamic network delivery a mandatory dependency. *(Tercih edilen ilk mimari gerekli LiteRT dependency'sini dinamik ağ dağıtımını zorunlu bağımlılık haline getirmek yerine Android uygulamasıyla birlikte paketleyecektir.)*

This supports offline operation and reproducible experimental builds. *(Bu çevrimdışı çalışmayı ve tekrarlanabilir deneysel build'leri destekler.)*

---

# 11. Google Play Services Runtime Is Not Mandatory (Google Play Services Runtime Zorunlu Değildir)

LiteRT can also be used through Google Play services in some Interpreter-based Android deployment paths, but NAVGUARD will not require that route for its minimum offline research architecture. *(LiteRT bazı Interpreter tabanlı Android deployment yollarında Google Play services üzerinden de kullanılabilir ancak NAVGUARD minimum çevrimdışı araştırma mimarisi için bu yolu zorunlu tutmayacaktır.)*

---

# 12. Deployment Architecture Overview (Deployment Mimarisi Genel Görünümü)

```text
Python Training
(Python Eğitimi)
        ↓
Model Selection
(Model Seçimi)
        ↓
Export / Serialization
(Export / Serialization)
        ↓
Artifact Validation
(Artifact Doğrulama)
        ↓
Model Registry
(Model Registry)
        ↓
Android Model Repository
(Android Model Repository)
        ↓
Native Kotlin AI Runtime
(Native Kotlin Yapay Zekâ Runtime)
        ↓
Preprocessor
(Ön İşleyici)
        ↓
Tensor / Feature Builder
(Tensor / Özellik Oluşturucu)
        ↓
Inference Executor
(Çıkarım Çalıştırıcı)
        ↓
Output Validation
(Çıktı Doğrulama)
        ↓
Postprocessing / Temporal Logic
(Son İşleme / Zamansal Mantık)
        ↓
Navigation Domain
(Navigasyon Domain Katmanı)
        ↓
Flutter State Snapshot
(Flutter Durum Anlık Görüntüsü)
```

---

# 13. Runtime Ownership (Runtime Sahipliği)

The native Kotlin AI subsystem will own all hardware-sensitive model-execution responsibilities. *(Native Kotlin yapay zekâ alt sistemi donanıma hassas tüm model çalıştırma sorumluluklarının sahibi olacaktır.)*

Flutter will not directly instantiate or control LiteRT execution objects. *(Flutter LiteRT çalıştırma nesnelerini doğrudan oluşturmayacak veya kontrol etmeyecektir.)*

---

# 14. AI Runtime Responsibilities (Yapay Zekâ Runtime Sorumlulukları)

The Kotlin runtime will own model discovery. *(Kotlin runtime model keşfinin sahibi olacaktır.)*

It will own model validation. *(Model doğrulamanın sahibi olacaktır.)*

It will own model loading. *(Model yüklemenin sahibi olacaktır.)*

It will own preprocessing execution required immediately before inference. *(Çıkarımdan hemen önce gerekli ön işleme çalıştırmasının sahibi olacaktır.)*

It will own inference execution and output decoding. *(Çıkarım çalıştırma ve çıktı decoding işleminin sahibi olacaktır.)*

---

# 15. AI Platform Interface (Yapay Zekâ Platform Arayüzü)

Flutter will communicate with the native runtime through the previously defined `NavguardAiPlatform` abstraction. *(Flutter daha önce tanımlanan `NavguardAiPlatform` abstraction üzerinden native runtime ile iletişim kuracaktır.)*

The platform layer will expose high-level domain results rather than raw LiteRT objects. *(Platform katmanı ham LiteRT nesneleri yerine yüksek seviyeli domain sonuçlarını sunacaktır.)*

---

# 16. Example Platform Responsibilities (Örnek Platform Sorumlulukları)

```text
NavguardAiPlatform

initialize()
loadModel(...)
startMotionInference()
stopMotionInference()
getRuntimeInfo()
getModelInfo()
runParityTest(...)
dispose()
```

The exact method names may change during implementation. *(Kesin method isimleri uygulama sırasında değişebilir.)*

---

# 17. Continuous Results Use Stream Semantics (Sürekli Sonuçlar Stream Semantiği Kullanır)

Continuous Motion Classification results will use a stream-oriented interface. *(Sürekli Hareket Sınıflandırma sonuçları stream odaklı arayüz kullanacaktır.)*

A one-off method call for every window from Flutter is not the preferred high-frequency architecture. *(Flutter'dan her pencere için tek seferlik method call tercih edilen yüksek frekanslı mimari değildir.)*

---

# 18. Native Window Construction Preference (Native Pencere Oluşturma Tercihi)

The preferred deployment architecture will construct AI motion windows close to the native sensor stream. *(Tercih edilen deployment mimarisi yapay zekâ hareket pencerelerini native sensör akışına yakın oluşturacaktır.)*

This avoids unnecessarily transporting every raw sensor event through Flutter solely for native inference. *(Bu yalnızca native çıkarım için her ham sensör olayını gereksiz yere Flutter üzerinden taşımayı önler.)*

---

# 19. Source-of-Truth Preservation (Ana Veri Kaynağını Koruma)

Native AI window construction does not create a second physical sensor owner. *(Native yapay zekâ pencere oluşturma ikinci fiziksel sensör sahibi oluşturmaz.)*

The authoritative Sensor Manager stream will fan out to logging, preprocessing, PDR, diagnostics, and AI consumers. *(Ana Sensor Manager akışı logging, ön işleme, PDR, diagnostics ve AI consumer'larına dağıtılacaktır.)*

---

# 20. No Duplicate Sensor Registration for AI (Yapay Zekâ İçin Duplicate Sensör Kaydı Olmaması)

The AI subsystem must not independently register duplicate accelerometer and gyroscope listeners when the authoritative acquisition subsystem already owns those sensors. *(Ana veri toplama alt sistemi sensörlerin sahibi olduğunda yapay zekâ alt sistemi bağımsız duplicate ivmeölçer ve jiroskop listener'ları kaydetmemelidir.)*

---

# 21. Neural Model Export Pipeline (Sinir Ağı Model Export Hattı)

A selected TensorFlow or Keras-compatible neural model will be exported through a frozen conversion process. *(Seçilen TensorFlow veya Keras uyumlu sinir ağı modeli sabitlenmiş conversion süreci üzerinden export edilecektir.)*

The conversion result will be a `.tflite` artifact. *(Conversion sonucu `.tflite` artifact'ı olacaktır.)*

---

# 22. Export Source Model (Export Kaynak Modeli)

The deployment pipeline must record exactly which training checkpoint produced the exported model. *(Deployment hattı export edilen modeli tam olarak hangi eğitim checkpoint'inin ürettiğini kaydetmelidir.)*

---

# 23. Export Configuration (Export Yapılandırması)

```text
ModelExportConfig
- sourceModelId
- sourceCheckpoint
- sourceFrameworkVersion
- converterVersion
- conversionOptions
- quantizationMode
- representativeDatasetId
- outputModelVersion
```

---

# 24. Conversion Validation (Conversion Doğrulaması)

Conversion success does not mean numerical equivalence has been proven. *(Conversion başarısı sayısal eşdeğerliğin kanıtlandığı anlamına gelmez.)*

The exported model must be evaluated on fixed validation inputs and compared against the source model. *(Export edilen model sabit doğrulama girdilerinde değerlendirilmeli ve kaynak modelle karşılaştırılmalıdır.)*

---

# 25. Conversion Failure (Conversion Hatası)

Unsupported operations, tensor-shape errors, or unacceptable prediction changes will block deployment. *(Desteklenmeyen operasyonlar, tensor şekli hataları veya kabul edilemez tahmin değişiklikleri deployment'ı engelleyecektir.)*

---

# 26. Exported Artifact Is a New Artifact (Export Edilmiş Artifact Yeni Bir Artifact'tır)

The exported `.tflite` file will have its own identity even when it originates from one training checkpoint. *(Export edilmiş `.tflite` dosyası tek bir eğitim checkpoint'inden kaynaklansa bile kendi kimliğine sahip olacaktır.)*

---

# 27. Model Artifact Naming (Model Artifact İsimlendirme)

A deterministic naming convention will be used. *(Deterministik bir isimlendirme kuralı kullanılacaktır.)*

```text
motion_classifier_v001.tflite

step_length_v001.tflite
```

The exact file names will match the model registry. *(Kesin dosya isimleri model registry ile eşleşecektir.)*

---

# 28. Model Hash Requirement (Model Hash Gereksinimi)

Every deployment model will have a SHA-256 or equivalent cryptographic hash recorded. *(Her deployment modeli kaydedilmiş SHA-256 veya eşdeğer kriptografik hash değerine sahip olacaktır.)*

The runtime benchmark evidence will reference this hash. *(Runtime benchmark kanıtı bu hash değerine referans verecektir.)*

---

# 29. Model Registry Entry (Model Registry Girdisi)

```text
DeploymentModelEntry
- modelId
- task
- modelVersion
- artifactFile
- artifactHash
- artifactFormat
- sourceTrainingRun
- datasetId
- preprocessingVersion
- inputSchemaVersion
- outputSchemaVersion
- quantizationMode
- deploymentStatus
```

---

# 30. Model Metadata File (Model Metadata Dosyası)

Each model will have a machine-readable metadata configuration. *(Her model machine-readable metadata yapılandırmasına sahip olacaktır.)*

The runtime must not depend on undocumented assumptions embedded only in developer memory. *(Runtime yalnızca geliştirici hafızasında bulunan dokümante edilmemiş varsayımlara bağımlı olmamalıdır.)*

---

# 31. Motion Model Metadata Candidate (Hareket Modeli Metadata Adayı)

```text
{
  "modelId": "...",
  "version": "...",
  "task": "MOTION_CLASSIFICATION",
  "inputShape": [...],
  "channelOrder": [
    "ax",
    "ay",
    "az",
    "gx",
    "gy",
    "gz"
  ],
  "sampleRateHz": ...,
  "windowDurationMs": ...,
  "normalizationVersion": "...",
  "classOrder": [
    "STATIONARY",
    "WALKING",
    "RUNNING",
    "TURNING"
  ]
}
```

The actual values remain pending final model selection. *(Gerçek değerler nihai model seçimini beklemektedir.)*

---

# 32. Input Contract Is Immutable Per Model Version (Girdi Sözleşmesi Model Sürümü Başına Değişmezdir)

A deployed model version must have one exact input contract. *(Deployment edilen model sürümü tek kesin girdi sözleşmesine sahip olmalıdır.)*

Changing channel order or normalization requires a compatible new deployment configuration and usually a new model version. *(Kanal sırasını veya normalizasyonu değiştirmek uyumlu yeni deployment yapılandırması ve genellikle yeni model sürümü gerektirir.)*

---

# 33. Output Contract Is Immutable Per Model Version (Çıktı Sözleşmesi Model Sürümü Başına Değişmezdir)

The meaning and ordering of model outputs must remain frozen. *(Model çıktılarının anlamı ve sırası sabit kalmalıdır.)*

---

# 34. Tensor DType Contract (Tensor DType Sözleşmesi)

The model metadata will explicitly declare tensor data types such as `float32` or an applicable quantized type. *(Model metadata bilgisi `float32` veya uygun quantize veri türü gibi tensor veri türlerini açıkça tanımlayacaktır.)*

---

# 35. Tensor Shape Validation (Tensor Şekli Doğrulaması)

The runtime must validate input and output tensor shapes during model initialization. *(Runtime model başlatma sırasında girdi ve çıktı tensor şekillerini doğrulamalıdır.)*

A shape mismatch will block the model from entering `READY`. *(Şekil uyuşmazlığı modelin `READY` durumuna girmesini engelleyecektir.)*

---

# 36. Tensor Layout (Tensor Layout'u)

For the candidate time-series 1D-CNN, the deployment contract will explicitly define whether the runtime input is conceptually `[1, T, C]` or another exported shape. *(Aday zaman serisi 1D-CNN için deployment sözleşmesi runtime girdisinin kavramsal olarak `[1, T, C]` veya başka export edilmiş şekil olup olmadığını açıkça tanımlayacaktır.)*

No reshaping assumption will be left implicit. *(Hiçbir reshape varsayımı örtük bırakılmayacaktır.)*

---

# 37. Batch Size (Batch Boyutu)

Normal live Motion Classification inference will use one current causal window per inference request unless later profiling demonstrates a reason to batch. *(Normal canlı Hareket Sınıflandırma çıkarımı daha sonra profiling batching için neden göstermedikçe çıkarım isteği başına bir mevcut nedensel pencere kullanacaktır.)*

---

# 38. No Artificial Live Batching (Yapay Canlı Batching Olmaması)

NAVGUARD will not delay current predictions simply to create larger inference batches unless measured performance justifies the additional latency. *(NAVGUARD ölçülmüş performans ek gecikmeyi gerekçelendirmedikçe yalnızca daha büyük çıkarım batch'leri oluşturmak için mevcut tahminleri geciktirmeyecektir.)*

---

# 39. Tensor Memory Reuse (Tensor Bellek Yeniden Kullanımı)

The runtime should reuse fixed-size input and output buffers where practical. *(Runtime uygulanabilir olduğunda sabit boyutlu girdi ve çıktı buffer'larını yeniden kullanmalıdır.)*

Repeated large allocation inside every inference cycle should be avoided. *(Her çıkarım döngüsü içerisinde tekrarlanan büyük allocation'dan kaçınılmalıdır.)*

---

# 40. Ring Buffer for Motion Windows (Hareket Pencereleri İçin Ring Buffer)

The synchronized sensor history used for Motion Classification will use a bounded ring buffer. *(Hareket Sınıflandırması için kullanılan senkronize sensör geçmişi sınırlı ring buffer kullanacaktır.)*

The buffer capacity will cover only the required recent temporal context plus a small engineering margin. *(Buffer kapasitesi yalnızca gerekli son zamansal bağlamı ve küçük mühendislik marjını kapsayacaktır.)*

---

# 41. No Unlimited Sensor History in Memory (Bellekte Sınırsız Sensör Geçmişi Olmaması)

Long-term session evidence belongs to the logging subsystem rather than an ever-growing AI runtime buffer. *(Uzun süreli oturum kanıtı sürekli büyüyen yapay zekâ runtime buffer'ı yerine logging alt sistemine aittir.)*

---

# 42. Preprocessing Pipeline Ownership (Ön İşleme Hattı Sahipliği)

The deployment runtime will execute the exact preprocessing contract associated with the loaded model. *(Deployment runtime yüklenen modelle ilişkili kesin ön işleme sözleşmesini çalıştıracaktır.)*

---

# 43. Runtime Preprocessing Stages (Runtime Ön İşleme Aşamaları)

```text
Timestamped Sensor Samples
(Zaman Damgalı Sensör Örnekleri)
        ↓
Synchronization
(Senkronizasyon)
        ↓
Validity / Gap Check
(Geçerlilik / Boşluk Kontrolü)
        ↓
Optional Filtering
(İsteğe Bağlı Filtreleme)
        ↓
Resampling
(Yeniden Örnekleme)
        ↓
Normalization
(Normalizasyon)
        ↓
Tensor Construction
(Tensor Oluşturma)
```

---

# 44. No UI Preprocessing (UI Ön İşleme Olmaması)

Flutter UI code will not be responsible for numerical normalization or sensor resampling required by the model. *(Flutter UI kodu model tarafından gereken sayısal normalizasyon veya sensör yeniden örneklemeden sorumlu olmayacaktır.)*

---

# 45. Training-Mobile Parity Is Mandatory (Eğitim-Mobil Eşdeğerliği Zorunludur)

Every transformation used in production inference must match the frozen Python reference behavior within defined numerical tolerance. *(Üretim çıkarımında kullanılan her dönüşüm tanımlanan sayısal tolerans içerisinde sabitlenmiş Python referans davranışıyla eşleşmelidir.)*

---

# 46. Golden Parity Dataset (Golden Eşdeğerlik Veri Seti)

A small immutable collection of raw validation windows will be used for Python-to-Android parity tests. *(Küçük değişmez ham validation pencere koleksiyonu Python-Android eşdeğerlik testleri için kullanılacaktır.)*

---

# 47. Golden Parity Package (Golden Eşdeğerlik Paketi)

```text
parity/
├── raw_window_001.*
├── expected_tensor_001.*
├── expected_output_001.*
├── raw_window_002.*
├── expected_tensor_002.*
└── expected_output_002.*
```

---

# 48. Tensor Parity Test (Tensor Eşdeğerlik Testi)

Android preprocessing must produce the expected tensor values within tolerance. *(Android ön işleme beklenen tensor değerlerini tolerans içerisinde üretmelidir.)*

---

# 49. Output Parity Test (Çıktı Eşdeğerlik Testi)

The deployment runtime must produce model outputs equivalent to the reference implementation within the defined tolerance. *(Deployment runtime tanımlanan tolerans içerisinde referans uygulamayla eşdeğer model çıktıları üretmelidir.)*

---

# 50. Class Parity Test (Sınıf Eşdeğerlik Testi)

For Motion Classification, equivalent model output must map to the same class in Python and Android. *(Hareket Sınıflandırması için eşdeğer model çıktısı Python ve Android'de aynı sınıfa eşlenmelidir.)*

---

# 51. Regression Parity Test (Regresyon Eşdeğerlik Testi)

For a neural Step Length model, the predicted `L_k` must match the reference deployment output within tolerance. *(Sinir ağı Adım Uzunluğu modeli için tahmin edilen `L_k` referans deployment çıktısıyla tolerans içerisinde eşleşmelidir.)*

---

# 52. Classical Model Deployment Path (Klasik Model Deployment Yolu)

Not every NAVGUARD machine-learning model needs LiteRT. *(Her NAVGUARD makine öğrenmesi modelinin LiteRT kullanması gerekmez.)*

If a classical model wins the evaluation, its deployment strategy will prioritize deterministic reproducibility and low complexity. *(Klasik model değerlendirmeyi kazanırsa deployment stratejisi deterministik tekrarlanabilirliğe ve düşük karmaşıklığa öncelik verecektir.)*

---

# 53. Linear Regression Deployment (Linear Regression Deployment)

A final Linear Regression step-length estimator may be implemented directly from frozen coefficients, intercept, feature ordering, and normalization parameters. *(Nihai Linear Regression adım uzunluğu tahmin motoru sabitlenmiş katsayılar, intercept, özellik sırası ve normalizasyon parametrelerinden doğrudan uygulanabilir.)*

---

# 54. Random Forest Deployment (Random Forest Deployment)

If Random Forest wins a task, its mobile representation will require an explicit deterministic inference implementation or a verified conversion path. *(Random Forest bir görevi kazanırsa mobil temsili açık deterministik çıkarım uygulaması veya doğrulanmış conversion yolu gerektirecektir.)*

Deployment difficulty is part of the final model-selection decision. *(Deployment zorluğu nihai model seçim kararının parçasıdır.)*

---

# 55. No Forced Neural Conversion (Zorla Sinir Ağı Conversion Olmaması)

A successful classical model will not be replaced by a neural model solely to fit the LiteRT deployment pipeline. *(Başarılı klasik model yalnızca LiteRT deployment hattına uyması için sinir ağı modeliyle değiştirilmeyecektir.)*

---

# 56. AI Runtime Component Structure (Yapay Zekâ Runtime Bileşen Yapısı)

```text
ai/
├── model/
├── registry/
├── preprocessing/
├── runtime/
├── motion/
├── step_length/
├── parity/
├── diagnostics/
└── logging/
```

The exact package names may change while preserving responsibility boundaries. *(Kesin package isimleri sorumluluk sınırlarını koruyarak değişebilir.)*

---

# 57. Model Repository (Model Repository)

A native `ModelRepository` will resolve the active model artifact and metadata. *(Native `ModelRepository` aktif model artifact'ını ve metadata bilgisini çözecektir.)*

---

# 58. Model Repository Responsibilities (Model Repository Sorumlulukları)

The repository will resolve model ID. *(Repository model ID'sini çözecektir.)*

It will resolve artifact location. *(Artifact konumunu çözecektir.)*

It will resolve expected hash and schemas. *(Beklenen hash ve şemaları çözecektir.)*

---

# 59. Runtime Model Verification (Runtime Model Doğrulaması)

Before a formal benchmark model becomes active, the runtime will verify that the loaded file corresponds to the configured model identity. *(Resmî benchmark modeli aktif hale gelmeden önce runtime yüklenen dosyanın yapılandırılmış model kimliğine karşılık geldiğini doğrulayacaktır.)*

---

# 60. Hash Verification Policy (Hash Doğrulama Politikası)

Formal Benchmark Mode should verify the model artifact hash at startup or model load. *(Resmî Benchmark Modu başlangıçta veya model yüklemede model artifact hash değerini doğrulamalıdır.)*

Development Mode may expose a faster optional policy if repeated hashing becomes inconvenient, but the loaded identity must remain observable. *(Development Mode tekrarlanan hash hesaplama zahmetli hale gelirse daha hızlı isteğe bağlı politika sunabilir ancak yüklenen kimlik gözlemlenebilir kalmalıdır.)*

---

# 61. Model Runtime States (Model Runtime Durumları)

```text
UNAVAILABLE
UNLOADED
LOADING
READY
ACTIVE
DEGRADED
ERROR
DISPOSED
```

---

# 62. UNAVAILABLE State (UNAVAILABLE Durumu)

`UNAVAILABLE` means the required model artifact or runtime capability cannot be used. *(`UNAVAILABLE`, gerekli model artifact'ı veya runtime yeteneğinin kullanılamadığı anlamına gelir.)*

---

# 63. UNLOADED State (UNLOADED Durumu)

`UNLOADED` means a valid model configuration exists but runtime initialization has not yet occurred. *(`UNLOADED`, geçerli model yapılandırmasının mevcut ancak runtime başlatmanın henüz gerçekleşmediği anlamına gelir.)*

---

# 64. LOADING State (LOADING Durumu)

`LOADING` represents model file validation and runtime creation. *(`LOADING`, model dosyası doğrulaması ve runtime oluşturmayı temsil eder.)*

---

# 65. READY State (READY Durumu)

`READY` means the model has been loaded, schemas have passed validation, and inference resources are prepared. *(`READY`, modelin yüklendiği, şemaların doğrulamayı geçtiği ve çıkarım kaynaklarının hazır olduğu anlamına gelir.)*

---

# 66. ACTIVE State (ACTIVE Durumu)

`ACTIVE` means the model is currently participating in inference. *(`ACTIVE`, modelin şu anda çıkarıma katıldığı anlamına gelir.)*

---

# 67. DEGRADED State (DEGRADED Durumu)

`DEGRADED` means inference remains possible but a quality, timing, delegate, or input condition has reduced operational confidence. *(`DEGRADED`, çıkarımın hâlâ mümkün ancak kalite, zamanlama, delegate veya girdi koşulunun operasyonel güveni azalttığı anlamına gelir.)*

---

# 68. ERROR State (ERROR Durumu)

`ERROR` means the model cannot safely provide navigation-consumable predictions. *(`ERROR`, modelin güvenli şekilde navigasyon tarafından kullanılabilir tahmin sağlayamadığı anlamına gelir.)*

---

# 69. Runtime Initialization Sequence (Runtime Başlatma Sırası)

```text
Resolve Model
(Modeli Çöz)
        ↓
Verify Metadata
(Metadata Doğrula)
        ↓
Verify Hash
(Hash Doğrula)
        ↓
Create Runtime
(Runtime Oluştur)
        ↓
Inspect Tensor Contract
(Tensor Sözleşmesini İncele)
        ↓
Allocate / Prepare Buffers
(Buffer'ları Ayır / Hazırla)
        ↓
Optional Warm-Up
(İsteğe Bağlı Warm-Up)
        ↓
READY
```

---

# 70. Model Load Once, Reuse Many Times (Modeli Bir Kez Yükle, Çok Kez Kullan)

The model execution object will normally be created once per runtime lifecycle and reused for many predictions. *(Model çalıştırma nesnesi normalde runtime yaşam döngüsü başına bir kez oluşturulacak ve çok sayıda tahmin için yeniden kullanılacaktır.)*

---

# 71. No Interpreter Recreation Per Window (Pencere Başına Runtime Yeniden Oluşturma Olmaması)

NAVGUARD will not recreate the LiteRT runtime for every Motion Classification window. *(NAVGUARD her Hareket Sınıflandırma penceresinde LiteRT runtime'ı yeniden oluşturmayacaktır.)*

---

# 72. Lazy Initialization (Lazy Initialization)

The AI runtime may be initialized lazily when an AI-enabled navigation profile is selected. *(Yapay zekâ runtime'ı yapay zekâ etkin navigasyon profili seçildiğinde lazy olarak başlatılabilir.)*

---

# 73. Early Readiness Option (Erken Hazırlık Seçeneği)

Benchmark or Demo Mode may preload the model during readiness checks to avoid unexpected startup delay when navigation begins. *(Benchmark veya Demo Modu navigasyon başladığında beklenmedik başlangıç gecikmesini önlemek için hazırlık kontrolleri sırasında modeli preload edebilir.)*

---

# 74. Warm-Up Policy (Warm-Up Politikası)

A small number of non-benchmark warm-up inferences may be executed after model initialization if profiling shows first-run latency differs materially from steady state. *(Profiling ilk çalıştırma gecikmesinin steady state'ten anlamlı şekilde farklı olduğunu gösterirse model başlatıldıktan sonra küçük sayıda benchmark dışı warm-up çıkarımı çalıştırılabilir.)*

---

# 75. Warm-Up Must Be Logged Separately (Warm-Up Ayrı Kaydedilmelidir)

Warm-up inference latency must not be silently mixed with steady-state benchmark latency. *(Warm-up çıkarım gecikmesi steady-state benchmark gecikmesiyle sessizce karıştırılmamalıdır.)*

---

# 76. Motion Inference Trigger (Hareket Çıkarım Tetikleyicisi)

A Motion Classification inference will be triggered only when a complete valid causal model window is available. *(Hareket Sınıflandırma çıkarımı yalnızca tam geçerli nedensel model penceresi mevcut olduğunda tetiklenecektir.)*

---

# 77. Step Length Inference Trigger (Adım Uzunluğu Çıkarım Tetikleyicisi)

Step Length inference will be triggered only after an accepted step event exists and all mandatory features are available. *(Adım Uzunluğu çıkarımı yalnızca kabul edilmiş adım olayı mevcut ve tüm zorunlu özellikler kullanılabilir olduğunda tetiklenecektir.)*

---

# 78. Inference Scheduling Is Not Sensor Scheduling (Çıkarım Zamanlaması Sensör Zamanlaması Değildir)

The accelerometer may deliver approximately fifty samples per second while Motion Classification inference runs at a substantially lower cadence determined by the window stride. *(İvmeölçer saniyede yaklaşık elli örnek teslim edebilirken Hareket Sınıflandırma çıkarımı pencere stride değeri tarafından belirlenen anlamlı şekilde daha düşük kadansta çalışabilir.)*

---

# 79. Inference Stride (Çıkarım Stride Değeri)

The inference stride will follow the frozen overlap configuration from the selected model. *(Çıkarım stride değeri seçilen modelin sabitlenmiş overlap yapılandırmasını izleyecektir.)*

---

# 80. Example Only (Yalnızca Örnek)

A `2.0 s` window with `50%` overlap would conceptually produce a new inference opportunity every approximately `1.0 s`, but this remains only an example until the final model configuration is frozen. *(`%50` overlap kullanan `2.0 s` pencere kavramsal olarak yaklaşık her `1.0 s` değerinde yeni çıkarım fırsatı üretir ancak nihai model yapılandırması sabitlenene kadar bu yalnızca örnek olarak kalır.)*

---

# 81. Dedicated Execution Context (Özel Çalıştırma Context'i)

AI inference will not execute heavy numerical work directly on the Flutter UI thread. *(Yapay zekâ çıkarımı ağır sayısal çalışmayı doğrudan Flutter UI thread'i üzerinde çalıştırmayacaktır.)*

---

# 82. Kotlin Execution Context (Kotlin Çalıştırma Context'i)

The native runtime may use a dedicated coroutine dispatcher, executor, or runtime-supported asynchronous mechanism depending on the selected LiteRT API and profiling results. *(Native runtime seçilen LiteRT API'sine ve profiling sonuçlarına bağlı olarak özel coroutine dispatcher, executor veya runtime tarafından desteklenen asynchronous mekanizma kullanabilir.)*

---

# 83. Single Inference Serialization Candidate (Tek Çıkarım Serialization Adayı)

For a small continuously reused model, a serialized inference queue is the preferred initial design unless the runtime explicitly supports safe beneficial concurrent execution. *(Küçük sürekli yeniden kullanılan model için runtime açık şekilde güvenli ve faydalı concurrent execution desteklemedikçe serialize edilmiş çıkarım kuyruğu tercih edilen ilk tasarımdır.)*

---

# 84. No Unbounded Inference Queue (Sınırsız Çıkarım Kuyruğu Olmaması)

Inference requests must never accumulate in an unbounded queue. *(Çıkarım istekleri hiçbir zaman sınırsız kuyrukta birikmemelidir.)*

---

# 85. Backpressure Policy (Backpressure Politikası)

If Motion Classification inference falls behind, obsolete pending windows may be dropped according to a frozen policy. *(Hareket Sınıflandırma çıkarımı geride kalırsa eski bekleyen pencereler sabitlenmiş politikaya göre düşürülebilir.)*

Current navigation context is generally more valuable than processing a long backlog of old windows. *(Mevcut navigasyon bağlamı genellikle uzun eski pencere backlog'unu işlemekten daha değerlidir.)*

---

# 86. Drop Accounting (Drop Sayımı)

Every dropped inference opportunity will increment an observable counter. *(Her düşürülen çıkarım fırsatı gözlemlenebilir counter'ı artıracaktır.)*

---

# 87. Prediction Timestamp (Tahmin Zaman Damgası)

The prediction will preserve the model window's reference timestamp rather than using only inference-completion time. *(Tahmin yalnızca çıkarım tamamlanma zamanını kullanmak yerine model penceresinin referans zaman damgasını koruyacaktır.)*

---

# 88. Inference Completion Timestamp (Çıkarım Tamamlanma Zaman Damgası)

The runtime may additionally record inference start and completion timestamps. *(Runtime ayrıca çıkarım başlangıç ve tamamlanma zaman damgalarını kaydedebilir.)*

---

# 89. Motion Inference Result (Hareket Çıkarım Sonucu)

```text
MotionInferenceResult
- predictionId
- windowStartNs
- windowEndNs
- inferenceStartNs
- inferenceEndNs
- modelId
- modelVersion
- predictedClass
- confidence
- classScores
- qualityState
- delegate
```

---

# 90. Step Length Inference Result (Adım Uzunluğu Çıkarım Sonucu)

```text
StepLengthInferenceResult
- predictionId
- stepId
- stepTimestampNs
- inferenceStartNs
- inferenceEndNs
- methodId
- modelId
- predictedLengthM
- uncertaintyVariance
- qualityState
- fallbackUsed
```

---

# 91. Output Validation Before Domain Publication (Domain'e Yayınlamadan Önce Çıktı Doğrulama)

Raw model output will never be sent directly to PDR or EKF without validation. *(Ham model çıktısı doğrulamadan hiçbir zaman doğrudan PDR veya EKF'ye gönderilmeyecektir.)*

---

# 92. Motion Output Validation (Hareket Çıktısı Doğrulama)

Motion output must contain a valid class index or class representation. *(Hareket çıktısı geçerli sınıf indeksi veya sınıf temsili içermelidir.)*

All expected scores must be finite. *(Beklenen tüm skorlar sonlu olmalıdır.)*

---

# 93. Step Length Output Validation (Adım Uzunluğu Çıktısı Doğrulama)

Step Length output must be finite and pass the frozen plausibility policy. *(Adım Uzunluğu çıktısı sonlu olmalı ve sabitlenmiş makullük politikasını geçmelidir.)*

---

# 94. NaN / Infinity Policy (NaN / Sonsuzluk Politikası)

NaN or infinite output immediately invalidates that inference result. *(NaN veya sonsuz çıktı ilgili çıkarım sonucunu anında geçersiz kılar.)*

---

# 95. Invalid Model Output Does Not Crash Navigation (Geçersiz Model Çıktısı Navigasyonu Çökertmez)

A single invalid inference will trigger fallback behavior rather than terminating the complete navigation session. *(Tek geçersiz çıkarım tam navigasyon oturumunu sonlandırmak yerine geri dönüş davranışı tetikleyecektir.)*

---

# 96. Temporal Postprocessing (Zamansal Son İşleme)

Motion Classification results may pass through the frozen confidence gate and causal temporal smoothing policy. *(Hareket Sınıflandırma sonuçları sabitlenmiş güven kapısı ve nedensel zamansal smoothing politikasından geçebilir.)*

---

# 97. Runtime Does Not Redefine Model Classes (Runtime Model Sınıflarını Yeniden Tanımlamaz)

Deployment postprocessing may stabilize predictions but will not secretly alter the semantic definitions of `STATIONARY`, `WALKING`, `RUNNING`, or `TURNING`. *(Deployment son işleme tahminleri kararlı hale getirebilir ancak `STATIONARY`, `WALKING`, `RUNNING` veya `TURNING` sınıflarının semantik tanımlarını gizlice değiştirmeyecektir.)*

---

# 98. Raw and Operational Predictions Are Separate (Ham ve Operasyonel Tahminler Ayrıdır)

NAVGUARD will distinguish the model's raw prediction from the accepted operational motion context. *(NAVGUARD modelin ham tahminini kabul edilmiş operasyonel hareket bağlamından ayıracaktır.)*

---

# 99. Shadow Mode (Shadow Mode)

A deployment candidate will first operate in Shadow Mode on the physical phone. *(Bir deployment adayı önce fiziksel telefonda Shadow Mode içerisinde çalışacaktır.)*

Predictions will be generated and logged but will not affect navigation state. *(Tahminler üretilecek ve kaydedilecek ancak navigasyon durumunu etkilemeyecektir.)*

---

# 100. Shadow Mode Objectives (Shadow Mode Hedefleri)

Shadow Mode will verify runtime stability. *(Shadow Mode runtime kararlılığını doğrulayacaktır.)*

It will verify real-world preprocessing behavior. *(Gerçek dünya ön işleme davranışını doğrulayacaktır.)*

It will verify latency and prediction timing. *(Gecikme ve tahmin zamanlamasını doğrulayacaktır.)*

---

# 101. Navigation Enablement Requires Shadow Success (Navigasyon Etkinleştirme Shadow Başarısı Gerektirir)

A candidate model will not become `NAVIGATION_ENABLED` until required Shadow Mode validation has passed. *(Aday model gerekli Shadow Mode doğrulamasını geçene kadar `NAVIGATION_ENABLED` olmayacaktır.)*

---

# 102. CPU Baseline (CPU Temeli)

The first formal mobile inference benchmark will use CPU execution. *(İlk resmî mobil çıkarım benchmark'ı CPU çalıştırmayı kullanacaktır.)*

This produces the simplest initial hardware baseline. *(Bu en basit ilk donanım temelini üretir.)*

---

# 103. Why CPU First (Neden Önce CPU)

NAVGUARD's candidate models are expected to be small compared with large vision or generative models. *(NAVGUARD aday modellerinin büyük vision veya generative modellere göre küçük olması beklenmektedir.)*

Hardware acceleration will therefore be justified by measurement rather than assumed to be necessary. *(Bu nedenle donanım hızlandırma gerekli varsayılmak yerine ölçümle gerekçelendirilecektir.)*

---

# 104. CompiledModel Hardware Acceleration (CompiledModel Donanım Hızlandırma)

Google documents the LiteRT `CompiledModel` API as supporting streamlined execution across CPU, GPU, and NPU backends. *(Google LiteRT `CompiledModel` API'sini CPU, GPU ve NPU backend'leri genelinde kolaylaştırılmış çalıştırmayı destekleyen API olarak dokümante etmektedir.)*

---

# 105. GPU Candidate (GPU Adayı)

GPU acceleration may be benchmarked after the CPU baseline. *(GPU hızlandırma CPU temelinden sonra benchmark edilebilir.)*

Google documents GPU execution support for LiteRT and also provides GPU paths for the newer CompiledModel API. *(Google LiteRT için GPU çalıştırma desteğini dokümante etmekte ve daha yeni CompiledModel API'si için de GPU yolları sağlamaktadır.)*

---

# 106. GPU Is Not Automatically Better (GPU Otomatik Olarak Daha İyi Değildir)

A very small time-series model may execute faster or more efficiently on CPU once GPU initialization and synchronization costs are considered. *(Çok küçük zaman serisi modeli GPU initialization ve synchronization maliyetleri dikkate alındığında CPU üzerinde daha hızlı veya verimli çalışabilir.)*

NAVGUARD will therefore benchmark the actual model on the actual phone. *(Bu nedenle NAVGUARD gerçek modeli gerçek telefon üzerinde benchmark edecektir.)*

---

# 107. NPU Candidate (NPU Adayı)

NPU execution is optional and will be considered only if the actual Redmi Note 9 Pro runtime path supports the chosen model reliably. *(NPU çalıştırma isteğe bağlıdır ve yalnızca gerçek Redmi Note 9 Pro runtime yolu seçilen modeli güvenilir şekilde desteklerse değerlendirilecektir.)*

Google's current LiteRT architecture includes NPU support through accelerator-specific paths, including Qualcomm-oriented support in the CompiledModel ecosystem. *(Google'ın mevcut LiteRT mimarisi CompiledModel ekosistemindeki Qualcomm odaklı destek dahil accelerator-specific yollar üzerinden NPU desteği içermektedir.)*

---

# 108. NPU Support Is Not Assumed from SoC Name (NPU Desteği SoC Adından Varsayılmaz)

The presence of a Qualcomm chipset does not by itself prove that NAVGUARD's selected Android runtime, device software, and model can use an NPU path successfully. *(Qualcomm chipset bulunması kendi başına NAVGUARD'ın seçilen Android runtime'ının, cihaz yazılımının ve modelinin NPU yolunu başarıyla kullanabileceğini kanıtlamaz.)*

Physical runtime validation is mandatory. *(Fiziksel runtime doğrulaması zorunludur.)*

---

# 109. Delegate Selection Rule (Delegate Seçim Kuralı)

The final execution backend will be selected using measured latency, stability, memory, battery, thermal behavior, and implementation complexity. *(Nihai çalıştırma backend'i ölçülmüş gecikme, kararlılık, bellek, batarya, termal davranış ve uygulama karmaşıklığı kullanılarak seçilecektir.)*

---

# 110. Delegate Identity Must Be Logged (Delegate Kimliği Kaydedilmelidir)

Every formal inference benchmark will record which backend or delegate was used. *(Her resmî çıkarım benchmark'ı hangi backend veya delegate'in kullanıldığını kaydedecektir.)*

---

# 111. Delegate Fallback (Delegate Geri Dönüşü)

If an optional accelerated backend fails to initialize, the runtime may fall back to CPU if the model remains compatible and the benchmark profile permits fallback. *(İsteğe bağlı hızlandırılmış backend başlatılamazsa model uyumlu kalır ve benchmark profili geri dönüşe izin verirse runtime CPU'ya geri dönebilir.)*

---

# 112. Benchmark Mode Delegate Strictness (Benchmark Modu Delegate Katılığı)

A formal delegate comparison must not silently fall back from GPU or NPU to CPU and then report the result as accelerated inference. *(Resmî delegate karşılaştırması GPU veya NPU'dan CPU'ya sessizce geri dönüp sonucu hızlandırılmış çıkarım olarak raporlamamalıdır.)*

---

# 113. Runtime Backend State (Runtime Backend Durumu)

```text
requestedBackend
actualBackend
fallbackOccurred
fallbackReason
```

These fields will be preserved in benchmark evidence. *(Bu alanlar benchmark kanıtında korunacaktır.)*

---

# 114. Quantization Objective (Quantization Hedefi)

Quantization may reduce model size, memory cost, or inference latency. *(Quantization model boyutunu, bellek maliyetini veya çıkarım gecikmesini azaltabilir.)*

It will not be enabled automatically. *(Otomatik olarak etkinleştirilmeyecektir.)*

---

# 115. Floating-Point Reference First (Önce Floating-Point Referans)

A stable floating-point deployment model will be established before quantization experiments. *(Quantization deneylerinden önce kararlı floating-point deployment modeli oluşturulacaktır.)*

---

# 116. Quantized Model Is a Separate Artifact (Quantize Model Ayrı Artifact'tır)

Every quantized variant will receive its own model version, file hash, evaluation results, and parity evidence. *(Her quantize varyant kendi model sürümünü, dosya hash'ini, değerlendirme sonuçlarını ve eşdeğerlik kanıtını alacaktır.)*

---

# 117. Representative Dataset Requirement (Representative Dataset Gereksinimi)

If a quantization method requires representative calibration data, that data will come from the training or development portion only. *(Quantization yöntemi representative kalibrasyon verisi gerektirirse bu veri yalnızca training veya development bölümünden gelecektir.)*

Final test data will not be used to calibrate quantization. *(Nihai test verisi quantization kalibrasyonu için kullanılmayacaktır.)*

---

# 118. Quantization Evaluation Dimensions (Quantization Değerlendirme Boyutları)

The quantized candidate will be evaluated for predictive quality. *(Quantize aday tahmin kalitesi açısından değerlendirilecektir.)*

It will be evaluated for size and latency. *(Boyut ve gecikme açısından değerlendirilecektir.)*

It will be evaluated for mobile stability. *(Mobil kararlılık açısından değerlendirilecektir.)*

---

# 119. Quantization Retention Rule (Quantization Koruma Kuralı)

A quantized model will be retained only if the resource benefit justifies any predictive degradation and additional deployment complexity. *(Quantize model yalnızca kaynak faydası herhangi bir tahmin bozulmasını ve ek deployment karmaşıklığını gerekçelendirirse korunacaktır.)*

---

# 120. Inference Latency Definition (Çıkarım Gecikmesi Tanımı)

Model execution latency will be measured from immediately before runtime invocation to completion of model output availability. *(Model çalıştırma gecikmesi runtime invocation'dan hemen önce model çıktısının kullanılabilir hale gelmesine kadar ölçülecektir.)*

---

# 121. Model Latency Formula (Model Gecikme Formülü)

```text
latency_model =
t_model_output -
t_model_invoke
```

---

# 122. Preprocessing Latency (Ön İşleme Gecikmesi)

Preprocessing latency will be measured separately when useful. *(Ön işleme gecikmesi kullanışlı olduğunda ayrı ölçülecektir.)*

---

# 123. End-to-End AI Latency (Uçtan Uca Yapay Zekâ Gecikmesi)

```text
latency_e2e =
t_operational_result -
t_window_ready
```

This metric includes preprocessing, model execution, output validation, and required postprocessing. *(Bu metrik ön işlemeyi, model çalıştırmayı, çıktı doğrulamayı ve gerekli son işlemeyi içerir.)*

---

# 124. Window Formation Delay Is Separate (Pencere Oluşturma Gecikmesi Ayrıdır)

A two-second model window inherently requires temporal evidence spanning two seconds, which is different from computational inference latency. *(İki saniyelik model penceresi doğası gereği iki saniyeye yayılan zamansal kanıt gerektirir ve bu hesaplama çıkarım gecikmesinden farklıdır.)*

The report will distinguish these concepts. *(Rapor bu kavramları ayıracaktır.)*

---

# 125. Provisional Model Latency Target (Geçici Model Gecikme Hedefi)

The project target remains less than `50 ms` per Motion Classification inference on the Redmi Note 9 Pro. *(Proje hedefi Redmi Note 9 Pro üzerinde Hareket Sınıflandırma çıkarımı başına `50 ms` altı olarak kalmaktadır.)*

This remains a target until measured. *(Bu ölçülene kadar hedef olarak kalır.)*

---

# 126. Latency Distribution (Gecikme Dağılımı)

Formal benchmarks will not rely only on one inference or only on the arithmetic mean. *(Resmî benchmark'lar yalnızca tek çıkarıma veya yalnızca aritmetik ortalamaya dayanmayacaktır.)*

Median and upper-percentile latency should be retained. *(Medyan ve üst yüzdelik gecikme korunmalıdır.)*

---

# 127. Recommended Latency Statistics (Önerilen Gecikme İstatistikleri)

```text
count
mean
median
P90
P95
maximum
```

---

# 128. Warm and Cold Measurements (Warm ve Cold Ölçümler)

Startup or cold-load latency will be reported separately from steady-state inference where relevant. *(Başlangıç veya cold-load gecikmesi ilgili olduğunda steady-state çıkarımdan ayrı raporlanacaktır.)*

---

# 129. Sustained Runtime Benchmark (Sürekli Runtime Benchmark)

The model will run repeatedly during a representative navigation session. *(Model temsili navigasyon oturumu sırasında tekrar tekrar çalışacaktır.)*

This test will look for latency drift, queue growth, memory growth, exceptions, and thermal degradation. *(Bu test gecikme drift'ini, kuyruk büyümesini, bellek büyümesini, exception'ları ve termal bozulmayı inceleyecektir.)*

---

# 130. Combined Stack Benchmark (Birleşik Yığın Benchmark'ı)

Final Edge AI performance will be tested while sensor acquisition, logging, PDR, heading, and selected fusion components are running. *(Nihai Edge AI performansı sensör toplama, logging, PDR, yön ve seçilen füzyon bileşenleri çalışırken test edilecektir.)*

---

# 131. ARCore Combined Benchmark (ARCore Birleşik Benchmark)

If the target full configuration includes ARCore, AI runtime will also be tested while ARCore tracking is active. *(Hedef tam yapılandırma ARCore içeriyorsa yapay zekâ runtime'ı ARCore tracking aktifken de test edilecektir.)*

---

# 132. Debug Builds Are Not Performance Evidence (Debug Build'ler Performans Kanıtı Değildir)

Final latency conclusions will use profile or release-like builds rather than relying only on Flutter or Android debug execution. *(Nihai gecikme sonuçları yalnızca Flutter veya Android debug çalışmasına dayanmak yerine profile veya release benzeri build'leri kullanacaktır.)*

---

# 133. Performance Benchmark Tooling (Performans Benchmark Araçları)

Android timing instrumentation, profiler tools, application logs, and LiteRT-compatible benchmarking approaches may be used. *(Android zamanlama instrumentation'ı, profiler araçları, uygulama logları ve LiteRT uyumlu benchmark yaklaşımları kullanılabilir.)*

Google also documents dedicated LiteRT performance measurement and benchmark tooling. *(Google ayrıca özel LiteRT performans ölçüm ve benchmark araçlarını dokümante etmektedir.)*

---

# 134. CPU Usage Measurement (CPU Kullanım Ölçümü)

CPU utilization will be observed during sustained AI-enabled navigation. *(CPU kullanımı sürekli yapay zekâ etkin navigasyon sırasında gözlemlenecektir.)*

---

# 135. Memory Measurement (Bellek Ölçümü)

Runtime memory behavior will be monitored for stable allocation after model initialization. *(Runtime bellek davranışı model başlatma sonrasında kararlı allocation açısından izlenecektir.)*

---

# 136. No Growing Prediction History in Runtime (Runtime'ta Büyüyen Tahmin Geçmişi Olmaması)

The runtime will not keep every historical tensor and prediction in memory. *(Runtime her geçmiş tensor ve tahmini bellekte tutmayacaktır.)*

Persistent evidence belongs to the logging subsystem. *(Kalıcı kanıt logging alt sistemine aittir.)*

---

# 137. Battery Evaluation (Batarya Değerlendirmesi)

AI-enabled and comparable AI-disabled sessions may be compared for battery consumption where practical. *(Yapay zekâ etkin ve karşılaştırılabilir yapay zekâsız oturumlar uygulanabilir olduğunda batarya tüketimi açısından karşılaştırılabilir.)*

---

# 138. Thermal Evaluation (Termal Değerlendirme)

Longer combined sessions will inspect whether the selected backend contributes to thermal throttling or unstable latency. *(Daha uzun birleşik oturumlar seçilen backend'in thermal throttling veya kararsız gecikmeye katkıda bulunup bulunmadığını inceleyecektir.)*

---

# 139. Performance Optimization Order (Performans Optimizasyon Sırası)

NAVGUARD will optimize architecture only after profiling identifies a real bottleneck. *(NAVGUARD yalnızca profiling gerçek bottleneck belirledikten sonra mimariyi optimize edecektir.)*

---

# 140. Optimization Priority (Optimizasyon Önceliği)

The preferred optimization sequence is to eliminate unnecessary allocation and duplicate work first. *(Tercih edilen optimizasyon sırası önce gereksiz allocation ve duplicate çalışmayı ortadan kaldırmaktır.)*

Hardware delegate changes come later if still useful. *(Hâlâ kullanışlıysa donanım delegate değişiklikleri daha sonra gelir.)*

---

# 141. Prediction Freshness (Tahmin Güncelliği)

The navigation controller will evaluate prediction age before applying a result. *(Navigasyon controller'ı sonucu uygulamadan önce tahmin yaşını değerlendirecektir.)*

---

# 142. Freshness Formula (Güncellik Formülü)

```text
predictionAge =
t_current -
t_prediction_reference
```

---

# 143. Stale Prediction Policy (Eski Tahmin Politikası)

A prediction older than the frozen operational maximum age will not alter current motion context. *(Sabitlenmiş operasyonel maksimum yaştan daha eski tahmin mevcut hareket bağlamını değiştirmeyecektir.)*

---

# 144. Stale Prediction Logging (Eski Tahmin Kaydı)

Stale results may still be logged for diagnosis. *(Eski sonuçlar tanı amacıyla yine de kaydedilebilir.)*

---

# 145. Out-of-Order Result Policy (Sıra Dışı Sonuç Politikası)

An older completed inference must not overwrite a newer accepted operational prediction. *(Daha eski tamamlanmış çıkarım daha yeni kabul edilmiş operasyonel tahminin üzerine yazmamalıdır.)*

---

# 146. Prediction Sequence Number (Tahmin Sequence Number)

Inference requests and results may carry monotonically increasing sequence numbers to help enforce ordering. *(Çıkarım istekleri ve sonuçları sıralamayı uygulamaya yardımcı olmak için monotonik artan sequence number taşıyabilir.)*

---

# 147. Failure Isolation Principle (Hata İzolasyonu İlkesi)

AI is an enhancement layer and must not become a single point of failure for baseline navigation. *(Yapay zekâ iyileştirme katmanıdır ve temel navigasyon için single point of failure haline gelmemelidir.)*

---

# 148. Model Load Failure Behavior (Model Yükleme Hatası Davranışı)

If the Motion Classification model cannot be loaded, deterministic motion logic remains available. *(Hareket Sınıflandırma modeli yüklenemezse deterministik hareket mantığı kullanılabilir kalır.)*

---

# 149. Step Length Model Failure Behavior (Adım Uzunluğu Model Hatası Davranışı)

If a learned Step Length model cannot be loaded, NAVGUARD falls back to the deterministic variable-step estimator and then the calibrated fixed-step method. *(Öğrenilmiş Adım Uzunluğu modeli yüklenemezse NAVGUARD deterministik değişken adım tahmin motoruna ve ardından kalibre edilmiş sabit adım yöntemine geri döner.)*

---

# 150. Runtime Exception Policy (Runtime Exception Politikası)

Recoverable inference exceptions will be captured and converted into structured AI runtime errors. *(Kurtarılabilir çıkarım exception'ları yakalanacak ve yapılandırılmış yapay zekâ runtime hatalarına dönüştürülecektir.)*

---

# 151. No Silent Failure (Sessiz Hata Olmaması)

The runtime must not silently stop producing predictions while reporting `ACTIVE`. *(Runtime `ACTIVE` raporlarken sessizce tahmin üretmeyi durdurmamalıdır.)*

---

# 152. Runtime Watchdog Candidate (Runtime Watchdog Adayı)

The AI health component may detect missing predictions beyond an expected interval while input windows remain available. *(Yapay zekâ health bileşeni girdi pencereleri kullanılabilir kalırken beklenen aralığın ötesinde eksik tahminleri tespit edebilir.)*

---

# 153. AI Error Codes (Yapay Zekâ Hata Kodları)

```text
AI_MODEL_FILE_MISSING
AI_MODEL_HASH_MISMATCH
AI_METADATA_MISSING
AI_METADATA_INVALID
AI_RUNTIME_INIT_FAILED
AI_INPUT_SCHEMA_MISMATCH
AI_OUTPUT_SCHEMA_MISMATCH
AI_PREPROCESSING_FAILED
AI_INPUT_WINDOW_INVALID
AI_INFERENCE_FAILED
AI_OUTPUT_INVALID
AI_RESULT_STALE
AI_QUEUE_OVERFLOW
AI_BACKEND_FALLBACK
AI_PARITY_FAILED
```

---

# 154. Hash Mismatch Is Critical (Hash Uyuşmazlığı Kritiktir)

A hash mismatch in Benchmark Mode will prevent the model from being treated as the declared benchmark artifact. *(Benchmark Modu içerisinde hash uyuşmazlığı modelin tanımlanan benchmark artifact'ı olarak ele alınmasını engelleyecektir.)*

---

# 155. Metadata Mismatch Is Critical (Metadata Uyuşmazlığı Kritiktir)

A model whose tensor schema conflicts with its metadata will not be executed for navigation. *(Tensor şeması metadata bilgisiyle çelişen model navigasyon için çalıştırılmayacaktır.)*

---

# 156. Input Window Invalidity (Girdi Penceresi Geçersizliği)

A Motion Classification window with excessive sensor gaps or missing mandatory channels will be rejected before inference. *(Aşırı sensör boşluklarına veya eksik zorunlu kanallara sahip Hareket Sınıflandırma penceresi çıkarımdan önce reddedilecektir.)*

---

# 157. Fallback Events Are Observable (Geri Dönüş Olayları Gözlemlenebilir)

Every runtime fallback should produce structured logging evidence. *(Her runtime geri dönüşü yapılandırılmış logging kanıtı üretmelidir.)*

---

# 158. Runtime Logging (Runtime Logging)

Formal AI deployment logs will record model identity, inference timing, output summary, runtime backend, and health state. *(Resmî yapay zekâ deployment logları model kimliğini, çıkarım zamanlamasını, çıktı özetini, runtime backend'ini ve health durumunu kaydedecektir.)*

---

# 159. Motion Inference Log Candidate (Hareket Çıkarım Log Adayı)

```text
prediction_id,
window_start_ns,
window_end_ns,
model_id,
model_version,
predicted_class,
confidence,
inference_latency_us,
actual_backend,
quality_state,
accepted_operationally
```

---

# 160. Full Probability Logging Policy (Tam Olasılık Logging Politikası)

Development sessions may store the complete class-score vector. *(Development oturumları tam sınıf skor vektörünü saklayabilir.)*

Formal logging policy may retain it when storage overhead remains negligible. *(Resmî logging politikası depolama yükü ihmal edilebilir kaldığında bunu koruyabilir.)*

---

# 161. Runtime Statistics (Runtime İstatistikleri)

```text
inferenceCount
inferenceFailureCount
invalidInputCount
staleResultCount
droppedWindowCount
backendFallbackCount
meanLatency
medianLatency
p95Latency
```

---

# 162. Session Manifest AI Fields (Oturum Manifest Yapay Zekâ Alanları)

```text
aiEnabled
motionModelId
motionModelVersion
motionModelHash
stepLengthModelId
stepLengthModelVersion
runtimeApi
requestedBackend
actualBackend
quantizationMode
preprocessingVersion
```

---

# 163. Flutter Result Boundary (Flutter Sonuç Sınırı)

Flutter will receive compact immutable AI-domain snapshots. *(Flutter kompakt değişmez yapay zekâ domain anlık görüntülerini alacaktır.)*

It will not receive model tensors unless a dedicated diagnostic tool explicitly requests them. *(Özel diagnostic araç açıkça istemedikçe model tensor'larını almayacaktır.)*

---

# 164. Flutter Motion Snapshot Candidate (Flutter Hareket Anlık Görüntü Adayı)

```text
MotionAiState
- timestampNs
- motionClass
- confidence
- quality
- modelVersion
- inferenceLatency
- runtimeState
```

---

# 165. Flutter Is Not the Inference Authority (Flutter Çıkarım Otoritesi Değildir)

The native AI runtime remains authoritative for model execution state. *(Native yapay zekâ runtime'ı model çalıştırma durumu için otorite olarak kalır.)*

Flutter mirrors that state for UI and application orchestration. *(Flutter bu durumu UI ve uygulama orkestrasyonu için yansıtır.)*

---

# 166. UI Refresh Rate Is Independent (UI Yenileme Hızı Bağımsızdır)

The UI does not need to redraw at the sensor sampling rate or every numerical internal update. *(UI sensör örnekleme hızında veya her sayısal internal update'te yeniden çizilmek zorunda değildir.)*

---

# 167. Diagnostic UI (Diagnostic UI)

Development diagnostics may show current motion class, confidence, model identity, backend, inference latency, and runtime health. *(Development diagnostics mevcut hareket sınıfını, güveni, model kimliğini, backend'i, çıkarım gecikmesini ve runtime health durumunu gösterebilir.)*

---

# 168. Diagnostic UI Must Reuse Existing Inference (Diagnostic UI Mevcut Çıkarımı Yeniden Kullanmalıdır)

Opening an AI monitor screen must not create a second copy of the model runtime solely for display. *(Yapay zekâ monitor ekranını açmak yalnızca görüntüleme için model runtime'ının ikinci kopyasını oluşturmamalıdır.)*

---

# 169. Shadow Mode UI (Shadow Mode UI)

Shadow Mode may display both deterministic motion context and AI-predicted context for debugging. *(Shadow Mode debugging için hem deterministik hareket bağlamını hem yapay zekâ tahminli bağlamı gösterebilir.)*

---

# 170. Production UI Simplicity (Production UI Basitliği)

Normal navigation UI will not expose low-level tensor or delegate details to the end user. *(Normal navigasyon UI'ı düşük seviyeli tensor veya delegate ayrıntılarını son kullanıcıya göstermeyecektir.)*

---

# 171. Model Update Policy (Model Güncelleme Politikası)

The research prototype will use application-controlled model artifacts rather than silently downloading replacement models during formal experiments. *(Araştırma prototipi resmî deneyler sırasında sessizce replacement model indirmek yerine uygulama kontrollü model artifact'ları kullanacaktır.)*

---

# 172. No Silent Remote Model Replacement (Sessiz Uzaktan Model Değiştirme Olmaması)

A benchmark model must remain unchanged throughout the formal benchmark cycle. *(Benchmark modeli resmî benchmark döngüsü boyunca değişmeden kalmalıdır.)*

---

# 173. New Model Means New Version (Yeni Model Yeni Sürüm Anlamına Gelir)

Any replacement model will receive a new version and explicit promotion cycle. *(Her replacement model yeni sürüm ve açık promotion döngüsü alacaktır.)*

---

# 174. No On-Device Retraining Requirement (Cihaz Üzeri Yeniden Eğitim Gereksinimi Olmaması)

NAVGUARD will not require full on-device model retraining. *(NAVGUARD tam cihaz üzeri model yeniden eğitimi gerektirmeyecektir.)*

Training remains an offline Python activity. *(Eğitim çevrimdışı Python aktivitesi olarak kalır.)*

---

# 175. No Hidden Evaluation Adaptation (Gizli Değerlendirme Adaptasyonu Olmaması)

Evaluation Mode GNSS ground truth cannot be used to update AI model weights, normalization statistics, or deployment thresholds during the protected denied interval. *(Evaluation Mode GNSS ground truth korunan kesintili aralık sırasında yapay zekâ model ağırlıklarını, normalizasyon istatistiklerini veya deployment eşiklerini güncellemek için kullanılamaz.)*

---

# 176. Ground Truth Firewall Applies to AI Deployment (Ground Truth Firewall Yapay Zekâ Deployment'a da Uygulanır)

The AI runtime must obey the same Ground Truth Firewall boundary as the rest of the estimator. *(Yapay zekâ runtime'ı tahmin motorunun geri kalanıyla aynı Ground Truth Firewall sınırına uymalıdır.)*

---

# 177. Forbidden Runtime AI Inputs (Yasak Runtime Yapay Zekâ Girdileri)

Live ground-truth GNSS latitude is forbidden as an AI feature during denied evaluation. *(Canlı ground truth GNSS enlemi kesintili değerlendirme sırasında yapay zekâ özelliği olarak yasaktır.)*

Live ground-truth GNSS longitude is forbidden. *(Canlı ground truth GNSS boylamı yasaktır.)*

Ground-truth GNSS speed or displacement is also forbidden if it can affect denied navigation. *(Ground truth GNSS hızı veya yer değiştirmesi kesintili navigasyonu etkileyebiliyorsa o da yasaktır.)*

---

# 178. Offline Labels Remain Allowed (Çevrimdışı Etiketler İzinli Kalır)

Ground truth may still have been used during offline training-label generation where scientifically justified. *(Ground truth bilimsel olarak gerekçelendirildiğinde çevrimdışı eğitim etiketi üretiminde kullanılmış olabilir.)*

Deployment input and training-label construction remain separate concepts. *(Deployment girdisi ve eğitim etiketi oluşturma ayrı kavramlar olarak kalır.)*

---

# 179. Security of Model Files (Model Dosyalarının Güvenliği)

Model files will be treated as application artifacts rather than executable user-provided content. *(Model dosyaları kullanıcı tarafından sağlanan executable içerik yerine uygulama artifact'ları olarak ele alınacaktır.)*

---

# 180. Corrupted Model Handling (Bozuk Model Yönetimi)

A corrupted or truncated model file must fail validation safely. *(Bozuk veya kesilmiş model dosyası doğrulamada güvenli şekilde başarısız olmalıdır.)*

---

# 181. Privacy Benefit of Local AI (Yerel Yapay Zekânın Gizlilik Faydası)

Local inference avoids sending raw inertial navigation windows to a remote AI service during normal operation. *(Yerel çıkarım normal çalışma sırasında ham ataletsel navigasyon pencerelerini uzaktaki yapay zekâ servisine göndermeyi önler.)*

---

# 182. Resource Release (Kaynak Serbest Bırakma)

The AI runtime will provide an explicit disposal or shutdown path. *(Yapay zekâ runtime'ı açık disposal veya shutdown yolu sağlayacaktır.)*

---

# 183. Shutdown Sequence (Shutdown Sırası)

```text
Stop New Inference
(Yeni Çıkarımı Durdur)
        ↓
Drain / Cancel Pending Work
(Bekleyen İşi Tamamla / İptal Et)
        ↓
Flush Runtime Logs
(Runtime Loglarını Flush Et)
        ↓
Release Model Resources
(Model Kaynaklarını Serbest Bırak)
        ↓
DISPOSED
```

---

# 184. Session Stop Does Not Necessarily Destroy Global Runtime (Oturum Durdurmak Global Runtime'ı Mutlaka Yok Etmez)

The model may remain loaded between nearby sessions if the application lifecycle and memory policy permit it. *(Uygulama yaşam döngüsü ve bellek politikası izin verirse model yakın oturumlar arasında yüklü kalabilir.)*

Formal session inference state must nevertheless stop cleanly. *(Buna rağmen resmî oturum çıkarım durumu temiz şekilde durmalıdır.)*

---

# 185. Crash Recovery (Çökme Sonrası Kurtarma)

If the application terminates unexpectedly, the next launch will not assume the previous AI runtime remained valid. *(Uygulama beklenmedik şekilde sonlanırsa sonraki başlatma önceki yapay zekâ runtime'ının geçerli kaldığını varsaymayacaktır.)*

The runtime will be reinitialized and session recovery logic will handle the incomplete experiment separately. *(Runtime yeniden başlatılacak ve oturum kurtarma mantığı tamamlanmamış deneyi ayrı yönetecektir.)*

---

# 186. Live AI Profiles (Canlı Yapay Zekâ Profilleri)

```text
AI_DISABLED
AI_SHADOW
AI_ENABLED
AI_BENCHMARK
```

---

# 187. AI_DISABLED Profile (AI_DISABLED Profili)

No AI prediction affects navigation and inference may be completely disabled. *(Hiçbir yapay zekâ tahmini navigasyonu etkilemez ve çıkarım tamamen devre dışı olabilir.)*

---

# 188. AI_SHADOW Profile (AI_SHADOW Profili)

AI inference runs and is logged but navigation ignores its output. *(Yapay zekâ çıkarımı çalışır ve kaydedilir ancak navigasyon çıktıyı yok sayar.)*

---

# 189. AI_ENABLED Profile (AI_ENABLED Profili)

Validated predictions may affect their permitted navigation components. *(Doğrulanmış tahminler izin verilen navigasyon bileşenlerini etkileyebilir.)*

---

# 190. AI_BENCHMARK Profile (AI_BENCHMARK Profili)

Benchmark Mode freezes model identity, runtime configuration, backend, and logging requirements for formal performance measurement. *(Benchmark Modu resmî performans ölçümü için model kimliğini, runtime yapılandırmasını, backend'i ve logging gereksinimlerini sabitler.)*

---

# 191. Deployment Promotion Pipeline (Deployment Promotion Hattı)

```text
OFFLINE_VALIDATED
        ↓
EXPORT_VALIDATED
        ↓
PARITY_VALIDATED
        ↓
DEVICE_LOAD_VALIDATED
        ↓
SHADOW_VALIDATED
        ↓
RUNTIME_VALIDATED
        ↓
NAVIGATION_ENABLED
```

---

# 192. EXPORT_VALIDATED Gate (EXPORT_VALIDATED Kapısı)

The exported artifact must reproduce reference predictions acceptably. *(Export edilen artifact referans tahminlerini kabul edilebilir şekilde yeniden üretmelidir.)*

---

# 193. PARITY_VALIDATED Gate (PARITY_VALIDATED Kapısı)

Python and Android preprocessing and prediction parity tests must pass. *(Python ve Android ön işleme ve tahmin eşdeğerlik testleri geçmelidir.)*

---

# 194. DEVICE_LOAD_VALIDATED Gate (DEVICE_LOAD_VALIDATED Kapısı)

The target physical Redmi Note 9 Pro must successfully load the artifact. *(Hedef fiziksel Redmi Note 9 Pro artifact'ı başarıyla yüklemelidir.)*

---

# 195. SHADOW_VALIDATED Gate (SHADOW_VALIDATED Kapısı)

The model must produce stable live predictions without affecting navigation. *(Model navigasyonu etkilemeden kararlı canlı tahminler üretmelidir.)*

---

# 196. RUNTIME_VALIDATED Gate (RUNTIME_VALIDATED Kapısı)

Latency, memory, queue, sustained execution, and failure handling must satisfy the frozen requirements. *(Gecikme, bellek, kuyruk, sürekli çalıştırma ve hata yönetimi sabitlenmiş gereksinimleri karşılamalıdır.)*

---

# 197. Navigation Promotion Is Explicit (Navigasyon Promotion Açık Süreçtir)

No model automatically becomes navigation-enabled merely because a `.tflite` file exists in the application. *(Hiçbir model yalnızca uygulamada `.tflite` dosyası bulunduğu için otomatik olarak navigasyon etkin hale gelmez.)*

---

# 198. Motion AI Navigation Boundary (Hareket Yapay Zekâsı Navigasyon Sınırı)

Motion AI publishes validated motion context. *(Hareket yapay zekâsı doğrulanmış hareket bağlamını yayınlar.)*

It does not directly modify `E`, `N`, latitude, or longitude. *(Doğrudan `E`, `N`, enlem veya boylamı değiştirmez.)*

---

# 199. Step Length AI Navigation Boundary (Adım Uzunluğu Yapay Zekâsı Navigasyon Sınırı)

Step Length AI publishes `L_k`, quality, and validated uncertainty. *(Adım Uzunluğu yapay zekâsı `L_k`, kalite ve doğrulanmış belirsizliği yayınlar.)*

PDR and EKF remain responsible for applying the physical displacement model. *(PDR ve EKF fiziksel yer değiştirme modelini uygulamaktan sorumlu kalır.)*

---

# 200. AI Cannot Directly Correct Historical Trajectory (Yapay Zekâ Geçmiş Trajectory'yi Doğrudan Düzeltemez)

A late AI prediction will not retroactively rewrite historical navigation points during live operation. *(Geç yapay zekâ tahmini canlı çalışma sırasında geçmiş navigasyon noktalarını geriye dönük yeniden yazmayacaktır.)*

---

# 201. Replay May Recompute History (Replay Geçmişi Yeniden Hesaplayabilir)

Offline replay may intentionally recompute a trajectory under another model configuration for analysis. *(Çevrimdışı replay analiz için başka model yapılandırması altında trajectory'yi bilinçli olarak yeniden hesaplayabilir.)*

Replay output remains separate from immutable live-session evidence. *(Replay çıktısı değişmez canlı oturum kanıtından ayrı kalır.)*

---

# 202. Deterministic Replay Requirement (Deterministik Replay Gereksinimi)

Given the same recorded raw inputs, model artifact, preprocessing configuration, and postprocessing policy, replay should reproduce equivalent AI results within numerical tolerance. *(Aynı kaydedilmiş ham girdiler, model artifact'ı, ön işleme yapılandırması ve son işleme politikası verildiğinde replay sayısal tolerans içerisinde eşdeğer yapay zekâ sonuçları üretmelidir.)*

---

# 203. Edge AI Unit Test — Metadata (Edge AI Birim Testi — Metadata)

A known model metadata file must parse into the expected runtime configuration. *(Bilinen model metadata dosyası beklenen runtime yapılandırmasına parse edilmelidir.)*

---

# 204. Edge AI Unit Test — Hash (Edge AI Birim Testi — Hash)

A modified artifact must fail hash verification when strict verification is enabled. *(Değiştirilmiş artifact strict doğrulama etkin olduğunda hash doğrulamasını geçememelidir.)*

---

# 205. Edge AI Unit Test — Tensor Shape (Edge AI Birim Testi — Tensor Şekli)

A model with an unexpected input shape must fail initialization. *(Beklenmeyen girdi şekline sahip model initialization'da başarısız olmalıdır.)*

---

# 206. Edge AI Unit Test — Channel Order (Edge AI Birim Testi — Kanal Sırası)

Known raw samples must enter the tensor in the exact declared order. *(Bilinen ham örnekler tensor'a tam olarak tanımlanan sırada girmelidir.)*

---

# 207. Edge AI Unit Test — Normalization (Edge AI Birim Testi — Normalizasyon)

Known channel values must produce expected normalized values. *(Bilinen kanal değerleri beklenen normalize edilmiş değerleri üretmelidir.)*

---

# 208. Edge AI Unit Test — Invalid Input (Edge AI Birim Testi — Geçersiz Girdi)

A window with missing mandatory data must not invoke the model as if valid. *(Eksik zorunlu veriye sahip pencere geçerliymiş gibi modeli invoke etmemelidir.)*

---

# 209. Edge AI Unit Test — Class Mapping (Edge AI Birim Testi — Sınıf Eşleme)

Known output index `i` must map to the exact class defined by model metadata. *(Bilinen `i` çıktı indeksi model metadata bilgisi tarafından tanımlanan kesin sınıfa eşlenmelidir.)*

---

# 210. Edge AI Unit Test — NaN Output (Edge AI Birim Testi — NaN Çıktı)

A synthetic invalid model result must trigger rejection and fallback. *(Sentetik geçersiz model sonucu reddetmeyi ve geri dönüşü tetiklemelidir.)*

---

# 211. Edge AI Integration Test — Model Load (Edge AI Entegrasyon Testi — Model Yükleme)

The final artifact must load successfully on the Redmi Note 9 Pro. *(Nihai artifact Redmi Note 9 Pro üzerinde başarıyla yüklenmelidir.)*

---

# 212. Edge AI Integration Test — Reuse (Edge AI Entegrasyon Testi — Yeniden Kullanım)

Repeated inference must reuse the loaded runtime rather than recreating it per request. *(Tekrarlanan çıkarım yüklü runtime'ı yeniden kullanmalı ve istek başına yeniden oluşturmamalıdır.)*

---

# 213. Edge AI Integration Test — Tensor Parity (Edge AI Entegrasyon Testi — Tensor Eşdeğerliği)

Golden validation examples must pass Python-to-Android preprocessing parity. *(Golden validation örnekleri Python-Android ön işleme eşdeğerliğini geçmelidir.)*

---

# 214. Edge AI Integration Test — Output Parity (Edge AI Entegrasyon Testi — Çıktı Eşdeğerliği)

Golden validation examples must pass reference-to-Android prediction parity. *(Golden validation örnekleri referans-Android tahmin eşdeğerliğini geçmelidir.)*

---

# 215. Edge AI Integration Test — Ordering (Edge AI Entegrasyon Testi — Sıralama)

Delayed older results must not replace newer accepted predictions. *(Gecikmiş eski sonuçlar daha yeni kabul edilmiş tahminlerin yerini almamalıdır.)*

---

# 216. Edge AI Integration Test — Backpressure (Edge AI Entegrasyon Testi — Backpressure)

Artificially slow inference must not create an unbounded queue. *(Yapay olarak yavaşlatılmış çıkarım sınırsız kuyruk oluşturmamalıdır.)*

---

# 217. Edge AI Integration Test — Fallback (Edge AI Entegrasyon Testi — Geri Dönüş)

A deliberately failed model initialization must leave deterministic navigation functional. *(Bilinçli olarak başarısız model initialization deterministik navigasyonu çalışır durumda bırakmalıdır.)*

---

# 218. Edge AI Integration Test — Shadow Mode (Edge AI Entegrasyon Testi — Shadow Mode)

Shadow Mode must produce predictions without changing active navigation behavior. *(Shadow Mode aktif navigasyon davranışını değiştirmeden tahmin üretmelidir.)*

---

# 219. Edge AI Integration Test — Enabled Mode (Edge AI Entegrasyon Testi — Enabled Mode)

Enabled Mode must permit only documented AI effects to reach navigation. *(Enabled Mode yalnızca dokümante edilmiş yapay zekâ etkilerinin navigasyona ulaşmasına izin vermelidir.)*

---

# 220. Edge AI Performance Test — CPU (Edge AI Performans Testi — CPU)

The final candidate will receive a sustained CPU benchmark. *(Nihai aday sürekli CPU benchmark'ı alacaktır.)*

---

# 221. Edge AI Performance Test — GPU (Edge AI Performans Testi — GPU)

GPU will be benchmarked only if applicable and useful. *(GPU yalnızca uygulanabilir ve kullanışlıysa benchmark edilecektir.)*

---

# 222. Edge AI Performance Test — Optional NPU (Edge AI Performans Testi — İsteğe Bağlı NPU)

NPU will be benchmarked only if the physical device and runtime expose a reliable supported path. *(NPU yalnızca fiziksel cihaz ve runtime güvenilir desteklenen yol sunarsa benchmark edilecektir.)*

---

# 223. Backend Comparison Integrity (Backend Karşılaştırma Bütünlüğü)

CPU, GPU, and optional NPU tests must use the same model artifact or clearly documented equivalent variants. *(CPU, GPU ve isteğe bağlı NPU testleri aynı model artifact'ını veya açıkça dokümante edilmiş eşdeğer varyantları kullanmalıdır.)*

---

# 224. Edge AI Performance Test — Combined Runtime (Edge AI Performans Testi — Birleşik Runtime)

AI will be benchmarked while the normal NAVGUARD navigation stack is active. *(Yapay zekâ normal NAVGUARD navigasyon yığını aktifken benchmark edilecektir.)*

---

# 225. Edge AI Performance Test — Thermal (Edge AI Performans Testi — Termal)

A sustained session will evaluate latency stability as device temperature changes. *(Sürekli oturum cihaz sıcaklığı değişirken gecikme kararlılığını değerlendirecektir.)*

---

# 226. Edge AI Test IDs (Edge AI Test ID'leri)

```text
EDGE-MDL-001   Artifact exists
EDGE-MDL-002   Hash verification
EDGE-MDL-003   Metadata validation
EDGE-MDL-004   Tensor schema validation

EDGE-PRE-001   Channel-order parity
EDGE-PRE-002   Normalization parity
EDGE-PRE-003   Resampling parity
EDGE-PRE-004   Golden tensor parity

EDGE-INF-001   Model load
EDGE-INF-002   Repeated inference
EDGE-INF-003   Output validity
EDGE-INF-004   Prediction ordering
EDGE-INF-005   Stale prediction rejection
EDGE-INF-006   Backpressure behavior

EDGE-RT-001    CPU latency
EDGE-RT-002    P95 latency
EDGE-RT-003    Sustained inference
EDGE-RT-004    Memory stability
EDGE-RT-005    Combined-stack execution
EDGE-RT-006    Thermal behavior

EDGE-ACC-001   GPU benchmark if enabled
EDGE-ACC-002   NPU benchmark if enabled
EDGE-ACC-003   Backend fallback detection

EDGE-QNT-001   Quantized accuracy comparison
EDGE-QNT-002   Quantized latency comparison
EDGE-QNT-003   Quantized parity

EDGE-SHD-001   Shadow Mode isolation
EDGE-SHD-002   Live prediction logging

EDGE-FBK-001   Motion AI fallback
EDGE-FBK-002   Step Length fallback
EDGE-FBK-003   Runtime exception isolation

EDGE-NAV-001   AI-enabled navigation boundary
EDGE-NAV-002   No direct position update
EDGE-NAV-003   Ground Truth Firewall compliance
```

---

# 227. Artifact Acceptance Criteria (Artifact Kabul Kriterleri)

The selected deployment artifact must have a valid model ID, version, metadata configuration, and cryptographic hash. *(Seçilen deployment artifact'ı geçerli model ID'sine, sürüme, metadata yapılandırmasına ve kriptografik hash'e sahip olmalıdır.)*

---

# 228. Conversion Acceptance Criteria (Conversion Kabul Kriterleri)

The converted neural model must preserve acceptable prediction equivalence with the selected source model. *(Dönüştürülmüş sinir ağı modeli seçilen kaynak modelle kabul edilebilir tahmin eşdeğerliğini korumalıdır.)*

---

# 229. Parity Acceptance Criteria (Eşdeğerlik Kabul Kriterleri)

Python-to-Android preprocessing parity must pass before formal navigation use. *(Python-Android ön işleme eşdeğerliği resmî navigasyon kullanımından önce geçmelidir.)*

Python-to-Android model output parity must also pass. *(Python-Android model çıktı eşdeğerliği de geçmelidir.)*

---

# 230. Runtime Acceptance Criteria (Runtime Kabul Kriterleri)

The model must load and execute repeatedly without runtime failure. *(Model runtime hatası olmadan yüklenmeli ve tekrar tekrar çalışmalıdır.)*

No unbounded inference backlog may occur. *(Sınırsız çıkarım backlog'u oluşamaz.)*

---

# 231. Motion Latency Acceptance Criterion (Hareket Gecikme Kabul Kriteri)

The provisional target remains below `50 ms` model inference latency per Motion Classification inference on the target device. *(Geçici hedef hedef cihaz üzerinde Hareket Sınıflandırma çıkarımı başına `50 ms` altı model çıkarım gecikmesi olarak kalmaktadır.)*

---

# 232. Prediction Freshness Acceptance Criteria (Tahmin Güncellik Kabul Kriterleri)

Stale or out-of-order predictions must not overwrite newer operational state. *(Eski veya sıra dışı tahminler daha yeni operasyonel durumun üzerine yazmamalıdır.)*

---

# 233. Failure Isolation Acceptance Criteria (Hata İzolasyonu Kabul Kriterleri)

AI initialization or inference failure must not terminate minimum deterministic navigation. *(Yapay zekâ initialization veya çıkarım hatası minimum deterministik navigasyonu sonlandırmamalıdır.)*

---

# 234. Shadow Mode Acceptance Criteria (Shadow Mode Kabul Kriterleri)

Shadow Mode must generate and log predictions while producing zero AI-originated navigation state changes. *(Shadow Mode sıfır yapay zekâ kaynaklı navigasyon durum değişikliği üretirken tahminleri oluşturmalı ve kaydetmelidir.)*

---

# 235. Navigation Boundary Acceptance Criteria (Navigasyon Sınırı Kabul Kriterleri)

Motion AI may publish motion context only through the documented interface. *(Hareket yapay zekâsı hareket bağlamını yalnızca dokümante edilmiş arayüz üzerinden yayınlayabilir.)*

Step Length AI may publish `L_k` and associated quality or uncertainty. *(Adım Uzunluğu yapay zekâsı `L_k` ve ilişkili kalite veya belirsizliği yayınlayabilir.)*

Neither model may directly overwrite global position. *(Hiçbir model global konumun doğrudan üzerine yazamaz.)*

---

# 236. Ground Truth Isolation Acceptance Criteria (Ground Truth İzolasyon Kabul Kriterleri)

No protected Evaluation Mode GNSS information may enter a navigation-enabled AI inference feature vector during the denied interval. *(Korunan Evaluation Mode GNSS bilgisi kesintili aralık sırasında navigasyon etkin yapay zekâ çıkarım özellik vektörüne giremez.)*

---

# 237. Backend Acceptance Criteria (Backend Kabul Kriterleri)

The actual runtime backend must be observable and recorded. *(Gerçek runtime backend'i gözlemlenebilir ve kaydedilmiş olmalıdır.)*

Silent fallback is not acceptable in formal backend comparison. *(Sessiz geri dönüş resmî backend karşılaştırmasında kabul edilemez.)*

---

# 238. Quantization Acceptance Criteria (Quantization Kabul Kriterleri)

A quantized model may replace the floating-point deployment candidate only after predictive and runtime comparison. *(Quantize model floating-point deployment adayının yerini yalnızca tahmin ve runtime karşılaştırmasından sonra alabilir.)*

---

# 239. Reproducibility Acceptance Criteria (Tekrarlanabilirlik Kabul Kriterleri)

Every formal AI runtime result must identify the exact model artifact, model hash, preprocessing version, runtime configuration, and actual execution backend. *(Her resmî yapay zekâ runtime sonucu kesin model artifact'ını, model hash'ini, ön işleme sürümünü, runtime yapılandırmasını ve gerçek çalıştırma backend'ini tanımlamalıdır.)*

---

# 240. Minimum Edge AI Deployment (Minimum Edge AI Deployment)

The minimum successful Edge AI deployment will run the validated Motion Classification model locally on the Redmi Note 9 Pro with deterministic fallback. *(Minimum başarılı Edge AI deployment doğrulanmış Hareket Sınıflandırma modelini deterministik geri dönüşle Redmi Note 9 Pro üzerinde yerel olarak çalıştıracaktır.)*

CPU execution is sufficient if it meets the measured requirements. *(Ölçülmüş gereksinimleri karşılıyorsa CPU çalıştırma yeterlidir.)*

---

# 241. Target Edge AI Deployment (Hedef Edge AI Deployment)

The target architecture will provide verified model registry integration, Kotlin native inference, preprocessing parity, runtime health monitoring, Shadow Mode, performance profiling, and navigation-safe fallbacks. *(Hedef mimari doğrulanmış model registry entegrasyonu, Kotlin native çıkarım, ön işleme eşdeğerliği, runtime health izleme, Shadow Mode, performans profiling ve navigasyon güvenli geri dönüşleri sağlayacaktır.)*

---

# 242. Optional Edge AI Enhancements (İsteğe Bağlı Edge AI İyileştirmeleri)

Optional improvements may include GPU acceleration. *(İsteğe bağlı iyileştirmeler GPU hızlandırmayı içerebilir.)*

Optional improvements may include supported NPU acceleration. *(İsteğe bağlı iyileştirmeler desteklenen NPU hızlandırmayı içerebilir.)*

Optional improvements may include quantization. *(İsteğe bağlı iyileştirmeler quantization'ı içerebilir.)*

---

# 243. Edge AI Non-Goals (Edge AI Olmayan Hedefler)

NAVGUARD will not require cloud AI inference. *(NAVGUARD bulut yapay zekâ çıkarımı gerektirmeyecektir.)*

NAVGUARD will not require on-device training. *(NAVGUARD cihaz üzeri eğitim gerektirmeyecektir.)*

NAVGUARD will not require GPU or NPU acceleration if CPU already satisfies the system requirements. *(NAVGUARD CPU sistem gereksinimlerini zaten karşılıyorsa GPU veya NPU hızlandırma gerektirmeyecektir.)*

---

# 244. Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kararlar)

Navigation-enabled neural AI will execute locally on Android. *(Navigasyon etkin sinir ağı yapay zekâ Android üzerinde yerel olarak çalışacaktır.)*

Neural deployment artifacts will use versioned `.tflite` files. *(Sinir ağı deployment artifact'ları sürümlenmiş `.tflite` dosyaları kullanacaktır.)*

---

# 245. Runtime Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Runtime Kararları)

Native Kotlin will own AI model execution. *(Native Kotlin yapay zekâ model çalıştırmanın sahibi olacaktır.)*

Flutter will consume high-level immutable AI-domain results rather than operate the model runtime directly. *(Flutter model runtime'ını doğrudan çalıştırmak yerine yüksek seviyeli değişmez yapay zekâ domain sonuçlarını kullanacaktır.)*

---

# 246. LiteRT API Direction Frozen by This Document (Bu Dokümanla Sabitlenen LiteRT API Yönü)

The preferred new implementation path will target the current LiteRT `CompiledModel` Kotlin API, subject to successful environment bootstrap and target-device validation. *(Tercih edilen yeni uygulama yolu başarılı ortam bootstrap ve hedef cihaz doğrulamasına bağlı olarak mevcut LiteRT `CompiledModel` Kotlin API'sini hedefleyecektir.)*

The `Interpreter` API remains an allowed compatibility fallback rather than the primary new-work choice. *(`Interpreter` API'si temel yeni geliştirme seçimi yerine izin verilen uyumluluk geri dönüşü olarak kalacaktır.)*

---

# 247. Model Lifecycle Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Model Yaşam Döngüsü Kararları)

Models will normally be loaded once and reused for repeated inference. *(Modeller normalde bir kez yüklenip tekrarlanan çıkarım için yeniden kullanılacaktır.)*

The runtime will not be recreated for every sensor window. *(Runtime her sensör penceresi için yeniden oluşturulmayacaktır.)*

---

# 248. Tensor Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Tensor Kararları)

Every model version will have an explicit input shape, channel order, data type, normalization configuration, and output schema. *(Her model sürümü açık girdi şekline, kanal sırasına, veri türüne, normalizasyon yapılandırmasına ve çıktı şemasına sahip olacaktır.)*

---

# 249. Parity Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Eşdeğerlik Kararları)

Golden Python-to-Android preprocessing parity tests are mandatory. *(Golden Python-Android ön işleme eşdeğerlik testleri zorunludur.)*

Golden output parity tests are mandatory before navigation enablement. *(Golden çıktı eşdeğerlik testleri navigasyon etkinleştirmesinden önce zorunludur.)*

---

# 250. Scheduling Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Zamanlama Kararları)

Motion inference will run per completed configured sensor window rather than per raw accelerometer event. *(Hareket çıkarımı ham ivmeölçer olayı başına değil tamamlanmış yapılandırılmış sensör penceresi başına çalışacaktır.)*

Step Length inference will run only for accepted steps. *(Adım Uzunluğu çıkarımı yalnızca kabul edilmiş adımlar için çalışacaktır.)*

---

# 251. Queue Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kuyruk Kararları)

Inference queues will remain bounded. *(Çıkarım kuyrukları sınırlı kalacaktır.)*

Obsolete predictions may be dropped rather than allowing unbounded backlog growth. *(Sınırsız backlog büyümesine izin vermek yerine eski tahminler düşürülebilir.)*

---

# 252. CPU Decisions Frozen by This Document (Bu Dokümanla Sabitlenen CPU Kararları)

CPU will be the first measured mobile execution baseline. *(CPU ilk ölçülen mobil çalıştırma temeli olacaktır.)*

---

# 253. Acceleration Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Hızlandırma Kararları)

GPU and NPU use will be evidence-driven rather than mandatory. *(GPU ve NPU kullanımı zorunlu yerine kanıt güdümlü olacaktır.)*

The final backend will be selected only after target-device measurements. *(Nihai backend yalnızca hedef cihaz ölçümlerinden sonra seçilecektir.)*

---

# 254. Quantization Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Quantization Kararları)

Floating-point deployment will be established before quantization experiments. *(Quantization deneylerinden önce floating-point deployment oluşturulacaktır.)*

Quantized models will be treated as separate artifacts. *(Quantize modeller ayrı artifact'lar olarak ele alınacaktır.)*

---

# 255. Failure Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Hata Kararları)

AI failure will never intentionally disable the minimum deterministic navigation path. *(Yapay zekâ hatası minimum deterministik navigasyon yolunu bilinçli olarak hiçbir zaman devre dışı bırakmayacaktır.)*

Motion AI failure falls back to deterministic motion behavior. *(Hareket yapay zekâsı hatası deterministik hareket davranışına geri döner.)*

Learned Step Length failure falls back through deterministic estimators. *(Öğrenilmiş Adım Uzunluğu hatası deterministik tahmin motorları üzerinden geri döner.)*

---

# 256. Shadow Mode Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Shadow Mode Kararları)

Every final navigation candidate AI model will pass live Shadow Mode before it can influence navigation. *(Her nihai navigasyon adayı yapay zekâ modeli navigasyonu etkileyebilmeden önce canlı Shadow Mode'dan geçecektir.)*

---

# 257. Logging Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Logging Kararları)

Formal sessions will identify the active model version, model hash, preprocessing version, requested backend, actual backend, inference latency, and fallback behavior. *(Resmî oturumlar aktif model sürümünü, model hash'ini, ön işleme sürümünü, talep edilen backend'i, gerçek backend'i, çıkarım gecikmesini ve geri dönüş davranışını tanımlayacaktır.)*

---

# 258. Ground Truth Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Ground Truth Kararları)

Navigation-enabled AI will not receive protected GNSS ground-truth information as a live denied-navigation feature. *(Navigasyon etkin yapay zekâ korunan GNSS ground truth bilgisini canlı kesintili navigasyon özelliği olarak almayacaktır.)*

---

# 259. Decisions Pending Environment Bootstrap (Ortam Bootstrap Bekleyen Kararlar)

The exact LiteRT dependency version remains pending project environment bootstrap. *(Kesin LiteRT dependency sürümü proje ortam bootstrap sürecini beklemektedir.)*

The exact Kotlin and Android integration syntax will be frozen against the selected LiteRT release. *(Kesin Kotlin ve Android entegrasyon syntax'ı seçilen LiteRT sürümüne göre sabitlenecektir.)*

---

# 260. Decisions Pending Final Motion Model (Nihai Hareket Modelini Bekleyen Kararlar)

The final Motion Classification tensor shape remains pending window and model selection. *(Nihai Hareket Sınıflandırma tensor şekli pencere ve model seçimini beklemektedir.)*

The final dtype remains pending model and quantization selection. *(Nihai dtype model ve quantization seçimini beklemektedir.)*

---

# 261. Decisions Pending Target-Device Benchmark (Hedef Cihaz Benchmark'ını Bekleyen Kararlar)

The final execution backend remains pending CPU, GPU, and any applicable NPU measurements on the Redmi Note 9 Pro. *(Nihai çalıştırma backend'i Redmi Note 9 Pro üzerindeki CPU, GPU ve uygulanabilir herhangi bir NPU ölçümlerini beklemektedir.)*

---

# 262. Decisions Pending Quantization Evaluation (Quantization Değerlendirmesini Bekleyen Kararlar)

The final quantization mode remains pending predictive-quality and runtime comparison. *(Nihai quantization modu tahmin kalitesi ve runtime karşılaştırmasını beklemektedir.)*

---

# 263. Decisions Pending Profiling (Profiling Bekleyen Kararlar)

The exact native execution context, inference queue capacity, and buffer reuse strategy remain subject to profiling. *(Kesin native execution context'i, çıkarım kuyruk kapasitesi ve buffer yeniden kullanım stratejisi profiling'e bağlı kalmaktadır.)*

---

# 264. Decisions Pending Shadow Testing (Shadow Testini Bekleyen Kararlar)

The final stale-prediction age threshold remains pending live Motion Classification timing tests. *(Nihai eski tahmin yaş eşiği canlı Hareket Sınıflandırma zamanlama testlerini beklemektedir.)*

---

# 265. Official Technical Reference Basis (Resmî Teknik Referans Temeli)

The deployment architecture is aligned with Google's current LiteRT Android, conversion, acceleration, migration, and measurement documentation as checked on September 1, 2026. *(Deployment mimarisi 1 Eylül 2026 tarihinde kontrol edilen Google'ın mevcut LiteRT Android, conversion, acceleration, migration ve ölçüm dokümantasyonuyla uyumludur.)*

---

# 266. Final On-Device Edge AI Architecture Statement (Nihai Cihaz Üzeri Edge AI Mimarisi Bildirimi)

**NAVGUARD will execute navigation-enabled machine-learning inference locally on the Xiaomi Redmi Note 9 Pro through a native Kotlin AI subsystem, while Flutter remains responsible for presentation and high-level application orchestration rather than low-level model execution.** *(NAVGUARD navigasyon etkin makine öğrenmesi çıkarımını native Kotlin yapay zekâ alt sistemi üzerinden Xiaomi Redmi Note 9 Pro üzerinde yerel olarak çalıştıracak, Flutter ise düşük seviyeli model çalıştırma yerine sunum ve yüksek seviyeli uygulama orkestrasyonundan sorumlu kalacaktır.)*

**Neural deployment artifacts will use versioned `.tflite` files with explicit hashes, model metadata, input and output schemas, preprocessing versions, and source-training traceability so that every benchmark prediction can be linked to the exact binary that produced it.** *(Sinir ağı deployment artifact'ları açık hash'ler, model metadata bilgisi, girdi ve çıktı şemaları, ön işleme sürümleri ve kaynak eğitim izlenebilirliğiyle sürümlenmiş `.tflite` dosyaları kullanacak; böylece her benchmark tahmini onu üreten kesin binary'ye bağlanabilecektir.)*

**The preferred new Android runtime direction will use LiteRT's current Kotlin `CompiledModel` API when target-device validation succeeds, while the legacy-compatible `Interpreter` path will remain available only as a documented fallback when required.** *(Tercih edilen yeni Android runtime yönü hedef cihaz doğrulaması başarılı olduğunda LiteRT'nin mevcut Kotlin `CompiledModel` API'sini kullanacak, legacy uyumlu `Interpreter` yolu ise yalnızca gerektiğinde dokümante edilmiş geri dönüş olarak kullanılabilir kalacaktır.)*

**Every model will pass source-to-export validation, Python-to-Android preprocessing parity, Android output parity, physical-device loading, Shadow Mode, sustained runtime, latency, ordering, backpressure, and fallback tests before it can influence formal navigation.** *(Her model resmî navigasyonu etkileyebilmeden önce kaynak-export doğrulamasını, Python-Android ön işleme eşdeğerliğini, Android çıktı eşdeğerliğini, fiziksel cihaz yüklemeyi, Shadow Mode'u, sürekli runtime'ı, gecikmeyi, sıralamayı, backpressure'ı ve geri dönüş testlerini geçecektir.)*

**CPU execution will establish the initial target-device baseline, while GPU, supported NPU execution, and quantization will remain optional optimizations retained only when measured improvements justify their additional complexity.** *(CPU çalıştırma ilk hedef cihaz temelini oluşturacak, GPU, desteklenen NPU çalıştırma ve quantization ise yalnızca ölçülmüş iyileştirmeler ek karmaşıklıklarını gerekçelendirdiğinde korunan isteğe bağlı optimizasyonlar olarak kalacaktır.)*

**Inference queues will remain bounded, model objects will normally be loaded once and reused, stale or out-of-order predictions will never overwrite newer operational state, and heavy inference processing will remain outside the Flutter UI execution path.** *(Çıkarım kuyrukları sınırlı kalacak, model nesneleri normalde bir kez yüklenip yeniden kullanılacak, eski veya sıra dışı tahminler daha yeni operasyonel durumun üzerine hiçbir zaman yazmayacak ve ağır çıkarım işlemesi Flutter UI çalıştırma yolunun dışında kalacaktır.)*

**AI runtime failure will never intentionally terminate the minimum deterministic navigation chain, because Motion Classification can fall back to deterministic motion logic and learned Step Length Estimation can fall back to deterministic variable or calibrated fixed step length.** *(Yapay zekâ runtime hatası minimum deterministik navigasyon zincirini hiçbir zaman bilinçli olarak sonlandırmayacaktır çünkü Hareket Sınıflandırması deterministik hareket mantığına ve öğrenilmiş Adım Uzunluğu Tahmini deterministik değişken veya kalibre edilmiş sabit adım uzunluğuna geri dönebilir.)*

**Protected Evaluation Mode GNSS ground truth will remain outside all navigation-enabled AI feature vectors during the denied interval, preserving the same Ground Truth Firewall guarantee applied to PDR, EKF, and the rest of the estimator.** *(Korunan Evaluation Mode GNSS ground truth kesintili aralık sırasında tüm navigasyon etkin yapay zekâ özellik vektörlerinin dışında kalacak ve PDR, EKF ve tahmin motorunun geri kalanına uygulanan aynı Ground Truth Firewall garantisini koruyacaktır.)*

---

# 267. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development On-Device Edge AI Deployment Architecture Completed *(Doküman Durumu: Geliştirme Öncesi Cihaz Üzeri Edge AI Deployment Mimarisi Tamamlandı)*

**Deployment Philosophy:** Offline-First / On-Device *(Deployment Felsefesi: Çevrimdışı Öncelikli / Cihaz Üzeri)*

**Primary Target Device:** Xiaomi Redmi Note 9 Pro *(Temel Hedef Cihaz: Xiaomi Redmi Note 9 Pro)*

**Native Runtime Owner:** Kotlin AI Subsystem *(Native Runtime Sahibi: Kotlin Yapay Zekâ Alt Sistemi)*

**Flutter Role:** UI + High-Level Orchestration *(Flutter Rolü: UI + Yüksek Seviyeli Orkestrasyon)*

**Neural Artifact Format:** `.tflite` *(Sinir Ağı Artifact Formatı: `.tflite`)*

**Preferred New LiteRT Runtime Direction:** `CompiledModel` Kotlin API *(Tercih Edilen Yeni LiteRT Runtime Yönü: `CompiledModel` Kotlin API)*

**Compatibility Fallback:** `Interpreter` API *(Uyumluluk Geri Dönüşü: `Interpreter` API)*

**Exact LiteRT Dependency Version:** Pending Environment Bootstrap *(Kesin LiteRT Dependency Sürümü: Ortam Bootstrap Bekleniyor)*

**Current Official LiteRT Android Release Observed on 2026-09-01:** `2.2.0` *(2026-09-01 Tarihinde Gözlemlenen Mevcut Resmî LiteRT Android Sürümü: `2.2.0`)*

**Model Load Policy:** Load Once / Reuse *(Model Yükleme Politikası: Bir Kez Yükle / Yeniden Kullan)*

**Motion Inference Trigger:** Completed Valid Sensor Window *(Hareket Çıkarım Tetikleyicisi: Tamamlanmış Geçerli Sensör Penceresi)*

**Step Length Inference Trigger:** Accepted Step Event *(Adım Uzunluğu Çıkarım Tetikleyicisi: Kabul Edilmiş Adım Olayı)*

**Inference Queue:** Bounded *(Çıkarım Kuyruğu: Sınırlı)*

**Training-Mobile Preprocessing Parity:** Mandatory *(Eğitim-Mobil Ön İşleme Eşdeğerliği: Zorunlu)*

**Model Output Parity:** Mandatory *(Model Çıktı Eşdeğerliği: Zorunlu)*

**Model Hash Verification:** Mandatory for Formal Benchmark *(Model Hash Doğrulaması: Resmî Benchmark İçin Zorunlu)*

**First Runtime Baseline:** CPU *(İlk Runtime Temeli: CPU)*

**GPU:** Optional / Benchmark-Driven *(GPU: İsteğe Bağlı / Benchmark Güdümlü)*

**NPU:** Optional / Physical Support Required *(NPU: İsteğe Bağlı / Fiziksel Destek Gerekli)*

**Quantization:** Optional / Separate Artifact *(Quantization: İsteğe Bağlı / Ayrı Artifact)*

**Motion Inference Provisional Target:** `< 50 ms` *(Hareket Çıkarım Geçici Hedefi: `< 50 ms`)*

**Shadow Mode:** Mandatory Before Navigation Enablement *(Shadow Mode: Navigasyon Etkinleştirmeden Önce Zorunlu)*

**Stale Prediction Protection:** Mandatory *(Eski Tahmin Koruması: Zorunlu)*

**Out-of-Order Protection:** Mandatory *(Sıra Dışı Tahmin Koruması: Zorunlu)*

**Backpressure Handling:** Mandatory *(Backpressure Yönetimi: Zorunlu)*

**Motion AI Fallback:** Deterministic Motion Logic *(Hareket Yapay Zekâsı Geri Dönüşü: Deterministik Hareket Mantığı)*

**Step Length AI Fallback:** Deterministic Variable → Calibrated Fixed *(Adım Uzunluğu Yapay Zekâsı Geri Dönüşü: Deterministik Değişken → Kalibre Edilmiş Sabit)*

**Direct AI Position Update:** Forbidden *(Doğrudan Yapay Zekâ Konum Güncellemesi: Yasak)*

**Protected GNSS Ground Truth as Runtime AI Feature:** Forbidden During Denial *(Runtime Yapay Zekâ Özelliği Olarak Korunan GNSS Ground Truth: Kesinti Sırasında Yasak)*

**Final Motion Tensor Shape:** Pending Model Selection *(Nihai Hareket Tensor Şekli: Model Seçimi Bekleniyor)*

**Final Quantization Mode:** Pending Benchmark *(Nihai Quantization Modu: Benchmark Bekleniyor)*

**Final Execution Backend:** Pending Redmi Note 9 Pro Benchmark *(Nihai Çalıştırma Backend'i: Redmi Note 9 Pro Benchmark'ı Bekleniyor)*

**Final Stale Prediction Threshold:** Pending Shadow Timing Tests *(Nihai Eski Tahmin Eşiği: Shadow Zamanlama Testleri Bekleniyor)*

**Next Documentation Item:** 28 — Position Estimation & Uncertainty Engine *(Sonraki Dokümantasyon Öğesi: 28 — Konum Tahmini ve Belirsizlik Motoru)*
