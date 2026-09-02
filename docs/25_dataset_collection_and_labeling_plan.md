# 25 — Dataset Collection & Labeling Plan (Veri Seti Toplama ve Etiketleme Planı)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the physical data-collection protocol, session structure, route design, activity blocks, phone-placement policy, sensor logging requirements, motion-label construction, step-length reference construction, metadata, quality-control rules, exclusion criteria, dataset splitting, leakage prevention, dataset versioning, manifest structure, evidence preservation, reproducibility requirements, and acceptance criteria for NAVGUARD machine-learning datasets. *(Bu doküman NAVGUARD makine öğrenmesi veri setleri için fiziksel veri toplama protokolünü, oturum yapısını, rota tasarımını, aktivite bloklarını, telefon yerleşimi politikasını, sensör kayıt gereksinimlerini, hareket etiketi oluşturmayı, adım uzunluğu referansı oluşturmayı, metadata bilgisini, kalite kontrol kurallarını, hariç tutma kriterlerini, veri seti ayrımını, veri sızıntısı önlemeyi, veri seti sürümlemeyi, manifest yapısını, kanıt korumayı, tekrarlanabilirlik gereksinimlerini ve kabul kriterlerini tanımlar.)*

The plan covers both Motion Classification and Step Length Estimation datasets while preserving separate labels and experimental objectives for each task. *(Plan Hareket Sınıflandırması ve Adım Uzunluğu Tahmini veri setlerinin her ikisini kapsarken her görev için ayrı etiketleri ve deneysel hedefleri korur.)*

---

# 2. Dataset Objectives (Veri Seti Hedefleri)

The Motion Classification dataset will provide labeled inertial time-series recordings for `STATIONARY`, `WALKING`, `RUNNING`, and `TURNING`. *(Hareket Sınıflandırma veri seti `STATIONARY`, `WALKING`, `RUNNING` ve `TURNING` için etiketli ataletsel zaman serisi kayıtları sağlayacaktır.)*

The Step Length dataset will provide accepted-step events, inertial features, motion context, and defensible distance references for comparing step-length estimators. *(Adım Uzunluğu veri seti adım uzunluğu tahmin motorlarını karşılaştırmak için kabul edilmiş adım olaylarını, ataletsel özellikleri, hareket bağlamını ve savunulabilir mesafe referanslarını sağlayacaktır.)*

---

# 3. Dataset Design Principle (Veri Seti Tasarım İlkesi)

NAVGUARD will prioritize independent physical recording sessions over generating very large numbers of highly correlated windows from only a few recordings. *(NAVGUARD yalnızca birkaç kayıttan çok büyük sayıda yüksek korelasyonlu pencere üretmek yerine bağımsız fiziksel kayıt oturumlarına öncelik verecektir.)*

The number of model windows will never be treated as equivalent to the number of independent experiments. *(Model pencere sayısı hiçbir zaman bağımsız deney sayısına eşdeğer kabul edilmeyecektir.)*

---

# 4. Primary Collection Device (Temel Veri Toplama Cihazı)

The primary collection device will be the Xiaomi Redmi Note 9 Pro. *(Temel veri toplama cihazı Xiaomi Redmi Note 9 Pro olacaktır.)*

Models created from these datasets will therefore initially be considered validated primarily for this device and collection protocol. *(Bu nedenle bu veri setlerinden oluşturulan modeller başlangıçta temel olarak bu cihaz ve veri toplama protokolü için doğrulanmış kabul edilecektir.)*

---

# 5. Participant Scope (Katılımcı Kapsamı)

The initial research dataset may be collected primarily from one controlled test participant. *(İlk araştırma veri seti temel olarak tek kontrollü test katılımcısından toplanabilir.)*

The resulting models must not be described as population-generalized models unless additional participants are later included and evaluated. *(Daha sonra ek katılımcılar dahil edilip değerlendirilmedikçe ortaya çıkan modeller popülasyona genellenmiş modeller olarak açıklanmamalıdır.)*

---

# 6. Participant Identifier (Katılımcı Tanımlayıcısı)

Dataset files will use a non-identifying participant code such as `P001` rather than a personal name. *(Veri seti dosyaları kişisel isim yerine `P001` gibi kişiyi doğrudan tanımlamayan katılımcı kodu kullanacaktır.)*

This supports clean dataset metadata and reduces unnecessary personal information in ML artifacts. *(Bu temiz veri seti metadata bilgisini destekler ve ML artifact'larında gereksiz kişisel bilgiyi azaltır.)*

---

# 7. Controlled Phone Placement (Kontrollü Telefon Yerleşimi)

Formal dataset collection will use one predefined phone-placement protocol. *(Resmî veri seti toplama önceden tanımlanmış tek telefon yerleşimi protokolü kullanacaktır.)*

The placement must remain consistent across calibration, training, validation, and final evaluation sessions unless placement robustness is intentionally being studied. *(Yerleşim, yerleşim dayanıklılığı bilinçli olarak araştırılmadığı sürece kalibrasyon, eğitim, doğrulama ve nihai değerlendirme oturumları arasında tutarlı kalmalıdır.)*

---

# 8. Placement Must Be Documented (Yerleşim Dokümante Edilmelidir)

The final placement definition will specify where the phone is carried and its approximate orientation. *(Nihai yerleşim tanımı telefonun nerede taşındığını ve yaklaşık yönelimini belirtecektir.)*

The selected placement will be recorded in the session metadata. *(Seçilen yerleşim oturum metadata bilgisine kaydedilecektir.)*

---

# 9. Placement Changes Create a New Experimental Condition (Yerleşim Değişiklikleri Yeni Deney Koşulu Oluşturur)

A major phone-placement change will be treated as a different experimental condition rather than silently mixed into the original dataset. *(Büyük telefon yerleşimi değişikliği orijinal veri setine sessizce karıştırılmak yerine farklı bir deney koşulu olarak ele alınacaktır.)*

---

# 10. Dataset Collection Phases (Veri Seti Toplama Aşamaları)

NAVGUARD data collection will proceed through three conceptual phases. *(NAVGUARD veri toplama üç kavramsal aşama üzerinden ilerleyecektir.)*

```text id="d25p01"
PILOT
(Pilot)

DEVELOPMENT
(Geliştirme)

FINAL_HELD_OUT
(Nihai Ayrılmış)
```

---

# 11. PILOT Phase (PILOT Aşaması)

Pilot sessions will validate sensor acquisition, labels, timing, placement, and route protocols before large-scale collection begins. *(Pilot oturumlar büyük ölçekli toplama başlamadan önce sensör toplama, etiket, zamanlama, yerleşim ve rota protokollerini doğrulayacaktır.)*

Pilot recordings may be used for engineering and preliminary modeling but will be marked clearly. *(Pilot kayıtlar mühendislik ve ön modelleme için kullanılabilir ancak açık şekilde işaretlenecektir.)*

---

# 12. DEVELOPMENT Phase (DEVELOPMENT Aşaması)

Development sessions will provide the main training and validation data used for feature engineering, hyperparameter tuning, architecture selection, and threshold calibration. *(Geliştirme oturumları özellik mühendisliği, hiperparametre ayarı, mimari seçimi ve eşik kalibrasyonu için kullanılan temel eğitim ve doğrulama verisini sağlayacaktır.)*

---

# 13. FINAL_HELD_OUT Phase (FINAL_HELD_OUT Aşaması)

Final held-out sessions will remain outside model fitting and tuning. *(Nihai ayrılmış oturumlar model fit ve ayar işlemlerinin dışında kalacaktır.)*

These sessions will provide the principal evidence of generalization after the model configuration has been frozen. *(Bu oturumlar model yapılandırması sabitlendikten sonra genellemenin temel kanıtını sağlayacaktır.)*

---

# 14. Dataset Freeze Principle (Veri Seti Sabitleme İlkesi)

The final test split will be explicitly frozen before final model-selection results are interpreted. *(Nihai test ayrımı nihai model seçim sonuçları yorumlanmadan önce açıkça sabitlenecektir.)*

---

# 15. Session as the Fundamental Unit (Temel Birim Olarak Oturum)

A physical recording session will be the fundamental unit of dataset separation. *(Fiziksel kayıt oturumu veri seti ayrımının temel birimi olacaktır.)*

All windows, accepted steps, and derived features originating from one session will inherit the same dataset split. *(Tek bir oturumdan kaynaklanan tüm pencereler, kabul edilmiş adımlar ve türetilmiş özellikler aynı veri seti ayrımını miras alacaktır.)*

---

# 16. Session Identifier Format (Oturum Tanımlayıcı Formatı)

A structured session identifier will be used. *(Yapılandırılmış bir oturum tanımlayıcısı kullanılacaktır.)*

```text id="d25p02"
NG_<DATE>_<PARTICIPANT>_<TASK>_<SESSION_NUMBER>
```

An example could be `NG_YYYYMMDD_P001_MC_001`. *(Bir örnek `NG_YYYYMMDD_P001_MC_001` olabilir.)*

---

# 17. Task Codes (Görev Kodları)

```text id="d25p03"
MC = Motion Classification
SL = Step Length
MX = Mixed / Multi-Purpose Collection
```

A mixed session may support several analyses but every derived dataset record will preserve its task-specific labels. *(Karma oturum birkaç analizi destekleyebilir ancak türetilmiş her veri seti kaydı görevine özgü etiketlerini koruyacaktır.)*

---

# 18. Raw Session Is Immutable (Ham Oturum Değişmezdir)

Raw sensor recordings will be treated as immutable evidence after collection. *(Ham sensör kayıtları toplama sonrasında değişmez kanıt olarak ele alınacaktır.)*

Preprocessing changes will create new derived dataset versions rather than modifying original raw files. *(Ön işleme değişiklikleri orijinal ham dosyaları değiştirmek yerine yeni türetilmiş veri seti sürümleri oluşturacaktır.)*

---

# 19. Raw-versus-Derived Separation (Ham ile Türetilmiş Veri Ayrımı)

```text id="d25p04"
RAW
↓
PROCESSED
↓
WINDOWS / FEATURES
↓
TRAINING ARTIFACTS
```

Each level will remain traceable to its source. *(Her seviye kaynağına izlenebilir kalacaktır.)*

---

# 20. Required Raw Sensors (Gerekli Ham Sensörler)

Motion-classification and step-length sessions will record accelerometer data. *(Hareket sınıflandırma ve adım uzunluğu oturumları ivmeölçer verisini kaydedecektir.)*

They will record gyroscope data. *(Jiroskop verisini kaydedeceklerdir.)*

They will record timestamps from the common NAVGUARD experiment timeline. *(Ortak NAVGUARD deney zaman çizgisinden zaman damgalarını kaydedeceklerdir.)*

---

# 21. Additional Recorded Sources (Ek Kaydedilen Kaynaklar)

Magnetometer and heading outputs may be recorded for diagnostic and turning-label support. *(Manyetometre ve yön çıktıları tanısal ve dönüş etiketi desteği için kaydedilebilir.)*

GNSS may be recorded independently for route reference and evaluation where appropriate. *(GNSS uygun olduğunda rota referansı ve değerlendirme için bağımsız olarak kaydedilebilir.)*

ARCore data may be recorded if the session is also part of navigation evaluation. *(Oturum aynı zamanda navigasyon değerlendirmesinin parçasıysa ARCore verisi kaydedilebilir.)*

---

# 22. Model Inputs and Recorded Data Are Different Concepts (Model Girdileri ile Kaydedilen Veri Farklı Kavramlardır)

A sensor being recorded does not mean it must become a model feature. *(Bir sensörün kaydediliyor olması model özelliği haline gelmesi gerektiği anlamına gelmez.)*

Dataset collection may intentionally preserve more information than the final deployed model consumes. *(Veri seti toplama bilinçli olarak nihai deployment modelinin kullandığından daha fazla bilgiyi koruyabilir.)*

---

# 23. Raw Sensor Schema (Ham Sensör Şeması)

```text id="d25p05"
session_id
timestamp_ns
sensor_type
x
y
z
accuracy
sequence_number
```

Sensor-specific additional fields may be stored in source-specific logs. *(Sensöre özgü ek alanlar kaynağa özgü loglarda saklanabilir.)*

---

# 24. Session Metadata Schema (Oturum Metadata Şeması)

```text id="d25p06"
session_id
participant_id
device_model
device_configuration_id
collection_phase
collection_date
task_type
route_id
placement_id
activity_protocol_id
sensor_profile_id
label_version
notes
```

---

# 25. Device Snapshot (Cihaz Anlık Görüntüsü)

Each formal collection session should reference the frozen device and sensor configuration active during recording. *(Her resmî veri toplama oturumu kayıt sırasında aktif olan sabitlenmiş cihaz ve sensör yapılandırmasına referans vermelidir.)*

This allows later detection of configuration changes across sessions. *(Bu oturumlar arasındaki yapılandırma değişikliklerinin daha sonra tespit edilmesine izin verir.)*

---

# 26. Sampling Profile (Örnekleme Profili)

The initial research collection profile will target approximately `50 Hz` accelerometer and `50 Hz` gyroscope acquisition. *(İlk araştırma veri toplama profili yaklaşık `50 Hz` ivmeölçer ve `50 Hz` jiroskop toplamayı hedefleyecektir.)*

Actual delivered sampling will be measured from timestamps. *(Gerçek teslim edilen örnekleme zaman damgalarından ölçülecektir.)*

---

# 27. Delivered Rate Must Be Logged (Teslim Edilen Hız Kaydedilmelidir)

Every session-quality report will include actual sensor-rate statistics. *(Her oturum kalite raporu gerçek sensör hızı istatistiklerini içerecektir.)*

The requested rate alone is not sufficient evidence of the recorded temporal resolution. *(Yalnızca talep edilen hız kaydedilen zamansal çözünürlük için yeterli kanıt değildir.)*

---

# 28. Pre-Collection Device Audit Gate (Veri Toplama Öncesi Cihaz Denetimi Kapısı)

Formal AI dataset collection will not begin until the mandatory Device Capability Audit sensor inventory and timing checks have been completed sufficiently for reliable logging. *(Resmî yapay zekâ veri seti toplama zorunlu Cihaz Yetenek Denetimi sensör envanteri ve zamanlama kontrolleri güvenilir kayıt için yeterince tamamlanmadan başlamayacaktır.)*

---

# 29. Collection Session Lifecycle (Veri Toplama Oturumu Yaşam Döngüsü)

```text id="d25p07"
PREPARE
↓
READINESS_CHECK
↓
START_RECORDING
↓
PROTOCOL_EXECUTION
↓
STOP_RECORDING
↓
FLUSH
↓
QUALITY_CHECK
↓
ACCEPT / DEGRADED / EXCLUDE
```

---

# 30. Pre-Session Readiness Check (Oturum Öncesi Hazırlık Kontrolü)

Before a formal session begins, mandatory sensors must be available. *(Resmî oturum başlamadan önce zorunlu sensörler kullanılabilir olmalıdır.)*

Logging must be writable. *(Kayıt sistemi yazılabilir durumda olmalıdır.)*

The correct placement and activity protocol must be selected. *(Doğru yerleşim ve aktivite protokolü seçilmiş olmalıdır.)*

---

# 31. Session Start Boundary (Oturum Başlangıç Sınırı)

The exact formal recording start timestamp will be stored. *(Kesin resmî kayıt başlangıç zaman damgası saklanacaktır.)*

Data before this boundary may be retained diagnostically but will not automatically enter the formal dataset. *(Bu sınırdan önceki veri tanısal olarak korunabilir ancak resmî veri setine otomatik olarak girmeyecektir.)*

---

# 32. Session End Boundary (Oturum Bitiş Sınırı)

The exact formal recording end timestamp will also be stored. *(Kesin resmî kayıt bitiş zaman damgası da saklanacaktır.)*

---

# 33. Activity Timeline (Aktivite Zaman Çizgisi)

Motion-classification sessions will maintain an explicit activity timeline. *(Hareket sınıflandırma oturumları açık bir aktivite zaman çizgisi tutacaktır.)*

```text id="d25p08"
start_ns
end_ns
activity_label
annotation_source
confidence
notes
```

---

# 34. Activity Marker Events (Aktivite İşaretleyici Olayları)

The collection application may provide manual protocol markers such as `START_WALKING` or `START_STATIONARY`. *(Veri toplama uygulaması `START_WALKING` veya `START_STATIONARY` gibi manuel protokol işaretleyicileri sağlayabilir.)*

These markers will use the same monotonic experiment timeline as the sensor stream. *(Bu işaretleyiciler sensör akışıyla aynı monotonik deney zaman çizgisini kullanacaktır.)*

---

# 35. Manual Markers Are Reference Events (Manuel İşaretleyiciler Referans Olaylarıdır)

A button press timestamp is not assumed to perfectly equal the participant's exact biomechanical transition instant. *(Bir buton basma zaman damgasının katılımcının kesin biyomekanik geçiş anına kusursuz şekilde eşit olduğu varsayılmayacaktır.)*

Transition uncertainty will therefore be handled explicitly during annotation. *(Bu nedenle geçiş belirsizliği anotasyon sırasında açık şekilde yönetilecektir.)*

---

# 36. Motion Classification Protocol Blocks (Hareket Sınıflandırma Protokol Blokları)

Motion data will be collected in controlled activity blocks. *(Hareket verisi kontrollü aktivite bloklarında toplanacaktır.)*

Each block will intentionally emphasize one target operational motion class. *(Her blok bilinçli olarak tek hedef operasyonel hareket sınıfını vurgulayacaktır.)*

---

# 37. STATIONARY Block (STATIONARY Bloğu)

A stationary block will require the participant to remain at approximately the same physical position while holding the phone according to the formal placement protocol. *(Sabit blok katılımcının telefonu resmî yerleşim protokolüne göre taşırken yaklaşık aynı fiziksel konumda kalmasını gerektirecektir.)*

Small natural phone movements are allowed. *(Küçük doğal telefon hareketlerine izin verilir.)*

---

# 38. WALKING Block (WALKING Bloğu)

A walking block will contain normal continuous pedestrian walking. *(Yürüyüş bloğu normal sürekli yaya yürüyüşünü içerecektir.)*

Straight or gently varying direction may be used as long as deliberate strong turns are separately annotated. *(Bilinçli güçlü dönüşler ayrı annotate edildiği sürece düz veya hafif değişen yön kullanılabilir.)*

---

# 39. RUNNING Block (RUNNING Bloğu)

A running block will contain controlled safe running because `RUNNING` is part of the frozen trained class set. If safe collection is not possible, the limitation must be recorded and the dataset acceptance status must remain incomplete rather than silently removing the class. *(Koşu bloğu `RUNNING` frozen trained class set'in parçası olduğu için kontrollü güvenli koşuyu içerecektir. Güvenli collection mümkün değilse limitation kaydedilmeli ve sınıf sessizce kaldırılmak yerine dataset acceptance status incomplete kalmalıdır.)*

The protocol will prioritize repeatability and safety rather than maximum speed. *(Protokol maksimum hız yerine tekrarlanabilirliğe ve güvenliğe öncelik verecektir.)*

---

# 40. TURNING Block (TURNING Bloğu)

A turning block will contain deliberate navigation-relevant changes in heading. *(Dönüş bloğu bilinçli navigasyon açısından önemli yön değişimlerini içerecektir.)*

The participant may continue walking while turning. *(Katılımcı dönerken yürümeye devam edebilir.)*

---

# 41. Walk-Stop-Walk Protocol (Yürü-Dur-Yürü Protokolü)

A dedicated walk-stop-walk sequence will be collected. *(Özel yürü-dur-yürü dizisi toplanacaktır.)*

This sequence is particularly important for `WALKING ↔ STATIONARY` transition behavior and false-step suppression. *(Bu dizi özellikle `WALKING ↔ STATIONARY` geçiş davranışı ve yanlış adım bastırma için önemlidir.)*

---

# 42. Walk-Turn-Walk Protocol (Yürü-Dön-Yürü Protokolü)

A dedicated walk-turn-walk sequence will be collected. *(Özel yürü-dön-yürü dizisi toplanacaktır.)*

This provides transition evidence for the `TURNING` class. *(Bu `TURNING` sınıfı için geçiş kanıtı sağlar.)*

---

# 43. Walk-Run-Walk Protocol (Yürü-Koş-Yürü Protokolü)

A walk-run-walk sequence may be collected to evaluate `WALKING`–`RUNNING` transitions within the frozen class set. *(Frozen class set içerisindeki `WALKING`–`RUNNING` geçişlerini değerlendirmek için walk-run-walk sequence toplanabilir.)*

This will test transition behavior rather than only long isolated running blocks. *(Bu yalnızca uzun izole koşu blokları yerine geçiş davranışını test edecektir.)*

---

# 44. Mixed Activity Session (Karma Aktivite Oturumu)

Some sessions will intentionally contain several activity types in one continuous recording. *(Bazı oturumlar tek sürekli kayıt içerisinde bilinçli olarak birkaç aktivite türü içerecektir.)*

Mixed sessions are important for evaluating real-world state transitions. *(Karma oturumlar gerçek dünya durum geçişlerini değerlendirmek için önemlidir.)*

---

# 45. Pure Activity Sessions (Saf Aktivite Oturumları)

Separate pure-class recordings may also be collected for clean class examples. *(Temiz sınıf örnekleri için ayrı saf sınıf kayıtları da toplanabilir.)*

The dataset should contain both clean activity segments and realistic transitions. *(Veri seti hem temiz aktivite segmentlerini hem de gerçekçi geçişleri içermelidir.)*

---

# 46. Activity Block Duration (Aktivite Blok Süresi)

Pilot sessions will determine practical block duration. *(Pilot oturumlar pratik blok süresini belirleyecektir.)*

Initial candidate blocks may be on the order of tens of seconds to a few minutes depending on activity type. *(İlk aday bloklar aktivite türüne bağlı olarak onlarca saniye ile birkaç dakika mertebesinde olabilir.)*

No final duration will be frozen before pilot collection. *(Pilot toplama öncesinde nihai süre sabitlenmeyecektir.)*

---

# 47. Why Blocks Must Be Long Enough (Bloklar Neden Yeterince Uzun Olmalıdır)

Blocks must be long enough to create multiple non-identical model windows and natural gait cycles. *(Bloklar birden fazla aynı olmayan model penceresi ve doğal gait döngüsü oluşturacak kadar uzun olmalıdır.)*

---

# 48. Why Blocks Must Not Be Excessively Long (Bloklar Neden Aşırı Uzun Olmamalıdır)

Very long single recordings can create many correlated windows without adding corresponding independent-session diversity. *(Çok uzun tek kayıtlar karşılık gelen bağımsız oturum çeşitliliğini eklemeden çok sayıda korelasyonlu pencere oluşturabilir.)*

---

# 49. Independent Session Coverage (Bağımsız Oturum Kapsamı)

Every retained motion class must appear across multiple independent recording sessions. *(Korunan her hareket sınıfı birden fazla bağımsız kayıt oturumu genelinde görünmelidir.)*

A single physical session is not sufficient final evidence for one class. *(Tek fiziksel oturum bir sınıf için yeterli nihai kanıt değildir.)*

---

# 50. Provisional Minimum Coverage Gate (Geçici Minimum Kapsama Kapısı)

As an initial planning gate, each of the four frozen trained classes should appear in at least three independent usable sessions before model development is considered minimally viable. *(İlk planning gate olarak dört frozen trained class'ın her biri model development minimally viable kabul edilmeden önce en az üç independent usable session'da görünmelidir.)*

This is a practical project-planning minimum and not a claim of statistical sufficiency. *(Bu pratik proje planlama minimumudur ve istatistiksel yeterlilik iddiası değildir.)*

---

# 51. Preferred Coverage Beyond the Minimum (Minimumun Üzerinde Tercih Edilen Kapsama)

Where the 24-business-day schedule permits, additional independent sessions will be preferred over generating more overlapping windows from existing sessions. *(24 iş günlük takvim izin verdiğinde mevcut oturumlardan daha fazla örtüşen pencere üretmek yerine ek bağımsız oturumlar tercih edilecektir.)*

---

# 52. Collection-Day Diversity (Toplama Günü Çeşitliliği)

Important classes should be represented on more than one day when practical. *(Önemli sınıflar uygulanabilir olduğunda birden fazla günde temsil edilmelidir.)*

This introduces natural variation in gait, handling, device temperature, and environment. *(Bu gait, tutuş, cihaz sıcaklığı ve ortamda doğal çeşitlilik oluşturur.)*

---

# 53. Indoor and Outdoor Diversity (İç ve Dış Mekân Çeşitliliği)

Motion-classification data may include both indoor and outdoor recordings. *(Hareket sınıflandırma verisi hem iç mekân hem de dış mekân kayıtlarını içerebilir.)*

The objective is to reduce accidental dependence on one physical environment. *(Amaç tek fiziksel ortama yanlışlıkla bağımlılığı azaltmaktır.)*

---

# 54. Environment Is Metadata, Not Motion Label (Ortam Metadata Bilgisidir, Hareket Etiketi Değildir)

Indoor and outdoor status will remain metadata unless a dedicated environment study is later introduced. *(İç ve dış mekân durumu daha sonra özel ortam çalışması eklenmediği sürece metadata bilgisi olarak kalacaktır.)*

---

# 55. Route Identity (Rota Kimliği)

Every route-based session will have a route identifier. *(Her rota tabanlı oturum bir rota tanımlayıcısına sahip olacaktır.)*

```text id="d25p09"
route_id
route_type
environment
reference_distance
distance_reference_method
notes
```

---

# 56. Route Types (Rota Türleri)

The collection plan will use several route types where relevant. *(Veri toplama planı ilgili olduğunda birkaç rota türü kullanacaktır.)*

```text id="d25p10"
STRAIGHT
TURN_HEAVY
CLOSED_LOOP
WALK_STOP_WALK
MIXED_ACTIVITY
KNOWN_DISTANCE_CALIBRATION
```

---

# 57. Straight Route (Düz Rota)

Straight routes are particularly important for step-length calibration because they minimize uncertainty from path geometry. *(Düz rotalar rota geometrisinden kaynaklanan belirsizliği azalttıkları için adım uzunluğu kalibrasyonu açısından özellikle önemlidir.)*

---

# 58. Turn-Heavy Route (Dönüş Yoğun Rota)

Turn-heavy routes will provide `TURNING` examples and evaluate how turning affects step dynamics. *(Dönüş yoğun rotalar `TURNING` örnekleri sağlayacak ve dönüşün adım dinamiklerini nasıl etkilediğini değerlendirecektir.)*

---

# 59. Closed-Loop Route (Kapalı Döngü Rota)

Closed or near-closed routes may be used primarily for navigation evaluation rather than direct motion labels. *(Kapalı veya yaklaşık kapalı rotalar doğrudan hareket etiketlerinden çok navigasyon değerlendirmesi için kullanılabilir.)*

Their recordings may still contribute motion windows if split and label rules permit. *(Kayıtları ayrım ve etiket kuralları izin verirse yine de hareket pencerelerine katkıda bulunabilir.)*

---

# 60. Known-Distance Calibration Route (Bilinen Mesafe Kalibrasyon Rotası)

Step-length calibration will prefer a route whose physical horizontal distance is independently known with sufficient confidence. *(Adım uzunluğu kalibrasyonu fiziksel yatay mesafesi yeterli güvenle bağımsız olarak bilinen bir rotayı tercih edecektir.)*

The distance-reference method will be documented. *(Mesafe referans yöntemi dokümante edilecektir.)*

---

# 61. No Unverified Map Distance as Exact Ground Truth (Doğrulanmamış Harita Mesafesini Kesin Ground Truth Olarak Kullanmama)

A visual map estimate will not automatically be treated as exact physical walking distance. *(Görsel harita tahmini otomatik olarak kesin fiziksel yürüyüş mesafesi olarak ele alınmayacaktır.)*

Reference precision must match the method that produced the distance. *(Referans hassasiyeti mesafeyi üreten yöntemle uyumlu olmalıdır.)*

---

# 62. Route Reference Method Field (Rota Referans Yöntemi Alanı)

```text id="d25p11"
DISTANCE_REFERENCE_METHOD =
PRE_MEASURED_ROUTE
KNOWN_BUILDING_SEGMENT
VALIDATED_MAP_GEOMETRY
GNSS_OFFLINE_REFERENCE
OTHER_DOCUMENTED_METHOD
```

The exact methods retained for final experiments will depend on available reliable references. *(Nihai deneyler için korunan kesin yöntemler mevcut güvenilir referanslara bağlı olacaktır.)*

---

# 63. Step Length Session Design (Adım Uzunluğu Oturum Tasarımı)

Step-length sessions will emphasize known-distance straight or simple routes. *(Adım uzunluğu oturumları bilinen mesafeli düz veya basit rotaları vurgulayacaktır.)*

They will also record enough variation in gait to test adaptive estimators. *(Ayrıca adaptif tahmin motorlarını test etmek için yeterli gait çeşitliliğini kaydedeceklerdir.)*

---

# 64. Walking Intensity Segments (Yürüyüş Yoğunluğu Segmentleri)

Where practical, step-length development sessions may contain controlled slow, normal, and faster walking segments. *(Uygulanabilir olduğunda adım uzunluğu geliştirme oturumları kontrollü yavaş, normal ve daha hızlı yürüyüş segmentleri içerebilir.)*

These labels describe collection protocol rather than exact physical speed unless independently measured. *(Bu etiketler bağımsız olarak ölçülmedikçe kesin fiziksel hız yerine veri toplama protokolünü açıklar.)*

---

# 65. Running Step-Length Data (Koşu Adım Uzunluğu Verisi)

`RUNNING` remains part of the frozen Motion Classification class set. Collection of running-specific step-length labels is a separate optional step-length experiment and will occur only if it can be performed safely and produces defensible labels; omitting this optional regression dataset does not remove the `RUNNING` classification class. *(`RUNNING` frozen Motion Classification class set'in parçası olarak kalır. Running-specific step-length label collection ayrı bir optional step-length experiment'tır ve yalnızca güvenli biçimde yapılabilir ve defensible label üretebilirse gerçekleştirilir; bu optional regression dataset'in toplanmaması `RUNNING` classification class'ını kaldırmaz.)*

---

# 66. Step Count Reference (Adım Sayısı Referansı)

Known-distance calibration sessions require an independently verified step count. *(Bilinen mesafeli kalibrasyon oturumları bağımsız doğrulanmış adım sayısı gerektirir.)*

The automatic Step Detection output alone will not automatically be treated as perfect reference. *(Otomatik Adım Tespit çıktısı tek başına otomatik olarak kusursuz referans kabul edilmeyecektir.)*

---

# 67. Manual Step Count Evidence (Manuel Adım Sayısı Kanıtı)

Controlled sessions may use a manually verified step count as reference evidence. *(Kontrollü oturumlar referans kanıt olarak manuel doğrulanmış adım sayısı kullanabilir.)*

The method used to obtain the reference count will be stored in metadata. *(Referans sayımını elde etmek için kullanılan yöntem metadata bilgisine kaydedilecektir.)*

---

# 68. Step Count Reference Schema (Adım Sayısı Referans Şeması)

```text id="d25p12"
session_id
segment_id
reference_step_count
reference_method
automatic_step_count
difference
notes
```

---

# 69. Route-Average Step-Length Reference (Rota Ortalama Adım Uzunluğu Referansı)

If only route-level distance and verified total step count are available, average step length will be calculated at route level. *(Yalnızca rota seviyesi mesafe ve doğrulanmış toplam adım sayısı mevcutsa ortalama adım uzunluğu rota seviyesinde hesaplanacaktır.)*

```text id="d25p13"
L_route_avg =
D_route_ref / N_steps_ref
```

---

# 70. Segment-Average Reference (Segment Ortalama Referansı)

If a route contains independently known segments, each segment may produce a separate average step-length label. *(Bir rota bağımsız olarak bilinen segmentler içeriyorsa her segment ayrı ortalama adım uzunluğu etiketi üretebilir.)*

This is preferred over one route-wide label when valid segment references exist. *(Geçerli segment referansları mevcut olduğunda bu tek rota geneli etikete göre tercih edilir.)*

---

# 71. Per-Step Reference Is Optional (Adım Başına Referans İsteğe Bağlıdır)

Exact per-step ground truth is not required for the project to evaluate route-level step-length performance. *(Kesin adım başına ground truth projenin rota seviyesi adım uzunluğu performansını değerlendirmesi için gerekli değildir.)*

Per-step claims will only be made if per-step references become scientifically defensible. *(Adım başına iddialar yalnızca adım başına referanslar bilimsel olarak savunulabilir hale gelirse yapılacaktır.)*

---

# 72. Motion Label Sources (Hareket Etiketi Kaynakları)

Motion labels may originate from scripted activity blocks. *(Hareket etiketleri script edilmiş aktivite bloklarından kaynaklanabilir.)*

They may originate from manual start and stop markers. *(Manuel başlangıç ve bitiş işaretleyicilerinden kaynaklanabilir.)*

They may be refined through offline annotation using inertial and heading evidence. *(Ataletsel ve yön kanıtı kullanılarak çevrimdışı anotasyonla iyileştirilebilir.)*

---

# 73. Label Source Must Be Preserved (Etiket Kaynağı Korunmalıdır)

Each label segment will preserve how the label was created. *(Her etiket segmenti etiketin nasıl oluşturulduğunu koruyacaktır.)*

```text id="d25p14"
PROTOCOL
MANUAL_MARKER
OFFLINE_REVIEW
DERIVED_RULE
```

---

# 74. Label Confidence (Etiket Güveni)

Each annotated activity interval may include label confidence. *(Her annotate edilmiş aktivite aralığı etiket güveni içerebilir.)*

```text id="d25p15"
HIGH
MEDIUM
LOW
```

Low-confidence intervals may be excluded from the first formal training dataset. *(Düşük güvenli aralıklar ilk resmî eğitim veri setinden çıkarılabilir.)*

---

# 75. Transition Zones (Geçiş Bölgeleri)

Motion transitions will be explicitly represented as uncertain temporal regions when exact boundaries cannot be established. *(Kesin sınırlar belirlenemediğinde hareket geçişleri açık şekilde belirsiz zamansal bölgeler olarak temsil edilecektir.)*

---

# 76. Initial Transition Exclusion Policy (İlk Geçiş Hariç Tutma Politikası)

The first clean training dataset may exclude short windows that overlap ambiguous transition boundaries. *(İlk temiz eğitim veri seti belirsiz geçiş sınırlarıyla örtüşen kısa pencereleri hariç tutabilir.)*

The exact exclusion margin will be selected during pilot annotation. *(Kesin hariç tutma marjı pilot anotasyon sırasında seçilecektir.)*

---

# 77. Transition Windows Will Not Receive Arbitrary Labels (Geçiş Pencereleri Keyfi Etiket Almayacaktır)

A window containing substantial evidence from two motion states will not be assigned a random class merely to preserve dataset size. *(İki hareket durumundan anlamlı kanıt içeren pencereye yalnızca veri seti boyutunu korumak için rastgele sınıf atanmayacaktır.)*

---

# 78. Turning Annotation Support (Dönüş Anotasyon Desteği)

Turning intervals may be refined using gyroscope magnitude and independent heading-change evidence. *(Dönüş aralıkları jiroskop büyüklüğü ve bağımsız yön değişimi kanıtı kullanılarak iyileştirilebilir.)*

The final label rule will distinguish deliberate turns from ordinary small walking corrections. *(Nihai etiket kuralı bilinçli dönüşleri normal küçük yürüyüş düzeltmelerinden ayırt edecektir.)*

---

# 79. Turning Threshold Freeze (Dönüş Eşiği Sabitleme)

The angular and temporal rule defining `TURNING` will be calibrated on pilot and development data and frozen before final held-out evaluation. *(`TURNING` tanımlayan açısal ve zamansal kural pilot ve geliştirme verisinde kalibre edilecek ve nihai ayrılmış değerlendirmeden önce sabitlenecektir.)*

---

# 80. Label Timeline Must Use Sensor Time (Etiket Zaman Çizgisi Sensör Zamanını Kullanmalıdır)

Activity labels and sensor measurements will be aligned to the common monotonic experiment timeline. *(Aktivite etiketleri ve sensör ölçümleri ortak monotonik deney zaman çizgisine hizalanacaktır.)*

Wall-clock time will be supplementary metadata only. *(Duvar saati zamanı yalnızca tamamlayıcı metadata olacaktır.)*

---

# 81. No UI-Time Labeling (UI Zamanıyla Etiketleme Olmaması)

A Flutter UI receipt timestamp will not replace the authoritative native event time when label alignment requires precise timing. *(Etiket hizalama hassas zamanlama gerektirdiğinde Flutter UI alım zaman damgası ana native olay zamanının yerini almayacaktır.)*

---

# 82. Dataset Window Generation (Veri Seti Pencere Üretimi)

Motion Classification windows will be generated only after session split assignment and label alignment. *(Hareket Sınıflandırma pencereleri yalnızca oturum ayrım ataması ve etiket hizalama sonrasında üretilecektir.)*

---

# 83. Split Before Window Generation (Pencere Üretiminden Önce Ayrım)

The safest workflow is to assign the physical session to train, validation, or test before generating overlapping model windows. *(En güvenli iş akışı örtüşen model pencereleri üretmeden önce fiziksel oturumu train, validation veya test grubuna atamaktır.)*

---

# 84. Window Inheritance (Pencere Mirası)

Every derived window will inherit its parent session's split permanently within that dataset version. *(Her türetilmiş pencere o veri seti sürümü içerisinde ana oturumunun ayrımını kalıcı olarak miras alacaktır.)*

---

# 85. No Random Window-Level Split (Rastgele Pencere Seviyesi Ayrım Olmaması)

Randomly splitting all generated windows into train and test is forbidden. *(Üretilen tüm pencereleri train ve test gruplarına rastgele ayırmak yasaktır.)*

---

# 86. Step-Level Split Follows the Same Rule (Adım Seviyesi Ayrım Aynı Kuralı İzler)

Individual accepted steps from one physical step-length recording will not be randomly divided across training and final test sets. *(Tek bir fiziksel adım uzunluğu kaydından bireysel kabul edilmiş adımlar eğitim ve nihai test setleri arasında rastgele bölünmeyecektir.)*

---

# 87. Group Identity (Grup Kimliği)

For ML splitting purposes, the default group identifier will be `session_id`. *(ML ayrımı amacıyla varsayılan grup tanımlayıcısı `session_id` olacaktır.)*

A stricter experiment may group by `route_session_id` or route identity when evaluating route generalization. *(Daha katı deney rota genellemesini değerlendirirken `route_session_id` veya rota kimliğine göre gruplama yapabilir.)*

---

# 88. Route Holdout Candidate (Rota Holdout Adayı)

Where sufficient route diversity exists, one or more route identities may be kept entirely outside model development. *(Yeterli rota çeşitliliği mevcut olduğunda bir veya daha fazla rota kimliği tamamen model geliştirme dışında tutulabilir.)*

This provides a stricter generalization test than session-only separation. *(Bu yalnızca oturum ayrımından daha katı genelleme testi sağlar.)*

---

# 89. Exact Split Percentages Are Not Yet Frozen (Kesin Ayrım Yüzdeleri Henüz Sabit Değildir)

The exact train-validation-test percentages will depend on the number of independent usable sessions collected. *(Kesin train-validation-test yüzdeleri toplanan bağımsız kullanılabilir oturum sayısına bağlı olacaktır.)*

A percentage will not be frozen before the available session count is known. *(Mevcut oturum sayısı bilinmeden bir yüzde sabitlenmeyecektir.)*

---

# 90. Split Balance Objective (Ayrım Dengeleme Hedefi)

Each formal train, validation, and test split must contain representative coverage of all four frozen trained classes: `STATIONARY`, `WALKING`, `RUNNING`, and `TURNING`. If session count or valid `RUNNING` evidence is insufficient, dataset acceptance remains unmet or incomplete rather than silently reducing class membership. *(Her formal train, validation ve test split'i dört frozen trained class'ın tamamı için representative coverage içermelidir: `STATIONARY`, `WALKING`, `RUNNING` ve `TURNING`. Session count veya valid `RUNNING` evidence yetersizse class membership sessizce azaltılmak yerine dataset acceptance karşılanmamış veya incomplete kalır.)*

---

# 91. Test Coverage Requirement (Test Kapsama Gereksinimi)

The final test split must contain examples of every motion class that is reported as part of final model performance. *(Nihai test ayrımı nihai model performansının parçası olarak raporlanan her hareket sınıfından örnekler içermelidir.)*

---

# 92. Multiple Test Sessions Preferred (Birden Fazla Test Oturumu Tercih Edilir)

Where data volume permits, final performance should not rely on only one test recording per class. *(Veri miktarı izin verdiğinde nihai performans sınıf başına yalnızca tek test kaydına dayanmamalıdır.)*

---

# 93. Frozen Split Manifest (Sabitlenmiş Ayrım Manifest'i)

```text id="d25p16"
session_id,split

NG_..._001,train
NG_..._002,train
NG_..._003,validation
NG_..._004,test
```

The split manifest will be version-controlled with the dataset. *(Ayrım manifest'i veri setiyle birlikte sürüm kontrolünde tutulacaktır.)*

---

# 94. Dataset Versioning (Veri Seti Sürümleme)

Every processed dataset release will have a unique dataset identifier. *(İşlenmiş her veri seti sürümü benzersiz veri seti tanımlayıcısına sahip olacaktır.)*

```text id="d25p17"
NAVGUARD_MC_V001

NAVGUARD_SL_V001
```

---

# 95. Dataset Version Changes (Veri Seti Sürüm Değişiklikleri)

A material change in labels, source sessions, preprocessing, split assignment, or exclusion rules will create a new dataset version. *(Etiketlerde, kaynak oturumlarda, ön işlemede, ayrım atamasında veya hariç tutma kurallarında anlamlı değişiklik yeni veri seti sürümü oluşturacaktır.)*

---

# 96. Dataset Manifest (Veri Seti Manifest'i)

```text id="d25p18"
dataset_id
task
version
creation_date
source_session_ids
split_manifest
label_version
preprocessing_version
feature_schema_version
exclusion_rule_version
notes
```

---

# 97. Dataset Provenance (Veri Seti Köken İzlenebilirliği)

Every model-ready sample will remain traceable to its raw physical source session. *(Modele hazır her örnek ham fiziksel kaynak oturumuna izlenebilir kalacaktır.)*

---

# 98. File Hashing (Dosya Hash'leme)

Important raw and derived dataset artifacts may have file hashes stored in manifests. *(Önemli ham ve türetilmiş veri seti artifact'ları manifestlerde saklanan dosya hash'lerine sahip olabilir.)*

This will help detect accidental file changes after dataset freeze. *(Bu veri seti sabitlemesinden sonra yanlışlıkla oluşan dosya değişikliklerini tespit etmeye yardımcı olacaktır.)*

---

# 99. Session Quality Control (Oturum Kalite Kontrolü)

Every session will receive a quality-control result before entering a formal ML dataset. *(Her oturum resmî ML veri setine girmeden önce kalite kontrol sonucu alacaktır.)*

---

# 100. Session Quality States (Oturum Kalite Durumları)

```text id="d25p19"
ACCEPTED
DEGRADED_BUT_USABLE
EXCLUDED
PENDING_REVIEW
```

---

# 101. ACCEPTED Session (ACCEPTED Oturumu)

An `ACCEPTED` session satisfies all mandatory requirements for the intended dataset task. *(Bir `ACCEPTED` oturumu amaçlanan veri seti görevi için tüm zorunlu gereksinimleri karşılar.)*

---

# 102. DEGRADED_BUT_USABLE Session (DEGRADED_BUT_USABLE Oturumu)

A degraded but usable session has a documented limitation that does not invalidate the intended analysis. *(Bozulmuş ancak kullanılabilir oturum amaçlanan analizi geçersiz kılmayan dokümante edilmiş sınırlamaya sahiptir.)*

Its limitation will remain visible in metadata. *(Sınırlaması metadata bilgisinde görünür kalacaktır.)*

---

# 103. EXCLUDED Session (EXCLUDED Oturumu)

An excluded session will not enter the specified formal ML dataset. *(Hariç tutulmuş oturum belirtilen resmî ML veri setine girmeyecektir.)*

The raw evidence will normally remain preserved for audit. *(Ham kanıt normalde denetim için korunmaya devam edecektir.)*

---

# 104. Session Exclusion Must Have a Reason (Oturum Hariç Tutma Nedeni Olmalıdır)

A session will never be excluded merely because a model performs poorly on it. *(Bir oturum yalnızca bir model üzerinde kötü performans gösterdiği için hiçbir zaman hariç tutulmayacaktır.)*

---

# 105. Exclusion Reason Codes (Hariç Tutma Neden Kodları)

```text id="d25p20"
MISSING_ACCELEROMETER
MISSING_GYROSCOPE
TIMESTAMP_FAILURE
MAJOR_SAMPLE_GAPS
LOGGING_FAILURE
INCORRECT_PLACEMENT
PROTOCOL_VIOLATION
LABEL_AMBIGUITY
INVALID_ROUTE_REFERENCE
STEP_COUNT_REFERENCE_FAILURE
CORRUPTED_FILE
DUPLICATE_SESSION
OTHER_DOCUMENTED_REASON
```

---

# 106. Sample Gap Audit (Örnek Boşluğu Denetimi)

Sensor timing statistics will be analyzed for large gaps and irregular acquisition. *(Sensör zamanlama istatistikleri büyük boşluklar ve düzensiz veri toplama açısından analiz edilecektir.)*

---

# 107. Missing Data Rate (Eksik Veri Oranı)

A session-quality report may calculate missing or unusable data proportion for mandatory channels. *(Oturum kalite raporu zorunlu kanallar için eksik veya kullanılamaz veri oranını hesaplayabilir.)*

Final thresholds will depend on measured device behavior. *(Nihai eşikler ölçülmüş cihaz davranışına bağlı olacaktır.)*

---

# 108. Non-Monotonic Timestamp Check (Monotonik Olmayan Zaman Damgası Kontrolü)

Any non-monotonic timestamp event will be detected and counted. *(Her monotonik olmayan zaman damgası olayı tespit edilip sayılacaktır.)*

Severe timestamp corruption may invalidate the session. *(Ciddi zaman damgası bozulması oturumu geçersiz kılabilir.)*

---

# 109. Numerical Validity Check (Sayısal Geçerlilik Kontrolü)

NaN and infinite sensor values will be detected. *(NaN ve sonsuz sensör değerleri tespit edilecektir.)*

Such values will never silently enter model tensors. *(Böyle değerler model tensor'larına hiçbir zaman sessizce girmeyecektir.)*

---

# 110. Duplicate Session Check (Yinelenen Oturum Kontrolü)

Accidental copies of the same physical recording must not be treated as independent sessions. *(Aynı fiziksel kaydın yanlışlıkla oluşturulmuş kopyaları bağımsız oturumlar olarak ele alınmamalıdır.)*

---

# 111. Duplicate Window Check (Yinelenen Pencere Kontrolü)

Exact duplicate model windows across dataset splits are forbidden. *(Veri seti ayrımları arasında tam yinelenen model pencereleri yasaktır.)*

---

# 112. Label Coverage Audit (Etiket Kapsam Denetimi)

The percentage of formal recording time covered by valid labels will be calculated for Motion Classification sessions. *(Resmî kayıt süresinin geçerli etiketlerle kapsanan yüzdesi Hareket Sınıflandırma oturumları için hesaplanacaktır.)*

---

# 113. Unlabeled Intervals (Etiketsiz Aralıklar)

Unlabeled intervals will not automatically inherit the nearest motion class. *(Etiketsiz aralıklar otomatik olarak en yakın hareket sınıfını miras almayacaktır.)*

They may be excluded from supervised window generation. *(Supervised pencere üretiminden çıkarılabilirler.)*

---

# 114. Label Conflict Check (Etiket Çakışma Kontrolü)

Overlapping contradictory labels will be treated as annotation errors requiring review. *(Birbiriyle çelişen örtüşen etiketler inceleme gerektiren anotasyon hataları olarak ele alınacaktır.)*

---

# 115. Route Reference Quality Check (Rota Referans Kalite Kontrolü)

Step-length sessions will verify that the route reference is available and documented before the session enters supervised regression data. *(Adım uzunluğu oturumları supervised regresyon verisine girmeden önce rota referansının mevcut ve dokümante edilmiş olduğunu doğrulayacaktır.)*

---

# 116. Step Count Quality Check (Adım Sayısı Kalite Kontrolü)

If route-average step length depends on manual or independent step count, the reference count must be present and plausible. *(Rota ortalama adım uzunluğu manuel veya bağımsız adım sayısına bağlıysa referans sayım mevcut ve makul olmalıdır.)*

---

# 117. Motion Classification Dataset Record (Hareket Sınıflandırma Veri Seti Kaydı)

```text id="d25p21"
window_id
session_id
window_start_ns
window_end_ns
label
label_confidence
split
preprocessing_version
```

The actual tensor may be stored separately or generated reproducibly. *(Gerçek tensor ayrı saklanabilir veya tekrarlanabilir şekilde üretilebilir.)*

---

# 118. Step Length Dataset Record (Adım Uzunluğu Veri Seti Kaydı)

```text id="d25p22"
step_id
session_id
segment_id
timestamp_ns
reference_type
reference_length_m
feature_schema_version
motion_context
split
```

Fields unsupported by the available label level will remain explicitly unavailable. *(Mevcut etiket seviyesi tarafından desteklenmeyen alanlar açık şekilde kullanılamaz kalacaktır.)*

---

# 119. Derived Data Must Not Invent Missing Reference Values (Türetilmiş Veri Eksik Referans Değerleri Uydurmamalıdır)

If exact per-step distance is unknown, the dataset will not create fabricated exact per-step distances. *(Kesin adım başına mesafe bilinmiyorsa veri seti uydurulmuş kesin adım başına mesafeler oluşturmayacaktır.)*

---

# 120. Label Granularity Field (Etiket Granülerliği Alanı)

```text id="d25p23"
PER_STEP
SEGMENT_AVERAGE
ROUTE_AVERAGE
NONE
```

This field will directly constrain which evaluation metrics may be used. *(Bu alan hangi değerlendirme metriklerinin kullanılabileceğini doğrudan sınırlayacaktır.)*

---

# 121. Collection Protocol Versioning (Veri Toplama Protokolü Sürümleme)

Every formal session will reference a collection-protocol version. *(Her resmî oturum veri toplama protokolü sürümüne referans verecektir.)*

A meaningful protocol change will create a new version rather than silently altering the experiment. *(Anlamlı protokol değişikliği deneyi sessizce değiştirmek yerine yeni sürüm oluşturacaktır.)*

---

# 122. Motion Label Versioning (Hareket Etiketi Sürümleme)

Changes to class definitions or transition rules will increment the label version. *(Sınıf tanımlarındaki veya geçiş kurallarındaki değişiklikler etiket sürümünü artıracaktır.)*

---

# 123. Step Reference Versioning (Adım Referansı Sürümleme)

Changes to distance-reference construction will increment the step-reference protocol version. *(Mesafe referansı oluşturmadaki değişiklikler adım referansı protokol sürümünü artıracaktır.)*

---

# 124. Annotation Audit Trail (Anotasyon Denetim İzi)

Manual changes to formal labels should preserve the original label and the reason for revision. *(Resmî etiketlerdeki manuel değişiklikler orijinal etiketi ve değişiklik nedenini korumalıdır.)*

---

# 125. Annotation Revision Schema (Anotasyon Revizyon Şeması)

```text id="d25p24"
annotation_id
previous_label
new_label
timestamp_range
revision_reason
annotation_version
```

---

# 126. No Model-Driven Relabeling Without Review (İnceleme Olmadan Model Güdümlü Yeniden Etiketleme Olmaması)

A model disagreement will not automatically change a ground-truth label. *(Bir model uyuşmazlığı ground truth etiketi otomatik olarak değiştirmeyecektir.)*

Model errors may identify intervals for human review, but the model cannot become the authority for its own labels. *(Model hataları insan incelemesi için aralıkları belirleyebilir ancak model kendi etiketlerinin otoritesi haline gelemez.)*

---

# 127. Dataset Leakage Audit (Veri Seti Sızıntı Denetimi)

An automated audit will verify that no session exists in more than one train-validation-test split. *(Otomatik denetim hiçbir oturumun birden fazla train-validation-test ayrımında bulunmadığını doğrulayacaktır.)*

---

# 128. Parent-Child Integrity Audit (Ana-Alt Kayıt Bütünlük Denetimi)

Every model-ready window and accepted-step sample must resolve to exactly one known parent session. *(Modele hazır her pencere ve kabul edilmiş adım örneği tam olarak bir bilinen ana oturuma çözümlenmelidir.)*

---

# 129. Training Statistics Leakage Audit (Eğitim İstatistikleri Sızıntı Denetimi)

Normalization or scaling parameters must be calculated from training data only. *(Normalizasyon veya ölçekleme parametreleri yalnızca eğitim verisinden hesaplanmalıdır.)*

The audit will verify the source sessions used to calculate those statistics. *(Denetim bu istatistikleri hesaplamak için kullanılan kaynak oturumları doğrulayacaktır.)*

---

# 130. Test Isolation Audit (Test İzolasyon Denetimi)

The test split must not participate in model architecture selection, threshold tuning, normalization fitting, feature selection, or hyperparameter optimization. *(Test ayrımı model mimarisi seçimine, eşik ayarına, normalizasyon fit işlemine, özellik seçimine veya hiperparametre optimizasyonuna katılmamalıdır.)*

---

# 131. Pilot Data and Final Test Data Must Be Distinguishable (Pilot Veri ile Nihai Test Verisi Ayırt Edilebilir Olmalıdır)

Dataset manifests will identify whether a session belongs to pilot, development, or final held-out collection. *(Veri seti manifestleri bir oturumun pilot, geliştirme veya nihai ayrılmış toplamaya ait olup olmadığını tanımlayacaktır.)*

---

# 132. Data Quantity Reporting (Veri Miktarı Raporlama)

NAVGUARD will report both total recording duration and number of independent sessions. *(NAVGUARD hem toplam kayıt süresini hem de bağımsız oturum sayısını raporlayacaktır.)*

---

# 133. Class Quantity Reporting (Sınıf Miktarı Raporlama)

For Motion Classification, the project will report labeled duration, window count, and independent-session count per class. *(Hareket Sınıflandırma için proje sınıf başına etiketli süreyi, pencere sayısını ve bağımsız oturum sayısını raporlayacaktır.)*

---

# 134. Step Length Quantity Reporting (Adım Uzunluğu Veri Miktarı Raporlama)

For Step Length Estimation, the project will report route count, session count, accepted-step count, reference type, and reference-distance coverage. *(Adım Uzunluğu Tahmini için proje rota sayısını, oturum sayısını, kabul edilmiş adım sayısını, referans türünü ve referans mesafe kapsamını raporlayacaktır.)*

---

# 135. Class Balance Review (Sınıf Dengesi İncelemesi)

Motion-class counts will be reviewed before training. *(Hareket sınıf sayıları eğitimden önce incelenecektir.)*

Additional collection should be preferred over aggressive synthetic balancing when one class has insufficient independent-session coverage. *(Bir sınıf yetersiz bağımsız oturum kapsamına sahipse agresif sentetik dengeleme yerine ek veri toplama tercih edilmelidir.)*

---

# 136. Independent Coverage Before Window Balance (Pencere Dengesinden Önce Bağımsız Kapsam)

A class with thousands of windows but only one physical session will still be considered weakly covered. *(Binlerce pencereye ancak yalnızca bir fiziksel oturuma sahip sınıf yine de zayıf kapsanmış kabul edilecektir.)*

---

# 137. Pilot Coverage Review (Pilot Kapsam İncelemesi)

After pilot collection, class separability and label quality will be reviewed before the final collection schedule is expanded. *(Pilot toplama sonrasında nihai toplama takvimi genişletilmeden önce sınıf ayrılabilirliği ve etiket kalitesi incelenecektir.)*

---

# 138. RUNNING Data Limitation Handling (RUNNING Veri Sınırlaması Yönetimi)

`RUNNING` remains part of the exact frozen trained class set. If running data cannot be collected safely, consistently, or with sufficient quality, the limitation must be documented, the affected dataset/model acceptance criteria must remain unmet, and running-specific navigation behavior may remain disabled. *(`RUNNING` exact frozen trained class set'in parçası olarak kalır. Running verisi güvenli, tutarlı veya yeterli kalitede toplanamazsa limitation dokümante edilmeli, etkilenen dataset/model acceptance criteria karşılanmamış kalmalı ve running-specific navigation behavior devre dışı kalabilmelidir.)*

Pilot evidence alone does not authorize class removal. Removing or redefining `RUNNING` requires an explicit Technical Decision and versioned Change Record that supersedes TD-058 before dataset freeze. *(Pilot evidence tek başına class removal yetkisi vermez. `RUNNING` sınıfının kaldırılması veya yeniden tanımlanması dataset freeze öncesinde TD-058'i supersede eden explicit Technical Decision ve versioned Change Record gerektirir.)*

---

# 139. TURNING Retention Decision (TURNING Koruma Kararı)

If `TURNING` labels cannot be made sufficiently consistent, the project may revise the operational definition before final training. *(Eğer `TURNING` etiketleri yeterince tutarlı hale getirilemezse proje nihai eğitimden önce operasyonel tanımı revize edebilir.)*

The final test set will not be used to redefine the class after results are seen. *(Sonuçlar görüldükten sonra sınıfı yeniden tanımlamak için nihai test seti kullanılmayacaktır.)*

---

# 140. Camera Data Policy (Kamera Veri Politikası)

Motion Classification and Step Length datasets do not require raw camera image recording. *(Hareket Sınıflandırma ve Adım Uzunluğu veri setleri ham kamera görüntüsü kaydı gerektirmez.)*

Camera frames will not be stored by default for these datasets. *(Kamera kareleri bu veri setleri için varsayılan olarak saklanmayacaktır.)*

---

# 141. ARCore Data Is Separate (ARCore Verisi Ayrıdır)

If ARCore is active during a multi-purpose navigation session, pose information may be stored separately from AI training tensors. *(ARCore çok amaçlı navigasyon oturumu sırasında aktifse poz bilgisi yapay zekâ eğitim tensor'larından ayrı saklanabilir.)*

---

# 142. GNSS Data Privacy Awareness (GNSS Veri Gizliliği Farkındalığı)

GNSS session files may reveal route locations and will therefore be treated as sensitive experiment data. *(GNSS oturum dosyaları rota konumlarını ortaya çıkarabilir ve bu nedenle hassas deney verisi olarak ele alınacaktır.)*

Detailed privacy and security requirements will be finalized in **32 — Permissions, Privacy & Security**. *(Ayrıntılı gizlilik ve güvenlik gereksinimleri **32 — Permissions, Privacy & Security** içerisinde kesinleştirilecektir.)*

---

# 143. Data Export (Veri Dışa Aktarma)

Formal sessions will support reproducible export of raw data, labels, metadata, and session manifests. *(Resmî oturumlar ham veri, etiket, metadata ve oturum manifestlerinin tekrarlanabilir dışa aktarımını destekleyecektir.)*

---

# 144. Session Manifest (Oturum Manifest'i)

```text id="d25p25"
session_id
collection_protocol_version
participant_id
device_configuration_id
placement_id
route_id
start_timestamp_ns
end_timestamp_ns
sensor_files
label_files
reference_files
quality_status
quality_report
```

---

# 145. Post-Collection Verification (Toplama Sonrası Doğrulama)

Immediately after a formal session, the system should verify that required files were created and are readable. *(Resmî oturumdan hemen sonra sistem gerekli dosyaların oluşturulduğunu ve okunabilir olduğunu doğrulamalıdır.)*

---

# 146. Post-Collection Summary (Toplama Sonrası Özet)

The application or analysis tool may generate a concise session summary. *(Uygulama veya analiz aracı kısa oturum özeti üretebilir.)*

```text id="d25p26"
duration
accelerometer_samples
gyroscope_samples
delivered_rate_statistics
label_coverage
step_count
logging_errors
session_quality
```

---

# 147. Failed Session Is Recorded as Failed (Başarısız Oturum Başarısız Olarak Kaydedilir)

A failed collection attempt will not be silently deleted from experiment records. *(Başarısız veri toplama denemesi deney kayıtlarından sessizce silinmeyecektir.)*

Its failure reason may help identify recurring system problems. *(Başarısızlık nedeni tekrar eden sistem problemlerini belirlemeye yardımcı olabilir.)*

---

# 148. Repeat Session Policy (Oturum Tekrar Politikası)

A failed or protocol-violating session may be repeated as a new session with a new identifier. *(Başarısız veya protokol ihlalli oturum yeni tanımlayıcıyla yeni oturum olarak tekrarlanabilir.)*

The replacement recording will not overwrite the original evidence. *(Yerine geçen kayıt orijinal kanıtın üzerine yazmayacaktır.)*

---

# 149. Data Collection Checklist (Veri Toplama Kontrol Listesi)

Before each formal session, the operator will verify the intended participant code. *(Her resmî oturumdan önce operatör amaçlanan katılımcı kodunu doğrulayacaktır.)*

The operator will verify the correct route and activity protocol. *(Operatör doğru rota ve aktivite protokolünü doğrulayacaktır.)*

The operator will verify phone placement. *(Operatör telefon yerleşimini doğrulayacaktır.)*

The operator will verify acquisition readiness. *(Operatör veri toplama hazırlığını doğrulayacaktır.)*

---

# 150. During-Session Monitoring (Oturum Sırasında İzleme)

The application may display basic recording health without exposing excessive diagnostic complexity. *(Uygulama aşırı tanısal karmaşıklık göstermeden temel kayıt sağlığını gösterebilir.)*

Critical logging failures must be surfaced immediately. *(Kritik kayıt hataları hemen görünür hale getirilmelidir.)*

---

# 151. No Silent Sensor Loss (Sessiz Sensör Kaybı Olmaması)

Loss of a mandatory sensor stream during a formal collection session must be logged and reflected in session quality. *(Resmî veri toplama oturumu sırasında zorunlu sensör akışının kaybı kaydedilmeli ve oturum kalitesine yansıtılmalıdır.)*

---

# 152. Collection Configuration Freeze Per Session (Oturum Başına Veri Toplama Yapılandırmasını Sabitleme)

A formal session will not change sampling profile, placement definition, or label protocol midway without recording a formal configuration transition. *(Resmî oturum kayıtlı resmî yapılandırma geçişi olmadan örnekleme profilini, yerleşim tanımını veya etiket protokolünü oturum ortasında değiştirmeyecektir.)*

---

# 153. Prefer New Session for Major Change (Büyük Değişiklik İçin Yeni Oturum Tercihi)

A major configuration change should normally end the current session and begin a new one. *(Büyük yapılandırma değişikliği normalde mevcut oturumu sonlandırmalı ve yeni oturum başlatmalıdır.)*

---

# 154. Motion Dataset Generation Workflow (Hareket Veri Seti Üretim İş Akışı)

```text id="d25p27"
Raw Sessions
↓
Session QC
↓
Activity Timeline Review
↓
Split Assignment
↓
Synchronization
↓
Window Generation
↓
Training-Only Normalization
↓
Dataset Freeze
```

---

# 155. Step Length Dataset Generation Workflow (Adım Uzunluğu Veri Seti Üretim İş Akışı)

```text id="d25p28"
Raw Sessions
↓
Session QC
↓
Step Detection / Reference Step Count
↓
Distance Reference Alignment
↓
Split Assignment
↓
Feature Generation
↓
Label-Quality Assignment
↓
Dataset Freeze
```

---

# 156. Model Training Starts Only After Dataset Freeze Candidate (Model Eğitimi Yalnızca Veri Seti Sabitleme Adayından Sonra Başlar)

Exploratory pilot modeling may occur earlier. *(Keşif amaçlı pilot modelleme daha erken gerçekleşebilir.)*

Formal model comparison will use a versioned dataset snapshot. *(Resmî model karşılaştırması sürümlenmiş veri seti anlık görüntüsünü kullanacaktır.)*

---

# 157. Data Augmentation Is Not Part of Physical Collection (Data Augmentation Fiziksel Toplamanın Parçası Değildir)

Synthetic augmentation, if later used, will be a separate training transformation and will not be confused with physically recorded sessions. *(Sentetik augmentation daha sonra kullanılırsa ayrı eğitim dönüşümü olacak ve fiziksel olarak kaydedilmiş oturumlarla karıştırılmayacaktır.)*

---

# 158. Augmented Samples Retain Parent Split (Augment Edilmiş Örnekler Ana Ayrımı Korur)

Any augmented sample derived from a training session remains training data. *(Bir eğitim oturumundan türetilen her augment edilmiş örnek eğitim verisi olarak kalır.)*

Augmentation will never create a new independent test sample. *(Augmentation hiçbir zaman yeni bağımsız test örneği oluşturmayacaktır.)*

---

# 159. Data Collection Does Not Optimize Test Performance (Veri Toplama Test Performansını Optimize Etmez)

After the final held-out dataset is frozen, additional collection motivated specifically by observed test errors cannot simply be added to training while retaining the same test result as untouched evidence. *(Nihai ayrılmış veri seti sabitlendikten sonra özellikle gözlemlenen test hataları tarafından motive edilen ek veri toplama aynı test sonucu dokunulmamış kanıt olarak korunurken basitçe eğitime eklenemez.)*

---

# 160. New Data Means New Experimental Cycle (Yeni Veri Yeni Deney Döngüsü Anlamına Gelir)

If major new training data is introduced after final test analysis, the updated model will require a new evaluation cycle or appropriately fresh held-out evidence. *(Nihai test analizinden sonra büyük yeni eğitim verisi eklenirse güncellenmiş model yeni değerlendirme döngüsü veya uygun şekilde yeni ayrılmış kanıt gerektirecektir.)*

---

# 161. Dataset Summary Report (Veri Seti Özet Raporu)

Every frozen dataset version will have a summary report. *(Her sabitlenmiş veri seti sürümü özet raporuna sahip olacaktır.)*

---

# 162. Motion Dataset Summary Fields (Hareket Veri Seti Özet Alanları)

```text id="d25p29"
dataset_id
total_sessions
train_sessions
validation_sessions
test_sessions
total_labeled_duration
class_duration
class_window_counts
class_session_counts
excluded_sessions
label_version
```

---

# 163. Step Length Dataset Summary Fields (Adım Uzunluğu Veri Seti Özet Alanları)

```text id="d25p30"
dataset_id
total_sessions
route_count
train_sessions
validation_sessions
test_sessions
accepted_steps
reference_type_counts
total_reference_distance
excluded_sessions
feature_schema_version
```

---

# 164. Exclusion Report (Hariç Tutma Raporu)

The summary will include counts and reasons for excluded sessions. *(Özet hariç tutulan oturumların sayılarını ve nedenlerini içerecektir.)*

This prevents silent survivorship bias. *(Bu sessiz survivorship bias'ını önler.)*

---

# 165. Dataset Balance Report (Veri Seti Denge Raporu)

The Motion Classification dataset will report both class-window balance and class-session balance. *(Hareket Sınıflandırma veri seti hem sınıf-pencere dengesini hem de sınıf-oturum dengesini raporlayacaktır.)*

---

# 166. Data Collection Completion Gate (Veri Toplama Tamamlama Kapısı)

Formal model training will not be considered ready until each of the four frozen trained classes has adequate independent-session coverage and the leakage audit passes. *(Dört frozen trained class'ın her biri yeterli independent-session coverage'a sahip olana ve leakage audit geçene kadar formal model training hazır kabul edilmeyecektir.)*

---

# 167. Step Length Collection Completion Gate (Adım Uzunluğu Veri Toplama Tamamlama Kapısı)

Supervised step-length regression will not be considered ready until the available reference-distance method is sufficiently documented and repeatable. *(Supervised adım uzunluğu regresyonu mevcut referans mesafe yöntemi yeterince dokümante edilmiş ve tekrarlanabilir olana kadar hazır kabul edilmeyecektir.)*

---

# 168. Label Review Gate (Etiket İnceleme Kapısı)

All formal motion labels must pass basic temporal and semantic consistency checks before window generation. *(Tüm resmî hareket etiketleri pencere üretiminden önce temel zamansal ve semantik tutarlılık kontrollerini geçmelidir.)*

---

# 169. Model Independence from Collection UI (Modelin Veri Toplama UI'ından Bağımsızlığı)

The model will consume exported sensor and label data rather than depend on temporary UI state. *(Model geçici UI durumuna bağlı olmak yerine dışa aktarılmış sensör ve etiket verisini kullanacaktır.)*

---

# 170. Replay Compatibility (Replay Uyumluluğu)

The stored raw sessions must remain sufficient to regenerate model windows and step-length features after preprocessing changes. *(Saklanan ham oturumlar ön işleme değişikliklerinden sonra model pencerelerini ve adım uzunluğu özelliklerini yeniden üretmek için yeterli kalmalıdır.)*

---

# 171. Reproducibility Requirement (Tekrarlanabilirlik Gereksinimi)

Given the same raw session, label version, preprocessing version, and split manifest, dataset generation should produce equivalent model-ready samples. *(Aynı ham oturum, etiket sürümü, ön işleme sürümü ve ayrım manifest'i verildiğinde veri seti üretimi eşdeğer modele hazır örnekler üretmelidir.)*

---

# 172. Dataset Generation Configuration (Veri Seti Üretim Yapılandırması)

```text id="d25p31"
datasetGeneratorVersion
task
sourceManifest
labelVersion
preprocessingVersion
windowConfiguration
featureConfiguration
splitManifest
exclusionPolicy
```

---

# 173. Automated Dataset Validation (Otomatik Veri Seti Doğrulaması)

The dataset-generation pipeline will include automated validation checks before marking a dataset version as frozen. *(Veri seti üretim hattı bir veri seti sürümünü sabitlenmiş olarak işaretlemeden önce otomatik doğrulama kontrolleri içerecektir.)*

---

# 174. Dataset Validation Test IDs (Veri Seti Doğrulama Test ID'leri)

```text id="d25p32"
DATA-COL-001   Required raw files exist
DATA-COL-002   Mandatory sensor streams exist
DATA-COL-003   Timestamp integrity
DATA-COL-004   Session metadata completeness
DATA-COL-005   Placement protocol recorded

DATA-LBL-001   Label timeline validity
DATA-LBL-002   No contradictory overlap
DATA-LBL-003   Transition policy applied
DATA-LBL-004   Label source traceability
DATA-LBL-005   Turning-label consistency

DATA-SL-001    Route reference exists
DATA-SL-002    Reference-step count exists
DATA-SL-003    Label granularity recorded
DATA-SL-004    No fabricated per-step ground truth

DATA-SPLIT-001 No session crosses splits
DATA-SPLIT-002 Every sample has parent session
DATA-SPLIT-003 Training-only normalization source
DATA-SPLIT-004 Test split isolated

DATA-QA-001    Sample-rate report
DATA-QA-002    Missing-data audit
DATA-QA-003    NaN / Inf audit
DATA-QA-004    Duplicate-session audit
DATA-QA-005    Exclusion report

DATA-REP-001   Dataset manifest complete
DATA-REP-002   Dataset regeneration reproducibility
```

---

# 175. Motion Collection Acceptance Criteria (Hareket Veri Toplama Kabul Kriterleri)

Each of the four frozen trained classes must have valid labeled examples from multiple independent sessions. *(Dört frozen trained class'ın her biri birden fazla independent session'dan valid labeled example'lara sahip olmalıdır.)*

The provisional planning minimum is three usable independent sessions for each of the four frozen trained classes before formal model development is considered minimally viable. *(Geçici planning minimum'u formal model development minimally viable kabul edilmeden önce dört frozen trained class'ın her biri için üç usable independent session'dır.)*

---

# 176. Timing Acceptance Criteria (Zamanlama Kabul Kriterleri)

Accelerometer and gyroscope records must contain valid monotonic timestamps sufficient for synchronization and window construction. *(İvmeölçer ve jiroskop kayıtları senkronizasyon ve pencere oluşturma için yeterli geçerli monotonik zaman damgaları içermelidir.)*

---

# 177. Label Acceptance Criteria (Etiket Kabul Kriterleri)

Every supervised motion window must map to a valid label interval under the frozen annotation policy. *(Her supervised hareket penceresi sabitlenmiş anotasyon politikası altında geçerli etiket aralığına eşlenmelidir.)*

Ambiguous transition windows must follow the documented transition policy. *(Belirsiz geçiş pencereleri dokümante edilmiş geçiş politikasını izlemelidir.)*

---

# 178. Step Length Reference Acceptance Criteria (Adım Uzunluğu Referans Kabul Kriterleri)

Every supervised Step Length session must have a documented distance-reference method. *(Her supervised Adım Uzunluğu oturumu dokümante edilmiş mesafe referans yöntemine sahip olmalıdır.)*

Route-average labels must also have a defensible reference step count. *(Rota ortalama etiketleri ayrıca savunulabilir referans adım sayısına sahip olmalıdır.)*

---

# 179. Split Acceptance Criteria (Ayrım Kabul Kriterleri)

No physical session may contribute samples to more than one of train, validation, and test within the same dataset version. *(Hiçbir fiziksel oturum aynı veri seti sürümü içerisinde train, validation ve test gruplarından birden fazlasına örnek sağlayamaz.)*

---

# 180. Test Isolation Acceptance Criteria (Test İzolasyon Kabul Kriterleri)

Final held-out sessions must not participate in normalization fitting, feature selection, threshold selection, hyperparameter tuning, or architecture selection. *(Nihai ayrılmış oturumlar normalizasyon fit işlemine, özellik seçimine, eşik seçimine, hiperparametre ayarına veya mimari seçimine katılmamalıdır.)*

---

# 181. Quality Acceptance Criteria (Kalite Kabul Kriterleri)

Each session must have an explicit `ACCEPTED`, `DEGRADED_BUT_USABLE`, `EXCLUDED`, or `PENDING_REVIEW` quality state. *(Her oturum açık bir `ACCEPTED`, `DEGRADED_BUT_USABLE`, `EXCLUDED` veya `PENDING_REVIEW` kalite durumuna sahip olmalıdır.)*

Excluded sessions must preserve documented reasons. *(Hariç tutulan oturumlar dokümante edilmiş nedenleri korumalıdır.)*

---

# 182. Reproducibility Acceptance Criteria (Tekrarlanabilirlik Kabul Kriterleri)

Every frozen dataset must include a dataset manifest, split manifest, label version, preprocessing version, and source-session inventory. *(Her sabitlenmiş veri seti veri seti manifest'i, ayrım manifest'i, etiket sürümü, ön işleme sürümü ve kaynak oturum envanteri içermelidir.)*

---

# 183. Research Integrity Acceptance Criteria (Araştırma Bütünlüğü Kabul Kriterleri)

Sessions will not be excluded because their model predictions are inconvenient. *(Oturumlar model tahminleri istenmeyen sonuç verdiği için hariç tutulmayacaktır.)*

Final test data will not be repeatedly recycled into model development while still being described as untouched evaluation data. *(Nihai test verisi hâlâ dokunulmamış değerlendirme verisi olarak açıklanırken tekrar tekrar model geliştirmeye geri dönüştürülmeyecektir.)*

---

# 184. Minimum Dataset Success Definition (Minimum Veri Seti Başarı Tanımı)

The minimum successful Motion Classification dataset will contain session-wise isolated labeled data for all four frozen trained classes and sufficient metadata to reproduce window generation. *(Minimum başarılı Motion Classification dataset'i dört frozen trained class'ın tümü için session-wise isolated labeled data ve window generation'ı reproduce etmek için yeterli metadata içerecektir.)*

The minimum successful Step Length dataset will contain known-distance calibration sessions with defensible step-count reference and clear label granularity. *(Minimum başarılı Adım Uzunluğu veri seti savunulabilir adım sayısı referansına ve açık etiket granülerliğine sahip bilinen mesafeli kalibrasyon oturumlarını içerecektir.)*

---

# 185. Target Dataset Success Definition (Hedef Veri Seti Başarı Tanımı)

The target Motion Classification dataset will contain class-balanced independent-session coverage across multiple routes, activity transitions, and more than one collection context. *(Hedef Hareket Sınıflandırma veri seti birden fazla rota, aktivite geçişi ve birden fazla veri toplama bağlamı genelinde sınıf dengeli bağımsız oturum kapsamı içerecektir.)*

The target Step Length dataset will contain multiple known-distance segments with controlled gait variation and sufficient reference quality to compare deterministic and learned estimators fairly. *(Hedef Adım Uzunluğu veri seti kontrollü gait değişimi ve deterministik ile öğrenilmiş tahmin motorlarını adil karşılaştırmak için yeterli referans kalitesine sahip birden fazla bilinen mesafeli segment içerecektir.)*

---

# 186. Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kararlar)

Physical recording session will be the fundamental unit of ML dataset separation. *(Fiziksel kayıt oturumu ML veri seti ayrımının temel birimi olacaktır.)*

All derived windows and step samples will inherit the split of their source session. *(Tüm türetilmiş pencereler ve adım örnekleri kaynak oturumlarının ayrımını miras alacaktır.)*

Raw recordings will remain immutable. *(Ham kayıtlar değişmez kalacaktır.)*

---

# 187. Motion Dataset Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Hareket Veri Seti Kararları)

Motion Classification collection will target the exact frozen trained class set: `STATIONARY`, `WALKING`, `RUNNING`, and `TURNING`. Any class-set change requires an explicit Technical Decision and versioned Change Record that supersedes TD-058 before dataset freeze. *(Motion Classification collection exact frozen trained class set'i hedefleyecektir: `STATIONARY`, `WALKING`, `RUNNING` ve `TURNING`. Herhangi bir class-set değişikliği dataset freeze öncesinde TD-058'i supersede eden explicit Technical Decision ve versioned Change Record gerektirir.)*

Motion labels will use explicit activity timelines. *(Hareket etiketleri açık aktivite zaman çizgileri kullanacaktır.)*

Ambiguous transition intervals will be handled explicitly. *(Belirsiz geçiş aralıkları açık şekilde yönetilecektir.)*

---

# 188. Step Length Dataset Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Adım Uzunluğu Veri Seti Kararları)

Step-length collection will prioritize known-distance routes or segments. *(Adım uzunluğu veri toplama bilinen mesafeli rota veya segmentlere öncelik verecektir.)*

The dataset will explicitly distinguish per-step, segment-average, and route-average reference quality. *(Veri seti adım başına, segment ortalama ve rota ortalama referans kalitesini açıkça ayırt edecektir.)*

Fabricated per-step ground truth is forbidden. *(Uydurulmuş adım başına ground truth yasaktır.)*

---

# 189. Leakage Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Veri Sızıntısı Kararları)

Random overlapping-window train-test splitting is forbidden. *(Rastgele örtüşen pencere train-test ayrımı yasaktır.)*

Random correlated step-level train-test splitting from the same physical session is forbidden. *(Aynı fiziksel oturumdan rastgele korelasyonlu adım seviyesi train-test ayrımı yasaktır.)*

Normalization statistics will use training data only. *(Normalizasyon istatistikleri yalnızca eğitim verisini kullanacaktır.)*

---

# 190. Ground Truth Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Ground Truth Kararları)

GNSS may support offline route reference or evaluation where scientifically appropriate. *(GNSS bilimsel olarak uygun olduğunda çevrimdışı rota referansını veya değerlendirmeyi destekleyebilir.)*

GNSS ground truth will not become a live deployed AI feature during GNSS-denied navigation. *(GNSS ground truth GNSS kesintili navigasyon sırasında canlı deployment yapay zekâ özelliği haline gelmeyecektir.)*

---

# 191. Quality Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kalite Kararları)

Every physical session will receive an explicit quality-control status before inclusion in a formal dataset. *(Her fiziksel oturum resmî veri setine dahil edilmeden önce açık kalite kontrol durumu alacaktır.)*

Session exclusions will require documented protocol or data-integrity reasons. *(Oturum hariç tutmaları dokümante edilmiş protokol veya veri bütünlüğü nedenleri gerektirecektir.)*

---

# 192. Versioning Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Sürümleme Kararları)

Dataset versions, label versions, preprocessing versions, and split manifests will be stored explicitly. *(Veri seti sürümleri, etiket sürümleri, ön işleme sürümleri ve ayrım manifestleri açık şekilde saklanacaktır.)*

A material change will create a new dataset version rather than silently modifying frozen evidence. *(Anlamlı değişiklik sabitlenmiş kanıtı sessizce değiştirmek yerine yeni veri seti sürümü oluşturacaktır.)*

---

# 193. Collection Decisions Pending Pilot Study (Pilot Çalışmayı Bekleyen Veri Toplama Kararları)

The exact activity-block duration remains pending pilot sessions. *(Kesin aktivite blok süresi pilot oturumları beklemektedir.)*

The exact transition-exclusion margin remains pending annotation experiments. *(Kesin geçiş hariç tutma marjı anotasyon deneylerini beklemektedir.)*

The final `TURNING` temporal and angular annotation rule remains pending pilot analysis. *(Nihai `TURNING` zamansal ve açısal anotasyon kuralı pilot analizini beklemektedir.)*

---

# 194. Coverage Decisions Pending Pilot Study (Pilot Çalışmayı Bekleyen Kapsama Kararları)

The exact number of development sessions per class remains pending pilot data quality and project-time analysis. *(Sınıf başına kesin geliştirme oturumu sayısı pilot veri kalitesini ve proje zaman analizini beklemektedir.)*

The provisional minimum planning gate remains three independent usable sessions for each of the four frozen trained classes. *(Geçici minimum planning gate dört frozen trained class'ın her biri için üç independent usable session olarak kalmaktadır.)*

---

# 195. Split Decisions Pending Dataset Size (Veri Seti Boyutunu Bekleyen Ayrım Kararları)

The final train-validation-test percentage allocation remains pending the total number of usable independent sessions. *(Nihai train-validation-test yüzde dağılımı toplam kullanılabilir bağımsız oturum sayısını beklemektedir.)*

---

# 196. Step Length Reference Decisions Pending Physical Setup (Fiziksel Kurulumu Bekleyen Adım Uzunluğu Referans Kararları)

The final route-distance reference method remains pending identification of the most defensible available known-distance routes or segments. *(Nihai rota mesafe referans yöntemi mevcut en savunulabilir bilinen mesafeli rota veya segmentlerin belirlenmesini beklemektedir.)*

The final achievable label granularity remains pending reference quality. *(Nihai elde edilebilir etiket granülerliği referans kalitesini beklemektedir.)*

---

# 197. Final Dataset Collection Architecture Statement (Nihai Veri Seti Toplama Mimarisi Bildirimi)

**NAVGUARD will build its AI datasets from versioned physical recording sessions collected under a controlled device, phone-placement, sensor, route, and activity protocol rather than from anonymous model windows disconnected from their experimental origin.** *(NAVGUARD yapay zekâ veri setlerini deneysel kökenlerinden kopmuş anonim model pencereleri yerine kontrollü cihaz, telefon yerleşimi, sensör, rota ve aktivite protokolü altında toplanan sürümlenmiş fiziksel kayıt oturumlarından oluşturacaktır.)*

**Every derived motion window and step-length sample will remain traceable to exactly one physical source session, and that complete session will belong to only one of train, validation, or test within a frozen dataset version.** *(Türetilmiş her hareket penceresi ve adım uzunluğu örneği tam olarak bir fiziksel kaynak oturuma izlenebilir kalacak ve o tam oturum sabitlenmiş veri seti sürümü içerisinde yalnızca train, validation veya test gruplarından birine ait olacaktır.)*

**Motion Classification collection will combine clean activity blocks with realistic `walk-stop-walk`, `walk-turn-walk`, mixed-motion, and optional running transitions so that model evaluation reflects both class recognition and operational state changes.** *(Hareket Sınıflandırma veri toplama temiz aktivite bloklarını gerçekçi `yürü-dur-yürü`, `yürü-dön-yürü`, karma hareket ve isteğe bağlı koşu geçişleriyle birleştirecek; böylece model değerlendirmesi hem sınıf tanımayı hem de operasyonel durum değişikliklerini yansıtacaktır.)*

**Step Length collection will prioritize known-distance routes and segments, independently verified step counts, and explicit reference-quality levels so that route-average or segment-average labels are never misrepresented as exact per-step ground truth.** *(Adım Uzunluğu veri toplama bilinen mesafeli rota ve segmentlere, bağımsız doğrulanmış adım sayılarına ve açık referans kalite seviyelerine öncelik verecek; böylece rota ortalama veya segment ortalama etiketleri hiçbir zaman kesin adım başına ground truth olarak yanlış sunulmayacaktır.)*

**Raw sensor recordings will remain immutable, while labels, preprocessing, feature extraction, windows, and ML-ready datasets will be regenerated as versioned derived artifacts with full provenance.** *(Ham sensör kayıtları değişmez kalırken etiketler, ön işleme, özellik çıkarma, pencereler ve ML'ye hazır veri setleri tam köken izlenebilirliğiyle sürümlenmiş türetilmiş artifact'lar olarak yeniden üretilecektir.)*

**Final held-out sessions will remain isolated from normalization fitting, threshold tuning, feature selection, hyperparameter optimization, and architecture selection so that final model metrics represent genuine unseen-session performance rather than data leakage.** *(Nihai ayrılmış oturumlar normalizasyon fit işleminden, eşik ayarından, özellik seçiminden, hiperparametre optimizasyonundan ve mimari seçiminden izole kalacak; böylece nihai model metrikleri veri sızıntısı yerine gerçek görülmemiş oturum performansını temsil edecektir.)*

**Every formal dataset release will include a dataset manifest, split manifest, source-session inventory, label version, preprocessing version, quality-control report, and exclusion report so that every published model result can be traced back to the physical evidence that produced it.** *(Her resmî veri seti sürümü veri seti manifest'i, ayrım manifest'i, kaynak oturum envanteri, etiket sürümü, ön işleme sürümü, kalite kontrol raporu ve hariç tutma raporu içerecek; böylece yayımlanan her model sonucu onu üreten fiziksel kanıta kadar izlenebilecektir.)*

---

# 198. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development Dataset Collection & Labeling Plan Completed *(Doküman Durumu: Geliştirme Öncesi Veri Seti Toplama ve Etiketleme Planı Tamamlandı)*

**Primary Device:** Xiaomi Redmi Note 9 Pro *(Temel Cihaz: Xiaomi Redmi Note 9 Pro)*

**Primary Participant Scope:** Controlled Single-Participant Prototype *(Temel Katılımcı Kapsamı: Kontrollü Tek Katılımcılı Prototip)*

**Primary ML Tasks:** Motion Classification + Step Length Estimation *(Temel ML Görevleri: Hareket Sınıflandırması + Adım Uzunluğu Tahmini)*

**Fundamental Split Unit:** Physical Session *(Temel Ayrım Birimi: Fiziksel Oturum)*

**Raw Data Policy:** Immutable *(Ham Veri Politikası: Değişmez)*

**Derived Data Policy:** Reproducible and Versioned *(Türetilmiş Veri Politikası: Tekrarlanabilir ve Sürümlenmiş)*

**Motion Classes:** `STATIONARY / WALKING / RUNNING / TURNING` *(Hareket Sınıfları: `STATIONARY / WALKING / RUNNING / TURNING`)*

**Primary Motion Sensors:** Accelerometer + Gyroscope *(Temel Hareket Sensörleri: İvmeölçer + Jiroskop)*

**Initial Sampling Target:** Approximately `50 Hz` Accelerometer + `50 Hz` Gyroscope *(İlk Örnekleme Hedefi: Yaklaşık `50 Hz` İvmeölçer + `50 Hz` Jiroskop)*

**Actual Rate Source:** Measured Timestamps *(Gerçek Hız Kaynağı: Ölçülmüş Zaman Damgaları)*

**Formal Phone Placement:** Controlled and Fixed Per Protocol *(Resmî Telefon Yerleşimi: Protokol Başına Kontrollü ve Sabit)*

**Motion Label Source:** Activity Timeline + Protocol Markers + Offline Review *(Hareket Etiket Kaynağı: Aktivite Zaman Çizgisi + Protokol İşaretleyicileri + Çevrimdışı İnceleme)*

**Transition Handling:** Explicit, Final Margin Pending Pilot *(Geçiş Yönetimi: Açık, Nihai Marj Pilot Bekliyor)*

**Provisional Minimum Coverage:** Three Independent Usable Sessions for Each Frozen Trained Class *(Geçici Minimum Kapsam: Her Frozen Trained Class İçin Üç Independent Usable Session)*

**Exact Final Session Count:** Pending Pilot Quality and Schedule Review *(Kesin Nihai Oturum Sayısı: Pilot Kalitesi ve Takvim İncelemesi Bekleniyor)*

**Step Length Reference Priority:** Known-Distance Routes / Segments *(Adım Uzunluğu Referans Önceliği: Bilinen Mesafeli Rotalar / Segmentler)*

**Step Count Reference:** Independently Verified *(Adım Sayısı Referansı: Bağımsız Doğrulanmış)*

**Step Length Label Levels:** `PER_STEP / SEGMENT_AVERAGE / ROUTE_AVERAGE` *(Adım Uzunluğu Etiket Seviyeleri: `PER_STEP / SEGMENT_AVERAGE / ROUTE_AVERAGE`)*

**Fabricated Per-Step Ground Truth:** Forbidden *(Uydurulmuş Adım Başına Ground Truth: Yasak)*

**Dataset Split:** Session-Wise / Route-Session-Wise Where Required *(Veri Seti Ayrımı: Oturum Bazlı / Gerektiğinde Rota-Oturumu Bazlı)*

**Random Window Split:** Forbidden *(Rastgele Pencere Ayrımı: Yasak)*

**Random Correlated Step Split:** Forbidden *(Rastgele Korelasyonlu Adım Ayrımı: Yasak)*

**Training Statistics Source:** Training Split Only *(Eğitim İstatistik Kaynağı: Yalnızca Eğitim Ayrımı)*

**Final Test Isolation:** Mandatory *(Nihai Test İzolasyonu: Zorunlu)*

**Session Quality States:** `ACCEPTED / DEGRADED_BUT_USABLE / EXCLUDED / PENDING_REVIEW` *(Oturum Kalite Durumları: `ACCEPTED / DEGRADED_BUT_USABLE / EXCLUDED / PENDING_REVIEW`)*

**Exclusion Reason:** Mandatory *(Hariç Tutma Nedeni: Zorunlu)*

**Dataset Manifest:** Mandatory *(Veri Seti Manifest'i: Zorunlu)*

**Split Manifest:** Mandatory *(Ayrım Manifest'i: Zorunlu)*

**Source-Session Traceability:** Mandatory *(Kaynak Oturum İzlenebilirliği: Zorunlu)*

**Motion Block Duration:** Pending Pilot *(Hareket Blok Süresi: Pilot Bekleniyor)*

**TURNING Definition Threshold:** Pending Pilot Annotation *(TURNING Tanım Eşiği: Pilot Anotasyon Bekleniyor)*

**Final Train / Validation / Test Ratio:** Pending Usable Session Count *(Nihai Train / Validation / Test Oranı: Kullanılabilir Oturum Sayısı Bekleniyor)*

**Final Step Reference Method:** Pending Physical Route Selection *(Nihai Adım Referans Yöntemi: Fiziksel Rota Seçimi Bekleniyor)*

**Next Documentation Item:** 26 — Machine Learning Training & Evaluation *(Sonraki Dokümantasyon Öğesi: 26 — Makine Öğrenmesi Eğitim ve Değerlendirme)*
