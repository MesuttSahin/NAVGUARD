# 18 — Heading Estimation System (Yön Tahmin Sistemi)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the heading-estimation architecture, magnetic-heading calculation, tilt compensation, gyroscope-based short-term propagation, magnetic-declination correction, rotation-vector usage, magnetic-disturbance detection, circular-angle processing, heading confidence, phone-placement alignment, fallback behavior, evaluation methodology, logging requirements, and acceptance criteria of NAVGUARD. *(Bu doküman, NAVGUARD’ın yön tahmin mimarisini, manyetik yön hesabını, tilt compensation işlemini, jiroskop tabanlı kısa dönem ilerletmeyi, manyetik sapma düzeltmesini, rotation-vector kullanımını, manyetik bozulma tespitini, dairesel açı işlemeyi, yön güvenini, telefon yerleşim hizalamasını, geri dönüş davranışını, değerlendirme metodolojisini, kayıt gereksinimlerini ve kabul kriterlerini tanımlar.)*

The Heading Estimation System provides the true-north-referenced direction required by step-based PDR. *(Yön Tahmin Sistemi adım tabanlı PDR’nin ihtiyaç duyduğu gerçek kuzey referanslı yönü sağlar.)*

Heading estimation is considered a critical navigation subsystem because even small persistent directional errors rotate every subsequent PDR displacement vector. *(Yön tahmini kritik bir navigasyon alt sistemi olarak kabul edilir çünkü küçük kalıcı yön hataları bile sonraki her PDR yer değiştirme vektörünü döndürür.)*

---

# 2. Primary Heading Objective (Temel Yön Hedefi)

NAVGUARD will estimate the horizontal travel direction of the pedestrian relative to true north. *(NAVGUARD yayanın yatay hareket yönünü gerçek kuzeye göre tahmin edecektir.)*

The resulting navigation heading will use the convention defined in **14 — Coordinate Systems & Mathematical Foundations**. *(Ortaya çıkan navigasyon yönü **14 — Coordinate Systems & Mathematical Foundations** içerisinde tanımlanan kuralı kullanacaktır.)*

```
0°   = North
      (Kuzey)

90°  = East
      (Doğu)

180° = South
      (Güney)

270° = West
      (Batı)
```

Heading will increase clockwise from true north. *(Yön gerçek kuzeyden saat yönünde artacaktır.)*

---

# 3. Heading Symbol (Yön Sembolü)

Navigation heading will normally be represented by `ψ`. *(Navigasyon yönü normalde `ψ` ile temsil edilecektir.)*

```
ψ ∈ [0, 2π)
```

Internal mathematical calculations will normally use radians. *(Dahili matematiksel hesaplamalar normalde radyan kullanacaktır.)*

User-facing diagnostic values may additionally be displayed in degrees. *(Kullanıcıya yönelik tanısal değerler ayrıca derece cinsinden gösterilebilir.)*

---

# 4. Heading System Role in PDR (PDR İçerisinde Yön Sisteminin Rolü)

For every accepted pedestrian step, PDR requires a heading corresponding to the physical time of that step. *(Kabul edilmiş her yaya adımı için PDR, o adımın fiziksel zamanına karşılık gelen bir yöne ihtiyaç duyar.)*

```
Accepted Step
     +
Step Length
     +
True-North Heading
     ↓
ΔE / ΔN
```

The Heading Estimation System will provide that directional input without directly modifying PDR position. *(Yön Tahmin Sistemi PDR konumunu doğrudan değiştirmeden bu yönsel girdiyi sağlayacaktır.)*

---

# 5. Heading Estimation Architecture (Yön Tahmin Mimarisi)

```
Accelerometer ───────────┐
                         │
Magnetometer ────────────┼──► Absolute Magnetic Orientation
                         │    (Mutlak Manyetik Yönelim)
                         │
Gyroscope ───────────────┼──► Short-Term Rotation Propagation
                         │    (Kısa Dönem Dönüş İlerletmesi)
                         │
Rotation Vector ─────────┼──► Reference / Fallback / Comparison
                         │    (Referans / Geri Dönüş / Karşılaştırma)
                         │
GNSS Anchor + Time ──────┼──► Magnetic Declination
                         │    (Manyetik Sapma)
                         ▼
                  Heading Fusion
                  (Yön Füzyonu)
                         ↓
                 Placement Alignment
                 (Yerleşim Hizalaması)
                         ↓
                 True-North Heading
                 (Gerçek Kuzey Yönü)
                         ↓
                        PDR
```

---

# 6. Primary Physical Sensors (Temel Fiziksel Sensörler)

The primary physical sensors for NAVGUARD heading estimation will be the gyroscope, magnetometer, and accelerometer. *(NAVGUARD yön tahmini için temel fiziksel sensörler jiroskop, manyetometre ve ivmeölçer olacaktır.)*

The accelerometer primarily contributes gravity-direction information for tilt compensation. *(İvmeölçer temel olarak tilt compensation için yerçekimi yönü bilgisine katkıda bulunur.)*

The magnetometer provides an Earth-referenced magnetic direction. *(Manyetometre Dünya referanslı manyetik yön sağlar.)*

The gyroscope provides rapid relative rotational information. *(Jiroskop hızlı göreli dönüş bilgisi sağlar.)*

---

# 7. Android Rotation Vector Role (Android Rotation Vector Rolü)

`TYPE_ROTATION_VECTOR` will be recorded when it is available on the Redmi Note 9 Pro. *(`TYPE_ROTATION_VECTOR`, Redmi Note 9 Pro üzerinde mevcut olduğunda kaydedilecektir.)*

Android defines the rotation vector as a representation of device orientation relative to an Earth-related reference frame whose horizontal Y axis points toward magnetic north. *(Android rotation vector’ü yatay Y ekseni manyetik kuzeye doğru yönelen Dünya ile ilişkili bir referans çerçevesine göre cihaz yöneliminin temsili olarak tanımlar.)*

Rotation-vector output will initially serve as a comparison, fallback, and possible target-fusion input rather than being treated as an unexplained ground-truth orientation. *(Rotation-vector çıktısı başlangıçta açıklanamayan gerçek referans yönelimi olarak ele alınmak yerine karşılaştırma, geri dönüş ve olası hedef füzyon girdisi olarak kullanılacaktır.)*

---

# 8. Why Android Rotation Vector Is Not Ground Truth (Android Rotation Vector Neden Gerçek Referans Değildir)

The Android rotation vector is itself a sensor-fusion output produced by the device platform. *(Android rotation vector cihaz platformu tarafından üretilen bir sensör füzyonu çıktısıdır.)*

Its internal vendor-specific implementation is not controlled by NAVGUARD. *(Dahili üreticiye özgü uygulaması NAVGUARD tarafından kontrol edilmez.)*

It may therefore provide an excellent practical orientation source without serving as independent scientific ground truth for NAVGUARD’s own heading algorithm. *(Bu nedenle NAVGUARD’ın kendi yön algoritması için bağımsız bilimsel gerçek referans olmadan mükemmel bir pratik yönelim kaynağı sağlayabilir.)*

---

# 9. Game Rotation Vector Role (Game Rotation Vector Rolü)

`TYPE_GAME_ROTATION_VECTOR` will be recorded when available for relative-rotation experiments. *(`TYPE_GAME_ROTATION_VECTOR`, göreli dönüş deneyleri için mevcut olduğunda kaydedilecektir.)*

Android specifies that the game rotation vector does not use the geomagnetic field and therefore does not maintain a north-referenced Y axis. *(Android game rotation vector’ün jeomanyetik alanı kullanmadığını ve bu nedenle kuzey referanslı bir Y eksenini korumadığını belirtir.)*

Its heading reference is allowed to drift approximately with gyroscope drift. *(Yön referansının yaklaşık olarak jiroskop sürüklenmesiyle birlikte sürüklenmesine izin verilir.)*

It will therefore not be used alone as an absolute true-north heading source. *(Bu nedenle tek başına mutlak gerçek kuzey yön kaynağı olarak kullanılmayacaktır.)*

---

# 10. Geomagnetic Rotation Vector Role (Jeomanyetik Rotation Vector Rolü)

`TYPE_GEOMAGNETIC_ROTATION_VECTOR` may be recorded when available. *(`TYPE_GEOMAGNETIC_ROTATION_VECTOR`, mevcut olduğunda kaydedilebilir.)*

Android describes this sensor as similar to the normal rotation vector but using the magnetometer instead of the gyroscope. *(Android bu sensörü normal rotation vector’e benzer ancak jiroskop yerine manyetometre kullanan bir sensör olarak tanımlar.)*

Android also notes that it consumes less power but is generally noisier and works best outdoors. *(Android ayrıca daha az güç tükettiğini ancak genel olarak daha gürültülü olduğunu ve en iyi dış mekânda çalıştığını belirtir.)*

It will remain an optional comparison source rather than a mandatory dependency. *(Zorunlu bağımlılık yerine isteğe bağlı karşılaştırma kaynağı olarak kalacaktır.)*

---

# 11. Deprecated Android Orientation Sensor Policy (Deprecated Android Yönelim Sensörü Politikası)

NAVGUARD will not depend on Android’s deprecated `TYPE_ORIENTATION` sensor. *(NAVGUARD Android’in deprecated `TYPE_ORIENTATION` sensörüne bağımlı olmayacaktır.)*

Android deprecated `TYPE_ORIENTATION` and recommends orientation computation through newer sensor APIs such as `SensorManager.getOrientation()`. *(Android `TYPE_ORIENTATION` sensörünü deprecated etmiş ve yönelim hesabı için `SensorManager.getOrientation()` gibi daha yeni sensör API’lerini önermiştir.)*

---

# 12. Baseline Heading Configuration (Temel Yön Yapılandırması)

The initial transparent baseline heading method will use accelerometer and magnetometer measurements to calculate a tilt-compensated magnetic azimuth. *(İlk şeffaf temel yön yöntemi tilt telafili manyetik azimut hesaplamak için ivmeölçer ve manyetometre ölçümlerini kullanacaktır.)*

Magnetic declination will then convert this result from magnetic north to true north. *(Manyetik sapma daha sonra bu sonucu manyetik kuzeyden gerçek kuzeye dönüştürecektir.)*

This creates a deterministic and inspectable Configuration A heading baseline. *(Bu deterministik ve incelenebilir bir Yapılandırma A yön temeli oluşturur.)*

---

# 13. Target Heading Configuration (Hedef Yön Yapılandırması)

The target heading system will combine short-term gyroscope stability with long-term Earth-referenced magnetic correction. *(Hedef yön sistemi kısa dönem jiroskop kararlılığını uzun dönem Dünya referanslı manyetik düzeltmeyle birleştirecektir.)*

Magnetic corrections will be weakened or rejected when magnetic quality is poor. *(Manyetik kalite düşük olduğunda manyetik düzeltmeler zayıflatılacak veya reddedilecektir.)*

Rotation-vector outputs may be used for comparison, fallback, initialization, or additional validation where experiments demonstrate value. *(Rotation-vector çıktıları deneyler fayda gösterdiğinde karşılaştırma, geri dönüş, başlatma veya ek doğrulama için kullanılabilir.)*

---

# 14. Heading Configuration Comparison (Yön Yapılandırma Karşılaştırması)

| Configuration (Yapılandırma) | Heading Strategy (Yön Stratejisi) |
| --- | --- |
| A — Baseline PDR *(Temel PDR)* | Tilt-compensated accelerometer + magnetometer heading with declination correction. *(Tilt telafili ivmeölçer + manyetometre yönü ve sapma düzeltmesi.)* |
| B — Improved Heading *(Geliştirilmiş Yön)* | Gyroscope propagation with quality-controlled magnetic correction. *(Kalite kontrollü manyetik düzeltmeyle jiroskop ilerletmesi.)* |
| C — PDR + ARCore | Configuration A baseline heading, unchanged, plus validated ARCore relative tracking. Configuration B improved/fused heading remains off. *(Configuration A baseline heading'i değiştirilmeden korunur ve doğrulanmış ARCore relative tracking eklenir. Configuration B improved/fused heading'i kapalı kalır.)* |
| D — Full NAVGUARD *(Tam NAVGUARD)* | Final validated heading integrated with confidence-aware fusion. *(Güven farkındalıklı füzyona entegre edilmiş nihai doğrulanmış yön.)* |

---

# 15. Magnetic Heading Principle (Manyetik Yön İlkesi)

A smartphone magnetometer measures the local magnetic-field vector in the device coordinate frame. *(Bir akıllı telefon manyetometresi yerel manyetik alan vektörünü cihaz koordinat çerçevesinde ölçer.)*

The raw magnetic X and Y values must not be converted directly into a navigation heading without accounting for device tilt. *(Ham manyetik X ve Y değerleri cihaz eğimini dikkate almadan doğrudan navigasyon yönüne dönüştürülmemelidir.)*

---

# 16. Why Tilt Compensation Is Required (Tilt Compensation Neden Gereklidir)

A pedestrian will not necessarily hold the smartphone perfectly horizontal. *(Bir yaya akıllı telefonu her zaman tamamen yatay tutmayacaktır.)*

Pitch and roll change the projection of Earth’s magnetic field onto the device axes. *(Pitch ve roll Dünya’nın manyetik alanının cihaz eksenlerine izdüşümünü değiştirir.)*

A naive two-axis compass can therefore produce incorrect heading while the device is tilted. *(Bu nedenle basit iki eksenli pusula cihaz eğildiğinde yanlış yön üretebilir.)*

---

# 17. Android Rotation Matrix for Tilt Compensation (Tilt Compensation İçin Android Dönüş Matrisi)

Android provides `SensorManager.getRotationMatrix()` using gravity and geomagnetic vectors. *(Android yerçekimi ve jeomanyetik vektörleri kullanarak `SensorManager.getRotationMatrix()` sağlar.)*

The resulting matrix transforms device-frame vectors into an Android world frame whose X axis points approximately East, Y points toward magnetic North, and Z points toward the sky. *(Ortaya çıkan matris cihaz çerçevesi vektörlerini X ekseni yaklaşık Doğu’ya, Y ekseni manyetik Kuzey’e ve Z ekseni gökyüzüne yönelen Android dünya çerçevesine dönüştürür.)*

This mechanism will provide the initial deterministic tilt-compensated magnetic orientation baseline. *(Bu mekanizma ilk deterministik tilt telafili manyetik yönelim temelini sağlayacaktır.)*

---

# 18. Android Magnetic World Frame (Android Manyetik Dünya Çerçevesi)

The Android magnetic world frame is not identical to NAVGUARD’s true-north ENU frame. *(Android manyetik dünya çerçevesi NAVGUARD’ın gerçek kuzeyli ENU çerçevesiyle aynı değildir.)*

Android’s world-frame Y axis references magnetic north. *(Android dünya çerçevesinin Y ekseni manyetik kuzeye referans verir.)*

NAVGUARD’s navigation-frame Y axis references true north. *(NAVGUARD navigasyon çerçevesinin Y ekseni gerçek kuzeye referans verir.)*

A declination correction is therefore required. *(Bu nedenle sapma düzeltmesi gereklidir.)*

---

# 19. Android Magnetic Azimuth (Android Manyetik Azimut)

Android `SensorManager.getOrientation()` computes orientation angles from a rotation matrix. *(Android `SensorManager.getOrientation()` bir dönüş matrisinden yönelim açılarını hesaplar.)*

Its first output value is azimuth about the vertical axis and represents the angle between the device Y axis and magnetic north. *(İlk çıktı değeri dikey eksen çevresindeki azimuttur ve cihaz Y ekseni ile manyetik kuzey arasındaki açıyı temsil eder.)*

Android documents approximately `0` for North, `π/2` for East, `π` for South, and `-π/2` for West. *(Android yaklaşık olarak Kuzey için `0`, Doğu için `π/2`, Güney için `π` ve Batı için `-π/2` değerlerini dokümante eder.)*

---

# 20. Baseline Magnetic Heading (Temel Manyetik Yön)

The baseline magnetic heading may therefore be obtained from the Android tilt-compensated orientation calculation. *(Bu nedenle temel manyetik yön Android tilt telafili yönelim hesabından elde edilebilir.)*

```
ψ_mag =
normalize0To2Pi(azimuthAndroid)
```

The resulting value still references magnetic north. *(Ortaya çıkan değer hâlâ manyetik kuzeye referans verir.)*

---

# 21. Rotation Matrix Failure Handling (Dönüş Matrisi Başarısızlık Yönetimi)

`SensorManager.getRotationMatrix()` can fail when the required physical vectors are unsuitable for a valid orientation solution. *(`SensorManager.getRotationMatrix()`, gerekli fiziksel vektörler geçerli bir yönelim çözümü için uygun olmadığında başarısız olabilir.)*

Android also warns that strong acceleration or strong magnetic fields may make the resulting matrices inaccurate. *(Android ayrıca güçlü ivme veya güçlü manyetik alanların ortaya çıkan matrisleri hatalı hale getirebileceğini belirtir.)*

NAVGUARD will treat a failed or low-quality magnetic orientation calculation as unavailable rather than force a heading value. *(NAVGUARD başarısız veya düşük kaliteli manyetik yönelim hesabını yön değeri üretmeye zorlamak yerine kullanılamaz olarak ele alacaktır.)*

---

# 22. Magnetic Declination (Manyetik Sapma)

Magnetic declination is the horizontal angular difference between magnetic north and true north. *(Manyetik sapma manyetik kuzey ile gerçek kuzey arasındaki yatay açısal farktır.)*

NAVGUARD will obtain a declination estimate using Android `GeomagneticField`. *(NAVGUARD Android `GeomagneticField` kullanarak sapma tahmini elde edecektir.)*

Android defines positive declination as magnetic north being rotated eastward from true north. *(Android pozitif sapmayı manyetik kuzeyin gerçek kuzeyden doğuya doğru dönmüş olması şeklinde tanımlar.)*

---

# 23. Declination Inputs (Sapma Girdileri)

Android `GeomagneticField` evaluates the geomagnetic field using geographic position, altitude, and time. *(Android `GeomagneticField` coğrafi konum, yükseklik ve zamanı kullanarak jeomanyetik alanı değerlendirir.)*

NAVGUARD will normally use the accepted GNSS anchor position and session time when initializing declination. *(NAVGUARD sapmayı başlatırken normalde kabul edilmiş GNSS çapa konumunu ve oturum zamanını kullanacaktır.)*

If valid altitude is unavailable, an explicitly documented fallback altitude will be required by the implementation rather than silently fabricating a measured altitude. *(Geçerli yükseklik mevcut değilse uygulama ölçülmüş yükseklik uydurmak yerine açıkça dokümante edilmiş bir fallback yükseklik kullanacaktır.)*

---

# 24. Magnetic-to-True Heading Conversion (Manyetik Yönden Gerçek Yöne Dönüşüm)

The initial conversion will use the following convention. *(İlk dönüşüm aşağıdaki kuralı kullanacaktır.)*

```
ψ_true =
normalize0To2Pi(
    ψ_mag + δ
)
```

`δ` represents Android magnetic declination converted to radians. *(`δ`, radyana dönüştürülmüş Android manyetik sapmasını temsil eder.)*

The sign will be verified through controlled cardinal-direction testing before the formal benchmark configuration is frozen. *(İşaret resmî benchmark yapılandırması sabitlenmeden önce kontrollü ana yön testleriyle doğrulanacaktır.)*

---

# 25. Declination Update Policy (Sapma Güncelleme Politikası)

Declination changes slowly relative to a short pedestrian experiment. *(Sapma kısa bir yaya deneyine göre yavaş değişir.)*

The initial target policy will therefore calculate declination at the accepted GNSS anchor and reuse it during the associated short GNSS-denied segment. *(Bu nedenle ilk hedef politika sapmayı kabul edilmiş GNSS çapasında hesaplayacak ve ilişkili kısa GNSS kesintili segment sırasında yeniden kullanacaktır.)*

A new value may be calculated after a formal re-anchor or sufficiently large geographic change. *(Resmî yeniden çapalama veya yeterince büyük coğrafi değişiklik sonrasında yeni bir değer hesaplanabilir.)*

---

# 26. Gyroscope Role (Jiroskop Rolü)

The gyroscope measures device angular velocity. *(Jiroskop cihazın açısal hızını ölçer.)*

It reacts quickly to turns and is not directly disturbed by local magnetic anomalies. *(Dönüşlere hızlı tepki verir ve yerel manyetik anomalilerden doğrudan etkilenmez.)*

It does not provide an absolute north reference by itself. *(Tek başına mutlak kuzey referansı sağlamaz.)*

---

# 27. Gyroscope Units (Jiroskop Birimleri)

NAVGUARD will represent gyroscope angular velocity in radians per second. *(NAVGUARD jiroskop açısal hızını radyan/saniye cinsinden temsil edecektir.)*

```
ωᴰ =
[ω_x, ω_y, ω_z]ᵀ
```

Actual integration will use sensor timestamps rather than assume a perfectly constant sampling period. *(Gerçek integrasyon tam sabit örnekleme periyodu varsaymak yerine sensör zaman damgalarını kullanacaktır.)*

---

# 28. Gyroscope Bias (Jiroskop Bias’ı)

A stationary gyroscope may report small nonzero angular velocity. *(Sabit bir jiroskop küçük sıfır olmayan açısal hız raporlayabilir.)*

Persistent bias accumulates into orientation drift during integration. *(Kalıcı bias integrasyon sırasında yönelim sürüklenmesine birikir.)*

NAVGUARD will estimate an initial gyroscope bias from a validated stationary interval when practical. *(NAVGUARD uygulanabilir olduğunda doğrulanmış bir sabit dönemden başlangıç jiroskop bias’ını tahmin edecektir.)*

---

# 29. Gyroscope Bias Correction (Jiroskop Bias Düzeltmesi)

A simple stationary bias estimate may use the mean measured angular velocity. *(Basit sabit durum bias tahmini ortalama ölçülen açısal hızı kullanabilir.)*

```
b_g =
mean(ω_stationary)
```

Corrected angular velocity may then be represented as follows. *(Düzeltilmiş açısal hız daha sonra aşağıdaki şekilde temsil edilebilir.)*

```
ω_corrected =
ω_raw - b_g
```

---

# 30. Gyroscope Heading Propagation (Jiroskop Yön İlerletmesi)

For a simplified horizontal representation, short-term heading propagation may conceptually use the following relation. *(Basitleştirilmiş yatay temsil için kısa dönem yön ilerletmesi kavramsal olarak aşağıdaki ilişkiyi kullanabilir.)*

```
ψ_pred,k =
normalize(
    ψ_(k-1) + Δψ_gyro,k
)
```

The actual `Δψ_gyro` calculation must respect full device orientation rather than assume that raw device Z angular velocity always equals pedestrian yaw. *(Gerçek `Δψ_gyro` hesabı ham cihaz Z açısal hızının her zaman yaya yaw değerine eşit olduğunu varsaymak yerine tam cihaz yönelimini dikkate almalıdır.)*

---

# 31. Why Raw `ω_z` Is Not Always Heading Rate (Ham `ω_z` Neden Her Zaman Yön Değişim Hızı Değildir)

The smartphone may be tilted relative to the local vertical axis. *(Akıllı telefon yerel dikey eksene göre eğilmiş olabilir.)*

Raw device-frame Z rotation therefore does not universally equal rotation about the Earth Up axis. *(Bu nedenle ham cihaz çerçevesi Z dönüşü evrensel olarak Dünya Yukarı ekseni çevresindeki dönüşe eşit değildir.)*

A robust target implementation will use full attitude or an equivalent coordinate transformation before extracting horizontal heading change. *(Robust hedef uygulama yatay yön değişimini çıkarmadan önce tam attitude veya eşdeğer koordinat dönüşümü kullanacaktır.)*

---

# 32. Quaternion-Based Gyroscope Integration Candidate (Quaternion Tabanlı Jiroskop Integrasyonu Adayı)

The target orientation implementation may integrate gyroscope measurements through quaternion propagation. *(Hedef yönelim uygulaması jiroskop ölçümlerini quaternion ilerletmesi üzerinden integre edebilir.)*

A continuous quaternion relation can be represented conceptually as follows. *(Sürekli quaternion ilişkisi kavramsal olarak aşağıdaki şekilde temsil edilebilir.)*

```
q_dot =
1/2 · q ⊗ Ω(ω)
```

A numerically appropriate discrete update will be implemented and normalized after integration. *(Sayısal olarak uygun bir ayrık güncelleme geliştirilecek ve integrasyondan sonra normalize edilecektir.)*

---

# 33. Quaternion Normalization (Quaternion Normalizasyonu)

Every integrated orientation quaternion must remain approximately unit length. *(İntegre edilen her yönelim quaternion’ı yaklaşık birim uzunlukta kalmalıdır.)*

```
q_normalized =
q / ||q||
```

Near-zero or invalid quaternion values must be rejected. *(Sıfıra yakın veya geçersiz quaternion değerleri reddedilmelidir.)*

---

# 34. Gyroscope Strength (Jiroskop Güçlü Yönü)

The gyroscope is expected to provide smooth and responsive short-term turn information. *(Jiroskobun düzgün ve hızlı tepki veren kısa dönem dönüş bilgisi sağlaması beklenir.)*

It is particularly useful during rapid turns where magnetometer readings may be temporarily noisy. *(Özellikle manyetometre ölçümlerinin geçici olarak gürültülü olabileceği hızlı dönüşlerde kullanışlıdır.)*

---

# 35. Gyroscope Limitation (Jiroskop Sınırlaması)

Gyroscope integration accumulates bias and noise over time. *(Jiroskop integrasyonu zaman içerisinde bias ve gürültü biriktirir.)*

A gyroscope-only heading cannot remain permanently aligned with true north without an external absolute reference. *(Yalnızca jiroskopa dayalı yön harici mutlak referans olmadan gerçek kuzeyle kalıcı olarak hizalı kalamaz.)*

---

# 36. Magnetometer Strength (Manyetometre Güçlü Yönü)

The magnetometer provides an absolute Earth-related horizontal reference. *(Manyetometre Dünya ile ilişkili mutlak yatay referans sağlar.)*

It can therefore correct long-term gyroscope heading drift when magnetic conditions are trustworthy. *(Bu nedenle manyetik koşullar güvenilir olduğunda uzun dönem jiroskop yön sürüklenmesini düzeltebilir.)*

---

# 37. Magnetometer Limitation (Manyetometre Sınırlaması)

Magnetic measurements can be disturbed by nearby ferromagnetic materials, electronics, vehicles, buildings, and other local sources. *(Manyetik ölçümler yakındaki ferromanyetik malzemeler, elektronik cihazlar, araçlar, binalar ve diğer yerel kaynaklar tarafından bozulabilir.)*

Magnetometer heading must therefore not be trusted with a fixed maximum weight under every environment. *(Bu nedenle manyetometre yönüne her ortamda sabit maksimum ağırlıkla güvenilmemelidir.)*

---

# 38. Complementary Heading Concept (Tamamlayıcı Yön Kavramı)

The target deterministic heading system will evaluate a complementary fusion strategy. *(Hedef deterministik yön sistemi tamamlayıcı bir füzyon stratejisini değerlendirecektir.)*

Gyroscope propagation will supply short-term continuity. *(Jiroskop ilerletmesi kısa dönem sürekliliği sağlayacaktır.)*

Trusted magnetic heading will provide slow absolute correction toward true north. *(Güvenilir manyetik yön gerçek kuzeye doğru yavaş mutlak düzeltme sağlayacaktır.)*

---

# 39. Circular Complementary Correction (Dairesel Tamamlayıcı Düzeltme)

A heading prediction may first be produced from gyroscope propagation. *(İlk olarak jiroskop ilerletmesinden bir yön tahmini üretilebilir.)*

```
ψ_pred =
normalize(
    ψ_previous + Δψ_gyro
)
```

The shortest signed difference between magnetic heading and predicted heading may then be calculated. *(Manyetik yön ile tahmini yön arasındaki en kısa işaretli fark daha sonra hesaplanabilir.)*

```
e_mag =
atan2(
    sin(ψ_mag_true - ψ_pred),
    cos(ψ_mag_true - ψ_pred)
)
```

---

# 40. Fused Heading Candidate (Füzyonlu Yön Adayı)

A simple quality-controlled correction can then be expressed as follows. *(Basit kalite kontrollü düzeltme daha sonra aşağıdaki şekilde ifade edilebilir.)*

```
ψ_fused =
normalize(
    ψ_pred + K_mag · e_mag
)
```

`K_mag` represents the current magnetic correction weight. *(`K_mag`, mevcut manyetik düzeltme ağırlığını temsil eder.)*

---

# 41. Magnetic Correction Weight (Manyetik Düzeltme Ağırlığı)

`K_mag` will not be a universal fixed constant selected without device testing. *(`K_mag`, cihaz testi olmadan seçilen evrensel sabit bir katsayı olmayacaktır.)*

The target system may change this value according to magnetometer quality. *(Hedef sistem bu değeri manyetometre kalitesine göre değiştirebilir.)*

```
Good magnetic quality
(İyi manyetik kalite)
        ↓
Larger correction
(Daha büyük düzeltme)

Poor magnetic quality
(Düşük manyetik kalite)
        ↓
Small or zero correction
(Küçük veya sıfır düzeltme)
```

---

# 42. No Linear Degree Averaging (Doğrusal Derece Ortalaması Olmaması)

Heading values must not be averaged with ordinary arithmetic without handling their circular nature. *(Yön değerleri dairesel yapıları yönetilmeden sıradan aritmetik ile ortalanmamalıdır.)*

For example, the average of `359°` and `1°` should be near `0°` rather than `180°`. *(Örneğin `359°` ile `1°` değerlerinin ortalaması `180°` yerine `0°` civarında olmalıdır.)*

---

# 43. Circular Difference Function (Dairesel Fark Fonksiyonu)

NAVGUARD will centralize circular-angle difference calculations. *(NAVGUARD dairesel açı farkı hesaplarını merkezileştirecektir.)*

```
angleDifference(a, b) =
atan2(
    sin(a - b),
    cos(a - b)
)
```

The result lies in the shortest signed angular interval. *(Sonuç en kısa işaretli açısal aralık içerisinde bulunur.)*

---

# 44. Heading Normalization (Yön Normalizasyonu)

Every public navigation heading will be normalized into the canonical interval. *(Her genel navigasyon yönü kanonik aralığa normalize edilecektir.)*

```
ψ ∈ [0, 2π)
```

Diagnostics may additionally expose the equivalent range in degrees. *(Tanı ayrıca derece cinsinden eşdeğer aralığı sunabilir.)*

---

# 45. Magnetic Disturbance Detection (Manyetik Bozulma Tespiti)

NAVGUARD will implement magnetic-quality analysis before accepting magnetic heading as a strong correction source. *(NAVGUARD manyetik yönü güçlü bir düzeltme kaynağı olarak kabul etmeden önce manyetik kalite analizi geliştirecektir.)*

No single disturbance detector will initially be assumed sufficient. *(Başlangıçta tek bir bozulma algılayıcının yeterli olduğu varsayılmayacaktır.)*

Multiple pieces of evidence may be combined. *(Birden fazla kanıt birleştirilebilir.)*

---

# 46. Magnetic Quality Inputs (Manyetik Kalite Girdileri)

Candidate quality evidence will include measured magnetic-field magnitude. *(Aday kalite kanıtı ölçülen manyetik alan büyüklüğünü içerecektir.)*

Candidate quality evidence will include Android sensor-accuracy status when available. *(Aday kalite kanıtı mevcut olduğunda Android sensör doğruluk durumunu içerecektir.)*

Candidate quality evidence will include short-term field variation. *(Aday kalite kanıtı kısa dönem alan değişimini içerecektir.)*

Candidate quality evidence will include disagreement between magnetic heading and gyro-propagated heading. *(Aday kalite kanıtı manyetik yön ile jiroskop ilerletmeli yön arasındaki uyuşmazlığı içerecektir.)*

Candidate quality evidence may include expected geomagnetic-field strength from `GeomagneticField`. *(Aday kalite kanıtı `GeomagneticField` üzerinden beklenen jeomanyetik alan şiddetini içerebilir.)*

---

# 47. Magnetic Field Magnitude (Manyetik Alan Büyüklüğü)

Measured field magnitude will be calculated as follows. *(Ölçülen alan büyüklüğü aşağıdaki şekilde hesaplanacaktır.)*

```
|B| =
√(
B_x² + B_y² + B_z²
)
```

The measurement remains sensor data rather than a direct heading-quality probability. *(Ölçüm doğrudan yön kalite olasılığı yerine sensör verisi olarak kalır.)*

---

# 48. Expected Geomagnetic Field (Beklenen Jeomanyetik Alan)

Android `GeomagneticField` can also provide modeled total field strength for a geographic location and time. *(Android `GeomagneticField` coğrafi konum ve zaman için modellenmiş toplam alan şiddeti de sağlayabilir.)*

NAVGUARD may compare measured magnetic-field magnitude with the modeled environmental magnitude as one disturbance indicator. *(NAVGUARD bir bozulma göstergesi olarak ölçülen manyetik alan büyüklüğünü modellenmiş çevresel büyüklükle karşılaştırabilir.)*

The allowed deviation will be determined from physical-device experiments. *(İzin verilen sapma fiziksel cihaz deneylerinden belirlenecektir.)*

---

# 49. No Universal Magnetic Magnitude Threshold (Evrensel Manyetik Büyüklük Eşiği Olmaması)

NAVGUARD will not hard-code an arbitrary universal microtesla range before local measurements are collected. *(NAVGUARD yerel ölçümler toplanmadan keyfi evrensel bir mikrotesla aralığını hard-code etmeyecektir.)*

The expected geomagnetic field varies geographically, while phone hardware and nearby disturbances also affect observed values. *(Beklenen jeomanyetik alan coğrafi olarak değişirken telefon donanımı ve yakındaki bozulmalar da gözlemlenen değerleri etkiler.)*

---

# 50. Magnetic Heading Innovation Test (Manyetik Yön Yenilik Testi)

The difference between magnetic heading and current gyro prediction can act as an innovation signal. *(Manyetik yön ile mevcut jiroskop tahmini arasındaki fark bir innovation sinyali olarak kullanılabilir.)*

```
innovation =
wrapToPi(
    ψ_mag_true - ψ_pred
)
```

A sudden unusually large innovation may indicate magnetic disturbance, gyro error, genuine rapid rotation, or a combination of these factors. *(Ani ve olağan dışı büyük bir innovation manyetik bozulmayı, jiroskop hatasını, gerçek hızlı dönüşü veya bu faktörlerin birleşimini gösterebilir.)*

The detector must therefore interpret innovation together with motion information rather than reject every large difference automatically. *(Bu nedenle algılayıcı her büyük farkı otomatik olarak reddetmek yerine innovation değerini hareket bilgisiyle birlikte yorumlamalıdır.)*

---

# 51. Magnetic Change Rate (Manyetik Değişim Hızı)

Rapid changes in field magnitude while geographic location changes only slightly may indicate local magnetic disturbance. *(Coğrafi konum yalnızca az değişirken alan büyüklüğündeki hızlı değişimler yerel manyetik bozulmayı gösterebilir.)*

The final quality engine may use the derivative or short-window variation of field magnitude. *(Nihai kalite motoru alan büyüklüğünün türevini veya kısa pencere değişimini kullanabilir.)*

---

# 52. Magnetometer Accuracy Status (Manyetometre Doğruluk Durumu)

Android sensor events can expose sensor accuracy changes through the sensor-listener interface. *(Android sensör olayları sensör listener arayüzü üzerinden sensör doğruluk değişikliklerini sunabilir.)*

NAVGUARD may preserve these states as supporting quality metadata. *(NAVGUARD bu durumları destekleyici kalite metadata bilgisi olarak koruyabilir.)*

The Android accuracy state will not be the only magnetic-quality criterion. *(Android doğruluk durumu tek manyetik kalite kriteri olmayacaktır.)*

---

# 53. Magnetometer Calibration (Manyetometre Kalibrasyonu)

The physical device may require magnetometer calibration before formal heading experiments. *(Fiziksel cihaz resmî yön deneylerinden önce manyetometre kalibrasyonu gerektirebilir.)*

NAVGUARD may provide a diagnostic prompt when measured magnetic quality indicates calibration problems. *(NAVGUARD ölçülen manyetik kalite kalibrasyon problemi gösterdiğinde tanısal uyarı sağlayabilir.)*

A custom hard-iron and soft-iron calibration algorithm is not mandatory for the minimum implementation. *(Özel hard-iron ve soft-iron kalibrasyon algoritması minimum uygulama için zorunlu değildir.)*

---

# 54. Custom Magnetic Calibration as Enhancement (İyileştirme Olarak Özel Manyetik Kalibrasyon)

If pilot tests reveal persistent correctable magnetometer distortion, custom calibration may be investigated. *(Pilot testler kalıcı ve düzeltilebilir manyetometre bozulması gösterirse özel kalibrasyon araştırılabilir.)*

Such additional complexity will be introduced only if it produces measurable heading improvement. *(Böyle ek karmaşıklık yalnızca ölçülebilir yön iyileştirmesi üretirse dahil edilecektir.)*

---

# 55. Magnetic Quality State (Manyetik Kalite Durumu)

A derived magnetic-quality state may use the following categories. *(Türetilmiş manyetik kalite durumu aşağıdaki kategorileri kullanabilir.)*

```
UNKNOWN
GOOD
USABLE
DISTURBED
UNAVAILABLE
```

The numerical thresholds behind these categories will remain configurable until physical validation is complete. *(Bu kategorilerin arkasındaki sayısal eşikler fiziksel doğrulama tamamlanana kadar yapılandırılabilir kalacaktır.)*

---

# 56. Magnetic Disturbance Behavior (Manyetik Bozulma Davranışı)

When magnetic quality becomes `DISTURBED`, the target heading system will reduce or temporarily disable magnetometer correction. *(Manyetik kalite `DISTURBED` olduğunda hedef yön sistemi manyetometre düzeltmesini azaltacak veya geçici olarak devre dışı bırakacaktır.)*

Gyroscope propagation may continue for short periods. *(Jiroskop ilerletmesi kısa dönemler için devam edebilir.)*

Heading confidence will decrease as time without trustworthy absolute correction increases. *(Güvenilir mutlak düzeltme olmadan geçen süre arttıkça yön güveni azalacaktır.)*

---

# 57. Magnetic Recovery (Manyetik Geri Kazanım)

Magnetic correction will not necessarily return to full weight immediately after one apparently good sample. *(Manyetik düzeltme görünüşte iyi tek bir örnek sonrasında mutlaka hemen tam ağırlığa dönmeyecektir.)*

A short period of stable magnetic observations may be required before normal correction weight is restored. *(Normal düzeltme ağırlığı geri yüklenmeden önce kısa süreli kararlı manyetik gözlemler gerekebilir.)*

This hysteresis can reduce rapid switching between trusted and disturbed states. *(Bu hysteresis güvenilir ve bozulmuş durumlar arasında hızlı geçişleri azaltabilir.)*

---

# 58. Rotation Vector Heading Accuracy (Rotation Vector Yön Doğruluğu)

Android rotation-vector events can include an estimated heading-accuracy value when the platform provides it. *(Android rotation-vector olayları platform sağladığında tahmini yön doğruluğu değeri içerebilir.)*

NAVGUARD will preserve this value as optional platform-provided metadata. *(NAVGUARD bu değeri isteğe bağlı platform tarafından sağlanan metadata olarak koruyacaktır.)*

It will not be treated as independent ground-truth heading error. *(Bağımsız gerçek referans yön hatası olarak ele alınmayacaktır.)*

---

# 59. Rotation Vector Quaternion Conversion (Rotation Vector Quaternion Dönüşümü)

Android provides `SensorManager.getQuaternionFromVector()` for converting a rotation vector to a normalized quaternion. *(Android bir rotation vector’ü normalize edilmiş quaternion’a dönüştürmek için `SensorManager.getQuaternionFromVector()` sağlar.)*

The returned quaternion uses `[w, x, y, z]` ordering. *(Döndürülen quaternion `[w, x, y, z]` sıralamasını kullanır.)*

This matches NAVGUARD’s canonical internal quaternion order. *(Bu NAVGUARD’ın kanonik dahili quaternion sırasıyla eşleşir.)*

---

# 60. Rotation Vector Comparison Experiment (Rotation Vector Karşılaştırma Deneyi)

The following heading approaches may be compared using the same recorded sessions. *(Aşağıdaki yön yaklaşımları aynı kaydedilmiş oturumlar kullanılarak karşılaştırılabilir.)*

| Method (Yöntem) | Purpose (Amaç) |
| --- | --- |
| Accelerometer + Magnetometer *(İvmeölçer + Manyetometre)* | Transparent baseline heading. *(Şeffaf temel yön.)* |
| Android Rotation Vector | Platform-fused comparison. *(Platform füzyonlu karşılaştırma.)* |
| Game Rotation Vector + Initial Alignment | Relative-orientation comparison. *(Göreli yönelim karşılaştırması.)* |
| NAVGUARD Gyro + Magnetic Fusion | Target custom heading. *(Hedef özel yön sistemi.)* |

Only the methods actually available on the physical device will be evaluated. *(Yalnızca fiziksel cihazda gerçekten mevcut olan yöntemler değerlendirilecektir.)*

---

# 61. Sensor Availability Fallback (Sensör Kullanılabilirlik Geri Dönüşü)

The Heading Estimation System will not assume that every virtual Android orientation sensor exists. *(Yön Tahmin Sistemi her sanal Android yönelim sensörünün mevcut olduğunu varsaymayacaktır.)*

Runtime sensor enumeration from the Device Capability Audit will determine available sources. *(Cihaz Yetenek Denetimindeki çalışma zamanı sensör envanteri mevcut kaynakları belirleyecektir.)*

---

# 62. Heading Fallback Hierarchy (Yön Geri Dönüş Hiyerarşisi)

A target fallback hierarchy may use the following structure. *(Hedef geri dönüş hiyerarşisi aşağıdaki yapıyı kullanabilir.)*

```
Validated NAVGUARD Gyro + Magnetic Fusion
(Doğrulanmış NAVGUARD Jiroskop + Manyetik Füzyon)
                 ↓
Validated Android Rotation Vector
(Doğrulanmış Android Rotation Vector)
                 ↓
Tilt-Compensated Magnetic Heading
(Tilt Telafili Manyetik Yön)
                 ↓
Short-Term Gyroscope Propagation
(Kısa Dönem Jiroskop İlerletmesi)
                 ↓
Heading Unavailable / Degraded
(Yön Kullanılamaz / Bozulmuş)
```

The exact ordering may be refined after physical experiments. *(Kesin sıralama fiziksel deneylerden sonra iyileştirilebilir.)*

---

# 63. Gyroscope-Only Duration (Yalnızca Jiroskop Süresi)

NAVGUARD will not assume that gyroscope-only heading remains reliable indefinitely. *(NAVGUARD yalnızca jiroskopa dayalı yönün süresiz güvenilir kaldığını varsaymayacaktır.)*

Heading confidence will generally decrease during prolonged periods without absolute correction. *(Mutlak düzeltme olmadan uzayan dönemlerde yön güveni genel olarak azalacaktır.)*

The maximum practical gyro-only interval will be determined experimentally. *(Pratik maksimum yalnızca jiroskop aralığı deneysel olarak belirlenecektir.)*

---

# 64. Heading Initialization (Yön Başlatma)

The heading system requires an initial Earth-referenced orientation before GNSS-denied PDR begins. *(Yön sistemi GNSS kesintili PDR başlamadan önce başlangıç Dünya referanslı yönelime ihtiyaç duyar.)*

The primary initialization candidate will use a stable tilt-compensated magnetic heading corrected for declination. *(Temel başlatma adayı sapma için düzeltilmiş kararlı tilt telafili manyetik yön kullanacaktır.)*

A validated rotation vector may provide additional initialization evidence. *(Doğrulanmış rotation vector ek başlatma kanıtı sağlayabilir.)*

---

# 65. Heading Initialization Stability (Yön Başlatma Kararlılığı)

NAVGUARD should observe heading for a short initialization interval rather than blindly accept one instantaneous sample. *(NAVGUARD tek bir anlık örneği körlemesine kabul etmek yerine kısa bir başlatma aralığı boyunca yönü gözlemlemelidir.)*

The initialization process may evaluate circular dispersion and magnetic quality. *(Başlatma işlemi dairesel dağılımı ve manyetik kaliteyi değerlendirebilir.)*

The exact duration and allowable dispersion will be determined from device tests. *(Kesin süre ve izin verilen dağılım cihaz testlerinden belirlenecektir.)*

---

# 66. Circular Mean Heading (Dairesel Ortalama Yön)

When averaging multiple heading observations, NAVGUARD will use circular statistics. *(Birden fazla yön gözlemi ortalanırken NAVGUARD dairesel istatistik kullanacaktır.)*

```
C =
1/n · Σ cos(ψ_i)

S =
1/n · Σ sin(ψ_i)

ψ_mean =
atan2(S, C)
```

The result will then be normalized into the canonical heading interval. *(Sonuç daha sonra kanonik yön aralığına normalize edilecektir.)*

---

# 67. Circular Concentration (Dairesel Yoğunlaşma)

The stability of a set of heading observations may be assessed using the resultant-vector magnitude. *(Bir yön gözlem setinin kararlılığı sonuç vektörü büyüklüğü kullanılarak değerlendirilebilir.)*

```
R =
√(C² + S²)
```

Values closer to one indicate more concentrated directions, while lower values indicate greater angular dispersion. *(Bire daha yakın değerler daha yoğun yönleri, düşük değerler ise daha büyük açısal dağılımı gösterir.)*

The final use of this statistic will be validated experimentally. *(Bu istatistiğin nihai kullanımı deneysel olarak doğrulanacaktır.)*

---

# 68. Phone Heading Versus Pedestrian Heading (Telefon Yönü ile Yaya Yönü)

The smartphone’s physical forward direction is not universally identical to the pedestrian’s direction of travel. *(Akıllı telefonun fiziksel ileri yönü evrensel olarak yayanın hareket yönüyle aynı değildir.)*

This difference is one of the most important practical heading issues in smartphone PDR. *(Bu fark akıllı telefon PDR’sindeki en önemli pratik yön problemlerinden biridir.)*

---

# 69. Controlled Phone Placement (Kontrollü Telefon Yerleşimi)

Formal baseline experiments will use a controlled phone-placement configuration. *(Resmî temel deneyler kontrollü bir telefon yerleşim yapılandırması kullanacaktır.)*

The preferred initial protocol will keep the device orientation sufficiently consistent relative to the pedestrian’s forward travel direction. *(Tercih edilen ilk protokol cihaz yönelimini yayanın ileri hareket yönüne göre yeterince tutarlı tutacaktır.)*

The exact physical placement will be frozen in the field-test protocol. *(Kesin fiziksel yerleşim saha testi protokolünde sabitlenecektir.)*

---

# 70. Placement Heading Offset (Yerleşim Yön Offset’i)

If the device’s defined forward axis differs consistently from pedestrian travel direction, NAVGUARD may apply a calibrated placement offset. *(Cihazın tanımlanmış ileri ekseni yayanın hareket yönünden tutarlı şekilde farklıysa NAVGUARD kalibre edilmiş yerleşim offset’i uygulayabilir.)*

```
ψ_user =
normalize(
    ψ_device_true + γ_placement
)
```

`γ_placement` represents the known device-to-user heading offset. *(`γ_placement`, bilinen cihaz-yaya yön offset’ini temsil eder.)*

---

# 71. Placement Offset Calibration (Yerleşim Offset Kalibrasyonu)

Placement offset will not be guessed from UI screen orientation. *(Yerleşim offset’i UI ekran yöneliminden tahmin edilmeyecektir.)*

It will be derived from the formal placement definition or a controlled forward-direction calibration. *(Resmî yerleşim tanımından veya kontrollü ileri yön kalibrasyonundan türetilecektir.)*

---

# 72. Placement Change During Session (Oturum Sırasında Yerleşim Değişikliği)

The placement offset is valid only while the physical phone-placement relationship remains unchanged. *(Yerleşim offset’i yalnızca fiziksel telefon yerleşim ilişkisi değişmeden kaldığı sürece geçerlidir.)*

An untracked change in phone placement can create a large systematic heading error. *(Takip edilmeyen telefon yerleşimi değişikliği büyük sistematik yön hatası oluşturabilir.)*

Formal benchmark sessions will therefore avoid arbitrary placement changes unless placement change itself is being tested. *(Bu nedenle resmî benchmark oturumları yerleşim değişiminin kendisi test edilmediği sürece keyfi yerleşim değişikliklerinden kaçınacaktır.)*

---

# 73. Arbitrary Pocket Navigation Scope (Keyfi Cep Navigasyonu Kapsamı)

Supporting unrestricted hand, pocket, bag, and arbitrary body placement with automatic device-to-user heading inference is outside the minimum project scope. *(Kısıtlanmamış el, cep, çanta ve keyfi vücut yerleşimini otomatik cihaz-yaya yön çıkarımıyla desteklemek minimum proje kapsamının dışındadır.)*

This may be investigated as future work. *(Bu gelecek çalışma olarak araştırılabilir.)*

---

# 74. Device Orientation Versus Course of Travel (Cihaz Yönelimi ile Hareket Rotası Ayrımı)

Device orientation and actual travel direction may temporarily differ even under controlled placement. *(Cihaz yönelimi ve gerçek hareket yönü kontrollü yerleşimde bile geçici olarak farklı olabilir.)*

This is especially possible during turns, side steps, or natural arm motion. *(Bu özellikle dönüşler, yan adımlar veya doğal kol hareketleri sırasında mümkündür.)*

Heading evaluation must therefore distinguish device attitude accuracy from pedestrian course accuracy. *(Bu nedenle yön değerlendirmesi cihaz attitude doğruluğu ile yaya hareket rotası doğruluğunu ayırt etmelidir.)*

---

# 75. Turning Behavior (Dönüş Davranışı)

During a turn, gyroscope information will provide high-rate relative rotation evidence. *(Dönüş sırasında jiroskop bilgisi yüksek hızlı göreli dönüş kanıtı sağlayacaktır.)*

Magnetometer correction may continue only when magnetic quality remains trustworthy. *(Manyetik düzeltme yalnızca manyetik kalite güvenilir kaldığında devam edebilir.)*

The heading estimate should change smoothly without artificial jumps at the `0°/360°` boundary. *(Yön tahmini `0°/360°` sınırında yapay sıçramalar olmadan düzgün şekilde değişmelidir.)*

---

# 76. Turning Rate (Dönüş Hızı)

A heading-rate estimate may be calculated from circular heading change over elapsed time. *(Yön değişim hızı geçen süre içerisindeki dairesel yön değişiminden hesaplanabilir.)*

```
ψ_dot =
wrapToPi(
    ψ_k - ψ_(k-1)
)
/
Δt
```

This may support `TURNING` context detection and diagnostics. *(Bu `TURNING` bağlam tespitini ve tanıyı destekleyebilir.)*

---

# 77. Heading at Step Time (Adım Anındaki Yön)

PDR will require heading at the timestamp of each accepted step event. *(PDR kabul edilmiş her adım olayının zaman damgasındaki yöne ihtiyaç duyacaktır.)*

The Heading Estimation System may therefore maintain a timestamped heading buffer. *(Bu nedenle Yön Tahmin Sistemi zaman damgalı bir yön tamponu tutabilir.)*

---

# 78. Heading Buffer (Yön Tamponu)

A logical heading history may contain the following fields. *(Mantıksal yön geçmişi aşağıdaki alanları içerebilir.)*

```
HeadingSample
- timestampNs
- magneticHeadingRad
- trueHeadingRad
- fusedHeadingRad
- headingConfidence
- magneticQuality
- source
```

The buffer size will be bounded. *(Tampon boyutu sınırlı olacaktır.)*

---

# 79. Heading Interpolation at Step Time (Adım Anında Yön Interpolasyonu)

If a step occurs between two valid heading samples, circular interpolation may be used when appropriate. *(Bir adım iki geçerli yön örneği arasında meydana gelirse uygun olduğunda dairesel interpolasyon kullanılabilir.)*

Quaternion interpolation may be used when full orientation is required. *(Tam yönelim gerektiğinde quaternion interpolasyonu kullanılabilir.)*

Ordinary linear degree interpolation across the `0°/360°` boundary will not be used. *( `0°/360°` sınırı boyunca sıradan doğrusal derece interpolasyonu kullanılmayacaktır.)*

---

# 80. Heading Freshness (Yön Güncelliği)

Every heading estimate consumed by PDR must have a measurable age. *(PDR tarafından kullanılan her yön tahmininin ölçülebilir bir yaşı olmalıdır.)*

```
headingAge =
stepTimestamp -
headingTimestamp
```

A stale heading must not be treated as current indefinitely. *(Eski yön süresiz olarak güncel kabul edilmemelidir.)*

---

# 81. Heading Freshness Threshold (Yön Güncellik Eşiği)

The final maximum acceptable heading age will depend on measured heading update rates and pedestrian-turn dynamics. *(Nihai maksimum kabul edilebilir yön yaşı ölçülen yön güncelleme hızlarına ve yaya dönüş dinamiklerine bağlı olacaktır.)*

The value will be frozen after Device Capability Audit and pilot tests. *(Değer Cihaz Yetenek Denetimi ve pilot testlerden sonra sabitlenecektir.)*

---

# 82. Heading Confidence (Yön Güveni)

The target heading output may include a quality or confidence score. *(Hedef yön çıktısı kalite veya güven skoru içerebilir.)*

This score will indicate relative trust in the current direction estimate rather than automatically represent a calibrated probability. *(Bu skor otomatik olarak kalibre edilmiş olasılığı temsil etmek yerine mevcut yön tahminine olan göreli güveni gösterecektir.)*

---

# 83. Heading Confidence Inputs (Yön Güven Girdileri)

Candidate confidence inputs include magnetometer quality. *(Aday güven girdileri manyetometre kalitesini içerir.)*

Candidate confidence inputs include time since the last trusted magnetic correction. *(Aday güven girdileri son güvenilir manyetik düzeltmeden itibaren geçen süreyi içerir.)*

Candidate confidence inputs include gyroscope timing quality. *(Aday güven girdileri jiroskop zamanlama kalitesini içerir.)*

Candidate confidence inputs include sensor availability. *(Aday güven girdileri sensör kullanılabilirliğini içerir.)*

Candidate confidence inputs include orientation-solution validity. *(Aday güven girdileri yönelim çözümü geçerliliğini içerir.)*

Candidate confidence inputs may include rotation-vector heading-accuracy metadata. *(Aday güven girdileri rotation-vector yön doğruluk metadata bilgisini içerebilir.)*

---

# 84. Heading Confidence States (Yön Güven Durumları)

A simple initial representation may use the following states. *(Basit bir başlangıç temsili aşağıdaki durumları kullanabilir.)*

```
HIGH
MODERATE
LOW
INVALID
```

These states must eventually be associated with measured heading behavior. *(Bu durumlar sonunda ölçülmüş yön davranışıyla ilişkilendirilmelidir.)*

---

# 85. Confidence Decay During Magnetic Loss (Manyetik Kayıp Sırasında Güven Azalması)

When magnetic correction becomes unavailable, heading confidence should generally decrease as gyroscope-only propagation continues. *(Manyetik düzeltme kullanılamaz hale geldiğinde yalnızca jiroskop ilerletmesi devam ettikçe yön güveni genel olarak azalmalıdır.)*

The decay model will be calibrated from measured gyro drift rather than invented in advance. *(Azalma modeli önceden uydurulmak yerine ölçülmüş jiroskop sürüklenmesinden kalibre edilecektir.)*

---

# 86. Heading Output Model (Yön Çıktı Modeli)

```
HeadingEstimate
- timestampNs
- deviceMagneticHeadingRad
- deviceTrueHeadingRad
- pedestrianHeadingRad
- source
- confidence
- magneticQuality
- declinationRad
- placementOffsetRad
```

Optional diagnostic fields may be added without changing the PDR interface. *(İsteğe bağlı tanısal alanlar PDR arayüzünü değiştirmeden eklenebilir.)*

---

# 87. Heading Source Enumeration (Yön Kaynak Tanımı)

A heading estimate may identify its current source or strategy. *(Bir yön tahmini mevcut kaynağını veya stratejisini tanımlayabilir.)*

```
ACC_MAG_BASELINE
ROTATION_VECTOR
GAME_ROTATION_VECTOR_ALIGNED
GYRO_MAG_FUSION
GYRO_FALLBACK
INVALID
```

This metadata will support component-level evaluation. *(Bu metadata bileşen seviyesinde değerlendirmeyi destekleyecektir.)*

---

# 88. Heading System Runtime States (Yön Sistemi Çalışma Durumları)

```
STARTING
CALIBRATING
READY
ACTIVE
MAGNETIC_DEGRADED
GYRO_ONLY
DEGRADED
ERROR
```

`MAGNETIC_DEGRADED` does not necessarily mean that all heading estimation has failed. *(`MAGNETIC_DEGRADED`, tüm yön tahmininin başarısız olduğu anlamına gelmek zorunda değildir.)*

---

# 89. Baseline Heading Health (Temel Yön Sağlığı)

The accelerometer-magnetometer baseline requires a usable gravity estimate and usable magnetic measurement. *(İvmeölçer-manyetometre temeli kullanılabilir yerçekimi tahmini ve kullanılabilir manyetik ölçüm gerektirir.)*

If either becomes invalid, baseline absolute heading will be considered unavailable or degraded. *(Bunlardan biri geçersiz hale gelirse temel mutlak yön kullanılamaz veya bozulmuş kabul edilecektir.)*

---

# 90. Target Heading Health (Hedef Yön Sağlığı)

The target fused system may remain temporarily usable when magnetic quality degrades because gyroscope propagation can continue. *(Manyetik kalite bozulduğunda jiroskop ilerletmesi devam edebildiği için hedef füzyonlu sistem geçici olarak kullanılabilir kalabilir.)*

Its confidence must nevertheless reflect increasing uncertainty. *(Bununla birlikte güveni artan belirsizliği yansıtmalıdır.)*

---

# 91. Heading Failure Codes (Yön Hata Kodları)

```
HEADING_NOT_INITIALIZED
HEADING_ACCELEROMETER_UNAVAILABLE
HEADING_GYROSCOPE_UNAVAILABLE
HEADING_MAGNETOMETER_UNAVAILABLE
HEADING_MAGNETIC_DISTURBANCE
HEADING_ROTATION_MATRIX_INVALID
HEADING_STALE
HEADING_QUATERNION_INVALID
HEADING_NON_MONOTONIC_TIME
HEADING_CONFIGURATION_ERROR
```

Structured codes will support replay and diagnostics. *(Yapılandırılmış kodlar replay ve tanıyı destekleyecektir.)*

---

# 92. No Silent Zero-Heading Fallback (Sessiz Sıfır Yön Geri Dönüşü Olmaması)

An unavailable heading must never be silently replaced with `0°`. *(Kullanılamayan bir yön hiçbir zaman sessizce `0°` ile değiştirilmemelidir.)*

`0°` is a valid physical direction corresponding to true north. *(`0°`, gerçek kuzeye karşılık gelen geçerli fiziksel bir yöndür.)*

Unavailable and north-facing states must therefore remain distinguishable. *(Bu nedenle kullanılamaz ve kuzeye dönük durumlar ayırt edilebilir kalmalıdır.)*

---

# 93. Heading Failure and PDR (Yön Hatası ve PDR)

PDR must not blindly propagate a step with an invalid heading. *(PDR geçersiz yönle bir adımı körlemesine ilerletmemelidir.)*

Depending on the final fallback policy, it may temporarily use a sufficiently recent valid heading, reduce confidence, buffer the event briefly, or reject position propagation. *(Nihai geri dönüş politikasına bağlı olarak yeterince yeni son geçerli yönü geçici olarak kullanabilir, güveni azaltabilir, olayı kısa süre tamponlayabilir veya konum ilerletmesini reddedebilir.)*

The policy will be selected using measured turn behavior and latency requirements. *(Politika ölçülen dönüş davranışı ve gecikme gereksinimleri kullanılarak seçilecektir.)*

---

# 94. Straight-Line Heading Test (Düz Çizgi Yön Testi)

A controlled straight route will evaluate heading stability during approximately constant travel direction. *(Kontrollü düz bir rota yaklaşık sabit hareket yönü sırasında yön kararlılığını değerlendirecektir.)*

The test will help identify slowly varying drift and magnetic bias. *(Test yavaş değişen sürüklenmeyi ve manyetik bias’ı belirlemeye yardımcı olacaktır.)*

---

# 95. Cardinal Direction Test (Ana Yön Testi)

The physical phone-placement protocol will be aligned approximately with known North, East, South, and West directions. *(Fiziksel telefon yerleşim protokolü yaklaşık olarak bilinen Kuzey, Doğu, Güney ve Batı yönleriyle hizalanacaktır.)*

Expected true-heading values will be approximately `0°`, `90°`, `180°`, and `270°`. *(Beklenen gerçek yön değerleri yaklaşık `0°`, `90°`, `180°` ve `270°` olacaktır.)*

This test will verify axis order, sign convention, placement offset, and declination direction. *(Bu test eksen sırasını, işaret kuralını, yerleşim offset’ini ve sapma yönünü doğrulayacaktır.)*

---

# 96. Controlled Rotation Test (Kontrollü Dönüş Testi)

A stationary controlled rotation test will include approximately `90°`, `180°`, and return-to-start rotations. *(Sabit kontrollü dönüş testi yaklaşık `90°`, `180°` ve başlangıç yönüne dönüş hareketlerini içerecektir.)*

The system will compare estimated angular change with the known physical rotation. *(Sistem tahmini açısal değişimi bilinen fiziksel dönüşle karşılaştıracaktır.)*

---

# 97. Return-to-Heading Test (Başlangıç Yönüne Dönüş Testi)

After a controlled rotation and return to the original orientation, the final estimated heading should approximately return to the initial value. *(Kontrollü bir dönüş ve orijinal yönelime dönüş sonrasında nihai tahmini yön yaklaşık olarak başlangıç değerine dönmelidir.)*

The remaining angular difference can characterize short-term drift or magnetic inconsistency. *(Kalan açısal fark kısa dönem sürüklenmeyi veya manyetik tutarsızlığı karakterize edebilir.)*

---

# 98. Stationary Heading Stability Test (Sabit Yön Kararlılık Testi)

The phone will remain stationary for a controlled interval while heading output is recorded. *(Telefon kontrollü bir aralık boyunca sabit kalırken yön çıktısı kaydedilecektir.)*

The test will measure heading variation, magnetic variation, and gyroscope drift. *(Test yön değişimini, manyetik değişimi ve jiroskop sürüklenmesini ölçecektir.)*

---

# 99. Magnetic Disturbance Test (Manyetik Bozulma Testi)

Heading will be observed under a relatively quiet magnetic environment and under naturally disturbed environments. *(Yön nispeten sakin manyetik ortamda ve doğal olarak bozulmuş ortamlarda gözlemlenecektir.)*

The project will not intentionally generate hazardous magnetic or RF interference. *(Proje bilinçli olarak tehlikeli manyetik veya RF müdahalesi oluşturmayacaktır.)*

Normal environmental conditions will be sufficient to test disturbance handling. *(Normal çevresel koşullar bozulma yönetimini test etmek için yeterli olacaktır.)*

---

# 100. Disturbance Examples (Bozulma Örnekleri)

Candidate ordinary disturbance environments may include proximity to metal structures. *(Aday sıradan bozulma ortamları metal yapılara yakınlığı içerebilir.)*

Candidate ordinary disturbance environments may include vehicles or electrically active indoor environments. *(Aday sıradan bozulma ortamları araçları veya elektriksel olarak aktif iç mekânları içerebilir.)*

The exact experiment will remain safe and non-destructive. *(Kesin deney güvenli ve zarar vermeyen şekilde kalacaktır.)*

---

# 101. Walking Heading Evaluation (Yürüyüş Yön Değerlendirmesi)

Heading must also be evaluated while the user is actually walking because motion introduces accelerometer dynamics absent from stationary compass tests. *(Yön kullanıcı gerçekten yürürken de değerlendirilmelidir çünkü hareket sabit pusula testlerinde bulunmayan ivmeölçer dinamikleri oluşturur.)*

Stationary heading performance alone will not be considered sufficient. *(Yalnızca sabit yön performansı yeterli kabul edilmeyecektir.)*

---

# 102. Turn-Heavy Heading Evaluation (Dönüş Yoğun Yön Değerlendirmesi)

A route containing repeated turns will evaluate response speed, gyro propagation, magnetic correction, and angle wrap-around. *(Tekrarlanan dönüşler içeren bir rota tepki hızını, jiroskop ilerletmesini, manyetik düzeltmeyi ve açı wrap-around yönetimini değerlendirecektir.)*

---

# 103. Reference Heading Sources (Referans Yön Kaynakları)

No single reference method is expected to provide perfect pedestrian heading under every condition. *(Tek bir referans yöntemin her koşulda mükemmel yaya yönü sağlaması beklenmemektedir.)*

NAVGUARD will use controlled experimental references appropriate to each test. *(NAVGUARD her teste uygun kontrollü deneysel referanslar kullanacaktır.)*

---

# 104. Cardinal Reference (Ana Yön Referansı)

Known physical cardinal alignment can provide strong reference evidence for static tests. *(Bilinen fiziksel ana yön hizalaması sabit testler için güçlü referans kanıtı sağlayabilir.)*

The method used to establish the reference direction must be documented. *(Referans yönünü oluşturmak için kullanılan yöntem dokümante edilmelidir.)*

---

# 105. Authorized GNSS Bearing Diagnostic Use (Yetkilendirilmiş GNSS Bearing Diagnostic Kullanımı)

GNSS course bearing represents horizontal travel direction and not physical device or body heading. *(GNSS course bearing yatay travel direction'ı temsil eder; fiziksel cihaz veya body heading'i temsil etmez.)*

It may be inspected only as travel-direction diagnostic information in explicitly authorized GNSS Mode or during offline post-session evaluation when movement and reference quality are sufficient. *(Yalnızca açıkça authorized GNSS Mode içerisinde veya movement ve reference quality yeterliyken offline post-session evaluation sırasında travel-direction diagnostic bilgisi olarak incelenebilir.)*

It must not be described or consumed as a phone-heading measurement. *(Phone-heading measurement olarak tanımlanmamalı veya tüketilmemelidir.)*

---

# 106. Denied Evaluation GNSS-Bearing Boundary (Denied Evaluation GNSS-Bearing Sınırı)

During a denied Evaluation interval, protected GNSS bearing is not authorized to correct or reset heading, enter the estimator, influence heading confidence, influence the navigation Quality Engine, or alter controller behavior. *(Denied Evaluation interval sırasında protected GNSS bearing heading'i düzeltemez veya resetleyemez, estimator'a giremez, heading confidence'i etkileyemez, navigation Quality Engine'i etkileyemez veya controller behavior'ı değiştiremez.)*

Motion, speed, bearing accuracy, or any other quality condition cannot authorize protected GNSS bearing during the denied interval. *(Motion, speed, bearing accuracy veya başka bir quality condition denied interval sırasında protected GNSS bearing'i authorize edemez.)*

Diagnostic thresholds for authorized GNSS Mode or offline evaluation remain pending field evidence and are not estimator-authorization thresholds. *(Authorized GNSS Mode veya offline evaluation için diagnostic eşikler field evidence beklemektedir ve estimator-authorization threshold'ları değildir.)*

---

# 107. Known Route Direction (Bilinen Rota Yönü)

Straight route segments with known geometry may provide an additional course-direction reference. *(Bilinen geometriye sahip düz rota segmentleri ek hareket yönü referansı sağlayabilir.)*

This information will be used only for evaluation and not leaked into the active heading estimator. *(Bu bilgi yalnızca değerlendirme için kullanılacak ve aktif yön tahmin motoruna sızdırılmayacaktır.)*

---

# 108. Heading Error (Yön Hatası)

Heading error will use circular angular difference. *(Yön hatası dairesel açısal fark kullanacaktır.)*

```
e_ψ =
atan2(
    sin(ψ_est - ψ_ref),
    cos(ψ_est - ψ_ref)
)
```

Absolute heading error will be represented as follows. *(Mutlak yön hatası aşağıdaki şekilde temsil edilecektir.)*

```
|e_ψ|
```

---

# 109. Heading MAE (Yön MAE)

For `n` valid reference observations, heading mean absolute error will be calculated as follows. *(`n` geçerli referans gözlemi için yön ortalama mutlak hatası aşağıdaki şekilde hesaplanacaktır.)*

```
Heading_MAE =
1/n · Σ |e_ψ,i|
```

The preferred reported unit will normally be degrees for readability. *(Tercih edilen raporlama birimi okunabilirlik için normalde derece olacaktır.)*

---

# 110. Heading RMSE (Yön RMSE)

Heading RMSE may additionally be reported using wrapped angular errors. *(Yön RMSE ayrıca wrap edilmiş açısal hatalar kullanılarak raporlanabilir.)*

```
Heading_RMSE =
√(
    1/n · Σ e_ψ,i²
)
```

---

# 111. P95 Heading Error (P95 Yön Hatası)

The 95th percentile of absolute heading error may be reported to characterize larger but less frequent errors. *(Mutlak yön hatasının 95. yüzdeliği daha büyük ancak daha seyrek hataları karakterize etmek için raporlanabilir.)*

This may be especially useful for identifying magnetic-disturbance failures. *(Bu özellikle manyetik bozulma hatalarını belirlemek için kullanışlı olabilir.)*

---

# 112. Heading Drift Metric (Yön Sürüklenme Metriği)

During gyro-dominant intervals, change in heading error over time may be used to characterize drift. *(Jiroskop ağırlıklı aralıklarda zaman içerisindeki yön hatası değişimi sürüklenmeyi karakterize etmek için kullanılabilir.)*

A candidate rate may be reported in degrees per minute. *(Aday oran derece/dakika cinsinden raporlanabilir.)*

No device-specific expected rate will be claimed before measurement. *(Ölçümden önce cihaza özgü beklenen oran iddia edilmeyecektir.)*

---

# 113. Heading Availability Metric (Yön Kullanılabilirlik Metriği)

NAVGUARD may calculate the proportion of a session for which a valid heading estimate was available. *(NAVGUARD bir oturumun geçerli yön tahmininin mevcut olduğu oranını hesaplayabilir.)*

```
HeadingAvailability =
ValidHeadingDuration
──────────────────── × 100
SessionDuration
```

---

# 114. Magnetic Disturbance Detection Metrics (Manyetik Bozulma Tespit Metrikleri)

If ground-truth disturbance labels can be reasonably created, disturbance detection may be evaluated separately. *(Gerçek referans bozulma etiketleri makul şekilde oluşturulabilirse bozulma tespiti ayrı olarak değerlendirilebilir.)*

Otherwise, disturbance flags will primarily be evaluated through their effect on heading error. *(Aksi halde bozulma flag’leri temel olarak yön hatası üzerindeki etkileri üzerinden değerlendirilecektir.)*

---

# 115. PDR-Level Heading Evaluation (PDR Seviyesinde Yön Değerlendirmesi)

Heading quality will not be judged only by angular metrics. *(Yön kalitesi yalnızca açısal metriklerle değerlendirilmeyecektir.)*

The improved heading configuration will also be evaluated by its effect on PDR position error. *(Geliştirilmiş yön yapılandırması ayrıca PDR konum hatası üzerindeki etkisiyle değerlendirilecektir.)*

This directly tests whether better heading translates into better navigation. *(Bu daha iyi yönün gerçekten daha iyi navigasyona dönüşüp dönüşmediğini doğrudan test eder.)*

---

# 116. Controlled Heading Ablation (Kontrollü Yön Ablation)

Configuration A and Configuration B should use the same step detector and step-length method when heading contribution is being isolated. *(Yön katkısı izole edilirken Yapılandırma A ve Yapılandırma B aynı adım algılayıcıyı ve adım uzunluğu yöntemini kullanmalıdır.)*

Only the heading method should change. *(Yalnızca yön yöntemi değişmelidir.)*

---

# 117. Heading Benchmark Comparison (Yön Benchmark Karşılaştırması)

```
Configuration A
(Yapılandırma A)

Baseline Magnetic Heading
(Temel Manyetik Yön)

        versus
        (karşı)

Configuration B
(Yapılandırma B)

Gyroscope + Quality-Controlled Magnetic Fusion
(Jiroskop + Kalite Kontrollü Manyetik Füzyon)
```

The primary research outcome will be whether Configuration B produces lower heading and navigation error on held-out sessions. *(Temel araştırma sonucu Yapılandırma B’nin ayrılmış oturumlarda daha düşük yön ve navigasyon hatası üretip üretmediği olacaktır.)*

---

# 118. Heading Dataset Requirements (Yön Veri Seti Gereksinimleri)

Heading development recordings should include stationary orientation tests. *(Yön geliştirme kayıtları sabit yönelim testlerini içermelidir.)*

They should include slow controlled rotations. *(Yavaş kontrollü dönüşleri içermelidir.)*

They should include normal walking. *(Normal yürüyüşü içermelidir.)*

They should include repeated turns. *(Tekrarlanan dönüşleri içermelidir.)*

They should include at least some naturally magnetically disturbed conditions. *(En azından bazı doğal manyetik olarak bozulmuş koşulları içermelidir.)*

---

# 119. Raw Heading-Related Logging (Ham Yönle İlişkili Kayıt)

Formal heading experiments will preserve raw accelerometer, gyroscope, and magnetometer streams. *(Resmî yön deneyleri ham ivmeölçer, jiroskop ve manyetometre akışlarını koruyacaktır.)*

Available rotation-vector streams will also be preserved for comparison. *(Mevcut rotation-vector akışları da karşılaştırma için korunacaktır.)*

---

# 120. Processed Heading Log (İşlenmiş Yön Kaydı)

A processed heading stream may use the following schema. *(İşlenmiş yön akışı aşağıdaki şemayı kullanabilir.)*

```
timestamp_ns,
magnetic_heading_rad,
declination_rad,
true_magnetic_heading_rad,
gyro_predicted_heading_rad,
fused_heading_rad,
pedestrian_heading_rad,
placement_offset_rad,
magnetic_quality,
heading_confidence,
heading_source
```

The exact schema will be versioned. *(Kesin şema sürümlenecektir.)*

---

# 121. Magnetic Diagnostic Log (Manyetik Tanı Kaydı)

A magnetic-quality diagnostic stream may contain the following fields. *(Manyetik kalite tanısal akışı aşağıdaki alanları içerebilir.)*

```
timestamp_ns,
field_x_ut,
field_y_ut,
field_z_ut,
field_magnitude_ut,
expected_field_magnitude,
android_accuracy,
heading_innovation_rad,
magnetic_quality
```

Unavailable values must remain explicitly unavailable rather than being replaced with fabricated zero measurements. *(Kullanılamayan değerler uydurulmuş sıfır ölçümlerle değiştirilmek yerine açıkça kullanılamaz kalmalıdır.)*

---

# 122. Gyroscope Diagnostic Log (Jiroskop Tanı Kaydı)

A gyroscope diagnostic stream may preserve initial bias and propagation information. *(Jiroskop tanısal akışı başlangıç bias’ını ve ilerletme bilgisini koruyabilir.)*

```
timestamp_ns,
gyro_x,
gyro_y,
gyro_z,
bias_x,
bias_y,
bias_z,
delta_time_s,
heading_delta_rad
```

---

# 123. Heading Configuration Snapshot (Yön Yapılandırma Anlık Görüntüsü)

Every formal session should identify the active heading configuration. *(Her resmî oturum aktif yön yapılandırmasını tanımlamalıdır.)*

```
headingVersion
baselineMethod
fusionMethod
magneticQualityMethod
declinationMethod
gyroBiasMethod
placementMode
placementOffset
headingFallbackPolicy
```

---

# 124. Heading Versioning (Yön Sürümleme)

Any change that alters numerical heading output must create a new heading-algorithm or preprocessing version. *(Sayısal yön çıktısını değiştiren herhangi bir değişiklik yeni yön algoritması veya ön işleme sürümü oluşturmalıdır.)*

This includes changes to fusion gain, magnetic quality thresholds, calibration behavior, or placement offset. *(Bu füzyon gain değerindeki, manyetik kalite eşiklerindeki, kalibrasyon davranışındaki veya yerleşim offset’indeki değişiklikleri içerir.)*

---

# 125. Live and Offline Equivalence (Canlı ve Çevrimdışı Eşdeğerlik)

The same recorded sensor sequence and frozen heading configuration should produce equivalent heading estimates in live and offline implementations. *(Aynı kaydedilmiş sensör dizisi ve sabitlenmiş yön yapılandırması canlı ve çevrimdışı uygulamalarda eşdeğer yön tahminleri üretmelidir.)*

Python may serve as a reference implementation for selected mathematical tests. *(Python seçilen matematiksel testler için referans uygulama olarak hizmet edebilir.)*

---

# 126. Heading Unit Tests (Yön Birim Testleri)

Angle normalization will be unit tested. *(Açı normalizasyonu birim test edilecektir.)*

Circular difference will be unit tested. *(Dairesel fark birim test edilecektir.)*

Declination correction will be unit tested. *(Sapma düzeltmesi birim test edilecektir.)*

Placement-offset correction will be unit tested. *(Yerleşim offset düzeltmesi birim test edilecektir.)*

---

# 127. Wrap-Around Unit Test (Wrap-Around Birim Testi)

The angular difference between `359°` and `1°` must be approximately `2°`, not `358°`. *(`359°` ile `1°` arasındaki açısal fark yaklaşık `2°` olmalıdır, `358°` olmamalıdır.)*

This test is mandatory because wrap-around errors can cause large false corrections. *(Bu test zorunludur çünkü wrap-around hataları büyük yanlış düzeltmeler oluşturabilir.)*

---

# 128. Declination Sign Unit Test (Sapma İşareti Birim Testi)

A synthetic positive declination must rotate magnetic heading eastward toward the corresponding true-heading convention according to the frozen formula. *(Sentetik pozitif sapma sabitlenmiş formüle göre manyetik yönü karşılık gelen gerçek yön kuralına doğru doğuya döndürmelidir.)*

Physical cardinal testing will provide the final end-to-end sign verification. *(Fiziksel ana yön testi nihai uçtan uca işaret doğrulamasını sağlayacaktır.)*

---

# 129. Gyroscope Integration Unit Test (Jiroskop Integrasyon Birim Testi)

Synthetic constant angular velocity over a known time interval will verify integrated angular change. *(Bilinen bir zaman aralığı boyunca sentetik sabit açısal hız integre edilmiş açısal değişimi doğrulayacaktır.)*

Actual integration will use supplied timestamps. *(Gerçek integrasyon sağlanan zaman damgalarını kullanacaktır.)*

---

# 130. Quaternion Tests (Quaternion Testleri)

Identity orientation must leave vectors unchanged. *(Identity yönelim vektörleri değiştirmeden bırakmalıdır.)*

Known `90°` rotations must produce expected transformed directions. *(Bilinen `90°` dönüşler beklenen dönüştürülmüş yönleri üretmelidir.)*

Quaternion normalization must preserve unit length within numerical tolerance. *(Quaternion normalizasyonu sayısal tolerans içerisinde birim uzunluğu korumalıdır.)*

---

# 131. Magnetic Fusion Unit Test (Manyetik Füzyon Birim Testi)

When magnetic quality is marked invalid, magnetic correction weight must become zero or follow the explicitly configured degraded policy. *(Manyetik kalite geçersiz olarak işaretlendiğinde manyetik düzeltme ağırlığı sıfır olmalı veya açıkça yapılandırılmış bozulmuş politikayı izlemelidir.)*

A disturbed measurement must not unexpectedly force a large heading jump. *(Bozulmuş bir ölçüm beklenmedik şekilde büyük yön sıçramasına zorlamamalıdır.)*

---

# 132. Heading Initialization Test (Yön Başlatma Testi)

PDR readiness must remain false until heading initialization meets the configured validity conditions. *(Yön başlatma yapılandırılmış geçerlilik koşullarını karşılayana kadar PDR hazırlığı false kalmalıdır.)*

A single invalid compass sample must not complete formal heading initialization. *(Tek bir geçersiz pusula örneği resmî yön başlatmayı tamamlamamalıdır.)*

---

# 133. Heading-to-PDR Integration Test (Yön-PDR Entegrasyon Testi)

Each accepted PDR step must receive a valid true-north heading according to the selected alignment policy. *(Kabul edilmiş her PDR adımı seçilen hizalama politikasına göre geçerli gerçek kuzey yönü almalıdır.)*

A magnetic-north-only value must not be silently passed as true-north heading. *(Yalnızca manyetik kuzey değeri sessizce gerçek kuzey yönü olarak geçirilmemelidir.)*

---

# 134. Stationary Physical Test (Sabit Fiziksel Test)

The Redmi Note 9 Pro will remain stationary at several known orientations while heading is logged. *(Redmi Note 9 Pro yön kaydedilirken birkaç bilinen yönelimde sabit kalacaktır.)*

The test will characterize noise, stability, bias, and magnetic quality. *(Test gürültüyü, kararlılığı, bias’ı ve manyetik kaliteyi karakterize edecektir.)*

---

# 135. Walking Physical Test (Yürüyüş Fiziksel Testi)

A straight outdoor walking session will compare baseline and fused heading under actual pedestrian motion. *(Düz dış mekân yürüyüş oturumu gerçek yaya hareketi altında temel ve füzyonlu yönü karşılaştıracaktır.)*

---

# 136. Turning Physical Test (Dönüş Fiziksel Testi)

A turn-heavy route will evaluate the target system’s ability to follow rapid heading changes without excessive lag. *(Dönüş yoğun bir rota hedef sistemin hızlı yön değişikliklerini aşırı gecikme olmadan takip etme yeteneğini değerlendirecektir.)*

---

# 137. Magnetic Degradation Physical Test (Manyetik Bozulma Fiziksel Testi)

Naturally different magnetic environments will be compared to determine whether the quality engine identifies degraded conditions. *(Kalite motorunun bozulmuş koşulları belirleyip belirlemediğini görmek için doğal olarak farklı manyetik ortamlar karşılaştırılacaktır.)*

---

# 138. Performance Requirement (Performans Gereksinimi)

Heading processing must remain lightweight enough for continuous on-device execution. *(Yön işleme sürekli cihaz üzerinde çalışma için yeterince hafif kalmalıdır.)*

The system will measure CPU cost, processing latency, and queue stability during combined sensor operation. *(Sistem birleşik sensör çalışması sırasında CPU maliyetini, işleme gecikmesini ve kuyruk kararlılığını ölçecektir.)*

---

# 139. No Cloud Dependency (Bulut Bağımlılığı Olmaması)

Core heading estimation will run entirely on the smartphone. *(Temel yön tahmini tamamen akıllı telefon üzerinde çalışacaktır.)*

No cloud service will be required to calculate orientation, magnetic correction, or fused heading during navigation. *(Navigasyon sırasında yönelim, manyetik düzeltme veya füzyonlu yön hesaplamak için bulut hizmeti gerekmeyecektir.)*

---

# 140. Minimum Heading System (Minimum Yön Sistemi)

The minimum heading system must obtain accelerometer and magnetometer measurements. *(Minimum yön sistemi ivmeölçer ve manyetometre ölçümlerini elde etmelidir.)*

It must calculate tilt-compensated magnetic orientation. *(Tilt telafili manyetik yönelimi hesaplamalıdır.)*

It must apply magnetic-declination correction. *(Manyetik sapma düzeltmesi uygulamalıdır.)*

It must produce normalized true-north heading. *(Normalize edilmiş gerçek kuzey yönü üretmelidir.)*

It must provide timestamped headings to PDR. *(PDR’ye zaman damgalı yönler sağlamalıdır.)*

---

# 141. Target Heading System (Hedef Yön Sistemi)

The target heading system will additionally use gyroscope-based short-term orientation propagation. *(Hedef yön sistemi ayrıca jiroskop tabanlı kısa dönem yönelim ilerletmesi kullanacaktır.)*

It will perform magnetic quality analysis. *(Manyetik kalite analizi gerçekleştirecektir.)*

It will dynamically control magnetic correction according to quality. *(Manyetik düzeltmeyi kaliteye göre dinamik olarak kontrol edecektir.)*

It will provide heading confidence. *(Yön güveni sağlayacaktır.)*

It will support controlled fallback between available orientation sources. *(Mevcut yönelim kaynakları arasında kontrollü geri dönüşü destekleyecektir.)*

---

# 142. Optional Heading Enhancements (İsteğe Bağlı Yön İyileştirmeleri)

Optional enhancements may include custom magnetometer calibration. *(İsteğe bağlı iyileştirmeler özel manyetometre kalibrasyonunu içerebilir.)*

Optional enhancements may include learned magnetic-disturbance detection. *(İsteğe bağlı iyileştirmeler öğrenilmiş manyetik bozulma tespitini içerebilir.)*

Optional enhancements may include automatic device-placement estimation. *(İsteğe bağlı iyileştirmeler otomatik cihaz yerleşimi tahminini içerebilir.)*

These features must not delay the minimum transparent heading baseline. *(Bu özellikler minimum şeffaf yön temelini geciktirmemelidir.)*

---

# 143. Heading Non-Goals (Yön Olmayan Hedefler)

The heading subsystem will not estimate geographic position. *(Yön alt sistemi coğrafi konum tahmin etmeyecektir.)*

The heading subsystem will not perform PDR displacement by itself. *(Yön alt sistemi kendi başına PDR yer değiştirmesi gerçekleştirmeyecektir.)*

The heading subsystem will not claim unrestricted arbitrary-phone-placement robustness in the minimum project. *(Yön alt sistemi minimum projede sınırsız keyfi telefon yerleşimi dayanıklılığı iddia etmeyecektir.)*

The heading subsystem will not treat Android platform-fused orientation as scientifically perfect ground truth. *(Yön alt sistemi Android platform füzyonlu yönelimi bilimsel olarak kusursuz gerçek referans kabul etmeyecektir.)*

---

# 144. Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kararlar)

NAVGUARD navigation heading will reference true north. *(NAVGUARD navigasyon yönü gerçek kuzeye referans verecektir.)*

The baseline heading will use tilt-compensated accelerometer and magnetometer orientation. *(Temel yön tilt telafili ivmeölçer ve manyetometre yönelimini kullanacaktır.)*

Magnetic heading will receive explicit declination correction before PDR use. *(Manyetik yön PDR kullanımından önce açık sapma düzeltmesi alacaktır.)*

Raw magnetometer axes will not be converted directly into navigation heading without tilt compensation. *(Ham manyetometre eksenleri tilt compensation olmadan doğrudan navigasyon yönüne dönüştürülmeyecektir.)*

---

# 145. Additional Frozen Decisions (Ek Sabitlenmiş Kararlar)

The target improved heading will combine gyroscope propagation with quality-controlled absolute correction. *(Hedef geliştirilmiş yön jiroskop ilerletmesini kalite kontrollü mutlak düzeltmeyle birleştirecektir.)*

Circular mathematics will be mandatory for heading difference, interpolation, and fusion. *(Dairesel matematik yön farkı, interpolasyonu ve füzyonu için zorunlu olacaktır.)*

Magnetometer quality will influence magnetic correction weight. *(Manyetometre kalitesi manyetik düzeltme ağırlığını etkileyecektir.)*

A disturbed magnetometer will not be allowed to force unrestricted heading correction. *(Bozulmuş manyetometrenin sınırsız yön düzeltmesine zorlamasına izin verilmeyecektir.)*

---

# 146. Further Frozen Decisions (Diğer Sabitlenmiş Kararlar)

Android rotation-vector sensors will be treated as optional validated sources rather than mandatory dependencies. *(Android rotation-vector sensörleri zorunlu bağımlılıklar yerine isteğe bağlı doğrulanmış kaynaklar olarak ele alınacaktır.)*

`TYPE_GAME_ROTATION_VECTOR` will not be treated as absolute north heading. *(`TYPE_GAME_ROTATION_VECTOR`, mutlak kuzey yönü olarak ele alınmayacaktır.)*

Formal PDR experiments will use controlled phone placement. *(Resmî PDR deneyleri kontrollü telefon yerleşimi kullanacaktır.)*

A placement offset may be applied explicitly when device forward direction and pedestrian forward direction differ. *(Cihaz ileri yönü ile yaya ileri yönü farklı olduğunda açık şekilde yerleşim offset’i uygulanabilir.)*

---

# 147. Decisions Pending Measurement (Ölçüm Bekleyen Kararlar)

The final magnetic quality thresholds remain pending Redmi Note 9 Pro field measurements. *(Nihai manyetik kalite eşikleri Redmi Note 9 Pro saha ölçümlerini beklemektedir.)*

The final fusion correction gain remains pending comparative heading experiments. *(Nihai füzyon düzeltme gain değeri karşılaştırmalı yön deneylerini beklemektedir.)*

The final gyro-only confidence decay remains pending measured gyroscope drift. *(Nihai yalnızca jiroskop güven azalması ölçülmüş jiroskop sürüklenmesini beklemektedir.)*

The final heading freshness threshold remains pending measured update behavior. *(Nihai yön güncellik eşiği ölçülen güncelleme davranışını beklemektedir.)*

The final initialization-stability requirement remains pending pilot tests. *(Nihai başlatma kararlılık gereksinimi pilot testleri beklemektedir.)*

The final placement offset remains pending the formal physical placement protocol. *(Nihai yerleşim offset’i resmî fiziksel yerleşim protokolünü beklemektedir.)*

---

# 148. Baseline Acceptance Criteria (Temel Kabul Kriterleri)

The physical device must provide usable accelerometer and magnetometer measurements. *(Fiziksel cihaz kullanılabilir ivmeölçer ve manyetometre ölçümleri sağlamalıdır.)*

The baseline must calculate a valid tilt-compensated magnetic azimuth under suitable conditions. *(Temel sistem uygun koşullarda geçerli tilt telafili manyetik azimut hesaplamalıdır.)*

Declination correction must produce a true-north-referenced heading. *(Sapma düzeltmesi gerçek kuzey referanslı yön üretmelidir.)*

The heading must remain correctly normalized across the `0°/360°` boundary. *(Yön `0°/360°` sınırı boyunca doğru şekilde normalize edilmiş kalmalıdır.)*

---

# 149. Improved Heading Acceptance Criteria (Geliştirilmiş Yön Kabul Kriterleri)

Gyroscope integration must use actual timestamps. *(Jiroskop integrasyonu gerçek zaman damgalarını kullanmalıdır.)*

Magnetic correction must respond to magnetic-quality state. *(Manyetik düzeltme manyetik kalite durumuna yanıt vermelidir.)*

Invalid magnetic measurements must not create uncontrolled heading jumps. *(Geçersiz manyetik ölçümler kontrolsüz yön sıçramaları oluşturmamalıdır.)*

The system must continue with documented degraded behavior during temporary magnetic disturbance when gyroscope data remains usable. *(Jiroskop verisi kullanılabilir kaldığında sistem geçici manyetik bozulma sırasında dokümante edilmiş bozulmuş davranışla devam etmelidir.)*

---

# 150. PDR Integration Acceptance Criteria (PDR Entegrasyon Kabul Kriterleri)

Every propagated PDR step must receive a true-north-referenced heading or explicitly documented fallback behavior. *(İlerletilen her PDR adımı gerçek kuzey referanslı yön veya açıkça dokümante edilmiş geri dönüş davranışı almalıdır.)*

A stale or invalid heading must not silently propagate a normal-confidence step. *(Eski veya geçersiz yön normal güvenli bir adımı sessizce ilerletmemelidir.)*

Heading source and confidence must remain traceable for each formal PDR update. *(Yön kaynağı ve güveni her resmî PDR güncellemesi için izlenebilir kalmalıdır.)*

---

# 151. Experimental Acceptance Criteria (Deneysel Kabul Kriterleri)

The baseline and improved heading methods must be compared on held-out physical sessions. *(Temel ve geliştirilmiş yön yöntemleri ayrılmış fiziksel oturumlarda karşılaştırılmalıdır.)*

The comparison must include direct angular error where valid reference information exists. *(Karşılaştırma geçerli referans bilgisi mevcut olduğunda doğrudan açısal hatayı içermelidir.)*

The comparison must also include downstream PDR position performance. *(Karşılaştırma ayrıca aşağı akış PDR konum performansını içermelidir.)*

Any claimed heading improvement must be supported by stored experimental evidence. *(İddia edilen herhangi bir yön iyileştirmesi saklanmış deneysel kanıtla desteklenmelidir.)*

---

# 152. Source Basis (Kaynak Temeli)

The Android tilt-compensated world-frame and magnetic-azimuth definitions used by this design are based on the current official `SensorManager` documentation. *(Bu tasarım tarafından kullanılan Android tilt telafili dünya çerçevesi ve manyetik azimut tanımları güncel resmî `SensorManager` dokümantasyonuna dayanmaktadır.)*

The magnetic-declination model is based on the current official Android `GeomagneticField` documentation. *(Manyetik sapma modeli güncel resmî Android `GeomagneticField` dokümantasyonuna dayanmaktadır.)*

The Android rotation-vector and game-rotation-vector behavior is based on the current official Android sensor documentation. *(Android rotation-vector ve game-rotation-vector davranışı güncel resmî Android sensör dokümantasyonuna dayanmaktadır.)*

The decision to avoid the deprecated Android orientation sensor is based on the current official Android `Sensor` documentation. *(Deprecated Android yönelim sensöründen kaçınma kararı güncel resmî Android `Sensor` dokümantasyonuna dayanmaktadır.)*

---

# 153. Final Heading Architecture Statement (Nihai Yön Mimarisi Bildirimi)

**NAVGUARD will estimate pedestrian travel heading relative to true north and will use that heading as the directional input to step-based PDR.** *(NAVGUARD yaya hareket yönünü gerçek kuzeye göre tahmin edecek ve bu yönü adım tabanlı PDR’nin yönsel girdisi olarak kullanacaktır.)*

**The transparent baseline will calculate tilt-compensated magnetic orientation from accelerometer and magnetometer measurements and convert magnetic heading to true heading using location- and time-dependent magnetic declination.** *(Şeffaf temel sistem ivmeölçer ve manyetometre ölçümlerinden tilt telafili manyetik yönelim hesaplayacak ve konum ile zamana bağlı manyetik sapmayı kullanarak manyetik yönü gerçek yöne dönüştürecektir.)*

**The improved heading system will propagate short-term orientation using gyroscope information and will apply quality-controlled absolute magnetic correction only when the magnetic environment is considered trustworthy.** *(Geliştirilmiş yön sistemi kısa dönem yönelimi jiroskop bilgisi kullanarak ilerletecek ve kalite kontrollü mutlak manyetik düzeltmeyi yalnızca manyetik ortam güvenilir kabul edildiğinde uygulayacaktır.)*

**Android rotation-vector outputs will be recorded and validated as useful platform-fused comparison or fallback sources, but they will not be treated as independent scientific ground truth.** *(Android rotation-vector çıktıları kullanışlı platform füzyonlu karşılaştırma veya geri dönüş kaynakları olarak kaydedilip doğrulanacak ancak bağımsız bilimsel gerçek referans olarak ele alınmayacaktır.)*

**Circular-angle mathematics will be mandatory throughout heading normalization, interpolation, error calculation, and fusion so that the `0°/360°` boundary cannot create artificial orientation errors.** *(Dairesel açı matematiği yön normalizasyonu, interpolasyonu, hata hesabı ve füzyon boyunca zorunlu olacak; böylece `0°/360°` sınırı yapay yönelim hataları oluşturamayacaktır.)*

**Formal NAVGUARD experiments will use controlled phone placement, and an explicitly calibrated placement offset will be used when device-forward direction differs from pedestrian-forward direction.** *(Resmî NAVGUARD deneyleri kontrollü telefon yerleşimi kullanacak ve cihaz ileri yönü yaya ileri yönünden farklı olduğunda açıkça kalibre edilmiş yerleşim offset’i kullanılacaktır.)*

---

# 154. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development Heading Estimation Architecture Completed *(Doküman Durumu: Geliştirme Öncesi Yön Tahmin Mimarisi Tamamlandı)*

**Navigation Reference:** True North *(Navigasyon Referansı: Gerçek Kuzey)*

**Heading Convention:** Clockwise from True North *(Yön Kuralı: Gerçek Kuzeyden Saat Yönünde)*

**Baseline Heading:** Accelerometer + Magnetometer Tilt-Compensated Magnetic Orientation *(Temel Yön: İvmeölçer + Manyetometre Tilt Telafili Manyetik Yönelim)*

**True-North Conversion:** Android `GeomagneticField` Declination *(Gerçek Kuzey Dönüşümü: Android `GeomagneticField` Sapması)*

**Improved Heading:** Gyroscope Propagation + Quality-Controlled Magnetic Correction *(Geliştirilmiş Yön: Jiroskop İlerletmesi + Kalite Kontrollü Manyetik Düzeltme)*

**Rotation Vector:** Optional Comparison / Fallback *(Rotation Vector: İsteğe Bağlı Karşılaştırma / Geri Dönüş)*

**Game Rotation Vector:** Relative Orientation Only *(Game Rotation Vector: Yalnızca Göreli Yönelim)*

**Magnetic Disturbance Handling:** Mandatory for Target System *(Manyetik Bozulma Yönetimi: Hedef Sistem İçin Zorunlu)*

**Angle Processing:** Circular Mathematics *(Açı İşleme: Dairesel Matematik)*

**Phone Placement:** Controlled for Formal Benchmarks *(Telefon Yerleşimi: Resmî Benchmark’lar İçin Kontrollü)*

**Placement Offset:** Explicitly Calibrated if Required *(Yerleşim Offset’i: Gerekirse Açıkça Kalibre Edilecek)*

**Primary Heading Metric:** Circular Heading MAE *(Temel Yön Metriği: Dairesel Yön MAE)*

**Additional Metrics:** RMSE / P95 / Drift / Availability / PDR Position Impact *(Ek Metrikler: RMSE / P95 / Sürüklenme / Kullanılabilirlik / PDR Konum Etkisi)*

**Final Magnetic Thresholds:** Pending Redmi Note 9 Pro Measurements *(Nihai Manyetik Eşikler: Redmi Note 9 Pro Ölçümleri Bekleniyor)*

**Final Fusion Gain:** Pending Comparative Experiments *(Nihai Füzyon Gain Değeri: Karşılaştırmalı Deneyler Bekleniyor)*

**Final Gyro-Only Limit:** Pending Measured Drift *(Nihai Yalnızca Jiroskop Sınırı: Ölçülmüş Sürüklenme Bekleniyor)*

**Next Documentation Item:** 19 — ARCore Visual-Inertial Tracking *(Sonraki Dokümantasyon Öğesi: 19 — ARCore Görsel-Ataletsel Takip)*
