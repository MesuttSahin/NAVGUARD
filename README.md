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

Heading absolute accuracy, true-north absolute accuracy, and step-detection accuracy remain **NOT VALIDATED**. Stage 3B represents handset heading using the phone's physical top edge (+Y), not body heading; body heading and handset-to-body calibration are **NOT IMPLEMENTED**. GNSS absolute coordinate accuracy and physical ENU distance accuracy also remain **NOT VALIDATED**. Overall physical verification remains **PARTIAL** and the device baseline is **NOT FROZEN**. Step length, PDR position, heading-step association, ARCore-to-ENU alignment, the Ground Truth Firewall, Quality Engine, EKF / Sensor Fusion, GNSS denial/recovery, and full GNSS-denied navigation remain unimplemented or unmeasured as applicable. Stage 3C is a step-event foundation, not PDR.

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

Heading mutlak doğruluğu, gerçek-kuzey mutlak doğruluğu ve adım-algılama doğruluğu **DOĞRULANMAMIŞTIR**. Stage 3B, body heading yerine telefonun fiziksel üst kenarını (+Y) kullanan handset heading'i temsil eder; body heading ve telefon-vücut kalibrasyonu **UYGULANMAMIŞTIR**. GNSS mutlak koordinat doğruluğu ve fiziksel ENU mesafe doğruluğu da **DOĞRULANMAMIŞTIR**. Genel fiziksel doğrulama **KISMİ** durumdadır ve cihaz baseline'ı **SABİTLENMEMİŞTİR**. Adım uzunluğu, PDR konumu, heading-adım ilişkilendirmesi, ARCore-to-ENU hizalama, Ground Truth Firewall, Quality Engine, EKF / Sensör Füzyonu, GNSS kesinti/recovery ve tam GNSS-kesintili navigasyon duruma göre uygulanmamış veya ölçülmemiştir. Stage 3C bir adım-olayı temelidir; PDR değildir.

### Platform

* Android
* Xiaomi Redmi Note 9 Pro
* Flutter / Dart
* Kotlin
* Python

### Dokümantasyon

Proje dokümantasyonu `docs/` dizini altında tutulur.
