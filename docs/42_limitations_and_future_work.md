# 42 — Limitations & Future Work (Sınırlamalar ve Gelecek Çalışmalar)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the known technical, experimental, platform, data, evaluation, deployment, and research limitations of NAVGUARD and identifies future work that may extend the current prototype beyond its initial scope. *(Bu doküman NAVGUARD’ın bilinen teknik, deneysel, platform, veri, değerlendirme, deployment ve research limitation’larını tanımlar ve current prototype’ı initial scope’un ötesine taşıyabilecek future work alanlarını belirler.)*

The purpose is to ensure that final conclusions remain proportional to the evidence actually collected. *(Amaç final conclusion’ların gerçekten toplanan evidence ile orantılı kalmasını sağlamaktır.)*

---

# 2. Limitation Philosophy (Sınırlama Felsefesi)

NAVGUARD limitations are engineering boundaries rather than defects that should be hidden. *(NAVGUARD limitation’ları gizlenmesi gereken defect’ler yerine engineering boundary’lerdir.)*

A limitation should be reported whenever it materially affects how a result can be interpreted or generalized. *(Bir limitation result’ın nasıl interpreted veya generalized edilebileceğini materially etkiliyorsa raporlanmalıdır.)*

---

# 3. No Overclaiming Principle (Aşırı İddia Etmeme İlkesi)

NAVGUARD will not claim capabilities beyond those demonstrated by the implemented system and final benchmark evidence. *(NAVGUARD implemented system ve final benchmark evidence tarafından demonstrated edilenlerin ötesinde capability claim etmeyecektir.)*

---

# 4. Result-Dependent Limitations (Sonuca Bağlı Sınırlamalar)

Some limitations can only be finalized after Page 41 contains measured results. *(Bazı limitation’lar yalnızca Page 41 measured result içerdiğinde finalize edilebilir.)*

Until then, such items remain anticipated limitations rather than measured findings. *(O zamana kadar bu item’lar measured finding yerine anticipated limitation olarak kalacaktır.)*

---

# 5. Limitation Categories (Sınırlama Kategorileri)

NAVGUARD limitations will be organized into the following categories. *(NAVGUARD limitation’ları aşağıdaki category’lerde düzenlenecektir.)*

```text id="v1q7oc"
DEVICE
(CİHAZ)

PLATFORM
(PLATFORM)

SENSOR
(SENSÖR)

POSITION REFERENCE
(KONUM REFERANSI)

PDR
(PDR)

HEADING
(HEADING)

ARCORE
(ARCORE)

AI / DATASET
(AI / DATASET)

STEP LENGTH
(ADIM UZUNLUĞU)

EKF / UNCERTAINTY
(EKF / BELİRSİZLİK)

GROUND TRUTH
(GROUND TRUTH)

FIELD EXPERIMENT
(SAHA DENEYİ)

GENERALIZATION
(GENELLEME)

PERFORMANCE
(PERFORMANS)

BATTERY / THERMAL
(BATARYA / TERMAL)

SOFTWARE / PRODUCTIZATION
(YAZILIM / ÜRÜNLEŞTİRME)

RESEARCH DESIGN
(ARAŞTIRMA TASARIMI)
```

---

# 6. Primary Device Limitation (Ana Cihaz Sınırlaması)

The initial project is centered on the Xiaomi Redmi Note 9 Pro. *(Initial proje Xiaomi Redmi Note 9 Pro merkezlidir.)*

Results from this device cannot automatically be generalized to all Android smartphones. *(Bu cihazdan elde edilen result’lar tüm Android smartphone’lara otomatik olarak generalize edilemez.)*

---

# 7. Why Device Generalization Is Limited (Cihaz Genellemesi Neden Sınırlıdır)

Android phones use different IMUs, magnetometers, GNSS chipsets, camera systems, sensor drivers, thermal policies, and operating-system implementations. *(Android telefonlar farklı IMU, magnetometer, GNSS chipset, camera system, sensor driver, thermal policy ve operating-system implementation kullanır.)*

These differences can materially affect PDR, heading, ARCore, AI timing, and runtime behavior. *(Bu difference’lar PDR, heading, ARCore, AI timing ve runtime behavior’ı materially etkileyebilir.)*

---

# 8. Sensor Vendor Limitation (Sensör Vendor Sınırlaması)

Sensor characteristics observed on one Redmi Note 9 Pro unit may not match another production batch exactly. *(Bir Redmi Note 9 Pro unit üzerinde observed sensor characteristic’leri başka bir production batch ile exactly match etmeyebilir.)*

---

# 9. Android Version Limitation (Android Sürümü Sınırlaması)

The validated behavior will apply primarily to the Android version used during final testing. *(Validated behavior primarily final testing sırasında kullanılan Android version’a uygulanacaktır.)*

Future Android versions may change permission behavior, sensor scheduling, background limits, ARCore behavior, or runtime APIs. *(Future Android version’lar permission behavior, sensor scheduling, background limit, ARCore behavior veya runtime API’leri değiştirebilir.)*

---

# 10. Android Fragmentation Limitation (Android Fragmentation Sınırlaması)

Android device fragmentation limits any assumption that one native implementation will behave identically across manufacturers. *(Android device fragmentation tek bir native implementation’ın manufacturer’lar arasında identically behave edeceği assumption’ını sınırlar.)*

---

# 11. Single-Platform Limitation (Tek Platform Sınırlaması)

NAVGUARD is not validated on iOS. *(NAVGUARD iOS üzerinde validated değildir.)*

No cross-platform performance claim will be made. *(Cross-platform performance claim yapılmayacaktır.)*

---

# 12. Additional Hardware Limitation (Ek Donanım Sınırlaması)

The current project intentionally uses no external IMU, RTK receiver, UWB node, beacon infrastructure, wheel encoder, or other navigation hardware. *(Current proje intentionally external IMU, RTK receiver, UWB node, beacon infrastructure, wheel encoder veya other navigation hardware kullanmaz.)*

This keeps the system accessible but limits reference quality and absolute navigation performance. *(Bu durum sistemi accessible tutar ancak reference quality ve absolute navigation performance’ı sınırlar.)*

---

# 13. Commodity Sensor Limitation (Tüketici Sınıfı Sensör Sınırlaması)

Smartphone inertial sensors are consumer-grade sensors rather than precision navigation instruments. *(Smartphone inertial sensor’ları precision navigation instrument yerine consumer-grade sensor’lardır.)*

Bias, scale-factor error, noise, temperature sensitivity, and device-specific calibration can therefore affect results. *(Bu nedenle bias, scale-factor error, noise, temperature sensitivity ve device-specific calibration result’ları etkileyebilir.)*

---

# 14. Accelerometer Limitation (İvmeölçer Sınırlaması)

The accelerometer measures device acceleration rather than pedestrian position directly. *(Accelerometer pedestrian position’ı directly ölçmek yerine device acceleration ölçer.)*

Step detection therefore depends on signal-processing assumptions and phone placement. *(Bu nedenle step detection signal-processing assumption’ları ve phone placement’a bağlıdır.)*

---

# 15. Gyroscope Limitation (Jiroskop Sınırlaması)

Gyroscope integration can accumulate orientation bias over time. *(Gyroscope integration zamanla orientation bias biriktirebilir.)*

Without periodic absolute correction, heading error may grow. *(Periodic absolute correction olmadan heading error büyüyebilir.)*

---

# 16. Magnetometer Limitation (Manyetometre Sınırlaması)

Magnetometer measurements are highly sensitive to nearby ferromagnetic material and electronic equipment. *(Magnetometer measurement’ları nearby ferromagnetic material ve electronic equipment’a oldukça sensitive’dir.)*

---

# 17. Indoor Magnetic Environment Limitation (İç Mekân Manyetik Ortam Sınırlaması)

Buildings may contain reinforcement steel, electrical infrastructure, elevators, vehicles, and equipment that distort the local magnetic field. *(Building’ler local magnetic field’ı distort eden reinforcement steel, electrical infrastructure, elevator, vehicle ve equipment içerebilir.)*

---

# 18. Magnetic Calibration Limitation (Manyetik Kalibrasyon Sınırlaması)

Even a calibrated device may experience temporary local magnetic disturbances that cannot be removed by calibration alone. *(Calibrated device bile yalnız calibration ile removed edilemeyen temporary local magnetic disturbance yaşayabilir.)*

---

# 19. Rotation Vector Limitation (Rotation Vector Sınırlaması)

Android Rotation Vector is itself a fused sensor output and its internal vendor algorithm may not be fully transparent. *(Android Rotation Vector kendisi fused sensor output’tur ve internal vendor algorithm’i fully transparent olmayabilir.)*

---

# 20. Barometer Availability Limitation (Barometre Kullanılabilirlik Sınırlaması)

Barometer use depends on physical availability on the target device and will not be assumed before the device audit confirms it. *(Barometer kullanımı target device üzerindeki physical availability’ye bağlıdır ve device audit doğrulamadan önce assumed edilmeyecektir.)*

---

# 21. Vertical Navigation Limitation (Dikey Navigasyon Sınırlaması)

The primary research objective is horizontal pedestrian navigation rather than precise floor-level or vertical navigation. *(Primary research objective precise floor-level veya vertical navigation yerine horizontal pedestrian navigation’dır.)*

---

# 22. Altitude Limitation (İrtifa Sınırlaması)

Smartphone GNSS altitude and optional pressure-based height estimates may be considerably less reliable than horizontal position. *(Smartphone GNSS altitude ve optional pressure-based height estimate’leri horizontal position’dan considerably less reliable olabilir.)*

---

# 23. GNSS Reference Limitation (GNSS Referans Sınırlaması)

Evaluation Mode uses smartphone GNSS as an independent position reference rather than survey-grade ground truth. *(Evaluation Mode survey-grade ground truth yerine smartphone GNSS’i independent position reference olarak kullanır.)*

---

# 24. Smartphone GNSS Accuracy Limitation (Smartphone GNSS Accuracy Sınırlaması)

The GNSS reference may contain multipath error, urban-canyon distortion, atmospheric error, delayed fixes, and chipset filtering effects. *(GNSS reference multipath error, urban-canyon distortion, atmospheric error, delayed fix ve chipset filtering effect içerebilir.)*

---

# 25. Reference Error Contamination (Referans Hata Kontaminasyonu)

Observed NAVGUARD position error includes uncertainty from both the estimator and the GNSS reference. *(Observed NAVGUARD position error hem estimator hem GNSS reference uncertainty’sini içerir.)*

---

# 26. Absolute Accuracy Interpretation Limitation (Mutlak Accuracy Yorumlama Sınırlaması)

Small differences between configurations may be difficult to interpret when they approach the noise level of the smartphone reference. *(Configuration’lar arasındaki küçük difference’lar smartphone reference noise level’ına yaklaştığında interpret etmek zor olabilir.)*

---

# 27. Outdoor Reference Preference (Dış Mekân Referans Tercihi)

Primary continuous position-error evaluation is therefore better suited to outdoor routes with reasonably usable GNSS reference quality. *(Bu nedenle primary continuous position-error evaluation reasonably usable GNSS reference quality’ye sahip outdoor route’lara daha uygundur.)*

---

# 28. Indoor Reference Limitation (İç Mekân Referans Sınırlaması)

Indoor GNSS may be unavailable or too degraded to support continuous position-error evaluation. *(Indoor GNSS continuous position-error evaluation’ı desteklemek için unavailable veya çok degraded olabilir.)*

---

# 29. Indoor Evaluation Alternative Limitation (İç Mekân Evaluation Alternatif Sınırlaması)

Known-distance, checkpoint, or closure-error methods can support indoor evaluation but do not provide the same information as continuous reference trajectories. *(Known-distance, checkpoint veya closure-error method’ları indoor evaluation’ı support edebilir ancak continuous reference trajectory ile aynı information’ı sağlamaz.)*

---

# 30. Ground Truth Terminology Limitation (Ground Truth Terminology Sınırlaması)

The term `ground truth` in implementation logs should be interpreted as the protected evaluation reference rather than perfect physical truth. *(`ground truth` terimi implementation log’larında perfect physical truth yerine protected evaluation reference olarak interpreted edilmelidir.)*

---

# 31. GNSS Denial Simulation Limitation (GNSS Kesintisi Simülasyonu Sınırlaması)

NAVGUARD uses software-defined denial rather than an actual RF-denied environment. *(NAVGUARD actual RF-denied environment yerine software-defined denial kullanır.)*

---

# 32. Why Software Denial Is Different (Software Denial Neden Farklıdır)

Software denial blocks estimator access to GNSS but does not reproduce every hardware-level effect of a real jamming environment. *(Software denial estimator’ın GNSS access’ini block eder ancak real jamming environment’ın her hardware-level effect’ini reproduce etmez.)*

---

# 33. No Jamming Claim (Jamming Claim Olmaması)

The project therefore cannot claim validated behavior under real GNSS jamming. *(Bu nedenle proje real GNSS jamming altında validated behavior claim edemez.)*

---

# 34. No Spoofing Claim (Spoofing Claim Olmaması)

The project does not evaluate GNSS spoofing detection or spoof-resilient navigation. *(Proje GNSS spoofing detection veya spoof-resilient navigation evaluate etmez.)*

---

# 35. Denial Integrity Strength (Denial Integrity Gücü)

Software denial still provides a strong research mechanism for testing whether the estimator can continue without receiving GNSS updates. *(Software denial yine de estimator’ın GNSS update almadan continue edip edemediğini test etmek için strong research mechanism sağlar.)*

---

# 36. Initial Anchor Dependency (Initial Anchor Bağımlılığı)

NAVGUARD requires a valid initial global position anchor before GNSS-denied navigation begins. *(NAVGUARD GNSS-denied navigation başlamadan önce valid initial global position anchor gerektirir.)*

---

# 37. No Cold-Start Global Localization (Cold-Start Global Localization Olmaması)

The current architecture does not solve arbitrary global localization from an unknown position without GNSS or another global reference. *(Current architecture GNSS veya another global reference olmadan unknown position’dan arbitrary global localization problem’ini çözmez.)*

---

# 38. Anchor Error Persistence (Anchor Hatası Kalıcılığı)

An inaccurate initial anchor can shift the entire estimated trajectory even when local displacement is accurate. *(Inaccurate initial anchor local displacement accurate olsa bile entire estimated trajectory’yi shift edebilir.)*

---

# 39. Short-Term Navigation Scope (Kısa Süreli Navigasyon Scope’u)

NAVGUARD is intended for short-term continuity during temporary GNSS loss. *(NAVGUARD temporary GNSS loss sırasında short-term continuity için tasarlanmıştır.)*

---

# 40. Long-Duration Drift Limitation (Uzun Süreli Drift Sınırlaması)

Dead-reckoning error generally accumulates with time and travelled distance when no absolute correction is available. *(Absolute correction available olmadığında dead-reckoning error generally time ve travelled distance ile accumulate eder.)*

---

# 41. Permanent GNSS Replacement Limitation (Kalıcı GNSS Yerine Geçme Sınırlaması)

The prototype should not be interpreted as a permanent GNSS replacement. *(Prototype permanent GNSS replacement olarak interpreted edilmemelidir.)*

---

# 42. PDR Model Limitation (PDR Model Sınırlaması)

The baseline PDR model represents pedestrian motion as discrete accepted steps with estimated step length and heading. *(Baseline PDR model pedestrian motion’ı estimated step length ve heading’e sahip discrete accepted step’ler olarak represent eder.)*

---

# 43. Non-Step Motion Limitation (Adım Dışı Hareket Sınırlaması)

Movement that does not resemble ordinary pedestrian stepping may not be represented well by the current PDR model. *(Ordinary pedestrian stepping’e benzemeyen movement current PDR model tarafından iyi represent edilmeyebilir.)*

---

# 44. Stair and Escalator Limitation (Merdiven ve Yürüyen Merdiven Sınırlaması)

Stairs, escalators, elevators, crawling, vehicles, and other movement modes are outside the primary validated scope unless explicitly tested. *(Stair, escalator, elevator, crawling, vehicle ve other movement mode’lar explicitly tested edilmedikçe primary validated scope dışındadır.)*

---

# 45. Walking Style Limitation (Yürüme Stili Sınırlaması)

Step timing and acceleration patterns vary between people and may also vary within the same person across speed, fatigue, footwear, and terrain. *(Step timing ve acceleration pattern’ları kişiler arasında değişir ve aynı kişide speed, fatigue, footwear ve terrain’e göre de değişebilir.)*

---

# 46. Fixed Step-Length Limitation (Sabit Step-Length Sınırlaması)

A calibrated fixed step length cannot represent all variations in gait. *(Calibrated fixed step length gait içerisindeki tüm variation’ları represent edemez.)*

---

# 47. Variable Step-Length Limitation (Değişken Step-Length Sınırlaması)

Deterministic variable step-length models still rely on simplified relationships between acceleration waveform and actual stride. *(Deterministic variable step-length model’lar acceleration waveform ile actual stride arasındaki simplified relationship’lere dayanır.)*

---

# 48. Learned Step-Length Label Limitation (Learned Step-Length Label Sınırlaması)

Accurate per-step ground-truth step length is difficult to obtain without external measurement infrastructure. *(Accurate per-step ground-truth step length external measurement infrastructure olmadan elde edilmesi zordur.)*

---

# 49. Route-Average Label Limitation (Route-Average Label Sınırlaması)

A route-average step length label does not capture genuine variation from one step to another. *(Route-average step length label step’ten step’e genuine variation’ı capture etmez.)*

---

# 50. Segment-Level Label Limitation (Segment-Level Label Sınırlaması)

Segment-level labels improve granularity but still remain approximations unless exact footfall positions are independently measured. *(Segment-level label’lar granularity’yi improve eder ancak exact footfall position’lar independently measured edilmedikçe approximation olarak kalır.)*

---

# 51. Step-Length ML Generalization Limitation (Step-Length ML Genelleme Sınırlaması)

A learned step-length model trained on limited participants or one phone placement may not generalize to new users or placements. *(Limited participant veya one phone placement üzerinde trained learned step-length model new user veya placement’lara generalize olmayabilir.)*

---

# 52. Step Detection Threshold Limitation (Step Detection Threshold Sınırlaması)

Thresholds calibrated for the target device and placement may not remain optimal under substantially different conditions. *(Target device ve placement için calibrated threshold’lar substantially different condition’larda optimal kalmayabilir.)*

---

# 53. Step Detection False Positive Limitation (Step Detection False Positive Sınırlaması)

Phone shaking or repetitive non-walking motion may produce step-like waveforms. *(Phone shaking veya repetitive non-walking motion step-like waveform üretebilir.)*

---

# 54. Step Detection False Negative Limitation (Step Detection False Negative Sınırlaması)

Very soft, irregular, or unusual steps may be missed. *(Very soft, irregular veya unusual step’ler missed olabilir.)*

---

# 55. Heading Dominance Limitation (Heading Dominance Sınırlaması)

Even small systematic heading error can cause significant lateral drift over distance. *(Küçük systematic heading error bile distance boyunca significant lateral drift oluşturabilir.)*

---

# 56. True-North Correction Limitation (True-North Correction Sınırlaması)

Geomagnetic declination correction improves magnetic-to-true-north conversion but does not correct local magnetic distortion. *(Geomagnetic declination correction magnetic-to-true-north conversion’ı improve eder ancak local magnetic distortion’ı correct etmez.)*

---

# 57. Phone Orientation Limitation (Telefon Orientation Sınırlaması)

Heading estimation depends on how the device coordinate frame relates to the user’s walking direction. *(Heading estimation device coordinate frame’in user walking direction ile nasıl relate olduğuna bağlıdır.)*

---

# 58. Body-Heading vs Device-Heading Limitation (Body-Heading vs Device-Heading Sınırlaması)

The direction the phone points is not always the same as the direction the pedestrian is travelling. *(Phone’un pointing direction’ı pedestrian’ın travelling direction’ı ile her zaman aynı değildir.)*

---

# 59. Controlled Placement Rationale (Controlled Placement Gerekçesi)

A controlled placement is therefore necessary in the initial benchmark to reduce uncontrolled orientation variation. *(Bu nedenle uncontrolled orientation variation’ı azaltmak için initial benchmark’ta controlled placement gereklidir.)*

---

# 60. Placement Generalization Limitation (Placement Genelleme Sınırlaması)

Results from one placement should not be generalized to hand-held, pocket, backpack, chest, and other placements without testing. *(One placement’tan elde edilen result’lar testing olmadan hand-held, pocket, backpack, chest ve other placement’lara generalize edilmemelidir.)*

---

# 61. ARCore Environmental Limitation (ARCore Çevresel Sınırlaması)

ARCore visual-inertial tracking depends on camera-visible scene information. *(ARCore visual-inertial tracking camera-visible scene information’a bağlıdır.)*

---

# 62. Low-Texture Limitation (Low-Texture Sınırlaması)

Uniform walls, dark corridors, open low-feature areas, and visually repetitive environments may reduce tracking quality. *(Uniform wall, dark corridor, open low-feature area ve visually repetitive environment tracking quality’yi azaltabilir.)*

---

# 63. Lighting Limitation (Aydınlatma Sınırlaması)

Poor lighting can reduce visual feature detection and tracking reliability. *(Poor lighting visual feature detection ve tracking reliability’yi azaltabilir.)*

---

# 64. Excessive Motion Limitation (Aşırı Hareket Sınırlaması)

Rapid phone motion or motion blur can degrade visual tracking. *(Rapid phone motion veya motion blur visual tracking’i degrade edebilir.)*

---

# 65. Camera Occlusion Limitation (Kamera Kapanması Sınırlaması)

If the camera is obstructed by clothing, a hand, or another object, ARCore tracking may degrade or stop. *(Camera clothing, hand veya another object tarafından obstructed edilirse ARCore tracking degrade olabilir veya stop edebilir.)*

---

# 66. ARCore World-Frame Limitation (ARCore World-Frame Sınırlaması)

ARCore does not provide a stable global geographic coordinate frame by default. *(ARCore default olarak stable global geographic coordinate frame sağlamaz.)*

---

# 67. Relative Tracking Limitation (Relative Tracking Sınırlaması)

NAVGUARD therefore uses ARCore as relative displacement information rather than absolute latitude and longitude. *(Bu nedenle NAVGUARD ARCore’u absolute latitude ve longitude yerine relative displacement information olarak kullanır.)*

---

# 68. ARCore Alignment Limitation (ARCore Alignment Sınırlaması)

ARCore-to-ENU alignment introduces its own uncertainty and may become invalid after tracking loss or substantial frame changes. *(ARCore-to-ENU alignment kendi uncertainty’sini getirir ve tracking loss veya substantial frame change sonrasında invalid hale gelebilir.)*

---

# 69. ARCore Segment Discontinuity Limitation (ARCore Segment Discontinuity Sınırlaması)

Restarting tracking as a new segment preserves integrity but reduces continuity between visual segments. *(Tracking’i new segment olarak restart etmek integrity’yi preserve eder ancak visual segment’ler arasındaki continuity’yi azaltır.)*

---

# 70. ARCore Drift Limitation (ARCore Drift Sınırlaması)

ARCore itself can drift and must not be treated as perfect relative ground truth. *(ARCore kendisi drift edebilir ve perfect relative ground truth olarak treated edilmemelidir.)*

---

# 71. ARCore Timestamp Limitation (ARCore Timestamp Sınırlaması)

ARCore timestamp-domain alignment requires empirical validation. *(ARCore timestamp-domain alignment empirical validation gerektirir.)*

---

# 72. ARCore Device Support Limitation (ARCore Cihaz Desteği Sınırlaması)

ARCore behavior and support vary across Android devices. *(ARCore behavior ve support Android device’lar arasında değişir.)*

---

# 73. ARCore Resource Limitation (ARCore Kaynak Sınırlaması)

Continuous camera and visual-inertial processing may substantially increase CPU, battery, and thermal load. *(Continuous camera ve visual-inertial processing CPU, battery ve thermal load’u substantially artırabilir.)*

---

# 74. Camera Privacy Limitation (Kamera Privacy Sınırlaması)

Using ARCore requires camera access even when raw camera frames are not stored. *(Raw camera frame’leri stored edilmese bile ARCore kullanmak camera access gerektirir.)*

---

# 75. Raw Camera Storage Decision (Raw Kamera Storage Kararı)

The current design does not require continuous storage of raw camera images. *(Current design raw camera image’ların continuous storage’unu gerektirmez.)*

---

# 76. AI Dataset Scope Limitation (AI Dataset Scope Sınırlaması)

The Motion Classification dataset is intentionally limited by the 24-business-day project schedule. *(Motion Classification dataset 24 iş günlük project schedule nedeniyle intentionally sınırlıdır.)*

---

# 77. Participant Diversity Limitation (Katılımcı Çeşitliliği Sınırlaması)

The initial dataset may contain data primarily from one controlled participant or a small participant set. *(Initial dataset primarily one controlled participant veya small participant set’ten data içerebilir.)*

---

# 78. Population Generalization Limitation (Population Genelleme Sınırlaması)

The resulting Motion Classification model cannot automatically be claimed to generalize across age, body type, gait, mobility characteristics, or population groups. *(Resulting Motion Classification model age, body type, gait, mobility characteristic veya population group’lar arasında automatically generalize olduğu claim edilemez.)*

---

# 79. Motion-Class Simplification Limitation (Motion-Class Simplification Sınırlaması)

The four-class taxonomy simplifies continuous human movement into `STATIONARY`, `WALKING`, `RUNNING`, and `TURNING`. *(Four-class taxonomy continuous human movement’ı `STATIONARY`, `WALKING`, `RUNNING` ve `TURNING` olarak simplify eder.)*

---

# 80. TURNING Overlap Limitation (TURNING Overlap Sınırlaması)

`TURNING` can occur simultaneously with walking and is therefore an operational dominant-context label rather than a mutually exclusive physical state. *(`TURNING` walking ile simultaneously occur edebilir ve bu nedenle mutually exclusive physical state yerine operational dominant-context label’dır.)*

---

# 81. Transition Label Limitation (Transition Label Sınırlaması)

Transitions between motion classes are intrinsically ambiguous. *(Motion class’lar arasındaki transition’lar intrinsically ambiguous’dır.)*

---

# 82. Manual Annotation Limitation (Manual Annotation Sınırlaması)

Protocol markers and offline review reduce ambiguity but still contain human labeling uncertainty. *(Protocol marker’lar ve offline review ambiguity’yi azaltır ancak yine de human labeling uncertainty içerir.)*

---

# 83. Windowing Limitation (Windowing Sınırlaması)

Window-based classification introduces latency because a complete sensor window must exist before classification. *(Window-based classification complete sensor window classification öncesinde exist etmesi gerektiği için latency oluşturur.)*

---

# 84. Window Boundary Limitation (Window Boundary Sınırlaması)

Motion transitions occurring near window boundaries can create mixed-context windows. *(Window boundary yakınında occurring motion transition’lar mixed-context window oluşturabilir.)*

---

# 85. Sampling Irregularity Limitation (Sampling Irregularity Sınırlaması)

Actual Android sensor delivery is not perfectly uniform even when a nominal sampling rate is requested. *(Nominal sampling rate requested edilse bile actual Android sensor delivery perfectly uniform değildir.)*

---

# 86. Resampling Limitation (Resampling Sınırlaması)

Resampling can create small interpolation artifacts when adapting irregular sensor timing to regular model tensors. *(Resampling irregular sensor timing’i regular model tensor’larına adapt ederken small interpolation artifact oluşturabilir.)*

---

# 87. Model Generalization Limitation (Model Genelleme Sınırlaması)

A model that performs well on held-out sessions from the same controlled study may still perform differently in substantially different environments or device placements. *(Aynı controlled study’den held-out session’larda iyi perform eden model substantially different environment veya device placement’ta farklı perform edebilir.)*

---

# 88. Dataset Size Limitation (Dataset Boyutu Sınırlaması)

The project dataset is not expected to match the scale of large commercial human-activity-recognition datasets. *(Project dataset’in large commercial human-activity-recognition dataset scale’ini match etmesi beklenmez.)*

---

# 89. Class Imbalance Limitation (Class Imbalance Sınırlaması)

Natural collection may create unequal representation between motion classes. *(Natural collection motion class’lar arasında unequal representation oluşturabilir.)*

---

# 90. Training Target Limitation (Training Target Sınırlaması)

Macro F1 ≥0.90 is a project target rather than evidence of universal model robustness. *(Macro F1 ≥0.90 universal model robustness evidence’ı yerine project target’tır.)*

---

# 91. AI Confidence Limitation (AI Confidence Sınırlaması)

Raw softmax output is a model score and may not be a calibrated probability. *(Raw softmax output model score’dur ve calibrated probability olmayabilir.)*

---

# 92. AI Runtime Limitation (AI Runtime Sınırlaması)

The provisional inference target of approximately 50 ms applies to the selected device and final measured runtime configuration only. *(Yaklaşık 50 ms olan provisional inference target yalnızca selected device ve final measured runtime configuration’a uygulanır.)*

---

# 93. AI Navigation-Effect Limitation (AI Navigasyon Etkisi Sınırlaması)

Good classification performance does not guarantee improved navigation accuracy. *(Good classification performance improved navigation accuracy guarantee etmez.)*

---

# 94. AI Causality Limitation (AI Causality Sınırlaması)

Live AI decisions must remain causal, which prevents the use of future sensor samples that might improve offline classification. *(Live AI decision’lar causal kalmalıdır ve bu durum offline classification’ı improve edebilecek future sensor sample’ların kullanımını engeller.)*

---

# 95. On-Device Model Limitation (On-Device Model Sınırlaması)

On-device deployment imposes constraints on model size, latency, memory, and compatibility. *(On-device deployment model size, latency, memory ve compatibility üzerinde constraint oluşturur.)*

---

# 96. Quantization Limitation (Quantization Sınırlaması)

Quantization may improve runtime efficiency but can reduce numerical precision or model accuracy. *(Quantization runtime efficiency’yi improve edebilir ancak numerical precision veya model accuracy’yi azaltabilir.)*

---

# 97. Delegate Limitation (Delegate Sınırlaması)

GPU or other hardware delegates may have device-specific behavior and are not assumed to be superior to CPU execution. *(GPU veya other hardware delegate’ler device-specific behavior’a sahip olabilir ve CPU execution’dan superior olduğu assumed edilmez.)*

---

# 98. No On-Device Retraining Limitation (On-Device Retraining Olmaması Sınırlaması)

The current system does not perform online model retraining or continual learning on the phone. *(Current system telefon üzerinde online model retraining veya continual learning gerçekleştirmez.)*

---

# 99. Personalization Limitation (Kişiselleştirme Sınırlaması)

The current Motion Classification model is not designed as an automatically personalized model for each user. *(Current Motion Classification model her user için automatically personalized model olarak tasarlanmamıştır.)*

---

# 100. EKF Model Limitation (EKF Model Sınırlaması)

The initial EKF intentionally uses the compact state `[E,N,ψ]`. *(Initial EKF intentionally compact state `[E,N,ψ]` kullanır.)*

---

# 101. Velocity-State Limitation (Velocity-State Sınırlaması)

Explicit East and North velocity states are not part of the frozen minimum filter unless later experiments demonstrate benefit. *(Explicit East ve North velocity state’leri later experiment’ler benefit demonstrate etmedikçe frozen minimum filter’ın parçası değildir.)*

---

# 102. Simplified Process Model Limitation (Basitleştirilmiş Process Model Sınırlaması)

The EKF process model inherits the assumptions and errors of step-based PDR. *(EKF process model step-based PDR assumption ve error’larını inherit eder.)*

---

# 103. Noise-Model Limitation (Noise Model Sınırlaması)

`Q` and `R` are modeling approximations and may not perfectly represent true sensor-error distributions. *(`Q` ve `R` modeling approximation’lardır ve true sensor-error distribution’ları perfectly represent etmeyebilir.)*

---

# 104. Gaussian Assumption Limitation (Gaussian Assumption Sınırlaması)

EKF uncertainty interpretation often relies on approximately Gaussian error assumptions that may not hold under magnetic disturbances, ARCore resets, or severe outliers. *(EKF uncertainty interpretation often approximately Gaussian error assumption’larına dayanır ve bunlar magnetic disturbance, ARCore reset veya severe outlier altında hold etmeyebilir.)*

---

# 105. Measurement Independence Limitation (Measurement Independence Sınırlaması)

Some estimator inputs may contain partially correlated information. *(Bazı estimator input’ları partially correlated information içerebilir.)*

---

# 106. ARCore Correlation Limitation (ARCore Correlation Sınırlaması)

Treating PDR and ARCore pseudo-position updates as fully independent may overstate confidence if correlation exists. *(Correlation mevcutsa PDR ve ARCore pseudo-position update’lerini fully independent treat etmek confidence’ı overstate edebilir.)*

---

# 107. Conservative Fusion Limitation (Conservative Fusion Sınırlaması)

Using conservative covariance reduces overconfidence risk but may also reduce the apparent benefit of additional sensors. *(Conservative covariance kullanmak overconfidence risk’ini azaltır ancak additional sensor’ların apparent benefit’ini de azaltabilir.)*

---

# 108. NIS Gate Limitation (NIS Gate Sınırlaması)

Innovation gating depends on thresholds and covariance quality. *(Innovation gating threshold ve covariance quality’ye bağlıdır.)*

---

# 109. Outlier Interpretation Limitation (Outlier Interpretation Sınırlaması)

A large innovation may indicate either a bad measurement or a genuinely drifted estimator. *(Large innovation bad measurement veya genuinely drifted estimator gösterebilir.)*

---

# 110. Uncertainty Calibration Limitation (Belirsizlik Kalibrasyonu Sınırlaması)

The covariance produced by the EKF is a model-based uncertainty estimate and is not automatically empirically calibrated. *(EKF tarafından produced covariance model-based uncertainty estimate’tir ve automatically empirically calibrated değildir.)*

---

# 111. Confidence Ellipse Limitation (Confidence Ellipse Sınırlaması)

A formal confidence percentage should not be attached to an uncertainty ellipse unless calibration supports that interpretation. *(Calibration desteklemedikçe uncertainty ellipse’e formal confidence percentage attach edilmemelidir.)*

---

# 112. Limited Uncertainty Sample Limitation (Sınırlı Belirsizlik Sample Sınırlaması)

A small number of field sessions may not be sufficient for strong covariance-calibration conclusions. *(Small number of field session strong covariance-calibration conclusion’ları için sufficient olmayabilir.)*

---

# 113. NEES Limitation (NEES Sınırlaması)

NEES-style consistency analysis may be difficult to interpret when the position reference itself contains significant uncertainty. *(Position reference kendisi significant uncertainty içerdiğinde NEES-style consistency analysis interpret etmek zor olabilir.)*

---

# 114. Ground Truth Firewall Scope Limitation (Ground Truth Firewall Scope Sınırlaması)

The Ground Truth Firewall protects against prohibited GNSS estimator updates within the application architecture. *(Ground Truth Firewall application architecture içerisindeki prohibited GNSS estimator update’lerine karşı koruma sağlar.)*

---

# 115. Operating-System Trust Limitation (Operating-System Trust Sınırlaması)

The project does not claim security against a compromised Android operating system or malicious hardware. *(Proje compromised Android operating system veya malicious hardware’a karşı security claim etmez.)*

---

# 116. Application-Level Integrity Limitation (Application-Level Integrity Sınırlaması)

Ground Truth Firewall guarantees are application-architecture guarantees rather than cryptographically verified hardware isolation. *(Ground Truth Firewall guarantee’leri cryptographically verified hardware isolation yerine application-architecture guarantee’leridir.)*

---

# 117. Replay Integrity Limitation (Replay Integrity Sınırlaması)

Replay determinism depends on preserving the full set of required raw inputs, configuration, schema versions, and model artifacts. *(Replay determinism required raw input set’inin, configuration’ın, schema version’larının ve model artifact’larının preserved olmasına bağlıdır.)*

---

# 118. Missing Evidence Limitation (Eksik Evidence Sınırlaması)

A session with missing critical evidence may become unusable for some metrics even if the application appeared to run normally. *(Missing critical evidence’a sahip session application apparently normal run etse bile bazı metric’ler için unusable olabilir.)*

---

# 119. Storage Format Limitation (Storage Format Sınırlaması)

CSV and JSON are research-friendly but less storage-efficient than specialized binary formats. *(CSV ve JSON research-friendly’dir ancak specialized binary format’lardan less storage-efficient’tir.)*

---

# 120. Logging Overhead Limitation (Logging Overhead Sınırlaması)

Detailed scientific logging adds CPU, storage, and I/O overhead that would be smaller in a production-only application. *(Detailed scientific logging production-only application’da daha küçük olacak CPU, storage ve I/O overhead ekler.)*

---

# 121. Benchmark-vs-Production Runtime Limitation (Benchmark-vs-Production Runtime Sınırlaması)

Formal benchmark mode may consume more resources than a future optimized product mode because it preserves extensive evidence. *(Formal benchmark mode extensive evidence preserve ettiği için future optimized product mode’dan daha fazla resource consume edebilir.)*

---

# 122. Battery Measurement Limitation (Batarya Ölçüm Sınırlaması)

Battery percentage is a coarse operating-system estimate and may not provide precise energy consumption measurements. *(Battery percentage coarse operating-system estimate’tir ve precise energy consumption measurement sağlamayabilir.)*

---

# 123. Charging-State Limitation (Şarj Durumu Sınırlaması)

Battery tests performed while charging would not provide comparable consumption evidence and are therefore unsuitable for formal battery comparison. *(Charging sırasında performed battery test’leri comparable consumption evidence sağlamaz ve formal battery comparison için unsuitable’dır.)*

---

# 124. Thermal Measurement Limitation (Termal Ölçüm Sınırlaması)

Available Android thermal indicators may not expose precise component temperatures for every subsystem. *(Available Android thermal indicator’ları her subsystem için precise component temperature expose etmeyebilir.)*

---

# 125. Environmental Thermal Limitation (Çevresel Termal Sınırlama)

Ambient temperature, direct sunlight, device case, screen brightness, and network activity can influence thermal behavior. *(Ambient temperature, direct sunlight, device case, screen brightness ve network activity thermal behavior’ı influence edebilir.)*

---

# 126. Performance Reproducibility Limitation (Performans Reproducibility Sınırlaması)

Runtime measurements may vary because of operating-system scheduling, background services, thermal state, and battery condition. *(Runtime measurement’lar operating-system scheduling, background service, thermal state ve battery condition nedeniyle vary edebilir.)*

---

# 127. Development-Build Limitation (Development Build Sınırlaması)

Debug-build performance may not represent release-build behavior. *(Debug-build performance release-build behavior’ı represent etmeyebilir.)*

---

# 128. Screen-On Limitation (Ekran Açık Kalma Sınırlaması)

The demonstration-oriented UI may keep the display active, increasing battery consumption beyond a background-navigation design. *(Demonstration-oriented UI display’i active tutabilir ve battery consumption’ı background-navigation design’ın ötesine artırabilir.)*

---

# 129. Map Rendering Limitation (Harita Render Sınırlaması)

Map rendering adds UI and network or tile-cache costs that are separate from the estimator itself. *(Map rendering estimator’ın kendisinden ayrı UI ve network veya tile-cache cost ekler.)*

---

# 130. Map Dependency Limitation (Harita Dependency Sınırlaması)

The map is visualization-only and therefore does not correct estimator drift through map matching. *(Map visualization-only’dur ve bu nedenle map matching üzerinden estimator drift’i correct etmez.)*

---

# 131. No Road-Snapping Limitation (Road-Snapping Olmaması Sınırlaması)

NAVGUARD deliberately avoids road snapping in the current estimator to preserve clean evaluation of sensor-based navigation. *(NAVGUARD sensor-based navigation’ın clean evaluation’ını preserve etmek için current estimator’da deliberately road snapping’den kaçınır.)*

---

# 132. No Semantic Map Constraint Limitation (Semantic Map Constraint Olmaması Sınırlaması)

The current estimator does not use building geometry, pedestrian paths, floor plans, or accessibility maps as motion constraints. *(Current estimator building geometry, pedestrian path, floor plan veya accessibility map’lerini motion constraint olarak kullanmaz.)*

---

# 133. No External Infrastructure Limitation (Harici Altyapı Olmaması Sınırlaması)

The initial system does not use Wi-Fi fingerprinting, BLE beacons, UWB anchors, or dedicated indoor infrastructure. *(Initial system Wi-Fi fingerprinting, BLE beacon, UWB anchor veya dedicated indoor infrastructure kullanmaz.)*

---

# 134. No Collaborative Navigation Limitation (Collaborative Navigation Olmaması Sınırlaması)

NAVGUARD does not currently fuse observations from multiple users or multiple devices. *(NAVGUARD currently multiple user veya multiple device’dan observation fuse etmez.)*

---

# 135. Single-User Session Limitation (Tek Kullanıcı Session Sınırlaması)

The current architecture is designed around one active pedestrian session at a time. *(Current architecture aynı anda one active pedestrian session etrafında tasarlanmıştır.)*

---

# 136. No Server-Side Fusion Limitation (Server-Side Fusion Olmaması Sınırlaması)

The core navigation system does not depend on cloud-based sensor fusion. *(Core navigation system cloud-based sensor fusion’a depend etmez.)*

---

# 137. Offline-First Tradeoff (Offline-First Tradeoff’u)

Offline-first operation improves independence but limits access to cloud-scale map, vision, or learned localization services. *(Offline-first operation independence’ı improve eder ancak cloud-scale map, vision veya learned localization service’lerine access’i sınırlar.)*

---

# 138. Privacy-vs-Data Limitation (Privacy-vs-Data Sınırlaması)

Avoiding raw-camera storage protects privacy and reduces storage cost but limits later visual reprocessing experiments. *(Raw-camera storage’dan kaçınmak privacy’yi protect eder ve storage cost’u azaltır ancak later visual reprocessing experiment’lerini sınırlar.)*

---

# 139. Field Route Limitation (Saha Rota Sınırlaması)

The final benchmark will cover a limited set of predefined route geometries. *(Final benchmark limited set of predefined route geometry’leri cover edecektir.)*

---

# 140. Route Diversity Limitation (Rota Çeşitliliği Sınırlaması)

Straight, turn-heavy, and closed routes do not represent every possible pedestrian environment. *(Straight, turn-heavy ve closed route’lar every possible pedestrian environment’ı represent etmez.)*

---

# 141. Route Length Limitation (Rota Uzunluğu Sınırlaması)

The route lengths selected for a 24-day research prototype may be shorter than operational navigation missions. *(24 günlük research prototype için selected route length’leri operational navigation mission’lardan shorter olabilir.)*

---

# 142. Repetition Limitation (Tekrar Sayısı Sınırlaması)

The provisional target of repeated principal routes provides replication but is not equivalent to a large statistical study. *(Repeated principal route’ların provisional target’ı replication sağlar ancak large statistical study ile equivalent değildir.)*

---

# 143. Sample-Size Limitation (Örneklem Boyutu Sınırlaması)

A small number of independent field sessions limits statistical power. *(Small number of independent field session statistical power’ı sınırlar.)*

---

# 144. Statistical Inference Limitation (İstatistiksel Çıkarım Sınırlaması)

Strong population-level statistical claims may not be justified by the initial field sample. *(Strong population-level statistical claim’ler initial field sample tarafından justified olmayabilir.)*

---

# 145. Engineering-Evidence Emphasis (Engineering Evidence Vurgusu)

The project therefore prioritizes matched-session engineering effect sizes and transparent per-session results. *(Bu nedenle proje matched-session engineering effect size’ları ve transparent per-session result’ları prioritize eder.)*

---

# 146. Same-Route Familiarity Limitation (Aynı Rotaya Aşinalık Sınırlaması)

Repeated walking of the same route may change participant behavior through familiarity. *(Same route’un repeated walking’i familiarity üzerinden participant behavior’ı değiştirebilir.)*

---

# 147. Operator Effect Limitation (Operator Etkisi Sınırlaması)

A participant who knows the experiment may unconsciously walk more consistently during later trials. *(Experiment’i bilen participant later trial’larda unconsciously daha consistently yürüyebilir.)*

---

# 148. Blinding Limitation (Blinding Sınırlaması)

The operator can be blinded to protected ground truth during denial but cannot be fully blinded to the fact that a NAVGUARD experiment is occurring. *(Operator denial sırasında protected ground truth’a blinded olabilir ancak NAVGUARD experiment’i gerçekleştiği fact’ine fully blinded olamaz.)*

---

# 149. Route-Safety Limitation (Rota Güvenliği Sınırlaması)

Real pedestrian routes may need to be shortened or altered for safety reasons. *(Real pedestrian route’lar safety reason nedeniyle shortened veya altered edilmek zorunda kalabilir.)*

---

# 150. Weather Limitation (Hava Durumu Sınırlaması)

Weather can influence gait, phone handling, GNSS quality, camera visibility, battery, and thermal behavior. *(Weather gait, phone handling, GNSS quality, camera visibility, battery ve thermal behavior’ı influence edebilir.)*

---

# 151. Urban-Canyon Limitation (Urban-Canyon Sınırlaması)

Dense buildings can simultaneously degrade GNSS reference quality and create challenging magnetic and visual conditions. *(Dense building’ler simultaneously GNSS reference quality’yi degrade edebilir ve challenging magnetic ve visual condition oluşturabilir.)*

---

# 152. Indoor-Outdoor Transition Limitation (İç-Dış Mekân Geçişi Sınırlaması)

Transitions between indoor and outdoor environments may introduce simultaneous changes in GNSS, magnetometer, lighting, and ARCore behavior. *(Indoor ve outdoor environment arasındaki transition’lar GNSS, magnetometer, lighting ve ARCore behavior’da simultaneous change oluşturabilir.)*

---

# 153. Recovery Limitation (Recovery Sınırlaması)

Recovery depends on obtaining a sufficiently usable GNSS reference after the denied interval. *(Recovery denied interval sonrasında sufficiently usable GNSS reference elde etmeye bağlıdır.)*

---

# 154. Recovery Quality Limitation (Recovery Quality Sınırlaması)

A poor returning GNSS fix may delay or prevent reliable relocalization. *(Poor returning GNSS fix reliable relocalization’ı delay edebilir veya prevent edebilir.)*

---

# 155. Recovery Latency Limitation (Recovery Latency Sınırlaması)

Recovery validation intentionally introduces latency because the first returning fix is not automatically accepted. *(Recovery validation first returning fix automatically accepted edilmediği için intentionally latency oluşturur.)*

---

# 156. Recovery Correction Limitation (Recovery Correction Sınırlaması)

A hard correction can create a visible position jump even when it is mathematically appropriate. *(Hard correction mathematically appropriate olsa bile visible position jump oluşturabilir.)*

---

# 157. Recovery-vs-Continuity Tradeoff (Recovery-vs-Continuity Tradeoff’u)

Smoother corrections may improve user experience but require careful estimator-consistent design to avoid corrupting physical meaning. *(Smoother correction’lar user experience’ı improve edebilir ancak physical meaning’i corrupt etmemek için careful estimator-consistent design gerektirir.)*

---

# 158. Re-Anchoring Limitation (Re-Anchoring Sınırlaması)

Multiple anchors improve long-session manageability but add coordinate-history complexity. *(Multiple anchor long-session manageability’yi improve eder ancak coordinate-history complexity ekler.)*

---

# 159. Historical Trajectory Limitation (Historical Trajectory Sınırlaması)

Preserving historical denied trajectories prevents misleading retroactive correction but leaves visible accumulated drift in the record. *(Historical denied trajectory’leri preserve etmek misleading retroactive correction’ı önler ancak record içerisinde visible accumulated drift bırakır.)*

---

# 160. Productization Limitation (Ürünleştirme Sınırlaması)

NAVGUARD is a research prototype rather than a production-ready consumer navigation product. *(NAVGUARD production-ready consumer navigation product yerine research prototype’tır.)*

---

# 161. Certification Limitation (Sertifikasyon Sınırlaması)

The system has not undergone formal navigation, safety, automotive, aviation, medical, or defense certification. *(Sistem formal navigation, safety, automotive, aviation, medical veya defense certification’dan geçmemiştir.)*

---

# 162. Safety-Critical Use Limitation (Safety-Critical Kullanım Sınırlaması)

The prototype should not be used as a sole navigation source for safety-critical decisions. *(Prototype safety-critical decision’lar için sole navigation source olarak kullanılmamalıdır.)*

---

# 163. Military-Grade Claim Limitation (Military-Grade Claim Sınırlaması)

The project does not demonstrate military-grade navigation resilience. *(Proje military-grade navigation resilience demonstrate etmez.)*

---

# 164. Security Hardening Limitation (Security Hardening Sınırlaması)

The current scope does not include full production security hardening, penetration testing, secure boot verification, or hardware-backed integrity attestation. *(Current scope full production security hardening, penetration testing, secure boot verification veya hardware-backed integrity attestation içermez.)*

---

# 165. Tamper Resistance Limitation (Tamper Resistance Sınırlaması)

Session logs and model hashes provide integrity evidence but do not make the entire device tamper-proof. *(Session log’ları ve model hash’leri integrity evidence sağlar ancak entire device’ı tamper-proof yapmaz.)*

---

# 166. Privacy Limitation (Privacy Sınırlaması)

Location traces are sensitive data and require careful storage and export handling. *(Location trace’leri sensitive data’dır ve careful storage ve export handling gerektirir.)*

---

# 167. Participant Metadata Limitation (Participant Metadata Sınırlaması)

The project should minimize personal identifiers and use participant codes whenever possible. *(Proje personal identifier’ları minimize etmeli ve possible olduğunda participant code kullanmalıdır.)*

---

# 168. No Cloud Backup Limitation (Cloud Backup Olmaması Sınırlaması)

Offline-first design means research evidence may depend on deliberate local export and backup procedures. *(Offline-first design research evidence’ın deliberate local export ve backup procedure’lerine depend etmesine neden olabilir.)*

---

# 169. UI Limitation (UI Sınırlaması)

The interface prioritizes research visibility and diagnostic clarity over commercial product polish. *(Interface commercial product polish yerine research visibility ve diagnostic clarity’yi prioritize eder.)*

---

# 170. Accessibility Limitation (Erişilebilirlik Sınırlaması)

The current scope does not guarantee full accessibility compliance for every user group. *(Current scope every user group için full accessibility compliance guarantee etmez.)*

---

# 171. Localization Limitation (Localization Sınırlaması)

The research application may use limited language localization during the prototype stage. *(Research application prototype stage sırasında limited language localization kullanabilir.)*

---

# 172. Background Execution Limitation (Background Execution Sınırlaması)

Android background restrictions can complicate long-running sensor and camera workloads if the application is not actively foregrounded. *(Android background restriction’ları application actively foregrounded değilse long-running sensor ve camera workload’larını complicate edebilir.)*

---

# 173. Screen-Off Limitation (Ekran Kapalı Sınırlaması)

The initial benchmark may focus on controlled foreground operation rather than every possible screen-off lifecycle case. *(Initial benchmark every possible screen-off lifecycle case yerine controlled foreground operation’a focus edebilir.)*

---

# 174. Process-Kill Limitation (Process Kill Sınırlaması)

The app can preserve incomplete evidence after a crash where possible, but a hard operating-system process termination may still lose data not yet flushed. *(App possible olduğunda crash sonrasında incomplete evidence preserve edebilir ancak hard operating-system process termination henüz flush edilmemiş data’nın loss’una neden olabilir.)*

---

# 175. Timestamp Precision Limitation (Timestamp Precision Sınırlaması)

High-resolution timestamps improve ordering but do not guarantee that every sensor measurement represents exactly the same physical instant. *(High-resolution timestamp’ler ordering’i improve eder ancak every sensor measurement’ın exactly same physical instant’ı represent ettiğini guarantee etmez.)*

---

# 176. Sensor Fusion Synchronization Limitation (Sensor Fusion Synchronization Sınırlaması)

Interpolation and nearest-neighbor association between asynchronous streams introduce residual temporal uncertainty. *(Asynchronous stream’ler arasında interpolation ve nearest-neighbor association residual temporal uncertainty oluşturur.)*

---

# 177. Replay-vs-Live Limitation (Replay-vs-Live Sınırlaması)

Replay can reproduce algorithmic behavior but cannot reproduce every live operating-system scheduling effect unless those effects are explicitly recorded. *(Replay algorithmic behavior’ı reproduce edebilir ancak explicitly recorded edilmedikçe every live operating-system scheduling effect’i reproduce edemez.)*

---

# 178. Benchmark Environment Limitation (Benchmark Environment Sınırlaması)

A benchmark conducted in one city or campus environment cannot represent all pedestrian navigation environments. *(One city veya campus environment’ta conducted benchmark all pedestrian navigation environment’ları represent edemez.)*

---

# 179. Cultural and Infrastructure Variation Limitation (Kültürel ve Altyapısal Variation Sınırlaması)

Sidewalk design, building materials, pedestrian density, magnetic infrastructure, and urban geometry differ substantially across locations. *(Sidewalk design, building material, pedestrian density, magnetic infrastructure ve urban geometry location’lar arasında substantially differ eder.)*

---

# 180. Future Work Philosophy (Gelecek Çalışma Felsefesi)

Future work should address measured limitations rather than add complexity without evidence. *(Future work measured limitation’ları address etmeli, evidence olmadan complexity eklememelidir.)*

---

# 181. Future Work Priority Levels (Gelecek Çalışma Öncelik Seviyeleri)

Future work will be grouped into near-term, medium-term, and advanced research directions. *(Future work near-term, medium-term ve advanced research direction olarak grouped edilecektir.)*

```text id="15v9cy"
NEAR-TERM
(YAKIN DÖNEM)

MEDIUM-TERM
(ORTA DÖNEM)

ADVANCED RESEARCH
(İLERİ ARAŞTIRMA)
```

---

# 182. Near-Term Future Work Goal (Yakın Dönem Future Work Hedefi)

Near-term work should improve robustness without fundamentally changing the current architecture. *(Near-term work current architecture’ı fundamentally değiştirmeden robustness’ı improve etmelidir.)*

---

# 183. Multi-Session Dataset Expansion (Multi-Session Dataset Genişletme)

The Motion Classification dataset should be expanded with more independent sessions. *(Motion Classification dataset daha fazla independent session ile expanded edilmelidir.)*

---

# 184. Multi-Participant Expansion (Multi-Participant Genişletme)

Future datasets should include more participants with different gait patterns. *(Future dataset’ler different gait pattern’lara sahip daha fazla participant içermelidir.)*

---

# 185. Phone Placement Expansion (Telefon Placement Genişletme)

Future work should test hand-held, trouser pocket, jacket pocket, backpack, and other realistic placements. *(Future work hand-held, trouser pocket, jacket pocket, backpack ve other realistic placement’ları test etmelidir.)*

---

# 186. Placement Classification Future Work (Placement Classification Future Work)

A future model may estimate phone placement before selecting navigation parameters. *(Future model navigation parameter’larını select etmeden önce phone placement estimate edebilir.)*

---

# 187. Adaptive Step Detection Future Work (Adaptive Step Detection Future Work)

Step-detection thresholds could adapt to motion context, cadence, placement, or user calibration. *(Step-detection threshold’ları motion context, cadence, placement veya user calibration’a adapt olabilir.)*

---

# 188. Personalized Step-Length Future Work (Personalized Step-Length Future Work)

A lightweight personal calibration procedure could improve step-length estimation for individual users. *(Lightweight personal calibration procedure individual user’lar için step-length estimation’ı improve edebilir.)*

---

# 189. Better Step-Length Labels (Daha İyi Step-Length Label’ları)

Future experiments could use external video, floor markers, motion capture, UWB, or other reference systems to obtain higher-quality per-step labels. *(Future experiment’ler higher-quality per-step label elde etmek için external video, floor marker, motion capture, UWB veya other reference system kullanabilir.)*

---

# 190. Broader Motion Taxonomy (Daha Geniş Motion Taxonomy)

Future classifiers may distinguish stairs, elevator, escalator, vehicle motion, phone handling, and additional pedestrian states. *(Future classifier’lar stair, elevator, escalator, vehicle motion, phone handling ve additional pedestrian state’leri distinguish edebilir.)*

---

# 191. Transition-Aware AI Future Work (Transition-Aware AI Future Work)

A future temporal model could explicitly represent transitions instead of classifying every window independently. *(Future temporal model every window’u independently classify etmek yerine transition’ları explicitly represent edebilir.)*

---

# 192. Temporal Model Future Work (Temporal Model Future Work)

GRU, LSTM, temporal convolutional networks, or compact transformer-style models could be compared against the 1D-CNN if data volume justifies them. *(Data volume justify ederse GRU, LSTM, temporal convolutional network veya compact transformer-style model’lar 1D-CNN’e karşı compare edilebilir.)*

---

# 193. AI Calibration Future Work (AI Calibration Future Work)

Future work could calibrate class confidence through temperature scaling or another validation-based calibration method. *(Future work temperature scaling veya another validation-based calibration method üzerinden class confidence calibrate edebilir.)*

---

# 194. Out-of-Distribution Detection Future Work (Out-of-Distribution Detection Future Work)

A future model could detect sensor patterns outside the training distribution before they influence navigation. *(Future model navigation’ı influence etmeden önce training distribution dışındaki sensor pattern’ları detect edebilir.)*

---

# 195. Uncertainty-Aware AI Future Work (Uncertainty-Aware AI Future Work)

Future AI outputs could include uncertainty estimates that are empirically calibrated for navigation use. *(Future AI output’ları navigation use için empirically calibrated uncertainty estimate’leri içerebilir.)*

---

# 196. Multi-Device Validation Future Work (Multi-Device Validation Future Work)

NAVGUARD should eventually be tested across low-end, mid-range, and high-end Android devices. *(NAVGUARD eventually low-end, mid-range ve high-end Android device’lar arasında test edilmelidir.)*

---

# 197. Sensor Hardware Diversity Future Work (Sensör Hardware Diversity Future Work)

Cross-device experiments should compare different IMU and magnetometer vendors. *(Cross-device experiment’ler different IMU ve magnetometer vendor’larını compare etmelidir.)*

---

# 198. Android Version Diversity Future Work (Android Version Diversity Future Work)

Future validation should include multiple Android versions and manufacturer-specific firmware. *(Future validation multiple Android version ve manufacturer-specific firmware içermelidir.)*

---

# 199. Adaptive Sensor-Rate Future Work (Adaptive Sensor-Rate Future Work)

Sensor sampling rates could adapt to motion and confidence to reduce battery cost. *(Sensor sampling rate’leri battery cost’u azaltmak için motion ve confidence’a adapt olabilir.)*

---

# 200. Energy-Aware Runtime Future Work (Energy-Aware Runtime Future Work)

A future runtime policy could disable expensive subsystems when their expected navigation benefit is low. *(Future runtime policy expected navigation benefit low olduğunda expensive subsystem’leri disable edebilir.)*

---

# 201. ARCore Duty-Cycling Future Work (ARCore Duty-Cycling Future Work)

ARCore could be activated selectively during high-drift-risk periods instead of running continuously. *(ARCore continuously run etmek yerine high-drift-risk period’larda selectively activated olabilir.)*

---

# 202. AI Duty-Cycling Future Work (AI Duty-Cycling Future Work)

Motion classification frequency could adapt dynamically instead of using a constant inference schedule. *(Motion classification frequency constant inference schedule kullanmak yerine dynamically adapt olabilir.)*

---

# 203. Thermal-Aware Policy Future Work (Thermal-Aware Policy Future Work)

A thermal-aware controller could change inference rate, ARCore usage, and UI refresh based on device thermal state. *(Thermal-aware controller device thermal state’e göre inference rate, ARCore usage ve UI refresh’i change edebilir.)*

---

# 204. Better ARCore Alignment Future Work (Daha İyi ARCore Alignment Future Work)

Future work could develop more robust ARCore-to-ENU alignment using multiple motion observations rather than a single initialization assumption. *(Future work single initialization assumption yerine multiple motion observation kullanarak daha robust ARCore-to-ENU alignment geliştirebilir.)*

---

# 205. ARCore Re-Localization Future Work (ARCore Re-Localization Future Work)

Future research could investigate whether visual place recognition can reconnect separated ARCore segments safely. *(Future research visual place recognition’ın separated ARCore segment’leri safely reconnect edip edemeyeceğini investigate edebilir.)*

---

# 206. Visual Loop Closure Future Work (Visual Loop Closure Future Work)

Loop-closure techniques could reduce visual-inertial drift on repeated or closed routes. *(Loop-closure technique’leri repeated veya closed route’larda visual-inertial drift’i reduce edebilir.)*

---

# 207. Learned Visual Reliability Future Work (Learned Visual Reliability Future Work)

A future model could estimate ARCore measurement reliability from tracking diagnostics and scene context. *(Future model tracking diagnostic ve scene context’ten ARCore measurement reliability estimate edebilir.)*

---

# 208. Camera-Free Fallback Research (Camera-Free Fallback Research)

Future work could investigate additional non-camera sensor strategies for environments where camera use is restricted. *(Future work camera use restricted olan environment’larda additional non-camera sensor strategy’lerini investigate edebilir.)*

---

# 209. Improved Heading Fusion Future Work (Geliştirilmiş Heading Fusion Future Work)

Future heading estimation could use adaptive magnetic rejection, gyro-bias estimation, and motion-aware orientation constraints. *(Future heading estimation adaptive magnetic rejection, gyro-bias estimation ve motion-aware orientation constraint kullanabilir.)*

---

# 210. Walking-Direction Estimation Future Work (Yürüme Yönü Tahmini Future Work)

Future work could explicitly estimate body walking direction separately from phone orientation. *(Future work body walking direction’ı phone orientation’dan separately estimate edebilir.)*

---

# 211. Pocket-Heading Future Work (Pocket-Heading Future Work)

Specialized models could infer pedestrian heading even when the phone is not aligned with the torso. *(Specialized model’lar phone torso ile aligned olmadığında bile pedestrian heading infer edebilir.)*

---

# 212. Magnetic Map Future Work (Manyetik Harita Future Work)

A separately controlled experiment could investigate magnetic fingerprint maps for indoor correction. *(Separately controlled experiment indoor correction için magnetic fingerprint map’leri investigate edebilir.)*

---

# 213. Map Matching Future Work (Map Matching Future Work)

Map matching may be evaluated in a future configuration as an explicit additional information source. *(Map matching future configuration’da explicit additional information source olarak evaluate edilebilir.)*

---

# 214. Map Matching Experimental Isolation (Map Matching Experimental Isolation)

Any future map-matching experiment should remain separate from the current sensor-only benchmark so its benefit can be measured honestly. *(Future map-matching experiment current sensor-only benchmark’tan separate kalmalıdır ki benefit’i honestly measured edilebilsin.)*

---

# 215. Building Geometry Future Work (Building Geometry Future Work)

Indoor floor-plan constraints could prevent impossible wall crossings and reduce drift. *(Indoor floor-plan constraint’leri impossible wall crossing’leri prevent edebilir ve drift’i reduce edebilir.)*

---

# 216. Pedestrian Network Future Work (Pedestrian Network Future Work)

Outdoor pedestrian-path networks could provide probabilistic motion constraints. *(Outdoor pedestrian-path network’leri probabilistic motion constraint sağlayabilir.)*

---

# 217. Wi-Fi Future Work (Wi-Fi Future Work)

Wi-Fi fingerprinting could provide intermittent indoor absolute corrections where suitable infrastructure exists. *(Wi-Fi fingerprinting suitable infrastructure mevcut olduğunda intermittent indoor absolute correction sağlayabilir.)*

---

# 218. BLE Future Work (BLE Future Work)

BLE beacons could provide additional reference measurements in controlled indoor spaces. *(BLE beacon’lar controlled indoor space’lerde additional reference measurement sağlayabilir.)*

---

# 219. UWB Future Work (UWB Future Work)

UWB could provide higher-quality indoor range or position reference in future hardware-assisted experiments. *(UWB future hardware-assisted experiment’lerde higher-quality indoor range veya position reference sağlayabilir.)*

---

# 220. RTK-GNSS Future Evaluation (RTK-GNSS Future Evaluation)

Future research evaluation could use an RTK-capable reference system to improve outdoor ground-truth quality. *(Future research evaluation outdoor ground-truth quality’yi improve etmek için RTK-capable reference system kullanabilir.)*

---

# 221. External IMU Future Work (External IMU Future Work)

A future benchmark could compare smartphone-only navigation with higher-grade external inertial sensors. *(Future benchmark smartphone-only navigation’ı higher-grade external inertial sensor’larla compare edebilir.)*

---

# 222. Multi-Sensor Global Correction Future Work (Multi-Sensor Global Correction Future Work)

Future NAVGUARD versions could fuse intermittent GNSS, Wi-Fi, BLE, UWB, map constraints, and vision in a unified estimator. *(Future NAVGUARD version’ları intermittent GNSS, Wi-Fi, BLE, UWB, map constraint ve vision’ı unified estimator içerisinde fuse edebilir.)*

---

# 223. Factor Graph Future Work (Factor Graph Future Work)

A factor-graph or smoothing-based estimator could be compared with the EKF in offline and eventually real-time experiments. *(Factor-graph veya smoothing-based estimator offline ve eventually real-time experiment’lerde EKF ile compare edilebilir.)*

---

# 224. Why Factor Graph May Help (Factor Graph Neden Yardımcı Olabilir)

Factor graphs can represent asynchronous measurements, nonlinear constraints, and historical relationships more flexibly than a compact EKF. *(Factor graph’lar asynchronous measurement, nonlinear constraint ve historical relationship’leri compact EKF’den daha flexibly represent edebilir.)*

---

# 225. Factor Graph Tradeoff (Factor Graph Tradeoff’u)

The added computational complexity may be difficult to justify on a smartphone without measured benefit. *(Added computational complexity measured benefit olmadan smartphone üzerinde justify edilmesi zor olabilir.)*

---

# 226. Error-State EKF Future Work (Error-State EKF Future Work)

A future version could evaluate an error-state inertial formulation if higher-rate continuous inertial propagation becomes necessary. *(Higher-rate continuous inertial propagation necessary hale gelirse future version error-state inertial formulation evaluate edebilir.)*

---

# 227. Velocity-State Future Work (Velocity-State Future Work)

The optional `[E,N,vE,vN,ψ]` state could be compared against the frozen `[E,N,ψ]` baseline only through matched experiments. *(Optional `[E,N,vE,vN,ψ]` state yalnızca matched experiment’ler üzerinden frozen `[E,N,ψ]` baseline’a karşı compare edilebilir.)*

---

# 228. Bias-State Future Work (Bias-State Future Work)

Future filters could explicitly estimate gyro or accelerometer bias when sufficient observability exists. *(Sufficient observability mevcut olduğunda future filter’lar gyro veya accelerometer bias’ı explicitly estimate edebilir.)*

---

# 229. Adaptive Covariance Future Work (Adaptive Covariance Future Work)

Quality Engine outputs could drive empirically calibrated adaptive `Q` and `R` policies. *(Quality Engine output’ları empirically calibrated adaptive `Q` ve `R` policy’lerini drive edebilir.)*

---

# 230. Learned Noise Model Future Work (Learned Noise Model Future Work)

A future model could predict measurement noise from environmental and sensor diagnostics. *(Future model environmental ve sensor diagnostic’lerden measurement noise predict edebilir.)*

---

# 231. Better Uncertainty Calibration Future Work (Daha İyi Belirsizlik Kalibrasyonu Future Work)

Larger benchmark datasets could support empirical covariance calibration and coverage analysis. *(Larger benchmark dataset’ler empirical covariance calibration ve coverage analysis’i support edebilir.)*

---

# 232. Coverage Calibration Future Work (Coverage Calibration Future Work)

Future experiments could compare predicted uncertainty ellipses with empirical containment frequencies. *(Future experiment’ler predicted uncertainty ellipse’leri empirical containment frequency’lerle compare edebilir.)*

---

# 233. Multiple Ground-Truth Sources Future Work (Çoklu Ground-Truth Kaynağı Future Work)

A future study could combine RTK GNSS, surveyed checkpoints, and indoor reference infrastructure to reduce dependence on one imperfect reference. *(Future study one imperfect reference’a dependency’yi reduce etmek için RTK GNSS, surveyed checkpoint ve indoor reference infrastructure combine edebilir.)*

---

# 234. Indoor Benchmark Future Work (Indoor Benchmark Future Work)

A dedicated indoor benchmark should use independently known geometry or high-quality reference infrastructure. *(Dedicated indoor benchmark independently known geometry veya high-quality reference infrastructure kullanmalıdır.)*

---

# 235. Underground Navigation Future Work (Yeraltı Navigasyonu Future Work)

Subways, tunnels, parking structures, and underground facilities could become separate future evaluation environments. *(Subway, tunnel, parking structure ve underground facility ayrı future evaluation environment olabilir.)*

---

# 236. Multi-Floor Navigation Future Work (Çok Katlı Navigasyon Future Work)

Future versions could add floor-transition detection and vertical-state estimation. *(Future version’lar floor-transition detection ve vertical-state estimation ekleyebilir.)*

---

# 237. Elevator Detection Future Work (Asansör Detection Future Work)

Accelerometer, barometer, and motion context could be fused for elevator-event detection if hardware supports it. *(Hardware desteklerse accelerometer, barometer ve motion context elevator-event detection için fuse edilebilir.)*

---

# 238. Stair Detection Future Work (Merdiven Detection Future Work)

A dedicated stair classifier could prevent ordinary horizontal PDR assumptions from being applied to stair motion. *(Dedicated stair classifier ordinary horizontal PDR assumption’larının stair motion’a uygulanmasını prevent edebilir.)*

---

# 239. Long-Duration Benchmark Future Work (Uzun Süreli Benchmark Future Work)

Future experiments should extend GNSS-denied duration and travelled distance to characterize drift growth. *(Future experiment’ler drift growth’u characterize etmek için GNSS-denied duration ve travelled distance’ı extend etmelidir.)*

---

# 240. Drift Saturation Research (Drift Saturation Research)

Longer tests could determine whether some configurations exhibit approximately linear, superlinear, or bounded drift under specific environments. *(Longer test’ler specific environment’larda bazı configuration’ların approximately linear, superlinear veya bounded drift exhibit edip etmediğini determine edebilir.)*

---

# 241. Repeated Denial Future Work (Repeated Denial Future Work)

Future sessions could contain multiple GNSS-loss and recovery cycles instead of one denied interval. *(Future session’lar one denied interval yerine multiple GNSS-loss ve recovery cycle içerebilir.)*

---

# 242. Recovery Policy Future Work (Recovery Policy Future Work)

Hard correction, EKF measurement update, and controlled re-anchoring could be compared systematically. *(Hard correction, EKF measurement update ve controlled re-anchoring systematically compare edilebilir.)*

---

# 243. Recovery Smoothness Future Work (Recovery Smoothness Future Work)

A mathematically consistent smoothing policy could improve user experience without altering historical evaluation evidence. *(Mathematically consistent smoothing policy historical evaluation evidence’ı alter etmeden user experience’ı improve edebilir.)*

---

# 244. Automatic Denial Detection Future Work (Automatic Denial Detection Future Work)

The current research flow uses controlled software denial, while future work could detect real GNSS degradation automatically. *(Current research flow controlled software denial kullanırken future work real GNSS degradation’ı automatically detect edebilir.)*

---

# 245. GNSS Quality Monitoring Future Work (GNSS Quality Monitoring Future Work)

Future versions could use satellite status, C/N0 trends, multipath indicators, and raw GNSS diagnostics to estimate GNSS reliability. *(Future version’lar GNSS reliability estimate etmek için satellite status, C/N0 trend, multipath indicator ve raw GNSS diagnostic kullanabilir.)*

---

# 246. Spoofing Detection Future Work (Spoofing Detection Future Work)

GNSS spoofing detection could be investigated as a separate security-oriented research project. *(GNSS spoofing detection separate security-oriented research project olarak investigate edilebilir.)*

---

# 247. Jamming-Resilience Future Work (Jamming-Resilience Future Work)

Any future real RF-denial research would require appropriate legal, safety, laboratory, and regulatory controls. *(Future real RF-denial research appropriate legal, safety, laboratory ve regulatory control gerektirir.)*

---

# 248. Multi-User Collaborative Future Work (Multi-User Collaborative Future Work)

Future systems could exchange relative observations between nearby users to improve localization resilience. *(Future system’ler localization resilience’ı improve etmek için nearby user’lar arasında relative observation exchange edebilir.)*

---

# 249. Device-to-Device Ranging Future Work (Device-to-Device Ranging Future Work)

Bluetooth, UWB, or other ranging technologies could support collaborative positioning. *(Bluetooth, UWB veya other ranging technology collaborative positioning’i support edebilir.)*

---

# 250. Federated Learning Future Work (Federated Learning Future Work)

Future AI personalization could investigate federated learning without centralizing raw motion data. *(Future AI personalization raw motion data’yı centralize etmeden federated learning investigate edebilir.)*

---

# 251. Privacy-Preserving Learning Future Work (Privacy-Preserving Learning Future Work)

Privacy-preserving training techniques could be explored if the project expands to many users. *(Proje many user’a expand olursa privacy-preserving training technique’leri explore edilebilir.)*

---

# 252. Production Security Future Work (Production Security Future Work)

A production version would require stronger encryption, secure key management, integrity verification, secure export, and tamper-resistant audit design. *(Production version stronger encryption, secure key management, integrity verification, secure export ve tamper-resistant audit design gerektirir.)*

---

# 253. Signed Model Artifacts Future Work (Signed Model Artifact Future Work)

Future releases could cryptographically sign approved model artifacts and benchmark configurations. *(Future release’ler approved model artifact ve benchmark configuration’ları cryptographically sign edebilir.)*

---

# 254. Secure Evidence Export Future Work (Secure Evidence Export Future Work)

Research exports could include signed manifests to improve evidence provenance. *(Research export’ları evidence provenance’ı improve etmek için signed manifest içerebilir.)*

---

# 255. Automated Verification Dashboard Future Work (Automated Verification Dashboard Future Work)

A future developer dashboard could display requirement coverage, session integrity, firewall status, replay determinism, and benchmark readiness automatically. *(Future developer dashboard requirement coverage, session integrity, firewall status, replay determinism ve benchmark readiness’i automatically display edebilir.)*

---

# 256. Continuous Regression Future Work (Continuous Regression Future Work)

Sensor replay sessions could become part of continuous integration to detect navigation regressions after code changes. *(Sensor replay session’ları code change sonrasında navigation regression detect etmek için continuous integration’ın parçası olabilir.)*

---

# 257. Benchmark Dataset Release Future Work (Benchmark Dataset Release Future Work)

A sanitized dataset could potentially be prepared for reproducible academic comparison if privacy and licensing conditions permit. *(Privacy ve licensing condition’lar permit ederse sanitized dataset reproducible academic comparison için potentially hazırlanabilir.)*

---

# 258. Open Benchmark Future Work (Open Benchmark Future Work)

Future work could define a standardized smartphone GNSS-denied pedestrian-navigation benchmark protocol. *(Future work standardized smartphone GNSS-denied pedestrian-navigation benchmark protocol define edebilir.)*

---

# 259. Comparative Algorithm Study Future Work (Comparative Algorithm Study Future Work)

NAVGUARD could be compared with alternative PDR, complementary filter, particle filter, factor graph, and neural inertial-navigation approaches. *(NAVGUARD alternative PDR, complementary filter, particle filter, factor graph ve neural inertial-navigation approach’larla compare edilebilir.)*

---

# 260. Neural Inertial Navigation Future Work (Neural Inertial Navigation Future Work)

Future work could evaluate learned inertial odometry models if sufficient data and reference quality become available. *(Sufficient data ve reference quality available hale gelirse future work learned inertial odometry model’ları evaluate edebilir.)*

---

# 261. Neural Inertial Risk (Neural Inertial Risk)

Such models may require far more data and may generalize poorly across devices and placements without careful study. *(Such model’lar çok daha fazla data require edebilir ve careful study olmadan device ve placement’lar arasında poorly generalize edebilir.)*

---

# 262. Hybrid Physical-AI Future Work (Hybrid Physical-AI Future Work)

A future architecture could retain physical PDR equations while learning only residual corrections or noise parameters. *(Future architecture physical PDR equation’larını retain ederken yalnızca residual correction veya noise parameter learn edebilir.)*

---

# 263. Residual Drift Model Future Work (Residual Drift Model Future Work)

A learned residual model could estimate systematic drift patterns after deterministic propagation. *(Learned residual model deterministic propagation sonrasında systematic drift pattern’ları estimate edebilir.)*

---

# 264. Explainable AI Future Work (Explainable AI Future Work)

Future AI modules could expose feature importance, uncertainty, or diagnostic explanation for navigation decisions. *(Future AI module’ları navigation decision’ları için feature importance, uncertainty veya diagnostic explanation expose edebilir.)*

---

# 265. User Confidence Communication Future Work (User Confidence Communication Future Work)

Future UX research could investigate how best to communicate degraded navigation quality without overwhelming users. *(Future UX research degraded navigation quality’yi user’ları overwhelm etmeden en iyi nasıl communicate edeceğini investigate edebilir.)*

---

# 266. Accessible Feedback Future Work (Accessible Feedback Future Work)

Audio, vibration, and simplified confidence cues could support users who cannot continuously watch the map. *(Audio, vibration ve simplified confidence cue’lar map’i continuously izleyemeyen user’ları support edebilir.)*

---

# 267. API Future Work (API Future Work)

A future NAVGUARD engine could expose a reusable native API or Flutter package for research applications. *(Future NAVGUARD engine research application’lar için reusable native API veya Flutter package expose edebilir.)*

---

# 268. Modular Architecture Future Work (Modüler Mimari Future Work)

Estimator sources could be made more modular so new absolute and relative measurements can be added through standard interfaces. *(Estimator source’ları more modular hale getirilebilir ve böylece new absolute ve relative measurement’lar standard interface’ler üzerinden eklenebilir.)*

---

# 269. Research Reproducibility Future Work (Research Reproducibility Future Work)

Future work should preserve code, parameter, model, dataset, session, and analysis versioning as the project grows. *(Future work proje büyüdükçe code, parameter, model, dataset, session ve analysis versioning’i preserve etmelidir.)*

---

# 270. Larger Independent Validation Future Work (Daha Büyük Independent Validation Future Work)

A later study should test the frozen model and estimator on participants and routes not involved in development. *(Later study frozen model ve estimator’ı development’a involved olmayan participant ve route’larda test etmelidir.)*

---

# 271. Cross-Site Validation Future Work (Cross-Site Validation Future Work)

Evaluation across multiple cities, campuses, indoor environments, and building types would improve external validity. *(Multiple city, campus, indoor environment ve building type across evaluation external validity’yi improve eder.)*

---

# 272. Cross-Day Validation Future Work (Cross-Day Validation Future Work)

Larger studies should intentionally include different days and environmental conditions. *(Larger study’ler intentionally different day ve environmental condition içermelidir.)*

---

# 273. Cross-Season Validation Future Work (Cross-Season Validation Future Work)

Seasonal conditions may affect clothing, phone placement, weather, lighting, and walking behavior. *(Seasonal condition’lar clothing, phone placement, weather, lighting ve walking behavior’ı affect edebilir.)*

---

# 274. Benchmark Reference Upgrade Future Work (Benchmark Reference Upgrade Future Work)

The single most valuable experimental improvement may be upgrading reference-position quality beyond ordinary smartphone GNSS. *(En valuable experimental improvement’lardan biri reference-position quality’yi ordinary smartphone GNSS’in ötesine upgrade etmek olabilir.)*

---

# 275. Why Better Reference Matters (Daha İyi Referans Neden Önemlidir)

A stronger reference allows smaller navigation improvements and covariance behavior to be evaluated more confidently. *(Stronger reference smaller navigation improvement ve covariance behavior’ın more confidently evaluate edilmesini sağlar.)*

---

# 276. Future Work Selection Rule (Future Work Seçim Kuralı)

Future development priorities should be selected after reviewing Page 41 results rather than assuming every listed enhancement is necessary. *(Future development priority’leri listed every enhancement’ın necessary olduğu assumed edilmek yerine Page 41 result’ları reviewed edildikten sonra selected edilmelidir.)*

---

# 277. If Heading Is the Dominant Error Source (Heading Dominant Error Source ise)

If final evidence shows heading dominates navigation error, future work should prioritize orientation and body-heading estimation before more complex AI models. *(Final evidence heading’in navigation error’a dominate ettiğini gösterirse future work more complex AI model’lardan önce orientation ve body-heading estimation’ı prioritize etmelidir.)*

---

# 278. If Step Length Is the Dominant Error Source (Step Length Dominant Error Source ise)

If distance bias dominates, future work should prioritize step-length calibration and labeling quality. *(Distance bias dominate ederse future work step-length calibration ve labeling quality’yi prioritize etmelidir.)*

---

# 279. If ARCore Is the Dominant Improvement Source (ARCore Dominant Improvement Source ise)

If ARCore provides the largest measured benefit, future work should focus on tracking robustness, duty cycling, and better segment alignment. *(ARCore largest measured benefit sağlarsa future work tracking robustness, duty cycling ve better segment alignment’a focus etmelidir.)*

---

# 280. If ARCore Provides Little Benefit (ARCore Az Fayda Sağlarsa)

If ARCore provides little or inconsistent benefit, future work should investigate whether the limitation comes from alignment, timing, environment, covariance tuning, or fundamental redundancy. *(ARCore little veya inconsistent benefit sağlarsa future work limitation’ın alignment, timing, environment, covariance tuning veya fundamental redundancy’den gelip gelmediğini investigate etmelidir.)*

---

# 281. If Motion AI Provides Little Navigation Benefit (Motion AI Az Navigasyon Faydası Sağlarsa)

If Motion Classification performs well but does not improve navigation, future work should reconsider how motion context is used by the estimator rather than only increasing classifier complexity. *(Motion Classification well perform eder ancak navigation’ı improve etmezse future work yalnız classifier complexity’yi artırmak yerine motion context’in estimator tarafından nasıl kullanıldığını reconsider etmelidir.)*

---

# 282. If Motion AI Accuracy Is Low (Motion AI Accuracy Düşükse)

If held-out Macro F1 is weak, future work should prioritize dataset quality, labeling, session diversity, and feature design before deeper models. *(Held-out Macro F1 weak ise future work deeper model’lardan önce dataset quality, labeling, session diversity ve feature design’ı prioritize etmelidir.)*

---

# 283. If EKF Adds Little Benefit (EKF Az Fayda Sağlarsa)

If EKF fusion adds little improvement, future work should first audit measurement quality, timing, covariance calibration, and source correlation. *(EKF fusion little improvement eklerse future work önce measurement quality, timing, covariance calibration ve source correlation’ı audit etmelidir.)*

---

# 284. If Covariance Is Overconfident (Covariance Overconfident ise)

If observed error repeatedly exceeds predicted uncertainty, future work should prioritize covariance calibration before presenting formal confidence regions. *(Observed error repeatedly predicted uncertainty’yi exceed ederse future work formal confidence region present etmeden önce covariance calibration’ı prioritize etmelidir.)*

---

# 285. If Battery Cost Is High (Batarya Maliyeti Yüksekse)

If full NAVGUARD consumes excessive battery, future work should prioritize duty cycling and adaptive source activation. *(Full NAVGUARD excessive battery consume ederse future work duty cycling ve adaptive source activation’ı prioritize etmelidir.)*

---

# 286. If Thermal Throttling Is Significant (Termal Throttling Önemliyse)

If thermal throttling materially degrades runtime, future work should optimize ARCore duty cycle, AI inference frequency, rendering, and logging overhead. *(Thermal throttling runtime’ı materially degrade ederse future work ARCore duty cycle, AI inference frequency, rendering ve logging overhead’ı optimize etmelidir.)*

---

# 287. If Reference GNSS Is Too Noisy (Reference GNSS Çok Gürültülüyse)

If smartphone GNSS prevents meaningful comparison, improving the reference system becomes a higher priority than increasing estimator complexity. *(Smartphone GNSS meaningful comparison’ı prevent ederse reference system’ı improve etmek estimator complexity’yi artırmaktan daha high priority olur.)*

---

# 288. Limitation-to-Future-Work Traceability (Limitation-to-Future-Work İzlenebilirliği)

Major limitations should map to one or more future-work directions. *(Major limitation’lar one or more future-work direction’a map edilmelidir.)*

---

# 289. Candidate Traceability Matrix (Aday Traceability Matrisi)

| Limitation (Sınırlama)                                            | Future Work (Gelecek Çalışma)                                         |
| ----------------------------------------------------------------- | --------------------------------------------------------------------- |
| Single-device validation *(Tek cihaz validation)*                 | Multi-device benchmark *(Multi-device benchmark)*                     |
| Limited participants *(Sınırlı participant)*                      | Larger independent dataset *(Daha büyük independent dataset)*         |
| Controlled placement *(Controlled placement)*                     | Multi-placement modeling *(Multi-placement modeling)*                 |
| Smartphone GNSS reference *(Smartphone GNSS reference)*           | RTK / surveyed reference *(RTK / surveyed reference)*                 |
| Magnetic disturbance *(Manyetik bozulma)*                         | Adaptive heading fusion *(Adaptive heading fusion)*                   |
| ARCore tracking loss *(ARCore tracking loss)*                     | Better segment re-localization *(Better segment re-localization)*     |
| Step-length labels *(Step-length label’ları)*                     | Per-step high-quality reference *(Per-step high-quality reference)*   |
| Limited covariance calibration *(Limited covariance calibration)* | Larger uncertainty study *(Larger uncertainty study)*                 |
| Battery / thermal cost *(Battery / thermal cost)*                 | Duty cycling *(Duty cycling)*                                         |
| No map constraints *(Map constraint yok)*                         | Controlled map-matching ablation *(Controlled map-matching ablation)* |

---

# 290. Limitation Severity Classification (Sınırlama Severity Classification)

Not all limitations have the same effect on the final research claim. *(Tüm limitation’lar final research claim üzerinde aynı effect’e sahip değildir.)*

---

# 291. High-Impact Limitations (High-Impact Sınırlamalar)

The most important anticipated limitations are reference-position quality, single-device scope, limited participant diversity, controlled phone placement, short-term evaluation, heading sensitivity, and ARCore environmental dependence. *(En önemli anticipated limitation’lar reference-position quality, single-device scope, limited participant diversity, controlled phone placement, short-term evaluation, heading sensitivity ve ARCore environmental dependence’tır.)*

---

# 292. Medium-Impact Limitations (Medium-Impact Sınırlamalar)

AI calibration, uncertainty calibration, battery precision, and runtime variability are important but generally affect secondary interpretation more than basic prototype validity. *(AI calibration, uncertainty calibration, battery precision ve runtime variability important’tır ancak generally basic prototype validity’den daha fazla secondary interpretation’ı affect eder.)*

---

# 293. Optional-Scope Limitations (Optional-Scope Sınırlamaları)

Lack of cross-device optimization, map matching, UWB, BLE, advanced factor graphs, and online learning does not invalidate the initial project because these are outside the frozen minimum scope. *(Cross-device optimization, map matching, UWB, BLE, advanced factor graph ve online learning eksikliği initial project’i invalid hale getirmez çünkü bunlar frozen minimum scope dışındadır.)*

---

# 294. Limitations That Can Invalidate Results (Sonuçları Invalid Hale Getirebilecek Sınırlamalar)

Some conditions are not merely limitations but can invalidate specific benchmark evidence. *(Bazı condition’lar yalnız limitation değildir ve specific benchmark evidence’ı invalid hale getirebilir.)*

---

# 295. Ground Truth Leakage Invalidation (Ground Truth Leakage Invalidation)

Unauthorized GNSS estimator influence invalidates the affected denied interval. *(Unauthorized GNSS estimator influence affected denied interval’ı invalid hale getirir.)*

---

# 296. Missing Critical Logs Invalidation (Eksik Kritik Log Invalidation)

Missing evidence required to reconstruct a metric can invalidate that metric for the affected session. *(Bir metric’i reconstruct etmek için required missing evidence affected session için o metric’i invalid hale getirebilir.)*

---

# 297. Post-Freeze Tuning Invalidation (Post-Freeze Tuning Invalidation)

Using final benchmark results to tune the estimator invalidates the intended holdout interpretation for affected results. *(Final benchmark result’larını estimator’ı tune etmek için kullanmak affected result’ların intended holdout interpretation’ını invalid hale getirir.)*

---

# 298. Reference Quality Invalidation (Referans Kalitesi Invalidation)

A session with inadequate reference quality may be excluded from primary continuous position-error analysis according to frozen rules. *(Inadequate reference quality’ye sahip session frozen rule’lara göre primary continuous position-error analysis’ten excluded edilebilir.)*

---

# 299. Limitation Documentation Rule (Sınırlama Dokümantasyon Kuralı)

Every material limitation observed during implementation or final benchmark must be added to this page or Page 43 as appropriate. *(Implementation veya final benchmark sırasında observed every material limitation appropriate olduğu şekilde bu page’e veya Page 43’e added edilmelidir.)*

---

# 300. Final Limitation Summary Placeholder (Final Limitation Summary Placeholder)

The final prioritized limitation list will be updated after Page 41 results are available. *(Final prioritized limitation list Page 41 result’ları available olduktan sonra updated edilecektir.)*

```text id="ilmnyw"
FINAL HIGH-IMPACT LIMITATIONS
(FINAL HIGH-IMPACT SINIRLAMALAR)

1. TBD
2. TBD
3. TBD
4. TBD
5. TBD
```

---

# 301. Final Future-Work Priority Placeholder (Final Future-Work Priority Placeholder)

The final future-work priorities will be selected from measured weaknesses rather than preselected assumptions. *(Final future-work priority’leri preselected assumption’lar yerine measured weakness’lardan selected edilecektir.)*

```text id="0rrcjc"
FINAL FUTURE-WORK PRIORITIES
(FINAL FUTURE-WORK ÖNCELİKLERİ)

1. TBD
2. TBD
3. TBD
4. TBD
5. TBD
```

---

# 302. Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kararlar)

NAVGUARD final claims will remain limited to the tested device, participants, phone placement, routes, denied durations, and environmental conditions. *(NAVGUARD final claim’leri tested device, participant’lar, phone placement, route’lar, denied duration’lar ve environmental condition’lar ile limited kalacaktır.)*

---

# 303. Device Claim Decision Frozen by This Document (Bu Dokümanla Sabitlenen Device Claim Kararı)

Single-device evidence will not be generalized to all Android phones. *(Single-device evidence tüm Android phone’lara generalize edilmeyecektir.)*

---

# 304. Participant Claim Decision Frozen by This Document (Bu Dokümanla Sabitlenen Participant Claim Kararı)

Limited-participant evidence will not be used for population-level generalization. *(Limited-participant evidence population-level generalization için kullanılmayacaktır.)*

---

# 305. Placement Claim Decision Frozen by This Document (Bu Dokümanla Sabitlenen Placement Claim Kararı)

Controlled-placement results will not be generalized to arbitrary phone placements without additional experiments. *(Controlled-placement result’ları additional experiment olmadan arbitrary phone placement’lara generalize edilmeyecektir.)*

---

# 306. Ground Truth Claim Decision Frozen by This Document (Bu Dokümanla Sabitlenen Ground Truth Claim Kararı)

Smartphone GNSS will be treated as an imperfect protected evaluation reference rather than perfect ground truth. *(Smartphone GNSS perfect ground truth yerine imperfect protected evaluation reference olarak treated edilecektir.)*

---

# 307. Denial Claim Decision Frozen by This Document (Bu Dokümanla Sabitlenen Denial Claim Kararı)

Software-defined GNSS denial will not be presented as validated real RF jamming resilience. *(Software-defined GNSS denial validated real RF jamming resilience olarak sunulmayacaktır.)*

---

# 308. Duration Claim Decision Frozen by This Document (Bu Dokümanla Sabitlenen Duration Claim Kararı)

NAVGUARD will be presented as a short-term continuity system rather than permanent GNSS replacement. *(NAVGUARD permanent GNSS replacement yerine short-term continuity system olarak sunulacaktır.)*

---

# 309. ARCore Claim Decision Frozen by This Document (Bu Dokümanla Sabitlenen ARCore Claim Kararı)

ARCore will remain a relative visual-inertial source with known environmental and drift limitations. *(ARCore known environmental ve drift limitation’lara sahip relative visual-inertial source olarak kalacaktır.)*

---

# 310. AI Claim Decision Frozen by This Document (Bu Dokümanla Sabitlenen AI Claim Kararı)

Motion Classification performance will not be used as a substitute for navigation-performance evidence. *(Motion Classification performance navigation-performance evidence yerine kullanılmayacaktır.)*

---

# 311. Step-Length Claim Decision Frozen by This Document (Bu Dokümanla Sabitlenen Step-Length Claim Kararı)

Learned step-length results will remain constrained by the granularity and quality of their reference labels. *(Learned step-length result’ları reference label’larının granularity ve quality’si ile constrained kalacaktır.)*

---

# 312. EKF Claim Decision Frozen by This Document (Bu Dokümanla Sabitlenen EKF Claim Kararı)

EKF covariance will not automatically be interpreted as calibrated probability. *(EKF covariance automatically calibrated probability olarak interpreted edilmeyecektir.)*

---

# 313. Map Claim Decision Frozen by This Document (Bu Dokümanla Sabitlenen Map Claim Kararı)

The current map remains visualization-only and does not provide hidden estimator correction. *(Current map visualization-only kalır ve hidden estimator correction sağlamaz.)*

---

# 314. Productization Claim Decision Frozen by This Document (Bu Dokümanla Sabitlenen Productization Claim Kararı)

NAVGUARD will remain described as a research prototype rather than a certified production navigation product. *(NAVGUARD certified production navigation product yerine research prototype olarak described edilmeye devam edecektir.)*

---

# 315. Future Work Prioritization Decision Frozen by This Document (Bu Dokümanla Sabitlenen Future Work Prioritization Kararı)

Final future-work priorities will be selected after Page 41 measured findings are available. *(Final future-work priority’leri Page 41 measured finding’leri available olduktan sonra selected edilecektir.)*

---

# 316. Future Work Evidence Rule Frozen by This Document (Bu Dokümanla Sabitlenen Future Work Evidence Kuralı)

Measured bottlenecks will be prioritized before adding unrelated complexity. *(Measured bottleneck’ler unrelated complexity eklenmeden önce prioritized edilecektir.)*

---

# 317. Final Limitations & Future Work Statement (Nihai Sınırlamalar ve Gelecek Çalışmalar Bildirimi)

**NAVGUARD is intentionally scoped as a smartphone-only, short-term, GNSS-denied pedestrian-navigation research prototype centered on the Xiaomi Redmi Note 9 Pro, and its final conclusions will remain limited to the device, phone placement, participants, routes, environmental conditions, and denied durations actually tested.** *(NAVGUARD intentionally Xiaomi Redmi Note 9 Pro merkezli smartphone-only, short-term, GNSS-denied pedestrian-navigation research prototype olarak scoped edilmiştir ve final conclusion’ları gerçekten tested edilen device, phone placement, participant, route, environmental condition ve denied duration’larla limited kalacaktır.)*

**The project’s most important anticipated experimental limitation is the use of ordinary smartphone GNSS as an independent evaluation reference rather than survey-grade positioning, meaning that observed navigation error contains uncertainty from both NAVGUARD and the reference itself.** *(Projenin en önemli anticipated experimental limitation’larından biri survey-grade positioning yerine ordinary smartphone GNSS’in independent evaluation reference olarak kullanılmasıdır; bu durum observed navigation error’ın hem NAVGUARD hem reference uncertainty’sini içermesi anlamına gelir.)*

**The primary PDR architecture remains vulnerable to accumulated heading and step-length error, and the limited initial dataset, controlled phone placement, and restricted participant diversity prevent broad population or device-generalization claims even if held-out AI and navigation targets are achieved.** *(Primary PDR architecture accumulated heading ve step-length error’a vulnerable kalır ve limited initial dataset, controlled phone placement ve restricted participant diversity held-out AI ve navigation target’ları achieved edilse bile broad population veya device-generalization claim’lerini engeller.)*

**ARCore may reduce local drift when visual tracking is healthy, but its dependence on lighting, scene texture, camera visibility, device support, timestamp alignment, local-frame alignment, and tracking continuity prevents it from being treated as a universal or absolute positioning source.** *(ARCore visual tracking healthy olduğunda local drift’i reduce edebilir ancak lighting, scene texture, camera visibility, device support, timestamp alignment, local-frame alignment ve tracking continuity’ye dependency’si onun universal veya absolute positioning source olarak treated edilmesini engeller.)*

**The initial `[E,N,ψ]` EKF provides a deliberately compact fusion framework, but its covariance remains a model-based uncertainty estimate whose probabilistic interpretation must not be overstated without sufficient calibration data and higher-quality reference measurements.** *(Initial `[E,N,ψ]` EKF deliberately compact fusion framework sağlar ancak covariance’i model-based uncertainty estimate olarak kalır ve sufficient calibration data ile higher-quality reference measurement olmadan probabilistic interpretation’ı overstated edilmemelidir.)*

**Future work should therefore be driven by the measured error sources revealed in Page 41: heading and body-direction estimation should be prioritized if directional drift dominates, improved step-length calibration should be prioritized if distance bias dominates, ARCore robustness should be prioritized if visual tracking provides the largest benefit, and reference-system quality should be upgraded before estimator complexity if smartphone GNSS becomes the evaluation bottleneck.** *(Bu nedenle future work Page 41’de revealed measured error source’lar tarafından driven edilmelidir; directional drift dominate ederse heading ve body-direction estimation, distance bias dominate ederse improved step-length calibration, visual tracking largest benefit sağlarsa ARCore robustness prioritize edilmeli ve smartphone GNSS evaluation bottleneck haline gelirse estimator complexity’den önce reference-system quality upgrade edilmelidir.)*

**Longer-term research may extend NAVGUARD through multi-device and multi-participant validation, multiple phone placements, stronger ground-truth infrastructure, adaptive sensor and energy management, improved ARCore re-localization, map constraints as separately controlled experiments, Wi-Fi/BLE/UWB corrections, advanced uncertainty calibration, factor-graph estimation, collaborative navigation, and privacy-preserving model personalization.** *(Longer-term research NAVGUARD’ı multi-device ve multi-participant validation, multiple phone placement, stronger ground-truth infrastructure, adaptive sensor ve energy management, improved ARCore re-localization, separately controlled experiment olarak map constraint’ler, Wi-Fi/BLE/UWB correction’lar, advanced uncertainty calibration, factor-graph estimation, collaborative navigation ve privacy-preserving model personalization üzerinden extend edebilir.)*

**These future directions are intentionally not treated as requirements for the current 24-business-day prototype, because the value of NAVGUARD depends more on completing a clean, reproducible, evidence-backed research system than on maximizing architectural complexity.** *(Bu future direction’lar intentionally current 24 iş günlük prototype için requirement olarak treated edilmez çünkü NAVGUARD’ın value’su architectural complexity’yi maximize etmekten daha çok clean, reproducible ve evidence-backed research system tamamlamaya bağlıdır.)*

---

# 318. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Final Limitations & Future Work Framework Completed *(Doküman Durumu: Final Öncesi Limitations & Future Work Framework’ü Tamamlandı)*

**Final Measured Limitations Available:** Not Yet *(Final Measured Limitation’lar Available mı: Henüz Değil)*

**Final Priority Limitations:** Pending Page 41 Results *(Final Priority Limitation’lar: Page 41 Sonuçları Bekleniyor)*

**Final Future-Work Priorities:** Pending Page 41 Results *(Final Future-Work Priority’leri: Page 41 Sonuçları Bekleniyor)*

**Primary Device Scope:** Xiaomi Redmi Note 9 Pro *(Primary Device Scope: Xiaomi Redmi Note 9 Pro)*

**Cross-Device Generalization:** Not Claimed *(Cross-Device Generalization: Claim Edilmez)*

**iOS Validation:** Not Included *(iOS Validation: Dahil Değil)*

**Additional Navigation Hardware:** Not Used in Current Prototype *(Additional Navigation Hardware: Current Prototype’ta Kullanılmaz)*

**Consumer-Grade IMU Limitation:** Explicit *(Consumer-Grade IMU Limitation: Explicit)*

**Magnetic Disturbance Limitation:** Explicit *(Magnetic Disturbance Limitation: Explicit)*

**Phone Orientation Limitation:** Explicit *(Phone Orientation Limitation: Explicit)*

**Controlled Phone Placement:** Current Benchmark Scope *(Controlled Phone Placement: Current Benchmark Scope)*

**Arbitrary Placement Generalization:** Not Claimed *(Arbitrary Placement Generalization: Claim Edilmez)*

**Smartphone GNSS Reference:** Imperfect Evaluation Reference *(Smartphone GNSS Reference: Imperfect Evaluation Reference)*

**Survey-Grade Ground Truth:** Not Available in Current Scope *(Survey-Grade Ground Truth: Current Scope’ta Mevcut Değil)*

**Indoor Continuous GNSS Ground Truth:** Not Assumed *(Indoor Continuous GNSS Ground Truth: Assumed Edilmez)*

**GNSS Denial Type:** Software-Defined *(GNSS Denial Türü: Software-Defined)*

**Real RF Jamming Validation:** Not Included *(Real RF Jamming Validation: Dahil Değil)*

**Spoofing Detection:** Not Included *(Spoofing Detection: Dahil Değil)*

**Initial GNSS Anchor Required:** Yes *(Initial GNSS Anchor Gerekli: Evet)*

**Cold-Start Global Localization Without Reference:** Not Supported *(Reference Olmadan Cold-Start Global Localization: Desteklenmez)*

**Short-Term Navigation Scope:** Yes *(Short-Term Navigation Scope: Evet)*

**Permanent GNSS Replacement Claim:** Forbidden *(Permanent GNSS Replacement Claim: Yasak)*

**PDR Main Error Sources:** Heading + Step Detection + Step Length *(PDR Main Error Source’ları: Heading + Step Detection + Step Length)*

**Non-Step Motion Validation:** Limited *(Non-Step Motion Validation: Sınırlı)*

**Stairs / Elevators / Vehicles:** Outside Initial Core Scope Unless Tested *(Stair / Elevator / Vehicle: Tested Değilse Initial Core Scope Dışında)*

**Learned Step-Length Label Quality:** Limited by Reference Granularity *(Learned Step-Length Label Quality: Reference Granularity ile Limited)*

**Motion AI Dataset Scale:** Limited *(Motion AI Dataset Scale: Limited)*

**Participant Diversity:** Limited *(Participant Diversity: Limited)*

**Population-Level AI Generalization:** Not Claimed *(Population-Level AI Generalization: Claim Edilmez)*

**Motion Classes:** Simplified Operational Taxonomy *(Motion Classes: Simplified Operational Taxonomy)*

**TURNING Overlap:** Explicit Limitation *(TURNING Overlap: Explicit Limitation)*

**AI Score as Calibrated Probability:** Not Assumed *(AI Score Calibrated Probability Olarak: Assumed Edilmez)*

**AI Accuracy Equals Navigation Improvement:** No *(AI Accuracy Navigation Improvement’a Eşit mi: Hayır)*

**On-Device Retraining:** Not Included *(On-Device Retraining: Dahil Değil)*

**ARCore Absolute GPS Source:** No *(ARCore Absolute GPS Source mu: Hayır)*

**ARCore Low-Light Sensitivity:** Limitation *(ARCore Low-Light Sensitivity: Limitation)*

**ARCore Low-Texture Sensitivity:** Limitation *(ARCore Low-Texture Sensitivity: Limitation)*

**ARCore Tracking Loss:** Expected Failure Mode *(ARCore Tracking Loss: Expected Failure Mode)*

**ARCore Segment Discontinuity:** Explicit Limitation *(ARCore Segment Discontinuity: Explicit Limitation)*

**ARCore Drift:** Possible *(ARCore Drift: Possible)*

**ARCore-to-ENU Alignment Error:** Explicit Limitation *(ARCore-to-ENU Alignment Error: Explicit Limitation)*

**EKF Frozen Minimum State:** `[E,N,ψ]` *(EKF Frozen Minimum State: `[E,N,ψ]`)*

**Velocity States:** Future Evidence-Gated Option *(Velocity State’leri: Future Evidence-Gated Option)*

**EKF Gaussian Assumption:** Limitation *(EKF Gaussian Assumption: Limitation)*

**PDR / ARCore Correlation:** Recognized *(PDR / ARCore Correlation: Recognized)*

**Covariance Automatically Calibrated:** No *(Covariance Automatically Calibrated mı: Hayır)*

**Formal 95% Confidence Claim Without Calibration:** Forbidden *(Calibration Olmadan Formal 95% Confidence Claim: Yasak)*

**Ground Truth Firewall Scope:** Application-Level Integrity *(Ground Truth Firewall Scope: Application-Level Integrity)*

**Compromised OS Protection Claim:** No *(Compromised OS Protection Claim: Hayır)*

**CSV / JSON Storage Efficiency:** Limited Compared with Binary *(CSV / JSON Storage Efficiency: Binary’ye Göre Limited)*

**Scientific Logging Overhead:** Expected *(Scientific Logging Overhead: Expected)*

**Battery Percentage Precision:** Limited *(Battery Percentage Precision: Limited)*

**Thermal Measurement Precision:** Device/API Dependent *(Thermal Measurement Precision: Device/API Dependent)*

**Map Matching:** Not Used *(Map Matching: Kullanılmaz)*

**Road Snapping:** Not Used *(Road Snapping: Kullanılmaz)*

**Indoor Floor-Plan Constraint:** Not Used *(Indoor Floor-Plan Constraint: Kullanılmaz)*

**Wi-Fi Localization:** Not Used *(Wi-Fi Localization: Kullanılmaz)*

**BLE Localization:** Not Used *(BLE Localization: Kullanılmaz)*

**UWB Localization:** Not Used *(UWB Localization: Kullanılmaz)*

**Collaborative Navigation:** Not Included *(Collaborative Navigation: Dahil Değil)*

**Cloud Sensor Fusion:** Not Required *(Cloud Sensor Fusion: Gerekli Değil)*

**Production Certification:** Not Included *(Production Certification: Dahil Değil)*

**Safety-Critical Sole Navigation Use:** Not Supported *(Safety-Critical Sole Navigation Use: Desteklenmez)*

**Future Work Principle:** Measured Bottlenecks First *(Future Work Principle: Önce Measured Bottleneck’ler)*

**Near-Term Future Work:** Dataset + Placement + Calibration + Robustness *(Near-Term Future Work: Dataset + Placement + Calibration + Robustness)*

**Medium-Term Future Work:** Multi-Device + Better ARCore + Adaptive Runtime + Stronger Reference *(Medium-Term Future Work: Multi-Device + Better ARCore + Adaptive Runtime + Stronger Reference)*

**Advanced Future Work:** Factor Graph + UWB/BLE/Wi-Fi + Collaborative + Neural Inertial + Privacy-Preserving Learning *(Advanced Future Work: Factor Graph + UWB/BLE/Wi-Fi + Collaborative + Neural Inertial + Privacy-Preserving Learning)*

**Final Priority Selection:** After Page 41 Measured Findings *(Final Priority Selection: Page 41 Measured Finding’leri Sonrasında)*

**Next Documentation Item:** 43 — Technical Decisions & Change Log *(Sonraki Dokümantasyon Öğesi: 43 — Teknik Kararlar ve Değişiklik Günlüğü)*
