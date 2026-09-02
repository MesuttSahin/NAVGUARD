# 40 — Demo & Presentation Plan (Demo ve Sunum Planı)

## 1. Document Purpose (Dokümanın Amacı)

This document defines how NAVGUARD will be demonstrated, explained, visualized, and presented to a technical audience after implementation and validation are complete. *(Bu doküman NAVGUARD'ın implementation ve validation tamamlandıktan sonra teknik bir kitleye nasıl gösterileceğini, açıklanacağını, görselleştirileceğini ve sunulacağını tanımlar.)*

The objective is to present the project as a reproducible engineering and research system rather than as a visually impressive but scientifically unsupported mobile demonstration. *(Amaç projeyi görsel olarak etkileyici ancak bilimsel olarak desteklenmeyen bir mobil demo yerine reproducible engineering ve research system olarak sunmaktır.)*

---

# 2. Presentation Philosophy (Sunum Felsefesi)

The presentation will answer three questions in a clear sequence. *(Sunum üç soruya açık bir sıra içerisinde cevap verecektir.)*

```text
1. What problem does NAVGUARD solve?
   (NAVGUARD hangi problemi çözüyor?)

2. How does NAVGUARD solve it?
   (NAVGUARD bu problemi nasıl çözüyor?)

3. Does the measured evidence show that it works?
   (Ölçülen kanıt sistemin çalıştığını gösteriyor mu?)
```

---

# 3. Demo Philosophy (Demo Felsefesi)

The live demo will show the same architecture that produced the benchmark evidence. *(Canlı demo benchmark evidence'ı üreten aynı architecture'ı gösterecektir.)*

A separate simplified demonstration algorithm will not be substituted merely to make the presentation look smoother. *(Sunumun daha smooth görünmesi için ayrı simplified demonstration algorithm kullanılmayacaktır.)*

---

# 4. Evidence Before Spectacle (Gösteriden Önce Kanıt)

The strongest presentation message will be traceable evidence rather than visual animation alone. *(En güçlü sunum mesajı yalnızca görsel animation yerine traceable evidence olacaktır.)*

---

# 5. Research Scope Statement (Araştırma Kapsamı Bildirimi)

NAVGUARD will be introduced as an Android pedestrian GNSS-denied navigation research prototype. *(NAVGUARD Android yaya GNSS-denied navigation research prototype olarak tanıtılacaktır.)*

It will not be presented as certified navigation, military-grade navigation, or a permanent GNSS replacement. *(Certified navigation, military-grade navigation veya permanent GNSS replacement olarak sunulmayacaktır.)*

---

# 6. No RF Interference Claim (RF Müdahalesi İddiası Olmaması)

The project uses software-defined GNSS denial rather than radio-frequency jamming, spoofing, or interference. *(Proje radio-frequency jamming, spoofing veya interference yerine software-defined GNSS denial kullanır.)*

---

# 7. Primary Presentation Message (Temel Sunum Mesajı)

The central message is that NAVGUARD attempts to maintain short-term pedestrian position continuity when estimator access to GNSS is intentionally removed. *(Temel mesaj NAVGUARD'ın estimator'ın GNSS erişimi kasıtlı olarak kaldırıldığında kısa süreli yaya konum continuity'sini korumaya çalışmasıdır.)*

---

# 8. Secondary Presentation Message (İkincil Sunum Mesajı)

The second message is that AI and ARCore are assistance layers, while deterministic PDR remains the safety backbone. *(İkinci mesaj AI ve ARCore'un assistance layer olduğu, deterministic PDR'ın ise safety backbone olarak kaldığıdır.)*

---

# 9. Third Presentation Message (Üçüncü Sunum Mesajı)

The third message is that the project separates live estimator input from independently logged GNSS ground truth through the Ground Truth Firewall. *(Üçüncü mesaj projenin live estimator input ile independently logged GNSS ground truth'u Ground Truth Firewall üzerinden ayırdığıdır.)*

---

# 10. Fourth Presentation Message (Dördüncü Sunum Mesajı)

The fourth message is that all final claims will be based on matched benchmark evidence rather than one successful route. *(Dördüncü mesaj tüm final claim'lerin tek başarılı rota yerine matched benchmark evidence'a dayanacağıdır.)*

---

# 11. Presentation Audience (Sunum Hedef Kitlesi)

The presentation is designed for a technically literate audience such as software engineers, AI engineers, embedded or mobile developers, research reviewers, internship supervisors, or project juries. *(Sunum software engineer, AI engineer, embedded veya mobile developer, research reviewer, staj supervisor veya proje jury gibi teknik bilgisi olan bir kitle için tasarlanmıştır.)*

---

# 12. Presentation Depth (Sunum Derinliği)

The presentation will remain technically rigorous without turning every slide into source-code explanation. *(Sunum her slide'ı source-code explanation'a dönüştürmeden teknik olarak rigorous kalacaktır.)*

---

# 13. Recommended Presentation Duration (Önerilen Sunum Süresi)

The main presentation should be designed around a concise technical narrative, while exact speaking duration may be adjusted to the available event slot. *(Ana sunum concise technical narrative etrafında tasarlanmalı, exact speaking duration ise available event slot'a göre ayarlanabilir.)*

---

# 14. Demo and Presentation Separation (Demo ve Sunum Ayrımı)

The verbal presentation and the live demo will be planned as separate but connected phases. *(Sözlü sunum ve live demo ayrı ancak bağlantılı fazlar olarak planlanacaktır.)*

---

# 15. Preferred High-Level Flow (Tercih Edilen Yüksek Seviyeli Akış)

```text
PROBLEM
(Problem)

→ RESEARCH QUESTION
(Araştırma Sorusu)

→ SYSTEM ARCHITECTURE
(Sistem Mimarisi)

→ HOW GNSS DENIAL IS ENFORCED
(GNSS Kesintisinin Nasıl Uygulandığı)

→ PDR / AI / ARCORE / EKF
(PDR / AI / ARCORE / EKF)

→ LIVE DEMO
(Canlı Demo)

→ BENCHMARK RESULTS
(Benchmark Sonuçları)

→ LIMITATIONS
(Sınırlamalar)

→ CONCLUSION
(Sonuç)
```

---

# 16. Presentation Opening (Sunum Açılışı)

The presentation should begin with the navigation problem rather than with application screenshots. *(Sunum application screenshot'ları yerine navigation problem ile başlamalıdır.)*

---

# 17. Opening Problem Statement (Açılış Problem Bildirimi)

The opening should explain that ordinary smartphone navigation is heavily dependent on GNSS for global positioning. *(Açılış ordinary smartphone navigation'ın global positioning için büyük ölçüde GNSS'e bağlı olduğunu açıklamalıdır.)*

---

# 18. Denied Navigation Problem (Kesintili Navigasyon Problemi)

The audience should immediately understand that the research problem begins when a valid GNSS anchor exists and GNSS estimator access is then intentionally removed. *(Kitle araştırma probleminin valid GNSS anchor mevcutken başladığını ve ardından GNSS estimator access'in kasıtlı olarak kaldırıldığını hemen anlamalıdır.)*

---

# 19. Research Question Slide (Araştırma Sorusu Slide'ı)

The primary research question should be displayed clearly and without unnecessary wording. *(Primary research question açık ve gereksiz wording olmadan gösterilmelidir.)*

> Can AI-assisted pedestrian dead reckoning and visual-inertial sensor fusion reduce position drift during simulated GNSS outages on the Xiaomi Redmi Note 9 Pro compared with a baseline PDR-only approach?
> *(Yapay zekâ destekli yaya dead reckoning ve görsel-ataletsel sensör füzyonu, Xiaomi Redmi Note 9 Pro üzerinde simüle edilen GNSS kesintileri sırasında baseline PDR-only yaklaşıma göre konum drift'ini azaltabilir mi?)*

---

# 20. Research Scope Slide (Araştırma Kapsamı Slide'ı)

The scope slide will establish the boundaries of the project before technical details begin. *(Scope slide teknik detaylar başlamadan önce projenin boundaries'lerini belirleyecektir.)*

---

# 21. Scope Items (Kapsam Öğeleri)

```text
Android smartphone only.
(Yalnızca Android smartphone.)

Xiaomi Redmi Note 9 Pro as the primary device.
(Ana cihaz Xiaomi Redmi Note 9 Pro.)

Pedestrian navigation.
(Yaya navigasyonu.)

Software-defined GNSS denial.
(Yazılım tanımlı GNSS kesintisi.)

No additional navigation hardware.
(Ek navigasyon donanımı yok.)

Offline / on-device core.
(Offline / cihaz üzerinde çalışan çekirdek.)
```

---

# 22. Non-Goal Slide (Hedef Olmayanlar Slide'ı)

A short non-goal slide may prevent the audience from misinterpreting the project. *(Kısa bir non-goal slide kitlenin projeyi yanlış yorumlamasını önleyebilir.)*

---

# 23. Non-Goal Items (Hedef Olmayan Öğeler)

```text
Not permanent GNSS replacement.
(Kalıcı GNSS alternatifi değildir.)

Not centimeter-level navigation.
(Santimetre seviye navigasyon değildir.)

Not certified safety navigation.
(Sertifikalı güvenlik navigasyonu değildir.)

Not RF jamming or spoofing.
(RF jamming veya spoofing değildir.)

Not military-grade navigation.
(Askeri seviye navigasyon değildir.)
```

---

# 24. Architecture Slide (Mimari Slide)

The architecture slide should be one of the most important technical slides. *(Architecture slide en önemli teknik slide'lardan biri olmalıdır.)*

---

# 25. Architecture Slide Goal (Mimari Slide Hedefi)

The audience should understand the full sensor-to-position pipeline in less than one minute of explanation. *(Kitle full sensor-to-position pipeline'ı bir dakikadan kısa explanation içerisinde anlayabilmelidir.)*

---

# 26. Architecture Pipeline (Mimari Pipeline)

```text
ACCELEROMETER + GYROSCOPE + MAGNETOMETER
(İvmeölçer + Jiroskop + Manyetometre)

                ↓

TIMING / SYNCHRONIZATION
(Zamanlama / Senkronizasyon)

                ↓

STEP DETECTION + HEADING
(Adım Tespiti + Heading)

                ↓

STEP LENGTH
(Adım Uzunluğu)

                ↓

PDR
(Yaya Dead Reckoning)

                ↓

AI MOTION CONTEXT
(AI Hareket Context'i)

+ ARCORE RELATIVE TRACKING
(+ ARCore Relative Tracking)

                ↓

QUALITY ENGINE
(Kalite Motoru)

                ↓

EKF
(EKF)

                ↓

ENU POSITION + UNCERTAINTY
(ENU Konumu + Belirsizlik)

                ↓

WGS84 MAP DISPLAY
(WGS84 Harita Gösterimi)
```

---

# 27. Ground Truth Side Channel (Ground Truth Yan Kanalı)

The architecture slide should show GNSS ground truth as a separate protected side channel during Evaluation Mode. *(Architecture slide Evaluation Mode sırasında GNSS ground truth'u ayrı protected side channel olarak göstermelidir.)*

---

# 28. Ground Truth Firewall Visualization (Ground Truth Firewall Görselleştirmesi)

A visually clear barrier should separate protected GNSS ground truth from denied estimator inputs. *(Görsel olarak açık bir barrier protected GNSS ground truth ile denied estimator input'larını ayırmalıdır.)*

---

# 29. Firewall Message (Firewall Mesajı)

The audience should hear one explicit sentence explaining that physical GNSS may still be logged during Evaluation Mode but is not allowed to update the estimator. *(Kitle physical GNSS'in Evaluation Mode sırasında loglanmaya devam edebileceğini ancak estimator'ı update etmesine izin verilmediğini açıklayan explicit bir cümle duymalıdır.)*

---

# 30. Ground Truth Firewall Evidence (Ground Truth Firewall Kanıtı)

The presentation should show the final `unauthorizedGnssEstimatorUpdateCount` result when final evidence exists. *(Final evidence mevcut olduğunda sunum final `unauthorizedGnssEstimatorUpdateCount` sonucunu göstermelidir.)*

---

# 31. Required Firewall Result (Gerekli Firewall Sonucu)

```text
unauthorizedGnssEstimatorUpdateCount = 0
```

---

# 32. Navigation Modes Slide (Navigasyon Modları Slide'ı)

The presentation should explain the operational modes before the demo begins. *(Sunum demo başlamadan önce operational mode'ları açıklamalıdır.)*

---

# 33. Mode Sequence (Mod Sırası)

```text
GNSS MODE
(GNSS Modu)

→ EVALUATION / ANCHOR READY
(Evaluation / Anchor Hazır)

→ NAVGUARD GNSS-DENIED MODE
(NAVGUARD GNSS Kesintili Mod)

→ RECOVERY PENDING
(Recovery Bekleniyor)

→ RELOCALIZATION
(Yeniden Konumlandırma)

→ GNSS RESTORED
(GNSS Geri Geldi)
```

---

# 34. Coordinate-System Slide (Koordinat Sistemi Slide'ı)

A short technical slide should explain the local navigation frame. *(Kısa technical slide local navigation frame'i açıklamalıdır.)*

---

# 35. ENU Convention (ENU Convention)

```text
+E = East
(+E = Doğu)

+N = North
(+N = Kuzey)

+U = Up
(+U = Yukarı)
```

---

# 36. Heading Convention (Heading Convention)

Heading is clockwise from true north. *(Heading true north'tan clockwise ölçülür.)*

---

# 37. PDR Slide (PDR Slide'ı)

The PDR slide should show that NAVGUARD does not double-integrate raw acceleration to obtain position. *(PDR slide NAVGUARD'ın position elde etmek için raw acceleration'ı double-integrate etmediğini göstermelidir.)*

---

# 38. PDR Core Equation (PDR Temel Denklem)

```text
ΔE = L sin(ψ)
ΔN = L cos(ψ)
```

---

# 39. PDR Explanation (PDR Açıklaması)

Each accepted pedestrian step contributes a local East-North displacement based on step length and heading. *(Her accepted pedestrian step step length ve heading'e göre local East-North displacement katkısı sağlar.)*

---

# 40. Step Detection Slide (Adım Tespiti Slide'ı)

The presentation should identify step detection as a deterministic navigation-critical subsystem. *(Sunum step detection'ı deterministic navigation-critical subsystem olarak tanımlamalıdır.)*

---

# 41. Step Count Target on Slide (Slide Üzerinde Adım Sayısı Hedefi)

The provisional controlled target may be shown as absolute step-count error at or below `5%`. *(Geçici controlled target absolute step-count error `5%` veya altında olarak gösterilebilir.)*

---

# 42. Step-Length Slide (Adım Uzunluğu Slide'ı)

The presentation should distinguish deterministic step length from optional learned step length. *(Sunum deterministic step length ile optional learned step length'i ayırmalıdır.)*

---

# 43. Step-Length Fallback Visualization (Adım Uzunluğu Fallback Görselleştirmesi)

```text
Learned Step Length
(Öğrenilmiş Adım Uzunluğu)

        ↓ fallback

Deterministic Variable
(Deterministik Değişken)

        ↓ fallback

Calibrated Fixed
(Kalibre Edilmiş Sabit)
```

---

# 44. Learned Step-Length Honesty Rule (Learned Step-Length Dürüstlük Kuralı)

If learned step length does not outperform deterministic methods, the presentation will state that result directly. *(Learned step length deterministic method'ları outperform etmezse sunum bu sonucu doğrudan belirtecektir.)*

---

# 45. Heading Slide (Heading Slide'ı)

The heading slide should emphasize that direction error can dominate PDR drift. *(Heading slide direction error'ın PDR drift üzerinde dominant olabileceğini vurgulamalıdır.)*

---

# 46. Heading Sources (Heading Kaynakları)

```text
Magnetometer absolute reference.
(Manyetometre absolute reference.)

Gyroscope short-term propagation.
(Jiroskop short-term propagation.)

Rotation Vector candidate.
(Rotation Vector adayı.)

Magnetic quality checks.
(Manyetik kalite kontrolleri.)
```

---

# 47. Magnetic Disturbance Slide (Manyetik Bozulma Slide'ı)

The presentation may show how heading quality decreases during detected magnetic disturbance. *(Sunum detected magnetic disturbance sırasında heading quality'nin nasıl düştüğünü gösterebilir.)*

---

# 48. AI Slide (AI Slide'ı)

The AI slide should focus on the practical navigation role of Motion Classification. *(AI slide Motion Classification'ın practical navigation role'üne odaklanmalıdır.)*

---

# 49. AI Classes (AI Sınıfları)

```text
STATIONARY
(Hareketsiz)

WALKING
(Yürüme)

RUNNING
(Koşma)

TURNING
(Dönüş)
```

---

# 50. AI Architecture Message (AI Mimari Mesajı)

The primary neural candidate is a lightweight 1D-CNN operating on accelerometer and gyroscope windows. *(Primary neural candidate accelerometer ve gyroscope window'ları üzerinde çalışan lightweight 1D-CNN'dir.)*

---

# 51. AI Baseline Message (AI Baseline Mesajı)

Random Forest should be shown as the strong classical baseline. *(Random Forest strong classical baseline olarak gösterilmelidir.)*

---

# 52. AI Evaluation Slide (AI Değerlendirme Slide'ı)

The final presentation should show held-out session-wise Macro F1 rather than training accuracy. *(Final sunum training accuracy yerine held-out session-wise Macro F1 göstermelidir.)*

---

# 53. AI Target (AI Hedefi)

```text
Held-Out Motion Classification Target:
(Held-Out Motion Classification Hedefi:)

Macro F1 ≥ 0.90
```

---

# 54. AI Confusion Matrix (AI Confusion Matrix)

The final confusion matrix should be included if it is readable at presentation scale. *(Final confusion matrix presentation scale'de okunabilir ise dahil edilmelidir.)*

---

# 55. AI Navigation Effect (AI Navigasyon Etkisi)

The presenter should explain how motion context affects navigation rather than merely showing predicted labels. *(Sunucu yalnızca predicted label'ları göstermek yerine motion context'in navigation'ı nasıl etkilediğini açıklamalıdır.)*

---

# 56. Example AI Navigation Effects (Örnek AI Navigasyon Etkileri)

```text
STATIONARY → suppress false propagation.
(STATIONARY → false propagation'ı baskıla.)

WALKING → normal pedestrian profile.
(WALKING → normal yaya profili.)

RUNNING → alternate profile if validated.
(RUNNING → validated ise alternatif profil.)

TURNING → turn-aware heading / process behavior.
(TURNING → dönüş farkındalıklı heading / process davranışı.)
```

---

# 57. AI Fallback Message (AI Fallback Mesajı)

The audience should understand that AI failure does not stop navigation. *(Kitle AI failure'ın navigation'ı durdurmadığını anlamalıdır.)*

---

# 58. AI Fallback Slide (AI Fallback Slide'ı)

```text
AI AVAILABLE
(AI Kullanılabilir)

      ↓ failure

DETERMINISTIC PDR POLICY
(Deterministik PDR Politikası)
```

---

# 59. ARCore Slide (ARCore Slide'ı)

The ARCore slide should clearly state that ARCore provides relative visual-inertial motion rather than latitude and longitude. *(ARCore slide ARCore'un latitude ve longitude yerine relative visual-inertial motion sağladığını açıkça belirtmelidir.)*

---

# 60. ARCore Tracking States (ARCore Tracking State'leri)

Only `TRACKING` poses can enter fusion. *(Yalnızca `TRACKING` pose'ları fusion'a girebilir.)*

`PAUSED` poses are rejected. *(`PAUSED` pose'ları rejected edilir.)*

---

# 61. ARCore Segment Message (ARCore Segment Mesajı)

Tracking recovery generally starts a new local segment instead of assuming perfect world-frame continuity. *(Tracking recovery perfect world-frame continuity varsaymak yerine genellikle yeni local segment başlatır.)*

---

# 62. ARCore Fallback Message (ARCore Fallback Mesajı)

If ARCore fails, PDR continues. *(ARCore fail olursa PDR devam eder.)*

---

# 63. EKF Slide (EKF Slide'ı)

The EKF slide should remain mathematically clear but visually simple. *(EKF slide matematiksel olarak açık ancak görsel olarak simple kalmalıdır.)*

---

# 64. EKF Core State (EKF Temel State)

```text
x =
[E, N, ψ]ᵀ
```

---

# 65. EKF State Explanation (EKF State Açıklaması)

The formal initial state contains East position, North position, and heading. *(Formal initial state East position, North position ve heading içerir.)*

---

# 66. EKF Prediction Slide (EKF Prediction Slide'ı)

```text
E⁻ = E⁺ + L sin(ψ)
N⁻ = N⁺ + L cos(ψ)
ψ⁻ = ψ⁺
```

---

# 67. EKF Measurement Sources (EKF Measurement Kaynakları)

The presentation should show heading updates, authorized GNSS outside denial, and ARCore relative updates as distinct measurement paths. *(Sunum heading update'lerini, denial dışında authorized GNSS'i ve ARCore relative update'lerini distinct measurement path olarak göstermelidir.)*

---

# 68. Quality Engine Slide (Quality Engine Slide'ı)

The Quality Engine slide should explain why NAVGUARD does not trust all sensors equally at all times. *(Quality Engine slide NAVGUARD'ın tüm sensörlere her zaman eşit güvenmediğini açıklamalıdır.)*

---

# 69. Quality States (Quality State'leri)

```text
UNKNOWN
GOOD
USABLE
DEGRADED
UNRELIABLE
UNAVAILABLE
```

---

# 70. Quality and Availability Distinction (Quality ve Availability Ayrımı)

The presenter should explain that a sensor may be available but unreliable. *(Sunucu bir sensörün available ancak unreliable olabileceğini açıklamalıdır.)*

---

# 71. Uncertainty Slide (Belirsizlik Slide'ı)

The presentation should show position uncertainty separately from estimated position. *(Sunum position uncertainty'yi estimated position'dan ayrı göstermelidir.)*

---

# 72. Uncertainty Message (Belirsizlik Mesajı)

A small uncertainty estimate does not automatically prove that the position is correct. *(Küçük uncertainty estimate position'ın correct olduğunu otomatik olarak kanıtlamaz.)*

---

# 73. Demo Readiness Screen (Demo Readiness Screen)

The live demo should begin on a readiness screen rather than immediately starting navigation. *(Live demo immediately navigation başlatmak yerine readiness screen üzerinde başlamalıdır.)*

---

# 74. Readiness Screen Items (Readiness Screen Öğeleri)

```text
Accelerometer ready.
(İvmeölçer hazır.)

Gyroscope ready.
(Jiroskop hazır.)

Magnetometer ready.
(Manyetometre hazır.)

GNSS ready.
(GNSS hazır.)

ARCore supported / unavailable.
(ARCore destekleniyor / kullanılamıyor.)

AI model ready.
(AI model hazır.)

Storage ready.
(Depolama hazır.)

Ground Truth Firewall ready.
(Ground Truth Firewall hazır.)
```

---

# 75. Readiness Failure Rule (Readiness Failure Kuralı)

The demo should not begin a formal flow while mandatory readiness checks are failing. *(Mandatory readiness check'ler fail ederken demo formal flow başlatmamalıdır.)*

---

# 76. Live Demo Goal (Canlı Demo Hedefi)

The live demo should demonstrate the complete lifecycle rather than only movement of a map marker. *(Live demo yalnızca map marker movement yerine complete lifecycle'ı göstermelidir.)*

---

# 77. Primary Live Demo Sequence (Temel Canlı Demo Sırası)

```text
1. Application readiness.
   (Uygulama hazırlığı.)

2. GNSS anchor acquisition.
   (GNSS anchor edinimi.)

3. Start navigation.
   (Navigasyonu başlat.)

4. Confirm normal GNSS mode.
   (Normal GNSS modunu doğrula.)

5. Activate software GNSS denial.
   (Yazılımsal GNSS kesintisini etkinleştir.)

6. Walk the predefined route.
   (Önceden tanımlı rotayı yürü.)

7. Observe PDR / fused position.
   (PDR / fused konumu gözlemle.)

8. Observe quality and uncertainty.
   (Kalite ve belirsizliği gözlemle.)

9. Trigger GNSS recovery.
   (GNSS recovery'yi tetikle.)

10. Capture pre-correction error.
    (Düzeltme öncesi hatayı kaydet.)

11. Relocalize.
    (Yeniden konumlandır.)

12. Finalize the session.
    (Session'ı finalize et.)
```

---

# 78. Anchor Demo (Anchor Demo)

The presenter should show that the system waits for an acceptable anchor instead of accepting the first location callback automatically. *(Sunucu sistemin ilk location callback'i otomatik kabul etmek yerine acceptable anchor beklediğini göstermelidir.)*

---

# 79. Denial Demo (Denial Demo)

The transition into denied mode should be explicit and visible. *(Denied mode'a transition explicit ve visible olmalıdır.)*

---

# 80. Denial Marker (Denial Marker)

A clear visual state should indicate that GNSS estimator updates are blocked. *(Clear visual state GNSS estimator update'lerinin blocked olduğunu göstermelidir.)*

---

# 81. Ground Truth Hidden During Demo (Demo Sırasında Ground Truth Gizleme)

Protected GNSS ground truth must not be shown on the main map during the blinded denied interval. *(Protected GNSS ground truth blinded denied interval sırasında main map üzerinde gösterilmemelidir.)*

---

# 82. Why Ground Truth Is Hidden (Ground Truth Neden Gizlenir)

Hiding ground truth prevents the operator from unconsciously changing walking behavior to match the reference. *(Ground truth'u gizlemek operator'ın reference'a uymak için walking behavior'ını bilinçsizce değiştirmesini önler.)*

---

# 83. Demo Map Layers (Demo Harita Katmanları)

During denial, the main map should show only the allowed navigation layers. *(Denial sırasında main map yalnızca allowed navigation layer'larını göstermelidir.)*

---

# 84. Suggested Main Map During Denial (Denial Sırasında Önerilen Main Map)

```text
NAVGUARD estimated position.
(NAVGUARD tahmini konumu.)

Estimated trajectory.
(Tahmini trajectory.)

Uncertainty region.
(Belirsizlik bölgesi.)

Current mode.
(Mevcut mod.)

Current quality.
(Mevcut kalite.)
```

---

# 85. Ground Truth Reveal Timing (Ground Truth Gösterme Zamanı)

Ground truth may be revealed only after the denied comparison interval has ended. *(Ground truth yalnızca denied comparison interval sona erdikten sonra gösterilebilir.)*

---

# 86. Post-Demo Comparison View (Demo Sonrası Comparison View)

After recovery, the application may display estimated and ground-truth trajectories together for explanation. *(Recovery sonrasında application explanation için estimated ve ground-truth trajectory'leri birlikte gösterebilir.)*

---

# 87. Live Quality Visualization (Canlı Quality Görselleştirmesi)

The demo should display source quality in a compact way without overwhelming the audience with raw numbers. *(Demo audience'ı raw number'larla overwhelm etmeden source quality'yi compact şekilde göstermelidir.)*

---

# 88. Suggested Quality Panel (Önerilen Quality Panel)

```text
Heading: USABLE
(Heading: KULLANILABİLİR)

ARCore: TRACKING / UNAVAILABLE
(ARCore: TRACKING / KULLANILAMIYOR)

AI: ACTIVE / FALLBACK
(AI: AKTİF / FALLBACK)

Navigation Quality: GOOD / DEGRADED / ...
(Navigasyon Kalitesi: GOOD / DEGRADED / ...)
```

---

# 89. Live Uncertainty Visualization (Canlı Belirsizlik Görselleştirmesi)

The map may show an uncertainty ellipse or simplified uncertainty region around the estimated position. *(Map estimated position çevresinde uncertainty ellipse veya simplified uncertainty region gösterebilir.)*

---

# 90. No Fake Confidence Percentage (Sahte Confidence Percentage Olmaması)

The demo must not label uncertainty as `95% confidence` unless covariance calibration justifies that statement. *(Covariance calibration bu statement'ı justify etmedikçe demo uncertainty'yi `95% confidence` olarak label etmemelidir.)*

---

# 91. Live AI Panel (Canlı AI Paneli)

A compact AI panel may show the current operational motion context. *(Compact AI panel current operational motion context'i gösterebilir.)*

---

# 92. AI Panel Content (AI Panel İçeriği)

```text
Predicted class.
(Tahmin edilen sınıf.)

Model score.
(Model skoru.)

Model ID.
(Model kimliği.)

Inference latency.
(Inference gecikmesi.)

Fallback state.
(Fallback durumu.)
```

---

# 93. AI Score Labeling (AI Score Labeling)

If the model score is not calibrated, it should be labeled as a model score rather than probability. *(Model score calibrated değilse probability yerine model score olarak label edilmelidir.)*

---

# 94. Live Step Panel (Canlı Step Paneli)

The demo may show accepted step count, latest step length, and PDR distance. *(Demo accepted step count, latest step length ve PDR distance gösterebilir.)*

---

# 95. Live Heading Panel (Canlı Heading Paneli)

The demo may show true-north heading and heading quality. *(Demo true-north heading ve heading quality gösterebilir.)*

---

# 96. ARCore Panel (ARCore Paneli)

If ARCore is enabled, the demo may show tracking state and current segment ID. *(ARCore enabled ise demo tracking state ve current segment ID gösterebilir.)*

---

# 97. Demo Simplicity Rule (Demo Basitlik Kuralı)

The main demo screen should not expose every diagnostic value simultaneously. *(Main demo screen her diagnostic value'yu simultaneously expose etmemelidir.)*

---

# 98. Diagnostic Screen Separation (Diagnostic Screen Ayrımı)

Detailed sensor traces, raw timestamps, covariance matrices, and event counters should remain on a separate diagnostics screen. *(Detailed sensor trace'leri, raw timestamp'ler, covariance matrix'leri ve event counter'ları separate diagnostics screen üzerinde kalmalıdır.)*

---

# 99. Demo Failure Strategy (Demo Hata Stratejisi)

The project must have a planned response if one optional subsystem fails during the live demo. *(Live demo sırasında optional subsystem'lardan biri fail olursa projenin planned response'u olmalıdır.)*

---

# 100. AI Failure Demo Response (AI Failure Demo Tepkisi)

If AI becomes unavailable, the presenter should explain that the runtime has entered deterministic fallback rather than attempting to hide the failure. *(AI unavailable hale gelirse presenter failure'ı gizlemeye çalışmak yerine runtime'ın deterministic fallback'e geçtiğini açıklamalıdır.)*

---

# 101. ARCore Failure Demo Response (ARCore Failure Demo Tepkisi)

If ARCore loses tracking, the demo should visibly show that ARCore was removed from fusion while PDR continues. *(ARCore tracking kaybederse demo ARCore'un fusion'dan çıkarıldığını ve PDR'ın devam ettiğini visibly göstermelidir.)*

---

# 102. Heading Degradation Demo Response (Heading Degradation Demo Tepkisi)

If heading becomes degraded, quality should decrease and uncertainty should grow rather than keeping a falsely confident state. *(Heading degraded hale gelirse falsely confident state korumak yerine quality düşmeli ve uncertainty büyümelidir.)*

---

# 103. No Safe Estimate Demo Response (Safe Estimate Yoksa Demo Tepkisi)

If no defensible navigation estimate remains, the system should show `UNRELIABLE` or `UNAVAILABLE`. *(Defensible navigation estimate kalmazsa sistem `UNRELIABLE` veya `UNAVAILABLE` göstermelidir.)*

---

# 104. Fallback Demonstration Value (Fallback Demo Değeri)

A visible and correct fallback can strengthen the technical presentation because it demonstrates robust architecture rather than perfect-condition scripting. *(Visible ve correct fallback perfect-condition scripting yerine robust architecture gösterdiği için technical presentation'ı güçlendirebilir.)*

---

# 105. Planned Fallback Demo (Planlı Fallback Demo)

A controlled fallback demonstration may be prepared separately from the primary route. *(Controlled fallback demonstration primary route'tan ayrı hazırlanabilir.)*

---

# 106. Candidate Fallback Demo 1 (Aday Fallback Demo 1)

Temporarily disable or simulate AI failure and show deterministic navigation continuation. *(Geçici olarak AI failure disable veya simulate et ve deterministic navigation continuation'ı göster.)*

---

# 107. Candidate Fallback Demo 2 (Aday Fallback Demo 2)

Force ARCore tracking loss and show PDR continuation. *(ARCore tracking loss oluştur ve PDR continuation'ı göster.)*

---

# 108. Candidate Fallback Demo 3 (Aday Fallback Demo 3)

Inject an invalid learned step-length output and show deterministic step-length fallback. *(Invalid learned step-length output inject et ve deterministic step-length fallback'i göster.)*

---

# 109. Ground Truth Firewall Demonstration (Ground Truth Firewall Demo)

A technical demonstration may show the firewall counter remaining unchanged while protected GNSS is continuously logged. *(Technical demonstration protected GNSS continuously logged edilirken firewall counter'ın unchanged kaldığını gösterebilir.)*

---

# 110. Firewall Mutation Demo (Firewall Mutation Demo)

An offline replay demonstration may modify ground-truth GNSS values while showing that denied estimator output remains identical. *(Offline replay demonstration ground-truth GNSS value'larını modify ederken denied estimator output'un identical kaldığını gösterebilir.)*

---

# 111. Why Firewall Mutation Demo Is Powerful (Firewall Mutation Demo Neden Güçlüdür)

This directly demonstrates that the estimator is not secretly consuming protected GNSS during denial. *(Bu estimator'ın denial sırasında protected GNSS'i secretly consume etmediğini doğrudan gösterir.)*

---

# 112. Recovery Demo (Recovery Demo)

The recovery sequence should be explained as a controlled state transition rather than as a simple map snap. *(Recovery sequence simple map snap yerine controlled state transition olarak açıklanmalıdır.)*

---

# 113. Recovery Visual Sequence (Recovery Görsel Sırası)

```text
RECOVERY REQUESTED
(Recovery istendi.)

→ FIX VALIDATION
(Fix doğrulaması.)

→ PRE-CORRECTION SNAPSHOT
(Düzeltme öncesi snapshot.)

→ RECOVERY ERROR RECORDED
(Recovery hatası kaydedildi.)

→ RELOCALIZATION
(Yeniden konumlandırma.)

→ GNSS RESTORED
(GNSS geri geldi.)
```

---

# 114. Pre-Correction Error Demo (Pre-Correction Error Demo)

The presenter should explicitly show the estimator error before correction when the demo evidence supports it. *(Demo evidence destekliyorsa presenter correction öncesi estimator error'ı explicit göstermelidir.)*

---

# 115. Recovery Correction Message (Recovery Correction Mesajı)

The post-recovery correction is not pedestrian movement and should never be counted as travelled distance. *(Post-recovery correction pedestrian movement değildir ve hiçbir zaman travelled distance olarak sayılmamalıdır.)*

---

# 116. Session Finalization Demo (Session Finalization Demo)

The live demo should finish by showing that the session is being finalized and evidence is being preserved. *(Live demo session'ın finalize edildiğini ve evidence'ın preserved edildiğini göstererek bitmelidir.)*

---

# 117. Session Evidence View (Session Evidence View)

A compact post-session page may show the session ID, status, duration, evidence files, dropped-record count, and firewall integrity status. *(Compact post-session page session ID, status, duration, evidence file'ları, dropped-record count ve firewall integrity status gösterebilir.)*

---

# 118. Demo Success Is Not Benchmark Success (Demo Başarısı Benchmark Başarısı Değildir)

The presenter should explicitly state that one live demo does not determine the research result. *(Presenter tek live demo'nun research result'ı belirlemediğini explicit belirtmelidir.)*

---

# 119. Benchmark Transition (Benchmark'a Geçiş)

After the live demo, the presentation should move immediately to frozen final benchmark evidence. *(Live demo sonrasında sunum immediate olarak frozen final benchmark evidence'a geçmelidir.)*

---

# 120. Benchmark Configuration Slide (Benchmark Configuration Slide'ı)

The four benchmark configurations should be shown clearly. *(Dört benchmark configuration açık şekilde gösterilmelidir.)*

```text
A — PDR Only
(A — Yalnızca PDR)

B — PDR + Improved Heading
(B — PDR + Geliştirilmiş Heading)

C — PDR + ARCore
(C — PDR + ARCore)

D — Full NAVGUARD
(D — Tam NAVGUARD)
```

---

# 121. Benchmark Fairness Message (Benchmark Adalet Mesajı)

Whenever possible, the same physical raw session is replayed through A, B, C, and D. *(Mümkün olduğunda aynı physical raw session A, B, C ve D üzerinden replay edilir.)*

---

# 122. Why Matched Replay Matters (Matched Replay Neden Önemlidir)

Matched replay makes the comparison more interpretable because each configuration receives the same physical motion evidence. *(Matched replay her configuration aynı physical motion evidence aldığı için comparison'ı daha interpretable hale getirir.)*

---

# 123. Primary Benchmark Metric Slide (Temel Benchmark Metric Slide'ı)

The primary benchmark slide should emphasize median horizontal ENU position error. *(Primary benchmark slide median horizontal ENU position error'ı vurgulamalıdır.)*

---

# 124. Core Benchmark Metrics (Temel Benchmark Metrikleri)

```text
Median Error
(Median Hata)

Mean Error
(Ortalama Hata)

RMSE
(RMSE)

P95 Error
(P95 Hata)

Final Pre-Correction Error
(Final Düzeltme Öncesi Hata)

Drift per Minute
(Dakika Başına Drift)

Drift per Distance
(Mesafe Başına Drift)
```

---

# 125. Primary Research Target Slide (Temel Araştırma Hedefi Slide'ı)

The target should be shown before revealing the final result. *(Final result gösterilmeden önce target gösterilmelidir.)*

```text
Primary Target:
(Temel Hedef:)

≥20% reduction in aggregated matched-session median position error
for Configuration D relative to Configuration A.
(Configuration D için Configuration A'ya göre aggregated matched-session
median position error'da ≥%20 azalma.)
```

---

# 126. Why Target Comes Before Result (Hedef Neden Sonuçtan Önce Gelir)

Showing the target first demonstrates that the criterion was defined before interpreting final benchmark outcomes. *(Target'ı önce göstermek criterion'ın final benchmark outcome yorumlanmadan önce defined edildiğini gösterir.)*

---

# 127. A-D Comparison Slide (A-D Karşılaştırma Slide'ı)

The A-D comparison should be the primary result slide. *(A-D comparison primary result slide olmalıdır.)*

---

# 128. A-D Result Table Candidate (A-D Sonuç Tablosu Adayı)

| Metric (Metrik)              | A — PDR | D — Full NAVGUARD | Change (Değişim) |
| ---------------------------- | ------: | ----------------: | ---------------: |
| Median Error *(Median Hata)* |     TBD |               TBD |              TBD |
| Mean Error *(Ortalama Hata)* |     TBD |               TBD |              TBD |
| RMSE                         |     TBD |               TBD |              TBD |
| P95 Error *(P95 Hata)*       |     TBD |               TBD |              TBD |
| Final Error *(Final Hata)*   |     TBD |               TBD |              TBD |

---

# 129. No Invented Values (Uydurma Değer Olmaması)

All values remain `TBD` until final field evidence exists. *(Tüm value'lar final field evidence mevcut olana kadar `TBD` kalır.)*

---

# 130. Ablation Slide (Ablation Slide'ı)

A separate slide should explain what B and C reveal. *(Separate slide B ve C'nin ne gösterdiğini açıklamalıdır.)*

---

# 131. A-to-B Interpretation (A-to-B Yorumu)

A → B estimates the contribution of improved heading. *(A → B improved heading katkısını tahmin eder.)*

---

# 132. A-to-C Interpretation (A-to-C Yorumu)

A → C estimates the contribution of ARCore relative tracking. *(A → C ARCore relative tracking katkısını tahmin eder.)*

---

# 133. A-to-D Interpretation (A-to-D Yorumu)

A → D estimates the combined full-system improvement. *(A → D combined full-system improvement'ı tahmin eder.)*

---

# 134. No Additive Assumption (Additive Varsayım Olmaması)

The presentation must not imply that B and C improvements necessarily add linearly to D. *(Sunum B ve C improvement'larının necessarily linear şekilde D'ye eklendiğini ima etmemelidir.)*

---

# 135. Trajectory Comparison Slide (Trajectory Karşılaştırma Slide'ı)

At least one representative trajectory visualization should compare baseline PDR, full NAVGUARD, and ground truth. *(En az bir representative trajectory visualization baseline PDR, full NAVGUARD ve ground truth'u karşılaştırmalıdır.)*

---

# 136. Trajectory Plot Layers (Trajectory Plot Katmanları)

```text
Ground Truth
(Ground Truth)

Configuration A
(Configuration A)

Configuration D
(Configuration D)

Denial Start
(Denial Başlangıcı)

Recovery Point
(Recovery Noktası)
```

---

# 137. Representative Route Rule (Representative Rota Kuralı)

The representative route should not be selected only because it is the best NAVGUARD result. *(Representative route yalnızca en iyi NAVGUARD result olduğu için seçilmemelidir.)*

---

# 138. Route-Specific Result Slide (Rota Özel Sonuç Slide'ı)

Straight, turn-heavy, and closed-route behavior should be summarized separately. *(Straight, turn-heavy ve closed-route behavior ayrı summarized edilmelidir.)*

---

# 139. Route Result Candidate Table (Rota Sonuç Tablosu Adayı)

| Route Type (Rota Türü)     | A Median Error (A Median Hata) | D Median Error (D Median Hata) | Improvement (İyileştirme) |
| -------------------------- | -----------------------------: | -----------------------------: | ------------------------: |
| Straight *(Düz)*           |                            TBD |                            TBD |                       TBD |
| Turn-Heavy *(Dönüş Yoğun)* |                            TBD |                            TBD |                       TBD |
| Closed *(Kapalı)*          |                            TBD |                            TBD |                       TBD |

---

# 140. Error-over-Time Slide (Zamana Göre Hata Slide'ı)

A time-series plot may show horizontal position error from denial start to recovery. *(Time-series plot denial start'tan recovery'ye kadar horizontal position error gösterebilir.)*

---

# 141. Error-over-Time Markers (Zamana Göre Hata Marker'ları)

The denial start and pre-correction recovery boundary should be clearly marked. *(Denial start ve pre-correction recovery boundary açık şekilde marked edilmelidir.)*

---

# 142. Final Error Definition on Slide (Slide Üzerinde Final Error Tanımı)

The presentation should state that final denied error is measured before recovery correction. *(Sunum final denied error'ın recovery correction öncesinde measured edildiğini belirtmelidir.)*

---

# 143. No Post-Correction Result Inflation (Post-Correction Sonuç Şişirme Olmaması)

The near-zero post-relocalization position must not be used to make denied performance appear better. *(Near-zero post-relocalization position denied performance'ı better göstermek için kullanılmamalıdır.)*

---

# 144. Drift Slide (Drift Slide'ı)

A concise slide may report drift per minute and drift per travelled distance. *(Concise slide drift per minute ve drift per travelled distance raporlayabilir.)*

---

# 145. Step Detection Result Slide (Adım Tespiti Sonuç Slide'ı)

The final presentation should show controlled step-count performance. *(Final sunum controlled step-count performance göstermelidir.)*

---

# 146. Step Result Candidate (Step Sonuç Adayı)

```text
Reference Steps: TBD
(Referans Adım: TBD)

Detected Steps: TBD
(Tespit Edilen Adım: TBD)

Absolute Error: TBD
(Mutlak Hata: TBD)

Percentage Error: TBD
(Yüzde Hata: TBD)
```

---

# 147. Motion AI Result Slide (Motion AI Sonuç Slide'ı)

The AI result slide should include Macro F1, class-level metrics, confusion matrix, and mobile latency. *(AI result slide Macro F1, class-level metric'ler, confusion matrix ve mobile latency içermelidir.)*

---

# 148. AI Runtime Slide (AI Runtime Slide'ı)

The presentation should distinguish model inference latency from complete motion-context latency. *(Sunum model inference latency ile complete motion-context latency'yi ayırmalıdır.)*

---

# 149. Provisional AI Runtime Target Slide (Geçici AI Runtime Hedef Slide'ı)

```text
Target:
(Hedef:)

Approximately <50 ms per inference on Redmi Note 9 Pro.
(Redmi Note 9 Pro üzerinde inference başına yaklaşık <50 ms.)
```

---

# 150. ARCore Result Slide (ARCore Sonuç Slide'ı)

The final presentation should report tracking availability and tracking-loss behavior if ARCore is retained. *(ARCore retained edilirse final sunum tracking availability ve tracking-loss behavior raporlamalıdır.)*

---

# 151. ARCore Negative Result Rule (ARCore Negatif Sonuç Kuralı)

If ARCore provides no measurable navigation improvement, that result should be shown rather than hidden. *(ARCore measurable navigation improvement sağlamazsa bu result hidden edilmek yerine gösterilmelidir.)*

---

# 152. Recovery Result Slide (Recovery Sonuç Slide'ı)

The recovery slide should report pre-correction error and recovery latency. *(Recovery slide pre-correction error ve recovery latency raporlamalıdır.)*

---

# 153. Recovery Candidate Metrics (Recovery Aday Metrikleri)

```text
Pre-Correction Horizontal Error
(Düzeltme Öncesi Yatay Hata)

Validation Latency
(Validation Latency)

Relocalization Latency
(Relocalization Latency)

Total Recovery Latency
(Toplam Recovery Latency)
```

---

# 154. Uncertainty Result Slide (Belirsizlik Sonuç Slide'ı)

If uncertainty calibration evidence is defensible, the presentation may compare reported uncertainty with observed error. *(Uncertainty calibration evidence defensible ise sunum reported uncertainty ile observed error'ı karşılaştırabilir.)*

---

# 155. No Overconfidence Claim (Overconfidence İddiası Olmaması)

The presentation should discuss whether the covariance appears overconfident or conservative when evidence supports the analysis. *(Evidence analysis'i destekliyorsa sunum covariance'ın overconfident veya conservative görünüp görünmediğini tartışmalıdır.)*

---

# 156. Performance Result Slide (Performans Sonuç Slide'ı)

The final presentation should summarize the practical cost of full NAVGUARD on the Redmi Note 9 Pro. *(Final sunum Redmi Note 9 Pro üzerindeki full NAVGUARD practical cost'unu özetlemelidir.)*

---

# 157. Performance Metrics on Slide (Slide Üzerindeki Performans Metrikleri)

```text
AI latency.
(AI latency.)

Memory behavior.
(Memory behavior.)

Storage growth.
(Storage growth.)

Battery use.
(Batarya kullanımı.)

Thermal behavior.
(Termal davranış.)

ARCore resource cost.
(ARCore kaynak maliyeti.)
```

---

# 158. Resource Tradeoff Message (Kaynak Tradeoff Mesajı)

The presentation should state both accuracy improvement and resource cost. *(Sunum hem accuracy improvement hem resource cost'u belirtmelidir.)*

---

# 159. No Composite Efficiency Score (Composite Efficiency Score Olmaması)

A subjective composite score mixing accuracy and battery will not be used. *(Accuracy ve battery'yi karıştıran subjective composite score kullanılmayacaktır.)*

---

# 160. Failure Injection Slide (Failure Injection Slide'ı)

A technical audience should see evidence that the system was deliberately tested under failure conditions. *(Technical audience sistemin deliberately failure condition'lar altında test edildiğine dair evidence görmelidir.)*

---

# 161. Failure Injection Examples (Failure Injection Örnekleri)

```text
AI model failure.
(AI model hatası.)

ARCore tracking loss.
(ARCore tracking kaybı.)

Stale sensor input.
(Stale sensör girdisi.)

Bad recovery fix.
(Kötü recovery fix.)

Logging delay.
(Logging gecikmesi.)

Permission loss.
(Permission kaybı.)

Ground Truth Firewall injection attempt.
(Ground Truth Firewall injection denemesi.)
```

---

# 162. Fallback Result Slide (Fallback Sonuç Slide'ı)

The presentation may summarize whether each planned fallback passed. *(Sunum her planned fallback'in pass edip etmediğini summarize edebilir.)*

---

# 163. Fallback Candidate Table (Fallback Aday Tablosu)

| Failure (Hata)                                              | Expected Fallback (Beklenen Fallback)                         | Status (Durum) |
| ----------------------------------------------------------- | ------------------------------------------------------------- | -------------- |
| AI unavailable *(AI unavailable)*                           | Deterministic PDR *(Deterministic PDR)*                       | TBD            |
| ARCore lost *(ARCore kayıp)*                                | PDR *(PDR)*                                                   | TBD            |
| Learned step length invalid *(Learned step length invalid)* | Deterministic variable/fixed *(Deterministic variable/fixed)* | TBD            |
| EKF invalid *(EKF invalid)*                                 | Independent PDR *(Independent PDR)*                           | TBD            |

---

# 164. Scientific Integrity Slide (Bilimsel Bütünlük Slide'ı)

A dedicated slide should summarize the major controls protecting the research result. *(Dedicated slide research result'ı koruyan major control'leri summarize etmelidir.)*

---

# 165. Integrity Controls (Bütünlük Kontrolleri)

```text
Session-wise ML split.
(Session-wise ML split.)

Ground Truth Firewall.
(Ground Truth Firewall.)

Frozen benchmark build.
(Frozen benchmark build.)

Frozen metric pipeline.
(Frozen metric pipeline.)

No post-hoc tuning.
(Post-hoc tuning yok.)

No result-based session exclusion.
(Result-based session exclusion yok.)

Pre-correction recovery error capture.
(Pre-correction recovery error capture.)
```

---

# 166. Freeze Slide (Freeze Slide'ı)

The presentation should show that Day 21 froze the benchmark configuration before final field collection. *(Sunum Day 21'in final field collection öncesinde benchmark configuration'ı freeze ettiğini göstermelidir.)*

---

# 167. Freeze Items (Freeze Öğeleri)

```text
Build
(Build)

Models
(Modeller)

Thresholds
(Eşikler)

Routes
(Rotalar)

Inclusion rules
(Dahil etme kuralları)

Metric pipeline
(Metrik pipeline)
```

---

# 168. No Post-Hoc Tuning Message (Post-Hoc Tuning Olmaması Mesajı)

The presenter should explicitly state that final benchmark outcomes were not used to retune the system. *(Presenter final benchmark outcome'larının sistemi retune etmek için kullanılmadığını explicit belirtmelidir.)*

---

# 169. Session Inclusion Slide (Session Inclusion Slide'ı)

The presentation may summarize how many final sessions were valid, excluded, or limited. *(Sunum kaç final session'ın valid, excluded veya limited olduğunu summarize edebilir.)*

---

# 170. Exclusion Transparency (Exclusion Şeffaflığı)

Excluded sessions should have explicit integrity or reference-quality reasons. *(Excluded session'ların explicit integrity veya reference-quality reason'ları olmalıdır.)*

---

# 171. Poor Valid Session Rule (Kötü Valid Session Kuralı)

High error alone is not a valid exclusion reason. *(High error tek başına valid exclusion reason değildir.)*

---

# 172. Research Outcome Slide (Araştırma Sonucu Slide'ı)

The project result should be classified using the frozen research-outcome categories. *(Project result frozen research-outcome category'leri kullanılarak classified edilmelidir.)*

---

# 173. Outcome Categories (Sonuç Kategorileri)

```text
TARGET MET
(HEDEF KARŞILANDI)

PARTIAL IMPROVEMENT
(KISMİ İYİLEŞME)

NO MEASURABLE IMPROVEMENT
(ÖLÇÜLEBİLİR İYİLEŞME YOK)

REGRESSION
(GERİLEME)

INCONCLUSIVE
(SONUÇSUZ)
```

---

# 174. Negative Result Presentation (Negatif Sonuç Sunumu)

A negative result will be presented as a valid research outcome when the experiment and evidence remain valid. *(Experiment ve evidence valid kaldığında negative result valid research outcome olarak sunulacaktır.)*

---

# 175. No Forced Success Story (Zorla Başarı Hikâyesi Olmaması)

The presentation will not rewrite a failed target into a success claim. *(Sunum failed target'ı success claim'e dönüştürmeyecektir.)*

---

# 176. Limitations Slide (Sınırlamalar Slide'ı)

A strong technical presentation must include the major limitations before the conclusion. *(Güçlü technical presentation conclusion öncesinde major limitation'ları içermelidir.)*

---

# 177. Candidate Limitations (Aday Sınırlamalar)

```text
Single primary smartphone.
(Tek ana smartphone.)

Controlled phone placement.
(Kontrollü telefon yerleşimi.)

Limited participant diversity.
(Sınırlı katılımcı çeşitliliği.)

Smartphone GNSS as imperfect reference.
(Smartphone GNSS'in imperfect reference olması.)

Short-term denied navigation scope.
(Kısa süreli denied navigation scope.)

ARCore environment sensitivity.
(ARCore'un çevre koşullarına hassasiyeti.)

Magnetic-disturbance sensitivity.
(Manyetik bozulma hassasiyeti.)

No additional reference hardware.
(Ek referans donanımı yok.)
```

---

# 178. Limitation Tone (Sınırlama Tonu)

Limitations should be presented as engineering boundaries rather than apologies. *(Limitation'lar apology yerine engineering boundary olarak sunulmalıdır.)*

---

# 179. Future Work Slide (Gelecek Çalışmalar Slide'ı)

Future work should directly follow observed limitations and results. *(Future work observed limitation ve result'ları doğrudan takip etmelidir.)*

---

# 180. Candidate Future Work (Aday Gelecek Çalışmalar)

```text
Multi-device evaluation.
(Çoklu cihaz değerlendirmesi.)

More participants and phone placements.
(Daha fazla katılımcı ve telefon yerleşimi.)

Improved uncertainty calibration.
(Geliştirilmiş belirsizlik kalibrasyonu.)

Better visual-inertial fusion.
(Daha iyi görsel-ataletsel füzyon.)

Longer GNSS-denied routes.
(Daha uzun GNSS kesintili rotalar.)

Map constraints as a separately controlled experiment.
(Harita kısıtlarının ayrı kontrollü deney olarak incelenmesi.)

Additional sensors if future hardware allows.
(Gelecekte donanım izin verirse ek sensörler.)
```

---

# 181. No Hidden Map Matching Future Confusion (Gizli Map Matching Future Confusion Olmaması)

If map matching is proposed as future work, the presenter should clarify that the current benchmark does not use hidden road snapping. *(Map matching future work olarak proposed edilirse presenter current benchmark'ın hidden road snapping kullanmadığını açıklamalıdır.)*

---

# 182. Conclusion Slide (Sonuç Slide'ı)

The final technical conclusion should return to the original research question. *(Final technical conclusion original research question'a geri dönmelidir.)*

---

# 183. Conclusion Structure (Sonuç Yapısı)

The conclusion should state what was built, what was measured, what improved or failed to improve, and what the evidence supports. *(Conclusion neyin built edildiğini, neyin measured edildiğini, neyin improved veya fail olduğunu ve evidence'ın neyi desteklediğini belirtmelidir.)*

---

# 184. Conclusion Should Avoid Overclaiming (Conclusion Overclaiming'den Kaçınmalıdır)

The conclusion must remain scoped to the tested Redmi Note 9 Pro, routes, participants, and experiment conditions. *(Conclusion tested Redmi Note 9 Pro, route'lar, participant'lar ve experiment condition'lar ile scoped kalmalıdır.)*

---

# 185. Suggested Final Technical Message (Önerilen Final Teknik Mesaj)

NAVGUARD should be presented as a measured attempt to extend pedestrian navigation continuity during temporary GNSS denial using only standard smartphone sensors and on-device computation. *(NAVGUARD yalnızca standard smartphone sensor'ları ve on-device computation kullanarak temporary GNSS denial sırasında pedestrian navigation continuity'yi uzatmaya yönelik measured attempt olarak sunulmalıdır.)*

---

# 186. Demo Presentation Order (Demo Sunum Sırası)

The preferred order is explanation first, live demonstration second, benchmark evidence third. *(Preferred sıra önce explanation, ikinci live demonstration, üçüncü benchmark evidence'dır.)*

---

# 187. Why Demo Should Not Come First (Demo Neden İlk Olmamalıdır)

Starting with the demo may cause the audience to interpret NAVGUARD as only a mobile app rather than a research system. *(Demo ile başlamak audience'ın NAVGUARD'ı research system yerine yalnızca mobile app olarak yorumlamasına neden olabilir.)*

---

# 188. Why Results Follow Demo (Sonuçlar Neden Demo'yu Takip Eder)

Showing benchmark evidence after the live demo prevents the demonstration from becoming the primary proof of correctness. *(Live demo sonrasında benchmark evidence göstermek demonstration'ın primary proof of correctness haline gelmesini önler.)*

---

# 189. Slide Density Rule (Slide Yoğunluk Kuralı)

Slides should avoid dense paragraphs and instead use diagrams, equations, concise bullets, charts, and evidence. *(Slide'lar dense paragraph'lardan kaçınmalı ve diagram, equation, concise bullet, chart ve evidence kullanmalıdır.)*

---

# 190. One Main Message per Slide (Slide Başına Tek Ana Mesaj)

Each slide should communicate one principal idea. *(Her slide bir principal idea communicate etmelidir.)*

---

# 191. Code on Slides (Slide Üzerinde Kod)

Source code should appear only when one small implementation detail is essential to explain a technical guarantee. *(Source code yalnızca küçük bir implementation detail technical guarantee'yi açıklamak için essential olduğunda görünmelidir.)*

---

# 192. Equations on Slides (Slide Üzerinde Denklemler)

Only the most important equations should appear in the primary deck. *(Primary deck içerisinde yalnızca en önemli equation'lar görünmelidir.)*

---

# 193. Recommended Equations (Önerilen Denklemler)

```text
ΔE = L sin(ψ)
ΔN = L cos(ψ)

e = sqrt(e_E² + e_N²)
```

---

# 194. Backup Technical Slides (Yedek Teknik Slide'lar)

Detailed EKF Jacobians, covariance formulas, model architecture, schema diagrams, and test matrices may be placed in backup slides for questions. *(Detailed EKF Jacobian'ları, covariance formula'ları, model architecture, schema diagram'ları ve test matrix'leri question'lar için backup slide'lara konulabilir.)*

---

# 195. Suggested Main Deck Structure (Önerilen Ana Sunum Yapısı)

```text
01 — Problem
(Problem)

02 — Research Question
(Araştırma Sorusu)

03 — Scope & Boundaries
(Kapsam ve Sınırlar)

04 — System Architecture
(Sistem Mimarisi)

05 — Ground Truth Firewall
(Ground Truth Firewall)

06 — PDR
(PDR)

07 — Heading + Step Length
(Heading + Adım Uzunluğu)

08 — Motion AI
(Motion AI)

09 — ARCore
(ARCore)

10 — EKF + Quality Engine
(EKF + Quality Engine)

11 — Live Demo
(Canlı Demo)

12 — Benchmark Design
(Benchmark Tasarımı)

13 — A-D Results
(A-D Sonuçları)

14 — AI / Step / ARCore Results
(AI / Step / ARCore Sonuçları)

15 — Performance & Failure Testing
(Performans ve Failure Testing)

16 — Limitations
(Sınırlamalar)

17 — Conclusion
(Sonuç)
```

---

# 196. Main Deck Length (Ana Sunum Uzunluğu)

The exact slide count may be adjusted, but the deck should remain concise enough that benchmark evidence receives adequate speaking time. *(Exact slide count ayarlanabilir ancak deck benchmark evidence'a adequate speaking time kalacak kadar concise olmalıdır.)*

---

# 197. Backup Deck Structure (Yedek Sunum Yapısı)

Backup slides may contain detailed implementation evidence. *(Backup slide'lar detailed implementation evidence içerebilir.)*

---

# 198. Candidate Backup Slides (Aday Yedek Slide'lar)

```text
Device capability audit.
(Cihaz capability audit.)

Sensor delivered rates.
(Sensör delivered rate'leri.)

Timestamp-domain validation.
(Timestamp-domain validation.)

Step detector details.
(Step detector detayları.)

1D-CNN architecture.
(1D-CNN architecture.)

Dataset split diagram.
(Dataset split diagram.)

ARCore coordinate alignment.
(ARCore coordinate alignment.)

EKF Jacobian.
(EKF Jacobian.)

Quality-state machine.
(Quality-state machine.)

Recovery state machine.
(Recovery state machine.)

Failure-injection matrix.
(Failure-injection matrix.)

Performance traces.
(Performance trace'leri.)

Session evidence schema.
(Session evidence schema.)
```

---

# 199. Demo Device Preparation (Demo Cihaz Hazırlığı)

The physical Redmi Note 9 Pro should be prepared before the presentation. *(Fiziksel Redmi Note 9 Pro sunum öncesinde hazırlanmalıdır.)*

---

# 200. Demo Device Checklist (Demo Cihaz Checklist'i)

```text
Battery sufficient.
(Batarya yeterli.)

Device not charging.
(Cihaz şarjda değil.)

Required permissions granted.
(Gerekli izinler verilmiş.)

AI model verified.
(AI model doğrulanmış.)

ARCore ready if used.
(Kullanılıyorsa ARCore hazır.)

Storage sufficient.
(Depolama yeterli.)

Screen brightness controlled.
(Ekran parlaklığı kontrollü.)

Benchmark/demo build verified.
(Benchmark/demo build doğrulanmış.)

Notifications minimized.
(Bildirimler minimize edilmiş.)
```

---

# 201. Demo Build Identity (Demo Build Kimliği)

The presentation should record the exact build used for the live demo. *(Sunum live demo için kullanılan exact build'i kaydetmelidir.)*

---

# 202. Demo Model Identity (Demo Model Kimliği)

The exact AI model and hash used in the demo should be known. *(Demo'da kullanılan exact AI model ve hash bilinmelidir.)*

---

# 203. Demo Route Preparation (Demo Rota Hazırlığı)

The demo route should be predefined and safe. *(Demo route predefined ve safe olmalıdır.)*

---

# 204. Demo Route Requirements (Demo Rota Gereksinimleri)

The route should be short enough for a presentation but long enough to demonstrate denial, local motion, and recovery. *(Route presentation için yeterince short ancak denial, local motion ve recovery gösterecek kadar long olmalıdır.)*

---

# 205. Demo Route Safety (Demo Rota Güvenliği)

The route must avoid dangerous traffic, stairs requiring attention to the phone, or environments where the presenter cannot walk safely. *(Route dangerous traffic, telefona bakmayı gerektiren stair veya presenter'ın safe yürüyemeyeceği environment'lardan kaçınmalıdır.)*

---

# 206. Demo Operator (Demo Operator)

If practical, one person may operate the presentation while another walks the demo route. *(Practical ise bir kişi presentation'ı yönetirken başka biri demo route'u yürüyebilir.)*

---

# 207. Single-Person Demo (Tek Kişilik Demo)

If one person must present and operate the phone, the route and UI should be designed to minimize interaction while walking. *(Tek kişi hem present hem phone operate edecekse route ve UI walking sırasında interaction'ı minimize edecek şekilde designed edilmelidir.)*

---

# 208. Live Screen Mirroring (Canlı Ekran Yansıtma)

If a reliable screen-mirroring setup is available, the phone display may be mirrored for the audience. *(Reliable screen-mirroring setup available ise phone display audience için mirrored edilebilir.)*

---

# 209. Screen-Mirroring Risk (Ekran Yansıtma Riski)

Wireless mirroring may add battery, thermal, and network load. *(Wireless mirroring battery, thermal ve network load ekleyebilir.)*

---

# 210. Mirroring Mitigation (Yansıtma Mitigation)

The demo should be tested with the exact mirroring setup before presentation day. *(Demo presentation day öncesinde exact mirroring setup ile test edilmelidir.)*

---

# 211. Ground Truth Visibility in Mirroring (Yansıtma Sırasında Ground Truth Görünürlüğü)

Mirroring must not accidentally expose protected ground truth during the blinded interval. *(Mirroring blinded interval sırasında protected ground truth'u accidentally expose etmemelidir.)*

---

# 212. Backup Demo Strategy (Yedek Demo Stratejisi)

A pre-recorded demonstration may be prepared as backup evidence in case live environmental conditions make the demo impossible. *(Live environmental condition'lar demo'yu impossible hale getirirse backup evidence olarak pre-recorded demonstration hazırlanabilir.)*

---

# 213. Backup Demo Honesty Rule (Yedek Demo Dürüstlük Kuralı)

A recorded demonstration must be clearly identified as pre-recorded rather than presented as live. *(Recorded demonstration live gibi sunulmak yerine clearly pre-recorded olarak identified edilmelidir.)*

---

# 214. Backup Demo Should Use Real Build (Yedek Demo Gerçek Build Kullanmalıdır)

The backup recording should use the same or traceably equivalent frozen implementation. *(Backup recording aynı veya traceably equivalent frozen implementation kullanmalıdır.)*

---

# 215. Offline Replay Backup (Offline Replay Backup)

An offline replay of a previously recorded valid session should be available as a second technical fallback. *(Previously recorded valid session'ın offline replay'i second technical fallback olarak available olmalıdır.)*

---

# 216. Why Replay Is a Strong Backup (Replay Neden Güçlü Bir Backup'tır)

Replay can demonstrate estimator behavior deterministically even when field conditions are unsuitable for walking. *(Replay field condition'lar walking için unsuitable olduğunda bile estimator behavior'ı deterministically gösterebilir.)*

---

# 217. Demo Failure Contingency Order (Demo Failure Contingency Sırası)

```text
LIVE PHYSICAL DEMO
(Canlı Fiziksel Demo)

        ↓ if unavailable
        (kullanılamazsa)

VALID SESSION REPLAY
(Geçerli Session Replay)

        ↓ if unavailable
        (kullanılamazsa)

PRE-RECORDED DEMO
(Önceden Kaydedilmiş Demo)
```

---

# 218. No Fabricated Demo State (Uydurma Demo State Olmaması)

The presentation will not manually alter application state to simulate successful navigation without explaining the simulation. *(Sunum simulation'ı açıklamadan successful navigation simulate etmek için application state'i manually alter etmeyecektir.)*

---

# 219. Presentation Data Freeze (Sunum Veri Freeze)

All charts and tables in the final deck should be generated from the final accepted benchmark analysis version. *(Final deck içerisindeki tüm chart ve table'lar final accepted benchmark analysis version'dan generated edilmelidir.)*

---

# 220. Chart Reproducibility (Grafik Tekrarlanabilirliği)

Every major result chart should be reproducible from stored session and metric evidence. *(Her major result chart stored session ve metric evidence'dan reproducible olmalıdır.)*

---

# 221. Chart Labeling (Grafik Etiketleme)

Charts should clearly identify configuration, units, route type, and whether values are session-level or pooled. *(Chart'lar configuration, unit, route type ve value'ların session-level veya pooled olup olmadığını clearly identify etmelidir.)*

---

# 222. No Misleading Scale (Yanıltıcı Ölçek Olmaması)

Axis scaling should not exaggerate small differences. *(Axis scaling küçük difference'ları exaggerate etmemelidir.)*

---

# 223. No Hidden Exclusions (Gizli Exclusion Olmaması)

Result plots should not silently omit valid poor-performing sessions. *(Result plot'ları valid poor-performing session'ları silently omit etmemelidir.)*

---

# 224. Presentation Precision (Sunum Hassasiyeti)

Reported decimal precision should match measurement quality. *(Reported decimal precision measurement quality ile match etmelidir.)*

---

# 225. Presentation Terminology (Sunum Terminolojisi)

The same terminology used in the documentation should be used in the presentation. *(Documentation içerisinde kullanılan aynı terminology presentation içerisinde kullanılmalıdır.)*

---

# 226. Forbidden Terminology Drift (Terminoloji Sapmasının Yasaklanması)

The presenter should not casually rename the Ground Truth Firewall, denied interval, recovery error, or quality states during the presentation. *(Presenter Ground Truth Firewall, denied interval, recovery error veya quality state'leri presentation sırasında casually rename etmemelidir.)*

---

# 227. Final Error Terminology (Final Error Terminology)

`Final Position Error` always means the pre-correction denied-end horizontal error. *(`Final Position Error` her zaman pre-correction denied-end horizontal error anlamına gelir.)*

---

# 228. Confidence Terminology (Confidence Terminology)

Uncalibrated model scores should not be called probabilities. *(Uncalibrated model score'lar probability olarak adlandırılmamalıdır.)*

---

# 229. Quality Terminology (Quality Terminology)

The canonical Quality Engine states remain `UNKNOWN, GOOD, USABLE, DEGRADED, UNRELIABLE, UNAVAILABLE`. *(Canonical Quality Engine state'leri `UNKNOWN, GOOD, USABLE, DEGRADED, UNRELIABLE, UNAVAILABLE` olarak kalır.)*

---

# 230. Presentation Question Strategy (Sunum Soru Stratejisi)

The presentation should anticipate likely technical questions and prepare concise evidence-backed answers. *(Sunum likely technical question'ları anticipate etmeli ve concise evidence-backed answer'lar hazırlamalıdır.)*

---

# 231. Likely Question — Why Not Double Integrate Acceleration? (Olası Soru — Neden İvmeyi Double Integrate Etmiyorsunuz?)

The answer should explain that low-cost smartphone accelerometer bias and orientation error cause rapid unbounded drift, so the project uses step-event-driven PDR instead. *(Cevap low-cost smartphone accelerometer bias ve orientation error'ın rapid unbounded drift oluşturduğunu, bu nedenle projenin step-event-driven PDR kullandığını açıklamalıdır.)*

---

# 232. Likely Question — Why Use AI? (Olası Soru — Neden AI Kullanıyorsunuz?)

The answer should explain that AI provides motion context to improve navigation behavior, while deterministic PDR remains the fallback. *(Cevap AI'ın navigation behavior'ı iyileştirmek için motion context sağladığını, deterministic PDR'ın ise fallback olarak kaldığını açıklamalıdır.)*

---

# 233. Likely Question — Why ARCore? (Olası Soru — Neden ARCore?)

The answer should explain that ARCore provides relative visual-inertial displacement that may reduce pure PDR drift when tracking quality is good. *(Cevap ARCore'un tracking quality good olduğunda pure PDR drift'i azaltabilecek relative visual-inertial displacement sağladığını açıklamalıdır.)*

---

# 234. Likely Question — Does ARCore Give GPS Coordinates? (Olası Soru — ARCore GPS Koordinatı Veriyor mu?)

The answer is no; NAVGUARD explicitly aligns ARCore relative movement with the local ENU frame. *(Cevap hayırdır; NAVGUARD ARCore relative movement'ı local ENU frame ile explicitly align eder.)*

---

# 235. Likely Question — How Do You Know GNSS Was Not Used? (Olası Soru — GNSS'in Kullanılmadığını Nasıl Biliyorsunuz?)

The answer should reference the Ground Truth Firewall architecture, authorization path, runtime counter, replay mutation tests, and zero unauthorized update requirement. *(Cevap Ground Truth Firewall architecture, authorization path, runtime counter, replay mutation testleri ve zero unauthorized update requirement'a referans vermelidir.)*

---

# 236. Likely Question — Why Is Smartphone GNSS Ground Truth? (Olası Soru — Neden Smartphone GNSS Ground Truth?)

The answer should clarify that it is an independent evaluation reference with known limitations, not perfect survey-grade truth. *(Cevap bunun known limitation'lara sahip independent evaluation reference olduğunu, perfect survey-grade truth olmadığını açıklamalıdır.)*

---

# 237. Likely Question — Why Only One Phone? (Olası Soru — Neden Sadece Bir Telefon?)

The answer should explain that the project is intentionally scoped to a controlled single-device research PoC within the 24-business-day development window. *(Cevap projenin 24 iş günlük development window içerisinde controlled single-device research PoC olarak intentionally scoped edildiğini açıklamalıdır.)*

---

# 238. Likely Question — Why Only One Participant? (Olası Soru — Neden Tek Katılımcı?)

The answer should state that the initial objective is controlled proof-of-concept validation and that population generalization is outside the current claim scope. *(Cevap initial objective'in controlled proof-of-concept validation olduğunu ve population generalization'ın current claim scope dışında olduğunu belirtmelidir.)*

---

# 239. Likely Question — What Happens if ARCore Fails? (Olası Soru — ARCore Fail Olursa Ne Olur?)

The answer should state that ARCore updates are rejected and independent PDR continues if its inputs remain valid. *(Cevap ARCore update'lerinin rejected edildiğini ve input'ları valid kaldığında independent PDR'ın devam ettiğini belirtmelidir.)*

---

# 240. Likely Question — What Happens if AI Fails? (Olası Soru — AI Fail Olursa Ne Olur?)

The answer should state that the system falls back to deterministic navigation policy. *(Cevap sistemin deterministic navigation policy'ye fallback yaptığını belirtmelidir.)*

---

# 241. Likely Question — What Happens if Heading Fails? (Olası Soru — Heading Fail Olursa Ne Olur?)

The answer should explain that the system will not keep propagating confidently without a defensible direction source. *(Cevap sistemin defensible direction source olmadan confidently propagation'a devam etmeyeceğini açıklamalıdır.)*

---

# 242. Likely Question — Is the Map Used by the Estimator? (Olası Soru — Harita Estimator Tarafından Kullanılıyor mu?)

The answer is no; map tiles are visualization-only in the current architecture. *(Cevap hayırdır; current architecture içerisinde map tile'ları visualization-only'dir.)*

---

# 243. Likely Question — How Is Recovery Error Measured? (Olası Soru — Recovery Error Nasıl Ölçülüyor?)

The answer should state that the error is captured in the original ENU frame before any recovery correction. *(Cevap error'ın herhangi bir recovery correction öncesinde original ENU frame içerisinde captured edildiğini belirtmelidir.)*

---

# 244. Likely Question — Why Use Median Error? (Olası Soru — Neden Median Error Kullanılıyor?)

The answer should explain that median is robust to isolated spikes and is paired with mean, RMSE, P95, and final error for fuller interpretation. *(Cevap median'ın isolated spike'lara robust olduğunu ve fuller interpretation için mean, RMSE, P95 ve final error ile paired edildiğini açıklamalıdır.)*

---

# 245. Likely Question — Why 20%? (Olası Soru — Neden %20?)

The answer should state that it is a predeclared practical project target rather than a post-hoc success threshold. *(Cevap bunun post-hoc success threshold yerine predeclared practical project target olduğunu belirtmelidir.)*

---

# 246. Likely Question — What if 20% Is Not Achieved? (Olası Soru — %20 Sağlanmazsa Ne Olur?)

The answer should explain that the project remains technically complete if the experiment is valid, but the predefined research target is reported as not met. *(Cevap experiment valid ise projenin technically complete kalacağını ancak predefined research target'ın not met olarak raporlanacağını açıklamalıdır.)*

---

# 247. Likely Question — What Is the Main Innovation? (Olası Soru — Ana Yenilik Nedir?)

The answer should avoid claiming novelty that has not been established through literature review. *(Cevap literature review üzerinden established edilmemiş novelty claim'lerinden kaçınmalıdır.)*

The project contribution should instead be described as an integrated, reproducible smartphone research implementation combining controlled GNSS denial, PDR, AI motion context, relative visual-inertial tracking, quality-aware fusion, and evidence-based evaluation. *(Project contribution bunun yerine controlled GNSS denial, PDR, AI motion context, relative visual-inertial tracking, quality-aware fusion ve evidence-based evaluation'ı birleştiren integrated, reproducible smartphone research implementation olarak tanımlanmalıdır.)*

---

# 248. Demo Rehearsal Requirement (Demo Prova Gereksinimi)

The complete presentation and demo should be rehearsed using the actual device and actual presentation environment when possible. *(Complete presentation ve demo mümkün olduğunda actual device ve actual presentation environment kullanılarak rehearsed edilmelidir.)*

---

# 249. Rehearsal Checklist (Prova Checklist'i)

```text
Application starts cleanly.
(Uygulama temiz şekilde başlıyor.)

Readiness completes.
(Readiness tamamlanıyor.)

Anchor acquisition works.
(Anchor acquisition çalışıyor.)

Denial works.
(Denial çalışıyor.)

Ground truth remains hidden.
(Ground truth gizli kalıyor.)

PDR / fusion updates.
(PDR / fusion update oluyor.)

Recovery works.
(Recovery çalışıyor.)

Session finalizes.
(Session finalize oluyor.)

Screen mirroring works if used.
(Kullanılıyorsa screen mirroring çalışıyor.)

Backup replay is ready.
(Backup replay hazır.)
```

---

# 250. Rehearsal Failure Logging (Prova Hata Logging)

Any failure found during rehearsal should be documented and classified before presentation day. *(Rehearsal sırasında bulunan herhangi bir failure presentation day öncesinde documented ve classified edilmelidir.)*

---

# 251. No Last-Minute Feature Development (Son Dakika Feature Development Olmaması)

Major new functionality should not be added immediately before the presentation. *(Major new functionality presentation hemen öncesinde eklenmemelidir.)*

---

# 252. Presentation-Day Build Stability (Sunum Günü Build Stabilitesi)

The presentation should use a stable verified build rather than the newest untested build. *(Sunum newest untested build yerine stable verified build kullanmalıdır.)*

---

# 253. Demo Session Separation (Demo Session Ayrımı)

Demo sessions should be labeled separately from final benchmark sessions. *(Demo session'ları final benchmark session'larından separate label almalıdır.)*

---

# 254. Demo Data Must Not Enter Final Benchmark (Demo Verisi Final Benchmark'a Girmemelidir)

Demo data must not silently become part of the final benchmark dataset. *(Demo data final benchmark dataset'in sessizce parçası olmamalıdır.)*

---

# 255. Presentation Artifact Traceability (Sunum Artifact İzlenebilirliği)

Final charts, screenshots, and tables should retain source session or analysis references internally. *(Final chart, screenshot ve table'lar internally source session veya analysis reference'larını retain etmelidir.)*

---

# 256. Screenshot Honesty (Screenshot Dürüstlüğü)

Screenshots should represent actual application states rather than mockups presented as runtime evidence. *(Screenshot'lar runtime evidence gibi sunulan mockup'lar yerine actual application state'lerini represent etmelidir.)*

---

# 257. Video Honesty (Video Dürüstlüğü)

Recorded video should not cut away in a way that hides critical failures unless editing is explicitly disclosed. *(Recorded video critical failure'ları gizleyecek şekilde cut away etmemeli, editing varsa explicitly disclosed edilmelidir.)*

---

# 258. Final Presentation Evidence Package (Final Sunum Evidence Paketi)

The final presentation package should be preserved alongside the benchmark evidence. *(Final presentation package benchmark evidence ile birlikte preserved edilmelidir.)*

---

# 259. Candidate Presentation Package (Aday Sunum Paketi)

```text
Final slide deck.
(Final slide deck.)

Backup technical slides.
(Backup technical slide'lar.)

Demo checklist.
(Demo checklist.)

Demo build identity.
(Demo build kimliği.)

Demo model identity.
(Demo model kimliği.)

Benchmark charts.
(Benchmark chart'ları.)

Representative trajectory plots.
(Representative trajectory plot'ları.)

Failure-injection summary.
(Failure-injection özeti.)

Final acceptance summary.
(Final acceptance özeti.)
```

---

# 260. Presentation Acceptance Criteria (Sunum Kabul Kriterleri)

The presentation is considered ready only when its technical claims match the frozen final evidence. *(Sunum technical claim'leri frozen final evidence ile match ettiğinde ready kabul edilir.)*

---

# 261. Demo Acceptance Criteria (Demo Kabul Kriterleri)

The live demo is considered ready when the intended lifecycle can be completed safely on the target device or replay fallback is available. *(Live demo intended lifecycle target device üzerinde safely completed edilebildiğinde veya replay fallback available olduğunda ready kabul edilir.)*

---

# 262. Ground Truth Presentation Acceptance (Ground Truth Sunum Kabulü)

Protected ground truth must remain hidden during the live denied interval. *(Protected ground truth live denied interval sırasında hidden kalmalıdır.)*

---

# 263. Evidence Presentation Acceptance (Evidence Sunum Kabulü)

Every headline result in the deck must map to final accepted metric evidence. *(Deck içerisindeki her headline result final accepted metric evidence'a map edilmelidir.)*

---

# 264. Negative Result Presentation Acceptance (Negatif Sonuç Sunum Kabulü)

Negative or partial results must not be removed merely because they weaken the narrative. *(Negative veya partial result'lar narrative'i zayıflattığı için removed edilmemelidir.)*

---

# 265. Limitation Presentation Acceptance (Sınırlama Sunum Kabulü)

Material limitations must appear before the final conclusion. *(Material limitation'lar final conclusion öncesinde görünmelidir.)*

---

# 266. Final Presentation Non-Goals (Final Sunumun Hedefi Olmayanlar)

The presentation will not attempt to prove military deployment readiness. *(Sunum military deployment readiness prove etmeye çalışmayacaktır.)*

The presentation will not imply general Android-device performance from one primary phone. *(Sunum tek primary phone'dan general Android-device performance ima etmeyecektir.)*

The presentation will not hide failed optional subsystems. *(Sunum failed optional subsystem'leri gizlemeyecektir.)*

---

# 267. Additional Presentation Non-Goals (Ek Sunum Hedefi Olmayanlar)

The presentation will not use visual map accuracy as the only proof of performance. *(Sunum visual map accuracy'yi performance'ın tek kanıtı olarak kullanmayacaktır.)*

The presentation will not use corrected recovery position as denied-navigation accuracy. *(Sunum corrected recovery position'ı denied-navigation accuracy olarak kullanmayacaktır.)*

The presentation will not treat AI classification accuracy as equivalent to navigation improvement. *(Sunum AI classification accuracy'yi navigation improvement ile equivalent kabul etmeyecektir.)*

---

# 268. Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kararlar)

The final presentation will follow the sequence problem → architecture → demo → benchmark → limitations → conclusion. *(Final presentation problem → architecture → demo → benchmark → limitations → conclusion sırasını izleyecektir.)*

---

# 269. Demo Integrity Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Demo Bütünlük Kararları)

The live demo will use the real navigation architecture rather than a separate simplified estimator. *(Live demo separate simplified estimator yerine real navigation architecture kullanacaktır.)*

---

# 270. Ground Truth Visibility Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Ground Truth Görünürlük Kararları)

Protected GNSS ground truth will remain hidden from the main navigation view during the blinded denied interval. *(Protected GNSS ground truth blinded denied interval sırasında main navigation view'dan hidden kalacaktır.)*

---

# 271. Demo Lifecycle Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Demo Lifecycle Kararları)

The preferred live demo sequence is readiness → anchor → GNSS mode → denial → NAVGUARD local navigation → recovery → pre-correction capture → relocalization → finalization. *(Preferred live demo sequence readiness → anchor → GNSS mode → denial → NAVGUARD local navigation → recovery → pre-correction capture → relocalization → finalization olarak sabitlenmiştir.)*

---

# 272. Fallback Demo Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Fallback Demo Kararları)

AI or ARCore failure may be shown openly as deterministic fallback behavior rather than hidden as a presentation defect. *(AI veya ARCore failure presentation defect olarak gizlenmek yerine deterministic fallback behavior olarak açıkça gösterilebilir.)*

---

# 273. Replay Backup Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Replay Backup Kararları)

A valid-session replay will be the preferred technical backup if a live physical demo cannot be completed. *(Live physical demo completed edilemezse valid-session replay preferred technical backup olacaktır.)*

---

# 274. Presentation Result Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Sunum Sonuç Kararları)

Final benchmark results will appear after the live demo and will remain the primary evidence of system performance. *(Final benchmark result'ları live demo sonrasında gösterilecek ve system performance'ın primary evidence'ı olarak kalacaktır.)*

---

# 275. Primary Comparison Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Temel Karşılaştırma Kararları)

Configuration A versus Configuration D will be the primary benchmark comparison shown in the main deck. *(Configuration A versus Configuration D main deck içerisinde gösterilecek primary benchmark comparison olacaktır.)*

---

# 276. Target Visibility Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Hedef Görünürlüğü Kararları)

The `≥20%` primary improvement target will be shown before revealing the final result. *(Final result gösterilmeden önce `≥20%` primary improvement target gösterilecektir.)*

---

# 277. AI Result Decisions Frozen by This Document (Bu Dokümanla Sabitlenen AI Sonuç Kararları)

The AI slide will report held-out session-wise metrics and on-device latency rather than training performance. *(AI slide training performance yerine held-out session-wise metric'ler ve on-device latency raporlayacaktır.)*

---

# 278. ARCore Result Decisions Frozen by This Document (Bu Dokümanla Sabitlenen ARCore Sonuç Kararları)

ARCore will be presented as a relative-motion enhancement with PDR fallback rather than an independent global-position system. *(ARCore independent global-position system yerine PDR fallback'e sahip relative-motion enhancement olarak sunulacaktır.)*

---

# 279. Recovery Result Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Recovery Sonuç Kararları)

Recovery performance will use pre-correction error and separate recovery latency metrics. *(Recovery performance pre-correction error ve separate recovery latency metric'leri kullanacaktır.)*

---

# 280. Research Integrity Presentation Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Araştırma Bütünlüğü Sunum Kararları)

The presentation will explicitly mention session-wise ML splitting, Ground Truth Firewall isolation, benchmark freeze, no post-hoc tuning, and no result-based exclusion. *(Sunum session-wise ML splitting, Ground Truth Firewall isolation, benchmark freeze, no post-hoc tuning ve no result-based exclusion'ı explicit olarak belirtecektir.)*

---

# 281. Limitation Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Sınırlama Kararları)

Material limitations will be presented before the conclusion and will not be hidden from the audience. *(Material limitation'lar conclusion öncesinde sunulacak ve audience'dan gizlenmeyecektir.)*

---

# 282. Negative Result Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Negatif Sonuç Kararları)

A negative or partial final result will be presented as a valid research outcome if the experiment remains valid. *(Experiment valid kalırsa negative veya partial final result valid research outcome olarak sunulacaktır.)*

---

# 283. Presentation-Day Stability Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Sunum Günü Stabilite Kararları)

The presentation will use a verified stable build instead of introducing last-minute major changes. *(Sunum last-minute major change eklemek yerine verified stable build kullanacaktır.)*

---

# 284. Final Demo & Presentation Statement (Nihai Demo ve Sunum Bildirimi)

**NAVGUARD will be presented as a reproducible GNSS-denied pedestrian-navigation research prototype whose credibility comes from controlled estimator isolation, deterministic fallbacks, matched benchmark comparison, preserved evidence, and transparent limitations rather than from one visually successful map trajectory.** *(NAVGUARD credibility'si tek visually successful map trajectory'den değil controlled estimator isolation, deterministic fallback'lar, matched benchmark comparison, preserved evidence ve transparent limitation'lardan gelen reproducible GNSS-denied pedestrian-navigation research prototype olarak sunulacaktır.)*

**The main presentation will first establish the navigation problem and research question, then explain the sensor, PDR, AI, ARCore, quality, EKF, Ground Truth Firewall, and recovery architecture before showing the live system.** *(Ana sunum önce navigation problem ve research question'ı belirleyecek, ardından live system gösterilmeden önce sensor, PDR, AI, ARCore, quality, EKF, Ground Truth Firewall ve recovery architecture'ı açıklayacaktır.)*

**The live demo will follow the complete operational lifecycle from readiness and GNSS anchoring through software denial, local NAVGUARD navigation, uncertainty display, protected recovery, pre-correction evidence capture, relocalization, and session finalization, while protected GNSS ground truth remains hidden during the blinded denied interval.** *(Live demo readiness ve GNSS anchoring'den software denial, local NAVGUARD navigation, uncertainty display, protected recovery, pre-correction evidence capture, relocalization ve session finalization'a kadar complete operational lifecycle'ı takip edecek; protected GNSS ground truth ise blinded denied interval sırasında hidden kalacaktır.)*

**Optional subsystem failures such as AI unavailability or ARCore tracking loss will not be hidden during the demonstration; they may instead be used to show that deterministic PDR fallback remains operational and that the system explicitly reports degraded capability.** *(AI unavailability veya ARCore tracking loss gibi optional subsystem failure'ları demonstration sırasında gizlenmeyecek; bunun yerine deterministic PDR fallback'in operational kaldığını ve sistemin degraded capability'yi explicit olarak raporladığını göstermek için kullanılabilir.)*

**After the live demo, the presentation will transition to the frozen benchmark evidence, with Configuration A versus Configuration D forming the primary comparison and Configurations B and C providing ablation evidence for improved heading and ARCore contribution.** *(Live demo sonrasında sunum frozen benchmark evidence'a geçecek; Configuration A versus Configuration D primary comparison'ı oluştururken Configuration B ve C improved heading ve ARCore contribution için ablation evidence sağlayacaktır.)*

**The predefined `≥20%` matched-session median-error reduction target will be shown before the final result, and the final conclusion will report the observed research outcome exactly as measured, whether it is target met, partial improvement, no measurable improvement, regression, or inconclusive.** *(Predefined `≥20%` matched-session median-error reduction target final result öncesinde gösterilecek ve final conclusion observed research outcome'ı target met, partial improvement, no measurable improvement, regression veya inconclusive olmasına bakılmaksızın exactly measured şekilde raporlayacaktır.)*

**Presentation charts, tables, AI metrics, trajectory plots, recovery results, performance data, and failure-testing summaries will all derive from the frozen accepted analysis evidence, preventing the final narrative from being disconnected from the actual benchmark system.** *(Presentation chart'ları, table'ları, AI metric'leri, trajectory plot'ları, recovery result'ları, performance data ve failure-testing summary'leri frozen accepted analysis evidence'dan derive edilecek; böylece final narrative'in actual benchmark system'den disconnected olması önlenecektir.)*

**The final presentation will close by separating what NAVGUARD demonstrably achieved from what remains limited or future work, so the project can be evaluated as an honest engineering and research contribution rather than an overclaimed product demonstration.** *(Final presentation NAVGUARD'ın demonstrably neyi achieve ettiğini limited veya future work olarak kalanlardan ayırarak kapanacak; böylece proje overclaimed product demonstration yerine honest engineering ve research contribution olarak değerlendirilebilecektir.)*

---

# 285. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development Demo & Presentation Plan Completed *(Doküman Durumu: Geliştirme Öncesi Demo ve Sunum Planı Tamamlandı)*

**Primary Presentation Order:** Problem → Architecture → Demo → Benchmark → Limitations → Conclusion *(Temel Sunum Sırası: Problem → Architecture → Demo → Benchmark → Limitations → Conclusion)*

**Presentation Primary Message:** Short-Term GNSS-Denied Pedestrian Navigation Continuity *(Sunum Temel Mesajı: Kısa Süreli GNSS Kesintili Yaya Navigasyon Sürekliliği)*

**Presentation Research Scope:** Android / Redmi Note 9 Pro / Pedestrian / Software-Defined Denial *(Sunum Araştırma Scope'u: Android / Redmi Note 9 Pro / Yaya / Software-Defined Denial)*

**Military-Grade Claim:** Forbidden *(Military-Grade Claim: Yasak)*

**Permanent GNSS Replacement Claim:** Forbidden *(Permanent GNSS Replacement Claim: Yasak)*

**RF Jamming / Spoofing Demo:** Not Used *(RF Jamming / Spoofing Demo: Kullanılmaz)*

**Architecture Slide:** Mandatory *(Architecture Slide: Zorunlu)*

**Ground Truth Firewall Slide:** Mandatory *(Ground Truth Firewall Slide: Zorunlu)*

**Ground Truth Firewall Counter Result:** Show When Measured *(Ground Truth Firewall Counter Sonucu: Ölçüldüğünde Gösterilir)*

**Protected GNSS Visible During Denied Demo:** No *(Protected GNSS Denied Demo Sırasında Görünür mü: Hayır)*

**Demo Uses Real Navigation Architecture:** Yes *(Demo Gerçek Navigation Architecture Kullanır: Evet)*

**Separate Simplified Demo Estimator:** Forbidden *(Ayrı Simplified Demo Estimator: Yasak)*

**Preferred Demo Lifecycle:** Readiness → Anchor → GNSS → Denial → NAVGUARD → Recovery → Pre-Correction Capture → Relocalization → Finalization *(Preferred Demo Lifecycle: Readiness → Anchor → GNSS → Denial → NAVGUARD → Recovery → Pre-Correction Capture → Relocalization → Finalization)*

**Main Demo Map During Denial:** Estimated Position + Trajectory + Uncertainty + Quality *(Denial Sırasında Main Demo Map: Estimated Position + Trajectory + Uncertainty + Quality)*

**Ground Truth Reveal:** After Denied Interval *(Ground Truth Reveal: Denied Interval Sonrasında)*

**AI Panel:** Optional but Recommended *(AI Panel: İsteğe Bağlı ama Önerilir)*

**ARCore Panel:** Optional but Recommended if Enabled *(ARCore Panel: Enabled ise İsteğe Bağlı ama Önerilir)*

**Raw Diagnostics on Main Demo Screen:** Avoided *(Main Demo Screen Üzerinde Raw Diagnostics: Kaçınılır)*

**AI Failure Demo Behavior:** Deterministic PDR Fallback *(AI Failure Demo Behavior: Deterministic PDR Fallback)*

**ARCore Failure Demo Behavior:** PDR Continues *(ARCore Failure Demo Behavior: PDR Devam Eder)*

**No Safe Estimate:** `UNRELIABLE / UNAVAILABLE` *(Safe Estimate Yoksa: `UNRELIABLE / UNAVAILABLE`)*

**Primary Demo Backup:** Valid Session Replay *(Primary Demo Backup: Valid Session Replay)*

**Secondary Demo Backup:** Pre-Recorded Demonstration *(Secondary Demo Backup: Pre-Recorded Demonstration)*

**Pre-Recorded Demo Must Be Labeled:** Yes *(Pre-Recorded Demo Label Gerektirir: Evet)*

**Demo Session Used as Final Benchmark Data:** No *(Demo Session Final Benchmark Data Olarak Kullanılır mı: Hayır)*

**Primary Benchmark Comparison in Main Deck:** A vs D *(Main Deck'te Primary Benchmark Comparison: A vs D)*

**Ablation Configurations:** B + C *(Ablation Configuration'lar: B + C)*

**Primary Metric on Main Result Slide:** Aggregated Matched-Session Median Position Error *(Main Result Slide'daki Primary Metric: Aggregated Matched-Session Median Position Error)*

**Primary Improvement Target:** `≥20%` vs Configuration A *(Primary Improvement Target: Configuration A'ya Göre `≥20%`)*

**Target Shown Before Result:** Yes *(Target Sonuçtan Önce Gösterilir: Evet)*

**Core Position Metrics:** Mean + Median + RMSE + P95 + Final Pre-Correction Error *(Core Position Metrics: Mean + Median + RMSE + P95 + Final Pre-Correction Error)*

**Representative Trajectory Plot:** Required *(Representative Trajectory Plot: Gerekli)*

**Representative Route Cherry-Picked Only for Best Result:** Forbidden *(Representative Route Yalnızca Best Result İçin Cherry-Pick: Yasak)*

**Motion AI Slide:** Held-Out Macro F1 + Confusion Matrix + Mobile Latency *(Motion AI Slide: Held-Out Macro F1 + Confusion Matrix + Mobile Latency)*

**AI Training Accuracy as Primary Result:** Forbidden *(AI Training Accuracy Primary Result Olarak: Yasak)*

**ARCore Presented as Global Position Source:** Forbidden *(ARCore Global Position Source Olarak Sunulur mu: Yasak)*

**Recovery Result:** Pre-Correction Error + Latency *(Recovery Result: Pre-Correction Error + Latency)*

**Post-Relocalization Error as Denied Performance:** Forbidden *(Post-Relocalization Error Denied Performance Olarak: Yasak)*

**Failure Injection Summary:** Recommended *(Failure Injection Summary: Önerilir)*

**Scientific Integrity Slide:** Recommended / High Priority *(Scientific Integrity Slide: Önerilir / Yüksek Öncelik)*

**Final Benchmark Freeze Mentioned:** Yes *(Final Benchmark Freeze Belirtilir: Evet)*

**No Post-Hoc Tuning Mentioned:** Yes *(No Post-Hoc Tuning Belirtilir: Evet)*

**No Result-Based Session Exclusion Mentioned:** Yes *(No Result-Based Session Exclusion Belirtilir: Evet)*

**Negative Result Hidden:** Forbidden *(Negative Result Gizleme: Yasak)*

**Research Outcome Categories:** `TARGET MET / PARTIAL IMPROVEMENT / NO MEASURABLE IMPROVEMENT / REGRESSION / INCONCLUSIVE` *(Research Outcome Categories: `TARGET MET / PARTIAL IMPROVEMENT / NO MEASURABLE IMPROVEMENT / REGRESSION / INCONCLUSIVE`)*

**Limitations Slide:** Mandatory *(Limitations Slide: Zorunlu)*

**Future Work Slide:** Recommended *(Future Work Slide: Önerilir)*

**Single-Device Generalization Claim:** Forbidden *(Single-Device Generalization Claim: Yasak)*

**Map Matching in Current Estimator:** Not Used *(Current Estimator'da Map Matching: Kullanılmaz)*

**Presentation Uses Stable Verified Build:** Mandatory *(Presentation Stable Verified Build Kullanır: Zorunlu)*

**Last-Minute Major Feature Addition:** Avoided *(Last-Minute Major Feature Addition: Kaçınılır)*

**Presentation Charts from Frozen Analysis:** Mandatory *(Presentation Chart'ları Frozen Analysis'ten: Zorunlu)*

**Headline Results Traceable to Evidence:** Mandatory *(Headline Result'lar Evidence'a Traceable: Zorunlu)*

**Final Presentation Package Preserved:** Recommended *(Final Presentation Package Preserved: Önerilir)*

**Next Documentation Item:** 41 — Final Results & Experimental Findings *(Sonraki Dokümantasyon Öğesi: 41 — Final Sonuçlar ve Deneysel Bulgular)*
