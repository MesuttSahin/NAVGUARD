# 03 — Project Scope & Boundaries (Proje Kapsamı ve Sınırları)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the functional, technical, experimental, and operational scope of the NAVGUARD project. *(Bu doküman, NAVGUARD projesinin fonksiyonel, teknik, deneysel ve operasyonel kapsamını tanımlar.)*

It establishes which capabilities are mandatory, which capabilities are desirable, which capabilities are optional, and which capabilities are explicitly outside the project scope. *(Hangi yeteneklerin zorunlu, hangilerinin tercih edilen, hangilerinin isteğe bağlı ve hangilerinin açıkça proje kapsamı dışında olduğunu belirler.)*

The primary purpose of this document is to prevent uncontrolled scope growth during the 24-business-day development period. *(Bu dokümanın temel amacı, 24 iş günlük geliştirme süresi boyunca kontrolsüz kapsam büyümesini önlemektir.)*

All future feature requests and technical changes must be evaluated against the scope defined in this document. *(Gelecekteki tüm özellik talepleri ve teknik değişiklikler bu dokümanda tanımlanan kapsama göre değerlendirilmelidir.)*

---

# 2. Scope Definition (Kapsam Tanımı)

NAVGUARD will be developed as an Android-based research and proof-of-concept application for short-term pedestrian navigation during simulated GNSS outages. *(NAVGUARD, simüle edilmiş GNSS kesintileri sırasında kısa süreli yaya navigasyonu için Android tabanlı bir araştırma ve kavram kanıtlama uygulaması olarak geliştirilecektir.)*

The project will use sensors and processing resources available on the Xiaomi Redmi Note 9 Pro as its primary hardware platform. *(Proje, birincil donanım platformu olarak Xiaomi Redmi Note 9 Pro üzerinde bulunan sensörleri ve işlem kaynaklarını kullanacaktır.)*

The project will focus on estimating pedestrian displacement and position after a reliable GNSS reference position has been obtained. *(Proje, güvenilir bir GNSS referans konumu elde edildikten sonra yaya yer değiştirmesini ve konumunu tahmin etmeye odaklanacaktır.)*

The navigation system will combine conventional navigation algorithms with on-device artificial intelligence where measurable benefit is expected. *(Navigasyon sistemi, ölçülebilir fayda beklenen noktalarda geleneksel navigasyon algoritmalarını cihaz üzerinde çalışan yapay zekâyla birleştirecektir.)*

The project will prioritize experimentally measurable navigation performance over production-level application complexity. *(Proje, üretim seviyesinde uygulama karmaşıklığı yerine deneysel olarak ölçülebilir navigasyon performansına öncelik verecektir.)*

---

# 3. Project Scope Prioritization Method (Proje Kapsamı Önceliklendirme Yöntemi)

The NAVGUARD feature set will be managed using four priority levels. *(NAVGUARD özellik seti dört öncelik seviyesi kullanılarak yönetilecektir.)*

**MUST** features are required for the project to be considered technically complete. *(MUST özellikleri, projenin teknik olarak tamamlanmış kabul edilmesi için zorunludur.)*

**SHOULD** features are important advanced capabilities that should be implemented if the core system remains stable and the development schedule allows. *(SHOULD özellikleri, temel sistem kararlı kaldığı ve geliştirme takvimi izin verdiği sürece uygulanması gereken önemli gelişmiş yeteneklerdir.)*

**COULD** features are optional improvements that will only be implemented after all mandatory and selected advanced components are complete. *(COULD özellikleri, yalnızca tüm zorunlu ve seçilmiş gelişmiş bileşenler tamamlandıktan sonra uygulanacak isteğe bağlı iyileştirmelerdir.)*

**OUT OF SCOPE** items will not be implemented during the defined project period. *(OUT OF SCOPE maddeleri tanımlanan proje süresi içerisinde uygulanmayacaktır.)*

---

# 4. MUST — Mandatory Project Scope (MUST — Zorunlu Proje Kapsamı)

## 4.1 Android Application (Android Uygulaması)

NAVGUARD must be delivered as a functional Android mobile application. *(NAVGUARD çalışan bir Android mobil uygulaması olarak teslim edilmelidir.)*

The application must be installable and executable on the Xiaomi Redmi Note 9 Pro. *(Uygulama Xiaomi Redmi Note 9 Pro üzerine kurulabilir ve çalıştırılabilir olmalıdır.)*

The project does not require support for iOS, web, desktop, or other mobile platforms. *(Proje iOS, web, masaüstü veya diğer mobil platformlar için destek gerektirmez.)*

---

## 4.2 Device Capability Verification (Cihaz Yetenek Doğrulaması)

The application must verify the availability of required sensors on the physical test device before advanced navigation development begins. *(Uygulama, gelişmiş navigasyon geliştirmesi başlamadan önce fiziksel test cihazında gerekli sensörlerin kullanılabilirliğini doğrulamalıdır.)*

The measured sensor capabilities must be documented instead of relying only on theoretical specifications. *(Yalnızca teorik özelliklere güvenmek yerine ölçülen sensör yetenekleri dokümante edilmelidir.)*

Actual sampling behavior and sensor availability must be recorded during the Device Capability Audit. *(Gerçek örnekleme davranışı ve sensör kullanılabilirliği Cihaz Yetenek Denetimi sırasında kaydedilmelidir.)*

---

## 4.3 Sensor Data Acquisition (Sensör Veri Toplama)

NAVGUARD must collect accelerometer data from the target Android device. *(NAVGUARD hedef Android cihazdan ivmeölçer verisi toplamalıdır.)*

NAVGUARD must collect gyroscope data from the target Android device. *(NAVGUARD hedef Android cihazdan jiroskop verisi toplamalıdır.)*

NAVGUARD must collect magnetometer data when the sensor is available and operating correctly. *(NAVGUARD sensör mevcut ve doğru çalışıyorsa manyetometre verisi toplamalıdır.)*

NAVGUARD must collect suitable orientation or rotation information for heading estimation. *(NAVGUARD yön tahmini için uygun yönelim veya dönüş bilgisi toplamalıdır.)*

NAVGUARD must collect GNSS position and accuracy information. *(NAVGUARD GNSS konum ve doğruluk bilgisi toplamalıdır.)*

Sensor measurements must include timestamps suitable for later synchronization and analysis. *(Sensör ölçümleri daha sonraki senkronizasyon ve analiz için uygun zaman damgaları içermelidir.)*

---

## 4.4 Sensor Logging (Sensör Kayıt Sistemi)

NAVGUARD must include a session-based sensor logging mechanism. *(NAVGUARD oturum tabanlı bir sensör kayıt mekanizması içermelidir.)*

A user must be able to start and stop a recording session. *(Bir kullanıcı bir kayıt oturumunu başlatabilmeli ve durdurabilmelidir.)*

The system must preserve sensor and navigation measurements required for later experimentation. *(Sistem daha sonraki deneyler için gerekli sensör ve navigasyon ölçümlerini saklamalıdır.)*

Recorded sessions must be distinguishable from each other using unique identifiers or timestamps. *(Kaydedilen oturumlar benzersiz tanımlayıcılar veya zaman damgaları kullanılarak birbirinden ayırt edilebilir olmalıdır.)*

---

## 4.5 Initial GNSS Positioning (Başlangıç GNSS Konumlandırması)

NAVGUARD must obtain a sufficiently reliable GNSS position before a controlled GNSS-denied test begins. *(NAVGUARD kontrollü bir GNSS kesinti testi başlamadan önce yeterince güvenilir bir GNSS konumu elde etmelidir.)*

This position must be stored as the initial global anchor for the navigation session. *(Bu konum navigasyon oturumu için başlangıç global referans noktası olarak saklanmalıdır.)*

GNSS accuracy information must be considered before the initial anchor is accepted. *(Başlangıç referansı kabul edilmeden önce GNSS doğruluk bilgisi dikkate alınmalıdır.)*

---

## 4.6 GNSS-Denied Simulation Mode (GNSS Kesinti Simülasyon Modu)

The application must provide a controlled software-based mechanism for simulating GNSS unavailability. *(Uygulama GNSS kullanılamazlığını simüle etmek için kontrollü yazılım tabanlı bir mekanizma sağlamalıdır.)*

When the GNSS-denied mode is activated, GNSS position updates must not be provided to the active NAVGUARD position estimator. *(GNSS kesinti modu etkinleştirildiğinde GNSS konum güncellemeleri aktif NAVGUARD konum tahmin motoruna verilmemelidir.)*

GNSS data may continue to be recorded separately for ground-truth evaluation. *(GNSS verileri gerçek referans değerlendirmesi için ayrı olarak kaydedilmeye devam edebilir.)*

A clear separation must exist between navigation input data and evaluation reference data. *(Navigasyon girdi verileri ile değerlendirme referans verileri arasında açık bir ayrım bulunmalıdır.)*

---

## 4.7 Step Detection (Adım Tespiti)

NAVGUARD must implement a working step detection mechanism. *(NAVGUARD çalışan bir adım tespit mekanizması geliştirmelidir.)*

The initial step detector may use deterministic signal-processing methods such as filtering and peak detection. *(İlk adım tespit sistemi filtreleme ve tepe noktası tespiti gibi deterministik sinyal işleme yöntemlerini kullanabilir.)*

The step detection system must be evaluated against manually observed or independently verified step counts. *(Adım tespit sistemi elle gözlemlenen veya bağımsız olarak doğrulanan adım sayılarıyla değerlendirilmelidir.)*

---

## 4.8 Baseline Step Length Estimation (Temel Adım Uzunluğu Tahmini)

The baseline system must include a deterministic method for estimating pedestrian step length. *(Temel sistem yaya adım uzunluğunu tahmin etmek için deterministik bir yöntem içermelidir.)*

A fixed or calibrated step length may be used as the first baseline implementation. *(İlk temel uygulama olarak sabit veya kalibre edilmiş bir adım uzunluğu kullanılabilir.)*

The baseline step length model must remain available for comparison even if a machine learning model is later introduced. *(Daha sonra bir makine öğrenmesi modeli eklense bile temel adım uzunluğu modeli karşılaştırma için kullanılabilir durumda kalmalıdır.)*

---

## 4.9 Heading Estimation (Yön Tahmini)

NAVGUARD must estimate the user’s movement heading. *(NAVGUARD kullanıcının hareket yönünü tahmin etmelidir.)*

The heading estimator must use suitable smartphone orientation information rather than relying on a single unfiltered magnetic measurement. *(Yön tahmin sistemi tek bir filtrelenmemiş manyetik ölçüme güvenmek yerine uygun akıllı telefon yönelim bilgisini kullanmalıdır.)*

The heading output must be expressed in a consistent world-referenced coordinate system. *(Yön çıktısı tutarlı bir dünya referanslı koordinat sisteminde ifade edilmelidir.)*

---

## 4.10 Pedestrian Dead Reckoning (Yaya Ölü Hesaplama)

NAVGUARD must implement a baseline Pedestrian Dead Reckoning system. *(NAVGUARD temel bir Yaya Ölü Hesaplama sistemi geliştirmelidir.)*

The PDR system must update relative position using detected steps, estimated step length, and heading. *(PDR sistemi tespit edilen adımları, tahmini adım uzunluğunu ve yönü kullanarak göreli konumu güncellemelidir.)*

The system must convert local pedestrian displacement into a representation that can be related to the initial GNSS geographic position. *(Sistem yerel yaya yer değiştirmesini başlangıç GNSS coğrafi konumuyla ilişkilendirilebilecek bir gösterime dönüştürmelidir.)*

---

## 4.11 Coordinate Transformation (Koordinat Dönüşümü)

NAVGUARD must define and use consistent coordinate frames for sensor, local navigation, and global geographic calculations. *(NAVGUARD sensör, yerel navigasyon ve global coğrafi hesaplamalar için tutarlı koordinat sistemleri tanımlamalı ve kullanmalıdır.)*

A local coordinate representation such as East-North-Up or an equivalent local navigation frame must be used for displacement calculations. *(Yer değiştirme hesaplamaları için East-North-Up veya eşdeğer bir yerel navigasyon koordinat sistemi kullanılmalıdır.)*

The application must be able to convert estimated local displacement into geographic latitude and longitude for visualization and evaluation. *(Uygulama görselleştirme ve değerlendirme için tahmini yerel yer değiştirmeyi coğrafi enlem ve boylama dönüştürebilmelidir.)*

---

## 4.12 Estimated Route Visualization (Tahmini Rota Görselleştirmesi)

The mobile application must display the estimated NAVGUARD route. *(Mobil uygulama tahmini NAVGUARD rotasını göstermelidir.)*

The current estimated position must update during an active navigation session. *(Aktif bir navigasyon oturumu sırasında mevcut tahmini konum güncellenmelidir.)*

The user must be able to distinguish between estimated navigation information and GNSS reference information during evaluation. *(Kullanıcı değerlendirme sırasında tahmini navigasyon bilgisi ile GNSS referans bilgisini birbirinden ayırt edebilmelidir.)*

---

## 4.13 Motion Classification AI (Hareket Sınıflandırma Yapay Zekâsı)

NAVGUARD must include at least one trained machine learning or deep learning model that processes smartphone motion sensor data. *(NAVGUARD akıllı telefon hareket sensörü verilerini işleyen en az bir eğitilmiş makine öğrenmesi veya derin öğrenme modeli içermelidir.)*

The primary planned AI task is motion classification. *(Planlanan birincil yapay zekâ görevi hareket sınıflandırmasıdır.)*

The minimum target motion classes are stationary, walking, running, and turning. *(Minimum hedef hareket sınıfları sabit durma, yürüme, koşma ve dönmedir.)*

The final model must be selected after comparison with at least one simpler baseline model. *(Nihai model en az bir daha basit temel modelle karşılaştırıldıktan sonra seçilmelidir.)*

The selected model must be capable of running on the target Android device. *(Seçilen model hedef Android cihaz üzerinde çalışabilir olmalıdır.)*

---

## 4.14 On-Device AI Inference (Cihaz Üzerinde Yapay Zekâ Çıkarımı)

Core artificial intelligence inference must operate locally on the Android device during navigation. *(Temel yapay zekâ çıkarımı navigasyon sırasında Android cihaz üzerinde yerel olarak çalışmalıdır.)*

The application must not require a remote AI API for motion classification during an active session. *(Uygulama aktif bir oturum sırasında hareket sınıflandırması için uzak bir yapay zekâ API’sine ihtiyaç duymamalıdır.)*

The AI model must be optimized to provide practical inference latency on the Xiaomi Redmi Note 9 Pro. *(Yapay zekâ modeli Xiaomi Redmi Note 9 Pro üzerinde uygulanabilir çıkarım gecikmesi sağlayacak şekilde optimize edilmelidir.)*

---

## 4.15 Dataset Collection (Veri Seti Toplama)

NAVGUARD must provide a method for collecting labelled motion sensor data from the target test device. *(NAVGUARD hedef test cihazından etiketli hareket sensörü verisi toplamak için bir yöntem sağlamalıdır.)*

The collected dataset must contain samples suitable for training and evaluating the motion classification model. *(Toplanan veri seti hareket sınıflandırma modelini eğitmek ve değerlendirmek için uygun örnekler içermelidir.)*

Training, validation, and test data must be separated in a way that reduces the risk of data leakage. *(Eğitim, doğrulama ve test verileri veri sızıntısı riskini azaltacak şekilde ayrılmalıdır.)*

---

## 4.16 Experimental Evaluation (Deneysel Değerlendirme)

NAVGUARD must be evaluated using controlled walking sessions. *(NAVGUARD kontrollü yürüyüş oturumları kullanılarak değerlendirilmelidir.)*

At least one baseline navigation configuration and the final NAVGUARD configuration must be compared. *(En az bir temel navigasyon yapılandırması ile nihai NAVGUARD yapılandırması karşılaştırılmalıdır.)*

Estimated trajectories must be compared with reference trajectories. *(Tahmini rotalar referans rotalarla karşılaştırılmalıdır.)*

Navigation error must be represented using quantitative metrics rather than visual inspection alone. *(Navigasyon hatası yalnızca görsel inceleme yerine nicel metrikler kullanılarak gösterilmelidir.)*

---

## 4.17 Core Navigation Metrics (Temel Navigasyon Metrikleri)

The project must calculate final position error. *(Proje nihai konum hatasını hesaplamalıdır.)*

The project must calculate at least one average trajectory error metric. *(Proje en az bir ortalama rota hata metriğini hesaplamalıdır.)*

The project must calculate a drift-related metric such as error per minute or error relative to travelled distance. *(Proje dakika başına hata veya kat edilen mesafeye göre hata gibi sürüklenmeyle ilişkili bir metrik hesaplamalıdır.)*

The project must preserve sufficient test data to reproduce these calculations. *(Proje bu hesaplamaları yeniden üretmek için yeterli test verisini saklamalıdır.)*

---

## 4.18 Session Management (Oturum Yönetimi)

The user must be able to create a new navigation or experiment session. *(Kullanıcı yeni bir navigasyon veya deney oturumu oluşturabilmelidir.)*

The user must be able to end and save the active session. *(Kullanıcı aktif oturumu sonlandırabilmeli ve kaydedebilmelidir.)*

Saved sessions must include the data required to perform later evaluation. *(Kaydedilen oturumlar daha sonraki değerlendirmeyi gerçekleştirmek için gerekli verileri içermelidir.)*

---

## 4.19 Basic System Status Interface (Temel Sistem Durum Arayüzü)

The application must provide visibility into the current navigation mode. *(Uygulama mevcut navigasyon modunu görünür şekilde göstermelidir.)*

The application must indicate whether GNSS input is active or excluded from the estimator. *(Uygulama GNSS girdisinin aktif olup olmadığını veya tahmin motorundan çıkarılıp çıkarılmadığını göstermelidir.)*

The application must display the current motion classification result when the AI model is active. *(Uygulama yapay zekâ modeli aktif olduğunda mevcut hareket sınıflandırma sonucunu göstermelidir.)*

The application must provide basic visibility into sensor availability or system readiness. *(Uygulama sensör kullanılabilirliği veya sistem hazır olma durumu hakkında temel görünürlük sağlamalıdır.)*

---

# 5. SHOULD — Advanced Project Scope (SHOULD — Gelişmiş Proje Kapsamı)

## 5.1 ARCore Visual-Inertial Tracking (ARCore Görsel-Ataletsel Takip)

NAVGUARD should integrate ARCore as an additional source of relative movement information. *(NAVGUARD ARCore’u ek bir göreli hareket bilgisi kaynağı olarak entegre etmelidir.)*

ARCore pose information should be aligned with the local NAVGUARD coordinate frame. *(ARCore poz bilgisi NAVGUARD’ın yerel koordinat sistemiyle hizalanmalıdır.)*

The application should monitor ARCore tracking state and should not assume that visual tracking is always available. *(Uygulama ARCore takip durumunu izlemeli ve görsel takibin her zaman kullanılabilir olduğunu varsaymamalıdır.)*

---

## 5.2 Sensor Fusion (Sensör Füzyonu)

NAVGUARD should combine multiple navigation information sources rather than using PDR alone in the final advanced configuration. *(NAVGUARD nihai gelişmiş yapılandırmada yalnızca PDR kullanmak yerine birden fazla navigasyon bilgi kaynağını birleştirmelidir.)*

The fusion mechanism should combine suitable PDR, heading, and ARCore measurements. *(Füzyon mekanizması uygun PDR, yön ve ARCore ölçümlerini birleştirmelidir.)*

The final fusion architecture should remain modular so that individual measurement sources can be enabled or disabled for experiments. *(Nihai füzyon mimarisi, bireysel ölçüm kaynaklarının deneyler için etkinleştirilip devre dışı bırakılabilmesi amacıyla modüler kalmalıdır.)*

---

## 5.3 Extended Kalman Filter (Genişletilmiş Kalman Filtresi)

An Extended Kalman Filter should be evaluated as the primary advanced state-estimation mechanism. *(Genişletilmiş Kalman Filtresi birincil gelişmiş durum tahmin mekanizması olarak değerlendirilmelidir.)*

The EKF state definition should remain limited to variables that can be reliably estimated within the available project duration. *(EKF durum tanımı mevcut proje süresi içerisinde güvenilir şekilde tahmin edilebilecek değişkenlerle sınırlı tutulmalıdır.)*

The EKF must not be made unnecessarily complex if a simpler fusion method produces sufficient performance. *(Daha basit bir füzyon yöntemi yeterli performans üretiyorsa EKF gereksiz yere karmaşıklaştırılmamalıdır.)*

---

## 5.4 Machine-Learning-Based Step Length Estimation (Makine Öğrenmesi Tabanlı Adım Uzunluğu Tahmini)

NAVGUARD should investigate a regression model for dynamic step length estimation. *(NAVGUARD dinamik adım uzunluğu tahmini için bir regresyon modelini araştırmalıdır.)*

The machine learning model should be compared against the deterministic baseline. *(Makine öğrenmesi modeli deterministik temel yöntemle karşılaştırılmalıdır.)*

The model should only remain in the final navigation configuration if it provides measurable benefit. *(Model yalnızca ölçülebilir fayda sağlarsa nihai navigasyon yapılandırmasında kalmalıdır.)*

---

## 5.5 Sensor Confidence Layer (Sensör Güven Katmanı)

NAVGUARD should estimate a quality or confidence indicator for important navigation sources. *(NAVGUARD önemli navigasyon kaynakları için bir kalite veya güven göstergesi tahmin etmelidir.)*

At minimum, the system should consider GNSS quality, ARCore tracking state, and magnetometer consistency when sufficient information is available. *(En azından yeterli bilgi mevcut olduğunda sistem GNSS kalitesini, ARCore takip durumunu ve manyetometre tutarlılığını dikkate almalıdır.)*

Sensor confidence should be used to reduce the influence of clearly degraded measurements when technically feasible. *(Teknik olarak mümkün olduğunda sensör güveni açık şekilde bozulmuş ölçümlerin etkisini azaltmak için kullanılmalıdır.)*

---

## 5.6 Position Uncertainty Indicator (Konum Belirsizliği Göstergesi)

NAVGUARD should display an estimated confidence or uncertainty value together with the position estimate. *(NAVGUARD konum tahminiyle birlikte tahmini bir güven veya belirsizlik değeri göstermelidir.)*

The uncertainty indicator should increase when navigation evidence becomes weaker or when dead reckoning continues for a prolonged period without absolute correction. *(Navigasyon kanıtı zayıfladığında veya mutlak düzeltme olmadan ölü hesaplama uzun süre devam ettiğinde belirsizlik göstergesi artmalıdır.)*

The indicator does not need to represent certified statistical positioning accuracy in the initial prototype. *(İlk prototipte göstergenin sertifikalı istatistiksel konum doğruluğunu temsil etmesi gerekmez.)*

---

## 5.7 Automatic GNSS Quality Monitoring (Otomatik GNSS Kalite İzleme)

The application should monitor GNSS accuracy and availability during normal navigation. *(Uygulama normal navigasyon sırasında GNSS doğruluğunu ve kullanılabilirliğini izlemelidir.)*

The system should distinguish between good, degraded, and unavailable GNSS conditions using documented thresholds. *(Sistem dokümante edilmiş eşikler kullanarak iyi, bozulmuş ve kullanılamaz GNSS koşullarını ayırt etmelidir.)*

Automatic transition into GNSS-denied estimation may be implemented if it can be tested reliably. *(Güvenilir şekilde test edilebilirse GNSS kesintili tahmine otomatik geçiş uygulanabilir.)*

---

## 5.8 Relocalization After GNSS Recovery (GNSS Geri Geldikten Sonra Yeniden Konumlandırma)

NAVGUARD should detect when reliable GNSS information becomes available again. *(NAVGUARD güvenilir GNSS bilgisi tekrar kullanılabilir hale geldiğinde bunu tespit etmelidir.)*

The application should calculate the difference between the current estimated position and the recovered GNSS position. *(Uygulama mevcut tahmini konum ile geri kazanılan GNSS konumu arasındaki farkı hesaplamalıdır.)*

The system should support a controlled transition back to GNSS-supported navigation. *(Sistem GNSS destekli navigasyona kontrollü bir geçişi desteklemelidir.)*

---

## 5.9 Comparison Dashboard (Karşılaştırma Paneli)

The application should provide a post-session comparison between selected navigation configurations. *(Uygulama seçilen navigasyon yapılandırmaları arasında oturum sonrası karşılaştırma sağlamalıdır.)*

The comparison should show both route visualization and quantitative error metrics. *(Karşılaştırma hem rota görselleştirmesini hem de nicel hata metriklerini göstermelidir.)*

---

## 5.10 On-Device Performance Measurement (Cihaz Üzerinde Performans Ölçümü)

NAVGUARD should record AI inference latency on the target device. *(NAVGUARD hedef cihaz üzerinde yapay zekâ çıkarım gecikmesini kaydetmelidir.)*

The application should record or estimate resource usage relevant to final system evaluation. *(Uygulama nihai sistem değerlendirmesiyle ilgili kaynak kullanımını kaydetmeli veya tahmin etmelidir.)*

Performance measurements should not interfere significantly with navigation timing. *(Performans ölçümleri navigasyon zamanlamasına önemli ölçüde müdahale etmemelidir.)*

---

# 6. COULD — Optional Project Scope (COULD — İsteğe Bağlı Proje Kapsamı)

## 6.1 Raw GNSS Diagnostics (Ham GNSS Tanılama)

NAVGUARD could record advanced GNSS diagnostic information if supported reliably by the target device and development schedule. *(NAVGUARD hedef cihaz ve geliştirme takvimi tarafından güvenilir şekilde desteklenirse gelişmiş GNSS tanılama bilgilerini kaydedebilir.)*

This feature is not required for the primary GNSS-denied navigation objective. *(Bu özellik temel GNSS kesintili navigasyon hedefi için gerekli değildir.)*

---

## 6.2 Automatic Magnetic Disturbance Detection (Otomatik Manyetik Bozulma Tespiti)

NAVGUARD could detect magnetometer disturbances using cross-sensor consistency rules. *(NAVGUARD sensörler arası tutarlılık kurallarını kullanarak manyetometre bozulmalarını tespit edebilir.)*

A detected disturbance could temporarily reduce magnetometer influence in heading estimation. *(Tespit edilen bir bozulma yön tahmininde manyetometrenin etkisini geçici olarak azaltabilir.)*

---

## 6.3 Adaptive Sensor Weighting (Uyarlanabilir Sensör Ağırlıklandırma)

The fusion system could dynamically adjust source weights according to sensor quality indicators. *(Füzyon sistemi sensör kalite göstergelerine göre kaynak ağırlıklarını dinamik olarak ayarlayabilir.)*

This feature will only be attempted after the fixed fusion baseline is validated. *(Bu özellik yalnızca sabit füzyon temel sistemi doğrulandıktan sonra denenmelidir.)*

---

## 6.4 Additional Motion Classes (Ek Hareket Sınıfları)

The motion classifier could be extended beyond the initial four classes. *(Hareket sınıflandırma modeli başlangıçtaki dört sınıfın ötesine genişletilebilir.)*

Optional classes could include slow walking, fast walking, stairs, or device handling transitions. *(İsteğe bağlı sınıflar yavaş yürüme, hızlı yürüme, merdiven veya cihaz tutuş geçişlerini içerebilir.)*

Additional classes must not be added if they reduce dataset quality or delay the core system. *(Ek sınıflar veri seti kalitesini azaltacak veya temel sistemi geciktirecekse eklenmemelidir.)*

---

## 6.5 Offline Map Caching (Çevrimdışı Harita Önbellekleme)

The application could provide locally cached map data for selected experiment areas. *(Uygulama seçilen deney alanları için yerel olarak önbelleğe alınmış harita verisi sağlayabilir.)*

Offline mapping is not required for the position estimation engine itself. *(Çevrimdışı haritalama konum tahmin motorunun kendisi için gerekli değildir.)*

---

## 6.6 Session Export (Oturum Dışa Aktarma)

Recorded navigation sessions could be exported as CSV, JSON, or another analysis-friendly format. *(Kaydedilen navigasyon oturumları CSV, JSON veya analize uygun başka bir formatta dışa aktarılabilir.)*

Export functionality would support offline Python analysis and report generation. *(Dışa aktarma işlevi çevrimdışı Python analizini ve rapor oluşturmayı destekler.)*

---

## 6.7 Developer Diagnostic Mode (Geliştirici Tanılama Modu)

NAVGUARD could contain a hidden or dedicated diagnostic interface displaying raw and processed sensor values. *(NAVGUARD ham ve işlenmiş sensör değerlerini gösteren gizli veya özel bir tanılama arayüzü içerebilir.)*

This interface would primarily support debugging and experimentation rather than final user navigation. *(Bu arayüz nihai kullanıcı navigasyonundan ziyade temel olarak hata ayıklama ve deneyleri destekler.)*

---

## 6.8 Energy-Aware Processing (Enerji Farkındalıklı İşleme)

The system could reduce selected processing rates when device battery level becomes low. *(Sistem cihaz batarya seviyesi düştüğünde seçilen işlem hızlarını azaltabilir.)*

This feature is optional and must not compromise the reproducibility of planned experiments. *(Bu özellik isteğe bağlıdır ve planlanan deneylerin tekrarlanabilirliğini bozmamalıdır.)*

---

# 7. OUT OF SCOPE — Explicitly Excluded Features (OUT OF SCOPE — Açıkça Hariç Tutulan Özellikler)

## 7.1 iOS Support (iOS Desteği)

NAVGUARD will not be developed for iOS during the project period. *(NAVGUARD proje süresi içerisinde iOS için geliştirilmeyecektir.)*

No iPhone-specific sensor or ARKit implementation will be created. *(iPhone’a özgü sensör veya ARKit uygulaması geliştirilmeyecektir.)*

---

## 7.2 Web or Desktop Navigation Application (Web veya Masaüstü Navigasyon Uygulaması)

A production web or desktop version of NAVGUARD is outside the project scope. *(NAVGUARD’ın üretim seviyesinde web veya masaüstü sürümü proje kapsamı dışındadır.)*

Python desktop tools may still be used internally for machine learning experiments and data analysis. *(Python masaüstü araçları makine öğrenmesi deneyleri ve veri analizi için dahili olarak yine kullanılabilir.)*

---

## 7.3 Vehicle Navigation (Araç Navigasyonu)

The initial NAVGUARD prototype will not support automotive navigation. *(İlk NAVGUARD prototipi araç navigasyonunu desteklemeyecektir.)*

Vehicle dynamics, road constraints, wheel odometry, and automotive sensors are outside the defined project scope. *(Araç dinamikleri, yol kısıtları, tekerlek odometrisi ve otomotiv sensörleri tanımlanan proje kapsamı dışındadır.)*

---

## 7.4 UAV or Aircraft Navigation (İHA veya Hava Aracı Navigasyonu)

NAVGUARD will not be developed as a UAV, drone, aircraft, missile, or weapon navigation system. *(NAVGUARD İHA, drone, hava aracı, füze veya silah navigasyon sistemi olarak geliştirilmeyecektir.)*

The project will remain focused on pedestrian mobile navigation research. *(Proje yaya mobil navigasyon araştırmasına odaklı kalacaktır.)*

---

## 7.5 Real GNSS Jamming or Interference Generation (Gerçek GNSS Karıştırma veya Parazit Üretimi)

The project will not generate, transmit, or reproduce real GNSS jamming signals. *(Proje gerçek GNSS karıştırma sinyalleri üretmeyecek, iletmeyecek veya yeniden oluşturmayacaktır.)*

The project will not include hardware intended to interfere with satellite navigation systems. *(Proje uydu navigasyon sistemlerine müdahale etmek amacıyla tasarlanmış donanım içermeyecektir.)*

GNSS loss will be simulated entirely at the software estimation layer. *(GNSS kaybı tamamen yazılım tahmin katmanında simüle edilecektir.)*

---

## 7.6 GNSS Spoofing Detection or Generation (GNSS Aldatma Tespiti veya Üretimi)

Advanced GNSS spoofing generation is outside the project scope. *(Gelişmiş GNSS aldatma üretimi proje kapsamı dışındadır.)*

Dedicated spoofing detection research is also not required for the initial NAVGUARD prototype. *(Özel GNSS aldatma tespiti araştırması da ilk NAVGUARD prototipi için gerekli değildir.)*

GNSS quality monitoring may be implemented without attempting to classify specific attack mechanisms. *(Belirli saldırı mekanizmalarını sınıflandırmaya çalışmadan GNSS kalite izleme uygulanabilir.)*

---

## 7.7 Certified Inertial Navigation System (Sertifikalı Ataletsel Navigasyon Sistemi)

NAVGUARD will not attempt to achieve aviation-grade, military-grade, or certified inertial navigation accuracy. *(NAVGUARD havacılık seviyesi, askeri seviye veya sertifikalı ataletsel navigasyon doğruluğu elde etmeye çalışmayacaktır.)*

The smartphone sensors are not treated as replacements for high-grade inertial measurement units. *(Akıllı telefon sensörleri yüksek seviye ataletsel ölçüm birimlerinin yerine geçen sistemler olarak ele alınmayacaktır.)*

---

## 7.8 High-Precision Indoor Positioning Infrastructure (Yüksek Hassasiyetli İç Mekân Konumlandırma Altyapısı)

The project will not deploy Bluetooth beacons, UWB anchors, Wi-Fi RTT infrastructure, or dedicated indoor positioning hardware. *(Proje Bluetooth beacon’ları, UWB anchor’ları, Wi-Fi RTT altyapısı veya özel iç mekân konumlandırma donanımı kurmayacaktır.)*

Indoor tests may still be conducted using only the smartphone’s available sensors. *(İç mekân testleri yalnızca akıllı telefonda bulunan sensörler kullanılarak yine gerçekleştirilebilir.)*

---

## 7.9 External High-Grade IMU Hardware (Harici Yüksek Seviye IMU Donanımı)

Purchasing or integrating an external precision IMU is outside the initial project scope. *(Harici hassas bir IMU satın almak veya entegre etmek ilk proje kapsamı dışındadır.)*

The project must remain achievable using the existing smartphone hardware. *(Proje mevcut akıllı telefon donanımı kullanılarak gerçekleştirilebilir kalmalıdır.)*

---

## 7.10 Custom Visual-Inertial Odometry from Scratch (Sıfırdan Özel Görsel-Ataletsel Odometri)

The project will not implement a complete custom visual-inertial odometry framework from first principles. *(Proje temel prensiplerden başlayarak tamamen özel bir görsel-ataletsel odometri sistemi geliştirmeyecektir.)*

ARCore will be used as the primary visual-inertial movement source if visual tracking is included. *(Görsel takip dahil edilirse ARCore birincil görsel-ataletsel hareket kaynağı olarak kullanılacaktır.)*

This limitation is necessary to keep the project achievable within 24 business days. *(Bu sınırlama projenin 24 iş günü içerisinde gerçekleştirilebilir kalması için gereklidir.)*

---

## 7.11 Full SLAM Implementation (Tam SLAM Uygulaması)

A complete Simultaneous Localization and Mapping system is outside the initial NAVGUARD scope. *(Tam bir Eşzamanlı Konumlandırma ve Haritalama sistemi ilk NAVGUARD kapsamı dışındadır.)*

The project does not require building or maintaining a persistent three-dimensional map of the environment. *(Proje ortamın kalıcı üç boyutlu haritasını oluşturmayı veya sürdürmeyi gerektirmez.)*

---

## 7.12 Cloud-Based Navigation Backend (Bulut Tabanlı Navigasyon Backend’i)

A continuously connected cloud backend is not required for core navigation. *(Temel navigasyon için sürekli bağlı bir bulut backend’i gerekli değildir.)*

Core position estimation will not depend on Firebase, AWS, Azure, Google Cloud, or another remote compute service. *(Temel konum tahmini Firebase, AWS, Azure, Google Cloud veya başka bir uzak işlem hizmetine bağımlı olmayacaktır.)*

---

## 7.13 User Account System (Kullanıcı Hesap Sistemi)

User registration, authentication, profile management, and multi-user account infrastructure are outside the initial project scope. *(Kullanıcı kaydı, kimlik doğrulama, profil yönetimi ve çok kullanıcılı hesap altyapısı ilk proje kapsamı dışındadır.)*

The prototype is intended primarily for controlled technical evaluation. *(Prototip temel olarak kontrollü teknik değerlendirme için tasarlanmıştır.)*

---

## 7.14 Social or Communication Features (Sosyal veya İletişim Özellikleri)

Messaging, friend systems, social sharing, and user-to-user communication are outside the project scope. *(Mesajlaşma, arkadaş sistemleri, sosyal paylaşım ve kullanıcılar arası iletişim proje kapsamı dışındadır.)*

---

## 7.15 Commercial Production Deployment (Ticari Üretim Dağıtımı)

The 24-day project will not include commercial deployment, commercial support infrastructure, or production-scale user management. *(24 günlük proje ticari dağıtımı, ticari destek altyapısını veya üretim ölçeğinde kullanıcı yönetimini içermeyecektir.)*

The final result will remain a research proof-of-concept. *(Nihai sonuç bir araştırma kavram kanıtlama prototipi olarak kalacaktır.)*

---

## 7.16 Google Play Store Publication (Google Play Store Yayını)

Publishing NAVGUARD on the Google Play Store is not required for project completion. *(NAVGUARD’ın Google Play Store’da yayınlanması projenin tamamlanması için gerekli değildir.)*

An installable development or release APK is sufficient for the defined demonstration scope. *(Tanımlanan demo kapsamı için kurulabilir bir geliştirme veya release APK yeterlidir.)*

---

## 7.17 Full Multi-Device Generalization Study (Tam Çoklu Cihaz Genelleme Çalışması)

The initial project will not perform a large-scale study across multiple Android phone models. *(İlk proje birden fazla Android telefon modeli üzerinde geniş ölçekli bir çalışma gerçekleştirmeyecektir.)*

The Xiaomi Redmi Note 9 Pro will remain the primary reference platform. *(Xiaomi Redmi Note 9 Pro birincil referans platform olarak kalacaktır.)*

Cross-device generalization will be documented as future work. *(Cihazlar arası genelleme gelecekteki çalışma olarak dokümante edilecektir.)*

---

## 7.18 Continuous Background Navigation Service (Sürekli Arka Plan Navigasyon Servisi)

The initial prototype is not required to provide production-grade continuous background navigation while the application is closed. *(İlk prototip uygulama kapalıyken üretim seviyesinde sürekli arka plan navigasyonu sağlamak zorunda değildir.)*

The core experiment may require the NAVGUARD application to remain active in the foreground. *(Temel deney NAVGUARD uygulamasının ön planda aktif kalmasını gerektirebilir.)*

---

## 7.19 Barometric Floor Estimation (Barometrik Kat Tahmini)

Barometer-based vertical positioning is outside the mandatory and advanced scope for the Xiaomi Redmi Note 9 Pro baseline. *(Barometre tabanlı dikey konumlandırma Xiaomi Redmi Note 9 Pro temel referansı için zorunlu ve gelişmiş kapsamın dışındadır.)*

Vertical floor estimation will not be required for project completion. *(Dikey kat tahmini projenin tamamlanması için gerekli olmayacaktır.)*

---

# 8. Scope by System Component (Sistem Bileşenine Göre Kapsam)

| Component (Bileşen) | Scope Level (Kapsam Seviyesi) | Required Outcome (Gerekli Sonuç) |
| --- | --- | --- |
| Android Application (Android Uygulaması) | MUST | Functional application on Redmi Note 9 Pro *(Redmi Note 9 Pro üzerinde çalışan uygulama)* |
| Sensor Logger (Sensör Kaydedici) | MUST | Reliable timestamped sensor recording *(Güvenilir zaman damgalı sensör kaydı)* |
| GNSS Module (GNSS Modülü) | MUST | Initial position and ground truth *(Başlangıç konumu ve gerçek referans)* |
| GNSS-Denied Mode (GNSS Kesinti Modu) | MUST | GNSS excluded from estimator *(GNSS’in tahmin motorundan çıkarılması)* |
| Step Detection (Adım Tespiti) | MUST | Working pedestrian step detection *(Çalışan yaya adım tespiti)* |
| Baseline Step Length (Temel Adım Uzunluğu) | MUST | Deterministic distance estimate *(Deterministik mesafe tahmini)* |
| Heading Estimation (Yön Tahmini) | MUST | Stable heading input *(Kararlı yön girdisi)* |
| PDR | MUST | Baseline GNSS-denied trajectory *(Temel GNSS kesintili rota)* |
| Motion AI (Hareket Yapay Zekâsı) | MUST | On-device motion classification *(Cihaz üzerinde hareket sınıflandırması)* |
| Dataset Pipeline (Veri Seti Hattı) | MUST | Train, validation, and test datasets *(Eğitim, doğrulama ve test veri setleri)* |
| Evaluation Engine (Değerlendirme Motoru) | MUST | Quantitative trajectory errors *(Nicel rota hataları)* |
| ARCore | SHOULD | Relative visual-inertial movement *(Göreli görsel-ataletsel hareket)* |
| EKF / Sensor Fusion (EKF / Sensör Füzyonu) | SHOULD | Multi-source position estimate *(Çok kaynaklı konum tahmini)* |
| ML Step Length (ML Adım Uzunluğu) | SHOULD | Improved dynamic step length *(İyileştirilmiş dinamik adım uzunluğu)* |
| Sensor Confidence (Sensör Güveni) | SHOULD | Measurement quality awareness *(Ölçüm kalite farkındalığı)* |
| Uncertainty (Belirsizlik) | SHOULD | Position confidence indicator *(Konum güven göstergesi)* |
| Relocalization (Yeniden Konumlandırma) | SHOULD | Controlled GNSS recovery *(Kontrollü GNSS geri dönüşü)* |
| Offline Maps (Çevrimdışı Haritalar) | COULD | Local visualization support *(Yerel görselleştirme desteği)* |
| Advanced GNSS Diagnostics (Gelişmiş GNSS Tanılama) | COULD | Additional experiment data *(Ek deney verisi)* |
| Custom VIO / SLAM (Özel VIO / SLAM) | OUT OF SCOPE | Not implemented *(Uygulanmayacak)* |
| Vehicle / UAV Navigation (Araç / İHA Navigasyonu) | OUT OF SCOPE | Not implemented *(Uygulanmayacak)* |

---

# 9. Minimum Viable Technical Prototype (Minimum Uygulanabilir Teknik Prototip)

The minimum technically acceptable NAVGUARD prototype must be able to acquire an initial GNSS position. *(Minimum teknik olarak kabul edilebilir NAVGUARD prototipi başlangıç GNSS konumunu alabilmelidir.)*

It must then exclude GNSS position updates from the estimator and continue producing an estimated pedestrian trajectory. *(Daha sonra GNSS konum güncellemelerini tahmin motorundan çıkarmalı ve tahmini bir yaya rotası üretmeye devam etmelidir.)*

The trajectory must be generated using at least step detection, step length estimation, and heading estimation. *(Rota en azından adım tespiti, adım uzunluğu tahmini ve yön tahmini kullanılarak oluşturulmalıdır.)*

The system must contain a functioning on-device motion classification model. *(Sistem cihaz üzerinde çalışan bir hareket sınıflandırma modeli içermelidir.)*

The session must record GNSS ground truth independently for later comparison. *(Oturum daha sonraki karşılaştırma için GNSS gerçek referansını bağımsız olarak kaydetmelidir.)*

The application must calculate and display measurable navigation error after the experiment. *(Uygulama deneyden sonra ölçülebilir navigasyon hatasını hesaplamalı ve göstermelidir.)*

If these conditions are satisfied, the project will remain technically demonstrable even if selected advanced components are not completed. *(Bu koşullar sağlanırsa seçilmiş gelişmiş bileşenler tamamlanmasa bile proje teknik olarak gösterilebilir durumda kalacaktır.)*

---

# 10. Target Final Prototype (Hedef Nihai Prototip)

The preferred final version of NAVGUARD will contain all mandatory capabilities and the primary advanced components. *(NAVGUARD’ın tercih edilen nihai sürümü tüm zorunlu yetenekleri ve temel gelişmiş bileşenleri içerecektir.)*

The target final navigation configuration will combine PDR, improved heading estimation, ARCore relative movement, AI-based motion classification, dynamic step length estimation, and sensor fusion. *(Hedef nihai navigasyon yapılandırması PDR, geliştirilmiş yön tahmini, ARCore göreli hareket, yapay zekâ tabanlı hareket sınıflandırması, dinamik adım uzunluğu tahmini ve sensör füzyonunu birleştirecektir.)*

The target system will also expose position confidence or uncertainty information and provide post-session benchmark results. *(Hedef sistem ayrıca konum güveni veya belirsizlik bilgisi sunacak ve oturum sonrası benchmark sonuçları sağlayacaktır.)*

---

# 11. Scope Reduction Order (Kapsam Azaltma Sırası)

If development delays occur, optional features must be removed before mandatory components are reduced. *(Geliştirme gecikmeleri oluşursa zorunlu bileşenler azaltılmadan önce isteğe bağlı özellikler çıkarılmalıdır.)*

The first features to be removed will be cosmetic UI improvements and optional diagnostic tools. *(İlk çıkarılacak özellikler görsel UI iyileştirmeleri ve isteğe bağlı tanılama araçları olacaktır.)*

Advanced GNSS diagnostics and offline map enhancements will be removed next. *(Daha sonra gelişmiş GNSS tanılama ve çevrimdışı harita iyileştirmeleri çıkarılacaktır.)*

Adaptive sensor weighting and advanced confidence mechanisms may then be simplified. *(Daha sonra uyarlanabilir sensör ağırlıklandırma ve gelişmiş güven mekanizmaları basitleştirilebilir.)*

Machine-learning-based step length estimation may be replaced by the deterministic baseline if necessary. *(Gerekirse makine öğrenmesi tabanlı adım uzunluğu tahmini deterministik temel yöntemle değiştirilebilir.)*

ARCore integration may be excluded from the final build if it creates unacceptable schedule or stability risk. *(ARCore entegrasyonu kabul edilemez takvim veya kararlılık riski oluşturursa nihai sürümden çıkarılabilir.)*

The baseline PDR, GNSS-denied simulation, sensor logging, motion AI, route estimation, and experimental evaluation must remain protected. *(Temel PDR, GNSS kesinti simülasyonu, sensör kaydı, hareket yapay zekâsı, rota tahmini ve deneysel değerlendirme korunmalıdır.)*

---

# 12. Scope Expansion Rule (Kapsam Genişletme Kuralı)

No new feature should be added during development unless all currently scheduled mandatory tasks remain on track. *(Mevcut planlanmış zorunlu görevlerin tamamı takviminde ilerlemediği sürece geliştirme sırasında yeni özellik eklenmemelidir.)*

Any proposed new feature must be classified as MUST, SHOULD, COULD, or OUT OF SCOPE before implementation begins. *(Önerilen her yeni özellik geliştirme başlamadan önce MUST, SHOULD, COULD veya OUT OF SCOPE olarak sınıflandırılmalıdır.)*

A new feature must not be classified as MUST unless it is required to satisfy an existing project objective or acceptance criterion. *(Yeni bir özellik mevcut bir proje hedefini veya kabul kriterini karşılamak için gerekli değilse MUST olarak sınıflandırılmamalıdır.)*

All accepted scope changes must be recorded in the Technical Decisions and Change Log document. *(Kabul edilen tüm kapsam değişiklikleri Teknik Kararlar ve Değişiklik Günlüğü dokümanında kaydedilmelidir.)*

---

# 13. Technical Complexity Boundary (Teknik Karmaşıklık Sınırı)

NAVGUARD will prefer understandable and testable algorithms over unnecessarily complex techniques. *(NAVGUARD gereksiz derecede karmaşık teknikler yerine anlaşılabilir ve test edilebilir algoritmaları tercih edecektir.)*

A more complex algorithm will only replace a simpler one if experiments demonstrate meaningful benefit. *(Daha karmaşık bir algoritma yalnızca deneyler anlamlı fayda gösterirse daha basit olanın yerini alacaktır.)*

The project will not add neural networks to navigation components where deterministic algorithms are sufficient and easier to validate. *(Proje deterministik algoritmaların yeterli ve doğrulaması daha kolay olduğu navigasyon bileşenlerine sinir ağları eklemeyecektir.)*

Artificial intelligence will be used only where it has a clearly defined role and measurable output. *(Yapay zekâ yalnızca açıkça tanımlanmış bir role ve ölçülebilir çıktıya sahip olduğu noktalarda kullanılacaktır.)*

---

# 14. Platform Boundary (Platform Sınırı)

Android is the only supported runtime platform for the project. *(Android proje için desteklenen tek çalışma platformudur.)*

Flutter will be used for the primary mobile application layer. *(Flutter birincil mobil uygulama katmanı için kullanılacaktır.)*

Native Kotlin components may be used where Android-specific sensor, ARCore, or timing control requires lower-level access. *(Android’e özgü sensör, ARCore veya zamanlama kontrolünün daha düşük seviyeli erişim gerektirdiği yerlerde native Kotlin bileşenleri kullanılabilir.)*

Python will be used for offline machine learning development, dataset processing, experimentation, and analysis. *(Python çevrimdışı makine öğrenmesi geliştirmesi, veri seti işleme, deney ve analiz için kullanılacaktır.)*

Python is not required to run continuously during the final mobile demonstration. *(Python’un nihai mobil demo sırasında sürekli çalışması gerekmeyecektir.)*

---

# 15. Hardware Boundary (Donanım Sınırı)

The Xiaomi Redmi Note 9 Pro is the primary hardware reference. *(Xiaomi Redmi Note 9 Pro birincil donanım referansıdır.)*

The core prototype must not require additional purchased hardware. *(Temel prototip ek satın alınmış donanım gerektirmemelidir.)*

The smartphone’s internal GNSS, accelerometer, gyroscope, magnetometer, orientation capabilities, and camera will form the main sensor platform. *(Akıllı telefonun dahili GNSS, ivmeölçer, jiroskop, manyetometre, yönelim yetenekleri ve kamerası temel sensör platformunu oluşturacaktır.)*

External equipment may only be used as an optional reference or measurement aid if it is already available and does not become a project dependency. *(Harici ekipman yalnızca zaten mevcutsa ve proje bağımlılığı haline gelmiyorsa isteğe bağlı referans veya ölçüm yardımcısı olarak kullanılabilir.)*

---

# 16. Operational Boundary (Operasyonel Sınır)

The application will be evaluated using controlled pedestrian movement scenarios. *(Uygulama kontrollü yaya hareket senaryoları kullanılarak değerlendirilecektir.)*

The user is expected to carry the test smartphone during navigation experiments. *(Kullanıcının navigasyon deneyleri sırasında test akıllı telefonunu taşıması beklenmektedir.)*

The initial project does not guarantee identical performance for arbitrary phone carrying positions. *(İlk proje rastgele telefon taşıma konumlarında aynı performansı garanti etmez.)*

Selected device-carrying positions will be defined and documented in the Field Experiment Plan. *(Seçilen cihaz taşıma konumları Saha Deney Planında tanımlanacak ve dokümante edilecektir.)*

Testing will prioritize repeatable walking scenarios over uncontrolled real-world navigation. *(Testler kontrolsüz gerçek dünya navigasyonu yerine tekrarlanabilir yürüyüş senaryolarına öncelik verecektir.)*

---

# 17. Experimental Boundary (Deneysel Sınır)

The project will use controlled GNSS-denied simulation rather than real RF signal denial. *(Proje gerçek RF sinyal engelleme yerine kontrollü GNSS kesinti simülasyonu kullanacaktır.)*

Reference GNSS data may be recorded while the NAVGUARD estimator operates without access to those measurements. *(NAVGUARD tahmin motoru bu ölçümlere erişmeden çalışırken referans GNSS verileri kaydedilebilir.)*

Experimental conclusions will be limited to the tested device, routes, motion conditions, and configurations. *(Deneysel sonuçlar test edilen cihaz, rotalar, hareket koşulları ve yapılandırmalarla sınırlı olacaktır.)*

The project will not generalize results to all smartphones or all GNSS-denied environments without supporting evidence. *(Proje destekleyici kanıt olmadan sonuçları tüm akıllı telefonlara veya tüm GNSS kesintili ortamlara genellemeyecektir.)*

---

# 18. Artificial Intelligence Boundary (Yapay Zekâ Sınırı)

Artificial intelligence will not directly generate latitude and longitude coordinates in the initial project. *(Yapay zekâ ilk projede doğrudan enlem ve boylam koordinatları üretmeyecektir.)*

The main AI responsibility will be interpreting motion sensor patterns. *(Temel yapay zekâ sorumluluğu hareket sensörü örüntülerini yorumlamak olacaktır.)*

Motion classification is the mandatory AI task. *(Hareket sınıflandırması zorunlu yapay zekâ görevidir.)*

Step length regression is an advanced AI task and may be removed if it does not provide sufficient benefit. *(Adım uzunluğu regresyonu gelişmiş bir yapay zekâ görevidir ve yeterli fayda sağlamazsa çıkarılabilir.)*

Artificial intelligence will not replace the core state-estimation and coordinate transformation algorithms. *(Yapay zekâ temel durum tahmini ve koordinat dönüşüm algoritmalarının yerini almayacaktır.)*

---

# 19. Data Boundary (Veri Sınırı)

The primary dataset will consist of sensor measurements collected from the project’s own test device. *(Birincil veri seti projenin kendi test cihazından toplanan sensör ölçümlerinden oluşacaktır.)*

The project will not require access to confidential institutional data. *(Proje gizli kurumsal verilere erişim gerektirmeyecektir.)*

The project will not require personal data from external participants for the initial prototype. *(Proje ilk prototip için harici katılımcılardan kişisel veri gerektirmeyecektir.)*

If additional participants are later introduced, data collection requirements must be reviewed before their data is recorded. *(Daha sonra ek katılımcılar dahil edilirse verileri kaydedilmeden önce veri toplama gereksinimleri gözden geçirilmelidir.)*

---

# 20. User Interface Boundary (Kullanıcı Arayüzü Sınırı)

The user interface must support the technical demonstration and experimentation workflow. *(Kullanıcı arayüzü teknik demo ve deney iş akışını desteklemelidir.)*

The interface does not need commercial-grade animation, branding, onboarding, or visual polish. *(Arayüz ticari seviyede animasyon, markalama, onboarding veya görsel kalite gerektirmez.)*

Functional clarity has higher priority than decorative design. *(Fonksiyonel açıklık dekoratif tasarımdan daha yüksek önceliğe sahiptir.)*

The final interface should clearly separate normal navigation, GNSS-denied operation, sensor status, and experiment results. *(Nihai arayüz normal navigasyonu, GNSS kesintili çalışmayı, sensör durumunu ve deney sonuçlarını açıkça ayırmalıdır.)*

---

# 21. Documentation Boundary (Dokümantasyon Sınırı)

All major system components must have corresponding design documentation before or during implementation. *(Tüm önemli sistem bileşenlerinin geliştirmeden önce veya geliştirme sırasında karşılık gelen tasarım dokümantasyonu bulunmalıdır.)*

The documentation will describe intended behavior, not only the final code implementation. *(Dokümantasyon yalnızca nihai kod uygulamasını değil amaçlanan davranışı da açıklayacaktır.)*

Changes discovered during implementation must be reflected in the relevant documentation. *(Geliştirme sırasında ortaya çıkan değişiklikler ilgili dokümantasyona yansıtılmalıdır.)*

Documentation completeness is part of the project completion criteria. *(Dokümantasyon bütünlüğü proje tamamlanma kriterlerinin bir parçasıdır.)*

---

# 22. Final Scope Protection Rule (Nihai Kapsam Koruma Kuralı)

The project must always preserve a complete end-to-end path from sensor input to measurable GNSS-denied navigation output. *(Proje her zaman sensör girdisinden ölçülebilir GNSS kesintili navigasyon çıktısına kadar eksiksiz bir uçtan uca hattı korumalıdır.)*

A partially implemented advanced algorithm must never replace a stable baseline unless it has been validated experimentally. *(Kısmen uygulanmış gelişmiş bir algoritma deneysel olarak doğrulanmadığı sürece kararlı bir temel sistemin yerini almamalıdır.)*

If schedule pressure occurs, the system will become simpler rather than incomplete. *(Takvim baskısı oluşursa sistem eksik hale gelmek yerine daha basit hale getirilecektir.)*

The mandatory NAVGUARD baseline will therefore remain the protected core of the project throughout development. *(Bu nedenle zorunlu NAVGUARD temel sistemi geliştirme boyunca projenin korunan çekirdeği olarak kalacaktır.)*

---

# 23. Scope Completion Checklist (Kapsam Tamamlanma Kontrol Listesi)

The following conditions must be satisfied before the core scope is considered complete. *(Temel kapsam tamamlanmış kabul edilmeden önce aşağıdaki koşullar sağlanmalıdır.)*

- **Android prototype runs on the Xiaomi Redmi Note 9 Pro.** *(Android prototipi Xiaomi Redmi Note 9 Pro üzerinde çalışır.)*
- **Required smartphone sensors are validated and logged.** *(Gerekli akıllı telefon sensörleri doğrulanır ve kaydedilir.)*
- **A valid initial GNSS anchor can be acquired.** *(Geçerli bir başlangıç GNSS referansı elde edilebilir.)*
- **GNSS-denied mode prevents GNSS leakage into the estimator.** *(GNSS kesinti modu GNSS verisinin tahmin motoruna sızmasını engeller.)*
- **Step detection operates during pedestrian movement.** *(Adım tespiti yaya hareketi sırasında çalışır.)*
- **Heading estimation produces a usable directional estimate.** *(Yön tahmini kullanılabilir bir yön tahmini üretir.)*
- **Baseline PDR generates an estimated trajectory.** *(Temel PDR tahmini bir rota üretir.)*
- **Motion classification AI runs on the mobile device.** *(Hareket sınıflandırma yapay zekâsı mobil cihaz üzerinde çalışır.)*
- **Experiment sessions are recorded.** *(Deney oturumları kaydedilir.)*
- **GNSS ground truth and estimated trajectory can be compared.** *(GNSS gerçek referansı ve tahmini rota karşılaştırılabilir.)*
- **At least one quantitative navigation error metric is produced.** *(En az bir nicel navigasyon hata metriği üretilir.)*
- **The final application can be demonstrated without external navigation hardware.** *(Nihai uygulama harici navigasyon donanımı olmadan gösterilebilir.)*

---

# 24. Scope Approval Statement (Kapsam Onay Bildirimi)

This document defines the approved baseline scope for the NAVGUARD project before implementation begins. *(Bu doküman, geliştirme başlamadan önce NAVGUARD projesi için onaylanmış temel kapsamı tanımlar.)*

Development tasks must be planned according to the MUST, SHOULD, COULD, and OUT OF SCOPE priorities defined above. *(Geliştirme görevleri yukarıda tanımlanan MUST, SHOULD, COULD ve OUT OF SCOPE önceliklerine göre planlanmalıdır.)*

The success of the project will be judged primarily against the protected mandatory scope rather than the total number of implemented optional features. *(Projenin başarısı temel olarak uygulanan isteğe bağlı özelliklerin toplam sayısına değil korunan zorunlu kapsama göre değerlendirilecektir.)*

---

# 25. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Completed *(Doküman Durumu: Tamamlandı)*

**Scope Baseline:** Defined *(Kapsam Temel Referansı: Tanımlandı)*

**Mandatory Scope:** Protected *(Zorunlu Kapsam: Koruma Altında)*

**Target Platform:** Android Only *(Hedef Platform: Yalnızca Android)*

**Primary Test Device:** Xiaomi Redmi Note 9 Pro *(Birincil Test Cihazı: Xiaomi Redmi Note 9 Pro)*

**Development Duration:** 24 Business Days *(Geliştirme Süresi: 24 İş Günü)*

**Next Documentation Item:** 04 — Research Questions & Success Criteria *(Sonraki Dokümantasyon Öğesi: 04 — Araştırma Soruları ve Başarı Kriterleri)*