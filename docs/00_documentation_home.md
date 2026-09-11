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

**Current Phase:** Stage 8 — GNSS Denial / Recovery + Full NAVGUARD Flow Implemented, Statically Validated, and Physically Verified; Documentation Synchronized; Final Combined Commit-Readiness Audit Pending

**Development Status:** Flutter Android Bootstrap and Stages 2A–2D Runtime Diagnostics Verified for Their Defined Scopes; Stages 3A–7 Foundations, Evaluation Firewall, and Config D Fusion plus Stage 8 Software-Defined GNSS Denial, Quarantine, Recovery, and Full State Machine Implemented, Tested, and Physically Verified for Their Defined Scopes

**Documentation Status:** Technical Documentation Baseline Completed; Current Status Synchronized Through Stage 8; Combined 10-Path Commit-Readiness Audit Pending

**Primary Test Device:** Xiaomi Redmi Note 9 Pro

**Target Platform:** Android Only

**Planned Development Duration:** 24 Business Days

### Türkçe

**Mevcut Aşama:** Aşama 8 — GNSS Kesintisi / Geri Kazanım + Tam NAVGUARD Akışı Uygulandı, Statik ve Fiziksel Olarak Doğrulandı; Dokümantasyon Senkronize Edildi; Nihai Birleşik Commit-Readiness Denetimi Bekliyor

**Geliştirme Durumu:** Flutter Android Bootstrap ve Stage 2A–2D Çalışma Zamanı Tanıları Tanımlı Kapsamlarında Doğrulandı; Stage 3A–7 Temelleri, Değerlendirme Firewall'u ve Yapılandırma D Füzyonu ile Stage 8 Yazılım-Tanımlı GNSS Kesintisi, Karantina, Recovery ve Tam Durum Makinesi Tanımlı Kapsamlarında Uygulandı, Test Edildi ve Fiziksel Olarak Doğrulandı

**Dokümantasyon Durumu:** Teknik Dokümantasyon Baseline'ı Tamamlandı; Mevcut Durum Stage 8'e Kadar Senkronize Edildi; Birleşik 10-Yolluk Commit-Readiness Denetimi Bekliyor

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

Stage 8 implementation, static validation, and scoped physical verification are **COMPLETE/PASS**. Full-flow accuracy, GNSS-recovery accuracy, the GNSS threshold, fusion accuracy, quality thresholds, noise parameters, step detection, step length, heading, true North, ARCore position, and covariance calibration remain **NOT VALIDATED**. Protected ground truth is not accessed. Overall NAVGUARD physical verification remains **PARTIAL**, the device baseline remains **NOT FROZEN**, and Stage 9 — Experiments + A/B/C/D Benchmark + Final UI / Documentation / Demo is next and **NOT IMPLEMENTED**.

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

Stage 8 uygulaması, statik doğrulaması ve kapsamı belirli fiziksel doğrulaması **TAMAMLANDI/GEÇTİ**. Tam-akış doğruluğu, GNSS-recovery doğruluğu, GNSS eşiği, füzyon doğruluğu, kalite eşikleri, gürültü parametreleri, adım algılama, adım uzunluğu, heading, gerçek Kuzey, ARCore konumu ve kovaryans kalibrasyonu **DOĞRULANMAMIŞTIR**. Korumalı ground truth'a erişilmez. Genel NAVGUARD fiziksel doğrulaması **KISMİ**, cihaz baseline'ı **SABİTLENMEMİŞ** durumdadır; sıradaki Aşama 9 — Deneyler + A/B/C/D Benchmark + Nihai UI / Dokümantasyon / Demo **UYGULANMAMIŞTIR**.

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
