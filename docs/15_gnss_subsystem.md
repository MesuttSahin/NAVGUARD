# 15 — GNSS Subsystem (GNSS Alt Sistemi)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the architecture, acquisition method, data model, quality-control strategy, satellite diagnostics, initial-anchor procedure, ground-truth behavior, estimator authorization, GNSS-denied evaluation behavior, recovery process, and failure handling of the NAVGUARD GNSS subsystem. *(Bu doküman, NAVGUARD GNSS alt sisteminin mimarisini, veri toplama yöntemini, veri modelini, kalite kontrol stratejisini, uydu tanısını, başlangıç çapası prosedürünü, gerçek referans davranışını, tahmin motoru yetkilendirmesini, GNSS kesintili değerlendirme davranışını, geri kazanım sürecini ve hata yönetimini tanımlar.)*

GNSS serves several different purposes in NAVGUARD and those purposes must remain explicitly separated. *(GNSS, NAVGUARD içerisinde birden fazla farklı amaca hizmet eder ve bu amaçlar açıkça ayrı tutulmalıdır.)*

GNSS is simultaneously a global initialization source, a normal-navigation measurement source, an experimental ground-truth source, and a recovery reference. *(GNSS aynı anda global başlatma kaynağı, normal navigasyon ölçüm kaynağı, deneysel gerçek referans kaynağı ve geri kazanım referansıdır.)*

---

# 2. Primary GNSS Roles (Temel GNSS Rolleri)

NAVGUARD will use GNSS for four primary roles. *(NAVGUARD GNSS’i dört temel rol için kullanacaktır.)*

The first role is establishing the initial global WGS84 position anchor. *(Birinci rol başlangıç global WGS84 konum çapasını oluşturmaktır.)*

The second role is providing position information during normal GNSS-enabled navigation. *(İkinci rol normal GNSS etkin navigasyon sırasında konum bilgisi sağlamaktır.)*

The third role is independently recording ground truth during controlled GNSS-denied Evaluation Mode. *(Üçüncü rol kontrollü GNSS kesintili Değerlendirme Modunda bağımsız gerçek referans kaydetmektir.)*

The fourth role is providing a validated geographic reference during GNSS recovery and relocalization. *(Dördüncü rol GNSS geri kazanımı ve yeniden konumlandırma sırasında doğrulanmış coğrafi referans sağlamaktır.)*

---

# 3. GNSS Is Not a Single Data Path (GNSS Tek Bir Veri Hattı Değildir)

NAVGUARD will not implement GNSS as one unrestricted position stream directly connected to every navigation component. *(NAVGUARD GNSS’i her navigasyon bileşenine doğrudan bağlı tek ve sınırsız bir konum akışı olarak geliştirmeyecektir.)*

The physical GNSS acquisition stream will be separated from estimator authorization. *(Fiziksel GNSS veri toplama akışı tahmin motoru yetkilendirmesinden ayrılacaktır.)*

This separation is required to preserve experimental integrity during simulated GNSS outages. *(Bu ayrım simüle edilmiş GNSS kesintileri sırasında deneysel bütünlüğü korumak için gereklidir.)*

---

# 4. GNSS Subsystem Architecture (GNSS Alt Sistemi Mimarisi)

```
Android GNSS Hardware
        │
        ▼
LocationManager
GPS_PROVIDER
        │
        ▼
Native GnssManager
        │
        ├──────────────► Raw GNSS Logger
        │
        ├──────────────► GNSS Quality Engine
        │
        ├──────────────► Ground Truth Stream
        │
        └──────────────► Estimator Authorization Gate
                              │
                       ┌──────┴──────┐
                       │             │
                    ALLOWED       BLOCKED
                       │             │
                       ▼             ▼
                  Estimator       No Access
```

The logger path must remain independent from estimator authorization. *(Logger hattı tahmin motoru yetkilendirmesinden bağımsız kalmalıdır.)*

---

# 5. Authoritative Android GNSS Interface (Ana Android GNSS Arayüzü)

Android `LocationManager` will be the authoritative native location interface for formal NAVGUARD GNSS acquisition. *(Android `LocationManager`, resmî NAVGUARD GNSS veri toplama için ana native konum arayüzü olacaktır.)*

NAVGUARD will explicitly select `LocationManager.GPS_PROVIDER` for the formal GNSS stream. *(NAVGUARD resmî GNSS akışı için açıkça `LocationManager.GPS_PROVIDER` kullanacaktır.)*

Android defines `GPS_PROVIDER` as the standard GNSS location provider and states that it determines position using GNSS satellites when available. *(Android `GPS_PROVIDER` değerini standart GNSS konum sağlayıcısı olarak tanımlar ve mevcut olduğunda konumu GNSS uydularını kullanarak belirttiğini belirtir.)*

---

# 6. Why GPS_PROVIDER Is Explicitly Selected (GPS_PROVIDER’ın Neden Açıkça Seçildiği)

The formal ground-truth stream must represent satellite-based GNSS positioning rather than an opaque combination of network and satellite sources. *(Resmî gerçek referans akışı, ağ ve uydu kaynaklarının belirsiz bir birleşimi yerine uydu tabanlı GNSS konumlandırmayı temsil etmelidir.)*

Android’s fused provider may combine several location sources, whereas `GPS_PROVIDER` explicitly represents GNSS satellite positioning. *(Android’in fused provider’ı birden fazla konum kaynağını birleştirebilirken `GPS_PROVIDER` açıkça GNSS uydu konumlandırmasını temsil eder.)*

NAVGUARD will therefore not use the fused provider as the authoritative formal GNSS ground-truth source. *(Bu nedenle NAVGUARD fused provider’ı resmî ana GNSS gerçek referans kaynağı olarak kullanmayacaktır.)*

---

# 7. GPS Naming Clarification (GPS Adlandırma Açıklaması)

The Android constant is named `GPS_PROVIDER`, but NAVGUARD documentation will generally use the broader term GNSS. *(Android sabiti `GPS_PROVIDER` olarak adlandırılmıştır ancak NAVGUARD dokümantasyonu genel olarak daha geniş GNSS terimini kullanacaktır.)*

This distinction is important because modern Android GNSS receivers may observe multiple satellite constellations rather than GPS alone. *(Bu ayrım önemlidir çünkü modern Android GNSS alıcıları yalnızca GPS yerine birden fazla uydu takımyıldızını gözlemleyebilir.)*

---

# 8. Location Permission Requirement (Konum İzni Gereksinimi)

Formal NAVGUARD GNSS operation will require precise location access. *(Resmî NAVGUARD GNSS çalışması hassas konum erişimi gerektirecektir.)*

Android may provide only coarse and obfuscated results when an application lacks fine-location authorization. *(Bir uygulama hassas konum yetkisine sahip olmadığında Android yalnızca kaba ve gizlenmiş sonuçlar sağlayabilir.)*

NAVGUARD will therefore require `ACCESS_FINE_LOCATION` for formal GNSS experiments. *(Bu nedenle NAVGUARD resmî GNSS deneyleri için `ACCESS_FINE_LOCATION` gerektirecektir.)*

Detailed permission UX and privacy behavior will be defined in **32 — Permissions, Privacy & Security**. *(Ayrıntılı izin UX’i ve gizlilik davranışı **32 — Permissions, Privacy & Security** bölümünde tanımlanacaktır.)*

---

# 9. Foreground GNSS Operation (Ön Plan GNSS Çalışması)

Formal NAVGUARD experiments will initially acquire GNSS while the application is actively running in the foreground. *(Resmî NAVGUARD deneyleri başlangıçta uygulama aktif olarak ön planda çalışırken GNSS verisi toplayacaktır.)*

Continuous unrestricted background GNSS acquisition is not required for the minimum research prototype. *(Sürekli sınırsız arka plan GNSS veri toplama minimum araştırma prototipi için gerekli değildir.)*

This keeps the permission and lifecycle architecture proportional to the project’s controlled experiment workflow. *(Bu izin ve yaşam döngüsü mimarisini projenin kontrollü deney iş akışıyla orantılı tutar.)*

---

# 10. Native GNSS Ownership (Native GNSS Sahipliği)

One dedicated Kotlin GNSS component will own formal Android GNSS subscriptions. *(Bir özel Kotlin GNSS bileşeni resmî Android GNSS aboneliklerinin sahibi olacaktır.)*

Flutter screens will not independently request physical location updates. *(Flutter ekranları bağımsız şekilde fiziksel konum güncellemeleri istemeyecektir.)*

The GNSS diagnostic interface, live-navigation screen, and logger will consume the same authoritative GNSS acquisition stream. *(GNSS tanı arayüzü, canlı navigasyon ekranı ve logger aynı ana GNSS veri toplama akışını kullanacaktır.)*

---

# 11. Proposed Native GNSS Components (Önerilen Native GNSS Bileşenleri)

```
GnssManagerService
GnssStatusService
GnssQualityEvaluator
GnssAnchorManager
GnssGroundTruthRouter
GnssEstimatorGate
GnssRecoveryManager
```

These names are logical responsibilities rather than mandatory final class names. *(Bu adlar zorunlu nihai sınıf adları yerine mantıksal sorumlulukları temsil eder.)*

---

# 12. GNSS Acquisition Lifecycle (GNSS Veri Toplama Yaşam Döngüsü)

GNSS acquisition will start only when the active workflow requires GNSS information. *(GNSS veri toplama yalnızca aktif iş akışı GNSS bilgisi gerektirdiğinde başlayacaktır.)*

GNSS acquisition will normally start before initial anchor acceptance. *(GNSS veri toplama normalde başlangıç çapası kabulünden önce başlayacaktır.)*

During Evaluation Mode, acquisition will continue after estimator GNSS access is blocked. *(Değerlendirme Modunda tahmin motoru GNSS erişimi engellendikten sonra veri toplama devam edecektir.)*

GNSS acquisition will be stopped during controlled session shutdown when no longer required. *(GNSS veri toplama artık gerekli olmadığında kontrollü oturum kapanışı sırasında durdurulacaktır.)*

---

# 13. GNSS Acquisition State Model (GNSS Veri Toplama Durum Modeli)

```
STOPPED
STARTING
WAITING_FOR_FIX
ACTIVE
DEGRADED
DISABLED
ERROR
```

The GNSS acquisition state is separate from the global NAVGUARD navigation mode. *(GNSS veri toplama durumu global NAVGUARD navigasyon modundan ayrıdır.)*

For example, GNSS acquisition may remain `ACTIVE` while NAVGUARD Mode prevents the estimator from receiving GNSS. *(Örneğin NAVGUARD Modu tahmin motorunun GNSS almasını engellerken GNSS veri toplama `ACTIVE` durumda kalabilir.)*

---

# 14. GNSS Location Record (GNSS Konum Kaydı)

Every accepted Android GNSS callback will be converted into a NAVGUARD domain record without destroying the original reported values. *(Kabul edilen her Android GNSS callback’i orijinal raporlanan değerleri bozmadan NAVGUARD domain kaydına dönüştürülecektir.)*

```
GnssSample
- elapsedRealtimeNs
- wallClockTimeMs
- sequenceNumber
- provider
- latitudeDeg
- longitudeDeg
- horizontalAccuracyM
- altitudeM
- altitudeAvailable
- verticalAccuracyM
- verticalAccuracyAvailable
- speedMps
- speedAvailable
- speedAccuracyMps
- speedAccuracyAvailable
- bearingDeg
- bearingAvailable
- bearingAccuracyDeg
- bearingAccuracyAvailable
```

---

# 15. Authoritative GNSS Timestamp (Ana GNSS Zaman Damgası)

`Location.getElapsedRealtimeNanos()` will be the authoritative within-session timestamp for GNSS fixes. *(`Location.getElapsedRealtimeNanos()`, GNSS fix’leri için oturum içindeki ana zaman damgası olacaktır.)*

Android defines this timestamp as nanoseconds of elapsed realtime since system boot and states that it can be used to reliably order locations because the clock is monotonic. *(Android bu zaman damgasını sistem açılışından itibaren geçen zamanın nanosaniyesi olarak tanımlar ve saat monotonik olduğu için konumları güvenilir şekilde sıralamak amacıyla kullanılabileceğini belirtir.)*

All locations generated by `LocationManager` are guaranteed to contain valid elapsed-realtime information. *(`LocationManager` tarafından üretilen tüm konumların geçerli elapsed-realtime bilgisi içermesi garanti edilir.)*

---

# 16. GNSS Wall-Clock Timestamp (GNSS Duvar Saati Zaman Damgası)

`Location.getTime()` may additionally be retained as human-readable epoch time. *(`Location.getTime()` ayrıca insan tarafından okunabilir epoch zamanı olarak korunabilir.)*

Wall-clock time will not replace elapsed realtime for sensor synchronization. *(Duvar saati zamanı sensör senkronizasyonu için elapsed realtime’ın yerini almayacaktır.)*

This preserves compatibility with the common timing model defined in **13 — Sensor Timing, Synchronization & Preprocessing**. *(Bu, **13 — Sensor Timing, Synchronization & Preprocessing** içerisinde tanımlanan ortak zamanlama modeliyle uyumluluğu korur.)*

---

# 17. GNSS Fix Age (GNSS Fix Yaşı)

NAVGUARD will calculate the age of every GNSS fix relative to the current monotonic time. *(NAVGUARD her GNSS fix’inin yaşını mevcut monotonik zamana göre hesaplayacaktır.)*

```
fixAge =
currentElapsedRealtimeNs
-
locationElapsedRealtimeNs
```

A stale GNSS location must not be accepted as a fresh initial anchor merely because it is the latest object available to the application. *(Eski bir GNSS konumu yalnızca uygulamada mevcut en son nesne olduğu için yeni bir başlangıç çapası olarak kabul edilmemelidir.)*

---

# 18. GNSS Horizontal Accuracy (GNSS Yatay Doğruluğu)

Android `Location.getAccuracy()` reports an estimated horizontal accuracy radius in metres at the 68th-percentile confidence level when horizontal accuracy is available. *(Android `Location.getAccuracy()`, yatay doğruluk mevcut olduğunda yüzde 68 güven seviyesindeki tahmini yatay doğruluk yarıçapını metre cinsinden raporlar.)*

A smaller reported accuracy value represents a tighter estimated horizontal uncertainty radius. *(Daha küçük raporlanan doğruluk değeri daha dar bir tahmini yatay belirsizlik yarıçapını temsil eder.)*

NAVGUARD will preserve this value as measurement metadata rather than interpret it as guaranteed physical error. *(NAVGUARD bu değeri garanti edilmiş fiziksel hata olarak yorumlamak yerine ölçüm metadata bilgisi olarak koruyacaktır.)*

---

# 19. Accuracy Is Not Ground-Truth Certainty (Doğruluk Değeri Kesin Gerçek Referans Değildir)

An Android-reported horizontal accuracy of `x` metres does not prove that the actual position error is exactly `x` metres. *(Android tarafından raporlanan `x` metre yatay doğruluk gerçek konum hatasının tam olarak `x` metre olduğunu kanıtlamaz.)*

It is an estimated uncertainty value produced by the location system. *(Bu konum sistemi tarafından üretilen tahmini bir belirsizlik değeridir.)*

NAVGUARD evaluation will therefore use repeated controlled tests and trajectory analysis rather than rely only on the reported accuracy field. *(Bu nedenle NAVGUARD değerlendirmesi yalnızca raporlanan doğruluk alanına güvenmek yerine tekrarlanan kontrollü testleri ve rota analizini kullanacaktır.)*

---

# 20. GNSS Altitude Policy (GNSS Yükseklik Politikası)

GNSS altitude will be recorded when Android indicates that altitude is available. *(Android yüksekliğin kullanılabilir olduğunu belirttiğinde GNSS yüksekliği kaydedilecektir.)*

The primary NAVGUARD navigation benchmark will remain horizontally focused. *(Temel NAVGUARD navigasyon benchmark’ı yatay odaklı kalacaktır.)*

Altitude quality will therefore not block the minimum horizontal-navigation experiment unless a specific vertical experiment requires it. *(Bu nedenle belirli bir dikey deney gerektirmediği sürece yükseklik kalitesi minimum yatay navigasyon deneyini engellemeyecektir.)*

---

# 21. Vertical Accuracy (Dikey Doğruluk)

When available, Android vertical accuracy will be stored independently from horizontal accuracy. *(Mevcut olduğunda Android dikey doğruluğu yatay doğruluktan bağımsız olarak saklanacaktır.)*

Android exposes vertical accuracy separately and defines it as an estimated altitude-accuracy value at the 68th-percentile confidence level. *(Android dikey doğruluğu ayrı olarak sunar ve bunu yüzde 68 güven seviyesinde tahmini yükseklik doğruluğu değeri olarak tanımlar.)*

NAVGUARD will never apply horizontal accuracy as though it were vertical accuracy. *(NAVGUARD yatay doğruluğu hiçbir zaman dikey doğrulukmuş gibi uygulamayacaktır.)*

---

# 22. GNSS Speed (GNSS Hızı)

GNSS speed will be retained when Android reports it as available. *(Android mevcut olarak raporladığında GNSS hızı korunacaktır.)*

Android reports location speed in metres per second and notes that GNSS-derived speed may use information such as satellite Doppler rather than only sequential position differences. *(Android konum hızını metre/saniye cinsinden raporlar ve GNSS kaynaklı hızın yalnızca ardışık konum farkları yerine uydu Doppler bilgisi gibi verileri kullanabileceğini belirtir.)*

GNSS speed may later support motion validation but will not be available to the denied estimator during the protected evaluation window if it originates from the blocked GNSS measurement path. *(GNSS hızı daha sonra hareket doğrulamasını destekleyebilir ancak engellenmiş GNSS ölçüm hattından geliyorsa korunan değerlendirme penceresinde kesintili tahmin motoruna sunulmayacaktır.)*

---

# 23. GNSS Bearing (GNSS Hareket Yönü)

GNSS bearing will be recorded when available. *(GNSS hareket yönü mevcut olduğunda kaydedilecektir.)*

Android defines location bearing as horizontal direction of travel and explicitly distinguishes it from physical device orientation. *(Android konum bearing değerini yatay hareket yönü olarak tanımlar ve fiziksel cihaz yöneliminden açıkça ayırır.)*

GNSS bearing will therefore never be interpreted as a direct compass orientation of the smartphone. *(Bu nedenle GNSS bearing değeri akıllı telefonun doğrudan pusula yönelimi olarak yorumlanmayacaktır.)*

---

# 24. Bearing Accuracy (Hareket Yönü Doğruluğu)

Bearing accuracy will be retained when Android reports it. *(Android raporladığında bearing doğruluğu korunacaktır.)*

Android provides bearing accuracy separately from horizontal position accuracy. *(Android bearing doğruluğunu yatay konum doğruluğundan ayrı olarak sağlar.)*

A GNSS bearing should not be used as a heading reference merely because a bearing value exists. *(Bir GNSS bearing değeri yalnızca mevcut olduğu için yön referansı olarak kullanılmamalıdır.)*

Movement and quality conditions must also be satisfied. *(Hareket ve kalite koşulları da karşılanmalıdır.)*

---

# 25. Optional Location Fields (İsteğe Bağlı Konum Alanları)

NAVGUARD will respect Android `has*()` availability methods before consuming optional `Location` fields. *(NAVGUARD isteğe bağlı `Location` alanlarını kullanmadan önce Android `has*()` kullanılabilirlik metotlarına uyacaktır.)*

Missing altitude, speed, bearing, or accuracy-related values must remain explicitly unavailable. *(Eksik yükseklik, hız, bearing veya doğrulukla ilişkili değerler açıkça kullanılamaz kalmalıdır.)*

A missing value must not be replaced by zero when zero is physically meaningful. *(Eksik bir değer sıfır fiziksel olarak anlamlı olduğunda sıfırla değiştirilmemelidir.)*

---

# 26. Location Provider Validation (Konum Sağlayıcı Doğrulaması)

Formal GNSS records will preserve the provider identity. *(Resmî GNSS kayıtları provider kimliğini koruyacaktır.)*

The formal ground-truth route will accept measurements from the configured GNSS provider rather than silently mixing unrelated providers. *(Resmî gerçek referans rotası ilgisiz provider’ları sessizce karıştırmak yerine yapılandırılmış GNSS sağlayıcısından gelen ölçümleri kabul edecektir.)*

Provider mismatches will be logged as diagnostic events. *(Provider uyuşmazlıkları tanısal olay olarak kaydedilecektir.)*

---

# 27. Mock Location Policy (Mock Konum Politikası)

Formal physical-device benchmark sessions must use real device location measurements rather than intentionally injected mock locations. *(Resmî fiziksel cihaz benchmark oturumları bilinçli olarak enjekte edilmiş mock konumlar yerine gerçek cihaz konum ölçümlerini kullanmalıdır.)*

Mock locations may be useful for automated testing but must be clearly separated from physical field data. *(Mock konumlar otomatik test için kullanışlı olabilir ancak fiziksel saha verisinden açıkça ayrılmalıdır.)*

A mock-location session must never be classified as a physical field benchmark. *(Bir mock konum oturumu hiçbir zaman fiziksel saha benchmark’ı olarak sınıflandırılmamalıdır.)*

---

# 28. GNSS Status Diagnostics (GNSS Durum Tanısı)

NAVGUARD will use Android `GnssStatus` where supported to observe satellite-level diagnostic information. *(NAVGUARD desteklendiğinde uydu seviyesindeki tanısal bilgiyi gözlemlemek için Android `GnssStatus` kullanacaktır.)*

The diagnostic stream is separate from the geographic `Location` fix stream. *(Tanısal akış coğrafi `Location` fix akışından ayrıdır.)*

Satellite diagnostics will help explain GNSS quality changes without becoming a substitute for the actual position measurement. *(Uydu tanısı gerçek konum ölçümünün yerine geçmeden GNSS kalite değişikliklerini açıklamaya yardımcı olacaktır.)*

---

# 29. GnssStatus Information (GnssStatus Bilgileri)

`GnssStatus` can expose satellite constellation, satellite identifier, carrier-to-noise density, elevation, azimuth, carrier frequency when available, and whether a satellite was used in the most recent fix. *(`GnssStatus`; uydu takımyıldızını, uydu tanımlayıcısını, carrier-to-noise density değerini, yükseliş açısını, azimutu, mevcut olduğunda taşıyıcı frekansını ve bir uydunun en son fix’te kullanılıp kullanılmadığını sunabilir.)*

NAVGUARD will preserve only the fields actually available on the physical device. *(NAVGUARD yalnızca fiziksel cihazda gerçekten mevcut olan alanları koruyacaktır.)*

---

# 30. Supported Constellation Diagnostics (Desteklenen Takımyıldız Tanısı)

Android’s GNSS status model includes constellation identifiers for systems such as GPS, GLONASS, Galileo, BeiDou, QZSS, SBAS, and IRNSS. *(Android’in GNSS durum modeli GPS, GLONASS, Galileo, BeiDou, QZSS, SBAS ve IRNSS gibi sistemler için takımyıldız tanımlayıcıları içerir.)*

NAVGUARD will record the constellations actually observed by the Redmi Note 9 Pro rather than assuming all Android-supported constellations are physically available. *(NAVGUARD Android tarafından desteklenen tüm takımyıldızların fiziksel olarak mevcut olduğunu varsaymak yerine Redmi Note 9 Pro tarafından gerçekten gözlemlenen takımyıldızları kaydedecektir.)*

---

# 31. Satellite Count (Uydu Sayısı)

NAVGUARD may record both total visible/tracked satellite count and number of satellites reported as used in the current fix. *(NAVGUARD toplam görünür/takip edilen uydu sayısını ve mevcut fix’te kullanıldığı raporlanan uydu sayısını kaydedebilir.)*

These values are diagnostic indicators rather than direct position-error measurements. *(Bu değerler doğrudan konum hata ölçümleri yerine tanısal göstergelerdir.)*

A high satellite count does not by itself guarantee high positioning accuracy. *(Yüksek uydu sayısı tek başına yüksek konumlandırma doğruluğunu garanti etmez.)*

---

# 32. `usedInFix` Policy (`usedInFix` Politikası)

NAVGUARD will use `GnssStatus.usedInFix()` when determining the satellite count associated with the most recent GNSS fix. *(NAVGUARD en son GNSS fix’iyle ilişkili uydu sayısını belirlerken `GnssStatus.usedInFix()` kullanacaktır.)*

Android defines this flag as indicating whether fresh data from the respective satellite was used by the position engine for the most recent fix. *(Android bu flag’i ilgili uydudan gelen güncel verinin en son fix için konum motoru tarafından kullanılıp kullanılmadığını belirten bilgi olarak tanımlar.)*

---

# 33. C/N0 Diagnostics (C/N0 Tanısı)

NAVGUARD may record per-satellite carrier-to-noise density values in dB-Hz. *(NAVGUARD uydu başına carrier-to-noise density değerlerini dB-Hz cinsinden kaydedebilir.)*

Android exposes this information through GNSS status and raw GNSS measurement APIs when supported. *(Android desteklendiğinde bu bilgiyi GNSS durum ve ham GNSS ölçüm API’leri üzerinden sunar.)*

C/N0 values will be used as diagnostic signal-quality evidence rather than converted directly into a claimed position-error value. *(C/N0 değerleri doğrudan iddia edilen bir konum hata değerine dönüştürülmek yerine tanısal sinyal kalite kanıtı olarak kullanılacaktır.)*

---

# 34. C/N0 Aggregate Statistics (C/N0 Toplu İstatistikleri)

NAVGUARD may calculate session-time diagnostic statistics from satellites used in the fix. *(NAVGUARD fix’te kullanılan uydulardan oturum zamanı tanısal istatistikler hesaplayabilir.)*

Candidate statistics include median C/N0, mean C/N0, strongest-satellite C/N0, and number of satellites above experimentally selected quality levels. *(Aday istatistikler medyan C/N0, ortalama C/N0, en güçlü uydu C/N0 ve deneysel olarak seçilen kalite seviyelerinin üzerindeki uydu sayısını içerir.)*

No universal quality threshold will be frozen before Redmi Note 9 Pro field measurements are collected. *(Redmi Note 9 Pro saha ölçümleri toplanmadan evrensel bir kalite eşiği sabitlenmeyecektir.)*

---

# 35. Satellite Geometry Awareness (Uydu Geometrisi Farkındalığı)

Satellite azimuth and elevation may be logged for diagnostic analysis. *(Uydu azimut ve yükseliş açıları tanısal analiz için kaydedilebilir.)*

NAVGUARD will not attempt to derive a full professional GNSS integrity solution from satellite geometry within the minimum project scope. *(NAVGUARD minimum proje kapsamında uydu geometrisinden tam profesyonel GNSS bütünlük çözümü türetmeye çalışmayacaktır.)*

The information may nevertheless help explain indoor, urban, obstructed, or low-sky-visibility behavior. *(Bununla birlikte bilgi iç mekân, kentsel, engellenmiş veya düşük gökyüzü görünürlüğü davranışlarını açıklamaya yardımcı olabilir.)*

---

# 36. GNSS Status Data Model (GNSS Durum Veri Modeli)

```
GnssSatelliteStatus
- statusTimestampNs
- constellation
- svid
- usedInFix
- cn0DbHz
- elevationDeg
- azimuthDeg
- carrierFrequencyHz
- carrierFrequencyAvailable
```

A status snapshot will also include aggregate counts. *(Bir durum anlık görüntüsü ayrıca toplu sayımları içerecektir.)*

```
GnssStatusSnapshot
- timestampNs
- satelliteCount
- usedInFixCount
- constellationCounts
- medianUsedCn0DbHz
```

---

# 37. Raw GNSS Measurements (Ham GNSS Ölçümleri)

Android supports access to satellite-level raw GNSS measurement events on supported devices. *(Android desteklenen cihazlarda uydu seviyesindeki ham GNSS ölçüm olaylarına erişimi destekler.)*

`GnssMeasurementsEvent.Callback` receives GNSS measurement events through `LocationManager.registerGnssMeasurementsCallback`. *(`GnssMeasurementsEvent.Callback`, GNSS ölçüm olaylarını `LocationManager.registerGnssMeasurementsCallback` üzerinden alır.)*

Raw GNSS measurement support is an optional NAVGUARD research capability and is not required for the core estimator. *(Ham GNSS ölçüm desteği isteğe bağlı bir NAVGUARD araştırma yeteneğidir ve temel tahmin motoru için gerekli değildir.)*

---

# 38. Raw GNSS Scope Boundary (Ham GNSS Kapsam Sınırı)

NAVGUARD will not implement its own full GNSS positioning engine from pseudoranges during the minimum 24-day project. *(NAVGUARD minimum 24 günlük proje sırasında pseudorange değerlerinden kendi tam GNSS konumlandırma motorunu geliştirmeyecektir.)*

Raw GNSS may instead be used for diagnostics, device-capability research, signal-quality analysis, or future work. *(Ham GNSS bunun yerine tanı, cihaz yetenek araştırması, sinyal kalite analizi veya gelecek çalışmalar için kullanılabilir.)*

This prevents the GNSS subsystem from expanding beyond the primary GNSS-denied navigation objective. *(Bu GNSS alt sisteminin temel GNSS kesintili navigasyon hedefinin ötesine genişlemesini önler.)*

---

# 39. Raw GNSS Capability Detection (Ham GNSS Yetenek Tespiti)

Raw GNSS functionality will be enabled only when actual runtime capability and successful event delivery are verified. *(Ham GNSS işlevi yalnızca gerçek çalışma zamanı yeteneği ve başarılı olay teslimi doğrulandığında etkinleştirilecektir.)*

NAVGUARD will not rely on the deprecated `GnssMeasurementsEvent.Callback.onStatusChanged()` status mechanism on modern Android versions. *(NAVGUARD modern Android sürümlerinde deprecated olan `GnssMeasurementsEvent.Callback.onStatusChanged()` durum mekanizmasına güvenmeyecektir.)*

Android deprecated these measurement-status callbacks in API level 31 and recommends using `LocationManager` APIs to determine relevant GNSS availability or support conditions. *(Android bu ölçüm durum callback’lerini API 31 seviyesinde deprecated etmiş ve ilgili GNSS kullanılabilirlik veya destek koşullarını belirlemek için `LocationManager` API’lerini önermiştir.)*

---

# 40. Deprecated Provider Status Avoidance (Deprecated Provider Durumlarından Kaçınma)

NAVGUARD will not design its GNSS health architecture around deprecated provider-status constants such as `AVAILABLE`, `TEMPORARILY_UNAVAILABLE`, or `OUT_OF_SERVICE`. *(NAVGUARD GNSS sağlık mimarisini `AVAILABLE`, `TEMPORARILY_UNAVAILABLE` veya `OUT_OF_SERVICE` gibi deprecated provider durum sabitleri etrafında tasarlamayacaktır.)*

Android deprecated the old provider-status model. *(Android eski provider durum modelini deprecated etmiştir.)*

GNSS health will instead be inferred from provider enablement, incoming fix age, reported accuracy, satellite diagnostics, and observed runtime behavior. *(Bunun yerine GNSS sağlığı provider etkinliği, gelen fix yaşı, raporlanan doğruluk, uydu tanısı ve gözlemlenen çalışma zamanı davranışından çıkarılacaktır.)*

---

# 41. GNSS Quality Engine (GNSS Kalite Motoru)

NAVGUARD will implement a GNSS Quality Engine that evaluates incoming GNSS information before it is used for anchor acceptance, recovery, or quality display. *(NAVGUARD gelen GNSS bilgisini çapa kabulü, geri kazanım veya kalite gösterimi için kullanılmadan önce değerlendiren bir GNSS Kalite Motoru geliştirecektir.)*

The quality engine will not alter the raw GNSS record. *(Kalite motoru ham GNSS kaydını değiştirmeyecektir.)*

It will produce derived quality metadata. *(Türetilmiş kalite metadata bilgisi üretecektir.)*

---

# 42. GNSS Quality Inputs (GNSS Kalite Girdileri)

Candidate GNSS quality inputs include horizontal accuracy. *(Aday GNSS kalite girdileri yatay doğruluğu içerir.)*

Candidate GNSS quality inputs include fix age. *(Aday GNSS kalite girdileri fix yaşını içerir.)*

Candidate GNSS quality inputs include provider identity. *(Aday GNSS kalite girdileri provider kimliğini içerir.)*

Candidate GNSS quality inputs include recent position stability. *(Aday GNSS kalite girdileri son konum kararlılığını içerir.)*

Candidate GNSS quality inputs include satellite count and used-in-fix count when available. *(Aday GNSS kalite girdileri mevcut olduğunda uydu sayısını ve fix’te kullanılan uydu sayısını içerir.)*

Candidate GNSS quality inputs include C/N0 statistics when available. *(Aday GNSS kalite girdileri mevcut olduğunda C/N0 istatistiklerini içerir.)*

---

# 43. GNSS Quality Does Not Depend on One Number (GNSS Kalitesi Tek Bir Sayıya Bağlı Değildir)

No single GNSS field will automatically determine all quality decisions. *(Tek bir GNSS alanı tüm kalite kararlarını otomatik olarak belirlemeyecektir.)*

For example, a good reported horizontal accuracy combined with an old stale fix must not be considered equivalent to a fresh measurement. *(Örneğin iyi raporlanmış yatay doğruluk ile eski bir fix’in birleşimi yeni bir ölçümle eşdeğer kabul edilmemelidir.)*

Quality decisions will use the combination of evidence appropriate to the operation. *(Kalite kararları işlem için uygun kanıt birleşimini kullanacaktır.)*

---

# 44. GNSS Quality State (GNSS Kalite Durumu)

A derived GNSS quality state may use the following categories. *(Türetilmiş bir GNSS kalite durumu aşağıdaki kategorileri kullanabilir.)*

```
UNKNOWN
POOR
USABLE
GOOD
EXCELLENT
STALE
UNAVAILABLE
```

These labels must be calibrated using physical-device observations before being presented as measured quality categories. *(Bu etiketler ölçülmüş kalite kategorileri olarak sunulmadan önce fiziksel cihaz gözlemleriyle kalibre edilmelidir.)*

---

# 45. Quantitative Quality Metadata (Sayısal Kalite Metadata Bilgisi)

NAVGUARD should preserve the underlying quantitative evidence even if a simplified categorical quality label is displayed. *(NAVGUARD basitleştirilmiş kategorik kalite etiketi gösterilse bile temel sayısal kanıtı korumalıdır.)*

A category such as `GOOD` must not replace the original reported accuracy, satellite count, fix age, or other diagnostic values in stored data. *(`GOOD` gibi bir kategori saklanan veride orijinal raporlanan doğruluğun, uydu sayısının, fix yaşının veya diğer tanısal değerlerin yerini almamalıdır.)*

---

# 46. Anchor Purpose (Çapa Amacı)

The initial GNSS anchor connects the global WGS84 coordinate system with NAVGUARD’s local ENU navigation frame. *(Başlangıç GNSS çapası global WGS84 koordinat sistemini NAVGUARD’ın yerel ENU navigasyon çerçevesine bağlar.)*

The anchor represents local position `(E, N, U) = (0, 0, 0)` for the initial navigation segment. *(Çapa ilk navigasyon parçası için yerel konum `(E, N, U) = (0, 0, 0)` değerini temsil eder.)*

Anchor quality therefore directly affects the geographic placement of the entire GNSS-denied trajectory. *(Bu nedenle çapa kalitesi tüm GNSS kesintili rotanın coğrafi yerleşimini doğrudan etkiler.)*

---

# 47. Anchor Acceptance Must Be Explicit (Çapa Kabulü Açık Olmalıdır)

NAVGUARD will not silently use the first location callback as the formal anchor. *(NAVGUARD ilk konum callback’ini sessizce resmî çapa olarak kullanmayacaktır.)*

An anchor candidate must pass explicit validation. *(Bir çapa adayı açık doğrulamayı geçmelidir.)*

The validation rules will be measurable and stored in the experiment configuration. *(Doğrulama kuralları ölçülebilir olacak ve deney yapılandırmasında saklanacaktır.)*

---

# 48. Minimum Anchor Validity Conditions (Minimum Çapa Geçerlilik Koşulları)

An anchor candidate must originate from the configured GNSS provider. *(Bir çapa adayı yapılandırılmış GNSS provider’ından gelmelidir.)*

The location must contain valid latitude and longitude. *(Konum geçerli enlem ve boylam içermelidir.)*

The location must contain horizontal accuracy information. *(Konum yatay doğruluk bilgisi içermelidir.)*

The fix must be sufficiently fresh. *(Fix yeterince yeni olmalıdır.)*

The horizontal accuracy must satisfy the configured anchor-quality requirement. *(Yatay doğruluk yapılandırılmış çapa kalite gereksinimini karşılamalıdır.)*

---

# 49. Anchor Accuracy Threshold Policy (Çapa Doğruluk Eşiği Politikası)

The final maximum acceptable horizontal-accuracy threshold for initial anchoring will not be invented before field testing. *(Başlangıç çapalaması için nihai maksimum kabul edilebilir yatay doğruluk eşiği saha testinden önce uydurulmayacaktır.)*

An initial engineering threshold may be configured during development, but it will remain provisional until measured GNSS behavior on the Redmi Note 9 Pro is reviewed. *(Geliştirme sırasında bir başlangıç mühendislik eşiği yapılandırılabilir ancak Redmi Note 9 Pro üzerinde ölçülen GNSS davranışı incelenene kadar geçici kalacaktır.)*

The final value will be documented in the Device Capability Audit or experiment configuration. *(Nihai değer Cihaz Yetenek Denetimi veya deney yapılandırmasında dokümante edilecektir.)*

---

# 50. Anchor Freshness Threshold Policy (Çapa Güncellik Eşiği Politikası)

The maximum permitted anchor-fix age will be defined relative to the requested GNSS cadence and measured device behavior. *(Maksimum izin verilen çapa fix yaşı talep edilen GNSS kadansına ve ölçülen cihaz davranışına göre tanımlanacaktır.)*

A cached or stale fix must not pass anchor validation. *(Cache’lenmiş veya eski bir fix çapa doğrulamasını geçmemelidir.)*

The final freshness threshold will be frozen before formal field benchmarks. *(Nihai güncellik eşiği resmî saha benchmark’larından önce sabitlenecektir.)*

---

# 51. Stable Anchor Window (Kararlı Çapa Penceresi)

The target anchor procedure should observe more than one GNSS fix when sufficient time is available. *(Hedef çapa prosedürü yeterli zaman mevcut olduğunda birden fazla GNSS fix’i gözlemlemelidir.)*

A short stationary initialization window can determine whether recent GNSS positions are spatially stable before the anchor is accepted. *(Kısa bir sabit başlatma penceresi çapa kabul edilmeden önce son GNSS konumlarının uzamsal olarak kararlı olup olmadığını belirleyebilir.)*

This strategy is preferred over accepting a single unusually good or bad sample without context. *(Bu strateji bağlam olmadan tek bir olağan dışı iyi veya kötü örneği kabul etmeye tercih edilir.)*

---

# 52. Anchor Window Candidate (Çapa Penceresi Adayı)

```
GNSS Fix 1
GNSS Fix 2
GNSS Fix 3
...
        │
        ▼
Freshness Check
        │
        ▼
Accuracy Check
        │
        ▼
Spatial Stability Check
        │
        ▼
Anchor Accepted
```

The exact number of fixes and observation duration remain pending field measurements. *(Kesin fix sayısı ve gözlem süresi saha ölçümlerini beklemektedir.)*

---

# 53. Anchor Stability Calculation (Çapa Kararlılık Hesabı)

Recent valid GNSS fixes may be converted into a temporary local metric frame to evaluate spatial dispersion. *(Son geçerli GNSS fix’leri uzamsal dağılımı değerlendirmek için geçici bir yerel metrik çerçeveye dönüştürülebilir.)*

The anchor algorithm should avoid comparing latitude and longitude degree differences directly when a metric distance is desired. *(Çapa algoritması metrik mesafe istendiğinde enlem ve boylam derece farklarını doğrudan karşılaştırmaktan kaçınmalıdır.)*

The WGS84/ECEF/ENU mathematics defined in **14 — Coordinate Systems & Mathematical Foundations** will provide the common metric representation. *(Ortak metrik temsil **14 — Coordinate Systems & Mathematical Foundations** içerisinde tanımlanan WGS84/ECEF/ENU matematiği tarafından sağlanacaktır.)*

---

# 54. Anchor Position Selection (Çapa Konumu Seçimi)

The target anchor may be selected from the best validated recent fix or derived from a short stable set of valid fixes. *(Hedef çapa en iyi doğrulanmış son fix’ten seçilebilir veya kısa ve kararlı bir geçerli fix setinden türetilebilir.)*

The exact estimator will be selected after pilot data is inspected. *(Kesin tahmin yöntemi pilot veri incelendikten sonra seçilecektir.)*

If multiple fixes are combined, the method must be defined and reproducible. *(Birden fazla fix birleştirilirse yöntem tanımlı ve tekrarlanabilir olmalıdır.)*

---

# 55. Anchor Averaging Rule (Çapa Ortalama Kuralı)

NAVGUARD will avoid introducing an undocumented naive latitude-longitude averaging rule. *(NAVGUARD dokümante edilmemiş basit bir enlem-boylam ortalama kuralı kullanmaktan kaçınacaktır.)*

If averaging is used, positions will preferably be combined in a suitable metric or Cartesian frame and converted back to WGS84. *(Ortalama kullanılacaksa konumlar tercihen uygun bir metrik veya Kartezyen çerçevede birleştirilecek ve WGS84’e geri dönüştürülecektir.)*

---

# 56. Anchor Data Model (Çapa Veri Modeli)

```
GnssAnchor
- anchorId
- timestampNs
- latitudeDeg
- longitudeDeg
- ellipsoidalHeightM
- horizontalAccuracyM
- sourceFixCount
- anchorMethod
- qualityState
```

The anchor method will record whether the anchor came from a single validated fix or a stable multi-fix procedure. *(Çapa yöntemi çapanın tek doğrulanmış fix’ten mi yoksa kararlı çoklu fix prosedüründen mi geldiğini kaydedecektir.)*

---

# 57. Anchor Acceptance Event (Çapa Kabul Olayı)

Every accepted formal anchor will generate a timestamped event. *(Kabul edilen her resmî çapa zaman damgalı bir olay üretecektir.)*

```
GNSS_ANCHOR_ACCEPTED
```

The event will contain the anchor identifier and relevant quality information. *(Olay çapa tanımlayıcısını ve ilgili kalite bilgisini içerecektir.)*

---

# 58. Anchor Rejection Event (Çapa Red Olayı)

Rejected anchor candidates may produce diagnostic events during development and audit mode. *(Reddedilen çapa adayları geliştirme ve denetim modunda tanısal olaylar üretebilir.)*

Possible reasons include stale fix, poor reported accuracy, unstable recent positions, invalid provider, or missing required data. *(Olası nedenler eski fix, düşük raporlanan doğruluk, kararsız son konumlar, geçersiz provider veya eksik gerekli veriyi içerir.)*

---

# 59. User Feedback During Anchor Acquisition (Çapa Toplama Sırasında Kullanıcı Geri Bildirimi)

The user interface will indicate when NAVGUARD is waiting for an acceptable GNSS anchor. *(Kullanıcı arayüzü NAVGUARD kabul edilebilir bir GNSS çapası beklediğinde bunu gösterecektir.)*

The interface should display meaningful readiness information rather than only an indefinite loading indicator. *(Arayüz yalnızca belirsiz bir yükleniyor göstergesi yerine anlamlı hazırlık bilgisi göstermelidir.)*

Candidate information may include reported accuracy, fix age, and current GNSS quality state. *(Aday bilgiler raporlanan doğruluk, fix yaşı ve mevcut GNSS kalite durumunu içerebilir.)*

---

# 60. GNSS Mode (GNSS Modu)

In GNSS Mode, validated GNSS fixes may enter the active navigation estimator. *(GNSS Modunda doğrulanmış GNSS fix’leri aktif navigasyon tahmin motoruna girebilir.)*

The raw GNSS logger will simultaneously preserve the measurements. *(Ham GNSS logger’ı aynı anda ölçümleri koruyacaktır.)*

The quality engine may reject unsuitable GNSS measurements from estimator updates without deleting them from raw evidence. *(Kalite motoru uygun olmayan GNSS ölçümlerini ham kanıttan silmeden tahmin motoru güncellemelerinden reddedebilir.)*

---

# 61. GNSS Estimator Measurement Model (GNSS Tahmin Motoru Ölçüm Modeli)

A validated GNSS position intended for the estimator will be converted from WGS84 into the active local ENU frame. *(Tahmin motoru için amaçlanan doğrulanmış bir GNSS konumu WGS84’ten aktif yerel ENU çerçevesine dönüştürülecektir.)*

```
GNSS WGS84
    │
    ▼
ECEF
    │
    ▼
Anchor ENU
    │
    ▼
[E_GNSS, N_GNSS]
```

The estimator will therefore consume metric local coordinates rather than directly update state with latitude and longitude degrees. *(Bu nedenle tahmin motoru durumu doğrudan enlem ve boylam dereceleriyle güncellemek yerine metrik yerel koordinatları kullanacaktır.)*

---

# 62. GNSS Measurement Covariance Candidate (GNSS Ölçüm Kovaryansı Adayı)

The reported horizontal accuracy may contribute to the initial GNSS measurement-noise model used by the EKF. *(Raporlanan yatay doğruluk EKF tarafından kullanılan ilk GNSS ölçüm gürültüsü modeline katkıda bulunabilir.)*

It must not automatically be interpreted as an exact Gaussian standard deviation without validation. *(Doğrulama olmadan otomatik olarak kesin Gaussian standart sapması şeklinde yorumlanmamalıdır.)*

The final relationship between Android accuracy and EKF covariance will be calibrated empirically. *(Android doğruluğu ile EKF kovaryansı arasındaki nihai ilişki ampirik olarak kalibre edilecektir.)*

---

# 63. Evaluation Mode Ground Truth (Değerlendirme Modu Gerçek Referansı)

Evaluation Mode will keep GNSS acquisition active when physical GNSS is available. *(Fiziksel GNSS mevcut olduğunda Değerlendirme Modu GNSS veri toplamayı aktif tutacaktır.)*

GNSS measurements will continue entering the raw logger and ground-truth stream. *(GNSS ölçümleri ham logger ve gerçek referans akışına girmeye devam edecektir.)*

The same measurements will be prevented from entering the denied estimator. *(Aynı ölçümlerin kesintili tahmin motoruna girmesi engellenecektir.)*

---

# 64. Ground Truth Firewall (Gerçek Referans Güvenlik Duvarı)

The Ground Truth Firewall is the mandatory logical boundary between GNSS acquisition and the estimator. *(Gerçek Referans Güvenlik Duvarı GNSS veri toplama ile tahmin motoru arasındaki zorunlu mantıksal sınırdır.)*

```
GNSS Sample
    │
    ├────────────► Ground Truth Logger
    │
    ▼
Ground Truth Firewall
    │
    ├── ALLOWED ──► Estimator
    │
    └── BLOCKED ──► No Estimator Access
```

The firewall state is controlled by the Navigation Mode Manager. *(Güvenlik duvarı durumu Navigasyon Mod Yöneticisi tarafından kontrol edilir.)*

---

# 65. Firewall Default-Safety Principle (Güvenlik Duvarı Varsayılan Güvenlik İlkesi)

The estimator should require explicit authorization to consume GNSS. *(Tahmin motoru GNSS kullanmak için açık yetkilendirme gerektirmelidir.)*

The architecture should not rely on every downstream algorithm independently remembering to ignore GNSS. *(Mimari her aşağı akış algoritmasının GNSS’i göz ardı etmeyi bağımsız olarak hatırlamasına güvenmemelidir.)*

This central gate reduces accidental GNSS leakage. *(Bu merkezi kapı yanlışlıkla GNSS sızıntısı riskini azaltır.)*

---

# 66. Firewall Authorization States (Güvenlik Duvarı Yetkilendirme Durumları)

```
GNSS Mode:
ALLOWED

Evaluation Armed:
ALLOWED

GNSS Denial Transition:
BLOCKING

NAVGUARD Active:
BLOCKED

Degraded NAVGUARD:
BLOCKED

GNSS Recovery Pending:
BLOCKED

Relocalizing:
CONTROLLED

GNSS Navigation Restored:
ALLOWED
```

The detailed controlled behavior during relocalization will be defined in **29 — GNSS Recovery & Relocalization**. *(Yeniden konumlandırma sırasındaki ayrıntılı kontrollü davranış **29 — GNSS Recovery & Relocalization** bölümünde tanımlanacaktır.)*

---

# 67. Denial Boundary (Kesinti Sınırı)

The primary GNSS-denied evaluation interval begins at the exact timestamp when estimator GNSS authorization becomes `BLOCKED`. *(Temel GNSS kesintili değerlendirme aralığı tahmin motoru GNSS yetkilendirmesinin `BLOCKED` olduğu kesin zaman damgasında başlar.)*

The physical Android GNSS provider does not need to be disabled. *(Fiziksel Android GNSS provider’ının devre dışı bırakılması gerekmez.)*

This preserves continuous independent ground-truth evidence. *(Bu sürekli bağımsız gerçek referans kanıtını korur.)*

---

# 68. No GNSS Jamming or Interference (GNSS Karıştırma veya Müdahalesi Olmaması)

NAVGUARD will not create GNSS loss through radio-frequency jamming, spoofing, or interference. *(NAVGUARD GNSS kaybını radyo frekansı karıştırma, spoofing veya müdahale yoluyla oluşturmayacaktır.)*

Controlled GNSS denial will occur entirely through software-level estimator exclusion. *(Kontrollü GNSS kesintisi tamamen yazılım seviyesinde tahmin motoru dışlaması yoluyla gerçekleşecektir.)*

This provides a safe, reproducible, and measurable experiment. *(Bu güvenli, tekrarlanabilir ve ölçülebilir bir deney sağlar.)*

---

# 69. Ground Truth Stream Must Remain Untouched (Gerçek Referans Akışı Değişmeden Kalmalıdır)

Ground-truth GNSS fixes will be stored as reported before trajectory comparison or interpolation. *(Gerçek referans GNSS fix’leri rota karşılaştırması veya interpolasyondan önce raporlandıkları şekilde saklanacaktır.)*

Any later time alignment, interpolation, smoothing, or conversion into ENU will produce processed evaluation data. *(Daha sonraki zaman hizalama, interpolasyon, yumuşatma veya ENU’ya dönüşüm işlenmiş değerlendirme verisi üretecektir.)*

Raw GNSS evidence will remain separately available. *(Ham GNSS kanıtı ayrı olarak kullanılabilir kalacaktır.)*

---

# 70. Ground Truth Is a Reference, Not Absolute Truth (Gerçek Referans Mutlak Gerçek Değildir)

Consumer-smartphone GNSS itself contains positioning error. *(Tüketici sınıfı akıllı telefon GNSS’i de konumlandırma hatası içerir.)*

The term ground truth in NAVGUARD therefore means the independent GNSS reference trajectory used for comparison, not an assertion of centimetre-level absolute truth. *(Bu nedenle NAVGUARD içerisindeki ground truth terimi santimetre seviyesinde mutlak doğruluk iddiası yerine karşılaştırma için kullanılan bağımsız GNSS referans rotasını ifade eder.)*

This limitation will be stated in the final experimental report. *(Bu sınırlama nihai deneysel raporda belirtilecektir.)*

---

# 71. Ground Truth Quality Filtering (Gerçek Referans Kalite Filtreleme)

GNSS ground-truth measurements may receive quality flags during evaluation. *(GNSS gerçek referans ölçümleri değerlendirme sırasında kalite flag’leri alabilir.)*

Raw measurements will not be deleted merely because their reported accuracy is worse. *(Ham ölçümler yalnızca raporlanan doğrulukları daha kötü olduğu için silinmeyecektir.)*

Formal metrics may use a documented validity policy to avoid comparing NAVGUARD against clearly unusable GNSS reference points. *(Resmî metrikler NAVGUARD’ı açıkça kullanılamaz GNSS referans noktalarıyla karşılaştırmaktan kaçınmak için dokümante edilmiş bir geçerlilik politikası kullanabilir.)*

---

# 72. Reference Quality Transparency (Referans Kalite Şeffaflığı)

Every benchmark should preserve the quality distribution of its ground-truth GNSS. *(Her benchmark gerçek referans GNSS’inin kalite dağılımını korumalıdır.)*

This may include median reported accuracy, maximum reported accuracy, GNSS fix availability, and selected satellite diagnostics. *(Bu medyan raporlanan doğruluk, maksimum raporlanan doğruluk, GNSS fix kullanılabilirliği ve seçilen uydu tanısını içerebilir.)*

A benchmark performed under poor GNSS ground-truth conditions must be identified accordingly. *(Düşük GNSS gerçek referans koşullarında gerçekleştirilen benchmark buna göre tanımlanmalıdır.)*

---

# 73. Ground Truth Availability Metric (Gerçek Referans Kullanılabilirlik Metriği)

NAVGUARD may calculate the percentage of the evaluation interval for which valid GNSS ground-truth fixes were available. *(NAVGUARD değerlendirme aralığının geçerli GNSS gerçek referans fix’lerinin mevcut olduğu yüzdesini hesaplayabilir.)*

```
GroundTruthAvailability =
ValidReferenceDuration
────────────────────── × 100
EvaluationDuration
```

The final definition will be frozen with the benchmark methodology. *(Nihai tanım benchmark metodolojisiyle birlikte sabitlenecektir.)*

---

# 74. GNSS Update Rate Measurement (GNSS Güncelleme Hızı Ölçümü)

The actual GNSS update rate will be measured from elapsed-realtime timestamps. *(Gerçek GNSS güncelleme hızı elapsed-realtime zaman damgalarından ölçülecektir.)*

The requested update interval will not be treated as proof of the delivered rate. *(Talep edilen güncelleme aralığı teslim edilen hızın kanıtı olarak ele alınmayacaktır.)*

The Redmi Note 9 Pro Device Capability Audit will record the effective rate under relevant test conditions. *(Redmi Note 9 Pro Cihaz Yetenek Denetimi ilgili test koşullarında etkin hızı kaydedecektir.)*

---

# 75. GNSS Sampling Statistics (GNSS Örnekleme İstatistikleri)

GNSS timing analysis should include fix count. *(GNSS zamanlama analizi fix sayısını içermelidir.)*

GNSS timing analysis should include median update interval. *(GNSS zamanlama analizi medyan güncelleme aralığını içermelidir.)*

GNSS timing analysis should include mean update interval. *(GNSS zamanlama analizi ortalama güncelleme aralığını içermelidir.)*

GNSS timing analysis should include maximum observed gap. *(GNSS zamanlama analizi gözlemlenen maksimum boşluğu içermelidir.)*

GNSS timing analysis should include stale-fix events. *(GNSS zamanlama analizi eski fix olaylarını içermelidir.)*

---

# 76. GNSS Fix Gap Detection (GNSS Fix Boşluğu Tespiti)

NAVGUARD will monitor elapsed time since the latest GNSS fix. *(NAVGUARD son GNSS fix’inden itibaren geçen süreyi izleyecektir.)*

A long interval without new fixes may cause GNSS quality to transition to `DEGRADED`, `STALE`, or `UNAVAILABLE`. *(Yeni fix olmadan uzun bir aralık GNSS kalitesinin `DEGRADED`, `STALE` veya `UNAVAILABLE` durumuna geçmesine neden olabilir.)*

The exact timing threshold will be derived from the frozen GNSS update configuration and measured behavior. *(Kesin zaman eşiği sabitlenmiş GNSS güncelleme yapılandırmasından ve ölçülen davranıştan türetilecektir.)*

---

# 77. GNSS Provider Disabled State (GNSS Provider Devre Dışı Durumu)

NAVGUARD will detect whether required location functionality or the configured provider is disabled. *(NAVGUARD gerekli konum işlevinin veya yapılandırılmış provider’ın devre dışı olup olmadığını tespit edecektir.)*

If the provider is disabled before a formal experiment, the readiness check will fail. *(Provider resmî bir deneyden önce devre dışıysa hazırlık kontrolü başarısız olacaktır.)*

If it becomes disabled during Evaluation Mode, ground-truth availability will be lost and the event must be recorded. *(Değerlendirme Modu sırasında devre dışı hale gelirse gerçek referans kullanılabilirliği kaybolacak ve olay kaydedilecektir.)*

---

# 78. GNSS Loss During Ground Truth Recording (Gerçek Referans Kaydı Sırasında GNSS Kaybı)

A real physical GNSS outage may occur even though NAVGUARD’s formal denial is implemented in software. *(NAVGUARD’ın resmî kesintisi yazılımda uygulanmasına rağmen gerçek fiziksel GNSS kesintisi meydana gelebilir.)*

If this happens, NAVGUARD must distinguish physical ground-truth loss from the intentional estimator-denial state. *(Bu meydana gelirse NAVGUARD fiziksel gerçek referans kaybını bilinçli tahmin motoru kesinti durumundan ayırmalıdır.)*

The session may continue operationally but its formal evaluation quality may be reduced or invalidated depending on duration and protocol. *(Oturum operasyonel olarak devam edebilir ancak resmî değerlendirme kalitesi süre ve protokole bağlı olarak azalabilir veya geçersiz kılınabilir.)*

---

# 79. GNSS Health Versus Navigation Mode (GNSS Sağlığı ile Navigasyon Modu Ayrımı)

GNSS health and navigation mode are independent state dimensions. *(GNSS sağlığı ve navigasyon modu bağımsız durum boyutlarıdır.)*

A session may have `GNSS_HEALTH = GOOD` while `NAVIGATION_MODE = NAVGUARD_MODE`. *(Bir oturum `GNSS_HEALTH = GOOD` iken `NAVIGATION_MODE = NAVGUARD_MODE` durumunda olabilir.)*

This is expected during Evaluation Mode because GNSS may remain physically healthy while estimator access is intentionally blocked. *(Bu Değerlendirme Modunda beklenen bir durumdur çünkü tahmin motoru erişimi bilinçli olarak engellenirken GNSS fiziksel olarak sağlıklı kalabilir.)*

---

# 80. Example Evaluation State (Örnek Değerlendirme Durumu)

```
GNSS Acquisition:
ACTIVE

GNSS Quality:
GOOD

Ground Truth Logging:
ACTIVE

Estimator GNSS Authorization:
BLOCKED

Navigation Mode:
NAVGUARD_MODE
```

This combination is valid and intentional. *(Bu birleşim geçerli ve bilinçlidir.)*

---

# 81. GNSS Recovery Definition (GNSS Geri Kazanımı Tanımı)

GNSS recovery means restoring estimator permission to consume validated GNSS after the denied interval. *(GNSS geri kazanımı kesintili aralıktan sonra tahmin motorunun doğrulanmış GNSS kullanma izninin geri verilmesi anlamına gelir.)*

It does not necessarily mean that the physical receiver has just reacquired satellite signals. *(Bu fiziksel alıcının uydu sinyallerini henüz yeniden elde ettiği anlamına gelmek zorunda değildir.)*

In Evaluation Mode, physical GNSS may have remained available throughout the entire denied period. *(Değerlendirme Modunda fiziksel GNSS tüm kesintili dönem boyunca kullanılabilir kalmış olabilir.)*

---

# 82. Recovery Request (Geri Kazanım İsteği)

A recovery request will move the navigation state into `GNSS_RECOVERY_PENDING`. *(Bir geri kazanım isteği navigasyon durumunu `GNSS_RECOVERY_PENDING` durumuna taşıyacaktır.)*

The Ground Truth Firewall will remain blocked during initial recovery validation. *(Gerçek Referans Güvenlik Duvarı ilk geri kazanım doğrulaması sırasında engelli kalacaktır.)*

The first available GNSS fix will not automatically be injected into the estimator. *(İlk mevcut GNSS fix’i otomatik olarak tahmin motoruna enjekte edilmeyecektir.)*

---

# 83. Recovery Fix Validation (Geri Kazanım Fix Doğrulaması)

A recovery fix must satisfy explicit quality rules. *(Bir geri kazanım fix’i açık kalite kurallarını karşılamalıdır.)*

The fix must be fresh. *(Fix yeni olmalıdır.)*

The fix must have valid horizontal position and horizontal accuracy. *(Fix geçerli yatay konuma ve yatay doğruluğa sahip olmalıdır.)*

The reported horizontal accuracy must satisfy the configured recovery requirement. *(Raporlanan yatay doğruluk yapılandırılmış geri kazanım gereksinimini karşılamalıdır.)*

Additional recent-fix consistency may be required if pilot testing shows that single-fix recovery is unstable. *(Pilot test tek fix geri kazanımının kararsız olduğunu gösterirse ek son-fix tutarlılığı gerekebilir.)*

---

# 84. Recovery Threshold Policy (Geri Kazanım Eşiği Politikası)

The final recovery-accuracy and freshness thresholds will be based on measured GNSS behavior. *(Nihai geri kazanım doğruluk ve güncellik eşikleri ölçülen GNSS davranışına dayanacaktır.)*

Anchor and recovery thresholds do not necessarily have to be identical. *(Çapa ve geri kazanım eşiklerinin mutlaka aynı olması gerekmez.)*

Their values will be frozen before formal benchmark execution. *(Değerleri resmî benchmark çalıştırılmadan önce sabitlenecektir.)*

---

# 85. Recovery Stability Window (Geri Kazanım Kararlılık Penceresi)

The target recovery strategy may require multiple consistent valid GNSS fixes before relocalization. *(Hedef geri kazanım stratejisi yeniden konumlandırmadan önce birden fazla tutarlı geçerli GNSS fix’i gerektirebilir.)*

This can reduce the risk of relocalizing to one transiently poor point. *(Bu geçici olarak kötü olan tek bir noktaya yeniden konumlandırma riskini azaltabilir.)*

The additional delay must be balanced against responsiveness. *(Ek gecikme tepki verebilirlikle dengelenmelidir.)*

---

# 86. Pre-Correction Position Capture (Düzeltme Öncesi Konum Yakalama)

Before any recovery GNSS measurement changes the estimator, NAVGUARD must preserve the current GNSS-denied estimate. *(Herhangi bir geri kazanım GNSS ölçümü tahmin motorunu değiştirmeden önce NAVGUARD mevcut GNSS kesintili tahmini korumalıdır.)*

```
p_est_pre_correction
```

The accepted recovery GNSS position must also be transformed into the same ENU frame. *(Kabul edilen geri kazanım GNSS konumu da aynı ENU çerçevesine dönüştürülmelidir.)*

```
p_gnss_recovery
```

---

# 87. Recovery Position Error (Geri Kazanım Konum Hatası)

The pre-correction recovery error will be calculated as follows. *(Düzeltme öncesi geri kazanım hatası aşağıdaki şekilde hesaplanacaktır.)*

```
e_recovery =
|| p_est_pre_correction - p_gnss_recovery ||
```

For horizontal NAVGUARD evaluation, the corresponding expression is as follows. *(Yatay NAVGUARD değerlendirmesi için karşılık gelen ifade aşağıdaki gibidir.)*

```
e_recovery =
√(
(E_est - E_gnss)²
+
(N_est - N_gnss)²
)
```

---

# 88. Recovery Error Must Precede Correction (Geri Kazanım Hatası Düzeltmeden Önce Gelmelidir)

Relocalization must not modify the estimator before the pre-correction error is recorded. *(Düzeltme öncesi hata kaydedilmeden yeniden konumlandırma tahmin motorunu değiştirmemelidir.)*

Otherwise, NAVGUARD would erase evidence of accumulated GNSS-denied drift. *(Aksi halde NAVGUARD birikmiş GNSS kesintili sürüklenme kanıtını silmiş olur.)*

This ordering is mandatory for formal evaluation. *(Bu sıralama resmî değerlendirme için zorunludur.)*

---

# 89. Recovery Data Event (Geri Kazanım Veri Olayı)

A successful recovery validation will generate a structured event. *(Başarılı geri kazanım doğrulaması yapılandırılmış bir olay üretecektir.)*

```
GNSS_RECOVERY_ACCEPTED
- timestamp
- recoveryFixId
- horizontalAccuracy
- preCorrectionEastError
- preCorrectionNorthError
- preCorrectionHorizontalError
```

The event will exist before the relocalization-completed event. *(Olay yeniden konumlandırma tamamlandı olayından önce mevcut olacaktır.)*

---

# 90. Relocalization Boundary (Yeniden Konumlandırma Sınırı)

The GNSS subsystem will provide validated recovery measurements but will not independently decide the final estimator-correction mathematics. *(GNSS alt sistemi doğrulanmış geri kazanım ölçümleri sağlayacak ancak nihai tahmin motoru düzeltme matematiğine bağımsız olarak karar vermeyecektir.)*

The detailed correction strategy belongs to **29 — GNSS Recovery & Relocalization** and the fusion architecture. *(Ayrıntılı düzeltme stratejisi **29 — GNSS Recovery & Relocalization** ve füzyon mimarisine aittir.)*

---

# 91. Direct Re-Anchoring Fallback (Doğrudan Yeniden Çapalama Geri Dönüşü)

If advanced relocalization is not ready, NAVGUARD may use direct re-anchoring as the minimum recovery mechanism. *(Gelişmiş yeniden konumlandırma hazır değilse NAVGUARD minimum geri kazanım mekanizması olarak doğrudan yeniden çapalama kullanabilir.)*

This fallback must still preserve the pre-correction error and historical denied trajectory. *(Bu geri dönüş yine de düzeltme öncesi hatayı ve geçmiş kesintili rotayı korumalıdır.)*

---

# 92. Historical Trajectory Immutability (Geçmiş Rotanın Değişmezliği)

Recovery GNSS must never be used to retrospectively move historical NAVGUARD positions so that the denied trajectory appears more accurate. *(Geri kazanım GNSS’i geçmiş NAVGUARD konumlarını geriye dönük hareket ettirerek kesintili rotayı daha doğru göstermek için hiçbir zaman kullanılmamalıdır.)*

Historical estimates are experimental evidence. *(Geçmiş tahminler deneysel kanıttır.)*

Relocalization affects current and future estimator state only. *(Yeniden konumlandırma yalnızca mevcut ve gelecekteki tahmin motoru durumunu etkiler.)*

---

# 93. GNSS Recovery Failure (GNSS Geri Kazanım Başarısızlığı)

If valid GNSS cannot be obtained during recovery, the estimator must not receive an invalid fix merely to exit NAVGUARD Mode. *(Geri kazanım sırasında geçerli GNSS elde edilemezse tahmin motoru yalnızca NAVGUARD Modundan çıkmak için geçersiz bir fix almamalıdır.)*

The system may remain in `GNSS_RECOVERY_PENDING` or continue local navigation according to the experiment controller. *(Sistem `GNSS_RECOVERY_PENDING` durumunda kalabilir veya deney controller’ına göre yerel navigasyona devam edebilir.)*

The UI must indicate that GNSS recovery has not yet been validated. *(UI GNSS geri kazanımının henüz doğrulanmadığını göstermelidir.)*

---

# 94. Recovery Timeout Policy (Geri Kazanım Timeout Politikası)

A configurable recovery timeout may be used to prevent indefinite waiting. *(Belirsiz süre beklemeyi önlemek için yapılandırılabilir bir geri kazanım timeout değeri kullanılabilir.)*

The exact timeout will be selected after physical GNSS acquisition tests. *(Kesin timeout fiziksel GNSS veri toplama testlerinden sonra seçilecektir.)*

A timeout will not force acceptance of a poor fix. *(Bir timeout düşük kaliteli bir fix’in zorla kabul edilmesine neden olmayacaktır.)*

---

# 95. GNSS Diagnostic UI (GNSS Tanı Arayüzü)

The research interface may display current GNSS diagnostic information. *(Araştırma arayüzü mevcut GNSS tanısal bilgisini gösterebilir.)*

Useful values may include current reported horizontal accuracy, fix age, satellite count, used-in-fix count, GNSS quality state, and current provider status. *(Kullanışlı değerler mevcut raporlanan yatay doğruluğu, fix yaşını, uydu sayısını, fix’te kullanılan uydu sayısını, GNSS kalite durumunu ve mevcut provider durumunu içerebilir.)*

Detailed satellite lists should remain in diagnostics rather than clutter the primary navigation interface. *(Ayrıntılı uydu listeleri temel navigasyon arayüzünü karmaşıklaştırmak yerine tanı bölümünde kalmalıdır.)*

---

# 96. User-Visible GNSS Readiness (Kullanıcıya Görünen GNSS Hazırlığı)

A simplified readiness indicator may use states such as `CHECKING`, `NOT_READY`, `READY`, and `DEGRADED`. *(Basitleştirilmiş hazırlık göstergesi `CHECKING`, `NOT_READY`, `READY` ve `DEGRADED` gibi durumları kullanabilir.)*

The underlying numerical quality evidence must remain available in developer or research diagnostics. *(Temel sayısal kalite kanıtı geliştirici veya araştırma tanısında kullanılabilir kalmalıdır.)*

---

# 97. GNSS Audit Tests (GNSS Denetim Testleri)

The Device Capability Audit will verify whether `GPS_PROVIDER` is available and enabled under normal device settings. *(Cihaz Yetenek Denetimi `GPS_PROVIDER` değerinin normal cihaz ayarlarında mevcut ve etkin olup olmadığını doğrulayacaktır.)*

The audit will measure time to first usable GNSS fix. *(Denetim ilk kullanılabilir GNSS fix’ine kadar geçen süreyi ölçecektir.)*

The audit will measure effective update intervals. *(Denetim etkin güncelleme aralıklarını ölçecektir.)*

The audit will record reported horizontal accuracy behavior. *(Denetim raporlanan yatay doğruluk davranışını kaydedecektir.)*

The audit will inspect available `GnssStatus` information. *(Denetim mevcut `GnssStatus` bilgisini inceleyecektir.)*

---

# 98. Time to First Fix Metric (İlk Fix Süresi Metriği)

NAVGUARD may measure time from GNSS acquisition start to the first fix satisfying the current acceptance rules. *(NAVGUARD GNSS veri toplama başlangıcından mevcut kabul kurallarını karşılayan ilk fix’e kadar geçen süreyi ölçebilir.)*

```
TTFF_usable =
t_first_accepted_fix
-
t_gnss_start
```

This project-specific usable-fix metric must be distinguished from lower-level receiver TTFF terminology where necessary. *(Bu projeye özgü kullanılabilir-fix metriği gerektiğinde daha düşük seviyeli alıcı TTFF terminolojisinden ayırt edilmelidir.)*

---

# 99. Stationary GNSS Test (Sabit GNSS Testi)

A stationary outdoor GNSS recording will characterize positional scatter while the phone remains at one location. *(Sabit dış mekân GNSS kaydı telefon tek bir konumda kalırken konumsal saçılımı karakterize edecektir.)*

The test will provide evidence for anchor stability thresholds and ground-truth limitations. *(Test çapa kararlılık eşikleri ve gerçek referans sınırlamaları için kanıt sağlayacaktır.)*

---

# 100. Walking GNSS Test (Yürüyüş GNSS Testi)

A controlled walking recording will characterize GNSS update continuity during pedestrian motion. *(Kontrollü yürüyüş kaydı yaya hareketi sırasında GNSS güncelleme sürekliliğini karakterize edecektir.)*

The test will examine fix intervals, reported accuracy, trajectory smoothness, and satellite diagnostics where available. *(Test fix aralıklarını, raporlanan doğruluğu, rota düzgünlüğünü ve mevcut olduğunda uydu tanısını inceleyecektir.)*

---

# 101. Environment Variation Tests (Ortam Değişkenliği Testleri)

GNSS behavior should be observed in more than one environment when time permits. *(Zaman izin verdiğinde GNSS davranışı birden fazla ortamda gözlemlenmelidir.)*

Candidate conditions include open outdoor sky, partially obstructed outdoor areas, and indoor locations where GNSS quality may deteriorate. *(Aday koşullar açık dış mekân gökyüzü, kısmen engellenmiş dış alanlar ve GNSS kalitesinin bozulabileceği iç mekânları içerir.)*

These tests will characterize behavior rather than attempt to guarantee GNSS availability everywhere. *(Bu testler GNSS kullanılabilirliğini her yerde garanti etmeye çalışmak yerine davranışı karakterize edecektir.)*

---

# 102. Ground Truth Route Quality Requirement (Gerçek Referans Rota Kalite Gereksinimi)

Formal quantitative NAVGUARD benchmark routes should preferably be conducted where GNSS ground truth is sufficiently available to support comparison. *(Resmî nicel NAVGUARD benchmark rotaları tercihen GNSS gerçek referansının karşılaştırmayı destekleyecek kadar kullanılabilir olduğu yerlerde gerçekleştirilmelidir.)*

GNSS-denied estimator testing may still include indoor experiments, but an indoor experiment with weak ground truth must not be presented as equivalent to a high-quality outdoor reference benchmark. *(GNSS kesintili tahmin motoru testi yine de iç mekân deneyleri içerebilir ancak zayıf gerçek referansa sahip bir iç mekân deneyi yüksek kaliteli dış mekân referans benchmark’ına eşdeğer olarak sunulmamalıdır.)*

---

# 103. Indoor Experiment Reference Policy (İç Mekân Deneyi Referans Politikası)

Indoor experiments may require alternative evaluation designs if GNSS ground truth becomes unusable. *(GNSS gerçek referansı kullanılamaz hale gelirse iç mekân deneyleri alternatif değerlendirme tasarımları gerektirebilir.)*

Possible alternatives may include known route geometry, measured checkpoints, or closed-loop error. *(Olası alternatifler bilinen rota geometrisini, ölçülmüş kontrol noktalarını veya kapalı döngü hatasını içerebilir.)*

Such alternatives will be documented separately in the Field Experiment Plan rather than silently treated as GNSS ground truth. *(Bu alternatifler sessizce GNSS gerçek referansı olarak ele alınmak yerine Saha Deney Planında ayrı şekilde dokümante edilecektir.)*

---

# 104. GNSS Data Logging (GNSS Veri Kaydı)

Every formal GNSS session will preserve the raw location stream in session storage. *(Her resmî GNSS oturumu ham konum akışını oturum depolamasında koruyacaktır.)*

GNSS status diagnostics may use a separate stream because their update timing differs from `Location` fixes. *(GNSS durum tanısı güncelleme zamanlaması `Location` fix’lerinden farklı olduğu için ayrı bir akış kullanabilir.)*

---

# 105. GNSS Raw File Candidate (GNSS Ham Dosya Adayı)

```
raw/
├── gnss_ground_truth.csv
└── gnss_status.csv
```

Raw GNSS files will remain independent from processed ENU ground-truth trajectories. *(Ham GNSS dosyaları işlenmiş ENU gerçek referans rotalarından bağımsız kalacaktır.)*

---

# 106. GNSS Ground Truth CSV Candidate (GNSS Gerçek Referans CSV Adayı)

```
elapsed_realtime_ns,
wall_clock_ms,
sequence,
provider,
latitude_deg,
longitude_deg,
horizontal_accuracy_m,
altitude_m,
vertical_accuracy_m,
speed_mps,
speed_accuracy_mps,
bearing_deg,
bearing_accuracy_deg
```

Availability fields or documented missing-value handling will distinguish unavailable optional values from legitimate zeros. *(Kullanılabilirlik alanları veya dokümante edilmiş eksik değer yönetimi kullanılamayan isteğe bağlı değerleri geçerli sıfırlardan ayıracaktır.)*

---

# 107. GNSS Status CSV Candidate (GNSS Durum CSV Adayı)

```
timestamp_ns,
snapshot_sequence,
satellite_index,
constellation,
svid,
used_in_fix,
cn0_dbhz,
elevation_deg,
azimuth_deg,
carrier_frequency_hz
```

Unavailable optional values will be represented explicitly. *(Kullanılamayan isteğe bağlı değerler açıkça temsil edilecektir.)*

---

# 108. GNSS Processed Ground Truth (İşlenmiş GNSS Gerçek Referansı)

A processed evaluation stream may convert raw WGS84 ground-truth fixes into the session anchor’s ENU frame. *(İşlenmiş bir değerlendirme akışı ham WGS84 gerçek referans fix’lerini oturum çapasının ENU çerçevesine dönüştürebilir.)*

```
processed/
└── gnss_ground_truth_enu.csv
```

This processed file must retain traceability to the original GNSS samples. *(Bu işlenmiş dosya orijinal GNSS örneklerine kadar izlenebilirliği korumalıdır.)*

---

# 109. GNSS Ground Truth ENU Schema (GNSS Gerçek Referans ENU Şeması)

```
source_timestamp_ns,
source_sequence,
east_m,
north_m,
up_m,
horizontal_accuracy_m,
quality_state
```

No smoothing or interpolation will be hidden inside this transformation without being declared by the preprocessing version. *(Herhangi bir yumuşatma veya interpolasyon ön işleme sürümü tarafından belirtilmeden bu dönüşümün içine gizlenmeyecektir.)*

---

# 110. GNSS and Sensor Synchronization (GNSS ve Sensör Senkronizasyonu)

GNSS fixes and Android sensor measurements can be aligned through their common elapsed-realtime timeline. *(GNSS fix’leri ile Android sensör ölçümleri ortak elapsed-realtime zaman çizelgesi üzerinden hizalanabilir.)*

GNSS does not need to be artificially resampled to IMU frequency for the live estimator if the estimator supports asynchronous measurements. *(Tahmin motoru asenkron ölçümleri destekliyorsa GNSS’in canlı tahmin motoru için yapay olarak IMU frekansına yeniden örneklenmesine gerek yoktur.)*

The evaluation pipeline may perform controlled time alignment when comparing trajectories. *(Değerlendirme hattı rotaları karşılaştırırken kontrollü zaman hizalama gerçekleştirebilir.)*

---

# 111. Ground Truth Interpolation (Gerçek Referans Interpolasyonu)

The raw ground-truth GNSS stream will remain unmodified. *(Ham gerçek referans GNSS akışı değişmeden kalacaktır.)*

A processed comparison pipeline may interpolate reference positions for selected estimator timestamps when necessary. *(İşlenmiş karşılaştırma hattı gerektiğinde seçilen tahmin motoru zaman damgaları için referans konumları interpolate edebilir.)*

The interpolation method and maximum allowed GNSS gap will be frozen in the evaluation methodology. *(Interpolasyon yöntemi ve izin verilen maksimum GNSS boşluğu değerlendirme metodolojisinde sabitlenecektir.)*

---

# 112. No Interpolation Across Large GNSS Loss (Büyük GNSS Kaybı Boyunca Interpolasyon Olmaması)

The evaluation pipeline must not create an apparently continuous ground-truth trajectory across a long interval with no trustworthy GNSS observations. *(Değerlendirme hattı güvenilir GNSS gözlemi bulunmayan uzun bir aralık boyunca görünüşte sürekli gerçek referans rotası oluşturmamalıdır.)*

Large ground-truth gaps will remain visible and may invalidate the affected metric interval. *(Büyük gerçek referans boşlukları görünür kalacak ve etkilenen metrik aralığını geçersiz kılabilir.)*

---

# 113. GNSS Integrity Counters (GNSS Bütünlük Sayaçları)

Each formal session should maintain GNSS integrity counters. *(Her resmî oturum GNSS bütünlük sayaçları tutmalıdır.)*

```
receivedFixCount
validFixCount
staleFixCount
rejectedEstimatorFixCount
groundTruthLoggedFixCount
providerMismatchCount
recoveryRejectedFixCount
groundTruthGapCount
```

These counters will support session diagnostics and acceptance testing. *(Bu sayaçlar oturum tanısını ve kabul testini destekleyecektir.)*

---

# 114. GNSS Firewall Counter (GNSS Güvenlik Duvarı Sayacı)

The system should maintain evidence that GNSS samples were blocked from the estimator during the denied interval. *(Sistem kesintili aralık sırasında GNSS örneklerinin tahmin motorundan engellendiğine dair kanıt tutmalıdır.)*

A diagnostic counter may record how many GNSS estimator updates were intentionally rejected by the firewall. *(Bir tanısal sayaç güvenlik duvarı tarafından bilinçli olarak reddedilen GNSS tahmin motoru güncelleme sayısını kaydedebilir.)*

```
gnssBlockedEstimatorUpdateCount
```

A nonzero value during Evaluation Mode is expected and demonstrates that physical GNSS remained available while estimator access was blocked. *(Değerlendirme Modunda sıfırdan farklı bir değer beklenir ve tahmin motoru erişimi engelliyken fiziksel GNSS’in kullanılabilir kaldığını gösterir.)*

---

# 115. GNSS Leakage Counter (GNSS Sızıntı Sayacı)

The system may additionally maintain an integrity counter for unauthorized GNSS estimator updates. *(Sistem ayrıca yetkisiz GNSS tahmin motoru güncellemeleri için bir bütünlük sayacı tutabilir.)*

```
unauthorizedGnssEstimatorUpdateCount
```

The required value during every valid denied benchmark is zero. *(Her geçerli kesintili benchmark sırasında gerekli değer sıfırdır.)*

Any nonzero value invalidates the formal denied-evaluation interval. *(Sıfırdan farklı herhangi bir değer resmî kesintili değerlendirme aralığını geçersiz kılar.)*

---

# 116. GNSS Isolation Automated Test (GNSS İzolasyon Otomatik Testi)

A mandatory automated test will inject synthetic GNSS measurements while the firewall state is `BLOCKED`. *(Zorunlu bir otomatik test güvenlik duvarı durumu `BLOCKED` iken sentetik GNSS ölçümleri enjekte edecektir.)*

The test must verify that the ground-truth logger receives the measurements. *(Test gerçek referans logger’ının ölçümleri aldığını doğrulamalıdır.)*

The test must verify that the estimator receives none of the measurements. *(Test tahmin motorunun ölçümlerin hiçbirini almadığını doğrulamalıdır.)*

This is a critical experiment-integrity test. *(Bu kritik bir deney bütünlük testidir.)*

---

# 117. GNSS Anchor Automated Tests (GNSS Çapa Otomatik Testleri)

Anchor logic will be tested with valid fresh fixes. *(Çapa mantığı geçerli yeni fix’lerle test edilecektir.)*

Anchor logic will be tested with stale fixes. *(Çapa mantığı eski fix’lerle test edilecektir.)*

Anchor logic will be tested with poor reported accuracy. *(Çapa mantığı düşük raporlanan doğrulukla test edilecektir.)*

Anchor logic will be tested with missing required information. *(Çapa mantığı eksik gerekli bilgiyle test edilecektir.)*

Anchor logic will be tested with spatially unstable fix sequences if stable-window logic is implemented. *(Kararlı pencere mantığı geliştirilirse çapa mantığı uzamsal olarak kararsız fix dizileriyle test edilecektir.)*

---

# 118. GNSS Recovery Automated Tests (GNSS Geri Kazanım Otomatik Testleri)

Recovery must reject stale GNSS fixes. *(Geri kazanım eski GNSS fix’lerini reddetmelidir.)*

Recovery must reject measurements failing the configured quality gate. *(Geri kazanım yapılandırılmış kalite kapısını geçemeyen ölçümleri reddetmelidir.)*

Recovery must record the pre-correction error before relocalization. *(Geri kazanım yeniden konumlandırmadan önce düzeltme öncesi hatayı kaydetmelidir.)*

Recovery must not modify the historical denied trajectory. *(Geri kazanım geçmiş kesintili rotayı değiştirmemelidir.)*

---

# 119. Physical Device GNSS Tests (Fiziksel Cihaz GNSS Testleri)

GNSS behavior must be validated on the physical Redmi Note 9 Pro. *(GNSS davranışı fiziksel Redmi Note 9 Pro üzerinde doğrulanmalıdır.)*

An emulator cannot replace field validation of satellite reception, GNSS accuracy behavior, satellite status, or recovery characteristics. *(Bir emülatör uydu alımı, GNSS doğruluk davranışı, uydu durumu veya geri kazanım özelliklerinin saha doğrulamasının yerini alamaz.)*

---

# 120. Anchor Field Test (Çapa Saha Testi)

A dedicated test will measure how long it takes to obtain a stable acceptable anchor under open-sky conditions. *(Özel bir test açık gökyüzü koşullarında kararlı kabul edilebilir bir çapa elde etmenin ne kadar sürdüğünü ölçecektir.)*

The experiment will record reported accuracy and short-term position dispersion. *(Deney raporlanan doğruluğu ve kısa süreli konum dağılımını kaydedecektir.)*

The results will determine the final anchor acceptance configuration. *(Sonuçlar nihai çapa kabul yapılandırmasını belirleyecektir.)*

---

# 121. Recovery Field Test (Geri Kazanım Saha Testi)

A dedicated recovery test will begin with an accepted anchor and active GNSS ground truth. *(Özel bir geri kazanım testi kabul edilmiş bir çapa ve aktif GNSS gerçek referansıyla başlayacaktır.)*

Estimator GNSS access will then be blocked for a controlled interval. *(Daha sonra tahmin motoru GNSS erişimi kontrollü bir aralık boyunca engellenecektir.)*

At the end of the interval, recovery will be requested and the time to obtain a valid recovery reference will be measured. *(Aralığın sonunda geri kazanım istenecek ve geçerli geri kazanım referansı elde etme süresi ölçülecektir.)*

---

# 122. GNSS Resource Usage (GNSS Kaynak Kullanımı)

GNSS acquisition contributes to battery consumption during field sessions. *(GNSS veri toplama saha oturumları sırasında batarya tüketimine katkıda bulunur.)*

Evaluation Mode intentionally keeps GNSS active for ground-truth recording even though the estimator is blind to it. *(Değerlendirme Modu tahmin motoru GNSS’i görmese bile gerçek referans kaydı için GNSS’i bilinçli olarak aktif tutar.)*

Battery measurements must therefore interpret Evaluation Mode as a research configuration rather than a pure real-world GNSS-off power scenario. *(Bu nedenle batarya ölçümleri Değerlendirme Modunu saf gerçek dünya GNSS-kapalı güç senaryosu yerine araştırma yapılandırması olarak yorumlamalıdır.)*

---

# 123. Evaluation Mode Power Limitation (Değerlendirme Modu Güç Sınırlaması)

Power consumption measured during Evaluation Mode includes the cost of background ground-truth GNSS acquisition. *(Değerlendirme Modunda ölçülen güç tüketimi arka plandaki gerçek referans GNSS veri toplama maliyetini içerir.)*

The project must not claim that such a measurement represents the battery cost of a physically unavailable GNSS receiver. *(Proje böyle bir ölçümün fiziksel olarak kullanılamayan GNSS alıcısının batarya maliyetini temsil ettiğini iddia etmemelidir.)*

---

# 124. GNSS Privacy Boundary (GNSS Gizlilik Sınırı)

GNSS coordinates are sensitive location data and will remain locally stored by default. *(GNSS koordinatları hassas konum verisidir ve varsayılan olarak yerel olarak saklanacaktır.)*

The core NAVGUARD GNSS subsystem will not automatically upload location history to a cloud service. *(Temel NAVGUARD GNSS alt sistemi konum geçmişini otomatik olarak bulut hizmetine yüklemeyecektir.)*

Explicit export will remain the normal mechanism for transferring experiment data. *(Açık dışa aktarma deney verisini aktarmanın normal mekanizması olarak kalacaktır.)*

---

# 125. GNSS Failure Categories (GNSS Hata Kategorileri)

```
GNSS_PROVIDER_DISABLED
GNSS_PERMISSION_DENIED
GNSS_NO_FIX
GNSS_STALE_FIX
GNSS_POOR_ACCURACY
GNSS_STREAM_LOST
GNSS_GROUND_TRUTH_GAP
GNSS_PROVIDER_MISMATCH
GNSS_RECOVERY_TIMEOUT
GNSS_FIREWALL_VIOLATION
GNSS_STATUS_UNAVAILABLE
RAW_GNSS_UNAVAILABLE
```

Failure codes will support structured diagnostics. *(Hata kodları yapılandırılmış tanıyı destekleyecektir.)*

---

# 126. GNSS Failure Severity (GNSS Hata Ciddiyeti)

A temporary poor-accuracy fix may generate a warning without stopping acquisition. *(Geçici düşük doğruluklu bir fix veri toplamayı durdurmadan uyarı oluşturabilir.)*

Failure to acquire an initial acceptable anchor will prevent formal denied navigation from starting. *(Başlangıçta kabul edilebilir bir çapa elde edilememesi resmî kesintili navigasyonun başlamasını engelleyecektir.)*

Loss of ground truth during a formal evaluation may degrade or invalidate the affected benchmark interval. *(Resmî değerlendirme sırasında gerçek referans kaybı etkilenen benchmark aralığını bozabilir veya geçersiz kılabilir.)*

A Ground Truth Firewall violation will invalidate the formal denied-evaluation interval. *(Bir Gerçek Referans Güvenlik Duvarı ihlali resmî kesintili değerlendirme aralığını geçersiz kılacaktır.)*

---

# 127. GNSS Fallback Behavior (GNSS Geri Dönüş Davranışı)

Failure of GNSS after a valid initial anchor does not automatically stop local NAVGUARD estimation. *(Geçerli bir başlangıç çapasından sonra GNSS’in başarısız olması yerel NAVGUARD tahminini otomatik olarak durdurmaz.)*

This is precisely the condition the GNSS-denied navigation system is intended to tolerate for a limited period. *(Bu tam olarak GNSS kesintili navigasyon sisteminin sınırlı bir süre boyunca tolere etmek üzere tasarlandığı durumdur.)*

However, loss of independent GNSS ground truth may reduce the ability to quantitatively evaluate the session. *(Bununla birlikte bağımsız GNSS gerçek referansının kaybı oturumu nicel olarak değerlendirme yeteneğini azaltabilir.)*

---

# 128. Automatic Natural GNSS Degradation Detection (Otomatik Doğal GNSS Bozulma Tespiti)

NAVGUARD may later implement automatic detection of naturally degraded GNSS. *(NAVGUARD daha sonra doğal olarak bozulmuş GNSS’in otomatik tespitini geliştirebilir.)*

Candidate evidence may include fix age, reported accuracy, loss of fixes, satellite diagnostics, and temporal consistency. *(Aday kanıt fix yaşını, raporlanan doğruluğu, fix kaybını, uydu tanısını ve zamansal tutarlılığı içerebilir.)*

This capability is not mandatory for the first controlled experiment workflow. *(Bu yetenek ilk kontrollü deney iş akışı için zorunlu değildir.)*

---

# 129. Why Manual GNSS Denial Comes First (Neden Önce Manuel GNSS Kesintisi Kullanılır)

Manual software-controlled denial provides an exact known transition time. *(Manuel yazılım kontrollü kesinti kesin ve bilinen bir geçiş zamanı sağlar.)*

It makes repeated A/B experiments easier to reproduce. *(Tekrarlanan A/B deneylerinin yeniden üretilmesini kolaylaştırır.)*

It also allows real GNSS to remain available as reference evidence. *(Ayrıca gerçek GNSS’in referans kanıtı olarak kullanılabilir kalmasını sağlar.)*

---

# 130. Natural GNSS Loss as Future Extension (Doğal GNSS Kaybı Gelecek Genişletmesi)

After the controlled system is validated, naturally occurring GNSS degradation may be tested as an additional research condition. *(Kontrollü sistem doğrulandıktan sonra doğal olarak meydana gelen GNSS bozulması ek araştırma koşulu olarak test edilebilir.)*

The automatic detection mechanism must remain distinguishable from the estimator that operates after denial. *(Otomatik tespit mekanizması kesintiden sonra çalışan tahmin motorundan ayırt edilebilir kalmalıdır.)*

---

# 131. GNSS Quality and Sensor Confidence (GNSS Kalitesi ve Sensör Güveni)

GNSS quality information may later contribute to the Sensor Confidence and Quality Engine. *(GNSS kalite bilgisi daha sonra Sensör Güven ve Kalite Motoruna katkıda bulunabilir.)*

During GNSS-enabled operation, poor GNSS quality may reduce the weight of GNSS measurements in a fusion estimator. *(GNSS etkin çalışma sırasında düşük GNSS kalitesi bir füzyon tahmin motorunda GNSS ölçümlerinin ağırlığını azaltabilir.)*

During GNSS-denied operation, quality information must not reopen estimator GNSS access. *(GNSS kesintili çalışma sırasında kalite bilgisi tahmin motoru GNSS erişimini yeniden açmamalıdır.)*

Authorization always takes precedence over confidence weighting. *(Yetkilendirme her zaman güven ağırlıklandırmasına göre önceliklidir.)*

---

# 132. Authorization Before Quality (Kaliteden Önce Yetkilendirme)

The estimator input process will conceptually follow this order. *(Tahmin motoru girdi işlemi kavramsal olarak bu sırayı izleyecektir.)*

```
GNSS Measurement
      │
      ▼
Authorization Gate
      │
      ├── BLOCKED ──► Reject From Estimator
      │
      ▼
    ALLOWED
      │
      ▼
Quality Validation
      │
      ├── INVALID ──► Reject
      │
      ▼
     VALID
      │
      ▼
Estimator Update
```

A high-quality GNSS fix cannot bypass a blocked authorization gate. *(Yüksek kaliteli bir GNSS fix’i engellenmiş yetkilendirme kapısını geçemez.)*

---

# 133. GNSS and EKF Boundary (GNSS ve EKF Sınırı)

The GNSS subsystem will produce validated metric position measurements and associated quality metadata. *(GNSS alt sistemi doğrulanmış metrik konum ölçümleri ve ilişkili kalite metadata bilgisi üretecektir.)*

The EKF will decide how an authorized valid measurement updates the filter state. *(EKF yetkilendirilmiş geçerli bir ölçümün filtre durumunu nasıl güncelleyeceğine karar verecektir.)*

This preserves separation between GNSS quality control and general sensor-fusion mathematics. *(Bu GNSS kalite kontrolü ile genel sensör füzyonu matematiği arasındaki ayrımı korur.)*

---

# 134. GNSS and PDR Boundary (GNSS ve PDR Sınırı)

GNSS establishes the initial global anchor but does not calculate PDR step displacement. *(GNSS başlangıç global çapasını oluşturur ancak PDR adım yer değiştirmesini hesaplamaz.)*

PDR operates in local East-North coordinates after anchoring. *(PDR çapa oluşturulduktan sonra yerel Doğu-Kuzey koordinatlarında çalışır.)*

Ground-truth GNSS remains an external comparison stream during the denied period. *(Gerçek referans GNSS kesintili dönem boyunca harici karşılaştırma akışı olarak kalır.)*

---

# 135. GNSS and Heading Boundary (GNSS ve Yön Sınırı)

GNSS motion bearing may be used as an experimental heading reference when the user is moving sufficiently and the bearing quality is suitable. *(Kullanıcı yeterince hareket ediyorsa ve bearing kalitesi uygunsa GNSS hareket yönü deneysel yön referansı olarak kullanılabilir.)*

It will not be treated as a continuously valid device-heading sensor. *(Sürekli geçerli cihaz yön sensörü olarak ele alınmayacaktır.)*

Detailed heading-reference rules belong to **18 — Heading Estimation System**. *(Ayrıntılı yön referansı kuralları **18 — Heading Estimation System** bölümüne aittir.)*

---

# 136. GNSS Ground Truth and Training Data (GNSS Gerçek Referansı ve Eğitim Verisi)

GNSS data may help create derived route or speed labels for selected offline research tasks. *(GNSS verisi seçilen çevrimdışı araştırma görevleri için türetilmiş rota veya hız etiketleri oluşturmaya yardımcı olabilir.)*

GNSS ground truth must not become an unavailable hidden input to a model intended to operate during GNSS denial. *(GNSS gerçek referansı GNSS kesintisi sırasında çalışması amaçlanan bir model için kullanılamayan gizli bir girdi haline gelmemelidir.)*

Training features available only from GNSS must not be included in a model expected to run without GNSS. *(Yalnızca GNSS’ten elde edilebilen eğitim özellikleri GNSS olmadan çalışması beklenen bir modele dahil edilmemelidir.)*

---

# 137. Data Leakage Prevention (Veri Sızıntısı Önleme)

Offline evaluation scripts must preserve the same logical GNSS-denial boundary used by the live application. *(Çevrimdışı değerlendirme script’leri canlı uygulama tarafından kullanılan aynı mantıksal GNSS kesinti sınırını korumalıdır.)*

A replayed denied estimator must not receive future or ground-truth GNSS simply because the data exists in the session files. *(Replay edilen kesintili tahmin motoru veri oturum dosyalarında mevcut olduğu için gelecekteki veya gerçek referans GNSS’i almamalıdır.)*

The replay engine must enforce the navigation profile and firewall events recorded in the session. *(Replay motoru oturumda kaydedilen navigasyon profilini ve güvenlik duvarı olaylarını uygulamalıdır.)*

---

# 138. Evaluation Reproducibility Rule (Değerlendirme Tekrarlanabilirlik Kuralı)

The same recorded session and navigation profile must reproduce the same GNSS authorization intervals during replay. *(Aynı kaydedilmiş oturum ve navigasyon profili replay sırasında aynı GNSS yetkilendirme aralıklarını yeniden üretmelidir.)*

This allows estimator improvements to be compared on identical GNSS-denial windows. *(Bu tahmin motoru iyileştirmelerinin aynı GNSS kesinti pencerelerinde karşılaştırılmasına olanak sağlar.)*

---

# 139. GNSS Session Configuration Snapshot (GNSS Oturum Yapılandırma Anlık Görüntüsü)

Every formal session should record the active GNSS configuration. *(Her resmî oturum aktif GNSS yapılandırmasını kaydetmelidir.)*

```
gnssProvider
requestedUpdateInterval
anchorAccuracyRequirement
anchorFreshnessRequirement
anchorStabilityMethod
recoveryAccuracyRequirement
recoveryFreshnessRequirement
groundTruthLoggingEnabled
rawGnssDiagnosticsEnabled
gnssStatusLoggingEnabled
```

Measured rather than merely requested update behavior will remain available in session diagnostics. *(Yalnızca talep edilen değil ölçülen güncelleme davranışı oturum tanısında kullanılabilir kalacaktır.)*

---

# 140. Configuration Freeze (Yapılandırma Sabitleme)

Formal benchmark GNSS configuration will be frozen when the session begins. *(Resmî benchmark GNSS yapılandırması oturum başladığında sabitlenecektir.)*

Anchor or recovery thresholds must not change silently during one benchmark. *(Çapa veya geri kazanım eşikleri tek bir benchmark sırasında sessizce değişmemelidir.)*

Any intentional configuration change must create an explicit event or new session. *(Her bilinçli yapılandırma değişikliği açık bir olay veya yeni oturum oluşturmalıdır.)*

---

# 141. Minimum GNSS Subsystem (Minimum GNSS Alt Sistemi)

The minimum GNSS subsystem must acquire `GPS_PROVIDER` locations. *(Minimum GNSS alt sistemi `GPS_PROVIDER` konumlarını toplamalıdır.)*

It must preserve elapsed-realtime timestamps. *(Elapsed-realtime zaman damgalarını korumalıdır.)*

It must record reported horizontal accuracy. *(Raporlanan yatay doğruluğu kaydetmelidir.)*

It must establish an initial anchor. *(Bir başlangıç çapası oluşturmalıdır.)*

It must maintain an independent ground-truth stream. *(Bağımsız bir gerçek referans akışı tutmalıdır.)*

It must implement the estimator authorization gate. *(Tahmin motoru yetkilendirme kapısını geliştirmelidir.)*

It must support controlled recovery. *(Kontrollü geri kazanımı desteklemelidir.)*

---

# 142. Target GNSS Subsystem (Hedef GNSS Alt Sistemi)

The target GNSS subsystem will additionally include `GnssStatus` satellite diagnostics. *(Hedef GNSS alt sistemi ayrıca `GnssStatus` uydu tanısını içerecektir.)*

It will include measured quality classification. *(Ölçülmüş kalite sınıflandırmasını içerecektir.)*

It will include stable multi-fix anchor validation if pilot testing justifies it. *(Pilot test gerekçelendirirse kararlı çoklu-fix çapa doğrulamasını içerecektir.)*

It will include robust multi-fix recovery validation if needed. *(Gerekirse robust çoklu-fix geri kazanım doğrulamasını içerecektir.)*

It may include optional raw GNSS diagnostic logging. *(İsteğe bağlı ham GNSS tanısal kaydını içerebilir.)*

---

# 143. Optional GNSS Capabilities (İsteğe Bağlı GNSS Yetenekleri)

Raw satellite measurement logging is optional. *(Ham uydu ölçüm kaydı isteğe bağlıdır.)*

GNSS antenna-information analysis is optional. *(GNSS anten bilgi analizi isteğe bağlıdır.)*

Advanced signal-quality analysis is optional. *(Gelişmiş sinyal kalite analizi isteğe bağlıdır.)*

Automatic natural GNSS degradation detection is optional. *(Otomatik doğal GNSS bozulma tespiti isteğe bağlıdır.)*

These capabilities must not delay the mandatory GNSS-denied evaluation workflow. *(Bu yetenekler zorunlu GNSS kesintili değerlendirme iş akışını geciktirmemelidir.)*

---

# 144. GNSS Non-Goals (GNSS Olmayan Hedefler)

NAVGUARD will not develop a new GNSS receiver. *(NAVGUARD yeni bir GNSS alıcısı geliştirmeyecektir.)*

NAVGUARD will not perform RF jamming or spoofing. *(NAVGUARD RF karıştırma veya spoofing gerçekleştirmeyecektir.)*

NAVGUARD will not claim survey-grade or military-grade GNSS accuracy. *(NAVGUARD ölçme sınıfı veya askerî sınıf GNSS doğruluğu iddia etmeyecektir.)*

NAVGUARD will not implement complete standalone raw-GNSS positioning as an MVP requirement. *(NAVGUARD tam bağımsız ham-GNSS konumlandırmayı MVP gereksinimi olarak geliştirmeyecektir.)*

---

# 145. GNSS Acceptance Criteria (GNSS Kabul Kriterleri)

The physical Redmi Note 9 Pro must successfully deliver GNSS fixes through the configured provider. *(Fiziksel Redmi Note 9 Pro yapılandırılmış provider üzerinden GNSS fix’lerini başarıyla sağlamalıdır.)*

Every formal fix must preserve its monotonic timestamp. *(Her resmî fix monotonik zaman damgasını korumalıdır.)*

Every formal ground-truth fix must preserve reported horizontal accuracy. *(Her resmî gerçek referans fix’i raporlanan yatay doğruluğu korumalıdır.)*

The initial anchor must pass explicit validation. *(Başlangıç çapası açık doğrulamayı geçmelidir.)*

The ground-truth logger must continue independently while estimator GNSS access is blocked. *(Gerçek referans logger’ı tahmin motoru GNSS erişimi engelliyken bağımsız olarak devam etmelidir.)*

---

# 146. GNSS Isolation Acceptance Criteria (GNSS İzolasyon Kabul Kriterleri)

No GNSS position update may reach the denied estimator during the protected evaluation interval. *(Korunan değerlendirme aralığında hiçbir GNSS konum güncellemesi kesintili tahmin motoruna ulaşmamalıdır.)*

The ground-truth logger must still receive available GNSS measurements during the same interval. *(Gerçek referans logger’ı aynı aralık sırasında mevcut GNSS ölçümlerini almaya devam etmelidir.)*

The mode-event log must identify the exact firewall-block timestamp. *(Mod olay kaydı kesin güvenlik duvarı engelleme zaman damgasını tanımlamalıdır.)*

The unauthorized GNSS estimator update count must remain zero. *(Yetkisiz GNSS tahmin motoru güncelleme sayısı sıfır kalmalıdır.)*

---

# 147. GNSS Recovery Acceptance Criteria (GNSS Geri Kazanım Kabul Kriterleri)

Recovery must use a fresh GNSS measurement satisfying the frozen recovery policy. *(Geri kazanım sabitlenmiş geri kazanım politikasını karşılayan yeni bir GNSS ölçümü kullanmalıdır.)*

The pre-correction position error must be recorded before any relocalization. *(Herhangi bir yeniden konumlandırmadan önce düzeltme öncesi konum hatası kaydedilmelidir.)*

Historical GNSS-denied estimates must remain unchanged. *(Geçmiş GNSS kesintili tahminler değişmeden kalmalıdır.)*

Estimator GNSS access must become fully allowed only after controlled recovery completes. *(Tahmin motoru GNSS erişimi yalnızca kontrollü geri kazanım tamamlandıktan sonra tamamen izinli hale gelmelidir.)*

---

# 148. GNSS Data Integrity Acceptance Criteria (GNSS Veri Bütünlüğü Kabul Kriterleri)

Raw GNSS and processed GNSS data must remain distinguishable. *(Ham GNSS ve işlenmiş GNSS verileri ayırt edilebilir kalmalıdır.)*

Missing optional values must remain distinguishable from zero. *(Eksik isteğe bağlı değerler sıfırdan ayırt edilebilir kalmalıdır.)*

Ground-truth fixes must remain traceable to original Android location events. *(Gerçek referans fix’leri orijinal Android konum olaylarına kadar izlenebilir kalmalıdır.)*

Processed ENU reference positions must identify their source fix and active anchor. *(İşlenmiş ENU referans konumları kaynak fix’lerini ve aktif çapalarını tanımlamalıdır.)*

---

# 149. Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kararlar)

Formal GNSS acquisition will use native Android `LocationManager`. *(Resmî GNSS veri toplama native Android `LocationManager` kullanacaktır.)*

Formal satellite-based location acquisition will explicitly use `GPS_PROVIDER`. *(Resmî uydu tabanlı konum veri toplama açıkça `GPS_PROVIDER` kullanacaktır.)*

GNSS ground truth and estimator GNSS input will use separate logical paths. *(GNSS gerçek referansı ile tahmin motoru GNSS girdisi ayrı mantıksal yollar kullanacaktır.)*

`Location.getElapsedRealtimeNanos()` will be the authoritative within-session GNSS timestamp. *(`Location.getElapsedRealtimeNanos()` oturum içindeki ana GNSS zaman damgası olacaktır.)*

Reported horizontal accuracy will be preserved as uncertainty metadata. *(Raporlanan yatay doğruluk belirsizlik metadata bilgisi olarak korunacaktır.)*

The first received GNSS fix will not automatically become the formal anchor. *(Alınan ilk GNSS fix’i otomatik olarak resmî çapa olmayacaktır.)*

---

# 150. Additional Frozen Decisions (Ek Sabitlenmiş Kararlar)

GNSS denial will occur through software estimator exclusion rather than RF interference. *(GNSS kesintisi RF müdahalesi yerine yazılım tahmin motoru dışlaması üzerinden gerçekleşecektir.)*

Ground-truth logging will continue during Evaluation Mode when physical GNSS remains available. *(Fiziksel GNSS kullanılabilir kaldığında Değerlendirme Modu sırasında gerçek referans kaydı devam edecektir.)*

A high-quality GNSS fix will not bypass a blocked estimator authorization gate. *(Yüksek kaliteli bir GNSS fix’i engellenmiş tahmin motoru yetkilendirme kapısını aşmayacaktır.)*

Recovery error will be recorded before relocalization. *(Geri kazanım hatası yeniden konumlandırmadan önce kaydedilecektir.)*

Raw GNSS measurements will remain optional rather than becoming a mandatory project dependency. *(Ham GNSS ölçümleri zorunlu proje bağımlılığı haline gelmek yerine isteğe bağlı kalacaktır.)*

---

# 151. Decisions Pending Measurement (Ölçüm Bekleyen Kararlar)

The final anchor horizontal-accuracy threshold remains pending Redmi Note 9 Pro field testing. *(Nihai çapa yatay doğruluk eşiği Redmi Note 9 Pro saha testini beklemektedir.)*

The final anchor freshness threshold remains pending measured GNSS cadence. *(Nihai çapa güncellik eşiği ölçülen GNSS kadansını beklemektedir.)*

The final anchor stability-window duration remains pending pilot tests. *(Nihai çapa kararlılık penceresi süresi pilot testleri beklemektedir.)*

The final recovery quality thresholds remain pending field measurements. *(Nihai geri kazanım kalite eşikleri saha ölçümlerini beklemektedir.)*

The final GNSS quality-category boundaries remain pending collected data. *(Nihai GNSS kalite kategori sınırları toplanmış veriyi beklemektedir.)*

The practical ground-truth update rate remains pending physical-device measurement. *(Pratik gerçek referans güncelleme hızı fiziksel cihaz ölçümünü beklemektedir.)*

---

# 152. Source Basis (Kaynak Temeli)

The use of `LocationManager.GPS_PROVIDER` as the explicit GNSS satellite provider is based on the current official Android `LocationManager` documentation. *(`LocationManager.GPS_PROVIDER` değerinin açık GNSS uydu sağlayıcısı olarak kullanımı güncel resmî Android `LocationManager` dokümantasyonuna dayanmaktadır.)*

The horizontal-accuracy definition and monotonic GNSS timing model are based on the current official Android `Location` documentation. *(Yatay doğruluk tanımı ve monotonik GNSS zamanlama modeli güncel resmî Android `Location` dokümantasyonuna dayanmaktadır.)*

The satellite diagnostic fields are based on the current official Android `GnssStatus` documentation. *(Uydu tanısal alanları güncel resmî Android `GnssStatus` dokümantasyonuna dayanmaktadır.)*

The optional raw-GNSS architecture is based on the current official Android `GnssMeasurementsEvent` documentation. *(İsteğe bağlı ham-GNSS mimarisi güncel resmî Android `GnssMeasurementsEvent` dokümantasyonuna dayanmaktadır.)*

---

# 153. Final GNSS Subsystem Statement (Nihai GNSS Alt Sistemi Bildirimi)

**NAVGUARD will use native Android `LocationManager` with the explicit GNSS `GPS_PROVIDER` to obtain satellite-based WGS84 position measurements for initialization, normal GNSS navigation, independent experimental ground truth, and controlled recovery.** *(NAVGUARD başlatma, normal GNSS navigasyonu, bağımsız deneysel gerçek referans ve kontrollü geri kazanım için uydu tabanlı WGS84 konum ölçümlerini elde etmek amacıyla açık GNSS `GPS_PROVIDER` ile native Android `LocationManager` kullanacaktır.)*

**Every formal GNSS measurement will preserve its monotonic elapsed-realtime timestamp, reported horizontal accuracy, provider identity, and available optional motion or altitude information before any quality filtering or coordinate conversion.** *(Her resmî GNSS ölçümü herhangi bir kalite filtreleme veya koordinat dönüşümünden önce monotonik elapsed-realtime zaman damgasını, raporlanan yatay doğruluğunu, provider kimliğini ve mevcut isteğe bağlı hareket veya yükseklik bilgisini koruyacaktır.)*

**The initial GNSS anchor will be accepted only after explicit freshness, accuracy, and stability validation rather than automatically using the first received location fix.** *(Başlangıç GNSS çapası alınan ilk konum fix’ini otomatik olarak kullanmak yerine yalnızca açık güncellik, doğruluk ve kararlılık doğrulamasından sonra kabul edilecektir.)*

**During Evaluation Mode, physical GNSS acquisition and ground-truth logging may remain active while an explicit Ground Truth Firewall makes GNSS logically inaccessible to the active NAVGUARD estimator.** *(Değerlendirme Modu sırasında fiziksel GNSS veri toplama ve gerçek referans kaydı aktif kalabilirken açık bir Gerçek Referans Güvenlik Duvarı GNSS’i aktif NAVGUARD tahmin motoru için mantıksal olarak erişilemez hale getirecektir.)*

**GNSS recovery will validate fresh measurements, preserve the final pre-correction NAVGUARD position, calculate recovery error, and only then permit controlled relocalization.** *(GNSS geri kazanımı yeni ölçümleri doğrulayacak, son düzeltme öncesi NAVGUARD konumunu koruyacak, geri kazanım hatasını hesaplayacak ve ancak bundan sonra kontrollü yeniden konumlandırmaya izin verecektir.)*

---

# 154. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development GNSS Subsystem Completed *(Doküman Durumu: Geliştirme Öncesi GNSS Alt Sistemi Tamamlandı)*

**Authoritative GNSS Interface:** Android `LocationManager` *(Ana GNSS Arayüzü: Android `LocationManager`)*

**Formal GNSS Provider:** `GPS_PROVIDER` *(Resmî GNSS Provider’ı: `GPS_PROVIDER`)*

**Authoritative Timing:** `Location.getElapsedRealtimeNanos()` *(Ana Zamanlama: `Location.getElapsedRealtimeNanos()`)*

**Global Coordinate Reference:** WGS84 *(Global Koordinat Referansı: WGS84)*

**Initial Anchor Policy:** Explicit Quality Validation Required *(Başlangıç Çapa Politikası: Açık Kalite Doğrulaması Gerekli)*

**Ground Truth Policy:** Independent Continuous GNSS Logging During Evaluation When Available *(Gerçek Referans Politikası: Mevcut Olduğunda Değerlendirme Sırasında Bağımsız Sürekli GNSS Kaydı)*

**Estimator Isolation:** Explicit Ground Truth Firewall *(Tahmin Motoru İzolasyonu: Açık Gerçek Referans Güvenlik Duvarı)*

**GNSS Denial Method:** Software Estimator Exclusion *(GNSS Kesinti Yöntemi: Yazılımsal Tahmin Motoru Dışlaması)*

**Satellite Diagnostics:** Android `GnssStatus` *(Uydu Tanısı: Android `GnssStatus`)*

**Raw GNSS Measurements:** Optional Research Capability *(Ham GNSS Ölçümleri: İsteğe Bağlı Araştırma Yeteneği)*

**Recovery Rule:** Validate → Record Pre-Correction Error → Relocalize *(Geri Kazanım Kuralı: Doğrula → Düzeltme Öncesi Hatayı Kaydet → Yeniden Konumlandır)*

**Final Anchor Thresholds:** Pending Redmi Note 9 Pro Field Measurement *(Nihai Çapa Eşikleri: Redmi Note 9 Pro Saha Ölçümü Bekleniyor)*

**Final Recovery Thresholds:** Pending Field Measurement *(Nihai Geri Kazanım Eşikleri: Saha Ölçümü Bekleniyor)*

**Next Documentation Item:** 16 — Pedestrian Dead Reckoning — PDR *(Sonraki Dokümantasyon Öğesi: 16 — Yaya Ölü Hesaplama — PDR)*