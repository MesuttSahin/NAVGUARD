# 21 — Sensor Fusion & Extended Kalman Filter (Sensör Füzyonu ve Genişletilmiş Kalman Filtresi)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the sensor-fusion architecture, Extended Kalman Filter state representation, initialization, nonlinear PDR propagation, heading update, GNSS measurement update, ARCore measurement integration, process and measurement uncertainty, asynchronous event processing, innovation gating, quality-aware covariance, GNSS-denied behavior, recovery behavior, numerical-stability rules, logging, replay, evaluation, and acceptance criteria of NAVGUARD. *(Bu doküman, NAVGUARD’ın sensör füzyon mimarisini, Genişletilmiş Kalman Filtresi durum temsilini, başlatmayı, doğrusal olmayan PDR ilerletmesini, yön güncellemesini, GNSS ölçüm güncellemesini, ARCore ölçüm entegrasyonunu, süreç ve ölçüm belirsizliğini, asenkron olay işlemeyi, innovation gating’i, kalite farkındalıklı kovaryansı, GNSS kesintili davranışı, geri kazanım davranışını, sayısal kararlılık kurallarını, kaydı, replay’i, değerlendirmeyi ve kabul kriterlerini tanımlar.)*

The fusion engine will combine complementary navigation measurements without assuming that any individual source remains reliable under all conditions. *(Füzyon motoru herhangi bir bireysel kaynağın tüm koşullarda güvenilir kalacağını varsaymadan birbirini tamamlayan navigasyon ölçümlerini birleştirecektir.)*

The Extended Kalman Filter will be the target state-estimation method because NAVGUARD contains nonlinear step-based motion equations and measurements with different rates, qualities, and availability. *(Genişletilmiş Kalman Filtresi NAVGUARD doğrusal olmayan adım tabanlı hareket denklemleri ile farklı hızlara, kalitelere ve kullanılabilirliğe sahip ölçümler içerdiği için hedef durum tahmin yöntemi olacaktır.)*

---

# 2. Role of Sensor Fusion (Sensör Füzyonunun Rolü)

Sensor fusion will maintain one coherent navigation estimate from PDR propagation, heading observations, ARCore relative motion, and authorized GNSS measurements. *(Sensör füzyonu PDR ilerletmesi, yön gözlemleri, ARCore göreli hareketi ve yetkilendirilmiş GNSS ölçümlerinden tek tutarlı navigasyon tahmini tutacaktır.)*

The fusion engine will also maintain explicit uncertainty describing how certain the estimator is about its current state. *(Füzyon motoru ayrıca tahmin motorunun mevcut durumu hakkında ne kadar emin olduğunu açıklayan açık belirsizlik tutacaktır.)*

---

# 3. Fusion Does Not Replace Baseline Components (Füzyon Temel Bileşenlerin Yerini Almaz)

The baseline PDR trajectory will continue to exist independently from the fused trajectory. *(Temel PDR rotası füzyonlu rotadan bağımsız olarak var olmaya devam edecektir.)*

The baseline heading output will remain observable independently from the EKF heading state. *(Temel yön çıktısı EKF yön durumundan bağımsız olarak gözlemlenebilir kalacaktır.)*

ARCore and GNSS raw measurements will also remain independently logged. *(ARCore ve GNSS ham ölçümleri de bağımsız olarak kaydedilmeye devam edecektir.)*

This separation is required for ablation studies and error analysis. *(Bu ayrım ablation çalışmaları ve hata analizi için gereklidir.)*

---

# 4. Fusion Architecture (Füzyon Mimarisi)

`text id="m0f3pl" Step Detection ──► Step Length ──► PDR Process Model                                         │ Heading Estimate ───────────────────────┤                                         │ ARCore ENU Measurement ─────────────────┤                                         ▼                                    NAVGUARD EKF                                         │ Authorized GNSS ENU ────────────────────┤                                         │ Quality Engine ──► Quality / R / Gates ─┘                                         ↓                               Fused ENU State                                         ↓                                Uncertainty                                         ↓                                WGS84 / UI`

---

# 5. EKF State Philosophy (EKF Durum Felsefesi)

The first NAVGUARD EKF will intentionally use a compact state vector rather than immediately estimating every possible sensor bias and calibration parameter. *(İlk NAVGUARD EKF mümkün olan her sensör bias’ını ve kalibrasyon parametresini hemen tahmin etmek yerine bilinçli olarak kompakt bir durum vektörü kullanacaktır.)*

Additional states will be added only when experiments demonstrate that they provide measurable benefit. *(Ek durumlar yalnızca deneyler ölçülebilir fayda sağladıklarını gösterdiğinde eklenecektir.)*

---

# 6. Minimum EKF State Vector (Minimum EKF Durum Vektörü)

The initial EKF state will contain horizontal position and true-north heading. *(İlk EKF durumu yatay konumu ve gerçek kuzey yönünü içerecektir.)*

`text id="pmptq4" x = [E, N, ψ]ᵀ`

`E` is local East position in metres. *(`E`, metre cinsinden yerel Doğu konumudur.)*

`N` is local North position in metres. *(`N`, metre cinsinden yerel Kuzey konumudur.)*

`ψ` is pedestrian heading clockwise from true north. *(`ψ`, gerçek kuzeyden saat yönünde yaya yönüdür.)*

---

# 7. Why the Minimum State Is Compact (Minimum Durum Neden Kompakttır)

NAVGUARD baseline position propagation is step-event-driven rather than raw-acceleration double integration. *(NAVGUARD temel konum ilerletmesi ham ivme çift integrasyonu yerine adım olayı güdümlüdür.)*

A velocity state is therefore not required to make the minimum PDR-driven EKF operational. *(Bu nedenle minimum PDR güdümlü EKF’yi çalıştırmak için hız durumu gerekli değildir.)*

This reduces the number of weakly observable variables during the first implementation. *(Bu ilk uygulama sırasında zayıf gözlemlenebilir değişkenlerin sayısını azaltır.)*

---

# 8. Target Velocity-Augmented State (Hedef Hız Genişletilmiş Durum)

A later target experiment may evaluate an augmented state. *(Daha sonraki hedef deney genişletilmiş bir durumu değerlendirebilir.)*

`text id="e31v4z" x_aug = [E, N, vE, vN, ψ]ᵀ`

`vE` and `vN` represent local horizontal velocity. *(`vE` ve `vN`, yerel yatay hızı temsil eder.)*

The augmented state will be retained only if GNSS, ARCore, or other measured velocity information makes it sufficiently observable and improves navigation results. *(Genişletilmiş durum yalnızca GNSS, ARCore veya diğer ölçülmüş hız bilgileri onu yeterince gözlemlenebilir hale getirir ve navigasyon sonuçlarını iyileştirirse korunacaktır.)*

---

# 9. Bias States Policy (Bias Durumları Politikası)

Gyroscope bias, heading bias, step-length scale, and other calibration variables will not be included in the initial EKF state automatically. *(Jiroskop bias’ı, yön bias’ı, adım uzunluğu ölçeği ve diğer kalibrasyon değişkenleri başlangıç EKF durumuna otomatik olarak dahil edilmeyecektir.)*

Such states may be investigated only if pilot experiments demonstrate that the additional complexity is justified. *(Bu tür durumlar yalnızca pilot deneyler ek karmaşıklığın gerekçelendirildiğini gösterirse araştırılabilir.)*

---

# 10. EKF Estimate Notation (EKF Tahmin Gösterimi)

The predicted state before a measurement update will be written as follows. *(Bir ölçüm güncellemesinden önceki tahmin edilmiş durum aşağıdaki şekilde yazılacaktır.)*

`text id="va3gaa" x_k^-`

The corrected posterior state after a measurement update will be written as follows. *(Bir ölçüm güncellemesinden sonraki düzeltilmiş posterior durum aşağıdaki şekilde yazılacaktır.)*

`text id="ey5c5u" x_k^+`

---

# 11. State Covariance (Durum Kovaryansı)

The EKF will maintain state-estimation covariance. *(EKF durum tahmin kovaryansını tutacaktır.)*

`text id="gsgd4f" P = Cov(x - x_true)`

For the minimum three-state EKF, `P` will be a `3 × 3` matrix. *(Minimum üç durumlu EKF için `P`, `3 × 3` matris olacaktır.)*

---

# 12. Meaning of Covariance (Kovaryansın Anlamı)

The diagonal elements of `P` represent uncertainty associated with individual state dimensions. *(`P` matrisinin köşegen elemanları bireysel durum boyutlarıyla ilişkili belirsizliği temsil eder.)*

The off-diagonal elements represent correlations between state errors. *(Köşegen dışı elemanlar durum hataları arasındaki korelasyonları temsil eder.)*

---

# 13. Position and Heading Correlation (Konum ve Yön Korelasyonu)

PDR naturally creates correlation between heading uncertainty and horizontal position uncertainty. *(PDR doğal olarak yön belirsizliği ile yatay konum belirsizliği arasında korelasyon oluşturur.)*

A heading error changes the direction of every subsequent step displacement. *(Bir yön hatası sonraki her adım yer değiştirmesinin yönünü değiştirir.)*

The EKF Jacobian will explicitly propagate this relationship. *(EKF Jacobian’ı bu ilişkiyi açıkça ilerletecektir.)*

---

# 14. EKF Initialization (EKF Başlatma)

Formal EKF initialization will occur only after a validated GNSS anchor and valid initial heading are available. *(Resmî EKF başlatma yalnızca doğrulanmış bir GNSS çapası ve geçerli başlangıç yönü mevcut olduktan sonra gerçekleşecektir.)*

The initial local position will correspond to the ENU origin. *(Başlangıç yerel konumu ENU başlangıç noktasına karşılık gelecektir.)*

`text id="07zm0u" x_0 = [0, 0, ψ_0]ᵀ`

---

# 15. Initial Heading (Başlangıç Yönü)

`ψ_0` will be supplied by the validated Heading Estimation System. *(`ψ_0`, doğrulanmış Yön Tahmin Sistemi tarafından sağlanacaktır.)*

A formal navigation benchmark will not initialize heading to an arbitrary default such as zero when no valid heading is available. *(Geçerli yön mevcut olmadığında resmî navigasyon benchmark’ı yönü sıfır gibi keyfi bir varsayılan değere başlatmayacaktır.)*

---

# 16. Initial Covariance (Başlangıç Kovaryansı)

The initial covariance matrix `P_0` will represent uncertainty in the GNSS anchor and initial heading. *(`P_0` başlangıç kovaryans matrisi GNSS çapası ve başlangıç yönündeki belirsizliği temsil edecektir.)*

`text id="ki1ecy" P_0 = [ σE0²       0          0    ] [   0      σN0²         0    ] [   0        0        σψ0²   ]`

The final numerical values will be calibrated from device measurements. *(Nihai sayısal değerler cihaz ölçümlerinden kalibre edilecektir.)*

---

# 17. Initial Position Uncertainty (Başlangıç Konum Belirsizliği)

GNSS-reported horizontal accuracy may contribute to the initial position covariance model. *(GNSS tarafından raporlanan yatay doğruluk başlangıç konum kovaryansı modeline katkıda bulunabilir.)*

It will not automatically be interpreted as an exact Gaussian standard deviation without calibration. *(Kalibrasyon olmadan otomatik olarak kesin Gaussian standart sapması şeklinde yorumlanmayacaktır.)*

---

# 18. Initial Heading Uncertainty (Başlangıç Yön Belirsizliği)

Initial heading covariance will be based on the validated heading source and measured heading performance. *(Başlangıç yön kovaryansı doğrulanmış yön kaynağına ve ölçülmüş yön performansına dayanacaktır.)*

A magnetically disturbed initialization must not receive the same covariance as a stable open-environment initialization. *(Manyetik olarak bozulmuş bir başlatma kararlı açık ortam başlatmasıyla aynı kovaryansı almamalıdır.)*

---

# 19. EKF Event-Driven Architecture (EKF Olay Güdümlü Mimarisi)

NAVGUARD will use an asynchronous event-driven EKF rather than forcing all sensors into one artificial common sampling frequency. *(NAVGUARD tüm sensörleri tek yapay ortak örnekleme frekansına zorlamak yerine asenkron olay güdümlü EKF kullanacaktır.)*

Every valid navigation event will be processed according to its timestamp and type. *(Her geçerli navigasyon olayı zaman damgasına ve türüne göre işlenecektir.)*

---

# 20. Primary EKF Event Types (Temel EKF Olay Türleri)

`text id="87glkg" HEADING_MEASUREMENT STEP_PROPAGATION ARCORE_MEASUREMENT GNSS_MEASUREMENT MODE_TRANSITION QUALITY_TRANSITION RELOCALIZATION_EVENT`

---

# 21. Timestamp Ordering (Zaman Damgası Sıralaması)

Events must be processed in monotonic navigation time order. *(Olaylar monotonik navigasyon zamanı sırasıyla işlenmelidir.)*

Arrival order at the Flutter interface must not override authoritative measurement timestamps. *(Flutter arayüzüne varış sırası ana ölçüm zaman damgalarının önüne geçmemelidir.)*

---

# 22. Late Measurement Policy (Geç Gelen Ölçüm Politikası)

A measurement that arrives after the EKF has already committed a significantly newer state must not silently update the past. *(EKF anlamlı şekilde daha yeni bir durumu zaten kesinleştirdikten sonra gelen bir ölçüm geçmişi sessizce güncellememelidir.)*

The first live implementation may reject excessively late measurements and log them. *(İlk canlı uygulama aşırı geç gelen ölçümleri reddedebilir ve kaydedebilir.)*

A bounded reorder buffer may later be introduced if measured transport latency justifies it. *(Ölçülen taşıma gecikmesi gerekçelendirirse daha sonra sınırlı bir yeniden sıralama tamponu eklenebilir.)*

---

# 23. No Hidden Online Smoothing (Gizli Çevrimiçi Smoothing Olmaması)

The real-time EKF will remain causal. *(Gerçek zamanlı EKF nedensel kalacaktır.)*

Future measurements will not retrospectively improve previously displayed historical real-time estimates. *(Gelecekteki ölçümler daha önce gösterilmiş geçmiş gerçek zamanlı tahminleri geriye dönük olarak iyileştirmeyecektir.)*

Offline smoothing may be investigated separately and must be reported separately. *(Çevrimdışı smoothing ayrı olarak araştırılabilir ve ayrı raporlanmalıdır.)*

---

# 24. PDR as the Primary Process Model (Temel Süreç Modeli Olarak PDR)

The minimum EKF will use accepted pedestrian steps as its primary horizontal process-propagation events. *(Minimum EKF kabul edilmiş yaya adımlarını temel yatay süreç ilerletme olayları olarak kullanacaktır.)*

This preserves the step-based PDR architecture defined in **16 — Pedestrian Dead Reckoning — PDR**. *(Bu, **16 — Pedestrian Dead Reckoning — PDR** içerisinde tanımlanan adım tabanlı PDR mimarisini korur.)*

---

# 25. Step Propagation Input (Adım İlerletme Girdisi)

For each accepted step, the process model will receive a step length `L_k`. *(Kabul edilen her adım için süreç modeli bir `L_k` adım uzunluğu alacaktır.)*

The current EKF heading state will determine the step direction. *(Mevcut EKF yön durumu adım yönünü belirleyecektir.)*

---

# 26. Heading Update Before Step Propagation (Adım İlerletmeden Önce Yön Güncellemesi)

When an aligned heading observation exists at the step timestamp, the EKF will normally process the heading measurement before propagating that step. *(Adım zaman damgasında hizalanmış bir yön gözlemi mevcut olduğunda EKF normalde o adımı ilerletmeden önce yön ölçümünü işleyecektir.)*

This allows the step direction to use the most recent validated heading information. *(Bu adım yönünün en son doğrulanmış yön bilgisini kullanmasına olanak sağlar.)*

---

# 27. Nonlinear Step Process Model (Doğrusal Olmayan Adım Süreç Modeli)

For the minimum state, one accepted step will propagate the state as follows. *(Minimum durum için kabul edilmiş bir adım durumu aşağıdaki şekilde ilerletecektir.)*

```text id=“s4zrlk”
E_k^- =
E_(k-1)^+ + L_k sin(ψ_(k-1)^+)

N_k^- =
N_(k-1)^+ + L_k cos(ψ_(k-1)^+)

ψ_k^- =
ψ_(k-1)^+

```

The sine and cosine terms make this process model nonlinear. *(Sinüs ve kosinüs terimleri bu süreç modelini doğrusal olmayan hale getirir.)*

---

# 28. Step Process Function (Adım Süreç Fonksiyonu)

The process equation may be written compactly as follows. *(Süreç denklemi kompakt şekilde aşağıdaki gibi yazılabilir.)*

```text id="n42i6e"
x_k^- =
f(
x_(k-1)^+,
L_k
)
```

---

# 29. Step Process Jacobian (Adım Süreç Jacobian’ı)

The EKF requires the Jacobian of the nonlinear process model with respect to the state. *(EKF doğrusal olmayan süreç modelinin duruma göre Jacobian’ına ihtiyaç duyar.)*

```text id=“ge4fc7”
F_k =

[ 1 0 L_k cos(ψ) ]
[ 0 1 -L_k sin(ψ) ]
[ 0 0 1 ]

```

The Jacobian explicitly transfers heading uncertainty into East and North uncertainty. *(Jacobian yön belirsizliğini açıkça Doğu ve Kuzey belirsizliğine aktarır.)*

---

# 30. Step-Length Noise Input (Adım Uzunluğu Gürültü Girdisi)

Step-length uncertainty will enter the position process through a noise mapping vector. *(Adım uzunluğu belirsizliği konum sürecine bir gürültü eşleme vektörü üzerinden girecektir.)*

```text id="gp5gk5"
G_L =

[ sin(ψ) ]
[ cos(ψ) ]
[   0    ]
```

---

# 31. Step-Length Variance (Adım Uzunluğu Varyansı)

The active step-length estimator will provide or be assigned a validated step-length uncertainty. *(Aktif adım uzunluğu tahmin motoru doğrulanmış bir adım uzunluğu belirsizliği sağlayacak veya ona atanacaktır.)*

`text id="v24121" σL²`

Fixed, deterministic, and ML-based step-length methods may use different uncertainty models. *(Sabit, deterministik ve ML tabanlı adım uzunluğu yöntemleri farklı belirsizlik modelleri kullanabilir.)*

---

# 32. Heading Process Noise (Yön Süreç Gürültüsü)

The heading state may accumulate additional process uncertainty between trusted heading observations. *(Yön durumu güvenilir yön gözlemleri arasında ek süreç belirsizliği biriktirebilir.)*

This contribution will be represented by a heading process-noise term. *(Bu katkı yön süreç gürültüsü terimiyle temsil edilecektir.)*

`text id="dt0ae4" q_ψ`

The final value will depend on heading-source behavior and quality. *(Nihai değer yön kaynağı davranışına ve kalitesine bağlı olacaktır.)*

---

# 33. Step Process Noise Matrix (Adım Süreç Gürültü Matrisi)

A candidate step-process uncertainty model may be written as follows. *(Aday adım süreç belirsizlik modeli aşağıdaki şekilde yazılabilir.)*

`text id="u9a87t" Q_step = G_L σL² G_Lᵀ + diag( 0, 0, q_ψ )`

Additional empirically required terms may be added after validation. *(Doğrulama sonrasında ampirik olarak gerekli ek terimler eklenebilir.)*

---

# 34. Covariance Prediction (Kovaryans Tahmini)

The covariance will propagate through the nonlinear process Jacobian. *(Kovaryans doğrusal olmayan süreç Jacobian’ı üzerinden ilerletilecektir.)*

`text id="288jc4" P_k^- = F_k P_(k-1)^+ F_kᵀ + Q_step`

---

# 35. No Step Means No Baseline PDR Translation (Adım Yoksa Temel PDR Ötelemesi Yoktur)

When no step is accepted, the minimum PDR-driven process model will not intentionally translate East or North position. *(Hiçbir adım kabul edilmediğinde minimum PDR güdümlü süreç modeli Doğu veya Kuzey konumunu kasıtlı olarak ilerletmeyecektir.)*

Other valid measurement updates may still modify the fused state. *(Diğer geçerli ölçüm güncellemeleri yine de füzyonlu durumu değiştirebilir.)*

---

# 36. Stationary Behavior (Sabit Durum Davranışı)

During validated stationary periods, false PDR propagation must remain suppressed. *(Doğrulanmış sabit dönemlerde yanlış PDR ilerletmesi bastırılmış kalmalıdır.)*

The EKF may still receive ARCore, heading, or authorized GNSS measurements according to the active navigation configuration. *(EKF aktif navigasyon yapılandırmasına göre yine de ARCore, yön veya yetkilendirilmiş GNSS ölçümleri alabilir.)*

---

# 37. Stationary ARCore Caution (Sabit Durumda ARCore Dikkati)

Stationary motion evidence does not automatically permit ARCore to move the fused position because small ARCore stationary drift may exist. *(Sabit hareket kanıtı küçük ARCore sabit sürüklenmesi mevcut olabileceği için ARCore’un füzyonlu konumu otomatik olarak hareket ettirmesine izin vermez.)*

Quality and fusion uncertainty must reflect the measured stationary ARCore behavior. *(Kalite ve füzyon belirsizliği ölçülmüş sabit ARCore davranışını yansıtmalıdır.)*

---

# 38. Heading Measurement Update (Yön Ölçüm Güncellemesi)

The EKF will receive true-north heading measurements from the Heading Estimation System. *(EKF Yön Tahmin Sisteminden gerçek kuzey yön ölçümleri alacaktır.)*

`text id="w8oa66" z_ψ = ψ_measured`

---

# 39. Heading Measurement Function (Yön Ölçüm Fonksiyonu)

For the minimum state, the expected heading measurement is as follows. *(Minimum durum için beklenen yön ölçümü aşağıdaki gibidir.)*

`text id="dfayni" h_ψ(x) = ψ`

The corresponding measurement Jacobian is as follows. *(Karşılık gelen ölçüm Jacobian’ı aşağıdaki gibidir.)*

`text id="xt2wf3" H_ψ = [0  0  1]`

---

# 40. Circular Heading Innovation (Dairesel Yön Innovation’ı)

Heading innovation must use circular-angle difference. *(Yön innovation’ı dairesel açı farkını kullanmalıdır.)*

`text id="vgrjpo" y_ψ = atan2( sin(z_ψ - ψ^-), cos(z_ψ - ψ^-) )`

Ordinary subtraction without wrap handling is forbidden for heading innovation. *(Wrap yönetimi olmadan sıradan çıkarma yön innovation’ı için yasaktır.)*

---

# 41. Heading Measurement Noise (Yön Ölçüm Gürültüsü)

Heading measurement uncertainty will be represented by `R_ψ`. *(Yön ölçüm belirsizliği `R_ψ` ile temsil edilecektir.)*

`text id="vl7xew" R_ψ = [σ_ψ,meas²]`

The value may depend on heading source and current heading quality. *(Değer yön kaynağına ve mevcut yön kalitesine bağlı olabilir.)*

---

# 42. Quality-Aware Heading R (Kalite Farkındalıklı Yön R Değeri)

A stable high-quality fused heading may receive lower measurement variance. *(Kararlı yüksek kaliteli füzyonlu yön daha düşük ölçüm varyansı alabilir.)*

Gyroscope-only or magnetically degraded heading may receive larger variance. *(Yalnızca jiroskopa dayalı veya manyetik olarak bozulmuş yön daha büyük varyans alabilir.)*

An invalid heading measurement will be rejected rather than assigned an extremely large finite variance. *(Geçersiz yön ölçümü son derece büyük sonlu varyans atanmak yerine reddedilecektir.)*

---

# 43. GNSS Position Measurement (GNSS Konum Ölçümü)

When estimator GNSS access is authorized, a validated GNSS fix will be converted to the active ENU frame. *(Tahmin motoru GNSS erişimi yetkilendirildiğinde doğrulanmış bir GNSS fix’i aktif ENU çerçevesine dönüştürülecektir.)*

```text id=“end15m”
z_GNSS =

[E_GNSS]
[N_GNSS]

```

---

# 44. GNSS Measurement Function (GNSS Ölçüm Fonksiyonu)

The expected GNSS measurement for the minimum state is the current horizontal position. *(Minimum durum için beklenen GNSS ölçümü mevcut yatay konumdur.)*

```text id="0wpzsi"
h_GNSS(x) =

[E]
[N]
```

The measurement Jacobian is as follows. *(Ölçüm Jacobian’ı aşağıdaki gibidir.)*

```text id=“4l4ew8”
H_GNSS =

[1 0 0]
[0 1 0]

```

---

# 45. GNSS Measurement Covariance (GNSS Ölçüm Kovaryansı)

The initial GNSS measurement covariance will use a horizontal uncertainty model. *(İlk GNSS ölçüm kovaryansı yatay bir belirsizlik modeli kullanacaktır.)*

```text id="se1s74"
R_GNSS =

[σE_GNSS²      ρEN]
[   ρEN      σN_GNSS²]
```

An isotropic diagonal approximation may be used initially if no reliable directional covariance information is available. *(Güvenilir yönsel kovaryans bilgisi mevcut değilse başlangıçta izotropik köşegen yaklaşımı kullanılabilir.)*

---

# 46. Android Accuracy Mapping (Android Doğruluk Eşlemesi)

Android-reported horizontal accuracy may contribute to `R_GNSS`. *(Android tarafından raporlanan yatay doğruluk `R_GNSS` değerine katkıda bulunabilir.)*

The final conversion from Android accuracy to EKF covariance will be calibrated against recorded field behavior. *(Android doğruluğundan EKF kovaryansına nihai dönüşüm kaydedilmiş saha davranışına karşı kalibre edilecektir.)*

---

# 47. GNSS Quality Scaling (GNSS Kalite Ölçekleme)

A usable but degraded GNSS fix may receive larger measurement covariance than a higher-quality fix. *(Kullanılabilir ancak bozulmuş GNSS fix’i daha yüksek kaliteli fix’e göre daha büyük ölçüm kovaryansı alabilir.)*

A stale or otherwise invalid GNSS fix will be rejected. *(Eski veya başka şekilde geçersiz GNSS fix’i reddedilecektir.)*

---

# 48. Ground Truth Firewall Before EKF (EKF Öncesi Ground Truth Firewall)

The EKF will never decide independently whether Evaluation Mode GNSS may be used. *(EKF Değerlendirme Modu GNSS’inin kullanılıp kullanılamayacağına bağımsız olarak karar vermeyecektir.)*

The Ground Truth Firewall will block unauthorized GNSS before the measurement reaches EKF update logic. *(Ground Truth Firewall yetkisiz GNSS’i ölçüm EKF güncelleme mantığına ulaşmadan önce engelleyecektir.)*

---

# 49. GNSS Quality Cannot Override Authorization (GNSS Kalitesi Yetkilendirmeyi Geçersiz Kılamaz)

Even an excellent GNSS measurement must not update the EKF while estimator GNSS access is `BLOCKED`. *(Mükemmel bir GNSS ölçümü bile tahmin motoru GNSS erişimi `BLOCKED` iken EKF’yi güncellememelidir.)*

This is a mandatory experiment-integrity rule. *(Bu zorunlu bir deney bütünlüğü kuralıdır.)*

---

# 50. ARCore Measurement Principle (ARCore Ölçüm İlkesi)

ARCore will provide aligned local visual-inertial motion information rather than global geographic coordinates. *(ARCore global coğrafi koordinatlar yerine hizalanmış yerel görsel-ataletsel hareket bilgisi sağlayacaktır.)*

Only validated ARCore measurements in the NAVGUARD ENU frame may enter the EKF. *(Yalnızca NAVGUARD ENU çerçevesindeki doğrulanmış ARCore ölçümleri EKF’ye girebilir.)*

---

# 51. ARCore Segment Origin (ARCore Segment Başlangıcı)

When a new ARCore navigation segment begins, the current fused ENU position will be preserved as the segment’s navigation origin. *(Yeni bir ARCore navigasyon segmenti başladığında mevcut füzyonlu ENU konumu segmentin navigasyon başlangıcı olarak korunacaktır.)*

`text id="s5j3xo" p_seg,0 = [E_seg,0, N_seg,0]ᵀ`

---

# 52. ARCore Segment Pseudo-Position Candidate (ARCore Segment Pseudo-Konum Adayı)

Aligned ARCore displacement relative to the segment origin may produce an ENU pseudo-position. *(Segment başlangıcına göre hizalanmış ARCore yer değiştirmesi bir ENU pseudo-konumu üretebilir.)*

```text id=“3qa20f”
z_AR =

[E_seg,0 + ΔE_AR]
[N_seg,0 + ΔN_AR]

```

This is the initial target implementation because it allows ARCore to use the standard EKF position-measurement interface. *(Bu, ARCore'un standart EKF konum ölçüm arayüzünü kullanmasına olanak sağladığı için ilk hedef uygulamadır.)*

---

# 53. ARCore Measurement Function (ARCore Ölçüm Fonksiyonu)

For the pseudo-position formulation, the expected measurement is the EKF horizontal position. *(Pseudo-konum formülasyonu için beklenen ölçüm EKF yatay konumudur.)*

```text id="86gfcs"
h_AR(x) =

[E]
[N]
```

The corresponding Jacobian is as follows. *(Karşılık gelen Jacobian aşağıdaki gibidir.)*

```text id=“uqh5wn”
H_AR =

[1 0 0]
[0 1 0]

```

---

# 54. ARCore Segment-Origin Correlation (ARCore Segment Başlangıç Korelasyonu)

The ARCore pseudo-position is not statistically independent from the fused position used to create its segment origin. *(ARCore pseudo-konumu segment başlangıcını oluşturmak için kullanılan füzyonlu konumdan istatistiksel olarak bağımsız değildir.)*

This correlation must not be ignored when interpreting filter consistency. *(Filtre tutarlılığı yorumlanırken bu korelasyon göz ardı edilmemelidir.)*

---

# 55. Conservative ARCore Covariance (Temkinli ARCore Kovaryansı)

The initial ARCore pseudo-position implementation will therefore use conservative covariance that accounts for visual-inertial motion uncertainty, alignment uncertainty, and segment-origin uncertainty. *(Bu nedenle ilk ARCore pseudo-konum uygulaması görsel-ataletsel hareket belirsizliğini, hizalama belirsizliğini ve segment başlangıç belirsizliğini dikkate alan temkinli kovaryans kullanacaktır.)*

---

# 56. ARCore Effective Measurement Covariance (ARCore Etkin Ölçüm Kovaryansı)

Conceptually, the ARCore covariance may contain several components. *(Kavramsal olarak ARCore kovaryansı birkaç bileşen içerebilir.)*

```text id="6t4epl"
R_AR,effective
≈
R_motion
+
R_alignment
+
R_segment_origin
```

This expression is an engineering decomposition rather than a final statistically independent covariance identity. *(Bu ifade nihai istatistiksel olarak bağımsız kovaryans eşitliği yerine mühendislik ayrıştırmasıdır.)*

---

# 57. ARCore Relative-State Alternative (ARCore Göreli Durum Alternatifi)

If pseudo-position correlation causes measurable EKF inconsistency, a relative-displacement formulation may be implemented. *(Pseudo-konum korelasyonu ölçülebilir EKF tutarsızlığı oluşturursa göreli yer değiştirme formülasyonu geliştirilebilir.)*

Such a formulation may require previous-state augmentation or a separate delta-state update. *(Böyle bir formülasyon önceki durum genişletmesini veya ayrı bir delta-state güncellemesini gerektirebilir.)*

The more complex method will be introduced only if experiments justify it. *(Daha karmaşık yöntem yalnızca deneyler gerekçelendirirse dahil edilecektir.)*

---

# 58. ARCore Tracking Gate (ARCore Takip Kapısı)

ARCore measurements will be rejected unless the tracking and segment-validity requirements defined in **19 — ARCore Visual-Inertial Tracking** are satisfied. *(ARCore ölçümleri **19 — ARCore Visual-Inertial Tracking** içerisinde tanımlanan takip ve segment geçerlilik gereksinimleri karşılanmadıkça reddedilecektir.)*

A `PAUSED`, stale, or jump-rejected ARCore pose must not reach the normal EKF update. *(Bir `PAUSED`, eski veya sıçrama nedeniyle reddedilmiş ARCore pozu normal EKF güncellemesine ulaşmamalıdır.)*

---

# 59. General Measurement Update (Genel Ölçüm Güncellemesi)

For a valid measurement `z_k`, the EKF innovation is defined as follows. *(Geçerli bir `z_k` ölçümü için EKF innovation aşağıdaki şekilde tanımlanır.)*

`text id="6k34mh" y_k = z_k - h(x_k^-)`

Circular measurement quantities will use wrapped innovation instead of ordinary subtraction. *(Dairesel ölçüm büyüklükleri sıradan çıkarma yerine wrap edilmiş innovation kullanacaktır.)*

---

# 60. Innovation Covariance (Innovation Kovaryansı)

The innovation covariance will be calculated as follows. *(Innovation kovaryansı aşağıdaki şekilde hesaplanacaktır.)*

`text id="2tpx9p" S_k = H_k P_k^- H_kᵀ + R_k`

---

# 61. Kalman Gain (Kalman Gain)

The Kalman gain will be calculated as follows. *(Kalman gain aşağıdaki şekilde hesaplanacaktır.)*

`text id="jyzd6l" K_k = P_k^- H_kᵀ S_k^-1`

A numerically stable linear solve should be preferred over explicitly forming a matrix inverse when implementing the calculation. *(Hesap uygulanırken açıkça matris tersi oluşturmak yerine sayısal olarak kararlı doğrusal çözüm tercih edilmelidir.)*

---

# 62. State Correction (Durum Düzeltmesi)

The posterior state will be calculated as follows. *(Posterior durum aşağıdaki şekilde hesaplanacaktır.)*

`text id="a97jzp" x_k^+ = x_k^- + K_k y_k`

The heading component will be normalized after every update. *(Yön bileşeni her güncellemeden sonra normalize edilecektir.)*

---

# 63. Covariance Correction (Kovaryans Düzeltmesi)

NAVGUARD will prefer the Joseph stabilized covariance update. *(NAVGUARD Joseph kararlı kovaryans güncellemesini tercih edecektir.)*

`text id="dk65ma" P_k^+ = (I - K_k H_k) P_k^- (I - K_k H_k)ᵀ + K_k R_k K_kᵀ`

This form provides better numerical robustness than the simplified covariance update under finite-precision arithmetic. *(Bu form sonlu hassasiyetli aritmetik altında basitleştirilmiş kovaryans güncellemesine göre daha iyi sayısal dayanıklılık sağlar.)*

---

# 64. Covariance Symmetry (Kovaryans Simetrisi)

Numerical implementation will monitor covariance symmetry. *(Sayısal uygulama kovaryans simetrisini izleyecektir.)*

Small floating-point asymmetry may be corrected explicitly when required. *(Küçük floating-point asimetrisi gerektiğinde açıkça düzeltilebilir.)*

`text id="3k4cuc" P ← (P + Pᵀ) / 2`

---

# 65. Positive-Semidefinite Requirement (Pozitif Yarı Tanımlı Gereksinimi)

The covariance matrix must remain positive semidefinite within numerical tolerance. *(Kovaryans matrisi sayısal tolerans içerisinde pozitif yarı tanımlı kalmalıdır.)*

A covariance matrix containing invalid negative variances indicates a numerical or modeling failure. *(Geçersiz negatif varyanslar içeren bir kovaryans matrisi sayısal veya modelleme hatasını gösterir.)*

---

# 66. Innovation Gating (Innovation Gating)

A measurement that passes source-quality validation may still be inconsistent with the predicted state. *(Kaynak kalite doğrulamasını geçen bir ölçüm yine de tahmin edilmiş durumla tutarsız olabilir.)*

The EKF may therefore apply an innovation-based statistical gate. *(Bu nedenle EKF innovation tabanlı istatistiksel kapı uygulayabilir.)*

---

# 67. Normalized Innovation Squared (Normalize Innovation Karesi)

For vector measurements, the normalized innovation squared can be calculated as follows. *(Vektör ölçümleri için normalize innovation karesi aşağıdaki şekilde hesaplanabilir.)*

`text id="lk726g" NIS = y_kᵀ S_k^-1 y_k`

---

# 68. NIS Gate (NIS Kapısı)

A measurement may be rejected or degraded when its NIS exceeds the configured statistical threshold. *(NIS değeri yapılandırılmış istatistiksel eşiği aştığında bir ölçüm reddedilebilir veya düşük kaliteli hale getirilebilir.)*

The threshold may be selected from an appropriate chi-square distribution for the measurement dimension. *(Eşik ölçüm boyutu için uygun chi-square dağılımından seçilebilir.)*

The final confidence level will be frozen before final benchmarking rather than selected after observing final results. *(Nihai güven seviyesi nihai sonuçlar görüldükten sonra seçilmek yerine final benchmark’tan önce sabitlenecektir.)*

---

# 69. Innovation Gate Is Not a Substitute for Source Quality (Innovation Kapısı Kaynak Kalitesinin Yerini Almaz)

An invalid ARCore or GNSS measurement should be rejected before EKF statistical gating. *(Geçersiz ARCore veya GNSS ölçümü EKF istatistiksel gating’inden önce reddedilmelidir.)*

The innovation gate is an additional consistency defense. *(Innovation kapısı ek bir tutarlılık savunmasıdır.)*

---

# 70. Innovation Rejection Logging (Innovation Red Kaydı)

Every innovation-based rejection during formal research sessions will be logged. *(Resmî araştırma oturumları sırasında innovation tabanlı her red kaydedilecektir.)*

The log will identify measurement source, innovation, NIS, threshold, and active covariance. *(Kayıt ölçüm kaynağını, innovation’ı, NIS değerini, eşiği ve aktif kovaryansı tanımlayacaktır.)*

---

# 71. Process Noise Q (Süreç Gürültüsü Q)

`Q` represents uncertainty introduced by the state-propagation model. *(`Q`, durum ilerletme modeli tarafından eklenen belirsizliği temsil eder.)*

For NAVGUARD, important process uncertainty includes step-length error and unresolved heading evolution. *(NAVGUARD için önemli süreç belirsizliği adım uzunluğu hatasını ve çözümlenmemiş yön değişimini içerir.)*

---

# 72. Measurement Noise R (Ölçüm Gürültüsü R)

`R` represents uncertainty associated with a measurement source. *(`R`, bir ölçüm kaynağıyla ilişkili belirsizliği temsil eder.)*

GNSS, heading, and ARCore will use separate measurement-noise models. *(GNSS, yön ve ARCore ayrı ölçüm gürültüsü modelleri kullanacaktır.)*

---

# 73. State Covariance P (Durum Kovaryansı P)

`P` represents the estimator’s current uncertainty about its state after accounting for past process and measurement information. *(`P`, geçmiş süreç ve ölçüm bilgileri dikkate alındıktan sonra tahmin motorunun mevcut durumu hakkındaki belirsizliğini temsil eder.)*

`P`, `Q`, and `R` must remain conceptually distinct. *(`P`, `Q` ve `R` kavramsal olarak ayrı kalmalıdır.)*

---

# 74. No Arbitrary Q and R Tuning (Keyfi Q ve R Ayarı Olmaması)

NAVGUARD will not select final `Q` and `R` values only because they make one demonstration trajectory look visually better. *(NAVGUARD nihai `Q` ve `R` değerlerini yalnızca bir gösterim rotasını görsel olarak daha iyi gösterdikleri için seçmeyecektir.)*

Noise values will be estimated and tuned from development data and then frozen before final evaluation. *(Gürültü değerleri geliştirme verisinden tahmin edilip ayarlanacak ve nihai değerlendirmeden önce sabitlenecektir.)*

---

# 75. Step-Length Q Calibration (Adım Uzunluğu Q Kalibrasyonu)

Step-length residuals from calibration or validation sessions may be used to estimate `σL²`. *(Kalibrasyon veya doğrulama oturumlarından adım uzunluğu residual değerleri `σL²` tahmini için kullanılabilir.)*

Different motion classes may eventually use different step process uncertainty if data supports that distinction. *(Veri bu ayrımı desteklerse farklı hareket sınıfları sonunda farklı adım süreç belirsizliği kullanabilir.)*

---

# 76. Motion-Aware Process Noise (Hareket Farkındalıklı Süreç Gürültüsü)

Walking and running may produce different step-length and heading uncertainty. *(Yürüyüş ve koşma farklı adım uzunluğu ve yön belirsizliği üretebilir.)*

The target EKF may therefore use motion-aware `Q` profiles. *(Bu nedenle hedef EKF hareket farkındalıklı `Q` profilleri kullanabilir.)*

The motion AI will influence process uncertainty only through documented context and will not directly output global position. *(Hareket yapay zekâsı süreç belirsizliğini yalnızca dokümante edilmiş bağlam üzerinden etkileyecek ve doğrudan global konum üretmeyecektir.)*

---

# 77. Stationary Process Noise (Sabit Durum Süreç Gürültüsü)

During confidently stationary periods, step-driven horizontal process noise should not grow as though normal walking steps were occurring. *(Güvenli sabit dönemlerde adım güdümlü yatay süreç gürültüsü normal yürüyüş adımları gerçekleşiyormuş gibi büyümemelidir.)*

Other uncertainty sources may still evolve. *(Diğer belirsizlik kaynakları yine de değişebilir.)*

---

# 78. Heading R Calibration (Yön R Kalibrasyonu)

Heading measurement variance will be calibrated from controlled heading-error experiments. *(Yön ölçüm varyansı kontrollü yön hata deneylerinden kalibre edilecektir.)*

Different heading sources may receive different baseline measurement variances. *(Farklı yön kaynakları farklı temel ölçüm varyansları alabilir.)*

---

# 79. GNSS R Calibration (GNSS R Kalibrasyonu)

GNSS covariance will be evaluated using stationary and walking GNSS recordings. *(GNSS kovaryansı sabit ve yürüyüş GNSS kayıtları kullanılarak değerlendirilecektir.)*

The mapping between reported Android horizontal accuracy and observed ENU residuals will be examined. *(Raporlanan Android yatay doğruluğu ile gözlemlenen ENU residual değerleri arasındaki eşleme incelenecektir.)*

---

# 80. ARCore R Calibration (ARCore R Kalibrasyonu)

ARCore measurement uncertainty will use evidence from stationary drift, straight-line displacement, closed-loop drift, tracking recovery, and alignment experiments. *(ARCore ölçüm belirsizliği sabit sürüklenme, düz çizgi yer değiştirmesi, kapalı döngü sürüklenmesi, takip geri kazanımı ve hizalama deneylerinden elde edilen kanıtı kullanacaktır.)*

---

# 81. Quality-Aware Measurement Noise (Kalite Farkındalıklı Ölçüm Gürültüsü)

The Sensor Confidence & Quality Engine may scale source measurement covariance according to current validated quality. *(Sensör Güven ve Kalite Motoru kaynak ölçüm kovaryansını mevcut doğrulanmış kaliteye göre ölçekleyebilir.)*

`text id="x1gahr" R_effective = qualityMapping( R_base, qualityState, confidence, reasonFlags )`

The mapping will be empirically calibrated. *(Eşleme ampirik olarak kalibre edilecektir.)*

---

# 82. No Direct `1 / Confidence` Rule (Doğrudan `1 / Confidence` Kuralı Olmaması)

NAVGUARD will not assume that covariance is simply the inverse of a confidence score. *(NAVGUARD kovaryansın basitçe güven skorunun tersi olduğunu varsaymayacaktır.)*

Such a relationship requires experimental justification. *(Böyle bir ilişki deneysel gerekçe gerektirir.)*

---

# 83. Degraded Measurement Behavior (Bozulmuş Ölçüm Davranışı)

A `USABLE` or selected `DEGRADED` measurement may remain eligible for fusion with increased covariance. *(Bir `USABLE` veya seçilmiş `DEGRADED` ölçüm artırılmış kovaryansla füzyona uygun kalabilir.)*

An `UNRELIABLE` or `UNAVAILABLE` measurement will normally be excluded. *(Bir `UNRELIABLE` veya `UNAVAILABLE` ölçüm normalde dışlanacaktır.)*

---

# 84. Measurement Source Priority Is Dynamic (Ölçüm Kaynağı Önceliği Dinamiktir)

NAVGUARD will not use one fixed ranking such as GNSS greater than ARCore greater than PDR under every condition. *(NAVGUARD her koşulda GNSS ARCore’dan, ARCore da PDR’den daha iyidir gibi tek sabit sıralama kullanmayacaktır.)*

Effective influence will depend on authorization, quality, uncertainty, and innovation consistency. *(Etkin etki yetkilendirmeye, kaliteye, belirsizliğe ve innovation tutarlılığına bağlı olacaktır.)*

---

# 85. GNSS Mode Behavior (GNSS Modu Davranışı)

In GNSS Mode, validated GNSS measurements may regularly correct horizontal EKF position. *(GNSS Modunda doğrulanmış GNSS ölçümleri yatay EKF konumunu düzenli olarak düzeltebilir.)*

PDR and heading will continue to propagate the state between GNSS updates. *(PDR ve yön GNSS güncellemeleri arasında durumu ilerletmeye devam edecektir.)*

ARCore may additionally contribute when the active experiment profile enables it. *(Aktif deney profili etkinleştirdiğinde ARCore ayrıca katkıda bulunabilir.)*

---

# 86. Evaluation Mode Before Denial (Kesinti Öncesi Değerlendirme Modu)

Before the software denial boundary, Evaluation Mode may operate like GNSS-enabled fusion while separately logging ground truth. *(Yazılım kesinti sınırından önce Değerlendirme Modu ground truth verisini ayrı kaydederken GNSS etkin füzyon gibi çalışabilir.)*

The exact denial transition time will be recorded. *(Kesin kesinti geçiş zamanı kaydedilecektir.)*

---

# 87. GNSS-Denied Transition (GNSS Kesintili Geçiş)

At the denial boundary, estimator GNSS authorization will change to `BLOCKED`. *(Kesinti sınırında tahmin motoru GNSS yetkilendirmesi `BLOCKED` durumuna değişecektir.)*

The EKF state will not be reset. *(EKF durumu sıfırlanmayacaktır.)*

The covariance will not be artificially reduced. *(Kovaryans yapay olarak azaltılmayacaktır.)*

---

# 88. State Capture at Denial Boundary (Kesinti Sınırında Durum Yakalama)

The exact fused state and covariance at GNSS denial will be preserved. *(GNSS kesintisindeki kesin füzyonlu durum ve kovaryans korunacaktır.)*

`text id="6cszvu" x_denial_start P_denial_start t_denial_start`

This provides the starting reference for denied-navigation analysis. *(Bu kesintili navigasyon analizi için başlangıç referansı sağlar.)*

---

# 89. GNSS-Denied EKF Behavior (GNSS Kesintili EKF Davranışı)

During the protected denied interval, the EKF may use PDR, heading, ARCore, motion context, and quality information. *(Korunan kesintili aralık sırasında EKF PDR, yön, ARCore, hareket bağlamı ve kalite bilgisini kullanabilir.)*

GNSS position, speed, bearing, or other GNSS-derived estimator measurements are forbidden during this interval. *(GNSS konumu, hızı, bearing değeri veya diğer GNSS kaynaklı tahmin motoru ölçümleri bu aralık sırasında yasaktır.)*

---

# 90. Ground Truth May Still Be Logged (Ground Truth Kaydı Devam Edebilir)

Physical GNSS may remain active and be logged as independent ground truth during Evaluation Mode. *(Fiziksel GNSS Değerlendirme Modunda bağımsız ground truth olarak aktif kalabilir ve kaydedilebilir.)*

The EKF must remain unaware of those ground-truth coordinates. *(EKF bu ground truth koordinatlarından habersiz kalmalıdır.)*

---

# 91. Denied Covariance Growth (Kesintili Kovaryans Büyümesi)

Without global position corrections, EKF position uncertainty will generally increase as step propagation continues. *(Global konum düzeltmeleri olmadan adım ilerletmesi devam ettikçe EKF konum belirsizliği genel olarak artacaktır.)*

High-quality ARCore measurements may reduce or constrain this growth without restoring GNSS information. *(Yüksek kaliteli ARCore ölçümleri GNSS bilgisini geri getirmeden bu büyümeyi azaltabilir veya sınırlayabilir.)*

---

# 92. No Artificial Confidence Reset (Yapay Güven Sıfırlaması Olmaması)

Entering NAVGUARD Mode must not reset covariance to a small default value. *(NAVGUARD Moduna girmek kovaryansı küçük bir varsayılan değere sıfırlamamalıdır.)*

Such behavior would falsely imply that GNSS loss improves position certainty. *(Böyle bir davranış GNSS kaybının konum kesinliğini iyileştirdiğini yanlış şekilde ima eder.)*

---

# 93. ARCore Loss During Denied Navigation (Kesintili Navigasyonda ARCore Kaybı)

If ARCore tracking is lost during GNSS denial, ARCore EKF updates will stop immediately. *(GNSS kesintisi sırasında ARCore takibi kaybolursa ARCore EKF güncellemeleri hemen duracaktır.)*

PDR and heading propagation will continue when valid. *(PDR ve yön ilerletmesi geçerli olduğunda devam edecektir.)*

Position covariance should generally grow faster without the ARCore correction source. *(ARCore düzeltme kaynağı olmadan konum kovaryansı genel olarak daha hızlı büyümelidir.)*

---

# 94. Magnetometer Disturbance During Denial (Kesinti Sırasında Manyetometre Bozulması)

If magnetic heading becomes unreliable, heading updates will receive increased uncertainty or be rejected according to quality state. *(Manyetik yön güvenilmez hale gelirse yön güncellemeleri kalite durumuna göre artırılmış belirsizlik alacak veya reddedilecektir.)*

Gyroscope-supported heading may continue temporarily while heading covariance grows. *(Jiroskop destekli yön, yön kovaryansı büyürken geçici olarak devam edebilir.)*

---

# 95. Heading Uncertainty Propagates Into Position (Yön Belirsizliği Konuma İlerler)

Because the PDR step Jacobian contains derivatives with respect to heading, increased heading covariance naturally increases East and North covariance during subsequent steps. *(PDR adım Jacobian’ı yöne göre türevler içerdiği için artan yön kovaryansı sonraki adımlar sırasında doğal olarak Doğu ve Kuzey kovaryansını artırır.)*

This is a central reason for keeping heading inside the EKF state. *(Bu yönü EKF durumu içerisinde tutmanın temel nedenlerinden biridir.)*

---

# 96. Step-Length AI Integration (Adım Uzunluğu Yapay Zekâ Entegrasyonu)

If the learned step-length model is enabled, its output will provide `L_k` to the same PDR process interface. *(Öğrenilmiş adım uzunluğu modeli etkinse çıktısı aynı PDR süreç arayüzüne `L_k` sağlayacaktır.)*

The associated step-length uncertainty may differ from the deterministic baseline. *(İlişkili adım uzunluğu belirsizliği deterministik temelden farklı olabilir.)*

---

# 97. Motion Classification Integration (Hareket Sınıflandırma Entegrasyonu)

Motion classification will not directly alter East or North coordinates. *(Hareket sınıflandırması Doğu veya Kuzey koordinatlarını doğrudan değiştirmeyecektir.)*

It may influence step acceptance, step-length selection, process-noise profile, stationary handling, or heading-quality interpretation. *(Adım kabulünü, adım uzunluğu seçimini, süreç gürültüsü profilini, sabit durum yönetimini veya yön kalite yorumunu etkileyebilir.)*

---

# 98. No AI Direct Coordinate Prediction (Yapay Zekâ ile Doğrudan Koordinat Tahmini Olmaması)

The core NAVGUARD architecture will not train a neural network to directly output global latitude and longitude during GNSS denial. *(Temel NAVGUARD mimarisi GNSS kesintisi sırasında doğrudan global enlem ve boylam üreten bir sinir ağı eğitmeyecektir.)*

AI will support physically interpretable navigation components. *(Yapay zekâ fiziksel olarak yorumlanabilir navigasyon bileşenlerini destekleyecektir.)*

---

# 99. GNSS Recovery Request (GNSS Geri Kazanım İsteği)

When the navigation controller requests GNSS recovery, the EKF must remain protected until a validated recovery fix has passed the GNSS recovery policy. *(Navigasyon controller’ı GNSS geri kazanımı istediğinde doğrulanmış bir geri kazanım fix’i GNSS geri kazanım politikasını geçene kadar EKF korunmuş kalmalıdır.)*

The first available GNSS fix will not automatically update the state. *(İlk mevcut GNSS fix’i durumu otomatik olarak güncellemeyecektir.)*

---

# 100. Pre-Correction Recovery State (Düzeltme Öncesi Geri Kazanım Durumu)

Before any recovery measurement modifies the EKF, the denied estimate and covariance must be preserved. *(Herhangi bir geri kazanım ölçümü EKF’yi değiştirmeden önce kesintili tahmin ve kovaryans korunmalıdır.)*

`text id="1dpl7f" x_recovery_pre P_recovery_pre`

---

# 101. Recovery Error Measurement (Geri Kazanım Hata Ölçümü)

The pre-correction EKF position will be compared with the validated recovery GNSS position before fusion. *(Düzeltme öncesi EKF konumu füzyondan önce doğrulanmış geri kazanım GNSS konumuyla karşılaştırılacaktır.)*

`text id="omno7d" e_recovery = √( (E_est - E_GNSS)² + (N_est - N_GNSS)² )`

This value is experimental evidence and must be stored before state correction. *(Bu değer deneysel kanıttır ve durum düzeltmesinden önce saklanmalıdır.)*

---

# 102. Controlled EKF Recovery Update (Kontrollü EKF Geri Kazanım Güncellemesi)

After recovery error is recorded, the validated GNSS measurement may perform a controlled EKF position update. *(Geri kazanım hatası kaydedildikten sonra doğrulanmış GNSS ölçümü kontrollü EKF konum güncellemesi gerçekleştirebilir.)*

The measurement covariance will reflect recovery-fix quality. *(Ölçüm kovaryansı geri kazanım fix kalitesini yansıtacaktır.)*

---

# 103. Re-Anchor Alternative (Yeniden Çapalama Alternatifi)

Direct controlled re-anchoring may remain a fallback if EKF recovery proves unstable or unnecessary for the minimum prototype. *(EKF geri kazanımı kararsız veya minimum prototip için gereksiz çıkarsa doğrudan kontrollü yeniden çapalama geri dönüş olarak kalabilir.)*

Detailed recovery strategy will be finalized in **29 — GNSS Recovery & Relocalization**. *(Ayrıntılı geri kazanım stratejisi **29 — GNSS Recovery & Relocalization** içerisinde kesinleştirilecektir.)*

---

# 104. Historical Trajectory Immutability (Geçmiş Rotanın Değişmezliği)

Recovery updates may modify the current and future EKF state. *(Geri kazanım güncellemeleri mevcut ve gelecekteki EKF durumunu değiştirebilir.)*

They must not retroactively rewrite historical GNSS-denied trajectory points. *(Geçmiş GNSS kesintili rota noktalarını geriye dönük olarak yeniden yazmamalıdır.)*

---

# 105. Filter Reset Policy (Filtre Sıfırlama Politikası)

A normal GNSS denial or ARCore tracking loss must not reset the complete EKF. *(Normal GNSS kesintisi veya ARCore takip kaybı tam EKF’yi sıfırlamamalıdır.)*

A full reset will occur only through controlled session restart, unrecoverable numerical failure, or an explicit relocalization policy that requires reinitialization. *(Tam sıfırlama yalnızca kontrollü oturum yeniden başlatma, geri kazanılamaz sayısal hata veya yeniden başlatma gerektiren açık relocalization politikası üzerinden gerçekleşecektir.)*

---

# 106. EKF Numerical Validation (EKF Sayısal Doğrulaması)

Every prediction and update will verify that state values are finite. *(Her prediction ve update durum değerlerinin sonlu olduğunu doğrulayacaktır.)*

Every covariance update will verify finite matrix elements. *(Her kovaryans güncellemesi sonlu matris elemanlarını doğrulayacaktır.)*

NaN or infinite states must never silently propagate into the navigation trajectory. *(NaN veya sonsuz durumlar navigasyon rotasına hiçbir zaman sessizce ilerlememelidir.)*

---

# 107. Heading Normalization After Prediction (Prediction Sonrası Yön Normalizasyonu)

The heading state will be normalized after every process prediction. *(Yön durumu her süreç prediction işleminden sonra normalize edilecektir.)*

`text id="yefyua" ψ ∈ [0, 2π)`

---

# 108. Heading Normalization After Update (Update Sonrası Yön Normalizasyonu)

The heading state will also be normalized after every measurement update that modifies heading. *(Yön durumu yönü değiştiren her ölçüm update işleminden sonra da normalize edilecektir.)*

This prevents numerical accumulation outside the canonical angle range. *(Bu kanonik açı aralığının dışında sayısal birikimi önler.)*

---

# 109. Matrix Conditioning (Matris Koşulluluğu)

The implementation will monitor innovation covariance for numerical singularity or severe ill-conditioning. *(Uygulama innovation kovaryansını sayısal singularity veya ciddi ill-conditioning açısından izleyecektir.)*

An unstable matrix solve will trigger a diagnostic failure rather than produce an uncontrolled state update. *(Kararsız matris çözümü kontrolsüz durum güncellemesi üretmek yerine tanısal hata tetikleyecektir.)*

---

# 110. EKF Failure Codes (EKF Hata Kodları)

`text id="b4e6uo" EKF_NOT_INITIALIZED EKF_INVALID_STATE EKF_INVALID_COVARIANCE EKF_NON_MONOTONIC_EVENT EKF_PROCESS_MODEL_ERROR EKF_MEASUREMENT_MODEL_ERROR EKF_INNOVATION_SINGULAR EKF_NUMERICAL_FAILURE EKF_MEASUREMENT_REJECTED EKF_CONFIGURATION_ERROR`

---

# 111. Numerical Failure Behavior (Sayısal Hata Davranışı)

A numerical EKF failure must not silently replace the fused position with zeros. *(Sayısal EKF hatası füzyonlu konumu sessizce sıfırlarla değiştirmemelidir.)*

The system may preserve the last valid state, mark fused navigation unavailable, and fall back to the independent PDR trajectory when appropriate. *(Sistem son geçerli durumu koruyabilir, füzyonlu navigasyonu kullanılamaz olarak işaretleyebilir ve uygun olduğunda bağımsız PDR rotasına geri dönebilir.)*

---

# 112. Independent PDR Safety Net (Bağımsız PDR Güvenlik Ağı)

The baseline PDR engine will continue to maintain its own trajectory even when the EKF is active. *(Temel PDR motoru EKF aktifken bile kendi rotasını tutmaya devam edecektir.)*

A fusion implementation error must therefore not destroy the only available local navigation estimate. *(Bu nedenle bir füzyon uygulama hatası mevcut tek yerel navigasyon tahminini yok etmemelidir.)*

---

# 113. Fusion Runtime State (Füzyon Çalışma Zamanı Durumu)

`text id="n9lapk" STOPPED INITIALIZING READY ACTIVE DEGRADED RECOVERING ERROR`

The fusion runtime state is separate from navigation mode and source-quality states. *(Füzyon çalışma zamanı durumu navigasyon modu ve kaynak kalite durumlarından ayrıdır.)*

---

# 114. DEGRADED Fusion State (Bozulmuş Füzyon Durumu)

The fusion engine may remain operational in `DEGRADED` state when optional correction sources are lost. *(İsteğe bağlı düzeltme kaynakları kaybolduğunda füzyon motoru `DEGRADED` durumunda çalışabilir kalabilir.)*

For example, loss of ARCore during GNSS denial may leave PDR and heading as the remaining local sources. *(Örneğin GNSS kesintisi sırasında ARCore kaybı PDR ve yönü kalan yerel kaynaklar olarak bırakabilir.)*

---

# 115. Asynchronous Measurement Example (Asenkron Ölçüm Örneği)

`text id="9ozk8k" t0  Heading Update t1  Step Prediction t2  ARCore Update t3  Heading Update t4  Step Prediction t5  GNSS Update t6  Step Prediction`

The EKF does not require all measurements to occur at the same rate. *(EKF tüm ölçümlerin aynı hızda gerçekleşmesini gerektirmez.)*

---

# 116. Same-Timestamp Event Ordering (Aynı Zaman Damgalı Olay Sıralaması)

When multiple events have effectively the same timestamp, NAVGUARD will use a deterministic processing priority. *(Birden fazla olay etkili olarak aynı zaman damgasına sahip olduğunda NAVGUARD deterministik işlem önceliği kullanacaktır.)*

The initial intended priority is heading update, step propagation, then external position correction. *(İlk amaçlanan öncelik yön güncellemesi, adım ilerletmesi ve ardından harici konum düzeltmesidir.)*

The exact ordering will be frozen in the implementation configuration and replay logic. *(Kesin sıralama uygulama yapılandırması ve replay mantığında sabitlenecektir.)*

---

# 117. Why Heading Precedes Step (Yön Neden Adımdan Önce Gelir)

A step displacement depends directly on heading. *(Bir adım yer değiştirmesi doğrudan yöne bağlıdır.)*

Processing the most relevant validated heading observation first reduces temporal mismatch in the PDR process model. *(En ilgili doğrulanmış yön gözlemini önce işlemek PDR süreç modelindeki zamansal uyuşmazlığı azaltır.)*

---

# 118. External Position Corrections After Step (Adımdan Sonra Harici Konum Düzeltmeleri)

An ARCore or authorized GNSS position update at the same effective time may then correct the propagated state. *(Aynı etkili zamanda bir ARCore veya yetkilendirilmiş GNSS konum güncellemesi daha sonra ilerletilmiş durumu düzeltebilir.)*

This ordering will remain deterministic across live and replay processing. *(Bu sıralama canlı ve replay işleme arasında deterministik kalacaktır.)*

---

# 119. EKF Input Data Model (EKF Girdi Veri Modeli)

`text id="vjkyhq" FusionEvent - eventId - timestampNs - source - eventType - measurement - qualityState - confidence - covariance - reasonFlags - configurationId`

---

# 120. EKF State Output Model (EKF Durum Çıktı Modeli)

`text id="hydw4r" FusedNavigationState - timestampNs - eastM - northM - headingRad - covariance - positionUncertainty - headingUncertainty - activeSources - fusionState`

The detailed user-facing uncertainty representation belongs to **28 — Position Estimation & Uncertainty Engine**. *(Ayrıntılı kullanıcıya yönelik belirsizlik temsili **28 — Position Estimation & Uncertainty Engine** bölümüne aittir.)*

---

# 121. Active Source Tracking (Aktif Kaynak Takibi)

Every fused state snapshot should identify which measurement sources were currently contributing. *(Her füzyonlu durum anlık görüntüsü hangi ölçüm kaynaklarının o anda katkıda bulunduğunu tanımlamalıdır.)*

This allows an analyst to distinguish PDR-only periods from ARCore-corrected or GNSS-corrected periods. *(Bu analiz yapan kişinin yalnızca PDR dönemlerini ARCore düzeltilmiş veya GNSS düzeltilmiş dönemlerden ayırt etmesine olanak sağlar.)*

---

# 122. EKF Prediction Log (EKF Prediction Kaydı)

Formal research sessions may log each PDR prediction event. *(Resmî araştırma oturumları her PDR prediction olayını kaydedebilir.)*

`text id="mv5iie" timestamp_ns, step_id, step_length_m, heading_before_rad, east_before_m, north_before_m, east_after_prediction_m, north_after_prediction_m, q_profile,`

---

# 123. Measurement Update Log (Ölçüm Update Kaydı)

Formal measurement updates may use the following schema. *(Resmî ölçüm update’leri aşağıdaki şemayı kullanabilir.)*

`text id="w28ojm" timestamp_ns, source, measurement_type, innovation, nis, gate_result, r_profile, quality_state, confidence, state_before, state_after`

---

# 124. Covariance Logging (Kovaryans Kaydı)

Selected covariance values will be stored for later uncertainty analysis. *(Seçilen kovaryans değerleri daha sonraki belirsizlik analizi için saklanacaktır.)*

Logging every full matrix at every high-frequency event may be reduced if storage overhead becomes unnecessary. *(Her yüksek frekanslı olayda tüm matrisin kaydı depolama yükü gereksiz hale gelirse azaltılabilir.)*

Formal benchmark logs must still preserve enough information to reproduce filter behavior. *(Resmî benchmark kayıtları filtre davranışını yeniden üretmek için yine de yeterli bilgiyi korumalıdır.)*

---

# 125. EKF Configuration Snapshot (EKF Yapılandırma Anlık Görüntüsü)

`text id="01r68e" ekfVersion stateModel processModelVersion initialCovarianceProfile stepNoiseProfile headingRProfile gnssRProfile arcoreRProfile qualityCovarianceMapping innovationGatePolicy eventOrderingPolicy`

Every formal session will reference the active configuration. *(Her resmî oturum aktif yapılandırmaya referans verecektir.)*

---

# 126. Configuration Freeze (Yapılandırma Sabitleme)

EKF parameters must be frozen when a formal benchmark begins. *(Resmî benchmark başladığında EKF parametreleri sabitlenmelidir.)*

`Q`, `R`, innovation gates, and confidence mappings must not silently adapt using ground-truth position error during the benchmark. *(`Q`, `R`, innovation kapıları ve güven eşlemeleri benchmark sırasında ground truth konum hatasını kullanarak sessizce adapte olmamalıdır.)*

---

# 127. Ground Truth Cannot Tune the Live EKF (Ground Truth Canlı EKF’yi Ayarlayamaz)

Evaluation GNSS may be used after a session to tune future configurations. *(Değerlendirme GNSS’i bir oturumdan sonra gelecekteki yapılandırmaları ayarlamak için kullanılabilir.)*

It cannot be used to choose current `Q`, `R`, or measurement acceptance online during the protected denied interval. *(Korunan kesintili aralık sırasında mevcut `Q`, `R` veya ölçüm kabulünü çevrimiçi seçmek için kullanılamaz.)*

---

# 128. EKF Replay (EKF Replay)

The stored event stream should allow NAVGUARD to rerun EKF fusion offline. *(Saklanan olay akışı NAVGUARD’ın EKF füzyonunu çevrimdışı yeniden çalıştırmasına izin vermelidir.)*

Replay will use the same event ordering, quality configuration, and EKF equations as the live estimator. *(Replay canlı tahmin motoruyla aynı olay sıralamasını, kalite yapılandırmasını ve EKF denklemlerini kullanacaktır.)*

---

# 129. Replay Determinism (Replay Determinizmi)

Identical processed inputs and frozen configuration should produce numerically equivalent EKF trajectories within floating-point tolerance. *(Aynı işlenmiş girdiler ve sabitlenmiş yapılandırma floating-point toleransı içerisinde sayısal olarak eşdeğer EKF rotaları üretmelidir.)*

---

# 130. Replay Ground Truth Isolation (Replay Ground Truth İzolasyonu)

Replay of a GNSS-denied interval must enforce the recorded Ground Truth Firewall events. *(GNSS kesintili bir aralığın replay’i kaydedilmiş Ground Truth Firewall olaylarını uygulamalıdır.)*

The existence of GNSS coordinates in the same session files must not make them available to the replayed estimator. *(Aynı oturum dosyalarında GNSS koordinatlarının bulunması onları replay edilen tahmin motoru için kullanılabilir hale getirmemelidir.)*

---

# 131. EKF Unit Test — Initialization (EKF Birim Testi — Başlatma)

A known valid anchor and heading must initialize the expected state. *(Bilinen geçerli çapa ve yön beklenen durumu başlatmalıdır.)*

`text id="4acwcn" E = 0 N = 0 ψ = ψ_0`

---

# 132. EKF Unit Test — Northward Step (EKF Birim Testi — Kuzeye Adım)

With heading `0°` and known step length `L`, a prediction must increase North by `L` and leave East unchanged within numerical tolerance. *(`0°` yön ve bilinen `L` adım uzunluğuyla prediction Kuzeyi `L` kadar artırmalı ve sayısal tolerans içerisinde Doğuyu değiştirmemelidir.)*

---

# 133. EKF Unit Test — Eastward Step (EKF Birim Testi — Doğuya Adım)

With heading `90°`, a known step must increase East and produce approximately zero North increment. *(`90°` yönde bilinen bir adım Doğuyu artırmalı ve yaklaşık sıfır Kuzey artışı üretmelidir.)*

---

# 134. EKF Unit Test — Heading Wrap (EKF Birim Testi — Yön Wrap)

A heading update crossing `359° → 1°` must generate a small innovation rather than a near-full-circle correction. *(`359° → 1°` sınırını geçen yön update’i neredeyse tam daire düzeltmesi yerine küçük innovation üretmelidir.)*

---

# 135. EKF Unit Test — Heading Covariance Propagation (EKF Birim Testi — Yön Kovaryans İlerlemesi)

Increasing heading variance before a step must increase predicted horizontal position uncertainty. *(Bir adımdan önce yön varyansını artırmak tahmin edilmiş yatay konum belirsizliğini artırmalıdır.)*

This verifies the nonlinear PDR Jacobian. *(Bu doğrusal olmayan PDR Jacobian’ını doğrular.)*

---

# 136. EKF Unit Test — GNSS Position Update (EKF Birim Testi — GNSS Konum Güncellemesi)

A valid authorized GNSS measurement should move the state toward the GNSS observation according to its covariance. *(Geçerli yetkilendirilmiş GNSS ölçümü kovaryansına göre durumu GNSS gözlemine doğru hareket ettirmelidir.)*

A measurement with larger `R_GNSS` should normally produce a weaker correction. *(Daha büyük `R_GNSS` değerine sahip ölçüm normalde daha zayıf düzeltme üretmelidir.)*

---

# 137. EKF Unit Test — GNSS Firewall (EKF Birim Testi — GNSS Firewall)

A valid high-quality GNSS measurement must produce no EKF update when estimator GNSS access is blocked. *(Geçerli yüksek kaliteli GNSS ölçümü tahmin motoru GNSS erişimi engelliyken hiçbir EKF güncellemesi üretmemelidir.)*

This test is mandatory. *(Bu test zorunludur.)*

---

# 138. EKF Unit Test — ARCore Rejection (EKF Birim Testi — ARCore Reddi)

An ARCore measurement from an invalid tracking state must not update position. *(Geçersiz takip durumundan gelen ARCore ölçümü konumu güncellememelidir.)*

---

# 139. EKF Unit Test — Innovation Gate (EKF Birim Testi — Innovation Kapısı)

A synthetic extreme position outlier should exceed the configured innovation gate and be rejected. *(Sentetik aşırı konum outlier’ı yapılandırılmış innovation kapısını aşmalı ve reddedilmelidir.)*

A normal in-family measurement should pass under the same covariance assumptions. *(Normal dağılım içindeki bir ölçüm aynı kovaryans varsayımları altında geçmelidir.)*

---

# 140. EKF Unit Test — Joseph Covariance (EKF Birim Testi — Joseph Kovaryansı)

The posterior covariance should remain symmetric and non-negative on the diagonal within numerical tolerance. *(Posterior kovaryans sayısal tolerans içerisinde simetrik ve köşegende negatif olmayan durumda kalmalıdır.)*

---

# 141. EKF Integration Test — PDR Only (EKF Entegrasyon Testi — Yalnızca PDR)

A known step and heading sequence must produce the same nominal position trajectory as the baseline PDR when no external correction measurements are enabled and equivalent process inputs are used. *(Bilinen bir adım ve yön dizisi hiçbir harici düzeltme ölçümü etkin değilken ve eşdeğer süreç girdileri kullanıldığında temel PDR ile aynı nominal konum rotasını üretmelidir.)*

Covariance will additionally describe uncertainty. *(Kovaryans ayrıca belirsizliği açıklayacaktır.)*

---

# 142. EKF Integration Test — ARCore Correction (EKF Entegrasyon Testi — ARCore Düzeltmesi)

A controlled ARCore measurement should alter the fused state according to the configured covariance without altering the independently stored baseline PDR trajectory. *(Kontrollü ARCore ölçümü bağımsız olarak saklanan temel PDR rotasını değiştirmeden yapılandırılmış kovaryansa göre füzyonlu durumu değiştirmelidir.)*

---

# 143. EKF Integration Test — GNSS Denial (EKF Entegrasyon Testi — GNSS Kesintisi)

The system will begin with GNSS-enabled fusion and then transition to software-denied operation. *(Sistem GNSS etkin füzyonla başlayacak ve daha sonra yazılım kesintili çalışmaya geçecektir.)*

The state must remain continuous across the transition. *(Durum geçiş boyunca sürekli kalmalıdır.)*

GNSS correction count must stop increasing after the firewall boundary. *(GNSS düzeltme sayısı firewall sınırından sonra artmayı durdurmalıdır.)*

---

# 144. EKF Integration Test — Recovery (EKF Entegrasyon Testi — Geri Kazanım)

The recovery test must preserve the pre-correction state and error before any GNSS update is applied. *(Geri kazanım testi herhangi bir GNSS update’i uygulanmadan önce düzeltme öncesi durumu ve hatayı korumalıdır.)*

Historical denied estimates must remain unchanged after recovery. *(Geçmiş kesintili tahminler geri kazanımdan sonra değişmeden kalmalıdır.)*

---

# 145. EKF Physical Test — Straight Route (EKF Fiziksel Testi — Düz Rota)

A controlled straight walking route will compare baseline PDR and fused NAVGUARD position. *(Kontrollü düz yürüyüş rotası temel PDR ile füzyonlu NAVGUARD konumunu karşılaştıracaktır.)*

The comparison will evaluate along-track and cross-track error. *(Karşılaştırma rota doğrultusu ve rota dışı hatayı değerlendirecektir.)*

---

# 146. EKF Physical Test — Turn-Heavy Route (EKF Fiziksel Testi — Dönüş Yoğun Rota)

A turn-heavy route will evaluate heading-position covariance propagation and the benefit of improved heading and ARCore corrections. *(Dönüş yoğun bir rota yön-konum kovaryans ilerlemesini ve geliştirilmiş yön ile ARCore düzeltmelerinin faydasını değerlendirecektir.)*

---

# 147. EKF Physical Test — Closed Loop (EKF Fiziksel Testi — Kapalı Döngü)

A closed or near-closed route will evaluate accumulated fused closure error. *(Kapalı veya yaklaşık kapalı rota birikmiş füzyonlu kapanış hatasını değerlendirecektir.)*

`text id="dlj0yw" ClosureError_fused = √( E_final² + N_final² )`

---

# 148. EKF Physical Test — ARCore Loss (EKF Fiziksel Testi — ARCore Kaybı)

A controlled ARCore tracking-loss interval will verify that fusion continues through PDR and heading without producing a false position jump. *(Kontrollü ARCore takip kaybı aralığı füzyonun yanlış konum sıçraması üretmeden PDR ve yön üzerinden devam ettiğini doğrulayacaktır.)*

---

# 149. EKF Physical Test — Magnetic Disturbance (EKF Fiziksel Testi — Manyetik Bozulma)

A naturally magnetically disturbed environment will evaluate quality-aware heading covariance and position behavior. *(Doğal olarak manyetik bozulmuş bir ortam kalite farkındalıklı yön kovaryansını ve konum davranışını değerlendirecektir.)*

---

# 150. EKF Benchmark Configurations (EKF Benchmark Yapılandırmaları)

Configuration A will preserve the independent PDR-only baseline. *(Yapılandırma A bağımsız yalnızca PDR temelini koruyacaktır.)*

Configuration B will preserve PDR with improved heading. *(Yapılandırma B geliştirilmiş yönle PDR’yi koruyacaktır.)*

Configuration C will evaluate the added value of ARCore relative-motion integration. *(Yapılandırma C ARCore göreli hareket entegrasyonunun ek değerini değerlendirecektir.)*

Configuration D will represent the full validated NAVGUARD fusion stack with AI-assisted motion context and step-length estimation where retained. *(Yapılandırma D korunduğu durumda yapay zekâ destekli hareket bağlamı ve adım uzunluğu tahminiyle tam doğrulanmış NAVGUARD füzyon yığınını temsil edecektir.)*

---

# 151. Baseline Must Remain Visible (Baseline Görünür Kalmalıdır)

The fused trajectory must never overwrite the stored Configuration A PDR trajectory. *(Füzyonlu rota saklanan Yapılandırma A PDR rotasının üzerine hiçbir zaman yazmamalıdır.)*

This ensures that improvement claims can always be reproduced. *(Bu iyileştirme iddialarının her zaman yeniden üretilebilmesini sağlar.)*

---

# 152. EKF Ablation Strategy (EKF Ablation Stratejisi)

Controlled comparisons will add or remove one major information source at a time where practical. *(Kontrollü karşılaştırmalar uygulanabilir olduğunda bir seferde bir ana bilgi kaynağını ekleyecek veya kaldıracaktır.)*

```text id=“wmf5fo”
A:
PDR

B:
PDR + Improved Heading

C:
PDR + Improved Heading + ARCore

D:
Full NAVGUARD
```

---

# 153. EKF Evaluation Metrics (EKF Değerlendirme Metrikleri)

Fusion performance will be evaluated using mean position error. *(Füzyon performansı ortalama konum hatası kullanılarak değerlendirilecektir.)*

Fusion performance will be evaluated using median position error. *(Füzyon performansı medyan konum hatası kullanılarak değerlendirilecektir.)*

Fusion performance will be evaluated using RMSE. *(Füzyon performansı RMSE kullanılarak değerlendirilecektir.)*

Fusion performance will be evaluated using final position error. *(Füzyon performansı nihai konum hatası kullanılarak değerlendirilecektir.)*

Fusion performance will be evaluated using P95 position error. *(Füzyon performansı P95 konum hatası kullanılarak değerlendirilecektir.)*

Fusion performance will be evaluated using drift per minute and drift relative to travelled distance. *(Füzyon performansı dakika başına sürüklenme ve kat edilen mesafeye göre sürüklenme kullanılarak değerlendirilecektir.)*

---

# 154. Primary Research Comparison (Temel Araştırma Karşılaştırması)

The primary system-level comparison will determine whether full NAVGUARD fusion reduces median GNSS-denied position error relative to matched PDR-only sessions. *(Temel sistem seviyesi karşılaştırma tam NAVGUARD füzyonunun eşleştirilmiş yalnızca PDR oturumlarına göre medyan GNSS kesintili konum hatasını azaltıp azaltmadığını belirleyecektir.)*

The previously defined provisional project target is at least a twenty-percent reduction in median position error across matched final sessions. *(Daha önce tanımlanan geçici proje hedefi eşleştirilmiş nihai oturumlar genelinde medyan konum hatasında en az yüzde yirmi azalmadır.)*

This remains a target rather than a fabricated measured result. *(Bu ölçülmüş uydurma bir sonuç yerine hedef olarak kalmaktadır.)*

---

# 155. Filter Consistency Evaluation (Filtre Tutarlılık Değerlendirmesi)

NAVGUARD will not evaluate the EKF only by final trajectory error. *(NAVGUARD EKF’yi yalnızca nihai rota hatasıyla değerlendirmeyecektir.)*

Innovation statistics and covariance behavior will also be examined for signs of overconfidence or underconfidence. *(Innovation istatistikleri ve kovaryans davranışı da aşırı güven veya düşük güven belirtileri açısından incelenecektir.)*

---

# 156. Overconfident Filter (Aşırı Güvenli Filtre)

A filter is suspiciously overconfident when actual error repeatedly becomes much larger than its estimated uncertainty suggests. *(Gerçek hata tekrar tekrar tahmini belirsizliğin ima ettiğinden çok daha büyük hale geldiğinde filtre şüpheli şekilde aşırı güvenlidir.)*

Such behavior may indicate underestimated `Q`, underestimated `R`, ignored measurement correlations, or a poor process model. *(Böyle davranış düşük tahmin edilmiş `Q`, düşük tahmin edilmiş `R`, göz ardı edilmiş ölçüm korelasyonları veya kötü süreç modelini gösterebilir.)*

---

# 157. Underconfident Filter (Düşük Güvenli Filtre)

A filter may be underconfident when covariance remains much larger than observed error across many valid sessions. *(Kovaryans birçok geçerli oturum boyunca gözlemlenen hatadan çok daha büyük kaldığında filtre düşük güvenli olabilir.)*

Such behavior is safer than severe overconfidence but may reduce useful measurement weighting and uncertainty interpretation. *(Böyle davranış ciddi aşırı güvenden daha güvenlidir ancak kullanışlı ölçüm ağırlıklandırmasını ve belirsizlik yorumunu azaltabilir.)*

---

# 158. NIS Analysis (NIS Analizi)

The distribution of NIS values may be compared with the expected measurement degrees of freedom during offline analysis. *(NIS değerlerinin dağılımı çevrimdışı analiz sırasında beklenen ölçüm serbestlik derecesiyle karşılaştırılabilir.)*

This will help identify badly calibrated measurement covariance. *(Bu kötü kalibre edilmiş ölçüm kovaryansını belirlemeye yardımcı olacaktır.)*

---

# 159. Position Uncertainty Validation (Konum Belirsizliği Doğrulaması)

The relationship between EKF covariance and observed GNSS-reference error will be analyzed after formal sessions. *(EKF kovaryansı ile gözlemlenen GNSS referans hatası arasındaki ilişki resmî oturumlardan sonra analiz edilecektir.)*

Detailed uncertainty presentation will be finalized in **28 — Position Estimation & Uncertainty Engine**. *(Ayrıntılı belirsizlik sunumu **28 — Position Estimation & Uncertainty Engine** içerisinde kesinleştirilecektir.)*

---

# 160. Resource Requirements (Kaynak Gereksinimleri)

The minimum three-state EKF is computationally small and should be suitable for continuous smartphone execution. *(Minimum üç durumlu EKF hesaplama açısından küçüktür ve sürekli akıllı telefon çalışması için uygun olmalıdır.)*

Actual latency and resource cost will nevertheless be measured on the Redmi Note 9 Pro. *(Bununla birlikte gerçek gecikme ve kaynak maliyeti Redmi Note 9 Pro üzerinde ölçülecektir.)*

---

# 161. EKF Language Boundary (EKF Dil Sınırı)

The initial implementation may place the platform-independent EKF mathematics in Dart as defined by the mobile architecture. *(İlk uygulama mobil mimaride tanımlandığı şekilde platformdan bağımsız EKF matematiğini Dart içerisinde konumlandırabilir.)*

This decision will remain subject to profiling. *(Bu karar profillemeye tabi kalacaktır.)*

---

# 162. Native Migration Policy (Native’e Taşıma Politikası)

The EKF will not be moved to Kotlin merely because native code is assumed to be faster. *(EKF yalnızca native kodun daha hızlı olduğu varsayıldığı için Kotlin’e taşınmayacaktır.)*

Migration will occur only if measured latency, event throughput, or integration complexity justifies it. *(Taşıma yalnızca ölçülen gecikme, olay throughput’u veya entegrasyon karmaşıklığı gerekçelendirirse gerçekleşecektir.)*

---

# 163. No Cloud Fusion Dependency (Bulut Füzyon Bağımlılığı Olmaması)

Core sensor fusion will run completely on the smartphone. *(Temel sensör füzyonu tamamen akıllı telefon üzerinde çalışacaktır.)*

No cloud API will be required for EKF prediction or measurement updates. *(EKF prediction veya ölçüm update’leri için bulut API’si gerekmeyecektir.)*

---

# 164. Minimum Fusion System (Minimum Füzyon Sistemi)

The minimum fusion implementation must initialize from a valid GNSS anchor and heading. *(Minimum füzyon uygulaması geçerli GNSS çapası ve yönünden başlatılmalıdır.)*

It must propagate position using accepted PDR steps. *(Konumu kabul edilmiş PDR adımları kullanarak ilerletmelidir.)*

It must maintain state covariance. *(Durum kovaryansını tutmalıdır.)*

It must support heading measurement updates. *(Yön ölçüm güncellemelerini desteklemelidir.)*

It must enforce GNSS authorization. *(GNSS yetkilendirmesini uygulamalıdır.)*

---

# 165. Target Fusion System (Hedef Füzyon Sistemi)

The target fusion system will additionally support quality-aware ARCore measurements. *(Hedef füzyon sistemi ayrıca kalite farkındalıklı ARCore ölçümlerini destekleyecektir.)*

It will support quality-aware authorized GNSS updates. *(Kalite farkındalıklı yetkilendirilmiş GNSS güncellemelerini destekleyecektir.)*

It will support innovation gating. *(Innovation gating’i destekleyecektir.)*

It will support empirically calibrated source-specific `Q` and `R`. *(Ampirik olarak kalibre edilmiş kaynağa özgü `Q` ve `R` değerlerini destekleyecektir.)*

---

# 166. Optional Fusion Enhancements (İsteğe Bağlı Füzyon İyileştirmeleri)

Optional enhancements may include velocity states. *(İsteğe bağlı iyileştirmeler hız durumlarını içerebilir.)*

Optional enhancements may include sensor bias states. *(İsteğe bağlı iyileştirmeler sensör bias durumlarını içerebilir.)*

Optional enhancements may include step-length scale estimation. *(İsteğe bağlı iyileştirmeler adım uzunluğu ölçek tahminini içerebilir.)*

Optional enhancements may include relative-state ARCore updates. *(İsteğe bağlı iyileştirmeler göreli durum ARCore güncellemelerini içerebilir.)*

Optional enhancements may include offline smoothing for analysis. *(İsteğe bağlı iyileştirmeler analiz için çevrimdışı smoothing’i içerebilir.)*

---

# 167. Fusion Non-Goals (Füzyon Olmayan Hedefler)

The EKF will not directly process raw camera pixels. *(EKF ham kamera piksellerini doğrudan işlemeyecektir.)*

The EKF will not directly detect pedestrian steps. *(EKF yaya adımlarını doğrudan tespit etmeyecektir.)*

The EKF will not directly perform magnetic disturbance detection. *(EKF manyetik bozulma tespitini doğrudan gerçekleştirmeyecektir.)*

The EKF will not bypass the Ground Truth Firewall. *(EKF Ground Truth Firewall’u atlamayacaktır.)*

The EKF will not claim certified navigation integrity. *(EKF sertifikalı navigasyon bütünlüğü iddia etmeyecektir.)*

---

# 168. Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kararlar)

NAVGUARD will use an Extended Kalman Filter as the target sensor-fusion estimator. *(NAVGUARD hedef sensör füzyon tahmin motoru olarak Genişletilmiş Kalman Filtresi kullanacaktır.)*

The minimum EKF state will be `[E, N, ψ]`. *(Minimum EKF durumu `[E, N, ψ]` olacaktır.)*

PDR step propagation will be the minimum horizontal process model. *(PDR adım ilerletmesi minimum yatay süreç modeli olacaktır.)*

The step process will use `ΔE = L sinψ` and `ΔN = L cosψ`. *(Adım süreci `ΔE = L sinψ` ve `ΔN = L cosψ` kullanacaktır.)*

---

# 169. Additional Frozen Decisions (Ek Sabitlenmiş Kararlar)

Heading will remain an explicit EKF state because its uncertainty directly affects position propagation. *(Yön, belirsizliği konum ilerletmesini doğrudan etkilediği için açık EKF durumu olarak kalacaktır.)*

Heading measurement innovation will use circular mathematics. *(Yön ölçüm innovation’ı dairesel matematik kullanacaktır.)*

Covariance prediction will use the nonlinear PDR Jacobian. *(Kovaryans prediction’ı doğrusal olmayan PDR Jacobian’ını kullanacaktır.)*

Joseph-form covariance correction will be preferred. *(Joseph biçimli kovaryans düzeltmesi tercih edilecektir.)*

---

# 170. Measurement Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Ölçüm Kararları)

Authorized GNSS will enter as ENU horizontal position measurements. *(Yetkilendirilmiş GNSS ENU yatay konum ölçümleri olarak girecektir.)*

ARCore will enter only after valid tracking, timestamp, quality, segment, and ENU-alignment checks. *(ARCore yalnızca geçerli takip, zaman damgası, kalite, segment ve ENU hizalama kontrollerinden sonra girecektir.)*

The initial ARCore fusion candidate will use segment-relative ENU pseudo-position with conservative covariance. *(İlk ARCore füzyon adayı temkinli kovaryansla segment göreli ENU pseudo-konumu kullanacaktır.)*

---

# 171. Quality Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kalite Kararları)

Invalid measurements will be rejected before EKF updates. *(Geçersiz ölçümler EKF update’lerinden önce reddedilecektir.)*

Usable degraded measurements may receive increased `R`. *(Kullanılabilir bozulmuş ölçümler artırılmış `R` alabilir.)*

The final confidence-to-covariance mapping will require empirical calibration. *(Nihai güven-kovaryans eşlemesi ampirik kalibrasyon gerektirecektir.)*

Innovation gating will provide an additional consistency check after source-quality validation. *(Innovation gating kaynak kalite doğrulamasından sonra ek bir tutarlılık kontrolü sağlayacaktır.)*

---

# 172. GNSS-Denied Decisions Frozen by This Document (Bu Dokümanla Sabitlenen GNSS Kesintili Kararlar)

GNSS denial will not reset the EKF state. *(GNSS kesintisi EKF durumunu sıfırlamayacaktır.)*

GNSS denial will not reduce covariance artificially. *(GNSS kesintisi kovaryansı yapay olarak azaltmayacaktır.)*

GNSS measurements will not reach EKF update logic while the Ground Truth Firewall is blocked. *(Ground Truth Firewall engelliyken GNSS ölçümleri EKF update mantığına ulaşmayacaktır.)*

Ground-truth GNSS may continue logging independently. *(Ground truth GNSS bağımsız olarak kaydedilmeye devam edebilir.)*

---

# 173. Recovery Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Geri Kazanım Kararları)

The pre-correction denied state will be preserved before GNSS recovery. *(Düzeltme öncesi kesintili durum GNSS geri kazanımından önce korunacaktır.)*

Recovery error will be calculated before correction. *(Geri kazanım hatası düzeltmeden önce hesaplanacaktır.)*

Historical denied trajectories will remain immutable. *(Geçmiş kesintili rotalar değişmez kalacaktır.)*

Controlled EKF correction or controlled re-anchoring may then occur according to the final recovery strategy. *(Daha sonra nihai geri kazanım stratejisine göre kontrollü EKF düzeltmesi veya kontrollü yeniden çapalama gerçekleşebilir.)*

---

# 174. Decisions Pending Measurement (Ölçüm Bekleyen Kararlar)

The final initial covariance `P_0` remains pending device measurements. *(Nihai başlangıç kovaryansı `P_0` cihaz ölçümlerini beklemektedir.)*

The final step-length process noise remains pending step-length experiments. *(Nihai adım uzunluğu süreç gürültüsü adım uzunluğu deneylerini beklemektedir.)*

The final heading process and measurement noise remain pending heading experiments. *(Nihai yön süreç ve ölçüm gürültüsü yön deneylerini beklemektedir.)*

The final GNSS covariance mapping remains pending GNSS field analysis. *(Nihai GNSS kovaryans eşlemesi GNSS saha analizini beklemektedir.)*

---

# 175. Additional Pending Decisions (Ek Bekleyen Kararlar)

The final ARCore covariance model remains pending ARCore experiments. *(Nihai ARCore kovaryans modeli ARCore deneylerini beklemektedir.)*

The final innovation-gate confidence level remains pending development-data analysis. *(Nihai innovation kapısı güven seviyesi geliştirme verisi analizini beklemektedir.)*

The final quality-to-covariance mapping remains pending calibration. *(Nihai kalite-kovaryans eşlemesi kalibrasyonu beklemektedir.)*

The final decision on velocity-state augmentation remains pending profiling and experimental benefit. *(Hız durumu genişletmesi hakkındaki nihai karar profillemeyi ve deneysel faydayı beklemektedir.)*

---

# 176. Core Acceptance Criteria (Temel Kabul Kriterleri)

The EKF must initialize from a validated GNSS anchor and heading. *(EKF doğrulanmış GNSS çapası ve yönünden başlatılmalıdır.)*

A valid step must propagate East and North according to the defined nonlinear process model. *(Geçerli bir adım Doğu ve Kuzeyi tanımlanan doğrusal olmayan süreç modeline göre ilerletmelidir.)*

Heading uncertainty must propagate into horizontal covariance. *(Yön belirsizliği yatay kovaryansa ilerlemelidir.)*

All state and covariance outputs must remain finite. *(Tüm durum ve kovaryans çıktıları sonlu kalmalıdır.)*

---

# 177. Measurement Acceptance Criteria (Ölçüm Kabul Kriterleri)

Heading measurements must use circular innovation. *(Yön ölçümleri dairesel innovation kullanmalıdır.)*

Unauthorized GNSS must never update the EKF. *(Yetkisiz GNSS EKF’yi hiçbir zaman güncellememelidir.)*

Invalid ARCore measurements must never update the EKF. *(Geçersiz ARCore ölçümleri EKF’yi hiçbir zaman güncellememelidir.)*

Innovation-rejected measurements must leave the nominal state uncorrected by that measurement. *(Innovation nedeniyle reddedilen ölçümler nominal durumu o ölçüm tarafından düzeltilmemiş bırakmalıdır.)*

---

# 178. Covariance Acceptance Criteria (Kovaryans Kabul Kriterleri)

The covariance matrix must remain symmetric within numerical tolerance. *(Kovaryans matrisi sayısal tolerans içerisinde simetrik kalmalıdır.)*

Diagonal variances must remain non-negative within numerical tolerance. *(Köşegen varyansları sayısal tolerans içerisinde negatif olmayan durumda kalmalıdır.)*

GNSS denial must not artificially shrink covariance. *(GNSS kesintisi kovaryansı yapay olarak küçültmemelidir.)*

Loss of correction sources should be reflected by increasing or less-constrained uncertainty. *(Düzeltme kaynaklarının kaybı artan veya daha az sınırlanmış belirsizlikle yansıtılmalıdır.)*

---

# 179. Experimental Acceptance Criteria (Deneysel Kabul Kriterleri)

The fused trajectory must be quantitatively compared against the independent PDR baseline. *(Füzyonlu rota bağımsız PDR temeliyle nicel olarak karşılaştırılmalıdır.)*

Configuration C must determine whether ARCore provides measurable benefit over the corresponding non-ARCore configuration. *(Yapılandırma C ARCore’un karşılık gelen ARCore’suz yapılandırmaya göre ölçülebilir fayda sağlayıp sağlamadığını belirlemelidir.)*

Configuration D must determine whether the complete validated fusion stack reduces GNSS-denied drift relative to Configuration A. *(Yapılandırma D tam doğrulanmış füzyon yığınının Yapılandırma A’ya göre GNSS kesintili sürüklenmeyi azaltıp azaltmadığını belirlemelidir.)*

---

# 180. Experiment Integrity Acceptance Criteria (Deney Bütünlüğü Kabul Kriterleri)

The denied EKF must receive zero unauthorized GNSS measurement updates. *(Kesintili EKF sıfır yetkisiz GNSS ölçüm update’i almalıdır.)*

Ground truth may be used only after the live estimate is produced for evaluation purposes. *(Ground truth yalnızca canlı tahmin üretildikten sonra değerlendirme amacıyla kullanılabilir.)*

Final benchmark `Q`, `R`, gates, and mappings must be frozen before final results are examined. *(Nihai benchmark `Q`, `R`, kapı ve eşleme değerleri nihai sonuçlar incelenmeden önce sabitlenmelidir.)*

---

# 181. Final Sensor Fusion Architecture Statement (Nihai Sensör Füzyon Mimarisi Bildirimi)

**NAVGUARD will use a compact Extended Kalman Filter with the initial state `[E, N, ψ]` to combine step-based dead reckoning, true-north heading observations, validated ARCore relative motion, and authorized GNSS position measurements.** *(NAVGUARD adım tabanlı dead reckoning’i, gerçek kuzey yön gözlemlerini, doğrulanmış ARCore göreli hareketini ve yetkilendirilmiş GNSS konum ölçümlerini birleştirmek için başlangıç durumu `[E, N, ψ]` olan kompakt bir Genişletilmiş Kalman Filtresi kullanacaktır.)*

**PDR step propagation will form the minimum nonlinear process model, causing both position and covariance to evolve according to step length and heading uncertainty.** *(PDR adım ilerletmesi minimum doğrusal olmayan süreç modelini oluşturacak ve hem konumun hem de kovaryansın adım uzunluğu ile yön belirsizliğine göre gelişmesine neden olacaktır.)*

**Heading, GNSS, and ARCore will enter through separate measurement models with independent quality gates and empirically calibrated measurement uncertainty.** *(Yön, GNSS ve ARCore bağımsız kalite kapıları ve ampirik olarak kalibre edilmiş ölçüm belirsizliğiyle ayrı ölçüm modelleri üzerinden girecektir.)*

**The estimator will process asynchronous timestamped events without forcing all sources into one artificial sampling rate, and it will preserve deterministic processing order for live and replay execution.** *(Tahmin motoru tüm kaynakları tek yapay örnekleme hızına zorlamadan asenkron zaman damgalı olayları işleyecek ve canlı ile replay çalışması için deterministik işlem sırasını koruyacaktır.)*

**During GNSS-denied Evaluation Mode, the Ground Truth Firewall will prevent every GNSS-derived estimator measurement from entering the EKF while independent physical GNSS logging may continue solely for later evaluation.** *(GNSS kesintili Değerlendirme Modu sırasında Ground Truth Firewall, yalnızca daha sonraki değerlendirme için bağımsız fiziksel GNSS kaydı devam edebilirken GNSS kaynaklı her tahmin motoru ölçümünün EKF’ye girmesini engelleyecektir.)*

**Measurement quality will influence acceptance and uncertainty, but invalid data will be rejected before fusion and no high-confidence score will be allowed to bypass an explicit authorization or validity rule.** *(Ölçüm kalitesi kabulü ve belirsizliği etkileyecek ancak geçersiz veri füzyondan önce reddedilecek ve hiçbir yüksek güven skoru açık bir yetkilendirme veya geçerlilik kuralını aşamayacaktır.)*

**GNSS recovery will preserve the complete pre-correction EKF state and recovery error before any controlled EKF correction or relocalization takes place.** *(GNSS geri kazanımı herhangi bir kontrollü EKF düzeltmesi veya yeniden konumlandırma gerçekleşmeden önce tam düzeltme öncesi EKF durumunu ve geri kazanım hatasını koruyacaktır.)*

**The independent baseline PDR trajectory will remain available throughout the project so that fusion improvement can be quantitatively demonstrated rather than inferred from visual appearance.** *(Bağımsız temel PDR rotası proje boyunca kullanılabilir kalacak; böylece füzyon iyileştirmesi görsel görünümden çıkarılmak yerine nicel olarak gösterilebilecektir.)*

---

# 182. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development Sensor Fusion & EKF Architecture Completed *(Doküman Durumu: Geliştirme Öncesi Sensör Füzyonu ve EKF Mimarisi Tamamlandı)*

**Target Fusion Method:** Extended Kalman Filter *(Hedef Füzyon Yöntemi: Genişletilmiş Kalman Filtresi)*

**Initial EKF State:** `[E, N, ψ]` *(Başlangıç EKF Durumu: `[E, N, ψ]`)*

**Optional Extended State:** `[E, N, vE, vN, ψ]` Pending Experimental Benefit *(İsteğe Bağlı Genişletilmiş Durum: `[E, N, vE, vN, ψ]` Deneysel Fayda Bekleniyor)*

**Primary Process Model:** Step-Based PDR *(Temel Süreç Modeli: Adım Tabanlı PDR)*

**Nonlinear Process:** `ΔE = L sinψ`, `ΔN = L cosψ` *(Doğrusal Olmayan Süreç: `ΔE = L sinψ`, `ΔN = L cosψ`)*

**Heading Measurement:** True-North Circular Update *(Yön Ölçümü: Gerçek Kuzey Dairesel Güncelleme)*

**GNSS Measurement:** Authorized ENU Position Only *(GNSS Ölçümü: Yalnızca Yetkilendirilmiş ENU Konumu)*

**ARCore Measurement:** Validated ENU Segment-Relative Position Candidate *(ARCore Ölçümü: Doğrulanmış ENU Segment Göreli Konum Adayı)*

**Process Covariance:** `Q` from Step and Heading Uncertainty *(Süreç Kovaryansı: Adım ve Yön Belirsizliğinden `Q`)*

**Measurement Covariance:** Source-Specific `R` *(Ölçüm Kovaryansı: Kaynağa Özgü `R`)*

**State Covariance:** `P` *(Durum Kovaryansı: `P`)*

**Measurement Consistency:** Innovation / NIS Gating *(Ölçüm Tutarlılığı: Innovation / NIS Gating)*

**Covariance Update:** Joseph Form Preferred *(Kovaryans Güncellemesi: Joseph Formu Tercih Edilir)*

**Event Model:** Asynchronous and Timestamp-Ordered *(Olay Modeli: Asenkron ve Zaman Damgası Sıralı)*

**GNSS-Denied Policy:** Ground Truth Firewall Blocks All GNSS EKF Updates *(GNSS Kesintili Politikası: Ground Truth Firewall Tüm GNSS EKF Güncellemelerini Engeller)*

**ARCore Loss Policy:** Stop ARCore Updates, Continue PDR *(ARCore Kayıp Politikası: ARCore Güncellemelerini Durdur, PDR’ye Devam Et)*

**Recovery Policy:** Preserve Error Before Correction *(Geri Kazanım Politikası: Düzeltmeden Önce Hatayı Koru)*

**Historical Trajectory:** Immutable After Recovery *(Geçmiş Rota: Geri Kazanımdan Sonra Değişmez)*

**Final `P_0`:** Pending Device Calibration *(Nihai `P_0`: Cihaz Kalibrasyonu Bekleniyor)*

**Final `Q`:** Pending PDR and Heading Experiments *(Nihai `Q`: PDR ve Yön Deneyleri Bekleniyor)*

**Final `R_GNSS`:** Pending GNSS Field Analysis *(Nihai `R_GNSS`: GNSS Saha Analizi Bekleniyor)*

**Final `R_ARCore`:** Pending ARCore Experiments *(Nihai `R_ARCore`: ARCore Deneyleri Bekleniyor)*

**Final `R_Heading`:** Pending Heading Experiments *(Nihai `R_Heading`: Yön Deneyleri Bekleniyor)*

**Final NIS Threshold:** Pending Development Calibration *(Nihai NIS Eşiği: Geliştirme Kalibrasyonu Bekleniyor)*

**Final Quality-to-Covariance Mapping:** Pending Experimental Calibration *(Nihai Kalite-Kovaryans Eşlemesi: Deneysel Kalibrasyon Bekleniyor)*

**Next Documentation Item:** 22 — Artificial Intelligence System *(Sonraki Dokümantasyon Öğesi: 22 — Yapay Zekâ Sistemi)*