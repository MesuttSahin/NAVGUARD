# 32 — Permissions, Privacy & Security (İzinler, Gizlilik ve Güvenlik)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the Android permission model, privacy boundaries, local-data protection policy, experiment-data handling rules, Ground Truth Firewall security requirements, model and artifact integrity controls, export protections, logging restrictions, and runtime security behavior for NAVGUARD. *(Bu doküman NAVGUARD için Android izin modelini, gizlilik sınırlarını, yerel veri koruma politikasını, deney verisi yönetim kurallarını, Ground Truth Firewall güvenlik gereksinimlerini, model ve artifact bütünlük kontrollerini, export korumalarını, logging kısıtlamalarını ve runtime güvenlik davranışını tanımlar.)*

The objective is to request only permissions that are technically necessary, keep navigation data local by default, prevent accidental leakage of protected GNSS ground truth into the estimator, and preserve the integrity of formal research evidence. *(Amaç yalnızca teknik olarak gerekli izinleri istemek, navigasyon verisini varsayılan olarak yerel tutmak, korunan GNSS ground truth'un tahmin motoruna yanlışlıkla sızmasını önlemek ve resmî araştırma kanıtının bütünlüğünü korumaktır.)*

---

# 2. Security Philosophy (Güvenlik Felsefesi)

NAVGUARD will follow a least-privilege and local-first security model. *(NAVGUARD least-privilege ve local-first güvenlik modeli izleyecektir.)*

The application will not request access to device capabilities merely because those capabilities are available. *(Uygulama cihaz yeteneklerine yalnızca bu yetenekler mevcut olduğu için erişim istemeyecektir.)*

---

# 3. Permission Minimization Principle (İzin Minimizasyonu İlkesi)

Android permissions will be requested only when a selected NAVGUARD feature actually requires them. *(Android izinleri yalnızca seçilen NAVGUARD özelliği gerçekten gerektirdiğinde istenecektir.)*

Android's current privacy guidance similarly recommends minimizing permission requests and using less-sensitive alternatives where they satisfy the use case. *(Android'in güncel gizlilik rehberi de permission taleplerinin azaltılmasını ve kullanım senaryosunu karşılıyorsa daha az hassas alternatiflerin kullanılmasını önermektedir.)*

---

# 4. Contextual Permission Requests (Bağlama Dayalı İzin İstekleri)

NAVGUARD will request runtime permissions in context rather than displaying every possible permission dialog immediately at first launch. *(NAVGUARD runtime permission'larını ilk açılışta tüm olası izin dialog'larını hemen göstermek yerine bağlam içerisinde isteyecektir.)*

---

# 5. Permission Denial Is a Supported State (İzin Reddetme Desteklenen Bir Durumdur)

A denied permission will be handled as an explicit runtime state rather than an unexpected crash condition. *(Reddedilmiş permission beklenmedik crash koşulu yerine açık runtime durumu olarak yönetilecektir.)*

---

# 6. Permission Matrix (İzin Matrisi)

The planned permission classes are summarized below. *(Planlanan izin sınıfları aşağıda özetlenmiştir.)*

| Permission / Capability      | NAVGUARD Role                              | Initial Policy                                     |
| ---------------------------- | ------------------------------------------ | -------------------------------------------------- |
| `ACCESS_FINE_LOCATION`       | Precise GNSS                               | Required for formal GNSS navigation and evaluation |
| `ACCESS_COARSE_LOCATION`     | Android location permission pairing        | Requested together with Fine where required        |
| `CAMERA`                     | ARCore visual-inertial tracking            | Required only for ARCore-enabled profiles          |
| `ACTIVITY_RECOGNITION`       | Android Step Detector / Counter comparison | Optional                                           |
| `HIGH_SAMPLING_RATE_SENSORS` | Motion sensors above Android rate limits   | Not required initially                             |
| `ACCESS_BACKGROUND_LOCATION` | Background GNSS                            | Not required in minimum architecture               |
| Broad storage permission     | General filesystem access                  | Not required                                       |
| `RECORD_AUDIO`               | Microphone                                 | Not required                                       |
| Bluetooth permissions        | External devices                           | Not required                                       |
| Contacts / Phone / SMS       | Personal communications                    | Forbidden / Not required                           |

---

# 7. Precise Location Is Required for Formal Experiments (Resmî Deneyler İçin Kesin Konum Gereklidir)

Formal GNSS anchoring, Evaluation Mode ground truth, recovery comparison, and position-error measurement require precise location access. *(Resmî GNSS anchoring, Evaluation Mode ground truth, recovery karşılaştırması ve konum-hata ölçümü kesin konum erişimi gerektirir.)*

---

# 8. Android Precise and Approximate Location Model (Android Kesin ve Yaklaşık Konum Modeli)

On current Android versions, users may grant approximate location even when an application asks for precise location. *(Mevcut Android sürümlerinde uygulama kesin konum istese bile kullanıcı yaklaşık konum izni verebilir.)*

Android's current guidance requires `ACCESS_FINE_LOCATION` to be requested together with `ACCESS_COARSE_LOCATION`, and Android 12 and later allow the user to choose between Precise and Approximate access. *(Android'in güncel rehberi `ACCESS_FINE_LOCATION` izninin `ACCESS_COARSE_LOCATION` ile birlikte istenmesini gerektirir ve Android 12 ve sonrasında kullanıcı Precise ile Approximate erişim arasında seçim yapabilir.)*

---

# 9. NAVGUARD Location Permission Request (NAVGUARD Konum İzni İsteği)

The formal location request will therefore request both permissions through the appropriate Android runtime flow. *(Bu nedenle resmî konum isteği uygun Android runtime akışı üzerinden iki izni birlikte isteyecektir.)*

```text
ACCESS_COARSE_LOCATION
ACCESS_FINE_LOCATION
```

---

# 10. Approximate-Only Location Behavior (Yalnızca Yaklaşık Konum Davranışı)

If the user grants only approximate location, NAVGUARD will not pretend that formal GNSS evaluation requirements are satisfied. *(Kullanıcı yalnızca yaklaşık konuma izin verirse NAVGUARD resmî GNSS değerlendirme gereksinimlerinin karşılandığını varsaymayacaktır.)*

---

# 11. Approximate Location May Allow Limited Application Use (Yaklaşık Konum Sınırlı Uygulama Kullanımına İzin Verebilir)

The application may remain usable for some diagnostics or non-formal screens with approximate location. *(Uygulama yaklaşık konumla bazı diagnostics veya resmî olmayan ekranlar için kullanılabilir kalabilir.)*

Formal anchor acquisition and quantitative GNSS-ground-truth experiments will remain blocked. *(Resmî anchor acquisition ve nicel GNSS-ground-truth deneyleri blocked kalacaktır.)*

---

# 12. Precise Location Readiness Gate (Kesin Konum Hazırlık Kapısı)

The Readiness Screen will distinguish between location permission being granted and precise location actually being available. *(Hazırlık Ekranı location permission'ın verilmesiyle kesin konumun gerçekten kullanılabilir olması arasında ayrım yapacaktır.)*

---

# 13. Location Permission Rationale (Konum İzni Açıklaması)

The permission rationale will explain that precise location is needed to establish the initial GNSS anchor and independently evaluate GNSS-denied position error. *(Permission açıklaması kesin konumun ilk GNSS anchor'ını oluşturmak ve GNSS kesintili konum hatasını bağımsız olarak değerlendirmek için gerekli olduğunu açıklayacaktır.)*

---

# 14. Ground Truth Must Be Mentioned Transparently (Ground Truth Şeffaf Şekilde Belirtilmelidir)

Evaluation Mode documentation will state that GNSS may continue being recorded as protected reference data while being excluded from the estimator. *(Evaluation Mode dokümantasyonu GNSS'in tahmin motorundan hariç tutulurken korunan referans verisi olarak kaydedilmeye devam edebileceğini belirtecektir.)*

---

# 15. Background Location Is Not Required Initially (Arka Plan Konumu Başlangıçta Gerekli Değildir)

NAVGUARD's minimum architecture is foreground-first and does not require continuous hidden background location collection. *(NAVGUARD'ın minimum mimarisi foreground-first'tür ve sürekli gizli arka plan konum toplama gerektirmez.)*

---

# 16. `ACCESS_BACKGROUND_LOCATION` Initial Policy (`ACCESS_BACKGROUND_LOCATION` İlk Politikası)

`ACCESS_BACKGROUND_LOCATION` will not be declared or requested in the minimum implementation. *(`ACCESS_BACKGROUND_LOCATION` minimum uygulamada declare veya request edilmeyecektir.)*

---

# 17. Background Location Requires Scope Revision (Arka Plan Konumu Kapsam Revizyonu Gerektirir)

If future requirements introduce true background GNSS tracking, the permission model must be reviewed and documented before implementation. *(Gelecekteki gereksinimler gerçek arka plan GNSS tracking getirirse permission modeli uygulamadan önce yeniden incelenmeli ve dokümante edilmelidir.)*

---

# 18. Android Foreground Location Context (Android Foreground Konum Bağlamı)

Android distinguishes visible or foreground-service location access from background location access. *(Android görünür veya foreground-service location erişimini background location erişiminden ayırır.)*

A visible activity is considered foreground location use, while background location has additional restrictions. *(Görünür activity foreground location kullanımı olarak değerlendirilirken background location ek kısıtlamalara sahiptir.)*

---

# 19. Foreground-Service Decision Is Deferred (Foreground Service Kararı Ertelenmiştir)

The first NAVGUARD implementation will not introduce a foreground service merely to make the architecture appear more sophisticated. *(İlk NAVGUARD uygulaması yalnızca mimarinin daha gelişmiş görünmesi için foreground service eklemeyecektir.)*

---

# 20. Foreground Service Conditional Requirement (Foreground Service Koşullu Gereksinimi)

If later testing demonstrates that a foreground service is necessary, its Android service type and corresponding permissions will be added as an explicit architectural change. *(Daha sonraki testler foreground service'in gerekli olduğunu gösterirse Android service type ve karşılık gelen permission'ları açık mimari değişiklik olarak eklenecektir.)*

---

# 21. Location Foreground Service Rule (Konum Foreground Service Kuralı)

Current Android documentation requires a location foreground service to declare the location service type and relevant foreground-service permission, while location runtime permission must also be available. *(Güncel Android dokümantasyonu konum foreground service'inin location service type ve ilgili foreground-service iznini declare etmesini, ayrıca location runtime izninin de mevcut olmasını gerektirir.)*

---

# 22. Camera Permission Purpose (Kamera İzninin Amacı)

The camera will be used only when ARCore visual-inertial tracking is enabled. *(Kamera yalnızca ARCore visual-inertial tracking etkin olduğunda kullanılacaktır.)*

---

# 23. Camera Permission Is Dangerous Permission (Kamera İzni Dangerous Permission'dır)

Android defines `CAMERA` as a dangerous runtime permission required for direct camera-device access. *(Android `CAMERA` iznini doğrudan kamera cihazı erişimi için gerekli dangerous runtime permission olarak tanımlar.)*

---

# 24. ARCore Camera Requirement (ARCore Kamera Gereksinimi)

Google's current ARCore Android guidance requires camera permission before an AR session can be created. *(Google'ın güncel ARCore Android rehberi bir AR session oluşturulmadan önce kamera izninin verilmesini gerektirir.)*

---

# 25. ARCore Will Be Treated as Optional at Application Level (ARCore Uygulama Seviyesinde İsteğe Bağlı Ele Alınacaktır)

Because minimum NAVGUARD navigation can fall back to PDR without ARCore, the application architecture will treat ARCore as an enhancement rather than an absolute application requirement. *(Minimum NAVGUARD navigasyonu ARCore olmadan PDR'a fallback yapabildiği için uygulama mimarisi ARCore'u mutlak uygulama gereksinimi yerine geliştirme bileşeni olarak ele alacaktır.)*

---

# 26. AR Optional Direction (AR Optional Yönü)

The preferred packaging direction is therefore AR Optional unless later distribution requirements justify AR Required. *(Bu nedenle daha sonraki dağıtım gereksinimleri AR Required'ı gerekçelendirmedikçe tercih edilen paketleme yönü AR Optional olacaktır.)*

Google documents AR Optional applications as applications that remain usable without ARCore while using it when available. *(Google AR Optional uygulamaları ARCore olmadan kullanılabilir kalırken mevcut olduğunda onu kullanan uygulamalar olarak dokümante etmektedir.)*

---

# 27. Camera Permission Request Timing (Kamera İzni İstek Zamanı)

NAVGUARD will request camera permission when the user selects an ARCore-enabled configuration or enters an ARCore diagnostic workflow. *(NAVGUARD kullanıcı ARCore etkin yapılandırma seçtiğinde veya ARCore diagnostic workflow'una girdiğinde kamera iznini isteyecektir.)*

---

# 28. PDR-Only Configuration Does Not Need Camera (Yalnızca PDR Yapılandırması Kamera Gerektirmez)

Configuration A will not require camera access. *(Configuration A kamera erişimi gerektirmeyecektir.)*

---

# 29. ARCore Permission Denial (ARCore İzin Reddi)

If camera permission is denied, ARCore will become unavailable rather than causing the entire application to crash. *(Kamera izni reddedilirse ARCore tüm uygulamanın crash olmasına neden olmak yerine kullanılamaz hale gelecektir.)*

---

# 30. Configuration-Specific Blocking (Yapılandırmaya Özgü Blocking)

Camera denial may block Configuration C or an ARCore-dependent Configuration D profile. *(Kamera reddi Configuration C'yi veya ARCore bağımlı Configuration D profilini engelleyebilir.)*

It will not block a valid minimum PDR-only profile. *(Geçerli minimum PDR-only profilini engellemeyecektir.)*

---

# 31. Camera Frames Are Transient by Default (Kamera Kareleri Varsayılan Olarak Geçicidir)

NAVGUARD will not save raw ARCore camera frames by default. *(NAVGUARD ham ARCore kamera karelerini varsayılan olarak kaydetmeyecektir.)*

---

# 32. Camera Data Minimization (Kamera Verisi Minimizasyonu)

The camera is used to derive ARCore visual-inertial motion information, while the stored experiment evidence will primarily retain ARCore pose and tracking metadata. *(Kamera ARCore visual-inertial hareket bilgisini türetmek için kullanılırken saklanan deney kanıtı temel olarak ARCore pose ve tracking metadata bilgisini koruyacaktır.)*

---

# 33. No Automatic Camera Recording (Otomatik Kamera Kaydı Olmaması)

NAVGUARD will not create ordinary photographs or videos during navigation unless a future explicitly documented research feature requires them. *(NAVGUARD gelecekte açıkça dokümante edilmiş araştırma özelliği gerektirmedikçe navigasyon sırasında normal fotoğraf veya video oluşturmayacaktır.)*

---

# 34. Microphone Permission Is Not Required (Mikrofon İzni Gerekli Değildir)

NAVGUARD's current navigation architecture does not require audio input. *(NAVGUARD'ın mevcut navigasyon mimarisi ses girdisi gerektirmez.)*

---

# 35. `RECORD_AUDIO` Is Forbidden in Minimum Scope (`RECORD_AUDIO` Minimum Kapsamda Yasaktır)

The application will not request `RECORD_AUDIO` in the current scope. *(Uygulama mevcut kapsamda `RECORD_AUDIO` istemeyecektir.)*

---

# 36. No Hidden Audio Capture (Gizli Ses Yakalama Olmaması)

No microphone data will be stored in session evidence. *(Oturum kanıtında mikrofon verisi saklanmayacaktır.)*

---

# 37. Raw Motion Sensors and Runtime Permissions (Ham Hareket Sensörleri ve Runtime İzinleri)

The core accelerometer, gyroscope, and magnetometer pipeline does not require a dangerous user-facing runtime permission for the planned sampling rates. *(Temel ivmeölçer, jiroskop ve manyetometre hattı planlanan sampling hızları için kullanıcıya gösterilen dangerous runtime permission gerektirmez.)*

---

# 38. Android Sensor Rate Limiting (Android Sensör Hız Sınırlaması)

For applications targeting Android 12 or later, Android limits certain motion-sensor streams obtained with `SensorEventListener` to 200 Hz unless `HIGH_SAMPLING_RATE_SENSORS` is declared. *(Android 12 veya sonrasını hedefleyen uygulamalarda Android, `HIGH_SAMPLING_RATE_SENSORS` declare edilmedikçe `SensorEventListener` ile alınan belirli hareket sensörü stream'lerini 200 Hz ile sınırlar.)*

---

# 39. NAVGUARD Does Not Need More Than 200 Hz Initially (NAVGUARD Başlangıçta 200 Hz Üzerine İhtiyaç Duymaz)

NAVGUARD's provisional accelerometer and gyroscope targets are approximately 50 Hz and therefore remain well below the Android high-rate threshold. *(NAVGUARD'ın geçici ivmeölçer ve jiroskop hedefleri yaklaşık 50 Hz'dir ve bu nedenle Android high-rate eşiğinin oldukça altında kalır.)*

---

# 40. `HIGH_SAMPLING_RATE_SENSORS` Initial Policy (`HIGH_SAMPLING_RATE_SENSORS` İlk Politikası)

`HIGH_SAMPLING_RATE_SENSORS` will not be declared in the initial implementation unless profiling proves a requirement above the standard rate limit. *(`HIGH_SAMPLING_RATE_SENSORS`, profiling standart hız sınırının üzerinde gereksinim kanıtlamadıkça ilk uygulamada declare edilmeyecektir.)*

---

# 41. Permission Creep Is Forbidden (Permission Creep Yasaktır)

Increasing sensor rate for experimentation will not automatically justify adding a new permission. *(Deney için sensör hızını artırmak otomatik olarak yeni permission eklemeyi gerekçelendirmeyecektir.)*

The benefit must first be measured. *(Fayda önce ölçülmelidir.)*

---

# 42. Android Step Detector and Step Counter (Android Adım Algılayıcı ve Adım Sayacı)

NAVGUARD's authoritative step-detection method will be implemented from its own sensor-processing pipeline. *(NAVGUARD'ın ana adım tespit yöntemi kendi sensör işleme hattından uygulanacaktır.)*

Android's built-in step detector and step counter may only be used as optional comparison sources. *(Android'in built-in step detector ve step counter sensörleri yalnızca isteğe bağlı karşılaştırma kaynakları olarak kullanılabilir.)*

---

# 43. `ACTIVITY_RECOGNITION` Requirement (`ACTIVITY_RECOGNITION` Gereksinimi)

Android 10 and later require `ACTIVITY_RECOGNITION` for use of the built-in step detector and step counter sensors. *(Android 10 ve sonrası built-in step detector ve step counter sensörlerinin kullanımı için `ACTIVITY_RECOGNITION` gerektirir.)*

---

# 44. `ACTIVITY_RECOGNITION` Is Optional for NAVGUARD (`ACTIVITY_RECOGNITION` NAVGUARD İçin İsteğe Bağlıdır)

The minimum NAVGUARD navigation architecture will not depend on this permission. *(Minimum NAVGUARD navigasyon mimarisi bu izne bağlı olmayacaktır.)*

---

# 45. Optional Step-Sensor Comparison Permission (İsteğe Bağlı Adım Sensörü Karşılaştırma İzni)

If the built-in Android step sensors are enabled for comparison, `ACTIVITY_RECOGNITION` will be requested in context and the session configuration will record that comparison source. *(Built-in Android adım sensörleri karşılaştırma için etkinleştirilirse `ACTIVITY_RECOGNITION` bağlam içerisinde istenecek ve oturum yapılandırması bu karşılaştırma kaynağını kaydedecektir.)*

---

# 46. Activity Recognition Denial (Activity Recognition Reddi)

Denial of this optional permission will disable only the Android built-in step-sensor comparison. *(Bu isteğe bağlı iznin reddedilmesi yalnızca Android built-in adım sensörü karşılaştırmasını devre dışı bırakacaktır.)*

NAVGUARD's independent step detector will continue functioning. *(NAVGUARD'ın bağımsız adım algılayıcısı çalışmaya devam edecektir.)*

---

# 47. Storage Permission Philosophy (Depolama İzin Felsefesi)

Active experiment evidence will remain in app-controlled storage rather than requiring broad filesystem access. *(Aktif deney kanıtı geniş filesystem erişimi gerektirmek yerine uygulama kontrollü depolamada kalacaktır.)*

---

# 48. App-Specific Internal Storage (Uygulamaya Özgü Dahili Depolama)

Android app-specific internal storage is inaccessible to other ordinary applications and does not require a storage runtime permission. *(Android uygulamaya özgü dahili depolaması diğer normal uygulamalar tarafından erişilemez ve storage runtime permission gerektirmez.)*

---

# 49. Sensitive Session Storage Preference (Hassas Oturum Depolama Tercihi)

Sensitive navigation session metadata, SQLite state, manifests, and critical experiment evidence will preferably remain in app-controlled private storage while actively managed by NAVGUARD. *(Hassas navigasyon oturum metadata bilgisi, SQLite durumu, manifestler ve kritik deney kanıtı NAVGUARD tarafından aktif olarak yönetilirken tercihen uygulama kontrollü private storage içerisinde kalacaktır.)*

---

# 50. Android Internal Storage Protection (Android Dahili Depolama Koruması)

Android documentation states that app-specific internal-storage locations are protected from other apps and are encrypted on Android 10 and later. *(Android dokümantasyonu uygulamaya özgü internal-storage konumlarının diğer uygulamalardan korunduğunu ve Android 10 ve sonrasında şifrelendiğini belirtmektedir.)*

---

# 51. System Encryption Is Not Application-Level Encryption (Sistem Şifrelemesi Uygulama Seviyesi Şifreleme Değildir)

NAVGUARD will not describe Android's storage protection as custom NAVGUARD encryption. *(NAVGUARD Android'in depolama korumasını özel NAVGUARD encryption olarak tanımlamayacaktır.)*

---

# 52. External App-Specific Storage (Harici Uygulamaya Özgü Depolama)

If session size makes internal storage impractical, app-specific external storage may be evaluated. *(Oturum boyutu internal storage'ı kullanışsız hale getirirse uygulamaya özgü external storage değerlendirilebilir.)*

Android 4.4 and later do not require storage permissions for an application's own external app-specific directory. *(Android 4.4 ve sonrası uygulamanın kendi external app-specific klasörü için storage permission gerektirmez.)*

---

# 53. Critical Evidence Prefers Reliable Storage (Kritik Kanıt Güvenilir Depolamayı Tercih Eder)

Storage that may become unavailable should not be selected for critical active evidence without explicit runtime availability checks. *(Kullanılamaz hale gelebilecek depolama açık runtime kullanılabilirlik kontrolleri olmadan kritik aktif kanıt için seçilmemelidir.)*

---

# 54. Broad Storage Permission Is Not Required (Geniş Storage İzni Gerekli Değildir)

NAVGUARD does not require unrestricted access to the entire shared filesystem. *(NAVGUARD tüm shared filesystem'e sınırsız erişim gerektirmez.)*

---

# 55. `MANAGE_EXTERNAL_STORAGE` Is Out of Scope (`MANAGE_EXTERNAL_STORAGE` Kapsam Dışıdır)

NAVGUARD will not request Android's all-files access permission in the current architecture. *(NAVGUARD mevcut mimaride Android all-files access iznini istemeyecektir.)*

Android's storage guidance states that most applications do not need this broad access. *(Android'in storage rehberi çoğu uygulamanın bu geniş erişime ihtiyaç duymadığını belirtmektedir.)*

---

# 56. Legacy Write Permission Is Not Part of Target Design (Legacy Yazma İzni Hedef Tasarımın Parçası Değildir)

The current architecture will not depend on legacy `WRITE_EXTERNAL_STORAGE` behavior. *(Mevcut mimari legacy `WRITE_EXTERNAL_STORAGE` davranışına bağlı olmayacaktır.)*

---

# 57. Storage Access Framework for Export (Export İçin Storage Access Framework)

Session export will use the Android Storage Access Framework or an equivalent user-mediated document workflow. *(Oturum export'u Android Storage Access Framework veya eşdeğer kullanıcı kontrollü doküman workflow'u kullanacaktır.)*

---

# 58. SAF Does Not Require Broad Storage Permission (SAF Geniş Storage İzni Gerektirmez)

Android's Storage Access Framework lets the user select a target document or directory through the system picker without granting the application broad storage permission. *(Android Storage Access Framework kullanıcının uygulamaya geniş storage permission vermeden sistem picker üzerinden hedef doküman veya klasör seçmesine izin verir.)*

---

# 59. User Controls Export Destination (Kullanıcı Export Hedefini Kontrol Eder)

The user will explicitly choose where an exported NAVGUARD package is written. *(Kullanıcı export edilmiş NAVGUARD paketinin nereye yazılacağını açık şekilde seçecektir.)*

---

# 60. Export Changes the Security Boundary (Export Güvenlik Sınırını Değiştirir)

Once a session is exported to a user-selected shared location, the file is no longer protected solely by NAVGUARD's private app-storage boundary. *(Bir oturum kullanıcı tarafından seçilen shared konuma export edildikten sonra dosya artık yalnızca NAVGUARD'ın private app-storage sınırı tarafından korunmaz.)*

---

# 61. Export Privacy Warning (Export Gizlilik Uyarısı)

Before exporting location-containing evidence, the UI will clearly state that the package may contain precise movement and GNSS information. *(Konum içeren kanıt export edilmeden önce UI paketin kesin hareket ve GNSS bilgisi içerebileceğini açık şekilde belirtecektir.)*

---

# 62. Export Is User-Initiated (Export Kullanıcı Tarafından Başlatılır)

NAVGUARD will not automatically copy research sessions to shared storage. *(NAVGUARD araştırma oturumlarını shared storage'a otomatik olarak kopyalamayacaktır.)*

---

# 63. No Automatic Cloud Upload (Otomatik Cloud Upload Olmaması)

The minimum NAVGUARD architecture has no mandatory backend and will not automatically upload session evidence to a remote server. *(Minimum NAVGUARD mimarisinde zorunlu backend bulunmaz ve oturum kanıtını uzak sunucuya otomatik yüklemeyecektir.)*

---

# 64. No Mandatory Account (Zorunlu Hesap Olmaması)

The minimum research application will not require user sign-in for navigation. *(Minimum araştırma uygulaması navigasyon için kullanıcı sign-in gerektirmeyecektir.)*

---

# 65. No Automatic Analytics Upload (Otomatik Analytics Upload Olmaması)

The minimum architecture will not transmit sensor, GNSS, ARCore, or trajectory data to a third-party analytics service. *(Minimum mimari sensör, GNSS, ARCore veya trajectory verisini üçüncü taraf analytics servisine göndermeyecektir.)*

---

# 66. Future Telemetry Requires Explicit Review (Gelecekteki Telemetry Açık İnceleme Gerektirir)

If remote crash reporting or analytics is later introduced, its data fields and privacy implications must be reviewed before activation. *(Uzaktan crash reporting veya analytics daha sonra eklenirse veri alanları ve gizlilik etkileri etkinleştirmeden önce incelenmelidir.)*

---

# 67. Network Is Not a Navigation Dependency (Ağ Navigasyon Bağımlılığı Değildir)

The core estimator will continue operating without Internet connectivity. *(Temel tahmin motoru internet bağlantısı olmadan çalışmaya devam edecektir.)*

---

# 68. Optional Network Usage (İsteğe Bağlı Ağ Kullanımı)

Network connectivity may optionally be used for map imagery or platform-service availability outside the estimator. *(Ağ bağlantısı tahmin motorunun dışında harita görüntüsü veya platform servis kullanılabilirliği için isteğe bağlı olarak kullanılabilir.)*

---

# 69. Network Data Must Not Alter Protected Evaluation (Ağ Verisi Korunan Değerlendirmeyi Değiştirmemelidir)

Online map or service data will not bypass the Ground Truth Firewall or become an undeclared absolute-position correction source. *(Online harita veya servis verisi Ground Truth Firewall'u atlamayacak veya declare edilmemiş mutlak konum düzeltme kaynağı haline gelmeyecektir.)*

---

# 70. Map Tiles Are Visualization Data (Harita Tile'ları Görselleştirme Verisidir)

Map tiles will remain visual context rather than estimator measurements. *(Harita tile'ları tahmin motoru measurement'ları yerine görsel bağlam olarak kalacaktır.)*

---

# 71. Data Classification Model (Veri Sınıflandırma Modeli)

NAVGUARD will classify stored information by sensitivity. *(NAVGUARD saklanan bilgiyi hassasiyete göre sınıflandıracaktır.)*

```text
PUBLIC
INTERNAL
SENSITIVE
INTEGRITY_CRITICAL
```

---

# 72. PUBLIC Data (PUBLIC Veri)

Public data may include generic application version information and public project documentation. *(Public veri genel uygulama sürüm bilgisini ve halka açık proje dokümantasyonunu içerebilir.)*

---

# 73. INTERNAL Data (INTERNAL Veri)

Internal data may include runtime configuration IDs, feature flags, and non-sensitive diagnostic metadata. *(Internal veri runtime yapılandırma ID'lerini, feature flag'leri ve hassas olmayan diagnostic metadata bilgisini içerebilir.)*

---

# 74. SENSITIVE Data (SENSITIVE Veri)

Precise GNSS coordinates, movement trajectories, timestamps associated with those coordinates, and detailed experiment notes will be treated as sensitive application data. *(Kesin GNSS koordinatları, hareket trajectory'leri, bu koordinatlarla ilişkili zaman damgaları ve ayrıntılı deney notları hassas uygulama verisi olarak ele alınacaktır.)*

---

# 75. INTEGRITY_CRITICAL Data (INTEGRITY_CRITICAL Veri)

Ground Truth Firewall state, denied-interval boundaries, model hashes, recovery evidence, configuration snapshots, and benchmark manifests are integrity-critical evidence. *(Ground Truth Firewall durumu, kesintili aralık sınırları, model hash'leri, recovery kanıtı, yapılandırma snapshot'ları ve benchmark manifestleri bütünlük açısından kritik kanıttır.)*

---

# 76. Data May Belong to More Than One Class (Veri Birden Fazla Sınıfa Ait Olabilir)

A GNSS ground-truth file is both sensitive and integrity-critical. *(GNSS ground-truth dosyası hem hassas hem bütünlük açısından kritiktir.)*

---

# 77. Data Minimization (Veri Minimizasyonu)

NAVGUARD will collect only information necessary for navigation, reproducibility, diagnostics, model development, and experiment evaluation. *(NAVGUARD yalnızca navigasyon, tekrarlanabilirlik, diagnostics, model geliştirme ve deney değerlendirmesi için gerekli bilgiyi toplayacaktır.)*

---

# 78. No Contacts Access (Kişiler Erişimi Olmaması)

NAVGUARD has no requirement to access the user's contacts. *(NAVGUARD'ın kullanıcının kişiler listesine erişim gereksinimi yoktur.)*

---

# 79. No SMS Access (SMS Erişimi Olmaması)

NAVGUARD has no requirement to read or send SMS messages. *(NAVGUARD'ın SMS mesajlarını okuma veya gönderme gereksinimi yoktur.)*

---

# 80. No Phone Access (Telefon Erişimi Olmaması)

NAVGUARD has no requirement to read phone state, call logs, or phone numbers. *(NAVGUARD'ın telefon durumunu, call loglarını veya telefon numaralarını okuma gereksinimi yoktur.)*

---

# 81. No Bluetooth Requirement (Bluetooth Gereksinimi Olmaması)

The minimum system uses standard smartphone hardware and does not require Bluetooth peripherals. *(Minimum sistem standart akıllı telefon donanımını kullanır ve Bluetooth peripheral gerektirmez.)*

---

# 82. No Body-Sensor Permission (Body-Sensor İzni Olmaması)

NAVGUARD does not require heart-rate, oxygen, skin-temperature, or other medical body-sensor data. *(NAVGUARD kalp hızı, oksijen, cilt sıcaklığı veya diğer tıbbi body-sensor verilerini gerektirmez.)*

---

# 83. Device Identifiers (Cihaz Tanımlayıcıları)

NAVGUARD will not use IMEI or another non-resettable hardware identifier as a session identity. *(NAVGUARD oturum kimliği olarak IMEI veya başka resetlenemeyen hardware identifier kullanmayacaktır.)*

Android security guidance recommends avoiding non-resettable hardware identifiers such as IMEI for application identification. *(Android güvenlik rehberi uygulama tanımlama için IMEI gibi resetlenemeyen hardware identifier'ların kullanılmamasını önermektedir.)*

---

# 84. Session Identity Is Application-Scoped (Oturum Kimliği Uygulama Kapsamlıdır)

NAVGUARD will generate its own random or UUID-backed session identifiers. *(NAVGUARD kendi random veya UUID tabanlı oturum tanımlayıcılarını oluşturacaktır.)*

---

# 85. Device Metadata Minimization (Cihaz Metadata Minimizasyonu)

Only hardware and software metadata necessary for reproducibility will be stored. *(Yalnızca tekrarlanabilirlik için gerekli hardware ve software metadata bilgisi saklanacaktır.)*

---

# 86. No Personal Profile Requirement (Kişisel Profil Gereksinimi Olmaması)

The application will not require the user to create a personal profile for minimum research operation. *(Uygulama minimum araştırma çalışması için kullanıcının kişisel profil oluşturmasını gerektirmeyecektir.)*

---

# 87. Ground Truth Firewall as a Security Boundary (Güvenlik Sınırı Olarak Ground Truth Firewall)

The Ground Truth Firewall is both a scientific-integrity mechanism and an internal information-flow security boundary. *(Ground Truth Firewall hem bilimsel bütünlük mekanizması hem dahili bilgi akışı güvenlik sınırıdır.)*

---

# 88. Ground Truth Classification (Ground Truth Sınıflandırması)

Evaluation GNSS data will be tagged as protected reference data. *(Evaluation GNSS verisi korunan referans verisi olarak etiketlenecektir.)*

```text
REFERENCE_ONLY
```

---

# 89. Estimator Authorization Is Explicit (Tahmin Motoru Authorization Açıktır)

The presence of a GNSS sample in memory or storage does not authorize the estimator to use it. *(GNSS örneğinin bellekte veya depolamada bulunması tahmin motoruna onu kullanma yetkisi vermez.)*

---

# 90. Authorization Before Quality (Kaliteden Önce Authorization)

A high-quality protected GNSS fix remains forbidden to the estimator while the firewall state is blocked. *(Yüksek kaliteli korunan GNSS fix'i firewall durumu blocked iken tahmin motoru için yasak kalır.)*

---

# 91. Ground Truth Separation in Memory (Bellekte Ground Truth Ayrımı)

Native acquisition will maintain logically separate estimator-authorized and ground-truth/reference pathways. *(Native acquisition mantıksal olarak ayrı tahmin motoru-authorized ve ground-truth/reference yolları tutacaktır.)*

---

# 92. Ground Truth Separation in Storage (Depolamada Ground Truth Ayrımı)

Ground-truth data will use separate artifacts from fused-position and PDR outputs. *(Ground-truth verisi fused-position ve PDR çıktılarından ayrı artifact'lar kullanacaktır.)*

---

# 93. Ground Truth Separation in Replay (Replay'de Ground Truth Ayrımı)

Replay will enforce the original authorization boundary even though the complete session archive contains ground-truth files. *(Replay tam oturum arşivi ground-truth dosyalarını içerse bile orijinal authorization sınırını uygulayacaktır.)*

---

# 94. Ground Truth Separation in UI (UI'da Ground Truth Ayrımı)

Protected ground truth will be hidden during blinded denied intervals as defined in Page 31. *(Korunan ground truth Page 31'de tanımlandığı şekilde blinded kesintili aralıklarda gizli olacaktır.)*

---

# 95. Ground Truth Violation Severity (Ground Truth İhlal Seviyesi)

Unauthorized ground-truth influence is a critical research-integrity violation. *(Yetkisiz ground-truth etkisi kritik araştırma bütünlüğü ihlalidir.)*

---

# 96. Violation Counter (İhlal Counter'ı)

```text
unauthorizedGnssEstimatorUpdateCount
```

This counter must remain zero during every formal denied interval. *(Bu counter her resmî kesintili aralıkta sıfır kalmalıdır.)*

---

# 97. Non-Zero Violation Counter (Sıfır Olmayan İhlal Counter'ı)

A non-zero unauthorized update count invalidates the corresponding formal denied interval. *(Sıfır olmayan unauthorized update count karşılık gelen resmî kesintili aralığı geçersiz kılar.)*

---

# 98. Protected Data Must Not Enter AI Features (Korunan Veri AI Feature'larına Girmemelidir)

Evaluation GNSS latitude, longitude, speed, bearing, or derived displacement must not become live AI features when they would influence denied navigation. *(Evaluation GNSS enlem, boylam, hız, bearing veya türetilmiş displacement değerleri kesintili navigasyonu etkileyecekse canlı AI feature'ları haline gelmemelidir.)*

---

# 99. Protected Data Must Not Enter EKF Updates (Korunan Veri EKF Update'lerine Girmemelidir)

No protected absolute GNSS position update may enter the EKF during an active denied interval. *(Aktif kesintili aralık sırasında hiçbir korunan mutlak GNSS konum update'i EKF'ye giremez.)*

---

# 100. Protected Data Must Not Move the Anchor (Korunan Veri Anchor'ı Taşımamalıdır)

Ground truth cannot silently modify the active anchor during the denied interval. *(Ground truth kesintili aralık sırasında aktif anchor'ı sessizce değiştiremez.)*

---

# 101. Security Events (Güvenlik Olayları)

Security-relevant internal events will be logged structurally. *(Güvenlikle ilişkili dahili olaylar yapılandırılmış olarak loglanacaktır.)*

---

# 102. Candidate Security Event Types (Aday Güvenlik Olay Türleri)

```text
PERMISSION_GRANTED
PERMISSION_DENIED
PERMISSION_REVOKED
GROUND_TRUTH_ACCESS_BLOCKED
GROUND_TRUTH_VIOLATION
MODEL_HASH_MISMATCH
ARTIFACT_HASH_MISMATCH
EXPORT_STARTED
EXPORT_COMPLETED
EXPORT_FAILED
IMPORT_REJECTED
BACKUP_POLICY_CHECK_FAILED
```

---

# 103. Permission Revocation During Runtime (Runtime Sırasında İzin İptali)

NAVGUARD will assume that a user can revoke permissions through Android settings while the application exists. *(NAVGUARD kullanıcının uygulama mevcutken Android ayarları üzerinden izinleri iptal edebileceğini varsayacaktır.)*

---

# 104. Location Revocation During Session (Oturum Sırasında Konum İzni İptali)

If precise location permission becomes unavailable during GNSS Mode, the GNSS subsystem will enter an appropriate unavailable or degraded state. *(Kesin konum izni GNSS Modu sırasında kullanılamaz hale gelirse GNSS alt sistemi uygun unavailable veya degraded durumuna geçecektir.)*

---

# 105. Evaluation Ground Truth Loss (Evaluation Ground Truth Kaybı)

If location permission loss prevents Evaluation Mode ground-truth logging, the system will record the reference gap and evaluate session validity according to the benchmark protocol. *(Location permission kaybı Evaluation Mode ground-truth logging'i önlerse sistem referans boşluğunu kaydedecek ve oturum geçerliliğini benchmark protokolüne göre değerlendirecektir.)*

---

# 106. Camera Revocation During ARCore Session (ARCore Oturumu Sırasında Kamera İzni İptali)

If camera access becomes unavailable, ARCore will degrade or stop and the navigation system will fall back to permitted non-camera sources when possible. *(Kamera erişimi kullanılamaz hale gelirse ARCore degrade olacak veya duracak ve navigasyon sistemi mümkün olduğunda izin verilen kamera dışı kaynaklara fallback yapacaktır.)*

---

# 107. Android Camera Privacy Controls (Android Kamera Gizlilik Kontrolleri)

Android 12 and later provide device-wide camera access controls that can disable camera access independently of application permission state. *(Android 12 ve sonrası uygulama permission durumundan bağımsız olarak kamera erişimini devre dışı bırakabilen cihaz geneli kamera erişim kontrolleri sağlar.)*

---

# 108. Permission State Must Be Rechecked (Permission Durumu Yeniden Kontrol Edilmelidir)

NAVGUARD will not assume that a permission granted yesterday remains available forever. *(NAVGUARD dün verilen permission'ın sonsuza kadar kullanılabilir kalacağını varsaymayacaktır.)*

Readiness checks will inspect current permission state. *(Hazırlık kontrolleri mevcut permission durumunu inceleyecektir.)*

---

# 109. Permanent Denial / Settings Path (Kalıcı Red / Settings Yolu)

If Android no longer presents the runtime dialog after repeated denial, the UI may offer a direct explanation and route to system application settings. *(Android tekrarlanan redden sonra runtime dialog'u artık göstermiyorsa UI açık açıklama ve sistem uygulama ayarlarına yönlendirme sunabilir.)*

---

# 110. No Coercive Permission UX (Zorlayıcı Permission UX Olmaması)

NAVGUARD will explain why a permission is needed but will not falsely claim that unrelated features require it. *(NAVGUARD permission'ın neden gerekli olduğunu açıklayacak ancak ilgisiz özelliklerin onu gerektirdiğini yanlış şekilde iddia etmeyecektir.)*

---

# 111. Feature-Level Permission Graceful Degradation (Özellik Seviyesi Permission Graceful Degradation)

When technically possible, denial will disable only the affected feature rather than the complete application. *(Teknik olarak mümkün olduğunda red tüm uygulama yerine yalnızca etkilenen özelliği devre dışı bırakacaktır.)*

---

# 112. Permission Readiness Model (Permission Hazırlık Modeli)

```text
GRANTED
DENIED
APPROXIMATE_ONLY
NOT_REQUESTED
PERMANENTLY_DENIED
NOT_REQUIRED
```

---

# 113. Permission Requirement Model (Permission Gereksinim Modeli)

```text
MANDATORY_FOR_SELECTED_PROFILE
OPTIONAL
NOT_REQUIRED
```

---

# 114. Permission Decision Depends on Configuration (Permission Kararı Yapılandırmaya Bağlıdır)

A permission may be mandatory for Configuration D and unnecessary for Configuration A. *(Bir permission Configuration D için zorunlu ve Configuration A için gereksiz olabilir.)*

---

# 115. Permission Manifest Minimization (Manifest Permission Minimizasyonu)

The final Android manifest will be audited so unused dangerous permissions are removed before Benchmark and release builds. *(Nihai Android manifest Benchmark ve release build'lerinden önce kullanılmayan dangerous permission'ların kaldırılması için audit edilecektir.)*

---

# 116. Manifest Audit Test (Manifest Audit Testi)

A permission audit will compare declared permissions against the frozen NAVGUARD capability matrix. *(Permission audit declare edilmiş permission'ları sabitlenmiş NAVGUARD capability matrisiyle karşılaştıracaktır.)*

---

# 117. Unexpected Permission Is a Failure (Beklenmeyen Permission Hatadır)

An unexplained dangerous permission in the release manifest will fail the permission audit. *(Release manifest içerisindeki açıklanamayan dangerous permission permission audit'i başarısız kılacaktır.)*

---

# 118. Local-First Privacy Model (Local-First Gizlilik Modeli)

Sensor, GNSS, ARCore pose, AI, PDR, EKF, recovery, and benchmark evidence will remain on the device unless the user explicitly exports it. *(Sensör, GNSS, ARCore pose, yapay zekâ, PDR, EKF, recovery ve benchmark kanıtı kullanıcı açıkça export etmedikçe cihazda kalacaktır.)*

---

# 119. Automatic Backup Must Be Controlled (Otomatik Backup Kontrol Edilmelidir)

Local-only intent can be undermined if Android automatically includes research data in cloud backup. *(Android araştırma verisini otomatik cloud backup'a dahil ederse local-only amacı zedelenebilir.)*

---

# 120. Android Auto Backup Default (Android Auto Backup Varsayılanı)

Android applications targeting Android 6.0 or later can participate in Auto Backup, and the `android:allowBackup` application attribute defaults to `true` unless explicitly configured. *(Android 6.0 veya sonrasını hedefleyen uygulamalar Auto Backup'a katılabilir ve `android:allowBackup` application attribute açıkça yapılandırılmadıkça varsayılan olarak `true` değerindedir.)*

---

# 121. NAVGUARD Backup Policy (NAVGUARD Backup Politikası)

Formal research-session data will be excluded from automatic cloud backup. *(Resmî araştırma oturum verisi otomatik cloud backup'tan hariç tutulacaktır.)*

---

# 122. `allowBackup` Direction (`allowBackup` Yönü)

The research prototype will prefer explicitly disabling general application backup with `android:allowBackup="false"` unless implementation testing identifies a compelling reason to preserve selected non-sensitive preferences. *(Araştırma prototipi implementation testleri seçilen hassas olmayan preference'ları korumak için güçlü neden belirlemedikçe genel uygulama backup'ını `android:allowBackup="false"` ile açıkça devre dışı bırakmayı tercih edecektir.)*

---

# 123. Android 12 Backup Nuance (Android 12 Backup Ayrıntısı)

Android documentation notes that on some devices running modern Android, `allowBackup="false"` disables cloud backup but may not prevent every device-to-device transfer. *(Android dokümantasyonu bazı modern Android cihazlarında `allowBackup="false"` değerinin cloud backup'ı devre dışı bıraktığını ancak her device-to-device transfer'ı önlemeyebileceğini belirtmektedir.)*

---

# 124. Explicit Data Extraction Rules (Açık Data Extraction Kuralları)

Where supported, NAVGUARD will also use Android backup/data-extraction rules to explicitly exclude sensitive session directories and databases from transfer mechanisms. *(Desteklendiğinde NAVGUARD hassas oturum klasörlerini ve veritabanlarını transfer mekanizmalarından açık şekilde hariç tutmak için Android backup/data-extraction kurallarını da kullanacaktır.)*

Android 12 and later support `dataExtractionRules` with separate include and exclude controls for cloud backup and device transfer. *(Android 12 ve sonrası cloud backup ile device transfer için ayrı include ve exclude kontrollerine sahip `dataExtractionRules` destekler.)*

---

# 125. Backup Policy Verification (Backup Politikası Doğrulaması)

The final Android build will be inspected to verify that session evidence is excluded according to the intended backup policy. *(Nihai Android build oturum kanıtının amaçlanan backup politikasına göre hariç tutulduğunu doğrulamak için incelenecektir.)*

---

# 126. No Sensitive Session Data in Cache-Only Assumptions (Hassas Oturum Verisinde Yalnızca Cache Varsayımı Olmaması)

Critical experiment evidence will not rely on cache directories because the operating system may remove cache data. *(Kritik deney kanıtı cache klasörlerine dayanmayacaktır çünkü işletim sistemi cache verisini kaldırabilir.)*

---

# 127. Uninstall Behavior (Uninstall Davranışı)

Android removes app-specific files when the application is uninstalled. *(Android uygulama uninstall edildiğinde uygulamaya özgü dosyaları kaldırır.)*

---

# 128. Export Before Uninstall (Uninstall Öncesi Export)

The application documentation will warn that important research sessions should be explicitly exported before uninstalling NAVGUARD. *(Uygulama dokümantasyonu önemli araştırma oturumlarının NAVGUARD uninstall edilmeden önce açık şekilde export edilmesi gerektiği konusunda uyaracaktır.)*

---

# 129. Exported Package Encryption (Export Edilmiş Paket Şifrelemesi)

The initial ZIP export format will not be described as encrypted unless actual encryption is implemented. *(İlk ZIP export formatı gerçek encryption uygulanmadıkça şifrelenmiş olarak tanımlanmayacaktır.)*

---

# 130. Optional Encrypted Export (İsteğe Bağlı Şifreli Export)

Password-protected or cryptographically encrypted export may be considered as a future enhancement if external sharing requirements justify it. *(Harici paylaşım gereksinimleri gerekçelendirirse password-protected veya kriptografik olarak şifrelenmiş export gelecekteki iyileştirme olarak değerlendirilebilir.)*

---

# 131. Export Integrity Is Separate from Confidentiality (Export Bütünlüğü Gizlilikten Ayrıdır)

SHA-256 checksums can detect modification but do not hide file contents. *(SHA-256 checksum'lar değişikliği tespit edebilir ancak dosya içeriğini gizlemez.)*

---

# 132. Model Integrity (Model Bütünlüğü)

Navigation-enabled AI models are integrity-critical application artifacts. *(Navigasyon etkin yapay zekâ modelleri bütünlük açısından kritik uygulama artifact'larıdır.)*

---

# 133. Model Hash Verification (Model Hash Doğrulaması)

Formal Benchmark Mode will verify the configured model artifact hash before treating that model as the declared benchmark model. *(Resmî Benchmark Mode yapılandırılmış model artifact hash'ini modeli declare edilmiş benchmark modeli olarak ele almadan önce doğrulayacaktır.)*

---

# 134. Hash Mismatch Behavior (Hash Uyuşmazlığı Davranışı)

A model hash mismatch will block navigation-enabled use of that artifact in Benchmark Mode. *(Model hash uyuşmazlığı Benchmark Modunda ilgili artifact'ın navigasyon etkin kullanımını engelleyecektir.)*

---

# 135. Model Files Are Not Arbitrary User Content (Model Dosyaları Keyfi Kullanıcı İçeriği Değildir)

The minimum application will not load arbitrary `.tflite` files selected from shared storage into the navigation runtime. *(Minimum uygulama shared storage'dan seçilen keyfi `.tflite` dosyalarını navigasyon runtime'ına yüklemeyecektir.)*

---

# 136. Model Promotion Is Controlled (Model Promotion Kontrollüdür)

Only models registered through the validated deployment process defined in Page 27 may become navigation-enabled. *(Yalnızca Page 27'de tanımlanan doğrulanmış deployment süreci üzerinden register edilen modeller navigasyon etkin olabilir.)*

---

# 137. Application Artifact Integrity (Uygulama Artifact Bütünlüğü)

Release and Benchmark builds will use known application builds rather than ad-hoc modified packages. *(Release ve Benchmark build'leri ad-hoc değiştirilmiş paketler yerine bilinen uygulama build'lerini kullanacaktır.)*

---

# 138. Build Identity Logging (Build Kimliği Logging)

Benchmark sessions will record application version and build identity. *(Benchmark oturumları uygulama sürümünü ve build kimliğini kaydedecektir.)*

---

# 139. Git Commit Logging (Git Commit Logging)

Where available, Benchmark builds may record the source-control commit used to produce the application. *(Kullanılabilir olduğunda Benchmark build'leri uygulamayı üretmek için kullanılan source-control commit'ini kaydedebilir.)*

---

# 140. Debug Build Restriction (Debug Build Kısıtlaması)

Final performance and formal benchmark conclusions will not depend solely on debug builds. *(Nihai performans ve resmî benchmark sonuçları yalnızca debug build'lere dayanmayacaktır.)*

---

# 141. Application Signing (Uygulama İmzalama)

Any distributable release build will use the normal Android application-signing process. *(Dağıtılabilir her release build normal Android uygulama imzalama sürecini kullanacaktır.)*

---

# 142. Signing Keys Are Outside Session Data (İmzalama Anahtarları Oturum Verisinin Dışındadır)

Application signing credentials will never be stored inside NAVGUARD session manifests, exports, or source-controlled experiment datasets. *(Uygulama signing credential'ları hiçbir zaman NAVGUARD oturum manifestleri, export'ları veya source-controlled deney veri setleri içerisinde saklanmayacaktır.)*

---

# 143. No API Secret Requirement (API Secret Gereksinimi Olmaması)

The core navigation architecture does not require a cloud AI API key or backend secret. *(Temel navigasyon mimarisi cloud AI API key veya backend secret gerektirmez.)*

---

# 144. Future Secrets Must Not Be Hard-Coded (Gelecekteki Secret'lar Hard-Code Edilmemelidir)

If any future network service requires credentials, secrets must not be committed directly into public source code or session exports. *(Gelecekteki ağ servisi credential gerektirirse secret'lar doğrudan public source code veya oturum export'larına commit edilmemelidir.)*

---

# 145. Logging Security (Logging Güvenliği)

System logs are not the same as protected session storage. *(Sistem logları korunan oturum depolamasıyla aynı değildir.)*

---

# 146. Sensitive Data Must Not Be Written to General System Logs (Hassas Veri Genel Sistem Loglarına Yazılmamalıdır)

Precise latitude, longitude, complete movement trajectories, raw ground-truth streams, and other sensitive data will not be emitted unnecessarily through ordinary Android `Log` output. *(Kesin enlem, boylam, tam hareket trajectory'leri, ham ground-truth stream'leri ve diğer hassas veriler normal Android `Log` çıktısı üzerinden gereksiz şekilde yayınlanmayacaktır.)*

Android core-quality guidance explicitly discourages logging sensitive data to system or application logs. *(Android core-quality rehberi hassas verinin sistem veya uygulama loglarına yazılmamasını açık şekilde önermektedir.)*

---

# 147. Structured Session Logs Are Different (Yapılandırılmış Oturum Logları Farklıdır)

Precise navigation evidence may be stored inside the controlled session artifact system because it is required for the research experiment. *(Kesin navigasyon kanıtı araştırma deneyi için gerekli olduğundan kontrollü oturum artifact sistemi içerisinde saklanabilir.)*

---

# 148. Debug Log Redaction (Debug Log Redaction)

Debug logging will prefer session IDs, state names, counters, and error categories rather than full sensitive payloads. *(Debug logging tam hassas payload'lar yerine session ID'lerini, state isimlerini, counter'ları ve hata kategorilerini tercih edecektir.)*

---

# 149. Exception Messages (Exception Mesajları)

Exception handling will avoid embedding entire sensor or GNSS records into user-visible error messages. *(Exception yönetimi tam sensör veya GNSS kayıtlarını kullanıcıya gösterilen hata mesajlarına yerleştirmekten kaçınacaktır.)*

---

# 150. Diagnostic UI Access (Diagnostic UI Erişimi)

Diagnostics may show precise technical data when necessary for the local experiment. *(Diagnostics yerel deney için gerekli olduğunda kesin teknik veri gösterebilir.)*

---

# 151. Evaluation Mode Diagnostic Restrictions (Evaluation Mode Diagnostic Kısıtlamaları)

Ground-truth-sensitive diagnostic panels may be hidden or locked while a blinded denied interval is active. *(Ground-truth hassas diagnostic panelleri blinded kesintili aralık aktifken gizlenebilir veya kilitlenebilir.)*

---

# 152. Screenshot Risk (Ekran Görüntüsü Riski)

The application cannot generally guarantee that a user will never capture sensitive information displayed on screen. *(Uygulama genellikle kullanıcının ekranda gösterilen hassas bilginin hiçbir zaman ekran görüntüsünü almayacağını garanti edemez.)*

---

# 153. Secure-Window Candidate (Secure Window Adayı)

Android secure-window behavior may be considered for specific highly sensitive diagnostic or ground-truth screens if future deployment requirements justify it. *(Gelecekteki deployment gereksinimleri gerekçelendirirse Android secure-window davranışı belirli yüksek hassas diagnostic veya ground-truth ekranları için değerlendirilebilir.)*

It is not required for the minimum research prototype. *(Minimum araştırma prototipi için gerekli değildir.)*

---

# 154. Database Security (Veritabanı Güvenliği)

The SQLite database will remain inside application-controlled storage. *(SQLite veritabanı uygulama kontrollü depolama içerisinde kalacaktır.)*

---

# 155. Parameterized Database Operations (Parametreli Veritabanı İşlemleri)

User-entered labels and notes will be handled through parameterized database APIs rather than dynamically concatenated SQL strings. *(Kullanıcı tarafından girilen etiketler ve notlar dynamically concatenate edilmiş SQL string'leri yerine parametreli veritabanı API'ları üzerinden yönetilecektir.)*

---

# 156. Session Names Are Untrusted Text (Oturum İsimleri Güvenilmeyen Metindir)

User-visible session names will not be used directly as unrestricted filesystem paths. *(Kullanıcıya gösterilen oturum isimleri doğrudan sınırsız filesystem path'leri olarak kullanılmayacaktır.)*

---

# 157. Internal ID Controls Directory Naming (Dahili ID Klasör İsimlendirmeyi Kontrol Eder)

Session directories will be based primarily on application-generated identifiers. *(Oturum klasörleri temel olarak uygulama tarafından oluşturulan tanımlayıcılara dayanacaktır.)*

---

# 158. Filename Sanitization (Dosya Adı Sanitization)

If user-entered names appear in export filenames, invalid or dangerous path characters will be sanitized. *(Kullanıcı tarafından girilen isimler export dosya isimlerinde yer alırsa geçersiz veya tehlikeli path karakterleri sanitize edilecektir.)*

---

# 159. Path Traversal Protection (Path Traversal Koruması)

User-controlled values must never permit writing outside the intended session or export directory through constructs such as `../`. *(Kullanıcı kontrollü değerler `../` gibi yapılar üzerinden amaçlanan oturum veya export klasörünün dışına yazmaya hiçbir zaman izin vermemelidir.)*

---

# 160. Replay Import Security (Replay Import Güvenliği)

If session import is added later, imported archives will be treated as untrusted external data. *(Oturum import özelliği daha sonra eklenirse import edilen arşivler güvenilmeyen harici veri olarak ele alınacaktır.)*

---

# 161. Archive Extraction Protection (Arşiv Açma Koruması)

Archive extraction must reject entries that escape the intended import directory. *(Archive extraction amaçlanan import klasörünün dışına çıkan entry'leri reddetmelidir.)*

---

# 162. Imported Manifest Validation (Import Edilmiş Manifest Doğrulaması)

An imported session will not be trusted merely because it contains a `manifest.json` file. *(Import edilmiş oturuma yalnızca `manifest.json` dosyası içerdiği için güvenilmeyecektir.)*

Schema, required fields, paths, and optional checksums will be validated. *(Schema, gerekli alanlar, path'ler ve isteğe bağlı checksum'lar doğrulanacaktır.)*

---

# 163. Imported Model Files (Import Edilmiş Model Dosyaları)

An imported session archive must not automatically replace the active navigation AI model. *(Import edilmiş oturum arşivi aktif navigasyon yapay zekâ modelini otomatik olarak değiştirmemelidir.)*

---

# 164. Replay Is Sandboxed from Live Configuration (Replay Canlı Yapılandırmadan İzole Edilir)

Replay configuration changes will not silently modify the application's currently validated live benchmark configuration. *(Replay yapılandırma değişiklikleri uygulamanın mevcut doğrulanmış canlı benchmark yapılandırmasını sessizce değiştirmeyecektir.)*

---

# 165. CSV Export Safety (CSV Export Güvenliği)

CSV writers will properly escape text fields. *(CSV writer'ları metin alanlarını uygun şekilde escape edecektir.)*

---

# 166. Spreadsheet Formula Injection Candidate (Spreadsheet Formula Injection Adayı)

If user-entered free-form text is ever exported into CSV files intended for spreadsheet viewing, the exporter will prevent that text from being interpreted unintentionally as a spreadsheet formula. *(Kullanıcı tarafından girilen free-form metin spreadsheet görüntüleme için tasarlanmış CSV dosyalarına export edilirse exporter bu metnin yanlışlıkla spreadsheet formula olarak yorumlanmasını önleyecektir.)*

---

# 167. Raw Numerical Sensor CSV Is Low Risk for Formula Injection (Ham Sayısal Sensör CSV'sinde Formula Injection Riski Düşüktür)

Raw sensor channels are numerical and do not normally contain user-controlled formula-like text. *(Ham sensör kanalları sayısaldır ve normalde kullanıcı kontrollü formula benzeri metin içermez.)*

---

# 168. Artifact Integrity (Artifact Bütünlüğü)

Formal session artifacts may receive SHA-256 hashes after finalization. *(Resmî oturum artifact'ları finalization sonrasında SHA-256 hash alabilir.)*

---

# 169. Hash Purpose (Hash Amacı)

Artifact hashing supports later detection of accidental or intentional modification. *(Artifact hash'leme daha sonra yanlışlıkla veya kasıtlı değişiklik tespitini destekler.)*

---

# 170. Hash Generation Timing (Hash Oluşturma Zamanı)

Hashes will be generated only after the relevant artifact has been completely written and closed. *(Hash'ler yalnızca ilgili artifact tamamen yazılıp kapatıldıktan sonra oluşturulacaktır.)*

---

# 171. Hash Does Not Protect an Active File (Hash Aktif Dosyayı Korumaz)

A checksum generated before a file is finished would not represent the final artifact. *(Dosya tamamlanmadan oluşturulan checksum nihai artifact'ı temsil etmez.)*

---

# 172. Manifest Hashing (Manifest Hash'leme)

If the final manifest contains hashes for other artifacts, its own integrity strategy must avoid circular hash dependencies. *(Nihai manifest diğer artifact'lar için hash içeriyorsa kendi bütünlük stratejisi circular hash bağımlılıklarından kaçınmalıdır.)*

---

# 173. Checksums File Candidate (Checksums Dosyası Adayı)

A separate `checksums.json` artifact is the preferred simple approach for export integrity. *(Ayrı `checksums.json` artifact'ı export bütünlüğü için tercih edilen basit yaklaşımdır.)*

---

# 174. Evidence Deletion Policy (Kanıt Silme Politikası)

Formal research evidence will not be silently deleted automatically. *(Resmî araştırma kanıtı sessizce otomatik olarak silinmeyecektir.)*

---

# 175. Explicit User Deletion (Açık Kullanıcı Silme İşlemi)

Session deletion will require explicit user action as defined in Page 31. *(Oturum silme Page 31'de tanımlandığı şekilde açık kullanıcı işlemi gerektirecektir.)*

---

# 176. Deletion Confirmation (Silme Onayı)

Sensitive or benchmark session deletion will use confirmation appropriate to its importance. *(Hassas veya benchmark oturum silme önemine uygun confirmation kullanacaktır.)*

---

# 177. Delete Means Delete Local Managed Copy (Silme Yerel Yönetilen Kopyayı Silme Anlamına Gelir)

Deleting a NAVGUARD session can remove the application's managed copy but cannot automatically recall copies that the user previously exported elsewhere. *(NAVGUARD oturumunu silmek uygulamanın yönettiği kopyayı kaldırabilir ancak kullanıcının daha önce başka yere export ettiği kopyaları otomatik olarak geri çağıramaz.)*

---

# 178. Retention Policy (Saklama Politikası)

The minimum prototype will use user-controlled retention rather than automatic age-based deletion. *(Minimum prototip otomatik yaş tabanlı silme yerine kullanıcı kontrollü saklama kullanacaktır.)*

---

# 179. Storage Pressure Warning (Depolama Baskısı Uyarısı)

If available space becomes insufficient, NAVGUARD will warn the user rather than silently deleting older research sessions. *(Kullanılabilir alan yetersiz hale gelirse NAVGUARD eski araştırma oturumlarını sessizce silmek yerine kullanıcıyı uyaracaktır.)*

---

# 180. Permission and Privacy Readiness (Permission ve Gizlilik Hazırlığı)

Before a formal session starts, the Readiness Check will verify required permissions and privacy-relevant runtime state. *(Resmî oturum başlamadan önce Hazırlık Kontrolü gerekli permission'ları ve gizlilikla ilişkili runtime durumunu doğrulayacaktır.)*

---

# 181. Candidate Security Readiness Checks (Aday Güvenlik Hazırlık Kontrolleri)

```text
Precise location permission
Camera permission when ARCore is required
Activity recognition when optional step comparison is enabled
Private session storage writable
Backup policy configuration present
Model integrity valid
Ground Truth Firewall initialized
Export path not active as live storage
```

---

# 182. Benchmark Security Gate (Benchmark Güvenlik Kapısı)

A critical security or evidence-integrity failure will block a formal Benchmark session from starting. *(Kritik güvenlik veya kanıt bütünlüğü hatası resmî Benchmark oturumunun başlamasını engelleyecektir.)*

---

# 183. Development Mode Is More Permissive but Not Silent (Development Mode Daha Esnektir ancak Sessiz Değildir)

Development Mode may allow experimentation with degraded security-readiness conditions when safe, but all deviations must remain visible and logged. *(Development Mode güvenli olduğunda bozulmuş security-readiness koşullarıyla deneye izin verebilir ancak tüm sapmalar görünür ve loglanmış kalmalıdır.)*

---

# 184. Benchmark Ground Truth Firewall Self-Test (Benchmark Ground Truth Firewall Self-Test'i)

Benchmark readiness will include or reference a verified Ground Truth Firewall isolation test. *(Benchmark readiness doğrulanmış Ground Truth Firewall izolasyon testini içerecek veya ona referans verecektir.)*

---

# 185. Injected GNSS Isolation Test (Enjekte Edilmiş GNSS İzolasyon Testi)

A test will inject or simulate a GNSS reference event while estimator access is blocked. *(Test tahmin motoru erişimi blocked iken GNSS referans olayını enjekte edecek veya simüle edecektir.)*

The ground-truth logger must receive it while the estimator receives no position update. *(Ground-truth logger bunu alırken tahmin motoru hiçbir konum update'i almamalıdır.)*

---

# 186. Permission Test — Precise Location (Permission Testi — Kesin Konum)

The application must distinguish Precise from Approximate location state on Android versions that expose that distinction. *(Uygulama bu ayrımı sunan Android sürümlerinde Precise ile Approximate location durumunu ayırt etmelidir.)*

---

# 187. Permission Test — Location Denial (Permission Testi — Konum Reddi)

Denied location permission must block formal GNSS readiness without crashing the app. *(Reddedilmiş location permission uygulamayı crash etmeden resmî GNSS readiness'ı engellemelidir.)*

---

# 188. Permission Test — Camera Denial (Permission Testi — Kamera Reddi)

Camera denial must disable ARCore-dependent readiness while leaving PDR-capable configurations available. *(Kamera reddi ARCore bağımlı readiness'ı devre dışı bırakırken PDR-capable yapılandırmaları kullanılabilir bırakmalıdır.)*

---

# 189. Permission Test — Activity Recognition Denial (Permission Testi — Activity Recognition Reddi)

Activity Recognition denial must disable only the optional built-in Android step-sensor comparison. *(Activity Recognition reddi yalnızca isteğe bağlı built-in Android adım sensörü karşılaştırmasını devre dışı bırakmalıdır.)*

---

# 190. Permission Test — Runtime Revocation (Permission Testi — Runtime İptali)

Revoking a required permission during a session must create a deterministic subsystem and session response. *(Oturum sırasında gerekli permission'ı iptal etmek deterministik alt sistem ve oturum tepkisi oluşturmalıdır.)*

---

# 191. Storage Test — App Private Access (Depolama Testi — App Private Erişim)

Active session files must be written into the configured application-controlled storage root. *(Aktif oturum dosyaları yapılandırılmış uygulama kontrollü storage root'a yazılmalıdır.)*

---

# 192. Storage Test — No Broad Permission (Depolama Testi — Geniş İzin Olmaması)

Normal session creation and recording must succeed without all-files storage permission. *(Normal oturum oluşturma ve kayıt all-files storage permission olmadan başarılı olmalıdır.)*

---

# 193. Export Test — SAF (Export Testi — SAF)

The user must be able to create an export through the selected Android document workflow without granting broad filesystem access. *(Kullanıcı geniş filesystem erişimi vermeden seçilen Android document workflow üzerinden export oluşturabilmelidir.)*

---

# 194. Export Test — Location Warning (Export Testi — Konum Uyarısı)

Exporting a session containing precise location data must display the defined privacy warning. *(Kesin konum verisi içeren oturumu export etmek tanımlanan gizlilik uyarısını göstermelidir.)*

---

# 195. Backup Test (Backup Testi)

The final Android build must be inspected or tested to ensure that sensitive session evidence follows the frozen backup-exclusion policy. *(Nihai Android build hassas oturum kanıtının sabitlenmiş backup exclusion politikasını izlediğini doğrulamak için incelenmeli veya test edilmelidir.)*

---

# 196. Logging Test — Sensitive Coordinates (Logging Testi — Hassas Koordinatlar)

Ordinary Android debug/system logs must not contain continuous precise GNSS trajectories during a formal session. *(Normal Android debug/system logları resmî oturum sırasında sürekli kesin GNSS trajectory'leri içermemelidir.)*

---

# 197. Model Integrity Test (Model Bütünlük Testi)

A modified model artifact must fail strict Benchmark Mode hash validation. *(Değiştirilmiş model artifact'ı strict Benchmark Mode hash validation'ı geçememelidir.)*

---

# 198. Artifact Integrity Test (Artifact Bütünlük Testi)

Changing a finalized hashed artifact must cause checksum verification to fail. *(Finalize edilmiş hash'lenmiş artifact'ı değiştirmek checksum verification'ın başarısız olmasına neden olmalıdır.)*

---

# 199. Ground Truth Firewall Test (Ground Truth Firewall Testi)

Protected Evaluation GNSS must not affect position, velocity, heading, AI features, anchor state, or fused covariance while estimator access is blocked. *(Korunan Evaluation GNSS tahmin motoru erişimi blocked iken konumu, velocity'yi, yönü, AI feature'larını, anchor durumunu veya füzyon kovaryansını etkilememelidir.)*

---

# 200. Ground Truth UI Test (Ground Truth UI Testi)

Protected ground truth must remain hidden during the configured blinded interval. *(Korunan ground truth yapılandırılmış blinded aralık sırasında gizli kalmalıdır.)*

---

# 201. Security Test IDs (Güvenlik Test ID'leri)

```text
SEC-PERM-001   Precise location request
SEC-PERM-002   Approximate-only handling
SEC-PERM-003   location denial
SEC-PERM-004   camera denial
SEC-PERM-005   activity recognition optionality
SEC-PERM-006   runtime revocation
SEC-PERM-007   manifest permission audit

SEC-STO-001    private session storage
SEC-STO-002    no all-files permission
SEC-STO-003    app storage availability
SEC-STO-004    path traversal prevention

SEC-EXP-001    SAF export
SEC-EXP-002    export privacy warning
SEC-EXP-003    filename sanitization
SEC-EXP-004    checksum verification

SEC-BKP-001    backup disabled / exclusion verified
SEC-BKP-002    session evidence excluded
SEC-BKP-003    restore behavior reviewed

SEC-GTF-001    estimator GNSS blocked
SEC-GTF-002    ground truth logger continues
SEC-GTF-003    AI feature isolation
SEC-GTF-004    EKF isolation
SEC-GTF-005    anchor isolation
SEC-GTF-006    replay isolation
SEC-GTF-007    unauthorized update counter zero

SEC-AI-001     model hash validation
SEC-AI-002     model metadata validation
SEC-AI-003     arbitrary model loading blocked

SEC-LOG-001    no precise GNSS in system log
SEC-LOG-002    debug payload redaction
SEC-LOG-003    security event logging

SEC-IMP-001    imported manifest validation
SEC-IMP-002    archive traversal rejection
SEC-IMP-003    imported model isolation

SEC-UI-001     permission rationale
SEC-UI-002     ground truth hidden
SEC-UI-003     permission failure clarity
```

---

# 202. Permission Acceptance Criteria (Permission Kabul Kriterleri)

The application must request only permissions required by the active or selected functionality. *(Uygulama yalnızca aktif veya seçilen işlevsellik tarafından gerekli permission'ları istemelidir.)*

---

# 203. Precise Location Acceptance Criteria (Kesin Konum Kabul Kriterleri)

Formal GNSS sessions must not begin with Approximate-only location authorization. *(Resmî GNSS oturumları yalnızca Approximate location authorization ile başlamamalıdır.)*

---

# 204. Camera Acceptance Criteria (Kamera Kabul Kriterleri)

PDR-only operation must remain possible without camera permission. *(PDR-only çalışma kamera izni olmadan mümkün kalmalıdır.)*

---

# 205. Activity Recognition Acceptance Criteria (Activity Recognition Kabul Kriterleri)

`ACTIVITY_RECOGNITION` must not become a dependency of NAVGUARD's independent step detector. *(`ACTIVITY_RECOGNITION` NAVGUARD'ın bağımsız adım algılayıcısının bağımlılığı haline gelmemelidir.)*

---

# 206. High Sampling Acceptance Criteria (Yüksek Sampling Kabul Kriterleri)

`HIGH_SAMPLING_RATE_SENSORS` must remain absent unless a measured requirement above the standard Android rate limit is approved. *(`HIGH_SAMPLING_RATE_SENSORS` standart Android hız sınırının üzerinde ölçülmüş gereksinim onaylanmadıkça bulunmamalıdır.)*

---

# 207. Background Location Acceptance Criteria (Arka Plan Konum Kabul Kriterleri)

`ACCESS_BACKGROUND_LOCATION` must remain absent from the minimum foreground-first architecture. *(`ACCESS_BACKGROUND_LOCATION` minimum foreground-first mimaride bulunmamalıdır.)*

---

# 208. Storage Acceptance Criteria (Depolama Kabul Kriterleri)

Active sensitive evidence must remain in application-controlled storage until explicit export. *(Aktif hassas kanıt açık export'a kadar uygulama kontrollü depolamada kalmalıdır.)*

---

# 209. Export Acceptance Criteria (Export Kabul Kriterleri)

Export must require explicit user action and a user-selected destination. *(Export açık kullanıcı işlemi ve kullanıcı tarafından seçilmiş hedef gerektirmelidir.)*

---

# 210. Cloud Acceptance Criteria (Cloud Kabul Kriterleri)

No mandatory sensor, trajectory, or GNSS upload will occur during minimum NAVGUARD operation. *(Minimum NAVGUARD çalışması sırasında zorunlu sensör, trajectory veya GNSS upload gerçekleşmeyecektir.)*

---

# 211. Backup Acceptance Criteria (Backup Kabul Kriterleri)

Sensitive formal session evidence must be excluded from automatic cloud backup according to the implemented Android backup policy. *(Hassas resmî oturum kanıtı uygulanan Android backup politikasına göre otomatik cloud backup'tan hariç tutulmalıdır.)*

---

# 212. Ground Truth Acceptance Criteria (Ground Truth Kabul Kriterleri)

The unauthorized GNSS estimator update count must remain zero during every valid formal denied interval. *(Unauthorized GNSS estimator update count her geçerli resmî kesintili aralıkta sıfır kalmalıdır.)*

---

# 213. Model Integrity Acceptance Criteria (Model Bütünlük Kabul Kriterleri)

Benchmark Mode must identify and verify the exact navigation-enabled model artifact. *(Benchmark Mode kesin navigasyon etkin model artifact'ını tanımlamalı ve doğrulamalıdır.)*

---

# 214. Sensitive Logging Acceptance Criteria (Hassas Logging Kabul Kriterleri)

Precise research data must be stored through controlled session evidence channels rather than unrestricted general-purpose logs. *(Kesin araştırma verisi sınırsız genel amaçlı loglar yerine kontrollü oturum kanıt kanalları üzerinden saklanmalıdır.)*

---

# 215. Import Acceptance Criteria (Import Kabul Kriterleri)

If import is implemented, external session packages must be validated before any replay processing. *(Import uygulanırsa harici oturum paketleri herhangi bir replay işlemesinden önce doğrulanmalıdır.)*

---

# 216. Deletion Acceptance Criteria (Silme Kabul Kriterleri)

Sensitive sessions must not be deleted automatically without the explicit retention policy permitting it. *(Hassas oturumlar açık retention politikası izin vermeden otomatik olarak silinmemelidir.)*

---

# 217. Minimum Successful Security Architecture (Minimum Başarılı Güvenlik Mimarisi)

The minimum successful implementation will support precise-location permission, conditional camera permission, private app-controlled storage, explicit SAF export, Ground Truth Firewall isolation, no background-location dependency, no cloud upload dependency, controlled logging, and model identity validation. *(Minimum başarılı uygulama kesin konum iznini, koşullu kamera iznini, private uygulama kontrollü depolamayı, açık SAF export'u, Ground Truth Firewall izolasyonunu, background-location bağımlılığı olmamasını, cloud upload bağımlılığı olmamasını, kontrollü logging'i ve model kimliği doğrulamasını destekleyecektir.)*

---

# 218. Target Successful Security Architecture (Hedef Başarılı Güvenlik Mimarisi)

The target implementation will additionally provide backup exclusion verification, session artifact hashing, strict Benchmark manifest auditing, secure import validation, permission-revocation handling, structured security events, and comprehensive automated Ground Truth Firewall tests. *(Hedef uygulama ek olarak backup exclusion doğrulaması, oturum artifact hash'leme, strict Benchmark manifest auditing, güvenli import doğrulaması, permission-revocation yönetimi, yapılandırılmış security event'leri ve kapsamlı otomatik Ground Truth Firewall testleri sağlayacaktır.)*

---

# 219. Optional Security Enhancements (İsteğe Bağlı Güvenlik İyileştirmeleri)

Optional enhancements may include encrypted session exports. *(İsteğe bağlı iyileştirmeler şifrelenmiş oturum export'larını içerebilir.)*

Optional enhancements may include secure-window protection for selected diagnostic screens. *(İsteğe bağlı iyileştirmeler seçilen diagnostic ekranlar için secure-window korumasını içerebilir.)*

Optional enhancements may include stronger archive signing or authenticated evidence packages. *(İsteğe bağlı iyileştirmeler daha güçlü archive signing veya authenticated kanıt paketlerini içerebilir.)*

---

# 220. Security Non-Goals (Güvenlik Olmayan Hedefler)

NAVGUARD will not implement enterprise mobile-device management. *(NAVGUARD enterprise mobile-device management uygulamayacaktır.)*

NAVGUARD will not attempt to protect exported files after the user intentionally transfers them to an uncontrolled third-party system. *(NAVGUARD kullanıcı dosyaları bilinçli olarak kontrol edilmeyen üçüncü taraf sisteme aktardıktan sonra export edilmiş dosyaları korumaya çalışmayacaktır.)*

NAVGUARD will not claim resistance against a fully compromised or rooted operating system. *(NAVGUARD tamamen compromise edilmiş veya rooted işletim sistemine karşı dayanıklılık iddia etmeyecektir.)*

---

# 221. Additional Security Non-Goals (Ek Güvenlik Olmayan Hedefler)

NAVGUARD will not collect audio. *(NAVGUARD ses toplamayacaktır.)*

NAVGUARD will not access contacts, SMS, call logs, or telephone identifiers. *(NAVGUARD kişiler, SMS, call log veya telefon tanımlayıcılarına erişmeyecektir.)*

NAVGUARD will not require broad all-files storage access. *(NAVGUARD geniş all-files storage erişimi gerektirmeyecektir.)*

---

# 222. Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kararlar)

NAVGUARD will use a least-privilege permission strategy. *(NAVGUARD least-privilege permission stratejisi kullanacaktır.)*

Permissions will be requested in context according to the selected functionality. *(Permission'lar seçilen işlevselliğe göre bağlam içerisinde istenecektir.)*

---

# 223. Location Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Konum Kararları)

Formal GNSS experiments require precise location. *(Resmî GNSS deneyleri kesin konum gerektirir.)*

`ACCESS_FINE_LOCATION` and `ACCESS_COARSE_LOCATION` will be handled together according to current Android permission behavior. *(`ACCESS_FINE_LOCATION` ve `ACCESS_COARSE_LOCATION` güncel Android permission davranışına göre birlikte yönetilecektir.)*

Approximate-only authorization does not satisfy formal GNSS evaluation readiness. *(Yalnızca Approximate authorization resmî GNSS değerlendirme readiness'ını karşılamaz.)*

---

# 224. Background Location Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Arka Plan Konum Kararları)

`ACCESS_BACKGROUND_LOCATION` is not part of the minimum NAVGUARD permission set. *(`ACCESS_BACKGROUND_LOCATION` minimum NAVGUARD permission setinin parçası değildir.)*

The application remains foreground-first. *(Uygulama foreground-first olarak kalır.)*

---

# 225. Camera Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kamera Kararları)

`CAMERA` will be requested only when ARCore-enabled functionality requires it. *(`CAMERA` yalnızca ARCore etkin işlevsellik gerektirdiğinde istenecektir.)*

PDR-only navigation will not require camera permission. *(PDR-only navigasyon kamera izni gerektirmeyecektir.)*

Raw camera frames will not be persistently stored by default. *(Ham kamera kareleri varsayılan olarak kalıcı şekilde saklanmayacaktır.)*

---

# 226. ARCore Decisions Frozen by This Document (Bu Dokümanla Sabitlenen ARCore Kararları)

The preferred application-level packaging direction is AR Optional because the minimum architecture can operate without ARCore. *(Minimum mimari ARCore olmadan çalışabildiği için tercih edilen uygulama seviyesi paketleme yönü AR Optional'dır.)*

---

# 227. Activity Recognition Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Activity Recognition Kararları)

`ACTIVITY_RECOGNITION` is optional and will be used only if Android's built-in step sensors are enabled for comparison. *(`ACTIVITY_RECOGNITION` isteğe bağlıdır ve yalnızca Android'in built-in adım sensörleri karşılaştırma için etkinleştirilirse kullanılacaktır.)*

---

# 228. High Sampling Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Yüksek Sampling Kararları)

`HIGH_SAMPLING_RATE_SENSORS` is not required for the planned approximately 50 Hz NAVGUARD sensor profile. *(`HIGH_SAMPLING_RATE_SENSORS` planlanan yaklaşık 50 Hz NAVGUARD sensör profili için gerekli değildir.)*

It will not be declared without measured justification. *(Ölçülmüş gerekçe olmadan declare edilmeyecektir.)*

---

# 229. Audio Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Ses Kararları)

`RECORD_AUDIO` is outside the current permission scope. *(`RECORD_AUDIO` mevcut permission kapsamının dışındadır.)*

---

# 230. Storage Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Depolama Kararları)

Active sensitive sessions will use app-controlled storage. *(Aktif hassas oturumlar uygulama kontrollü storage kullanacaktır.)*

Broad all-files access is forbidden in the current architecture. *(Geniş all-files access mevcut mimaride yasaktır.)*

---

# 231. Export Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Export Kararları)

Export will be explicit and user initiated. *(Export açık ve kullanıcı tarafından başlatılan işlem olacaktır.)*

The preferred Android mechanism is the Storage Access Framework or equivalent system-mediated document flow. *(Tercih edilen Android mekanizması Storage Access Framework veya eşdeğer sistem kontrollü document flow'dur.)*

---

# 232. Cloud Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Cloud Kararları)

No automatic session upload is part of the minimum architecture. *(Minimum mimaride otomatik oturum upload bulunmaz.)*

Core navigation remains independent of Internet connectivity. *(Temel navigasyon internet bağlantısından bağımsız kalır.)*

---

# 233. Backup Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Backup Kararları)

Sensitive research sessions will be excluded from automatic cloud backup. *(Hassas araştırma oturumları otomatik cloud backup'tan hariç tutulacaktır.)*

The preferred prototype policy is to disable general backup and explicitly exclude sensitive evidence through supported backup/data-transfer rules. *(Tercih edilen prototip politikası genel backup'ı devre dışı bırakmak ve desteklenen backup/data-transfer kuralları üzerinden hassas kanıtı açık şekilde hariç tutmaktır.)*

---

# 234. Ground Truth Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Ground Truth Kararları)

Evaluation GNSS ground truth is protected reference data. *(Evaluation GNSS ground truth korunan referans verisidir.)*

Storage availability does not imply estimator authorization. *(Depolamada bulunması tahmin motoru authorization anlamına gelmez.)*

Unauthorized estimator access invalidates the corresponding formal denied interval. *(Yetkisiz tahmin motoru erişimi karşılık gelen resmî kesintili aralığı geçersiz kılar.)*

---

# 235. Model Security Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Model Güvenlik Kararları)

Navigation-enabled models will have controlled identities and hashes. *(Navigasyon etkin modeller kontrollü kimliklere ve hash'lere sahip olacaktır.)*

Arbitrary user-selected model files will not become live navigation models. *(Kullanıcı tarafından keyfi seçilen model dosyaları canlı navigasyon modeli haline gelmeyecektir.)*

---

# 236. Logging Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Logging Kararları)

Sensitive location streams will not be copied unnecessarily into general Android system logs. *(Hassas konum stream'leri gereksiz şekilde genel Android sistem loglarına kopyalanmayacaktır.)*

Controlled session artifacts remain the authoritative evidence store. *(Kontrollü oturum artifact'ları ana kanıt deposu olarak kalacaktır.)*

---

# 237. Identifier Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Tanımlayıcı Kararları)

NAVGUARD will not use IMEI or other non-resettable hardware identifiers for session identity. *(NAVGUARD oturum kimliği için IMEI veya diğer resetlenemeyen hardware identifier'ları kullanmayacaktır.)*

---

# 238. Permission Audit Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Permission Audit Kararları)

Benchmark and release manifests will be audited for unnecessary permissions. *(Benchmark ve release manifestleri gereksiz permission'lar için audit edilecektir.)*

Unexpected dangerous permissions will fail the audit. *(Beklenmeyen dangerous permission'lar audit'i başarısız kılacaktır.)*

---

# 239. Decisions Pending Android Bootstrap (Android Bootstrap Bekleyen Kararlar)

The exact manifest syntax and permission helper implementation will be frozen against the final Android target SDK and project toolchain. *(Kesin manifest syntax'ı ve permission helper uygulaması nihai Android target SDK ve proje toolchain'ine göre sabitlenecektir.)*

---

# 240. Decisions Pending Storage Implementation (Depolama Uygulamasını Bekleyen Kararlar)

The final balance between internal app storage and app-specific external storage remains pending measured session sizes and Redmi Note 9 Pro storage behavior. *(Internal app storage ile app-specific external storage arasındaki nihai denge ölçülmüş oturum boyutlarını ve Redmi Note 9 Pro storage davranışını beklemektedir.)*

---

# 241. Decisions Pending Android Backup Testing (Android Backup Testini Bekleyen Kararlar)

The exact backup/data-extraction XML configuration will be frozen after the target SDK and device behavior are verified. *(Kesin backup/data-extraction XML yapılandırması target SDK ve cihaz davranışı doğrulandıktan sonra sabitlenecektir.)*

---

# 242. Decisions Pending Foreground Lifecycle Testing (Foreground Lifecycle Testini Bekleyen Kararlar)

The final decision on whether NAVGUARD needs a foreground service remains pending Android lifecycle reliability testing. *(NAVGUARD'ın foreground service'e ihtiyaç duyup duymadığına ilişkin nihai karar Android lifecycle güvenilirlik testlerini beklemektedir.)*

---

# 243. Decisions Pending Distribution Plan (Dağıtım Planını Bekleyen Kararlar)

Any future Play Store privacy declarations or Data Safety disclosures will be based on the actual final data behavior of the distributable build rather than assumptions made during planning. *(Gelecekteki Play Store privacy declaration veya Data Safety açıklamaları planlama sırasında yapılan varsayımlar yerine dağıtılabilir build'in gerçek nihai veri davranışına dayanacaktır.)*

---

# 244. Final Permissions, Privacy & Security Architecture Statement (Nihai İzinler, Gizlilik ve Güvenlik Mimarisi Bildirimi)

**NAVGUARD will follow a least-privilege Android permission model in which precise location is required for formal GNSS anchoring and evaluation, camera access is requested only for ARCore-enabled functionality, Activity Recognition remains optional for Android step-sensor comparison, and broad storage, background location, microphone, contacts, SMS, phone, and unrelated device permissions remain outside the minimum architecture.** *(NAVGUARD resmî GNSS anchoring ve değerlendirme için kesin konumun gerekli olduğu, kamera erişiminin yalnızca ARCore etkin işlevsellik için istendiği, Activity Recognition'ın Android adım sensörü karşılaştırması için isteğe bağlı kaldığı ve geniş storage, background location, mikrofon, kişiler, SMS, telefon ve ilgisiz cihaz permission'larının minimum mimarinin dışında kaldığı least-privilege Android permission modeli izleyecektir.)*

**Formal sessions will not begin unless the selected navigation profile has the permissions it actually requires, and Approximate-only location access will never be treated as equivalent to the precise GNSS access required for anchor creation, recovery evaluation, and quantitative ground-truth comparison.** *(Resmî oturumlar seçilen navigasyon profili gerçekten gerektirdiği permission'lara sahip olmadıkça başlamayacak ve yalnızca Approximate location erişimi anchor oluşturma, recovery değerlendirmesi ve nicel ground-truth karşılaştırması için gerekli kesin GNSS erişimine hiçbir zaman eşdeğer kabul edilmeyecektir.)*

**Sensitive sensor, GNSS, ARCore, trajectory, recovery, and benchmark evidence will remain in application-controlled local storage by default, while external export will occur only through explicit user action and a user-selected destination without requiring unrestricted filesystem permission.** *(Hassas sensör, GNSS, ARCore, trajectory, recovery ve benchmark kanıtı varsayılan olarak uygulama kontrollü yerel depolamada kalırken harici export sınırsız filesystem permission gerektirmeden yalnızca açık kullanıcı işlemi ve kullanıcı tarafından seçilen hedef üzerinden gerçekleşecektir.)*

**The research prototype will prevent sensitive session evidence from being silently transferred through automatic cloud backup, using an explicit backup policy and supported Android exclusion mechanisms that will be verified against the final target SDK and device behavior.** *(Araştırma prototipi hassas oturum kanıtının otomatik cloud backup üzerinden sessizce aktarılmasını önleyecek ve nihai target SDK ile cihaz davranışına karşı doğrulanacak açık backup politikası ve desteklenen Android exclusion mekanizmalarını kullanacaktır.)*

**Evaluation Mode GNSS ground truth will remain a protected reference stream whose existence in memory, storage, diagnostics, or replay archives never grants estimator authorization, and any unauthorized influence on PDR, AI, EKF, anchor state, or fused position will invalidate the corresponding formal denied interval.** *(Evaluation Mode GNSS ground truth bellekte, depolamada, diagnostics'te veya replay arşivlerinde bulunması tahmin motoru authorization vermeyen korunan referans stream'i olarak kalacak ve PDR, yapay zekâ, EKF, anchor durumu veya füzyonlu konum üzerindeki herhangi bir yetkisiz etkisi karşılık gelen resmî kesintili aralığı geçersiz kılacaktır.)*

**Navigation-enabled AI artifacts, session manifests, recovery evidence, configuration snapshots, and finalized benchmark files will be treated as integrity-critical artifacts whose identities and optional hashes make accidental or unauthorized changes observable without falsely claiming that hashing provides confidentiality.** *(Navigasyon etkin yapay zekâ artifact'ları, oturum manifestleri, recovery kanıtı, yapılandırma snapshot'ları ve finalize edilmiş benchmark dosyaları kimlikleri ve isteğe bağlı hash'leriyle yanlışlıkla veya yetkisiz değişiklikleri gözlemlenebilir hale getiren bütünlük açısından kritik artifact'lar olarak ele alınacak ancak hash'lemenin gizlilik sağladığı yanlış şekilde iddia edilmeyecektir.)*

**General Android logs will not become an uncontrolled duplicate store for precise navigation evidence, camera frames will not be persistently retained by default, raw audio will not be collected, and no mandatory analytics or cloud service will receive NAVGUARD movement data in the minimum architecture.** *(Genel Android logları kesin navigasyon kanıtı için kontrolsüz duplicate depo haline gelmeyecek, kamera kareleri varsayılan olarak kalıcı şekilde tutulmayacak, ham ses toplanmayacak ve minimum mimaride hiçbir zorunlu analytics veya cloud servisi NAVGUARD hareket verisini almayacaktır.)*

**Permission state, backup policy, Ground Truth Firewall state, model integrity, storage availability, and export behavior will all be testable system properties rather than documentation-only promises, allowing the final research results to demonstrate both navigation performance and evidence integrity.** *(Permission durumu, backup politikası, Ground Truth Firewall durumu, model bütünlüğü, depolama kullanılabilirliği ve export davranışı yalnızca dokümantasyon vaatleri yerine test edilebilir sistem özellikleri olacak ve nihai araştırma sonuçlarının hem navigasyon performansını hem kanıt bütünlüğünü göstermesine izin verecektir.)*

---

# 245. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development Permissions, Privacy & Security Architecture Completed *(Doküman Durumu: Geliştirme Öncesi İzinler, Gizlilik ve Güvenlik Mimarisi Tamamlandı)*

**Permission Philosophy:** Least Privilege *(Permission Felsefesi: Least Privilege)*

**Privacy Philosophy:** Local-First *(Gizlilik Felsefesi: Local-First)*

**Formal GNSS Location Requirement:** Precise *(Resmî GNSS Konum Gereksinimi: Precise)*

**Location Runtime Permissions:** `ACCESS_COARSE_LOCATION` + `ACCESS_FINE_LOCATION` *(Konum Runtime Permission'ları: `ACCESS_COARSE_LOCATION` + `ACCESS_FINE_LOCATION`)*

**Approximate-Only Formal Benchmark:** Blocked *(Yalnızca Approximate Resmî Benchmark: Blocked)*

**Background Location:** Not Required *(Background Location: Gerekli Değil)*

**`ACCESS_BACKGROUND_LOCATION`:** Excluded from Minimum Scope *(`ACCESS_BACKGROUND_LOCATION`: Minimum Kapsamdan Hariç)*

**Camera Permission:** Conditional on ARCore *(`CAMERA` Permission: ARCore'a Bağlı Koşullu)*

**Preferred ARCore Packaging:** AR Optional *(Tercih Edilen ARCore Paketleme: AR Optional)*

**Raw Camera Frame Storage:** Disabled by Default *(Ham Kamera Kare Depolama: Varsayılan Olarak Devre Dışı)*

**Microphone Permission:** Not Required *(Mikrofon Permission: Gerekli Değil)*

**Audio Recording:** Disabled *(Ses Kaydı: Devre Dışı)*

**`ACTIVITY_RECOGNITION`:** Optional Android Step-Sensor Comparison *(`ACTIVITY_RECOGNITION`: İsteğe Bağlı Android Adım Sensörü Karşılaştırması)*

**NAVGUARD Custom Step Detector Dependency on Activity Recognition:** None *(NAVGUARD Özel Adım Algılayıcısının Activity Recognition Bağımlılığı: Yok)*

**`HIGH_SAMPLING_RATE_SENSORS`:** Not Required Initially *(`HIGH_SAMPLING_RATE_SENSORS`: Başlangıçta Gerekli Değil)*

**Planned Motion Sampling:** Approximately 50 Hz *(Planlanan Hareket Sampling: Yaklaşık 50 Hz)*

**Broad Filesystem Permission:** Forbidden *(Geniş Filesystem Permission: Yasak)*

**`MANAGE_EXTERNAL_STORAGE`:** Not Required *(`MANAGE_EXTERNAL_STORAGE`: Gerekli Değil)*

**Active Session Storage:** App-Controlled *(Aktif Oturum Depolama: Uygulama Kontrollü)*

**Session Export:** Explicit User Action *(Oturum Export: Açık Kullanıcı İşlemi)*

**Preferred Export Mechanism:** Storage Access Framework *(Tercih Edilen Export Mekanizması: Storage Access Framework)*

**Automatic Cloud Session Upload:** Disabled *(Otomatik Cloud Oturum Upload: Devre Dışı)*

**Mandatory User Account:** None *(Zorunlu Kullanıcı Hesabı: Yok)*

**Automatic Third-Party Analytics Upload:** None in Minimum Architecture *(Otomatik Üçüncü Taraf Analytics Upload: Minimum Mimaride Yok)*

**Formal Session Cloud Backup:** Excluded *(Resmî Oturum Cloud Backup: Hariç)*

**Preferred Prototype Backup Policy:** General Backup Disabled + Explicit Sensitive-Data Exclusion *(Tercih Edilen Prototip Backup Politikası: Genel Backup Devre Dışı + Açık Hassas Veri Exclusion)*

**Ground Truth Classification:** `REFERENCE_ONLY` *(Ground Truth Sınıflandırması: `REFERENCE_ONLY`)*

**Ground Truth Firewall:** Mandatory *(Ground Truth Firewall: Zorunlu)*

**Unauthorized GNSS Estimator Update Count:** Must Equal `0` *(Yetkisiz GNSS Estimator Update Count: `0` Olmalı)*

**Protected GNSS as AI Runtime Feature During Denial:** Forbidden *(Kesinti Sırasında AI Runtime Feature Olarak Korunan GNSS: Yasak)*

**Protected GNSS EKF Update During Denial:** Forbidden *(Kesinti Sırasında Korunan GNSS EKF Update: Yasak)*

**Protected GNSS Anchor Modification During Denial:** Forbidden *(Kesinti Sırasında Korunan GNSS Anchor Değişikliği: Yasak)*

**General Android Log for Precise Trajectories:** Forbidden *(Kesin Trajectory İçin Genel Android Log: Yasak)*

**Session Evidence Hashing:** Target / Supported *(Oturum Kanıt Hash'leme: Hedef / Destekleniyor)*

**AI Model Hash Verification:** Mandatory in Benchmark Mode *(AI Model Hash Doğrulaması: Benchmark Modunda Zorunlu)*

**Arbitrary User Model Loading:** Forbidden *(Keyfi Kullanıcı Model Yükleme: Yasak)*

**IMEI / Non-Resettable Hardware ID Usage:** Forbidden *(IMEI / Resetlenemeyen Hardware ID Kullanımı: Yasak)*

**Session Identifier:** Application-Generated *(Oturum Tanımlayıcısı: Uygulama Tarafından Oluşturulur)*

**Raw Evidence Automatic Deletion:** Forbidden *(Ham Kanıt Otomatik Silme: Yasak)*

**Session Retention:** User Controlled *(Oturum Saklama: Kullanıcı Kontrollü)*

**Imported Archive Trust:** Untrusted Until Validated *(Import Edilmiş Arşive Güven: Doğrulanana Kadar Güvenilmez)*

**Path Traversal Protection:** Mandatory *(Path Traversal Koruması: Zorunlu)*

**Permission Manifest Audit:** Mandatory Before Benchmark / Release *(Permission Manifest Audit: Benchmark / Release Öncesi Zorunlu)*

**Final Android Manifest Syntax:** Pending Environment Bootstrap *(Nihai Android Manifest Syntax: Ortam Bootstrap Bekleniyor)*

**Final Target SDK Permission Details:** Pending Environment Bootstrap *(Nihai Target SDK Permission Ayrıntıları: Ortam Bootstrap Bekleniyor)*

**Final Internal vs App-Specific External Storage Split:** Pending Device Storage Benchmark *(Nihai Internal vs App-Specific External Storage Ayrımı: Cihaz Storage Benchmark'ı Bekleniyor)*

**Final Backup Rule XML:** Pending Android Target / Device Validation *(Nihai Backup Rule XML: Android Target / Cihaz Doğrulaması Bekleniyor)*

**Foreground Service Requirement:** Pending Lifecycle Testing *(Foreground Service Gereksinimi: Lifecycle Testi Bekleniyor)*

**Encrypted Export:** Optional Future Enhancement *(Şifreli Export: İsteğe Bağlı Gelecek İyileştirmesi)*

**Next Documentation Item:** 33 — Testing Strategy *(Sonraki Dokümantasyon Öğesi: 33 — Test Stratejisi)*
