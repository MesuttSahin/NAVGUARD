# 33 — Testing Strategy (Test Stratejisi)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the complete verification and validation strategy for NAVGUARD across software, sensors, timing, navigation algorithms, artificial intelligence, ARCore, GNSS isolation, recovery, storage, user interface, performance, replay, and field operation. *(Bu doküman NAVGUARD için yazılım, sensörler, zamanlama, navigasyon algoritmaları, yapay zekâ, ARCore, GNSS izolasyonu, recovery, depolama, kullanıcı arayüzü, performans, replay ve saha çalışmasını kapsayan tam verification ve validation stratejisini tanımlar.)*

The testing system is designed to demonstrate not only that individual components execute, but that the complete research system behaves reproducibly and preserves experimental integrity. *(Test sistemi yalnızca tek tek bileşenlerin çalıştığını değil, tam araştırma sisteminin tekrarlanabilir davrandığını ve deneysel bütünlüğü koruduğunu göstermek için tasarlanmıştır.)*

---

# 2. Testing Philosophy (Test Felsefesi)

NAVGUARD will be tested as a research instrument rather than only as a mobile application. *(NAVGUARD yalnızca mobil uygulama olarak değil, araştırma aracı olarak test edilecektir.)*

Correct UI rendering is insufficient if estimator timing, Ground Truth Firewall isolation, replay determinism, or evidence logging is incorrect. *(Tahmin motoru zamanlaması, Ground Truth Firewall izolasyonu, replay determinizmi veya kanıt logging yanlışsa doğru UI render tek başına yeterli değildir.)*

---

# 3. Verification and Validation Are Different (Verification ve Validation Farklıdır)

Verification asks whether NAVGUARD was implemented according to its defined requirements and mathematical design. *(Verification NAVGUARD'ın tanımlanmış gereksinimlerine ve matematiksel tasarımına göre uygulanıp uygulanmadığını sorgular.)*

Validation asks whether the implemented system performs meaningfully on the Redmi Note 9 Pro under the intended GNSS-denied pedestrian-navigation scenarios. *(Validation uygulanan sistemin Redmi Note 9 Pro üzerinde amaçlanan GNSS kesintili yaya navigasyon senaryolarında anlamlı performans gösterip göstermediğini sorgular.)*

---

# 4. Testing Objectives (Test Hedefleri)

The testing strategy has five primary objectives. *(Test stratejisinin beş temel hedefi vardır.)*

```text
1. Functional Correctness
   (Fonksiyonel Doğruluk)

2. Numerical Correctness
   (Sayısal Doğruluk)

3. Experimental Integrity
   (Deneysel Bütünlük)

4. Runtime Reliability
   (Runtime Güvenilirliği)

5. Research Reproducibility
   (Araştırma Tekrarlanabilirliği)
```

---

# 5. Functional Correctness Objective (Fonksiyonel Doğruluk Hedefi)

Each subsystem must perform the behavior defined by its specification. *(Her alt sistem kendi spesifikasyonunda tanımlanan davranışı gerçekleştirmelidir.)*

---

# 6. Numerical Correctness Objective (Sayısal Doğruluk Hedefi)

Coordinate transforms, heading calculations, PDR propagation, covariance calculations, error metrics, and EKF operations must produce mathematically valid outputs. *(Koordinat dönüşümleri, yön hesapları, PDR ilerletme, kovaryans hesapları, hata metrikleri ve EKF işlemleri matematiksel olarak geçerli çıktılar üretmelidir.)*

---

# 7. Experimental Integrity Objective (Deneysel Bütünlük Hedefi)

Evaluation GNSS ground truth must never enter the denied estimator before controlled recovery. *(Evaluation GNSS ground truth kontrollü recovery öncesinde kesintili tahmin motoruna hiçbir zaman girmemelidir.)*

---

# 8. Runtime Reliability Objective (Runtime Güvenilirliği Hedefi)

The application must continue operating predictably under sensor degradation, ARCore loss, permission changes, storage pressure, logging delay, and recovery failures. *(Uygulama sensör bozulması, ARCore kaybı, permission değişiklikleri, depolama baskısı, logging gecikmesi ve recovery hataları altında öngörülebilir şekilde çalışmaya devam etmelidir.)*

---

# 9. Research Reproducibility Objective (Araştırma Tekrarlanabilirliği Hedefi)

The same frozen input evidence and configuration should reproduce equivalent replay results within numerical tolerance. *(Aynı sabitlenmiş girdi kanıtı ve yapılandırma sayısal tolerans içerisinde eşdeğer replay sonuçlarını yeniden üretmelidir.)*

---

# 10. Test Pyramid (Test Piramidi)

NAVGUARD will use multiple test layers rather than relying primarily on end-to-end field tests. *(NAVGUARD temel olarak uçtan uca saha testlerine dayanmak yerine birden fazla test katmanı kullanacaktır.)*

```text
                FIELD TESTS
              (SAHA TESTLERİ)

             END-TO-END TESTS
           (UÇTAN UCA TESTLER)

           INTEGRATION TESTS
         (ENTEGRASYON TESTLERİ)

          COMPONENT TESTS
         (BİLEŞEN TESTLERİ)

            UNIT TESTS
           (BİRİM TESTLERİ)
```

---

# 11. Why the Pyramid Matters (Test Piramidi Neden Önemlidir)

Mathematical or state-machine bugs should be caught by deterministic tests before they consume scarce field-test time. *(Matematiksel veya state-machine hataları sınırlı saha test süresini tüketmeden önce deterministik testlerle yakalanmalıdır.)*

---

# 12. Test Categories (Test Kategorileri)

NAVGUARD testing will be organized into the following major categories. *(NAVGUARD testleri aşağıdaki ana kategoriler halinde düzenlenecektir.)*

```text
UNIT
INTEGRATION
SYSTEM
REPLAY
DEVICE
FIELD
PERFORMANCE
FAILURE-INJECTION
SECURITY / INTEGRITY
UI / UX
ACCEPTANCE
```

---

# 13. Unit Tests (Birim Testleri)

Unit tests will verify isolated deterministic logic without requiring physical sensors wherever possible. *(Birim testleri mümkün olduğunda fiziksel sensörler gerektirmeden izole deterministik mantığı doğrulayacaktır.)*

---

# 14. Unit Test Candidates (Birim Test Adayları)

Unit tests will cover coordinate mathematics. *(Birim testleri koordinat matematiğini kapsayacaktır.)*

They will cover heading normalization. *(Yön normalizasyonunu kapsayacaktır.)*

They will cover PDR displacement equations. *(PDR yer değiştirme denklemlerini kapsayacaktır.)*

They will cover quality-state logic. *(Kalite durumu mantığını kapsayacaktır.)*

They will cover state-machine transitions. *(State-machine geçişlerini kapsayacaktır.)*

They will cover session metadata serialization. *(Oturum metadata serialization'ını kapsayacaktır.)*

---

# 15. Integration Tests (Entegrasyon Testleri)

Integration tests will verify that independently correct components exchange data correctly through their real interfaces. *(Entegrasyon testleri bağımsız olarak doğru bileşenlerin gerçek arayüzleri üzerinden veriyi doğru şekilde değiş tokuş ettiğini doğrulayacaktır.)*

---

# 16. System Tests (Sistem Testleri)

System tests will exercise complete navigation workflows from readiness through finalization. *(Sistem testleri hazırlıktan finalization'a kadar tam navigasyon workflow'larını çalıştıracaktır.)*

---

# 17. Replay Tests (Replay Testleri)

Replay tests will use recorded sessions to validate algorithms reproducibly without requiring the user to repeat the physical route every time. *(Replay testleri kullanıcının fiziksel rotayı her seferinde tekrar etmesini gerektirmeden algoritmaları tekrarlanabilir şekilde doğrulamak için kaydedilmiş oturumları kullanacaktır.)*

---

# 18. Device Tests (Cihaz Testleri)

Device tests will verify behavior that cannot be established reliably through host-side or emulator testing. *(Cihaz testleri host-side veya emulator testleri üzerinden güvenilir şekilde belirlenemeyen davranışı doğrulayacaktır.)*

---

# 19. Field Tests (Saha Testleri)

Field tests will validate the complete navigation system under real pedestrian motion and real smartphone sensor conditions. *(Saha testleri tam navigasyon sistemini gerçek yaya hareketi ve gerçek akıllı telefon sensör koşulları altında doğrulayacaktır.)*

---

# 20. Performance Tests (Performans Testleri)

Performance tests will measure latency, sampling behavior, CPU, memory, storage throughput, battery consumption, and thermal behavior. *(Performans testleri latency, sampling davranışı, CPU, memory, depolama throughput, batarya tüketimi ve termal davranışı ölçecektir.)*

---

# 21. Failure-Injection Tests (Hata Enjeksiyon Testleri)

Failure-injection tests will deliberately create controlled software failures to verify fallback behavior. *(Hata enjeksiyon testleri fallback davranışını doğrulamak için kontrollü yazılım hataları bilinçli olarak oluşturacaktır.)*

---

# 22. Security and Integrity Tests (Güvenlik ve Bütünlük Testleri)

Security and integrity testing will verify permissions, Ground Truth Firewall enforcement, backup policy, artifact hashes, and protected-data boundaries. *(Güvenlik ve bütünlük testleri permission'ları, Ground Truth Firewall uygulamasını, backup politikasını, artifact hash'lerini ve korunan veri sınırlarını doğrulayacaktır.)*

---

# 23. UI and UX Tests (UI ve UX Testleri)

UI tests will verify that system state is communicated correctly and that critical actions cannot be triggered accidentally. *(UI testleri sistem durumunun doğru şekilde iletildiğini ve kritik işlemlerin yanlışlıkla tetiklenemediğini doğrulayacaktır.)*

---

# 24. Acceptance Tests (Kabul Testleri)

Acceptance tests will determine whether a subsystem or the complete project satisfies its formal Definition of Done. *(Kabul testleri bir alt sistemin veya tam projenin resmî Definition of Done kriterlerini karşılayıp karşılamadığını belirleyecektir.)*

---

# 25. Test Environments (Test Ortamları)

NAVGUARD will use multiple execution environments. *(NAVGUARD birden fazla execution ortamı kullanacaktır.)*

```text
HOST / PYTHON
FLUTTER TEST ENVIRONMENT
ANDROID JVM TESTS
ANDROID INSTRUMENTATION
PHYSICAL REDMI NOTE 9 PRO
OFFLINE REPLAY ENVIRONMENT
FIELD ENVIRONMENT
```

---

# 26. Emulator Limitations (Emulator Sınırlamaları)

An Android emulator may be useful for UI and lifecycle development. *(Android emulator UI ve lifecycle geliştirmesi için kullanışlı olabilir.)*

It will not be treated as authoritative evidence for real IMU, magnetometer, GNSS, ARCore, battery, or thermal performance. *(Gerçek IMU, manyetometre, GNSS, ARCore, batarya veya termal performans için ana kanıt olarak kabul edilmeyecektir.)*

---

# 27. Primary Physical Test Device (Temel Fiziksel Test Cihazı)

The Xiaomi Redmi Note 9 Pro will remain the primary physical validation device. *(Xiaomi Redmi Note 9 Pro temel fiziksel validation cihazı olarak kalacaktır.)*

---

# 28. Cross-Device Testing Is Optional (Cihazlar Arası Test İsteğe Bağlıdır)

Additional Android phones may be used for exploratory compatibility testing if available. *(Kullanılabilir olduğunda ek Android telefonlar exploratory compatibility testleri için kullanılabilir.)*

Cross-device generalization is not required for the minimum success criteria. *(Cihazlar arası genelleme minimum başarı kriterleri için gerekli değildir.)*

---

# 29. Test Data Classes (Test Veri Sınıfları)

NAVGUARD will distinguish synthetic, recorded, development, validation, and final benchmark evidence. *(NAVGUARD sentetik, kaydedilmiş, geliştirme, validation ve nihai benchmark kanıtını ayıracaktır.)*

---

# 30. Synthetic Data (Sentetik Veri)

Synthetic input will be used to test mathematical correctness and state transitions. *(Sentetik girdi matematiksel doğruluğu ve durum geçişlerini test etmek için kullanılacaktır.)*

---

# 31. Recorded Replay Data (Kaydedilmiş Replay Verisi)

Recorded raw sessions will support repeatable algorithm integration testing. *(Kaydedilmiş ham oturumlar tekrarlanabilir algoritma entegrasyon testlerini destekleyecektir.)*

---

# 32. Development Sessions (Geliştirme Oturumları)

Development sessions may be used to tune thresholds and diagnose system behavior. *(Geliştirme oturumları eşikleri ayarlamak ve sistem davranışını teşhis etmek için kullanılabilir.)*

---

# 33. Final Benchmark Sessions (Nihai Benchmark Oturumları)

Final benchmark sessions will not be used for post-hoc tuning. *(Nihai benchmark oturumları sonradan tuning için kullanılmayacaktır.)*

---

# 34. Final Benchmark Separation (Nihai Benchmark Ayrımı)

Once final benchmark data collection begins, algorithm parameters and decision thresholds used for the primary reported result will be frozen. *(Nihai benchmark veri toplama başladıktan sonra temel raporlanan sonuç için kullanılan algoritma parametreleri ve karar eşikleri sabitlenecektir.)*

---

# 35. Test Traceability (Test İzlenebilirliği)

Every formal requirement should be traceable to one or more tests. *(Her resmî gereksinim bir veya daha fazla teste izlenebilir olmalıdır.)*

---

# 36. Requirement-to-Test Mapping (Gereksinimden Teste Eşleme)

A traceability matrix will map requirement identifiers to verification evidence. *(Traceability matrisi requirement identifier'larını verification kanıtına eşleyecektir.)*

```text
Requirement ID
Test ID
Test Type
Expected Result
Execution Status
Evidence Artifact
```

---

# 37. Test ID Convention (Test ID Kuralı)

Existing subsystem-specific test identifiers defined in Pages 12–32 will remain valid. *(Sayfa 12–32 içerisinde tanımlanan mevcut alt sistem özel test identifier'ları geçerli kalacaktır.)*

Page 33 will add cross-system test groups rather than replacing previous IDs. *(Page 33 önceki ID'leri değiştirmek yerine sistemler arası test grupları ekleyecektir.)*

---

# 38. Test Case Structure (Test Case Yapısı)

Every formal test case should define the following information. *(Her resmî test case aşağıdaki bilgileri tanımlamalıdır.)*

```text
Test ID
Purpose
Preconditions
Configuration
Input
Execution Steps
Expected Result
Measured Result
Pass / Fail
Evidence
Notes
```

---

# 39. No Ambiguous Pass Criteria (Belirsiz Pass Kriteri Olmaması)

Formal tests will not use criteria such as `looks good` or `seems stable`. *(Resmî testler `looks good` veya `seems stable` gibi kriterler kullanmayacaktır.)*

---

# 40. Numerical Tolerance (Sayısal Tolerans)

Mathematical tests will define explicit tolerances appropriate to floating-point computation. *(Matematiksel testler floating-point hesaplamaya uygun açık toleranslar tanımlayacaktır.)*

---

# 41. Tolerance Is Test-Specific (Tolerans Teste Özgüdür)

NAVGUARD will not use one arbitrary universal epsilon for all algorithms. *(NAVGUARD tüm algoritmalar için tek keyfi universal epsilon kullanmayacaktır.)*

---

# 42. Coordinate System Test Group (Koordinat Sistemi Test Grubu)

Coordinate mathematics defined in Page 14 will receive deterministic tests. *(Page 14'te tanımlanan koordinat matematiği deterministik testler alacaktır.)*

---

# 43. ENU Initialization Test (ENU Initialization Testi)

A valid anchor must correspond to local position `[0,0,0]`. *(Geçerli anchor yerel `[0,0,0]` konumuna karşılık gelmelidir.)*

---

# 44. WGS84 to ECEF Test (WGS84'ten ECEF'e Test)

Known geodetic reference points will be compared with trusted reference calculations. *(Bilinen geodetic referans noktaları güvenilir referans hesaplamalarıyla karşılaştırılacaktır.)*

---

# 45. ECEF to ENU Test (ECEF'ten ENU'ya Test)

Known Cartesian differences must produce expected East, North, and Up values. *(Bilinen Cartesian farklar beklenen East, North ve Up değerlerini üretmelidir.)*

---

# 46. ENU Round-Trip Test (ENU Round-Trip Testi)

WGS84 → ECEF → ENU → ECEF → WGS84 conversion should return approximately to the original coordinate. *(WGS84 → ECEF → ENU → ECEF → WGS84 dönüşümü yaklaşık olarak orijinal koordinata dönmelidir.)*

---

# 47. Heading Normalization Test (Yön Normalizasyon Testi)

Heading values below zero or above one full revolution must normalize correctly. *(Sıfırın altındaki veya bir tam dönüşün üzerindeki yön değerleri doğru normalize edilmelidir.)*

---

# 48. Circular Error Test (Dairesel Hata Testi)

Heading error between `359°` and `1°` must be interpreted as approximately `2°`, not `358°`. *(`359°` ile `1°` arasındaki yön hatası `358°` yerine yaklaşık `2°` olarak yorumlanmalıdır.)*

---

# 49. Quaternion Tests (Quaternion Testleri)

Quaternion conversion, normalization, multiplication, inversion, and vector rotation will receive deterministic tests. *(Quaternion dönüşümü, normalizasyonu, multiplication, inversion ve vector rotation deterministik testler alacaktır.)*

---

# 50. Quaternion Ordering Test (Quaternion Sıralama Testi)

Adapters for Android and ARCore quaternion conventions must produce the expected canonical `[w,x,y,z]` representation. *(Android ve ARCore quaternion convention adapter'ları beklenen canonical `[w,x,y,z]` temsilini üretmelidir.)*

---

# 51. Sensor Acquisition Test Group (Sensör Toplama Test Grubu)

Sensor acquisition testing will validate availability, timing, rates, sample integrity, and callback behavior. *(Sensör toplama testleri kullanılabilirliği, zamanlamayı, hızları, örnek bütünlüğünü ve callback davranışını doğrulayacaktır.)*

---

# 52. Sensor Enumeration Test (Sensör Enumeration Testi)

The runtime sensor inventory must match the sensors actually reported by Android. *(Runtime sensör inventory Android tarafından gerçekten raporlanan sensörlerle eşleşmelidir.)*

---

# 53. Accelerometer Availability Test (İvmeölçer Kullanılabilirlik Testi)

The authoritative accelerometer stream must be available before a minimum navigation session starts. *(Minimum navigasyon oturumu başlamadan önce ana accelerometer stream kullanılabilir olmalıdır.)*

---

# 54. Gyroscope Availability Test (Jiroskop Kullanılabilirlik Testi)

The authoritative gyroscope stream must be available before a minimum navigation session starts. *(Minimum navigasyon oturumu başlamadan önce ana gyroscope stream kullanılabilir olmalıdır.)*

---

# 55. Magnetometer Availability Test (Manyetometre Kullanılabilirlik Testi)

The heading subsystem must have an approved Earth-referenced heading source before a formal baseline session begins. *(Resmî baseline oturumu başlamadan önce heading alt sistemi onaylanmış Earth-referenced yön kaynağına sahip olmalıdır.)*

---

# 56. Sensor Timestamp Test (Sensör Zaman Damgası Testi)

Sensor measurement timestamps must be monotonic within each authoritative stream. *(Sensör measurement zaman damgaları her ana stream içerisinde monotonik olmalıdır.)*

---

# 57. Sensor Sequence Test (Sensör Sequence Testi)

Sequence counters should increase consistently and reveal dropped or reordered events where applicable. *(Sequence counter'ları tutarlı şekilde artmalı ve uygulanabilir olduğunda düşürülen veya reordered olayları ortaya çıkarmalıdır.)*

---

# 58. Effective Sampling Rate Test (Efektif Sampling Rate Testi)

Actual delivered rate will be calculated from measurement timestamps rather than assumed from the requested rate. *(Gerçek delivered rate talep edilen hızdan varsayılmak yerine measurement zaman damgalarından hesaplanacaktır.)*

---

# 59. Sampling Gap Test (Sampling Gap Testi)

Unexpected long gaps will be detected and counted. *(Beklenmeyen uzun boşluklar tespit edilecek ve sayılacaktır.)*

---

# 60. Requested vs Delivered Rate Test (Talep Edilen ve Delivered Rate Testi)

Candidate requested rates such as 20 Hz, 50 Hz, and 100 Hz may be compared during the device audit. *(20 Hz, 50 Hz ve 100 Hz gibi aday talep edilen hızlar cihaz denetimi sırasında karşılaştırılabilir.)*

---

# 61. Stationary Sensor Test (Sabit Sensör Testi)

A stationary phone will be recorded to characterize accelerometer, gyroscope, and magnetometer behavior. *(Sabit telefon accelerometer, gyroscope ve magnetometer davranışını karakterize etmek için kaydedilecektir.)*

---

# 62. Gyroscope Bias Test (Jiroskop Bias Testi)

Stationary gyroscope measurements will support bias estimation and stability analysis. *(Sabit gyroscope ölçümleri bias tahminini ve stability analizini destekleyecektir.)*

---

# 63. Sensor Preprocessing Test Group (Sensör Ön İşleme Test Grubu)

Preprocessing will be tested independently from navigation state propagation. *(Ön işleme navigasyon state propagation'dan bağımsız test edilecektir.)*

---

# 64. Filter Determinism Test (Filtre Determinizm Testi)

The same sample sequence and frozen filter configuration must produce the same output. *(Aynı örnek dizisi ve sabitlenmiş filtre yapılandırması aynı çıktıyı üretmelidir.)*

---

# 65. No NaN Test (NaN Olmaması Testi)

Preprocessing must not emit NaN or infinite values for valid finite input. *(Ön işleme geçerli sonlu girdi için NaN veya sonsuz değer üretmemelidir.)*

---

# 66. Resampling Test (Resampling Testi)

Known asynchronous sample sequences will be used to verify bounded interpolation onto the required analysis grid. *(Bilinen asynchronous örnek dizileri gerekli analiz grid'ine sınırlı interpolation'ı doğrulamak için kullanılacaktır.)*

---

# 67. Missing Gap Test (Eksik Boşluk Testi)

Interpolation must not bridge gaps beyond the configured maximum interval. *(Interpolation yapılandırılmış maksimum aralığın ötesindeki boşlukları köprülememelidir.)*

---

# 68. Training-Mobile Preprocessing Parity Test (Training-Mobile Ön İşleme Parity Testi)

The Python training pipeline and mobile inference pipeline must produce equivalent model input tensors from the same frozen input window within tolerance. *(Python training hattı ve mobil inference hattı aynı sabitlenmiş input window'dan tolerans içerisinde eşdeğer model input tensor'ları üretmelidir.)*

---

# 69. Step Detection Test Group (Adım Tespit Test Grubu)

The independent NAVGUARD step detector will receive synthetic, replay, and physical walking tests. *(Bağımsız NAVGUARD adım algılayıcısı sentetik, replay ve fiziksel yürüyüş testleri alacaktır.)*

---

# 70. No-Step Stationary Test (Sabitken Adım Olmaması Testi)

A stationary recording should not generate persistent false steps. *(Sabit kayıt sürekli false step üretmemelidir.)*

---

# 71. Known-Step Test (Bilinen Adım Testi)

Controlled walks with manually counted steps will be used to evaluate step-count error. *(Manuel sayılmış adımlı kontrollü yürüyüşler step-count error değerlendirmesi için kullanılacaktır.)*

---

# 72. Duplicate Step Test (Duplicate Adım Testi)

The same physical event must not be accepted twice through duplicate detection paths. *(Aynı fiziksel olay duplicate detection yolları üzerinden iki kez kabul edilmemelidir.)*

---

# 73. Step Timestamp Test (Adım Zaman Damgası Testi)

Accepted step events must preserve meaningful measurement timestamps for heading lookup and replay. *(Kabul edilmiş step event'leri heading lookup ve replay için anlamlı measurement zaman damgalarını korumalıdır.)*

---

# 74. Step Detector Replay Test (Adım Algılayıcı Replay Testi)

The same raw accelerometer input and frozen detector configuration must reproduce the same accepted step sequence. *(Aynı ham accelerometer girdisi ve sabitlenmiş detector yapılandırması aynı kabul edilmiş step sequence'i yeniden üretmelidir.)*

---

# 75. Heading Estimation Test Group (Yön Tahmin Test Grubu)

Heading testing will evaluate numerical correctness, cardinal direction behavior, magnetic disturbance handling, freshness, and quality state. *(Yön testleri sayısal doğruluğu, cardinal direction davranışını, magnetic disturbance yönetimini, freshness ve kalite durumunu değerlendirecektir.)*

---

# 76. Cardinal Heading Test (Cardinal Yön Testi)

Controlled phone orientations toward North, East, South, and West will verify sign and axis conventions. *(Telefonun North, East, South ve West yönlerine kontrollü yönlendirilmesi sign ve axis convention'larını doğrulayacaktır.)*

---

# 77. Declination Sign Test (Declination Sign Testi)

True-north correction will be validated against a known geographic orientation to ensure declination is applied with the correct sign. *(True-north düzeltmesi declination'ın doğru sign ile uygulandığını sağlamak için bilinen coğrafi yönelime karşı doğrulanacaktır.)*

---

# 78. Heading Freshness Test (Yön Freshness Testi)

A stale heading must trigger the configured degraded or invalid behavior rather than being silently reused indefinitely. *(Stale heading sonsuza kadar sessizce yeniden kullanılmak yerine yapılandırılmış degraded veya invalid davranışı tetiklemelidir.)*

---

# 79. Magnetic Disturbance Test (Manyetik Bozulma Testi)

Controlled magnetic disturbance scenarios will verify that heading quality decreases instead of remaining falsely high. *(Kontrollü magnetic disturbance senaryoları heading kalitesinin yanlış şekilde yüksek kalmak yerine düştüğünü doğrulayacaktır.)*

---

# 80. PDR Test Group (PDR Test Grubu)

PDR will receive deterministic equation tests before any field evaluation. *(PDR herhangi bir saha değerlendirmesinden önce deterministik equation testleri alacaktır.)*

---

# 81. North Step Test (Kuzey Adım Testi)

For `L = 1 m` and `ψ = 0`, the expected displacement is approximately `ΔE = 0`, `ΔN = +1`. *(`L = 1 m` ve `ψ = 0` için beklenen displacement yaklaşık `ΔE = 0`, `ΔN = +1` değeridir.)*

---

# 82. East Step Test (Doğu Adım Testi)

For `L = 1 m` and `ψ = π/2`, the expected displacement is approximately `ΔE = +1`, `ΔN = 0`. *(`L = 1 m` ve `ψ = π/2` için beklenen displacement yaklaşık `ΔE = +1`, `ΔN = 0` değeridir.)*

---

# 83. South Step Test (Güney Adım Testi)

For `L = 1 m` and `ψ = π`, the expected displacement is approximately `ΔE = 0`, `ΔN = -1`. *(`L = 1 m` ve `ψ = π` için beklenen displacement yaklaşık `ΔE = 0`, `ΔN = -1` değeridir.)*

---

# 84. West Step Test (Batı Adım Testi)

For `L = 1 m` and `ψ = 3π/2`, the expected displacement is approximately `ΔE = -1`, `ΔN = 0`. *(`L = 1 m` ve `ψ = 3π/2` için beklenen displacement yaklaşık `ΔE = -1`, `ΔN = 0` değeridir.)*

---

# 85. Cardinal Loop Test (Cardinal Döngü Testi)

Four equal North-East-South-West synthetic steps should approximately return to the initial local position. *(Dört eşit North-East-South-West sentetik adımı yaklaşık olarak ilk yerel konuma dönmelidir.)*

---

# 86. Stationary PDR Test (Sabit PDR Testi)

No accepted step must produce no PDR displacement. *(Kabul edilmiş adım olmaması PDR displacement üretmemelidir.)*

---

# 87. GNSS Independence Test for PDR (PDR İçin GNSS Bağımsızlık Testi)

Changing protected GNSS reference values during a denied replay must not change the baseline PDR trajectory. *(Kesintili replay sırasında korunan GNSS referans değerlerini değiştirmek temel PDR trajectory'sini değiştirmemelidir.)*

---

# 88. Step Length Test Group (Adım Uzunluğu Test Grubu)

Deterministic and learned step-length methods will be tested independently. *(Deterministik ve learned step-length yöntemleri bağımsız test edilecektir.)*

---

# 89. Constant Step Length Test (Sabit Adım Uzunluğu Testi)

The baseline constant-length model must produce the configured value for every accepted normal walking step. *(Baseline constant-length model her kabul edilmiş normal walking step için yapılandırılmış değeri üretmelidir.)*

---

# 90. Learned Step Length Bound Test (Öğrenilmiş Adım Uzunluğu Sınır Testi)

Out-of-range model outputs must trigger the configured plausibility or fallback policy. *(Sınır dışı model çıktıları yapılandırılmış plausibility veya fallback politikasını tetiklemelidir.)*

---

# 91. Step Length Fallback Test (Adım Uzunluğu Fallback Testi)

AI step-length failure must fall back to the deterministic method without stopping PDR when the fallback remains valid. *(AI step-length hatası fallback geçerli kaldığında PDR'ı durdurmadan deterministik yönteme dönmelidir.)*

---

# 92. Motion Classification Test Group (Hareket Sınıflandırma Test Grubu)

Motion classification will be tested at training, export, mobile parity, runtime, and navigation-integration levels. *(Hareket sınıflandırma training, export, mobil parity, runtime ve navigasyon entegrasyon seviyelerinde test edilecektir.)*

---

# 93. Session-Wise Split Test (Oturum Bazlı Split Testi)

The ML evaluation pipeline must reject or detect splits where overlapping windows from the same recording session leak across train and test sets. *(ML değerlendirme hattı aynı kayıt oturumundan overlapping window'ların train ve test setleri arasında sızdığı split'leri reddetmeli veya tespit etmelidir.)*

---

# 94. Model Input Shape Test (Model Girdi Shape Testi)

The deployed LiteRT model must receive the exact tensor shape expected by the frozen preprocessing pipeline. *(Deploy edilmiş LiteRT modeli sabitlenmiş preprocessing hattının beklediği kesin tensor shape'i almalıdır.)*

---

# 95. Model Output Shape Test (Model Çıktı Shape Testi)

The application must reject incompatible model outputs rather than interpreting them incorrectly. *(Uygulama uyumsuz model çıktılarını yanlış yorumlamak yerine reddetmelidir.)*

---

# 96. Class Mapping Test (Sınıf Eşleme Testi)

Model class indices must map correctly to `STATIONARY`, `WALKING`, `RUNNING`, and `TURNING`. *(Model class index'leri `STATIONARY`, `WALKING`, `RUNNING` ve `TURNING` sınıflarına doğru eşlenmelidir.)*

---

# 97. Motion AI Navigation Influence Test (Hareket AI Navigasyon Etki Testi)

The accepted AI output must measurably influence navigation behavior according to the documented rules. *(Kabul edilmiş AI çıktısı dokümante edilmiş kurallara göre navigasyon davranışını ölçülebilir şekilde etkilemelidir.)*

---

# 98. Stationary AI Test (Sabit AI Testi)

A sustained accepted `STATIONARY` state must suppress false propagation according to the frozen policy. *(Sürdürülen kabul edilmiş `STATIONARY` durumu sabitlenmiş politikaya göre false propagation'ı baskılamalıdır.)*

---

# 99. Running AI Test (Koşu AI Testi)

Accepted `RUNNING` classification must activate the configured running-specific behavior if that behavior is enabled. *(Kabul edilmiş `RUNNING` sınıflandırması etkinse yapılandırılmış running-specific davranışı aktive etmelidir.)*

---

# 100. Turning AI Test (Dönüş AI Testi)

Accepted `TURNING` classification must influence heading or fusion handling only through the documented interface. *(Kabul edilmiş `TURNING` sınıflandırması heading veya fusion yönetimini yalnızca dokümante edilmiş arayüz üzerinden etkilemelidir.)*

---

# 101. AI Inference Latency Test (AI Inference Latency Testi)

Representative inference latency will be measured on the Redmi Note 9 Pro using the actual deployment runtime. *(Temsili inference latency gerçek deployment runtime kullanılarak Redmi Note 9 Pro üzerinde ölçülecektir.)*

---

# 102. AI Failure Test (AI Hata Testi)

Model load failure, inference exception, invalid output, and stale output will each receive explicit fallback tests. *(Model load hatası, inference exception, invalid output ve stale output ayrı ayrı açık fallback testleri alacaktır.)*

---

# 103. LiteRT Parity Test (LiteRT Parity Testi)

A frozen set of test windows will be evaluated in Python and on-device LiteRT, and the resulting probabilities or logits will be compared within tolerance. *(Sabitlenmiş test window seti Python ve on-device LiteRT üzerinde değerlendirilecek ve ortaya çıkan probability veya logit değerleri tolerans içerisinde karşılaştırılacaktır.)*

---

# 104. ARCore Test Group (ARCore Test Grubu)

ARCore testing will verify availability, initialization, tracking, pose continuity, timestamp behavior, degradation, and fallback. *(ARCore testleri kullanılabilirliği, initialization'ı, tracking'i, pose continuity'yi, timestamp davranışını, degradation'ı ve fallback'i doğrulayacaktır.)*

---

# 105. ARCore Availability Test (ARCore Kullanılabilirlik Testi)

The Redmi Note 9 Pro must report the expected ARCore support state during the device audit. *(Redmi Note 9 Pro cihaz denetimi sırasında beklenen ARCore support durumunu raporlamalıdır.)*

---

# 106. ARCore Initialization Test (ARCore Initialization Testi)

An ARCore-enabled session must initialize without creating duplicate camera or tracking sessions. *(ARCore etkin oturum duplicate kamera veya tracking session oluşturmadan initialize olmalıdır.)*

---

# 107. ARCore Stationary Drift Test (ARCore Sabit Drift Testi)

The phone will remain stationary while ARCore relative pose drift is recorded. *(Telefon sabit tutulurken ARCore relative pose drift kaydedilecektir.)*

---

# 108. ARCore Short Motion Test (ARCore Kısa Hareket Testi)

Known short physical movements will be compared with ARCore relative displacement behavior. *(Bilinen kısa fiziksel hareketler ARCore relative displacement davranışıyla karşılaştırılacaktır.)*

---

# 109. ARCore Tracking Loss Test (ARCore Tracking Kaybı Testi)

A controlled low-texture or obstructed-camera condition will verify transition to degraded tracking and PDR fallback. *(Kontrollü low-texture veya obstructed-camera koşulu degraded tracking'e geçişi ve PDR fallback'i doğrulayacaktır.)*

---

# 110. ARCore Recovery Test (ARCore Recovery Testi)

Tracking restoration must not create an uncontrolled estimator jump. *(Tracking restoration kontrolsüz estimator sıçraması oluşturmamalıdır.)*

---

# 111. ARCore Timestamp Alignment Test (ARCore Zaman Damgası Hizalama Testi)

The selected mapping between ARCore timestamps and the common experiment clock will be validated through measured offset and drift behavior. *(ARCore zaman damgaları ile ortak deney clock'u arasındaki seçilen mapping ölçülmüş offset ve drift davranışı üzerinden doğrulanacaktır.)*

---

# 112. Sensor Fusion Test Group (Sensör Füzyon Test Grubu)

The EKF will be tested first through synthetic sequences and then through recorded replay sessions. *(EKF önce sentetik dizilerle ve ardından kaydedilmiş replay oturumlarıyla test edilecektir.)*

---

# 113. EKF Initialization Test (EKF Initialization Testi)

A valid initial state and covariance must produce a valid initialized filter state. *(Geçerli initial state ve covariance geçerli initialized filter durumu üretmelidir.)*

---

# 114. EKF Prediction Test (EKF Prediction Testi)

Known state-transition inputs must produce expected predicted states within numerical tolerance. *(Bilinen state-transition girdileri sayısal tolerans içerisinde beklenen predicted state'leri üretmelidir.)*

---

# 115. EKF Measurement Update Test (EKF Measurement Update Testi)

Synthetic measurements with known residuals will verify Kalman update behavior. *(Bilinen residual'lara sahip sentetik measurements Kalman update davranışını doğrulayacaktır.)*

---

# 116. EKF Covariance Symmetry Test (EKF Kovaryans Simetri Testi)

The covariance matrix must remain symmetric within numerical tolerance. *(Kovaryans matrisi sayısal tolerans içerisinde simetrik kalmalıdır.)*

---

# 117. EKF Positive Semidefinite Test (EKF Pozitif Yarı Tanımlı Testi)

The filter will monitor covariance validity and detect materially invalid negative eigenvalues. *(Filtre kovaryans geçerliliğini izleyecek ve anlamlı şekilde geçersiz negatif eigenvalue'ları tespit edecektir.)*

---

# 118. EKF Variable Delta-Time Test (EKF Değişken Delta-Time Testi)

Prediction must correctly handle variable measurement intervals rather than assuming a perfect fixed sample rate. *(Prediction kusursuz sabit sample rate varsaymak yerine değişken measurement interval'ları doğru yönetmelidir.)*

---

# 119. EKF Measurement Rejection Test (EKF Ölçüm Reddetme Testi)

Invalid or stale measurements must be rejected according to the frozen gating rules. *(Invalid veya stale measurement'lar sabitlenmiş gating kurallarına göre reddedilmelidir.)*

---

# 120. EKF Source Loss Test (EKF Kaynak Kaybı Testi)

Loss of ARCore or degraded heading must modify uncertainty behavior without silently stopping the entire estimator when fallback remains possible. *(ARCore kaybı veya degraded heading fallback mümkün kaldığında tüm tahmin motorunu sessizce durdurmadan belirsizlik davranışını değiştirmelidir.)*

---

# 121. Uncertainty Test Group (Belirsizlik Test Grubu)

Position uncertainty will be tested for numerical validity, monotonic behavior expectations, visualization mapping, and calibration consistency. *(Konum belirsizliği sayısal geçerlilik, monotonik davranış beklentileri, görselleştirme mapping'i ve calibration consistency açısından test edilecektir.)*

---

# 122. Horizontal Covariance Extraction Test (Yatay Kovaryans Çıkarma Testi)

Known full EKF covariance must produce the expected East-North covariance block. *(Bilinen tam EKF covariance beklenen East-North covariance bloğunu üretmelidir.)*

---

# 123. Ellipse Eigenvalue Test (Ellipse Eigenvalue Testi)

Known covariance matrices will verify major and minor ellipse axis calculations. *(Bilinen kovaryans matrisleri major ve minor ellipse axis hesaplarını doğrulayacaktır.)*

---

# 124. Invalid Covariance Test (Geçersiz Kovaryans Testi)

NaN, infinite, strongly asymmetric, or materially negative covariance must not be presented as valid uncertainty. *(NaN, sonsuz, güçlü asimetrik veya anlamlı negatif kovaryans geçerli belirsizlik olarak sunulmamalıdır.)*

---

# 125. Zero-Uncertainty Prevention Test (Sıfır Belirsizlik Önleme Testi)

GNSS anchor initialization and recovery must not produce unjustified zero position uncertainty. *(GNSS anchor initialization ve recovery gerekçesiz sıfır konum belirsizliği üretmemelidir.)*

---

# 126. Quality Mapping Test (Kalite Mapping Testi)

Frozen uncertainty and quality conditions must map deterministically to the same quality state. *(Sabitlenmiş belirsizlik ve kalite koşulları deterministik olarak aynı kalite durumuna mapping edilmelidir.)*

---

# 127. GNSS Test Group (GNSS Test Grubu)

GNSS testing will cover provider selection, timestamps, accuracy metadata, anchor acquisition, Evaluation Mode logging, and recovery behavior. *(GNSS testleri provider seçimini, zaman damgalarını, accuracy metadata bilgisini, anchor acquisition'ı, Evaluation Mode logging'i ve recovery davranışını kapsayacaktır.)*

---

# 128. GPS Provider Test (GPS Provider Testi)

Formal GNSS acquisition must use the configured authoritative GNSS provider. *(Resmî GNSS acquisition yapılandırılmış ana GNSS provider'ı kullanmalıdır.)*

---

# 129. GNSS Timestamp Test (GNSS Zaman Damgası Testi)

GNSS measurement time must use the common monotonic timing model. *(GNSS measurement time ortak monotonik zamanlama modelini kullanmalıdır.)*

---

# 130. Stale GNSS Test (Stale GNSS Testi)

A cached or stale location must not be accepted as a fresh anchor or recovery reference. *(Cache'lenmiş veya stale konum fresh anchor veya recovery referansı olarak kabul edilmemelidir.)*

---

# 131. Optional Field Availability Test (İsteğe Bağlı Alan Kullanılabilirlik Testi)

Missing altitude, speed, bearing, or accuracy metadata must remain explicitly unavailable rather than becoming zero. *(Eksik altitude, speed, bearing veya accuracy metadata bilgisi sıfıra dönüşmek yerine açık şekilde unavailable kalmalıdır.)*

---

# 132. GNSS Anchor Test (GNSS Anchor Testi)

Anchor acceptance must require the frozen quality and freshness policy. *(Anchor kabulü sabitlenmiş kalite ve freshness politikasını gerektirmelidir.)*

---

# 133. GNSS First-Fix Rejection Test (GNSS İlk Fix Reddetme Testi)

The first observed GNSS fix must not be accepted automatically when it fails anchor quality criteria. *(İlk gözlemlenen GNSS fix anchor kalite kriterlerini geçemezse otomatik olarak kabul edilmemelidir.)*

---

# 134. Ground Truth Firewall Test Group (Ground Truth Firewall Test Grubu)

Ground Truth Firewall testing is a mandatory research-integrity gate. *(Ground Truth Firewall testleri zorunlu araştırma bütünlüğü kapısıdır.)*

---

# 135. Ground Truth Logging Test (Ground Truth Logging Testi)

Evaluation GNSS samples must continue reaching the protected logger while estimator authorization is blocked. *(Evaluation GNSS örnekleri tahmin motoru authorization blocked iken korunan logger'a ulaşmaya devam etmelidir.)*

---

# 136. Estimator Block Test (Tahmin Motoru Block Testi)

The same protected GNSS samples must not reach the estimator update interface. *(Aynı korunan GNSS örnekleri tahmin motoru update arayüzüne ulaşmamalıdır.)*

---

# 137. Ground Truth Mutation Test (Ground Truth Mutation Testi)

Changing protected GNSS coordinates during replay must not modify the denied estimator output. *(Replay sırasında korunan GNSS koordinatlarını değiştirmek kesintili tahmin motoru çıktısını değiştirmemelidir.)*

---

# 138. Ground Truth AI Leakage Test (Ground Truth AI Sızıntı Testi)

Protected GNSS fields must not appear in runtime AI feature tensors during a denied interval. *(Korunan GNSS alanları kesintili aralık sırasında runtime AI feature tensor'larında görünmemelidir.)*

---

# 139. Ground Truth Anchor Leakage Test (Ground Truth Anchor Sızıntı Testi)

Protected GNSS must not move or replace the active anchor before controlled recovery. *(Korunan GNSS kontrollü recovery öncesinde aktif anchor'ı taşımamalı veya değiştirmemelidir.)*

---

# 140. Ground Truth Covariance Leakage Test (Ground Truth Kovaryans Sızıntı Testi)

Protected GNSS must not reduce EKF covariance during denied estimation. *(Korunan GNSS kesintili tahmin sırasında EKF covariance'ını azaltmamalıdır.)*

---

# 141. Unauthorized Update Counter Test (Yetkisiz Update Counter Testi)

`unauthorizedGnssEstimatorUpdateCount` must remain zero in every valid benchmark denied interval. *(`unauthorizedGnssEstimatorUpdateCount` her geçerli benchmark kesintili aralıkta sıfır kalmalıdır.)*

---

# 142. Recovery Test Group (Recovery Test Grubu)

Recovery testing will verify quality validation, evidence ordering, error capture, relocalization, and authorization restoration. *(Recovery testleri kalite validation'ını, evidence ordering'i, hata yakalamayı, relocalization'ı ve authorization restoration'ı doğrulayacaktır.)*

---

# 143. Recovery Pending Block Test (Recovery Pending Block Testi)

GNSS must remain blocked from estimator updates throughout `GNSS_RECOVERY_PENDING`. *(GNSS `GNSS_RECOVERY_PENDING` boyunca tahmin motoru update'lerinden blocked kalmalıdır.)*

---

# 144. Recovery Candidate Validation Test (Recovery Aday Validation Testi)

Stale, inaccurate, invalid, or wrong-provider candidates must be rejected according to frozen rules. *(Stale, inaccurate, invalid veya yanlış-provider adaylar sabitlenmiş kurallara göre reddedilmelidir.)*

---

# 145. Recovery Error Ordering Test (Recovery Hata Sırası Testi)

Pre-correction state capture and error calculation must complete before relocalization begins. *(Düzeltme öncesi state capture ve error calculation relocalization başlamadan önce tamamlanmalıdır.)*

---

# 146. Recovery Historical Integrity Test (Recovery Geçmiş Bütünlük Testi)

Historical denied-navigation trajectory points must remain unchanged after relocalization. *(Geçmiş kesintili navigasyon trajectory noktaları relocalization sonrasında değişmeden kalmalıdır.)*

---

# 147. Recovery Covariance Test (Recovery Kovaryans Testi)

Recovery must update or reinitialize covariance according to an explicit policy rather than resetting it to zero. *(Recovery covariance'ı sıfıra resetlemek yerine açık politikaya göre update veya reinitialize etmelidir.)*

---

# 148. Recovery Failure Test (Recovery Hata Testi)

A timeout or lack of acceptable GNSS reference must not force a poor fix into the estimator. *(Timeout veya kabul edilebilir GNSS referansı olmaması kötü fix'i tahmin motoruna zorlamamalıdır.)*

---

# 149. Storage Test Group (Depolama Test Grubu)

Storage testing will verify session lifecycle, bounded queues, append-only evidence, manifests, crash recovery, integrity, and export. *(Depolama testleri oturum lifecycle'ını, sınırlı kuyrukları, append-only kanıtı, manifestleri, crash recovery'yi, integrity'yi ve export'u doğrulayacaktır.)*

---

# 150. Session Creation Test (Oturum Oluşturma Testi)

Every new session must receive a unique immutable internal identifier. *(Her yeni oturum benzersiz değişmez dahili tanımlayıcı almalıdır.)*

---

# 151. Session Start Test (Oturum Başlatma Testi)

Recording must not begin until required writers and session metadata are prepared successfully. *(Gerekli writer'lar ve oturum metadata bilgisi başarıyla hazırlanmadan kayıt başlamamalıdır.)*

---

# 152. Append-Only Test (Append-Only Testi)

Committed raw sensor rows must not be modified by normal live processing. *(Commit edilmiş ham sensör satırları normal live processing tarafından değiştirilmemelidir.)*

---

# 153. Writer Queue Test (Writer Queue Testi)

Artificially slowed disk writes must not create unbounded memory growth. *(Yapay olarak yavaşlatılmış disk yazımları sınırsız memory büyümesi oluşturmamalıdır.)*

---

# 154. Drop Visibility Test (Drop Görünürlük Testi)

Any deliberately induced dropped record must increment the corresponding diagnostic counter. *(Bilinçli oluşturulan herhangi bir dropped record karşılık gelen diagnostic counter'ı artırmalıdır.)*

---

# 155. Finalization Test (Finalization Testi)

A session must not become `COMPLETED` until required queues are drained, writers are closed, artifacts are verified, and the manifest is finalized. *(Gerekli kuyruklar drain edilmeden, writer'lar kapatılmadan, artifact'lar doğrulanmadan ve manifest finalize edilmeden oturum `COMPLETED` olmamalıdır.)*

---

# 156. Crash During Recording Test (Kayıt Sırasında Crash Testi)

A simulated process crash must leave the session detectable as `INCOMPLETE` on the next launch. *(Simüle edilmiş process crash sonraki başlatmada oturumu `INCOMPLETE` olarak tespit edilebilir bırakmalıdır.)*

---

# 157. Crash During Finalization Test (Finalization Sırasında Crash Testi)

A crash during finalization must not produce a false completed session. *(Finalization sırasında crash yanlış tamamlanmış oturum üretmemelidir.)*

---

# 158. Partial CSV Tail Test (Kısmi CSV Tail Testi)

A malformed incomplete final line must not invalidate all earlier valid rows in the file. *(Malformed incomplete son satır dosyadaki önceki tüm geçerli satırları geçersiz hale getirmemelidir.)*

---

# 159. Export Test (Export Testi)

A completed export must include the manifest and all mandatory selected artifacts. *(Tamamlanmış export manifest'i ve tüm zorunlu seçilmiş artifact'ları içermelidir.)*

---

# 160. Export Hash Test (Export Hash Testi)

Modifying a hashed artifact after export must cause checksum verification to fail. *(Export sonrasında hash'lenmiş artifact'ı değiştirmek checksum doğrulamasının başarısız olmasına neden olmalıdır.)*

---

# 161. Replay Test Group (Replay Test Grubu)

Replay is a central NAVGUARD verification mechanism. *(Replay temel NAVGUARD verification mekanizmalarından biridir.)*

---

# 162. Replay Determinism Test (Replay Determinizm Testi)

The same raw evidence and frozen configuration must reproduce equivalent outputs within numerical tolerance. *(Aynı ham kanıt ve sabitlenmiş yapılandırma sayısal tolerans içerisinde eşdeğer çıktılar yeniden üretmelidir.)*

---

# 163. Replay Source Discovery Test (Replay Kaynak Keşfi Testi)

Replay must identify input artifacts from the manifest or structured artifact index rather than relying only on hard-coded filenames. *(Replay yalnızca hard-coded dosya adlarına dayanmak yerine manifest veya yapılandırılmış artifact index üzerinden girdi artifact'larını tanımlamalıdır.)*

---

# 164. Replay Output Separation Test (Replay Çıktı Ayrım Testi)

Replay output must be written separately from original live output. *(Replay çıktısı orijinal live output'tan ayrı yazılmalıdır.)*

---

# 165. Replay Causality Test (Replay Nedensellik Testi)

Replay must not use future samples that would not have been available at the corresponding live time. *(Replay karşılık gelen canlı zamanda kullanılamayacak gelecekteki örnekleri kullanmamalıdır.)*

---

# 166. Replay Firewall Test (Replay Firewall Testi)

Denied replay must enforce the same Ground Truth Firewall boundary as the original live run. *(Kesintili replay orijinal live run ile aynı Ground Truth Firewall sınırını uygulamalıdır.)*

---

# 167. Replay Algorithm Comparison Test (Replay Algoritma Karşılaştırma Testi)

Alternative PDR, heading, step-length, ARCore, or fusion algorithms may be compared on identical recorded inputs. *(Alternatif PDR, heading, step-length, ARCore veya fusion algoritmaları aynı kaydedilmiş girdiler üzerinde karşılaştırılabilir.)*

---

# 168. Replay Does Not Replace Field Testing (Replay Saha Testinin Yerini Almaz)

Replay can verify software behavior but cannot establish new physical sensor performance that was not present in the recorded evidence. *(Replay yazılım davranışını doğrulayabilir ancak kaydedilmiş kanıtta bulunmayan yeni fiziksel sensör performansını belirleyemez.)*

---

# 169. Permission Test Group (Permission Test Grubu)

Permission testing will verify exact behavior for granted, denied, approximate-only, revoked, and not-required states. *(Permission testleri granted, denied, approximate-only, revoked ve not-required durumları için kesin davranışı doğrulayacaktır.)*

---

# 170. Approximate-Only Location Test (Yalnızca Approximate Konum Testi)

Formal GNSS benchmark readiness must remain blocked when only approximate location is available. *(Yalnızca approximate location mevcutken resmî GNSS benchmark readiness blocked kalmalıdır.)*

---

# 171. Camera Denial Test (Kamera Reddi Testi)

Camera denial must disable ARCore-required configurations while preserving PDR-capable configurations. *(Kamera reddi PDR-capable yapılandırmaları korurken ARCore-required yapılandırmaları devre dışı bırakmalıdır.)*

---

# 172. Activity Recognition Denial Test (Activity Recognition Reddi Testi)

Denial must affect only optional Android step-sensor comparison. *(Red yalnızca isteğe bağlı Android adım sensörü karşılaştırmasını etkilemelidir.)*

---

# 173. Runtime Permission Revocation Test (Runtime Permission İptali Testi)

Revoking a required permission during an active session must generate the documented subsystem and session response. *(Aktif oturum sırasında gerekli permission'ı iptal etmek dokümante edilmiş alt sistem ve oturum tepkisini oluşturmalıdır.)*

---

# 174. UI Test Group (UI Test Grubu)

UI testing will focus on state correctness rather than purely visual appearance. *(UI testleri yalnızca görsel görünüm yerine durum doğruluğuna odaklanacaktır.)*

---

# 175. Navigation Mode Visibility Test (Navigasyon Mod Görünürlüğü Testi)

The active navigation mode must remain visible throughout live navigation. *(Aktif navigasyon modu live navigation boyunca görünür kalmalıdır.)*

---

# 176. Denial Confirmation Test (Kesinti Onay Testi)

Benchmark Mode must require explicit user intent before starting GNSS-denied operation. *(Benchmark Mode GNSS kesintili çalışmayı başlatmadan önce açık kullanıcı niyeti gerektirmelidir.)*

---

# 177. Ground Truth Hidden UI Test (Ground Truth Gizli UI Testi)

Protected GNSS ground truth must not appear on the live blinded Evaluation Mode map. *(Korunan GNSS ground truth live blinded Evaluation Mode haritasında görünmemelidir.)*

---

# 178. Invalid Position UI Test (Geçersiz Konum UI Testi)

An invalid estimator position must not continue appearing as a normal trustworthy moving marker. *(Invalid estimator konumu normal güvenilir hareketli marker olarak görünmeye devam etmemelidir.)*

---

# 179. Recovery UI State Test (Recovery UI Durum Testi)

The UI must progress through recovery pending, validation, relocalization, and restored states in the same order as the authoritative state machine. *(UI recovery pending, validation, relocalization ve restored durumları arasında ana state machine ile aynı sırada ilerlemelidir.)*

---

# 180. Session Finalization UI Test (Oturum Finalization UI Testi)

The UI must not display `Completed` before storage finalization succeeds. *(UI depolama finalization başarılı olmadan `Completed` göstermemelidir.)*

---

# 181. UI Rebuild Test (UI Rebuild Testi)

Flutter rebuilds must not restart sensors, GNSS, ARCore, or LiteRT inference pipelines. *(Flutter rebuild'leri sensörleri, GNSS'i, ARCore'u veya LiteRT inference hatlarını yeniden başlatmamalıdır.)*

---

# 182. Screen Rotation Test (Ekran Döndürme Testi)

If device rotation is allowed, orientation change must not create duplicate acquisition sessions. *(Cihaz döndürmeye izin verilirse orientation change duplicate acquisition session oluşturmamalıdır.)*

---

# 183. Performance Test Group (Performans Test Grubu)

Performance testing will be performed on physical hardware with release or profile builds where practical. *(Performans testleri uygulanabilir olduğunda fiziksel donanım üzerinde release veya profile build'lerle gerçekleştirilecektir.)*

---

# 184. Sensor Callback Latency Test (Sensör Callback Latency Testi)

Callback handling must remain lightweight enough to avoid backlog under the selected sensor profile. *(Callback yönetimi seçilen sensör profili altında backlog'u önleyecek kadar hafif kalmalıdır.)*

---

# 185. AI Latency Test (AI Latency Testi)

On-device motion-classification inference latency will be measured over representative repeated runs. *(On-device motion-classification inference latency temsili tekrarlanan run'lar üzerinde ölçülecektir.)*

---

# 186. AI Latency Target (AI Latency Hedefi)

The current provisional target remains below approximately 50 ms per inference on the Redmi Note 9 Pro. *(Mevcut geçici hedef Redmi Note 9 Pro üzerinde inference başına yaklaşık 50 ms'nin altında kalmaktadır.)*

---

# 187. UI Frame Responsiveness Test (UI Frame Responsiveness Testi)

Map rendering and diagnostics must not materially delay navigation processing. *(Harita render ve diagnostics navigasyon işlemesini anlamlı şekilde geciktirmemelidir.)*

---

# 188. Logging Throughput Test (Logging Throughput Testi)

The writer system must sustain the complete selected logging profile without uncontrolled queue growth. *(Writer sistemi kontrolsüz queue büyümesi olmadan tam seçilmiş logging profilini sürdürebilmelidir.)*

---

# 189. Memory Test (Memory Testi)

A representative long session must not show unbounded growth from queues, rolling windows, trajectory buffers, or diagnostic charts. *(Temsili uzun oturum queues, rolling windows, trajectory buffer'ları veya diagnostic chart'lar nedeniyle sınırsız growth göstermemelidir.)*

---

# 190. Battery Test (Batarya Testi)

Battery consumption will be measured over representative sessions with selected system configurations. *(Batarya tüketimi seçilen sistem yapılandırmalarıyla temsili oturumlar boyunca ölçülecektir.)*

---

# 191. Thermal Test (Termal Test)

Device temperature and thermal throttling indicators will be monitored during long combined-stack tests where practical. *(Cihaz sıcaklığı ve thermal throttling indicator'ları uygulanabilir olduğunda uzun combined-stack testleri sırasında izlenecektir.)*

---

# 192. Build-Type Test (Build-Type Testi)

Final performance conclusions will not be based solely on debug builds. *(Nihai performans sonuçları yalnızca debug build'lere dayanmayacaktır.)*

---

# 193. Combined Runtime Test (Birleşik Runtime Testi)

The full stack will be tested with sensors, GNSS, ARCore, AI, EKF, logging, and UI active simultaneously where the selected configuration requires them. *(Tam stack seçilen yapılandırma gerektirdiğinde sensörler, GNSS, ARCore, AI, EKF, logging ve UI aynı anda aktifken test edilecektir.)*

---

# 194. Failure-Injection Test Group (Hata Enjeksiyon Test Grubu)

Controlled failure injection will validate fallback and evidence-integrity behavior. *(Kontrollü failure injection fallback ve evidence-integrity davranışını doğrulayacaktır.)*

---

# 195. ARCore Loss Injection (ARCore Kaybı Enjeksiyonu)

Tracking loss will be simulated or naturally induced to verify PDR continuation. *(Tracking loss PDR devamlılığını doğrulamak için simüle edilecek veya doğal olarak oluşturulacaktır.)*

---

# 196. GNSS Loss Injection (GNSS Kaybı Enjeksiyonu)

The formal denied condition will be created through software estimator exclusion rather than RF interference. *(Resmî kesintili koşul RF müdahalesi yerine yazılım tahmin motoru exclusion üzerinden oluşturulacaktır.)*

---

# 197. AI Failure Injection (AI Hata Enjeksiyonu)

Model-load or inference failure will verify deterministic fallback behavior. *(Model-load veya inference failure deterministik fallback davranışını doğrulayacaktır.)*

---

# 198. Logging Delay Injection (Logging Gecikme Enjeksiyonu)

Artificially slowed writer throughput will verify bounded queue and drop-counter behavior. *(Yapay olarak yavaşlatılmış writer throughput bounded queue ve drop-counter davranışını doğrulayacaktır.)*

---

# 199. Storage Failure Injection (Depolama Hata Enjeksiyonu)

Controlled write failures will verify incomplete and invalid-session handling. *(Kontrollü write failure'lar incomplete ve invalid-session yönetimini doğrulayacaktır.)*

---

# 200. Permission Revocation Injection (Permission İptal Enjeksiyonu)

Runtime permission loss will verify deterministic subsystem degradation. *(Runtime permission kaybı deterministik alt sistem degradation'ını doğrulayacaktır.)*

---

# 201. Invalid Sensor Sample Injection (Geçersiz Sensör Örneği Enjeksiyonu)

NaN, infinite, duplicate, out-of-order, or missing samples will test input-validation boundaries where appropriate. *(NaN, sonsuz, duplicate, out-of-order veya missing sample'lar uygun olduğunda input-validation sınırlarını test edecektir.)*

---

# 202. Recovery Failure Injection (Recovery Hata Enjeksiyonu)

Poor GNSS candidates and recovery timeout conditions will verify that recovery does not force invalid corrections. *(Kötü GNSS adayları ve recovery timeout koşulları recovery'nin invalid correction zorlamadığını doğrulayacaktır.)*

---

# 203. App Crash Injection (Uygulama Crash Enjeksiyonu)

Development testing will deliberately terminate the app during recording and finalization. *(Development testleri uygulamayı kayıt ve finalization sırasında bilinçli olarak terminate edecektir.)*

---

# 204. Security Test Group (Güvenlik Test Grubu)

Security testing will validate actual runtime behavior rather than relying on manifest review alone. *(Güvenlik testleri yalnızca manifest incelemesine dayanmak yerine gerçek runtime davranışını doğrulayacaktır.)*

---

# 205. Permission Manifest Audit (Permission Manifest Audit'i)

Declared Android permissions will be compared with the approved capability matrix. *(Declare edilmiş Android permission'lar onaylanmış capability matrisiyle karşılaştırılacaktır.)*

---

# 206. Backup Exclusion Test (Backup Exclusion Testi)

Sensitive session data must follow the frozen backup exclusion policy. *(Hassas oturum verisi sabitlenmiş backup exclusion politikasını izlemelidir.)*

---

# 207. Sensitive Log Test (Hassas Log Testi)

System logs will be inspected to verify that continuous precise trajectories are not unintentionally emitted. *(System log'ları sürekli kesin trajectory'lerin yanlışlıkla yayınlanmadığını doğrulamak için incelenecektir.)*

---

# 208. Model Hash Test (Model Hash Testi)

A modified model artifact must fail Benchmark Mode integrity verification. *(Değiştirilmiş model artifact'ı Benchmark Mode integrity verification'ı geçememelidir.)*

---

# 209. Artifact Hash Test (Artifact Hash Testi)

A modified finalized evidence file must fail checksum validation where hashing is enabled. *(Hashing etkin olduğunda değiştirilmiş finalize edilmiş evidence dosyası checksum validation'ı geçememelidir.)*

---

# 210. Path Safety Test (Path Güvenliği Testi)

User-entered session labels must not permit writing outside the session or export root. *(Kullanıcı tarafından girilen session label'ları session veya export root'un dışına yazmaya izin vermemelidir.)*

---

# 211. Imported Archive Test (Import Edilmiş Arşiv Testi)

If import is implemented, path traversal and invalid manifest structures must be rejected. *(Import uygulanırsa path traversal ve invalid manifest yapıları reddedilmelidir.)*

---

# 212. Field Validation Test Group (Saha Validation Test Grubu)

Field validation will evaluate the actual research question under controlled pedestrian routes. *(Saha validation gerçek araştırma sorusunu kontrollü yaya rotaları altında değerlendirecektir.)*

---

# 213. Straight Route Test (Düz Rota Testi)

A straight route will evaluate accumulated distance and heading drift with minimal turning complexity. *(Düz rota minimum dönüş karmaşıklığıyla birikmiş mesafe ve heading drift'ini değerlendirecektir.)*

---

# 214. Turn-Heavy Route Test (Dönüş Yoğun Rota Testi)

A multi-turn route will stress heading estimation and fusion. *(Multi-turn rota heading estimation ve fusion'ı zorlayacaktır.)*

---

# 215. Closed-Loop Test (Kapalı Döngü Testi)

A closed or near-closed route will support closure-error analysis. *(Kapalı veya yaklaşık kapalı rota closure-error analizini destekleyecektir.)*

---

# 216. Walk-Stop-Walk Test (Yürü-Dur-Yürü Testi)

This route will evaluate stationary detection, false-step suppression, and restart behavior. *(Bu rota stationary detection, false-step suppression ve restart davranışını değerlendirecektir.)*

---

# 217. Running Segment Test (Koşu Segmenti Testi)

If running is retained in the formal motion model, controlled running segments will evaluate running-specific behavior. *(Koşma resmî motion model içerisinde korunursa kontrollü running segment'leri running-specific davranışı değerlendirecektir.)*

---

# 218. Magnetic Disturbance Route Test (Manyetik Bozulma Rota Testi)

A route containing magnetic disturbance will test heading-quality degradation and fusion response. *(Magnetic disturbance içeren rota heading-quality degradation ve fusion tepkisini test edecektir.)*

---

# 219. Low-Texture ARCore Route Test (Düşük Texture ARCore Rota Testi)

A visually weak environment will test ARCore degradation and PDR fallback. *(Görsel olarak zayıf ortam ARCore degradation ve PDR fallback'i test edecektir.)*

---

# 220. Indoor Test Consideration (İç Mekân Testi Değerlendirmesi)

Indoor tests may be useful for relative-navigation behavior but GNSS cannot be assumed to provide reliable ground truth indoors. *(Indoor testler göreli navigasyon davranışı için kullanışlı olabilir ancak GNSS'in iç mekânda güvenilir ground truth sağlayacağı varsayılamaz.)*

---

# 221. Indoor Evaluation Alternative (İç Mekân Değerlendirme Alternatifi)

Indoor sessions may use known geometry, checkpoints, measured route distance, or closure error rather than pretending weak GNSS is precise ground truth. *(Indoor oturumlar zayıf GNSS'i precise ground truth gibi göstermek yerine bilinen geometri, checkpoint, ölçülmüş rota mesafesi veya closure error kullanabilir.)*

---

# 222. Matched Configuration Testing (Eşleşmiş Yapılandırma Testi)

Configurations A-D should be evaluated on matched routes and denial intervals where practical. *(Configuration A-D uygulanabilir olduğunda eşleşmiş rotalar ve kesintili aralıklar üzerinde değerlendirilmelidir.)*

---

# 223. Same-Session Replay Preference (Aynı Oturum Replay Tercihi)

Where component comparison can be performed through replay, identical recorded input is preferred over physically repeating the route for each algorithm. *(Bileşen karşılaştırması replay üzerinden yapılabildiğinde her algoritma için fiziksel rotayı tekrar etmek yerine aynı kaydedilmiş input tercih edilir.)*

---

# 224. Physical Repeat Requirement (Fiziksel Tekrar Gereksinimi)

Final system validation still requires repeated physical sessions because environmental and sensor behavior vary between walks. *(Nihai sistem validation yine de tekrarlanan fiziksel oturumlar gerektirir çünkü çevresel ve sensör davranışı yürüyüşler arasında değişir.)*

---

# 225. Principal Repeat Plan (Temel Tekrar Planı)

The provisional final design prefers at least three repeated sessions for each principal route type. *(Geçici nihai tasarım her temel rota türü için en az üç tekrarlanan oturumu tercih eder.)*

---

# 226. Principal Route Types (Temel Rota Türleri)

The current principal route set is straight, multi-turn, and closed or near-closed. *(Mevcut temel rota seti düz, multi-turn ve kapalı veya yaklaşık kapalı rotadır.)*

---

# 227. Approximate Principal Session Count (Yaklaşık Temel Oturum Sayısı)

This produces approximately nine primary repeated sessions before additional stress scenarios are included. *(Bu ek stress senaryoları dahil edilmeden önce yaklaşık dokuz temel tekrarlanan oturum üretir.)*

---

# 228. No Fabricated Statistical Power Claim (Uydurulmuş İstatistiksel Güç İddiası Olmaması)

This repeat count is a practical engineering baseline and is not presented as a formal statistical power calculation. *(Bu tekrar sayısı pratik mühendislik baseline'ıdır ve resmî statistical power calculation olarak sunulmamaktadır.)*

---

# 229. Evaluation Metrics (Değerlendirme Metrikleri)

Formal navigation evaluation will include the metrics already defined in earlier documents. *(Resmî navigasyon değerlendirmesi önceki dokümanlarda tanımlanan metrikleri içerecektir.)*

```text
Mean Position Error
Median Position Error
RMSE
Final Position Error
P95 Position Error
Drift per Minute
Drift per Travel Distance
Heading MAE
Step Count Error
Step Length MAE
ARCore Availability
AI Accuracy
AI Macro F1
Inference Latency
Battery Usage
CPU / Memory
```

---

# 230. Primary Research Metric (Temel Araştırma Metriği)

Median position error across matched final sessions remains one of the primary NAVGUARD comparison metrics. *(Eşleşmiş nihai oturumlar arasındaki median position error temel NAVGUARD karşılaştırma metriklerinden biri olarak kalır.)*

---

# 231. Primary Success Target (Temel Başarı Hedefi)

The provisional primary navigation target remains at least a 20% reduction in median position error for the full NAVGUARD configuration compared with PDR-only baseline across matched final sessions. *(Geçici temel navigasyon hedefi eşleşmiş nihai oturumlar üzerinde tam NAVGUARD yapılandırmasının PDR-only baseline'a göre median position error değerinde en az %20 azalma sağlamasıdır.)*

---

# 232. AI Success Target (AI Başarı Hedefi)

The provisional motion-classification target remains Macro F1 of at least 0.90 on a held-out session-wise test set. *(Geçici motion-classification hedefi held-out session-wise test setinde en az 0.90 Macro F1 olarak kalmaktadır.)*

---

# 233. Step Count Target (Adım Sayısı Hedefi)

The provisional controlled step-count absolute error target remains at or below 5%. *(Geçici kontrollü step-count absolute error hedefi %5 veya altında kalmaktadır.)*

---

# 234. AI Latency Target (AI Latency Hedefi)

The provisional AI latency target remains below approximately 50 ms per inference on the Redmi Note 9 Pro. *(Geçici AI latency hedefi Redmi Note 9 Pro üzerinde inference başına yaklaşık 50 ms'nin altında kalmaktadır.)*

---

# 235. Targets Are Not Results (Hedefler Sonuç Değildir)

These values are planning targets and must not be reported as measured performance until experiments produce real results. *(Bu değerler planlama hedefleridir ve deneyler gerçek sonuç üretmeden measured performance olarak raporlanmamalıdır.)*

---

# 236. Benchmark Configurations (Benchmark Yapılandırmaları)

The formal comparison will preserve configurations A-D. *(Resmî karşılaştırma Configuration A-D'yi koruyacaktır.)*

```text
A — PDR Only
B — PDR + Improved / Fused Heading
C — PDR + ARCore
D — Full NAVGUARD AI-Assisted Fusion
```

---

# 237. Configuration A Purpose (Configuration A Amacı)

Configuration A provides the reproducible baseline. *(Configuration A tekrarlanabilir baseline sağlar.)*

---

# 238. Configuration B Purpose (Configuration B Amacı)

Configuration B isolates the value of improved heading handling. *(Configuration B geliştirilmiş heading yönetiminin değerini izole eder.)*

---

# 239. Configuration C Purpose (Configuration C Amacı)

Configuration C isolates the value of ARCore relative tracking when combined with PDR. *(Configuration C PDR ile birleştirildiğinde ARCore relative tracking'in değerini izole eder.)*

---

# 240. Configuration D Purpose (Configuration D Amacı)

Configuration D evaluates the complete AI-assisted fusion system. *(Configuration D tam AI-assisted fusion sistemini değerlendirir.)*

---

# 241. Fair Comparison Principle (Adil Karşılaştırma İlkesi)

Configurations must differ only in the intended experimental component wherever practical. *(Yapılandırmalar uygulanabilir olduğunda yalnızca amaçlanan deneysel bileşende farklılık göstermelidir.)*

---

# 242. Same Denial Boundary Principle (Aynı Kesinti Sınırı İlkesi)

Replay comparisons should use the same denial start and recovery boundaries for every compared configuration. *(Replay karşılaştırmaları karşılaştırılan her yapılandırma için aynı kesinti başlangıcı ve recovery sınırlarını kullanmalıdır.)*

---

# 243. Same Raw Evidence Principle (Aynı Ham Kanıt İlkesi)

Replay comparisons should use identical raw sensor and reference evidence. *(Replay karşılaştırmaları aynı ham sensör ve referans kanıtını kullanmalıdır.)*

---

# 244. Same Metric Pipeline Principle (Aynı Metrik Hattı İlkesi)

Compared configurations will use the same evaluation-code version for the primary metrics. *(Karşılaştırılan yapılandırmalar temel metrikler için aynı evaluation-code sürümünü kullanacaktır.)*

---

# 245. Parameter Freeze (Parametre Sabitleme)

Thresholds, model artifacts, filter settings, recovery rules, and benchmark configuration will be frozen before final evaluation. *(Eşikler, model artifact'ları, filter ayarları, recovery kuralları ve benchmark yapılandırması nihai değerlendirmeden önce sabitlenecektir.)*

---

# 246. Change After Freeze (Sabitleme Sonrası Değişiklik)

Any necessary post-freeze change must be documented in Page 43 and may require restarting the affected final benchmark set. *(Gerekli herhangi bir post-freeze değişiklik Page 43 içerisinde dokümante edilmeli ve etkilenen final benchmark setinin yeniden başlatılmasını gerektirebilir.)*

---

# 247. Test Evidence (Test Kanıtı)

Every formal test execution should produce inspectable evidence. *(Her resmî test çalıştırması incelenebilir kanıt üretmelidir.)*

---

# 248. Candidate Test Evidence Types (Aday Test Kanıt Türleri)

```text
JUnit / Flutter / pytest result
CSV log
JSON manifest
Screenshot
Profiler capture
Replay output
Metric table
Field-test note
Device log
Integrity report
```

---

# 249. Test Evidence Directory (Test Kanıt Klasörü)

Formal test evidence may be stored separately from ordinary navigation sessions. *(Resmî test kanıtı normal navigasyon oturumlarından ayrı saklanabilir.)*

```text
tests/evidence/
```

---

# 250. Test Run Identity (Test Run Kimliği)

Formal automated and manual test executions may receive unique test-run identifiers. *(Resmî otomatik ve manuel test çalıştırmaları benzersiz test-run identifier'ları alabilir.)*

---

# 251. Candidate Test Run Record (Aday Test Run Kaydı)

```text
test_run_id
timestamp
build_id
device_id
test_suite
configuration
result
evidence_path
```

---

# 252. Automated Test Suites (Otomatik Test Suite'leri)

NAVGUARD will maintain separate automated suites for Flutter, Kotlin/Android, and Python code. *(NAVGUARD Flutter, Kotlin/Android ve Python kodu için ayrı otomatik suite'ler tutacaktır.)*

---

# 253. Flutter Automated Tests (Flutter Otomatik Testleri)

Flutter tests will cover domain logic written in Dart, state management, UI state mapping, and widget-level behavior. *(Flutter testleri Dart içerisinde yazılan domain logic'i, state management'ı, UI state mapping'i ve widget-level davranışı kapsayacaktır.)*

---

# 254. Kotlin Automated Tests (Kotlin Otomatik Testleri)

Kotlin tests will cover native adapters, sensor models, permission handling, platform-channel contracts, GNSS authorization logic, ARCore wrappers, and LiteRT runtime interfaces where testable. *(Kotlin testleri test edilebilir olduğunda native adapter'ları, sensör modellerini, permission yönetimini, platform-channel contract'larını, GNSS authorization logic'ini, ARCore wrapper'larını ve LiteRT runtime arayüzlerini kapsayacaktır.)*

---

# 255. Python Automated Tests (Python Otomatik Testleri)

Python tests will cover preprocessing, dataset splitting, feature generation, model evaluation, replay utilities, and metric calculations. *(Python testleri preprocessing'i, dataset splitting'i, feature generation'ı, model evaluation'ı, replay utility'lerini ve metric calculation'ları kapsayacaktır.)*

---

# 256. Cross-Language Golden Tests (Cross-Language Golden Testleri)

Frozen golden input/output fixtures will be used where Dart, Kotlin, and Python must implement equivalent mathematics or preprocessing. *(Dart, Kotlin ve Python'un eşdeğer matematik veya preprocessing uygulaması gereken yerlerde sabitlenmiş golden input/output fixture'ları kullanılacaktır.)*

---

# 257. Golden Fixture Example (Golden Fixture Örneği)

A known sensor window may have one reference normalized tensor shared by Python and mobile tests. *(Bilinen sensor window Python ve mobil testler tarafından paylaşılan tek referans normalized tensor'a sahip olabilir.)*

---

# 258. Continuous Test Execution (Sürekli Test Çalıştırma)

Automated tests should be run frequently during development rather than only before the final demo. *(Otomatik testler yalnızca final demo öncesinde değil geliştirme boyunca sık çalıştırılmalıdır.)*

---

# 259. Test Gate Before New Feature Integration (Yeni Özellik Entegrasyonu Öncesi Test Gate)

A major subsystem should not be integrated into the full navigation pipeline while its basic deterministic tests are failing. *(Temel deterministik testleri başarısızken büyük alt sistem tam navigasyon hattına entegre edilmemelidir.)*

---

# 260. Regression Testing (Regression Testing)

Previously passing critical tests will be rerun after major architecture or algorithm changes. *(Daha önce geçen kritik testler büyük mimari veya algoritma değişikliklerinden sonra yeniden çalıştırılacaktır.)*

---

# 261. Regression Priority (Regression Önceliği)

Ground Truth Firewall, PDR mathematics, coordinate transforms, recovery ordering, session finalization, and replay determinism are high-priority regression suites. *(Ground Truth Firewall, PDR matematiği, koordinat dönüşümleri, recovery ordering, session finalization ve replay determinism yüksek öncelikli regression suite'leridir.)*

---

# 262. Smoke Tests (Smoke Testleri)

A compact smoke-test suite will verify that the application can start, create a session, acquire required sensors, establish basic state, and finalize without obvious failure. *(Kompakt smoke-test suite uygulamanın başlayabildiğini, oturum oluşturabildiğini, gerekli sensörleri alabildiğini, temel durumu kurabildiğini ve belirgin hata olmadan finalize edebildiğini doğrulayacaktır.)*

---

# 263. Pre-Field Smoke Test (Saha Öncesi Smoke Test)

A smoke test should be completed before every important field-test day. *(Her önemli saha test gününden önce smoke test tamamlanmalıdır.)*

---

# 264. Candidate Pre-Field Checklist (Aday Saha Öncesi Checklist)

```text
App launches
Required permissions valid
Sensors active
GNSS provider active
Anchor acquisition works
ARCore works if required
AI model valid
Logging active
Storage available
Ground Truth Firewall self-test passes
Export path not required for active recording
```

---

# 265. Manual Test Protocols (Manuel Test Protokolleri)

Some physical behaviors cannot be fully automated and will use repeatable manual protocols. *(Bazı fiziksel davranışlar tamamen otomatikleştirilemez ve tekrarlanabilir manuel protokoller kullanacaktır.)*

---

# 266. Manual Protocol Documentation (Manuel Protokol Dokümantasyonu)

Each manual protocol will specify device placement, route, starting orientation, operator actions, and expected evidence. *(Her manuel protokol cihaz yerleşimini, rotayı, başlangıç yönelimini, operatör işlemlerini ve beklenen kanıtı belirtecektir.)*

---

# 267. Phone Placement Control (Telefon Yerleşim Kontrolü)

Minimum formal experiments will use a controlled phone placement unless a specific placement-robustness experiment is being performed. *(Belirli placement-robustness deneyi gerçekleştirilmiyorsa minimum resmî deneyler kontrollü telefon yerleşimi kullanacaktır.)*

---

# 268. Route Marking (Rota İşaretleme)

Known route start, turn, checkpoint, and end positions should be documented before formal field runs. *(Bilinen rota başlangıcı, dönüş, checkpoint ve bitiş konumları resmî saha run'larından önce dokümante edilmelidir.)*

---

# 269. Environmental Notes (Çevresel Notlar)

Field sessions may record environment type, weather relevance, magnetic disturbance, visual texture, and unusual events where useful. *(Saha oturumları kullanışlı olduğunda ortam türünü, hava durumu ilgisini, magnetic disturbance'ı, visual texture'ı ve olağandışı olayları kaydedebilir.)*

---

# 270. Operator Behavior Consistency (Operatör Davranış Tutarlılığı)

Formal repeated routes should use approximately consistent walking behavior where practical. *(Resmî tekrarlanan rotalar uygulanabilir olduğunda yaklaşık tutarlı walking behavior kullanmalıdır.)*

---

# 271. Ground Truth Quality During Field Tests (Saha Testlerinde Ground Truth Kalitesi)

GNSS ground truth quality must be reviewed before using a session for precise positional metrics. *(Bir oturum precise positional metric'lerde kullanılmadan önce GNSS ground truth kalitesi incelenmelidir.)*

---

# 272. Reference Quality Exclusion (Referans Kalite Hariç Tutma)

A session with unacceptable reference quality may remain valuable for qualitative or subsystem analysis but must not silently enter the primary positional benchmark. *(Kabul edilemez referans kalitesine sahip oturum qualitative veya alt sistem analizi için değerli kalabilir ancak temel positional benchmark'a sessizce girmemelidir.)*

---

# 273. Exclusion Rules Must Be Predeclared (Hariç Tutma Kuralları Önceden Tanımlanmalıdır)

Ground-truth exclusion criteria must be frozen before reviewing final benchmark outcomes. *(Ground-truth exclusion kriterleri nihai benchmark sonuçları incelenmeden önce sabitlenmelidir.)*

---

# 274. No Cherry-Picking Sessions (Session Cherry-Picking Olmaması)

Final reporting will not include only the routes where NAVGUARD performed best. *(Nihai raporlama yalnızca NAVGUARD'ın en iyi performans gösterdiği rotaları içermeyecektir.)*

---

# 275. Failed Sessions Are Evidence (Başarısız Oturumlar Kanıttır)

A validly recorded but poorly performing session remains experimental evidence. *(Geçerli şekilde kaydedilmiş ancak kötü performans gösteren oturum deneysel kanıt olarak kalır.)*

---

# 276. Invalid Session vs Poor Result (Geçersiz Oturum ile Kötü Sonuç Farkı)

A scientifically invalid session must be distinguished from a scientifically valid session with poor navigation accuracy. *(Bilimsel olarak geçersiz oturum kötü navigasyon doğruluğuna sahip bilimsel olarak geçerli oturumdan ayrılmalıdır.)*

---

# 277. Test Result States (Test Sonuç Durumları)

Formal test cases will use explicit result states. *(Resmî test case'ler açık sonuç durumlarını kullanacaktır.)*

```text
PASS
FAIL
BLOCKED
NOT_RUN
PASS_WITH_WARNING
```

---

# 278. BLOCKED Test Result (BLOCKED Test Sonucu)

A test is `BLOCKED` when required environmental or hardware preconditions are unavailable. *(Gerekli çevresel veya hardware precondition'lar kullanılamadığında test `BLOCKED` olur.)*

---

# 279. PASS_WITH_WARNING Result (PASS_WITH_WARNING Sonucu)

`PASS_WITH_WARNING` may be used only where the formal acceptance condition passes but a non-blocking diagnostic issue is observed. *(`PASS_WITH_WARNING` yalnızca resmî acceptance condition geçerken blocking olmayan diagnostic problem gözlemlendiğinde kullanılabilir.)*

---

# 280. Test Failure Logging (Test Hata Logging)

Every failed formal test will retain enough evidence to reproduce or diagnose the failure. *(Başarısız her resmî test hatayı yeniden üretmek veya teşhis etmek için yeterli kanıtı koruyacaktır.)*

---

# 281. Bug Severity Model (Bug Önem Modeli)

Defects may be classified by impact. *(Defect'ler etkiye göre sınıflandırılabilir.)*

```text
CRITICAL
HIGH
MEDIUM
LOW
```

---

# 282. CRITICAL Bug Example (CRITICAL Bug Örneği)

Ground Truth Firewall violation is a critical defect. *(Ground Truth Firewall ihlali critical defect'tir.)*

---

# 283. HIGH Bug Example (HIGH Bug Örneği)

Loss of mandatory sensor logging during valid navigation may be a high-severity defect. *(Geçerli navigasyon sırasında zorunlu sensör logging kaybı high-severity defect olabilir.)*

---

# 284. MEDIUM Bug Example (MEDIUM Bug Örneği)

Incorrect diagnostic labeling that does not affect estimator state may be medium severity. *(Tahmin motoru durumunu etkilemeyen yanlış diagnostic labeling medium severity olabilir.)*

---

# 285. LOW Bug Example (LOW Bug Örneği)

Minor spacing or non-critical visual inconsistency may be low severity. *(Küçük spacing veya kritik olmayan görsel tutarsızlık low severity olabilir.)*

---

# 286. Critical Bug Gate (Kritik Bug Gate)

No known critical defect may remain open when final benchmark collection begins. *(Nihai benchmark veri toplama başladığında bilinen hiçbir critical defect açık kalmamalıdır.)*

---

# 287. High Bug Review (Yüksek Bug İncelemesi)

Known high-severity defects must be explicitly reviewed before final benchmark collection. *(Bilinen high-severity defect'ler nihai benchmark veri toplama öncesinde açık şekilde incelenmelidir.)*

---

# 288. Benchmark Readiness Gate (Benchmark Hazırlık Gate'i)

Final benchmark collection will begin only after a dedicated readiness gate passes. *(Nihai benchmark veri toplama yalnızca özel readiness gate geçtikten sonra başlayacaktır.)*

---

# 289. Benchmark Readiness Requirements (Benchmark Hazırlık Gereksinimleri)

```text
Critical unit tests PASS
Critical integration tests PASS
Ground Truth Firewall PASS
Sensor timing validated
Logging stability validated
Session finalization validated
Recovery ordering validated
Model hash validated
Configuration frozen
Reference routes documented
Build identity frozen
```

---

# 290. Final Build Freeze (Nihai Build Sabitleme)

The application build used for final benchmark sessions will be identified explicitly. *(Nihai benchmark oturumları için kullanılan application build açık şekilde tanımlanacaktır.)*

---

# 291. Build Change During Final Benchmark (Final Benchmark Sırasında Build Değişikliği)

A material application change during final benchmark collection may require repeating previously collected benchmark sessions. *(Nihai benchmark veri toplama sırasında anlamlı application değişikliği daha önce toplanmış benchmark oturumlarının tekrar edilmesini gerektirebilir.)*

---

# 292. Benchmark Configuration Manifest (Benchmark Yapılandırma Manifest'i)

The frozen benchmark configuration will be stored as a machine-readable artifact. *(Sabitlenmiş benchmark yapılandırması machine-readable artifact olarak saklanacaktır.)*

---

# 293. Test Reproducibility (Test Tekrarlanabilirliği)

Formal automated tests should be runnable from documented commands or scripts. *(Resmî otomatik testler dokümante edilmiş command veya script'lerden çalıştırılabilir olmalıdır.)*

---

# 294. Manual Test Reproducibility (Manuel Test Tekrarlanabilirliği)

Manual field protocols must be documented sufficiently for the same operator to repeat them consistently. *(Manuel saha protokolleri aynı operatörün onları tutarlı şekilde tekrar edebilmesi için yeterince dokümante edilmelidir.)*

---

# 295. Randomness Control (Randomness Kontrolü)

ML and replay tools that use random behavior will record or freeze relevant random seeds where practical. *(Random behavior kullanan ML ve replay araçları uygulanabilir olduğunda ilgili random seed'leri kaydedecek veya sabitleyecektir.)*

---

# 296. Non-Deterministic Runtime Behavior (Deterministik Olmayan Runtime Davranışı)

Some physical sensor and platform behavior is inherently non-deterministic. *(Bazı fiziksel sensör ve platform davranışları doğası gereği deterministik değildir.)*

Reproducibility therefore means controlled protocol and traceable evidence rather than identical physical samples across repeated walks. *(Bu nedenle reproducibility tekrarlanan yürüyüşlerde tamamen aynı fiziksel sample'lar yerine kontrollü protokol ve izlenebilir kanıt anlamına gelir.)*

---

# 297. Test Documentation (Test Dokümantasyonu)

Test cases, test runs, failures, evidence links, and acceptance decisions will be documented systematically. *(Test case'ler, test run'lar, failure'lar, evidence link'leri ve acceptance decision'ları sistematik olarak dokümante edilecektir.)*

---

# 298. Daily Development Testing (Günlük Geliştirme Testleri)

The 24-day implementation plan will include continuous testing rather than reserving testing for the final days. *(24 günlük implementation plan testing'i yalnızca son günlere bırakmak yerine sürekli testing içerecektir.)*

---

# 299. Day-23 Benchmark Role (23. Gün Benchmark Rolü)

The roadmap's benchmark and bug-fixing day will be a final consolidation phase rather than the first time NAVGUARD is tested. *(Roadmap içerisindeki benchmark ve bug-fixing günü NAVGUARD'ın ilk kez test edildiği zaman yerine final consolidation aşaması olacaktır.)*

---

# 300. Minimum Successful Test Strategy (Minimum Başarılı Test Stratejisi)

The minimum successful test system will include deterministic math tests, sensor acquisition checks, PDR tests, GNSS isolation tests, session lifecycle tests, replay tests, AI parity tests, recovery tests, and repeated physical field sessions. *(Minimum başarılı test sistemi deterministik matematik testlerini, sensör acquisition kontrollerini, PDR testlerini, GNSS izolasyon testlerini, oturum lifecycle testlerini, replay testlerini, AI parity testlerini, recovery testlerini ve tekrarlanan fiziksel saha oturumlarını içerecektir.)*

---

# 301. Target Successful Test Strategy (Hedef Başarılı Test Stratejisi)

The target test system will additionally include cross-language golden tests, extensive failure injection, covariance-consistency analysis, automated traceability, performance profiling, export integrity checks, and full A-D matched benchmark evaluation. *(Hedef test sistemi ek olarak cross-language golden testleri, kapsamlı failure injection'ı, covariance-consistency analizini, otomatik traceability'yi, performans profiling'i, export integrity kontrollerini ve tam A-D eşleşmiş benchmark değerlendirmesini içerecektir.)*

---

# 302. Optional Testing Enhancements (İsteğe Bağlı Test İyileştirmeleri)

Optional enhancements may include automated CI pipelines. *(İsteğe bağlı iyileştirmeler otomatik CI pipeline'larını içerebilir.)*

Optional enhancements may include additional Android-device compatibility testing. *(İsteğe bağlı iyileştirmeler ek Android cihaz compatibility testlerini içerebilir.)*

Optional enhancements may include property-based testing for mathematical invariants. *(İsteğe bağlı iyileştirmeler matematiksel invariant'lar için property-based testing içerebilir.)*

---

# 303. Testing Non-Goals (Test Olmayan Hedefler)

NAVGUARD will not claim complete correctness merely because automated unit tests pass. *(NAVGUARD yalnızca otomatik unit testler geçtiği için tam doğruluk iddia etmeyecektir.)*

NAVGUARD will not claim field performance from emulator tests. *(NAVGUARD emulator testlerinden saha performansı iddia etmeyecektir.)*

NAVGUARD will not treat replay as a substitute for all physical-device validation. *(NAVGUARD replay'i tüm fiziksel cihaz validation'ın yerine koymayacaktır.)*

---

# 304. Additional Testing Non-Goals (Ek Test Olmayan Hedefler)

NAVGUARD will not tune final parameters on the final benchmark set. *(NAVGUARD nihai parametreleri final benchmark seti üzerinde tune etmeyecektir.)*

NAVGUARD will not discard scientifically valid poor results solely because they reduce headline performance. *(NAVGUARD headline performance'ı düşürdüğü için bilimsel olarak geçerli kötü sonuçları atmayacaktır.)*

---

# 305. Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kararlar)

NAVGUARD will use a layered test strategy combining unit, integration, replay, device, field, performance, failure-injection, security, UI, and acceptance testing. *(NAVGUARD unit, integration, replay, device, field, performance, failure-injection, security, UI ve acceptance testing'i birleştiren katmanlı test stratejisi kullanacaktır.)*

---

# 306. Physical Device Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Fiziksel Cihaz Kararları)

The Redmi Note 9 Pro will remain the authoritative device for final sensor, ARCore, performance, battery, and field-navigation validation. *(Redmi Note 9 Pro nihai sensör, ARCore, performans, batarya ve saha navigasyon validation için ana cihaz olarak kalacaktır.)*

---

# 307. Emulator Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Emulator Kararları)

Emulator results will not be treated as evidence of real sensor or field-navigation performance. *(Emulator sonuçları gerçek sensör veya saha navigasyon performansı kanıtı olarak ele alınmayacaktır.)*

---

# 308. Replay Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Replay Kararları)

Replay is a required verification mechanism for deterministic algorithm comparison. *(Replay deterministik algoritma karşılaştırması için gerekli verification mekanizmasıdır.)*

Replay will preserve causality and Ground Truth Firewall rules. *(Replay nedenselliği ve Ground Truth Firewall kurallarını koruyacaktır.)*

---

# 309. Ground Truth Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Ground Truth Kararları)

Ground Truth Firewall verification is a mandatory Benchmark readiness gate. *(Ground Truth Firewall verification zorunlu Benchmark readiness gate'idir.)*

Any unauthorized GNSS estimator update invalidates the corresponding formal denied interval. *(Herhangi bir unauthorized GNSS estimator update karşılık gelen resmî kesintili aralığı geçersiz kılar.)*

---

# 310. ML Testing Decisions Frozen by This Document (Bu Dokümanla Sabitlenen ML Test Kararları)

Machine-learning evaluation will use session-wise separation. *(Machine-learning değerlendirmesi session-wise separation kullanacaktır.)*

Training-mobile preprocessing parity and on-device model parity will be explicitly tested. *(Training-mobile preprocessing parity ve on-device model parity açık şekilde test edilecektir.)*

---

# 311. Navigation Comparison Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Navigasyon Karşılaştırma Kararları)

Configurations A-D will remain the formal comparison framework. *(Configuration A-D resmî karşılaştırma framework'ü olarak kalacaktır.)*

Matched raw evidence and matched denial intervals will be preferred wherever replay makes that possible. *(Replay bunu mümkün kıldığında matched raw evidence ve matched denial interval'lar tercih edilecektir.)*

---

# 312. Benchmark Integrity Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Benchmark Bütünlük Kararları)

Final benchmark parameters will be frozen before the final benchmark results are inspected. *(Nihai benchmark parametreleri final benchmark sonuçları incelenmeden önce sabitlenecektir.)*

Post-hoc tuning on final benchmark data is forbidden. *(Final benchmark verisi üzerinde post-hoc tuning yasaktır.)*

---

# 313. Field Repeat Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Saha Tekrar Kararları)

The provisional principal field plan will target at least three repeats each for straight, turn-heavy, and closed or near-closed route categories. *(Geçici temel saha planı düz, dönüş yoğun ve kapalı veya yaklaşık kapalı rota kategorilerinin her biri için en az üç tekrar hedefleyecektir.)*

---

# 314. Failure Testing Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Hata Test Kararları)

ARCore loss, AI failure, logging delay, storage failure, permission revocation, recovery failure, and application interruption will be tested deliberately during development. *(ARCore kaybı, AI hatası, logging gecikmesi, depolama hatası, permission revocation, recovery hatası ve uygulama kesintisi geliştirme sırasında bilinçli olarak test edilecektir.)*

---

# 315. Evidence Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kanıt Kararları)

Formal test results will retain evidence sufficient to determine what build, device, configuration, and input produced the result. *(Resmî test sonuçları hangi build'in, cihazın, yapılandırmanın ve girdinin sonucu ürettiğini belirlemek için yeterli kanıtı koruyacaktır.)*

---

# 316. Bug Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Bug Kararları)

No known critical defect may remain open when final benchmark collection begins. *(Nihai benchmark veri toplama başladığında bilinen hiçbir critical defect açık kalamaz.)*

---

# 317. Decisions Pending Physical Audit (Fiziksel Audit Bekleyen Kararlar)

Final sensor-rate tolerance thresholds remain pending Redmi Note 9 Pro timing measurements. *(Nihai sensör rate tolerance eşikleri Redmi Note 9 Pro zamanlama ölçümlerini beklemektedir.)*

---

# 318. Decisions Pending Pilot Field Tests (Pilot Saha Testlerini Bekleyen Kararlar)

Final route lengths, denied durations, and controlled field-test timing remain pending pilot-session practicality. *(Nihai rota uzunlukları, kesintili süreler ve kontrollü saha test zamanlaması pilot oturum practicality'sini beklemektedir.)*

---

# 319. Decisions Pending Performance Profiling (Performans Profiling Bekleyen Kararlar)

Final acceptable memory growth, writer queue thresholds, battery thresholds, and thermal warning thresholds remain pending measured runtime behavior. *(Nihai kabul edilebilir memory growth, writer queue eşikleri, batarya eşikleri ve termal warning eşikleri ölçülmüş runtime davranışını beklemektedir.)*

---

# 320. Decisions Pending Covariance Calibration (Kovaryans Kalibrasyonunu Bekleyen Kararlar)

Final uncertainty-consistency acceptance thresholds remain pending development-session covariance calibration. *(Nihai uncertainty-consistency acceptance eşikleri development-session covariance calibration'ını beklemektedir.)*

---

# 321. Decisions Pending Final Benchmark Protocol (Nihai Benchmark Protokolünü Bekleyen Kararlar)

The exact final inclusion and exclusion policy for positional benchmark sessions will be frozen before formal benchmark execution. *(Positional benchmark oturumları için kesin final inclusion ve exclusion politikası resmî benchmark çalıştırılmadan önce sabitlenecektir.)*

---

# 322. Final Testing Strategy Statement (Nihai Test Stratejisi Bildirimi)

**NAVGUARD will be verified through a layered test architecture in which deterministic mathematics and domain rules are tested first, subsystem interfaces are then tested through integration and replay, platform-dependent behavior is validated on the Xiaomi Redmi Note 9 Pro, and complete research claims are evaluated only through controlled repeated field experiments.** *(NAVGUARD deterministik matematik ve domain kurallarının önce test edildiği, alt sistem arayüzlerinin daha sonra integration ve replay üzerinden test edildiği, platform bağımlı davranışın Xiaomi Redmi Note 9 Pro üzerinde doğrulandığı ve tam araştırma iddialarının yalnızca kontrollü tekrarlanan saha deneyleri üzerinden değerlendirildiği katmanlı test mimarisiyle verification edilecektir.)*

**Replay will provide the primary mechanism for reproducible algorithm comparison because identical raw sensor evidence, configuration, denial boundaries, and timing can be presented to competing PDR, heading, ARCore, AI, and fusion configurations without requiring a new physical walk for every software change.** *(Replay tekrarlanabilir algoritma karşılaştırması için temel mekanizmayı sağlayacak çünkü aynı ham sensör kanıtı, yapılandırma, kesinti sınırları ve zamanlama her yazılım değişikliği için yeni fiziksel yürüyüş gerektirmeden rakip PDR, heading, ARCore, AI ve fusion yapılandırmalarına sunulabilecektir.)*

**Replay will not replace physical-device validation, because sensor noise, magnetic disturbance, ARCore tracking, battery consumption, thermal behavior, GNSS quality, and pedestrian motion are physical phenomena that must ultimately be observed on the target device.** *(Replay fiziksel cihaz validation'ın yerini almayacaktır çünkü sensor noise, magnetic disturbance, ARCore tracking, batarya tüketimi, termal davranış, GNSS kalitesi ve yaya hareketi nihai olarak hedef cihaz üzerinde gözlemlenmesi gereken fiziksel olaylardır.)*

**Ground Truth Firewall isolation will be treated as a mandatory research-integrity gate, and every valid denied interval must demonstrate that protected GNSS continued to be available to the independent reference logger while remaining completely unavailable to PDR, AI, EKF, anchor management, uncertainty correction, and all other estimator pathways.** *(Ground Truth Firewall izolasyonu zorunlu araştırma bütünlüğü gate'i olarak ele alınacak ve her geçerli kesintili aralık korunan GNSS'in bağımsız referans logger için kullanılabilir kalırken PDR, AI, EKF, anchor yönetimi, belirsizlik correction ve diğer tüm tahmin motoru yolları için tamamen kullanılamaz kaldığını göstermelidir.)*

**Final benchmark evaluation will preserve configurations A through D, use matched routes and replay inputs where practical, freeze algorithms and thresholds before the final benchmark outcomes are inspected, and retain both successful and poor scientifically valid sessions rather than selecting only favorable results.** *(Nihai benchmark değerlendirmesi Configuration A-D'yi koruyacak, uygulanabilir olduğunda eşleşmiş rotaları ve replay girdilerini kullanacak, nihai benchmark sonuçları incelenmeden önce algoritmaları ve eşikleri sabitleyecek ve yalnızca olumlu sonuçları seçmek yerine hem başarılı hem kötü bilimsel olarak geçerli oturumları koruyacaktır.)*

**The final reported NAVGUARD results will therefore depend on a traceable chain from requirement → test → evidence → benchmark session → metric, allowing every major performance or reliability claim to be linked back to reproducible technical evidence rather than subjective observation.** *(Bu nedenle nihai raporlanan NAVGUARD sonuçları requirement → test → evidence → benchmark session → metric şeklinde izlenebilir zincire dayanacak ve her büyük performans veya güvenilirlik iddiasının subjective observation yerine tekrarlanabilir teknik kanıta geri bağlanmasına izin verecektir.)*

---

# 323. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development Testing Strategy Completed *(Doküman Durumu: Geliştirme Öncesi Test Stratejisi Tamamlandı)*

**Testing Philosophy:** Layered Verification + Physical Validation *(Test Felsefesi: Katmanlı Verification + Fiziksel Validation)*

**Primary Test Layers:** Unit + Integration + System + Replay + Device + Field *(Temel Test Katmanları: Unit + Integration + System + Replay + Device + Field)*

**Failure-Injection Testing:** Mandatory During Development *(Failure-Injection Testing: Geliştirme Sırasında Zorunlu)*

**Ground Truth Firewall Test:** Mandatory Benchmark Gate *(Ground Truth Firewall Testi: Zorunlu Benchmark Gate)*

**Primary Physical Test Device:** Xiaomi Redmi Note 9 Pro *(Temel Fiziksel Test Cihazı: Xiaomi Redmi Note 9 Pro)*

**Emulator as Field Evidence:** Forbidden *(Saha Kanıtı Olarak Emulator: Yasak)*

**Replay Determinism:** Mandatory *(Replay Determinizmi: Zorunlu)*

**Replay Causality:** Mandatory *(Replay Nedenselliği: Zorunlu)*

**Replay Ground Truth Isolation:** Mandatory *(Replay Ground Truth İzolasyonu: Zorunlu)*

**Training / Mobile Preprocessing Parity:** Mandatory *(Training / Mobil Preprocessing Parity: Zorunlu)*

**On-Device AI Parity:** Mandatory *(On-Device AI Parity: Zorunlu)*

**ML Split Policy:** Session-Wise *(ML Split Politikası: Session-Wise)*

**Formal Comparison Configurations:** A / B / C / D *(Resmî Karşılaştırma Yapılandırmaları: A / B / C / D)*

**Primary Baseline:** PDR Only *(Temel Baseline: PDR Only)*

**Primary Full System:** Full NAVGUARD AI-Assisted Fusion *(Temel Tam Sistem: Full NAVGUARD AI-Assisted Fusion)*

**Provisional Primary Navigation Target:** ≥20% Median Position Error Reduction vs PDR Baseline *(Geçici Temel Navigasyon Hedefi: PDR Baseline'a Göre ≥%20 Median Position Error Azalması)*

**Provisional Motion AI Target:** Macro F1 ≥0.90 *(Geçici Motion AI Hedefi: Macro F1 ≥0.90)*

**Provisional Step Count Target:** Absolute Error ≤5% *(Geçici Adım Sayısı Hedefi: Absolute Error ≤%5)*

**Provisional AI Inference Latency Target:** <50 ms *(Geçici AI Inference Latency Hedefi: <50 ms)*

**Straight Route Repeats:** Target ≥3 *(Düz Rota Tekrarları: Hedef ≥3)*

**Turn-Heavy Route Repeats:** Target ≥3 *(Dönüş Yoğun Rota Tekrarları: Hedef ≥3)*

**Closed / Near-Closed Route Repeats:** Target ≥3 *(Kapalı / Yaklaşık Kapalı Rota Tekrarları: Hedef ≥3)*

**Approximate Principal Final Sessions:** ~9 Before Stress Scenarios *(Yaklaşık Temel Nihai Oturum: Stress Senaryoları Öncesi ~9)*

**Final Benchmark Parameter Tuning:** Forbidden *(Final Benchmark Parametre Tuning: Yasak)*

**Final Benchmark Session Cherry-Picking:** Forbidden *(Final Benchmark Session Cherry-Picking: Yasak)*

**Scientifically Valid Poor Results:** Retained *(Bilimsel Olarak Geçerli Kötü Sonuçlar: Korunur)*

**Critical Defects at Final Benchmark Start:** Must Equal 0 *(Final Benchmark Başlangıcında Critical Defect: 0 Olmalı)*

**Test Traceability:** Requirement → Test → Evidence *(Test İzlenebilirliği: Requirement → Test → Evidence)*

**Cross-Language Golden Tests:** Target *(Cross-Language Golden Testleri: Hedef)*

**Performance Testing on Debug Build Only:** Forbidden *(Yalnızca Debug Build Üzerinde Performans Testi: Yasak)*

**Combined Stack Test:** Mandatory *(Birleşik Stack Testi: Zorunlu)*

**Crash Recovery Testing:** Mandatory *(Crash Recovery Testing: Zorunlu)*

**Permission Revocation Testing:** Mandatory *(Permission Revocation Testing: Zorunlu)*

**ARCore Loss Testing:** Mandatory for ARCore Profiles *(ARCore Kaybı Testing: ARCore Profilleri İçin Zorunlu)*

**AI Failure Fallback Testing:** Mandatory *(AI Hata Fallback Testing: Zorunlu)*

**Logging Backpressure Testing:** Mandatory *(Logging Backpressure Testing: Zorunlu)*

**Recovery Ordering Testing:** Mandatory *(Recovery Ordering Testing: Zorunlu)*

**Final Sensor Rate Tolerances:** Pending Device Audit *(Nihai Sensör Rate Toleransları: Cihaz Audit Bekleniyor)*

**Final Field Route Lengths:** Pending Pilot Tests *(Nihai Saha Rota Uzunlukları: Pilot Testler Bekleniyor)*

**Final Denied Durations:** Pending Pilot Tests *(Nihai Kesintili Süreler: Pilot Testler Bekleniyor)*

**Final Performance Thresholds:** Pending Physical Profiling *(Nihai Performans Eşikleri: Fiziksel Profiling Bekleniyor)*

**Final Covariance Calibration Acceptance:** Pending Development Evidence *(Nihai Kovaryans Kalibrasyon Kabulü: Geliştirme Kanıtı Bekleniyor)*

**Final Benchmark Inclusion / Exclusion Policy:** Pending Pre-Benchmark Freeze *(Nihai Benchmark Inclusion / Exclusion Politikası: Benchmark Öncesi Freeze Bekleniyor)*

**Next Documentation Item:** 34 — Field Experiment Plan *(Sonraki Dokümantasyon Öğesi: 34 — Saha Deney Planı)*
