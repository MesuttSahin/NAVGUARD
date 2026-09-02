# 14 — Coordinate Systems & Mathematical Foundations (Koordinat Sistemleri ve Matematiksel Temeller)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the coordinate systems, reference frames, mathematical notation, units, orientation conventions, geographic transformations, local-navigation equations, quaternion operations, heading conventions, distance calculations, and transformation rules used throughout NAVGUARD. *(Bu doküman, NAVGUARD genelinde kullanılan koordinat sistemlerini, referans çerçevelerini, matematiksel gösterimi, birimleri, yönelim kurallarını, coğrafi dönüşümleri, yerel navigasyon denklemlerini, quaternion işlemlerini, yön kurallarını, mesafe hesaplarını ve dönüşüm kurallarını tanımlar.)*

The objective is to ensure that every navigation subsystem uses the same mathematical definitions. *(Amaç, her navigasyon alt sisteminin aynı matematiksel tanımları kullanmasını sağlamaktır.)*

Coordinate ambiguity is considered a critical engineering risk because an otherwise correct algorithm can produce invalid navigation results when axes, angle directions, or reference frames are interpreted incorrectly. *(Koordinat belirsizliği kritik bir mühendislik riski olarak kabul edilir çünkü aksi halde doğru olan bir algoritma eksenler, açı yönleri veya referans çerçeveleri yanlış yorumlandığında geçersiz navigasyon sonuçları üretebilir.)*

---

# 2. Mathematical Design Principles (Matematiksel Tasarım İlkeleri)

NAVGUARD will use explicit coordinate-frame transformations rather than implicit axis assumptions. *(NAVGUARD örtük eksen varsayımları yerine açık koordinat çerçevesi dönüşümleri kullanacaktır.)*

Every vector must have a known coordinate frame. *(Her vektör bilinen bir koordinat çerçevesine sahip olmalıdır.)*

Every angle must have a documented unit and reference direction. *(Her açı dokümante edilmiş bir birime ve referans yönüne sahip olmalıdır.)*

Every transformation must clearly define its source and destination frames. *(Her dönüşüm kaynak ve hedef çerçevelerini açıkça tanımlamalıdır.)*

Internal navigation calculations will prefer SI units. *(Dahili navigasyon hesaplamaları SI birimlerini tercih edecektir.)*

---

# 3. Primary Coordinate Frames (Temel Koordinat Çerçeveleri)

NAVGUARD will use several coordinate frames for different purposes. *(NAVGUARD farklı amaçlar için birden fazla koordinat çerçevesi kullanacaktır.)*

The primary frames are the Android Device Frame, Android Magnetic World Frame, NAVGUARD ENU Navigation Frame, WGS84 Geodetic Frame, Earth-Centered Earth-Fixed Frame, and ARCore Local World Frame. *(Temel çerçeveler Android Cihaz Çerçevesi, Android Manyetik Dünya Çerçevesi, NAVGUARD ENU Navigasyon Çerçevesi, WGS84 Jeodezik Çerçevesi, Dünya Merkezli Dünya Sabit Çerçevesi ve ARCore Yerel Dünya Çerçevesidir.)*

These coordinate systems must not be treated as interchangeable. *(Bu koordinat sistemleri birbirinin yerine kullanılabilir olarak ele alınmamalıdır.)*

---

# 4. Coordinate Frame Abbreviations (Koordinat Çerçevesi Kısaltmaları)

| Symbol (Sembol) | Frame (Çerçeve) |
| --- | --- |
| **D** | Android Device Frame *(Android Cihaz Çerçevesi)* |
| **M** | Android Magnetic World Frame *(Android Manyetik Dünya Çerçevesi)* |
| **N** | NAVGUARD ENU Navigation Frame *(NAVGUARD ENU Navigasyon Çerçevesi)* |
| **ECEF** | Earth-Centered Earth-Fixed Frame *(Dünya Merkezli Dünya Sabit Çerçevesi)* |
| **G** | WGS84 Geodetic Coordinates *(WGS84 Jeodezik Koordinatları)* |
| **A** | ARCore Local World / Anchor Frame *(ARCore Yerel Dünya / Anchor Çerçevesi)* |
| **C** | ARCore Camera Frame *(ARCore Kamera Çerçevesi)* |

---

# 5. Vector Convention (Vektör Kuralı)

NAVGUARD mathematical documentation will represent vectors as column vectors unless explicitly stated otherwise. *(NAVGUARD matematiksel dokümantasyonu açıkça aksi belirtilmediği sürece vektörleri sütun vektörleri olarak temsil edecektir.)*

A three-dimensional vector will generally use the following form. *(Üç boyutlu bir vektör genel olarak aşağıdaki formu kullanacaktır.)*

```
v = [x, y, z]ᵀ
```

The superscript may identify the coordinate frame when ambiguity is possible. *(Belirsizlik mümkün olduğunda üst simge koordinat çerçevesini belirtebilir.)*

```
vᴺ = vector expressed in NAVGUARD ENU coordinates
(vᴺ = NAVGUARD ENU koordinatlarında ifade edilen vektör)
```

---

# 6. Matrix Convention (Matris Kuralı)

A rotation matrix `R_A_B` will transform a vector expressed in frame B into frame A. *(Bir `R_A_B` dönüş matrisi B çerçevesinde ifade edilen bir vektörü A çerçevesine dönüştürecektir.)*

```
vᴬ = R_A_B · vᴮ
```

This source-to-destination convention must remain consistent throughout implementation. *(Bu kaynak-hedef kuralı uygulama boyunca tutarlı kalmalıdır.)*

---

# 7. Rigid Transformation Convention (Katı Dönüşüm Kuralı)

A rigid transformation will combine rotation and translation. *(Bir katı dönüşüm dönme ve ötelemeyi birleştirecektir.)*

```
T_A_B =
┌         ┐
│ R_A_B t │
│ 0 0 0 1 │
└         ┘
```

`T_A_B` transforms homogeneous coordinates from frame B into frame A. *(`T_A_B`, homojen koordinatları B çerçevesinden A çerçevesine dönüştürür.)*

---

# 8. Transformation Composition (Dönüşüm Bileşimi)

Sequential transformations will use matrix multiplication. *(Ardışık dönüşümler matris çarpımı kullanacaktır.)*

```
T_A_C = T_A_B · T_B_C
```

The multiplication order must never be changed merely to satisfy implementation convenience. *(Çarpım sırası yalnızca uygulama kolaylığı sağlamak amacıyla değiştirilmemelidir.)*

---

# 9. Transformation Inverse (Dönüşüm Tersi)

For a rigid transform with rotation `R` and translation `t`, the inverse is defined as follows. *(Dönme `R` ve öteleme `t` içeren bir katı dönüşüm için ters dönüşüm aşağıdaki şekilde tanımlanır.)*

```
T⁻¹ =
┌              ┐
│ Rᵀ   -Rᵀ · t │
│ 0 0 0    1   │
└              ┘
```

A valid rotation matrix satisfies `R⁻¹ = Rᵀ`. *(Geçerli bir dönüş matrisi `R⁻¹ = Rᵀ` koşulunu sağlar.)*

---

# 10. Unit Convention (Birim Kuralı)

NAVGUARD will use metres for internal position and displacement calculations. *(NAVGUARD dahili konum ve yer değiştirme hesaplamalarında metre kullanacaktır.)*

Velocity will use metres per second. *(Hız metre/saniye kullanacaktır.)*

Acceleration will use metres per second squared. *(İvme metre/saniye kare kullanacaktır.)*

Angular velocity will use radians per second. *(Açısal hız radyan/saniye kullanacaktır.)*

Internal angular mathematics will generally use radians. *(Dahili açısal matematik genel olarak radyan kullanacaktır.)*

User-interface heading values may use degrees. *(Kullanıcı arayüzü yön değerleri derece kullanabilir.)*

---

# 11. Degree and Radian Conversion (Derece ve Radyan Dönüşümü)

Degree-to-radian conversion will use the following relation. *(Dereceden radyana dönüşüm aşağıdaki ilişkiyi kullanacaktır.)*

```
rad = deg × π / 180
```

Radian-to-degree conversion will use the following relation. *(Radyandan dereceye dönüşüm aşağıdaki ilişkiyi kullanacaktır.)*

```
deg = rad × 180 / π
```

Explicit conversion functions should be used instead of repeatedly embedding conversion constants throughout the source code. *(Dönüşüm sabitlerini kaynak kodun farklı yerlerine tekrar tekrar gömmek yerine açık dönüşüm fonksiyonları kullanılmalıdır.)*

---

# 12. Android Device Coordinate Frame — D (Android Cihaz Koordinat Çerçevesi — D)

Android sensors use a device-relative three-axis coordinate frame. *(Android sensörleri cihaza göreli üç eksenli bir koordinat çerçevesi kullanır.)*

When the device is in its natural orientation, positive X points toward the right side of the screen, positive Y points toward the top of the device, and positive Z points outward from the front face of the screen. *(Cihaz doğal yönelimindeyken pozitif X ekranın sağ tarafına, pozitif Y cihazın üst tarafına ve pozitif Z ekranın ön yüzünden dışarı doğru yönelir.)*

```
             +Y
             ↑
             │
             │
      ┌──────────────┐
      │              │
      │    DEVICE    │ ─────► +X
      │              │
      └──────────────┘
             ⊙ +Z
      Out of screen
      (Ekranın dışına)
```

---

# 13. Android Sensor Frame Does Not Follow Screen Rotation (Android Sensör Çerçevesi Ekran Dönüşünü Takip Etmez)

The Android sensor coordinate axes are not swapped when display orientation changes. *(Android sensör koordinat eksenleri ekran yönelimi değiştiğinde değiştirilmez.)*

NAVGUARD will therefore never use Flutter screen orientation as the physical sensor reference frame. *(Bu nedenle NAVGUARD Flutter ekran yönelimini fiziksel sensör referans çerçevesi olarak hiçbir zaman kullanmayacaktır.)*

---

# 14. Device-Frame Sensor Vectors (Cihaz Çerçevesi Sensör Vektörleri)

Raw accelerometer measurements will initially be expressed as follows. *(Ham ivmeölçer ölçümleri başlangıçta aşağıdaki şekilde ifade edilecektir.)*

```
aᴰ = [aₓ, aᵧ, a_z]ᵀ
```

Raw gyroscope measurements will initially be expressed as follows. *(Ham jiroskop ölçümleri başlangıçta aşağıdaki şekilde ifade edilecektir.)*

```
ωᴰ = [ωₓ, ωᵧ, ω_z]ᵀ
```

Raw magnetometer measurements will initially be expressed as follows. *(Ham manyetometre ölçümleri başlangıçta aşağıdaki şekilde ifade edilecektir.)*

```
mᴰ = [mₓ, mᵧ, m_z]ᵀ
```

---

# 15. Android Magnetic World Frame — M (Android Manyetik Dünya Çerçevesi — M)

Android can construct a world-relative rotation matrix using gravity and geomagnetic measurements. *(Android yerçekimi ve jeomanyetik ölçümleri kullanarak dünya göreli bir dönüş matrisi oluşturabilir.)*

In this Android world frame, X points approximately east, Y points toward magnetic north, and Z points toward the sky. *(Bu Android dünya çerçevesinde X yaklaşık olarak doğuya, Y manyetik kuzeye ve Z gökyüzüne doğru yönelir.)*

```
X_M = East
Y_M = Magnetic North
Z_M = Up
```

This frame is similar to ENU but uses magnetic north rather than true geodetic north. *(Bu çerçeve ENU’ya benzer ancak gerçek jeodezik kuzey yerine manyetik kuzeyi kullanır.)*

---

# 16. NAVGUARD Navigation Frame — N (NAVGUARD Navigasyon Çerçevesi — N)

NAVGUARD will use a local East-North-Up coordinate system as its primary navigation frame. *(NAVGUARD temel navigasyon çerçevesi olarak yerel Doğu-Kuzey-Yukarı koordinat sistemini kullanacaktır.)*

```
X_N = East
Y_N = True North
Z_N = Up
```

The frame will be right-handed. *(Çerçeve sağ elli olacaktır.)*

---

# 17. ENU Axis Definition (ENU Eksen Tanımı)

A NAVGUARD local-position vector will be represented as follows. *(Bir NAVGUARD yerel konum vektörü aşağıdaki şekilde temsil edilecektir.)*

```
pᴺ = [E, N, U]ᵀ
```

`E` represents displacement toward east. *(`E`, doğuya doğru yer değiştirmeyi temsil eder.)*

`N` represents displacement toward true north. *(`N`, gerçek kuzeye doğru yer değiştirmeyi temsil eder.)*

`U` represents displacement upward relative to the local tangent plane. *(`U`, yerel teğet düzleme göre yukarı doğru yer değiştirmeyi temsil eder.)*

---

# 18. Primary Navigation Dimensionality (Temel Navigasyon Boyutu)

The primary NAVGUARD pedestrian-navigation problem will be treated as a horizontal two-dimensional navigation problem. *(Temel NAVGUARD yaya navigasyonu problemi yatay iki boyutlu bir navigasyon problemi olarak ele alınacaktır.)*

The primary estimator output will therefore focus on East and North displacement. *(Bu nedenle temel tahmin motoru çıktısı Doğu ve Kuzey yer değiştirmesine odaklanacaktır.)*

```
p_horizontal = [E, N]ᵀ
```

Vertical displacement may still be recorded or investigated without becoming mandatory to the baseline estimator. *(Dikey yer değiştirme temel tahmin motoru için zorunlu hale gelmeden yine de kaydedilebilir veya araştırılabilir.)*

---

# 19. Local Navigation Origin (Yerel Navigasyon Başlangıç Noktası)

The local navigation frame will be anchored to an accepted GNSS position. *(Yerel navigasyon çerçevesi kabul edilen bir GNSS konumuna sabitlenecektir.)*

The accepted anchor will be represented by the following geodetic coordinates. *(Kabul edilen çapa aşağıdaki jeodezik koordinatlarla temsil edilecektir.)*

```
φ₀ = anchor latitude
λ₀ = anchor longitude
h₀ = anchor ellipsoidal height
```

The corresponding local ENU coordinate will be defined as the origin. *(Karşılık gelen yerel ENU koordinatı başlangıç noktası olarak tanımlanacaktır.)*

```
E₀ = 0
N₀ = 0
U₀ = 0
```

---

# 20. Anchor Immutability During GNSS Denial (GNSS Kesintisi Sırasında Çapanın Değişmezliği)

The initial geographic anchor will remain fixed during the primary GNSS-denied evaluation interval. *(Başlangıç coğrafi çapası temel GNSS kesintili değerlendirme aralığında sabit kalacaktır.)*

Ground-truth GNSS updates recorded during Evaluation Mode must not move the anchor used by the denied estimator. *(Değerlendirme Modu sırasında kaydedilen gerçek referans GNSS güncellemeleri kesintili tahmin motoru tarafından kullanılan çapayı hareket ettirmemelidir.)*

A new anchor may be established only through the controlled relocalization process. *(Yeni bir çapa yalnızca kontrollü yeniden konumlandırma işlemi üzerinden oluşturulabilir.)*

---

# 21. Global Geographic Frame — WGS84 (Global Coğrafi Çerçeve — WGS84)

NAVGUARD will use WGS84 geodetic latitude and longitude for its global geographic position representation. *(NAVGUARD global coğrafi konum temsili için WGS84 jeodezik enlem ve boylamını kullanacaktır.)*

The WGS84 ellipsoid has a semi-major axis of `6378137.0 m` and an inverse flattening of `298.257223563`. *(WGS84 elipsoidi `6378137.0 m` yarı büyük eksene ve `298.257223563` ters basıklık değerine sahiptir.)*

---

# 22. WGS84 Constants (WGS84 Sabitleri)

The primary constants will be defined as follows. *(Temel sabitler aşağıdaki şekilde tanımlanacaktır.)*

```
a = 6378137.0 m

1/f = 298.257223563

f = 1 / 298.257223563
```

The first eccentricity squared will be calculated as follows. *(Birinci dış merkezlik karesi aşağıdaki şekilde hesaplanacaktır.)*

```
e² = f(2 - f)
```

These constants will be centralized rather than duplicated throughout multiple modules. *(Bu sabitler birden fazla modülde tekrarlanmak yerine merkezileştirilecektir.)*

---

# 23. Geodetic Coordinate Representation (Jeodezik Koordinat Temsili)

A WGS84 geodetic position will be represented as follows. *(Bir WGS84 jeodezik konumu aşağıdaki şekilde temsil edilecektir.)*

```
g = [φ, λ, h]
```

`φ` represents geodetic latitude. *(`φ`, jeodezik enlemi temsil eder.)*

`λ` represents geodetic longitude. *(`λ`, jeodezik boylamı temsil eder.)*

`h` represents ellipsoidal height above the WGS84 ellipsoid. *(`h`, WGS84 elipsoidi üzerindeki elipsoidal yüksekliği temsil eder.)*

---

# 24. Latitude Convention (Enlem Kuralı)

Latitude will be positive north of the equator and negative south of the equator. *(Enlem ekvatorun kuzeyinde pozitif, güneyinde negatif olacaktır.)*

User-facing latitude values will normally be represented in degrees. *(Kullanıcıya görünen enlem değerleri normalde derece cinsinden temsil edilecektir.)*

Mathematical trigonometric calculations will convert latitude to radians first. *(Matematiksel trigonometrik hesaplamalar önce enlemi radyana dönüştürecektir.)*

---

# 25. Longitude Convention (Boylam Kuralı)

Longitude will be positive east of the prime meridian and negative west of the prime meridian. *(Boylam başlangıç meridyeninin doğusunda pozitif, batısında negatif olacaktır.)*

User-facing longitude values will normally be represented in degrees. *(Kullanıcıya görünen boylam değerleri normalde derece cinsinden temsil edilecektir.)*

Internal trigonometric calculations will use radians. *(Dahili trigonometrik hesaplamalar radyan kullanacaktır.)*

---

# 26. Altitude Convention (Yükseklik Kuralı)

Android `Location` altitude represents metres above the WGS84 reference ellipsoid when altitude is available. *(Android `Location` yüksekliği mevcut olduğunda WGS84 referans elipsoidinin üzerindeki metreyi temsil eder.)*

NAVGUARD will therefore retain raw Android altitude as ellipsoidal height rather than silently treating it as mean-sea-level altitude. *(Bu nedenle NAVGUARD ham Android yüksekliğini sessizce ortalama deniz seviyesi yüksekliği olarak ele almak yerine elipsoidal yükseklik olarak koruyacaktır.)*

The primary horizontal estimator will not depend on precise altitude accuracy. *(Temel yatay tahmin motoru hassas yükseklik doğruluğuna bağımlı olmayacaktır.)*

---

# 27. Earth-Centered Earth-Fixed Frame — ECEF (Dünya Merkezli Dünya Sabit Çerçevesi — ECEF)

ECEF will provide the intermediate Cartesian frame used for accurate transformation between geographic coordinates and local ENU coordinates. *(ECEF, coğrafi koordinatlar ile yerel ENU koordinatları arasındaki doğru dönüşüm için kullanılan ara Kartezyen çerçeveyi sağlayacaktır.)*

An ECEF position will be represented as follows. *(Bir ECEF konumu aşağıdaki şekilde temsil edilecektir.)*

```
p_ECEF = [X, Y, Z]ᵀ
```

The origin is located at the Earth’s center of mass according to the reference ellipsoid frame. *(Başlangıç noktası referans elipsoid çerçevesine göre Dünya’nın kütle merkezinde bulunur.)*

---

# 28. Prime Vertical Radius of Curvature (Asal Düşey Eğrilik Yarıçapı)

For geodetic latitude `φ`, the prime vertical radius of curvature will be calculated as follows. *(Jeodezik enlem `φ` için asal düşey eğrilik yarıçapı aşağıdaki şekilde hesaplanacaktır.)*

```
ν(φ) = a / √(1 - e² sin²φ)
```

This term is required by the WGS84 geodetic-to-ECEF conversion. *(Bu terim WGS84 jeodezik-ECEF dönüşümü için gereklidir.)*

---

# 29. Geodetic to ECEF Conversion (Jeodezikten ECEF’e Dönüşüm)

Given latitude `φ`, longitude `λ`, and ellipsoidal height `h`, NAVGUARD will calculate ECEF coordinates using the following equations. *(Enlem `φ`, boylam `λ` ve elipsoidal yükseklik `h` verildiğinde NAVGUARD ECEF koordinatlarını aşağıdaki denklemleri kullanarak hesaplayacaktır.)*

```
X = (ν + h) cosφ cosλ

Y = (ν + h) cosφ sinλ

Z = (ν(1 - e²) + h) sinφ
```

All angular inputs to these equations will use radians. *(Bu denklemlere verilen tüm açısal girdiler radyan kullanacaktır.)*

---

# 30. Anchor ECEF Position (Çapa ECEF Konumu)

The accepted GNSS anchor will first be converted into ECEF coordinates. *(Kabul edilen GNSS çapası önce ECEF koordinatlarına dönüştürülecektir.)*

```
p₀_ECEF = geodeticToECEF(φ₀, λ₀, h₀)
```

A second geographic point may then be converted in the same manner. *(İkinci bir coğrafi nokta daha sonra aynı şekilde dönüştürülebilir.)*

```
p_ECEF = geodeticToECEF(φ, λ, h)
```

---

# 31. ECEF Difference Vector (ECEF Fark Vektörü)

The Cartesian displacement from the anchor will be calculated as follows. *(Çapadan Kartezyen yer değiştirme aşağıdaki şekilde hesaplanacaktır.)*

```
Δp_ECEF = p_ECEF - p₀_ECEF
```

This displacement will then be rotated into the local ENU frame. *(Bu yer değiştirme daha sonra yerel ENU çerçevesine döndürülecektir.)*

---

# 32. ECEF to ENU Rotation (ECEF’ten ENU’ya Dönüş)

The ECEF displacement will be transformed into the local ENU frame using the anchor latitude and longitude. *(ECEF yer değiştirmesi çapa enlem ve boylamı kullanılarak yerel ENU çerçevesine dönüştürülecektir.)*

```
┌ E ┐
│ N │ =
└ U ┘

┌ -sinλ₀              cosλ₀             0      ┐
│ -sinφ₀ cosλ₀       -sinφ₀ sinλ₀      cosφ₀  │ · Δp_ECEF
│  cosφ₀ cosλ₀        cosφ₀ sinλ₀      sinφ₀  │
└                                                  ┘
```

This transformation defines East, North, and Up directly relative to the accepted anchor. *(Bu dönüşüm Doğu, Kuzey ve Yukarı yönlerini doğrudan kabul edilen çapaya göre tanımlar.)*

---

# 33. Local ENU Origin Verification (Yerel ENU Başlangıç Noktası Doğrulaması)

The anchor itself must transform to approximately zero displacement. *(Çapanın kendisi yaklaşık sıfır yer değiştirmeye dönüşmelidir.)*

```
geodeticToENU(anchor, anchor)
≈ [0, 0, 0]ᵀ
```

This will be one of the fundamental coordinate unit tests. *(Bu temel koordinat birim testlerinden biri olacaktır.)*

---

# 34. ENU to ECEF Conversion (ENU’dan ECEF’e Dönüşüm)

The inverse ENU transformation will use the transpose of the ECEF-to-ENU rotation matrix. *(Ters ENU dönüşümü ECEF-ENU dönüş matrisinin transpozunu kullanacaktır.)*

```
Δp_ECEF = R_ENU_ECEFᵀ · p_ENU
```

The anchor ECEF position will then be restored. *(Daha sonra çapa ECEF konumu geri eklenecektir.)*

```
p_ECEF = p₀_ECEF + Δp_ECEF
```

This position can then be converted back into WGS84 geodetic coordinates. *(Bu konum daha sonra WGS84 jeodezik koordinatlarına geri dönüştürülebilir.)*

---

# 35. ECEF to Geodetic Conversion (ECEF’ten Jeodeziğe Dönüşüm)

NAVGUARD will use a tested numerical or closed-form geodetic inverse implementation rather than an unverified custom approximation. *(NAVGUARD doğrulanmamış özel bir yaklaşım yerine test edilmiş sayısal veya kapalı form jeodezik ters dönüşüm uygulaması kullanacaktır.)*

A candidate Bowring-style formulation may be used and validated against reference coordinates. *(Aday olarak Bowring tarzı bir formülasyon kullanılabilir ve referans koordinatlara karşı doğrulanabilir.)*

The implementation will return latitude, longitude, and ellipsoidal height. *(Uygulama enlem, boylam ve elipsoidal yüksekliği döndürecektir.)*

---

# 36. ECEF Inverse Supporting Values (ECEF Ters Dönüşüm Destek Değerleri)

The semi-minor axis may be calculated as follows. *(Yarı küçük eksen aşağıdaki şekilde hesaplanabilir.)*

```
b = a(1 - f)
```

The second eccentricity squared may be calculated as follows. *(İkinci dış merkezlik karesi aşağıdaki şekilde hesaplanabilir.)*

```
e'² = (a² - b²) / b²
```

---

# 37. Candidate ECEF-to-Geodetic Equations (Aday ECEF-Jeodezik Denklemleri)

The horizontal radius will first be calculated as follows. *(Yatay yarıçap önce aşağıdaki şekilde hesaplanacaktır.)*

```
p = √(X² + Y²)
```

An auxiliary angle may then be calculated. *(Daha sonra yardımcı bir açı hesaplanabilir.)*

```
θ = atan2(Za, pb)
```

Longitude may be calculated as follows. *(Boylam aşağıdaki şekilde hesaplanabilir.)*

```
λ = atan2(Y, X)
```

Latitude may then be estimated as follows. *(Enlem daha sonra aşağıdaki şekilde tahmin edilebilir.)*

```
φ = atan2(
    Z + e'² b sin³θ,
    p - e² a cos³θ
)
```

Ellipsoidal height may then be calculated using the resulting latitude. *(Elipsoidal yükseklik daha sonra elde edilen enlem kullanılarak hesaplanabilir.)*

```
ν = a / √(1 - e² sin²φ)

h = p / cosφ - ν
```

The final implementation will be validated numerically before being used by the map output. *(Nihai uygulama harita çıktısı tarafından kullanılmadan önce sayısal olarak doğrulanacaktır.)*

---

# 38. Preferred Geographic Conversion Pipeline (Tercih Edilen Coğrafi Dönüşüm Hattı)

The preferred authoritative geographic transformation will use the following pipeline. *(Tercih edilen ana coğrafi dönüşüm aşağıdaki hattı kullanacaktır.)*

```
Latitude / Longitude / Height
            ↓
           ECEF
            ↓
        Local ENU
```

The inverse visualization path will use the reverse process. *(Ters görselleştirme hattı sürecin tersini kullanacaktır.)*

```
Local ENU
   ↓
 ECEF
   ↓
Latitude / Longitude / Height
```

---

# 39. Why ECEF Is Used (ECEF’in Kullanılma Nedeni)

ECEF provides a mathematically consistent bridge between curved-Earth geographic coordinates and local Cartesian navigation. *(ECEF eğri Dünya coğrafi koordinatları ile yerel Kartezyen navigasyon arasında matematiksel olarak tutarlı bir köprü sağlar.)*

This avoids spreading latitude-and-longitude approximations across multiple navigation modules. *(Bu, enlem ve boylam yaklaşımlarının birden fazla navigasyon modülüne dağılmasını önler.)*

PDR and EKF calculations will therefore remain primarily in metres rather than degrees. *(Bu nedenle PDR ve EKF hesaplamaları temel olarak derece yerine metre cinsinden kalacaktır.)*

---

# 40. Short-Distance Approximation (Kısa Mesafe Yaklaşımı)

For debugging or lightweight local checks, a small-displacement geographic approximation may also be used. *(Hata ayıklama veya hafif yerel kontroller için küçük yer değiştirmeli bir coğrafi yaklaşım da kullanılabilir.)*

This approximation will not replace the tested authoritative conversion when both are available. *(Her ikisi de mevcut olduğunda bu yaklaşım test edilmiş ana dönüşümün yerini almayacaktır.)*

---

# 41. Meridian Radius of Curvature (Meridyen Eğrilik Yarıçapı)

The meridian radius of curvature is defined as follows. *(Meridyen eğrilik yarıçapı aşağıdaki şekilde tanımlanır.)*

```
M(φ) =
a(1 - e²)
───────────────
(1 - e² sin²φ)^(3/2)
```

---

# 42. Approximate North-to-Latitude Conversion (Yaklaşık Kuzey-Enlem Dönüşümü)

For sufficiently small local displacement, latitude change may be approximated as follows. *(Yeterince küçük yerel yer değiştirme için enlem değişimi aşağıdaki şekilde yaklaşık hesaplanabilir.)*

```
Δφ ≈ N / (M + h)
```

The result is in radians. *(Sonuç radyan cinsindedir.)*

---

# 43. Approximate East-to-Longitude Conversion (Yaklaşık Doğu-Boylam Dönüşümü)

For sufficiently small local displacement, longitude change may be approximated as follows. *(Yeterince küçük yerel yer değiştirme için boylam değişimi aşağıdaki şekilde yaklaşık hesaplanabilir.)*

```
Δλ ≈ E / ((ν + h) cosφ)
```

The result is in radians. *(Sonuç radyan cinsindedir.)*

---

# 44. Approximate Local-to-Geographic Conversion (Yaklaşık Yerelden Coğrafi Dönüşüm)

The approximate geographic position may then be calculated as follows. *(Yaklaşık coğrafi konum daha sonra aşağıdaki şekilde hesaplanabilir.)*

```
φ ≈ φ₀ + Δφ

λ ≈ λ₀ + Δλ
```

This method will be used only where its error is negligible for the intended calculation or as a reference check. *(Bu yöntem yalnızca hatasının amaçlanan hesaplama için ihmal edilebilir olduğu durumlarda veya referans kontrolü olarak kullanılacaktır.)*

---

# 45. Heading Definition (Yön Tanımı)

NAVGUARD heading will represent horizontal direction measured clockwise from true north. *(NAVGUARD yönü gerçek kuzeyden saat yönünde ölçülen yatay yönü temsil edecektir.)*

```
0°   = North
90°  = East
180° = South
270° = West
```

This convention will be used by the navigation state and user interface. *(Bu kural navigasyon durumu ve kullanıcı arayüzü tarafından kullanılacaktır.)*

---

# 46. Heading Symbol (Yön Sembolü)

Heading will generally be represented by the symbol `ψ`. *(Yön genel olarak `ψ` sembolüyle temsil edilecektir.)*

```
ψ ∈ [0, 2π)
```

when expressed internally in radians. *(Dahili olarak radyan cinsinden ifade edildiğinde `ψ ∈ [0, 2π)` olacaktır.)*

```
ψ ∈ [0°, 360°)
```

when expressed in user-facing degrees. *(Kullanıcıya yönelik derece cinsinden ifade edildiğinde `ψ ∈ [0°, 360°)` olacaktır.)*

---

# 47. Heading Normalization (Yön Normalizasyonu)

A general radian heading will be normalized as follows. *(Genel bir radyan yönü aşağıdaki şekilde normalize edilecektir.)*

```
ψ_normalized = ((ψ mod 2π) + 2π) mod 2π
```

A degree representation will use the equivalent `360°` normalization. *(Derece temsili eşdeğer `360°` normalizasyonunu kullanacaktır.)*

---

# 48. Navigation Heading Versus Mathematical Angle (Navigasyon Yönü ile Matematiksel Açı)

Traditional Cartesian mathematics often measures angles counterclockwise from the positive X axis. *(Geleneksel Kartezyen matematik genellikle açıları pozitif X ekseninden saat yönünün tersine ölçer.)*

NAVGUARD heading instead measures clockwise from North. *(NAVGUARD yönü ise Kuzeyden saat yönünde ölçülür.)*

The two conventions must not be mixed. *(İki kural birbirine karıştırılmamalıdır.)*

---

# 49. Navigation-to-Cartesian Angle Conversion (Navigasyon Açısından Kartezyen Açıya Dönüşüm)

For the NAVGUARD ENU plane, a Cartesian angle may be related to navigation heading as follows. *(NAVGUARD ENU düzlemi için Kartezyen açı navigasyon yönüyle aşağıdaki şekilde ilişkilendirilebilir.)*

```
θ_cartesian = π/2 - ψ
```

The result must be normalized when required. *(Sonuç gerektiğinde normalize edilmelidir.)*

---

# 50. PDR Step Displacement (PDR Adım Yer Değiştirmesi)

For step length `L` and navigation heading `ψ`, the horizontal displacement will use the following equations. *(Adım uzunluğu `L` ve navigasyon yönü `ψ` için yatay yer değiştirme aşağıdaki denklemleri kullanacaktır.)*

```
ΔE = L sinψ

ΔN = L cosψ
```

This convention correctly produces northward displacement at `ψ = 0`. *(Bu kural `ψ = 0` olduğunda doğru şekilde kuzeye yer değiştirme üretir.)*

---

# 51. PDR Position Propagation (PDR Konum İlerletme)

The baseline PDR position will update as follows. *(Temel PDR konumu aşağıdaki şekilde güncellenecektir.)*

```
E_k = E_(k-1) + ΔE

N_k = N_(k-1) + ΔN
```

The resulting position remains relative to the original GNSS anchor. *(Ortaya çıkan konum orijinal GNSS çapasına göreli kalır.)*

---

# 52. Horizontal Displacement Magnitude (Yatay Yer Değiştirme Büyüklüğü)

The horizontal displacement magnitude will be calculated as follows. *(Yatay yer değiştirme büyüklüğü aşağıdaki şekilde hesaplanacaktır.)*

```
d = √(ΔE² + ΔN²)
```

This relation will also be used for local horizontal error calculation. *(Bu ilişki yerel yatay hata hesabı için de kullanılacaktır.)*

---

# 53. Heading From ENU Displacement (ENU Yer Değiştirmesinden Yön)

When a sufficiently reliable horizontal displacement vector exists, its navigation bearing may be calculated as follows. *(Yeterince güvenilir bir yatay yer değiştirme vektörü mevcut olduğunda navigasyon yönü aşağıdaki şekilde hesaplanabilir.)*

```
ψ = atan2(ΔE, ΔN)
```

The resulting angle will then be normalized into `[0, 2π)`. *(Ortaya çıkan açı daha sonra `[0, 2π)` aralığına normalize edilecektir.)*

---

# 54. Zero-Displacement Bearing Rule (Sıfır Yer Değiştirme Yön Kuralı)

Heading must not be derived from position displacement when horizontal displacement is effectively zero. *(Yatay yer değiştirme etkili olarak sıfır olduğunda yön konum yer değiştirmesinden türetilmemelidir.)*

`atan2(0, 0)` must not be interpreted as meaningful pedestrian direction. *(`atan2(0, 0)` anlamlı yaya yönü olarak yorumlanmamalıdır.)*

The previous valid heading or another orientation source may instead remain active. *(Bunun yerine önceki geçerli yön veya başka bir yönelim kaynağı aktif kalabilir.)*

---

# 55. Path Length Versus Net Displacement (Yol Uzunluğu ile Net Yer Değiştirme)

NAVGUARD will distinguish travelled path length from straight-line displacement. *(NAVGUARD kat edilen yol uzunluğunu doğrusal net yer değiştirmeden ayıracaktır.)*

Path length is the accumulated length of successive motion segments. *(Yol uzunluğu ardışık hareket parçalarının birikmiş uzunluğudur.)*

```
D_path = Σ d_k
```

Net displacement is the distance between the beginning and current position. *(Net yer değiştirme başlangıç konumu ile mevcut konum arasındaki mesafedir.)*

```
D_net = √((E-E₀)² + (N-N₀)²)
```

These quantities must not be used interchangeably in drift metrics. *(Bu büyüklükler sürüklenme metriklerinde birbirinin yerine kullanılmamalıdır.)*

---

# 56. Closed-Loop Error (Kapalı Döngü Hatası)

For a route intended to return to its starting point, closure error may be calculated as follows. *(Başlangıç noktasına dönmesi amaçlanan bir rota için kapanış hatası aşağıdaki şekilde hesaplanabilir.)*

```
E_closure = √(E_final² + N_final²)
```

This provides a useful PDR evaluation measure for square or loop experiments. *(Bu kare veya döngü deneyleri için kullanışlı bir PDR değerlendirme ölçüsü sağlar.)*

---

# 57. Position Error in ENU (ENU’da Konum Hatası)

Estimated and reference positions will preferably be compared in the same local ENU frame. *(Tahmini ve referans konumlar tercihen aynı yerel ENU çerçevesinde karşılaştırılacaktır.)*

```
e_E = E_est - E_ref

e_N = N_est - N_ref
```

The horizontal position error will be calculated as follows. *(Yatay konum hatası aşağıdaki şekilde hesaplanacaktır.)*

```
e_pos = √(e_E² + e_N²)
```

---

# 58. Why Error Is Calculated in Metres (Hatanın Neden Metre Cinsinden Hesaplandığı)

Latitude and longitude are angular quantities and do not represent equal physical distances in every direction or location. *(Enlem ve boylam açısal büyüklüklerdir ve her yönde veya konumda eşit fiziksel mesafeyi temsil etmez.)*

NAVGUARD will therefore convert reference and estimated geographic positions into a common metric coordinate frame before calculating primary position error. *(Bu nedenle NAVGUARD temel konum hatasını hesaplamadan önce referans ve tahmini coğrafi konumları ortak bir metrik koordinat çerçevesine dönüştürecektir.)*

---

# 59. Geographic Distance Calculation (Coğrafi Mesafe Hesabı)

A geographic distance function may be used for validation or external comparisons. *(Bir coğrafi mesafe fonksiyonu doğrulama veya harici karşılaştırmalar için kullanılabilir.)*

For short NAVGUARD test routes, local ENU distance will be the preferred primary metric because all navigation estimates already exist in that frame. *(Kısa NAVGUARD test rotalarında tüm navigasyon tahminleri zaten bu çerçevede bulunduğu için yerel ENU mesafesi tercih edilen temel metrik olacaktır.)*

---

# 60. GNSS Bearing Is Not Device Orientation (GNSS Bearing Cihaz Yönelimi Değildir)

Android `Location.getBearing()` represents the horizontal direction of travel associated with the location and is explicitly unrelated to physical device orientation. *(Android `Location.getBearing()`, konumla ilişkili yatay hareket yönünü temsil eder ve fiziksel cihaz yönelimiyle açıkça ilişkili değildir.)*

NAVGUARD must therefore not use GNSS bearing as though it directly represented where the smartphone is pointing. *(Bu nedenle NAVGUARD GNSS yönünü akıllı telefonun doğrudan baktığı yönü temsil ediyormuş gibi kullanmamalıdır.)*

---

# 61. GNSS Bearing at Low Speed (Düşük Hızda GNSS Yönü)

GNSS-derived movement bearing may become unstable when horizontal displacement or speed is small. *(GNSS kaynaklı hareket yönü yatay yer değiştirme veya hız küçük olduğunda kararsız hale gelebilir.)*

The project will therefore apply a motion or quality condition before using GNSS bearing as a heading-reference measurement. *(Bu nedenle proje GNSS yönünü yön referans ölçümü olarak kullanmadan önce hareket veya kalite koşulu uygulayacaktır.)*

The exact threshold will be determined experimentally. *(Kesin eşik deneysel olarak belirlenecektir.)*

---

# 62. Magnetic North Versus True North (Manyetik Kuzey ile Gerçek Kuzey)

The raw magnetometer and standard Android orientation calculations may reference magnetic north rather than true north. *(Ham manyetometre ve standart Android yönelim hesaplamaları gerçek kuzey yerine manyetik kuzeye referans verebilir.)*

NAVGUARD’s ENU frame will use true north. *(NAVGUARD’ın ENU çerçevesi gerçek kuzeyi kullanacaktır.)*

A magnetic-declination correction may therefore be required. *(Bu nedenle manyetik sapma düzeltmesi gerekebilir.)*

---

# 63. Magnetic Declination (Manyetik Sapma)

Magnetic declination `δ` represents the angular difference between magnetic north and true north at a given position and time. *(Manyetik sapma `δ`, belirli bir konum ve zamanda manyetik kuzey ile gerçek kuzey arasındaki açısal farkı temsil eder.)*

Android provides `GeomagneticField` to estimate magnetic declination from true north. *(Android gerçek kuzeye göre manyetik sapmayı tahmin etmek için `GeomagneticField` sağlar.)*

Positive Android declination means that magnetic north is rotated east of true north. *(Pozitif Android declination, manyetik kuzeyin gerçek kuzeyden doğuya doğru dönmüş olduğu anlamına gelir.)*

---

# 64. Magnetic-to-True Heading Conversion (Manyetik Yönden Gerçek Yöne Dönüşüm)

An initial heading conversion may use the following relation. *(İlk yön dönüşümü aşağıdaki ilişkiyi kullanabilir.)*

```
ψ_true = normalize(ψ_magnetic + δ)
```

The sign convention must be verified with controlled cardinal-direction tests before final heading integration. *(İşaret kuralı nihai yön entegrasyonundan önce kontrollü ana yön testleriyle doğrulanmalıdır.)*

---

# 65. Declination Update Policy (Sapma Güncelleme Politikası)

Magnetic declination changes slowly relative to the duration and distance of a typical NAVGUARD experiment. *(Manyetik sapma tipik bir NAVGUARD deneyinin süresi ve mesafesine göre yavaş değişir.)*

A declination value may therefore be calculated from the initial or current GNSS position and reused for a short session. *(Bu nedenle sapma değeri başlangıç veya mevcut GNSS konumundan hesaplanabilir ve kısa bir oturum boyunca yeniden kullanılabilir.)*

The exact implementation will be defined in the heading-estimation document. *(Kesin uygulama yön tahmini dokümanında tanımlanacaktır.)*

---

# 66. Android Orientation Matrix (Android Yönelim Matrisi)

Android `SensorManager.getRotationMatrix()` provides a matrix that transforms vectors from the device coordinate system into Android’s world coordinate system. *(Android `SensorManager.getRotationMatrix()`, vektörleri cihaz koordinat sisteminden Android dünya koordinat sistemine dönüştüren bir matris sağlar.)*

NAVGUARD may use this function as a validated Android orientation reference during development and comparison. *(NAVGUARD geliştirme ve karşılaştırma sırasında bu fonksiyonu doğrulanmış Android yönelim referansı olarak kullanabilir.)*

The resulting magnetic world frame must still be distinguished from the true-north ENU navigation frame. *(Ortaya çıkan manyetik dünya çerçevesi yine de gerçek kuzeyli ENU navigasyon çerçevesinden ayırt edilmelidir.)*

---

# 67. Device-to-Navigation Transformation (Cihazdan Navigasyon Çerçevesine Dönüşüm)

A device-frame vector may be transformed into the NAVGUARD navigation frame through an orientation matrix. *(Bir cihaz çerçevesi vektörü yönelim matrisi üzerinden NAVGUARD navigasyon çerçevesine dönüştürülebilir.)*

```
vᴺ = R_N_D · vᴰ
```

The transformation must include the correct true-north reference when directional accuracy requires it. *(Dönüşüm yön doğruluğu gerektirdiğinde doğru gerçek kuzey referansını içermelidir.)*

---

# 68. Gravity in the NAVGUARD Frame (NAVGUARD Çerçevesinde Yerçekimi)

With the ENU convention, the Up axis is positive upward. *(ENU kuralında Yukarı ekseni yukarı doğru pozitiftir.)*

The gravitational acceleration vector therefore points primarily in the negative Up direction. *(Bu nedenle yerçekimi ivme vektörü temel olarak negatif Yukarı yönüne işaret eder.)*

```
gᴺ ≈ [0, 0, -g]ᵀ
```

Sign conventions will be verified against actual Android accelerometer behavior because accelerometer specific force must not be confused with physical gravitational acceleration. *(İşaret kuralları gerçek Android ivmeölçer davranışına karşı doğrulanacaktır çünkü ivmeölçer specific force değeri fiziksel yerçekimi ivmesiyle karıştırılmamalıdır.)*

---

# 69. Quaternion Purpose (Quaternion Amacı)

Quaternions will provide the preferred compact representation for full three-dimensional orientation. *(Quaternion’lar tam üç boyutlu yönelim için tercih edilen kompakt temsili sağlayacaktır.)*

They avoid the singularity problems associated with representing all orientation operations directly through Euler angles. *(Tüm yönelim işlemlerini doğrudan Euler açılarıyla temsil etmekle ilişkili tekillik problemlerinden kaçınırlar.)*

---

# 70. Internal Quaternion Convention (Dahili Quaternion Kuralı)

NAVGUARD’s canonical internal quaternion ordering will be defined as follows. *(NAVGUARD’ın kanonik dahili quaternion sıralaması aşağıdaki şekilde tanımlanacaktır.)*

```
q = [w, x, y, z]
```

Every platform-specific quaternion must be converted to this canonical representation at an explicit adapter boundary. *(Her platforma özgü quaternion açık bir adapter sınırında bu kanonik temsile dönüştürülmelidir.)*

---

# 71. Android Quaternion Ordering (Android Quaternion Sıralaması)

Android `SensorManager.getQuaternionFromVector()` returns its quaternion as `[w, x, y, z]`. *(Android `SensorManager.getQuaternionFromVector()` quaternion’ı `[w, x, y, z]` sırasıyla döndürür.)*

This matches the planned NAVGUARD internal storage order. *(Bu planlanan NAVGUARD dahili depolama sırasıyla eşleşir.)*

---

# 72. ARCore Quaternion Ordering (ARCore Quaternion Sıralaması)

ARCore Pose represents quaternion rotation using the order `{x, y, z, w}` and uses the Hamilton convention. *(ARCore Pose quaternion dönüşünü `{x, y, z, w}` sırasıyla temsil eder ve Hamilton kuralını kullanır.)*

NAVGUARD must therefore reorder ARCore quaternion components before placing them into the canonical internal quaternion representation. *(Bu nedenle NAVGUARD ARCore quaternion bileşenlerini kanonik dahili quaternion temsiline yerleştirmeden önce yeniden sıralamalıdır.)*

```
ARCore:
[x, y, z, w]

NAVGUARD:
[w, x, y, z]
```

---

# 73. Unit Quaternion Requirement (Birim Quaternion Gereksinimi)

Orientation quaternions must remain normalized. *(Yönelim quaternion’ları normalize edilmiş kalmalıdır.)*

For quaternion `q`, its norm will be calculated as follows. *(`q` quaternion’ı için norm aşağıdaki şekilde hesaplanacaktır.)*

```
||q|| = √(w² + x² + y² + z²)
```

Normalization will use the following relation. *(Normalizasyon aşağıdaki ilişkiyi kullanacaktır.)*

```
q_normalized = q / ||q||
```

---

# 74. Invalid Quaternion Handling (Geçersiz Quaternion Yönetimi)

A quaternion with a near-zero norm will be considered invalid. *(Sıfıra yakın norma sahip bir quaternion geçersiz kabul edilecektir.)*

The implementation must not divide blindly by a near-zero quaternion norm. *(Uygulama sıfıra yakın bir quaternion normuna körlemesine bölme yapmamalıdır.)*

An invalid orientation measurement must be rejected and diagnosed. *(Geçersiz bir yönelim ölçümü reddedilmeli ve tanılanmalıdır.)*

---

# 75. Quaternion Conjugate (Quaternion Eşleniği)

For a unit quaternion, the conjugate will be represented as follows. *(Bir birim quaternion için eşlenik aşağıdaki şekilde temsil edilecektir.)*

```
q* = [w, -x, -y, -z]
```

For a unit quaternion, the conjugate also represents the inverse rotation. *(Bir birim quaternion için eşlenik aynı zamanda ters dönüşü temsil eder.)*

---

# 76. Quaternion Multiplication (Quaternion Çarpımı)

Quaternion composition order must be explicitly tested because multiplication is not commutative. *(Quaternion bileşim sırası açıkça test edilmelidir çünkü çarpım değişmeli değildir.)*

```
q₁ ⊗ q₂ ≠ q₂ ⊗ q₁
```

The chosen implementation will document whether a composed quaternion applies `q₂` first and then `q₁`. *(Seçilen uygulama birleşik quaternion’ın önce `q₂`, ardından `q₁` uygulayıp uygulamadığını dokümante edecektir.)*

---

# 77. Quaternion Vector Rotation (Quaternion ile Vektör Döndürme)

A three-dimensional vector may be represented as a pure quaternion. *(Üç boyutlu bir vektör saf quaternion olarak temsil edilebilir.)*

```
v_q = [0, vₓ, vᵧ, v_z]
```

For a unit rotation quaternion `q`, one common active-rotation formulation is as follows. *(Birim dönüş quaternion’ı `q` için yaygın bir aktif dönüş formülasyonu aşağıdaki gibidir.)*

```
v'_q = q ⊗ v_q ⊗ q*
```

The exact active-versus-passive interpretation must match the selected frame transformation convention. *(Kesin aktif-pasif yorum seçilen çerçeve dönüşüm kuralıyla eşleşmelidir.)*

---

# 78. Quaternion to Rotation Matrix (Quaternion’dan Dönüş Matrisine)

A normalized quaternion may be converted into a three-dimensional rotation matrix. *(Normalize edilmiş bir quaternion üç boyutlu dönüş matrisine dönüştürülebilir.)*

For `q = [w, x, y, z]`, the matrix may be written as follows. *(`q = [w, x, y, z]` için matris aşağıdaki şekilde yazılabilir.)*

```
R =

┌ 1-2(y²+z²)   2(xy-wz)     2(xz+wy)   ┐
│ 2(xy+wz)     1-2(x²+z²)   2(yz-wx)   │
│ 2(xz-wy)     2(yz+wx)     1-2(x²+y²) │
└                                        ┘
```

The implementation will use deterministic reference tests because quaternion matrix conventions can differ between libraries. *(Uygulama deterministik referans testleri kullanacaktır çünkü quaternion matris kuralları kütüphaneler arasında farklılık gösterebilir.)*

---

# 79. Rotation Matrix Properties (Dönüş Matrisi Özellikleri)

A valid three-dimensional rotation matrix must satisfy orthonormality. *(Geçerli bir üç boyutlu dönüş matrisi ortonormallik koşulunu sağlamalıdır.)*

```
RᵀR = I
```

Its determinant should be approximately `+1`. *(Determinantı yaklaşık `+1` olmalıdır.)*

```
det(R) ≈ 1
```

These properties may be checked in development assertions and tests. *(Bu özellikler geliştirme assertion’larında ve testlerde kontrol edilebilir.)*

---

# 80. Euler Angles Policy (Euler Açıları Politikası)

Yaw, pitch, and roll may be used for diagnostics, visualization, and selected algorithms. *(Yaw, pitch ve roll tanı, görselleştirme ve seçilen algoritmalar için kullanılabilir.)*

They will not be treated as the universal internal orientation representation. *(Evrensel dahili yönelim temsili olarak ele alınmayacaktır.)*

The exact Euler rotation order must always be documented when Euler angles are used. *(Euler açıları kullanıldığında kesin Euler dönüş sırası her zaman dokümante edilmelidir.)*

---

# 81. Gimbal Lock Awareness (Gimbal Lock Farkındalığı)

Euler-angle representations can encounter singular configurations commonly referred to as gimbal lock. *(Euler açı temsilleri yaygın olarak gimbal lock olarak adlandırılan tekil yapılandırmalarla karşılaşabilir.)*

NAVGUARD will therefore prefer quaternion or rotation-matrix calculations for complete three-dimensional orientation transformations. *(Bu nedenle NAVGUARD tam üç boyutlu yönelim dönüşümleri için quaternion veya dönüş matrisi hesaplamalarını tercih edecektir.)*

---

# 82. Heading Versus Yaw (Heading ile Yaw Ayrımı)

NAVGUARD heading is an Earth-referenced horizontal direction. *(NAVGUARD yönü Dünya referanslı yatay bir yöndür.)*

Yaw is a rotational quantity whose exact meaning depends on the selected coordinate frame and Euler convention. *(Yaw, kesin anlamı seçilen koordinat çerçevesine ve Euler kuralına bağlı olan dönme büyüklüğüdür.)*

The terms must not be used interchangeably without confirming the reference frame. *(Referans çerçevesi doğrulanmadan terimler birbirinin yerine kullanılmamalıdır.)*

---

# 83. Phone Orientation Versus User Travel Direction (Telefon Yönelimi ile Kullanıcı Hareket Yönü)

The direction in which the smartphone points may not always equal the direction in which the pedestrian is travelling. *(Akıllı telefonun baktığı yön her zaman yayanın hareket ettiği yönle aynı olmayabilir.)*

This difference depends strongly on phone placement and user behavior. *(Bu fark telefon yerleşimine ve kullanıcı davranışına güçlü şekilde bağlıdır.)*

NAVGUARD will therefore document the phone-placement protocol used during formal experiments. *(Bu nedenle NAVGUARD resmî deneyler sırasında kullanılan telefon yerleşim protokolünü dokümante edecektir.)*

---

# 84. Controlled Phone-Placement Requirement (Kontrollü Telefon Yerleşimi Gereksinimi)

The initial heading and PDR experiments will use a controlled phone-placement configuration. *(İlk yön ve PDR deneyleri kontrollü bir telefon yerleşim yapılandırması kullanacaktır.)*

The final placement definition will be frozen after pilot tests. *(Nihai yerleşim tanımı pilot testlerden sonra sabitlenecektir.)*

Supporting arbitrary pocket, hand, and bag placement simultaneously is outside the minimum project scope. *(Cep, el ve çanta yerleşimini aynı anda keyfi şekilde desteklemek minimum proje kapsamının dışındadır.)*

---

# 85. ARCore Coordinate System — A (ARCore Koordinat Sistemi — A)

ARCore poses use a right-handed coordinate system and translations are expressed in metres. *(ARCore pozları sağ elli bir koordinat sistemi kullanır ve ötelemeler metre cinsinden ifade edilir.)*

ARCore poses describe transformations from an object’s local coordinate space into ARCore world coordinate space. *(ARCore pozları bir nesnenin yerel koordinat alanından ARCore dünya koordinat alanına dönüşümleri tanımlar.)*

---

# 86. ARCore Physical Camera Axes (ARCore Fiziksel Kamera Eksenleri)

For the ARCore physical camera pose, positive X points right, positive Y points up, and negative Z points in the viewing direction. *(ARCore fiziksel kamera pozu için pozitif X sağa, pozitif Y yukarı ve negatif Z görüntüleme yönüne işaret eder.)*

```
Camera right   = +X
Camera up      = +Y
Camera forward = -Z
```

These axes must not be directly interpreted as East, North, and Up. *(Bu eksenler doğrudan Doğu, Kuzey ve Yukarı olarak yorumlanmamalıdır.)*

---

# 87. ARCore World Coordinates Are Local, Not Geographic (ARCore Dünya Koordinatları Yereldir, Coğrafi Değildir)

Standard ARCore pose coordinates do not directly represent latitude and longitude. *(Standart ARCore poz koordinatları doğrudan enlem ve boylamı temsil etmez.)*

NAVGUARD will therefore use ARCore primarily as a relative local-motion source. *(Bu nedenle NAVGUARD ARCore’u temel olarak göreli yerel hareket kaynağı olarak kullanacaktır.)*

No ARCore X or Z coordinate will be directly added to geographic longitude or latitude. *(Hiçbir ARCore X veya Z koordinatı doğrudan coğrafi boylam veya enleme eklenmeyecektir.)*

---

# 88. ARCore World Adjustment Risk (ARCore Dünya Ayarlama Riski)

ARCore may adjust its internal understanding of the world as tracking improves, and numerical camera or anchor coordinates may therefore change. *(ARCore takip geliştikçe dünyanın dahili modelini ayarlayabilir ve bu nedenle sayısal kamera veya anchor koordinatları değişebilir.)*

Google recommends using anchors or positions relative to nearby anchors when a physical position must persist beyond a single frame. *(Google fiziksel bir konum tek bir karenin ötesinde korunması gerektiğinde anchor veya yakındaki anchor’lara göreli konum kullanılmasını önerir.)*

NAVGUARD will therefore not treat raw ARCore world coordinates as a perfectly immutable global Cartesian frame. *(Bu nedenle NAVGUARD ham ARCore dünya koordinatlarını tamamen değişmez global Kartezyen çerçeve olarak ele almayacaktır.)*

---

# 89. NAVGUARD ARCore Anchor Strategy (NAVGUARD ARCore Anchor Stratejisi)

NAVGUARD will create or designate an ARCore local reference near the beginning of an ARCore-enabled navigation session. *(NAVGUARD ARCore etkin bir navigasyon oturumunun başlangıcına yakın bir ARCore yerel referans oluşturacak veya belirleyecektir.)*

Relative camera motion will preferably be evaluated with respect to that local anchor rather than raw standalone world-coordinate values. *(Göreli kamera hareketi tercihen bağımsız ham dünya koordinat değerleri yerine bu yerel anchor’a göre değerlendirilecektir.)*

---

# 90. Relative ARCore Pose (Göreli ARCore Pozu)

Let `T_W_C(k)` represent the current ARCore camera pose in ARCore world coordinates. *(`T_W_C(k)`, mevcut ARCore kamera pozunu ARCore dünya koordinatlarında temsil etsin.)*

Let `T_W_A(k)` represent the current pose of the selected local anchor in the same ARCore frame. *(`T_W_A(k)`, seçilen yerel anchor’ın mevcut pozunu aynı ARCore çerçevesinde temsil etsin.)*

The camera pose relative to the anchor may then be calculated as follows. *(Anchor’a göre kamera pozu daha sonra aşağıdaki şekilde hesaplanabilir.)*

```
T_A_C(k) =
T_W_A(k)⁻¹ · T_W_C(k)
```

This relative representation is more appropriate for persistent local motion than blindly differencing unrelated raw world coordinates. *(Bu göreli temsil, ilgisiz ham dünya koordinatlarını körlemesine fark almaktan daha kalıcı yerel hareket için uygundur.)*

---

# 91. ARCore Relative Translation (ARCore Göreli Öteleme)

The translation component of `T_A_C(k)` will provide local relative camera position in the anchor frame. *(`T_A_C(k)` dönüşümünün öteleme bileşeni anchor çerçevesinde yerel göreli kamera konumu sağlayacaktır.)*

```
pᴬ(k) = [x_A, y_A, z_A]ᵀ
```

This vector still requires alignment before it can be interpreted as East-North-Up displacement. *(Bu vektör Doğu-Kuzey-Yukarı yer değiştirme olarak yorumlanmadan önce hâlâ hizalama gerektirir.)*

---

# 92. ARCore-to-ENU Alignment (ARCore’dan ENU’ya Hizalama)

NAVGUARD will estimate a transformation between the local ARCore reference frame and the NAVGUARD ENU navigation frame. *(NAVGUARD yerel ARCore referans çerçevesi ile NAVGUARD ENU navigasyon çerçevesi arasında bir dönüşüm tahmin edecektir.)*

```
pᴺ = R_N_A · pᴬ
```

The transformation will be initialized from known orientation and heading information during calibration. *(Dönüşüm kalibrasyon sırasında bilinen yönelim ve yön bilgisinden başlatılacaktır.)*

The exact alignment procedure will be validated experimentally before ARCore displacement enters the final EKF. *(Kesin hizalama prosedürü ARCore yer değiştirmesi nihai EKF’ye girmeden önce deneysel olarak doğrulanacaktır.)*

---

# 93. ARCore Alignment Translation (ARCore Hizalama Ötelemesi)

When relative displacement from an anchor is used, the primary alignment requirement is rotational rather than global translational alignment. *(Bir anchor’dan göreli yer değiştirme kullanıldığında temel hizalama gereksinimi global öteleme hizalamasından ziyade dönme hizalamasıdır.)*

The initial GNSS position separately provides the global translation anchor. *(Başlangıç GNSS konumu global öteleme çapasını ayrı olarak sağlar.)*

This allows ARCore to contribute local movement without pretending that ARCore itself provides absolute geolocation. *(Bu, ARCore’un kendisinin mutlak coğrafi konum sağladığını varsaymadan yerel harekete katkı sağlamasına izin verir.)*

---

# 94. ARCore Horizontal Displacement (ARCore Yatay Yer Değiştirme)

After validated alignment, horizontal ARCore displacement will be expressed in ENU coordinates. *(Doğrulanmış hizalamadan sonra yatay ARCore yer değiştirmesi ENU koordinatlarında ifade edilecektir.)*

```
Δp_AR_ENU =
[ΔE_AR, ΔN_AR]ᵀ
```

Vertical ARCore motion may be retained separately as `ΔU_AR`. *(Dikey ARCore hareketi ayrı olarak `ΔU_AR` şeklinde korunabilir.)*

---

# 95. ARCore Geospatial API Policy (ARCore Geospatial API Politikası)

NAVGUARD does not require ARCore Geospatial API as part of the core local visual-inertial navigation architecture. *(NAVGUARD temel yerel görsel-ataletsel navigasyon mimarisinin bir parçası olarak ARCore Geospatial API’ye ihtiyaç duymaz.)*

The project already obtains its global anchor from Android GNSS. *(Proje global çapasını zaten Android GNSS’ten elde eder.)*

Standard local ARCore motion tracking will therefore remain separable from cloud or geospatial AR services. *(Bu nedenle standart yerel ARCore hareket takibi bulut veya coğrafi AR hizmetlerinden ayrı kalacaktır.)*

---

# 96. Android Sensor Pose From ARCore (ARCore’dan Android Sensör Pozu)

ARCore can expose the Android Sensor Coordinate System pose in its world coordinate space for the current frame. *(ARCore mevcut kare için Android Sensör Koordinat Sisteminin pozunu kendi dünya koordinat alanında sunabilir.)*

This pose follows Android’s native sensor axes and is not affected by display rotation. *(Bu poz Android’in doğal sensör eksenlerini izler ve ekran dönüşünden etkilenmez.)*

NAVGUARD may use this information during ARCore-to-IMU alignment experiments. *(NAVGUARD bu bilgiyi ARCore-IMU hizalama deneyleri sırasında kullanabilir.)*

---

# 97. Coordinate Transformation Chain (Koordinat Dönüşüm Zinciri)

The primary NAVGUARD transformation architecture can be summarized as follows. *(Temel NAVGUARD dönüşüm mimarisi aşağıdaki şekilde özetlenebilir.)*

```
Android Device Sensors
        D
        │
        ▼
Orientation Transformation
        │
        ▼
NAVGUARD ENU
        N
        │
        ├────────► PDR / EKF / Error Metrics
        │
        ▼
       ECEF
        │
        ▼
WGS84 Latitude / Longitude
```

ARCore enters the ENU frame through its own validated alignment transform. *(ARCore kendi doğrulanmış hizalama dönüşümü üzerinden ENU çerçevesine girer.)*

---

# 98. Full ARCore Transformation Chain (Tam ARCore Dönüşüm Zinciri)

```
ARCore Camera Pose
        │
        ▼
Relative Anchor Pose
        │
        ▼
ARCore Local Displacement
        │
        ▼
ARCore-to-ENU Alignment
        │
        ▼
[E, N, U]
        │
        ▼
Fusion Engine
```

ARCore world coordinates themselves will not bypass this transformation chain. *(ARCore dünya koordinatlarının kendisi bu dönüşüm zincirini atlamayacaktır.)*

---

# 99. Position Representation in the EKF (EKF’de Konum Temsili)

The initial EKF will represent horizontal position in local metric coordinates rather than latitude and longitude. *(İlk EKF yatay konumu enlem ve boylam yerine yerel metrik koordinatlarda temsil edecektir.)*

A candidate state may contain the following components. *(Aday durum aşağıdaki bileşenleri içerebilir.)*

```
x =
[E, N, v_E, v_N, ψ]ᵀ
```

This keeps state-transition mathematics numerically simple and physically meaningful. *(Bu durum geçiş matematiğini sayısal olarak basit ve fiziksel olarak anlamlı tutar.)*

---

# 100. Velocity Representation (Hız Temsili)

Horizontal velocity will use ENU components. *(Yatay hız ENU bileşenlerini kullanacaktır.)*

```
vᴺ =
[v_E, v_N, v_U]ᵀ
```

The initial pedestrian estimator may use only `v_E` and `v_N`. *(İlk yaya tahmin motoru yalnızca `v_E` ve `v_N` kullanabilir.)*

---

# 101. Velocity From Speed and Heading (Hız Büyüklüğü ve Yönden Hız Bileşenleri)

For horizontal speed `v` and heading `ψ`, the velocity components may be represented as follows. *(Yatay hız büyüklüğü `v` ve yön `ψ` için hız bileşenleri aşağıdaki şekilde temsil edilebilir.)*

```
v_E = v sinψ

v_N = v cosψ
```

This follows the same heading convention used by PDR step propagation. *(Bu PDR adım ilerletmesinde kullanılan aynı yön kuralını izler.)*

---

# 102. Heading Error (Yön Hatası)

Heading error must be computed using circular angular difference. *(Yön hatası dairesel açısal fark kullanılarak hesaplanmalıdır.)*

A direct subtraction may incorrectly report a large error near the 0°/360° boundary. *(Doğrudan çıkarma 0°/360° sınırı yakınında yanlış şekilde büyük hata raporlayabilir.)*

---

# 103. Circular Heading Difference (Dairesel Yön Farkı)

A signed angular difference may be calculated as follows. *(İşaretli açısal fark aşağıdaki şekilde hesaplanabilir.)*

```
Δψ =
atan2(
    sin(ψ_est - ψ_ref),
    cos(ψ_est - ψ_ref)
)
```

Absolute heading error will then be calculated as follows. *(Mutlak yön hatası daha sonra aşağıdaki şekilde hesaplanacaktır.)*

```
e_heading = |Δψ|
```

---

# 104. Heading MAE (Yön MAE)

For `n` valid heading-reference observations, heading mean absolute error may be calculated as follows. *(`n` geçerli yön referans gözlemi için yön ortalama mutlak hatası aşağıdaki şekilde hesaplanabilir.)*

```
Heading_MAE =
1/n · Σ |Δψ_i|
```

Only reference headings considered sufficiently reliable will enter this metric. *(Yalnızca yeterince güvenilir kabul edilen referans yönler bu metriğe girecektir.)*

---

# 105. Position RMSE (Konum RMSE)

For horizontal position errors `e_i`, position RMSE may be calculated as follows. *(Yatay konum hataları `e_i` için konum RMSE aşağıdaki şekilde hesaplanabilir.)*

```
RMSE =
√(
  1/n · Σ e_i²
)
```

The exact temporal alignment of estimates and ground truth will be defined in the evaluation documents. *(Tahminler ile gerçek referansın kesin zamansal hizalaması değerlendirme dokümanlarında tanımlanacaktır.)*

---

# 106. Mean Position Error (Ortalama Konum Hatası)

Mean horizontal position error may be calculated as follows. *(Ortalama yatay konum hatası aşağıdaki şekilde hesaplanabilir.)*

```
MeanPositionError =
1/n · Σ e_i
```

This value is different from RMSE because RMSE penalizes large errors more strongly. *(Bu değer RMSE’den farklıdır çünkü RMSE büyük hataları daha güçlü şekilde cezalandırır.)*

---

# 107. Final Position Error (Nihai Konum Hatası)

The final GNSS-denied position error will compare the final pre-correction NAVGUARD estimate with the aligned ground-truth position. *(Nihai GNSS kesintili konum hatası son düzeltme öncesi NAVGUARD tahminini hizalanmış gerçek referans konumuyla karşılaştıracaktır.)*

```
FinalError =
√(
(E_est_final - E_ref_final)² +
(N_est_final - N_ref_final)²
)
```

Relocalization must not occur before this value can be captured. *(Bu değer yakalanmadan yeniden konumlandırma gerçekleşmemelidir.)*

---

# 108. Drift Per Time (Zaman Başına Sürüklenme)

A simple drift-per-time metric may be calculated as follows. *(Basit bir zaman başına sürüklenme metriği aşağıdaki şekilde hesaplanabilir.)*

```
DriftRate =
FinalError / GNSSDeniedDuration
```

The preferred presentation unit may be metres per minute. *(Tercih edilen sunum birimi metre/dakika olabilir.)*

---

# 109. Drift Relative to Distance (Mesafeye Göre Sürüklenme)

Drift relative to travelled distance may be calculated as follows. *(Kat edilen mesafeye göre sürüklenme aşağıdaki şekilde hesaplanabilir.)*

```
DriftPercent =
FinalError
────────────── × 100
TravelledDistance
```

This metric must not be calculated when travelled distance is effectively zero. *(Kat edilen mesafe etkili olarak sıfır olduğunda bu metrik hesaplanmamalıdır.)*

---

# 110. Drift Reduction (Sürüklenme Azaltımı)

When comparing NAVGUARD with a baseline estimator, drift reduction may be calculated as follows. *(NAVGUARD temel bir tahmin motoruyla karşılaştırılırken sürüklenme azalması aşağıdaki şekilde hesaplanabilir.)*

```
DriftReduction =
Error_baseline - Error_NAVGUARD
─────────────────────────────── × 100
        Error_baseline
```

This value will be reported only from measured experimental results. *(Bu değer yalnızca ölçülmüş deneysel sonuçlardan raporlanacaktır.)*

---

# 111. Coordinate Covariance Representation (Koordinat Kovaryans Temsili)

The fusion system may maintain uncertainty in the ENU coordinate frame. *(Füzyon sistemi belirsizliği ENU koordinat çerçevesinde tutabilir.)*

For horizontal position, covariance may contain East and North uncertainty and their correlation. *(Yatay konum için kovaryans Doğu ve Kuzey belirsizliğini ve aralarındaki korelasyonu içerebilir.)*

```
P_pos =
┌ σ_E²    cov_EN ┐
│ cov_EN   σ_N²  │
└                ┘
```

This structure may later support an uncertainty ellipse. *(Bu yapı daha sonra belirsizlik elipsini destekleyebilir.)*

---

# 112. Uncertainty Ellipse Concept (Belirsizlik Elipsi Kavramı)

The eigenvalues and eigenvectors of horizontal covariance can describe the principal directions of estimated uncertainty. *(Yatay kovaryansın özdeğerleri ve özvektörleri tahmini belirsizliğin temel yönlerini açıklayabilir.)*

NAVGUARD may use this information for research visualization if the EKF covariance proves sufficiently calibrated. *(EKF kovaryansı yeterince kalibre edilmiş olduğu kanıtlanırsa NAVGUARD bu bilgiyi araştırma görselleştirmesi için kullanabilir.)*

A visually displayed ellipse must not imply validated statistical confidence unless calibration supports that interpretation. *(Görsel olarak gösterilen bir elips kalibrasyon bu yorumu desteklemediği sürece doğrulanmış istatistiksel güven anlamına gelmemelidir.)*

---

# 113. Coordinate Numerical Precision (Koordinat Sayısal Hassasiyeti)

Dart `double` and Python double-precision floating-point values will be sufficient for NAVGUARD’s planned local-navigation distances. *(Dart `double` ve Python çift hassasiyetli floating-point değerleri NAVGUARD’ın planlanan yerel navigasyon mesafeleri için yeterli olacaktır.)*

Geographic transformation calculations will use double precision. *(Coğrafi dönüşüm hesaplamaları çift hassasiyet kullanacaktır.)*

ARCore native pose values may originate as single-precision floats and will be converted without implying additional physical accuracy. *(ARCore native poz değerleri tek hassasiyetli float olarak gelebilir ve ek fiziksel doğruluk ima edilmeden dönüştürülecektir.)*

---

# 114. Latitude and Longitude Storage Precision (Enlem ve Boylam Depolama Hassasiyeti)

Latitude and longitude will be stored using double-precision numerical values. *(Enlem ve boylam çift hassasiyetli sayısal değerler kullanılarak saklanacaktır.)*

The number of displayed decimal places in the user interface will be a presentation decision rather than an estimator-accuracy statement. *(Kullanıcı arayüzünde gösterilen ondalık basamak sayısı tahmin motoru doğruluk bildirimi yerine bir sunum kararı olacaktır.)*

---

# 115. No Direct Degree Arithmetic for PDR (PDR İçin Doğrudan Derece Aritmetiği Olmaması)

PDR will not directly add metre-scale step displacement to latitude or longitude degree values. *(PDR metre ölçeğindeki adım yer değiştirmesini doğrudan enlem veya boylam derece değerlerine eklemeyecektir.)*

PDR will operate in local metres. *(PDR yerel metre cinsinden çalışacaktır.)*

Geographic conversion will occur only through a dedicated coordinate-transformation boundary. *(Coğrafi dönüşüm yalnızca özel bir koordinat dönüşüm sınırı üzerinden gerçekleşecektir.)*

---

# 116. No Direct ARCore-to-Latitude Mapping (Doğrudan ARCore-Enlem Eşleme Olmaması)

ARCore X, Y, or Z coordinates will never be interpreted directly as longitude, altitude, or latitude increments. *(ARCore X, Y veya Z koordinatları hiçbir zaman doğrudan boylam, yükseklik veya enlem artışı olarak yorumlanmayacaktır.)*

ARCore translation must first be converted into the NAVGUARD local ENU frame. *(ARCore ötelemesi önce NAVGUARD yerel ENU çerçevesine dönüştürülmelidir.)*

Only then may it contribute to geographic position through the shared ENU-to-WGS84 conversion. *(Ancak bundan sonra ortak ENU-WGS84 dönüşümü üzerinden coğrafi konuma katkıda bulunabilir.)*

---

# 117. No Direct Raw Gyroscope Heading (Ham Jiroskoptan Doğrudan Yön Olmaması)

Raw gyroscope angular velocity is not itself a compass heading. *(Ham jiroskop açısal hızı kendi başına pusula yönü değildir.)*

It must be integrated through time and interpreted within the correct device attitude and reference frame. *(Zaman boyunca integre edilmeli ve doğru cihaz attitude ve referans çerçevesi içerisinde yorumlanmalıdır.)*

Gyroscope drift must also be corrected or constrained by other information sources. *(Jiroskop sürüklenmesi ayrıca diğer bilgi kaynakları tarafından düzeltilmeli veya sınırlandırılmalıdır.)*

---

# 118. No Direct Raw Magnetometer Heading (Ham Manyetometreden Doğrudan Yön Olmaması)

A raw three-axis magnetic vector is not directly equivalent to a tilt-compensated pedestrian heading. *(Ham üç eksenli manyetik vektör doğrudan tilt telafili yaya yönüne eşdeğer değildir.)*

Device orientation and magnetic declination must be considered. *(Cihaz yönelimi ve manyetik sapma dikkate alınmalıdır.)*

The complete heading algorithm will be defined in **18 — Heading Estimation System**. *(Tam yön algoritması **18 — Heading Estimation System** bölümünde tanımlanacaktır.)*

---

# 119. Local Frame Re-Anchoring (Yerel Çerçeveyi Yeniden Çapalama)

During GNSS recovery, NAVGUARD may establish a new local reference for future navigation. *(GNSS geri kazanımı sırasında NAVGUARD gelecekteki navigasyon için yeni bir yerel referans oluşturabilir.)*

Historical ENU estimates from the original denied interval must remain associated with their original anchor. *(Orijinal kesintili aralıktan gelen geçmiş ENU tahminleri orijinal çapalarıyla ilişkili kalmalıdır.)*

Historical coordinates must not be retrospectively moved merely to make the recovered trajectory look more accurate. *(Geçmiş koordinatlar geri kazanılan rotayı daha doğru göstermek amacıyla geriye dönük olarak hareket ettirilmemelidir.)*

---

# 120. Multiple Anchor Representation (Birden Fazla Çapa Temsili)

If relocalization creates a new local frame, the session must retain the identity and geographic coordinates of each anchor. *(Yeniden konumlandırma yeni bir yerel çerçeve oluşturursa oturum her çapanın kimliğini ve coğrafi koordinatlarını korumalıdır.)*

A trajectory segment must be traceable to the anchor frame in which it was estimated. *(Bir rota parçası tahmin edildiği çapa çerçevesine kadar izlenebilir olmalıdır.)*

---

# 121. Route Rendering Across Anchors (Çapalar Arasında Rota Render Etme)

For map visualization, each local position will be converted through its corresponding anchor into global geographic coordinates. *(Harita görselleştirmesi için her yerel konum ilgili çapası üzerinden global coğrafi koordinatlara dönüştürülecektir.)*

This allows trajectories from different local anchor intervals to be drawn consistently on the same map. *(Bu farklı yerel çapa aralıklarından gelen rotaların aynı harita üzerinde tutarlı şekilde çizilmesini sağlar.)*

---

# 122. Geographic Ground Truth Conversion (Coğrafi Gerçek Referans Dönüşümü)

GNSS ground-truth coordinates will be transformed into the same ENU frame used by the estimator before primary local error calculation. *(GNSS gerçek referans koordinatları temel yerel hata hesabından önce tahmin motorunun kullandığı aynı ENU çerçevesine dönüştürülecektir.)*

```
GNSS Lat/Lon
     ↓
   ECEF
     ↓
Anchor ENU
     ↓
[E_ref, N_ref]
```

This produces directly comparable metric coordinates. *(Bu doğrudan karşılaştırılabilir metrik koordinatlar üretir.)*

---

# 123. Ground Truth Altitude Policy (Gerçek Referans Yükseklik Politikası)

Primary position-error evaluation will focus on horizontal error. *(Temel konum hata değerlendirmesi yatay hataya odaklanacaktır.)*

GNSS vertical error will not be allowed to distort the primary two-dimensional pedestrian-navigation metric. *(GNSS dikey hatasının temel iki boyutlu yaya navigasyonu metriğini bozmasına izin verilmeyecektir.)*

Three-dimensional error may be reported separately if the vertical subsystem is validated. *(Dikey alt sistem doğrulanırsa üç boyutlu hata ayrı olarak raporlanabilir.)*

---

# 124. Three-Dimensional Error Candidate (Üç Boyutlu Hata Adayı)

If validated three-dimensional positions are available, 3D error may be calculated as follows. *(Doğrulanmış üç boyutlu konumlar mevcutsa 3D hata aşağıdaki şekilde hesaplanabilir.)*

```
e_3D =
√(
  e_E² +
  e_N² +
  e_U²
)
```

This metric is optional and will not replace primary horizontal error. *(Bu metrik isteğe bağlıdır ve temel yatay hatanın yerini almayacaktır.)*

---

# 125. Coordinate Frame Metadata (Koordinat Çerçevesi Metadata Bilgisi)

Processed vectors should identify their coordinate frame in schema or type information. *(İşlenmiş vektörler koordinat çerçevelerini şema veya tür bilgisinde tanımlamalıdır.)*

A variable called simply `x` or `position` without a frame definition should be avoided in core navigation code. *(Temel navigasyon kodunda çerçeve tanımı olmayan yalnızca `x` veya `position` adlı değişkenlerden kaçınılmalıdır.)*

Examples of preferred names include `positionEnu`, `accelerationDevice`, and `arcoreTranslationAnchor`. *(Tercih edilen ad örnekleri `positionEnu`, `accelerationDevice` ve `arcoreTranslationAnchor` değerlerini içerir.)*

---

# 126. Typed Coordinate Models (Türlendirilmiş Koordinat Modelleri)

The implementation should use separate data models for semantically different coordinate representations. *(Uygulama anlamsal olarak farklı koordinat temsilleri için ayrı veri modelleri kullanmalıdır.)*

Possible examples include the following. *(Olası örnekler aşağıdakileri içerir.)*

```
DeviceVector3
EnuVector3
EcefPoint
GeodeticPosition
ArcorePose
Heading
```

This reduces accidental mixing of mathematically incompatible values. *(Bu matematiksel olarak uyumsuz değerlerin yanlışlıkla karıştırılmasını azaltır.)*

---

# 127. Geographic Model Candidate (Coğrafi Model Adayı)

A logical geographic model may use the following fields. *(Mantıksal bir coğrafi model aşağıdaki alanları kullanabilir.)*

```
GeodeticPosition
- latitudeDeg
- longitudeDeg
- ellipsoidalHeightM
```

Height must be nullable or explicitly unavailable when no valid altitude exists. *(Geçerli yükseklik mevcut olmadığında yükseklik nullable veya açıkça kullanılamaz olmalıdır.)*

---

# 128. ENU Model Candidate (ENU Model Adayı)

A logical local-position model may use the following fields. *(Mantıksal bir yerel konum modeli aşağıdaki alanları kullanabilir.)*

```
EnuPosition
- eastM
- northM
- upM
- anchorId
```

Including the anchor identity prevents local coordinates from being interpreted without their geographic reference. *(Çapa kimliğini dahil etmek yerel koordinatların coğrafi referansları olmadan yorumlanmasını önler.)*

---

# 129. Heading Model Candidate (Yön Model Adayı)

A logical heading model may include the following information. *(Mantıksal bir yön modeli aşağıdaki bilgileri içerebilir.)*

```
HeadingEstimate
- headingRad
- reference
- source
- confidence
- timestamp
```

The `reference` field may distinguish true north from magnetic north where necessary. *(`reference` alanı gerektiğinde gerçek kuzey ile manyetik kuzeyi ayırt edebilir.)*

---

# 130. Numerical Boundary Checks (Sayısal Sınır Kontrolleri)

Latitude must remain within valid geographic limits. *(Enlem geçerli coğrafi sınırlar içerisinde kalmalıdır.)*

Longitude must be normalized into the selected canonical range. *(Boylam seçilen kanonik aralığa normalize edilmelidir.)*

Heading must remain within the selected circular range. *(Yön seçilen dairesel aralık içerisinde kalmalıdır.)*

Quaternion norm and matrix determinant must be checked when suspicious numerical input is detected. *(Şüpheli sayısal girdi tespit edildiğinde quaternion normu ve matris determinantı kontrol edilmelidir.)*

---

# 131. Longitude Normalization (Boylam Normalizasyonu)

The canonical longitude range will be `[-180°, 180°)`. *(Kanonik boylam aralığı `[-180°, 180°)` olacaktır.)*

A normalization utility will be used whenever a calculation may cross the antimeridian. *(Bir hesaplama tarih değiştirme çizgisini geçebileceğinde normalizasyon yardımcı fonksiyonu kullanılacaktır.)*

Antimeridian behavior is not expected to affect the planned local field experiments but will remain mathematically correct. *(Tarih değiştirme çizgisi davranışının planlanan yerel saha deneylerini etkilemesi beklenmemektedir ancak matematiksel olarak doğru kalacaktır.)*

---

# 132. Polar Limitation (Kutup Sınırlaması)

The NAVGUARD local pedestrian prototype is not designed for navigation immediately adjacent to the geographic poles. *(NAVGUARD yerel yaya prototipi coğrafi kutupların hemen yakınında navigasyon için tasarlanmamıştır.)*

The planned Türkiye-based experiments are far from coordinate singularities associated with polar longitude behavior. *(Planlanan Türkiye tabanlı deneyler kutup boylamı davranışıyla ilişkili koordinat tekilliklerinden uzaktadır.)*

No special polar-navigation architecture is required for this project. *(Bu proje için özel kutup navigasyonu mimarisi gerekli değildir.)*

---

# 133. Frame Transformation Validation (Çerçeve Dönüşüm Doğrulaması)

Coordinate transformations will be tested using known cardinal directions. *(Koordinat dönüşümleri bilinen ana yönler kullanılarak test edilecektir.)*

A device displacement aligned with true north should create positive North displacement after transformation. *(Gerçek kuzeyle hizalanmış bir cihaz yer değiştirmesi dönüşümden sonra pozitif Kuzey yer değiştirmesi üretmelidir.)*

An eastward displacement should create positive East displacement. *(Doğuya yer değiştirme pozitif Doğu yer değiştirmesi üretmelidir.)*

No horizontal movement should generate a large vertical displacement solely because of an axis-order error. *(Hiçbir yatay hareket yalnızca eksen sırası hatası nedeniyle büyük dikey yer değiştirme üretmemelidir.)*

---

# 134. Cardinal Heading Tests (Ana Yön Testleri)

Controlled heading tests will include approximately North, East, South, and West orientations. *(Kontrollü yön testleri yaklaşık Kuzey, Doğu, Güney ve Batı yönelimlerini içerecektir.)*

The expected heading outputs will be approximately `0°`, `90°`, `180°`, and `270°`. *(Beklenen yön çıktıları yaklaşık `0°`, `90°`, `180°` ve `270°` olacaktır.)*

These tests will detect reversed axes, wrong declination signs, and clockwise-versus-counterclockwise errors. *(Bu testler ters çevrilmiş eksenleri, yanlış sapma işaretlerini ve saat yönü-saat yönünün tersi hatalarını tespit edecektir.)*

---

# 135. ENU Round-Trip Test (ENU Gidiş-Dönüş Testi)

A geographic point will be transformed from WGS84 into ENU and then back into WGS84. *(Bir coğrafi nokta WGS84’ten ENU’ya ve daha sonra tekrar WGS84’e dönüştürülecektir.)*

```
Geodetic
   ↓
 ECEF
   ↓
  ENU
   ↓
 ECEF
   ↓
Geodetic
```

The recovered coordinate must match the original coordinate within a defined numerical tolerance. *(Geri elde edilen koordinat tanımlanmış bir sayısal tolerans içerisinde orijinal koordinatla eşleşmelidir.)*

---

# 136. ECEF Reference Tests (ECEF Referans Testleri)

Known WGS84 coordinates will be used to verify the geodetic-to-ECEF implementation. *(Bilinen WGS84 koordinatları jeodezik-ECEF uygulamasını doğrulamak için kullanılacaktır.)*

Python and Dart implementations should produce equivalent results within a defined floating-point tolerance. *(Python ve Dart uygulamaları tanımlanmış floating-point toleransı içerisinde eşdeğer sonuçlar üretmelidir.)*

---

# 137. Quaternion Reference Tests (Quaternion Referans Testleri)

Identity quaternion behavior will be tested. *(Identity quaternion davranışı test edilecektir.)*

Known 90-degree rotations about each axis will be tested. *(Her eksen çevresindeki bilinen 90 derecelik dönüşler test edilecektir.)*

Quaternion-to-matrix and matrix-to-vector operations will be compared against known expected vectors. *(Quaternion-matris ve matris-vektör işlemleri bilinen beklenen vektörlere karşı karşılaştırılacaktır.)*

---

# 138. Identity Rotation (Identity Dönüşü)

The identity quaternion will be represented as follows. *(Identity quaternion aşağıdaki şekilde temsil edilecektir.)*

```
q_identity =
[1, 0, 0, 0]
```

Applying the identity rotation must leave a vector unchanged. *(Identity dönüşünü uygulamak bir vektörü değiştirmeden bırakmalıdır.)*

---

# 139. Identity Matrix (Identity Matris)

The identity rotation matrix will be represented as follows. *(Identity dönüş matrisi aşağıdaki şekilde temsil edilecektir.)*

```
I =
┌ 1 0 0 ┐
│ 0 1 0 │
│ 0 0 1 │
└       ┘
```

A frame transform that should represent no rotation must produce this matrix within numerical tolerance. *(Dönüş olmamasını temsil etmesi gereken bir çerçeve dönüşümü sayısal tolerans içerisinde bu matrisi üretmelidir.)*

---

# 140. Cross-Language Mathematical Verification (Diller Arası Matematiksel Doğrulama)

Python will be used as a reference environment for selected coordinate and orientation tests. *(Python seçilen koordinat ve yönelim testleri için referans ortam olarak kullanılacaktır.)*

Dart implementations will be tested against identical input vectors and geographic coordinates. *(Dart uygulamaları aynı girdi vektörleri ve coğrafi koordinatlara karşı test edilecektir.)*

Native Kotlin transformations, if introduced, must pass the same reference tests. *(Native Kotlin dönüşümleri dahil edilirse aynı referans testlerini geçmelidir.)*

---

# 141. No Unverified Library Assumptions (Doğrulanmamış Kütüphane Varsayımı Olmaması)

A third-party library’s quaternion order, matrix storage order, handedness, or geographic convention must not be assumed. *(Bir üçüncü taraf kütüphanenin quaternion sırası, matris depolama sırası, el yönlülüğü veya coğrafi kuralı varsayılmamalıdır.)*

Adapters must explicitly convert external conventions into NAVGUARD conventions. *(Adapter’lar harici kuralları açıkça NAVGUARD kurallarına dönüştürmelidir.)*

Reference tests will verify each adapter. *(Referans testleri her adapter’ı doğrulayacaktır.)*

---

# 142. Matrix Storage Versus Mathematical Matrix (Matris Depolama ile Matematiksel Matris Ayrımı)

Row-major or column-major memory layout is an implementation detail that must not alter the mathematical transformation definition. *(Row-major veya column-major bellek düzeni matematiksel dönüşüm tanımını değiştirmemesi gereken bir uygulama ayrıntısıdır.)*

Every external matrix API must be inspected before converting values into NAVGUARD matrices. *(Her harici matris API’si değerler NAVGUARD matrislerine dönüştürülmeden önce incelenmelidir.)*

---

# 143. ARCore Pose Persistence Rule (ARCore Poz Kalıcılığı Kuralı)

NAVGUARD will use relative anchor-based ARCore transformations when persistent local displacement is required. *(NAVGUARD kalıcı yerel yer değiştirme gerektiğinde anchor tabanlı göreli ARCore dönüşümlerini kullanacaktır.)*

Raw ARCore camera world positions will remain useful diagnostic evidence but will not automatically become the authoritative trajectory representation. *(Ham ARCore kamera dünya konumları kullanışlı tanısal kanıt olarak kalacak ancak otomatik olarak ana rota temsili haline gelmeyecektir.)*

---

# 144. ARCore Coordinate Reset Handling (ARCore Koordinat Sıfırlama Yönetimi)

A tracking interruption or anchor invalidation may require ARCore local-frame reinitialization. *(Takip kesintisi veya anchor geçersizliği ARCore yerel çerçevesinin yeniden başlatılmasını gerektirebilir.)*

The event must be explicitly recorded. *(Olay açıkça kaydedilmelidir.)*

The fusion system must not interpret a frame reset as physical pedestrian displacement. *(Füzyon sistemi bir çerçeve sıfırlamasını fiziksel yaya yer değiştirmesi olarak yorumlamamalıdır.)*

---

# 145. Relative Pose Jump Detection (Göreli Poz Sıçraması Tespiti)

NAVGUARD may monitor successive aligned ARCore displacements for implausibly large jumps. *(NAVGUARD art arda gelen hizalanmış ARCore yer değiştirmelerini fiziksel olarak mantıksız büyük sıçramalar açısından izleyebilir.)*

A detected jump will initially reduce ARCore confidence or reject the corresponding measurement rather than force the full fused position to jump. *(Tespit edilen bir sıçrama başlangıçta tam füzyon konumunu sıçramaya zorlamak yerine ARCore güvenini azaltacak veya ilgili ölçümü reddedecektir.)*

Thresholds will be based on measured pedestrian motion and ARCore behavior. *(Eşikler ölçülen yaya hareketi ve ARCore davranışına dayanacaktır.)*

---

# 146. Coordinate Conversion Performance (Koordinat Dönüşüm Performansı)

PDR and EKF will remain in local ENU coordinates during active navigation. *(PDR ve EKF aktif navigasyon sırasında yerel ENU koordinatlarında kalacaktır.)*

Repeated WGS84 conversion is therefore not required for every internal mathematical operation. *(Bu nedenle her dahili matematiksel işlem için tekrarlanan WGS84 dönüşümü gerekli değildir.)*

Geographic conversion may occur at the visualization or logging rate required by the application. *(Coğrafi dönüşüm uygulamanın gerektirdiği görselleştirme veya kayıt hızında gerçekleşebilir.)*

---

# 147. Map Conversion Rate (Harita Dönüşüm Hızı)

The Flutter map may receive geographic points at a lower frequency than the internal navigation estimator updates. *(Flutter haritası dahili navigasyon tahmin motoru güncellemelerinden daha düşük frekansta coğrafi noktalar alabilir.)*

This reduction must not alter the stored full-resolution ENU trajectory. *(Bu azaltma saklanan tam çözünürlüklü ENU rotasını değiştirmemelidir.)*

---

# 148. Mathematical Error Handling (Matematiksel Hata Yönetimi)

Invalid trigonometric input, NaN values, infinite values, singular transformations, or failed normalization must not propagate silently through the navigation system. *(Geçersiz trigonometrik girdi, NaN değerleri, sonsuz değerler, tekil dönüşümler veya başarısız normalizasyon navigasyon sistemi boyunca sessizce yayılmamalıdır.)*

The affected measurement or transformation must be rejected and a diagnostic event generated. *(Etkilenen ölçüm veya dönüşüm reddedilmeli ve tanısal olay oluşturulmalıdır.)*

---

# 149. Numerical Tolerance Policy (Sayısal Tolerans Politikası)

Floating-point comparisons will use documented numerical tolerances rather than direct equality when appropriate. *(Floating-point karşılaştırmaları uygun olduğunda doğrudan eşitlik yerine dokümante edilmiş sayısal toleranslar kullanacaktır.)*

Different mathematical domains may require different tolerances. *(Farklı matematiksel alanlar farklı toleranslar gerektirebilir.)*

The final tolerances will be frozen with the automated mathematics test suite. *(Nihai toleranslar otomatik matematik test paketiyle birlikte sabitlenecektir.)*

---

# 150. Mathematical Module Boundaries (Matematiksel Modül Sınırları)

NAVGUARD should separate general mathematical utilities from navigation-specific algorithms. *(NAVGUARD genel matematik yardımcılarını navigasyona özgü algoritmalardan ayırmalıdır.)*

Possible modules may include the following. *(Olası modüller aşağıdakileri içerebilir.)*

```
math/
├── angles
├── vectors
├── matrices
├── quaternions
└── statistics

coordinates/
├── geodetic
├── ecef
├── enu
├── device_frame
└── arcore_alignment
```

The exact source directory structure may change while preserving these logical boundaries. *(Kesin kaynak klasör yapısı bu mantıksal sınırları koruyarak değişebilir.)*

---

# 151. Minimum Mathematical Foundation (Minimum Matematiksel Temel)

The minimum NAVGUARD mathematical implementation must support true-north heading normalization. *(Minimum NAVGUARD matematiksel uygulaması gerçek kuzey yön normalizasyonunu desteklemelidir.)*

It must support PDR East-North displacement. *(PDR Doğu-Kuzey yer değiştirmesini desteklemelidir.)*

It must support WGS84-to-ENU conversion. *(WGS84-ENU dönüşümünü desteklemelidir.)*

It must support ENU-to-WGS84 conversion. *(ENU-WGS84 dönüşümünü desteklemelidir.)*

It must support horizontal position-error calculation. *(Yatay konum hata hesabını desteklemelidir.)*

It must support basic orientation transformations. *(Temel yönelim dönüşümlerini desteklemelidir.)*

---

# 152. Target Mathematical Foundation (Hedef Matematiksel Temel)

The target NAVGUARD mathematical implementation will additionally support quaternion-based full device attitude. *(Hedef NAVGUARD matematiksel uygulaması ayrıca quaternion tabanlı tam cihaz attitude bilgisini destekleyecektir.)*

It will support ARCore local-anchor transforms. *(ARCore yerel anchor dönüşümlerini destekleyecektir.)*

It will support ARCore-to-ENU alignment. *(ARCore-ENU hizalamasını destekleyecektir.)*

It will support EKF state and covariance mathematics. *(EKF durum ve kovaryans matematiğini destekleyecektir.)*

It will support uncertainty representation and circular heading statistics. *(Belirsizlik temsilini ve dairesel yön istatistiklerini destekleyecektir.)*

---

# 153. Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kararlar)

NAVGUARD local navigation will use ENU coordinates. *(NAVGUARD yerel navigasyonu ENU koordinatlarını kullanacaktır.)*

Positive local X will represent East. *(Pozitif yerel X Doğu’yu temsil edecektir.)*

Positive local Y will represent true North. *(Pozitif yerel Y gerçek Kuzey’i temsil edecektir.)*

Positive local Z will represent Up. *(Pozitif yerel Z Yukarı’yı temsil edecektir.)*

Heading will increase clockwise from true North. *(Yön gerçek Kuzeyden saat yönünde artacaktır.)*

The global geographic representation will use WGS84. *(Global coğrafi temsil WGS84 kullanacaktır.)*

PDR will operate in metres rather than latitude and longitude degrees. *(PDR enlem ve boylam dereceleri yerine metre cinsinden çalışacaktır.)*

The canonical NAVGUARD quaternion representation will use `[w, x, y, z]`. *(Kanonik NAVGUARD quaternion temsili `[w, x, y, z]` kullanacaktır.)*

ARCore translations will require explicit alignment before being interpreted as ENU displacement. *(ARCore ötelemeleri ENU yer değiştirme olarak yorumlanmadan önce açık hizalama gerektirecektir.)*

---

# 154. Decisions Pending Experimental Validation (Deneysel Doğrulama Bekleyen Kararlar)

The exact ARCore-to-ENU alignment procedure remains pending physical-device experiments. *(Kesin ARCore-ENU hizalama prosedürü fiziksel cihaz deneylerini beklemektedir.)*

The final magnetic-declination update policy remains pending heading experiments. *(Nihai manyetik sapma güncelleme politikası yön deneylerini beklemektedir.)*

The exact phone-placement-to-user-heading relationship remains pending pilot tests. *(Kesin telefon yerleşimi-kullanıcı hareket yönü ilişkisi pilot testleri beklemektedir.)*

The final use of vertical displacement remains pending device and field measurements. *(Dikey yer değiştirmenin nihai kullanımı cihaz ve saha ölçümlerini beklemektedir.)*

---

# 155. Coordinate Acceptance Criteria (Koordinat Kabul Kriterleri)

A known eastward displacement must produce positive East. *(Bilinen doğuya yer değiştirme pozitif Doğu üretmelidir.)*

A known northward displacement must produce positive North. *(Bilinen kuzeye yer değiştirme pozitif Kuzey üretmelidir.)*

A heading of `0°` must produce no East component for ideal straight-line PDR. *(`0°` yön ideal doğrusal PDR için Doğu bileşeni üretmemelidir.)*

A heading of `90°` must produce positive East displacement. *(`90°` yön pozitif Doğu yer değiştirmesi üretmelidir.)*

Geodetic-to-ENU-to-geodetic round trips must remain within the selected numerical tolerance. *(Jeodezik-ENU-jeodezik gidiş-dönüşleri seçilen sayısal tolerans içerisinde kalmalıdır.)*

---

# 156. Orientation Acceptance Criteria (Yönelim Kabul Kriterleri)

Identity quaternion must leave vectors unchanged. *(Identity quaternion vektörleri değiştirmeden bırakmalıdır.)*

Known quaternion rotations must produce expected axis transformations. *(Bilinen quaternion dönüşleri beklenen eksen dönüşümlerini üretmelidir.)*

Android and ARCore quaternion adapters must produce consistent NAVGUARD internal ordering. *(Android ve ARCore quaternion adapter’ları tutarlı NAVGUARD dahili sıralaması üretmelidir.)*

Magnetic and true-north headings must remain explicitly distinguishable. *(Manyetik ve gerçek kuzey yönleri açıkça ayırt edilebilir kalmalıdır.)*

---

# 157. ARCore Acceptance Criteria (ARCore Kabul Kriterleri)

ARCore pose translation must remain expressed in metres. *(ARCore poz ötelemesi metre cinsinden ifade edilmiş kalmalıdır.)*

Raw ARCore coordinates must not be interpreted directly as ENU coordinates. *(Ham ARCore koordinatları doğrudan ENU koordinatları olarak yorumlanmamalıdır.)*

Relative anchor-based movement must remain stable enough for experimental use before entering final fusion. *(Anchor tabanlı göreli hareket nihai füzyona girmeden önce deneysel kullanım için yeterince kararlı kalmalıdır.)*

ARCore frame resets must not create artificial physical displacement. *(ARCore çerçeve sıfırlamaları yapay fiziksel yer değiştirme oluşturmamalıdır.)*

---

# 158. Mathematical Non-Goals (Matematiksel Olmayan Hedefler)

NAVGUARD will not develop a complete global geodesy library from scratch. *(NAVGUARD sıfırdan tam bir global jeodezi kütüphanesi geliştirmeyecektir.)*

NAVGUARD will not implement high-precision surveying or military-grade inertial navigation mathematics. *(NAVGUARD yüksek hassasiyetli ölçme veya askerî seviye ataletsel navigasyon matematiği geliştirmeyecektir.)*

NAVGUARD will not require Earth-rotation or relativistic corrections for its short pedestrian experiments. *(NAVGUARD kısa yaya deneyleri için Dünya dönüşü veya relativistik düzeltmeler gerektirmeyecektir.)*

The mathematical scope will remain proportional to a smartphone pedestrian-navigation research prototype. *(Matematiksel kapsam akıllı telefon yaya navigasyonu araştırma prototipiyle orantılı kalacaktır.)*

---

# 159. Source Basis (Kaynak Temeli)

The Android device-axis convention used in this document is based on the official Android sensor-coordinate documentation. *(Bu dokümanda kullanılan Android cihaz ekseni kuralı resmî Android sensör koordinat dokümantasyonuna dayanmaktadır.)*

The Android magnetic world-frame and quaternion conventions are based on the official `SensorManager` documentation. *(Android manyetik dünya çerçevesi ve quaternion kuralları resmî `SensorManager` dokümantasyonuna dayanmaktadır.)*

The WGS84 ellipsoid constants are based on the National Geospatial-Intelligence Agency WGS84 reference information. *(WGS84 elipsoid sabitleri National Geospatial-Intelligence Agency WGS84 referans bilgisine dayanmaktadır.)*

The Android ellipsoidal-altitude convention is based on the official Android `Location` documentation. *(Android elipsoidal yükseklik kuralı resmî Android `Location` dokümantasyonuna dayanmaktadır.)*

The ARCore pose, coordinate-system, and world-adjustment rules are based on the official ARCore Pose and Camera documentation. *(ARCore poz, koordinat sistemi ve dünya ayarlama kuralları resmî ARCore Pose ve Camera dokümantasyonuna dayanmaktadır.)*

The magnetic-declination definition is based on the official Android `GeomagneticField` documentation. *(Manyetik sapma tanımı resmî Android `GeomagneticField` dokümantasyonuna dayanmaktadır.)*

---

# 160. Final Mathematical Foundation Statement (Nihai Matematiksel Temel Bildirimi)

**NAVGUARD will perform pedestrian position estimation in a local right-handed East-North-Up coordinate frame anchored to an accepted WGS84 GNSS position.** *(NAVGUARD yaya konum tahminini kabul edilen bir WGS84 GNSS konumuna çapalanmış sağ elli yerel Doğu-Kuzey-Yukarı koordinat çerçevesinde gerçekleştirecektir.)*

**Global latitude and longitude will be converted through WGS84 ECEF mathematics into local metric ENU coordinates so that PDR, ARCore fusion, EKF estimation, and error calculation operate primarily in metres rather than geographic degrees.** *(Global enlem ve boylam WGS84 ECEF matematiği üzerinden yerel metrik ENU koordinatlarına dönüştürülecek; böylece PDR, ARCore füzyonu, EKF tahmini ve hata hesabı temel olarak coğrafi dereceler yerine metre cinsinden çalışacaktır.)*

**NAVGUARD heading will be measured clockwise from true north, with `0° = North`, `90° = East`, `180° = South`, and `270° = West`.** *(NAVGUARD yönü gerçek kuzeyden saat yönünde ölçülecek ve `0° = Kuzey`, `90° = Doğu`, `180° = Güney` ve `270° = Batı` olacaktır.)*

**Android device vectors, magnetic-world vectors, NAVGUARD ENU vectors, and ARCore local vectors will remain explicitly separated and will be connected only through validated transformations.** *(Android cihaz vektörleri, manyetik dünya vektörleri, NAVGUARD ENU vektörleri ve ARCore yerel vektörleri açıkça ayrı kalacak ve yalnızca doğrulanmış dönüşümler üzerinden birbirine bağlanacaktır.)*

**Quaternions will use the canonical NAVGUARD internal order `[w, x, y, z]`, while platform-specific representations such as ARCore `{x, y, z, w}` will be converted at controlled adapter boundaries.** *(Quaternion’lar kanonik NAVGUARD dahili sırası `[w, x, y, z]` kullanırken ARCore `{x, y, z, w}` gibi platforma özgü temsiller kontrollü adapter sınırlarında dönüştürülecektir.)*

**ARCore will contribute relative local movement only after validated anchor-based coordinate alignment and will never be treated as a direct latitude-longitude source in the core estimator.** *(ARCore yalnızca doğrulanmış anchor tabanlı koordinat hizalamasından sonra göreli yerel harekete katkı sağlayacak ve temel tahmin motorunda hiçbir zaman doğrudan enlem-boylam kaynağı olarak ele alınmayacaktır.)*

---

# 161. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development Coordinate and Mathematical Foundation Completed *(Doküman Durumu: Geliştirme Öncesi Koordinat ve Matematiksel Temel Tamamlandı)*

**Primary Local Navigation Frame:** ENU — East, North, Up *(Temel Yerel Navigasyon Çerçevesi: ENU — Doğu, Kuzey, Yukarı)*

**Horizontal Coordinate Convention:** X = East, Y = True North *(Yatay Koordinat Kuralı: X = Doğu, Y = Gerçek Kuzey)*

**Vertical Coordinate Convention:** Z = Up *(Dikey Koordinat Kuralı: Z = Yukarı)*

**Heading Convention:** Clockwise from True North *(Yön Kuralı: Gerçek Kuzeyden Saat Yönünde)*

**Global Geographic Reference:** WGS84 *(Global Coğrafi Referans: WGS84)*

**Global-to-Local Transformation:** WGS84 → ECEF → ENU *(Globalden Yerele Dönüşüm: WGS84 → ECEF → ENU)*

**Local-to-Global Transformation:** ENU → ECEF → WGS84 *(Yerelden Globale Dönüşüm: ENU → ECEF → WGS84)*

**Primary PDR Coordinates:** East / North in Metres *(Temel PDR Koordinatları: Metre Cinsinden Doğu / Kuzey)*

**Canonical Quaternion Order:** `[w, x, y, z]` *(Kanonik Quaternion Sırası: `[w, x, y, z]`)*

**ARCore Quaternion Adapter:** `{x, y, z, w} → [w, x, y, z]` *(ARCore Quaternion Adapter’ı: `{x, y, z, w} → [w, x, y, z]`)*

**ARCore Geographic Policy:** Relative Local Motion Only Until Explicit ENU Alignment *(ARCore Coğrafi Politikası: Açık ENU Hizalamasına Kadar Yalnızca Göreli Yerel Hareket)*

**Primary Error Frame:** Local ENU in Metres *(Temel Hata Çerçevesi: Metre Cinsinden Yerel ENU)*

**Vertical Navigation:** Secondary / Experimental *(Dikey Navigasyon: İkincil / Deneysel)*

**Next Documentation Item:** 15 — GNSS Subsystem *(Sonraki Dokümantasyon Öğesi: 15 — GNSS Alt Sistemi)*