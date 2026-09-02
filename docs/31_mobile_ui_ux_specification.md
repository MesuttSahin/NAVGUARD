# 31 — Mobile UI/UX Specification (Mobil UI/UX Spesifikasyonu)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the complete user-interface and user-experience specification for the NAVGUARD Android research application. *(Bu doküman NAVGUARD Android araştırma uygulaması için tam kullanıcı arayüzü ve kullanıcı deneyimi spesifikasyonunu tanımlar.)*

It defines how the user creates sessions, performs readiness checks, calibrates the system, starts navigation, activates GNSS-denied operation, observes estimated position and uncertainty, performs GNSS recovery, reviews diagnostics, inspects completed sessions, compares navigation configurations, exports evidence, and handles degraded or failed system states. *(Kullanıcının oturumları nasıl oluşturacağını, hazırlık kontrollerini nasıl gerçekleştireceğini, sistemi nasıl kalibre edeceğini, navigasyonu nasıl başlatacağını, GNSS kesintili çalışmayı nasıl etkinleştireceğini, tahmini konum ve belirsizliği nasıl gözlemleyeceğini, GNSS recovery işlemini nasıl gerçekleştireceğini, diagnostics'i nasıl inceleyeceğini, tamamlanmış oturumları nasıl görüntüleyeceğini, navigasyon yapılandırmalarını nasıl karşılaştıracağını, kanıtı nasıl export edeceğini ve bozulmuş veya başarısız sistem durumlarını nasıl yöneteceğini tanımlar.)*

The UI will prioritize experimental clarity, state transparency, fast operator understanding, and protection against accidental invalidation of formal sessions. *(UI deneysel açıklığa, durum şeffaflığına, operatörün hızlı anlamasına ve resmî oturumların yanlışlıkla geçersiz hale getirilmesine karşı korumaya öncelik verecektir.)*

---

# 2. UI Philosophy (UI Felsefesi)

NAVGUARD is a research navigation application rather than a consumer turn-by-turn navigation product. *(NAVGUARD tüketici tipi turn-by-turn navigasyon ürünü yerine araştırma navigasyon uygulamasıdır.)*

The interface will therefore expose system state and confidence more explicitly than a normal map application. *(Bu nedenle arayüz sistem durumunu ve güveni normal harita uygulamasına göre daha açık şekilde gösterecektir.)*

---

# 3. Primary UX Principle (Temel UX İlkesi)

The user must always be able to understand whether the displayed position comes from GNSS, local dead reckoning, or fused NAVGUARD estimation. *(Kullanıcı gösterilen konumun GNSS'ten, yerel dead reckoning'den veya füzyonlu NAVGUARD tahmininden gelip gelmediğini her zaman anlayabilmelidir.)*

---

# 4. No Hidden Navigation Mode (Gizli Navigasyon Modu Olmaması)

The application must never silently change from GNSS Mode to GNSS-denied estimation or back without an observable state transition. *(Uygulama GNSS Modundan GNSS kesintili tahmine veya geri dönüşe gözlemlenebilir durum geçişi olmadan hiçbir zaman sessizce geçmemelidir.)*

---

# 5. No False Precision (Sahte Hassasiyet Olmaması)

The UI must not present GNSS-denied position as an exact location. *(UI GNSS kesintili konumu kesin konum olarak sunmamalıdır.)*

Estimated position must be accompanied by confidence or uncertainty information. *(Tahmini konuma güven veya belirsizlik bilgisi eşlik etmelidir.)*

---

# 6. Research Integrity in UI (UI İçerisinde Araştırma Bütünlüğü)

Evaluation Mode ground truth must be clearly separated from estimator output. *(Evaluation Mode ground truth tahmin motoru çıktısından açık şekilde ayrılmalıdır.)*

The UI must not expose protected ground truth in a way that can accidentally influence the operator during a blinded denied-navigation trial unless the active experiment protocol explicitly permits it. *(Aktif deney protokolü açıkça izin vermedikçe UI korunan ground truth'u blinded kesintili navigasyon denemesi sırasında operatörü yanlışlıkla etkileyebilecek şekilde göstermemelidir.)*

---

# 7. Primary Device Orientation (Temel Cihaz Yönelimi)

Portrait orientation will be the preferred initial layout for the Redmi Note 9 Pro. *(Dikey yönelim Redmi Note 9 Pro için tercih edilen ilk layout olacaktır.)*

Landscape support may be added later if testing demonstrates a practical need. *(Testler pratik ihtiyaç gösterirse yatay yönelim daha sonra eklenebilir.)*

---

# 8. Primary UI Technology (Temel UI Teknolojisi)

Flutter will own the main user interface and application-level visual state. *(Flutter temel kullanıcı arayüzünün ve uygulama seviyesi görsel durumun sahibi olacaktır.)*

Hardware-sensitive runtime state will be received through the platform abstractions defined in the Android architecture. *(Donanıma hassas runtime durumu Android mimarisinde tanımlanan platform abstraction'ları üzerinden alınacaktır.)*

---

# 9. UI Must Not Own Sensor Logic (UI Sensör Mantığının Sahibi Olmamalıdır)

Flutter widgets will not directly register physical sensors. *(Flutter widget'ları fiziksel sensörleri doğrudan register etmeyecektir.)*

The UI will consume normalized domain state produced by the authoritative system components. *(UI ana sistem bileşenleri tarafından üretilen normalize edilmiş domain durumunu kullanacaktır.)*

---

# 10. UI State Source of Truth (UI Durumunun Tek Kaynağı)

The UI will consume one authoritative application state rather than independently reconstructing navigation state inside individual screens. *(UI tek tek ekranların içerisinde navigasyon durumunu bağımsız olarak yeniden oluşturmak yerine tek ana uygulama durumunu kullanacaktır.)*

---

# 11. Raw Sensor Streams Are Not UI State (Ham Sensör Akışları UI Durumu Değildir)

High-frequency accelerometer or gyroscope samples will not be stored directly in general UI state management. *(Yüksek frekanslı ivmeölçer veya jiroskop örnekleri doğrudan genel UI state management içerisinde saklanmayacaktır.)*

Diagnostic charts may subscribe through dedicated bounded diagnostic streams. *(Diagnostic grafikler özel sınırlı diagnostic stream'ler üzerinden subscribe olabilir.)*

---

# 12. Main Application Navigation Structure (Ana Uygulama Navigasyon Yapısı)

The application will use a small number of clearly separated primary areas. *(Uygulama az sayıda açık şekilde ayrılmış temel alan kullanacaktır.)*

```text
HOME
(ANA SAYFA)

NEW SESSION / READINESS
(YENİ OTURUM / HAZIRLIK)

LIVE NAVIGATION
(CANLI NAVİGASYON)

SESSION HISTORY
(OTURUM GEÇMİŞİ)

DIAGNOSTICS
(DIAGNOSTICS)

SETTINGS
(AYARLAR)
```

---

# 13. Primary Navigation Pattern (Temel Navigasyon Deseni)

The first implementation may use a bottom navigation structure for stable top-level destinations. *(İlk uygulama kararlı üst seviye hedefler için bottom navigation yapısı kullanabilir.)*

Live Navigation may temporarily replace or hide ordinary navigation controls during an active formal session to reduce accidental exits. *(Canlı Navigasyon aktif resmî oturum sırasında yanlışlıkla çıkışları azaltmak için normal navigasyon kontrollerinin yerini geçici olarak alabilir veya onları gizleyebilir.)*

---

# 14. Main Screens (Ana Ekranlar)

The minimum application will contain the following primary screens. *(Minimum uygulama aşağıdaki temel ekranları içerecektir.)*

```text
01 Home
02 New Session
03 Readiness Check
04 Calibration
05 Live Navigation
06 Recovery
07 Session Finalization
08 Session History
09 Session Detail
10 Comparison
11 Diagnostics
12 Settings
```

---

# 15. Home Screen Purpose (Ana Sayfa Amacı)

The Home Screen will act as the main entry point into the application. *(Ana Sayfa uygulamanın temel giriş noktası olarak görev yapacaktır.)*

It will summarize system readiness and provide direct access to the next relevant action. *(Sistem hazırlığını özetleyecek ve bir sonraki ilgili işleme doğrudan erişim sağlayacaktır.)*

---

# 16. Home Screen Primary Content (Ana Sayfa Temel İçeriği)

The Home Screen will show the NAVGUARD project identity. *(Ana Sayfa NAVGUARD proje kimliğini gösterecektir.)*

It will show the current device-readiness summary. *(Mevcut cihaz hazırlık özetini gösterecektir.)*

It will show whether an unfinished session exists. *(Tamamlanmamış oturum bulunup bulunmadığını gösterecektir.)*

It will expose the primary `New Session` action. *(Temel `New Session` işlemini sunacaktır.)*

---

# 17. Home Screen Candidate Layout (Ana Sayfa Aday Layout'u)

```text
NAVGUARD

System Status
Sensors: Ready
GNSS: Ready
ARCore: Available
AI Runtime: Ready
Storage: Ready

[ NEW SESSION ]

Recent Session
...

[ SESSION HISTORY ]
[ DIAGNOSTICS ]
```

The actual visual styling will remain simple and research-oriented. *(Gerçek görsel stil sade ve araştırma odaklı kalacaktır.)*

---

# 18. Home Readiness Summary (Ana Sayfa Hazırlık Özeti)

The Home Screen will not duplicate the full Readiness Check. *(Ana Sayfa tam Hazırlık Kontrolünü duplicate etmeyecektir.)*

It will show a compact health summary derived from the authoritative readiness system. *(Ana hazırlık sisteminden türetilmiş kompakt health özeti gösterecektir.)*

---

# 19. Unfinished Session Alert (Tamamlanmamış Oturum Uyarısı)

If an `INCOMPLETE` session exists after an application restart, the Home Screen will display a visible recovery notice. *(Uygulama yeniden başlatıldıktan sonra `INCOMPLETE` oturum mevcutsa Ana Sayfa görünür recovery bildirimi gösterecektir.)*

---

# 20. Incomplete Session Actions (Tamamlanmamış Oturum İşlemleri)

The user may be allowed to inspect the incomplete session. *(Kullanıcının tamamlanmamış oturumu incelemesine izin verilebilir.)*

The user may export it for diagnostics. *(Kullanıcı diagnostics için export edebilir.)*

The user may delete it through an explicit destructive action. *(Kullanıcı açık destructive işlem üzerinden silebilir.)*

---

# 21. New Session Screen Purpose (Yeni Oturum Ekranı Amacı)

The New Session Screen will define the experimental configuration before recording begins. *(Yeni Oturum Ekranı kayıt başlamadan önce deneysel yapılandırmayı tanımlayacaktır.)*

---

# 22. New Session Configuration Fields (Yeni Oturum Yapılandırma Alanları)

The minimum user-selectable fields will include a session name or label. *(Minimum kullanıcı tarafından seçilebilir alanlar oturum adı veya etiketini içerecektir.)*

They will include runtime mode. *(Runtime modunu içerecektir.)*

They will include navigation configuration where appropriate. *(Uygun olduğunda navigasyon yapılandırmasını içerecektir.)*

---

# 23. Runtime Mode Selector (Runtime Modu Seçici)

Candidate runtime modes will be as follows. *(Aday runtime modları aşağıdaki gibi olacaktır.)*

```text
Development
(Geliştirme)

Audit
(Denetim)

Benchmark
(Benchmark)

Demo
(Demo)
```

---

# 24. Benchmark Mode Restrictions (Benchmark Modu Kısıtlamaları)

Benchmark Mode will hide or lock options that could invalidate a frozen experiment. *(Benchmark Modu sabitlenmiş deneyi geçersiz hale getirebilecek seçenekleri gizleyecek veya kilitleyecektir.)*

---

# 25. Navigation Configuration Selector (Navigasyon Yapılandırması Seçici)

Where comparison sessions are being performed, the user may select Configuration A, B, C, or D. *(Karşılaştırma oturumları gerçekleştirildiğinde kullanıcı Configuration A, B, C veya D seçebilir.)*

---

# 26. Configuration Labels (Yapılandırma Etiketleri)

```text
A — PDR Baseline
(A — PDR Temeli)

B — PDR + Improved Heading
(B — PDR + Geliştirilmiş Yön)

C — PDR + ARCore
(C — PDR + ARCore)

D — Full NAVGUARD
(D — Tam NAVGUARD)
```

---

# 27. Configuration Explanations (Yapılandırma Açıklamaları)

The interface will provide a short explanation for each configuration. *(Arayüz her yapılandırma için kısa açıklama sağlayacaktır.)*

The user should not need to memorize what A, B, C, and D mean. *(Kullanıcının A, B, C ve D'nin ne anlama geldiğini ezberlemesi gerekmemelidir.)*

---

# 28. Hidden Advanced Configuration (Gizli Gelişmiş Yapılandırma)

Low-level algorithm parameters will not be presented in the default New Session Screen. *(Düşük seviyeli algoritma parametreleri varsayılan Yeni Oturum Ekranında sunulmayacaktır.)*

Development Mode may expose an advanced configuration section. *(Development Mode gelişmiş yapılandırma bölümü sunabilir.)*

---

# 29. Benchmark Configuration Freeze Indicator (Benchmark Yapılandırma Sabitleme Göstergesi)

Benchmark sessions will show that the active configuration is frozen. *(Benchmark oturumları aktif yapılandırmanın sabitlenmiş olduğunu gösterecektir.)*

---

# 30. Continue to Readiness (Hazırlığa Devam)

The New Session Screen will not start acquisition directly. *(Yeni Oturum Ekranı veri toplamayı doğrudan başlatmayacaktır.)*

The next step will be the Readiness Check. *(Sonraki adım Hazırlık Kontrolü olacaktır.)*

---

# 31. Readiness Check Screen Purpose (Hazırlık Kontrol Ekranı Amacı)

The Readiness Check Screen will verify that all required capabilities for the selected configuration are available before recording starts. *(Hazırlık Kontrol Ekranı kayıt başlamadan önce seçilen yapılandırma için gerekli tüm yeteneklerin kullanılabilir olduğunu doğrulayacaktır.)*

---

# 32. Readiness Categories (Hazırlık Kategorileri)

The readiness screen will group checks into clear categories. *(Hazırlık ekranı kontrolleri açık kategoriler halinde gruplayacaktır.)*

```text
Device
(Cihaz)

Permissions
(İzinler)

Sensors
(Sensörler)

GNSS
(GNSS)

ARCore
(ARCore)

AI Runtime
(Yapay Zekâ Runtime)

Storage
(Depolama)

Logging
(Logging)
```

---

# 33. Readiness Status Values (Hazırlık Durum Değerleri)

```text
READY
(HAZIR)

WARNING
(UYARI)

BLOCKED
(ENGELLENDİ)

CHECKING
(KONTROL EDİLİYOR)
```

---

# 34. Readiness Severity (Hazırlık Önem Seviyesi)

A warning may allow the session to continue. *(Bir uyarı oturumun devam etmesine izin verebilir.)*

A blocked requirement will prevent a formal session from starting. *(Engellenmiş gereksinim resmî oturumun başlamasını önleyecektir.)*

---

# 35. Configuration-Specific Readiness (Yapılandırmaya Özgü Hazırlık)

Readiness requirements will depend on the selected navigation configuration. *(Hazırlık gereksinimleri seçilen navigasyon yapılandırmasına bağlı olacaktır.)*

ARCore failure will block Configuration C or a Configuration D profile that requires ARCore, but it will not necessarily block the minimum PDR-only configuration. *(ARCore hatası Configuration C'yi veya ARCore gerektiren Configuration D profilini engelleyecek ancak minimum yalnızca PDR yapılandırmasını mutlaka engellemeyecektir.)*

---

# 36. Mandatory Sensor Readiness (Zorunlu Sensör Hazırlığı)

Accelerometer availability will be checked. *(İvmeölçer kullanılabilirliği kontrol edilecektir.)*

Gyroscope availability will be checked. *(Jiroskop kullanılabilirliği kontrol edilecektir.)*

Magnetometer or required heading source availability will be checked. *(Manyetometre veya gerekli yön kaynağı kullanılabilirliği kontrol edilecektir.)*

---

# 37. GNSS Readiness (GNSS Hazırlığı)

GNSS provider availability will be shown explicitly. *(GNSS provider kullanılabilirliği açık şekilde gösterilecektir.)*

A currently valid anchor will not be assumed until the anchor acquisition stage completes. *(Anchor acquisition aşaması tamamlanana kadar mevcut geçerli anchor varsayılmayacaktır.)*

---

# 38. Storage Readiness (Depolama Hazırlığı)

The screen will report whether the application can create and write the required session artifacts. *(Ekran uygulamanın gerekli oturum artifact'larını oluşturup yazıp yazamadığını raporlayacaktır.)*

---

# 39. AI Readiness (Yapay Zekâ Hazırlığı)

AI-enabled profiles will show model identity, runtime readiness, and parity validation state where appropriate. *(Yapay zekâ etkin profiller uygun olduğunda model kimliğini, runtime hazırlığını ve parity validation durumunu gösterecektir.)*

---

# 40. Readiness Detail Expansion (Hazırlık Ayrıntı Genişletme)

Each readiness item may be expanded for technical details. *(Her hazırlık öğesi teknik ayrıntılar için genişletilebilir.)*

The default view will remain concise. *(Varsayılan görünüm kısa kalacaktır.)*

---

# 41. Readiness Retry (Hazırlık Yeniden Deneme)

Failed readiness checks will provide a `Retry` action where retry is meaningful. *(Başarısız hazırlık kontrolleri yeniden denemenin anlamlı olduğu durumlarda `Retry` işlemi sağlayacaktır.)*

---

# 42. Permission Resolution (Permission Çözümü)

Missing permissions will provide a direct action to request or resolve them. *(Eksik permission'lar onları istemek veya çözmek için doğrudan işlem sağlayacaktır.)*

Detailed permission behavior will be defined in Page 32. *(Ayrıntılı permission davranışı Page 32'de tanımlanacaktır.)*

---

# 43. Calibration Screen Purpose (Kalibrasyon Ekranı Amacı)

The Calibration Screen will prepare heading, sensor bias, and initial navigation conditions before formal navigation begins. *(Kalibrasyon Ekranı resmî navigasyon başlamadan önce yönü, sensör bias'ını ve ilk navigasyon koşullarını hazırlayacaktır.)*

---

# 44. Calibration Is Step-Based (Kalibrasyon Adım Bazlıdır)

Calibration will be presented as a short guided sequence rather than one ambiguous progress spinner. *(Kalibrasyon tek belirsiz progress spinner yerine kısa yönlendirilmiş dizi olarak sunulacaktır.)*

---

# 45. Candidate Calibration Steps (Aday Kalibrasyon Adımları)

```text
1. Hold Device Steady
(1. Cihazı Sabit Tut)

2. Orientation Check
(2. Yönelim Kontrolü)

3. Heading Quality Check
(3. Yön Kalitesi Kontrolü)

4. GNSS Anchor Acquisition
(4. GNSS Anchor Alımı)

5. Ready to Start
(5. Başlamaya Hazır)
```

---

# 46. Stationary Calibration Instruction (Sabit Kalibrasyon Talimatı)

The UI will clearly instruct the user when the phone must remain stationary. *(UI telefonun ne zaman sabit tutulması gerektiğini açık şekilde söyleyecektir.)*

---

# 47. No False Calibration Completion (Sahte Kalibrasyon Tamamlanması Olmaması)

The UI will not display calibration as completed merely because a fixed timer elapsed. *(UI yalnızca sabit timer dolduğu için kalibrasyonu tamamlanmış göstermeyecektir.)*

The underlying quality criteria must pass. *(Temel kalite kriterleri geçmelidir.)*

---

# 48. GNSS Anchor Acquisition UI (GNSS Anchor Alım UI'ı)

The anchor acquisition stage will display a clear waiting state. *(Anchor acquisition aşaması açık bekleme durumu gösterecektir.)*

---

# 49. Candidate Anchor Information (Aday Anchor Bilgileri)

Development diagnostics may show current GNSS horizontal accuracy, fix age, and stability status. *(Development diagnostics mevcut GNSS yatay accuracy değerini, fix yaşını ve kararlılık durumunu gösterebilir.)*

The normal user view may show only a simplified anchor-quality status. *(Normal kullanıcı görünümü yalnızca sadeleştirilmiş anchor kalite durumu gösterebilir.)*

---

# 50. Anchor Acceptance Feedback (Anchor Kabul Geri Bildirimi)

When the anchor is accepted, the UI will explicitly confirm that the local coordinate origin has been established. *(Anchor kabul edildiğinde UI yerel koordinat origin'inin oluşturulduğunu açık şekilde doğrulayacaktır.)*

---

# 51. Calibration Failure (Kalibrasyon Hatası)

A failed calibration step will identify the cause rather than presenting a generic failure. *(Başarısız kalibrasyon adımı genel hata göstermek yerine nedeni tanımlayacaktır.)*

---

# 52. Calibration Retry (Kalibrasyon Yeniden Deneme)

The user will be able to retry failed calibration where technically safe. *(Kullanıcı teknik olarak güvenli olduğunda başarısız kalibrasyonu yeniden deneyebilecektir.)*

---

# 53. Start Session Confirmation (Oturum Başlatma Onayı)

After successful calibration, the application will show a final start summary. *(Başarılı kalibrasyondan sonra uygulama nihai başlangıç özetini gösterecektir.)*

---

# 54. Start Summary Content (Başlangıç Özeti İçeriği)

The summary will include session identity. *(Özet oturum kimliğini içerecektir.)*

It will include configuration A-D or the selected profile. *(Configuration A-D veya seçilen profili içerecektir.)*

It will include AI status, ARCore status, GNSS anchor status, and logging status. *(Yapay zekâ durumu, ARCore durumu, GNSS anchor durumu ve logging durumunu içerecektir.)*

---

# 55. Live Navigation Screen Purpose (Canlı Navigasyon Ekranı Amacı)

The Live Navigation Screen will be the primary operational screen during active sessions. *(Canlı Navigasyon Ekranı aktif oturumlar sırasında temel operasyonel ekran olacaktır.)*

---

# 56. Live Navigation Layout Priorities (Canlı Navigasyon Layout Öncelikleri)

The current navigation mode must be immediately visible. *(Mevcut navigasyon modu anında görünür olmalıdır.)*

The estimated position must be visible on a map or equivalent spatial view. *(Tahmini konum harita veya eşdeğer spatial görünüm üzerinde görünür olmalıdır.)*

Confidence or uncertainty must be visible. *(Güven veya belirsizlik görünür olmalıdır.)*

Critical controls must remain easy to reach. *(Kritik kontroller kolay erişilebilir kalmalıdır.)*

---

# 57. Candidate Live Navigation Layout (Aday Canlı Navigasyon Layout'u)

```text
[ MODE STATUS ]

[ MAP / TRAJECTORY ]

Estimated Position
Confidence / Uncertainty
Heading
Distance
Steps

[ GNSS DENIED ]
[ RECOVER GNSS ]
[ STOP SESSION ]
```

Only actions valid in the current state will be enabled. *(Yalnızca mevcut durumda geçerli işlemler etkin olacaktır.)*

---

# 58. Mode Banner (Mod Banner'ı)

The top of the Live Navigation Screen will contain a persistent mode banner. *(Canlı Navigasyon Ekranının üst kısmı kalıcı mod banner'ı içerecektir.)*

---

# 59. Candidate Mode Labels (Aday Mod Etiketleri)

```text
GNSS MODE
(GNSS MODU)

EVALUATION MODE
(EVALUATION MODU)

NAVGUARD MODE
(NAVGUARD MODU)

RECOVERY PENDING
(RECOVERY BEKLENİYOR)

RELOCALIZING
(YENİDEN KONUMLANDIRILIYOR)

DEGRADED
(BOZULMUŞ)
```

---

# 60. Mode Color Must Not Be the Only Signal (Renk Tek Mod Sinyali Olmamalıdır)

Mode must be represented by text and iconography in addition to color. *(Mod renge ek olarak metin ve ikonografiyle temsil edilmelidir.)*

This avoids relying solely on color perception. *(Bu yalnızca renk algısına dayanmayı önler.)*

---

# 61. Map Role (Haritanın Rolü)

The map is a visualization surface rather than a navigation measurement source. *(Harita navigasyon ölçüm kaynağı yerine görselleştirme yüzeyidir.)*

---

# 62. Estimated Marker (Tahmini Marker)

The current NAVGUARD estimate will use a clearly identifiable marker. *(Mevcut NAVGUARD tahmini açık şekilde tanımlanabilir marker kullanacaktır.)*

---

# 63. GNSS Marker (GNSS Marker'ı)

When normal GNSS Mode permits it, the GNSS position may use a visually distinguishable marker. *(Normal GNSS Modu izin verdiğinde GNSS konumu görsel olarak ayırt edilebilir marker kullanabilir.)*

---

# 64. Ground Truth Marker in Evaluation Mode (Evaluation Mode Ground Truth Marker'ı)

Protected ground truth will be hidden by default during formal blinded denied intervals. *(Korunan ground truth resmî blinded kesintili aralıklar sırasında varsayılan olarak gizli olacaktır.)*

---

# 65. Estimated Trajectory (Tahmini Trajectory)

The map may display the estimated NAVGUARD trajectory accumulated during the session. *(Harita oturum sırasında birikmiş tahmini NAVGUARD trajectory'sini gösterebilir.)*

---

# 66. Baseline Trajectory Visibility (Temel Trajectory Görünürlüğü)

Baseline PDR trajectory will normally remain hidden during ordinary navigation to avoid clutter. *(Temel PDR trajectory normal navigasyon sırasında kalabalığı önlemek için genellikle gizli kalacaktır.)*

It may be shown in diagnostics or post-session comparison. *(Diagnostics veya oturum sonrası karşılaştırmada gösterilebilir.)*

---

# 67. Uncertainty Visualization (Belirsizlik Görselleştirmesi)

The estimated marker will support an uncertainty region. *(Tahmini marker belirsizlik bölgesini destekleyecektir.)*

---

# 68. Uncertainty Ellipse (Belirsizlik Ellipse'i)

Where technically practical, the UI will render the horizontal covariance ellipse defined in Page 28. *(Teknik olarak uygulanabilir olduğunda UI Page 28'de tanımlanan yatay kovaryans ellipse'ini render edecektir.)*

---

# 69. Circular Fallback (Dairesel Geri Dönüş)

A conservative circular uncertainty region may be used if rotated ellipse rendering becomes unnecessarily complex. *(Döndürülmüş ellipse render gereksiz derecede karmaşık hale gelirse temkinli dairesel belirsizlik bölgesi kullanılabilir.)*

---

# 70. No Probability Label Without Calibration (Kalibrasyon Olmadan Olasılık Etiketi Olmaması)

The UI will not call an uncertainty shape a `95% confidence region` unless Page 28 covariance calibration supports that claim. *(UI Page 28 kovaryans kalibrasyonu bu iddiayı desteklemedikçe belirsizlik şeklini `%95 güven bölgesi` olarak adlandırmayacaktır.)*

---

# 71. Generic Uncertainty Label (Genel Belirsizlik Etiketi)

Before statistical calibration, the visual region may simply be labeled `Estimated Uncertainty`. *(İstatistiksel kalibrasyon öncesinde görsel bölge yalnızca `Estimated Uncertainty` olarak etiketlenebilir.)*

---

# 72. Confidence Indicator (Güven Göstergesi)

A compact confidence indicator will accompany the map. *(Kompakt güven göstergesi haritaya eşlik edecektir.)*

---

# 73. Candidate UI Confidence Labels (Aday UI Güven Etiketleri)

The UI may expose the following separate presentation type. *(UI aşağıdaki ayrı presentation type'ını sunabilir.)*

```text
UiConfidenceLabel

HIGH
(YÜKSEK)

MODERATE
(ORTA)

LOW
(DÜŞÜK)

VERY_LOW
(ÇOK DÜŞÜK)

UNAVAILABLE
(KULLANILAMIYOR)
```

These are user-facing labels and are not members of the canonical Sensor Quality enum. The canonical internal enum remains `UNKNOWN`, `GOOD`, `USABLE`, `DEGRADED`, `UNRELIABLE`, and `UNAVAILABLE`. *(Bunlar user-facing label'lardır ve canonical Sensor Quality enum'unun üyeleri değildir. Canonical internal enum `UNKNOWN`, `GOOD`, `USABLE`, `DEGRADED`, `UNRELIABLE` ve `UNAVAILABLE` olarak kalır.)*

The mapping from internal quality and uncertainty to `UiConfidenceLabel` must be explicit, versioned, and calibrated before being interpreted as validated confidence. *(Internal quality ve uncertainty'den `UiConfidenceLabel`'a mapping explicit, versioned ve validated confidence olarak yorumlanmadan önce calibrated olmalıdır.)*

---

# 74. User-Friendly Confidence Labels (Kullanıcı Dostu Güven Etiketleri)

Normal UI may render `UiConfidenceLabel` using localized labels such as `High`, `Moderate`, `Low`, `Very Low`, and `Unavailable`. *(Normal UI `UiConfidenceLabel` değerlerini `High`, `Moderate`, `Low`, `Very Low` ve `Unavailable` gibi localized label'larla gösterebilir.)*

Diagnostics will retain the exact internal quality state. *(Diagnostics kesin dahili kalite durumunu koruyacaktır.)*

---

# 75. No Percentage Confidence by Default (Varsayılan Yüzde Güven Olmaması)

The UI will not display an arbitrary confidence percentage unless it has a calibrated mathematical interpretation. *(UI kalibre edilmiş matematiksel yorumu olmadıkça keyfi güven yüzdesi göstermeyecektir.)*

---

# 76. Position Detail Card (Konum Ayrıntı Kartı)

The Live Navigation Screen may contain a compact position card. *(Canlı Navigasyon Ekranı kompakt konum kartı içerebilir.)*

---

# 77. Candidate Position Card Fields (Aday Konum Kartı Alanları)

```text
Mode
Estimated Position
Uncertainty
Heading
Step Count
Estimated Distance
ARCore Status
Motion State
```

---

# 78. Latitude and Longitude Display (Enlem ve Boylam Gösterimi)

Latitude and longitude may be available through an expandable detail section. *(Enlem ve boylam genişletilebilir ayrıntı bölümü üzerinden kullanılabilir olabilir.)*

They do not need to dominate the normal navigation UI. *(Normal navigasyon UI'ına hakim olmaları gerekmez.)*

---

# 79. Local ENU Display (Yerel ENU Gösterimi)

Development diagnostics will expose East and North coordinates directly. *(Development diagnostics East ve North koordinatlarını doğrudan sunacaktır.)*

---

# 80. Heading Display (Yön Gösterimi)

Current true-north-referenced heading may be shown as a compact compass indicator. *(Mevcut true-north referanslı yön kompakt pusula göstergesi olarak gösterilebilir.)*

---

# 81. Heading Quality (Yön Kalitesi)

Heading quality will be available alongside heading where appropriate. *(Uygun olduğunda yön kalitesi yön bilgisiyle birlikte kullanılabilir olacaktır.)*

---

# 82. Motion State Display (Hareket Durumu Gösterimi)

AI-enabled profiles may show the accepted operational motion class. *(Yapay zekâ etkin profiller kabul edilmiş operasyonel hareket sınıfını gösterebilir.)*

---

# 83. Candidate Motion Labels (Aday Hareket Etiketleri)

```text
STATIONARY
(SABİT)

WALKING
(YÜRÜYOR)

RUNNING
(KOŞUYOR)

TURNING
(DÖNÜYOR)

UNKNOWN
(BİLİNMİYOR)
```

---

# 84. Raw AI Prediction Is Diagnostic (Ham Yapay Zekâ Tahmini Diagnostic'tir)

The normal navigation UI will show the accepted operational motion state rather than every raw model fluctuation. *(Normal navigasyon UI'ı her ham model dalgalanması yerine kabul edilmiş operasyonel hareket durumunu gösterecektir.)*

---

# 85. AI Shadow Mode Display (Yapay Zekâ Shadow Mode Gösterimi)

In Shadow Mode, diagnostics may show deterministic state and AI prediction side by side. *(Shadow Mode içerisinde diagnostics deterministik durum ve yapay zekâ tahminini yan yana gösterebilir.)*

---

# 86. ARCore Status Display (ARCore Durum Gösterimi)

ARCore-enabled configurations will show tracking state. *(ARCore etkin yapılandırmalar tracking durumunu gösterecektir.)*

---

# 87. Candidate ARCore Labels (Aday ARCore Etiketleri)

```text
TRACKING
(TRACKING)

LIMITED
(SINIRLI)

PAUSED
(DURAKLATILDI)

UNAVAILABLE
(KULLANILAMIYOR)
```

---

# 88. ARCore Tracking Loss Behavior (ARCore Tracking Kaybı Davranışı)

Tracking loss will not automatically replace the entire Live Navigation Screen with an error page. *(Tracking kaybı tüm Canlı Navigasyon Ekranını otomatik olarak hata sayfasıyla değiştirmeyecektir.)*

The application will continue PDR if valid and show a degraded-state notification. *(Uygulama geçerliyse PDR'a devam edecek ve degraded-state bildirimi gösterecektir.)*

---

# 89. GNSS-Denied Activation Control (GNSS Kesintili Etkinleştirme Kontrolü)

The first implementation will provide an explicit software control for beginning GNSS-denied navigation. *(İlk uygulama GNSS kesintili navigasyonu başlatmak için açık yazılım kontrolü sağlayacaktır.)*

---

# 90. Candidate Denial Button (Aday Kesinti Butonu)

```text
START GNSS-DENIED MODE
(GNSS KESİNTİLİ MODU BAŞLAT)
```

---

# 91. Denial Action Is High Impact (Kesinti İşlemi Yüksek Etkilidir)

Starting a denied interval changes the experimental state and must not occur from an accidental tap. *(Kesintili aralık başlatmak deneysel durumu değiştirir ve yanlışlıkla dokunmayla gerçekleşmemelidir.)*

---

# 92. Denial Confirmation (Kesinti Onayı)

Benchmark Mode may require a confirmation sheet before starting the denied interval. *(Benchmark Mode kesintili aralığı başlatmadan önce confirmation sheet gerektirebilir.)*

---

# 93. Denial Confirmation Content (Kesinti Onayı İçeriği)

The confirmation will state that GNSS will be excluded from the estimator. *(Onay GNSS'in tahmin motorundan hariç tutulacağını belirtecektir.)*

It will state that Evaluation Mode ground truth may continue logging independently. *(Evaluation Mode ground truth'un bağımsız logging'e devam edebileceğini belirtecektir.)*

---

# 94. Denial Transition Feedback (Kesinti Geçiş Geri Bildirimi)

The UI will visibly acknowledge when the Ground Truth Firewall becomes blocking. *(UI Ground Truth Firewall blocking hale geldiğinde bunu görünür şekilde bildirecektir.)*

---

# 95. Denied Interval Timer (Kesintili Aralık Timer'ı)

The Live Navigation Screen may display elapsed denied time. *(Canlı Navigasyon Ekranı geçen kesintili süreyi gösterebilir.)*

---

# 96. Denied Distance (Kesintili Mesafe)

The UI may display estimated travelled distance since denial began. *(UI kesinti başladığından beri tahmini kat edilen mesafeyi gösterebilir.)*

---

# 97. No Ground Truth Error During Blinded Run (Blinded Deneme Sırasında Ground Truth Hatası Olmaması)

Live position error against protected GNSS ground truth will not be shown during formal blinded Evaluation Mode. *(Korunan GNSS ground truth'a karşı canlı konum hatası resmî blinded Evaluation Mode sırasında gösterilmeyecektir.)*

---

# 98. Reason for Hidden Live Error (Canlı Hatanın Gizlenme Nedeni)

Showing live error could influence how the user moves and contaminate the experiment. *(Canlı hatayı göstermek kullanıcının nasıl hareket ettiğini etkileyebilir ve deneyi kontamine edebilir.)*

---

# 99. Degraded Navigation Notification (Bozulmuş Navigasyon Bildirimi)

When quality falls to a degraded level, the UI will present a persistent but non-blocking warning. *(Kalite degraded seviyeye düştüğünde UI kalıcı ancak block etmeyen uyarı gösterecektir.)*

---

# 100. Invalid Estimate Notification (Geçersiz Tahmin Bildirimi)

When current position becomes invalid, the UI will stop presenting the marker as trustworthy. *(Mevcut konum geçersiz hale geldiğinde UI marker'ı güvenilir olarak sunmayı bırakacaktır.)*

---

# 101. Invalid Estimate Map Behavior (Geçersiz Tahmin Harita Davranışı)

The last valid position may remain visible with a clear stale or invalid indicator. *(Son geçerli konum açık stale veya invalid göstergesiyle görünür kalabilir.)*

It must not continue moving without estimator updates. *(Tahmin motoru update'leri olmadan hareket etmeye devam etmemelidir.)*

---

# 102. Recovery Control (Recovery Kontrolü)

During an active denied interval, the interface will expose a controlled GNSS recovery action. *(Aktif kesintili aralık sırasında arayüz kontrollü GNSS recovery işlemi sunacaktır.)*

---

# 103. Candidate Recovery Action (Aday Recovery İşlemi)

```text
RECOVER GNSS
(GNSS'İ GERİ KAZAN)
```

---

# 104. Recovery Is Not Instant (Recovery Anlık Değildir)

Pressing the recovery action will move the application to `GNSS_RECOVERY_PENDING`. *(Recovery işlemine basmak uygulamayı `GNSS_RECOVERY_PENDING` durumuna taşıyacaktır.)*

It will not immediately display the GNSS fix as the corrected position. *(GNSS fix'ini hemen düzeltilmiş konum olarak göstermeyecektir.)*

---

# 105. Recovery Screen Purpose (Recovery Ekranı Amacı)

The Recovery Screen will communicate the multi-stage recovery process defined in Page 29. *(Recovery Ekranı Page 29'da tanımlanan çok aşamalı recovery sürecini iletecektir.)*

---

# 106. Recovery Steps (Recovery Adımları)

```text
1. Checking GNSS
(1. GNSS Kontrol Ediliyor)

2. Validating Reference
(2. Referans Doğrulanıyor)

3. Recording Pre-Correction Error
(3. Düzeltme Öncesi Hata Kaydediliyor)

4. Relocalizing
(4. Yeniden Konumlandırılıyor)

5. GNSS Restored
(5. GNSS Geri Yüklendi)
```

---

# 107. Recovery Quality Display (Recovery Kalite Gösterimi)

Development Mode may show fix age, accuracy, candidate count, and stability. *(Development Mode fix yaşını, accuracy değerini, aday sayısını ve kararlılığı gösterebilir.)*

Normal Mode may show only the recovery stage and whether a valid reference is available. *(Normal Mod yalnızca recovery aşamasını ve geçerli referansın kullanılabilir olup olmadığını gösterebilir.)*

---

# 108. Recovery Cannot Be Forced Through Bad Data (Recovery Kötü Veriyle Zorlanamaz)

The UI will not provide a normal Benchmark Mode button that bypasses recovery quality gates. *(UI Benchmark Modunda recovery kalite kapılarını atlayan normal buton sağlamayacaktır.)*

---

# 109. Recovery Timeout UI (Recovery Timeout UI'ı)

If recovery times out, the user will be told that no acceptable GNSS reference was obtained. *(Recovery timeout olursa kullanıcıya kabul edilebilir GNSS referansı elde edilemediği bildirilecektir.)*

---

# 110. Recovery Retry UI (Recovery Yeniden Deneme UI'ı)

The user may retry recovery while local navigation continues if allowed by the state machine. *(State machine izin verirse kullanıcı yerel navigasyon devam ederken recovery'yi yeniden deneyebilir.)*

---

# 111. Recovery Cancellation (Recovery İptali)

A pending recovery attempt may offer a cancel action before relocalization begins. *(Bekleyen recovery denemesi relocalization başlamadan önce cancel işlemi sunabilir.)*

Cancellation will return to denied navigation rather than GNSS Mode. *(İptal GNSS Moduna değil kesintili navigasyona geri dönecektir.)*

---

# 112. Relocalization UI (Relocalization UI'ı)

During relocalization, the UI will briefly indicate that the current estimate is being aligned to a validated absolute reference. *(Relocalization sırasında UI mevcut tahminin doğrulanmış mutlak referansa hizalandığını kısa süreli belirtecektir.)*

---

# 113. Relocalization Discontinuity (Relocalization Süreksizliği)

If the current marker moves significantly due to recovery correction, the UI will not pretend that the correction path was physically walked. *(Mevcut marker recovery düzeltmesi nedeniyle anlamlı şekilde hareket ederse UI düzeltme path'inin fiziksel olarak yüründüğünü varsaymayacaktır.)*

---

# 114. Relocalization Marker (Relocalization Marker'ı)

A small map event marker may indicate where relocalization occurred. *(Küçük harita olay marker'ı relocalization'ın nerede gerçekleştiğini gösterebilir.)*

---

# 115. Recovery Error Visibility (Recovery Hata Görünürlüğü)

Recovery error may be shown after the pre-correction value has been safely recorded. *(Recovery hatası düzeltme öncesi değer güvenli şekilde kaydedildikten sonra gösterilebilir.)*

---

# 116. Benchmark Recovery Result (Benchmark Recovery Sonucu)

The application may show a concise message such as `Pre-correction error recorded`. *(Uygulama `Pre-correction error recorded` gibi kısa mesaj gösterebilir.)*

Detailed numerical error may be deferred to the session summary to preserve experiment flow. *(Ayrıntılı sayısal hata deney akışını korumak için oturum özetine bırakılabilir.)*

---

# 117. GNSS Restored State (GNSS Geri Yüklendi Durumu)

After successful relocalization and authorization restoration, the mode banner will explicitly return to GNSS Mode. *(Başarılı relocalization ve authorization geri açıldıktan sonra mod banner'ı açık şekilde GNSS Moduna dönecektir.)*

---

# 118. Stop Session Control (Oturumu Durdurma Kontrolü)

The Live Navigation Screen will contain a persistent Stop Session action. *(Canlı Navigasyon Ekranı kalıcı Stop Session işlemi içerecektir.)*

---

# 119. Stop Session Is Destructive to Active Recording (Stop Session Aktif Kayıt İçin Destructive İşlemdir)

The user will receive confirmation before ending a formal session. *(Kullanıcı resmî oturumu sonlandırmadan önce onay alacaktır.)*

---

# 120. Emergency Stop Simplicity (Acil Durdurma Basitliği)

The confirmation flow must remain short enough that the user can terminate recording quickly if needed. *(Onay akışı kullanıcının gerektiğinde kaydı hızlı şekilde sonlandırabileceği kadar kısa kalmalıdır.)*

---

# 121. Session Stopping Screen (Oturum Durdurma Ekranı)

After Stop is confirmed, the UI will show that finalization is in progress. *(Stop onaylandıktan sonra UI finalization'ın devam ettiğini gösterecektir.)*

---

# 122. Finalization Stages (Finalization Aşamaları)

The UI may show high-level stages such as stopping sensors, flushing logs, verifying files, and generating the manifest. *(UI sensörleri durdurma, logları flush etme, dosyaları doğrulama ve manifest üretme gibi yüksek seviyeli aşamaları gösterebilir.)*

---

# 123. Do Not Leave During Critical Finalization (Kritik Finalization Sırasında Çıkmama)

The application may temporarily block starting another session while finalization is incomplete. *(Uygulama finalization tamamlanmamışken yeni oturum başlatmayı geçici olarak engelleyebilir.)*

---

# 124. Finalization Failure UI (Finalization Hatası UI'ı)

If finalization fails, the user will be told that the session has been preserved but may be incomplete or invalid. *(Finalization başarısız olursa kullanıcıya oturumun korunduğu ancak tamamlanmamış veya geçersiz olabileceği bildirilecektir.)*

---

# 125. Session Summary Screen (Oturum Özet Ekranı)

A completed session will end on a Session Summary Screen. *(Tamamlanmış oturum Oturum Özet Ekranında sona erecektir.)*

---

# 126. Session Summary Candidate Content (Oturum Özeti Aday İçeriği)

```text
Session ID
Duration
Configuration
Navigation Modes
Denied Duration
Estimated Distance
Step Count
ARCore Availability
AI Model
Recovery Result
Final Position Error
Integrity Status
```

Only metrics that are actually available will be shown. *(Yalnızca gerçekten kullanılabilir metrikler gösterilecektir.)*

---

# 127. No Fabricated Summary Metrics (Uydurulmuş Özet Metrikleri Olmaması)

Unavailable results will be displayed as unavailable rather than zero. *(Kullanılamayan sonuçlar sıfır yerine kullanılamaz olarak gösterilecektir.)*

---

# 128. Integrity Status in Summary (Özette Bütünlük Durumu)

The summary will show whether the session passed formal integrity checks. *(Özet oturumun resmî bütünlük kontrollerini geçip geçmediğini gösterecektir.)*

---

# 129. Candidate Integrity Labels (Aday Bütünlük Etiketleri)

```text
PASS
(GEÇTİ)

PASS WITH WARNINGS
(UYARILARLA GEÇTİ)

INVALID
(GEÇERSİZ)

INCOMPLETE
(TAMAMLANMAMIŞ)
```

---

# 130. Session History Screen Purpose (Oturum Geçmiş Ekranı Amacı)

The Session History Screen will list previously recorded sessions. *(Oturum Geçmiş Ekranı daha önce kaydedilmiş oturumları listeleyecektir.)*

---

# 131. Session History Sorting (Oturum Geçmiş Sıralaması)

Sessions will normally be ordered by most recent first. *(Oturumlar normalde en yeniden en eskiye doğru sıralanacaktır.)*

---

# 132. Session History Item (Oturum Geçmiş Öğesi)

Each list item will show enough information to distinguish sessions quickly. *(Her liste öğesi oturumları hızlı ayırt etmek için yeterli bilgi gösterecektir.)*

---

# 133. Candidate Session History Fields (Aday Oturum Geçmiş Alanları)

```text
Session Name
Date
Duration
Configuration
Status
Denied Duration
```

---

# 134. Session Status Visibility (Oturum Durum Görünürlüğü)

Incomplete and invalid sessions must be clearly visible as such. *(Tamamlanmamış ve geçersiz oturumlar açık şekilde bu durumlarıyla görünür olmalıdır.)*

---

# 135. Session Filters (Oturum Filtreleri)

Optional filters may allow viewing only Benchmark, Demo, Invalid, or Completed sessions. *(İsteğe bağlı filtreler yalnızca Benchmark, Demo, Invalid veya Completed oturumların görüntülenmesine izin verebilir.)*

---

# 136. Session Detail Screen Purpose (Oturum Ayrıntı Ekranı Amacı)

The Session Detail Screen will provide post-session analysis for one selected session. *(Oturum Ayrıntı Ekranı seçilen tek oturum için oturum sonrası analiz sağlayacaktır.)*

---

# 137. Session Detail Tabs (Oturum Ayrıntı Sekmeleri)

Candidate sections are as follows. *(Aday bölümler aşağıdaki gibidir.)*

```text
Overview
(Genel Bakış)

Map
(Harita)

Metrics
(Metrikler)

Events
(Olaylar)

Artifacts
(Artifact'lar)

Configuration
(Yapılandırma)
```

---

# 138. Session Detail Overview (Oturum Ayrıntı Genel Bakış)

The Overview section will show session metadata and high-level results. *(Genel Bakış bölümü oturum metadata bilgisini ve yüksek seviyeli sonuçları gösterecektir.)*

---

# 139. Post-Session Map (Oturum Sonrası Harita)

The Map section may display estimated, baseline, and ground-truth trajectories simultaneously when appropriate. *(Harita bölümü uygun olduğunda tahmini, temel ve ground-truth trajectory'lerini aynı anda gösterebilir.)*

---

# 140. Trajectory Legend (Trajectory Lejandı)

Each trajectory will have a clear legend. *(Her trajectory açık lejanda sahip olacaktır.)*

No two trajectories will rely solely on subtle color differences. *(Hiçbir iki trajectory yalnızca ince renk farklılıklarına dayanmayacaktır.)*

---

# 141. Denied Interval Highlight (Kesintili Aralık Vurgusu)

The post-session map may visually highlight the GNSS-denied interval. *(Oturum sonrası harita GNSS kesintili aralığı görsel olarak vurgulayabilir.)*

---

# 142. Recovery Point Display (Recovery Noktası Gösterimi)

Recovery and relocalization events may be shown as event markers. *(Recovery ve relocalization olayları event marker olarak gösterilebilir.)*

---

# 143. Metrics Screen (Metrikler Ekranı)

The Metrics section will show only metrics supported by the stored evidence. *(Metrikler bölümü yalnızca saklanan kanıt tarafından desteklenen metrikleri gösterecektir.)*

---

# 144. Candidate Navigation Metrics (Aday Navigasyon Metrikleri)

```text
Mean Position Error
(Ortalama Konum Hatası)

Median Position Error
(Medyan Konum Hatası)

RMSE
(RMSE)

Final Error
(Nihai Hata)

P95 Error
(P95 Hata)

Drift per Minute
(Dakika Başına Drift)

Drift per Distance
(Mesafe Başına Drift)
```

---

# 145. Position Error Requires Reference (Konum Hatası Referans Gerektirir)

If valid ground truth is not available, the application will not display false position-error metrics. *(Geçerli ground truth mevcut değilse uygulama sahte konum hata metrikleri göstermeyecektir.)*

---

# 146. Recovery Metrics (Recovery Metrikleri)

The Metrics section may include recovery error, recovery latency, and recovery-reference accuracy. *(Metrikler bölümü recovery hatasını, recovery gecikmesini ve recovery referans accuracy değerini içerebilir.)*

---

# 147. AI Metrics in Session UI (Oturum UI'ında Yapay Zekâ Metrikleri)

The application may show model identity and runtime latency for AI-enabled sessions. *(Uygulama yapay zekâ etkin oturumlarda model kimliğini ve runtime gecikmesini gösterebilir.)*

Full ML evaluation metrics belong primarily to the offline ML evaluation workflow. *(Tam ML değerlendirme metrikleri temel olarak çevrimdışı ML değerlendirme workflow'una aittir.)*

---

# 148. Uncertainty History (Belirsizlik Geçmişi)

The Session Detail Screen may show an uncertainty-over-time graph. *(Oturum Ayrıntı Ekranı zaman içerisindeki belirsizlik grafiğini gösterebilir.)*

---

# 149. Error vs Uncertainty Plot (Hata ile Belirsizlik Grafiği)

Development or analysis mode may compare observed error with predicted uncertainty. *(Development veya analysis modu gözlemlenen hata ile tahmin edilen belirsizliği karşılaştırabilir.)*

---

# 150. Event Timeline Screen (Olay Zaman Çizgisi Ekranı)

The Events section will provide a chronological list of important system transitions. *(Olaylar bölümü önemli sistem geçişlerinin kronolojik listesini sağlayacaktır.)*

---

# 151. Candidate Event Timeline Items (Aday Olay Zaman Çizgisi Öğeleri)

```text
Session Started
(Oturum Başladı)

GNSS Anchor Accepted
(GNSS Anchor Kabul Edildi)

Denial Started
(Kesinti Başladı)

ARCore Degraded
(ARCore Bozuldu)

Recovery Requested
(Recovery İstendi)

Recovery Reference Accepted
(Recovery Referansı Kabul Edildi)

Relocalization Completed
(Relocalization Tamamlandı)

Session Finalized
(Oturum Finalize Edildi)
```

---

# 152. Artifact Browser (Artifact Tarayıcı)

Development Mode may provide a lightweight Artifact section showing which files were generated. *(Development Mode hangi dosyaların üretildiğini gösteren hafif Artifact bölümü sağlayabilir.)*

---

# 153. No Raw File Editing in App (Uygulamada Ham Dosya Düzenleme Olmaması)

The application will not provide direct editing of raw session evidence. *(Uygulama ham oturum kanıtını doğrudan düzenleme imkânı sağlamayacaktır.)*

---

# 154. Export Action (Export İşlemi)

Session Detail will provide an explicit export action. *(Oturum Ayrıntı açık export işlemi sağlayacaktır.)*

---

# 155. Candidate Export Button (Aday Export Butonu)

```text
EXPORT SESSION
(OTURUMU EXPORT ET)
```

---

# 156. Export Progress (Export İlerlemesi)

Large exports will show a progress state. *(Büyük export işlemleri progress durumu gösterecektir.)*

---

# 157. Export Completion (Export Tamamlanması)

The user will receive clear confirmation when export succeeds. *(Export başarılı olduğunda kullanıcı açık confirmation alacaktır.)*

---

# 158. Export Failure (Export Hatası)

A failed export will not be shown as completed. *(Başarısız export tamamlanmış olarak gösterilmeyecektir.)*

---

# 159. Session Deletion UX (Oturum Silme UX'i)

Deleting a session will use a destructive-action confirmation. *(Oturum silmek destructive-action confirmation kullanacaktır.)*

---

# 160. Benchmark Session Deletion Protection (Benchmark Oturum Silme Koruması)

Benchmark sessions may require stronger confirmation than ordinary development sessions. *(Benchmark oturumları normal geliştirme oturumlarına göre daha güçlü confirmation gerektirebilir.)*

---

# 161. Comparison Screen Purpose (Karşılaştırma Ekranı Amacı)

The Comparison Screen will support side-by-side analysis of configurations A-D or other controlled replay results. *(Karşılaştırma Ekranı A-D yapılandırmalarının veya diğer kontrollü replay sonuçlarının yan yana analizini destekleyecektir.)*

---

# 162. Comparison Requires Compatible Sessions (Karşılaştırma Uyumlu Oturumlar Gerektirir)

The UI will warn when selected sessions are not sufficiently comparable. *(Seçilen oturumlar yeterince karşılaştırılabilir değilse UI uyaracaktır.)*

---

# 163. Candidate Compatibility Checks (Aday Uyumluluk Kontrolleri)

Comparison may consider route identity. *(Karşılaştırma rota kimliğini dikkate alabilir.)*

It may consider denied duration. *(Kesintili süreyi dikkate alabilir.)*

It may consider configuration version. *(Yapılandırma sürümünü dikkate alabilir.)*

---

# 164. Comparison Metrics (Karşılaştırma Metrikleri)

The Comparison Screen may compare final error, median error, RMSE, P95, drift rate, ARCore availability, and recovery error. *(Karşılaştırma Ekranı nihai hata, medyan hata, RMSE, P95, drift hızı, ARCore kullanılabilirliği ve recovery hatasını karşılaştırabilir.)*

---

# 165. Comparison Map (Karşılaştırma Haritası)

Matched trajectories may be overlaid on a shared map. *(Eşleşmiş trajectory'ler ortak harita üzerinde overlay edilebilir.)*

---

# 166. No Automatic Winner Without Context (Bağlam Olmadan Otomatik Kazanan Olmaması)

The UI will not simply declare a configuration best from one metric unless the benchmark definition explicitly defines that criterion. *(Benchmark tanımı bu kriteri açıkça tanımlamadıkça UI tek metrik üzerinden yapılandırmayı basitçe en iyi ilan etmeyecektir.)*

---

# 167. Diagnostics Home (Diagnostics Ana Ekranı)

The Diagnostics area will provide technical visibility into the system without polluting the main navigation interface. *(Diagnostics alanı ana navigasyon arayüzünü kalabalıklaştırmadan sisteme teknik görünürlük sağlayacaktır.)*

---

# 168. Diagnostic Categories (Diagnostic Kategorileri)

```text
Device
(Cihaz)

Sensors
(Sensörler)

Timing
(Zamanlama)

GNSS
(GNSS)

ARCore
(ARCore)

AI
(Yapay Zekâ)

Fusion
(Füzyon)

Storage
(Depolama)

Runtime
(Runtime)
```

---

# 169. Sensor Diagnostics Screen (Sensör Diagnostics Ekranı)

The Sensor Diagnostics Screen will show currently detected sensors and stream health. *(Sensör Diagnostics Ekranı mevcut tespit edilmiş sensörleri ve stream health durumunu gösterecektir.)*

---

# 170. Sensor Diagnostic Fields (Sensör Diagnostic Alanları)

Candidate fields include sensor name, vendor, requested rate, measured rate, accuracy state, last timestamp, and drop count. *(Aday alanlar sensör adını, vendor'ı, talep edilen hızı, ölçülen hızı, accuracy durumunu, son zaman damgasını ve drop sayısını içerir.)*

---

# 171. Live Sensor Charts (Canlı Sensör Grafikleri)

Development Mode may provide short rolling plots for accelerometer, gyroscope, and magnetometer values. *(Development Mode ivmeölçer, jiroskop ve manyetometre değerleri için kısa rolling grafikler sağlayabilir.)*

---

# 172. Diagnostic Chart Buffers Must Be Bounded (Diagnostic Grafik Buffer'ları Sınırlı Olmalıdır)

Live charts will retain only a recent bounded window. *(Canlı grafikler yalnızca yakın zamandaki sınırlı pencereyi koruyacaktır.)*

---

# 173. Timing Diagnostics Screen (Zamanlama Diagnostics Ekranı)

Timing diagnostics will show actual sample intervals, jitter indicators, and missing-sample events. *(Zamanlama diagnostics gerçek örnek aralıklarını, jitter göstergelerini ve eksik örnek olaylarını gösterecektir.)*

---

# 174. GNSS Diagnostics Screen (GNSS Diagnostics Ekranı)

GNSS diagnostics may show provider, fix age, horizontal accuracy, satellite count, used-in-fix count, and GNSS status. *(GNSS diagnostics provider'ı, fix yaşını, yatay accuracy değerini, uydu sayısını, fix'te kullanılan uydu sayısını ve GNSS durumunu gösterebilir.)*

---

# 175. GNSS Diagnostics and Evaluation Isolation (GNSS Diagnostics ve Evaluation İzolasyonu)

During formal Evaluation Mode, access to detailed ground-truth GNSS diagnostics may be restricted while the denied interval is active. *(Resmî Evaluation Mode sırasında kesintili aralık aktifken ayrıntılı ground-truth GNSS diagnostics erişimi kısıtlanabilir.)*

---

# 176. ARCore Diagnostics Screen (ARCore Diagnostics Ekranı)

ARCore diagnostics may display tracking state, pose availability, relative displacement, clock-alignment state, and tracking-loss events. *(ARCore diagnostics tracking durumunu, pose kullanılabilirliğini, göreli yer değiştirmeyi, clock-alignment durumunu ve tracking-loss olaylarını gösterebilir.)*

---

# 177. AI Diagnostics Screen (Yapay Zekâ Diagnostics Ekranı)

AI diagnostics will show the active model identity. *(Yapay zekâ diagnostics aktif model kimliğini gösterecektir.)*

It will show runtime state. *(Runtime durumunu gösterecektir.)*

It will show actual backend, inference latency, latest class, confidence, queue health, and fallback state. *(Gerçek backend'i, inference gecikmesini, son sınıfı, güveni, kuyruk health durumunu ve fallback durumunu gösterecektir.)*

---

# 178. AI Model Hash in Diagnostics (Diagnostics İçerisinde Yapay Zekâ Model Hash'i)

Benchmark diagnostics may expose the model hash for reproducibility verification. *(Benchmark diagnostics tekrarlanabilirlik doğrulaması için model hash'ini gösterebilir.)*

---

# 179. Fusion Diagnostics Screen (Füzyon Diagnostics Ekranı)

Fusion diagnostics may display the current EKF state, selected measurement sources, covariance summary, and rejected measurements. *(Füzyon diagnostics mevcut EKF durumunu, seçilen measurement kaynaklarını, kovaryans özetini ve reddedilen measurement'ları gösterebilir.)*

---

# 180. Covariance Diagnostics (Kovaryans Diagnostics)

Development Mode may display `σE`, `σN`, major ellipse axis, minor ellipse axis, and quality state. *(Development Mode `σE`, `σN`, büyük ellipse ekseni, küçük ellipse ekseni ve kalite durumunu gösterebilir.)*

---

# 181. Storage Diagnostics Screen (Depolama Diagnostics Ekranı)

Storage diagnostics will show active session writer health. *(Depolama diagnostics aktif oturum writer health durumunu gösterecektir.)*

---

# 182. Storage Diagnostic Fields (Depolama Diagnostic Alanları)

Candidate fields include queue depth, maximum queue depth, dropped records, bytes written, write errors, and last successful write time. *(Aday alanlar queue derinliğini, maksimum queue derinliğini, düşürülen kayıtları, yazılan byte miktarını, write error'larını ve son başarılı yazma zamanını içerir.)*

---

# 183. Runtime Diagnostics Screen (Runtime Diagnostics Ekranı)

Runtime diagnostics may show application build, runtime mode, active configuration IDs, memory indicators, and recent critical events. *(Runtime diagnostics uygulama build'ini, runtime modunu, aktif yapılandırma ID'lerini, bellek göstergelerini ve son kritik olayları gösterebilir.)*

---

# 184. Diagnostic Screens Are Read-Only by Default (Diagnostic Ekranlar Varsayılan Olarak Salt Okunurdur)

Diagnostics will primarily observe existing state. *(Diagnostics temel olarak mevcut durumu gözlemleyecektir.)*

They will not silently alter sensor rates, filters, or estimator configuration. *(Sensör hızlarını, filtreleri veya tahmin motoru yapılandırmasını sessizce değiştirmeyecektir.)*

---

# 185. Development Controls (Development Kontrolleri)

Development Mode may expose explicit test controls. *(Development Mode açık test kontrolleri sunabilir.)*

Any control that modifies runtime configuration must produce a traceable event. *(Runtime yapılandırmasını değiştiren her kontrol izlenebilir olay üretmelidir.)*

---

# 186. Settings Screen Purpose (Ayarlar Ekranı Amacı)

The Settings Screen will contain persistent application preferences and experiment defaults. *(Ayarlar Ekranı kalıcı uygulama tercihlerini ve deney varsayılanlarını içerecektir.)*

---

# 187. Settings Categories (Ayar Kategorileri)

```text
General
(Genel)

Navigation
(Navigasyon)

AI
(Yapay Zekâ)

Logging
(Logging)

Map
(Harita)

Diagnostics
(Diagnostics)

About
(Hakkında)
```

---

# 188. Settings Do Not Override Active Benchmark Session (Ayarlar Aktif Benchmark Oturumunun Üzerine Yazmaz)

Changing a global setting while a Benchmark session is active must not silently change the frozen session configuration. *(Benchmark oturumu aktifken global ayarı değiştirmek sabitlenmiş oturum yapılandırmasını sessizce değiştirmemelidir.)*

---

# 189. Settings During Active Session (Aktif Oturum Sırasında Ayarlar)

Many settings will be disabled or read-only during an active formal session. *(Birçok ayar aktif resmî oturum sırasında disabled veya read-only olacaktır.)*

---

# 190. General Settings (Genel Ayarlar)

General settings may include preferred units and basic display behavior. *(Genel ayarlar tercih edilen birimleri ve temel display davranışını içerebilir.)*

---

# 191. Navigation Settings (Navigasyon Ayarları)

Navigation settings may expose only validated configuration profiles rather than low-level algorithm coefficients. *(Navigasyon ayarları düşük seviyeli algoritma katsayıları yerine yalnızca doğrulanmış yapılandırma profillerini sunabilir.)*

---

# 192. AI Settings (Yapay Zekâ Ayarları)

AI settings may show selected model and deployment status. *(Yapay zekâ ayarları seçilen modeli ve deployment durumunu gösterebilir.)*

Development Mode may allow Shadow Mode selection. *(Development Mode Shadow Mode seçimine izin verebilir.)*

---

# 193. Logging Settings (Logging Ayarları)

Logging settings may allow selecting predefined logging profiles. *(Logging ayarları önceden tanımlanmış logging profillerinin seçilmesine izin verebilir.)*

---

# 194. Map Settings (Harita Ayarları)

Map settings may include map visibility or cached local map behavior where supported. *(Harita ayarları desteklendiğinde harita görünürlüğünü veya cache'lenmiş yerel harita davranışını içerebilir.)*

Map availability will never determine whether the estimator can operate. *(Harita kullanılabilirliği tahmin motorunun çalışıp çalışamayacağını hiçbir zaman belirlemeyecektir.)*

---

# 195. About Screen (Hakkında Ekranı)

The About section will show NAVGUARD project identity, application version, build version, and research-prototype disclaimer. *(Hakkında bölümü NAVGUARD proje kimliğini, uygulama sürümünü, build sürümünü ve araştırma prototipi disclaimer'ını gösterecektir.)*

---

# 196. Research Prototype Disclaimer (Araştırma Prototipi Disclaimer'ı)

The application will state that NAVGUARD is a research proof of concept and not a certified navigation system. *(Uygulama NAVGUARD'ın araştırma proof of concept olduğunu ve sertifikalı navigasyon sistemi olmadığını belirtecektir.)*

---

# 197. No Military-Grade Claim (Military-Grade İddiası Olmaması)

The UI and About page will not describe the system as military-grade or certified for safety-critical navigation. *(UI ve Hakkında sayfası sistemi military-grade veya safety-critical navigasyon için sertifikalı olarak tanımlamayacaktır.)*

---

# 198. Error Presentation Philosophy (Hata Sunum Felsefesi)

Errors will be specific, actionable, and proportional to their severity. *(Hatalar spesifik, işlem yapılabilir ve önem seviyeleriyle orantılı olacaktır.)*

---

# 199. Error Severity Levels (Hata Önem Seviyeleri)

```text
INFO
(BİLGİ)

WARNING
(UYARI)

DEGRADED
(BOZULMUŞ)

BLOCKING
(ENGELLEYİCİ)

CRITICAL
(KRİTİK)
```

---

# 200. Info Message (Bilgi Mesajı)

An informational message does not require user intervention. *(Bilgi mesajı kullanıcı müdahalesi gerektirmez.)*

---

# 201. Warning Message (Uyarı Mesajı)

A warning indicates reduced conditions but may allow operation to continue. *(Uyarı azalmış koşulları gösterir ancak çalışmanın devam etmesine izin verebilir.)*

---

# 202. Blocking Error (Engelleyici Hata)

A blocking error prevents the requested state transition. *(Engelleyici hata istenen durum geçişini önler.)*

---

# 203. Critical Error (Kritik Hata)

A critical error indicates that the current formal navigation or evidence integrity cannot continue safely. *(Kritik hata mevcut resmî navigasyonun veya kanıt bütünlüğünün güvenli şekilde devam edemediğini gösterir.)*

---

# 204. Error Messages Must Name the Failing Component (Hata Mesajları Başarısız Bileşeni Adlandırmalıdır)

The message should identify whether the problem is GNSS, ARCore, AI, storage, sensors, permissions, or another subsystem. *(Mesaj problemin GNSS, ARCore, yapay zekâ, depolama, sensörler, permission'lar veya başka alt sistemden kaynaklanıp kaynaklanmadığını tanımlamalıdır.)*

---

# 205. Example Error Style (Örnek Hata Stili)

`ARCore tracking lost — PDR fallback is active.` *( `ARCore tracking lost — PDR fallback is active.` mesajı kullanılabilir.)*

The Turkish UI equivalent will communicate the same meaning clearly. *(Türkçe UI karşılığı aynı anlamı açık şekilde iletecektir.)*

---

# 206. No Generic `Something Went Wrong` for Critical Errors (Kritik Hatalarda Genel `Something Went Wrong` Olmaması)

Generic error wording is insufficient for formal experiment operation. *(Genel hata metni resmî deney çalışması için yetersizdir.)*

---

# 207. Snackbar Use (Snackbar Kullanımı)

Short non-critical notifications may use snackbars or transient banners. *(Kısa kritik olmayan bildirimler snackbar veya geçici banner kullanabilir.)*

---

# 208. Persistent Warning Use (Kalıcı Uyarı Kullanımı)

Long-lived degraded states must use persistent indicators rather than disappearing notifications. *(Uzun süreli degraded durumlar kaybolan bildirimler yerine kalıcı göstergeler kullanmalıdır.)*

---

# 209. Modal Dialog Use (Modal Dialog Kullanımı)

Modal confirmation will be reserved for high-impact actions such as starting denial, stopping a formal session, deleting evidence, or overriding a non-benchmark restriction. *(Modal confirmation kesinti başlatmak, resmî oturumu durdurmak, kanıt silmek veya benchmark dışı kısıtlamayı override etmek gibi yüksek etkili işlemler için ayrılacaktır.)*

---

# 210. Avoid Excessive Confirmation Dialogs (Aşırı Confirmation Dialog'dan Kaçınma)

Routine navigation will not be interrupted by unnecessary confirmation dialogs. *(Rutin navigasyon gereksiz confirmation dialog'larıyla kesilmeyecektir.)*

---

# 211. Haptic Feedback Candidate (Haptic Feedback Adayı)

Important mode transitions may use short haptic feedback if it improves operator awareness. *(Önemli mod geçişleri operatör farkındalığını artırıyorsa kısa haptic feedback kullanabilir.)*

---

# 212. Audio Feedback Candidate (Sesli Geri Bildirim Adayı)

Short tones may optionally indicate start, denial, recovery, or stop transitions. *(Kısa tonlar isteğe bağlı olarak başlangıç, kesinti, recovery veya stop geçişlerini belirtebilir.)*

Audio feedback is optional and must not be required for operation. *(Sesli geri bildirim isteğe bağlıdır ve çalışma için zorunlu olmamalıdır.)*

---

# 213. Accessibility Principle (Erişilebilirlik İlkesi)

Critical system state must not depend solely on color, tiny text, or subtle animation. *(Kritik sistem durumu yalnızca renge, küçük metne veya ince animasyona bağlı olmamalıdır.)*

---

# 214. Touch Target Principle (Dokunma Hedefi İlkesi)

Primary controls will use sufficiently large touch targets for outdoor walking use. *(Temel kontroller dış ortamda yürürken kullanım için yeterince büyük dokunma hedefleri kullanacaktır.)*

---

# 215. Outdoor Readability (Dış Ortam Okunabilirliği)

The Live Navigation Screen will prioritize contrast and readable text in outdoor lighting. *(Canlı Navigasyon Ekranı dış ortam ışığında kontrasta ve okunabilir metne öncelik verecektir.)*

---

# 216. One-Handed Use (Tek Elle Kullanım)

Critical actions will be positioned where they can reasonably be reached during handheld operation. *(Kritik işlemler elde kullanım sırasında makul şekilde erişilebilecek yerlere konumlandırılacaktır.)*

---

# 217. Reduced Cognitive Load (Azaltılmış Bilişsel Yük)

The normal Live Navigation Screen will show only information needed during movement. *(Normal Canlı Navigasyon Ekranı yalnızca hareket sırasında gerekli bilgileri gösterecektir.)*

Technical details will remain in expandable panels or diagnostics. *(Teknik ayrıntılar genişletilebilir panellerde veya diagnostics içerisinde kalacaktır.)*

---

# 218. Screen-On Behavior (Ekranı Açık Tutma Davranışı)

During active formal navigation, the application may keep the screen awake to preserve foreground-first operation and operator visibility. *(Aktif resmî navigasyon sırasında uygulama foreground-first çalışmayı ve operatör görünürlüğünü korumak için ekranı açık tutabilir.)*

The final power policy will be validated in performance testing. *(Nihai güç politikası performans testlerinde doğrulanacaktır.)*

---

# 219. Backgrounding During Active Session (Aktif Oturum Sırasında Arka Plana Alma)

The first implementation will be foreground-first. *(İlk uygulama foreground-first olacaktır.)*

If the app leaves the foreground during a formal session, the behavior will be explicit and logged. *(Uygulama resmî oturum sırasında foreground'dan çıkarsa davranış açık ve loglanmış olacaktır.)*

---

# 220. Background Warning (Arka Plan Uyarısı)

Benchmark Mode may warn or invalidate the session if leaving the foreground violates the frozen protocol. *(Benchmark Mode foreground'dan çıkmak sabitlenmiş protokolü ihlal ediyorsa uyarabilir veya oturumu geçersiz kılabilir.)*

---

# 221. App Lifecycle Restoration (Uygulama Yaşam Döngüsü Geri Yükleme)

Returning to the app must restore the UI from authoritative session state rather than assuming a new session. *(Uygulamaya geri dönmek yeni oturum varsaymak yerine UI'ı ana oturum durumundan geri yüklemelidir.)*

---

# 222. Rotation Handling (Ekran Döndürme Yönetimi)

If orientation changes are allowed, they must not recreate native acquisition or duplicate the active session. *(Ekran yönü değişikliklerine izin verilirse native acquisition'ı yeniden oluşturmamalı veya aktif oturumu duplicate etmemelidir.)*

---

# 223. UI Rebuild Safety (UI Rebuild Güvenliği)

Flutter widget rebuilds must never restart sensors, GNSS acquisition, ARCore, or AI inference unintentionally. *(Flutter widget rebuild'leri sensörleri, GNSS acquisition'ı, ARCore'u veya yapay zekâ çıkarımını yanlışlıkla yeniden başlatmamalıdır.)*

---

# 224. Loading State Principle (Loading State İlkesi)

Long operations will display explicit loading or progress states. *(Uzun işlemler açık loading veya progress durumları gösterecektir.)*

---

# 225. No Fake Progress Percentage (Sahte Progress Yüzdesi Olmaması)

An operation will not show a fabricated percentage when true completion progress is unknown. *(Gerçek tamamlanma ilerlemesi bilinmediğinde işlem uydurulmuş yüzde göstermeyecektir.)*

---

# 226. Readiness Progress (Hazırlık İlerlemesi)

Readiness may show completed versus remaining checks. *(Hazırlık tamamlanan ve kalan kontrolleri gösterebilir.)*

---

# 227. Calibration Progress (Kalibrasyon İlerlemesi)

Calibration may show step-based progress. *(Kalibrasyon adım bazlı progress gösterebilir.)*

---

# 228. Recovery Progress (Recovery İlerlemesi)

Recovery will use state-based progress rather than a fake linear percentage. *(Recovery sahte doğrusal yüzde yerine durum bazlı progress kullanacaktır.)*

---

# 229. Session Finalization Progress (Oturum Finalization İlerlemesi)

Finalization may show named stages instead of an invented completion percentage. *(Finalization uydurulmuş tamamlanma yüzdesi yerine isimlendirilmiş aşamalar gösterebilir.)*

---

# 230. Navigation State Model for UI (UI İçin Navigasyon Durum Modeli)

The UI will consume one immutable navigation snapshot. *(UI tek değişmez navigasyon snapshot'ı kullanacaktır.)*

---

# 231. Candidate `NavigationUiState` (Aday `NavigationUiState`)

```text
NavigationUiState
- sessionId
- runtimeState
- navigationMode
- estimatorProfile
- currentPosition
- positionQuality
- uncertainty
- heading
- headingQuality
- stepCount
- estimatedDistance
- motionState
- arcoreState
- aiState
- gnssState
- deniedDuration
- recoveryState
- loggingState
```

---

# 232. UI State Update Frequency (UI Durum Update Frekansı)

The UI state may update at a lower rate than the estimator. *(UI durumu tahmin motorundan daha düşük hızda update olabilir.)*

---

# 233. Map Rendering Frequency (Harita Render Frekansı)

Map rendering will be throttled or downsampled if necessary for smooth performance. *(Harita render gerekiyorsa akıcı performans için throttle veya downsample edilecektir.)*

This will not alter the underlying estimator state. *(Bu temel tahmin motoru durumunu değiştirmeyecektir.)*

---

# 234. Animation Policy (Animasyon Politikası)

Animations will be subtle and functional. *(Animasyonlar sade ve işlevsel olacaktır.)*

They will not delay critical state changes or hide exact transition timing. *(Kritik durum değişikliklerini geciktirmeyecek veya kesin geçiş zamanlamasını gizlemeyecektir.)*

---

# 235. Map Camera Behavior (Harita Kamera Davranışı)

The map may follow the current estimated position by default. *(Harita varsayılan olarak mevcut tahmini konumu takip edebilir.)*

---

# 236. User Map Pan (Kullanıcı Harita Kaydırma)

The user may temporarily pan or zoom the map. *(Kullanıcı haritayı geçici olarak pan veya zoom yapabilir.)*

---

# 237. Recenter Control (Yeniden Merkezleme Kontrolü)

A visible recenter control will return the map to the current estimate. *(Görünür recenter kontrolü haritayı mevcut tahmine döndürecektir.)*

---

# 238. Recenter Does Not Change Estimator (Yeniden Merkezleme Tahmin Motorunu Değiştirmez)

Map recentering is purely visual. *(Harita yeniden merkezleme tamamen görseldir.)*

---

# 239. Map Rotation Candidate (Harita Döndürme Adayı)

The first implementation may keep map north-up for consistency. *(İlk uygulama tutarlılık için haritayı north-up tutabilir.)*

Heading-up map rotation may be considered later if useful. *(Heading-up harita döndürme kullanışlıysa daha sonra değerlendirilebilir.)*

---

# 240. North-Up Research Benefit (North-Up Araştırma Faydası)

North-up presentation simplifies interpretation of East-North trajectories during testing. *(North-up sunum test sırasında East-North trajectory'lerinin yorumlanmasını basitleştirir.)*

---

# 241. Offline Map Failure (Çevrimdışı Harita Hatası)

If map imagery is unavailable, the navigation estimator will continue operating. *(Harita görüntüsü kullanılamazsa navigasyon tahmin motoru çalışmaya devam edecektir.)*

---

# 242. No Map Available State (Harita Kullanılamıyor Durumu)

The UI may switch to a simplified local trajectory plane when map data is unavailable. *(Harita verisi kullanılamadığında UI sadeleştirilmiş yerel trajectory düzlemine geçebilir.)*

---

# 243. Local ENU Plot Candidate (Yerel ENU Grafik Adayı)

A simple East-North grid can provide offline visualization independent of map tiles. *(Basit East-North grid harita tile'larından bağımsız çevrimdışı görselleştirme sağlayabilir.)*

---

# 244. Map Downloading Is Not Core Navigation (Harita İndirme Temel Navigasyon Değildir)

The project will not make bulk map-tile downloading a prerequisite for core navigation. *(Proje toplu harita tile indirmeyi temel navigasyon için prerequisite haline getirmeyecektir.)*

---

# 245. Session Comparison UX Principle (Oturum Karşılaştırma UX İlkesi)

Comparison views will emphasize reproducible metrics rather than decorative charts. *(Karşılaştırma görünümleri dekoratif grafiklerden çok tekrarlanabilir metriklere vurgu yapacaktır.)*

---

# 246. Graph Interaction (Grafik Etkileşimi)

Charts may support inspection of selected time points. *(Grafikler seçilen zaman noktalarının incelenmesini destekleyebilir.)*

---

# 247. Time Cursor Candidate (Zaman İmleci Adayı)

A shared time cursor may synchronize trajectory, uncertainty, and event plots during post-session analysis. *(Ortak zaman imleci oturum sonrası analiz sırasında trajectory, belirsizlik ve event grafiklerini senkronize edebilir.)*

---

# 248. Benchmark Evidence Lock (Benchmark Kanıt Kilidi)

Completed Benchmark sessions may show a lock indicator that original evidence is immutable. *(Tamamlanmış Benchmark oturumları orijinal kanıtın değişmez olduğunu gösteren lock indicator gösterebilir.)*

---

# 249. Reprocessing Indicator (Yeniden İşleme Göstergesi)

Derived replay or reprocessed results will be visually labeled as derived rather than live. *(Türetilmiş replay veya yeniden işlenmiş sonuçlar canlı yerine türetilmiş olarak görsel etiketlenecektir.)*

---

# 250. Live vs Replay Label (Canlı ile Replay Etiketi)

```text
LIVE
(CANLI)

REPLAY
(REPLAY)

OFFLINE ANALYSIS
(ÇEVRİMDIŞI ANALİZ)
```

---

# 251. Session Export Provenance UX (Oturum Export Köken UX'i)

The export screen will show which session and artifact version are being exported. *(Export ekranı hangi oturumun ve artifact sürümünün export edildiğini gösterecektir.)*

---

# 252. Destructive Action Placement (Destructive İşlem Yerleşimi)

Delete and invalidate actions will not be placed adjacent to common navigation actions. *(Silme ve invalidation işlemleri yaygın navigasyon işlemlerinin hemen yanında yer almayacaktır.)*

---

# 253. Manual Session Invalidation (Manuel Oturum Geçersizleştirme)

Development or Benchmark Mode may allow the operator to mark a session invalid with a reason. *(Development veya Benchmark Mode operatörün oturumu nedenle birlikte geçersiz işaretlemesine izin verebilir.)*

---

# 254. Invalidation Reason Required (Geçersizleştirme Nedeni Zorunludur)

Manual invalidation will require a structured or written reason. *(Manuel invalidation yapılandırılmış veya yazılı neden gerektirecektir.)*

---

# 255. Invalidation Does Not Delete Evidence (Geçersizleştirme Kanıtı Silmez)

Marking a session invalid will not delete its data. *(Oturumu geçersiz işaretlemek verisini silmeyecektir.)*

---

# 256. Benchmark Mode UI Restrictions (Benchmark Modu UI Kısıtlamaları)

Benchmark Mode will minimize opportunities to change experiment configuration mid-session. *(Benchmark Modu oturum ortasında deney yapılandırmasını değiştirme fırsatlarını azaltacaktır.)*

---

# 257. Benchmark Mode Hidden Controls (Benchmark Modunda Gizli Kontroller)

Advanced tuning sliders, model changes, filter changes, and sampling-rate changes will not be available during an active Benchmark session. *(Aktif Benchmark oturumu sırasında gelişmiş tuning slider'ları, model değişiklikleri, filter değişiklikleri ve sampling-rate değişiklikleri kullanılamayacaktır.)*

---

# 258. Development Mode Freedom (Development Modu Esnekliği)

Development Mode may expose more controls for experimentation. *(Development Mode deney için daha fazla kontrol sunabilir.)*

Every significant change must remain logged. *(Her anlamlı değişiklik loglanmış kalmalıdır.)*

---

# 259. Audit Mode (Audit Modu)

Audit Mode will emphasize device, timing, sensor, GNSS, ARCore, AI, and storage diagnostics. *(Audit Modu cihaz, zamanlama, sensör, GNSS, ARCore, yapay zekâ ve depolama diagnostics'ine vurgu yapacaktır.)*

---

# 260. Demo Mode (Demo Modu)

Demo Mode will prioritize clean visualization and simplified operator flow while preserving truthful confidence and mode state. *(Demo Modu doğru güven ve mod durumunu korurken temiz görselleştirmeye ve sadeleştirilmiş operatör akışına öncelik verecektir.)*

---

# 261. Demo Mode Must Not Fake Results (Demo Modu Sonuç Uydurmamalıdır)

Demo Mode may simplify information density but must not fabricate accuracy, confidence, or sensor availability. *(Demo Modu bilgi yoğunluğunu azaltabilir ancak doğruluk, güven veya sensör kullanılabilirliği uydurmamalıdır.)*

---

# 262. System Readiness UX Acceptance Criteria (Sistem Hazırlık UX Kabul Kriterleri)

The user must be able to identify whether the selected configuration can start. *(Kullanıcı seçilen yapılandırmanın başlayıp başlayamayacağını anlayabilmelidir.)*

Blocking requirements must be visually distinct from warnings. *(Blocking gereksinimler uyarılardan görsel olarak ayırt edilebilir olmalıdır.)*

---

# 263. Calibration UX Acceptance Criteria (Kalibrasyon UX Kabul Kriterleri)

Calibration must provide explicit step-by-step guidance. *(Kalibrasyon açık adım adım yönlendirme sağlamalıdır.)*

The UI must not report success before the underlying calibration criteria pass. *(UI temel kalibrasyon kriterleri geçmeden başarı raporlamamalıdır.)*

---

# 264. Live Navigation UX Acceptance Criteria (Canlı Navigasyon UX Kabul Kriterleri)

The current navigation mode must remain visible at all times during an active session. *(Aktif oturum sırasında mevcut navigasyon modu her zaman görünür kalmalıdır.)*

The current position-quality state must remain accessible. *(Mevcut konum kalite durumu erişilebilir kalmalıdır.)*

---

# 265. GNSS-Denied UX Acceptance Criteria (GNSS Kesintili UX Kabul Kriterleri)

Beginning a denied interval must require an explicit user action. *(Kesintili aralığı başlatmak açık kullanıcı işlemi gerektirmelidir.)*

The UI must visibly confirm when estimator GNSS access becomes blocked. *(Tahmin motoru GNSS erişimi blocked hale geldiğinde UI bunu görünür şekilde doğrulamalıdır.)*

---

# 266. Evaluation Mode UX Acceptance Criteria (Evaluation Mode UX Kabul Kriterleri)

Protected ground truth must not be displayed during a blinded denied interval unless the protocol explicitly enables it. *(Protokol açıkça etkinleştirmedikçe korunan ground truth blinded kesintili aralık sırasında gösterilmemelidir.)*

---

# 267. Uncertainty UX Acceptance Criteria (Belirsizlik UX Kabul Kriterleri)

GNSS-denied position must never appear without an associated confidence or uncertainty state. *(GNSS kesintili konum ilişkili güven veya belirsizlik durumu olmadan hiçbir zaman görünmemelidir.)*

---

# 268. Invalid Position UX Acceptance Criteria (Geçersiz Konum UX Kabul Kriterleri)

An invalid position must not continue to be represented as a normal live location marker. *(Geçersiz konum normal canlı location marker olarak temsil edilmeye devam etmemelidir.)*

---

# 269. Recovery UX Acceptance Criteria (Recovery UX Kabul Kriterleri)

Recovery must visibly progress through validation and relocalization states. *(Recovery validation ve relocalization durumları boyunca görünür şekilde ilerlemelidir.)*

Pressing recovery must not instantly present GNSS as accepted. *(Recovery'ye basmak GNSS'i anında kabul edilmiş olarak göstermemelidir.)*

---

# 270. Recovery Evidence UX Acceptance Criteria (Recovery Kanıt UX Kabul Kriterleri)

The interface must not report recovery completion before pre-correction evidence capture and relocalization succeed. *(Arayüz düzeltme öncesi kanıt yakalama ve relocalization başarılı olmadan recovery tamamlandığını raporlamamalıdır.)*

---

# 271. Stop Session UX Acceptance Criteria (Oturumu Durdurma UX Kabul Kriterleri)

Stopping a session must require explicit user intent. *(Oturumu durdurmak açık kullanıcı niyeti gerektirmelidir.)*

The UI must show finalization progress after stopping. *(UI durdurmadan sonra finalization progress göstermelidir.)*

---

# 272. Session Completion UX Acceptance Criteria (Oturum Tamamlama UX Kabul Kriterleri)

The UI must not show `Completed` until final storage integrity checks succeed. *(UI nihai depolama bütünlük kontrolleri başarılı olmadan `Completed` göstermemelidir.)*

---

# 273. Session History UX Acceptance Criteria (Oturum Geçmiş UX Kabul Kriterleri)

Completed, incomplete, and invalid sessions must be distinguishable at a glance. *(Tamamlanmış, tamamlanmamış ve geçersiz oturumlar ilk bakışta ayırt edilebilir olmalıdır.)*

---

# 274. Export UX Acceptance Criteria (Export UX Kabul Kriterleri)

Export must be explicit and must report completion or failure accurately. *(Export açık olmalı ve tamamlanma veya hatayı doğru şekilde raporlamalıdır.)*

---

# 275. Diagnostics UX Acceptance Criteria (Diagnostics UX Kabul Kriterleri)

Diagnostic screens must consume existing authoritative streams rather than creating duplicate sensor or AI runtimes. *(Diagnostic ekranlar duplicate sensör veya yapay zekâ runtime'ları oluşturmak yerine mevcut ana stream'leri kullanmalıdır.)*

---

# 276. Benchmark UX Acceptance Criteria (Benchmark UX Kabul Kriterleri)

Benchmark Mode must prevent accidental modification of frozen experiment parameters during an active session. *(Benchmark Modu aktif oturum sırasında sabitlenmiş deney parametrelerinin yanlışlıkla değiştirilmesini önlemelidir.)*

---

# 277. Accessibility UX Acceptance Criteria (Erişilebilirlik UX Kabul Kriterleri)

Critical state differences must not rely exclusively on color. *(Kritik durum farklılıkları yalnızca renge bağlı olmamalıdır.)*

Primary controls must remain readable and reachable during outdoor handheld operation. *(Temel kontroller dış ortamda elde kullanım sırasında okunabilir ve erişilebilir kalmalıdır.)*

---

# 278. Performance UX Acceptance Criteria (Performans UX Kabul Kriterleri)

UI rendering must not materially delay sensor acquisition, AI inference, PDR, EKF, or logging. *(UI render sensör toplamayı, yapay zekâ çıkarımını, PDR'ı, EKF'yi veya logging'i anlamlı şekilde geciktirmemelidir.)*

---

# 279. UI Test IDs (UI Test ID'leri)

```text
UI-HOME-001   Home readiness summary
UI-HOME-002   Incomplete session warning

UI-SES-001    New session creation
UI-SES-002    Configuration selection
UI-SES-003    Benchmark configuration lock

UI-RDY-001    Ready state
UI-RDY-002    Warning state
UI-RDY-003    Blocking state
UI-RDY-004    Retry action

UI-CAL-001    Stationary calibration guidance
UI-CAL-002    Anchor acquisition
UI-CAL-003    Calibration failure
UI-CAL-004    Calibration success

UI-LIVE-001   Mode banner
UI-LIVE-002   Position marker
UI-LIVE-003   confidence display
UI-LIVE-004   heading display
UI-LIVE-005   motion display
UI-LIVE-006   ARCore state

UI-DEN-001    denial confirmation
UI-DEN-002    denied state visibility
UI-DEN-003    ground-truth hidden
UI-DEN-004    denied timer

UI-UNC-001    uncertainty region
UI-UNC-002    degraded state
UI-UNC-003    invalid position
UI-UNC-004    no false probability label

UI-REC-001    recovery pending
UI-REC-002    reference validation
UI-REC-003    relocalization state
UI-REC-004    recovery timeout
UI-REC-005    successful restoration

UI-STOP-001   stop confirmation
UI-STOP-002   finalization progress
UI-STOP-003   finalization failure

UI-HIS-001    session list
UI-HIS-002    completed/incomplete/invalid distinction
UI-HIS-003    session detail

UI-CMP-001    trajectory comparison
UI-CMP-002    metric comparison
UI-CMP-003    compatibility warning

UI-DIA-001    sensor diagnostics
UI-DIA-002    GNSS diagnostics
UI-DIA-003    ARCore diagnostics
UI-DIA-004    AI diagnostics
UI-DIA-005    storage diagnostics

UI-EXP-001    export
UI-EXP-002    export failure
UI-EXP-003    export completion

UI-ACC-001    state not color-only
UI-ACC-002    readable outdoor layout
UI-ACC-003    touch-target usability

UI-PERF-001   UI does not block estimator
UI-PERF-002   map update throttling
UI-PERF-003   diagnostic chart bounded buffer
```

---

# 280. Minimum Successful UI (Minimum Başarılı UI)

The minimum successful UI will provide Home, Readiness, Calibration, Live Navigation, GNSS-denied activation, confidence display, Recovery, Stop Session, Session History, Session Detail, Diagnostics, Export, and Settings. *(Minimum başarılı UI Ana Sayfa, Hazırlık, Kalibrasyon, Canlı Navigasyon, GNSS kesintili etkinleştirme, güven gösterimi, Recovery, Stop Session, Oturum Geçmişi, Oturum Ayrıntı, Diagnostics, Export ve Ayarlar sağlayacaktır.)*

---

# 281. Target Successful UI (Hedef Başarılı UI)

The target UI will additionally provide covariance visualization, advanced session comparison, synchronized event timelines, richer runtime diagnostics, replay labeling, uncertainty history, and polished Demo Mode presentation. *(Hedef UI ek olarak kovaryans görselleştirmesi, gelişmiş oturum karşılaştırması, senkronize event timeline'ları, daha zengin runtime diagnostics, replay etiketleme, belirsizlik geçmişi ve geliştirilmiş Demo Mode sunumu sağlayacaktır.)*

---

# 282. Optional UI Enhancements (İsteğe Bağlı UI İyileştirmeleri)

Optional enhancements may include heading-up map mode. *(İsteğe bağlı iyileştirmeler heading-up harita modunu içerebilir.)*

Optional enhancements may include haptic transition feedback. *(İsteğe bağlı iyileştirmeler haptic geçiş geri bildirimini içerebilir.)*

Optional enhancements may include synchronized trajectory and metric cursors. *(İsteğe bağlı iyileştirmeler senkronize trajectory ve metrik cursor'larını içerebilir.)*

---

# 283. UI Non-Goals (UI Olmayan Hedefler)

NAVGUARD will not attempt to reproduce the full feature set of Google Maps. *(NAVGUARD Google Maps'in tam özellik setini yeniden oluşturmaya çalışmayacaktır.)*

NAVGUARD will not provide consumer-grade turn-by-turn routing in the minimum research prototype. *(NAVGUARD minimum araştırma prototipinde consumer-grade turn-by-turn routing sağlamayacaktır.)*

NAVGUARD will not hide experimental state transitions behind decorative animations. *(NAVGUARD deneysel durum geçişlerini dekoratif animasyonların arkasında gizlemeyecektir.)*

---

# 284. Additional UI Non-Goals (Ek UI Olmayan Hedefler)

The UI will not perform sensor fusion. *(UI sensör füzyonu gerçekleştirmeyecektir.)*

The UI will not calculate the authoritative position independently. *(UI ana konumu bağımsız olarak hesaplamayacaktır.)*

The UI will not expose ground truth as estimator output. *(UI ground truth'u tahmin motoru çıktısı olarak sunmayacaktır.)*

---

# 285. Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kararlar)

Flutter will own the primary application UI. *(Flutter temel uygulama UI'ının sahibi olacaktır.)*

The UI will consume authoritative domain state rather than owning hardware acquisition. *(UI donanım acquisition'ın sahibi olmak yerine ana domain durumunu kullanacaktır.)*

---

# 286. Navigation Structure Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Navigasyon Yapısı Kararları)

The application will provide distinct Home, Session Setup, Readiness, Calibration, Live Navigation, Recovery, History, Diagnostics, and Settings experiences. *(Uygulama ayrı Ana Sayfa, Oturum Kurulumu, Hazırlık, Kalibrasyon, Canlı Navigasyon, Recovery, Geçmiş, Diagnostics ve Ayarlar deneyimleri sağlayacaktır.)*

---

# 287. Mode Visibility Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Mod Görünürlük Kararları)

The active navigation mode will remain visibly identifiable during every live session. *(Aktif navigasyon modu her canlı oturum sırasında görünür şekilde tanımlanabilir kalacaktır.)*

---

# 288. Denied Mode Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kesintili Mod Kararları)

GNSS-denied operation will begin only through an explicit software action. *(GNSS kesintili çalışma yalnızca açık yazılım işlemi üzerinden başlayacaktır.)*

The UI will visibly confirm that GNSS estimator access has been blocked. *(UI GNSS tahmin motoru erişiminin engellendiğini görünür şekilde doğrulayacaktır.)*

---

# 289. Evaluation Mode Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Evaluation Mode Kararları)

Protected GNSS ground truth will remain hidden during blinded denied-navigation trials by default. *(Korunan GNSS ground truth varsayılan olarak blinded kesintili navigasyon denemeleri sırasında gizli kalacaktır.)*

---

# 290. Position UX Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Konum UX Kararları)

GNSS-denied position will always be accompanied by quality or uncertainty information. *(GNSS kesintili konuma her zaman kalite veya belirsizlik bilgisi eşlik edecektir.)*

The UI will not imply certainty through excessive coordinate precision. *(UI aşırı koordinat hassasiyeti üzerinden kesinlik ima etmeyecektir.)*

---

# 291. Uncertainty Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Belirsizlik Kararları)

The live map will support a visual uncertainty region. *(Canlı harita görsel belirsizlik bölgesini destekleyecektir.)*

Formal probability labels will remain disabled until covariance calibration supports them. *(Resmî olasılık etiketleri kovaryans kalibrasyonu onları destekleyene kadar devre dışı kalacaktır.)*

---

# 292. Recovery UX Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Recovery UX Kararları)

Pressing Recover GNSS will enter a pending validation state rather than immediately correcting position. *(Recover GNSS'e basmak konumu anında düzeltmek yerine pending validation durumuna girecektir.)*

Recovery completion will only be shown after evidence capture and relocalization succeed. *(Recovery tamamlanması yalnızca kanıt yakalama ve relocalization başarılı olduktan sonra gösterilecektir.)*

---

# 293. Stop and Finalization Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Stop ve Finalization Kararları)

Stopping recording and completing the session will remain separate UX states. *(Kaydı durdurmak ile oturumu tamamlamak ayrı UX durumları olarak kalacaktır.)*

---

# 294. History Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Geçmiş Kararları)

Session History will explicitly distinguish completed, incomplete, invalid, and archived sessions where supported. *(Oturum Geçmişi desteklendiğinde tamamlanmış, tamamlanmamış, geçersiz ve arşivlenmiş oturumları açık şekilde ayıracaktır.)*

---

# 295. Diagnostics Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Diagnostics Kararları)

Diagnostics will reuse authoritative sensor, GNSS, ARCore, AI, fusion, and storage streams. *(Diagnostics ana sensör, GNSS, ARCore, yapay zekâ, füzyon ve depolama stream'lerini yeniden kullanacaktır.)*

Opening diagnostics will not create duplicate acquisition or inference pipelines. *(Diagnostics açmak duplicate acquisition veya inference hattı oluşturmayacaktır.)*

---

# 296. Benchmark UX Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Benchmark UX Kararları)

Benchmark Mode will prevent accidental mid-session modification of frozen experiment settings. *(Benchmark Modu sabitlenmiş deney ayarlarının oturum ortasında yanlışlıkla değiştirilmesini önleyecektir.)*

---

# 297. Map Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Harita Kararları)

The map will visualize estimator output but will not modify it. *(Harita tahmin motoru çıktısını görselleştirecek ancak değiştirmeyecektir.)*

Map recentering and visual smoothing will remain display-only operations. *(Harita recenter ve görsel smoothing yalnızca display işlemleri olarak kalacaktır.)*

---

# 298. Accessibility Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Erişilebilirlik Kararları)

Critical navigation states will not be communicated through color alone. *(Kritik navigasyon durumları yalnızca renk üzerinden iletilmeyecektir.)*

---

# 299. Performance Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Performans Kararları)

UI refresh rate and map rendering cadence will remain independent from high-frequency estimator execution. *(UI refresh hızı ve harita render kadansı yüksek frekanslı tahmin motoru çalışmasından bağımsız kalacaktır.)*

---

# 300. Decisions Pending UI Prototype Testing (UI Prototip Testlerini Bekleyen Kararlar)

The final visual theme remains pending implementation prototype evaluation. *(Nihai görsel tema uygulama prototipi değerlendirmesini beklemektedir.)*

The final map component layout remains pending Redmi Note 9 Pro screen testing. *(Nihai harita bileşeni layout'u Redmi Note 9 Pro ekran testlerini beklemektedir.)*

---

# 301. Decisions Pending Uncertainty Calibration (Belirsizlik Kalibrasyonunu Bekleyen Kararlar)

The final user-facing confidence labels and numerical uncertainty presentation remain pending Page 28 calibration results. *(Nihai kullanıcıya gösterilen güven etiketleri ve sayısal belirsizlik sunumu Page 28 kalibrasyon sonuçlarını beklemektedir.)*

---

# 302. Decisions Pending Field Usability Tests (Saha Kullanılabilirlik Testlerini Bekleyen Kararlar)

The final placement of Denial, Recovery, and Stop controls remains pending walking-use tests. *(Denial, Recovery ve Stop kontrollerinin nihai yerleşimi yürüyüş kullanım testlerini beklemektedir.)*

---

# 303. Decisions Pending Map Evaluation (Harita Değerlendirmesini Bekleyen Kararlar)

The final choice between covariance ellipse and conservative circular uncertainty visualization remains pending Flutter map rendering evaluation. *(Kovaryans ellipse'i ile temkinli dairesel belirsizlik görselleştirmesi arasındaki nihai seçim Flutter harita render değerlendirmesini beklemektedir.)*

---

# 304. Decisions Pending Background Behavior Tests (Arka Plan Davranış Testlerini Bekleyen Kararlar)

The final policy for app backgrounding during formal sessions remains pending Android lifecycle and reliability testing. *(Resmî oturumlar sırasında uygulamanın background'a alınması için nihai politika Android lifecycle ve güvenilirlik testlerini beklemektedir.)*

---

# 305. Final Mobile UI/UX Architecture Statement (Nihai Mobil UI/UX Mimarisi Bildirimi)

**NAVGUARD will use a Flutter-based research-oriented mobile interface in which the user can always identify the active navigation mode, current estimate source, position quality, uncertainty state, session status, and availability of critical subsystems without requiring access to low-level sensor internals.** *(NAVGUARD kullanıcının düşük seviyeli sensör ayrıntılarına erişmesi gerekmeden aktif navigasyon modunu, mevcut tahmin kaynağını, konum kalitesini, belirsizlik durumunu, oturum durumunu ve kritik alt sistemlerin kullanılabilirliğini her zaman tanımlayabildiği Flutter tabanlı araştırma odaklı mobil arayüz kullanacaktır.)*

**The normal experiment flow will proceed through Home → New Session → Readiness Check → Calibration → Live Navigation → optional GNSS Denial → controlled Recovery → Session Finalization → Session Summary, ensuring that each state transition remains explicit and auditable.** *(Normal deney akışı Ana Sayfa → Yeni Oturum → Hazırlık Kontrolü → Kalibrasyon → Canlı Navigasyon → isteğe bağlı GNSS Kesintisi → kontrollü Recovery → Oturum Finalization → Oturum Özeti şeklinde ilerleyecek ve her durum geçişinin açık ve denetlenebilir kalmasını sağlayacaktır.)*

**During GNSS-denied navigation, the current NAVGUARD estimate will be displayed together with explicit confidence or uncertainty, while protected Evaluation Mode GNSS ground truth will remain hidden by default during blinded formal trials and will never be visually confused with estimator output.** *(GNSS kesintili navigasyon sırasında mevcut NAVGUARD tahmini açık güven veya belirsizlikle birlikte gösterilirken korunan Evaluation Mode GNSS ground truth blinded resmî denemeler sırasında varsayılan olarak gizli kalacak ve hiçbir zaman tahmin motoru çıktısıyla görsel olarak karıştırılmayacaktır.)*

**Recovery will appear as a visible multi-stage workflow rather than an instantaneous switch, and the interface will not report GNSS restoration until recovery validation, pre-correction evidence capture, error recording, relocalization, and estimator authorization restoration have completed in the required order.** *(Recovery anlık geçiş yerine görünür çok aşamalı workflow olarak sunulacak ve arayüz recovery validation, düzeltme öncesi kanıt yakalama, hata kaydı, relocalization ve tahmin motoru authorization geri açılması gerekli sırada tamamlanmadan GNSS'in geri yüklendiğini raporlamayacaktır.)*

**Session completion will remain distinct from recording stop, so the UI will show explicit finalization while logging queues are drained, artifacts are closed, integrity checks are performed, and the portable session manifest is finalized before the session can appear as completed.** *(Oturum tamamlama kayıt durdurmadan ayrı kalacak, böylece UI oturum tamamlanmış görünebilmeden önce logging kuyrukları drain edilirken, artifact'lar kapatılırken, bütünlük kontrolleri gerçekleştirilirken ve taşınabilir oturum manifest'i finalize edilirken açık finalization gösterecektir.)*

**Post-session views will preserve the separation between baseline PDR, fused NAVGUARD, and independent GNSS ground truth, allowing trajectory comparison, event-timeline inspection, uncertainty analysis, recovery evaluation, integrity review, export, and replay provenance without modifying the original live evidence.** *(Oturum sonrası görünümler temel PDR, füzyonlu NAVGUARD ve bağımsız GNSS ground truth arasındaki ayrımı koruyacak; böylece orijinal canlı kanıtı değiştirmeden trajectory karşılaştırması, event timeline incelemesi, belirsizlik analizi, recovery değerlendirmesi, bütünlük incelemesi, export ve replay köken takibi yapılabilecektir.)*

**Benchmark Mode will prioritize experimental integrity by locking mutable configuration controls during active sessions, while Development and Audit modes may expose richer diagnostics and test controls whose changes remain explicitly logged.** *(Benchmark Modu aktif oturumlar sırasında değiştirilebilir yapılandırma kontrollerini kilitleyerek deneysel bütünlüğe öncelik verecek, Development ve Audit modları ise değişiklikleri açık şekilde loglanmış kalan daha zengin diagnostics ve test kontrolleri sunabilecektir.)*

**The Live Navigation UI will remain intentionally simpler than the internal system, exposing only information useful during movement while detailed sensor rates, timing, GNSS diagnostics, ARCore state, AI runtime, EKF covariance, writer queues, and other engineering evidence remain available through dedicated diagnostic screens.** *(Canlı Navigasyon UI'ı bilinçli olarak dahili sistemden daha sade kalacak, hareket sırasında yalnızca kullanışlı bilgileri sunarken ayrıntılı sensör hızları, zamanlama, GNSS diagnostics, ARCore durumu, yapay zekâ runtime'ı, EKF kovaryansı, writer kuyrukları ve diğer mühendislik kanıtları özel diagnostic ekranları üzerinden kullanılabilir kalacaktır.)*

---

# 306. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development Mobile UI/UX Specification Completed *(Doküman Durumu: Geliştirme Öncesi Mobil UI/UX Spesifikasyonu Tamamlandı)*

**Primary UI Framework:** Flutter *(Temel UI Framework'ü: Flutter)*

**Primary Target Orientation:** Portrait *(Temel Hedef Yönelim: Dikey)*

**Primary Target Device:** Xiaomi Redmi Note 9 Pro *(Temel Hedef Cihaz: Xiaomi Redmi Note 9 Pro)*

**UI Architecture:** Domain-State Consumer *(UI Mimarisi: Domain-State Consumer)*

**Direct Sensor Ownership by UI:** Forbidden *(UI Tarafından Doğrudan Sensör Sahipliği: Yasak)*

**Primary Screens:** Home + Session Setup + Readiness + Calibration + Live Navigation + Recovery + History + Diagnostics + Settings *(Temel Ekranlar: Ana Sayfa + Oturum Kurulumu + Hazırlık + Kalibrasyon + Canlı Navigasyon + Recovery + Geçmiş + Diagnostics + Ayarlar)*

**Active Mode Visibility:** Mandatory *(Aktif Mod Görünürlüğü: Zorunlu)*

**GNSS-Denied Activation:** Explicit User Action *(GNSS Kesintili Etkinleştirme: Açık Kullanıcı İşlemi)*

**Denial Confirmation in Benchmark Mode:** Target *(Benchmark Modunda Kesinti Onayı: Hedef)*

**Ground Truth Visibility During Blinded Evaluation:** Hidden *(Blinded Evaluation Sırasında Ground Truth Görünürlüğü: Gizli)*

**Estimated Position Confidence:** Mandatory *(Tahmini Konum Güveni: Zorunlu)*

**Uncertainty Visualization:** Supported *(Belirsizlik Görselleştirmesi: Destekleniyor)*

**Formal Confidence Percentage Without Calibration:** Forbidden *(Kalibrasyon Olmadan Resmî Güven Yüzdesi: Yasak)*

**Position Marker During Invalid State:** Must Not Appear Normal *(Geçersiz Durumda Konum Marker'ı: Normal Görünmemeli)*

**Motion State Display:** Supported *(Hareket Durumu Gösterimi: Destekleniyor)*

**ARCore State Display:** Supported *(ARCore Durum Gösterimi: Destekleniyor)*

**Recovery UX:** Multi-Stage *(Recovery UX: Çok Aşamalı)*

**Instant GNSS Restore on Recovery Tap:** Forbidden *(Recovery Dokunmasında Anında GNSS Geri Açılması: Yasak)*

**Pre-Correction Evidence Before Recovery Completion:** Mandatory *(Recovery Tamamlanmadan Önce Düzeltme Öncesi Kanıt: Zorunlu)*

**Stop Session Confirmation:** Required for Formal Sessions *(Stop Session Onayı: Resmî Oturumlar İçin Gerekli)*

**Recording Stop and Session Completion:** Separate States *(Kayıt Durdurma ve Oturum Tamamlama: Ayrı Durumlar)*

**Finalization Progress:** Visible *(Finalization İlerlemesi: Görünür)*

**Session History:** Mandatory *(Oturum Geçmişi: Zorunlu)*

**Completed / Incomplete / Invalid Distinction:** Mandatory *(Completed / Incomplete / Invalid Ayrımı: Zorunlu)*

**Session Detail:** Supported *(Oturum Ayrıntı: Destekleniyor)*

**Trajectory Comparison:** Target *(Trajectory Karşılaştırma: Hedef)*

**Event Timeline:** Target *(Event Timeline: Hedef)*

**Session Export UI:** Mandatory *(Oturum Export UI: Zorunlu)*

**Raw Evidence Editing:** Forbidden *(Ham Kanıt Düzenleme: Yasak)*

**Diagnostics:** Dedicated Area *(Diagnostics: Özel Alan)*

**Diagnostics Creating Duplicate Sensors:** Forbidden *(Diagnostics Duplicate Sensör Oluşturması: Yasak)*

**Diagnostics Creating Duplicate AI Runtime:** Forbidden *(Diagnostics Duplicate Yapay Zekâ Runtime Oluşturması: Yasak)*

**Benchmark Configuration Editing During Active Session:** Forbidden *(Aktif Oturumda Benchmark Yapılandırma Düzenleme: Yasak)*

**Map Role:** Visualization Only *(Harita Rolü: Yalnızca Görselleştirme)*

**Hidden Road Snapping:** Forbidden *(Gizli Road Snapping: Yasak)*

**UI Map Smoothing Affecting Metrics:** Forbidden *(UI Harita Smoothing'in Metrikleri Etkilemesi: Yasak)*

**UI Refresh Coupled to Sensor Sampling:** Forbidden *(UI Refresh'in Sensör Sampling'e Bağlanması: Yasak)*

**Outdoor Readability:** Required *(Dış Ortam Okunabilirliği: Gerekli)*

**Critical State Communicated by Color Only:** Forbidden *(Kritik Durumun Yalnızca Renkle İletilmesi: Yasak)*

**Background Operation:** Foreground-First *(Arka Plan Çalışması: Foreground-First)*

**Final Visual Theme:** Pending Prototype *(Nihai Görsel Tema: Prototip Bekleniyor)*

**Final Live Control Placement:** Pending Walking Usability Test *(Nihai Canlı Kontrol Yerleşimi: Yürüyüş Kullanılabilirlik Testi Bekleniyor)*

**Final Confidence Labels:** Pending Uncertainty Calibration *(Nihai Güven Etiketleri: Belirsizlik Kalibrasyonu Bekleniyor)*

**Final Ellipse vs Circular Uncertainty UI:** Pending Flutter Map Evaluation *(Nihai Ellipse vs Dairesel Belirsizlik UI: Flutter Harita Değerlendirmesi Bekleniyor)*

**Final Backgrounding Policy:** Pending Android Lifecycle Testing *(Nihai Background Politikası: Android Lifecycle Testi Bekleniyor)*

**Next Documentation Item:** 32 — Permissions, Privacy & Security *(Sonraki Dokümantasyon Öğesi: 32 — İzinler, Gizlilik ve Güvenlik)*
