# 07 — Software Requirements Specification — SRS (Yazılım Gereksinimleri Şartnamesi — SRS)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the functional, non-functional, platform, hardware, data, artificial intelligence, navigation, testing, security, and operational requirements of the NAVGUARD system. *(Bu doküman, NAVGUARD sisteminin fonksiyonel, fonksiyonel olmayan, platform, donanım, veri, yapay zekâ, navigasyon, test, güvenlik ve operasyonel gereksinimlerini tanımlar.)*

This Software Requirements Specification will serve as the primary contract between the project design, implementation, testing, and final acceptance phases. *(Bu Yazılım Gereksinimleri Şartnamesi, proje tasarımı, geliştirme, test ve nihai kabul aşamaları arasındaki temel sözleşme olarak hizmet edecektir.)*

Every mandatory requirement defined in this document must be traceable to an implementation component and one or more verification activities. *(Bu dokümanda tanımlanan her zorunlu gereksinim bir uygulama bileşenine ve bir veya daha fazla doğrulama faaliyetine izlenebilir olmalıdır.)*

---

# 2. Requirement Terminology (Gereksinim Terminolojisi)

The word **shall** indicates a mandatory requirement that must be satisfied for the corresponding project level. *(**Shall** kelimesi, ilgili proje seviyesi için karşılanması zorunlu bir gereksinimi ifade eder.)*

The word **should** indicates a recommended requirement that is expected to be implemented unless a documented technical reason prevents it. *(**Should** kelimesi, dokümante edilmiş teknik bir neden engellemediği sürece uygulanması beklenen önerilen bir gereksinimi ifade eder.)*

The word **may** indicates an optional capability or implementation choice. *(**May** kelimesi, isteğe bağlı bir yeteneği veya uygulama tercihini ifade eder.)*

Requirements marked as **MUST** belong to the minimum accepted project scope. *(**MUST** olarak işaretlenen gereksinimler minimum kabul edilen proje kapsamına aittir.)*

Requirements marked as **TARGET** belong to the intended full NAVGUARD configuration. *(**TARGET** olarak işaretlenen gereksinimler planlanan tam NAVGUARD yapılandırmasına aittir.)*

Requirements marked as **OPTIONAL** may be implemented if time, device capability, and experimental value justify them. *(**OPTIONAL** olarak işaretlenen gereksinimler zaman, cihaz yeteneği ve deneysel değer tarafından gerekçelendirilirse uygulanabilir.)*

---

# 3. Requirement Identification Scheme (Gereksinim Kimliklendirme Şeması)

Functional requirements will use the prefix **FR**. *(Fonksiyonel gereksinimler **FR** önekini kullanacaktır.)*

Non-functional requirements will use the prefix **NFR**. *(Fonksiyonel olmayan gereksinimler **NFR** önekini kullanacaktır.)*

Artificial intelligence requirements will use the prefix **AI**. *(Yapay zekâ gereksinimleri **AI** önekini kullanacaktır.)*

Navigation requirements will use the prefix **NAV**. *(Navigasyon gereksinimleri **NAV** önekini kullanacaktır.)*

Sensor requirements will use the prefix **SEN**. *(Sensör gereksinimleri **SEN** önekini kullanacaktır.)*

Data requirements will use the prefix **DATA**. *(Veri gereksinimleri **DATA** önekini kullanacaktır.)*

ARCore requirements will use the prefix **AR**. *(ARCore gereksinimleri **AR** önekini kullanacaktır.)*

Security and privacy requirements will use the prefix **SEC**. *(Güvenlik ve gizlilik gereksinimleri **SEC** önekini kullanacaktır.)*

Testing and experimental requirements will use the prefix **TEST**. *(Test ve deneysel gereksinimler **TEST** önekini kullanacaktır.)*

Performance requirements will use the prefix **PERF**. *(Performans gereksinimleri **PERF** önekini kullanacaktır.)*

---

# 4. System Overview (Sistem Genel Bakışı)

NAVGUARD shall be an Android-based mobile research application for short-term pedestrian position estimation during simulated GNSS outages. *(NAVGUARD, simüle edilmiş GNSS kesintileri sırasında kısa süreli yaya konum tahmini için Android tabanlı bir mobil araştırma uygulaması olacaktır.)*

The system shall use sensors available on the target smartphone to estimate pedestrian movement after GNSS measurements are removed from the navigation estimator. *(Sistem, GNSS ölçümleri navigasyon tahmin motorundan çıkarıldıktan sonra yaya hareketini tahmin etmek için hedef akıllı telefonda mevcut sensörleri kullanacaktır.)*

The primary physical target device shall be the Xiaomi Redmi Note 9 Pro. *(Birincil fiziksel hedef cihaz Xiaomi Redmi Note 9 Pro olacaktır.)*

The core navigation system shall operate without a mandatory cloud service. *(Temel navigasyon sistemi zorunlu bir bulut hizmeti olmadan çalışacaktır.)*

---

# 5. Primary System Actor (Birincil Sistem Aktörü)

The primary actor shall be a technical user conducting navigation experiments and reviewing system outputs. *(Birincil aktör, navigasyon deneyleri gerçekleştiren ve sistem çıktılarını inceleyen teknik kullanıcı olacaktır.)*

The user shall be able to initialize, start, observe, stop, save, and review a navigation session. *(Kullanıcı bir navigasyon oturumunu başlatabilmeli, başlatma işlemini yapabilmeli, gözlemleyebilmeli, durdurabilmeli, kaydedebilmeli ve inceleyebilmelidir.)*

The user shall not be required to manually process raw sensor measurements during normal application operation. *(Kullanıcının normal uygulama çalışması sırasında ham sensör ölçümlerini manuel olarak işlemesi gerekmeyecektir.)*

---

# 6. Functional Requirement Priority Classes (Fonksiyonel Gereksinim Öncelik Sınıfları)

| Priority (Öncelik) | Definition (Tanım) |
| --- | --- |
| MUST | Required for minimum project acceptance *(Minimum proje kabulü için zorunlu)* |
| TARGET | Required for intended full NAVGUARD configuration *(Planlanan tam NAVGUARD yapılandırması için gerekli)* |
| OPTIONAL | Implemented only if justified by schedule and experimental value *(Yalnızca takvim ve deneysel değer tarafından gerekçelendirilirse uygulanır)* |

---

# 7. Application Startup Requirements (Uygulama Başlatma Gereksinimleri)

### FR-001 — Application Launch (Uygulama Başlatma)

NAVGUARD shall launch successfully on the target Android device without requiring an internet connection for core initialization. *(NAVGUARD, temel başlatma için internet bağlantısı gerektirmeden hedef Android cihaz üzerinde başarıyla açılacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### FR-002 — Device Capability Check (Cihaz Yetenek Kontrolü)

The application shall check the availability of mandatory sensors before allowing a navigation experiment to begin. *(Uygulama, bir navigasyon deneyinin başlamasına izin vermeden önce zorunlu sensörlerin kullanılabilirliğini kontrol edecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### FR-003 — Startup Diagnostic Status (Başlangıç Tanı Durumu)

The application shall display whether the core navigation components are ready, unavailable, or degraded. *(Uygulama, temel navigasyon bileşenlerinin hazır, kullanılamaz veya bozulmuş durumda olup olmadığını gösterecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

---

# 8. Permission Requirements (İzin Gereksinimleri)

### FR-004 — Location Permission (Konum İzni)

The application shall request the Android location permission required to obtain GNSS position information. *(Uygulama, GNSS konum bilgisini elde etmek için gerekli Android konum iznini isteyecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### FR-005 — Camera Permission (Kamera İzni)

The application shall request camera permission before enabling ARCore-based visual-inertial tracking. *(Uygulama, ARCore tabanlı görsel-ataletsel takibi etkinleştirmeden önce kamera izni isteyecektir.)*

**Priority:** TARGET *(Öncelik: TARGET)*

### FR-006 — Permission Denial Handling (İzin Reddetme Yönetimi)

The application shall handle denied permissions without crashing. *(Uygulama reddedilen izinleri çökmeden yönetecektir.)*

The application shall explain which functionality is unavailable when a required permission is denied. *(Uygulama, gerekli bir izin reddedildiğinde hangi işlevin kullanılamadığını açıklayacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### FR-007 — Background Location Restriction (Arka Plan Konum Kısıtı)

The minimum NAVGUARD architecture shall not require continuous background location permission because formal navigation experiments will be performed while the application is active. *(Minimum NAVGUARD mimarisi sürekli arka plan konum iznine ihtiyaç duymayacaktır çünkü resmî navigasyon deneyleri uygulama aktifken gerçekleştirilecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

---

# 9. Sensor Acquisition Requirements (Sensör Veri Toplama Gereksinimleri)

### SEN-001 — Accelerometer Acquisition (İvmeölçer Veri Toplama)

The system shall acquire three-axis accelerometer measurements with timestamps. *(Sistem, zaman damgalarıyla birlikte üç eksenli ivmeölçer ölçümlerini elde edecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### SEN-002 — Gyroscope Acquisition (Jiroskop Veri Toplama)

The system shall acquire three-axis gyroscope measurements with timestamps. *(Sistem, zaman damgalarıyla birlikte üç eksenli jiroskop ölçümlerini elde edecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### SEN-003 — Magnetometer Acquisition (Manyetometre Veri Toplama)

The system shall acquire three-axis magnetic field measurements with timestamps. *(Sistem, zaman damgalarıyla birlikte üç eksenli manyetik alan ölçümlerini elde edecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### SEN-004 — Rotation Vector Acquisition (Dönüş Vektörü Veri Toplama)

The system should acquire Android rotation-vector measurements if the physical device exposes a suitable rotation-vector sensor. *(Fiziksel cihaz uygun bir dönüş vektörü sensörü sunuyorsa sistem Android rotation-vector ölçümlerini elde etmelidir.)*

**Priority:** TARGET *(Öncelik: TARGET)*

### SEN-005 — Virtual Sensor Fallback (Sanal Sensör Geri Dönüşü)

The architecture shall not depend exclusively on optional Android virtual sensors. *(Mimari yalnızca isteğe bağlı Android sanal sensörlerine bağımlı olmayacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### SEN-006 — Sensor Timestamp Preservation (Sensör Zaman Damgası Koruma)

The original sensor event timestamp shall be preserved for every recorded measurement. *(Her kaydedilen ölçüm için orijinal sensör olay zaman damgası korunacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

---

# 10. Sensor Sampling Requirements (Sensör Örnekleme Gereksinimleri)

### SEN-007 — Configurable Sampling Rate (Yapılandırılabilir Örnekleme Hızı)

The sensor subsystem shall support a configurable target sampling configuration for the primary inertial sensors. *(Sensör alt sistemi temel ataletsel sensörler için yapılandırılabilir bir hedef örnekleme yapılandırmasını destekleyecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### SEN-008 — Initial IMU Sampling Target (Başlangıç IMU Örnekleme Hedefi)

The initial accelerometer and gyroscope target sampling rate should be approximately 50 Hz until the Device Capability Audit establishes the final configuration. *(Cihaz Yetenek Denetimi nihai yapılandırmayı belirleyene kadar başlangıç ivmeölçer ve jiroskop hedef örnekleme hızı yaklaşık 50 Hz olmalıdır.)*

**Priority:** TARGET *(Öncelik: TARGET)*

### SEN-009 — Effective Rate Measurement (Etkin Hız Ölçümü)

The application shall calculate effective sensor sampling rates using received event timestamps. *(Uygulama, alınan olay zaman damgalarını kullanarak etkin sensör örnekleme hızlarını hesaplayacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### SEN-010 — Irregular Timing Handling (Düzensiz Zamanlama Yönetimi)

Navigation calculations shall use actual time differences between measurements instead of assuming perfectly fixed sensor intervals. *(Navigasyon hesaplamaları tamamen sabit sensör aralıkları varsaymak yerine ölçümler arasındaki gerçek zaman farklarını kullanacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

---

# 11. Sensor Metadata Requirements (Sensör Metadata Gereksinimleri)

### SEN-011 — Sensor Inventory (Sensör Envanteri)

The system shall be able to enumerate all sensors exposed by the Android runtime. *(Sistem Android çalışma zamanı tarafından sunulan tüm sensörleri listeleyebilmelidir.)*

**Priority:** MUST *(Öncelik: MUST)*

### SEN-012 — Sensor Technical Metadata (Sensör Teknik Metadata Bilgisi)

The system shall record available sensor metadata including name, vendor, resolution, maximum range, minimum delay, and Android sensor type. *(Sistem; sensör adı, üretici, çözünürlük, maksimum aralık, minimum gecikme ve Android sensör türü dahil olmak üzere mevcut sensör metadata bilgisini kaydedecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

---

# 12. GNSS Requirements (GNSS Gereksinimleri)

### NAV-001 — Initial GNSS Position (Başlangıç GNSS Konumu)

NAVGUARD shall obtain a valid GNSS position before beginning a formal GNSS-denied navigation experiment. *(NAVGUARD, resmî bir GNSS kesintili navigasyon deneyine başlamadan önce geçerli bir GNSS konumu elde edecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### NAV-002 — GNSS Accuracy Information (GNSS Doğruluk Bilgisi)

The system shall record the accuracy value associated with GNSS location updates when Android provides it. *(Sistem, Android sağladığında GNSS konum güncellemeleriyle ilişkili doğruluk değerini kaydedecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### NAV-003 — GNSS Initialization Gate (GNSS Başlatma Kapısı)

The application shall prevent a formal evaluation session from starting if the initial GNSS state does not satisfy the configured readiness condition. *(Uygulama, başlangıç GNSS durumu yapılandırılmış hazırlık koşulunu karşılamıyorsa resmî değerlendirme oturumunun başlamasını engelleyecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### NAV-004 — Ground Truth Recording (Gerçek Referans Kaydı)

Evaluation mode shall allow GNSS positions to continue being recorded as independent ground-truth data. *(Değerlendirme modu, GNSS konumlarının bağımsız gerçek referans verisi olarak kaydedilmeye devam etmesine izin verecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### NAV-005 — Ground Truth Isolation (Gerçek Referans İzolasyonu)

Ground-truth GNSS measurements shall not enter the position estimator while the GNSS-denied state is active. *(Gerçek referans GNSS ölçümleri GNSS kesintili durum aktifken konum tahmin motoruna girmeyecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

---

# 13. Navigation Mode Requirements (Navigasyon Modu Gereksinimleri)

### NAV-006 — GNSS Mode (GNSS Modu)

The application shall provide a normal GNSS-enabled navigation state. *(Uygulama normal bir GNSS etkin navigasyon durumu sağlayacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### NAV-007 — Evaluation Mode (Değerlendirme Modu)

The application shall provide an evaluation mode in which GNSS ground truth is recorded while denied to the alternative navigation estimator. *(Uygulama, GNSS gerçek referansının kaydedildiği ancak alternatif navigasyon tahmin motoruna verilmediği bir değerlendirme modu sağlayacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### NAV-008 — GNSS-Denied Mode (GNSS Kesintili Mod)

The system shall provide a software-controlled GNSS-denied state that prevents GNSS coordinates from updating the alternative position estimator. *(Sistem, GNSS koordinatlarının alternatif konum tahmin motorunu güncellemesini engelleyen yazılım kontrollü bir GNSS kesintili durum sağlayacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### NAV-009 — Navigation State Visibility (Navigasyon Durumu Görünürlüğü)

The active navigation mode shall be visible in the application interface and recorded in the session log. *(Aktif navigasyon modu uygulama arayüzünde görünür olacak ve oturum kaydına yazılacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

---

# 14. Pedestrian Dead Reckoning Requirements (Yaya Ölü Hesaplama Gereksinimleri)

### NAV-010 — Baseline PDR (Temel PDR)

NAVGUARD shall implement a baseline Pedestrian Dead Reckoning subsystem. *(NAVGUARD temel bir Yaya Ölü Hesaplama alt sistemi geliştirecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### NAV-011 — Step-Based Displacement (Adım Tabanlı Yer Değiştirme)

The baseline PDR shall estimate pedestrian displacement using detected steps, estimated step length, and heading. *(Temel PDR, tespit edilen adımları, tahmini adım uzunluğunu ve yönü kullanarak yaya yer değiştirmesini tahmin edecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### NAV-012 — Local Position Representation (Yerel Konum Temsili)

The PDR subsystem shall maintain movement in a local navigation coordinate system before conversion to geographic coordinates. *(PDR alt sistemi, coğrafi koordinatlara dönüşümden önce hareketi yerel bir navigasyon koordinat sisteminde tutacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### NAV-013 — Estimated Route Update (Tahmini Rota Güncellemesi)

The PDR subsystem shall generate sequential estimated positions that can be displayed as a route. *(PDR alt sistemi rota olarak gösterilebilecek ardışık tahmini konumlar üretecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

---

# 15. Step Detection Requirements (Adım Tespit Gereksinimleri)

### NAV-014 — Independent Step Detection (Bağımsız Adım Tespiti)

NAVGUARD shall implement its own step detection logic using inertial measurements. *(NAVGUARD, ataletsel ölçümleri kullanarak kendi adım tespit mantığını geliştirecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### NAV-015 — Native Step Sensor Independence (Native Adım Sensörü Bağımsızlığı)

The minimum project shall not depend on Android’s native step detector or step counter. *(Minimum proje Android’in native adım algılayıcısına veya adım sayacına bağımlı olmayacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### NAV-016 — Step Count Output (Adım Sayısı Çıktısı)

The system shall expose the detected step count for each navigation session. *(Sistem her navigasyon oturumu için tespit edilen adım sayısını gösterecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### NAV-017 — Stationary False-Step Suppression (Sabit Durum Yanlış Adım Bastırma)

The navigation system should suppress false displacement updates when the user is stationary. *(Navigasyon sistemi kullanıcı sabit durumdayken yanlış yer değiştirme güncellemelerini bastırmalıdır.)*

**Priority:** TARGET *(Öncelik: TARGET)*

---

# 16. Heading Estimation Requirements (Yön Tahmini Gereksinimleri)

### NAV-018 — Heading Output (Yön Çıktısı)

NAVGUARD shall maintain an estimate of pedestrian movement heading. *(NAVGUARD yaya hareket yönünün bir tahminini sürdürecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### NAV-019 — Multi-Sensor Heading (Çoklu Sensör Yön Tahmini)

The target heading subsystem should combine information from more than one orientation-related source when available. *(Hedef yön alt sistemi mevcut olduğunda birden fazla yönelimle ilişkili kaynaktan gelen bilgiyi birleştirmelidir.)*

**Priority:** TARGET *(Öncelik: TARGET)*

### NAV-020 — Magnetometer Degradation Handling (Manyetometre Bozulma Yönetimi)

The system should reduce dependence on magnetometer-derived heading when magnetic measurements are identified as unreliable. *(Sistem manyetik ölçümler güvenilmez olarak belirlendiğinde manyetometreden türetilen yöne olan bağımlılığı azaltmalıdır.)*

**Priority:** TARGET *(Öncelik: TARGET)*

---

# 17. Coordinate System Requirements (Koordinat Sistemi Gereksinimleri)

### NAV-021 — Initial Geographic Anchor (Başlangıç Coğrafi Çapası)

The last accepted GNSS position before the denied phase shall define the initial geographic anchor of the local navigation frame. *(Kesinti aşamasından önce kabul edilen son GNSS konumu yerel navigasyon koordinat sisteminin başlangıç coğrafi çapasını tanımlayacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### NAV-022 — Local ENU-Compatible Representation (Yerel ENU-Uyumlu Temsil)

The navigation architecture shall support a local east-north representation suitable for pedestrian displacement calculations. *(Navigasyon mimarisi yaya yer değiştirme hesaplamalarına uygun yerel doğu-kuzey temsilini destekleyecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### NAV-023 — Geographic Conversion (Coğrafi Dönüşüm)

The application shall convert estimated local displacement into latitude and longitude for map visualization and comparison. *(Uygulama, harita görselleştirmesi ve karşılaştırma için tahmini yerel yer değiştirmeyi enlem ve boylama dönüştürecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

---

# 18. Artificial Intelligence Requirements (Yapay Zekâ Gereksinimleri)

### AI-001 — Motion Classification (Hareket Sınıflandırması)

NAVGUARD shall include an artificial intelligence or machine learning component for classifying pedestrian motion from sensor time-series data. *(NAVGUARD, sensör zaman serisi verilerinden yaya hareketini sınıflandırmak için bir yapay zekâ veya makine öğrenmesi bileşeni içerecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### AI-002 — Motion Classes (Hareket Sınıfları)

The planned primary motion classes shall include stationary, walking, running, and turning. *(Planlanan temel hareket sınıfları sabit durma, yürüme, koşma ve dönmeyi içerecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### AI-003 — 1D-CNN Candidate (1D-CNN Adayı)

A lightweight 1D Convolutional Neural Network shall be evaluated as a primary candidate model. *(Hafif bir 1 Boyutlu Evrişimsel Sinir Ağı birincil aday model olarak değerlendirilecektir.)*

**Priority:** TARGET *(Öncelik: TARGET)*

### AI-004 — Baseline Model Comparison (Temel Model Karşılaştırması)

At least one traditional machine learning baseline shall be compared with the candidate neural model before the final model is selected. *(Nihai model seçilmeden önce en az bir geleneksel makine öğrenmesi temel modeli aday sinir ağı modeliyle karşılaştırılacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### AI-005 — Session-Level Data Split (Oturum Seviyesinde Veri Bölme)

Training, validation, and test partitions shall be separated at the recording-session level. *(Eğitim, doğrulama ve test bölümleri kayıt oturumu seviyesinde ayrılacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### AI-006 — Test Data Isolation (Test Verisi İzolasyonu)

Test sessions shall not be used for model training, feature fitting, or hyperparameter selection. *(Test oturumları model eğitimi, özellik uyarlaması veya hiperparametre seçimi için kullanılmayacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### AI-007 — Model Evaluation Metrics (Model Değerlendirme Metrikleri)

The motion classifier shall be evaluated using accuracy, per-class metrics, macro F1 score, and a confusion matrix. *(Hareket sınıflandırıcı doğruluk, sınıf bazlı metrikler, macro F1 skoru ve karışıklık matrisi kullanılarak değerlendirilecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

---

# 19. On-Device AI Requirements (Cihaz Üzeri Yapay Zekâ Gereksinimleri)

### AI-008 — Local Inference (Yerel Çıkarım)

The final motion classification model shall perform inference locally on the Android device. *(Nihai hareket sınıflandırma modeli çıkarımı Android cihaz üzerinde yerel olarak gerçekleştirecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### AI-009 — Cloud Independence (Bulut Bağımsızlığı)

Real-time motion classification shall not require a cloud AI API. *(Gerçek zamanlı hareket sınıflandırması bir bulut yapay zekâ API’sine ihtiyaç duymayacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### AI-010 — TensorFlow Lite Deployment (TensorFlow Lite Dağıtımı)

The preferred deployment format for the neural motion model shall be TensorFlow Lite or its compatible Android runtime equivalent. *(Sinir ağı hareket modeli için tercih edilen dağıtım formatı TensorFlow Lite veya uyumlu Android çalışma zamanı eşdeğeri olacaktır.)*

**Priority:** TARGET *(Öncelik: TARGET)*

### AI-011 — AI Navigation Integration (Yapay Zekâ Navigasyon Entegrasyonu)

The AI output shall influence navigation logic or experimental evaluation rather than exist only as a visual demonstration. *(Yapay zekâ çıktısı yalnızca görsel bir gösterim olarak bulunmak yerine navigasyon mantığını veya deneysel değerlendirmeyi etkileyecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

---

# 20. Step Length Estimation Requirements (Adım Uzunluğu Tahmin Gereksinimleri)

### AI-012 — Baseline Step Length (Temel Adım Uzunluğu)

NAVGUARD shall provide a deterministic or calibrated baseline step length model. *(NAVGUARD deterministik veya kalibre edilmiş temel bir adım uzunluğu modeli sağlayacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### AI-013 — Learned Step Length Estimation (Öğrenilmiş Adım Uzunluğu Tahmini)

NAVGUARD should evaluate a regression-based dynamic step length model if schedule and dataset quality permit. *(Takvim ve veri seti kalitesi izin verirse NAVGUARD regresyon tabanlı dinamik bir adım uzunluğu modelini değerlendirmelidir.)*

**Priority:** TARGET *(Öncelik: TARGET)*

### AI-014 — Learned Model Retention Rule (Öğrenilmiş Modeli Koruma Kuralı)

A learned step length model shall remain in the final architecture only if experimental results show measurable benefit over the baseline approach. *(Öğrenilmiş bir adım uzunluğu modeli yalnızca deneysel sonuçlar temel yaklaşıma göre ölçülebilir fayda gösterirse nihai mimaride kalacaktır.)*

**Priority:** TARGET *(Öncelik: TARGET)*

---

# 21. ARCore Requirements (ARCore Gereksinimleri)

### AR-001 — ARCore Compatibility Check (ARCore Uyumluluk Kontrolü)

The application shall verify ARCore availability before enabling visual-inertial navigation features. *(Uygulama görsel-ataletsel navigasyon özelliklerini etkinleştirmeden önce ARCore kullanılabilirliğini doğrulayacaktır.)*

**Priority:** TARGET *(Öncelik: TARGET)*

### AR-002 — Relative Pose Acquisition (Göreli Poz Veri Toplama)

NAVGUARD should acquire timestamped ARCore pose information including translation and rotation. *(NAVGUARD, öteleme ve dönüşü içeren zaman damgalı ARCore poz bilgisini elde etmelidir.)*

**Priority:** TARGET *(Öncelik: TARGET)*

### AR-003 — Tracking State Acquisition (Takip Durumu Veri Toplama)

The application shall record the ARCore tracking state when ARCore is active. *(Uygulama ARCore aktifken ARCore takip durumunu kaydedecektir.)*

**Priority:** TARGET *(Öncelik: TARGET)*

### AR-004 — Tracking Failure Handling (Takip Başarısızlığı Yönetimi)

ARCore tracking failure shall not cause the entire navigation session to terminate. *(ARCore takip başarısızlığı tüm navigasyon oturumunun sonlanmasına neden olmayacaktır.)*

**Priority:** TARGET *(Öncelik: TARGET)*

### AR-005 — ARCore Optionality (ARCore İsteğe Bağlılığı)

The minimum PDR-based NAVGUARD configuration shall remain functional without ARCore. *(Minimum PDR tabanlı NAVGUARD yapılandırması ARCore olmadan çalışabilir durumda kalacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

---

# 22. Sensor Confidence Requirements (Sensör Güven Gereksinimleri)

### NAV-024 — Sensor Quality Representation (Sensör Kalite Temsili)

The target system should maintain quality or confidence information for major navigation sources. *(Hedef sistem temel navigasyon kaynakları için kalite veya güven bilgisi tutmalıdır.)*

**Priority:** TARGET *(Öncelik: TARGET)*

### NAV-025 — Degraded Sensor Influence (Bozulmuş Sensör Etkisi)

Measurements identified as degraded should have reduced influence on the final navigation estimate. *(Bozulmuş olarak belirlenen ölçümler nihai navigasyon tahmini üzerinde azaltılmış etkiye sahip olmalıdır.)*

**Priority:** TARGET *(Öncelik: TARGET)*

### NAV-026 — Quality Diagnostic Output (Kalite Tanısal Çıktısı)

The application should expose major sensor quality states for research and debugging purposes. *(Uygulama araştırma ve hata ayıklama amacıyla temel sensör kalite durumlarını göstermelidir.)*

**Priority:** TARGET *(Öncelik: TARGET)*

---

# 23. Sensor Fusion Requirements (Sensör Füzyonu Gereksinimleri)

### NAV-027 — Multi-Source Fusion (Çok Kaynaklı Füzyon)

The target NAVGUARD configuration shall combine multiple navigation information sources into a unified estimate. *(Hedef NAVGUARD yapılandırması birden fazla navigasyon bilgi kaynağını birleşik bir tahminde birleştirecektir.)*

**Priority:** TARGET *(Öncelik: TARGET)*

### NAV-028 — EKF Evaluation (EKF Değerlendirmesi)

An Extended Kalman Filter shall be evaluated as the primary candidate for state estimation and sensor fusion. *(Genişletilmiş Kalman Filtresi durum tahmini ve sensör füzyonu için birincil aday olarak değerlendirilecektir.)*

**Priority:** TARGET *(Öncelik: TARGET)*

### NAV-029 — Fusion Fallback (Füzyon Geri Dönüşü)

The fusion architecture shall remain operational when an optional measurement source is temporarily unavailable. *(Füzyon mimarisi isteğe bağlı bir ölçüm kaynağı geçici olarak kullanılamadığında çalışır durumda kalacaktır.)*

**Priority:** TARGET *(Öncelik: TARGET)*

### NAV-030 — Internal State Logging (Dahili Durum Kaydı)

The fusion subsystem shall expose sufficient internal state for debugging and experimental analysis. *(Füzyon alt sistemi hata ayıklama ve deneysel analiz için yeterli dahili durumu erişilebilir hale getirecektir.)*

**Priority:** TARGET *(Öncelik: TARGET)*

---

# 24. Position Estimation Requirements (Konum Tahmin Gereksinimleri)

### NAV-031 — Continuous Estimate (Sürekli Tahmin)

The application shall continue producing estimated positions during an active GNSS-denied session while sufficient local navigation information is available. *(Uygulama yeterli yerel navigasyon bilgisi mevcutken aktif bir GNSS kesintili oturum sırasında tahmini konumlar üretmeye devam edecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### NAV-032 — Timestamped Position Output (Zaman Damgalı Konum Çıktısı)

Every stored position estimate shall include a timestamp. *(Saklanan her konum tahmini bir zaman damgası içerecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### NAV-033 — Estimated Travelled Distance (Tahmini Kat Edilen Mesafe)

The system shall maintain an estimate of total travelled distance during the navigation session. *(Sistem navigasyon oturumu sırasında toplam kat edilen mesafenin tahminini tutacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### NAV-034 — Position Uncertainty (Konum Belirsizliği)

The target system shall provide a confidence or uncertainty representation associated with the estimated position. *(Hedef sistem tahmini konumla ilişkili bir güven veya belirsizlik temsili sağlayacaktır.)*

**Priority:** TARGET *(Öncelik: TARGET)*

---

# 25. GNSS Recovery Requirements (GNSS Geri Kazanım Gereksinimleri)

### NAV-035 — GNSS Recovery Detection (GNSS Geri Kazanım Tespiti)

The system should detect when acceptable GNSS positioning becomes available again after a denied period. *(Sistem, bir kesinti döneminden sonra kabul edilebilir GNSS konumlandırması tekrar kullanılabilir hale geldiğinde bunu tespit etmelidir.)*

**Priority:** TARGET *(Öncelik: TARGET)*

### NAV-036 — Estimate-to-GNSS Difference (Tahmin-GNSS Farkı)

The system should calculate the difference between the current NAVGUARD estimate and the recovered GNSS position. *(Sistem mevcut NAVGUARD tahmini ile geri kazanılan GNSS konumu arasındaki farkı hesaplamalıdır.)*

**Priority:** TARGET *(Öncelik: TARGET)*

### NAV-037 — Controlled Relocalization (Kontrollü Yeniden Konumlandırma)

The target system should support controlled relocalization rather than an unexplained instantaneous state reset. *(Hedef sistem açıklamasız anlık durum sıfırlaması yerine kontrollü yeniden konumlandırmayı desteklemelidir.)*

**Priority:** TARGET *(Öncelik: TARGET)*

---

# 26. Session Management Requirements (Oturum Yönetimi Gereksinimleri)

### FR-008 — Start Session (Oturum Başlatma)

The user shall be able to start a new navigation session after the readiness conditions are satisfied. *(Kullanıcı hazırlık koşulları karşılandıktan sonra yeni bir navigasyon oturumu başlatabilecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### FR-009 — Stop Session (Oturum Durdurma)

The user shall be able to stop an active navigation session explicitly. *(Kullanıcı aktif bir navigasyon oturumunu açıkça durdurabilecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### FR-010 — Session Identifier (Oturum Kimliği)

Every recorded navigation session shall have a unique identifier. *(Kaydedilen her navigasyon oturumu benzersiz bir kimliğe sahip olacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### FR-011 — Session Metadata (Oturum Metadata Bilgisi)

Each session shall store configuration metadata including application version, navigation configuration, device identity, and model version where applicable. *(Her oturum; uygulama sürümü, navigasyon yapılandırması, cihaz kimliği ve uygulanabilir olduğunda model sürümü dahil olmak üzere yapılandırma metadata bilgisini saklayacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### FR-012 — Session History (Oturum Geçmişi)

The application shall provide access to previously recorded navigation sessions. *(Uygulama daha önce kaydedilmiş navigasyon oturumlarına erişim sağlayacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

---

# 27. Data Logging Requirements (Veri Kayıt Gereksinimleri)

### DATA-001 — Raw Sensor Logging (Ham Sensör Kaydı)

The system shall be able to record raw measurements from the sensors required by the active experimental configuration. *(Sistem aktif deneysel yapılandırma tarafından gerekli sensörlerden gelen ham ölçümleri kaydedebilecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### DATA-002 — GNSS Logging (GNSS Kaydı)

The system shall record GNSS reference measurements during evaluation sessions. *(Sistem değerlendirme oturumları sırasında GNSS referans ölçümlerini kaydedecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### DATA-003 — Estimator Output Logging (Tahmin Motoru Çıktı Kaydı)

The system shall record the generated position estimates and relevant estimator state. *(Sistem üretilen konum tahminlerini ve ilgili tahmin motoru durumunu kaydedecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### DATA-004 — AI Output Logging (Yapay Zekâ Çıktı Kaydı)

The system shall record motion classification outputs with timestamps during experimental sessions. *(Sistem deneysel oturumlar sırasında hareket sınıflandırma çıktılarını zaman damgalarıyla kaydedecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### DATA-005 — Navigation Mode Logging (Navigasyon Modu Kaydı)

The active navigation mode and transitions between modes shall be recorded. *(Aktif navigasyon modu ve modlar arasındaki geçişler kaydedilecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

---

# 28. Data Integrity Requirements (Veri Bütünlüğü Gereksinimleri)

### DATA-006 — Common Experiment Timeline (Ortak Deney Zaman Çizelgesi)

Sensor, GNSS, ARCore, AI, and estimator data shall be alignable onto a common experiment timeline. *(Sensör, GNSS, ARCore, yapay zekâ ve tahmin motoru verileri ortak bir deney zaman çizelgesine hizalanabilir olacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### DATA-007 — Missing Data Identification (Eksik Veri Tanımlama)

Missing or unavailable measurements shall not be silently replaced with fabricated values. *(Eksik veya kullanılamayan ölçümler sessizce uydurulmuş değerlerle değiştirilmeyecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### DATA-008 — Invalid Numeric Handling (Geçersiz Sayısal Değer Yönetimi)

The system shall detect or safely handle invalid numeric values that could corrupt navigation calculations. *(Sistem navigasyon hesaplamalarını bozabilecek geçersiz sayısal değerleri tespit edecek veya güvenli şekilde yönetecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### DATA-009 — Session Completeness (Oturum Bütünlüğü)

The system shall indicate whether a recorded session contains all data required for the selected benchmark configuration. *(Sistem kaydedilmiş bir oturumun seçilen benchmark yapılandırması için gerekli tüm verileri içerip içermediğini belirtecektir.)*

**Priority:** TARGET *(Öncelik: TARGET)*

---

# 29. Data Export Requirements (Veri Dışa Aktarma Gereksinimleri)

### DATA-010 — Research Data Export (Araştırma Verisi Dışa Aktarma)

The application shall provide a method to export recorded experimental data for offline Python analysis. *(Uygulama kaydedilmiş deneysel verileri çevrimdışı Python analizi için dışa aktarma yöntemi sağlayacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### DATA-011 — Machine-Readable Format (Makine Tarafından Okunabilir Format)

Exported experimental data shall use a documented machine-readable format such as CSV, JSON, or another structured format selected during architecture design. *(Dışa aktarılan deneysel veriler CSV, JSON veya mimari tasarım sırasında seçilen başka bir yapılandırılmış format gibi dokümante edilmiş makine tarafından okunabilir bir format kullanacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### DATA-012 — Replay Compatibility (Yeniden Oynatma Uyumluluğu)

The target architecture should support replaying recorded sessions through multiple estimator configurations. *(Hedef mimari kaydedilmiş oturumların birden fazla tahmin motoru yapılandırması üzerinden yeniden oynatılmasını desteklemelidir.)*

**Priority:** TARGET *(Öncelik: TARGET)*

---

# 30. User Interface Requirements (Kullanıcı Arayüzü Gereksinimleri)

### FR-013 — Home Screen (Ana Ekran)

The application shall provide a home or system status screen showing overall NAVGUARD readiness. *(Uygulama genel NAVGUARD hazırlığını gösteren bir ana ekran veya sistem durum ekranı sağlayacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### FR-014 — Calibration and Readiness Screen (Kalibrasyon ve Hazırlık Ekranı)

The application shall provide a pre-session screen showing the readiness of mandatory navigation components. *(Uygulama zorunlu navigasyon bileşenlerinin hazırlığını gösteren oturum öncesi bir ekran sağlayacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### FR-015 — Live Navigation Screen (Canlı Navigasyon Ekranı)

The application shall provide a live screen displaying the estimated navigation state during a session. *(Uygulama bir oturum sırasında tahmini navigasyon durumunu gösteren canlı bir ekran sağlayacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### FR-016 — Estimated Route Visualization (Tahmini Rota Görselleştirmesi)

The application shall visualize the estimated route during or after a navigation session. *(Uygulama tahmini rotayı navigasyon oturumu sırasında veya sonrasında görselleştirecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### FR-017 — Navigation Mode Indicator (Navigasyon Modu Göstergesi)

The interface shall clearly indicate whether the estimator is using GNSS, operating in evaluation mode, or operating in GNSS-denied mode. *(Arayüz tahmin motorunun GNSS kullanıp kullanmadığını, değerlendirme modunda mı yoksa GNSS kesintili modda mı çalıştığını açıkça gösterecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

---

# 31. Research Dashboard Requirements (Araştırma Dashboard Gereksinimleri)

### FR-018 — Sensor Monitor (Sensör İzleme)

The application should provide a developer or research view showing live sensor status and selected measurements. *(Uygulama canlı sensör durumunu ve seçilen ölçümleri gösteren bir geliştirici veya araştırma görünümü sağlamalıdır.)*

**Priority:** TARGET *(Öncelik: TARGET)*

### FR-019 — AI Monitor (Yapay Zekâ İzleme)

The application should display the current AI motion class and associated confidence information during research sessions. *(Uygulama araştırma oturumları sırasında mevcut yapay zekâ hareket sınıfını ve ilişkili güven bilgisini göstermelidir.)*

**Priority:** TARGET *(Öncelik: TARGET)*

### FR-020 — Sensor Quality Monitor (Sensör Kalite İzleme)

The target application should display major sensor quality states when the confidence engine is available. *(Hedef uygulama güven motoru mevcut olduğunda temel sensör kalite durumlarını göstermelidir.)*

**Priority:** TARGET *(Öncelik: TARGET)*

---

# 32. Result Review Requirements (Sonuç İnceleme Gereksinimleri)

### FR-021 — Session Result Screen (Oturum Sonuç Ekranı)

The application shall provide a summary screen after a completed evaluation session. *(Uygulama tamamlanmış bir değerlendirme oturumundan sonra bir özet ekranı sağlayacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### FR-022 — Estimated and Reference Route Comparison (Tahmini ve Referans Rota Karşılaştırması)

The result view shall allow comparison of the estimated route with the recorded GNSS reference route. *(Sonuç görünümü tahmini rotanın kaydedilen GNSS referans rotasıyla karşılaştırılmasına izin verecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### FR-023 — Error Metrics Display (Hata Metrikleri Gösterimi)

The application or offline analysis pipeline shall provide the primary navigation error metrics for evaluation sessions. *(Uygulama veya çevrimdışı analiz hattı değerlendirme oturumları için temel navigasyon hata metriklerini sağlayacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

---

# 33. Experimental Configuration Requirements (Deneysel Yapılandırma Gereksinimleri)

### TEST-001 — PDR-Only Configuration (Yalnızca PDR Yapılandırması)

The experimental framework shall support a PDR-only baseline configuration. *(Deneysel framework yalnızca PDR kullanan bir temel yapılandırmayı destekleyecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### TEST-002 — PDR and Heading Configuration (PDR ve Yön Yapılandırması)

The framework shall support a configuration combining PDR with improved heading estimation. *(Framework PDR’yi geliştirilmiş yön tahminiyle birleştiren bir yapılandırmayı destekleyecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### TEST-003 — PDR and ARCore Configuration (PDR ve ARCore Yapılandırması)

The target framework should support a configuration combining PDR and ARCore movement information. *(Hedef framework PDR ile ARCore hareket bilgisini birleştiren bir yapılandırmayı desteklemelidir.)*

**Priority:** TARGET *(Öncelik: TARGET)*

### TEST-004 — Full NAVGUARD Configuration (Tam NAVGUARD Yapılandırması)

The target framework shall support the final integrated AI-assisted sensor fusion configuration. *(Hedef framework nihai entegre yapay zekâ destekli sensör füzyonu yapılandırmasını destekleyecektir.)*

**Priority:** TARGET *(Öncelik: TARGET)*

---

# 34. Evaluation Metric Requirements (Değerlendirme Metrik Gereksinimleri)

### TEST-005 — Position Error Calculation (Konum Hatası Hesaplama)

The evaluation pipeline shall calculate point-wise position error where temporally aligned ground-truth data is available. *(Değerlendirme hattı zaman açısından hizalanmış gerçek referans verisi mevcut olduğunda nokta bazlı konum hatasını hesaplayacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### TEST-006 — Mean and Median Error (Ortalama ve Medyan Hata)

The evaluation pipeline shall calculate mean and median position error. *(Değerlendirme hattı ortalama ve medyan konum hatasını hesaplayacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### TEST-007 — RMSE (RMSE)

The evaluation pipeline shall calculate position RMSE. *(Değerlendirme hattı konum RMSE değerini hesaplayacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### TEST-008 — Final Position Error (Nihai Konum Hatası)

The evaluation pipeline shall calculate final position error for each evaluation session. *(Değerlendirme hattı her değerlendirme oturumu için nihai konum hatasını hesaplayacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### TEST-009 — Drift Rate (Sürüklenme Hızı)

The evaluation pipeline shall calculate at least one drift metric relative to time or travelled distance. *(Değerlendirme hattı zamana veya kat edilen mesafeye göre en az bir sürüklenme metriği hesaplayacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

---

# 35. Field Experiment Requirements (Saha Deney Gereksinimleri)

### TEST-010 — Multiple Route Geometries (Birden Fazla Rota Geometrisi)

The final evaluation shall include more than one route geometry. *(Nihai değerlendirme birden fazla rota geometrisini içerecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### TEST-011 — Straight Route (Düz Rota)

The final experiment set shall include at least one straight walking route. *(Nihai deney seti en az bir düz yürüyüş rotası içerecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### TEST-012 — Turning Route (Dönüşlü Rota)

The final experiment set shall include at least one route containing multiple turns. *(Nihai deney seti birden fazla dönüş içeren en az bir rota içerecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### TEST-013 — Closed Route (Kapalı Rota)

The final experiment set should include at least one closed or approximately closed route. *(Nihai deney seti en az bir kapalı veya yaklaşık kapalı rota içermelidir.)*

**Priority:** TARGET *(Öncelik: TARGET)*

### TEST-014 — Repeated Sessions (Tekrarlı Oturumlar)

Primary route types should be repeated multiple times when environmental conditions and project schedule permit. *(Çevresel koşullar ve proje takvimi izin verdiğinde temel rota türleri birden fazla kez tekrarlanmalıdır.)*

**Priority:** TARGET *(Öncelik: TARGET)*

---

# 36. Offline Operation Requirements (Çevrimdışı Çalışma Gereksinimleri)

### NFR-001 — Offline Core Navigation (Çevrimdışı Temel Navigasyon)

The core GNSS-denied navigation estimator shall operate without Wi-Fi or mobile data connectivity. *(Temel GNSS kesintili navigasyon tahmin motoru Wi-Fi veya mobil veri bağlantısı olmadan çalışacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### NFR-002 — Offline AI (Çevrimdışı Yapay Zekâ)

The final motion classifier shall operate without network connectivity. *(Nihai hareket sınıflandırıcı ağ bağlantısı olmadan çalışacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### NFR-003 — Offline Session Recording (Çevrimdışı Oturum Kaydı)

Navigation sessions shall be recordable locally without network connectivity. *(Navigasyon oturumları ağ bağlantısı olmadan yerel olarak kaydedilebilir olacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

---

# 37. Performance Requirements (Performans Gereksinimleri)

### PERF-001 — Responsive User Interface (Tepki Verebilir Kullanıcı Arayüzü)

The application shall remain responsive during normal sensor acquisition and navigation processing. *(Uygulama normal sensör veri toplama ve navigasyon işleme sırasında tepki verebilir kalacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### PERF-002 — AI Latency Target (Yapay Zekâ Gecikme Hedefi)

The target motion classification inference latency should remain below 50 milliseconds per inference on the Xiaomi Redmi Note 9 Pro under normal benchmark conditions. *(Hedef hareket sınıflandırma çıkarım gecikmesi normal benchmark koşullarında Xiaomi Redmi Note 9 Pro üzerinde çıkarım başına 50 milisaniyenin altında kalmalıdır.)*

**Priority:** TARGET *(Öncelik: TARGET)*

### PERF-003 — No Persistent UI Blocking (Kalıcı Kullanıcı Arayüzü Bloklaması Olmaması)

High-frequency sensor processing shall not repeatedly block the Flutter user-interface thread. *(Yüksek frekanslı sensör işleme Flutter kullanıcı arayüzü thread’ini tekrar tekrar bloke etmeyecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### PERF-004 — Five-Minute Stability (Beş Dakikalık Kararlılık)

The application shall complete at least a five-minute combined sensor and navigation test without crashing. *(Uygulama en az beş dakikalık birleşik sensör ve navigasyon testini çökmeden tamamlayacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

---

# 38. Resource Requirements (Kaynak Gereksinimleri)

### PERF-005 — Memory Stability (Bellek Kararlılığı)

The application shall not exhibit uncontrolled memory growth during normal navigation sessions. *(Uygulama normal navigasyon oturumları sırasında kontrolsüz bellek büyümesi göstermeyecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### PERF-006 — Storage Awareness (Depolama Farkındalığı)

The application shall detect or report insufficient local storage before beginning a recording session when practical. *(Uygulama uygulanabilir olduğunda bir kayıt oturumu başlamadan önce yetersiz yerel depolamayı tespit edecek veya raporlayacaktır.)*

**Priority:** TARGET *(Öncelik: TARGET)*

### PERF-007 — Battery Measurement (Batarya Ölçümü)

The project shall measure battery impact during selected experimental configurations. *(Proje seçilen deneysel yapılandırmalar sırasında batarya etkisini ölçecektir.)*

**Priority:** TARGET *(Öncelik: TARGET)*

---

# 39. Reliability Requirements (Güvenilirlik Gereksinimleri)

### NFR-004 — Graceful Degradation (Kontrollü Performans Kaybı)

The system shall degrade gracefully when an optional subsystem becomes unavailable. *(İsteğe bağlı bir alt sistem kullanılamaz hale geldiğinde sistem kontrollü şekilde performans kaybedecektir.)*

**Priority:** TARGET *(Öncelik: TARGET)*

### NFR-005 — ARCore Failure Isolation (ARCore Hata İzolasyonu)

An ARCore failure shall not corrupt the stored PDR or sensor data for the session. *(Bir ARCore hatası oturumun saklanan PDR veya sensör verisini bozmayacaktır.)*

**Priority:** TARGET *(Öncelik: TARGET)*

### NFR-006 — Data Preservation on Controlled Stop (Kontrollü Durdurmada Veri Koruma)

A normally stopped session shall preserve all successfully recorded data up to the stop event. *(Normal şekilde durdurulan bir oturum durdurma olayına kadar başarıyla kaydedilmiş tüm verileri koruyacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

---

# 40. Error Handling Requirements (Hata Yönetimi Gereksinimleri)

### FR-024 — User-Visible Critical Errors (Kullanıcıya Görünen Kritik Hatalar)

Critical errors preventing a navigation session from starting shall be presented clearly to the user. *(Bir navigasyon oturumunun başlamasını engelleyen kritik hatalar kullanıcıya açık şekilde gösterilecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### FR-025 — Diagnostic Error Logging (Tanısal Hata Kaydı)

Important runtime failures shall be recorded with sufficient information for debugging. *(Önemli çalışma zamanı hataları hata ayıklama için yeterli bilgiyle kaydedilecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### FR-026 — Invalid Configuration Prevention (Geçersiz Yapılandırmayı Önleme)

The application shall prevent a navigation configuration from starting if a required dependency is unavailable. *(Uygulama gerekli bir bağımlılık kullanılamıyorsa bir navigasyon yapılandırmasının başlamasını engelleyecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

---

# 41. Security Requirements (Güvenlik Gereksinimleri)

### SEC-001 — Local-First Sensor Data (Yerel Öncelikli Sensör Verisi)

Sensor measurements and navigation session data shall be stored locally by default. *(Sensör ölçümleri ve navigasyon oturumu verileri varsayılan olarak yerel olarak saklanacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### SEC-002 — No Mandatory Cloud Upload (Zorunlu Bulut Yüklemesi Olmaması)

NAVGUARD shall not automatically upload experimental sensor or location data to a cloud service as part of core operation. *(NAVGUARD temel çalışma kapsamında deneysel sensör veya konum verilerini otomatik olarak bir bulut hizmetine yüklemeyecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### SEC-003 — Explicit Export (Açık Dışa Aktarma)

Experimental data export shall occur only through an explicit user or developer action. *(Deneysel veri dışa aktarma yalnızca açık bir kullanıcı veya geliştirici işlemiyle gerçekleşecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

---

# 42. Privacy Requirements (Gizlilik Gereksinimleri)

### SEC-004 — Location Data Awareness (Konum Verisi Farkındalığı)

The application shall treat recorded geographic positions as potentially sensitive experimental data. *(Uygulama kaydedilen coğrafi konumları potansiyel olarak hassas deneysel veri olarak ele alacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### SEC-005 — Camera Frame Retention (Kamera Karesi Saklama)

NAVGUARD shall not retain ARCore camera frames by default unless a specific research experiment requires them and the behavior is documented. *(NAVGUARD belirli bir araştırma deneyi gerektirmediği ve davranış dokümante edilmediği sürece ARCore kamera karelerini varsayılan olarak saklamayacaktır.)*

**Priority:** TARGET *(Öncelik: TARGET)*

### SEC-006 — Minimum Required Permissions (Minimum Gerekli İzinler)

The application shall request only permissions justified by active NAVGUARD functionality. *(Uygulama yalnızca aktif NAVGUARD işlevleri tarafından gerekçelendirilen izinleri isteyecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

---

# 43. Platform Requirements (Platform Gereksinimleri)

### NFR-007 — Android-Only Support (Yalnızca Android Desteği)

The defined project shall support Android only. *(Tanımlanan proje yalnızca Android’i destekleyecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### NFR-008 — Primary Device Compatibility (Birincil Cihaz Uyumluluğu)

The final application shall run on the project’s Xiaomi Redmi Note 9 Pro test device. *(Nihai uygulama projenin Xiaomi Redmi Note 9 Pro test cihazında çalışacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### NFR-009 — Flutter Application Layer (Flutter Uygulama Katmanı)

The primary application and user-interface layer shall be implemented with Flutter unless a later documented technical decision replaces this requirement. *(Bir sonraki dokümante edilmiş teknik karar bu gereksinimi değiştirmediği sürece temel uygulama ve kullanıcı arayüzü katmanı Flutter ile geliştirilecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### NFR-010 — Native Android Integration (Native Android Entegrasyonu)

Android-specific functionality may be implemented in Kotlin when Flutter plugins do not provide sufficient timing, sensor, ARCore, or platform control. *(Flutter eklentileri yeterli zamanlama, sensör, ARCore veya platform kontrolü sağlamadığında Android’e özgü işlevler Kotlin ile geliştirilebilir.)*

**Priority:** TARGET *(Öncelik: TARGET)*

---

# 44. Maintainability Requirements (Sürdürülebilirlik Gereksinimleri)

### NFR-011 — Modular Architecture (Modüler Mimari)

The application shall separate sensor acquisition, navigation algorithms, AI inference, data storage, experiment management, and user-interface responsibilities into maintainable modules. *(Uygulama sensör veri toplama, navigasyon algoritmaları, yapay zekâ çıkarımı, veri depolama, deney yönetimi ve kullanıcı arayüzü sorumluluklarını sürdürülebilir modüllere ayıracaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### NFR-012 — Replaceable Estimator Components (Değiştirilebilir Tahmin Motoru Bileşenleri)

Navigation components should be replaceable or disableable to support experimental comparisons. *(Navigasyon bileşenleri deneysel karşılaştırmaları desteklemek için değiştirilebilir veya devre dışı bırakılabilir olmalıdır.)*

**Priority:** TARGET *(Öncelik: TARGET)*

### NFR-013 — Configuration Centralization (Yapılandırma Merkezileştirme)

Experiment-sensitive constants and algorithm parameters should be stored in controlled configuration structures rather than scattered through application code. *(Deneye duyarlı sabitler ve algoritma parametreleri uygulama koduna dağılmak yerine kontrollü yapılandırma yapılarında saklanmalıdır.)*

**Priority:** TARGET *(Öncelik: TARGET)*

---

# 45. Reproducibility Requirements (Tekrarlanabilirlik Gereksinimleri)

### TEST-015 — Algorithm Version Traceability (Algoritma Sürümü İzlenebilirliği)

Evaluation sessions shall record the estimator configuration or version used to generate the results. *(Değerlendirme oturumları sonuçları üretmek için kullanılan tahmin motoru yapılandırmasını veya sürümünü kaydedecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### TEST-016 — AI Model Version Traceability (Yapay Zekâ Model Sürümü İzlenebilirliği)

Sessions using AI inference shall record the model version or identifier. *(Yapay zekâ çıkarımı kullanan oturumlar model sürümünü veya tanımlayıcısını kaydedecektir.)*

**Priority:** MUST *(Öncelik: MUST)*

### TEST-017 — Device Baseline Traceability (Cihaz Temel Referansı İzlenebilirliği)

Final benchmark sessions shall be traceable to the frozen device baseline. *(Nihai benchmark oturumları sabitlenmiş cihaz temel referansına kadar izlenebilir olacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

---

# 46. Research Integrity Requirements (Araştırma Bütünlüğü Gereksinimleri)

### TEST-018 — No Ground Truth Leakage (Gerçek Referans Sızıntısı Olmaması)

No ground-truth GNSS data shall be used by the GNSS-denied estimator during formal evaluation. *(Resmî değerlendirme sırasında GNSS kesintili tahmin motoru tarafından hiçbir gerçek referans GNSS verisi kullanılmayacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### TEST-019 — Failed Session Recording (Başarısız Oturum Kaydı)

Technically valid but poor-performing sessions shall not be removed solely because they reduce reported performance. *(Teknik olarak geçerli ancak düşük performans gösteren oturumlar yalnızca raporlanan performansı düşürdükleri için çıkarılmayacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

### TEST-020 — Exclusion Reason Documentation (Hariç Tutma Nedeni Dokümantasyonu)

Any session excluded from final analysis shall have a documented technical reason. *(Nihai analizden çıkarılan herhangi bir oturum dokümante edilmiş teknik bir nedene sahip olacaktır.)*

**Priority:** MUST *(Öncelik: MUST)*

---

# 47. Minimum Project Acceptance Requirements (Minimum Proje Kabul Gereksinimleri)

The minimum accepted NAVGUARD system shall run successfully on the Redmi Note 9 Pro. *(Minimum kabul edilen NAVGUARD sistemi Redmi Note 9 Pro üzerinde başarıyla çalışacaktır.)*

The minimum system shall acquire and log accelerometer, gyroscope, magnetometer, and GNSS data. *(Minimum sistem ivmeölçer, jiroskop, manyetometre ve GNSS verilerini elde edecek ve kaydedecektir.)*

The minimum system shall implement a working PDR estimator. *(Minimum sistem çalışan bir PDR tahmin motoru geliştirecektir.)*

The minimum system shall provide software-controlled GNSS-denied evaluation. *(Minimum sistem yazılım kontrollü GNSS kesintili değerlendirme sağlayacaktır.)*

The minimum system shall record GNSS ground truth without feeding it into the denied estimator. *(Minimum sistem GNSS gerçek referansını kesinti tahmin motoruna vermeden kaydedecektir.)*

The minimum system shall include an evaluated on-device motion classification model. *(Minimum sistem değerlendirilmiş cihaz üzeri bir hareket sınıflandırma modeli içerecektir.)*

The minimum system shall calculate quantitative navigation error metrics. *(Minimum sistem nicel navigasyon hata metriklerini hesaplayacaktır.)*

---

# 48. Target Project Acceptance Requirements (Hedef Proje Kabul Gereksinimleri)

The target NAVGUARD system shall include improved heading estimation. *(Hedef NAVGUARD sistemi geliştirilmiş yön tahmini içerecektir.)*

The target system shall integrate ARCore relative movement information if the Device Capability Audit validates its runtime suitability. *(Hedef sistem, Cihaz Yetenek Denetimi çalışma zamanı uygunluğunu doğrularsa ARCore göreli hareket bilgisini entegre edecektir.)*

The target system shall implement multi-source sensor fusion. *(Hedef sistem çok kaynaklı sensör füzyonu geliştirecektir.)*

The target system shall include a position confidence or uncertainty representation. *(Hedef sistem bir konum güveni veya belirsizlik temsili içerecektir.)*

The target system shall demonstrate measurable improvement relative to the PDR-only baseline during final matched evaluation. *(Hedef sistem nihai eşleştirilmiş değerlendirme sırasında yalnızca PDR kullanan temel yaklaşıma göre ölçülebilir iyileşme gösterecektir.)*

---

# 49. Optional Requirements (İsteğe Bağlı Gereksinimler)

### OPT-001 — Raw GNSS Diagnostics (Ham GNSS Tanısı)

The application may collect raw GNSS diagnostic information if supported by the device and useful to the research. *(Uygulama cihaz tarafından desteklenir ve araştırma için yararlı olursa ham GNSS tanısal bilgisi toplayabilir.)*

### OPT-002 — Native Step Counter Comparison (Native Adım Sayacı Karşılaştırması)

The project may compare NAVGUARD step detection with Android’s native step counter or detector when available. *(Proje mevcut olduğunda NAVGUARD adım tespitini Android’in native adım sayacı veya algılayıcısıyla karşılaştırabilir.)*

### OPT-003 — Offline Map Package (Çevrimdışı Harita Paketi)

The application may provide fully offline map visualization if implementation time permits. *(Uygulama geliştirme süresi izin verirse tamamen çevrimdışı harita görselleştirmesi sağlayabilir.)*

### OPT-004 — Fault Injection (Arıza Enjeksiyonu)

The research build may include controlled sensor-degradation simulation for confidence-engine testing. *(Araştırma build’i güven motoru testi için kontrollü sensör bozulma simülasyonu içerebilir.)*

---

# 50. Explicitly Out-of-Scope Requirements (Açıkça Kapsam Dışı Gereksinimler)

NAVGUARD shall not be required to provide certified aviation-grade navigation. *(NAVGUARD’ın sertifikalı havacılık seviye navigasyon sağlaması gerekmeyecektir.)*

NAVGUARD shall not be required to provide military-grade inertial navigation accuracy. *(NAVGUARD’ın askeri seviye ataletsel navigasyon doğruluğu sağlaması gerekmeyecektir.)*

NAVGUARD shall not be required to operate an unmanned aerial vehicle, weapon system, or physical autonomous platform. *(NAVGUARD’ın bir insansız hava aracını, silah sistemini veya fiziksel otonom platformu çalıştırması gerekmeyecektir.)*

NAVGUARD shall not be required to intentionally interfere with or disrupt real GNSS signals. *(NAVGUARD’ın gerçek GNSS sinyallerine kasıtlı olarak müdahale etmesi veya bunları bozması gerekmeyecektir.)*

NAVGUARD shall not be required to support iOS. *(NAVGUARD’ın iOS’u desteklemesi gerekmeyecektir.)*

NAVGUARD shall not require external high-grade IMU or GNSS hardware. *(NAVGUARD harici yüksek seviye IMU veya GNSS donanımı gerektirmeyecektir.)*

NAVGUARD shall not require a cloud backend for its core navigation algorithm. *(NAVGUARD temel navigasyon algoritması için bir bulut backend’i gerektirmeyecektir.)*

---

# 51. Requirement Verification Methods (Gereksinim Doğrulama Yöntemleri)

Each mandatory requirement shall be verified using at least one defined verification method. *(Her zorunlu gereksinim en az bir tanımlı doğrulama yöntemi kullanılarak doğrulanacaktır.)*

### Inspection (İnceleme)

Inspection verifies source code, configuration, documentation, or stored output without requiring a dynamic test. *(İnceleme, dinamik test gerektirmeden kaynak kodu, yapılandırmayı, dokümantasyonu veya saklanan çıktıyı doğrular.)*

### Functional Test (Fonksiyonel Test)

Functional testing verifies that a required feature behaves as specified during application execution. *(Fonksiyonel test, gerekli bir özelliğin uygulama çalışması sırasında belirtildiği şekilde davrandığını doğrular.)*

### Measurement (Ölçüm)

Measurement verifies a quantitative requirement using recorded numerical evidence. *(Ölçüm, nicel bir gereksinimi kaydedilmiş sayısal kanıt kullanarak doğrular.)*

### Field Experiment (Saha Deneyi)

A field experiment verifies navigation behavior under defined physical walking conditions. *(Saha deneyi, tanımlanmış fiziksel yürüyüş koşulları altında navigasyon davranışını doğrular.)*

### Offline Analysis (Çevrimdışı Analiz)

Offline analysis verifies algorithm or AI performance using stored experimental data. *(Çevrimdışı analiz, saklanan deneysel verileri kullanarak algoritma veya yapay zekâ performansını doğrular.)*

---

# 52. High-Level Verification Matrix (Üst Seviye Doğrulama Matrisi)

| Requirement Area (Gereksinim Alanı) | Primary Verification Method (Temel Doğrulama Yöntemi) |
| --- | --- |
| Sensor Acquisition *(Sensör Veri Toplama)* | Device Test + Logged Data *(Cihaz Testi + Kaydedilmiş Veri)* |
| GNSS Isolation *(GNSS İzolasyonu)* | Architecture Inspection + Evaluation Test *(Mimari İnceleme + Değerlendirme Testi)* |
| PDR | Replay Test + Field Experiment *(Yeniden Oynatma Testi + Saha Deneyi)* |
| Motion AI *(Hareket Yapay Zekâsı)* | Held-Out Dataset Evaluation *(Ayrılmış Veri Seti Değerlendirmesi)* |
| On-Device AI *(Cihaz Üzeri Yapay Zekâ)* | Physical Device Runtime Test *(Fiziksel Cihaz Çalışma Zamanı Testi)* |
| ARCore | Physical Device Tracking Test *(Fiziksel Cihaz Takip Testi)* |
| Sensor Fusion *(Sensör Füzyonu)* | Replay Comparison + Field Experiment *(Yeniden Oynatma Karşılaştırması + Saha Deneyi)* |
| Offline Operation *(Çevrimdışı Çalışma)* | Network-Disabled Test *(Ağ Devre Dışı Testi)* |
| Performance *(Performans)* | Runtime Measurement *(Çalışma Zamanı Ölçümü)* |
| Data Integrity *(Veri Bütünlüğü)* | Export and Replay Validation *(Dışa Aktarma ve Yeniden Oynatma Doğrulaması)* |

---

# 53. Requirements Traceability Rule (Gereksinim İzlenebilirlik Kuralı)

Every MUST requirement shall eventually be mapped to an implementation module and at least one test case. *(Her MUST gereksinimi sonunda bir uygulama modülüne ve en az bir test senaryosuna eşlenecektir.)*

TARGET requirements shall also be traced if they are included in the frozen final architecture. *(TARGET gereksinimleri de sabitlenmiş nihai mimariye dahil edilirlerse izlenecektir.)*

Requirements that are removed or modified shall not be deleted silently. *(Kaldırılan veya değiştirilen gereksinimler sessizce silinmeyecektir.)*

Any approved requirement change shall be recorded in the Technical Decisions and Change Log. *(Onaylanan herhangi bir gereksinim değişikliği Teknik Kararlar ve Değişiklik Günlüğünde kaydedilecektir.)*

---

# 54. Requirement Freeze Policy (Gereksinim Sabitleme Politikası)

The current SRS is considered a pre-development baseline rather than an immutable final document. *(Mevcut SRS değiştirilemez nihai bir doküman yerine geliştirme öncesi temel referans olarak kabul edilir.)*

Hardware-dependent requirements may be refined after the Device Capability Audit. *(Donanıma bağlı gereksinimler Cihaz Yetenek Denetiminden sonra iyileştirilebilir.)*

Algorithm-specific requirements may be refined after early prototype experiments provide measured evidence. *(Algoritmaya özgü gereksinimler ilk prototip deneyleri ölçülmüş kanıt sağladıktan sonra iyileştirilebilir.)*

The SRS shall be frozen before final system validation and benchmark testing begins. *(SRS nihai sistem doğrulaması ve benchmark testleri başlamadan önce sabitlenecektir.)*

Requirements shall not be changed after final benchmark results are observed merely to make the system appear successful. *(Gereksinimler nihai benchmark sonuçları görüldükten sonra yalnızca sistemi başarılı göstermek amacıyla değiştirilmeyecektir.)*

---

# 55. Current Requirement Summary (Mevcut Gereksinim Özeti)

**Target Platform:** Android Only *(Hedef Platform: Yalnızca Android)*

**Primary Device:** Xiaomi Redmi Note 9 Pro *(Birincil Cihaz: Xiaomi Redmi Note 9 Pro)*

**Minimum Navigation Core:** GNSS Initialization + Sensor Acquisition + Step Detection + Heading + PDR + Evaluation *(Minimum Navigasyon Çekirdeği: GNSS Başlatma + Sensör Veri Toplama + Adım Tespiti + Yön + PDR + Değerlendirme)*

**Mandatory AI Capability:** On-Device Motion Classification *(Zorunlu Yapay Zekâ Yeteneği: Cihaz Üzeri Hareket Sınıflandırması)*

**Target Advanced Navigation:** ARCore + Sensor Confidence + Multi-Source Fusion + EKF *(Hedef Gelişmiş Navigasyon: ARCore + Sensör Güveni + Çok Kaynaklı Füzyon + EKF)*

**Core Runtime Mode:** Offline-Capable *(Temel Çalışma Modu: Çevrimdışı Çalışabilir)*

**Primary Evaluation Method:** Recorded GNSS Ground Truth Versus GNSS-Denied Estimated Trajectory *(Birincil Değerlendirme Yöntemi: Kaydedilmiş GNSS Gerçek Referansı ile GNSS Kesintili Tahmini Rota Karşılaştırması)*

---

# 56. SRS Acceptance Statement (SRS Kabul Bildirimi)

**The NAVGUARD implementation shall be considered compliant with this SRS when all applicable MUST requirements have passed their defined verification activities and all TARGET requirements included in the frozen final architecture have either passed or received a formally documented limitation decision.** *(NAVGUARD uygulaması, uygulanabilir tüm MUST gereksinimleri tanımlanan doğrulama faaliyetlerini geçtiğinde ve sabitlenmiş nihai mimariye dahil edilen tüm TARGET gereksinimleri geçtiğinde veya resmî olarak dokümante edilmiş bir sınırlama kararı aldığında bu SRS ile uyumlu kabul edilecektir.)*

**A working user interface alone shall not constitute SRS compliance unless the sensor, navigation, AI, data integrity, experimental, and offline-operation requirements are also verified.** *(Yalnızca çalışan bir kullanıcı arayüzü; sensör, navigasyon, yapay zekâ, veri bütünlüğü, deneysel ve çevrimdışı çalışma gereksinimleri de doğrulanmadıkça SRS uyumluluğu oluşturmayacaktır.)*

---

# 57. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development Baseline Completed *(Doküman Durumu: Geliştirme Öncesi Temel Referans Tamamlandı)*

**Requirement Freeze Status:** Not Frozen *(Gereksinim Sabitleme Durumu: Sabitlenmedi)*

**Device-Dependent Requirements:** Pending Device Capability Audit *(Cihaza Bağlı Gereksinimler: Cihaz Yetenek Denetimi Bekleniyor)*

**Minimum Project Requirements:** Defined *(Minimum Proje Gereksinimleri: Tanımlandı)*

**Target Project Requirements:** Defined *(Hedef Proje Gereksinimleri: Tanımlandı)*

**Optional Requirements:** Defined *(İsteğe Bağlı Gereksinimler: Tanımlandı)*

**Next Documentation Item:** 08 — System Architecture *(Sonraki Dokümantasyon Öğesi: 08 — Sistem Mimarisi)*