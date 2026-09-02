# 29 — GNSS Recovery & Relocalization (GNSS Geri Kazanımı ve Yeniden Konumlandırma)

## 1. Document Purpose (Dokümanın Amacı)

This document defines how NAVGUARD detects GNSS recovery, validates candidate recovery fixes, preserves pre-correction estimator evidence, calculates recovery error, decides whether correction is permitted, performs controlled relocalization, manages covariance, preserves historical trajectory integrity, handles failed recovery attempts, restores GNSS estimator access, and records every recovery event reproducibly. *(Bu doküman NAVGUARD'ın GNSS geri kazanımını nasıl tespit ettiğini, aday geri kazanım fix'lerini nasıl doğruladığını, düzeltme öncesi tahmin motoru kanıtını nasıl koruduğunu, recovery hatasını nasıl hesapladığını, düzeltmeye izin verilip verilmediğine nasıl karar verdiğini, kontrollü yeniden konumlandırmayı nasıl gerçekleştirdiğini, kovaryansı nasıl yönettiğini, geçmiş trajectory bütünlüğünü nasıl koruduğunu, başarısız recovery denemelerini nasıl yönettiğini, GNSS tahmin motoru erişimini nasıl geri açtığını ve her recovery olayını nasıl tekrarlanabilir şekilde kaydettiğini tanımlar.)*

GNSS recovery is treated as a controlled state transition rather than an immediate switch from dead reckoning to the first available GNSS coordinate. *(GNSS geri kazanımı dead reckoning'den kullanılabilir ilk GNSS koordinatına anında geçiş yerine kontrollü bir durum geçişi olarak ele alınır.)*

---

# 2. Core Recovery Principle (Temel Recovery İlkesi)

The first GNSS sample observed after a denied interval will never be injected blindly into the estimator. *(Kesintili aralıktan sonra gözlemlenen ilk GNSS örneği tahmin motoruna hiçbir zaman kör şekilde enjekte edilmeyecektir.)*

Every recovery candidate must pass freshness, validity, provider, quality, and state-machine authorization checks before it can influence navigation. *(Her recovery adayı navigasyonu etkileyebilmeden önce güncellik, geçerlilik, provider, kalite ve state-machine authorization kontrollerini geçmelidir.)*

---

# 3. Recovery Is Not Satellite Reacquisition Alone (Recovery Yalnızca Uydu Yeniden Yakalama Değildir)

In NAVGUARD, GNSS recovery means that validated GNSS information becomes eligible again to influence the estimator. *(NAVGUARD içerisinde GNSS recovery doğrulanmış GNSS bilgisinin tahmin motorunu yeniden etkileyebilir hale gelmesi anlamına gelir.)*

Physical satellite reception may already have existed continuously during Evaluation Mode. *(Evaluation Mode sırasında fiziksel uydu alımı zaten sürekli olarak mevcut olabilir.)*

---

# 4. Evaluation Mode Special Case (Evaluation Mode Özel Durumu)

During Evaluation Mode, the phone may continue receiving and logging GNSS while NAVGUARD navigation deliberately excludes GNSS from the estimator. *(Evaluation Mode sırasında telefon GNSS almaya ve kaydetmeye devam ederken NAVGUARD navigasyonu GNSS'i bilinçli olarak tahmin motorundan hariç tutabilir.)*

Therefore recovery may be an authorization transition rather than a radio-level reacquisition event. *(Bu nedenle recovery radyo seviyesinde yeniden yakalama olayı yerine authorization geçişi olabilir.)*

---

# 5. No RF Interference (RF Müdahalesi Olmaması)

NAVGUARD will not perform GNSS jamming, spoofing, or intentional radio-frequency interference as part of recovery testing. *(NAVGUARD recovery testinin parçası olarak GNSS jamming, spoofing veya kasıtlı radyo frekansı müdahalesi gerçekleştirmeyecektir.)*

Recovery experiments will be created through software-controlled estimator authorization and ordinary naturally available GNSS signals. *(Recovery deneyleri yazılım kontrollü tahmin motoru authorization ve normal doğal olarak kullanılabilir GNSS sinyalleri üzerinden oluşturulacaktır.)*

---

# 6. Recovery State Sequence (Recovery Durum Dizisi)

The preferred recovery state sequence is as follows. *(Tercih edilen recovery durum dizisi aşağıdaki gibidir.)*

```text
ACTIVE_LOCAL_NAVIGATION
        ↓
GNSS_RECOVERY_PENDING
        ↓
RECOVERY_FIX_VALIDATION
        ↓
RECOVERY_REFERENCE_ACCEPTED
        ↓
PRE_CORRECTION_CAPTURED
        ↓
RECOVERY_ERROR_RECORDED
        ↓
RELOCALIZING
        ↓
GNSS_RECOVERED
        ↓
GNSS_NAVIGATION
```

Any validation failure may keep the system in `GNSS_RECOVERY_PENDING` or return it to local navigation according to the frozen state-machine policy. *(Herhangi bir validation hatası sistemi `GNSS_RECOVERY_PENDING` durumunda tutabilir veya sabitlenmiş state-machine politikasına göre yerel navigasyona geri döndürebilir.)*

---

# 7. Relationship to Navigation State Machine (Navigasyon State Machine ile İlişkisi)

The navigation state machine defined in **11 — Navigation Modes & State Machine** owns the high-level recovery transition. *(**11 — Navigasyon Modları ve State Machine** bölümünde tanımlanan navigasyon state machine yüksek seviyeli recovery geçişinin sahibidir.)*

The Recovery & Relocalization subsystem implements the validation and correction logic required by that transition. *(Recovery & Relocalization alt sistemi bu geçiş için gerekli validation ve düzeltme mantığını uygular.)*

---

# 8. Ground Truth Firewall During Recovery (Recovery Sırasında Ground Truth Firewall)

The Ground Truth Firewall remains blocking when the system first enters `GNSS_RECOVERY_PENDING`. *(Sistem ilk olarak `GNSS_RECOVERY_PENDING` durumuna girdiğinde Ground Truth Firewall blocking durumunda kalır.)*

GNSS samples may be inspected for recovery validation without yet being allowed to update the estimator. *(GNSS örnekleri henüz tahmin motorunu güncellemesine izin verilmeden recovery validation için incelenebilir.)*

---

# 9. Recovery Validation Channel (Recovery Validation Kanalı)

A separate recovery-validation path may inspect candidate GNSS fixes. *(Ayrı recovery-validation yolu aday GNSS fix'lerini inceleyebilir.)*

This path does not automatically imply estimator authorization. *(Bu yol otomatik olarak tahmin motoru authorization anlamına gelmez.)*

---

# 10. Recovery Candidate Model (Recovery Aday Modeli)

A recovery candidate will be represented explicitly. *(Recovery adayı açık şekilde temsil edilecektir.)*

```text
RecoveryGnssCandidate
- timestampNs
- latitudeDeg
- longitudeDeg
- altitudeM
- hasAltitude
- horizontalAccuracyM
- hasHorizontalAccuracy
- speedMps
- hasSpeed
- bearingDeg
- hasBearing
- fixAgeNs
- provider
- qualityState
- sequenceNumber
```

Unavailable optional values must remain unavailable rather than being replaced by zero. *(Kullanılamayan isteğe bağlı değerler sıfırla değiştirilmek yerine kullanılamaz olarak kalmalıdır.)*

---

# 11. Required Recovery Candidate Properties (Gerekli Recovery Aday Özellikleri)

A recovery candidate must originate from the configured formal GNSS provider. *(Recovery adayı yapılandırılmış resmî GNSS provider'dan gelmelidir.)*

Its latitude and longitude must be numerically valid. *(Enlem ve boylamı sayısal olarak geçerli olmalıdır.)*

Its timestamp must be valid on the common experiment timeline. *(Zaman damgası ortak deney zaman çizgisinde geçerli olmalıdır.)*

---

# 12. Freshness Requirement (Güncellik Gereksinimi)

A recovery candidate must be sufficiently fresh. *(Recovery adayı yeterince güncel olmalıdır.)*

A stale location cached before the intended recovery period must not be accepted as a new recovery fix. *(Amaçlanan recovery döneminden önce cache'lenmiş eski konum yeni recovery fix'i olarak kabul edilmemelidir.)*

---

# 13. Fix Age (Fix Yaşı)

Candidate fix age may be calculated as follows. *(Aday fix yaşı aşağıdaki şekilde hesaplanabilir.)*

```text
fixAge =
t_current -
t_gnss_measurement
```

The final maximum acceptable fix age remains pending physical-device measurements. *(Nihai maksimum kabul edilebilir fix yaşı fiziksel cihaz ölçümlerini beklemektedir.)*

---

# 14. Horizontal Accuracy Requirement (Yatay Accuracy Gereksinimi)

A formal recovery candidate should provide horizontal accuracy metadata. *(Resmî recovery adayı yatay accuracy metadata bilgisi sağlamalıdır.)*

A candidate with missing or clearly poor horizontal accuracy may remain visible for logging but can be rejected for relocalization. *(Eksik veya açık şekilde kötü yatay accuracy değerine sahip aday logging için görünür kalabilir ancak relocalization için reddedilebilir.)*

---

# 15. Accuracy Threshold Is Not Yet Frozen (Accuracy Eşiği Henüz Sabit Değildir)

The final horizontal-accuracy threshold will be selected from Redmi Note 9 Pro field behavior and development experiments. *(Nihai yatay accuracy eşiği Redmi Note 9 Pro saha davranışından ve geliştirme deneylerinden seçilecektir.)*

No arbitrary metre threshold will be fabricated before those measurements exist. *(Bu ölçümler mevcut olmadan keyfi metre eşiği uydurulmayacaktır.)*

---

# 16. Recovery and Anchor Thresholds May Differ (Recovery ve Anchor Eşikleri Farklı Olabilir)

The quality requirement for initial session anchoring does not have to be identical to the quality requirement for recovery. *(İlk oturum anchor'ı için kalite gereksiniminin recovery kalite gereksinimiyle aynı olması gerekmez.)*

The two thresholds may be calibrated separately if experiments justify it. *(Deneyler gerekçelendirirse iki eşik ayrı kalibre edilebilir.)*

---

# 17. Single-Fix Recovery Candidate (Tek Fix Recovery Adayı)

A single sufficiently strong recovery fix may be acceptable in the minimum implementation. *(Tek yeterince güçlü recovery fix'i minimum uygulamada kabul edilebilir olabilir.)*

However, the target design will prefer short multi-fix stability validation when it improves reliability without unacceptable delay. *(Ancak hedef tasarım kabul edilemez gecikme oluşturmadan güvenilirliği artırdığında kısa multi-fix stability validation'ı tercih edecektir.)*

---

# 18. Stable Recovery Window (Kararlı Recovery Penceresi)

A target recovery window may contain several consecutive validated GNSS fixes. *(Hedef recovery penceresi birkaç ardışık doğrulanmış GNSS fix'i içerebilir.)*

```text
RecoveryFixWindow
- startTimestampNs
- endTimestampNs
- fixCount
- candidateFixes
- spatialSpreadM
- meanAccuracyM
- stabilityState
```

---

# 19. Multi-Fix Stability Objective (Multi-Fix Kararlılık Hedefi)

The purpose of multi-fix validation is to reduce the risk of relocalizing to one transient GNSS outlier. *(Multi-fix validation'ın amacı tek geçici GNSS outlier'ına relocalization yapma riskini azaltmaktır.)*

---

# 20. Recovery Window Duration (Recovery Pencere Süresi)

The exact number of fixes or duration required for recovery stability will remain pending field evaluation. *(Recovery kararlılığı için gerekli kesin fix sayısı veya süre saha değerlendirmesini bekleyecektir.)*

The project will not invent a fixed value before measured GNSS cadence is known. *(Proje ölçülmüş GNSS kadansı bilinmeden sabit bir değer uydurmayacaktır.)*

---

# 21. Recovery Candidate Spatial Stability (Recovery Adayı Mekânsal Kararlılığı)

Multiple fixes may be transformed into a temporary metric frame and evaluated for spatial consistency. *(Birden fazla fix geçici metrik frame'e dönüştürülerek mekânsal tutarlılık açısından değerlendirilebilir.)*

Large scatter may reduce recovery confidence. *(Büyük saçılım recovery güvenini azaltabilir.)*

---

# 22. No Naive Latitude Averaging Without Documentation (Dokümansız Basit Enlem Ortalaması Olmaması)

If multiple fixes are combined, NAVGUARD will not use undocumented naive arithmetic averaging of latitude and longitude. *(Birden fazla fix birleştirilirse NAVGUARD enlem ve boylamın dokümante edilmemiş basit aritmetik ortalamasını kullanmayacaktır.)*

A metric-frame or ECEF-based method is preferred for reproducible combination. *(Tekrarlanabilir birleştirme için metrik frame veya ECEF tabanlı yöntem tercih edilir.)*

---

# 23. Candidate Recovery Reference Methods (Aday Recovery Referans Yöntemleri)

A recovery reference may be selected as the best validated recent fix. *(Recovery referansı en iyi doğrulanmış son fix olarak seçilebilir.)*

A recovery reference may alternatively be produced from a short validated multi-fix cluster. *(Recovery referansı alternatif olarak kısa doğrulanmış multi-fix kümesinden üretilebilir.)*

The final method will be frozen before final benchmarking. *(Nihai yöntem final benchmark öncesinde sabitlenecektir.)*

---

# 24. Recovery Reference Model (Recovery Referans Modeli)

```text
RecoveryReference
- referenceId
- timestampNs
- latitudeDeg
- longitudeDeg
- altitudeM
- hasAltitude
- horizontalAccuracyM
- sourceFixCount
- selectionMethod
- qualityState
- windowStartNs
- windowEndNs
```

---

# 25. Current Anchor Remains Active During Validation (Validation Sırasında Mevcut Anchor Aktif Kalır)

The original denied-navigation ENU anchor remains active while recovery candidates are being evaluated. *(Recovery adayları değerlendirilirken orijinal kesintili navigasyon ENU anchor'ı aktif kalmaya devam eder.)*

Recovery validation must not silently move the coordinate origin. *(Recovery validation koordinat origin'ini sessizce taşımamalıdır.)*

---

# 26. Recovery Reference Is Converted Into Existing ENU (Recovery Referansı Mevcut ENU'ya Dönüştürülür)

The accepted recovery reference will first be transformed into the same fixed ENU frame used during the denied interval. *(Kabul edilen recovery referansı önce kesintili aralıkta kullanılan aynı sabit ENU frame'ine dönüştürülecektir.)*

This ensures that error is measured before any re-anchoring decision. *(Bu herhangi bir re-anchor kararından önce hatanın ölçülmesini sağlar.)*

---

# 27. Existing Anchor Is the Comparison Frame (Mevcut Anchor Karşılaştırma Frame'idir)

The original anchor defines the comparison frame for recovery error. *(Orijinal anchor recovery hatası için karşılaştırma frame'ini tanımlar.)*

Ground truth or recovery data cannot redefine that frame before the error has been recorded. *(Ground truth veya recovery verisi hata kaydedilmeden önce bu frame'i yeniden tanımlayamaz.)*

---

# 28. Pre-Correction Estimate Capture (Düzeltme Öncesi Tahmini Koruma)

Immediately before relocalization, NAVGUARD must store the current estimator state. *(Relocalization'dan hemen önce NAVGUARD mevcut tahmin motoru durumunu saklamalıdır.)*

```text
x_pre
P_pre
t_pre
```

---

# 29. Pre-Correction Position Capture (Düzeltme Öncesi Konum Koruma)

At minimum, the following values will be retained. *(Minimum olarak aşağıdaki değerler korunacaktır.)*

```text
E_pre
N_pre
latitude_pre
longitude_pre
horizontal_uncertainty_pre
quality_pre
```

---

# 30. Recovery Reference in ENU (ENU İçerisinde Recovery Referansı)

```text
p_rec =
[
E_rec
N_rec
]
```

The reference must be computed relative to the original active anchor. *(Referans orijinal aktif anchor'a göre hesaplanmalıdır.)*

---

# 31. Recovery Error Vector (Recovery Hata Vektörü)

```text
e_rec =
p_pre - p_rec
```

Expanded form is as follows. *(Açılmış biçim aşağıdaki gibidir.)*

```text
e_E =
E_pre - E_rec

e_N =
N_pre - N_rec
```

---

# 32. Horizontal Recovery Error (Yatay Recovery Hatası)

```text
e_horizontal =
√(
e_E² + e_N²
)
```

This value is recorded before any state correction. *(Bu değer herhangi bir durum düzeltmesinden önce kaydedilir.)*

---

# 33. Recovery Error Is Immutable Evidence (Recovery Hatası Değişmez Kanıttır)

Once recorded for a formal benchmark interval, pre-correction recovery error must not be replaced by post-correction error. *(Resmî benchmark aralığı için kaydedildikten sonra düzeltme öncesi recovery hatası düzeltme sonrası hatayla değiştirilmemelidir.)*

---

# 34. Why Correction Must Come Second (Düzeltme Neden İkinci Gelmelidir)

If NAVGUARD corrected the state before measuring error, the reported recovery error could become artificially small. *(NAVGUARD hatayı ölçmeden önce durumu düzeltirse raporlanan recovery hatası yapay olarak küçük hale gelebilir.)*

That would invalidate the drift evaluation. *(Bu drift değerlendirmesini geçersiz kılardı.)*

---

# 35. Recovery Event Model (Recovery Olay Modeli)

```text
GnssRecoveryEvent
- recoveryId
- requestTimestampNs
- referenceAcceptedTimestampNs
- preCorrectionTimestampNs
- relocalizationTimestampNs
- preEastM
- preNorthM
- referenceEastM
- referenceNorthM
- errorEastM
- errorNorthM
- horizontalErrorM
- preCovariance
- referenceAccuracyM
- recoveryMethod
- relocalizationMethod
- success
- failureReason
```

---

# 36. Recovery Request (Recovery İsteği)

A recovery request may be initiated manually in the first implementation. *(İlk uygulamada recovery isteği manuel olarak başlatılabilir.)*

Automatic recovery triggering may be added later if clearly needed. *(Açık şekilde gerekli olursa otomatik recovery triggering daha sonra eklenebilir.)*

---

# 37. Manual Recovery Benefits (Manuel Recovery'nin Faydaları)

Manual recovery makes the beginning and end of the denied interval explicit during controlled experiments. *(Manuel recovery kontrollü deneylerde kesintili aralığın başlangıcını ve sonunu açık hale getirir.)*

This improves experimental reproducibility. *(Bu deneysel tekrarlanabilirliği artırır.)*

---

# 38. Automatic Recovery Candidate (Otomatik Recovery Adayı)

A future automatic policy could request recovery after GNSS quality remains acceptable for a stable period. *(Gelecekteki otomatik politika GNSS kalitesi kararlı süre boyunca kabul edilebilir kaldıktan sonra recovery isteyebilir.)*

This is not required for the minimum prototype. *(Bu minimum prototip için gerekli değildir.)*

---

# 39. Recovery Pending State (Recovery Pending Durumu)

Entering `GNSS_RECOVERY_PENDING` does not restore estimator GNSS access. *(`GNSS_RECOVERY_PENDING` durumuna girmek tahmin motoru GNSS erişimini geri açmaz.)*

The estimator remains GNSS-denied until recovery authorization is explicitly granted. *(Recovery authorization açıkça verilene kadar tahmin motoru GNSS-denied kalır.)*

---

# 40. Recovery Timeout (Recovery Timeout'u)

A recovery attempt may have a maximum waiting interval for finding a valid reference. *(Recovery denemesi geçerli referans bulmak için maksimum bekleme aralığına sahip olabilir.)*

The final timeout duration remains pending field testing. *(Nihai timeout süresi saha testlerini beklemektedir.)*

---

# 41. Timeout Does Not Force Bad GNSS (Timeout Kötü GNSS'i Zorlamaz)

A recovery timeout will never force acceptance of a poor GNSS fix merely to finish the transition. *(Recovery timeout'u yalnızca geçişi tamamlamak için kötü GNSS fix'inin kabulünü hiçbir zaman zorlamayacaktır.)*

---

# 42. Recovery Failure Behavior (Recovery Hatası Davranışı)

If no acceptable recovery reference becomes available, NAVGUARD will continue local navigation if that estimator remains valid. *(Kabul edilebilir recovery referansı kullanılamazsa NAVGUARD tahmin motoru geçerli kaldığı sürece yerel navigasyona devam edecektir.)*

Position quality may continue to degrade as dead reckoning continues. *(Dead reckoning devam ettikçe konum kalitesi düşmeye devam edebilir.)*

---

# 43. Recovery Retry (Recovery Yeniden Deneme)

A failed recovery attempt may be retried later. *(Başarısız recovery denemesi daha sonra yeniden denenebilir.)*

Every retry will receive its own attempt identifier. *(Her yeniden deneme kendi attempt tanımlayıcısını alacaktır.)*

---

# 44. Recovery Attempt Model (Recovery Deneme Modeli)

```text
RecoveryAttempt
- attemptId
- startTimestampNs
- endTimestampNs
- candidateCount
- acceptedReferenceId
- result
- failureReason
```

---

# 45. Recovery Failure Reason Codes (Recovery Hata Neden Kodları)

```text
RECOVERY_NO_GNSS
RECOVERY_STALE_FIX
RECOVERY_POOR_ACCURACY
RECOVERY_INVALID_COORDINATE
RECOVERY_UNSTABLE_FIXES
RECOVERY_PROVIDER_MISMATCH
RECOVERY_TIMEOUT
RECOVERY_REFERENCE_CONVERSION_FAILED
RECOVERY_STATE_INVALID
RECOVERY_AUTHORIZATION_FAILED
RECOVERY_RELOCALIZATION_FAILED
```

---

# 46. Recovery Quality States (Recovery Kalite Durumları)

```text
UNKNOWN
REJECTED
CANDIDATE
STABLE
ACCEPTED
```

These states describe recovery-reference readiness rather than current navigation quality. *(Bu durumlar mevcut navigasyon kalitesi yerine recovery referans hazırlığını açıklar.)*

---

# 47. Relocalization Definition (Relocalization Tanımı)

Relocalization is the controlled process of aligning the active estimator state with a newly authorized absolute position reference. *(Relocalization aktif tahmin motoru durumunu yeni izin verilmiş mutlak konum referansıyla kontrollü şekilde hizalama sürecidir.)*

---

# 48. Relocalization Is Not Historical Editing (Relocalization Geçmiş Düzenleme Değildir)

Relocalization changes the current or future estimator state. *(Relocalization mevcut veya gelecekteki tahmin motoru durumunu değiştirir.)*

It does not rewrite the previously measured denied-navigation trajectory. *(Daha önce ölçülmüş kesintili navigasyon trajectory'sini yeniden yazmaz.)*

---

# 49. Candidate Relocalization Strategies (Aday Relocalization Stratejileri)

NAVGUARD will consider three conceptual strategies. *(NAVGUARD üç kavramsal stratejiyi değerlendirecektir.)*

```text
HARD_SNAP
SOFT_CORRECTION
CONTROLLED_REANCHOR
```

Only strategies that preserve evaluation integrity will be allowed. *(Yalnızca değerlendirme bütünlüğünü koruyan stratejilere izin verilecektir.)*

---

# 50. HARD_SNAP Strategy (HARD_SNAP Stratejisi)

A hard snap sets the current horizontal position directly to the accepted recovery reference. *(Hard snap mevcut yatay konumu doğrudan kabul edilmiş recovery referansına ayarlar.)*

```text
E_post = E_rec

N_post = N_rec
```

---

# 51. HARD_SNAP Advantages (HARD_SNAP Avantajları)

Hard snap is simple and deterministic. *(Hard snap basit ve deterministiktir.)*

It rapidly restores consistency with the accepted absolute reference. *(Kabul edilen mutlak referansla tutarlılığı hızlı şekilde geri kazandırır.)*

---

# 52. HARD_SNAP Limitations (HARD_SNAP Sınırlamaları)

Hard snap may create a visible discontinuity in the current trajectory. *(Hard snap mevcut trajectory'de görünür süreksizlik oluşturabilir.)*

It may also abruptly alter EKF velocity or heading consistency if only position is reset without a complete state policy. *(Yalnızca konum resetlenip tam durum politikası tanımlanmazsa EKF velocity veya heading tutarlılığını da aniden bozabilir.)*

---

# 53. SOFT_CORRECTION Strategy (SOFT_CORRECTION Stratejisi)

A soft correction gradually moves the active state toward the recovery reference over a controlled interval. *(Soft correction aktif durumu kontrollü aralık boyunca recovery referansına doğru kademeli şekilde taşır.)*

---

# 54. Generic Soft Correction Form (Genel Soft Correction Formu)

A simple conceptual form may be expressed as follows. *(Basit kavramsal biçim aşağıdaki şekilde ifade edilebilir.)*

```text
p_post =
p_pre +
α(
p_rec - p_pre
)
```

where `0 < α ≤ 1`. *(burada `0 < α ≤ 1` değeridir.)*

---

# 55. Soft Correction Must Be State-Aware (Soft Correction Durum Farkındalıklı Olmalıdır)

A practical EKF correction should not be implemented as an arbitrary UI interpolation. *(Pratik EKF düzeltmesi keyfi UI interpolation olarak uygulanmamalıdır.)*

If soft relocalization is retained, it must be implemented through a mathematically consistent estimator correction policy. *(Soft relocalization korunursa matematiksel olarak tutarlı tahmin motoru düzeltme politikası üzerinden uygulanmalıdır.)*

---

# 56. CONTROLLED_REANCHOR Strategy (CONTROLLED_REANCHOR Stratejisi)

A controlled re-anchor establishes a new local geographic origin after recovery. *(Controlled re-anchor recovery sonrasında yeni yerel coğrafi origin oluşturur.)*

It may be useful for long future navigation segments after the recovery point. *(Recovery noktasından sonraki uzun gelecek navigasyon segmentleri için kullanışlı olabilir.)*

---

# 57. Re-Anchoring Must Preserve History (Re-Anchor Geçmişi Korumalıdır)

A new anchor must not reinterpret or move historical denied-navigation ENU points. *(Yeni anchor geçmiş kesintili navigasyon ENU noktalarını yeniden yorumlamamalı veya taşımamalıdır.)*

Historical points remain associated with the anchor that was active when they were produced. *(Geçmiş noktalar üretildikleri sırada aktif olan anchor ile ilişkili kalır.)*

---

# 58. Anchor Versioning (Anchor Sürümleme)

Every anchor will have a stable identifier. *(Her anchor kararlı tanımlayıcıya sahip olacaktır.)*

```text
AnchorRecord
- anchorId
- timestampNs
- latitudeDeg
- longitudeDeg
- altitudeM
- source
- predecessorAnchorId
- creationReason
```

---

# 59. Anchor Chain (Anchor Zinciri)

A session may therefore contain an anchor chain. *(Bu nedenle bir oturum anchor zinciri içerebilir.)*

```text
ANCHOR_001
   ↓
ANCHOR_002
   ↓
ANCHOR_003
```

Each trajectory point remains traceable to the anchor used for its geographic conversion. *(Her trajectory noktası coğrafi dönüşümünde kullanılan anchor'a izlenebilir kalır.)*

---

# 60. Minimum Preferred Relocalization Strategy (Minimum Tercih Edilen Relocalization Stratejisi)

For the minimum implementation, a controlled hard position correction after error capture is the simplest acceptable recovery method. *(Minimum uygulama için hata kaydından sonra kontrollü hard position correction en basit kabul edilebilir recovery yöntemidir.)*

The exact state-reset policy will still be explicit. *(Kesin durum reset politikası yine açık olacaktır.)*

---

# 61. Target Relocalization Strategy (Hedef Relocalization Stratejisi)

The target implementation will compare direct correction and estimator-consistent measurement-based relocalization. *(Hedef uygulama doğrudan düzeltme ile tahmin motoruyla tutarlı ölçüm tabanlı relocalization'ı karşılaştıracaktır.)*

The simplest method with stable behavior will be retained. *(Kararlı davranış gösteren en basit yöntem korunacaktır.)*

---

# 62. EKF Measurement-Based Recovery (EKF Ölçüm Tabanlı Recovery)

One candidate is to inject the accepted recovery reference as a strongly validated absolute-position measurement into the EKF after pre-correction error capture. *(Aday yöntemlerden biri düzeltme öncesi hata kaydından sonra kabul edilen recovery referansını güçlü şekilde doğrulanmış mutlak konum ölçümü olarak EKF'ye enjekte etmektir.)*

---

# 63. Recovery Measurement Model (Recovery Ölçüm Modeli)

For a horizontal position measurement, a candidate measurement may be written as follows. *(Yatay konum ölçümü için aday measurement aşağıdaki şekilde yazılabilir.)*

```text
z_rec =
[
E_rec
N_rec
]
```

---

# 64. Authoritative Core Recovery Measurement Matrix (Authoritative Core Recovery Ölçüm Matrisi)

For the authoritative minimum state `[E, N, ψ]`, an authorized horizontal recovery-position measurement uses the following matrix. *(Authoritative minimum `[E, N, ψ]` durumu için authorized horizontal recovery-position measurement aşağıdaki matrisi kullanır.)*

```text
H_rec =

[1 0 0]
[0 1 0]
```

This three-column matrix is authoritative for the core recovery implementation. *(Bu üç sütunlu matris core recovery implementation için authoritative'dir.)*

A five-column matrix such as the following belongs only to the optional `[E, N, vE, vN, ψ]` extension. *(Aşağıdaki gibi beş sütunlu bir matris yalnızca optional `[E, N, vE, vN, ψ]` extension'a aittir.)*

```text
H_rec_optional =

[1 0 0 0 0]
[0 1 0 0 0]
```

**Status: OPTIONAL / NON-AUTHORITATIVE / EVIDENCE-GATED EXTENSION.** *(Durum: OPTIONAL / NON-AUTHORITATIVE / EVIDENCE-GATED EXTENSION.)*

The optional recovery matrix must not be used unless the corresponding velocity-augmented state has been explicitly approved through a later Technical Decision and versioned experiment profile. *(İlgili velocity-augmented state daha sonraki bir Technical Decision ve versioned experiment profile aracılığıyla açıkça approved edilmediği sürece optional recovery matrix kullanılmamalıdır.)*

---

# 65. Recovery Measurement Noise (Recovery Ölçüm Gürültüsü)

Recovery measurement covariance `R_rec` should reflect the validated quality of the accepted GNSS reference. *(Recovery measurement kovaryansı `R_rec` kabul edilmiş GNSS referansının doğrulanmış kalitesini yansıtmalıdır.)*

```text
R_rec =

[σE²    0 ]
[ 0    σN²]
```

The final mapping from Android horizontal accuracy to `R_rec` remains pending calibration. *(Android yatay accuracy değerinden `R_rec` değerine nihai eşleme kalibrasyonu beklemektedir.)*

---

# 66. Isotropic Recovery Noise Candidate (İzotropik Recovery Gürültü Adayı)

If only one horizontal accuracy radius is available, an isotropic covariance approximation may be used initially. *(Yalnızca tek yatay accuracy radius mevcutsa başlangıçta izotropik kovaryans yaklaşımı kullanılabilir.)*

This assumption must be documented and validated. *(Bu varsayım dokümante edilmeli ve doğrulanmalıdır.)*

---

# 67. No Zero Recovery Noise (Sıfır Recovery Gürültüsü Olmaması)

Recovery GNSS will never be treated as perfectly exact by setting `R_rec = 0`. *(Recovery GNSS `R_rec = 0` ayarlanarak hiçbir zaman kusursuz kesin olarak ele alınmayacaktır.)*

---

# 68. Recovery Innovation (Recovery Innovation)

The EKF recovery innovation may be written as follows. *(EKF recovery innovation aşağıdaki şekilde yazılabilir.)*

```text
y_rec =
z_rec -
H_rec x_pre
```

This innovation is related to but conceptually distinct from the externally recorded recovery error metric. *(Bu innovation harici olarak kaydedilen recovery hata metriğiyle ilişkili ancak kavramsal olarak farklıdır.)*

---

# 69. Innovation Gating Candidate (Innovation Gating Adayı)

A very large recovery innovation may indicate either large accumulated dead-reckoning drift or a bad GNSS recovery reference. *(Çok büyük recovery innovation büyük birikmiş dead-reckoning drift'i veya kötü GNSS recovery referansını gösterebilir.)*

The system must distinguish these possibilities using recovery-quality evidence. *(Sistem recovery kalite kanıtını kullanarak bu olasılıkları ayırt etmelidir.)*

---

# 70. Do Not Reject True Drift Automatically (Gerçek Drift'i Otomatik Reddetmeme)

A recovery reference must not be rejected solely because it is far from the current estimate. *(Recovery referansı yalnızca mevcut tahminden uzak olduğu için reddedilmemelidir.)*

Large disagreement may be exactly the drift that the experiment is intended to measure. *(Büyük uyuşmazlık deneyin ölçmek istediği drift'in kendisi olabilir.)*

---

# 71. Quality Before Innovation Magnitude (Innovation Büyüklüğünden Önce Kalite)

GNSS reference quality, freshness, stability, and independent plausibility must be considered before interpreting a large residual as an outlier. *(Büyük residual outlier olarak yorumlanmadan önce GNSS referans kalitesi, güncelliği, kararlılığı ve bağımsız makullüğü değerlendirilmelidir.)*

---

# 72. Recovery Outlier Rejection (Recovery Outlier Reddetme)

A candidate recovery fix may be rejected if independent GNSS-quality evidence indicates that it is unreliable. *(Bağımsız GNSS kalite kanıtı güvenilmez olduğunu gösterirse aday recovery fix'i reddedilebilir.)*

The rejection must not be based on a desire to reduce the reported navigation error. *(Reddetme raporlanan navigasyon hatasını azaltma isteğine dayanmamalıdır.)*

---

# 73. Recovery Quality Policy Freeze (Recovery Kalite Politikası Sabitleme)

All recovery acceptance thresholds will be frozen before the final benchmark. *(Tüm recovery kabul eşikleri final benchmark öncesinde sabitlenecektir.)*

---

# 74. No Post-Hoc Recovery Selection (Sonradan Recovery Seçimi Olmaması)

After final results are visible, NAVGUARD will not select whichever GNSS recovery fix produces the smallest reported error. *(Nihai sonuçlar görünür olduktan sonra NAVGUARD raporlanan en küçük hatayı üreten GNSS recovery fix'ini seçmeyecektir.)*

---

# 75. Recovery Reference Selection Must Be Deterministic (Recovery Referans Seçimi Deterministik Olmalıdır)

Given the same candidate fixes and configuration, the recovery-selection algorithm should choose the same reference. *(Aynı aday fix'ler ve yapılandırma verildiğinde recovery-selection algoritması aynı referansı seçmelidir.)*

---

# 76. Recovery Configuration (Recovery Yapılandırması)

```text
RecoveryConfig
- provider
- maxFixAge
- maxHorizontalAccuracy
- minStableFixCount
- stabilityWindowDuration
- maxSpatialSpread
- selectionMethod
- timeoutDuration
- relocalizationMethod
- covarianceResetPolicy
```

Exact numeric values remain pending development measurements. *(Kesin sayısal değerler geliştirme ölçümlerini beklemektedir.)*

---

# 77. Recovery Configuration Versioning (Recovery Yapılandırma Sürümleme)

Formal sessions will record a recovery configuration version. *(Resmî oturumlar recovery yapılandırma sürümünü kaydedecektir.)*

---

# 78. Relocalization Configuration (Relocalization Yapılandırması)

```text
RelocalizationConfig
- method
- updatePosition
- updateVelocity
- updateHeading
- covariancePolicy
- createNewAnchor
- preserveHistoricalAnchor
```

---

# 79. Position Correction Policy (Konum Düzeltme Politikası)

Position is the primary state expected to change during GNSS recovery. *(Konum GNSS recovery sırasında değişmesi beklenen temel durumdur.)*

Other states will not be modified automatically unless the selected relocalization model justifies it. *(Diğer durumlar seçilen relocalization modeli gerekçelendirmedikçe otomatik olarak değiştirilmeyecektir.)*

---

# 80. Velocity Correction (Hız Düzeltmesi)

GNSS speed may potentially inform velocity after recovery. *(GNSS speed recovery sonrasında velocity'yi potansiyel olarak bilgilendirebilir.)*

However, velocity will not be reset blindly from GNSS unless its measurement quality and state model support that update. *(Ancak measurement kalitesi ve durum modeli bu update'i desteklemedikçe velocity GNSS'ten kör şekilde resetlenmeyecektir.)*

---

# 81. Heading Correction (Yön Düzeltmesi)

GNSS movement or travel bearing is not a physical device or body-heading measurement and must not be used to correct, reset, replace, or initialize the NAVGUARD phone-heading state during recovery. *(GNSS movement veya travel bearing fiziksel cihaz veya body-heading measurement değildir ve recovery sırasında NAVGUARD phone-heading state'ini düzeltmek, resetlemek, değiştirmek veya initialize etmek için kullanılmamalıdır.)*

No manual action, recovery mode, motion gate, speed gate, quality gate, or bearing-accuracy condition authorizes GNSS travel bearing as a phone-heading input. *(Hiçbir manual action, recovery mode, motion gate, speed gate, quality gate veya bearing-accuracy condition GNSS travel bearing'i phone-heading input olarak authorize etmez.)*

GNSS bearing may be inspected only as travel-direction diagnostic information in explicitly authorized GNSS Mode or during offline post-session evaluation. *(GNSS bearing yalnızca explicitly authorized GNSS Mode içerisinde veya offline post-session evaluation sırasında travel-direction diagnostic bilgisi olarak incelenebilir.)*

---

# 82. Heading Continuity (Yön Sürekliliği)

Relocalization should preserve heading continuity unless an independently validated heading correction exists. *(Bağımsız doğrulanmış yön düzeltmesi mevcut olmadıkça relocalization yön sürekliliğini korumalıdır.)*

---

# 83. Covariance After Recovery (Recovery Sonrası Kovaryans)

Relocalization must define what happens to the EKF covariance. *(Relocalization EKF kovaryansına ne olduğunu tanımlamalıdır.)*

The covariance must not be reset arbitrarily to zero. *(Kovaryans keyfi olarak sıfıra resetlenmemelidir.)*

---

# 84. Measurement-Update Covariance Policy (Measurement-Update Kovaryans Politikası)

If recovery is applied as an EKF measurement update, covariance should naturally update through the Kalman correction equations. *(Recovery EKF measurement update olarak uygulanırsa kovaryans Kalman düzeltme denklemleri üzerinden doğal olarak güncellenmelidir.)*

---

# 85. Hard Reset Covariance Policy (Hard Reset Kovaryans Politikası)

If a direct hard position reset is used, a corresponding explicit covariance initialization policy is required. *(Doğrudan hard position reset kullanılırsa karşılık gelen açık kovaryans initialization politikası gereklidir.)*

---

# 86. No Artificial Certainty After Snap (Snap Sonrası Yapay Kesinlik Olmaması)

A hard snap to GNSS does not justify zero horizontal uncertainty. *(GNSS'e hard snap yapmak sıfır yatay belirsizliği gerekçelendirmez.)*

The post-recovery uncertainty must include the uncertainty of the accepted GNSS reference. *(Recovery sonrası belirsizlik kabul edilen GNSS referansının belirsizliğini içermelidir.)*

---

# 87. Pre-Correction Covariance Is Preserved for Evaluation (Düzeltme Öncesi Kovaryans Değerlendirme İçin Korunur)

`P_pre` must remain stored even if the active covariance changes during relocalization. *(`P_pre` aktif kovaryans relocalization sırasında değişse bile saklanmış olarak kalmalıdır.)*

---

# 88. Post-Correction Covariance (Düzeltme Sonrası Kovaryans)

```text
P_post
```

The recovery event will store enough information to distinguish `P_pre` from `P_post`. *(Recovery olayı `P_pre` ile `P_post` değerlerini ayırt etmek için yeterli bilgiyi saklayacaktır.)*

---

# 89. Covariance Reduction Is Expected but Not Guaranteed (Kovaryans Azalması Beklenir ancak Garanti Değildir)

A strong absolute position update will generally reduce horizontal position uncertainty. *(Güçlü mutlak konum update'i genel olarak yatay konum belirsizliğini azaltacaktır.)*

The actual covariance behavior depends on the filter model and measurement noise. *(Gerçek kovaryans davranışı filtre modeline ve measurement noise'a bağlıdır.)*

---

# 90. New Anchor After Recovery (Recovery Sonrası Yeni Anchor)

The system may optionally establish a new geographic anchor after successful recovery. *(Sistem başarılı recovery sonrasında isteğe bağlı olarak yeni coğrafi anchor oluşturabilir.)*

---

# 91. When Re-Anchoring Is Useful (Re-Anchor Ne Zaman Kullanışlıdır)

Re-anchoring may simplify future local-coordinate magnitudes if navigation continues for a long distance after recovery. *(Navigasyon recovery sonrasında uzun mesafe devam ederse re-anchor gelecekteki yerel koordinat büyüklüklerini basitleştirebilir.)*

---

# 92. Re-Anchoring Is Not Mandatory (Re-Anchor Zorunlu Değildir)

Short sessions may continue using the original session anchor after recovery. *(Kısa oturumlar recovery sonrasında orijinal oturum anchor'ını kullanmaya devam edebilir.)*

The final policy will be selected for implementation simplicity and evaluation clarity. *(Nihai politika uygulama basitliği ve değerlendirme açıklığı için seçilecektir.)*

---

# 93. Original Anchor Must Remain Recorded (Orijinal Anchor Kaydedilmiş Kalmalıdır)

Even if a new anchor is created, the original denied-interval anchor must remain in the session manifest. *(Yeni anchor oluşturulsa bile orijinal kesintili aralık anchor'ı oturum manifest'inde kalmalıdır.)*

---

# 94. Coordinate Transform Between Anchors (Anchor'lar Arası Koordinat Dönüşümü)

If multiple anchors exist, trajectory data may be converted through WGS84 or ECEF for unified analysis. *(Birden fazla anchor mevcutsa trajectory verisi birleşik analiz için WGS84 veya ECEF üzerinden dönüştürülebilir.)*

---

# 95. No Reinterpretation of Stored ENU (Saklanan ENU'nun Yeniden Yorumlanmaması)

Stored ENU coordinates always belong to the anchor ID recorded with them. *(Saklanan ENU koordinatları her zaman kendileriyle kaydedilmiş anchor ID'sine aittir.)*

---

# 96. Recovery Success Definition (Recovery Başarı Tanımı)

A recovery attempt is successful only when an accepted recovery reference has been validated and the configured relocalization procedure completes successfully. *(Recovery denemesi yalnızca kabul edilmiş recovery referansı doğrulanmış ve yapılandırılmış relocalization prosedürü başarıyla tamamlanmışsa başarılıdır.)*

---

# 97. GNSS Access Restoration (GNSS Erişim Geri Açılması)

Estimator GNSS authorization will be restored only after the recovery state machine grants access. *(Tahmin motoru GNSS authorization yalnızca recovery state machine erişim izni verdikten sonra geri açılacaktır.)*

---

# 98. Recovery Authorization States (Recovery Authorization Durumları)

```text
NAVGUARD_ACTIVE        → BLOCKED
RECOVERY_PENDING       → BLOCKED
REFERENCE_ACCEPTED     → BLOCKED
PRE_ERROR_CAPTURED     → BLOCKED
RELOCALIZING           → CONTROLLED
GNSS_RECOVERED         → ALLOWED
GNSS_NAVIGATION        → ALLOWED
```

This ordering ensures that GNSS cannot correct the estimator before recovery error has been recorded. *(Bu sıralama recovery hatası kaydedilmeden önce GNSS'in tahmin motorunu düzeltememesini sağlar.)*

---

# 99. Firewall Authorization Before Quality (Firewall Authorization Kaliteden Önce)

A high-quality GNSS fix must still be blocked from the estimator while the authorization state is `BLOCKED`. *(Yüksek kaliteli GNSS fix'i authorization durumu `BLOCKED` iken yine de tahmin motorundan engellenmelidir.)*

---

# 100. Recovery and Ground Truth Logging Continue Independently (Recovery ve Ground Truth Logging Bağımsız Devam Eder)

GNSS ground-truth logging can continue while recovery validation is pending. *(Recovery validation beklerken GNSS ground-truth logging devam edebilir.)*

---

# 101. Recovery Does Not Erase Denial Boundary (Recovery Kesinti Sınırını Silmez)

The original denial start timestamp remains part of the session record after recovery. *(Orijinal kesinti başlangıç zaman damgası recovery sonrasında oturum kaydının parçası olarak kalır.)*

---

# 102. Denied Interval End Timestamp (Kesintili Aralık Bitiş Zaman Damgası)

The formal denied interval will end at the exact configured recovery boundary. *(Resmî kesintili aralık kesin yapılandırılmış recovery sınırında sona erecektir.)*

The selected boundary definition will be explicit. *(Seçilen sınır tanımı açık olacaktır.)*

---

# 103. Candidate Denied-End Definitions (Aday Kesinti Bitiş Tanımları)

One candidate is the moment a recovery reference is accepted. *(Adaylardan biri recovery referansının kabul edildiği andır.)*

Another candidate is the moment relocalization is applied. *(Diğer aday relocalization'ın uygulandığı andır.)*

The final metric policy must use one consistent definition. *(Nihai metrik politikası tek tutarlı tanım kullanmalıdır.)*

---

# 104. Preferred Evaluation Boundary (Tercih Edilen Değerlendirme Sınırı)

For drift evaluation, the preferred denied endpoint is the pre-correction recovery comparison timestamp. *(Drift değerlendirmesi için tercih edilen kesintili bitiş noktası düzeltme öncesi recovery karşılaştırma zaman damgasıdır.)*

This captures the estimator error immediately before GNSS correction. *(Bu GNSS düzeltmesinden hemen önce tahmin motoru hatasını yakalar.)*

---

# 105. Recovery Latency (Recovery Gecikmesi)

Recovery latency may be measured from recovery request to accepted reference. *(Recovery gecikmesi recovery isteğinden kabul edilmiş referansa kadar ölçülebilir.)*

```text
latency_recovery =
t_reference_accepted -
t_recovery_requested
```

---

# 106. Relocalization Latency (Relocalization Gecikmesi)

```text
latency_relocalization =
t_relocalization_complete -
t_reference_accepted
```

---

# 107. Total Recovery Latency (Toplam Recovery Gecikmesi)

```text
latency_total =
t_relocalization_complete -
t_recovery_requested
```

---

# 108. Recovery Latency Is a Secondary Metric (Recovery Gecikmesi İkincil Metriktir)

Recovery accuracy and integrity are more important than minimizing recovery delay aggressively. *(Recovery doğruluğu ve bütünlüğü recovery gecikmesini agresif şekilde azaltmaktan daha önemlidir.)*

---

# 109. Recovery UX State (Recovery UX Durumu)

The UI should indicate when GNSS recovery is pending. *(UI GNSS recovery beklediğinde bunu belirtmelidir.)*

The UI should not imply that GNSS navigation is restored before relocalization succeeds. *(UI relocalization başarılı olmadan GNSS navigasyonunun geri geldiğini ima etmemelidir.)*

---

# 110. Candidate Recovery UI States (Aday Recovery UI Durumları)

```text
Checking GNSS Recovery
(GNSS Geri Kazanımı Kontrol Ediliyor)

GNSS Reference Validated
(GNSS Referansı Doğrulandı)

Relocalizing
(Yeniden Konumlandırılıyor)

GNSS Navigation Restored
(GNSS Navigasyonu Geri Yüklendi)
```

Final wording belongs to **31 — Mobile UI/UX Specification**. *(Nihai metin **31 — Mobil UI/UX Spesifikasyonu** bölümüne aittir.)*

---

# 111. No Error Value Before Capture (Yakalanmadan Önce Hata Değeri Olmaması)

The UI and logs must not display recovery error until the pre-correction estimate and reference have both been captured. *(UI ve loglar düzeltme öncesi tahmin ve referansın her ikisi yakalanmadan recovery hatası göstermemelidir.)*

---

# 112. Recovery Reference Accuracy Display (Recovery Referans Accuracy Gösterimi)

Diagnostics may display recovery reference horizontal accuracy separately from NAVGUARD recovery error. *(Diagnostics recovery referans yatay accuracy değerini NAVGUARD recovery hatasından ayrı gösterebilir.)*

---

# 113. Accuracy Is Not Error (Accuracy Hata Değildir)

GNSS-reported horizontal accuracy and actual NAVGUARD position error are different quantities. *(GNSS tarafından raporlanan yatay accuracy ile gerçek NAVGUARD konum hatası farklı büyüklüklerdir.)*

---

# 114. Recovery Error Confidence (Recovery Hata Güveni)

The quality of the recovery-error metric depends partly on the quality of the recovery reference. *(Recovery-error metriğinin kalitesi kısmen recovery referansının kalitesine bağlıdır.)*

---

# 115. Poor Reference Does Not Become Perfect Ground Truth (Kötü Referans Kusursuz Ground Truth Olmaz)

A poor GNSS recovery fix cannot support a high-confidence claim about exact drift magnitude. *(Kötü GNSS recovery fix'i kesin drift büyüklüğü hakkında yüksek güvenli iddiayı destekleyemez.)*

---

# 116. Recovery Benchmark Eligibility (Recovery Benchmark Uygunluğu)

A session may be excluded from specific GNSS-ground-truth recovery metrics if the recovery reference fails the predeclared validity policy. *(Recovery referansı önceden tanımlanan geçerlilik politikasını geçemezse oturum belirli GNSS-ground-truth recovery metriklerinden çıkarılabilir.)*

The session itself may still remain useful for other analyses. *(Oturumun kendisi diğer analizler için yine de kullanışlı kalabilir.)*

---

# 117. Recovery Exclusion Must Be Predefined (Recovery Hariç Tutma Önceden Tanımlanmalıdır)

Recovery reference validity rules must be frozen before final test results are reviewed. *(Recovery referans geçerlilik kuralları final test sonuçları incelenmeden önce sabitlenmelidir.)*

---

# 118. No Cherry-Picking Recovery Time (Recovery Zamanını Cherry-Picking Etmeme)

Formal evaluation will not search through a long GNSS log and choose the time that minimizes NAVGUARD error. *(Resmî değerlendirme uzun GNSS logu içerisinde arama yapıp NAVGUARD hatasını en aza indiren zamanı seçmeyecektir.)*

---

# 119. Recovery Reference Timestamp Policy (Recovery Referans Zaman Damgası Politikası)

The selected recovery method will define exactly which timestamp represents the accepted reference. *(Seçilen recovery yöntemi kabul edilen referansı hangi zaman damgasının temsil ettiğini kesin olarak tanımlayacaktır.)*

---

# 120. Time Alignment Before Error Calculation (Hata Hesabından Önce Zaman Hizalama)

The estimated position and recovery reference must correspond to compatible times before their error is calculated. *(Tahmini konum ve recovery referansı hata hesaplanmadan önce uyumlu zamanlara karşılık gelmelidir.)*

---

# 121. No Large Unbounded Time Interpolation (Büyük Sınırsız Zaman Interpolation Olmaması)

NAVGUARD will not interpolate over long GNSS gaps simply to manufacture a recovery reference at the desired time. *(NAVGUARD istenen zamanda recovery referansı üretmek için uzun GNSS boşlukları üzerinden interpolation yapmayacaktır.)*

---

# 122. Candidate Temporal Alignment (Aday Zamansal Hizalama)

The pre-correction estimate may be evaluated at the accepted recovery reference timestamp through estimator replay or bounded state interpolation if justified. *(Düzeltme öncesi tahmin gerekçelendirilirse tahmin motoru replay'i veya sınırlı durum interpolation ile kabul edilen recovery referans zaman damgasında değerlendirilebilir.)*

---

# 123. Simpler Live Policy (Daha Basit Canlı Politika)

For the live implementation, the system may instead capture the current estimator state immediately when the reference becomes accepted. *(Canlı uygulamada sistem bunun yerine referans kabul edildiği anda mevcut tahmin motoru durumunu yakalayabilir.)*

This minimizes timing ambiguity. *(Bu zamanlama belirsizliğini azaltır.)*

---

# 124. Recovery Event Ordering (Recovery Olay Sıralaması)

The recovery subsystem will enforce a strict event ordering. *(Recovery alt sistemi katı olay sıralaması uygulayacaktır.)*

```text
1. recovery_requested
2. candidate_observed
3. candidate_validated
4. reference_accepted
5. pre_state_captured
6. recovery_error_calculated
7. relocalization_started
8. relocalization_completed
9. estimator_gnss_access_restored
```

---

# 125. Sequence Violation (Sıra İhlali)

If relocalization occurs before step 6, the formal recovery event will be considered invalid for benchmark evidence. *(Relocalization 6. adımdan önce gerçekleşirse resmî recovery olayı benchmark kanıtı için geçersiz kabul edilecektir.)*

---

# 126. Recovery Transaction Concept (Recovery Transaction Kavramı)

Recovery may be implemented as a small transactional workflow. *(Recovery küçük transactional iş akışı olarak uygulanabilir.)*

Either the critical pre-correction evidence is successfully persisted before relocalization, or the formal correction is delayed. *(Ya kritik düzeltme öncesi kanıt relocalization öncesinde başarıyla saklanır ya da resmî düzeltme geciktirilir.)*

---

# 127. Persistence Before Correction (Düzeltmeden Önce Persist Etme)

For formal Benchmark Mode, the system should persist the recovery event's critical pre-correction fields before applying irreversible current-state changes. *(Resmî Benchmark Modunda sistem geri döndürülemez mevcut durum değişikliklerini uygulamadan önce recovery olayının kritik düzeltme öncesi alanlarını persist etmelidir.)*

---

# 128. Logging Failure During Recovery (Recovery Sırasında Logging Hatası)

If critical recovery evidence cannot be stored, the system may mark the benchmark recovery event invalid even if navigation itself can continue. *(Kritik recovery kanıtı saklanamazsa navigasyon devam edebilse bile sistem benchmark recovery olayını geçersiz işaretleyebilir.)*

---

# 129. Navigation Safety Versus Research Validity (Navigasyon Güvenliği ile Araştırma Geçerliliği)

Research logging failure and navigation failure are different conditions. *(Araştırma logging hatası ile navigasyon hatası farklı koşullardır.)*

The system may continue navigation while marking the session or recovery metric invalid for research. *(Sistem oturumu veya recovery metriğini araştırma için geçersiz işaretlerken navigasyona devam edebilir.)*

---

# 130. Recovery Logging Files (Recovery Logging Dosyaları)

A dedicated recovery event log is recommended. *(Özel recovery olay logu önerilir.)*

```text
processed/gnss_recovery_events.csv
```

---

# 131. Recovery Event Log Fields (Recovery Olay Log Alanları)

```text
recovery_id,
attempt_id,
request_timestamp_ns,
reference_timestamp_ns,
pre_correction_timestamp_ns,
relocalization_timestamp_ns,
reference_latitude,
reference_longitude,
reference_accuracy_m,
reference_east_m,
reference_north_m,
pre_east_m,
pre_north_m,
error_east_m,
error_north_m,
horizontal_error_m,
relocalization_method,
success,
failure_reason
```

---

# 132. Recovery Candidate Log (Recovery Aday Logu)

Development sessions may also retain all evaluated candidate fixes. *(Development oturumları değerlendirilen tüm aday fix'leri de koruyabilir.)*

```text
processed/gnss_recovery_candidates.csv
```

---

# 133. Candidate Rejection Traceability (Aday Reddetme İzlenebilirliği)

Every rejected candidate should record a rejection reason. *(Her reddedilen aday reddetme nedenini kaydetmelidir.)*

---

# 134. Relocalization Event Log (Relocalization Olay Logu)

Relocalization may have a dedicated event record. *(Relocalization özel olay kaydına sahip olabilir.)*

```text
processed/relocalization_events.csv
```

---

# 135. Relocalization Event Fields (Relocalization Olay Alanları)

```text
timestamp_ns,
method,
pre_state_id,
post_state_id,
correction_east_m,
correction_north_m,
anchor_before,
anchor_after,
covariance_policy,
success
```

---

# 136. Recovery State Snapshot (Recovery Durum Snapshot'ı)

```text
RecoveryState
- state
- attemptId
- candidateCount
- acceptedReference
- elapsedTime
- lastFailureReason
```

---

# 137. Flutter Recovery Snapshot (Flutter Recovery Snapshot'ı)

Flutter may receive a compact immutable recovery snapshot for UI. *(Flutter UI için kompakt değişmez recovery snapshot'ı alabilir.)*

---

# 138. Flutter Does Not Decide Recovery Validity (Flutter Recovery Geçerliliğine Karar Vermez)

Recovery acceptance remains a navigation-domain decision rather than a UI decision. *(Recovery kabulü UI kararı yerine navigasyon-domain kararı olarak kalır.)*

---

# 139. Recovery Controls (Recovery Kontrolleri)

The first prototype may expose a manual `Recover GNSS` or equivalent experimental control. *(İlk prototip manuel `Recover GNSS` veya eşdeğer deneysel kontrol sunabilir.)*

Final wording will be specified in the UI document. *(Nihai metin UI dokümanında belirtilecektir.)*

---

# 140. Manual Recovery Must Be Logged (Manuel Recovery Kaydedilmelidir)

The exact time of the operator's recovery request must be stored. *(Operatörün recovery isteğinin kesin zamanı saklanmalıdır.)*

---

# 141. Recovery Cancellation (Recovery İptali)

A pending recovery attempt may be cancelled before relocalization. *(Bekleyen recovery denemesi relocalization öncesinde iptal edilebilir.)*

Cancellation does not restore GNSS estimator access. *(İptal GNSS tahmin motoru erişimini geri açmaz.)*

---

# 142. Recovery Cancellation State (Recovery İptal Durumu)

After cancellation, the system returns to the appropriate local-navigation state. *(İptal sonrasında sistem uygun yerel navigasyon durumuna döner.)*

---

# 143. Recovery During Degraded Local Navigation (Bozulmuş Yerel Navigasyon Sırasında Recovery)

Recovery is particularly important when local position quality has become poor. *(Recovery özellikle yerel konum kalitesi kötüleştiğinde önemlidir.)*

The same GNSS validation rules still apply. *(Aynı GNSS validation kuralları yine uygulanır.)*

---

# 144. Recovery Does Not Depend on Current Estimate Quality (Recovery Mevcut Tahmin Kalitesine Bağlı Değildir)

Even a highly uncertain or invalid local estimate may still be recoverable using a strong absolute reference. *(Çok belirsiz veya geçersiz yerel tahmin bile güçlü mutlak referans kullanılarak recover edilebilir.)*

---

# 145. Recovery from Invalid Position (Geçersiz Konumdan Recovery)

If the local estimator becomes invalid but the session remains active, successful GNSS recovery may reinitialize a valid position state. *(Yerel tahmin motoru geçersiz hale gelir ancak oturum aktif kalırsa başarılı GNSS recovery geçerli konum durumunu yeniden initialize edebilir.)*

---

# 146. Invalid-State Recovery Must Be Marked (Geçersiz Durum Recovery İşaretlenmelidir)

Recovery from an invalid estimator state must be distinguished from ordinary correction of a still-valid drifted state. *(Geçersiz tahmin motoru durumundan recovery hâlâ geçerli drift etmiş durumun normal düzeltmesinden ayırt edilmelidir.)*

---

# 147. Recovery Method Field (Recovery Yöntem Alanı)

```text
RECOVERY_FROM_VALID_STATE
RECOVERY_FROM_DEGRADED_STATE
RECOVERY_FROM_INVALID_STATE
```

---

# 148. EKF Reinitialization Candidate (EKF Yeniden Initialization Adayı)

If the EKF is numerically invalid, a complete state reinitialization from the accepted GNSS reference may be required. *(EKF sayısal olarak geçersizse kabul edilen GNSS referansından tam durum yeniden initialization gerekebilir.)*

---

# 149. Reinitialization Is Different from Correction (Reinitialization Düzeltmeden Farklıdır)

A complete filter reinitialization must be recorded explicitly. *(Tam filtre yeniden initialization açık şekilde kaydedilmelidir.)*

---

# 150. Reinitialization State Policy (Yeniden Initialization Durum Politikası)

Position may be initialized from GNSS. *(Konum GNSS'ten initialize edilebilir.)*

Velocity, heading, and other states must use separately justified initialization rules. *(Velocity, heading ve diğer durumlar ayrı gerekçelendirilmiş initialization kurallarını kullanmalıdır.)*

---

# 151. Recovery While Stationary (Sabitken Recovery)

A stationary recovery may provide useful conditions for a stable GNSS reference and low-motion transition. *(Sabitken recovery kararlı GNSS referansı ve düşük hareketli geçiş için kullanışlı koşullar sağlayabilir.)*

---

# 152. Recovery While Moving (Hareket Halindeyken Recovery)

Recovery must also be able to operate while the user continues walking. *(Recovery kullanıcı yürümeye devam ederken de çalışabilmelidir.)*

The temporal alignment of the reference becomes more important in this case. *(Bu durumda referansın zamansal hizalaması daha önemli hale gelir.)*

---

# 153. No Forced Stop Requirement (Zorunlu Durma Gereksinimi Olmaması)

The minimum system will not require the user to stop physically before GNSS recovery unless experiments show this is necessary for reliable relocalization. *(Minimum sistem deneyler güvenilir relocalization için gerekli olduğunu göstermedikçe GNSS recovery öncesinde kullanıcının fiziksel olarak durmasını gerektirmeyecektir.)*

---

# 154. Recovery and Motion Context (Recovery ve Hareket Bağlamı)

Motion state may be recorded as recovery metadata. *(Hareket durumu recovery metadata bilgisi olarak kaydedilebilir.)*

It will not automatically determine whether GNSS is valid. *(GNSS'in geçerli olup olmadığını otomatik olarak belirlemeyecektir.)*

---

# 155. Recovery and ARCore (Recovery ve ARCore)

ARCore may continue tracking during GNSS recovery. *(ARCore GNSS recovery sırasında tracking'e devam edebilir.)*

Relocalization must define how the ARCore-to-ENU alignment behaves after the global state is corrected. *(Relocalization global durum düzeltildikten sonra ARCore-ENU hizalamasının nasıl davrandığını tanımlamalıdır.)*

---

# 156. ARCore Alignment Continuity (ARCore Hizalama Sürekliliği)

A global position correction should not falsely imply that ARCore's local world frame itself jumped physically. *(Global konum düzeltmesi ARCore'un yerel world frame'inin fiziksel olarak sıçradığını yanlış şekilde ima etmemelidir.)*

---

# 157. ARCore Alignment Update Candidate (ARCore Hizalama Güncelleme Adayı)

The mapping from the ARCore local frame to ENU may require a controlled transform update after relocalization. *(ARCore yerel frame'inden ENU'ya eşleme relocalization sonrasında kontrollü transform update gerektirebilir.)*

The exact policy will depend on the final ARCore fusion implementation. *(Kesin politika nihai ARCore füzyon uygulamasına bağlı olacaktır.)*

---

# 158. No ARCore History Rewrite (ARCore Geçmiş Yeniden Yazma Olmaması)

Historical ARCore-relative measurements will remain immutable. *(Geçmiş ARCore-relative ölçümler değişmez kalacaktır.)*

---

# 159. Recovery and Step Counter (Recovery ve Adım Sayacı)

GNSS recovery does not reset cumulative session step count. *(GNSS recovery birikimli oturum adım sayısını resetlemez.)*

---

# 160. Recovery and PDR Distance (Recovery ve PDR Mesafesi)

Cumulative PDR travelled distance may continue across the recovery event. *(Birikimli PDR kat edilen mesafe recovery olayı boyunca devam edebilir.)*

If a new segment starts after recovery, segment-specific distance may additionally reset. *(Recovery sonrasında yeni segment başlarsa segment özel mesafe ayrıca resetlenebilir.)*

---

# 161. Recovery and Baseline PDR (Recovery ve Temel PDR)

The raw baseline PDR trajectory should continue independently even if the fused state is relocalized. *(Ham temel PDR trajectory'si füzyonlu durum relocalize edilse bile bağımsız devam etmelidir.)*

This preserves the baseline comparison. *(Bu temel karşılaştırmayı korur.)*

---

# 162. Fused-State Correction Does Not Correct Baseline (Füzyonlu Durum Düzeltmesi Temeli Düzeltmez)

A fused recovery correction must not rewrite or reset the baseline PDR track used for benchmarking unless a new explicitly separated baseline segment is started. *(Füzyonlu recovery düzeltmesi yeni açık şekilde ayrılmış temel segment başlatılmadıkça benchmark için kullanılan temel PDR track'ini yeniden yazmamalı veya resetlememelidir.)*

---

# 163. Recovery Segmentation (Recovery Segmentasyonu)

A session may be divided into navigation segments separated by recovery events. *(Bir oturum recovery olaylarıyla ayrılan navigasyon segmentlerine bölünebilir.)*

```text
SEGMENT_01 — GNSS
SEGMENT_02 — DENIED
SEGMENT_03 — GNSS
SEGMENT_04 — DENIED
```

---

# 164. Multiple Denied Intervals Per Session (Oturum Başına Birden Fazla Kesintili Aralık)

The architecture may support more than one denied-recovery cycle in a single session. *(Mimari tek oturumda birden fazla denied-recovery döngüsünü destekleyebilir.)*

The first formal benchmark may use simpler one-denial sessions for easier analysis. *(İlk resmî benchmark daha kolay analiz için daha basit tek kesintili oturumlar kullanabilir.)*

---

# 165. Each Denied Interval Has Its Own ID (Her Kesintili Aralığın Kendi ID'si Vardır)

```text
DeniedInterval
- deniedIntervalId
- startTimestampNs
- recoveryAttemptId
- preCorrectionError
- endTimestampNs
```

---

# 166. Multi-Recovery Research Value (Çoklu Recovery Araştırma Değeri)

Multiple cycles may later test whether the system can repeatedly transition between absolute and local navigation without accumulating state-management errors. *(Birden fazla döngü daha sonra sistemin durum yönetimi hataları biriktirmeden mutlak ve yerel navigasyon arasında tekrar tekrar geçiş yapıp yapamadığını test edebilir.)*

---

# 167. Recovery Replay (Recovery Replay'i)

Replay must reproduce the same recovery validation and relocalization policy when using the same frozen configuration. *(Replay aynı sabitlenmiş yapılandırmayı kullanırken aynı recovery validation ve relocalization politikasını yeniden üretmelidir.)*

---

# 168. Replay Candidate Fix Visibility (Replay Aday Fix Görünürlüğü)

Replay may read the full recorded GNSS stream. *(Replay tam kaydedilmiş GNSS akışını okuyabilir.)*

However, it must expose samples to the estimator only according to the original authorization and recovery boundaries. *(Ancak örnekleri tahmin motoruna yalnızca orijinal authorization ve recovery sınırlarına göre sunmalıdır.)*

---

# 169. Replay Cannot Use Future GNSS (Replay Gelecekteki GNSS'i Kullanamaz)

The recovery algorithm may not use future GNSS samples that would not have been available at the corresponding live recovery time. *(Recovery algoritması karşılık gelen canlı recovery zamanında kullanılamayacak gelecekteki GNSS örneklerini kullanamaz.)*

---

# 170. Causal Recovery Validation (Nedensel Recovery Validation)

Formal replay of recovery will remain causal. *(Recovery'nin resmî replay'i nedensel kalacaktır.)*

---

# 171. Offline Diagnostic Recovery (Çevrimdışı Tanısal Recovery)

A non-causal offline analysis may inspect future GNSS samples to understand what happened. *(Nedensel olmayan çevrimdışı analiz ne olduğunu anlamak için gelecekteki GNSS örneklerini inceleyebilir.)*

Such analysis must be labeled diagnostic and cannot replace live benchmark results. *(Böyle analiz diagnostic olarak etiketlenmeli ve canlı benchmark sonuçlarının yerini alamaz.)*

---

# 172. Recovery Reproducibility (Recovery Tekrarlanabilirliği)

Given the same GNSS candidates, estimator state, timestamps, and recovery configuration, the same recovery decision should be reproduced. *(Aynı GNSS adayları, tahmin motoru durumu, zaman damgaları ve recovery yapılandırması verildiğinde aynı recovery kararı yeniden üretilmelidir.)*

---

# 173. Recovery Unit Test — Stale Fix (Recovery Birim Testi — Eski Fix)

A stale GNSS fix must be rejected when it exceeds the configured freshness limit. *(Eski GNSS fix'i yapılandırılmış güncellik sınırını aştığında reddedilmelidir.)*

---

# 174. Recovery Unit Test — Invalid Coordinate (Recovery Birim Testi — Geçersiz Koordinat)

Invalid latitude or longitude must be rejected. *(Geçersiz enlem veya boylam reddedilmelidir.)*

---

# 175. Recovery Unit Test — Poor Accuracy (Recovery Birim Testi — Kötü Accuracy)

A candidate beyond the frozen horizontal-accuracy threshold must not be accepted for relocalization. *(Sabitlenmiş yatay accuracy eşiğinin ötesindeki aday relocalization için kabul edilmemelidir.)*

---

# 176. Recovery Unit Test — Provider (Recovery Birim Testi — Provider)

A recovery fix from an unauthorized provider must be rejected in the formal GNSS recovery path. *(Yetkisiz provider'dan gelen recovery fix'i resmî GNSS recovery yolunda reddedilmelidir.)*

---

# 177. Recovery Unit Test — Multi-Fix Stability (Recovery Birim Testi — Multi-Fix Kararlılığı)

Synthetic stable and unstable fix clusters must produce the expected validation states. *(Sentetik kararlı ve kararsız fix kümeleri beklenen validation durumlarını üretmelidir.)*

---

# 178. Recovery Unit Test — Error Vector (Recovery Birim Testi — Hata Vektörü)

Known pre-correction and reference ENU coordinates must produce the expected `e_E`, `e_N`, and horizontal error. *(Bilinen düzeltme öncesi ve referans ENU koordinatları beklenen `e_E`, `e_N` ve yatay hatayı üretmelidir.)*

---

# 179. Recovery Unit Test — Authorization (Recovery Birim Testi — Authorization)

GNSS must remain blocked from the estimator during `RECOVERY_PENDING`. *(GNSS `RECOVERY_PENDING` sırasında tahmin motorundan engellenmiş kalmalıdır.)*

---

# 180. Recovery Unit Test — Pre-Correction Order (Recovery Birim Testi — Düzeltme Öncesi Sıra)

Relocalization must be rejected if the pre-correction evidence capture step has not completed in Benchmark Mode. *(Benchmark Modunda düzeltme öncesi kanıt yakalama adımı tamamlanmamışsa relocalization reddedilmelidir.)*

---

# 181. Relocalization Unit Test — Hard Snap (Relocalization Birim Testi — Hard Snap)

A known hard-snap reference must produce the expected post-correction position. *(Bilinen hard-snap referansı beklenen düzeltme sonrası konumu üretmelidir.)*

---

# 182. Relocalization Unit Test — Historical Integrity (Relocalization Birim Testi — Geçmiş Bütünlük)

Historical points committed before recovery must remain unchanged after correction. *(Recovery öncesinde kesinleşmiş geçmiş noktalar düzeltme sonrasında değişmeden kalmalıdır.)*

---

# 183. Relocalization Unit Test — Covariance (Relocalization Birim Testi — Kovaryans)

The configured covariance policy must produce the expected post-recovery covariance. *(Yapılandırılmış kovaryans politikası beklenen recovery sonrası kovaryansı üretmelidir.)*

---

# 184. Recovery Integration Test — Good Fix (Recovery Entegrasyon Testi — İyi Fix)

A valid recovery reference must progress through validation, evidence capture, error calculation, relocalization, and GNSS restoration in the correct order. *(Geçerli recovery referansı validation, kanıt yakalama, hata hesaplama, relocalization ve GNSS geri açılma aşamalarından doğru sırada geçmelidir.)*

---

# 185. Recovery Integration Test — Bad Fix Then Good Fix (Recovery Entegrasyon Testi — Kötü Fix Sonra İyi Fix)

A rejected poor candidate must not prevent a later valid candidate from succeeding. *(Reddedilmiş kötü aday daha sonraki geçerli adayın başarılı olmasını engellememelidir.)*

---

# 186. Recovery Integration Test — Timeout (Recovery Entegrasyon Testi — Timeout)

A recovery timeout must not silently authorize GNSS estimator updates. *(Recovery timeout'u GNSS tahmin motoru update'lerini sessizce authorize etmemelidir.)*

---

# 187. Recovery Integration Test — Logging Failure (Recovery Entegrasyon Testi — Logging Hatası)

A forced critical evidence-write failure must produce the configured research-validity state. *(Zorlanmış kritik kanıt yazma hatası yapılandırılmış araştırma geçerlilik durumunu üretmelidir.)*

---

# 188. Recovery Integration Test — Moving User (Recovery Entegrasyon Testi — Hareketli Kullanıcı)

Recovery while walking must preserve temporal consistency between estimator and accepted GNSS reference. *(Yürürken recovery tahmin motoru ile kabul edilmiş GNSS referansı arasında zamansal tutarlılığı korumalıdır.)*

---

# 189. Recovery Integration Test — ARCore Active (Recovery Entegrasyon Testi — ARCore Aktif)

GNSS relocalization must not corrupt the ARCore local pose stream. *(GNSS relocalization ARCore yerel pose akışını bozmamalıdır.)*

---

# 190. Recovery Integration Test — Baseline Independence (Recovery Entegrasyon Testi — Temel Bağımsızlığı)

Fused relocalization must not alter the separately logged baseline PDR trajectory. *(Füzyonlu relocalization ayrı kaydedilmiş temel PDR trajectory'sini değiştirmemelidir.)*

---

# 191. Recovery Integration Test — Replay (Recovery Entegrasyon Testi — Replay)

The same frozen replay inputs must reproduce the same accepted recovery reference and relocalization event. *(Aynı sabitlenmiş replay girdileri aynı kabul edilmiş recovery referansını ve relocalization olayını yeniden üretmelidir.)*

---

# 192. Recovery Field Test — Short Denial (Recovery Saha Testi — Kısa Kesinti)

A short denied interval will test normal low-drift recovery behavior. *(Kısa kesintili aralık normal düşük-drift recovery davranışını test edecektir.)*

---

# 193. Recovery Field Test — Longer Denial (Recovery Saha Testi — Daha Uzun Kesinti)

A longer denied interval will test recovery from larger accumulated drift. *(Daha uzun kesintili aralık daha büyük birikmiş drift'ten recovery'yi test edecektir.)*

---

# 194. Recovery Field Test — Turn-Heavy Route (Recovery Saha Testi — Dönüş Yoğun Rota)

A turn-heavy route will test relocalization after significant heading-related drift. *(Dönüş yoğun rota anlamlı yön kaynaklı drift sonrasında relocalization'ı test edecektir.)*

---

# 195. Recovery Field Test — Weak GNSS Environment (Recovery Saha Testi — Zayıf GNSS Ortamı)

A naturally weak GNSS environment may be used to test rejection of poor recovery references without intentionally interfering with RF signals. *(Doğal olarak zayıf GNSS ortamı RF sinyallerine kasıtlı müdahale etmeden kötü recovery referanslarının reddedilmesini test etmek için kullanılabilir.)*

---

# 196. Recovery Field Test — Continuous Evaluation GNSS (Recovery Saha Testi — Sürekli Evaluation GNSS)

Evaluation Mode will test the case where GNSS was continuously logged but estimator authorization remained blocked throughout the denied interval. *(Evaluation Mode GNSS'in sürekli kaydedildiği ancak tahmin motoru authorization'ın kesintili aralık boyunca blocked kaldığı durumu test edecektir.)*

---

# 197. Recovery Field Test — Repeated Cycles (Recovery Saha Testi — Tekrarlanan Döngüler)

Optional repeated denied-recovery cycles may test state-machine robustness. *(İsteğe bağlı tekrarlanan denied-recovery döngüleri state-machine dayanıklılığını test edebilir.)*

---

# 198. Recovery Metrics (Recovery Metrikleri)

Formal recovery evaluation may include pre-correction horizontal error. *(Resmî recovery değerlendirmesi düzeltme öncesi yatay hatayı içerebilir.)*

It may include recovery-reference accuracy. *(Recovery referans accuracy değerini içerebilir.)*

It may include recovery latency. *(Recovery gecikmesini içerebilir.)*

It may include relocalization latency. *(Relocalization gecikmesini içerebilir.)*

---

# 199. Recovery Success Rate (Recovery Başarı Oranı)

```text
RecoverySuccessRate =
successful_attempts
────────────────── × 100
total_attempts
```

This metric will be meaningful only under a clearly defined recovery protocol. *(Bu metrik yalnızca açıkça tanımlanmış recovery protokolü altında anlamlı olacaktır.)*

---

# 200. Candidate Rejection Rate (Aday Reddetme Oranı)

```text
CandidateRejectionRate =
rejected_candidates
─────────────────── × 100
all_candidates
```

This may help tune overly strict or overly permissive validation policies during development. *(Bu geliştirme sırasında aşırı katı veya aşırı gevşek validation politikalarını ayarlamaya yardımcı olabilir.)*

---

# 201. Recovery Evaluation Table (Recovery Değerlendirme Tablosu)

```text
Session
Denied Duration
Denied Distance
Recovery Method
Reference Accuracy
Pre-Correction Error
Recovery Latency
Relocalization Latency
Post-Recovery Quality
Success
```

---

# 202. Relocalization Comparison Table (Relocalization Karşılaştırma Tablosu)

```text
Method
Discontinuity Magnitude
Post-Recovery Covariance
Runtime Complexity
Stability
Navigation Continuity
Implementation Complexity
```

---

# 203. Hard Snap vs Measurement Update Experiment (Hard Snap ile Measurement Update Deneyi)

Development testing may compare direct hard correction against EKF measurement-based correction. *(Geliştirme testleri doğrudan hard correction ile EKF measurement tabanlı correction'ı karşılaştırabilir.)*

---

# 204. Comparison Must Use Matched Sessions (Karşılaştırma Eşleşmiş Oturumları Kullanmalıdır)

Relocalization methods should be compared through replay on identical recorded denied intervals where practical. *(Relocalization yöntemleri uygulanabilir olduğunda aynı kaydedilmiş kesintili aralıklar üzerinde replay yoluyla karşılaştırılmalıdır.)*

---

# 205. Final Relocalization Selection Rule (Nihai Relocalization Seçim Kuralı)

The final method will favor deterministic behavior, estimator consistency, low implementation risk, and clean experimental interpretation. *(Nihai yöntem deterministik davranışı, tahmin motoru tutarlılığını, düşük uygulama riskini ve temiz deneysel yorumu tercih edecektir.)*

---

# 206. No Complex Correction Without Benefit (Fayda Olmadan Karmaşık Düzeltme Olmaması)

A complicated soft-correction method will not be retained unless it produces measurable operational benefit over a simpler correction. *(Karmaşık soft-correction yöntemi daha basit düzeltmeye göre ölçülebilir operasyonel fayda üretmedikçe korunmayacaktır.)*

---

# 207. Recovery Test IDs (Recovery Test ID'leri)

```text
REC-VAL-001   Provider validation
REC-VAL-002   Timestamp freshness
REC-VAL-003   Horizontal accuracy
REC-VAL-004   Coordinate validity
REC-VAL-005   Stable-fix window
REC-VAL-006   Candidate rejection

REC-FW-001    GNSS blocked in recovery pending
REC-FW-002    Ground-truth logging continues
REC-FW-003    Controlled authorization restoration

REC-ERR-001   Pre-correction state capture
REC-ERR-002   ENU reference conversion
REC-ERR-003   East/North error calculation
REC-ERR-004   Horizontal recovery error
REC-ERR-005   Evidence persisted before correction

REC-REL-001   Hard correction
REC-REL-002   EKF measurement correction
REC-REL-003   covariance update
REC-REL-004   historical trajectory immutability
REC-REL-005   anchor continuity
REC-REL-006   optional re-anchor

REC-FAIL-001  recovery timeout
REC-FAIL-002  no valid fix
REC-FAIL-003  logging failure
REC-FAIL-004  relocalization failure
REC-FAIL-005  invalid estimator recovery

REC-REP-001   deterministic recovery replay
REC-REP-002   causal GNSS exposure
REC-REP-003   future GNSS blocked

REC-UI-001    pending state
REC-UI-002    relocalization state
REC-UI-003    restored state

REC-NAV-001   baseline PDR independence
REC-NAV-002   ARCore continuity
REC-NAV-003   repeated denied-recovery cycle
```

---

# 208. Recovery Validation Acceptance Criteria (Recovery Validation Kabul Kriterleri)

An accepted recovery reference must satisfy the frozen provider, freshness, coordinate-validity, and quality policies. *(Kabul edilmiş recovery referansı sabitlenmiş provider, güncellik, koordinat geçerliliği ve kalite politikalarını karşılamalıdır.)*

---

# 209. Ground Truth Firewall Acceptance Criteria (Ground Truth Firewall Kabul Kriterleri)

GNSS must remain blocked from estimator updates until the pre-correction comparison has been completed. *(Düzeltme öncesi karşılaştırma tamamlanana kadar GNSS tahmin motoru update'lerinden engellenmiş kalmalıdır.)*

---

# 210. Error Capture Acceptance Criteria (Hata Yakalama Kabul Kriterleri)

The pre-correction estimator position must be stored before relocalization. *(Düzeltme öncesi tahmin motoru konumu relocalization öncesinde saklanmalıdır.)*

The accepted recovery reference must be transformed into the same ENU frame. *(Kabul edilmiş recovery referansı aynı ENU frame'ine dönüştürülmelidir.)*

---

# 211. Recovery Error Acceptance Criteria (Recovery Hatası Kabul Kriterleri)

East error, North error, and horizontal error must be calculated before correction. *(East hatası, North hatası ve yatay hata düzeltmeden önce hesaplanmalıdır.)*

---

# 212. Historical Integrity Acceptance Criteria (Geçmiş Bütünlük Kabul Kriterleri)

No relocalization method may retroactively rewrite committed denied-navigation trajectory points. *(Hiçbir relocalization yöntemi kesinleşmiş kesintili navigasyon trajectory noktalarını geriye dönük yeniden yazamaz.)*

---

# 213. Covariance Acceptance Criteria (Kovaryans Kabul Kriterleri)

Post-recovery covariance must be produced by an explicit documented policy. *(Recovery sonrası kovaryans açık dokümante edilmiş politika tarafından üretilmelidir.)*

Zero uncertainty after recovery is forbidden. *(Recovery sonrasında sıfır belirsizlik yasaktır.)*

---

# 214. Anchor Acceptance Criteria (Anchor Kabul Kriterleri)

If a new anchor is created, both old and new anchors must remain traceable. *(Yeni anchor oluşturulursa hem eski hem yeni anchor izlenebilir kalmalıdır.)*

Historical points must preserve their original anchor association. *(Geçmiş noktalar orijinal anchor ilişkilerini korumalıdır.)*

---

# 215. Recovery Failure Acceptance Criteria (Recovery Hatası Kabul Kriterleri)

Failure to obtain a valid GNSS reference must not force acceptance of poor data. *(Geçerli GNSS referansı elde edilememesi kötü verinin kabulünü zorlamamalıdır.)*

---

# 216. Replay Acceptance Criteria (Replay Kabul Kriterleri)

Recovery replay must remain causal and enforce the original Ground Truth Firewall. *(Recovery replay nedensel kalmalı ve orijinal Ground Truth Firewall'u uygulamalıdır.)*

---

# 217. Research Integrity Acceptance Criteria (Araştırma Bütünlüğü Kabul Kriterleri)

Recovery thresholds and candidate-selection policy must be frozen before final benchmark results are inspected. *(Recovery eşikleri ve aday seçim politikası nihai benchmark sonuçları incelenmeden önce sabitlenmelidir.)*

---

# 218. Minimum Successful Recovery System (Minimum Başarılı Recovery Sistemi)

The minimum successful implementation will support manual recovery request, validated GNSS reference selection, pre-correction error capture, controlled position correction, historical trajectory preservation, and restoration of GNSS estimator access. *(Minimum başarılı uygulama manuel recovery isteğini, doğrulanmış GNSS referans seçimini, düzeltme öncesi hata yakalamayı, kontrollü konum düzeltmesini, geçmiş trajectory korumayı ve GNSS tahmin motoru erişiminin geri açılmasını destekleyecektir.)*

---

# 219. Target Successful Recovery System (Hedef Başarılı Recovery Sistemi)

The target system will additionally support multi-fix stability validation, explicit covariance handling, replay-deterministic recovery, optional re-anchoring, ARCore alignment continuity, and detailed recovery diagnostics. *(Hedef sistem ek olarak multi-fix kararlılık validation'ı, açık kovaryans yönetimi, replay-deterministic recovery, isteğe bağlı re-anchor, ARCore hizalama sürekliliği ve ayrıntılı recovery diagnostics destekleyecektir.)*

---

# 220. Optional Recovery Enhancements (İsteğe Bağlı Recovery İyileştirmeleri)

Optional enhancements may include automatic recovery triggering. *(İsteğe bağlı iyileştirmeler otomatik recovery triggering içerebilir.)*

Optional enhancements may include advanced GNSS stability scoring. *(İsteğe bağlı iyileştirmeler gelişmiş GNSS kararlılık scoring içerebilir.)*

Optional enhancements may include estimator-consistent gradual relocalization. *(İsteğe bağlı iyileştirmeler tahmin motoruyla tutarlı kademeli relocalization içerebilir.)*

---

# 221. Recovery Non-Goals (Recovery Olmayan Hedefler)

NAVGUARD will not use RF jamming to produce or recover GNSS loss. *(NAVGUARD GNSS kaybı oluşturmak veya recover etmek için RF jamming kullanmayacaktır.)*

NAVGUARD will not blindly trust the first GNSS sample after denial. *(NAVGUARD kesintiden sonraki ilk GNSS örneğine kör şekilde güvenmeyecektir.)*

NAVGUARD will not rewrite historical trajectory to hide drift. *(NAVGUARD drift'i gizlemek için geçmiş trajectory'yi yeniden yazmayacaktır.)*

---

# 222. Additional Non-Goals (Ek Olmayan Hedefler)

NAVGUARD will not select recovery fixes after the fact based on which one minimizes reported error. *(NAVGUARD sonradan raporlanan hatayı en aza indiren recovery fix'ine göre seçim yapmayacaktır.)*

GNSS movement or travel bearing must never be used to correct, reset, replace, or initialize the NAVGUARD phone/body heading state during recovery. No independent justification, manual action, recovery condition, motion gate, speed gate, quality gate, or non-default path can authorize GNSS bearing as a phone-heading input. *(GNSS movement veya travel bearing recovery sırasında NAVGUARD phone/body heading state'ini düzeltmek, resetlemek, değiştirmek veya initialize etmek için hiçbir zaman kullanılmamalıdır. Hiçbir independent justification, manual action, recovery condition, motion gate, speed gate, quality gate veya non-default path GNSS bearing'i phone-heading input olarak authorize edemez.)*

---

# 223. Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kararlar)

GNSS recovery will be a controlled state-machine process rather than an immediate acceptance of the first GNSS fix. *(GNSS recovery ilk GNSS fix'inin anında kabulü yerine kontrollü state-machine süreci olacaktır.)*

---

# 224. Firewall Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Firewall Kararları)

GNSS estimator access will remain blocked during `GNSS_RECOVERY_PENDING`. *(GNSS tahmin motoru erişimi `GNSS_RECOVERY_PENDING` sırasında blocked kalacaktır.)*

GNSS may become estimator-authorized only after pre-correction recovery evidence has been captured. *(GNSS yalnızca düzeltme öncesi recovery kanıtı yakalandıktan sonra tahmin motoru için authorize edilebilir.)*

---

# 225. Recovery Reference Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Recovery Referans Kararları)

Recovery references must pass provider, timestamp, coordinate, freshness, and quality validation. *(Recovery referansları provider, zaman damgası, koordinat, güncellik ve kalite validation'ını geçmelidir.)*

---

# 226. Error Measurement Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Hata Ölçüm Kararları)

The accepted recovery reference will be transformed into the original active ENU frame before error calculation. *(Kabul edilen recovery referansı hata hesabından önce orijinal aktif ENU frame'ine dönüştürülecektir.)*

Pre-correction East, North, and horizontal error will be recorded before relocalization. *(Düzeltme öncesi East, North ve yatay hata relocalization öncesinde kaydedilecektir.)*

---

# 227. Historical Integrity Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Geçmiş Bütünlük Kararları)

Historical denied-navigation trajectory points will remain immutable after recovery. *(Geçmiş kesintili navigasyon trajectory noktaları recovery sonrasında değişmez kalacaktır.)*

---

# 228. Baseline Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Temel Model Kararları)

Fused relocalization will not overwrite the separately logged baseline PDR trajectory. *(Füzyonlu relocalization ayrı kaydedilmiş temel PDR trajectory'sinin üzerine yazmayacaktır.)*

---

# 229. Covariance Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kovaryans Kararları)

Recovery will never reset position uncertainty to zero. *(Recovery konum belirsizliğini hiçbir zaman sıfıra resetlemeyecektir.)*

The covariance update method will be explicit and versioned. *(Kovaryans update yöntemi açık ve sürümlenmiş olacaktır.)*

---

# 230. Heading Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Yön Kararları)

GNSS movement or travel bearing must never correct, reset, replace, or initialize the phone-heading state during relocalization; it remains diagnostic-only under the explicitly authorized contexts defined by this document. *(GNSS movement veya travel bearing relocalization sırasında phone-heading state'ini hiçbir zaman düzeltemez, resetleyemez, değiştiremez veya initialize edemez; yalnızca bu dokümanda açıkça authorize edilen context'lerde diagnostic-only olarak kalır.)*

---

# 231. Anchor Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Anchor Kararları)

Recovery validation will use the original denied-navigation anchor for pre-correction error calculation. *(Recovery validation düzeltme öncesi hata hesabı için orijinal kesintili navigasyon anchor'ını kullanacaktır.)*

If a new anchor is created later, the original anchor remains preserved. *(Daha sonra yeni anchor oluşturulursa orijinal anchor korunmuş kalacaktır.)*

---

# 232. Replay Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Replay Kararları)

Replay recovery will remain causal. *(Replay recovery nedensel kalacaktır.)*

Future GNSS samples unavailable at the live recovery time cannot influence the replay recovery decision. *(Canlı recovery zamanında kullanılamayan gelecekteki GNSS örnekleri replay recovery kararını etkileyemez.)*

---

# 233. Logging Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Logging Kararları)

Every formal recovery attempt will have a traceable attempt ID and result. *(Her resmî recovery denemesi izlenebilir attempt ID ve sonuca sahip olacaktır.)*

Successful recovery events will store pre-correction state, reference state, error, and relocalization method. *(Başarılı recovery olayları düzeltme öncesi durumu, referans durumunu, hatayı ve relocalization yöntemini saklayacaktır.)*

---

# 234. Decisions Pending Device Measurements (Cihaz Ölçümlerini Bekleyen Kararlar)

The maximum acceptable GNSS fix age remains pending Redmi Note 9 Pro measurements. *(Maksimum kabul edilebilir GNSS fix yaşı Redmi Note 9 Pro ölçümlerini beklemektedir.)*

The final horizontal accuracy threshold remains pending field data. *(Nihai yatay accuracy eşiği saha verisini beklemektedir.)*

---

# 235. Decisions Pending Recovery Pilot Tests (Recovery Pilot Testlerini Bekleyen Kararlar)

The minimum stable fix count remains pending recovery experiments. *(Minimum kararlı fix sayısı recovery deneylerini beklemektedir.)*

The stability-window duration remains pending recovery experiments. *(Kararlılık pencere süresi recovery deneylerini beklemektedir.)*

The maximum acceptable fix-cluster spread remains pending recovery experiments. *(Maksimum kabul edilebilir fix kümesi saçılımı recovery deneylerini beklemektedir.)*

---

# 236. Decisions Pending Relocalization Comparison (Relocalization Karşılaştırmasını Bekleyen Kararlar)

The final relocalization method remains pending comparison between controlled hard correction and estimator-consistent measurement-based correction. *(Nihai relocalization yöntemi kontrollü hard correction ile tahmin motoruyla tutarlı measurement tabanlı correction arasındaki karşılaştırmayı beklemektedir.)*

---

# 237. Decisions Pending Covariance Calibration (Kovaryans Kalibrasyonunu Bekleyen Kararlar)

The final mapping from GNSS horizontal accuracy to recovery measurement covariance remains pending development calibration. *(GNSS yatay accuracy değerinden recovery measurement kovaryansına nihai eşleme geliştirme kalibrasyonunu beklemektedir.)*

---

# 238. Decisions Pending Anchor Strategy (Anchor Stratejisini Bekleyen Kararlar)

The final policy for creating a new anchor after successful recovery remains pending implementation and replay comparison. *(Başarılı recovery sonrasında yeni anchor oluşturma nihai politikası uygulama ve replay karşılaştırmasını beklemektedir.)*

---

# 239. Decisions Pending ARCore Integration (ARCore Entegrasyonunu Bekleyen Kararlar)

The exact ARCore-to-ENU alignment update policy after relocalization remains pending final ARCore fusion implementation. *(Relocalization sonrasında kesin ARCore-ENU hizalama update politikası nihai ARCore füzyon uygulamasını beklemektedir.)*

---

# 240. Final GNSS Recovery & Relocalization Architecture Statement (Nihai GNSS Recovery ve Relocalization Mimarisi Bildirimi)

**NAVGUARD will treat GNSS recovery as a controlled multi-stage authorization process in which candidate GNSS fixes can be observed and validated while estimator GNSS access remains blocked, preventing any absolute-position information from correcting the denied estimator before its true pre-correction error has been captured.** *(NAVGUARD GNSS recovery'yi aday GNSS fix'lerinin gözlemlenip doğrulanabildiği ancak tahmin motoru GNSS erişiminin blocked kaldığı kontrollü çok aşamalı authorization süreci olarak ele alacak ve gerçek düzeltme öncesi hata yakalanmadan herhangi bir mutlak konum bilgisinin kesintili tahmin motorunu düzeltmesini önleyecektir.)*

**A recovery reference will be accepted only after provider, timestamp, coordinate, freshness, horizontal-accuracy, and optional multi-fix stability validation, and the exact thresholds will be frozen from Redmi Note 9 Pro development evidence before final benchmark sessions.** *(Recovery referansı yalnızca provider, zaman damgası, koordinat, güncellik, yatay accuracy ve isteğe bağlı multi-fix kararlılık validation'ından sonra kabul edilecek ve kesin eşikler final benchmark oturumlarından önce Redmi Note 9 Pro geliştirme kanıtından sabitlenecektir.)*

**The accepted recovery reference will first be transformed into the original denied-navigation ENU frame, the current estimator position and covariance will be preserved as pre-correction evidence, East and North error will be calculated, horizontal recovery error will be recorded, and only then may relocalization modify the active estimator state.** *(Kabul edilen recovery referansı önce orijinal kesintili navigasyon ENU frame'ine dönüştürülecek, mevcut tahmin motoru konumu ve kovaryansı düzeltme öncesi kanıt olarak korunacak, East ve North hatası hesaplanacak, yatay recovery hatası kaydedilecek ve yalnızca bundan sonra relocalization aktif tahmin motoru durumunu değiştirebilecektir.)*

**The minimum relocalization implementation may use a controlled hard position correction after evidence capture, while the target design will compare that approach with an estimator-consistent EKF absolute-position measurement update before selecting the simplest stable final policy.** *(Minimum relocalization uygulaması kanıt yakalamadan sonra kontrollü hard position correction kullanabilirken hedef tasarım en basit kararlı nihai politikayı seçmeden önce bu yaklaşımı tahmin motoruyla tutarlı EKF mutlak konum measurement update'iyle karşılaştıracaktır.)*

**Position covariance will never be reset to zero after recovery, GNSS bearing will never correct, reset, replace, or initialize device heading, and any optional new geographic anchor will preserve the original anchor and all historical anchor associations.** *(Konum kovaryansı recovery sonrasında hiçbir zaman sıfıra resetlenmeyecek, GNSS bearing cihaz yönünü hiçbir zaman düzeltmeyecek, resetlemeyecek, değiştirmeyecek veya initialize etmeyecek ve isteğe bağlı yeni coğrafi anchor orijinal anchor'ı ve tüm geçmiş anchor ilişkilerini koruyacaktır.)*

**Historical denied-navigation trajectory points and the separately logged baseline PDR trajectory will remain immutable after relocalization, allowing the exact drift accumulated before GNSS recovery to remain auditable even though current navigation is subsequently corrected.** *(Geçmiş kesintili navigasyon trajectory noktaları ve ayrı kaydedilmiş temel PDR trajectory'si relocalization sonrasında değişmez kalacak, böylece mevcut navigasyon daha sonra düzeltilse bile GNSS recovery öncesinde biriken kesin drift denetlenebilir kalacaktır.)*

**Recovery replay will remain causal and deterministic, so recorded future GNSS samples cannot leak into an earlier recovery decision and the same frozen candidate stream and configuration will reproduce the same reference-selection and relocalization behavior.** *(Recovery replay nedensel ve deterministik kalacak, böylece kaydedilmiş gelecekteki GNSS örnekleri daha erken recovery kararına sızamayacak ve aynı sabitlenmiş aday akışı ve yapılandırma aynı referans seçim ve relocalization davranışını yeniden üretecektir.)*

---

# 241. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development GNSS Recovery & Relocalization Design Completed *(Doküman Durumu: Geliştirme Öncesi GNSS Recovery ve Relocalization Tasarımı Tamamlandı)*

**Recovery Philosophy:** Validate → Capture Error → Relocalize → Restore GNSS *(Recovery Felsefesi: Doğrula → Hatayı Yakala → Relocalize Et → GNSS'i Geri Aç)*

**First GNSS Fix Auto-Accept:** Forbidden *(İlk GNSS Fix'ini Otomatik Kabul: Yasak)*

**RF Jamming / Spoofing:** Forbidden *(RF Jamming / Spoofing: Yasak)*

**Recovery Pending GNSS Authorization:** `BLOCKED` *(Recovery Pending GNSS Authorization: `BLOCKED`)*

**Recovery Reference Inputs:** Provider + Timestamp + Coordinates + Accuracy + Quality *(Recovery Referans Girdileri: Provider + Zaman Damgası + Koordinatlar + Accuracy + Kalite)*

**Recovery Freshness Validation:** Mandatory *(Recovery Güncellik Validation: Zorunlu)*

**Recovery Accuracy Validation:** Mandatory *(Recovery Accuracy Validation: Zorunlu)*

**Multi-Fix Stability Validation:** Target / Pending Calibration *(Multi-Fix Kararlılık Validation: Hedef / Kalibrasyon Bekleniyor)*

**Recovery Comparison Frame:** Original Denied-Interval ENU Anchor *(Recovery Karşılaştırma Frame'i: Orijinal Kesintili Aralık ENU Anchor'ı)*

**Pre-Correction State Capture:** Mandatory *(Düzeltme Öncesi Durum Yakalama: Zorunlu)*

**Pre-Correction Covariance Capture:** Mandatory *(Düzeltme Öncesi Kovaryans Yakalama: Zorunlu)*

**East Recovery Error:** Mandatory *(East Recovery Hatası: Zorunlu)*

**North Recovery Error:** Mandatory *(North Recovery Hatası: Zorunlu)*

**Horizontal Recovery Error:** Mandatory *(Yatay Recovery Hatası: Zorunlu)*

**Error Measurement Before Correction:** Mandatory *(Düzeltmeden Önce Hata Ölçümü: Zorunlu)*

**Minimum Relocalization Method:** Controlled Hard Position Correction *(Minimum Relocalization Yöntemi: Kontrollü Hard Position Correction)*

**Target Relocalization Comparison:** Hard Correction vs EKF Measurement Update *(Hedef Relocalization Karşılaştırması: Hard Correction vs EKF Measurement Update)*

**Zero Covariance After Recovery:** Forbidden *(Recovery Sonrası Sıfır Kovaryans: Yasak)*

**GNSS Bearing → Device Heading Correction / Reset / Replacement / Initialization:** Forbidden *(GNSS Bearing → Cihaz Yön Düzeltme / Reset / Değiştirme / Initialization: Yasak)*

**Historical Denied Trajectory Rewrite:** Forbidden *(Geçmiş Kesintili Trajectory Yeniden Yazma: Yasak)*

**Baseline PDR Rewrite After Recovery:** Forbidden *(Recovery Sonrası Temel PDR Yeniden Yazma: Yasak)*

**Optional Re-Anchoring:** Supported in Target Design *(İsteğe Bağlı Re-Anchor: Hedef Tasarımda Destekleniyor)*

**Original Anchor Preservation:** Mandatory *(Orijinal Anchor Koruma: Zorunlu)*

**Recovery Replay:** Causal + Deterministic *(Recovery Replay: Nedensel + Deterministik)*

**Future GNSS Leakage During Replay:** Forbidden *(Replay Sırasında Gelecek GNSS Sızıntısı: Yasak)*

**Recovery Timeout Forcing Bad Fix:** Forbidden *(Recovery Timeout ile Kötü Fix Zorlama: Yasak)*

**Recovery Attempt Logging:** Mandatory *(Recovery Deneme Logging: Zorunlu)*

**Recovery Failure Reason:** Mandatory *(Recovery Hata Nedeni: Zorunlu)*

**Final Maximum Fix Age:** Pending Redmi Note 9 Pro Measurement *(Nihai Maksimum Fix Yaşı: Redmi Note 9 Pro Ölçümü Bekleniyor)*

**Final Horizontal Accuracy Threshold:** Pending Field Calibration *(Nihai Yatay Accuracy Eşiği: Saha Kalibrasyonu Bekleniyor)*

**Final Stable Fix Count:** Pending Pilot Recovery Tests *(Nihai Kararlı Fix Sayısı: Pilot Recovery Testleri Bekleniyor)*

**Final Recovery Window Duration:** Pending Pilot Recovery Tests *(Nihai Recovery Pencere Süresi: Pilot Recovery Testleri Bekleniyor)*

**Final Recovery Reference Selection Method:** Pending Development Comparison *(Nihai Recovery Referans Seçim Yöntemi: Geliştirme Karşılaştırması Bekleniyor)*

**Final Relocalization Method:** Pending Replay / Field Comparison *(Nihai Relocalization Yöntemi: Replay / Saha Karşılaştırması Bekleniyor)*

**Final GNSS Accuracy → EKF `R_rec` Mapping:** Pending Calibration *(Nihai GNSS Accuracy → EKF `R_rec` Eşlemesi: Kalibrasyon Bekleniyor)*

**Final Re-Anchoring Policy:** Pending Implementation Evaluation *(Nihai Re-Anchor Politikası: Uygulama Değerlendirmesi Bekleniyor)*

**Final ARCore Alignment Recovery Policy:** Pending ARCore Fusion Implementation *(Nihai ARCore Hizalama Recovery Politikası: ARCore Füzyon Uygulaması Bekleniyor)*

**Next Documentation Item:** 30 — Data Storage, Logging & Session Management *(Sonraki Dokümantasyon Öğesi: 30 — Veri Depolama, Logging ve Oturum Yönetimi)*
