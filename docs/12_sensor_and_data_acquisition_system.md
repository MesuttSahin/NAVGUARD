# 12 — Sensor & Data Acquisition System (Sensör ve Veri Toplama Sistemi)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the sensor sources, acquisition architecture, sampling strategy, timestamp policy, runtime data models, data-quality controls, buffering behavior, and raw-data logging requirements of NAVGUARD. *(Bu doküman, NAVGUARD’ın sensör kaynaklarını, veri toplama mimarisini, örnekleme stratejisini, zaman damgası politikasını, çalışma zamanı veri modellerini, veri kalite kontrollerini, tamponlama davranışını ve ham veri kayıt gereksinimlerini tanımlar.)*

The objective is to create a reproducible acquisition system that preserves the physical measurements required by navigation, machine learning, replay, debugging, and final experimental evaluation. *(Amaç; navigasyon, makine öğrenmesi, yeniden oynatma, hata ayıklama ve nihai deneysel değerlendirme için gerekli fiziksel ölçümleri koruyan tekrarlanabilir bir veri toplama sistemi oluşturmaktır.)*

The acquisition system must preserve measurement evidence before higher-level navigation algorithms modify or interpret that evidence. *(Veri toplama sistemi, daha yüksek seviyeli navigasyon algoritmaları ölçüm kanıtını değiştirmeden veya yorumlamadan önce bu kanıtı korumalıdır.)*

---

# 2. Acquisition Design Principle (Veri Toplama Tasarım İlkesi)

NAVGUARD will use a **measure first, process second, interpret third** data-flow principle. *(NAVGUARD **önce ölç, sonra işle, ardından yorumla** veri akışı ilkesini kullanacaktır.)*

Raw measurements will first enter an authoritative acquisition stream. *(Ham ölçümler önce ana veri toplama akışına girecektir.)*

The measurements may then enter preprocessing, navigation, artificial intelligence, visualization, and logging pipelines. *(Ölçümler daha sonra ön işleme, navigasyon, yapay zekâ, görselleştirme ve kayıt hatlarına girebilir.)*

Processed values must never silently replace the authoritative raw measurements in the research dataset. *(İşlenmiş değerler araştırma veri setindeki ana ham ölçümlerin yerini hiçbir zaman sessizce almamalıdır.)*

---

# 3. Primary Data Sources (Temel Veri Kaynakları)

NAVGUARD will acquire information from multiple mobile-device sources. *(NAVGUARD mobil cihazdaki birden fazla kaynaktan bilgi toplayacaktır.)*

The primary sources will include Android inertial sensors, magnetic sensors, orientation-related sensors, GNSS, and ARCore when enabled. *(Temel kaynaklar Android ataletsel sensörlerini, manyetik sensörleri, yönelimle ilişkili sensörleri, GNSS’i ve etkinleştirildiğinde ARCore’u içerecektir.)*

Artificial intelligence outputs and navigation estimates are derived data sources rather than physical sensor sources. *(Yapay zekâ çıktıları ve navigasyon tahminleri fiziksel sensör kaynakları yerine türetilmiş veri kaynaklarıdır.)*

---

# 4. Sensor Priority Classification (Sensör Öncelik Sınıflandırması)

| Source (Kaynak) | NAVGUARD Role (NAVGUARD Rolü) | Priority (Öncelik) |
| --- | --- | --- |
| Accelerometer *(İvmeölçer)* | Motion and step analysis *(Hareket ve adım analizi)* | CRITICAL *(KRİTİK)* |
| Gyroscope *(Jiroskop)* | Angular motion and heading propagation *(Açısal hareket ve yön ilerletme)* | CRITICAL *(KRİTİK)* |
| Magnetometer *(Manyetometre)* | Earth-referenced heading information *(Dünya referanslı yön bilgisi)* | CRITICAL *(KRİTİK)* |
| Rotation Vector *(Dönüş Vektörü)* | Fused orientation reference *(Füzyonlu yönelim referansı)* | HIGH *(YÜKSEK)* |
| Gravity *(Yerçekimi)* | Optional gravity estimate *(İsteğe bağlı yerçekimi tahmini)* | MEDIUM *(ORTA)* |
| Linear Acceleration *(Doğrusal İvme)* | Optional gravity-compensated acceleration *(İsteğe bağlı yerçekimi telafili ivme)* | MEDIUM *(ORTA)* |
| Step Detector *(Adım Algılayıcı)* | Comparison only *(Yalnızca karşılaştırma)* | LOW *(DÜŞÜK)* |
| Step Counter *(Adım Sayacı)* | Comparison only *(Yalnızca karşılaştırma)* | LOW *(DÜŞÜK)* |
| GNSS | Anchor and ground truth *(Çapa ve gerçek referans)* | CRITICAL *(KRİTİK)* |
| ARCore Pose *(ARCore Pozu)* | Relative visual-inertial motion *(Göreli görsel-ataletsel hareket)* | TARGET *(HEDEF)* |

---

# 5. Physical and Virtual Sensor Separation (Fiziksel ve Sanal Sensör Ayrımı)

NAVGUARD will explicitly distinguish physical sensor measurements from Android-generated virtual or fused sensor outputs. *(NAVGUARD fiziksel sensör ölçümlerini Android tarafından oluşturulan sanal veya füzyonlu sensör çıktılarından açıkça ayıracaktır.)*

The accelerometer, gyroscope, and magnetometer will be treated as the primary physical measurement sources when exposed by the device. *(İvmeölçer, jiroskop ve manyetometre cihaz tarafından sunulduğunda temel fiziksel ölçüm kaynakları olarak ele alınacaktır.)*

Rotation-vector, gravity, and linear-acceleration sensors may be produced using Android sensor fusion and must therefore not automatically be interpreted as independent physical measurements. *(Rotation-vector, gravity ve linear-acceleration sensörleri Android sensör füzyonu kullanılarak üretilebilir ve bu nedenle otomatik olarak bağımsız fiziksel ölçümler şeklinde yorumlanmamalıdır.)*

---

# 6. Authoritative Sensor API (Ana Sensör API’si)

Android `SensorManager` will be the authoritative sensor-discovery and acquisition interface. *(Android `SensorManager` ana sensör keşif ve veri toplama arayüzü olacaktır.)*

Native Kotlin code will register the sensor listeners used by formal NAVGUARD acquisition sessions. *(Native Kotlin kodu resmî NAVGUARD veri toplama oturumlarında kullanılan sensör listener’larını kaydedecektir.)*

The application will use Android sensor events rather than relying on a generic Flutter sensor plugin as the authoritative research source. *(Uygulama ana araştırma kaynağı olarak genel bir Flutter sensör eklentisine güvenmek yerine Android sensör olaylarını kullanacaktır.)*

---

# 7. Complete Sensor Enumeration (Tam Sensör Listeleme)

NAVGUARD must enumerate the complete Android sensor inventory during the Device Capability Audit. *(NAVGUARD Cihaz Yetenek Denetimi sırasında tam Android sensör envanterini listelemelidir.)*

The application must not query only the sensors already expected by the design. *(Uygulama yalnızca tasarım tarafından zaten beklenen sensörleri sorgulamamalıdır.)*

The complete inventory may reveal useful virtual sensors, additional sensor variants, or device-specific implementations. *(Tam envanter kullanışlı sanal sensörleri, ek sensör varyantlarını veya cihaza özgü uygulamaları ortaya çıkarabilir.)*

---

# 8. Sensor Metadata Record (Sensör Metadata Kaydı)

The following metadata should be recorded for each sensor relevant to NAVGUARD. *(NAVGUARD ile ilgili her sensör için aşağıdaki metadata bilgisi kaydedilmelidir.)*

```
sensorType
stringType
name
vendor
version
resolution
maximumRange
minimumDelayUs
maximumDelayUs
power
reportingMode
wakeUpSensor
```

The physical-device values will be frozen only after the Redmi Note 9 Pro audit is completed. *(Fiziksel cihaz değerleri yalnızca Redmi Note 9 Pro denetimi tamamlandıktan sonra sabitlenecektir.)*

---

# 9. Default Sensor Selection Policy (Varsayılan Sensör Seçim Politikası)

NAVGUARD will initially request the Android default sensor for each required sensor type. *(NAVGUARD başlangıçta gerekli her sensör türü için Android varsayılan sensörünü isteyecektir.)*

If the device exposes multiple sensors of the same logical type, the Device Capability Audit will identify the available alternatives. *(Cihaz aynı mantıksal türde birden fazla sensör sunarsa Cihaz Yetenek Denetimi mevcut alternatifleri belirleyecektir.)*

The final selection must be documented rather than changed silently between benchmark sessions. *(Nihai seçim benchmark oturumları arasında sessizce değiştirilmek yerine dokümante edilmelidir.)*

---

# 10. Accelerometer Acquisition (İvmeölçer Veri Toplama)

NAVGUARD will acquire three-axis acceleration using `TYPE_ACCELEROMETER`. *(NAVGUARD `TYPE_ACCELEROMETER` kullanarak üç eksenli ivme verisi toplayacaktır.)*

Android accelerometer values use metres per second squared and include the effect of gravity. *(Android ivmeölçer değerleri metre/saniye kare birimini kullanır ve yerçekimi etkisini içerir.)*

A stationary device is therefore expected to observe an acceleration magnitude close to gravitational acceleration rather than zero. *(Bu nedenle sabit bir cihazın sıfır yerine yerçekimi ivmesine yakın bir ivme büyüklüğü gözlemlemesi beklenir.)*

---

# 11. Raw Accelerometer Model (Ham İvmeölçer Modeli)

A logical raw accelerometer sample will contain the original Android event timestamp and three-axis values. *(Mantıksal bir ham ivmeölçer örneği orijinal Android olay zaman damgasını ve üç eksen değerlerini içerecektir.)*

```
AccelerometerSample
- timestampNs
- sequenceNumber
- ax
- ay
- az
- accuracy
```

Acceleration magnitude may be calculated later as derived data. *(İvme büyüklüğü daha sonra türetilmiş veri olarak hesaplanabilir.)*

---

# 12. Accelerometer Magnitude (İvmeölçer Büyüklüğü)

A derived acceleration magnitude may be calculated as follows. *(Türetilmiş ivme büyüklüğü aşağıdaki şekilde hesaplanabilir.)*

```
|a| = sqrt(ax² + ay² + az²)
```

This value will be useful for baseline step detection and motion analysis. *(Bu değer temel adım tespiti ve hareket analizi için kullanışlı olacaktır.)*

The magnitude must be stored as derived data if retained, not falsely labelled as a raw sensor channel. *(Büyüklük saklanırsa türetilmiş veri olarak saklanmalı ve yanlış şekilde ham sensör kanalı olarak etiketlenmemelidir.)*

---

# 13. Gyroscope Acquisition (Jiroskop Veri Toplama)

NAVGUARD will acquire three-axis angular velocity using `TYPE_GYROSCOPE`. *(NAVGUARD `TYPE_GYROSCOPE` kullanarak üç eksenli açısal hız verisi toplayacaktır.)*

The gyroscope will primarily support turning detection, short-term orientation propagation, and heading stabilization. *(Jiroskop temel olarak dönüş tespiti, kısa süreli yönelim ilerletme ve yön kararlılığını destekleyecektir.)*

Stationary gyroscope measurements will also be used to characterize bias-like behavior and sensor noise. *(Sabit jiroskop ölçümleri ayrıca bias benzeri davranışı ve sensör gürültüsünü karakterize etmek için kullanılacaktır.)*

---

# 14. Raw Gyroscope Model (Ham Jiroskop Modeli)

```
GyroscopeSample
- timestampNs
- sequenceNumber
- gx
- gy
- gz
- accuracy
```

The original values will be preserved before bias correction or filtering. *(Orijinal değerler bias düzeltmesi veya filtrelemeden önce korunacaktır.)*

A corrected gyroscope stream, if implemented, will remain separate from the raw stream. *(Düzeltilmiş bir jiroskop akışı geliştirilirse ham akıştan ayrı kalacaktır.)*

---

# 15. Magnetometer Acquisition (Manyetometre Veri Toplama)

NAVGUARD will acquire three-axis geomagnetic field measurements using `TYPE_MAGNETIC_FIELD`. *(NAVGUARD `TYPE_MAGNETIC_FIELD` kullanarak üç eksenli jeomanyetik alan ölçümleri toplayacaktır.)*

Android reports geomagnetic field values in microtesla. *(Android jeomanyetik alan değerlerini mikrotesla cinsinden raporlar.)*

The magnetometer will provide an Earth-referenced directional cue but will not be assumed reliable in every environment. *(Manyetometre Dünya referanslı bir yön ipucu sağlayacak ancak her ortamda güvenilir olduğu varsayılmayacaktır.)*

---

# 16. Raw Magnetometer Model (Ham Manyetometre Modeli)

```
MagnetometerSample
- timestampNs
- sequenceNumber
- mx
- my
- mz
- accuracy
```

Magnetic magnitude and disturbance indicators will be calculated as derived data. *(Manyetik büyüklük ve bozulma göstergeleri türetilmiş veri olarak hesaplanacaktır.)*

The Android accuracy state will be preserved when provided. *(Android doğruluk durumu sağlandığında korunacaktır.)*

---

# 17. Magnetic Field Magnitude (Manyetik Alan Büyüklüğü)

A derived magnetic field magnitude may be calculated as follows. *(Türetilmiş manyetik alan büyüklüğü aşağıdaki şekilde hesaplanabilir.)*

```
|m| = sqrt(mx² + my² + mz²)
```

Sudden or persistent abnormal changes may later contribute to sensor-confidence logic. *(Ani veya kalıcı anormal değişiklikler daha sonra sensör güveni mantığına katkıda bulunabilir.)*

No fixed magnetic disturbance threshold will be frozen before field measurements are collected. *(Saha ölçümleri toplanmadan sabit bir manyetik bozulma eşiği sabitlenmeyecektir.)*

---

# 18. Rotation Vector Acquisition (Dönüş Vektörü Veri Toplama)

NAVGUARD should acquire `TYPE_ROTATION_VECTOR` if the physical device exposes it reliably. *(Fiziksel cihaz güvenilir şekilde sunuyorsa NAVGUARD `TYPE_ROTATION_VECTOR` verisini toplamalıdır.)*

The rotation vector provides Android-fused orientation information and uses a world-referenced coordinate definition related approximately to east, geomagnetic north, and sky. *(Rotation vector, Android tarafından füzyonlanmış yönelim bilgisi sağlar ve yaklaşık olarak doğu, jeomanyetik kuzey ve gökyüzüyle ilişkili dünya referanslı bir koordinat tanımı kullanır.)*

Rotation-vector output will not be treated as an independent replacement for recording the underlying physical sensors. *(Rotation-vector çıktısı temel fiziksel sensörlerin kaydedilmesinin bağımsız bir alternatifi olarak ele alınmayacaktır.)*

---

# 19. Rotation Vector Model (Dönüş Vektörü Modeli)

```
RotationVectorSample
- timestampNs
- sequenceNumber
- x
- y
- z
- wOrScalarIfAvailable
- headingAccuracyIfAvailable
- accuracy
```

The exact number and interpretation of returned values will follow the Android sensor implementation exposed on the physical device. *(Döndürülen değerlerin kesin sayısı ve yorumu fiziksel cihaz üzerinde sunulan Android sensör uygulamasını izleyecektir.)*

Quaternion conversion will be performed in the orientation-processing layer rather than altering the raw event record. *(Quaternion dönüşümü ham olay kaydını değiştirmek yerine yönelim işleme katmanında gerçekleştirilecektir.)*

---

# 20. Game Rotation Vector (Oyun Dönüş Vektörü)

`TYPE_GAME_ROTATION_VECTOR` may be recorded during the Device Capability Audit when available. *(`TYPE_GAME_ROTATION_VECTOR` mevcut olduğunda Cihaz Yetenek Denetimi sırasında kaydedilebilir.)*

It may provide useful short-term rotational information without relying on geomagnetic north. *(Jeomanyetik kuzeye bağımlı olmadan kullanışlı kısa süreli dönme bilgisi sağlayabilir.)*

It will initially remain an experimental comparison source rather than a mandatory navigation dependency. *(Başlangıçta zorunlu bir navigasyon bağımlılığı yerine deneysel bir karşılaştırma kaynağı olarak kalacaktır.)*

---

# 21. Gravity Sensor (Yerçekimi Sensörü)

`TYPE_GRAVITY` will be audited and may be recorded if available. *(`TYPE_GRAVITY` denetlenecek ve mevcutsa kaydedilebilir.)*

Android defines this sensor as a three-dimensional estimate of the direction and magnitude of gravity. *(Android bu sensörü yerçekiminin yönü ve büyüklüğünün üç boyutlu tahmini olarak tanımlar.)*

NAVGUARD will not depend on this virtual sensor because gravity can also be estimated through the project’s preprocessing pipeline when required. *(NAVGUARD bu sanal sensöre bağımlı olmayacaktır çünkü gerektiğinde yerçekimi projenin ön işleme hattı üzerinden de tahmin edilebilir.)*

---

# 22. Linear Acceleration Sensor (Doğrusal İvme Sensörü)

`TYPE_LINEAR_ACCELERATION` will be audited and may be recorded if available. *(`TYPE_LINEAR_ACCELERATION` denetlenecek ve mevcutsa kaydedilebilir.)*

Android defines linear acceleration as device acceleration with the estimated gravity component removed. *(Android doğrusal ivmeyi, tahmini yerçekimi bileşeni çıkarılmış cihaz ivmesi olarak tanımlar.)*

The output may contain offsets and will therefore not automatically be assumed superior to NAVGUARD’s own preprocessing. *(Çıktı offset içerebilir ve bu nedenle NAVGUARD’ın kendi ön işlemesinden otomatik olarak daha üstün olduğu varsayılmayacaktır.)*

---

# 23. Native Step Detector and Step Counter (Native Adım Algılayıcı ve Adım Sayacı)

Android’s `TYPE_STEP_DETECTOR` and `TYPE_STEP_COUNTER` may be acquired for diagnostic comparison if the Redmi Note 9 Pro exposes them. *(Redmi Note 9 Pro bunları sunuyorsa Android’in `TYPE_STEP_DETECTOR` ve `TYPE_STEP_COUNTER` sensörleri tanısal karşılaştırma için kullanılabilir.)*

They will not become the primary NAVGUARD step-detection source. *(Bunlar temel NAVGUARD adım tespit kaynağı haline gelmeyecektir.)*

On Android 10 and later, use of the Android step detector requires activity-recognition permission, so this permission should be requested only if the optional comparison feature is actually enabled. *(Android 10 ve sonrasında Android adım algılayıcısının kullanımı activity-recognition izni gerektirdiği için bu izin yalnızca isteğe bağlı karşılaştırma özelliği gerçekten etkinleştirilirse istenmelidir.)*

---

# 24. Barometer Policy (Barometre Politikası)

NAVGUARD will not include pressure data in the mandatory acquisition configuration. *(NAVGUARD basınç verisini zorunlu veri toplama yapılandırmasına dahil etmeyecektir.)*

`TYPE_PRESSURE` may still be checked during complete sensor enumeration. *(`TYPE_PRESSURE` tam sensör listeleme sırasında yine kontrol edilebilir.)*

If the physical device unexpectedly exposes a usable pressure sensor, it will remain outside the frozen core architecture unless a documented project change is approved. *(Fiziksel cihaz beklenmedik şekilde kullanılabilir bir basınç sensörü sunarsa dokümante edilmiş bir proje değişikliği onaylanmadığı sürece sabitlenmiş temel mimarinin dışında kalacaktır.)*

---

# 25. Android Sensor Coordinate System (Android Sensör Koordinat Sistemi)

Android motion and magnetic sensors use a device-relative coordinate system. *(Android hareket ve manyetik sensörleri cihaz göreli bir koordinat sistemi kullanır.)*

In the standard Android sensor coordinate system, X points toward the right side of the device, Y points toward the top, and Z points outward from the screen in the device’s natural orientation. *(Standart Android sensör koordinat sisteminde cihazın doğal yöneliminde X cihazın sağına, Y üst tarafına ve Z ekranın dışına doğru yönelir.)*

The sensor coordinate frame does not rotate merely because the screen orientation changes. *(Sensör koordinat sistemi yalnızca ekran yönelimi değiştiği için dönmez.)*

---

# 26. Device Frame Preservation (Cihaz Koordinat Sisteminin Korunması)

Raw IMU measurements will be stored in the Android device coordinate frame. *(Ham IMU ölçümleri Android cihaz koordinat sisteminde saklanacaktır.)*

World-frame or navigation-frame transformations will create separate processed values. *(Dünya koordinat sistemine veya navigasyon koordinat sistemine dönüşümler ayrı işlenmiş değerler oluşturacaktır.)*

This ensures that future algorithms can reproduce coordinate transformations from the original measurements. *(Bu, gelecekteki algoritmaların orijinal ölçümlerden koordinat dönüşümlerini yeniden oluşturabilmesini sağlar.)*

---

# 27. Screen Orientation Independence (Ekran Yönelimi Bağımsızlığı)

Sensor measurements must not be altered simply to match the current visual screen rotation before they are stored as raw data. *(Sensör ölçümleri ham veri olarak saklanmadan önce yalnızca mevcut görsel ekran dönüşüne uyması için değiştirilmemelidir.)*

Screen-oriented transformations may be created separately when required for visualization. *(Görselleştirme için gerekli olduğunda ekran yönelimli dönüşümler ayrı olarak oluşturulabilir.)*

Navigation-frame transformations will be controlled by the dedicated coordinate and orientation pipeline. *(Navigasyon koordinat sistemi dönüşümleri özel koordinat ve yönelim hattı tarafından kontrol edilecektir.)*

---

# 28. Sensor Timestamp Authority (Sensör Zaman Damgası Otoritesi)

`SensorEvent.timestamp` will be the authoritative acquisition timestamp for Android sensor measurements. *(`SensorEvent.timestamp`, Android sensör ölçümleri için ana veri toplama zaman damgası olacaktır.)*

Android defines this timestamp in nanoseconds using the same time base as `SystemClock.elapsedRealtimeNanos()`. *(Android bu zaman damgasını `SystemClock.elapsedRealtimeNanos()` ile aynı zaman tabanını kullanarak nanosaniye cinsinden tanımlar.)*

For each individual sensor, new timestamps should increase monotonically. *(Her bireysel sensör için yeni zaman damgalarının monotonik olarak artması beklenir.)*

---

# 29. Callback Time Is Not Measurement Time (Callback Zamanı Ölçüm Zamanı Değildir)

NAVGUARD must distinguish measurement time from callback-processing time. *(NAVGUARD ölçüm zamanı ile callback işleme zamanını birbirinden ayırmalıdır.)*

The arrival time of an event in Kotlin or Dart will not replace the Android sensor timestamp. *(Bir olayın Kotlin veya Dart’a ulaşma zamanı Android sensör zaman damgasının yerini almayacaktır.)*

Callback time may optionally be recorded for latency diagnostics. *(Callback zamanı gecikme tanısı için isteğe bağlı olarak kaydedilebilir.)*

---

# 30. Optional Reception Timestamp (İsteğe Bağlı Alım Zaman Damgası)

A diagnostic event representation may include both measurement timestamp and application-reception timestamp. *(Tanısal bir olay temsili hem ölçüm zaman damgasını hem de uygulama alım zaman damgasını içerebilir.)*

```
measurementTimestampNs
nativeReceptionTimestampNs
```

The difference may help characterize callback and processing latency. *(Aradaki fark callback ve işleme gecikmesini karakterize etmeye yardımcı olabilir.)*

This diagnostic timestamp must not replace the physical measurement timestamp in navigation calculations. *(Bu tanısal zaman damgası navigasyon hesaplamalarında fiziksel ölçüm zaman damgasının yerini almamalıdır.)*

---

# 31. Sequence Numbers (Sıra Numaraları)

Each authoritative sensor stream may maintain a locally increasing sequence number. *(Her ana sensör akışı yerel olarak artan bir sıra numarası tutabilir.)*

Sequence numbers will assist with detecting unexpected duplication, gaps, reordering, or pipeline losses. *(Sıra numaraları beklenmedik tekrarları, boşlukları, sıralama değişikliklerini veya hat içi kayıpları tespit etmeye yardımcı olacaktır.)*

Sequence numbers are diagnostic metadata and will not replace timestamps. *(Sıra numaraları tanısal metadata bilgisidir ve zaman damgalarının yerini almayacaktır.)*

---

# 32. GNSS Acquisition Source (GNSS Veri Toplama Kaynağı)

NAVGUARD will acquire formal GNSS reference positions using the Android native location layer defined in the technology stack. *(NAVGUARD resmî GNSS referans konumlarını teknoloji yığınında tanımlanan Android native konum katmanı üzerinden elde edecektir.)*

Each GNSS record will preserve latitude, longitude, Android-reported accuracy, and timing information. *(Her GNSS kaydı enlem, boylam, Android tarafından bildirilen doğruluk ve zamanlama bilgisini koruyacaktır.)*

Optional fields such as altitude, speed, and bearing will be preserved only when Android indicates that they are available. *(Yükseklik, hız ve yön açısı gibi isteğe bağlı alanlar yalnızca Android mevcut olduklarını belirttiğinde korunacaktır.)*

---

# 33. GNSS Timing Authority (GNSS Zamanlama Otoritesi)

`Location.getElapsedRealtimeNanos()` will be the preferred monotonic timestamp for aligning Android location fixes with sensor measurements. *(`Location.getElapsedRealtimeNanos()`, Android konum fix’lerini sensör ölçümleriyle hizalamak için tercih edilen monotonik zaman damgası olacaktır.)*

Android defines this value as nanoseconds of elapsed realtime since system boot and guarantees valid elapsed-realtime information for locations generated by `LocationManager`. *(Android bu değeri sistem açılışından itibaren geçen sürenin nanosaniyeleri olarak tanımlar ve `LocationManager` tarafından oluşturulan konumlar için geçerli elapsed-realtime bilgisini garanti eder.)*

This makes Android sensor and GNSS timelines directly comparable within the same boot session. *(Bu, aynı cihaz açılış oturumu içerisinde Android sensör ve GNSS zaman çizelgelerini doğrudan karşılaştırılabilir hale getirir.)*

---

# 34. GNSS Wall-Clock Time (GNSS Duvar Saati Zamanı)

Human-readable location time may also be recorded separately. *(İnsan tarafından okunabilir konum zamanı ayrıca kaydedilebilir.)*

Wall-clock time will be used for file metadata, user-facing timestamps, and experiment documentation rather than primary sensor fusion. *(Duvar saati zamanı temel sensör füzyonu yerine dosya metadata bilgisi, kullanıcıya görünen zaman damgaları ve deney dokümantasyonu için kullanılacaktır.)*

Monotonic elapsed time will remain the preferred basis for within-session timing calculations. *(Oturum içi zamanlama hesaplamaları için monotonik geçen zaman tercih edilen temel olarak kalacaktır.)*

---

# 35. GNSS Raw Data Model (GNSS Ham Veri Modeli)

```
GnssSample
- elapsedRealtimeNs
- wallClockTimeMs
- sequenceNumber
- latitude
- longitude
- horizontalAccuracyM
- altitudeM
- altitudeAvailable
- speedMps
- speedAvailable
- bearingDeg
- bearingAvailable
- provider
```

Missing optional values must be represented as unavailable rather than fabricated numeric measurements. *(Eksik isteğe bağlı değerler uydurulmuş sayısal ölçümler yerine kullanılamaz olarak temsil edilmelidir.)*

---

# 36. GNSS Ground Truth Stream (GNSS Gerçek Referans Akışı)

Evaluation GNSS data will have a dedicated logical ground-truth stream. *(Değerlendirme GNSS verisi özel bir mantıksal gerçek referans akışına sahip olacaktır.)*

The stream will continue recording while estimator GNSS access is blocked during Evaluation Mode. *(Akış, Değerlendirme Modunda tahmin motoru GNSS erişimi engelliyken kayda devam edecektir.)*

The logger must not depend on the estimator accepting the GNSS sample. *(Logger, tahmin motorunun GNSS örneğini kabul etmesine bağımlı olmamalıdır.)*

---

# 37. GNSS Estimator Input Stream (GNSS Tahmin Motoru Girdi Akışı)

GNSS measurements intended for estimator correction will pass through the Navigation Mode authorization gate. *(Tahmin motoru düzeltmesi için kullanılan GNSS ölçümleri Navigasyon Modu yetkilendirme kapısından geçecektir.)*

The gate will be OPEN during permitted GNSS states and BLOCKED during the primary GNSS-denied evaluation window. *(Kapı izin verilen GNSS durumlarında OPEN, temel GNSS kesintili değerlendirme penceresinde BLOCKED olacaktır.)*

The acquisition subsystem itself will not stop ground-truth recording when this estimator gate closes. *(Bu tahmin motoru kapısı kapandığında veri toplama alt sistemi gerçek referans kaydını durdurmayacaktır.)*

---

# 38. GNSS Acquisition Rate Policy (GNSS Veri Toplama Hızı Politikası)

GNSS does not require IMU-level sampling frequency for NAVGUARD. *(GNSS, NAVGUARD için IMU seviyesinde örnekleme frekansı gerektirmez.)*

The requested GNSS update configuration will prioritize stable ground-truth recording over unnecessarily high update rates. *(Talep edilen GNSS güncelleme yapılandırması gereksiz yüksek güncelleme hızları yerine kararlı gerçek referans kaydına öncelik verecektir.)*

The effective GNSS update rate will be measured on the physical device rather than assumed from the requested interval. *(Etkin GNSS güncelleme hızı talep edilen aralıktan varsayılmak yerine fiziksel cihaz üzerinde ölçülecektir.)*

---

# 39. ARCore Acquisition Source (ARCore Veri Toplama Kaynağı)

ARCore will provide a separate visual-inertial relative-pose stream when an ARCore-enabled profile is active. *(ARCore etkin bir profil aktif olduğunda ARCore ayrı bir görsel-ataletsel göreli poz akışı sağlayacaktır.)*

The native ARCore component will acquire pose information only while the ARCore tracking state is suitable. *(Native ARCore bileşeni poz bilgisini yalnızca ARCore takip durumu uygun olduğunda elde edecektir.)*

Invalid tracking states will be recorded rather than converted into artificial pose measurements. *(Geçersiz takip durumları yapay poz ölçümlerine dönüştürülmek yerine kaydedilecektir.)*

---

# 40. ARCore Frame Timestamp (ARCore Kare Zaman Damgası)

ARCore `Frame.getTimestamp()` provides a timestamp in nanoseconds for the captured frame. *(ARCore `Frame.getTimestamp()` yakalanan kare için nanosaniye cinsinden bir zaman damgası sağlar.)*

Google explicitly does not define its time base as an Android elapsed-realtime guarantee. *(Google bunun zaman tabanını Android elapsed-realtime garantisi olarak açıkça tanımlamaz.)*

NAVGUARD must therefore not directly assume that ARCore frame timestamps and Android sensor timestamps are numerically interchangeable. *(Bu nedenle NAVGUARD, ARCore kare zaman damgaları ile Android sensör zaman damgalarının sayısal olarak doğrudan birbirinin yerine kullanılabileceğini varsaymamalıdır.)*

---

# 41. ARCore Timestamp Synchronization Requirement (ARCore Zaman Damgası Senkronizasyon Gereksinimi)

The ARCore stream will preserve the original ARCore timestamp. *(ARCore akışı orijinal ARCore zaman damgasını koruyacaktır.)*

The native reception time may additionally be captured using the common Android monotonic clock. *(Native alım zamanı ayrıca ortak Android monotonik saat kullanılarak yakalanabilir.)*

A deterministic timestamp-alignment strategy will be defined before ARCore is fused with IMU or PDR measurements. *(ARCore IMU veya PDR ölçümleriyle füzyonlanmadan önce deterministik bir zaman damgası hizalama stratejisi tanımlanacaktır.)*

The detailed method belongs to **13 — Sensor Timing, Synchronization & Preprocessing**. *(Ayrıntılı yöntem **13 — Sensor Timing, Synchronization & Preprocessing** bölümüne aittir.)*

---

# 42. ARCore Pose Model (ARCore Poz Modeli)

```
ArcorePoseSample
- frameTimestampNs
- nativeReceptionTimestampNs
- sequenceNumber
- translationX
- translationY
- translationZ
- quaternionX
- quaternionY
- quaternionZ
- quaternionW
- trackingState
```

The translation values will initially remain expressed in the ARCore world coordinate system. *(Öteleme değerleri başlangıçta ARCore dünya koordinat sisteminde ifade edilmiş olarak kalacaktır.)*

Alignment to NAVGUARD’s local navigation frame will occur later in the processing pipeline. *(NAVGUARD’ın yerel navigasyon koordinat sistemiyle hizalama daha sonra işleme hattında gerçekleşecektir.)*

---

# 43. ARCore Android Sensor Pose (ARCore Android Sensör Pozu)

ARCore exposes an Android sensor coordinate-system pose for a frame through its API. *(ARCore API üzerinden bir kare için Android sensör koordinat sistemi pozunu sunar.)*

Google specifies that this pose is useful only while camera tracking is in the `TRACKING` state. *(Google bu pozun yalnızca kamera takibi `TRACKING` durumundayken kullanışlı olduğunu belirtir.)*

NAVGUARD may investigate this information during the ARCore integration phase if it improves coordinate alignment. *(NAVGUARD koordinat hizalamayı iyileştirirse ARCore entegrasyon aşamasında bu bilgiyi araştırabilir.)*

---

# 44. Sampling Configuration Philosophy (Örnekleme Yapılandırma Yaklaşımı)

The requested sensor sampling period will be treated as a configuration target rather than a guaranteed physical frequency. *(Talep edilen sensör örnekleme periyodu garanti edilmiş fiziksel frekans yerine bir yapılandırma hedefi olarak ele alınacaktır.)*

Android explicitly treats the requested sampling period as a hint and may deliver events faster or slower than requested. *(Android talep edilen örnekleme periyodunu açıkça bir öneri olarak ele alır ve olayları istenenden daha hızlı veya daha yavaş teslim edebilir.)*

Every final algorithm must therefore use observed timestamps instead of assuming ideal periodic sampling. *(Bu nedenle her nihai algoritma ideal periyodik örnekleme varsaymak yerine gözlemlenen zaman damgalarını kullanmalıdır.)*

---

# 45. Explicit Sampling Periods (Açık Örnekleme Periyotları)

NAVGUARD should request explicit sampling periods in microseconds rather than depend only on broad `SENSOR_DELAY_*` categories for formal experiments. *(NAVGUARD resmî deneylerde yalnızca geniş `SENSOR_DELAY_*` kategorilerine bağlı olmak yerine mikrosaniye cinsinden açık örnekleme periyotları istemelidir.)*

This improves configuration traceability. *(Bu yapılandırma izlenebilirliğini iyileştirir.)*

The requested value will still remain subject to actual device delivery behavior. *(Talep edilen değer yine de gerçek cihaz teslim davranışına tabi olacaktır.)*

---

# 46. Initial Sampling Configuration (Başlangıç Örnekleme Yapılandırması)

| Source (Kaynak) | Initial Target (Başlangıç Hedefi) | Status (Durum) |
| --- | --- | --- |
| Accelerometer *(İvmeölçer)* | 50 Hz / 20,000 µs | Provisional *(Geçici)* |
| Gyroscope *(Jiroskop)* | 50 Hz / 20,000 µs | Provisional *(Geçici)* |
| Magnetometer *(Manyetometre)* | 20–50 Hz | Provisional *(Geçici)* |
| Rotation Vector *(Dönüş Vektörü)* | Approximately 50 Hz if supported *(Desteklenirse yaklaşık 50 Hz)* | Provisional *(Geçici)* |
| Gravity *(Yerçekimi)* | Match required processing rate *(Gerekli işleme hızına uyumlu)* | Optional *(İsteğe Bağlı)* |
| Linear Acceleration *(Doğrusal İvme)* | Match required processing rate *(Gerekli işleme hızına uyumlu)* | Optional *(İsteğe Bağlı)* |
| GNSS | Device-measured practical rate *(Cihazda ölçülen pratik hız)* | To Be Measured *(Ölçülecek)* |
| ARCore | Per available AR frame *(Mevcut AR karesi başına)* | Runtime Controlled *(Çalışma Zamanı Kontrollü)* |

---

# 47. 50 Hz IMU Baseline Rationale (50 Hz IMU Temel Referans Gerekçesi)

Approximately 50 Hz provides an appropriate initial engineering target for pedestrian motion, step analysis, heading processing, and lightweight time-series AI. *(Yaklaşık 50 Hz yaya hareketi, adım analizi, yön işleme ve hafif zaman serisi yapay zekâsı için uygun bir başlangıç mühendislik hedefi sağlar.)*

This value is not being defined as an empirically optimal rate before measurements exist. *(Bu değer ölçümler mevcut olmadan ampirik olarak optimum hız şeklinde tanımlanmamaktadır.)*

The Device Capability Audit and later algorithm experiments may select a different frozen rate. *(Cihaz Yetenek Denetimi ve sonraki algoritma deneyleri farklı bir sabitlenmiş hız seçebilir.)*

---

# 48. Real-Time Reporting Latency (Gerçek Zamanlı Raporlama Gecikmesi)

The initial formal-navigation configuration should request low-latency sensor delivery. *(İlk resmî navigasyon yapılandırması düşük gecikmeli sensör teslimi istemelidir.)*

Android allows a maximum report latency to be supplied when a sensor listener is registered. *(Android sensör listener’ı kaydedildiğinde maksimum raporlama gecikmesinin belirtilmesine izin verir.)*

A value of zero requests events to be delivered as soon as possible rather than intentionally retained for sensor batching. *(Sıfır değeri olayların sensör batching amacıyla kasıtlı olarak bekletilmesi yerine mümkün olan en kısa sürede teslim edilmesini ister.)*

---

# 49. Initial Batching Policy (Başlangıç Batching Politikası)

The initial real-time navigation and dataset-acquisition configuration will prefer `maxReportLatencyUs = 0`. *(İlk gerçek zamanlı navigasyon ve veri seti toplama yapılandırması `maxReportLatencyUs = 0` değerini tercih edecektir.)*

This minimizes intentional acquisition latency and simplifies early timing analysis. *(Bu kasıtlı veri toplama gecikmesini azaltır ve ilk zamanlama analizini basitleştirir.)*

Sensor batching may later be evaluated for battery optimization only if it does not compromise navigation or synchronization requirements. *(Sensör batching daha sonra yalnızca navigasyon veya senkronizasyon gereksinimlerini bozmazsa batarya optimizasyonu için değerlendirilebilir.)*

---

# 50. Native Acquisition Thread (Native Veri Toplama Thread’i)

The initial native sensor implementation should deliver formal sensor callbacks to a dedicated Android execution context rather than intentionally performing heavy work on the primary UI thread. *(İlk native sensör uygulaması resmî sensör callback’lerini kasıtlı olarak ana UI thread’inde ağır işlem yapmak yerine özel bir Android çalışma bağlamına teslim etmelidir.)*

Android `SensorManager` supports listener registration with a `Handler`, allowing callback delivery to be assigned to an appropriate looper. *(Android `SensorManager`, bir `Handler` ile listener kaydını destekleyerek callback tesliminin uygun bir looper’a atanmasına olanak sağlar.)*

The exact threading implementation will be benchmarked on the physical device. *(Kesin threading uygulaması fiziksel cihaz üzerinde benchmark edilecektir.)*

---

# 51. Sensor Callback Responsibilities (Sensör Callback Sorumlulukları)

The sensor callback must perform only the minimum work necessary to preserve the measurement and transfer it into the acquisition pipeline. *(Sensör callback’i yalnızca ölçümü korumak ve veri toplama hattına aktarmak için gerekli minimum işi gerçekleştirmelidir.)*

Expensive filtering, database operations, map updates, or neural inference must not be performed synchronously inside every raw sensor callback. *(Pahalı filtreleme, veritabanı işlemleri, harita güncellemeleri veya sinir ağı çıkarımı her ham sensör callback’i içerisinde senkron olarak gerçekleştirilmemelidir.)*

This reduces the risk of callback delays and dropped processing opportunities. *(Bu callback gecikmeleri ve kaçırılan işleme fırsatları riskini azaltır.)*

---

# 52. Acquisition Fan-Out (Veri Toplama Çoklama Akışı)

A raw measurement may need to reach multiple downstream consumers. *(Bir ham ölçümün birden fazla aşağı akış tüketicisine ulaşması gerekebilir.)*

```
Android Sensor Event
        │
        ▼
Authoritative Acquisition Stream
        │
        ├────────► Raw Logger
        │
        ├────────► Preprocessing
        │
        └────────► Diagnostics
```

The raw logger and navigation processor must consume the same authoritative measurement rather than independently registering duplicate physical listeners. *(Ham logger ve navigasyon işlemcisi bağımsız yinelenen fiziksel listener’lar kaydetmek yerine aynı ana ölçümü kullanmalıdır.)*

---

# 53. Single Listener Ownership (Tek Listener Sahipliği)

Formal NAVGUARD sessions should use one clearly owned listener path for each physical Android sensor. *(Resmî NAVGUARD oturumları her fiziksel Android sensörü için açıkça sahip olunan tek bir listener hattı kullanmalıdır.)*

The Sensor Monitor screen will observe the existing acquisition stream rather than creating another high-frequency listener. *(Sensör İzleme ekranı başka bir yüksek frekanslı listener oluşturmak yerine mevcut veri toplama akışını gözlemleyecektir.)*

This prevents diagnostic screens from changing the sensor workload of an experiment. *(Bu tanı ekranlarının bir deneyin sensör iş yükünü değiştirmesini önler.)*

---

# 54. Raw Sensor Buffer (Ham Sensör Tamponu)

A bounded in-memory buffer may temporarily hold acquired measurements before downstream processing or persistent storage. *(Sınırlı bir bellek içi tampon, aşağı akış işleme veya kalıcı depolamadan önce elde edilen ölçümleri geçici olarak tutabilir.)*

The buffer must have a defined maximum size. *(Tamponun tanımlanmış maksimum boyutu olmalıdır.)*

The application must not allow the buffer to grow without limit when downstream processing falls behind. *(Aşağı akış işleme geride kaldığında uygulama tamponun sınırsız büyümesine izin vermemelidir.)*

---

# 55. Ring Buffers for Active Algorithms (Aktif Algoritmalar İçin Ring Buffer’lar)

Fixed-size ring buffers may hold the recent sensor history required by filtering and machine-learning windows. *(Sabit boyutlu ring buffer’lar filtreleme ve makine öğrenmesi pencereleri için gerekli son sensör geçmişini tutabilir.)*

The buffer size will be calculated from the maximum required time window and effective sampling rate. *(Tampon boyutu gerekli maksimum zaman penceresi ve etkin örnekleme hızından hesaplanacaktır.)*

Long-term session storage must not depend on retaining the entire recording in memory. *(Uzun süreli oturum depolama tüm kaydı bellekte tutmaya bağımlı olmamalıdır.)*

---

# 56. Logging Queue (Kayıt Kuyruğu)

Persistent logging will use a queue or equivalent controlled buffering mechanism when necessary. *(Kalıcı kayıt gerektiğinde bir kuyruk veya eşdeğer kontrollü tamponlama mekanizması kullanacaktır.)*

Sensor callbacks will enqueue lightweight immutable records. *(Sensör callback’leri hafif değiştirilemez kayıtları kuyruğa ekleyecektir.)*

A dedicated writer will perform append-oriented disk writes. *(Özel bir writer append odaklı disk yazma işlemlerini gerçekleştirecektir.)*

---

# 57. Logging Queue Health (Kayıt Kuyruğu Sağlığı)

NAVGUARD should monitor logging queue depth during development and benchmark sessions. *(NAVGUARD geliştirme ve benchmark oturumları sırasında kayıt kuyruğu derinliğini izlemelidir.)*

A continuously growing queue indicates that persistent storage or downstream processing cannot keep pace with acquisition. *(Sürekli büyüyen bir kuyruk kalıcı depolamanın veya aşağı akış işlemenin veri toplamaya yetişemediğini gösterir.)*

Such a condition must generate a diagnostic warning rather than remain invisible. *(Böyle bir durum görünmez kalmak yerine tanısal bir uyarı üretmelidir.)*

---

# 58. Overflow Policy (Taşma Politikası)

The system must define explicit behavior if a bounded acquisition or logging queue reaches capacity. *(Sınırlı bir veri toplama veya kayıt kuyruğu kapasiteye ulaşırsa sistem açık davranış tanımlamalıdır.)*

The preferred solution is to prevent sustained overload through efficient processing rather than routinely discard research samples. *(Tercih edilen çözüm araştırma örneklerini rutin olarak düşürmek yerine verimli işleme yoluyla sürekli aşırı yükü önlemektir.)*

If measurement loss occurs, the loss must be measurable and recorded. *(Ölçüm kaybı meydana gelirse kayıp ölçülebilir ve kaydedilmiş olmalıdır.)*

---

# 59. No Silent Sample Fabrication (Sessiz Örnek Uydurma Olmaması)

The acquisition layer will never fabricate missing physical sensor measurements. *(Veri toplama katmanı eksik fiziksel sensör ölçümlerini hiçbir zaman uydurmayacaktır.)*

Interpolation, resampling, and missing-value reconstruction are preprocessing operations and must be explicitly identified when used. *(Interpolasyon, yeniden örnekleme ve eksik değer yeniden oluşturma ön işleme işlemleridir ve kullanıldıklarında açıkça tanımlanmalıdır.)*

Raw logs must preserve the actual acquisition pattern. *(Ham kayıtlar gerçek veri toplama örüntüsünü korumalıdır.)*

---

# 60. Effective Sampling Rate Measurement (Etkin Örnekleme Hızı Ölçümü)

Effective sampling frequency will be calculated from consecutive measurement timestamps. *(Etkin örnekleme frekansı ardışık ölçüm zaman damgalarından hesaplanacaktır.)*

A basic interval will be calculated as follows. *(Temel bir aralık aşağıdaki şekilde hesaplanacaktır.)*

```
Δt_i = (timestamp_i - timestamp_(i-1)) / 1,000,000,000
```

An approximate instantaneous sampling frequency may then be calculated as follows. *(Yaklaşık anlık örnekleme frekansı daha sonra aşağıdaki şekilde hesaplanabilir.)*

```
f_i = 1 / Δt_i
```

---

# 61. Sampling Statistics (Örnekleme İstatistikleri)

NAVGUARD will calculate more than a single average sampling-rate value. *(NAVGUARD tek bir ortalama örnekleme hızı değerinden fazlasını hesaplayacaktır.)*

The audit should include sample count, mean interval, median interval, minimum interval, maximum interval, standard deviation, and selected percentiles. *(Denetim örnek sayısı, ortalama aralık, medyan aralık, minimum aralık, maksimum aralık, standart sapma ve seçilen yüzdelik değerlerini içermelidir.)*

Long timing gaps must be identifiable separately from ordinary jitter. *(Uzun zamanlama boşlukları normal jitter’dan ayrı olarak belirlenebilir olmalıdır.)*

---

# 62. Timing Gap Detection (Zamanlama Boşluğu Tespiti)

The acquisition diagnostics will detect intervals that are substantially longer than the expected sampling interval. *(Veri toplama tanısı beklenen örnekleme aralığından önemli ölçüde uzun aralıkları tespit edecektir.)*

A timing gap does not automatically mean a physical sensor failure. *(Bir zamanlama boşluğu otomatik olarak fiziksel sensör hatası anlamına gelmez.)*

It may result from Android scheduling, callback delays, resource contention, or other runtime effects. *(Android zamanlaması, callback gecikmeleri, kaynak rekabeti veya diğer çalışma zamanı etkilerinden kaynaklanabilir.)*

---

# 63. Timestamp Monotonicity Check (Zaman Damgası Monotoniklik Kontrolü)

Each sensor stream must be checked for non-monotonic timestamps. *(Her sensör akışı monotonik olmayan zaman damgaları açısından kontrol edilmelidir.)*

A non-monotonic event must generate a data-quality diagnostic because temporal ordering is fundamental to navigation processing. *(Monotonik olmayan bir olay zamansal sıralama navigasyon işlemesi için temel olduğundan veri kalite tanısı üretmelidir.)*

The raw record should normally be preserved for later investigation rather than silently removed. *(Ham kayıt sessizce çıkarılmak yerine normalde daha sonraki inceleme için korunmalıdır.)*

---

# 64. Duplicate Timestamp Check (Yinelenen Zaman Damgası Kontrolü)

Repeated timestamps within the same continuous sensor stream will be counted. *(Aynı sürekli sensör akışı içerisindeki tekrarlanan zaman damgaları sayılacaktır.)*

The system will determine during the Device Capability Audit whether duplicates occur in normal Redmi Note 9 Pro operation. *(Sistem yinelenen zaman damgalarının normal Redmi Note 9 Pro çalışmasında meydana gelip gelmediğini Cihaz Yetenek Denetimi sırasında belirleyecektir.)*

No arbitrary duplicate-removal rule will be introduced before the observed behavior is understood. *(Gözlemlenen davranış anlaşılmadan keyfi yinelenen kayıt kaldırma kuralı getirilmeyecektir.)*

---

# 65. Sensor Accuracy Events (Sensör Doğruluk Olayları)

The acquisition layer will preserve Android-provided sensor accuracy information when available. *(Veri toplama katmanı mevcut olduğunda Android tarafından sağlanan sensör doğruluk bilgisini koruyacaktır.)*

Accuracy changes may be recorded as dedicated diagnostic events instead of unnecessarily repeating static status in every high-frequency row. *(Doğruluk değişiklikleri statik durumu her yüksek frekanslı satırda gereksiz şekilde tekrar etmek yerine özel tanısal olaylar olarak kaydedilebilir.)*

Magnetometer accuracy changes may later contribute to heading-confidence analysis. *(Manyetometre doğruluk değişiklikleri daha sonra yön güven analizi için katkı sağlayabilir.)*

---

# 66. Stationary Baseline Acquisition (Sabit Durum Temel Veri Toplama)

NAVGUARD will support controlled stationary recordings for accelerometer, gyroscope, magnetometer, and orientation sources. *(NAVGUARD ivmeölçer, jiroskop, manyetometre ve yönelim kaynakları için kontrollü sabit durum kayıtlarını destekleyecektir.)*

These recordings will characterize sensor offsets, noise, stability, and sampling behavior. *(Bu kayıtlar sensör offset’lerini, gürültüyü, kararlılığı ve örnekleme davranışını karakterize edecektir.)*

Stationary audit recordings should occur before final preprocessing parameters are selected. *(Sabit durum denetim kayıtları nihai ön işleme parametreleri seçilmeden önce gerçekleştirilmelidir.)*

---

# 67. Motion Baseline Acquisition (Hareket Temel Veri Toplama)

NAVGUARD will support controlled motion recordings containing known movement segments. *(NAVGUARD bilinen hareket bölümleri içeren kontrollü hareket kayıtlarını destekleyecektir.)*

Initial sequences may include stationary, normal walking, running, turning, and stopping periods. *(İlk diziler sabit durma, normal yürüme, koşma, dönme ve durma sürelerini içerebilir.)*

These recordings will provide early evidence for step detection and motion-classification design. *(Bu kayıtlar adım tespiti ve hareket sınıflandırma tasarımı için ilk kanıtı sağlayacaktır.)*

---

# 68. Dataset Acquisition Mode (Veri Seti Toplama Modu)

NAVGUARD should provide a dedicated dataset-recording workflow. *(NAVGUARD özel bir veri seti kayıt iş akışı sağlamalıdır.)*

Dataset sessions may record raw sensors without requiring the full navigation estimator to be enabled. *(Veri seti oturumları tam navigasyon tahmin motorunun etkin olmasını gerektirmeden ham sensörleri kaydedebilir.)*

Each dataset session must still use the same authoritative sensor acquisition implementation as formal navigation. *(Her veri seti oturumu yine de resmî navigasyonla aynı ana sensör veri toplama uygulamasını kullanmalıdır.)*

---

# 69. Motion Label Acquisition (Hareket Etiketi Toplama)

Dataset sessions intended for motion classification will store the intended ground-truth activity label. *(Hareket sınıflandırması için amaçlanan veri seti oturumları hedef gerçek aktivite etiketini saklayacaktır.)*

The initial labels will include STATIONARY, WALKING, RUNNING, and TURNING. *(İlk etiketler STATIONARY, WALKING, RUNNING ve TURNING olacaktır.)*

Labels may be assigned at session level or as explicitly timestamped segment annotations depending on the collection protocol. *(Etiketler toplama protokolüne bağlı olarak oturum seviyesinde veya açık zaman damgalı segment anotasyonları şeklinde atanabilir.)*

---

# 70. Label Event Model (Etiket Olay Modeli)

```
MotionLabelEvent
- timestampNs
- label
- source
- annotationId
- notes
```

Manual labels must not be confused with AI predictions. *(Manuel etiketler yapay zekâ tahminleriyle karıştırılmamalıdır.)*

Ground-truth labels and model outputs will use separate data streams. *(Gerçek referans etiketleri ile model çıktıları ayrı veri akışları kullanacaktır.)*

---

# 71. Session Identity Requirement (Oturum Kimliği Gereksinimi)

Every acquisition session must have a unique session identifier. *(Her veri toplama oturumu benzersiz bir oturum tanımlayıcısına sahip olmalıdır.)*

Every raw file generated during that session must be attributable to the same session. *(Oturum sırasında oluşturulan her ham dosya aynı oturuma ilişkilendirilebilir olmalıdır.)*

Session identity must be established before formal evidence recording begins. *(Resmî kanıt kaydı başlamadan önce oturum kimliği oluşturulmalıdır.)*

---

# 72. Session Manifest (Oturum Manifest’i)

Every formal session will contain a structured manifest. *(Her resmî oturum yapılandırılmış bir manifest içerecektir.)*

The manifest will describe what was intended to be recorded and what was actually recorded. *(Manifest neyin kaydedilmesinin amaçlandığını ve gerçekte neyin kaydedildiğini açıklayacaktır.)*

```
sessionId
schemaVersion
applicationVersion
deviceBaselineId
sessionType
navigationProfile
startTime
endTime
enabledSources
requestedSamplingConfiguration
modelId
completionState
validityState
```

---

# 73. Raw Data File Policy (Ham Veri Dosyası Politikası)

High-frequency numerical sensor streams will initially use append-oriented structured files. *(Yüksek frekanslı sayısal sensör akışları başlangıçta append odaklı yapılandırılmış dosyalar kullanacaktır.)*

CSV is the planned initial scientific format because it can be inspected directly and loaded easily into Python. *(CSV doğrudan incelenebildiği ve Python’a kolayca yüklenebildiği için planlanan başlangıç bilimsel formatıdır.)*

The storage format may later be optimized only if performance measurements justify a change. *(Depolama formatı daha sonra yalnızca performans ölçümleri bir değişikliği gerekçelendirirse optimize edilebilir.)*

---

# 74. Proposed Raw IMU Schema (Önerilen Ham IMU Şeması)

```
timestamp_ns,
sequence,
acc_x,
acc_y,
acc_z,
gyro_x,
gyro_y,
gyro_z
```

A combined IMU file may be used only if streams are deliberately synchronized or represented without falsely implying simultaneous measurement times. *(Birleşik IMU dosyası yalnızca akışlar bilinçli olarak senkronize edilmişse veya eşzamanlı ölçüm zamanları yanlış şekilde ima edilmeden temsil ediliyorsa kullanılabilir.)*

Otherwise, separate accelerometer and gyroscope streams are safer for authoritative raw storage. *(Aksi halde ayrı ivmeölçer ve jiroskop akışları ana ham depolama için daha güvenlidir.)*

---

# 75. Preferred Authoritative Raw File Separation (Tercih Edilen Ana Ham Dosya Ayrımı)

The initial authoritative logging design should preserve independently timestamped sensor streams separately. *(İlk ana kayıt tasarımı bağımsız zaman damgalı sensör akışlarını ayrı olarak korumalıdır.)*

```
accelerometer.csv
gyroscope.csv
magnetometer.csv
rotation_vector.csv
gravity.csv
linear_acceleration.csv
gnss_ground_truth.csv
arcore_pose.csv
```

Synchronized multi-sensor tables will be generated later as processed datasets. *(Senkronize çoklu sensör tabloları daha sonra işlenmiş veri setleri olarak oluşturulacaktır.)*

---

# 76. Accelerometer CSV Schema (İvmeölçer CSV Şeması)

```
timestamp_ns,sequence,x_mps2,y_mps2,z_mps2,accuracy
```

Units will be encoded in column names or documented schema metadata. *(Birimler sütun adlarında kodlanacak veya şema metadata bilgisinde dokümante edilecektir.)*

Unit conventions must remain stable across sessions using the same schema version. *(Birim kuralları aynı şema sürümünü kullanan oturumlar arasında kararlı kalmalıdır.)*

---

# 77. Gyroscope CSV Schema (Jiroskop CSV Şeması)

```
timestamp_ns,sequence,x_radps,y_radps,z_radps,accuracy
```

The schema will represent original sensor measurements before NAVGUARD bias correction. *(Şema NAVGUARD bias düzeltmesinden önceki orijinal sensör ölçümlerini temsil edecektir.)*

Any corrected version must use a separate processed field or file. *(Düzeltilmiş herhangi bir sürüm ayrı bir işlenmiş alan veya dosya kullanmalıdır.)*

---

# 78. Magnetometer CSV Schema (Manyetometre CSV Şeması)

```
timestamp_ns,sequence,x_ut,y_ut,z_ut,accuracy
```

The `ut` suffix represents microtesla. *(`ut` son eki mikroteslayı temsil eder.)*

Magnetic disturbance flags will not overwrite the original field measurements. *(Manyetik bozulma flag’leri orijinal alan ölçümlerinin üzerine yazmayacaktır.)*

---

# 79. GNSS Ground Truth CSV Schema (GNSS Gerçek Referans CSV Şeması)

```
elapsed_realtime_ns,
wall_clock_ms,
sequence,
latitude,
longitude,
accuracy_m,
altitude_m,
speed_mps,
bearing_deg,
provider
```

Unavailable optional fields will use the documented missing-value convention. *(Kullanılamayan isteğe bağlı alanlar dokümante edilmiş eksik değer kuralını kullanacaktır.)*

---

# 80. ARCore Pose CSV Schema (ARCore Poz CSV Şeması)

```
frame_timestamp_ns,
native_reception_timestamp_ns,
sequence,
tx,
ty,
tz,
qx,
qy,
qz,
qw,
tracking_state
```

The ARCore coordinate frame must be documented with the file schema. *(ARCore koordinat sistemi dosya şemasıyla birlikte dokümante edilmelidir.)*

The file must not imply that translation values are already east-north geographic displacement. *(Dosya öteleme değerlerinin halihazırda doğu-kuzey coğrafi yer değiştirmesi olduğunu ima etmemelidir.)*

---

# 81. Schema Versioning (Şema Sürümleme)

Every exported NAVGUARD session will contain a schema-version identifier. *(Dışa aktarılan her NAVGUARD oturumu bir şema sürüm tanımlayıcısı içerecektir.)*

A breaking change to column meaning, units, timestamp basis, or required fields must increment the relevant schema version. *(Sütun anlamında, birimlerde, zaman damgası temelinde veya gerekli alanlarda geriye uyumsuz bir değişiklik ilgili şema sürümünü artırmalıdır.)*

Python parsers must reject or explicitly handle incompatible schema versions rather than silently misinterpret them. *(Python parser’ları uyumsuz şema sürümlerini sessizce yanlış yorumlamak yerine reddetmeli veya açıkça yönetmelidir.)*

---

# 82. Raw Versus Processed Directory Separation (Ham ve İşlenmiş Klasör Ayrımı)

A session export may distinguish raw evidence from derived data. *(Bir oturum dışa aktarımı ham kanıtı türetilmiş veriden ayırabilir.)*

```
session_<id>/
├── manifest.json
├── raw/
└── processed/
```

This organization prevents derived resampled or filtered data from being confused with device output. *(Bu organizasyon türetilmiş yeniden örneklenmiş veya filtrelenmiş verinin cihaz çıktısıyla karıştırılmasını önler.)*

---

# 83. Example Session Data Layout (Örnek Oturum Veri Düzeni)

```
session_<id>/
│
├── manifest.json
├── device.json
├── configuration.json
│
├── raw/
│   ├── accelerometer.csv
│   ├── gyroscope.csv
│   ├── magnetometer.csv
│   ├── rotation_vector.csv
│   ├── gnss_ground_truth.csv
│   └── arcore_pose.csv
│
├── processed/
│   ├── synchronized_imu.csv
│   ├── motion_ai.csv
│   ├── step_events.csv
│   ├── heading.csv
│   ├── pdr_state.csv
│   └── fusion_state.csv
│
└── diagnostics/
    ├── mode_events.csv
    ├── quality_events.csv
    └── runtime_events.csv
```

This structure is the preferred logical format and may be optimized after logging benchmarks. *(Bu yapı tercih edilen mantıksal formattır ve kayıt benchmark’larından sonra optimize edilebilir.)*

---

# 84. Raw Data Immutability Principle (Ham Veri Değişmezliği İlkesi)

Raw session files should be treated as immutable evidence after a completed formal session. *(Ham oturum dosyaları tamamlanmış resmî bir oturumdan sonra değiştirilemez kanıt olarak ele alınmalıdır.)*

Preprocessing scripts must generate new outputs instead of modifying the original recordings in place. *(Ön işleme script’leri orijinal kayıtları yerinde değiştirmek yerine yeni çıktılar oluşturmalıdır.)*

This principle improves experiment reproducibility. *(Bu ilke deney tekrarlanabilirliğini iyileştirir.)*

---

# 85. Data Integrity Counters (Veri Bütünlüğü Sayaçları)

Each formal session should maintain integrity counters for critical streams. *(Her resmî oturum kritik akışlar için bütünlük sayaçları tutmalıdır.)*

Useful counters may include received samples, persisted samples, detected timing gaps, duplicate timestamps, non-monotonic timestamps, queue-overflow events, and parser errors. *(Kullanışlı sayaçlar alınan örnekleri, kalıcı hale getirilen örnekleri, tespit edilen zamanlama boşluklarını, yinelenen zaman damgalarını, monotonik olmayan zaman damgalarını, kuyruk taşma olaylarını ve parser hatalarını içerebilir.)*

These counters will support automated session-validity assessment. *(Bu sayaçlar otomatik oturum geçerlilik değerlendirmesini destekleyecektir.)*

---

# 86. Acquisition Health Model (Veri Toplama Sağlık Modeli)

Each critical stream should expose a runtime health state. *(Her kritik akış bir çalışma zamanı sağlık durumu sunmalıdır.)*

```
STARTING
HEALTHY
WARNING
DEGRADED
LOST
ERROR
```

The navigation state machine may use these states when determining degradation or experiment invalidation. *(Navigasyon durum makinesi bozulma veya deney geçersiz kılma kararında bu durumları kullanabilir.)*

---

# 87. Sensor-Loss Detection (Sensör Kaybı Tespiti)

NAVGUARD should detect when a critical continuous sensor stops delivering measurements unexpectedly. *(NAVGUARD kritik bir sürekli sensör beklenmedik şekilde ölçüm teslim etmeyi durdurduğunda bunu tespit etmelidir.)*

Loss detection will use elapsed time since the last accepted sensor event rather than only listener-registration state. *(Kayıp tespiti yalnızca listener kayıt durumunu değil son kabul edilen sensör olayından itibaren geçen süreyi kullanacaktır.)*

The exact timeout threshold will depend on the frozen sensor rate and measured device behavior. *(Kesin timeout eşiği sabitlenmiş sensör hızına ve ölçülen cihaz davranışına bağlı olacaktır.)*

---

# 88. Sensor Restart Policy (Sensör Yeniden Başlatma Politikası)

A temporary acquisition failure may trigger a controlled listener restart if this behavior is demonstrated to be safe. *(Geçici bir veri toplama hatası bu davranışın güvenli olduğu gösterilirse kontrollü listener yeniden başlatmasını tetikleyebilir.)*

The restart event must be recorded. *(Yeniden başlatma olayı kaydedilmelidir.)*

A formal benchmark may be marked degraded or invalid depending on the affected source and duration. *(Resmî bir benchmark etkilenen kaynak ve süreye bağlı olarak bozulmuş veya geçersiz olarak işaretlenebilir.)*

---

# 89. Native-to-Dart Transfer Policy (Native-to-Dart Aktarım Politikası)

Not every raw measurement necessarily needs to reach Flutter widgets. *(Her ham ölçümün Flutter widget’larına ulaşması gerekmez.)*

The navigation domain may require selected streams to cross into Dart, while the UI receives only reduced-frequency snapshots. *(Navigasyon domain’i seçilen akışların Dart’a geçmesini gerektirebilirken UI yalnızca azaltılmış frekanslı anlık görüntüler alabilir.)*

The exact raw-transfer strategy will be finalized after the Redmi Note 9 Pro throughput benchmark. *(Kesin ham veri aktarım stratejisi Redmi Note 9 Pro throughput benchmark’ından sonra kesinleştirilecektir.)*

---

# 90. Transfer Strategy Candidates (Aktarım Stratejisi Adayları)

The first candidate is individual event transfer from Kotlin to Dart. *(İlk aday Kotlin’den Dart’a bireysel olay aktarımıdır.)*

The second candidate is short timestamp-preserving batches. *(İkinci aday zaman damgalarını koruyan kısa batch’lerdir.)*

The third candidate is limited native preprocessing followed by lower-volume processed transfer. *(Üçüncü aday sınırlı native ön işleme ve ardından daha düşük hacimli işlenmiş aktarımdır.)*

No candidate will be selected permanently before real-device measurements. *(Hiçbir aday gerçek cihaz ölçümlerinden önce kalıcı olarak seçilmeyecektir.)*

---

# 91. Batch Transfer Requirement (Batch Aktarım Gereksinimi)

If batching is used between Kotlin and Dart, every individual sensor measurement must retain its original timestamp. *(Kotlin ile Dart arasında batching kullanılırsa her bireysel sensör ölçümü orijinal zaman damgasını korumalıdır.)*

Batch delivery time must not be substituted for sample measurement time. *(Batch teslim zamanı örnek ölçüm zamanının yerine kullanılmamalıdır.)*

The batch structure should also preserve source order and sequence information. *(Batch yapısı ayrıca kaynak sırasını ve sıra bilgisini korumalıdır.)*

---

# 92. Diagnostic UI Data Rate (Tanısal UI Veri Hızı)

Live sensor-monitor widgets will use reduced-rate snapshots. *(Canlı sensör izleme widget’ları azaltılmış hızlı anlık görüntüler kullanacaktır.)*

For example, a 50 Hz accelerometer does not require 50 full Flutter widget rebuilds per second. *(Örneğin 50 Hz ivmeölçer saniyede 50 tam Flutter widget rebuild’i gerektirmez.)*

Presentation throttling must not change the authoritative acquisition or estimator rate. *(Sunum throttling işlemi ana veri toplama veya tahmin motoru hızını değiştirmemelidir.)*

---

# 93. Dataset Quality Gate (Veri Seti Kalite Kapısı)

Final AI dataset collection must not begin until the critical acquisition configuration has been validated. *(Nihai yapay zekâ veri seti toplama kritik veri toplama yapılandırması doğrulanmadan başlamamalıdır.)*

The minimum prerequisites include verified sensor identity, timestamp behavior, effective sampling frequency, stable recording, and documented device placement protocol. *(Minimum ön koşullar doğrulanmış sensör kimliğini, zaman damgası davranışını, etkin örnekleme frekansını, kararlı kaydı ve dokümante edilmiş cihaz yerleşim protokolünü içerir.)*

This prevents collecting a large dataset with an incorrect or unstable acquisition configuration. *(Bu yanlış veya kararsız bir veri toplama yapılandırmasıyla büyük bir veri seti toplanmasını önler.)*

---

# 94. Dataset Session Isolation (Veri Seti Oturum İzolasyonu)

Every data-collection run will be treated as an identifiable recording session. *(Her veri toplama çalışması tanımlanabilir bir kayıt oturumu olarak ele alınacaktır.)*

Windows derived from one session must retain their original session identity. *(Bir oturumdan türetilen pencereler orijinal oturum kimliklerini korumalıdır.)*

This identity will later enforce session-wise train, validation, and test separation. *(Bu kimlik daha sonra oturum bazlı eğitim, doğrulama ve test ayrımını uygulayacaktır.)*

---

# 95. Device Placement Metadata (Cihaz Yerleşim Metadata Bilgisi)

Dataset and field-test sessions should record the phone placement protocol used during the session. *(Veri seti ve saha testi oturumları oturum sırasında kullanılan telefon yerleşim protokolünü kaydetmelidir.)*

Examples may include handheld-forward, handheld-natural, or another frozen placement definition established by pilot tests. *(Örnekler elde öne dönük, elde doğal veya pilot testlerle oluşturulan başka bir sabitlenmiş yerleşim tanımını içerebilir.)*

Multiple device-placement modes must not be mixed without being labelled. *(Birden fazla cihaz yerleşim modu etiketlenmeden karıştırılmamalıdır.)*

---

# 96. Orientation Metadata (Yönelim Metadata Bilgisi)

The initial device orientation at the start of a formal experiment should be recorded or reproducibly initialized. *(Resmî bir deney başlangıcındaki ilk cihaz yönelimi kaydedilmeli veya tekrarlanabilir şekilde başlatılmalıdır.)*

This is particularly important for heading and ARCore alignment. *(Bu özellikle yön ve ARCore hizalaması için önemlidir.)*

The final initialization procedure will be defined in the coordinate and heading documents. *(Nihai başlatma prosedürü koordinat ve yön dokümanlarında tanımlanacaktır.)*

---

# 97. User-Generated Markers (Kullanıcı Tarafından Oluşturulan İşaretleyiciler)

The research interface may allow the user to create timestamped experiment markers during a recording. *(Araştırma arayüzü kullanıcının kayıt sırasında zaman damgalı deney işaretleyicileri oluşturmasına izin verebilir.)*

Markers may identify events such as START_WALKING, STOP, TURN_START, TURN_END, or route checkpoints. *(İşaretleyiciler START_WALKING, STOP, TURN_START, TURN_END veya rota kontrol noktaları gibi olayları belirtebilir.)*

These markers will be stored separately from physical sensor measurements. *(Bu işaretleyiciler fiziksel sensör ölçümlerinden ayrı olarak saklanacaktır.)*

---

# 98. Experiment Marker Model (Deney İşaretleyici Modeli)

```
ExperimentMarker
- timestampNs
- markerType
- markerId
- notes
```

Markers can improve later annotation and synchronization without modifying raw measurements. *(İşaretleyiciler ham ölçümleri değiştirmeden sonraki anotasyon ve senkronizasyonu iyileştirebilir.)*

---

# 99. Data Acquisition During GNSS-Denied Navigation (GNSS Kesintili Navigasyon Sırasında Veri Toplama)

Physical sensor acquisition will continue normally after estimator GNSS access is blocked. *(Tahmin motoru GNSS erişimi engellendikten sonra fiziksel sensör veri toplama normal şekilde devam edecektir.)*

The accelerometer, gyroscope, magnetometer, selected orientation sources, and ARCore will remain available according to the active profile. *(İvmeölçer, jiroskop, manyetometre, seçilen yönelim kaynakları ve ARCore aktif profile göre kullanılabilir kalacaktır.)*

GNSS may remain active exclusively for ground-truth logging. *(GNSS yalnızca gerçek referans kaydı için aktif kalabilir.)*

---

# 100. No Acquisition Reconfiguration at Denial Boundary (Kesinti Sınırında Veri Toplama Yeniden Yapılandırması Olmaması)

The GNSS-denied transition should not unnecessarily restart the IMU sensors. *(GNSS kesintili geçiş IMU sensörlerini gereksiz yere yeniden başlatmamalıdır.)*

Maintaining continuous IMU streams across the denial boundary simplifies temporal analysis and prevents artificial discontinuities. *(Kesinti sınırı boyunca sürekli IMU akışlarını korumak zamansal analizi basitleştirir ve yapay süreksizlikleri önler.)*

The mode transition will instead be represented through a timestamped navigation-mode event. *(Bunun yerine mod geçişi zaman damgalı bir navigasyon modu olayı üzerinden temsil edilecektir.)*

---

# 101. Pre-Denial Data Retention (Kesinti Öncesi Veri Saklama)

Formal evaluation sessions should retain a short pre-denial sensor interval. *(Resmî değerlendirme oturumları kısa bir kesinti öncesi sensör aralığını korumalıdır.)*

This data provides context for initial heading, movement state, filter state, and estimator initialization. *(Bu veri ilk yön, hareket durumu, filtre durumu ve tahmin motoru başlatması için bağlam sağlar.)*

The exact required pre-denial duration will be defined with the experiment protocol. *(Gerekli kesin kesinti öncesi süre deney protokolüyle tanımlanacaktır.)*

---

# 102. Post-Recovery Data Retention (Geri Kazanım Sonrası Veri Saklama)

Formal evaluation sessions should retain a short post-recovery interval. *(Resmî değerlendirme oturumları kısa bir geri kazanım sonrası aralığı korumalıdır.)*

This supports analysis of relocalization behavior and estimator stabilization. *(Bu yeniden konumlandırma davranışı ve tahmin motoru kararlılığı analizini destekler.)*

Post-recovery measurements must remain distinguishable from the primary GNSS-denied evaluation window. *(Geri kazanım sonrası ölçümler temel GNSS kesintili değerlendirme penceresinden ayırt edilebilir kalmalıdır.)*

---

# 103. Data Acquisition Performance Counters (Veri Toplama Performans Sayaçları)

The acquisition subsystem should expose runtime counters for development diagnostics. *(Veri toplama alt sistemi geliştirme tanısı için çalışma zamanı sayaçları sunmalıdır.)*

Potential counters include current sampling rate, total samples, callback latency, queue depth, persisted rows, timing gaps, and dropped-record indicators. *(Potansiyel sayaçlar mevcut örnekleme hızı, toplam örnek sayısı, callback gecikmesi, kuyruk derinliği, kalıcı hale getirilen satırlar, zamanlama boşlukları ve düşen kayıt göstergelerini içerir.)*

Counters should be reset or namespaced per session. *(Sayaçlar oturum başına sıfırlanmalı veya ayrı namespace altında tutulmalıdır.)*

---

# 104. Acquisition Diagnostic Snapshot (Veri Toplama Tanısal Anlık Görüntüsü)

```
AcquisitionDiagnostics
- accelerometerHz
- gyroscopeHz
- magnetometerHz
- sensorQueueDepth
- loggerQueueDepth
- sensorGapCount
- nonMonotonicTimestampCount
- persistedSampleCount
- acquisitionState
```

This structure is diagnostic and may evolve during development. *(Bu yapı tanısaldır ve geliştirme sırasında değişebilir.)*

---

# 105. Data Quality Severity (Veri Kalite Ciddiyeti)

Acquisition issues will be categorized by severity. *(Veri toplama sorunları ciddiyete göre sınıflandırılacaktır.)*

A small sampling-rate variation may produce an informational diagnostic. *(Küçük bir örnekleme hızı değişimi bilgilendirici bir tanı üretebilir.)*

A persistent timing gap may produce a warning or degraded state. *(Kalıcı bir zamanlama boşluğu uyarı veya bozulmuş durum üretebilir.)*

Loss of a mandatory sensor may invalidate the active benchmark. *(Zorunlu bir sensörün kaybı aktif benchmark’ı geçersiz kılabilir.)*

---

# 106. Acquisition Error Categories (Veri Toplama Hata Kategorileri)

```
SENSOR_UNAVAILABLE
SENSOR_REGISTRATION_FAILED
SENSOR_STREAM_LOST
NON_MONOTONIC_TIMESTAMP
EXCESSIVE_TIMING_GAP
BUFFER_OVERFLOW
LOGGER_BACKPRESSURE
FILE_WRITE_FAILURE
GNSS_UNAVAILABLE
ARCORE_TRACKING_LOST
```

Error codes will allow later experiment analysis to identify why a session degraded or failed. *(Hata kodları daha sonraki deney analizinin bir oturumun neden bozulduğunu veya başarısız olduğunu belirlemesine olanak sağlayacaktır.)*

---

# 107. Data Acquisition and Replay Compatibility (Veri Toplama ve Replay Uyumluluğu)

The authoritative log format must contain enough information to reconstruct the original event order and timing. *(Ana kayıt formatı orijinal olay sırasını ve zamanlamasını yeniden oluşturmak için yeterli bilgi içermelidir.)*

Replay tools will read recorded files and generate domain events compatible with the live navigation pipeline. *(Replay araçları kaydedilmiş dosyaları okuyacak ve canlı navigasyon hattıyla uyumlu domain olayları üretecektir.)*

Replay must not require the physical Android SensorManager. *(Replay fiziksel Android SensorManager’a ihtiyaç duymamalıdır.)*

---

# 108. Deterministic Replay Requirement (Deterministik Replay Gereksinimi)

The same raw session and the same frozen processing configuration should produce reproducible algorithm inputs. *(Aynı ham oturum ve aynı sabitlenmiş işleme yapılandırması tekrarlanabilir algoritma girdileri üretmelidir.)*

Randomized processing components must use controlled seeds where applicable. *(Rastgeleleştirilmiş işleme bileşenleri uygulanabilir olduğunda kontrollü seed değerleri kullanmalıdır.)*

Changes to preprocessing must create a new processing configuration or version. *(Ön işleme değişiklikleri yeni bir işleme yapılandırması veya sürümü oluşturmalıdır.)*

---

# 109. Acquisition and AI Compatibility (Veri Toplama ve Yapay Zekâ Uyumluluğu)

The mobile acquisition schema must preserve every input channel required by the frozen motion model. *(Mobil veri toplama şeması sabitlenmiş hareket modeli tarafından gerekli her girdi kanalını korumalıdır.)*

The training pipeline must not use sensor information that the deployed mobile runtime cannot reproduce. *(Eğitim hattı dağıtılan mobil çalışma zamanının yeniden üretemeyeceği sensör bilgisini kullanmamalıdır.)*

Training-time and inference-time sensor definitions must remain equivalent. *(Eğitim zamanı ve çıkarım zamanı sensör tanımları eşdeğer kalmalıdır.)*

---

# 110. Sampling-Rate Compatibility With AI (Yapay Zekâ ile Örnekleme Hızı Uyumluluğu)

The AI pipeline will use a documented effective sampling configuration. *(Yapay zekâ hattı dokümante edilmiş etkin bir örnekleme yapılandırması kullanacaktır.)*

If raw acquisition is irregular, preprocessing may resample the data onto the model’s required timeline. *(Ham veri toplama düzensizse ön işleme veriyi modelin gerekli zaman çizelgesine yeniden örnekleyebilir.)*

The resampling method must be identical or mathematically equivalent between training and deployed inference. *(Yeniden örnekleme yöntemi eğitim ile dağıtılan çıkarım arasında aynı veya matematiksel olarak eşdeğer olmalıdır.)*

---

# 111. Raw Data Retention for ML (ML İçin Ham Veri Saklama)

The original irregularly sampled measurements will be retained even when a synchronized AI dataset is generated. *(Senkronize bir yapay zekâ veri seti oluşturulsa bile orijinal düzensiz örneklenmiş ölçümler korunacaktır.)*

This allows preprocessing strategies to be changed without recollecting the physical dataset. *(Bu fiziksel veri setini yeniden toplamadan ön işleme stratejilerinin değiştirilmesine olanak sağlar.)*

This is especially important before the final model architecture is frozen. *(Bu özellikle nihai model mimarisi sabitlenmeden önce önemlidir.)*

---

# 112. Acquisition and PDR Compatibility (Veri Toplama ve PDR Uyumluluğu)

The PDR pipeline will consume processed sensor signals derived from the authoritative acquisition streams. *(PDR hattı ana veri toplama akışlarından türetilen işlenmiş sensör sinyallerini kullanacaktır.)*

The step detector must have access to sufficient acceleration history for filtering and peak analysis. *(Adım algılayıcı filtreleme ve peak analizi için yeterli ivme geçmişine erişebilmelidir.)*

Heading estimation must have access to appropriately timestamped orientation-related measurements. *(Yön tahmini uygun şekilde zaman damgalanmış yönelimle ilişkili ölçümlere erişebilmelidir.)*

---

# 113. Acquisition and EKF Compatibility (Veri Toplama ve EKF Uyumluluğu)

The fusion system will receive timestamped derived measurements rather than unstructured callback values. *(Füzyon sistemi yapılandırılmamış callback değerleri yerine zaman damgalı türetilmiş ölçümler alacaktır.)*

Every fusion measurement must preserve traceability back to its source stream. *(Her füzyon ölçümü kaynak akışına kadar izlenebilirliği korumalıdır.)*

The estimator must be able to reason about measurement age when asynchronous sources arrive at different frequencies. *(Tahmin motoru asenkron kaynaklar farklı frekanslarda geldiğinde ölçüm yaşı hakkında işlem yapabilmelidir.)*

---

# 114. No Direct Double Integration of Raw Accelerometer (Ham İvmenin Doğrudan Çift İntegrasyonu Olmaması)

The acquisition system will make raw acceleration available, but the baseline NAVGUARD position estimator will not simply double-integrate raw accelerometer measurements to produce position. *(Veri toplama sistemi ham ivmeyi kullanılabilir hale getirecek ancak temel NAVGUARD konum tahmin motoru konum üretmek için ham ivmeölçer ölçümlerini basitçe çift integre etmeyecektir.)*

Consumer smartphone acceleration contains gravity, bias, noise, orientation effects, and timing variation that can create rapidly increasing drift. *(Tüketici sınıfı akıllı telefon ivmesi yerçekimi, bias, gürültü, yönelim etkileri ve hızla büyüyen sürüklenme oluşturabilecek zamanlama değişkenliği içerir.)*

Baseline displacement will therefore rely primarily on the PDR structure defined elsewhere in the project. *(Bu nedenle temel yer değiştirme öncelikle projede başka yerde tanımlanan PDR yapısına dayanacaktır.)*

---

# 115. Session Start Acquisition Sequence (Oturum Başlangıcı Veri Toplama Sırası)

```
Create Session Identity
        ↓
Freeze Acquisition Configuration
        ↓
Create Session Storage
        ↓
Register Required Sensor Listeners
        ↓
Verify Event Delivery
        ↓
Start GNSS Reference Stream
        ↓
Start Optional ARCore Stream
        ↓
Start Logging
        ↓
Record Session Start Event
```

The exact ordering may be adjusted so that no required startup evidence is missed. *(Kesin sıra gerekli başlangıç kanıtlarının kaçırılmaması için ayarlanabilir.)*

---

# 116. Session Stop Acquisition Sequence (Oturum Sonu Veri Toplama Sırası)

```
Stop Accepting New Navigation Updates
        ↓
Record Stop Event
        ↓
Stop Optional ARCore Acquisition
        ↓
Unregister Sensor Listeners
        ↓
Stop GNSS Subscription
        ↓
Flush Logging Queues
        ↓
Close Files
        ↓
Write Integrity Summary
        ↓
Finalize Session Manifest
```

The logger must not be closed before pending critical records are flushed where controlled shutdown is possible. *(Kontrollü kapanış mümkün olduğunda bekleyen kritik kayıtlar diske yazılmadan logger kapatılmamalıdır.)*

---

# 117. Crash and Interrupted Recording Policy (Çökme ve Kesilmiş Kayıt Politikası)

A sudden application failure may prevent normal stream finalization. *(Ani bir uygulama hatası normal akış sonlandırmasını engelleyebilir.)*

Already flushed append-oriented data should remain readable where practical. *(Daha önce diske yazılmış append odaklı veri uygulanabilir olduğu ölçüde okunabilir kalmalıdır.)*

An interrupted session will be identified through the absence of a valid completion marker. *(Kesilmiş bir oturum geçerli bir tamamlanma işaretinin bulunmaması üzerinden belirlenecektir.)*

---

# 118. Storage Space Readiness (Depolama Alanı Hazırlığı)

NAVGUARD should check available storage before beginning long formal recording sessions. *(NAVGUARD uzun resmî kayıt oturumlarına başlamadan önce kullanılabilir depolama alanını kontrol etmelidir.)*

The minimum required free-space threshold will be determined after measuring real session file sizes. *(Minimum gerekli boş alan eşiği gerçek oturum dosya boyutları ölçüldükten sonra belirlenecektir.)*

No arbitrary large storage reservation will be fixed before these measurements exist. *(Bu ölçümler mevcut olmadan keyfi büyük bir depolama rezervi sabitlenmeyecektir.)*

---

# 119. Five-Minute Acquisition Benchmark (Beş Dakikalık Veri Toplama Benchmark’ı)

The initial integrated acquisition benchmark will record all mandatory inertial streams continuously for at least five minutes. *(İlk entegre veri toplama benchmark’ı tüm zorunlu ataletsel akışları en az beş dakika sürekli kaydedecektir.)*

GNSS should be recorded simultaneously during an outdoor version of the test. *(Testin dış mekân sürümü sırasında GNSS eşzamanlı olarak kaydedilmelidir.)*

The benchmark will evaluate effective sampling rate, queue stability, write throughput, memory behavior, and data integrity. *(Benchmark etkin örnekleme hızını, kuyruk kararlılığını, yazma throughput’unu, bellek davranışını ve veri bütünlüğünü değerlendirecektir.)*

---

# 120. Extended Acquisition Benchmark (Uzatılmış Veri Toplama Benchmark’ı)

A longer recording should later be performed to reveal issues not visible during a five-minute test. *(Beş dakikalık test sırasında görünmeyen sorunları ortaya çıkarmak için daha sonra daha uzun bir kayıt gerçekleştirilmelidir.)*

The extended test may include ARCore and AI workload after their independent components are validated. *(Uzatılmış test bağımsız bileşenleri doğrulandıktan sonra ARCore ve yapay zekâ iş yükünü içerebilir.)*

The final duration will be defined in the performance-testing plan. *(Nihai süre performans test planında tanımlanacaktır.)*

---

# 121. Acquisition Acceptance Criteria (Veri Toplama Kabul Kriterleri)

The accelerometer, gyroscope, and magnetometer must provide continuous timestamped streams suitable for the selected baseline configuration. *(İvmeölçer, jiroskop ve manyetometre seçilen temel yapılandırma için uygun sürekli zaman damgalı akışlar sağlamalıdır.)*

Effective sampling behavior must be measured and documented. *(Etkin örnekleme davranışı ölçülmeli ve dokümante edilmelidir.)*

Raw sensor measurements must be persisted without losing their authoritative timestamps. *(Ham sensör ölçümleri ana zaman damgalarını kaybetmeden kalıcı hale getirilmelidir.)*

GNSS reference measurements must remain independently loggable while estimator GNSS access is blocked. *(GNSS referans ölçümleri tahmin motoru GNSS erişimi engelliyken bağımsız olarak kaydedilebilir kalmalıdır.)*

ARCore measurements must retain their own timestamp basis until a validated synchronization method is applied. *(ARCore ölçümleri doğrulanmış bir senkronizasyon yöntemi uygulanana kadar kendi zaman damgası temelini korumalıdır.)*

---

# 122. Data Integrity Acceptance Criteria (Veri Bütünlüğü Kabul Kriterleri)

Every formal stream must be attributable to a unique session. *(Her resmî akış benzersiz bir oturuma ilişkilendirilebilir olmalıdır.)*

Every numerical measurement must have a documented unit. *(Her sayısal ölçümün dokümante edilmiş birimi olmalıdır.)*

Every time-dependent record must have a documented timestamp basis. *(Zamana bağlı her kaydın dokümante edilmiş bir zaman damgası temeli olmalıdır.)*

Missing optional measurements must remain distinguishable from legitimate zero values. *(Eksik isteğe bağlı ölçümler geçerli sıfır değerlerinden ayırt edilebilir kalmalıdır.)*

Raw and processed data must remain distinguishable. *(Ham ve işlenmiş veri ayırt edilebilir kalmalıdır.)*

---

# 123. Acquisition Reproducibility Requirements (Veri Toplama Tekrarlanabilirlik Gereksinimleri)

Every formal session must record its requested sampling configuration. *(Her resmî oturum talep edilen örnekleme yapılandırmasını kaydetmelidir.)*

Every formal session must be traceable to the physical device baseline. *(Her resmî oturum fiziksel cihaz temel referansına kadar izlenebilir olmalıdır.)*

Every formal session must record the application build and relevant schema version. *(Her resmî oturum uygulama build’ini ve ilgili şema sürümünü kaydetmelidir.)*

The final dataset must be reproducible from immutable raw recordings and versioned preprocessing. *(Nihai veri seti değiştirilemez ham kayıtlardan ve sürümlenmiş ön işlemeden yeniden üretilebilir olmalıdır.)*

---

# 124. Acquisition Non-Goals (Veri Toplama Olmayan Hedefler)

The acquisition layer will not classify motion. *(Veri toplama katmanı hareket sınıflandırmayacaktır.)*

The acquisition layer will not estimate pedestrian position. *(Veri toplama katmanı yaya konumunu tahmin etmeyecektir.)*

The acquisition layer will not determine whether a magnetic measurement should be trusted by the EKF. *(Veri toplama katmanı bir manyetik ölçüme EKF tarafından güvenilip güvenilmeyeceğine karar vermeyecektir.)*

The acquisition layer will provide accurate evidence and quality diagnostics to the higher-level systems that make those decisions. *(Veri toplama katmanı bu kararları veren daha yüksek seviyeli sistemlere doğru kanıt ve kalite tanısı sağlayacaktır.)*

---

# 125. Measurement Freeze Decisions (Ölçüm Sonrası Sabitlenecek Kararlar)

The final accelerometer sampling target will be frozen after Device Capability Audit measurements. *(Nihai ivmeölçer örnekleme hedefi Cihaz Yetenek Denetimi ölçümlerinden sonra sabitlenecektir.)*

The final gyroscope sampling target will be frozen after Device Capability Audit measurements. *(Nihai jiroskop örnekleme hedefi Cihaz Yetenek Denetimi ölçümlerinden sonra sabitlenecektir.)*

The final magnetometer sampling target will be frozen after Device Capability Audit measurements. *(Nihai manyetometre örnekleme hedefi Cihaz Yetenek Denetimi ölçümlerinden sonra sabitlenecektir.)*

The Kotlin-to-Dart transfer strategy will be frozen after throughput measurements. *(Kotlin-to-Dart aktarım stratejisi throughput ölçümlerinden sonra sabitlenecektir.)*

The final buffering capacity will be frozen after workload measurements. *(Nihai tampon kapasitesi iş yükü ölçümlerinden sonra sabitlenecektir.)*

---

# 126. Initial Frozen Acquisition Decisions (Başlangıçta Sabitlenen Veri Toplama Kararları)

The authoritative physical sensor interface will be native Android SensorManager. *(Ana fiziksel sensör arayüzü native Android SensorManager olacaktır.)*

The authoritative sensor measurement timestamp will be `SensorEvent.timestamp`. *(Ana sensör ölçüm zaman damgası `SensorEvent.timestamp` olacaktır.)*

GNSS alignment will prefer `Location.getElapsedRealtimeNanos()`. *(GNSS hizalaması `Location.getElapsedRealtimeNanos()` değerini tercih edecektir.)*

Raw Android sensor values will be preserved before preprocessing. *(Ham Android sensör değerleri ön işlemeden önce korunacaktır.)*

GNSS ground truth and estimator GNSS input will remain logically separated. *(GNSS gerçek referansı ile tahmin motoru GNSS girdisi mantıksal olarak ayrı kalacaktır.)*

Raw and processed experiment data will remain distinguishable. *(Ham ve işlenmiş deney verileri ayırt edilebilir kalacaktır.)*

---

# 127. Source Basis (Kaynak Temeli)

The Android sensor timestamp policy in this document is based on the official Android `SensorEvent` documentation. *(Bu dokümandaki Android sensör zaman damgası politikası resmî Android `SensorEvent` dokümantasyonuna dayanmaktadır.)*

The sampling and reporting-latency behavior is based on the official Android `SensorManager` documentation. *(Örnekleme ve raporlama gecikmesi davranışı resmî Android `SensorManager` dokümantasyonuna dayanmaktadır.)*

The GNSS monotonic timestamp policy is based on the official Android `Location` documentation. *(GNSS monotonik zaman damgası politikası resmî Android `Location` dokümantasyonuna dayanmaktadır.)*

The ARCore timestamp and tracking constraints are based on the official ARCore `Frame` documentation. *(ARCore zaman damgası ve takip kısıtları resmî ARCore `Frame` dokümantasyonuna dayanmaktadır.)*

---

# 128. Final Acquisition Architecture Statement (Nihai Veri Toplama Mimarisi Bildirimi)

**NAVGUARD will acquire Android inertial and magnetic measurements through a native Kotlin SensorManager layer while preserving each sensor’s authoritative event timestamp, source identity, units, sequence information, and raw values before preprocessing.** *(NAVGUARD Android ataletsel ve manyetik ölçümlerini native Kotlin SensorManager katmanı üzerinden toplarken her sensörün ana olay zaman damgasını, kaynak kimliğini, birimlerini, sıra bilgisini ve ön işleme öncesi ham değerlerini koruyacaktır.)*

**GNSS data will use a separate native acquisition path with monotonic elapsed-realtime timing, allowing GNSS reference measurements to be synchronized with IMU data while remaining isolated from the estimator during GNSS-denied evaluation.** *(GNSS verisi monotonik elapsed-realtime zamanlamasına sahip ayrı bir native veri toplama hattı kullanacak; böylece GNSS referans ölçümleri IMU verisiyle senkronize edilebilirken GNSS kesintili değerlendirme sırasında tahmin motorundan izole kalacaktır.)*

**ARCore pose data will retain its original ARCore frame timestamp and will not be fused with the Android sensor timeline until a validated synchronization strategy has been applied.** *(ARCore poz verisi orijinal ARCore kare zaman damgasını koruyacak ve doğrulanmış bir senkronizasyon stratejisi uygulanana kadar Android sensör zaman çizelgesiyle füzyonlanmayacaktır.)*

**The acquisition system will preserve immutable raw evidence, generate separately versioned processed data, monitor data integrity and queue health, and support deterministic replay of recorded sessions.** *(Veri toplama sistemi değiştirilemez ham kanıtı koruyacak, ayrı sürümlenmiş işlenmiş veri üretecek, veri bütünlüğü ve kuyruk sağlığını izleyecek ve kaydedilmiş oturumların deterministik replay işlemini destekleyecektir.)*

---

# 129. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development Acquisition Architecture Completed *(Doküman Durumu: Geliştirme Öncesi Veri Toplama Mimarisi Tamamlandı)*

**Physical Sensor Interface:** Native Android SensorManager *(Fiziksel Sensör Arayüzü: Native Android SensorManager)*

**Primary IMU Sensors:** Accelerometer + Gyroscope *(Temel IMU Sensörleri: İvmeölçer + Jiroskop)*

**Primary Heading Sensor:** Magnetometer with Orientation Support *(Temel Yön Sensörü: Yönelim Desteğiyle Manyetometre)*

**Target Orientation Source:** Rotation Vector *(Hedef Yönelim Kaynağı: Rotation Vector)*

**Initial Accelerometer Target:** Approximately 50 Hz — Provisional *(Başlangıç İvmeölçer Hedefi: Yaklaşık 50 Hz — Geçici)*

**Initial Gyroscope Target:** Approximately 50 Hz — Provisional *(Başlangıç Jiroskop Hedefi: Yaklaşık 50 Hz — Geçici)*

**Initial Magnetometer Target:** Approximately 20–50 Hz — Provisional *(Başlangıç Manyetometre Hedefi: Yaklaşık 20–50 Hz — Geçici)*

**Initial Sensor Report Latency:** 0 µs Preferred for Real-Time Tests *(Başlangıç Sensör Raporlama Gecikmesi: Gerçek Zamanlı Testler İçin 0 µs Tercih Ediliyor)*

**Authoritative IMU Timestamp:** SensorEvent.timestamp *(Ana IMU Zaman Damgası: SensorEvent.timestamp)*

**Authoritative GNSS Monotonic Timestamp:** Location.getElapsedRealtimeNanos() *(Ana GNSS Monotonik Zaman Damgası: Location.getElapsedRealtimeNanos())*

**ARCore Timestamp:** Separate Time Basis Until Synchronization Validation *(ARCore Zaman Damgası: Senkronizasyon Doğrulamasına Kadar Ayrı Zaman Temeli)*

**Raw Data Policy:** Preserve Before Filtering, Resampling, or Coordinate Transformation *(Ham Veri Politikası: Filtreleme, Yeniden Örnekleme veya Koordinat Dönüşümünden Önce Koru)*

**Final Sampling Configuration:** Pending Device Capability Audit *(Nihai Örnekleme Yapılandırması: Cihaz Yetenek Denetimi Bekleniyor)*

**Kotlin-to-Dart Transfer Strategy:** Pending Physical Device Throughput Benchmark *(Kotlin-to-Dart Aktarım Stratejisi: Fiziksel Cihaz Throughput Benchmark’ı Bekleniyor)*

**Next Documentation Item:** 13 — Sensor Timing, Synchronization & Preprocessing *(Sonraki Dokümantasyon Öğesi: 13 — Sensör Zamanlaması, Senkronizasyonu ve Ön İşleme)*