# 34 — Field Experiment Plan (Saha Deney Planı)

## 1. Document Purpose (Dokümanın Amacı)

This document defines how NAVGUARD field experiments will be planned, prepared, executed, repeated, validated, documented, and accepted on the Xiaomi Redmi Note 9 Pro. *(Bu doküman NAVGUARD saha deneylerinin Xiaomi Redmi Note 9 Pro üzerinde nasıl planlanacağını, hazırlanacağını, yürütüleceğini, tekrarlanacağını, doğrulanacağını, dokümante edileceğini ve kabul edileceğini tanımlar.)*

The field plan converts the testing strategy defined in Page 33 into repeatable physical experiment procedures. *(Saha planı Page 33'te tanımlanan test stratejisini tekrarlanabilir fiziksel deney prosedürlerine dönüştürür.)*

---

# 2. Core Field Experiment Principle (Temel Saha Deney İlkesi)

Field experiments will be controlled enough to support comparison while still using real pedestrian motion and real smartphone sensor conditions. *(Saha deneyleri gerçek yaya hareketini ve gerçek akıllı telefon sensör koşullarını kullanırken karşılaştırmayı destekleyecek kadar kontrollü olacaktır.)*

---

# 3. Research Question Connection (Araştırma Sorusu Bağlantısı)

The field plan is designed to answer whether AI-assisted pedestrian dead reckoning and visual-inertial sensor fusion reduce position drift during simulated GNSS outages compared with baseline PDR-only navigation. *(Saha planı yapay zekâ destekli yaya dead reckoning ve visual-inertial sensör füzyonunun simüle edilmiş GNSS kesintileri sırasında baseline yalnızca PDR navigasyona kıyasla konum drift'ini azaltıp azaltmadığını cevaplamak için tasarlanmıştır.)*

---

# 4. Physical Device (Fiziksel Cihaz)

All principal experiments will be performed on the Xiaomi Redmi Note 9 Pro. *(Tüm temel deneyler Xiaomi Redmi Note 9 Pro üzerinde gerçekleştirilecektir.)*

---

# 5. No Additional Hardware Requirement (Ek Donanım Gereksinimi Olmaması)

The minimum experiment plan requires no additional purchased hardware. *(Minimum deney planı ek satın alınmış donanım gerektirmez.)*

---

# 6. GNSS-Denied Condition (GNSS Kesintili Koşul)

The primary denied-navigation condition will be created in software by excluding GNSS from estimator access. *(Temel kesintili navigasyon koşulu GNSS'i tahmin motoru erişiminden hariç tutarak yazılım içerisinde oluşturulacaktır.)*

---

# 7. No RF Jamming (RF Jamming Olmaması)

No RF jamming, spoofing, interference, or deliberate disruption of GNSS signals will be used. *(Hiçbir RF jamming, spoofing, interference veya GNSS sinyallerinin kasıtlı bozulması kullanılmayacaktır.)*

---

# 8. Evaluation Mode Ground Truth (Evaluation Mode Ground Truth)

During Evaluation Mode, physical GNSS may continue recording independently as ground truth while remaining blocked from the estimator. *(Evaluation Mode sırasında fiziksel GNSS tahmin motorundan blocked kalırken bağımsız ground truth olarak kaydedilmeye devam edebilir.)*

---

# 9. Field Experiment Categories (Saha Deney Kategorileri)

NAVGUARD field work will use five major experiment categories. *(NAVGUARD saha çalışmaları beş ana deney kategorisi kullanacaktır.)*

```text id="ab2n4e"
1. Calibration / Baseline Experiments
   (Kalibrasyon / Baseline Deneyleri)

2. Principal Navigation Experiments
   (Temel Navigasyon Deneyleri)

3. Stress Experiments
   (Zorlama Deneyleri)

4. Recovery Experiments
   (Recovery Deneyleri)

5. Performance / Endurance Experiments
   (Performans / Dayanıklılık Deneyleri)
```

---

# 10. Calibration Experiments (Kalibrasyon Deneyleri)

Calibration sessions will characterize phone sensors and baseline pedestrian behavior before final benchmark collection. *(Kalibrasyon oturumları final benchmark veri toplama öncesinde telefon sensörlerini ve baseline yaya davranışını karakterize edecektir.)*

---

# 11. Principal Navigation Experiments (Temel Navigasyon Deneyleri)

Principal navigation experiments will provide the primary evidence used to compare configurations A through D. *(Temel navigasyon deneyleri Configuration A-D karşılaştırmasında kullanılan ana kanıtı sağlayacaktır.)*

---

# 12. Stress Experiments (Zorlama Deneyleri)

Stress experiments will evaluate NAVGUARD under intentionally difficult but naturally occurring conditions. *(Stress deneyleri NAVGUARD'ı kasıtlı olarak zor ancak doğal şekilde oluşan koşullar altında değerlendirecektir.)*

---

# 13. Recovery Experiments (Recovery Deneyleri)

Recovery experiments will evaluate the controlled transition from denied navigation back to validated GNSS navigation. *(Recovery deneyleri kesintili navigasyondan doğrulanmış GNSS navigasyona kontrollü geçişi değerlendirecektir.)*

---

# 14. Performance Experiments (Performans Deneyleri)

Performance experiments will measure endurance, battery, thermal behavior, runtime stability, and storage growth. *(Performans deneyleri dayanıklılığı, bataryayı, termal davranışı, runtime stability'yi ve depolama büyümesini ölçecektir.)*

---

# 15. Principal Route Set (Temel Rota Seti)

The principal benchmark will use three route categories. *(Temel benchmark üç rota kategorisi kullanacaktır.)*

```text id="pc99vj"
ROUTE-S
Straight
(Düz)

ROUTE-T
Turn-Heavy
(Dönüş Yoğun)

ROUTE-C
Closed / Near-Closed
(Kapalı / Yaklaşık Kapalı)
```

---

# 16. Straight Route Purpose (Düz Rota Amacı)

The straight route will isolate distance accumulation and heading stability with minimal turning complexity. *(Düz rota minimum dönüş karmaşıklığıyla mesafe birikimini ve heading kararlılığını izole edecektir.)*

---

# 17. Turn-Heavy Route Purpose (Dönüş Yoğun Rota Amacı)

The turn-heavy route will stress heading estimation, turn handling, step propagation, ARCore alignment, and fusion. *(Dönüş yoğun rota heading estimation, turn handling, step propagation, ARCore alignment ve fusion'ı zorlayacaktır.)*

---

# 18. Closed Route Purpose (Kapalı Rota Amacı)

The closed or near-closed route will provide a strong endpoint and closure-error interpretation. *(Kapalı veya yaklaşık kapalı rota güçlü endpoint ve closure-error yorumu sağlayacaktır.)*

---

# 19. Route Length Is Not Yet Frozen (Rota Uzunluğu Henüz Sabit Değildir)

Exact route lengths will be selected after pilot testing and local field practicality are confirmed. *(Kesin rota uzunlukları pilot testlerden ve yerel saha practicality doğrulandıktan sonra seçilecektir.)*

---

# 20. No Fabricated Route Length (Uydurulmuş Rota Uzunluğu Olmaması)

NAVGUARD will not declare a route to be exactly 100 m, 200 m, or another value without actually defining and measuring that route. *(NAVGUARD rotayı gerçekten tanımlayıp ölçmeden tam olarak 100 m, 200 m veya başka bir değer olarak ilan etmeyecektir.)*

---

# 21. Route Length Candidate Range (Aday Rota Uzunluğu Aralığı)

Pilot routes should be long enough to reveal dead-reckoning drift but short enough to permit repeated trials within the project schedule. *(Pilot rotalar dead-reckoning drift'ini ortaya çıkaracak kadar uzun ancak proje takvimi içerisinde tekrarlanan denemelere izin verecek kadar kısa olmalıdır.)*

---

# 22. Route Safety (Rota Güvenliği)

Formal routes will prioritize pedestrian safety and repeatability. *(Resmî rotalar yaya güvenliğine ve tekrarlanabilirliğe öncelik verecektir.)*

---

# 23. Traffic Avoidance (Trafikten Kaçınma)

Routes that require repeated crossing of dangerous traffic will be avoided where practical. *(Tehlikeli trafiğin tekrar tekrar geçilmesini gerektiren rotalardan uygulanabilir olduğunda kaçınılacaktır.)*

---

# 24. Terrain Consistency (Zemin Tutarlılığı)

Principal routes should use reasonably consistent walking surfaces where possible. *(Temel rotalar mümkün olduğunda makul derecede tutarlı yürüme yüzeyleri kullanmalıdır.)*

---

# 25. Route Geometry Documentation (Rota Geometrisi Dokümantasyonu)

Every principal route will be documented before final benchmark collection. *(Her temel rota final benchmark veri toplama öncesinde dokümante edilecektir.)*

---

# 26. Route Definition Record (Rota Tanım Kaydı)

```text id="jaqwr3"
RouteDefinition
- routeId
- routeType
- startPoint
- endPoint
- checkpoints
- knownTurns
- approximateLength
- environment
- surfaceType
- expectedVisualTexture
- magneticRiskNotes
```

---

# 27. Start Point (Başlangıç Noktası)

Each route will have a clearly repeatable starting location. *(Her rota açık şekilde tekrarlanabilir başlangıç konumuna sahip olacaktır.)*

---

# 28. End Point (Bitiş Noktası)

Each route will have a clearly repeatable endpoint. *(Her rota açık şekilde tekrarlanabilir bitiş noktasına sahip olacaktır.)*

---

# 29. Checkpoints (Checkpoint'ler)

Intermediate checkpoints may be added to support local error analysis and route verification. *(Yerel hata analizi ve rota doğrulamasını desteklemek için ara checkpoint'ler eklenebilir.)*

---

# 30. Checkpoint Types (Checkpoint Türleri)

A checkpoint may be a physically identifiable point such as a corner, pavement marker, building corner, path intersection, or known route waypoint. *(Checkpoint köşe, kaldırım işareti, bina köşesi, yol kesişimi veya bilinen rota waypoint'i gibi fiziksel olarak tanımlanabilir nokta olabilir.)*

---

# 31. Checkpoint Precision (Checkpoint Hassasiyeti)

Checkpoint precision must match the intended evaluation method. *(Checkpoint hassasiyeti amaçlanan değerlendirme yöntemiyle eşleşmelidir.)*

A visually identifiable checkpoint does not automatically imply centimeter-level ground truth. *(Görsel olarak tanımlanabilir checkpoint otomatik olarak centimeter-level ground truth anlamına gelmez.)*

---

# 32. Route Measurement Method (Rota Ölçüm Yöntemi)

Route length and checkpoint coordinates will use the most reliable available method that does not require new hardware purchases. *(Rota uzunluğu ve checkpoint koordinatları yeni donanım satın almayı gerektirmeyen en güvenilir kullanılabilir yöntemi kullanacaktır.)*

---

# 33. Reference Sources (Referans Kaynakları)

Possible reference sources include stable outdoor GNSS, map geometry for rough planning, known physical dimensions, manual distance measurement, and repeatable route landmarks. *(Olası referans kaynakları kararlı dış ortam GNSS'i, kaba planlama için harita geometrisini, bilinen fiziksel ölçüleri, manuel mesafe ölçümünü ve tekrarlanabilir rota landmark'larını içerir.)*

---

# 34. Map Geometry Is Not Absolute Truth (Harita Geometrisi Mutlak Doğru Değildir)

Map geometry may help define routes but will not automatically be treated as centimeter-accurate ground truth. *(Harita geometrisi rotaları tanımlamaya yardımcı olabilir ancak otomatik olarak centimeter-accurate ground truth olarak ele alınmayacaktır.)*

---

# 35. Principal Repeat Count (Temel Tekrar Sayısı)

The current target remains at least three physical repeats for each principal route category. *(Mevcut hedef her temel rota kategorisi için en az üç fiziksel tekrar olarak kalmaktadır.)*

---

# 36. Principal Session Count (Temel Oturum Sayısı)

Straight, turn-heavy, and closed-route testing with at least three repeats each produces approximately nine principal physical sessions. *(Düz, dönüş yoğun ve kapalı rota testlerinin her biri en az üç tekrar ile yaklaşık dokuz temel fiziksel oturum üretir.)*

---

# 37. Nine Sessions Are a Minimum Practical Baseline (Dokuz Oturum Minimum Pratik Baseline'dır)

This count is an engineering repeat plan rather than a formal statistical-power calculation. *(Bu sayı resmî statistical-power calculation yerine mühendislik tekrar planıdır.)*

---

# 38. Additional Stress Sessions (Ek Stress Oturumları)

Stress and recovery sessions will be added beyond the principal repeat set when time permits. *(Zaman izin verdiğinde temel tekrar setine ek olarak stress ve recovery oturumları eklenecektir.)*

---

# 39. Route Repeat Consistency (Rota Tekrar Tutarlılığı)

Repeated trials should follow the same route geometry as closely as practical. *(Tekrarlanan denemeler uygulanabilir olduğunca aynı rota geometrisini izlemelidir.)*

---

# 40. Walking Direction Consistency (Yürüme Yönü Tutarlılığı)

Unless direction is itself being studied, repeated route runs should use the same traversal direction. *(Yönün kendisi incelenmiyorsa tekrarlanan rota run'ları aynı traversal yönünü kullanmalıdır.)*

---

# 41. Phone Placement Control (Telefon Yerleşim Kontrolü)

Formal baseline sessions will use a controlled phone placement. *(Resmî baseline oturumları kontrollü telefon yerleşimi kullanacaktır.)*

---

# 42. Preferred Initial Phone Placement (Tercih Edilen İlk Telefon Yerleşimi)

The initial formal protocol will use one consistent handheld or body placement selected during pilot testing. *(İlk resmî protokol pilot test sırasında seçilen tek tutarlı elde veya vücut placement'ını kullanacaktır.)*

---

# 43. Placement Must Be Reproducible (Yerleşim Tekrarlanabilir Olmalıdır)

The chosen placement must be easy for the same operator to reproduce across sessions. *(Seçilen placement aynı operatörün oturumlar arasında kolayca tekrar edebileceği şekilde olmalıdır.)*

---

# 44. Arbitrary Placement Is Outside Minimum Benchmark (Keyfi Yerleşim Minimum Benchmark Dışındadır)

Phone-placement robustness is not part of the minimum principal benchmark. *(Telefon placement robustness minimum temel benchmark'ın parçası değildir.)*

---

# 45. Placement Variation Is a Stress Experiment (Yerleşim Değişimi Stress Deneyidir)

Pocket, hand, chest-level, or other placement variation may later be tested as a separate robustness scenario. *(Cep, el, göğüs seviyesi veya diğer placement değişimleri daha sonra ayrı robustness senaryosu olarak test edilebilir.)*

---

# 46. Device Orientation at Start (Başlangıçta Cihaz Yönelimi)

The initial phone orientation will be documented for each formal route. *(İlk telefon yönelimi her resmî rota için dokümante edilecektir.)*

---

# 47. Starting Heading (Başlangıç Yönü)

Each principal route should have a repeatable initial walking heading. *(Her temel rota tekrarlanabilir ilk yürüme heading'ine sahip olmalıdır.)*

---

# 48. Heading Calibration Before Walking (Yürümeden Önce Heading Kalibrasyonu)

The required heading calibration procedure must complete before the formal walking segment begins. *(Gerekli heading calibration prosedürü resmî walking segment başlamadan önce tamamlanmalıdır.)*

---

# 49. Stationary Pre-Run Phase (Koşu Öncesi Sabit Faz)

Each formal session will include a short stationary preparation phase before walking. *(Her resmî oturum yürüme öncesinde kısa stationary preparation phase içerecektir.)*

---

# 50. Stationary Phase Purpose (Sabit Faz Amacı)

The stationary phase allows sensor stabilization, gyroscope bias observation, heading-quality assessment, GNSS anchor validation, and logger readiness confirmation. *(Stationary phase sensör stabilization'ına, gyroscope bias gözlemine, heading-quality değerlendirmesine, GNSS anchor validation'a ve logger readiness confirmation'a izin verir.)*

---

# 51. Stationary Duration Is Pending Pilot Tests (Sabit Süre Pilot Testlerini Bekliyor)

The exact stationary preparation duration will be selected after physical-device measurements. *(Kesin stationary preparation süresi fiziksel cihaz ölçümlerinden sonra seçilecektir.)*

---

# 52. No Timer-Only Calibration (Yalnızca Timer Tabanlı Kalibrasyon Olmaması)

The preparation phase will not be considered successful solely because a fixed number of seconds elapsed. *(Preparation phase yalnızca sabit saniye sayısı geçtiği için başarılı kabul edilmeyecektir.)*

---

# 53. GNSS Anchor Requirement (GNSS Anchor Gereksinimi)

A valid anchor must be accepted before formal denied-navigation evaluation begins. *(Resmî kesintili navigasyon değerlendirmesi başlamadan önce geçerli anchor kabul edilmelidir.)*

---

# 54. Anchor Quality Gate (Anchor Kalite Gate'i)

The anchor must pass the frozen GNSS quality and freshness policy. *(Anchor sabitlenmiş GNSS kalite ve freshness politikasını geçmelidir.)*

---

# 55. No First-Fix Auto-Anchor (İlk Fix'in Otomatik Anchor Olmaması)

The first available GNSS fix will not automatically become the benchmark anchor. *(İlk kullanılabilir GNSS fix'i otomatik olarak benchmark anchor'ı olmayacaktır.)*

---

# 56. Ground Truth Logging Readiness (Ground Truth Logging Hazırlığı)

Evaluation Mode ground-truth logging must be confirmed active before the denied interval begins. *(Evaluation Mode ground-truth logging kesintili aralık başlamadan önce aktif olarak doğrulanmalıdır.)*

---

# 57. Ground Truth Firewall Readiness (Ground Truth Firewall Hazırlığı)

The Ground Truth Firewall self-test must have passed before final benchmark sessions. *(Ground Truth Firewall self-test final benchmark oturumları öncesinde geçmiş olmalıdır.)*

---

# 58. Session Start Sequence (Oturum Başlangıç Sırası)

The recommended field-session sequence is as follows. *(Önerilen saha oturumu sırası aşağıdaki gibidir.)*

```text id="gm7d70"
1. Open NAVGUARD
2. Select Benchmark Mode
3. Select Configuration
4. Run Readiness Check
5. Verify Storage
6. Verify Sensors
7. Verify GNSS
8. Verify ARCore if required
9. Verify AI if required
10. Complete Calibration
11. Accept GNSS Anchor
12. Begin Session
13. Begin Walking
14. Start Denied Interval
15. Complete Route
16. Request Recovery
17. Capture Recovery Error
18. Relocalize
19. Stop Session
20. Finalize Session
21. Review Integrity
22. Add Field Notes
```

---

# 59. Warm-Up Walking Candidate (Warm-Up Yürüyüş Adayı)

A short pre-denial walking segment may be used to stabilize heading, step detection, and ARCore before denial begins. *(Kısa pre-denial walking segment kesinti başlamadan önce heading, step detection ve ARCore'u stabilize etmek için kullanılabilir.)*

---

# 60. Warm-Up Is Not Ground Truth Leakage (Warm-Up Ground Truth Sızıntısı Değildir)

During normal GNSS Mode before the denial boundary, authorized GNSS may be used according to the selected configuration. *(Kesinti sınırından önce normal GNSS Mode sırasında authorized GNSS seçilen yapılandırmaya göre kullanılabilir.)*

---

# 61. Denied Boundary Must Be Explicit (Kesinti Sınırı Açık Olmalıdır)

The exact denial start will be produced by an explicit software action and stored with a monotonic timestamp. *(Kesin kesinti başlangıcı açık yazılım işlemiyle oluşturulacak ve monotonik timestamp ile saklanacaktır.)*

---

# 62. Manual Denial Trigger (Manuel Kesinti Tetikleyicisi)

The initial formal experiment will use a manual software trigger for denial. *(İlk resmî deney kesinti için manuel yazılım tetikleyicisi kullanacaktır.)*

---

# 63. Denial Trigger Must Not Depend on Looking at Ground Truth (Kesinti Tetikleyicisi Ground Truth'a Bakmaya Bağlı Olmamalıdır)

The operator will not choose the denial point because the GNSS trajectory looks favorable or unfavorable in real time. *(Operatör kesinti noktasını GNSS trajectory gerçek zamanda iyi veya kötü göründüğü için seçmeyecektir.)*

---

# 64. Denial Point Definition (Kesinti Noktası Tanımı)

For each formal route, the intended denial start region or route event will be predeclared. *(Her resmî rota için amaçlanan kesinti başlangıç bölgesi veya rota olayı önceden tanımlanacaktır.)*

---

# 65. Candidate Denial Trigger Methods (Aday Kesinti Tetikleme Yöntemleri)

The denial trigger may be defined by elapsed distance, checkpoint, elapsed time, or a fixed route marker. *(Kesinti tetikleyicisi kat edilen mesafe, checkpoint, geçen süre veya sabit rota marker'ı ile tanımlanabilir.)*

---

# 66. Preferred Denial Trigger (Tercih Edilen Kesinti Tetikleyicisi)

A physically repeatable checkpoint or route marker is preferred when practical because it improves matched-run comparability. *(Fiziksel olarak tekrarlanabilir checkpoint veya rota marker'ı uygulanabilir olduğunda tercih edilir çünkü matched-run karşılaştırılabilirliğini artırır.)*

---

# 67. Denied Duration Is Not Yet Frozen (Kesintili Süre Henüz Sabit Değildir)

The exact denied-navigation duration will be selected after pilot sessions. *(Kesin kesintili navigasyon süresi pilot oturumlardan sonra seçilecektir.)*

---

# 68. Denied Distance May Be More Useful Than Time (Kesintili Mesafe Zamandan Daha Kullanışlı Olabilir)

For walking experiments, denied distance may sometimes provide more consistent comparison than denied time. *(Walking deneyleri için kesintili mesafe bazen kesintili zamana göre daha tutarlı karşılaştırma sağlayabilir.)*

---

# 69. Denial Protocol Must Be Frozen (Kesinti Protokolü Sabitlenmelidir)

The final benchmark will freeze the denial-start and recovery-end policy before final results are inspected. *(Final benchmark nihai sonuçlar incelenmeden önce kesinti başlangıcı ve recovery bitiş politikasını sabitleyecektir.)*

---

# 70. Ground Truth During Denial (Kesinti Sırasında Ground Truth)

GNSS ground truth may continue logging throughout the denied interval in Evaluation Mode. *(Evaluation Mode içerisinde GNSS ground truth kesintili aralık boyunca logging'e devam edebilir.)*

---

# 71. Ground Truth Must Remain Hidden from Estimator (Ground Truth Tahmin Motorundan Gizli Kalmalıdır)

No ground-truth sample may influence PDR, AI, EKF, anchor updates, covariance reduction, or route correction during denial. *(Hiçbir ground-truth sample kesinti sırasında PDR, AI, EKF, anchor update, covariance reduction veya rota correction'ı etkileyemez.)*

---

# 72. Ground Truth UI Blinding (Ground Truth UI Körleme)

Protected GNSS position will remain hidden from the operator during the blinded denied interval. *(Korunan GNSS konumu blinded kesintili aralık sırasında operatörden gizli kalacaktır.)*

---

# 73. Walking Protocol (Yürüme Protokolü)

The operator will walk naturally rather than intentionally modifying gait to help the algorithm. *(Operatör algoritmaya yardımcı olmak için gait'i kasıtlı değiştirmek yerine doğal şekilde yürüyecektir.)*

---

# 74. Pace Consistency (Tempo Tutarlılığı)

Repeated principal runs should use a similar comfortable walking pace where practical. *(Tekrarlanan temel run'lar uygulanabilir olduğunda benzer rahat yürüme temposu kullanmalıdır.)*

---

# 75. No Metronome Requirement (Metronom Gereksinimi Olmaması)

A metronome is not required for the principal real-world benchmark unless later experiments justify strict cadence control. *(Daha sonraki deneyler strict cadence control'ü gerekçelendirmedikçe temel gerçek dünya benchmark'ı için metronom gerekli değildir.)*

---

# 76. Operator Stops (Operatör Durmaları)

Unplanned stops should be logged or noted if they materially affect a formal route. *(Planlanmamış durmalar resmî rotayı anlamlı şekilde etkiliyorsa loglanmalı veya not edilmelidir.)*

---

# 77. Walk-Stop-Walk Scenario (Yürü-Dur-Yürü Senaryosu)

A dedicated controlled walk-stop-walk experiment will separately test stationary recognition and restart behavior. *(Özel kontrollü walk-stop-walk deneyi stationary recognition ve restart davranışını ayrı test edecektir.)*

---

# 78. Turn Execution (Dönüş Uygulaması)

Known route turns should be executed naturally and consistently. *(Bilinen rota dönüşleri doğal ve tutarlı şekilde gerçekleştirilmelidir.)*

---

# 79. Turn Point Documentation (Dönüş Noktası Dokümantasyonu)

Principal turn points will be documented before benchmark runs. *(Temel dönüş noktaları benchmark run'ları öncesinde dokümante edilecektir.)*

---

# 80. Turn Angle Candidate (Dönüş Açısı Adayı)

Where the route geometry allows, approximately right-angle turns are useful because they are easy to reproduce and interpret. *(Rota geometrisi izin verdiğinde yaklaşık right-angle dönüşler tekrarlanması ve yorumlanması kolay olduğu için kullanışlıdır.)*

---

# 81. Exact Turn Angle Must Not Be Fabricated (Kesin Dönüş Açısı Uydurulmamalıdır)

A turn will not be labeled exactly 90° unless the route geometry supports that claim. *(Rota geometrisi bu iddiayı desteklemiyorsa dönüş tam 90° olarak etiketlenmeyecektir.)*

---

# 82. Closed-Loop Route (Kapalı Döngü Rota)

The closed route should return as close as practical to its defined starting point. *(Kapalı rota tanımlanan başlangıç noktasına uygulanabilir olduğunca yakın dönmelidir.)*

---

# 83. Closure Error (Closure Error)

Closure error will be measured separately from path-length error. *(Closure error path-length error'dan ayrı ölçülecektir.)*

---

# 84. Endpoint Confirmation (Endpoint Doğrulaması)

The operator will clearly mark or trigger the endpoint of the route. *(Operatör rota bitiş noktasını açık şekilde işaretleyecek veya tetikleyecektir.)*

---

# 85. Manual Checkpoint Markers (Manuel Checkpoint Marker'ları)

Manual event markers may be used to identify important route positions. *(Önemli rota konumlarını tanımlamak için manuel event marker'ları kullanılabilir.)*

---

# 86. Marker Timing Limitations (Marker Zamanlama Sınırlamaları)

Manual event taps are not assumed to correspond exactly to the physical instant of passing a checkpoint. *(Manuel event tap'lerinin checkpoint'in fiziksel olarak geçildiği tam ana karşılık geldiği varsayılmayacaktır.)*

---

# 87. Checkpoint Time Refinement (Checkpoint Zaman İyileştirme)

Offline analysis may refine checkpoint times using route evidence where justified. *(Gerekçelendirildiğinde offline analysis rota kanıtını kullanarak checkpoint zamanlarını iyileştirebilir.)*

---

# 88. Recovery Point (Recovery Noktası)

Each formal denied run will have a predeclared recovery point or recovery condition. *(Her resmî kesintili run önceden tanımlanmış recovery point veya recovery condition'a sahip olacaktır.)*

---

# 89. Recovery Should Not Be Triggered by Looking at Error (Recovery Hataya Bakarak Tetiklenmemelidir)

The operator must not wait until the NAVGUARD estimate appears particularly good before requesting GNSS recovery. *(Operatör GNSS recovery istemeden önce NAVGUARD tahmininin özellikle iyi görünmesini beklememelidir.)*

---

# 90. Recovery Candidate Validation (Recovery Aday Validation)

Recovery will follow the quality-validation rules defined in Page 29. *(Recovery Page 29'da tanımlanan kalite validation kurallarını izleyecektir.)*

---

# 91. First Recovery Fix Is Not Automatically Accepted (İlk Recovery Fix Otomatik Kabul Edilmez)

The first GNSS fix after a recovery request will not automatically correct the estimator. *(Recovery isteğinden sonraki ilk GNSS fix tahmin motorunu otomatik olarak düzeltmeyecektir.)*

---

# 92. Pre-Correction Error Capture (Düzeltme Öncesi Hata Yakalama)

The current NAVGUARD estimate must be captured before any recovery correction. *(Herhangi bir recovery correction öncesinde mevcut NAVGUARD tahmini yakalanmalıdır.)*

---

# 93. Recovery Ground Truth in Existing ENU (Mevcut ENU İçerisinde Recovery Ground Truth)

The accepted GNSS recovery reference will be converted into the original denied-interval ENU frame before error measurement. *(Kabul edilmiş GNSS recovery referansı error measurement öncesinde orijinal kesintili aralık ENU frame'ine dönüştürülecektir.)*

---

# 94. Recovery Error Is Recorded Before Relocalization (Recovery Hatası Relocalization Öncesi Kaydedilir)

East, North, and horizontal recovery error must be recorded before relocalization. *(East, North ve horizontal recovery error relocalization öncesinde kaydedilmelidir.)*

---

# 95. Relocalization After Evidence Capture (Kanıt Yakalama Sonrası Relocalization)

Only after pre-correction evidence is safely captured may the active estimator be corrected. *(Yalnızca düzeltme öncesi kanıt güvenli şekilde yakalandıktan sonra aktif tahmin motoru düzeltilebilir.)*

---

# 96. Session Stop Timing (Oturum Durdurma Zamanı)

The formal session will normally continue until recovery and any required post-recovery stabilization are completed. *(Resmî oturum normalde recovery ve gerekli post-recovery stabilization tamamlanana kadar devam edecektir.)*

---

# 97. Stop Is Not Completion (Stop Tamamlama Değildir)

Pressing Stop ends recording but does not immediately make the session scientifically complete. *(Stop'a basmak kaydı sonlandırır ancak oturumu bilimsel olarak anında tamamlanmış hale getirmez.)*

---

# 98. Finalization Required (Finalization Gereklidir)

The session must pass storage finalization and integrity checks before being marked completed. *(Oturum completed işaretlenmeden önce storage finalization ve integrity kontrollerini geçmelidir.)*

---

# 99. Post-Session Field Notes (Oturum Sonrası Saha Notları)

Immediately after a run, the operator may add short field notes while observations are fresh. *(Run sonrasında gözlemler tazeyken operatör kısa saha notları ekleyebilir.)*

---

# 100. Candidate Field Notes (Aday Saha Notları)

```text id="e7syj8"
Unexpected stop
Crowd interference
Phone grip change
Magnetic disturbance
ARCore issue
Route deviation
Weather issue
GNSS concern
Application warning
Other anomaly
```

---

# 101. Field Notes Are Supplementary (Saha Notları Tamamlayıcıdır)

Human notes do not replace structured sensor and event evidence. *(İnsan notları yapılandırılmış sensör ve event kanıtının yerini almaz.)*

---

# 102. Route Deviation (Rota Sapması)

If the operator deviates materially from the planned route, the session will be marked for review. *(Operatör planlanan rotadan anlamlı şekilde saparsa oturum review için işaretlenecektir.)*

---

# 103. Route Deviation Does Not Automatically Mean Deletion (Rota Sapması Otomatik Silme Anlamına Gelmez)

The session will not be deleted simply because a deviation occurred. *(Sapma gerçekleştiği için oturum yalnızca bu nedenle silinmeyecektir.)*

---

# 104. Session Validity Review (Oturum Geçerlilik İncelemesi)

The benchmark inclusion policy will determine whether the deviated session remains eligible for primary comparison. *(Benchmark inclusion politikası sapmış oturumun temel karşılaştırma için uygun kalıp kalmadığını belirleyecektir.)*

---

# 105. Weather Logging (Hava Durumu Logging)

Weather may be noted when it materially affects phone handling, walking surface, visibility, or thermal behavior. *(Hava durumu telefon kullanımını, yürüme yüzeyini, görünürlüğü veya termal davranışı anlamlı şekilde etkilediğinde not edilebilir.)*

---

# 106. Weather Is Not Automatically a Primary Variable (Hava Durumu Otomatik Temel Değişken Değildir)

The minimum experiment does not attempt to model navigation error as a function of weather. *(Minimum deney navigasyon hatasını weather'ın fonksiyonu olarak modellemeye çalışmaz.)*

---

# 107. Time-of-Day Recording (Günün Saati Kaydı)

Session time may be retained as contextual metadata. *(Oturum saati contextual metadata olarak korunabilir.)*

---

# 108. Lighting Conditions (Işık Koşulları)

Lighting conditions may be relevant to ARCore tracking and therefore should be noted in ARCore-focused stress tests. *(Işık koşulları ARCore tracking için önemli olabilir ve bu nedenle ARCore odaklı stress testlerinde not edilmelidir.)*

---

# 109. Visual Texture Stress Test (Görsel Texture Stress Testi)

A low-texture environment may be used to test ARCore degradation. *(Düşük texture'lı ortam ARCore degradation'ı test etmek için kullanılabilir.)*

---

# 110. Low-Texture Test Safety (Düşük Texture Test Güvenliği)

The selected environment must remain safe for walking and must not require obstructing the user's ability to see the route. *(Seçilen ortam yürüyüş için güvenli kalmalı ve kullanıcının rotayı görmesini engellemeyi gerektirmemelidir.)*

---

# 111. Magnetic Disturbance Stress Test (Manyetik Bozulma Stress Testi)

A naturally magnetically disturbed environment may be used to test heading-quality handling. *(Doğal manyetik olarak bozulmuş ortam heading-quality yönetimini test etmek için kullanılabilir.)*

---

# 112. No Artificial Dangerous Magnetic Setup (Tehlikeli Yapay Manyetik Düzenek Olmaması)

The experiment does not require construction of strong artificial magnetic fields. *(Deney güçlü yapay manyetik alanların oluşturulmasını gerektirmez.)*

---

# 113. Magnetic Disturbance Goal (Manyetik Bozulma Hedefi)

The objective is to observe whether heading confidence degrades appropriately rather than to maximize compass failure. *(Amaç compass failure'ı maksimuma çıkarmak yerine heading confidence'ın uygun şekilde düşüp düşmediğini gözlemlemektir.)*

---

# 114. Indoor Scenario (İç Mekân Senaryosu)

Indoor walking may be tested as an additional relative-navigation scenario. *(Indoor walking ek relative-navigation senaryosu olarak test edilebilir.)*

---

# 115. Indoor GNSS Limitation (İç Mekân GNSS Sınırlaması)

Indoor GNSS will not automatically be considered reliable ground truth. *(Indoor GNSS otomatik olarak güvenilir ground truth kabul edilmeyecektir.)*

---

# 116. Indoor Reference Alternatives (İç Mekân Referans Alternatifleri)

Known corridors, measured distances, physical checkpoints, and closure error may be used for indoor analysis. *(Bilinen koridorlar, ölçülmüş mesafeler, fiziksel checkpoint'ler ve closure error indoor analysis için kullanılabilir.)*

---

# 117. Indoor Result Labeling (İç Mekân Sonuç Etiketleme)

Indoor sessions using non-GNSS references must be reported separately from GNSS-ground-truth positional benchmarks. *(GNSS dışı referans kullanan indoor oturumlar GNSS-ground-truth positional benchmark'larından ayrı raporlanmalıdır.)*

---

# 118. Outdoor Scenario (Dış Mekân Senaryosu)

Outdoor open-sky or reasonably GNSS-visible routes will form the primary quantitative position benchmark. *(Outdoor open-sky veya makul şekilde GNSS-visible rotalar temel nicel konum benchmark'ını oluşturacaktır.)*

---

# 119. Ground Truth GNSS Quality (Ground Truth GNSS Kalitesi)

GNSS ground truth quality must be checked before a session contributes to primary positional metrics. *(Bir oturum temel positional metrics'e katkıda bulunmadan önce GNSS ground truth kalitesi kontrol edilmelidir.)*

---

# 120. Ground Truth Quality Is Independent of Estimator Mode (Ground Truth Kalitesi Tahmin Motoru Modundan Bağımsızdır)

GNSS may be physically available and logged while estimator access remains blocked. *(Tahmin motoru erişimi blocked kalırken GNSS fiziksel olarak kullanılabilir ve loglanmış olabilir.)*

---

# 121. Ground Truth Quality Indicators (Ground Truth Kalite Göstergeleri)

Candidate indicators include horizontal accuracy, fix age, continuity, satellite diagnostics, and spatial plausibility. *(Aday göstergeler yatay accuracy, fix age, continuity, satellite diagnostics ve spatial plausibility'yi içerir.)*

---

# 122. Satellite Count Is Not Enough (Uydu Sayısı Tek Başına Yeterli Değildir)

A high satellite count does not automatically make a GNSS trajectory accurate. *(Yüksek uydu sayısı GNSS trajectory'yi otomatik olarak doğru hale getirmez.)*

---

# 123. Accuracy Field Is Not Actual Error (Accuracy Alanı Gerçek Hata Değildir)

Android-reported horizontal accuracy is metadata describing estimated uncertainty, not the actual known error of each fix. *(Android tarafından raporlanan horizontal accuracy her fix'in gerçek bilinen hatası değil tahmini belirsizliği tanımlayan metadata bilgisidir.)*

---

# 124. Ground Truth Inclusion Policy (Ground Truth Inclusion Politikası)

The final benchmark inclusion policy will specify when a GNSS reference segment is sufficiently usable for primary error metrics. *(Nihai benchmark inclusion politikası GNSS referans segmentinin temel error metrics için ne zaman yeterince kullanılabilir olduğunu belirtecektir.)*

---

# 125. Inclusion Policy Must Be Frozen Early (Inclusion Politikası Erken Sabitlenmelidir)

The inclusion policy must be frozen before final benchmark outcomes are inspected. *(Inclusion politikası nihai benchmark sonuçları incelenmeden önce sabitlenmelidir.)*

---

# 126. No Ground Truth Cherry-Picking (Ground Truth Cherry-Picking Olmaması)

NAVGUARD will not select only the GNSS fixes that make estimator error appear smaller. *(NAVGUARD yalnızca estimator error değerini daha küçük gösteren GNSS fix'lerini seçmeyecektir.)*

---

# 127. Reference Gaps (Referans Boşlukları)

Ground-truth gaps will be recorded explicitly. *(Ground-truth gaps açık şekilde kaydedilecektir.)*

---

# 128. Reference Gap Does Not Become Interpolated Truth Automatically (Referans Boşluğu Otomatik Interpolated Truth Olmaz)

Long GNSS gaps will not be filled with arbitrary interpolation and presented as measured ground truth. *(Uzun GNSS boşlukları keyfi interpolation ile doldurulup measured ground truth olarak sunulmayacaktır.)*

---

# 129. Benchmark Configurations (Benchmark Yapılandırmaları)

Field evidence will support the four formal configurations. *(Saha kanıtı dört resmî yapılandırmayı destekleyecektir.)*

```text id="n8wui6"
A — PDR Only
(A — Yalnızca PDR)

B — PDR + Improved Heading
(B — PDR + Geliştirilmiş Heading)

C — PDR + ARCore
(C — PDR + ARCore)

D — Full NAVGUARD
(D — Tam NAVGUARD)
```

---

# 130. Preferred A-D Comparison Method (Tercih Edilen A-D Karşılaştırma Yöntemi)

Where possible, one physical recording will be replayed through multiple configurations to ensure identical raw sensor evidence. *(Mümkün olduğunda tek fiziksel kayıt aynı ham sensör kanıtını sağlamak için birden fazla yapılandırma üzerinden replay edilecektir.)*

---

# 131. Why Same-Session Replay Is Valuable (Aynı Oturum Replay Neden Değerlidir)

Same-session replay reduces the variability caused by walking a route differently for each algorithm. *(Aynı oturum replay her algoritma için rotanın farklı yürünmesinden kaynaklanan variability'yi azaltır.)*

---

# 132. Live Configuration Validation Still Required (Canlı Yapılandırma Validation Yine Gereklidir)

Replay comparison does not remove the need to verify that Configuration D and other live profiles operate correctly in real time. *(Replay karşılaştırması Configuration D ve diğer live profillerin gerçek zamanda doğru çalıştığını doğrulama gereksinimini ortadan kaldırmaz.)*

---

# 133. Recording Profile for Replay (Replay İçin Kayıt Profili)

Principal data-collection sessions should record every raw stream required to replay configurations A-D where practical. *(Temel veri toplama oturumları uygulanabilir olduğunda Configuration A-D'yi replay etmek için gerekli her ham stream'i kaydetmelidir.)*

---

# 134. ARCore Required for C and D Replay (C ve D Replay İçin ARCore Gereklidir)

A session cannot retrospectively evaluate ARCore-based configurations if ARCore evidence was never recorded. *(ARCore kanıtı hiç kaydedilmediyse bir oturum geriye dönük olarak ARCore tabanlı yapılandırmaları değerlendiremez.)*

---

# 135. AI Replay Requirement (AI Replay Gereksinimi)

Raw sensor evidence necessary for reconstructing AI model windows must be retained. *(AI model window'larını yeniden oluşturmak için gerekli ham sensor evidence korunmalıdır.)*

---

# 136. Preprocessing Version (Preprocessing Sürümü)

Replay will use the frozen preprocessing version associated with the compared model or configuration. *(Replay karşılaştırılan model veya yapılandırmayla ilişkili sabitlenmiş preprocessing sürümünü kullanacaktır.)*

---

# 137. Session Randomization Candidate (Oturum Randomization Adayı)

If multiple live configurations must be physically tested separately, execution order may be rotated to reduce systematic order effects. *(Birden fazla live yapılandırma fiziksel olarak ayrı test edilmek zorundaysa sistematik order effect'leri azaltmak için execution order döndürülebilir.)*

---

# 138. No Mandatory Statistical Randomization Claim (Zorunlu İstatistiksel Randomization İddiası Olmaması)

Formal randomization is optional and will not be claimed unless it is actually implemented. *(Formal randomization isteğe bağlıdır ve gerçekten uygulanmadıkça kullanıldığı iddia edilmeyecektir.)*

---

# 139. Operator Fatigue (Operatör Yorgunluğu)

Repeated walking sessions may introduce fatigue effects. *(Tekrarlanan walking oturumları fatigue effect oluşturabilir.)*

---

# 140. Rest Between Runs (Run'lar Arasında Dinlenme)

Short recovery periods between principal runs may be used to reduce fatigue and allow the phone to return toward normal thermal conditions. *(Temel run'lar arasında kısa recovery periods yorgunluğu azaltmak ve telefonun normal thermal condition'a dönmesine izin vermek için kullanılabilir.)*

---

# 141. Exact Rest Duration Is Not Frozen (Kesin Dinlenme Süresi Sabit Değildir)

The exact rest duration will be selected pragmatically during pilot testing. *(Kesin rest duration pilot test sırasında pratik şekilde seçilecektir.)*

---

# 142. Battery Level at Session Start (Oturum Başlangıcında Batarya Seviyesi)

Battery level will be recorded at session start and end for performance-relevant runs. *(Batarya seviyesi performansla ilişkili run'lar için oturum başlangıcında ve sonunda kaydedilecektir.)*

---

# 143. Charging During Principal Runs (Temel Run'lar Sırasında Şarj)

Principal benchmark sessions should avoid charging during active walking unless a specific power experiment requires it. *(Belirli power deneyi gerektirmedikçe temel benchmark oturumları aktif walking sırasında charging'den kaçınmalıdır.)*

---

# 144. Thermal State (Termal Durum)

The device thermal state may be recorded before and after long combined-stack sessions. *(Cihaz thermal state uzun combined-stack oturumlarından önce ve sonra kaydedilebilir.)*

---

# 145. Thermal Throttling Concern (Thermal Throttling Endişesi)

If the device is already strongly thermally throttled before a principal benchmark run, the run may be postponed or flagged. *(Cihaz temel benchmark run öncesinde zaten güçlü thermal throttling altındaysa run ertelenebilir veya flag'lenebilir.)*

---

# 146. Storage Availability (Depolama Kullanılabilirliği)

The application must confirm sufficient writable storage before each formal session. *(Uygulama her resmî oturumdan önce yeterli yazılabilir storage doğrulamalıdır.)*

---

# 147. Storage Threshold Pending Measurements (Depolama Eşiği Ölçümleri Bekliyor)

The final minimum free-space threshold will be based on measured bytes per minute. *(Nihai minimum free-space threshold measured bytes per minute değerine dayanacaktır.)*

---

# 148. Network State (Ağ Durumu)

Network availability may be recorded as context but core estimator operation must remain independent of it. *(Ağ kullanılabilirliği context olarak kaydedilebilir ancak temel estimator çalışması ondan bağımsız kalmalıdır.)*

---

# 149. Airplane Mode Is Not Required (Uçak Modu Gerekli Değildir)

Formal GNSS-denied simulation does not require airplane mode because GNSS exclusion occurs in software. *(Resmî GNSS kesintili simulation airplane mode gerektirmez çünkü GNSS exclusion yazılım içerisinde gerçekleşir.)*

---

# 150. Map Availability (Harita Kullanılabilirliği)

Map imagery availability will not determine experiment validity. *(Harita görüntüsü kullanılabilirliği deney geçerliliğini belirlemeyecektir.)*

---

# 151. Principal Experiment Record (Temel Deney Kaydı)

Each formal physical run will have an experiment record. *(Her resmî fiziksel run deney kaydına sahip olacaktır.)*

---

# 152. Candidate Experiment Record (Aday Deney Kaydı)

```text id="x4f74d"
FieldExperimentRecord
- experimentId
- sessionId
- routeId
- routeType
- repeatIndex
- runtimeMode
- liveConfiguration
- devicePlacement
- startHeading
- anchorId
- denialStartRule
- recoveryRule
- startTime
- endTime
- groundTruthAvailability
- integrityStatus
- operatorNotes
```

---

# 153. Repeat Index (Tekrar Index'i)

Repeated trials will use an explicit repeat index rather than ambiguous filenames. *(Tekrarlanan denemeler belirsiz dosya isimleri yerine açık repeat index kullanacaktır.)*

---

# 154. Example Session Labels (Örnek Oturum Etiketleri)

```text id="1ak1su"
ROUTE-S-R1
ROUTE-S-R2
ROUTE-S-R3

ROUTE-T-R1
ROUTE-T-R2
ROUTE-T-R3

ROUTE-C-R1
ROUTE-C-R2
ROUTE-C-R3
```

---

# 155. Internal Session IDs Remain Separate (Dahili Session ID'leri Ayrı Kalır)

Readable route labels will not replace the application's immutable internal session identifier. *(Okunabilir rota label'ları uygulamanın değişmez dahili session identifier'ının yerini almayacaktır.)*

---

# 156. Principal Straight Experiment Procedure (Temel Düz Rota Deney Prosedürü)

The straight-route protocol will begin with readiness, calibration, and anchor acquisition. *(Düz rota protokolü readiness, calibration ve anchor acquisition ile başlayacaktır.)*

The operator will begin walking along the defined straight route. *(Operatör tanımlanmış düz rota boyunca yürümeye başlayacaktır.)*

The denied boundary will be triggered at the predefined route point. *(Kesintili sınır önceden tanımlanmış rota noktasında tetiklenecektir.)*

The route will continue without intentional heading changes. *(Rota kasıtlı heading change olmadan devam edecektir.)*

Recovery will occur at the predeclared endpoint or recovery marker. *(Recovery önceden tanımlanmış endpoint veya recovery marker'da gerçekleşecektir.)*

---

# 157. Straight Route Primary Observations (Düz Rota Temel Gözlemleri)

Straight-route analysis will emphasize longitudinal distance error, lateral heading drift, final position error, and drift rate. *(Düz rota analizi longitudinal distance error, lateral heading drift, final position error ve drift rate'e vurgu yapacaktır.)*

---

# 158. Principal Turn-Heavy Experiment Procedure (Temel Dönüş Yoğun Deney Prosedürü)

The turn-heavy route will include multiple documented changes in walking direction. *(Dönüş yoğun rota birden fazla dokümante edilmiş yürüme direction change içerecektir.)*

---

# 159. Turn-Heavy Denial Timing (Dönüş Yoğun Kesinti Zamanı)

At least part of the turning sequence should occur during the denied interval. *(Dönüş sequence'inin en az bir kısmı kesintili aralık sırasında gerçekleşmelidir.)*

---

# 160. Turn-Heavy Primary Observations (Dönüş Yoğun Temel Gözlemleri)

Analysis will emphasize heading error, accumulated lateral drift, turn recovery, ARCore usefulness, and fusion behavior. *(Analiz heading error, accumulated lateral drift, turn recovery, ARCore usefulness ve fusion behavior'a vurgu yapacaktır.)*

---

# 161. Principal Closed-Loop Experiment Procedure (Temel Kapalı Döngü Deney Prosedürü)

The operator will follow a route that returns to or near the starting location. *(Operatör başlangıç konumuna veya yakınına dönen rotayı izleyecektir.)*

---

# 162. Closed-Loop Denied Segment (Kapalı Döngü Kesintili Segment)

A significant portion of the closed loop should occur while GNSS is excluded from the estimator. *(Kapalı döngünün anlamlı bir kısmı GNSS tahmin motorundan excluded iken gerçekleşmelidir.)*

---

# 163. Closed-Loop Primary Observations (Kapalı Döngü Temel Gözlemleri)

Analysis will emphasize closure error, accumulated heading error, position drift, and total path-distance consistency. *(Analiz closure error, accumulated heading error, position drift ve total path-distance consistency'ye vurgu yapacaktır.)*

---

# 164. Walk-Stop-Walk Procedure (Yürü-Dur-Yürü Prosedürü)

The operator will walk, stop completely at a defined point, remain stationary, and then resume walking. *(Operatör yürüyecek, tanımlanmış noktada tamamen duracak, stationary kalacak ve ardından yürümeye devam edecektir.)*

---

# 165. Walk-Stop-Walk Objective (Yürü-Dur-Yürü Hedefi)

The experiment will evaluate false-step suppression, AI `STATIONARY` behavior, covariance growth, and restart handling. *(Deney false-step suppression, AI `STATIONARY` davranışı, covariance growth ve restart handling'i değerlendirecektir.)*

---

# 166. Running Scenario (Koşu Senaryosu)

A controlled running segment may be added if running remains part of the final motion-classification scope. *(Running final motion-classification scope içerisinde kalırsa kontrollü running segment eklenebilir.)*

---

# 167. Running Is Not Required for Minimum Navigation Success (Koşu Minimum Navigasyon Başarısı İçin Gerekli Değildir)

If running data proves too limited within the 24-day project, walking performance remains the primary navigation objective. *(Running verisi 24 günlük proje içerisinde fazla sınırlı kalırsa walking performance temel navigasyon hedefi olarak kalacaktır.)*

---

# 168. ARCore Degradation Experiment (ARCore Degradation Deneyi)

An ARCore-specific stress route will include naturally poor visual tracking conditions where safe. *(ARCore'a özgü stress route güvenli olduğunda doğal olarak kötü visual tracking koşulları içerecektir.)*

---

# 169. ARCore Degradation Objective (ARCore Degradation Hedefi)

The goal is to confirm graceful degradation to PDR rather than perfect ARCore performance. *(Hedef kusursuz ARCore performansı yerine PDR'a graceful degradation doğrulamaktır.)*

---

# 170. Magnetic Disturbance Experiment (Manyetik Bozulma Deneyi)

A route segment with known or suspected magnetic disturbance may be included. *(Bilinen veya şüphelenilen magnetic disturbance içeren rota segmenti dahil edilebilir.)*

---

# 171. Magnetic Experiment Objective (Manyetik Deney Hedefi)

The test will examine whether heading quality degrades appropriately and whether fusion avoids blindly trusting the disturbed source. *(Test heading quality'nin uygun şekilde düşüp düşmediğini ve fusion'ın disturbed source'a kör şekilde güvenmekten kaçınıp kaçınmadığını inceleyecektir.)*

---

# 172. GNSS Recovery Experiment (GNSS Recovery Deneyi)

A dedicated recovery run may use a longer denied interval to create meaningful accumulated drift before GNSS recovery. *(Özel recovery run GNSS recovery öncesinde anlamlı accumulated drift oluşturmak için daha uzun kesintili aralık kullanabilir.)*

---

# 173. Recovery Error Requirement (Recovery Hata Gereksinimi)

Pre-correction recovery error must be captured before any correction. *(Düzeltme öncesi recovery error herhangi bir correction öncesinde yakalanmalıdır.)*

---

# 174. Recovery Latency Measurement (Recovery Latency Ölçümü)

Recovery request time, accepted-reference time, relocalization completion time, and total recovery latency will be retained. *(Recovery request time, accepted-reference time, relocalization completion time ve total recovery latency korunacaktır.)*

---

# 175. Repeated Recovery Cycles (Tekrarlanan Recovery Döngüleri)

Optional stress testing may perform more than one denied-recovery cycle within a session. *(İsteğe bağlı stress testing tek oturum içerisinde birden fazla denied-recovery cycle gerçekleştirebilir.)*

---

# 176. Multiple Cycles Are Not Required for Principal Benchmark (Birden Fazla Döngü Temel Benchmark İçin Gerekli Değildir)

The principal benchmark may remain one denied interval per session for easier interpretation. *(Temel benchmark daha kolay yorumlama için session başına tek denied interval olarak kalabilir.)*

---

# 177. Long-Duration Session (Uzun Süreli Oturum)

A long combined-stack session will test runtime endurance. *(Uzun combined-stack oturumu runtime endurance'ı test edecektir.)*

---

# 178. Long-Duration Session Objective (Uzun Süreli Oturum Hedefi)

This session will measure memory stability, writer queue behavior, battery consumption, thermal behavior, and sustained sensor delivery. *(Bu oturum memory stability, writer queue behavior, battery consumption, thermal behavior ve sustained sensor delivery'yi ölçecektir.)*

---

# 179. Long-Duration Exact Length Pending (Uzun Süreli Kesin Süre Bekliyor)

The final endurance duration will be chosen after initial performance profiling. *(Nihai endurance duration ilk performance profiling sonrasında seçilecektir.)*

---

# 180. Field Experiment Precondition Checklist (Saha Deney Önkoşul Checklist'i)

Every principal run should satisfy a pre-run checklist. *(Her temel run pre-run checklist'i karşılamalıdır.)*

```text id="8trtvz"
Correct build installed
Correct benchmark configuration loaded
Required permissions granted
Precise location available
Sensors available
GNSS available
ARCore available when required
AI model hash valid when required
Storage writable
Battery sufficient
Ground Truth Firewall ready
Route definition available
Session label correct
Device placement confirmed
```

---

# 181. Ground Truth Firewall Is a Hard Precondition (Ground Truth Firewall Sert Önkoşuldur)

A failed Ground Truth Firewall isolation test blocks formal benchmark collection. *(Başarısız Ground Truth Firewall isolation testi resmî benchmark veri toplamayı engeller.)*

---

# 182. Build Identity Precondition (Build Kimliği Önkoşulu)

The final benchmark build must be identified before principal final sessions begin. *(Final benchmark build temel final oturumlar başlamadan önce tanımlanmalıdır.)*

---

# 183. Benchmark Configuration Freeze (Benchmark Yapılandırma Sabitleme)

Filters, thresholds, model files, step-length policy, heading policy, recovery rules, and fusion configuration must be frozen before final benchmark collection. *(Filter'lar, threshold'lar, model dosyaları, step-length politikası, heading politikası, recovery kuralları ve fusion yapılandırması final benchmark veri toplama öncesinde sabitlenmelidir.)*

---

# 184. Pilot Sessions Are Separate from Final Sessions (Pilot Oturumlar Final Oturumlardan Ayrıdır)

Pilot data may be used to refine procedures and thresholds. *(Pilot veri prosedürleri ve threshold'ları iyileştirmek için kullanılabilir.)*

Final benchmark data will not be used for post-hoc tuning. *(Final benchmark verisi post-hoc tuning için kullanılmayacaktır.)*

---

# 185. Pilot Route Objectives (Pilot Rota Hedefleri)

Pilot testing will determine practical route length, denial timing, recovery timing, operator control placement, and expected GNSS quality. *(Pilot testing pratik rota uzunluğunu, denial timing'i, recovery timing'i, operator control placement'ı ve beklenen GNSS kalitesini belirleyecektir.)*

---

# 186. Pilot Data Label (Pilot Veri Etiketi)

Pilot sessions will be clearly labeled `PILOT` or equivalent. *(Pilot oturumlar açık şekilde `PILOT` veya eşdeğer olarak etiketlenecektir.)*

---

# 187. Final Benchmark Label (Final Benchmark Etiketi)

Final formal sessions will be clearly labeled `FINAL_BENCHMARK` or equivalent. *(Nihai resmî oturumlar açık şekilde `FINAL_BENCHMARK` veya eşdeğer olarak etiketlenecektir.)*

---

# 188. Session Inclusion Review (Oturum Inclusion İncelemesi)

Every final session will undergo an integrity and reference-quality review before inclusion in the primary metrics table. *(Her final oturum primary metrics table'a inclusion öncesinde integrity ve reference-quality review'dan geçecektir.)*

---

# 189. Session Exclusion Reasons (Oturum Exclusion Nedenleri)

Candidate exclusion reasons include Ground Truth Firewall violation, critical logging failure, route corruption, invalid GNSS reference quality, major configuration mismatch, and unrecoverable timestamp corruption. *(Aday exclusion nedenleri Ground Truth Firewall violation, critical logging failure, route corruption, invalid GNSS reference quality, major configuration mismatch ve unrecoverable timestamp corruption'ı içerir.)*

---

# 190. Poor Navigation Accuracy Is Not an Exclusion Reason (Kötü Navigasyon Doğruluğu Exclusion Nedeni Değildir)

A valid run with large NAVGUARD error remains part of the evidence. *(Büyük NAVGUARD error içeren geçerli run kanıtın parçası olarak kalır.)*

---

# 191. Inclusion Status (Inclusion Durumu)

```text id="e0dn0c"
INCLUDED
EXCLUDED
INCLUDED_WITH_LIMITATIONS
PENDING_REVIEW
```

---

# 192. Exclusion Evidence Must Be Preserved (Exclusion Kanıtı Korunmalıdır)

Excluded sessions will remain stored and their exclusion reason will remain documented. *(Excluded oturumlar saklanmaya devam edecek ve exclusion reason dokümante edilmiş kalacaktır.)*

---

# 193. No Session Deletion for Bad Results (Kötü Sonuç İçin Session Silme Olmaması)

A session will not be deleted because it reduces NAVGUARD's average performance. *(Oturum NAVGUARD'ın average performance değerini düşürdüğü için silinmeyecektir.)*

---

# 194. Experiment Order Logging (Deney Sırası Logging)

The execution order of formal runs will be recorded. *(Resmî run'ların execution order'ı kaydedilecektir.)*

---

# 195. Environment Metadata (Ortam Metadata Bilgisi)

Each principal session may include environment metadata. *(Her temel oturum environment metadata bilgisi içerebilir.)*

---

# 196. Candidate Environment Fields (Aday Ortam Alanları)

```text id="fjv43t"
indoorOutdoor
lightingCondition
weatherNote
crowdLevel
visualTexture
magneticDisturbanceNote
surfaceType
routeCondition
```

---

# 197. Environmental Metadata Is Descriptive (Çevresel Metadata Tanımlayıcıdır)

Unless a dedicated experiment is designed around one variable, environment metadata remains descriptive rather than causal proof. *(Belirli değişken etrafında özel deney tasarlanmadıkça environment metadata causal proof yerine descriptive kalır.)*

---

# 198. Field Experiment Evidence Package (Saha Deneyi Kanıt Paketi)

Every principal session should produce a complete evidence package. *(Her temel oturum tam evidence package üretmelidir.)*

---

# 199. Required Evidence Package Components (Gerekli Kanıt Paketi Bileşenleri)

```text id="rzlt2m"
Session manifest
Raw IMU logs
GNSS ground-truth log
GNSS status log when enabled
ARCore pose log when enabled
Step events
Heading estimates
AI outputs when enabled
PDR state
Fused state
Uncertainty state
Denial event
Recovery event
Integrity report
Field notes
```

---

# 200. Optional Evidence Components (İsteğe Bağlı Kanıt Bileşenleri)

Optional evidence may include screenshots, profiler captures, battery records, and photographs of route markers when useful for documentation. *(İsteğe bağlı kanıt screenshots, profiler capture'ları, battery record'ları ve dokümantasyon için kullanışlı olduğunda rota marker'larının fotoğraflarını içerebilir.)*

---

# 201. Camera Photos Are Documentation Only (Kamera Fotoğrafları Yalnızca Dokümantasyondur)

Route documentation photographs are separate from ARCore runtime camera data. *(Rota dokümantasyon fotoğrafları ARCore runtime kamera verisinden ayrıdır.)*

---

# 202. Evidence Completeness Check (Kanıt Tamlık Kontrolü)

A formal session will be checked for required evidence before being accepted as complete. *(Resmî oturum complete olarak kabul edilmeden önce gerekli evidence için kontrol edilecektir.)*

---

# 203. Session Manifest Must Match Field Record (Session Manifest Saha Kaydıyla Eşleşmelidir)

Route ID, configuration, session ID, and timestamps must be internally consistent across the evidence package. *(Route ID, configuration, session ID ve timestamps evidence package boyunca internally consistent olmalıdır.)*

---

# 204. Benchmark Route Table (Benchmark Rota Tablosu)

The final benchmark report will maintain a route table. *(Nihai benchmark raporu rota tablosu tutacaktır.)*

```text id="74n37b"
Route ID
Route Type
Approximate Length
Turn Count
Environment
Ground Truth Method
Repeat Count
Denial Rule
Recovery Rule
```

---

# 205. Field Run Table (Saha Run Tablosu)

A separate run table will record each completed experiment. *(Ayrı run table tamamlanan her deneyi kaydedecektir.)*

```text id="zg1g1q"
Session ID
Route ID
Repeat
Build
Configuration
Start Time
Denied Duration
Denied Distance
Ground Truth Availability
Integrity
Inclusion
```

---

# 206. Matched Session Comparison Table (Eşleşmiş Oturum Karşılaştırma Tablosu)

Replay outputs for A-D may be summarized per physical recording. *(A-D replay çıktıları fiziksel kayıt başına özetlenebilir.)*

```text id="k3bwox"
Session ID
A Final Error
B Final Error
C Final Error
D Final Error
A Median Error
B Median Error
C Median Error
D Median Error
```

---

# 207. Route-Level Aggregation (Rota Seviyesi Aggregation)

Metrics will also be aggregated by route type. *(Metrikler rota türüne göre de aggregate edilecektir.)*

---

# 208. Overall Aggregation (Genel Aggregation)

Overall matched-session metrics will support the primary research conclusion. *(Genel matched-session metrics temel araştırma sonucunu destekleyecektir.)*

---

# 209. Median as Primary Robust Statistic (Temel Robust İstatistik Olarak Median)

Median position error remains an important primary summary because it is less sensitive to a small number of extreme samples than the mean. *(Median position error az sayıdaki extreme sample'a mean'e göre daha az hassas olduğu için önemli temel summary olarak kalır.)*

---

# 210. Mean Is Still Reported (Mean Yine Raporlanır)

Mean position error will still be reported to expose overall average behavior. *(Mean position error genel average behavior'ı göstermek için yine raporlanacaktır.)*

---

# 211. Final Error (Nihai Hata)

Final position error at the recovery boundary will be retained as a major drift indicator. *(Recovery boundary'deki final position error büyük drift indicator olarak korunacaktır.)*

---

# 212. P95 Error (P95 Hata)

P95 position error will expose high-error behavior that median alone may hide. *(P95 position error median'ın tek başına gizleyebileceği high-error behavior'ı ortaya çıkaracaktır.)*

---

# 213. Drift Per Minute (Dakika Başına Drift)

```text id="9y7zc2"
driftRateTime =
finalPositionError /
deniedDuration
```

Units will be expressed consistently. *(Birimler tutarlı şekilde ifade edilecektir.)*

---

# 214. Drift Per Distance (Mesafe Başına Drift)

```text id="nt03af"
driftRateDistance =
finalPositionError /
referenceTravelDistance
```

---

# 215. Heading Error (Heading Hatası)

Heading MAE will be evaluated where a suitable reference can be defined. *(Uygun referans tanımlanabildiğinde heading MAE değerlendirilecektir.)*

---

# 216. Step Count Error (Adım Sayısı Hatası)

Controlled sessions will compare detected step count against manually counted or otherwise verified steps. *(Kontrollü oturumlar detected step count'u manually counted veya başka şekilde verified adımlarla karşılaştıracaktır.)*

---

# 217. Step Length Error (Adım Uzunluğu Hatası)

Known-distance calibration and test segments may support step-length MAE evaluation. *(Known-distance calibration ve test segmentleri step-length MAE değerlendirmesini destekleyebilir.)*

---

# 218. ARCore Availability (ARCore Kullanılabilirliği)

The fraction of relevant time in acceptable tracking state will be recorded for ARCore-enabled sessions. *(ARCore-enabled oturumlar için acceptable tracking state içerisinde geçen ilgili zaman oranı kaydedilecektir.)*

---

# 219. AI Runtime Evidence (AI Runtime Kanıtı)

Motion-classification latency and accepted motion-state behavior will be retained for AI-enabled runs. *(Motion-classification latency ve accepted motion-state behavior AI-enabled run'lar için korunacaktır.)*

---

# 220. Performance Field Metrics (Performans Saha Metrikleri)

Battery percentage change, session duration, memory observations, thermal observations, and storage growth may be retained during endurance tests. *(Battery percentage change, session duration, memory observations, thermal observations ve storage growth endurance testleri sırasında korunabilir.)*

---

# 221. No Performance Claim Without Measured Data (Ölçülmüş Veri Olmadan Performans İddiası Olmaması)

Battery or thermal efficiency will not be claimed until representative measurements exist. *(Temsili ölçümler mevcut olmadan battery veya thermal efficiency iddia edilmeyecektir.)*

---

# 222. Session Timing Integrity (Oturum Zamanlama Bütünlüğü)

All field-event timing will use the common monotonic experiment timeline. *(Tüm field-event timing ortak monotonik experiment timeline'ı kullanacaktır.)*

---

# 223. Wall Clock Is Contextual (Wall Clock Bağlamsaldır)

Human-readable clock time may be stored as metadata but will not replace monotonic timing for alignment. *(Human-readable clock time metadata olarak saklanabilir ancak alignment için monotonik timing'in yerini almayacaktır.)*

---

# 224. GNSS and IMU Alignment (GNSS ve IMU Hizalama)

Evaluation analysis will align GNSS and estimator states according to the timestamp policies defined in Page 13. *(Evaluation analysis GNSS ve estimator state'lerini Page 13'te tanımlanan timestamp policies'e göre hizalayacaktır.)*

---

# 225. No Nearest-Sample Abuse (Nearest-Sample Kötüye Kullanımı Olmaması)

Large temporal mismatches will not be hidden by blindly pairing the nearest samples. *(Büyük temporal mismatch'ler nearest sample'ları kör şekilde eşleyerek gizlenmeyecektir.)*

---

# 226. Analysis Alignment Policy (Analiz Hizalama Politikası)

The final trajectory-alignment tolerance will be frozen before formal benchmark calculation. *(Nihai trajectory-alignment tolerance resmî benchmark calculation öncesinde sabitlenecektir.)*

---

# 227. Field Data Review Workflow (Saha Verisi İnceleme Workflow'u)

After each important field day, recorded sessions will be reviewed before additional benchmark collection. *(Her önemli field day sonrasında kaydedilmiş oturumlar ek benchmark collection öncesinde incelenecektir.)*

---

# 228. Review Purpose (İnceleme Amacı)

The review will check data integrity and experiment execution, not retune final benchmark algorithms after benchmark freeze. *(Review data integrity ve experiment execution'ı kontrol edecek, benchmark freeze sonrasında final benchmark algoritmalarını retune etmeyecektir.)*

---

# 229. Pilot Review vs Final Review (Pilot Review ile Final Review)

Pilot review may lead to protocol changes. *(Pilot review protocol değişikliklerine yol açabilir.)*

Final benchmark review may classify validity but must not optimize the algorithm from the observed outcome. *(Final benchmark review validity'yi sınıflandırabilir ancak observed outcome'dan algoritmayı optimize etmemelidir.)*

---

# 230. Formal Field Experiment Phases (Resmî Saha Deney Fazları)

The complete field program will use four phases. *(Tam saha programı dört faz kullanacaktır.)*

```text id="yp9mml"
PHASE 1 — Pilot Validation
(PHASE 1 — Pilot Validation)

PHASE 2 — Parameter Freeze
(PHASE 2 — Parameter Sabitleme)

PHASE 3 — Final Benchmark Collection
(PHASE 3 — Final Benchmark Veri Toplama)

PHASE 4 — Stress / Supplementary Tests
(PHASE 4 — Stress / Tamamlayıcı Testler)
```

---

# 231. Phase 1 — Pilot Validation (Faz 1 — Pilot Validation)

Pilot sessions will verify route practicality, GNSS ground-truth quality, operator flow, denial timing, recovery timing, and logging completeness. *(Pilot oturumlar rota practicality, GNSS ground-truth quality, operator flow, denial timing, recovery timing ve logging completeness'i doğrulayacaktır.)*

---

# 232. Pilot Exit Criteria (Pilot Çıkış Kriterleri)

Pilot phase ends only when the principal route protocol can be executed repeatably without unresolved critical failures. *(Pilot phase yalnızca temel rota protokolü unresolved critical failure olmadan tekrarlanabilir şekilde uygulanabildiğinde sona erer.)*

---

# 233. Phase 2 — Parameter Freeze (Faz 2 — Parametre Sabitleme)

Algorithms, thresholds, models, preprocessing, denial rules, recovery rules, route definitions, and inclusion policies will be frozen. *(Algoritmalar, threshold'lar, modeller, preprocessing, denial rules, recovery rules, route definitions ve inclusion policies sabitlenecektir.)*

---

# 234. Freeze Record (Freeze Kaydı)

The frozen benchmark configuration will be stored in Page 43 and machine-readable configuration artifacts. *(Sabitlenmiş benchmark yapılandırması Page 43 ve machine-readable configuration artifact'larında saklanacaktır.)*

---

# 235. Phase 3 — Final Benchmark Collection (Faz 3 — Final Benchmark Veri Toplama)

The principal straight, turn-heavy, and closed-route repeats will be collected under the frozen configuration. *(Temel düz, dönüş yoğun ve kapalı rota tekrarları sabitlenmiş yapılandırma altında toplanacaktır.)*

---

# 236. Final Benchmark Changes (Final Benchmark Değişiklikleri)

Any material algorithm or protocol change during Phase 3 must be documented and may require restarting affected benchmark runs. *(Phase 3 sırasında herhangi bir material algorithm veya protocol change dokümante edilmeli ve etkilenen benchmark run'larının yeniden başlatılmasını gerektirebilir.)*

---

# 237. Phase 4 — Stress and Supplementary Tests (Faz 4 — Stress ve Tamamlayıcı Testler)

Stress tests will evaluate conditions such as magnetic disturbance, low visual texture, repeated recovery, walking-stop-walking, longer outages, and runtime endurance. *(Stress testleri magnetic disturbance, low visual texture, repeated recovery, walking-stop-walking, longer outages ve runtime endurance gibi koşulları değerlendirecektir.)*

---

# 238. Stress Results Are Secondary (Stress Sonuçları İkincildir)

Stress results will supplement rather than replace the principal matched-route benchmark. *(Stress sonuçları temel matched-route benchmark'ın yerini almak yerine onu tamamlayacaktır.)*

---

# 239. Field Experiment Failure States (Saha Deney Hata Durumları)

A field run may fail operationally even when the application remains running. *(Uygulama çalışmaya devam etse bile field run operasyonel olarak başarısız olabilir.)*

---

# 240. Candidate Field Failure States (Aday Saha Hata Durumları)

```text id="jm5s58"
ROUTE_ABORTED
GROUND_TRUTH_INVALID
CRITICAL_LOGGING_FAILURE
SENSOR_FAILURE
ARCORE_FAILURE
CONFIGURATION_MISMATCH
GROUND_TRUTH_FIREWALL_VIOLATION
RECOVERY_FAILURE
APP_CRASH
OPERATOR_ERROR
```

---

# 241. Route Abort (Rota Abort)

A route may be aborted for safety, environment, or operational reasons. *(Rota güvenlik, çevre veya operasyonel nedenlerle abort edilebilir.)*

---

# 242. Safety Has Priority (Güvenlik Önceliklidir)

No benchmark session is more important than pedestrian safety. *(Hiçbir benchmark oturumu yaya güvenliğinden daha önemli değildir.)*

---

# 243. Aborted Session Preservation (Abort Edilmiş Oturumun Korunması)

Aborted-session evidence will remain stored where technically possible. *(Abort edilmiş oturum evidence teknik olarak mümkün olduğunda saklanacaktır.)*

---

# 244. Field Experiment Acceptance Criteria (Saha Deney Kabul Kriterleri)

A principal field session can be considered valid only if its mandatory protocol conditions are satisfied. *(Temel saha oturumu yalnızca zorunlu protocol condition'ları karşılanırsa geçerli kabul edilebilir.)*

---

# 245. Mandatory Validity Conditions (Zorunlu Geçerlilik Koşulları)

The correct build must be used. *(Doğru build kullanılmalıdır.)*

The correct route must be followed. *(Doğru rota izlenmelidir.)*

The correct configuration must be active. *(Doğru yapılandırma aktif olmalıdır.)*

The Ground Truth Firewall must remain valid. *(Ground Truth Firewall geçerli kalmalıdır.)*

Mandatory sensor and logging evidence must be available. *(Zorunlu sensor ve logging evidence kullanılabilir olmalıdır.)*

---

# 246. Ground Truth Validity Condition (Ground Truth Geçerlilik Koşulu)

A session used for primary positional metrics must have acceptable reference quality according to the frozen inclusion policy. *(Primary positional metrics için kullanılan oturum frozen inclusion policy'ye göre kabul edilebilir reference quality'ye sahip olmalıdır.)*

---

# 247. Recovery Validity Condition (Recovery Geçerlilik Koşulu)

If recovery error is used as a formal metric, its pre-correction evidence must have been captured before correction. *(Recovery error formal metric olarak kullanılıyorsa düzeltme öncesi evidence correction öncesinde yakalanmış olmalıdır.)*

---

# 248. Timing Validity Condition (Zamanlama Geçerlilik Koşulu)

Critical timestamps must remain valid and interpretable on the common experiment timeline. *(Kritik timestamps ortak experiment timeline üzerinde geçerli ve yorumlanabilir kalmalıdır.)*

---

# 249. Evidence Completeness Condition (Kanıt Tamlık Koşulu)

The session manifest and required artifacts must pass finalization integrity checks. *(Session manifest ve gerekli artifact'lar finalization integrity kontrollerini geçmelidir.)*

---

# 250. Minimum Successful Field Program (Minimum Başarılı Saha Programı)

The minimum successful field program will include pilot validation, at least three repeats each of straight, turn-heavy, and closed or near-closed routes, Evaluation Mode ground-truth recording, software GNSS denial, controlled recovery, session integrity review, and quantitative comparison against PDR-only baseline. *(Minimum başarılı saha programı pilot validation, düz, dönüş yoğun ve kapalı veya yaklaşık kapalı rotaların her biri için en az üç tekrar, Evaluation Mode ground-truth recording, software GNSS denial, controlled recovery, session integrity review ve PDR-only baseline'a karşı quantitative comparison içerecektir.)*

---

# 251. Target Successful Field Program (Hedef Başarılı Saha Programı)

The target field program will additionally include walk-stop-walk, magnetic disturbance, low-texture ARCore degradation, longer denied intervals, repeated recovery, and long-duration performance sessions. *(Hedef saha programı ek olarak walk-stop-walk, magnetic disturbance, low-texture ARCore degradation, daha uzun denied interval'lar, repeated recovery ve long-duration performance oturumlarını içerecektir.)*

---

# 252. Optional Field Enhancements (İsteğe Bağlı Saha İyileştirmeleri)

Optional enhancements may include alternative phone placements. *(İsteğe bağlı iyileştirmeler alternatif telefon placement'larını içerebilir.)*

Optional enhancements may include additional route geometries. *(İsteğe bağlı iyileştirmeler ek rota geometrilerini içerebilir.)*

Optional enhancements may include exploratory cross-device testing. *(İsteğe bağlı iyileştirmeler exploratory cross-device testing içerebilir.)*

---

# 253. Field Experiment Non-Goals (Saha Deneyi Olmayan Hedefler)

The principal experiment will not claim military-grade navigation performance. *(Temel deney military-grade navigasyon performansı iddia etmeyecektir.)*

The principal experiment will not claim permanent GNSS replacement. *(Temel deney permanent GNSS replacement iddia etmeyecektir.)*

The principal experiment will not use RF jamming or spoofing. *(Temel deney RF jamming veya spoofing kullanmayacaktır.)*

---

# 254. Additional Field Non-Goals (Ek Saha Olmayan Hedefler)

The principal experiment will not claim centimeter-level truth from ordinary smartphone GNSS. *(Temel deney normal smartphone GNSS'ten centimeter-level truth iddia etmeyecektir.)*

The principal experiment will not treat one successful route as proof of general navigation reliability. *(Temel deney tek başarılı rotayı genel navigasyon reliability kanıtı olarak ele almayacaktır.)*

---

# 255. Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kararlar)

NAVGUARD will use controlled repeated physical field experiments on the Xiaomi Redmi Note 9 Pro. *(NAVGUARD Xiaomi Redmi Note 9 Pro üzerinde kontrollü tekrarlanan fiziksel saha deneyleri kullanacaktır.)*

---

# 256. Principal Route Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Temel Rota Kararları)

The principal route categories are straight, turn-heavy, and closed or near-closed. *(Temel rota kategorileri düz, dönüş yoğun ve kapalı veya yaklaşık kapalıdır.)*

---

# 257. Repeat Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Tekrar Kararları)

The provisional final plan targets at least three physical repeats per principal route category. *(Geçici final plan her temel rota kategorisi için en az üç fiziksel tekrar hedefler.)*

---

# 258. Device Placement Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Cihaz Yerleşim Kararları)

The principal benchmark will use one controlled and repeatable phone placement. *(Temel benchmark tek kontrollü ve tekrarlanabilir telefon placement kullanacaktır.)*

---

# 259. Denial Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kesinti Kararları)

GNSS denial will be created through software estimator exclusion. *(GNSS denial yazılım tahmin motoru exclusion üzerinden oluşturulacaktır.)*

The denial start will be explicit and timestamped. *(Kesinti başlangıcı açık ve timestamped olacaktır.)*

---

# 260. RF Decisions Frozen by This Document (Bu Dokümanla Sabitlenen RF Kararları)

RF jamming, spoofing, and intentional interference are outside the experiment. *(RF jamming, spoofing ve intentional interference deneyin dışındadır.)*

---

# 261. Ground Truth Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Ground Truth Kararları)

Evaluation GNSS may remain active as protected reference evidence while estimator access is blocked. *(Tahmin motoru erişimi blocked iken Evaluation GNSS korunan referans evidence olarak aktif kalabilir.)*

Protected ground truth will remain hidden from the estimator and the blinded live operator view. *(Korunan ground truth tahmin motorundan ve blinded live operator view'dan gizli kalacaktır.)*

---

# 262. Recovery Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Recovery Kararları)

Recovery will occur through explicit request, quality validation, pre-correction error capture, relocalization, and GNSS restoration. *(Recovery açık request, kalite validation, pre-correction error capture, relocalization ve GNSS restoration üzerinden gerçekleşecektir.)*

---

# 263. Evidence Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kanıt Kararları)

Every principal field run will retain a structured session manifest, mandatory sensor evidence, navigation outputs, denial/recovery events, integrity result, and field notes. *(Her temel field run structured session manifest, mandatory sensor evidence, navigation outputs, denial/recovery event'leri, integrity result ve field notes koruyacaktır.)*

---

# 264. Poor Result Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kötü Sonuç Kararları)

Scientifically valid poor-performing sessions will remain part of the evidence. *(Bilimsel olarak geçerli kötü performanslı oturumlar evidence'ın parçası olarak kalacaktır.)*

---

# 265. Pilot Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Pilot Kararları)

Pilot sessions may be used to refine route lengths, timing, thresholds, and field protocol. *(Pilot oturumlar rota uzunluklarını, timing'i, threshold'ları ve field protocol'ü iyileştirmek için kullanılabilir.)*

---

# 266. Final Benchmark Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Final Benchmark Kararları)

Final benchmark sessions will not be used for post-hoc algorithm tuning. *(Final benchmark oturumları post-hoc algorithm tuning için kullanılmayacaktır.)*

---

# 267. Inclusion Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Inclusion Kararları)

Session inclusion and exclusion rules must be frozen before final benchmark outcomes are reviewed. *(Session inclusion ve exclusion kuralları final benchmark sonuçları incelenmeden önce sabitlenmelidir.)*

---

# 268. Decisions Pending Pilot Sessions (Pilot Oturumları Bekleyen Kararlar)

Exact route lengths remain pending pilot validation. *(Kesin rota uzunlukları pilot validation beklemektedir.)*

Exact denied durations remain pending pilot validation. *(Kesin denied duration'lar pilot validation beklemektedir.)*

Exact recovery locations remain pending pilot validation. *(Kesin recovery location'lar pilot validation beklemektedir.)*

---

# 269. Decisions Pending Device Measurements (Cihaz Ölçümlerini Bekleyen Kararlar)

The exact stationary calibration duration remains pending physical-device evidence. *(Kesin stationary calibration duration fiziksel cihaz evidence'ını beklemektedir.)*

The final GNSS reference-quality thresholds remain pending field measurements. *(Nihai GNSS reference-quality threshold'ları field measurement'ları beklemektedir.)*

---

# 270. Decisions Pending Usability Tests (Kullanılabilirlik Testlerini Bekleyen Kararlar)

The final phone placement and live control placement remain pending pilot walking usability tests. *(Nihai telefon placement ve live control placement pilot walking usability testlerini beklemektedir.)*

---

# 271. Decisions Pending Performance Profiling (Performans Profiling Bekleyen Kararlar)

The final endurance-session duration and battery/thermal warning thresholds remain pending profiling. *(Nihai endurance-session duration ve battery/thermal warning threshold'ları profiling beklemektedir.)*

---

# 272. Final Field Experiment Architecture Statement (Nihai Saha Deney Mimarisi Bildirimi)

**NAVGUARD will validate its central research claim through controlled, repeatable pedestrian experiments on the Xiaomi Redmi Note 9 Pro using three principal route geometries—straight, turn-heavy, and closed or near-closed—with a provisional target of at least three physical repeats per route category.** *(NAVGUARD temel araştırma iddiasını Xiaomi Redmi Note 9 Pro üzerinde üç temel rota geometrisi—düz, dönüş yoğun ve kapalı veya yaklaşık kapalı—kullanarak kontrollü, tekrarlanabilir yaya deneyleriyle doğrulayacak ve rota kategorisi başına geçici olarak en az üç fiziksel tekrar hedefleyecektir.)*

**Every formal field session will begin from verified permissions, storage readiness, mandatory sensor availability, calibration readiness, and a validated GNSS anchor, after which the user will follow a predeclared route using a controlled phone placement and a reproducible starting orientation.** *(Her resmî saha oturumu doğrulanmış permission'lar, storage readiness, mandatory sensor availability, calibration readiness ve validated GNSS anchor ile başlayacak; ardından kullanıcı kontrollü telefon placement ve tekrarlanabilir başlangıç yönelimi kullanarak önceden tanımlanmış rotayı izleyecektir.)*

**GNSS denial will be introduced through a precise software authorization boundary rather than physical signal interference, while Evaluation Mode may continue recording GNSS privately as independent reference evidence that remains unavailable to PDR, AI, EKF, anchor updates, uncertainty correction, and the blinded live user interface.** *(GNSS denial fiziksel sinyal müdahalesi yerine kesin yazılım authorization boundary üzerinden oluşturulacak, Evaluation Mode ise GNSS'i PDR, AI, EKF, anchor update'leri, uncertainty correction ve blinded live user interface için kullanılamaz kalırken bağımsız reference evidence olarak private şekilde kaydetmeye devam edebilecektir.)*

**The denial start, route checkpoints, recovery condition, recovery request, pre-correction estimator state, accepted GNSS reference, relocalization event, and session end will all be timestamped and stored so that the entire physical experiment can be reconstructed later from evidence rather than from operator memory.** *(Kesinti başlangıcı, rota checkpoint'leri, recovery condition, recovery request, pre-correction estimator state, accepted GNSS reference, relocalization event ve session end'in tamamı timestamped ve stored olacak; böylece tüm fiziksel deney daha sonra operatör hafızası yerine evidence üzerinden yeniden oluşturulabilecektir.)*

**Principal final benchmark sessions will be collected only after pilot validation and parameter freeze, and scientifically valid poor-performing sessions will remain in the dataset while invalid sessions are excluded only through predeclared integrity and ground-truth-quality criteria whose reasons remain auditable.** *(Temel final benchmark oturumları yalnızca pilot validation ve parameter freeze sonrasında toplanacak, bilimsel olarak geçerli kötü performanslı oturumlar dataset içerisinde kalırken invalid oturumlar yalnızca nedenleri auditable kalan önceden tanımlanmış integrity ve ground-truth-quality kriterleri üzerinden hariç tutulacaktır.)*

**Where possible, the same raw physical recording will be replayed through configurations A, B, C, and D so each algorithm sees identical IMU, GNSS-reference, ARCore, timing, denial-boundary, and route evidence, while separate live tests will still verify that the complete full-stack NAVGUARD configuration operates correctly on the physical device.** *(Mümkün olduğunda aynı ham fiziksel kayıt Configuration A, B, C ve D üzerinden replay edilecek; böylece her algoritma aynı IMU, GNSS-reference, ARCore, timing, denial-boundary ve route evidence görecek, ayrı live testler ise tam full-stack NAVGUARD yapılandırmasının fiziksel cihaz üzerinde doğru çalıştığını doğrulamaya devam edecektir.)*

**Stress sessions involving walk-stop-walk behavior, natural magnetic disturbance, weak visual texture, longer denied intervals, ARCore tracking degradation, repeated recovery, and long-duration combined-stack operation will extend the principal benchmark without replacing it.** *(Walk-stop-walk behavior, doğal magnetic disturbance, zayıf visual texture, daha uzun denied interval'lar, ARCore tracking degradation, repeated recovery ve long-duration combined-stack operation içeren stress oturumları temel benchmark'ın yerini almadan onu genişletecektir.)*

**The final field evidence will therefore connect physical route execution to session manifests, raw sensor data, protected GNSS ground truth, algorithm outputs, integrity status, recovery measurements, and matched configuration metrics, allowing NAVGUARD's final conclusions to be based on reproducible measured evidence rather than demonstration-only behavior.** *(Nihai saha evidence böylece fiziksel rota uygulamasını session manifest'lere, raw sensor data'ya, protected GNSS ground truth'a, algorithm output'larına, integrity status'a, recovery measurement'larına ve matched configuration metrics'e bağlayacak ve NAVGUARD'ın final sonuçlarının demonstration-only behavior yerine tekrarlanabilir measured evidence'a dayanmasını sağlayacaktır.)*

---

# 273. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development Field Experiment Plan Completed *(Doküman Durumu: Geliştirme Öncesi Saha Deney Planı Tamamlandı)*

**Primary Physical Device:** Xiaomi Redmi Note 9 Pro *(Temel Fiziksel Cihaz: Xiaomi Redmi Note 9 Pro)*

**Additional Hardware Required:** No *(Ek Donanım Gerekli: Hayır)*

**Primary Experiment Type:** Controlled Pedestrian Navigation *(Temel Deney Türü: Kontrollü Yaya Navigasyonu)*

**GNSS-Denied Method:** Software Estimator Exclusion *(GNSS Kesintili Yöntemi: Yazılım Tahmin Motoru Exclusion)*

**RF Jamming / Spoofing:** Forbidden *(RF Jamming / Spoofing: Yasak)*

**Evaluation GNSS Logging:** Independent Reference Stream *(Evaluation GNSS Logging: Bağımsız Referans Stream'i)*

**Ground Truth Estimator Access During Denial:** Forbidden *(Kesinti Sırasında Ground Truth Tahmin Motoru Erişimi: Yasak)*

**Ground Truth Live Display During Blinded Run:** Hidden *(Blinded Run Sırasında Ground Truth Canlı Gösterim: Gizli)*

**Principal Route 1:** Straight *(Temel Rota 1: Düz)*

**Principal Route 2:** Turn-Heavy *(Temel Rota 2: Dönüş Yoğun)*

**Principal Route 3:** Closed / Near-Closed *(Temel Rota 3: Kapalı / Yaklaşık Kapalı)*

**Target Physical Repeats per Principal Route:** ≥3 *(Temel Rota Başına Hedef Fiziksel Tekrar: ≥3)*

**Approximate Principal Session Count:** ~9 *(Yaklaşık Temel Oturum Sayısı: ~9)*

**Phone Placement:** Controlled / Repeatable *(Telefon Yerleşimi: Kontrollü / Tekrarlanabilir)*

**Arbitrary Placement Benchmark:** Outside Minimum Scope *(Keyfi Placement Benchmark: Minimum Kapsam Dışı)*

**Pre-Run Stationary Phase:** Mandatory *(Run Öncesi Stationary Phase: Zorunlu)*

**GNSS Anchor Before Denial:** Mandatory *(Kesinti Öncesi GNSS Anchor: Zorunlu)*

**First GNSS Fix Auto-Anchor:** Forbidden *(İlk GNSS Fix Auto-Anchor: Yasak)*

**Denial Start:** Explicit + Timestamped *(Kesinti Başlangıcı: Açık + Timestamped)*

**Preferred Denial Trigger:** Predeclared Physical Route Marker / Checkpoint *(Tercih Edilen Kesinti Tetikleyicisi: Önceden Tanımlanmış Fiziksel Rota Marker / Checkpoint)*

**Exact Denied Duration:** Pending Pilot Tests *(Kesin Kesintili Süre: Pilot Testleri Bekliyor)*

**Recovery Point:** Predeclared *(Recovery Noktası: Önceden Tanımlı)*

**First Recovery Fix Auto-Accept:** Forbidden *(İlk Recovery Fix Auto-Accept: Yasak)*

**Pre-Correction Recovery Error:** Mandatory *(Düzeltme Öncesi Recovery Hatası: Zorunlu)*

**Recovery Before Error Capture:** Forbidden *(Hata Yakalama Öncesi Recovery Correction: Yasak)*

**Principal Comparison Configurations:** A / B / C / D *(Temel Karşılaştırma Yapılandırmaları: A / B / C / D)*

**Preferred Algorithm Comparison:** Same-Session Replay *(Tercih Edilen Algoritma Karşılaştırması: Same-Session Replay)*

**Live Full-Stack Physical Validation:** Mandatory *(Canlı Full-Stack Fiziksel Validation: Zorunlu)*

**Pilot Sessions:** Required *(Pilot Oturumlar: Gerekli)*

**Parameter Freeze Before Final Benchmark:** Mandatory *(Final Benchmark Öncesi Parametre Freeze: Zorunlu)*

**Post-Hoc Final Benchmark Tuning:** Forbidden *(Post-Hoc Final Benchmark Tuning: Yasak)*

**Ground Truth Inclusion Policy:** Must Be Frozen Pre-Benchmark *(Ground Truth Inclusion Politikası: Benchmark Öncesi Sabitlenmeli)*

**Poor Valid Sessions:** Retained *(Kötü Geçerli Oturumlar: Korunur)*

**Invalid Sessions:** Preserved + Documented *(Geçersiz Oturumlar: Korunur + Dokümante Edilir)*

**Stress Scenario — Walk-Stop-Walk:** Target *(Stress Senaryosu — Walk-Stop-Walk: Hedef)*

**Stress Scenario — Magnetic Disturbance:** Target *(Stress Senaryosu — Magnetic Disturbance: Hedef)*

**Stress Scenario — Low Visual Texture:** Target *(Stress Senaryosu — Low Visual Texture: Hedef)*

**Stress Scenario — Longer Denial:** Target *(Stress Senaryosu — Longer Denial: Hedef)*

**Stress Scenario — Repeated Recovery:** Optional *(Stress Senaryosu — Repeated Recovery: İsteğe Bağlı)*

**Endurance Session:** Target *(Endurance Oturumu: Hedef)*

**Indoor GNSS as Precise Ground Truth:** Forbidden by Default *(Indoor GNSS'i Kesin Ground Truth Olarak Kullanma: Varsayılan Olarak Yasak)*

**Indoor Alternative References:** Known Geometry + Checkpoints + Distance + Closure Error *(Indoor Alternatif Referanslar: Bilinen Geometri + Checkpoint + Mesafe + Closure Error)*

**Field Safety Priority:** Mandatory *(Saha Güvenliği Önceliği: Zorunlu)*

**Route Safety Over Benchmark Completion:** Mandatory *(Benchmark Tamamlamaya Karşı Rota Güvenliği: Öncelikli)*

**Session Evidence Package:** Mandatory *(Session Evidence Package: Zorunlu)*

**Field Notes:** Supported *(Saha Notları: Destekleniyor)*

**Exact Route Lengths:** Pending Pilot Validation *(Kesin Rota Uzunlukları: Pilot Validation Bekleniyor)*

**Exact Denial Durations:** Pending Pilot Validation *(Kesin Denial Duration'lar: Pilot Validation Bekleniyor)*

**Exact Recovery Locations:** Pending Pilot Validation *(Kesin Recovery Location'lar: Pilot Validation Bekleniyor)*

**Exact Stationary Preparation Duration:** Pending Physical Audit *(Kesin Stationary Preparation Duration: Fiziksel Audit Bekleniyor)*

**Final GNSS Reference-Quality Thresholds:** Pending Field Calibration *(Nihai GNSS Reference-Quality Threshold'ları: Saha Kalibrasyonu Bekleniyor)*

**Final Phone Placement:** Pending Pilot Usability Test *(Nihai Telefon Placement: Pilot Kullanılabilirlik Testi Bekleniyor)*

**Final Endurance Duration:** Pending Performance Profiling *(Nihai Endurance Duration: Performans Profiling Bekleniyor)*

**Next Documentation Item:** 35 — Benchmark & Evaluation Metrics *(Sonraki Dokümantasyon Öğesi: 35 — Benchmark ve Değerlendirme Metrikleri)*
