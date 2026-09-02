# 20 — Sensor Confidence & Quality Engine (Sensör Güven ve Kalite Motoru)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the architecture, quality dimensions, confidence representation, freshness monitoring, timing-quality assessment, plausibility checks, degradation detection, confidence decay, recovery behavior, sensor rejection, fallback logic, fusion integration, logging, calibration, evaluation, and acceptance criteria of the NAVGUARD Sensor Confidence & Quality Engine. *(Bu doküman, NAVGUARD Sensör Güven ve Kalite Motorunun mimarisini, kalite boyutlarını, güven temsilini, güncellik izlemeyi, zamanlama kalite değerlendirmesini, makullük kontrollerini, bozulma tespitini, güven azalmasını, geri kazanım davranışını, sensör reddini, geri dönüş mantığını, füzyon entegrasyonunu, kaydı, kalibrasyonu, değerlendirmeyi ve kabul kriterlerini tanımlar.)*

The engine will provide a common quality layer between raw or processed navigation sources and the sensor-fusion system. *(Motor, ham veya işlenmiş navigasyon kaynakları ile sensör füzyon sistemi arasında ortak bir kalite katmanı sağlayacaktır.)*

The engine will not replace the individual validation logic already defined inside the GNSS, heading, PDR, and ARCore subsystems. *(Motor, GNSS, yön, PDR ve ARCore alt sistemleri içerisinde zaten tanımlanmış bireysel doğrulama mantığının yerini almayacaktır.)*

---

# 2. Primary Objective (Temel Hedef)

The primary objective is to prevent NAVGUARD from treating every available measurement as equally trustworthy. *(Temel hedef NAVGUARD’ın mevcut her ölçümü eşit derecede güvenilir olarak ele almasını önlemektir.)*

Different sensors fail in different ways and under different environmental conditions. *(Farklı sensörler farklı şekillerde ve farklı çevresel koşullar altında hata verir.)*

The quality engine will convert observable evidence about each source into explicit quality metadata that can be used by navigation logic. *(Kalite motoru her kaynak hakkındaki gözlemlenebilir kanıtı navigasyon mantığı tarafından kullanılabilecek açık kalite metadata bilgisine dönüştürecektir.)*

---

# 3. Why a Common Quality Layer Is Required (Ortak Kalite Katmanı Neden Gereklidir)

GNSS may become stale or inaccurate. *(GNSS eski veya hatalı hale gelebilir.)*

Magnetometer measurements may become magnetically disturbed. *(Manyetometre ölçümleri manyetik olarak bozulabilir.)*

Gyroscope-only orientation may drift over time. *(Yalnızca jiroskopa dayalı yönelim zaman içerisinde sürüklenebilir.)*

ARCore may lose visual tracking. *(ARCore görsel takibi kaybedebilir.)*

Step detection may become unreliable because of unusual motion. *(Adım tespiti olağan dışı hareket nedeniyle güvenilmez hale gelebilir.)*

A fusion system that ignores these differences can become less accurate than the individual sources it is trying to combine. *(Bu farkları göz ardı eden bir füzyon sistemi birleştirmeye çalıştığı bireysel kaynaklardan daha az doğru hale gelebilir.)*

---

# 4. Quality Engine Position in the Architecture (Kalite Motorunun Mimarideki Konumu)

`text id="83gv1a" Sensors / Navigation Sources (Sensörler / Navigasyon Kaynakları)         ↓ Subsystem-Specific Validation (Alt Sisteme Özgü Doğrulama)         ↓ Sensor Confidence & Quality Engine (Sensör Güven ve Kalite Motoru)         ↓ Quality Metadata (Kalite Metadata Bilgisi)         ↓ Fusion / Navigation Decision (Füzyon / Navigasyon Kararı)`

The quality engine will consume both physical sensor evidence and subsystem-derived diagnostic information. *(Kalite motoru hem fiziksel sensör kanıtını hem de alt sistem tarafından türetilmiş tanısal bilgiyi kullanacaktır.)*

---

# 5. Quality Is Not the Same as Availability (Kalite Kullanılabilirlikle Aynı Değildir)

A sensor may be available but unreliable. *(Bir sensör mevcut ancak güvenilmez olabilir.)*

A sensor may also be temporarily unavailable while the rest of NAVGUARD remains functional. *(Bir sensör geçici olarak kullanılamazken NAVGUARD’ın geri kalanı çalışabilir durumda kalabilir.)*

Availability and quality will therefore be represented separately. *(Bu nedenle kullanılabilirlik ve kalite ayrı temsil edilecektir.)*

---

# 6. Quality Is Not the Same as Accuracy (Kalite Doğrulukla Aynı Değildir)

Quality is a broader concept than numerical accuracy. *(Kalite sayısal doğruluktan daha geniş bir kavramdır.)*

A measurement may have good timing and continuity but still contain bias. *(Bir ölçüm iyi zamanlama ve sürekliliğe sahipken yine de bias içerebilir.)*

Another measurement may be physically accurate but too stale to use for the current navigation update. *(Başka bir ölçüm fiziksel olarak doğru olabilir ancak mevcut navigasyon güncellemesi için fazla eski olabilir.)*

---

# 7. Quality Dimensions (Kalite Boyutları)

NAVGUARD will evaluate several independent quality dimensions where relevant. *(NAVGUARD ilgili olduğunda birkaç bağımsız kalite boyutunu değerlendirecektir.)*

The initial quality dimensions are availability, freshness, timing quality, signal plausibility, continuity, environmental reliability, internal consistency, and cross-sensor consistency. *(İlk kalite boyutları kullanılabilirlik, güncellik, zamanlama kalitesi, sinyal makullüğü, süreklilik, çevresel güvenilirlik, iç tutarlılık ve sensörler arası tutarlılıktır.)*

---

# 8. Availability Quality (Kullanılabilirlik Kalitesi)

Availability indicates whether a required measurement source is currently able to produce valid observations. *(Kullanılabilirlik gerekli bir ölçüm kaynağının şu anda geçerli gözlemler üretip üretemediğini gösterir.)*

`text id="uh4hll" AVAILABLE TEMPORARILY_UNAVAILABLE UNAVAILABLE`

A temporarily unavailable source may recover without restarting the full navigation session. *(Geçici olarak kullanılamayan bir kaynak tam navigasyon oturumunu yeniden başlatmadan geri kazanılabilir.)*

---

# 9. Freshness Quality (Güncellik Kalitesi)

Freshness describes how old a measurement is relative to the navigation event that wants to consume it. *(Güncellik bir ölçümün onu kullanmak isteyen navigasyon olayına göre ne kadar eski olduğunu açıklar.)*

`text id="d2i18u" age = t_current - t_measurement`

Freshness thresholds will be source-specific because GNSS, IMU, heading, and ARCore operate at different update rates. *(Güncellik eşikleri kaynağa özgü olacaktır çünkü GNSS, IMU, yön ve ARCore farklı güncelleme hızlarında çalışır.)*

---

# 10. Timing Quality (Zamanlama Kalitesi)

Timing quality describes whether measurement timestamps are monotonic, sufficiently continuous, and compatible with the expected source behavior. *(Zamanlama kalitesi ölçüm zaman damgalarının monotonik, yeterince sürekli ve beklenen kaynak davranışıyla uyumlu olup olmadığını açıklar.)*

Timing gaps, duplicated timestamps, non-monotonic timestamps, and excessive jitter may reduce quality. *(Zamanlama boşlukları, yinelenen zaman damgaları, monotonik olmayan zaman damgaları ve aşırı jitter kaliteyi düşürebilir.)*

---

# 11. Signal Plausibility (Sinyal Makullüğü)

Signal plausibility checks whether a measurement is numerically and physically reasonable. *(Sinyal makullüğü bir ölçümün sayısal ve fiziksel olarak makul olup olmadığını kontrol eder.)*

NaN, infinite values, impossible ranges, implausible jumps, or invalid vector norms will cause rejection or degradation. *(NaN, sonsuz değerler, imkânsız aralıklar, fiziksel olarak mantıksız sıçramalar veya geçersiz vektör normları red veya bozulmaya neden olacaktır.)*

---

# 12. Continuity Quality (Süreklilik Kalitesi)

Continuity describes how smoothly a measurement source behaves over time relative to its expected dynamics. *(Süreklilik bir ölçüm kaynağının beklenen dinamiklerine göre zaman içerisinde ne kadar düzgün davrandığını açıklar.)*

Sudden unexplained position, heading, or field jumps may indicate a low-quality observation. *(Ani ve açıklanamayan konum, yön veya alan sıçramaları düşük kaliteli gözlemi gösterebilir.)*

---

# 13. Environmental Reliability (Çevresel Güvenilirlik)

Some sources depend strongly on the surrounding environment. *(Bazı kaynaklar çevredeki ortama güçlü şekilde bağlıdır.)*

Magnetometer quality depends on the local magnetic environment. *(Manyetometre kalitesi yerel manyetik ortama bağlıdır.)*

ARCore quality depends on visual features, lighting, camera access, and motion conditions. *(ARCore kalitesi görsel özelliklere, ışığa, kamera erişimine ve hareket koşullarına bağlıdır.)*

GNSS quality depends on satellite visibility and propagation conditions. *(GNSS kalitesi uydu görünürlüğüne ve sinyal yayılım koşullarına bağlıdır.)*

---

# 14. Internal Consistency (İç Tutarlılık)

Internal consistency checks whether a source behaves consistently with its own recent history. *(İç tutarlılık bir kaynağın kendi yakın geçmişiyle tutarlı davranıp davranmadığını kontrol eder.)*

For example, an isolated ARCore translation jump may be suspicious even when ARCore still reports `TRACKING`. *(Örneğin izole bir ARCore öteleme sıçraması ARCore hâlâ `TRACKING` raporlasa bile şüpheli olabilir.)*

---

# 15. Cross-Sensor Consistency (Sensörler Arası Tutarlılık)

Cross-sensor consistency compares independent or partially independent sources when such comparison is meaningful. *(Sensörler arası tutarlılık anlamlı olduğunda bağımsız veya kısmen bağımsız kaynakları karşılaştırır.)*

For example, a large magnetic heading change while the gyroscope reports almost no rotation may indicate magnetic disturbance. *(Örneğin jiroskop neredeyse hiç dönüş raporlamazken büyük bir manyetik yön değişimi manyetik bozulmayı gösterebilir.)*

---

# 16. Quality State Model (Kalite Durum Modeli)

NAVGUARD will use a common categorical quality representation. *(NAVGUARD ortak bir kategorik kalite temsili kullanacaktır.)*

`text id="w1rcu1" UNKNOWN GOOD USABLE DEGRADED UNRELIABLE UNAVAILABLE`

Individual subsystems may expose more specific states while mapping them into this common model. *(Bireysel alt sistemler bu ortak modele eşlerken daha özel durumlar sunabilir.)*

---

# 17. Meaning of GOOD (GOOD Anlamı)

`GOOD` means that the source is currently available and no important quality problem is detected. *(`GOOD`, kaynağın şu anda kullanılabilir olduğu ve önemli bir kalite problemi tespit edilmediği anlamına gelir.)*

`GOOD` does not mean perfect accuracy. *(`GOOD`, kusursuz doğruluk anlamına gelmez.)*

---

# 18. Meaning of USABLE (USABLE Anlamı)

`USABLE` means that the source can still contribute to navigation but has some limitation or reduced certainty. *(`USABLE`, kaynağın navigasyona hâlâ katkıda bulunabileceği ancak bazı sınırlamalara veya azalmış kesinliğe sahip olduğu anlamına gelir.)*

Fusion may assign lower influence to a `USABLE` measurement than to a `GOOD` measurement. *(Füzyon bir `USABLE` ölçüme `GOOD` ölçüme göre daha düşük etki atayabilir.)*

---

# 19. Meaning of DEGRADED (DEGRADED Anlamı)

`DEGRADED` means that meaningful quality problems exist and the source should be used only with strong caution or increased uncertainty. *(`DEGRADED`, anlamlı kalite problemlerinin mevcut olduğu ve kaynağın yalnızca yüksek dikkat veya artırılmış belirsizlikle kullanılması gerektiği anlamına gelir.)*

Some degraded measurements may still be useful when no stronger source is available. *(Bazı bozulmuş ölçümler daha güçlü bir kaynak bulunmadığında yine de kullanışlı olabilir.)*

---

# 20. Meaning of UNRELIABLE (UNRELIABLE Anlamı)

`UNRELIABLE` means that the measurement source is producing data but the current evidence indicates that it should not influence normal navigation updates. *(`UNRELIABLE`, ölçüm kaynağının veri ürettiği ancak mevcut kanıtın normal navigasyon güncellemelerini etkilememesi gerektiğini gösterdiği anlamına gelir.)*

The data may still be logged for diagnosis. *(Veri yine de tanı için kaydedilebilir.)*

---

# 21. Meaning of UNAVAILABLE (UNAVAILABLE Anlamı)

`UNAVAILABLE` means that no valid current measurement can be supplied by the source. *(`UNAVAILABLE`, kaynak tarafından geçerli güncel ölçüm sağlanamadığı anlamına gelir.)*

Unavailable data will never be replaced by a fabricated numerical value. *(Kullanılamayan veri hiçbir zaman uydurulmuş sayısal bir değerle değiştirilmeyecektir.)*

---

# 22. Confidence Score (Güven Skoru)

The target quality engine may additionally expose a normalized relative confidence score. *(Hedef kalite motoru ayrıca normalize edilmiş göreli bir güven skoru sunabilir.)*

`text id="6htzta" c ∈ [0, 1]`

A value near one represents stronger relative trust, while a value near zero represents very weak trust. *(Bire yakın bir değer daha güçlü göreli güveni, sıfıra yakın bir değer ise çok zayıf güveni temsil eder.)*

---

# 23. Confidence Is Not Probability (Güven Olasılık Değildir)

The confidence score will not be described as the probability that a measurement is correct unless explicit statistical calibration supports that interpretation. *(Güven skoru açık istatistiksel kalibrasyon bu yorumu desteklemediği sürece bir ölçümün doğru olma olasılığı olarak açıklanmayacaktır.)*

The initial implementation may use confidence only as a relative weighting or diagnostic quantity. *(İlk uygulama güveni yalnızca göreli ağırlıklandırma veya tanısal büyüklük olarak kullanabilir.)*

---

# 24. Quality State and Confidence Are Related but Separate (Kalite Durumu ve Güven İlişkili Ancak Ayrıdır)

The categorical quality state will support deterministic safety decisions. *(Kategorik kalite durumu deterministik güvenlik kararlarını destekleyecektir.)*

The continuous confidence score may support smoother fusion weighting. *(Sürekli güven skoru daha yumuşak füzyon ağırlıklandırmasını destekleyebilir.)*

A source may therefore have `USABLE` quality with a moderate confidence value. *(Bu nedenle bir kaynak orta güven değeriyle `USABLE` kaliteye sahip olabilir.)*

---

# 25. Hard Rejection Versus Soft Degradation (Sert Red ile Yumuşak Bozulma)

Some quality failures will require hard measurement rejection. *(Bazı kalite hataları sert ölçüm reddi gerektirecektir.)*

Other failures will only increase uncertainty or reduce confidence. *(Diğer hatalar yalnızca belirsizliği artıracak veya güveni azaltacaktır.)*

NAVGUARD will distinguish these two behaviors explicitly. *(NAVGUARD bu iki davranışı açıkça ayırt edecektir.)*

---

# 26. Hard-Rejection Examples (Sert Red Örnekleri)

A measurement containing NaN or infinite values will be rejected. *(NaN veya sonsuz değer içeren bir ölçüm reddedilecektir.)*

A non-monotonic timestamp that violates the active stream contract may be rejected. *(Aktif akış sözleşmesini ihlal eden monotonik olmayan zaman damgası reddedilebilir.)*

An ARCore pose while tracking is `PAUSED` will be rejected from navigation. *(Takip `PAUSED` iken bir ARCore pozu navigasyondan reddedilecektir.)*

A GNSS measurement blocked by the Ground Truth Firewall will be rejected from the estimator regardless of quality. *(Ground Truth Firewall tarafından engellenen bir GNSS ölçümü kalitesinden bağımsız olarak tahmin motorundan reddedilecektir.)*

---

# 27. Soft-Degradation Examples (Yumuşak Bozulma Örnekleri)

A slightly stale heading may remain usable with reduced confidence. *(Biraz eski bir yön azaltılmış güvenle kullanılabilir kalabilir.)*

A gyroscope-only heading may remain usable for a limited period while confidence decays. *(Yalnızca jiroskopa dayalı yön güven azalırken sınırlı bir süre kullanılabilir kalabilir.)*

A GNSS fix with weaker reported accuracy may remain available but receive larger uncertainty. *(Daha zayıf raporlanmış doğruluğa sahip GNSS fix’i kullanılabilir kalabilir ancak daha büyük belirsizlik alabilir.)*

---

# 28. Authorization Precedes Quality (Yetkilendirme Kaliteden Önce Gelir)

Quality assessment cannot override an explicit navigation authorization rule. *(Kalite değerlendirmesi açık bir navigasyon yetkilendirme kuralını geçersiz kılamaz.)*

A high-confidence GNSS measurement remains forbidden to the estimator while GNSS authorization is blocked. *(Yüksek güvenli bir GNSS ölçümü GNSS yetkilendirmesi engelliyken tahmin motoru için yasak kalır.)*

`text id="we3mlc" Authorization (Yetkilendirme)       ↓ Quality Validation (Kalite Doğrulama)       ↓ Fusion Decision (Füzyon Kararı)`

---

# 29. Common Quality Record (Ortak Kalite Kaydı)

`text id="p1zc7f" SourceQuality - sourceId - timestampNs - availability - qualityState - confidence - freshnessScore - timingScore - plausibilityScore - continuityScore - environmentalScore - consistencyScore - reasonFlags`

Not every source must populate every score. *(Her kaynak her skoru doldurmak zorunda değildir.)*

Unavailable dimensions will remain explicitly unavailable. *(Kullanılamayan boyutlar açıkça kullanılamaz kalacaktır.)*

---

# 30. Quality Reason Flags (Kalite Neden Flag’leri)

Quality decisions will preserve their causes rather than expose only one final score. *(Kalite kararları yalnızca tek bir nihai skor sunmak yerine nedenlerini koruyacaktır.)*

`text id="jkccu7" STALE TIMING_GAP TIMING_JITTER NON_MONOTONIC_TIME OUT_OF_RANGE SIGNAL_SPIKE MAGNETIC_DISTURBANCE TRACKING_LOST TRACKING_RECENTLY_RECOVERED LOW_VISUAL_FEATURES LOW_LIGHT EXCESSIVE_MOTION GNSS_POOR_ACCURACY GNSS_FIX_GAP GYRO_DRIFTING LOW_STEP_CONFIDENCE CROSS_SENSOR_DISAGREEMENT`

Multiple flags may be active simultaneously. *(Birden fazla flag aynı anda aktif olabilir.)*

---

# 31. Quality Provenance (Kalite Kaynak İzlenebilirliği)

Every derived quality decision should be traceable to the measurements and rules that produced it. *(Türetilmiş her kalite kararı onu üreten ölçümlere ve kurallara kadar izlenebilir olmalıdır.)*

This prevents confidence from becoming an unexplained black-box number. *(Bu güvenin açıklanamayan bir black-box sayısına dönüşmesini önler.)*

---

# 32. Accelerometer Quality (İvmeölçer Kalitesi)

Accelerometer quality will primarily evaluate availability, timestamp continuity, numerical validity, saturation or clipping evidence, and abnormal gaps. *(İvmeölçer kalitesi temel olarak kullanılabilirliği, zaman damgası sürekliliğini, sayısal geçerliliği, saturation veya clipping kanıtını ve anormal boşlukları değerlendirecektir.)*

Normal movement-induced acceleration magnitude variation will not itself be considered sensor failure. *(Normal hareket kaynaklı ivme büyüklüğü değişimi kendi başına sensör hatası kabul edilmeyecektir.)*

---

# 33. Accelerometer Quality Inputs (İvmeölçer Kalite Girdileri)

`text id="3qeyvc" availability timestampMonotonicity sampleGapStatistics measuredRate rangeValidity clippingEvidence`

The final clipping rule will depend on the physical sensor range discovered during the Device Capability Audit. *(Nihai clipping kuralı Cihaz Yetenek Denetimi sırasında keşfedilen fiziksel sensör aralığına bağlı olacaktır.)*

---

# 34. Gyroscope Quality (Jiroskop Kalitesi)

Gyroscope quality will evaluate availability, timing stability, numerical validity, stationary bias behavior, and time since the last absolute orientation correction when the gyroscope is used for heading propagation. *(Jiroskop kalitesi kullanılabilirliği, zamanlama kararlılığını, sayısal geçerliliği, sabit bias davranışını ve jiroskop yön ilerletmesi için kullanıldığında son mutlak yönelim düzeltmesinden itibaren geçen süreyi değerlendirecektir.)*

---

# 35. Gyroscope Confidence Decay (Jiroskop Güven Azalması)

Gyroscope-based heading confidence should generally decrease while absolute heading correction remains unavailable. *(Mutlak yön düzeltmesi kullanılamaz kaldığı sürece jiroskop tabanlı yön güveni genel olarak azalmalıdır.)*

The decay rate will be calibrated from measured Redmi Note 9 Pro gyroscope drift. *(Azalma oranı ölçülen Redmi Note 9 Pro jiroskop sürüklenmesinden kalibre edilecektir.)*

---

# 36. Magnetometer Quality (Manyetometre Kalitesi)

Magnetometer quality will use the disturbance evidence defined in **18 — Heading Estimation System**. *(Manyetometre kalitesi **18 — Heading Estimation System** içerisinde tanımlanan bozulma kanıtını kullanacaktır.)*

This includes field magnitude, field variation, sensor-status metadata, and disagreement with inertial heading. *(Bu alan büyüklüğünü, alan değişimini, sensör durum metadata bilgisini ve ataletsel yönle uyuşmazlığı içerir.)*

---

# 37. Magnetic Confidence Behavior (Manyetik Güven Davranışı)

Magnetic confidence should drop rapidly when strong disturbance evidence appears. *(Güçlü bozulma kanıtı ortaya çıktığında manyetik güven hızlı şekilde düşmelidir.)*

Recovery may be slower and require a stable sequence of good observations. *(Geri kazanım daha yavaş olabilir ve kararlı bir iyi gözlem dizisi gerektirebilir.)*

This asymmetric behavior provides hysteresis and prevents unstable rapid switching. *(Bu asimetrik davranış hysteresis sağlar ve kararsız hızlı geçişleri önler.)*

---

# 38. GNSS Quality (GNSS Kalitesi)

GNSS quality will reuse the validated GNSS diagnostics defined in **15 — GNSS Subsystem**. *(GNSS kalitesi **15 — GNSS Subsystem** içerisinde tanımlanan doğrulanmış GNSS tanılarını yeniden kullanacaktır.)*

Candidate evidence includes fix age, reported horizontal accuracy, recent position stability, used-in-fix satellite count, and C/N0 diagnostics when available. *(Aday kanıt fix yaşını, raporlanan yatay doğruluğu, son konum kararlılığını, fix’te kullanılan uydu sayısını ve mevcut olduğunda C/N0 tanısını içerir.)*

---

# 39. GNSS Quality Does Not Reopen the Firewall (GNSS Kalitesi Firewall’u Yeniden Açmaz)

GNSS quality will be computed even during Evaluation Mode if GNSS ground truth continues to be recorded. *(GNSS gerçek referansı kaydedilmeye devam ederse GNSS kalitesi Değerlendirme Modu sırasında bile hesaplanacaktır.)*

That quality information must not authorize GNSS estimator updates. *(Bu kalite bilgisi GNSS tahmin motoru güncellemelerini yetkilendirmemelidir.)*

---

# 40. Step Detection Quality (Adım Tespit Kalitesi)

Step-detection quality will reflect confidence that an accepted event represents a genuine pedestrian step. *(Adım tespit kalitesi kabul edilmiş bir olayın gerçek yaya adımını temsil ettiğine olan güveni yansıtacaktır.)*

Candidate evidence includes peak prominence, timing consistency, cadence consistency, stationary evidence, and detector validation state. *(Aday kanıt peak prominence değerini, zamanlama tutarlılığını, kadans tutarlılığını, sabit durum kanıtını ve algılayıcı doğrulama durumunu içerir.)*

---

# 41. PDR Quality (PDR Kalitesi)

PDR quality will represent the current expected reliability of the dead-reckoning trajectory rather than the confidence of one individual step. *(PDR kalitesi tek bir bireysel adımın güveni yerine mevcut dead-reckoning rotasının beklenen güvenilirliğini temsil edecektir.)*

It may depend on accumulated step count, time since last global reference, heading quality, step-length quality, and detected motion anomalies. *(Birikmiş adım sayısına, son global referanstan itibaren geçen süreye, yön kalitesine, adım uzunluğu kalitesine ve tespit edilen hareket anomalilerine bağlı olabilir.)*

---

# 42. PDR Confidence Must Generally Decrease Without Correction (PDR Güveni Düzeltme Olmadan Genel Olarak Azalmalıdır)

An uncorrected PDR trajectory should not become more confident merely because it has been running for longer. *(Düzeltilmemiş bir PDR rotası yalnızca daha uzun süredir çalıştığı için daha güvenli hale gelmemelidir.)*

Uncertainty should generally grow with distance, time, and low-quality navigation inputs. *(Belirsizlik genel olarak mesafe, zaman ve düşük kaliteli navigasyon girdileriyle büyümelidir.)*

---

# 43. ARCore Quality (ARCore Kalitesi)

ARCore quality will use tracking state, tracking failure reason, pose continuity, time since tracking recovery, stationary-drift characteristics, and detected pose jumps. *(ARCore kalitesi takip durumunu, takip başarısızlık nedenini, poz sürekliliğini, takip geri kazanımından itibaren geçen süreyi, sabit sürüklenme özelliklerini ve tespit edilen poz sıçramalarını kullanacaktır.)*

---

# 44. ARCore Hard Gate (ARCore Sert Kapısı)

A camera state other than valid `TRACKING` will prevent ARCore pose measurements from entering normal fusion. *(Geçerli `TRACKING` dışındaki kamera durumu ARCore poz ölçümlerinin normal füzyona girmesini engelleyecektir.)*

A quality score cannot override this rule. *(Bir kalite skoru bu kuralı geçersiz kılamaz.)*

---

# 45. Heading Quality (Yön Kalitesi)

Heading quality will combine the status of the active heading source with freshness, magnetic reliability, gyroscope drift exposure, and orientation validity. *(Yön kalitesi aktif yön kaynağının durumunu güncellik, manyetik güvenilirlik, jiroskop sürüklenme maruziyeti ve yönelim geçerliliğiyle birleştirecektir.)*

---

# 46. Motion Classification Quality (Hareket Sınıflandırma Kalitesi)

The AI motion classifier may expose its predicted class and associated model confidence. *(Yapay zekâ hareket sınıflandırıcısı tahmin edilen sınıfını ve ilişkili model güvenini sunabilir.)*

The Sensor Confidence & Quality Engine will preserve this confidence but will not automatically assume that raw softmax or model output is statistically calibrated. *(Sensör Güven ve Kalite Motoru bu güveni koruyacak ancak ham softmax veya model çıktısının istatistiksel olarak kalibre edildiğini otomatik olarak varsaymayacaktır.)*

---

# 47. Step Length Quality (Adım Uzunluğu Kalitesi)

Step-length quality will depend on the active estimation method and whether its inputs fall within the model’s validated operating region. *(Adım uzunluğu kalitesi aktif tahmin yöntemine ve girdilerinin modelin doğrulanmış çalışma bölgesi içerisinde olup olmadığına bağlı olacaktır.)*

A deterministic fixed-step fallback may have lower adaptability but still provide a known usable estimate. *(Deterministik sabit adım geri dönüşü daha düşük adaptasyona sahip olabilir ancak yine de bilinen kullanılabilir bir tahmin sağlayabilir.)*

---

# 48. Source-Specific Quality Profiles (Kaynağa Özgü Kalite Profilleri)

Each navigation source will have its own quality profile. *(Her navigasyon kaynağı kendi kalite profiline sahip olacaktır.)*

A universal rule set will not be forced onto fundamentally different sensors. *(Temelden farklı sensörlere evrensel tek bir kural seti zorlanmayacaktır.)*

---

# 49. Common Quality Interface (Ortak Kalite Arayüzü)

Despite source-specific rules, all sources will expose a common minimum quality interface to the fusion layer. *(Kaynağa özgü kurallara rağmen tüm kaynaklar füzyon katmanına ortak minimum kalite arayüzü sunacaktır.)*

`text id="79w6n5" NavigationMeasurement - measurement - timestamp - source - qualityState - confidence - covariance - reasonFlags`

Covariance may remain unavailable until the relevant source has been calibrated. *(İlgili kaynak kalibre edilene kadar kovaryans kullanılamaz kalabilir.)*

---

# 50. Freshness Score Candidate (Güncellik Skoru Adayı)

A source-specific freshness score may decrease as measurement age increases. *(Kaynağa özgü güncellik skoru ölçüm yaşı arttıkça azalabilir.)*

A simple conceptual model may use full confidence up to a preferred age and then decay toward zero. *(Basit kavramsal model tercih edilen yaşa kadar tam güven kullanabilir ve daha sonra sıfıra doğru azalabilir.)*

No universal age parameters will be fixed across all sources. *(Tüm kaynaklar için evrensel yaş parametreleri sabitlenmeyecektir.)*

---

# 51. Freshness Hard Limit (Güncellik Sert Sınırı)

Each time-sensitive measurement may define a maximum age beyond which it is no longer accepted as a current observation. *(Zamana duyarlı her ölçüm artık güncel gözlem olarak kabul edilmeyeceği maksimum bir yaş tanımlayabilir.)*

The exact threshold will be derived from the source’s measured update characteristics. *(Kesin eşik kaynağın ölçülmüş güncelleme özelliklerinden türetilecektir.)*

---

# 52. Timing Gap Detection (Zamanlama Boşluğu Tespiti)

For periodic streams, NAVGUARD will compare observed sample intervals with the source’s measured normal behavior. *(Periyodik akışlar için NAVGUARD gözlemlenen örnek aralıklarını kaynağın ölçülmüş normal davranışıyla karşılaştıracaktır.)*

Large unexpected gaps may reduce timing quality or invalidate nearby derived measurements. *(Büyük beklenmeyen boşluklar zamanlama kalitesini düşürebilir veya yakındaki türetilmiş ölçümleri geçersiz kılabilir.)*

---

# 53. Jitter Assessment (Jitter Değerlendirmesi)

Timing jitter may be characterized using the distribution of observed sample intervals. *(Zamanlama jitter’ı gözlemlenen örnek aralıklarının dağılımı kullanılarak karakterize edilebilir.)*

Candidate statistics include mean, median, standard deviation, and selected percentiles. *(Aday istatistikler ortalama, medyan, standart sapma ve seçilen yüzdelikleri içerir.)*

---

# 54. No Exact-Rate Assumption (Kesin Hız Varsayımı Olmaması)

Quality logic will use observed timestamps rather than assume that requested sensor rates were delivered exactly. *(Kalite mantığı talep edilen sensör hızlarının tam olarak teslim edildiğini varsaymak yerine gözlemlenen zaman damgalarını kullanacaktır.)*

---

# 55. Confidence Decay (Güven Azalması)

Some quality states require confidence to decrease gradually rather than immediately become zero. *(Bazı kalite durumları güvenin hemen sıfır olması yerine kademeli olarak azalmasını gerektirir.)*

Examples include gyroscope-only heading and PDR operating without external correction. *(Örnekler yalnızca jiroskopa dayalı yönü ve harici düzeltme olmadan çalışan PDR’yi içerir.)*

---

# 56. Confidence Decay Model (Güven Azalma Modeli)

A generic conceptual decay may be written as follows. *(Genel kavramsal azalma aşağıdaki şekilde yazılabilir.)*

`text id="hktrhs" c(t) = c0 · f(t)`

`f(t)` is a monotonic non-increasing function selected from experimental calibration. *(`f(t)`, deneysel kalibrasyondan seçilen monotonik olarak artmayan bir fonksiyondur.)*

The exact functional form will not be invented before measurements. *(Kesin fonksiyon biçimi ölçümlerden önce uydurulmayacaktır.)*

---

# 57. Distance-Based Decay (Mesafe Tabanlı Azalma)

PDR confidence may additionally depend on uncorrected travelled distance. *(PDR güveni ayrıca düzeltilmemiş kat edilen mesafeye bağlı olabilir.)*

This captures the fact that step-length and heading errors accumulate with propagation. *(Bu adım uzunluğu ve yön hatalarının ilerletmeyle biriktiği gerçeğini yakalar.)*

---

# 58. Confidence Recovery (Güven Geri Kazanımı)

Confidence recovery will generally require new valid evidence. *(Güven geri kazanımı genel olarak yeni geçerli kanıt gerektirecektir.)*

A source will not automatically return to full confidence immediately after one apparently good observation. *(Bir kaynak görünüşte iyi tek bir gözlemden sonra otomatik olarak tam güvene dönmeyecektir.)*

---

# 59. Recovery Hysteresis (Geri Kazanım Hysteresis’i)

Recovery may require several consecutive valid observations or a short stable time interval. *(Geri kazanım birkaç ardışık geçerli gözlem veya kısa kararlı zaman aralığı gerektirebilir.)*

This prevents rapid oscillation between good and bad quality states. *(Bu iyi ve kötü kalite durumları arasında hızlı salınımı önler.)*

---

# 60. Degradation Faster Than Recovery (Bozulma Geri Kazanımdan Daha Hızlı Olabilir)

For safety against bad measurements, the quality engine may reduce confidence faster than it restores confidence. *(Kötü ölçümlere karşı güvenlik için kalite motoru güveni geri kazandırdığından daha hızlı azaltabilir.)*

This policy is especially relevant to magnetometer disturbance and ARCore tracking recovery. *(Bu politika özellikle manyetometre bozulması ve ARCore takip geri kazanımı için ilgilidir.)*

---

# 61. Cross-Sensor Innovation Checks (Sensörler Arası Innovation Kontrolleri)

The quality engine may compare the innovation between two sources that estimate related physical quantities. *(Kalite motoru ilişkili fiziksel büyüklükleri tahmin eden iki kaynak arasındaki innovation değerini karşılaştırabilir.)*

`text id="di87zx" innovation = measurementA - predictedMeasurementB`

For angular quantities, circular difference must be used. *(Açısal büyüklükler için dairesel fark kullanılmalıdır.)*

---

# 62. Cross-Sensor Checks Are Supporting Evidence (Sensörler Arası Kontroller Destekleyici Kanıttır)

Disagreement does not automatically prove which source is wrong. *(Uyuşmazlık hangi kaynağın yanlış olduğunu otomatik olarak kanıtlamaz.)*

Cross-sensor disagreement will therefore reduce confidence only when combined with additional source-specific evidence. *(Bu nedenle sensörler arası uyuşmazlık yalnızca kaynağa özgü ek kanıtla birleştirildiğinde güveni azaltacaktır.)*

---

# 63. Heading Consistency Check (Yön Tutarlılık Kontrolü)

Magnetometer-derived heading may be compared with gyroscope-propagated heading. *(Manyetometre kaynaklı yön jiroskop ilerletmeli yönle karşılaştırılabilir.)*

A large unexpected angular innovation under low measured rotation may indicate magnetic disturbance. *(Düşük ölçülmüş dönüş altında büyük beklenmeyen açısal innovation manyetik bozulmayı gösterebilir.)*

---

# 64. PDR and ARCore Consistency Check (PDR ve ARCore Tutarlılık Kontrolü)

Over a suitable interval, PDR displacement and ARCore displacement may be compared. *(Uygun bir aralık boyunca PDR yer değiştirmesi ile ARCore yer değiştirmesi karşılaştırılabilir.)*

Large disagreement may indicate PDR drift, ARCore tracking error, phone-motion effects, or alignment problems. *(Büyük uyuşmazlık PDR sürüklenmesini, ARCore takip hatasını, telefon hareket etkilerini veya hizalama problemlerini gösterebilir.)*

The quality engine must not automatically blame one source without additional evidence. *(Kalite motoru ek kanıt olmadan otomatik olarak bir kaynağı suçlamamalıdır.)*

---

# 65. Stationary Cross-Check (Sabit Durum Çapraz Kontrolü)

When deterministic and AI motion evidence strongly indicates stationary behavior, significant PDR or ARCore displacement becomes suspicious. *(Deterministik ve yapay zekâ hareket kanıtı güçlü şekilde sabit davranışı gösterdiğinde anlamlı PDR veya ARCore yer değiştirmesi şüpheli hale gelir.)*

This evidence may be used to reduce relevant source confidence. *(Bu kanıt ilgili kaynak güvenini azaltmak için kullanılabilir.)*

---

# 66. Motion-Aware Quality (Hareket Farkındalıklı Kalite)

Sensor interpretation may depend on current motion context. *(Sensör yorumu mevcut hareket bağlamına bağlı olabilir.)*

For example, higher gyroscope activity is expected during turning and should not automatically indicate sensor failure. *(Örneğin dönüş sırasında daha yüksek jiroskop aktivitesi beklenir ve otomatik olarak sensör hatası göstermemelidir.)*

---

# 67. Environment-Aware Quality (Ortam Farkındalıklı Kalite)

The quality engine may also preserve environmental context such as indoor, outdoor, low-light, low-texture, or magnetically disturbed conditions when available. *(Kalite motoru ayrıca mevcut olduğunda iç mekân, dış mekân, düşük ışık, düşük doku veya manyetik olarak bozulmuş koşullar gibi çevresel bağlamı koruyabilir.)*

These labels will support analysis and not automatically become hidden corrections. *(Bu etiketler analizi destekleyecek ve otomatik olarak gizli düzeltmelere dönüşmeyecektir.)*

---

# 68. Quality Engine and EKF (Kalite Motoru ve EKF)

The quality engine will provide the EKF with information that can influence measurement acceptance and measurement covariance. *(Kalite motoru EKF’ye ölçüm kabulünü ve ölçüm kovaryansını etkileyebilecek bilgi sağlayacaktır.)*

The EKF remains responsible for the mathematical state update. *(EKF matematiksel durum güncellemesinden sorumlu kalır.)*

---

# 69. Measurement Covariance Scaling (Ölçüm Kovaryansı Ölçekleme)

A lower-confidence measurement may be represented by larger measurement covariance. *(Daha düşük güvenli bir ölçüm daha büyük ölçüm kovaryansıyla temsil edilebilir.)*

Conceptually, the relationship may follow the following principle. *(Kavramsal olarak ilişki aşağıdaki ilkeyi izleyebilir.)*

`text id="adq9bu" lower confidence (daha düşük güven)       ↓ larger R (daha büyük R)       ↓ less EKF influence (daha az EKF etkisi)`

The exact mapping will be empirically calibrated. *(Kesin eşleme ampirik olarak kalibre edilecektir.)*

---

# 70. No Arbitrary Confidence-to-Covariance Formula (Keyfi Güven-Kovaryans Formülü Olmaması)

NAVGUARD will not use a mathematically convenient but unvalidated formula such as `R = 1 / confidence` as a final model without experimental evidence. *(NAVGUARD deneysel kanıt olmadan `R = 1 / confidence` gibi matematiksel olarak kullanışlı ancak doğrulanmamış bir formülü nihai model olarak kullanmayacaktır.)*

---

# 71. Hard Gating Before Covariance Scaling (Kovaryans Ölçeklemeden Önce Sert Gate)

Invalid measurements will be rejected before covariance scaling is considered. *(Geçersiz ölçümler kovaryans ölçekleme değerlendirilmeden önce reddedilecektir.)*

Increasing covariance is not a substitute for rejecting obviously invalid data. *(Kovaryansı artırmak açıkça geçersiz veriyi reddetmenin yerine geçmez.)*

---

# 72. Quality-Aware Fusion Flow (Kalite Farkındalıklı Füzyon Akışı)

`text id="nwl5m2" Measurement (Ölçüm)     ↓ Authorization (Yetkilendirme)     ↓ Hard Validity Checks (Sert Geçerlilik Kontrolleri)     ↓ Quality Assessment (Kalite Değerlendirmesi)     ↓ Confidence / Covariance (Güven / Kovaryans)     ↓ EKF Innovation Gate (EKF Innovation Kapısı)     ↓ State Update (Durum Güncellemesi)`

---

# 73. Quality Engine Is Not the EKF Innovation Gate (Kalite Motoru EKF Innovation Kapısı Değildir)

The quality engine evaluates source quality before fusion. *(Kalite motoru füzyondan önce kaynak kalitesini değerlendirir.)*

The EKF may still perform its own innovation-based statistical gate after receiving the measurement. *(EKF ölçümü aldıktan sonra yine de kendi innovation tabanlı istatistiksel kapısını uygulayabilir.)*

Both mechanisms may reject the same measurement for different reasons. *(Her iki mekanizma aynı ölçümü farklı nedenlerle reddedebilir.)*

---

# 74. Quality Engine Output Timing (Kalite Motoru Çıktı Zamanlaması)

Quality metadata must correspond to the measurement or state interval it describes. *(Kalite metadata bilgisi tanımladığı ölçüm veya durum aralığına karşılık gelmelidir.)*

A later quality decision must not be retroactively attached to earlier measurements without explicit postprocessing semantics. *(Daha sonraki bir kalite kararı açık son işleme semantiği olmadan önceki ölçümlere geriye dönük bağlanmamalıdır.)*

---

# 75. Real-Time Causality (Gerçek Zamanlı Nedensellik)

Live quality decisions will use only information available up to the current time. *(Canlı kalite kararları yalnızca mevcut zamana kadar kullanılabilir bilgiyi kullanacaktır.)*

Future measurements must not improve a historical real-time confidence value. *(Gelecekteki ölçümler geçmiş gerçek zamanlı güven değerini iyileştirmemelidir.)*

---

# 76. Offline Quality Analysis (Çevrimdışı Kalite Analizi)

Offline analysis may calculate additional diagnostic quality metrics using complete recorded sessions. *(Çevrimdışı analiz tam kaydedilmiş oturumları kullanarak ek tanısal kalite metrikleri hesaplayabilir.)*

These retrospective metrics must be distinguished from online confidence used during navigation. *(Bu geriye dönük metrikler navigasyon sırasında kullanılan çevrimiçi güvenden ayırt edilmelidir.)*

---

# 77. Quality State Machine (Kalite Durum Makinesi)

A source may transition through the following simplified state sequence. *(Bir kaynak aşağıdaki basitleştirilmiş durum dizisi üzerinden geçebilir.)*

`text id="gqk8ng" UNKNOWN    ↓ GOOD    ↓ USABLE    ↓ DEGRADED    ↓ UNRELIABLE    ↓ UNAVAILABLE`

Recovery may move in the opposite direction only after sufficient valid evidence. *(Geri kazanım yalnızca yeterli geçerli kanıttan sonra ters yönde ilerleyebilir.)*

---

# 78. State Transitions Need Hysteresis (Durum Geçişleri Hysteresis Gerektirir)

A single borderline sample should not repeatedly flip a source between `GOOD` and `DEGRADED`. *(Tek bir sınırdaki örnek kaynağı sürekli `GOOD` ile `DEGRADED` arasında değiştirmemelidir.)*

State-entry and state-exit conditions may therefore differ. *(Bu nedenle duruma giriş ve durumdan çıkış koşulları farklı olabilir.)*

---

# 79. Quality Update Frequency (Kalite Güncelleme Frekansı)

Quality state may update when new source measurements arrive. *(Yeni kaynak ölçümleri geldiğinde kalite durumu güncellenebilir.)*

Some time-dependent qualities must also update when no new measurement arrives because freshness continues to decrease. *(Bazı zamana bağlı kaliteler yeni ölçüm gelmediğinde de güncellenmelidir çünkü güncellik azalmaya devam eder.)*

---

# 80. Missing Data Is Information (Eksik Veri de Bilgidir)

A missing expected update may itself lower quality. *(Beklenen bir güncellemenin gelmemesi kendi başına kaliteyi düşürebilir.)*

The quality engine must therefore react not only to incoming values but also to expected events that fail to arrive. *(Bu nedenle kalite motoru yalnızca gelen değerlere değil gerçekleşmeyen beklenen olaylara da tepki vermelidir.)*

---

# 81. Source Timeout (Kaynak Timeout’u)

Each periodic or semi-periodic source may define a timeout after which it becomes stale or unavailable. *(Her periyodik veya yarı periyodik kaynak eski veya kullanılamaz hale geleceği bir timeout tanımlayabilir.)*

These timeouts will be determined from measured source behavior. *(Bu timeout değerleri ölçülmüş kaynak davranışından belirlenecektir.)*

---

# 82. Quality Event Logging (Kalite Olay Kaydı)

Important quality transitions will generate structured events. *(Önemli kalite geçişleri yapılandırılmış olaylar üretecektir.)*

`text id="zlzyck" QUALITY_DEGRADED QUALITY_UNRELIABLE QUALITY_UNAVAILABLE QUALITY_RECOVERING QUALITY_RECOVERED MEASUREMENT_REJECTED`

Each event will identify the source and reason flags. *(Her olay kaynağı ve neden flag’lerini tanımlayacaktır.)*

---

# 83. Quality Transition Log (Kalite Geçiş Kaydı)

`text id="54nsjr" timestamp_ns, source_id, previous_state, new_state, confidence_before, confidence_after, reason_flags`

This log will support explanation of fusion behavior during field tests. *(Bu kayıt saha testleri sırasında füzyon davranışının açıklanmasını destekleyecektir.)*

---

# 84. Per-Measurement Quality Logging (Ölçüm Başına Kalite Kaydı)

For important fusion measurements, quality metadata may be stored directly with the processed measurement. *(Önemli füzyon ölçümleri için kalite metadata bilgisi doğrudan işlenmiş ölçümle birlikte saklanabilir.)*

This avoids losing the exact quality state used during the historical estimator update. *(Bu geçmiş tahmin motoru güncellemesi sırasında kullanılan kesin kalite durumunun kaybolmasını önler.)*

---

# 85. Quality Configuration Snapshot (Kalite Yapılandırma Anlık Görüntüsü)

Every formal session should preserve the active quality-engine configuration. *(Her resmî oturum aktif kalite motoru yapılandırmasını korumalıdır.)*

`text id="86f4fm" qualityEngineVersion sourceProfiles freshnessThresholds timeoutRules degradationRules recoveryRules confidenceMappings covarianceMappings`

---

# 86. Quality Versioning (Kalite Sürümleme)

Changes to quality thresholds, confidence decay, recovery hysteresis, or covariance mappings must increment the quality-engine configuration version. *(Kalite eşiklerindeki, güven azalmasındaki, geri kazanım hysteresis’indeki veya kovaryans eşlemelerindeki değişiklikler kalite motoru yapılandırma sürümünü artırmalıdır.)*

---

# 87. No Hidden Runtime Retuning (Gizli Çalışma Zamanı Yeniden Ayarı Olmaması)

Formal benchmark quality thresholds must not silently retune themselves using the benchmark ground-truth error. *(Resmî benchmark kalite eşikleri benchmark gerçek referans hatasını kullanarak kendilerini sessizce yeniden ayarlamamalıdır.)*

Ground truth is for evaluation, not hidden online calibration during the denied interval. *(Ground truth değerlendirme içindir, kesintili aralık sırasında gizli çevrimiçi kalibrasyon için değildir.)*

---

# 88. Calibration Data Separation (Kalibrasyon Verisi Ayrımı)

Quality thresholds may be tuned using development and pilot sessions. *(Kalite eşikleri geliştirme ve pilot oturumlar kullanılarak ayarlanabilir.)*

Final benchmark sessions must remain held out from this tuning process. *(Nihai benchmark oturumları bu ayar sürecinden ayrılmış kalmalıdır.)*

---

# 89. Empirical Calibration Principle (Ampirik Kalibrasyon İlkesi)

Confidence and quality thresholds will be based on measured relationships between diagnostic evidence and actual navigation error. *(Güven ve kalite eşikleri tanısal kanıt ile gerçek navigasyon hatası arasındaki ölçülmüş ilişkilere dayanacaktır.)*

A threshold will not be retained merely because it appears reasonable numerically. *(Bir eşik yalnızca sayısal olarak makul göründüğü için korunmayacaktır.)*

---

# 90. Quality Engine Evaluation (Kalite Motoru Değerlendirmesi)

The quality engine will be evaluated by whether degraded or rejected measurements correspond to increased source error or known failure conditions. *(Kalite motoru bozulmuş veya reddedilmiş ölçümlerin artan kaynak hatası veya bilinen hata koşullarıyla eşleşip eşleşmediğine göre değerlendirilecektir.)*

It will also be evaluated by its effect on fused navigation performance. *(Ayrıca füzyonlu navigasyon performansı üzerindeki etkisiyle değerlendirilecektir.)*

---

# 91. Ablation Evaluation (Ablation Değerlendirmesi)

The target fusion system may be evaluated with quality adaptation enabled and disabled. *(Hedef füzyon sistemi kalite adaptasyonu açık ve kapalı olarak değerlendirilebilir.)*

```text id=“b2vw74”
Fusion with fixed source treatment
(Sabit kaynak davranışıyla füzyon)

versus
(karşı)

Quality-aware fusion
(Kalite farkındalıklı füzyon)

```

This will determine whether the additional quality layer produces measurable benefit. *(Bu ek kalite katmanının ölçülebilir fayda üretip üretmediğini belirleyecektir.)*

---

# 92. Quality Detection Precision (Kalite Tespiti Precision Değeri)

Where explicit failure labels exist, a quality detector may be evaluated using precision and recall. *(Açık hata etiketleri mevcut olduğunda bir kalite algılayıcı precision ve recall kullanılarak değerlendirilebilir.)*

For example, ARCore tracking-loss detection already has explicit platform states and can be validated deterministically. *(Örneğin ARCore takip kaybı tespiti zaten açık platform durumlarına sahiptir ve deterministik olarak doğrulanabilir.)*

---

# 93. Correlation With Error (Hata ile Korelasyon)

For continuous confidence scores, NAVGUARD may examine whether lower confidence corresponds statistically to larger observed navigation error. *(Sürekli güven skorları için NAVGUARD daha düşük güvenin istatistiksel olarak daha büyük gözlemlenmiş navigasyon hatasına karşılık gelip gelmediğini inceleyebilir.)*

A confidence score that has no relationship with actual error has limited value. *(Gerçek hatayla hiçbir ilişkisi olmayan bir güven skorunun değeri sınırlıdır.)*

---

# 94. Confidence Calibration Analysis (Güven Kalibrasyon Analizi)

If enough data exists, observations may be grouped into confidence bins and their empirical error distributions compared. *(Yeterli veri mevcutsa gözlemler güven bin'lerine ayrılabilir ve ampirik hata dağılımları karşılaştırılabilir.)*

This may later support a more principled mapping from confidence to covariance. *(Bu daha sonra güvenden kovaryansa daha prensipli bir eşlemeyi destekleyebilir.)*

---

# 95. Source Availability Metric (Kaynak Kullanılabilirlik Metriği)

For each navigation source, availability may be measured as follows. *(Her navigasyon kaynağı için kullanılabilirlik aşağıdaki şekilde ölçülebilir.)*

```text id="qa3xn1"
Availability =
ValidSourceDuration
─────────────────── × 100
SessionDuration
```

---

# 96. Degraded-Time Metric (Bozulmuş Süre Metriği)

NAVGUARD may measure the percentage of a session during which each source remained degraded. *(NAVGUARD her kaynağın oturumun yüzde kaçında bozulmuş durumda kaldığını ölçebilir.)*

This will help explain differences between sessions. *(Bu oturumlar arasındaki farkları açıklamaya yardımcı olacaktır.)*

---

# 97. Rejection Rate (Red Oranı)

A source-specific measurement rejection rate may be calculated. *(Kaynağa özgü ölçüm red oranı hesaplanabilir.)*

`text id="4wsubz" RejectionRate = RejectedMeasurements ──────────────────── × 100 CandidateMeasurements`

A very high rejection rate may indicate either poor source conditions or overly aggressive quality rules. *(Çok yüksek red oranı ya kötü kaynak koşullarını ya da aşırı agresif kalite kurallarını gösterebilir.)*

---

# 98. Recovery Time Metric (Geri Kazanım Süresi Metriği)

Quality recovery time may measure the interval between the end of a known disturbance and return to an accepted quality state. *(Kalite geri kazanım süresi bilinen bir bozulmanın sonu ile kabul edilmiş kalite durumuna dönüş arasındaki aralığı ölçebilir.)*

This is relevant to magnetometer and ARCore recovery behavior. *(Bu manyetometre ve ARCore geri kazanım davranışı için önemlidir.)*

---

# 99. False Recovery (Yanlış Geri Kazanım)

A source that returns to `GOOD` immediately before another failure may indicate weak hysteresis or overly permissive recovery rules. *(Başka bir hatadan hemen önce `GOOD` durumuna dönen bir kaynak zayıf hysteresis veya aşırı izin verici geri kazanım kurallarını gösterebilir.)*

Such oscillations will be analyzed during pilot testing. *(Bu tür salınımlar pilot test sırasında analiz edilecektir.)*

---

# 100. Quality Engine Diagnostic UI (Kalite Motoru Tanı Arayüzü)

A developer or research diagnostics screen may display current source qualities. *(Bir geliştirici veya araştırma tanı ekranı mevcut kaynak kalitelerini gösterebilir.)*

`text id="2kpp27" Accelerometer   GOOD Gyroscope       GOOD Magnetometer    DEGRADED Heading         USABLE PDR             USABLE ARCore          UNAVAILABLE GNSS            GOOD / BLOCKED_FROM_ESTIMATOR`

Authorization status must remain distinct from quality status. *(Yetkilendirme durumu kalite durumundan ayrı kalmalıdır.)*

---

# 101. User-Facing Quality Presentation (Kullanıcıya Yönelik Kalite Sunumu)

The normal navigation interface should avoid overwhelming the user with raw sensor diagnostics. *(Normal navigasyon arayüzü kullanıcıyı ham sensör tanılarıyla bunaltmamalıdır.)*

A simplified overall navigation-confidence indicator may be shown while detailed source information remains available in research diagnostics. *(Ayrıntılı kaynak bilgisi araştırma tanısında kullanılabilir kalırken basitleştirilmiş genel navigasyon güven göstergesi gösterilebilir.)*

---

# 102. Overall Navigation Confidence (Genel Navigasyon Güveni)

NAVGUARD may derive an overall confidence state from the active navigation architecture. *(NAVGUARD aktif navigasyon mimarisinden genel bir güven durumu türetebilir.)*

This value must not be calculated as a naive arithmetic average of all sensor confidence scores. *(Bu değer tüm sensör güven skorlarının basit aritmetik ortalaması olarak hesaplanmamalıdır.)*

The importance of each source depends on the current navigation mode and estimator state. *(Her kaynağın önemi mevcut navigasyon moduna ve tahmin motoru durumuna bağlıdır.)*

---

# 103. Mode-Dependent Confidence (Moda Bağlı Güven)

In GNSS Mode, GNSS quality may strongly influence overall confidence. *(GNSS Modunda GNSS kalitesi genel güveni güçlü şekilde etkileyebilir.)*

In NAVGUARD Mode, GNSS quality must not influence estimator confidence as an available correction source because GNSS is intentionally excluded. *(NAVGUARD Modunda GNSS bilinçli olarak dışlandığı için GNSS kalitesi tahmin motoru güvenini kullanılabilir düzeltme kaynağı olarak etkilememelidir.)*

---

# 104. Evaluation Mode Quality Separation (Değerlendirme Modu Kalite Ayrımı)

Evaluation Mode may simultaneously report good GNSS ground-truth quality and lower NAVGUARD estimator confidence. *(Değerlendirme Modu aynı anda iyi GNSS gerçek referans kalitesi ve daha düşük NAVGUARD tahmin motoru güveni raporlayabilir.)*

This is a valid and expected combination. *(Bu geçerli ve beklenen bir birleşimdir.)*

---

# 105. Example Evaluation Quality State (Örnek Değerlendirme Kalite Durumu)

```text id=“2gzi6g”
GNSS Ground Truth Quality:
GOOD

GNSS Estimator Authorization:
BLOCKED

PDR Quality:
USABLE

Heading Quality:
GOOD

ARCore Quality:
DEGRADED

Overall NAVGUARD Confidence:
MODERATE

```

This state does not violate GNSS-denied experiment integrity. *(Bu durum GNSS kesintili deney bütünlüğünü ihlal etmez.)*

---

# 106. UI Confidence Labels (UI Güven Etiketleri)

A separate UI-only type may initially use the following representation. *(Ayrı bir UI-only type başlangıçta aşağıdaki temsili kullanabilir.)*

```text
UiConfidenceLabel

HIGH
MODERATE
LOW
VERY_LOW
UNAVAILABLE
```

`UiConfidenceLabel` is not the canonical Sensor Quality enum and must be derived through an explicit, versioned mapping from quality and uncertainty information. *(UiConfidenceLabel canonical Sensor Quality enum değildir ve quality ile uncertainty bilgisinden explicit, versioned bir mapping üzerinden türetilmelidir.)*

The canonical internal Sensor Quality enum remains `UNKNOWN`, `GOOD`, `USABLE`, `DEGRADED`, `UNRELIABLE`, and `UNAVAILABLE`. *(Canonical internal Sensor Quality enum `UNKNOWN`, `GOOD`, `USABLE`, `DEGRADED`, `UNRELIABLE` ve `UNAVAILABLE` olarak kalır.)*

The UI mapping must be calibrated against actual navigation error before being presented as a validated uncertainty indicator. *(UI mapping doğrulanmış uncertainty indicator olarak sunulmadan önce actual navigation error'a karşı kalibre edilmelidir.)*

---

# 107. Confidence Versus Position Uncertainty (Güven ile Konum Belirsizliği)

Confidence and position uncertainty are related but not identical quantities. *(Güven ve konum belirsizliği ilişkili ancak aynı olmayan büyüklüklerdir.)*

The formal position-uncertainty representation will be defined in **28 — Position Estimation & Uncertainty Engine**. *(Resmî konum belirsizliği temsili **28 — Position Estimation & Uncertainty Engine** içerisinde tanımlanacaktır.)*

The quality engine supplies evidence that may influence that uncertainty. *(Kalite motoru bu belirsizliği etkileyebilecek kanıt sağlar.)*

---

# 108. Sensor Failure Independence (Sensör Hatası Bağımsızlığı)

Failure of one optional source must not automatically invalidate all navigation. *(İsteğe bağlı bir kaynağın başarısız olması tüm navigasyonu otomatik olarak geçersiz kılmamalıdır.)*

The quality engine will support graceful degradation according to available fallback sources. *(Kalite motoru mevcut geri dönüş kaynaklarına göre kontrollü bozulmayı destekleyecektir.)*

---

# 109. Example Graceful Degradation (Örnek Kontrollü Bozulma)

`text id="5a11p7" ARCore lost (ARCore kayıp)      ↓ ARCore confidence = 0      ↓ PDR + Heading continue (PDR + Yön devam eder)      ↓ Overall confidence decreases (Genel güven azalır)`

The navigation session does not need to terminate. *(Navigasyon oturumunun sona ermesi gerekmez.)*

---

# 110. Magnetometer Failure Example (Manyetometre Hatası Örneği)

`text id="9uvqia" Magnetic disturbance (Manyetik bozulma)       ↓ Magnetometer = UNRELIABLE       ↓ Magnetic correction disabled (Manyetik düzeltme devre dışı)       ↓ Gyroscope propagation continues (Jiroskop ilerletmesi devam eder)       ↓ Heading confidence decays (Yön güveni azalır)`

---

# 111. GNSS Loss Example (GNSS Kayıp Örneği)

After a valid initial anchor, real GNSS loss does not automatically stop PDR. *(Geçerli bir başlangıç çapasından sonra gerçek GNSS kaybı PDR’yi otomatik olarak durdurmaz.)*

GNSS quality becomes unavailable while local-estimation confidence evolves according to PDR, heading, and ARCore quality. *(GNSS kalitesi kullanılamaz hale gelirken yerel tahmin güveni PDR, yön ve ARCore kalitesine göre gelişir.)*

---

# 112. Multiple Simultaneous Failures (Birden Fazla Eşzamanlı Hata)

The quality engine must support multiple degraded sources simultaneously. *(Kalite motoru aynı anda birden fazla bozulmuş kaynağı desteklemelidir.)*

For example, ARCore and magnetometer may both become unreliable while PDR and gyroscope remain partially usable. *(Örneğin PDR ve jiroskop kısmen kullanılabilir kalırken ARCore ve manyetometre aynı anda güvenilmez hale gelebilir.)*

---

# 113. Minimum Navigation Gate (Minimum Navigasyon Kapısı)

The minimum architecture requires sufficient quality for step detection and directional propagation. *(Minimum mimari adım tespiti ve yönsel ilerletme için yeterli kalite gerektirir.)*

If every usable heading source is lost, directional PDR may no longer satisfy formal navigation quality requirements. *(Kullanılabilir tüm yön kaynakları kaybolursa yönsel PDR artık resmî navigasyon kalite gereksinimlerini karşılamayabilir.)*

---

# 114. Quality Engine Failure Must Be Safe (Kalite Motoru Hatası Güvenli Olmalıdır)

If the quality engine itself encounters an internal error, it must not silently mark every source as `GOOD`. *(Kalite motorunun kendisi dahili hata yaşarsa tüm kaynakları sessizce `GOOD` olarak işaretlememelidir.)*

The conservative fallback is to preserve hard validity rules and reduce use of uncertain advanced sources. *(Temkinli geri dönüş sert geçerlilik kurallarını korumak ve belirsiz gelişmiş kaynakların kullanımını azaltmaktır.)*

---

# 115. Quality Engine Failure Codes (Kalite Motoru Hata Kodları)

`text id="1x5olh" QUALITY_CONFIGURATION_ERROR QUALITY_SOURCE_UNKNOWN QUALITY_TIMESTAMP_ERROR QUALITY_NUMERICAL_ERROR QUALITY_RULE_CONFLICT QUALITY_MAPPING_UNAVAILABLE QUALITY_INTERNAL_ERROR`

---

# 116. No Circular Dependency (Döngüsel Bağımlılık Olmaması)

The quality engine must avoid circular logic where sensor confidence depends on fused position error while fused position simultaneously depends on the same confidence in real time. *(Kalite motoru sensör güveninin füzyonlu konum hatasına bağlı olduğu ve füzyonlu konumun aynı anda gerçek zamanlı olarak aynı güvene bağlı olduğu döngüsel mantıktan kaçınmalıdır.)*

Evaluation ground truth may be used offline for calibration but not as a hidden online quality input. *(Değerlendirme ground truth verisi çevrimdışı kalibrasyon için kullanılabilir ancak gizli çevrimiçi kalite girdisi olarak kullanılamaz.)*

---

# 117. No Ground-Truth Leakage (Ground Truth Sızıntısı Olmaması)

During Evaluation Mode, GNSS ground truth must not be used to label current PDR, heading, ARCore, or fused estimates as good or bad before the navigation update occurs. *(Değerlendirme Modunda GNSS ground truth mevcut navigasyon güncellemesi gerçekleşmeden önce PDR, yön, ARCore veya füzyon tahminlerini iyi veya kötü olarak etiketlemek için kullanılmamalıdır.)*

Such usage would leak reference information into the estimator. *(Böyle bir kullanım referans bilgisini tahmin motoruna sızdırır.)*

---

# 118. Offline Ground-Truth Calibration Is Allowed (Çevrimdışı Ground Truth Kalibrasyonuna İzin Verilir)

After a session ends, GNSS reference error may be compared against historical quality scores. *(Bir oturum sona erdikten sonra GNSS referans hatası geçmiş kalite skorlarıyla karşılaştırılabilir.)*

This analysis may improve future frozen quality mappings. *(Bu analiz gelecekteki sabitlenmiş kalite eşlemelerini iyileştirebilir.)*

It must not rewrite the original real-time confidence history. *(Orijinal gerçek zamanlı güven geçmişini yeniden yazmamalıdır.)*

---

# 119. Quality Replay (Kalite Replay)

Recorded source data should be sufficient to rerun the quality engine offline. *(Kaydedilmiş kaynak verisi kalite motorunu çevrimdışı yeniden çalıştırmak için yeterli olmalıdır.)*

The same source data and frozen quality configuration should produce equivalent quality transitions. *(Aynı kaynak verisi ve sabitlenmiş kalite yapılandırması eşdeğer kalite geçişleri üretmelidir.)*

---

# 120. Deterministic Quality Rules (Deterministik Kalite Kuralları)

The baseline quality engine should be deterministic where rules are threshold-based. *(Temel kalite motoru kurallar eşik tabanlı olduğunda deterministik olmalıdır.)*

Learned quality models, if ever added, must be versioned and evaluated separately. *(Öğrenilmiş kalite modelleri daha sonra eklenirse sürümlenmeli ve ayrı değerlendirilmelidir.)*

---

# 121. AI Is Not Required for Quality Engine (Kalite Motoru İçin Yapay Zekâ Gerekli Değildir)

The minimum Sensor Confidence & Quality Engine will use deterministic evidence and rules. *(Minimum Sensör Güven ve Kalite Motoru deterministik kanıt ve kurallar kullanacaktır.)*

Artificial intelligence is not required to decide whether fundamental sensors are available, stale, or invalid. *(Temel sensörlerin kullanılabilir, eski veya geçersiz olup olmadığına karar vermek için yapay zekâ gerekli değildir.)*

---

# 122. Optional Learned Quality Model (İsteğe Bağlı Öğrenilmiş Kalite Modeli)

A learned quality model may be investigated only if deterministic rules fail to capture an important measurable failure pattern. *(Öğrenilmiş kalite modeli yalnızca deterministik kurallar önemli ölçülebilir bir hata örüntüsünü yakalayamazsa araştırılabilir.)*

It is outside the minimum project requirement. *(Minimum proje gereksiniminin dışındadır.)*

---

# 123. CPU and Memory Requirement (CPU ve Bellek Gereksinimi)

The quality engine must remain lightweight enough to run continuously with the navigation stack. *(Kalite motoru navigasyon yığınıyla sürekli çalışabilecek kadar hafif kalmalıdır.)*

Most quality checks should use incremental statistics rather than repeatedly processing entire historical sessions in real time. *(Çoğu kalite kontrolü gerçek zamanlı olarak tüm geçmiş oturumları tekrar tekrar işlemek yerine artımlı istatistikler kullanmalıdır.)*

---

# 124. Sliding Window Statistics (Kayan Pencere İstatistikleri)

Short-term quality checks may use bounded rolling windows. *(Kısa dönem kalite kontrolleri sınırlı kayan pencereler kullanabilir.)*

Examples include magnetic-field variance, sampling-interval variance, and recent pose continuity. *(Örnekler manyetik alan varyansını, örnekleme aralığı varyansını ve son poz sürekliliğini içerir.)*

Window lengths will be source-specific and experimentally tuned. *(Pencere uzunlukları kaynağa özgü olacak ve deneysel olarak ayarlanacaktır.)*

---

# 125. Online Statistics (Çevrimiçi İstatistikler)

Where possible, mean and variance may be updated incrementally. *(Mümkün olduğunda ortalama ve varyans artımlı olarak güncellenebilir.)*

This reduces memory and CPU overhead. *(Bu bellek ve CPU yükünü azaltır.)*

---

# 126. Minimum Quality Engine (Minimum Kalite Motoru)

The minimum quality engine must monitor source availability. *(Minimum kalite motoru kaynak kullanılabilirliğini izlemelidir.)*

It must monitor measurement freshness. *(Ölçüm güncelliğini izlemelidir.)*

It must detect invalid numerical values. *(Geçersiz sayısal değerleri tespit etmelidir.)*

It must detect important timestamp failures. *(Önemli zaman damgası hatalarını tespit etmelidir.)*

It must preserve source-specific hard-rejection rules. *(Kaynağa özgü sert red kurallarını korumalıdır.)*

---

# 127. Target Quality Engine (Hedef Kalite Motoru)

The target quality engine will additionally support continuous confidence. *(Hedef kalite motoru ayrıca sürekli güveni destekleyecektir.)*

It will support source-specific degradation and recovery hysteresis. *(Kaynağa özgü bozulma ve geri kazanım hysteresis’ini destekleyecektir.)*

It will support confidence-informed covariance scaling. *(Güven bilgili kovaryans ölçeklemeyi destekleyecektir.)*

It will support cross-sensor consistency evidence. *(Sensörler arası tutarlılık kanıtını destekleyecektir.)*

---

# 128. Optional Quality Enhancements (İsteğe Bağlı Kalite İyileştirmeleri)

Optional enhancements may include learned disturbance detection. *(İsteğe bağlı iyileştirmeler öğrenilmiş bozulma tespitini içerebilir.)*

Optional enhancements may include more advanced confidence calibration. *(İsteğe bağlı iyileştirmeler daha gelişmiş güven kalibrasyonunu içerebilir.)*

Optional enhancements may include environment-adaptive quality profiles. *(İsteğe bağlı iyileştirmeler ortama adaptif kalite profillerini içerebilir.)*

These features must not delay the core navigation implementation. *(Bu özellikler temel navigasyon uygulamasını geciktirmemelidir.)*

---

# 129. Quality Engine Non-Goals (Kalite Motoru Olmayan Hedefler)

The quality engine will not estimate geographic position. *(Kalite motoru coğrafi konum tahmin etmeyecektir.)*

The quality engine will not independently perform EKF state updates. *(Kalite motoru bağımsız olarak EKF durum güncellemeleri gerçekleştirmeyecektir.)*

The quality engine will not use GNSS ground truth as a hidden live correction source. *(Kalite motoru GNSS ground truth verisini gizli canlı düzeltme kaynağı olarak kullanmayacaktır.)*

The quality engine will not claim certified navigation integrity. *(Kalite motoru sertifikalı navigasyon bütünlüğü iddia etmeyecektir.)*

---

# 130. Quality Engine Unit Tests (Kalite Motoru Birim Testleri)

A fresh valid measurement must not be marked stale. *(Yeni ve geçerli bir ölçüm eski olarak işaretlenmemelidir.)*

A measurement beyond the configured freshness limit must become stale or unavailable according to policy. *(Yapılandırılmış güncellik sınırının ötesindeki ölçüm politikaya göre eski veya kullanılamaz hale gelmelidir.)*

NaN values must be rejected. *(NaN değerleri reddedilmelidir.)*

Non-monotonic timestamps must trigger the configured quality response. *(Monotonik olmayan zaman damgaları yapılandırılmış kalite yanıtını tetiklemelidir.)*

---

# 131. Hysteresis Unit Test (Hysteresis Birim Testi)

A source near a quality boundary must not rapidly oscillate between states because of one-sample noise. *(Kalite sınırına yakın bir kaynak tek örneklik gürültü nedeniyle durumlar arasında hızlı şekilde salınmamalıdır.)*

The configured recovery condition must require the intended stable evidence. *(Yapılandırılmış geri kazanım koşulu amaçlanan kararlı kanıtı gerektirmelidir.)*

---

# 132. Confidence Decay Unit Test (Güven Azalması Birim Testi)

For a source configured with time-based decay, confidence must not increase while no new corrective evidence arrives. *(Zaman tabanlı azalmayla yapılandırılmış bir kaynak için yeni düzeltici kanıt gelmezken güven artmamalıdır.)*

---

# 133. Authorization Unit Test (Yetkilendirme Birim Testi)

A high-quality GNSS sample must still be rejected from the estimator when GNSS authorization is blocked. *(Yüksek kaliteli bir GNSS örneği GNSS yetkilendirmesi engelliyken yine de tahmin motorundan reddedilmelidir.)*

This test is mandatory for Evaluation Mode integrity. *(Bu test Değerlendirme Modu bütünlüğü için zorunludur.)*

---

# 134. ARCore Quality Unit Test (ARCore Kalite Birim Testi)

An ARCore pose with `PAUSED` tracking must receive a non-usable navigation quality state. *(`PAUSED` takibe sahip bir ARCore pozu kullanılamaz navigasyon kalite durumu almalıdır.)*

A new valid tracking segment must pass recovery conditions before normal confidence is restored. *(Yeni geçerli bir takip segmenti normal güven geri yüklenmeden önce geri kazanım koşullarını geçmelidir.)*

---

# 135. Magnetometer Quality Unit Test (Manyetometre Kalite Birim Testi)

A synthetic large magnetic anomaly must trigger the configured disturbance response. *(Sentetik büyük bir manyetik anomali yapılandırılmış bozulma yanıtını tetiklemelidir.)*

Recovery must require the configured stable interval rather than one good sample. *(Geri kazanım tek iyi örnek yerine yapılandırılmış kararlı aralığı gerektirmelidir.)*

---

# 136. Quality-to-Fusion Integration Test (Kalite-Füzyon Entegrasyon Testi)

A measurement marked `UNRELIABLE` must not perform a normal EKF measurement update. *(`UNRELIABLE` olarak işaretlenen bir ölçüm normal EKF ölçüm güncellemesi gerçekleştirmemelidir.)*

A lower-confidence accepted measurement should produce the configured increase in measurement uncertainty once covariance mapping is implemented. *(Daha düşük güvenli kabul edilmiş bir ölçüm kovaryans eşlemesi geliştirildikten sonra yapılandırılmış ölçüm belirsizliği artışını üretmelidir.)*

---

# 137. Physical Quality Tests (Fiziksel Kalite Testleri)

Quality behavior must be tested on the physical Redmi Note 9 Pro. *(Kalite davranışı fiziksel Redmi Note 9 Pro üzerinde test edilmelidir.)*

Recorded conditions will include stationary operation, normal walking, turns, magnetic disturbance, ARCore degradation, and GNSS quality variation where practical. *(Kaydedilen koşullar uygulanabilir olduğunda sabit çalışma, normal yürüyüş, dönüşler, manyetik bozulma, ARCore bozulması ve GNSS kalite değişimini içerecektir.)*

---

# 138. Quality Threshold Freeze (Kalite Eşik Sabitleme)

Final source-specific thresholds will be frozen only after Device Capability Audit and pilot sessions. *(Nihai kaynağa özgü eşikler yalnızca Cihaz Yetenek Denetimi ve pilot oturumlardan sonra sabitlenecektir.)*

Threshold revisions must be documented before final benchmark execution. *(Eşik değişiklikleri nihai benchmark çalıştırılmadan önce dokümante edilmelidir.)*

---

# 139. Acceptance Criteria — Core Quality (Kabul Kriterleri — Temel Kalite)

Every fusion-capable source must expose availability and quality state. *(Füzyona uygun her kaynak kullanılabilirlik ve kalite durumu sunmalıdır.)*

Invalid measurements must be rejectable before fusion. *(Geçersiz ölçümler füzyondan önce reddedilebilir olmalıdır.)*

Stale measurements must be distinguishable from fresh measurements. *(Eski ölçümler yeni ölçümlerden ayırt edilebilir olmalıdır.)*

Quality reasons must remain observable in diagnostics. *(Kalite nedenleri tanıda gözlemlenebilir kalmalıdır.)*

---

# 140. Acceptance Criteria — Degradation (Kabul Kriterleri — Bozulma)

ARCore tracking loss must reduce ARCore quality without stopping PDR. *(ARCore takip kaybı PDR’yi durdurmadan ARCore kalitesini düşürmelidir.)*

Magnetic disturbance must reduce magnetometer influence. *(Manyetik bozulma manyetometre etkisini azaltmalıdır.)*

Prolonged gyro-only heading must reduce heading confidence. *(Uzayan yalnızca jiroskop yönü yön güvenini azaltmalıdır.)*

Uncorrected PDR operation must not falsely increase confidence with time. *(Düzeltilmemiş PDR çalışması zamanla güveni yanlış şekilde artırmamalıdır.)*

---

# 141. Acceptance Criteria — Recovery (Kabul Kriterleri — Geri Kazanım)

A degraded source must not recover to full confidence from one isolated good sample unless the frozen source profile explicitly justifies that behavior. *(Bozulmuş bir kaynak sabitlenmiş kaynak profili açıkça bu davranışı gerekçelendirmedikçe tek izole iyi örnekten tam güvene dönmemelidir.)*

Recovery transitions must be logged. *(Geri kazanım geçişleri kaydedilmelidir.)*

---

# 142. Acceptance Criteria — Experiment Integrity (Kabul Kriterleri — Deney Bütünlüğü)

GNSS ground truth must not influence live NAVGUARD quality decisions during the protected denied interval. *(GNSS ground truth korunan kesintili aralık sırasında canlı NAVGUARD kalite kararlarını etkilememelidir.)*

Quality configurations must remain frozen during one formal benchmark. *(Kalite yapılandırmaları tek bir resmî benchmark sırasında sabit kalmalıdır.)*

Historical quality output must remain reproducible from stored data and configuration where practical. *(Geçmiş kalite çıktısı uygulanabilir olduğunda saklanan veri ve yapılandırmadan yeniden üretilebilir kalmalıdır.)*

---

# 143. Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kararlar)

NAVGUARD will implement a common Sensor Confidence & Quality Engine above subsystem-specific validation. *(NAVGUARD alt sisteme özgü doğrulamanın üzerinde ortak bir Sensör Güven ve Kalite Motoru geliştirecektir.)*

Quality and availability will be represented separately. *(Kalite ve kullanılabilirlik ayrı temsil edilecektir.)*

The common quality states will include `UNKNOWN`, `GOOD`, `USABLE`, `DEGRADED`, `UNRELIABLE`, and `UNAVAILABLE`. *(Ortak kalite durumları `UNKNOWN`, `GOOD`, `USABLE`, `DEGRADED`, `UNRELIABLE` ve `UNAVAILABLE` durumlarını içerecektir.)*

---

# 144. Additional Frozen Decisions (Ek Sabitlenmiş Kararlar)

Quality decisions will preserve reason flags. *(Kalite kararları neden flag’lerini koruyacaktır.)*

Hard-invalid measurements will be rejected rather than merely assigned low confidence. *(Sert geçersiz ölçümler yalnızca düşük güven atanmak yerine reddedilecektir.)*

Confidence will not be treated as calibrated probability without evidence. *(Güven kanıt olmadan kalibre edilmiş olasılık olarak ele alınmayacaktır.)*

Authorization will always precede confidence evaluation. *(Yetkilendirme her zaman güven değerlendirmesinden önce gelecektir.)*

---

# 145. Further Frozen Decisions (Diğer Sabitlenmiş Kararlar)

Magnetometer quality will directly influence magnetic heading correction. *(Manyetometre kalitesi manyetik yön düzeltmesini doğrudan etkileyecektir.)*

ARCore quality will directly control whether ARCore measurements may enter fusion. *(ARCore kalitesi ARCore ölçümlerinin füzyona girip giremeyeceğini doğrudan kontrol edecektir.)*

PDR confidence will generally decrease during prolonged uncorrected navigation. *(PDR güveni uzun süreli düzeltilmemiş navigasyon sırasında genel olarak azalacaktır.)*

Recovery behavior will use hysteresis where appropriate. *(Geri kazanım davranışı uygun olduğunda hysteresis kullanacaktır.)*

---

# 146. Fusion Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Füzyon Kararları)

The quality engine may influence EKF measurement covariance. *(Kalite motoru EKF ölçüm kovaryansını etkileyebilir.)*

The exact confidence-to-covariance relationship will require empirical calibration. *(Kesin güven-kovaryans ilişkisi ampirik kalibrasyon gerektirecektir.)*

Invalid measurements will be rejected before covariance scaling. *(Geçersiz ölçümler kovaryans ölçeklemeden önce reddedilecektir.)*

---

# 147. Ground Truth Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Ground Truth Kararları)

GNSS ground truth may be used offline to evaluate quality calibration. *(GNSS ground truth kalite kalibrasyonunu değerlendirmek için çevrimdışı kullanılabilir.)*

GNSS ground truth will not be used as a hidden live quality signal during GNSS-denied evaluation. *(GNSS ground truth GNSS kesintili değerlendirme sırasında gizli canlı kalite sinyali olarak kullanılmayacaktır.)*

---

# 148. Decisions Pending Measurement (Ölçüm Bekleyen Kararlar)

Final accelerometer timing thresholds remain pending Device Capability Audit results. *(Nihai ivmeölçer zamanlama eşikleri Cihaz Yetenek Denetimi sonuçlarını beklemektedir.)*

Final magnetometer disturbance thresholds remain pending field measurements. *(Nihai manyetometre bozulma eşikleri saha ölçümlerini beklemektedir.)*

Final gyro-confidence decay remains pending measured drift. *(Nihai jiroskop güven azalması ölçülmüş sürüklenmeyi beklemektedir.)*

Final PDR confidence decay remains pending route experiments. *(Nihai PDR güven azalması rota deneylerini beklemektedir.)*

---

# 149. Additional Pending Decisions (Ek Bekleyen Kararlar)

Final ARCore pose-continuity thresholds remain pending ARCore experiments. *(Nihai ARCore poz süreklilik eşikleri ARCore deneylerini beklemektedir.)*

Final freshness limits remain pending measured source update rates. *(Nihai güncellik sınırları ölçülen kaynak güncelleme hızlarını beklemektedir.)*

Final quality-state boundaries remain pending pilot data. *(Nihai kalite durum sınırları pilot veriyi beklemektedir.)*

Final confidence-to-covariance mappings remain pending EKF calibration. *(Nihai güven-kovaryans eşlemeleri EKF kalibrasyonunu beklemektedir.)*

---

# 150. Minimum Implementation Priority (Minimum Uygulama Önceliği)

The quality engine is a SHOULD-level enhancement for the complete NAVGUARD architecture but basic source validity gates are mandatory. *(Kalite motoru tam NAVGUARD mimarisi için SHOULD seviyesinde bir iyileştirmedir ancak temel kaynak geçerlilik kapıları zorunludur.)*

If schedule pressure occurs, mandatory hard gates will be implemented before advanced continuous-confidence scoring. *(Takvim baskısı oluşursa gelişmiş sürekli güven skorlamasından önce zorunlu sert kapılar geliştirilecektir.)*

---

# 151. Minimum Fallback Version (Minimum Geri Dönüş Sürümü)

A minimum quality implementation may operate using only categorical source states and reason flags. *(Minimum kalite uygulaması yalnızca kategorik kaynak durumları ve neden flag’lerini kullanarak çalışabilir.)*

`text id="fuxo2m" GOOD DEGRADED UNAVAILABLE`

Continuous confidence can be added later without changing subsystem interfaces. *(Sürekli güven daha sonra alt sistem arayüzlerini değiştirmeden eklenebilir.)*

---

# 152. Target Research Version (Hedef Araştırma Sürümü)

The target research version will combine categorical quality, continuous confidence, hysteresis, cross-sensor evidence, and empirically calibrated fusion uncertainty. *(Hedef araştırma sürümü kategorik kaliteyi, sürekli güveni, hysteresis’i, sensörler arası kanıtı ve ampirik olarak kalibre edilmiş füzyon belirsizliğini birleştirecektir.)*

---

# 153. Final Quality Architecture Statement (Nihai Kalite Mimarisi Bildirimi)

**NAVGUARD will use a shared Sensor Confidence & Quality Engine to describe how trustworthy each currently available navigation source is before that source can influence sensor fusion.** *(NAVGUARD mevcut her navigasyon kaynağının sensör füzyonunu etkilemeden önce ne kadar güvenilir olduğunu açıklamak için ortak bir Sensör Güven ve Kalite Motoru kullanacaktır.)*

**The engine will evaluate source-specific evidence including availability, freshness, timing stability, numerical validity, continuity, environmental reliability, and cross-sensor consistency while preserving the reasons behind every important degradation decision.** *(Motor her önemli bozulma kararının arkasındaki nedenleri korurken kullanılabilirlik, güncellik, zamanlama kararlılığı, sayısal geçerlilik, süreklilik, çevresel güvenilirlik ve sensörler arası tutarlılık dahil olmak üzere kaynağa özgü kanıtları değerlendirecektir.)*

**Hard-invalid measurements will be rejected before fusion, while partially degraded but still useful measurements may remain available with reduced confidence and increased uncertainty.** *(Sert geçersiz ölçümler füzyondan önce reddedilirken kısmen bozulmuş ancak hâlâ kullanışlı ölçümler azaltılmış güven ve artırılmış belirsizlikle kullanılabilir kalabilir.)*

**Confidence will decay when evidence becomes weaker, recover only after sufficient valid observations, and use hysteresis where necessary to prevent unstable quality-state oscillation.** *(Kanıt zayıfladığında güven azalacak, yalnızca yeterli geçerli gözlem sonrasında geri kazanılacak ve kararsız kalite durumu salınımını önlemek için gerektiğinde hysteresis kullanılacaktır.)*

**The quality engine may influence EKF measurement covariance, but no final confidence-to-covariance mapping will be accepted until physical experiments demonstrate a measurable relationship between source diagnostics and navigation error.** *(Kalite motoru EKF ölçüm kovaryansını etkileyebilir ancak fiziksel deneyler kaynak tanıları ile navigasyon hatası arasında ölçülebilir bir ilişki gösterene kadar hiçbir nihai güven-kovaryans eşlemesi kabul edilmeyecektir.)*

**GNSS ground truth will remain isolated from live quality decisions during GNSS-denied Evaluation Mode so that confidence adaptation cannot become an indirect path for reference-data leakage into the estimator.** *(GNSS ground truth GNSS kesintili Değerlendirme Modu sırasında canlı kalite kararlarından izole kalacak; böylece güven adaptasyonu referans verisinin tahmin motoruna dolaylı sızıntı yolu haline gelemeyecektir.)*

---

# 154. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development Sensor Confidence & Quality Architecture Completed *(Doküman Durumu: Geliştirme Öncesi Sensör Güven ve Kalite Mimarisi Tamamlandı)*

**Primary Role:** Common Measurement Quality Layer *(Temel Rol: Ortak Ölçüm Kalite Katmanı)*

**Common Quality States:** `UNKNOWN / GOOD / USABLE / DEGRADED / UNRELIABLE / UNAVAILABLE` *(Ortak Kalite Durumları: `UNKNOWN / GOOD / USABLE / DEGRADED / UNRELIABLE / UNAVAILABLE`)*

**Continuous Confidence:** Target Capability *(Sürekli Güven: Hedef Yetenek)*

**Confidence Interpretation:** Relative Trust, Not Automatically Probability *(Güven Yorumu: Göreli Güven, Otomatik Olarak Olasılık Değil)*

**Hard Invalid Data:** Rejected Before Fusion *(Sert Geçersiz Veri: Füzyondan Önce Reddedilir)*

**Freshness Monitoring:** Mandatory *(Güncellik İzleme: Zorunlu)*

**Timing Quality Monitoring:** Mandatory *(Zamanlama Kalitesi İzleme: Zorunlu)*

**Reason Flags:** Mandatory for Important Degradation *(Neden Flag’leri: Önemli Bozulmalar İçin Zorunlu)*

**Magnetometer Quality:** Controls Magnetic Correction *(Manyetometre Kalitesi: Manyetik Düzeltmeyi Kontrol Eder)*

**ARCore Quality:** Controls ARCore Fusion Eligibility *(ARCore Kalitesi: ARCore Füzyon Uygunluğunu Kontrol Eder)*

**Gyroscope Confidence:** Decays Without Absolute Correction *(Jiroskop Güveni: Mutlak Düzeltme Olmadan Azalır)*

**PDR Confidence:** Generally Decreases During Uncorrected Propagation *(PDR Güveni: Düzeltilmemiş İlerletme Sırasında Genel Olarak Azalır)*

**Recovery Strategy:** Hysteresis-Based Where Appropriate *(Geri Kazanım Stratejisi: Uygun Olduğunda Hysteresis Tabanlı)*

**EKF Integration:** Quality-Aware Measurement Covariance *(EKF Entegrasyonu: Kalite Farkındalıklı Ölçüm Kovaryansı)*

**GNSS Ground Truth Leakage:** Forbidden *(GNSS Ground Truth Sızıntısı: Yasak)*

**Final Quality Thresholds:** Pending Device and Field Measurements *(Nihai Kalite Eşikleri: Cihaz ve Saha Ölçümleri Bekleniyor)*

**Final Confidence Calibration:** Pending Experimental Error Analysis *(Nihai Güven Kalibrasyonu: Deneysel Hata Analizi Bekleniyor)*

**Final Covariance Mapping:** Pending EKF Calibration *(Nihai Kovaryans Eşlemesi: EKF Kalibrasyonu Bekleniyor)*

**Next Documentation Item:** 21 — Sensor Fusion & Extended Kalman Filter *(Sonraki Dokümantasyon Öğesi: 21 — Sensör Füzyonu ve Genişletilmiş Kalman Filtresi)*
