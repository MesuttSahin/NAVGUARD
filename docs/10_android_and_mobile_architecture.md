# 10 — Android & Mobile Architecture (Android ve Mobil Mimari)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the Android-specific and Flutter-specific software architecture of the NAVGUARD mobile application. *(Bu doküman, NAVGUARD mobil uygulamasının Android’e özgü ve Flutter’a özgü yazılım mimarisini tanımlar.)*

The document specifies the responsibility boundaries between Flutter, Dart, Kotlin, native Android APIs, ARCore, LiteRT, local storage, and the application state-management system. *(Doküman; Flutter, Dart, Kotlin, native Android API’leri, ARCore, LiteRT, yerel depolama ve uygulama durum yönetimi sistemi arasındaki sorumluluk sınırlarını tanımlar.)*

The objective is to create a mobile architecture that can acquire high-frequency sensor data reliably while maintaining a responsive Flutter interface and a modular navigation pipeline. *(Amaç, tepki verebilir bir Flutter arayüzünü ve modüler bir navigasyon hattını korurken yüksek frekanslı sensör verilerini güvenilir şekilde toplayabilen bir mobil mimari oluşturmaktır.)*

---

# 2. Mobile Architecture Objective (Mobil Mimari Hedefi)

NAVGUARD will use a hybrid Flutter and native Android architecture. *(NAVGUARD hibrit Flutter ve native Android mimarisi kullanacaktır.)*

Flutter will provide the primary application, user-interface, experiment-management, and visualization environment. *(Flutter temel uygulama, kullanıcı arayüzü, deney yönetimi ve görselleştirme ortamını sağlayacaktır.)*

Kotlin will provide direct access to Android functionality where hardware timing, platform lifecycle, ARCore, LiteRT, or sensor control requires native implementation. *(Kotlin; donanım zamanlaması, platform yaşam döngüsü, ARCore, LiteRT veya sensör kontrolünün native uygulama gerektirdiği yerlerde Android işlevlerine doğrudan erişim sağlayacaktır.)*

The architecture will avoid implementing native functionality merely for complexity or prestige. *(Mimari yalnızca karmaşıklık veya gösteriş amacıyla native işlev geliştirmekten kaçınacaktır.)*

Native Android code will be used only where it provides a measurable technical advantage. *(Native Android kodu yalnızca ölçülebilir teknik avantaj sağladığı yerlerde kullanılacaktır.)*

---

# 3. High-Level Mobile Architecture (Üst Seviye Mobil Mimari)

```
┌─────────────────────────────────────────────────────┐
│ Flutter Presentation Layer                         │
│ (Flutter Sunum Katmanı)                            │
│                                                     │
│ Screens / Widgets / Maps / Charts / User Controls  │
└───────────────────────┬─────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────┐
│ Flutter Application Layer                          │
│ (Flutter Uygulama Katmanı)                         │
│                                                     │
│ Riverpod / Controllers / Session / Navigation Mode │
└───────────────────────┬─────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────┐
│ Dart Domain & Navigation Core                      │
│ (Dart Domain ve Navigasyon Çekirdeği)              │
│                                                     │
│ PDR / Coordinates / Heading / Fusion / Evaluation  │
└───────────────────────┬─────────────────────────────┘
                        │
              Platform Interface Layer
              (Platform Arayüz Katmanı)
                        │
          ┌─────────────┴─────────────┐
          ▼                           ▼
┌──────────────────────┐    ┌────────────────────────┐
│ Kotlin Native Layer  │    │ Local Data Layer       │
│ (Kotlin Native)      │    │ (Yerel Veri Katmanı)   │
│                      │    │                        │
│ Sensors              │    │ SQLite                 │
│ GNSS                 │    │ CSV / JSON             │
│ ARCore               │    │ Session Files          │
│ LiteRT               │    │ Export                 │
└───────────┬──────────┘    └────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────────────────┐
│ Android Platform & Physical Hardware               │
│ (Android Platformu ve Fiziksel Donanım)            │
└─────────────────────────────────────────────────────┘
```

---

# 4. Architectural Responsibility Rule (Mimari Sorumluluk Kuralı)

Each responsibility must have one primary architectural owner. *(Her sorumluluğun bir birincil mimari sahibi olmalıdır.)*

The same navigation calculation should not be independently implemented in both Flutter and Kotlin unless a test or reference implementation specifically requires duplication. *(Aynı navigasyon hesaplaması, bir test veya referans uygulaması açıkça tekrar gerektirmediği sürece hem Flutter hem Kotlin içerisinde bağımsız olarak geliştirilmemelidir.)*

Duplicated business logic increases the risk of inconsistent experimental results. *(Tekrarlanan iş mantığı tutarsız deneysel sonuç riskini artırır.)*

---

# 5. Flutter Responsibility Boundary (Flutter Sorumluluk Sınırı)

Flutter will be responsible for application presentation and high-level orchestration. *(Flutter uygulama sunumu ve yüksek seviyeli orkestrasyondan sorumlu olacaktır.)*

Flutter responsibilities will include screen navigation, application state, experiment configuration, session control, route visualization, result visualization, user feedback, and research dashboards. *(Flutter sorumlulukları ekran navigasyonu, uygulama durumu, deney yapılandırması, oturum kontrolü, rota görselleştirmesi, sonuç görselleştirmesi, kullanıcı geri bildirimi ve araştırma dashboard’larını içerecektir.)*

Flutter will consume processed or summarized navigation state rather than directly rendering every raw high-frequency sensor event. *(Flutter her ham yüksek frekanslı sensör olayını doğrudan render etmek yerine işlenmiş veya özetlenmiş navigasyon durumunu kullanacaktır.)*

---

# 6. Native Android Responsibility Boundary (Native Android Sorumluluk Sınırı)

The native Kotlin layer will own hardware-sensitive Android integrations. *(Native Kotlin katmanı donanıma duyarlı Android entegrasyonlarının sahibi olacaktır.)*

The initial native responsibilities will include Android sensor access, sensor metadata, GNSS access, ARCore lifecycle management, and LiteRT inference. *(İlk native sorumluluklar Android sensör erişimi, sensör metadata bilgisi, GNSS erişimi, ARCore yaşam döngüsü yönetimi ve LiteRT çıkarımını içerecektir.)*

Additional Android-specific functionality may be moved into Kotlin only when profiling or platform limitations justify the change. *(Ek Android’e özgü işlevler yalnızca profilleme veya platform kısıtları değişikliği gerekçelendirdiğinde Kotlin içerisine taşınabilir.)*

---

# 7. Dart Domain Layer (Dart Domain Katmanı)

The Dart Domain Layer will contain platform-independent NAVGUARD models and navigation logic where practical. *(Dart Domain Katmanı uygulanabilir olduğu ölçüde platformdan bağımsız NAVGUARD modellerini ve navigasyon mantığını içerecektir.)*

This layer will avoid dependencies on Flutter widgets and Android APIs. *(Bu katman Flutter widget’larına ve Android API’lerine bağımlılıktan kaçınacaktır.)*

The separation will allow important algorithms to be unit tested without launching an Android application. *(Bu ayrım önemli algoritmaların Android uygulaması başlatılmadan birim test edilmesine olanak sağlayacaktır.)*

---

# 8. Candidate Dart Domain Responsibilities (Aday Dart Domain Sorumlulukları)

The Dart navigation core may contain coordinate transformations. *(Dart navigasyon çekirdeği koordinat dönüşümlerini içerebilir.)*

The Dart navigation core may contain deterministic step-processing logic. *(Dart navigasyon çekirdeği deterministik adım işleme mantığını içerebilir.)*

The Dart navigation core may contain heading normalization and fusion logic. *(Dart navigasyon çekirdeği yön normalizasyonu ve füzyon mantığını içerebilir.)*

The Dart navigation core may contain PDR propagation. *(Dart navigasyon çekirdeği PDR ilerletmesini içerebilir.)*

The Dart navigation core may contain the EKF implementation if profiling demonstrates acceptable performance. *(Profilleme kabul edilebilir performans gösterirse Dart navigasyon çekirdeği EKF uygulamasını içerebilir.)*

The Dart navigation core may contain uncertainty calculations and evaluation metrics. *(Dart navigasyon çekirdeği belirsizlik hesaplamalarını ve değerlendirme metriklerini içerebilir.)*

---

# 9. Native Performance Escalation Rule (Native Performans Yükseltme Kuralı)

Dart will remain the preferred implementation environment for platform-independent navigation mathematics until measurements demonstrate a performance problem. *(Ölçümler bir performans problemi gösterene kadar Dart platformdan bağımsız navigasyon matematiği için tercih edilen uygulama ortamı olarak kalacaktır.)*

An algorithm will not be moved to Kotlin simply because native code is assumed to be faster. *(Bir algoritma yalnızca native kodun daha hızlı olduğu varsayıldığı için Kotlin’e taşınmayacaktır.)*

Performance-sensitive migration must be justified by profiling evidence. *(Performansa duyarlı taşıma işlemi profilleme kanıtıyla gerekçelendirilmelidir.)*

---

# 10. Platform Interface Layer (Platform Arayüz Katmanı)

Flutter and native Android functionality will communicate through explicit platform interfaces. *(Flutter ve native Android işlevleri açık platform arayüzleri üzerinden iletişim kuracaktır.)*

The platform interface will hide Kotlin implementation details from the Flutter application layer. *(Platform arayüzü Kotlin uygulama ayrıntılarını Flutter uygulama katmanından gizleyecektir.)*

Flutter code should depend on Dart interfaces rather than directly depend on arbitrary platform-channel names throughout the application. *(Flutter kodu uygulamanın her yerine dağılmış keyfi platform-channel adlarına doğrudan bağımlı olmak yerine Dart arayüzlerine bağımlı olmalıdır.)*

---

# 11. Platform Channel Architecture (Platform Channel Mimarisi)

NAVGUARD will separate command-oriented platform communication from continuous event streaming. *(NAVGUARD komut odaklı platform iletişimini sürekli olay akışından ayıracaktır.)*

Command operations will use method-style communication. *(Komut işlemleri metot tarzı iletişim kullanacaktır.)*

Continuous platform measurements will use event-style streaming where Flutter requires those measurements. *(Sürekli platform ölçümleri Flutter bu ölçümlere ihtiyaç duyduğunda olay tarzı streaming kullanacaktır.)*

---

# 12. Proposed Platform Interfaces (Önerilen Platform Arayüzleri)

```
NavguardSensorPlatform
NavguardGnssPlatform
NavguardArcorePlatform
NavguardAiPlatform
NavguardDevicePlatform
```

These are logical interface names rather than mandatory final class names. *(Bunlar zorunlu nihai sınıf adları yerine mantıksal arayüz adlarıdır.)*

Their responsibilities must remain separate even if implementation naming changes. *(Uygulama adlandırması değişse bile sorumlulukları ayrı kalmalıdır.)*

---

# 13. Sensor Platform Commands (Sensör Platform Komutları)

The sensor platform interface should support starting sensor acquisition. *(Sensör platform arayüzü sensör veri toplamayı başlatmayı desteklemelidir.)*

The sensor platform interface should support stopping sensor acquisition. *(Sensör platform arayüzü sensör veri toplamayı durdurmayı desteklemelidir.)*

The sensor platform interface should support requesting the complete sensor inventory. *(Sensör platform arayüzü tam sensör envanterini istemeyi desteklemelidir.)*

The sensor platform interface should support changing the requested acquisition configuration before a formal session starts. *(Sensör platform arayüzü resmî bir oturum başlamadan önce talep edilen veri toplama yapılandırmasını değiştirmeyi desteklemelidir.)*

---

# 14. Sensor Platform Event Stream (Sensör Platform Olay Akışı)

The native sensor layer will generate timestamped internal measurements. *(Native sensör katmanı zaman damgalı dahili ölçümler üretecektir.)*

The full raw measurement stream does not need to cross into the Flutter widget tree. *(Tam ham ölçüm akışının Flutter widget ağacına geçmesine gerek yoktur.)*

Raw measurements required by the navigation core may cross the platform boundary through an optimized stream or may be preprocessed natively if later profiling justifies that architecture. *(Navigasyon çekirdeği tarafından gerekli ham ölçümler optimize edilmiş bir akış üzerinden platform sınırını geçebilir veya daha sonraki profilleme bu mimariyi gerekçelendirirse native olarak ön işlenebilir.)*

The final decision will be based on the Device Capability Audit and the first sensor-throughput benchmark. *(Nihai karar Cihaz Yetenek Denetimine ve ilk sensör throughput benchmark’ına dayanacaktır.)*

---

# 15. Channel Payload Principle (Channel Payload İlkesi)

Platform messages must use compact structured representations. *(Platform mesajları kompakt yapılandırılmış temsiller kullanmalıdır.)*

Unnecessary object nesting should be avoided for high-frequency communication. *(Yüksek frekanslı iletişim için gereksiz nesne iç içeliğinden kaçınılmalıdır.)*

Every time-dependent measurement must preserve its original timestamp. *(Zamana bağlı her ölçüm orijinal zaman damgasını korumalıdır.)*

Channel conversion must not replace the authoritative sensor timestamp with UI reception time. *(Channel dönüşümü ana sensör zaman damgasını UI alım zamanı ile değiştirmemelidir.)*

---

# 16. Sensor Event Internal Model (Sensör Olay Dahili Modeli)

A standardized inertial measurement model will be used inside the application. *(Uygulama içerisinde standartlaştırılmış bir ataletsel ölçüm modeli kullanılacaktır.)*

A logical model may include the following fields. *(Mantıksal bir model aşağıdaki alanları içerebilir.)*

```
SensorSample
- sensorType
- timestampNs
- x
- y
- z
- accuracy
- sequenceNumber
```

Additional metadata will be associated with the sensor source rather than duplicated in every sample where practical. *(Ek metadata bilgisi uygulanabilir olduğu ölçüde her örnekte tekrar edilmek yerine sensör kaynağıyla ilişkilendirilecektir.)*

---

# 17. Native Sensor Manager Component (Native Sensör Yönetici Bileşeni)

A dedicated Kotlin component will own Android SensorManager integration. *(Özel bir Kotlin bileşeni Android SensorManager entegrasyonunun sahibi olacaktır.)*

Only this component should register the primary Android sensor listeners used by formal NAVGUARD sessions. *(Yalnızca bu bileşen resmî NAVGUARD oturumlarında kullanılan temel Android sensör listener’larını kaydetmelidir.)*

This rule prevents multiple application modules from receiving duplicate high-frequency sensor streams unintentionally. *(Bu kural birden fazla uygulama modülünün istemeden yinelenen yüksek frekanslı sensör akışları almasını önler.)*

---

# 18. Sensor Listener Lifecycle (Sensör Listener Yaşam Döngüsü)

Sensor listeners will not remain registered permanently without a reason. *(Sensör listener’ları bir neden olmadan kalıcı olarak kayıtlı kalmayacaktır.)*

Formal acquisition will begin when an audit, diagnostic operation, dataset session, or navigation session requires sensor data. *(Resmî veri toplama bir denetim, tanısal işlem, veri seti oturumu veya navigasyon oturumu sensör verisi gerektirdiğinde başlayacaktır.)*

Listeners will be unregistered when the owning operation ends. *(Sahip işlem sona erdiğinde listener’ların kaydı kaldırılacaktır.)*

Lifecycle cleanup must also occur after unrecoverable session errors. *(Yaşam döngüsü temizliği kurtarılamaz oturum hatalarından sonra da gerçekleşmelidir.)*

---

# 19. Sensor Acquisition State (Sensör Veri Toplama Durumu)

The native sensor subsystem will maintain an explicit acquisition state. *(Native sensör alt sistemi açık bir veri toplama durumu tutacaktır.)*

The states may include STOPPED, STARTING, RUNNING, DEGRADED, and ERROR. *(Durumlar STOPPED, STARTING, RUNNING, DEGRADED ve ERROR içerebilir.)*

Flutter will consume a summarized version of this state for readiness and diagnostics. *(Flutter hazırlık ve tanı için bu durumun özetlenmiş bir sürümünü kullanacaktır.)*

---

# 20. Threading Principle (Thread Yönetimi İlkesi)

High-frequency sensor processing must not depend on the Flutter UI rendering thread. *(Yüksek frekanslı sensör işleme Flutter UI render thread’ine bağımlı olmamalıdır.)*

Long-running file writes must not execute synchronously on the UI thread. *(Uzun süren dosya yazma işlemleri UI thread üzerinde senkron olarak çalışmamalıdır.)*

AI inference must not repeatedly block interactive application controls. *(Yapay zekâ çıkarımı etkileşimli uygulama kontrollerini tekrar tekrar bloke etmemelidir.)*

ARCore processing must respect its Android runtime and rendering requirements without coupling all frame updates to Flutter rebuilds. *(ARCore işleme, tüm kare güncellemelerini Flutter rebuild işlemlerine bağlamadan kendi Android çalışma zamanı ve render gereksinimlerine uymalıdır.)*

---

# 21. Native Worker Strategy (Native Worker Stratejisi)

Kotlin components may use dedicated background execution contexts for sensor processing, logging, and AI inference when required. *(Kotlin bileşenleri gerektiğinde sensör işleme, kayıt ve yapay zekâ çıkarımı için özel arka plan çalışma bağlamları kullanabilir.)*

The exact executor, coroutine dispatcher, or thread mechanism will be selected according to the component’s runtime characteristics. *(Kesin executor, coroutine dispatcher veya thread mekanizması bileşenin çalışma zamanı özelliklerine göre seçilecektir.)*

Thread ownership must remain explicit to prevent accidental concurrent mutation of navigation state. *(Navigasyon durumunun yanlışlıkla eşzamanlı değiştirilmesini önlemek için thread sahipliği açık kalmalıdır.)*

---

# 22. Dart Isolate Policy (Dart Isolate Politikası)

Dart isolates may be used for computational work that proves too expensive for the main Dart isolate. *(Dart isolate’ları ana Dart isolate’ı için fazla maliyetli olduğu kanıtlanan hesaplama işleri için kullanılabilir.)*

Isolates will not be introduced before profiling identifies a meaningful need. *(Profilleme anlamlı bir ihtiyaç belirlemeden isolate’lar dahil edilmeyecektir.)*

Small PDR and coordinate operations are expected to remain lightweight enough for ordinary Dart execution. *(Küçük PDR ve koordinat işlemlerinin normal Dart çalışması için yeterince hafif kalması beklenmektedir.)*

---

# 23. UI Update Rate Decoupling (UI Güncelleme Hızının Ayrılması)

Flutter does not need to rebuild the interface for every sensor event. *(Flutter’ın her sensör olayında arayüzü yeniden oluşturmasına gerek yoktur.)*

Sensor data may arrive at approximately tens of samples per second while visible diagnostic values can update at a lower rate. *(Sensör verisi saniyede onlarca örnek hızında gelebilirken görünür tanısal değerler daha düşük hızda güncellenebilir.)*

Navigation-state visualization will use a controlled presentation update rate. *(Navigasyon durumu görselleştirmesi kontrollü bir sunum güncelleme hızı kullanacaktır.)*

This separation will reduce rendering overhead without reducing estimator frequency. *(Bu ayrım tahmin motoru frekansını azaltmadan render yükünü azaltacaktır.)*

---

# 24. Application State Management (Uygulama Durum Yönetimi)

Riverpod is the preferred state-management technology for the Flutter layer. *(Riverpod Flutter katmanı için tercih edilen durum yönetimi teknolojisidir.)*

Riverpod will manage application-level state rather than act as the raw high-frequency sensor transport. *(Riverpod ham yüksek frekanslı sensör taşıma sistemi olarak çalışmak yerine uygulama seviyesindeki durumu yönetecektir.)*

Providers will expose readiness state, active session state, navigation state, application configuration, session history, and selected diagnostic summaries. *(Provider’lar hazırlık durumunu, aktif oturum durumunu, navigasyon durumunu, uygulama yapılandırmasını, oturum geçmişini ve seçilen tanısal özetleri sunacaktır.)*

---

# 25. Proposed State Domains (Önerilen Durum Alanları)

The Flutter application may maintain separate state domains for system readiness. *(Flutter uygulaması sistem hazırlığı için ayrı bir durum alanı tutabilir.)*

The Flutter application may maintain separate state domains for navigation sessions. *(Flutter uygulaması navigasyon oturumları için ayrı bir durum alanı tutabilir.)*

The Flutter application may maintain separate state domains for live navigation. *(Flutter uygulaması canlı navigasyon için ayrı bir durum alanı tutabilir.)*

The Flutter application may maintain separate state domains for experiments and configuration. *(Flutter uygulaması deneyler ve yapılandırma için ayrı bir durum alanı tutabilir.)*

The Flutter application may maintain separate state domains for diagnostics and session history. *(Flutter uygulaması tanı ve oturum geçmişi için ayrı bir durum alanı tutabilir.)*

---

# 26. Immutable State Principle (Değiştirilemez Durum İlkesi)

Flutter-facing navigation state should use immutable snapshots where practical. *(Flutter’a sunulan navigasyon durumu uygulanabilir olduğu ölçüde değiştirilemez anlık görüntüler kullanmalıdır.)*

A UI widget should not directly mutate the underlying estimator state. *(Bir UI widget’ı temel tahmin motoru durumunu doğrudan değiştirmemelidir.)*

User actions will be routed through controllers or application services. *(Kullanıcı işlemleri controller’lar veya uygulama servisleri üzerinden yönlendirilecektir.)*

---

# 27. Navigation State Snapshot (Navigasyon Durumu Anlık Görüntüsü)

A navigation-state snapshot may contain the following information. *(Bir navigasyon durumu anlık görüntüsü aşağıdaki bilgileri içerebilir.)*

```
NavigationState
- timestamp
- navigationMode
- localEast
- localNorth
- latitude
- longitude
- heading
- travelledDistance
- stepCount
- motionClass
- motionConfidence
- positionConfidence
- arcoreTrackingState
- sensorHealth
```

This state represents application-consumable navigation information rather than every internal EKF variable. *(Bu durum her dahili EKF değişkeni yerine uygulama tarafından kullanılabilir navigasyon bilgisini temsil eder.)*

---

# 28. Repository Pattern (Repository Patterni)

Flutter application modules will access persisted or platform-derived information through repository interfaces where this separation provides value. *(Flutter uygulama modülleri bu ayrım değer sağladığında saklanan veya platformdan türetilen bilgilere repository arayüzleri üzerinden erişecektir.)*

Repositories will isolate storage or platform implementation details from higher application logic. *(Repository’ler depolama veya platform uygulama ayrıntılarını daha yüksek uygulama mantığından izole edecektir.)*

Not every simple utility requires a repository abstraction. *(Her basit yardımcı işlev bir repository soyutlaması gerektirmez.)*

The architecture will avoid ceremonial layers that do not improve testability or maintainability. *(Mimari test edilebilirliği veya sürdürülebilirliği artırmayan törensel katmanlardan kaçınacaktır.)*

---

# 29. Proposed Repository Interfaces (Önerilen Repository Arayüzleri)

```
SensorRepository
GnssRepository
ArcoreRepository
AiRepository
SessionRepository
ConfigurationRepository
EvaluationRepository
```

These repository names are provisional. *(Bu repository adları geçicidir.)*

Their responsibility boundaries are more important than the final naming convention. *(Sorumluluk sınırları nihai adlandırma kuralından daha önemlidir.)*

---

# 30. Service Layer (Servis Katmanı)

Services will coordinate operations that combine multiple repositories or platform components. *(Servisler birden fazla repository veya platform bileşenini birleştiren işlemleri koordine edecektir.)*

A SessionService may coordinate session creation, configuration snapshots, logging startup, and session shutdown. *(Bir SessionService oturum oluşturmayı, yapılandırma anlık görüntülerini, kayıt başlatmayı ve oturum kapatmayı koordine edebilir.)*

A NavigationService may coordinate the selected estimator configuration and navigation lifecycle. *(Bir NavigationService seçilen tahmin motoru yapılandırmasını ve navigasyon yaşam döngüsünü koordine edebilir.)*

A ReadinessService may aggregate sensor, permission, GNSS, ARCore, AI, and storage readiness. *(Bir ReadinessService sensör, izin, GNSS, ARCore, yapay zekâ ve depolama hazırlığını birleştirebilir.)*

---

# 31. Controller Layer (Controller Katmanı)

Controllers will translate user actions into application operations. *(Controller’lar kullanıcı işlemlerini uygulama operasyonlarına dönüştürecektir.)*

A screen should not manually coordinate SensorManager, ARCore, storage, and AI operations. *(Bir ekran SensorManager, ARCore, depolama ve yapay zekâ işlemlerini manuel olarak koordine etmemelidir.)*

The controller will request the appropriate service to perform these operations. *(Controller uygun servisten bu işlemleri gerçekleştirmesini isteyecektir.)*

---

# 32. Session Lifecycle Architecture (Oturum Yaşam Döngüsü Mimarisi)

A navigation experiment will follow an explicit lifecycle. *(Bir navigasyon deneyi açık bir yaşam döngüsü izleyecektir.)*

```
IDLE
  ↓
PREPARING
  ↓
READINESS_CHECK
  ↓
READY
  ↓
STARTING
  ↓
RECORDING / NAVIGATING
  ↓
STOPPING
  ↓
FINALIZING
  ↓
COMPLETED
```

Failure states may branch from the normal lifecycle. *(Hata durumları normal yaşam döngüsünden dallanabilir.)*

---

# 33. Session Start Transaction (Oturum Başlatma İşlemi)

A formal session must not partially start without the application knowing which components are active. *(Resmî bir oturum uygulama hangi bileşenlerin aktif olduğunu bilmeden kısmen başlamamalıdır.)*

The Session Manager will create the session identity first. *(Oturum Yöneticisi önce oturum kimliğini oluşturacaktır.)*

The configuration snapshot will then be frozen. *(Daha sonra yapılandırma anlık görüntüsü sabitlenecektir.)*

Required log destinations will be initialized. *(Gerekli kayıt hedefleri başlatılacaktır.)*

Mandatory sensor services will then start. *(Daha sonra zorunlu sensör servisleri başlayacaktır.)*

Optional services will start according to the selected experiment profile. *(İsteğe bağlı servisler seçilen deney profiline göre başlayacaktır.)*

The navigation state will become active only after required startup operations succeed. *(Navigasyon durumu yalnızca gerekli başlangıç işlemleri başarılı olduktan sonra aktif hale gelecektir.)*

---

# 34. Session Stop Transaction (Oturum Durdurma İşlemi)

Stopping a session will occur through a controlled sequence. *(Bir oturumun durdurulması kontrollü bir sıra üzerinden gerçekleşecektir.)*

Navigation updates will first be prevented from creating new session state. *(Öncelikle navigasyon güncellemelerinin yeni oturum durumu oluşturması engellenecektir.)*

Pending logs will be flushed. *(Bekleyen loglar diske yazılacaktır.)*

Native sensor listeners will be unregistered. *(Native sensör listener’larının kaydı kaldırılacaktır.)*

ARCore resources will be released when active. *(Aktif olduğunda ARCore kaynakları serbest bırakılacaktır.)*

The session manifest and summary will then be finalized. *(Daha sonra oturum manifest’i ve özeti sonlandırılacaktır.)*

---

# 35. Unexpected Application Lifecycle Changes (Beklenmeyen Uygulama Yaşam Döngüsü Değişiklikleri)

The mobile architecture must account for Android application lifecycle changes. *(Mobil mimari Android uygulama yaşam döngüsü değişikliklerini dikkate almalıdır.)*

Temporary UI lifecycle changes must not automatically corrupt an active experiment. *(Geçici UI yaşam döngüsü değişiklikleri aktif bir deneyi otomatik olarak bozmamalıdır.)*

If the operating system forces a state that prevents reliable experimental acquisition, the session should be marked degraded or invalid rather than silently assumed valid. *(İşletim sistemi güvenilir deneysel veri toplamayı engelleyen bir durum zorlarsa oturum sessizce geçerli varsayılmak yerine bozulmuş veya geçersiz olarak işaretlenmelidir.)*

---

# 36. Foreground-First Operation (Ön Plan Öncelikli Çalışma)

Formal NAVGUARD experiments will primarily run while the application remains in the foreground. *(Resmî NAVGUARD deneyleri temel olarak uygulama ön planda kalırken çalışacaktır.)*

This decision reduces unnecessary complexity related to unrestricted background sensor and camera operation. *(Bu karar sınırsız arka plan sensör ve kamera çalışmasıyla ilişkili gereksiz karmaşıklığı azaltır.)*

Background navigation is not a mandatory requirement of the initial research prototype. *(Arka plan navigasyonu ilk araştırma prototipinin zorunlu bir gereksinimi değildir.)*

---

# 37. Screen Lock Policy (Ekran Kilidi Politikası)

Formal experiments should initially be performed with the application visible and the device screen active. *(Resmî deneyler başlangıçta uygulama görünür ve cihaz ekranı aktif durumdayken gerçekleştirilmelidir.)*

This reduces uncontrolled changes in Android sensor, camera, and process behavior during baseline experiments. *(Bu, temel deneyler sırasında Android sensör, kamera ve süreç davranışındaki kontrolsüz değişiklikleri azaltır.)*

A later test may characterize behavior when the screen is turned off, but this is not required for the minimum project. *(Daha sonraki bir test ekran kapatıldığında davranışı karakterize edebilir ancak bu minimum proje için gerekli değildir.)*

---

# 38. ARCore Lifecycle Architecture (ARCore Yaşam Döngüsü Mimarisi)

ARCore will have a dedicated native Android lifecycle manager. *(ARCore özel bir native Android yaşam döngüsü yöneticisine sahip olacaktır.)*

ARCore resources will be initialized only for experiment profiles that require visual-inertial tracking. *(ARCore kaynakları yalnızca görsel-ataletsel takip gerektiren deney profilleri için başlatılacaktır.)*

The system will not initialize the camera and ARCore unnecessarily for PDR-only sessions. *(Sistem yalnızca PDR kullanan oturumlarda kamera ve ARCore’u gereksiz yere başlatmayacaktır.)*

---

# 39. ARCore State Model (ARCore Durum Modeli)

The ARCore subsystem will expose an explicit state to the application. *(ARCore alt sistemi uygulamaya açık bir durum sunacaktır.)*

Possible states may include UNAVAILABLE, INITIALIZING, TRACKING, PAUSED, DEGRADED, and ERROR. *(Olası durumlar UNAVAILABLE, INITIALIZING, TRACKING, PAUSED, DEGRADED ve ERROR içerebilir.)*

The fusion engine will use ARCore measurements only when the applicable tracking state allows them. *(Füzyon motoru ARCore ölçümlerini yalnızca uygun takip durumu izin verdiğinde kullanacaktır.)*

---

# 40. ARCore Pose Interface (ARCore Poz Arayüzü)

The native ARCore layer will expose timestamped relative pose samples. *(Native ARCore katmanı zaman damgalı göreli poz örnekleri sunacaktır.)*

A logical pose sample may contain the following fields. *(Mantıksal bir poz örneği aşağıdaki alanları içerebilir.)*

```
ArPoseSample
- timestamp
- translationX
- translationY
- translationZ
- quaternionX
- quaternionY
- quaternionZ
- quaternionW
- trackingState
```

Coordinate alignment will occur outside the low-level ARCore acquisition component. *(Koordinat hizalama düşük seviyeli ARCore veri toplama bileşeninin dışında gerçekleşecektir.)*

---

# 41. ARCore Render Separation (ARCore Render Ayrımı)

NAVGUARD requires ARCore tracking information but does not require a full augmented-reality visual interface for its primary navigation function. *(NAVGUARD temel navigasyon işlevi için ARCore takip bilgisine ihtiyaç duyar ancak tam bir artırılmış gerçeklik görsel arayüzüne ihtiyaç duymaz.)*

The project should therefore avoid unnecessary AR rendering complexity when pose tracking can be obtained without presenting a full AR scene to the user. *(Bu nedenle proje, tam bir AR sahnesini kullanıcıya sunmadan poz takibi elde edilebildiğinde gereksiz AR render karmaşıklığından kaçınmalıdır.)*

---

# 42. LiteRT Runtime Architecture (LiteRT Çalışma Zamanı Mimarisi)

LiteRT model inference will be encapsulated inside a dedicated native AI runtime component. *(LiteRT model çıkarımı özel bir native yapay zekâ çalışma zamanı bileşeni içerisinde kapsüllenecektir.)*

The rest of the application will not directly manipulate interpreter internals. *(Uygulamanın geri kalanı interpreter dahili yapılarını doğrudan yönetmeyecektir.)*

The runtime will own model loading, tensor preparation, inference execution, output parsing, and latency measurement. *(Çalışma zamanı model yükleme, tensör hazırlama, çıkarım çalıştırma, çıktı ayrıştırma ve gecikme ölçümünün sahibi olacaktır.)*

---

# 43. AI Runtime Lifecycle (Yapay Zekâ Çalışma Zamanı Yaşam Döngüsü)

The selected motion model should be loaded before or during navigation initialization rather than reloaded for every inference. *(Seçilen hareket modeli her çıkarım için yeniden yüklenmek yerine navigasyon başlatılmadan önce veya başlatma sırasında yüklenmelidir.)*

The model instance should remain reusable during the active session. *(Model instance’ı aktif oturum sırasında yeniden kullanılabilir kalmalıdır.)*

Resources will be released when the runtime is permanently shut down or when model replacement requires reinitialization. *(Kaynaklar çalışma zamanı kalıcı olarak kapatıldığında veya model değişimi yeniden başlatma gerektirdiğinde serbest bırakılacaktır.)*

---

# 44. AI Input Window Buffer (Yapay Zekâ Girdi Penceresi Tamponu)

Motion classification will operate on a rolling or segmented time-series window. *(Hareket sınıflandırması kayan veya bölümlenmiş bir zaman serisi penceresi üzerinde çalışacaktır.)*

A dedicated buffer will accumulate the required processed sensor samples. *(Özel bir tampon gerekli işlenmiş sensör örneklerini biriktirecektir.)*

Inference will execute only when a valid input window is available. *(Çıkarım yalnızca geçerli bir girdi penceresi mevcut olduğunda çalışacaktır.)*

The model will not execute once for every individual accelerometer callback. *(Model her bireysel ivmeölçer callback’i için bir kez çalışmayacaktır.)*

---

# 45. AI Window Ownership (Yapay Zekâ Pencere Sahipliği)

The feature-window builder will have a clearly defined owner. *(Özellik pencere oluşturucusunun açıkça tanımlanmış bir sahibi olacaktır.)*

Training-time and mobile-time window construction must follow equivalent preprocessing rules. *(Eğitim zamanı ve mobil çalışma zamanı pencere oluşturma eşdeğer ön işleme kurallarını izlemelidir.)*

The same channel order, normalization, sampling assumptions, and window length must be versioned together with the model. *(Aynı kanal sırası, normalizasyon, örnekleme varsayımları ve pencere uzunluğu modelle birlikte sürümlenmelidir.)*

---

# 46. AI Inference Output Model (Yapay Zekâ Çıkarım Çıktı Modeli)

A logical motion inference result may contain the following information. *(Mantıksal bir hareket çıkarım sonucu aşağıdaki bilgileri içerebilir.)*

```
MotionInference
- timestamp
- modelId
- predictedClass
- confidence
- classProbabilities
- inferenceLatencyMs
```

The model identifier must be included in session-level configuration even if it is not repeated in every output record. *(Model tanımlayıcısı her çıktı kaydında tekrarlanmasa bile oturum seviyesindeki yapılandırmaya dahil edilmelidir.)*

---

# 47. AI Failure Handling (Yapay Zekâ Hata Yönetimi)

An AI runtime exception must not crash the entire navigation session when deterministic fallback behavior is available. *(Deterministik geri dönüş davranışı mevcut olduğunda bir yapay zekâ çalışma zamanı istisnası tüm navigasyon oturumunu çökertmemelidir.)*

The failure will be recorded. *(Hata kaydedilecektir.)*

The AI state will transition to ERROR or UNAVAILABLE. *(Yapay zekâ durumu ERROR veya UNAVAILABLE durumuna geçecektir.)*

The navigation pipeline will switch to the configured non-AI fallback where appropriate. *(Navigasyon hattı uygun olduğunda yapılandırılmış yapay zekâsız geri dönüşe geçecektir.)*

---

# 48. GNSS Native Architecture (GNSS Native Mimarisi)

A dedicated native GNSS component will own Android LocationManager interactions. *(Özel bir native GNSS bileşeni Android LocationManager etkileşimlerinin sahibi olacaktır.)*

The component will acquire GNSS-based position updates and preserve their timestamps and Android-reported accuracy. *(Bileşen GNSS tabanlı konum güncellemelerini elde edecek ve zaman damgalarını ve Android tarafından bildirilen doğruluklarını koruyacaktır.)*

The component will not decide whether the estimator is allowed to use a measurement. *(Bileşen tahmin motorunun bir ölçümü kullanmasına izin verilip verilmediğine karar vermeyecektir.)*

That decision belongs to the Navigation Mode and Ground Truth Firewall logic. *(Bu karar Navigasyon Modu ve Gerçek Referans Güvenlik Duvarı mantığına aittir.)*

---

# 49. GNSS Data Model (GNSS Veri Modeli)

A logical GNSS sample may contain the following fields. *(Mantıksal bir GNSS örneği aşağıdaki alanları içerebilir.)*

```
GnssSample
- timestamp
- latitude
- longitude
- altitude
- horizontalAccuracy
- speed
- bearing
- provider
```

Optional fields will remain explicitly absent when Android does not provide them. *(Android sağlamadığında isteğe bağlı alanlar açıkça eksik kalacaktır.)*

Missing information will not be replaced with fabricated zero values where zero has a valid physical meaning. *(Sıfırın geçerli fiziksel anlam taşıdığı yerlerde eksik bilgi uydurulmuş sıfır değerleriyle değiştirilmemelidir.)*

---

# 50. Ground Truth Firewall in Mobile Architecture (Mobil Mimaride Gerçek Referans Güvenlik Duvarı)

The GNSS source will publish measurements to the logging path independently from estimator authorization. *(GNSS kaynağı ölçümleri tahmin motoru yetkilendirmesinden bağımsız olarak kayıt hattına yayınlayacaktır.)*

A navigation-mode gate will control whether GNSS measurements may enter the estimator. *(Bir navigasyon modu kapısı GNSS ölçümlerinin tahmin motoruna girip giremeyeceğini kontrol edecektir.)*

Evaluation Mode will therefore allow the logger to receive GNSS while preventing the estimator from receiving GNSS. *(Bu nedenle Değerlendirme Modu logger’ın GNSS almasına izin verirken tahmin motorunun GNSS almasını engelleyecektir.)*

---

# 51. Ground Truth Mobile Flow (Gerçek Referans Mobil Akışı)

```
LocationManager
      │
      ▼
Native GnssManager
      │
      ├──────────────► GroundTruthLogger
      │
      ▼
NavigationModeGate
      │
      ├── GNSS Allowed ──► Estimator
      │
      └── GNSS Denied ───► BLOCKED
```

The logger path must not pass through the estimator path. *(Logger hattı tahmin motoru hattının içerisinden geçmemelidir.)*

---

# 52. Navigation Core Input Bus (Navigasyon Çekirdeği Girdi Veri Yolu)

The navigation core will receive normalized domain events rather than Android framework objects. *(Navigasyon çekirdeği Android framework nesneleri yerine normalize edilmiş domain olayları alacaktır.)*

For example, the Dart navigation layer should not depend directly on Android SensorEvent classes. *(Örneğin Dart navigasyon katmanı doğrudan Android SensorEvent sınıflarına bağımlı olmamalıdır.)*

This boundary makes offline replay and unit testing possible. *(Bu sınır çevrimdışı yeniden oynatmayı ve birim testini mümkün kılar.)*

---

# 53. Live and Replay Input Abstraction (Canlı ve Replay Girdi Soyutlaması)

Live acquisition and recorded-session replay should emit compatible domain models. *(Canlı veri toplama ve kaydedilmiş oturum yeniden oynatma uyumlu domain modelleri üretmelidir.)*

The estimator should not need to know whether a measurement originated from physical hardware or a replay file. *(Tahmin motorunun bir ölçümün fiziksel donanımdan mı yoksa replay dosyasından mı geldiğini bilmesine gerek olmamalıdır.)*

This design will allow algorithm comparisons using identical inputs. *(Bu tasarım aynı girdiler kullanılarak algoritma karşılaştırmalarına olanak sağlayacaktır.)*

---

# 54. Navigation Pipeline Controller (Navigasyon Hattı Controller’ı)

A dedicated navigation pipeline controller will coordinate the order in which navigation modules receive events. *(Özel bir navigasyon hattı controller’ı navigasyon modüllerinin olayları hangi sırayla alacağını koordine edecektir.)*

The controller will know the active experiment profile. *(Controller aktif deney profilini bilecektir.)*

The controller will enable only the modules required by the selected configuration. *(Controller yalnızca seçilen yapılandırma tarafından gerekli modülleri etkinleştirecektir.)*

---

# 55. Configuration A Mobile Pipeline (Yapılandırma A Mobil Hattı)

```
Sensors
  ↓
Preprocessing
  ↓
Step Detection
  ↓
Baseline Heading
  ↓
Baseline Step Length
  ↓
PDR
  ↓
Navigation State
```

This pipeline will provide the simplest formal baseline. *(Bu hat en basit resmî temel referansı sağlayacaktır.)*

---

# 56. Configuration B Mobile Pipeline (Yapılandırma B Mobil Hattı)

```
Sensors
  ↓
Preprocessing
  ├────► Step Detection
  └────► Heading Fusion
             │
Step Length ─┤
             ▼
            PDR
             ↓
      Navigation State
```

This pipeline will isolate the contribution of improved heading estimation. *(Bu hat geliştirilmiş yön tahmininin katkısını izole edecektir.)*

---

# 57. Configuration C Mobile Pipeline (Yapılandırma C Mobil Hattı)

```
Sensors ───────► PDR
                  │
ARCore ───────────┤
                  ▼
             Fusion Logic
                  ↓
          Navigation State
```

This pipeline will evaluate the contribution of ARCore relative movement information. *(Bu hat ARCore göreli hareket bilgisinin katkısını değerlendirecektir.)*

---

# 58. Configuration D Mobile Pipeline (Yapılandırma D Mobil Hattı)

```
Sensors
  │
  ├────► Step Detection
  ├────► Heading
  └────► Motion AI
             │
             ▼
            PDR
             │
ARCore ──────┤
             │
Quality ─────┤
             ▼
       EKF / Fusion
             │
             ▼
  Position + Uncertainty
```

This pipeline will represent the intended full NAVGUARD configuration. *(Bu hat planlanan tam NAVGUARD yapılandırmasını temsil edecektir.)*

---

# 59. Local Storage Architecture (Yerel Depolama Mimarisi)

The mobile application will separate session metadata from high-frequency stream data. *(Mobil uygulama oturum metadata bilgisini yüksek frekanslı akış verisinden ayıracaktır.)*

SQLite will primarily store structured low-frequency information. *(SQLite temel olarak yapılandırılmış düşük frekanslı bilgiyi saklayacaktır.)*

Append-oriented files will primarily store high-frequency experimental streams. *(Append odaklı dosyalar temel olarak yüksek frekanslı deney akışlarını saklayacaktır.)*

---

# 60. SQLite Responsibilities (SQLite Sorumlulukları)

SQLite may store session identifiers. *(SQLite oturum tanımlayıcılarını saklayabilir.)*

SQLite may store session start and end times. *(SQLite oturum başlangıç ve bitiş zamanlarını saklayabilir.)*

SQLite may store experiment profiles and summary statistics. *(SQLite deney profillerini ve özet istatistiklerini saklayabilir.)*

SQLite may store application-level history required by the Session History interface. *(SQLite Oturum Geçmişi arayüzü tarafından gerekli uygulama seviyesindeki geçmişi saklayabilir.)*

SQLite will not automatically become the raw IMU time-series database. *(SQLite otomatik olarak ham IMU zaman serisi veritabanı haline gelmeyecektir.)*

---

# 61. File Logger Architecture (Dosya Kayıt Mimarisi)

High-frequency session streams will use dedicated append writers. *(Yüksek frekanslı oturum akışları özel append writer’lar kullanacaktır.)*

Writers should remain open during active logging rather than repeatedly reopening files for every sample. *(Writer’lar her örnek için dosyaları tekrar tekrar açmak yerine aktif kayıt sırasında açık kalmalıdır.)*

Buffered writes may be used to improve performance. *(Performansı artırmak için tamponlanmış yazma kullanılabilir.)*

A controlled flush policy must balance data safety and I/O overhead. *(Kontrollü flush politikası veri güvenliği ile I/O yükünü dengelemelidir.)*

---

# 62. Logging Queue (Kayıt Kuyruğu)

Sensor callbacks should not perform expensive file operations directly. *(Sensör callback’leri pahalı dosya işlemlerini doğrudan gerçekleştirmemelidir.)*

Measurements may be placed into an in-memory logging queue or buffer. *(Ölçümler bellek içi bir kayıt kuyruğuna veya tamponuna yerleştirilebilir.)*

A dedicated writer process or execution context will persist the data. *(Özel bir writer süreci veya çalışma bağlamı veriyi kalıcı hale getirecektir.)*

Queue growth must be monitored so that slow storage cannot silently cause unlimited memory growth. *(Yavaş depolamanın sessizce sınırsız bellek büyümesine neden olmaması için kuyruk büyümesi izlenmelidir.)*

---

# 63. Storage Failure Handling (Depolama Hata Yönetimi)

Critical logging failures during formal evaluation must be surfaced immediately. *(Resmî değerlendirme sırasında kritik kayıt hataları hemen görünür hale getirilmelidir.)*

The application must not continue presenting the session as scientifically valid if essential experimental evidence can no longer be stored. *(Temel deneysel kanıt artık saklanamıyorsa uygulama oturumu bilimsel olarak geçerliymiş gibi sunmaya devam etmemelidir.)*

Depending on severity, the session may continue as a non-benchmark diagnostic session or terminate in a controlled manner. *(Ciddiyete bağlı olarak oturum benchmark dışı tanısal bir oturum olarak devam edebilir veya kontrollü şekilde sonlandırılabilir.)*

---

# 64. Session Directory Ownership (Oturum Klasörü Sahipliği)

Each formal session will own one logical storage directory or equivalent structured storage unit. *(Her resmî oturum tek bir mantıksal depolama klasörüne veya eşdeğer yapılandırılmış depolama birimine sahip olacaktır.)*

Session files will not be shared across unrelated experiments. *(Oturum dosyaları ilgisiz deneyler arasında paylaşılmayacaktır.)*

This simplifies export, deletion, replay, and reproducibility. *(Bu dışa aktarma, silme, yeniden oynatma ve tekrarlanabilirliği basitleştirir.)*

---

# 65. Mobile Export Architecture (Mobil Dışa Aktarma Mimarisi)

Export will operate on completed session data. *(Dışa aktarma tamamlanmış oturum verileri üzerinde çalışacaktır.)*

The exporter will package the session manifest together with its associated stream files. *(Exporter oturum manifest’ini ilişkili akış dosyalarıyla birlikte paketleyecektir.)*

The export process must not silently omit failed or partially recorded streams. *(Dışa aktarma işlemi başarısız veya kısmen kaydedilmiş akışları sessizce çıkarmamalıdır.)*

Their status must be represented in the manifest. *(Durumları manifest içerisinde temsil edilmelidir.)*

---

# 66. App-Level Error Architecture (Uygulama Seviyesi Hata Mimarisi)

NAVGUARD will use structured error categories rather than only free-text error messages. *(NAVGUARD yalnızca serbest metin hata mesajları yerine yapılandırılmış hata kategorileri kullanacaktır.)*

Errors may be classified as configuration errors, permission errors, sensor errors, GNSS errors, ARCore errors, AI errors, storage errors, estimator errors, or internal application errors. *(Hatalar yapılandırma hataları, izin hataları, sensör hataları, GNSS hataları, ARCore hataları, yapay zekâ hataları, depolama hataları, tahmin motoru hataları veya dahili uygulama hataları olarak sınıflandırılabilir.)*

This classification will improve fallback behavior and diagnostic reporting. *(Bu sınıflandırma geri dönüş davranışını ve tanısal raporlamayı iyileştirecektir.)*

---

# 67. Error Severity Model (Hata Ciddiyet Modeli)

Errors may use INFO, WARNING, DEGRADED, CRITICAL, and FATAL severity levels. *(Hatalar INFO, WARNING, DEGRADED, CRITICAL ve FATAL ciddiyet seviyelerini kullanabilir.)*

A WARNING does not invalidate the session automatically. *(Bir WARNING oturumu otomatik olarak geçersiz kılmaz.)*

A DEGRADED state indicates that the system is continuing with reduced capability. *(DEGRADED durumu sistemin azaltılmış yetenekle devam ettiğini gösterir.)*

A CRITICAL error may invalidate the scientific session while still allowing safe application shutdown. *(CRITICAL hata güvenli uygulama kapanışına izin verirken bilimsel oturumu geçersiz kılabilir.)*

---

# 68. Diagnostic Logging Architecture (Tanısal Kayıt Mimarisi)

Diagnostic logs will be separate from high-frequency research measurements. *(Tanısal loglar yüksek frekanslı araştırma ölçümlerinden ayrı olacaktır.)*

Diagnostic events will contain timestamp, severity, subsystem, code, and message information. *(Tanısal olaylar zaman damgası, ciddiyet, alt sistem, kod ve mesaj bilgisi içerecektir.)*

Important state changes such as ARCore loss, AI failure, GNSS denial, or storage warnings will be recorded as diagnostic events. *(ARCore kaybı, yapay zekâ hatası, GNSS kesintisi veya depolama uyarıları gibi önemli durum değişiklikleri tanısal olaylar olarak kaydedilecektir.)*

---

# 69. Permission Architecture (İzin Mimarisi)

Permission handling will be centralized rather than implemented independently by every screen. *(İzin yönetimi her ekran tarafından bağımsız olarak geliştirilmek yerine merkezileştirilecektir.)*

The Permission Manager will expose the status of each capability required by NAVGUARD. *(İzin Yöneticisi NAVGUARD tarafından gerekli her yeteneğin durumunu sunacaktır.)*

The readiness system will consume these permission states. *(Hazırlık sistemi bu izin durumlarını kullanacaktır.)*

---

# 70. Initial Permission Set (Başlangıç İzin Seti)

Precise location permission will be required for GNSS functions. *(Hassas konum izni GNSS işlevleri için gerekli olacaktır.)*

Camera permission will be required for ARCore configurations. *(Kamera izni ARCore yapılandırmaları için gerekli olacaktır.)*

File export may require an Android-compatible user-selected destination rather than broad unrestricted storage permission. *(Dosya dışa aktarma geniş ve sınırsız depolama izni yerine Android uyumlu kullanıcı tarafından seçilen bir hedef gerektirebilir.)*

The application will avoid unnecessary permission requests. *(Uygulama gereksiz izin isteklerinden kaçınacaktır.)*

---

# 71. Readiness Architecture (Hazırlık Mimarisi)

The Readiness Manager will aggregate independent subsystem readiness information. *(Hazırlık Yöneticisi bağımsız alt sistem hazırlık bilgilerini birleştirecektir.)*

A readiness result will depend on the selected experiment profile. *(Bir hazırlık sonucu seçilen deney profiline bağlı olacaktır.)*

For example, ARCore failure will block an ARCore experiment but will not block a PDR-only experiment. *(Örneğin ARCore başarısızlığı bir ARCore deneyini engelleyecek ancak yalnızca PDR kullanan bir deneyi engellemeyecektir.)*

---

# 72. Readiness State Model (Hazırlık Durum Modeli)

A readiness item may contain the following fields. *(Bir hazırlık öğesi aşağıdaki alanları içerebilir.)*

```
ReadinessItem
- componentId
- status
- required
- message
- lastUpdated
```

Possible status values may include READY, WARNING, NOT_READY, UNAVAILABLE, and CHECKING. *(Olası durum değerleri READY, WARNING, NOT_READY, UNAVAILABLE ve CHECKING içerebilir.)*

---

# 73. Navigation Profile Architecture (Navigasyon Profil Mimarisi)

Experiment profiles will be represented as explicit configuration objects. *(Deney profilleri açık yapılandırma nesneleri olarak temsil edilecektir.)*

A profile will define which modules are enabled. *(Bir profil hangi modüllerin etkin olduğunu tanımlayacaktır.)*

A profile will define whether GNSS is allowed into the estimator. *(Bir profil GNSS’in tahmin motoruna girmesine izin verilip verilmediğini tanımlayacaktır.)*

A profile will define whether ARCore, AI, sensor confidence, or fusion is required. *(Bir profil ARCore, yapay zekâ, sensör güveni veya füzyonun gerekli olup olmadığını tanımlayacaktır.)*

---

# 74. Configuration Object Example (Yapılandırma Nesnesi Örneği)

```
NavigationProfile
- profileId
- pdrEnabled
- headingFusionEnabled
- motionAiEnabled
- learnedStepLengthEnabled
- arcoreEnabled
- sensorConfidenceEnabled
- ekfEnabled
- gnssEstimatorAccess
- groundTruthLoggingEnabled
```

The exact schema will be finalized before implementation. *(Kesin şema geliştirmeden önce kesinleştirilecektir.)*

---

# 75. Configuration Immutability During Formal Session (Resmî Oturum Sırasında Yapılandırmanın Değişmezliği)

A formal experiment profile will be frozen when a session begins. *(Resmî bir deney profili oturum başladığında sabitlenecektir.)*

The user interface will not silently change estimator configuration while the experiment is running. *(Kullanıcı arayüzü deney çalışırken tahmin motoru yapılandırmasını sessizce değiştirmeyecektir.)*

Any intentional experimental change must either create a new session or be recorded as an explicit configuration event. *(Bilinçli herhangi bir deneysel değişiklik ya yeni bir oturum oluşturmalı ya da açık bir yapılandırma olayı olarak kaydedilmelidir.)*

---

# 76. Route Visualization Architecture (Rota Görselleştirme Mimarisi)

The Flutter map will consume estimated geographic positions produced by the navigation domain layer. *(Flutter haritası navigasyon domain katmanı tarafından üretilen tahmini coğrafi konumları kullanacaktır.)*

The map will not independently convert raw sensor measurements into geographic positions. *(Harita ham sensör ölçümlerini bağımsız olarak coğrafi konumlara dönüştürmeyecektir.)*

Reference GNSS trajectories and estimated trajectories will remain visually distinguishable. *(Referans GNSS rotaları ile tahmini rotalar görsel olarak ayırt edilebilir kalacaktır.)*

---

# 77. Map Rendering Rate (Harita Render Hızı)

The map path does not need to append a new visual point for every high-frequency estimator update. *(Harita rotasının her yüksek frekanslı tahmin motoru güncellemesinde yeni bir görsel nokta eklemesine gerek yoktur.)*

The presentation layer may downsample visualization points while preserving full-resolution estimator data in storage. *(Sunum katmanı tam çözünürlüklü tahmin motoru verisini depolamada korurken görselleştirme noktalarını seyreltebilir.)*

This separation will improve rendering performance. *(Bu ayrım render performansını artıracaktır.)*

---

# 78. Application Navigation Structure (Uygulama Ekran Navigasyonu Yapısı)

The initial Flutter application will use a simple hierarchical screen structure. *(İlk Flutter uygulaması basit hiyerarşik bir ekran yapısı kullanacaktır.)*

The primary navigation experience will prioritize research operations over consumer-style complexity. *(Temel navigasyon deneyimi tüketici tarzı karmaşıklık yerine araştırma işlemlerine öncelik verecektir.)*

The exact screen design will be defined in the Mobile UI/UX Specification. *(Kesin ekran tasarımı Mobil UI/UX Şartnamesinde tanımlanacaktır.)*

---

# 79. Planned Mobile Screen Structure (Planlanan Mobil Ekran Yapısı)

```
Home
├── Readiness / Calibration
├── Start Experiment
│   └── Live Navigation
├── Sensor Monitor
├── AI Monitor
├── Session History
│   └── Session Detail
│       └── Route Comparison
├── Research / Developer Diagnostics
└── Settings
```

This is the logical navigation structure rather than the final visual design. *(Bu nihai görsel tasarım yerine mantıksal navigasyon yapısıdır.)*

---

# 80. Home Screen Architecture (Ana Ekran Mimarisi)

The Home screen will consume readiness and recent-session state. *(Ana ekran hazırlık ve son oturum durumunu kullanacaktır.)*

The Home screen will not query native sensors independently. *(Ana ekran native sensörleri bağımsız olarak sorgulamayacaktır.)*

It will obtain summarized readiness information from the application layer. *(Özetlenmiş hazırlık bilgisini uygulama katmanından alacaktır.)*

---

# 81. Live Navigation Architecture (Canlı Navigasyon Mimarisi)

The Live Navigation screen will subscribe to a reduced-frequency navigation-state stream. *(Canlı Navigasyon ekranı azaltılmış frekanslı bir navigasyon durumu akışına abone olacaktır.)*

It will display navigation mode, estimated position, route, heading, movement state, confidence, and major system status. *(Navigasyon modu, tahmini konum, rota, yön, hareket durumu, güven ve temel sistem durumunu gösterecektir.)*

The screen will not own sensor listeners or AI interpreters. *(Ekran sensör listener’larının veya yapay zekâ interpreter’larının sahibi olmayacaktır.)*

---

# 82. Sensor Monitor Architecture (Sensör İzleme Mimarisi)

The Sensor Monitor will consume diagnostic snapshots rather than create a second sensor acquisition pipeline. *(Sensör İzleme ekranı ikinci bir sensör veri toplama hattı oluşturmak yerine tanısal anlık görüntüleri kullanacaktır.)*

The existing Sensor Manager will remain the single source of live sensor data. *(Mevcut Sensör Yöneticisi canlı sensör verisinin tek kaynağı olarak kalacaktır.)*

This prevents debugging tools from changing experiment behavior. *(Bu, hata ayıklama araçlarının deney davranışını değiştirmesini önler.)*

---

# 83. AI Monitor Architecture (Yapay Zekâ İzleme Mimarisi)

The AI Monitor will consume the same inference output used by the navigation system. *(Yapay Zekâ İzleme ekranı navigasyon sistemi tarafından kullanılan aynı çıkarım çıktısını kullanacaktır.)*

It will not execute an independent second inference merely for display. *(Yalnızca görüntüleme için bağımsız ikinci bir çıkarım çalıştırmayacaktır.)*

This ensures that displayed AI results match the model output that actually influenced navigation. *(Bu, gösterilen yapay zekâ sonuçlarının navigasyonu gerçekten etkileyen model çıktısıyla eşleşmesini sağlar.)*

---

# 84. Result Screen Architecture (Sonuç Ekranı Mimarisi)

The result screen will load session summaries and computed metrics from the data and evaluation layers. *(Sonuç ekranı oturum özetlerini ve hesaplanmış metrikleri veri ve değerlendirme katmanlarından yükleyecektir.)*

Heavy offline statistical calculations do not need to execute synchronously while the result screen is rendering. *(Ağır çevrimdışı istatistiksel hesaplamaların sonuç ekranı render edilirken senkron olarak çalışmasına gerek yoktur.)*

Simple mobile metrics may be precomputed during session finalization. *(Basit mobil metrikler oturum sonlandırma sırasında önceden hesaplanabilir.)*

---

# 85. Developer Diagnostics Architecture (Geliştirici Tanı Mimarisi)

Developer diagnostics will use the same authoritative runtime components as normal operation. *(Geliştirici tanısı normal çalışmayla aynı ana çalışma zamanı bileşenlerini kullanacaktır.)*

Diagnostics may expose internal timing, queue depth, sensor rate, AI latency, ARCore state, and logging health. *(Tanısal bilgiler dahili zamanlama, kuyruk derinliği, sensör hızı, yapay zekâ gecikmesi, ARCore durumu ve kayıt sağlığını gösterebilir.)*

Diagnostic information must not automatically be visible in the simplified final demo interface. *(Tanısal bilgilerin basitleştirilmiş nihai demo arayüzünde otomatik olarak görünmesi gerekmez.)*

---

# 86. Mobile Logging Levels (Mobil Log Seviyeleri)

NAVGUARD may support different logging levels for development and formal experiments. *(NAVGUARD geliştirme ve resmî deneyler için farklı kayıt seviyelerini destekleyebilir.)*

A DEBUG mode may record additional internal diagnostic information. *(DEBUG modu ek dahili tanısal bilgi kaydedebilir.)*

A BENCHMARK mode may record the complete evidence required for formal evaluation while avoiding unnecessary verbose development logs. *(BENCHMARK modu gereksiz ayrıntılı geliştirme loglarından kaçınırken resmî değerlendirme için gerekli tam kanıtı kaydedebilir.)*

---

# 87. App Build Modes (Uygulama Build Modları)

Flutter debug builds will be used during active development. *(Flutter debug build’leri aktif geliştirme sırasında kullanılacaktır.)*

Profile builds may be used for performance analysis. *(Profile build’ler performans analizi için kullanılabilir.)*

Release builds will be used for final performance and field benchmarks where practical. *(Release build’ler uygulanabilir olduğu ölçüde nihai performans ve saha benchmark’ları için kullanılacaktır.)*

Performance conclusions must not rely exclusively on debug-build measurements. *(Performans sonuçları yalnızca debug-build ölçümlerine dayanmamalıdır.)*

---

# 88. Mobile Performance Monitoring (Mobil Performans İzleme)

NAVGUARD should expose selected runtime performance counters internally. *(NAVGUARD seçilen çalışma zamanı performans sayaçlarını dahili olarak sunmalıdır.)*

Potential counters include sensor events per second, logging queue depth, AI inference latency, estimator update rate, dropped or delayed event counts, and ARCore tracking availability. *(Potansiyel sayaçlar saniye başına sensör olayları, kayıt kuyruğu derinliği, yapay zekâ çıkarım gecikmesi, tahmin motoru güncelleme hızı, düşen veya geciken olay sayıları ve ARCore takip kullanılabilirliğini içerir.)*

These counters will support debugging and final resource evaluation. *(Bu sayaçlar hata ayıklamayı ve nihai kaynak değerlendirmesini destekleyecektir.)*

---

# 89. Memory Management Principle (Bellek Yönetimi İlkesi)

NAVGUARD will avoid retaining unlimited sensor history in application memory. *(NAVGUARD uygulama belleğinde sınırsız sensör geçmişi tutmaktan kaçınacaktır.)*

Only the windows required for active algorithms and short diagnostic history should remain in memory. *(Yalnızca aktif algoritmalar ve kısa tanısal geçmiş için gerekli pencereler bellekte kalmalıdır.)*

Long-term experiment history will be written to persistent storage. *(Uzun süreli deney geçmişi kalıcı depolamaya yazılacaktır.)*

---

# 90. Ring Buffer Strategy (Ring Buffer Stratejisi)

Fixed-capacity ring buffers may be used for recent IMU samples required by AI, filters, and diagnostics. *(Sabit kapasiteli ring buffer’lar yapay zekâ, filtreler ve tanı için gerekli son IMU örnekleri için kullanılabilir.)*

The capacity will be determined by the largest active time window plus a controlled safety margin. *(Kapasite en büyük aktif zaman penceresi artı kontrollü güvenlik payına göre belirlenecektir.)*

This prevents memory usage from increasing with session duration. *(Bu, bellek kullanımının oturum süresiyle birlikte artmasını önler.)*

---

# 91. Battery-Aware Architecture (Batarya Farkındalıklı Mimari)

Components will only remain active when required by the selected experiment profile. *(Bileşenler yalnızca seçilen deney profili tarafından gerekli olduklarında aktif kalacaktır.)*

ARCore will not consume camera and processing resources during PDR-only experiments. *(ARCore yalnızca PDR kullanan deneyler sırasında kamera ve işlem kaynaklarını tüketmeyecektir.)*

AI inference frequency will be limited by the model windowing strategy rather than executed continuously without need. *(Yapay zekâ çıkarım frekansı gereksiz şekilde sürekli çalıştırılmak yerine model pencereleme stratejisi tarafından sınırlandırılacaktır.)*

---

# 92. Thermal-Aware Architecture (Termal Farkındalıklı Mimari)

The mobile architecture will support measurement of prolonged combined workloads. *(Mobil mimari uzun süreli birleşik iş yüklerinin ölçümünü destekleyecektir.)*

The system may reduce non-essential visualization frequency if rendering creates unnecessary thermal or processing overhead. *(Render gereksiz termal veya işlem yükü oluşturursa sistem temel olmayan görselleştirme frekansını azaltabilir.)*

Estimator correctness will take priority over high-frequency cosmetic UI updates. *(Tahmin motoru doğruluğu yüksek frekanslı kozmetik UI güncellemelerine göre öncelikli olacaktır.)*

---

# 93. Android Activity Architecture (Android Activity Mimarisi)

The Flutter application should use the minimum native Activity complexity required by Flutter and ARCore integration. *(Flutter uygulaması Flutter ve ARCore entegrasyonu tarafından gerekli minimum native Activity karmaşıklığını kullanmalıdır.)*

Business and navigation logic will not be placed directly inside the Android Activity. *(İş ve navigasyon mantığı doğrudan Android Activity içerisine yerleştirilmeyecektir.)*

The Activity will primarily serve as a lifecycle and platform integration entry point. *(Activity temel olarak yaşam döngüsü ve platform entegrasyonu giriş noktası olarak hizmet edecektir.)*

---

# 94. Native Component Organization (Native Bileşen Organizasyonu)

Native Kotlin integrations should be divided into focused components. *(Native Kotlin entegrasyonları odaklanmış bileşenlere ayrılmalıdır.)*

A single extremely large platform plugin class should be avoided. *(Tek bir aşırı büyük platform plugin sınıfından kaçınılmalıdır.)*

Sensor, GNSS, ARCore, AI, and device-diagnostics responsibilities should remain logically separate. *(Sensör, GNSS, ARCore, yapay zekâ ve cihaz tanı sorumlulukları mantıksal olarak ayrı kalmalıdır.)*

---

# 95. Proposed Kotlin Package Structure (Önerilen Kotlin Paket Yapısı)

```
android/app/src/main/kotlin/.../navguard/

├── platform/
│   ├── SensorPlatformPlugin.kt
│   ├── GnssPlatformPlugin.kt
│   ├── ArcorePlatformPlugin.kt
│   ├── AiPlatformPlugin.kt
│   └── DevicePlatformPlugin.kt
│
├── sensors/
│   ├── SensorManagerService.kt
│   ├── SensorMetadataMapper.kt
│   └── SensorSampleMapper.kt
│
├── gnss/
│   ├── GnssManagerService.kt
│   └── GnssStatusService.kt
│
├── arcore/
│   ├── ArcoreSessionManager.kt
│   └── ArPoseMapper.kt
│
├── ai/
│   ├── LiteRtRuntime.kt
│   ├── MotionModelRunner.kt
│   └── TensorBufferManager.kt
│
└── diagnostics/
    └── DeviceDiagnostics.kt
```

The exact class names are provisional. *(Kesin sınıf adları geçicidir.)*

---

# 96. Proposed Flutter Source Structure (Önerilen Flutter Kaynak Yapısı)

```
lib/

├── app/
│   ├── app.dart
│   ├── router.dart
│   └── providers.dart
│
├── core/
│   ├── config/
│   ├── errors/
│   ├── timing/
│   ├── math/
│   └── coordinates/
│
├── platform/
│   ├── sensors/
│   ├── gnss/
│   ├── arcore/
│   ├── ai/
│   └── device/
│
├── navigation/
│   ├── models/
│   ├── preprocessing/
│   ├── step_detection/
│   ├── heading/
│   ├── step_length/
│   ├── pdr/
│   ├── fusion/
│   ├── uncertainty/
│   └── relocalization/
│
├── sessions/
│   ├── models/
│   ├── services/
│   └── repositories/
│
├── data/
│   ├── database/
│   ├── logging/
│   ├── export/
│   └── replay/
│
├── evaluation/
│   ├── alignment/
│   ├── metrics/
│   └── comparison/
│
├── features/
│   ├── home/
│   ├── readiness/
│   ├── live_navigation/
│   ├── sensor_monitor/
│   ├── ai_monitor/
│   ├── session_history/
│   ├── comparison/
│   ├── diagnostics/
│   └── settings/
│
└── shared/
    ├── widgets/
    └── utilities/
```

This structure is the preferred starting architecture rather than an immutable directory contract. *(Bu yapı değiştirilemez bir klasör sözleşmesi yerine tercih edilen başlangıç mimarisidir.)*

---

# 97. Feature Versus Layer Organization (Feature ve Katman Organizasyonu)

NAVGUARD will use a hybrid organizational approach. *(NAVGUARD hibrit bir organizasyon yaklaşımı kullanacaktır.)*

Shared technical systems such as navigation mathematics, platform interfaces, and storage will remain layer-oriented. *(Navigasyon matematiği, platform arayüzleri ve depolama gibi paylaşılan teknik sistemler katman odaklı kalacaktır.)*

User-facing screens and their local controllers will remain feature-oriented. *(Kullanıcıya yönelik ekranlar ve yerel controller’ları özellik odaklı kalacaktır.)*

This avoids both an excessively horizontal architecture and duplicated feature-specific core logic. *(Bu, hem aşırı yatay bir mimariden hem de tekrar eden özelliğe özgü çekirdek mantıktan kaçınır.)*

---

# 98. Dependency Direction (Bağımlılık Yönü)

Presentation code may depend on application services and domain interfaces. *(Sunum kodu uygulama servislerine ve domain arayüzlerine bağımlı olabilir.)*

Application services may depend on repositories and navigation-domain interfaces. *(Uygulama servisleri repository’lere ve navigasyon domain arayüzlerine bağımlı olabilir.)*

Domain mathematics should not depend on presentation widgets. *(Domain matematiği sunum widget’larına bağımlı olmamalıdır.)*

Platform-specific code should not import Flutter feature-screen logic. *(Platforma özgü kod Flutter özellik ekranı mantığını import etmemelidir.)*

---

# 99. Dependency Flow Diagram (Bağımlılık Akış Diyagramı)

```
Presentation
    ↓
Application Controllers
    ↓
Services
    ↓
Domain Interfaces
   ↙ ↘
Domain   Repositories
          ↓
      Platform / Storage
```

Reverse dependencies should occur only through explicitly defined interfaces or callbacks. *(Ters bağımlılıklar yalnızca açıkça tanımlanmış arayüzler veya callback’ler üzerinden gerçekleşmelidir.)*

---

# 100. Testability Principle (Test Edilebilirlik İlkesi)

Navigation mathematics will be separated from physical Android sensor acquisition. *(Navigasyon matematiği fiziksel Android sensör veri toplamadan ayrılacaktır.)*

The same PDR implementation should be testable using synthetic or recorded measurements. *(Aynı PDR uygulaması sentetik veya kaydedilmiş ölçümler kullanılarak test edilebilir olmalıdır.)*

The same evaluation functions should operate on live-generated and replay-generated estimator outputs. *(Aynı değerlendirme fonksiyonları canlı üretilmiş ve replay ile üretilmiş tahmin motoru çıktıları üzerinde çalışmalıdır.)*

---

# 101. Mock Platform Interfaces (Mock Platform Arayüzleri)

Dart platform interfaces should support mock implementations for automated tests where practical. *(Dart platform arayüzleri uygulanabilir olduğu ölçüde otomatik testler için mock uygulamalarını desteklemelidir.)*

A mock sensor source may provide predefined sensor events. *(Mock sensör kaynağı önceden tanımlanmış sensör olayları sağlayabilir.)*

A mock GNSS source may provide predefined geographic positions. *(Mock GNSS kaynağı önceden tanımlanmış coğrafi konumlar sağlayabilir.)*

This allows application logic to be tested without physical hardware. *(Bu, uygulama mantığının fiziksel donanım olmadan test edilmesine olanak sağlar.)*

---

# 102. Physical Device Boundary (Fiziksel Cihaz Sınırı)

Mock tests cannot replace physical Redmi Note 9 Pro validation for sensor timing, GNSS behavior, ARCore, or LiteRT performance. *(Mock testler sensör zamanlaması, GNSS davranışı, ARCore veya LiteRT performansı için fiziksel Redmi Note 9 Pro doğrulamasının yerini alamaz.)*

The mobile architecture must therefore support both automated testing and physical-device instrumentation. *(Bu nedenle mobil mimari hem otomatik testleri hem de fiziksel cihaz instrumentation işlemlerini desteklemelidir.)*

---

# 103. Replay Integration in Mobile Architecture (Mobil Mimaride Replay Entegrasyonu)

The replay subsystem will inject recorded domain events into the same logical processing pipeline used by live data. *(Replay alt sistemi kaydedilmiş domain olaylarını canlı veri tarafından kullanılan aynı mantıksal işleme hattına enjekte edecektir.)*

Replay will bypass physical Android sensor acquisition. *(Replay fiziksel Android sensör veri toplama katmanını atlayacaktır.)*

It will not bypass preprocessing or estimator logic unless a specific experiment explicitly requires that behavior. *(Belirli bir deney bu davranışı açıkça gerektirmediği sürece ön işleme veya tahmin motoru mantığını atlamayacaktır.)*

---

# 104. Replay Modes (Replay Modları)

A full raw replay may begin from recorded sensor measurements. *(Tam ham replay kaydedilmiş sensör ölçümlerinden başlayabilir.)*

A processed replay may begin from previously processed intermediate data for debugging specific downstream components. *(İşlenmiş replay belirli aşağı akış bileşenlerini hata ayıklamak için daha önce işlenmiş ara veriden başlayabilir.)*

Final benchmark comparisons should prefer the earliest practical common input so competing algorithms receive equivalent evidence. *(Nihai benchmark karşılaştırmaları rakip algoritmaların eşdeğer kanıt alması için uygulanabilir en erken ortak girdiyi tercih etmelidir.)*

---

# 105. Mobile Security Boundary (Mobil Güvenlik Sınırı)

Experimental data will remain inside application-controlled storage by default. *(Deneysel veri varsayılan olarak uygulama kontrollü depolama içerisinde kalacaktır.)*

No automatic cloud synchronization module will exist in the core mobile architecture. *(Temel mobil mimaride otomatik bulut senkronizasyon modülü bulunmayacaktır.)*

User-triggered export will be the normal mechanism for moving session data to the development computer. *(Kullanıcı tarafından tetiklenen dışa aktarma oturum verisini geliştirme bilgisayarına taşımanın normal mekanizması olacaktır.)*

---

# 106. Camera Privacy Boundary (Kamera Gizlilik Sınırı)

ARCore camera access will be used for live tracking. *(ARCore kamera erişimi canlı takip için kullanılacaktır.)*

NAVGUARD will not save camera frames during ordinary navigation sessions by default. *(NAVGUARD normal navigasyon oturumları sırasında kamera karelerini varsayılan olarak kaydetmeyecektir.)*

If future research requires image retention, that capability must be separately documented and explicitly enabled. *(Gelecekteki araştırma görüntü saklamayı gerektirirse bu yetenek ayrı olarak dokümante edilmeli ve açıkça etkinleştirilmelidir.)*

---

# 107. Crash Recovery Principle (Çökme Kurtarma İlkesi)

The initial prototype does not require complete transaction-level recovery from every application crash. *(İlk prototip her uygulama çökmesinden tam transaction seviyesinde kurtarma gerektirmez.)*

However, logging should be designed so that already flushed experiment data remains readable whenever practical. *(Ancak kayıt sistemi uygulanabilir olduğu ölçüde önceden diske yazılmış deney verisinin okunabilir kalmasını sağlayacak şekilde tasarlanmalıdır.)*

A session interrupted by a crash must be marked incomplete when detected later. *(Bir çökme nedeniyle kesilen oturum daha sonra tespit edildiğinde eksik olarak işaretlenmelidir.)*

---

# 108. Incomplete Session Detection (Eksik Oturum Tespiti)

A completed session will receive an explicit completion marker in its manifest. *(Tamamlanan bir oturum manifest içerisinde açık bir tamamlanma işareti alacaktır.)*

If the application later discovers a session without this marker, the session will be treated as interrupted or incomplete. *(Uygulama daha sonra bu işarete sahip olmayan bir oturum keşfederse oturum kesilmiş veya eksik olarak ele alınacaktır.)*

Incomplete sessions may still be useful for debugging but should not automatically enter formal benchmark analysis. *(Eksik oturumlar hata ayıklama için yine yararlı olabilir ancak resmî benchmark analizine otomatik olarak girmemelidir.)*

---

# 109. Startup Architecture (Başlangıç Mimarisi)

NAVGUARD startup will initialize only application-critical lightweight components immediately. *(NAVGUARD başlangıcı yalnızca uygulama açısından kritik hafif bileşenleri hemen başlatacaktır.)*

Expensive resources such as ARCore and active high-frequency sensor acquisition will use lazy initialization. *(ARCore ve aktif yüksek frekanslı sensör veri toplama gibi pahalı kaynaklar lazy initialization kullanacaktır.)*

The motion model may be preloaded when approaching a navigation session if this reduces first-inference latency without creating unnecessary startup cost. *(Hareket modeli gereksiz başlangıç maliyeti oluşturmadan ilk çıkarım gecikmesini azaltıyorsa navigasyon oturumuna yaklaşılırken önceden yüklenebilir.)*

---

# 110. Bootstrap Sequence (Bootstrap Sırası)

```
Flutter Application Start
        ↓
Load App Configuration
        ↓
Initialize Local Database
        ↓
Initialize Platform Interfaces
        ↓
Read Device / Permission State
        ↓
Build Readiness State
        ↓
Show Home Screen
```

ARCore, active GNSS subscriptions, and high-frequency sensors do not need to start during ordinary application bootstrap. *(ARCore, aktif GNSS abonelikleri ve yüksek frekanslı sensörlerin normal uygulama bootstrap sırasında başlamasına gerek yoktur.)*

---

# 111. Navigation Initialization Sequence (Navigasyon Başlatma Sırası)

```
Select Experiment Profile
        ↓
Check Permissions
        ↓
Check Device Capabilities
        ↓
Start Required Sensors
        ↓
Acquire Initial GNSS
        ↓
Initialize Heading
        ↓
Initialize Optional ARCore
        ↓
Load / Verify AI Model
        ↓
Create Session
        ↓
Start Logging
        ↓
Start Navigation Pipeline
```

The exact ordering may be refined to ensure that no scientifically relevant initial measurements are lost. *(Bilimsel olarak ilgili başlangıç ölçümlerinin kaybolmamasını sağlamak için kesin sıralama iyileştirilebilir.)*

---

# 112. GNSS-Denied Transition Sequence (GNSS Kesintili Geçiş Sırası)

```
GNSS Available
      ↓
Initial Anchor Valid
      ↓
User Activates GNSS-Denied Test
      ↓
Record Mode Transition
      ↓
Block GNSS Estimator Channel
      ↓
Keep Ground Truth Logging Active
      ↓
Continue Local Estimation
```

The mode transition timestamp must be preserved precisely. *(Mod geçiş zaman damgası hassas şekilde korunmalıdır.)*

---

# 113. GNSS Recovery Sequence (GNSS Geri Kazanım Sırası)

```
GNSS-Denied Active
       ↓
GNSS Recovery Requested / Detected
       ↓
Check GNSS Quality
       ↓
Compare Estimate With GNSS
       ↓
Record Recovery Error
       ↓
Relocalize / Re-anchor
       ↓
Return to GNSS-Enabled State
```

The historical denied trajectory will remain unchanged after recovery. *(Geçmiş kesinti rotası geri kazanımdan sonra değişmeden kalacaktır.)*

---

# 114. Build Configuration Architecture (Build Yapılandırma Mimarisi)

Development-only diagnostic capabilities may be controlled using build-time or application configuration flags. *(Yalnızca geliştirmeye özgü tanısal yetenekler build zamanı veya uygulama yapılandırma flag’leri kullanılarak kontrol edilebilir.)*

Research capabilities required for formal experiments must remain accessible in the benchmark build. *(Resmî deneyler için gerekli araştırma yetenekleri benchmark build’inde erişilebilir kalmalıdır.)*

Experimental toggles must not accidentally alter final benchmark configuration without being recorded. *(Deneysel toggle’lar kaydedilmeden nihai benchmark yapılandırmasını yanlışlıkla değiştirmemelidir.)*

---

# 115. Environment Configuration (Ortam Yapılandırması)

NAVGUARD does not require development, staging, and production backend environments because no mandatory backend exists. *(NAVGUARD zorunlu backend bulunmadığı için development, staging ve production backend ortamlarına ihtiyaç duymaz.)*

The important configuration distinction is instead between development, audit, benchmark, and demo behavior. *(Önemli yapılandırma ayrımı bunun yerine geliştirme, denetim, benchmark ve demo davranışı arasındadır.)*

These modes may control diagnostic verbosity and available controls without changing core estimator mathematics silently. *(Bu modlar temel tahmin motoru matematiğini sessizce değiştirmeden tanısal ayrıntı seviyesini ve kullanılabilir kontrolleri yönetebilir.)*

---

# 116. Proposed Runtime Modes (Önerilen Çalışma Modları)

### Development Mode (Geliştirme Modu)

Development Mode may expose verbose diagnostics and experimental controls. *(Geliştirme Modu ayrıntılı tanısal bilgileri ve deneysel kontrolleri gösterebilir.)*

### Audit Mode (Denetim Modu)

Audit Mode may expose device capability and sampling tools. *(Denetim Modu cihaz yetenek ve örnekleme araçlarını gösterebilir.)*

### Benchmark Mode (Benchmark Modu)

Benchmark Mode will prioritize frozen configuration and reproducible data recording. *(Benchmark Modu sabitlenmiş yapılandırmaya ve tekrarlanabilir veri kaydına öncelik verecektir.)*

### Demo Mode (Demo Modu)

Demo Mode may simplify visible controls while using the same validated navigation pipeline. *(Demo Modu aynı doğrulanmış navigasyon hattını kullanırken görünür kontrolleri basitleştirebilir.)*

---

# 117. Single Source of Truth Principle (Tek Gerçek Kaynak İlkesi)

Each critical runtime fact should have one authoritative owner. *(Her kritik çalışma zamanı gerçeğinin bir ana sahibi olmalıdır.)*

The Navigation Mode Manager will own the current navigation mode. *(Navigasyon Mod Yöneticisi mevcut navigasyon modunun sahibi olacaktır.)*

The Session Manager will own the current session identity. *(Oturum Yöneticisi mevcut oturum kimliğinin sahibi olacaktır.)*

The Sensor Manager will own physical sensor acquisition state. *(Sensör Yöneticisi fiziksel sensör veri toplama durumunun sahibi olacaktır.)*

The AI Runtime will own the loaded motion-model state. *(Yapay Zekâ Çalışma Zamanı yüklenmiş hareket modeli durumunun sahibi olacaktır.)*

The UI will observe these states rather than recreate them independently. *(UI bu durumları bağımsız olarak yeniden oluşturmak yerine gözlemleyecektir.)*

---

# 118. Event Ordering Principle (Olay Sıralama İlkesi)

The navigation pipeline must prefer measurement timestamps over callback arrival order when reconstructing temporal relationships. *(Navigasyon hattı zamansal ilişkileri yeniden oluştururken callback geliş sırası yerine ölçüm zaman damgalarını tercih etmelidir.)*

Asynchronous platform boundaries may cause two events to arrive in a different order from their physical measurement times. *(Asenkron platform sınırları iki olayın fiziksel ölçüm zamanlarından farklı bir sırada ulaşmasına neden olabilir.)*

The synchronization layer must account for this behavior. *(Senkronizasyon katmanı bu davranışı dikkate almalıdır.)*

---

# 119. Sequence Number Policy (Sıra Numarası Politikası)

High-frequency streams may include monotonically increasing local sequence numbers in addition to timestamps. *(Yüksek frekanslı akışlar zaman damgalarına ek olarak monotonik olarak artan yerel sıra numaraları içerebilir.)*

Sequence numbers can help detect dropped or duplicated events during debugging. *(Sıra numaraları hata ayıklama sırasında düşen veya yinelenen olayları tespit etmeye yardımcı olabilir.)*

They will not replace physical sensor timestamps. *(Fiziksel sensör zaman damgalarının yerini almayacaktır.)*

---

# 120. Queue Backpressure Principle (Kuyruk Backpressure İlkesi)

NAVGUARD must avoid silently accumulating unlimited event queues when downstream processing becomes slower than acquisition. *(NAVGUARD aşağı akış işleme veri toplamadan daha yavaş hale geldiğinde sınırsız olay kuyruklarını sessizce biriktirmekten kaçınmalıdır.)*

Queue size or processing delay should be observable in diagnostics. *(Kuyruk boyutu veya işleme gecikmesi tanısal bilgilerde gözlemlenebilir olmalıdır.)*

A sustained overload condition must produce a warning or degraded state. *(Sürekli aşırı yük durumu bir uyarı veya bozulmuş durum üretmelidir.)*

---

# 121. Dropped Data Policy (Düşen Veri Politikası)

The system should prefer preserving research sensor samples when practical. *(Sistem uygulanabilir olduğu ölçüde araştırma sensör örneklerini korumayı tercih etmelidir.)*

If data must be dropped because of a sustained overload condition, the loss must be measurable or recorded. *(Sürekli aşırı yük durumu nedeniyle veri düşürülmesi gerekiyorsa kayıp ölçülebilir veya kaydedilmiş olmalıdır.)*

The application must not silently fabricate intermediate samples unless a documented interpolation step explicitly requires it. *(Dokümante edilmiş bir interpolasyon adımı açıkça gerektirmediği sürece uygulama ara örnekleri sessizce uydurmamalıdır.)*

---

# 122. Development Diagnostics Contract (Geliştirme Tanı Sözleşmesi)

The mobile architecture should expose sufficient internal measurements to identify pipeline bottlenecks. *(Mobil mimari hat darboğazlarını belirlemek için yeterli dahili ölçümü sunmalıdır.)*

At minimum, sensor rate, sensor delay, logging queue state, AI latency, estimator update rate, and ARCore tracking state should be inspectable. *(Minimum olarak sensör hızı, sensör gecikmesi, kayıt kuyruğu durumu, yapay zekâ gecikmesi, tahmin motoru güncelleme hızı ve ARCore takip durumu incelenebilir olmalıdır.)*

These measurements may later be disabled or hidden from the simplified demo UI. *(Bu ölçümler daha sonra basitleştirilmiş demo UI’ından devre dışı bırakılabilir veya gizlenebilir.)*

---

# 123. Android-Specific Fallback Architecture (Android’e Özgü Geri Dönüş Mimarisi)

If a virtual Android sensor is unavailable, the navigation domain will use available physical sensors and its own processing where possible. *(Bir sanal Android sensörü kullanılamazsa navigasyon domain’i mümkün olduğunda mevcut fiziksel sensörleri ve kendi işlemesini kullanacaktır.)*

If ARCore cannot initialize, ARCore-enabled profiles will be marked unavailable while baseline navigation remains available. *(ARCore başlatılamazsa ARCore etkin profiller kullanılamaz olarak işaretlenirken temel navigasyon kullanılabilir kalacaktır.)*

If LiteRT cannot initialize, AI-required profiles will be marked degraded or unavailable while deterministic profiles remain available. *(LiteRT başlatılamazsa yapay zekâ gerektiren profiller bozulmuş veya kullanılamaz olarak işaretlenirken deterministik profiller kullanılabilir kalacaktır.)*

---

# 124. Mobile Minimum Architecture (Mobil Minimum Mimari)

The minimum mobile application architecture will include Flutter UI, Riverpod-compatible state management, Kotlin sensor acquisition, Kotlin GNSS access, local session storage, deterministic step detection, heading estimation, baseline PDR, on-device motion AI, map or local trajectory visualization, and experiment evaluation. *(Minimum mobil uygulama mimarisi Flutter UI, Riverpod uyumlu durum yönetimi, Kotlin sensör veri toplama, Kotlin GNSS erişimi, yerel oturum depolama, deterministik adım tespiti, yön tahmini, temel PDR, cihaz üzeri hareket yapay zekâsı, harita veya yerel rota görselleştirmesi ve deney değerlendirmesini içerecektir.)*

ARCore and advanced EKF fusion will not be required for the minimum fallback path. *(ARCore ve gelişmiş EKF füzyonu minimum geri dönüş hattı için gerekli olmayacaktır.)*

---

# 125. Mobile Target Architecture (Mobil Hedef Mimari)

The target mobile architecture will extend the minimum system with native ARCore tracking, sensor quality information, learned navigation context, EKF-based fusion, uncertainty estimation, and controlled GNSS recovery. *(Hedef mobil mimari minimum sistemi native ARCore takibi, sensör kalite bilgisi, öğrenilmiş navigasyon bağlamı, EKF tabanlı füzyon, belirsizlik tahmini ve kontrollü GNSS geri kazanımıyla genişletecektir.)*

All target modules will retain deterministic fallbacks where technically possible. *(Tüm hedef modüller teknik olarak mümkün olduğunda deterministik geri dönüşleri koruyacaktır.)*

---

# 126. Mobile Architecture Validation Tests (Mobil Mimari Doğrulama Testleri)

The platform-channel bridge must be tested for reliable command and event transfer. *(Platform-channel köprüsü güvenilir komut ve olay aktarımı için test edilmelidir.)*

The sensor layer must be tested under continuous multi-sensor load. *(Sensör katmanı sürekli çoklu sensör yükü altında test edilmelidir.)*

The logging layer must be tested under the selected sampling configuration. *(Kayıt katmanı seçilen örnekleme yapılandırması altında test edilmelidir.)*

The LiteRT layer must be tested independently and under combined navigation load. *(LiteRT katmanı bağımsız olarak ve birleşik navigasyon yükü altında test edilmelidir.)*

The ARCore layer must be tested independently and together with sensor acquisition. *(ARCore katmanı bağımsız olarak ve sensör veri toplamayla birlikte test edilmelidir.)*

The Flutter interface must remain responsive during the combined runtime test. *(Flutter arayüzü birleşik çalışma zamanı testi sırasında tepki verebilir kalmalıdır.)*

---

# 127. Mobile Architecture Acceptance Criteria (Mobil Mimari Kabul Kriterleri)

The mobile architecture must successfully acquire required sensors on the physical Redmi Note 9 Pro. *(Mobil mimari fiziksel Redmi Note 9 Pro üzerinde gerekli sensörleri başarıyla elde etmelidir.)*

The mobile architecture must preserve authoritative timestamps through the native-to-Dart boundary. *(Mobil mimari native-to-Dart sınırı boyunca ana zaman damgalarını korumalıdır.)*

The mobile architecture must keep the user interface responsive during normal navigation processing. *(Mobil mimari normal navigasyon işleme sırasında kullanıcı arayüzünü tepki verebilir durumda tutmalıdır.)*

The mobile architecture must maintain ground-truth GNSS isolation. *(Mobil mimari gerçek referans GNSS izolasyonunu korumalıdır.)*

The mobile architecture must allow PDR operation if ARCore becomes unavailable. *(Mobil mimari ARCore kullanılamaz hale gelirse PDR çalışmasına izin vermelidir.)*

The mobile architecture must support local on-device AI inference without cloud communication. *(Mobil mimari bulut iletişimi olmadan yerel cihaz üzeri yapay zekâ çıkarımını desteklemelidir.)*

The mobile architecture must produce exportable experimental session data. *(Mobil mimari dışa aktarılabilir deneysel oturum verisi üretmelidir.)*

---

# 128. Mobile Architecture Risks (Mobil Mimari Riskleri)

The largest mobile architecture risk is excessive communication overhead between Kotlin and Dart for high-frequency sensor streams. *(En büyük mobil mimari risk yüksek frekanslı sensör akışlarında Kotlin ile Dart arasındaki aşırı iletişim yüküdür.)*

This risk will be evaluated through the initial throughput benchmark. *(Bu risk ilk throughput benchmark’ı ile değerlendirilecektir.)*

A second risk is resource competition between ARCore, LiteRT, logging, map rendering, and sensor acquisition. *(İkinci risk ARCore, LiteRT, kayıt, harita render ve sensör veri toplama arasındaki kaynak rekabetidir.)*

A third risk is accidental coupling of UI lifecycle to experiment lifecycle. *(Üçüncü risk UI yaşam döngüsünün deney yaşam döngüsüne yanlışlıkla bağlanmasıdır.)*

A fourth risk is uncontrolled queue growth during sustained high-frequency recording. *(Dördüncü risk sürekli yüksek frekanslı kayıt sırasında kontrolsüz kuyruk büyümesidir.)*

---

# 129. Mobile Architecture Risk Mitigation (Mobil Mimari Risk Azaltımı)

High-frequency streams will be benchmarked before finalizing the Kotlin-to-Dart processing boundary. *(Yüksek frekanslı akışlar Kotlin-to-Dart işleme sınırı kesinleştirilmeden önce benchmark edilecektir.)*

UI refresh frequency will remain independent from sensor acquisition frequency. *(UI yenileme frekansı sensör veri toplama frekansından bağımsız kalacaktır.)*

Heavy storage operations will use asynchronous or buffered execution. *(Ağır depolama işlemleri asenkron veya tamponlanmış çalışma kullanacaktır.)*

Optional subsystems will be activated only when required. *(İsteğe bağlı alt sistemler yalnızca gerekli olduklarında etkinleştirilecektir.)*

Queue depth and processing latency will be observable during development. *(Kuyruk derinliği ve işleme gecikmesi geliştirme sırasında gözlemlenebilir olacaktır.)*

---

# 130. Architecture Freeze Decisions Requiring Measurement (Ölçüm Gerektiren Mimari Sabitleme Kararları)

The final location of real-time sensor preprocessing between Kotlin and Dart will be decided after throughput testing. *(Gerçek zamanlı sensör ön işlemenin Kotlin ile Dart arasındaki nihai konumu throughput testinden sonra belirlenecektir.)*

The final EKF implementation language will be decided after profiling. *(Nihai EKF uygulama dili profillemeden sonra belirlenecektir.)*

The final sensor batching strategy across platform channels will be decided after device testing. *(Platform channel’ları üzerinden nihai sensör batching stratejisi cihaz testinden sonra belirlenecektir.)*

The final LiteRT delegate configuration will be decided after CPU baseline measurements. *(Nihai LiteRT delegate yapılandırması CPU temel ölçümlerinden sonra belirlenecektir.)*

These decisions are intentionally left measurable rather than being fixed through assumption. *(Bu kararlar varsayımla sabitlenmek yerine bilinçli olarak ölçülebilir bırakılmıştır.)*

---

# 131. Initial Implementation Boundary Decision (Başlangıç Uygulama Sınırı Kararı)

The initial implementation will begin with native sensor acquisition and GNSS access in Kotlin while navigation mathematics remains in Dart. *(İlk uygulama navigasyon matematiği Dart içerisinde kalırken Kotlin içerisinde native sensör veri toplama ve GNSS erişimiyle başlayacaktır.)*

This provides a simple and testable boundary for the first prototype. *(Bu ilk prototip için basit ve test edilebilir bir sınır sağlar.)*

ARCore and LiteRT will then be added as separate native modules without changing the sensor acquisition ownership model. *(Daha sonra ARCore ve LiteRT sensör veri toplama sahiplik modelini değiştirmeden ayrı native modüller olarak eklenecektir.)*

---

# 132. Mobile Architecture Non-Goals (Mobil Mimari Olmayan Hedefler)

NAVGUARD will not implement a complex multi-module Android application architecture solely to imitate large commercial applications. *(NAVGUARD yalnızca büyük ticari uygulamaları taklit etmek için karmaşık çok modüllü Android uygulama mimarisi geliştirmeyecektir.)*

NAVGUARD will not introduce dependency injection frameworks unless dependency complexity makes them genuinely useful. *(NAVGUARD bağımlılık karmaşıklığı onları gerçekten yararlı hale getirmediği sürece dependency injection framework’leri dahil etmeyecektir.)*

NAVGUARD will not create native duplicates of Flutter screens. *(NAVGUARD Flutter ekranlarının native kopyalarını oluşturmayacaktır.)*

NAVGUARD will not require background service complexity for the initial foreground research workflow. *(NAVGUARD ilk ön plan araştırma iş akışı için arka plan servis karmaşıklığı gerektirmeyecektir.)*

---

# 133. Architecture Simplicity Rule (Mimari Basitlik Kuralı)

Every abstraction added to NAVGUARD must have a clear responsibility. *(NAVGUARD’a eklenen her soyutlamanın açık bir sorumluluğu olmalıdır.)*

An architectural layer that exists only to forward identical calls without improving testability, platform isolation, or maintainability should not be added. *(Test edilebilirliği, platform izolasyonunu veya sürdürülebilirliği artırmadan yalnızca aynı çağrıları iletmek için var olan bir mimari katman eklenmemelidir.)*

The project will prefer understandable architecture over enterprise-style complexity that provides no research value. *(Proje araştırma değeri sağlamayan kurumsal tarz karmaşıklık yerine anlaşılabilir mimariyi tercih edecektir.)*

---

# 134. Final Mobile Architecture Diagram (Nihai Mobil Mimari Diyagramı)

```
┌────────────────────────────────────────────────────────────┐
│                     FLUTTER UI                             │
│                                                            │
│ Home / Readiness / Live Navigation / Diagnostics / Results│
└─────────────────────────────┬──────────────────────────────┘
                              │
                              ▼
┌────────────────────────────────────────────────────────────┐
│                 APPLICATION STATE                          │
│                                                            │
│ Riverpod / Controllers / Session / Configuration / Modes  │
└─────────────────────────────┬──────────────────────────────┘
                              │
                              ▼
┌────────────────────────────────────────────────────────────┐
│                    DART DOMAIN CORE                        │
│                                                            │
│ Preprocessing / Step / Heading / PDR / Fusion / Metrics   │
└───────────────────────┬─────────────────────┬──────────────┘
                        │                     │
                        │                     ▼
                        │              Local Storage
                        │              SQLite / CSV / JSON
                        │
                 Platform Interfaces
                        │
        ┌───────────────┼──────────────────┬────────────────┐
        ▼               ▼                  ▼                ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ Sensors      │ │ GNSS         │ │ ARCore       │ │ LiteRT       │
│ Kotlin       │ │ Kotlin       │ │ Kotlin       │ │ Kotlin       │
└──────┬───────┘ └──────┬───────┘ └──────┬───────┘ └──────┬───────┘
       │                │                │                │
       ▼                ▼                ▼                ▼
 SensorManager     LocationManager    ARCore SDK      AI Runtime
       │                │
       │                ├──────────► Ground Truth Logger
       │                │
       └────────────────┴──────────────┐
                                      ▼
                              Navigation Pipeline
                                      │
                                      ▼
                           Position + Uncertainty
```

---

# 135. Final Mobile Architecture Statement (Nihai Mobil Mimari Bildirimi)

**NAVGUARD will use Flutter as the primary application and presentation environment while Kotlin will provide direct Android integration for hardware-sensitive sensors, GNSS, ARCore, and LiteRT inference.** *(NAVGUARD temel uygulama ve sunum ortamı olarak Flutter kullanırken Kotlin donanıma duyarlı sensörler, GNSS, ARCore ve LiteRT çıkarımı için doğrudan Android entegrasyonu sağlayacaktır.)*

**Platform-independent navigation mathematics will initially remain in a testable Dart domain layer, while measured performance results will determine whether any computation must later move closer to the native Android layer.** *(Platformdan bağımsız navigasyon matematiği başlangıçta test edilebilir bir Dart domain katmanında kalacak, herhangi bir hesaplamanın daha sonra native Android katmanına yaklaşması gerekip gerekmediğini ise ölçülen performans sonuçları belirleyecektir.)*

**High-frequency acquisition, navigation processing, logging, AI inference, and UI rendering will operate as decoupled workloads so that the Flutter interface does not control the timing of the navigation estimator.** *(Yüksek frekanslı veri toplama, navigasyon işleme, kayıt, yapay zekâ çıkarımı ve UI render birbirinden ayrılmış iş yükleri olarak çalışacak; böylece Flutter arayüzü navigasyon tahmin motorunun zamanlamasını kontrol etmeyecektir.)*

**The mobile application will preserve modular fallbacks, ground-truth GNSS isolation, offline operation, experiment reproducibility, and direct physical-device observability as primary architectural requirements.** *(Mobil uygulama temel mimari gereksinimler olarak modüler geri dönüşleri, gerçek referans GNSS izolasyonunu, çevrimdışı çalışmayı, deney tekrarlanabilirliğini ve doğrudan fiziksel cihaz gözlemlenebilirliğini koruyacaktır.)*

---

# 136. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development Mobile Architecture Completed *(Doküman Durumu: Geliştirme Öncesi Mobil Mimari Tamamlandı)*

**Flutter Architecture:** Defined *(Flutter Mimarisi: Tanımlandı)*

**Native Kotlin Boundary:** Defined *(Native Kotlin Sınırı: Tanımlandı)*

**Sensor Ownership:** Native Kotlin Sensor Manager *(Sensör Sahipliği: Native Kotlin Sensör Yöneticisi)*

**GNSS Ownership:** Native Kotlin GNSS Manager *(GNSS Sahipliği: Native Kotlin GNSS Yöneticisi)*

**ARCore Ownership:** Native Kotlin ARCore Manager *(ARCore Sahipliği: Native Kotlin ARCore Yöneticisi)*

**AI Runtime Ownership:** Native Kotlin LiteRT Runtime *(Yapay Zekâ Çalışma Zamanı Sahipliği: Native Kotlin LiteRT Çalışma Zamanı)*

**Primary Navigation Mathematics:** Dart Domain Core, Pending Profiling *(Temel Navigasyon Matematiği: Dart Domain Çekirdeği, Profilleme Bekleniyor)*

**Application State Management:** Riverpod Preferred *(Uygulama Durum Yönetimi: Riverpod Tercih Ediliyor)*

**High-Frequency Storage:** Append-Oriented Session Files *(Yüksek Frekanslı Depolama: Append Odaklı Oturum Dosyaları)*

**Metadata Storage:** SQLite *(Metadata Depolama: SQLite)*

**Exact Kotlin-to-Dart Sensor Boundary:** Pending Device Throughput Benchmark *(Kesin Kotlin-to-Dart Sensör Sınırı: Cihaz Throughput Benchmark’ı Bekleniyor)*

**Next Documentation Item:** 11 — Navigation Modes & State Machine *(Sonraki Dokümantasyon Öğesi: 11 — Navigasyon Modları ve Durum Makinesi)*