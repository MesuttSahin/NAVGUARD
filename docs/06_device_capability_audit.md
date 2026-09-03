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
| Rotation Vector *(Dönüş Vektörü)* | TYPE_ROTATION_VECTOR | HIGH *(YÜKSEK)* | TBD |
| Game Rotation Vector *(Oyun Dönüş Vektörü)* | TYPE_GAME_ROTATION_VECTOR | MEDIUM *(ORTA)* | TBD |
| Linear Acceleration *(Doğrusal İvme)* | TYPE_LINEAR_ACCELERATION | MEDIUM *(ORTA)* | TBD |
| Gravity *(Yerçekimi)* | TYPE_GRAVITY | MEDIUM *(ORTA)* | TBD |
| Step Detector *(Adım Algılayıcı)* | TYPE_STEP_DETECTOR | LOW *(DÜŞÜK)* | TBD |
| Step Counter *(Adım Sayacı)* | TYPE_STEP_COUNTER | LOW *(DÜŞÜK)* | TBD |
| Pressure / Barometer *(Basınç / Barometre)* | TYPE_PRESSURE | LOW *(DÜŞÜK)* | TBD |

The Android-provided step detector and step counter will be audited for comparison purposes but will not automatically replace the NAVGUARD step detection algorithm. *(Android tarafından sağlanan adım algılayıcı ve adım sayacı karşılaştırma amacıyla denetlenecek ancak NAVGUARD adım tespit algoritmasının otomatik olarak yerini almayacaktır.)*

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
| Rotation Vector *(Dönüş Vektörü)* | TBD | TBD |
| Game Rotation Vector *(Oyun Dönüş Vektörü)* | TBD | TBD |
| Gravity *(Yerçekimi)* | TBD | TBD |
| Linear Acceleration *(Doğrusal İvme)* | TBD | TBD |

### Acceptance Criterion (Kabul Kriteri)

At least one reliable orientation strategy must be available from physical sensors or a suitable Android fused sensor combination. *(Fiziksel sensörlerden veya uygun bir Android füzyonlu sensör kombinasyonundan en az bir güvenilir yönelim stratejisi mevcut olmalıdır.)*

**Actual Status:** TBD *(Gerçek Durum: TBD)*

---

# 15. Sensor Timestamp Audit — AUD-TIME-001 (Sensör Zaman Damgası Denetimi — AUD-TIME-001)

NAVGUARD must verify that sensor events contain monotonically increasing timestamps suitable for relative timing calculations. *(NAVGUARD, sensör olaylarının göreli zamanlama hesaplamaları için uygun monotonik olarak artan zaman damgaları içerdiğini doğrulamalıdır.)*

The application must not assume that callbacks arrive at perfectly constant wall-clock intervals. *(Uygulama callback’lerin tamamen sabit duvar saati aralıklarında geldiğini varsaymamalıdır.)*

### Test Procedure (Test Prosedürü)

Record at least 60 seconds of continuous accelerometer and gyroscope data while the device is stationary. *(Cihaz sabit durumdayken en az 60 saniye sürekli ivmeölçer ve jiroskop verisi kaydet.)*

Calculate the difference between consecutive event timestamps. *(Ardışık olay zaman damgaları arasındaki farkı hesapla.)*

Calculate minimum, maximum, mean, median, standard deviation, and percentile values for the observed intervals. *(Gözlemlenen aralıklar için minimum, maksimum, ortalama, medyan, standart sapma ve yüzdelik değerlerini hesapla.)*

Check for non-monotonic timestamps, duplicated timestamps, and unusually long gaps. *(Monotonik olmayan zaman damgalarını, yinelenen zaman damgalarını ve olağandışı uzun boşlukları kontrol et.)*

### Result Table (Sonuç Tablosu)

| Metric (Metrik) | Accelerometer (İvmeölçer) | Gyroscope (Jiroskop) | Magnetometer (Manyetometre) |
| --- | --- | --- | --- |
| Duration *(Süre)* | TBD | TBD | TBD |
| Samples *(Örnekler)* | TBD | TBD | TBD |
| Minimum Interval *(Minimum Aralık)* | TBD | TBD | TBD |
| Median Interval *(Medyan Aralık)* | TBD | TBD | TBD |
| Mean Interval *(Ortalama Aralık)* | TBD | TBD | TBD |
| Maximum Interval *(Maksimum Aralık)* | TBD | TBD | TBD |
| Standard Deviation *(Standart Sapma)* | TBD | TBD | TBD |
| Non-Monotonic Events *(Monotonik Olmayan Olaylar)* | TBD | TBD | TBD |

### Acceptance Criterion (Kabul Kriteri)

Timestamps must be suitable for determining actual measurement intervals and synchronizing the navigation pipeline. *(Zaman damgaları gerçek ölçüm aralıklarını belirlemek ve navigasyon hattını senkronize etmek için uygun olmalıdır.)*

**Actual Status:** TBD *(Gerçek Durum: TBD)*

---

# 16. Effective Sampling Rate Audit — AUD-RATE-001 (Etkin Örnekleme Hızı Denetimi — AUD-RATE-001)

Requested sensor frequency and delivered sensor frequency must be treated as separate values. *(Talep edilen sensör frekansı ile sağlanan sensör frekansı ayrı değerler olarak ele alınmalıdır.)*

Android sensor delivery timing can vary, so effective sampling frequency must be calculated from actual event timestamps. *(Android sensör teslim zamanlaması değişebileceği için etkin örnekleme frekansı gerçek olay zaman damgalarından hesaplanmalıdır.)*

### Planned Test Rates (Planlanan Test Hızları)

- **Approximately 20 Hz** *(Yaklaşık 20 Hz)*
- **Approximately 50 Hz** *(Yaklaşık 50 Hz)*
- **Approximately 100 Hz where appropriate** *(Uygun olduğunda yaklaşık 100 Hz)*

NAVGUARD does not require sampling above 200 Hz for the planned architecture. *(NAVGUARD planlanan mimari için 200 Hz’in üzerinde örneklemeye ihtiyaç duymaz.)*

### Result Table (Sonuç Tablosu)

| Sensor (Sensör) | Requested Rate (Talep Edilen Hız) | Measured Median Rate (Ölçülen Medyan Hız) | Measured Mean Rate (Ölçülen Ortalama Hız) | Result (Sonuç) |
| --- | --- | --- | --- | --- |
| Accelerometer *(İvmeölçer)* | 50 Hz Target *(50 Hz Hedef)* | TBD | TBD | TBD |
| Gyroscope *(Jiroskop)* | 50 Hz Target *(50 Hz Hedef)* | TBD | TBD | TBD |
| Magnetometer *(Manyetometre)* | 20–50 Hz Target *(20–50 Hz Hedef)* | TBD | TBD | TBD |

### Acceptance Criterion (Kabul Kriteri)

The accelerometer and gyroscope should provide sufficiently stable sampling around the selected navigation rate for time-series processing. *(İvmeölçer ve jiroskop zaman serisi işleme için seçilen navigasyon hızının çevresinde yeterince kararlı örnekleme sağlamalıdır.)*

The exact accepted frequency will be selected based on measured stability rather than maximum capability. *(Kesin kabul edilen frekans maksimum yetenek yerine ölçülen kararlılığa göre seçilecektir.)*

**Actual Status:** TBD *(Gerçek Durum: TBD)*

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

If Android exposes a step detector or step counter on the device, its behavior will be measured for reference. *(Android cihaz üzerinde bir adım algılayıcı veya adım sayacı sunuyorsa davranışı referans amacıyla ölçülecektir.)*

The native Android step output will not be treated as ground truth without validation. *(Native Android adım çıktısı doğrulama yapılmadan gerçek referans olarak ele alınmayacaktır.)*

A manually counted walking sequence will be used for comparison. *(Karşılaştırma için manuel olarak sayılan bir yürüyüş dizisi kullanılacaktır.)*

### Result Table (Sonuç Tablosu)

| Item (Öğe) | Result (Sonuç) |
| --- | --- |
| TYPE_STEP_DETECTOR Available *(TYPE_STEP_DETECTOR Mevcut)* | TBD |
| TYPE_STEP_COUNTER Available *(TYPE_STEP_COUNTER Mevcut)* | TBD |
| Manual Steps *(Manuel Adımlar)* | TBD |
| Native Detected Steps *(Native Tespit Edilen Adımlar)* | TBD |
| Absolute Error *(Mutlak Hata)* | TBD |

**Actual Status:** TBD *(Gerçek Durum: TBD)*

---

# 23. GNSS Availability Audit — AUD-GNSS-001 (GNSS Kullanılabilirlik Denetimi — AUD-GNSS-001)

The physical device must successfully acquire geographic position information outdoors under ordinary open-sky conditions. *(Fiziksel cihaz normal açık gökyüzü koşullarında dış mekânda coğrafi konum bilgisini başarıyla elde etmelidir.)*

### Values to Record (Kaydedilecek Değerler)

- **Latitude** *(Enlem)*
- **Longitude** *(Boylam)*
- **Reported Accuracy** *(Bildirilen Doğruluk)*
- **Altitude if available** *(Mevcutsa Yükseklik)*
- **Speed if available** *(Mevcutsa Hız)*
- **Bearing if available** *(Mevcutsa Yön Açısı)*
- **Timestamp** *(Zaman Damgası)*

### Acceptance Criterion (Kabul Kriteri)

The device must provide stable enough outdoor location updates to establish the initial NAVGUARD position and record an evaluation reference trajectory. *(Cihaz başlangıç NAVGUARD konumunu oluşturmak ve değerlendirme referans rotasını kaydetmek için yeterince kararlı dış mekân konum güncellemeleri sağlamalıdır.)*

**Criticality:** CRITICAL *(Kritiklik: KRİTİK)*

**Actual Status:** TBD *(Gerçek Durum: TBD)*

---

# 24. GNSS Cold and Warm Acquisition Observation — AUD-GNSS-002 (GNSS Soğuk ve Sıcak Konum Alma Gözlemi — AUD-GNSS-002)

GNSS acquisition behavior will be observed after application startup under ordinary outdoor conditions. *(GNSS konum alma davranışı normal dış mekân koşullarında uygulama başlangıcından sonra gözlemlenecektir.)*

The objective is to characterize practical initialization delay rather than certify receiver performance. *(Amaç alıcı performansını sertifikalandırmak yerine pratik başlatma gecikmesini karakterize etmektir.)*

### Record (Kayıt)

| Metric (Metrik) | Result (Sonuç) |
| --- | --- |
| Time to First Acceptable Location *(İlk Kabul Edilebilir Konuma Kadar Süre)* | TBD |
| Initial Reported Accuracy *(İlk Bildirilen Doğruluk)* | TBD |
| Stable Accuracy After 30 Seconds *(30 Saniye Sonraki Kararlı Doğruluk)* | TBD |

**Actual Status:** TBD *(Gerçek Durum: TBD)*

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

Google officially lists the Redmi Note 9 Pro as an ARCore-supported device. *(Google, Redmi Note 9 Pro’yu resmî olarak ARCore destekli bir cihaz olarak listelemektedir.)*

The physical device must nevertheless be tested because project success depends on the installed software environment and actual runtime behavior. *(Bununla birlikte proje başarısı yüklü yazılım ortamına ve gerçek çalışma zamanı davranışına bağlı olduğu için fiziksel cihaz test edilmelidir.)*

### Required Checks (Gerekli Kontroller)

- **Google Play Services for AR availability** *(Google Play Services for AR kullanılabilirliği)*
- **ARCore session creation** *(ARCore oturumu oluşturma)*
- **Camera permission** *(Kamera izni)*
- **Rear camera startup** *(Arka kamera başlatma)*
- **AR tracking initialization** *(AR takip başlatma)*

### Acceptance Criterion (Kabul Kriteri)

An ARCore session must initialize successfully on the physical Redmi Note 9 Pro. *(Bir ARCore oturumu fiziksel Redmi Note 9 Pro üzerinde başarıyla başlatılmalıdır.)*

**Criticality:** HIGH *(Kritiklik: YÜKSEK)*

**Actual Status:** TBD *(Gerçek Durum: TBD)*

---

# 28. ARCore Pose Audit — AUD-AR-002 (ARCore Poz Denetimi — AUD-AR-002)

The audit must verify that ARCore produces changing relative pose values as the device is physically moved. *(Denetim, cihaz fiziksel olarak hareket ettirildiğinde ARCore’un değişen göreli poz değerleri ürettiğini doğrulamalıdır.)*

### Required Pose Information (Gerekli Poz Bilgisi)

- **Translation X, Y, and Z** *(Öteleme X, Y ve Z)*
- **Rotation Quaternion X, Y, Z, and W** *(Dönüş Quaternion X, Y, Z ve W)*
- **Frame Timestamp** *(Kare Zaman Damgası)*
- **Tracking State** *(Takip Durumu)*

### Planned Test (Planlanan Test)

Initialize ARCore while the device is stationary. *(Cihaz sabitken ARCore’u başlat.)*

Move the device slowly forward and backward. *(Cihazı yavaşça ileri ve geri hareket ettir.)*

Move the device laterally. *(Cihazı yanal olarak hareket ettir.)*

Perform a controlled rotation. *(Kontrollü bir dönüş gerçekleştir.)*

Return approximately to the starting position. *(Yaklaşık olarak başlangıç konumuna geri dön.)*

### Acceptance Criterion (Kabul Kriteri)

The pose output must respond consistently to physical movement and remain usable for relative displacement estimation during ordinary tracking conditions. *(Poz çıktısı fiziksel harekete tutarlı şekilde tepki vermeli ve normal takip koşullarında göreli yer değiştirme tahmini için kullanılabilir kalmalıdır.)*

**Actual Status:** TBD *(Gerçek Durum: TBD)*

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

**Actual Status:** TBD *(Gerçek Durum: TBD)*

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

**Actual Status:** TBD *(Gerçek Durum: TBD)*

---

# 31. Camera Runtime Audit — AUD-CAM-001 (Kamera Çalışma Zamanı Denetimi — AUD-CAM-001)

The rear camera must be available to ARCore without resource conflicts during the intended navigation workflow. *(Arka kamera, amaçlanan navigasyon iş akışı sırasında kaynak çatışmaları olmadan ARCore tarafından kullanılabilir olmalıdır.)*

### Required Checks (Gerekli Kontroller)

- **Camera permission granted** *(Kamera izni verildi)*
- **ARCore camera initialization successful** *(ARCore kamera başlatma başarılı)*
- **No persistent camera conflict** *(Kalıcı kamera çatışması yok)*
- **Navigation UI remains responsive while camera tracking is active** *(Kamera takibi aktifken navigasyon kullanıcı arayüzü tepki verebilir kalıyor)*

**Actual Status:** TBD *(Gerçek Durum: TBD)*

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

NAVGUARD must identify and test every runtime permission required by the selected Android configuration. *(NAVGUARD, seçilen Android yapılandırması tarafından gerekli her çalışma zamanı iznini belirlemeli ve test etmelidir.)*

### Planned Permission Categories (Planlanan İzin Kategorileri)

| Permission Area (İzin Alanı) | Required Use (Gerekli Kullanım) | Result (Sonuç) |
| --- | --- | --- |
| Precise Location *(Hassas Konum)* | GNSS initialization and ground truth *(GNSS başlatma ve gerçek referans)* | TBD |
| Camera *(Kamera)* | ARCore tracking *(ARCore takibi)* | TBD |
| Local File / Media Access if Required *(Gerekirse Yerel Dosya / Medya Erişimi)* | Session export *(Oturum dışa aktarma)* | TBD |
| High Sampling Rate Sensors *(Yüksek Örnekleme Hızlı Sensörler)* | Not expected to be required *(Gerekmesi beklenmiyor)* | TBD |

### Acceptance Criterion (Kabul Kriteri)

The application must handle granted and denied permission states without crashing. *(Uygulama izin verilmiş ve reddedilmiş durumları çökmeden yönetmelidir.)*

The user must receive a clear explanation when a required permission prevents a selected navigation configuration from running. *(Zorunlu bir izin seçilen navigasyon yapılandırmasının çalışmasını engellediğinde kullanıcı açık bir açıklama almalıdır.)*

**Actual Status:** TBD *(Gerçek Durum: TBD)*

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

NAVGUARD must define how sensor timestamps, GNSS timestamps, ARCore timestamps, and application event timestamps are represented and aligned. *(NAVGUARD; sensör zaman damgalarının, GNSS zaman damgalarının, ARCore zaman damgalarının ve uygulama olay zaman damgalarının nasıl temsil edilip hizalanacağını tanımlamalıdır.)*

The audit must identify whether each source uses a monotonic elapsed-time reference, wall-clock time, or another timestamp basis. *(Denetim her kaynağın monotonik geçen zaman referansı, duvar saati zamanı veya başka bir zaman damgası temeli kullanıp kullanmadığını belirlemelidir.)*

A documented conversion or synchronization strategy must exist before multi-source fusion begins. *(Çok kaynaklı füzyon başlamadan önce dokümante edilmiş bir dönüşüm veya senkronizasyon stratejisi mevcut olmalıdır.)*

### Acceptance Criterion (Kabul Kriteri)

Measurements from different sources must be alignable onto a common experiment timeline. *(Farklı kaynaklardan gelen ölçümler ortak bir deney zaman çizelgesine hizalanabilir olmalıdır.)*

**Criticality:** CRITICAL *(Kritiklik: KRİTİK)*

**Actual Status:** TBD *(Gerçek Durum: TBD)*

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
| AUD-GNSS-001 | GNSS Availability *(GNSS Kullanılabilirliği)* | CRITICAL *(KRİTİK)* | TBD |
| AUD-GNSS-003 | Ground Truth Isolation *(Gerçek Referans İzolasyonu)* | CRITICAL *(KRİTİK)* | TBD |
| AUD-AR-001 | ARCore Startup *(ARCore Başlatma)* | HIGH *(YÜKSEK)* | TBD |
| AUD-AR-002 | ARCore Relative Pose *(ARCore Göreli Poz)* | HIGH *(YÜKSEK)* | TBD |
| AUD-AI-001 | Local TFLite Runtime *(Yerel TFLite Çalışma Zamanı)* | HIGH *(YÜKSEK)* | TBD |
| AUD-STO-001 | Continuous Logging *(Sürekli Kayıt)* | CRITICAL *(KRİTİK)* | TBD |
| AUD-TIME-002 | Multi-Source Clock Alignment *(Çok Kaynaklı Saat Hizalama)* | CRITICAL *(KRİTİK)* | TBD |
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
- [ ]  **GNSS outdoor test completed.** *(GNSS dış mekân testi tamamlandı.)*
- [ ]  **GNSS ground-truth isolation verified.** *(GNSS gerçek referans izolasyonu doğrulandı.)*
- [ ]  **ARCore installation verified.** *(ARCore kurulumu doğrulandı.)*
- [ ]  **ARCore pose tracking verified.** *(ARCore poz takibi doğrulandı.)*
- [ ]  **ARCore stationary drift recorded.** *(ARCore sabit durum sürüklenmesi kaydedildi.)*
- [ ]  **ARCore degradation handling verified.** *(ARCore bozulma yönetimi doğrulandı.)*
- [ ]  **TensorFlow Lite test inference completed.** *(TensorFlow Lite test çıkarımı tamamlandı.)*
- [ ]  **Local storage logging test completed.** *(Yerel depolama kayıt testi tamamlandı.)*
- [ ]  **Offline runtime test completed.** *(Çevrimdışı çalışma testi tamamlandı.)*
- [ ]  **Clock alignment strategy verified.** *(Saat hizalama stratejisi doğrulandı.)*
- [ ]  **Minimum architecture gate evaluated.** *(Minimum mimari kapısı değerlendirildi.)*
- [ ]  **Target architecture gate evaluated.** *(Hedef mimari kapısı değerlendirildi.)*
- [ ]  **Final device baseline frozen.** *(Nihai cihaz temel referansı sabitlendi.)*

---

# 55. Final Audit Summary Table (Nihai Denetim Özet Tablosu)

| Area (Alan) | Result (Sonuç) | Notes (Notlar) |
| --- | --- | --- |
| Device Environment *(Cihaz Ortamı)* | TBD | TBD |
| Accelerometer *(İvmeölçer)* | TBD | TBD |
| Gyroscope *(Jiroskop)* | TBD | TBD |
| Magnetometer *(Manyetometre)* | TBD | TBD |
| Rotation Vector *(Dönüş Vektörü)* | TBD | TBD |
| Sensor Timing *(Sensör Zamanlaması)* | TBD | TBD |
| Sensor Sampling *(Sensör Örnekleme)* | TBD | TBD |
| GNSS | TBD | TBD |
| Ground Truth Isolation *(Gerçek Referans İzolasyonu)* | TBD | TBD |
| Raw GNSS *(Ham GNSS)* | TBD | TBD |
| ARCore | TBD | TBD |
| Camera *(Kamera)* | TBD | TBD |
| TensorFlow Lite | TBD | TBD |
| Local Storage *(Yerel Depolama)* | TBD | TBD |
| Offline Runtime *(Çevrimdışı Çalışma)* | TBD | TBD |
| Performance *(Performans)* | TBD | TBD |
| Battery *(Batarya)* | TBD | TBD |
| Thermal Behavior *(Termal Davranış)* | TBD | TBD |
| Minimum Architecture Gate *(Minimum Mimari Kapısı)* | TBD | TBD |
| Target Architecture Gate *(Hedef Mimari Kapısı)* | TBD | TBD |

---

# 56. Device Baseline Freeze Record (Cihaz Temel Referansı Sabitleme Kaydı)

**Baseline Status:** NOT FROZEN *(Temel Referans Durumu: SABİTLENMEDİ)*

**Audit Date:** TBD *(Denetim Tarihi: TBD)*

**Application Audit Build:** TBD *(Uygulama Denetim Build’i: TBD)*

**Device Model:** Xiaomi Redmi Note 9 Pro *(Cihaz Modeli: Xiaomi Redmi Note 9 Pro)*

**Android Version:** TBD *(Android Sürümü: TBD)*

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

# 59. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Protocol Completed — Partial Execution *(Doküman Durumu: Protokol Tamamlandı — Kısmi Uygulama)*

**Physical Device Audit Status:** Partial — Static Capability Review and Flutter Bootstrap Run Completed; Runtime Sensor/GNSS/ARCore Diagnostics Pending *(Fiziksel Cihaz Denetim Durumu: Kısmi — Statik Yetenek İncelemesi ve Flutter Bootstrap Çalıştırması Tamamlandı; Runtime Sensör/GNSS/ARCore Tanıları Bekleniyor)*

**Device Baseline Status:** Not Frozen *(Cihaz Temel Referans Durumu: Sabitlenmedi)*

**Dataset Collection Authorization:** Pending Device Audit *(Veri Seti Toplama Yetkisi: Cihaz Denetimi Bekleniyor)*

**Minimum Architecture Authorization:** Pending GATE-MIN *(Minimum Mimari Yetkisi: GATE-MIN Bekleniyor)*

**Target Architecture Authorization:** Pending GATE-TGT *(Hedef Mimari Yetkisi: GATE-TGT Bekleniyor)*

**Next Documentation Item:** 07 — Software Requirements Specification — SRS *(Sonraki Dokümantasyon Öğesi: 07 — Yazılım Gereksinimleri Şartnamesi — SRS)*
