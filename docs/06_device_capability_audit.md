# 06 — Device Capability Audit (Cihaz Yetenek Denetimi)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the mandatory pre-development hardware and runtime capability audit for the Xiaomi Redmi Note 9 Pro used by the NAVGUARD project. *(Bu doküman, NAVGUARD projesinde kullanılan Xiaomi Redmi Note 9 Pro için zorunlu geliştirme öncesi donanım ve çalışma zamanı yetenek denetimini tanımlar.)*

The purpose of the audit is to replace theoretical device assumptions with measured runtime evidence before navigation algorithms, sensor sampling parameters, artificial intelligence pipelines, and experimental protocols are finalized. *(Denetimin amacı, navigasyon algoritmaları, sensör örnekleme parametreleri, yapay zekâ hatları ve deney protokolleri kesinleştirilmeden önce teorik cihaz varsayımlarını ölçülmüş çalışma zamanı kanıtlarıyla değiştirmektir.)*

The audit will determine which Android sensors are actually exposed by the physical device, how they behave during runtime, and whether the device can support the minimum and target NAVGUARD configurations. *(Denetim, fiziksel cihaz tarafından gerçekte hangi Android sensörlerinin sunulduğunu, çalışma sırasında nasıl davrandıklarını ve cihazın minimum ile hedef NAVGUARD yapılandırmalarını destekleyip destekleyemeyeceğini belirleyecektir.)*

No hardware-sensitive navigation parameter will be considered final until the relevant audit item has been completed. *(İlgili denetim öğesi tamamlanmadan donanıma duyarlı hiçbir navigasyon parametresi nihai kabul edilmeyecektir.)*

---

# 2. Audit Objectives (Denetim Hedefleri)

The audit will identify the exact Android and Xiaomi software environment of the physical test device. *(Denetim, fiziksel test cihazının kesin Android ve Xiaomi yazılım ortamını belirleyecektir.)*

The audit will enumerate all sensors exposed through the Android Sensor Framework. *(Denetim, Android Sensor Framework üzerinden sunulan tüm sensörleri listeleyecektir.)*

The audit will identify the manufacturer and technical metadata of the sensors required by NAVGUARD. *(Denetim, NAVGUARD tarafından gerekli sensörlerin üreticisini ve teknik metadata bilgilerini belirleyecektir.)*

The audit will measure actual sensor event delivery frequencies instead of relying only on requested sampling rates. *(Denetim, yalnızca talep edilen örnekleme hızlarına güvenmek yerine gerçek sensör olay teslim frekanslarını ölçecektir.)*

The audit will evaluate basic sensor noise and stationary stability. *(Denetim, temel sensör gürültüsünü ve sabit durum kararlılığını değerlendirecektir.)*

The audit will verify GNSS availability and runtime behavior. *(Denetim, GNSS kullanılabilirliğini ve çalışma zamanı davranışını doğrulayacaktır.)*

The audit will verify ARCore installation, compatibility, camera access, and motion tracking behavior. *(Denetim, ARCore kurulumunu, uyumluluğunu, kamera erişimini ve hareket takip davranışını doğrulayacaktır.)*

The audit will verify that a lightweight TensorFlow Lite model can execute locally on the physical device. *(Denetim, hafif bir TensorFlow Lite modelinin fiziksel cihaz üzerinde yerel olarak çalışabildiğini doğrulayacaktır.)*

The audit will establish an initial battery, storage, memory, and thermal baseline. *(Denetim, başlangıç batarya, depolama, bellek ve termal temel referansını oluşturacaktır.)*

---

# 3. Audit Timing (Denetim Zamanlaması)

The Device Capability Audit must be performed before full navigation development begins. *(Cihaz Yetenek Denetimi, tam navigasyon geliştirmesi başlamadan önce gerçekleştirilmelidir.)*

A minimal diagnostic implementation may be developed specifically to collect the required runtime information. *(Gerekli çalışma zamanı bilgilerini toplamak için özel olarak minimum bir tanısal uygulama geliştirilebilir.)*

The diagnostic functionality should later remain available inside NAVGUARD as a developer or research diagnostics module where practical. *(Tanısal işlevler uygulanabilir olduğu ölçüde daha sonra NAVGUARD içerisinde geliştirici veya araştırma tanı modülü olarak kullanılabilir kalmalıdır.)*

The final device baseline will be frozen only after all critical audit items are resolved. *(Nihai cihaz temel referansı yalnızca tüm kritik denetim öğeleri çözüldükten sonra sabitlenecektir.)*

---

# 4. Audit Status Definitions (Denetim Durumu Tanımları)

### PASS (GEÇTİ)

A PASS result means that the capability is available and sufficiently functional for the intended NAVGUARD use case. *(PASS sonucu, yeteneğin mevcut ve amaçlanan NAVGUARD kullanım senaryosu için yeterince işlevsel olduğu anlamına gelir.)*

### PASS WITH LIMITATION (SINIRLAMAYLA GEÇTİ)

A PASS WITH LIMITATION result means that the capability can be used but requires a documented restriction, reduced configuration, or fallback behavior. *(PASS WITH LIMITATION sonucu, yeteneğin kullanılabileceği ancak dokümante edilmiş bir kısıtlama, azaltılmış yapılandırma veya geri dönüş davranışı gerektirdiği anlamına gelir.)*

### WARNING (UYARI)

A WARNING result means that the capability is available but exhibits behavior that may affect navigation quality and requires further evaluation. *(WARNING sonucu, yeteneğin mevcut ancak navigasyon kalitesini etkileyebilecek davranış gösterdiği ve daha fazla değerlendirme gerektirdiği anlamına gelir.)*

### FAIL (BAŞARISIZ)

A FAIL result means that the capability is unavailable or unsuitable for the planned use case. *(FAIL sonucu, yeteneğin mevcut olmadığı veya planlanan kullanım senaryosu için uygun olmadığı anlamına gelir.)*

### NOT APPLICABLE (UYGULANAMAZ)

A NOT APPLICABLE result means that the capability is not required by the selected NAVGUARD configuration. *(NOT APPLICABLE sonucu, yeteneğin seçilen NAVGUARD yapılandırması tarafından gerekli olmadığı anlamına gelir.)*

---

# 5. Criticality Levels (Kritiklik Seviyeleri)

### CRITICAL (KRİTİK)

Failure of a critical capability prevents the minimum NAVGUARD configuration from operating as currently designed. *(Kritik bir yeteneğin başarısız olması minimum NAVGUARD yapılandırmasının mevcut tasarımla çalışmasını engeller.)*

### HIGH (YÜKSEK)

Failure of a high-priority capability prevents the target configuration from operating but does not necessarily invalidate the minimum PDR-based project. *(Yüksek öncelikli bir yeteneğin başarısız olması hedef yapılandırmanın çalışmasını engeller ancak minimum PDR tabanlı projeyi zorunlu olarak geçersiz kılmaz.)*

### MEDIUM (ORTA)

Failure of a medium-priority capability requires an alternative implementation but does not threaten the primary research objective. *(Orta öncelikli bir yeteneğin başarısız olması alternatif bir uygulama gerektirir ancak temel araştırma hedefini tehdit etmez.)*

### LOW (DÜŞÜK)

Failure of a low-priority capability affects only optional diagnostics or future enhancements. *(Düşük öncelikli bir yeteneğin başarısız olması yalnızca isteğe bağlı tanı özelliklerini veya gelecekteki geliştirmeleri etkiler.)*

---

# 6. Audit Execution Environment (Denetim Çalışma Ortamı)

The audit must be performed on the physical Xiaomi Redmi Note 9 Pro rather than only on an Android emulator. *(Denetim yalnızca Android emülatörü üzerinde değil fiziksel Xiaomi Redmi Note 9 Pro üzerinde gerçekleştirilmelidir.)*

The device should be restarted before the formal audit session when practical. *(Uygulanabilir olduğunda resmî denetim oturumundan önce cihaz yeniden başlatılmalıdır.)*

Unnecessary background applications should be closed before performance-related measurements. *(Performansla ilişkili ölçümlerden önce gereksiz arka plan uygulamaları kapatılmalıdır.)*

Battery percentage, charging state, device temperature, and network state should be recorded before relevant tests. *(İlgili testlerden önce batarya yüzdesi, şarj durumu, cihaz sıcaklığı ve ağ durumu kaydedilmelidir.)*

The same physical device must be used for all initial baseline measurements. *(Tüm başlangıç temel referans ölçümleri için aynı fiziksel cihaz kullanılmalıdır.)*

---

# 7. Device Identity Audit — AUD-DEV-001 (Cihaz Kimliği Denetimi — AUD-DEV-001)

The exact runtime device identity must be recorded before sensor testing begins. *(Sensör testleri başlamadan önce kesin çalışma zamanı cihaz kimliği kaydedilmelidir.)*

The information should be obtained from Android runtime properties or system settings rather than inferred only from the commercial device name. *(Bilgi yalnızca ticari cihaz adından çıkarılmak yerine Android çalışma zamanı özelliklerinden veya sistem ayarlarından elde edilmelidir.)*

### Required Record (Gerekli Kayıt)

| Property (Özellik) | Result (Sonuç) |
| --- | --- |
| Manufacturer *(Üretici)* | TBD |
| Commercial Model *(Ticari Model)* | Xiaomi Redmi Note 9 Pro |
| Android Model Identifier *(Android Model Tanımlayıcısı)* | TBD |
| Android Device Code *(Android Cihaz Kodu)* | TBD |
| Android Version *(Android Sürümü)* | TBD |
| Android API Level *(Android API Seviyesi)* | TBD |
| Xiaomi / MIUI / System Version *(Xiaomi / MIUI / Sistem Sürümü)* | TBD |
| Security Patch Level *(Güvenlik Yaması Seviyesi)* | TBD |
| Kernel Version *(Kernel Sürümü)* | TBD |
| Primary ABI *(Birincil ABI)* | TBD |
| Build Identifier *(Build Tanımlayıcısı)* | TBD |

### Acceptance Criterion (Kabul Kriteri)

The device identity must be recorded completely enough to reproduce the software environment used by later experiments. *(Cihaz kimliği, daha sonraki deneylerde kullanılan yazılım ortamını yeniden oluşturabilecek kadar eksiksiz kaydedilmelidir.)*

**Expected Status:** PASS *(Beklenen Durum: GEÇTİ)*

**Actual Status:** TBD *(Gerçek Durum: TBD)*

---

# 8. Compute and Memory Audit — AUD-DEV-002 (İşlem ve Bellek Denetimi — AUD-DEV-002)

The available processor architecture, memory, and storage environment must be recorded. *(Mevcut işlemci mimarisi, bellek ve depolama ortamı kaydedilmelidir.)*

The purpose is not to benchmark maximum theoretical performance but to establish the real runtime resource baseline of the project device. *(Amaç maksimum teorik performansı benchmark etmek değil proje cihazının gerçek çalışma zamanı kaynak temel referansını oluşturmaktır.)*

### Required Record (Gerekli Kayıt)

| Property (Özellik) | Result (Sonuç) |
| --- | --- |
| SoC *(Sistem Çipi)* | Qualcomm Snapdragon 720G — Published Baseline *(Yayınlanmış Temel Referans)* |
| CPU Architecture *(CPU Mimarisi)* | TBD Runtime Verification *(TBD Çalışma Zamanı Doğrulaması)* |
| Logical CPU Cores *(Mantıksal CPU Çekirdekleri)* | TBD |
| Total RAM *(Toplam RAM)* | TBD |
| Available RAM at Audit Start *(Denetim Başlangıcındaki Kullanılabilir RAM)* | TBD |
| Total Internal Storage *(Toplam Dahili Depolama)* | TBD |
| Available Internal Storage *(Kullanılabilir Dahili Depolama)* | TBD |

### Acceptance Criterion (Kabul Kriteri)

The device must provide sufficient available memory and storage to operate the application and record planned experimental sessions without resource failure. *(Cihaz, uygulamayı çalıştırmak ve planlanan deneysel oturumları kaynak hatası olmadan kaydetmek için yeterli kullanılabilir bellek ve depolama sağlamalıdır.)*

**Actual Status:** TBD *(Gerçek Durum: TBD)*

---

# 9. Android Sensor Enumeration Audit — AUD-SEN-001 (Android Sensör Listeleme Denetimi — AUD-SEN-001)

NAVGUARD must enumerate every sensor exposed by Android using the SensorManager runtime API. *(NAVGUARD, Android tarafından sunulan her sensörü SensorManager çalışma zamanı API’sini kullanarak listelemelidir.)*

The audit must use the complete sensor list rather than query only the sensors already expected by the project. *(Denetim yalnızca proje tarafından zaten beklenen sensörleri sorgulamak yerine tam sensör listesini kullanmalıdır.)*

This makes it possible to identify useful physical and virtual sensors that were not visible in published device specifications. *(Bu, yayınlanmış cihaz özelliklerinde görünmeyen kullanışlı fiziksel ve sanal sensörlerin belirlenmesini mümkün kılar.)*

### Metadata to Record for Each Sensor (Her Sensör İçin Kaydedilecek Metadata)

- **Sensor Name** *(Sensör Adı)*
- **Vendor** *(Üretici)*
- **Version** *(Sürüm)*
- **Android Sensor Type** *(Android Sensör Türü)*
- **String Type** *(String Türü)*
- **Resolution** *(Çözünürlük)*
- **Maximum Range** *(Maksimum Aralık)*
- **Reported Power Consumption** *(Bildirilen Güç Tüketimi)*
- **Minimum Delay** *(Minimum Gecikme)*
- **Maximum Delay if Available** *(Mevcutsa Maksimum Gecikme)*
- **Reporting Mode** *(Raporlama Modu)*
- **Wake-Up Sensor Status** *(Uyandırma Sensörü Durumu)*

Android exposes sensor availability and technical properties at runtime, including vendor, resolution, maximum range, power requirements, and minimum delay. *(Android; üretici, çözünürlük, maksimum aralık, güç gereksinimleri ve minimum gecikme dahil olmak üzere sensör kullanılabilirliğini ve teknik özelliklerini çalışma zamanında sunar.)*

### Acceptance Criterion (Kabul Kriteri)

A complete runtime inventory of the physical device sensors must be produced and stored. *(Fiziksel cihaz sensörlerinin eksiksiz çalışma zamanı envanteri oluşturulmalı ve saklanmalıdır.)*

**Actual Status:** TBD *(Gerçek Durum: TBD)*

---

# 10. Required Sensor Availability Audit — AUD-SEN-002 (Zorunlu Sensör Kullanılabilirlik Denetimi — AUD-SEN-002)

The following sensor sources must be checked individually. *(Aşağıdaki sensör kaynakları ayrı ayrı kontrol edilmelidir.)*

| Sensor (Sensör) | Android Type (Android Türü) | Criticality (Kritiklik) | Result (Sonuç) |
| --- | --- | --- | --- |
| Accelerometer *(İvmeölçer)* | TYPE_ACCELEROMETER | CRITICAL *(KRİTİK)* | TBD |
| Gyroscope *(Jiroskop)* | TYPE_GYROSCOPE | CRITICAL *(KRİTİK)* | TBD |
| Magnetic Field Sensor *(Manyetik Alan Sensörü)* | TYPE_MAGNETIC_FIELD | CRITICAL *(KRİTİK)* | TBD |
| Rotation Vector *(Dönüş Vektörü)* | TYPE_ROTATION_VECTOR | HIGH *(YÜKSEK)* | AVAILABLE AND FORMALLY EXERCISED — STAGE 3B *(MEVCUT VE RESMÎ OLARAK ÇALIŞTIRILDI — STAGE 3B)* |
| Game Rotation Vector *(Oyun Dönüş Vektörü)* | TYPE_GAME_ROTATION_VECTOR | MEDIUM *(ORTA)* | TBD |
| Linear Acceleration *(Doğrusal İvme)* | TYPE_LINEAR_ACCELERATION | MEDIUM *(ORTA)* | TBD |
| Gravity *(Yerçekimi)* | TYPE_GRAVITY | MEDIUM *(ORTA)* | TBD |
| Step Detector *(Adım Algılayıcı)* | TYPE_STEP_DETECTOR | LOW *(DÜŞÜK)* | AVAILABLE AND FORMALLY EXERCISED — STAGE 3C *(MEVCUT VE RESMÎ OLARAK ÇALIŞTIRILDI — STAGE 3C)* |
| Step Counter *(Adım Sayacı)* | TYPE_STEP_COUNTER | LOW *(DÜŞÜK)* | TBD |
| Pressure / Barometer *(Basınç / Barometre)* | TYPE_PRESSURE | LOW *(DÜŞÜK)* | TBD |

The Android-provided `TYPE_STEP_DETECTOR` is the primary and only formal Stage 3C step source and has been physically audited. `TYPE_STEP_COUNTER` was not used by the formal diagnostic. Stage 3C does not validate general step-detection accuracy and does not implement step length or PDR. *(Android tarafından sağlanan `TYPE_STEP_DETECTOR`, Stage 3C'nin birincil ve tek resmî adım kaynağıdır ve fiziksel olarak denetlenmiştir. `TYPE_STEP_COUNTER` resmî tanıda kullanılmamıştır. Stage 3C genel adım-algılama doğruluğunu doğrulamaz ve adım uzunluğu veya PDR uygulamaz.)*

### Minimum PASS Condition (Minimum GEÇTİ Koşulu)

Accelerometer, gyroscope, magnetic field information, and the GNSS subsystem must be available for the planned minimum architecture. *(Planlanan minimum mimari için ivmeölçer, jiroskop, manyetik alan bilgisi ve GNSS alt sistemi mevcut olmalıdır.)*

---

# 11. Accelerometer Metadata Audit — AUD-ACC-001 (İvmeölçer Metadata Denetimi — AUD-ACC-001)

The exact accelerometer implementation must be recorded. *(Kesin ivmeölçer uygulaması kaydedilmelidir.)*

### Result Table (Sonuç Tablosu)

| Property (Özellik) | Result (Sonuç) |
| --- | --- |
| Sensor Name *(Sensör Adı)* | TBD |
| Vendor *(Üretici)* | TBD |
| Version *(Sürüm)* | TBD |
| Resolution *(Çözünürlük)* | TBD |
| Maximum Range *(Maksimum Aralık)* | TBD |
| Minimum Delay *(Minimum Gecikme)* | TBD |
| Reported Power *(Bildirilen Güç)* | TBD |
| Wake-Up *(Uyandırma)* | TBD |
| Reporting Mode *(Raporlama Modu)* | TBD |

**Criticality:** CRITICAL *(Kritiklik: KRİTİK)*

**Actual Status:** TBD *(Gerçek Durum: TBD)*

---

# 12. Gyroscope Metadata Audit — AUD-GYR-001 (Jiroskop Metadata Denetimi — AUD-GYR-001)

The exact gyroscope implementation must be recorded. *(Kesin jiroskop uygulaması kaydedilmelidir.)*

### Result Table (Sonuç Tablosu)

| Property (Özellik) | Result (Sonuç) |
| --- | --- |
| Sensor Name *(Sensör Adı)* | TBD |
| Vendor *(Üretici)* | TBD |
| Version *(Sürüm)* | TBD |
| Resolution *(Çözünürlük)* | TBD |
| Maximum Range *(Maksimum Aralık)* | TBD |
| Minimum Delay *(Minimum Gecikme)* | TBD |
| Reported Power *(Bildirilen Güç)* | TBD |
| Wake-Up *(Uyandırma)* | TBD |
| Reporting Mode *(Raporlama Modu)* | TBD |

**Criticality:** CRITICAL *(Kritiklik: KRİTİK)*

**Actual Status:** TBD *(Gerçek Durum: TBD)*

---

# 13. Magnetometer Metadata Audit — AUD-MAG-001 (Manyetometre Metadata Denetimi — AUD-MAG-001)

The exact geomagnetic sensor implementation must be recorded. *(Kesin jeomanyetik sensör uygulaması kaydedilmelidir.)*

### Result Table (Sonuç Tablosu)

| Property (Özellik) | Result (Sonuç) |
| --- | --- |
| Sensor Name *(Sensör Adı)* | TBD |
| Vendor *(Üretici)* | TBD |
| Version *(Sürüm)* | TBD |
| Resolution *(Çözünürlük)* | TBD |
| Maximum Range *(Maksimum Aralık)* | TBD |
| Minimum Delay *(Minimum Gecikme)* | TBD |
| Reported Power *(Bildirilen Güç)* | TBD |
| Wake-Up *(Uyandırma)* | TBD |
| Reporting Mode *(Raporlama Modu)* | TBD |

**Criticality:** CRITICAL *(Kritiklik: KRİTİK)*

**Actual Status:** TBD *(Gerçek Durum: TBD)*

---

# 14. Virtual Orientation Sensor Audit — AUD-ORI-001 (Sanal Yönelim Sensörü Denetimi — AUD-ORI-001)

The availability of Android sensor-fusion outputs must be verified. *(Android sensör füzyonu çıktılarının kullanılabilirliği doğrulanmalıdır.)*

The preferred orientation-related source is the rotation vector rather than the deprecated legacy orientation sensor. *(Tercih edilen yönelimle ilişkili kaynak, kullanımdan kaldırılmış eski orientation sensor yerine rotation vector’dür.)*

### Required Checks (Gerekli Kontroller)

| Capability (Yetenek) | Available (Mevcut) | Runtime Stable (Çalışma Zamanında Kararlı) |
| --- | --- | --- |
| Rotation Vector *(Dönüş Vektörü)* | YES — `Rotation Vector Non-wakeup` | YES — 3/3 FORMAL STAGE 3B SESSIONS |
| Game Rotation Vector *(Oyun Dönüş Vektörü)* | TBD | TBD |
| Gravity *(Yerçekimi)* | TBD | TBD |
| Linear Acceleration *(Doğrusal İvme)* | TBD | TBD |

### Acceptance Criterion (Kabul Kriteri)

At least one reliable orientation strategy must be available from physical sensors or a suitable Android fused sensor combination. *(Fiziksel sensörlerden veya uygun bir Android füzyonlu sensör kombinasyonundan en az bir güvenilir yönelim stratejisi mevcut olmalıdır.)*

**Actual Status:** PARTIAL — `TYPE_ROTATION_VECTOR` availability, real heading delivery, timestamp monotonicity, clockwise-positive response, and circular continuity were physically exercised in Stage 3B; heading absolute accuracy and true-north absolute accuracy remain not validated. *(Gerçek Durum: KISMİ — `TYPE_ROTATION_VECTOR` kullanılabilirliği, gerçek heading teslimi, zaman damgası monotonluğu, saat yönünde pozitif tepki ve dairesel süreklilik Stage 3B'de fiziksel olarak çalıştırıldı; heading mutlak doğruluğu ve gerçek-kuzey mutlak doğruluğu doğrulanmamış durumda.)*

---

# 15. Sensor Timestamp Audit — AUD-TIME-001 (Sensör Zaman Damgası Denetimi — AUD-TIME-001)

### English

NAVGUARD must verify that sensor events contain monotonically increasing timestamps suitable for relative timing calculations. The application must not assume that callbacks arrive at perfectly constant wall-clock intervals.

#### Full Audit Procedure

The full audit records at least 60 seconds of continuous stationary accelerometer and gyroscope data, calculates interval statistics from consecutive event timestamps, and checks for non-monotonic timestamps, duplicates, and unusually long gaps.

#### Stage 2B Physical Evidence

Stage 2B used `SensorEvent.timestamp` as the event timestamp authority; it did not treat callback arrival time as the sample timestamp. The accelerometer, gyroscope, magnetometer, and rotation vector were each measured in three 10-second requested-duration sessions on the tested Xiaomi Redmi Note 9 Pro running Android 12 / API 31. The phone remained stationary on a stable surface with the screen awake, the application in the foreground, USB connected, one diagnostic active at a time, and no intended interaction during each run.

All 12 sessions completed with valid timing summaries and monotonically increasing timestamp sequences. No non-monotonic timestamp was observed. Using `gapThresholdMultiplier = 3.0`, no interval above the provisional `60,000,000 ns` threshold was observed in any session. This threshold remains provisional and is not a general device guarantee.

| Sensor | Sessions | Event Count per Session | Monotonic Sessions | Sessions with Provisional >60 ms Gaps |
| --- | ---: | --- | ---: | ---: |
| Accelerometer | 3 | 518 / 518 / 518 | 3/3 | 0/3 |
| Gyroscope | 3 | 504 / 504 / 503 | 3/3 | 0/3 |
| Magnetometer | 3 | 500 / 500 / 500 | 3/3 | 0/3 |
| Rotation Vector | 3 | 502 / 502 / 502 | 3/3 | 0/3 |

#### Acceptance Criterion

Timestamps must be suitable for determining measurement intervals and synchronizing the navigation pipeline.

**Actual Status:** PARTIAL — Stage 2B physically verified monotonic timestamp capture for the tested four-sensor configuration and 12 sessions. The full 60-second AUD-TIME-001 procedure and broader runtime-condition coverage remain pending; sensor signal quality, noise, bias, and calibration were not evaluated.

### Türkçe

NAVGUARD, sensör olaylarının göreli zamanlama hesaplamalarına uygun monotonik olarak artan zaman damgaları içerdiğini doğrulamalıdır. Uygulama, callback'lerin tamamen sabit duvar saati aralıklarında geldiğini varsaymamalıdır.

#### Tam Denetim Prosedürü

Tam denetim, sabit durumdaki ivmeölçer ve jiroskoptan en az 60 saniye sürekli veri kaydeder, ardışık olay zaman damgalarından aralık istatistiklerini hesaplar ve monotonik olmayan zaman damgalarını, yinelenen zaman damgalarını ve olağandışı uzun boşlukları kontrol eder.

#### Stage 2B Fiziksel Kanıtı

Stage 2B, olay zaman damgası otoritesi olarak `SensorEvent.timestamp` kullandı; callback varış zamanını örnek zaman damgası olarak ele almadı. İvmeölçer, jiroskop, manyetometre ve dönüş vektörünün her biri, Android 12 / API 31 çalıştıran test cihazı Xiaomi Redmi Note 9 Pro üzerinde talep edilen 10 saniyelik üç oturumda ölçüldü. Her oturum sırasında telefon kararlı bir yüzey üzerinde sabit tutuldu; ekran açık, uygulama ön planda ve USB bağlantısı etkin durumdaydı, aynı anda yalnızca bir tanı çalıştı ve amaçlı kullanıcı etkileşimi yapılmadı.

On iki oturumun tamamı geçerli zamanlama özetleri ve monotonik olarak artan zaman damgası dizileriyle tamamlandı. Monotonik olmayan zaman damgası gözlenmedi. `gapThresholdMultiplier = 3.0` kullanıldığında hiçbir oturumda geçici `60.000.000 ns` eşiğinin üzerinde aralık gözlenmedi. Bu eşik geçici kalır ve genel bir cihaz garantisi değildir.

| Sensör | Oturum | Oturum Başına Olay Sayısı | Monotonik Oturum | Geçici >60 ms Boşluk İçeren Oturum |
| --- | ---: | --- | ---: | ---: |
| İvmeölçer | 3 | 518 / 518 / 518 | 3/3 | 0/3 |
| Jiroskop | 3 | 504 / 504 / 503 | 3/3 | 0/3 |
| Manyetometre | 3 | 500 / 500 / 500 | 3/3 | 0/3 |
| Dönüş Vektörü | 3 | 502 / 502 / 502 | 3/3 | 0/3 |

#### Kabul Kriteri

Zaman damgaları, ölçüm aralıklarını belirlemek ve navigasyon hattını senkronize etmek için uygun olmalıdır.

**Gerçek Durum:** KISMİ — Stage 2B, test edilen dört sensörlü yapılandırma ve 12 oturum için monotonik zaman damgası yakalamayı fiziksel olarak doğruladı. Tam 60 saniyelik AUD-TIME-001 prosedürü ve daha geniş çalışma koşulu kapsamı beklemektedir; sensör sinyal kalitesi, gürültü, bias ve kalibrasyon değerlendirilmemiştir.

---

# 16. Effective Sampling Rate Audit — AUD-RATE-001 (Etkin Örnekleme Hızı Denetimi — AUD-RATE-001)

### English

Requested sensor frequency and delivered sensor frequency must be treated as separate values. Android sensor delivery timing can vary, so effective event/sample rate must be calculated from event timestamps.

#### Full Audit Planned Rates

- Approximately 20 Hz
- Approximately 50 Hz
- Approximately 100 Hz where appropriate

NAVGUARD does not require sampling above 200 Hz for the planned architecture.

#### Stage 2B Requested Configuration and Observations

All Stage 2B sessions used `requestedSamplingPeriodUs = 20,000 µs`, `requestedNominalRateHz = 50.0 Hz`, `collectionDurationTargetMs = 10,000 ms`, and `maxReportLatencyUs = 0`. The 50.0 Hz value is the requested nominal configuration, not a guaranteed delivered rate.

| Sensor | Requested Nominal Rate | Observed Timestamp-Derived Aggregate Mean Rate | Observed Run Range |
| --- | ---: | ---: | ---: |
| Accelerometer | 50.0 Hz | ~52.10 Hz | ~52.079–52.125 Hz |
| Gyroscope | 50.0 Hz | ~51.07 Hz | ~51.072–51.076 Hz |
| Magnetometer | 50.0 Hz | ~50.00 Hz | ~50.000 Hz; 20.000 ms median interval in all runs |
| Rotation Vector | 50.0 Hz | ~51.10 Hz | ~51.072–51.130 Hz |

These values are timestamp-derived effective event/sample-rate observations for the tested Redmi Note 9 Pro, Stage 2B configuration, and 12 sessions. They are not callback-arrival frequencies, universal hardware constants, or production-rate selections.

#### Acceptance Criterion

The accelerometer and gyroscope should provide sufficiently stable sampling around the selected navigation rate for time-series processing. The exact accepted production frequency will be selected from broader measured evidence rather than maximum capability or a single requested value.

**Actual Status:** PARTIAL — Requested-versus-observed timing was physically characterized for the fixed Stage 2B configuration. The full planned multi-rate audit and production sampling-rate decision remain pending.

### Türkçe

Talep edilen sensör frekansı ile sağlanan sensör frekansı ayrı değerler olarak ele alınmalıdır. Android sensör teslim zamanlaması değişebileceği için etkin olay/örnek hızı olay zaman damgalarından hesaplanmalıdır.

#### Tam Denetimde Planlanan Hızlar

- Yaklaşık 20 Hz
- Yaklaşık 50 Hz
- Uygun olduğunda yaklaşık 100 Hz

NAVGUARD, planlanan mimari için 200 Hz'in üzerinde örneklemeye ihtiyaç duymaz.

#### Stage 2B Talep Yapılandırması ve Gözlemleri

Tüm Stage 2B oturumlarında `requestedSamplingPeriodUs = 20.000 µs`, `requestedNominalRateHz = 50,0 Hz`, `collectionDurationTargetMs = 10.000 ms` ve `maxReportLatencyUs = 0` kullanıldı. 50,0 Hz değeri talep edilen nominal yapılandırmadır; garanti edilen sağlanan hız değildir.

| Sensör | Talep Edilen Nominal Hız | Gözlenen Timestamp-Türevli Birleşik Ortalama Hız | Gözlenen Oturum Aralığı |
| --- | ---: | ---: | ---: |
| İvmeölçer | 50,0 Hz | ~52,10 Hz | ~52,079–52,125 Hz |
| Jiroskop | 50,0 Hz | ~51,07 Hz | ~51,072–51,076 Hz |
| Manyetometre | 50,0 Hz | ~50,00 Hz | ~50,000 Hz; tüm oturumlarda 20,000 ms medyan aralık |
| Dönüş Vektörü | 50,0 Hz | ~51,10 Hz | ~51,072–51,130 Hz |

Bu değerler test edilen Redmi Note 9 Pro, Stage 2B yapılandırması ve 12 oturum için timestamp-türevli etkin olay/örnek hızı gözlemleridir. Callback varış frekansları, evrensel donanım sabitleri veya üretim hızı seçimleri değildir.

#### Kabul Kriteri

İvmeölçer ve jiroskop, zaman serisi işleme için seçilen navigasyon hızının çevresinde yeterince kararlı örnekleme sağlamalıdır. Kesin kabul edilen üretim frekansı, maksimum yetenek veya tek bir talep değeri yerine daha geniş ölçüm kanıtlarından seçilecektir.

**Gerçek Durum:** KISMİ — Talep edilen ve gözlenen zamanlama, sabit Stage 2B yapılandırması için fiziksel olarak karakterize edildi. Planlanan tam çoklu hız denetimi ve üretim örnekleme hızı kararı beklemektedir.

---

# 17. Stationary Accelerometer Test — AUD-ACC-002 (Sabit İvmeölçer Testi — AUD-ACC-002)

The device will be placed on a stable, motionless surface. *(Cihaz kararlı ve hareketsiz bir yüzeye yerleştirilecektir.)*

At least 60 seconds of accelerometer measurements will be recorded. *(En az 60 saniye ivmeölçer ölçümü kaydedilecektir.)*

The test will characterize baseline noise, bias-like behavior, and gravitational magnitude stability. *(Test temel gürültüyü, bias benzeri davranışı ve yerçekimi büyüklüğü kararlılığını karakterize edecektir.)*

### Metrics to Calculate (Hesaplanacak Metrikler)

- **Mean X, Y, and Z acceleration** *(Ortalama X, Y ve Z ivmesi)*
- **Standard deviation of each axis** *(Her eksenin standart sapması)*
- **Acceleration magnitude mean** *(İvme büyüklüğü ortalaması)*
- **Acceleration magnitude standard deviation** *(İvme büyüklüğü standart sapması)*
- **Minimum and maximum observed values** *(Gözlemlenen minimum ve maksimum değerler)*

### Result Table (Sonuç Tablosu)

| Metric (Metrik) | X | Y | Z | Magnitude (Büyüklük) |
| --- | --- | --- | --- | --- |
| Mean *(Ortalama)* | TBD | TBD | TBD | TBD |
| Standard Deviation *(Standart Sapma)* | TBD | TBD | TBD | TBD |
| Minimum *(Minimum)* | TBD | TBD | TBD | TBD |
| Maximum *(Maksimum)* | TBD | TBD | TBD | TBD |

### Acceptance Criterion (Kabul Kriteri)

The signal must be sufficiently stable to support filtering, step detection, and motion-feature extraction. *(Sinyal filtreleme, adım tespiti ve hareket özelliği çıkarımını destekleyecek kadar kararlı olmalıdır.)*

No fixed numerical noise threshold will be frozen before the first real measurement. *(İlk gerçek ölçüm yapılmadan sabit bir sayısal gürültü eşiği sabitlenmeyecektir.)*

**Actual Status:** TBD *(Gerçek Durum: TBD)*

---

# 18. Stationary Gyroscope Test — AUD-GYR-002 (Sabit Jiroskop Testi — AUD-GYR-002)

The device will remain stationary on a stable surface for at least 60 seconds. *(Cihaz en az 60 saniye kararlı bir yüzey üzerinde hareketsiz kalacaktır.)*

The expected physical angular velocity during this period is approximately zero. *(Bu süre boyunca beklenen fiziksel açısal hız yaklaşık sıfırdır.)*

Any persistent non-zero mean will be treated as a candidate gyroscope bias. *(Kalıcı sıfırdan farklı herhangi bir ortalama aday jiroskop bias değeri olarak ele alınacaktır.)*

### Result Table (Sonuç Tablosu)

| Metric (Metrik) | X | Y | Z |
| --- | --- | --- | --- |
| Mean Angular Rate *(Ortalama Açısal Hız)* | TBD | TBD | TBD |
| Standard Deviation *(Standart Sapma)* | TBD | TBD | TBD |
| Minimum *(Minimum)* | TBD | TBD | TBD |
| Maximum *(Maksimum)* | TBD | TBD | TBD |

### Acceptance Criterion (Kabul Kriteri)

The gyroscope must produce a sufficiently stable stationary signal for short-term rotation estimation after preprocessing. *(Jiroskop, ön işleme sonrasında kısa süreli dönüş tahmini için yeterince kararlı bir sabit durum sinyali üretmelidir.)*

A measurable bias does not automatically produce a FAIL result if it can be estimated and compensated in software. *(Ölçülebilir bir bias yazılımda tahmin edilip telafi edilebiliyorsa otomatik olarak FAIL sonucu oluşturmaz.)*

**Actual Status:** TBD *(Gerçek Durum: TBD)*

---

# 19. Magnetometer Stability Test — AUD-MAG-002 (Manyetometre Kararlılık Testi — AUD-MAG-002)

The device will be tested in at least one magnetically quiet location and one ordinary indoor environment. *(Cihaz en az bir manyetik olarak sakin konumda ve bir normal kapalı ortamda test edilecektir.)*

The objective is to observe how strongly heading-related measurements react to nearby environmental conditions. *(Amaç, yönle ilişkili ölçümlerin yakındaki çevresel koşullara ne kadar güçlü tepki verdiğini gözlemlemektir.)*

### Measurements to Record (Kaydedilecek Ölçümler)

- **Magnetic field X, Y, and Z values** *(Manyetik alan X, Y ve Z değerleri)*
- **Magnetic field magnitude** *(Manyetik alan büyüklüğü)*
- **Android-reported accuracy state where available** *(Mevcutsa Android tarafından bildirilen doğruluk durumu)*
- **Derived heading stability** *(Türetilmiş yön kararlılığı)*

### Acceptance Criterion (Kabul Kriteri)

The magnetometer must provide useful directional information in at least normal low-disturbance test conditions. *(Manyetometre en azından normal düşük bozulmalı test koşullarında kullanışlı yön bilgisi sağlamalıdır.)*

Environmental sensitivity will be treated as an expected limitation rather than immediate hardware failure. *(Çevresel hassasiyet doğrudan donanım hatası yerine beklenen bir sınırlama olarak ele alınacaktır.)*

**Actual Status:** TBD *(Gerçek Durum: TBD)*

---

# 20. Manual Rotation Test — AUD-ORI-002 (Manuel Dönüş Testi — AUD-ORI-002)

The device will be rotated manually through controlled orientation changes while gyroscope, magnetometer, and rotation-vector outputs are recorded. *(Jiroskop, manyetometre ve rotation-vector çıktıları kaydedilirken cihaz kontrollü yönelim değişiklikleri boyunca manuel olarak döndürülecektir.)*

The purpose is to verify that orientation-related sensors respond consistently to known physical movements. *(Amaç yönelimle ilişkili sensörlerin bilinen fiziksel hareketlere tutarlı tepki verdiğini doğrulamaktır.)*

### Planned Motions (Planlanan Hareketler)

- **Approximately 90-degree clockwise rotation** *(Yaklaşık 90 derece saat yönünde dönüş)*
- **Approximately 90-degree counterclockwise rotation** *(Yaklaşık 90 derece saat yönünün tersine dönüş)*
- **Approximately 180-degree rotation** *(Yaklaşık 180 derece dönüş)*
- **Return to initial orientation** *(Başlangıç yönelimine dönüş)*

### Acceptance Criterion (Kabul Kriteri)

Orientation-related measurements must respond in the expected direction and return reasonably close to the initial orientation after a controlled return movement. *(Yönelimle ilişkili ölçümler beklenen yönde tepki vermeli ve kontrollü geri dönüş hareketinden sonra başlangıç yönelimine makul ölçüde yakın dönmelidir.)*

**Actual Status:** TBD *(Gerçek Durum: TBD)*

---

# 21. Short Walking Sensor Test — AUD-MOT-001 (Kısa Yürüyüş Sensör Testi — AUD-MOT-001)

A short controlled walking session will verify that the inertial streams capture clear pedestrian motion patterns. *(Kısa kontrollü bir yürüyüş oturumu, ataletsel akışların belirgin yaya hareket örüntülerini yakaladığını doğrulayacaktır.)*

### Planned Procedure (Planlanan Prosedür)

Stand still for approximately 10 seconds. *(Yaklaşık 10 saniye sabit dur.)*

Walk approximately 20 to 30 normal steps. *(Yaklaşık 20 ile 30 normal adım yürü.)*

Stop and remain stationary for approximately 10 seconds. *(Dur ve yaklaşık 10 saniye sabit kal.)*

Perform one or more deliberate turns. *(Bir veya daha fazla bilinçli dönüş gerçekleştir.)*

### Acceptance Criterion (Kabul Kriteri)

The recorded signals must show distinguishable stationary, walking, and turning patterns suitable for later preprocessing and machine learning analysis. *(Kaydedilen sinyaller daha sonraki ön işleme ve makine öğrenmesi analizi için uygun ayırt edilebilir sabit durma, yürüme ve dönme örüntüleri göstermelidir.)*

**Actual Status:** TBD *(Gerçek Durum: TBD)*

---

# 22. Native Step Sensor Audit — AUD-STEP-001 (Native Adım Sensörü Denetimi — AUD-STEP-001)

### English

Stage 3C formally exercised Android `Sensor.TYPE_STEP_DETECTOR` on the Xiaomi Redmi Note 9 Pro running Android 12 / API 31. Android reported the sensor display name literally as `pedometer  Non-wakeup`. `TYPE_STEP_COUNTER` was not used as a source or fallback. The runtime path requires `android.permission.ACTIVITY_RECOGNITION` on the tested API level.

Each formal diagnostic window was 30 seconds. `SensorEvent.timestamp` was the step measurement-time authority, while `SystemClock.elapsedRealtimeNanos()` controlled the operation window. No wall clock was used as step timing authority. The diagnostic returned aggregate counts, interval statistics, and observed cadence; it returned no raw step timestamp list or raw sensor samples and used no persistence. A zero-step session was accepted as a valid result.

| Session | Manual Steps | Updates | Accepted | Invalid | Out of Window | Unique | Duplicate | Non-Monotonic | Result |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Stationary | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | PASS |
| Controlled walk 1 | 20 | 21 | 16 | 0 | 5 | 16 | 0 | 0 | PASS WITH OBSERVATION |
| Controlled walk 2 | 30 | 30 | 30 | 0 | 0 | 30 | 0 | 0 | PASS |

The stationary session observed no false step event during that single 30-second window; this is not a global zero-false-positive claim. In the 20-step walk, five delivered events were excluded by the formal session-window filter and the accepted count was 16. This must not be described as an 80% validated sensor-accuracy result, and no one-to-one mapping between excluded events and manually counted steps is inferred. In the 30-step walk, the accepted event count matched the manual count. This single match is not sufficient to validate general step-detection accuracy.

### Türkçe

Stage 3C, Android 12 / API 31 çalıştıran Xiaomi Redmi Note 9 Pro üzerinde Android `Sensor.TYPE_STEP_DETECTOR` kaynağını resmî olarak çalıştırdı. Android sensör görünen adını tam olarak `pedometer  Non-wakeup` şeklinde bildirdi. `TYPE_STEP_COUNTER` kaynak veya fallback olarak kullanılmadı. Çalışma zamanı yolu, test edilen API seviyesinde `android.permission.ACTIVITY_RECOGNITION` iznini gerektirir.

Her resmî tanı penceresi 30 saniyeydi. Adım ölçüm-zamanı otoritesi `SensorEvent.timestamp`, operasyon penceresi denetimi ise `SystemClock.elapsedRealtimeNanos()` idi. Wall clock adım zamanlaması otoritesi olarak kullanılmadı. Tanı birleşik sayıları, aralık istatistiklerini ve gözlenen kadansı döndürdü; ham adım zaman damgası listesi veya ham sensör örneği döndürmedi ve kalıcılaştırma kullanmadı. Sıfır-adımlı oturum geçerli sonuç olarak kabul edildi.

| Oturum | Manuel Adım | Update | Kabul Edilen | Geçersiz | Pencere Dışı | Benzersiz | Duplicate | Monotonik Olmayan | Sonuç |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Sabit | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | GEÇTİ |
| Kontrollü yürüyüş 1 | 20 | 21 | 16 | 0 | 5 | 16 | 0 | 0 | GÖZLEMLE GEÇTİ |
| Kontrollü yürüyüş 2 | 30 | 30 | 30 | 0 | 0 | 30 | 0 | 0 | GEÇTİ |

Sabit oturumda yalnızca bu 30 saniyelik pencere boyunca false adım olayı gözlenmedi; bu global sıfır-false-positive iddiası değildir. 20-adımlık yürüyüşte teslim edilen beş olay resmî oturum-penceresi filtresiyle dışlandı ve kabul edilen sayı 16 oldu. Bu, doğrulanmış %80 sensör doğruluğu olarak tanımlanamaz ve dışlanan olaylarla manuel sayılan adımlar arasında bire bir eşleme çıkarılamaz. 30-adımlık yürüyüşte kabul edilen olay sayısı manuel sayımla eşleşti. Bu tek eşleşme genel adım-algılama doğruluğunu doğrulamaya yeterli değildir.

**Actual Status:** VERIFIED — STAGE 3C RUNTIME SCOPE; STEP-DETECTION ACCURACY NOT VALIDATED *(Gerçek Durum: DOĞRULANDI — STAGE 3C ÇALIŞMA ZAMANI KAPSAMI; ADIM-ALGILAMA DOĞRULUĞU DOĞRULANMADI)*

---

# 23. GNSS Availability Audit — AUD-GNSS-001 (GNSS Kullanılabilirlik Denetimi — AUD-GNSS-001)

### English

The physical device must successfully acquire geographic position information outdoors under ordinary open-sky conditions.

#### Values Planned for the Full Audit

- **Latitude**
- **Longitude**
- **Reported accuracy**
- **Altitude if available**
- **Speed if available**
- **Bearing if available**
- **Timestamp**

#### Acceptance Criterion

The device must provide stable enough outdoor location updates to establish the initial NAVGUARD position and record an evaluation reference trajectory.

#### Stage 2C Runtime Timing Evidence

Stage 2C implemented a foreground-only native diagnostic using Android `LocationManager`, `GPS_PROVIDER`, `LocationListener`, `GnssStatus.Callback`, and a dedicated `HandlerThread`. Formal sessions requested `requestedMinTimeMs = 1,000 ms` and `requestedMinDistanceM = 0 m`, allowed up to 120 seconds for the first received GPS location callback, and then collected for 60 seconds. The timing authority was `Location.elapsedRealtimeNanos` in the `elapsed_realtime_nanoseconds` domain; callback arrival wall-clock time was not used.

The foreground precise-location flow and preflight were physically verified on the Xiaomi Redmi Note 9 Pro running Android 12 / API 31. Before permission, coarse and fine location were not granted and `canRunFormalDiagnostic` was false while `GPS_PROVIDER` and location services were available and enabled. After the user granted precise foreground location, both coarse and fine permission states were granted and `canRunFormalDiagnostic` became true. Stage 2C added only `ACCESS_COARSE_LOCATION` and `ACCESS_FINE_LOCATION`; it added no background-location permission, location foreground service, Flutter dependency, or Android dependency.

Three formal physical sessions completed normally. Location-update and `GnssStatus` registrations succeeded in 3/3 sessions, all three timing summaries were valid, all three `Location.elapsedRealtimeNanos` sequences were monotonic, and 0/3 sessions contained mock locations.

| Session | Location Events | Duration | Delta Count | Min Interval | Mean Interval | Median Interval | P95 Interval | Max Interval | Mean Fix Rate |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | 61 | 60 s | 60 | 1.000 s | 1.000 s | 1.000 s | 1.000 s | 1.000 s | 1.000 Hz |
| 2 | 61 | 60 s | 60 | 1.000 s | 1.000 s | 1.000 s | 1.000 s | 1.000 s | 1.000 Hz |
| 3 | 59 | 59 s | 58 | 1.000 s | ~1.017241379 s | 1.000 s | 1.000 s | 2.000 s | ~0.9830508475 Hz |

Across the tested device, configuration, and sessions, the median and p95 callback intervals were 1.000 s in 3/3 sessions, the observed timestamp-derived mean rate range was approximately 0.983–1.000 Hz, and the observed maximum consecutive interval range was 1–2 seconds. The 2.000 s interval in Session 3 did not invalidate the monotonic, mock-free timing summary. No GNSS large-gap threshold is defined, and the provisional Stage 2B sensor threshold of 60 ms does not apply to GNSS. A requested 1,000 ms minimum interval does not guarantee fixed 1 Hz delivery.

`GnssStatus.Callback.onFirstFix()` reported 36.609 s, 20.646 s, and 9.716 s in Sessions 1–3. These TTFF values are GNSS-engine metadata and are not the measured wait to the first received GPS `Location` callback.

| Session | Reported Accuracy Min | Reported Accuracy Median | Reported Accuracy Max | Last / Max Satellites | Last / Max Used in Fix |
| --- | ---: | ---: | ---: | ---: | ---: |
| 1 | ~18.376 m | ~53.901 m | ~78.789 m | 30 / 30 | 7 / 16 |
| 2 | ~15.508 m | ~30.388 m | ~93.592 m | 30 / 31 | 6 / 9 |
| 3 | ~24.265 m | ~59.101 m | ~256.142 m | 31 / 31 | 4 / 8 |

Horizontal-accuracy metadata was present for every recorded callback. These values are only Android-reported metadata; they do not measure coordinate error or validate GNSS accuracy, quality, bias, calibration, or EKF covariance. Satellite values are sanitized aggregate status counts only and do not validate satellite geometry, signal quality, position accuracy, or navigation performance.

The Stage 2C diagnostic does not read, store, return, log, or persist latitude, longitude, altitude, speed, bearing, raw `Location` objects, raw GPS tracks, NMEA, `GnssMeasurements`, pseudorange, carrier phase, navigation messages, satellite identities, or per-satellite C/N0. Therefore Stage 2C physically verifies GPS runtime callback availability and characterizes timing only; GNSS coordinate accuracy, initial-position/anchor behavior, reference-trajectory recording, denial control, and Ground Truth Firewall enforcement were outside Stage 2C and were not verified by it. Stage 3A anchor evidence follows below.

#### Stage 3A GNSS Anchor + Local ENU Evidence

Stage 3A implemented real foreground GNSS-anchor acquisition before future software-defined GNSS denial. Android `LocationManager.GPS_PROVIDER` is the only anchor source and `ACCESS_FINE_LOCATION` is required. Background location, `FusedLocationProviderClient`, and network or passive providers are not used.

A formal candidate must come from `GPS_PROVIDER`, be non-mock, contain finite valid latitude and longitude, have `Location.elapsedRealtimeNanos > 0`, and include finite positive reported horizontal accuracy. Altitude and vertical accuracy are optional. The first structurally valid candidate establishes the formal GNSS measurement-time window. Subsequent candidates qualify only when their `Location.elapsedRealtimeNanos` values fall from 0 through 10 seconds relative to that first candidate. The Handler delay only terminates operation/control flow; it is not physical GNSS measurement-time authority. No fixed 1 Hz delivery guarantee or GNSS callback-gap threshold is defined.

The first structurally valid GNSS fix timeout is 120 seconds, the candidate collection measurement window is 10 seconds, and at least three structurally valid candidates are required. Selection uses the lowest Android-reported horizontal accuracy, with newer `Location.elapsedRealtimeNanos` as the tie-break. Reported accuracy is metadata, not measured ground-truth error or proof that the selected candidate is physically most accurate.

Initial physical preflight with Android location services disabled returned `fineLocationPermissionGranted = true`, `locationServicesEnabled = false`, `gpsProviderAvailable = true`, `gpsProviderEnabled = false`, `acquisitionRunning = false`, and `canAcquireAnchor = false`; formal acquisition was correctly unavailable. After Android location/GPS was enabled, the corresponding values were `true`, `true`, `true`, `true`, `false`, and `true`; formal acquisition was ready.

Three independent formal acquisitions completed successfully on the Xiaomi Redmi Note 9 Pro running Android 12 / API 31:

| Session | Success | Candidate Count | Selected Reported Horizontal Accuracy | Altitude Available |
| --- | --- | ---: | ---: | --- |
| 1 | true | 10 | ~17.98036 m | true |
| 2 | true | 11 | ~15.32364 m | true |
| 3 | true | 10 | ~34.79066 m | true |

All three results reported `selectionPolicy = lowest_reported_horizontal_accuracy_then_newer_elapsed_realtime`, `coordinateAccuracyValidated = false`, `firstValidFixTimeoutMs = 120000`, `candidateCollectionWindowMs = 10000`, and `minimumValidCandidateCount = 3`. Thus 3/3 anchor acquisitions succeeded and the minimum-candidate policy was satisfied in every observed session. The approximately 17.98 m, 15.32 m, and 34.79 m values are Android-reported horizontal-accuracy metadata; GNSS absolute coordinate accuracy remains **NOT VALIDATED**.

Explicit runtime clear/reacquire was verified between formal sessions. The sanitized state transitioned from `anchor_locked` to `no_anchor`, after which acquisition succeeded again. Explicit cancellation was also physically verified: the cancelled operation returned `success = false` and `errorCategory = acquisition_cancelled`; it was not counted as a successful acquisition.

A successful anchor remains immutable for its runtime reference session. Replacement requires Clear Anchor followed by Acquire GNSS Anchor. No disk persistence is implemented. Shared formal logs contained sanitized metadata only: no raw latitude, longitude, altitude value, ECEF coordinates, or candidate-coordinate list was observed. Raw anchor coordinates are not printed in the formal sanitized diagnostic logs and are not persisted by Stage 3A; they still exist as necessary runtime values for internal navigation math.

The coordinate foundation uses WGS84 with semi-major axis 6378137.0 m, flattening `1 / 298.257223563`, and eccentricity squared `f * (2 - f)`. External latitude/longitude degrees are converted internally to radians through WGS84 geodetic → ECEF → anchor-relative ENU, where +E is East, +N is North, +U is Up, and units are meters. Full 3D ENU requires both anchor and target ellipsoid altitudes. When altitude is unavailable, the same deterministic `h = 0` reference is used for both points and only horizontal E/N is returned; no measured or fabricated Up component is claimed. A GNSS anchor may therefore lock without altitude and expose `Horizontal ENU origin ready`.

Stage 3A static validation passed: `flutter analyze`, 32/32 tests, `flutter build apk --debug`, and `git diff --check`. That implementation changed eight source/test paths. Physical anchor flow is verified for the tested scope, but GNSS absolute coordinate accuracy, survey-grade anchor quality, physical ENU distance accuracy, and same-location anchor repeatability are not validated. At the Stage 3A boundary, GNSS-denied navigation, true heading, PDR, ARCore-to-ENU, Ground Truth Firewall, Quality Engine, EKF, and the 20% improvement target were unimplemented or unmeasured as applicable; the later Stage 3B handset-heading foundation is recorded in Section 59.

**Criticality:** CRITICAL

**Actual Status:** PARTIAL — Stage 2C runtime timing and Stage 3A pre-denial GNSS-anchor flow were physically verified for their defined scopes, including 3/3 successful anchor sessions, clear/reacquire, and cancellation. Reference-trajectory recording and physical coordinate/ENU accuracy validation remain pending; GNSS absolute coordinate accuracy is not validated.

### Türkçe

Fiziksel cihaz, normal açık gökyüzü koşullarında dış mekânda coğrafi konum bilgisini başarıyla elde etmelidir.

#### Tam Denetim İçin Planlanan Değerler

- **Enlem**
- **Boylam**
- **Bildirilen doğruluk**
- **Mevcutsa yükseklik**
- **Mevcutsa hız**
- **Mevcutsa yön açısı**
- **Zaman damgası**

#### Kabul Kriteri

Cihaz, başlangıç NAVGUARD konumunu oluşturmak ve değerlendirme referans rotasını kaydetmek için yeterince kararlı dış mekân konum güncellemeleri sağlamalıdır.

#### Stage 2C Çalışma Zamanı Zamanlama Kanıtı

Stage 2C; Android `LocationManager`, yalnızca `GPS_PROVIDER`, `LocationListener`, `GnssStatus.Callback` ve özel bir `HandlerThread` kullanan yalnızca ön planda çalışan native bir tanı uyguladı. Resmî oturumlarda `requestedMinTimeMs = 1.000 ms` ve `requestedMinDistanceM = 0 m` talep edildi, ilk alınan GPS konum callback'i için en fazla 120 saniye beklendi ve ardından 60 saniye veri toplandı. Zamanlama otoritesi `elapsed_realtime_nanoseconds` alanındaki `Location.elapsedRealtimeNanos` idi; callback varış duvar saati kullanılmadı.

Hassas ön plan konum izni akışı ve preflight, Android 12 / API 31 çalıştıran Xiaomi Redmi Note 9 Pro üzerinde fiziksel olarak doğrulandı. İzin öncesinde coarse ve fine konum izinleri verilmemişti ve `GPS_PROVIDER` ile konum hizmetleri kullanılabilir ve etkin durumdayken `canRunFormalDiagnostic` false idi. Kullanıcı hassas ön plan konum izni verdikten sonra coarse ve fine izin durumlarının ikisi de granted oldu ve `canRunFormalDiagnostic` true değerine geçti. Stage 2C yalnızca `ACCESS_COARSE_LOCATION` ve `ACCESS_FINE_LOCATION` izinlerini ekledi; arka plan konum izni, konum foreground service'i, Flutter dependency'si veya Android dependency'si eklemedi.

Üç resmî fiziksel oturum normal biçimde tamamlandı. Konum güncellemesi ve `GnssStatus` kayıtları 3/3 oturumda başarılı oldu, üç zamanlama özetinin tamamı geçerliydi, üç `Location.elapsedRealtimeNanos` dizisinin tamamı monotonikti ve 0/3 oturum mock konum içerdi.

| Oturum | Konum Olayı | Süre | Delta Sayısı | Min Aralık | Ortalama Aralık | Medyan Aralık | P95 Aralık | Maks Aralık | Ortalama Fix Hızı |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | 61 | 60 s | 60 | 1,000 s | 1,000 s | 1,000 s | 1,000 s | 1,000 s | 1,000 Hz |
| 2 | 61 | 60 s | 60 | 1,000 s | 1,000 s | 1,000 s | 1,000 s | 1,000 s | 1,000 Hz |
| 3 | 59 | 59 s | 58 | 1,000 s | ~1,017241379 s | 1,000 s | 1,000 s | 2,000 s | ~0,9830508475 Hz |

Test edilen cihaz, yapılandırma ve oturumlarda medyan ve p95 callback aralıkları 3/3 oturumda 1,000 s, gözlenen timestamp-türevli ortalama hız aralığı yaklaşık 0,983–1,000 Hz ve gözlenen maksimum ardışık aralık 1–2 saniye oldu. Oturum 3'teki 2,000 s aralık, monotonik ve mock içermeyen zamanlama özetini geçersiz kılmadı. Tanımlı bir GNSS büyük-boşluk eşiği yoktur ve Stage 2B'nin geçici 60 ms sensör eşiği GNSS için uygulanmaz. Talep edilen 1.000 ms minimum aralık, sabit 1 Hz teslimi garanti etmez.

`GnssStatus.Callback.onFirstFix()` Oturum 1–3 için 36,609 s, 20,646 s ve 9,716 s bildirdi. Bu TTFF değerleri GNSS motoru metadata'sıdır ve ilk alınan GPS `Location` callback'ine kadar ölçülen bekleme süresi değildir.

| Oturum | Bildirilen Doğruluk Min | Bildirilen Doğruluk Medyan | Bildirilen Doğruluk Maks | Son / Maks Uydu | Son / Maks Fix'te Kullanılan |
| --- | ---: | ---: | ---: | ---: | ---: |
| 1 | ~18,376 m | ~53,901 m | ~78,789 m | 30 / 30 | 7 / 16 |
| 2 | ~15,508 m | ~30,388 m | ~93,592 m | 30 / 31 | 6 / 9 |
| 3 | ~24,265 m | ~59,101 m | ~256,142 m | 31 / 31 | 4 / 8 |

Yatay doğruluk metadata'sı kaydedilen her callback'te mevcuttu. Bu değerler yalnızca Android tarafından bildirilen metadata'dır; koordinat hatasını ölçmez ve GNSS doğruluğunu, kaliteyi, bias'ı, kalibrasyonu veya EKF kovaryansını doğrulamaz. Uydu değerleri yalnızca sanitize edilmiş birleşik durum sayılarıdır; uydu geometrisini, sinyal kalitesini, konum doğruluğunu veya navigasyon performansını doğrulamaz.

Stage 2C tanısı; enlem, boylam, yükseklik, hız, yön açısı, ham `Location` nesneleri, ham GPS rotaları, NMEA, `GnssMeasurements`, pseudorange, carrier phase, navigasyon mesajları, uydu kimlikleri veya uydu başına C/N0 değerlerini okumaz, saklamaz, döndürmez, loglamaz ya da kalıcılaştırmaz. Bu nedenle Stage 2C yalnızca GPS çalışma zamanı callback kullanılabilirliğini fiziksel olarak doğrular ve zamanlamayı karakterize eder; GNSS koordinat doğruluğu, başlangıç konumu/anchor davranışı, referans rota kaydı, kesinti denetimi ve Ground Truth Firewall uygulaması Stage 2C kapsamı dışındaydı ve onun tarafından doğrulanmadı. Stage 3A anchor kanıtı aşağıdadır.

#### Stage 3A GNSS Anchor + Yerel ENU Kanıtı

Stage 3A, gelecekteki yazılım tanımlı GNSS kesintisinden önce gerçek yalnızca ön planda çalışan GNSS anchor edinimini uyguladı. Android `LocationManager.GPS_PROVIDER` tek anchor kaynağıdır ve `ACCESS_FINE_LOCATION` gerekir. Arka plan konumu, `FusedLocationProviderClient`, network veya passive provider kullanılmaz.

Resmî aday `GPS_PROVIDER` kaynağından gelmeli, mock olmamalı, sonlu ve geçerli enlem/boylam içermeli, `Location.elapsedRealtimeNanos > 0` olmalı ve sonlu pozitif bildirilen yatay doğruluk taşımalıdır. Yükseklik ve dikey doğruluk isteğe bağlıdır. İlk yapısal olarak geçerli aday resmî GNSS ölçüm-zamanı penceresini başlatır. Sonraki adaylar yalnızca `Location.elapsedRealtimeNanos` değerleri ilk adaya göre 0 ile 10 saniye arasındaysa pencereye girer. Handler gecikmesi yalnızca operasyon/control-flow sonlandırmasıdır; fiziksel GNSS ölçüm-zamanı otoritesi değildir. Sabit 1 Hz teslim garantisi veya GNSS callback-boşluk eşiği tanımlanmamıştır.

İlk yapısal olarak geçerli GNSS fix timeout'u 120 saniye, aday toplama ölçüm penceresi 10 saniye ve gereken minimum yapısal olarak geçerli aday sayısı üçtür. Seçim en düşük Android-bildirilen yatay doğruluğu, eşitlik bozucu olarak daha yeni `Location.elapsedRealtimeNanos` değerini kullanır. Bildirilen doğruluk metadata'dır; ölçülmüş ground-truth hatası veya seçilen adayın fiziksel olarak en doğru olduğunun kanıtı değildir.

Android konum hizmetleri kapalıyken yapılan ilk fiziksel preflight; `fineLocationPermissionGranted = true`, `locationServicesEnabled = false`, `gpsProviderAvailable = true`, `gpsProviderEnabled = false`, `acquisitionRunning = false` ve `canAcquireAnchor = false` döndürdü; resmî edinim doğru biçimde kullanılamıyordu. Android konum/GPS açıldıktan sonra karşılık gelen değerler `true`, `true`, `true`, `true`, `false` ve `true` oldu; resmî edinim hazırdı.

Android 12 / API 31 çalıştıran Xiaomi Redmi Note 9 Pro üzerinde üç bağımsız resmî edinim başarıyla tamamlandı:

| Oturum | Başarı | Aday Sayısı | Seçilen Bildirilen Yatay Doğruluk | Yükseklik Mevcut |
| --- | --- | ---: | ---: | --- |
| 1 | true | 10 | ~17,98036 m | true |
| 2 | true | 11 | ~15,32364 m | true |
| 3 | true | 10 | ~34,79066 m | true |

Üç sonuç da `selectionPolicy = lowest_reported_horizontal_accuracy_then_newer_elapsed_realtime`, `coordinateAccuracyValidated = false`, `firstValidFixTimeoutMs = 120000`, `candidateCollectionWindowMs = 10000` ve `minimumValidCandidateCount = 3` bildirdi. Böylece 3/3 anchor edinimi başarılı oldu ve gözlenen her oturumda minimum-aday politikası sağlandı. Yaklaşık 17,98 m, 15,32 m ve 34,79 m değerleri Android-bildirilen yatay doğruluk metadata'sıdır; GNSS mutlak koordinat doğruluğu **DOĞRULANMAMIŞTIR**.

Resmî oturumlar arasında açık çalışma zamanı clear/reacquire doğrulandı. Sanitize edilmiş durum `anchor_locked` değerinden `no_anchor` değerine geçti ve sonrasında edinim yeniden başarılı oldu. Açık iptal de fiziksel olarak doğrulandı: iptal edilen operasyon `success = false` ve `errorCategory = acquisition_cancelled` döndürdü; başarılı edinim olarak sayılmadı.

Başarılı anchor kendi çalışma zamanı referans oturumunda değişmez kalır. Değiştirmek için Clear Anchor ve ardından Acquire GNSS Anchor gerekir. Disk kalıcılığı uygulanmamıştır. Paylaşılan resmî loglar yalnızca sanitize edilmiş metadata içerdi; ham enlem, boylam, yükseklik değeri, ECEF koordinatı veya aday koordinat listesi gözlenmedi. Ham anchor koordinatları resmî sanitize edilmiş tanı loglarında yazdırılmaz ve Stage 3A tarafından kalıcılaştırılmaz; iç navigasyon matematiği için gerekli çalışma zamanı değerleri olarak yine de mevcuttur.

Koordinat temeli; 6378137,0 m yarı-büyük eksen, `1 / 298.257223563` basıklık ve `f * (2 - f)` eksantriklik karesiyle WGS84 kullanır. Dış enlem/boylam dereceleri içeride radyana dönüştürülür ve WGS84 jeodezik → ECEF → anchor-göreli ENU hattı izlenir; +E Doğu, +N Kuzey, +U Yukarı ve birimler metredir. Tam 3B ENU için anchor ve hedef elipsoit yüksekliklerinin ikisi de gerekir. Yükseklik yoksa iki nokta için aynı deterministik `h = 0` referansı kullanılır ve yalnızca yatay E/N döndürülür; ölçülmüş veya uydurma Up bileşeni iddia edilmez. Bu nedenle GNSS anchor yükseklik olmadan kilitlenebilir ve `Horizontal ENU origin ready` gösterebilir.

Stage 3A statik doğrulaması geçti: `flutter analyze`, 32/32 test, `flutter build apk --debug` ve `git diff --check`. Bu uygulama sekiz kaynak/test yolunu değiştirdi. Fiziksel anchor akışı test edilen kapsamda doğrulandı ancak GNSS mutlak koordinat doğruluğu, survey-grade anchor niteliği, fiziksel ENU mesafe doğruluğu ve aynı-konum anchor tekrarlanabilirliği doğrulanmadı. Stage 3A sınırında GNSS-kesintili navigasyon, gerçek heading, PDR, ARCore-to-ENU, Ground Truth Firewall, Quality Engine, EKF ve %20 iyileştirme hedefi duruma göre uygulanmamış veya ölçülmemişti; sonraki Stage 3B handset-heading temeli Bölüm 59'da kaydedilmiştir.

**Kritiklik:** KRİTİK

**Gerçek Durum:** KISMİ — Stage 2C çalışma zamanı zamanlaması ve Stage 3A kesinti-öncesi GNSS anchor akışı; 3/3 başarılı anchor oturumu, clear/reacquire ve iptal dahil tanımlı kapsamlarında fiziksel olarak doğrulandı. Referans rota kaydı ve fiziksel koordinat/ENU doğruluk doğrulaması beklemektedir; GNSS mutlak koordinat doğruluğu doğrulanmamıştır.

---

# 24. GNSS Cold and Warm Acquisition Observation — AUD-GNSS-002 (GNSS Soğuk ve Sıcak Konum Alma Gözlemi — AUD-GNSS-002)

### English

GNSS acquisition behavior will be observed after application startup under ordinary outdoor conditions. The objective is to characterize practical initialization delay rather than certify receiver performance.

#### Full Audit Record

| Metric | Result |
| --- | --- |
| Time to First Acceptable Location | TBD |
| Initial Reported Accuracy | TBD |
| Stable Accuracy After 30 Seconds | TBD |

#### Stage 2C TTFF Metadata

`GnssStatus.Callback.onFirstFix()` was observed in all three formal Stage 2C sessions, reporting 36.609 s, 20.646 s, and 9.716 s. These values are session-specific GNSS-engine TTFF metadata. They are not a universal TTFF result and are not the wait time to the first received GPS `Location` callback. Stage 2C did not run a separately controlled cold-versus-warm acquisition protocol or validate a first acceptable coordinate.

**Actual Status:** PARTIAL — `GnssStatus.onFirstFix` metadata was observed, but the planned cold/warm acquisition comparison and first-acceptable-location assessment remain pending.

### Türkçe

GNSS konum alma davranışı normal dış mekân koşullarında uygulama başlangıcından sonra gözlemlenecektir. Amaç alıcı performansını sertifikalandırmak yerine pratik başlatma gecikmesini karakterize etmektir.

#### Tam Denetim Kaydı

| Metrik | Sonuç |
| --- | --- |
| İlk Kabul Edilebilir Konuma Kadar Süre | TBD |
| İlk Bildirilen Doğruluk | TBD |
| 30 Saniye Sonraki Kararlı Doğruluk | TBD |

#### Stage 2C TTFF Metadata'sı

`GnssStatus.Callback.onFirstFix()` üç resmî Stage 2C oturumunun tamamında gözlendi ve 36,609 s, 20,646 s ve 9,716 s değerlerini bildirdi. Bu değerler oturuma özgü GNSS motoru TTFF metadata'sıdır. Evrensel bir TTFF sonucu değildir ve ilk alınan GPS `Location` callback'ine kadar geçen bekleme süresi değildir. Stage 2C ayrı kontrollü bir soğuk-sıcak konum alma protokolü çalıştırmadı veya ilk kabul edilebilir koordinatı doğrulamadı.

**Gerçek Durum:** KISMİ — `GnssStatus.onFirstFix` metadata'sı gözlendi ancak planlanan soğuk/sıcak konum alma karşılaştırması ve ilk kabul edilebilir konum değerlendirmesi beklemektedir.

---

# 25. GNSS Ground-Truth Logging Audit — AUD-GNSS-003 (GNSS Gerçek Referans Kayıt Denetimi — AUD-GNSS-003)

NAVGUARD must prove that GNSS reference positions can be recorded while being excluded from the GNSS-denied estimator. *(NAVGUARD, GNSS referans konumlarının GNSS kesintili tahmin motorundan çıkarılmış halde kaydedilebildiğini kanıtlamalıdır.)*

The implementation must maintain a logical separation between the navigation input channel and the evaluation-only GNSS channel. *(Uygulama, navigasyon giriş kanalı ile yalnızca değerlendirme amaçlı GNSS kanalı arasında mantıksal bir ayrım korumalıdır.)*

### Acceptance Criterion (Kabul Kriteri)

A test session must demonstrate that GNSS records continue to be stored while the estimator reports GNSS input as disabled. *(Bir test oturumu, tahmin motoru GNSS girdisini devre dışı olarak raporlarken GNSS kayıtlarının saklanmaya devam ettiğini göstermelidir.)*

No GNSS coordinate from the evaluation channel may enter the denied estimator state update. *(Değerlendirme kanalından hiçbir GNSS koordinatı kesinti tahmin motoru durum güncellemesine girmemelidir.)*

**Criticality:** CRITICAL *(Kritiklik: KRİTİK)*

**Actual Status:** TBD *(Gerçek Durum: TBD)*

---

# 26. Raw GNSS Capability Audit — AUD-GNSS-004 (Ham GNSS Yetenek Denetimi — AUD-GNSS-004)

Raw GNSS measurement support will be checked as an optional diagnostic capability. *(Ham GNSS ölçüm desteği isteğe bağlı bir tanısal yetenek olarak kontrol edilecektir.)*

Android provides raw GNSS measurement access on supported devices, but this capability is not required by the minimum NAVGUARD architecture. *(Android desteklenen cihazlarda ham GNSS ölçüm erişimi sağlar ancak bu yetenek minimum NAVGUARD mimarisi tarafından gerekli değildir.)*

### Optional Checks (İsteğe Bağlı Kontroller)

- **GnssStatus availability** *(GnssStatus kullanılabilirliği)*
- **Satellite count information** *(Uydu sayısı bilgisi)*
- **Carrier-to-noise density information where available** *(Mevcutsa taşıyıcı-gürültü yoğunluğu bilgisi)*
- **GnssMeasurementsEvent availability** *(GnssMeasurementsEvent kullanılabilirliği)*

### Decision Rule (Karar Kuralı)

Failure of raw GNSS measurement access will not reduce the project below target status unless a later architecture explicitly depends on it. *(Ham GNSS ölçüm erişiminin başarısız olması, daha sonraki bir mimari açıkça buna bağımlı olmadığı sürece projeyi hedef durumunun altına düşürmeyecektir.)*

**Priority:** LOW *(Öncelik: DÜŞÜK)*

**Actual Status:** TBD *(Gerçek Durum: TBD)*

---

# 27. ARCore Installation Audit — AUD-AR-001 (ARCore Kurulum Denetimi — AUD-AR-001)

### English

Google officially lists the Redmi Note 9 Pro as an ARCore-supported device. The physical device must nevertheless be tested because project success depends on the installed software environment and actual runtime behavior.

#### Required Checks

- **Google Play Services for AR availability**
- **ARCore session creation**
- **Camera permission**
- **Rear camera startup**
- **AR tracking initialization**

#### Stage 2D Physical Evidence

The Stage 2D preflight on the tested Xiaomi Redmi Note 9 Pro running Android 12 / API 31 reported `cameraPermissionGranted = true`, `availabilityRaw = SUPPORTED_INSTALLED`, `availabilityCategory = ready`, `arCoreSupported = true`, `arCoreInstalledAndCurrent = true`, and `canRunFormalDiagnostic = true`. This confirms tested-device support and readiness; `SUPPORTED_INSTALLED` alone is not treated as live-tracking evidence.

Live behavior was independently exercised in three formal physical sessions. ARCore `Session` creation, configuration, and resume passed in 3/3 sessions. Dedicated GL/EGL initialization and camera-texture setup also passed in 3/3 sessions, and real `TrackingState.TRACKING` was observed in every session.

The application remains AR Optional. Stage 2D added `android.permission.CAMERA`, declared `com.google.ar.core` as `optional`, and used `com.google.ar:core:1.54.0`. It did not add an AR-required installation constraint, background-location permission, location foreground service, microphone permission, storage permission, or unrelated dependency.

#### Acceptance Criterion

An ARCore session must initialize successfully on the physical Redmi Note 9 Pro.

**Criticality:** HIGH

**Actual Status:** VERIFIED — STAGE 2D DIAGNOSTIC SCOPE

### Türkçe

Google, Redmi Note 9 Pro'yu resmî olarak ARCore destekli bir cihaz olarak listeler. Bununla birlikte proje başarısı yüklü yazılım ortamına ve gerçek çalışma zamanı davranışına bağlı olduğu için fiziksel cihaz test edilmelidir.

#### Gerekli Kontroller

- **Google Play Services for AR kullanılabilirliği**
- **ARCore oturumu oluşturma**
- **Kamera izni**
- **Arka kamera başlatma**
- **AR takip başlatma**

#### Stage 2D Fiziksel Kanıtı

Android 12 / API 31 çalıştıran test cihazı Xiaomi Redmi Note 9 Pro üzerindeki Stage 2D preflight; `cameraPermissionGranted = true`, `availabilityRaw = SUPPORTED_INSTALLED`, `availabilityCategory = ready`, `arCoreSupported = true`, `arCoreInstalledAndCurrent = true` ve `canRunFormalDiagnostic = true` bildirdi. Bu, test edilen cihazda destek ve hazır olma durumunu doğrular; yalnızca `SUPPORTED_INSTALLED` değeri canlı takip kanıtı olarak ele alınmaz.

Canlı davranış üç resmî fiziksel oturumda bağımsız olarak çalıştırıldı. ARCore `Session` oluşturma, yapılandırma ve resume 3/3 oturumda geçti. Özel GL/EGL başlatma ile kamera texture kurulumu da 3/3 oturumda geçti ve her oturumda gerçek `TrackingState.TRACKING` gözlendi.

Uygulama AR Optional kalır. Stage 2D `android.permission.CAMERA` ekledi, `com.google.ar.core` özelliğini `optional` olarak bildirdi ve `com.google.ar:core:1.54.0` kullandı. AR-required kurulum kısıtı, arka plan konum izni, konum foreground service'i, mikrofon izni, depolama izni veya ilgisiz dependency eklemedi.

#### Kabul Kriteri

Bir ARCore oturumu fiziksel Redmi Note 9 Pro üzerinde başarıyla başlatılmalıdır.

**Kritiklik:** YÜKSEK

**Gerçek Durum:** DOĞRULANDI — STAGE 2D TANI KAPSAMI

---

# 28. ARCore Pose Audit — AUD-AR-002 (ARCore Poz Denetimi — AUD-AR-002)

### English

The audit must verify that ARCore produces changing relative pose values as the device is physically moved. Required information includes translation X/Y/Z, rotation quaternion X/Y/Z/W, `Frame.timestamp`, and tracking state.

#### Stage 2D Physical Evidence

Three formal physical sessions were run: (1) the phone held approximately stationary while facing a visually detailed environment, (2) an approximately 120-degree rightward handheld/camera rotation with pauses, and (3) approximately 2–3 steps of rightward walking. All 3/3 sessions produced valid summaries, reached real `TrackingState.TRACKING`, exposed local-session tracking pose, produced monotonic `Frame.timestamp` sequences, completed without terminal errors, and contained no `STOPPED` frames.

| Session | Physical Scenario | Tracking Fraction | Net Local-Session Relative Translation | Maximum Displacement from First Tracking Pose |
| --- | --- | ---: | ---: | ---: |
| 1 | Approximately stationary | ~98.26% | ~0.0386 m | ~0.1027 m |
| 2 | Approximately 120-degree rightward rotation with pauses | ~98.15% | ~0.6313 m | ~0.7161 m |
| 3 | Approximately 2–3 steps rightward; exact distance not measured | ~98.36% | ~3.0063 m | ~3.0146 m |

Session 2 showed that ARCore maintained live tracking during controlled handheld rotational motion, but the diagnostic did not calculate a rotation-angle aggregate or validate the approximately 120-degree rotation. The translation values are not rotation-angle measurements. Session 3 showed a clear local-session relative pose change during real rightward walking, but the physical distance was not independently measured; the ARCore translation is not a ground-truth walking distance or distance-accuracy result.

The observed unique-frame rate was approximately 30.0295–30.0304 Hz. The median interval-derived rate was approximately 30.0304 Hz in all three sessions, the median frame interval was approximately 33.299584 ms, and the observed p95 interval range was approximately 33.325–33.350 ms. Non-monotonic `Frame.timestamp` count was zero in all sessions. These are tested-device/configuration/session observations, not a fixed or guaranteed 30 Hz rate. The time base of `Frame.timestamp` remains undefined for cross-source alignment.

`trackingFraction` is the fraction of unique ARCore frames observed in `TrackingState.TRACKING` during a tested diagnostic session. Its observed range was approximately 98.15%–98.36%; it is not a final NAVGUARD quality score, a universal reliability percentage, or a navigation-accuracy result. No quality threshold is frozen from these sessions.

Stage 2D applied no ARCore frame-gap threshold (`frameGapThresholdApplied = false`). The provisional 60 ms Stage 2B sensor threshold does not apply to ARCore, and no threshold is inferred from these sessions.

Stage 2D verified pose only in ARCore local-session coordinates. It did not implement or verify ARCore-to-ENU conversion, true north, WGS84 or map coordinates, GNSS-relative pose, absolute position, distance accuracy, scale accuracy, rotation accuracy, or absolute accuracy. Raw camera frames and raw pose trajectories were not persisted.

#### Acceptance Criterion

The pose output must respond consistently to physical movement and remain usable for relative displacement observation during ordinary tracking conditions.

**Actual Status:** VERIFIED — STAGE 2D DIAGNOSTIC SCOPE; COORDINATE, SCALE, AND ACCURACY VALIDATION PENDING

### Türkçe

Denetim, cihaz fiziksel olarak hareket ettirildiğinde ARCore'un değişen göreli poz değerleri ürettiğini doğrulamalıdır. Gerekli bilgiler öteleme X/Y/Z, dönüş quaternion X/Y/Z/W, `Frame.timestamp` ve takip durumudur.

#### Stage 2D Fiziksel Kanıtı

Üç resmî fiziksel oturum çalıştırıldı: (1) görsel olarak ayrıntılı bir ortama bakarken telefonun yaklaşık sabit tutulması, (2) duraklamalarla sağa doğru yaklaşık 120 derecelik elde telefon/kamera dönüşü ve (3) sağa doğru yaklaşık 2–3 adım yürüyüş. Oturumların 3/3'ü geçerli özet üretti, gerçek `TrackingState.TRACKING` durumuna ulaştı, yerel-oturum takip pozu sağladı, monotonik `Frame.timestamp` dizileri üretti, terminal hatası olmadan tamamlandı ve hiçbirinde `STOPPED` kare bulunmadı.

| Oturum | Fiziksel Senaryo | Tracking Fraction | Net Yerel-Oturum Göreli Ötelemesi | İlk Takip Pozundan Maksimum Yer Değiştirme |
| --- | --- | ---: | ---: | ---: |
| 1 | Yaklaşık sabit | ~%98,26 | ~0,0386 m | ~0,1027 m |
| 2 | Duraklamalarla sağa doğru yaklaşık 120 derece dönüş | ~%98,15 | ~0,6313 m | ~0,7161 m |
| 3 | Sağa doğru yaklaşık 2–3 adım; kesin mesafe ölçülmedi | ~%98,36 | ~3,0063 m | ~3,0146 m |

Oturum 2, ARCore'un kontrollü elde dönüş hareketi boyunca canlı takibi koruduğunu gösterdi; ancak tanı bir dönüş açısı özeti hesaplamadı veya yaklaşık 120 derecelik dönüşü doğrulamadı. Öteleme değerleri dönüş açısı ölçümü değildir. Oturum 3, gerçek sağa yürüme hareketi sırasında belirgin bir yerel-oturum göreli poz değişimi gösterdi; ancak fiziksel mesafe bağımsız olarak ölçülmedi. ARCore ötelemesi gerçek referans yürüme mesafesi veya mesafe doğruluğu sonucu değildir.

Gözlenen benzersiz-kare hızı yaklaşık 30,0295–30,0304 Hz idi. Medyan aralık-türevli hız üç oturumun tamamında yaklaşık 30,0304 Hz, medyan kare aralığı yaklaşık 33,299584 ms ve gözlenen p95 aralık yaklaşık 33,325–33,350 ms idi. Monotonik olmayan `Frame.timestamp` sayısı tüm oturumlarda sıfırdı. Bunlar test edilen cihaz/yapılandırma/oturum gözlemleridir; sabit veya garanti edilen 30 Hz hız değildir. Kaynaklar arası hizalama için `Frame.timestamp` zaman tabanı tanımsız kalır.

`trackingFraction`, test edilen bir tanı oturumunda `TrackingState.TRACKING` durumunda gözlenen benzersiz ARCore karelerinin oranıdır. Gözlenen aralık yaklaşık %98,15–%98,36 idi; bu değer nihai NAVGUARD kalite skoru, evrensel güvenilirlik yüzdesi veya navigasyon doğruluğu sonucu değildir. Bu oturumlardan bir kalite eşiği sabitlenmemiştir.

Stage 2D herhangi bir ARCore kare-boşluk eşiği uygulamadı (`frameGapThresholdApplied = false`). Stage 2B'nin geçici 60 ms sensör eşiği ARCore'a uygulanmaz ve bu oturumlardan bir eşik çıkarılmaz.

Stage 2D pozu yalnızca ARCore yerel-oturum koordinatlarında doğruladı. ARCore-to-ENU dönüşümü, true north, WGS84 veya harita koordinatları, GNSS'e göre poz, mutlak konum, mesafe doğruluğu, ölçek doğruluğu, dönüş doğruluğu veya mutlak doğruluğu uygulamadı ya da doğrulamadı. Ham kamera kareleri ve ham poz rotaları kalıcılaştırılmadı.

#### Kabul Kriteri

Poz çıktısı fiziksel harekete tutarlı şekilde tepki vermeli ve normal takip koşullarında göreli yer değiştirme gözlemi için kullanılabilir kalmalıdır.

**Gerçek Durum:** DOĞRULANDI — STAGE 2D TANI KAPSAMI; KOORDİNAT, ÖLÇEK VE DOĞRULUK DOĞRULAMASI BEKLİYOR

---

# 29. ARCore Stationary Drift Test — AUD-AR-003 (ARCore Sabit Durum Sürüklenme Testi — AUD-AR-003)

The device will remain as stationary as possible after ARCore tracking reaches a stable state. *(ARCore takibi kararlı bir duruma ulaştıktan sonra cihaz mümkün olduğunca sabit tutulacaktır.)*

The relative pose will be recorded for a planned period of at least 60 seconds. *(Göreli poz en az 60 saniyelik planlanan süre boyunca kaydedilecektir.)*

The purpose is to measure apparent position movement while no intentional physical displacement occurs. *(Amaç bilinçli fiziksel yer değiştirme gerçekleşmezken görünen konum hareketini ölçmektir.)*

### Metrics (Metrikler)

- **Maximum apparent displacement** *(Maksimum görünen yer değiştirme)*
- **Mean apparent displacement** *(Ortalama görünen yer değiştirme)*
- **Final apparent displacement** *(Nihai görünen yer değiştirme)*
- **Tracking interruptions** *(Takip kesintileri)*

### Acceptance Criterion (Kabul Kriteri)

The measured stationary drift must be characterized before ARCore is assigned a fusion confidence model. *(ARCore’a bir füzyon güven modeli atanmasından önce ölçülen sabit durum sürüklenmesi karakterize edilmelidir.)*

No fixed absolute threshold will be frozen until this experiment is performed. *(Bu deney gerçekleştirilene kadar sabit bir mutlak eşik sabitlenmeyecektir.)*

### Stage 2D Observation — English

During the approximately stationary session, the tracking fraction was approximately 98.26%, net local-session relative translation was approximately 0.0386 m, and maximum displacement from the first tracking pose was approximately 0.1027 m. This is a small non-zero local-session pose variation, or apparent drift-like motion, while the device was intended to remain approximately stationary. Because no independent reference position existed, it is not a formal drift benchmark, an error measurement, or an accuracy validation.

**Actual Status:** PARTIAL — STAGE 2D STATIONARY OBSERVATION RECORDED; FORMAL DRIFT BENCHMARK PENDING

### Stage 2D Gözlemi — Türkçe

Yaklaşık sabit oturumda tracking fraction yaklaşık %98,26, net yerel-oturum göreli ötelemesi yaklaşık 0,0386 m ve ilk takip pozundan maksimum yer değiştirme yaklaşık 0,1027 m idi. Bu, cihazın yaklaşık sabit kalması amaçlanırken gözlenen küçük, sıfır olmayan bir yerel-oturum poz değişimi veya görünür sürüklenme-benzeri harekettir. Bağımsız bir referans konum bulunmadığından resmî bir sürüklenme benchmark'ı, hata ölçümü veya doğruluk doğrulaması değildir.

**Gerçek Durum:** KISMİ — STAGE 2D SABİT DURUM GÖZLEMİ KAYDEDİLDİ; RESMÎ SÜRÜKLENME BENCHMARK'I BEKLİYOR

---

# 30. ARCore Tracking Degradation Audit — AUD-AR-004 (ARCore Takip Bozulması Denetimi — AUD-AR-004)

NAVGUARD must verify that ARCore tracking degradation can be detected. *(NAVGUARD, ARCore takip bozulmasının tespit edilebildiğini doğrulamalıdır.)*

The test should include ordinary conditions likely to reduce visual tracking quality without intentionally damaging the device or environment. *(Test, cihaza veya çevreye kasıtlı zarar vermeden görsel takip kalitesini azaltması muhtemel normal koşulları içermelidir.)*

### Example Conditions (Örnek Koşullar)

- **Low-texture surface** *(Düşük dokulu yüzey)*
- **Reduced lighting** *(Azaltılmış aydınlatma)*
- **Temporary camera obstruction** *(Geçici kamera engelleme)*
- **Faster device movement than normal walking** *(Normal yürüyüşten daha hızlı cihaz hareketi)*

### Acceptance Criterion (Kabul Kriteri)

NAVGUARD must detect when ARCore tracking is unavailable or degraded and must avoid blindly treating invalid pose measurements as reliable navigation input. *(NAVGUARD, ARCore takibi kullanılamaz veya bozulmuş olduğunda bunu tespit etmeli ve geçersiz poz ölçümlerini körü körüne güvenilir navigasyon girdisi olarak ele almamalıdır.)*

### Stage 2D Boundary — English

All three ordinary-condition sessions were free of `STOPPED` frames and terminal errors. Deliberate low-texture, reduced-lighting, obstruction, and excessive-motion degradation tests were not performed, so degradation detection and recovery remain unverified.

**Actual Status:** TBD — DEGRADATION PROCEDURE NOT EXECUTED

### Stage 2D Sınırı — Türkçe

Üç normal-koşul oturumunun tamamında `STOPPED` kare ve terminal hatası yoktu. Kasıtlı düşük doku, azaltılmış aydınlatma, engelleme ve aşırı hareket bozulma testleri yapılmadığından bozulma tespiti ve recovery doğrulanmamıştır.

**Gerçek Durum:** TBD — BOZULMA PROSEDÜRÜ ÇALIŞTIRILMADI

---

# 31. Camera Runtime Audit — AUD-CAM-001 (Kamera Çalışma Zamanı Denetimi — AUD-CAM-001)

The rear camera must be available to ARCore without resource conflicts during the intended navigation workflow. *(Arka kamera, amaçlanan navigasyon iş akışı sırasında kaynak çatışmaları olmadan ARCore tarafından kullanılabilir olmalıdır.)*

### Required Checks (Gerekli Kontroller)

- **Camera permission granted** *(Kamera izni verildi)*
- **ARCore camera initialization successful** *(ARCore kamera başlatma başarılı)*
- **No persistent camera conflict** *(Kalıcı kamera çatışması yok)*
- **Navigation UI remains responsive while camera tracking is active** *(Kamera takibi aktifken navigasyon kullanıcı arayüzü tepki verebilir kalıyor)*

### Stage 3B Evidence — English

Camera permission was granted, dedicated GL/EGL initialization and camera-texture setup passed in 3/3 sessions, the ARCore session resumed successfully in 3/3 sessions, and live tracking completed without a persistent camera conflict, visible crash, freeze, or terminal error. This evidence applies only to the Stage 2D diagnostic workflow, not a future combined navigation workload.

**Actual Status:** VERIFIED — STAGE 2D DIAGNOSTIC SCOPE

### Stage 2D Kanıtı — Türkçe

Kamera izni verildi; özel GL/EGL başlatma ve kamera texture kurulumu 3/3 oturumda geçti, ARCore oturumu 3/3 oturumda başarıyla resume edildi ve canlı takip kalıcı kamera çatışması, görünür çökme, donma veya terminal hatası olmadan tamamlandı. Bu kanıt yalnızca Stage 2D tanı iş akışına uygulanır; gelecekteki birleşik navigasyon iş yüküne uygulanmaz.

**Gerçek Durum:** DOĞRULANDI — STAGE 2D TANI KAPSAMI

---

# 32. TensorFlow Lite Runtime Audit — AUD-AI-001 (TensorFlow Lite Çalışma Zamanı Denetimi — AUD-AI-001)

Before the final NAVGUARD model is trained, the device must demonstrate that a small TensorFlow Lite test model can execute locally. *(Nihai NAVGUARD modeli eğitilmeden önce cihaz küçük bir TensorFlow Lite test modelini yerel olarak çalıştırabildiğini göstermelidir.)*

This audit verifies the deployment path independently from final model accuracy. *(Bu denetim, dağıtım hattını nihai model doğruluğundan bağımsız olarak doğrular.)*

### Required Checks (Gerekli Kontroller)

- **TFLite model loads successfully** *(TFLite modeli başarıyla yükleniyor)*
- **Input tensor can be populated** *(Girdi tensörü doldurulabiliyor)*
- **Inference executes successfully** *(Çıkarım başarıyla çalışıyor)*
- **Output tensor can be read** *(Çıktı tensörü okunabiliyor)*
- **Repeated inference does not crash the application** *(Tekrarlanan çıkarım uygulamayı çökertmiyor)*

### Acceptance Criterion (Kabul Kriteri)

A local model must complete repeated inference without network access. *(Yerel bir model ağ erişimi olmadan tekrarlanan çıkarımları tamamlamalıdır.)*

**Criticality:** HIGH *(Kritiklik: YÜKSEK)*

**Actual Status:** TBD *(Gerçek Durum: TBD)*

---

# 33. Preliminary AI Latency Audit — AUD-AI-002 (Ön Yapay Zekâ Gecikme Denetimi — AUD-AI-002)

A representative lightweight test model will be executed repeatedly to estimate the practical inference environment of the device. *(Temsili hafif bir test modeli, cihazın pratik çıkarım ortamını tahmin etmek için tekrar tekrar çalıştırılacaktır.)*

### Metrics (Metrikler)

- **First inference latency** *(İlk çıkarım gecikmesi)*
- **Median warm inference latency** *(Medyan sıcak çıkarım gecikmesi)*
- **Mean inference latency** *(Ortalama çıkarım gecikmesi)*
- **95th percentile inference latency** *(95. yüzdelik çıkarım gecikmesi)*
- **Maximum observed inference latency** *(Gözlemlenen maksimum çıkarım gecikmesi)*

### Result Table (Sonuç Tablosu)

| Metric (Metrik) | Result (Sonuç) |
| --- | --- |
| First Inference *(İlk Çıkarım)* | TBD |
| Median Inference *(Medyan Çıkarım)* | TBD |
| Mean Inference *(Ortalama Çıkarım)* | TBD |
| P95 Inference *(P95 Çıkarım)* | TBD |
| Maximum Inference *(Maksimum Çıkarım)* | TBD |

The final 1D-CNN will later receive its own dedicated benchmark. *(Nihai 1D-CNN daha sonra kendi özel benchmark’ına sahip olacaktır.)*

**Actual Status:** TBD *(Gerçek Durum: TBD)*

---

# 34. Local Storage Write Audit — AUD-STO-001 (Yerel Depolama Yazma Denetimi — AUD-STO-001)

NAVGUARD must verify that continuous sensor logging can occur without interrupting the acquisition pipeline. *(NAVGUARD, sürekli sensör kaydının veri toplama hattını kesintiye uğratmadan gerçekleşebildiğini doğrulamalıdır.)*

### Test Procedure (Test Prosedürü)

Record accelerometer, gyroscope, magnetometer, and available orientation information continuously for at least five minutes. *(İvmeölçer, jiroskop, manyetometre ve mevcut yönelim bilgilerini en az beş dakika sürekli kaydet.)*

Write timestamps and sensor values to the planned local storage format. *(Zaman damgalarını ve sensör değerlerini planlanan yerel depolama formatına yaz.)*

Verify record count and file or database integrity after the session. *(Oturumdan sonra kayıt sayısını ve dosya veya veritabanı bütünlüğünü doğrula.)*

### Acceptance Criterion (Kabul Kriteri)

The complete session must be stored without application crash, corrupted timestamps, or unacceptable sensor event loss caused by storage operations. *(Tam oturum, uygulama çökmesi, bozulmuş zaman damgaları veya depolama işlemlerinin neden olduğu kabul edilemez sensör olay kaybı olmadan saklanmalıdır.)*

**Actual Status:** TBD *(Gerçek Durum: TBD)*

---

# 35. Five-Minute Combined Load Audit — AUD-PERF-001 (Beş Dakikalık Birleşik Yük Denetimi — AUD-PERF-001)

A short integrated stress test will evaluate whether the device can handle multiple NAVGUARD workloads simultaneously. *(Kısa bir entegre stres testi, cihazın birden fazla NAVGUARD iş yükünü aynı anda yönetip yönetemediğini değerlendirecektir.)*

### Planned Active Components (Planlanan Aktif Bileşenler)

- **Accelerometer logging** *(İvmeölçer kaydı)*
- **Gyroscope logging** *(Jiroskop kaydı)*
- **Magnetometer logging** *(Manyetometre kaydı)*
- **GNSS logging** *(GNSS kaydı)*
- **Basic live charts or status UI** *(Temel canlı grafikler veya durum kullanıcı arayüzü)*
- **Representative TFLite inference** *(Temsili TFLite çıkarımı)*

ARCore may be added to a second version of this load test after its independent audit passes. *(ARCore, bağımsız denetimi geçtikten sonra bu yük testinin ikinci sürümüne eklenebilir.)*

### Acceptance Criterion (Kabul Kriteri)

The application must remain responsive and must not crash during the test. *(Uygulama test sırasında tepki verebilir kalmalı ve çökmemelidir.)*

**Actual Status:** TBD *(Gerçek Durum: TBD)*

---

# 36. ARCore Combined Load Audit — AUD-PERF-002 (ARCore Birleşik Yük Denetimi — AUD-PERF-002)

After ARCore passes its independent tests, a combined runtime test will activate ARCore together with sensor logging and representative AI inference. *(ARCore bağımsız testlerini geçtikten sonra birleşik bir çalışma zamanı testi ARCore’u sensör kaydı ve temsili yapay zekâ çıkarımıyla birlikte etkinleştirecektir.)*

### Acceptance Criterion (Kabul Kriteri)

ARCore tracking, sensor acquisition, and AI inference must operate together without sustained application instability. *(ARCore takibi, sensör veri toplama ve yapay zekâ çıkarımı sürekli uygulama kararsızlığı olmadan birlikte çalışmalıdır.)*

If performance becomes unacceptable, update frequencies or model complexity may be reduced before the architecture is frozen. *(Performans kabul edilemez hale gelirse mimari sabitlenmeden önce güncelleme frekansları veya model karmaşıklığı azaltılabilir.)*

**Actual Status:** TBD *(Gerçek Durum: TBD)*

---

# 37. Initial Battery Audit — AUD-BAT-001 (Başlangıç Batarya Denetimi — AUD-BAT-001)

Battery measurements in NAVGUARD will be interpreted relative to the current health of the physical device rather than the factory-rated capacity alone. *(NAVGUARD’daki batarya ölçümleri yalnızca fabrika nominal kapasitesi yerine fiziksel cihazın mevcut sağlığına göre yorumlanacaktır.)*

### Baseline Conditions to Record (Kaydedilecek Temel Koşullar)

- **Battery percentage** *(Batarya yüzdesi)*
- **Charging state** *(Şarj durumu)*
- **Battery temperature if available** *(Mevcutsa batarya sıcaklığı)*
- **Screen brightness setting** *(Ekran parlaklığı ayarı)*
- **Wi-Fi state** *(Wi-Fi durumu)*
- **Mobile data state** *(Mobil veri durumu)*
- **Location state** *(Konum durumu)*

### Initial Test (Başlangıç Testi)

Run a five-minute sensor-only NAVGUARD session. *(Beş dakikalık yalnızca sensör kullanan NAVGUARD oturumu çalıştır.)*

Record battery percentage and available battery statistics before and after the session. *(Oturumdan önce ve sonra batarya yüzdesini ve mevcut batarya istatistiklerini kaydet.)*

The result will serve as an initial reference rather than a final battery benchmark. *(Sonuç nihai batarya benchmark’ı yerine başlangıç referansı olarak kullanılacaktır.)*

**Actual Status:** TBD *(Gerçek Durum: TBD)*

---

# 38. Thermal Audit — AUD-THM-001 (Termal Denetim — AUD-THM-001)

The device will be observed for thermal behavior under sustained NAVGUARD workloads. *(Cihaz sürekli NAVGUARD iş yükleri altında termal davranış açısından gözlemlenecektir.)*

The initial audit will not require laboratory-grade temperature measurement. *(İlk denetim laboratuvar seviyesinde sıcaklık ölçümü gerektirmeyecektir.)*

Available Android battery temperature information and observable thermal throttling behavior may be recorded. *(Mevcut Android batarya sıcaklık bilgisi ve gözlemlenebilir termal kısıtlama davranışı kaydedilebilir.)*

### Acceptance Criterion (Kabul Kriteri)

Normal short test sessions must not cause application instability due to thermal conditions. *(Normal kısa test oturumları termal koşullar nedeniyle uygulama kararsızlığına neden olmamalıdır.)*

Longer thermal performance characterization will be performed later under the dedicated performance testing documentation. *(Daha uzun termal performans karakterizasyonu daha sonra özel performans test dokümantasyonu altında gerçekleştirilecektir.)*

**Actual Status:** TBD *(Gerçek Durum: TBD)*

---

# 39. Foreground Operation Audit — AUD-AND-001 (Ön Plan Çalışma Denetimi — AUD-AND-001)

NAVGUARD’s primary research sessions will operate while the navigation application is actively running in the foreground. *(NAVGUARD’ın temel araştırma oturumları navigasyon uygulaması aktif olarak ön planda çalışırken gerçekleştirilecektir.)*

This avoids relying on unrestricted background delivery of continuous sensor events. *(Bu, sürekli sensör olaylarının sınırsız arka plan teslimine bağımlı olmayı önler.)*

### Required Check (Gerekli Kontrol)

Verify that all mandatory sensor streams continue normally during the active navigation screen. *(Tüm zorunlu sensör akışlarının aktif navigasyon ekranı sırasında normal şekilde devam ettiğini doğrula.)*

### Optional Check (İsteğe Bağlı Kontrol)

Verify the behavior when the application temporarily loses foreground focus. *(Uygulama geçici olarak ön plan odağını kaybettiğinde davranışı doğrula.)*

**Actual Status:** TBD *(Gerçek Durum: TBD)*

---

# 40. Permission Audit — AUD-PERM-001 (İzin Denetimi — AUD-PERM-001)

### English

NAVGUARD must identify and test every runtime permission required by the selected Android configuration.

#### Planned Permission Categories

| Permission Area | Required Use | Result |
| --- | --- | --- |
| Precise Location | GNSS initialization and ground truth | VERIFIED — STAGE 2C DIAGNOSTIC SCOPE |
| Camera | ARCore tracking | VERIFIED — STAGE 2D DIAGNOSTIC SCOPE |
| Local File / Media Access if Required | Session export | TBD |
| High Sampling Rate Sensors | Not expected to be required | TBD |

Stage 2C added exactly `ACCESS_COARSE_LOCATION` and `ACCESS_FINE_LOCATION`. Both permissions were requested together through the native foreground permission flow. The pre-permission state was not granted and not formal-ready; after the user selected precise location, coarse and fine states were granted and the preflight became formal-ready. Approximate-only access is not treated as sufficient for the formal GNSS diagnostic. No `ACCESS_BACKGROUND_LOCATION` permission or location foreground service was added.

Stage 2D added `android.permission.CAMERA` for the ARCore diagnostic. The camera-permission path was physically verified, preflight reported permission granted, and all three formal ARCore sessions ran without a permission-related terminal error. No microphone, storage, background-location, or unrelated runtime permission was added.

#### Acceptance Criterion

The application must handle granted and denied permission states without crashing. The user must receive a clear explanation when a required permission prevents a selected navigation configuration from running.

**Actual Status:** PARTIAL — Foreground location permission and precise-versus-approximate readiness are verified for the Stage 2C GNSS diagnostic, and camera permission is verified for the Stage 2D ARCore diagnostic. Later configuration-specific permission audits remain pending.

### Türkçe

NAVGUARD, seçilen Android yapılandırması tarafından gerekli her çalışma zamanı iznini belirlemeli ve test etmelidir.

#### Planlanan İzin Kategorileri

| İzin Alanı | Gerekli Kullanım | Sonuç |
| --- | --- | --- |
| Hassas Konum | GNSS başlatma ve gerçek referans | DOĞRULANDI — STAGE 2C TANI KAPSAMI |
| Kamera | ARCore takibi | DOĞRULANDI — STAGE 2D TANI KAPSAMI |
| Gerekirse Yerel Dosya / Medya Erişimi | Oturum dışa aktarma | TBD |
| Yüksek Örnekleme Hızlı Sensörler | Gerekmesi beklenmiyor | TBD |

Stage 2C tam olarak `ACCESS_COARSE_LOCATION` ve `ACCESS_FINE_LOCATION` izinlerini ekledi. Her iki izin native ön plan izin akışında birlikte talep edildi. İzin öncesi durum not-granted ve resmî tanı için hazır değilken kullanıcı hassas konumu seçtikten sonra coarse ve fine durumları granted oldu ve preflight resmî tanı için hazır duruma geçti. Yalnızca yaklaşık konum erişimi resmî GNSS tanısı için yeterli kabul edilmez. `ACCESS_BACKGROUND_LOCATION` izni veya konum foreground service'i eklenmedi.

Stage 2D, ARCore tanısı için `android.permission.CAMERA` ekledi. Kamera izin yolu fiziksel olarak doğrulandı, preflight iznin verildiğini bildirdi ve üç resmî ARCore oturumunun tamamı izinle ilişkili terminal hatası olmadan çalıştı. Mikrofon, depolama, arka plan konum veya ilgisiz çalışma zamanı izni eklenmedi.

#### Kabul Kriteri

Uygulama izin verilmiş ve reddedilmiş durumları çökmeden yönetmelidir. Zorunlu bir izin seçilen navigasyon yapılandırmasının çalışmasını engellediğinde kullanıcı açık bir açıklama almalıdır.

**Gerçek Durum:** KISMİ — Ön plan konum izni ve hassas-yaklaşık konum hazır olma ayrımı Stage 2C GNSS tanısı için, kamera izni ise Stage 2D ARCore tanısı için doğrulandı. Daha sonraki yapılandırmalara özgü izin denetimleri beklemektedir.

---

# 41. Offline Runtime Audit — AUD-OFF-001 (Çevrimdışı Çalışma Denetimi — AUD-OFF-001)

The core NAVGUARD runtime must be tested with Wi-Fi and mobile data disabled. *(Temel NAVGUARD çalışma zamanı Wi-Fi ve mobil veri kapalıyken test edilmelidir.)*

The objective is to prove that the primary navigation, sensor processing, local AI inference, and session recording components do not depend on a cloud service. *(Amaç temel navigasyon, sensör işleme, yerel yapay zekâ çıkarımı ve oturum kayıt bileşenlerinin bir bulut hizmetine bağımlı olmadığını kanıtlamaktır.)*

### Required Functions During Offline Test (Çevrimdışı Test Sırasında Gerekli İşlevler)

- **Sensor acquisition** *(Sensör veri toplama)*
- **Motion model inference** *(Hareket modeli çıkarımı)*
- **PDR calculations** *(PDR hesaplamaları)*
- **Local session logging** *(Yerel oturum kaydı)*
- **Navigation state management** *(Navigasyon durum yönetimi)*

Map imagery may be treated separately if online map tiles have not yet been replaced by an offline mapping solution. *(Çevrimiçi harita tile’ları henüz çevrimdışı bir harita çözümüyle değiştirilmemişse harita görüntüleri ayrı olarak ele alınabilir.)*

### Acceptance Criterion (Kabul Kriteri)

The core estimator must remain operational without internet connectivity. *(Temel tahmin motoru internet bağlantısı olmadan çalışır durumda kalmalıdır.)*

**Actual Status:** TBD *(Gerçek Durum: TBD)*

---

# 42. Five-Minute Data Integrity Audit — AUD-DATA-001 (Beş Dakikalık Veri Bütünlüğü Denetimi — AUD-DATA-001)

A complete five-minute mixed-motion session will be recorded. *(Tam bir beş dakikalık karma hareket oturumu kaydedilecektir.)*

The session should include stationary periods, normal walking, turns, and stops. *(Oturum sabit durma sürelerini, normal yürüyüşü, dönüşleri ve duruşları içermelidir.)*

### Integrity Checks (Bütünlük Kontrolleri)

- **Every record contains a valid timestamp** *(Her kayıt geçerli bir zaman damgası içeriyor)*
- **Sensor streams remain distinguishable by source** *(Sensör akışları kaynağa göre ayırt edilebilir kalıyor)*
- **No invalid numeric values appear unexpectedly** *(Beklenmedik geçersiz sayısal değerler oluşmuyor)*
- **Session start and end timestamps are present** *(Oturum başlangıç ve bitiş zaman damgaları mevcut)*
- **GNSS and estimator channels remain logically separate** *(GNSS ve tahmin motoru kanalları mantıksal olarak ayrı kalıyor)*
- **Exported data can be parsed successfully by Python** *(Dışa aktarılan veri Python tarafından başarıyla ayrıştırılabiliyor)*

### Acceptance Criterion (Kabul Kriteri)

The resulting session must be suitable for offline analysis without manual repair of the dataset. *(Ortaya çıkan oturum veri setinin manuel olarak onarılması gerekmeksizin çevrimdışı analiz için uygun olmalıdır.)*

**Actual Status:** TBD *(Gerçek Durum: TBD)*

---

# 43. Clock Alignment Audit — AUD-TIME-002 (Saat Hizalama Denetimi — AUD-TIME-002)

### English

NAVGUARD must define how sensor timestamps, GNSS timestamps, ARCore timestamps, and application event timestamps are represented and aligned. The audit must identify whether each source uses a monotonic elapsed-time reference, wall-clock time, or another timestamp basis. A documented conversion or synchronization strategy must exist before multi-source fusion begins.

Stage 2B established `SensorEvent.timestamp` as the sensor timing authority for its tested scope. Stage 2C established `Location.elapsedRealtimeNanos` in the `elapsed_realtime_nanoseconds` domain as the GNSS diagnostic timing authority and physically characterized monotonic sequences in 3/3 sessions. Stage 2C did not use `Location.time`, wall-clock time, or callback arrival time for interval or rate calculations. Stage 2D used ARCore `Frame.timestamp` as its frame-timing authority and observed monotonic sequences in 3/3 sessions, but the Stage 2D diagnostic does not define its time base or a conversion to the sensor/GNSS domains.

#### Acceptance Criterion

Measurements from different sources must be alignable onto a common experiment timeline.

**Criticality:** CRITICAL

**Actual Status:** PARTIAL — Sensor, GNSS, and ARCore monotonic timestamp sources are physically observed for their tested scopes. The ARCore time base, application-event domain, and documented multi-source conversion/alignment strategy remain pending; fusion is not implemented.

### Türkçe

NAVGUARD; sensör zaman damgalarının, GNSS zaman damgalarının, ARCore zaman damgalarının ve uygulama olay zaman damgalarının nasıl temsil edilip hizalanacağını tanımlamalıdır. Denetim her kaynağın monotonik geçen zaman referansı, duvar saati zamanı veya başka bir zaman damgası temeli kullanıp kullanmadığını belirlemelidir. Çok kaynaklı füzyon başlamadan önce dokümante edilmiş bir dönüşüm veya senkronizasyon stratejisi mevcut olmalıdır.

Stage 2B, test edilen kapsamı için `SensorEvent.timestamp` değerini sensör zamanlama otoritesi olarak belirledi. Stage 2C, `elapsed_realtime_nanoseconds` alanındaki `Location.elapsedRealtimeNanos` değerini GNSS tanı zamanlama otoritesi olarak belirledi ve 3/3 oturumda monotonik dizileri fiziksel olarak karakterize etti. Stage 2C aralık veya hız hesaplamalarında `Location.time`, duvar saati ya da callback varış zamanını kullanmadı. Stage 2D, kare zamanlama otoritesi olarak ARCore `Frame.timestamp` kullandı ve 3/3 oturumda monotonik diziler gözledi; ancak Stage 2D tanısı bu zaman damgasının zaman tabanını veya sensör/GNSS alanlarına dönüşümünü tanımlamaz.

#### Kabul Kriteri

Farklı kaynaklardan gelen ölçümler ortak bir deney zaman çizelgesine hizalanabilir olmalıdır.

**Kritiklik:** KRİTİK

**Gerçek Durum:** KISMİ — Sensör, GNSS ve ARCore monotonik zaman damgası kaynakları tanımlı kapsamlarında fiziksel olarak gözlenmiştir. ARCore zaman tabanı, uygulama olayı alanı ve dokümante edilmiş çok-kaynaklı dönüşüm/hizalama stratejisi beklemektedir; füzyon uygulanmamıştır.

---

# 44. Developer Diagnostic Screen Requirement (Geliştirici Tanı Ekranı Gereksinimi)

NAVGUARD should include a diagnostic screen that exposes critical device and sensor information during development. *(NAVGUARD geliştirme sırasında kritik cihaz ve sensör bilgilerini gösteren bir tanı ekranı içermelidir.)*

The screen is intended for engineering validation rather than normal end-user navigation. *(Ekran normal son kullanıcı navigasyonu yerine mühendislik doğrulaması için tasarlanmıştır.)*

### Recommended Diagnostic Information (Önerilen Tanı Bilgileri)

- **Device model and Android version** *(Cihaz modeli ve Android sürümü)*
- **Available sensor list** *(Kullanılabilir sensör listesi)*
- **Sensor vendors** *(Sensör üreticileri)*
- **Current accelerometer values** *(Mevcut ivmeölçer değerleri)*
- **Current gyroscope values** *(Mevcut jiroskop değerleri)*
- **Current magnetometer values** *(Mevcut manyetometre değerleri)*
- **Measured sampling rates** *(Ölçülen örnekleme hızları)*
- **Rotation vector availability** *(Rotation vector kullanılabilirliği)*
- **GNSS status** *(GNSS durumu)*
- **ARCore status** *(ARCore durumu)*
- **TFLite runtime status** *(TFLite çalışma zamanı durumu)*
- **Session logging status** *(Oturum kayıt durumu)*

This screen may later become part of a permanent Research or Developer Mode. *(Bu ekran daha sonra kalıcı bir Araştırma veya Geliştirici Modunun parçası olabilir.)*

### Stage 2D Evidence — English

The Flutter runtime-diagnostics screen preserves the Stage 2A sensor inventory, Stage 2B sensor timing, Stage 2C GNSS, Stage 2D ARCore, and Stage 3A anchor controls. Stage 3B adds heading preflight, a formal 30-second heading diagnostic, explicit cancellation, and sanitized heading/timing/declination aggregates. The heading action requires both rotation-vector availability and a locked anchor; the shared busy state prevents simultaneous UI-triggered diagnostics. Raw anchor coordinates and raw rotation-vector streams are not displayed or included in sanitized formal logs.

**Actual Status:** PARTIAL — Sensor inventory, sensor timing, GNSS timing, ARCore tracking, GNSS anchor, and handset-heading diagnostic UI scopes are implemented. TFLite, storage, and other recommended diagnostic areas remain pending.

### Stage 3B Kanıtı — Türkçe

Flutter çalışma zamanı tanı ekranı Stage 2A sensör envanteri, Stage 2B sensör zamanlaması, Stage 2C GNSS, Stage 2D ARCore ve Stage 3A anchor kontrollerini korur. Stage 3B heading preflight, resmî 30 saniyelik heading tanısı, açık iptal ve sanitize edilmiş heading/zamanlama/declination birleşik değerlerini ekler. Heading eylemi hem rotation-vector kullanılabilirliğini hem kilitli anchor'ı gerektirir; ortak busy durumu aynı anda birden fazla UI tetiklemeli tanıyı engeller. Ham anchor koordinatları ve ham rotation-vector akışları görüntülenmez veya sanitize edilmiş resmî loglara dahil edilmez.

**Gerçek Durum:** KISMİ — Sensör envanteri, sensör zamanlaması, GNSS zamanlaması, ARCore takip, GNSS anchor ve handset-heading tanı kullanıcı arayüzü kapsamları uygulanmıştır. TFLite, depolama ve önerilen diğer tanı alanları beklemektedir.

---

# 45. Automatic Audit Report Requirement (Otomatik Denetim Raporu Gereksinimi)

Where practical, NAVGUARD should export the Device Capability Audit results into a machine-readable file. *(Uygulanabilir olduğu ölçüde NAVGUARD Cihaz Yetenek Denetimi sonuçlarını makine tarafından okunabilir bir dosyaya dışa aktarmalıdır.)*

JSON is the preferred initial format for structured device capability metadata. *(JSON, yapılandırılmış cihaz yetenek metadata bilgisi için tercih edilen başlangıç formatıdır.)*

### Example Logical Structure (Örnek Mantıksal Yapı)

```
device
android
sensors
    accelerometer
    gyroscope
    magnetometer
    rotation_vector
gnss
arcore
tensorflow_lite
storage
performance
audit_results
```

The exported report must include the application version and audit timestamp. *(Dışa aktarılan rapor uygulama sürümünü ve denetim zaman damgasını içermelidir.)*

---

# 46. Audit Evidence Requirements (Denetim Kanıtı Gereksinimleri)

Each critical audit result should have objective evidence rather than only a handwritten PASS status. *(Her kritik denetim sonucu yalnızca elle yazılmış bir PASS durumu yerine nesnel kanıta sahip olmalıdır.)*

Evidence may include exported JSON, CSV sensor recordings, screenshots, console logs, generated statistics, or recorded test-session files. *(Kanıt; dışa aktarılan JSON, CSV sensör kayıtları, ekran görüntüleri, konsol logları, oluşturulan istatistikler veya kaydedilmiş test oturumu dosyalarını içerebilir.)*

The evidence filename or location should be linked to the corresponding audit item. *(Kanıt dosya adı veya konumu ilgili denetim öğesiyle ilişkilendirilmelidir.)*

---

# 47. Critical Audit Matrix (Kritik Denetim Matrisi)

| Audit ID (Denetim Kimliği) | Capability (Yetenek) | Criticality (Kritiklik) | Status (Durum) |
| --- | --- | --- | --- |
| AUD-DEV-001 | Device Identity *(Cihaz Kimliği)* | HIGH *(YÜKSEK)* | TBD |
| AUD-SEN-001 | Sensor Enumeration *(Sensör Listeleme)* | CRITICAL *(KRİTİK)* | TBD |
| AUD-SEN-002 | Required Sensor Availability *(Zorunlu Sensör Kullanılabilirliği)* | CRITICAL *(KRİTİK)* | TBD |
| AUD-TIME-001 | Sensor Timestamp Quality *(Sensör Zaman Damgası Kalitesi)* | CRITICAL *(KRİTİK)* | TBD |
| AUD-RATE-001 | Effective Sampling Rate *(Etkin Örnekleme Hızı)* | CRITICAL *(KRİTİK)* | TBD |
| AUD-ACC-002 | Accelerometer Stability *(İvmeölçer Kararlılığı)* | CRITICAL *(KRİTİK)* | TBD |
| AUD-GYR-002 | Gyroscope Stability *(Jiroskop Kararlılığı)* | CRITICAL *(KRİTİK)* | TBD |
| AUD-MAG-002 | Magnetometer Usability *(Manyetometre Kullanılabilirliği)* | HIGH *(YÜKSEK)* | TBD |
| AUD-GNSS-001 | GNSS Availability *(GNSS Kullanılabilirliği)* | CRITICAL *(KRİTİK)* | PARTIAL — STAGE 2C TIMING SCOPE |
| AUD-GNSS-003 | Ground Truth Isolation *(Gerçek Referans İzolasyonu)* | CRITICAL *(KRİTİK)* | TBD |
| AUD-AR-001 | ARCore Startup *(ARCore Başlatma)* | HIGH *(YÜKSEK)* | VERIFIED — STAGE 2D DIAGNOSTIC SCOPE |
| AUD-AR-002 | ARCore Relative Pose *(ARCore Göreli Poz)* | HIGH *(YÜKSEK)* | VERIFIED — STAGE 2D DIAGNOSTIC SCOPE; ACCURACY NOT VALIDATED |
| AUD-AR-003 | ARCore Stationary Drift *(ARCore Sabit Durum Sürüklenmesi)* | HIGH *(YÜKSEK)* | PARTIAL — OBSERVATION ONLY; FORMAL BENCHMARK PENDING |
| AUD-AR-004 | ARCore Tracking Degradation *(ARCore Takip Bozulması)* | HIGH *(YÜKSEK)* | TBD — DEGRADATION PROCEDURE NOT EXECUTED |
| AUD-AI-001 | Local TFLite Runtime *(Yerel TFLite Çalışma Zamanı)* | HIGH *(YÜKSEK)* | TBD |
| AUD-STO-001 | Continuous Logging *(Sürekli Kayıt)* | CRITICAL *(KRİTİK)* | TBD |
| AUD-TIME-002 | Multi-Source Clock Alignment *(Çok Kaynaklı Saat Hizalama)* | CRITICAL *(KRİTİK)* | PARTIAL — SENSOR/GNSS/ARCORE SOURCES OBSERVED; ALIGNMENT PENDING |
| AUD-OFF-001 | Offline Core Runtime *(Çevrimdışı Temel Çalışma)* | HIGH *(YÜKSEK)* | TBD |

---

# 48. Minimum Architecture Gate — GATE-MIN (Minimum Mimari Kapısı — GATE-MIN)

The minimum NAVGUARD architecture may proceed only if all critical baseline capabilities pass or receive an approved PASS WITH LIMITATION result. *(Minimum NAVGUARD mimarisi yalnızca tüm kritik temel yetenekler PASS veya onaylanmış PASS WITH LIMITATION sonucu alırsa ilerleyebilir.)*

### Required Minimum Conditions (Gerekli Minimum Koşullar)

- **Accelerometer available and stable** *(İvmeölçer mevcut ve kararlı)*
- **Gyroscope available and stable** *(Jiroskop mevcut ve kararlı)*
- **Usable heading source available** *(Kullanılabilir yön kaynağı mevcut)*
- **GNSS initialization available** *(GNSS başlatma kullanılabilir)*
- **Sensor timestamps usable** *(Sensör zaman damgaları kullanılabilir)*
- **Continuous sensor logging stable** *(Sürekli sensör kaydı kararlı)*
- **Ground-truth GNSS isolation feasible** *(Gerçek referans GNSS izolasyonu uygulanabilir)*

### Gate Result (Kapı Sonucu)

**GATE-MIN:** TBD

---

# 49. Target Architecture Gate — GATE-TGT (Hedef Mimari Kapısı — GATE-TGT)

The target NAVGUARD architecture may proceed if the minimum gate passes and the advanced components required by the target configuration are also validated. *(Hedef NAVGUARD mimarisi, minimum kapı geçerse ve hedef yapılandırma tarafından gerekli gelişmiş bileşenler de doğrulanırsa ilerleyebilir.)*

### Additional Target Conditions (Ek Hedef Koşullar)

- **ARCore session initializes successfully** *(ARCore oturumu başarıyla başlıyor)*
- **ARCore relative pose is usable** *(ARCore göreli pozu kullanılabilir)*
- **ARCore tracking degradation is detectable** *(ARCore takip bozulması tespit edilebilir)*
- **TensorFlow Lite local inference works** *(TensorFlow Lite yerel çıkarımı çalışıyor)*
- **Combined runtime remains stable** *(Birleşik çalışma zamanı kararlı kalıyor)*

### Gate Result (Kapı Sonucu)

**GATE-TGT:** TBD

---

# 50. Fallback Decisions (Geri Dönüş Kararları)

If the rotation vector is unavailable, orientation estimation will be built directly from the available accelerometer, gyroscope, and magnetometer measurements. *(Rotation vector kullanılamazsa yönelim tahmini mevcut ivmeölçer, jiroskop ve manyetometre ölçümlerinden doğrudan oluşturulacaktır.)*

If the linear acceleration sensor is unavailable, NAVGUARD will calculate suitable gravity-compensated motion information using its own preprocessing pipeline. *(Doğrusal ivme sensörü kullanılamazsa NAVGUARD kendi ön işleme hattını kullanarak uygun yerçekimi telafili hareket bilgisini hesaplayacaktır.)*

If the native Android step detector is unavailable, no architecture change is required because NAVGUARD will implement its own step detection subsystem. *(Native Android adım algılayıcı kullanılamazsa NAVGUARD kendi adım tespit alt sistemini geliştireceği için herhangi bir mimari değişiklik gerekli değildir.)*

If raw GNSS measurements are unavailable, the minimum and target NAVGUARD configurations will continue without them. *(Ham GNSS ölçümleri kullanılamazsa minimum ve hedef NAVGUARD yapılandırmaları bunlar olmadan devam edecektir.)*

If ARCore cannot provide sufficiently stable tracking, the project will continue with PDR, heading fusion, AI-assisted motion estimation, and other validated components. *(ARCore yeterince kararlı takip sağlayamazsa proje PDR, yön füzyonu, yapay zekâ destekli hareket tahmini ve diğer doğrulanmış bileşenlerle devam edecektir.)*

If the selected neural model is too slow on the physical device, a smaller 1D-CNN, MLP, Random Forest, or another validated lightweight model may be selected. *(Seçilen sinir ağı modeli fiziksel cihaz üzerinde çok yavaşsa daha küçük bir 1D-CNN, MLP, Random Forest veya doğrulanmış başka bir hafif model seçilebilir.)*

---

# 51. Audit Failure Policy (Denetim Başarısızlık Politikası)

A failed audit item must not be hidden or silently ignored. *(Başarısız bir denetim öğesi gizlenmemeli veya sessizce göz ardı edilmemelidir.)*

The failure must be recorded together with its observed behavior, suspected cause, and effect on the project architecture. *(Başarısızlık gözlemlenen davranışı, şüphelenilen nedeni ve proje mimarisi üzerindeki etkisiyle birlikte kaydedilmelidir.)*

If a workaround is implemented, the audit item must be repeated after the change. *(Bir geçici çözüm uygulanırsa değişiklikten sonra denetim öğesi tekrar edilmelidir.)*

The final accepted behavior must be recorded in the Technical Decisions and Change Log when it changes the planned architecture. *(Planlanan mimariyi değiştirdiğinde nihai kabul edilen davranış Teknik Kararlar ve Değişiklik Günlüğünde kaydedilmelidir.)*

---

# 52. Audit Repetition Conditions (Denetimi Tekrarlama Koşulları)

The full or partial Device Capability Audit must be repeated after any operating-system change that may affect sensor or ARCore behavior. *(Sensör veya ARCore davranışını etkileyebilecek herhangi bir işletim sistemi değişikliğinden sonra Cihaz Yetenek Denetiminin tamamı veya ilgili kısmı tekrarlanmalıdır.)*

The relevant audit must be repeated after major changes to the Android sensor integration layer. *(Android sensör entegrasyon katmanındaki büyük değişikliklerden sonra ilgili denetim tekrarlanmalıdır.)*

The relevant audit must be repeated after changing the primary physical test device. *(Birincil fiziksel test cihazı değiştirildikten sonra ilgili denetim tekrarlanmalıdır.)*

Performance-related audits should be repeated after major changes to the AI model or ARCore runtime architecture. *(Yapay zekâ modeli veya ARCore çalışma zamanı mimarisindeki büyük değişikliklerden sonra performansla ilişkili denetimler tekrarlanmalıdır.)*

---

# 53. Audit Output Files (Denetim Çıktı Dosyaları)

The following output files are planned for the completed audit. *(Tamamlanmış denetim için aşağıdaki çıktı dosyaları planlanmaktadır.)*

```
device_capability_report.json
sensor_inventory.json
sensor_sampling_report.csv
stationary_accelerometer.csv
stationary_gyroscope.csv
magnetometer_baseline.csv
short_motion_test.csv
gnss_baseline.csv
arcore_stationary_pose.csv
arcore_motion_pose.csv
tflite_latency_report.csv
device_audit_summary.md
```

File names may change during implementation, but the information represented by these outputs must remain available. *(Dosya adları geliştirme sırasında değişebilir ancak bu çıktıların temsil ettiği bilgiler kullanılabilir kalmalıdır.)*

---

# 54. Audit Completion Checklist (Denetim Tamamlama Kontrol Listesi)

- [ ]  **Device identity recorded.** *(Cihaz kimliği kaydedildi.)*
- [ ]  **Android version and API level recorded.** *(Android sürümü ve API seviyesi kaydedildi.)*
- [ ]  **Complete Android sensor inventory exported.** *(Tam Android sensör envanteri dışa aktarıldı.)*
- [ ]  **Accelerometer metadata recorded.** *(İvmeölçer metadata bilgisi kaydedildi.)*
- [ ]  **Gyroscope metadata recorded.** *(Jiroskop metadata bilgisi kaydedildi.)*
- [ ]  **Magnetometer metadata recorded.** *(Manyetometre metadata bilgisi kaydedildi.)*
- [ ]  **Virtual sensor availability recorded.** *(Sanal sensör kullanılabilirliği kaydedildi.)*
- [ ]  **Effective accelerometer rate measured.** *(Etkin ivmeölçer hızı ölçüldü.)*
- [ ]  **Effective gyroscope rate measured.** *(Etkin jiroskop hızı ölçüldü.)*
- [ ]  **Effective magnetometer rate measured.** *(Etkin manyetometre hızı ölçüldü.)*
- [ ]  **Stationary accelerometer test completed.** *(Sabit ivmeölçer testi tamamlandı.)*
- [ ]  **Stationary gyroscope test completed.** *(Sabit jiroskop testi tamamlandı.)*
- [ ]  **Magnetometer stability test completed.** *(Manyetometre kararlılık testi tamamlandı.)*
- [ ]  **Manual rotation test completed.** *(Manuel dönüş testi tamamlandı.)*
- [ ]  **Short walking sensor test completed.** *(Kısa yürüyüş sensör testi tamamlandı.)*
- [x]  **Native `TYPE_STEP_DETECTOR` foundation verified for the Stage 3C diagnostic scope.** *(Native `TYPE_STEP_DETECTOR` temeli Stage 3C tanı kapsamı için doğrulandı.)*
- [x]  **Deterministic Baseline PDR verified for the Stage 4 diagnostic scope.** *(Deterministik Temel PDR, Stage 4 tanı kapsamı için doğrulandı.)*
- [ ]  **GNSS outdoor test completed.** *(GNSS dış mekân testi tamamlandı.)*
- [x]  **GNSS ground-truth isolation verified for the Stage 6 Evaluation Mode scope.** *(GNSS gerçek referans izolasyonu Stage 6 Değerlendirme Modu kapsamı için doğrulandı.)*
- [x]  **ARCore installation verified for the Stage 2D diagnostic scope.** *(ARCore kurulumu Stage 2D tanı kapsamı için doğrulandı.)*
- [x]  **ARCore local-session pose tracking verified for the Stage 2D diagnostic scope.** *(ARCore yerel-oturum poz takibi Stage 2D tanı kapsamı için doğrulandı.)*
- [x]  **ARCore-to-ENU stationary displacement recorded for the Stage 5 diagnostic scope.** *(ARCore-to-ENU sabit-durum yer değiştirmesi Stage 5 tanı kapsamı için kaydedildi.)*
- [x]  **ARCore relative motion → local ENU foundation verified for the Stage 5 diagnostic scope.** *(ARCore göreli hareket → yerel ENU temeli Stage 5 tanı kapsamı için doğrulandı.)*
- [ ]  **ARCore degradation handling verified.** *(ARCore bozulma yönetimi doğrulandı.)*
- [ ]  **TensorFlow Lite test inference completed.** *(TensorFlow Lite test çıkarımı tamamlandı.)*
- [ ]  **Local storage logging test completed.** *(Yerel depolama kayıt testi tamamlandı.)*
- [ ]  **Offline runtime test completed.** *(Çevrimdışı çalışma testi tamamlandı.)*
- [ ]  **Clock alignment strategy verified.** *(Saat hizalama stratejisi doğrulandı.)*
- [ ]  **Minimum architecture gate evaluated.** *(Minimum mimari kapısı değerlendirildi.)*
- [ ]  **Target architecture gate evaluated.** *(Hedef mimari kapısı değerlendirildi.)*
- [ ]  **Final device baseline frozen.** *(Nihai cihaz temel referansı sabitlendi.)*

**Stage 4 boundary:** Stage 2A sensor inventory, Stage 2B four-sensor timing, Stage 2C GNSS runtime timing, Stage 2D ARCore runtime tracking, Stage 3A pre-denial GNSS-anchor flow, Stage 3B handset-heading / true-north-correction foundation, Stage 3C step-event foundation, and Stage 4 deterministic baseline PDR are verified for their defined scopes, but they do not complete this checklist. PDR accuracy, step-detection accuracy, step-length accuracy, heading and true-north absolute accuracy, GNSS absolute coordinate and physical ENU accuracy, reference-trajectory recording, GNSS ground-truth isolation, formal ARCore stationary-drift and degradation procedures, ARCore accuracy and coordinate alignment, ARCore-to-ENU, full sensor-audit procedures, the multi-source clock-alignment strategy, and other required device/runtime checks remain pending or unimplemented as applicable.

**Stage 4 sınırı:** Stage 2A sensör envanteri, Stage 2B dört sensörlü zamanlama, Stage 2C GNSS çalışma zamanı zamanlaması, Stage 2D ARCore çalışma zamanı takibi, Stage 3A kesinti-öncesi GNSS anchor akışı, Stage 3B handset-heading / gerçek-kuzey-düzeltme temeli, Stage 3C adım-olayı temeli ve Stage 4 deterministik temel PDR tanımlı kapsamlarında doğrulanmıştır ancak bu kontrol listesini tamamlamaz. PDR doğruluğu, adım-algılama doğruluğu, adım-uzunluğu doğruluğu, heading ve gerçek-kuzey mutlak doğruluğu, GNSS mutlak koordinat ve fiziksel ENU doğruluğu, referans rota kaydı, GNSS gerçek referans izolasyonu, resmî ARCore sabit-durum sürüklenme ve bozulma prosedürleri, ARCore doğruluk ve koordinat hizalaması, ARCore-to-ENU, tam sensör denetimi prosedürleri, çok-kaynaklı saat hizalama stratejisi ve diğer gerekli cihaz/çalışma zamanı kontrolleri duruma göre beklemekte veya uygulanmamış durumdadır.

---

# 55. Final Audit Summary Table (Nihai Denetim Özet Tablosu)

### English

| Area | Result | Notes |
| --- | --- | --- |
| Device Environment | PARTIAL | Stages 2B–2D and Stages 3A–8 tested on Xiaomi Redmi Note 9 Pro, Android 12 / API 31; full environment audit pending. |
| Static Sensor Availability | VERIFIED — STAGE 2A SCOPE | Runtime default-sensor availability and metadata verified; this is not sensor-performance evidence. |
| Accelerometer | PARTIAL | Stage 2B live delivery/timing verified; signal quality, noise, bias, and calibration pending. |
| Gyroscope | PARTIAL | Stage 2B live delivery/timing verified; signal quality, noise, bias, and calibration pending. |
| Magnetometer | PARTIAL | Stage 2B live delivery/timing verified; signal quality, noise, bias, and calibration pending. |
| Rotation Vector | VERIFIED — STAGE 3B RUNTIME SCOPE | Available and formally exercised in 3/3 heading sessions at approximately 51.14 Hz observed delivery; absolute heading accuracy not validated. |
| Live Sensor Event Delivery | VERIFIED — STAGE 2B SCOPE | Four selected sensors; 12/12 timing sessions completed with valid summaries. |
| Sensor Timing | PARTIAL | 12/12 tested timestamp sequences were monotonic; 0/12 sessions had a gap above the provisional 60 ms threshold. Full AUD-TIME-001 pending. |
| Sensor Sampling | PARTIAL | Requested 20,000 µs (~50 Hz nominal) versus timestamp-derived observed rates characterized for the tested configuration; full multi-rate audit pending. |
| Sensor Signal Quality / Noise | NOT VERIFIED | Stage 2B was a timing characterization test only. |
| GNSS Foreground Permission / Preflight | VERIFIED — STAGE 2C SCOPE | Precise foreground permission and formal-ready preflight transition physically verified; only coarse and fine foreground permissions added. |
| GNSS Runtime Timing | VERIFIED — STAGE 2C SCOPE | 3/3 formal sessions valid, monotonic, and mock-free; median/p95 1.000 s in all sessions, observed mean rate ~0.983–1.000 Hz, and one 2.000 s interval. No GNSS gap threshold is defined. |
| GNSS Coordinate Accuracy | NOT VALIDATED | Android-reported horizontal-accuracy metadata was observed, but coordinate error or GNSS accuracy was not measured. |
| GNSS Anchor | VERIFIED — STAGE 3A SCOPE | 3/3 foreground pre-denial `GPS_PROVIDER` acquisitions succeeded; candidate counts 10 / 11 / 10; clear/reacquire and cancellation verified. |
| WGS84 / Local ENU Foundation | IMPLEMENTED — STAGE 3A SCOPE | WGS84 → ECEF → local ENU unit-tested; horizontal ENU avoids fabricated Up; physical ENU accuracy not validated. |
| GNSS Denial Controller / Ground Truth Firewall | IMPLEMENTED — STAGE 8 FULL-FLOW SCOPE | Software-defined estimator denial, denied-GNSS quarantine, protected-GT isolation, and fresh-fix recovery were physically verified; RF interference and spoofing were not used. |
| Ground Truth Isolation | VERIFIED — STAGE 6 SCOPE | Physical GNSS remained active for protected evaluation only and unavailable to the Config A estimator API; raw coordinates and trajectories were not returned or persisted. |
| Evaluation Mode | VERIFIED — STAGE 6 CONFIG A SCOPE | Stationary and post-fix moving sessions completed with 30/30 protected-GT matches; evaluation/firewall flow verified, accuracy not validated. |
| Raw GNSS | NOT VERIFIED | Stage 2C used sanitized `GnssStatus` counts only; NMEA and raw GNSS measurements were not used or verified. |
| ARCore Runtime Tracking | VERIFIED — STAGE 2D SCOPE | 3/3 sessions valid with real `TRACKING`, local-session pose, monotonic `Frame.timestamp`, no terminal errors, and no `STOPPED` frames; observed unique-frame rate ~30.0295–30.0304 Hz and tracking fraction ~98.15%–98.36%. |
| ARCore Pose Accuracy / Coordinates | NOT VALIDATED | Stage 5 implemented segment-relative local ENU, but position, distance, vertical, drift, scale, rotation, alignment, and absolute accuracy remain unvalidated. |
| ARCore-to-ENU Transform | VERIFIED — STAGE 5 RUNTIME SCOPE | `Frame.getAndroidSensorPose()`, local ARCore anchor inverse-compose, initial-device true-ENU alignment, qualitative axis/sign checks, and cancellation were physically exercised. |
| ARCore Degradation Handling | PARTIAL — STAGE 7 ATTEMPT | Deliberate degradation was attempted, but tracking remained active; fallback logic is statically tested and physical tracking-loss fallback is not validated. |
| Camera | VERIFIED — STAGE 2D SCOPE | Permission, GL/EGL initialization, camera-texture setup, and ARCore camera runtime passed in 3/3 diagnostic sessions. |
| TensorFlow Lite | TBD | TBD |
| Local Storage | TBD | TBD |
| Offline Runtime | TBD | TBD |
| Performance | NOT VERIFIED | Startup warnings remain a separate future application-performance QA item. |
| Battery | TBD | TBD |
| Thermal Behavior | TBD | TBD |
| PDR | IMPLEMENTED — STAGE 4 BASELINE SCOPE | Deterministic fixed-0.75 m horizontal baseline PDR and causal heading-step association are implemented; accuracy is not validated. |
| Handset Heading / True-North Foundation | VERIFIED — STAGE 3B RUNTIME SCOPE | Device +Y/top-edge, clockwise-positive, circular continuity, locked-anchor `GeomagneticField` correction, and cancellation physically exercised; heading and true-north absolute accuracy not validated. |
| Body Heading / Handset-to-Body Calibration | NOT IMPLEMENTED | Stage 3B represents handset heading only; pocket inference and body alignment are not implemented. |
| Step-Event Foundation | VERIFIED — STAGE 3C RUNTIME SCOPE | `TYPE_STEP_DETECTOR` formally exercised in one stationary and two controlled-walk sessions; session-window filtering, accepted-timestamp integrity, and cancellation verified. |
| Step Detection Accuracy | NOT VALIDATED | Limited Stage 3C/6 observations and the Stage 8 targeted retest's 16 manual steps versus 16 PDR updates are scoped execution evidence, not a general accuracy study. |
| Step Length / Heading-Step Association | IMPLEMENTED — STAGE 4 BASELINE SCOPE | Fixed uncalibrated 0.75 m model and latest-at-or-before causal association are implemented; accuracy is not validated. |
| Motion AI | NOT IMPLEMENTED | No motion-classification runtime is connected to navigation. |
| Quality Engine | IMPLEMENTED — STAGE 7/8 CONFIG D SCOPE | Six-state quality classification and 1 / 2 / 6 covariance scaling are implemented and physically exercised through the Stage 8 denied flow; thresholds are not validated. |
| EKF / Sensor Fusion | IMPLEMENTED — STAGE 7/8 CONFIG D SCOPE | Quality-aware PDR, heading, and ARCore fusion is implemented with Joseph covariance updates and physically exercised during Stage 8 denial; fusion accuracy and noise parameters are not validated. |
| Minimum Architecture Gate | TBD | TBD |
| Target Architecture Gate | TBD | TBD |
| Device Baseline | NOT FROZEN | Critical runtime audit items remain pending. |
| Overall Physical Verification | PARTIAL | Stages 2A–2D diagnostics and Stage 3A–8 foundation/evaluation/fusion/denial/recovery flow verified for their defined scopes; full device audit and accuracy validation remain incomplete. |

### Türkçe

| Alan | Sonuç | Notlar |
| --- | --- | --- |
| Cihaz Ortamı | KISMİ | Stage 2B–2D ve Stage 3A–8, Xiaomi Redmi Note 9 Pro ve Android 12 / API 31 üzerinde test edildi; tam ortam denetimi bekliyor. |
| Statik Sensör Kullanılabilirliği | DOĞRULANDI — STAGE 2A KAPSAMI | Çalışma zamanı varsayılan sensör kullanılabilirliği ve metadata doğrulandı; bu sensör performansı kanıtı değildir. |
| İvmeölçer | KISMİ | Stage 2B canlı iletim/zamanlama doğrulandı; sinyal kalitesi, gürültü, bias ve kalibrasyon bekliyor. |
| Jiroskop | KISMİ | Stage 2B canlı iletim/zamanlama doğrulandı; sinyal kalitesi, gürültü, bias ve kalibrasyon bekliyor. |
| Manyetometre | KISMİ | Stage 2B canlı iletim/zamanlama doğrulandı; sinyal kalitesi, gürültü, bias ve kalibrasyon bekliyor. |
| Dönüş Vektörü | DOĞRULANDI — STAGE 3B ÇALIŞMA ZAMANI KAPSAMI | 3/3 heading oturumunda kullanılabilir ve resmî olarak çalıştırıldı; yaklaşık 51,14 Hz teslim gözlendi, mutlak heading doğruluğu doğrulanmadı. |
| Canlı Sensör Olay İletimi | DOĞRULANDI — STAGE 2B KAPSAMI | Seçilen dört sensörde 12/12 zamanlama oturumu geçerli özetlerle tamamlandı. |
| Sensör Zamanlaması | KISMİ | Test edilen 12/12 zaman damgası dizisi monotonikti; 0/12 oturumda geçici 60 ms eşiğinin üzerinde boşluk vardı. Tam AUD-TIME-001 bekliyor. |
| Sensör Örnekleme | KISMİ | Talep edilen 20.000 µs (~50 Hz nominal) ile timestamp-türevli gözlenen hızlar test edilen yapılandırma için karakterize edildi; tam çoklu hız denetimi bekliyor. |
| Sensör Sinyal Kalitesi / Gürültü | DOĞRULANMADI | Stage 2B yalnızca zamanlama karakterizasyon testiydi. |
| GNSS Ön Plan İzni / Preflight | DOĞRULANDI — STAGE 2C KAPSAMI | Hassas ön plan izni ve resmî hazır olma preflight geçişi fiziksel olarak doğrulandı; yalnızca coarse ve fine ön plan izinleri eklendi. |
| GNSS Çalışma Zamanı Zamanlaması | DOĞRULANDI — STAGE 2C KAPSAMI | 3/3 resmî oturum geçerli, monotonik ve mock içermeyen sonuç verdi; medyan/p95 tüm oturumlarda 1,000 s, gözlenen ortalama hız ~0,983–1,000 Hz ve bir adet 2,000 s aralık. Tanımlı GNSS boşluk eşiği yoktur. |
| GNSS Koordinat Doğruluğu | DOĞRULANMADI | Android tarafından bildirilen yatay doğruluk metadata'sı gözlendi ancak koordinat hatası veya GNSS doğruluğu ölçülmedi. |
| GNSS Anchor | DOĞRULANDI — STAGE 3A KAPSAMI | 3/3 yalnızca ön planda çalışan kesinti-öncesi `GPS_PROVIDER` edinimi başarılı oldu; aday sayıları 10 / 11 / 10; clear/reacquire ve iptal doğrulandı. |
| WGS84 / Yerel ENU Temeli | UYGULANDI — STAGE 3A KAPSAMI | WGS84 → ECEF → yerel ENU birim testlerinden geçti; yatay ENU uydurma Up üretmez; fiziksel ENU doğruluğu doğrulanmadı. |
| GNSS Kesinti Denetleyicisi / Ground Truth Firewall | UYGULANDI — STAGE 8 TAM-AKIŞ KAPSAMI | Yazılım-tanımlı tahmin motoru kesintisi, kesinti-GNSS karantinası, korumalı-GT izolasyonu ve taze-fix recovery fiziksel olarak doğrulandı; RF girişimi ve spoofing kullanılmadı. |
| Gerçek Referans İzolasyonu | DOĞRULANDI — STAGE 6 KAPSAMI | Fiziksel GNSS yalnızca korumalı değerlendirme için etkin kaldı ve Yapılandırma A tahmin motoru API'sine kapalıydı; ham koordinatlar ve rotalar döndürülmedi veya kalıcılaştırılmadı. |
| Değerlendirme Modu | DOĞRULANDI — STAGE 6 YAPILANDIRMA A KAPSAMI | Sabit ve düzeltme-sonrası hareketli oturumlar 30/30 korumalı-GT eşleşmesiyle tamamlandı; değerlendirme/firewall akışı doğrulandı, doğruluk doğrulanmadı. |
| Ham GNSS | DOĞRULANMADI | Stage 2C yalnızca sanitize edilmiş `GnssStatus` sayılarını kullandı; NMEA ve ham GNSS ölçümleri kullanılmadı veya doğrulanmadı. |
| ARCore Çalışma Zamanı Takibi | DOĞRULANDI — STAGE 2D KAPSAMI | 3/3 oturum gerçek `TRACKING`, yerel-oturum pozu, monotonik `Frame.timestamp`, sıfır terminal hatası ve sıfır `STOPPED` kare ile geçerliydi; gözlenen benzersiz-kare hızı ~30,0295–30,0304 Hz ve tracking fraction ~%98,15–%98,36 idi. |
| ARCore Poz Doğruluğu / Koordinatları | DOĞRULANMADI | Stage 5 segment-göreli yerel ENU'yu uyguladı ancak konum, mesafe, dikey, sürüklenme, ölçek, dönüş, hizalama ve mutlak doğruluk doğrulanmadı. |
| ARCore-to-ENU Dönüşümü | DOĞRULANDI — STAGE 5 ÇALIŞMA ZAMANI KAPSAMI | `Frame.getAndroidSensorPose()`, yerel ARCore anchor inverse-compose, ilk-cihaz gerçek-ENU hizalaması, nitel eksen/işaret kontrolleri ve iptal fiziksel olarak çalıştırıldı. |
| ARCore Bozulma Yönetimi | KISMİ — STAGE 7 DENEMESİ | Kasıtlı bozulma denendi ancak tracking etkin kaldı; fallback mantığı statik olarak test edildi ve fiziksel tracking-loss fallback'i doğrulanmadı. |
| Kamera | DOĞRULANDI — STAGE 2D KAPSAMI | İzin, GL/EGL başlatma, kamera texture kurulumu ve ARCore kamera çalışma zamanı 3/3 tanı oturumunda geçti. |
| TensorFlow Lite | TBD | TBD |
| Yerel Depolama | TBD | TBD |
| Çevrimdışı Çalışma | TBD | TBD |
| Performans | DOĞRULANMADI | Başlangıç uyarıları gelecekteki ayrı bir uygulama performansı QA konusu olarak kalır. |
| Batarya | TBD | TBD |
| Termal Davranış | TBD | TBD |
| PDR | UYGULANDI — STAGE 4 BASELINE KAPSAMI | Deterministik sabit-0,75 m yatay baseline PDR ve nedensel heading-adım ilişkilendirmesi uygulandı; doğruluk doğrulanmadı. |
| Handset Heading / Gerçek Kuzey Temeli | DOĞRULANDI — STAGE 3B ÇALIŞMA ZAMANI KAPSAMI | Cihaz +Y/üst-kenar, saat yönünde pozitif convention, dairesel süreklilik, kilitli-anchor `GeomagneticField` düzeltmesi ve iptal fiziksel olarak çalıştırıldı; heading ve gerçek-kuzey mutlak doğruluğu doğrulanmadı. |
| Body Heading / Telefon-Vücut Kalibrasyonu | UYGULANMADI | Stage 3B yalnızca handset heading'i temsil eder; cep yönelimi çıkarımı ve vücut hizalaması uygulanmadı. |
| Adım Olayı Temeli | DOĞRULANDI — STAGE 3C ÇALIŞMA ZAMANI KAPSAMI | `TYPE_STEP_DETECTOR` bir sabit ve iki kontrollü-yürüyüş oturumunda resmî olarak çalıştırıldı; oturum-penceresi filtresi, kabul edilen zaman damgası bütünlüğü ve iptal doğrulandı. |
| Adım Algılama Doğruluğu | DOĞRULANMADI | Sınırlı Stage 3C/6 gözlemleri ile Stage 8 hedefli yeniden testindeki 16 manuel adıma karşı 16 PDR update kapsamlı çalışma kanıtıdır; genel bir doğruluk çalışması değildir. |
| Adım Uzunluğu / Heading-Adım İlişkilendirmesi | UYGULANDI — STAGE 4 BASELINE KAPSAMI | Sabit, kalibre edilmemiş 0,75 m model ve en-yeni-önce-veya-eşit nedensel ilişkilendirme uygulandı; doğruluk doğrulanmadı. |
| Motion AI | UYGULANMADI | Navigasyona bağlı bir hareket sınıflandırma çalışma zamanı yoktur. |
| Quality Engine | UYGULANDI — STAGE 7/8 YAPILANDIRMA D KAPSAMI | Altı durumlu kalite sınıflandırması ve 1 / 2 / 6 kovaryans ölçeklemesi uygulandı ve Stage 8 kesintili akışı boyunca fiziksel olarak çalıştırıldı; eşikler doğrulanmadı. |
| EKF / Sensör Füzyonu | UYGULANDI — STAGE 7/8 YAPILANDIRMA D KAPSAMI | Kalite-duyarlı PDR, heading ve ARCore füzyonu Joseph kovaryans güncellemeleriyle uygulandı ve Stage 8 kesintisi sırasında fiziksel olarak çalıştırıldı; füzyon doğruluğu ve gürültü parametreleri doğrulanmadı. |
| Minimum Mimari Kapısı | TBD | TBD |
| Hedef Mimari Kapısı | TBD | TBD |
| Cihaz Baseline'ı | SABİTLENMEDİ | Kritik çalışma zamanı denetim öğeleri bekliyor. |
| Genel Fiziksel Doğrulama | KISMİ | Stage 2A–2D tanıları ve Stage 3A–8 temel/değerlendirme/füzyon/kesinti/recovery akışı tanımlı kapsamlarında doğrulandı; tam cihaz denetimi ve doğruluk doğrulaması tamamlanmadı. |

---

# 56. Device Baseline Freeze Record (Cihaz Temel Referansı Sabitleme Kaydı)

**Baseline Status:** NOT FROZEN *(Temel Referans Durumu: SABİTLENMEDİ)*

**Audit Date:** TBD *(Denetim Tarihi: TBD)*

**Application Audit Build:** TBD *(Uygulama Denetim Build’i: TBD)*

**Device Model:** Xiaomi Redmi Note 9 Pro *(Cihaz Modeli: Xiaomi Redmi Note 9 Pro)*

**Android Version:** Android 12 / API 31 — Stage 2B, Stage 2C, Stage 2D, Stage 3A, Stage 3B, Stage 3C, Stage 4, Stage 5, and Stage 6 tested environment; final baseline pending

**Android Sürümü:** Android 12 / API 31 — Stage 2B, Stage 2C, Stage 2D, Stage 3A, Stage 3B, Stage 3C, Stage 4, Stage 5 ve Stage 6 test ortamı; nihai baseline bekliyor

**Minimum Architecture Gate:** TBD *(Minimum Mimari Kapısı: TBD)*

**Target Architecture Gate:** TBD *(Hedef Mimari Kapısı: TBD)*

**Baseline Approved for Dataset Collection:** NO — PENDING AUDIT *(Veri Seti Toplama İçin Temel Referans Onaylandı: HAYIR — DENETİM BEKLENİYOR)*

**Baseline Approved for Final Experiments:** NO — PENDING AUDIT *(Nihai Deneyler İçin Temel Referans Onaylandı: HAYIR — DENETİM BEKLENİYOR)*

---

# 57. Audit Decision Rule (Denetim Karar Kuralı)

Dataset collection for the final motion classification model must not begin until the sensor configuration and timestamp behavior required by the dataset have been validated. *(Nihai hareket sınıflandırma modeli için veri seti toplama, veri seti tarafından gerekli sensör yapılandırması ve zaman damgası davranışı doğrulanana kadar başlamamalıdır.)*

Navigation tuning must not use assumed sampling frequencies when measured frequencies are available. *(Ölçülen frekanslar mevcutken navigasyon ayarlaması varsayılan örnekleme frekanslarını kullanmamalıdır.)*

ARCore must not be included in the frozen target fusion configuration until its physical device tests have passed. *(ARCore fiziksel cihaz testlerini geçmeden sabitlenmiş hedef füzyon yapılandırmasına dahil edilmemelidir.)*

The final device baseline must represent actual measured Redmi Note 9 Pro behavior rather than generic Android behavior. *(Nihai cihaz temel referansı genel Android davranışı yerine gerçek ölçülmüş Redmi Note 9 Pro davranışını temsil etmelidir.)*

---

# 58. Audit Completion Statement (Denetim Tamamlanma Bildirimi)

**The Device Capability Audit will be considered complete when the physical Xiaomi Redmi Note 9 Pro has been tested for all critical NAVGUARD capabilities, the effective sensor behavior has been measured, all critical results have objective evidence, and the minimum architecture gate has received a PASS decision.** *(Cihaz Yetenek Denetimi; fiziksel Xiaomi Redmi Note 9 Pro tüm kritik NAVGUARD yetenekleri açısından test edildiğinde, etkin sensör davranışı ölçüldüğünde, tüm kritik sonuçlar nesnel kanıta sahip olduğunda ve minimum mimari kapısı PASS kararı aldığında tamamlanmış kabul edilecektir.)*

**The target NAVGUARD architecture will be frozen only after ARCore, on-device AI, and combined runtime capabilities have also been validated or formally replaced by documented fallback decisions.** *(Hedef NAVGUARD mimarisi yalnızca ARCore, cihaz üzeri yapay zekâ ve birleşik çalışma zamanı yetenekleri de doğrulandıktan veya dokümante edilmiş geri dönüş kararlarıyla resmî olarak değiştirildikten sonra sabitlenecektir.)*

---

# 59. Stage 3B Heading / True-North Evidence (Stage 3B Heading / Gerçek Kuzey Kanıtı)

### English

Stage 3B — Heading / True-North Reference Foundation establishes a deterministic handset-heading and true-north-correction foundation for later PDR, ARCore, and EKF work. It is not a navigation estimator. `Sensor.TYPE_ROTATION_VECTOR` is the primary and only Stage 3B heading source; neither `TYPE_GAME_ROTATION_VECTOR` nor an accelerometer-plus-magnetometer fallback estimator is used.

The canonical forward direction is the device +Y axis, meaning the physical top edge of the phone. This is **HANDSET HEADING**, not body heading. Rotation-vector samples are converted with `SensorManager.getRotationMatrixFromVector(...)`; device +Y is projected into horizontal East/North components, magnetic heading is calculated as `atan2(East, North)`, and angles are normalized into `[0, 2π)`. The frozen convention is 0 rad = North, π/2 rad = East, π rad = South, 3π/2 rad = West, with positive rotation clockwise. Circular signed-delta math maintains wrap continuity.

True-north correction uses `android.hardware.GeomagneticField` and the current locked Stage 3A GNSS anchor as the only declination position source. The correction is `normalize(magnetic heading + declination)`. When anchor altitude exists, `declinationAltitudeSource = anchor_ellipsoid_altitude`; otherwise a deterministic 0 m fallback is identified as `deterministic_zero_fallback`, not as measured altitude. In the physical sessions below the source was `anchor_ellipsoid_altitude`. The declination model is `platform_managed`, `declinationModelFreshnessValidated = false`, and no WMM2025 or independently verified model-freshness claim is made.

Sensor physical measurement-time authority is `SensorEvent.timestamp`. `System.currentTimeMillis` is used only as the geomagnetic-model time input; `wallClockUsedForSensorTiming = false`. The formal diagnostic requests 20,000 µs (nominal 50 Hz), has a 10-second first structurally valid sample timeout, and uses a 30-second sensor-timestamp measurement window. The requested rate is not a delivered-rate guarantee.

Static validation passed across six implementation paths (three new and three modified): `flutter analyze` PASS, 61/61 tests PASS, `flutter build apk --debug` PASS, and `git diff --check` PASS. No dependency or manifest change was required.

The tested device was the Xiaomi Redmi Note 9 Pro running Android 12 / API 31. A fresh Stage 3A anchor acquired before the heading sessions returned sanitized metadata with `success = true`, 11 candidates, approximately 43.7262 m selected Android-reported horizontal-accuracy metadata, and altitude available. The reported value is not measured GNSS position error. Raw coordinates are intentionally not recorded here.

Formal preflight returned `rotationVectorAvailable = true`, sensor name `Rotation Vector Non-wakeup`, `requestedSamplingPeriodUs = 20000`, and `diagnosticRunning = false`. Thus the real `TYPE_ROTATION_VECTOR` heading source was available and formally exercised on the tested device.

| Session | Scenario | Valid / Unique Samples | Duration | Observed Rate | Non-Monotonic / Duplicate | Circular Observation |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| 1 | Approximately stationary | 1535 / 1535 | ~29.997 s | ~51.1383 Hz | 0 / 0 | Cumulative ~-0.05827 rad; max consecutive ~0.00676 rad |
| 2 | Approximate manual clockwise rotation | 1535 / 1535 | ~29.998 s | ~51.1374 Hz | 0 / 0 | Cumulative ~+1.14196 rad (~+65.4°) |
| 3 | Circular / wrap continuity | 1535 / 1535 | ~29.998 s | ~51.1372 Hz | 0 / 0 | Cumulative ~+10.56496 rad (>2π); max consecutive ~0.07181 rad |

All three formal sessions succeeded. Across them, timestamp monotonicity passed 3/3, duplicate-free timestamps passed 3/3, observed delivery was approximately 51.137–51.138 Hz, and median delta was approximately 19.555 ms. Session 1 is observational stationary stability evidence only. Session 2 physically supports clockwise-positive response, but the manual rotation angle was not independently measured and heading scale accuracy is not validated. Session 3 physically supports continuous circular accumulation across one or more 0 / 2π boundaries without a consecutive ±2π discontinuity; it does not validate an exact physical rotation angle.

Observed declination was approximately 0.112255 rad (6.43°), remained effectively consistent across the sessions, used `android.hardware.GeomagneticField`, and used `anchor_ellipsoid_altitude`. This verifies execution of the locked-anchor correction path, not true-north absolute accuracy. Android did not supply usable rotation-vector reported heading-accuracy metadata in any formal session: `reportedHeadingAccuracyAvailable = false` and `lastReportedHeadingAccuracyRad = null`. This optional metadata absence is not a Stage 3B failure and is not an actual measured heading error. `headingAccuracyValidated = false` remains explicit.

Explicit cancellation was physically verified and returned the sanitized category `heading_diagnostic_cancelled`; cancellation is PASS. Anchor coordinates are used internally only for geomagnetic declination calculation and are not included in sanitized formal logs. Formal logs may contain heading, timing, declination, and sensor aggregates, but do not contain raw latitude, longitude, anchor altitude value, GNSS candidate coordinates, raw rotation-vector streams, raw GNSS trajectories, or device serials. No claim is made that coordinates never exist in process memory.

At the Stage 3B boundary, research limits remained explicit: heading absolute accuracy **NOT VALIDATED**; true-north absolute accuracy **NOT VALIDATED**; geomagnetic model freshness **NOT VALIDATED**; reported heading accuracy **UNAVAILABLE** in tested sessions; body heading and handset-to-body calibration **NOT IMPLEMENTED**; PDR, step detection, step length, ARCore-to-ENU, Ground Truth Firewall, Evaluation Mode, Quality Engine, EKF, and GNSS-denied navigation **NOT IMPLEMENTED**; the 20% benchmark improvement was **UNMEASURED**. At that boundary, the device baseline was **NOT FROZEN** and overall NAVGUARD physical verification remained **PARTIAL**. Later Stage 4 through Stage 7 status is documented below.

### Türkçe

Aşama 3B — Heading / Gerçek Kuzey Referans Temeli, sonraki PDR, ARCore ve EKF çalışmaları için deterministik handset-heading ve gerçek-kuzey-düzeltme temeli oluşturur. Bir navigasyon tahmin motoru değildir. `Sensor.TYPE_ROTATION_VECTOR`, Stage 3B'nin birincil ve tek heading kaynağıdır; `TYPE_GAME_ROTATION_VECTOR` veya ivmeölçer-artı-manyetometre fallback tahmin motoru kullanılmaz.

Canonical ileri yön cihaz +Y ekseni, yani telefonun fiziksel üst kenarıdır. Bu, body heading değil **HANDSET HEADING**'dir. Rotation-vector örnekleri `SensorManager.getRotationMatrixFromVector(...)` ile dönüştürülür; cihaz +Y yönü yatay Doğu/Kuzey bileşenlerine izdüşürülür, manyetik heading `atan2(Doğu, Kuzey)` ile hesaplanır ve açılar `[0, 2π)` aralığına normalize edilir. Sabitlenen convention; 0 rad = Kuzey, π/2 rad = Doğu, π rad = Güney, 3π/2 rad = Batı ve pozitif dönüşün saat yönünde olmasıdır. Dairesel işaretli-delta matematiği wrap sürekliliğini korur.

Gerçek-kuzey düzeltmesi, tek declination konum kaynağı olarak mevcut kilitli Stage 3A GNSS anchor ile `android.hardware.GeomagneticField` kullanır. Düzeltme `normalize(manyetik heading + declination)` biçimindedir. Anchor yüksekliği varsa `declinationAltitudeSource = anchor_ellipsoid_altitude`; yoksa deterministik 0 m fallback'i ölçülmüş yükseklik olarak değil, `deterministic_zero_fallback` şeklinde tanımlanır. Aşağıdaki fiziksel oturumlarda kaynak `anchor_ellipsoid_altitude` idi. Declination modeli `platform_managed`, `declinationModelFreshnessValidated = false` durumundadır; WMM2025 veya bağımsız doğrulanmış model güncelliği iddia edilmez.

Sensörün fiziksel ölçüm-zamanı otoritesi `SensorEvent.timestamp` değeridir. `System.currentTimeMillis` yalnızca geomanyetik modelin zaman girdisi olarak kullanılır; `wallClockUsedForSensorTiming = false` değeridir. Resmî tanı 20.000 µs (nominal 50 Hz) talep eder, ilk yapısal olarak geçerli örnek için 10 saniye timeout ve sensör zaman damgasına dayalı 30 saniyelik ölçüm penceresi kullanır. Talep edilen hız, teslim hızı garantisi değildir.

Statik doğrulama, üç yeni ve üç değiştirilmiş toplam altı uygulama yolunda geçti: `flutter analyze` PASS, 61/61 test PASS, `flutter build apk --debug` PASS ve `git diff --check` PASS. Dependency veya manifest değişikliği gerekmedi.

Test cihazı Android 12 / API 31 çalıştıran Xiaomi Redmi Note 9 Pro idi. Heading oturumlarından önce edinilen yeni Stage 3A anchor; `success = true`, 11 aday, yaklaşık 43,7262 m seçilen Android-bildirilen yatay doğruluk metadata'sı ve mevcut yükseklik içeren sanitize edilmiş metadata döndürdü. Bildirilen değer ölçülmüş GNSS konum hatası değildir. Ham koordinatlar burada bilinçli olarak kaydedilmez.

Resmî preflight; `rotationVectorAvailable = true`, sensör adı `Rotation Vector Non-wakeup`, `requestedSamplingPeriodUs = 20000` ve `diagnosticRunning = false` döndürdü. Böylece gerçek `TYPE_ROTATION_VECTOR` heading kaynağı test cihazında kullanılabilir bulundu ve resmî olarak çalıştırıldı.

| Oturum | Senaryo | Geçerli / Benzersiz Örnek | Süre | Gözlenen Hız | Monotonik Olmayan / Duplicate | Dairesel Gözlem |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| 1 | Yaklaşık sabit | 1535 / 1535 | ~29,997 s | ~51,1383 Hz | 0 / 0 | Birleşik ~-0,05827 rad; maksimum ardışık ~0,00676 rad |
| 2 | Yaklaşık manuel saat yönü dönüşü | 1535 / 1535 | ~29,998 s | ~51,1374 Hz | 0 / 0 | Birleşik ~+1,14196 rad (~+65,4°) |
| 3 | Dairesel / wrap sürekliliği | 1535 / 1535 | ~29,998 s | ~51,1372 Hz | 0 / 0 | Birleşik ~+10,56496 rad (>2π); maksimum ardışık ~0,07181 rad |

Üç resmî oturumun tamamı başarılı oldu. Oturumlar genelinde zaman damgası monotonluğu 3/3, duplicate içermeyen zaman damgaları 3/3 geçti; gözlenen teslim yaklaşık 51,137–51,138 Hz ve medyan delta yaklaşık 19,555 ms idi. Oturum 1 yalnızca gözlemsel sabit-kararlılık kanıtıdır. Oturum 2 saat yönünde pozitif tepkiyi fiziksel olarak destekler ancak manuel dönüş açısı bağımsız ölçülmedi ve heading ölçek doğruluğu doğrulanmadı. Oturum 3, ardışık ±2π süreksizliği olmadan bir veya daha fazla 0 / 2π sınırındaki sürekli dairesel birikimi fiziksel olarak destekler; kesin fiziksel dönüş açısını doğrulamaz.

Gözlenen declination yaklaşık 0,112255 rad (6,43°) idi, oturumlar boyunca etkili biçimde tutarlı kaldı, `android.hardware.GeomagneticField` ve `anchor_ellipsoid_altitude` kullandı. Bu, kilitli-anchor düzeltme yolunun çalışmasını doğrular; gerçek-kuzey mutlak doğruluğunu değil. Android hiçbir resmî oturumda kullanılabilir rotation-vector bildirilen heading-doğruluk metadata'sı sağlamadı: `reportedHeadingAccuracyAvailable = false` ve `lastReportedHeadingAccuracyRad = null`. Bu isteğe bağlı metadata'nın yokluğu Stage 3B başarısızlığı değildir ve gerçek ölçülmüş heading hatası değildir. `headingAccuracyValidated = false` açıkça korunur.

Açık iptal fiziksel olarak doğrulandı ve sanitize edilmiş `heading_diagnostic_cancelled` kategorisini döndürdü; iptal PASS durumundadır. Anchor koordinatları yalnızca geomanyetik declination hesabı için içeride kullanılır ve sanitize edilmiş resmî loglara dahil edilmez. Resmî loglar heading, zamanlama, declination ve sensör birleşik değerlerini içerebilir ancak ham enlem, boylam, anchor yükseklik değeri, GNSS aday koordinatları, ham rotation-vector akışları, ham GNSS rotaları veya cihaz seri numarası içermez. Koordinatların process memory içinde hiçbir zaman bulunmadığı iddia edilmez.

Stage 3B sınırında araştırma sınırları açık kalıyordu: heading mutlak doğruluğu **DOĞRULANMADI**; gerçek-kuzey mutlak doğruluğu **DOĞRULANMADI**; geomanyetik model güncelliği **DOĞRULANMADI**; bildirilen heading doğruluğu test oturumlarında **KULLANILAMAZ**; body heading ve telefon-vücut kalibrasyonu **UYGULANMADI**; PDR, adım algılama, adım uzunluğu, ARCore-to-ENU, Ground Truth Firewall, Evaluation Mode, Quality Engine, EKF ve GNSS-kesintili navigasyon **UYGULANMADI**; %20 benchmark iyileştirmesi **ÖLÇÜLMEDİ**. Bu sınırda cihaz baseline'ı **SABİTLENMEMİŞTİ** ve genel NAVGUARD fiziksel doğrulaması **KISMİ** durumdaydı. Daha sonraki Stage 4–7 durumu aşağıda dokümante edilmiştir.

---

# 60. Stage 3C Step-Event Foundation Evidence (Stage 3C Adım Olayı Temeli Kanıtı)

### English

Stage 3C — Step-Event Foundation establishes and physically verifies the Android step-event source intended to feed a later baseline PDR implementation. It is not PDR and does not estimate pedestrian position. `Sensor.TYPE_STEP_DETECTOR` is the primary and only formal step source; `TYPE_STEP_COUNTER` is not used as a source or fallback.

The implementation added three new paths and modified four paths, for exactly seven implementation paths. Static validation passed: `flutter analyze --no-pub` PASS, 97/97 tests PASS, `flutter build apk --debug` PASS, and `git diff --check` PASS. No unexpected implementation paths were present and the staging area contained zero files.

The tested device was the Xiaomi Redmi Note 9 Pro running Android 12 / API 31. Android reported the selected sensor display name literally as `pedometer  Non-wakeup`. The runtime path uses `android.permission.ACTIVITY_RECOGNITION`, which was required on the tested API level.

Each formal diagnostic uses a 30-second operation window. `SensorEvent.timestamp` is the physical step timestamp authority. `SystemClock.elapsedRealtimeNanos()` controls the operation window; wall clock is not the step timing authority. The formal contract tracks aggregate values including `updateCount`, `acceptedStepEventCount`, `invalidStepEventCount`, `outOfWindowStepEventCount`, `uniqueTimestampCount`, `duplicateTimestampCount`, `nonMonotonicTimestampCount`, `deltaCount`, step-interval statistics, and observed cadence. It returns no raw step timestamp list or raw sensor samples and uses no persistence. A zero-step session is a valid formal diagnostic result.

| Session | Manual Steps | `updateCount` | Accepted | Invalid | Out of Window | Unique | Duplicate | Non-Monotonic | `deltaCount` | Interpretation |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| 1 — Stationary | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | PASS |
| 2 — Controlled walk | 20 | 21 | 16 | 0 | 5 | 16 | 0 | 0 | 15 | PASS WITH OBSERVATION |
| 3 — Controlled walk | 30 | 30 | 30 | 0 | 0 | 30 | 0 | 0 | 29 | PASS |

| Session | Minimum Interval | Maximum Interval | Mean Interval | Median Interval | p95 Interval | Observed Cadence |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 — Stationary | null | null | null | null | null | null |
| 2 — Controlled 20-step walk | 560.0 ms | 760.0 ms | 657.3333333333334 ms | 640.0 ms | 760.0 ms | 91.27789046653143 steps/min |
| 3 — Controlled 30-step walk | 480.0 ms | 840.0 ms | 640.6896551724138 ms | 640.0 ms | 720.0 ms | 93.64908503767491 steps/min |

No false step event was observed during the single stationary 30-second session. This is a scoped observation and must not be generalized into a global zero-false-positive claim.

In the controlled 20-step walk, five delivered sensor events were excluded by the formal session-window filter and the formal accepted count was 16. This is not an 80% validated sensor-accuracy measurement. No inference is made that every out-of-window event corresponds to one of the manually counted steps.

In the controlled 30-step walk, the accepted event count matched the manually counted 30 steps. This limited physical observation is not sufficient to claim validated general step-detection accuracy.

Across the two walking sessions, `duplicateTimestampCount = 0` and `nonMonotonicTimestampCount = 0`. The stationary session also reported zero duplicate and non-monotonic timestamps because no events were delivered. Only this observed timestamp integrity is claimed.

Explicit cancellation was physically verified. The native error category was `step_diagnostic_cancelled`, and Flutter displayed `Step-event diagnostic failed (step_diagnostic_cancelled).` Cancellation is PASS as an operation-control behavior; it is not a successful measurement result.

Privacy boundaries were preserved in the documented and shared evidence: no raw physical GNSS coordinates, anchor coordinates, device or ADB serial, private Windows path, raw step timestamp, raw rotation-vector stream, API key, token, or secret is included. Stage 3C returns aggregate step evidence only and does not persist it.

At the Stage 3C boundary, research limits remained explicit: step-detection accuracy **NOT VALIDATED**; step length **NOT IMPLEMENTED**; PDR position **NOT IMPLEMENTED**; heading-step association **NOT IMPLEMENTED**; body heading **NOT IMPLEMENTED**; ARCore-to-ENU **NOT IMPLEMENTED**; Ground Truth Firewall **NOT IMPLEMENTED**; Quality Engine **NOT IMPLEMENTED**; EKF **NOT IMPLEMENTED**; full GNSS-denied navigation **NOT IMPLEMENTED**. At that boundary, the device baseline was **NOT FROZEN** and overall physical verification was **PARTIAL**. Later Stage 4 through Stage 7 status is documented below.

The next planned technical milestone at the close of Stage 3C was Stage 4 — Baseline PDR. Stage 4 has since been implemented and is documented in the following section. EKF and ARCore fusion remain outside the Stage 4 baseline.

### Türkçe

Aşama 3C — Adım Olayı Temeli, ilerideki baseline PDR uygulamasını beslemesi amaçlanan Android adım-olayı kaynağını oluşturur ve fiziksel olarak doğrular. PDR değildir ve yaya konumu tahmin etmez. `Sensor.TYPE_STEP_DETECTOR` birincil ve tek resmî adım kaynağıdır; `TYPE_STEP_COUNTER` kaynak veya fallback olarak kullanılmaz.

Uygulama üç yeni yol ekledi ve dört yolu değiştirdi; böylece tam yedi uygulama yolu oluştu. Statik doğrulama geçti: `flutter analyze --no-pub` GEÇTİ, 97/97 test GEÇTİ, `flutter build apk --debug` GEÇTİ ve `git diff --check` GEÇTİ. Beklenmeyen uygulama yolu yoktu ve staging alanında sıfır dosya vardı.

Test cihazı Android 12 / API 31 çalıştıran Xiaomi Redmi Note 9 Pro idi. Android seçilen sensörün görünen adını tam olarak `pedometer  Non-wakeup` şeklinde bildirdi. Çalışma zamanı yolu, test edilen API seviyesinde gerekli olan `android.permission.ACTIVITY_RECOGNITION` iznini kullanır.

Her resmî tanı 30 saniyelik bir operasyon penceresi kullanır. Fiziksel adım zaman damgası otoritesi `SensorEvent.timestamp` değeridir. `SystemClock.elapsedRealtimeNanos()` operasyon penceresini yönetir; wall clock adım zamanlaması otoritesi değildir. Resmî sözleşme; `updateCount`, `acceptedStepEventCount`, `invalidStepEventCount`, `outOfWindowStepEventCount`, `uniqueTimestampCount`, `duplicateTimestampCount`, `nonMonotonicTimestampCount`, `deltaCount`, adım-aralığı istatistikleri ve gözlenen kadans dahil birleşik değerleri izler. Ham adım zaman damgası listesi veya ham sensör örneği döndürmez ve kalıcılaştırma kullanmaz. Sıfır-adımlı oturum geçerli bir resmî tanı sonucudur.

| Oturum | Manuel Adım | `updateCount` | Kabul Edilen | Geçersiz | Pencere Dışı | Benzersiz | Duplicate | Monotonik Olmayan | `deltaCount` | Yorum |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| 1 — Sabit | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | GEÇTİ |
| 2 — Kontrollü yürüyüş | 20 | 21 | 16 | 0 | 5 | 16 | 0 | 0 | 15 | GÖZLEMLE GEÇTİ |
| 3 — Kontrollü yürüyüş | 30 | 30 | 30 | 0 | 0 | 30 | 0 | 0 | 29 | GEÇTİ |

| Oturum | Minimum Aralık | Maksimum Aralık | Ortalama Aralık | Medyan Aralık | p95 Aralık | Gözlenen Kadans |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 — Sabit | null | null | null | null | null | null |
| 2 — Kontrollü 20-adımlık yürüyüş | 560,0 ms | 760,0 ms | 657,3333333333334 ms | 640,0 ms | 760,0 ms | 91,27789046653143 adım/dakika |
| 3 — Kontrollü 30-adımlık yürüyüş | 480,0 ms | 840,0 ms | 640,6896551724138 ms | 640,0 ms | 720,0 ms | 93,64908503767491 adım/dakika |

Tek sabit 30 saniyelik oturumda false adım olayı gözlenmedi. Bu kapsamı sınırlı bir gözlemdir ve global sıfır-false-positive iddiasına genellenmemelidir.

Kontrollü 20-adımlık yürüyüşte teslim edilen beş sensör olayı resmî oturum-penceresi filtresiyle dışlandı ve resmî kabul edilen sayı 16 oldu. Bu, doğrulanmış %80 sensör-doğruluğu ölçümü değildir. Pencere dışındaki her olayın manuel sayılan adımlardan birine karşılık geldiği çıkarımı yapılmaz.

Kontrollü 30-adımlık yürüyüşte kabul edilen olay sayısı manuel olarak sayılan 30 adımla eşleşti. Bu sınırlı fiziksel gözlem, genel adım-algılama doğruluğunun doğrulandığını iddia etmek için yeterli değildir.

İki yürüyüş oturumu genelinde `duplicateTimestampCount = 0` ve `nonMonotonicTimestampCount = 0` idi. Sabit oturum da hiçbir olay teslim edilmediği için sıfır duplicate ve sıfır monotonik olmayan zaman damgası bildirdi. Yalnızca gözlenen bu zaman damgası bütünlüğü iddia edilir.

Açık iptal fiziksel olarak doğrulandı. Native hata kategorisi `step_diagnostic_cancelled` idi ve Flutter `Step-event diagnostic failed (step_diagnostic_cancelled).` mesajını gösterdi. İptal, operasyon-denetimi davranışı olarak GEÇTİ; başarılı ölçüm sonucu değildir.

Dokümante edilen ve paylaşılan kanıtta gizlilik sınırları korundu: ham fiziksel GNSS koordinatı, anchor koordinatı, cihaz veya ADB serisi, özel Windows yolu, ham adım zaman damgası, ham rotation-vector akışı, API anahtarı, token veya secret bulunmaz. Stage 3C yalnızca birleşik adım kanıtı döndürür ve bunu kalıcılaştırmaz.

Stage 3C sınırında araştırma sınırları açık kalıyordu: adım-algılama doğruluğu **DOĞRULANMADI**; adım uzunluğu **UYGULANMADI**; PDR konumu **UYGULANMADI**; heading-adım ilişkilendirmesi **UYGULANMADI**; body heading **UYGULANMADI**; ARCore-to-ENU **UYGULANMADI**; Ground Truth Firewall **UYGULANMADI**; Quality Engine **UYGULANMADI**; EKF **UYGULANMADI**; tam GNSS-kesintili navigasyon **UYGULANMADI**. Bu sınırda cihaz baseline'ı **SABİTLENMEMİŞTİ** ve genel fiziksel doğrulama **KISMİ** durumdaydı. Daha sonraki Stage 4–7 durumu aşağıda dokümante edilmiştir.

Stage 3C kapanışında planlanan sonraki teknik kilometre taşı Stage 4 — Baseline PDR idi. Stage 4 daha sonra uygulandı ve aşağıdaki bölümde dokümante edildi. EKF ve ARCore füzyonu Stage 4 baseline kapsamının dışında kalır.

---

# 61. Stage 4 Baseline PDR Evidence (Aşama 4 Temel PDR Kanıtı)

### English

Stage 4 — Baseline PDR combines Android `Sensor.TYPE_STEP_DETECTOR` events with true-north-corrected `Sensor.TYPE_ROTATION_VECTOR` handset heading to produce deterministic horizontal local-ENU pedestrian dead-reckoning displacement. The phone's physical top edge / device +Y axis is forward. Heading is clockwise-positive from North and normalized into `[0, 2π)`: 0 rad is North, π/2 East, π South, and 3π/2 West.

The frozen association policy is `latest_valid_heading_at_or_before_step_timestamp`. For each accepted step at `T_step`, Stage 4 selects the valid heading with the greatest `T_heading` satisfying `T_heading <= T_step`. Both sources use `SensorEvent.timestamp` in the Android monotonic sensor time domain. Future heading is never used (`futureHeadingUsed = false`), and there is no interpolation. `SystemClock.elapsedRealtimeNanos()` controls the formal 30-second operation window but is not the measurement-time association authority.

Each associated step uses the deterministic research-baseline parameter `L = 0.75 m`. The model is `fixed_baseline`; the value is not a calibrated or validated physical stride length. Starting from `E = 0, N = 0`, horizontal local ENU is updated with `ΔE = L × sin(ψ)` and `ΔN = L × cos(ψ)`, where `+E` is East and `+N` is North. Only associated steps are integrated. The final result returns aggregate counts, association-age statistics, final East/North, net displacement, and nominal model path length; it does not return a per-step trajectory.

True-north correction uses the locked Stage 3A GNSS anchor only as the position input to `android.hardware.GeomagneticField`. The declination model is reported as `platform_managed`, and model freshness remains not validated. The locked anchor is passed internally; no live GNSS is requested or used during Stage 4 PDR integration (`liveGnssUsed = false`).

Stage 4 added three files and modified three files, for exactly six implementation/test paths. Static validation passed: `flutter analyze --no-pub` PASS, 118/118 tests PASS, `flutter build apk --debug` PASS, and `git diff --check` PASS. No manifest or dependency change was required, and the staging area contained zero files before documentation synchronization.

The physical test device was the Xiaomi Redmi Note 9 Pro running Android 12 / API 31. No device serial or ADB identifier is documented.

The stationary formal session lasted 30 seconds with zero manually performed steps. It reported `acceptedStepEventCount = 0`, `associatedStepCount = 0`, `unassociatedStepCount = 0`, `integratedStepCount = 0`, and 1,527/1,527 valid heading samples with no invalid, duplicate, or non-monotonic heading sample. Final East, North, net displacement, and nominal path length were all 0.0 m. The session is PASS. No false step was observed in this single session; this is not a universal zero-false-positive claim.

Controlled straight walk A used 20 manually counted physical steps. It reported 20 accepted, associated, and integrated steps; zero unassociated, duplicate, or non-monotonic step events; and heading-association ages from 0.440730 to 19.472448 ms, with 9.0234301 ms mean, 8.507214 ms median, and 17.547657 ms p95. The final result was `E = -14.600705246027655 m`, `N = 2.6390348023407615 m`, 14.837287432996142 m net displacement, and 15.0 m nominal path length. The session is PASS. The user later determined that the originally assumed geographic walking direction had been physically selected incorrectly, so the absolute E/N direction is not evidence of a heading defect.

Controlled straight walk B also used 20 manually counted steps and reported 20 accepted, associated, and integrated steps with zero unassociated steps. Heading-association ages ranged from 0.341510 to 18.600833 ms, with 9.3492573 ms mean, 10.1975515 ms median, and 16.419947 ms p95. The final result was `E = 3.7152692548576267 m`, `N = 14.458050397065865 m`, 14.927774345835575 m net displacement, and 15.0 m nominal path length. The session is PASS. The two straight-walk PDR directions differed by approximately a right-angle rotation, consistent with the intended relative turn; this does not validate absolute heading accuracy.

The intended L-shaped pattern was approximately 10 steps, a roughly 90-degree clockwise turn, and 10 more steps. The diagnostic reported 22 accepted, associated, and integrated events with zero unassociated steps. Its final result was `E = -6.621301596775239 m`, `N = 11.423209666808471 m`, 13.203459922585626 m net displacement, and 16.5 m nominal path length. The result is PASS WITH OBSERVATION: the detected count exceeded the intended 20-step pattern by two events. Turning or transition steps may have contributed, but no cause is claimed as proven and step-detection accuracy is not inferred. The net-displacement/path-length invariant remained valid.

After the physical orientation was independently corrected, a targeted Heading Foundation north check used `TYPE_ROTATION_VECTOR` and produced 1,535 valid samples, zero duplicate or non-monotonic timestamps, and approximately 51.1421 Hz observed delivery. The first and last true-north-corrected headings were approximately 0.103615 and 0.124233 rad, with 0.020618 rad cumulative change and 0.004149 rad maximum consecutive circular delta. This PASS resolved the earlier absolute-direction concern and supports that no Stage 4 heading-axis bug was established. It remains limited physical verification, not heading or true-north metrological accuracy validation.

Explicit cancellation returned the native category `baseline_pdr_cancelled`, and Flutter displayed `Baseline PDR diagnostic failed (baseline_pdr_cancelled).` Cancellation is PASS as an operation-control behavior; it is not a successful measurement result.

Across the formal walking observations, `futureHeadingUsed = false`, `unassociatedStepCount = 0`, and duplicate/non-monotonic step and heading timestamp counts were zero. Observed association ages were approximately within the sampling interval of the roughly 50 Hz rotation-vector stream. This is observed timing integrity, not a guaranteed latency specification.

Privacy boundaries were preserved: `rawTrajectoryReturned = false`, `rawSensorSamplesReturned = false`, `rawTimestampsReturned = false`, `persistenceUsed = false`, `liveGnssUsed = false`, and `anchorUsedForDeclination = true`. No raw GNSS or anchor coordinates, device serial, private Windows path, raw trajectory, raw sensor stream, raw sensor timestamp, API key, token, or secret is documented.

At the Stage 4 boundary, implementation, static validation, and physical verification were complete for the defined baseline-PDR scope, and PDR position was implemented. PDR accuracy, step-detection accuracy, step-length accuracy, heading accuracy, true-north accuracy, and distance accuracy remained **NOT VALIDATED**. Body heading, ARCore fusion, ARCore-to-ENU, Ground Truth Firewall, Quality Engine, EKF, and full GNSS-denied navigation were **NOT IMPLEMENTED** at that boundary. Stages 5 through 7 were subsequently implemented and are documented in the following sections. The device baseline remains **NOT FROZEN**, and overall NAVGUARD physical verification remains **PARTIAL**.

### Türkçe

Aşama 4 — Temel PDR, deterministik yatay yerel-ENU yaya ölü hesaplama yer değiştirmesi üretmek için Android `Sensor.TYPE_STEP_DETECTOR` olaylarını gerçek-kuzey-düzeltilmiş `Sensor.TYPE_ROTATION_VECTOR` handset heading ile birleştirir. Telefonun fiziksel üst kenarı / cihaz +Y ekseni ileridir. Heading Kuzeyden saat yönünde pozitiftir ve `[0, 2π)` aralığına normalize edilir: 0 rad Kuzey, π/2 Doğu, π Güney ve 3π/2 Batıdır.

Sabitlenen ilişkilendirme politikası `latest_valid_heading_at_or_before_step_timestamp` değeridir. Stage 4, `T_step` anındaki her kabul edilen adım için `T_heading <= T_step` koşulunu sağlayan en büyük `T_heading` değerli geçerli heading'i seçer. Her iki kaynak da Android monotonik sensör zaman alanındaki `SensorEvent.timestamp` değerini kullanır. Gelecek heading hiçbir zaman kullanılmaz (`futureHeadingUsed = false`) ve interpolasyon yoktur. `SystemClock.elapsedRealtimeNanos()` resmî 30 saniyelik operasyon penceresini yönetir ancak ölçüm-zamanı ilişkilendirmesi otoritesi değildir.

Her ilişkilendirilmiş adım deterministik araştırma-baseline parametresi `L = 0,75 m` kullanır. Model `fixed_baseline` değerindedir; bu değer kalibre edilmiş veya doğrulanmış fiziksel adım uzunluğu değildir. `E = 0, N = 0` başlangıcından yatay yerel ENU, `ΔE = L × sin(ψ)` ve `ΔN = L × cos(ψ)` ile güncellenir; `+E` Doğu ve `+N` Kuzeydir. Yalnızca ilişkilendirilmiş adımlar entegre edilir. Nihai sonuç birleşik sayıları, ilişkilendirme-yaşı istatistiklerini, nihai Doğu/Kuzey değerlerini, net yer değiştirmeyi ve nominal model yol uzunluğunu döndürür; adım başına rota döndürmez.

Gerçek-kuzey düzeltmesi kilitli Stage 3A GNSS anchor'ı yalnızca `android.hardware.GeomagneticField` konum girdisi olarak kullanır. Declination modeli `platform_managed` olarak bildirilir ve model güncelliği doğrulanmamış durumda kalır. Kilitli anchor içeride aktarılır; Stage 4 PDR entegrasyonu sırasında canlı GNSS istenmez veya kullanılmaz (`liveGnssUsed = false`).

Stage 4 üç dosya ekledi ve üç dosyayı değiştirdi; böylece tam altı uygulama/test yolu oluştu. Statik doğrulama geçti: `flutter analyze --no-pub` GEÇTİ, 118/118 test GEÇTİ, `flutter build apk --debug` GEÇTİ ve `git diff --check` GEÇTİ. Manifest veya dependency değişikliği gerekmedi ve dokümantasyon senkronizasyonundan önce staging alanında sıfır dosya vardı.

Fiziksel test cihazı Android 12 / API 31 çalıştıran Xiaomi Redmi Note 9 Pro idi. Cihaz serisi veya ADB tanımlayıcısı dokümante edilmedi.

Sabit resmî oturum, manuel olarak sıfır adımla 30 saniye sürdü. `acceptedStepEventCount = 0`, `associatedStepCount = 0`, `unassociatedStepCount = 0`, `integratedStepCount = 0` ve geçersiz, duplicate veya monotonik olmayan heading örneği olmadan 1.527/1.527 geçerli heading örneği bildirdi. Nihai Doğu, Kuzey, net yer değiştirme ve nominal yol uzunluğu değerlerinin tümü 0,0 m idi. Oturum GEÇTİ. Bu tek oturumda false adım gözlenmedi; bu, evrensel sıfır-false-positive iddiası değildir.

Kontrollü düz yürüyüş A, manuel olarak sayılan 20 fiziksel adım kullandı. 20 kabul edilen, ilişkilendirilen ve entegre edilen adım; sıfır ilişkilendirilmemiş, duplicate veya monotonik olmayan adım olayı ve 0,440730–19,472448 ms ilişkilendirme yaşı bildirdi; ortalama 9,0234301 ms, medyan 8,507214 ms ve p95 17,547657 ms idi. Nihai sonuç `E = -14,600705246027655 m`, `N = 2,6390348023407615 m`, 14,837287432996142 m net yer değiştirme ve 15,0 m nominal yol uzunluğu idi. Oturum GEÇTİ. Kullanıcı daha sonra ilk varsayılan coğrafi yürüyüş yönünün fiziksel olarak yanlış seçildiğini belirledi; bu nedenle mutlak E/N yönü heading hatası kanıtı değildir.

Kontrollü düz yürüyüş B de manuel olarak sayılan 20 adım kullandı ve sıfır ilişkilendirilmemiş adımla 20 kabul edilen, ilişkilendirilen ve entegre edilen adım bildirdi. Heading ilişkilendirme yaşları 0,341510–18,600833 ms aralığındaydı; ortalama 9,3492573 ms, medyan 10,1975515 ms ve p95 16,419947 ms idi. Nihai sonuç `E = 3,7152692548576267 m`, `N = 14,458050397065865 m`, 14,927774345835575 m net yer değiştirme ve 15,0 m nominal yol uzunluğu idi. Oturum GEÇTİ. İki düz-yürüyüş PDR yönü hedeflenen göreli dönüşle tutarlı biçimde yaklaşık dik açı kadar farklıydı; bu, mutlak heading doğruluğunu doğrulamaz.

Hedeflenen L-biçimli desen yaklaşık 10 adım, yaklaşık 90 derece saat yönünde dönüş ve 10 adım daha içeriyordu. Tanı, sıfır ilişkilendirilmemiş adımla 22 kabul edilen, ilişkilendirilen ve entegre edilen olay bildirdi. Nihai sonuç `E = -6,621301596775239 m`, `N = 11,423209666808471 m`, 13,203459922585626 m net yer değiştirme ve 16,5 m nominal yol uzunluğu idi. Sonuç GÖZLEMLE GEÇTİ: algılanan sayı hedeflenen 20-adımlık deseni iki olay aştı. Dönüş veya geçiş adımları katkıda bulunmuş olabilir ancak hiçbir neden kanıtlanmış olarak iddia edilmez ve adım-algılama doğruluğu çıkarımı yapılmaz. Net-yer-değiştirme/yol-uzunluğu değişmezi geçerli kaldı.

Fiziksel yön bağımsız olarak düzeltildikten sonra hedefli Heading Foundation kuzey kontrolü `TYPE_ROTATION_VECTOR` kullandı; 1.535 geçerli örnek, sıfır duplicate veya monotonik olmayan zaman damgası ve yaklaşık 51,1421 Hz gözlenen teslim üretti. İlk ve son gerçek-kuzey-düzeltilmiş heading değerleri yaklaşık 0,103615 ve 0,124233 rad; birleşik değişim 0,020618 rad ve maksimum ardışık dairesel delta 0,004149 rad idi. Bu GEÇTİ sonucu önceki mutlak-yön endişesini çözdü ve Stage 4 heading-ekseni hatası saptanmadığını destekledi. Yine de bu, heading veya gerçek-kuzey metrolojik doğruluk doğrulaması değil, sınırlı fiziksel doğrulamadır.

Açık iptal native `baseline_pdr_cancelled` kategorisini döndürdü ve Flutter `Baseline PDR diagnostic failed (baseline_pdr_cancelled).` mesajını gösterdi. İptal operasyon-denetimi davranışı olarak GEÇTİ; başarılı ölçüm sonucu değildir.

Resmî yürüyüş gözlemlerinin tümünde `futureHeadingUsed = false`, `unassociatedStepCount = 0` ve duplicate/monotonik olmayan adım ile heading zaman damgası sayıları sıfırdı. Gözlenen ilişkilendirme yaşları yaklaşık 50 Hz rotation-vector akışının örnekleme aralığı içinde kaldı. Bu, gözlenen zamanlama bütünlüğüdür; garanti edilen gecikme şartnamesi değildir.

Gizlilik sınırları korundu: `rawTrajectoryReturned = false`, `rawSensorSamplesReturned = false`, `rawTimestampsReturned = false`, `persistenceUsed = false`, `liveGnssUsed = false` ve `anchorUsedForDeclination = true`. Ham GNSS veya anchor koordinatı, cihaz serisi, özel Windows yolu, ham rota, ham sensör akışı, ham sensör zaman damgası, API anahtarı, token veya secret dokümante edilmedi.

Stage 4 sınırında uygulama, statik doğrulama ve fiziksel doğrulama tanımlı baseline-PDR kapsamı için tamamlanmış ve PDR konumu uygulanmıştı. PDR doğruluğu, adım-algılama doğruluğu, adım-uzunluğu doğruluğu, heading doğruluğu, gerçek-kuzey doğruluğu ve mesafe doğruluğu **DOĞRULANMAMIŞTI**. Body heading, ARCore füzyonu, ARCore-to-ENU, Ground Truth Firewall, Quality Engine, EKF ve tam GNSS-kesintili navigasyon bu sınırda **UYGULANMAMIŞTI**. Stage 5–7 daha sonra uygulandı ve aşağıdaki bölümlerde dokümante edildi. Cihaz baseline'ı **SABİTLENMEMİŞTİR** ve genel NAVGUARD fiziksel doğrulaması **KISMİ** durumdadır.

---

# 62. Stage 5 ARCore Relative Motion → ENU Evidence (Aşama 5 ARCore Göreli Hareket → ENU Kanıtı)

### English

Stage 5 — ARCore Relative Motion → ENU Foundation converts segment-relative ARCore visual-inertial displacement into NAVGUARD local ENU (`+E` East, `+N` North, `+U` Up). It is an isolated motion foundation, not ARCore/PDR fusion or a navigation estimator.

The frozen pose source is `Frame.getAndroidSensorPose()`. The Android sensor-frame axes are +X physical device right, +Y physical device top edge, and +Z outward from the screen; device-forward remains device +Y / the physical top edge. Stage 5 performs no display-rotation remapping and does not treat camera optical forward as walking forward.

Acquisition requires ARCore camera `TrackingState.TRACKING` and at least one valid `TYPE_ROTATION_VECTOR` sample. The user is instructed to hold the handset approximately stationary, screen approximately upward, and top edge stable for `alignmentHoldMs = 2000`; the acquisition timeout is 15,000 ms. Stationarity is assumed for this phase (`alignmentStationarityAssumed = true`) but is not independently validated (`alignmentStationarityValidated = false`).

At alignment completion, Stage 5 creates a local runtime ARCore anchor from the current Android sensor pose. The reference strategy is `local_arcore_anchor`, and each usable relative pose is `anchor.pose.inverse().compose(currentAndroidSensorPose)`. Its translation is expressed in the initial device/reference frame; raw ARCore world translation is not treated directly as ENU.

The initial device-to-true-ENU rotation uses `alignmentSource = rotation_vector_plus_geomagnetic_declination`, frozen from `TYPE_ROTATION_VECTOR` plus `android.hardware.GeomagneticField` declination. The locked Stage 3A GNSS anchor is supplied only for declination; live GNSS, GNSS travel bearing, fused location, ARCore Geospatial, VPS, Cloud/Terrain/Rooftop anchors, and internet services are not used. After anchor values are supplied, `liveGnssUsed = false`. The formal movement window begins after alignment and lasts `measurementWindowMs = 30000`, controlled by `SystemClock.elapsedRealtimeNanos()`.

Rotation-vector timing authority is `SensorEvent.timestamp`; ARCore frame ordering, duplicate/non-monotonic detection, and aggregate frame-rate statistics use `Frame.getTimestamp()`. The formal contract records `arFrameTimestampTimeBase = undefined_by_arcore_api`: ARCore does not define a shared numeric epoch with Android sensor timestamps. The two clocks are never numerically cross-compared (`crossClockTimestampComparisonUsed = false`), and no cross-sensor latency is reported.

ENU is updated only when both the camera and local reference anchor are `TRACKING`. `PAUSED` or `STOPPED` states do not fabricate a pose. Temporary tracking loss has no PDR, GNSS, map, or accelerometer-integration fallback; a permanently stopped reference anchor fails deterministically.

Stage 5 added three files and modified three files, for exactly six implementation/test paths. Static validation passed: `flutter analyze --no-pub` PASS, 141/141 tests PASS, `flutter build apk --debug` PASS, and `git diff --check` PASS. No manifest or dependency change was required, unexpected paths were absent, and the staging area contained zero paths before documentation synchronization.

The physical test device was the Xiaomi Redmi Note 9 Pro running Android 12 / API 31. No device serial or ADB identifier is documented.

The stationary 30-second formal session reported `arFrameUpdateCount = 900`, `trackingFrameCount = 900`, `pausedFrameCount = 0`, `stoppedFrameCount = 0`, `usableEnuFrameCount = 900`, `trackingFraction = 1.0`, `duplicateArFrameTimestampCount = 0`, and `nonMonotonicArFrameTimestampCount = 0`. `medianFrameDeltaMs = 33.299584` and `observedTrackingFrameRateHz = 30.029775697740583`. It ended at `finalEastM = -0.05995663974270185`, `finalNorthM = -0.05445452655016181`, and `finalUpM = -0.0035056549199725673`: `finalHorizontalDisplacementM = 0.08099440789979523`, `final3dDisplacementM = 0.08107023946835447`, `maxHorizontalDisplacementM = 0.10048726936326462`, and `maxAbsUpM = 0.01242511761435372`. The result is **PASS** for the scoped stationary observation. This specific session ended approximately 8.1 cm horizontally from the origin and showed approximately 10.0 cm maximum horizontal excursion; it is not a universal drift or accuracy specification.

The independently identified north-like straight-motion session reported `arFrameUpdateCount = 900`, `trackingFrameCount = 900`, `usableEnuFrameCount = 900`, `trackingFraction = 1.0`, `pausedFrameCount = 0`, `stoppedFrameCount = 0`, `duplicateArFrameTimestampCount = 0`, `nonMonotonicArFrameTimestampCount = 0`, and `observedTrackingFrameRateHz = 30.031286834473587`. It ended at `finalEastM = 1.5068029158075469`, `finalNorthM = 8.223012798105698`, `finalUpM = -0.7123536788677436`, `finalHorizontalDisplacementM = 8.359927900699637`, `final3dDisplacementM = 8.390223016624327`, `maxHorizontalDisplacementM = 8.368223074399847`, and `maxAbsUpM = 0.740541385205586`. North was positive and clearly dominant; the horizontal direction was approximately 10 degrees east of north. The result is **PASS** for qualitative ENU axis/sign verification, not absolute heading, distance, or vertical accuracy validation.

The east-like straight-motion session reported `arFrameUpdateCount = 899`, `trackingFrameCount = 899`, `pausedFrameCount = 0`, `stoppedFrameCount = 0`, `usableEnuFrameCount = 898`, `trackingFraction = 1.0`, `uniqueArFrameTimestampCount = 898`, `duplicateArFrameTimestampCount = 1`, `nonMonotonicArFrameTimestampCount = 0`, `medianFrameDeltaMs = 33.299584`, and `observedTrackingFrameRateHz = 29.964009038200984`. It ended at `finalEastM = 9.128999139852409`, `finalNorthM = -1.1755135596772799`, `finalUpM = -0.3212850446477491`, `finalHorizontalDisplacementM = 9.204371647451616`, `final3dDisplacementM = 9.209977280337096`, `maxHorizontalDisplacementM = 9.229182166301715`, and `maxAbsUpM = 0.33117926154093835`. East was positive and clearly dominant; the horizontal direction was approximately 97 degrees clockwise from north. The result is **PASS** for qualitative ENU axis/sign verification. The single duplicate was counted diagnostically and is not treated as a system failure.

The approximate 90-degree in-place rotation session reported `arFrameUpdateCount = 901`, `trackingFrameCount = 901`, `pausedFrameCount = 0`, `stoppedFrameCount = 0`, `usableEnuFrameCount = 901`, `trackingFraction = 1.0`, `duplicateArFrameTimestampCount = 0`, `nonMonotonicArFrameTimestampCount = 0`, and `observedTrackingFrameRateHz = 30.033981060867745`. It ended at `finalEastM = 0.4044209568871296`, `finalNorthM = -0.29916259235067916`, `finalUpM = 0.0052074308466663055`, `finalHorizontalDisplacementM = 0.5030452932206803`, `final3dDisplacementM = 0.5030722456740214`, `maxHorizontalDisplacementM = 0.537769891199854`, and `maxAbsUpM = 0.014645347105641804`. The result is **PASS WITH OBSERVATION**: the approximately 0.50 m final displacement was much smaller than the approximately 8–9 m straight-walk displacements, supporting that orientation change was not interpreted as walking-scale translation. Human handset/body translation may contribute, and no rotation-only threshold or ARCore error value is validated.

Explicit cancellation returned `arcore_enu_cancelled`. This is **PASS** for lifecycle and resource-control behavior, not a successful movement measurement.

Across completed formal Stage 5 measurement sessions, `trackingFraction = 1.0` and no `PAUSED` or `STOPPED` frames were observed. This does not generalize to other environments and does not validate tracking-loss recovery.

Privacy and research boundaries remained intact: `anchorUsedForDeclination = true`, `liveGnssUsed = false`, `rawTrajectoryReturned = false`, `rawArcorePosesReturned = false`, `rawRotationVectorSamplesReturned = false`, `rawTimestampsReturned = false`, `cameraImagesReturned = false`, `persistenceUsed = false`, `pathLengthCalculated = false`, `displayRotationRemappingUsed = false`, `cameraOpticalForwardUsed = false`, `geospatialApiUsed = false`, and `cloudServiceUsed = false`. No GNSS/anchor coordinates, device serial, private filesystem path, raw pose, trajectory, camera frame, sensor stream, timestamp, credential, or secret is documented.

At the Stage 5 boundary, implementation, static validation, and physical verification were **COMPLETE/PASS** for the defined foundation scope. ARCore relative motion and the ARCore-to-ENU transform were **IMPLEMENTED**. ARCore position accuracy, ARCore distance accuracy, ENU-alignment accuracy, vertical accuracy, heading accuracy, and true-north accuracy remained **NOT VALIDATED**. PDR fusion, Quality Engine, EKF, Ground Truth Firewall, and full GNSS-denied navigation were **NOT IMPLEMENTED** at that boundary. Stages 6 and 7 were subsequently implemented and are documented in the following sections. Overall NAVGUARD physical verification remains **PARTIAL**, and the device baseline remains **NOT FROZEN**.

### Türkçe

Aşama 5 — ARCore Göreli Hareket → ENU Temeli, segment-göreli ARCore görsel-ataletsel yer değiştirmesini NAVGUARD yerel ENU çerçevesine (`+E` Doğu, `+N` Kuzey, `+U` Yukarı) dönüştürür. Bu, izole bir hareket temelidir; ARCore/PDR füzyonu veya navigasyon tahmin motoru değildir.

Sabitlenen poz kaynağı `Frame.getAndroidSensorPose()` değeridir. Android sensör-çerçevesi eksenleri +X cihazın fiziksel sağı, +Y cihazın fiziksel üst kenarı ve +Z ekrandan dışarıdır; cihaz-ileri yönü cihaz +Y / fiziksel üst kenar olarak kalır. Stage 5 ekran-dönüşü remapping'i yapmaz ve kamera optik ileri yönünü yürüme ileri yönü olarak ele almaz.

Edinim, ARCore kamera `TrackingState.TRACKING` durumu ve en az bir geçerli `TYPE_ROTATION_VECTOR` örneği gerektirir. Kullanıcıdan `alignmentHoldMs = 2000` süresince telefonu yaklaşık sabit, ekranı yaklaşık yukarı ve üst kenarı kararlı tutması istenir; edinim timeout'u 15.000 ms'dir. Bu fazda sabitlik varsayılır (`alignmentStationarityAssumed = true`) ancak bağımsız doğrulanmaz (`alignmentStationarityValidated = false`).

Hizalama tamamlandığında Stage 5 mevcut Android sensör pozundan yerel çalışma zamanı ARCore anchor'ı oluşturur. Referans stratejisi `local_arcore_anchor` değeridir ve her kullanılabilir göreli poz `anchor.pose.inverse().compose(currentAndroidSensorPose)` ile hesaplanır. Öteleme ilk cihaz/referans çerçevesinde ifade edilir; ham ARCore dünya ötelemesi doğrudan ENU olarak ele alınmaz.

İlk cihazdan gerçek ENU'ya dönüş, `TYPE_ROTATION_VECTOR` ile `android.hardware.GeomagneticField` declination değerinden sabitlenen `alignmentSource = rotation_vector_plus_geomagnetic_declination` kaynağını kullanır. Kilitli Stage 3A GNSS anchor yalnızca declination için sağlanır; canlı GNSS, GNSS travel bearing, fused location, ARCore Geospatial, VPS, Cloud/Terrain/Rooftop anchor veya internet hizmeti kullanılmaz. Anchor değerleri sağlandıktan sonra `liveGnssUsed = false` değeridir. Resmî hareket penceresi hizalamadan sonra başlar, `measurementWindowMs = 30000` sürer ve `SystemClock.elapsedRealtimeNanos()` ile yönetilir.

Rotation-vector zamanlama otoritesi `SensorEvent.timestamp`; ARCore kare sıralaması, duplicate/monotonik-olmayan algılama ve birleşik kare-hızı istatistikleri `Frame.getTimestamp()` kullanır. Resmî sözleşme `arFrameTimestampTimeBase = undefined_by_arcore_api` değerini kaydeder: ARCore, Android sensör zaman damgalarıyla paylaşılan bir sayısal epoch tanımlamaz. İki saat sayısal olarak hiçbir zaman cross-compare edilmez (`crossClockTimestampComparisonUsed = false`) ve çapraz-sensör gecikmesi bildirilmez.

ENU yalnızca kamera ve yerel referans anchor `TRACKING` durumundayken güncellenir. `PAUSED` veya `STOPPED` durumlarında poz uydurulmaz. Geçici takip kaybı için PDR, GNSS, harita veya ivmeölçer-entegrasyonu fallback'i yoktur; kalıcı olarak duran referans anchor deterministik hatayla sonlanır.

Stage 5 üç dosya ekledi ve üç dosyayı değiştirdi; böylece tam altı uygulama/test yolu oluştu. Statik doğrulama geçti: `flutter analyze --no-pub` GEÇTİ, 141/141 test GEÇTİ, `flutter build apk --debug` GEÇTİ ve `git diff --check` GEÇTİ. Manifest veya dependency değişikliği gerekmedi, beklenmeyen yol yoktu ve dokümantasyon senkronizasyonundan önce staging alanında sıfır yol vardı.

Fiziksel test cihazı Android 12 / API 31 çalıştıran Xiaomi Redmi Note 9 Pro idi. Cihaz serisi veya ADB tanımlayıcısı dokümante edilmedi.

Sabit 30 saniyelik resmî oturum `arFrameUpdateCount = 900`, `trackingFrameCount = 900`, `pausedFrameCount = 0`, `stoppedFrameCount = 0`, `usableEnuFrameCount = 900`, `trackingFraction = 1.0`, `duplicateArFrameTimestampCount = 0` ve `nonMonotonicArFrameTimestampCount = 0` bildirdi. `medianFrameDeltaMs = 33.299584` ve `observedTrackingFrameRateHz = 30.029775697740583` idi. `finalEastM = -0.05995663974270185`, `finalNorthM = -0.05445452655016181` ve `finalUpM = -0.0035056549199725673` değerlerinde sonlandı; `finalHorizontalDisplacementM = 0.08099440789979523`, `final3dDisplacementM = 0.08107023946835447`, `maxHorizontalDisplacementM = 0.10048726936326462` ve `maxAbsUpM = 0.01242511761435372` idi. Sonuç kapsamı belirli sabit gözlem için **GEÇTİ**. Bu özel oturum başlangıçtan yaklaşık 8,1 cm yatay uzaklıkta sonlandı ve yaklaşık 10,0 cm maksimum yatay sapma gösterdi; bu evrensel sürüklenme veya doğruluk şartnamesi değildir.

Bağımsız tanımlanan kuzey-benzeri düz-hareket oturumu `arFrameUpdateCount = 900`, `trackingFrameCount = 900`, `usableEnuFrameCount = 900`, `trackingFraction = 1.0`, `pausedFrameCount = 0`, `stoppedFrameCount = 0`, `duplicateArFrameTimestampCount = 0`, `nonMonotonicArFrameTimestampCount = 0` ve `observedTrackingFrameRateHz = 30.031286834473587` bildirdi. `finalEastM = 1.5068029158075469`, `finalNorthM = 8.223012798105698`, `finalUpM = -0.7123536788677436`, `finalHorizontalDisplacementM = 8.359927900699637`, `final3dDisplacementM = 8.390223016624327`, `maxHorizontalDisplacementM = 8.368223074399847` ve `maxAbsUpM = 0.740541385205586` ile sonlandı. Kuzey pozitif ve açıkça Doğudan baskındı; yatay yön kuzeyin yaklaşık 10 derece doğusundaydı. Sonuç nitel ENU eksen/işaret doğrulaması için **GEÇTİ**; mutlak heading, mesafe veya dikey doğruluk doğrulaması değildir.

Doğu-benzeri düz-hareket oturumu `arFrameUpdateCount = 899`, `trackingFrameCount = 899`, `pausedFrameCount = 0`, `stoppedFrameCount = 0`, `usableEnuFrameCount = 898`, `trackingFraction = 1.0`, `uniqueArFrameTimestampCount = 898`, `duplicateArFrameTimestampCount = 1`, `nonMonotonicArFrameTimestampCount = 0`, `medianFrameDeltaMs = 33.299584` ve `observedTrackingFrameRateHz = 29.964009038200984` bildirdi. `finalEastM = 9.128999139852409`, `finalNorthM = -1.1755135596772799`, `finalUpM = -0.3212850446477491`, `finalHorizontalDisplacementM = 9.204371647451616`, `final3dDisplacementM = 9.209977280337096`, `maxHorizontalDisplacementM = 9.229182166301715` ve `maxAbsUpM = 0.33117926154093835` ile sonlandı. Doğu pozitif ve açıkça Kuzeyden baskındı; yatay yön kuzeyden saat yönünde yaklaşık 97 dereceydi. Sonuç nitel ENU eksen/işaret doğrulaması için **GEÇTİ**. Tek duplicate tanısal olarak sayıldı ve sistem hatası olarak ele alınmadı.

Yaklaşık 90 derecelik yerinde dönüş oturumu `arFrameUpdateCount = 901`, `trackingFrameCount = 901`, `pausedFrameCount = 0`, `stoppedFrameCount = 0`, `usableEnuFrameCount = 901`, `trackingFraction = 1.0`, `duplicateArFrameTimestampCount = 0`, `nonMonotonicArFrameTimestampCount = 0` ve `observedTrackingFrameRateHz = 30.033981060867745` bildirdi. `finalEastM = 0.4044209568871296`, `finalNorthM = -0.29916259235067916`, `finalUpM = 0.0052074308466663055`, `finalHorizontalDisplacementM = 0.5030452932206803`, `final3dDisplacementM = 0.5030722456740214`, `maxHorizontalDisplacementM = 0.537769891199854` ve `maxAbsUpM = 0.014645347105641804` ile sonlandı. Sonuç **GÖZLEMLE GEÇTİ**: yaklaşık 0,50 m nihai yer değiştirme yaklaşık 8–9 m düz-yürüyüş yer değiştirmelerinden çok daha düşüktü ve yönelim değişikliğinin yürüme-ölçeğinde öteleme olarak yorumlanmadığını destekledi. İnsan kaynaklı telefon/vücut ötelemesi katkıda bulunabilir; yalnızca-dönüş eşiği veya ARCore hata değeri doğrulanmadı.

Açık iptal `arcore_enu_cancelled` döndürdü. Bu yaşam döngüsü ve kaynak-denetimi davranışı için **GEÇTİ** sonucudur; başarılı hareket ölçümü değildir.

Tamamlanan resmî Stage 5 ölçüm oturumlarında `trackingFraction = 1.0` idi ve `PAUSED` veya `STOPPED` kare gözlenmedi. Bu diğer ortamlara genellenemez ve tracking-loss recovery doğrulaması değildir.

Gizlilik ve araştırma sınırları korundu: `anchorUsedForDeclination = true`, `liveGnssUsed = false`, `rawTrajectoryReturned = false`, `rawArcorePosesReturned = false`, `rawRotationVectorSamplesReturned = false`, `rawTimestampsReturned = false`, `cameraImagesReturned = false`, `persistenceUsed = false`, `pathLengthCalculated = false`, `displayRotationRemappingUsed = false`, `cameraOpticalForwardUsed = false`, `geospatialApiUsed = false` ve `cloudServiceUsed = false`. Hiçbir GNSS/anchor koordinatı, cihaz serisi, özel dosya sistemi yolu, ham poz, rota, kamera karesi, sensör akışı, zaman damgası, kimlik bilgisi veya secret dokümante edilmedi.

Stage 5 sınırında uygulama, statik doğrulama ve fiziksel doğrulama tanımlı temel kapsamı için **TAMAMLANDI/GEÇTİ** durumundaydı. ARCore göreli hareketi ve ARCore-to-ENU dönüşümü **UYGULANMIŞTI**. ARCore konum doğruluğu, ARCore mesafe doğruluğu, ENU-hizalama doğruluğu, dikey doğruluk, heading doğruluğu ve gerçek-kuzey doğruluğu **DOĞRULANMAMIŞTI**. PDR füzyonu, Quality Engine, EKF, Ground Truth Firewall ve tam GNSS-kesintili navigasyon bu sınırda **UYGULANMAMIŞTI**. Stage 6 ve Stage 7 daha sonra uygulandı ve aşağıdaki bölümlerde dokümante edildi. Genel NAVGUARD fiziksel doğrulaması **KISMİ**, cihaz baseline'ı **SABİTLENMEMİŞ** durumda kalır.

---

# 63. Stage 6 Evaluation Mode + Ground Truth Firewall Evidence (Aşama 6 Değerlendirme Modu + Ground Truth Güvenlik Duvarı Kanıtı)

### English

Stage 6 — Evaluation Mode + Ground Truth Firewall implements a protected evaluation path for the frozen Config A denied estimator. Physical `GPS_PROVIDER` GNSS remains active only as `protected_ground_truth_only`; software-defined estimator GNSS denial remains active throughout the formal window. The denied-estimator API receives only accepted `TYPE_STEP_DETECTOR` events and valid true-north-corrected `TYPE_ROTATION_VECTOR` handset headings. Protected GNSS is not available to or used by the denied estimator, heading, step length, Quality Engine, or controller, and no GNSS correction is applied.

Config A remains `config_a_baseline_pdr` with a fixed, uncalibrated, unvalidated 0.75 m step length. Its equations remain `ΔE = 0.75 × sin(ψ)` and `ΔN = 0.75 × cos(ψ)`. Step and heading timestamps are nanosecond `SensorEvent.timestamp` values. Protected GNSS uses `Location.getElapsedRealtimeNanos`, and the operation window uses `SystemClock.elapsedRealtimeNanos`. The observed contract reported `elapsedRealtimeSharedTimeBaseUsed = true`, `gnssSensorElapsedRealtimeComparisonUsed = true`, and `unsupportedCrossClockComparisonUsed = false`. ARCore `Frame` timestamps are not involved.

The denied estimator uses `latest_valid_heading_at_or_before_step_timestamp`: for each accepted step at `T_step`, it selects the valid heading with the greatest timestamp satisfying `T_heading <= T_step`. Future headings, nearest-neighbor selection, interpolation, averaging, post-step correction, GNSS heading, and protected-GT influence are prohibited. The separate evaluation comparator uses `latest_estimator_state_at_or_before_ground_truth_timestamp`, observes finalized estimator states only, and performs no interpolation or correction. `finalDeniedPreCorrectionErrorM` is the final horizontal error before any correction; Stage 6 implements no GNSS correction.

Stage 6 added three files and modified three files, for exactly six implementation/test paths. After the physical bug fix, static validation passed: `flutter analyze --no-pub` PASS, 169/169 tests PASS, `flutter build apk --debug` PASS, and `git diff --check` PASS. Unexpected paths were absent and the staging area contained zero paths before documentation synchronization.

The stationary Evaluation Mode session passed. It reported 30 accepted protected-GT fixes, 30 matched fixes, zero unmatched fixes, zero mock fixes, zero accepted/associated/integrated steps, and final denied state `E = 0.0 m, N = 0.0 m`. Final horizontal displacement and nominal integrated path length were both 0.0 m. Median horizontal error was approximately 0.526 m, p95 error approximately 2.445 m, and final denied pre-correction error approximately 0.506 m. These values are session observations, not survey-grade accuracy measurements.

The initial moving physical test failed and exposed a real implementation defect. Eleven step events were accepted, but associated/integrated counts were zero and all 11 were unassociated despite 1,531/1,531 valid heading samples. Stage 6 retained only the latest delivered heading sample. Because cross-sensor callbacks can be delivered with timing/order differences, that latest delivered heading could have a timestamp later than a delayed step timestamp while older causal headings were no longer retained. Stage 4 was unaffected because it buffered heading and step streams and performed timestamp-based causal association after collection.

The two-file bug fix modified only `EvaluationModeDiagnostic.kt` and `evaluation_mode_test.dart`. Valid heading samples and accepted step timestamps are now buffered separately, and association is finalized in timestamp order by selecting the greatest `T_heading <= T_step`. Future heading, protected GT, interpolation, averaging, and post-step correction remain excluded. Regression tests for a causal previous heading, immediate prior heading, future-heading rejection, multi-step association/counter invariants, and ground-truth mutation invariance passed. Stage 4 and the Ground Truth Firewall contract were unchanged.

The post-fix moving retest passed for the defined flow. The user manually walked 20 physical steps. The runtime observed 16 step updates; five were outside the formal evaluation window and 11 were accepted. All 11 accepted steps were associated and integrated, with zero unassociated, duplicate, or non-monotonic accepted step timestamps. The heading stream contained 1,531 valid samples with zero duplicate or non-monotonic timestamps. The final denied state was approximately `E = 8.108 m, N = -1.311 m`, horizontal displacement approximately 8.213 m, and nominal integrated path length 8.25 m. The 11 accepted events must not be described as 20/20 step-detection accuracy; step-detection accuracy remains not validated.

The moving retest accepted and matched 30/30 protected-GT fixes with zero unmatched and zero mock fixes. Android-reported protected-GNSS horizontal-accuracy metadata ranged from approximately 17.36 m to 57.12 m, with mean approximately 22.83 m and median approximately 19.91 m. Observed median horizontal error was approximately 19.99 m, p95 error approximately 48.24 m, and final denied pre-correction error approximately 19.78 m. Because the reference uncertainty was large, these values validate the Evaluation Mode and firewall data flow, not Config A navigation accuracy, survey-grade position error, or protected-GNSS ground-truth accuracy.

Successful Stage 6 physical results reported `evaluationModeImplemented = true`, `groundTruthFirewallImplemented = true`, `protectedGroundTruthGnssActive = true`, `softwareDefinedEstimatorGnssDenial = true`, `liveGnssPhysicallyActive = true`, `liveGnssUsedForProtectedGroundTruth = true`, `liveGnssUsedByDeniedEstimator = false`, `protectedGnssAvailableToEstimatorApi = false`, `protectedGnssUsedByDeniedEstimator = false`, `protectedGnssUsedByHeading = false`, `protectedGnssUsedByStepLength = false`, `protectedGnssUsedByQualityEngine = false`, `protectedGnssUsedByController = false`, `gnssCorrectionApplied = false`, and `firewallMutationSelfTestPassed = true`. Explicit `evaluation_cancelled` cancellation passed as a lifecycle test, not a successful measurement.

Privacy boundaries passed: `rawGroundTruthTrajectoryReturned = false`, `rawDeniedTrajectoryReturned = false`, `rawGnssCoordinatesReturned = false`, `rawTimestampsReturned = false`, and `persistenceUsed = false`. No raw latitude, longitude, altitude, per-fix GT ENU, per-step denied trajectory, timestamp, device identifier, or private filesystem path is recorded here.

Stage 6 implementation, static validation, and physical verification are **COMPLETE/PASS** for the defined evaluation/firewall scope. Evaluation Mode, the Ground Truth Firewall, and Config A evaluation are **IMPLEMENTED**. Baseline-PDR, step-detection, step-length, heading, true-north, and protected-GNSS ground-truth accuracy remain **NOT VALIDATED**. At the Stage 6 boundary, Quality Engine, EKF / Sensor Fusion, PDR + ARCore fusion, GNSS recovery, and full GNSS-denied navigation were **NOT IMPLEMENTED**. Stage 7 was subsequently implemented and is documented below. Overall NAVGUARD physical verification remains **PARTIAL**, and the device baseline remains **NOT FROZEN**.

### Türkçe

Aşama 6 — Değerlendirme Modu + Ground Truth Güvenlik Duvarı, sabitlenen Yapılandırma A kesintili tahmin motoru için korumalı bir değerlendirme yolu uygular. Fiziksel `GPS_PROVIDER` GNSS yalnızca `protected_ground_truth_only` olarak etkin kalır; yazılım-tanımlı tahmin motoru GNSS kesintisi resmî pencere boyunca sürer. Kesintili tahmin motoru API'si yalnızca kabul edilen `TYPE_STEP_DETECTOR` olaylarını ve geçerli gerçek-kuzey-düzeltilmiş `TYPE_ROTATION_VECTOR` telefon heading'lerini alır. Korumalı GNSS kesintili tahmin motoru, heading, adım uzunluğu, Quality Engine veya denetleyici için kullanılamaz ve kullanılmaz; GNSS düzeltmesi uygulanmaz.

Yapılandırma A, sabit, kalibre edilmemiş ve doğrulanmamış 0,75 m adım uzunluğuyla `config_a_baseline_pdr` olarak kalır. Denklemleri `ΔE = 0,75 × sin(ψ)` ve `ΔN = 0,75 × cos(ψ)` olarak korunur. Adım ve heading zaman damgaları nanosaniye `SensorEvent.timestamp` değerleridir. Korumalı GNSS `Location.getElapsedRealtimeNanos`, operasyon penceresi `SystemClock.elapsedRealtimeNanos` kullanır. Gözlenen sözleşme `elapsedRealtimeSharedTimeBaseUsed = true`, `gnssSensorElapsedRealtimeComparisonUsed = true` ve `unsupportedCrossClockComparisonUsed = false` bildirdi. ARCore `Frame` zaman damgaları bu işleme katılmaz.

Kesintili tahmin motoru `latest_valid_heading_at_or_before_step_timestamp` kullanır: `T_step` zamanındaki her kabul edilmiş adım için `T_heading <= T_step` koşulunu sağlayan en büyük zaman damgalı geçerli heading seçilir. Gelecek heading, en-yakın-komşu seçimi, interpolasyon, ortalama, adım-sonrası düzeltme, GNSS heading'i ve korumalı-GT etkisi yasaktır. Ayrı değerlendirme karşılaştırıcısı `latest_estimator_state_at_or_before_ground_truth_timestamp` kullanır, yalnızca finalize edilmiş tahmin motoru durumlarını gözlemler ve interpolasyon veya düzeltme yapmaz. `finalDeniedPreCorrectionErrorM`, herhangi bir düzeltme öncesindeki nihai yatay hatadır; Stage 6 GNSS düzeltmesi uygulamaz.

Stage 6 üç dosya ekleyip üç dosyayı değiştirdi; böylece tam altı uygulama/test yolu oluştu. Fiziksel bug fix sonrasında statik doğrulama geçti: `flutter analyze --no-pub` GEÇTİ, 169/169 test GEÇTİ, `flutter build apk --debug` GEÇTİ ve `git diff --check` GEÇTİ. Beklenmeyen yol yoktu ve dokümantasyon senkronizasyonundan önce staging alanında sıfır yol vardı.

Sabit Değerlendirme Modu oturumu geçti. Otuz kabul edilen korumalı-GT fix'i, 30 eşleşen fix, sıfır eşleşmeyen fix, sıfır mock fix, sıfır kabul edilen/ilişkilendirilen/entegre adım ve `E = 0,0 m, N = 0,0 m` nihai kesintili durumu bildirdi. Nihai yatay yer değiştirme ile nominal entegre yol uzunluğu 0,0 m idi. Medyan yatay hata yaklaşık 0,526 m, p95 hata yaklaşık 2,445 m ve nihai kesintili düzeltme-öncesi hata yaklaşık 0,506 m idi. Bu değerler survey-grade doğruluk ölçümleri değil, oturum gözlemleridir.

İlk hareketli fiziksel test başarısız oldu ve gerçek bir uygulama hatasını açığa çıkardı. On bir adım olayı kabul edildi; ancak 1.531/1.531 geçerli heading örneğine rağmen ilişkilendirilmiş/entegre sayılar sıfır, ilişkilendirilmemiş sayı 11 idi. Stage 6 yalnızca en son teslim edilen heading örneğini tutuyordu. Sensörler-arası callback'ler zamanlama/sıralama farklarıyla teslim edilebildiğinden en son teslim edilen heading gecikmeli adım zaman damgasından daha yeni olabilirken eski nedensel heading'ler artık tutulmuyordu. Stage 4, heading ve adım akışlarını tamponlayıp toplama sonrasında zaman damgası tabanlı nedensel ilişkilendirme yaptığı için etkilenmedi.

İki dosyalık bug fix yalnızca `EvaluationModeDiagnostic.kt` ile `evaluation_mode_test.dart` dosyalarını değiştirdi. Geçerli heading örnekleri ve kabul edilen adım zaman damgaları artık ayrı tamponlanır; ilişkilendirme en büyük `T_heading <= T_step` seçilerek zaman damgası sırasında finalize edilir. Gelecek heading, korumalı GT, interpolasyon, ortalama ve adım-sonrası düzeltme dışlanmış durumda kalır. Nedensel önceki heading, hemen önceki heading, gelecek-heading reddi, çoklu-adım ilişkilendirme/sayaç değişmezleri ve ground-truth mutasyon değişmezliği regresyon testleri geçti. Stage 4 ile Ground Truth Firewall sözleşmesi değişmedi.

Düzeltme-sonrası hareketli yeniden test tanımlı akış kapsamında geçti. Kullanıcı manuel olarak 20 fiziksel adım yürüdü. Çalışma zamanı 16 adım update'i gözledi; beşi resmî değerlendirme penceresinin dışındaydı ve 11'i kabul edildi. Kabul edilen 11 adımın tamamı ilişkilendirilip entegre edildi; ilişkilendirilmemiş, duplicate veya monotonik olmayan kabul edilmiş adım zaman damgası yoktu. Heading akışında 1.531 geçerli örnek ve sıfır duplicate veya monotonik olmayan zaman damgası vardı. Nihai kesintili durum yaklaşık `E = 8,108 m, N = -1,311 m`, yatay yer değiştirme yaklaşık 8,213 m ve nominal entegre yol uzunluğu 8,25 m idi. Kabul edilen 11 olay 20/20 adım-algılama doğruluğu olarak tanımlanmamalıdır; adım-algılama doğruluğu doğrulanmamış olarak kalır.

Hareketli yeniden test 30/30 korumalı-GT fix'ini sıfır eşleşmeyen ve sıfır mock fix ile kabul edip eşleştirdi. Android-bildirilen korumalı-GNSS yatay doğruluk metadata'sı yaklaşık 17,36 m ile 57,12 m arasındaydı; ortalama yaklaşık 22,83 m ve medyan yaklaşık 19,91 m idi. Gözlenen medyan yatay hata yaklaşık 19,99 m, p95 hata yaklaşık 48,24 m ve nihai kesintili düzeltme-öncesi hata yaklaşık 19,78 m idi. Referans belirsizliği yüksek olduğundan bu değerler Yapılandırma A navigasyon doğruluğunu, survey-grade konum hatasını veya korumalı-GNSS ground-truth doğruluğunu değil Değerlendirme Modu ile firewall veri akışını doğrular.

Başarılı Stage 6 fiziksel sonuçları `evaluationModeImplemented = true`, `groundTruthFirewallImplemented = true`, `protectedGroundTruthGnssActive = true`, `softwareDefinedEstimatorGnssDenial = true`, `liveGnssPhysicallyActive = true`, `liveGnssUsedForProtectedGroundTruth = true`, `liveGnssUsedByDeniedEstimator = false`, `protectedGnssAvailableToEstimatorApi = false`, `protectedGnssUsedByDeniedEstimator = false`, `protectedGnssUsedByHeading = false`, `protectedGnssUsedByStepLength = false`, `protectedGnssUsedByQualityEngine = false`, `protectedGnssUsedByController = false`, `gnssCorrectionApplied = false` ve `firewallMutationSelfTestPassed = true` bildirdi. Açık `evaluation_cancelled` iptali başarılı ölçüm olarak değil yaşam döngüsü testi olarak geçti.

Gizlilik sınırları geçti: `rawGroundTruthTrajectoryReturned = false`, `rawDeniedTrajectoryReturned = false`, `rawGnssCoordinatesReturned = false`, `rawTimestampsReturned = false` ve `persistenceUsed = false`. Ham latitude, longitude, altitude, fix-başına GT ENU, adım-başına kesintili rota, zaman damgası, cihaz kimliği veya özel dosya sistemi yolu burada kaydedilmez.

Stage 6 uygulaması, statik doğrulaması ve fiziksel doğrulaması tanımlı değerlendirme/firewall kapsamı için **TAMAMLANDI/GEÇTİ**. Değerlendirme Modu, Ground Truth Güvenlik Duvarı ve Yapılandırma A değerlendirmesi **UYGULANDI**. Baseline-PDR, adım-algılama, adım-uzunluğu, heading, gerçek-kuzey ve korumalı-GNSS ground-truth doğruluğu **DOĞRULANMAMIŞTIR**. Stage 6 sınırında Quality Engine, EKF / Sensör Füzyonu, PDR + ARCore füzyonu, GNSS recovery ve tam GNSS-kesintili navigasyon **UYGULANMAMIŞTI**. Stage 7 daha sonra uygulandı ve aşağıdaki bölümde dokümante edildi. Genel NAVGUARD fiziksel doğrulaması **KISMİ**, cihaz baseline'ı **SABİTLENMEMİŞ** durumda kalır.

---

# 64. Stage 7 Quality Engine + EKF Sensor Fusion Evidence (Aşama 7 Quality Engine + EKF Sensör Füzyonu Kanıtı)

### English

Stage 7 implements Config D profile `config_d_navguard_ekf_v1`. The configuration map is fixed as Config A = baseline PDR, Config B = improved heading, Config C = ARCore relative motion, and Config D = quality-aware PDR + heading + ARCore EKF fusion. This stage does not redefine the earlier configuration scopes.

The EKF state is `[E, N, heading]`: a three-dimensional state containing horizontal East/North position and heading in the `local_enu` coordinate frame. Heading is expressed clockwise from true North, normalized to `[0, 2π)`, and heading measurement innovation is circularly wrapped into `(-π, π]`.

PDR prediction is driven only by accepted step events. It retains the fixed research assumption `L = 0.75 m`, with `ΔE = L × sin(ψ)` and `ΔN = L × cos(ψ)`; heading remains unchanged by a step prediction. The step length is uncalibrated and unvalidated, and accelerometer integration is not used. Heading measurements use true-north-corrected rotation-vector heading with a base measurement sigma of 15 degrees; this is a heuristic, not a calibrated physical noise value.

ARCore measurements come from `Frame.getAndroidSensorPose()`, a local ARCore anchor, and the Stage 5 initial-device-to-ENU transform. The EKF measurement is `[E_AR, N_AR]` with a base position sigma of 0.35 m. That sigma is also heuristic and unvalidated. EKF correction uses Joseph-form covariance updates and explicitly preserves covariance symmetry. The formal flags are `josephCovarianceUpdateUsed = true` and `circularHeadingInnovationUsed = true`; no physical estimator calibration is claimed.

The exact quality enum is `UNKNOWN`, `GOOD`, `USABLE`, `DEGRADED`, `UNRELIABLE`, and `UNAVAILABLE`. The quality covariance multipliers are exactly 1 for `GOOD`, 2 for `USABLE`, and 6 for `DEGRADED`. `UNKNOWN`, `UNRELIABLE`, and `UNAVAILABLE` skip the relevant EKF measurement or prediction update. These are deterministic engineering heuristics and `qualityThresholdsValidated = false`.

Heading and step measurement timing use nanosecond `SensorEvent.timestamp`. `Frame.getTimestamp()` is used only for AR frame duplicate detection, monotonicity, and rate diagnostics; it is not used for fusion ordering or numerical comparison with sensor-event timestamps. After a usable AR pose has been processed and transformed, `SystemClock.elapsedRealtimeNanos()` supplies the AR fusion-order timestamp. The reported contract is `arcoreFrameTimestampUsedForFusionOrdering = false`, `arcoreFusionOrderingTimestampAuthority = SystemClock.elapsedRealtimeNanos`, `arcoreFusionTimestampSemantics = processing_time_after_frame_update_not_camera_capture_time`, `elapsedRealtimeFusionOrderingUsed = true`, and `unsupportedCrossClockComparisonUsed = false`. No hardware-level camera/sensor synchronization is claimed. Equal fusion timestamps resolve deterministically with `heading,step,arcore` priority.

Each formal diagnostic first captures a 30-second event window and then performs deterministic replay (`deterministicOfflineReplayUsed = true`). Heading, step, and ARCore have equal input priority except for the stated equal-timestamp tie-break. No raw trajectory is returned by the result.

Stage 7 added three files and modified three files, for exactly six implementation/test paths. Static validation passed: `flutter analyze --no-pub` PASS, 191/191 tests PASS, `flutter build apk --debug --no-pub` PASS, and `git diff --check` PASS. Unexpected paths were absent and the staging area contained zero paths before documentation synchronization.

The stationary physical session passed on the Xiaomi Redmi Note 9 Pro running Android 12 / API 31. It applied 1,533 heading measurements, zero PDR predictions, and 899 ARCore measurements; accepted step count was zero. Final heading/PDR/ARCore/fusion qualities were `USABLE / UNKNOWN / GOOD / DEGRADED`. Final state was `E = -0.017638648667053784 m`, `N = 0.0030745775441314484 m`, with horizontal displacement `0.017904607057253046 m`; final AR horizontal displacement was `0.025157250614618376 m`. Final East/North variance was `0.00013450452923414788` for each axis and heading variance was `0.00008930152371597315`. The state and covariance were finite, and no false PDR update occurred in this session. The approximately 1.8 cm result is session-only evidence and does not validate accuracy.

The straight-walk physical session passed. It applied 1,532 heading measurements, 14 PDR predictions, and 900 ARCore measurements, with zero steps skipped for no heading and zero heading/PDR/ARCore quality skips. Final qualities were `USABLE / USABLE / GOOD / GOOD`. PDR, ARCore, and fused horizontal displacement were `10.431846962465512 m`, `12.748158649585523 m`, and `12.505097218593054 m`. The final state was `E = 2.9137848617249835 m`, `N = -12.160892821912627 m`, and heading `2.8867908596981624 rad`. This verifies finite fused execution, not ground-truth or absolute accuracy.

The turn/L-shaped physical session passed. It applied 1,532 heading measurements, 18 PDR predictions, and 899 ARCore measurements. Final qualities were `USABLE / USABLE / GOOD / GOOD`. PDR, ARCore, and fused horizontal displacement were `9.969587449490005 m`, `10.230657618967602 m`, and `10.018619917994043 m`. The final state was `E = 6.923941747510453 m`, `N = -7.240978921272237 m`, and heading `3.1102752009064423 rad`; maximum absolute heading innovation was `0.5011230255610553 rad`. The result remained finite without NaN or crash; no absolute-accuracy claim follows.

The deliberate AR-degradation attempt completed as PASS WITH OBSERVATION. It reported `arFrameUpdateCount = 898`, `arTrackingFrameCount = 898`, `arcoreGoodCount = 895`, `arcoreUsableCount = 2`, `arcoreDegradedCount = 0`, `arcoreUnreliableCount = 0`, `arcoreUnavailableCount = 0`, `duplicateArFrameTimestampCount = 1`, and `nonMonotonicArFrameTimestampCount = 0`. Tracking remained active, so degradation/tracking loss was not physically induced. The quality/fallback logic is implemented and statically tested, but physical AR-loss fallback remains **NOT VALIDATED**. The session remained finite and did not crash.

Straight-walk AR innovation norms had mean `0.48777001235280326 m`, median `0.3546481691003017 m`, and maximum `1.4639648406102521 m`. Turn/L-shaped norms had mean `0.44992150986587176 m`, median `0.33393466260756566 m`, and maximum `1.4329170781800478 m`. These are diagnostic observations, not validated measurement-noise estimates. Explicit cancellation returned `navguard_fusion_cancelled` and passed as a lifecycle test, not a successful measurement.

The pre-denial locked GNSS anchor is used only for geomagnetic declination (`preDenialAnchorUsedForDeclination = true`). It is not used for quality, covariance, fusion, heading, PDR, or parameter tuning. Privacy/firewall boundaries passed: `protectedGroundTruthAccessed = false`, `liveGnssRequested = false`, `gnssCorrectionApplied = false`, `rawSensorSamplesReturned = false`, `rawArcorePosesReturned = false`, `rawTrajectoryReturned = false`, `rawTimestampsReturned = false`, `cameraImagesReturned = false`, and `persistenceUsed = false`. No raw GNSS coordinate, sensor sample, ARCore pose/trajectory, camera image, anchor coordinate, location, timestamp, device identifier, or private filesystem path is recorded here.

At the Stage 7 boundary, implementation, static validation, and physical verification were **COMPLETE/PASS** for the defined Config D diagnostic scope. Quality Engine and EKF / Sensor Fusion were **IMPLEMENTED**. Fusion accuracy, quality thresholds, noise parameters, PDR/step-detection/step-length/heading/true-north/ARCore accuracy, and physical AR-loss fallback remained **NOT VALIDATED**. Protected ground truth was not used and live GNSS was not requested. GNSS recovery and the full denied flow were not yet implemented at that boundary; this historical limitation is superseded by the Stage 8 evidence documented immediately below. Overall physical verification remains **PARTIAL**, and the device baseline remains **NOT FROZEN**.

### Türkçe

Aşama 7, Yapılandırma D profili `config_d_navguard_ekf_v1` değerini uygular. Yapılandırma haritası Yapılandırma A = baseline PDR, Yapılandırma B = geliştirilmiş heading, Yapılandırma C = ARCore göreli hareket ve Yapılandırma D = kalite-duyarlı PDR + heading + ARCore EKF füzyonu olarak sabittir. Bu aşama önceki yapılandırma kapsamlarını yeniden tanımlamaz.

EKF durumu `[E, N, heading]` biçimindedir: `local_enu` koordinat çerçevesinde yatay Doğu/Kuzey konumu ve heading içeren üç boyutlu durumdur. Heading gerçek Kuzeyden saat yönünde pozitif, `[0, 2π)` aralığına normalize edilmiş biçimde ifade edilir; heading measurement innovation `(-π, π]` aralığına dairesel olarak sarılır.

PDR prediction yalnızca kabul edilen adım olaylarıyla çalışır. Sabit araştırma varsayımı `L = 0,75 m`, `ΔE = L × sin(ψ)` ve `ΔN = L × cos(ψ)` korunur; adım prediction işlemi heading'i değiştirmez. Adım uzunluğu kalibre edilmemiş ve doğrulanmamıştır; ivmeölçer entegrasyonu kullanılmaz. Heading measurements, 15 derecelik base measurement sigma ile gerçek-kuzey-düzeltilmiş rotation-vector heading kullanır; bu değer kalibre edilmiş fiziksel gürültü değeri değil heuristic'tir.

ARCore measurements; `Frame.getAndroidSensorPose()`, yerel ARCore anchor'ı ve Stage 5 ilk-cihazdan-ENU'ya dönüşümünü kullanır. EKF measurement `[E_AR, N_AR]`, base position sigma 0,35 m'dir. Bu sigma da heuristic ve doğrulanmamıştır. EKF correction Joseph-form kovaryans güncellemelerini kullanır ve kovaryans simetrisini açıkça korur. Resmî bayraklar `josephCovarianceUpdateUsed = true` ve `circularHeadingInnovationUsed = true` değerleridir; fiziksel tahmin motoru kalibrasyonu iddia edilmez.

Kesin quality enum'u `UNKNOWN`, `GOOD`, `USABLE`, `DEGRADED`, `UNRELIABLE` ve `UNAVAILABLE` değerlerinden oluşur. Quality kovaryans çarpanları `GOOD` için tam 1, `USABLE` için 2 ve `DEGRADED` için 6'dır. `UNKNOWN`, `UNRELIABLE` ve `UNAVAILABLE` ilgili EKF measurement veya prediction güncellemesini atlar. Bunlar deterministik mühendislik heuristic'leridir ve `qualityThresholdsValidated = false` değeridir.

Heading ve adım ölçüm zamanlaması nanosaniye `SensorEvent.timestamp` kullanır. `Frame.getTimestamp()` yalnızca AR kare duplicate algılama, monotoniklik ve hız tanıları için kullanılır; füzyon sıralamasında veya sensör-olayı zaman damgalarıyla sayısal karşılaştırmada kullanılmaz. Kullanılabilir AR pozu işlenip dönüştürüldükten sonra `SystemClock.elapsedRealtimeNanos()` AR füzyon-sırası zaman damgasını sağlar. Bildirilen sözleşme `arcoreFrameTimestampUsedForFusionOrdering = false`, `arcoreFusionOrderingTimestampAuthority = SystemClock.elapsedRealtimeNanos`, `arcoreFusionTimestampSemantics = processing_time_after_frame_update_not_camera_capture_time`, `elapsedRealtimeFusionOrderingUsed = true` ve `unsupportedCrossClockComparisonUsed = false` değerleridir. Donanım düzeyinde kamera/sensör senkronizasyonu iddia edilmez. Eşit füzyon zaman damgaları deterministik olarak `heading,step,arcore` önceliğiyle çözülür.

Her resmî tanı önce 30 saniyelik olay penceresini capture eder ve ardından deterministik replay gerçekleştirir (`deterministicOfflineReplayUsed = true`). Heading, adım ve ARCore, belirtilen eşit-zaman-damgası eşitlik bozucusu dışında eşit girdi önceliğine sahiptir. Sonuç ham rota döndürmez.

Stage 7 üç dosya ekleyip üç dosyayı değiştirdi; böylece tam altı uygulama/test yolu oluştu. Statik doğrulama geçti: `flutter analyze --no-pub` GEÇTİ, 191/191 test GEÇTİ, `flutter build apk --debug --no-pub` GEÇTİ ve `git diff --check` GEÇTİ. Beklenmeyen yol yoktu ve dokümantasyon senkronizasyonundan önce staging alanında sıfır yol vardı.

Sabit fiziksel oturum Android 12 / API 31 çalıştıran Xiaomi Redmi Note 9 Pro üzerinde geçti. 1.533 heading measurement, sıfır PDR prediction ve 899 ARCore measurement uyguladı; kabul edilen adım sayısı sıfırdı. Nihai heading/PDR/ARCore/fusion kaliteleri `USABLE / UNKNOWN / GOOD / DEGRADED` idi. Nihai durum `E = -0,017638648667053784 m`, `N = 0,0030745775441314484 m`, yatay yer değiştirme `0,017904607057253046 m`; nihai AR yatay yer değiştirmesi `0,025157250614618376 m` idi. Nihai Doğu/Kuzey varyansı her eksen için `0,00013450452923414788`, heading varyansı `0,00008930152371597315` idi. Durum ve kovaryans sonluydu; bu oturumda yanlış PDR güncellemesi gerçekleşmedi. Yaklaşık 1,8 cm sonuç yalnızca oturum kanıtıdır ve doğruluğu doğrulamaz.

Düz-yürüyüş fiziksel oturumu geçti. Sıfır heading-yok atlaması ve sıfır heading/PDR/ARCore kalite atlamasıyla 1.532 heading measurement, 14 PDR prediction ve 900 ARCore measurement uyguladı. Nihai kaliteler `USABLE / USABLE / GOOD / GOOD` idi. PDR, ARCore ve fused yatay yer değiştirme `10,431846962465512 m`, `12,748158649585523 m` ve `12,505097218593054 m` idi. Nihai durum `E = 2,9137848617249835 m`, `N = -12,160892821912627 m`, heading `2,8867908596981624 rad` oldu. Bu, sonlu fused çalışmayı doğrular; ground-truth veya mutlak doğruluğu doğrulamaz.

Dönüş/L-biçimli fiziksel oturum geçti. 1.532 heading measurement, 18 PDR prediction ve 899 ARCore measurement uyguladı. Nihai kaliteler `USABLE / USABLE / GOOD / GOOD` idi. PDR, ARCore ve fused yatay yer değiştirme `9,969587449490005 m`, `10,230657618967602 m` ve `10,018619917994043 m` idi. Nihai durum `E = 6,923941747510453 m`, `N = -7,240978921272237 m`, heading `3,1102752009064423 rad`; maksimum mutlak heading innovation `0,5011230255610553 rad` oldu. Sonuç NaN veya crash olmadan sonlu kaldı; buradan mutlak-doğruluk iddiası çıkarılamaz.

Kasıtlı AR bozulma denemesi GÖZLEMLE GEÇTİ olarak tamamlandı. `arFrameUpdateCount = 898`, `arTrackingFrameCount = 898`, `arcoreGoodCount = 895`, `arcoreUsableCount = 2`, `arcoreDegradedCount = 0`, `arcoreUnreliableCount = 0`, `arcoreUnavailableCount = 0`, `duplicateArFrameTimestampCount = 1` ve `nonMonotonicArFrameTimestampCount = 0` bildirdi. Tracking etkin kaldığından bozulma/tracking kaybı fiziksel olarak oluşturulamadı. Quality/fallback mantığı uygulandı ve statik olarak test edildi ancak fiziksel AR-kaybı fallback'i **DOĞRULANMAMIŞTIR**. Oturum sonlu kaldı ve crash olmadı.

Düz-yürüyüş AR innovation normları ortalama `0,48777001235280326 m`, medyan `0,3546481691003017 m`, maksimum `1,4639648406102521 m` idi. Dönüş/L-biçimli normlar ortalama `0,44992150986587176 m`, medyan `0,33393466260756566 m`, maksimum `1,4329170781800478 m` idi. Bunlar doğrulanmış measurement-noise tahminleri değil tanısal gözlemlerdir. Açık iptal `navguard_fusion_cancelled` döndürdü ve başarılı ölçüm değil yaşam döngüsü testi olarak geçti.

Kesinti öncesi kilitli GNSS anchor yalnızca geomanyetik declination için kullanılır (`preDenialAnchorUsedForDeclination = true`). Quality, kovaryans, füzyon, heading, PDR veya parametre ayarı için kullanılmaz. Gizlilik/firewall sınırları geçti: `protectedGroundTruthAccessed = false`, `liveGnssRequested = false`, `gnssCorrectionApplied = false`, `rawSensorSamplesReturned = false`, `rawArcorePosesReturned = false`, `rawTrajectoryReturned = false`, `rawTimestampsReturned = false`, `cameraImagesReturned = false` ve `persistenceUsed = false`. Ham GNSS koordinatı, sensör örneği, ARCore pozu/rotası, kamera görüntüsü, anchor koordinatı, konum, zaman damgası, cihaz kimliği veya özel dosya sistemi yolu burada kaydedilmez.

Stage 7 sınırında uygulama, statik doğrulama ve fiziksel doğrulama tanımlı Yapılandırma D tanı kapsamı için **TAMAMLANDI/GEÇTİ** durumundaydı. Quality Engine ve EKF / Sensör Füzyonu **UYGULANMIŞTI**. Füzyon doğruluğu, kalite eşikleri, gürültü parametreleri, PDR/adım-algılama/adım-uzunluğu/heading/gerçek-kuzey/ARCore doğruluğu ve fiziksel AR-kaybı fallback'i **DOĞRULANMAMIŞTI**. Korumalı ground truth kullanılmıyor ve canlı GNSS istenmiyordu. GNSS recovery ve tam kesintili akış bu sınırda henüz uygulanmamıştı; bu tarihsel sınırlama hemen aşağıda belgelenen Stage 8 kanıtıyla aşılmıştır. Genel fiziksel doğrulama **KISMİ**, cihaz baseline'ı **SABİTLENMEMİŞ** durumda kalır.

---

# 65. Stage 8 GNSS Denial / Recovery + Full NAVGUARD Flow Evidence (Aşama 8 GNSS Kesintisi / Geri Kazanım + Tam NAVGUARD Akışı Kanıtı)

### English

Stage 8 implements the first complete deterministic NAVGUARD operational flow. Its states are `IDLE`, `ACQUIRING_GNSS`, `NORMAL_GNSS`, `DENIED_NAVGUARD`, `RECOVERY_PENDING`, `RECOVERED_GNSS`, `COMPLETED`, `CANCELLED`, and `FAILED`. The successful sequence is `ACQUIRING_GNSS → NORMAL_GNSS → DENIED_NAVGUARD → RECOVERY_PENDING → RECOVERED_GNSS → COMPLETED`.

Denial is software-defined: `softwareDefinedGnssDenialImplemented = true`, `rfInterferenceUsed = false`, and `gnssSpoofingUsed = false`. This is not RF jamming. The physical `GPS_PROVIDER` listener may remain active during denial, but fixes generated in `DENIED_NAVGUARD` are quarantined before any estimator-facing API. The denial firewall keeps GNSS unavailable to and unused by the estimator, heading, PDR, Quality Engine, and controller. Protected ground truth is not accessed, and mutation invariance is implemented and passed.

The formal denial evidence is `deniedGnssAvailableToEstimator = false`, `deniedGnssUsedByEstimator = false`, `deniedGnssUsedByHeading = false`, `deniedGnssUsedByPdr = false`, `deniedGnssUsedByQualityEngine = false`, `deniedGnssUsedByController = false`, `deniedGnssUsedByEstimatorCount = 0`, `denialGnssMutationInvariancePassed = true`, and `protectedGroundTruthAccessed = false`.

Operational GNSS uses `GPS_PROVIDER` only. GNSS fix generation time is `Location.getElapsedRealtimeNanos`; state-operation boundaries use `SystemClock.elapsedRealtimeNanos`. The fixed operational horizontal-accuracy threshold is 50 m and remains an engineering heuristic with `gnssAccuracyThresholdValidated = false`. Initial acquisition requires three consecutive acceptable fresh fixes. Recovery also requires three consecutive acceptable fixes generated at or after the recovery gate. A pre-gate fix cannot become eligible merely because its callback arrives later. The formal gate contract is `recoveryUsesFixGenerationTime = true`, `preGateGnssFixAcceptedForRecovery = false`, `recoveryRequiresFreshFixes = true`, and `recoveryRequiresConsecutiveFixes = true`. GNSS bearing and course are not used.

At denial entry, the latest accepted `NORMAL_GNSS` local ENU becomes the horizontal denial origin. The EKF begins at `[E_denial_origin, N_denial_origin, latest true heading]`; it does not reset to ENU zero. ARCore relative displacement starts at zero at the transition and is offset by the denial origin before EKF input.

After three qualifying recovery fixes, the horizontal navigation state is explicitly reset to recovered-GPS local ENU while heading remains sensor-derived: `recoveryPositionResetApplied = true` and `gnssBearingUsedForRecovery = false`. Recovery correction distance is the distance between the pre-recovery denied estimate and the recovered GNSS position; it is not ground-truth error.

Config D retains the Stage 7 architecture: EKF state `[E,N,heading]`, `TYPE_STEP_DETECTOR` PDR, true-north-corrected `TYPE_ROTATION_VECTOR` heading, ARCore relative ENU position, Quality Engine gating, Joseph-form covariance update, and circular heading innovation. `Frame.getTimestamp()` is not used for cross-source fusion ordering. ARCore fusion ordering uses `SystemClock.elapsedRealtimeNanos()` captured after usable pose conversion. The formal contract remains `arcoreFrameTimestampUsedForFusionOrdering = false` and `unsupportedCrossClockComparisonUsed = false`; no camera/sensor hardware synchronization is claimed.

Stage 8 added `FullNavguardFlowDiagnostic.kt`, `full_navguard_flow.dart`, and `full_navguard_flow_test.dart`, and modified `MainActivity.kt`, `main.dart`, and `widget_test.dart`. The targeted bugfix changed existing Stage 8 paths only. Post-fix static validation passed: `flutter analyze --no-pub` PASS, 211/211 tests PASS, `flutter build apk --debug --no-pub` PASS, and `git diff --check` PASS. The six implementation/test paths remained unstaged with no unexpected path.

The stationary full-flow session passed on the Xiaomi Redmi Note 9 Pro running Android 12 / API 31. It reported `finalState = COMPLETED`, `finalNavigationMode = GNSS_RECOVERED`, `stateTransitionCount = 6`, four accepted normal-GNSS fixes, 30 denied GNSS fixes, zero denied-GNSS estimator uses, 1,532 applied heading measurements, zero PDR predictions, and 897 applied ARCore measurements. Pre-recovery denied horizontal displacement from the denial origin was `0.007818049471611195 m`. End-of-denial heading/PDR/ARCore/fusion qualities were `USABLE / UNKNOWN / GOOD / DEGRADED`. Mutation invariance passed and three consecutive recovery fixes were achieved. No false PDR movement was observed in this session; full-flow accuracy remains not validated.

The initial walking session exposed a real Stage 8 integration bug and is retained as evidence. It applied 1,532 heading measurements and 900 ARCore measurements, but applied zero PDR predictions. Thirteen accepted step opportunities were all recorded as `deniedPdrPredictionsSkippedNoHeading`, with zero quality skips. Rotation vector, step detector, and the device were already known to work, and Stage 7 had integrated steps on the same device.

The exact root cause was callback-order-dependent heading retention. Stage 8 kept only the latest delivered heading and attempted step association immediately. In the representative sequence `heading@120`, `step generated @125`, `heading@130 delivered`, then delayed `step@125 callback`, only `heading@130` remained visible. That sample was correctly rejected as future relative to the step, but the discarded causal `heading@120` was no longer available. This is the same physical integration bug class encountered in Stage 6. Stage 7 avoided it by buffering and deterministically replaying events.

The targeted fix buffers heading and step histories and finalizes association using sensor timestamps. For every accepted denied step, it selects the greatest valid heading satisfying `T_heading <= T_step`; future headings, nearest-sample substitution, interpolation, GNSS bearing, and processing-time substitution remain prohibited. Replay ordering is timestamp-first, with equal timestamps resolved as `HEADING → STEP → ARCORE_POSITION`. Callback delivery order no longer determines the causal association.

Regression coverage passed for a delayed step callback, multiple delayed steps, an equal heading/step timestamp, a future-only heading, a representative stream of approximately 1,500 heading samples with reordered delivery, and the denied PDR counter invariant. The formal invariant is `deniedPdrPredictionsApplied + deniedPdrPredictionsSkippedNoHeading + deniedPdrPredictionsSkippedByQuality = deniedAcceptedStepOpportunityCount`.

The targeted physical walking retest passed. It reported `finalState = COMPLETED`, `finalNavigationMode = GNSS_RECOVERED`, state-transition count six, four accepted and zero rejected normal-GNSS fixes, 30 denied fixes, zero denied-GNSS estimator uses, 1,533 applied heading measurements, 16 applied PDR predictions, zero no-heading skips, zero quality skips, 16 accepted step opportunities, and 899 applied ARCore measurements. Thus all 16 accepted step opportunities became predictions. This validates the targeted causal-association bugfix on this session; it does not validate step-detection accuracy.

Normal-GNSS Android-reported horizontal accuracy in the retest had minimum `32.01649475097656 m`, mean `35.32255458831787 m`, median `34.990304946899414 m`, and maximum `39.293113708496094 m`. These values are provider metadata, not independently measured coordinate errors.

At the end of denial, the retest qualities were heading `USABLE`, PDR `USABLE`, ARCore `GOOD`, and fusion `GOOD`. These are deterministic rule-based states, not calibrated probabilities. The pre-recovery denied estimate was `E = 103.97400837769132 m`, `N = 10.243276245931213 m`, heading `0.1237035657125761 rad`, and displacement from the denial origin `13.992556202762895 m`. PDR ended at `E = 103.85695523709553 m`, `N = 8.193154012611815 m`; ARCore ended at `E = 103.96813220591123 m`, `N = 10.440114136222226 m`. These are operational local-ENU estimates; absolute E/N relative to the anchor is not an accuracy measurement.

Recovery counters were corrected to a single gate scope. `recoveryCandidateFixCount`, `recoveryAcceptedFixCount`, and `recoveryRejectedFixCount` refer only to `RECOVERY_PENDING`, and the required invariant is `accepted + rejected = candidate`. The retest reported `recoveryCandidateFixCount = 4`, `recoveryAcceptedFixCount = 3`, and `recoveryRejectedFixCount = 1`, so `3 + 1 = 4` passed. The subsequent `RECOVERED_GNSS` observation period separately reported `recoveredObservationAcceptedFixCount = 5` and `recoveredObservationRejectedFixCount = 0`. Three consecutive good fixes were required and achieved.

Recovery-gate Android-reported horizontal accuracy had minimum `20.726154327392578 m`, mean `21.397263209025066 m`, median `20.90433120727539 m`, and maximum `22.561304092407227 m`. Recovered GNSS was approximately `E = 30.836014739161925 m`, `N = 17.08281031058 m`. The observed recovery correction was `73.45709863376757 m`. Final recovered position was approximately `E = 31.33199100301342 m`, `N = 17.120569488070675 m`, or `35.70444733935495 m` horizontally from the anchor.

The approximately 73.46 m correction is not a validated navigation error and must not be called estimator accuracy. It is only the distance between the pre-recovery denied estimate and operational recovered GNSS position. Normal-GNSS reported accuracy was approximately 32–39 m and recovery-gate reported accuracy approximately 21–23 m; no protected ground truth was used. This observation is retained for Stage 9 benchmark analysis.

Final recovered horizontal variance was `528.8254157129122 m²` on both East and North, and heading variance was `0.00014583460534085057 rad²`. These values follow the Stage 8 recovery-reset contract and reported GNSS accuracy; they are not calibrated statistical uncertainty.

The physical retest preserved the firewall: denied GNSS used-by-estimator count was zero; all denied-GNSS availability/use flags for estimator, heading, PDR, Quality Engine, and controller were false; mutation invariance passed; protected ground truth was not accessed; and GNSS bearing was not used. Explicit cancellation returned `full_navguard_flow_cancelled` and passed as lifecycle validation, not a successful navigation measurement.

Privacy boundaries passed: `rawGnssCoordinatesReturned = false`, `rawGnssFixesReturned = false`, `rawSensorSamplesReturned = false`, `rawArcorePosesReturned = false`, `rawTrajectoryReturned = false`, `rawTimestampsReturned = false`, `cameraImagesReturned = false`, and `persistenceUsed = false`. No device serial or ADB identifier is recorded.

Stage 8 implementation is **COMPLETE**, static validation is **PASS**, and scoped physical verification is **PASS**. Software-defined GNSS denial, denied-GNSS quarantine, Config D during denial, GNSS recovery, full GNSS-denied navigation, and the full-flow state machine are **IMPLEMENTED**. Full-flow accuracy, GNSS-recovery accuracy, the GNSS accuracy threshold, fusion accuracy, quality thresholds, noise parameters, step-detection accuracy, step length, heading accuracy, true-north accuracy, ARCore position accuracy, and covariance calibration remain **NOT VALIDATED**. Protected ground truth was not accessed; RF interference and GNSS spoofing were not used. Overall NAVGUARD physical verification remains **PARTIAL**, and the device baseline remains **NOT FROZEN**.

### Türkçe

Aşama 8 ilk tam deterministik NAVGUARD operasyon akışını uygular. Durumları `IDLE`, `ACQUIRING_GNSS`, `NORMAL_GNSS`, `DENIED_NAVGUARD`, `RECOVERY_PENDING`, `RECOVERED_GNSS`, `COMPLETED`, `CANCELLED` ve `FAILED` değerleridir. Başarılı dizi `ACQUIRING_GNSS → NORMAL_GNSS → DENIED_NAVGUARD → RECOVERY_PENDING → RECOVERED_GNSS → COMPLETED` biçimindedir.

Kesinti yazılım-tanımlıdır: `softwareDefinedGnssDenialImplemented = true`, `rfInterferenceUsed = false` ve `gnssSpoofingUsed = false`. Bu RF jamming değildir. Fiziksel `GPS_PROVIDER` dinleyicisi kesinti sırasında etkin kalabilir ancak `DENIED_NAVGUARD` içinde üretilen fix'ler tahmin motoruna dönük herhangi bir API'den önce karantinaya alınır. Kesinti firewall'u GNSS'i tahmin motoru, heading, PDR, Quality Engine ve denetleyici için kullanılamaz ve kullanılmamış tutar. Korumalı ground truth'a erişilmez; mutasyon değişmezliği uygulanmış ve geçmiştir.

Resmî kesinti kanıtı `deniedGnssAvailableToEstimator = false`, `deniedGnssUsedByEstimator = false`, `deniedGnssUsedByHeading = false`, `deniedGnssUsedByPdr = false`, `deniedGnssUsedByQualityEngine = false`, `deniedGnssUsedByController = false`, `deniedGnssUsedByEstimatorCount = 0`, `denialGnssMutationInvariancePassed = true` ve `protectedGroundTruthAccessed = false` değerleridir.

Operasyonel GNSS yalnızca `GPS_PROVIDER` kullanır. GNSS fix üretim zamanı `Location.getElapsedRealtimeNanos`, durum-operasyon sınırları `SystemClock.elapsedRealtimeNanos` kullanır. Sabit operasyonel yatay-doğruluk eşiği 50 m'dir ve `gnssAccuracyThresholdValidated = false` ile doğrulanmamış mühendislik heuristic'i olarak kalır. İlk edinim art arda üç kabul edilebilir taze fix gerektirir. Recovery de recovery gate'de veya sonrasında üretilmiş art arda üç kabul edilebilir fix gerektirir. Gate-öncesi fix, callback'i daha sonra geldiği için uygun hale gelemez. Resmî gate sözleşmesi `recoveryUsesFixGenerationTime = true`, `preGateGnssFixAcceptedForRecovery = false`, `recoveryRequiresFreshFixes = true` ve `recoveryRequiresConsecutiveFixes = true` değerleridir. GNSS bearing veya course kullanılmaz.

Kesinti girişinde en son kabul edilen `NORMAL_GNSS` yerel ENU yatay kesinti başlangıcı olur. EKF `[E_kesinti_başlangıcı, N_kesinti_başlangıcı, son gerçek heading]` durumundan başlar; ENU sıfıra resetlenmez. ARCore göreli yer değiştirmesi geçişte sıfırdan başlar ve EKF girdisinden önce kesinti başlangıcıyla offsetlenir.

Uygun üç recovery fix'inden sonra yatay navigasyon durumu recovered-GPS yerel ENU'ya açıkça resetlenir; heading sensör-türevli kalır: `recoveryPositionResetApplied = true` ve `gnssBearingUsedForRecovery = false`. Recovery correction mesafesi, recovery-öncesi kesintili tahmin ile recovered GNSS konumu arasındaki mesafedir; ground-truth hatası değildir.

Yapılandırma D, Stage 7 mimarisini korur: EKF durumu `[E,N,heading]`, `TYPE_STEP_DETECTOR` PDR, gerçek-kuzey-düzeltilmiş `TYPE_ROTATION_VECTOR` heading, ARCore göreli ENU konumu, Quality Engine gating, Joseph-form kovaryans güncellemesi ve dairesel heading innovation. `Frame.getTimestamp()` cross-source füzyon sıralamasında kullanılmaz. ARCore füzyon sıralaması kullanılabilir poz dönüşümünden sonra alınan `SystemClock.elapsedRealtimeNanos()` değerini kullanır. Resmî sözleşme `arcoreFrameTimestampUsedForFusionOrdering = false` ve `unsupportedCrossClockComparisonUsed = false` olarak kalır; kamera/sensör donanım senkronizasyonu iddia edilmez.

Stage 8 `FullNavguardFlowDiagnostic.kt`, `full_navguard_flow.dart` ve `full_navguard_flow_test.dart` dosyalarını ekledi; `MainActivity.kt`, `main.dart` ve `widget_test.dart` dosyalarını değiştirdi. Hedefli bugfix yalnızca mevcut Stage 8 yollarını değiştirdi. Düzeltme-sonrası statik doğrulama geçti: `flutter analyze --no-pub` GEÇTİ, 211/211 test GEÇTİ, `flutter build apk --debug --no-pub` GEÇTİ ve `git diff --check` GEÇTİ. Altı uygulama/test yolu beklenmeyen yol olmadan unstaged kaldı.

Sabit tam-akış oturumu Android 12 / API 31 çalıştıran Xiaomi Redmi Note 9 Pro üzerinde geçti. `finalState = COMPLETED`, `finalNavigationMode = GNSS_RECOVERED`, `stateTransitionCount = 6`, dört kabul edilen normal-GNSS fix'i, 30 kesinti GNSS fix'i, sıfır kesinti-GNSS tahmin motoru kullanımı, 1.532 uygulanan heading measurement, sıfır PDR prediction ve 897 uygulanan ARCore measurement bildirdi. Kesinti başlangıcından recovery-öncesi kesintili yatay yer değiştirme `0,007818049471611195 m` idi. Kesinti-sonu heading/PDR/ARCore/fusion kaliteleri `USABLE / UNKNOWN / GOOD / DEGRADED` idi. Mutasyon değişmezliği geçti ve art arda üç recovery fix'i elde edildi. Bu oturumda false PDR hareketi gözlenmedi; tam-akış doğruluğu doğrulanmamış olarak kalır.

İlk yürüyüş oturumu gerçek bir Stage 8 entegrasyon hatasını açığa çıkardı ve kanıt olarak korunur. 1.532 heading measurement ve 900 ARCore measurement uygulandı ancak sıfır PDR prediction uygulandı. Kabul edilen 13 adım fırsatının tamamı `deniedPdrPredictionsSkippedNoHeading` olarak kaydedildi; kalite atlaması sıfırdı. Rotation vector, step detector ve cihazın çalıştığı zaten biliniyordu; Stage 7 aynı cihazda adımları entegre etmişti.

Kesin kök neden callback-sırasına bağımlı heading saklamaydı. Stage 8 yalnızca en son teslim edilen heading'i tutuyor ve adım ilişkilendirmesini hemen yapıyordu. Temsilî `heading@120`, `step @125 üretildi`, `heading@130 teslim edildi`, ardından gecikmiş `step@125 callback` dizisinde yalnızca `heading@130` görünür kaldı. Bu örnek adıma göre gelecek olduğu için doğru biçimde reddedildi ancak atılmış nedensel `heading@120` artık yoktu. Bu, Stage 6'da karşılaşılan aynı fiziksel entegrasyon hata sınıfıdır. Stage 7 tamponlama ve deterministik replay ile bunu yaşamıyordu.

Hedefli düzeltme heading ve adım geçmişlerini tamponlar, ilişkilendirmeyi sensör zaman damgalarıyla finalize eder. Kabul edilen her kesinti adımı için `T_heading <= T_step` koşulunu sağlayan en büyük geçerli heading seçilir; gelecek heading, en-yakın örnek ikamesi, interpolasyon, GNSS bearing ve işlem-zamanı ikamesi yasak kalır. Replay zaman damgasına göre sıralanır; eşit zaman damgaları `HEADING → STEP → ARCORE_POSITION` olarak çözülür. Callback teslim sırası artık nedensel ilişkilendirmeyi belirlemez.

Regresyon kapsamı; gecikmiş adım callback'i, çoklu gecikmiş adımlar, eşit heading/adım zaman damgası, yalnızca gelecek heading, teslim sırası değiştirilmiş yaklaşık 1.500 heading örnekli temsilî akış ve kesinti PDR sayaç değişmezi için geçti. Resmî değişmez `deniedPdrPredictionsApplied + deniedPdrPredictionsSkippedNoHeading + deniedPdrPredictionsSkippedByQuality = deniedAcceptedStepOpportunityCount` biçimindedir.

Hedefli fiziksel yürüyüş yeniden testi geçti. `finalState = COMPLETED`, `finalNavigationMode = GNSS_RECOVERED`, altı durum geçişi, dört kabul ve sıfır ret normal-GNSS fix'i, 30 kesinti fix'i, sıfır kesinti-GNSS tahmin motoru kullanımı, 1.533 uygulanan heading measurement, 16 uygulanan PDR prediction, sıfır heading-yok atlaması, sıfır kalite atlaması, kabul edilen 16 adım fırsatı ve 899 uygulanan ARCore measurement bildirdi. Böylece kabul edilen 16 adım fırsatının tamamı prediction oldu. Bu, hedefli nedensel-ilişkilendirme bugfix'ini bu oturumda doğrular; adım-algılama doğruluğunu doğrulamaz.

Yeniden testte normal-GNSS Android-bildirilen yatay doğruluk minimum `32,01649475097656 m`, ortalama `35,32255458831787 m`, medyan `34,990304946899414 m` ve maksimum `39,293113708496094 m` idi. Bunlar bağımsız ölçülmüş koordinat hataları değil provider metadata'sıdır.

Kesinti sonunda yeniden test kaliteleri heading `USABLE`, PDR `USABLE`, ARCore `GOOD` ve fusion `GOOD` idi. Bunlar kalibre edilmiş olasılıklar değil deterministik kural-tabanlı durumlardır. Recovery-öncesi kesintili tahmin `E = 103,97400837769132 m`, `N = 10,243276245931213 m`, heading `0,1237035657125761 rad` ve kesinti başlangıcından yer değiştirme `13,992556202762895 m` idi. PDR `E = 103,85695523709553 m`, `N = 8,193154012611815 m`; ARCore `E = 103,96813220591123 m`, `N = 10,440114136222226 m` konumunda sonlandı. Bunlar operasyonel yerel-ENU tahminleridir; anchor'a göre mutlak E/N doğruluk ölçümü değildir.

Recovery sayaçları tek gate kapsamına düzeltildi. `recoveryCandidateFixCount`, `recoveryAcceptedFixCount` ve `recoveryRejectedFixCount` yalnızca `RECOVERY_PENDING` durumunu ifade eder; gerekli değişmez `kabul + ret = aday` biçimindedir. Yeniden test `recoveryCandidateFixCount = 4`, `recoveryAcceptedFixCount = 3` ve `recoveryRejectedFixCount = 1` bildirdi; `3 + 1 = 4` geçti. Sonraki `RECOVERED_GNSS` gözlem dönemi ayrı olarak `recoveredObservationAcceptedFixCount = 5` ve `recoveredObservationRejectedFixCount = 0` bildirdi. Art arda üç iyi fix gerekliydi ve elde edildi.

Recovery-gate Android-bildirilen yatay doğruluk minimum `20,726154327392578 m`, ortalama `21,397263209025066 m`, medyan `20,90433120727539 m` ve maksimum `22,561304092407227 m` idi. Recovered GNSS yaklaşık `E = 30,836014739161925 m`, `N = 17,08281031058 m` oldu. Gözlenen recovery correction `73,45709863376757 m` idi. Nihai recovered konum yaklaşık `E = 31,33199100301342 m`, `N = 17,120569488070675 m`; anchor'dan yatay `35,70444733935495 m` idi.

Yaklaşık 73,46 m correction doğrulanmış navigasyon hatası değildir ve tahmin motoru doğruluğu olarak adlandırılmamalıdır. Yalnızca recovery-öncesi kesintili tahmin ile operasyonel recovered GNSS konumu arasındaki mesafedir. Normal-GNSS bildirilen doğruluğu yaklaşık 32–39 m, recovery-gate bildirilen doğruluğu yaklaşık 21–23 m idi; korumalı ground truth kullanılmadı. Bu gözlem Stage 9 benchmark analizi için korunur.

Nihai recovered yatay varyans Doğu ve Kuzeyde `528,8254157129122 m²`, heading varyansı `0,00014583460534085057 rad²` idi. Bu değerler Stage 8 recovery-reset sözleşmesi ile bildirilen GNSS doğruluğundan gelir; kalibre edilmiş istatistiksel belirsizlik değildir.

Fiziksel yeniden test firewall'u korudu: kesinti GNSS kullanılan-tahmin-motoru sayısı sıfırdı; tahmin motoru, heading, PDR, Quality Engine ve denetleyici için tüm kesinti-GNSS kullanılabilirlik/kullanım bayrakları false idi; mutasyon değişmezliği geçti; korumalı ground truth'a erişilmedi ve GNSS bearing kullanılmadı. Açık iptal `full_navguard_flow_cancelled` döndürdü ve başarılı navigasyon ölçümü değil yaşam döngüsü doğrulaması olarak geçti.

Gizlilik sınırları geçti: `rawGnssCoordinatesReturned = false`, `rawGnssFixesReturned = false`, `rawSensorSamplesReturned = false`, `rawArcorePosesReturned = false`, `rawTrajectoryReturned = false`, `rawTimestampsReturned = false`, `cameraImagesReturned = false` ve `persistenceUsed = false`. Cihaz seri numarası veya ADB kimliği kaydedilmez.

Stage 8 uygulaması **TAMAMLANDI**, statik doğrulaması **GEÇTİ** ve kapsamı belirli fiziksel doğrulaması **GEÇTİ**. Yazılım-tanımlı GNSS kesintisi, kesinti-GNSS karantinası, kesinti sırasında Yapılandırma D, GNSS recovery, tam GNSS-kesintili navigasyon ve tam-akış durum makinesi **UYGULANDI**. Tam-akış doğruluğu, GNSS-recovery doğruluğu, GNSS doğruluk eşiği, füzyon doğruluğu, kalite eşikleri, gürültü parametreleri, adım-algılama doğruluğu, adım uzunluğu, heading doğruluğu, gerçek-kuzey doğruluğu, ARCore konum doğruluğu ve kovaryans kalibrasyonu **DOĞRULANMAMIŞTIR**. Korumalı ground truth'a erişilmedi; RF paraziti veya GNSS spoofing kullanılmadı. Genel NAVGUARD fiziksel doğrulaması **KISMİ**, cihaz baseline'ı **SABİTLENMEMİŞ** durumdadır.

---

# 66. Stage 9A Matched A/B/C/D Benchmark Evidence (Aşama 9A Eşleştirilmiş A/B/C/D Benchmark Kanıtı)

### English

Stage 9A — Matched A/B/C/D Benchmark + Protected Ground Truth is **IMPLEMENTED**. The benchmark captures heading events, step events, ARCore relative ENU, and protected physical `GPS_PROVIDER` observations once in the same denied-navigation session, then replays four independent estimators from an identical denial origin. The configurations are not separate walks.

The frozen configurations are:

* Config A — `config_a_deterministic_pdr`: `TYPE_STEP_DETECTOR`, fixed 0.75 m step length, and latest causal true-north heading; no EKF, no ARCore position, and no Quality Engine covariance behavior.
* Config B — `config_b_pdr_heading_ekf`: PDR, true-north heading, heading EKF, circular heading innovation, and Joseph covariance; no ARCore input.
* Config C — `config_c_arcore_relative`: common denial origin plus ARCore relative ENU; no PDR and no position EKF.
* Config D — `config_d_navguard_ekf_v1`: PDR, true-north heading, ARCore relative ENU, the Quality Engine, EKF, Joseph covariance, and circular heading innovation.

The Ground Truth Firewall passed. `protectedGroundTruthAvailableToEstimators`, every `protectedGroundTruthUsedByConfig*` flag, and `protectedGroundTruthUsedByQualityEngine` are false. `groundTruthCorrectionApplied` and `gnssRecoveryAppliedDuringBenchmark` are false. Mutation and removal invariance passed. Protected GPS is evaluation-only and reaches the comparator only after estimator histories are finalized.

The comparator selects the latest estimator snapshot satisfying `T_estimator <= T_gt`. It never uses a future state or interpolation, and every Config has an initial denial snapshot. The primary metric is `matched_session_median_horizontal_error_m`, the primary comparison is `config_d_vs_config_a`, and p95 uses the deterministic `nearest_rank` policy.

Static validation passed across exactly six implementation/test paths: `flutter analyze --no-pub`, 230/230 tests, `flutter build apk --debug --no-pub`, and `git diff --check` passed; no unexpected path was present and staging was empty.

Five physical matched sessions completed with `benchmarkSessionValid = true`. No valid session was selectively removed, and negative outcomes are retained:

| Session | Config A median (m) | Config B median (m) | Config C median (m) | Config D median (m) | D vs A | Target met | Protected-GT reported accuracy median (m) |
| ------- | ------------------- | ------------------- | ------------------- | ------------------- | ------ | ---------- | ----------------------------------------- |
| 1 | 12.561945121444253 | 12.514907481594365 | 12.726737383050589 | 12.185632073247444 | +2.9956590683907147% | No | 9.10942268371582 |
| 2 | 39.91989974980391 | 39.85436801118203 | 38.62589905258437 | 39.01836083458484 | +2.2583696874727224% | No | 7.354877471923828 |
| 3 | 7.385470679117635 | 7.450695721587582 | 9.068059287914132 | 8.854542536862272 | -19.89137756512158% | No | 10.32039499282837 |
| 4 | 5.489879483076921 | 5.537451914072966 | 9.163584244845294 | 7.674902856418617 | -39.80093515854474% | No | 4.68110466003418 |
| 5 | 5.581047781899263 | 5.795966420799285 | 6.086691642081835 | 5.644477312321822 | -1.1365165270269924% | No | 4.203737020492554 |

Session 1 showed a small D advantage, but the difference was small relative to the reported GNSS reference uncertainty; the reported accuracy range was approximately 5.9603–14.5096 m. Session 2 placed all Config medians near 39–40 m, suggesting a possible common-mode reference/origin contribution that cannot be diagnosed definitively from aggregate-only data. Session 3 had D worse than A but better than C. Session 4 had A strongly outperform C; D recovered substantially relative to C but remained worse than A. Session 5 had A and D very close relative to reference uncertainty. These interpretations are session-specific and do not establish universal causes.

Each Config matched 149 protected-GT observations (`29 + 30 + 30 + 30 + 30`). There were 89 accepted step opportunities (`14 + 17 + 24 + 15 + 19`); Config A applied all 89, with zero missing-causal-heading skips, and Config D also had zero no-heading skips in all sessions. Approximately 7,659 heading measurements (`1532 + 1532 + 1532 + 1531 + 1532`) and 4,499 Config D ARCore measurements (`900 + 900 + 899 + 900 + 900`) were used.

D outperformed A in 2/5 sessions and underperformed A in 3/5. It exceeded A by at least 20% in 0/5 sessions: **TARGET NOT MET**. The paired D-vs-A improvements were approximately +2.996%, +2.258%, -19.891%, -39.801%, and -1.137%; their median was approximately -1.14% and mean approximately -11.11%. The median of session-level median errors was approximately 7.3855 m for A, 7.4507 m for B, 9.1636 m for C, and 8.8545 m for D. These are descriptive cross-session summaries, not population-level statistically validated accuracy.

B-vs-A session changes were approximately +0.37%, +0.16%, -0.88%, -0.87%, and -3.85%; adding the current heading EKF alone did not provide a material or consistent improvement in these five sessions. C-vs-A changes were approximately -1.31%, +3.24%, -22.78%, -66.92%, and -9.06%; ARCore-relative-only Config C generally did not outperform deterministic PDR in this benchmark. D-vs-C changes were approximately +4.25%, -1.02%, +2.35%, +16.25%, and +7.27%; D outperformed C in 4/5 sessions, with approximately +4.25% median paired improvement. None of these findings is universal.

The approved scientific conclusion is: NAVGUARD demonstrated functional GNSS-denied navigation and matched multi-configuration evaluation, but the predefined >=20% Config D versus Config A median-error improvement target was not met in the five-session physical benchmark. The experiment does not demonstrate systematic Config D superiority over Config A.

Protected Ground Truth uses handset `GPS_PROVIDER`. It is not survey-grade ground truth, RTK GNSS, motion-capture ground truth, or total-station ground truth. Reported session-median accuracy ranged approximately 4.2–10.3 m, so differences materially smaller than the reference uncertainty require caution. `protectedGroundTruthAccuracyValidated` and benchmark accuracy remain false / **NOT VALIDATED**.

Plausible contributors—not proven causes—include the uncalibrated fixed 0.75 m step length, ARCore-to-ENU alignment uncertainty, true-heading uncertainty, heuristic Quality Engine thresholds, heuristic EKF noise parameters, especially the uncalibrated `BASE_ARCORE_POSITION_SIGMA_M = 0.35 m`, the short 30-second horizon, and handset-GNSS uncertainty. Config A may remain competitive in short pedestrian windows because dead-reckoning drift has limited time to accumulate; no long-duration benchmark was performed.

The five sessions are frozen as the current evaluation set. ARCore sigma, step sigma, heading sigma, quality thresholds, stride, or other fusion parameters must not be tuned from these outcomes and then evaluated on the same sessions as if they were independent validation. Any future tuning requires new independent physical validation sessions.

Privacy passed: `rawGnssCoordinatesReturned = false`, `rawProtectedGroundTruthReturned = false`, `rawSensorSamplesReturned = false`, `rawArcorePosesReturned = false`, `rawTrajectoryReturned = false`, `rawTimestampsReturned = false`, `cameraImagesReturned = false`, and `persistenceUsed = false`. Raw benchmark data is not added to the repository.

Stage 9B — Live Map NAVGUARD Demo is now **IMPLEMENTED AND PHYSICALLY VERIFIED** for its defined integration scope, as recorded in Section 67. This does not change the Stage 9A benchmark conclusion. Stage 9C — Final UI / Documentation / Demo Packaging / Final Project Closure is next and is not complete.

### Türkçe

Aşama 9A — Eşleştirilmiş A/B/C/D Benchmark + Korunan Referans Konum **UYGULANDI**. Benchmark aynı kesintili-navigasyon oturumunda heading olaylarını, adım olaylarını, ARCore göreli ENU'yu ve korumalı fiziksel `GPS_PROVIDER` gözlemlerini bir kez yakalar; ardından aynı kesinti başlangıcından dört bağımsız tahmin motorunu replay eder. Yapılandırmalar ayrı yürüyüşler değildir.

Sabitlenen yapılandırmalar şunlardır:

* Yapılandırma A — `config_a_deterministic_pdr`: `TYPE_STEP_DETECTOR`, sabit 0,75 m adım uzunluğu ve en yeni nedensel gerçek-kuzey heading; EKF, ARCore konumu ve Quality Engine kovaryans davranışı yoktur.
* Yapılandırma B — `config_b_pdr_heading_ekf`: PDR, gerçek-kuzey heading, heading EKF, dairesel heading innovation ve Joseph kovaryans; ARCore girdisi yoktur.
* Yapılandırma C — `config_c_arcore_relative`: ortak kesinti başlangıcı artı ARCore göreli ENU; PDR ve konum EKF'si yoktur.
* Yapılandırma D — `config_d_navguard_ekf_v1`: PDR, gerçek-kuzey heading, ARCore göreli ENU, Quality Engine, EKF, Joseph kovaryans ve dairesel heading innovation.

Ground Truth Güvenlik Duvarı geçti. `protectedGroundTruthAvailableToEstimators`, bütün `protectedGroundTruthUsedByConfig*` bayrakları ve `protectedGroundTruthUsedByQualityEngine` false'tur. `groundTruthCorrectionApplied` ve `gnssRecoveryAppliedDuringBenchmark` false'tur. Mutasyon ve kaldırma değişmezliği geçti. Korumalı GPS yalnızca değerlendirme içindir ve tahmin motoru geçmişleri finalize edildikten sonra karşılaştırıcıya ulaşır.

Karşılaştırıcı `T_estimator <= T_gt` koşulunu sağlayan en yeni tahmin motoru snapshot'ını seçer. Gelecek durum veya interpolasyon kullanılmaz ve her Yapılandırmanın ilk kesinti snapshot'ı vardır. Birincil metrik `matched_session_median_horizontal_error_m`, birincil karşılaştırma `config_d_vs_config_a`, p95 politikası deterministik `nearest_rank` değeridir.

Statik doğrulama tam altı uygulama/test yolunda geçti: `flutter analyze --no-pub`, 230/230 test, `flutter build apk --debug --no-pub` ve `git diff --check` geçti; beklenmeyen yol yoktu ve staging boştu.

Beş fiziksel eşleştirilmiş oturum `benchmarkSessionValid = true` ile tamamlandı. Hiçbir geçerli oturum seçici olarak çıkarılmadı ve olumsuz sonuçlar korundu:

| Oturum | Yapılandırma A medyanı (m) | Yapılandırma B medyanı (m) | Yapılandırma C medyanı (m) | Yapılandırma D medyanı (m) | D ve A | Hedef | Korumalı-GT bildirilen doğruluk medyanı (m) |
| ------ | --------------------------- | --------------------------- | --------------------------- | --------------------------- | ------ | ----- | ------------------------------------------ |
| 1 | 12,561945121444253 | 12,514907481594365 | 12,726737383050589 | 12,185632073247444 | +%2,9956590683907147 | Hayır | 9,10942268371582 |
| 2 | 39,91989974980391 | 39,85436801118203 | 38,62589905258437 | 39,01836083458484 | +%2,2583696874727224 | Hayır | 7,354877471923828 |
| 3 | 7,385470679117635 | 7,450695721587582 | 9,068059287914132 | 8,854542536862272 | -%19,89137756512158 | Hayır | 10,32039499282837 |
| 4 | 5,489879483076921 | 5,537451914072966 | 9,163584244845294 | 7,674902856418617 | -%39,80093515854474 | Hayır | 4,68110466003418 |
| 5 | 5,581047781899263 | 5,795966420799285 | 6,086691642081835 | 5,644477312321822 | -%1,1365165270269924 | Hayır | 4,203737020492554 |

Oturum 1 küçük bir D avantajı gösterdi ancak fark bildirilen GNSS referans belirsizliğine göre küçüktü; bildirilen doğruluk aralığı yaklaşık 5,9603–14,5096 m idi. Oturum 2 bütün Yapılandırma medyanlarını yaklaşık 39–40 m düzeyinde verdi ve aggregate-only veriden kesin tanılanamayacak olası ortak-mod referans/başlangıç katkısına işaret etti. Oturum 3'te D, A'dan kötü fakat C'den iyiydi. Oturum 4'te A, C'yi güçlü biçimde geçti; D, C'ye göre önemli ölçüde toparlandı ancak A'dan kötü kaldı. Oturum 5'te A ve D referans belirsizliğine göre çok yakındı. Bu yorumlar oturuma özgüdür ve evrensel neden oluşturmaz.

Her Yapılandırma 149 korumalı-GT gözlemiyle eşleşti (`29 + 30 + 30 + 30 + 30`). Kabul edilen 89 adım fırsatı vardı (`14 + 17 + 24 + 15 + 19`); Yapılandırma A bütün 89 adımı, eksik-nedensel-heading atlaması olmadan uyguladı ve Yapılandırma D'nin bütün oturumlardaki heading-yok atlaması da sıfırdı. Yaklaşık 7.659 heading ölçümü (`1532 + 1532 + 1532 + 1531 + 1532`) ve Yapılandırma D tarafından kullanılan 4.499 ARCore ölçümü (`900 + 900 + 899 + 900 + 900`) vardı.

D, A'yı 2/5 oturumda geçti ve 3/5 oturumda geride kaldı. A'yı en az %20 oranında geçtiği oturum sayısı 0/5'tir: **HEDEF KARŞILANMADI**. Eşleştirilmiş D-ve-A iyileştirmeleri yaklaşık +%2,996, +%2,258, -%19,891, -%39,801 ve -%1,137 idi; medyan yaklaşık -%1,14, ortalama yaklaşık -%11,11 idi. Oturum-düzeyi medyan hataların medyanı A için yaklaşık 7,3855 m, B için 7,4507 m, C için 9,1636 m ve D için 8,8545 m idi. Bunlar popülasyon düzeyinde istatistiksel olarak doğrulanmış doğruluk değil betimsel oturumlar-arası özetlerdir.

B-ve-A oturum değişimleri yaklaşık +%0,37, +%0,16, -%0,88, -%0,87 ve -%3,85 idi; mevcut heading EKF'yi tek başına eklemek bu beş oturumda maddi veya tutarlı iyileştirme sağlamadı. C-ve-A değişimleri yaklaşık -%1,31, +%3,24, -%22,78, -%66,92 ve -%9,06 idi; yalnızca ARCore-göreli Yapılandırma C bu benchmark'ta genellikle deterministik PDR'ı geçmedi. D-ve-C değişimleri yaklaşık +%4,25, -%1,02, +%2,35, +%16,25 ve +%7,27 idi; D, C'yi 4/5 oturumda yaklaşık +%4,25 eşleştirilmiş medyan iyileştirmeyle geçti. Bu bulguların hiçbiri evrensel değildir.

Onaylanan bilimsel sonuç şudur: NAVGUARD işlevsel GNSS-kesintili navigasyonu ve eşleştirilmiş çoklu-yapılandırma değerlendirmesini gösterdi; ancak önceden tanımlanan >=%20 Yapılandırma D-ve-A medyan-hata iyileştirme hedefi beş oturumlu fiziksel benchmark'ta karşılanmadı. Deney, Yapılandırma D'nin Yapılandırma A'ya sistematik üstünlüğünü göstermemektedir.

Korumalı Referans Konum telefonun `GPS_PROVIDER` verisini kullanır. Survey-grade ground truth, RTK GNSS, motion-capture ground truth veya total-station ground truth değildir. Bildirilen oturum-medyanı doğruluk yaklaşık 4,2–10,3 m aralığındadır; bu nedenle referans belirsizliğinden belirgin biçimde küçük farklar dikkatle yorumlanmalıdır. `protectedGroundTruthAccuracyValidated` ve benchmark doğruluğu false / **DOĞRULANMAMIŞTIR**.

Kanıtlanmış nedenler olmamak üzere olası katkılar; kalibre edilmemiş sabit 0,75 m adım uzunluğu, ARCore-to-ENU hizalama belirsizliği, gerçek-heading belirsizliği, heuristic Quality Engine eşikleri, heuristic EKF gürültü parametreleri—özellikle kalibre edilmemiş `BASE_ARCORE_POSITION_SIGMA_M = 0,35 m`—kısa 30 saniyelik ufuk ve telefon-GNSS belirsizliğidir. Yapılandırma A, dead-reckoning drift'inin birikmek için sınırlı zamanı olduğu kısa yaya pencerelerinde rekabetçi kalabilir; uzun-süreli benchmark yapılmadı.

Beş oturum mevcut değerlendirme seti olarak dondurulmuştur. ARCore sigma, adım sigma, heading sigma, kalite eşikleri, stride veya diğer füzyon parametreleri bu sonuçlardan tuning edilip aynı oturumlar bağımsız doğrulamaymış gibi tekrar değerlendirilemez. Gelecekteki her tuning yeni bağımsız fiziksel doğrulama oturumları gerektirir.

Gizlilik geçti: `rawGnssCoordinatesReturned = false`, `rawProtectedGroundTruthReturned = false`, `rawSensorSamplesReturned = false`, `rawArcorePosesReturned = false`, `rawTrajectoryReturned = false`, `rawTimestampsReturned = false`, `cameraImagesReturned = false` ve `persistenceUsed = false`. Ham benchmark verisi repository'ye eklenmez.

Aşama 9B — Canlı Harita NAVGUARD Demosu, Bölüm 67'de kaydedildiği üzere tanımlı entegrasyon kapsamında artık **UYGULANDI VE FİZİKSEL OLARAK DOĞRULANDI**. Bu, Stage 9A benchmark sonucunu değiştirmez. Sıradaki Aşama 9C — Nihai UI / Dokümantasyon / Demo Paketleme / Nihai Proje Kapanışı tamamlanmamıştır.

---

# 67. Stage 9B Live Map NAVGUARD Demo Evidence (Aşama 9B Canlı Harita NAVGUARD Demosu Kanıtı)

### English

Stage 9B — Live Map NAVGUARD Demo is **IMPLEMENTED**, statically validated, and physically verified for its defined integration scope on the tested Xiaomi Redmi Note 9 Pro. Final validation passed with `flutter analyze`, 260/260 tests, `flutter build apk --debug`, and `git diff --check`. Ten implementation/dependency paths comprise the Stage 9B source scope; no frozen diagnostic class was modified.

The display stack is `flutter_map 8.3.2` plus `latlong2 0.10.1`, using OpenStreetMap raster tiles with visible `© OpenStreetMap contributors` attribution and configured application identification. `android.permission.INTERNET` was added because it was absent. No Google Maps SDK, Mapbox, proprietary map API, bulk tile download, area prefetch, or offline-region scraper is used.

Estimator and map responsibilities remain separated:

```text
Sensors + ARCore + Quality Engine + EKF
                 ↓
           local ENU estimate
                 ↓
        display map projection
                 ↓
               map
```

The map is not estimator input. A tile or network failure does not mutate the local ENU state, source quality, EKF, denial controller, or recovery gate.

The physically exercised user flow was:

```text
GNSS Anchor
↓
Start Live Demo
↓
GNSS ACTIVE
↓
NAVGUARD READY
↓
Start GNSS Denial
↓
GNSS DENIED — NAVGUARD ACTIVE
↓
live estimated position + route
↓
Recover GNSS
↓
RECOVERY PENDING
↓
3 fresh valid GNSS fixes
↓
GNSS RECOVERED
```

Denial duration is interactive, not fixed at 30 seconds. Denial is software-defined: no RF interference, jammer, or GNSS spoofing is used. The physical `GPS_PROVIDER` listener may remain active, but every denied fix is quarantined before estimator access.

The initial no-anchor physical check exposed an invalid fake `0,0` map center. The fix removed that fallback and added an explicit `GNSS Anchor Required` state. `Start Live Demo` is blocked without an anchor, and `Return to Prepare GNSS Anchor` uses the existing Stage 3A workflow rather than duplicating anchor acquisition. The no-anchor path passed physical verification. With a valid anchor, OpenStreetMap and attribution rendered, the map centered around the operational anchor/GNSS area, Follow and Start controls rendered, `NAVGUARD READY` was reached, manual denial began, the estimated route was visible, and recovery visualization worked.

The first complete live physical walk verified manual denial, map motion, route visualization, recovery, and the denied-GNSS firewall; an example observation was accepted/quarantined/denied-used `4 / 41 / 0`. It also exposed a live PDR regression that remains part of the evidence:

```text
Updates H/PDR/AR: 2070 / 0 / 1212
Late H/Step/AR:   0 / 56 / 0
```

Fifty-six step events were received, zero PDR predictions were applied, and all 56 were classified late. The visible route was therefore predominantly ARCore-driven, not a full Config D route.

The initial 250 ms global reorder watermark was increased to 1,000 ms with 5,000 ms heading-history retention. Synthetic tests passed, but two independent approximately 20-manual-step physical retests failed:

| Retest | Received / Applied / Pending | No-heading / Late / Duplicate | Mean callback latency | Maximum callback latency |
| ------ | ---------------------------- | ----------------------------- | --------------------- | ------------------------ |
| 1 | 17 / 0 / 0 | 0 / 17 / 0 | 6602.6 ms | 10498.8 ms |
| 2 | 14 / 0 / 0 | 0 / 14 / 0 | 7113.4 ms | 10565.1 ms |

This physically demonstrated that `TYPE_STEP_DETECTOR` callbacks on the tested device may arrive approximately 6–7 seconds late on average and approximately 10.6 seconds late at the observed maximum. Android immediate callback delivery is not assumed. An 11+ second global reorder window was rejected because it would make the live map visibly lag the user.

The final implementation uses `FIXED_LAG_HISTORY_MS = 12000` with a maximum of 4,096 sanitized in-memory events/checkpoints. Normal heading and ARCore processing and approximately 5 Hz map emission remain low-latency; there is no 12-second global display delay. A delayed step retains its original `SensorEvent.timestamp`, is inserted into the retained historical sequence, and replays the checkpointed estimator forward in exact timestamp order with `HEADING → STEP → ARCORE_POSITION → insertion sequence` priority. Every step selects the greatest valid `T_heading <= T_step`; future heading and interpolation remain prohibited. Callback receipt time is used only for latency measurement. Events older than the retained history are rejected as genuinely late. Duplicate protection and the applied + no-heading + late + duplicate + pending = received invariant remain enforced. The live registration requests `maxReportLatencyUs = 0`, while fixed-lag replay remains required.

Only the corrected current operational estimate is streamed after replay. Previously emitted Flutter route points are not rewritten; subsequent visualization continues from the corrected state. No denied GNSS measurement enters replay history, and only already-converted ARCore relative ENU inputs need to be retained.

The final targeted physical retest consisted of approximately 20 manual straight steps followed by approximately 16–17 seconds stationary. The observed result was:

```text
Updates H/PDR/AR:                 1934 / 16 / 1135
Steps received/applied/pending:   16 / 16 / 0
No-heading/late/duplicate:        0 / 0 / 0
Step latency last/max/mean:       4999.8 / 10149.9 / 6493.4 ms
Late heading/step/AR:             0 / 0 / 0
Final H/PDR/AR/Fusion quality:    USABLE / USABLE / GOOD / GOOD
Denied GNSS quarantined/used:     38 / 0
Recovery state:                   GNSS RECOVERED
Recovery correction distance:     5.73 m
```

All 16 Android detector events were incorporated once through fixed-lag replay. This validates delayed-event handling, not step-detection accuracy: approximately 20 manual steps produced 16 detector events. The 5.73 m recovery correction is only the distance from the final pre-recovery NAVGUARD estimate to the accepted recovered operational GNSS position. It is not ground-truth error or NAVGUARD accuracy.

The physically displayed route followed the general direction of the approximately straight walk and demonstrated visually coherent relative motion, with minor geometric deviations. This does not establish metre-level route accuracy. Initial or recovered absolute handset-GNSS position may differ from the user's apparent real-world map location by tens of metres in some urban sessions. No projection defect or single cause was established; handset-GNSS uncertainty, urban multipath, and reference uncertainty remain possible limitations. Absolute GNSS alignment and map-position accuracy are not survey-grade and remain **NOT VALIDATED**.

Privacy boundaries remain active: the live local ENU route is ephemeral, `routePersisted = false`, and `routeUploaded = false`. Raw sensor streams, raw ARCore poses, raw timestamps, and anchor coordinates are not exposed to Flutter, logged, or persisted. Stage 9B physically verified live map integration, software-defined denial, the denied-GNSS firewall, active live heading/PDR/ARCore/Config D fusion, recovery, and fixed-lag detected-event handling. Live-demo accuracy, absolute-GNSS accuracy, step-detection accuracy, step length, heading accuracy, ARCore position accuracy, noise parameters, and quality thresholds remain **NOT VALIDATED**.

Stage 9A remains unchanged: Config D was better than A in 2/5 sessions and worse in 3/5; the >=20% target was not met, and median paired D-vs-A improvement remained approximately -1.14%. Stage 9B visualization does not replace that benchmark. Stage 9C — Final UI / Documentation / Demo Packaging / Final Project Closure is next and is not complete.

### Türkçe

Aşama 9B — Canlı Harita NAVGUARD Demosu test edilen Xiaomi Redmi Note 9 Pro üzerindeki tanımlı entegrasyon kapsamında **UYGULANDI**, statik olarak doğrulandı ve fiziksel olarak doğrulandı. Nihai doğrulama `flutter analyze`, 260/260 test, `flutter build apk --debug` ve `git diff --check` ile geçti. Stage 9B kaynak kapsamı on uygulama/bağımlılık yolundan oluşur; dondurulmuş tanı sınıfları değiştirilmedi.

Gösterim stack'i `flutter_map 8.3.2` ile `latlong2 0.10.1` kullanır; görünür `© OpenStreetMap contributors` atfı ve yapılandırılmış uygulama kimliğiyle OpenStreetMap raster tile'larını gösterir. Eksik olduğu için `android.permission.INTERNET` eklendi. Google Maps SDK, Mapbox, proprietary harita API'si, toplu tile indirme, alan prefetch'i veya çevrimdışı bölge kazıyıcısı kullanılmaz.

Tahmin motoru ile harita sorumlulukları ayrı kalır:

```text
Sensörler + ARCore + Quality Engine + EKF
                 ↓
             yerel ENU tahmini
                 ↓
          gösterim harita projeksiyonu
                 ↓
                 harita
```

Harita tahmin motoru girdisi değildir. Tile veya ağ arızası yerel ENU durumunu, kaynak kalitesini, EKF'yi, kesinti denetleyicisini veya recovery gate'ini değiştirmez.

Fiziksel olarak çalıştırılan kullanıcı akışı şuydu:

```text
GNSS Anchor
↓
Start Live Demo
↓
GNSS ACTIVE
↓
NAVGUARD READY
↓
Start GNSS Denial
↓
GNSS DENIED — NAVGUARD ACTIVE
↓
canlı tahmini konum + rota
↓
Recover GNSS
↓
RECOVERY PENDING
↓
3 taze geçerli GNSS fix'i
↓
GNSS RECOVERED
```

Kesinti süresi 30 saniyeye sabit değil, etkileşimlidir. Kesinti yazılım-tanımlıdır; RF paraziti, jammer veya GNSS spoofing kullanılmaz. Fiziksel `GPS_PROVIDER` dinleyicisi etkin kalabilir ancak her kesinti fix'i tahmin motoru erişiminden önce karantinaya alınır.

İlk anchor-yok fiziksel kontrolü geçersiz sahte `0,0` harita merkezini açığa çıkardı. Düzeltme bu fallback'i kaldırdı ve açık `GNSS Anchor Required` durumu ekledi. Anchor olmadan `Start Live Demo` engellenir; `Return to Prepare GNSS Anchor`, edinimi yinelemek yerine mevcut Stage 3A akışını kullanır. Anchor-yok yolu fiziksel doğrulamayı geçti. Geçerli anchor ile OpenStreetMap ve atıf gösterildi, harita operasyonel anchor/GNSS bölgesi çevresinde merkezlendi, Follow ve Start denetimleri gösterildi, `NAVGUARD READY` durumuna ulaşıldı, manuel kesinti başlatıldı, tahmini rota görüldü ve recovery görselleştirmesi çalıştı.

İlk tam canlı fiziksel yürüyüş manuel kesintiyi, harita hareketini, rota görselleştirmesini, recovery'yi ve kesinti-GNSS firewall'unu doğruladı; örnek kabul/karantina/kullanılan gözlemi `4 / 41 / 0` idi. Aynı test kanıtın parçası olarak korunan canlı PDR regresyonunu da açığa çıkardı:

```text
Heading/PDR/AR güncellemeleri: 2070 / 0 / 1212
Geç heading/adım/AR:           0 / 56 / 0
```

Elli altı adım olayı alındı, sıfır PDR prediction uygulandı ve 56'nın tamamı geç olarak sınıflandırıldı. Görünür rota bu nedenle tam Yapılandırma D rotası değil, ağırlıklı olarak ARCore güdümlüydü.

İlk 250 ms global reorder watermark'ı, 5.000 ms heading-geçmişi saklamayla 1.000 ms'ye çıkarıldı. Sentetik testler geçti ancak yaklaşık 20 manuel adımlı iki bağımsız fiziksel yeniden test başarısız oldu:

| Yeniden test | Alınan / Uygulanan / Bekleyen | Heading-yok / Geç / Duplicate | Ortalama callback gecikmesi | Maksimum callback gecikmesi |
| ------------ | ----------------------------- | ----------------------------- | -------------------------- | ------------------------- |
| 1 | 17 / 0 / 0 | 0 / 17 / 0 | 6.602,6 ms | 10.498,8 ms |
| 2 | 14 / 0 / 0 | 0 / 14 / 0 | 7.113,4 ms | 10.565,1 ms |

Bu sonuç test edilen cihazdaki `TYPE_STEP_DETECTOR` callback'lerinin ortalama yaklaşık 6–7 saniye, gözlenen maksimumda yaklaşık 10,6 saniye gecikebildiğini fiziksel olarak gösterdi. Android'in anında callback teslimi varsayılmaz. Canlı haritanın kullanıcıdan görünür biçimde geri kalmasına neden olacağı için 11+ saniyelik global reorder penceresi reddedildi.

Nihai uygulama, en fazla 4.096 sanitize edilmiş bellek-içi olay/checkpoint ile `FIXED_LAG_HISTORY_MS = 12000` kullanır. Normal heading ve ARCore işleme ile yaklaşık 5 Hz harita yayını düşük-gecikmeli kalır; global 12 saniyelik gösterim gecikmesi yoktur. Gecikmiş adım özgün `SensorEvent.timestamp` değerini korur, saklanan tarihsel diziye eklenir ve checkpoint'li tahmin motorunu `HEADING → STEP → ARCORE_POSITION → insertion sequence` önceliğiyle kesin zaman damgası sırasında ileri replay eder. Her adım en büyük geçerli `T_heading <= T_step` değerini seçer; gelecek heading ve interpolasyon yasak kalır. Callback-alım zamanı yalnızca gecikme ölçümünde kullanılır. Saklanan geçmişten eski olaylar gerçekten geç olarak reddedilir. Duplicate koruması ile uygulanan + heading-yok + geç + duplicate + bekleyen = alınan değişmezi korunur. Canlı kayıt `maxReportLatencyUs = 0` ister; fixed-lag replay yine de gereklidir.

Replay sonrasında yalnızca düzeltilmiş güncel operasyonel tahmin yayınlanır. Önceden yayınlanan Flutter rota noktaları yeniden yazılmaz; sonraki görselleştirme düzeltilmiş durumdan devam eder. Replay geçmişine kesinti-GNSS ölçümü girmez; yalnızca önceden dönüştürülmüş ARCore göreli ENU girdilerinin saklanması yeterlidir.

Nihai hedefli fiziksel yeniden test, yaklaşık 20 manuel düz adım ve ardından yaklaşık 16–17 saniye sabit duruştan oluştu. Gözlenen sonuç şuydu:

```text
Heading/PDR/AR güncellemeleri:     1934 / 16 / 1135
Alınan/uygulanan/bekleyen adımlar: 16 / 16 / 0
Heading-yok/geç/duplicate:         0 / 0 / 0
Adım gecikmesi son/maks/ortalama:  4999,8 / 10149,9 / 6493,4 ms
Geç heading/adım/AR:               0 / 0 / 0
Nihai H/PDR/AR/Füzyon kalitesi:    USABLE / USABLE / GOOD / GOOD
Karantina/kullanılan kesinti GNSS: 38 / 0
Recovery durumu:                   GNSS RECOVERED
Recovery correction mesafesi:      5,73 m
```

Android detector olaylarının 16/16'sı fixed-lag replay ile bir kez uygulandı. Bu, adım-algılama doğruluğunu değil gecikmiş-olay işlemeyi doğrular: yaklaşık 20 manuel adım 16 detector olayı üretti. 5,73 m recovery correction yalnızca recovery-öncesi son NAVGUARD tahmininden kabul edilen recovered operasyonel GNSS konumuna olan mesafedir. Ground-truth hata veya NAVGUARD doğruluğu değildir.

Fiziksel olarak gösterilen rota yaklaşık düz yürüyüşün genel yönünü izledi ve küçük geometrik sapmalarla görsel olarak tutarlı göreli hareket gösterdi. Bu, metre-düzeyi rota doğruluğu oluşturmaz. İlk veya recovered mutlak telefon-GNSS konumu bazı kentsel oturumlarda kullanıcının görünen gerçek-dünya harita konumundan onlarca metre farklı olabilir. Projeksiyon hatası veya tek bir neden kanıtlanmadı; telefon-GNSS belirsizliği, kentsel multipath ve referans belirsizliği olası sınırlamalar olarak kalır. Mutlak GNSS hizalaması ve harita-konum doğruluğu survey-grade değildir ve **DOĞRULANMAMIŞTIR**.

Gizlilik sınırları etkin kalır: canlı yerel ENU rota geçicidir, `routePersisted = false` ve `routeUploaded = false` değerindedir. Ham sensör akışları, ham ARCore pozları, ham zaman damgaları ve anchor koordinatları Flutter'a açılmaz, loglanmaz veya kalıcılaştırılmaz. Stage 9B; canlı harita entegrasyonunu, yazılım-tanımlı kesintiyi, kesinti-GNSS firewall'unu, fiziksel olarak etkin canlı heading/PDR/ARCore/Yapılandırma D füzyonunu, recovery'yi ve fixed-lag algılanan-olay işlemeyi fiziksel olarak doğruladı. Canlı-demo doğruluğu, mutlak-GNSS doğruluğu, adım-algılama doğruluğu, adım uzunluğu, heading doğruluğu, ARCore konum doğruluğu, gürültü parametreleri ve kalite eşikleri **DOĞRULANMAMIŞTIR**.

Stage 9A değişmez: Yapılandırma D, A'dan 2/5 oturumda iyi, 3/5 oturumda kötüydü; >=%20 hedefi karşılanmadı ve eşleştirilmiş D-ve-A medyan iyileştirmesi yaklaşık -%1,14 olarak kaldı. Stage 9B görselleştirmesi bu benchmark'ın yerine geçmez. Sıradaki Aşama 9C — Nihai UI / Dokümantasyon / Demo Paketleme / Nihai Proje Kapanışı tamamlanmamıştır.

---

# 68. Current Document Status (Mevcut Doküman Durumu)

### English

**Document Status:** Protocol Completed — Partial Execution

**Physical Device Audit Status:** PARTIAL — Static capability review, Flutter bootstrap execution, Stage 2A–2D runtime diagnostics, Stage 3A–5 navigation foundations, Stage 6 Evaluation Mode / Ground Truth Firewall verification, Stage 7 Config D Quality Engine + EKF fusion verification, Stage 8 full-flow verification, five valid Stage 9A matched benchmark sessions, and Stage 9B live-map/fixed-lag replay verification are complete for their defined scopes. The full device capability audit is not complete.

**Stage 2A Runtime Sensor Inventory Evidence:** VERIFIED on the tested Xiaomi Redmi Note 9 Pro. SensorManager runtime access, the Flutter–Kotlin diagnostic bridge, and runtime sensor metadata retrieval were verified. The inventory returned 14 requested records: 13 default sensors available and `TYPE_PRESSURE` unavailable. This is capability metadata evidence, not sensor-performance evidence.

**Stage 2B Live Timing Evidence:** VERIFIED for the tested accelerometer, gyroscope, magnetometer, and rotation-vector configuration. Three 10-second sessions per sensor produced 12/12 valid timing summaries and monotonic `SensorEvent.timestamp` sequences. No session contained a gap above the provisional 60 ms threshold (0/12 sessions with such gaps). Timestamp-derived aggregate mean rates were approximately 52.10 Hz, 51.07 Hz, 50.00 Hz, and 51.10 Hz respectively under the 20,000 µs (~50 Hz requested) configuration. These are scoped observations, not universal fixed rates.

**Stage 2C GNSS Runtime Timing Evidence:** VERIFIED for the tested diagnostic scope on the Xiaomi Redmi Note 9 Pro running Android 12 / API 31. The native implementation, static validation, debug build, final source audit, foreground precise-location permission flow, and GNSS preflight passed. Three of three formal `GPS_PROVIDER` sessions completed with valid, monotonic, and mock-free `Location.elapsedRealtimeNanos` summaries. Median and p95 callback intervals were 1.000 s in every session; the observed mean timestamp-derived rate range was approximately 0.983–1.000 Hz, and Session 3 contained one 2.000 s consecutive interval. The requested 1,000 ms minimum interval is not a guaranteed fixed 1 Hz delivery rate, and no GNSS gap threshold is defined. `GnssStatus.onFirstFix`, sanitized satellite counts, and Android-reported horizontal-accuracy metadata were observed; coordinate accuracy was not validated.

**Stage 2D ARCore Runtime Tracking Evidence:** VERIFIED for the tested diagnostic scope on the Xiaomi Redmi Note 9 Pro running Android 12 / API 31. AR Optional configuration, camera permission, preflight readiness, ARCore session creation/configuration/resume, dedicated GL/EGL initialization, and camera-texture setup passed. Three of three formal sessions were valid, reached real `TrackingState.TRACKING`, exposed local-session pose, produced monotonic `Frame.timestamp` sequences, completed without terminal errors, and contained no `STOPPED` frames. The observed unique-frame rate was approximately 30.0295–30.0304 Hz and the tracking fraction was approximately 98.15%–98.36%. Stationary, rotational, and rightward walking scenarios demonstrated local-session pose response. No ARCore frame-gap threshold was applied or frozen.

**Stage 3A GNSS Anchor + Local ENU Evidence:** VERIFIED for the defined runtime-flow scope on the same tested device. Preflight correctly blocked acquisition while location/GPS was disabled and reported ready after it was enabled. Three of three independent foreground `GPS_PROVIDER` anchor acquisitions succeeded with candidate counts 10 / 11 / 10. Explicit clear/reacquire and explicit cancellation were verified. Selection used lowest Android-reported horizontal accuracy with newer `Location.elapsedRealtimeNanos` as the tie-break; the selected metadata was approximately 17.98 / 15.32 / 34.79 m and is not measured coordinate error. WGS84 → ECEF → local ENU is implemented and unit-tested; horizontal ENU does not fabricate Up when altitude is unavailable. Raw coordinate exposure in shared formal logs: none observed. The runtime anchor is not persisted.

**Stage 3B Heading / True-North Evidence:** VERIFIED for the defined handset-heading foundation scope on the same tested device. `TYPE_ROTATION_VECTOR` was available and formally exercised; three of three 30-second sessions succeeded with approximately 51.14 Hz observed delivery, monotonic and duplicate-free `SensorEvent.timestamp` sequences, clockwise-positive response, circular continuity beyond 2π, locked-anchor `android.hardware.GeomagneticField` correction, and verified cancellation. Reported heading-accuracy metadata was unavailable in all sessions. Heading and true-north absolute accuracy remain not validated.

**Stage 3C Step-Event Evidence:** VERIFIED for the defined step-event foundation scope on the same tested device. `TYPE_STEP_DETECTOR` was available as `pedometer  Non-wakeup` and formally exercised in one stationary and two controlled-walk 30-second sessions. The stationary session accepted zero events, the controlled 20-step session accepted 16 events and excluded five delivered events through the formal window filter, and the controlled 30-step session accepted 30 events. Walking-session accepted timestamps were monotonic and duplicate-free; cancellation passed. Step-detection accuracy remains not validated.

**Stage 4 Baseline PDR Evidence:** VERIFIED for the defined deterministic baseline-PDR scope on the same tested device. Static validation passed with 118/118 tests. One stationary session, two 20-step straight walks, an intended 20-step L-shaped walk with 22 detected events, a corrected independent north check, and explicit cancellation were completed. The walking steps were causally associated without future heading use; PDR position is implemented. The earlier absolute-direction concern was resolved as a physically misidentified walking reference, not a Stage 4 heading-axis defect.

**Stage 5 ARCore Relative Motion → ENU Evidence:** VERIFIED for the defined foundation scope on the same tested device. Static validation passed with 141/141 tests. Stationary, north-like, east-like, and approximate 90-degree in-place rotation sessions plus explicit cancellation were completed. The straight-walk results had the expected dominant positive ENU axes; the in-place-rotation displacement remained much smaller than the straight-walk displacements. Completed sessions reported `trackingFraction = 1.0` with no `PAUSED` or `STOPPED` frames. ARCore-to-ENU is implemented; position, distance, vertical, heading, true-north, and ENU-alignment accuracy remain not validated.

**Stage 6 Evaluation Mode + Ground Truth Firewall Evidence:** VERIFIED for the defined Config A evaluation/firewall scope on the same tested device. Post-fix static validation passed with 169/169 tests. The stationary session remained at local origin; the initial moving failure exposed the delivered-callback-order heading-retention defect; and the fixed moving retest causally associated and integrated 11/11 accepted formal-window steps from a 20-manual-step walk. Both successful measurement sessions accepted and matched 30/30 protected-GT fixes. All firewall isolation flags passed and cancellation passed. Large Android-reported protected-GNSS uncertainty means the error metrics are not validated navigation-accuracy evidence.

**Stage 7 Config D Quality Engine + EKF Evidence:** VERIFIED for the defined diagnostic scope on the same tested device. Static validation passed with 191/191 tests. Stationary, straight-walk, and turn/L-shaped sessions completed with finite state/covariance and no crash; cancellation returned `navguard_fusion_cancelled`. Config D fused horizontal displacement was approximately 0.017905 m, 12.505097 m, and 10.018620 m respectively. The AR-degradation attempt retained tracking and produced no degraded-or-worse AR quality, so it passed with observation; fallback logic is implemented and statically tested, but physical AR-loss fallback is not validated. No physical-session value is an absolute-accuracy or calibrated-noise claim.

**Stage 8 Full NAVGUARD Flow Evidence:** VERIFIED for the defined full-flow scope on the same tested device. Static validation passed with 211/211 tests. The stationary flow, initial walking defect reproduction, timestamp-buffered causal-association correction, targeted 16/16 accepted-step walking retest, fresh-fix recovery, corrected gate/observation counter scopes, denial firewall, privacy boundary, and explicit cancellation were verified. The approximately 73.46 m recovery correction is an operational separation, not validated error or accuracy.

**Stage 9A Matched A/B/C/D Benchmark Evidence:** VERIFIED for the defined matched-session scope on the same tested device. Static validation passed with 230/230 tests. Five of five physical sessions were valid; each Config matched 149 protected-GT observations in total. Capture-once/replay-many, identical denial origin, causal no-future matching, the Ground Truth Firewall, mutation/removal invariance, aggregate-only privacy, and retention of all positive and negative outcomes passed. Config D outperformed A in 2/5 sessions, underperformed A in 3/5, and met the predefined >=20% target in 0/5. Median paired D-vs-A improvement was approximately -1.14% and mean approximately -11.11%. D outperformed C in 4/5. The target was not met; benchmark and protected-GT accuracy remain not validated.

**Stage 9B Live Map NAVGUARD Demo Evidence:** VERIFIED for the defined live integration scope on the same tested device. Static validation passed with 260/260 tests. OpenStreetMap rendering/attribution, map-estimator isolation, explicit no-anchor handling, interactive software-defined denial, live heading/PDR/ARCore/Config D fusion, route visualization, the denied-GNSS firewall, and recovery passed physical checks. The initial `56 / 0 / 56` received/applied/late result and both failed 1,000 ms physical retests remain recorded. The final bounded 12,000 ms fixed-lag replay retest incorporated 16/16 detected events with zero late steps; denied-GNSS estimator use remained zero and recovery completed. This verifies integration and delayed-event handling, not navigation or step-detection accuracy.

**Outstanding Evidence:** Sensor signal quality, noise, bias, calibration, complete sensor timing/multi-rate procedures, full-flow and recovery accuracy, live-map accuracy, fusion accuracy, Quality Engine threshold validity, EKF noise-parameter validity, covariance calibration, PDR accuracy, step-detection accuracy, step-length accuracy, heading absolute accuracy, true-north absolute accuracy, geomagnetic-model freshness, protected-GNSS ground-truth accuracy, GNSS absolute coordinate accuracy, survey-grade anchor quality, physical ENU distance accuracy, same-location anchor repeatability, ARCore position/distance/scale/rotation/drift/vertical/absolute accuracy, ENU-alignment accuracy, physically induced ARCore tracking loss and fallback/recovery handling, long-duration navigation behavior, independent post-tuning validation, full multi-source clock strategy, and other required device/runtime checks remain pending. Body heading and handset-to-body calibration are not implemented. Evaluation Mode, software-defined denial, the Ground Truth Firewall, Config D Quality Engine, EKF / Sensor Fusion, denied-GNSS quarantine, fresh-fix recovery, the full state-machine flow, the Stage 9A matched benchmark, and the Stage 9B live-map demonstration are implemented; Motion AI is not implemented. The >=20% Stage 9A target was measured and not met; no validated navigation-accuracy claim has been established.

**Documentation Synchronization:** Stage 9B live-map implementation, negative and positive physical findings, and fixed-lag replay evidence synchronized on 2026-09-15. Ten implementation/dependency paths and four documentation paths remain unstaged; the controlled combined 14-path staging gate is pending.

**Device Baseline Status:** NOT FROZEN

**Dataset Collection Authorization:** Pending Device Audit

**Minimum Architecture Authorization:** Pending GATE-MIN

**Target Architecture Authorization:** Pending GATE-TGT

### Türkçe

**Doküman Durumu:** Protokol Tamamlandı — Kısmi Uygulama

**Fiziksel Cihaz Denetim Durumu:** KISMİ — Statik yetenek incelemesi, Flutter bootstrap çalıştırması, Stage 2A–2D çalışma zamanı tanıları, Stage 3A–5 navigasyon temelleri, Stage 6 Değerlendirme Modu / Ground Truth Firewall doğrulaması, Stage 7 Yapılandırma D Quality Engine + EKF füzyon doğrulaması, Stage 8 tam-akış doğrulaması, beş geçerli Stage 9A eşleştirilmiş benchmark oturumu ve Stage 9B canlı-harita/fixed-lag replay doğrulaması tanımlı kapsamlarında tamamlandı. Tam cihaz yetenek denetimi tamamlanmadı.

**Stage 2A Çalışma Zamanı Sensör Envanteri Kanıtı:** Test edilen Xiaomi Redmi Note 9 Pro üzerinde DOĞRULANDI. SensorManager çalışma zamanı erişimi, Flutter–Kotlin tanı köprüsü ve çalışma zamanı sensör metadata alımı doğrulandı. Envanter 14 istenen kayıt döndürdü: 13 varsayılan sensör kullanılabilirdi ve `TYPE_PRESSURE` kullanılamıyordu. Bu yetenek metadata kanıtıdır; sensör performansı kanıtı değildir.

**Stage 2B Canlı Zamanlama Kanıtı:** Test edilen ivmeölçer, jiroskop, manyetometre ve dönüş vektörü yapılandırması için DOĞRULANDI. Sensör başına üç adet 10 saniyelik oturum; 12/12 geçerli zamanlama özeti ve monoton `SensorEvent.timestamp` dizisi üretti. 0/12 oturumda geçici 60 ms eşiğinin üzerinde boşluk gözlendi. Timestamp-türevli birleşik ortalama hızlar, 20.000 µs (~50 Hz talep edilen) yapılandırma altında sırasıyla yaklaşık 52,10 Hz, 51,07 Hz, 50,00 Hz ve 51,10 Hz idi. Bunlar evrensel sabit hızlar değil, kapsamı belirli gözlemlerdir.

**Stage 2C GNSS Çalışma Zamanı Zamanlama Kanıtı:** Android 12 / API 31 çalıştıran test cihazı Xiaomi Redmi Note 9 Pro üzerindeki tanı kapsamı için DOĞRULANDI. Native uygulama, statik doğrulama, debug build, nihai kaynak denetimi, hassas ön plan konum izni akışı ve GNSS preflight geçti. Üç resmî `GPS_PROVIDER` oturumunun 3/3'ü geçerli, monotonik ve mock içermeyen `Location.elapsedRealtimeNanos` özetleriyle tamamlandı. Medyan ve p95 callback aralıkları her oturumda 1,000 s idi; gözlenen timestamp-türevli ortalama hız aralığı yaklaşık 0,983–1,000 Hz oldu ve Oturum 3 ardışık bir 2,000 s aralık içerdi. Talep edilen 1.000 ms minimum aralık garanti edilen sabit 1 Hz teslim hızı değildir ve tanımlı bir GNSS boşluk eşiği yoktur. `GnssStatus.onFirstFix`, sanitize edilmiş uydu sayıları ve Android tarafından bildirilen yatay doğruluk metadata'sı gözlendi; koordinat doğruluğu doğrulanmadı.

**Stage 2D ARCore Çalışma Zamanı Takip Kanıtı:** Android 12 / API 31 çalıştıran test cihazı Xiaomi Redmi Note 9 Pro üzerindeki tanı kapsamı için DOĞRULANDI. AR Optional yapılandırması, kamera izni, preflight hazır olma durumu, ARCore oturum oluşturma/yapılandırma/resume, özel GL/EGL başlatma ve kamera texture kurulumu geçti. Üç resmî oturumun 3/3'ü geçerliydi; gerçek `TrackingState.TRACKING` durumuna ulaştı, yerel-oturum pozu sağladı, monotonik `Frame.timestamp` dizileri üretti, terminal hatası olmadan tamamlandı ve hiçbirinde `STOPPED` kare bulunmadı. Gözlenen benzersiz-kare hızı yaklaşık 30,0295–30,0304 Hz, tracking fraction yaklaşık %98,15–%98,36 idi. Sabit durma, dönüş ve sağa yürüme senaryoları yerel-oturum poz tepkisini gösterdi. ARCore kare-boşluk eşiği uygulanmadı veya sabitlenmedi.

**Stage 3A GNSS Anchor + Yerel ENU Kanıtı:** Aynı test cihazındaki tanımlı çalışma zamanı akışı kapsamında DOĞRULANDI. Preflight, konum/GPS kapalıyken edinimi doğru biçimde engelledi ve açıldıktan sonra hazır olduğunu bildirdi. Üç bağımsız yalnızca ön planda çalışan `GPS_PROVIDER` anchor ediniminin 3/3'ü 10 / 11 / 10 aday sayılarıyla başarılı oldu. Açık clear/reacquire ve açık iptal doğrulandı. Seçim, en düşük Android-bildirilen yatay doğruluğu daha yeni `Location.elapsedRealtimeNanos` eşitlik bozucusuyla kullandı; seçilen yaklaşık 17,98 / 15,32 / 34,79 m metadata değerleri ölçülmüş koordinat hatası değildir. WGS84 → ECEF → yerel ENU uygulandı ve birim testlerinden geçti; yatay ENU, yükseklik yokken Up uydurmaz. Paylaşılan resmî loglarda ham koordinat maruziyeti gözlenmedi. Çalışma zamanı anchor'ı kalıcılaştırılmaz.

**Stage 3B Heading / Gerçek Kuzey Kanıtı:** Aynı test cihazındaki tanımlı handset-heading temeli kapsamında DOĞRULANDI. `TYPE_ROTATION_VECTOR` kullanılabilirdi ve resmî olarak çalıştırıldı; üç adet 30 saniyelik oturumun 3/3'ü yaklaşık 51,14 Hz gözlenen teslim, monotonik ve duplicate içermeyen `SensorEvent.timestamp` dizileri, saat yönünde pozitif tepki, 2π üzerindeki dairesel süreklilik, kilitli-anchor `android.hardware.GeomagneticField` düzeltmesi ve doğrulanmış iptal ile başarılı oldu. Bildirilen heading-doğruluk metadata'sı tüm oturumlarda kullanılamıyordu. Heading ve gerçek-kuzey mutlak doğruluğu doğrulanmamış durumda.

**Stage 3C Adım Olayı Kanıtı:** Aynı test cihazındaki tanımlı adım-olayı temeli kapsamında DOĞRULANDI. `TYPE_STEP_DETECTOR`, `pedometer  Non-wakeup` adıyla kullanılabilirdi ve bir sabit ile iki kontrollü-yürüyüş 30 saniyelik oturumunda resmî olarak çalıştırıldı. Sabit oturum sıfır olay kabul etti; kontrollü 20-adımlı oturum 16 olay kabul edip teslim edilen beş olayı resmî pencere filtresiyle dışladı; kontrollü 30-adımlı oturum 30 olay kabul etti. Yürüyüş oturumlarının kabul edilen zaman damgaları monotonik ve duplicate içermiyordu; iptal geçti. Adım-algılama doğruluğu doğrulanmamış durumda.

**Stage 4 Temel PDR Kanıtı:** Aynı test cihazındaki tanımlı deterministik baseline-PDR kapsamında DOĞRULANDI. Statik doğrulama 118/118 testle geçti. Bir sabit oturum, iki 20-adımlık düz yürüyüş, algılanan 22 olaylı hedeflenmiş 20-adımlık L-biçimli yürüyüş, düzeltilmiş bağımsız kuzey kontrolü ve açık iptal tamamlandı. Yürüyüş adımları gelecek heading kullanılmadan nedensel olarak ilişkilendirildi; PDR konumu uygulandı. Önceki mutlak-yön endişesi Stage 4 heading-ekseni hatası değil, fiziksel olarak yanlış tanımlanmış yürüyüş referansı olarak çözüldü.

**Stage 5 ARCore Göreli Hareket → ENU Kanıtı:** Aynı test cihazındaki tanımlı temel kapsamında DOĞRULANDI. Statik doğrulama 141/141 testle geçti. Sabit, kuzey-benzeri, doğu-benzeri ve yaklaşık 90 derecelik yerinde dönüş oturumları ile açık iptal tamamlandı. Düz-yürüyüş sonuçlarında beklenen pozitif ENU eksenleri baskındı; yerinde-dönüş yer değiştirmesi düz-yürüyüş yer değiştirmelerinden çok daha düşük kaldı. Tamamlanan oturumlar sıfır `PAUSED`/`STOPPED` kareyle `trackingFraction = 1.0` bildirdi. ARCore-to-ENU uygulandı; konum, mesafe, dikey, heading, gerçek-kuzey ve ENU-hizalama doğruluğu doğrulanmadı.

**Stage 6 Değerlendirme Modu + Ground Truth Firewall Kanıtı:** Aynı test cihazındaki tanımlı Yapılandırma A değerlendirme/firewall kapsamında DOĞRULANDI. Düzeltme-sonrası statik doğrulama 169/169 testle geçti. Sabit oturum yerel başlangıçta kaldı; ilk hareketli başarısızlık teslim-callback-sırası heading saklama hatasını açığa çıkardı ve düzeltilmiş hareketli yeniden test 20-manuel-adımlı yürüyüşte kabul edilen 11/11 resmî-pencere adımını nedensel olarak ilişkilendirip entegre etti. İki başarılı ölçüm oturumu da 30/30 korumalı-GT fix'ini kabul edip eşleştirdi. Tüm firewall izolasyon bayrakları ve iptal geçti. Android-bildirilen yüksek korumalı-GNSS belirsizliği nedeniyle hata metrikleri doğrulanmış navigasyon-doğruluğu kanıtı değildir.

**Stage 7 Yapılandırma D Quality Engine + EKF Kanıtı:** Aynı test cihazındaki tanımlı tanı kapsamında DOĞRULANDI. Statik doğrulama 191/191 testle geçti. Sabit, düz-yürüyüş ve dönüş/L-biçimli oturumlar sonlu durum/kovaryansla ve crash olmadan tamamlandı; iptal `navguard_fusion_cancelled` döndürdü. Yapılandırma D fused yatay yer değiştirmeleri sırasıyla yaklaşık 0,017905 m, 12,505097 m ve 10,018620 m idi. AR bozulma denemesi tracking durumunu korudu ve degraded-veya-daha-kötü AR kalitesi üretmedi; bu nedenle gözlemle geçti. Fallback mantığı uygulandı ve statik olarak test edildi ancak fiziksel AR-kaybı fallback'i doğrulanmadı. Hiçbir fiziksel oturum değeri mutlak-doğruluk veya kalibre edilmiş-gürültü iddiası değildir.

**Stage 8 Tam NAVGUARD Akışı Kanıtı:** Aynı test cihazındaki tanımlı tam-akış kapsamında DOĞRULANDI. Statik doğrulama 211/211 testle geçti. Sabit akış, ilk yürüyüş hatasının yeniden üretimi, zaman damgası-tamponlu nedensel-ilişkilendirme düzeltmesi, hedefli kabul edilen 16/16-adım yürüyüş yeniden testi, taze-fix recovery, düzeltilmiş gate/gözlem sayaç kapsamları, kesinti firewall'u, gizlilik sınırı ve açık iptal doğrulandı. Yaklaşık 73,46 m recovery correction doğrulanmış hata veya doğruluk değil operasyonel ayrımdır.

**Stage 9A Eşleştirilmiş A/B/C/D Benchmark Kanıtı:** Aynı test cihazındaki tanımlı eşleştirilmiş-oturum kapsamında DOĞRULANDI. Statik doğrulama 230/230 testle geçti. Beş fiziksel oturumun 5/5'i geçerliydi; her Yapılandırma toplam 149 korumalı-GT gözlemiyle eşleşti. Bir-kez-yakala/çok-kez-replay, aynı kesinti başlangıcı, geleceği kullanmayan nedensel eşleştirme, Ground Truth Güvenlik Duvarı, mutasyon/kaldırma değişmezliği, yalnızca aggregate gizlilik ve bütün olumlu/olumsuz sonuçların korunması geçti. Yapılandırma D, A'yı 2/5 oturumda geçti, 3/5 oturumda geride kaldı ve önceden tanımlanan >=%20 hedefini 0/5 oturumda karşıladı. Eşleştirilmiş D-ve-A iyileştirmesinin medyanı yaklaşık -%1,14, ortalaması yaklaşık -%11,11 idi. D, C'yi 4/5 oturumda geçti. Hedef karşılanmadı; benchmark ve korumalı-GT doğruluğu doğrulanmamıştır.

**Stage 9B Canlı Harita NAVGUARD Demosu Kanıtı:** Aynı test cihazındaki tanımlı canlı entegrasyon kapsamında DOĞRULANDI. Statik doğrulama 260/260 testle geçti. OpenStreetMap gösterimi/atfı, harita-tahmin-motoru izolasyonu, açık anchor-yok yönetimi, etkileşimli yazılım-tanımlı kesinti, canlı heading/PDR/ARCore/Yapılandırma D füzyonu, rota görselleştirmesi, kesinti-GNSS firewall'u ve recovery fiziksel kontrolleri geçti. İlk `56 / 0 / 56` alınan/uygulanan/geç sonucu ve başarısız iki 1.000 ms fiziksel yeniden test kaydedilmiş durumda kalır. Nihai sınırlı 12.000 ms fixed-lag replay yeniden testi algılanan 16/16 olayı sıfır geç adımla uyguladı; kesinti-GNSS tahmin motoru kullanımı sıfır kaldı ve recovery tamamlandı. Bu entegrasyonu ve gecikmiş-olay işlemeyi doğrular; navigasyon veya adım-algılama doğruluğunu doğrulamaz.

**Bekleyen Kanıt:** Sensör sinyal kalitesi, gürültü, bias, kalibrasyon, tam sensör zamanlama/çoklu hız prosedürleri, tam-akış ve recovery doğruluğu, canlı-harita doğruluğu, füzyon doğruluğu, Quality Engine eşik geçerliliği, EKF gürültü-parametresi geçerliliği, kovaryans kalibrasyonu, PDR doğruluğu, adım-algılama doğruluğu, adım-uzunluğu doğruluğu, heading mutlak doğruluğu, gerçek-kuzey mutlak doğruluğu, geomanyetik model güncelliği, korumalı-GNSS ground-truth doğruluğu, GNSS mutlak koordinat doğruluğu, survey-grade anchor niteliği, fiziksel ENU mesafe doğruluğu, aynı-konum anchor tekrarlanabilirliği, ARCore konum/mesafe/ölçek/dönüş/sürüklenme/dikey/mutlak doğruluğu, ENU-hizalama doğruluğu, fiziksel olarak oluşturulmuş ARCore tracking kaybı ve fallback/recovery yönetimi, uzun-süreli navigasyon davranışı, tuning-sonrası bağımsız doğrulama, tam çok-kaynaklı saat stratejisi ve diğer gerekli cihaz/çalışma zamanı kontrolleri beklemektedir. Body heading ve telefon-vücut kalibrasyonu uygulanmamıştır. Değerlendirme Modu, yazılım-tanımlı kesinti, Ground Truth Firewall, Yapılandırma D Quality Engine, EKF / Sensör Füzyonu, kesinti-GNSS karantinası, taze-fix recovery, tam durum-makinesi akışı, Stage 9A eşleştirilmiş benchmark ve Stage 9B canlı-harita demosu uygulanmıştır; Motion AI uygulanmamıştır. Stage 9A >=%20 hedefi ölçülmüş ve karşılanmamıştır; doğrulanmış navigasyon-doğruluğu iddiası oluşturulmamıştır.

**Dokümantasyon Senkronizasyonu:** Stage 9B canlı-harita uygulaması, olumsuz/olumlu fiziksel bulguları ve fixed-lag replay kanıtı 2026-09-15 tarihinde senkronize edildi. On uygulama/bağımlılık yolu ve dört dokümantasyon yolu unstaged durumdadır; kontrollü birleşik 14-yolluk staging kapısı beklemektedir.

**Cihaz Baseline Durumu:** SABİTLENMEDİ

**Veri Seti Toplama Yetkisi:** Cihaz Denetimi Bekliyor

**Minimum Mimari Yetkisi:** GATE-MIN Bekliyor

**Hedef Mimari Yetkisi:** GATE-TGT Bekliyor

**Next Documentation Item:** 07 — Software Requirements Specification — SRS *(Sonraki Dokümantasyon Öğesi: 07 — Yazılım Gereksinimleri Şartnamesi — SRS)*
