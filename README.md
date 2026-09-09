# NAVGUARD

AI-Assisted GNSS-Denied Mobile Navigation & Sensor Fusion System.

NAVGUARD is an Android-based research and development project focused on pedestrian navigation continuity using smartphone sensors and on-device processing.

## English

### Status

The technical documentation baseline and Stage 1 Flutter Android bootstrap are complete. Stage 2A SensorManager runtime capability inventory is implemented and physically verified on the Xiaomi Redmi Note 9 Pro. Stage 2B live SensorEvent timing diagnostics are implemented and physically verified for the tested accelerometer, gyroscope, magnetometer, and rotation-vector scope: all 12 sessions produced valid, monotonic timing summaries, with 0/12 sessions containing a gap above the provisional 60 ms sensor threshold.

Stage 2C GNSS runtime timing diagnostics are implemented, statically verified, final-audited, and physically verified for the tested diagnostic scope. Three of three formal GPS_PROVIDER sessions produced valid, monotonic Location.elapsedRealtimeNanos summaries with no mock locations. With a requested minimum interval of 1,000 ms, all three sessions had 1.000 s median and p95 intervals; the observed mean timestamp-derived rate range was approximately 0.983–1.000 Hz, and one 2.000 s consecutive callback interval occurred. Requested timing therefore remains distinct from delivered timing and does not guarantee fixed 1 Hz delivery.

Stage 2D ARCore runtime tracking diagnostics are implemented, statically verified, final-audited, and physically verified for the tested scope. Three of three physical sessions were valid, reached real `TrackingState.TRACKING`, exposed local-session pose, and had monotonic `Frame.timestamp` sequences. The observed unique-frame rate was approximately 30.0295–30.0304 Hz and the tested-session tracking fraction was approximately 98.15%–98.36% across stationary, rotational, and rightward walking scenarios.

Stage 3A — GNSS Anchor + Local ENU Reference Foundation is implemented and statically validated. All 32 tests passed and the debug APK build and diff-integrity check passed. Three of three physical `GPS_PROVIDER` anchor acquisitions succeeded on the tested device; explicit clear/reacquire and acquisition cancellation also passed. The WGS84 → ECEF → local ENU foundation is implemented, including horizontal ENU without a fabricated Up component when altitude is unavailable.

Stage 3B — Heading / True-North Reference Foundation is implemented and statically validated across six source/test paths. `flutter analyze`, all 61/61 tests, the debug APK build, and `git diff --check` passed. Three of three formal physical heading sessions succeeded on the tested device with approximately 51.14 Hz delivered under a 50 Hz nominal request. Clockwise-positive handset-heading behavior, circular continuity across the 0 / 2π boundary, the locked-anchor `android.hardware.GeomagneticField` correction path, and explicit cancellation were physically observed.

Stage 3C — Step-Event Foundation is implemented, statically validated across seven implementation paths, and physically verified for its defined diagnostic scope. `Sensor.TYPE_STEP_DETECTOR` is the only formal step source, `SensorEvent.timestamp` is the step-timing authority, and the Android 12 / API 31 runtime path uses `android.permission.ACTIVITY_RECOGNITION`. `flutter analyze --no-pub`, all 97/97 tests, the debug APK build, and `git diff --check` passed. One stationary 30-second session accepted zero events, a controlled 20-step walk accepted 16 events while five events were excluded by the formal session-window filter, and a controlled 30-step walk accepted 30 events. Both walking sessions had zero duplicate and zero non-monotonic accepted timestamps; explicit cancellation was also verified. These limited observations do not validate general step-detection accuracy.

Stage 4 — Baseline PDR is implemented, statically validated across six implementation/test paths, and physically verified for its defined diagnostic scope. It causally associates each accepted `TYPE_STEP_DETECTOR` event with the latest valid `TYPE_ROTATION_VECTOR` true-north-corrected handset heading at or before the step's `SensorEvent.timestamp`; future headings and interpolation are prohibited. A fixed, uncalibrated, unvalidated 0.75 m research baseline produces horizontal local ENU displacement using `ΔE = L × sin(ψ)` and `ΔN = L × cos(ψ)`. `flutter analyze --no-pub`, all 118/118 tests, the debug APK build, and `git diff --check` passed.

Physical verification on the Xiaomi Redmi Note 9 Pro included a stationary 30-second session with zero accepted/integrated steps; two manually counted 20-step straight walks with 20 associated/integrated steps each; an intended 20-step L-shaped walk with 22 detected/associated events; an independent corrected north check; and explicit `baseline_pdr_cancelled` cancellation. The initial absolute-direction concern was resolved when the user determined that the first walking reference direction had been chosen incorrectly; no Stage 4 heading-axis defect was established. These observations verify the defined runtime flow, causal association, local-ENU integration, and cancellation, but do not validate PDR, step-detection, step-length, heading, true-north, or physical-distance accuracy.

Stage 5 — ARCore Relative Motion → ENU Foundation is implemented, statically validated across six implementation/test paths, and physically verified for its defined diagnostic scope. It uses `Frame.getAndroidSensorPose()` in the Android sensor frame (+X right, +Y physical top edge, +Z outward from the screen), creates a local runtime ARCore anchor after a 2-second stationary-assumed alignment, and computes `anchor.pose.inverse().compose(currentAndroidSensorPose)`. The frozen initial device-to-true-ENU rotation uses `TYPE_ROTATION_VECTOR` plus `android.hardware.GeomagneticField` declination. The formal movement window is 30 seconds. `SensorEvent.timestamp` and `Frame.getTimestamp()` remain separate authorities; no numeric cross-clock comparison is performed. `flutter analyze --no-pub`, all 141/141 tests, the debug APK build, and `git diff --check` passed.

Physical Stage 5 verification on the Xiaomi Redmi Note 9 Pro running Android 12 / API 31 passed for the defined scope. The stationary session used 900/900 tracking/usable frames and ended about 0.081 m horizontally from the segment origin, with about 0.100 m maximum horizontal excursion. The north-like walk ended at approximately `E = 1.507 m, N = 8.223 m`; the east-like walk ended at approximately `E = 9.129 m, N = -1.176 m` and recorded one duplicate AR frame timestamp without a non-monotonic timestamp. The approximate 90-degree in-place rotation ended at about 0.503 m horizontal displacement, substantially below the approximately 8–9 m straight-walk displacements. Explicit cancellation returned `arcore_enu_cancelled`. Completed formal sessions had `trackingFraction = 1.0` with no observed `PAUSED` or `STOPPED` frames; this is scoped evidence, not a universal tracking guarantee.

Overall NAVGUARD physical verification remains **PARTIAL** and the device baseline is **NOT FROZEN**. ARCore relative motion and the ARCore-to-ENU transform are **IMPLEMENTED**, but ARCore position, distance, ENU-alignment, vertical, heading, and true-north accuracy remain **NOT VALIDATED**. Body heading, handset-to-body calibration, ARCore/PDR fusion, the Ground Truth Firewall, Quality Engine, EKF / Sensor Fusion, GNSS denial/recovery, and full GNSS-denied navigation remain **NOT IMPLEMENTED**. Stage 6 — Evaluation Mode + Ground Truth Firewall is the next planned technical milestone, not an implemented feature.

### Platform

* Android
* Xiaomi Redmi Note 9 Pro
* Flutter / Dart
* Kotlin
* Python

### Documentation

Project documentation is maintained under the `docs/` directory.

## Türkçe

### Durum

Teknik dokümantasyon baseline'ı ve Stage 1 Flutter Android bootstrap tamamlandı. Stage 2A SensorManager çalışma zamanı yetenek envanteri Xiaomi Redmi Note 9 Pro üzerinde uygulandı ve fiziksel olarak doğrulandı. Stage 2B canlı `SensorEvent` zamanlama tanıları, test edilen ivmeölçer, jiroskop, manyetometre ve dönüş vektörü kapsamında uygulandı ve fiziksel olarak doğrulandı: 12 oturumun tamamı geçerli ve monotonik zamanlama özetleri üretti; 0/12 oturumda geçici 60 ms sensör eşiğinin üzerinde boşluk vardı.

Stage 2C GNSS çalışma zamanı zamanlama tanıları uygulandı, statik olarak doğrulandı, nihai denetimden geçti ve test edilen tanı kapsamında fiziksel olarak doğrulandı. Üç resmî `GPS_PROVIDER` oturumunun 3/3'ü geçerli, monotonik ve mock içermeyen `Location.elapsedRealtimeNanos` özetleri üretti. Talep edilen minimum aralık 1.000 ms iken üç oturumun tümünde medyan ve p95 aralık 1,000 s; gözlenen ortalama timestamp-türevli hız yaklaşık 0,983–1,000 Hz idi ve ardışık bir 2,000 s callback aralığı gözlendi. Talep edilen zamanlama, sabit 1 Hz teslim garantisi değildir.

Stage 2D ARCore çalışma zamanı takip tanıları uygulandı, statik olarak doğrulandı, nihai denetimden geçti ve test edilen kapsamda fiziksel olarak doğrulandı. Üç fiziksel oturumun 3/3'ü geçerliydi; gerçek `TrackingState.TRACKING` durumuna ulaştı, yerel-oturum pozu sağladı ve monotonik `Frame.timestamp` dizileri üretti. Sabit, dönüş ve sağa yürüme senaryolarında gözlenen benzersiz-kare hızı yaklaşık 30,0295–30,0304 Hz, tracking fraction ise yaklaşık %98,15–%98,36 idi.

Aşama 3A — GNSS Anchor + Yerel ENU Referans Temeli uygulandı ve statik olarak doğrulandı. 32 testin tamamı, debug APK build'i ve diff bütünlüğü kontrolü geçti. Test cihazındaki üç fiziksel `GPS_PROVIDER` anchor ediniminin 3/3'ü başarılı oldu; açık clear/reacquire ve edinim iptali de geçti. WGS84 → ECEF → yerel ENU temeli, yükseklik yokken uydurma bir Up bileşeni üretmeden yatay ENU sağlayacak şekilde uygulandı.

Aşama 3B — Heading / Gerçek Kuzey Referans Temeli altı kaynak/test yolu kapsamında uygulandı ve statik olarak doğrulandı. `flutter analyze`, 61/61 testin tamamı, debug APK build'i ve `git diff --check` geçti. Test cihazındaki üç resmî fiziksel heading oturumunun 3/3'ü başarılı oldu; nominal 50 Hz talep altında yaklaşık 51,14 Hz teslim gözlendi. Saat yönünde pozitif telefon-heading davranışı, 0 / 2π sınırındaki dairesel süreklilik, kilitli anchor kullanan `android.hardware.GeomagneticField` düzeltme yolu ve açık iptal fiziksel olarak gözlendi.

Aşama 3C — Adım Olayı Temeli yedi uygulama yolu kapsamında uygulandı, statik olarak doğrulandı ve tanımlı tanı kapsamında fiziksel olarak doğrulandı. `Sensor.TYPE_STEP_DETECTOR` tek resmî adım kaynağıdır, adım zamanlaması otoritesi `SensorEvent.timestamp` değeridir ve Android 12 / API 31 çalışma zamanı yolu `android.permission.ACTIVITY_RECOGNITION` iznini kullanır. `flutter analyze --no-pub`, 97/97 testin tamamı, debug APK build'i ve `git diff --check` geçti. Sabit 30 saniyelik bir oturum sıfır olay kabul etti; kontrollü 20 adımlık yürüyüş 16 olay kabul ederken beş olay resmî oturum-penceresi filtresiyle dışlandı ve kontrollü 30 adımlık yürüyüş 30 olay kabul etti. İki yürüyüş oturumunda da kabul edilen zaman damgalarında duplicate veya monotonik olmayan değer yoktu; açık iptal de doğrulandı. Bu sınırlı gözlemler genel adım-algılama doğruluğunu doğrulamaz.

Aşama 4 — Temel PDR altı uygulama/test yolu kapsamında uygulandı, statik olarak doğrulandı ve tanımlı tanı kapsamında fiziksel olarak doğrulandı. Her kabul edilen `TYPE_STEP_DETECTOR` olayı, adımın `SensorEvent.timestamp` değerinde veya öncesindeki en yeni geçerli `TYPE_ROTATION_VECTOR` gerçek-kuzey-düzeltilmiş telefon heading'i ile nedensel olarak ilişkilendirilir; gelecek heading ve interpolasyon yasaktır. Sabit, kalibre edilmemiş ve doğrulanmamış 0,75 m araştırma baseline'ı `ΔE = L × sin(ψ)` ve `ΔN = L × cos(ψ)` ile yatay yerel ENU yer değiştirmesi üretir. `flutter analyze --no-pub`, 118/118 testin tamamı, debug APK build'i ve `git diff --check` geçti.

Xiaomi Redmi Note 9 Pro üzerindeki fiziksel doğrulama; sıfır kabul edilen/entegre adımlı sabit 30 saniyelik oturumu, her birinde 20 ilişkilendirilmiş/entegre adım bulunan manuel sayılmış iki 20-adımlık düz yürüyüşü, 22 algılanan/ilişkilendirilen olay üreten hedeflenmiş 20-adımlık L-biçimli yürüyüşü, bağımsız düzeltilmiş kuzey kontrolünü ve açık `baseline_pdr_cancelled` iptalini içerdi. İlk mutlak-yön endişesi, kullanıcının ilk yürüyüş referans yönünü fiziksel olarak yanlış seçtiğini belirlemesiyle çözüldü; Stage 4 heading-ekseni hatası saptanmadı. Bu gözlemler tanımlı çalışma zamanı akışını, nedensel ilişkilendirmeyi, yerel-ENU entegrasyonunu ve iptali doğrular; PDR, adım-algılama, adım-uzunluğu, heading, gerçek-kuzey veya fiziksel-mesafe doğruluğunu doğrulamaz.

Aşama 5 — ARCore Göreli Hareket → ENU Temeli altı uygulama/test yolu kapsamında uygulandı, statik olarak doğrulandı ve tanımlı tanı kapsamında fiziksel olarak doğrulandı. Android sensör çerçevesinde (+X sağ, +Y fiziksel üst kenar, +Z ekrandan dışarı) `Frame.getAndroidSensorPose()` kullanılır; sabitliğin varsayıldığı 2 saniyelik hizalamadan sonra yerel çalışma zamanı ARCore anchor'ı oluşturulur ve `anchor.pose.inverse().compose(currentAndroidSensorPose)` hesaplanır. Sabitlenen ilk-cihazdan-gerçek-ENU'ya dönüş, `TYPE_ROTATION_VECTOR` ile `android.hardware.GeomagneticField` declination düzeltmesini kullanır. Resmî hareket penceresi 30 saniyedir. `SensorEvent.timestamp` ile `Frame.getTimestamp()` ayrı otoritelerdir; sayısal cross-clock karşılaştırması yapılmaz. `flutter analyze --no-pub`, 141/141 testin tamamı, debug APK build'i ve `git diff --check` geçti.

Android 12 / API 31 çalıştıran Xiaomi Redmi Note 9 Pro üzerindeki fiziksel Stage 5 doğrulaması tanımlı kapsamda geçti. Sabit oturum 900/900 takip/kullanılabilir kare kullandı; segment başlangıcından yaklaşık 0,081 m yatay uzaklıkta sonlandı ve yaklaşık 0,100 m maksimum yatay sapma gösterdi. Kuzey-benzeri yürüyüş yaklaşık `E = 1,507 m, N = 8,223 m`; doğu-benzeri yürüyüş yaklaşık `E = 9,129 m, N = -1,176 m` ile sonlandı ve monotonik olmayan zaman damgası olmadan bir duplicate AR kare zaman damgası kaydetti. Yaklaşık 90 derecelik yerinde dönüş yaklaşık 0,503 m yatay yer değiştirmeyle, yaklaşık 8–9 m düz-yürüyüş yer değiştirmelerinden belirgin biçimde düşük kaldı. Açık iptal `arcore_enu_cancelled` döndürdü. Tamamlanan resmî oturumlarda `trackingFraction = 1.0` idi ve `PAUSED` veya `STOPPED` kare gözlenmedi; bu kapsamlı bir evrensel takip garantisi değildir.

Genel NAVGUARD fiziksel doğrulaması **KISMİ** durumdadır ve cihaz baseline'ı **SABİTLENMEMİŞTİR**. ARCore göreli hareketi ve ARCore-to-ENU dönüşümü **UYGULANDI**; ancak ARCore konum, mesafe, ENU hizalama, dikey, heading ve gerçek-kuzey doğruluğu **DOĞRULANMAMIŞTIR**. Body heading, telefon-vücut kalibrasyonu, ARCore/PDR füzyonu, Ground Truth Firewall, Quality Engine, EKF / Sensör Füzyonu, GNSS kesinti/recovery ve tam GNSS-kesintili navigasyon **UYGULANMAMIŞTIR**. Aşama 6 — Değerlendirme Modu + Ground Truth Firewall planlanan sonraki teknik kilometre taşıdır; uygulanmış bir özellik değildir.

### Platform

* Android
* Xiaomi Redmi Note 9 Pro
* Flutter / Dart
* Kotlin
* Python

### Dokümantasyon

Proje dokümantasyonu `docs/` dizini altında tutulur.
