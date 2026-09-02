# 05 — Target Platform & Device Baseline (Hedef Platform ve Cihaz Temel Referansı)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the target software platform, primary physical test device, verified hardware capabilities, device-dependent assumptions, and hardware constraints of the NAVGUARD project. *(Bu doküman, NAVGUARD projesinin hedef yazılım platformunu, birincil fiziksel test cihazını, doğrulanmış donanım yeteneklerini, cihaza bağlı varsayımları ve donanım kısıtlarını tanımlar.)*

The purpose of this document is to establish a stable hardware and platform baseline before sensor acquisition, navigation algorithms, artificial intelligence models, and field experiments are designed in detail. *(Bu dokümanın amacı, sensör veri toplama, navigasyon algoritmaları, yapay zekâ modelleri ve saha deneyleri ayrıntılı olarak tasarlanmadan önce kararlı bir donanım ve platform temel referansı oluşturmaktır.)*

NAVGUARD will be developed exclusively for Android during the defined project scope. *(NAVGUARD, tanımlanan proje kapsamı boyunca yalnızca Android için geliştirilecektir.)*

The Xiaomi Redmi Note 9 Pro will be treated as the primary physical reference device for development, data collection, optimization, and final evaluation. *(Xiaomi Redmi Note 9 Pro; geliştirme, veri toplama, optimizasyon ve nihai değerlendirme için birincil fiziksel referans cihaz olarak ele alınacaktır.)*

---

# 2. Target Platform Decision (Hedef Platform Kararı)

**Target Operating System Family:** Android *(Hedef İşletim Sistemi Ailesi: Android)*

**Supported Project Platform:** Android Only *(Desteklenen Proje Platformu: Yalnızca Android)*

**Primary Mobile Framework:** Flutter *(Birincil Mobil Framework: Flutter)*

**Primary Native Integration Language:** Kotlin *(Birincil Native Entegrasyon Dili: Kotlin)*

**Primary Test Device:** Xiaomi Redmi Note 9 Pro *(Birincil Test Cihazı: Xiaomi Redmi Note 9 Pro)*

**Primary AI Execution Environment:** On-Device TensorFlow Lite Runtime *(Birincil Yapay Zekâ Çalışma Ortamı: Cihaz Üzerinde TensorFlow Lite Çalışma Ortamı)*

**Primary Visual-Inertial Platform:** Google ARCore *(Birincil Görsel-Ataletsel Platform: Google ARCore)*

---

# 3. Android-Only Development Decision (Yalnızca Android Geliştirme Kararı)

NAVGUARD will not target iOS during the 24-business-day development period. *(NAVGUARD, 24 iş günlük geliştirme süresi boyunca iOS’u hedeflemeyecektir.)*

Restricting the project to Android reduces platform-specific implementation complexity and allows deeper integration with the Android sensor and ARCore ecosystems. *(Projeyi Android ile sınırlamak platforma özgü geliştirme karmaşıklığını azaltır ve Android sensör ile ARCore ekosistemleriyle daha derin entegrasyona olanak sağlar.)*

This decision allows development time to be concentrated on sensor synchronization, navigation algorithms, artificial intelligence, sensor fusion, and experimental evaluation instead of maintaining two mobile platforms. *(Bu karar, geliştirme süresinin iki mobil platformu sürdürmek yerine sensör senkronizasyonu, navigasyon algoritmaları, yapay zekâ, sensör füzyonu ve deneysel değerlendirmeye yoğunlaştırılmasını sağlar.)*

No iOS compatibility requirement will therefore be included in the initial NAVGUARD Software Requirements Specification. *(Bu nedenle ilk NAVGUARD Yazılım Gereksinimleri Şartnamesine herhangi bir iOS uyumluluk gereksinimi dahil edilmeyecektir.)*

---

# 4. Primary Device Identification (Birincil Cihaz Tanımlaması)

**Manufacturer:** Xiaomi *(Üretici: Xiaomi)*

**Device Family:** Redmi *(Cihaz Ailesi: Redmi)*

**Device Model:** Redmi Note 9 Pro *(Cihaz Modeli: Redmi Note 9 Pro)*

**Device Role:** Primary Development and Evaluation Device *(Cihaz Rolü: Birincil Geliştirme ve Değerlendirme Cihazı)*

The physical Redmi Note 9 Pro owned for this project will be considered the authoritative runtime hardware for NAVGUARD experiments. *(Bu proje için kullanılan fiziksel Redmi Note 9 Pro, NAVGUARD deneyleri için ana çalışma zamanı donanımı olarak kabul edilecektir.)*

Published device specifications will be used only as an initial reference. *(Yayınlanmış cihaz özellikleri yalnızca başlangıç referansı olarak kullanılacaktır.)*

Runtime sensor information collected from the physical device will take precedence when software behavior differs from published specifications. *(Yazılım davranışı yayınlanmış özelliklerden farklı olduğunda fiziksel cihazdan toplanan çalışma zamanı sensör bilgileri öncelikli kabul edilecektir.)*

---

# 5. Verified Processor Baseline (Doğrulanmış İşlemci Temel Referansı)

The Redmi Note 9 Pro is based on the Qualcomm Snapdragon 720G mobile platform. *(Redmi Note 9 Pro, Qualcomm Snapdragon 720G mobil platformunu temel almaktadır.)*

The processor uses an octa-core CPU architecture with a maximum advertised frequency of up to 2.3 GHz. *(İşlemci, ilan edilen maksimum 2,3 GHz’e kadar frekansa sahip sekiz çekirdekli bir CPU mimarisi kullanır.)*

The device includes an Adreno 618 graphics processor. *(Cihaz Adreno 618 grafik işlemcisini içerir.)*

The available processing capability is expected to be sufficient for lightweight time-series artificial intelligence inference, sensor processing, mobile visualization, and the targeted navigation algorithms. *(Mevcut işlem gücünün hafif zaman serisi yapay zekâ çıkarımı, sensör işleme, mobil görselleştirme ve hedeflenen navigasyon algoritmaları için yeterli olması beklenmektedir.)*

Actual runtime performance will nevertheless be measured rather than assumed. *(Bununla birlikte gerçek çalışma zamanı performansı varsayılmak yerine ölçülecektir.)*

---

# 6. Processing Resource Philosophy (İşlem Kaynağı Yaklaşımı)

NAVGUARD will be designed for the capabilities of the target smartphone rather than for desktop-class computing hardware. *(NAVGUARD, masaüstü sınıfı hesaplama donanımı yerine hedef akıllı telefonun yeteneklerine göre tasarlanacaktır.)*

Artificial intelligence models will therefore be kept intentionally lightweight. *(Bu nedenle yapay zekâ modelleri bilinçli olarak hafif tutulacaktır.)*

Sensor processing should use streaming or window-based calculations instead of retaining unnecessary high-volume data in memory. *(Sensör işleme, gereksiz yüksek hacimli verileri bellekte tutmak yerine akış veya pencere tabanlı hesaplamalar kullanmalıdır.)*

Expensive calculations should be moved away from the Flutter user-interface thread when necessary. *(Gerekli olduğunda yüksek maliyetli hesaplamalar Flutter kullanıcı arayüzü thread’inden uzaklaştırılmalıdır.)*

Performance optimization will focus on maintaining real-time navigation behavior without unnecessary computational complexity. *(Performans optimizasyonu, gereksiz hesaplama karmaşıklığı olmadan gerçek zamanlı navigasyon davranışının korunmasına odaklanacaktır.)*

---

# 7. Verified Physical Motion Sensors (Doğrulanmış Fiziksel Hareket Sensörleri)

The official Redmi Note 9 Pro specification lists an accelerometer. *(Resmî Redmi Note 9 Pro teknik özellikleri bir ivmeölçer bulunduğunu belirtmektedir.)*

The official Redmi Note 9 Pro specification lists a gyroscope. *(Resmî Redmi Note 9 Pro teknik özellikleri bir jiroskop bulunduğunu belirtmektedir.)*

The official Redmi Note 9 Pro specification lists an electronic compass. *(Resmî Redmi Note 9 Pro teknik özellikleri bir elektronik pusula bulunduğunu belirtmektedir.)*

For NAVGUARD, the electronic compass capability is expected to expose geomagnetic or magnetometer-related information through the Android sensor framework. *(NAVGUARD için elektronik pusula yeteneğinin Android sensör framework’ü aracılığıyla jeomanyetik veya manyetometreyle ilişkili bilgi sağlaması beklenmektedir.)*

The exact Android sensor types and physical sensor implementations must be verified on the actual device. *(Kesin Android sensör türleri ve fiziksel sensör uygulamaları gerçek cihaz üzerinde doğrulanmalıdır.)*

---

# 8. Core Sensor Baseline (Temel Sensör Referansı)

| Sensor Source (Sensör Kaynağı) | Expected NAVGUARD Role (Beklenen NAVGUARD Rolü) | Baseline Status (Temel Durum) |
| --- | --- | --- |
| Accelerometer *(İvmeölçer)* | Motion, step, and acceleration analysis *(Hareket, adım ve ivme analizi)* | Required *(Zorunlu)* |
| Gyroscope *(Jiroskop)* | Angular motion and heading stabilization *(Açısal hareket ve yön kararlılığı)* | Required *(Zorunlu)* |
| Magnetometer / Electronic Compass *(Manyetometre / Elektronik Pusula)* | Absolute directional reference and magnetic quality analysis *(Mutlak yön referansı ve manyetik kalite analizi)* | Required *(Zorunlu)* |
| GNSS Receiver *(GNSS Alıcısı)* | Initial position and evaluation ground truth *(Başlangıç konumu ve değerlendirme gerçek referansı)* | Required *(Zorunlu)* |
| Rear Camera *(Arka Kamera)* | ARCore visual-inertial tracking *(ARCore görsel-ataletsel takip)* | Target *(Hedef)* |
| Rotation Vector *(Dönüş Vektörü)* | Orientation estimation if available *(Mevcutsa yönelim tahmini)* | To Be Verified *(Doğrulanacak)* |
| Linear Acceleration *(Doğrusal İvme)* | Gravity-compensated motion information if available *(Mevcutsa yerçekiminden arındırılmış hareket bilgisi)* | To Be Verified *(Doğrulanacak)* |
| Gravity Sensor *(Yerçekimi Sensörü)* | Gravity direction estimation if available *(Mevcutsa yerçekimi yönü tahmini)* | To Be Verified *(Doğrulanacak)* |

---

# 9. Sensors That Will Not Be Assumed (Varsayılmayacak Sensörler)

A barometer will not be assumed to exist on the Redmi Note 9 Pro. *(Redmi Note 9 Pro üzerinde barometre bulunduğu varsayılmayacaktır.)*

The official device specification used for the project baseline does not list a barometric pressure sensor. *(Proje temel referansı için kullanılan resmî cihaz teknik özellikleri barometrik basınç sensörü listelememektedir.)*

Barometric altitude or floor-change estimation will therefore not be included in the mandatory NAVGUARD architecture. *(Bu nedenle barometrik yükseklik veya kat değişimi tahmini zorunlu NAVGUARD mimarisine dahil edilmeyecektir.)*

Any sensor not verified through the Android runtime will be treated as unavailable until proven otherwise. *(Android çalışma zamanı üzerinden doğrulanmayan herhangi bir sensör, aksi kanıtlanana kadar kullanılamaz kabul edilecektir.)*

---

# 10. Virtual and Composite Android Sensors (Sanal ve Birleşik Android Sensörleri)

Android may expose software-generated or sensor-fused virtual sensors in addition to physical sensors. *(Android, fiziksel sensörlere ek olarak yazılım tarafından oluşturulan veya sensör füzyonlu sanal sensörler sağlayabilir.)*

Potentially useful examples include the rotation vector, game rotation vector, gravity, and linear acceleration sensors. *(Potansiyel olarak yararlı örnekler dönüş vektörü, oyun dönüş vektörü, yerçekimi ve doğrusal ivme sensörlerini içerir.)*

Their presence must not be assumed solely because accelerometer and gyroscope hardware exists. *(Bu sensörlerin varlığı yalnızca ivmeölçer ve jiroskop donanımı bulunduğu için varsayılmamalıdır.)*

NAVGUARD will query the Android SensorManager at runtime and record the exact sensors exposed by the target device. *(NAVGUARD, çalışma zamanında Android SensorManager’ı sorgulayacak ve hedef cihaz tarafından sunulan kesin sensörleri kaydedecektir.)*

The result will be documented in the Device Capability Audit. *(Sonuç Cihaz Yetenek Denetiminde dokümante edilecektir.)*

---

# 11. GNSS Capability Baseline (GNSS Yetenek Temel Referansı)

The official Redmi Note 9 Pro specification lists GPS, A-GPS, GLONASS, and BeiDou positioning support. *(Resmî Redmi Note 9 Pro teknik özellikleri GPS, A-GPS, GLONASS ve BeiDou konumlandırma desteğini listelemektedir.)*

NAVGUARD will use Android location APIs to acquire initial position information and experimental ground-truth records. *(NAVGUARD, başlangıç konum bilgisini ve deneysel gerçek referans kayıtlarını elde etmek için Android konum API’lerini kullanacaktır.)*

The specific satellite constellations, signal characteristics, measurement fields, and raw GNSS capabilities exposed by the physical device will be verified separately. *(Fiziksel cihaz tarafından sunulan belirli uydu takımyıldızları, sinyal özellikleri, ölçüm alanları ve ham GNSS yetenekleri ayrı olarak doğrulanacaktır.)*

The project will not require raw GNSS measurements for the minimum viable navigation system. *(Proje, minimum uygulanabilir navigasyon sistemi için ham GNSS ölçümlerine ihtiyaç duymayacaktır.)*

Raw GNSS information may be investigated as an optional diagnostic capability if the device and development schedule permit. *(Cihaz ve geliştirme takvimi izin verirse ham GNSS bilgisi isteğe bağlı bir tanısal yetenek olarak araştırılabilir.)*

---

# 12. GNSS Role in NAVGUARD (NAVGUARD’da GNSS’in Rolü)

GNSS will serve three different roles depending on the navigation state. *(GNSS, navigasyon durumuna bağlı olarak üç farklı rol üstlenecektir.)*

Before a GNSS-denied session, GNSS will establish the initial global position. *(GNSS kesintili bir oturumdan önce GNSS başlangıç global konumunu oluşturacaktır.)*

During normal navigation mode, GNSS may provide standard position information. *(Normal navigasyon modu sırasında GNSS standart konum bilgisi sağlayabilir.)*

During evaluation mode, GNSS may continue recording an independent reference trajectory while remaining isolated from the NAVGUARD estimator. *(Değerlendirme modu sırasında GNSS, NAVGUARD tahmin motorundan izole kalırken bağımsız bir referans rota kaydetmeye devam edebilir.)*

During the simulated GNSS-denied estimation phase, GNSS position measurements must not influence the alternative position estimator. *(Simüle edilmiş GNSS kesintili tahmin aşaması sırasında GNSS konum ölçümleri alternatif konum tahmin motorunu etkilememelidir.)*

---

# 13. Camera Baseline (Kamera Temel Referansı)

The Redmi Note 9 Pro includes a rear camera system that can provide the visual input required by ARCore. *(Redmi Note 9 Pro, ARCore tarafından gerekli görsel girdiyi sağlayabilecek bir arka kamera sistemine sahiptir.)*

NAVGUARD does not require direct use of the full native camera resolution for visual-inertial navigation. *(NAVGUARD, görsel-ataletsel navigasyon için tam native kamera çözünürlüğünün doğrudan kullanılmasını gerektirmez.)*

Camera processing requirements will be determined primarily by ARCore rather than by custom full-resolution computer vision processing. *(Kamera işleme gereksinimleri özel tam çözünürlüklü bilgisayarlı görü işlemleri yerine temel olarak ARCore tarafından belirlenecektir.)*

The camera will therefore be treated as a navigation sensor rather than as a photography feature. *(Bu nedenle kamera bir fotoğrafçılık özelliği yerine bir navigasyon sensörü olarak ele alınacaktır.)*

---

# 14. ARCore Compatibility Baseline (ARCore Uyumluluk Temel Referansı)

The Xiaomi Redmi Note 9 Pro is listed by Google as an ARCore-supported device. *(Xiaomi Redmi Note 9 Pro, Google tarafından ARCore destekli bir cihaz olarak listelenmektedir.)*

This support allows NAVGUARD to investigate ARCore motion tracking as a relative movement information source. *(Bu destek NAVGUARD’ın ARCore hareket takibini bir göreli hareket bilgi kaynağı olarak araştırmasına olanak sağlar.)*

ARCore certification indicates that Google has evaluated the device platform for required camera, motion sensor, and processing characteristics. *(ARCore sertifikasyonu, Google’ın cihaz platformunu gerekli kamera, hareket sensörü ve işlem özellikleri açısından değerlendirdiğini gösterir.)*

ARCore support does not guarantee that tracking will remain accurate in every environment. *(ARCore desteği, takibin her ortamda doğru kalacağını garanti etmez.)*

Actual ARCore pose stability and tracking availability must therefore be tested on the physical Redmi Note 9 Pro. *(Bu nedenle gerçek ARCore poz kararlılığı ve takip kullanılabilirliği fiziksel Redmi Note 9 Pro üzerinde test edilmelidir.)*

---

# 15. ARCore Depth Capability Policy (ARCore Depth Yeteneği Politikası)

NAVGUARD will not assume ARCore Depth API support on the Redmi Note 9 Pro. *(NAVGUARD, Redmi Note 9 Pro üzerinde ARCore Depth API desteği bulunduğunu varsaymayacaktır.)*

The project does not require the Depth API for its core visual-inertial tracking design. *(Proje, temel görsel-ataletsel takip tasarımı için Depth API’ye ihtiyaç duymamaktadır.)*

The required ARCore capability is device pose and motion tracking rather than environmental depth reconstruction. *(Gerekli ARCore yeteneği çevresel derinlik yeniden yapılandırması yerine cihaz pozu ve hareket takibidir.)*

This keeps the visual tracking subsystem aligned with the actual project objective. *(Bu yaklaşım görsel takip alt sistemini gerçek proje hedefiyle uyumlu tutar.)*

---

# 16. ARCore Role in NAVGUARD (NAVGUARD’da ARCore’un Rolü)

ARCore will not provide the global geographic position of the user. *(ARCore kullanıcının global coğrafi konumunu sağlamayacaktır.)*

ARCore will provide relative device pose and movement information within its local tracking coordinate system. *(ARCore kendi yerel takip koordinat sistemi içerisinde göreli cihaz pozu ve hareket bilgisi sağlayacaktır.)*

NAVGUARD will align this relative movement information with the navigation coordinate system established at the beginning of the session. *(NAVGUARD bu göreli hareket bilgisini oturum başlangıcında oluşturulan navigasyon koordinat sistemiyle hizalayacaktır.)*

The contribution of ARCore will then be evaluated against PDR-based movement estimates. *(Daha sonra ARCore’un katkısı PDR tabanlı hareket tahminlerine karşı değerlendirilecektir.)*

ARCore must remain an optional measurement source so that temporary tracking loss does not terminate the navigation system. *(Geçici takip kaybının navigasyon sistemini sonlandırmaması için ARCore isteğe bağlı bir ölçüm kaynağı olarak kalmalıdır.)*

---

# 17. Battery Baseline (Batarya Temel Referansı)

The official Redmi Note 9 Pro specification lists a typical battery capacity of 5020 mAh. *(Resmî Redmi Note 9 Pro teknik özellikleri tipik 5020 mAh batarya kapasitesi belirtmektedir.)*

The actual usable capacity of the project’s physical device may be lower because battery health changes with age and usage history. *(Projenin fiziksel cihazındaki gerçek kullanılabilir kapasite, batarya sağlığının yaş ve kullanım geçmişiyle değişmesi nedeniyle daha düşük olabilir.)*

NAVGUARD will therefore measure battery consumption as a relative runtime metric instead of assuming factory-new battery capacity. *(Bu nedenle NAVGUARD, fabrika çıkışı yeni batarya kapasitesini varsaymak yerine batarya tüketimini göreli bir çalışma zamanı metriği olarak ölçecektir.)*

Long-duration continuous camera use may create a higher energy cost than sensor-only navigation. *(Uzun süreli sürekli kamera kullanımı yalnızca sensör kullanan navigasyondan daha yüksek enerji maliyeti oluşturabilir.)*

Battery impact will therefore be measured separately for major navigation configurations where practical. *(Bu nedenle batarya etkisi uygulanabilir olduğu durumlarda temel navigasyon yapılandırmaları için ayrı ayrı ölçülecektir.)*

---

# 18. Memory and Storage Baseline (Bellek ve Depolama Temel Referansı)

Published Redmi Note 9 Pro configurations include multiple storage variants. *(Yayınlanmış Redmi Note 9 Pro yapılandırmaları birden fazla depolama varyantı içerir.)*

NAVGUARD will not assume the RAM or storage capacity of the specific physical test device until it is read from the device. *(NAVGUARD, belirli fiziksel test cihazının RAM veya depolama kapasitesini cihazdan okunana kadar varsaymayacaktır.)*

The exact available memory and storage values will be recorded during the Device Capability Audit. *(Kesin kullanılabilir bellek ve depolama değerleri Cihaz Yetenek Denetimi sırasında kaydedilecektir.)*

Sensor logs can grow significantly during long recording sessions, so logging formats must be designed efficiently. *(Sensör kayıtları uzun kayıt oturumlarında önemli ölçüde büyüyebileceği için kayıt formatları verimli şekilde tasarlanmalıdır.)*

Raw sensor retention policies will be defined to avoid unnecessary storage growth. *(Gereksiz depolama büyümesini önlemek için ham sensör saklama politikaları tanımlanacaktır.)*

---

# 19. Android Version Policy (Android Sürüm Politikası)

The exact Android version installed on the physical Redmi Note 9 Pro will not be assumed in advance. *(Fiziksel Redmi Note 9 Pro üzerinde yüklü kesin Android sürümü önceden varsayılmayacaktır.)*

The operating system version, API level, Xiaomi software version, security patch level, and relevant runtime environment information will be recorded during the Device Capability Audit. *(İşletim sistemi sürümü, API seviyesi, Xiaomi yazılım sürümü, güvenlik yaması seviyesi ve ilgili çalışma ortamı bilgileri Cihaz Yetenek Denetimi sırasında kaydedilecektir.)*

NAVGUARD’s minimum and target Android API levels will be selected after compatibility requirements for Flutter, TensorFlow Lite, ARCore, and the physical device are verified. *(NAVGUARD’ın minimum ve hedef Android API seviyeleri Flutter, TensorFlow Lite, ARCore ve fiziksel cihaz için uyumluluk gereksinimleri doğrulandıktan sonra seçilecektir.)*

This prevents the architecture from depending on an assumed operating system configuration. *(Bu yaklaşım mimarinin varsayılan bir işletim sistemi yapılandırmasına bağımlı olmasını önler.)*

---

# 20. Android Sensor Sampling Constraint (Android Sensör Örnekleme Kısıtı)

Android applies sensor sampling restrictions to applications targeting modern Android versions. *(Android, modern Android sürümlerini hedefleyen uygulamalara sensör örnekleme kısıtları uygular.)*

For applications targeting Android 12 or higher, normal SensorEventListener access to accelerometer, gyroscope, and geomagnetic measurements is limited to a maximum rate of 200 Hz unless the special high-sampling-rate permission is used. *(Android 12 veya üzerini hedefleyen uygulamalarda accelerometer, gyroscope ve geomagnetic ölçümlere normal SensorEventListener erişimi, özel yüksek örnekleme hızı izni kullanılmadığı sürece maksimum 200 Hz ile sınırlıdır.)*

NAVGUARD does not currently require sensor sampling rates above 200 Hz. *(NAVGUARD şu anda 200 Hz’in üzerinde sensör örnekleme hızlarına ihtiyaç duymamaktadır.)*

The initial target sampling frequency for the primary inertial sensors will therefore remain below this limit. *(Bu nedenle temel ataletsel sensörler için başlangıç hedef örnekleme frekansı bu sınırın altında kalacaktır.)*

---

# 21. Initial Sampling Targets (Başlangıç Örnekleme Hedefleri)

The initial accelerometer target will be approximately 50 Hz. *(Başlangıç ivmeölçer hedefi yaklaşık 50 Hz olacaktır.)*

The initial gyroscope target will be approximately 50 Hz. *(Başlangıç jiroskop hedefi yaklaşık 50 Hz olacaktır.)*

The initial magnetometer target will be approximately 20 to 50 Hz depending on the actual device capability. *(Başlangıç manyetometre hedefi gerçek cihaz yeteneğine bağlı olarak yaklaşık 20 ile 50 Hz arasında olacaktır.)*

GNSS position updates will use a substantially lower rate because absolute geographic positioning does not require IMU-level sampling frequencies. *(GNSS konum güncellemeleri, mutlak coğrafi konumlandırma IMU seviyesinde örnekleme frekansları gerektirmediği için önemli ölçüde daha düşük bir hız kullanacaktır.)*

ARCore pose information will be processed according to the ARCore frame and tracking update mechanism. *(ARCore poz bilgisi ARCore kare ve takip güncelleme mekanizmasına göre işlenecektir.)*

These frequencies are initial design targets rather than guaranteed runtime rates. *(Bu frekanslar garanti edilmiş çalışma hızları yerine başlangıç tasarım hedefleridir.)*

---

# 22. Delivered Sampling Rate Policy (Gerçekleşen Örnekleme Hızı Politikası)

NAVGUARD will measure the actual intervals between consecutive sensor timestamps. *(NAVGUARD ardışık sensör zaman damgaları arasındaki gerçek aralıkları ölçecektir.)*

The navigation algorithms will use measured timestamps rather than assuming that every sample arrives at a perfectly fixed interval. *(Navigasyon algoritmaları her örneğin tamamen sabit bir aralıkla geldiğini varsaymak yerine ölçülen zaman damgalarını kullanacaktır.)*

Mean sampling rate, median sampling rate, variation, dropped events, and timing irregularities will be inspected during the device audit. *(Ortalama örnekleme hızı, medyan örnekleme hızı, değişkenlik, kayıp olaylar ve zamanlama düzensizlikleri cihaz denetimi sırasında incelenecektir.)*

This is especially important for synchronization between IMU, GNSS, AI windows, and ARCore measurements. *(Bu özellikle IMU, GNSS, yapay zekâ pencereleri ve ARCore ölçümleri arasındaki senkronizasyon için önemlidir.)*

---

# 23. Sensor Metadata Requirement (Sensör Metadata Gereksinimi)

NAVGUARD must record the Android metadata of every sensor used by the project. *(NAVGUARD, proje tarafından kullanılan her sensörün Android metadata bilgisini kaydetmelidir.)*

The recorded metadata should include the sensor name, vendor, version, Android sensor type, reporting mode, resolution, maximum range, power value, and minimum delay when available. *(Kaydedilen metadata; mevcut olduğunda sensör adını, üreticisini, sürümünü, Android sensör türünü, raporlama modunu, çözünürlüğünü, maksimum aralığını, güç değerini ve minimum gecikmesini içermelidir.)*

This information will identify the actual sensor implementations present in the physical Redmi Note 9 Pro. *(Bu bilgi fiziksel Redmi Note 9 Pro içerisinde bulunan gerçek sensör uygulamalarını belirleyecektir.)*

These values will become part of the reproducibility record for all later experiments. *(Bu değerler daha sonraki tüm deneyler için tekrarlanabilirlik kaydının bir parçası olacaktır.)*

---

# 24. Sensor Availability Policy (Sensör Kullanılabilirlik Politikası)

Application startup must not blindly assume that every planned sensor is available. *(Uygulama başlangıcı, planlanan her sensörün mevcut olduğunu körü körüne varsaymamalıdır.)*

The sensor subsystem must perform a runtime capability check before a navigation session begins. *(Sensör alt sistemi bir navigasyon oturumu başlamadan önce çalışma zamanı yetenek kontrolü gerçekleştirmelidir.)*

A required sensor failure must prevent the corresponding navigation configuration from starting. *(Zorunlu bir sensörün başarısız olması ilgili navigasyon yapılandırmasının başlamasını engellemelidir.)*

An optional sensor failure should disable only the dependent feature when a safe fallback exists. *(Güvenli bir geri dönüş mevcut olduğunda isteğe bağlı bir sensörün başarısız olması yalnızca ona bağlı özelliği devre dışı bırakmalıdır.)*

The user should be informed about unavailable capabilities before an experiment begins. *(Bir deney başlamadan önce kullanıcı kullanılamayan yetenekler hakkında bilgilendirilmelidir.)*

---

# 25. Required Device Capabilities (Zorunlu Cihaz Yetenekleri)

The minimum NAVGUARD baseline requires accelerometer access. *(Minimum NAVGUARD temel referansı ivmeölçer erişimi gerektirir.)*

The minimum NAVGUARD baseline requires gyroscope access. *(Minimum NAVGUARD temel referansı jiroskop erişimi gerektirir.)*

The minimum NAVGUARD baseline requires a directional information source suitable for heading estimation. *(Minimum NAVGUARD temel referansı yön tahmini için uygun bir yön bilgisi kaynağı gerektirir.)*

The minimum NAVGUARD baseline requires GNSS or Android location access for initialization and experimental reference recording. *(Minimum NAVGUARD temel referansı başlatma ve deneysel referans kaydı için GNSS veya Android konum erişimi gerektirir.)*

The minimum NAVGUARD baseline requires sufficient local computation to execute the selected motion model and navigation pipeline. *(Minimum NAVGUARD temel referansı seçilen hareket modelini ve navigasyon hattını çalıştırmak için yeterli yerel hesaplama gücü gerektirir.)*

---

# 26. Target Device Capabilities (Hedef Cihaz Yetenekleri)

ARCore motion tracking is a target capability rather than a requirement for the minimum PDR-only fallback system. *(ARCore hareket takibi minimum yalnızca PDR yedek sistemi için zorunluluk yerine hedef bir yetenektir.)*

Rotation vector information is a target capability if exposed by Android on the physical device. *(Android tarafından fiziksel cihaz üzerinde sunulursa rotation vector bilgisi hedef bir yetenektir.)*

Linear acceleration and gravity virtual sensors may be used if they demonstrate useful runtime behavior. *(Doğrusal ivme ve yerçekimi sanal sensörleri kullanışlı çalışma davranışı gösterirlerse kullanılabilir.)*

Raw GNSS measurements are considered optional research information rather than a required project capability. *(Ham GNSS ölçümleri zorunlu bir proje yeteneği yerine isteğe bağlı araştırma bilgisi olarak kabul edilir.)*

---

# 27. Baseline Capability Matrix (Temel Yetenek Matrisi)

| Capability (Yetenek) | Published Support (Yayınlanmış Destek) | Physical Device Verification (Fiziksel Cihaz Doğrulaması) | NAVGUARD Priority (NAVGUARD Önceliği) |
| --- | --- | --- | --- |
| Accelerometer *(İvmeölçer)* | Yes *(Evet)* | Required *(Gerekli)* | Critical *(Kritik)* |
| Gyroscope *(Jiroskop)* | Yes *(Evet)* | Required *(Gerekli)* | Critical *(Kritik)* |
| Electronic Compass *(Elektronik Pusula)* | Yes *(Evet)* | Required *(Gerekli)* | Critical *(Kritik)* |
| GNSS *(GNSS)* | Yes *(Evet)* | Required *(Gerekli)* | Critical *(Kritik)* |
| ARCore | Officially Supported *(Resmî Olarak Destekleniyor)* | Required Before ARCore Integration *(ARCore Entegrasyonundan Önce Gerekli)* | High *(Yüksek)* |
| Rotation Vector *(Dönüş Vektörü)* | Not Assumed *(Varsayılmıyor)* | Required *(Gerekli)* | High *(Yüksek)* |
| Linear Acceleration *(Doğrusal İvme)* | Not Assumed *(Varsayılmıyor)* | Required *(Gerekli)* | Medium *(Orta)* |
| Gravity Sensor *(Yerçekimi Sensörü)* | Not Assumed *(Varsayılmıyor)* | Required *(Gerekli)* | Medium *(Orta)* |
| Barometer *(Barometre)* | Not Listed *(Listelenmiyor)* | Optional Check *(İsteğe Bağlı Kontrol)* | Out of Core Scope *(Temel Kapsam Dışı)* |
| Raw GNSS *(Ham GNSS)* | Not Assumed *(Varsayılmıyor)* | Optional Check *(İsteğe Bağlı Kontrol)* | Low *(Düşük)* |

---

# 28. Device Orientation Consideration (Cihaz Yönelimi Hususu)

The smartphone may not remain in exactly the same physical orientation during every navigation session. *(Akıllı telefon her navigasyon oturumu boyunca tamamen aynı fiziksel yönelimde kalmayabilir.)*

Sensor measurements are initially expressed relative to the device coordinate frame rather than directly relative to geographic north and east. *(Sensör ölçümleri başlangıçta doğrudan coğrafi kuzey ve doğuya göre değil cihaz koordinat sistemine göre ifade edilir.)*

NAVGUARD must therefore explicitly manage the transformation between device-relative measurements and the navigation reference frame. *(Bu nedenle NAVGUARD cihaz göreli ölçümler ile navigasyon referans koordinat sistemi arasındaki dönüşümü açıkça yönetmelidir.)*

The initial prototype may define a preferred phone carrying orientation to reduce uncontrolled experimental variability. *(İlk prototip kontrolsüz deneysel değişkenliği azaltmak için tercih edilen bir telefon taşıma yönelimi tanımlayabilir.)*

More orientation-independent operation may be investigated after the baseline system becomes stable. *(Temel sistem kararlı hale geldikten sonra yönelimden daha bağımsız çalışma araştırılabilir.)*

---

# 29. Preferred Experimental Device Placement (Tercih Edilen Deneysel Cihaz Yerleşimi)

Early data collection should use a consistent device placement whenever possible. *(İlk veri toplama aşamasında mümkün olduğunda tutarlı bir cihaz yerleşimi kullanılmalıdır.)*

A stable and documented placement will reduce unnecessary differences between recorded sensor sessions. *(Kararlı ve dokümante edilmiş bir yerleşim kaydedilen sensör oturumları arasındaki gereksiz farkları azaltacaktır.)*

The final placement protocol will be defined after pilot sensor recordings are examined. *(Nihai yerleşim protokolü pilot sensör kayıtları incelendikten sonra tanımlanacaktır.)*

If multiple carrying modes are later evaluated, they must be treated as separate experimental conditions. *(Daha sonra birden fazla taşıma modu değerlendirilirse bunlar ayrı deneysel koşullar olarak ele alınmalıdır.)*

---

# 30. Thermal Considerations (Termal Hususlar)

Continuous ARCore camera tracking, sensor processing, logging, map rendering, and AI inference may increase device temperature. *(Sürekli ARCore kamera takibi, sensör işleme, kayıt, harita çizimi ve yapay zekâ çıkarımı cihaz sıcaklığını artırabilir.)*

Thermal throttling can reduce CPU or GPU performance during long sessions. *(Termal kısıtlama uzun oturumlarda CPU veya GPU performansını azaltabilir.)*

The final performance tests should therefore include sessions long enough to reveal sustained-load behavior. *(Bu nedenle nihai performans testleri sürekli yük davranışını ortaya çıkaracak kadar uzun oturumlar içermelidir.)*

NAVGUARD will avoid unnecessarily heavy models or visual processing that provide no measurable navigation benefit. *(NAVGUARD ölçülebilir navigasyon faydası sağlamayan gereksiz ağır modellerden veya görsel işlemlerden kaçınacaktır.)*

---

# 31. Resource Competition Consideration (Kaynak Rekabeti Hususu)

ARCore, TensorFlow Lite inference, map rendering, sensor logging, and navigation calculations may compete for device resources. *(ARCore, TensorFlow Lite çıkarımı, harita çizimi, sensör kaydı ve navigasyon hesaplamaları cihaz kaynakları için rekabet edebilir.)*

The architecture must therefore support profiling of CPU, memory, latency, and battery impact. *(Bu nedenle mimari CPU, bellek, gecikme ve batarya etkisinin profillenmesini desteklemelidir.)*

Performance problems must be investigated using measurements rather than assumptions. *(Performans problemleri varsayımlar yerine ölçümler kullanılarak araştırılmalıdır.)*

A lower-complexity model or lower update frequency may be selected when the measured performance benefit justifies the trade-off. *(Ölçülen performans faydası dengeyi gerekçelendirirse daha düşük karmaşıklıklı bir model veya daha düşük güncelleme frekansı seçilebilir.)*

---

# 32. Offline Operation Baseline (Çevrimdışı Çalışma Temel Referansı)

The core NAVGUARD position estimator must function without continuous network connectivity. *(Temel NAVGUARD konum tahmin motoru sürekli ağ bağlantısı olmadan çalışmalıdır.)*

Sensor acquisition must be local. *(Sensör veri toplama yerel olmalıdır.)*

Motion classification inference must be local. *(Hareket sınıflandırma çıkarımı yerel olmalıdır.)*

PDR calculations must be local. *(PDR hesaplamaları yerel olmalıdır.)*

Sensor fusion must be local. *(Sensör füzyonu yerel olmalıdır.)*

ARCore tracking must not require a NAVGUARD cloud backend for normal runtime operation. *(ARCore takibi normal çalışma sırasında bir NAVGUARD bulut backend’ine ihtiyaç duymamalıdır.)*

Experimental session records must be storable locally on the device. *(Deneysel oturum kayıtları cihaz üzerinde yerel olarak saklanabilir olmalıdır.)*

---

# 33. Network Usage Policy (Ağ Kullanım Politikası)

NAVGUARD’s scientific and navigation results must not depend on the availability of a remote server. *(NAVGUARD’ın bilimsel ve navigasyon sonuçları uzak bir sunucunun kullanılabilirliğine bağlı olmamalıdır.)*

Network connectivity may be used for non-core development activities such as package installation, source control, or map data acquisition. *(Ağ bağlantısı paket kurulumu, kaynak kontrolü veya harita verisi edinimi gibi temel olmayan geliştirme faaliyetleri için kullanılabilir.)*

A network failure during a field test must not disable the core GNSS-denied estimator. *(Bir saha testi sırasında ağ kesintisi temel GNSS kesintili tahmin motorunu devre dışı bırakmamalıdır.)*

This requirement separates internet availability from navigation availability. *(Bu gereksinim internet kullanılabilirliği ile navigasyon kullanılabilirliğini birbirinden ayırır.)*

---

# 34. External Hardware Policy (Harici Donanım Politikası)

No external IMU is required for the initial NAVGUARD prototype. *(İlk NAVGUARD prototipi için harici IMU gerekli değildir.)*

No external GNSS receiver is required for the initial NAVGUARD prototype. *(İlk NAVGUARD prototipi için harici GNSS alıcısı gerekli değildir.)*

No dedicated camera is required for the initial NAVGUARD prototype. *(İlk NAVGUARD prototipi için özel kamera gerekli değildir.)*

No specialized navigation hardware must be purchased to meet the project’s mandatory requirements. *(Projenin zorunlu gereksinimlerini karşılamak için özel navigasyon donanımı satın alınması gerekmemelidir.)*

The smartphone itself is the primary sensing and computing platform. *(Akıllı telefonun kendisi birincil algılama ve hesaplama platformudur.)*

---

# 35. Development Computer Role (Geliştirme Bilgisayarının Rolü)

A development computer will be used for Flutter development, Android builds, Python analysis, machine learning training, visualization, and experiment processing. *(Bir geliştirme bilgisayarı Flutter geliştirme, Android build işlemleri, Python analizi, makine öğrenmesi eğitimi, görselleştirme ve deney işleme için kullanılacaktır.)*

The development computer is not part of the runtime navigation architecture. *(Geliştirme bilgisayarı çalışma zamanı navigasyon mimarisinin bir parçası değildir.)*

The final mobile navigation demonstration must operate without the development computer continuously controlling the estimator. *(Nihai mobil navigasyon demosu geliştirme bilgisayarı tahmin motorunu sürekli kontrol etmeden çalışmalıdır.)*

Offline analysis may still be performed on the development computer after recorded sessions are exported. *(Kaydedilen oturumlar dışa aktarıldıktan sonra çevrimdışı analiz yine geliştirme bilgisayarında gerçekleştirilebilir.)*

---

# 36. AI Training and Runtime Separation (Yapay Zekâ Eğitimi ve Çalışma Zamanı Ayrımı)

Artificial intelligence model training will primarily occur on the development computer. *(Yapay zekâ modeli eğitimi temel olarak geliştirme bilgisayarında gerçekleştirilecektir.)*

The trained model will then be converted into a mobile-compatible deployment format. *(Eğitilmiş model daha sonra mobil uyumlu bir dağıtım formatına dönüştürülecektir.)*

The final inference process will run directly on the Redmi Note 9 Pro. *(Nihai çıkarım işlemi doğrudan Redmi Note 9 Pro üzerinde çalışacaktır.)*

This separation allows heavier offline training while keeping runtime navigation independent from external computing infrastructure. *(Bu ayrım daha ağır çevrimdışı eğitime olanak sağlarken çalışma zamanı navigasyonunu harici hesaplama altyapısından bağımsız tutar.)*

---

# 37. Physical Device as Dataset Source (Veri Seti Kaynağı Olarak Fiziksel Cihaz)

The Redmi Note 9 Pro will serve as the primary source of motion sensor data for the NAVGUARD machine learning dataset. *(Redmi Note 9 Pro, NAVGUARD makine öğrenmesi veri seti için temel hareket sensörü veri kaynağı olarak kullanılacaktır.)*

Training data collected on the same device reduces hardware-domain differences between training and initial deployment. *(Aynı cihaz üzerinde toplanan eğitim verisi, eğitim ile ilk dağıtım arasındaki donanım alanı farklılıklarını azaltır.)*

The resulting model may therefore initially be device-specific or device-biased. *(Bu nedenle ortaya çıkan model başlangıçta cihaza özgü veya cihaz yanlı olabilir.)*

Generalization to other Android devices will not be assumed without additional experiments. *(Ek deneyler olmadan diğer Android cihazlara genelleme varsayılmayacaktır.)*

---

# 38. Device-Specific Model Limitation (Cihaza Özgü Model Sınırlaması)

Sensor noise characteristics may differ between smartphone models. *(Sensör gürültü özellikleri akıllı telefon modelleri arasında farklılık gösterebilir.)*

Sampling behavior may also vary across Android devices. *(Örnekleme davranışı da Android cihazlar arasında değişebilir.)*

A motion model trained primarily using Redmi Note 9 Pro sensor data may therefore perform differently on another phone. *(Bu nedenle temel olarak Redmi Note 9 Pro sensör verisi kullanılarak eğitilmiş bir hareket modeli başka bir telefonda farklı performans gösterebilir.)*

Cross-device generalization will be documented as future work rather than treated as a mandatory project requirement. *(Cihazlar arası genelleme zorunlu bir proje gereksinimi olarak ele alınmak yerine gelecek çalışma olarak dokümante edilecektir.)*

---

# 39. Experimental Reproducibility Baseline (Deneysel Tekrarlanabilirlik Temel Referansı)

Every final experiment must record the target device identity and relevant software environment. *(Her nihai deney hedef cihaz kimliğini ve ilgili yazılım ortamını kaydetmelidir.)*

The record should include at least the device model, Android API level, application version, algorithm configuration, model version, and session identifier. *(Kayıt en azından cihaz modelini, Android API seviyesini, uygulama sürümünü, algoritma yapılandırmasını, model sürümünü ve oturum kimliğini içermelidir.)*

Sensor metadata should be linked to the experiment configuration. *(Sensör metadata bilgisi deney yapılandırmasıyla ilişkilendirilmelidir.)*

This information will make later performance results traceable to the exact runtime baseline. *(Bu bilgi daha sonraki performans sonuçlarının kesin çalışma zamanı temel referansına kadar izlenebilir olmasını sağlayacaktır.)*

---

# 40. Baseline Test Environment Policy (Temel Test Ortamı Politikası)

Early engineering tests will prioritize repeatability over environmental variety. *(İlk mühendislik testleri çevresel çeşitlilik yerine tekrarlanabilirliğe öncelik verecektir.)*

After the navigation baseline is stable, experiments will gradually introduce different route geometries and environmental conditions. *(Navigasyon temel sistemi kararlı hale geldikten sonra deneylere kademeli olarak farklı rota geometrileri ve çevresel koşullar dahil edilecektir.)*

Device configuration should remain as consistent as practical across comparative benchmark sessions. *(Karşılaştırmalı benchmark oturumları arasında cihaz yapılandırması uygulanabilir olduğu ölçüde tutarlı tutulmalıdır.)*

Changes that may influence measurements must be recorded. *(Ölçümleri etkileyebilecek değişiklikler kaydedilmelidir.)*

---

# 41. Device Calibration Philosophy (Cihaz Kalibrasyon Yaklaşımı)

NAVGUARD will distinguish between manufacturer-level sensor calibration and project-level initialization. *(NAVGUARD, üretici seviyesindeki sensör kalibrasyonu ile proje seviyesindeki başlatma işlemini birbirinden ayıracaktır.)*

The project will not attempt to modify hardware factory calibration. *(Proje donanım fabrika kalibrasyonunu değiştirmeye çalışmayacaktır.)*

NAVGUARD may perform session-level checks for sensor stability, orientation initialization, magnetic quality, GNSS quality, and ARCore tracking readiness. *(NAVGUARD oturum seviyesinde sensör kararlılığı, yönelim başlatma, manyetik kalite, GNSS kalitesi ve ARCore takip hazırlığı kontrolleri gerçekleştirebilir.)*

These checks will be described as navigation initialization rather than hardware recalibration unless an explicit software calibration method is implemented. *(Açık bir yazılım kalibrasyon yöntemi uygulanmadığı sürece bu kontroller donanım yeniden kalibrasyonu yerine navigasyon başlatma olarak tanımlanacaktır.)*

---

# 42. Device Readiness Gate (Cihaz Hazırlık Kapısı)

A NAVGUARD experiment should not begin until mandatory device capabilities have passed a readiness check. *(Zorunlu cihaz yetenekleri hazırlık kontrolünü geçmeden bir NAVGUARD deneyi başlamamalıdır.)*

The readiness gate should verify required sensors, application permissions, GNSS state, sensor event delivery, local storage availability, and the selected navigation configuration. *(Hazırlık kapısı gerekli sensörleri, uygulama izinlerini, GNSS durumunu, sensör olay teslimini, yerel depolama kullanılabilirliğini ve seçilen navigasyon yapılandırmasını doğrulamalıdır.)*

ARCore readiness will be required only for configurations that use visual-inertial tracking. *(ARCore hazırlığı yalnızca görsel-ataletsel takip kullanan yapılandırmalar için gerekli olacaktır.)*

A failed readiness condition should produce a clear diagnostic message instead of silently starting an invalid experiment. *(Başarısız bir hazırlık koşulu, geçersiz bir deneyi sessizce başlatmak yerine açık bir tanısal mesaj üretmelidir.)*

---

# 43. Initial Hardware Baseline Summary (Başlangıç Donanım Temel Referans Özeti)

| Component (Bileşen) | NAVGUARD Baseline (NAVGUARD Temel Referansı) |
| --- | --- |
| Device *(Cihaz)* | Xiaomi Redmi Note 9 Pro |
| Platform *(Platform)* | Android Only *(Yalnızca Android)* |
| Processor *(İşlemci)* | Qualcomm Snapdragon 720G |
| GPU | Adreno 618 |
| Accelerometer *(İvmeölçer)* | Verified by Published Specification *(Yayınlanmış Teknik Özellikle Doğrulandı)* |
| Gyroscope *(Jiroskop)* | Verified by Published Specification *(Yayınlanmış Teknik Özellikle Doğrulandı)* |
| Electronic Compass *(Elektronik Pusula)* | Verified by Published Specification *(Yayınlanmış Teknik Özellikle Doğrulandı)* |
| GNSS | GPS / A-GPS / GLONASS / BeiDou Published Support *(GPS / A-GPS / GLONASS / BeiDou Yayınlanmış Desteği)* |
| ARCore | Officially Supported *(Resmî Olarak Destekleniyor)* |
| Depth API | Not Required and Not Assumed *(Gerekli Değil ve Varsayılmıyor)* |
| Barometer *(Barometre)* | Not Assumed *(Varsayılmıyor)* |
| Battery *(Batarya)* | 5020 mAh Typical Published Capacity *(5020 mAh Yayınlanmış Tipik Kapasite)* |
| Actual Android Version *(Gerçek Android Sürümü)* | To Be Audited *(Denetlenecek)* |
| Actual Sensor Vendors *(Gerçek Sensör Üreticileri)* | To Be Audited *(Denetlenecek)* |
| Actual Sampling Rates *(Gerçek Örnekleme Hızları)* | To Be Measured *(Ölçülecek)* |
| Virtual Sensors *(Sanal Sensörler)* | To Be Audited *(Denetlenecek)* |
| Raw GNSS Support *(Ham GNSS Desteği)* | Optional Audit *(İsteğe Bağlı Denetim)* |

---

# 44. Baseline Assumptions (Temel Varsayımlar)

The physical Redmi Note 9 Pro is assumed to be operational and available throughout the development period. *(Fiziksel Redmi Note 9 Pro’nun geliştirme süresi boyunca çalışır ve kullanılabilir durumda olduğu varsayılmaktadır.)*

The accelerometer, gyroscope, compass-related sensor, GNSS receiver, and rear camera are assumed to function normally unless the device audit identifies a hardware issue. *(Cihaz denetimi bir donanım problemi belirlemediği sürece ivmeölçer, jiroskop, pusulayla ilişkili sensör, GNSS alıcısı ve arka kameranın normal çalıştığı varsayılmaktadır.)*

ARCore installation and runtime compatibility are expected based on Google’s supported-device listing but must still be verified on the actual device. *(ARCore kurulumu ve çalışma zamanı uyumluluğu Google’ın desteklenen cihaz listesine dayanarak beklenmektedir ancak yine de gerçek cihaz üzerinde doğrulanmalıdır.)*

No assumption is made about exact sensor manufacturers, biases, noise levels, or sampling stability before measurement. *(Ölçüm yapılmadan önce kesin sensör üreticileri, bias değerleri, gürültü seviyeleri veya örnekleme kararlılığı hakkında herhangi bir varsayım yapılmamaktadır.)*

---

# 45. Baseline Constraints (Temel Kısıtlar)

The project is constrained by consumer-grade smartphone sensors. *(Proje tüketici sınıfı akıllı telefon sensörleriyle sınırlıdır.)*

The project is constrained by the processing, memory, battery, and thermal characteristics of the Redmi Note 9 Pro. *(Proje Redmi Note 9 Pro’nun işlem, bellek, batarya ve termal özellikleriyle sınırlıdır.)*

The project is constrained by Android sensor scheduling and API behavior. *(Proje Android sensör zamanlaması ve API davranışıyla sınırlıdır.)*

The project is constrained by environmental effects on magnetometer, GNSS, and visual tracking measurements. *(Proje manyetometre, GNSS ve görsel takip ölçümleri üzerindeki çevresel etkilerle sınırlıdır.)*

The project will explicitly measure and document these limitations rather than treating them as implementation failures. *(Proje bu sınırlamaları uygulama hataları olarak ele almak yerine açıkça ölçecek ve dokümante edecektir.)*

---

# 46. Platform Acceptance Conditions (Platform Kabul Koşulları)

The Android platform will be considered technically suitable if all mandatory sensor streams can be acquired with reliable timestamps. *(Tüm zorunlu sensör akışları güvenilir zaman damgalarıyla elde edilebilirse Android platformu teknik olarak uygun kabul edilecektir.)*

The Redmi Note 9 Pro will be considered suitable for the minimum NAVGUARD configuration if GNSS, accelerometer, gyroscope, and heading-related measurements operate reliably enough for baseline experiments. *(GNSS, ivmeölçer, jiroskop ve yönle ilişkili ölçümler temel deneyler için yeterince güvenilir çalışırsa Redmi Note 9 Pro minimum NAVGUARD yapılandırması için uygun kabul edilecektir.)*

The device will be considered suitable for the target configuration if ARCore tracking and on-device AI inference also pass the planned capability tests. *(ARCore takibi ve cihaz üzeri yapay zekâ çıkarımı da planlanan yetenek testlerini geçerse cihaz hedef yapılandırma için uygun kabul edilecektir.)*

Failure of an optional capability will not automatically invalidate the entire project. *(İsteğe bağlı bir yeteneğin başarısız olması tüm projeyi otomatik olarak geçersiz kılmayacaktır.)*

---

# 47. Device Baseline Freeze Rule (Cihaz Temel Referansını Sabitleme Kuralı)

The final device baseline will be frozen only after the Device Capability Audit is completed. *(Nihai cihaz temel referansı yalnızca Cihaz Yetenek Denetimi tamamlandıktan sonra sabitlenecektir.)*

Measured values will replace provisional assumptions wherever appropriate. *(Uygun olan yerlerde ölçülen değerler geçici varsayımların yerini alacaktır.)*

The frozen baseline will define the sensor configuration used for dataset collection, algorithm tuning, and final evaluation. *(Sabitlenmiş temel referans veri seti toplama, algoritma ayarlama ve nihai değerlendirme için kullanılan sensör yapılandırmasını tanımlayacaktır.)*

Any later device or operating-system change that can influence experimental results must be documented. *(Deneysel sonuçları etkileyebilecek daha sonraki herhangi bir cihaz veya işletim sistemi değişikliği dokümante edilmelidir.)*

---

# 48. Required Device Audit Outputs (Gerekli Cihaz Denetimi Çıktıları)

The following values must be determined before the NAVGUARD device baseline is considered final. *(NAVGUARD cihaz temel referansı nihai kabul edilmeden önce aşağıdaki değerler belirlenmelidir.)*

- **Android Version and API Level** *(Android Sürümü ve API Seviyesi)*
- **Xiaomi System Software Version** *(Xiaomi Sistem Yazılımı Sürümü)*
- **CPU and Available Memory Information** *(CPU ve Kullanılabilir Bellek Bilgisi)*
- **Available Storage** *(Kullanılabilir Depolama)*
- **Accelerometer Name and Vendor** *(İvmeölçer Adı ve Üreticisi)*
- **Gyroscope Name and Vendor** *(Jiroskop Adı ve Üreticisi)*
- **Magnetometer Name and Vendor** *(Manyetometre Adı ve Üreticisi)*
- **Sensor Resolution and Maximum Range** *(Sensör Çözünürlüğü ve Maksimum Aralığı)*
- **Reported Minimum Sensor Delay** *(Bildirilen Minimum Sensör Gecikmesi)*
- **Measured Sampling Frequencies** *(Ölçülen Örnekleme Frekansları)*
- **Sampling Interval Variation** *(Örnekleme Aralığı Değişkenliği)*
- **Rotation Vector Availability** *(Dönüş Vektörü Kullanılabilirliği)*
- **Linear Acceleration Availability** *(Doğrusal İvme Kullanılabilirliği)*
- **Gravity Sensor Availability** *(Yerçekimi Sensörü Kullanılabilirliği)*
- **GNSS Runtime Behavior** *(GNSS Çalışma Zamanı Davranışı)*
- **ARCore Installation and Tracking Test** *(ARCore Kurulum ve Takip Testi)*
- **Camera Permission and Runtime Test** *(Kamera İzni ve Çalışma Zamanı Testi)*
- **TensorFlow Lite Test Inference** *(TensorFlow Lite Test Çıkarımı)*
- **Battery Baseline Measurement** *(Batarya Temel Ölçümü)*

---

# 49. Device-Specific Development Principle (Cihaza Özgü Geliştirme İlkesi)

NAVGUARD will be developed using a measure-first approach for all hardware-sensitive parameters. *(NAVGUARD, donanıma duyarlı tüm parametreler için önce ölçüm yaklaşımı kullanılarak geliştirilecektir.)*

Published specifications will identify expected capabilities. *(Yayınlanmış teknik özellikler beklenen yetenekleri belirleyecektir.)*

The Android runtime will identify exposed capabilities. *(Android çalışma zamanı sunulan yetenekleri belirleyecektir.)*

Controlled experiments will determine whether those capabilities are sufficiently stable for the navigation system. *(Kontrollü deneyler bu yeteneklerin navigasyon sistemi için yeterince kararlı olup olmadığını belirleyecektir.)*

Algorithm parameters will then be selected using measured behavior rather than generic smartphone assumptions. *(Daha sonra algoritma parametreleri genel akıllı telefon varsayımları yerine ölçülen davranış kullanılarak seçilecektir.)*

---

# 50. Target Platform Summary (Hedef Platform Özeti)

**NAVGUARD will be developed as an Android-only, offline-capable, sensor-intensive mobile research application using the Xiaomi Redmi Note 9 Pro as its primary development, dataset collection, and evaluation device.** *(NAVGUARD, Xiaomi Redmi Note 9 Pro’yu birincil geliştirme, veri seti toplama ve değerlendirme cihazı olarak kullanan, yalnızca Android için geliştirilen, çevrimdışı çalışabilen ve yoğun sensör kullanan bir mobil araştırma uygulaması olarak geliştirilecektir.)*

**The confirmed baseline includes an accelerometer, gyroscope, electronic compass, GNSS positioning capability, rear camera, Snapdragon 720G processing platform, and official ARCore compatibility.** *(Doğrulanmış temel referans; ivmeölçer, jiroskop, elektronik pusula, GNSS konumlandırma yeteneği, arka kamera, Snapdragon 720G işlem platformu ve resmî ARCore uyumluluğunu içerir.)*

**All runtime-dependent properties such as exact sensor vendors, actual sampling frequencies, available virtual sensors, Android version, and ARCore tracking quality will be measured directly on the physical device before the hardware baseline is frozen.** *(Kesin sensör üreticileri, gerçek örnekleme frekansları, kullanılabilir sanal sensörler, Android sürümü ve ARCore takip kalitesi gibi çalışma zamanına bağlı tüm özellikler donanım temel referansı sabitlenmeden önce doğrudan fiziksel cihaz üzerinde ölçülecektir.)*

---

# 51. Source Basis (Kaynak Temeli)

The published hardware baseline in this document is based on the official Xiaomi Redmi Note 9 Pro specifications. *(Bu dokümandaki yayınlanmış donanım temel referansı resmî Xiaomi Redmi Note 9 Pro teknik özelliklerine dayanmaktadır.)*

ARCore compatibility is based on Google’s official ARCore supported-device information. *(ARCore uyumluluğu Google’ın resmî ARCore desteklenen cihaz bilgilerine dayanmaktadır.)*

Android sensor sampling constraints are based on official Android Developers documentation. *(Android sensör örnekleme kısıtları resmî Android Developers dokümantasyonuna dayanmaktadır.)*

Physical runtime measurements collected from the project device will supersede generic published assumptions where appropriate. *(Projede kullanılan fiziksel cihazdan toplanan çalışma zamanı ölçümleri uygun olan durumlarda genel yayınlanmış varsayımların yerini alacaktır.)*

---

# 52. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Completed *(Doküman Durumu: Tamamlandı)*

**Hardware Baseline Status:** Provisional Until Device Capability Audit *(Donanım Temel Referansı Durumu: Cihaz Yetenek Denetimine Kadar Geçici)*

**Target Platform:** Android Only *(Hedef Platform: Yalnızca Android)*

**Primary Device:** Xiaomi Redmi Note 9 Pro *(Birincil Cihaz: Xiaomi Redmi Note 9 Pro)*

**ARCore Compatibility:** Officially Supported, Physical Verification Pending *(ARCore Uyumluluğu: Resmî Olarak Destekleniyor, Fiziksel Doğrulama Bekleniyor)*

**Core Sensor Baseline:** Accelerometer, Gyroscope, Electronic Compass, GNSS *(Temel Sensör Referansı: İvmeölçer, Jiroskop, Elektronik Pusula, GNSS)*

**Next Documentation Item:** 06 — Device Capability Audit *(Sonraki Dokümantasyon Öğesi: 06 — Cihaz Yetenek Denetimi)*