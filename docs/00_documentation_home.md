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

### English

**Current Phase:** Stage 10 — Navigation Accuracy v2 Implemented and Statically Validated; Config D-v2 Adaptive Mechanisms Physically Exercised as a Development Prototype; Accuracy Not Validated; Controlled 16-Path Staging Gate Pending

**Development Status:** Flutter Android Bootstrap and Stages 2A–2D Runtime Diagnostics Verified for Their Defined Scopes; Stages 3A–9B Foundations, Evaluation, Benchmark, Software-Defined Denial, Recovery, Config D-v1 Fusion, Fixed-Lag Delayed-Step Replay, and Live Map Implemented; Stage 10 Config D-v2 Adaptive/Heuristic Fusion Implemented and Physically Exercised for Development

**Documentation Status:** Technical Documentation Baseline Completed; Current Status Synchronized Through Stage 10; Combined 16-Path Commit-Readiness Audit Pending

**Primary Test Device:** Xiaomi Redmi Note 9 Pro

**Target Platform:** Android Only

**Planned Development Duration:** 24 Business Days

### Türkçe

**Mevcut Aşama:** Stage 10 — Navigasyon Doğruluğu v2 Uygulandı ve Statik Olarak Doğrulandı; Yapılandırma D-v2 Uyarlanabilir Mekanizmaları Geliştirme Prototipi Olarak Fiziksel Biçimde Çalıştırıldı; Doğruluk Doğrulanmadı; Kontrollü 16-Yolluk Staging Kapısı Bekliyor

**Geliştirme Durumu:** Flutter Android Bootstrap ve Stage 2A–2D Çalışma Zamanı Tanıları Tanımlı Kapsamlarında Doğrulandı; Stage 3A–9B Temelleri, Değerlendirme, Benchmark, Yazılım-Tanımlı Kesinti, Recovery, Yapılandırma D-v1 Füzyonu, Fixed-Lag Gecikmiş-Adım Replay'i ve Canlı Harita Uygulandı; Stage 10 Yapılandırma D-v2 Uyarlanabilir/Sezgisel Füzyon Uygulandı ve Geliştirme İçin Fiziksel Biçimde Çalıştırıldı

**Dokümantasyon Durumu:** Teknik Dokümantasyon Baseline'ı Tamamlandı; Mevcut Durum Stage 10'a Kadar Senkronize Edildi; Birleşik 16-Yolluk Commit-Readiness Denetimi Bekliyor

**Birincil Test Cihazı:** Xiaomi Redmi Note 9 Pro

**Hedef Platform:** Yalnızca Android

**Planlanan Geliştirme Süresi:** 24 İş Günü

---

## 14. Current Milestone (Mevcut Kilometre Taşı)

### English

The technical documentation baseline and development-environment validation are complete. The Flutter Android bootstrap and Stage 2A SensorManager runtime capability inventory passed their static and physical checks. The Stage 2A snapshot returned 14 requested records: 13 default sensors were available and `TYPE_PRESSURE` was unavailable.

Stage 2B live timing diagnostics were implemented and physically verified for the accelerometer, gyroscope, magnetometer, and rotation vector on the tested Xiaomi Redmi Note 9 Pro configuration. Three 10-second sessions per sensor used a 20,000 µs (~50 Hz requested) configuration. All 12 sessions returned valid timing summaries and monotonic `SensorEvent.timestamp` sequences, and no gap above the provisional 60 ms threshold was observed. Requested rate and timestamp-derived observed rate remain distinct.

Stage 2C GNSS runtime timing diagnostics were implemented, statically verified, final-audited, and physically verified for the tested Xiaomi Redmi Note 9 Pro running Android 12 / API 31. All three formal `GPS_PROVIDER` sessions produced valid, mock-free summaries with monotonic `Location.elapsedRealtimeNanos` sequences. With a requested minimum interval of 1,000 ms, all three sessions had 1.000 s median and p95 callback intervals, while observed mean timestamp-derived rates ranged from approximately 0.983 to 1.000 Hz and one 2.000 s consecutive interval occurred. This demonstrates that requested timing does not guarantee fixed delivered timing; no GNSS gap threshold is defined.

Stage 2D ARCore runtime tracking diagnostics were implemented, statically verified, final-audited, and physically verified on the same tested device. Three of three formal sessions were valid, reached real `TrackingState.TRACKING`, exposed local-session pose, and produced monotonic `Frame.timestamp` sequences without terminal errors or `STOPPED` frames. The observed unique-frame rate was approximately 30.0295–30.0304 Hz and the tested-session tracking fraction was approximately 98.15%–98.36%. Stationary, rotational, and rightward walking scenarios physically demonstrated local-session relative pose response. These observations do not validate distance, rotation, drift, scale, or absolute accuracy, and no ARCore frame-gap threshold is defined.

Stage 3A — GNSS Anchor + Local ENU Reference Foundation implemented real foreground `GPS_PROVIDER` preflight and pre-denial anchor acquisition, an immutable runtime anchor with explicit clear/reacquire and cancellation, and WGS84 → ECEF → anchor-relative ENU math. Static validation passed (`flutter analyze`, 32/32 tests, debug APK build, and `git diff --check`). Three of three physical anchor acquisitions succeeded, and clear/reacquire and cancellation were verified. Horizontal ENU is available without fabricating Up when altitude is absent. Shared formal logs were sanitized and did not print raw anchor coordinates.

Stage 3B — Heading / True-North Reference Foundation implemented a `TYPE_ROTATION_VECTOR`-only handset-heading path using the physical top edge / device +Y convention, clockwise-from-North radians normalized into `[0, 2π)`, circular delta math, and locked-anchor `android.hardware.GeomagneticField` correction. Static validation passed (`flutter analyze`, 61/61 tests, debug APK build, and `git diff --check`). Three of three formal physical sessions succeeded at approximately 51.14 Hz observed delivery under a nominal 50 Hz request; monotonic and duplicate-free timestamps, clockwise-positive response, circular continuity beyond 2π, declination-path execution, and explicit cancellation were physically observed.

Stage 3C — Step-Event Foundation implemented `Sensor.TYPE_STEP_DETECTOR` as the only formal step source, Android 10+ activity-recognition permission handling, a 30-second operation window controlled by `SystemClock.elapsedRealtimeNanos()`, and aggregate timing derived from `SensorEvent.timestamp`. Static validation passed (`flutter analyze --no-pub`, 97/97 tests, debug APK build, and `git diff --check`). The stationary 0-step session accepted zero events; the controlled 20-step session accepted 16 events and excluded five delivered events through the formal window filter; and the controlled 30-step session accepted 30 events. Walking-session accepted timestamps were duplicate-free and monotonic, and explicit cancellation passed.

Stage 4 — Baseline PDR combines `Sensor.TYPE_STEP_DETECTOR` with true-north-corrected `Sensor.TYPE_ROTATION_VECTOR` handset heading. Each step is causally associated with the latest valid heading at or before its `SensorEvent.timestamp`; no future heading or interpolation is used. A fixed, uncalibrated, unvalidated 0.75 m baseline step length produces horizontal local ENU displacement from `E = 0, N = 0` with `ΔE = L × sin(ψ)` and `ΔN = L × cos(ψ)`. The locked Stage 3A anchor is used only for `android.hardware.GeomagneticField` declination, and live GNSS is not used during integration. Static validation passed (`flutter analyze --no-pub`, 118/118 tests, debug APK build, and `git diff --check`).

Physical verification on the Xiaomi Redmi Note 9 Pro passed for the defined Stage 4 scope: a stationary 30-second session integrated zero steps; two manually counted 20-step straight walks each integrated 20 causally associated steps; an intended 20-step L-shaped walk integrated 22 detected events; a corrected independent north check resolved an earlier physically misidentified walking-direction reference; and explicit cancellation returned `baseline_pdr_cancelled`. No raw trajectory, sensor sample, sensor timestamp, anchor coordinate, or live GNSS data is returned or persisted.

Stage 5 — ARCore Relative Motion → ENU Foundation uses `Frame.getAndroidSensorPose()` in the Android sensor frame, a local ARCore anchor at the aligned initial pose, and `anchor.pose.inverse().compose(currentAndroidSensorPose)` to express segment-relative translation in the initial device frame. A frozen `TYPE_ROTATION_VECTOR` plus `android.hardware.GeomagneticField` transform maps that displacement into true local ENU. Alignment holds for 2 seconds within a 15-second acquisition timeout; the separate formal movement window lasts 30 seconds. `SensorEvent.timestamp` and `Frame.getTimestamp()` are separate authorities and are never numerically cross-compared. Static validation passed with 141/141 tests, the debug APK build, and `git diff --check` across exactly six implementation/test paths.

Physical Stage 5 verification on the Xiaomi Redmi Note 9 Pro running Android 12 / API 31 passed for the defined scope. A stationary session ended approximately 0.081 m horizontally from the origin with approximately 0.100 m maximum excursion. A north-like walk ended near `E = 1.507 m, N = 8.223 m`; an east-like walk ended near `E = 9.129 m, N = -1.176 m` and recorded one duplicate but no non-monotonic AR frame timestamp. An approximate 90-degree in-place rotation ended at approximately 0.503 m horizontal displacement, much smaller than the approximately 8–9 m straight-walk results. Explicit cancellation returned `arcore_enu_cancelled`. Completed formal sessions had `trackingFraction = 1.0` and no observed `PAUSED` or `STOPPED` frame; these observations are not universal performance or accuracy guarantees.

Stage 6 — Evaluation Mode + Ground Truth Firewall keeps physical `GPS_PROVIDER` data active only as `protected_ground_truth_only`, while the software-defined denied Config A estimator receives step and heading data only. Config A remains fixed at 0.75 m per accepted step with `ΔE = 0.75 × sin(ψ)` and `ΔN = 0.75 × cos(ψ)`. Step and heading use nanosecond `SensorEvent.timestamp`, protected GNSS uses `Location.getElapsedRealtimeNanos`, and the operation window uses `SystemClock.elapsedRealtimeNanos`. Step-to-heading selection is `latest_valid_heading_at_or_before_step_timestamp`; the separate comparator selects `latest_estimator_state_at_or_before_ground_truth_timestamp`. Neither path uses a future sample, interpolation, protected-GT estimator input, or GNSS correction. Static validation passed with 169/169 tests, the debug APK build, and `git diff --check` across exactly six implementation/test paths.

The stationary physical evaluation accepted and matched 30/30 protected-GT fixes, accepted zero steps, remained at local origin, and produced approximately 0.526 m median error, 2.445 m p95 error, and 0.506 m final denied pre-correction error. The initial moving evaluation exposed a real implementation defect: 11 accepted steps were all unassociated despite 1,531 valid headings because Stage 6 retained only the latest delivered heading and discarded older causal samples. The two-file fix buffered valid headings and accepted step timestamps and finalized the greatest `T_heading <= T_step`, matching Stage 4. Regression coverage for causal previous heading, future-heading rejection, multi-step counter invariants, and GT mutation invariance passed.

In the post-fix moving retest, the user manually walked 20 steps. Sixteen step updates were observed, five were outside the formal window, and all 11 accepted steps were associated and integrated with zero unassociated steps. The final denied state was approximately `E = 8.108 m, N = -1.311 m`, with 8.213 m displacement and 8.25 m nominal path length. Thirty protected-GT fixes were accepted and matched, but Android-reported horizontal-accuracy metadata ranged from approximately 17.36 m to 57.12 m. The approximately 19.99 m median error, 48.24 m p95 error, and 19.78 m final pre-correction error therefore validate the evaluation/firewall data flow, not Config A accuracy or survey-grade ground truth. The manual 20-step count must not be described as 20/20 detection accuracy.

All successful Stage 6 physical results kept protected GNSS unavailable to and unused by the denied estimator, heading, step length, Quality Engine, and controller; `gnssCorrectionApplied = false` and `firewallMutationSelfTestPassed = true`. Explicit `evaluation_cancelled` cancellation passed. Raw GNSS coordinates, protected-GT/denied trajectories, timestamps, and device identifiers are neither returned nor persisted. Evaluation Mode, the Ground Truth Firewall, and Config A evaluation are **IMPLEMENTED**, while PDR, step-detection, step-length, heading, true-north, protected-GNSS ground-truth, ARCore position/distance/vertical, ENU-alignment, and physical-distance accuracy remain **NOT VALIDATED**. Body heading and handset-to-body calibration remain **NOT IMPLEMENTED**. Stage 7 supersedes the former Stage 6 boundary status for Quality Engine and EKF as documented below.

Stage 7 — Config D Quality Engine + EKF Sensor Fusion implements profile `config_d_navguard_ekf_v1`. The configuration map remains A = baseline PDR, B = improved heading, C = ARCore relative motion, and D = quality-aware PDR + heading + ARCore EKF fusion. The three-state model is `[E, N, heading]` in `local_enu`, with heading clockwise from true North in `[0, 2π)` and circular innovation in `(-π, π]`. PDR remains step-driven with fixed uncalibrated/unvalidated `L = 0.75 m`, `ΔE = L × sin(ψ)`, and `ΔN = L × cos(ψ)` and no accelerometer integration. Heading uses a provisional 15-degree measurement sigma; ARCore uses `Frame.getAndroidSensorPose()`, the Stage 5 transform, and a provisional 0.35 m position sigma. Joseph covariance updates preserve symmetry without claiming physical calibration.

The exact quality enum is `UNKNOWN`, `GOOD`, `USABLE`, `DEGRADED`, `UNRELIABLE`, and `UNAVAILABLE`. `GOOD`, `USABLE`, and `DEGRADED` apply covariance multipliers 1, 2, and 6; the remaining qualities skip the relevant update. Heading and step timing use `SensorEvent.timestamp`. `Frame.getTimestamp()` is restricted to AR duplicate/monotonic/rate diagnostics; AR fusion ordering uses processing-time `SystemClock.elapsedRealtimeNanos()` after a usable frame update. Unsupported cross-clock comparison is false, and equal timestamps use `heading,step,arcore` priority. Each session captures for 30 seconds and then replays deterministically without returning a trajectory.

Stage 7 static validation passed across exactly six implementation/test paths with `flutter analyze --no-pub`, 191/191 tests, `flutter build apk --debug --no-pub`, and `git diff --check`. Physical verification on the Xiaomi Redmi Note 9 Pro running Android 12 / API 31 passed for stationary, straight-walk, turn/L-shaped, and `navguard_fusion_cancelled` cancellation scenarios. Fused horizontal displacement was approximately 0.017905 m, 12.505097 m, and 10.018620 m respectively. The AR-degradation attempt stayed in tracking with 895 `GOOD`, two `USABLE`, and zero degraded-or-worse observations; it passed with observation, while physical AR-loss fallback remains **NOT VALIDATED**. These values and the observed AR innovation norms are session diagnostics, not validated accuracy or noise estimates.

Stage 7 accessed no protected ground truth, requested no live GNSS, applied no GNSS correction, and returned or persisted no raw trajectory, timestamp, sensor, ARCore, camera, or anchor-coordinate data. Config D Quality Engine + EKF fusion is **IMPLEMENTED** for the defined scope, but fusion accuracy, quality thresholds, noise parameters, step/step-length/heading/true-north/ARCore accuracy, and physical AR-loss fallback are **NOT VALIDATED**.

Stage 8 — GNSS Denial / Recovery + Full NAVGUARD Flow implements the first complete deterministic operational sequence: `ACQUIRING_GNSS → NORMAL_GNSS → DENIED_NAVGUARD → RECOVERY_PENDING → RECOVERED_GNSS → COMPLETED`, with `IDLE`, `CANCELLED`, and `FAILED` terminal/control states. Denial is software-defined; no RF interference or spoofing is used. The physical `GPS_PROVIDER` listener may remain active, but every denied-window fix is quarantined before estimator, heading, PDR, Quality Engine, or controller access. Operational fix time is `Location.getElapsedRealtimeNanos`; operation boundaries use `SystemClock.elapsedRealtimeNanos`. Initial acquisition and recovery require three consecutive acceptable fresh fixes under the fixed but unvalidated 50 m engineering threshold. GNSS bearing is never used.

At denial entry, the latest accepted normal-GNSS local ENU becomes the horizontal origin and the EKF begins at `[E_denial_origin, N_denial_origin, latest true heading]`; denied navigation does not reset to ENU zero. ARCore relative displacement starts from zero and is offset by the denial origin before EKF input. Config D retains its Stage 7 `[E,N,heading]`, PDR, heading, ARCore, Quality Engine, Joseph covariance, and circular innovation architecture. `Frame.getTimestamp()` is not used for cross-source fusion ordering; the AR fusion-order timestamp uses `SystemClock.elapsedRealtimeNanos()` without claiming camera/sensor hardware synchronization.

Post-fix static validation passed with `flutter analyze --no-pub`, 211/211 tests, `flutter build apk --debug --no-pub`, and `git diff --check`. The stationary full-flow session completed with zero denied-GNSS estimator use, 1,532 heading updates, zero PDR predictions, 897 ARCore updates, and approximately 0.007818 m pre-recovery denied displacement. The first walking session deliberately remains documented because it exposed a real regression: all 13 accepted steps were skipped for no heading despite 1,532 valid heading updates.

The root cause matched the Stage 6 bug class: Stage 8 kept only the latest delivered heading and associated each step immediately, so a delayed step could see only a future heading after the older causal sample had been discarded. The fix buffers heading and step histories and replays events deterministically by timestamp. Each step selects the greatest `T_heading <= T_step`; future heading and interpolation remain prohibited, and equal timestamps resolve `HEADING → STEP → ARCORE_POSITION`. Delayed callback, multiple delayed steps, equal timestamp, future-only heading, representative approximately 1,500-heading, and PDR counter-invariant tests passed.

The targeted walking retest completed with 16/16 accepted step opportunities converted to PDR predictions, zero no-heading skips, zero quality skips, 1,533 heading updates, and 899 ARCore updates. End-of-denial qualities were `USABLE / USABLE / GOOD / GOOD`. Recovery gate counters were three accepted plus one rejected equals four candidates; the recovered observation separately recorded five accepted and zero rejected fixes. The approximately 73.46 m recovery correction is not true error or accuracy—it is the distance between the pre-recovery denied estimate and operational recovered GNSS position. Cancellation passed with `full_navguard_flow_cancelled`, and privacy/firewall boundaries returned or persisted no raw coordinates, fixes, samples, poses, trajectories, timestamps, or camera images.

Stage 8 implementation, static validation, and scoped physical verification are **COMPLETE/PASS**. Full-flow accuracy, GNSS-recovery accuracy, the GNSS threshold, fusion accuracy, quality thresholds, noise parameters, step detection, step length, heading, true North, ARCore position, and covariance calibration remain **NOT VALIDATED**. Overall NAVGUARD physical verification remains **PARTIAL**, and the device baseline remains **NOT FROZEN**.

Stage 9A — Matched A/B/C/D Benchmark + Protected Ground Truth is **IMPLEMENTED**, its static validation passed (`flutter analyze --no-pub`, 230/230 tests, debug APK build, and `git diff --check`), and five valid physical matched sessions are complete. The benchmark captures one physical session and replays Config A/B/C/D independently from an identical denial origin; these are not four separate walks. Config A (`config_a_deterministic_pdr`) is fixed-0.75 m causal-heading PDR without EKF, ARCore position, or Quality Engine covariance behavior. Config B (`config_b_pdr_heading_ekf`) adds heading EKF, circular innovation, and Joseph covariance with no ARCore. Config C (`config_c_arcore_relative`) is denial-origin-offset ARCore relative ENU without PDR or position EKF. Config D (`config_d_navguard_ekf_v1`) combines PDR, true-north heading, ARCore relative ENU, the Quality Engine, EKF, Joseph covariance, and circular heading innovation.

The Ground Truth Firewall passed: protected `GPS_PROVIDER` observations are evaluation-only and unavailable to all four estimators and the Quality Engine; no GT correction or GNSS recovery is applied. Mutation and removal invariance passed. Matching uses the latest state with `T_estimator <= T_gt`, never a future state and never interpolation, with an initial denial snapshot for every Config. The primary metric is `matched_session_median_horizontal_error_m`, the comparison is `config_d_vs_config_a`, and p95 uses `nearest_rank`.

| Session | A median (m) | B median (m) | C median (m) | D median (m) | D vs A | >=20% target | GT reported accuracy median (m) |
| ------- | ------------ | ------------ | ------------ | ------------ | ------ | ------------ | ------------------------------- |
| 1 | 12.561945 | 12.514907 | 12.726737 | 12.185632 | +2.995659% | No | 9.109423 |
| 2 | 39.919900 | 39.854368 | 38.625899 | 39.018361 | +2.258370% | No | 7.354877 |
| 3 | 7.385471 | 7.450696 | 9.068059 | 8.854543 | -19.891378% | No | 10.320395 |
| 4 | 5.489879 | 5.537452 | 9.163584 | 7.674903 | -39.800935% | No | 4.681105 |
| 5 | 5.581048 | 5.795966 | 6.086692 | 5.644477 | -1.136517% | No | 4.203737 |

All valid sessions are retained. Each Config matched 149 protected-GT observations; Config A applied all 89 accepted step opportunities with no missing causal heading, and Config D also had zero no-heading skips. D outperformed A in 2/5 sessions, underperformed it in 3/5, and met the predefined >=20% target in 0/5. Median paired D-vs-A improvement was approximately -1.14% and mean improvement approximately -11.11%. Session-level median-error medians were approximately A 7.3855 m, B 7.4507 m, C 9.1636 m, and D 8.8545 m. D outperformed C in 4/5 sessions, with approximately +4.25% median paired improvement.

The five-session experiment does **NOT** demonstrate systematic Config D superiority over Config A, and the predefined target was **NOT MET**. The full fusion architecture often reduced error relative to Config C, while the heading EKF alone did not materially or consistently improve on A in these sessions. These are descriptive, session-specific observations. Handset `GPS_PROVIDER` is not survey-grade, RTK, motion-capture, or total-station ground truth; reported session medians ranged approximately 4.2–10.3 m, so smaller differences require caution. Benchmark and protected-GT accuracy remain **NOT VALIDATED**.

Uncalibrated 0.75 m stride, ARCore-to-ENU and heading uncertainty, heuristic quality/noise parameters—especially the uncalibrated 0.35 m ARCore position sigma—the 30-second horizon, and handset-GNSS uncertainty are plausible contributors, not experimentally isolated causes. These five sessions are frozen as the current evaluation set; tuning on them cannot be presented as independently validated by the same sessions. New independent sessions are required after any tuning. Privacy remains enforced and no raw coordinates, GT, sensor samples, ARCore poses, trajectories, timestamps, camera images, or persistent benchmark data are included.

Stage 9B — Live Map NAVGUARD Demo is **IMPLEMENTED AND PHYSICALLY VERIFIED**. `flutter_map 8.3.2` and `latlong2 0.10.1` render OpenStreetMap raster tiles with visible `© OpenStreetMap contributors` attribution and configured application identification; `android.permission.INTERNET` supplies map-tile access. Google Maps SDK, Mapbox, proprietary map APIs, bulk tile downloads, area prefetch, and offline-region scraping are not used. The map is display-only: `Sensors + ARCore + Quality Engine + EKF → local ENU estimate → display map projection → map`. Map tile or network failure does not alter navigation estimation.

The physical user flow passed from an existing GNSS anchor through `GNSS ACTIVE`, `NAVGUARD READY`, interactive software-defined denial, live NAVGUARD estimate/route, `RECOVERY PENDING`, three fresh valid fixes, and `GNSS RECOVERED`. There is no RF interference, jammer, or spoofing; denied physical-GPS fixes are quarantined before estimator access. The initial no-anchor defect that centered the map on fake `0,0` was corrected with an explicit `GNSS Anchor Required` screen, a blocked Start action, and return to the existing Stage 3A anchor workflow. Both no-anchor and valid-anchor map paths passed physical verification.

The first live walking test is retained as negative evidence: heading/PDR/AR updates were `2070 / 0 / 1212`, and late heading/step/AR counts were `0 / 56 / 0`. The map route was predominantly ARCore-driven because all 56 received steps were late. Raising the global watermark from 250 ms to 1,000 ms with 5,000 ms heading retention passed synthetic tests but failed two physical retests: received/applied/pending remained `17 / 0 / 0` and `14 / 0 / 0`, with 6602.6–7113.4 ms mean and approximately 10.6 s maximum callback latency. A global 11+ second UI delay was explicitly rejected.

The final architecture retains low-latency live map updates and adds a bounded 12,000 ms fixed-lag replay history capped at 4,096 sanitized events/checkpoints. Original step `SensorEvent.timestamp` is authoritative; callback time measures latency only. Delayed steps are inserted at event time and replayed in exact timestamp order with `HEADING → STEP → ARCORE_POSITION → insertion sequence` priority. Each step uses the greatest valid `T_heading <= T_step`; no future heading or interpolation is authorized. `TYPE_STEP_DETECTOR` requests `maxReportLatencyUs = 0`, but immediate delivery is not claimed as an Android guarantee. Only the corrected current estimate is streamed forward; the prior Flutter route is not rewritten.

The final targeted physical retest used approximately 20 manual straight steps and observed 16 Android detector events. All 16/16 detected events became PDR predictions, with zero no-heading, late, duplicate, or pending outcomes. Heading/PDR/AR updates were `1934 / 16 / 1135`; qualities were approximately `USABLE / USABLE / GOOD / GOOD`; callback latency was 4999.8 ms last, 10149.9 ms maximum, and 6493.4 ms mean. Thirty-eight denied GNSS fixes were quarantined and zero were used by the estimator. Recovery reached `GNSS RECOVERED`; 5.73 m is a correction distance between pre-recovery NAVGUARD and accepted operational GNSS, not ground-truth error. The route demonstrated visually coherent relative motion and general walking direction, with minor geometric deviations.

Absolute initial/recovered handset-GNSS map alignment may be offset by tens of metres in urban sessions; handset GNSS, multipath, and reference uncertainty are possible limitations, not proven causes. Absolute GNSS and live-map position accuracy are not survey-grade. Live-demo, step-detection, step-length, heading, ARCore, fusion, noise, and quality-threshold accuracy remain **NOT VALIDATED**. The 16/16 result validates handling of detected events, not 20/20 step detection. The local ENU route is ephemeral and is neither persisted nor uploaded; raw sensor streams, ARCore poses, timestamps, and anchor coordinates are not exposed to Flutter, logged, or persisted. Final Stage 9B static validation passed with `flutter analyze`, 260/260 tests, `flutter build apk --debug`, and `git diff --check`. Stage 9A remains unchanged: D was better than A in 2/5 sessions, worse in 3/5, median paired improvement was approximately -1.14%, mean approximately -11.11%, and the >=20% target was met in 0/5 sessions. Accuracy remains **NOT VALIDATED**.

Stage 10 — Navigation Accuracy v2 is **IMPLEMENTED** as adaptive/heuristic profile `config_d_v2_adaptive_navguard`; D-v1 remains `config_d_navguard_ekf_v1`, Config A remains deterministic fixed-stride PDR, and D-v2 is **NOT AI**. Implemented mechanisms include robust pre-denial GNSS operational-origin stabilization with coordinate-wise median ENU, dynamic stride and bounded 0.45–1.05 m self-calibration, walking/device heading-offset estimation bounded to approximately ±25°, turn-aware behavior, adaptive heading and ARCore uncertainty, robust covariance inflation, pre/post-robust NIS diagnostics, post-robust gating, stationary detection and ARCore drift suppression, source-disagreement diagnostics, persistent derived calibration, absolute and relative-displacement metrics, same-session D-v1/D-v2 development comparison, 12 s final drain, and selectable live v2 mode. D-v1, denied-GNSS isolation, recovery, and visualization-only map behavior remain preserved.

Operational stabilization uses 20 s timeout, five accepted fixes as target, three as minimum, and at least 5 s observation; three or four at timeout allow degraded median-origin continuation, while fewer than three fail. The immutable Stage 3A anchor is not replaced. Previous physical step callbacks averaged approximately 6–7 s delay and reached approximately 10.6 s, so the Stage 9B live path keeps 12 s fixed-lag replay and Stage 10 capture uses a 12 s final drain. The formal development window remains 30 s; only original event timestamps inside it are scored.

Android `SharedPreferences` persists only `schemaVersion`, `strideEstimateM`, `strideSampleCount`, `bodyHeadingOffsetRad`, and `headingOffsetSampleCount`. Restart persistence passed; one development run restored approximately 0.752 m stride and 2.21° heading offset. The profile contains no coordinates, raw GNSS, raw sensor stream, raw ARCore pose, trajectory, timestamp, or camera image; there is no cloud or telemetry. The final calibration session observed two stationary entries/14,716 ms, 0.03386757489976859 m drift, 21/21 applied steps, stride 0.75→0.7523730395965736 m from five samples, heading offset 0→2.2066232751778716° from five samples, ARCore accepted/rejected 1,480/260, pre-NIS mean/max 59.962750136750486/165.91354580215992, post-NIS mean/max 3.4265619485971177/6.054501701453265, 913 accepted after inflation, and zero rejected after maximum inflation. These are development observations.

The live stationary retest reported stationary YES, one entry, 13,687 ms, and zero denied-GNSS estimator uses. `lastStepTimestampNs` had incorrectly been refreshed from heading/ARCore event time without a physical step; it is now changed only by accepted real steps using original `SensorEvent.timestamp`. State remains `[E, N, heading]`, so this is stationary drift suppression rather than classical ZUPT.

Before the final turn fix, D-v2 regressed against D-v1 by -17.386396742414703% absolute and -15.769133699656274% relative in L-turn, with 451/899 ARCore updates hard-rejected. Hard rejection was incorrectly applied to pre-inflation NIS. The corrected policy computes preliminary NIS, derives bounded covariance inflation, recomputes `S` and post-robust NIS, then applies the hard gate. Soft-start 5.99, hard gate 25.0, and sigma 0.35–5.0 m are engineering parameters, not validated guarantees. Earlier controlled D-v2-vs-D-v1 results remain: straight +0.5983025061282222% absolute/+0.6929110812016313% relative, L-turn -17.386396742414703%/-15.769133699656274%, and mixed +0.5787171354548967%/+2.628688517799457%. D-v2 was not consistently superior; L-turn drove the correction.

The clean targeted L-turn retest used approximately 15 straight steps, a 90° right turn, and 10 straight steps. Approximately 25 manual steps produced 24 formal-window steps and fair `24/24/24` A/D-v1/D-v2 input. D-v1/D-v2 absolute medians were 13.56790843528887/13.47382293944652 m (+0.6934414120723457% D-v2 development improvement); relative medians were 12.026944732036352/11.856664928086161 m (+1.4158192936283631%). ARCore accepted 901 updates: 606 nominal and 295 inflated; hard rejects were zero. Pre/post-NIS mean/max were 3.448132466354329/21.73240926815048 and 2.0656258056618424/6.070728289846873; robust sigma mean/max were 0.40048823072921524/0.6666664053719006 m, and disagreement mean/max were 0.521867776055212/1.6465281522807453 m. Prior mass turn rejection was absent in this targeted retest, not universally disproved.

That L-turn had degraded GNSS stabilization: 4/5 accepted fixes, `accepted_less_than_target`, 36.967708587646484 m reported-accuracy median, 12.786329740671398 m spread, and approximately 18.43 m initial matched bias. Neither absolute nor relative metrics are formal accuracy validation. GT mutation/removal invariance passed and `protectedGtEstimatorAccessCount = 0`; protected denied GNSS is comparator-only and feeds none of stride/heading learning, adaptive noise/NIS, stationary detection, Quality Engine, EKF, or correction.

Stage 10 static validation passed with `flutter analyze --no-pub`, 278/278 tests, `flutter build apk --debug --no-pub`, and `git diff --check`. D-v2 is implemented and physically exercised only as a development prototype. Accuracy is **NOT VALIDATED**, independent validation has not been performed, and overall physical verification remains **PARTIAL**. Stage 11 — AI-Assisted Motion & Sensor Reliability Model is next and not implemented; the plan is an on-device or locally deployable learned model for motion classification and source reliability from privacy-safe derived features, with deterministic fallback and no raw GNSS coordinate required. See `PROJECT_STATUS.md` and `docs/06_device_capability_audit.md` for the detailed Stage 10 evidence record.

### Türkçe

Teknik dokümantasyon baseline'ı ve geliştirme ortamı doğrulaması tamamlandı. Flutter Android bootstrap ve Stage 2A SensorManager çalışma zamanı yetenek envanteri statik ve fiziksel kontrollerini geçti. Stage 2A snapshot'ı 14 istenen kayıt döndürdü: 13 varsayılan sensör kullanılabilirdi ve `TYPE_PRESSURE` kullanılamıyordu.

Stage 2B canlı zamanlama tanıları, test edilen Xiaomi Redmi Note 9 Pro yapılandırmasında ivmeölçer, jiroskop, manyetometre ve dönüş vektörü için uygulandı ve fiziksel olarak doğrulandı. Sensör başına üç adet 10 saniyelik oturumda 20.000 µs (~50 Hz talep edilen) yapılandırması kullanıldı. On iki oturumun tamamı geçerli zamanlama özetleri ve monoton `SensorEvent.timestamp` dizileri döndürdü; geçici 60 ms eşiğinin üzerinde boşluk gözlenmedi. Talep edilen hız ile timestamp-türevli gözlenen hız ayrı değerler olarak korunur.

Stage 2C GNSS çalışma zamanı zamanlama tanıları, Android 12 / API 31 çalıştıran test cihazı Xiaomi Redmi Note 9 Pro üzerinde uygulandı, statik olarak doğrulandı, nihai denetimden geçti ve fiziksel olarak doğrulandı. Üç resmî `GPS_PROVIDER` oturumunun tamamı monotonik `Location.elapsedRealtimeNanos` dizileri içeren geçerli ve mock içermeyen özetler üretti. Talep edilen minimum aralık 1.000 ms iken üç oturumun tümünde medyan ve p95 callback aralığı 1,000 s oldu; gözlenen timestamp-türevli ortalama hızlar yaklaşık 0,983–1,000 Hz aralığındaydı ve ardışık bir 2,000 s aralık gözlendi. Bu sonuç, talep edilen zamanlamanın sabit teslim zamanlamasını garanti etmediğini gösterir; tanımlı bir GNSS boşluk eşiği yoktur.

Stage 2D ARCore çalışma zamanı takip tanıları aynı test cihazında uygulandı, statik olarak doğrulandı, nihai denetimden geçti ve fiziksel olarak doğrulandı. Üç resmî oturumun 3/3'ü geçerliydi; gerçek `TrackingState.TRACKING` durumuna ulaştı, yerel-oturum pozu sağladı ve terminal hatası veya `STOPPED` kare olmadan monotonik `Frame.timestamp` dizileri üretti. Gözlenen benzersiz-kare hızı yaklaşık 30,0295–30,0304 Hz, test edilen oturumlardaki tracking fraction yaklaşık %98,15–%98,36 idi. Sabit durma, dönüş ve sağa yürüyüş senaryoları yerel-oturum göreli poz tepkisini fiziksel olarak gösterdi. Bu gözlemler mesafe, dönüş, sürüklenme, ölçek veya mutlak doğruluğu doğrulamaz ve tanımlı bir ARCore kare-boşluk eşiği yoktur.

Stage 3A — GNSS Anchor + Yerel ENU Referans Temeli; gerçek yalnızca ön planda çalışan `GPS_PROVIDER` preflight ve kesinti-öncesi anchor edinimini, açık clear/reacquire ve iptal içeren değişmez çalışma zamanı anchor'ını ve WGS84 → ECEF → anchor-göreli ENU matematiğini uyguladı. Statik doğrulama geçti (`flutter analyze`, 32/32 test, debug APK build'i ve `git diff --check`). Üç fiziksel anchor ediniminin 3/3'ü başarılı oldu; clear/reacquire ve iptal doğrulandı. Yükseklik yokken Up uydurulmadan yatay ENU kullanılabilir. Paylaşılan resmî loglar sanitize edilmişti ve ham anchor koordinatlarını yazdırmadı.

Stage 3B — Heading / Gerçek Kuzey Referans Temeli; fiziksel üst kenar / cihaz +Y convention'ı, Kuzeyden saat yönünde pozitif ve `[0, 2π)` aralığına normalize edilmiş radyanlar, dairesel delta matematiği ve kilitli-anchor `android.hardware.GeomagneticField` düzeltmesi kullanan yalnızca `TYPE_ROTATION_VECTOR` tabanlı handset-heading yolunu uyguladı. Statik doğrulama geçti (`flutter analyze`, 61/61 test, debug APK build'i ve `git diff --check`). Üç resmî fiziksel oturumun 3/3'ü nominal 50 Hz talep altında yaklaşık 51,14 Hz gözlenen teslimle başarılı oldu; monotonik ve duplicate içermeyen zaman damgaları, saat yönünde pozitif tepki, 2π üzerindeki dairesel süreklilik, declination yolunun çalışması ve açık iptal fiziksel olarak gözlendi.

Stage 3C — Adım Olayı Temeli, tek resmî adım kaynağı olarak `Sensor.TYPE_STEP_DETECTOR`, Android 10+ aktivite-tanıma izin yönetimi, `SystemClock.elapsedRealtimeNanos()` ile yönetilen 30 saniyelik operasyon penceresi ve `SensorEvent.timestamp` değerinden türetilen birleşik zamanlamayı uyguladı. Statik doğrulama geçti (`flutter analyze --no-pub`, 97/97 test, debug APK build'i ve `git diff --check`). Sabit 0-adımlı oturum sıfır olay kabul etti; kontrollü 20-adımlı oturum 16 olay kabul edip teslim edilen beş olayı resmî pencere filtresiyle dışladı; kontrollü 30-adımlı oturum 30 olay kabul etti. Yürüyüş oturumlarının kabul edilen zaman damgaları duplicate içermiyordu ve monotonikti; açık iptal geçti.

Stage 4 — Temel PDR, `Sensor.TYPE_STEP_DETECTOR` ile gerçek-kuzey-düzeltilmiş `Sensor.TYPE_ROTATION_VECTOR` handset heading'i birleştirir. Her adım, `SensorEvent.timestamp` değerinde veya öncesindeki en yeni geçerli heading ile nedensel olarak ilişkilendirilir; gelecek heading veya interpolasyon kullanılmaz. Sabit, kalibre edilmemiş ve doğrulanmamış 0,75 m baseline adım uzunluğu; `E = 0, N = 0` başlangıcından `ΔE = L × sin(ψ)` ve `ΔN = L × cos(ψ)` ile yatay yerel ENU yer değiştirmesi üretir. Kilitli Stage 3A anchor yalnızca `android.hardware.GeomagneticField` declination değeri için kullanılır ve entegrasyon sırasında canlı GNSS kullanılmaz. Statik doğrulama geçti (`flutter analyze --no-pub`, 118/118 test, debug APK build'i ve `git diff --check`).

Xiaomi Redmi Note 9 Pro üzerindeki fiziksel doğrulama tanımlı Stage 4 kapsamı için geçti: sabit 30 saniyelik oturum sıfır adım entegre etti; manuel sayılan iki 20-adımlık düz yürüyüşün her biri nedensel olarak ilişkilendirilmiş 20 adım entegre etti; hedeflenen 20-adımlık L-biçimli yürüyüş algılanan 22 olayı entegre etti; düzeltilmiş bağımsız kuzey kontrolü daha önce fiziksel olarak yanlış tanımlanan yürüyüş-yönü referansını çözdü ve açık iptal `baseline_pdr_cancelled` döndürdü. Ham rota, sensör örneği, sensör zaman damgası, anchor koordinatı veya canlı GNSS verisi döndürülmez ya da kalıcılaştırılmaz.

Stage 5 — ARCore Göreli Hareket → ENU Temeli, Android sensör çerçevesindeki `Frame.getAndroidSensorPose()` değerini, hizalanmış ilk pozdaki yerel ARCore anchor'ını ve segment-göreli ötelemeyi ilk cihaz çerçevesinde ifade eden `anchor.pose.inverse().compose(currentAndroidSensorPose)` işlemini kullanır. Sabitlenen `TYPE_ROTATION_VECTOR` artı `android.hardware.GeomagneticField` dönüşümü bu yer değiştirmeyi gerçek yerel ENU'ya taşır. Hizalama, 15 saniyelik edinim timeout'u içinde 2 saniye tutulur; ayrı resmî hareket penceresi 30 saniyedir. `SensorEvent.timestamp` ve `Frame.getTimestamp()` ayrı otoritelerdir ve sayısal olarak cross-compare edilmez. Statik doğrulama, tam altı uygulama/test yolunda 141/141 test, debug APK build'i ve `git diff --check` ile geçti.

Android 12 / API 31 çalıştıran Xiaomi Redmi Note 9 Pro üzerindeki fiziksel Stage 5 doğrulaması tanımlı kapsamda geçti. Sabit oturum başlangıçtan yaklaşık 0,081 m yatay uzaklıkta ve yaklaşık 0,100 m maksimum sapmayla sonlandı. Kuzey-benzeri yürüyüş yaklaşık `E = 1,507 m, N = 8,223 m`; doğu-benzeri yürüyüş yaklaşık `E = 9,129 m, N = -1,176 m` sonucunu verdi ve bir duplicate fakat sıfır monotonik-olmayan AR kare zaman damgası kaydetti. Yaklaşık 90 derecelik yerinde dönüş yaklaşık 0,503 m yatay yer değiştirmeyle, yaklaşık 8–9 m düz-yürüyüş sonuçlarından çok daha düşük kaldı. Açık iptal `arcore_enu_cancelled` döndürdü. Tamamlanan resmî oturumlarda `trackingFraction = 1.0` idi ve `PAUSED` veya `STOPPED` kare gözlenmedi; bu gözlemler evrensel performans veya doğruluk garantisi değildir.

Aşama 6 — Değerlendirme Modu + Ground Truth Güvenlik Duvarı, fiziksel `GPS_PROVIDER` verisini yalnızca `protected_ground_truth_only` olarak etkin tutarken yazılım-tanımlı kesintili Yapılandırma A tahmin motoru yalnızca adım ve heading verisi alır. Yapılandırma A kabul edilen adım başına sabit 0,75 m ile `ΔE = 0,75 × sin(ψ)` ve `ΔN = 0,75 × cos(ψ)` kullanır. Adım ve heading nanosaniye `SensorEvent.timestamp`, korumalı GNSS `Location.getElapsedRealtimeNanos`, operasyon penceresi `SystemClock.elapsedRealtimeNanos` kullanır. Adımdan heading'e seçim `latest_valid_heading_at_or_before_step_timestamp`; ayrı karşılaştırıcı `latest_estimator_state_at_or_before_ground_truth_timestamp` kullanır. İki yol da gelecek örnek, interpolasyon, tahmin motoruna korumalı-GT girdisi veya GNSS düzeltmesi kullanmaz. Statik doğrulama tam altı uygulama/test yolunda 169/169 test, debug APK build'i ve `git diff --check` ile geçti.

Sabit fiziksel değerlendirme 30/30 korumalı-GT fix'ini kabul edip eşleştirdi, sıfır adım kabul etti, yerel başlangıçta kaldı ve yaklaşık 0,526 m medyan hata, 2,445 m p95 hata ve 0,506 m nihai kesintili düzeltme-öncesi hata üretti. İlk hareketli değerlendirme gerçek bir uygulama hatasını açığa çıkardı: Stage 6 yalnızca en son teslim edilen heading'i tutup eski nedensel örnekleri attığı için 1.531 geçerli heading'e rağmen kabul edilen 11 adımın tamamı ilişkilendirilemedi. İki dosyalık düzeltme, geçerli heading'lerle kabul edilen adım zaman damgalarını tamponladı ve Stage 4 ile uyumlu şekilde en büyük `T_heading <= T_step` değerini finalize etti. Nedensel önceki heading, gelecek-heading reddi, çoklu-adım sayaç değişmezleri ve GT mutasyon değişmezliği regresyon testleri geçti.

Düzeltme-sonrası hareketli yeniden testte kullanıcı manuel olarak 20 adım yürüdü. On altı adım update'i gözlendi, beşi resmî pencerenin dışındaydı ve kabul edilen 11 adımın tamamı sıfır ilişkilendirilmemiş adımla ilişkilendirilip entegre edildi. Nihai kesintili durum yaklaşık `E = 8,108 m, N = -1,311 m`, 8,213 m yer değiştirme ve 8,25 m nominal yol uzunluğu verdi. Otuz korumalı-GT fix'i kabul edilip eşleştirildi; ancak Android-bildirilen yatay doğruluk metadata'sı yaklaşık 17,36 m ile 57,12 m arasındaydı. Bu nedenle yaklaşık 19,99 m medyan hata, 48,24 m p95 hata ve 19,78 m nihai düzeltme-öncesi hata, Yapılandırma A doğruluğunu veya survey-grade ground truth'u değil değerlendirme/firewall veri akışını doğrular. Manuel 20-adım sayımı 20/20 algılama doğruluğu olarak tanımlanmamalıdır.

Tüm başarılı Stage 6 fiziksel sonuçlarında korumalı GNSS kesintili tahmin motoru, heading, adım uzunluğu, Quality Engine ve denetleyici için kullanılamaz ve kullanılmamış durumda kaldı; `gnssCorrectionApplied = false` ve `firewallMutationSelfTestPassed = true` idi. Açık `evaluation_cancelled` iptali geçti. Ham GNSS koordinatları, korumalı-GT/kesintili rotalar, zaman damgaları ve cihaz kimlikleri döndürülmez veya kalıcılaştırılmaz. Değerlendirme Modu, Ground Truth Güvenlik Duvarı ve Yapılandırma A değerlendirmesi **UYGULANDI**; PDR, adım-algılama, adım-uzunluğu, heading, gerçek-kuzey, korumalı-GNSS ground-truth, ARCore konum/mesafe/dikey, ENU-hizalama ve fiziksel-mesafe doğruluğu ise **DOĞRULANMAMIŞTIR**. Body heading ve telefon-vücut kalibrasyonu **UYGULANMAMIŞTIR**. Quality Engine ile EKF hakkındaki eski Stage 6 sınır durumu aşağıda belgelenen Stage 7 tarafından güncellenmiştir.

Aşama 7 — Yapılandırma D Quality Engine + EKF Sensör Füzyonu, `config_d_navguard_ekf_v1` profilini uygular. Yapılandırma haritası A = baseline PDR, B = geliştirilmiş heading, C = ARCore göreli hareket ve D = kalite-duyarlı PDR + heading + ARCore EKF füzyonu olarak kalır. Üç durumlu model `local_enu` içinde `[E, N, heading]` biçimindedir; heading gerçek Kuzeyden saat yönünde pozitif ve `[0, 2π)` aralığındadır, dairesel innovation ise `(-π, π]` aralığındadır. PDR, sabit kalibre edilmemiş/doğrulanmamış `L = 0,75 m`, `ΔE = L × sin(ψ)` ve `ΔN = L × cos(ψ)` ile adım tabanlıdır ve ivmeölçer entegrasyonu kullanmaz. Heading geçici 15 derecelik measurement sigma; ARCore `Frame.getAndroidSensorPose()`, Stage 5 dönüşümü ve geçici 0,35 m konum sigma'sı kullanır. Joseph kovaryans güncellemeleri fiziksel kalibrasyon iddia etmeden simetriyi korur.

Kesin quality enum'u `UNKNOWN`, `GOOD`, `USABLE`, `DEGRADED`, `UNRELIABLE` ve `UNAVAILABLE` değerlerinden oluşur. `GOOD`, `USABLE` ve `DEGRADED` sırasıyla 1, 2 ve 6 kovaryans çarpanı uygular; kalan kalite durumları ilgili güncellemeyi atlar. Heading ve adım zamanlaması `SensorEvent.timestamp` kullanır. `Frame.getTimestamp()` yalnızca AR duplicate/monotoniklik/hız tanılarıyla sınırlıdır; AR füzyon sıralaması kullanılabilir kare güncellemesinden sonraki işlem-zamanı `SystemClock.elapsedRealtimeNanos()` değerini kullanır. Desteklenmeyen cross-clock karşılaştırması false'tur ve eşit zaman damgalarında `heading,step,arcore` önceliği kullanılır. Her oturum 30 saniye capture yapar, ardından rota döndürmeden deterministik replay uygular.

Stage 7 statik doğrulaması tam altı uygulama/test yolunda `flutter analyze --no-pub`, 191/191 test, `flutter build apk --debug --no-pub` ve `git diff --check` ile geçti. Android 12 / API 31 çalıştıran Xiaomi Redmi Note 9 Pro üzerindeki fiziksel doğrulama; sabit, düz-yürüyüş, dönüş/L-biçimli ve `navguard_fusion_cancelled` iptal senaryolarında geçti. Fused yatay yer değiştirme sırasıyla yaklaşık 0,017905 m, 12,505097 m ve 10,018620 m idi. AR bozulma denemesi 895 `GOOD`, iki `USABLE` ve sıfır degraded-veya-daha-kötü gözlemle tracking durumunda kaldı; gözlemle geçti, fiziksel AR-kaybı fallback'i ise **DOĞRULANMAMIŞTIR**. Bu değerler ve gözlenen AR innovation normları doğrulanmış doğruluk veya gürültü tahminleri değil, oturum tanılarıdır.

Stage 7 korumalı ground truth'a erişmedi, canlı GNSS istemedi, GNSS düzeltmesi uygulamadı ve ham rota, zaman damgası, sensör, ARCore, kamera veya anchor-koordinat verisini döndürmedi ya da kalıcılaştırmadı. Yapılandırma D Quality Engine + EKF füzyonu tanımlı kapsamda **UYGULANDI**; ancak füzyon doğruluğu, kalite eşikleri, gürültü parametreleri, adım/adım-uzunluğu/heading/gerçek-kuzey/ARCore doğruluğu ve fiziksel AR-kaybı fallback'i **DOĞRULANMAMIŞTIR**.

Aşama 8 — GNSS Kesintisi / Geri Kazanım + Tam NAVGUARD Akışı ilk tam deterministik operasyon dizisini uygular: `ACQUIRING_GNSS → NORMAL_GNSS → DENIED_NAVGUARD → RECOVERY_PENDING → RECOVERED_GNSS → COMPLETED`; `IDLE`, `CANCELLED` ve `FAILED` denetim/terminal durumları da vardır. Kesinti yazılım-tanımlıdır; RF paraziti veya spoofing kullanılmaz. Fiziksel `GPS_PROVIDER` dinleyicisi etkin kalabilir ancak kesinti-penceresindeki her fix tahmin motoru, heading, PDR, Quality Engine veya denetleyici erişiminden önce karantinaya alınır. Operasyonel fix zamanı `Location.getElapsedRealtimeNanos`, operasyon sınırları `SystemClock.elapsedRealtimeNanos` kullanır. İlk edinim ve recovery, sabit fakat doğrulanmamış 50 m mühendislik eşiği altında art arda üç kabul edilebilir taze fix gerektirir. GNSS bearing hiçbir zaman kullanılmaz.

Kesinti girişinde son kabul edilen normal-GNSS yerel ENU yatay başlangıç olur ve EKF `[E_kesinti_başlangıcı, N_kesinti_başlangıcı, son gerçek heading]` durumundan başlar; kesintili navigasyon ENU sıfıra resetlenmez. ARCore göreli yer değiştirmesi sıfırdan başlar ve EKF girdisinden önce kesinti başlangıcıyla offsetlenir. Yapılandırma D, Stage 7 `[E,N,heading]`, PDR, heading, ARCore, Quality Engine, Joseph kovaryans ve dairesel innovation mimarisini korur. `Frame.getTimestamp()` cross-source füzyon sıralamasında kullanılmaz; AR füzyon-sırası zaman damgası kamera/sensör donanım senkronizasyonu iddia etmeden `SystemClock.elapsedRealtimeNanos()` kullanır.

Düzeltme-sonrası statik doğrulama `flutter analyze --no-pub`, 211/211 test, `flutter build apk --debug --no-pub` ve `git diff --check` ile geçti. Sabit tam-akış oturumu sıfır kesinti-GNSS tahmin motoru kullanımı, 1.532 heading güncellemesi, sıfır PDR prediction, 897 ARCore güncellemesi ve yaklaşık 0,007818 m recovery-öncesi kesintili yer değiştirmeyle tamamlandı. İlk yürüyüş oturumu gerçek bir regresyonu açığa çıkardığı için açıkça belgelenir: 1.532 geçerli heading güncellemesine rağmen kabul edilen 13 adımın tamamı heading-yok nedeniyle atlandı.

Kök neden Stage 6 ile aynı hata sınıfındaydı: Stage 8 yalnızca en son teslim edilen heading'i tutup her adımı hemen ilişkilendiriyordu; gecikmiş adım eski nedensel örnek atıldıktan sonra yalnızca gelecekteki heading'i görebiliyordu. Düzeltme heading ve adım geçmişlerini tamponlar, olayları zaman damgasına göre deterministik replay eder. Her adım en büyük `T_heading <= T_step` değerini seçer; gelecek heading ve interpolasyon yasak kalır, eşit zaman damgaları `HEADING → STEP → ARCORE_POSITION` sırasıyla çözülür. Gecikmiş callback, çoklu gecikmiş adım, eşit zaman damgası, yalnızca-gelecek heading, yaklaşık 1.500-heading temsilî akış ve PDR sayaç değişmezi testleri geçti.

Hedefli yürüyüş yeniden testi, kabul edilen 16/16 adım fırsatını sıfır heading-yok ve sıfır kalite atlamasıyla PDR prediction'a çevirdi; 1.533 heading ve 899 ARCore güncellemesi uygulandı. Kesinti-sonu kaliteler `USABLE / USABLE / GOOD / GOOD` idi. Recovery gate sayaçları üç kabul artı bir ret eşittir dört aday; recovered gözlemi ayrı olarak beş kabul ve sıfır ret kaydetti. Yaklaşık 73,46 m recovery correction gerçek hata veya doğruluk değildir; recovery-öncesi kesintili tahmin ile operasyonel recovered GNSS konumu arasındaki mesafedir. İptal `full_navguard_flow_cancelled` ile geçti; gizlilik/firewall sınırları ham koordinat, fix, örnek, poz, rota, zaman damgası veya kamera görüntüsü döndürmedi ya da kalıcılaştırmadı.

Stage 8 uygulaması, statik doğrulaması ve kapsamı belirli fiziksel doğrulaması **TAMAMLANDI/GEÇTİ**. Tam-akış doğruluğu, GNSS-recovery doğruluğu, GNSS eşiği, füzyon doğruluğu, kalite eşikleri, gürültü parametreleri, adım algılama, adım uzunluğu, heading, gerçek Kuzey, ARCore konumu ve kovaryans kalibrasyonu **DOĞRULANMAMIŞTIR**. Genel NAVGUARD fiziksel doğrulaması **KISMİ**, cihaz baseline'ı **SABİTLENMEMİŞ** durumdadır.

Aşama 9A — Eşleştirilmiş A/B/C/D Benchmark + Korunan Referans Konum **UYGULANDI**, statik doğrulaması geçti (`flutter analyze --no-pub`, 230/230 test, debug APK build'i ve `git diff --check`) ve beş geçerli fiziksel eşleştirilmiş oturum tamamlandı. Benchmark tek bir fiziksel oturumu yakalayıp aynı kesinti başlangıcından Yapılandırma A/B/C/D üzerinde bağımsız replay eder; bunlar dört ayrı yürüyüş değildir. Yapılandırma A (`config_a_deterministic_pdr`) EKF, ARCore konumu veya Quality Engine kovaryans davranışı olmadan sabit 0,75 m nedensel-heading PDR'dır. Yapılandırma B (`config_b_pdr_heading_ekf`) ARCore olmadan heading EKF, dairesel innovation ve Joseph kovaryans ekler. Yapılandırma C (`config_c_arcore_relative`) PDR veya konum EKF'si olmadan kesinti başlangıcıyla offsetlenmiş ARCore göreli ENU'dur. Yapılandırma D (`config_d_navguard_ekf_v1`) PDR, gerçek-kuzey heading, ARCore göreli ENU, Quality Engine, EKF, Joseph kovaryans ve dairesel heading innovation'ı birleştirir.

Ground Truth Güvenlik Duvarı geçti: korumalı `GPS_PROVIDER` gözlemleri yalnızca değerlendirme içindir; dört tahmin motoru ve Quality Engine erişemez, GT düzeltmesi veya GNSS recovery uygulanmaz. Mutasyon ve kaldırma değişmezliği geçti. Eşleştirme `T_estimator <= T_gt` koşulunu sağlayan en yeni durumu kullanır; gelecek durum ve interpolasyon yoktur, her Yapılandırma kesinti başlangıcı snapshot'ına sahiptir. Birincil metrik `matched_session_median_horizontal_error_m`, karşılaştırma `config_d_vs_config_a`, p95 politikası `nearest_rank` değeridir.

| Oturum | A medyanı (m) | B medyanı (m) | C medyanı (m) | D medyanı (m) | D ve A | >=%20 hedefi | GT bildirilen doğruluk medyanı (m) |
| ------ | ------------- | ------------- | ------------- | ------------- | ------ | ------------ | ---------------------------------- |
| 1 | 12,561945 | 12,514907 | 12,726737 | 12,185632 | +%2,995659 | Hayır | 9,109423 |
| 2 | 39,919900 | 39,854368 | 38,625899 | 39,018361 | +%2,258370 | Hayır | 7,354877 |
| 3 | 7,385471 | 7,450696 | 9,068059 | 8,854543 | -%19,891378 | Hayır | 10,320395 |
| 4 | 5,489879 | 5,537452 | 9,163584 | 7,674903 | -%39,800935 | Hayır | 4,681105 |
| 5 | 5,581048 | 5,795966 | 6,086692 | 5,644477 | -%1,136517 | Hayır | 4,203737 |

Tüm geçerli oturumlar korunmuştur. Her Yapılandırma 149 korumalı-GT gözlemiyle eşleşti; Yapılandırma A kabul edilen 89 adım fırsatının tamamını eksik nedensel heading olmadan uyguladı ve Yapılandırma D'de de heading-yok atlaması sıfırdı. D, A'yı 2/5 oturumda geçti, 3/5 oturumda geride kaldı ve önceden tanımlanan >=%20 hedefini 0/5 oturumda karşıladı. Eşleştirilmiş D-ve-A iyileştirmesinin medyanı yaklaşık -%1,14, ortalaması yaklaşık -%11,11 idi. Oturum-düzeyi medyan hataların medyanı yaklaşık A 7,3855 m, B 7,4507 m, C 9,1636 m ve D 8,8545 m idi. D, C'yi 4/5 oturumda yaklaşık +%4,25 eşleştirilmiş medyan iyileştirmeyle geçti.

Beş oturumlu deney, Yapılandırma D'nin Yapılandırma A'ya sistematik üstünlüğünü **GÖSTERMEMEKTEDİR** ve önceden tanımlanan hedef **KARŞILANMAMIŞTIR**. Tam füzyon mimarisi çoğu kez Yapılandırma C'ye göre hatayı düşürürken heading EKF tek başına bu oturumlarda A'ya göre maddi veya tutarlı iyileşme sağlamadı. Bunlar betimsel ve oturuma özgü gözlemlerdir. Telefon `GPS_PROVIDER` verisi survey-grade, RTK, motion-capture veya total-station ground truth değildir; bildirilen oturum medyanları yaklaşık 4,2–10,3 m aralığındadır, bu nedenle daha küçük farklar dikkatle yorumlanmalıdır. Benchmark ve korumalı-GT doğruluğu **DOĞRULANMAMIŞTIR**.

Kalibre edilmemiş 0,75 m stride, ARCore-to-ENU ve heading belirsizliği, heuristic kalite/gürültü parametreleri—özellikle kalibre edilmemiş 0,35 m ARCore konum sigma'sı—30 saniyelik ufuk ve telefon-GNSS belirsizliği olası katkılardır; deneysel olarak ayrıştırılmış nedenler değildir. Bu beş oturum mevcut değerlendirme seti olarak dondurulmuştur; bunlara göre tuning yapılıp aynı oturumlar bağımsız doğrulama olarak sunulamaz. Her tuning sonrasında yeni bağımsız oturumlar gerekir. Gizlilik korunur; ham koordinat, GT, sensör örneği, ARCore pozu, rota, zaman damgası, kamera görüntüsü veya kalıcı benchmark verisi eklenmez.

Aşama 9B — Canlı Harita NAVGUARD Demosu **UYGULANDI VE FİZİKSEL OLARAK DOĞRULANDI**. `flutter_map 8.3.2` ile `latlong2 0.10.1`, görünür `© OpenStreetMap contributors` atfı ve yapılandırılmış uygulama kimliğiyle OpenStreetMap raster tile'larını gösterir; `android.permission.INTERNET` harita tile erişimini sağlar. Google Maps SDK, Mapbox, proprietary harita API'leri, toplu tile indirme, alan prefetch'i ve çevrimdışı bölge kazıma kullanılmaz. Harita yalnızca gösterimdir: `Sensörler + ARCore + Quality Engine + EKF → yerel ENU tahmini → gösterim harita projeksiyonu → harita`. Harita tile'ı veya ağ arızası navigasyon tahminini değiştirmez.

Fiziksel kullanıcı akışı mevcut GNSS anchor'dan `GNSS ACTIVE`, `NAVGUARD READY`, etkileşimli yazılım-tanımlı kesinti, canlı NAVGUARD tahmini/rotası, `RECOVERY PENDING`, üç taze geçerli fix ve `GNSS RECOVERED` durumlarına kadar geçti. RF paraziti, jammer veya spoofing yoktur; kesinti fiziksel-GPS fix'leri tahmin motoru erişiminden önce karantinaya alınır. Haritayı sahte `0,0` merkezinde açan ilk anchor-yok hatası, açık `GNSS Anchor Required` ekranı, engellenmiş Start işlemi ve mevcut Stage 3A anchor akışına dönüşle düzeltildi. Anchor-yok ve geçerli-anchor harita yollarının ikisi de fiziksel doğrulamayı geçti.

İlk canlı yürüyüş testi olumsuz kanıt olarak korunur: heading/PDR/AR güncellemeleri `2070 / 0 / 1212`, geç heading/adım/AR sayıları `0 / 56 / 0` idi. Alınan 56 adımın tamamı geç olduğundan harita rotası ağırlıklı olarak ARCore güdümlüydü. Global watermark'ı 250 ms'den 5.000 ms heading saklamayla 1.000 ms'ye çıkarmak sentetik testleri geçti ancak iki fiziksel yeniden testte başarısız oldu: alınan/uygulanan/bekleyen `17 / 0 / 0` ve `14 / 0 / 0` kaldı; ortalama callback gecikmesi 6.602,6–7.113,4 ms, maksimum yaklaşık 10,6 saniyeydi. Global 11+ saniyelik UI gecikmesi açıkça reddedildi.

Nihai mimari düşük-gecikmeli canlı harita güncellemelerini korur; en fazla 4.096 sanitize edilmiş olay/checkpoint içeren 12.000 ms fixed-lag replay geçmişi ekler. Özgün adım `SensorEvent.timestamp` otoritedir; callback zamanı yalnızca gecikmeyi ölçer. Gecikmiş adımlar olay zamanına eklenir ve `HEADING → STEP → ARCORE_POSITION → insertion sequence` önceliğiyle kesin zaman damgası sırasında replay edilir. Her adım en büyük geçerli `T_heading <= T_step` değerini kullanır; gelecek heading veya interpolasyon yetkilendirilmez. `TYPE_STEP_DETECTOR`, Android'in anında teslim garantisi olduğu iddia edilmeden `maxReportLatencyUs = 0` ister. Yalnızca düzeltilmiş güncel tahmin ileri yayınlanır; önceki Flutter rotası yeniden yazılmaz.

Nihai hedefli fiziksel yeniden test yaklaşık 20 manuel düz adım kullandı ve 16 Android detector olayı gözledi. Algılanan 16/16 olayın tamamı PDR prediction oldu; heading-yok, geç, duplicate ve bekleyen sonuçları sıfırdı. Heading/PDR/AR güncellemeleri `1934 / 16 / 1135`; kaliteler yaklaşık `USABLE / USABLE / GOOD / GOOD`; callback gecikmesi son 4.999,8 ms, maksimum 10.149,9 ms ve ortalama 6.493,4 ms idi. Otuz sekiz kesinti-GNSS fix'i karantinaya alındı ve tahmin motorunda sıfır kullanıldı. Recovery `GNSS RECOVERED` durumuna ulaştı; 5,73 m, recovery-öncesi NAVGUARD ile kabul edilen operasyonel GNSS arasındaki correction mesafesidir, ground-truth hata değildir. Rota küçük geometrik sapmalarla görsel olarak tutarlı göreli hareketi ve genel yürüyüş yönünü gösterdi.

Mutlak ilk/recovered telefon-GNSS harita hizalaması kentsel oturumlarda onlarca metre offsetli olabilir; telefon GNSS'i, multipath ve referans belirsizliği olası sınırlamalardır, kanıtlanmış nedenler değildir. Mutlak GNSS ve canlı-harita konum doğruluğu survey-grade değildir. Canlı-demo, adım-algılama, adım-uzunluğu, heading, ARCore, füzyon, gürültü ve kalite-eşiği doğruluğu **DOĞRULANMAMIŞTIR**. 16/16 sonucu, 20/20 adım algılamayı değil algılanan olayların işlenmesini doğrular. Yerel ENU rota geçicidir; kalıcılaştırılmaz veya yüklenmez; ham sensör akışları, ARCore pozları, zaman damgaları ve anchor koordinatları Flutter'a açılmaz, loglanmaz veya kalıcılaştırılmaz. Nihai Stage 9B statik doğrulaması `flutter analyze`, 260/260 test, `flutter build apk --debug` ve `git diff --check` ile geçti. Stage 9A değişmez: D, A'dan 2/5 oturumda iyi, 3/5 oturumda kötüydü; eşleştirilmiş medyan yaklaşık -%1,14, ortalama yaklaşık -%11,11 idi ve >=%20 hedefi 0/5 oturumda karşılandı. Doğruluk **DOĞRULANMAMIŞTIR**.

Stage 10 — Navigasyon Doğruluğu v2, uyarlanabilir/sezgisel `config_d_v2_adaptive_navguard` profili olarak **UYGULANDI**; D-v1 `config_d_navguard_ekf_v1`, Yapılandırma A deterministik sabit-adım-uzunluklu PDR olarak kalır ve D-v2 **AI DEĞİLDİR**. Sağlam kesinti-öncesi GNSS operasyonel başlangıç sabitlemesi ve koordinat-bazlı medyan ENU, dinamik adım uzunluğu ve 0,45–1,05 m sınırlı öz-kalibrasyon, yaklaşık ±25° sınırlı yürüyüş/cihaz heading-offset tahmini, dönüş-duyarlı davranış, uyarlanabilir heading/ARCore belirsizliği, sağlam kovaryans şişirmesi, ön/son sağlam NIS tanısı, sağlamlaştırma-sonrası gate, sabitlik algılama ve ARCore drift baskılama, kaynak uyuşmazlığı, kalıcı türetilmiş kalibrasyon, mutlak ve göreli-yer-değiştirme metrikleri, aynı-oturum D-v1/D-v2 geliştirme karşılaştırması, 12 sn final drain ve seçilebilir canlı v2 modu uygulandı. D-v1, kesinti-GNSS izolasyonu, recovery ve yalnızca-görselleştirme harita davranışı korundu.

Operasyonel sabitleme 20 sn timeout, beş kabul edilmiş fix hedefi, üç fix minimumu ve en az 5 sn gözlem kullanır; timeout'ta üç veya dört fix degraded medyan-başlangıç devamına izin verir, üçten az fix başarısız olur. Değişmez Stage 3A anchor'ı yerine geçmez. Önceki fiziksel adım callback'lerinde yaklaşık 6–7 sn ortalama ve 10,6 sn maksimum gecikme görüldüğü için Stage 9B canlı yolu 12 sn fixed-lag replay'i, Stage 10 yakalama 12 sn final drain'i kullanır. Resmî geliştirme penceresi 30 sn kalır; yalnızca özgün zaman damgası pencere içinde olan olaylar skorlanır.

Android `SharedPreferences` yalnızca `schemaVersion`, `strideEstimateM`, `strideSampleCount`, `bodyHeadingOffsetRad` ve `headingOffsetSampleCount` alanlarını kalıcılaştırır. Yeniden başlatma kalıcılığı geçti; bir geliştirme çalışması yaklaşık 0,752 m adım uzunluğu ve 2,21° heading offset'i geri yükledi. Profil koordinat, ham GNSS, ham sensör akışı, ham ARCore pozu, rota, zaman damgası veya kamera görüntüsü içermez; cloud veya telemetry yoktur. Nihai kalibrasyon oturumu iki sabitlik girişi/14.716 ms, 0,03386757489976859 m drift, 21/21 uygulanan adım, beş örnekle 0,75→0,7523730395965736 m adım uzunluğu, beş örnekle 0→2,2066232751778716° heading offset, 1.480/260 ARCore kabul/ret, 59,962750136750486/165,91354580215992 ön-NIS ortalama/maksimum, 3,4265619485971177/6,054501701453265 son-NIS ortalama/maksimum, şişirme sonrası 913 kabul ve maksimum şişirme sonrası sıfır ret gözlemledi. Bunlar geliştirme gözlemleridir.

Canlı sabitlik yeniden testi stationary YES, bir giriş, 13.687 ms ve sıfır kesinti-GNSS tahmin motoru kullanımı bildirdi. `lastStepTimestampNs`, fiziksel adım olmadan heading/ARCore olay zamanından hatalı biçimde yenileniyordu; artık yalnızca kabul edilen gerçek adımların özgün `SensorEvent.timestamp` değeriyle değişir. Durum `[E, N, heading]` olarak kalır; bu klasik ZUPT değil sabitlik drift baskılamasıdır.

Nihai dönüş düzeltmesinden önce D-v2, L-dönüşte D-v1'e göre mutlak -%17,386396742414703 ve göreli -%15,769133699656274 geriledi; 899 ARCore update'inin 451'i hard-reject edildi. Hard gate hatalı biçimde şişirme-öncesi NIS'e uygulanıyordu. Düzeltilen politika ilk NIS'i hesaplar, sınırlı kovaryans şişirmesi türetir, `S` ve sağlamlaştırma-sonrası NIS'i yeniden hesaplar ve sonra hard gate'i uygular. Soft-start 5,99, hard gate 25,0 ve sigma 0,35–5,0 m mühendislik parametreleridir; doğrulanmış garanti değildir. Önceki kontrollü D-v2-ve-D-v1 sonuçları korunur: düz +%0,5983025061282222 mutlak/+%0,6929110812016313 göreli, L-dönüş -%17,386396742414703/-%15,769133699656274 ve karma +%0,5787171354548967/+%2,628688517799457. D-v2 tutarlı üstün değildi; düzeltmeyi L-dönüş tetikledi.

Temiz hedefli L-dönüş yeniden testi yaklaşık 15 düz adım, 90° sağ dönüş ve 10 düz adım kullandı. Yaklaşık 25 manuel adım, 24 resmî-pencere adımı ve adil `24/24/24` A/D-v1/D-v2 girdisi üretti. D-v1/D-v2 mutlak medyanları 13,56790843528887/13,47382293944652 m (+%0,6934414120723457 D-v2 geliştirme iyileştirmesi); göreli medyanları 12,026944732036352/11,856664928086161 m (+%1,4158192936283631) idi. ARCore 606 nominal ve 295 şişirilmiş olmak üzere 901 update kabul etti; hard reject sıfırdı. Ön/son NIS ortalama/maksimum 3,448132466354329/21,73240926815048 ve 2,0656258056618424/6,070728289846873; sağlam sigma ortalama/maksimum 0,40048823072921524/0,6666664053719006 m, uyuşmazlık ortalama/maksimum 0,521867776055212/1,6465281522807453 m idi. Önceki kitlesel dönüş reddi bu hedefli testte görülmedi; evrensel biçimde çürütülmedi.

Bu L-dönüşte GNSS sabitlemesi degraded durumdaydı: 4/5 kabul edilen fix, `accepted_less_than_target`, 36,967708587646484 m bildirilen doğruluk medyanı, 12,786329740671398 m yayılım ve yaklaşık 18,43 m ilk eşleşme bias'ı. Mutlak veya göreli metrikler resmî doğruluk doğrulaması değildir. GT mutasyon/kaldırma değişmezliği geçti ve `protectedGtEstimatorAccessCount = 0` idi; korumalı kesinti GNSS'i yalnızca karşılaştırıcıdır ve adım/heading öğrenimini, uyarlanabilir gürültü/NIS'i, sabitlik algılamayı, Quality Engine'i, EKF'yi veya düzeltmeyi beslemez.

Stage 10 statik doğrulaması `flutter analyze --no-pub`, 278/278 test, `flutter build apk --debug --no-pub` ve `git diff --check` ile geçti. D-v2 yalnızca geliştirme prototipi olarak uygulandı ve fiziksel biçimde çalıştırıldı. Doğruluk **DOĞRULANMAMIŞTIR**, bağımsız doğrulama yapılmadı ve genel fiziksel doğrulama **KISMİ** kalır. Sıradaki Stage 11 — AI-Assisted Motion & Sensor Reliability Model uygulanmamıştır; privacy-safe türetilmiş özelliklerle hareket sınıflandırması ve kaynak güvenilirliği için cihaz-üzeri veya yerel konuşlandırılabilir öğrenilmiş model, deterministik fallback ve ham GNSS koordinatını model girdisi olarak gerektirmeme planlanır. Ayrıntılı Stage 10 kanıt kaydı `PROJECT_STATUS.md` ve `docs/06_device_capability_audit.md` içindedir.

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
