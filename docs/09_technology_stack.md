# 09 — Technology Stack (Teknoloji Yığını)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the official software technologies, frameworks, programming languages, libraries, development tools, storage technologies, machine learning tools, testing tools, and version-management strategy selected for the NAVGUARD project. (Bu doküman, NAVGUARD projesi için seçilen resmî yazılım teknolojilerini, framework’leri, programlama dillerini, kütüphaneleri, geliştirme araçlarını, depolama teknolojilerini, makine öğrenmesi araçlarını, test araçlarını ve sürüm yönetimi stratejisini tanımlar.)

The technology stack is selected specifically for an Android-only navigation research application running primarily on the Xiaomi Redmi Note 9 Pro. (Teknoloji yığını özellikle temel olarak Xiaomi Redmi Note 9 Pro üzerinde çalışan yalnızca Android’e yönelik bir navigasyon araştırma uygulaması için seçilmiştir.)

The selected technologies must support offline navigation, high-frequency sensor acquisition, on-device artificial intelligence, ARCore tracking, reproducible data logging, and experimental evaluation. (Seçilen teknolojiler çevrimdışı navigasyonu, yüksek frekanslı sensör veri toplamayı, cihaz üzeri yapay zekâyı, ARCore takibini, tekrarlanabilir veri kaydını ve deneysel değerlendirmeyi desteklemelidir.)

---

# 2. Technology Selection Principles (Teknoloji Seçim İlkeleri)

NAVGUARD will prefer mature and actively maintained technologies over experimental dependencies when both can satisfy the same requirement. (NAVGUARD, her ikisi de aynı gereksinimi karşılayabiliyorsa deneysel bağımlılıklar yerine olgun ve aktif olarak sürdürülen teknolojileri tercih edecektir.)

Critical sensor and navigation capabilities will prefer official Android APIs where direct platform access provides better control over timing and hardware behavior. (Kritik sensör ve navigasyon yetenekleri, doğrudan platform erişiminin zamanlama ve donanım davranışı üzerinde daha iyi kontrol sağladığı durumlarda resmî Android API’lerini tercih edecektir.)

Third-party packages will be used primarily when they reduce development complexity without hiding hardware behavior required by the research. (Üçüncü taraf paketler temel olarak araştırma için gerekli donanım davranışını gizlemeden geliştirme karmaşıklığını azalttıkları durumlarda kullanılacaktır.)

The final dependency set will be intentionally limited to reduce integration risk within the 24-business-day development schedule. (Nihai bağımlılık seti, 24 iş günlük geliştirme takvimi içerisinde entegrasyon riskini azaltmak için bilinçli olarak sınırlı tutulacaktır.)

---

# 3. Official Technology Stack Summary (Resmî Teknoloji Yığını Özeti)

| Area (Alan) | Selected Technology (Seçilen Teknoloji) |
| --- | --- |
| Mobile Framework (Mobil Framework) Fl | utter |
| Primary Application Language (Birincil Uygulama Dili) Da | rt |
| Native Android Language (Native Android Dili) Ko | tlin |
| Target Platform (Hedef Platform) An | droid Only (Yalnızca Android) |
| Sensor Access (Sensör Erişimi) An | droid SensorManager SensorEventListener |
| GNSS Access (GNSS Erişimi) An | droid LocationManager GPS_PROVIDER |
| GNSS Diagnostics (GNSS Tanısı) Gn | ssStatus Optional Raw GNSS APIs (GnssStatus İsteğe Bağlı Ham GNSS API’leri) |
| Visual-Inertial Tracking (Görsel-Ataletsel Takip) Go | ogle ARCore SDK for Android |
| On-Device AI Runtime (Cihaz Üzeri AI Çalışma Zamanı) Go | ogle LiteRT |
| Mobile AI Model Format (Mobil AI Model Formatı) `. | tflite` |
| ML Development (ML Geliştirme) Py | thon |
| Neural Network Development (Sinir Ağı Geliştirme) Te | nsorFlow Keras-compatible training workflow (TensorFlow Keras uyumlu eğitim iş akışı) |
| Classical ML (Klasik ML) sc | ikit-learn |
| Numerical Computing (Sayısal Hesaplama) Nu | mPy SciPy |
| Data Processing (Veri İşleme) pa | ndas |
| Scientific Visualization (Bilimsel Görselleştirme) Ma | tplotlib |
| Map UI (Harita Arayüzü) fl | utter_map |
| Map Data (Harita Verisi) Op | enStreetMap-compatible map source (OpenStreetMap uyumlu harita kaynağı) |
| Session Metadata (Oturum Metadata Bilgisi) SQ | Lite |
| High-Frequency Experimental Data (Yüksek Frekanslı Deney Verisi) Fi | le-Based CSV Structured Export (Dosya Tabanlı CSV Yapılandırılmış Dışa Aktarma) |
| Configuration Manifest (Yapılandırma Manifest) JSON |  |
| Version Control (Sürüm Kontrolü) Gi | t |
| Remote Repository (Uzak Repository) Gi | tHub |
| Documentation (Dokümantasyon) No | tion + Repository Markdown |
| Flutter Testing (Flutter Testleri) fl | utter_test integration_test |
| Native Android Testing (Native Android Testleri) JU | nit Android Instrumentation |
| Python Testing (Python Testleri) py | test |
| Android Profiling (Android Profilleme) An | droid Studio Profiler ADB |
| Dependency Management (Bağımlılık Yönetimi) Pu | b Gradle-Maven Python venv + pinned requirements |

---

# 4. Mobile Framework — Flutter (Mobil Framework — Flutter)

Flutter will be the primary mobile application framework of NAVGUARD. (Flutter, NAVGUARD’ın birincil mobil uygulama framework’ü olacaktır.)

Flutter will manage application screens, navigation controls, experiment interfaces, status panels, maps, session history, result visualization, and research dashboards. (Flutter; uygulama ekranlarını, navigasyon kontrollerini, deney arayüzlerini, durum panellerini, haritaları, oturum geçmişini, sonuç görselleştirmesini ve araştırma dashboard’larını yönetecektir.)

Flutter will not be required to directly implement every hardware-sensitive operation. (Flutter’ın donanıma duyarlı her işlemi doğrudan gerçekleştirmesi gerekmeyecektir.)

Native Android functionality will be used when lower-level platform control is more appropriate. (Daha düşük seviyeli platform kontrolünün daha uygun olduğu durumlarda native Android işlevleri kullanılacaktır.)

---

# 5. Flutter Version Policy (Flutter Sürüm Politikası)

NAVGUARD will use a stable Flutter release rather than beta, development, or master channels. (NAVGUARD beta, development veya master kanalları yerine kararlı bir Flutter sürümü kullanacaktır.)

The exact Flutter and Dart versions will be frozen when implementation begins. (Kesin Flutter ve Dart sürümleri geliştirme başladığında sabitlenecektir.)

The selected versions will be recorded in the repository and experiment environment documentation. (Seçilen sürümler repository içerisinde ve deney ortamı dokümantasyonunda kaydedilecektir.)

Flutter upgrades will not be performed during the final benchmark period unless a critical technical problem requires the upgrade. (Kritik bir teknik problem yükseltmeyi gerektirmediği sürece nihai benchmark döneminde Flutter yükseltmesi yapılmayacaktır.)

---

# 6. Primary Application Language — Dart (Birincil Uygulama Dili — Dart)

Dart will be used for the Flutter application layer and platform-independent navigation logic where appropriate. (Dart, Flutter uygulama katmanı ve uygun olduğunda platformdan bağımsız navigasyon mantığı için kullanılacaktır.)

Pure mathematical algorithms should preferably remain independent from Android-specific APIs so that they can be unit tested and replayed easily. (Saf matematiksel algoritmalar kolayca birim test edilebilmeleri ve yeniden oynatılabilmeleri için tercihen Android’e özgü API’lerden bağımsız kalmalıdır.)

Coordinate transformations, PDR calculations, experiment configuration, evaluation utilities, and application-level state management are suitable candidates for Dart implementation. (Koordinat dönüşümleri, PDR hesaplamaları, deney yapılandırması, değerlendirme yardımcıları ve uygulama seviyesindeki durum yönetimi Dart uygulaması için uygun adaylardır.)

---

# 7. Native Android Language — Kotlin (Native Android Dili — Kotlin)

Kotlin will be the official native Android language of NAVGUARD. (Kotlin, NAVGUARD’ın resmî native Android dili olacaktır.)

Kotlin will be used where direct Android API access provides better control than a generic Flutter plugin. (Kotlin, doğrudan Android API erişiminin genel bir Flutter eklentisinden daha iyi kontrol sağladığı yerlerde kullanılacaktır.)

Critical native responsibilities may include sensor acquisition, sensor metadata inspection, GNSS access, ARCore integration, LiteRT inference, and platform-specific diagnostics. (Kritik native sorumluluklar sensör veri toplama, sensör metadata inceleme, GNSS erişimi, ARCore entegrasyonu, LiteRT çıkarımı ve platforma özgü tanısal işlevleri içerebilir.)

Flutter officially supports communication with Android-specific Kotlin code through platform channels. (Flutter, platform channel’ları aracılığıyla Android’e özgü Kotlin koduyla iletişimi resmî olarak desteklemektedir.)

---

# 8. Flutter and Kotlin Responsibility Boundary (Flutter ve Kotlin Sorumluluk Sınırı)

Flutter will own presentation and application orchestration responsibilities. (Flutter sunum ve uygulama orkestrasyon sorumluluklarına sahip olacaktır.)

Kotlin will own hardware-sensitive Android integrations when required. (Kotlin gerekli olduğunda donanıma duyarlı Android entegrasyonlarına sahip olacaktır.)

High-frequency raw data should not be routed through Flutter merely for display purposes. (Yüksek frekanslı ham veri yalnızca görüntüleme amacıyla Flutter üzerinden yönlendirilmemelidir.)

Only the information required by application logic or visualization should cross the Flutter-native boundary at high frequency. (Yalnızca uygulama mantığı veya görselleştirme tarafından gerekli bilgi yüksek frekansta Flutter-native sınırını geçmelidir.)

---

# 9. Platform Communication Technology (Platform İletişim Teknolojisi)

Flutter platform channels will provide the primary communication mechanism between Dart and Kotlin. (Flutter platform channel’ları Dart ile Kotlin arasındaki temel iletişim mekanizmasını sağlayacaktır.)

Method-oriented communication will be used for commands such as starting or stopping native services, requesting metadata, and changing configurations. (Metot odaklı iletişim native hizmetleri başlatma veya durdurma, metadata isteme ve yapılandırmaları değiştirme gibi komutlar için kullanılacaktır.)

Streaming communication will be used for continuously changing sensor, GNSS, ARCore, or diagnostic state when those values must enter Flutter. (Streaming iletişim, bu değerlerin Flutter’a girmesi gerektiğinde sürekli değişen sensör, GNSS, ARCore veya tanısal durum için kullanılacaktır.)

The native layer may batch high-frequency measurements before transfer if individual platform messages create unnecessary overhead. (Bireysel platform mesajları gereksiz yük oluşturursa native katman yüksek frekanslı ölçümleri aktarmadan önce batch’leyebilir.)

---

# 10. Android Sensor Framework (Android Sensör Framework’ü)

The official Android Sensor Framework will be used for primary inertial sensor acquisition. (Temel ataletsel sensör veri toplama için resmî Android Sensor Framework kullanılacaktır.)

Android SensorManager will enumerate and access sensors available on the physical device. (Android SensorManager fiziksel cihaz üzerinde mevcut sensörleri listeleyecek ve bunlara erişecektir.)

SensorEventListener will receive timestamped sensor measurements during normal NAVGUARD acquisition. (SensorEventListener normal NAVGUARD veri toplama sırasında zaman damgalı sensör ölçümlerini alacaktır.)

Android’s sensor APIs expose sensor type, timestamp, accuracy, and measurement information required by the NAVGUARD audit and acquisition architecture. (Android’in sensör API’leri NAVGUARD denetim ve veri toplama mimarisi tarafından gerekli sensör türü, zaman damgası, doğruluk ve ölçüm bilgisini sunmaktadır.)

---

# 11. Why a Generic Flutter Sensor Plugin Is Not the Primary Sensor Layer (Neden Genel Bir Flutter Sensör Eklentisi Birincil Sensör Katmanı Değildir)

NAVGUARD will not depend on a generic Flutter sensor package as the authoritative source of critical research measurements. (NAVGUARD kritik araştırma ölçümlerinin ana kaynağı olarak genel bir Flutter sensör paketine bağımlı olmayacaktır.)

Direct Android SensorManager access provides greater visibility into sensor metadata, timestamps, sampling behavior, and hardware-specific properties. (Doğrudan Android SensorManager erişimi sensör metadata bilgisi, zaman damgaları, örnekleme davranışı ve donanıma özgü özellikler üzerinde daha fazla görünürlük sağlar.)

This is important because the project explicitly studies the behavior of the physical Redmi Note 9 Pro sensors. (Bu önemlidir çünkü proje fiziksel Redmi Note 9 Pro sensörlerinin davranışını açıkça incelemektedir.)

A Flutter plugin may still be used for non-critical convenience functionality if it does not interfere with the authoritative native acquisition stream. (Ana native veri toplama akışına müdahale etmediği sürece kritik olmayan kolaylık işlevleri için bir Flutter eklentisi yine kullanılabilir.)

---

# 12. Sensor Sampling Technology (Sensör Örnekleme Teknolojisi)

Sensor callbacks will use Android-provided event timestamps as the primary timing reference. (Sensör callback’leri temel zamanlama referansı olarak Android tarafından sağlanan olay zaman damgalarını kullanacaktır.)

The requested sampling period will be considered a target rather than an assumption about actual delivery frequency. (Talep edilen örnekleme periyodu gerçek teslim frekansı hakkında bir varsayım yerine hedef olarak kabul edilecektir.)

NAVGUARD will calculate the effective sampling rate from received timestamps. (NAVGUARD etkin örnekleme hızını alınan zaman damgalarından hesaplayacaktır.)

The selected initial IMU rate will be approximately 50 Hz until the Device Capability Audit freezes the actual configuration. (Cihaz Yetenek Denetimi gerçek yapılandırmayı sabitleyene kadar seçilen başlangıç IMU hızı yaklaşık 50 Hz olacaktır.)

Android requires a special permission for SensorEventListener sampling rates above 200 Hz, but NAVGUARD does not require rates above that level. (Android, SensorEventListener için 200 Hz’in üzerindeki örnekleme hızlarında özel bir izin gerektirir ancak NAVGUARD bu seviyenin üzerinde hızlara ihtiyaç duymaz.)

---

# 13. GNSS Technology (GNSS Teknolojisi)

Android LocationManager will be the primary native GNSS access technology. (Android LocationManager temel native GNSS erişim teknolojisi olacaktır.)

The GPS_PROVIDER will be preferred for formal GNSS reference acquisition because Android defines it as the standard GNSS satellite positioning provider. (Android bunu standart GNSS uydu konumlandırma sağlayıcısı olarak tanımladığı için resmî GNSS referans veri toplamada GPS_PROVIDER tercih edilecektir.)

A fused network-assisted location provider will not be used as the authoritative GNSS ground-truth source during formal evaluation. (Füzyonlu ağ destekli konum sağlayıcısı resmî değerlendirme sırasında ana GNSS gerçek referans kaynağı olarak kullanılmayacaktır.)

This decision maintains a clearer separation between satellite-based reference measurements and other Android location sources. (Bu karar uydu tabanlı referans ölçümleri ile diğer Android konum kaynakları arasında daha açık bir ayrım sağlar.)

---

# 14. GNSS Diagnostic Technology (GNSS Tanı Teknolojisi)

GnssStatus will be used where useful to observe the current state of the GNSS engine and available satellite information. (GnssStatus, GNSS motorunun mevcut durumunu ve kullanılabilir uydu bilgisini gözlemlemek için yararlı olduğu durumlarda kullanılacaktır.)

Android GnssStatus can expose constellation information such as GPS, GLONASS, Galileo, and BeiDou when supported by the device. (Android GnssStatus, cihaz tarafından desteklendiğinde GPS, GLONASS, Galileo ve BeiDou gibi takımyıldız bilgilerini sunabilir.)

Raw GNSS measurements may be investigated through Android’s raw GNSS APIs only as an optional research feature. (Ham GNSS ölçümleri yalnızca isteğe bağlı bir araştırma özelliği olarak Android’in ham GNSS API’leri üzerinden araştırılabilir.)

The core NAVGUARD estimator will not depend on raw GNSS measurement support. (Temel NAVGUARD tahmin motoru ham GNSS ölçüm desteğine bağımlı olmayacaktır.)

---

# 15. Location Permission Technology (Konum İzni Teknolojisi)

Android ACCESS_FINE_LOCATION will be required for precise GNSS access used by the project. (Android ACCESS_FINE_LOCATION, proje tarafından kullanılan hassas GNSS erişimi için gerekli olacaktır.)

The application will manage runtime location permission through Android-compatible Flutter and native permission flows. (Uygulama çalışma zamanı konum iznini Android uyumlu Flutter ve native izin akışları üzerinden yönetecektir.)

The project will not require continuous background location access for the primary experimental workflow. (Proje temel deneysel iş akışı için sürekli arka plan konum erişimine ihtiyaç duymayacaktır.)

Formal navigation sessions will primarily run while NAVGUARD remains active in the foreground. (Resmî navigasyon oturumları temel olarak NAVGUARD ön planda aktif kalırken çalışacaktır.)

---

# 16. Visual-Inertial Technology — ARCore (Görsel-Ataletsel Teknoloji — ARCore)

Google ARCore SDK for Android will be the selected visual-inertial tracking platform. (Google ARCore SDK for Android seçilen görsel-ataletsel takip platformu olacaktır.)

ARCore will be integrated through the native Android layer rather than treated primarily as a Flutter visualization plugin. (ARCore temel olarak bir Flutter görselleştirme eklentisi olarak ele alınmak yerine native Android katmanı üzerinden entegre edilecektir.)

The integration will focus on device pose, relative translation, orientation, timestamp information, and tracking state. (Entegrasyon cihaz pozu, göreli öteleme, yönelim, zaman damgası bilgisi ve takip durumuna odaklanacaktır.)

ARCore certification evaluates supported devices for camera, motion sensor, architecture, and processing characteristics required for real-time motion tracking. (ARCore sertifikasyonu desteklenen cihazları gerçek zamanlı hareket takibi için gerekli kamera, hareket sensörü, mimari ve işlem özellikleri açısından değerlendirir.)

---

# 17. ARCore Application Mode (ARCore Uygulama Modu)

NAVGUARD will treat ARCore as an optional advanced capability rather than a mandatory dependency of the minimum application architecture. (NAVGUARD, ARCore’u minimum uygulama mimarisinin zorunlu bağımlılığı yerine isteğe bağlı gelişmiş bir yetenek olarak ele alacaktır.)

The application architecture must therefore remain usable when ARCore is unavailable or temporarily loses tracking. (Bu nedenle uygulama mimarisi ARCore kullanılamaz olduğunda veya geçici olarak takibi kaybettiğinde kullanılabilir kalmalıdır.)

The Android project will use a minimum SDK compatible with the selected ARCore integration and the physical Redmi Note 9 Pro. (Android projesi seçilen ARCore entegrasyonu ve fiziksel Redmi Note 9 Pro ile uyumlu bir minimum SDK kullanacaktır.)

The provisional minimum Android API level will be API 24 or higher, subject to final validation during project bootstrap. (Geçici minimum Android API seviyesi, proje başlangıcında nihai doğrulamaya tabi olmak üzere API 24 veya üzeri olacaktır.)

Google currently requires at least API 24 for Android applications that declare ARCore as required, while AR-optional applications can support lower API levels. (Google günümüzde ARCore’u zorunlu olarak tanımlayan Android uygulamaları için en az API 24 gerektirirken AR-optional uygulamalar daha düşük API seviyelerini destekleyebilir.)

---

# 18. ARCore Depth Policy (ARCore Depth Politikası)

The ARCore Depth API will not be part of the mandatory NAVGUARD technology stack. (ARCore Depth API zorunlu NAVGUARD teknoloji yığınının bir parçası olmayacaktır.)

NAVGUARD requires relative pose tracking rather than environmental depth reconstruction. (NAVGUARD çevresel derinlik yeniden yapılandırması yerine göreli poz takibine ihtiyaç duyar.)

This decision avoids adding an unnecessary hardware-specific dependency. (Bu karar gereksiz bir donanıma özgü bağımlılık eklenmesini önler.)

---

# 19. On-Device AI Runtime — LiteRT (Cihaz Üzeri AI Çalışma Zamanı — LiteRT)

Google LiteRT will be the preferred Android runtime for NAVGUARD artificial intelligence inference. (Google LiteRT, NAVGUARD yapay zekâ çıkarımı için tercih edilen Android çalışma zamanı olacaktır.)

LiteRT is the current Google AI Edge evolution and naming of the technology previously known as TensorFlow Lite. (LiteRT, daha önce TensorFlow Lite olarak bilinen teknolojinin güncel Google AI Edge devamı ve adlandırmasıdır.)

NAVGUARD documentation may continue to use the `.tflite` model-file extension because the deployed model format remains compatible with this workflow. (NAVGUARD dokümantasyonu, dağıtılan model formatı bu iş akışıyla uyumlu kalmaya devam ettiği için `.tflite` model dosyası uzantısını kullanmaya devam edebilir.)

---

# 20. LiteRT Integration Strategy (LiteRT Entegrasyon Stratejisi)

LiteRT inference will preferably execute in the native Android Kotlin layer. (LiteRT çıkarımı tercihen native Android Kotlin katmanında çalışacaktır.)

This decision reduces dependence on a Flutter AI plugin and provides direct control over the Android inference runtime. (Bu karar bir Flutter yapay zekâ eklentisine bağımlılığı azaltır ve Android çıkarım çalışma zamanı üzerinde doğrudan kontrol sağlar.)

The model runtime will expose only the required motion-class probabilities, selected class, inference timestamp, and latency information to the rest of NAVGUARD. (Model çalışma zamanı NAVGUARD’ın geri kalanına yalnızca gerekli hareket sınıfı olasılıklarını, seçilen sınıfı, çıkarım zaman damgasını ve gecikme bilgisini sunacaktır.)

The Flutter user interface will not directly own the LiteRT interpreter. (Flutter kullanıcı arayüzü LiteRT interpreter’ına doğrudan sahip olmayacaktır.)

---

# 21. Bundled AI Runtime Policy (Paketlenmiş AI Çalışma Zamanı Politikası)

NAVGUARD should prefer an application-bundled LiteRT runtime when this provides better experimental reproducibility on the test device. (NAVGUARD, test cihazında daha iyi deneysel tekrarlanabilirlik sağladığında uygulama içerisine paketlenmiş bir LiteRT çalışma zamanını tercih etmelidir.)

This allows the runtime version used by a benchmark to be tied directly to the application build. (Bu, bir benchmark tarafından kullanılan çalışma zamanı sürümünün doğrudan uygulama build’i ile ilişkilendirilmesini sağlar.)

The exact LiteRT dependency version will be pinned when the AI deployment module is implemented. (Kesin LiteRT bağımlılık sürümü yapay zekâ dağıtım modülü geliştirildiğinde sabitlenecektir.)

---

# 22. AI Hardware Acceleration Policy (Yapay Zekâ Donanım Hızlandırma Politikası)

CPU execution will be treated as the initial compatibility baseline. (CPU üzerinde çalışma başlangıç uyumluluk temel referansı olarak ele alınacaktır.)

GPU or other hardware delegates may be evaluated only after CPU inference has been verified. (GPU veya diğer donanım delegate’leri yalnızca CPU çıkarımı doğrulandıktan sonra değerlendirilebilir.)

LiteRT supports hardware acceleration mechanisms for Android devices, but acceleration will not be enabled merely because it is available. (LiteRT Android cihazlar için donanım hızlandırma mekanizmalarını destekler ancak hızlandırma yalnızca mevcut olduğu için etkinleştirilmeyecektir.)

The selected execution backend must demonstrate measurable latency or energy benefit without reducing stability. (Seçilen çalışma backend’i kararlılığı azaltmadan ölçülebilir gecikme veya enerji faydası göstermelidir.)

---

# 23. AI Model Format (Yapay Zekâ Model Formatı)

The deployable motion-classification model will use the `.tflite` model format compatible with the selected LiteRT runtime. (Dağıtılabilir hareket sınıflandırma modeli seçilen LiteRT çalışma zamanıyla uyumlu `.tflite` model formatını kullanacaktır.)

The deployed model will be stored as a versioned application asset or another controlled local application resource. (Dağıtılan model sürümlenmiş bir uygulama asset’i veya başka bir kontrollü yerel uygulama kaynağı olarak saklanacaktır.)

Every benchmark session using artificial intelligence will record the model identifier. (Yapay zekâ kullanan her benchmark oturumu model tanımlayıcısını kaydedecektir.)

---

# 24. Neural Network Development Stack (Sinir Ağı Geliştirme Yığını)

Python will be used for neural-network development outside the mobile application. (Python, mobil uygulamanın dışında sinir ağı geliştirme için kullanılacaktır.)

A TensorFlow and Keras-compatible workflow will be used for the initial 1D-CNN experiments. (İlk 1D-CNN deneyleri için TensorFlow ve Keras uyumlu bir iş akışı kullanılacaktır.)

The final conversion path must produce a model supported by the selected LiteRT Android runtime. (Nihai dönüştürme hattı seçilen LiteRT Android çalışma zamanı tarafından desteklenen bir model üretmelidir.)

Model architecture will avoid unnecessary operators that complicate mobile conversion or increase runtime size without demonstrated benefit. (Model mimarisi mobil dönüştürmeyi karmaşıklaştıran veya kanıtlanmış fayda olmadan çalışma zamanı boyutunu artıran gereksiz operatörlerden kaçınacaktır.)

---

# 25. Classical Machine Learning Stack (Klasik Makine Öğrenmesi Yığını)

scikit-learn will provide the primary classical machine learning baseline environment. (scikit-learn temel klasik makine öğrenmesi referans ortamını sağlayacaktır.)

Random Forest will be evaluated as one of the primary motion-classification baseline models. (Random Forest temel hareket sınıflandırma referans modellerinden biri olarak değerlendirilecektir.)

Logistic Regression or another lightweight classifier may be included as a simple baseline. (Logistic Regression veya başka bir hafif sınıflandırıcı basit bir temel model olarak dahil edilebilir.)

XGBoost may be evaluated if additional model comparison provides useful experimental value. (Ek model karşılaştırması kullanışlı deneysel değer sağlarsa XGBoost değerlendirilebilir.)

---

# 26. Step Length Machine Learning Stack (Adım Uzunluğu Makine Öğrenmesi Yığını)

The first step-length implementation will use a deterministic or calibrated mathematical baseline. (İlk adım uzunluğu uygulaması deterministik veya kalibre edilmiş matematiksel bir temel yaklaşım kullanacaktır.)

Random Forest Regressor will be the initial machine learning candidate for dynamic step-length estimation. (Random Forest Regressor dinamik adım uzunluğu tahmini için ilk makine öğrenmesi adayı olacaktır.)

Linear Regression will provide a simpler regression baseline. (Linear Regression daha basit bir regresyon temel referansı sağlayacaktır.)

A small neural regression model may be evaluated only if simpler approaches fail to provide sufficient performance. (Küçük bir sinir ağı regresyon modeli yalnızca daha basit yaklaşımlar yeterli performans sağlamazsa değerlendirilebilir.)

---

# 27. Python Version Policy (Python Sürüm Politikası)

A stable Python version supported by the selected machine learning dependencies will be used. (Seçilen makine öğrenmesi bağımlılıkları tarafından desteklenen kararlı bir Python sürümü kullanılacaktır.)

Python 3.12 will be the preferred initial environment unless compatibility testing during environment setup identifies a reason to select another supported version. (Ortam kurulumu sırasında uyumluluk testi başka desteklenen bir sürüm seçmek için bir neden belirlemediği sürece Python 3.12 tercih edilen başlangıç ortamı olacaktır.)

The exact Python version will be recorded and frozen before final dataset processing begins. (Kesin Python sürümü nihai veri seti işleme başlamadan önce kaydedilecek ve sabitlenecektir.)

---

# 28. Numerical Computing Stack (Sayısal Hesaplama Yığını)

NumPy will be used for numerical array operations and signal-processing data structures. (NumPy sayısal dizi işlemleri ve sinyal işleme veri yapıları için kullanılacaktır.)

SciPy may be used for filters, signal analysis, interpolation, and statistical operations where appropriate. (SciPy uygun olduğunda filtreler, sinyal analizi, interpolasyon ve istatistiksel işlemler için kullanılabilir.)

Mathematical calculations implemented independently in the mobile application must be verified against the Python reference implementation where practical. (Mobil uygulamada bağımsız olarak geliştirilen matematiksel hesaplamalar uygulanabilir olduğu ölçüde Python referans uygulamasına karşı doğrulanmalıdır.)

---

# 29. Data Analysis Stack (Veri Analiz Yığını)

pandas will be used for loading, cleaning, grouping, and analyzing recorded NAVGUARD datasets. (pandas kaydedilmiş NAVGUARD veri setlerini yüklemek, temizlemek, gruplamak ve analiz etmek için kullanılacaktır.)

scikit-learn will provide preprocessing, model evaluation, classification metrics, regression metrics, and baseline machine learning algorithms. (scikit-learn ön işleme, model değerlendirme, sınıflandırma metrikleri, regresyon metrikleri ve temel makine öğrenmesi algoritmalarını sağlayacaktır.)

Matplotlib will provide scientific plots used in experiment analysis and the final report. (Matplotlib deney analizinde ve nihai raporda kullanılan bilimsel grafikleri sağlayacaktır.)

---

# 30. Notebook Policy (Notebook Politikası)

Jupyter notebooks may be used for exploratory analysis and experiment visualization. (Jupyter notebook’ları keşifsel analiz ve deney görselleştirmesi için kullanılabilir.)

Critical preprocessing, metrics, and final training logic should not exist only inside manually executed notebook cells. (Kritik ön işleme, metrikler ve nihai eğitim mantığı yalnızca manuel olarak çalıştırılan notebook hücreleri içerisinde bulunmamalıdır.)

Reusable final logic should be transferred into version-controlled Python modules or scripts. (Yeniden kullanılabilir nihai mantık sürüm kontrollü Python modüllerine veya script’lere aktarılmalıdır.)

---

# 31. Mobile Map Technology (Mobil Harita Teknolojisi)

`flutter_map` will be the preferred Flutter map-rendering library. (`flutter_map`, tercih edilen Flutter harita render kütüphanesi olacaktır.)

The library provides a vendor-independent Flutter mapping layer suitable for displaying estimated and reference routes. (Kütüphane tahmini ve referans rotaları göstermek için uygun, sağlayıcıdan bağımsız bir Flutter haritalama katmanı sağlar.)

The map component will remain a visualization layer and will not become part of the position estimator. (Harita bileşeni bir görselleştirme katmanı olarak kalacak ve konum tahmin motorunun bir parçası olmayacaktır.)

---

# 32. Map Data Source — OpenStreetMap (Harita Veri Kaynağı — OpenStreetMap)

OpenStreetMap-compatible map data will be the preferred map source for development and demonstration. (OpenStreetMap uyumlu harita verisi geliştirme ve gösterim için tercih edilen harita kaynağı olacaktır.)

Visible OpenStreetMap attribution must be displayed when OpenStreetMap data or standard tiles are used. (OpenStreetMap verisi veya standart tile’ları kullanıldığında görünür OpenStreetMap atfı gösterilmelidir.)

The application will not bulk-download or prefetch standard OpenStreetMap raster tiles for offline use because the official tile usage policy prohibits that use of the community tile service. (Uygulama çevrimdışı kullanım için standart OpenStreetMap raster tile’larını toplu olarak indirmeyecek veya önceden yüklemeyecektir çünkü resmî tile kullanım politikası topluluk tile hizmetinin bu şekilde kullanılmasını yasaklamaktadır.)

---

# 33. Offline Map Policy (Çevrimdışı Harita Politikası)

Offline operation of the NAVGUARD estimator will not depend on map imagery being available. (NAVGUARD tahmin motorunun çevrimdışı çalışması harita görüntülerinin kullanılabilir olmasına bağlı olmayacaktır.)

If the device has no network connection and no legal local map package is installed, the estimated trajectory may still be displayed on a coordinate grid or simplified local visualization. (Cihazda ağ bağlantısı yoksa ve yasal bir yerel harita paketi kurulu değilse tahmini rota yine de koordinat ızgarası veya basitleştirilmiş yerel görselleştirme üzerinde gösterilebilir.)

A dedicated offline tile or vector-map package may later be added if the selected data provider explicitly permits offline packaging. (Seçilen veri sağlayıcı çevrimdışı paketlemeye açıkça izin verirse daha sonra özel bir çevrimdışı tile veya vektör harita paketi eklenebilir.)

Offline maps are therefore separate from offline navigation. (Bu nedenle çevrimdışı haritalar ile çevrimdışı navigasyon birbirinden ayrıdır.)

---

# 34. Coordinate Mathematics Technology (Koordinat Matematiği Teknolojisi)

NAVGUARD will use WGS84 geographic coordinates for global latitude and longitude representation. (NAVGUARD global enlem ve boylam temsili için WGS84 coğrafi koordinatlarını kullanacaktır.)

Local navigation will use an east-north-up-compatible local tangent representation. (Yerel navigasyon doğu-kuzey-yukarı uyumlu bir yerel teğet temsil kullanacaktır.)

The exact conversion equations will be implemented in a dedicated testable mathematics module. (Kesin dönüşüm denklemleri özel test edilebilir bir matematik modülünde geliştirilecektir.)

A third-party geospatial library may be used only if its coordinate conventions and numerical behavior are verified against NAVGUARD tests. (Bir üçüncü taraf coğrafi uzamsal kütüphane yalnızca koordinat kuralları ve sayısal davranışı NAVGUARD testlerine karşı doğrulanırsa kullanılabilir.)

---

# 35. Sensor Fusion Technology (Sensör Füzyonu Teknolojisi)

The Extended Kalman Filter will be the primary candidate fusion algorithm. (Genişletilmiş Kalman Filtresi birincil aday füzyon algoritması olacaktır.)

The first implementation should use a small explicitly defined state vector rather than a generic large navigation framework. (İlk uygulama genel büyük bir navigasyon framework’ü yerine küçük ve açıkça tanımlanmış bir durum vektörü kullanmalıdır.)

The EKF may be implemented directly in the NAVGUARD navigation core to preserve control over state definitions, covariance assumptions, and measurement updates. (EKF durum tanımları, kovaryans varsayımları ve ölçüm güncellemeleri üzerinde kontrolü korumak için doğrudan NAVGUARD navigasyon çekirdeğinde geliştirilebilir.)

A lightweight matrix library may be used only if it simplifies implementation without obscuring the estimator equations. (Hafif bir matris kütüphanesi yalnızca tahmin motoru denklemlerini gizlemeden uygulamayı basitleştirirse kullanılabilir.)

---

# 36. Signal Processing Technology (Sinyal İşleme Teknolojisi)

Real-time mobile preprocessing will use lightweight deterministic filters suitable for the measured Redmi Note 9 Pro sampling characteristics. (Gerçek zamanlı mobil ön işleme ölçülen Redmi Note 9 Pro örnekleme özelliklerine uygun hafif deterministik filtreler kullanacaktır.)

Offline filter development and analysis may use SciPy. (Çevrimdışı filtre geliştirme ve analiz SciPy kullanabilir.)

Filter coefficients or thresholds selected through experiments will be stored as versioned configuration values. (Deneyler yoluyla seçilen filtre katsayıları veya eşikleri sürümlenmiş yapılandırma değerleri olarak saklanacaktır.)

---

# 37. State Management Technology (Durum Yönetimi Teknolojisi)

Flutter application state should use a structured reactive state-management approach. (Flutter uygulama durumu yapılandırılmış reaktif bir durum yönetimi yaklaşımı kullanmalıdır.)

Riverpod is the preferred candidate for application-level state management. (Riverpod uygulama seviyesindeki durum yönetimi için tercih edilen adaydır.)

Riverpod will manage low-frequency application and navigation-state snapshots rather than every raw sensor event. (Riverpod her ham sensör olayı yerine düşük frekanslı uygulama ve navigasyon durumu anlık görüntülerini yönetecektir.)

Critical high-frequency streams will remain outside the widget-state layer. (Kritik yüksek frekanslı akışlar widget durum katmanının dışında kalacaktır.)

---

# 38. Local Storage Strategy (Yerel Depolama Stratejisi)

NAVGUARD will use a hybrid local storage architecture. (NAVGUARD hibrit bir yerel depolama mimarisi kullanacaktır.)

SQLite will store session metadata, configuration references, experiment summaries, and other structured low-frequency application records. (SQLite oturum metadata bilgisini, yapılandırma referanslarını, deney özetlerini ve diğer yapılandırılmış düşük frekanslı uygulama kayıtlarını saklayacaktır.)

High-frequency raw sensor streams will primarily use append-oriented files to reduce database write overhead and simplify scientific export. (Yüksek frekanslı ham sensör akışları veritabanı yazma yükünü azaltmak ve bilimsel dışa aktarmayı basitleştirmek için temel olarak append odaklı dosyalar kullanacaktır.)

---

# 39. SQLite Technology (SQLite Teknolojisi)

SQLite will provide the application’s lightweight local relational storage. (SQLite uygulamanın hafif yerel ilişkisel depolamasını sağlayacaktır.)

The Flutter `sqflite` ecosystem is the preferred implementation option unless project bootstrap reveals a compatibility issue. (Proje başlangıcı bir uyumluluk problemi ortaya çıkarmadığı sürece Flutter `sqflite` ekosistemi tercih edilen uygulama seçeneğidir.)

SQLite will not be used as the only storage mechanism for every high-frequency sensor sample unless performance testing proves that design preferable. (Performans testi bu tasarımın tercih edilebilir olduğunu kanıtlamadığı sürece SQLite her yüksek frekanslı sensör örneği için tek depolama mekanizması olarak kullanılmayacaktır.)

---

# 40. High-Frequency Log Format (Yüksek Frekanslı Kayıt Formatı)

CSV will be the initial preferred export and storage format for high-frequency numerical experiment streams. (CSV yüksek frekanslı sayısal deney akışları için başlangıçta tercih edilen dışa aktarma ve depolama formatı olacaktır.)

Separate stream files may be used for IMU, GNSS, ARCore, AI outputs, and estimator states. (IMU, GNSS, ARCore, yapay zekâ çıktıları ve tahmin motoru durumları için ayrı akış dosyaları kullanılabilir.)

Every row must contain a timestamp appropriate to the stream. (Her satır akışa uygun bir zaman damgası içermelidir.)

The file schema will be versioned so that Python replay tools can detect incompatible formats. (Dosya şeması, Python yeniden oynatma araçlarının uyumsuz formatları tespit edebilmesi için sürümlenecektir.)

---

# 41. JSON Technology (JSON Teknolojisi)

JSON will be used for session manifests, device capability reports, experiment configuration snapshots, and other structured metadata. (JSON oturum manifestleri, cihaz yetenek raporları, deney yapılandırma anlık görüntüleri ve diğer yapılandırılmış metadata bilgileri için kullanılacaktır.)

JSON files will remain human-readable to support debugging and documentation. (JSON dosyaları hata ayıklama ve dokümantasyonu desteklemek için insan tarafından okunabilir kalacaktır.)

High-frequency sensor streams will not be stored as deeply nested JSON objects unless testing demonstrates a clear advantage. (Test açık bir avantaj göstermediği sürece yüksek frekanslı sensör akışları derin iç içe geçmiş JSON nesneleri olarak saklanmayacaktır.)

---

# 42. Proposed Session File Structure (Önerilen Oturum Dosya Yapısı)

```
session_id
│
├── manifest.json
├── device.json
├── configuration.json
│
├── imu.csv
├── magnetometer.csv
├── orientation.csv
├── gnss_ground_truth.csv
├── arcore_pose.csv
├── motion_ai.csv
├── step_events.csv
├── heading.csv
├── pdr_state.csv
├── fusion_state.csv
├── quality.csv
├── mode_events.csv
└── diagnostics.csv
```

The final file organization may be optimized after the first logging benchmark. (Nihai dosya organizasyonu ilk kayıt benchmark’ından sonra optimize edilebilir.)

The logical separation of ground truth from estimator inputs must remain intact regardless of the final file layout. (Nihai dosya düzeninden bağımsız olarak gerçek referans ile tahmin motoru girdilerinin mantıksal ayrımı korunmalıdır.)

---

# 43. Data Export Technology (Veri Dışa Aktarma Teknolojisi)

Completed sessions will support explicit export from application-controlled storage. (Tamamlanan oturumlar uygulama kontrollü depolamadan açık dışa aktarmayı destekleyecektir.)

A complete session may be packaged into a compressed archive for transfer to the development computer. (Tam bir oturum geliştirme bilgisayarına aktarım için sıkıştırılmış bir arşiv içerisine paketlenebilir.)

The export process must preserve filenames, timestamps, and manifest information. (Dışa aktarma işlemi dosya adlarını, zaman damgalarını ve manifest bilgisini korumalıdır.)

---

# 44. Replay Technology (Yeniden Oynatma Teknolojisi)

The preferred primary replay environment will be Python because the same environment will already contain data-analysis and evaluation tools. (Tercih edilen temel yeniden oynatma ortamı Python olacaktır çünkü aynı ortam zaten veri analizi ve değerlendirme araçlarını içerecektir.)

Core algorithm replay may additionally be implemented inside the application when this provides useful development value. (Kullanışlı geliştirme değeri sağladığında temel algoritma yeniden oynatma ayrıca uygulama içerisinde geliştirilebilir.)

The same CSV and JSON session formats will be readable by the replay pipeline. (Aynı CSV ve JSON oturum formatları yeniden oynatma hattı tarafından okunabilir olacaktır.)

---

# 45. Python Project Structure (Python Proje Yapısı)

```
ml
├── preprocessing
├── features
├── datasets
├── models
├── training
├── evaluation
├── export
└── tests

experiments
├── notebooks
├── configs
├── results
└── plots
```

Reusable logic will reside in Python modules rather than only in notebooks. (Yeniden kullanılabilir mantık yalnızca notebook’larda değil Python modüllerinde bulunacaktır.)

---

# 46. Mobile Project Structure (Mobil Proje Yapısı)

```
mobile
├── lib
│   ├── core
│   ├── navigation
│   ├── ai
│   ├── data
│   ├── evaluation
│   └── presentation
│
├── android
│   └── native Kotlin integrations
│
├── assets
│   └── models
│
└── test
```

The exact Flutter directory tree may evolve while preserving the architectural boundaries defined in the System Architecture document. (Kesin Flutter klasör ağacı Sistem Mimarisi dokümanında tanımlanan mimari sınırları koruyarak gelişebilir.)

---

# 47. Complete Repository Structure (Tam Repository Yapısı)

```
NAVGUARD
│
├── mobile
├── ml
├── datasets
├── experiments
├── docs
├── scripts
├── test_data
│
├── README.md
├── .gitignore
└── LICENSE
```

The `datasets` directory will not automatically contain every raw private location recording committed to the remote repository. (`datasets` klasörü her ham özel konum kaydını otomatik olarak uzak repository’ye commit etmeyecektir.)

Large or sensitive experiment files will follow a controlled storage policy. (Büyük veya hassas deney dosyaları kontrollü bir depolama politikası izleyecektir.)

---

# 48. Version Control — Git (Sürüm Kontrolü — Git)

Git will be the official source-control system. (Git resmî kaynak kontrol sistemi olacaktır.)

All source code, configuration files, test definitions, model metadata, and important experiment scripts will be version controlled. (Tüm kaynak kodu, yapılandırma dosyaları, test tanımları, model metadata bilgileri ve önemli deney script’leri sürüm kontrollü olacaktır.)

Generated build files and unnecessary IDE files will not be committed. (Oluşturulan build dosyaları ve gereksiz IDE dosyaları commit edilmeyecektir.)

---

# 49. Remote Repository — GitHub (Uzak Repository — GitHub)

GitHub will be the preferred remote source-code repository. (GitHub tercih edilen uzak kaynak kod repository’si olacaktır.)

The repository will serve as the source-of-truth for implementation history. (Repository uygulama geçmişi için ana referans olarak hizmet edecektir.)

Notion will remain the primary detailed project documentation environment during planning. (Notion planlama sırasında birincil ayrıntılı proje dokümantasyon ortamı olarak kalacaktır.)

Important frozen technical decisions should also be mirrored into repository Markdown where they directly affect implementation or reproducibility. (Uygulama veya tekrarlanabilirliği doğrudan etkileyen önemli sabitlenmiş teknik kararlar repository Markdown içerisine de yansıtılmalıdır.)

---

# 50. Branching Strategy (Branch Stratejisi)

The repository will maintain a stable `main` branch. (Repository kararlı bir `main` branch’i tutacaktır.)

Development work may occur through short-lived feature branches. (Geliştirme çalışmaları kısa ömürlü feature branch’ler üzerinden gerçekleştirilebilir.)

Large long-lived branching structures will be avoided because the project has a short development schedule and a single primary developer. (Proje kısa bir geliştirme takvimine ve tek bir birincil geliştiriciye sahip olduğu için büyük ve uzun ömürlü branch yapılarından kaçınılacaktır.)

---

# 51. Commit Policy (Commit Politikası)

Commits should represent coherent technical changes rather than extremely large multi-day snapshots. (Commit’ler aşırı büyük çok günlük anlık görüntüler yerine tutarlı teknik değişiklikleri temsil etmelidir.)

Important experiment configurations should reference the relevant source-code commit when practical. (Önemli deney yapılandırmaları uygulanabilir olduğunda ilgili kaynak kod commit’ine referans vermelidir.)

Final benchmark results must be traceable to a specific application build and source revision. (Nihai benchmark sonuçları belirli bir uygulama build’ine ve kaynak revizyonuna kadar izlenebilir olmalıdır.)

---

# 52. Flutter Dependency Management (Flutter Bağımlılık Yönetimi)

Flutter and Dart dependencies will be managed through Pub. (Flutter ve Dart bağımlılıkları Pub üzerinden yönetilecektir.)

The project will preserve `pubspec.lock` for reproducible application builds. (Proje tekrarlanabilir uygulama build’leri için `pubspec.lock` dosyasını koruyacaktır.)

Dependency versions will not use unnecessarily broad ranges after the final architecture is frozen. (Nihai mimari sabitlendikten sonra bağımlılık sürümleri gereksiz derecede geniş aralıklar kullanmayacaktır.)

---

# 53. Android Dependency Management (Android Bağımlılık Yönetimi)

Native Android dependencies will be managed through Gradle and Maven repositories. (Native Android bağımlılıkları Gradle ve Maven repository’leri üzerinden yönetilecektir.)

ARCore and LiteRT dependencies will be declared explicitly in the Android build configuration. (ARCore ve LiteRT bağımlılıkları Android build yapılandırmasında açıkça tanımlanacaktır.)

Exact dependency versions used by final experiments will be preserved in version control. (Nihai deneylerde kullanılan kesin bağımlılık sürümleri sürüm kontrolünde korunacaktır.)

---

# 54. Python Dependency Management (Python Bağımlılık Yönetimi)

Python development will use an isolated virtual environment. (Python geliştirme izole bir sanal ortam kullanacaktır.)

The final training and evaluation environment will use pinned dependency versions. (Nihai eğitim ve değerlendirme ortamı sabitlenmiş bağımlılık sürümlerini kullanacaktır.)

A `requirements.txt` or equivalent reproducible dependency file will be maintained in the repository. (Repository içerisinde `requirements.txt` veya eşdeğer tekrarlanabilir bir bağımlılık dosyası tutulacaktır.)

---

# 55. Android Build Toolchain (Android Build Araç Zinciri)

Android Studio will be the primary native Android inspection, profiling, and build-diagnostics environment. (Android Studio temel native Android inceleme, profilleme ve build tanı ortamı olacaktır.)

Flutter CLI will remain the primary Flutter project build interface. (Flutter CLI temel Flutter proje build arayüzü olarak kalacaktır.)

Gradle will manage the underlying Android build process. (Gradle temel Android build sürecini yönetecektir.)

The exact JDK, Android Gradle Plugin, compile SDK, and target SDK versions will be frozen during project bootstrap according to the selected stable Flutter and Android toolchain. (Kesin JDK, Android Gradle Plugin, compile SDK ve target SDK sürümleri seçilen kararlı Flutter ve Android araç zincirine göre proje başlangıcında sabitlenecektir.)

---

# 56. Android SDK Policy (Android SDK Politikası)

The project will use the latest stable Android compile and target SDK versions compatible with the selected Flutter toolchain at implementation start. (Proje geliştirme başlangıcında seçilen Flutter araç zinciriyle uyumlu en güncel kararlı Android compile ve target SDK sürümlerini kullanacaktır.)

The minimum SDK will be selected based on the physical Redmi Note 9 Pro and ARCore requirements rather than broad legacy-device support. (Minimum SDK geniş eski cihaz desteği yerine fiziksel Redmi Note 9 Pro ve ARCore gereksinimlerine göre seçilecektir.)

API 24 is the provisional lower bound until the actual project manifest is finalized. (Gerçek proje manifest’i kesinleştirilene kadar API 24 geçici alt sınırdır.)

---

# 57. Flutter Testing Stack (Flutter Test Yığını)

`flutter_test` will be used for Dart unit tests and Flutter widget tests. (`flutter_test`, Dart birim testleri ve Flutter widget testleri için kullanılacaktır.)

`integration_test` will be used for end-to-end application workflows that require the Android application runtime. (`integration_test`, Android uygulama çalışma zamanını gerektiren uçtan uca uygulama iş akışları için kullanılacaktır.)

Navigation mathematics should be tested without requiring widgets whenever practical. (Navigasyon matematiği uygulanabilir olduğu ölçüde widget gerektirmeden test edilmelidir.)

---

# 58. Native Android Testing Stack (Native Android Test Yığını)

JUnit will be used for testable Kotlin logic. (JUnit test edilebilir Kotlin mantığı için kullanılacaktır.)

Android instrumentation tests may be used for functionality requiring physical Android APIs. (Android instrumentation testleri fiziksel Android API’lerini gerektiren işlevler için kullanılabilir.)

SensorManager, LocationManager, ARCore, and LiteRT runtime behavior will additionally require physical-device tests because emulators cannot reproduce the project’s complete hardware behavior. (SensorManager, LocationManager, ARCore ve LiteRT çalışma zamanı davranışı ayrıca fiziksel cihaz testleri gerektirecektir çünkü emülatörler projenin tam donanım davranışını yeniden üretemez.)

---

# 59. Python Testing Stack (Python Test Yığını)

pytest will be the preferred automated testing framework for Python preprocessing, evaluation, replay, and model-support modules. (pytest, Python ön işleme, değerlendirme, yeniden oynatma ve model destek modülleri için tercih edilen otomatik test framework’ü olacaktır.)

Metric calculations will receive tests using small deterministic reference inputs. (Metrik hesaplamaları küçük deterministik referans girdiler kullanılarak test edilecektir.)

Data parsers will be tested against valid, incomplete, and malformed session files. (Veri parser’ları geçerli, eksik ve bozuk oturum dosyalarına karşı test edilecektir.)

---

# 60. Code Quality Tools (Kod Kalite Araçları)

`flutter analyze` will be required for the Flutter project. (`flutter analyze`, Flutter projesi için zorunlu olacaktır.)

Dart formatting tools will maintain consistent Dart source formatting. (Dart formatlama araçları tutarlı Dart kaynak kodu formatını koruyacaktır.)

Kotlin source will follow Android Studio and Kotlin standard formatting conventions. (Kotlin kaynak kodu Android Studio ve Kotlin standart formatlama kurallarını izleyecektir.)

Python source should follow a consistent formatter and linting policy selected during repository initialization. (Python kaynak kodu repository başlangıcında seçilen tutarlı bir formatter ve linting politikasını izlemelidir.)

---

# 61. Android Diagnostic Tools (Android Tanı Araçları)

ADB will be used for device inspection, application installation, log collection, and selected runtime diagnostics. (ADB cihaz inceleme, uygulama kurulumu, log toplama ve seçilen çalışma zamanı tanıları için kullanılacaktır.)

Android Studio Logcat will provide native runtime logs. (Android Studio Logcat native çalışma zamanı loglarını sağlayacaktır.)

Android Studio Profiler will be used where practical for CPU, memory, and application resource analysis. (Android Studio Profiler uygulanabilir olduğu ölçüde CPU, bellek ve uygulama kaynak analizi için kullanılacaktır.)

---

# 62. Performance Profiling Technology (Performans Profilleme Teknolojisi)

Performance measurements will combine application-generated timing records with Android profiling tools. (Performans ölçümleri uygulama tarafından oluşturulan zamanlama kayıtlarını Android profilleme araçlarıyla birleştirecektir.)

AI inference latency will be measured directly around the LiteRT inference call using an appropriate monotonic timing source. (Yapay zekâ çıkarım gecikmesi uygun bir monotonik zamanlama kaynağı kullanılarak doğrudan LiteRT çıkarım çağrısı çevresinde ölçülecektir.)

Sensor processing latency should not be derived solely from user-interface frame timing. (Sensör işleme gecikmesi yalnızca kullanıcı arayüzü kare zamanlamasından türetilmemelidir.)

---

# 63. Continuous Integration Policy (Sürekli Entegrasyon Politikası)

GitHub Actions may be used for automatic static analysis and test execution. (GitHub Actions otomatik statik analiz ve test çalıştırma için kullanılabilir.)

At minimum, automated checks should eventually include Flutter analysis, Flutter unit tests, and Python unit tests. (Minimum olarak otomatik kontroller zamanla Flutter analizini, Flutter birim testlerini ve Python birim testlerini içermelidir.)

Physical sensor and ARCore tests cannot be replaced by cloud CI because they depend on the Redmi Note 9 Pro hardware. (Fiziksel sensör ve ARCore testleri Redmi Note 9 Pro donanımına bağlı oldukları için cloud CI tarafından değiştirilemez.)

---

# 64. Documentation Technology (Dokümantasyon Teknolojisi)

Notion will remain the primary planning and technical documentation workspace. (Notion temel planlama ve teknik dokümantasyon çalışma alanı olarak kalacaktır.)

Repository Markdown will contain implementation-critical documentation that should travel together with the source code. (Repository Markdown kaynak koduyla birlikte hareket etmesi gereken uygulama açısından kritik dokümantasyonu içerecektir.)

The main repository will include at least a project README and technical setup instructions. (Ana repository en azından proje README’si ve teknik kurulum talimatlarını içerecektir.)

---

# 65. Diagram Technology (Diyagram Teknolojisi)

diagrams.net or another exportable diagramming tool may be used for system architecture and data-flow diagrams. (diagrams.net veya başka bir dışa aktarılabilir diyagram aracı sistem mimarisi ve veri akışı diyagramları için kullanılabilir.)

Final important diagrams should be exported into repository-compatible image or vector formats. (Nihai önemli diyagramlar repository ile uyumlu görüntü veya vektör formatlarına dışa aktarılmalıdır.)

A diagram should supplement the written architecture rather than replace its technical definitions. (Bir diyagram yazılı mimariyi desteklemeli ancak teknik tanımlarının yerini almamalıdır.)

---

# 66. No Mandatory Backend Decision (Zorunlu Backend Olmaması Kararı)

NAVGUARD will not use a mandatory backend server for its primary project scope. (NAVGUARD temel proje kapsamı için zorunlu bir backend sunucusu kullanmayacaktır.)

No Firebase database, REST backend, cloud database, or remote inference server is required for core navigation. (Temel navigasyon için Firebase veritabanı, REST backend, cloud veritabanı veya uzak çıkarım sunucusu gerekli değildir.)

This decision reduces cost, latency, network dependency, privacy exposure, and architectural complexity. (Bu karar maliyeti, gecikmeyi, ağ bağımlılığını, gizlilik riskini ve mimari karmaşıklığı azaltır.)

---

# 67. No Mandatory External API Decision (Zorunlu Harici API Olmaması Kararı)

The core NAVGUARD estimator will not depend on a paid external API. (Temel NAVGUARD tahmin motoru ücretli bir harici API’ye bağımlı olmayacaktır.)

Artificial intelligence inference will remain local. (Yapay zekâ çıkarımı yerel kalacaktır.)

Sensor processing will remain local. (Sensör işleme yerel kalacaktır.)

GNSS position acquisition will use the Android device itself. (GNSS konum veri toplama Android cihazın kendisini kullanacaktır.)

---

# 68. Cost Baseline (Maliyet Temel Referansı)

The mandatory NAVGUARD software stack is intended to be developable without purchasing additional software services. (Zorunlu NAVGUARD yazılım yığınının ek yazılım hizmetleri satın almadan geliştirilebilir olması amaçlanmaktadır.)

The existing Android phone and development computer are sufficient for the planned prototype architecture. (Mevcut Android telefon ve geliştirme bilgisayarı planlanan prototip mimarisi için yeterlidir.)

Optional commercial map services, cloud platforms, or additional hardware are outside the mandatory stack. (İsteğe bağlı ticari harita hizmetleri, bulut platformları veya ek donanım zorunlu yığının dışındadır.)

---

# 69. Technology Dependency Risk Policy (Teknoloji Bağımlılık Risk Politikası)

A technology must not become a single point of failure unless it is explicitly part of the minimum architecture. (Bir teknoloji açıkça minimum mimarinin bir parçası olmadığı sürece tek hata noktası haline gelmemelidir.)

ARCore failure must leave PDR available. (ARCore başarısızlığı PDR’yi kullanılabilir bırakmalıdır.)

A LiteRT runtime problem must allow deterministic navigation to continue without AI when technically possible. (Bir LiteRT çalışma zamanı problemi teknik olarak mümkün olduğunda deterministik navigasyonun yapay zekâ olmadan devam etmesine izin vermelidir.)

Online map failure must not disable the estimator. (Çevrimiçi harita başarısızlığı tahmin motorunu devre dışı bırakmamalıdır.)

---

# 70. Technology Replacement Rules (Teknoloji Değiştirme Kuralları)

A selected technology may be replaced if physical device testing demonstrates a compatibility or performance problem. (Seçilen bir teknoloji fiziksel cihaz testi bir uyumluluk veya performans problemi gösterirse değiştirilebilir.)

Replacement decisions must preserve the requirements defined in the SRS. (Değiştirme kararları SRS içerisinde tanımlanan gereksinimleri korumalıdır.)

A major replacement must be recorded in 43 — Technical Decisions & Change Log. (Büyük bir değişiklik 43 — Technical Decisions & Change Log içerisinde kaydedilmelidir.)

---

# 71. Version Freeze Strategy (Sürüm Sabitleme Stratejisi)

Technology categories are frozen by this document, but exact package versions will be frozen during implementation bootstrap. (Teknoloji kategorileri bu dokümanla sabitlenmiştir ancak kesin paket sürümleri geliştirme başlangıcında sabitlenecektir.)

The initial repository setup will record the exact Flutter, Dart, Android SDK, Kotlin, Gradle, LiteRT, ARCore, Python, and primary package versions. (İlk repository kurulumu kesin Flutter, Dart, Android SDK, Kotlin, Gradle, LiteRT, ARCore, Python ve temel paket sürümlerini kaydedecektir.)

The generated environment snapshot will become part of the NAVGUARD reproducibility record. (Oluşturulan ortam anlık görüntüsü NAVGUARD tekrarlanabilirlik kaydının bir parçası olacaktır.)

---

# 72. Proposed Environment Record (Önerilen Ortam Kaydı)

```
Flutter Version TBD
Dart Version TBD
Android Compile SDK TBD
Android Target SDK TBD
Android Minimum SDK Provisional API 24
Kotlin Version TBD
Gradle Version TBD
Android Gradle Plugin TBD
ARCore SDK Version TBD
LiteRT Version TBD
Python Version Provisional 3.12
TensorFlow  Keras Version TBD
scikit-learn Version TBD
NumPy Version TBD
pandas Version TBD
SciPy Version TBD
flutter_map Version TBD
```

The values marked as TBD will be filled during project bootstrap and will then be committed to version control. (TBD olarak işaretlenen değerler proje başlangıcında doldurulacak ve daha sonra sürüm kontrolüne commit edilecektir.)

---

# 73. Technology-to-Architecture Mapping (Teknoloji-Mimari Eşleştirmesi)

| Architecture Component (Mimari Bileşen) | Technology (Teknoloji) |
| --- | --- |
| Presentation Layer (Sunum Katmanı) Fl | utter Dart |
| Application State (Uygulama Durumu) Da | rt + Riverpod Candidate (Dart + Riverpod Adayı) |
| Platform Bridge (Platform Köprüsü) Fl | utter Platform Channels |
| Sensor Acquisition (Sensör Veri Toplama) Ko | tlin + SensorManager |
| GNSS Manager (GNSS Yöneticisi) Ko | tlin + LocationManager |
| GNSS Diagnostics (GNSS Tanısı) Ko | tlin + GnssStatus |
| ARCore Manager (ARCore Yöneticisi) Ko | tlin + ARCore SDK |
| Motion AI Runtime (Hareket AI Çalışma Zamanı) Ko | tlin + LiteRT |
| PDR Engine (PDR Motoru) Da | rt Pure Navigation Core (Dart Saf Navigasyon Çekirdeği) |
| Heading Engine (Yön Motoru) Da | rt with Native Sensor Inputs (Native Sensör Girdileriyle Dart) |
| EKF Fusion (EKF Füzyonu) Da | rt Navigation Core, Subject to Profiling (Dart Navigasyon Çekirdeği, Profillemeye Tabi) |
| Session Metadata (Oturum Metadata Bilgisi) SQ | Lite |
| Sensor Logs (Sensör Kayıtları) CS | V |
| Session Manifest (Oturum Manifest’i) JS | ON |
| Mapping (Haritalama) fl | utter_map + OSM-Compatible Source |
| ML Training (ML Eğitimi) Py | thon + TensorFlowKeras |
| Classical ML (Klasik ML) Py | thon + scikit-learn |
| Analysis (Analiz) Nu | mPy + pandas + SciPy |
| Plots (Grafikler) Ma | tplotlib |
| Testing (Test) Fl | utter Test + JUnit + pytest |
| Repository (Repository) Gi | t + GitHub |
| Documentation (Dokümantasyon) No | tion + Markdown |

---

# 74. Technology Decision — Sensor Core (Teknoloji Kararı — Sensör Çekirdeği)

Decision Native Android SensorManager through Kotlin will be the authoritative sensor source. (Karar Kotlin üzerinden Native Android SensorManager ana sensör kaynağı olacaktır.)

Reason The research requires direct access to timestamps, metadata, sampling behavior, and device-specific sensor characteristics. (Neden Araştırma zaman damgalarına, metadata bilgisine, örnekleme davranışına ve cihaza özgü sensör özelliklerine doğrudan erişim gerektirir.)

---

# 75. Technology Decision — GNSS Core (Teknoloji Kararı — GNSS Çekirdeği)

Decision Android LocationManager with GPS_PROVIDER will be the authoritative GNSS reference interface. (Karar GPS_PROVIDER ile Android LocationManager ana GNSS referans arayüzü olacaktır.)

Reason Formal evaluation requires an explicitly GNSS-based reference stream that can remain isolated from the denied estimator. (Neden Resmî değerlendirme kesinti tahmin motorundan izole kalabilen açıkça GNSS tabanlı bir referans akışı gerektirir.)

---

# 76. Technology Decision — AI Runtime (Teknoloji Kararı — AI Çalışma Zamanı)

Decision LiteRT will execute the final motion model through the native Android layer. (Karar LiteRT nihai hareket modelini native Android katmanı üzerinden çalıştıracaktır.)

Reason This provides direct Android control, reduces Flutter plugin dependency, supports offline inference, and improves runtime reproducibility. (Neden Bu yaklaşım doğrudan Android kontrolü sağlar, Flutter eklenti bağımlılığını azaltır, çevrimdışı çıkarımı destekler ve çalışma zamanı tekrarlanabilirliğini artırır.)

---

# 77. Technology Decision — ARCore (Teknoloji Kararı — ARCore)

Decision ARCore will be integrated natively in Kotlin as an optional advanced navigation source. (Karar ARCore isteğe bağlı gelişmiş navigasyon kaynağı olarak Kotlin içerisinde native şekilde entegre edilecektir.)

Reason ARCore pose and tracking information are navigation data rather than merely a visual augmented-reality interface. (Neden ARCore poz ve takip bilgisi yalnızca görsel bir artırılmış gerçeklik arayüzü yerine navigasyon verisidir.)

---

# 78. Technology Decision — Storage (Teknoloji Kararı — Depolama)

Decision NAVGUARD will use SQLite for structured metadata and append-oriented files for high-frequency experimental streams. (Karar NAVGUARD yapılandırılmış metadata bilgisi için SQLite ve yüksek frekanslı deney akışları için append odaklı dosyalar kullanacaktır.)

Reason This hybrid strategy keeps application queries convenient while preserving efficient scientific data export. (Neden Bu hibrit strateji verimli bilimsel veri dışa aktarmayı korurken uygulama sorgularını kullanışlı tutar.)

---

# 79. Technology Decision — Maps (Teknoloji Kararı — Haritalar)

Decision `flutter_map` with an OpenStreetMap-compatible map source will provide route visualization. (Karar OpenStreetMap uyumlu bir harita kaynağıyla `flutter_map` rota görselleştirmesi sağlayacaktır.)

Reason The solution avoids a mandatory paid map API and keeps the map separate from the navigation estimator. (Neden Çözüm zorunlu ücretli bir harita API’sinden kaçınır ve haritayı navigasyon tahmin motorundan ayrı tutar.)

---

# 80. Technology Decision — ML Experimentation (Teknoloji Kararı — ML Deneyleri)

Decision Python will remain the authoritative offline machine learning and experiment-analysis environment. (Karar Python ana çevrimdışı makine öğrenmesi ve deney analiz ortamı olarak kalacaktır.)

Reason Python provides mature time-series processing, classical machine learning, neural-network training, statistics, and scientific visualization capabilities in one environment. (Neden Python tek bir ortam içerisinde olgun zaman serisi işleme, klasik makine öğrenmesi, sinir ağı eğitimi, istatistik ve bilimsel görselleştirme yetenekleri sağlar.)

---

# 81. Mandatory Technology Stack (Zorunlu Teknoloji Yığını)

The following technologies are mandatory for the defined minimum NAVGUARD architecture. (Aşağıdaki teknolojiler tanımlanan minimum NAVGUARD mimarisi için zorunludur.)

Android (Android)
Flutter (Flutter)
Dart (Dart)
Kotlin (Kotlin)
Android SensorManager (Android SensorManager)
Android LocationManager (Android LocationManager)
Python (Python)
scikit-learn (scikit-learn)
On-Device ML Runtime through LiteRT or the formally approved compatible replacement (LiteRT veya resmî olarak onaylanmış uyumlu alternatifi üzerinden cihaz üzeri ML çalışma zamanı)
Local Session Storage (Yerel Oturum Depolama)
Git (Git)

---

# 82. Target Technology Stack (Hedef Teknoloji Yığını)

The following technologies belong to the intended target NAVGUARD architecture. (Aşağıdaki teknolojiler planlanan hedef NAVGUARD mimarisine aittir.)

Google ARCore (Google ARCore)
LiteRT Native Android Runtime (LiteRT Native Android Çalışma Zamanı)
1D-CNN Motion Classification (1D-CNN Hareket Sınıflandırması)
Extended Kalman Filter (Genişletilmiş Kalman Filtresi)
Riverpod State Management (Riverpod Durum Yönetimi)
SQLite Metadata Storage (SQLite Metadata Depolama)
flutter_map (flutter_map)
OpenStreetMap-Compatible Map Data (OpenStreetMap Uyumlu Harita Verisi)
SciPy (SciPy)
Matplotlib (Matplotlib)

---

# 83. Optional Technology Stack (İsteğe Bağlı Teknoloji Yığını)

The following technologies may be introduced only when their value is justified. (Aşağıdaki teknolojiler yalnızca değerleri gerekçelendirildiğinde dahil edilebilir.)

XGBoost (XGBoost)
GPU LiteRT Delegate (GPU LiteRT Delegate’i)
Raw GNSS APIs (Ham GNSS API’leri)
Offline Vector Map Package (Çevrimdışı Vektör Harita Paketi)
Automated GitHub Actions CI (Otomatik GitHub Actions CI)
Compressed Session Export (Sıkıştırılmış Oturum Dışa Aktarma)

Optional technologies must not delay mandatory project completion. (İsteğe bağlı teknolojiler zorunlu proje tamamlanmasını geciktirmemelidir.)

---

# 84. Technologies Explicitly Not Selected (Açıkça Seçilmeyen Teknolojiler)

Firebase is not selected as a mandatory NAVGUARD backend. (Firebase zorunlu NAVGUARD backend’i olarak seçilmemiştir.)

A cloud-hosted AI model is not selected for real-time navigation. (Bulutta barındırılan bir yapay zekâ modeli gerçek zamanlı navigasyon için seçilmemiştir.)

Google Maps Platform is not required for the mandatory map implementation. (Google Maps Platform zorunlu harita uygulaması için gerekli değildir.)

A custom visual-inertial odometry implementation from raw camera frames is not selected. (Ham kamera karelerinden özel bir görsel-ataletsel odometri uygulaması seçilmemiştir.)

A microservice backend architecture is not selected. (Mikroservis backend mimarisi seçilmemiştir.)

iOS development technologies are not selected. (iOS geliştirme teknolojileri seçilmemiştir.)

---

# 85. Technology Validation Before Development Freeze (Geliştirme Sabitlemesinden Önce Teknoloji Doğrulaması)

The Android sensor stack must pass the Device Capability Audit. (Android sensör yığını Cihaz Yetenek Denetimini geçmelidir.)

The ARCore stack must successfully initialize and provide usable pose information on the physical Redmi Note 9 Pro before final integration. (ARCore yığını nihai entegrasyondan önce fiziksel Redmi Note 9 Pro üzerinde başarıyla başlamalı ve kullanılabilir poz bilgisi sağlamalıdır.)

The LiteRT stack must execute a representative model locally before the final AI deployment approach is frozen. (LiteRT yığını nihai yapay zekâ dağıtım yaklaşımı sabitlenmeden önce temsili bir modeli yerel olarak çalıştırmalıdır.)

The storage stack must complete the continuous logging audit without corrupting experimental data. (Depolama yığını deneysel veriyi bozmadan sürekli kayıt denetimini tamamlamalıdır.)

---

# 86. Technology Stack Freeze Conditions (Teknoloji Yığını Sabitleme Koşulları)

The technology categories defined in this document are considered the official pre-development selection. (Bu dokümanda tanımlanan teknoloji kategorileri resmî geliştirme öncesi seçim olarak kabul edilir.)

Exact versions will remain provisional until the development environment is initialized. (Kesin sürümler geliştirme ortamı başlatılana kadar geçici kalacaktır.)

The stack will be considered frozen when the repository is created, dependencies are installed successfully, the application builds on Android, and the first device capability application runs on the Redmi Note 9 Pro. (Repository oluşturulduğunda, bağımlılıklar başarıyla kurulduğunda, uygulama Android üzerinde build edildiğinde ve ilk cihaz yetenek uygulaması Redmi Note 9 Pro üzerinde çalıştığında yığın sabitlenmiş kabul edilecektir.)

---

# 87. Final Technology Stack Statement (Nihai Teknoloji Yığını Bildirimi)

NAVGUARD will use Flutter and Dart for the mobile application layer, Kotlin and official Android APIs for hardware-sensitive sensor and GNSS access, ARCore for optional visual-inertial tracking, and Google LiteRT for local artificial intelligence inference. (NAVGUARD mobil uygulama katmanı için Flutter ve Dart’ı, donanıma duyarlı sensör ve GNSS erişimi için Kotlin ve resmî Android API’lerini, isteğe bağlı görsel-ataletsel takip için ARCore’u ve yerel yapay zekâ çıkarımı için Google LiteRT’yi kullanacaktır.)

Python will provide the offline machine learning, signal analysis, replay, benchmarking, and scientific evaluation environment. (Python çevrimdışı makine öğrenmesi, sinyal analizi, yeniden oynatma, benchmark ve bilimsel değerlendirme ortamını sağlayacaktır.)

SQLite, structured file-based logging, JSON metadata, Git, GitHub, Notion, and OpenStreetMap-compatible visualization will complete the supporting engineering stack without requiring a mandatory cloud backend or paid runtime service. (SQLite, yapılandırılmış dosya tabanlı kayıt, JSON metadata, Git, GitHub, Notion ve OpenStreetMap uyumlu görselleştirme; zorunlu bir cloud backend veya ücretli çalışma zamanı hizmeti gerektirmeden destekleyici mühendislik yığınını tamamlayacaktır.)

---

# 88. Current Document Status (Mevcut Doküman Durumu)

Document Status Pre-Development Technology Stack Completed (Doküman Durumu Geliştirme Öncesi Teknoloji Yığını Tamamlandı)

Exact Version Status Pending Environment Bootstrap (Kesin Sürüm Durumu Ortam Başlatma Bekleniyor)

Primary Mobile Framework Flutter (Birincil Mobil Framework Flutter)

Primary Languages Dart + Kotlin + Python (Birincil Diller Dart + Kotlin + Python)

Authoritative Sensor Technology Android SensorManager (Ana Sensör Teknolojisi Android SensorManager)

Authoritative GNSS Technology Android LocationManager GPS_PROVIDER (Ana GNSS Teknolojisi Android LocationManager GPS_PROVIDER)

Visual-Inertial Technology Google ARCore (Görsel-Ataletsel Teknoloji Google ARCore)

On-Device AI Technology Google LiteRT (Cihaz Üzeri Yapay Zekâ Teknolojisi Google LiteRT)

Map Technology flutter_map + OpenStreetMap-Compatible Source (Harita Teknolojisi flutter_map + OpenStreetMap Uyumlu Kaynak)

Data Analysis Environment Python (Veri Analiz Ortamı Python)

Mandatory Backend None (Zorunlu Backend Yok)

Mandatory Paid API None (Zorunlu Ücretli API Yok)

Next Documentation Item 10 — Android & Mobile Architecture (Sonraki Dokümantasyon Öğesi 10 — Android ve Mobil Mimari)