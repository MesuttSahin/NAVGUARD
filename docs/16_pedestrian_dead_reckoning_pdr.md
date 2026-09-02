# 16 — Pedestrian Dead Reckoning — PDR (Yaya Ölü Hesaplama — PDR)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the Pedestrian Dead Reckoning architecture, mathematical propagation model, input and output interfaces, initialization procedure, step-based displacement logic, step-length handling, heading dependency, stationary behavior, running behavior, uncertainty growth, drift mechanisms, fallback behavior, logging requirements, and validation strategy of NAVGUARD. *(Bu doküman, NAVGUARD’ın Yaya Ölü Hesaplama mimarisini, matematiksel ilerletme modelini, girdi ve çıktı arayüzlerini, başlatma prosedürünü, adım tabanlı yer değiştirme mantığını, adım uzunluğu yönetimini, yön bağımlılığını, sabit durum davranışını, koşma davranışını, belirsizlik büyümesini, sürüklenme mekanizmalarını, geri dönüş davranışını, kayıt gereksinimlerini ve doğrulama stratejisini tanımlar.)*

PDR will provide the minimum independent local-position estimator used after GNSS access is removed from the active estimator. *(PDR, aktif tahmin motorundan GNSS erişimi kaldırıldıktan sonra kullanılan minimum bağımsız yerel konum tahmin motorunu sağlayacaktır.)*

PDR must remain operational even when optional ARCore and artificial-intelligence components are unavailable. *(İsteğe bağlı ARCore ve yapay zekâ bileşenleri kullanılamaz olduğunda bile PDR çalışabilir kalmalıdır.)*

---

# 2. PDR Definition (PDR Tanımı)

Pedestrian Dead Reckoning estimates pedestrian displacement from a previously known position using detected steps, estimated step length, and estimated heading. *(Yaya Ölü Hesaplama, önceden bilinen bir konumdan tespit edilen adımları, tahmini adım uzunluğunu ve tahmini yönü kullanarak yaya yer değiştirmesini tahmin eder.)*

The basic NAVGUARD PDR relation can be summarized as follows. *(Temel NAVGUARD PDR ilişkisi aşağıdaki şekilde özetlenebilir.)*

```
Known Position
      +
Detected Step
      +
Step Length
      +
Heading
      ↓
New Estimated Position
```

PDR does not require continuous GNSS after the initial global anchor has been established. *(PDR başlangıç global çapası oluşturulduktan sonra sürekli GNSS gerektirmez.)*

---

# 3. Role of PDR in NAVGUARD (NAVGUARD İçerisinde PDR’nin Rolü)

PDR is the core GNSS-denied fallback navigation mechanism of NAVGUARD. *(PDR, NAVGUARD’ın temel GNSS kesintili geri dönüş navigasyon mekanizmasıdır.)*

PDR also provides the baseline against which ARCore, improved heading, AI-assisted step length, and sensor fusion will be evaluated. *(PDR ayrıca ARCore, geliştirilmiş yön, yapay zekâ destekli adım uzunluğu ve sensör füzyonunun karşılaştırılacağı temel referansı sağlar.)*

A project result remains experimentally useful even if advanced fusion components fail, provided that baseline PDR and quantitative evaluation remain functional. *(Gelişmiş füzyon bileşenleri başarısız olsa bile temel PDR ve nicel değerlendirme çalışır kaldığı sürece proje sonucu deneysel olarak kullanışlı kalır.)*

---

# 4. PDR Is Not Full Inertial Navigation (PDR Tam Ataletsel Navigasyon Değildir)

NAVGUARD PDR will not estimate position by continuously double-integrating raw smartphone acceleration. *(NAVGUARD PDR, ham akıllı telefon ivmesini sürekli çift integre ederek konum tahmin etmeyecektir.)*

Instead, horizontal displacement will primarily be generated from discrete pedestrian step events. *(Bunun yerine yatay yer değiştirme temel olarak ayrık yaya adım olaylarından üretilecektir.)*

This design substantially reduces dependence on long-term integration of noisy consumer-grade acceleration. *(Bu tasarım gürültülü tüketici sınıfı ivmenin uzun süreli integrasyonuna bağımlılığı önemli ölçüde azaltır.)*

---

# 5. Why Raw Acceleration Is Not Double Integrated (Ham İvmenin Neden Çift İntegrasyon Yapılmadığı)

Raw smartphone acceleration contains gravity contribution, sensor bias, measurement noise, device-orientation effects, and timing imperfections. *(Ham akıllı telefon ivmesi yerçekimi katkısı, sensör bias’ı, ölçüm gürültüsü, cihaz yönelim etkileri ve zamanlama kusurları içerir.)*

Small acceleration errors accumulate during integration. *(Küçük ivme hataları integrasyon sırasında birikir.)*

Velocity error produced by the first integration subsequently creates rapidly increasing position error during the second integration. *(İlk integrasyon tarafından üretilen hız hatası daha sonra ikinci integrasyon sırasında hızla büyüyen konum hatası oluşturur.)*

The baseline pedestrian estimator will therefore use step-based displacement rather than unrestricted raw acceleration integration. *(Bu nedenle temel yaya tahmin motoru sınırsız ham ivme integrasyonu yerine adım tabanlı yer değiştirme kullanacaktır.)*

---

# 6. Primary PDR Inputs (Temel PDR Girdileri)

The baseline PDR engine requires an initial local position. *(Temel PDR motoru bir başlangıç yerel konumu gerektirir.)*

The baseline PDR engine requires timestamped accepted step events. *(Temel PDR motoru zaman damgalı kabul edilmiş adım olayları gerektirir.)*

The baseline PDR engine requires an estimated step length for each accepted step. *(Temel PDR motoru kabul edilen her adım için tahmini bir adım uzunluğu gerektirir.)*

The baseline PDR engine requires a heading estimate associated with each accepted step. *(Temel PDR motoru kabul edilen her adımla ilişkili bir yön tahmini gerektirir.)*

---

# 7. Primary PDR Outputs (Temel PDR Çıktıları)

The PDR engine will output local East and North position estimates. *(PDR motoru yerel Doğu ve Kuzey konum tahminleri üretecektir.)*

It will output accumulated travelled distance. *(Birikmiş kat edilen mesafeyi üretecektir.)*

It will output accepted step count. *(Kabul edilen adım sayısını üretecektir.)*

It will output per-step displacement vectors. *(Adım başına yer değiştirme vektörlerini üretecektir.)*

It may additionally output PDR confidence or uncertainty metadata. *(Ayrıca PDR güven veya belirsizlik metadata bilgisi üretebilir.)*

---

# 8. Primary PDR Coordinate Frame (Temel PDR Koordinat Çerçevesi)

PDR will operate in the NAVGUARD local ENU navigation frame defined in **14 — Coordinate Systems & Mathematical Foundations**. *(PDR, **14 — Coordinate Systems & Mathematical Foundations** içerisinde tanımlanan NAVGUARD yerel ENU navigasyon çerçevesinde çalışacaktır.)*

The primary horizontal state will use East and North in metres. *(Temel yatay durum metre cinsinden Doğu ve Kuzey kullanacaktır.)*

```
p_k =
[E_k, N_k]ᵀ
```

PDR will not directly propagate latitude and longitude. *(PDR enlem ve boylamı doğrudan ilerletmeyecektir.)*

---

# 9. Initial PDR Position (Başlangıç PDR Konumu)

After an initial GNSS anchor is accepted, PDR will initialize at the local ENU origin. *(Bir başlangıç GNSS çapası kabul edildikten sonra PDR yerel ENU başlangıç noktasında başlatılacaktır.)*

```
E_0 = 0

N_0 = 0
```

The corresponding WGS84 location is represented by the accepted GNSS anchor. *(Karşılık gelen WGS84 konumu kabul edilen GNSS çapası tarafından temsil edilir.)*

---

# 10. PDR Initialization Requirement (PDR Başlatma Gereksinimi)

A formal GNSS-denied benchmark must not start PDR without a valid navigation anchor. *(Resmî bir GNSS kesintili benchmark geçerli bir navigasyon çapası olmadan PDR’yi başlatmamalıdır.)*

The baseline heading source must also be initialized before the first propagated step. *(Temel yön kaynağı da ilk ilerletilen adımdan önce başlatılmış olmalıdır.)*

The active step-length configuration must be frozen before formal navigation begins. *(Aktif adım uzunluğu yapılandırması resmî navigasyon başlamadan önce sabitlenmiş olmalıdır.)*

---

# 11. PDR Initialization Flow (PDR Başlatma Akışı)

```
GNSS Anchor Accepted
        ↓
Local ENU Origin Created
        ↓
Heading Initialized
        ↓
Step Detector Ready
        ↓
Step-Length Model Ready
        ↓
PDR State Initialized
        ↓
GNSS-Denied Navigation Ready
```

Every formal PDR run must be traceable to the initialization configuration used. *(Her resmî PDR çalışması kullanılan başlatma yapılandırmasına kadar izlenebilir olmalıdır.)*

---

# 12. PDR State Model (PDR Durum Modeli)

The minimum PDR state may be represented as follows. *(Minimum PDR durumu aşağıdaki şekilde temsil edilebilir.)*

```
PdrState
- timestampNs
- eastM
- northM
- acceptedStepCount
- travelledDistanceM
- lastHeadingRad
- lastStepLengthM
```

Additional confidence or quality information may be added without changing the fundamental propagation model. *(Temel ilerletme modeli değiştirilmeden ek güven veya kalite bilgisi eklenebilir.)*

---

# 13. Step Event as the Propagation Trigger (İlerletme Tetikleyicisi Olarak Adım Olayı)

The baseline PDR position will normally advance only when a valid pedestrian step is accepted. *(Temel PDR konumu normalde yalnızca geçerli bir yaya adımı kabul edildiğinde ilerleyecektir.)*

Continuous accelerometer callbacks will not individually generate position increments. *(Sürekli ivmeölçer callback’leri bireysel olarak konum artışı üretmeyecektir.)*

This creates a discrete event-driven position propagation model. *(Bu ayrık olay güdümlü bir konum ilerletme modeli oluşturur.)*

---

# 14. Step Event Model (Adım Olay Modeli)

A logical step event may use the following representation. *(Mantıksal bir adım olayı aşağıdaki temsili kullanabilir.)*

```
StepEvent
- timestampNs
- stepIndex
- confidence
- source
- peakValue
- cadence
```

The exact detector fields will be finalized in **17 — Step Detection System**. *(Kesin algılayıcı alanları **17 — Step Detection System** içerisinde kesinleştirilecektir.)*

---

# 15. Accepted Versus Candidate Step (Kabul Edilmiş ve Aday Adım Ayrımı)

A candidate acceleration peak does not automatically become a navigation step. *(Bir aday ivme peak’i otomatik olarak navigasyon adımı haline gelmez.)*

The step detector will apply temporal, amplitude, and motion-related validation rules before a step is accepted. *(Adım algılayıcı bir adım kabul edilmeden önce zamansal, genlik ve hareketle ilişkili doğrulama kuralları uygulayacaktır.)*

Only accepted steps may update the baseline PDR position. *(Yalnızca kabul edilmiş adımlar temel PDR konumunu güncelleyebilir.)*

---

# 16. Step Timestamp (Adım Zaman Damgası)

Each accepted step will have one authoritative event timestamp. *(Kabul edilen her adım tek bir ana olay zaman damgasına sahip olacaktır.)*

The timestamp will represent the defined physical location of the step event in the processed acceleration signal. *(Zaman damgası işlenmiş ivme sinyalindeki tanımlanmış fiziksel adım olayı konumunu temsil edecektir.)*

Heading and step-length information will be evaluated relative to this timestamp. *(Yön ve adım uzunluğu bilgisi bu zaman damgasına göre değerlendirilecektir.)*

---

# 17. PDR Propagation Equation (PDR İlerletme Denklemi)

For an accepted step with estimated length `L_k` and true-north heading `ψ_k`, local displacement will be calculated as follows. *(Tahmini uzunluğu `L_k` ve gerçek kuzey yönü `ψ_k` olan kabul edilmiş bir adım için yerel yer değiştirme aşağıdaki şekilde hesaplanacaktır.)*

```
ΔE_k = L_k sin(ψ_k)

ΔN_k = L_k cos(ψ_k)
```

The heading convention is clockwise from true north. *(Yön kuralı gerçek kuzeyden saat yönündedir.)*

---

# 18. PDR Position Update (PDR Konum Güncellemesi)

The local PDR position will update as follows. *(Yerel PDR konumu aşağıdaki şekilde güncellenecektir.)*

```
E_k = E_(k-1) + ΔE_k

N_k = N_(k-1) + ΔN_k
```

The update represents one accepted pedestrian step. *(Güncelleme kabul edilmiş tek bir yaya adımını temsil eder.)*

---

# 19. Cardinal-Direction Verification (Ana Yön Doğrulaması)

For a heading of `0°`, an accepted step must increase North while producing approximately zero East displacement. *(`0°` yön için kabul edilmiş bir adım Kuzey’i artırmalı ve yaklaşık sıfır Doğu yer değiştirmesi üretmelidir.)*

```
ψ = 0°

ΔE = 0

ΔN = +L
```

For a heading of `90°`, an accepted step must increase East. *(`90°` yön için kabul edilmiş bir adım Doğu’yu artırmalıdır.)*

```
ψ = 90°

ΔE = +L

ΔN = 0
```

These equations will be unit tested. *(Bu denklemler birim test edilecektir.)*

---

# 20. South and West Verification (Güney ve Batı Doğrulaması)

For a heading of `180°`, North displacement must be negative. *(`180°` yön için Kuzey yer değiştirmesi negatif olmalıdır.)*

```
ψ = 180°

ΔE ≈ 0

ΔN = -L
```

For a heading of `270°`, East displacement must be negative. *(`270°` yön için Doğu yer değiştirmesi negatif olmalıdır.)*

```
ψ = 270°

ΔE = -L

ΔN ≈ 0
```

---

# 21. Step Length Definition (Adım Uzunluğu Tanımı)

Step length `L_k` represents the horizontal distance assigned to one accepted pedestrian step. *(`L_k` adım uzunluğu kabul edilmiş tek bir yaya adımına atanan yatay mesafeyi temsil eder.)*

Step length will be expressed in metres. *(Adım uzunluğu metre cinsinden ifade edilecektir.)*

NAVGUARD will support multiple step-length estimators for controlled comparison. *(NAVGUARD kontrollü karşılaştırma için birden fazla adım uzunluğu tahmin yöntemini destekleyecektir.)*

---

# 22. Step Length Strategy Levels (Adım Uzunluğu Strateji Seviyeleri)

The simplest baseline may use a fixed calibrated step length. *(En basit temel yöntem sabit kalibre edilmiş bir adım uzunluğu kullanabilir.)*

A stronger deterministic baseline may use an acceleration-based heuristic. *(Daha güçlü deterministik temel yöntem ivme tabanlı bir sezgisel yöntem kullanabilir.)*

The target system may use an ML-assisted step-length estimator. *(Hedef sistem ML destekli bir adım uzunluğu tahmin motoru kullanabilir.)*

These approaches must remain independently selectable for experiments. *(Bu yaklaşımlar deneyler için bağımsız olarak seçilebilir kalmalıdır.)*

---

# 23. Fixed Step Length Baseline (Sabit Adım Uzunluğu Temel Yöntemi)

A simple baseline may assign the same calibrated length to every normal walking step. *(Basit bir temel yöntem her normal yürüyüş adımına aynı kalibre edilmiş uzunluğu atayabilir.)*

```
L_k = L_fixed
```

The fixed value must be estimated from controlled walking measurements rather than chosen arbitrarily. *(Sabit değer keyfi olarak seçilmek yerine kontrollü yürüyüş ölçümlerinden tahmin edilmelidir.)*

---

# 24. Fixed Step Length Calibration (Sabit Adım Uzunluğu Kalibrasyonu)

A controlled route with known travelled distance may be used to calculate an initial average step length. *(Bilinen kat edilen mesafeye sahip kontrollü bir rota başlangıç ortalama adım uzunluğunu hesaplamak için kullanılabilir.)*

```
L_avg =
KnownDistance
─────────────
AcceptedStepCount
```

The calibration route must not be reused as final independent evaluation evidence if it was used to fit the parameter. *(Kalibrasyon rotası parametreyi fit etmek için kullanıldıysa nihai bağımsız değerlendirme kanıtı olarak tekrar kullanılmamalıdır.)*

---

# 25. Weinberg-Style Step Length Candidate (Weinberg Tarzı Adım Uzunluğu Adayı)

An acceleration-amplitude heuristic may be evaluated as the deterministic variable-step-length baseline. *(Bir ivme genliği sezgisel yöntemi deterministik değişken adım uzunluğu temeli olarak değerlendirilebilir.)*

A common candidate form is as follows. *(Yaygın bir aday form aşağıdaki gibidir.)*

```
L_k =
K · (a_max - a_min)^(1/4)
```

`K` is a calibration coefficient. *(`K` bir kalibrasyon katsayısıdır.)*

The exact signal definition and coefficient will be determined from NAVGUARD’s collected data. *(Kesin sinyal tanımı ve katsayı NAVGUARD’ın topladığı veriden belirlenecektir.)*

---

# 26. Step Length Coefficient Policy (Adım Uzunluğu Katsayısı Politikası)

No fixed `K` coefficient will be copied from another experiment and treated as universally valid. *(Başka bir deneyden hiçbir sabit `K` katsayısı kopyalanıp evrensel olarak geçerli kabul edilmeyecektir.)*

The coefficient depends on the processed signal, device placement, pedestrian behavior, and calibration procedure. *(Katsayı işlenmiş sinyale, cihaz yerleşimine, yaya davranışına ve kalibrasyon prosedürüne bağlıdır.)*

NAVGUARD will estimate and validate its own coefficient. *(NAVGUARD kendi katsayısını tahmin edecek ve doğrulayacaktır.)*

---

# 27. ML Step Length Role (ML Adım Uzunluğu Rolü)

A machine-learning regression model may later estimate step length from motion features. *(Bir makine öğrenmesi regresyon modeli daha sonra hareket özelliklerinden adım uzunluğunu tahmin edebilir.)*

Candidate features may include cadence, acceleration range, acceleration statistics, peak amplitude, motion class, and other validated features. *(Aday özellikler kadans, ivme aralığı, ivme istatistikleri, peak genliği, hareket sınıfı ve diğer doğrulanmış özellikleri içerebilir.)*

The detailed model belongs to **24 — Step Length Estimation Model**. *(Ayrıntılı model **24 — Step Length Estimation Model** bölümüne aittir.)*

---

# 28. Step Length Fallback Hierarchy (Adım Uzunluğu Geri Dönüş Hiyerarşisi)

```
Validated ML Step Length
          ↓ if unavailable
Deterministic Variable Step Length
          ↓ if unavailable
Calibrated Fixed Step Length
```

The availability of advanced step-length methods must never be required for baseline PDR operation. *(Gelişmiş adım uzunluğu yöntemlerinin kullanılabilirliği temel PDR çalışması için hiçbir zaman zorunlu olmamalıdır.)*

---

# 29. Step Length Validity Bounds (Adım Uzunluğu Geçerlilik Sınırları)

The PDR engine will enforce physically reasonable step-length validity bounds. *(PDR motoru fiziksel olarak makul adım uzunluğu geçerlilik sınırları uygulayacaktır.)*

Exact minimum and maximum values will be selected from collected user-specific and pilot data rather than invented in advance. *(Kesin minimum ve maksimum değerler önceden uydurulmak yerine toplanmış kullanıcıya özgü ve pilot verilerden seçilecektir.)*

Out-of-range predictions will generate quality warnings or fallback behavior. *(Aralık dışı tahminler kalite uyarıları veya geri dönüş davranışı oluşturacaktır.)*

---

# 30. Heading Dependency (Yön Bağımlılığı)

PDR requires an Earth-referenced heading to convert scalar step length into East and North displacement. *(PDR skaler adım uzunluğunu Doğu ve Kuzey yer değiştirmesine dönüştürmek için Dünya referanslı bir yöne ihtiyaç duyar.)*

Heading error directly rotates the direction of every propagated step. *(Yön hatası ilerletilen her adımın yönünü doğrudan döndürür.)*

Heading quality is therefore one of the dominant contributors to long-term PDR drift. *(Bu nedenle yön kalitesi uzun süreli PDR sürüklenmesine katkı sağlayan temel faktörlerden biridir.)*

---

# 31. Baseline Heading Source (Temel Yön Kaynağı)

Configuration A will use the simplest validated baseline heading method available to the project. *(Yapılandırma A proje için mevcut en basit doğrulanmış temel yön yöntemini kullanacaktır.)*

Configuration B will use the improved or fused heading system. *(Yapılandırma B geliştirilmiş veya füzyonlu yön sistemini kullanacaktır.)*

This preserves the ability to measure the benefit of improved heading independently from other advanced components. *(Bu geliştirilmiş yönün faydasını diğer gelişmiş bileşenlerden bağımsız olarak ölçme yeteneğini korur.)*

---

# 32. Heading at Step Time (Adım Anındaki Yön)

The heading used by PDR will correspond as closely as possible to the timestamp of the accepted step. *(PDR tarafından kullanılan yön kabul edilmiş adımın zaman damgasına mümkün olduğunca yakın karşılık gelecektir.)*

If heading estimates are asynchronous, the heading subsystem will provide an appropriately aligned estimate. *(Yön tahminleri asenkron ise yön alt sistemi uygun şekilde hizalanmış bir tahmin sağlayacaktır.)*

The PDR engine will not simply use whichever heading happened to reach the UI most recently. *(PDR motoru yalnızca UI’ya en son ulaşmış olan yönü kullanmayacaktır.)*

---

# 33. Heading Interface (Yön Arayüzü)

A logical PDR heading input may contain the following information. *(Mantıksal bir PDR yön girdisi aşağıdaki bilgileri içerebilir.)*

```
HeadingMeasurement
- timestampNs
- headingRad
- reference
- confidence
- source
```

The heading reference must be true north for direct ENU PDR propagation. *(Doğrudan ENU PDR ilerletmesi için yön referansı gerçek kuzey olmalıdır.)*

---

# 34. Magnetic Heading Handling (Manyetik Yön Yönetimi)

A magnetic-north heading must be converted into true-north heading before direct use in NAVGUARD ENU propagation. *(Manyetik kuzey yönü NAVGUARD ENU ilerletmesinde doğrudan kullanılmadan önce gerçek kuzey yönüne dönüştürülmelidir.)*

The magnetic-declination logic defined in the heading subsystem will perform this conversion. *(Yön alt sisteminde tanımlanan manyetik sapma mantığı bu dönüşümü gerçekleştirecektir.)*

---

# 35. Invalid Heading Behavior (Geçersiz Yön Davranışı)

A step must not blindly propagate using an invalid, stale, or numerically corrupted heading estimate. *(Bir adım geçersiz, eski veya sayısal olarak bozuk bir yön tahmini kullanılarak körlemesine ilerletilmemelidir.)*

Possible responses include using a recent valid heading within a bounded age, reducing confidence, or temporarily refusing displacement propagation. *(Olası yanıtlar sınırlı bir yaş içerisindeki son geçerli yönü kullanmayı, güveni azaltmayı veya yer değiştirme ilerletmesini geçici olarak reddetmeyi içerir.)*

The final fallback rules will be defined after heading tests. *(Nihai geri dönüş kuralları yön testlerinden sonra tanımlanacaktır.)*

---

# 36. Heading Measurement Age (Yön Ölçümü Yaşı)

The age of the heading associated with a step will be measurable. *(Bir adımla ilişkili yönün yaşı ölçülebilir olacaktır.)*

```
headingAge =
stepTimestamp
-
headingTimestamp
```

A maximum acceptable age may be configured depending on heading-update behavior. *(Yön güncelleme davranışına bağlı olarak maksimum kabul edilebilir bir yaş yapılandırılabilir.)*

---

# 37. Straight Walking Behavior (Düz Yürüme Davranışı)

During approximately straight walking with stable heading, consecutive steps should produce displacement vectors with similar direction. *(Kararlı yönle yaklaşık düz yürüyüş sırasında ardışık adımlar benzer yönde yer değiştirme vektörleri üretmelidir.)*

The accumulated trajectory should therefore form an approximately straight local path. *(Bu nedenle birikmiş rota yaklaşık düz bir yerel yol oluşturmalıdır.)*

Deviation will result from step-length and heading errors. *(Sapma adım uzunluğu ve yön hatalarından kaynaklanacaktır.)*

---

# 38. Turning Behavior (Dönüş Davranışı)

Turning does not directly generate an arbitrary position jump. *(Dönüş doğrudan keyfi bir konum sıçraması oluşturmaz.)*

The primary effect of turning is a change in heading used by subsequent step updates. *(Dönüşün temel etkisi sonraki adım güncellemelerinde kullanılan yönün değişmesidir.)*

Steps detected while the user is actively turning will still use the heading corresponding to their own timestamps. *(Kullanıcı aktif olarak dönerken tespit edilen adımlar yine kendi zaman damgalarına karşılık gelen yönü kullanacaktır.)*

---

# 39. Turning Motion Class Interaction (Dönüş Hareket Sınıfı Etkileşimi)

The motion classifier may identify `TURNING` as a motion context. *(Hareket sınıflandırıcı `TURNING` durumunu bir hareket bağlamı olarak tanımlayabilir.)*

This context may cause the heading subsystem to prioritize gyroscope-based short-term rotation handling. *(Bu bağlam yön alt sisteminin jiroskop tabanlı kısa süreli dönüş yönetimine öncelik vermesine neden olabilir.)*

The PDR equations themselves remain unchanged. *(PDR denklemlerinin kendisi değişmeden kalır.)*

---

# 40. Stationary Behavior (Sabit Durum Davranışı)

When the pedestrian is stationary, baseline PDR must not accumulate horizontal displacement. *(Yaya sabitken temel PDR yatay yer değiştirme biriktirmemelidir.)*

The ideal stationary PDR condition is therefore as follows. *(İdeal sabit PDR koşulu aşağıdaki gibidir.)*

```
ΔE = 0

ΔN = 0
```

The PDR position should remain fixed even while sensor noise continues to exist. *(Sensör gürültüsü devam ederken bile PDR konumu sabit kalmalıdır.)*

---

# 41. Stationary Detection Sources (Sabit Durum Tespit Kaynakları)

Stationary behavior may be inferred from the deterministic motion pipeline. *(Sabit durum davranışı deterministik hareket hattından çıkarılabilir.)*

It may additionally be supported by the motion-classification AI. *(Ayrıca hareket sınıflandırma yapay zekâsı tarafından desteklenebilir.)*

Baseline PDR must still have a deterministic path that does not depend exclusively on AI. *(Temel PDR yine de yalnızca yapay zekâya bağımlı olmayan deterministik bir yola sahip olmalıdır.)*

---

# 42. False Steps While Stationary (Sabitken Yanlış Adımlar)

False-positive step detections during stationary periods directly create false PDR displacement. *(Sabit dönemlerde yanlış pozitif adım tespitleri doğrudan yanlış PDR yer değiştirmesi oluşturur.)*

Stationary false-positive rate is therefore an important step-detector metric. *(Bu nedenle sabit durum yanlış pozitif oranı önemli bir adım algılayıcı metriğidir.)*

The baseline detector will be explicitly tested using stationary phone recordings. *(Temel algılayıcı sabit telefon kayıtları kullanılarak açıkça test edilecektir.)*

---

# 43. Walking Behavior (Yürüme Davranışı)

`WALKING` will represent the standard PDR propagation context. *(`WALKING` standart PDR ilerletme bağlamını temsil edecektir.)*

The standard walking step detector and standard step-length configuration will be used. *(Standart yürüyüş adım algılayıcısı ve standart adım uzunluğu yapılandırması kullanılacaktır.)*

---

# 44. Running Behavior (Koşma Davranışı)

Running will remain within the PDR model rather than create a separate navigation system. *(Koşma ayrı bir navigasyon sistemi oluşturmak yerine PDR modeli içerisinde kalacaktır.)*

Running may produce different cadence, acceleration amplitude, and step-length characteristics. *(Koşma farklı kadans, ivme genliği ve adım uzunluğu özellikleri üretebilir.)*

The system may therefore use a running-specific step-length model or parameter set. *(Bu nedenle sistem koşmaya özgü bir adım uzunluğu modeli veya parametre seti kullanabilir.)*

---

# 45. Running Fallback Policy (Koşma Geri Dönüş Politikası)

If the dedicated running model is unavailable, PDR may use a deterministic running fallback rather than terminate navigation. *(Özel koşma modeli kullanılamazsa PDR navigasyonu sonlandırmak yerine deterministik bir koşma geri dönüşü kullanabilir.)*

The fallback must be documented in the session configuration. *(Geri dönüş oturum yapılandırmasında dokümante edilmelidir.)*

---

# 46. Walk-Stop-Walk Behavior (Yürü-Dur-Yürü Davranışı)

NAVGUARD will explicitly test walking followed by a stationary interval followed by renewed walking. *(NAVGUARD açıkça yürüyüş, ardından sabit dönem ve ardından yeniden yürüyüş durumunu test edecektir.)*

PDR position must stop changing during the stationary interval. *(PDR konumu sabit dönem sırasında değişmeyi durdurmalıdır.)*

The next accepted walking step must continue from the previous stored position without resetting the trajectory. *(Sonraki kabul edilen yürüyüş adımı rotayı sıfırlamadan önceki saklanan konumdan devam etmelidir.)*

---

# 47. Step Count State (Adım Sayısı Durumu)

PDR will maintain the number of accepted navigation steps. *(PDR kabul edilmiş navigasyon adımlarının sayısını tutacaktır.)*

```
stepCount_k =
stepCount_(k-1) + 1
```

Rejected candidate steps will not increment the PDR navigation-step counter. *(Reddedilen aday adımlar PDR navigasyon adım sayacını artırmayacaktır.)*

---

# 48. Travelled Distance State (Kat Edilen Mesafe Durumu)

PDR will maintain accumulated estimated travelled distance. *(PDR birikmiş tahmini kat edilen mesafeyi tutacaktır.)*

```
D_k =
D_(k-1) + L_k
```

This value represents estimated path length rather than straight-line displacement from the anchor. *(Bu değer çapadan doğrusal yer değiştirme yerine tahmini yol uzunluğunu temsil eder.)*

---

# 49. Net Displacement (Net Yer Değiştirme)

Net horizontal displacement from the local anchor will be calculated as follows. *(Yerel çapadan net yatay yer değiştirme aşağıdaki şekilde hesaplanacaktır.)*

```
D_net =
√(E_k² + N_k²)
```

Net displacement and travelled distance must remain separate. *(Net yer değiştirme ve kat edilen mesafe ayrı kalmalıdır.)*

---

# 50. PDR Trajectory Representation (PDR Rota Temsili)

Each accepted step may generate one PDR trajectory point. *(Kabul edilen her adım bir PDR rota noktası oluşturabilir.)*

```
PdrTrajectoryPoint
- timestampNs
- eastM
- northM
- stepIndex
- stepLengthM
- headingRad
```

Higher-frequency estimator outputs may later be produced by the fusion layer without changing the discrete baseline PDR representation. *(Daha yüksek frekanslı tahmin motoru çıktıları daha sonra ayrık temel PDR temsilini değiştirmeden füzyon katmanı tarafından üretilebilir.)*

---

# 51. PDR Update Event (PDR Güncelleme Olayı)

Every accepted PDR propagation may generate a structured event. *(Kabul edilen her PDR ilerletmesi yapılandırılmış bir olay üretebilir.)*

```
PDR_STEP_PROPAGATED
```

The event may record the step length, heading, displacement vector, and resulting position. *(Olay adım uzunluğunu, yönü, yer değiştirme vektörünü ve ortaya çıkan konumu kaydedebilir.)*

---

# 52. PDR Data Flow (PDR Veri Akışı)

```
Accelerometer
     │
     ▼
Preprocessing
     │
     ▼
Step Detection
     │
     ▼
Accepted Step ─────────────┐
                           │
Step Length Estimator ─────┤
                           ├──► PDR Propagation
Heading Estimator ─────────┤
                           │
                           ▼
                    [East, North]
```

GNSS is not part of this propagation path during the denied interval. *(GNSS kesintili aralık sırasında bu ilerletme hattının bir parçası değildir.)*

---

# 53. PDR and GNSS Boundary (PDR ve GNSS Sınırı)

GNSS provides the initial geographic anchor before denied navigation begins. *(GNSS kesintili navigasyon başlamadan önce başlangıç coğrafi çapasını sağlar.)*

During the protected GNSS-denied interval, PDR must not request corrections from the ground-truth GNSS stream. *(Korunan GNSS kesintili aralık sırasında PDR gerçek referans GNSS akışından düzeltme istememelidir.)*

The PDR state may only be compared against GNSS externally by the evaluation subsystem. *(PDR durumu yalnızca değerlendirme alt sistemi tarafından harici olarak GNSS ile karşılaştırılabilir.)*

---

# 54. Pure Baseline PDR Configuration (Saf Temel PDR Yapılandırması)

Configuration A will represent the minimum validated PDR navigation stack. *(Yapılandırma A minimum doğrulanmış PDR navigasyon yığınını temsil edecektir.)*

It will include accepted step events. *(Kabul edilmiş adım olaylarını içerecektir.)*

It will include the baseline step-length method. *(Temel adım uzunluğu yöntemini içerecektir.)*

It will include the baseline heading method required for directional propagation. *(Yönsel ilerletme için gerekli temel yön yöntemini içerecektir.)*

It will not use ARCore corrections or AI-dependent navigation corrections. *(ARCore düzeltmelerini veya yapay zekâya bağımlı navigasyon düzeltmelerini kullanmayacaktır.)*

---

# 55. Configuration B Relationship (Yapılandırma B İlişkisi)

Configuration B will preserve the same PDR propagation equations while replacing or improving the heading subsystem. *(Yapılandırma B aynı PDR ilerletme denklemlerini korurken yön alt sistemini değiştirecek veya iyileştirecektir.)*

This comparison isolates the contribution of heading improvement. *(Bu karşılaştırma yön iyileştirmesinin katkısını izole eder.)*

---

# 56. Configuration C Relationship (Yapılandırma C İlişkisi)

Configuration C will retain PDR while introducing ARCore relative-motion information. *(Yapılandırma C ARCore göreli hareket bilgisini dahil ederken PDR’yi koruyacaktır.)*

ARCore will complement rather than eliminate baseline PDR. *(ARCore temel PDR’yi ortadan kaldırmak yerine tamamlayacaktır.)*

If ARCore tracking is lost, PDR remains the fallback navigation source. *(ARCore takibi kaybolursa PDR geri dönüş navigasyon kaynağı olarak kalır.)*

---

# 57. Configuration D Relationship (Yapılandırma D İlişkisi)

Configuration D will combine PDR with the final validated AI, ARCore, heading, confidence, and fusion components. *(Yapılandırma D PDR’yi nihai doğrulanmış yapay zekâ, ARCore, yön, güven ve füzyon bileşenleriyle birleştirecektir.)*

The baseline PDR state will remain separately observable for comparison. *(Temel PDR durumu karşılaştırma için ayrı olarak gözlemlenebilir kalacaktır.)*

---

# 58. AI Must Not Replace Baseline PDR (Yapay Zekâ Temel PDR’nin Yerini Almamalıdır)

Artificial intelligence may modify motion context or estimate step length. *(Yapay zekâ hareket bağlamını değiştirebilir veya adım uzunluğunu tahmin edebilir.)*

Artificial intelligence will not become the only mechanism capable of propagating pedestrian position. *(Yapay zekâ yaya konumunu ilerletebilen tek mekanizma haline gelmeyecektir.)*

A deterministic fallback will remain available. *(Deterministik bir geri dönüş kullanılabilir kalacaktır.)*

---

# 59. ARCore Must Not Replace Baseline PDR (ARCore Temel PDR’nin Yerini Almamalıdır)

ARCore may provide high-value relative displacement information. *(ARCore yüksek değerli göreli yer değiştirme bilgisi sağlayabilir.)*

ARCore tracking can degrade or become unavailable under unfavorable visual conditions. *(ARCore takibi uygun olmayan görsel koşullarda bozulabilir veya kullanılamaz hale gelebilir.)*

PDR must therefore continue without ARCore whenever technically possible. *(Bu nedenle PDR teknik olarak mümkün olduğunda ARCore olmadan devam etmelidir.)*

---

# 60. PDR Drift Definition (PDR Sürüklenme Tanımı)

PDR drift is the accumulated difference between estimated position and reference position as navigation continues without global correction. *(PDR sürüklenmesi global düzeltme olmadan navigasyon devam ederken tahmini konum ile referans konum arasındaki birikmiş farktır.)*

PDR drift is expected to grow over time and distance because step-length and heading errors accumulate. *(Adım uzunluğu ve yön hataları biriktiği için PDR sürüklenmesinin zaman ve mesafeyle büyümesi beklenir.)*

NAVGUARD does not assume that PDR can maintain indefinitely accurate position. *(NAVGUARD PDR’nin süresiz olarak doğru konum koruyabileceğini varsaymaz.)*

---

# 61. Primary PDR Drift Sources (Temel PDR Sürüklenme Kaynakları)

Primary drift sources include missed steps. *(Temel sürüklenme kaynakları kaçırılan adımları içerir.)*

Primary drift sources include false-positive steps. *(Temel sürüklenme kaynakları yanlış pozitif adımları içerir.)*

Primary drift sources include step-length estimation error. *(Temel sürüklenme kaynakları adım uzunluğu tahmin hatasını içerir.)*

Primary drift sources include heading error. *(Temel sürüklenme kaynakları yön hatasını içerir.)*

Primary drift sources include device-placement changes. *(Temel sürüklenme kaynakları cihaz yerleşimi değişikliklerini içerir.)*

Primary drift sources include sensor noise and magnetic disturbance indirectly affecting the supporting algorithms. *(Temel sürüklenme kaynakları destekleyici algoritmaları dolaylı olarak etkileyen sensör gürültüsünü ve manyetik bozulmayı içerir.)*

---

# 62. Missed-Step Error (Kaçırılan Adım Hatası)

If a real step is not detected, PDR fails to add the corresponding displacement. *(Gerçek bir adım tespit edilmezse PDR ilgili yer değiştirmeyi ekleyemez.)*

Repeated missed steps lead to systematic underestimation of travelled distance. *(Tekrarlanan kaçırılmış adımlar kat edilen mesafenin sistematik olarak düşük tahmin edilmesine yol açar.)*

---

# 63. False-Step Error (Yanlış Adım Hatası)

If a non-step motion is incorrectly accepted as a step, PDR creates displacement that never physically occurred. *(Adım olmayan bir hareket yanlış şekilde adım olarak kabul edilirse PDR fiziksel olarak hiç gerçekleşmemiş bir yer değiştirme oluşturur.)*

False steps during stationary periods are particularly damaging because all resulting displacement is artificial. *(Sabit dönemlerde yanlış adımlar özellikle zararlıdır çünkü ortaya çıkan tüm yer değiştirme yapaydır.)*

---

# 64. Step-Length Error (Adım Uzunluğu Hatası)

For one step, step-length error may be represented as follows. *(Tek bir adım için adım uzunluğu hatası aşağıdaki şekilde temsil edilebilir.)*

```
e_L =
L_est - L_ref
```

Repeated bias in `L_est` causes systematic distance drift. *(`L_est` içerisindeki tekrarlanan bias sistematik mesafe sürüklenmesine neden olur.)*

---

# 65. Heading Error Effect (Yön Hatası Etkisi)

A heading error rotates the displacement vector away from the actual travel direction. *(Bir yön hatası yer değiştirme vektörünü gerçek hareket yönünden uzaklaştırır.)*

Even when step length is perfectly estimated, persistent heading bias can produce large cross-track position error. *(Adım uzunluğu mükemmel tahmin edilse bile kalıcı yön bias’ı büyük yanal konum hatası üretebilir.)*

---

# 66. Combined Error Accumulation (Birleşik Hata Birikimi)

PDR position error generally results from the interaction of step-detection, step-length, and heading errors. *(PDR konum hatası genel olarak adım tespiti, adım uzunluğu ve yön hatalarının etkileşiminden kaynaklanır.)*

The final system must therefore evaluate these components separately in addition to reporting overall position error. *(Bu nedenle nihai sistem toplam konum hatasını raporlamaya ek olarak bu bileşenleri ayrı ayrı değerlendirmelidir.)*

---

# 67. No Hidden Re-Centering (Gizli Yeniden Merkezleme Olmaması)

The baseline PDR trajectory must not be periodically re-centered using ground-truth GNSS during the denied evaluation interval. *(Temel PDR rotası kesintili değerlendirme aralığında gerçek referans GNSS kullanılarak periyodik olarak yeniden merkezlenmemelidir.)*

Such correction would invalidate the measurement of natural accumulated PDR drift. *(Böyle bir düzeltme doğal birikmiş PDR sürüklenmesinin ölçümünü geçersiz kılar.)*

---

# 68. PDR Uncertainty Growth (PDR Belirsizlik Büyümesi)

PDR uncertainty should generally increase as more uncorrected steps are propagated. *(Daha fazla düzeltilmemiş adım ilerletildikçe PDR belirsizliği genel olarak artmalıdır.)*

Uncertainty may grow with elapsed GNSS-denied time. *(Belirsizlik geçen GNSS kesintili süreyle büyüyebilir.)*

Uncertainty may grow with travelled distance. *(Belirsizlik kat edilen mesafeyle büyüyebilir.)*

Uncertainty may additionally respond to heading and step-quality information. *(Belirsizlik ayrıca yön ve adım kalite bilgisine yanıt verebilir.)*

---

# 69. PDR Confidence Inputs (PDR Güven Girdileri)

Candidate confidence inputs include step-detection confidence. *(Aday güven girdileri adım tespit güvenini içerir.)*

Candidate confidence inputs include heading confidence. *(Aday güven girdileri yön güvenini içerir.)*

Candidate confidence inputs include step-length model confidence or validity. *(Aday güven girdileri adım uzunluğu modeli güvenini veya geçerliliğini içerir.)*

Candidate confidence inputs include time since the last global anchor or relocalization. *(Aday güven girdileri son global çapa veya yeniden konumlandırmadan itibaren geçen süreyi içerir.)*

---

# 70. No Unvalidated Confidence Claim (Doğrulanmamış Güven İddiası Olmaması)

A PDR confidence score must not be presented as a calibrated probability unless experiments support that interpretation. *(Bir PDR güven skoru deneyler bu yorumu desteklemediği sürece kalibre edilmiş olasılık olarak sunulmamalıdır.)*

Early versions may use qualitative states such as `HIGH`, `MODERATE`, and `LOW`. *(İlk sürümler `HIGH`, `MODERATE` ve `LOW` gibi niteliksel durumları kullanabilir.)*

The thresholds must eventually be supported by observed positioning performance. *(Eşikler sonunda gözlemlenen konumlandırma performansıyla desteklenmelidir.)*

---

# 71. PDR Health State (PDR Sağlık Durumu)

The PDR engine may expose the following runtime health states. *(PDR motoru aşağıdaki çalışma zamanı sağlık durumlarını sunabilir.)*

```
STARTING
READY
ACTIVE
DEGRADED
PAUSED
ERROR
```

`PAUSED` may represent a legitimate stationary period rather than a failure. *(`PAUSED` bir hata yerine geçerli sabit dönemi temsil edebilir.)*

---

# 72. PDR Degraded State (PDR Bozulmuş Durumu)

PDR may enter a degraded state when heading becomes unreliable. *(Yön güvenilmez hale geldiğinde PDR bozulmuş duruma girebilir.)*

PDR may enter a degraded state when step detection quality deteriorates. *(Adım tespit kalitesi bozulduğunda PDR bozulmuş duruma girebilir.)*

PDR may enter a degraded state when only fallback step-length estimation remains available. *(Yalnızca geri dönüş adım uzunluğu tahmini kullanılabilir kaldığında PDR bozulmuş duruma girebilir.)*

---

# 73. PDR Critical Failure (PDR Kritik Hatası)

Loss of the accelerometer may prevent baseline step detection. *(İvmeölçer kaybı temel adım tespitini engelleyebilir.)*

Loss of every usable heading source may prevent reliable directional propagation. *(Kullanılabilir tüm yön kaynaklarının kaybı güvenilir yönsel ilerletmeyi engelleyebilir.)*

Such failures may invalidate a Configuration A benchmark. *(Böyle hatalar Yapılandırma A benchmark’ını geçersiz kılabilir.)*

---

# 74. PDR Reset Policy (PDR Sıfırlama Politikası)

PDR state will not reset merely because GNSS denial begins. *(PDR durumu yalnızca GNSS kesintisi başladığı için sıfırlanmayacaktır.)*

The system may initialize PDR before the denial boundary so that filter and heading states are already stable. *(Sistem filtre ve yön durumlarının zaten kararlı olması için PDR’yi kesinti sınırından önce başlatabilir.)*

A true reset will occur only through controlled session initialization or relocalization logic. *(Gerçek bir sıfırlama yalnızca kontrollü oturum başlatma veya yeniden konumlandırma mantığı üzerinden gerçekleşecektir.)*

---

# 75. Recovery and PDR (Geri Kazanım ve PDR)

When GNSS recovery is accepted, the final pre-correction PDR position must first be preserved. *(GNSS geri kazanımı kabul edildiğinde son düzeltme öncesi PDR konumu önce korunmalıdır.)*

The position will then be compared with recovered GNSS ground truth. *(Konum daha sonra geri kazanılmış GNSS gerçek referansıyla karşılaştırılacaktır.)*

Only after the error is recorded may the active navigation state be re-anchored or corrected. *(Yalnızca hata kaydedildikten sonra aktif navigasyon durumu yeniden çapalanabilir veya düzeltilebilir.)*

---

# 76. Historical PDR Trajectory (Geçmiş PDR Rotası)

Historical PDR trajectory points are experiment evidence. *(Geçmiş PDR rota noktaları deneysel kanıttır.)*

They must not be retrospectively shifted after GNSS recovery. *(GNSS geri kazanımından sonra geriye dönük olarak kaydırılmamalıdır.)*

The recovered position may create a new navigation anchor for future estimates without rewriting the past trajectory. *(Geri kazanılmış konum geçmiş rotayı yeniden yazmadan gelecekteki tahminler için yeni bir navigasyon çapası oluşturabilir.)*

---

# 77. PDR Logging Requirements (PDR Kayıt Gereksinimleri)

The PDR system will record every accepted step used for position propagation. *(PDR sistemi konum ilerletmesi için kullanılan her kabul edilmiş adımı kaydedecektir.)*

It will record the step length used. *(Kullanılan adım uzunluğunu kaydedecektir.)*

It will record the heading used. *(Kullanılan yönü kaydedecektir.)*

It will record the resulting East and North displacement. *(Ortaya çıkan Doğu ve Kuzey yer değiştirmesini kaydedecektir.)*

It will record the cumulative position. *(Birikimli konumu kaydedecektir.)*

---

# 78. Proposed PDR Log Schema (Önerilen PDR Kayıt Şeması)

```
timestamp_ns,
step_index,
step_length_m,
heading_rad,
delta_east_m,
delta_north_m,
east_m,
north_m,
travelled_distance_m,
step_source,
step_length_source,
heading_source,
pdr_quality
```

The schema may be expanded with model-version or confidence fields. *(Şema model sürümü veya güven alanlarıyla genişletilebilir.)*

---

# 79. PDR Provenance (PDR Kaynak İzlenebilirliği)

Each PDR update should identify which step detector produced the event. *(Her PDR güncellemesi olayı hangi adım algılayıcının ürettiğini tanımlamalıdır.)*

Each PDR update should identify which step-length method was used. *(Her PDR güncellemesi hangi adım uzunluğu yönteminin kullanıldığını tanımlamalıdır.)*

Each PDR update should identify which heading method supplied direction. *(Her PDR güncellemesi hangi yön yönteminin yön bilgisi sağladığını tanımlamalıdır.)*

This makes configuration comparisons reproducible. *(Bu yapılandırma karşılaştırmalarını tekrarlanabilir hale getirir.)*

---

# 80. Baseline PDR Replay (Temel PDR Replay)

Recorded raw sensor data must be sufficient to reproduce baseline PDR offline. *(Kaydedilmiş ham sensör verisi temel PDR’yi çevrimdışı olarak yeniden üretmek için yeterli olmalıdır.)*

The same preprocessing, step-detection, step-length, and heading configuration should reproduce equivalent PDR updates. *(Aynı ön işleme, adım tespiti, adım uzunluğu ve yön yapılandırması eşdeğer PDR güncellemeleri üretmelidir.)*

---

# 81. Deterministic Baseline Requirement (Deterministik Temel Gereksinimi)

Configuration A should be deterministic for identical recorded input and identical frozen parameters. *(Yapılandırma A aynı kaydedilmiş girdi ve aynı sabitlenmiş parametreler için deterministik olmalıdır.)*

This provides a stable benchmark against which more advanced approaches can be compared. *(Bu daha gelişmiş yaklaşımların karşılaştırılabileceği kararlı bir benchmark sağlar.)*

---

# 82. PDR and Dataset Separation (PDR ve Veri Seti Ayrımı)

Parameters calibrated from one set of routes must not be evaluated only on those same routes and then presented as general performance. *(Bir rota setinden kalibre edilen parametreler yalnızca aynı rotalar üzerinde değerlendirilip daha sonra genel performans olarak sunulmamalıdır.)*

Calibration, validation, and final evaluation routes will remain appropriately separated. *(Kalibrasyon, doğrulama ve nihai değerlendirme rotaları uygun şekilde ayrı kalacaktır.)*

---

# 83. User-Specific Calibration Policy (Kullanıcıya Özgü Kalibrasyon Politikası)

Because the project is a controlled single-device research prototype, user-specific step-length calibration may be permitted. *(Proje kontrollü tek cihazlı bir araştırma prototipi olduğu için kullanıcıya özgü adım uzunluğu kalibrasyonuna izin verilebilir.)*

If used, this limitation must be documented explicitly. *(Kullanılırsa bu sınırlama açıkça dokümante edilmelidir.)*

The resulting model must not be claimed to generalize automatically to all pedestrians. *(Ortaya çıkan modelin otomatik olarak tüm yayalara genellendiği iddia edilmemelidir.)*

---

# 84. Phone Placement Dependency (Telefon Yerleşimi Bağımlılığı)

PDR performance depends partly on how the phone is carried. *(PDR performansı kısmen telefonun nasıl taşındığına bağlıdır.)*

The minimum project will use a controlled placement protocol during formal benchmark routes. *(Minimum proje resmî benchmark rotaları sırasında kontrollü bir yerleşim protokolü kullanacaktır.)*

Supporting arbitrary hand, pocket, bag, and body placements simultaneously is outside the minimum scope. *(Keyfi el, cep, çanta ve vücut yerleşimlerini aynı anda desteklemek minimum kapsamın dışındadır.)*

---

# 85. Placement Change During a Session (Oturum Sırasında Yerleşim Değişikliği)

The phone-placement protocol should remain unchanged during one formal benchmark unless the experiment explicitly tests placement changes. *(Deney açıkça yerleşim değişikliklerini test etmediği sürece telefon yerleşim protokolü tek bir resmî benchmark sırasında değişmeden kalmalıdır.)*

An unrecorded placement change may alter step and heading behavior and reduce experiment validity. *(Kaydedilmemiş bir yerleşim değişikliği adım ve yön davranışını değiştirebilir ve deney geçerliliğini azaltabilir.)*

---

# 86. Baseline PDR Experimental Routes (Temel PDR Deney Rotaları)

Baseline PDR will be tested on a straight route. *(Temel PDR düz bir rotada test edilecektir.)*

Baseline PDR will be tested on a square or closed-loop route. *(Temel PDR kare veya kapalı döngü rotasında test edilecektir.)*

Baseline PDR will be tested on a turn-heavy route. *(Temel PDR dönüş yoğun bir rotada test edilecektir.)*

Baseline PDR will be tested on walk-stop-walk behavior. *(Temel PDR yürü-dur-yürü davranışında test edilecektir.)*

Longer-duration routes will evaluate drift accumulation. *(Daha uzun süreli rotalar sürüklenme birikimini değerlendirecektir.)*

---

# 87. Straight-Route Metrics (Düz Rota Metrikleri)

Straight-route testing may measure final position error. *(Düz rota testi nihai konum hatasını ölçebilir.)*

It may measure lateral cross-track drift. *(Yanal rota dışı sürüklenmeyi ölçebilir.)*

It may measure estimated travelled-distance error. *(Tahmini kat edilen mesafe hatasını ölçebilir.)*

It may measure heading error where suitable reference information exists. *(Uygun referans bilgisi mevcut olduğunda yön hatasını ölçebilir.)*

---

# 88. Closed-Loop Metrics (Kapalı Döngü Metrikleri)

A route returning approximately to its start can evaluate closure error. *(Yaklaşık başlangıç noktasına dönen bir rota kapanış hatasını değerlendirebilir.)*

```
ClosureError =
√(E_final² + N_final²)
```

Closure error provides a useful summary of accumulated PDR drift on loop routes. *(Kapanış hatası döngü rotalarında birikmiş PDR sürüklenmesinin kullanışlı bir özetini sağlar.)*

---

# 89. Travelled Distance Error (Kat Edilen Mesafe Hatası)

When a reliable route distance is known, travelled-distance error may be calculated as follows. *(Güvenilir rota mesafesi bilindiğinde kat edilen mesafe hatası aşağıdaki şekilde hesaplanabilir.)*

```
DistanceError =
D_estimated - D_reference
```

Absolute distance error may additionally be reported. *(Mutlak mesafe hatası ayrıca raporlanabilir.)*

---

# 90. Step Count Error (Adım Sayısı Hatası)

When manually verified reference step counts are available, step-count error may be calculated as follows. *(Manuel olarak doğrulanmış referans adım sayıları mevcut olduğunda adım sayısı hatası aşağıdaki şekilde hesaplanabilir.)*

```
StepCountError =
N_detected - N_reference
```

A percentage error may also be reported when the reference count is nonzero. *(Referans sayısı sıfırdan farklı olduğunda yüzde hata da raporlanabilir.)*

---

# 91. Step Detection Error Propagation (Adım Tespit Hatasının İlerlemesi)

Step-count accuracy alone is not sufficient to characterize PDR performance. *(Adım sayısı doğruluğu tek başına PDR performansını karakterize etmek için yeterli değildir.)*

Two detectors may produce the same final count while detecting different individual steps at incorrect times. *(İki algılayıcı aynı nihai sayıyı üretirken farklı bireysel adımları yanlış zamanlarda tespit edebilir.)*

Event-level precision, recall, and timing quality will therefore also be considered in **17 — Step Detection System**. *(Bu nedenle olay seviyesinde precision, recall ve zamanlama kalitesi de **17 — Step Detection System** içerisinde değerlendirilecektir.)*

---

# 92. Step Length Evaluation (Adım Uzunluğu Değerlendirmesi)

Step-length models will be compared using direct regression error where suitable ground truth can be constructed. *(Adım uzunluğu modelleri uygun gerçek referans oluşturulabildiğinde doğrudan regresyon hatası kullanılarak karşılaştırılacaktır.)*

Route-level distance error will also be important because per-step labels may be difficult to obtain precisely. *(Adım başına etiketlerin hassas şekilde elde edilmesi zor olabileceği için rota seviyesinde mesafe hatası da önemli olacaktır.)*

---

# 93. Position Evaluation (Konum Değerlendirmesi)

Baseline PDR will be compared against independent GNSS ground truth in controlled outdoor evaluation sessions. *(Temel PDR kontrollü dış mekân değerlendirme oturumlarında bağımsız GNSS gerçek referansıyla karşılaştırılacaktır.)*

Both trajectories will be transformed into the same anchor-based ENU coordinate system before horizontal error is calculated. *(Yatay hata hesaplanmadan önce her iki rota aynı çapa tabanlı ENU koordinat sistemine dönüştürülecektir.)*

---

# 94. Primary PDR Position Metrics (Temel PDR Konum Metrikleri)

Primary metrics will include mean position error. *(Temel metrikler ortalama konum hatasını içerecektir.)*

Primary metrics will include RMSE. *(Temel metrikler RMSE’yi içerecektir.)*

Primary metrics will include final position error. *(Temel metrikler nihai konum hatasını içerecektir.)*

Primary metrics will include drift per minute. *(Temel metrikler dakika başına sürüklenmeyi içerecektir.)*

Primary metrics will include drift relative to travelled distance. *(Temel metrikler kat edilen mesafeye göre sürüklenmeyi içerecektir.)*

---

# 95. PDR Drift Rate (PDR Sürüklenme Hızı)

A time-normalized drift metric may be calculated as follows. *(Zamana normalize edilmiş bir sürüklenme metriği aşağıdaki şekilde hesaplanabilir.)*

```
DriftRate =
FinalPositionError
──────────────────
DeniedDuration
```

The preferred presentation unit may be metres per minute. *(Tercih edilen sunum birimi metre/dakika olabilir.)*

---

# 96. Distance-Normalized Drift (Mesafeye Normalize Sürüklenme)

A distance-normalized drift metric may be calculated as follows. *(Mesafeye normalize edilmiş sürüklenme metriği aşağıdaki şekilde hesaplanabilir.)*

```
DriftPercent =
FinalPositionError
────────────────── × 100
TravelledDistance
```

This metric must not be evaluated when travelled distance is approximately zero. *(Kat edilen mesafe yaklaşık sıfır olduğunda bu metrik değerlendirilmemelidir.)*

---

# 97. Baseline Versus Improved PDR (Temel ve Geliştirilmiş PDR Karşılaştırması)

The same physical route should be processed using multiple frozen configurations whenever possible. *(Mümkün olduğunda aynı fiziksel rota birden fazla sabitlenmiş yapılandırma kullanılarak işlenmelidir.)*

This reduces route-to-route environmental variation in component comparisons. *(Bu bileşen karşılaştırmalarında rotadan rotaya çevresel değişkenliği azaltır.)*

---

# 98. Candidate PDR Comparison Matrix (Aday PDR Karşılaştırma Matrisi)

| Configuration (Yapılandırma) | Step Detection (Adım Tespiti) | Step Length (Adım Uzunluğu) | Heading (Yön) | ARCore | AI |
| --- | --- | --- | --- | --- | --- |
| A — Baseline PDR *(Temel PDR)* | Baseline *(Temel)* | Baseline *(Temel)* | Baseline *(Temel)* | No *(Hayır)* | No correction *(Düzeltme yok)* |
| B — Improved Heading *(Geliştirilmiş Yön)* | Same *(Aynı)* | Same *(Aynı)* | Improved *(Geliştirilmiş)* | No *(Hayır)* | No correction *(Düzeltme yok)* |
| C — PDR + ARCore | Same *(Aynı)* | Same *(Aynı)* | Improved *(Geliştirilmiş)* | Yes *(Evet)* | Optional context *(İsteğe bağlı bağlam)* |
| D — NAVGUARD Fusion | Final *(Nihai)* | Final / ML *(Nihai / ML)* | Final *(Nihai)* | Yes *(Evet)* | Yes *(Evet)* |

The final experiment matrix will be frozen before field benchmarks. *(Nihai deney matrisi saha benchmark’larından önce sabitlenecektir.)*

---

# 99. Fair Comparison Rule (Adil Karşılaştırma Kuralı)

Only the component under investigation should change when a controlled ablation comparison is intended. *(Kontrollü ablation karşılaştırması amaçlandığında yalnızca araştırılan bileşen değişmelidir.)*

For example, a heading comparison should not simultaneously change the step detector and step-length model. *(Örneğin bir yön karşılaştırması aynı anda adım algılayıcıyı ve adım uzunluğu modelini değiştirmemelidir.)*

---

# 100. PDR Replay Experimentation (PDR Replay Deneyleri)

Offline replay will allow many PDR configurations to be evaluated on the same recorded route. *(Çevrimdışı replay birçok PDR yapılandırmasının aynı kaydedilmiş rota üzerinde değerlendirilmesine izin verecektir.)*

This reduces the need to physically repeat every algorithm experiment. *(Bu her algoritma deneyi için fiziksel rotayı tekrar etme ihtiyacını azaltır.)*

Final claims will nevertheless be verified through live or held-out field sessions. *(Bununla birlikte nihai iddialar canlı veya ayrılmış saha oturumları üzerinden doğrulanacaktır.)*

---

# 101. PDR Processing Frequency (PDR İşleme Frekansı)

Raw acceleration may be processed at approximately the sensor acquisition rate. *(Ham ivme yaklaşık sensör veri toplama hızında işlenebilir.)*

PDR position propagation itself is event-driven and therefore occurs at accepted step frequency rather than IMU frequency. *(PDR konum ilerletmesinin kendisi olay güdümlüdür ve bu nedenle IMU frekansı yerine kabul edilmiş adım frekansında gerçekleşir.)*

---

# 102. Map Update Frequency (Harita Güncelleme Frekansı)

The map does not need to rebuild at every raw IMU sample. *(Haritanın her ham IMU örneğinde yeniden çizilmesi gerekmez.)*

Baseline PDR route visualization may update after accepted steps or at a separately throttled UI rate. *(Temel PDR rota görselleştirmesi kabul edilmiş adımlardan sonra veya ayrı olarak sınırlandırılmış UI hızında güncellenebilir.)*

This presentation decision must not change estimator calculations. *(Bu sunum kararı tahmin motoru hesaplamalarını değiştirmemelidir.)*

---

# 103. Geographic PDR Output (Coğrafi PDR Çıktısı)

The authoritative PDR state will remain in ENU metres. *(Ana PDR durumu ENU metre cinsinde kalacaktır.)*

When a geographic display point is required, ENU will be converted through the active anchor to WGS84 latitude and longitude. *(Coğrafi gösterim noktası gerektiğinde ENU aktif çapa üzerinden WGS84 enlem ve boylamına dönüştürülecektir.)*

```
PDR ENU
   ↓
ECEF
   ↓
WGS84
   ↓
Map
```

---

# 104. No Map-Based Correction (Harita Tabanlı Düzeltme Olmaması)

The initial PDR baseline will not use road snapping or map matching to hide drift. *(İlk PDR temel sistemi sürüklenmeyi gizlemek için yol snapping veya map matching kullanmayacaktır.)*

The estimated path will represent the actual output of the navigation algorithm. *(Tahmini rota navigasyon algoritmasının gerçek çıktısını temsil edecektir.)*

Map matching may be investigated in future work but is outside the baseline experiment. *(Map matching gelecek çalışmalarda araştırılabilir ancak temel deneyin dışındadır.)*

---

# 105. No Route Constraint Leakage (Rota Kısıtı Sızıntısı Olmaması)

A known experimental route must not be used by the PDR estimator as a hidden trajectory constraint during evaluation. *(Bilinen deney rotası değerlendirme sırasında PDR tahmin motoru tarafından gizli rota kısıtı olarak kullanılmamalıdır.)*

Route geometry may be used for evaluation after the estimate has been generated. *(Rota geometrisi tahmin üretildikten sonra değerlendirme için kullanılabilir.)*

---

# 106. Real-Time PDR Requirement (Gerçek Zamanlı PDR Gereksinimi)

The PDR engine must operate online using only measurements available up to the current step. *(PDR motoru yalnızca mevcut adıma kadar kullanılabilir ölçümleri kullanarak çevrimiçi çalışmalıdır.)*

Future GNSS or future sensor measurements must not be used to improve an already produced real-time position estimate. *(Gelecekteki GNSS veya sensör ölçümleri daha önce üretilmiş gerçek zamanlı konum tahminini iyileştirmek için kullanılmamalıdır.)*

Offline smoothing, if later investigated, must be reported separately from real-time PDR. *(Daha sonra araştırılırsa çevrimdışı smoothing gerçek zamanlı PDR’den ayrı raporlanmalıdır.)*

---

# 107. Latency Requirement (Gecikme Gereksinimi)

An accepted step should produce its PDR update with low enough latency to appear responsive during walking. *(Kabul edilmiş bir adım yürüyüş sırasında duyarlı görünecek kadar düşük gecikmeyle PDR güncellemesini üretmelidir.)*

The exact acceptable latency threshold will be determined through device testing. *(Kesin kabul edilebilir gecikme eşiği cihaz testiyle belirlenecektir.)*

---

# 108. Step Detection Latency (Adım Tespit Gecikmesi)

Some step detectors may require observing a small number of samples after a candidate peak before confirming the step. *(Bazı adım algılayıcılar aday peak’ten sonra adımı doğrulamadan önce az sayıda örneği gözlemlemeyi gerektirebilir.)*

This confirmation latency must remain bounded and measured. *(Bu doğrulama gecikmesi sınırlı ve ölçülmüş kalmalıdır.)*

---

# 109. AI Latency Must Not Block Baseline PDR (Yapay Zekâ Gecikmesi Temel PDR’yi Engellememelidir)

If motion AI or ML step-length inference is temporarily delayed, baseline PDR must have a fallback path. *(Hareket yapay zekâsı veya ML adım uzunluğu çıkarımı geçici olarak gecikirse temel PDR bir geri dönüş yoluna sahip olmalıdır.)*

The application must not stop all position propagation solely because an optional model missed a timing deadline. *(Uygulama yalnızca isteğe bağlı bir model zamanlama sınırını kaçırdığı için tüm konum ilerletmeyi durdurmamalıdır.)*

---

# 110. PDR Threading Principle (PDR Threading İlkesi)

PDR calculations will not execute heavy UI work in the same critical path as sensor processing. *(PDR hesaplamaları sensör işleme ile aynı kritik hatta ağır UI işi yürütmeyecektir.)*

The resulting position state will be published to the presentation layer after navigation computation completes. *(Ortaya çıkan konum durumu navigasyon hesaplaması tamamlandıktan sonra sunum katmanına yayınlanacaktır.)*

---

# 111. PDR Failure Codes (PDR Hata Kodları)

```
PDR_NOT_INITIALIZED
PDR_NO_ANCHOR
PDR_STEP_STREAM_LOST
PDR_HEADING_UNAVAILABLE
PDR_INVALID_HEADING
PDR_INVALID_STEP_LENGTH
PDR_NON_MONOTONIC_STEP_TIME
PDR_NUMERICAL_ERROR
PDR_CONFIGURATION_MISMATCH
```

Structured failure codes will support replay and diagnosis. *(Yapılandırılmış hata kodları replay ve tanıyı destekleyecektir.)*

---

# 112. Non-Monotonic Step Protection (Monotonik Olmayan Adım Koruması)

Accepted PDR steps must have monotonically increasing event timestamps. *(Kabul edilmiş PDR adımları monotonik olarak artan olay zaman damgalarına sahip olmalıdır.)*

An out-of-order step must not silently modify an already propagated current state. *(Sıra dışı bir adım daha önce ilerletilmiş mevcut durumu sessizce değiştirmemelidir.)*

The event will be rejected or handled through explicitly designed replay logic. *(Olay reddedilecek veya açıkça tasarlanmış replay mantığı üzerinden yönetilecektir.)*

---

# 113. Duplicate Step Protection (Yinelenen Adım Koruması)

The same accepted step event must not update PDR twice. *(Aynı kabul edilmiş adım olayı PDR’yi iki kez güncellememelidir.)*

Unique step identifiers or deterministic event sequencing will be used to protect against duplicate propagation. *(Yinelenen ilerletmeye karşı koruma sağlamak için benzersiz adım tanımlayıcıları veya deterministik olay sıralaması kullanılacaktır.)*

---

# 114. Numerical Validation (Sayısal Doğrulama)

Before each propagation, step length must be finite and valid. *(Her ilerletmeden önce adım uzunluğu sonlu ve geçerli olmalıdır.)*

Heading must be finite and normalized. *(Yön sonlu ve normalize edilmiş olmalıdır.)*

The resulting East and North values must remain finite. *(Ortaya çıkan Doğu ve Kuzey değerleri sonlu kalmalıdır.)*

A NaN or infinite value must never silently enter the stored trajectory. *(Bir NaN veya sonsuz değer saklanan rotaya hiçbir zaman sessizce girmemelidir.)*

---

# 115. PDR Unit Tests (PDR Birim Testleri)

The PDR engine will test northward propagation. *(PDR motoru kuzeye ilerlemeyi test edecektir.)*

The PDR engine will test eastward propagation. *(PDR motoru doğuya ilerlemeyi test edecektir.)*

The PDR engine will test southward propagation. *(PDR motoru güneye ilerlemeyi test edecektir.)*

The PDR engine will test westward propagation. *(PDR motoru batıya ilerlemeyi test edecektir.)*

The PDR engine will test arbitrary-angle propagation. *(PDR motoru keyfi açılı ilerlemeyi test edecektir.)*

---

# 116. Stationary Unit Test (Sabit Durum Birim Testi)

A sequence containing no accepted step events must produce no PDR displacement. *(Hiç kabul edilmiş adım olayı içermeyen bir dizi hiçbir PDR yer değiştirmesi üretmemelidir.)*

```
stepCount = 0
⇒
E_final = E_initial
N_final = N_initial
```

---

# 117. Known Step Sequence Test (Bilinen Adım Dizisi Testi)

A synthetic sequence of equal step lengths and known headings will be used to verify accumulated position. *(Eşit adım uzunlukları ve bilinen yönlerden oluşan sentetik bir dizi birikmiş konumu doğrulamak için kullanılacaktır.)*

A four-step square test should approximately return to its starting point under ideal mathematics. *(Dört adımlı bir kare testi ideal matematik altında yaklaşık başlangıç noktasına dönmelidir.)*

---

# 118. Square Mathematical Test (Kare Matematik Testi)

For four identical steps with headings `0°`, `90°`, `180°`, and `270°`, ideal final displacement should be zero. *(`0°`, `90°`, `180°` ve `270°` yönlerine sahip dört aynı adım için ideal nihai yer değiştirme sıfır olmalıdır.)*

```
ΣΔE = 0

ΣΔN = 0
```

This test verifies the PDR heading convention and displacement equations. *(Bu test PDR yön kuralını ve yer değiştirme denklemlerini doğrular.)*

---

# 119. Step Length Validation Tests (Adım Uzunluğu Doğrulama Testleri)

Fixed step-length propagation will be tested independently. *(Sabit adım uzunluğu ilerletmesi bağımsız olarak test edilecektir.)*

Variable deterministic step-length propagation will be tested independently. *(Değişken deterministik adım uzunluğu ilerletmesi bağımsız olarak test edilecektir.)*

ML step-length integration will later be compared against the same PDR interface. *(ML adım uzunluğu entegrasyonu daha sonra aynı PDR arayüzüne karşı karşılaştırılacaktır.)*

---

# 120. Replay Equivalence Test (Replay Eşdeğerlik Testi)

The same accepted step-event sequence, step lengths, and headings must produce the same PDR trajectory in live and offline replay implementations within numerical tolerance. *(Aynı kabul edilmiş adım olay dizisi, adım uzunlukları ve yönler canlı ve çevrimdışı replay uygulamalarında sayısal tolerans içerisinde aynı PDR rotasını üretmelidir.)*

---

# 121. Physical Straight-Line Test (Fiziksel Düz Çizgi Testi)

A measured or controlled straight route will be used to evaluate baseline PDR. *(Ölçülmüş veya kontrollü düz bir rota temel PDR’yi değerlendirmek için kullanılacaktır.)*

The test should identify distance underestimation, distance overestimation, and heading-induced lateral drift. *(Test mesafe düşük tahminini, mesafe yüksek tahminini ve yön kaynaklı yanal sürüklenmeyi belirlemelidir.)*

---

# 122. Physical Closed-Loop Test (Fiziksel Kapalı Döngü Testi)

A square or similar closed route will be used to evaluate accumulated heading and distance error. *(Kare veya benzer kapalı bir rota birikmiş yön ve mesafe hatasını değerlendirmek için kullanılacaktır.)*

Final closure error will be measured. *(Nihai kapanış hatası ölçülecektir.)*

---

# 123. Turn-Heavy Test (Dönüş Yoğun Test)

A route containing repeated direction changes will challenge heading synchronization and step propagation. *(Tekrarlanan yön değişiklikleri içeren bir rota yön senkronizasyonunu ve adım ilerletmeyi zorlayacaktır.)*

The test will help distinguish straight-line accuracy from turn-handling accuracy. *(Test düz çizgi doğruluğu ile dönüş yönetimi doğruluğunu ayırt etmeye yardımcı olacaktır.)*

---

# 124. Long-Duration Test (Uzun Süreli Test)

Longer walking sessions will measure drift accumulation over time. *(Daha uzun yürüyüş oturumları zaman içerisinde sürüklenme birikimini ölçecektir.)*

Candidate durations include approximately five-minute and ten-minute tests. *(Aday süreler yaklaşık beş dakikalık ve on dakikalık testleri içerir.)*

Actual test definitions will be frozen in **34 — Field Experiment Plan**. *(Gerçek test tanımları **34 — Field Experiment Plan** içerisinde sabitlenecektir.)*

---

# 125. PDR Benchmark Success (PDR Benchmark Başarısı)

Baseline PDR success does not require zero drift. *(Temel PDR başarısı sıfır sürüklenme gerektirmez.)*

The baseline must operate reproducibly, produce a continuous estimated route, and generate measurable quantitative error. *(Temel sistem tekrarlanabilir şekilde çalışmalı, sürekli bir tahmini rota üretmeli ve ölçülebilir nicel hata oluşturmalıdır.)*

The baseline provides the reference needed to determine whether advanced NAVGUARD components actually reduce drift. *(Temel sistem gelişmiş NAVGUARD bileşenlerinin gerçekten sürüklenmeyi azaltıp azaltmadığını belirlemek için gerekli referansı sağlar.)*

---

# 126. No Fabricated Performance Target (Uydurulmuş Performans Hedefi Olmaması)

This document will not define an unsupported claim such as a guaranteed maximum PDR error after a fixed walking distance. *(Bu doküman sabit bir yürüyüş mesafesinden sonra garanti edilmiş maksimum PDR hatası gibi desteklenmeyen bir iddia tanımlamayacaktır.)*

Performance thresholds will be set only after pilot measurements establish realistic device-specific behavior. *(Performans eşikleri yalnızca pilot ölçümler gerçekçi cihaza özgü davranışı belirledikten sonra ayarlanacaktır.)*

---

# 127. Baseline PDR Definition of Done (Temel PDR Tamamlanma Tanımı)

The baseline PDR engine must initialize from a validated GNSS anchor. *(Temel PDR motoru doğrulanmış bir GNSS çapasından başlatılmalıdır.)*

It must accept timestamped step events. *(Zaman damgalı adım olaylarını kabul etmelidir.)*

It must obtain a valid step length for every propagated step. *(İlerletilen her adım için geçerli bir adım uzunluğu elde etmelidir.)*

It must obtain a true-north heading for every propagated step. *(İlerletilen her adım için gerçek kuzey referanslı yön elde etmelidir.)*

It must update East and North position correctly. *(Doğu ve Kuzey konumunu doğru güncellemelidir.)*

It must generate a reproducible trajectory. *(Tekrarlanabilir bir rota üretmelidir.)*

---

# 128. Additional Definition of Done Requirements (Ek Tamamlanma Tanımı Gereksinimleri)

The baseline PDR must remain independent from GNSS correction during the denied interval. *(Temel PDR kesintili aralık sırasında GNSS düzeltmesinden bağımsız kalmalıdır.)*

It must remain functional without ARCore. *(ARCore olmadan çalışabilir kalmalıdır.)*

It must remain functional without AI-based step-length estimation. *(Yapay zekâ tabanlı adım uzunluğu tahmini olmadan çalışabilir kalmalıdır.)*

It must preserve per-step evidence for evaluation. *(Değerlendirme için adım başına kanıtı korumalıdır.)*

---

# 129. PDR Minimum Dependencies (PDR Minimum Bağımlılıkları)

```
Accelerometer
     +
Step Detector
     +
Baseline Step Length
     +
Baseline Heading
     +
Initial GNSS Anchor
     =
Baseline NAVGUARD PDR
```

ARCore is not a minimum dependency. *(ARCore minimum bağımlılık değildir.)*

Artificial intelligence is not a minimum dependency. *(Yapay zekâ minimum bağımlılık değildir.)*

---

# 130. PDR Target Enhancements (PDR Hedef İyileştirmeleri)

Target enhancements include improved heading fusion. *(Hedef iyileştirmeler geliştirilmiş yön füzyonunu içerir.)*

Target enhancements include motion-aware step handling. *(Hedef iyileştirmeler hareket farkındalıklı adım yönetimini içerir.)*

Target enhancements include ML-based step length. *(Hedef iyileştirmeler ML tabanlı adım uzunluğunu içerir.)*

Target enhancements include ARCore displacement fusion. *(Hedef iyileştirmeler ARCore yer değiştirme füzyonunu içerir.)*

Target enhancements include EKF-based state estimation and uncertainty. *(Hedef iyileştirmeler EKF tabanlı durum tahminini ve belirsizliği içerir.)*

---

# 131. PDR Non-Goals (PDR Olmayan Hedefler)

Baseline PDR will not perform raw GNSS positioning. *(Temel PDR ham GNSS konumlandırma gerçekleştirmeyecektir.)*

Baseline PDR will not perform visual tracking. *(Temel PDR görsel takip gerçekleştirmeyecektir.)*

Baseline PDR will not perform map matching. *(Temel PDR map matching gerçekleştirmeyecektir.)*

Baseline PDR will not directly classify motion using a neural network. *(Temel PDR doğrudan bir sinir ağı kullanarak hareket sınıflandırmayacaktır.)*

Baseline PDR will not claim indefinite GNSS-independent accuracy. *(Temel PDR süresiz GNSS bağımsız doğruluk iddia etmeyecektir.)*

---

# 132. Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kararlar)

NAVGUARD baseline pedestrian navigation will use step-based PDR rather than raw-acceleration double integration. *(NAVGUARD temel yaya navigasyonu ham ivme çift integrasyonu yerine adım tabanlı PDR kullanacaktır.)*

PDR will operate in local ENU metres. *(PDR yerel ENU metre cinsinde çalışacaktır.)*

The initial PDR position will be `(E, N) = (0, 0)` at the accepted GNSS anchor. *(Başlangıç PDR konumu kabul edilen GNSS çapasında `(E, N) = (0, 0)` olacaktır.)*

Position will normally propagate only when a valid step is accepted. *(Konum normalde yalnızca geçerli bir adım kabul edildiğinde ilerleyecektir.)*

Each step will use an associated step length and true-north heading. *(Her adım ilişkili bir adım uzunluğu ve gerçek kuzey yönü kullanacaktır.)*

---

# 133. Additional Frozen Decisions (Ek Sabitlenmiş Kararlar)

Horizontal propagation will use `ΔE = L sinψ` and `ΔN = L cosψ`. *(Yatay ilerletme `ΔE = L sinψ` ve `ΔN = L cosψ` kullanacaktır.)*

Stationary periods will produce no intentional PDR displacement. *(Sabit dönemler kasıtlı PDR yer değiştirmesi üretmeyecektir.)*

Baseline PDR will remain operational without ARCore. *(Temel PDR ARCore olmadan çalışabilir kalacaktır.)*

Baseline PDR will remain operational without AI. *(Temel PDR yapay zekâ olmadan çalışabilir kalacaktır.)*

Historical PDR trajectories will not be retrospectively corrected after GNSS recovery. *(Geçmiş PDR rotaları GNSS geri kazanımından sonra geriye dönük olarak düzeltilmeyecektir.)*

---

# 134. Decisions Pending Measurement (Ölçüm Bekleyen Kararlar)

The final baseline step detector remains pending collected Redmi Note 9 Pro walking data. *(Nihai temel adım algılayıcı toplanmış Redmi Note 9 Pro yürüyüş verisini beklemektedir.)*

The final fixed-step-length calibration value remains pending measured walking routes. *(Nihai sabit adım uzunluğu kalibrasyon değeri ölçülmüş yürüyüş rotalarını beklemektedir.)*

The final deterministic variable-step-length model remains pending comparative experiments. *(Nihai deterministik değişken adım uzunluğu modeli karşılaştırmalı deneyleri beklemektedir.)*

The final baseline heading algorithm remains pending heading experiments. *(Nihai temel yön algoritması yön deneylerini beklemektedir.)*

The final PDR confidence mapping remains pending error calibration. *(Nihai PDR güven eşlemesi hata kalibrasyonunu beklemektedir.)*

---

# 135. PDR Acceptance Criteria (PDR Kabul Kriterleri)

A synthetic northward step must produce positive North displacement. *(Sentetik kuzeye bir adım pozitif Kuzey yer değiştirmesi üretmelidir.)*

A synthetic eastward step must produce positive East displacement. *(Sentetik doğuya bir adım pozitif Doğu yer değiştirmesi üretmelidir.)*

A stationary sequence with no accepted steps must not change position. *(Kabul edilmiş adım içermeyen sabit bir dizi konumu değiştirmemelidir.)*

Duplicate step events must not propagate twice. *(Yinelenen adım olayları iki kez ilerletilmemelidir.)*

Invalid heading or step-length values must not silently enter the trajectory. *(Geçersiz yön veya adım uzunluğu değerleri rotaya sessizce girmemelidir.)*

---

# 136. Experimental Acceptance Criteria (Deneysel Kabul Kriterleri)

Baseline PDR must complete a controlled straight walking route. *(Temel PDR kontrollü düz yürüyüş rotasını tamamlamalıdır.)*

Baseline PDR must complete a controlled turn-containing route. *(Temel PDR dönüş içeren kontrollü bir rotayı tamamlamalıdır.)*

Baseline PDR must preserve its position during a controlled stationary period. *(Temel PDR kontrollü sabit dönem sırasında konumunu korumalıdır.)*

Baseline PDR must produce measurable position-error results against independent reference data. *(Temel PDR bağımsız referans verisine karşı ölçülebilir konum hata sonuçları üretmelidir.)*

---

# 137. Comparison Acceptance Criteria (Karşılaştırma Kabul Kriterleri)

The same baseline configuration must be reusable across multiple sessions. *(Aynı temel yapılandırma birden fazla oturumda yeniden kullanılabilir olmalıdır.)*

Configuration A results must remain distinguishable from enhanced configurations. *(Yapılandırma A sonuçları geliştirilmiş yapılandırmalardan ayırt edilebilir kalmalıdır.)*

No hidden ARCore or ground-truth GNSS correction may influence Configuration A. *(Hiçbir gizli ARCore veya gerçek referans GNSS düzeltmesi Yapılandırma A’yı etkileyemez.)*

---

# 138. Final PDR Architecture Statement (Nihai PDR Mimarisi Bildirimi)

**NAVGUARD will use a discrete step-based Pedestrian Dead Reckoning engine as its minimum GNSS-denied position-estimation capability.** *(NAVGUARD minimum GNSS kesintili konum tahmin yeteneği olarak ayrık adım tabanlı bir Yaya Ölü Hesaplama motoru kullanacaktır.)*

**The PDR engine will begin from a validated GNSS anchor represented as the local ENU origin and will propagate horizontal position only from accepted pedestrian steps.** *(PDR motoru yerel ENU başlangıç noktası olarak temsil edilen doğrulanmış bir GNSS çapasından başlayacak ve yatay konumu yalnızca kabul edilmiş yaya adımlarından ilerletecektir.)*

**Each propagated step will use an estimated step length and a true-north-referenced heading to calculate `ΔE = L sinψ` and `ΔN = L cosψ`.** *(İlerletilen her adım `ΔE = L sinψ` ve `ΔN = L cosψ` hesaplamak için tahmini bir adım uzunluğu ve gerçek kuzey referanslı yön kullanacaktır.)*

**Baseline PDR will remain independent from ARCore, AI, and GNSS corrections so that it provides a reproducible experimental reference and a reliable fallback when advanced NAVGUARD components become unavailable.** *(Temel PDR, tekrarlanabilir deneysel referans ve gelişmiş NAVGUARD bileşenleri kullanılamaz hale geldiğinde güvenilir geri dönüş sağlamak için ARCore, yapay zekâ ve GNSS düzeltmelerinden bağımsız kalacaktır.)*

**Advanced motion classification, machine-learning step-length estimation, improved heading fusion, ARCore displacement, and EKF corrections will enhance rather than replace the baseline PDR architecture.** *(Gelişmiş hareket sınıflandırması, makine öğrenmesi adım uzunluğu tahmini, geliştirilmiş yön füzyonu, ARCore yer değiştirmesi ve EKF düzeltmeleri temel PDR mimarisinin yerini almak yerine onu geliştirecektir.)*

---

# 139. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development PDR Architecture Completed *(Doküman Durumu: Geliştirme Öncesi PDR Mimarisi Tamamlandı)*

**Primary PDR Type:** Step-Based Pedestrian Dead Reckoning *(Temel PDR Türü: Adım Tabanlı Yaya Ölü Hesaplama)*

**Primary Coordinate Frame:** Local ENU *(Temel Koordinat Çerçevesi: Yerel ENU)*

**Initial Position:** Accepted GNSS Anchor → `(E, N) = (0, 0)` *(Başlangıç Konumu: Kabul Edilmiş GNSS Çapası → `(E, N) = (0, 0)`)*

**Position Trigger:** Accepted Step Event *(Konum Tetikleyicisi: Kabul Edilmiş Adım Olayı)*

**East Propagation:** `ΔE = L sinψ` *(Doğu İlerletme: `ΔE = L sinψ`)*

**North Propagation:** `ΔN = L cosψ` *(Kuzey İlerletme: `ΔN = L cosψ`)*

**Heading Reference:** True North *(Yön Referansı: Gerçek Kuzey)*

**Baseline Step Length:** Deterministic / Calibrated *(Temel Adım Uzunluğu: Deterministik / Kalibre Edilmiş)*

**ML Step Length:** Target Enhancement *(ML Adım Uzunluğu: Hedef İyileştirme)*

**Stationary Policy:** No Position Propagation *(Sabit Durum Politikası: Konum İlerletme Yok)*

**ARCore Dependency:** None for Baseline *(ARCore Bağımlılığı: Temel Sistem İçin Yok)*

**AI Dependency:** None for Baseline *(Yapay Zekâ Bağımlılığı: Temel Sistem İçin Yok)*

**GNSS During Denial:** No Estimator Correction *(Kesinti Sırasında GNSS: Tahmin Motoru Düzeltmesi Yok)*

**Historical PDR Policy:** Immutable After Recovery *(Geçmiş PDR Politikası: Geri Kazanımdan Sonra Değiştirilemez)*

**Final Detector Parameters:** Pending Physical Data Collection *(Nihai Algılayıcı Parametreleri: Fiziksel Veri Toplama Bekleniyor)*

**Final Step-Length Parameters:** Pending Calibration Experiments *(Nihai Adım Uzunluğu Parametreleri: Kalibrasyon Deneyleri Bekleniyor)*

**Next Documentation Item:** 17 — Step Detection System *(Sonraki Dokümantasyon Öğesi: 17 — Adım Tespit Sistemi)*