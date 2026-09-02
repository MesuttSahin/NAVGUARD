# 13 — Sensor Timing, Synchronization & Preprocessing (Sensör Zamanlaması, Senkronizasyonu ve Ön İşleme)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the timing model, synchronization strategy, resampling rules, interpolation policies, filtering pipeline, gravity handling, bias correction, coordinate preparation, normalization, window construction, and preprocessing integrity requirements of NAVGUARD. *(Bu doküman, NAVGUARD’ın zamanlama modelini, senkronizasyon stratejisini, yeniden örnekleme kurallarını, interpolasyon politikalarını, filtreleme hattını, yerçekimi yönetimini, bias düzeltmesini, koordinat hazırlığını, normalizasyonu, pencere oluşturmayı ve ön işleme bütünlük gereksinimlerini tanımlar.)*

The primary objective is to transform independently timestamped raw sensor streams into temporally consistent processed measurements without destroying the original experimental evidence. *(Temel amaç, bağımsız olarak zaman damgalanmış ham sensör akışlarını orijinal deneysel kanıtı bozmadan zamansal olarak tutarlı işlenmiş ölçümlere dönüştürmektir.)*

The preprocessing system will be shared conceptually between live mobile navigation, offline replay, dataset generation, and machine learning. *(Ön işleme sistemi kavramsal olarak canlı mobil navigasyon, çevrimdışı replay, veri seti oluşturma ve makine öğrenmesi arasında paylaşılacaktır.)*

---

# 2. Core Timing Principle (Temel Zamanlama İlkesi)

NAVGUARD will use measurement time rather than callback-arrival time as the primary temporal reference. *(NAVGUARD temel zamansal referans olarak callback ulaşma zamanı yerine ölçüm zamanını kullanacaktır.)*

Every physical or derived measurement will remain associated with the timestamp representing the time at which the underlying observation occurred whenever such a timestamp is available. *(Her fiziksel veya türetilmiş ölçüm, böyle bir zaman damgası mevcut olduğunda temel gözlemin gerçekleştiği zamanı temsil eden zaman damgasıyla ilişkili kalacaktır.)*

Processing latency must not silently alter the chronological location of a measurement. *(İşleme gecikmesi bir ölçümün kronolojik konumunu sessizce değiştirmemelidir.)*

---

# 3. Raw Data Preservation Rule (Ham Veri Koruma Kuralı)

Synchronization will never overwrite raw sensor recordings. *(Senkronizasyon ham sensör kayıtlarının üzerine hiçbir zaman yazmayacaktır.)*

Filtering will never overwrite raw sensor recordings. *(Filtreleme ham sensör kayıtlarının üzerine hiçbir zaman yazmayacaktır.)*

Interpolation will never overwrite raw sensor recordings. *(Interpolasyon ham sensör kayıtlarının üzerine hiçbir zaman yazmayacaktır.)*

Coordinate transformation will never overwrite raw sensor recordings. *(Koordinat dönüşümü ham sensör kayıtlarının üzerine hiçbir zaman yazmayacaktır.)*

Every transformation will create derived data that can be traced back to the original stream. *(Her dönüşüm orijinal akışa kadar izlenebilen türetilmiş veri oluşturacaktır.)*

---

# 4. Time Domains in NAVGUARD (NAVGUARD’daki Zaman Alanları)

NAVGUARD may encounter several distinct time domains. *(NAVGUARD birden fazla farklı zaman alanıyla karşılaşabilir.)*

The Android sensor stream uses the elapsed-realtime monotonic time domain. *(Android sensör akışı elapsed-realtime monotonik zaman alanını kullanır.)*

Android GNSS locations obtained through `LocationManager` provide elapsed-realtime timing that can be compared with the Android monotonic clock. *(Android `LocationManager` üzerinden elde edilen GNSS konumları Android monotonik saatiyle karşılaştırılabilen elapsed-realtime zamanlaması sağlar.)*

ARCore frame timestamps are expressed in nanoseconds, but ARCore does not guarantee a formally defined time base for `Frame.getTimestamp()`. *(ARCore kare zaman damgaları nanosaniye cinsinden ifade edilir ancak ARCore `Frame.getTimestamp()` için resmî olarak tanımlanmış bir zaman tabanı garanti etmez.)*

Wall-clock timestamps represent human-readable civil time and are not the primary synchronization basis. *(Duvar saati zaman damgaları insan tarafından okunabilir sivil zamanı temsil eder ve temel senkronizasyon temeli değildir.)*

---

# 5. Common Session Timeline (Ortak Oturum Zaman Çizelgesi)

NAVGUARD will define one common monotonic session timeline for real-time navigation and experiment analysis. *(NAVGUARD gerçek zamanlı navigasyon ve deney analizi için tek bir ortak monotonik oturum zaman çizelgesi tanımlayacaktır.)*

The preferred common time base will be Android elapsed realtime in nanoseconds. *(Tercih edilen ortak zaman tabanı nanosaniye cinsinden Android elapsed realtime olacaktır.)*

A session-relative timestamp may additionally be calculated from the common time base. *(Ortak zaman tabanından ayrıca oturuma göreli bir zaman damgası hesaplanabilir.)*

```
t_session = t_elapsedRealtime - t_sessionStart
```

Session-relative time will usually begin at or near zero and will simplify plotting and replay. *(Oturuma göreli zaman genellikle sıfırda veya sıfıra yakın başlayacak ve grafik oluşturma ile replay işlemlerini basitleştirecektir.)*

---

# 6. Android Sensor Time Base (Android Sensör Zaman Tabanı)

`SensorEvent.timestamp` will remain the authoritative timestamp for accelerometer, gyroscope, magnetometer, and Android virtual-sensor events. *(`SensorEvent.timestamp`; ivmeölçer, jiroskop, manyetometre ve Android sanal sensör olayları için ana zaman damgası olarak kalacaktır.)*

Android defines this timestamp using the same time base as `SystemClock.elapsedRealtimeNanos()`. *(Android bu zaman damgasını `SystemClock.elapsedRealtimeNanos()` ile aynı zaman tabanını kullanarak tanımlar.)*

For each sensor, event timestamps should increase monotonically. *(Her sensör için olay zaman damgalarının monotonik olarak artması beklenir.)*

---

# 7. GNSS Time Base (GNSS Zaman Tabanı)

`Location.getElapsedRealtimeNanos()` will be the primary GNSS timing field used for within-session synchronization. *(`Location.getElapsedRealtimeNanos()`, oturum içi senkronizasyon için kullanılan temel GNSS zamanlama alanı olacaktır.)*

Android defines this value as monotonic elapsed realtime since system boot. *(Android bu değeri sistem açılışından itibaren geçen monotonik süre olarak tanımlar.)*

Locations generated by `LocationManager` are guaranteed to contain valid elapsed-realtime information. *(`LocationManager` tarafından oluşturulan konumların geçerli elapsed-realtime bilgisi içermesi garanti edilir.)*

This makes GNSS measurements directly orderable relative to Android sensor measurements within the same device boot cycle. *(Bu, aynı cihaz açılış döngüsü içerisinde GNSS ölçümlerinin Android sensör ölçümlerine göre doğrudan sıralanabilmesini sağlar.)*

---

# 8. Wall-Clock Time Policy (Duvar Saati Zamanı Politikası)

Wall-clock time will be recorded for human readability and experiment documentation. *(Duvar saati zamanı insan tarafından okunabilirlik ve deney dokümantasyonu için kaydedilecektir.)*

Wall-clock time will not be used as the primary ordering mechanism for sensor fusion. *(Duvar saati zamanı sensör füzyonu için temel sıralama mekanizması olarak kullanılmayacaktır.)*

Android notes that ordinary system clock time can change and is therefore not appropriate for reliable ordering of location fixes. *(Android normal sistem saati zamanının değişebileceğini ve bu nedenle konum fix’lerini güvenilir şekilde sıralamak için uygun olmadığını belirtir.)*

---

# 9. Boot-Cycle Limitation (Cihaz Açılış Döngüsü Sınırlaması)

Elapsed-realtime timestamps are meaningful only within the same device boot cycle. *(Elapsed-realtime zaman damgaları yalnızca aynı cihaz açılış döngüsü içerisinde anlamlıdır.)*

NAVGUARD will therefore never directly compare elapsed-realtime nanosecond values from different device boots as though they belonged to one continuous clock. *(Bu nedenle NAVGUARD farklı cihaz açılışlarından gelen elapsed-realtime nanosaniye değerlerini tek bir sürekli saate aitmiş gibi doğrudan karşılaştırmayacaktır.)*

Every session manifest should contain sufficient wall-clock metadata to distinguish separate recordings. *(Her oturum manifest’i ayrı kayıtları ayırt etmek için yeterli duvar saati metadata bilgisi içermelidir.)*

---

# 10. ARCore Timestamp Problem (ARCore Zaman Damgası Problemi)

ARCore `Frame.getTimestamp()` returns the image capture time in nanoseconds. *(ARCore `Frame.getTimestamp()` görüntünün yakalanma zamanını nanosaniye cinsinden döndürür.)*

ARCore states that the formal time base of this value is not defined. *(ARCore bu değerin resmî zaman tabanının tanımlanmadığını belirtir.)*

NAVGUARD will therefore treat the ARCore clock as a separate time domain until synchronization has been validated on the Redmi Note 9 Pro. *(Bu nedenle NAVGUARD, Redmi Note 9 Pro üzerinde senkronizasyon doğrulanana kadar ARCore saatini ayrı bir zaman alanı olarak ele alacaktır.)*

---

# 11. ARCore Original Timestamp Preservation (ARCore Orijinal Zaman Damgası Koruma)

Every ARCore pose sample will preserve the original frame timestamp. *(Her ARCore poz örneği orijinal kare zaman damgasını koruyacaktır.)*

The application will not rewrite the original ARCore timestamp after synchronization. *(Uygulama senkronizasyondan sonra orijinal ARCore zaman damgasını yeniden yazmayacaktır.)*

A separate synchronized timestamp field will be created when the mapping to NAVGUARD common time has been validated. *(NAVGUARD ortak zamanına eşleme doğrulandığında ayrı bir senkronize zaman damgası alanı oluşturulacaktır.)*

---

# 12. ARCore Reception Timestamp (ARCore Alım Zaman Damgası)

NAVGUARD will capture an Android elapsed-realtime timestamp when each ARCore frame is processed by the native layer. *(NAVGUARD her ARCore karesi native katman tarafından işlendiğinde Android elapsed-realtime zaman damgası yakalayacaktır.)*

```
t_ar_frame
t_native_receive
```

The difference between these values may provide information for estimating the mapping between the ARCore clock and NAVGUARD common time. *(Bu değerler arasındaki fark ARCore saati ile NAVGUARD ortak zamanı arasındaki eşlemeyi tahmin etmek için bilgi sağlayabilir.)*

Reception time will not be treated as equivalent to physical camera-capture time. *(Alım zamanı fiziksel kamera yakalama zamanına eşdeğer olarak ele alınmayacaktır.)*

---

# 13. ARCore Clock Mapping Model (ARCore Saat Eşleme Modeli)

The first synchronization candidate will use an offset model. *(İlk senkronizasyon adayı offset modeli kullanacaktır.)*

```
t_common ≈ t_arcore + b
```

The value `b` represents the estimated difference between the two time domains. *(`b` değeri iki zaman alanı arasındaki tahmini farkı temsil eder.)*

If measurements demonstrate measurable clock-scale drift, an affine mapping may be evaluated. *(Ölçümler ölçülebilir saat ölçeği sürüklenmesi gösterirse affine bir eşleme değerlendirilebilir.)*

```
t_common ≈ a · t_arcore + b
```

The more complex model will not be used unless real measurements demonstrate that it is necessary. *(Daha karmaşık model gerçek ölçümler gerekli olduğunu göstermediği sürece kullanılmayacaktır.)*

---

# 14. ARCore Offset Estimation (ARCore Offset Tahmini)

For a sequence of ARCore frames, NAVGUARD may calculate candidate offsets using native reception timestamps. *(Bir ARCore kare dizisi için NAVGUARD native alım zaman damgalarını kullanarak aday offset değerleri hesaplayabilir.)*

```
b_i = t_native_receive_i - t_arcore_i
```

A robust statistic such as the median may be used to reduce the influence of variable callback latency. *(Değişken callback gecikmesinin etkisini azaltmak için medyan gibi robust bir istatistik kullanılabilir.)*

The final method must be validated experimentally before ARCore is used as a fusion measurement. *(Nihai yöntem ARCore bir füzyon ölçümü olarak kullanılmadan önce deneysel olarak doğrulanmalıdır.)*

---

# 15. ARCore Synchronization Validation (ARCore Senkronizasyon Doğrulaması)

NAVGUARD will measure the stability of the estimated ARCore-to-common-time offset. *(NAVGUARD tahmini ARCore-ortak-zaman offset’inin kararlılığını ölçecektir.)*

The analysis should examine median offset, offset dispersion, long-term trend, and outliers. *(Analiz medyan offset’i, offset dağılımını, uzun dönem trendini ve aykırı değerleri incelemelidir.)*

If synchronization uncertainty is too large for reliable fusion, ARCore will remain available for separate trajectory analysis rather than being forced into the EKF. *(Senkronizasyon belirsizliği güvenilir füzyon için fazla büyükse ARCore EKF’ye zorla dahil edilmek yerine ayrı rota analizi için kullanılabilir kalacaktır.)*

---

# 16. Tracking-State Requirement for ARCore (ARCore İçin Takip Durumu Gereksinimi)

ARCore pose information will be used for navigation only while tracking state is valid for that purpose. *(ARCore poz bilgisi yalnızca takip durumu bu amaç için geçerliyken navigasyonda kullanılacaktır.)*

Google specifies that the Android sensor pose associated with an ARCore frame is useful only while camera tracking is in the tracking state. *(Google bir ARCore karesiyle ilişkili Android sensör pozunun yalnızca kamera takibi takip durumundayken kullanışlı olduğunu belirtir.)*

Samples from unusable tracking states will remain in diagnostics but will not be converted into trusted displacement updates. *(Kullanılamaz takip durumlarından gelen örnekler tanıda kalacak ancak güvenilir yer değiştirme güncellemelerine dönüştürülmeyecektir.)*

---

# 17. Synchronization Architecture (Senkronizasyon Mimarisi)

```
Accelerometer ─┐
Gyroscope ──────┼──► Android Elapsed Realtime ───┐
Magnetometer ───┤                                │
Rotation Vector ┘                                │
                                                 ├──► Common Session Timeline
GNSS ─────────────► ElapsedRealtimeNanos ─────────┤
                                                 │
ARCore ───────────► Clock Mapping ────────────────┘
```

The synchronized timeline will be a derived representation rather than the authoritative raw recording. *(Senkronize zaman çizelgesi ana ham kayıt yerine türetilmiş bir temsil olacaktır.)*

---

# 18. Asynchronous Sensor Principle (Asenkron Sensör İlkesi)

NAVGUARD will not assume that accelerometer, gyroscope, magnetometer, and rotation-vector measurements occur simultaneously. *(NAVGUARD ivmeölçer, jiroskop, manyetometre ve rotation-vector ölçümlerinin eşzamanlı gerçekleştiğini varsaymayacaktır.)*

Each source has its own timestamped event stream. *(Her kaynağın kendi zaman damgalı olay akışı vardır.)*

Synchronization will occur explicitly when a downstream algorithm requires a common timeline. *(Senkronizasyon bir aşağı akış algoritması ortak bir zaman çizelgesi gerektirdiğinde açıkça gerçekleştirilecektir.)*

---

# 19. Processing Without Forced Synchronization (Zorunlu Senkronizasyon Olmadan İşleme)

Not every navigation algorithm requires all sensor channels to be resampled onto one common grid. *(Her navigasyon algoritmasının tüm sensör kanallarını tek bir ortak grid üzerine yeniden örneklemesi gerekmez.)*

An event-driven estimator may process measurements at their original timestamps. *(Olay güdümlü bir tahmin motoru ölçümleri orijinal zaman damgalarında işleyebilir.)*

A time-series AI model may instead require a uniformly sampled multi-channel tensor. *(Bir zaman serisi yapay zekâ modeli ise eşit aralıklarla örneklenmiş çok kanallı bir tensöre ihtiyaç duyabilir.)*

Synchronization policy will therefore depend on the consumer. *(Bu nedenle senkronizasyon politikası tüketiciye bağlı olacaktır.)*

---

# 20. Consumer-Specific Timing Strategy (Tüketiciye Özgü Zamanlama Stratejisi)

| Consumer (Tüketici) | Preferred Timing Strategy (Tercih Edilen Zamanlama Stratejisi) |
| --- | --- |
| Raw Logger *(Ham Logger)* | Original timestamps *(Orijinal zaman damgaları)* |
| Step Detector *(Adım Algılayıcı)* | Native acceleration timestamps or filtered timeline *(Native ivme zaman damgaları veya filtrelenmiş zaman çizelgesi)* |
| Heading Estimator *(Yön Tahmin Motoru)* | Timestamp-aware asynchronous fusion *(Zaman damgası farkındalıklı asenkron füzyon)* |
| Motion AI *(Hareket AI)* | Uniform resampled window *(Eşit aralıklı yeniden örneklenmiş pencere)* |
| PDR | Step-event timestamps *(Adım olayı zaman damgaları)* |
| EKF | Measurement timestamps *(Ölçüm zaman damgaları)* |
| Evaluation *(Değerlendirme)* | Time-aligned trajectories *(Zamana hizalanmış rotalar)* |

---

# 21. Uniform Processing Timeline (Eşit Aralıklı İşleme Zaman Çizelgesi)

When a uniform timeline is required, NAVGUARD will generate it explicitly. *(Eşit aralıklı bir zaman çizelgesi gerektiğinde NAVGUARD bunu açıkça oluşturacaktır.)*

A nominal 50 Hz processing grid would use a 20-millisecond interval. *(Nominal 50 Hz işleme grid’i 20 milisaniyelik aralık kullanacaktır.)*

```
Δt_grid = 0.020 s
```

The final grid frequency will be frozen after device and algorithm testing. *(Nihai grid frekansı cihaz ve algoritma testlerinden sonra sabitlenecektir.)*

---

# 22. Resampling Definition (Yeniden Örnekleme Tanımı)

Resampling converts irregularly timestamped measurements into values evaluated on a defined target timeline. *(Yeniden örnekleme düzensiz zaman damgalı ölçümleri tanımlanmış bir hedef zaman çizelgesinde değerlendirilen değerlere dönüştürür.)*

Resampling does not create new physical measurements. *(Yeniden örnekleme yeni fiziksel ölçümler oluşturmaz.)*

Every resampled value must therefore be identifiable as processed data. *(Bu nedenle her yeniden örneklenmiş değer işlenmiş veri olarak tanımlanabilir olmalıdır.)*

---

# 23. Resampling Preconditions (Yeniden Örnekleme Ön Koşulları)

The raw source timestamps must first pass basic integrity checks. *(Ham kaynak zaman damgaları önce temel bütünlük kontrollerini geçmelidir.)*

The source must have sufficient measurements around the requested target time. *(Kaynak istenen hedef zamanın çevresinde yeterli ölçüme sahip olmalıdır.)*

Interpolation must not bridge an arbitrarily large data gap. *(Interpolasyon keyfi derecede büyük bir veri boşluğunu köprülememelidir.)*

A maximum acceptable interpolation gap will be defined empirically for each source. *(Her kaynak için maksimum kabul edilebilir interpolasyon boşluğu ampirik olarak tanımlanacaktır.)*

---

# 24. Continuous Scalar and Vector Interpolation (Sürekli Skaler ve Vektör Interpolasyonu)

Linear interpolation will be the initial candidate for continuous sensor channels such as acceleration, gyroscope, and magnetic-field components. *(Doğrusal interpolasyon ivme, jiroskop ve manyetik alan bileşenleri gibi sürekli sensör kanalları için ilk aday olacaktır.)*

For two measurements surrounding a target timestamp, the interpolated value may be calculated as follows. *(Bir hedef zaman damgasını çevreleyen iki ölçüm için interpolasyon değeri aşağıdaki şekilde hesaplanabilir.)*

```
α = (t - t0) / (t1 - t0)

x(t) = x0 + α(x1 - x0)
```

The same coefficient may be applied independently to each vector component. *(Aynı katsayı her vektör bileşenine bağımsız olarak uygulanabilir.)*

---

# 25. No Unbounded Interpolation (Sınırsız Interpolasyon Olmaması)

NAVGUARD will not linearly interpolate across long periods in which a sensor produced no measurements. *(NAVGUARD bir sensörün hiçbir ölçüm üretmediği uzun dönemler boyunca doğrusal interpolasyon yapmayacaktır.)*

If the source gap exceeds the configured maximum, the synchronized value will be marked unavailable. *(Kaynak boşluğu yapılandırılmış maksimumu aşarsa senkronize değer kullanılamaz olarak işaretlenecektir.)*

This prevents a visually smooth dataset from hiding actual acquisition failure. *(Bu, görsel olarak düzgün bir veri setinin gerçek veri toplama hatasını gizlemesini önler.)*

---

# 26. Extrapolation Policy (Ekstrapolasyon Politikası)

Offline preprocessing will avoid extrapolating continuous sensor measurements outside the available source range unless a specific algorithm explicitly requires it. *(Çevrimdışı ön işleme, belirli bir algoritma açıkça gerektirmediği sürece sürekli sensör ölçümlerini mevcut kaynak aralığının dışına ekstrapole etmekten kaçınacaktır.)*

Real-time processing may temporarily use the most recent valid measurement when an asynchronous estimator design requires it. *(Gerçek zamanlı işleme asenkron bir tahmin motoru tasarımı gerektirdiğinde geçici olarak en son geçerli ölçümü kullanabilir.)*

Such behavior must have an explicit maximum measurement-age rule. *(Böyle bir davranış açık bir maksimum ölçüm yaşı kuralına sahip olmalıdır.)*

---

# 27. Measurement Age (Ölçüm Yaşı)

For a current processing time `t`, measurement age may be calculated as follows. *(Mevcut işleme zamanı `t` için ölçüm yaşı aşağıdaki şekilde hesaplanabilir.)*

```
age = t - t_measurement
```

A stale measurement must not be treated as current merely because it is the latest available measurement. *(Eski bir ölçüm yalnızca mevcut en son ölçüm olduğu için güncel olarak ele alınmamalıdır.)*

Measurement-age limits will depend on sensor type and estimator design. *(Ölçüm yaşı sınırları sensör türüne ve tahmin motoru tasarımına bağlı olacaktır.)*

---

# 28. Orientation Interpolation (Yönelim Interpolasyonu)

Orientation represented as quaternions will not use ordinary independent linear interpolation of quaternion components as the preferred method. *(Quaternion olarak temsil edilen yönelim, tercih edilen yöntem olarak quaternion bileşenlerinin bağımsız sıradan doğrusal interpolasyonunu kullanmayacaktır.)*

Spherical linear interpolation, or another validated quaternion interpolation method, should be used when orientation must be evaluated between samples. *(Yönelim örnekler arasında değerlendirilmesi gerektiğinde spherical linear interpolation veya doğrulanmış başka bir quaternion interpolasyon yöntemi kullanılmalıdır.)*

The quaternion must remain normalized after processing. *(Quaternion işleme sonrasında normalize edilmiş kalmalıdır.)*

---

# 29. Quaternion Normalization (Quaternion Normalizasyonu)

For quaternion `q = [w, x, y, z]`, normalization may be performed as follows. *(`q = [w, x, y, z]` quaternion’ı için normalizasyon aşağıdaki şekilde gerçekleştirilebilir.)*

```
q_norm = q / ||q||
```

Invalid near-zero quaternion norms must be rejected rather than normalized blindly. *(Geçersiz sıfıra yakın quaternion normları körlemesine normalize edilmek yerine reddedilmelidir.)*

---

# 30. ARCore Translation Interpolation (ARCore Öteleme Interpolasyonu)

ARCore translation may use linear interpolation for short intervals after timestamp synchronization is validated. *(ARCore öteleme, zaman damgası senkronizasyonu doğrulandıktan sonra kısa aralıklar için doğrusal interpolasyon kullanabilir.)*

Interpolation must be disabled across tracking loss or large frame gaps. *(Takip kaybı veya büyük kare boşlukları boyunca interpolasyon devre dışı bırakılmalıdır.)*

A tracking-state transition creates a quality boundary even if timestamps remain continuous. *(Takip durumu geçişi zaman damgaları sürekli kalsa bile bir kalite sınırı oluşturur.)*

---

# 31. GNSS Interpolation Policy (GNSS Interpolasyon Politikası)

GNSS ground truth will not automatically be interpolated at IMU frequency for primary raw evaluation. *(GNSS gerçek referansı temel ham değerlendirme için otomatik olarak IMU frekansına interpolate edilmeyecektir.)*

Trajectory comparison may require time-aligned GNSS reference positions at estimator timestamps. *(Rota karşılaştırması tahmin motoru zaman damgalarında zamana hizalanmış GNSS referans konumları gerektirebilir.)*

The final evaluation pipeline may perform geographically appropriate interpolation over short valid GNSS intervals. *(Nihai değerlendirme hattı kısa geçerli GNSS aralıklarında coğrafi olarak uygun interpolasyon gerçekleştirebilir.)*

The interpolation method and maximum GNSS gap will be defined in the benchmark methodology. *(Interpolasyon yöntemi ve maksimum GNSS boşluğu benchmark metodolojisinde tanımlanacaktır.)*

---

# 32. Synchronization Metadata (Senkronizasyon Metadata Bilgisi)

Every processed synchronized dataset should preserve its processing configuration. *(Her işlenmiş senkronize veri seti işleme yapılandırmasını korumalıdır.)*

The configuration should include target frequency, interpolation methods, maximum gaps, input stream versions, and preprocessing version. *(Yapılandırma hedef frekansı, interpolasyon yöntemlerini, maksimum boşlukları, girdi akış sürümlerini ve ön işleme sürümünü içermelidir.)*

This allows identical raw recordings to be reprocessed under alternative synchronization strategies. *(Bu aynı ham kayıtların alternatif senkronizasyon stratejileri altında yeniden işlenmesine olanak sağlar.)*

---

# 33. Processing Pipeline Overview (İşleme Hattı Genel Bakışı)

```
Raw Timestamped Streams
(Ham Zaman Damgalı Akışlar)
          │
          ▼
Integrity Checks
(Bütünlük Kontrolleri)
          │
          ▼
Time-Domain Mapping
(Zaman Alanı Eşleme)
          │
          ▼
Calibration / Bias Handling
(Kalibrasyon / Bias Yönetimi)
          │
          ▼
Filtering
(Filtreleme)
          │
          ▼
Coordinate Preparation
(Koordinat Hazırlığı)
          │
          ▼
Optional Resampling
(İsteğe Bağlı Yeniden Örnekleme)
          │
          ▼
Normalization / Features
(Normalizasyon / Özellikler)
          │
          ▼
Algorithm-Specific Windows
(Algoritmaya Özgü Pencereler)
```

Not every consumer will necessarily use every stage. *(Her tüketicinin her aşamayı kullanması zorunlu değildir.)*

---

# 34. Preprocessing Versioning (Ön İşleme Sürümleme)

The preprocessing pipeline will have an explicit version identifier. *(Ön işleme hattının açık bir sürüm tanımlayıcısı olacaktır.)*

Any change that alters numerical algorithm inputs must create a new preprocessing version. *(Sayısal algoritma girdilerini değiştiren herhangi bir değişiklik yeni bir ön işleme sürümü oluşturmalıdır.)*

Examples include filter coefficients, normalization values, resampling rate, interpolation rules, gravity-removal strategy, and sensor-channel order. *(Örnekler filtre katsayılarını, normalizasyon değerlerini, yeniden örnekleme hızını, interpolasyon kurallarını, yerçekimi kaldırma stratejisini ve sensör kanal sırasını içerir.)*

---

# 35. Filtering Objective (Filtreleme Hedefi)

Filtering will reduce unwanted high-frequency noise or isolate signal components required by downstream algorithms. *(Filtreleme istenmeyen yüksek frekanslı gürültüyü azaltacak veya aşağı akış algoritmaları tarafından gerekli sinyal bileşenlerini ayıracaktır.)*

Filtering will not be applied automatically to every channel merely because filtering is possible. *(Filtreleme mümkün olduğu için her kanala otomatik olarak filtre uygulanmayacaktır.)*

Each filter must have a defined purpose and measurable effect. *(Her filtrenin tanımlanmış bir amacı ve ölçülebilir etkisi olmalıdır.)*

---

# 36. Filter Design Policy (Filtre Tasarım Politikası)

Filter selection will occur after the actual Redmi Note 9 Pro sampling characteristics have been measured. *(Filtre seçimi gerçek Redmi Note 9 Pro örnekleme özellikleri ölçüldükten sonra gerçekleştirilecektir.)*

Cutoff frequencies will not be frozen before actual signal spectra and step characteristics are inspected. *(Gerçek sinyal spektrumları ve adım özellikleri incelenmeden cutoff frekansları sabitlenmeyecektir.)*

Offline SciPy analysis may be used to compare candidate filters before the real-time implementation is finalized. *(Gerçek zamanlı uygulama kesinleştirilmeden önce aday filtreleri karşılaştırmak için çevrimdışı SciPy analizi kullanılabilir.)*

---

# 37. Real-Time Causality Requirement (Gerçek Zamanlı Nedensellik Gereksinimi)

Filters used by live navigation must be causal or otherwise implementable without future samples. *(Canlı navigasyonda kullanılan filtreler nedensel veya gelecekteki örnekler olmadan uygulanabilir olmalıdır.)*

Offline analysis may additionally use zero-phase filtering for diagnostic comparison. *(Çevrimdışı analiz tanısal karşılaştırma için ayrıca zero-phase filtreleme kullanabilir.)*

Offline-only zero-phase results must not be presented as though the real-time mobile system produced them. *(Yalnızca çevrimdışı zero-phase sonuçlar gerçek zamanlı mobil sistem üretmiş gibi sunulmamalıdır.)*

---

# 38. Candidate Low-Pass Filtering (Aday Alçak Geçiren Filtreleme)

A lightweight low-pass filter may be evaluated for acceleration and other noisy continuous signals. *(Hafif bir alçak geçiren filtre ivme ve diğer gürültülü sürekli sinyaller için değerlendirilebilir.)*

A simple first-order form may be expressed as follows. *(Basit bir birinci derece form aşağıdaki şekilde ifade edilebilir.)*

```
y_k = α y_(k-1) + (1 - α) x_k
```

The coefficient `α` must be derived from the intended cutoff behavior and actual sampling interval rather than selected arbitrarily. *(`α` katsayısı keyfi seçilmek yerine amaçlanan cutoff davranışından ve gerçek örnekleme aralığından türetilmelidir.)*

---

# 39. Time-Aware Filter Coefficients (Zaman Farkındalıklı Filtre Katsayıları)

If sampling intervals vary meaningfully, filter behavior should account for actual `Δt` rather than assume an exactly constant sampling period. *(Örnekleme aralıkları anlamlı şekilde değişiyorsa filtre davranışı tam olarak sabit bir örnekleme periyodu varsaymak yerine gerçek `Δt` değerini dikkate almalıdır.)*

A time-constant-based first-order filter may calculate its coefficient from the actual interval. *(Zaman sabiti tabanlı bir birinci derece filtre katsayısını gerçek aralıktan hesaplayabilir.)*

```
α = τ / (τ + Δt)
```

The final formulation will depend on the selected filter design. *(Nihai formülasyon seçilen filtre tasarımına bağlı olacaktır.)*

---

# 40. Baseline Step Signal Filtering (Temel Adım Sinyali Filtreleme)

The baseline step detector will likely operate on acceleration magnitude or another orientation-robust derived signal. *(Temel adım algılayıcı büyük olasılıkla ivme büyüklüğü veya yönelime dayanıklı başka bir türetilmiş sinyal üzerinde çalışacaktır.)*

A band-limited or smoothed version of this signal may be used for peak detection. *(Peak tespiti için bu sinyalin bant sınırlı veya yumuşatılmış bir sürümü kullanılabilir.)*

The exact filter and thresholds will be determined through recorded walking data rather than fixed in this document. *(Kesin filtre ve eşikler bu dokümanda sabitlenmek yerine kaydedilmiş yürüyüş verileriyle belirlenecektir.)*

---

# 41. Gravity in Accelerometer Measurements (İvmeölçer Ölçümlerinde Yerçekimi)

Raw Android accelerometer measurements include the effect of gravity. *(Ham Android ivmeölçer ölçümleri yerçekimi etkisini içerir.)*

NAVGUARD will therefore explicitly decide whether each downstream algorithm requires total measured acceleration or gravity-compensated acceleration. *(Bu nedenle NAVGUARD her aşağı akış algoritmasının toplam ölçülen ivmeye mi yoksa yerçekimi telafili ivmeye mi ihtiyaç duyduğuna açıkça karar verecektir.)*

Raw acceleration will always remain available. *(Ham ivme her zaman kullanılabilir kalacaktır.)*

---

# 42. Gravity Removal Strategies (Yerçekimi Kaldırma Stratejileri)

NAVGUARD may evaluate multiple gravity-removal approaches. *(NAVGUARD birden fazla yerçekimi kaldırma yaklaşımını değerlendirebilir.)*

The first approach may use an Android gravity estimate when available. *(İlk yaklaşım mevcut olduğunda Android yerçekimi tahminini kullanabilir.)*

A second approach may use low-pass estimation of the gravity component. *(İkinci yaklaşım yerçekimi bileşeninin low-pass tahminini kullanabilir.)*

A third approach may transform acceleration into a world frame using device orientation and explicitly subtract gravitational acceleration. *(Üçüncü yaklaşım ivmeyi cihaz yönelimini kullanarak dünya koordinat sistemine dönüştürebilir ve yerçekimi ivmesini açıkça çıkarabilir.)*

---

# 43. Gravity-Compensated Acceleration (Yerçekimi Telafili İvme)

Conceptually, gravity-compensated acceleration may be expressed as follows. *(Kavramsal olarak yerçekimi telafili ivme aşağıdaki şekilde ifade edilebilir.)*

```
a_linear = a_measured - g_estimated
```

The coordinate frame of both quantities must match before subtraction. *(Çıkarma işleminden önce her iki büyüklüğün koordinat sistemi eşleşmelidir.)*

Incorrect frame handling can create larger errors than the gravity-removal operation is intended to solve. *(Yanlış koordinat sistemi yönetimi yerçekimi kaldırma işleminin çözmeyi amaçladığından daha büyük hatalar oluşturabilir.)*

---

# 44. Android Linear Acceleration Comparison (Android Doğrusal İvme Karşılaştırması)

Android’s `TYPE_LINEAR_ACCELERATION` may be recorded as a comparison source when available. *(Android’in `TYPE_LINEAR_ACCELERATION` sensörü mevcut olduğunda karşılaştırma kaynağı olarak kaydedilebilir.)*

The project will compare this virtual output with NAVGUARD’s own gravity-removal approach before depending on it. *(Proje buna bağımlı olmadan önce bu sanal çıktıyı NAVGUARD’ın kendi yerçekimi kaldırma yaklaşımıyla karşılaştıracaktır.)*

No automatic superiority will be assumed. *(Otomatik üstünlük varsayılmayacaktır.)*

---

# 45. Gyroscope Bias Concept (Jiroskop Bias Kavramı)

A stationary gyroscope may report small non-zero angular velocities. *(Sabit bir jiroskop küçük sıfır olmayan açısal hızlar raporlayabilir.)*

Even small persistent offsets can accumulate into large orientation errors when integrated over time. *(Küçük kalıcı offset’ler bile zaman içinde integre edildiğinde büyük yönelim hatalarına birikebilir.)*

NAVGUARD will therefore estimate stationary gyroscope bias when suitable calibration data is available. *(Bu nedenle NAVGUARD uygun kalibrasyon verisi mevcut olduğunda sabit jiroskop bias’ını tahmin edecektir.)*

---

# 46. Gyroscope Bias Estimate (Jiroskop Bias Tahmini)

For a verified stationary interval, a simple initial bias estimate may use the mean angular velocity. *(Doğrulanmış sabit bir aralık için basit bir başlangıç bias tahmini ortalama açısal hızı kullanabilir.)*

```
b_g = mean(ω_stationary)
```

Corrected angular velocity may then be expressed as follows. *(Düzeltilmiş açısal hız daha sonra aşağıdaki şekilde ifade edilebilir.)*

```
ω_corrected = ω_raw - b_g
```

More advanced time-varying bias models will be considered only if measurements justify them. *(Daha gelişmiş zamana bağlı bias modelleri yalnızca ölçümler onları gerekçelendirirse değerlendirilecektir.)*

---

# 47. Bias Calibration Validity (Bias Kalibrasyonu Geçerliliği)

Bias estimation must use a verified stationary interval. *(Bias tahmini doğrulanmış sabit bir aralık kullanmalıdır.)*

The system must not estimate stationary bias while the user is moving. *(Sistem kullanıcı hareket ederken sabit durum bias’ı tahmin etmemelidir.)*

Calibration quality indicators may include acceleration stability and low gyroscope variance. *(Kalibrasyon kalite göstergeleri ivme kararlılığını ve düşük jiroskop varyansını içerebilir.)*

---

# 48. Accelerometer Bias Policy (İvmeölçer Bias Politikası)

The project may characterize accelerometer offsets during stationary tests. *(Proje sabit durum testleri sırasında ivmeölçer offset’lerini karakterize edebilir.)*

A full six-position IMU calibration is not mandatory for the minimum NAVGUARD prototype. *(Tam altı pozisyonlu IMU kalibrasyonu minimum NAVGUARD prototipi için zorunlu değildir.)*

Additional calibration complexity will be added only if experiments demonstrate measurable navigation benefit. *(Ek kalibrasyon karmaşıklığı yalnızca deneyler ölçülebilir navigasyon faydası gösterirse eklenecektir.)*

---

# 49. Magnetometer Calibration Policy (Manyetometre Kalibrasyon Politikası)

NAVGUARD will observe Android-reported magnetometer accuracy and measured field behavior. *(NAVGUARD Android tarafından bildirilen manyetometre doğruluğunu ve ölçülen alan davranışını gözlemleyecektir.)*

The project may prompt the user to perform device movement for magnetometer calibration when needed. *(Proje gerektiğinde kullanıcıdan manyetometre kalibrasyonu için cihaz hareketi yapmasını isteyebilir.)*

A custom hard-iron or soft-iron calibration model is not mandatory for the baseline prototype. *(Özel hard-iron veya soft-iron kalibrasyon modeli temel prototip için zorunlu değildir.)*

---

# 50. Magnetic Disturbance Detection (Manyetik Bozulma Tespiti)

Magnetometer quality analysis may use field magnitude, Android accuracy state, temporal variation, and consistency with gyroscope or rotation-vector heading. *(Manyetometre kalite analizi alan büyüklüğünü, Android doğruluk durumunu, zamansal değişimi ve jiroskop veya rotation-vector yönüyle tutarlılığı kullanabilir.)*

No single magnetic-magnitude threshold will be treated as universally valid before physical experiments. *(Fiziksel deneylerden önce tek bir manyetik büyüklük eşiği evrensel olarak geçerli kabul edilmeyecektir.)*

The result will later feed the Sensor Confidence and Quality Engine. *(Sonuç daha sonra Sensör Güven ve Kalite Motorunu besleyecektir.)*

---

# 51. Coordinate Frame Preparation (Koordinat Sistemi Hazırlığı)

Raw sensor measurements will initially remain in the Android device frame. *(Ham sensör ölçümleri başlangıçta Android cihaz koordinat sisteminde kalacaktır.)*

Navigation algorithms that require Earth-relative motion will transform measurements through an explicitly defined rotation. *(Dünya göreli hareket gerektiren navigasyon algoritmaları ölçümleri açıkça tanımlanmış bir dönüş üzerinden dönüştürecektir.)*

Detailed coordinate definitions will be frozen in **14 — Coordinate Systems & Mathematical Foundations**. *(Ayrıntılı koordinat tanımları **14 — Coordinate Systems & Mathematical Foundations** bölümünde sabitlenecektir.)*

---

# 52. Rotation Matrix Preparation (Dönüş Matrisi Hazırlığı)

A device-to-world rotation may be represented through a rotation matrix derived from a validated orientation estimate. *(Cihazdan dünyaya dönüş doğrulanmış bir yönelim tahmininden türetilen dönüş matrisiyle temsil edilebilir.)*

```
v_world = R_device_to_world · v_device
```

The orientation convention and multiplication order must be fixed and unit tested. *(Yönelim kuralı ve çarpım sırası sabitlenmeli ve birim test edilmelidir.)*

Frame-convention errors are considered a critical navigation risk. *(Koordinat sistemi kuralı hataları kritik navigasyon riski olarak kabul edilir.)*

---

# 53. Sensor Frame Versus Navigation Frame (Sensör Koordinat Sistemi ile Navigasyon Koordinat Sistemi)

The device frame moves with the smartphone. *(Cihaz koordinat sistemi akıllı telefonla birlikte hareket eder.)*

The local navigation frame remains referenced to the environment. *(Yerel navigasyon koordinat sistemi çevreye referanslı kalır.)*

NAVGUARD must therefore transform directional measurements appropriately before using them as east-north motion information. *(Bu nedenle NAVGUARD yönsel ölçümleri doğu-kuzey hareket bilgisi olarak kullanmadan önce uygun şekilde dönüştürmelidir.)*

---

# 54. Filtering Before or After Rotation (Dönüşten Önce veya Sonra Filtreleme)

Some filtering operations may be mathematically valid in either device or world coordinates. *(Bazı filtreleme işlemleri matematiksel olarak hem cihaz hem de dünya koordinatlarında geçerli olabilir.)*

The chosen processing order must nevertheless remain fixed for reproducibility. *(Buna rağmen seçilen işleme sırası tekrarlanabilirlik için sabit kalmalıdır.)*

NAVGUARD will not change preprocessing order between training and inference without creating a new preprocessing version. *(NAVGUARD yeni bir ön işleme sürümü oluşturmadan eğitim ve çıkarım arasında ön işleme sırasını değiştirmeyecektir.)*

---

# 55. Outlier Handling (Aykırı Değer Yönetimi)

Sensor preprocessing may detect physically implausible or numerically invalid values. *(Sensör ön işleme fiziksel olarak mantıksız veya sayısal olarak geçersiz değerleri tespit edebilir.)*

Outlier detection must not silently delete large portions of difficult but legitimate motion. *(Aykırı değer tespiti zor ancak geçerli hareketin büyük bölümlerini sessizce silmemelidir.)*

Every rejection rule must be documented and tested against real motion data. *(Her reddetme kuralı dokümante edilmeli ve gerçek hareket verisine karşı test edilmelidir.)*

---

# 56. NaN and Infinite Value Handling (NaN ve Sonsuz Değer Yönetimi)

Any NaN or infinite value entering the numerical navigation pipeline must be detected. *(Sayısal navigasyon hattına giren herhangi bir NaN veya sonsuz değer tespit edilmelidir.)*

The value must not propagate silently into PDR or EKF state. *(Değer PDR veya EKF durumuna sessizce yayılmamalıdır.)*

The corresponding event should be rejected or marked invalid while preserving diagnostic evidence. *(İlgili olay tanısal kanıt korunurken reddedilmeli veya geçersiz olarak işaretlenmelidir.)*

---

# 57. Missing Sensor Data (Eksik Sensör Verisi)

Missing measurements will remain explicitly missing until an approved preprocessing strategy handles them. *(Eksik ölçümler onaylanmış bir ön işleme stratejisi onları yönetene kadar açıkça eksik kalacaktır.)*

A zero value must not be used as a generic missing-value placeholder for numerical sensor channels. *(Sıfır değeri sayısal sensör kanalları için genel eksik değer yer tutucusu olarak kullanılmamalıdır.)*

This is critical because zero may be a physically valid measurement. *(Bu kritiktir çünkü sıfır fiziksel olarak geçerli bir ölçüm olabilir.)*

---

# 58. Resampled Missing-Value Mask (Yeniden Örneklenmiş Eksik Değer Maskesi)

AI or synchronized datasets may optionally include validity masks for channels containing unavailable values. *(Yapay zekâ veya senkronize veri setleri kullanılamayan değerler içeren kanallar için isteğe bağlı geçerlilik maskeleri içerebilir.)*

```
acc_valid
gyro_valid
mag_valid
orientation_valid
```

The final model should preferably avoid dependence on complex masking unless the collected data demonstrates a real need. *(Nihai model tercihen toplanan veri gerçek bir ihtiyaç göstermediği sürece karmaşık masking’e bağımlı olmamalıdır.)*

---

# 59. Standardization for Machine Learning (Makine Öğrenmesi İçin Standardizasyon)

Motion-classification inputs may require feature scaling or standardization. *(Hareket sınıflandırma girdileri özellik ölçekleme veya standardizasyon gerektirebilir.)*

A typical standardized channel may be calculated as follows. *(Tipik bir standardize edilmiş kanal aşağıdaki şekilde hesaplanabilir.)*

```
z = (x - μ_train) / σ_train
```

The mean and standard deviation must be calculated from the training partition only. *(Ortalama ve standart sapma yalnızca eğitim bölümünden hesaplanmalıdır.)*

Validation and test data must use the frozen training statistics. *(Doğrulama ve test verileri sabitlenmiş eğitim istatistiklerini kullanmalıdır.)*

---

# 60. No Dataset Leakage Through Preprocessing (Ön İşleme Yoluyla Veri Seti Sızıntısı Olmaması)

Global normalization statistics must not be calculated using test sessions. *(Global normalizasyon istatistikleri test oturumları kullanılarak hesaplanmamalıdır.)*

Filter parameters chosen based on final test performance must not be retrospectively optimized on the test set. *(Nihai test performansına göre seçilen filtre parametreleri test seti üzerinde geriye dönük olarak optimize edilmemelidir.)*

Preprocessing is part of the machine-learning experiment and is therefore subject to the same leakage controls as model training. *(Ön işleme makine öğrenmesi deneyinin bir parçasıdır ve bu nedenle model eğitimiyle aynı sızıntı kontrollerine tabidir.)*

---

# 61. Session-Wise Split Preservation (Oturum Bazlı Bölmenin Korunması)

Resampling and windowing must preserve the originating session identifier. *(Yeniden örnekleme ve pencereleme kaynak oturum tanımlayıcısını korumalıdır.)*

Windows from the same physical recording session must not be distributed across training and test partitions. *(Aynı fiziksel kayıt oturumundan gelen pencereler eğitim ve test bölümlerine dağıtılmamalıdır.)*

This requirement applies even when the windows do not overlap. *(Bu gereksinim pencereler örtüşmese bile geçerlidir.)*

---

# 62. AI Input Timeline (Yapay Zekâ Girdi Zaman Çizelgesi)

The motion model will receive uniformly structured windows rather than arbitrary event sequences. *(Hareket modeli keyfi olay dizileri yerine eşit yapıda pencereler alacaktır.)*

The initial candidate configuration may use a 50 Hz synchronized timeline. *(İlk aday yapılandırma 50 Hz senkronize zaman çizelgesi kullanabilir.)*

The exact frequency will be frozen after acquisition and model experiments. *(Kesin frekans veri toplama ve model deneylerinden sonra sabitlenecektir.)*

---

# 63. AI Window Length (Yapay Zekâ Pencere Uzunluğu)

A two-second input window at 50 Hz would contain 100 timesteps. *(50 Hz’de iki saniyelik bir girdi penceresi 100 timestep içerecektir.)*

```
2 s × 50 samples/s = 100 samples
```

This configuration is an initial candidate rather than a frozen requirement. *(Bu yapılandırma sabitlenmiş bir gereksinim yerine ilk adaydır.)*

Alternative window lengths will be compared experimentally. *(Alternatif pencere uzunlukları deneysel olarak karşılaştırılacaktır.)*

---

# 64. Window Overlap (Pencere Örtüşmesi)

Motion-classification windows may overlap to provide more frequent predictions. *(Hareket sınıflandırma pencereleri daha sık tahmin sağlamak için örtüşebilir.)*

For example, a two-second window may advance by a smaller stride. *(Örneğin iki saniyelik bir pencere daha küçük bir stride ile ilerleyebilir.)*

The final window length and stride will be part of the model configuration. *(Nihai pencere uzunluğu ve stride model yapılandırmasının bir parçası olacaktır.)*

---

# 65. Training and Mobile Window Equivalence (Eğitim ve Mobil Pencere Eşdeğerliği)

The mobile runtime must reconstruct AI windows using the same channel order and preprocessing rules used during training. *(Mobil çalışma zamanı yapay zekâ pencerelerini eğitim sırasında kullanılan aynı kanal sırası ve ön işleme kurallarıyla yeniden oluşturmalıdır.)*

A model trained with one sensor-channel order must not receive a different order on Android. *(Bir sensör kanal sırasıyla eğitilen model Android üzerinde farklı bir sıra almamalıdır.)*

The preprocessing configuration will therefore be versioned together with the AI model. *(Bu nedenle ön işleme yapılandırması yapay zekâ modeliyle birlikte sürümlenecektir.)*

---

# 66. Candidate AI Channels (Aday Yapay Zekâ Kanalları)

The initial motion-classification dataset may include accelerometer and gyroscope channels as the minimum candidate input set. *(İlk hareket sınıflandırma veri seti minimum aday girdi seti olarak ivmeölçer ve jiroskop kanallarını içerebilir.)*

Magnetometer channels may be evaluated as additional inputs. *(Manyetometre kanalları ek girdiler olarak değerlendirilebilir.)*

Derived magnitudes may also be compared against raw-axis-only configurations. *(Türetilmiş büyüklükler de yalnızca ham eksen kullanan yapılandırmalara karşı karşılaştırılabilir.)*

Additional channels will remain only if they provide measurable generalization benefit. *(Ek kanallar yalnızca ölçülebilir genelleme faydası sağlarlarsa kalacaktır.)*

---

# 67. AI Feature Engineering Policy (Yapay Zekâ Özellik Mühendisliği Politikası)

The primary 1D-CNN candidate may consume minimally processed time-series channels directly. *(Birincil 1D-CNN adayı minimum düzeyde işlenmiş zaman serisi kanallarını doğrudan kullanabilir.)*

Traditional machine-learning baselines may use engineered statistical and temporal features. *(Geleneksel makine öğrenmesi temel modelleri mühendislik ürünü istatistiksel ve zamansal özellikler kullanabilir.)*

Feature engineering must remain deterministic and versioned. *(Özellik mühendisliği deterministik ve sürümlenmiş kalmalıdır.)*

---

# 68. Candidate Statistical Features (Aday İstatistiksel Özellikler)

Traditional motion models may evaluate features such as mean, standard deviation, range, RMS, signal magnitude, peak count, and dominant frequency. *(Geleneksel hareket modelleri ortalama, standart sapma, aralık, RMS, sinyal büyüklüğü, peak sayısı ve baskın frekans gibi özellikleri değerlendirebilir.)*

Features will not be retained merely because they can be calculated. *(Özellikler yalnızca hesaplanabildikleri için tutulmayacaktır.)*

The final feature set will be selected through validation performance and mobile-computation cost. *(Nihai özellik seti doğrulama performansı ve mobil hesaplama maliyeti üzerinden seçilecektir.)*

---

# 69. PDR Preprocessing Path (PDR Ön İşleme Hattı)

The PDR preprocessing path will prioritize step timing, heading quality, and step-length inputs. *(PDR ön işleme hattı adım zamanlamasına, yön kalitesine ve adım uzunluğu girdilerine öncelik verecektir.)*

It will not require the exact same synchronized tensor used by the motion classifier. *(Hareket sınıflandırıcı tarafından kullanılan aynı senkronize tensöre ihtiyaç duymayacaktır.)*

This separation avoids forcing every navigation algorithm into an AI-oriented preprocessing format. *(Bu ayrım her navigasyon algoritmasını yapay zekâ odaklı bir ön işleme formatına zorlamayı önler.)*

---

# 70. Step Detection Timestamp Rule (Adım Tespit Zaman Damgası Kuralı)

Every detected step will receive a timestamp associated with the detected physical event. *(Tespit edilen her adım tespit edilen fiziksel olayla ilişkili bir zaman damgası alacaktır.)*

The step timestamp may correspond to the accepted acceleration peak or another precisely defined event location. *(Adım zaman damgası kabul edilen ivme peak’ine veya açıkça tanımlanmış başka bir olay konumuna karşılık gelebilir.)*

This rule will allow heading and step length to be evaluated at the appropriate time. *(Bu kural yön ve adım uzunluğunun uygun zamanda değerlendirilmesini sağlayacaktır.)*

---

# 71. Heading-at-Step Synchronization (Adım Anında Yön Senkronizasyonu)

PDR requires a heading estimate associated with each accepted step. *(PDR kabul edilen her adımla ilişkili bir yön tahminine ihtiyaç duyar.)*

If heading estimates are produced asynchronously, NAVGUARD will evaluate or interpolate heading at the step timestamp. *(Yön tahminleri asenkron olarak üretiliyorsa NAVGUARD adım zaman damgasında yönü değerlendirecek veya interpolate edecektir.)*

Angular wrap-around must be handled correctly. *(Açısal wrap-around doğru şekilde yönetilmelidir.)*

---

# 72. Angle Interpolation Problem (Açı Interpolasyonu Problemi)

Ordinary linear interpolation of heading degrees can fail around the 0°/360° boundary. *(Yön derecelerinin sıradan doğrusal interpolasyonu 0°/360° sınırı çevresinde başarısız olabilir.)*

For example, 359° and 1° should interpolate near 0° rather than 180°. *(Örneğin 359° ile 1° yaklaşık 0° civarında interpolate edilmelidir, 180° civarında değil.)*

Heading interpolation will therefore use circular-angle mathematics or orientation quaternions. *(Bu nedenle yön interpolasyonu dairesel açı matematiği veya yönelim quaternion’larını kullanacaktır.)*

---

# 73. Angle Normalization (Açı Normalizasyonu)

Heading angles will use one documented canonical interval. *(Yön açıları dokümante edilmiş tek bir kanonik aralık kullanacaktır.)*

A candidate representation is `[0°, 360°)`. *(Aday temsil `[0°, 360°)` aralığıdır.)*

Internal algorithms may use radians while presentation uses degrees. *(Dahili algoritmalar radyan kullanırken sunum derece kullanabilir.)*

Unit conversions must occur at explicit boundaries. *(Birim dönüşümleri açık sınırlarda gerçekleşmelidir.)*

---

# 74. Sensor Fusion Timing Principle (Sensör Füzyonu Zamanlama İlkesi)

The EKF or other fusion estimator will process measurements according to measurement timestamps rather than UI update order. *(EKF veya diğer füzyon tahmin motoru ölçümleri UI güncelleme sırası yerine ölçüm zaman damgalarına göre işleyecektir.)*

Prediction steps will account for actual elapsed time. *(Prediction adımları gerçek geçen süreyi dikkate alacaktır.)*

Measurement updates will use source-specific observation times whenever practical. *(Ölçüm güncellemeleri uygulanabilir olduğunda kaynağa özgü gözlem zamanlarını kullanacaktır.)*

---

# 75. Variable EKF Time Step (Değişken EKF Zaman Adımı)

The EKF must not assume that every update occurs exactly at the nominal sampling period. *(EKF her güncellemenin tam olarak nominal örnekleme periyodunda gerçekleştiğini varsaymamalıdır.)*

```
Δt = (t_k - t_(k-1)) × 10^-9
```

The state-transition model may therefore depend on the measured `Δt`. *(Bu nedenle durum geçiş modeli ölçülen `Δt` değerine bağlı olabilir.)*

Large abnormal `Δt` values must trigger diagnostic or recovery logic. *(Büyük anormal `Δt` değerleri tanısal veya geri kazanım mantığını tetiklemelidir.)*

---

# 76. Out-of-Order Measurement Policy (Sıra Dışı Ölçüm Politikası)

Asynchronous system boundaries may occasionally cause an event to be processed after a newer event has already arrived. *(Asenkron sistem sınırları zaman zaman daha yeni bir olay zaten geldikten sonra bir olayın işlenmesine neden olabilir.)*

NAVGUARD will detect such conditions through timestamps and sequence information. *(NAVGUARD bu koşulları zaman damgaları ve sıra bilgisi üzerinden tespit edecektir.)*

The final estimator policy may reject excessively late measurements or handle them through a bounded reordering buffer. *(Nihai tahmin motoru politikası aşırı geç ölçümleri reddedebilir veya sınırlı bir yeniden sıralama tamponuyla yönetebilir.)*

---

# 77. Reordering Buffer Candidate (Yeniden Sıralama Tamponu Adayı)

A small time-bounded reordering buffer may be evaluated if platform-boundary measurements arrive slightly out of order. *(Platform sınırı ölçümleri hafif sıra dışı ulaşıyorsa küçük zaman sınırlı bir yeniden sıralama tamponu değerlendirilebilir.)*

The buffer delay must remain small enough for real-time navigation. *(Tampon gecikmesi gerçek zamanlı navigasyon için yeterince küçük kalmalıdır.)*

The feature will not be introduced unless real measurements demonstrate a need. *(Özellik gerçek ölçümler ihtiyaç göstermediği sürece dahil edilmeyecektir.)*

---

# 78. Discontinuity Handling (Süreksizlik Yönetimi)

Unexpected large timing gaps, sensor restarts, ARCore tracking resets, and application lifecycle interruptions create discontinuities. *(Beklenmedik büyük zamanlama boşlukları, sensör yeniden başlatmaları, ARCore takip sıfırlamaları ve uygulama yaşam döngüsü kesintileri süreksizlikler oluşturur.)*

NAVGUARD will treat such discontinuities as explicit events rather than ordinary continuous samples. *(NAVGUARD bu süreksizlikleri normal sürekli örnekler yerine açık olaylar olarak ele alacaktır.)*

Filters and estimators may require reset or reinitialization after sufficiently large discontinuities. *(Filtreler ve tahmin motorları yeterince büyük süreksizliklerden sonra sıfırlama veya yeniden başlatma gerektirebilir.)*

---

# 79. Filter State Reset Policy (Filtre Durumu Sıfırlama Politikası)

A filter will not continue across an arbitrarily large sensor gap as though no interruption occurred. *(Bir filtre keyfi derecede büyük bir sensör boşluğu boyunca hiç kesinti olmamış gibi devam etmeyecektir.)*

Each stateful filter may define a maximum acceptable gap. *(Her durum tutan filtre maksimum kabul edilebilir boşluk tanımlayabilir.)*

Beyond this gap, filter state may be reinitialized using the next valid measurements. *(Bu boşluğun ötesinde filtre durumu sonraki geçerli ölçümler kullanılarak yeniden başlatılabilir.)*

---

# 80. AI Window Gap Policy (Yapay Zekâ Pencere Boşluğu Politikası)

An AI input window containing an unacceptable sensor gap will not be silently treated as a normal complete window. *(Kabul edilemez bir sensör boşluğu içeren yapay zekâ girdi penceresi sessizce normal tam pencere olarak ele alınmayacaktır.)*

The window may be rejected or marked invalid. *(Pencere reddedilebilir veya geçersiz olarak işaretlenebilir.)*

The final tolerance will depend on model robustness experiments. *(Nihai tolerans model dayanıklılığı deneylerine bağlı olacaktır.)*

---

# 81. Preprocessing Quality Flags (Ön İşleme Kalite Flag’leri)

Derived measurements may include quality metadata. *(Türetilmiş ölçümler kalite metadata bilgisi içerebilir.)*

```
VALID
INTERPOLATED
STALE
GAP_NEARBY
LOW_SENSOR_QUALITY
TRACKING_DEGRADED
INVALID
```

The exact representation will be frozen with the processed-data schema. *(Kesin temsil işlenmiş veri şemasıyla birlikte sabitlenecektir.)*

---

# 82. Provenance Tracking (Kaynak İzlenebilirliği)

Every major processed stream should identify the raw sources and preprocessing version used to create it. *(Her temel işlenmiş akış onu oluşturmak için kullanılan ham kaynakları ve ön işleme sürümünü tanımlamalıdır.)*

For example, a heading estimate may record whether it used gyroscope, magnetometer, rotation vector, or a subset. *(Örneğin bir yön tahmini jiroskop, manyetometre, rotation vector veya bunların bir alt kümesini kullanıp kullanmadığını kaydedebilir.)*

This supports later component-level analysis. *(Bu daha sonra bileşen seviyesinde analizi destekler.)*

---

# 83. Processed Data Schema Principle (İşlenmiş Veri Şeması İlkesi)

Processed files must clearly indicate their time basis and units. *(İşlenmiş dosyalar zaman temelini ve birimlerini açıkça belirtmelidir.)*

Processed timestamps should normally use the NAVGUARD common elapsed-realtime timeline. *(İşlenmiş zaman damgaları normalde NAVGUARD ortak elapsed-realtime zaman çizelgesini kullanmalıdır.)*

ARCore records should retain both original and mapped timestamps when synchronization has been applied. *(ARCore kayıtları senkronizasyon uygulandığında hem orijinal hem de eşlenmiş zaman damgalarını korumalıdır.)*

---

# 84. Example Synchronized IMU Schema (Örnek Senkronize IMU Şeması)

```
timestamp_ns,
acc_x,
acc_y,
acc_z,
gyro_x,
gyro_y,
gyro_z,
mag_x,
mag_y,
mag_z,
acc_valid,
gyro_valid,
mag_valid
```

This file would be processed data and must not replace the independently timestamped raw streams. *(Bu dosya işlenmiş veri olacaktır ve bağımsız zaman damgalı ham akışların yerini almamalıdır.)*

---

# 85. Preprocessing for Offline Replay (Çevrimdışı Replay İçin Ön İşleme)

Offline replay should be capable of starting from raw session recordings. *(Çevrimdışı replay ham oturum kayıtlarından başlayabilmelidir.)*

The same preprocessing version used by a benchmark must be reproducible offline. *(Bir benchmark tarafından kullanılan aynı ön işleme sürümü çevrimdışı olarak yeniden üretilebilir olmalıdır.)*

This allows algorithm changes to be tested without collecting the physical route again. *(Bu algoritma değişikliklerinin fiziksel rotayı tekrar toplamadan test edilmesine olanak sağlar.)*

---

# 86. Live and Offline Equivalence (Canlı ve Çevrimdışı Eşdeğerlik)

Where practical, live and offline preprocessing will share mathematically equivalent implementations. *(Uygulanabilir olduğu ölçüde canlı ve çevrimdışı ön işleme matematiksel olarak eşdeğer uygulamaları paylaşacaktır.)*

If Python and Dart or Kotlin implementations differ, deterministic reference tests will compare their outputs. *(Python ile Dart veya Kotlin uygulamaları farklıysa deterministik referans testleri çıktılarını karşılaştıracaktır.)*

Small floating-point differences may be tolerated within documented numerical limits. *(Küçük floating-point farkları dokümante edilmiş sayısal sınırlar içerisinde tolere edilebilir.)*

---

# 87. Cross-Language Reference Testing (Diller Arası Referans Testi)

Python may serve as the reference environment for complex preprocessing verification. *(Python karmaşık ön işleme doğrulaması için referans ortam olarak hizmet edebilir.)*

A fixed synthetic input sequence can be processed by Python and the mobile implementation. *(Sabit bir sentetik girdi dizisi Python ve mobil uygulama tarafından işlenebilir.)*

Outputs must agree within the defined numerical tolerance. *(Çıktılar tanımlanan sayısal tolerans içerisinde uyuşmalıdır.)*

---

# 88. Calibration Data Separation (Kalibrasyon Verisi Ayrımı)

Calibration measurements will be identifiable separately from active route measurements. *(Kalibrasyon ölçümleri aktif rota ölçümlerinden ayrı olarak tanımlanabilir olacaktır.)*

The system should record when calibration begins and ends. *(Sistem kalibrasyonun ne zaman başlayıp bittiğini kaydetmelidir.)*

Calibration samples may be retained in the raw session because they provide evidence for initialization values. *(Kalibrasyon örnekleri başlatma değerleri için kanıt sağladıkları için ham oturum içerisinde tutulabilir.)*

---

# 89. Pre-Denial Filter State (Kesinti Öncesi Filtre Durumu)

Filters used during the GNSS-denied phase should normally be initialized before the denial boundary. *(GNSS kesintili aşamada kullanılan filtreler normalde kesinti sınırından önce başlatılmalıdır.)*

The denial transition should not reset IMU filter state without a technical reason. *(Kesinti geçişi teknik bir neden olmadan IMU filtre durumunu sıfırlamamalıdır.)*

This preserves continuous motion interpretation across the transition. *(Bu geçiş boyunca sürekli hareket yorumunu korur.)*

---

# 90. GNSS Denial Timestamp Alignment (GNSS Kesinti Zaman Damgası Hizalama)

The exact time at which GNSS estimator access changes from ALLOWED to BLOCKED will be stored on the common monotonic timeline. *(GNSS tahmin motoru erişiminin ALLOWED durumundan BLOCKED durumuna geçtiği kesin zaman ortak monotonik zaman çizelgesinde saklanacaktır.)*

All sensor streams can therefore be separated into pre-denial and denied intervals using timestamps. *(Bu nedenle tüm sensör akışları zaman damgaları kullanılarak kesinti öncesi ve kesintili aralıklara ayrılabilir.)*

No sensor listener restart is required merely to mark this boundary. *(Yalnızca bu sınırı işaretlemek için sensör listener’ının yeniden başlatılması gerekmez.)*

---

# 91. Recovery Timestamp Alignment (Geri Kazanım Zaman Damgası Hizalama)

GNSS recovery events will also use the common monotonic timeline. *(GNSS geri kazanım olayları da ortak monotonik zaman çizelgesini kullanacaktır.)*

The estimator state immediately before correction must remain available for error analysis. *(Düzeltmeden hemen önceki tahmin motoru durumu hata analizi için kullanılabilir kalmalıdır.)*

The recovery event, GNSS measurement, pre-correction estimate, and relocalization action must be temporally distinguishable. *(Geri kazanım olayı, GNSS ölçümü, düzeltme öncesi tahmin ve yeniden konumlandırma işlemi zamansal olarak ayırt edilebilir olmalıdır.)*

---

# 92. Timing Precision Versus Accuracy (Zamanlama Hassasiyeti ile Doğruluğu Ayrımı)

Nanosecond timestamp representation does not imply nanosecond physical timing accuracy. *(Nanosaniye zaman damgası temsili nanosaniye fiziksel zamanlama doğruluğu anlamına gelmez.)*

Actual sensor and callback timing precision depends on hardware, Android scheduling, driver behavior, and subsystem implementation. *(Gerçek sensör ve callback zamanlama hassasiyeti donanıma, Android zamanlamasına, sürücü davranışına ve alt sistem uygulamasına bağlıdır.)*

NAVGUARD will therefore measure timing jitter instead of inferring precision from the timestamp unit. *(Bu nedenle NAVGUARD zaman damgası biriminden hassasiyet çıkarmak yerine zamanlama jitter’ını ölçecektir.)*

---

# 93. Timing Jitter Metrics (Zamanlama Jitter Metrikleri)

For each continuous stream, the project will calculate the distribution of inter-sample intervals. *(Her sürekli akış için proje örnekler arası aralıkların dağılımını hesaplayacaktır.)*

Useful statistics include median interval, standard deviation, percentile ranges, and maximum observed gaps. *(Kullanışlı istatistikler medyan aralığı, standart sapmayı, yüzdelik aralıklarını ve gözlemlenen maksimum boşlukları içerir.)*

These values will inform interpolation, gap-detection, and filtering decisions. *(Bu değerler interpolasyon, boşluk tespiti ve filtreleme kararlarını bilgilendirecektir.)*

---

# 94. Sampling Frequency Verification (Örnekleme Frekansı Doğrulaması)

The requested 50 Hz rate does not automatically mean the observed rate is exactly 50 Hz. *(Talep edilen 50 Hz hız, gözlemlenen hızın otomatik olarak tam 50 Hz olduğu anlamına gelmez.)*

NAVGUARD will calculate effective rates from measurement timestamps. *(NAVGUARD etkin hızları ölçüm zaman damgalarından hesaplayacaktır.)*

The frozen preprocessing frequency will be selected only after these measurements are reviewed. *(Sabitlenmiş ön işleme frekansı yalnızca bu ölçümler incelendikten sonra seçilecektir.)*

---

# 95. Downsampling Policy (Aşağı Örnekleme Politikası)

If a sensor produces data at a higher effective rate than required by an algorithm, the processed stream may be downsampled. *(Bir sensör bir algoritmanın gerektirdiğinden daha yüksek etkin hızda veri üretirse işlenmiş akış aşağı örneklenebilir.)*

Appropriate anti-alias filtering must be considered before significant downsampling. *(Önemli aşağı örneklemeden önce uygun anti-alias filtreleme değerlendirilmelidir.)*

Raw high-rate measurements will remain preserved. *(Ham yüksek hızlı ölçümler korunmaya devam edecektir.)*

---

# 96. Upsampling Policy (Yukarı Örnekleme Politikası)

Upsampling may create intermediate values required for a synchronized processing grid. *(Yukarı örnekleme senkronize bir işleme grid’i için gerekli ara değerleri oluşturabilir.)*

Upsampling does not increase the actual physical information content of the source sensor. *(Yukarı örnekleme kaynak sensörün gerçek fiziksel bilgi içeriğini artırmaz.)*

The synchronization system must therefore retain source-validity and interpolation metadata where relevant. *(Bu nedenle senkronizasyon sistemi ilgili olduğunda kaynak geçerliliği ve interpolasyon metadata bilgisini korumalıdır.)*

---

# 97. Frequency-Domain Analysis (Frekans Alanı Analizi)

Offline analysis may inspect frequency spectra of stationary and walking recordings. *(Çevrimdışı analiz sabit ve yürüyüş kayıtlarının frekans spektrumlarını inceleyebilir.)*

This analysis may inform filter cutoff selection and step-frequency assumptions. *(Bu analiz filtre cutoff seçimini ve adım frekansı varsayımlarını bilgilendirebilir.)*

Frequency-domain findings will not be assumed identical across all users or phone placements. *(Frekans alanı bulgularının tüm kullanıcılar veya telefon yerleşimleri için aynı olduğu varsayılmayacaktır.)*

---

# 98. Step Frequency Constraints (Adım Frekansı Kısıtları)

Reasonable human step cadence information may guide initial detector design. *(Makul insan adım kadansı bilgisi ilk algılayıcı tasarımını yönlendirebilir.)*

Final detector frequency ranges and refractory periods will be selected using NAVGUARD’s collected walking and running data. *(Nihai algılayıcı frekans aralıkları ve refractory süreleri NAVGUARD’ın topladığı yürüyüş ve koşu verileri kullanılarak seçilecektir.)*

No universal cadence threshold will be frozen before dataset inspection. *(Veri seti incelenmeden evrensel bir kadans eşiği sabitlenmeyecektir.)*

---

# 99. Motion Transition Handling (Hareket Geçişi Yönetimi)

Windows may contain transitions between stationary, walking, running, and turning. *(Pencereler sabit durma, yürüme, koşma ve dönme arasındaki geçişleri içerebilir.)*

The labeling policy must define how transition windows are treated. *(Etiketleme politikası geçiş pencerelerinin nasıl ele alınacağını tanımlamalıdır.)*

Ambiguous windows may be excluded from early supervised training or assigned according to a documented temporal rule. *(Belirsiz pencereler ilk supervised eğitimden çıkarılabilir veya dokümante edilmiş zamansal bir kurala göre atanabilir.)*

The final decision belongs to the dataset and ML documents. *(Nihai karar veri seti ve ML dokümanlarına aittir.)*

---

# 100. Step Length Feature Timing (Adım Uzunluğu Özellik Zamanlaması)

Step-length estimation may use features computed around each accepted step. *(Adım uzunluğu tahmini kabul edilen her adımın çevresinde hesaplanan özellikleri kullanabilir.)*

The feature window must be defined relative to the step timestamp. *(Özellik penceresi adım zaman damgasına göre tanımlanmalıdır.)*

Future information must not be used in real-time prediction unless the deployment design deliberately accepts the associated latency. *(Dağıtım tasarımı ilişkili gecikmeyi bilinçli olarak kabul etmediği sürece gerçek zamanlı tahminde gelecekteki bilgi kullanılmamalıdır.)*

---

# 101. Real-Time Latency Budget (Gerçek Zamanlı Gecikme Bütçesi)

Every preprocessing stage introduces computational or buffering latency. *(Her ön işleme aşaması hesaplama veya tamponlama gecikmesi oluşturur.)*

NAVGUARD will measure the combined delay between physical measurement time and availability of high-level navigation output. *(NAVGUARD fiziksel ölçüm zamanı ile yüksek seviyeli navigasyon çıktısının kullanılabilir hale gelmesi arasındaki birleşik gecikmeyi ölçecektir.)*

The final pipeline will balance noise reduction, AI window length, synchronization quality, and responsiveness. *(Nihai hat gürültü azaltma, yapay zekâ pencere uzunluğu, senkronizasyon kalitesi ve tepki verebilirlik arasında denge kuracaktır.)*

---

# 102. Processing Timestamp Model (İşleme Zaman Damgası Modeli)

Derived records may retain both source measurement time and computation completion time. *(Türetilmiş kayıtlar hem kaynak ölçüm zamanını hem de hesaplama tamamlanma zamanını koruyabilir.)*

```
source_timestamp_ns
processed_timestamp_ns
```

The source timestamp determines where the observation belongs in the navigation timeline. *(Kaynak zaman damgası gözlemin navigasyon zaman çizelgesinde nereye ait olduğunu belirler.)*

The processed timestamp supports latency diagnostics. *(İşlenmiş zaman damgası gecikme tanısını destekler.)*

---

# 103. AI Prediction Timestamp (Yapay Zekâ Tahmin Zaman Damgası)

An AI prediction generated from a window must have a clearly defined semantic timestamp. *(Bir pencereden üretilen yapay zekâ tahmini açıkça tanımlanmış anlamsal bir zaman damgasına sahip olmalıdır.)*

The prediction may represent the end, center, or another defined reference point of the input window. *(Tahmin girdi penceresinin sonunu, merkezini veya başka bir tanımlanmış referans noktasını temsil edebilir.)*

The chosen convention must remain identical between training evaluation and mobile inference. *(Seçilen kural eğitim değerlendirmesi ile mobil çıkarım arasında aynı kalmalıdır.)*

---

# 104. Recommended AI Timestamp Convention (Önerilen Yapay Zekâ Zaman Damgası Kuralı)

For real-time inference, the initial preferred convention is to associate the prediction with the end of the completed input window. *(Gerçek zamanlı çıkarım için başlangıçta tercih edilen kural tahmini tamamlanmış girdi penceresinin sonuyla ilişkilendirmektir.)*

This avoids assigning the prediction to a future time relative to the data available to the device. *(Bu tahminin cihazda mevcut veriye göre gelecekteki bir zamana atanmasını önler.)*

The convention may be revised if experimental analysis identifies a better definition. *(Deneysel analiz daha iyi bir tanım belirlerse kural değiştirilebilir.)*

---

# 105. Heading Filter Timing (Yön Filtresi Zamanlaması)

Gyroscope integration and heading correction must use actual time intervals. *(Jiroskop integrasyonu ve yön düzeltmesi gerçek zaman aralıklarını kullanmalıdır.)*

A basic yaw propagation relation may conceptually be expressed as follows. *(Temel yaw ilerletme ilişkisi kavramsal olarak aşağıdaki şekilde ifade edilebilir.)*

```
ψ_k = ψ_(k-1) + ω_z · Δt
```

The actual implementation will account for coordinate orientation and full device attitude rather than blindly applying one raw axis in every phone pose. *(Gerçek uygulama her telefon pozunda körlemesine tek bir ham ekseni kullanmak yerine koordinat yönelimini ve tam cihaz attitude bilgisini dikkate alacaktır.)*

---

# 106. Sensor Fusion Without Artificial Simultaneity (Yapay Eşzamanlılık Olmadan Sensör Füzyonu)

NAVGUARD will not force every measurement into one row before it can be used by sensor fusion. *(NAVGUARD sensör füzyonunda kullanılmadan önce her ölçümü tek bir satıra zorlamayacaktır.)*

The final EKF may process asynchronous measurements whenever they arrive with valid timestamps. *(Nihai EKF geçerli zaman damgalarıyla ulaştıklarında asenkron ölçümleri işleyebilir.)*

Uniform resampling will primarily be used where a consumer genuinely requires it. *(Eşit aralıklı yeniden örnekleme temel olarak bir tüketici gerçekten ihtiyaç duyduğunda kullanılacaktır.)*

---

# 107. Timestamp Precision Storage (Zaman Damgası Hassasiyeti Depolama)

Nanosecond timestamps will be stored using 64-bit integer representations. *(Nanosaniye zaman damgaları 64-bit integer temsilleri kullanılarak saklanacaktır.)*

They must not be converted prematurely to low-precision floating-point seconds for authoritative storage. *(Ana depolama için erken şekilde düşük hassasiyetli floating-point saniyelere dönüştürülmemelidir.)*

Relative seconds may be calculated later for visualization and numerical analysis. *(Göreli saniyeler daha sonra görselleştirme ve sayısal analiz için hesaplanabilir.)*

---

# 108. Floating-Point Time Conversion (Floating-Point Zaman Dönüşümü)

When algorithms require seconds, relative time should preferably be computed before conversion to floating point. *(Algoritmalar saniye gerektirdiğinde floating point dönüşümünden önce tercihen göreli zaman hesaplanmalıdır.)*

```
Δt_seconds = (timestamp_ns - reference_ns) / 1e9
```

This reduces unnecessary precision loss from representing very large absolute nanosecond values as floating-point numbers. *(Bu çok büyük mutlak nanosaniye değerlerinin floating-point sayılar olarak temsil edilmesinden kaynaklanan gereksiz hassasiyet kaybını azaltır.)*

---

# 109. Synchronization Quality Metrics (Senkronizasyon Kalite Metrikleri)

NAVGUARD will measure synchronization quality where multiple time domains are mapped. *(NAVGUARD birden fazla zaman alanının eşlendiği yerlerde senkronizasyon kalitesini ölçecektir.)*

ARCore mapping metrics may include offset median, offset standard deviation, maximum residual, and drift trend. *(ARCore eşleme metrikleri offset medyanını, offset standart sapmasını, maksimum residual değerini ve drift trendini içerebilir.)*

These metrics will determine whether the mapped stream is suitable for fusion. *(Bu metrikler eşlenmiş akışın füzyon için uygun olup olmadığını belirleyecektir.)*

---

# 110. Synchronization Confidence (Senkronizasyon Güveni)

A synchronized measurement may carry a timing-confidence indicator when the source clock required mapping. *(Senkronize bir ölçüm kaynak saati eşleme gerektirdiğinde zamanlama güven göstergesi taşıyabilir.)*

ARCore timing confidence may decrease when reception latency becomes unstable or when the clock mapping residual increases. *(ARCore zamanlama güveni alım gecikmesi kararsız hale geldiğinde veya saat eşleme residual değeri arttığında düşebilir.)*

Timing confidence may later contribute to fusion measurement weighting. *(Zamanlama güveni daha sonra füzyon ölçüm ağırlıklandırmasına katkıda bulunabilir.)*

---

# 111. Online Versus Offline Synchronization (Çevrimiçi ve Çevrimdışı Senkronizasyon)

The live mobile system requires an online synchronization method that uses only information available up to the current time. *(Canlı mobil sistem yalnızca mevcut zamana kadar kullanılabilir bilgiyi kullanan çevrimiçi bir senkronizasyon yöntemi gerektirir.)*

Offline analysis may use the entire recorded session to estimate a more accurate clock mapping. *(Çevrimdışı analiz daha doğru bir saat eşlemesi tahmin etmek için tüm kaydedilmiş oturumu kullanabilir.)*

Offline-refined results must be distinguished from the synchronization method actually available during live navigation. *(Çevrimdışı iyileştirilmiş sonuçlar canlı navigasyon sırasında gerçekten kullanılabilir senkronizasyon yönteminden ayırt edilmelidir.)*

---

# 112. Real-Time ARCore Clock Calibration (Gerçek Zamanlı ARCore Saat Kalibrasyonu)

The live ARCore clock mapper may use a short initialization window to estimate the current time offset. *(Canlı ARCore saat eşleyicisi mevcut zaman offset’ini tahmin etmek için kısa bir başlatma penceresi kullanabilir.)*

The mapper may update the offset gradually if long-session measurements show stable drift. *(Uzun oturum ölçümleri kararlı drift gösterirse eşleyici offset’i kademeli olarak güncelleyebilir.)*

The mapping must not jump abruptly because of one delayed frame callback. *(Eşleme tek bir gecikmiş kare callback’i nedeniyle aniden sıçramamalıdır.)*

---

# 113. Preprocessing Configuration Snapshot (Ön İşleme Yapılandırma Anlık Görüntüsü)

Every formal benchmark session should reference the active preprocessing configuration. *(Her resmî benchmark oturumu aktif ön işleme yapılandırmasına referans vermelidir.)*

A configuration may include the following fields. *(Bir yapılandırma aşağıdaki alanları içerebilir.)*

```
preprocessingVersion
targetSamplingHz
interpolationMethod
maxInterpolationGapMs
accFilterConfig
gyroFilterConfig
magFilterConfig
gravityRemovalMethod
gyroBiasMethod
orientationSource
normalizationId
aiWindowLength
aiWindowStride
```

---

# 114. Parameter Freeze Policy (Parametre Sabitleme Politikası)

Preprocessing parameters may be tuned using development and validation recordings. *(Ön işleme parametreleri geliştirme ve doğrulama kayıtları kullanılarak ayarlanabilir.)*

They must be frozen before final benchmark evaluation. *(Nihai benchmark değerlendirmesinden önce sabitlenmelidir.)*

Parameters must not be changed after observing final benchmark errors merely to improve the reported result. *(Parametreler yalnızca raporlanan sonucu iyileştirmek amacıyla nihai benchmark hataları gözlemlendikten sonra değiştirilmemelidir.)*

---

# 115. Preprocessing Experiment Matrix (Ön İşleme Deney Matrisi)

Candidate preprocessing configurations may be compared systematically. *(Aday ön işleme yapılandırmaları sistematik olarak karşılaştırılabilir.)*

Examples may include alternative filter types, cutoff frequencies, gravity-removal methods, and resampling frequencies. *(Örnekler alternatif filtre türlerini, cutoff frekanslarını, yerçekimi kaldırma yöntemlerini ve yeniden örnekleme frekanslarını içerebilir.)*

Only a manageable number of justified alternatives should be tested within the 24-day project schedule. *(24 günlük proje takvimi içerisinde yalnızca yönetilebilir sayıda gerekçelendirilmiş alternatif test edilmelidir.)*

---

# 116. Preprocessing Test Data (Ön İşleme Test Verisi)

Synthetic signals will be used for deterministic unit tests. *(Sentetik sinyaller deterministik birim testleri için kullanılacaktır.)*

Recorded stationary data will be used for noise and bias tests. *(Kaydedilmiş sabit durum verisi gürültü ve bias testleri için kullanılacaktır.)*

Recorded walking and turning data will be used for practical signal-processing validation. *(Kaydedilmiş yürüyüş ve dönüş verisi pratik sinyal işleme doğrulaması için kullanılacaktır.)*

---

# 117. Synchronization Unit Tests (Senkronizasyon Birim Testleri)

The synchronization system must correctly handle equal timestamps. *(Senkronizasyon sistemi eşit zaman damgalarını doğru şekilde yönetmelidir.)*

The synchronization system must correctly interpolate between known samples. *(Senkronizasyon sistemi bilinen örnekler arasında doğru şekilde interpolasyon yapmalıdır.)*

The synchronization system must reject interpolation across excessive gaps. *(Senkronizasyon sistemi aşırı boşluklar boyunca interpolasyonu reddetmelidir.)*

The synchronization system must handle missing channels. *(Senkronizasyon sistemi eksik kanalları yönetmelidir.)*

The synchronization system must preserve monotonic output timestamps. *(Senkronizasyon sistemi monotonik çıktı zaman damgalarını korumalıdır.)*

---

# 118. Quaternion Processing Tests (Quaternion İşleme Testleri)

Quaternion normalization will be unit tested. *(Quaternion normalizasyonu birim test edilecektir.)*

Quaternion interpolation will be tested across ordinary rotations and wrap-around cases. *(Quaternion interpolasyonu normal dönüşler ve wrap-around durumları üzerinde test edilecektir.)*

Known rotations will be used to verify device-to-world transformation conventions. *(Bilinen dönüşler cihazdan dünyaya dönüşüm kurallarını doğrulamak için kullanılacaktır.)*

---

# 119. Filter Tests (Filtre Testleri)

Filters will be tested against constant signals. *(Filtreler sabit sinyallere karşı test edilecektir.)*

Filters will be tested against impulses or controlled synthetic transitions. *(Filtreler impulse veya kontrollü sentetik geçişlere karşı test edilecektir.)*

State reset after large timing gaps will be tested explicitly. *(Büyük zamanlama boşluklarından sonra durum sıfırlaması açıkça test edilecektir.)*

---

# 120. Preprocessing Performance Test (Ön İşleme Performans Testi)

The final mobile preprocessing pipeline must be profiled under the expected sensor workload. *(Nihai mobil ön işleme hattı beklenen sensör iş yükü altında profillenmelidir.)*

The test will measure processing latency, CPU load, memory usage, and queue stability. *(Test işleme gecikmesini, CPU yükünü, bellek kullanımını ve kuyruk kararlılığını ölçecektir.)*

If Dart preprocessing creates a demonstrated bottleneck, selected operations may move to the native layer. *(Dart ön işleme kanıtlanmış bir darboğaz oluşturursa seçilen işlemler native katmana taşınabilir.)*

---

# 121. Preprocessing Failure Handling (Ön İşleme Hata Yönetimi)

A preprocessing failure must not modify or destroy the raw session evidence. *(Bir ön işleme hatası ham oturum kanıtını değiştirmemeli veya yok etmemelidir.)*

The affected processed output may be marked invalid and regenerated later. *(Etkilenen işlenmiş çıktı geçersiz olarak işaretlenebilir ve daha sonra yeniden oluşturulabilir.)*

This is one of the primary reasons raw and processed datasets remain separated. *(Bu ham ve işlenmiş veri setlerinin ayrı tutulmasının temel nedenlerinden biridir.)*

---

# 122. Online Processing Degradation (Çevrimiçi İşleme Bozulması)

If live preprocessing cannot keep pace with acquisition, NAVGUARD must surface the overload condition. *(Canlı ön işleme veri toplamaya yetişemezse NAVGUARD aşırı yük durumunu görünür hale getirmelidir.)*

The application must not allow unlimited queue growth. *(Uygulama sınırsız kuyruk büyümesine izin vermemelidir.)*

UI visualization frequency should be reduced before scientifically important raw acquisition is sacrificed. *(Bilimsel olarak önemli ham veri toplama feda edilmeden önce UI görselleştirme frekansı azaltılmalıdır.)*

---

# 123. Processing Priority (İşleme Önceliği)

The primary runtime priority order will be preservation of critical measurements, navigation estimation, required logging, and then optional visualization. *(Temel çalışma zamanı öncelik sırası kritik ölçümlerin korunması, navigasyon tahmini, gerekli kayıt ve ardından isteğe bağlı görselleştirme olacaktır.)*

Cosmetic UI updates must not receive higher priority than acquisition integrity. *(Kozmetik UI güncellemeleri veri toplama bütünlüğünden daha yüksek öncelik almamalıdır.)*

---

# 124. Preprocessing Security and Privacy (Ön İşleme Güvenlik ve Gizlilik)

Preprocessing will occur locally for the core NAVGUARD workflow. *(Ön işleme temel NAVGUARD iş akışı için yerel olarak gerçekleştirilecektir.)*

Raw sensor and location measurements will not require transmission to a cloud processing service. *(Ham sensör ve konum ölçümleri bir bulut işleme hizmetine iletilmeyi gerektirmeyecektir.)*

This preserves the project’s offline-first architecture. *(Bu projenin çevrimdışı öncelikli mimarisini korur.)*

---

# 125. Minimum Preprocessing Pipeline (Minimum Ön İşleme Hattı)

The minimum accepted preprocessing pipeline will include timestamp integrity checking. *(Minimum kabul edilen ön işleme hattı zaman damgası bütünlük kontrolünü içerecektir.)*

It will include actual `Δt` calculation. *(Gerçek `Δt` hesaplamasını içerecektir.)*

It will include baseline acceleration filtering for step detection. *(Adım tespiti için temel ivme filtrelemeyi içerecektir.)*

It will include the orientation preparation required for heading estimation. *(Yön tahmini için gerekli yönelim hazırlığını içerecektir.)*

It will preserve raw data separately from processed output. *(Ham veriyi işlenmiş çıktıdan ayrı olarak koruyacaktır.)*

---

# 126. Target Preprocessing Pipeline (Hedef Ön İşleme Hattı)

The target preprocessing pipeline will additionally provide multi-stream resampling for AI. *(Hedef ön işleme hattı ayrıca yapay zekâ için çoklu akış yeniden örnekleme sağlayacaktır.)*

It will provide calibrated gyroscope correction. *(Kalibre edilmiş jiroskop düzeltmesi sağlayacaktır.)*

It will provide validated device-to-navigation coordinate transformation. *(Doğrulanmış cihazdan navigasyon koordinatına dönüşüm sağlayacaktır.)*

It will provide ARCore timestamp mapping. *(ARCore zaman damgası eşleme sağlayacaktır.)*

It will provide quality and validity metadata for downstream fusion. *(Aşağı akış füzyonu için kalite ve geçerlilik metadata bilgisi sağlayacaktır.)*

---

# 127. Preprocessing Non-Goals (Ön İşleme Olmayan Hedefler)

The preprocessing layer will not decide the final user position. *(Ön işleme katmanı nihai kullanıcı konumuna karar vermeyecektir.)*

The preprocessing layer will not decide whether GNSS is allowed into the estimator. *(Ön işleme katmanı GNSS’in tahmin motoruna girip giremeyeceğine karar vermeyecektir.)*

The preprocessing layer will not label AI predictions as ground truth. *(Ön işleme katmanı yapay zekâ tahminlerini gerçek referans olarak etiketlemeyecektir.)*

The preprocessing layer will prepare reliable, traceable numerical inputs for the algorithms that perform those responsibilities. *(Ön işleme katmanı bu sorumlulukları gerçekleştiren algoritmalar için güvenilir ve izlenebilir sayısal girdiler hazırlayacaktır.)*

---

# 128. Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kararlar)

Android sensor and GNSS measurements will use the common elapsed-realtime monotonic domain whenever the platform provides it. *(Android sensör ve GNSS ölçümleri platform sağladığında ortak elapsed-realtime monotonik alanını kullanacaktır.)*

ARCore will remain a separately mapped time domain until synchronization is validated. *(ARCore senkronizasyon doğrulanana kadar ayrı eşlenen bir zaman alanı olarak kalacaktır.)*

Raw streams will remain independently timestamped and immutable. *(Ham akışlar bağımsız zaman damgalı ve değiştirilemez kalacaktır.)*

Uniform resampling will be consumer-specific rather than mandatory for every navigation component. *(Eşit aralıklı yeniden örnekleme her navigasyon bileşeni için zorunlu olmak yerine tüketiciye özgü olacaktır.)*

Actual `Δt` values will be used in timing-sensitive navigation calculations. *(Zamanlamaya duyarlı navigasyon hesaplamalarında gerçek `Δt` değerleri kullanılacaktır.)*

AI preprocessing will be identical or mathematically equivalent between training and deployment. *(Yapay zekâ ön işleme eğitim ve dağıtım arasında aynı veya matematiksel olarak eşdeğer olacaktır.)*

---

# 129. Decisions Pending Measurement (Ölçüm Bekleyen Kararlar)

The final uniform processing frequency remains pending physical-device measurements. *(Nihai eşit aralıklı işleme frekansı fiziksel cihaz ölçümlerini beklemektedir.)*

The final accelerometer step-filter design remains pending recorded walking analysis. *(Nihai ivmeölçer adım filtresi tasarımı kaydedilmiş yürüyüş analizini beklemektedir.)*

The final gravity-removal strategy remains pending comparison experiments. *(Nihai yerçekimi kaldırma stratejisi karşılaştırma deneylerini beklemektedir.)*

The final magnetometer-quality thresholds remain pending field measurements. *(Nihai manyetometre kalite eşikleri saha ölçümlerini beklemektedir.)*

The final ARCore clock-mapping method remains pending Redmi Note 9 Pro synchronization tests. *(Nihai ARCore saat eşleme yöntemi Redmi Note 9 Pro senkronizasyon testlerini beklemektedir.)*

The final AI window length and stride remain pending model experiments. *(Nihai yapay zekâ pencere uzunluğu ve stride model deneylerini beklemektedir.)*

---

# 130. Timing Integrity Acceptance Criteria (Zamanlama Bütünlüğü Kabul Kriterleri)

Android IMU streams must preserve `SensorEvent.timestamp`. *(Android IMU akışları `SensorEvent.timestamp` değerini korumalıdır.)*

GNSS streams must preserve `Location.getElapsedRealtimeNanos()`. *(GNSS akışları `Location.getElapsedRealtimeNanos()` değerini korumalıdır.)*

The system must detect non-monotonic timestamps. *(Sistem monotonik olmayan zaman damgalarını tespit etmelidir.)*

The system must detect excessive timing gaps. *(Sistem aşırı zamanlama boşluklarını tespit etmelidir.)*

Synchronized data must remain traceable to the raw source streams. *(Senkronize veri ham kaynak akışlarına kadar izlenebilir kalmalıdır.)*

---

# 131. Preprocessing Acceptance Criteria (Ön İşleme Kabul Kriterleri)

The preprocessing pipeline must produce deterministic output for identical raw data and identical configuration. *(Ön işleme hattı aynı ham veri ve aynı yapılandırma için deterministik çıktı üretmelidir.)*

Raw data must remain unchanged after preprocessing. *(Ham veri ön işlemeden sonra değişmeden kalmalıdır.)*

Interpolation must not silently bridge invalid large gaps. *(Interpolasyon geçersiz büyük boşlukları sessizce köprülememelidir.)*

Training and mobile AI preprocessing must use equivalent rules. *(Eğitim ve mobil yapay zekâ ön işleme eşdeğer kurallar kullanmalıdır.)*

Preprocessing parameters used by final benchmarks must be versioned and frozen. *(Nihai benchmark’larda kullanılan ön işleme parametreleri sürümlenmeli ve sabitlenmelidir.)*

---

# 132. Source Basis (Kaynak Temeli)

The Android IMU timing model is based on the official `SensorEvent` documentation, which defines sensor timestamps using the elapsed-realtime nanosecond time base. *(Android IMU zamanlama modeli, sensör zaman damgalarını elapsed-realtime nanosaniye zaman tabanı kullanarak tanımlayan resmî `SensorEvent` dokümantasyonuna dayanmaktadır.)*

The GNSS timing model is based on the official Android `Location` documentation, which defines `getElapsedRealtimeNanos()` as monotonic elapsed realtime since system boot. *(GNSS zamanlama modeli, `getElapsedRealtimeNanos()` değerini sistem açılışından itibaren geçen monotonik süre olarak tanımlayan resmî Android `Location` dokümantasyonuna dayanmaktadır.)*

The ARCore timing policy is based on the official ARCore `Frame` documentation, which states that `getTimestamp()` is expressed in nanoseconds but does not formally define its time base. *(ARCore zamanlama politikası, `getTimestamp()` değerinin nanosaniye cinsinden olduğunu ancak zaman tabanını resmî olarak tanımlamadığını belirten resmî ARCore `Frame` dokümantasyonuna dayanmaktadır.)*

---

# 133. Final Timing and Preprocessing Statement (Nihai Zamanlama ve Ön İşleme Bildirimi)

**NAVGUARD will preserve independently timestamped raw sensor streams and map all compatible Android sensor and GNSS measurements onto a common elapsed-realtime session timeline without modifying the original evidence.** *(NAVGUARD bağımsız zaman damgalı ham sensör akışlarını koruyacak ve uyumlu tüm Android sensör ve GNSS ölçümlerini orijinal kanıtı değiştirmeden ortak bir elapsed-realtime oturum zaman çizelgesine eşleyecektir.)*

**ARCore will be treated as a separate clock domain until its relationship with the Android monotonic timeline has been experimentally measured and validated on the Redmi Note 9 Pro.** *(ARCore, Android monotonik zaman çizelgesiyle ilişkisi Redmi Note 9 Pro üzerinde deneysel olarak ölçülüp doğrulanana kadar ayrı bir saat alanı olarak ele alınacaktır.)*

**Uniform resampling will be used only when required by a downstream consumer such as the motion-classification model, while event-driven navigation algorithms may continue to use original measurement timestamps.** *(Eşit aralıklı yeniden örnekleme yalnızca hareket sınıflandırma modeli gibi aşağı akış bir tüketici gerektirdiğinde kullanılacak, olay güdümlü navigasyon algoritmaları ise orijinal ölçüm zaman damgalarını kullanmaya devam edebilecektir.)*

**Filtering, gravity removal, bias correction, interpolation, coordinate transformation, normalization, and window construction will produce versioned processed data while immutable raw recordings remain available for replay and reproducibility.** *(Filtreleme, yerçekimi kaldırma, bias düzeltme, interpolasyon, koordinat dönüşümü, normalizasyon ve pencere oluşturma sürümlenmiş işlenmiş veri üretirken değiştirilemez ham kayıtlar replay ve tekrarlanabilirlik için kullanılabilir kalacaktır.)*

---

# 134. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development Timing, Synchronization, and Preprocessing Baseline Completed *(Doküman Durumu: Geliştirme Öncesi Zamanlama, Senkronizasyon ve Ön İşleme Temel Referansı Tamamlandı)*

**Primary Common Time Base:** Android Elapsed Realtime in Nanoseconds *(Temel Ortak Zaman Tabanı: Nanosaniye Cinsinden Android Elapsed Realtime)*

**IMU Timing Source:** `SensorEvent.timestamp` *(IMU Zamanlama Kaynağı: `SensorEvent.timestamp`)*

**GNSS Timing Source:** `Location.getElapsedRealtimeNanos()` *(GNSS Zamanlama Kaynağı: `Location.getElapsedRealtimeNanos()`)*

**ARCore Timing:** Separate Clock Domain Pending Validation *(ARCore Zamanlaması: Doğrulama Bekleyen Ayrı Saat Alanı)*

**Raw Stream Policy:** Immutable and Independently Timestamped *(Ham Akış Politikası: Değiştirilemez ve Bağımsız Zaman Damgalı)*

**Uniform Resampling:** Consumer-Specific *(Eşit Aralıklı Yeniden Örnekleme: Tüketiciye Özgü)*

**Initial AI Timeline Candidate:** Approximately 50 Hz *(İlk Yapay Zekâ Zaman Çizelgesi Adayı: Yaklaşık 50 Hz)*

**Initial AI Window Candidate:** Approximately 2 Seconds / 100 Samples at 50 Hz *(İlk Yapay Zekâ Pencere Adayı: 50 Hz’de Yaklaşık 2 Saniye / 100 Örnek)*

**Filter Parameters:** Pending Physical Data Analysis *(Filtre Parametreleri: Fiziksel Veri Analizi Bekleniyor)*

**Gravity Removal Method:** Pending Comparison *(Yerçekimi Kaldırma Yöntemi: Karşılaştırma Bekleniyor)*

**ARCore Clock Mapping:** Pending Physical Device Validation *(ARCore Saat Eşleme: Fiziksel Cihaz Doğrulaması Bekleniyor)*

**Next Documentation Item:** 14 — Coordinate Systems & Mathematical Foundations *(Sonraki Dokümantasyon Öğesi: 14 — Koordinat Sistemleri ve Matematiksel Temeller)*