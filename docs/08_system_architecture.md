# 08 — System Architecture (Sistem Mimarisi)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the high-level and logical system architecture of NAVGUARD. *(Bu doküman, NAVGUARD’ın üst seviye ve mantıksal sistem mimarisini tanımlar.)*

The architecture describes how Android sensors, GNSS, ARCore, artificial intelligence, pedestrian dead reckoning, heading estimation, sensor fusion, data storage, experimental evaluation, and the Flutter user interface interact with each other. *(Mimari; Android sensörlerinin, GNSS’in, ARCore’un, yapay zekânın, yaya ölü hesaplamanın, yön tahmininin, sensör füzyonunun, veri depolamanın, deneysel değerlendirmenin ve Flutter kullanıcı arayüzünün birbirleriyle nasıl etkileşime girdiğini açıklar.)*

This document defines architectural responsibilities and module boundaries without fixing every low-level implementation detail. *(Bu doküman, her düşük seviyeli uygulama ayrıntısını sabitlemeden mimari sorumlulukları ve modül sınırlarını tanımlar.)*

Detailed algorithmic implementations will be defined in their dedicated technical documents. *(Ayrıntılı algoritmik uygulamalar kendi özel teknik dokümanlarında tanımlanacaktır.)*

---

# 2. Architectural Objective (Mimari Hedef)

The primary architectural objective is to create a modular Android navigation research system that remains functional when GNSS measurements are removed from the estimator. *(Temel mimari hedef, GNSS ölçümleri tahmin motorundan çıkarıldığında çalışmaya devam eden modüler bir Android navigasyon araştırma sistemi oluşturmaktır.)*

The architecture must allow individual navigation components to be enabled, disabled, replaced, and compared experimentally. *(Mimari, bireysel navigasyon bileşenlerinin deneysel olarak etkinleştirilmesine, devre dışı bırakılmasına, değiştirilmesine ve karşılaştırılmasına olanak sağlamalıdır.)*

The architecture must also separate real-time navigation from ground-truth evaluation so that experimental GNSS measurements cannot influence the GNSS-denied estimator. *(Mimari ayrıca gerçek zamanlı navigasyonu gerçek referans değerlendirmesinden ayırmalıdır; böylece deneysel GNSS ölçümleri GNSS kesintili tahmin motorunu etkileyemez.)*

---

# 3. Architecture Style (Mimari Tarz)

NAVGUARD will use a layered, modular, event-driven architecture. *(NAVGUARD katmanlı, modüler ve olay güdümlü bir mimari kullanacaktır.)*

Sensor measurements will enter the system as timestamped events. *(Sensör ölçümleri sisteme zaman damgalı olaylar olarak girecektir.)*

Processing modules will transform these measurements into increasingly higher-level navigation information. *(İşleme modülleri bu ölçümleri giderek daha yüksek seviyeli navigasyon bilgilerine dönüştürecektir.)*

The final estimator will combine selected information sources and produce a unified navigation state. *(Nihai tahmin motoru seçilen bilgi kaynaklarını birleştirecek ve birleşik bir navigasyon durumu üretecektir.)*

---

# 4. High-Level Architecture (Üst Seviye Mimari)

NAVGUARD will be divided into the following primary architectural layers. *(NAVGUARD aşağıdaki temel mimari katmanlara ayrılacaktır.)*

```
┌──────────────────────────────────────────────────────────────┐
│ Presentation Layer (Sunum Katmanı)                          │
│ Flutter UI / Live Navigation / Research Dashboard           │
└──────────────────────────────────────────────────────────────┘
                              ↑
┌──────────────────────────────────────────────────────────────┐
│ Application & Experiment Layer (Uygulama ve Deney Katmanı)  │
│ Session / Modes / Readiness / Configuration / Replay        │
└──────────────────────────────────────────────────────────────┘
                              ↑
┌──────────────────────────────────────────────────────────────┐
│ Navigation Fusion Layer (Navigasyon Füzyon Katmanı)         │
│ EKF / Position / Confidence / Relocalization                │
└──────────────────────────────────────────────────────────────┘
                              ↑
┌──────────────────────────────────────────────────────────────┐
│ Navigation Interpretation Layer                             │
│ (Navigasyon Yorumlama Katmanı)                              │
│ PDR / Step / Heading / Motion AI / ARCore                   │
└──────────────────────────────────────────────────────────────┘
                              ↑
┌──────────────────────────────────────────────────────────────┐
│ Preprocessing & Synchronization Layer                       │
│ (Ön İşleme ve Senkronizasyon Katmanı)                       │
│ Filtering / Timestamp Alignment / Coordinate Transformation │
└──────────────────────────────────────────────────────────────┘
                              ↑
┌──────────────────────────────────────────────────────────────┐
│ Acquisition Layer (Veri Toplama Katmanı)                    │
│ Accelerometer / Gyroscope / Magnetometer / GNSS / ARCore    │
└──────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────┐
│ Data & Evidence Layer (Veri ve Kanıt Katmanı)               │
│ Session Logs / Raw Data / Estimates / Ground Truth / Export │
└──────────────────────────────────────────────────────────────┘
```

Each layer must have clearly defined responsibilities and must avoid unnecessary knowledge about higher-level modules. *(Her katman açıkça tanımlanmış sorumluluklara sahip olmalı ve daha yüksek seviyeli modüller hakkında gereksiz bilgiden kaçınmalıdır.)*

---

# 5. Architectural Separation of Concerns (Mimari Sorumluluk Ayrımı)

Sensor acquisition must not contain navigation decision logic. *(Sensör veri toplama katmanı navigasyon karar mantığı içermemelidir.)*

Preprocessing must not determine final user position. *(Ön işleme nihai kullanıcı konumunu belirlememelidir.)*

Artificial intelligence must not directly control unrelated user-interface behavior. *(Yapay zekâ, ilgisiz kullanıcı arayüzü davranışlarını doğrudan kontrol etmemelidir.)*

The user interface must not implement navigation mathematics. *(Kullanıcı arayüzü navigasyon matematiğini uygulamamalıdır.)*

Ground-truth evaluation logic must remain isolated from the real-time estimator. *(Gerçek referans değerlendirme mantığı gerçek zamanlı tahmin motorundan izole kalmalıdır.)*

---

# 6. Primary Runtime Components (Temel Çalışma Zamanı Bileşenleri)

The runtime system will contain the following major components. *(Çalışma zamanı sistemi aşağıdaki temel bileşenleri içerecektir.)*

- **Sensor Acquisition Manager** *(Sensör Veri Toplama Yöneticisi)*
- **GNSS Manager** *(GNSS Yöneticisi)*
- **ARCore Tracking Manager** *(ARCore Takip Yöneticisi)*
- **Timestamp Synchronization Engine** *(Zaman Damgası Senkronizasyon Motoru)*
- **Sensor Preprocessing Pipeline** *(Sensör Ön İşleme Hattı)*
- **Step Detection Engine** *(Adım Tespit Motoru)*
- **Heading Estimation Engine** *(Yön Tahmin Motoru)*
- **Step Length Estimator** *(Adım Uzunluğu Tahmin Motoru)*
- **Motion Classification Engine** *(Hareket Sınıflandırma Motoru)*
- **Pedestrian Dead Reckoning Engine** *(Yaya Ölü Hesaplama Motoru)*
- **Sensor Quality Engine** *(Sensör Kalite Motoru)*
- **Fusion Engine** *(Füzyon Motoru)*
- **Position Uncertainty Engine** *(Konum Belirsizliği Motoru)*
- **Navigation State Manager** *(Navigasyon Durum Yöneticisi)*
- **Session Manager** *(Oturum Yöneticisi)*
- **Logging Engine** *(Kayıt Motoru)*
- **Replay Engine** *(Yeniden Oynatma Motoru)*
- **Evaluation Engine** *(Değerlendirme Motoru)*
- **Presentation Layer** *(Sunum Katmanı)*

---

# 7. Flutter Application Layer (Flutter Uygulama Katmanı)

Flutter will provide the primary application shell and user-interface layer. *(Flutter temel uygulama kabuğunu ve kullanıcı arayüzü katmanını sağlayacaktır.)*

Flutter will manage screen navigation, research dashboards, session controls, configuration interfaces, result visualization, and user-visible system status. *(Flutter; ekran navigasyonunu, araştırma dashboard’larını, oturum kontrollerini, yapılandırma arayüzlerini, sonuç görselleştirmesini ve kullanıcıya görünen sistem durumunu yönetecektir.)*

Flutter will not be responsible for hardware-specific functionality when native Android control is technically more reliable. *(Native Android kontrolünün teknik olarak daha güvenilir olduğu durumlarda Flutter donanıma özgü işlevlerden sorumlu olmayacaktır.)*

The architecture will therefore allow selected low-level components to execute in Kotlin. *(Bu nedenle mimari, seçilen düşük seviyeli bileşenlerin Kotlin içerisinde çalışmasına izin verecektir.)*

---

# 8. Native Android Layer (Native Android Katmanı)

The native Android layer will provide direct access to Android-specific capabilities where Flutter abstractions are insufficient. *(Native Android katmanı, Flutter soyutlamalarının yetersiz olduğu durumlarda Android’e özgü yeteneklere doğrudan erişim sağlayacaktır.)*

Potential responsibilities include high-frequency sensor acquisition, precise timestamp handling, sensor metadata access, ARCore integration, and other Android-specific runtime services. *(Potansiyel sorumluluklar; yüksek frekanslı sensör veri toplama, hassas zaman damgası yönetimi, sensör metadata erişimi, ARCore entegrasyonu ve diğer Android’e özgü çalışma zamanı hizmetlerini içerir.)*

Kotlin will be the preferred language for custom native Android integration. *(Özel native Android entegrasyonu için tercih edilen dil Kotlin olacaktır.)*

---

# 9. Flutter-to-Kotlin Communication (Flutter-Kotlin İletişimi)

Flutter and the native Android layer will communicate through controlled platform interfaces. *(Flutter ve native Android katmanı kontrollü platform arayüzleri üzerinden iletişim kuracaktır.)*

Request-response operations may use a method-oriented communication mechanism. *(İstek-cevap işlemleri metot odaklı bir iletişim mekanizması kullanabilir.)*

Continuous high-frequency streams should use a streaming mechanism suitable for sensor events. *(Sürekli yüksek frekanslı akışlar sensör olaylarına uygun bir streaming mekanizması kullanmalıdır.)*

The architecture should avoid sending unnecessarily large volumes of raw high-frequency data through the UI layer when processing can occur closer to the native acquisition layer. *(İşleme native veri toplama katmanına daha yakın gerçekleştirilebiliyorsa mimari gereksiz derecede büyük miktarda ham yüksek frekanslı veriyi UI katmanı üzerinden göndermekten kaçınmalıdır.)*

---

# 10. Acquisition Layer (Veri Toplama Katmanı)

The Acquisition Layer will be the lowest logical NAVGUARD software layer above the Android hardware and platform APIs. *(Veri Toplama Katmanı, Android donanım ve platform API’lerinin üzerindeki en düşük mantıksal NAVGUARD yazılım katmanı olacaktır.)*

Its responsibility will be to acquire measurements without interpreting them as navigation decisions. *(Bu katmanın sorumluluğu, ölçümleri navigasyon kararları olarak yorumlamadan elde etmek olacaktır.)*

The layer must preserve original timestamps and source identity. *(Katman orijinal zaman damgalarını ve kaynak kimliğini korumalıdır.)*

---

# 11. Sensor Acquisition Manager (Sensör Veri Toplama Yöneticisi)

The Sensor Acquisition Manager will control accelerometer, gyroscope, magnetometer, and available virtual sensor streams. *(Sensör Veri Toplama Yöneticisi ivmeölçer, jiroskop, manyetometre ve mevcut sanal sensör akışlarını kontrol edecektir.)*

It will register and unregister Android sensor listeners according to session lifecycle. *(Oturum yaşam döngüsüne göre Android sensör listener’larını kaydedecek ve kaldıracaktır.)*

It will attach source metadata and timestamps to each sensor event. *(Her sensör olayına kaynak metadata bilgisi ve zaman damgası ekleyecektir.)*

It will expose effective sensor rate information to the diagnostic system. *(Etkin sensör hız bilgisini tanı sistemine sunacaktır.)*

---

# 12. Sensor Event Model (Sensör Olay Modeli)

All sensor measurements should be converted into a consistent internal event representation. *(Tüm sensör ölçümleri tutarlı bir dahili olay temsiline dönüştürülmelidir.)*

A sensor event should contain at least a source identifier, timestamp, measurement values, and optional accuracy information. *(Bir sensör olayı en azından kaynak tanımlayıcısı, zaman damgası, ölçüm değerleri ve isteğe bağlı doğruluk bilgisi içermelidir.)*

The internal representation should remain independent from user-interface objects. *(Dahili temsil kullanıcı arayüzü nesnelerinden bağımsız kalmalıdır.)*

---

# 13. GNSS Manager (GNSS Yöneticisi)

The GNSS Manager will acquire position information required for initialization and evaluation. *(GNSS Yöneticisi başlatma ve değerlendirme için gerekli konum bilgisini elde edecektir.)*

It will preserve GNSS accuracy and timestamp information. *(GNSS doğruluk ve zaman damgası bilgisini koruyacaktır.)*

It will expose GNSS measurements through two logically separate channels when Evaluation Mode is active. *(Değerlendirme Modu aktif olduğunda GNSS ölçümlerini mantıksal olarak ayrı iki kanal üzerinden sunacaktır.)*

One channel may be used by the estimator when GNSS use is allowed. *(GNSS kullanımına izin verildiğinde bir kanal tahmin motoru tarafından kullanılabilir.)*

The second channel will be reserved exclusively for ground-truth recording. *(İkinci kanal yalnızca gerçek referans kaydı için ayrılacaktır.)*

---

# 14. Ground Truth Firewall (Gerçek Referans Güvenlik Duvarı)

NAVGUARD will include a logical Ground Truth Firewall between evaluation GNSS data and the GNSS-denied estimator. *(NAVGUARD, değerlendirme GNSS verisi ile GNSS kesintili tahmin motoru arasında mantıksal bir Gerçek Referans Güvenlik Duvarı içerecektir.)*

When the estimator enters GNSS-Denied Mode, the navigation pipeline must stop receiving GNSS position updates. *(Tahmin motoru GNSS Kesintili Moda girdiğinde navigasyon hattı GNSS konum güncellemelerini almayı durdurmalıdır.)*

The logging pipeline may continue recording the same physical GNSS receiver output independently. *(Kayıt hattı aynı fiziksel GNSS alıcısı çıktısını bağımsız olarak kaydetmeye devam edebilir.)*

This architectural isolation is mandatory for valid experiments. *(Bu mimari izolasyon geçerli deneyler için zorunludur.)*

---

# 15. Ground Truth Isolation Flow (Gerçek Referans İzolasyon Akışı)

```
Physical GNSS Receiver (Fiziksel GNSS Alıcısı)
                    │
                    ▼
              GNSS Manager
                    │
           ┌────────┴────────┐
           │                 │
           ▼                 ▼
Estimator Channel        Ground Truth Channel
(Tahmin Motoru Kanalı)   (Gerçek Referans Kanalı)
           │                 │
           │                 ▼
           │              Logger
           │                 │
           ▼                 ▼
Navigation Estimator     Evaluation Dataset
(Navigasyon Tahmini)     (Değerlendirme Veri Seti)

GNSS-Denied Mode:
Estimator Channel = BLOCKED (ENGELLİ)
Ground Truth Channel = ACTIVE (AKTİF)
```

The architecture must make this separation observable through logs and runtime state. *(Mimari bu ayrımı loglar ve çalışma zamanı durumu üzerinden gözlemlenebilir hale getirmelidir.)*

---

# 16. ARCore Tracking Manager (ARCore Takip Yöneticisi)

The ARCore Tracking Manager will manage the lifecycle of ARCore sessions used for relative movement estimation. *(ARCore Takip Yöneticisi, göreli hareket tahmini için kullanılan ARCore oturumlarının yaşam döngüsünü yönetecektir.)*

It will provide timestamped translation, orientation, and tracking-state information. *(Zaman damgalı öteleme, yönelim ve takip durumu bilgisi sağlayacaktır.)*

ARCore output will remain in its native local coordinate system until an explicit alignment process transforms it into the NAVGUARD navigation frame. *(ARCore çıktısı, açık bir hizalama işlemi onu NAVGUARD navigasyon koordinat sistemine dönüştürene kadar kendi yerel koordinat sisteminde kalacaktır.)*

---

# 17. ARCore Isolation Principle (ARCore İzolasyon İlkesi)

ARCore will be treated as an optional navigation measurement source rather than the central navigation engine. *(ARCore merkezi navigasyon motoru yerine isteğe bağlı bir navigasyon ölçüm kaynağı olarak ele alınacaktır.)*

Temporary ARCore tracking failure must not stop PDR operation. *(Geçici ARCore takip başarısızlığı PDR çalışmasını durdurmamalıdır.)*

ARCore measurements will enter the fusion system only when their tracking state is considered usable. *(ARCore ölçümleri yalnızca takip durumu kullanılabilir kabul edildiğinde füzyon sistemine girecektir.)*

---

# 18. Timestamp Synchronization Engine (Zaman Damgası Senkronizasyon Motoru)

The Timestamp Synchronization Engine will align measurements from different clock domains onto a common experiment timeline. *(Zaman Damgası Senkronizasyon Motoru farklı saat alanlarından gelen ölçümleri ortak bir deney zaman çizelgesine hizalayacaktır.)*

It will identify the time basis of sensor events, GNSS updates, ARCore frames, AI outputs, and application events. *(Sensör olaylarının, GNSS güncellemelerinin, ARCore karelerinin, yapay zekâ çıktılarının ve uygulama olaylarının zaman temelini belirleyecektir.)*

The system must avoid assuming that all data sources use identical timestamp definitions. *(Sistem tüm veri kaynaklarının aynı zaman damgası tanımlarını kullandığını varsaymaktan kaçınmalıdır.)*

---

# 19. Common Experiment Timeline (Ortak Deney Zaman Çizelgesi)

Every recorded source will eventually be representable relative to one common session timeline. *(Kaydedilen her kaynak sonunda ortak bir oturum zaman çizelgesine göre temsil edilebilir olacaktır.)*

This timeline will allow offline replay, ground-truth comparison, and multi-sensor fusion. *(Bu zaman çizelgesi çevrimdışı yeniden oynatma, gerçek referans karşılaştırması ve çoklu sensör füzyonuna olanak sağlayacaktır.)*

Timestamp conversion rules must be deterministic and documented. *(Zaman damgası dönüşüm kuralları deterministik ve dokümante edilmiş olmalıdır.)*

---

# 20. Preprocessing Layer (Ön İşleme Katmanı)

The Preprocessing Layer will convert raw sensor measurements into signals suitable for navigation and machine learning. *(Ön İşleme Katmanı ham sensör ölçümlerini navigasyon ve makine öğrenmesi için uygun sinyallere dönüştürecektir.)*

The layer may perform filtering, gravity handling, normalization, coordinate transformation, resampling, window construction, and quality checks. *(Katman filtreleme, yerçekimi yönetimi, normalizasyon, koordinat dönüşümü, yeniden örnekleme, pencere oluşturma ve kalite kontrolleri gerçekleştirebilir.)*

Raw measurements must remain available in the recording pipeline even when processed versions are used by the estimator. *(İşlenmiş sürümler tahmin motoru tarafından kullanılsa bile ham ölçümler kayıt hattında kullanılabilir kalmalıdır.)*

---

# 21. Raw and Processed Data Separation (Ham ve İşlenmiş Veri Ayrımı)

NAVGUARD will distinguish raw sensor measurements from derived navigation signals. *(NAVGUARD ham sensör ölçümlerini türetilmiş navigasyon sinyallerinden ayıracaktır.)*

Raw data will preserve the closest practical representation of Android sensor output. *(Ham veri Android sensör çıktısının mümkün olan en yakın temsilini koruyacaktır.)*

Processed data may include filtered acceleration, corrected gyroscope values, transformed vectors, heading estimates, and AI feature windows. *(İşlenmiş veri filtrelenmiş ivme, düzeltilmiş jiroskop değerleri, dönüştürülmüş vektörler, yön tahminleri ve yapay zekâ özellik pencerelerini içerebilir.)*

This separation will support reproducibility and alternative offline processing. *(Bu ayrım tekrarlanabilirliği ve alternatif çevrimdışı işlemeyi destekleyecektir.)*

---

# 22. Coordinate Transformation Module (Koordinat Dönüşüm Modülü)

The Coordinate Transformation Module will manage transformations between device coordinates, ARCore coordinates, local navigation coordinates, and geographic coordinates. *(Koordinat Dönüşüm Modülü cihaz koordinatları, ARCore koordinatları, yerel navigasyon koordinatları ve coğrafi koordinatlar arasındaki dönüşümleri yönetecektir.)*

The local navigation frame will use an east-north-oriented representation suitable for pedestrian movement calculations. *(Yerel navigasyon koordinat sistemi yaya hareket hesaplamalarına uygun doğu-kuzey yönelimli bir temsil kullanacaktır.)*

Latitude and longitude conversion will occur at defined interfaces rather than throughout every navigation module. *(Enlem ve boylam dönüşümü her navigasyon modülüne dağılmak yerine tanımlı arayüzlerde gerçekleştirilecektir.)*

---

# 23. Navigation Interpretation Layer (Navigasyon Yorumlama Katmanı)

The Navigation Interpretation Layer will convert processed sensor signals into semantic movement information. *(Navigasyon Yorumlama Katmanı işlenmiş sensör sinyallerini anlamsal hareket bilgisine dönüştürecektir.)*

Its outputs will include detected steps, estimated step length, heading, motion class, relative displacement, and sensor quality indicators. *(Çıktıları; tespit edilen adımlar, tahmini adım uzunluğu, yön, hareket sınıfı, göreli yer değiştirme ve sensör kalite göstergelerini içerecektir.)*

These outputs will be consumed by PDR and the fusion layer. *(Bu çıktılar PDR ve füzyon katmanı tarafından kullanılacaktır.)*

---

# 24. Step Detection Engine (Adım Tespit Motoru)

The Step Detection Engine will detect pedestrian steps from processed inertial measurements. *(Adım Tespit Motoru işlenmiş ataletsel ölçümlerden yaya adımlarını tespit edecektir.)*

The initial implementation will support a deterministic signal-processing baseline. *(İlk uygulama deterministik bir sinyal işleme temel yaklaşımını destekleyecektir.)*

The module will expose timestamps for detected steps rather than only a cumulative step count. *(Modül yalnızca kümülatif adım sayısı yerine tespit edilen adımların zaman damgalarını sunacaktır.)*

This allows each step to be associated with heading and step-length information. *(Bu, her adımın yön ve adım uzunluğu bilgisiyle ilişkilendirilmesini sağlar.)*

---

# 25. Step Length Estimation Module (Adım Uzunluğu Tahmin Modülü)

The Step Length Estimation Module will provide an estimated displacement length for each accepted pedestrian step. *(Adım Uzunluğu Tahmin Modülü kabul edilen her yaya adımı için tahmini bir yer değiştirme uzunluğu sağlayacaktır.)*

The architecture will support at least a deterministic baseline estimator. *(Mimari en azından deterministik bir temel tahmin motorunu destekleyecektir.)*

A learned regression model may later replace or supplement the baseline through the same logical interface. *(Öğrenilmiş bir regresyon modeli daha sonra aynı mantıksal arayüz üzerinden temel yaklaşımın yerini alabilir veya onu destekleyebilir.)*

This replaceable design will allow direct experimental comparison. *(Bu değiştirilebilir tasarım doğrudan deneysel karşılaştırmaya olanak sağlayacaktır.)*

---

# 26. Heading Estimation Engine (Yön Tahmin Motoru)

The Heading Estimation Engine will estimate movement direction using available orientation-related information. *(Yön Tahmin Motoru mevcut yönelimle ilişkili bilgileri kullanarak hareket yönünü tahmin edecektir.)*

It may consume gyroscope, magnetometer, rotation-vector, and additional orientation signals. *(Jiroskop, manyetometre, rotation-vector ve ek yönelim sinyallerini kullanabilir.)*

The engine will expose both the heading estimate and available quality information. *(Motor hem yön tahminini hem de mevcut kalite bilgisini sunacaktır.)*

---

# 27. Motion Classification Engine (Hareket Sınıflandırma Motoru)

The Motion Classification Engine will perform on-device inference using windows of sensor time-series data. *(Hareket Sınıflandırma Motoru sensör zaman serisi veri pencerelerini kullanarak cihaz üzerinde çıkarım gerçekleştirecektir.)*

Its initial semantic output will include stationary, walking, running, and turning classes. *(İlk anlamsal çıktısı sabit durma, yürüme, koşma ve dönme sınıflarını içerecektir.)*

The engine will also expose model confidence or probability information when supported by the final model. *(Nihai model desteklediğinde motor model güveni veya olasılık bilgisini de sunacaktır.)*

---

# 28. AI Integration Boundary (Yapay Zekâ Entegrasyon Sınırı)

The AI model will provide navigation context rather than directly output final latitude and longitude. *(Yapay zekâ modeli doğrudan nihai enlem ve boylam çıktısı vermek yerine navigasyon bağlamı sağlayacaktır.)*

Motion classification may influence step detection behavior, stationary suppression, step-length selection, or estimator confidence. *(Hareket sınıflandırması adım tespit davranışını, sabit durum bastırmayı, adım uzunluğu seçimini veya tahmin motoru güvenini etkileyebilir.)*

This design keeps learned inference separated from deterministic navigation state estimation. *(Bu tasarım öğrenilmiş çıkarımı deterministik navigasyon durum tahmininden ayrı tutar.)*

---

# 29. Motion AI Data Flow (Hareket Yapay Zekâsı Veri Akışı)

```
Accelerometer + Gyroscope + Optional Sensor Channels
(İvmeölçer + Jiroskop + İsteğe Bağlı Sensör Kanalları)
                         │
                         ▼
                  Preprocessing
                   (Ön İşleme)
                         │
                         ▼
                Window Construction
                 (Pencere Oluşturma)
                         │
                         ▼
               Motion AI Inference
              (Hareket AI Çıkarımı)
                         │
                         ▼
           Motion Class + Confidence
           (Hareket Sınıfı + Güven)
                         │
             ┌───────────┼───────────┐
             ▼           ▼           ▼
       Step Logic   Step Length   Fusion Context
       (Adım Mantığı) (Adım Uz.) (Füzyon Bağlamı)
```

The final use of each AI output will be explicitly documented and experimentally evaluated. *(Her yapay zekâ çıktısının nihai kullanımı açıkça dokümante edilecek ve deneysel olarak değerlendirilecektir.)*

---

# 30. Pedestrian Dead Reckoning Engine (Yaya Ölü Hesaplama Motoru)

The PDR Engine will calculate relative pedestrian displacement from detected steps, step length, and heading. *(PDR Motoru tespit edilen adımlar, adım uzunluğu ve yönden göreli yaya yer değiştirmesini hesaplayacaktır.)*

It will maintain a local east-north position beginning from the navigation origin. *(Navigasyon başlangıcından itibaren yerel bir doğu-kuzey konumu tutacaktır.)*

The PDR Engine will operate independently from ARCore so that it remains available as the minimum navigation fallback. *(PDR Motoru, minimum navigasyon geri dönüşü olarak kullanılabilir kalması için ARCore’dan bağımsız çalışacaktır.)*

---

# 31. Baseline PDR Flow (Temel PDR Akışı)

```
Accelerometer / Gyroscope
(İvmeölçer / Jiroskop)
          │
          ▼
    Preprocessing
     (Ön İşleme)
          │
          ├───────────────► Motion Classification
          │                 (Hareket Sınıflandırma)
          ▼
    Step Detection
     (Adım Tespiti)
          │
          ▼
 Step Length Estimation
(Adım Uzunluğu Tahmini)
          │
          ├───────────────► Heading Estimation
          │                 (Yön Tahmini)
          ▼
       PDR Update
    (PDR Güncellemesi)
          │
          ▼
Local East/North Position
(Yerel Doğu/Kuzey Konumu)
```

---

# 32. Sensor Quality Engine (Sensör Kalite Motoru)

The Sensor Quality Engine will determine whether major navigation measurements should be treated as normal, degraded, or unavailable. *(Sensör Kalite Motoru temel navigasyon ölçümlerinin normal, bozulmuş veya kullanılamaz olarak ele alınıp alınmayacağını belirleyecektir.)*

The first implementation may use deterministic rules and platform-provided quality indicators. *(İlk uygulama deterministik kurallar ve platform tarafından sağlanan kalite göstergelerini kullanabilir.)*

A separate machine learning model is not required for the first sensor quality implementation. *(İlk sensör kalite uygulaması için ayrı bir makine öğrenmesi modeli gerekli değildir.)*

---

# 33. Quality Inputs (Kalite Girdileri)

Potential quality inputs may include GNSS accuracy, magnetometer consistency, gyroscope stability, ARCore tracking state, sensor event gaps, and estimator residuals. *(Potansiyel kalite girdileri GNSS doğruluğu, manyetometre tutarlılığı, jiroskop kararlılığı, ARCore takip durumu, sensör olay boşlukları ve tahmin motoru residual değerlerini içerebilir.)*

The exact quality rules will be determined through measured device behavior. *(Kesin kalite kuralları ölçülen cihaz davranışı üzerinden belirlenecektir.)*

Quality information will be consumed by the fusion and uncertainty layers. *(Kalite bilgisi füzyon ve belirsizlik katmanları tarafından kullanılacaktır.)*

---

# 34. Fusion Layer (Füzyon Katmanı)

The Fusion Layer will combine multiple navigation estimates into a unified system state. *(Füzyon Katmanı birden fazla navigasyon tahminini birleşik bir sistem durumunda birleştirecektir.)*

The Extended Kalman Filter is the primary candidate for the final state estimator. *(Genişletilmiş Kalman Filtresi nihai durum tahmin motoru için birincil adaydır.)*

The architecture will allow the fusion implementation to evolve without changing the public interfaces of upstream sensors or downstream user-interface modules. *(Mimari füzyon uygulamasının yukarı akış sensörlerin veya aşağı akış kullanıcı arayüzü modüllerinin genel arayüzlerini değiştirmeden gelişmesine olanak sağlayacaktır.)*

---

# 35. Candidate Fusion Inputs (Aday Füzyon Girdileri)

The fusion system may receive PDR displacement, heading observations, ARCore relative displacement, motion state, sensor confidence, and GNSS corrections when GNSS use is allowed. *(Füzyon sistemi GNSS kullanımına izin verildiğinde PDR yer değiştirmesi, yön gözlemleri, ARCore göreli yer değiştirme, hareket durumu, sensör güveni ve GNSS düzeltmelerini alabilir.)*

Not every measurement source will be mandatory at every time step. *(Her ölçüm kaynağı her zaman adımında zorunlu olmayacaktır.)*

The fusion architecture must explicitly support missing optional measurements. *(Füzyon mimarisi eksik isteğe bağlı ölçümleri açıkça desteklemelidir.)*

---

# 36. Candidate EKF State (Aday EKF Durumu)

The initial EKF state may include local east position, north position, east velocity, north velocity, and heading. *(İlk EKF durumu yerel doğu konumu, kuzey konumu, doğu hızı, kuzey hızı ve yönü içerebilir.)*

Additional states such as gyroscope bias or step-length scale may be introduced only if experiments justify the added complexity. *(Jiroskop bias veya adım uzunluğu ölçeği gibi ek durumlar yalnızca deneyler ek karmaşıklığı gerekçelendirirse dahil edilebilir.)*

The final state vector will be frozen in the dedicated sensor fusion document. *(Nihai durum vektörü özel sensör füzyonu dokümanında sabitlenecektir.)*

---

# 37. Fusion Architecture Flow (Füzyon Mimarisi Akışı)

```
                  PDR Estimate
                  (PDR Tahmini)
                       │
Heading Estimate ──────┤
(Yön Tahmini)          │
                       │
ARCore Pose ───────────┼──────► Fusion Engine / EKF
(ARCore Pozu)          │       (Füzyon Motoru / EKF)
                       │                 │
Sensor Quality ────────┤                 ▼
(Sensör Kalitesi)      │          Navigation State
                       │          (Navigasyon Durumu)
Motion Context ────────┘                 │
(Hareket Bağlamı)                        ▼
                               Position + Confidence
                                (Konum + Güven)
```

GNSS may enter the fusion engine only in navigation states that explicitly permit GNSS updates. *(GNSS yalnızca GNSS güncellemelerine açıkça izin veren navigasyon durumlarında füzyon motoruna girebilir.)*

---

# 38. Navigation State Model (Navigasyon Durum Modeli)

The Navigation State will represent the current best estimate of the user’s movement and position. *(Navigasyon Durumu kullanıcının hareketi ve konumuna ilişkin mevcut en iyi tahmini temsil edecektir.)*

It should contain the local estimated position, optional geographic position, heading, travelled distance, motion state, timestamp, and confidence information. *(Yerel tahmini konumu, isteğe bağlı coğrafi konumu, yönü, kat edilen mesafeyi, hareket durumunu, zaman damgasını ve güven bilgisini içermelidir.)*

The user interface will consume this state instead of directly subscribing to every navigation algorithm. *(Kullanıcı arayüzü her navigasyon algoritmasına doğrudan abone olmak yerine bu durumu kullanacaktır.)*

---

# 39. Position Uncertainty Engine (Konum Belirsizliği Motoru)

The Position Uncertainty Engine will estimate or represent the confidence associated with the current navigation output. *(Konum Belirsizliği Motoru mevcut navigasyon çıktısıyla ilişkili güveni tahmin edecek veya temsil edecektir.)*

The initial implementation may combine estimator covariance, elapsed GNSS-denied time, distance travelled, and sensor quality indicators. *(İlk uygulama tahmin motoru kovaryansını, GNSS kesintisinde geçen süreyi, kat edilen mesafeyi ve sensör kalite göstergelerini birleştirebilir.)*

The output may be expressed numerically or through defined confidence categories. *(Çıktı sayısal olarak veya tanımlı güven kategorileri üzerinden ifade edilebilir.)*

---

# 40. Uncertainty Design Principle (Belirsizlik Tasarım İlkesi)

Uncertainty must be treated as a first-class navigation output rather than an optional visual decoration. *(Belirsizlik, isteğe bağlı görsel bir süs yerine birinci sınıf bir navigasyon çıktısı olarak ele alınmalıdır.)*

Confidence should generally decrease when the estimator loses reliable information sources or accumulates longer uncorrected dead reckoning. *(Tahmin motoru güvenilir bilgi kaynaklarını kaybettiğinde veya daha uzun süre düzeltilmemiş ölü hesaplama biriktirdiğinde güven genel olarak azalmalıdır.)*

The system must not claim precision that is unsupported by the estimator state. *(Sistem tahmin motoru durumu tarafından desteklenmeyen bir hassasiyet iddiasında bulunmamalıdır.)*

---

# 41. Navigation Mode Manager (Navigasyon Mod Yöneticisi)

The Navigation Mode Manager will control whether GNSS information is permitted to influence the estimator. *(Navigasyon Mod Yöneticisi GNSS bilgisinin tahmin motorunu etkileyip etkileyemeyeceğini kontrol edecektir.)*

It will coordinate GNSS Mode, Evaluation Mode, GNSS-Denied Mode, and recovery transitions. *(GNSS Modu, Değerlendirme Modu, GNSS Kesintili Mod ve geri kazanım geçişlerini koordine edecektir.)*

Every mode transition will be timestamped and recorded. *(Her mod geçişi zaman damgalı olacak ve kaydedilecektir.)*

---

# 42. High-Level Navigation State Machine (Üst Seviye Navigasyon Durum Makinesi)

```
IDLE (BOŞTA)
   │
   ▼
READINESS CHECK (HAZIRLIK KONTROLÜ)
   │
   ▼
INITIALIZING GNSS (GNSS BAŞLATILIYOR)
   │
   ▼
GNSS READY (GNSS HAZIR)
   │
   ├──────────────► NORMAL GNSS MODE (NORMAL GNSS MODU)
   │
   ▼
EVALUATION ARMED (DEĞERLENDİRME HAZIR)
   │
   ▼
GNSS-DENIED ACTIVE (GNSS KESİNTİLİ AKTİF)
   │
   ├──────────────► DEGRADED LOCAL NAVIGATION
   │                 (BOZULMUŞ YEREL NAVİGASYON)
   │
   ▼
GNSS RECOVERED (GNSS GERİ GELDİ)
   │
   ▼
RELOCALIZATION (YENİDEN KONUMLANDIRMA)
   │
   ▼
SESSION COMPLETE (OTURUM TAMAMLANDI)
```

The detailed transition rules will be defined in the dedicated Navigation Modes and State Machine document. *(Ayrıntılı geçiş kuralları özel Navigasyon Modları ve Durum Makinesi dokümanında tanımlanacaktır.)*

---

# 43. Application and Experiment Layer (Uygulama ve Deney Katmanı)

The Application and Experiment Layer will coordinate user actions, navigation modes, session lifecycle, experiment configuration, and readiness checks. *(Uygulama ve Deney Katmanı kullanıcı işlemlerini, navigasyon modlarını, oturum yaşam döngüsünü, deney yapılandırmasını ve hazırlık kontrollerini koordine edecektir.)*

It will not perform low-level sensor mathematics. *(Düşük seviyeli sensör matematiğini gerçekleştirmeyecektir.)*

Its responsibility will be orchestration rather than numerical estimation. *(Sorumluluğu sayısal tahmin yerine orkestrasyon olacaktır.)*

---

# 44. Session Manager (Oturum Yöneticisi)

The Session Manager will create and control NAVGUARD experiment sessions. *(Oturum Yöneticisi NAVGUARD deney oturumlarını oluşturacak ve kontrol edecektir.)*

Each session will have a unique identifier and immutable start metadata. *(Her oturum benzersiz bir tanımlayıcıya ve değiştirilemez başlangıç metadata bilgisine sahip olacaktır.)*

The manager will coordinate session start, stop, configuration freeze, and finalization. *(Yönetici oturum başlatma, durdurma, yapılandırma sabitleme ve sonlandırma işlemlerini koordine edecektir.)*

---

# 45. Session Configuration Snapshot (Oturum Yapılandırma Anlık Görüntüsü)

Every formal experiment will capture the active configuration when the session begins. *(Her resmî deney oturum başladığında aktif yapılandırmayı kaydedecektir.)*

The snapshot should include navigation configuration, enabled sensors, model version, algorithm parameters, application version, and device baseline identifier. *(Anlık görüntü navigasyon yapılandırmasını, etkin sensörleri, model sürümünü, algoritma parametrelerini, uygulama sürümünü ve cihaz temel referans tanımlayıcısını içermelidir.)*

This snapshot will make results traceable to the exact system configuration used during the experiment. *(Bu anlık görüntü sonuçların deney sırasında kullanılan kesin sistem yapılandırmasına kadar izlenebilir olmasını sağlayacaktır.)*

---

# 46. Readiness Manager (Hazırlık Yöneticisi)

The Readiness Manager will determine whether the selected navigation configuration can safely begin. *(Hazırlık Yöneticisi seçilen navigasyon yapılandırmasının güvenli şekilde başlayıp başlayamayacağını belirleyecektir.)*

It will check mandatory sensors, permissions, GNSS condition, storage availability, AI runtime status, and ARCore status where applicable. *(Zorunlu sensörleri, izinleri, GNSS durumunu, depolama kullanılabilirliğini, yapay zekâ çalışma zamanı durumunu ve uygulanabilir olduğunda ARCore durumunu kontrol edecektir.)*

A configuration-specific readiness result will be produced before each formal experiment. *(Her resmî deneyden önce yapılandırmaya özgü bir hazırlık sonucu üretilecektir.)*

---

# 47. Configuration Manager (Yapılandırma Yöneticisi)

The Configuration Manager will provide centrally controlled navigation and experiment parameters. *(Yapılandırma Yöneticisi merkezi olarak kontrol edilen navigasyon ve deney parametrelerini sağlayacaktır.)*

Parameters should not be scattered across unrelated source files. *(Parametreler ilgisiz kaynak dosyalarına dağılmamalıdır.)*

Configuration changes relevant to experiments must be recordable and versionable. *(Deneylerle ilgili yapılandırma değişiklikleri kaydedilebilir ve sürümlenebilir olmalıdır.)*

---

# 48. Experimental Navigation Profiles (Deneysel Navigasyon Profilleri)

The architecture will support predefined navigation configurations for comparative experiments. *(Mimari karşılaştırmalı deneyler için önceden tanımlanmış navigasyon yapılandırmalarını destekleyecektir.)*

### Configuration A — PDR Only (Yapılandırma A — Yalnızca PDR)

This profile will use the minimum step-based pedestrian dead reckoning pipeline. *(Bu profil minimum adım tabanlı yaya ölü hesaplama hattını kullanacaktır.)*

### Configuration B — PDR + Heading Fusion (Yapılandırma B — PDR + Yön Füzyonu)

This profile will add improved heading estimation to the baseline PDR system. *(Bu profil temel PDR sistemine geliştirilmiş yön tahmini ekleyecektir.)*

### Configuration C — PDR + ARCore (Yapılandırma C — PDR + ARCore)

This profile will add ARCore relative movement information. *(Bu profil ARCore göreli hareket bilgisini ekleyecektir.)*

### Configuration D — NAVGUARD AI Fusion (Yapılandırma D — NAVGUARD AI Füzyonu)

This profile will represent the intended full multi-source NAVGUARD architecture. *(Bu profil planlanan tam çok kaynaklı NAVGUARD mimarisini temsil edecektir.)*

---

# 49. Data and Evidence Layer (Veri ve Kanıt Katmanı)

The Data and Evidence Layer will preserve the information required for debugging, reproducibility, offline analysis, and final evaluation. *(Veri ve Kanıt Katmanı hata ayıklama, tekrarlanabilirlik, çevrimdışı analiz ve nihai değerlendirme için gerekli bilgileri koruyacaktır.)*

The architecture will prioritize preserving experimental evidence over minimizing storage at the expense of reproducibility. *(Mimari, tekrarlanabilirlik pahasına depolamayı azaltmak yerine deneysel kanıtları korumaya öncelik verecektir.)*

Retention policies may later reduce redundant data after final formats are validated. *(Nihai formatlar doğrulandıktan sonra saklama politikaları gereksiz veriyi azaltabilir.)*

---

# 50. Logging Engine (Kayıt Motoru)

The Logging Engine will record raw measurements, processed states, estimator outputs, AI results, navigation modes, diagnostics, and evaluation data. *(Kayıt Motoru ham ölçümleri, işlenmiş durumları, tahmin motoru çıktılarını, yapay zekâ sonuçlarını, navigasyon modlarını, tanısal bilgileri ve değerlendirme verilerini kaydedecektir.)*

Logging must occur without significantly disrupting high-frequency sensor acquisition. *(Kayıt işlemi yüksek frekanslı sensör veri toplamayı önemli ölçüde bozmadan gerçekleşmelidir.)*

The logger should support asynchronous or buffered writes where appropriate. *(Kayıt motoru uygun olduğunda asenkron veya tamponlanmış yazma işlemlerini desteklemelidir.)*

---

# 51. Logical Data Streams (Mantıksal Veri Akışları)

The system will distinguish multiple logical data streams inside each session. *(Sistem her oturum içerisinde birden fazla mantıksal veri akışını ayıracaktır.)*

- **Raw Sensor Stream** *(Ham Sensör Akışı)*
- **GNSS Reference Stream** *(GNSS Referans Akışı)*
- **ARCore Pose Stream** *(ARCore Poz Akışı)*
- **AI Inference Stream** *(Yapay Zekâ Çıkarım Akışı)*
- **Step Event Stream** *(Adım Olay Akışı)*
- **Heading Stream** *(Yön Akışı)*
- **PDR State Stream** *(PDR Durum Akışı)*
- **Fusion State Stream** *(Füzyon Durum Akışı)*
- **Quality and Confidence Stream** *(Kalite ve Güven Akışı)*
- **Navigation Mode Event Stream** *(Navigasyon Mod Olay Akışı)*
- **Diagnostic Event Stream** *(Tanısal Olay Akışı)*

---

# 52. Storage Architecture Principle (Depolama Mimarisi İlkesi)

High-frequency raw streams and low-frequency application metadata may use different storage representations if this improves reliability and efficiency. *(Yüksek frekanslı ham akışlar ile düşük frekanslı uygulama metadata bilgileri güvenilirlik ve verimliliği artırıyorsa farklı depolama temsilleri kullanabilir.)*

The exact local database and file formats will be selected in the Technology Stack and Data Storage documents. *(Kesin yerel veritabanı ve dosya formatları Teknoloji Yığını ve Veri Depolama dokümanlarında seçilecektir.)*

All selected formats must support deterministic export and offline analysis. *(Seçilen tüm formatlar deterministik dışa aktarma ve çevrimdışı analizi desteklemelidir.)*

---

# 53. Replay Engine (Yeniden Oynatma Motoru)

The Replay Engine will allow previously recorded sessions to be processed again through navigation algorithms. *(Yeniden Oynatma Motoru daha önce kaydedilmiş oturumların navigasyon algoritmaları üzerinden tekrar işlenmesine olanak sağlayacaktır.)*

Replay will use stored timestamps and measurements instead of new physical sensor input. *(Yeniden oynatma yeni fiziksel sensör girdisi yerine saklanan zaman damgalarını ve ölçümleri kullanacaktır.)*

The objective is to compare algorithm versions on identical sensor evidence. *(Amaç algoritma sürümlerini aynı sensör kanıtı üzerinde karşılaştırmaktır.)*

---

# 54. Replay Architecture (Yeniden Oynatma Mimarisi)

```
Recorded Session
(Kaydedilmiş Oturum)
        │
        ▼
    Replay Reader
 (Yeniden Oynatma Okuyucusu)
        │
        ▼
Common Internal Events
(Ortak Dahili Olaylar)
        │
        ▼
Same Processing Pipeline
(Aynı İşleme Hattı)
        │
        ▼
Selected Estimator Configuration
(Seçilen Tahmin Motoru Yapılandırması)
        │
        ▼
Evaluation Output
(Değerlendirme Çıktısı)
```

Live acquisition and replay should converge onto the same internal processing interfaces wherever practical. *(Canlı veri toplama ve yeniden oynatma uygulanabilir olduğu ölçüde aynı dahili işleme arayüzlerinde birleşmelidir.)*

---

# 55. Evaluation Engine (Değerlendirme Motoru)

The Evaluation Engine will compare estimated trajectories against independently recorded GNSS reference data. *(Değerlendirme Motoru tahmini rotaları bağımsız olarak kaydedilmiş GNSS referans verisiyle karşılaştıracaktır.)*

It will align estimates and ground truth by time before calculating position error. *(Konum hatasını hesaplamadan önce tahminleri ve gerçek referansı zamana göre hizalayacaktır.)*

It will generate standardized metrics for comparison across navigation configurations. *(Navigasyon yapılandırmaları arasında karşılaştırma için standartlaştırılmış metrikler üretecektir.)*

---

# 56. Evaluation Architecture Separation (Değerlendirme Mimarisi Ayrımı)

The Evaluation Engine will not provide corrections to an active GNSS-denied estimator during formal experiments. *(Değerlendirme Motoru resmî deneyler sırasında aktif bir GNSS kesintili tahmin motoruna düzeltme sağlamayacaktır.)*

Evaluation is an observation and measurement process, not a navigation input process. *(Değerlendirme bir navigasyon girdi süreci değil gözlem ve ölçüm sürecidir.)*

This distinction will be enforced architecturally rather than relying only on developer discipline. *(Bu ayrım yalnızca geliştirici disiplinine güvenmek yerine mimari olarak uygulanacaktır.)*

---

# 57. Evaluation Metrics Pipeline (Değerlendirme Metrikleri Hattı)

```
Estimated Trajectory ───────────┐
(Tahmini Rota)                  │
                                ▼
                        Temporal Alignment
                        (Zamansal Hizalama)
                                ▲
GNSS Ground Truth ──────────────┘
(GNSS Gerçek Referansı)
                                │
                                ▼
                        Error Calculation
                         (Hata Hesaplama)
                                │
                                ▼
          Mean / Median / RMSE / Final Error / Drift
          (Ortalama / Medyan / RMSE / Son Hata / Sürüklenme)
```

---

# 58. Presentation Layer (Sunum Katmanı)

The Presentation Layer will display system state without becoming a source of navigation truth. *(Sunum Katmanı navigasyon gerçeğinin kaynağı haline gelmeden sistem durumunu gösterecektir.)*

UI components will consume immutable or controlled navigation-state snapshots where practical. *(UI bileşenleri uygulanabilir olduğu ölçüde değiştirilemez veya kontrollü navigasyon durumu anlık görüntülerini kullanacaktır.)*

The interface will not perform independent position calculations that differ from the estimator. *(Arayüz tahmin motorundan farklı bağımsız konum hesaplamaları gerçekleştirmeyecektir.)*

---

# 59. Planned Primary Screens (Planlanan Temel Ekranlar)

The architecture will support the following logical application screens. *(Mimari aşağıdaki mantıksal uygulama ekranlarını destekleyecektir.)*

- **Home / System Readiness** *(Ana Sayfa / Sistem Hazırlığı)*
- **Calibration and Initialization** *(Kalibrasyon ve Başlatma)*
- **Live Navigation** *(Canlı Navigasyon)*
- **Sensor Monitor** *(Sensör İzleme)*
- **AI Monitor** *(Yapay Zekâ İzleme)*
- **Experiment Configuration** *(Deney Yapılandırması)*
- **Session History** *(Oturum Geçmişi)*
- **Session Detail** *(Oturum Detayı)*
- **Route Comparison** *(Rota Karşılaştırması)*
- **Developer / Research Diagnostics** *(Geliştirici / Araştırma Tanısı)*
- **Settings** *(Ayarlar)*

The final UI structure will be frozen in the Mobile UI/UX Specification. *(Nihai kullanıcı arayüzü yapısı Mobil UI/UX Şartnamesinde sabitlenecektir.)*

---

# 60. Real-Time Data Flow (Gerçek Zamanlı Veri Akışı)

The primary runtime data flow will proceed from physical measurements toward increasingly abstract navigation states. *(Temel çalışma zamanı veri akışı fiziksel ölçümlerden giderek daha soyut navigasyon durumlarına doğru ilerleyecektir.)*

```
Physical Sensors / GNSS / Camera
(Fiziksel Sensörler / GNSS / Kamera)
                │
                ▼
       Acquisition Managers
       (Veri Toplama Yöneticileri)
                │
                ▼
       Timestamp Alignment
      (Zaman Damgası Hizalama)
                │
                ▼
          Preprocessing
           (Ön İşleme)
                │
        ┌───────┼─────────┬──────────┐
        ▼       ▼         ▼          ▼
      Step    Heading    Motion AI   ARCore
      (Adım)   (Yön)     (Hareket AI)
        │       │         │          │
        └───────┴────┬────┴──────────┘
                     ▼
              PDR / Quality
            (PDR / Kalite)
                     │
                     ▼
               Fusion Engine
              (Füzyon Motoru)
                     │
                     ▼
              Navigation State
             (Navigasyon Durumu)
                ┌────┴─────┐
                ▼          ▼
               UI        Logger
            (Arayüz)     (Kayıt)
```

---

# 61. Logging Data Flow (Kayıt Veri Akışı)

Logging will occur in parallel with navigation processing rather than only at the end of the pipeline. *(Kayıt işlemi yalnızca hattın sonunda değil navigasyon işlemesiyle paralel gerçekleşecektir.)*

Raw evidence and high-level outputs will therefore both be preserved. *(Bu nedenle hem ham kanıtlar hem de yüksek seviyeli çıktılar korunacaktır.)*

```
Acquisition ─────────────► Raw Logger
(Veri Toplama)             (Ham Kayıt)

Preprocessing ────────────► Processed Logger
(Ön İşleme)                (İşlenmiş Kayıt)

AI / Step / Heading ──────► Interpretation Logger
(AI / Adım / Yön)          (Yorumlama Kaydı)

Fusion ───────────────────► Estimator Logger
(Füzyon)                   (Tahmin Motoru Kaydı)

GNSS Ground Truth ────────► Evaluation Logger
(GNSS Gerçek Referansı)    (Değerlendirme Kaydı)
```

---

# 62. Real-Time and Offline Processing Separation (Gerçek Zamanlı ve Çevrimdışı İşleme Ayrımı)

NAVGUARD will distinguish real-time mobile processing from computationally heavier offline analysis. *(NAVGUARD gerçek zamanlı mobil işlemeyi hesaplama açısından daha ağır çevrimdışı analizden ayıracaktır.)*

Real-time processing must contain only the functionality required for active navigation, safety of the experiment, logging, and user feedback. *(Gerçek zamanlı işleme yalnızca aktif navigasyon, deney güvenliği, kayıt ve kullanıcı geri bildirimi için gerekli işlevleri içermelidir.)*

Detailed statistical analysis, model training, experiment aggregation, and advanced visualization may occur on the development computer. *(Ayrıntılı istatistiksel analiz, model eğitimi, deney birleştirme ve gelişmiş görselleştirme geliştirme bilgisayarında gerçekleştirilebilir.)*

---

# 63. On-Device Responsibilities (Cihaz Üzeri Sorumluluklar)

The Android device will perform sensor acquisition, preprocessing required for live operation, motion inference, PDR, heading estimation, fusion, confidence estimation, local logging, and user-interface updates. *(Android cihaz canlı çalışma için gerekli sensör veri toplama, ön işleme, hareket çıkarımı, PDR, yön tahmini, füzyon, güven tahmini, yerel kayıt ve kullanıcı arayüzü güncellemelerini gerçekleştirecektir.)*

The core navigation session must therefore be self-contained on the smartphone. *(Bu nedenle temel navigasyon oturumu akıllı telefon üzerinde bağımsız olmalıdır.)*

---

# 64. Development Computer Responsibilities (Geliştirme Bilgisayarı Sorumlulukları)

The development computer will perform machine learning training, detailed dataset preprocessing, offline replay experiments, statistical analysis, visualization, and model conversion. *(Geliştirme bilgisayarı makine öğrenmesi eğitimi, ayrıntılı veri seti ön işleme, çevrimdışı yeniden oynatma deneyleri, istatistiksel analiz, görselleştirme ve model dönüştürme işlemlerini gerçekleştirecektir.)*

It may also generate experiment reports from exported mobile data. *(Dışa aktarılmış mobil veriden deney raporları da oluşturabilir.)*

The development computer must not be required for an active field navigation session. *(Aktif bir saha navigasyon oturumu için geliştirme bilgisayarı gerekli olmamalıdır.)*

---

# 65. AI Training Architecture (Yapay Zekâ Eğitim Mimarisi)

The machine learning development pipeline will remain outside the mobile runtime application. *(Makine öğrenmesi geliştirme hattı mobil çalışma zamanı uygulamasının dışında kalacaktır.)*

```
NAVGUARD Sensor Logger
(NAVGUARD Sensör Kaydı)
        │
        ▼
Exported Dataset
(Dışa Aktarılan Veri Seti)
        │
        ▼
Python Preprocessing
(Python Ön İşleme)
        │
        ▼
Train / Validation / Test Split
(Eğitim / Doğrulama / Test Bölmesi)
        │
        ▼
Baseline + Candidate Models
(Temel + Aday Modeller)
        │
        ▼
Evaluation
(Değerlendirme)
        │
        ▼
Selected Model
(Seçilen Model)
        │
        ▼
Mobile Model Conversion
(Mobil Model Dönüşümü)
        │
        ▼
NAVGUARD Android Runtime
(NAVGUARD Android Çalışma Zamanı)
```

The final mobile model will be versioned and linked to experiment records. *(Nihai mobil model sürümlenecek ve deney kayıtlarıyla ilişkilendirilecektir.)*

---

# 66. Module Dependency Principle (Modül Bağımlılık İlkesi)

Dependencies should generally flow from higher-level orchestration modules toward clearly defined lower-level interfaces rather than through arbitrary cross-module references. *(Bağımlılıklar genel olarak keyfi modüller arası referanslar yerine daha yüksek seviyeli orkestrasyon modüllerinden açıkça tanımlanmış düşük seviyeli arayüzlere doğru akmalıdır.)*

Navigation modules should consume interfaces rather than directly depend on user-interface implementations. *(Navigasyon modülleri kullanıcı arayüzü uygulamalarına doğrudan bağımlı olmak yerine arayüzleri kullanmalıdır.)*

This design will improve testability and allow offline replay implementations to reuse the same algorithms. *(Bu tasarım test edilebilirliği artıracak ve çevrimdışı yeniden oynatma uygulamalarının aynı algoritmaları yeniden kullanmasına olanak sağlayacaktır.)*

---

# 67. Suggested Logical Module Boundaries (Önerilen Mantıksal Modül Sınırları)

```
core/
  timing
  math
  coordinates
  configuration

platform/
  sensors
  gnss
  arcore
  permissions

navigation/
  preprocessing
  step_detection
  heading
  step_length
  pdr
  fusion
  uncertainty
  relocalization

ai/
  motion_classifier
  model_runtime
  feature_pipeline

data/
  session
  logger
  storage
  export
  replay

evaluation/
  alignment
  metrics
  benchmark

presentation/
  screens
  controllers
  view_models
```

This structure is a logical architecture proposal rather than a frozen source-code directory tree. *(Bu yapı sabitlenmiş bir kaynak kodu klasör ağacı yerine mantıksal bir mimari öneridir.)*

The final repository structure will be adapted to Flutter and Android implementation requirements. *(Nihai repository yapısı Flutter ve Android uygulama gereksinimlerine göre uyarlanacaktır.)*

---

# 68. Concurrency Architecture (Eşzamanlılık Mimarisi)

High-frequency sensor processing must not depend on the rendering frequency of the Flutter user interface. *(Yüksek frekanslı sensör işleme Flutter kullanıcı arayüzünün render frekansına bağlı olmamalıdır.)*

Data acquisition, preprocessing, AI inference, logging, and UI rendering may execute at different logical rates. *(Veri toplama, ön işleme, yapay zekâ çıkarımı, kayıt ve UI render işlemleri farklı mantıksal hızlarda çalışabilir.)*

The architecture will therefore avoid coupling every sensor event to a visible UI refresh. *(Bu nedenle mimari her sensör olayını görünür bir UI yenilemesine bağlamaktan kaçınacaktır.)*

---

# 69. Update Rate Separation (Güncelleme Hızı Ayrımı)

Sensor acquisition may operate near the selected IMU frequency. *(Sensör veri toplama seçilen IMU frekansına yakın çalışabilir.)*

Motion AI may operate once per sensor window rather than once per individual sample. *(Hareket yapay zekâsı her bireysel örnek yerine her sensör penceresinde bir kez çalışabilir.)*

Position visualization may operate at a lower frequency than internal estimator updates. *(Konum görselleştirmesi dahili tahmin motoru güncellemelerinden daha düşük bir frekansta çalışabilir.)*

Logging frequency will depend on the source stream. *(Kayıt frekansı kaynak akışına bağlı olacaktır.)*

---

# 70. Error Isolation Architecture (Hata İzolasyon Mimarisi)

Failures should be contained within the smallest practical subsystem. *(Hatalar uygulanabilir en küçük alt sistem içerisinde sınırlandırılmalıdır.)*

A logging warning should not automatically terminate navigation when data integrity remains valid. *(Veri bütünlüğü geçerli kalıyorsa bir kayıt uyarısı navigasyonu otomatik olarak sonlandırmamalıdır.)*

An AI inference failure should trigger a deterministic fallback rather than crash the entire session. *(Bir yapay zekâ çıkarım hatası tüm oturumu çökertmek yerine deterministik bir geri dönüşü tetiklemelidir.)*

An ARCore failure should disable or reduce ARCore contribution while preserving PDR. *(Bir ARCore hatası PDR’yi korurken ARCore katkısını devre dışı bırakmalı veya azaltmalıdır.)*

A mandatory sensor failure may invalidate the active experiment and require controlled termination. *(Zorunlu bir sensör hatası aktif deneyi geçersiz kılabilir ve kontrollü sonlandırma gerektirebilir.)*

---

# 71. Fallback Hierarchy (Geri Dönüş Hiyerarşisi)

NAVGUARD will use a predefined degradation hierarchy. *(NAVGUARD önceden tanımlanmış bir performans kaybı hiyerarşisi kullanacaktır.)*

```
Full NAVGUARD Fusion
(Tam NAVGUARD Füzyonu)
        │
        ▼
PDR + Heading + AI
(PDR + Yön + AI)
        │
        ▼
PDR + Heading
(PDR + Yön)
        │
        ▼
Baseline PDR
(Temel PDR)
        │
        ▼
Experiment Invalid / Controlled Stop
(Deney Geçersiz / Kontrollü Durdurma)
```

The exact fallback transition conditions will be defined by module readiness and quality rules. *(Kesin geri dönüş geçiş koşulları modül hazırlığı ve kalite kuralları tarafından tanımlanacaktır.)*

---

# 72. AI Failure Fallback (Yapay Zekâ Hata Geri Dönüşü)

If motion inference becomes unavailable, the navigation system will fall back to deterministic motion assumptions where technically safe. *(Hareket çıkarımı kullanılamaz hale gelirse navigasyon sistemi teknik olarak güvenli olduğu durumlarda deterministik hareket varsayımlarına geri dönecektir.)*

The failure will be recorded in the session metadata. *(Hata oturum metadata bilgisine kaydedilecektir.)*

An AI runtime failure must not silently generate artificial motion classes. *(Bir yapay zekâ çalışma zamanı hatası sessizce yapay hareket sınıfları üretmemelidir.)*

---

# 73. ARCore Failure Fallback (ARCore Hata Geri Dönüşü)

If ARCore tracking becomes unavailable, its measurements will be excluded from fusion. *(ARCore takibi kullanılamaz hale gelirse ölçümleri füzyondan çıkarılacaktır.)*

PDR and other available navigation components will continue operating. *(PDR ve diğer mevcut navigasyon bileşenleri çalışmaya devam edecektir.)*

The position confidence may decrease to reflect the lost information source. *(Konum güveni kaybedilen bilgi kaynağını yansıtmak için azalabilir.)*

---

# 74. Magnetometer Degradation Fallback (Manyetometre Bozulma Geri Dönüşü)

If magnetic measurements become unreliable, heading estimation will reduce dependence on the magnetometer. *(Manyetik ölçümler güvenilmez hale gelirse yön tahmini manyetometreye olan bağımlılığı azaltacaktır.)*

Short-term gyroscope or alternative orientation information may temporarily carry more influence. *(Kısa süreli jiroskop veya alternatif yönelim bilgisi geçici olarak daha fazla etkiye sahip olabilir.)*

The event will be reflected in the sensor quality state. *(Olay sensör kalite durumuna yansıtılacaktır.)*

---

# 75. GNSS Loss Architecture (GNSS Kaybı Mimarisi)

GNSS loss is an expected operational condition rather than an application error. *(GNSS kaybı bir uygulama hatası yerine beklenen bir çalışma koşuludur.)*

The transition to GNSS-Denied Mode must therefore be handled as a controlled navigation-state transition. *(Bu nedenle GNSS Kesintili Moda geçiş kontrollü bir navigasyon durum geçişi olarak yönetilmelidir.)*

The estimator must retain the last accepted global anchor and continue in the local navigation frame. *(Tahmin motoru son kabul edilen global çapayı korumalı ve yerel navigasyon koordinat sisteminde devam etmelidir.)*

---

# 76. Relocalization Architecture (Yeniden Konumlandırma Mimarisi)

When GNSS becomes available again, the system will compare the current estimated position against the accepted GNSS position. *(GNSS tekrar kullanılabilir hale geldiğinde sistem mevcut tahmini konumu kabul edilen GNSS konumuyla karşılaştıracaktır.)*

The difference will be recorded as an experimental error measurement. *(Fark deneysel bir hata ölçümü olarak kaydedilecektir.)*

The target architecture will then support controlled correction or re-anchoring. *(Hedef mimari daha sonra kontrollü düzeltme veya yeniden çapa oluşturmayı destekleyecektir.)*

Relocalization must not overwrite the historical GNSS-denied trajectory. *(Yeniden konumlandırma geçmiş GNSS kesintili rotanın üzerine yazmamalıdır.)*

---

# 77. Offline-First Architecture (Çevrimdışı Öncelikli Mimari)

The core runtime architecture will not require network communication between navigation modules. *(Temel çalışma zamanı mimarisi navigasyon modülleri arasında ağ iletişimi gerektirmeyecektir.)*

AI inference will remain local. *(Yapay zekâ çıkarımı yerel kalacaktır.)*

Sensor processing will remain local. *(Sensör işleme yerel kalacaktır.)*

Session storage will remain local during field experiments. *(Oturum depolama saha deneyleri sırasında yerel kalacaktır.)*

Internet-dependent map tiles, if temporarily used, will remain outside the core estimator architecture. *(Geçici olarak kullanılırsa internet bağımlı harita tile’ları temel tahmin motoru mimarisinin dışında kalacaktır.)*

---

# 78. Security Architecture Principle (Güvenlik Mimarisi İlkesi)

Sensor, position, and experiment data will remain local by default. *(Sensör, konum ve deney verileri varsayılan olarak yerel kalacaktır.)*

No module will automatically upload experimental data to a remote server as part of core navigation. *(Hiçbir modül temel navigasyonun bir parçası olarak deneysel verileri otomatik şekilde uzak bir sunucuya yüklemeyecektir.)*

Data export will be explicit and controlled. *(Veri dışa aktarma açık ve kontrollü olacaktır.)*

---

# 79. Privacy Architecture Principle (Gizlilik Mimarisi İlkesi)

ARCore camera access will be used for tracking rather than routine image retention. *(ARCore kamera erişimi rutin görüntü saklama yerine takip için kullanılacaktır.)*

Camera frames will not be stored by default. *(Kamera kareleri varsayılan olarak saklanmayacaktır.)*

Geographic ground-truth records will be treated as experiment data and stored under the session model. *(Coğrafi gerçek referans kayıtları deney verisi olarak ele alınacak ve oturum modeli altında saklanacaktır.)*

---

# 80. Testability Architecture (Test Edilebilirlik Mimarisi)

Every major navigation module should support testing independently from the full user interface. *(Her temel navigasyon modülü tam kullanıcı arayüzünden bağımsız olarak test edilmeyi desteklemelidir.)*

Pure mathematical transformations should be implemented in testable components without Android dependencies where practical. *(Saf matematiksel dönüşümler uygulanabilir olduğu ölçüde Android bağımlılıkları olmayan test edilebilir bileşenlerde uygulanmalıdır.)*

Recorded sensor sessions should support deterministic algorithm replay. *(Kaydedilmiş sensör oturumları deterministik algoritma yeniden oynatmayı desteklemelidir.)*

---

# 81. Unit-Testable Components (Birim Test Edilebilir Bileşenler)

The following components should be independently unit-testable. *(Aşağıdaki bileşenler bağımsız olarak birim test edilebilir olmalıdır.)*

- **Coordinate transformations** *(Koordinat dönüşümleri)*
- **Timestamp conversion** *(Zaman damgası dönüşümü)*
- **Signal filters where deterministic** *(Deterministik sinyal filtreleri)*
- **Step event logic** *(Adım olay mantığı)*
- **PDR displacement equations** *(PDR yer değiştirme denklemleri)*
- **Heading normalization** *(Yön normalizasyonu)*
- **Error metrics** *(Hata metrikleri)*
- **Configuration validation** *(Yapılandırma doğrulama)*
- **Data serialization and parsing** *(Veri serileştirme ve ayrıştırma)*

---

# 82. Integration-Testable Components (Entegrasyon Test Edilebilir Bileşenler)

Sensor acquisition and logging should be tested together. *(Sensör veri toplama ve kayıt birlikte test edilmelidir.)*

AI preprocessing and model inference should be tested together. *(Yapay zekâ ön işleme ve model çıkarımı birlikte test edilmelidir.)*

ARCore tracking and fusion input handling should be tested together. *(ARCore takibi ve füzyon girdi yönetimi birlikte test edilmelidir.)*

GNSS ground-truth isolation and evaluation logging must be tested together. *(GNSS gerçek referans izolasyonu ve değerlendirme kaydı birlikte test edilmelidir.)*

---

# 83. Architecture for Benchmark Reproducibility (Benchmark Tekrarlanabilirlik Mimarisi)

The same recorded input session should be reusable across multiple estimator configurations. *(Aynı kaydedilmiş girdi oturumu birden fazla tahmin motoru yapılandırmasında yeniden kullanılabilir olmalıdır.)*

Configuration A, B, C, and D should therefore consume compatible replay events. *(Bu nedenle A, B, C ve D yapılandırmaları uyumlu yeniden oynatma olaylarını kullanmalıdır.)*

This architecture will enable paired comparisons without physically repeating every route. *(Bu mimari her rotayı fiziksel olarak tekrar etmeden eşleştirilmiş karşılaştırmalara olanak sağlayacaktır.)*

---

# 84. Architecture for Research Evidence (Araştırma Kanıtı Mimarisi)

Every final result should be traceable to the session that generated it. *(Her nihai sonuç kendisini üreten oturuma kadar izlenebilir olmalıdır.)*

Every session should be traceable to a device baseline, application version, model version, and experiment configuration. *(Her oturum bir cihaz temel referansına, uygulama sürümüne, model sürümüne ve deney yapılandırmasına kadar izlenebilir olmalıdır.)*

Every reported metric should be reproducible from stored experiment data. *(Raporlanan her metrik saklanan deney verilerinden yeniden üretilebilir olmalıdır.)*

---

# 85. Performance Architecture (Performans Mimarisi)

NAVGUARD will prioritize deterministic and efficient runtime behavior over unnecessary architectural complexity. *(NAVGUARD gereksiz mimari karmaşıklık yerine deterministik ve verimli çalışma zamanı davranışına öncelik verecektir.)*

High-frequency operations must avoid excessive object allocation and unnecessary UI updates. *(Yüksek frekanslı işlemler aşırı nesne oluşturma ve gereksiz UI güncellemelerinden kaçınmalıdır.)*

AI inference will operate at a rate appropriate to its input window rather than the raw sensor sampling rate. *(Yapay zekâ çıkarımı ham sensör örnekleme hızı yerine girdi penceresine uygun bir hızda çalışacaktır.)*

Logging should use buffering or batching if individual synchronous writes create performance problems. *(Bireysel senkron yazmalar performans problemi oluşturursa kayıt tamponlama veya batching kullanmalıdır.)*

---

# 86. Resource Ownership Principle (Kaynak Sahipliği İlkesi)

Each physical or platform resource should have one clearly responsible runtime manager. *(Her fiziksel veya platform kaynağının açıkça sorumlu tek bir çalışma zamanı yöneticisi olmalıdır.)*

Sensor listeners should be controlled by the Sensor Acquisition Manager. *(Sensör listener’ları Sensör Veri Toplama Yöneticisi tarafından kontrol edilmelidir.)*

GNSS subscriptions should be controlled by the GNSS Manager. *(GNSS abonelikleri GNSS Yöneticisi tarafından kontrol edilmelidir.)*

ARCore session ownership should belong to the ARCore Tracking Manager. *(ARCore oturum sahipliği ARCore Takip Yöneticisine ait olmalıdır.)*

This prevents multiple modules from independently opening or closing the same hardware resource. *(Bu yaklaşım birden fazla modülün aynı donanım kaynağını bağımsız olarak açmasını veya kapatmasını önler.)*

---

# 87. Lifecycle Architecture (Yaşam Döngüsü Mimarisi)

Hardware resources will be activated according to application and experiment lifecycle. *(Donanım kaynakları uygulama ve deney yaşam döngüsüne göre etkinleştirilecektir.)*

Diagnostic screens may observe sensors outside a formal experiment where appropriate. *(Tanı ekranları uygun olduğunda resmî bir deney dışında sensörleri gözlemleyebilir.)*

Formal high-frequency logging should begin only when an experiment or dedicated audit requires it. *(Resmî yüksek frekanslı kayıt yalnızca bir deney veya özel denetim gerektirdiğinde başlamalıdır.)*

All listeners and camera resources must be released correctly when no longer required. *(Tüm listener’lar ve kamera kaynakları artık gerekli olmadığında doğru şekilde serbest bırakılmalıdır.)*

---

# 88. Configuration Freeze During Session (Oturum Sırasında Yapılandırma Sabitleme)

Critical algorithm parameters should not change silently during a formal benchmark session. *(Kritik algoritma parametreleri resmî bir benchmark oturumu sırasında sessizce değişmemelidir.)*

If adaptive behavior is part of the algorithm, the adaptation logic must itself be defined in the recorded configuration. *(Uyarlanabilir davranış algoritmanın bir parçasıysa uyarlama mantığının kendisi kaydedilen yapılandırmada tanımlanmalıdır.)*

Manual parameter edits should require a new session or explicit experimental event. *(Manuel parametre değişiklikleri yeni bir oturum veya açık bir deney olayı gerektirmelidir.)*

---

# 89. Versioning Architecture (Sürümleme Mimarisi)

The application, navigation configuration, AI model, and relevant dataset versions will be independently identifiable. *(Uygulama, navigasyon yapılandırması, yapay zekâ modeli ve ilgili veri seti sürümleri bağımsız olarak tanımlanabilir olacaktır.)*

A navigation result must therefore not be represented only by an application version number. *(Bu nedenle bir navigasyon sonucu yalnızca bir uygulama sürüm numarasıyla temsil edilmemelidir.)*

The experiment record should preserve all relevant version identifiers. *(Deney kaydı ilgili tüm sürüm tanımlayıcılarını korumalıdır.)*

---

# 90. Architecture Decision Records (Mimari Karar Kayıtları)

Major architectural deviations from this document must be recorded in **43 — Technical Decisions & Change Log**. *(Bu dokümandan önemli mimari sapmalar **43 — Technical Decisions & Change Log** içerisinde kaydedilmelidir.)*

Examples include replacing Flutter, replacing the fusion approach, removing ARCore, changing the AI inference framework, or changing the timestamp strategy. *(Örnekler Flutter’ın değiştirilmesi, füzyon yaklaşımının değiştirilmesi, ARCore’un kaldırılması, yapay zekâ çıkarım framework’ünün değiştirilmesi veya zaman damgası stratejisinin değiştirilmesini içerir.)*

Small internal refactoring that does not alter system behavior does not require an architectural decision record. *(Sistem davranışını değiştirmeyen küçük dahili refactoring işlemleri mimari karar kaydı gerektirmez.)*

---

# 91. Minimum Architecture (Minimum Mimari)

The minimum accepted NAVGUARD architecture will contain the following functional path. *(Minimum kabul edilen NAVGUARD mimarisi aşağıdaki fonksiyonel hattı içerecektir.)*

```
Android Sensors
(Android Sensörleri)
       │
       ▼
Acquisition + Logging
(Veri Toplama + Kayıt)
       │
       ▼
Preprocessing
(Ön İşleme)
       │
       ├────────────► Motion AI
       │              (Hareket AI)
       ▼
Step + Heading
(Adım + Yön)
       │
       ▼
Baseline PDR
(Temel PDR)
       │
       ▼
Estimated Position
(Tahmini Konum)
       │
       ▼
Map / Logging / Evaluation
(Harita / Kayıt / Değerlendirme)

Independent GNSS Ground Truth
(Bağımsız GNSS Gerçek Referansı)
       │
       └────────────► Evaluation Only
                      (Yalnızca Değerlendirme)
```

This architecture is sufficient to preserve the primary research value even if advanced components cannot be completed. *(Bu mimari gelişmiş bileşenler tamamlanamazsa bile temel araştırma değerini korumak için yeterlidir.)*

---

# 92. Target Architecture (Hedef Mimari)

The intended target NAVGUARD architecture will extend the minimum architecture with ARCore, sensor confidence, learned motion context, advanced step-length estimation where beneficial, and multi-source fusion. *(Planlanan hedef NAVGUARD mimarisi minimum mimariyi ARCore, sensör güveni, öğrenilmiş hareket bağlamı, faydalı olduğu durumda gelişmiş adım uzunluğu tahmini ve çok kaynaklı füzyon ile genişletecektir.)*

```
                       GNSS Initial Anchor
                     (GNSS Başlangıç Çapası)
                              │
                              ▼
                    Local Navigation Frame
                 (Yerel Navigasyon Koordinatı)
                              │

Accelerometer ─┐
Gyroscope ─────┼────► Preprocessing ─────► Step Detection
Magnetometer ──┘          │                    │
                          │                    ▼
                          │              Step Length
                          │                    │
                          ├────► Motion AI ────┤
                          │                    │
                          └────► Heading ──────┤
                                               ▼
                                              PDR
                                               │
                                               │
ARCore ─────────► Tracking + Alignment ─────────┤
                                               │
Sensor Quality ─────────────────────────────────┤
                                               ▼
                                      Fusion Engine / EKF
                                               │
                                               ▼
                                   Position + Uncertainty
                                               │
                         ┌─────────────────────┼────────────────┐
                         ▼                     ▼                ▼
                        UI                  Logger          Evaluation
                    (Arayüz)               (Kayıt)       (Değerlendirme)

Independent GNSS Ground Truth ────────────────────────────────► Evaluation
(Bağımsız GNSS Gerçek Referansı)
```

---

# 93. Architecture Success Conditions (Mimari Başarı Koşulları)

The architecture will be considered successful if it supports both live navigation and deterministic experimental analysis. *(Mimari hem canlı navigasyonu hem de deterministik deneysel analizi desteklerse başarılı kabul edilecektir.)*

The architecture must preserve ground-truth isolation. *(Mimari gerçek referans izolasyonunu korumalıdır.)*

The architecture must preserve the minimum PDR fallback. *(Mimari minimum PDR geri dönüşünü korumalıdır.)*

The architecture must support on-device motion inference. *(Mimari cihaz üzeri hareket çıkarımını desteklemelidir.)*

The architecture must support recorded-session replay. *(Mimari kaydedilmiş oturum yeniden oynatmayı desteklemelidir.)*

The architecture must allow advanced components to be removed without requiring complete application redesign. *(Mimari gelişmiş bileşenlerin tam uygulama yeniden tasarımı gerektirmeden çıkarılmasına izin vermelidir.)*

---

# 94. Architecture Validation Gates (Mimari Doğrulama Kapıları)

The minimum architecture cannot be frozen until GATE-MIN from the Device Capability Audit has passed. *(Minimum mimari Cihaz Yetenek Denetimindeki GATE-MIN geçmeden sabitlenemez.)*

The target architecture cannot be frozen until GATE-TGT has passed or documented fallback decisions have replaced failed target components. *(Hedef mimari GATE-TGT geçmeden veya başarısız hedef bileşenlerin yerine dokümante edilmiş geri dönüş kararları konulmadan sabitlenemez.)*

The AI runtime path must be verified on the physical Redmi Note 9 Pro before the final model architecture is frozen. *(Nihai model mimarisi sabitlenmeden önce yapay zekâ çalışma zamanı hattı fiziksel Redmi Note 9 Pro üzerinde doğrulanmalıdır.)*

ARCore must pass physical tracking tests before being treated as a reliable fusion source. *(ARCore güvenilir bir füzyon kaynağı olarak ele alınmadan önce fiziksel takip testlerini geçmelidir.)*

---

# 95. Architectural Risks (Mimari Riskler)

The primary architectural risk is excessive complexity within the limited 24-business-day development period. *(Temel mimari risk sınırlı 24 iş günlük geliştirme süresi içerisinde aşırı karmaşıklıktır.)*

A second risk is coupling advanced components so tightly that failure of one subsystem disables the entire application. *(İkinci risk gelişmiş bileşenlerin bir alt sistemin başarısızlığının tüm uygulamayı devre dışı bırakacağı kadar sıkı bağlanmasıdır.)*

A third risk is timestamp inconsistency between sensor, GNSS, and ARCore data. *(Üçüncü risk sensör, GNSS ve ARCore verileri arasındaki zaman damgası tutarsızlığıdır.)*

A fourth risk is performance degradation when logging, ARCore, AI, and visualization operate simultaneously. *(Dördüncü risk kayıt, ARCore, yapay zekâ ve görselleştirme aynı anda çalıştığında performans bozulmasıdır.)*

The modular and fallback-oriented architecture is designed specifically to reduce these risks. *(Modüler ve geri dönüş odaklı mimari özellikle bu riskleri azaltmak için tasarlanmıştır.)*

---

# 96. Architectural Non-Goals (Mimari Olmayan Hedefler)

The architecture will not attempt to implement a complete custom visual-inertial odometry system from raw camera frames. *(Mimari ham kamera karelerinden tamamen özel bir görsel-ataletsel odometri sistemi geliştirmeye çalışmayacaktır.)*

The architecture will not require a remote microservice architecture. *(Mimari uzak bir mikroservis mimarisi gerektirmeyecektir.)*

The architecture will not require distributed computing. *(Mimari dağıtık hesaplama gerektirmeyecektir.)*

The architecture will not require external navigation hardware. *(Mimari harici navigasyon donanımı gerektirmeyecektir.)*

The architecture will not optimize prematurely for multiple mobile operating systems. *(Mimari birden fazla mobil işletim sistemi için erken optimizasyon yapmayacaktır.)*

---

# 97. Architecture Freeze Policy (Mimari Sabitleme Politikası)

This document defines the pre-development architectural baseline. *(Bu doküman geliştirme öncesi mimari temel referansı tanımlar.)*

The architecture may be refined after the Device Capability Audit and early prototypes produce real measurements. *(Cihaz Yetenek Denetimi ve ilk prototipler gerçek ölçümler ürettikten sonra mimari iyileştirilebilir.)*

Major changes must be documented before they become the accepted project architecture. *(Büyük değişiklikler kabul edilen proje mimarisi haline gelmeden önce dokümante edilmelidir.)*

The final architecture will be frozen before the final benchmark phase begins. *(Nihai mimari son benchmark aşaması başlamadan önce sabitlenecektir.)*

---

# 98. Architecture Summary (Mimari Özeti)

**NAVGUARD will use a layered Android architecture in which physical sensor measurements are acquired, timestamped, preprocessed, interpreted as pedestrian movement, fused into a unified navigation state, recorded for reproducibility, and presented through a Flutter-based mobile interface.** *(NAVGUARD; fiziksel sensör ölçümlerinin elde edildiği, zaman damgalandığı, ön işlendiği, yaya hareketi olarak yorumlandığı, birleşik bir navigasyon durumunda füzyonlandığı, tekrarlanabilirlik için kaydedildiği ve Flutter tabanlı mobil arayüz üzerinden sunulduğu katmanlı bir Android mimarisi kullanacaktır.)*

**GNSS ground-truth data will remain architecturally isolated from the GNSS-denied estimator while still being recorded for experimental evaluation.** *(GNSS gerçek referans verisi deneysel değerlendirme için kaydedilmeye devam ederken mimari olarak GNSS kesintili tahmin motorundan izole kalacaktır.)*

**PDR will form the minimum navigation fallback, while ARCore, AI-assisted motion understanding, sensor confidence, and EKF-based multi-source fusion will extend the system toward the target NAVGUARD configuration.** *(PDR minimum navigasyon geri dönüşünü oluştururken ARCore, yapay zekâ destekli hareket anlayışı, sensör güveni ve EKF tabanlı çok kaynaklı füzyon sistemi hedef NAVGUARD yapılandırmasına doğru genişletecektir.)*

**Live acquisition and recorded-session replay will use compatible internal processing interfaces so that the same algorithms can be evaluated on identical sensor evidence.** *(Canlı veri toplama ve kaydedilmiş oturum yeniden oynatma uyumlu dahili işleme arayüzlerini kullanacaktır; böylece aynı algoritmalar aynı sensör kanıtı üzerinde değerlendirilebilecektir.)*

---

# 99. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development Architecture Baseline Completed *(Doküman Durumu: Geliştirme Öncesi Mimari Temel Referans Tamamlandı)*

**Minimum Architecture Status:** Defined — Pending Device Audit Validation *(Minimum Mimari Durumu: Tanımlandı — Cihaz Denetimi Doğrulaması Bekleniyor)*

**Target Architecture Status:** Defined — Pending Device Audit and Prototype Validation *(Hedef Mimari Durumu: Tanımlandı — Cihaz Denetimi ve Prototip Doğrulaması Bekleniyor)*

**Primary Mobile Layer:** Flutter *(Birincil Mobil Katman: Flutter)*

**Native Android Layer:** Kotlin Where Required *(Native Android Katmanı: Gerektiğinde Kotlin)*

**Minimum Navigation Fallback:** PDR *(Minimum Navigasyon Geri Dönüşü: PDR)*

**Primary Fusion Candidate:** Extended Kalman Filter *(Birincil Füzyon Adayı: Genişletilmiş Kalman Filtresi)*

**Primary AI Role:** Motion Classification and Navigation Context *(Birincil Yapay Zekâ Rolü: Hareket Sınıflandırması ve Navigasyon Bağlamı)*

**Primary Visual-Inertial Source:** ARCore *(Birincil Görsel-Ataletsel Kaynak: ARCore)*

**Ground Truth Isolation:** Mandatory Architectural Boundary *(Gerçek Referans İzolasyonu: Zorunlu Mimari Sınır)*

**Next Documentation Item:** 09 — Technology Stack *(Sonraki Dokümantasyon Öğesi: 09 — Teknoloji Yığını)*