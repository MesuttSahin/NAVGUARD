# 19 — ARCore Visual-Inertial Tracking (ARCore Görsel-Ataletsel Takip)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the ARCore visual-inertial tracking architecture, runtime lifecycle, pose acquisition, tracking-state handling, local reference strategy, coordinate alignment, relative-displacement extraction, timestamp treatment, tracking-loss behavior, reinitialization, confidence handling, PDR fallback, logging, performance testing, experimental evaluation, and acceptance criteria of NAVGUARD. *(Bu doküman, NAVGUARD’ın ARCore görsel-ataletsel takip mimarisini, çalışma zamanı yaşam döngüsünü, poz elde etmeyi, takip durumu yönetimini, yerel referans stratejisini, koordinat hizalamasını, göreli yer değiştirme çıkarmayı, zaman damgası yönetimini, takip kaybı davranışını, yeniden başlatmayı, güven yönetimini, PDR geri dönüşünü, kaydı, performans testini, deneysel değerlendirmeyi ve kabul kriterlerini tanımlar.)*

ARCore will provide an optional visual-inertial relative-motion source for reducing drift during GNSS-denied navigation. *(ARCore, GNSS kesintili navigasyon sırasında sürüklenmeyi azaltmak için isteğe bağlı görsel-ataletsel göreli hareket kaynağı sağlayacaktır.)*

ARCore will enhance rather than replace the baseline PDR architecture. *(ARCore temel PDR mimarisinin yerini almak yerine onu geliştirecektir.)*

---

# 2. ARCore Role in NAVGUARD (NAVGUARD İçerisinde ARCore Rolü)

The primary ARCore role is to estimate the relative movement and orientation of the smartphone through the local physical environment. *(ARCore’un temel rolü akıllı telefonun yerel fiziksel ortam içerisindeki göreli hareketini ve yönelimini tahmin etmektir.)*

ARCore will not be treated as a direct absolute latitude-longitude provider. *(ARCore doğrudan mutlak enlem-boylam sağlayıcısı olarak ele alınmayacaktır.)*

The resulting local motion information will be aligned with the NAVGUARD ENU navigation frame before entering the fusion system. *(Ortaya çıkan yerel hareket bilgisi füzyon sistemine girmeden önce NAVGUARD ENU navigasyon çerçevesiyle hizalanacaktır.)*

---

# 3. Visual-Inertial Principle (Görsel-Ataletsel İlke)

ARCore motion tracking combines camera observations with motion-sensor information to estimate how the device moves through the environment. *(ARCore hareket takibi, cihazın ortam içerisinde nasıl hareket ettiğini tahmin etmek için kamera gözlemlerini hareket sensörü bilgisiyle birleştirir.)*

Google’s ARCore device-certification documentation explicitly describes sensitive motion tracking as combining camera images and motion-sensor input. *(Google’ın ARCore cihaz sertifikasyon dokümantasyonu hassas hareket takibini açıkça kamera görüntüleri ile hareket sensörü girdisinin birleşimi olarak tanımlar.)*

NAVGUARD will therefore use ARCore as an available platform visual-inertial odometry source rather than attempting to implement a complete visual-inertial odometry system from scratch within the project schedule. *(Bu nedenle NAVGUARD proje takvimi içerisinde sıfırdan tam bir görsel-ataletsel odometri sistemi geliştirmeye çalışmak yerine ARCore’u mevcut bir platform görsel-ataletsel odometri kaynağı olarak kullanacaktır.)*

---

# 4. Device Support Baseline (Cihaz Destek Temeli)

The current official ARCore supported-device list includes the Xiaomi Redmi Note 9 Pro. *(Güncel resmî ARCore desteklenen cihaz listesi Xiaomi Redmi Note 9 Pro’yu içermektedir.)*

Runtime support will nevertheless be verified on the physical test device before NAVGUARD depends on ARCore output. *(Bununla birlikte NAVGUARD ARCore çıktısına bağımlı olmadan önce çalışma zamanı desteği fiziksel test cihazında doğrulanacaktır.)*

Published compatibility does not replace the Device Capability Audit. *(Yayınlanmış uyumluluk Cihaz Yetenek Denetiminin yerini almaz.)*

---

# 5. ARCore Is an Optional Capability (ARCore İsteğe Bağlı Bir Yetenektir)

NAVGUARD must remain functional when ARCore is unavailable. *(NAVGUARD ARCore kullanılamadığında çalışabilir kalmalıdır.)*

The application architecture will therefore treat ARCore as an optional enhancement rather than a mandatory prerequisite for basic navigation. *(Bu nedenle uygulama mimarisi ARCore’u temel navigasyon için zorunlu bir ön koşul yerine isteğe bağlı bir iyileştirme olarak ele alacaktır.)*

---

# 6. AR Optional Application Strategy (AR Optional Uygulama Stratejisi)

The planned Android integration will use the AR Optional application model unless later implementation constraints provide a stronger reason to change it. *(Planlanan Android entegrasyonu daha sonra uygulama kısıtları değiştirmek için daha güçlü bir neden sağlamadığı sürece AR Optional uygulama modelini kullanacaktır.)*

Google defines an AR Optional application as one that can run without ARCore while enabling AR features on supported devices. *(Google AR Optional uygulamasını ARCore olmadan çalışabilen ancak desteklenen cihazlarda AR özelliklerini etkinleştiren uygulama olarak tanımlar.)*

This behavior directly matches NAVGUARD’s PDR-first fallback architecture. *(Bu davranış NAVGUARD’ın PDR öncelikli geri dönüş mimarisiyle doğrudan eşleşir.)*

---

# 7. ARCore Availability Check (ARCore Kullanılabilirlik Kontrolü)

NAVGUARD will perform a runtime ARCore availability check before enabling the ARCore tracking subsystem. *(NAVGUARD ARCore takip alt sistemini etkinleştirmeden önce çalışma zamanı ARCore kullanılabilirlik kontrolü gerçekleştirecektir.)*

Google recommends `ArCoreApk.checkAvailability()` or `checkAvailabilityAsync()` for both AR Required and AR Optional applications. *(Google hem AR Required hem de AR Optional uygulamalar için `ArCoreApk.checkAvailability()` veya `checkAvailabilityAsync()` kullanılmasını önerir.)*

Unsupported ARCore must disable only the ARCore enhancement rather than the complete NAVGUARD application. *(Desteklenmeyen ARCore tüm NAVGUARD uygulaması yerine yalnızca ARCore iyileştirmesini devre dışı bırakmalıdır.)*

---

# 8. Google Play Services for AR Check (Google Play Services for AR Kontrolü)

NAVGUARD will verify that a compatible Google Play Services for AR installation is available before creating an ARCore session. *(NAVGUARD bir ARCore oturumu oluşturmadan önce uyumlu Google Play Services for AR kurulumunun mevcut olduğunu doğrulayacaktır.)*

Google requires `ArCoreApk.requestInstall()` before session creation to verify installation and required device-profile information. *(Google kurulum ve gerekli cihaz profil bilgisini doğrulamak için oturum oluşturmadan önce `ArCoreApk.requestInstall()` kullanılmasını gerektirir.)*

---

# 9. Camera Permission (Kamera İzni)

ARCore tracking requires access to the device camera. *(ARCore takibi cihaz kamerasına erişim gerektirir.)*

Camera permission must therefore be validated before the ARCore session is resumed. *(Bu nedenle kamera izni ARCore oturumu devam ettirilmeden önce doğrulanmalıdır.)*

The detailed user-facing permission workflow will remain part of **32 — Permissions, Privacy & Security**. *(Ayrıntılı kullanıcıya yönelik izin iş akışı **32 — Permissions, Privacy & Security** bölümünün parçası olarak kalacaktır.)*

---

# 10. ARCore Lifecycle Overview (ARCore Yaşam Döngüsü Genel Görünümü)

```
Check ARCore Support
(ARCore Desteğini Kontrol Et)
        ↓
Check / Install Google Play Services for AR
(Google Play Services for AR Kontrol / Kurulum)
        ↓
Camera Permission
(Kamera İzni)
        ↓
Create Session
(Oturum Oluştur)
        ↓
Configure Session
(Oturumu Yapılandır)
        ↓
Resume
(Devam Ettir)
        ↓
Session.update()
        ↓
Read Tracking State and Pose
(Takip Durumunu ve Pozu Oku)
        ↓
Pause
(Duraklat)
        ↓
Close
(Kapat)
```

---

# 11. Session Ownership (Oturum Sahipliği)

A dedicated native Android component will own the ARCore `Session`. *(Özel bir native Android bileşeni ARCore `Session` nesnesinin sahibi olacaktır.)*

Flutter widgets will not independently create or control multiple ARCore sessions. *(Flutter widget’ları bağımsız olarak birden fazla ARCore oturumu oluşturmayacak veya kontrol etmeyecektir.)*

This provides a single authoritative ARCore state for navigation. *(Bu navigasyon için tek bir ana ARCore durumu sağlar.)*

---

# 12. Session Resume (Oturumu Devam Ettirme)

ARCore `Session.resume()` starts or resumes an ARCore session and is normally associated with the Android `onResume()` lifecycle. *(ARCore `Session.resume()` bir ARCore oturumunu başlatır veya devam ettirir ve normalde Android `onResume()` yaşam döngüsüyle ilişkilidir.)*

Failure to resume successfully must leave ARCore unavailable without stopping baseline PDR. *(Başarılı şekilde devam ettirememe temel PDR’yi durdurmadan ARCore’u kullanılamaz durumda bırakmalıdır.)*

---

# 13. Session Pause (Oturumu Duraklatma)

ARCore `Session.pause()` stops the camera feed and releases associated resources while allowing the session to be resumed later. *(ARCore `Session.pause()` kamera akışını durdurur ve ilişkili kaynakları serbest bırakırken oturumun daha sonra devam ettirilmesine izin verir.)*

A NAVGUARD pause event must also mark the current ARCore navigation segment as interrupted. *(Bir NAVGUARD duraklatma olayı mevcut ARCore navigasyon segmentini de kesintiye uğramış olarak işaretlemelidir.)*

---

# 14. Session Close (Oturumu Kapatma)

NAVGUARD will explicitly close the ARCore session when it is no longer required. *(NAVGUARD artık gerekli olmadığında ARCore oturumunu açıkça kapatacaktır.)*

Google documents that an ARCore `Session` owns significant native memory and should be explicitly closed to release resources. *(Google bir ARCore `Session` nesnesinin önemli miktarda native belleğe sahip olduğunu ve kaynakları serbest bırakmak için açıkça kapatılması gerektiğini belirtir.)*

---

# 15. Session State Model (Oturum Durum Modeli)

```
UNAVAILABLE
CHECKING
INSTALL_REQUIRED
PERMISSION_REQUIRED
CREATING
INITIALIZING
TRACKING
DEGRADED
PAUSED
ERROR
CLOSED
```

The NAVGUARD ARCore state is a project-level state derived from the underlying ARCore runtime state. *(NAVGUARD ARCore durumu temel ARCore çalışma zamanı durumundan türetilen proje seviyesinde bir durumdur.)*

---

# 16. Frame Update (Frame Güncellemesi)

Active ARCore tracking will be updated through `Session.update()`. *(Aktif ARCore takibi `Session.update()` üzerinden güncellenecektir.)*

Google documents that `Session.update()` receives a new camera frame and updates device location, anchors, detected trackables, and other ARCore state. *(Google `Session.update()` fonksiyonunun yeni kamera karesi aldığını ve cihaz konumunu, anchor’ları, tespit edilen trackable’ları ve diğer ARCore durumunu güncellediğini belirtir.)*

---

# 17. Primary ARCore Navigation Output (Temel ARCore Navigasyon Çıktısı)

The primary NAVGUARD ARCore navigation measurement will be relative pose or relative translation rather than planes, hit tests, or virtual-object placement. *(Temel NAVGUARD ARCore navigasyon ölçümü plane, hit test veya sanal nesne yerleştirme yerine göreli poz veya göreli öteleme olacaktır.)*

Scene rendering functionality will remain secondary to navigation research. *(Sahne render işlevi navigasyon araştırmasına göre ikincil kalacaktır.)*

---

# 18. Pose Definition (Poz Tanımı)

An ARCore `Pose` represents a rigid transformation from an object’s local coordinate system into ARCore world coordinates. *(Bir ARCore `Pose`, bir nesnenin yerel koordinat sisteminden ARCore dünya koordinatlarına katı dönüşümü temsil eder.)*

ARCore poses use a right-handed coordinate system and translation values are expressed in metres. *(ARCore pozları sağ elli koordinat sistemi kullanır ve öteleme değerleri metre cinsinden ifade edilir.)*

---

# 19. Camera Pose (Kamera Pozu)

NAVGUARD may obtain the physical camera pose from `Camera.getPose()` for the latest frame. *(NAVGUARD en son kare için fiziksel kamera pozunu `Camera.getPose()` üzerinden elde edebilir.)*

Google documents the physical camera pose as the camera position and orientation in ARCore world space for the latest frame. *(Google fiziksel kamera pozunu en son kare için ARCore dünya uzayındaki kamera konumu ve yönelimi olarak tanımlar.)*

---

# 20. Physical Camera Axes (Fiziksel Kamera Eksenleri)

For the physical camera pose, ARCore follows an OpenGL-style camera convention. *(Fiziksel kamera pozu için ARCore OpenGL tarzı kamera kuralını izler.)*

Positive X points to the camera’s right, positive Y points upward, and negative Z points in the viewing direction. *(Pozitif X kameranın sağına, pozitif Y yukarıya ve negatif Z görüntüleme yönüne işaret eder.)*

These axes are not equivalent to East, North, and Up. *(Bu eksenler Doğu, Kuzey ve Yukarı ile eşdeğer değildir.)*

---

# 21. Display-Oriented Pose Is Not the Navigation Pose (Ekran Yönelimli Poz Navigasyon Pozu Değildir)

ARCore also exposes a display-oriented camera pose for rendering. *(ARCore ayrıca render için ekran yönelimli kamera pozu sunar.)*

NAVGUARD navigation mathematics will not use display orientation as the authoritative physical tracking coordinate system. *(NAVGUARD navigasyon matematiği ekran yönelimini ana fiziksel takip koordinat sistemi olarak kullanmayacaktır.)*

---

# 22. Android Sensor Pose (Android Sensör Pozu)

ARCore `Frame.getAndroidSensorPose()` can expose the Android Sensor Coordinate System pose in ARCore world coordinates. *(ARCore `Frame.getAndroidSensorPose()`, Android Sensör Koordinat Sisteminin pozunu ARCore dünya koordinatlarında sunabilir.)*

Google states that this orientation follows the device’s native orientation and is not affected by display rotation. *(Google bu yönelimin cihazın doğal yönelimini izlediğini ve ekran dönüşünden etkilenmediğini belirtir.)*

NAVGUARD may use this pose when experimentally aligning ARCore tracking with the native IMU coordinate frame. *(NAVGUARD ARCore takibini native IMU koordinat çerçevesiyle deneysel olarak hizalarken bu pozu kullanabilir.)*

---

# 23. Camera Pose Versus Sensor Pose (Kamera Pozu ile Sensör Pozu)

The physical camera pose and Android sensor pose are not identical coordinate origins. *(Fiziksel kamera pozu ile Android sensör pozu aynı koordinat başlangıç noktaları değildir.)*

NAVGUARD must therefore explicitly record which pose type is used by each ARCore navigation experiment. *(Bu nedenle NAVGUARD her ARCore navigasyon deneyinde hangi poz türünün kullanıldığını açıkça kaydetmelidir.)*

---

# 24. ARCore Quaternion Representation (ARCore Quaternion Temsili)

ARCore pose rotations are represented using quaternion components in `{x, y, z, w}` order. *(ARCore poz dönüşleri quaternion bileşenlerini `{x, y, z, w}` sırasıyla kullanarak temsil edilir.)*

NAVGUARD’s canonical internal quaternion order is `[w, x, y, z]`. *(NAVGUARD’ın kanonik dahili quaternion sırası `[w, x, y, z]` şeklindedir.)*

The adapter layer must reorder these components explicitly. *(Adapter katmanı bu bileşenleri açıkça yeniden sıralamalıdır.)*

---

# 25. ARCore World Coordinates Are Not Globally Fixed (ARCore Dünya Koordinatları Global Olarak Sabit Değildir)

ARCore’s estimate of world space can change as its environmental understanding improves. *(ARCore’un dünya uzayı tahmini çevre anlayışı geliştikçe değişebilir.)*

Google explicitly warns that world coordinates are unique to the current frame and recommends anchors or anchor-relative positions for positions that need to persist. *(Google dünya koordinatlarının mevcut kareye özgü olduğunu açıkça belirtir ve kalıcı olması gereken konumlar için anchor veya anchor’a göreli konumlar önerir.)*

NAVGUARD will therefore not treat raw ARCore world XYZ values as immutable global coordinates. *(Bu nedenle NAVGUARD ham ARCore dünya XYZ değerlerini değişmez global koordinatlar olarak ele almayacaktır.)*

---

# 26. No Direct ARCore-to-Latitude Mapping (Doğrudan ARCore-Enlem/Boylam Eşleme Olmaması)

ARCore X, Y, and Z values will never be directly added to WGS84 latitude or longitude. *(ARCore X, Y ve Z değerleri hiçbir zaman doğrudan WGS84 enlem veya boylamına eklenmeyecektir.)*

ARCore movement must first enter the NAVGUARD local ENU metric coordinate system. *(ARCore hareketi önce NAVGUARD yerel ENU metrik koordinat sistemine girmelidir.)*

---

# 27. Tracking State (Takip Durumu)

NAVGUARD will inspect ARCore camera tracking state before using any pose measurement. *(NAVGUARD herhangi bir poz ölçümünü kullanmadan önce ARCore kamera takip durumunu inceleyecektir.)*

The ARCore `TrackingState` values are `TRACKING`, `PAUSED`, and `STOPPED`. *(ARCore `TrackingState` değerleri `TRACKING`, `PAUSED` ve `STOPPED` şeklindedir.)*

---

# 28. TRACKING State (TRACKING Durumu)

`TRACKING` means ARCore currently considers the tracked pose current. *(`TRACKING`, ARCore’un takip edilen pozu mevcut ve güncel kabul ettiği anlamına gelir.)*

Only `TRACKING` camera poses are candidates for navigation measurements. *(Yalnızca `TRACKING` kamera pozları navigasyon ölçümü adayıdır.)*

---

# 29. PAUSED State (PAUSED Durumu)

`PAUSED` means ARCore tracking is temporarily paused and may resume later. *(`PAUSED`, ARCore takibinin geçici olarak duraklatıldığı ve daha sonra devam edebileceği anlamına gelir.)*

Google warns that object properties may be highly inaccurate in this state and generally should not be used. *(Google bu durumda nesne özelliklerinin oldukça hatalı olabileceğini ve genel olarak kullanılmaması gerektiğini belirtir.)*

NAVGUARD will therefore reject ARCore pose measurements from active navigation while tracking is `PAUSED`. *(Bu nedenle NAVGUARD takip `PAUSED` iken ARCore poz ölçümlerini aktif navigasyondan reddedecektir.)*

---

# 30. STOPPED State (STOPPED Durumu)

`STOPPED` indicates that tracking of the relevant trackable has ended and will not resume. *(`STOPPED`, ilgili trackable takibinin sona erdiğini ve devam etmeyeceğini gösterir.)*

A stopped navigation reference must therefore be discarded and replaced through controlled reinitialization when possible. *(Bu nedenle durmuş bir navigasyon referansı atılmalı ve mümkün olduğunda kontrollü yeniden başlatma üzerinden değiştirilmelidir.)*

---

# 31. Pose Validity Gate (Poz Geçerlilik Kapısı)

The ARCore navigation measurement path will conceptually follow this gate. *(ARCore navigasyon ölçüm hattı kavramsal olarak bu kapıyı izleyecektir.)*

```
ARCore Frame
     ↓
Tracking State
     │
     ├── TRACKING ──► Continue Validation
     │
     ├── PAUSED ────► Reject Pose
     │
     └── STOPPED ───► Invalidate Segment
```

No ARCore pose will bypass this tracking-state validation. *(Hiçbir ARCore pozu bu takip durumu doğrulamasını atlamayacaktır.)*

---

# 32. Tracking Failure Reason (Takip Başarısızlık Nedeni)

When camera tracking is paused, NAVGUARD will record `Camera.getTrackingFailureReason()`. *(Kamera takibi duraklatıldığında NAVGUARD `Camera.getTrackingFailureReason()` değerini kaydedecektir.)*

This allows the application to distinguish different tracking-loss conditions. *(Bu uygulamanın farklı takip kaybı koşullarını ayırt etmesini sağlar.)*

---

# 33. Official Tracking Failure Categories (Resmî Takip Başarısızlık Kategorileri)

ARCore exposes failure reasons including `BAD_STATE`, `CAMERA_UNAVAILABLE`, `EXCESSIVE_MOTION`, `INSUFFICIENT_FEATURES`, `INSUFFICIENT_LIGHT`, and `NONE`. *(ARCore `BAD_STATE`, `CAMERA_UNAVAILABLE`, `EXCESSIVE_MOTION`, `INSUFFICIENT_FEATURES`, `INSUFFICIENT_LIGHT` ve `NONE` dahil olmak üzere başarısızlık nedenleri sunar.)*

NAVGUARD will preserve these reasons as diagnostic evidence rather than collapse every failure into one generic error. *(NAVGUARD bu nedenleri tek bir genel hataya indirgemek yerine tanısal kanıt olarak koruyacaktır.)*

---

# 34. Insufficient Features (Yetersiz Görsel Özellik)

`INSUFFICIENT_FEATURES` indicates that ARCore cannot obtain enough visual features for reliable tracking. *(`INSUFFICIENT_FEATURES`, ARCore’un güvenilir takip için yeterli görsel özellik elde edemediğini gösterir.)*

Blank walls and low-detail surfaces are examples of conditions that may cause this failure. *(Boş duvarlar ve düşük detaylı yüzeyler bu hataya neden olabilecek koşullara örnektir.)*

This condition is directly relevant to NAVGUARD low-texture experiments. *(Bu koşul NAVGUARD düşük dokulu ortam deneyleriyle doğrudan ilgilidir.)*

---

# 35. Insufficient Light (Yetersiz Işık)

`INSUFFICIENT_LIGHT` indicates that poor lighting prevents reliable motion tracking. *(`INSUFFICIENT_LIGHT`, düşük ışığın güvenilir hareket takibini engellediğini gösterir.)*

NAVGUARD will treat such measurements as unavailable rather than attempt to force ARCore displacement into the fusion system. *(NAVGUARD bu tür ölçümleri füzyon sistemine ARCore yer değiştirmesi zorlamak yerine kullanılamaz olarak ele alacaktır.)*

---

# 36. Excessive Motion (Aşırı Hareket)

`EXCESSIVE_MOTION` indicates that device movement has become too rapid for current ARCore tracking. *(`EXCESSIVE_MOTION`, cihaz hareketinin mevcut ARCore takibi için fazla hızlı hale geldiğini gösterir.)*

This condition may occur during fast phone motion even if the pedestrian remains in a visually rich environment. *(Bu koşul yaya görsel açıdan zengin bir ortamda kalsa bile hızlı telefon hareketi sırasında meydana gelebilir.)*

---

# 37. Camera Unavailable (Kamera Kullanılamaz)

`CAMERA_UNAVAILABLE` may occur when another application has higher-priority camera access. *(`CAMERA_UNAVAILABLE`, başka bir uygulamanın daha yüksek öncelikli kamera erişimine sahip olması durumunda meydana gelebilir.)*

PDR must continue independently during such an interruption. *(PDR böyle bir kesinti sırasında bağımsız olarak devam etmelidir.)*

---

# 38. ARCore Tracking Lifecycle and Canonical Quality (ARCore Takip Yaşam Döngüsü ve Canonical Kalite)

ARCore tracking lifecycle or availability will be represented by a separate explicit type. *(ARCore tracking lifecycle veya availability ayrı ve açık bir type ile temsil edilecektir.)*

```
ARCoreTrackingLifecycle

INITIALIZING
TRACKING
LOST
RECOVERING
UNAVAILABLE
```

These lifecycle values are not canonical Sensor Quality states and must remain distinguishable from both the raw ARCore `TrackingState` and the common quality field. Formal navigation measurement use still requires raw `TrackingState.TRACKING` plus all other validity checks. *(Bu lifecycle value'ları canonical Sensor Quality state değildir ve hem raw ARCore `TrackingState` hem de common quality field'dan ayrı kalmalıdır. Formal navigation measurement kullanımı yine raw `TrackingState.TRACKING` ve diğer tüm validity check'leri gerektirir.)*

The separate ARCore source-quality field will use the canonical Sensor Quality enum. *(Ayrı ARCore source-quality field canonical Sensor Quality enum'u kullanacaktır.)*

```text
UNKNOWN
GOOD
USABLE
DEGRADED
UNRELIABLE
UNAVAILABLE
```

Lifecycle and canonical quality must not replace one another. Any mapping from lifecycle and measured pose evidence into canonical quality must be explicit, versioned, and calibrated. *(Lifecycle ve canonical quality birbirinin yerini almamalıdır. Lifecycle ile measured pose evidence'tan canonical quality'ye yapılan herhangi bir mapping explicit, versioned ve calibrated olmalıdır.)*

---

# 39. GOOD ARCore Quality (İyi ARCore Kalitesi)

`GOOD` requires valid camera `TRACKING` and acceptable recent pose behavior. *(`GOOD`, geçerli kamera `TRACKING` durumu ve kabul edilebilir son poz davranışı gerektirir.)*

Additional quality checks may include pose continuity and recent tracking stability. *(Ek kalite kontrolleri poz sürekliliğini ve son takip kararlılığını içerebilir.)*

`GOOD` quality cannot authorize a pose when raw tracking is `PAUSED` or otherwise invalid. *(`GOOD` quality, raw tracking `PAUSED` veya başka şekilde invalid olduğunda bir pose'u authorize edemez.)*

---

# 40. DEGRADED ARCore Quality (Bozulmuş ARCore Kalitesi)

ARCore may be considered `DEGRADED` when tracking technically remains available but recent measurements exhibit suspicious discontinuity or instability. *(Takip teknik olarak kullanılabilir kalırken son ölçümler şüpheli süreksizlik veya kararsızlık gösterdiğinde ARCore `DEGRADED` kabul edilebilir.)*

The exact derived-quality thresholds will be based on measured Redmi Note 9 Pro behavior. *(Kesin türetilmiş kalite eşikleri ölçülmüş Redmi Note 9 Pro davranışına dayanacaktır.)*

---

# 41. Local ARCore Reference (Yerel ARCore Referansı)

NAVGUARD will establish a local ARCore reference when a tracking-enabled navigation segment begins. *(NAVGUARD takip etkin bir navigasyon segmenti başladığında yerel bir ARCore referansı oluşturacaktır.)*

This reference is separate from the geographic GNSS anchor. *(Bu referans coğrafi GNSS çapasından ayrıdır.)*

---

# 42. Two Different Anchor Concepts (İki Farklı Çapa Kavramı)

The GNSS anchor defines where the NAVGUARD ENU frame is located on Earth. *(GNSS çapası NAVGUARD ENU çerçevesinin Dünya üzerinde nerede bulunduğunu tanımlar.)*

The ARCore local anchor defines a persistent local visual-inertial reference within an ARCore tracking segment. *(ARCore yerel anchor’ı bir ARCore takip segmenti içerisinde kalıcı yerel görsel-ataletsel referansı tanımlar.)*

These two anchor types must never be treated as interchangeable. *(Bu iki çapa türü hiçbir zaman birbirinin yerine kullanılmamalıdır.)*

---

# 43. Anchor-Based Relative Pose (Anchor Tabanlı Göreli Poz)

Let `T_W_C(k)` represent the current camera pose in ARCore world coordinates. *(`T_W_C(k)`, mevcut kamera pozunu ARCore dünya koordinatlarında temsil etsin.)*

Let `T_W_A(k)` represent the current local ARCore anchor pose. *(`T_W_A(k)`, mevcut yerel ARCore anchor pozunu temsil etsin.)*

The camera pose relative to the anchor will be calculated as follows. *(Kameranın anchor’a göre pozu aşağıdaki şekilde hesaplanacaktır.)*

```
T_A_C(k) =
T_W_A(k)^-1 · T_W_C(k)
```

---

# 44. Why the Current Anchor Pose Is Used (Neden Mevcut Anchor Pozu Kullanılır)

ARCore may update the anchor’s world-space pose as its estimate of the environment changes. *(ARCore çevre tahminini değiştirdikçe anchor’ın dünya uzayındaki pozunu güncelleyebilir.)*

Using the current anchor pose and current camera pose keeps the relative transform tied to ARCore’s latest environmental estimate. *(Mevcut anchor pozu ile mevcut kamera pozunu kullanmak göreli dönüşümü ARCore’un en son çevre tahminine bağlı tutar.)*

Google describes anchors as adapting their poses as world-space understanding is updated. *(Google anchor’ları dünya uzayı anlayışı güncellendikçe pozlarını uyarlayan yapılar olarak tanımlar.)*

---

# 45. Relative ARCore Translation (Göreli ARCore Ötelemesi)

The translation component of `T_A_C(k)` will represent camera position relative to the local ARCore anchor. *(`T_A_C(k)` dönüşümünün öteleme bileşeni yerel ARCore anchor’ına göre kamera konumunu temsil edecektir.)*

```
p_A(k) =
[x_A, y_A, z_A]^T
```

These values are still expressed in the ARCore local reference frame. *(Bu değerler hâlâ ARCore yerel referans çerçevesinde ifade edilir.)*

---

# 46. Initial Relative Position (Başlangıç Göreli Konumu)

At creation of a navigation reference, the initial relative displacement may be defined as the segment origin. *(Bir navigasyon referansı oluşturulduğunda başlangıç göreli yer değiştirmesi segment başlangıç noktası olarak tanımlanabilir.)*

```
p_A,0 =
p_A(t0)
```

Subsequent displacement may then be expressed relative to that initial value. *(Sonraki yer değiştirme daha sonra bu başlangıç değerine göre ifade edilebilir.)*

```
Δp_A(k) =
p_A(k) - p_A,0
```

---

# 47. Incremental ARCore Displacement (Artımlı ARCore Yer Değiştirmesi)

NAVGUARD may additionally calculate incremental displacement between successive valid tracking samples. *(NAVGUARD ayrıca ardışık geçerli takip örnekleri arasında artımlı yer değiştirme hesaplayabilir.)*

```
δp_A(k) =
p_A(k) - p_A(k-1)
```

Incremental displacement can be useful for real-time fusion and jump detection. *(Artımlı yer değiştirme gerçek zamanlı füzyon ve sıçrama tespiti için kullanışlı olabilir.)*

---

# 48. Anchor Persistence Guidance (Anchor Kalıcılık Rehberi)

Google recommends using anchors for spatial information that must persist beyond a single frame. *(Google tek bir karenin ötesinde kalıcı olması gereken uzamsal bilgi için anchor kullanılmasını önerir.)*

NAVGUARD will therefore prefer anchor-relative tracking rather than relying only on unanchored numerical world coordinates. *(Bu nedenle NAVGUARD yalnızca anchor’sız sayısal dünya koordinatlarına güvenmek yerine anchor’a göreli takibi tercih edecektir.)*

---

# 49. Long Route Anchor Limitation (Uzun Rota Anchor Sınırlaması)

Google’s general AR anchor guidance recommends keeping anchored content close to its anchor and specifically advises against placing anchored objects more than approximately eight metres away. *(Google’ın genel AR anchor rehberi anchor’lı içeriğin anchor’a yakın tutulmasını önerir ve özellikle anchor’lı nesnelerin yaklaşık sekiz metreden daha uzağa yerleştirilmemesini tavsiye eder.)*

NAVGUARD will therefore not assume that one local ARCore anchor is automatically optimal for an arbitrarily long pedestrian route. *(Bu nedenle NAVGUARD tek bir yerel ARCore anchor’ının keyfi derecede uzun bir yaya rotası için otomatik olarak optimal olduğunu varsaymayacaktır.)*

---

# 50. ARCore Segment Strategy (ARCore Segment Stratejisi)

Long navigation sessions may be divided into local ARCore tracking segments. *(Uzun navigasyon oturumları yerel ARCore takip segmentlerine bölünebilir.)*

Each segment may have its own local ARCore reference while the global NAVGUARD ENU trajectory remains continuous. *(Global NAVGUARD ENU rotası sürekli kalırken her segment kendi yerel ARCore referansına sahip olabilir.)*

---

# 51. ARCore Segment Model (ARCore Segment Modeli)

```
ArcoreSegment
- segmentId
- startTimestamp
- endTimestamp
- anchorId
- enuAlignment
- startEnuPosition
- endReason
```

A segment boundary must not be interpreted as physical pedestrian displacement. *(Bir segment sınırı fiziksel yaya yer değiştirmesi olarak yorumlanmamalıdır.)*

---

# 52. Segment Re-Anchoring Policy (Segment Yeniden Çapalama Politikası)

NAVGUARD may begin a new ARCore segment after tracking loss, session restart, major pose discontinuity, or deliberate local-reference renewal. *(NAVGUARD takip kaybı, oturum yeniden başlatması, büyük poz süreksizliği veya bilinçli yerel referans yenilemesi sonrasında yeni bir ARCore segmenti başlatabilir.)*

The exact distance-based renewal rule will be selected after field measurements rather than blindly copying the eight-metre content-placement guideline as a navigation threshold. *(Kesin mesafe tabanlı yenileme kuralı sekiz metrelik içerik yerleştirme rehberini körlemesine navigasyon eşiği olarak kopyalamak yerine saha ölçümlerinden sonra seçilecektir.)*

---

# 53. Segment Continuity (Segment Sürekliliği)

A new ARCore segment will be aligned to the current NAVGUARD navigation state. *(Yeni bir ARCore segmenti mevcut NAVGUARD navigasyon durumuna hizalanacaktır.)*

The ENU trajectory will not reset to zero merely because the internal ARCore local reference changed. *(Dahili ARCore yerel referansı değiştiği için ENU rotası sıfıra sıfırlanmayacaktır.)*

---

# 54. ARCore-to-ENU Alignment (ARCore’dan ENU’ya Hizalama)

ARCore relative motion must be transformed into the NAVGUARD ENU frame before fusion. *(ARCore göreli hareketi füzyondan önce NAVGUARD ENU çerçevesine dönüştürülmelidir.)*

```
Δp_N =
R_N_A · Δp_A
```

`R_N_A` represents the rotational alignment between the active ARCore local reference and NAVGUARD ENU. *(`R_N_A`, aktif ARCore yerel referansı ile NAVGUARD ENU arasındaki dönme hizalamasını temsil eder.)*

---

# 55. No Hard-Coded Axis Mapping (Hard-Code Eksen Eşleme Olmaması)

NAVGUARD will not assume that ARCore X automatically equals East or that ARCore negative Z automatically equals North. *(NAVGUARD ARCore X’in otomatik olarak Doğu’ya veya ARCore negatif Z’nin otomatik olarak Kuzey’e eşit olduğunu varsaymayacaktır.)*

The mapping depends on the ARCore reference orientation at segment initialization. *(Eşleme segment başlatılırken ARCore referans yönelimine bağlıdır.)*

---

# 56. Alignment Initialization (Hizalama Başlatma)

The initial ARCore-to-ENU alignment may use the validated true-north heading available at the start of the segment. *(Başlangıç ARCore-ENU hizalaması segment başlangıcında mevcut olan doğrulanmış gerçek kuzey yönünü kullanabilir.)*

The camera or sensor-frame orientation must be interpreted according to the exact pose representation selected by the implementation. *(Kamera veya sensör çerçevesi yönelimi uygulama tarafından seçilen kesin poz temsiline göre yorumlanmalıdır.)*

---

# 57. Alignment Calibration Motion (Hizalama Kalibrasyon Hareketi)

A short controlled forward movement may be used as additional evidence for horizontal ARCore-to-ENU alignment. *(Kısa kontrollü ileri hareket yatay ARCore-ENU hizalaması için ek kanıt olarak kullanılabilir.)*

The expected ENU direction can be provided by the validated heading system while ARCore provides the corresponding local displacement direction. *(Beklenen ENU yönü doğrulanmış yön sistemi tarafından sağlanırken ARCore karşılık gelen yerel yer değiştirme yönünü sağlayabilir.)*

---

# 58. Horizontal Alignment Candidate (Yatay Hizalama Adayı)

Let `θ_A` represent the horizontal direction of a validated ARCore forward displacement in its local frame. *(`θ_A`, doğrulanmış ARCore ileri yer değiştirmesinin yerel çerçevesindeki yatay yönünü temsil etsin.)*

Let `ψ_N` represent the corresponding true-north navigation direction. *(`ψ_N`, karşılık gelen gerçek kuzey navigasyon yönünü temsil etsin.)*

A horizontal yaw alignment candidate may be derived from their angular difference. *(Yatay yaw hizalama adayı bu iki yön arasındaki açısal farktan türetilebilir.)*

---

# 59. Alignment Must Be Measured (Hizalama Ölçülmelidir)

The final ARCore-to-ENU alignment procedure will not be frozen until controlled Redmi Note 9 Pro tests confirm the axis and sign conventions. *(Nihai ARCore-ENU hizalama prosedürü kontrollü Redmi Note 9 Pro testleri eksen ve işaret kurallarını doğrulayana kadar sabitlenmeyecektir.)*

Known forward, rightward, and turning tests will verify the transformation. *(Bilinen ileri, sağa ve dönüş testleri dönüşümü doğrulayacaktır.)*

---

# 60. ARCore Horizontal Output (ARCore Yatay Çıktısı)

After alignment, the primary ARCore navigation measurement will be represented in East and North metres. *(Hizalamadan sonra temel ARCore navigasyon ölçümü metre cinsinden Doğu ve Kuzey olarak temsil edilecektir.)*

```
Δp_AR_ENU =
[ΔE_AR, ΔN_AR]^T
```

This allows direct comparison with PDR and GNSS-derived ENU positions. *(Bu PDR ve GNSS kaynaklı ENU konumlarıyla doğrudan karşılaştırmaya izin verir.)*

---

# 61. Vertical ARCore Output (Dikey ARCore Çıktısı)

ARCore also provides three-dimensional motion information. *(ARCore ayrıca üç boyutlu hareket bilgisi sağlar.)*

Vertical displacement may be logged as `ΔU_AR`, but the primary NAVGUARD benchmark will remain horizontally focused. *(Dikey yer değiştirme `ΔU_AR` olarak kaydedilebilir ancak temel NAVGUARD benchmark’ı yatay odaklı kalacaktır.)*

---

# 62. ARCore Measures Device Motion (ARCore Cihaz Hareketini Ölçer)

ARCore tracks the smartphone camera or sensor frame rather than the pedestrian’s body centre of mass. *(ARCore yayanın vücut kütle merkezi yerine akıllı telefon kamerasını veya sensör çerçevesini takip eder.)*

Natural hand and body motion can therefore appear as short-term local ARCore translation. *(Bu nedenle doğal el ve vücut hareketi kısa dönem yerel ARCore ötelemesi olarak görünebilir.)*

---

# 63. Device-Motion Limitation (Cihaz Hareketi Sınırlaması)

The fusion system must not automatically interpret every centimetre-scale camera motion as actual pedestrian path displacement. *(Füzyon sistemi santimetre ölçeğindeki her kamera hareketini otomatik olarak gerçek yaya rota yer değiştirmesi olarak yorumlamamalıdır.)*

Controlled phone placement and temporal filtering may reduce this effect. *(Kontrollü telefon yerleşimi ve zamansal filtreleme bu etkiyi azaltabilir.)*

---

# 64. ARCore Displacement Filtering (ARCore Yer Değiştirme Filtreleme)

NAVGUARD may apply lightweight filtering to aligned ARCore displacement or velocity before fusion. *(NAVGUARD füzyondan önce hizalanmış ARCore yer değiştirmesine veya hızına hafif filtreleme uygulayabilir.)*

The selected filtering must preserve genuine pedestrian turns and motion while suppressing device-hand oscillation where possible. *(Seçilen filtreleme mümkün olduğunda cihaz-el salınımını bastırırken gerçek yaya dönüşlerini ve hareketini korumalıdır.)*

The final filter will be selected from measured data. *(Nihai filtre ölçülmüş veriden seçilecektir.)*

---

# 65. No Ground Truth Correction Inside ARCore (ARCore İçerisinde Ground Truth Düzeltmesi Olmaması)

ARCore motion measurements will not be corrected using GNSS ground truth during a GNSS-denied evaluation interval. *(ARCore hareket ölçümleri GNSS kesintili değerlendirme aralığında GNSS gerçek referansı kullanılarak düzeltilmeyecektir.)*

GNSS may evaluate ARCore externally but cannot secretly recalibrate its denied trajectory during the benchmark. *(GNSS ARCore’u harici olarak değerlendirebilir ancak benchmark sırasında kesintili rotasını gizlice yeniden kalibre edemez.)*

---

# 66. ARCore Frame Timestamp (ARCore Frame Zaman Damgası)

ARCore `Frame.getTimestamp()` returns a nanosecond timestamp for the captured image. *(ARCore `Frame.getTimestamp()`, yakalanan görüntü için nanosaniye zaman damgası döndürür.)*

Google explicitly states that the time base of this value is not defined, although it is likely similar to `System.nanoTime()`. *(Google bu değerin zaman tabanının tanımlı olmadığını, ancak muhtemelen `System.nanoTime()` benzeri olduğunu açıkça belirtir.)*

NAVGUARD will therefore not assume without verification that `Frame.getTimestamp()` is directly interchangeable with Android sensor `elapsedRealtimeNanos` timestamps. *(Bu nedenle NAVGUARD doğrulama olmadan `Frame.getTimestamp()` değerinin Android sensör `elapsedRealtimeNanos` zaman damgalarıyla doğrudan değiştirilebilir olduğunu varsaymayacaktır.)*

---

# 67. Android Camera Timestamp (Android Kamera Zaman Damgası)

ARCore also exposes `Frame.getAndroidCameraTimestamp()`. *(ARCore ayrıca `Frame.getAndroidCameraTimestamp()` değerini sunar.)*

This timestamp corresponds to the Android camera image timestamp. *(Bu zaman damgası Android kamera görüntüsü zaman damgasına karşılık gelir.)*

NAVGUARD may use it as additional evidence during cross-sensor clock alignment. *(NAVGUARD bunu sensörler arası saat hizalaması sırasında ek kanıt olarak kullanabilir.)*

---

# 68. ARCore Common-Clock Mapping (ARCore Ortak Saat Eşlemesi)

The ARCore timestamp domain will be explicitly characterized during the Device Capability Audit. *(ARCore zaman damgası alanı Cihaz Yetenek Denetimi sırasında açıkça karakterize edilecektir.)*

The implementation may record application monotonic time immediately around each `Session.update()` observation to estimate and validate a timestamp mapping. *(Uygulama bir zaman damgası eşlemesini tahmin etmek ve doğrulamak için her `Session.update()` gözleminin hemen çevresinde uygulama monotonik zamanını kaydedebilir.)*

---

# 69. Timestamp Mapping Must Be Validated (Zaman Damgası Eşlemesi Doğrulanmalıdır)

A constant timestamp offset must not be assumed until measured data shows that such a mapping is stable. *(Sabit bir zaman damgası offset’i ölçülen veri böyle bir eşlemenin kararlı olduğunu gösterene kadar varsayılmamalıdır.)*

If clock relationship is unstable, ARCore fusion must use a more robust temporal-alignment strategy. *(Saat ilişkisi kararsızsa ARCore füzyonu daha robust bir zamansal hizalama stratejisi kullanmalıdır.)*

---

# 70. Frame Rate Measurement (Kare Hızı Ölçümü)

`Frame.getTimestamp()` may be used to detect dropped frames and estimate ARCore camera frame intervals. *(`Frame.getTimestamp()`, düşen kareleri tespit etmek ve ARCore kamera kare aralıklarını tahmin etmek için kullanılabilir.)*

NAVGUARD will measure actual frame behavior rather than assume a fixed ARCore frame rate. *(NAVGUARD sabit bir ARCore kare hızı varsaymak yerine gerçek kare davranışını ölçecektir.)*

---

# 71. Pose Event Data Model (Poz Olayı Veri Modeli)

```
ArcorePoseSample
- sampleSequence
- frameTimestampNs
- androidCameraTimestampNs
- appElapsedRealtimeNsAtRead
- trackingState
- trackingFailureReason
- cameraTranslationX
- cameraTranslationY
- cameraTranslationZ
- cameraQuaternionX
- cameraQuaternionY
- cameraQuaternionZ
- cameraQuaternionW
- segmentId
- anchorTrackingState
```

Derived alignment values will remain separate from raw pose values. *(Türetilmiş hizalama değerleri ham poz değerlerinden ayrı kalacaktır.)*

---

# 72. Derived ARCore Measurement Model (Türetilmiş ARCore Ölçüm Modeli)

```
ArcoreNavigationMeasurement
- timestampNsCommon
- segmentId
- deltaEastM
- deltaNorthM
- deltaUpM
- deltaDistanceM
- qualityState
- confidence
```

Only validated measurements may enter sensor fusion. *(Yalnızca doğrulanmış ölçümler sensör füzyonuna girebilir.)*

---

# 73. ARCore Tracking Start (ARCore Takip Başlangıcı)

ARCore navigation measurements will not begin immediately after session creation. *(ARCore navigasyon ölçümleri oturum oluşturulduktan hemen sonra başlamayacaktır.)*

The system will first wait for camera tracking to become valid and stable enough for local-reference creation. *(Sistem önce kamera takibinin geçerli ve yerel referans oluşturmak için yeterince kararlı hale gelmesini bekleyecektir.)*

---

# 74. Initialization Quarantine (Başlatma Karantinası)

A short initialization period may be used after ARCore first enters `TRACKING`. *(ARCore ilk kez `TRACKING` durumuna girdikten sonra kısa bir başlatma dönemi kullanılabilir.)*

The objective is to avoid treating the first unstable tracking frames as navigation displacement. *(Amaç ilk kararsız takip karelerini navigasyon yer değiştirmesi olarak ele almaktan kaçınmaktır.)*

The final duration or frame count will be determined experimentally. *(Nihai süre veya kare sayısı deneysel olarak belirlenecektir.)*

---

# 75. Local Reference Creation Gate (Yerel Referans Oluşturma Kapısı)

An ARCore segment anchor will be created only after the required tracking-readiness conditions are satisfied. *(Bir ARCore segment anchor’ı yalnızca gerekli takip hazırlık koşulları karşılandıktan sonra oluşturulacaktır.)*

```
ARCore TRACKING
      +
Stable Recent Tracking
      +
Valid Pose
      +
Valid Alignment Inputs
      ↓
Create Local ARCore Reference
```

---

# 76. Tracking Loss (Takip Kaybı)

When ARCore leaves `TRACKING`, NAVGUARD will immediately stop sending ARCore position measurements to the fusion engine. *(ARCore `TRACKING` durumundan çıktığında NAVGUARD ARCore konum ölçümlerini füzyon motoruna göndermeyi hemen durduracaktır.)*

PDR and other available non-ARCore navigation sources will continue. *(PDR ve diğer mevcut ARCore dışı navigasyon kaynakları devam edecektir.)*

---

# 77. No Stale Pose Use (Eski Poz Kullanımı Olmaması)

The last valid ARCore pose must not be repeatedly reused as though it were a new live motion measurement. *(Son geçerli ARCore pozu yeni canlı hareket ölçümüymüş gibi tekrar tekrar kullanılmamalıdır.)*

A stale pose represents lack of new ARCore motion information. *(Eski bir poz yeni ARCore hareket bilgisi olmadığını temsil eder.)*

---

# 78. No Artificial Zero-Velocity Measurement During Loss (Kayıp Sırasında Yapay Sıfır Hız Ölçümü Olmaması)

Tracking loss does not prove that the pedestrian stopped moving. *(Takip kaybı yayanın hareket etmeyi bıraktığını kanıtlamaz.)*

NAVGUARD will therefore not convert loss of ARCore updates into artificial zero-displacement measurements. *(Bu nedenle NAVGUARD ARCore güncellemelerinin kaybını yapay sıfır yer değiştirme ölçümlerine dönüştürmeyecektir.)*

---

# 79. PDR Fallback During Tracking Loss (Takip Kaybında PDR Geri Dönüşü)

```
ARCore TRACKING
      ↓ loss
ARCore Measurements Disabled
      +
PDR Continues
      +
Heading Continues
      ↓
ARCore Recovery Attempt
```

This fallback is mandatory. *(Bu geri dönüş zorunludur.)*

---

# 80. Tracking Recovery (Takip Geri Kazanımı)

When ARCore returns to `TRACKING`, NAVGUARD will not immediately calculate displacement from the last pose before the tracking interruption. *(ARCore tekrar `TRACKING` durumuna döndüğünde NAVGUARD takip kesintisinden önceki son pozdan hemen yer değiştirme hesaplamayacaktır.)*

The spatial relationship across the tracking-loss gap may be unreliable. *(Takip kaybı boşluğu boyunca uzamsal ilişki güvenilmez olabilir.)*

---

# 81. Recovery Quarantine (Geri Kazanım Karantinası)

A short recovery-validation interval may be required after tracking resumes. *(Takip devam ettikten sonra kısa bir geri kazanım doğrulama aralığı gerekebilir.)*

During this period, ARCore poses may be logged without affecting navigation. *(Bu dönem sırasında ARCore pozları navigasyonu etkilemeden kaydedilebilir.)*

---

# 82. New Segment After Loss (Kayıptan Sonra Yeni Segment)

After a significant tracking interruption, NAVGUARD will normally begin a new ARCore local segment rather than connect the pre-loss and post-recovery poses with one displacement vector. *(Önemli bir takip kesintisinden sonra NAVGUARD kayıp öncesi ve geri kazanım sonrası pozları tek yer değiştirme vektörüyle bağlamak yerine normalde yeni bir ARCore yerel segmenti başlatacaktır.)*

This prevents tracking resets from being interpreted as real pedestrian jumps. *(Bu takip sıfırlamalarının gerçek yaya sıçramaları olarak yorumlanmasını önler.)*

---

# 83. ARCore Pose Jump Detection (ARCore Poz Sıçraması Tespiti)

Successive valid ARCore measurements will be monitored for implausibly large displacement jumps. *(Ardışık geçerli ARCore ölçümleri fiziksel olarak mantıksız büyük yer değiştirme sıçramaları açısından izlenecektir.)*

```
jumpDistance =
||p_k - p_(k-1)||
```

The final jump threshold will be determined from real pedestrian and ARCore measurements. *(Nihai sıçrama eşiği gerçek yaya ve ARCore ölçümlerinden belirlenecektir.)*

---

# 84. Jump Handling (Sıçrama Yönetimi)

A suspected ARCore pose jump will not force the complete fused navigation state to jump. *(Şüpheli bir ARCore poz sıçraması tam füzyonlu navigasyon durumunu sıçramaya zorlamayacaktır.)*

The measurement may be rejected, ARCore confidence may be reduced, or a new ARCore segment may be started. *(Ölçüm reddedilebilir, ARCore güveni azaltılabilir veya yeni bir ARCore segmenti başlatılabilir.)*

---

# 85. Stationary ARCore Drift (Sabit Durum ARCore Sürüklenmesi)

A stationary smartphone may exhibit nonzero ARCore position variation even though it does not physically move. *(Sabit bir akıllı telefon fiziksel olarak hareket etmese bile sıfır olmayan ARCore konum değişimi gösterebilir.)*

NAVGUARD will measure this effect directly rather than assume zero visual-inertial drift. *(NAVGUARD sıfır görsel-ataletsel sürüklenme varsaymak yerine bu etkiyi doğrudan ölçecektir.)*

---

# 86. Stationary Drift Test (Sabit Sürüklenme Testi)

The physical device will remain stationary while ARCore tracking is active for at least a controlled test interval. *(Fiziksel cihaz en az kontrollü bir test aralığı boyunca ARCore takibi aktifken sabit kalacaktır.)*

The Device Capability Audit already defines an initial minimum observation target of approximately sixty seconds. *(Cihaz Yetenek Denetimi yaklaşık altmış saniyelik ilk minimum gözlem hedefini zaten tanımlamaktadır.)*

The exact final experiment duration may later be extended. *(Kesin nihai deney süresi daha sonra uzatılabilir.)*

---

# 87. Stationary Drift Metrics (Sabit Sürüklenme Metrikleri)

Candidate metrics include maximum displacement from the initial stationary position. *(Aday metrikler başlangıç sabit konumundan maksimum yer değiştirmeyi içerir.)*

Candidate metrics include final displacement after the stationary interval. *(Aday metrikler sabit aralık sonundaki nihai yer değiştirmeyi içerir.)*

Candidate metrics include RMS position variation. *(Aday metrikler RMS konum değişimini içerir.)*

Candidate metrics include drift rate over time. *(Aday metrikler zaman içerisindeki sürüklenme oranını içerir.)*

---

# 88. No Predefined Stationary Drift Pass Threshold (Önceden Tanımlanmış Sabit Sürüklenme Geçme Eşiği Olmaması)

NAVGUARD will not invent a stationary ARCore drift threshold before measuring the Redmi Note 9 Pro. *(NAVGUARD Redmi Note 9 Pro’yu ölçmeden sabit durum ARCore sürüklenme eşiği uydurmayacaktır.)*

The observed distribution will guide quality thresholds and fusion covariance. *(Gözlemlenen dağılım kalite eşiklerini ve füzyon kovaryansını yönlendirecektir.)*

---

# 89. Straight-Line ARCore Test (Düz Çizgi ARCore Testi)

A controlled straight walking route will evaluate ARCore horizontal displacement. *(Kontrollü düz yürüyüş rotası ARCore yatay yer değiştirmesini değerlendirecektir.)*

The ARCore estimate will be compared against known route geometry and independent GNSS reference where appropriate. *(ARCore tahmini uygun olduğunda bilinen rota geometrisi ve bağımsız GNSS referansıyla karşılaştırılacaktır.)*

---

# 90. Distance Error (Mesafe Hatası)

For a known or independently estimated reference displacement, ARCore horizontal distance error may be calculated as follows. *(Bilinen veya bağımsız olarak tahmin edilen referans yer değiştirme için ARCore yatay mesafe hatası aşağıdaki şekilde hesaplanabilir.)*

```
e_distance =
D_AR - D_reference
```

Absolute and percentage forms may also be reported. *(Mutlak ve yüzde biçimleri ayrıca raporlanabilir.)*

---

# 91. Turn Test (Dönüş Testi)

A route containing approximately known turns will evaluate whether aligned ARCore displacement changes direction consistently with physical movement. *(Yaklaşık bilinen dönüşleri içeren bir rota hizalanmış ARCore yer değiştirmesinin fiziksel hareketle tutarlı şekilde yön değiştirip değiştirmediğini değerlendirecektir.)*

The test will also expose errors in ARCore-to-ENU axis alignment. *(Test ayrıca ARCore-ENU eksen hizalama hatalarını ortaya çıkaracaktır.)*

---

# 92. Closed-Loop ARCore Test (Kapalı Döngü ARCore Testi)

A closed or approximately closed route may be used to measure ARCore closure error. *(Kapalı veya yaklaşık kapalı bir rota ARCore kapanış hatasını ölçmek için kullanılabilir.)*

```
ClosureError_AR =
√(
E_AR,final² +
N_AR,final²
)
```

This provides a direct visual-inertial drift indicator. *(Bu doğrudan görsel-ataletsel sürüklenme göstergesi sağlar.)*

---

# 93. Low-Texture Test (Düşük Doku Testi)

NAVGUARD will intentionally include safe ordinary low-texture environments such as visually plain areas. *(NAVGUARD görsel olarak sade alanlar gibi güvenli sıradan düşük dokulu ortamları bilinçli olarak içerecektir.)*

The objective is to observe ARCore tracking degradation and confirm that fallback behavior activates correctly. *(Amaç ARCore takip bozulmasını gözlemlemek ve geri dönüş davranışının doğru etkinleştiğini doğrulamaktır.)*

---

# 94. Reduced-Light Test (Azaltılmış Işık Testi)

A naturally lower-light environment may be used to evaluate ARCore degradation without creating hazardous conditions. *(Doğal olarak daha düşük ışıklı bir ortam tehlikeli koşullar oluşturmadan ARCore bozulmasını değerlendirmek için kullanılabilir.)*

The test will record `INSUFFICIENT_LIGHT` or other tracking behavior when reported. *(Test raporlandığında `INSUFFICIENT_LIGHT` veya diğer takip davranışını kaydedecektir.)*

---

# 95. Excessive-Motion Test (Aşırı Hareket Testi)

A controlled faster device movement may be used to observe whether ARCore enters `EXCESSIVE_MOTION`. *(Kontrollü daha hızlı cihaz hareketi ARCore’un `EXCESSIVE_MOTION` durumuna girip girmediğini gözlemlemek için kullanılabilir.)*

The motion must remain safe and must not involve throwing or dangerously moving the device. *(Hareket güvenli kalmalı ve cihazı fırlatmayı veya tehlikeli şekilde hareket ettirmeyi içermemelidir.)*

---

# 96. Temporary Camera Obstruction Test (Geçici Kamera Kapatma Testi)

A short normal camera obstruction may be used as a controlled tracking-degradation test. *(Kısa normal kamera kapatma kontrollü takip bozulma testi olarak kullanılabilir.)*

The objective is to verify detection and fallback rather than to produce artificial navigation performance. *(Amaç yapay navigasyon performansı üretmek yerine tespiti ve geri dönüşü doğrulamaktır.)*

---

# 97. ARCore Availability Metric (ARCore Kullanılabilirlik Metriği)

NAVGUARD will measure the fraction of the navigation interval for which valid ARCore tracking was available. *(NAVGUARD navigasyon aralığının geçerli ARCore takibinin mevcut olduğu oranını ölçecektir.)*

```
ARCoreAvailability =
ValidTrackingDuration
───────────────────── × 100
NavigationDuration
```

---

# 98. Tracking Interruption Metrics (Takip Kesintisi Metrikleri)

NAVGUARD may record the number of tracking interruptions. *(NAVGUARD takip kesintilerinin sayısını kaydedebilir.)*

It may record total lost-tracking duration. *(Toplam kayıp takip süresini kaydedebilir.)*

It may record maximum individual interruption duration. *(Maksimum bireysel kesinti süresini kaydedebilir.)*

It may record time required to return to accepted navigation tracking. *(Kabul edilmiş navigasyon takibine dönmek için gereken süreyi kaydedebilir.)*

---

# 99. Tracking Recovery Time (Takip Geri Kazanım Süresi)

A recovery-time metric may be defined as follows. *(Geri kazanım süresi metriği aşağıdaki şekilde tanımlanabilir.)*

```
RecoveryTime =
t_new_segment_accepted
-
t_tracking_lost
```

The final definition will account for the recovery-validation interval. *(Nihai tanım geri kazanım doğrulama aralığını dikkate alacaktır.)*

---

# 100. Tracking Failure Distribution (Takip Başarısızlık Dağılımı)

Formal experiments may summarize tracking interruptions by ARCore failure reason. *(Resmî deneyler takip kesintilerini ARCore başarısızlık nedenine göre özetleyebilir.)*

This will help distinguish environment-related limitations from software integration faults. *(Bu çevre kaynaklı sınırlamaları yazılım entegrasyon hatalarından ayırt etmeye yardımcı olacaktır.)*

---

# 101. ARCore Confidence (ARCore Güveni)

The target system may assign a NAVGUARD-specific confidence value to current ARCore motion information. *(Hedef sistem mevcut ARCore hareket bilgisine NAVGUARD’a özgü güven değeri atayabilir.)*

This value will represent relative measurement trust and will not automatically be interpreted as a calibrated probability. *(Bu değer göreli ölçüm güvenini temsil edecek ve otomatik olarak kalibre edilmiş olasılık şeklinde yorumlanmayacaktır.)*

---

# 102. ARCore Confidence Inputs (ARCore Güven Girdileri)

Candidate inputs include tracking state. *(Aday girdiler takip durumunu içerir.)*

Candidate inputs include tracking failure history. *(Aday girdiler takip başarısızlık geçmişini içerir.)*

Candidate inputs include recent pose continuity. *(Aday girdiler son poz sürekliliğini içerir.)*

Candidate inputs include stationary-drift characteristics. *(Aday girdiler sabit sürüklenme özelliklerini içerir.)*

Candidate inputs include time since tracking recovery. *(Aday girdiler takip geri kazanımından itibaren geçen süreyi içerir.)*

---

# 103. Confidence After Recovery (Geri Kazanımdan Sonra Güven)

ARCore confidence may begin conservatively after a new tracking segment starts. *(ARCore güveni yeni bir takip segmenti başladıktan sonra temkinli bir seviyeden başlayabilir.)*

Confidence may increase after sufficient stable tracking evidence is observed. *(Yeterli kararlı takip kanıtı gözlemlendikten sonra güven artabilir.)*

---

# 104. Fusion Input Gate (Füzyon Girdi Kapısı)

ARCore measurements will enter the fusion engine only after passing authorization and quality gates. *(ARCore ölçümleri yalnızca yetkilendirme ve kalite kapılarını geçtikten sonra füzyon motoruna girecektir.)*

```
ARCore Pose
    ↓
TRACKING?
    │
    ├── No ──► Reject
    ↓ Yes
Valid Segment?
    │
    ├── No ──► Reject
    ↓ Yes
Valid Timestamp?
    │
    ├── No ──► Reject
    ↓ Yes
Pose Continuity?
    │
    ├── No ──► Degrade / Reject
    ↓ Yes
ENU Alignment
    ↓
Fusion Measurement
```

---

# 105. ARCore and PDR Relationship (ARCore ve PDR İlişkisi)

PDR provides step-based pedestrian displacement. *(PDR adım tabanlı yaya yer değiştirmesi sağlar.)*

ARCore provides visual-inertial device-relative displacement. *(ARCore görsel-ataletsel cihaz göreli yer değiştirmesi sağlar.)*

The fusion system will compare and combine these complementary sources rather than selecting one permanently. *(Füzyon sistemi bunlardan birini kalıcı olarak seçmek yerine bu tamamlayıcı kaynakları karşılaştıracak ve birleştirecektir.)*

---

# 106. PDR Remains Available During ARCore Operation (ARCore Çalışırken PDR Kullanılabilir Kalır)

PDR will continue to produce its own baseline trajectory even while ARCore is tracking successfully. *(ARCore başarılı şekilde takip ederken bile PDR kendi temel rotasını üretmeye devam edecektir.)*

This preserves experimental comparison and immediate fallback capability. *(Bu deneysel karşılaştırmayı ve anında geri dönüş yeteneğini korur.)*

---

# 107. No Hard ARCore Position Replacement (Sert ARCore Konum Değiştirmesi Olmaması)

The target system will not simply overwrite the PDR position with every ARCore pose. *(Hedef sistem her ARCore pozunda PDR konumunun üzerine doğrudan yazmayacaktır.)*

ARCore information will be incorporated through the defined fusion model. *(ARCore bilgisi tanımlanmış füzyon modeli üzerinden dahil edilecektir.)*

---

# 108. ARCore and Heading (ARCore ve Yön)

ARCore orientation may provide useful relative rotation information. *(ARCore yönelimi kullanışlı göreli dönüş bilgisi sağlayabilir.)*

It will not automatically replace the true-north Heading Estimation System because standard local ARCore orientation does not itself define an absolute geographic north reference. *(Standart yerel ARCore yönelimi kendi başına mutlak coğrafi kuzey referansı tanımlamadığı için gerçek kuzey Yön Tahmin Sisteminin yerini otomatik olarak almayacaktır.)*

---

# 109. ARCore Relative Yaw (ARCore Göreli Yaw)

Relative ARCore orientation changes may be compared with gyroscope-derived turns as a diagnostic or fusion signal. *(Göreli ARCore yönelim değişiklikleri tanısal veya füzyon sinyali olarak jiroskop kaynaklı dönüşlerle karşılaştırılabilir.)*

The final use of ARCore orientation in heading fusion will depend on measured benefit. *(ARCore yöneliminin yön füzyonundaki nihai kullanımı ölçülen faydaya bağlı olacaktır.)*

---

# 110. ARCore and EKF Boundary (ARCore ve EKF Sınırı)

The ARCore subsystem will produce validated local displacement or pose-derived measurements. *(ARCore alt sistemi doğrulanmış yerel yer değiştirme veya poz kaynaklı ölçümler üretecektir.)*

The EKF will determine how those measurements affect the fused navigation state and covariance. *(EKF bu ölçümlerin füzyonlu navigasyon durumunu ve kovaryansı nasıl etkilediğini belirleyecektir.)*

The ARCore subsystem itself will not modify EKF state directly. *(ARCore alt sistemi EKF durumunu doğrudan değiştirmeyecektir.)*

---

# 111. ARCore Measurement Noise (ARCore Ölçüm Gürültüsü)

ARCore fusion covariance will not be assigned from an arbitrary fixed value before empirical testing. *(ARCore füzyon kovaryansı ampirik testten önce keyfi sabit bir değerden atanmayacaktır.)*

Stationary drift, straight-line error, tracking interruptions, and environment-specific performance will inform the initial measurement-noise model. *(Sabit sürüklenme, düz çizgi hatası, takip kesintileri ve ortama özgü performans ilk ölçüm gürültüsü modelini yönlendirecektir.)*

---

# 112. No Depth API Dependency (Depth API Bağımlılığı Olmaması)

The core NAVGUARD ARCore navigation subsystem does not require the Depth API. *(Temel NAVGUARD ARCore navigasyon alt sistemi Depth API gerektirmez.)*

The Redmi Note 9 Pro will not be assumed to support Depth API merely because the device supports ARCore. *(Redmi Note 9 Pro cihazının yalnızca ARCore desteklediği için Depth API’yi desteklediği varsayılmayacaktır.)*

Depth functionality is outside the minimum navigation requirement. *(Depth işlevi minimum navigasyon gereksiniminin dışındadır.)*

---

# 113. No Geospatial API Dependency (Geospatial API Bağımlılığı Olmaması)

NAVGUARD will not require ARCore Geospatial API for the core GNSS-denied estimator. *(NAVGUARD temel GNSS kesintili tahmin motoru için ARCore Geospatial API gerektirmeyecektir.)*

The global geographic anchor already comes from Android GNSS. *(Global coğrafi çapa zaten Android GNSS’ten gelir.)*

The ARCore role is local relative motion. *(ARCore’un rolü yerel göreli harekettir.)*

---

# 114. No Cloud Anchor Dependency (Cloud Anchor Bağımlılığı Olmaması)

NAVGUARD will not require ARCore Cloud Anchors for core local navigation. *(NAVGUARD temel yerel navigasyon için ARCore Cloud Anchors gerektirmeyecektir.)*

Local session anchors are sufficient for the planned visual-inertial experiments. *(Yerel oturum anchor’ları planlanan görsel-ataletsel deneyler için yeterlidir.)*

---

# 115. Offline Navigation Policy (Çevrimdışı Navigasyon Politikası)

The active local ARCore navigation design will not use a cloud positioning service during each tracking update. *(Aktif yerel ARCore navigasyon tasarımı her takip güncellemesinde bulut konumlandırma hizmeti kullanmayacaktır.)*

ARCore support or installation checks may still depend on Google Play Services for AR and may require connectivity during setup or update processes. *(ARCore destek veya kurulum kontrolleri yine de Google Play Services for AR’a bağlı olabilir ve kurulum veya güncelleme süreçlerinde bağlantı gerektirebilir.)*

The PDR fallback ensures that core NAVGUARD navigation does not depend on ARCore availability. *(PDR geri dönüşü temel NAVGUARD navigasyonunun ARCore kullanılabilirliğine bağımlı olmamasını sağlar.)*

---

# 116. Camera Resource Conflict (Kamera Kaynak Çakışması)

ARCore requires access to the rear camera while tracking. *(ARCore takip sırasında arka kameraya erişim gerektirir.)*

If another NAVGUARD feature also requires direct camera ownership, camera-resource architecture must avoid competing sessions. *(Başka bir NAVGUARD özelliği de doğrudan kamera sahipliği gerektirirse kamera kaynak mimarisi rekabet eden oturumlardan kaçınmalıdır.)*

This interaction will be tested during Android integration. *(Bu etkileşim Android entegrasyonu sırasında test edilecektir.)*

---

# 117. ARCore Logging (ARCore Kaydı)

Formal ARCore sessions will preserve raw pose and tracking-state information. *(Resmî ARCore oturumları ham poz ve takip durumu bilgisini koruyacaktır.)*

Derived ENU displacement will be stored separately from raw ARCore values. *(Türetilmiş ENU yer değiştirmesi ham ARCore değerlerinden ayrı saklanacaktır.)*

---

# 118. Raw ARCore Pose File Candidate (Ham ARCore Poz Dosyası Adayı)

```
raw/
└── arcore_pose.csv
```

This file will preserve the original ARCore coordinate convention. *(Bu dosya orijinal ARCore koordinat kuralını koruyacaktır.)*

---

# 119. ARCore Pose CSV Candidate (ARCore Poz CSV Adayı)

```
sequence,
frame_timestamp_ns,
android_camera_timestamp_ns,
app_elapsed_realtime_ns,
tracking_state,
failure_reason,
tx,
ty,
tz,
qx,
qy,
qz,
qw,
segment_id
```

Quaternion fields in the raw file may retain ARCore’s native `{x, y, z, w}` order if the schema clearly declares that convention. *(Ham dosyadaki quaternion alanları şema bu kuralı açıkça belirtiyorsa ARCore’un doğal `{x, y, z, w}` sırasını koruyabilir.)*

---

# 120. Processed ARCore File Candidate (İşlenmiş ARCore Dosyası Adayı)

```
processed/
└── arcore_navigation_enu.csv
```

This file will contain the validated aligned navigation representation. *(Bu dosya doğrulanmış hizalanmış navigasyon temsilini içerecektir.)*

---

# 121. Processed ARCore Schema (İşlenmiş ARCore Şeması)

```
timestamp_ns_common,
segment_id,
east_relative_m,
north_relative_m,
up_relative_m,
delta_east_m,
delta_north_m,
quality_state,
confidence
```

The transformation version must also be traceable. *(Dönüşüm sürümü de izlenebilir olmalıdır.)*

---

# 122. ARCore Event Log (ARCore Olay Kaydı)

Structured events may include the following values. *(Yapılandırılmış olaylar aşağıdaki değerleri içerebilir.)*

```
ARCORE_AVAILABLE
ARCORE_SESSION_CREATED
ARCORE_TRACKING_STARTED
ARCORE_SEGMENT_STARTED
ARCORE_TRACKING_LOST
ARCORE_TRACKING_RECOVERING
ARCORE_SEGMENT_ENDED
ARCORE_POSE_JUMP_REJECTED
ARCORE_SESSION_PAUSED
ARCORE_SESSION_CLOSED
ARCORE_ERROR
```

All state-changing events will include timestamps. *(Durum değiştiren tüm olaylar zaman damgalarını içerecektir.)*

---

# 123. ARCore Configuration Snapshot (ARCore Yapılandırma Anlık Görüntüsü)

Every formal session should preserve the active ARCore configuration. *(Her resmî oturum aktif ARCore yapılandırmasını korumalıdır.)*

```
arcoreIntegrationVersion
sessionConfig
poseSource
alignmentMethod
segmentStrategy
qualityPolicy
jumpPolicy
timestampMappingVersion
fusionEnabled
```

This enables experimental replay and comparison. *(Bu deneysel replay ve karşılaştırmayı mümkün kılar.)*

---

# 124. ARCore Versioning (ARCore Sürümleme)

A change that affects ARCore-to-ENU numerical output must increment the relevant processing version. *(ARCore-ENU sayısal çıktısını etkileyen bir değişiklik ilgili işleme sürümünü artırmalıdır.)*

Examples include alignment changes, timestamp mapping changes, filtering changes, jump thresholds, and segment policies. *(Örnekler hizalama değişikliklerini, zaman damgası eşleme değişikliklerini, filtreleme değişikliklerini, sıçrama eşiklerini ve segment politikalarını içerir.)*

---

# 125. Raw Data Immutability (Ham Veri Değişmezliği)

Reprocessing ARCore data with a newer alignment algorithm must not overwrite the original raw pose file. *(ARCore verisini daha yeni bir hizalama algoritmasıyla yeniden işlemek orijinal ham poz dosyasının üzerine yazmamalıdır.)*

Multiple processed versions may coexist when useful for research comparison. *(Araştırma karşılaştırması için kullanışlı olduğunda birden fazla işlenmiş sürüm birlikte bulunabilir.)*

---

# 126. ARCore Replay Limitation (ARCore Replay Sınırlaması)

Offline processing of recorded ARCore pose output can reproduce NAVGUARD transformation and fusion calculations. *(Kaydedilmiş ARCore poz çıktısının çevrimdışı işlenmesi NAVGUARD dönüşüm ve füzyon hesaplarını yeniden üretebilir.)*

It does not necessarily reproduce the internal ARCore tracking algorithm itself. *(Bu mutlaka dahili ARCore takip algoritmasının kendisini yeniden üretmez.)*

Google also documents that ARCore dataset playback may produce different trackable timing or pose results across playback runs. *(Google ayrıca ARCore veri seti playback işleminin farklı playback çalışmalarında farklı trackable zamanlaması veya poz sonuçları üretebileceğini belirtir.)*

---

# 127. Deterministic NAVGUARD Postprocessing (Deterministik NAVGUARD Son İşleme)

Given identical stored ARCore poses, alignment parameters, and processing configuration, NAVGUARD’s own ARCore-to-ENU postprocessing should be deterministic. *(Aynı saklanmış ARCore pozları, hizalama parametreleri ve işleme yapılandırması verildiğinde NAVGUARD’ın kendi ARCore-ENU son işlemesi deterministik olmalıdır.)*

---

# 128. ARCore Performance Cost (ARCore Performans Maliyeti)

ARCore uses the camera, motion tracking, native memory, CPU, GPU, and battery resources. *(ARCore kamera, hareket takibi, native bellek, CPU, GPU ve batarya kaynaklarını kullanır.)*

Resource cost must therefore be measured on the Redmi Note 9 Pro rather than assumed negligible. *(Bu nedenle kaynak maliyeti ihmal edilebilir varsayılmak yerine Redmi Note 9 Pro üzerinde ölçülmelidir.)*

---

# 129. Combined Runtime Test (Birleşik Çalışma Zamanı Testi)

The target performance test will run ARCore together with sensor logging, PDR, heading, and on-device AI where available. *(Hedef performans testi ARCore’u sensör kaydı, PDR, yön ve mevcut olduğunda cihaz üzeri yapay zekâyla birlikte çalıştıracaktır.)*

The test will monitor stability, frame timing, CPU, memory, battery, and thermal behavior. *(Test kararlılığı, kare zamanlamasını, CPU’yu, belleği, bataryayı ve termal davranışı izleyecektir.)*

---

# 130. ARCore Frame Processing Principle (ARCore Kare İşleme İlkesi)

NAVGUARD will avoid unnecessary heavy processing on every ARCore frame when the navigation estimator does not require it. *(NAVGUARD navigasyon tahmin motoru gerektirmediğinde her ARCore karesinde gereksiz ağır işlemeden kaçınacaktır.)*

Pose extraction and logging should remain lightweight. *(Poz çıkarma ve kayıt hafif kalmalıdır.)*

---

# 131. ARCore Pause When Unused (Kullanılmadığında ARCore’u Duraklatma)

ARCore will not remain active indefinitely when the application is in a workflow that does not require visual-inertial tracking. *(Uygulama görsel-ataletsel takip gerektirmeyen bir iş akışındayken ARCore süresiz aktif kalmayacaktır.)*

Appropriate session pause behavior will reduce camera and compute resource use. *(Uygun oturum duraklatma davranışı kamera ve hesaplama kaynak kullanımını azaltacaktır.)*

---

# 132. Minimum ARCore Capability (Minimum ARCore Yeteneği)

The minimum ARCore implementation must detect runtime support. *(Minimum ARCore uygulaması çalışma zamanı desteğini tespit etmelidir.)*

It must create and manage an ARCore session. *(Bir ARCore oturumu oluşturmalı ve yönetmelidir.)*

It must read camera tracking state. *(Kamera takip durumunu okumalıdır.)*

It must record valid camera pose while tracking is `TRACKING`. *(Takip `TRACKING` iken geçerli kamera pozunu kaydetmelidir.)*

It must detect tracking loss. *(Takip kaybını tespit etmelidir.)*

It must allow PDR to continue when tracking fails. *(Takip başarısız olduğunda PDR’nin devam etmesine izin vermelidir.)*

---

# 133. Target ARCore Capability (Hedef ARCore Yeteneği)

The target implementation will additionally support anchor-relative local motion. *(Hedef uygulama ayrıca anchor’a göreli yerel hareketi destekleyecektir.)*

It will support validated ARCore-to-ENU alignment. *(Doğrulanmış ARCore-ENU hizalamasını destekleyecektir.)*

It will support ARCore segment management. *(ARCore segment yönetimini destekleyecektir.)*

It will support pose-jump rejection. *(Poz sıçraması reddini destekleyecektir.)*

It will support confidence-aware fusion. *(Güven farkındalıklı füzyonu destekleyecektir.)*

---

# 134. Optional ARCore Enhancements (İsteğe Bağlı ARCore İyileştirmeleri)

Optional enhancements may include more advanced motion-quality estimation. *(İsteğe bağlı iyileştirmeler daha gelişmiş hareket kalite tahminini içerebilir.)*

Optional enhancements may include automatic local-reference renewal. *(İsteğe bağlı iyileştirmeler otomatik yerel referans yenilemeyi içerebilir.)*

Optional enhancements may include improved camera-to-body motion compensation. *(İsteğe bağlı iyileştirmeler geliştirilmiş kamera-vücut hareket telafisini içerebilir.)*

These features must not delay the minimum PDR plus ARCore comparison. *(Bu özellikler minimum PDR artı ARCore karşılaştırmasını geciktirmemelidir.)*

---

# 135. ARCore Non-Goals (ARCore Olmayan Hedefler)

NAVGUARD will not implement a complete visual-inertial SLAM system from scratch. *(NAVGUARD sıfırdan tam bir görsel-ataletsel SLAM sistemi geliştirmeyecektir.)*

NAVGUARD will not use ARCore as a direct latitude-longitude source. *(NAVGUARD ARCore’u doğrudan enlem-boylam kaynağı olarak kullanmayacaktır.)*

NAVGUARD will not require Cloud Anchors. *(NAVGUARD Cloud Anchors gerektirmeyecektir.)*

NAVGUARD will not require Geospatial API. *(NAVGUARD Geospatial API gerektirmeyecektir.)*

NAVGUARD will not require Depth API. *(NAVGUARD Depth API gerektirmeyecektir.)*

---

# 136. ARCore Failure Codes (ARCore Hata Kodları)

```
ARCORE_UNSUPPORTED
ARCORE_INSTALL_REQUIRED
ARCORE_INSTALL_FAILED
ARCORE_CAMERA_PERMISSION_DENIED
ARCORE_SESSION_CREATION_FAILED
ARCORE_CAMERA_UNAVAILABLE
ARCORE_TRACKING_LOST
ARCORE_INSUFFICIENT_FEATURES
ARCORE_INSUFFICIENT_LIGHT
ARCORE_EXCESSIVE_MOTION
ARCORE_BAD_STATE
ARCORE_POSE_INVALID
ARCORE_TIMESTAMP_INVALID
ARCORE_ALIGNMENT_INVALID
ARCORE_POSE_JUMP
ARCORE_SEGMENT_INVALID
```

These project-level codes may wrap official ARCore failure states. *(Bu proje seviyesinde kodlar resmî ARCore başarısızlık durumlarını kapsayabilir.)*

---

# 137. Critical Failure Principle (Kritik Hata İlkesi)

An ARCore failure is not automatically a NAVGUARD navigation failure. *(Bir ARCore hatası otomatik olarak NAVGUARD navigasyon hatası değildir.)*

If PDR and heading remain functional, NAVGUARD must continue in degraded fallback mode. *(PDR ve yön çalışabilir kalırsa NAVGUARD bozulmuş geri dönüş modunda devam etmelidir.)*

---

# 138. Configuration C Definition (Yapılandırma C Tanımı)

Configuration C represents Configuration A plus validated ARCore relative tracking while preserving Configuration A's deterministic step detector, baseline step-length policy, and baseline true-north heading policy. Configuration B's improved/fused heading is not enabled. *(Configuration C, Configuration A'nın deterministic step detector, baseline step-length policy ve baseline true-north heading policy'sini korurken Configuration A'ya doğrulanmış ARCore relative tracking ekler. Configuration B'nin improved/fused heading'i etkinleştirilmez.)*

The ARCore alignment design requires a validated true-north reference, but it does not require Configuration B's improved/fused heading method. Configuration A's validated baseline heading may provide the alignment reference. *(ARCore alignment tasarımı doğrulanmış bir true-north reference gerektirir ancak Configuration B'nin improved/fused heading yöntemini zorunlu kılmaz. Alignment reference Configuration A'nın doğrulanmış baseline heading'i tarafından sağlanabilir.)*

If formal ARCore integration requires the minimum EKF or another integration scaffold, that dependency must be explicitly identified in the frozen Configuration C profile and must not silently enable improved heading, Motion AI, learned step length, or full Configuration D behavior. *(Formal ARCore entegrasyonu minimum EKF veya başka bir integration scaffold gerektirirse bu dependency frozen Configuration C profilinde açıkça tanımlanmalı ve improved heading, Motion AI, learned step length veya tam Configuration D davranışını sessizce etkinleştirmemelidir.)*

---

# 139. ARCore Ablation Comparison (ARCore Ablation Karşılaştırması)

The preferred ARCore contribution test will compare Configuration A behavior with ARCore disabled against the same step, step-length, and baseline-heading policies with validated ARCore relative tracking enabled. *(Tercih edilen ARCore katkı testi ARCore devre dışıyken Configuration A davranışını, aynı step, step-length ve baseline-heading politikaları korunarak validated ARCore relative tracking etkinleştirilmiş davranışla karşılaştıracaktır.)*

```
Configuration A behavior with ARCore disabled
          versus
the same step, step-length, and baseline-heading policies with validated ARCore relative tracking enabled
```

This isolates the effect of validated visual-inertial displacement as much as practical without inheriting Configuration B heading behavior. *(Bu, Configuration B heading davranışını miras almadan validated visual-inertial displacement etkisini pratik olarak mümkün olduğunca izole eder.)*

---

# 140. ARCore Evaluation Metrics (ARCore Değerlendirme Metrikleri)

Primary ARCore-specific metrics will include tracking availability. *(Temel ARCore’a özgü metrikler takip kullanılabilirliğini içerecektir.)*

They will include stationary drift. *(Sabit sürüklenmeyi içerecektir.)*

They will include distance or displacement error. *(Mesafe veya yer değiştirme hatasını içerecektir.)*

They will include tracking interruption count and duration. *(Takip kesintisi sayısını ve süresini içerecektir.)*

They will include tracking recovery time. *(Takip geri kazanım süresini içerecektir.)*

They will include downstream NAVGUARD position-error improvement. *(Aşağı akış NAVGUARD konum hata iyileştirmesini içerecektir.)*

---

# 141. PDR-Level Success Criterion (PDR Seviyesinde Başarı Kriteri)

ARCore integration will be considered useful only if it produces measurable navigation benefit or robustness relative to the comparable non-ARCore configuration. *(ARCore entegrasyonu yalnızca karşılaştırılabilir ARCore’suz yapılandırmaya göre ölçülebilir navigasyon faydası veya dayanıklılık üretirse kullanışlı kabul edilecektir.)*

The project will not claim ARCore improvement merely because integration technically works. *(Proje yalnızca entegrasyon teknik olarak çalıştığı için ARCore iyileştirmesi iddia etmeyecektir.)*

---

# 142. Environment-Specific Reporting (Ortama Özgü Raporlama)

ARCore performance will be reported by relevant environmental condition where possible. *(ARCore performansı mümkün olduğunda ilgili çevresel koşula göre raporlanacaktır.)*

A visually rich outdoor route and a low-texture indoor route must not be assumed to provide equivalent tracking quality. *(Görsel açıdan zengin dış mekân rotası ile düşük dokulu iç mekân rotasının eşdeğer takip kalitesi sağladığı varsayılmamalıdır.)*

---

# 143. No Hidden Failed Sessions (Gizli Başarısız Oturum Olmaması)

ARCore sessions that fail because of poor tracking will remain part of the experiment record. *(Düşük takip nedeniyle başarısız olan ARCore oturumları deney kaydının parçası olarak kalacaktır.)*

Failed tracking is itself relevant evidence about system robustness. *(Başarısız takip sistem dayanıklılığı hakkında başlı başına ilgili kanıttır.)*

---

# 144. Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kararlar)

ARCore will be an optional NAVGUARD navigation enhancement. *(ARCore isteğe bağlı bir NAVGUARD navigasyon iyileştirmesi olacaktır.)*

The application will preserve PDR functionality when ARCore is unavailable. *(Uygulama ARCore kullanılamadığında PDR işlevini koruyacaktır.)*

Only valid `TRACKING` poses may become ARCore navigation measurements. *(Yalnızca geçerli `TRACKING` pozları ARCore navigasyon ölçümü haline gelebilir.)*

`PAUSED` poses will not be used for active displacement estimation. *(`PAUSED` pozları aktif yer değiştirme tahmini için kullanılmayacaktır.)*

---

# 145. Additional Frozen Decisions (Ek Sabitlenmiş Kararlar)

Raw ARCore world coordinates will not be treated as immutable global coordinates. *(Ham ARCore dünya koordinatları değişmez global koordinatlar olarak ele alınmayacaktır.)*

NAVGUARD will use local anchor-relative or equivalent validated local tracking. *(NAVGUARD yerel anchor’a göreli veya eşdeğer doğrulanmış yerel takip kullanacaktır.)*

ARCore motion will require explicit ARCore-to-ENU alignment. *(ARCore hareketi açık ARCore-ENU hizalaması gerektirecektir.)*

ARCore X, Y, and Z will not be hard-coded directly to East, North, and Up. *(ARCore X, Y ve Z doğrudan Doğu, Kuzey ve Yukarıya hard-code edilmeyecektir.)*

---

# 146. Further Frozen Decisions (Diğer Sabitlenmiş Kararlar)

Tracking loss will immediately stop ARCore fusion measurements without stopping baseline PDR. *(Takip kaybı temel PDR’yi durdurmadan ARCore füzyon ölçümlerini hemen durduracaktır.)*

A large tracking gap will normally start a new ARCore segment. *(Büyük bir takip boşluğu normalde yeni bir ARCore segmenti başlatacaktır.)*

The first pose after tracking recovery will not automatically be differenced against the final pre-loss pose. *(Takip geri kazanımından sonraki ilk poz otomatik olarak son kayıp öncesi pozla fark alınmayacaktır.)*

Pose jumps will be rejected or degraded rather than forcing navigation-state jumps. *(Poz sıçramaları navigasyon durumu sıçramalarına zorlamak yerine reddedilecek veya düşük güvenli hale getirilecektir.)*

---

# 147. Timestamp Decision (Zaman Damgası Kararı)

ARCore `Frame.getTimestamp()` will not be assumed to share the Android sensor monotonic time base until physical validation proves the mapping. *(ARCore `Frame.getTimestamp()` değerinin fiziksel doğrulama eşlemeyi kanıtlayana kadar Android sensör monotonik zaman tabanını paylaştığı varsayılmayacaktır.)*

The ARCore-to-common-clock mapping will be explicitly measured and documented. *(ARCore-ortak saat eşlemesi açıkça ölçülecek ve dokümante edilecektir.)*

---

# 148. Scope Decisions (Kapsam Kararları)

Cloud Anchors are not required. *(Cloud Anchors gerekli değildir.)*

Geospatial API is not required. *(Geospatial API gerekli değildir.)*

Depth API is not required. *(Depth API gerekli değildir.)*

A custom full visual-inertial SLAM implementation is not required. *(Özel tam görsel-ataletsel SLAM uygulaması gerekli değildir.)*

---

# 149. Decisions Pending Physical Measurement (Fiziksel Ölçüm Bekleyen Kararlar)

The final ARCore-to-ENU alignment procedure remains pending device experiments. *(Nihai ARCore-ENU hizalama prosedürü cihaz deneylerini beklemektedir.)*

The final ARCore pose filtering remains pending measured camera-motion behavior. *(Nihai ARCore poz filtrelemesi ölçülmüş kamera hareketi davranışını beklemektedir.)*

The final pose-jump threshold remains pending pedestrian measurements. *(Nihai poz sıçrama eşiği yaya ölçümlerini beklemektedir.)*

The final recovery-quarantine duration remains pending tracking-loss experiments. *(Nihai geri kazanım karantina süresi takip kaybı deneylerini beklemektedir.)*

The final segment-renewal policy remains pending long-route experiments. *(Nihai segment yenileme politikası uzun rota deneylerini beklemektedir.)*

---

# 150. Further Pending Decisions (Diğer Bekleyen Kararlar)

The final ARCore confidence model remains pending experimental calibration. *(Nihai ARCore güven modeli deneysel kalibrasyonu beklemektedir.)*

The final ARCore measurement covariance remains pending stationary and movement error analysis. *(Nihai ARCore ölçüm kovaryansı sabit ve hareket hata analizini beklemektedir.)*

The final timestamp-domain mapping remains pending Device Capability Audit measurements. *(Nihai zaman damgası alanı eşlemesi Cihaz Yetenek Denetimi ölçümlerini beklemektedir.)*

---

# 151. Runtime Acceptance Criteria (Çalışma Zamanı Kabul Kriterleri)

The physical Redmi Note 9 Pro must pass the runtime ARCore support check. *(Fiziksel Redmi Note 9 Pro çalışma zamanı ARCore destek kontrolünü geçmelidir.)*

A compatible ARCore session must be created successfully. *(Uyumlu bir ARCore oturumu başarıyla oluşturulmalıdır.)*

The rear camera must operate correctly during the session. *(Arka kamera oturum sırasında doğru çalışmalıdır.)*

The camera must enter `TRACKING` under suitable conditions. *(Kamera uygun koşullar altında `TRACKING` durumuna girmelidir.)*

---

# 152. Pose Acceptance Criteria (Poz Kabul Kriterleri)

Valid pose translation must be readable in metres. *(Geçerli poz ötelemesi metre cinsinden okunabilir olmalıdır.)*

Valid pose rotation must be converted correctly into the NAVGUARD quaternion convention. *(Geçerli poz dönüşü NAVGUARD quaternion kuralına doğru şekilde dönüştürülmelidir.)*

A `PAUSED` camera pose must not update ARCore navigation displacement. *(Bir `PAUSED` kamera pozu ARCore navigasyon yer değiştirmesini güncellememelidir.)*

---

# 153. Alignment Acceptance Criteria (Hizalama Kabul Kriterleri)

A controlled physical movement toward known East must produce positive East displacement after ARCore-to-ENU alignment. *(Bilinen Doğu yönüne kontrollü fiziksel hareket ARCore-ENU hizalamasından sonra pozitif Doğu yer değiştirmesi üretmelidir.)*

A controlled movement toward known North must produce positive North displacement. *(Bilinen Kuzey yönüne kontrollü hareket pozitif Kuzey yer değiştirmesi üretmelidir.)*

Axis reversal or sign errors must be detected by automated or physical validation tests. *(Eksen tersliği veya işaret hataları otomatik veya fiziksel doğrulama testleriyle tespit edilmelidir.)*

---

# 154. Tracking-Loss Acceptance Criteria (Takip Kaybı Kabul Kriterleri)

Tracking degradation must be detected through ARCore tracking state. *(Takip bozulması ARCore takip durumu üzerinden tespit edilmelidir.)*

The reported tracking failure reason must be logged when available. *(Raporlanan takip başarısızlık nedeni mevcut olduğunda kaydedilmelidir.)*

ARCore measurements must stop entering fusion while tracking is invalid. *(Takip geçersizken ARCore ölçümleri füzyona girmeyi durdurmalıdır.)*

PDR must continue during the same interval. *(PDR aynı aralık sırasında devam etmelidir.)*

---

# 155. Recovery Acceptance Criteria (Geri Kazanım Kabul Kriterleri)

Tracking recovery must not create a false pedestrian displacement jump. *(Takip geri kazanımı yanlış yaya yer değiştirme sıçraması oluşturmamalıdır.)*

A new ARCore segment must be created when the frozen recovery policy requires it. *(Sabitlenmiş geri kazanım politikası gerektirdiğinde yeni bir ARCore segmenti oluşturulmalıdır.)*

Historical trajectory data must remain unchanged. *(Geçmiş rota verisi değişmeden kalmalıdır.)*

---

# 156. Experimental Acceptance Criteria (Deneysel Kabul Kriterleri)

ARCore stationary drift must be measured. *(ARCore sabit durum sürüklenmesi ölçülmelidir.)*

ARCore straight-line displacement must be evaluated. *(ARCore düz çizgi yer değiştirmesi değerlendirilmelidir.)*

ARCore tracking degradation must be tested under at least one controlled ordinary adverse condition. *(ARCore takip bozulması en az bir kontrollü sıradan olumsuz koşul altında test edilmelidir.)*

ARCore-enabled PDR must be quantitatively compared with the corresponding non-ARCore configuration. *(ARCore etkin PDR karşılık gelen ARCore’suz yapılandırmayla nicel olarak karşılaştırılmalıdır.)*

---

# 157. Source Basis (Kaynak Temeli)

The Redmi Note 9 Pro ARCore compatibility baseline is based on the current official Google ARCore supported-device list. *(Redmi Note 9 Pro ARCore uyumluluk temeli güncel resmî Google ARCore desteklenen cihaz listesine dayanmaktadır.)*

The AR Optional architecture, support check, and installation flow are based on the current official ARCore Android integration documentation. *(AR Optional mimarisi, destek kontrolü ve kurulum akışı güncel resmî ARCore Android entegrasyon dokümantasyonuna dayanmaktadır.)*

The ARCore pose coordinate and persistence rules are based on the official ARCore `Pose` and anchor documentation. *(ARCore poz koordinat ve kalıcılık kuralları resmî ARCore `Pose` ve anchor dokümantasyonuna dayanmaktadır.)*

The camera tracking-state and pose-validity rules are based on the official ARCore `Camera` and `TrackingState` documentation. *(Kamera takip durumu ve poz geçerlilik kuralları resmî ARCore `Camera` ve `TrackingState` dokümantasyonuna dayanmaktadır.)*

The tracking-failure categories are based on the official ARCore `TrackingFailureReason` documentation. *(Takip başarısızlık kategorileri resmî ARCore `TrackingFailureReason` dokümantasyonuna dayanmaktadır.)*

The ARCore frame timestamp and Android sensor-pose rules are based on the official ARCore `Frame` documentation. *(ARCore kare zaman damgası ve Android sensör pozu kuralları resmî ARCore `Frame` dokümantasyonuna dayanmaktadır.)*

---

# 158. Final ARCore Architecture Statement (Nihai ARCore Mimarisi Bildirimi)

**NAVGUARD will use ARCore as an optional visual-inertial relative-motion source that supplements step-based PDR during GNSS-denied navigation.** *(NAVGUARD ARCore’u GNSS kesintili navigasyon sırasında adım tabanlı PDR’yi tamamlayan isteğe bağlı görsel-ataletsel göreli hareket kaynağı olarak kullanacaktır.)*

**ARCore camera poses will be used only while motion tracking is valid, and poses reported during paused or invalid tracking will never be treated as reliable navigation measurements.** *(ARCore kamera pozları yalnızca hareket takibi geçerliyken kullanılacak ve duraklatılmış veya geçersiz takip sırasında raporlanan pozlar hiçbir zaman güvenilir navigasyon ölçümleri olarak ele alınmayacaktır.)*

**Because ARCore world coordinates may change as environmental understanding improves, NAVGUARD will use local anchor-relative or equivalently validated segmented motion rather than assuming an immutable global ARCore coordinate system.** *(ARCore dünya koordinatları çevre anlayışı geliştikçe değişebildiği için NAVGUARD değişmez global ARCore koordinat sistemi varsaymak yerine yerel anchor’a göreli veya eşdeğer doğrulanmış segmentli hareket kullanacaktır.)*

**Every ARCore motion measurement will be explicitly aligned into the NAVGUARD ENU coordinate frame before it can contribute to sensor fusion.** *(Her ARCore hareket ölçümü sensör füzyonuna katkıda bulunmadan önce açıkça NAVGUARD ENU koordinat çerçevesine hizalanacaktır.)*

**Tracking loss, camera failure, insufficient visual features, insufficient light, or other ARCore degradation will disable ARCore measurement updates without disabling PDR navigation.** *(Takip kaybı, kamera hatası, yetersiz görsel özellikler, yetersiz ışık veya diğer ARCore bozulmaları PDR navigasyonunu devre dışı bırakmadan ARCore ölçüm güncellemelerini devre dışı bırakacaktır.)*

**After a meaningful tracking interruption, NAVGUARD will avoid connecting pre-loss and post-recovery ARCore poses directly and will instead establish a controlled new local tracking segment when required.** *(Anlamlı bir takip kesintisinden sonra NAVGUARD kayıp öncesi ve geri kazanım sonrası ARCore pozlarını doğrudan bağlamaktan kaçınacak ve gerektiğinde kontrollü yeni bir yerel takip segmenti oluşturacaktır.)*

**ARCore value will ultimately be determined by measured reduction in navigation drift and increased robustness compared with otherwise matched PDR configurations, not merely by successful technical integration.** *(ARCore’un değeri yalnızca başarılı teknik entegrasyonla değil, sonuçta diğer açılardan eşleştirilmiş PDR yapılandırmalarına kıyasla ölçülen navigasyon sürüklenmesi azalması ve artan dayanıklılıkla belirlenecektir.)*

---

# 159. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development ARCore Visual-Inertial Tracking Architecture Completed *(Doküman Durumu: Geliştirme Öncesi ARCore Görsel-Ataletsel Takip Mimarisi Tamamlandı)*

**ARCore Role:** Optional Relative Visual-Inertial Motion Source *(ARCore Rolü: İsteğe Bağlı Göreli Görsel-Ataletsel Hareket Kaynağı)*

**Primary Platform:** Xiaomi Redmi Note 9 Pro *(Temel Platform: Xiaomi Redmi Note 9 Pro)*

**Published ARCore Compatibility:** Supported *(Yayınlanmış ARCore Uyumluluğu: Destekleniyor)*

**Application Strategy:** AR Optional *(Uygulama Stratejisi: AR Optional)*

**Primary Pose Source:** Physical Camera Pose / Validated Sensor-Pose Alternative *(Temel Poz Kaynağı: Fiziksel Kamera Pozu / Doğrulanmış Sensör Pozu Alternatifi)*

**Pose Units:** Metres + Quaternion *(Poz Birimleri: Metre + Quaternion)*

**Valid Tracking State for Navigation:** `TRACKING` *(Navigasyon İçin Geçerli Takip Durumu: `TRACKING`)*

**PAUSED Pose Policy:** Reject from Navigation *(PAUSED Poz Politikası: Navigasyondan Reddet)*

**World Coordinate Policy:** Not Treated as Immutable Global Coordinates *(Dünya Koordinatı Politikası: Değişmez Global Koordinatlar Olarak Ele Alınmaz)*

**Persistent Local Reference:** Anchor-Relative / Segmented *(Kalıcı Yerel Referans: Anchor’a Göreli / Segmentli)*

**Navigation Coordinate Output:** ENU Metres *(Navigasyon Koordinat Çıktısı: ENU Metre)*

**ARCore-to-ENU Alignment:** Mandatory *(ARCore-ENU Hizalaması: Zorunlu)*

**Tracking-Loss Fallback:** PDR Continues *(Takip Kaybı Geri Dönüşü: PDR Devam Eder)*

**Tracking Recovery:** Controlled New Segment When Required *(Takip Geri Kazanımı: Gerektiğinde Kontrollü Yeni Segment)*

**Cloud Anchors:** Not Required *(Cloud Anchors: Gerekli Değil)*

**Geospatial API:** Not Required *(Geospatial API: Gerekli Değil)*

**Depth API:** Not Required *(Depth API: Gerekli Değil)*

**Timestamp Mapping:** Physical Validation Required *(Zaman Damgası Eşlemesi: Fiziksel Doğrulama Gerekli)*

**Stationary Drift Threshold:** Pending Measurement *(Sabit Sürüklenme Eşiği: Ölçüm Bekleniyor)*

**Pose-Jump Threshold:** Pending Measurement *(Poz Sıçrama Eşiği: Ölçüm Bekleniyor)*

**Fusion Measurement Covariance:** Pending Experimental Calibration *(Füzyon Ölçüm Kovaryansı: Deneysel Kalibrasyon Bekleniyor)*

**Next Documentation Item:** 20 — Sensor Confidence & Quality Engine *(Sonraki Dokümantasyon Öğesi: 20 — Sensör Güven ve Kalite Motoru)*
