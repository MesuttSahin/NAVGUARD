# 00 — Documentation Home (Dokümantasyon Ana Sayfası)

## NAVGUARD

**AI-Assisted GNSS-Denied Mobile Navigation and Sensor Fusion System** *(Yapay Zekâ Destekli GNSS Kesintili Mobil Navigasyon ve Sensör Füzyon Sistemi)*

---

## 1. Documentation Purpose (Dokümantasyonun Amacı)

This documentation serves as the central technical and project management reference for the NAVGUARD project. *(Bu dokümantasyon, NAVGUARD projesi için merkezi teknik ve proje yönetimi referansı olarak hizmet eder.)*

It defines the project requirements, system architecture, navigation algorithms, artificial intelligence components, data collection procedures, testing methodology, development roadmap, and final evaluation process. *(Proje gereksinimlerini, sistem mimarisini, navigasyon algoritmalarını, yapay zekâ bileşenlerini, veri toplama prosedürlerini, test metodolojisini, geliştirme yol haritasını ve nihai değerlendirme sürecini tanımlar.)*

The documentation is intended to be completed and maintained throughout the entire development lifecycle of NAVGUARD. *(Dokümantasyonun NAVGUARD'ın tüm geliştirme yaşam döngüsü boyunca tamamlanması ve güncel tutulması amaçlanmaktadır.)*

All major technical decisions, architectural changes, experimental results, and implementation constraints will be recorded within this documentation structure. *(Tüm önemli teknik kararlar, mimari değişiklikler, deneysel sonuçlar ve uygulama kısıtları bu dokümantasyon yapısı içerisinde kaydedilecektir.)*

---

## 2. Project Summary (Proje Özeti)

NAVGUARD is an Android-based mobile navigation research prototype designed to estimate a user's position when GNSS information becomes unavailable or is intentionally excluded from the navigation process. *(NAVGUARD, GNSS bilgisinin kullanılamaz hale geldiği veya navigasyon sürecinden bilinçli olarak çıkarıldığı durumlarda kullanıcının konumunu tahmin etmek için tasarlanmış Android tabanlı bir mobil navigasyon araştırma prototipidir.)*

The system will use the smartphone's inertial sensors, orientation information, pedestrian dead reckoning, visual-inertial tracking, sensor fusion, and on-device artificial intelligence to maintain approximate position continuity after GNSS loss. *(Sistem, GNSS kaybından sonra yaklaşık konum sürekliliğini korumak için akıllı telefonun ataletsel sensörlerini, yönelim bilgisini, yaya ölü hesaplama yöntemini, görsel-ataletsel takibi, sensör füzyonunu ve cihaz üzerinde çalışan yapay zekâyı kullanacaktır.)*

The project will focus on pedestrian navigation and will be developed exclusively for Android devices. *(Proje yaya navigasyonuna odaklanacak ve yalnızca Android cihazlar için geliştirilecektir.)*

The primary development and test device will be the Xiaomi Redmi Note 9 Pro. *(Birincil geliştirme ve test cihazı Xiaomi Redmi Note 9 Pro olacaktır.)*

The project is planned to be completed within 24 business days as a functional proof-of-concept and research prototype. *(Projenin 24 iş günü içerisinde çalışan bir kavram kanıtlama ve araştırma prototipi olarak tamamlanması planlanmaktadır.)*

---

## 3. Core Project Goal (Temel Proje Hedefi)

The primary goal of NAVGUARD is to investigate whether a standard Android smartphone can maintain useful short-term position estimates after GNSS loss by combining multiple onboard sensors and artificial intelligence techniques. *(NAVGUARD'ın temel amacı, standart bir Android akıllı telefonun birden fazla cihaz içi sensörü ve yapay zekâ tekniklerini birleştirerek GNSS kaybından sonra kullanışlı kısa süreli konum tahminlerini sürdürebilip sürdüremeyeceğini araştırmaktır.)*

The system will not attempt to replace GNSS permanently or provide military-grade navigation accuracy. *(Sistem, GNSS'in kalıcı olarak yerini almayı veya askeri seviye navigasyon doğruluğu sağlamayı amaçlamayacaktır.)*

Instead, the project will measure how effectively sensor fusion and AI-assisted motion estimation can reduce position drift compared with simpler dead reckoning approaches. *(Bunun yerine proje, sensör füzyonu ve yapay zekâ destekli hareket tahmininin daha basit ölü hesaplama yaklaşımlarına kıyasla konum sürüklenmesini ne ölçüde azaltabildiğini ölçecektir.)*

---

## 4. Primary Project Components (Temel Proje Bileşenleri)

- **Android Mobile Application** *(Android Mobil Uygulaması)*
- **GNSS Positioning and Ground Truth Recording** *(GNSS Konumlandırma ve Gerçek Referans Kaydı)*
- **Accelerometer Data Processing** *(İvmeölçer Veri İşleme)*
- **Gyroscope Data Processing** *(Jiroskop Veri İşleme)*
- **Magnetometer and Heading Estimation** *(Manyetometre ve Yön Tahmini)*
- **Pedestrian Dead Reckoning — PDR** *(Yaya Ölü Hesaplama — PDR)*
- **Step Detection** *(Adım Tespiti)*
- **Step Length Estimation** *(Adım Uzunluğu Tahmini)*
- **ARCore Visual-Inertial Tracking** *(ARCore Görsel-Ataletsel Takip)*
- **Sensor Confidence Evaluation** *(Sensör Güvenilirlik Değerlendirmesi)*
- **Sensor Fusion** *(Sensör Füzyonu)*
- **Extended Kalman Filter — EKF** *(Genişletilmiş Kalman Filtresi — EKF)*
- **Motion Classification with Artificial Intelligence** *(Yapay Zekâ ile Hareket Sınıflandırma)*
- **On-Device Edge AI Inference** *(Cihaz Üzerinde Edge AI Çıkarımı)*
- **Position Uncertainty Estimation** *(Konum Belirsizliği Tahmini)*
- **GNSS-Denied Simulation Mode** *(GNSS Kesinti Simülasyon Modu)*
- **Field Testing and Experimental Evaluation** *(Saha Testleri ve Deneysel Değerlendirme)*

---

## 5. Target Platform (Hedef Platform)

| Item (Öğe) | Definition (Tanım) |
| --- | --- |
| Platform (Platform) | Android |
| Primary Device (Birincil Cihaz) | Xiaomi Redmi Note 9 Pro |
| Mobile Framework (Mobil Framework) | Flutter |
| Native Android Layer (Native Android Katmanı) | Kotlin |
| Machine Learning Development (Makine Öğrenmesi Geliştirme) | Python |
| On-Device AI (Cihaz Üzerinde Yapay Zekâ) | TensorFlow Lite |
| Visual-Inertial Tracking (Görsel-Ataletsel Takip) | ARCore |
| Primary Navigation Type (Temel Navigasyon Türü) | Pedestrian Navigation *(Yaya Navigasyonu)* |
| Internet Requirement for Core Navigation (Temel Navigasyon İçin İnternet Gereksinimi) | Not Required *(Gerekli Değil)* |
| Development Duration (Geliştirme Süresi) | 24 Business Days *(24 İş Günü)* |

---

## 6. High-Level System Flow (Üst Seviye Sistem Akışı)

**Step 1 — GNSS Initialization** *(Adım 1 — GNSS Başlatma)*

The application obtains a reliable GNSS position before the GNSS-denied test begins. *(Uygulama, GNSS kesinti testi başlamadan önce güvenilir bir GNSS konumu elde eder.)*

↓

**Step 2 — Sensor Calibration** *(Adım 2 — Sensör Kalibrasyonu)*

The system verifies the availability and initial stability of the required sensors. *(Sistem, gerekli sensörlerin kullanılabilirliğini ve başlangıç kararlılığını doğrular.)*

↓

**Step 3 — GNSS-Denied Mode** *(Adım 3 — GNSS Kesinti Modu)*

GNSS measurements are removed from the navigation estimator while they may continue to be recorded separately for evaluation. *(GNSS ölçümleri navigasyon tahmin motorundan çıkarılırken değerlendirme amacıyla ayrı olarak kaydedilmeye devam edilebilir.)*

↓

**Step 4 — Motion Estimation** *(Adım 4 — Hareket Tahmini)*

The system detects user motion, steps, step length, and heading using smartphone sensor data and artificial intelligence. *(Sistem, akıllı telefon sensör verilerini ve yapay zekâyı kullanarak kullanıcı hareketini, adımlarını, adım uzunluğunu ve yönünü tespit eder.)*

↓

**Step 5 — Visual-Inertial Tracking** *(Adım 5 — Görsel-Ataletsel Takip)*

ARCore provides relative movement and pose information when visual tracking is available. *(ARCore, görsel takip kullanılabilir olduğunda göreli hareket ve poz bilgisi sağlar.)*

↓

**Step 6 — Sensor Fusion** *(Adım 6 — Sensör Füzyonu)*

PDR, heading, IMU, and ARCore measurements are combined to produce a more stable position estimate. *(PDR, yön, IMU ve ARCore ölçümleri daha kararlı bir konum tahmini üretmek için birleştirilir.)*

↓

**Step 7 — Position and Uncertainty Output** *(Adım 7 — Konum ve Belirsizlik Çıktısı)*

The application displays the estimated position, route, confidence level, and estimated uncertainty. *(Uygulama tahmini konumu, rotayı, güven seviyesini ve tahmini belirsizliği gösterir.)*

↓

**Step 8 — Experimental Evaluation** *(Adım 8 — Deneysel Değerlendirme)*

The estimated route is compared with the GNSS ground truth after the test session. *(Tahmini rota, test oturumundan sonra GNSS gerçek referans verisiyle karşılaştırılır.)*

---

## 7. Planned Navigation Approaches (Planlanan Navigasyon Yaklaşımları)

The project will evaluate multiple navigation configurations instead of relying on a single algorithm. *(Proje, tek bir algoritmaya bağlı kalmak yerine birden fazla navigasyon yapılandırmasını değerlendirecektir.)*

### Configuration A — PDR Only (Yapılandırma A — Yalnızca PDR)

This configuration will provide the simplest baseline for GNSS-denied pedestrian navigation. *(Bu yapılandırma, GNSS kesintili yaya navigasyonu için en basit temel referansı sağlayacaktır.)*

### Configuration B — PDR + Heading Fusion (Yapılandırma B — PDR + Yön Füzyonu)

This configuration will combine step-based displacement with improved heading estimation. *(Bu yapılandırma, adım tabanlı yer değiştirmeyi geliştirilmiş yön tahminiyle birleştirecektir.)*

### Configuration C — PDR + ARCore (Yapılandırma C — PDR + ARCore)

This configuration will supplement pedestrian dead reckoning with visual-inertial relative movement information. *(Bu yapılandırma, yaya ölü hesaplama yöntemini görsel-ataletsel göreli hareket bilgisiyle destekleyecektir.)*

### Configuration D — NAVGUARD AI Fusion (Yapılandırma D — NAVGUARD AI Füzyonu)

This configuration will combine PDR, visual-inertial tracking, sensor confidence, sensor fusion, and AI-assisted motion estimation. *(Bu yapılandırma, PDR, görsel-ataletsel takip, sensör güvenilirliği, sensör füzyonu ve yapay zekâ destekli hareket tahminini birleştirecektir.)*

---

## 8. Artificial Intelligence Overview (Yapay Zekâ Genel Bakışı)

NAVGUARD will use artificial intelligence as an active component of the navigation system rather than as a separate demonstration feature. *(NAVGUARD, yapay zekâyı ayrı bir gösterim özelliği yerine navigasyon sisteminin aktif bir bileşeni olarak kullanacaktır.)*

The primary AI model is planned to be a lightweight 1D Convolutional Neural Network for motion classification. *(Ana yapay zekâ modelinin hareket sınıflandırması için hafif bir 1 Boyutlu Evrişimsel Sinir Ağı olması planlanmaktadır.)*

The motion classification model will classify sensor windows into motion states such as stationary, walking, running, and turning. *(Hareket sınıflandırma modeli, sensör pencerelerini sabit durma, yürüme, koşma ve dönme gibi hareket durumlarına sınıflandıracaktır.)*

A secondary machine learning model may be used to estimate dynamic step length based on sensor characteristics and motion state. *(İkincil bir makine öğrenmesi modeli, sensör özelliklerine ve hareket durumuna bağlı olarak dinamik adım uzunluğunu tahmin etmek için kullanılabilir.)*

The trained models will be optimized for on-device inference so that the core AI functions can operate without an internet connection. *(Eğitilen modeller, temel yapay zekâ işlevlerinin internet bağlantısı olmadan çalışabilmesi için cihaz üzeri çıkarıma optimize edilecektir.)*

---

## 9. Primary Research Question (Ana Araştırma Sorusu)

**Can AI-assisted pedestrian dead reckoning and visual-inertial sensor fusion reduce position drift during GNSS outages on a standard Android smartphone compared with conventional PDR approaches?** *(Yapay zekâ destekli yaya ölü hesaplama ve görsel-ataletsel sensör füzyonu, standart bir Android akıllı telefonda GNSS kesintileri sırasında geleneksel PDR yaklaşımlarına kıyasla konum sürüklenmesini azaltabilir mi?)*

---

## 10. Primary Evaluation Metrics (Temel Değerlendirme Metrikleri)

- **Mean Position Error** *(Ortalama Konum Hatası)*
- **Root Mean Square Error — RMSE** *(Kök Ortalama Kare Hata — RMSE)*
- **Final Position Error** *(Nihai Konum Hatası)*
- **Drift per Minute** *(Dakika Başına Sürüklenme)*
- **Drift Relative to Travelled Distance** *(Kat Edilen Mesafeye Göre Sürüklenme)*
- **Heading Mean Absolute Error** *(Yön Ortalama Mutlak Hatası)*
- **Step Detection Accuracy** *(Adım Tespit Doğruluğu)*
- **Step Length Estimation Error** *(Adım Uzunluğu Tahmin Hatası)*
- **Motion Classification Accuracy** *(Hareket Sınıflandırma Doğruluğu)*
- **Motion Classification F1 Score** *(Hareket Sınıflandırma F1 Skoru)*
- **On-Device AI Inference Latency** *(Cihaz Üzerinde Yapay Zekâ Çıkarım Gecikmesi)*
- **ARCore Tracking Availability** *(ARCore Takip Kullanılabilirliği)*
- **Battery Consumption** *(Batarya Tüketimi)*
- **CPU and Memory Usage** *(CPU ve Bellek Kullanımı)*

---

## 11. Development Principles (Geliştirme İlkeleri)

The project will follow an offline-first architecture for all core navigation functions. *(Proje, tüm temel navigasyon işlevleri için çevrimdışı öncelikli bir mimari izleyecektir.)*

The application will be developed exclusively for Android. *(Uygulama yalnızca Android için geliştirilecektir.)*

The Xiaomi Redmi Note 9 Pro will be treated as the primary hardware baseline during development and testing. *(Xiaomi Redmi Note 9 Pro, geliştirme ve test sürecinde birincil donanım referansı olarak ele alınacaktır.)*

The project will use real sensor measurements collected from the target device whenever possible. *(Proje, mümkün olduğunda hedef cihazdan toplanan gerçek sensör ölçümlerini kullanacaktır.)*

The system will be designed modularly so that failure or removal of an advanced component does not prevent the baseline navigation system from operating. *(Sistem, gelişmiş bir bileşenin başarısız olması veya çıkarılması durumunda temel navigasyon sisteminin çalışmasını engellemeyecek şekilde modüler olarak tasarlanacaktır.)*

The project will prioritize measurable experimental results over visual complexity or unnecessary application features. *(Proje, görsel karmaşıklık veya gereksiz uygulama özellikleri yerine ölçülebilir deneysel sonuçlara öncelik verecektir.)*

Every major implementation decision will be documented before or during implementation. *(Her önemli uygulama kararı, geliştirmeden önce veya geliştirme sırasında dokümante edilecektir.)*

---

## 12. Documentation Map (Dokümantasyon Haritası)

### Project Foundation (Proje Temeli)

- **01 — Project Overview** *(Proje Genel Bakışı)*
- **02 — Problem Definition & Motivation** *(Problem Tanımı ve Motivasyon)*
- **03 — Project Scope & Boundaries** *(Proje Kapsamı ve Sınırları)*
- **04 — Research Questions & Success Criteria** *(Araştırma Soruları ve Başarı Kriterleri)*
- **05 — Target Platform & Device Baseline** *(Hedef Platform ve Cihaz Temel Referansı)*
- **06 — Device Capability Audit** *(Cihaz Yetenek Denetimi)*
- **07 — Software Requirements Specification — SRS** *(Yazılım Gereksinimleri Şartnamesi — SRS)*

### System Design (Sistem Tasarımı)

- **08 — System Architecture** *(Sistem Mimarisi)*
- **09 — Technology Stack** *(Teknoloji Yığını)*
- **10 — Android & Mobile Architecture** *(Android ve Mobil Mimari)*
- **11 — Navigation Modes & State Machine** *(Navigasyon Modları ve Durum Makinesi)*

### Sensors and Navigation (Sensörler ve Navigasyon)

- **12 — Sensor & Data Acquisition System** *(Sensör ve Veri Toplama Sistemi)*
- **13 — Sensor Timing, Synchronization & Preprocessing** *(Sensör Zamanlaması, Senkronizasyonu ve Ön İşleme)*
- **14 — Coordinate Systems & Mathematical Foundations** *(Koordinat Sistemleri ve Matematiksel Temeller)*
- **15 — GNSS Subsystem** *(GNSS Alt Sistemi)*
- **16 — Pedestrian Dead Reckoning — PDR** *(Yaya Ölü Hesaplama — PDR)*
- **17 — Step Detection System** *(Adım Tespit Sistemi)*
- **18 — Heading Estimation System** *(Yön Tahmin Sistemi)*
- **19 — ARCore Visual-Inertial Tracking** *(ARCore Görsel-Ataletsel Takip)*
- **20 — Sensor Confidence & Quality Engine** *(Sensör Güven ve Kalite Motoru)*
- **21 — Sensor Fusion & Extended Kalman Filter** *(Sensör Füzyonu ve Genişletilmiş Kalman Filtresi)*

### Artificial Intelligence (Yapay Zekâ)

- **22 — Artificial Intelligence System** *(Yapay Zekâ Sistemi)*
- **23 — Motion Classification Model** *(Hareket Sınıflandırma Modeli)*
- **24 — Step Length Estimation Model** *(Adım Uzunluğu Tahmin Modeli)*
- **25 — Dataset Collection & Labeling Plan** *(Veri Seti Toplama ve Etiketleme Planı)*
- **26 — Machine Learning Training & Evaluation** *(Makine Öğrenmesi Eğitimi ve Değerlendirme)*
- **27 — On-Device Edge AI Deployment** *(Cihaz Üzerinde Edge AI Dağıtımı)*

### Position, Data and Application (Konum, Veri ve Uygulama)

- **28 — Position Estimation & Uncertainty Engine** *(Konum Tahmini ve Belirsizlik Motoru)*
- **29 — GNSS Recovery & Relocalization** *(GNSS Geri Kazanımı ve Yeniden Konumlandırma)*
- **30 — Data Storage, Logging & Session Management** *(Veri Depolama, Kayıt Tutma ve Oturum Yönetimi)*
- **31 — Mobile UI/UX Specification** *(Mobil UI/UX Şartnamesi)*
- **32 — Permissions, Privacy & Security** *(İzinler, Gizlilik ve Güvenlik)*

### Testing and Evaluation (Test ve Değerlendirme)

- **33 — Testing Strategy** *(Test Stratejisi)*
- **34 — Field Experiment Plan** *(Saha Deney Planı)*
- **35 — Benchmark & Evaluation Metrics** *(Benchmark ve Değerlendirme Metrikleri)*
- **36 — Performance, Battery & Resource Testing** *(Performans, Batarya ve Kaynak Testleri)*
- **37 — Risk Analysis & Fallback Strategy** *(Risk Analizi ve Geri Dönüş Stratejisi)*

### Project Execution and Closure (Proje Yürütme ve Kapanış)

- **38 — 24-Day Development Roadmap** *(24 Günlük Geliştirme Yol Haritası)*
- **39 — Verification, Acceptance Criteria & Definition of Done** *(Doğrulama, Kabul Kriterleri ve Tamamlanma Tanımı)*
- **40 — Demo & Presentation Plan** *(Demo ve Sunum Planı)*
- **41 — Final Results & Experimental Findings** *(Nihai Sonuçlar ve Deneysel Bulgular)*
- **42 — Limitations & Future Work** *(Sınırlamalar ve Gelecek Çalışmalar)*
- **43 — Technical Decisions & Change Log** *(Teknik Kararlar ve Değişiklik Günlüğü)*
- **44 — References & Technical Resources** *(Kaynaklar ve Teknik Referanslar)*

---

## 13. Project Status (Proje Durumu)

**Current Phase:** Flutter Android Bootstrap Completed; Navigation Subsystems Not Started *(Mevcut Aşama: Flutter Android Bootstrap Tamamlandı; Navigasyon Alt Sistemleri Başlamadı)*

**Development Status:** Bootstrap Implemented and Tested; Navigation Subsystems Not Implemented *(Geliştirme Durumu: Bootstrap Uygulandı ve Test Edildi; Navigasyon Alt Sistemleri Uygulanmadı)*

**Documentation Status:** Technical Documentation Baseline Completed *(Dokümantasyon Durumu: Teknik Dokümantasyon Baseline'ı Tamamlandı)*

**Primary Test Device:** Xiaomi Redmi Note 9 Pro *(Birincil Test Cihazı: Xiaomi Redmi Note 9 Pro)*

**Target Platform:** Android Only *(Hedef Platform: Yalnızca Android)*

**Planned Development Duration:** 24 Business Days *(Planlanan Geliştirme Süresi: 24 İş Günü)*

---

## 14. Current Milestone (Mevcut Kilometre Taşı)

The technical documentation baseline and development-environment validation are complete. The Flutter Android bootstrap has passed analysis, tests, debug APK build verification, and a physical run on the Xiaomi Redmi Note 9 Pro. *(Teknik dokümantasyon baseline'ı ve geliştirme ortamı doğrulaması tamamlanmıştır. Flutter Android bootstrap; analiz, test, debug APK build doğrulaması ve Xiaomi Redmi Note 9 Pro üzerinde fiziksel çalıştırma kontrollerini geçmiştir.)*

Physical verification remains partial. SensorManager, GNSS, and ARCore runtime diagnostics and the PDR, Motion AI, Quality Engine, and EKF subsystems have not been implemented; the final benchmark has not been run. *(Fiziksel doğrulama kısmi durumdadır. SensorManager, GNSS ve ARCore runtime tanıları ile PDR, Motion AI, Quality Engine ve EKF alt sistemleri uygulanmamıştır; nihai benchmark çalıştırılmamıştır.)*

---

## 15. Documentation Status Legend (Dokümantasyon Durum Açıklamaları)

- **Not Started** *(Başlanmadı)*
- **Draft** *(Taslak)*
- **Under Review** *(İnceleniyor)*
- **Approved** *(Onaylandı)*
- **Implementation Updated** *(Uygulamaya Göre Güncellendi)*
- **Final** *(Nihai)*

---

## 16. Project Status Legend (Proje Durum Açıklamaları)

- **Planned** *(Planlandı)*
- **Ready** *(Hazır)*
- **In Development** *(Geliştirme Aşamasında)*
- **Testing** *(Test Aşamasında)*
- **Blocked** *(Engellendi)*
- **Completed** *(Tamamlandı)*

---

## 17. Document Control Rule (Doküman Kontrol Kuralı)

This documentation will be treated as the authoritative technical reference for the NAVGUARD project. *(Bu dokümantasyon, NAVGUARD projesinin ana teknik referansı olarak kabul edilecektir.)*

If an implementation decision conflicts with the documented architecture or requirements, the relevant documentation must be reviewed and updated before the change is accepted as part of the project. *(Bir uygulama kararı dokümante edilmiş mimari veya gereksinimlerle çelişirse, değişiklik projenin bir parçası olarak kabul edilmeden önce ilgili dokümantasyon gözden geçirilmeli ve güncellenmelidir.)*

All significant architectural and technical changes will be recorded in **43 — Technical Decisions & Change Log**. *(Tüm önemli mimari ve teknik değişiklikler **43 — Technical Decisions & Change Log** sayfasında kaydedilecektir.)*

---

## 18. Final Project Principle (Nihai Proje İlkesi)

NAVGUARD will be considered successful only if it produces a working Android prototype and measurable experimental evidence showing the behavior of the navigation system during simulated GNSS outages. *(NAVGUARD, yalnızca çalışan bir Android prototipi ve simüle edilmiş GNSS kesintileri sırasında navigasyon sisteminin davranışını gösteren ölçülebilir deneysel kanıtlar ürettiğinde başarılı kabul edilecektir.)*

The objective is not only to build an application, but also to design, implement, test, measure, and document an end-to-end mobile navigation research system. *(Amaç yalnızca bir uygulama geliştirmek değil, aynı zamanda uçtan uca bir mobil navigasyon araştırma sistemini tasarlamak, uygulamak, test etmek, ölçmek ve dokümante etmektir.)*
