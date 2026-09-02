# 28 — Position Estimation & Uncertainty Engine (Konum Tahmini ve Belirsizlik Motoru)

## 1. Document Purpose (Dokümanın Amacı)

This document defines how NAVGUARD will represent, update, validate, expose, log, visualize, compare, and interpret estimated position and its uncertainty during normal GNSS operation, GNSS-denied navigation, degraded navigation, replay, and GNSS recovery. *(Bu doküman NAVGUARD'ın normal GNSS çalışması, GNSS kesintili navigasyon, bozulmuş navigasyon, replay ve GNSS geri kazanımı sırasında tahmini konumu ve belirsizliğini nasıl temsil edeceğini, güncelleyeceğini, doğrulayacağını, sunacağını, kaydedeceğini, görselleştireceğini, karşılaştıracağını ve yorumlayacağını tanımlar.)*

The Position Estimation & Uncertainty Engine will be the authoritative domain component that converts navigation-state information into a user-consumable position estimate with explicit uncertainty and quality metadata. *(Konum Tahmini ve Belirsizlik Motoru navigasyon durum bilgisini açık belirsizlik ve kalite metadata bilgisiyle kullanıcı tarafından kullanılabilir konum tahminine dönüştüren ana domain bileşeni olacaktır.)*

---

# 2. Core Principle (Temel İlke)

NAVGUARD will never treat a GNSS-denied estimated position as an exact coordinate. *(NAVGUARD GNSS kesintili tahmini konumu hiçbir zaman kesin koordinat olarak ele almayacaktır.)*

Every active local-navigation estimate will have an associated quality and uncertainty state. *(Her aktif yerel navigasyon tahmini ilişkili kalite ve belirsizlik durumuna sahip olacaktır.)*

---

# 3. Position Is More Than Latitude and Longitude (Konum Yalnızca Enlem ve Boylam Değildir)

Internally, NAVGUARD will represent local position primarily in the fixed ENU coordinate frame established at the active GNSS anchor. *(NAVGUARD dahili olarak yerel konumu temel olarak aktif GNSS anchor'ında oluşturulan sabit ENU koordinat sisteminde temsil edecektir.)*

Latitude and longitude are geographic representations derived from that local state for mapping, export, comparison, and user display. *(Enlem ve boylam haritalama, dışa aktarma, karşılaştırma ve kullanıcı gösterimi için bu yerel durumdan türetilen coğrafi temsillerdir.)*

---

# 4. Authoritative Local Frame (Ana Yerel Koordinat Sistemi)

The authoritative denied-navigation horizontal frame will remain East-North-Up relative to the active anchor. *(Ana kesintili navigasyon yatay koordinat sistemi aktif anchor'a göre East-North-Up olarak kalacaktır.)*

For the core pedestrian problem, the primary estimated position is the horizontal pair `[E, N]`. *(Temel yaya problemi için temel tahmini konum yatay `[E, N]` çiftidir.)*

---

# 5. Geographic Projection Is an Output Transformation (Coğrafi Dönüşüm Bir Çıktı Dönüşümüdür)

The map coordinate does not drive the PDR or EKF state. *(Harita koordinatı PDR veya EKF durumunu yönlendirmez.)*

The estimated ENU position is transformed to WGS84 latitude and longitude using the mathematical conventions frozen in **14 — Coordinate Systems & Mathematical Foundations**. *(Tahmini ENU konumu **14 — Koordinat Sistemleri ve Matematiksel Temeller** bölümünde sabitlenen matematik kuralları kullanılarak WGS84 enlem ve boylama dönüştürülür.)*

---

# 6. Position Estimate Object (Konum Tahmin Nesnesi)

The engine will publish one normalized domain representation for current position estimates. *(Motor mevcut konum tahminleri için tek normalize edilmiş domain temsili yayınlayacaktır.)*

```text id="p28_001"
PositionEstimate
- timestampNs
- source
- mode
- eastM
- northM
- upM
- latitudeDeg
- longitudeDeg
- horizontalCovariance
- horizontalSigmaM
- uncertaintyEllipse
- confidenceLevel
- qualityState
- isValid
- isRelocalized
- anchorId
- estimatorProfile
```

Fields that are not available will remain explicitly unavailable instead of being fabricated. *(Kullanılamayan alanlar uydurulmak yerine açık şekilde kullanılamaz kalacaktır.)*

---

# 7. Estimate Source (Tahmin Kaynağı)

Every position estimate will identify its source category. *(Her konum tahmini kaynak kategorisini tanımlayacaktır.)*

```text id="p28_002"
GNSS
PDR
FUSED_EKF
ARCORE_RELATIVE
RELOCALIZED
REPLAY
```

The exact source set may be extended as implementation evolves. *(Kesin kaynak seti uygulama geliştikçe genişletilebilir.)*

---

# 8. Navigation Mode and Position Source Are Different (Navigasyon Modu ile Konum Kaynağı Farklıdır)

Navigation Mode describes what information is legally allowed to influence the estimator. *(Navigasyon Modu hangi bilginin tahmin motorunu etkilemesine izin verildiğini açıklar.)*

Position source describes which estimator produced the current position representation. *(Konum kaynağı mevcut konum temsilini hangi tahmin motorunun ürettiğini açıklar.)*

---

# 9. GNSS Mode Position (GNSS Modu Konumu)

In GNSS Mode, validated GNSS may be the primary absolute position source or may enter the fused estimator according to configuration. *(GNSS Modunda doğrulanmış GNSS temel mutlak konum kaynağı olabilir veya yapılandırmaya göre füzyon tahmin motoruna girebilir.)*

The engine will still retain local ENU state for continuity and comparison. *(Motor süreklilik ve karşılaştırma için yine de yerel ENU durumunu koruyacaktır.)*

---

# 10. GNSS-Denied Position (GNSS Kesintili Konum)

During active GNSS-denied navigation, current position will be produced entirely from authorized non-GNSS estimator inputs. *(Aktif GNSS kesintili navigasyon sırasında mevcut konum tamamen izin verilen GNSS dışı tahmin motoru girdilerinden üretilecektir.)*

Protected Evaluation Mode GNSS ground truth will not influence this position. *(Korunan Evaluation Mode GNSS ground truth bu konumu etkilemeyecektir.)*

---

# 11. Evaluation Mode Position Separation (Evaluation Mode Konum Ayrımı)

Evaluation Mode will maintain at least two logically separate position streams. *(Evaluation Mode en az iki mantıksal olarak ayrı konum akışı tutacaktır.)*

The first will be the NAVGUARD estimate. *(Birincisi NAVGUARD tahmini olacaktır.)*

The second will be the independent GNSS ground-truth/reference stream. *(İkincisi bağımsız GNSS ground-truth/referans akışı olacaktır.)*

---

# 12. No Ground Truth Feedback (Ground Truth Geri Beslemesi Olmaması)

Ground-truth error calculation will be performed outside the protected estimator path. *(Ground-truth hata hesabı korunan tahmin motoru yolunun dışında gerçekleştirilecektir.)*

The result of that comparison will not be fed back into the denied estimator until a controlled recovery or relocalization event explicitly permits it. *(Bu karşılaştırmanın sonucu kontrollü recovery veya relocalization olayı açıkça izin verene kadar kesintili tahmin motoruna geri beslenmeyecektir.)*

---

# 13. Baseline and Fused Trajectories Remain Separate (Temel ve Füzyonlu Trajectory'ler Ayrı Kalır)

NAVGUARD will preserve the raw baseline PDR trajectory separately from the fused EKF trajectory. *(NAVGUARD ham temel PDR trajectory'sini füzyonlu EKF trajectory'sinden ayrı koruyacaktır.)*

A fused correction must not overwrite the historical baseline trajectory used for comparison. *(Bir füzyon düzeltmesi karşılaştırma için kullanılan geçmiş temel trajectory'nin üzerine yazmamalıdır.)*

---

# 14. Why Separate Trajectories Matter (Ayrı Trajectory'ler Neden Önemlidir)

Keeping independent trajectories allows direct comparison between PDR-only and improved configurations on the same physical session. *(Bağımsız trajectory'leri korumak aynı fiziksel oturum üzerinde yalnızca PDR ve iyileştirilmiş yapılandırmalar arasında doğrudan karşılaştırmaya izin verir.)*

This is required for the A-D benchmark design. *(Bu A-D benchmark tasarımı için gereklidir.)*

---

# 15. Fused State Ownership (Füzyonlu Durum Sahipliği)

The EKF defined in **21 — Sensor Fusion & Extended Kalman Filter** remains the authoritative owner of the fused stochastic navigation state. *(**21 — Sensör Füzyonu ve Extended Kalman Filter** bölümünde tanımlanan EKF füzyonlu stokastik navigasyon durumunun ana sahibi olarak kalır.)*

The Position Estimation & Uncertainty Engine interprets and exposes that state rather than duplicating the filter. *(Konum Tahmini ve Belirsizlik Motoru filtreyi duplicate etmek yerine bu durumu yorumlar ve sunar.)*

---

# 16. Candidate EKF State (Aday EKF Durumu)

The current candidate EKF state remains as follows. *(Mevcut aday EKF durumu aşağıdaki gibi kalmaktadır.)*

```text id="p28_003"
x =

[ E  ]
[ N  ]
[ vE ]
[ vN ]
[ ψ  ]
```

Additional bias or scale states may be added only if experiments justify them. *(Ek bias veya scale durumları yalnızca deneyler gerekçelendirirse eklenebilir.)*

---

# 17. State Covariance (Durum Kovaryansı)

The EKF maintains state covariance `P`. *(EKF durum kovaryansı `P` değerini korur.)*

```text id="p28_004"
P ∈ R^(n×n)
```

`P` describes modeled uncertainty and correlations among the estimated states. *(`P` tahmin edilen durumlar arasındaki modellenmiş belirsizliği ve korelasyonları açıklar.)*

---

# 18. Horizontal Position Covariance (Yatay Konum Kovaryansı)

For the candidate state ordering, the horizontal position covariance block will be extracted from the East and North state dimensions. *(Aday durum sırası için yatay konum kovaryans bloğu East ve North durum boyutlarından çıkarılacaktır.)*

```text id="p28_005"
P_EN =

[ P_EE  P_EN ]
[ P_NE  P_NN ]
```

For a valid covariance matrix, `P_EN = P_NE` within numerical tolerance. *(Geçerli kovaryans matrisi için sayısal tolerans içerisinde `P_EN = P_NE` olmalıdır.)*

---

# 19. Covariance Must Be Symmetric (Kovaryans Simetrik Olmalıdır)

The engine will treat strong covariance asymmetry as a numerical-integrity warning. *(Motor güçlü kovaryans asimetrisini sayısal bütünlük uyarısı olarak ele alacaktır.)*

Small floating-point asymmetry may be symmetrized where the EKF implementation policy permits. *(Küçük floating-point asimetrisi EKF uygulama politikası izin verdiğinde simetrize edilebilir.)*

---

# 20. Covariance Must Be Finite (Kovaryans Sonlu Olmalıdır)

NaN or infinite covariance values invalidate uncertainty interpretation. *(NaN veya sonsuz kovaryans değerleri belirsizlik yorumunu geçersiz kılar.)*

A position may therefore become `INVALID` even if its numerical East and North coordinates remain finite. *(Bu nedenle sayısal East ve North koordinatları sonlu kalsa bile bir konum `INVALID` hale gelebilir.)*

---

# 21. Non-Negative Diagonal Requirement (Negatif Olmayan Diyagonal Gereksinimi)

Position covariance diagonal elements must not be materially negative. *(Konum kovaryans diyagonal elemanları anlamlı şekilde negatif olmamalıdır.)*

A materially negative variance indicates a numerical or implementation failure. *(Anlamlı şekilde negatif varyans sayısal veya uygulama hatasını gösterir.)*

---

# 22. Positive Semidefinite Expectation (Pozitif Yarı Tanımlı Beklentisi)

The covariance matrix is expected to remain positive semidefinite within numerical tolerance. *(Kovaryans matrisinin sayısal tolerans içerisinde pozitif yarı tanımlı kalması beklenir.)*

Formal diagnostics may inspect eigenvalues of the horizontal covariance block. *(Resmî diagnostics yatay kovaryans bloğunun özdeğerlerini inceleyebilir.)*

---

# 23. Horizontal One-Sigma Components (Yatay Bir Sigma Bileşenleri)

Axis-aligned standard deviations may be derived as follows. *(Eksen hizalı standart sapmalar aşağıdaki şekilde türetilebilir.)*

```text id="p28_006"
σE = √P_EE

σN = √P_NN
```

These values are useful diagnostics but do not fully describe correlated uncertainty. *(Bu değerler kullanışlı diagnostics'tir ancak korelasyonlu belirsizliği tam olarak açıklamaz.)*

---

# 24. Correlation Matters (Korelasyon Önemlidir)

If East and North errors are correlated, a single circular radius or independent axis values can hide the true geometry of the uncertainty. *(East ve North hataları korelasyonluysa tek dairesel radius veya bağımsız eksen değerleri belirsizliğin gerçek geometrisini gizleyebilir.)*

NAVGUARD will therefore support a 2D uncertainty ellipse representation. *(Bu nedenle NAVGUARD 2D belirsizlik ellipse temsili destekleyecektir.)*

---

# 25. Covariance Eigen-Decomposition (Kovaryans Özdeğer Ayrışımı)

The principal axes of the horizontal uncertainty ellipse can be derived from the eigenvalues and eigenvectors of `P_EN`. *(Yatay belirsizlik ellipse'inin temel eksenleri `P_EN` matrisinin özdeğerlerinden ve özvektörlerinden türetilebilir.)*

```text id="p28_007"
P_EN v_i =
λ_i v_i
```

---

# 26. One-Sigma Ellipse Axes (Bir Sigma Ellipse Eksenleri)

For a one-standard-deviation geometric representation, the principal semi-axis magnitudes are proportional to the square roots of the eigenvalues. *(Bir standart sapmalı geometrik temsil için temel yarı eksen büyüklükleri özdeğerlerin karekökleriyle orantılıdır.)*

```text id="p28_008"
a_1σ = √λ_max

b_1σ = √λ_min
```

---

# 27. Confidence Ellipse Scaling (Güven Ellipse Ölçekleme)

A statistical confidence ellipse requires scaling by an appropriate chi-square factor for two dimensions when the Gaussian covariance interpretation is considered valid. *(İstatistiksel güven ellipse'i Gaussian kovaryans yorumunun geçerli kabul edildiği durumda iki boyut için uygun chi-square faktörüyle ölçekleme gerektirir.)*

NAVGUARD will not label an ellipse as a statistically calibrated confidence region unless the covariance model has been validated sufficiently for that interpretation. *(NAVGUARD kovaryans modeli bu yorum için yeterince doğrulanmadıkça bir ellipse'i istatistiksel olarak kalibre edilmiş güven bölgesi olarak etiketlemeyecektir.)*

---

# 28. Example 95% Scaling (Örnek %95 Ölçekleme)

For an ideal two-dimensional Gaussian covariance, a 95% confidence ellipse can use the chi-square value for two degrees of freedom. *(İdeal iki boyutlu Gaussian kovaryans için %95 güven ellipse'i iki serbestlik derecesine ait chi-square değerini kullanabilir.)*

```text id="p28_009"
χ²_(2,0.95) ≈ 5.991
```

```text id="p28_010"
a_95 =
√(5.991 λ_max)

b_95 =
√(5.991 λ_min)
```

This formula will be treated as a statistical interpretation only when the covariance calibration supports it. *(Bu formül yalnızca kovaryans kalibrasyonu desteklediğinde istatistiksel yorum olarak ele alınacaktır.)*

---

# 29. Uncalibrated Ellipse Alternative (Kalibre Edilmemiş Ellipse Alternatifi)

Before covariance calibration is demonstrated, the UI may use a clearly labeled relative uncertainty ellipse rather than claiming a formal 95% probability region. *(Kovaryans kalibrasyonu gösterilmeden önce UI resmî %95 olasılık bölgesi iddia etmek yerine açıkça etiketlenmiş göreli belirsizlik ellipse'i kullanabilir.)*

---

# 30. Scalar Horizontal Uncertainty (Skaler Yatay Belirsizlik)

The engine may additionally expose one scalar horizontal uncertainty summary for UI simplicity. *(Motor UI basitliği için ayrıca tek skaler yatay belirsizlik özeti sunabilir.)*

This scalar will not replace the full covariance internally. *(Bu skaler dahili olarak tam kovaryansın yerini almayacaktır.)*

---

# 31. Candidate Scalar Summary (Aday Skaler Özet)

One conservative candidate is the largest principal standard deviation. *(Bir temkinli aday en büyük temel standart sapmadır.)*

```text id="p28_011"
σ_horizontal =
√λ_max
```

The final displayed scalar definition will be documented explicitly. *(Nihai gösterilen skaler tanım açık şekilde dokümante edilecektir.)*

---

# 32. Root-Mean-Square Axis Summary Candidate (Kök-Ortalama-Kare Eksen Özet Adayı)

Another diagnostic candidate is as follows. *(Başka bir tanısal aday aşağıdaki gibidir.)*

```text id="p28_012"
σ_rms =
√(
(P_EE + P_NN) / 2
)
```

NAVGUARD will not switch between scalar definitions silently. *(NAVGUARD skaler tanımlar arasında sessizce geçiş yapmayacaktır.)*

---

# 33. Confidence and Uncertainty Are Different Concepts (Güven ile Belirsizlik Farklı Kavramlardır)

Statistical position uncertainty describes the estimated error distribution of position. *(İstatistiksel konum belirsizliği konumun tahmini hata dağılımını açıklar.)*

Operational confidence describes how much the system trusts the current estimator configuration and supporting measurements. *(Operasyonel güven sistemin mevcut tahmin motoru yapılandırmasına ve destekleyici ölçümlere ne kadar güvendiğini açıklar.)*

---

# 34. Confidence Is Not a Probability Unless Calibrated (Güven Kalibre Edilmedikçe Olasılık Değildir)

A quality score of `0.8` will not automatically mean an 80% probability that the true position lies inside some unspecified radius. *(`0.8` kalite skoru otomatik olarak gerçek konumun belirtilmemiş bir radius içerisinde bulunma olasılığının %80 olduğu anlamına gelmeyecektir.)*

---

# 35. Position Quality State (Konum Kalite Durumu)

The engine will publish a discrete position-quality state in addition to numerical uncertainty. *(Motor sayısal belirsizliğe ek olarak ayrık konum kalite durumu yayınlayacaktır.)*

```text id="p28_013"
UNKNOWN
HIGH
GOOD
USABLE
DEGRADED
POOR
INVALID
```

The exact naming may be aligned later with the common Quality Engine. *(Kesin isimlendirme daha sonra ortak Kalite Motoruyla hizalanabilir.)*

---

# 36. Quality Engine Relationship (Kalite Motoru İlişkisi)

The Sensor Confidence & Quality Engine defined in **20 — Sensor Confidence & Quality Engine** will provide source-quality information. *(**20 — Sensör Güven ve Kalite Motoru** bölümünde tanımlanan Sensör Güven ve Kalite Motoru kaynak kalite bilgisi sağlayacaktır.)*

The Position Estimation & Uncertainty Engine will combine this information with estimator covariance, estimator mode, source availability, and state freshness. *(Konum Tahmini ve Belirsizlik Motoru bu bilgiyi tahmin motoru kovaryansı, tahmin motoru modu, kaynak kullanılabilirliği ve durum güncelliğiyle birleştirecektir.)*

---

# 37. Position Quality Is Derived, Not Measured Directly (Konum Kalitesi Doğrudan Ölçülmez, Türetilir)

No smartphone sensor directly reports NAVGUARD position confidence. *(Hiçbir akıllı telefon sensörü doğrudan NAVGUARD konum güvenini raporlamaz.)*

The quality state is a derived system interpretation. *(Kalite durumu türetilmiş sistem yorumudur.)*

---

# 38. Candidate Position Quality Inputs (Aday Konum Kalite Girdileri)

Candidate inputs include position covariance magnitude. *(Aday girdiler konum kovaryans büyüklüğünü içerir.)*

Candidate inputs include heading uncertainty. *(Aday girdiler yön belirsizliğini içerir.)*

Candidate inputs include current PDR quality. *(Aday girdiler mevcut PDR kalitesini içerir.)*

Candidate inputs include ARCore tracking quality. *(Aday girdiler ARCore tracking kalitesini içerir.)*

Candidate inputs include motion-state quality. *(Aday girdiler hareket durumu kalitesini içerir.)*

Candidate inputs include estimator age and measurement gaps. *(Aday girdiler tahmin motoru yaşını ve ölçüm boşluklarını içerir.)*

---

# 39. Time Since Last Absolute Anchor (Son Mutlak Anchor'dan Geçen Süre)

Time elapsed since the last authorized absolute position reference is an important dead-reckoning context variable. *(Son izin verilen mutlak konum referansından geçen süre önemli dead-reckoning bağlam değişkenidir.)*

```text id="p28_014"
t_denied =
t_current -
t_last_absolute_anchor
```

Longer denied duration generally increases risk of accumulated drift. *(Daha uzun kesintili süre genel olarak birikmiş drift riskini artırır.)*

---

# 40. Time Alone Does Not Determine Error (Süre Tek Başına Hatayı Belirlemez)

NAVGUARD will not assume a fixed number of metres of error per second without experimental evidence. *(NAVGUARD deneysel kanıt olmadan saniye başına sabit metre hata varsaymayacaktır.)*

Actual drift depends on heading, steps, motion, environment, ARCore availability, sensor quality, and model performance. *(Gerçek drift yön, adımlar, hareket, ortam, ARCore kullanılabilirliği, sensör kalitesi ve model performansına bağlıdır.)*

---

# 41. Distance Since Anchor (Anchor'dan Sonraki Mesafe)

Accumulated travelled distance since the last absolute anchor may also be tracked. *(Son mutlak anchor'dan itibaren birikmiş kat edilen mesafe de takip edilebilir.)*

```text id="p28_015"
D_since_anchor =
Σ L_k
```

This is useful for diagnostics and uncertainty modeling. *(Bu diagnostics ve belirsizlik modelleme için kullanışlıdır.)*

---

# 42. Covariance Propagation (Kovaryans İlerletme)

The EKF prediction step propagates covariance through the state transition model and process noise. *(EKF prediction adımı kovaryansı durum geçiş modeli ve süreç gürültüsü üzerinden ilerletir.)*

```text id="p28_016"
P_k^- =
F_k P_(k-1)^+ F_k^T
+
Q_k
```

---

# 43. Measurement Update Covariance (Ölçüm Güncelleme Kovaryansı)

When an authorized measurement update occurs, covariance is reduced or reshaped according to the EKF update. *(İzin verilen ölçüm güncellemesi gerçekleştiğinde kovaryans EKF update'e göre azalır veya yeniden şekillenir.)*

```text id="p28_017"
P_k^+ =
(I - K_k H_k)
P_k^-
```

A numerically more stable Joseph-form update may be preferred in implementation. *(Uygulamada sayısal olarak daha kararlı Joseph-form update tercih edilebilir.)*

---

# 44. Joseph Form Candidate (Joseph Form Adayı)

```text id="p28_018"
P_k^+ =
(I - K H)
P_k^-
(I - K H)^T
+
K R K^T
```

The final EKF covariance update implementation remains owned by the fusion layer. *(Nihai EKF kovaryans update uygulaması füzyon katmanının sahibi olarak kalır.)*

---

# 45. Step Length Uncertainty Contribution (Adım Uzunluğu Belirsizlik Katkısı)

Step-length uncertainty contributes to position process noise. *(Adım uzunluğu belirsizliği konum süreç gürültüsüne katkıda bulunur.)*

```text id="p28_019"
G_L =

[ sinψ ]
[ cosψ ]
```

```text id="p28_020"
Q_L =
G_L σL² G_L^T
```

---

# 46. Heading Uncertainty Contribution (Yön Belirsizlik Katkısı)

Heading uncertainty also affects horizontal displacement uncertainty. *(Yön belirsizliği de yatay yer değiştirme belirsizliğini etkiler.)*

For one PDR displacement, the local sensitivity to heading can be approximated by the derivative of displacement with respect to heading. *(Tek PDR yer değiştirmesi için yöne karşı yerel hassasiyet yer değiştirmenin yöne göre türeviyle yaklaşık olarak ifade edilebilir.)*

```text id="p28_021"
∂ΔE/∂ψ =
L cosψ

∂ΔN/∂ψ =
-L sinψ
```

---

# 47. Heading Noise Mapping Candidate (Yön Gürültüsü Eşleme Adayı)

```text id="p28_022"
G_ψ =

[  L cosψ ]
[ -L sinψ ]
```

```text id="p28_023"
Q_ψ =
G_ψ σψ² G_ψ^T
```

The exact process-noise construction will remain consistent with the EKF state model frozen in Page 21. *(Kesin süreç gürültüsü oluşturma Page 21'de sabitlenen EKF durum modeliyle tutarlı kalacaktır.)*

---

# 48. Motion Context Can Affect Q (Hareket Bağlamı Q'yu Etkileyebilir)

Walking, running, turning, and uncertain motion may require different process-noise profiles. *(Yürüyüş, koşma, dönüş ve belirsiz hareket farklı süreç gürültüsü profilleri gerektirebilir.)*

These differences will be calibrated from development data rather than assigned arbitrarily. *(Bu farklar keyfi olarak atanmak yerine geliştirme verisinden kalibre edilecektir.)*

---

# 49. Turning Uncertainty (Dönüş Belirsizliği)

Turning may temporarily increase heading-related uncertainty. *(Dönüş geçici olarak yönle ilişkili belirsizliği artırabilir.)*

The engine may therefore observe a widening or rotation of the position covariance during turn-heavy periods. *(Bu nedenle motor dönüş yoğun dönemlerde konum kovaryansının genişlediğini veya döndüğünü gözlemleyebilir.)*

---

# 50. Running Uncertainty (Koşma Belirsizliği)

Running may have different step-length and motion dynamics from normal walking. *(Koşma normal yürüyüşten farklı adım uzunluğu ve hareket dinamiklerine sahip olabilir.)*

Running-specific uncertainty will only be used if enough experimental evidence exists. *(Koşmaya özgü belirsizlik yalnızca yeterli deneysel kanıt mevcutsa kullanılacaktır.)*

---

# 51. Stationary Behavior (Sabit Durum Davranışı)

During a correctly recognized stationary interval with no accepted step, PDR position should not propagate. *(Doğru tanınmış sabit aralık sırasında kabul edilmiş adım yoksa PDR konumu ilerlememelidir.)*

Covariance may still evolve depending on the estimator model and heading uncertainty. *(Kovaryans tahmin motoru modeline ve yön belirsizliğine bağlı olarak yine de gelişebilir.)*

---

# 52. Stationary Does Not Automatically Collapse Position Uncertainty (Sabit Durum Konum Belirsizliğini Otomatik Olarak Sıfırlamaz)

Knowing that the device is stationary does not reveal the exact true global position. *(Cihazın sabit olduğunu bilmek kesin gerçek global konumu ortaya çıkarmaz.)*

Therefore stationary detection must not artificially reset horizontal position covariance to zero. *(Bu nedenle sabit durum tespiti yatay konum kovaryansını yapay olarak sıfıra resetlememelidir.)*

---

# 53. ARCore Measurement Effect (ARCore Ölçüm Etkisi)

When ARCore provides a validated local relative-motion measurement, the EKF may reduce drift uncertainty according to the measurement model. *(ARCore doğrulanmış yerel göreli hareket ölçümü sağladığında EKF ölçüm modeline göre drift belirsizliğini azaltabilir.)*

The Position Engine will reflect the resulting covariance but will not directly manipulate it. *(Konum Motoru ortaya çıkan kovaryansı yansıtacak ancak doğrudan manipüle etmeyecektir.)*

---

# 54. ARCore Loss (ARCore Kaybı)

When ARCore becomes unavailable or degraded, PDR may continue. *(ARCore kullanılamaz veya bozulmuş hale geldiğinde PDR devam edebilir.)*

Position uncertainty should then evolve according to the remaining estimator sources rather than pretending that ARCore correction is still active. *(Konum belirsizliği daha sonra ARCore düzeltmesi hâlâ aktifmiş gibi davranmak yerine kalan tahmin motoru kaynaklarına göre gelişmelidir.)*

---

# 55. Magnetometer Disturbance (Manyetometre Bozulması)

Magnetic disturbance may increase heading uncertainty or reduce heading quality. *(Manyetik bozulma yön belirsizliğini artırabilir veya yön kalitesini düşürebilir.)*

The resulting effect may propagate into position uncertainty through the EKF process model. *(Ortaya çıkan etki EKF süreç modeli üzerinden konum belirsizliğine yayılabilir.)*

---

# 56. Missing Measurements (Eksik Ölçümler)

The absence of a correction measurement does not necessarily invalidate the current position immediately. *(Düzeltme ölçümünün olmaması mevcut konumu mutlaka hemen geçersiz kılmaz.)*

It may instead cause the estimate to become progressively more uncertain. *(Bunun yerine tahminin giderek daha belirsiz hale gelmesine neden olabilir.)*

---

# 57. Degraded Does Not Mean Unusable (DEGRADED Kullanılamaz Anlamına Gelmez)

A degraded position may remain useful for short-term approximate navigation. *(Bozulmuş konum kısa süreli yaklaşık navigasyon için kullanışlı kalabilir.)*

The UI and evaluation logs must nevertheless communicate that reduced trust. *(Buna rağmen UI ve değerlendirme kayıtları azalmış güveni iletmelidir.)*

---

# 58. Invalid Position (Geçersiz Konum)

A position becomes invalid when the system can no longer provide a numerically or semantically trustworthy estimate under the frozen validity policy. *(Sistem sabitlenmiş geçerlilik politikası altında artık sayısal veya semantik olarak güvenilir tahmin sağlayamadığında konum geçersiz hale gelir.)*

---

# 59. Candidate Invalidity Conditions (Aday Geçersizlik Koşulları)

Candidate causes include non-finite state values. *(Aday nedenler sonlu olmayan durum değerlerini içerir.)*

Candidate causes include invalid covariance. *(Aday nedenler geçersiz kovaryansı içerir.)*

Candidate causes include uninitialized anchor. *(Aday nedenler başlatılmamış anchor'ı içerir.)*

Candidate causes include catastrophic estimator reset without controlled recovery. *(Aday nedenler kontrollü recovery olmadan katastrofik tahmin motoru resetini içerir.)*

---

# 60. Anchor Requirement (Anchor Gereksinimi)

A denied-navigation geographic position cannot be produced without a valid geographic anchor or equivalent controlled relocalization reference. *(Kesintili navigasyon coğrafi konumu geçerli coğrafi anchor veya eşdeğer kontrollü relocalization referansı olmadan üretilemez.)*

---

# 61. Local Position Without Geographic Anchor (Coğrafi Anchor Olmadan Yerel Konum)

The system may still maintain a local relative position in some diagnostic contexts without a geographic anchor. *(Sistem bazı tanısal bağlamlarda coğrafi anchor olmadan yine de yerel göreli konumu koruyabilir.)*

Such a position must not be falsely presented as WGS84 geographic navigation. *(Böyle konum yanlış şekilde WGS84 coğrafi navigasyon olarak sunulmamalıdır.)*

---

# 62. Initial State (Başlangıç Durumu)

After a valid GNSS anchor is accepted, the local horizontal position will be initialized as follows. *(Geçerli GNSS anchor kabul edildikten sonra yerel yatay konum aşağıdaki gibi başlatılacaktır.)*

```text id="p28_024"
E_0 = 0

N_0 = 0
```

The initial covariance will reflect the uncertainty of the anchor and any additional initialization assumptions. *(İlk kovaryans anchor belirsizliğini ve ek initialization varsayımlarını yansıtacaktır.)*

---

# 63. Anchor Accuracy Is Not Zero (Anchor Doğruluğu Sıfır Değildir)

A GNSS anchor is not an exact mathematical point. *(GNSS anchor kesin matematiksel nokta değildir.)*

Its position uncertainty must not be initialized to zero merely because it defines the ENU origin. *(ENU origin'ini tanımladığı için konum belirsizliği yalnızca bu nedenle sıfıra başlatılmamalıdır.)*

---

# 64. Coordinate Origin and Physical Truth Are Different (Koordinat Origin'i ile Fiziksel Gerçek Farklıdır)

The ENU coordinate origin is exactly `(0,0,0)` by definition. *(ENU koordinat origin'i tanım gereği tam olarak `(0,0,0)` değeridir.)*

The real physical location corresponding to that origin still has GNSS anchor uncertainty. *(Bu origin'e karşılık gelen gerçek fiziksel konum yine de GNSS anchor belirsizliğine sahiptir.)*

---

# 65. Anchor Uncertainty Initialization (Anchor Belirsizliği Initialization)

The initial horizontal covariance may use validated anchor-quality information. *(İlk yatay kovaryans doğrulanmış anchor kalite bilgisini kullanabilir.)*

Android GNSS accuracy will not automatically be treated as a perfectly calibrated Gaussian standard deviation without validation. *(Android GNSS accuracy değeri doğrulama olmadan otomatik olarak kusursuz kalibre edilmiş Gaussian standart sapması olarak ele alınmayacaktır.)*

---

# 66. GNSS Accuracy Interpretation (GNSS Accuracy Yorumlaması)

Android's horizontal accuracy is useful measurement-quality metadata but not guaranteed to match NAVGUARD's exact stochastic model. *(Android yatay accuracy değeri kullanışlı ölçüm kalite metadata bilgisidir ancak NAVGUARD'ın kesin stokastik modeliyle eşleşmesi garanti edilmez.)*

The conversion from Android accuracy to EKF measurement covariance will be calibrated or conservatively defined. *(Android accuracy değerinden EKF ölçüm kovaryansına dönüşüm kalibre edilecek veya temkinli şekilde tanımlanacaktır.)*

---

# 67. Denial Transition (Kesinti Geçişi)

At the GNSS denial transition, the current estimator state and covariance will continue without being reset solely because GNSS authorization changes. *(GNSS kesinti geçişinde mevcut tahmin motoru durumu ve kovaryansı yalnızca GNSS authorization değiştiği için resetlenmeden devam edecektir.)*

---

# 68. Denial Boundary Timestamp (Kesinti Sınırı Zaman Damgası)

The exact denial boundary timestamp will be stored with the position and uncertainty state. *(Kesin kesinti sınırı zaman damgası konum ve belirsizlik durumuyla birlikte saklanacaktır.)*

---

# 69. Uncertainty Growth During Denial (Kesinti Sırasında Belirsizlik Büyümesi)

In a valid dead-reckoning system, uncertainty will generally tend to grow while no absolute position correction is available. *(Geçerli dead-reckoning sisteminde mutlak konum düzeltmesi kullanılamazken belirsizlik genel olarak büyüme eğiliminde olacaktır.)*

It does not need to increase monotonically at every update because relative measurements such as ARCore may temporarily reduce parts of the covariance. *(ARCore gibi göreli ölçümler kovaryansın bazı bölümlerini geçici olarak azaltabileceği için her update'te monotonik olarak artması gerekmez.)*

---

# 70. No Artificial Confidence Reset (Yapay Güven Reset'i Olmaması)

Mode changes, UI actions, or map recentering must not artificially reset estimator uncertainty. *(Mode değişiklikleri, UI işlemleri veya harita recenter işlemi tahmin motoru belirsizliğini yapay olarak resetlememelidir.)*

---

# 71. Position Age (Konum Yaşı)

Every current estimate will have a timestamp and age. *(Her mevcut tahmin zaman damgasına ve yaşa sahip olacaktır.)*

```text id="p28_025"
positionAge =
t_current -
t_estimate
```

---

# 72. Stale Position (Eski Konum)

A numerically valid position can become operationally stale if estimator updates stop. *(Sayısal olarak geçerli konum tahmin motoru update'leri durursa operasyonel olarak eski hale gelebilir.)*

The stale threshold will be determined from runtime behavior and estimator cadence. *(Eski olma eşiği runtime davranışından ve tahmin motoru kadansından belirlenecektir.)*

---

# 73. Position Update Cadence (Konum Güncelleme Kadansı)

Internal estimator updates may occur at a higher rate than map rendering. *(Dahili tahmin motoru update'leri harita render hızından daha yüksek hızda gerçekleşebilir.)*

The Position Engine may publish lower-rate UI snapshots without changing estimator timing. *(Konum Motoru tahmin motoru zamanlamasını değiştirmeden daha düşük hızlı UI snapshot'ları yayınlayabilir.)*

---

# 74. UI Downsampling Is Not State Downsampling (UI Downsampling Durum Downsampling Değildir)

Reducing map-render updates must not reduce the frequency of the estimator itself unless explicitly designed and validated. *(Harita render update'lerini azaltmak açıkça tasarlanıp doğrulanmadıkça tahmin motorunun frekansını azaltmamalıdır.)*

---

# 75. Position History (Konum Geçmişi)

NAVGUARD will preserve time-stamped trajectory history for analysis and display. *(NAVGUARD analiz ve gösterim için zaman damgalı trajectory geçmişini koruyacaktır.)*

---

# 76. Trajectory Point Model (Trajectory Nokta Modeli)

```text id="p28_026"
TrajectoryPoint
- timestampNs
- eastM
- northM
- latitudeDeg
- longitudeDeg
- source
- quality
- horizontalUncertainty
- mode
```

---

# 77. Historical Immutability (Geçmiş Değişmezliği)

Live historical trajectory points will not be silently rewritten after they have been committed. *(Canlı geçmiş trajectory noktaları kesinleştirildikten sonra sessizce yeniden yazılmayacaktır.)*

---

# 78. Relocalization Does Not Rewrite History (Relocalization Geçmişi Yeniden Yazmaz)

A GNSS recovery or relocalization event may change the current estimator state going forward. *(GNSS recovery veya relocalization olayı ileriye dönük mevcut tahmin motoru durumunu değiştirebilir.)*

It will not retroactively move previously logged denied-navigation positions. *(Daha önce kaydedilmiş kesintili navigasyon konumlarını geriye dönük taşımayacaktır.)*

---

# 79. Pre-Correction Position Preservation (Düzeltme Öncesi Konum Koruması)

Immediately before controlled recovery correction, the engine must preserve the current estimated position and covariance. *(Kontrollü recovery düzeltmesinden hemen önce motor mevcut tahmini konumu ve kovaryansı korumalıdır.)*

```text id="p28_027"
p_est_pre_correction
P_pre_correction
```

---

# 80. Recovery Error Measurement (Recovery Hata Ölçümü)

The first accepted recovery reference will be transformed into the same ENU frame before comparison. *(İlk kabul edilmiş recovery referansı karşılaştırmadan önce aynı ENU frame'ine dönüştürülecektir.)*

```text id="p28_028"
e_recovery =
p_est_pre_correction
-
p_gnss_recovery
```

---

# 81. Horizontal Recovery Error (Yatay Recovery Hatası)

```text id="p28_029"
e_horizontal =
√(
e_E² + e_N²
)
```

This value must be stored before the estimator is corrected. *(Bu değer tahmin motoru düzeltilmeden önce saklanmalıdır.)*

---

# 82. Recovery Error Is Evaluation Evidence (Recovery Hatası Değerlendirme Kanıtıdır)

The pre-correction recovery error is one of the most important final drift metrics for a GNSS-denied interval. *(Düzeltme öncesi recovery hatası GNSS kesintili aralık için en önemli nihai drift metriklerinden biridir.)*

---

# 83. Recovery Covariance Consistency (Recovery Kovaryans Tutarlılığı)

The system may compare the observed recovery error with the pre-correction predicted uncertainty. *(Sistem gözlemlenen recovery hatasını düzeltme öncesi tahmin edilen belirsizlikle karşılaştırabilir.)*

This provides evidence about whether the uncertainty model is overconfident or underconfident. *(Bu belirsizlik modelinin aşırı güvenli veya yetersiz güvenli olup olmadığı hakkında kanıt sağlar.)*

---

# 84. NEES Candidate (NEES Adayı)

When sufficient reference quality and model assumptions exist, normalized estimation error squared may be evaluated. *(Yeterli referans kalitesi ve model varsayımları mevcut olduğunda normalized estimation error squared değerlendirilebilir.)*

```text id="p28_030"
NEES =
e^T
P^-1
e
```

NEES will only be used if the reference and covariance interpretation make the statistic defensible. *(NEES yalnızca referans ve kovaryans yorumu istatistiği savunulabilir hale getiriyorsa kullanılacaktır.)*

---

# 85. NIS Belongs to Measurement Updates (NIS Ölçüm Güncellemelerine Aittir)

Normalized innovation squared may be used in the EKF measurement-validation layer rather than as the primary output of this engine. *(Normalized innovation squared bu motorun temel çıktısı yerine EKF ölçüm doğrulama katmanında kullanılabilir.)*

---

# 86. Coverage Calibration (Kapsama Kalibrasyonu)

NAVGUARD may evaluate how often reference positions fall inside predicted uncertainty regions. *(NAVGUARD referans konumların tahmin edilen belirsizlik bölgelerinin içerisinde ne sıklıkla bulunduğunu değerlendirebilir.)*

This can reveal systematic overconfidence or underconfidence. *(Bu sistematik aşırı güveni veya yetersiz güveni ortaya çıkarabilir.)*

---

# 87. Overconfidence (Aşırı Güven)

An uncertainty model is operationally dangerous if it frequently reports very small uncertainty while actual position error is large. *(Belirsizlik modeli gerçek konum hatası büyükken sık sık çok küçük belirsizlik raporluyorsa operasyonel olarak tehlikelidir.)*

---

# 88. Underconfidence (Yetersiz Güven)

Excessively large uncertainty may be safer than overconfidence but can reduce usability and make the quality indicator uninformative. *(Aşırı büyük belirsizlik aşırı güvenden daha güvenli olabilir ancak kullanılabilirliği azaltabilir ve kalite göstergesini bilgisiz hale getirebilir.)*

---

# 89. Uncertainty Calibration Goal (Belirsizlik Kalibrasyon Hedefi)

The goal is not merely to minimize covariance. *(Amaç yalnızca kovaryansı küçültmek değildir.)*

The goal is to make uncertainty reasonably consistent with observed error under the tested conditions. *(Amaç belirsizliği test edilen koşullar altında gözlemlenen hatayla makul şekilde tutarlı hale getirmektir.)*

---

# 90. Covariance Inflation Candidate (Kovaryans Şişirme Adayı)

If the EKF is consistently overconfident, process or measurement noise may require recalibration or controlled covariance inflation. *(EKF sürekli aşırı güvenliyse süreç veya ölçüm gürültüsü yeniden kalibrasyon veya kontrollü kovaryans inflation gerektirebilir.)*

Such changes must be based on development evidence rather than final-test tuning. *(Böyle değişiklikler nihai test ayarı yerine geliştirme kanıtına dayanmalıdır.)*

---

# 91. Covariance Floor Candidate (Kovaryans Alt Sınırı Adayı)

A minimum covariance floor may be used if numerical updates produce unrealistically small uncertainty. *(Sayısal update'ler gerçekçi olmayan derecede küçük belirsizlik üretirse minimum kovaryans alt sınırı kullanılabilir.)*

The floor must be justified and documented. *(Alt sınır gerekçelendirilmeli ve dokümante edilmelidir.)*

---

# 92. Covariance Ceiling (Kovaryans Üst Sınırı)

The engine will not silently clamp large covariance solely to keep the UI attractive. *(Motor yalnızca UI'ı güzel tutmak için büyük kovaryansı sessizce clamp etmeyecektir.)*

If uncertainty becomes extremely large, the quality state should reflect that fact. *(Belirsizlik aşırı büyürse kalite durumu bu gerçeği yansıtmalıdır.)*

---

# 93. UI Confidence Representation (UI Güven Temsili)

Normal navigation UI may show a simplified confidence indicator. *(Normal navigasyon UI'ı sadeleştirilmiş güven göstergesi gösterebilir.)*

The underlying numerical uncertainty will still remain available in logs and diagnostics. *(Temel sayısal belirsizlik yine de loglarda ve diagnostics içerisinde kullanılabilir kalacaktır.)*

---

# 94. Candidate User-Facing States (Aday Kullanıcıya Gösterilen Durumlar)

```text id="p28_031"
High Confidence
(Yüksek Güven)

Moderate Confidence
(Orta Güven)

Low Confidence
(Düşük Güven)

Estimate Unreliable
(Tahmin Güvenilmez)
```

The final wording will be defined in **31 — Mobile UI/UX Specification**. *(Nihai metin **31 — Mobil UI/UX Spesifikasyonu** içerisinde tanımlanacaktır.)*

---

# 95. Avoid False Precision in UI (UI'da Sahte Hassasiyetten Kaçınma)

Displaying many decimal places in latitude and longitude does not imply metre-level accuracy. *(Enlem ve boylamda çok sayıda ondalık basamak göstermek metre seviyesinde doğruluk anlamına gelmez.)*

NAVGUARD UI will avoid visually implying precision that the estimator does not possess. *(NAVGUARD UI tahmin motorunun sahip olmadığı hassasiyeti görsel olarak ima etmekten kaçınacaktır.)*

---

# 96. Map Marker and Uncertainty (Harita Marker'ı ve Belirsizlik)

The estimated position may be displayed as a marker with an uncertainty region around it. *(Tahmini konum çevresinde belirsizlik bölgesi bulunan marker olarak gösterilebilir.)*

---

# 97. Circular Display Fallback (Dairesel Gösterim Geri Dönüşü)

If the map UI cannot conveniently render a rotated covariance ellipse, a conservative circular approximation may be used for presentation only. *(Harita UI döndürülmüş kovaryans ellipse'ini kolayca render edemezse yalnızca sunum için temkinli dairesel yaklaşım kullanılabilir.)*

---

# 98. Conservative Circle Candidate (Temkinli Daire Adayı)

A circle based on the major ellipse axis is one conservative visualization candidate. *(Ellipse'in büyük eksenine dayalı daire temkinli görselleştirme adaylarından biridir.)*

The logs will still retain the original covariance. *(Loglar yine de orijinal kovaryansı koruyacaktır.)*

---

# 99. Uncertainty Region Must Not Drive Map Tiles (Belirsizlik Bölgesi Harita Tile'larını Yönlendirmez)

The uncertainty visualization is an output overlay. *(Belirsizlik görselleştirmesi bir çıktı overlay'idir.)*

It does not alter the mathematical estimator. *(Matematiksel tahmin motorunu değiştirmez.)*

---

# 100. Estimated Versus Ground Truth Styling (Tahmin ile Ground Truth Görselleştirme Ayrımı)

Evaluation UI must visually distinguish estimated trajectory from GNSS ground-truth trajectory. *(Evaluation UI tahmini trajectory'yi GNSS ground-truth trajectory'sinden görsel olarak ayırmalıdır.)*

This distinction will prevent users from confusing the protected reference with the estimator output. *(Bu ayrım kullanıcıların korunan referansı tahmin motoru çıktısıyla karıştırmasını önleyecektir.)*

---

# 101. Ground Truth May Be Hidden During Live Evaluation (Canlı Değerlendirme Sırasında Ground Truth Gizlenebilir)

Evaluation Mode may intentionally hide the ground-truth path during the denied interval to prevent human feedback from affecting behavior. *(Evaluation Mode insan geri bildirimini davranışı etkilemekten korumak için kesintili aralık sırasında ground-truth path'i bilinçli olarak gizleyebilir.)*

The ground truth can be revealed during post-session analysis. *(Ground truth oturum sonrası analiz sırasında gösterilebilir.)*

---

# 102. Position Estimate Validity Model (Konum Tahmini Geçerlilik Modeli)

```text id="p28_032"
PositionValidity

VALID
DEGRADED
INVALID
```

Quality detail may be stored separately from this coarse validity state. *(Kalite ayrıntısı bu kaba geçerlilik durumundan ayrı saklanabilir.)*

---

# 103. VALID Position (VALID Konum)

A `VALID` position has finite coordinates, a valid anchor, a valid estimator state, and acceptable freshness. *(Bir `VALID` konum sonlu koordinatlara, geçerli anchor'a, geçerli tahmin motoru durumuna ve kabul edilebilir güncelliğe sahiptir.)*

---

# 104. DEGRADED Position (DEGRADED Konum)

A `DEGRADED` position remains numerically valid but has reduced estimator support or high uncertainty. *(Bir `DEGRADED` konum sayısal olarak geçerli kalır ancak azalmış tahmin motoru desteğine veya yüksek belirsizliğe sahiptir.)*

---

# 105. INVALID Position (INVALID Konum)

An `INVALID` position must not be presented as a trustworthy current navigation point. *(Bir `INVALID` konum güvenilir mevcut navigasyon noktası olarak sunulmamalıdır.)*

---

# 106. Position Validity and Session Validity Are Different (Konum Geçerliliği ile Oturum Geçerliliği Farklıdır)

A session may remain valid for research analysis even if the estimator becomes invalid during part of the route. *(Tahmin motoru rotanın bir bölümünde geçersiz hale gelse bile oturum araştırma analizi için geçerli kalabilir.)*

The failure itself may be important experimental evidence. *(Hatanın kendisi önemli deneysel kanıt olabilir.)*

---

# 107. Current Position Interface (Mevcut Konum Arayüzü)

The navigation domain will expose the latest authoritative position snapshot through a single source of truth. *(Navigasyon domain'i en son ana konum snapshot'ını tek source of truth üzerinden sunacaktır.)*

---

# 108. No Competing Current Position Owners (Birden Fazla Mevcut Konum Sahibi Olmaması)

Map UI, session logger, and diagnostics must consume the shared position stream rather than independently calculate their own current location. *(Harita UI, oturum logger'ı ve diagnostics bağımsız olarak kendi mevcut konumlarını hesaplamak yerine ortak konum akışını kullanmalıdır.)*

---

# 109. Position Repository Candidate (Konum Repository Adayı)

```text id="p28_033"
PositionRepository
- currentEstimate
- fusedTrajectory
- baselineTrajectory
- groundTruthTrajectory
- recoveryEvents
```

The final interface names may change during implementation. *(Nihai arayüz isimleri uygulama sırasında değişebilir.)*

---

# 110. Position Engine Inputs (Konum Motoru Girdileri)

```text id="p28_034"
EKF state + covariance
PDR state
active anchor
navigation mode
source quality
ARCore state
motion context
heading quality
recovery state
```

---

# 111. Position Engine Outputs (Konum Motoru Çıktıları)

```text id="p28_035"
Current local ENU position
Current WGS84 position
Position covariance
Uncertainty summary
Quality state
Validity state
Trajectory point
Diagnostic uncertainty data
```

---

# 112. Coordinate Conversion Failure (Koordinat Dönüşüm Hatası)

A failure to convert valid ENU coordinates to WGS84 will be treated as an output-layer error. *(Geçerli ENU koordinatlarını WGS84'e dönüştürme hatası çıktı katmanı hatası olarak ele alınacaktır.)*

The original ENU state must remain available for diagnosis. *(Orijinal ENU durumu tanı için kullanılabilir kalmalıdır.)*

---

# 113. Geographic Sanity Checks (Coğrafi Makullük Kontrolleri)

Derived latitude must remain within valid geographic limits. *(Türetilmiş enlem geçerli coğrafi sınırlar içerisinde kalmalıdır.)*

Derived longitude must remain within valid geographic limits. *(Türetilmiş boylam geçerli coğrafi sınırlar içerisinde kalmalıdır.)*

---

# 114. Local Distance Sanity Check (Yerel Mesafe Makullük Kontrolü)

A sudden extremely large position jump without a corresponding authorized measurement or relocalization event will trigger diagnostic review. *(Karşılık gelen izin verilmiş ölçüm veya relocalization olayı olmadan ani aşırı büyük konum sıçraması tanısal inceleme tetikleyecektir.)*

---

# 115. Jump Does Not Automatically Mean Error (Sıçrama Otomatik Olarak Hata Değildir)

A controlled GNSS recovery correction may intentionally create a large current-state shift. *(Kontrollü GNSS recovery düzeltmesi bilinçli olarak büyük mevcut durum kayması oluşturabilir.)*

Such events must be explicitly labeled as relocalization rather than mistaken for numerical instability. *(Böyle olaylar sayısal kararsızlıkla karıştırılmak yerine açık şekilde relocalization olarak etiketlenmelidir.)*

---

# 116. Relocalization Flag (Relocalization Bayrağı)

A position update caused by recovery correction will include explicit relocalization provenance. *(Recovery düzeltmesinden kaynaklanan konum update'i açık relocalization köken bilgisi içerecektir.)*

---

# 117. Position Discontinuity Logging (Konum Süreksizlik Kaydı)

Any deliberate discontinuity will be stored with before and after states. *(Her bilinçli süreksizlik öncesi ve sonrası durumlarla birlikte saklanacaktır.)*

```text id="p28_036"
RelocalizationEvent
- timestampNs
- preEastM
- preNorthM
- postEastM
- postNorthM
- correctionEastM
- correctionNorthM
- reason
- referenceSource
```

---

# 118. Map Trail Around Relocalization (Relocalization Çevresinde Harita İzi)

The UI may visually indicate a relocalization event rather than drawing a misleading continuous physical path between pre-correction and post-correction states. *(UI düzeltme öncesi ve sonrası durumlar arasında yanıltıcı sürekli fiziksel path çizmek yerine relocalization olayını görsel olarak gösterebilir.)*

---

# 119. Position Logging (Konum Kaydı)

Formal sessions will record current estimated position at a documented cadence or estimator-event boundary. *(Resmî oturumlar mevcut tahmini konumu dokümante edilmiş kadansta veya tahmin motoru olay sınırında kaydedecektir.)*

---

# 120. Fused Position Log Candidate (Füzyonlu Konum Log Adayı)

```text id="p28_037"
timestamp_ns,
east_m,
north_m,
latitude_deg,
longitude_deg,
source,
quality_state,
validity_state,
cov_ee,
cov_en,
cov_nn,
horizontal_uncertainty_m,
anchor_id,
mode
```

---

# 121. Baseline PDR Log Candidate (Temel PDR Log Adayı)

```text id="p28_038"
processed/pdr_state.csv
```

The baseline PDR trajectory remains separate from the fused position log. *(Temel PDR trajectory'si füzyonlu konum logundan ayrı kalır.)*

---

# 122. Ground Truth Log Candidate (Ground Truth Log Adayı)

```text id="p28_039"
processed/gnss_ground_truth_enu.csv
```

Ground-truth storage remains logically independent from estimator storage. *(Ground-truth depolama tahmin motoru depolamasından mantıksal olarak bağımsız kalır.)*

---

# 123. Uncertainty Log Candidate (Belirsizlik Log Adayı)

A separate diagnostics file may store extended covariance or ellipse parameters if the main position file should remain compact. *(Ana konum dosyasının kompakt kalması istenirse ayrı diagnostics dosyası genişletilmiş kovaryans veya ellipse parametrelerini saklayabilir.)*

---

# 124. Covariance Logging Frequency (Kovaryans Logging Frekansı)

Covariance should be logged often enough to reconstruct uncertainty evolution during the denied interval. *(Kovaryans kesintili aralık sırasında belirsizlik gelişimini yeniden oluşturabilecek kadar sık kaydedilmelidir.)*

---

# 125. No Rounded Evidence Values Internally (Dahili Kanıt Değerlerinde Yuvarlama Olmaması)

Internal logs will retain sufficient numerical precision for reproducible evaluation. *(Dahili loglar tekrarlanabilir değerlendirme için yeterli sayısal hassasiyeti koruyacaktır.)*

UI formatting may round values for readability. *(UI biçimlendirmesi okunabilirlik için değerleri yuvarlayabilir.)*

---

# 126. Replay Compatibility (Replay Uyumluluğu)

Offline replay will produce the same position-estimation interfaces used during live navigation. *(Çevrimdışı replay canlı navigasyon sırasında kullanılan aynı konum tahmin arayüzlerini üretecektir.)*

---

# 127. Replay Should Not Bypass Uncertainty (Replay Belirsizliği Atlamamalıdır)

A replay trajectory must include the same covariance and quality logic as live estimation when the same estimator profile is selected. *(Replay trajectory aynı tahmin motoru profili seçildiğinde canlı tahminle aynı kovaryans ve kalite mantığını içermelidir.)*

---

# 128. Replay Ground Truth Firewall (Replay Ground Truth Firewall)

Replay of a denied interval will enforce the original Ground Truth Firewall boundary. *(Kesintili aralığın replay'i orijinal Ground Truth Firewall sınırını uygulayacaktır.)*

The replay estimator cannot use ground-truth GNSS just because the log file contains it. *(Replay tahmin motoru log dosyası ground-truth GNSS içeriyor diye onu kullanamaz.)*

---

# 129. Replay Configuration Identity (Replay Yapılandırma Kimliği)

Replay results will identify which estimator profile and parameter set produced them. *(Replay sonuçları onları hangi tahmin motoru profilinin ve parametre setinin ürettiğini tanımlayacaktır.)*

---

# 130. Position Comparison Engine Boundary (Konum Karşılaştırma Motoru Sınırı)

Ground-truth comparison metrics belong to evaluation rather than to the protected estimator path. *(Ground-truth karşılaştırma metrikleri korunan tahmin motoru yolundan çok değerlendirmeye aittir.)*

---

# 131. Instantaneous Position Error (Anlık Konum Hatası)

When valid reference alignment exists, horizontal position error may be computed as follows. *(Geçerli referans hizalama mevcut olduğunda yatay konum hatası aşağıdaki şekilde hesaplanabilir.)*

```text id="p28_040"
e_t =
√(
(E_est - E_ref)²
+
(N_est - N_ref)²
)
```

---

# 132. Mean Position Error (Ortalama Konum Hatası)

```text id="p28_041"
MeanError =
1/n
Σ e_t
```

---

# 133. Median Position Error (Medyan Konum Hatası)

The median horizontal position error will be one of the primary robust navigation metrics. *(Medyan yatay konum hatası temel robust navigasyon metriklerinden biri olacaktır.)*

---

# 134. RMSE (RMSE)

```text id="p28_042"
RMSE =
√(
1/n
Σ e_t²
)
```

---

# 135. Final Position Error (Nihai Konum Hatası)

```text id="p28_043"
FinalError =
e_(t_end)
```

---

# 136. P95 Position Error (P95 Konum Hatası)

The 95th percentile of instantaneous horizontal error may be reported as an upper-tail robustness metric. *(Anlık yatay hatanın 95. yüzdeliği üst kuyruk dayanıklılık metriği olarak raporlanabilir.)*

---

# 137. Drift Per Minute (Dakika Başına Drift)

```text id="p28_044"
DriftRate_time =
FinalError
────────────
DeniedDuration
```

The exact reported unit will normally be metres per minute. *(Kesin raporlanan birim normalde metre/dakika olacaktır.)*

---

# 138. Drift Per Distance (Mesafe Başına Drift)

```text id="p28_045"
DriftRate_distance =
FinalError
────────────
ReferenceTravelDistance
```

This may be reported as a ratio or percentage when the reference distance is valid. *(Bu referans mesafe geçerli olduğunda oran veya yüzde olarak raporlanabilir.)*

---

# 139. Error Does Not Equal Uncertainty (Hata Belirsizliğe Eşit Değildir)

Observed position error uses an external reference. *(Gözlemlenen konum hatası harici referans kullanır.)*

Estimated uncertainty is generated internally by the estimator model. *(Tahmini belirsizlik dahili olarak tahmin motoru modeli tarafından üretilir.)*

The two should be compared but never confused. *(İkisi karşılaştırılmalı ancak hiçbir zaman karıştırılmamalıdır.)*

---

# 140. Calibration Plot Candidate (Kalibrasyon Grafiği Adayı)

The final analysis may compare predicted horizontal uncertainty against observed reference error over time. *(Nihai analiz tahmin edilen yatay belirsizliği zaman içerisindeki gözlemlenen referans hatayla karşılaştırabilir.)*

---

# 141. Error-to-Uncertainty Ratio Candidate (Hata-Belirsizlik Oranı Adayı)

A diagnostic ratio may be considered. *(Tanısal oran değerlendirilebilir.)*

```text id="p28_046"
r_t =
e_t
──────
σ_horizontal
```

Its interpretation depends strongly on how `σ_horizontal` is defined. *(Yorumu `σ_horizontal` değerinin nasıl tanımlandığına güçlü şekilde bağlıdır.)*

---

# 142. Do Not Optimize Uncertainty on Final Test (Belirsizlik Nihai Test Üzerinde Optimize Edilmemelidir)

Covariance calibration and uncertainty thresholds will be tuned using development evidence only. *(Kovaryans kalibrasyonu ve belirsizlik eşikleri yalnızca geliştirme kanıtı kullanılarak ayarlanacaktır.)*

---

# 143. Position Confidence Thresholds (Konum Güven Eşikleri)

The boundaries between `GOOD`, `USABLE`, `DEGRADED`, and other quality states will be calibrated after real system behavior is measured. *( `GOOD`, `USABLE`, `DEGRADED` ve diğer kalite durumları arasındaki sınırlar gerçek sistem davranışı ölçüldükten sonra kalibre edilecektir.)*

---

# 144. No Arbitrary Metre Thresholds Yet (Henüz Keyfi Metre Eşikleri Yok)

This planning document will not fabricate position-uncertainty thresholds before the Redmi Note 9 Pro experiments produce representative data. *(Bu planlama dokümanı Redmi Note 9 Pro deneyleri temsili veri üretmeden önce konum belirsizlik eşikleri uydurmayacaktır.)*

---

# 145. Quality Threshold Freeze (Kalite Eşiği Sabitleme)

The final quality thresholds will be frozen before formal final benchmarks. *(Nihai kalite eşikleri resmî nihai benchmark'lardan önce sabitlenecektir.)*

---

# 146. Uncertainty Engine State (Belirsizlik Motoru Durumu)

```text id="p28_047"
UNINITIALIZED
READY
ACTIVE
DEGRADED
INVALID
RELOCALIZING
ERROR
```

---

# 147. UNINITIALIZED State (UNINITIALIZED Durumu)

`UNINITIALIZED` means the engine lacks a valid navigation anchor or estimator state. *(`UNINITIALIZED`, motorun geçerli navigasyon anchor'ı veya tahmin motoru durumu olmadığı anlamına gelir.)*

---

# 148. READY State (READY Durumu)

`READY` means a valid initial position and uncertainty state exist but active propagation has not yet begun. *(`READY`, geçerli ilk konum ve belirsizlik durumunun mevcut ancak aktif ilerletmenin henüz başlamadığı anlamına gelir.)*

---

# 149. ACTIVE State (ACTIVE Durumu)

`ACTIVE` means the engine is publishing current estimator position and uncertainty normally. *(`ACTIVE`, motorun mevcut tahmin motoru konumunu ve belirsizliğini normal şekilde yayınladığı anlamına gelir.)*

---

# 150. DEGRADED State (DEGRADED Durumu)

`DEGRADED` means current output remains usable but with reduced confidence or estimator support. *(`DEGRADED`, mevcut çıktının kullanılabilir ancak azalmış güven veya tahmin motoru desteğiyle kaldığı anlamına gelir.)*

---

# 151. RELOCALIZING State (RELOCALIZING Durumu)

`RELOCALIZING` means a controlled reference-based correction is being processed. *(`RELOCALIZING`, kontrollü referans tabanlı düzeltmenin işlendiği anlamına gelir.)*

---

# 152. ERROR State (ERROR Durumu)

`ERROR` means the engine cannot safely publish a valid current position. *(`ERROR`, motorun güvenli şekilde geçerli mevcut konum yayınlayamadığı anlamına gelir.)*

---

# 153. Engine Does Not Own Sensor Acquisition (Motor Sensör Toplamanın Sahibi Değildir)

The Position Engine consumes normalized estimator outputs and does not register sensors directly. *(Konum Motoru normalize edilmiş tahmin motoru çıktılarını kullanır ve sensörleri doğrudan register etmez.)*

---

# 154. Engine Does Not Own GNSS Authorization (Motor GNSS Yetkilendirmenin Sahibi Değildir)

The Ground Truth Firewall and navigation state machine decide whether GNSS may influence the estimator. *(Ground Truth Firewall ve navigasyon state machine GNSS'in tahmin motorunu etkileyip etkileyemeyeceğine karar verir.)*

The Position Engine only consumes the already-authorized estimator state. *(Konum Motoru yalnızca zaten yetkilendirilmiş tahmin motoru durumunu kullanır.)*

---

# 155. Engine Does Not Own EKF Measurement Selection (Motor EKF Ölçüm Seçiminin Sahibi Değildir)

Measurement gating, residual validation, and Kalman updates remain responsibilities of the Sensor Fusion layer. *(Ölçüm gating, residual doğrulama ve Kalman update işlemleri Sensör Füzyon katmanının sorumlulukları olarak kalır.)*

---

# 156. Engine Owns Presentation-Ready Uncertainty (Motor Sunuma Hazır Belirsizliğin Sahibidir)

The Position Engine is responsible for converting internal covariance and quality state into a normalized output suitable for UI, logging, and evaluation. *(Konum Motoru dahili kovaryans ve kalite durumunu UI, logging ve değerlendirmeye uygun normalize edilmiş çıktıya dönüştürmekten sorumludur.)*

---

# 157. Engine Owns Trajectory Publication (Motor Trajectory Yayınının Sahibidir)

It will publish current and historical trajectory points for authorized consumers. *(Yetkilendirilmiş consumer'lar için mevcut ve geçmiş trajectory noktalarını yayınlayacaktır.)*

---

# 158. Uncertainty Provenance (Belirsizlik Kökeni)

Every uncertainty output should identify the method that produced it. *(Her belirsizlik çıktısı onu üreten yöntemi tanımlamalıdır.)*

```text id="p28_048"
EKF_COVARIANCE
HEURISTIC_PDR
GNSS_ACCURACY_PROXY
UNAVAILABLE
```

---

# 159. Standalone PDR Uncertainty (Standalone PDR Belirsizliği)

Baseline PDR without EKF covariance may use a separate heuristic uncertainty model for display and diagnostics. *(EKF kovaryansı olmayan temel PDR gösterim ve diagnostics için ayrı heuristic belirsizlik modeli kullanabilir.)*

This heuristic must not be presented as statistically calibrated EKF covariance. *(Bu heuristic istatistiksel olarak kalibre edilmiş EKF kovaryansı olarak sunulmamalıdır.)*

---

# 160. Baseline PDR Confidence (Temel PDR Güveni)

A baseline confidence model may depend on elapsed denied time, travelled distance, heading quality, and step quality. *(Temel güven modeli geçen kesintili süreye, kat edilen mesafeye, yön kalitesine ve adım kalitesine bağlı olabilir.)*

The final formula will require experimental calibration. *(Nihai formül deneysel kalibrasyon gerektirecektir.)*

---

# 161. Configuration Comparison Fairness (Yapılandırma Karşılaştırma Adaleti)

Each A-D benchmark configuration may expose uncertainty using its own valid estimator mechanism. *(Her A-D benchmark yapılandırması kendi geçerli tahmin motoru mekanizmasını kullanarak belirsizlik sunabilir.)*

The report must state when uncertainty values from different configurations are not directly statistically equivalent. *(Rapor farklı yapılandırmalardan gelen belirsizlik değerleri doğrudan istatistiksel olarak eşdeğer olmadığında bunu belirtmelidir.)*

---

# 162. Uncertainty Does Not Determine Benchmark Winner Alone (Belirsizlik Tek Başına Benchmark Kazananını Belirlemez)

A configuration with smaller reported covariance is not automatically better. *(Daha küçük raporlanmış kovaryansa sahip yapılandırma otomatik olarak daha iyi değildir.)*

Actual position error and calibration must also be considered. *(Gerçek konum hatası ve kalibrasyon da değerlendirilmelidir.)*

---

# 163. Confidence-Aware Navigation Behavior (Güven Farkındalıklı Navigasyon Davranışı)

The wider application may modify user messaging when position quality becomes degraded. *(Daha geniş uygulama konum kalitesi bozulduğunda kullanıcı mesajlarını değiştirebilir.)*

The position estimate itself remains the estimator output. *(Konum tahmininin kendisi tahmin motoru çıktısı olarak kalır.)*

---

# 164. No Hidden Route Snapping (Gizli Rota Snapping Olmaması)

NAVGUARD will not silently snap estimated positions to roads, paths, or map geometry unless a future explicitly documented map-matching subsystem is introduced. *(NAVGUARD gelecekte açıkça dokümante edilmiş map-matching alt sistemi eklenmedikçe tahmini konumları yollara, patikalara veya harita geometrisine sessizce snap etmeyecektir.)*

---

# 165. Why Hidden Snapping Is Forbidden (Gizli Snapping Neden Yasaktır)

Map snapping could artificially improve visual trajectory appearance without reflecting actual sensor-estimator performance. *(Harita snapping gerçek sensör-tahmin motoru performansını yansıtmadan görsel trajectory görünümünü yapay olarak iyileştirebilir.)*

---

# 166. Map Data Is Not Ground Truth (Harita Verisi Ground Truth Değildir)

Map geometry will remain a visualization resource unless explicitly promoted to a tested measurement source in a future scope revision. *(Harita geometrisi gelecekteki kapsam revizyonunda açıkça test edilmiş ölçüm kaynağına yükseltilmedikçe görselleştirme kaynağı olarak kalacaktır.)*

---

# 167. Position Smoothing for UI (UI İçin Konum Smoothing)

Visual-only smoothing may be considered for map rendering if the fused position stream is visually noisy. *(Füzyonlu konum akışı görsel olarak gürültülüyse yalnızca görsel smoothing harita render için değerlendirilebilir.)*

Such smoothing must not alter logged estimator state or benchmark metrics. *(Böyle smoothing kaydedilmiş tahmin motoru durumunu veya benchmark metriklerini değiştirmemelidir.)*

---

# 168. Raw Estimate and Display Estimate Must Be Distinguishable (Ham Tahmin ile Gösterim Tahmini Ayırt Edilebilir Olmalıdır)

If visual smoothing is used, the UI must consume a clearly derived display position while the authoritative estimate remains unchanged. *(Görsel smoothing kullanılırsa UI açık şekilde türetilmiş display konumunu kullanmalı, ana tahmin değişmeden kalmalıdır.)*

---

# 169. Position Engine Error Codes (Konum Motoru Hata Kodları)

```text id="p28_049"
POS_ANCHOR_MISSING
POS_STATE_INVALID
POS_COVARIANCE_INVALID
POS_TIMESTAMP_INVALID
POS_POSITION_STALE
POS_COORDINATE_CONVERSION_FAILED
POS_UNCERTAINTY_UNAVAILABLE
POS_RELOCALIZATION_FAILED
POS_DISCONTINUITY_UNEXPECTED
POS_GROUND_TRUTH_ISOLATION_VIOLATION
```

---

# 170. Ground Truth Violation Is Critical (Ground Truth İhlali Kritiktir)

If protected ground-truth GNSS is detected influencing a denied-navigation position estimate, the formal denied interval will be invalidated. *(Korunan ground-truth GNSS'in kesintili navigasyon konum tahminini etkilediği tespit edilirse resmî kesintili aralık geçersiz kılınacaktır.)*

---

# 171. Covariance Invalidity Fallback (Kovaryans Geçersizliği Geri Dönüşü)

If the fused covariance becomes invalid while a baseline deterministic position remains available, NAVGUARD may fall back to a lower-confidence navigation profile. *(Füzyonlu kovaryans geçersiz hale gelirken temel deterministik konum kullanılabilir kalırsa NAVGUARD daha düşük güvenli navigasyon profiline geri dönebilir.)*

The exact fallback is owned by the navigation state machine. *(Kesin geri dönüş navigasyon state machine'in sorumluluğundadır.)*

---

# 172. Position Engine Unit Test — ENU Initialization (Konum Motoru Birim Testi — ENU Initialization)

A newly accepted anchor must initialize local position to approximately `[0,0]`. *(Yeni kabul edilmiş anchor yerel konumu yaklaşık `[0,0]` değerine başlatmalıdır.)*

---

# 173. Position Engine Unit Test — Covariance Extraction (Konum Motoru Birim Testi — Kovaryans Çıkarma)

A known EKF covariance matrix must produce the expected `P_EN` block. *(Bilinen EKF kovaryans matrisi beklenen `P_EN` bloğunu üretmelidir.)*

---

# 174. Position Engine Unit Test — Sigma (Konum Motoru Birim Testi — Sigma)

Known diagonal covariance values must produce expected `σE` and `σN`. *(Bilinen diyagonal kovaryans değerleri beklenen `σE` ve `σN` değerlerini üretmelidir.)*

---

# 175. Position Engine Unit Test — Ellipse (Konum Motoru Birim Testi — Ellipse)

A known two-dimensional covariance matrix must produce expected principal axes and orientation. *(Bilinen iki boyutlu kovaryans matrisi beklenen temel eksenleri ve yönelimi üretmelidir.)*

---

# 176. Position Engine Unit Test — Symmetry (Konum Motoru Birim Testi — Simetri)

A materially asymmetric covariance input must trigger the defined integrity behavior. *(Anlamlı derecede asimetrik kovaryans girdisi tanımlanan bütünlük davranışını tetiklemelidir.)*

---

# 177. Position Engine Unit Test — Invalid Variance (Konum Motoru Birim Testi — Geçersiz Varyans)

A strongly negative variance must invalidate uncertainty output. *(Güçlü şekilde negatif varyans belirsizlik çıktısını geçersiz kılmalıdır.)*

---

# 178. Position Engine Unit Test — NaN (Konum Motoru Birim Testi — NaN)

NaN East, North, or covariance values must never be published as a valid position. *(NaN East, North veya kovaryans değerleri hiçbir zaman geçerli konum olarak yayınlanmamalıdır.)*

---

# 179. Position Engine Unit Test — ENU to WGS84 (Konum Motoru Birim Testi — ENU'dan WGS84'e)

Known ENU offsets around a known anchor must reproduce expected geographic coordinates within mathematical tolerance. *(Bilinen anchor çevresindeki bilinen ENU offset'leri matematiksel tolerans içerisinde beklenen coğrafi koordinatları yeniden üretmelidir.)*

---

# 180. Position Engine Unit Test — WGS84 Round Trip (Konum Motoru Birim Testi — WGS84 Round Trip)

A reference WGS84 point converted to ENU and back must return approximately to the original coordinate within the defined numerical tolerance. *(ENU'ya ve geri dönüştürülen referans WGS84 noktası tanımlanan sayısal tolerans içerisinde yaklaşık olarak orijinal koordinata dönmelidir.)*

---

# 181. Position Engine Integration Test — PDR Only (Konum Motoru Entegrasyon Testi — Yalnızca PDR)

A deterministic PDR trajectory must publish valid local and geographic positions without requiring ARCore or AI. *(Deterministik PDR trajectory'si ARCore veya yapay zekâ gerektirmeden geçerli yerel ve coğrafi konumlar yayınlamalıdır.)*

---

# 182. Position Engine Integration Test — EKF (Konum Motoru Entegrasyon Testi — EKF)

Known synthetic EKF states and covariances must propagate correctly into position snapshots. *(Bilinen sentetik EKF durumları ve kovaryansları konum snapshot'larına doğru şekilde aktarılmalıdır.)*

---

# 183. Position Engine Integration Test — Denied Mode Isolation (Konum Motoru Entegrasyon Testi — Kesintili Mod İzolasyonu)

Changing protected GNSS ground truth during denied mode must not change the estimator position. *(Kesintili mod sırasında korunan GNSS ground truth'u değiştirmek tahmin motoru konumunu değiştirmemelidir.)*

---

# 184. Position Engine Integration Test — ARCore Loss (Konum Motoru Entegrasyon Testi — ARCore Kaybı)

Simulated ARCore loss must allow PDR-based position continuation while quality and uncertainty respond appropriately. *(Simüle edilmiş ARCore kaybı kalite ve belirsizlik uygun şekilde tepki verirken PDR tabanlı konum devamlılığına izin vermelidir.)*

---

# 185. Position Engine Integration Test — Recovery (Konum Motoru Entegrasyon Testi — Recovery)

A recovery event must preserve pre-correction position, calculate error, and only then apply controlled relocalization. *(Recovery olayı düzeltme öncesi konumu korumalı, hatayı hesaplamalı ve yalnızca daha sonra kontrollü relocalization uygulamalıdır.)*

---

# 186. Position Engine Integration Test — Historical Immutability (Konum Motoru Entegrasyon Testi — Geçmiş Değişmezliği)

Relocalization must not modify previously committed denied-navigation trajectory points. *(Relocalization daha önce kesinleşmiş kesintili navigasyon trajectory noktalarını değiştirmemelidir.)*

---

# 187. Position Engine Integration Test — Replay (Konum Motoru Entegrasyon Testi — Replay)

The same frozen replay configuration must reproduce equivalent position and uncertainty outputs. *(Aynı sabitlenmiş replay yapılandırması eşdeğer konum ve belirsizlik çıktıları üretmelidir.)*

---

# 188. Position Engine Integration Test — Staleness (Konum Motoru Entegrasyon Testi — Staleness)

If estimator updates stop beyond the configured freshness interval, the current position must transition to stale or degraded behavior. *(Tahmin motoru update'leri yapılandırılmış güncellik aralığının ötesinde durursa mevcut konum stale veya degraded davranışa geçmelidir.)*

---

# 189. Position Engine Integration Test — UI Downsampling (Konum Motoru Entegrasyon Testi — UI Downsampling)

Reducing Flutter rendering frequency must not alter the estimator trajectory. *(Flutter render frekansını azaltmak tahmin motoru trajectory'sini değiştirmemelidir.)*

---

# 190. Position Engine Field Test — Straight Route (Konum Motoru Saha Testi — Düz Rota)

Straight GNSS-denied routes will evaluate uncertainty growth against observed position error. *(Düz GNSS kesintili rotalar belirsizlik büyümesini gözlemlenen konum hatasına karşı değerlendirecektir.)*

---

# 191. Position Engine Field Test — Turn-Heavy Route (Konum Motoru Saha Testi — Dönüş Yoğun Rota)

Turn-heavy routes will evaluate how heading uncertainty changes position covariance. *(Dönüş yoğun rotalar yön belirsizliğinin konum kovaryansını nasıl değiştirdiğini değerlendirecektir.)*

---

# 192. Position Engine Field Test — Closed Loop (Konum Motoru Saha Testi — Kapalı Döngü)

Closed or near-closed routes will compare closure error with predicted uncertainty. *(Kapalı veya yaklaşık kapalı rotalar closure error ile tahmin edilen belirsizliği karşılaştıracaktır.)*

---

# 193. Position Engine Field Test — ARCore Degradation (Konum Motoru Saha Testi — ARCore Bozulması)

Low-texture or tracking-loss scenarios will evaluate whether uncertainty increases appropriately after ARCore support degrades. *(Düşük texture veya tracking kaybı senaryoları ARCore desteği bozulduktan sonra belirsizliğin uygun şekilde artıp artmadığını değerlendirecektir.)*

---

# 194. Position Engine Field Test — Magnetic Disturbance (Konum Motoru Saha Testi — Manyetik Bozulma)

Magnetically disturbed environments will evaluate the effect of heading degradation on position confidence and error. *(Manyetik olarak bozulmuş ortamlar yön bozulmasının konum güveni ve hatası üzerindeki etkisini değerlendirecektir.)*

---

# 195. Position Engine Field Test — Duration (Konum Motoru Saha Testi — Süre)

Multiple GNSS-denied durations will evaluate whether uncertainty remains meaningful as dead reckoning continues. *(Birden fazla GNSS kesintili süre dead reckoning devam ederken belirsizliğin anlamlı kalıp kalmadığını değerlendirecektir.)*

---

# 196. Uncertainty Evaluation Table (Belirsizlik Değerlendirme Tablosu)

```text id="p28_050"
Session
Configuration
Denied Duration
Travel Distance
Final Position Error
Median Position Error
P95 Position Error
Predicted Final Uncertainty
Quality State
ARCore Availability
Recovery Error
```

---

# 197. Calibration Evaluation Table (Kalibrasyon Değerlendirme Tablosu)

```text id="p28_051"
Session
Observed Error
Predicted Sigma
Ellipse Major Axis
Ellipse Minor Axis
Inside Declared Region?
Quality State
```

The exact columns will depend on the final uncertainty interpretation. *(Kesin sütunlar nihai belirsizlik yorumuna bağlı olacaktır.)*

---

# 198. Position Engine Test IDs (Konum Motoru Test ID'leri)

```text id="p28_052"
POS-MATH-001   ENU initialization
POS-MATH-002   ENU ↔ WGS84 conversion
POS-MATH-003   covariance extraction
POS-MATH-004   ellipse eigen decomposition
POS-MATH-005   sigma calculation

POS-VAL-001    finite state validation
POS-VAL-002    covariance symmetry
POS-VAL-003    non-negative variance
POS-VAL-004    stale estimate handling

POS-MODE-001   GNSS mode
POS-MODE-002   NAVGUARD mode
POS-MODE-003   Evaluation Mode isolation

POS-FUS-001    EKF state publication
POS-FUS-002    PDR-only publication
POS-FUS-003    ARCore degradation response

POS-UNC-001    uncertainty propagation
POS-UNC-002    quality-state mapping
POS-UNC-003    calibration analysis

POS-REC-001    pre-correction state preservation
POS-REC-002    recovery error calculation
POS-REC-003    relocalization provenance
POS-REC-004    historical immutability

POS-REP-001    replay equivalence
POS-REP-002    ground-truth firewall replay

POS-UI-001     uncertainty visualization mapping
POS-UI-002     UI downsampling isolation

POS-LOG-001    trajectory logging
POS-LOG-002    covariance logging
POS-LOG-003    anchor traceability
```

---

# 199. Position Validity Acceptance Criteria (Konum Geçerlilik Kabul Kriterleri)

Every published valid estimate must contain finite local coordinates. *(Yayınlanan her geçerli tahmin sonlu yerel koordinatlar içermelidir.)*

Geographic estimates must reference a valid anchor. *(Coğrafi tahminler geçerli anchor'a referans vermelidir.)*

---

# 200. Covariance Acceptance Criteria (Kovaryans Kabul Kriterleri)

A fused uncertainty output must contain finite covariance values. *(Füzyonlu belirsizlik çıktısı sonlu kovaryans değerleri içermelidir.)*

The horizontal covariance must remain symmetric within numerical tolerance. *(Yatay kovaryans sayısal tolerans içerisinde simetrik kalmalıdır.)*

Materially negative variances are forbidden. *(Anlamlı şekilde negatif varyanslar yasaktır.)*

---

# 201. Uncertainty Acceptance Criteria (Belirsizlik Kabul Kriterleri)

Every fused GNSS-denied position must expose numerical or explicit unavailable uncertainty state. *(Her füzyonlu GNSS kesintili konum sayısal veya açık kullanılamaz belirsizlik durumu sunmalıdır.)*

The application must never silently replace unknown uncertainty with zero. *(Uygulama bilinmeyen belirsizliği hiçbir zaman sessizce sıfırla değiştirmemelidir.)*

---

# 202. Quality Acceptance Criteria (Kalite Kabul Kriterleri)

Every current denied-navigation estimate must expose a position-quality state. *(Her mevcut kesintili navigasyon tahmini konum kalite durumu sunmalıdır.)*

Quality mapping must be versioned and documented. *(Kalite eşlemesi sürümlenmiş ve dokümante edilmiş olmalıdır.)*

---

# 203. Ground Truth Isolation Acceptance Criteria (Ground Truth İzolasyon Kabul Kriterleri)

Protected Evaluation Mode GNSS must never modify the denied position estimate before controlled recovery. *(Korunan Evaluation Mode GNSS kontrollü recovery öncesinde kesintili konum tahminini hiçbir zaman değiştirmemelidir.)*

Any violation invalidates the formal denied interval. *(Herhangi bir ihlal resmî kesintili aralığı geçersiz kılar.)*

---

# 204. Recovery Acceptance Criteria (Recovery Kabul Kriterleri)

Pre-correction position and covariance must be saved before any recovery correction is applied. *(Herhangi bir recovery düzeltmesi uygulanmadan önce düzeltme öncesi konum ve kovaryans saklanmalıdır.)*

Recovery error must be calculated before relocalization. *(Recovery hatası relocalization öncesinde hesaplanmalıdır.)*

---

# 205. Historical Integrity Acceptance Criteria (Geçmiş Bütünlük Kabul Kriterleri)

Relocalization must not retroactively modify previously committed denied-navigation trajectory points. *(Relocalization daha önce kesinleştirilmiş kesintili navigasyon trajectory noktalarını geriye dönük değiştirmemelidir.)*

---

# 206. UI Acceptance Criteria (UI Kabul Kriterleri)

The UI must visually distinguish estimated position from independent ground truth when both are displayed. *(UI ikisi de gösterildiğinde tahmini konumu bağımsız ground truth'tan görsel olarak ayırmalıdır.)*

The UI must not imply exact certainty during GNSS-denied navigation. *(UI GNSS kesintili navigasyon sırasında kesinlik ima etmemelidir.)*

---

# 207. Logging Acceptance Criteria (Logging Kabul Kriterleri)

Formal sessions must preserve enough position and uncertainty data to reconstruct denied-interval uncertainty evolution. *(Resmî oturumlar kesintili aralık belirsizlik gelişimini yeniden oluşturmak için yeterli konum ve belirsizlik verisini korumalıdır.)*

---

# 208. Replay Acceptance Criteria (Replay Kabul Kriterleri)

Replay must preserve the original Ground Truth Firewall boundary. *(Replay orijinal Ground Truth Firewall sınırını korumalıdır.)*

Equivalent frozen input and configuration must produce equivalent trajectory and uncertainty output within numerical tolerance. *(Eşdeğer sabitlenmiş girdi ve yapılandırma sayısal tolerans içerisinde eşdeğer trajectory ve belirsizlik çıktısı üretmelidir.)*

---

# 209. Calibration Acceptance Criteria (Kalibrasyon Kabul Kriterleri)

The final uncertainty model must be evaluated against observed reference errors on development sessions. *(Nihai belirsizlik modeli geliştirme oturumlarında gözlemlenen referans hatalara karşı değerlendirilmelidir.)*

Final benchmark data must not be used to retroactively tune the uncertainty model. *(Nihai benchmark verisi belirsizlik modelini geriye dönük ayarlamak için kullanılmamalıdır.)*

---

# 210. Minimum Successful Position Engine (Minimum Başarılı Konum Motoru)

The minimum successful implementation will expose local ENU position, converted WGS84 position, validity, basic confidence, trajectory history, and recovery error measurement. *(Minimum başarılı uygulama yerel ENU konumunu, dönüştürülmüş WGS84 konumunu, geçerliliği, temel güveni, trajectory geçmişini ve recovery hata ölçümünü sunacaktır.)*

---

# 211. Minimum Uncertainty Without Full EKF Calibration (Tam EKF Kalibrasyonu Olmadan Minimum Belirsizlik)

If final EKF covariance calibration is incomplete, the minimum system may expose clearly labeled heuristic PDR uncertainty and raw EKF covariance separately. *(Nihai EKF kovaryans kalibrasyonu tamamlanmamışsa minimum sistem açıkça etiketlenmiş heuristic PDR belirsizliğini ve ham EKF kovaryansını ayrı ayrı sunabilir.)*

It must not falsely present an unvalidated covariance region as guaranteed statistical confidence. *(Doğrulanmamış kovaryans bölgesini garantili istatistiksel güven olarak yanlış sunmamalıdır.)*

---

# 212. Target Successful Position Engine (Hedef Başarılı Konum Motoru)

The target implementation will provide validated EKF covariance, two-dimensional uncertainty visualization, quality-state mapping, calibration evidence, recovery consistency analysis, and complete trajectory provenance. *(Hedef uygulama doğrulanmış EKF kovaryansı, iki boyutlu belirsizlik görselleştirmesi, kalite durumu eşlemesi, kalibrasyon kanıtı, recovery tutarlılık analizi ve tam trajectory köken izlenebilirliği sağlayacaktır.)*

---

# 213. Optional Enhancements (İsteğe Bağlı İyileştirmeler)

Optional enhancements may include empirically calibrated confidence ellipses. *(İsteğe bağlı iyileştirmeler deneysel olarak kalibre edilmiş güven ellipse'lerini içerebilir.)*

Optional enhancements may include richer uncertainty-history visualization. *(İsteğe bağlı iyileştirmeler daha zengin belirsizlik geçmişi görselleştirmesini içerebilir.)*

Optional enhancements may include advanced covariance-consistency statistics. *(İsteğe bağlı iyileştirmeler gelişmiş kovaryans tutarlılık istatistiklerini içerebilir.)*

---

# 214. Position Engine Non-Goals (Konum Motoru Olmayan Hedefler)

The Position Engine will not perform raw sensor acquisition. *(Konum Motoru ham sensör toplama yapmayacaktır.)*

The Position Engine will not bypass the EKF to invent fused coordinates. *(Konum Motoru füzyonlu koordinatlar uydurmak için EKF'yi atlamayacaktır.)*

The Position Engine will not use protected GNSS ground truth during denied estimation. *(Konum Motoru kesintili tahmin sırasında korunan GNSS ground truth'u kullanmayacaktır.)*

---

# 215. Additional Non-Goals (Ek Olmayan Hedefler)

The Position Engine will not silently snap estimates to roads or map geometry. *(Konum Motoru tahminleri sessizce yollara veya harita geometrisine snap etmeyecektir.)*

The Position Engine will not claim statistically calibrated confidence without calibration evidence. *(Konum Motoru kalibrasyon kanıtı olmadan istatistiksel olarak kalibre edilmiş güven iddia etmeyecektir.)*

---

# 216. Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kararlar)

ENU will remain the authoritative local position representation during GNSS-denied navigation. *(ENU GNSS kesintili navigasyon sırasında ana yerel konum temsili olarak kalacaktır.)*

WGS84 latitude and longitude will be derived outputs for mapping and reporting. *(WGS84 enlem ve boylam haritalama ve raporlama için türetilmiş çıktılar olacaktır.)*

---

# 217. Position Source Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Konum Kaynağı Kararları)

Baseline PDR trajectory and fused trajectory will remain separate. *(Temel PDR trajectory'si ile füzyonlu trajectory ayrı kalacaktır.)*

Ground truth will remain a third independent reference stream in Evaluation Mode. *(Ground truth Evaluation Mode içerisinde üçüncü bağımsız referans akışı olarak kalacaktır.)*

---

# 218. Uncertainty Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Belirsizlik Kararları)

The fused estimator will expose horizontal covariance derived from the EKF state covariance. *(Füzyonlu tahmin motoru EKF durum kovaryansından türetilen yatay kovaryansı sunacaktır.)*

A 2D uncertainty ellipse representation will be supported. *(2D belirsizlik ellipse temsili desteklenecektir.)*

---

# 219. Statistical Interpretation Decisions Frozen by This Document (Bu Dokümanla Sabitlenen İstatistiksel Yorum Kararları)

NAVGUARD will not label covariance regions as statistically calibrated confidence regions until development evidence supports that interpretation. *(NAVGUARD geliştirme kanıtı bu yorumu destekleyene kadar kovaryans bölgelerini istatistiksel olarak kalibre edilmiş güven bölgeleri olarak etiketlemeyecektir.)*

---

# 220. Quality Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kalite Kararları)

Every denied-navigation estimate will expose explicit validity and quality information. *(Her kesintili navigasyon tahmini açık geçerlilik ve kalite bilgisi sunacaktır.)*

Unknown uncertainty will never be represented as zero uncertainty. *(Bilinmeyen belirsizlik hiçbir zaman sıfır belirsizlik olarak temsil edilmeyecektir.)*

---

# 221. Anchor Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Anchor Kararları)

The local origin will be exactly `[0,0]` after anchor initialization, but the physical anchor location will retain its own uncertainty. *(Yerel origin anchor initialization sonrasında tam olarak `[0,0]` olacaktır ancak fiziksel anchor konumu kendi belirsizliğini koruyacaktır.)*

---

# 222. Denial Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kesinti Kararları)

Entering GNSS-denied mode will not reset estimator state or covariance. *(GNSS kesintili moda girmek tahmin motoru durumunu veya kovaryansını resetlemeyecektir.)*

---

# 223. Recovery Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Recovery Kararları)

Pre-correction position and covariance will be preserved before relocalization. *(Düzeltme öncesi konum ve kovaryans relocalization öncesinde korunacaktır.)*

Recovery error will be measured before any correction is applied. *(Recovery hatası herhangi bir düzeltme uygulanmadan önce ölçülecektir.)*

Historical denied trajectory will remain immutable. *(Geçmiş kesintili trajectory değişmez kalacaktır.)*

---

# 224. Ground Truth Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Ground Truth Kararları)

Protected Evaluation Mode GNSS may be used for comparison but cannot affect denied estimation. *(Korunan Evaluation Mode GNSS karşılaştırma için kullanılabilir ancak kesintili tahmini etkileyemez.)*

---

# 225. Map Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Harita Kararları)

Map rendering will consume estimated position rather than generate it. *(Harita render tahmini konumu kullanacak, üretmeyecektir.)*

Hidden map matching or road snapping is forbidden within the current scope. *(Gizli map matching veya road snapping mevcut kapsam içerisinde yasaktır.)*

---

# 226. Logging Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Logging Kararları)

Formal position logs will preserve local coordinates, geographic coordinates, source, mode, quality, and uncertainty provenance. *(Resmî konum logları yerel koordinatları, coğrafi koordinatları, kaynağı, modu, kaliteyi ve belirsizlik kökenini koruyacaktır.)*

---

# 227. Replay Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Replay Kararları)

Replay will reproduce position and uncertainty through the same domain interfaces used by live navigation. *(Replay canlı navigasyon tarafından kullanılan aynı domain arayüzleri üzerinden konum ve belirsizliği yeniden üretecektir.)*

---

# 228. Decisions Pending EKF Calibration (EKF Kalibrasyonunu Bekleyen Kararlar)

The final process-noise values remain pending development experiments. *(Nihai süreç gürültüsü değerleri geliştirme deneylerini beklemektedir.)*

The final measurement-noise mappings remain pending validation. *(Nihai ölçüm gürültüsü eşlemeleri doğrulamayı beklemektedir.)*

---

# 229. Decisions Pending Uncertainty Calibration (Belirsizlik Kalibrasyonunu Bekleyen Kararlar)

The final scalar horizontal-uncertainty definition remains pending usability and calibration analysis. *(Nihai skaler yatay belirsizlik tanımı kullanılabilirlik ve kalibrasyon analizini beklemektedir.)*

The final quality thresholds remain pending observed error and covariance behavior. *(Nihai kalite eşikleri gözlemlenen hata ve kovaryans davranışını beklemektedir.)*

---

# 230. Decisions Pending Field Tests (Saha Testlerini Bekleyen Kararlar)

The final stale-position threshold remains pending measured estimator cadence. *(Nihai eski konum eşiği ölçülmüş tahmin motoru kadansını beklemektedir.)*

The final display uncertainty policy remains pending UI testing. *(Nihai gösterim belirsizlik politikası UI testlerini beklemektedir.)*

---

# 231. Decisions Pending Statistical Validation (İstatistiksel Doğrulamayı Bekleyen Kararlar)

The use of a formal 95% confidence ellipse remains pending covariance calibration evidence. *(Resmî %95 güven ellipse'i kullanımı kovaryans kalibrasyon kanıtını beklemektedir.)*

NEES or similar covariance-consistency statistics remain optional pending sufficient independent evidence. *(NEES veya benzer kovaryans tutarlılık istatistikleri yeterli bağımsız kanıtı bekleyen isteğe bağlı yöntemler olarak kalmaktadır.)*

---

# 232. Final Position Estimation & Uncertainty Architecture Statement (Nihai Konum Tahmini ve Belirsizlik Mimarisi Bildirimi)

**NAVGUARD will represent GNSS-denied navigation primarily in a fixed local ENU frame anchored to the last authorized geographic reference, while WGS84 latitude and longitude will remain deterministic output transformations used for map display, logging, and comparison.** *(NAVGUARD GNSS kesintili navigasyonu temel olarak son izin verilen coğrafi referansa anchor edilmiş sabit yerel ENU frame'inde temsil edecek, WGS84 enlem ve boylam ise harita gösterimi, logging ve karşılaştırma için kullanılan deterministik çıktı dönüşümleri olarak kalacaktır.)*

**The fused Position Estimation & Uncertainty Engine will expose the EKF's current East-North position together with horizontal covariance, uncertainty provenance, validity, quality, navigation mode, anchor identity, and geographic representation rather than publishing an apparently exact coordinate without context.** *(Füzyonlu Konum Tahmini ve Belirsizlik Motoru bağlam olmadan görünüşte kesin koordinat yayınlamak yerine EKF'nin mevcut East-North konumunu yatay kovaryans, belirsizlik kökeni, geçerlilik, kalite, navigasyon modu, anchor kimliği ve coğrafi temsille birlikte sunacaktır.)*

**Baseline PDR, fused NAVGUARD, and Evaluation Mode GNSS ground-truth trajectories will remain logically independent so that baseline comparison, Ground Truth Firewall integrity, and final experimental evaluation remain auditable.** *(Temel PDR, füzyonlu NAVGUARD ve Evaluation Mode GNSS ground-truth trajectory'leri temel karşılaştırma, Ground Truth Firewall bütünlüğü ve nihai deneysel değerlendirme denetlenebilir kalacak şekilde mantıksal olarak bağımsız kalacaktır.)*

**Position uncertainty will be derived from the estimator's covariance and validated quality information, with a two-dimensional covariance ellipse available for visualization and analysis, but no region will be presented as a calibrated probability guarantee until development experiments demonstrate that the stochastic model supports such an interpretation.** *(Konum belirsizliği tahmin motorunun kovaryansından ve doğrulanmış kalite bilgisinden türetilecek, görselleştirme ve analiz için iki boyutlu kovaryans ellipse'i kullanılabilir olacak ancak geliştirme deneyleri stokastik modelin böyle bir yorumu desteklediğini göstermeden hiçbir bölge kalibre edilmiş olasılık garantisi olarak sunulmayacaktır.)*

**During GNSS denial, uncertainty will evolve according to PDR, heading, step-length, ARCore, motion-context, and other authorized estimator information, while protected Evaluation Mode GNSS remains completely outside the estimator until the controlled recovery sequence explicitly permits relocalization.** *(GNSS kesintisi sırasında belirsizlik PDR, yön, adım uzunluğu, ARCore, hareket bağlamı ve diğer izin verilen tahmin motoru bilgilerine göre gelişirken korunan Evaluation Mode GNSS kontrollü recovery dizisi relocalization'a açıkça izin verene kadar tamamen tahmin motorunun dışında kalacaktır.)*

**At GNSS recovery, NAVGUARD will preserve the pre-correction estimated position and covariance, transform the validated recovery reference into the same ENU frame, calculate the pre-correction horizontal error, record that error as experimental evidence, and only then permit the Relocalization subsystem to modify the active estimator state.** *(GNSS recovery sırasında NAVGUARD düzeltme öncesi tahmini konumu ve kovaryansı koruyacak, doğrulanmış recovery referansını aynı ENU frame'ine dönüştürecek, düzeltme öncesi yatay hatayı hesaplayacak, bu hatayı deneysel kanıt olarak kaydedecek ve yalnızca daha sonra Relocalization alt sisteminin aktif tahmin motoru durumunu değiştirmesine izin verecektir.)*

**Historical denied-navigation trajectory points will remain immutable after relocalization, while replay may intentionally recompute alternative trajectories under explicit configuration without modifying the original live-session evidence.** *(Geçmiş kesintili navigasyon trajectory noktaları relocalization sonrasında değişmez kalacak, replay ise orijinal canlı oturum kanıtını değiştirmeden açık yapılandırma altında alternatif trajectory'leri bilinçli olarak yeniden hesaplayabilecektir.)*

**The user interface will communicate the approximate nature of denied-navigation position through quality and uncertainty visualization, and it will never imply exact location merely because latitude and longitude can be rendered with many decimal places.** *(Kullanıcı arayüzü kesintili navigasyon konumunun yaklaşık doğasını kalite ve belirsizlik görselleştirmesi üzerinden iletecek ve yalnızca enlem ile boylam çok sayıda ondalık basamakla gösterilebildiği için hiçbir zaman kesin konum ima etmeyecektir.)*

---

# 233. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development Position Estimation & Uncertainty Engine Design Completed *(Doküman Durumu: Geliştirme Öncesi Konum Tahmini ve Belirsizlik Motoru Tasarımı Tamamlandı)*

**Authoritative Denied Local Frame:** ENU *(Ana Kesintili Yerel Frame: ENU)*

**Primary Horizontal Position:** `[E, N]` *(Temel Yatay Konum: `[E, N]`)*

**Geographic Representation:** WGS84 Latitude / Longitude Derived from ENU *(Coğrafi Temsil: ENU'dan Türetilmiş WGS84 Enlem / Boylam)*

**Primary Fused State Owner:** EKF *(Temel Füzyonlu Durum Sahibi: EKF)*

**Fused Position Uncertainty Source:** EKF Covariance *(Füzyonlu Konum Belirsizlik Kaynağı: EKF Kovaryansı)*

**Primary Horizontal Covariance:** `P_EN` *(Temel Yatay Kovaryans: `P_EN`)*

**2D Uncertainty Ellipse:** Supported *(2D Belirsizlik Ellipse'i: Destekleniyor)*

**Formal 95% Confidence Claim:** Pending Covariance Calibration *(Resmî %95 Güven İddiası: Kovaryans Kalibrasyonu Bekleniyor)*

**Scalar Horizontal Uncertainty:** Final Definition Pending *(Skaler Yatay Belirsizlik: Nihai Tanım Bekleniyor)*

**Position Validity:** Explicit *(Konum Geçerliliği: Açık)*

**Position Quality:** Explicit *(Konum Kalitesi: Açık)*

**Unknown Uncertainty as Zero:** Forbidden *(Bilinmeyen Belirsizliği Sıfır Olarak Gösterme: Yasak)*

**Baseline PDR Trajectory:** Separate *(Temel PDR Trajectory'si: Ayrı)*

**Fused NAVGUARD Trajectory:** Separate *(Füzyonlu NAVGUARD Trajectory'si: Ayrı)*

**Evaluation GNSS Ground Truth:** Separate Protected Stream *(Evaluation GNSS Ground Truth: Ayrı Korunan Akış)*

**Denied GNSS Feedback:** Forbidden *(Kesintili GNSS Geri Beslemesi: Yasak)*

**Anchor Origin:** `E=0, N=0` *(Anchor Origin'i: `E=0, N=0`)*

**Physical Anchor Uncertainty:** Preserved *(Fiziksel Anchor Belirsizliği: Korunuyor)*

**Denial Transition State Reset:** Forbidden *(Kesinti Geçişinde Durum Reset'i: Yasak)*

**Position Covariance Reset on Denial:** Forbidden *(Kesintide Konum Kovaryansı Reset'i: Yasak)*

**Recovery Pre-Correction State Preservation:** Mandatory *(Recovery Düzeltme Öncesi Durum Koruma: Zorunlu)*

**Recovery Error Measurement Before Correction:** Mandatory *(Düzeltmeden Önce Recovery Hata Ölçümü: Zorunlu)*

**Historical Trajectory Rewriting:** Forbidden *(Geçmiş Trajectory Yeniden Yazma: Yasak)*

**Hidden Map Matching / Road Snapping:** Forbidden *(Gizli Map Matching / Road Snapping: Yasak)*

**Visual-Only Map Smoothing:** Optional and Must Not Affect Metrics *(Yalnızca Görsel Harita Smoothing: İsteğe Bağlı ve Metrikleri Etkilememeli)*

**Position Error Metrics:** Mean / Median / RMSE / Final / P95 *(Konum Hata Metrikleri: Mean / Median / RMSE / Final / P95)*

**Drift Metrics:** Metres per Time + Error per Travel Distance *(Drift Metrikleri: Zaman Başına Metre + Kat Edilen Mesafe Başına Hata)*

**Covariance Calibration:** Required for Statistical Confidence Claims *(Kovaryans Kalibrasyonu: İstatistiksel Güven İddiaları İçin Gerekli)*

**NEES / Advanced Consistency Metrics:** Optional *(NEES / Gelişmiş Tutarlılık Metrikleri: İsteğe Bağlı)*

**Final Quality Thresholds:** Pending Development Experiments *(Nihai Kalite Eşikleri: Geliştirme Deneyleri Bekleniyor)*

**Final Scalar Uncertainty Definition:** Pending Calibration / UI Evaluation *(Nihai Skaler Belirsizlik Tanımı: Kalibrasyon / UI Değerlendirmesi Bekleniyor)*

**Final Stale Position Threshold:** Pending Runtime Measurement *(Nihai Eski Konum Eşiği: Runtime Ölçümü Bekleniyor)*

**Final Formal Confidence Ellipse Policy:** Pending Calibration Evidence *(Nihai Resmî Güven Ellipse Politikası: Kalibrasyon Kanıtı Bekleniyor)*

**Next Documentation Item:** 29 — GNSS Recovery & Relocalization *(Sonraki Dokümantasyon Öğesi: 29 — GNSS Geri Kazanımı ve Relocalization)*
