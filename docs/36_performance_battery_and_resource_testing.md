# 36 — Performance, Battery & Resource Testing (Performans, Batarya ve Kaynak Testleri)

## 1. Document Purpose (Dokümanın Amacı)

This document defines how NAVGUARD will measure runtime performance, artificial-intelligence latency, CPU use, memory use, sensor-processing load, logging throughput, storage growth, battery consumption, thermal behavior, long-duration stability, and resource differences between navigation configurations. *(Bu doküman NAVGUARD'ın runtime performansını, yapay zekâ latency değerini, CPU kullanımını, memory kullanımını, sensör işleme yükünü, logging throughput'unu, storage growth'u, batarya tüketimini, termal davranışı, uzun süreli stabiliteyi ve navigasyon yapılandırmaları arasındaki kaynak farklarını nasıl ölçeceğini tanımlar.)*

The purpose is not only to show that NAVGUARD works, but also to determine whether it can operate continuously on the Xiaomi Redmi Note 9 Pro without unacceptable resource pressure. *(Amaç yalnızca NAVGUARD'ın çalıştığını göstermek değil, aynı zamanda Xiaomi Redmi Note 9 Pro üzerinde kabul edilemez kaynak baskısı oluşturmadan sürekli çalışıp çalışamayacağını belirlemektir.)*

---

# 2. Performance Philosophy (Performans Felsefesi)

Navigation accuracy and runtime efficiency will be evaluated as separate but related properties. *(Navigasyon doğruluğu ve runtime verimliliği ayrı ancak ilişkili özellikler olarak değerlendirilecektir.)*

A configuration that slightly improves position accuracy while making the device unstable or thermally unusable may not be the preferred practical configuration. *(Konum doğruluğunu biraz iyileştirirken cihazı kararsız veya termal olarak kullanışsız hale getiren yapılandırma pratik olarak tercih edilen yapılandırma olmayabilir.)*

---

# 3. No Unmeasured Performance Claims (Ölçülmemiş Performans İddiası Olmaması)

NAVGUARD will not claim that it is lightweight, battery-efficient, low-latency, or thermally stable before physical measurements exist. *(NAVGUARD fiziksel ölçümler mevcut olmadan lightweight, battery-efficient, low-latency veya thermally stable olduğunu iddia etmeyecektir.)*

---

# 4. Primary Performance Device (Temel Performans Cihazı)

The Xiaomi Redmi Note 9 Pro will be the authoritative device for all principal mobile performance measurements. *(Tüm temel mobil performans ölçümleri için Xiaomi Redmi Note 9 Pro ana cihaz olacaktır.)*

---

# 5. Build Type Requirement (Build Türü Gereksinimi)

Final performance conclusions will not be based solely on debug builds. *(Nihai performans sonuçları yalnızca debug build'lere dayanmayacaktır.)*

Profile or release-equivalent builds will be preferred for representative measurements. *(Temsili ölçümler için profile veya release-equivalent build'ler tercih edilecektir.)*

---

# 6. Debug Build Role (Debug Build Rolü)

Debug builds may be used during development to locate bottlenecks and inspect internal state. *(Debug build'ler geliştirme sırasında bottleneck'leri bulmak ve dahili durumu incelemek için kullanılabilir.)*

They will not be treated as the final runtime-performance reference. *(Nihai runtime-performance referansı olarak ele alınmayacaktır.)*

---

# 7. Main Performance Domains (Temel Performans Alanları)

NAVGUARD performance testing will cover the following domains. *(NAVGUARD performans testleri aşağıdaki alanları kapsayacaktır.)*

```text
CPU
MEMORY
AI INFERENCE
SENSOR PROCESSING
ARCORE
EKF / PDR
LOGGING
STORAGE
UI / MAP
BATTERY
THERMAL
LONG-DURATION STABILITY
```

---

# 8. Configuration-Level Performance Comparison (Yapılandırma Seviyesi Performans Karşılaştırması)

Resource use will be compared across Configurations A through D where practical. *(Kaynak kullanımı uygulanabilir olduğunda Configuration A-D arasında karşılaştırılacaktır.)*

---

# 9. Configuration A Performance Role (Configuration A Performans Rolü)

Configuration A provides the minimum PDR runtime baseline. *(Configuration A minimum PDR runtime baseline'ını sağlar.)*

---

# 10. Configuration B Performance Role (Configuration B Performans Rolü)

Configuration B measures the additional cost of improved heading processing. *(Configuration B geliştirilmiş heading processing'in ek maliyetini ölçer.)*

---

# 11. Configuration C Performance Role (Configuration C Performans Rolü)

Configuration C measures the additional cost of ARCore relative tracking. *(Configuration C ARCore relative tracking'in ek maliyetini ölçer.)*

---

# 12. Configuration D Performance Role (Configuration D Performans Rolü)

Configuration D measures the complete cost of AI-assisted NAVGUARD fusion. *(Configuration D yapay zekâ destekli tam NAVGUARD fusion'ın toplam maliyetini ölçer.)*

---

# 13. Matched Runtime Conditions (Eşleşmiş Runtime Koşulları)

Where possible, A-D performance comparisons will use similar session durations, device state, battery conditions, route type, screen state, and environmental conditions. *(Mümkün olduğunda A-D performans karşılaştırmaları benzer session duration, device state, battery condition, route type, screen state ve environment condition kullanacaktır.)*

---

# 14. Performance Variability (Performans Değişkenliği)

Smartphone performance varies with temperature, background activity, battery state, and operating-system behavior. *(Akıllı telefon performansı sıcaklık, background activity, battery state ve operating-system davranışına göre değişir.)*

Multiple measurements will therefore be preferred over one isolated run. *(Bu nedenle tek izole run yerine birden fazla measurement tercih edilecektir.)*

---

# 15. Performance Test Categories (Performans Test Kategorileri)

```text
MICRO-BENCHMARK
SUBSYSTEM TEST
COMBINED-STACK TEST
FIELD PERFORMANCE TEST
ENDURANCE TEST
STRESS TEST
```

---

# 16. Micro-Benchmark Purpose (Micro-Benchmark Amacı)

Micro-benchmarks will isolate operations such as AI inference, coordinate transformation, or EKF update cost. *(Micro-benchmark'lar AI inference, coordinate transformation veya EKF update cost gibi işlemleri izole edecektir.)*

---

# 17. Subsystem Test Purpose (Alt Sistem Test Amacı)

Subsystem tests will measure one complete component under realistic input rates. *(Alt sistem testleri tek tam bileşeni gerçekçi input rate altında ölçecektir.)*

---

# 18. Combined-Stack Test Purpose (Birleşik Stack Test Amacı)

Combined-stack testing will measure the application with all components required by the selected configuration running simultaneously. *(Combined-stack testing seçilen configuration tarafından gerekli tüm component'ler aynı anda çalışırken uygulamayı ölçecektir.)*

---

# 19. Field Performance Test Purpose (Saha Performans Test Amacı)

Field performance testing will measure real runtime behavior during walking. *(Saha performans testing yürüyüş sırasında gerçek runtime davranışını ölçecektir.)*

---

# 20. Endurance Test Purpose (Dayanıklılık Test Amacı)

Endurance testing will evaluate whether memory, storage queues, battery consumption, or thermal state deteriorate over longer continuous operation. *(Endurance testing memory, storage queue'ları, battery consumption veya thermal state'in daha uzun continuous operation sırasında kötüleşip kötüleşmediğini değerlendirecektir.)*

---

# 21. Performance Test Environment Record (Performans Test Ortam Kaydı)

Each formal performance run will record contextual conditions. *(Her resmî performans run'ı bağlamsal koşulları kaydedecektir.)*

```text
buildId
configuration
deviceModel
osVersion
batteryStartPercent
batteryEndPercent
chargingState
screenState
screenBrightnessMode
networkState
arcoreEnabled
aiEnabled
sessionDuration
ambientNotes
thermalStateStart
thermalStateEnd
```

---

# 22. Charging State Control (Şarj Durumu Kontrolü)

Principal battery tests will not be performed while the phone is charging. *(Temel battery testleri telefon şarj olurken gerçekleştirilmeyecektir.)*

---

# 23. Battery Condition Consistency (Batarya Koşulu Tutarlılığı)

Battery tests should start from approximately comparable charge ranges where practical. *(Battery testleri uygulanabilir olduğunda yaklaşık benzer charge range'lerden başlamalıdır.)*

---

# 24. Exact Starting Battery Percentage Is Not Frozen (Kesin Başlangıç Batarya Yüzdesi Sabit Değildir)

The experiment does not require one arbitrary exact starting percentage such as 100%. *(Deney %100 gibi keyfi tek kesin başlangıç yüzdesi gerektirmez.)*

---

# 25. Screen-State Importance (Ekran Durumunun Önemi)

Screen state can materially affect battery use and thermal behavior. *(Screen state battery use ve thermal behavior'ı anlamlı şekilde etkileyebilir.)*

---

# 26. Foreground-First Measurement (Foreground-First Ölçüm)

Principal NAVGUARD performance measurements will reflect the foreground-first operating design. *(Temel NAVGUARD performans ölçümleri foreground-first çalışma tasarımını yansıtacaktır.)*

---

# 27. Screen-On Policy (Ekran Açık Politikası)

If the final application keeps the display awake during active navigation, battery tests must use the same behavior. *(Nihai uygulama aktif navigasyon sırasında display'i açık tutarsa battery testleri aynı davranışı kullanmalıdır.)*

---

# 28. Brightness as a Confounding Variable (Confounding Değişken Olarak Parlaklık)

Display brightness will be controlled or recorded during battery-comparison runs. *(Display brightness battery-comparison run'ları sırasında kontrol edilecek veya kaydedilecektir.)*

---

# 29. Network Condition Control (Ağ Koşulu Kontrolü)

Network state will be kept comparable when configurations are compared for battery or CPU cost. *(Configuration'lar battery veya CPU cost açısından karşılaştırıldığında network state karşılaştırılabilir tutulacaktır.)*

---

# 30. Map Network Cost (Harita Ağ Maliyeti)

Map-tile downloads can distort battery and network measurements. *(Map-tile download'ları battery ve network measurement'larını bozabilir.)*

Performance runs may therefore use cached or controlled map behavior when practical. *(Bu nedenle performance run'ları uygulanabilir olduğunda cached veya controlled map behavior kullanabilir.)*

---

# 31. Core Estimator Independence (Temel Tahmin Motoru Bağımsızlığı)

Core navigation performance must remain measurable independently from map-network availability. *(Temel navigation performance map-network availability'den bağımsız olarak ölçülebilir kalmalıdır.)*

---

# 32. CPU Measurement Objective (CPU Ölçüm Hedefi)

CPU testing will determine how much processing pressure NAVGUARD creates under each configuration. *(CPU testing NAVGUARD'ın her configuration altında ne kadar processing pressure oluşturduğunu belirleyecektir.)*

---

# 33. CPU Metrics (CPU Metrikleri)

Candidate CPU metrics include average utilization, peak utilization, sustained utilization, and subsystem-specific profiling information. *(Aday CPU metric'leri average utilization, peak utilization, sustained utilization ve subsystem-specific profiling bilgisini içerir.)*

---

# 34. CPU Measurement Granularity (CPU Ölçüm Granularity)

CPU values may be collected at application, process, or system level depending on available profiling tools. *(CPU değerleri kullanılabilir profiling tool'larına bağlı olarak application, process veya system seviyesinde toplanabilir.)*

---

# 35. Process CPU Is Preferred for Application Cost (Uygulama Maliyeti İçin Process CPU Tercih Edilir)

Process-level CPU measurement is preferred when the objective is to estimate NAVGUARD's own runtime cost. *(Amaç NAVGUARD'ın kendi runtime cost'unu tahmin etmek olduğunda process-level CPU measurement tercih edilir.)*

---

# 36. Average CPU Use (Ortalama CPU Kullanımı)

```text
CPU_avg =
mean(application CPU utilization over valid interval)
```

---

# 37. Peak CPU Use (Peak CPU Kullanımı)

```text
CPU_peak =
max(application CPU utilization over valid interval)
```

---

# 38. P95 CPU Use (P95 CPU Kullanımı)

P95 CPU use may be reported to characterize sustained high-load behavior without depending entirely on one instantaneous spike. *(P95 CPU use tek anlık spike'a tamamen bağlı olmadan sustained high-load behavior'ı karakterize etmek için raporlanabilir.)*

---

# 39. CPU Spike Analysis (CPU Spike Analizi)

Large CPU spikes around ARCore initialization, model loading, export, or finalization will be interpreted separately from steady-state navigation. *(ARCore initialization, model loading, export veya finalization çevresindeki büyük CPU spike'ları steady-state navigation'dan ayrı yorumlanacaktır.)*

---

# 40. Steady-State CPU Window (Steady-State CPU Penceresi)

The principal CPU comparison will exclude application startup and one-time initialization unless those phases are being tested specifically. *(Temel CPU comparison application startup ve one-time initialization'ı, bu fazlar özel olarak test edilmiyorsa hariç tutacaktır.)*

---

# 41. Initialization CPU Is Still Logged (Initialization CPU Yine Loglanır)

Initialization cost may still be reported separately. *(Initialization cost ayrı olarak yine raporlanabilir.)*

---

# 42. Sensor Callback CPU Load (Sensör Callback CPU Yükü)

Sensor callbacks will be profiled to ensure they do not perform expensive work directly. *(Sensor callback'leri doğrudan pahalı iş yapmadıklarını sağlamak için profile edilecektir.)*

---

# 43. Callback Work Principle (Callback İş İlkesi)

Callbacks should capture timestamped measurements and hand them to bounded processing pipelines as quickly as possible. *(Callback'ler timestamped measurement'ları yakalayıp mümkün olduğunca hızlı bounded processing pipeline'larına iletmelidir.)*

---

# 44. Sensor Backlog Indicator (Sensör Backlog Göstergesi)

Growing processing queues may indicate that the application cannot sustain the selected sensor rate. *(Büyüyen processing queue'ları uygulamanın seçilen sensor rate'i sürdüremediğini gösterebilir.)*

---

# 45. Sensor Processing Metrics (Sensör İşleme Metrikleri)

```text
sensorEventsReceived
sensorEventsProcessed
sensorEventsDropped
processingQueueDepth
maxProcessingQueueDepth
processingLatency
```

---

# 46. Sensor Drop Rate (Sensör Drop Oranı)

```text
SensorDropRate =
DroppedSensorEvents /
ReceivedSensorEvents
```

---

# 47. Required Sensor Drop Policy (Gerekli Sensör Drop Politikası)

Mandatory estimator sensor streams should not show unexplained persistent drops during valid benchmark operation. *(Zorunlu estimator sensor stream'leri geçerli benchmark çalışması sırasında açıklanamayan sürekli drop göstermemelidir.)*

---

# 48. Effective Sensor Frequency (Efektif Sensör Frekansı)

Effective rate will be measured from actual measurement timestamps. *(Efektif rate gerçek measurement timestamp'larından ölçülecektir.)*

---

# 49. Requested Frequency Is Not Performance Evidence (Talep Edilen Frekans Performans Kanıtı Değildir)

Requesting approximately 50 Hz does not prove that Android delivered approximately 50 Hz. *(Yaklaşık 50 Hz istemek Android'in yaklaşık 50 Hz sunduğunu kanıtlamaz.)*

---

# 50. Effective Frequency Formula (Efektif Frekans Formülü)

For a stable period:

```text
f_eff =
1 /
median(Δt)
```

when `Δt` is expressed in seconds. *(`Δt` saniye cinsinden ifade edildiğinde bu formül kullanılacaktır.)*

---

# 51. Sensor Jitter (Sensör Jitter'ı)

Inter-sample timing variation will be characterized with percentile or dispersion metrics. *(Inter-sample timing variation percentile veya dispersion metric'leri ile karakterize edilecektir.)*

---

# 52. Sensor Long-Gap Count (Sensör Uzun Gap Sayısı)

Intervals exceeding the frozen gap threshold will be counted. *(Frozen gap threshold'u aşan interval'lar sayılacaktır.)*

---

# 53. Timing Performance Is Separate from Processing Performance (Timing Performansı İşleme Performansından Ayrıdır)

A fast CPU pipeline can still receive irregular physical sensor callbacks. *(Hızlı CPU pipeline yine de irregular fiziksel sensor callback alabilir.)*

---

# 54. AI Runtime Performance Domain (AI Runtime Performans Alanı)

Motion-classification inference will receive dedicated device-level latency testing. *(Motion-classification inference özel device-level latency testing alacaktır.)*

---

# 55. AI Model Load Time (AI Model Yükleme Süresi)

Model initialization time will be measured separately from inference time. *(Model initialization time inference time'dan ayrı ölçülecektir.)*

---

# 56. Warm-Up Inference (Warm-Up Inference)

Initial warm-up inference may behave differently from sustained inference and will be measured separately where necessary. *(İlk warm-up inference sustained inference'dan farklı davranabilir ve gerektiğinde ayrı ölçülecektir.)*

---

# 57. Steady-State Inference Latency (Steady-State Inference Latency)

The principal AI latency metric will represent steady-state repeated inference after initialization. *(Temel AI latency metric'i initialization sonrasındaki steady-state repeated inference'ı temsil edecektir.)*

---

# 58. AI Inference Start (AI Inference Başlangıcı)

Inference timing begins immediately before invoking the model runtime. *(Inference timing model runtime invoke edilmeden hemen önce başlar.)*

---

# 59. AI Inference End (AI Inference Sonu)

Inference timing ends when the model output becomes available to the application. *(Inference timing model output uygulama için kullanılabilir hale geldiğinde sona erer.)*

---

# 60. Per-Inference Latency (Inference Başına Latency)

```text
T_inference =
t_output -
t_invoke
```

---

# 61. Median AI Latency (Median AI Latency)

```text
AI_latency_median =
median(T_inference)
```

---

# 62. P95 AI Latency (P95 AI Latency)

```text
AI_latency_p95 =
percentile_95(T_inference)
```

---

# 63. Maximum AI Latency (Maksimum AI Latency)

Maximum inference latency may be retained as a diagnostic metric. *(Maximum inference latency diagnostic metric olarak korunabilir.)*

---

# 64. Provisional AI Latency Target (Geçici AI Latency Hedefi)

The provisional target remains below approximately 50 ms per inference on the Redmi Note 9 Pro. *(Geçici hedef Redmi Note 9 Pro üzerinde inference başına yaklaşık 50 ms'nin altında kalmaktadır.)*

---

# 65. Exact AI Statistic for Target Is Pending Freeze (Hedef İçin Kesin AI İstatistiği Freeze Bekliyor)

The final choice of whether the 50 ms target applies to median, P95, or another frozen statistic will be defined before formal benchmark reporting. *(50 ms hedefinin median, P95 veya başka frozen statistic'e uygulanıp uygulanmayacağı final benchmark reporting öncesinde tanımlanacaktır.)*

---

# 66. End-to-End AI Context Latency (Uçtan Uca AI Context Latency)

Model inference latency is not the same as total motion-context latency. *(Model inference latency toplam motion-context latency ile aynı değildir.)*

---

# 67. End-to-End Motion Context Formula (Uçtan Uca Motion Context Formülü)

```text
T_motion_context =
t_operational_context_ready -
t_last_required_sensor_sample
```

---

# 68. Window Duration Dominates Some Latency (Window Süresi Bazı Latency'leri Belirler)

Window-based motion classification inherently requires sensor accumulation time before inference. *(Window-based motion classification inference öncesinde doğası gereği sensor accumulation time gerektirir.)*

---

# 69. No Misleading AI Latency Claim (Yanıltıcı AI Latency İddiası Olmaması)

A 10 ms model execution does not imply a 10 ms motion-state response if the model uses a much longer input window and smoothing policy. *(10 ms model execution, model çok daha uzun input window ve smoothing policy kullanıyorsa 10 ms motion-state response anlamına gelmez.)*

---

# 70. AI Throughput (AI Throughput)

Inference throughput may be measured as completed inferences per second. *(Inference throughput saniye başına completed inference sayısı olarak ölçülebilir.)*

---

# 71. AI Queue Depth (AI Queue Derinliği)

If inference requests are queued, queue depth and backlog behavior will be measured. *(Inference request'leri queued ise queue depth ve backlog behavior ölçülecektir.)*

---

# 72. Stale Inference Prevention (Stale Inference Önleme)

The system must avoid processing a large backlog of old windows after runtime delay. *(Sistem runtime delay sonrasında büyük old-window backlog'u işlememelidir.)*

---

# 73. AI Backpressure Policy (AI Backpressure Politikası)

If processing cannot keep up, stale candidate windows should be dropped or coalesced according to the frozen runtime policy rather than causing unbounded delay. *(Processing yetişemiyorsa stale candidate window'lar unbounded delay oluşturmak yerine frozen runtime policy'ye göre dropped veya coalesced edilmelidir.)*

---

# 74. AI Invalid Output Cost (AI Geçersiz Çıktı Maliyeti)

Fallback paths will also be profiled to ensure repeated AI failure does not create a retry loop that wastes resources. *(Fallback path'leri repeated AI failure'ın kaynak israfı yapan retry loop oluşturmadığını sağlamak için profile edilecektir.)*

---

# 75. Model Size Metric (Model Boyutu Metriği)

Model artifact size will be reported. *(Model artifact boyutu raporlanacaktır.)*

---

# 76. Parameter Count Metric (Parameter Count Metriği)

Neural model parameter count may be reported as a complexity metric. *(Neural model parameter count complexity metric olarak raporlanabilir.)*

---

# 77. Quantization Comparison (Quantization Karşılaştırması)

If quantization is tested, float and quantized models will be compared for accuracy, size, latency, and resource use. *(Quantization test edilirse float ve quantized modeller accuracy, size, latency ve resource use açısından karşılaştırılacaktır.)*

---

# 78. Quantization Is Not Automatically Better (Quantization Otomatik Olarak Daha İyi Değildir)

Quantization will only be retained if measured tradeoffs are acceptable. *(Quantization yalnızca measured tradeoff'lar kabul edilebilir ise korunacaktır.)*

---

# 79. Delegate Comparison (Delegate Karşılaştırması)

CPU baseline will be measured before any optional delegate optimization. *(CPU baseline herhangi bir optional delegate optimization öncesinde ölçülecektir.)*

---

# 80. Delegate Retention Rule (Delegate Koruma Kuralı)

An alternative delegate will only be enabled if device testing demonstrates reliable improvement without unacceptable instability or compatibility problems. *(Alternative delegate yalnızca device testing kabul edilemez instability veya compatibility problem oluşturmadan güvenilir improvement gösterirse etkinleştirilecektir.)*

---

# 81. PDR Runtime Performance (PDR Runtime Performansı)

PDR step propagation is expected to be lightweight but will still receive profiling. *(PDR step propagation'ın lightweight olması beklenmektedir ancak yine de profiling alacaktır.)*

---

# 82. PDR Step Update Latency (PDR Step Update Latency)

```text
T_pdr_update =
t_pdr_state_ready -
t_step_event_received
```

---

# 83. PDR Latency Requirement (PDR Latency Gereksinimi)

PDR processing must remain comfortably below inter-step timing so that accepted steps do not accumulate into a backlog. *(PDR processing accepted step'lerin backlog oluşturmaması için inter-step timing'in rahat şekilde altında kalmalıdır.)*

---

# 84. Exact PDR Latency Threshold Is Pending Profiling (Kesin PDR Latency Eşiği Profiling Bekliyor)

No arbitrary millisecond threshold will be frozen before implementation evidence exists. *(Implementation evidence mevcut olmadan keyfi millisecond threshold sabitlenmeyecektir.)*

---

# 85. Heading Runtime Performance (Heading Runtime Performansı)

Heading estimation will be profiled independently and inside the combined pipeline. *(Heading estimation bağımsız ve combined pipeline içerisinde profile edilecektir.)*

---

# 86. Heading Update Cost (Heading Update Maliyeti)

Filtering, fusion, declination correction, magnetic-quality evaluation, and circular normalization contribute to heading runtime cost. *(Filtering, fusion, declination correction, magnetic-quality evaluation ve circular normalization heading runtime cost'a katkıda bulunur.)*

---

# 87. EKF Runtime Performance (EKF Runtime Performansı)

EKF prediction and update cost will be measured for representative event sequences. *(EKF prediction ve update cost temsili event sequence'leri için ölçülecektir.)*

---

# 88. EKF Event Latency (EKF Event Latency)

```text
T_ekf_event =
t_state_published -
t_measurement_or_step_received
```

---

# 89. Small State Benefit (Küçük State'in Faydası)

The initial minimum state `[E,N,ψ]` is expected to keep EKF computational cost low. *(İlk minimum state `[E,N,ψ]` EKF computational cost'u düşük tutması beklenmektedir.)*

---

# 90. Extended-State Cost Evaluation (Genişletilmiş State Maliyet Değerlendirmesi)

If velocity or additional states are introduced, their performance cost must be measured alongside any accuracy benefit. *(Velocity veya additional state eklenirse performance cost'ları accuracy benefit ile birlikte ölçülmelidir.)*

---

# 91. Matrix Failure Cost (Matrix Hata Maliyeti)

Numerical-failure handling must not enter repeated expensive retry loops. *(Numerical-failure handling tekrarlanan pahalı retry loop'lara girmemelidir.)*

---

# 92. ARCore Runtime Performance (ARCore Runtime Performansı)

ARCore is expected to be one of the more resource-intensive optional subsystems. *(ARCore'un daha resource-intensive optional subsystem'lerden biri olması beklenmektedir.)*

---

# 93. ARCore CPU Cost (ARCore CPU Maliyeti)

Configuration C and D tests will quantify the additional CPU cost associated with ARCore. *(Configuration C ve D testleri ARCore ile ilişkili ek CPU cost'u quantify edecektir.)*

---

# 94. ARCore Battery Cost (ARCore Batarya Maliyeti)

ARCore-enabled runs will be compared with PDR-only runs to estimate additional battery impact. *(ARCore-enabled run'lar ek battery impact'ı tahmin etmek için PDR-only run'larla karşılaştırılacaktır.)*

---

# 95. ARCore Thermal Cost (ARCore Termal Maliyeti)

Longer ARCore sessions will be included in thermal and endurance testing. *(Daha uzun ARCore session'ları thermal ve endurance testing'e dahil edilecektir.)*

---

# 96. Camera Processing Is Not Free (Kamera İşleme Ücretsiz Değildir)

Camera and visual-inertial tracking consume additional compute and power even when no raw frames are saved. *(Ham frame'ler kaydedilmese bile kamera ve visual-inertial tracking ek compute ve power tüketir.)*

---

# 97. Tracking State Resource Comparison (Tracking State Kaynak Karşılaştırması)

Where practical, resource behavior in `TRACKING` and degraded ARCore states may be compared. *(Uygulanabilir olduğunda `TRACKING` ve degraded ARCore state'lerde resource behavior karşılaştırılabilir.)*

---

# 98. ARCore Loss Must Not Increase Resource Use Unexpectedly (ARCore Kaybı Kaynak Kullanımını Beklenmedik Artırmamalıdır)

Repeated tracking-loss recovery must not create accumulating AR sessions, camera sessions, or listeners. *(Repeated tracking-loss recovery accumulating AR session, camera session veya listener oluşturmamalıdır.)*

---

# 99. Duplicate ARCore Session Test (Duplicate ARCore Session Testi)

Lifecycle tests will verify that one logical navigation session does not accidentally create multiple simultaneous ARCore sessions. *(Lifecycle testleri tek logical navigation session'ın yanlışlıkla birden fazla simultaneous ARCore session oluşturmadığını doğrulayacaktır.)*

---

# 100. Memory Testing Objective (Memory Test Hedefi)

Memory testing will determine whether NAVGUARD remains bounded during continuous navigation. *(Memory testing NAVGUARD'ın continuous navigation sırasında bounded kalıp kalmadığını belirleyecektir.)*

---

# 101. Memory Metrics (Memory Metrikleri)

Candidate memory metrics include current memory, peak memory, growth over time, allocation rate, and retained queue size. *(Aday memory metric'leri current memory, peak memory, time over growth, allocation rate ve retained queue size içerir.)*

---

# 102. Baseline Memory (Baseline Memory)

A baseline application-memory measurement will be collected after startup and stabilization. *(Startup ve stabilization sonrasında baseline application-memory measurement alınacaktır.)*

---

# 103. Active Navigation Memory (Aktif Navigasyon Memory)

Memory will be measured during steady-state navigation. *(Memory steady-state navigation sırasında ölçülecektir.)*

---

# 104. Peak Navigation Memory (Peak Navigasyon Memory)

Peak memory during selected representative sessions will be retained. *(Seçilen temsili session'lar sırasında peak memory korunacaktır.)*

---

# 105. Memory Growth (Memory Growth)

```text
MemoryGrowth =
Memory_end -
Memory_start
```

---

# 106. Memory Growth Rate (Memory Growth Rate)

```text
MemoryGrowthRate =
MemoryGrowth /
SessionDuration
```

---

# 107. Memory Growth Does Not Automatically Equal Leak (Memory Growth Otomatik Leak Değildir)

Temporary caching or runtime behavior may produce bounded memory growth without representing a leak. *(Temporary caching veya runtime behavior leak anlamına gelmeden bounded memory growth üretebilir.)*

---

# 108. Unbounded Growth Is a Failure Signal (Unbounded Growth Hata Sinyalidir)

Memory that continues to grow with session duration without stabilization will require investigation. *(Session duration ile stabilization olmadan büyümeye devam eden memory investigation gerektirecektir.)*

---

# 109. Rolling Buffers Must Be Bounded (Rolling Buffer'lar Bounded Olmalıdır)

Sensor windows, AI windows, diagnostic charts, trajectory previews, and writer queues must all have explicit memory bounds. *(Sensor window'lar, AI window'lar, diagnostic chart'lar, trajectory preview'lar ve writer queue'ların tamamı explicit memory bound'a sahip olmalıdır.)*

---

# 110. Diagnostic UI Memory Test (Diagnostic UI Memory Testi)

Opening and closing diagnostic charts repeatedly must not leak listeners or retained sample buffers. *(Diagnostic chart'ları tekrar tekrar açıp kapatmak listener veya retained sample buffer leak oluşturmamalıdır.)*

---

# 111. Navigation Screen Memory Test (Navigation Screen Memory Testi)

Repeated UI rebuilds must not duplicate state subscriptions. *(Repeated UI rebuild'ler state subscription'ları duplicate etmemelidir.)*

---

# 112. Session Restart Memory Test (Session Restart Memory Testi)

Starting and ending multiple sessions sequentially will test whether native resources are released correctly. *(Birden fazla session'ı art arda başlatıp bitirmek native resource'ların doğru release edildiğini test edecektir.)*

---

# 113. Multi-Session Endurance Test (Çoklu Session Endurance Testi)

A repeated-session test may run several short sessions without restarting the application. *(Repeated-session test uygulamayı restart etmeden birkaç kısa session çalıştırabilir.)*

---

# 114. Memory Acceptance Threshold Pending (Memory Kabul Eşiği Bekliyor)

The final acceptable memory-growth threshold will be based on measured behavior rather than invented before implementation. *(Nihai acceptable memory-growth threshold implementation öncesinde uydurulmak yerine measured behavior'a dayanacaktır.)*

---

# 115. Logging Runtime Performance (Logging Runtime Performansı)

Logging must capture required evidence without blocking time-sensitive navigation processing. *(Logging time-sensitive navigation processing'i block etmeden gerekli evidence'ı yakalamalıdır.)*

---

# 116. Logging Architecture Requirement (Logging Mimari Gereksinimi)

Disk writes will remain decoupled from high-frequency sensor callbacks through bounded queues or equivalent asynchronous mechanisms. *(Disk write'lar bounded queue veya equivalent asynchronous mechanism üzerinden high-frequency sensor callback'lerden decoupled kalacaktır.)*

---

# 117. Produced Record Count (Üretilen Kayıt Sayısı)

```text
RecordsProduced
```

---

# 118. Written Record Count (Yazılan Kayıt Sayısı)

```text
RecordsWritten
```

---

# 119. Dropped Record Count (Düşürülen Kayıt Sayısı)

```text
RecordsDropped
```

---

# 120. Logging Drop Rate (Logging Drop Oranı)

```text
LogDropRate =
RecordsDropped /
RecordsProduced
```

---

# 121. Mandatory Benchmark Logging Target (Zorunlu Benchmark Logging Hedefi)

Mandatory evidence streams should have zero dropped records during valid formal benchmark sessions. *(Zorunlu evidence stream'leri geçerli formal benchmark session'larında sıfır dropped record'a sahip olmalıdır.)*

---

# 122. Queue Depth Metric (Queue Depth Metriği)

```text
WriterQueueDepth(t)
```

---

# 123. Maximum Queue Depth (Maksimum Queue Depth)

```text
WriterQueueDepthMax =
max(WriterQueueDepth(t))
```

---

# 124. Queue Recovery (Queue Recovery)

Temporary queue growth is acceptable only if the queue later drains and does not continue growing without bound. *(Temporary queue growth yalnızca queue daha sonra drain olur ve sınırsız büyümeye devam etmezse kabul edilebilir.)*

---

# 125. Logging Backpressure Test (Logging Backpressure Testi)

Artificially slowed writes will be used to test queue limits and drop behavior. *(Artificially slowed write'lar queue limit ve drop behavior test etmek için kullanılacaktır.)*

---

# 126. No Silent Logging Failure (Sessiz Logging Hatası Olmaması)

Writer errors, queue overflow, or dropped mandatory records must become visible diagnostics. *(Writer error, queue overflow veya dropped mandatory record'lar visible diagnostic haline gelmelidir.)*

---

# 127. Storage Throughput Objective (Storage Throughput Hedefi)

Storage testing will determine how quickly NAVGUARD generates evidence and whether the device can sustain required writes. *(Storage testing NAVGUARD'ın evidence'ı ne kadar hızlı ürettiğini ve cihazın gerekli write'ları sürdürebilip sürdüremediğini belirleyecektir.)*

---

# 128. Bytes Written Metric (Yazılan Byte Metriği)

```text
BytesWritten
```

---

# 129. Storage Rate (Storage Rate)

```text
StorageRate =
BytesWritten /
SessionDuration
```

---

# 130. Storage per Minute (Dakika Başına Storage)

```text
StorageMBPerMinute =
BytesWritten /
(1024² × SessionDurationMinutes)
```

---

# 131. Estimated Session Size (Tahmini Session Boyutu)

Once measured `StorageMBPerMinute` exists, expected session size may be estimated as follows. *(Measured `StorageMBPerMinute` mevcut olduğunda expected session size aşağıdaki gibi tahmin edilebilir.)*

```text
ExpectedSessionMB =
StorageMBPerMinute ×
ExpectedSessionMinutes
```

---

# 132. Storage Free-Space Gate (Storage Boş Alan Gate'i)

A formal session will require enough available space for the expected session plus safety margin. *(Resmî session expected session için yeterli alan ve safety margin gerektirecektir.)*

---

# 133. Final Free-Space Threshold Pending (Nihai Boş Alan Eşiği Bekliyor)

The exact free-space threshold will be derived from measured logging volume. *(Kesin free-space threshold measured logging volume'dan türetilecektir.)*

---

# 134. CSV Size (CSV Boyutu)

Raw CSV growth will be measured separately where useful. *(Raw CSV growth kullanışlı olduğunda ayrı ölçülecektir.)*

---

# 135. SQLite Size (SQLite Boyutu)

SQLite metadata and session-state growth may also be monitored. *(SQLite metadata ve session-state growth da izlenebilir.)*

---

# 136. Export Size (Export Boyutu)

Final exported session-package size will be measured. *(Final exported session-package size ölçülecektir.)*

---

# 137. Compression Ratio Candidate (Compression Ratio Adayı)

If ZIP compression is used, compression ratio may be reported as a storage diagnostic. *(ZIP compression kullanılırsa compression ratio storage diagnostic olarak raporlanabilir.)*

---

# 138. Export Performance (Export Performansı)

Export duration will be measured for representative completed sessions. *(Export duration temsili completed session'lar için ölçülecektir.)*

---

# 139. Export Latency Formula (Export Latency Formülü)

```text
T_export =
t_export_complete -
t_export_start
```

---

# 140. Export Does Not Block Active Navigation (Export Aktif Navigasyonu Block Etmez)

The normal workflow will not perform large session export during an active formal navigation session. *(Normal workflow aktif formal navigation session sırasında büyük session export gerçekleştirmeyecektir.)*

---

# 141. Finalization Performance (Finalization Performansı)

Session finalization time will be measured because draining writers and calculating hashes may delay completion. *(Session finalization time ölçülecektir çünkü writer drain ve hash calculation completion'ı geciktirebilir.)*

---

# 142. Finalization Latency (Finalization Latency)

```text
T_finalize =
t_completed -
t_stop_confirmed
```

---

# 143. Finalization Latency Is User-Visible (Finalization Latency Kullanıcıya Görünürdür)

Long finalization is a usability issue even if navigation accuracy is unaffected. *(Uzun finalization navigation accuracy etkilenmese bile usability issue'dur.)*

---

# 144. Hashing Cost (Hashing Maliyeti)

Artifact hashing cost may be measured separately if large evidence files make finalization expensive. *(Büyük evidence file'ları finalization'ı pahalı hale getirirse artifact hashing cost ayrı ölçülebilir.)*

---

# 145. UI Performance Domain (UI Performans Alanı)

Flutter rendering performance will be evaluated separately from estimator performance. *(Flutter rendering performance estimator performance'dan ayrı değerlendirilecektir.)*

---

# 146. UI Responsiveness Objective (UI Responsiveness Hedefi)

The user interface must remain responsive while navigation, AI, ARCore, and logging are active. *(Navigation, AI, ARCore ve logging aktifken user interface responsive kalmalıdır.)*

---

# 147. Map Rendering Load (Harita Render Yükü)

Map rendering will be profiled because frequent trajectory updates can create unnecessary UI work. *(Frequent trajectory update'leri gereksiz UI work oluşturabileceği için map rendering profile edilecektir.)*

---

# 148. Estimator and UI Rate Separation (Estimator ve UI Rate Ayrımı)

The UI does not need to render every high-frequency estimator event. *(UI her high-frequency estimator event'i render etmek zorunda değildir.)*

---

# 149. UI Throttling Candidate (UI Throttling Adayı)

Navigation-state display may be updated at a lower visual rate while estimator processing remains at full rate. *(Navigation-state display estimator processing full rate'te kalırken daha düşük visual rate'te update edilebilir.)*

---

# 150. UI Throttling Must Not Affect Data (UI Throttling Veriyi Etkilememelidir)

Reducing display-update frequency must not reduce stored estimator evidence or estimator execution frequency. *(Display-update frequency azaltmak stored estimator evidence'ı veya estimator execution frequency'yi azaltmamalıdır.)*

---

# 151. Diagnostic Chart Load (Diagnostic Chart Yükü)

Diagnostic charts will be measured because plotting high-frequency sensor samples can create unnecessary frame and memory pressure. *(High-frequency sensor sample plot etmek gereksiz frame ve memory pressure oluşturabileceği için diagnostic chart'lar ölçülecektir.)*

---

# 152. Diagnostic Downsampling (Diagnostic Downsampling)

Diagnostic display streams may be downsampled independently from authoritative acquisition. *(Diagnostic display stream'leri authoritative acquisition'dan bağımsız downsample edilebilir.)*

---

# 153. UI Frame Metrics (UI Frame Metrikleri)

Frame rendering duration, jank, or dropped-frame indicators may be captured during combined-stack tests where practical. *(Frame rendering duration, jank veya dropped-frame indicator'ları uygulanabilir olduğunda combined-stack testlerinde yakalanabilir.)*

---

# 154. UI Jank as Secondary Metric (İkincil Metrik Olarak UI Jank)

UI jank is important for usability but remains secondary to estimator correctness and evidence integrity. *(UI jank usability için önemlidir ancak estimator correctness ve evidence integrity'ye göre ikincil kalır.)*

---

# 155. UI Must Not Starve Native Processing (UI Native Processing'i Starve Etmemelidir)

Expensive Flutter rendering must not materially starve native sensor or AI processing. *(Expensive Flutter rendering native sensor veya AI processing'i anlamlı şekilde starve etmemelidir.)*

---

# 156. Battery Testing Objective (Batarya Test Hedefi)

Battery testing will quantify the practical cost of continuous NAVGUARD operation. *(Battery testing continuous NAVGUARD operation'ın pratik maliyetini quantify edecektir.)*

---

# 157. Battery Start (Batarya Başlangıcı)

```text
B_start
```

---

# 158. Battery End (Batarya Sonu)

```text
B_end
```

---

# 159. Battery Percentage Drop (Batarya Yüzde Düşüşü)

```text
ΔB =
B_start -
B_end
```

---

# 160. Battery Use per Hour (Saat Başına Batarya Kullanımı)

```text
BatteryUsePerHour =
ΔB /
SessionDurationHours
```

---

# 161. Battery Use per Minute (Dakika Başına Batarya Kullanımı)

For shorter diagnostic sessions, battery use may be normalized per minute. *(Daha kısa diagnostic session'lar için battery use dakika başına normalize edilebilir.)*

---

# 162. Battery Percentage Resolution Limitation (Batarya Yüzde Çözünürlük Sınırlaması)

Battery percentage is a coarse measure and can hide small short-term energy differences. *(Battery percentage coarse measure'dır ve küçük short-term energy difference'ları gizleyebilir.)*

---

# 163. Longer Sessions Improve Battery Measurement (Daha Uzun Session'lar Batarya Ölçümünü İyileştirir)

Longer controlled sessions may provide more interpretable battery-difference measurements than very short runs. *(Daha uzun controlled session'lar çok kısa run'lara göre daha yorumlanabilir battery-difference measurement sağlayabilir.)*

---

# 164. Battery Comparison Configurations (Batarya Karşılaştırma Yapılandırmaları)

At minimum, PDR-only and full NAVGUARD should be compared under similar conditions. *(Minimum olarak PDR-only ve full NAVGUARD benzer koşullar altında karşılaştırılmalıdır.)*

---

# 165. ARCore Battery Increment (ARCore Batarya Artışı)

Configuration C compared with A can help estimate the incremental cost of ARCore. *(Configuration C'nin A ile karşılaştırılması ARCore'un incremental cost'unu tahmin etmeye yardımcı olabilir.)*

---

# 166. AI Battery Increment (AI Batarya Artışı)

AI-specific battery impact may be estimated through controlled configuration or shadow-mode comparisons where practical. *(AI-specific battery impact uygulanabilir olduğunda controlled configuration veya shadow-mode comparison üzerinden tahmin edilebilir.)*

---

# 167. No Artificial Battery Efficiency Target Yet (Henüz Yapay Batarya Verimlilik Hedefi Yoktur)

No fixed percentage battery target will be invented before device measurements exist. *(Device measurement mevcut olmadan fixed percentage battery target uydurulmayacaktır.)*

---

# 168. Battery Acceptance Will Be Practical (Batarya Kabulü Pratik Olacaktır)

The final acceptance threshold will consider whether representative demonstration and benchmark sessions can complete reliably without excessive battery depletion. *(Final acceptance threshold temsili demonstration ve benchmark session'ların excessive battery depletion olmadan güvenilir şekilde tamamlanıp tamamlanamadığını dikkate alacaktır.)*

---

# 169. Thermal Testing Objective (Termal Test Hedefi)

Thermal testing will determine whether continuous combined-stack operation causes performance degradation or instability. *(Thermal testing continuous combined-stack operation'ın performance degradation veya instability oluşturup oluşturmadığını belirleyecektir.)*

---

# 170. Thermal Context (Termal Bağlam)

Smartphone temperature depends on ambient conditions, display activity, CPU use, camera use, charging state, and previous workload. *(Smartphone temperature ambient condition, display activity, CPU use, camera use, charging state ve previous workload'a bağlıdır.)*

---

# 171. Thermal Measurements (Termal Ölçümler)

Available thermal status and temperature indicators may be recorded during representative sessions. *(Available thermal status ve temperature indicator'ları temsili session'lar sırasında kaydedilebilir.)*

---

# 172. Thermal Start State (Termal Başlangıç Durumu)

Thermal state at session start will be recorded for endurance tests. *(Thermal state endurance test'leri için session başlangıcında kaydedilecektir.)*

---

# 173. Thermal End State (Termal Son Durum)

Thermal state at session end will also be recorded. *(Thermal state session sonunda da kaydedilecektir.)*

---

# 174. Thermal Throttling Observation (Thermal Throttling Gözlemi)

If thermal throttling occurs, its timing relative to AI latency, UI responsiveness, ARCore behavior, and CPU load will be examined. *(Thermal throttling oluşursa AI latency, UI responsiveness, ARCore behavior ve CPU load ile ilişkili timing'i incelenecektir.)*

---

# 175. Thermal Performance Degradation (Termal Performans Bozulması)

Latency before and after significant thermal escalation may be compared. *(Anlamlı thermal escalation öncesi ve sonrası latency karşılaştırılabilir.)*

---

# 176. Thermal Instability Failure (Termal Kararsızlık Hatası)

If thermal pressure causes repeated application failure, severe inference slowdown, ARCore instability, or sensor-processing backlog, the configuration requires optimization or fallback review. *(Thermal pressure repeated application failure, severe inference slowdown, ARCore instability veya sensor-processing backlog oluşturursa configuration optimization veya fallback review gerektirir.)*

---

# 177. Exact Thermal Threshold Pending (Kesin Termal Eşik Bekliyor)

No universal temperature threshold will be invented before device-specific observations exist. *(Device-specific observation mevcut olmadan universal temperature threshold uydurulmayacaktır.)*

---

# 178. Long-Duration Stability Objective (Uzun Süreli Stabilite Hedefi)

NAVGUARD must remain stable beyond short demonstration runs. *(NAVGUARD kısa demonstration run'ların ötesinde stabil kalmalıdır.)*

---

# 179. Endurance Session (Endurance Session)

A dedicated long-duration combined-stack session will be performed. *(Özel long-duration combined-stack session gerçekleştirilecektir.)*

---

# 180. Endurance Duration Is Pending Profiling (Endurance Süresi Profiling Bekliyor)

The final endurance-session length will be selected after shorter runs establish safe and practical conditions. *(Final endurance-session length daha kısa run'lar güvenli ve pratik koşulları belirledikten sonra seçilecektir.)*

---

# 181. Candidate Endurance Objectives (Aday Endurance Hedefleri)

```text
No crash
No unbounded memory growth
No unbounded writer queue
No duplicate runtime sessions
No accumulating sensor listeners
No repeated AI backlog
No corrupted session evidence
Acceptable thermal behavior
Acceptable battery use
```

---

# 182. Endurance Session Evidence (Endurance Session Kanıtı)

The endurance session will retain periodic resource samples and normal navigation evidence. *(Endurance session periodic resource sample'ları ve normal navigation evidence'ı koruyacaktır.)*

---

# 183. Long-Session Memory Trend (Uzun Session Memory Trend'i)

Memory will be plotted or summarized over time. *(Memory zaman içerisinde plot edilecek veya özetlenecektir.)*

---

# 184. Long-Session Queue Trend (Uzun Session Queue Trend'i)

Writer and inference queues will be monitored over time. *(Writer ve inference queue'ları zaman içerisinde izlenecektir.)*

---

# 185. Long-Session Latency Trend (Uzun Session Latency Trend'i)

AI and estimator latency may be compared between early and late sections of the same endurance run. *(AI ve estimator latency aynı endurance run'ın early ve late section'ları arasında karşılaştırılabilir.)*

---

# 186. Long-Session Battery Trend (Uzun Session Batarya Trend'i)

Battery consumption will be normalized by elapsed time. *(Battery consumption elapsed time'a göre normalize edilecektir.)*

---

# 187. Long-Session Thermal Trend (Uzun Session Termal Trend'i)

Thermal escalation will be correlated with other runtime metrics where possible. *(Thermal escalation mümkün olduğunda diğer runtime metric'leriyle correlate edilecektir.)*

---

# 188. Resource Leak Test (Kaynak Leak Testi)

Repeated creation and destruction of sessions will test resource cleanup. *(Session'ların repeated creation ve destruction işlemi resource cleanup'ı test edecektir.)*

---

# 189. Sensor Listener Cleanup (Sensör Listener Cleanup)

Ending a session must unregister or deactivate session-specific sensor listeners according to the architecture. *(Session bitirmek architecture'a göre session-specific sensor listener'ları unregister veya deactivate etmelidir.)*

---

# 190. GNSS Callback Cleanup (GNSS Callback Cleanup)

GNSS callbacks must not accumulate after repeated session restarts. *(GNSS callback'leri repeated session restart sonrasında accumulate etmemelidir.)*

---

# 191. ARCore Cleanup (ARCore Cleanup)

ARCore sessions and camera ownership must be released correctly. *(ARCore session'ları ve camera ownership doğru release edilmelidir.)*

---

# 192. AI Runtime Cleanup (AI Runtime Cleanup)

Unused LiteRT interpreters or equivalent runtime resources must not accumulate across sessions. *(Unused LiteRT interpreter veya equivalent runtime resource'lar session'lar arasında accumulate etmemelidir.)*

---

# 193. Writer Cleanup (Writer Cleanup)

File handles and database writers must close at finalization. *(File handle'lar ve database writer'lar finalization sırasında kapanmalıdır.)*

---

# 194. Flutter Subscription Cleanup (Flutter Subscription Cleanup)

UI stream subscriptions must be disposed correctly when screens are removed. *(UI stream subscription'ları screen'ler kaldırıldığında doğru dispose edilmelidir.)*

---

# 195. Session Restart Resource Test (Session Restart Kaynak Testi)

Resource usage after multiple complete session cycles should return near a stable baseline rather than growing monotonically. *(Birden fazla complete session cycle sonrasında resource usage monotonik büyümek yerine stable baseline'a yakın dönmelidir.)*

---

# 196. Failure-Mode Performance Testing (Failure-Mode Performans Testi)

Resource behavior will also be examined under failure conditions. *(Resource behavior failure condition'lar altında da incelenecektir.)*

---

# 197. ARCore Failure Resource Test (ARCore Hata Kaynak Testi)

Tracking loss and restart must not create escalating CPU or memory usage. *(Tracking loss ve restart escalating CPU veya memory usage oluşturmamalıdır.)*

---

# 198. AI Failure Resource Test (AI Hata Kaynak Testi)

Repeated inference failure must not create busy-loop retries. *(Repeated inference failure busy-loop retry oluşturmamalıdır.)*

---

# 199. Logging Failure Resource Test (Logging Hata Kaynak Testi)

Writer failure must not create unbounded queue accumulation. *(Writer failure unbounded queue accumulation oluşturmamalıdır.)*

---

# 200. GNSS Recovery Resource Test (GNSS Recovery Kaynak Testi)

Repeated rejected GNSS recovery candidates must not create uncontrolled processing load. *(Repeated rejected GNSS recovery candidate'ları uncontrolled processing load oluşturmamalıdır.)*

---

# 201. Permission Failure Resource Test (Permission Hata Kaynak Testi)

Permission loss must not produce repeated failing API calls at high frequency. *(Permission loss high frequency'de repeated failing API call oluşturmamalıdır.)*

---

# 202. UI Error-State Performance Test (UI Error-State Performans Testi)

Persistent warning states must not trigger unnecessary continuous rebuild loops. *(Persistent warning state'ler gereksiz continuous rebuild loop tetiklememelidir.)*

---

# 203. Configuration A Resource Profile (Configuration A Kaynak Profili)

Configuration A will establish the minimum expected runtime cost of sensors, step detection, heading, PDR, GNSS logging, UI, and storage. *(Configuration A sensörler, step detection, heading, PDR, GNSS logging, UI ve storage'ın minimum expected runtime cost'unu belirleyecektir.)*

---

# 204. Configuration B Incremental Cost (Configuration B Ek Maliyeti)

```text
Cost_B_minus_A =
ResourceMetric_B -
ResourceMetric_A
```

---

# 205. Configuration C Incremental Cost (Configuration C Ek Maliyeti)

```text
Cost_C_minus_A =
ResourceMetric_C -
ResourceMetric_A
```

---

# 206. Configuration D Incremental Cost (Configuration D Ek Maliyeti)

```text
Cost_D_minus_A =
ResourceMetric_D -
ResourceMetric_A
```

---

# 207. Resource Metric May Differ by Domain (Kaynak Metriği Alana Göre Değişebilir)

The comparison may be performed separately for CPU, memory, battery, and storage. *(Karşılaştırma CPU, memory, battery ve storage için ayrı ayrı gerçekleştirilebilir.)*

---

# 208. Accuracy–Cost Tradeoff (Accuracy–Cost Tradeoff)

Configuration comparison will pair navigation improvement with resource cost where useful. *(Configuration comparison kullanışlı olduğunda navigation improvement ile resource cost'u eşleştirecektir.)*

---

# 209. Example Tradeoff Metric (Örnek Tradeoff Metriği)

A configuration may reduce median position error while increasing battery drain. *(Bir configuration median position error'ı azaltırken battery drain'i artırabilir.)*

Both outcomes will be reported. *(Her iki sonuç da raporlanacaktır.)*

---

# 210. No Composite Efficiency Score Initially (Başlangıçta Composite Efficiency Score Olmaması)

NAVGUARD will not invent one arbitrary composite score that mixes accuracy, CPU, battery, and memory with subjective weights. *(NAVGUARD accuracy, CPU, battery ve memory'yi subjective weight'lerle birleştiren keyfi tek composite score uydurmayacaktır.)*

---

# 211. Separate Metric Reporting Is Preferred (Ayrı Metrik Raporlama Tercih Edilir)

Tradeoffs will be shown through separate measurable quantities. *(Tradeoff'lar ayrı measurable quantity'ler üzerinden gösterilecektir.)*

---

# 212. Performance Benchmark Session Types (Performans Benchmark Session Türleri)

```text
PERF-A-PDR
PERF-B-HEADING
PERF-C-ARCORE
PERF-D-FULL
PERF-ENDURANCE
PERF-STORAGE
PERF-AI
PERF-UI
```

---

# 213. AI Micro-Benchmark Protocol (AI Micro-Benchmark Protokolü)

The AI micro-benchmark will load the frozen model once and execute repeated representative inference windows. *(AI micro-benchmark frozen model'i bir kez load edecek ve repeated representative inference window'lar çalıştıracaktır.)*

---

# 214. AI Input Selection (AI Input Seçimi)

Benchmark windows should include representative motion classes rather than only one unusually easy tensor. *(Benchmark window'lar yalnızca tek unusually easy tensor yerine representative motion class'ları içermelidir.)*

---

# 215. AI Timing Sample Count (AI Timing Sample Sayısı)

A sufficiently large repeated inference set will be used to calculate stable latency percentiles. *(Stable latency percentile hesaplamak için yeterince büyük repeated inference set kullanılacaktır.)*

---

# 216. Exact AI Timing Sample Count Pending (Kesin AI Timing Sample Sayısı Bekliyor)

The exact number of repeated inferences will be selected during implementation. *(Repeated inference'ların kesin sayısı implementation sırasında seçilecektir.)*

---

# 217. AI Benchmark Warm-Up Separation (AI Benchmark Warm-Up Ayrımı)

Warm-up runs will not be mixed silently into steady-state latency statistics. *(Warm-up run'lar steady-state latency statistic'lerine sessizce karıştırılmayacaktır.)*

---

# 218. Combined-Stack Benchmark Protocol (Birleşik Stack Benchmark Protokolü)

The full-stack benchmark will run the exact active configuration with sensor acquisition, GNSS reference logging, AI, ARCore where enabled, PDR, EKF, logging, map, and UI active together. *(Full-stack benchmark exact active configuration'ı sensor acquisition, GNSS reference logging, AI, enabled ise ARCore, PDR, EKF, logging, map ve UI birlikte aktifken çalıştıracaktır.)*

---

# 219. Combined Stack Is Authoritative for Practical Performance (Pratik Performans İçin Combined Stack Ana Ölçümdür)

Micro-benchmarks cannot fully predict contention between all runtime components. *(Micro-benchmark'lar tüm runtime component'leri arasındaki contention'ı tam olarak öngöremez.)*

---

# 220. Full-Stack CPU Metric (Full-Stack CPU Metriği)

Average, P95, and peak process CPU may be retained during the combined run. *(Combined run sırasında average, P95 ve peak process CPU korunabilir.)*

---

# 221. Full-Stack Memory Metric (Full-Stack Memory Metriği)

Memory start, steady-state, peak, and end values will be retained. *(Memory start, steady-state, peak ve end değerleri korunacaktır.)*

---

# 222. Full-Stack Battery Metric (Full-Stack Batarya Metriği)

Battery drop normalized by duration will be retained. *(Duration'a normalize battery drop korunacaktır.)*

---

# 223. Full-Stack Storage Metric (Full-Stack Storage Metriği)

Bytes written per minute will be retained. *(Dakika başına bytes written korunacaktır.)*

---

# 224. Full-Stack AI Metric (Full-Stack AI Metriği)

AI latency will also be measured while the full stack is active rather than only in isolation. *(AI latency yalnızca isolation'da değil full stack aktifken de ölçülecektir.)*

---

# 225. Contention Penalty (Contention Penalty)

```text
AIContentionPenalty =
AI_latency_full_stack -
AI_latency_isolated
```

---

# 226. Similar Contention Analysis for Other Components (Diğer Bileşenler İçin Benzer Contention Analizi)

Where useful, isolated and combined latency may be compared for PDR or EKF processing. *(Kullanışlı olduğunda PDR veya EKF processing için isolated ve combined latency karşılaştırılabilir.)*

---

# 227. Battery Benchmark Duration (Batarya Benchmark Süresi)

Battery tests must run long enough for percentage-based measurement to be interpretable. *(Battery testleri percentage-based measurement'ın yorumlanabilir olması için yeterince uzun sürmelidir.)*

---

# 228. Exact Battery Test Duration Pending (Kesin Batarya Test Süresi Bekliyor)

The exact formal battery-test duration will be frozen after pilot profiling. *(Kesin formal battery-test duration pilot profiling sonrasında sabitlenecektir.)*

---

# 229. Environmental Repeatability (Çevresel Tekrarlanabilirlik)

Battery and thermal comparisons should avoid mixing very different environmental conditions where possible. *(Battery ve thermal comparison'lar mümkün olduğunda çok farklı environmental condition'ları karıştırmamalıdır.)*

---

# 230. Performance Run Repeats (Performans Run Tekrarları)

Important resource measurements should be repeated to reduce the influence of one anomalous run. *(Önemli resource measurement'lar tek anomalous run etkisini azaltmak için tekrar edilmelidir.)*

---

# 231. Exact Repeat Count Pending (Kesin Tekrar Sayısı Bekliyor)

The final repeat count for each performance suite will be chosen based on available project time and observed variability. *(Her performance suite için final repeat count available project time ve observed variability'ye göre seçilecektir.)*

---

# 232. Median Resource Metrics (Median Kaynak Metrikleri)

Median values across repeated performance runs may be preferred for central reporting where outliers occur. *(Outlier oluştuğunda repeated performance run'lar arasındaki median value'lar central reporting için tercih edilebilir.)*

---

# 233. P95 Resource Metrics (P95 Kaynak Metrikleri)

P95 will be used where tail performance is operationally important, especially for inference or processing latency. *(P95 özellikle inference veya processing latency için tail performance operational olarak önemli olduğunda kullanılacaktır.)*

---

# 234. Peak Metrics Are Diagnostic (Peak Metrikler Diagnostic'tir)

Peak CPU or latency values will usually be diagnostic rather than the sole acceptance criterion. *(Peak CPU veya latency value'ları genellikle sole acceptance criterion yerine diagnostic olacaktır.)*

---

# 235. Performance Regression Testing (Performans Regression Testing)

Major architecture changes may trigger repeated performance benchmarks. *(Büyük architecture change'ler repeated performance benchmark tetikleyebilir.)*

---

# 236. Performance Baseline Version (Performans Baseline Sürümü)

A stable reference build may be retained to compare later optimization changes. *(Daha sonraki optimization change'leri karşılaştırmak için stable reference build korunabilir.)*

---

# 237. Optimization Must Not Break Accuracy (Optimizasyon Accuracy'yi Bozmamalıdır)

Performance optimization will not be accepted merely because latency improves. *(Performance optimization yalnızca latency iyileştiği için kabul edilmeyecektir.)*

Navigation correctness and model accuracy must remain valid. *(Navigation correctness ve model accuracy geçerli kalmalıdır.)*

---

# 238. Optimization Must Not Break Evidence (Optimizasyon Evidence'ı Bozmamalıdır)

Resource-saving changes must not reduce mandatory logging or bypass integrity checks. *(Resource-saving change'ler mandatory logging'i azaltmamalı veya integrity check'leri bypass etmemelidir.)*

---

# 239. Optimization Order (Optimizasyon Sırası)

NAVGUARD will first establish a correct measurable baseline and optimize only measured bottlenecks. *(NAVGUARD önce doğru measurable baseline oluşturacak ve yalnızca measured bottleneck'leri optimize edecektir.)*

---

# 240. Premature Optimization Is Avoided (Premature Optimization'dan Kaçınılır)

Complex delegate, quantization, background-thread, or native optimization will not be introduced without evidence that the existing implementation requires it. *(Complex delegate, quantization, background-thread veya native optimization mevcut implementation'ın buna ihtiyaç duyduğuna dair evidence olmadan eklenmeyecektir.)*

---

# 241. Performance Profiling Workflow (Performans Profiling Workflow'u)

```text
Measure
Identify Bottleneck
Isolate Cause
Optimize
Re-Test Correctness
Re-Test Performance
Document Change
```

---

# 242. Performance Change Record (Performans Değişiklik Kaydı)

Important optimization changes will be documented with before-and-after metrics. *(Önemli optimization change'ler before-and-after metric'lerle dokümante edilecektir.)*

---

# 243. Example Optimization Record (Örnek Optimizasyon Kaydı)

```text
changeId
buildBefore
buildAfter
metric
beforeValue
afterValue
navigationRegression
notes
```

---

# 244. Performance Evidence Artifacts (Performans Kanıt Artifact'ları)

Formal performance runs should produce inspectable evidence. *(Formal performance run'ları inspectable evidence üretmelidir.)*

---

# 245. Candidate Performance Evidence (Aday Performans Kanıtı)

```text
Performance manifest
CPU trace
Memory samples
AI latency CSV
Sensor timing CSV
Writer queue CSV
Battery record
Thermal record
Storage summary
Build identity
Session manifest
```

---

# 246. Performance Manifest (Performans Manifest'i)

A machine-readable performance summary may accompany formal performance runs. *(Machine-readable performance summary formal performance run'larına eşlik edebilir.)*

---

# 247. Candidate `PerformanceSummary` (Aday `PerformanceSummary`)

```text
PerformanceSummary
- sessionId
- buildId
- configuration
- durationS
- cpuAvg
- cpuP95
- cpuPeak
- memoryStartMb
- memoryPeakMb
- memoryEndMb
- aiLatencyMedianMs
- aiLatencyP95Ms
- sensorDropRate
- loggingDropRate
- storageMbPerMin
- batteryDropPercent
- batteryPerHour
- thermalStart
- thermalEnd
- finalizationLatencyS
```

---

# 248. Missing Performance Values (Eksik Performans Değerleri)

Unavailable resource metrics will remain unavailable rather than becoming zero. *(Unavailable resource metric'ler sıfır haline gelmek yerine unavailable kalacaktır.)*

---

# 249. Performance Analysis Environment (Performans Analiz Ortamı)

Python may be used to aggregate and visualize exported performance evidence. *(Python exported performance evidence'ı aggregate ve visualize etmek için kullanılabilir.)*

---

# 250. Mobile Diagnostics Role (Mobil Diagnostics Rolü)

The Android application may display live resource diagnostics for development. *(Android application development için live resource diagnostic gösterebilir.)*

Final reported values should preferably be reproducible offline from stored evidence where feasible. *(Final reported value'lar uygulanabilir olduğunda tercihen stored evidence'dan offline şekilde reproducible olmalıdır.)*

---

# 251. Performance Charts (Performans Grafikleri)

The final analysis may include CPU-over-time, memory-over-time, AI-latency distribution, battery-over-time, temperature-over-time, and writer-queue-over-time plots. *(Final analysis CPU-over-time, memory-over-time, AI-latency distribution, battery-over-time, temperature-over-time ve writer-queue-over-time plot'larını içerebilir.)*

---

# 252. Resource Comparison Table Candidate (Kaynak Karşılaştırma Tablosu Adayı)

| Metric (Metrik)                         | A — PDR |    B — Heading |     C — ARCore | D — Full NAVGUARD |
| --------------------------------------- | ------: | -------------: | -------------: | ----------------: |
| CPU Avg % *(CPU Ortalama %)*            |     TBD |            TBD |            TBD |               TBD |
| CPU P95 % *(CPU P95 %)*                 |     TBD |            TBD |            TBD |               TBD |
| Peak Memory MB *(Peak Memory MB)*       |     TBD |            TBD |            TBD |               TBD |
| Battery % / h *(Batarya % / saat)*      |     TBD |            TBD |            TBD |               TBD |
| Storage MB / min *(Storage MB / dk)*    |     TBD |            TBD |            TBD |               TBD |
| AI Median ms *(AI Medyan ms)*           |     N/A | N/A / Optional | N/A / Optional |               TBD |
| ARCore Tracking % *(ARCore Tracking %)* |     N/A |            N/A |            TBD |               TBD |

---

# 253. Endurance Table Candidate (Endurance Tablosu Adayı)

| Metric (Metrik)   | Start (Başlangıç) | End (Bitiş) | Change (Değişim) |
| ----------------- | ----------------: | ----------: | ---------------: |
| Memory MB         |               TBD |         TBD |              TBD |
| Battery %         |               TBD |         TBD |              TBD |
| Thermal State     |               TBD |         TBD |              TBD |
| Writer Queue      |               TBD |         TBD |              TBD |
| AI Median Latency |               TBD |         TBD |              TBD |

---

# 254. AI Performance Table Candidate (AI Performans Tablosu Adayı)

| Metric (Metrik)                                                | Result (Sonuç) |
| -------------------------------------------------------------- | -------------: |
| Model Size MB *(Model Boyutu MB)*                              |            TBD |
| Parameters *(Parametreler)*                                    |            TBD |
| Load Time ms *(Yükleme Süresi ms)*                             |            TBD |
| Warm-Up Latency ms *(Warm-Up Latency ms)*                      |            TBD |
| Median Inference ms *(Medyan Inference ms)*                    |            TBD |
| P95 Inference ms *(P95 Inference ms)*                          |            TBD |
| End-to-End Context Latency ms *(Uçtan Uca Context Latency ms)* |            TBD |

---

# 255. Logging Performance Table Candidate (Logging Performans Tablosu Adayı)

| Metric (Metrik)                               | Result (Sonuç) |
| --------------------------------------------- | -------------: |
| Produced Records *(Üretilen Kayıtlar)*        |            TBD |
| Written Records *(Yazılan Kayıtlar)*          |            TBD |
| Dropped Records *(Düşürülen Kayıtlar)*        |            TBD |
| Max Queue Depth *(Maksimum Queue Derinliği)*  |            TBD |
| Storage MB / min *(Storage MB / dk)*          |            TBD |
| Finalization Time s *(Finalization Süresi s)* |            TBD |

---

# 256. Battery Reporting Precision (Batarya Raporlama Hassasiyeti)

Battery results will not be presented with more precision than the measurement source supports. *(Battery sonuçları measurement source'un desteklediğinden daha fazla precision ile sunulmayacaktır.)*

---

# 257. CPU Reporting Precision (CPU Raporlama Hassasiyeti)

CPU measurements will state the measurement source and aggregation method where relevant. *(CPU measurement'ları ilgili olduğunda measurement source ve aggregation method'u belirtecektir.)*

---

# 258. Thermal Reporting Precision (Termal Raporlama Hassasiyeti)

Thermal results will distinguish direct temperature measurements from platform thermal-state indicators when both are available. *(Thermal result'lar her ikisi de available olduğunda direct temperature measurement ile platform thermal-state indicator'larını ayıracaktır.)*

---

# 259. No Cross-Device Generalization Claim (Cihazlar Arası Genelleme İddiası Olmaması)

Performance measured on the Redmi Note 9 Pro will not automatically be claimed for all Android devices. *(Redmi Note 9 Pro üzerinde measured performance otomatik olarak tüm Android cihazlar için iddia edilmeyecektir.)*

---

# 260. Performance Acceptance Philosophy (Performans Kabul Felsefesi)

Performance acceptance will focus on whether the selected configuration can sustain the required navigation workload reliably on the target device. *(Performance acceptance seçilen configuration'ın target device üzerinde gerekli navigation workload'u güvenilir şekilde sürdürebilip sürdüremediğine odaklanacaktır.)*

---

# 261. Hard Performance Gates (Sert Performans Gate'leri)

Certain failures are unacceptable regardless of average resource values. *(Bazı failure'lar average resource value'lardan bağımsız olarak kabul edilemezdir.)*

---

# 262. Crash Gate (Crash Gate'i)

A representative formal navigation session must not crash because of resource exhaustion. *(Temsili formal navigation session resource exhaustion nedeniyle crash olmamalıdır.)*

---

# 263. Memory Gate (Memory Gate'i)

Resource use must not show clearly unbounded memory growth during the frozen endurance protocol. *(Resource use frozen endurance protocol sırasında açıkça unbounded memory growth göstermemelidir.)*

---

# 264. Queue Gate (Queue Gate'i)

Mandatory writer or inference queues must not grow without bound during sustained valid operation. *(Mandatory writer veya inference queue'ları sustained valid operation sırasında sınırsız büyümemelidir.)*

---

# 265. Mandatory Logging Gate (Zorunlu Logging Gate'i)

Valid formal benchmark runs require required evidence streams to remain intact. *(Geçerli formal benchmark run'ları gerekli evidence stream'lerinin intact kalmasını gerektirir.)*

---

# 266. Thermal Stability Gate (Termal Stabilite Gate'i)

Thermal conditions must not repeatedly force application failure or make the selected configuration unusable during the intended session duration. *(Thermal condition'lar intended session duration boyunca repeated application failure oluşturmamalı veya selected configuration'ı unusable hale getirmemelidir.)*

---

# 267. AI Runtime Gate (AI Runtime Gate'i)

AI inference must remain sufficiently fast that operational motion context does not accumulate uncontrolled backlog. *(AI inference operational motion context'in uncontrolled backlog oluşturmaması için yeterince hızlı kalmalıdır.)*

---

# 268. Provisional AI Target Gate (Geçici AI Hedef Gate'i)

The existing provisional target remains below approximately 50 ms per inference, subject to final statistic definition. *(Mevcut geçici hedef final statistic definition'a bağlı olarak inference başına yaklaşık 50 ms'nin altında kalmaktadır.)*

---

# 269. Sensor Processing Gate (Sensör İşleme Gate'i)

The selected motion-sensor profile must be sustained without persistent processing backlog. *(Seçilen motion-sensor profile persistent processing backlog olmadan sürdürülebilmelidir.)*

---

# 270. Storage Gate (Storage Gate'i)

The application must predictably estimate required storage before formal sessions once measured logging rate is known. *(Measured logging rate bilindikten sonra uygulama formal session öncesinde gerekli storage'ı predictable şekilde tahmin edebilmelidir.)*

---

# 271. Finalization Gate (Finalization Gate'i)

Session finalization must complete without data corruption or indefinite blocking. *(Session finalization data corruption veya indefinite blocking olmadan tamamlanmalıdır.)*

---

# 272. UI Responsiveness Gate (UI Responsiveness Gate'i)

Critical navigation controls must remain usable under full-stack operation. *(Critical navigation control'lar full-stack operation altında usable kalmalıdır.)*

---

# 273. Performance Degradation Policy (Performans Bozulma Politikası)

If full NAVGUARD exceeds practical device limits, the system will degrade through documented optional-component fallbacks rather than silently losing required evidence. *(Full NAVGUARD practical device limit'lerini aşarsa sistem gerekli evidence'ı sessizce kaybetmek yerine documented optional-component fallback'ları üzerinden degrade olacaktır.)*

---

# 274. Example Degradation Order (Örnek Degradation Sırası)

A possible future degradation sequence may reduce diagnostic rendering before disabling navigation-critical processing. *(Olası gelecekteki degradation sequence navigation-critical processing'i disable etmeden önce diagnostic rendering'i azaltabilir.)*

---

# 275. Navigation-Critical Work Has Priority (Navigation-Critical İş Önceliklidir)

Sensor acquisition, timing, PDR, required fusion, integrity logging, and safety-critical state transitions have higher priority than decorative UI updates. *(Sensor acquisition, timing, PDR, required fusion, integrity logging ve safety-critical state transition'lar decorative UI update'lerden daha yüksek önceliğe sahiptir.)*

---

# 276. Diagnostic Charts Are First Optimization Candidate (Diagnostic Chart'lar İlk Optimization Adayıdır)

If UI resource load becomes excessive, high-rate diagnostics can be throttled before estimator functionality is reduced. *(UI resource load excessive hale gelirse estimator functionality azaltılmadan önce high-rate diagnostic'ler throttle edilebilir.)*

---

# 277. Map Rendering Is Secondary (Harita Render İkincildir)

Map animation fidelity is less important than estimator correctness and logging integrity. *(Map animation fidelity estimator correctness ve logging integrity'den daha az önemlidir.)*

---

# 278. ARCore Is Optional Enhancement (ARCore İsteğe Bağlı Geliştirmedir)

If ARCore proves too resource-intensive or unstable under certain conditions, PDR remains the required fallback. *(ARCore belirli koşullarda fazla resource-intensive veya unstable olduğunu kanıtlarsa PDR gerekli fallback olarak kalır.)*

---

# 279. Learned Step Length Is Optional Enhancement (Learned Step Length İsteğe Bağlı Geliştirmedir)

A computationally expensive learned step-length model will not be retained without measurable navigation benefit. *(Computationally expensive learned step-length model measurable navigation benefit olmadan korunmayacaktır.)*

---

# 280. Performance Optimization Priorities (Performans Optimizasyon Öncelikleri)

```text
1. Preserve correctness
2. Preserve evidence integrity
3. Remove measured bottlenecks
4. Reduce unnecessary UI work
5. Reduce redundant processing
6. Optimize AI if required
7. Optimize storage if required
```

---

# 281. Performance Test IDs (Performans Test ID'leri)

```text
PERF-CPU-001   PDR baseline CPU
PERF-CPU-002   full-stack CPU
PERF-CPU-003   ARCore CPU increment
PERF-CPU-004   AI CPU increment

PERF-MEM-001   startup memory
PERF-MEM-002   steady-state memory
PERF-MEM-003   endurance memory trend
PERF-MEM-004   repeated-session cleanup

PERF-AI-001    model load time
PERF-AI-002    warm-up latency
PERF-AI-003    median inference latency
PERF-AI-004    P95 inference latency
PERF-AI-005    full-stack inference latency
PERF-AI-006    stale backlog prevention

PERF-SEN-001   effective accel rate
PERF-SEN-002   effective gyro rate
PERF-SEN-003   effective magnetometer rate
PERF-SEN-004   sampling jitter
PERF-SEN-005   sensor gap count
PERF-SEN-006   processing backlog

PERF-EKF-001   prediction latency
PERF-EKF-002   update latency
PERF-PDR-001   step propagation latency
PERF-HDG-001   heading update latency

PERF-ARC-001   ARCore CPU impact
PERF-ARC-002   ARCore battery impact
PERF-ARC-003   ARCore thermal impact
PERF-ARC-004   tracking-loss cleanup

PERF-LOG-001   writer throughput
PERF-LOG-002   maximum writer queue
PERF-LOG-003   dropped records
PERF-LOG-004   backpressure behavior
PERF-LOG-005   finalization latency

PERF-STO-001   storage MB per minute
PERF-STO-002   estimated session size
PERF-STO-003   export package size
PERF-STO-004   export latency

PERF-UI-001    live navigation responsiveness
PERF-UI-002    map update load
PERF-UI-003    diagnostics chart load
PERF-UI-004    UI rebuild stability

PERF-BAT-001   PDR battery rate
PERF-BAT-002   full NAVGUARD battery rate
PERF-BAT-003   ARCore battery increment
PERF-BAT-004   endurance battery trend

PERF-THM-001   thermal start/end state
PERF-THM-002   thermal latency degradation
PERF-THM-003   thermal stability

PERF-END-001   long-duration stability
PERF-END-002   long-duration memory
PERF-END-003   long-duration queues
PERF-END-004   repeated session cycles
```

---

# 282. Minimum Successful Performance Test Set (Minimum Başarılı Performans Test Seti)

The minimum successful performance program will measure AI latency, sensor delivery, logging throughput, storage growth, battery consumption, memory behavior, and full-stack stability on the Redmi Note 9 Pro. *(Minimum başarılı performance program Redmi Note 9 Pro üzerinde AI latency, sensor delivery, logging throughput, storage growth, battery consumption, memory behavior ve full-stack stability ölçecektir.)*

---

# 283. Target Successful Performance Test Set (Hedef Başarılı Performans Test Seti)

The target program will additionally compare A-D CPU and battery cost, profile ARCore overhead, quantify contention effects, analyze thermal throttling, measure export/finalization cost, and perform long-duration repeated-session testing. *(Hedef program ek olarak A-D CPU ve battery cost'u karşılaştıracak, ARCore overhead'i profile edecek, contention effect'lerini quantify edecek, thermal throttling'i analiz edecek, export/finalization cost'u ölçecek ve long-duration repeated-session testing gerçekleştirecektir.)*

---

# 284. Optional Performance Enhancements (İsteğe Bağlı Performans İyileştirmeleri)

Optional enhancements may include delegate benchmarking. *(İsteğe bağlı iyileştirmeler delegate benchmarking içerebilir.)*

Optional enhancements may include neural-model quantization benchmarking. *(İsteğe bağlı iyileştirmeler neural-model quantization benchmarking içerebilir.)*

Optional enhancements may include automated profiler capture. *(İsteğe bağlı iyileştirmeler automated profiler capture içerebilir.)*

Optional enhancements may include cross-device performance comparison. *(İsteğe bağlı iyileştirmeler cross-device performance comparison içerebilir.)*

---

# 285. Performance Non-Goals (Performans Olmayan Hedefler)

NAVGUARD will not optimize for benchmark numbers at the expense of correctness. *(NAVGUARD correctness pahasına benchmark number'ları için optimize edilmeyecektir.)*

NAVGUARD will not disable mandatory logging merely to reduce CPU or storage usage. *(NAVGUARD CPU veya storage usage azaltmak için mandatory logging'i disable etmeyecektir.)*

NAVGUARD will not claim low battery consumption from one short run. *(NAVGUARD tek kısa run'dan low battery consumption iddia etmeyecektir.)*

---

# 286. Additional Performance Non-Goals (Ek Performans Olmayan Hedefler)

NAVGUARD will not claim universal Android performance from one Redmi Note 9 Pro measurement set. *(NAVGUARD tek Redmi Note 9 Pro measurement setinden universal Android performance iddia etmeyecektir.)*

NAVGUARD will not treat model inference latency as equivalent to complete end-to-end motion-response latency. *(NAVGUARD model inference latency'yi complete end-to-end motion-response latency ile eşdeğer kabul etmeyecektir.)*

NAVGUARD will not use a composite efficiency score with arbitrary weights. *(NAVGUARD arbitrary weight'lere sahip composite efficiency score kullanmayacaktır.)*

---

# 287. Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kararlar)

Performance will be evaluated on the physical Xiaomi Redmi Note 9 Pro. *(Performans fiziksel Xiaomi Redmi Note 9 Pro üzerinde değerlendirilecektir.)*

---

# 288. Build Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Build Kararları)

Final performance conclusions will not rely solely on debug builds. *(Nihai performance conclusion'lar yalnızca debug build'lere dayanmayacaktır.)*

---

# 289. Configuration Comparison Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Yapılandırma Karşılaştırma Kararları)

Resource cost will be compared across A-D where practical. *(Resource cost uygulanabilir olduğunda A-D arasında karşılaştırılacaktır.)*

---

# 290. Sensor Performance Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Sensör Performans Kararları)

Actual delivered sensor rate will be measured from timestamps. *(Gerçek delivered sensor rate timestamp'lardan ölçülecektir.)*

Requested rate will not be treated as evidence of achieved rate. *(Requested rate achieved rate evidence'ı olarak ele alınmayacaktır.)*

---

# 291. AI Performance Decisions Frozen by This Document (Bu Dokümanla Sabitlenen AI Performans Kararları)

Model-load time, warm-up inference, steady-state median latency, P95 latency, and full-stack latency will remain separate concepts. *(Model-load time, warm-up inference, steady-state median latency, P95 latency ve full-stack latency ayrı concept'ler olarak kalacaktır.)*

---

# 292. AI Target Decisions Frozen by This Document (Bu Dokümanla Sabitlenen AI Hedef Kararları)

The provisional inference target remains approximately below 50 ms per inference on the target device. *(Geçici inference hedefi target device üzerinde inference başına yaklaşık 50 ms'nin altında kalmaktadır.)*

---

# 293. AI End-to-End Decisions Frozen by This Document (Bu Dokümanla Sabitlenen AI Uçtan Uca Kararları)

Inference runtime will not be presented as total motion-classification response latency. *(Inference runtime total motion-classification response latency olarak sunulmayacaktır.)*

---

# 294. Memory Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Memory Kararları)

All continuous buffers and queues must remain explicitly bounded. *(Tüm continuous buffer ve queue'lar explicit bounded kalmalıdır.)*

---

# 295. Logging Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Logging Kararları)

Disk writing will remain decoupled from high-frequency acquisition. *(Disk writing high-frequency acquisition'dan decoupled kalacaktır.)*

Mandatory benchmark evidence should have zero dropped records. *(Mandatory benchmark evidence sıfır dropped record'a sahip olmalıdır.)*

---

# 296. Storage Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Storage Kararları)

Storage requirements will be derived from measured bytes-per-minute rather than guessed session sizes. *(Storage requirement'ları guessed session size yerine measured bytes-per-minute değerinden türetilecektir.)*

---

# 297. Battery Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Batarya Kararları)

Battery use will be normalized by controlled session duration. *(Battery use controlled session duration'a normalize edilecektir.)*

No arbitrary final battery threshold is frozen before device measurements. *(Device measurement öncesinde arbitrary final battery threshold sabitlenmemiştir.)*

---

# 298. Thermal Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Termal Kararlar)

Thermal behavior will be evaluated during longer combined-stack operation. *(Thermal behavior daha uzun combined-stack operation sırasında değerlendirilecektir.)*

---

# 299. UI Performance Decisions Frozen by This Document (Bu Dokümanla Sabitlenen UI Performans Kararları)

UI refresh and map rendering may be throttled independently from estimator processing. *(UI refresh ve map rendering estimator processing'den bağımsız throttle edilebilir.)*

UI throttling must not change estimator evidence or metric results. *(UI throttling estimator evidence veya metric result'ları değiştirmemelidir.)*

---

# 300. ARCore Performance Decisions Frozen by This Document (Bu Dokümanla Sabitlenen ARCore Performans Kararları)

ARCore resource cost will be measured explicitly rather than assumed. *(ARCore resource cost varsayılmak yerine açık şekilde ölçülecektir.)*

PDR remains the fallback if ARCore becomes unavailable or impractical. *(ARCore unavailable veya impractical hale gelirse PDR fallback olarak kalacaktır.)*

---

# 301. Optimization Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Optimizasyon Kararları)

NAVGUARD will optimize measured bottlenecks rather than introducing premature complexity. *(NAVGUARD premature complexity eklemek yerine measured bottleneck'leri optimize edecektir.)*

---

# 302. Endurance Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Endurance Kararları)

At least one dedicated long-duration combined-stack stability test is required. *(En az bir dedicated long-duration combined-stack stability test gereklidir.)*

---

# 303. Performance Integrity Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Performans Bütünlük Kararları)

Performance optimization may not bypass Ground Truth Firewall, logging integrity, or benchmark evidence requirements. *(Performance optimization Ground Truth Firewall, logging integrity veya benchmark evidence requirement'larını bypass edemez.)*

---

# 304. Decisions Pending Device Profiling (Cihaz Profiling'ini Bekleyen Kararlar)

The final acceptable CPU range remains pending measurements. *(Nihai acceptable CPU range measurement'ları beklemektedir.)*

The final acceptable memory-growth threshold remains pending endurance evidence. *(Nihai acceptable memory-growth threshold endurance evidence'ını beklemektedir.)*

The final writer queue threshold remains pending logging stress tests. *(Nihai writer queue threshold logging stress testlerini beklemektedir.)*

---

# 305. Decisions Pending AI Deployment Tests (AI Deployment Testlerini Bekleyen Kararlar)

The final latency statistic used for the approximately 50 ms target remains pending mobile profiling. *(Yaklaşık 50 ms hedefi için kullanılacak final latency statistic mobile profiling'i beklemektedir.)*

The final delegate policy remains pending benchmark evidence. *(Nihai delegate policy benchmark evidence'ını beklemektedir.)*

The final quantization policy remains pending accuracy and latency comparison. *(Nihai quantization policy accuracy ve latency comparison'ı beklemektedir.)*

---

# 306. Decisions Pending Battery Tests (Batarya Testlerini Bekleyen Kararlar)

The final battery acceptance threshold remains pending controlled device measurements. *(Nihai battery acceptance threshold controlled device measurement'ları beklemektedir.)*

The final formal battery-test duration remains pending pilot profiling. *(Nihai formal battery-test duration pilot profiling'i beklemektedir.)*

---

# 307. Decisions Pending Thermal Tests (Termal Testleri Bekleyen Kararlar)

The final thermal warning and failure thresholds remain pending device-specific observations. *(Nihai thermal warning ve failure threshold'ları device-specific observation'ları beklemektedir.)*

---

# 308. Decisions Pending Storage Profiling (Storage Profiling Bekleyen Kararlar)

The final minimum free-storage requirement remains pending measured logging volume. *(Nihai minimum free-storage requirement measured logging volume'u beklemektedir.)*

---

# 309. Decisions Pending Endurance Pilots (Endurance Pilotlarını Bekleyen Kararlar)

The final endurance-session duration remains pending shorter stability tests. *(Nihai endurance-session duration daha kısa stability testlerini beklemektedir.)*

---

# 310. Final Performance, Battery & Resource Testing Statement (Nihai Performans, Batarya ve Kaynak Testleri Bildirimi)

**NAVGUARD will evaluate practical mobile performance on the Xiaomi Redmi Note 9 Pro by measuring CPU utilization, memory behavior, sensor-delivery stability, AI inference latency, PDR and EKF processing latency, ARCore overhead, logging throughput, storage growth, battery consumption, thermal behavior, UI responsiveness, and long-duration stability.** *(NAVGUARD pratik mobil performansı Xiaomi Redmi Note 9 Pro üzerinde CPU utilization, memory behavior, sensor-delivery stability, AI inference latency, PDR ve EKF processing latency, ARCore overhead, logging throughput, storage growth, battery consumption, thermal behavior, UI responsiveness ve long-duration stability ölçerek değerlendirecektir.)*

**Configurations A through D will be compared where practical so the project can quantify not only the navigation benefit of improved heading, ARCore, AI, and full sensor fusion, but also the incremental CPU, memory, battery, storage, and thermal cost introduced by those capabilities.** *(Configuration A-D uygulanabilir olduğunda karşılaştırılacak; böylece proje improved heading, ARCore, AI ve full sensor fusion'ın yalnızca navigation benefit'ini değil, bu capability'lerin eklediği incremental CPU, memory, battery, storage ve thermal cost'u da quantify edebilecektir.)*

**AI performance will separate model loading, warm-up, steady-state inference, P95 inference, full-stack inference, and end-to-end motion-context latency so a small neural-runtime number cannot be misrepresented as complete navigation response time.** *(AI performance model loading, warm-up, steady-state inference, P95 inference, full-stack inference ve end-to-end motion-context latency'yi ayıracak; böylece küçük neural-runtime number complete navigation response time olarak yanlış sunulamayacaktır.)*

**All continuous sensor, AI, UI, diagnostic, and writer buffers will remain bounded, and long-duration testing will explicitly verify that memory, writer queues, inference queues, listeners, ARCore sessions, GNSS callbacks, LiteRT resources, and Flutter subscriptions do not accumulate across sustained operation or repeated session cycles.** *(Tüm continuous sensor, AI, UI, diagnostic ve writer buffer'ları bounded kalacak ve long-duration testing memory, writer queue'ları, inference queue'ları, listener'lar, ARCore session'ları, GNSS callback'leri, LiteRT resource'ları ve Flutter subscription'larının sustained operation veya repeated session cycle'larda accumulate etmediğini açık şekilde doğrulayacaktır.)*

**Mandatory evidence logging will take priority over decorative UI work, while map rendering and diagnostics may be throttled or downsampled independently when necessary so performance optimization never reduces estimator correctness, Ground Truth Firewall integrity, or benchmark reproducibility.** *(Mandatory evidence logging decorative UI work'e göre öncelikli olacak, map rendering ve diagnostic'ler gerektiğinde bağımsız throttle veya downsample edilebilecek; böylece performance optimization estimator correctness, Ground Truth Firewall integrity veya benchmark reproducibility'yi hiçbir zaman azaltmayacaktır.)*

**Battery and thermal results will be treated as target-device engineering measurements rather than universal smartphone claims, and final thresholds will be derived from controlled Redmi Note 9 Pro evidence rather than invented before profiling.** *(Battery ve thermal result'lar universal smartphone claim yerine target-device engineering measurement olarak ele alınacak ve final threshold'lar profiling öncesinde uydurulmak yerine controlled Redmi Note 9 Pro evidence'ından türetilecektir.)*

**The final performance decision will therefore consider both navigation benefit and resource cost, allowing NAVGUARD to identify whether the full AI-assisted configuration is practically sustainable or whether a lighter fallback configuration provides a better operational tradeoff on the target hardware.** *(Nihai performance decision hem navigation benefit hem resource cost'u dikkate alacak; böylece NAVGUARD tam AI-assisted configuration'ın pratik olarak sürdürülebilir olup olmadığını veya daha lightweight fallback configuration'ın target hardware üzerinde daha iyi operational tradeoff sağlayıp sağlamadığını belirleyebilecektir.)*

---

# 311. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development Performance, Battery & Resource Testing Specification Completed *(Doküman Durumu: Geliştirme Öncesi Performans, Batarya ve Kaynak Testleri Spesifikasyonu Tamamlandı)*

**Authoritative Performance Device:** Xiaomi Redmi Note 9 Pro *(Ana Performans Cihazı: Xiaomi Redmi Note 9 Pro)*

**Debug-Only Final Performance Evidence:** Forbidden *(Yalnızca Debug Final Performans Kanıtı: Yasak)*

**Primary Resource Domains:** CPU + Memory + AI + Sensors + ARCore + Logging + Storage + Battery + Thermal + UI *(Temel Kaynak Alanları: CPU + Memory + AI + Sensors + ARCore + Logging + Storage + Battery + Thermal + UI)*

**Configuration Resource Comparison:** A / B / C / D *(Yapılandırma Kaynak Karşılaştırması: A / B / C / D)*

**Actual Sensor Rate Measurement:** Timestamp-Based *(Gerçek Sensör Rate Ölçümü: Timestamp-Based)*

**Requested Sensor Rate as Evidence:** Forbidden *(Requested Sensor Rate'i Evidence Olarak Kullanma: Yasak)*

**Continuous Buffers:** Bounded *(Continuous Buffer'lar: Bounded)*

**Sensor Processing Backlog:** Must Not Grow Persistently *(Sensor Processing Backlog: Sürekli Büyümemeli)*

**PDR Processing:** Lightweight Target *(PDR Processing: Lightweight Hedef)*

**EKF Initial State:** `[E,N,ψ]` *(EKF İlk State: `[E,N,ψ]`)*

**AI Runtime:** On-Device *(AI Runtime: On-Device)*

**AI Model Load Time:** Measured Separately *(AI Model Load Time: Ayrı Ölçülür)*

**AI Warm-Up Latency:** Measured Separately *(AI Warm-Up Latency: Ayrı Ölçülür)*

**AI Median Inference Latency:** Mandatory Metric *(AI Median Inference Latency: Zorunlu Metrik)*

**AI P95 Inference Latency:** Mandatory Metric *(AI P95 Inference Latency: Zorunlu Metrik)*

**Full-Stack AI Latency:** Required *(Full-Stack AI Latency: Gerekli)*

**End-to-End Motion Context Latency:** Separate Metric *(End-to-End Motion Context Latency: Ayrı Metrik)*

**Provisional AI Inference Target:** Approximately `<50 ms` *(Geçici AI Inference Hedefi: Yaklaşık `<50 ms`)*

**Final Statistic for 50 ms Target:** Pending Device Profiling *(50 ms Hedefi İçin Nihai Statistic: Device Profiling Bekliyor)*

**CPU Baseline:** Required *(CPU Baseline: Gerekli)*

**Memory Baseline:** Required *(Memory Baseline: Gerekli)*

**Unbounded Memory Growth:** Failure *(Unbounded Memory Growth: Hata)*

**Repeated Session Cleanup Test:** Mandatory *(Repeated Session Cleanup Test: Zorunlu)*

**ARCore Resource Cost:** Explicitly Measured *(ARCore Resource Cost: Açık Şekilde Ölçülür)*

**PDR Fallback if ARCore Impractical:** Mandatory *(ARCore Pratik Değilse PDR Fallback: Zorunlu)*

**Logging Architecture:** Asynchronous / Decoupled *(Logging Mimarisi: Asynchronous / Decoupled)*

**Mandatory Benchmark Log Drops:** Target `0` *(Zorunlu Benchmark Log Drop: Hedef `0`)*

**Writer Queue:** Bounded *(Writer Queue: Bounded)*

**Logging Backpressure Test:** Mandatory *(Logging Backpressure Test: Zorunlu)*

**Storage Growth Metric:** MB / Minute *(Storage Growth Metriği: MB / Dakika)*

**Final Free-Space Requirement:** Pending Storage Profiling *(Nihai Boş Alan Gereksinimi: Storage Profiling Bekliyor)*

**Session Finalization Latency:** Measured *(Session Finalization Latency: Ölçülür)*

**Export Latency:** Measured for Representative Sessions *(Export Latency: Temsili Session'lar İçin Ölçülür)*

**Battery Testing While Charging:** Forbidden for Principal Comparison *(Şarj Sırasında Battery Testing: Temel Karşılaştırmada Yasak)*

**Battery Normalization:** Per Controlled Duration *(Battery Normalization: Controlled Duration Başına)*

**Final Battery Threshold:** Pending Physical Measurement *(Nihai Batarya Eşiği: Fiziksel Ölçüm Bekliyor)*

**Thermal Testing:** Mandatory for Long Full-Stack Runs *(Thermal Testing: Uzun Full-Stack Run'lar İçin Zorunlu)*

**Final Thermal Thresholds:** Pending Device Evidence *(Nihai Thermal Threshold'lar: Device Evidence Bekliyor)*

**UI Rendering Rate:** Independent from Estimator Rate *(UI Rendering Rate: Estimator Rate'ten Bağımsız)*

**UI Downsampling:** Allowed for Diagnostics / Visualization *(UI Downsampling: Diagnostics / Visualization İçin İzinli)*

**Estimator Data Downsampling for UI Performance:** Forbidden *(UI Performansı İçin Estimator Data Downsampling: Yasak)*

**Dedicated Endurance Test:** Mandatory *(Dedicated Endurance Test: Zorunlu)*

**Endurance Duration:** Pending Pilot Profiling *(Endurance Duration: Pilot Profiling Bekliyor)*

**Performance Optimization Strategy:** Measure First, Optimize Bottlenecks *(Performans Optimizasyon Stratejisi: Önce Ölç, Bottleneck Optimize Et)*

**Premature Complex Optimization:** Avoided *(Premature Complex Optimization: Kaçınılır)*

**Optimization May Reduce Integrity:** Forbidden *(Optimization'ın Integrity'yi Azaltması: Yasak)*

**Composite Accuracy–Battery Score:** Not Used *(Composite Accuracy–Battery Score: Kullanılmaz)*

**Performance Generalization Beyond Redmi Note 9 Pro:** Not Claimed *(Redmi Note 9 Pro Dışına Performans Genelleme: İddia Edilmez)*

**Final CPU Acceptance Range:** Pending Profiling *(Nihai CPU Kabul Aralığı: Profiling Bekliyor)*

**Final Memory-Growth Threshold:** Pending Endurance Test *(Nihai Memory-Growth Threshold: Endurance Test Bekliyor)*

**Final Writer Queue Threshold:** Pending Stress Test *(Nihai Writer Queue Threshold: Stress Test Bekliyor)*

**Final Battery-Test Duration:** Pending Pilot Profiling *(Nihai Battery-Test Duration: Pilot Profiling Bekliyor)*

**Final Thermal Warning Thresholds:** Pending Physical Tests *(Nihai Thermal Warning Threshold'ları: Fiziksel Testler Bekliyor)*

**Final Delegate Policy:** Pending Benchmark *(Nihai Delegate Policy: Benchmark Bekliyor)*

**Final Quantization Policy:** Pending Accuracy / Latency Comparison *(Nihai Quantization Policy: Accuracy / Latency Karşılaştırması Bekliyor)*

**Next Documentation Item:** 37 — Risk Analysis & Fallback Strategy *(Sonraki Dokümantasyon Öğesi: 37 — Risk Analizi ve Fallback Stratejisi)*
