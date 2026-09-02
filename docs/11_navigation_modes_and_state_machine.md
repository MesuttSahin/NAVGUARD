# 11 — Navigation Modes & State Machine (Navigasyon Modları ve Durum Makinesi)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the operational navigation modes, runtime states, transition rules, guards, failure states, recovery behavior, and experiment-state logic of NAVGUARD. *(Bu doküman, NAVGUARD’ın operasyonel navigasyon modlarını, çalışma zamanı durumlarını, geçiş kurallarını, koruma koşullarını, hata durumlarını, geri kazanım davranışını ve deney durum mantığını tanımlar.)*

The state machine controls when GNSS information may influence the navigation estimator and when GNSS must remain isolated as evaluation-only ground truth. *(Durum makinesi, GNSS bilgisinin navigasyon tahmin motorunu ne zaman etkileyebileceğini ve GNSS’in ne zaman yalnızca değerlendirme amaçlı gerçek referans olarak izole kalması gerektiğini kontrol eder.)*

The state machine also coordinates initialization, readiness, GNSS denial, local navigation, degradation, GNSS recovery, relocalization, session completion, and failure handling. *(Durum makinesi ayrıca başlatma, hazırlık, GNSS kesintisi, yerel navigasyon, bozulma, GNSS geri kazanımı, yeniden konumlandırma, oturum tamamlama ve hata yönetimini koordine eder.)*

---

# 2. State Machine Objective (Durum Makinesi Hedefi)

The primary objective of the NAVGUARD state machine is to make every navigation transition explicit and reproducible. *(NAVGUARD durum makinesinin temel hedefi her navigasyon geçişini açık ve tekrarlanabilir hale getirmektir.)*

The application must never silently change whether GNSS is allowed to influence the estimator. *(Uygulama GNSS’in tahmin motorunu etkileyip etkileyemeyeceğini hiçbir zaman sessizce değiştirmemelidir.)*

Every important mode transition must be timestamped and recorded in the session log. *(Her önemli mod geçişi zaman damgalı olmalı ve oturum kaydına yazılmalıdır.)*

---

# 3. Core Navigation Modes (Temel Navigasyon Modları)

NAVGUARD will support three primary navigation modes. *(NAVGUARD üç temel navigasyon modunu destekleyecektir.)*

### GNSS Mode (GNSS Modu)

GNSS Mode allows GNSS measurements to update the active navigation estimator. *(GNSS Modu, GNSS ölçümlerinin aktif navigasyon tahmin motorunu güncellemesine izin verir.)*

### Evaluation Mode (Değerlendirme Modu)

Evaluation Mode records GNSS as ground truth while preventing GNSS measurements from entering the alternative estimator during the denied phase. *(Değerlendirme Modu, kesinti aşamasında GNSS ölçümlerinin alternatif tahmin motoruna girmesini engellerken GNSS’i gerçek referans olarak kaydeder.)*

### NAVGUARD Mode (NAVGUARD Modu)

NAVGUARD Mode represents active GNSS-denied navigation using local sensor-based estimation. *(NAVGUARD Modu, yerel sensör tabanlı tahmin kullanılarak gerçekleştirilen aktif GNSS kesintili navigasyonu temsil eder.)*

---

# 4. Navigation Mode Versus Runtime State (Navigasyon Modu ile Çalışma Zamanı Durumu Ayrımı)

A navigation mode defines the estimator’s GNSS-access policy. *(Bir navigasyon modu tahmin motorunun GNSS erişim politikasını tanımlar.)*

A runtime state defines the current lifecycle position of the navigation session. *(Bir çalışma zamanı durumu navigasyon oturumunun mevcut yaşam döngüsü konumunu tanımlar.)*

For example, NAVGUARD Mode may exist while the runtime state is ACTIVE_LOCAL_NAVIGATION or DEGRADED_LOCAL_NAVIGATION. *(Örneğin NAVGUARD Modu, çalışma zamanı durumu ACTIVE_LOCAL_NAVIGATION veya DEGRADED_LOCAL_NAVIGATION iken mevcut olabilir.)*

This distinction prevents user-interface labels from being confused with estimator lifecycle logic. *(Bu ayrım kullanıcı arayüzü etiketlerinin tahmin motoru yaşam döngüsü mantığıyla karıştırılmasını önler.)*

---

# 5. Primary Runtime States (Temel Çalışma Zamanı Durumları)

NAVGUARD will use the following high-level runtime states. *(NAVGUARD aşağıdaki üst seviye çalışma zamanı durumlarını kullanacaktır.)*

`text id="x0mvyv" IDLE READINESS_CHECK NOT_READY INITIALIZING GNSS_ACQUISITION GNSS_READY CALIBRATING READY_TO_START GNSS_NAVIGATION EVALUATION_ARMED GNSS_DENIAL_TRANSITION ACTIVE_LOCAL_NAVIGATION DEGRADED_LOCAL_NAVIGATION GNSS_RECOVERY_PENDING GNSS_RECOVERED RELOCALIZING SESSION_STOPPING SESSION_COMPLETED SESSION_INVALID ERROR`

The final implementation may use different enum names while preserving the behavior defined in this document. *(Nihai uygulama bu dokümanda tanımlanan davranışı koruyarak farklı enum adları kullanabilir.)*

---

# 6. High-Level State Machine (Üst Seviye Durum Makinesi)

`text id="ydkqem" IDLE   │   ▼ READINESS_CHECK   │   ├────────► NOT_READY   │             │   │             └────► READINESS_CHECK   ▼ INITIALIZING   │   ▼ GNSS_ACQUISITION   │   ▼ GNSS_READY   │   ▼ CALIBRATING   │   ▼ READY_TO_START   │   ├────────► GNSS_NAVIGATION   │   └────────► EVALUATION_ARMED                   │                   ▼           GNSS_DENIAL_TRANSITION                   │                   ▼           ACTIVE_LOCAL_NAVIGATION                   │           ┌───────┴────────┐           ▼                ▼ DEGRADED_LOCAL_NAVIGATION  GNSS_RECOVERY_PENDING           │                │           └───────┬────────┘                   ▼             GNSS_RECOVERED                   │                   ▼              RELOCALIZING                   │                   ▼            GNSS_NAVIGATION                   │                   ▼           SESSION_STOPPING                   │                   ▼           SESSION_COMPLETED`

Failure transitions may lead to SESSION_INVALID or ERROR depending on severity. *(Hata geçişleri ciddiyete bağlı olarak SESSION_INVALID veya ERROR durumuna gidebilir.)*

---

# 7. IDLE State (IDLE Durumu)

IDLE represents an application state in which no formal navigation session is active. *(IDLE, hiçbir resmî navigasyon oturumunun aktif olmadığı uygulama durumunu temsil eder.)*

No formal estimator state is considered valid in IDLE. *(IDLE durumunda hiçbir resmî tahmin motoru durumu geçerli kabul edilmez.)*

High-frequency sensor acquisition should not remain active unless a diagnostic tool explicitly requires it. *(Bir tanı aracı açıkça gerektirmediği sürece yüksek frekanslı sensör veri toplama aktif kalmamalıdır.)*

### Allowed Transitions (İzin Verilen Geçişler)

`IDLE → READINESS_CHECK` *(IDLE → HAZIRLIK KONTROLÜ)*

---

# 8. READINESS_CHECK State (READINESS_CHECK Durumu)

READINESS_CHECK verifies whether the selected navigation configuration can begin safely and scientifically validly. *(READINESS_CHECK, seçilen navigasyon yapılandırmasının güvenli ve bilimsel olarak geçerli şekilde başlayıp başlayamayacağını doğrular.)*

The state will check mandatory sensors, permissions, GNSS availability, storage, AI runtime, and ARCore where required by the selected profile. *(Durum; zorunlu sensörleri, izinleri, GNSS kullanılabilirliğini, depolamayı, yapay zekâ çalışma zamanını ve seçilen profil gerektiriyorsa ARCore’u kontrol edecektir.)*

### Successful Transition (Başarılı Geçiş)

`READINESS_CHECK → INITIALIZING` *(READINESS_CHECK → BAŞLATILIYOR)*

### Failed Transition (Başarısız Geçiş)

`READINESS_CHECK → NOT_READY` *(READINESS_CHECK → HAZIR DEĞİL)*

---

# 9. NOT_READY State (NOT_READY Durumu)

NOT_READY indicates that at least one required condition for the selected experiment profile is not satisfied. *(NOT_READY, seçilen deney profili için gerekli en az bir koşulun karşılanmadığını gösterir.)*

The application must identify the blocking condition. *(Uygulama engelleyici koşulu belirlemelidir.)*

The user must not be allowed to start a formal benchmark session while required readiness conditions remain unresolved. *(Zorunlu hazırlık koşulları çözülmemiş durumda kalırken kullanıcının resmî benchmark oturumu başlatmasına izin verilmemelidir.)*

A PDR-only profile may still be available when an ARCore-specific readiness condition fails. *(ARCore’a özgü bir hazırlık koşulu başarısız olduğunda yalnızca PDR kullanan profil yine kullanılabilir olabilir.)*

---

# 10. INITIALIZING State (INITIALIZING Durumu)

INITIALIZING prepares the internal navigation services required by the selected configuration. *(INITIALIZING seçilen yapılandırma tarafından gerekli dahili navigasyon servislerini hazırlar.)*

The application may initialize sensor streams, local storage, navigation models, and required native components during this state. *(Uygulama bu durumda sensör akışlarını, yerel depolamayı, navigasyon modellerini ve gerekli native bileşenleri başlatabilir.)*

The state must not yet be treated as an active benchmark period. *(Bu durum henüz aktif benchmark dönemi olarak ele alınmamalıdır.)*

---

# 11. GNSS_ACQUISITION State (GNSS_ACQUISITION Durumu)

GNSS_ACQUISITION waits for a GNSS position that satisfies the configured initialization conditions. *(GNSS_ACQUISITION yapılandırılmış başlatma koşullarını karşılayan bir GNSS konumunu bekler.)*

The system will record GNSS accuracy and timing information during this stage. *(Sistem bu aşamada GNSS doğruluk ve zamanlama bilgisini kaydedecektir.)*

The exact GNSS acceptance threshold will remain configurable until field measurements establish a suitable value. *(Kesin GNSS kabul eşiği saha ölçümleri uygun bir değer belirleyene kadar yapılandırılabilir kalacaktır.)*

---

# 12. GNSS_READY State (GNSS_READY Durumu)

GNSS_READY means that an acceptable global position is available for session initialization. *(GNSS_READY, oturum başlatma için kabul edilebilir bir global konumun mevcut olduğu anlamına gelir.)*

The accepted GNSS position may become the basis of the initial local navigation anchor. *(Kabul edilen GNSS konumu başlangıç yerel navigasyon çapasının temeli olabilir.)*

The application must record the accepted anchor information. *(Uygulama kabul edilen çapa bilgisini kaydetmelidir.)*

---

# 13. CALIBRATING State (CALIBRATING Durumu)

CALIBRATING performs the required session-level initialization checks before navigation begins. *(CALIBRATING navigasyon başlamadan önce gerekli oturum seviyesi başlatma kontrollerini gerçekleştirir.)*

The process may verify inertial stability, heading initialization, magnetic quality, GNSS quality, and ARCore readiness. *(İşlem ataletsel kararlılığı, yön başlatmayı, manyetik kaliteyi, GNSS kalitesini ve ARCore hazırlığını doğrulayabilir.)*

Calibration failure may return the system to a readiness or initialization state. *(Kalibrasyon başarısızlığı sistemi hazırlık veya başlatma durumuna geri döndürebilir.)*

---

# 14. READY_TO_START State (READY_TO_START Durumu)

READY_TO_START indicates that the selected experiment profile is prepared for navigation. *(READY_TO_START, seçilen deney profilinin navigasyon için hazır olduğunu gösterir.)*

The initial anchor and configuration snapshot must be fixed before leaving this state. *(Bu durumdan çıkmadan önce başlangıç çapası ve yapılandırma anlık görüntüsü sabitlenmelidir.)*

The application may wait for an explicit user command before the formal session begins. *(Uygulama resmî oturum başlamadan önce açık bir kullanıcı komutunu bekleyebilir.)*

---

# 15. GNSS_NAVIGATION State (GNSS_NAVIGATION Durumu)

GNSS_NAVIGATION represents normal navigation in which accepted GNSS measurements are permitted to update the estimator. *(GNSS_NAVIGATION, kabul edilen GNSS ölçümlerinin tahmin motorunu güncellemesine izin verilen normal navigasyonu temsil eder.)*

Local sensor processing may continue while GNSS is active. *(GNSS aktifken yerel sensör işleme devam edebilir.)*

This state may be used before a denial test or after GNSS recovery. *(Bu durum bir kesinti testinden önce veya GNSS geri kazanımından sonra kullanılabilir.)*

---

# 16. EVALUATION_ARMED State (EVALUATION_ARMED Durumu)

EVALUATION_ARMED indicates that NAVGUARD is ready to begin a controlled GNSS-denied evaluation. *(EVALUATION_ARMED, NAVGUARD’ın kontrollü bir GNSS kesintili değerlendirmeye başlamaya hazır olduğunu gösterir.)*

GNSS is still available before the denial transition. *(Kesinti geçişinden önce GNSS hâlâ kullanılabilir durumdadır.)*

The ground-truth logging channel must already be operational before the estimator GNSS channel is disabled. *(Tahmin motoru GNSS kanalı devre dışı bırakılmadan önce gerçek referans kayıt kanalı zaten çalışır durumda olmalıdır.)*

---

# 17. GNSS_DENIAL_TRANSITION State (GNSS_DENIAL_TRANSITION Durumu)

GNSS_DENIAL_TRANSITION is a short controlled transition state between GNSS-enabled and GNSS-denied estimation. *(GNSS_DENIAL_TRANSITION, GNSS etkin tahmin ile GNSS kesintili tahmin arasındaki kısa kontrollü geçiş durumudur.)*

The transition must record the exact denial timestamp. *(Geçiş kesin kesinti zaman damgasını kaydetmelidir.)*

The last accepted GNSS position must be frozen as the global anchor when required by the navigation configuration. *(Navigasyon yapılandırması gerektirdiğinde son kabul edilen GNSS konumu global çapa olarak sabitlenmelidir.)*

The estimator GNSS channel must be disabled before the system enters active local navigation. *(Sistem aktif yerel navigasyona girmeden önce tahmin motoru GNSS kanalı devre dışı bırakılmalıdır.)*

The independent GNSS ground-truth logger must remain active. *(Bağımsız GNSS gerçek referans logger’ı aktif kalmalıdır.)*

---

# 18. GNSS Denial Invariant (GNSS Kesintisi Değişmez Kuralı)

While GNSS denial is active, no GNSS position measurement may update the alternative navigation estimator. *(GNSS kesintisi aktifken hiçbir GNSS konum ölçümü alternatif navigasyon tahmin motorunu güncelleyemez.)*

This rule is an invariant and must remain true regardless of UI state, application screen, or optional subsystem behavior. *(Bu kural bir değişmezdir ve UI durumu, uygulama ekranı veya isteğe bağlı alt sistem davranışından bağımsız olarak doğru kalmalıdır.)*

Violation of this rule invalidates the corresponding evaluation session. *(Bu kuralın ihlali ilgili değerlendirme oturumunu geçersiz kılar.)*

---

# 19. ACTIVE_LOCAL_NAVIGATION State (ACTIVE_LOCAL_NAVIGATION Durumu)

ACTIVE_LOCAL_NAVIGATION represents the primary NAVGUARD operating condition during a simulated GNSS outage. *(ACTIVE_LOCAL_NAVIGATION simüle edilmiş GNSS kesintisi sırasında temel NAVGUARD çalışma koşulunu temsil eder.)*

The estimator will use only navigation sources permitted by the selected GNSS-denied profile. *(Tahmin motoru yalnızca seçilen GNSS kesintili profil tarafından izin verilen navigasyon kaynaklarını kullanacaktır.)*

These sources may include PDR, fused heading, motion AI, ARCore, sensor-quality information, and EKF state propagation. *(Bu kaynaklar PDR, füzyonlu yön, hareket yapay zekâsı, ARCore, sensör kalite bilgisi ve EKF durum ilerletmesini içerebilir.)*

GNSS ground truth may continue to be recorded independently. *(GNSS gerçek referansı bağımsız olarak kaydedilmeye devam edebilir.)*

---

# 20. ACTIVE_LOCAL_NAVIGATION Entry Conditions (ACTIVE_LOCAL_NAVIGATION Giriş Koşulları)

The initial global anchor must be valid. *(Başlangıç global çapası geçerli olmalıdır.)*

The required local navigation sources must be operational. *(Gerekli yerel navigasyon kaynakları çalışır durumda olmalıdır.)*

The GNSS estimator channel must be confirmed as blocked. *(Tahmin motoru GNSS kanalının engellendiği doğrulanmalıdır.)*

The session logger must be active. *(Oturum logger’ı aktif olmalıdır.)*

The active navigation profile must already be frozen. *(Aktif navigasyon profili önceden sabitlenmiş olmalıdır.)*

---

# 21. DEGRADED_LOCAL_NAVIGATION State (DEGRADED_LOCAL_NAVIGATION Durumu)

DEGRADED_LOCAL_NAVIGATION represents continued GNSS-denied navigation after one or more optional information sources become unreliable or unavailable. *(DEGRADED_LOCAL_NAVIGATION, bir veya daha fazla isteğe bağlı bilgi kaynağının güvenilmez veya kullanılamaz hale gelmesinden sonra devam eden GNSS kesintili navigasyonu temsil eder.)*

The estimator continues operating with a reduced source set. *(Tahmin motoru azaltılmış bir kaynak setiyle çalışmaya devam eder.)*

The application must indicate that navigation quality has degraded. *(Uygulama navigasyon kalitesinin bozulduğunu göstermelidir.)*

Position confidence or uncertainty must be adjusted accordingly where the uncertainty subsystem is active. *(Belirsizlik alt sistemi aktif olduğunda konum güveni veya belirsizlik buna göre ayarlanmalıdır.)*

---

# 22. Examples of Degraded Navigation (Bozulmuş Navigasyon Örnekleri)

ARCore tracking may become unavailable while PDR remains operational. *(PDR çalışır durumda kalırken ARCore takibi kullanılamaz hale gelebilir.)*

Magnetometer quality may degrade while short-term gyroscope heading remains usable. *(Kısa süreli jiroskop yönü kullanılabilir kalırken manyetometre kalitesi bozulabilir.)*

Motion AI may become unavailable while deterministic step processing remains operational. *(Deterministik adım işleme çalışır durumda kalırken hareket yapay zekâsı kullanılamaz hale gelebilir.)*

A temporary sensor-timing warning may reduce confidence without immediately stopping the experiment. *(Geçici bir sensör zamanlama uyarısı deneyi hemen durdurmadan güveni azaltabilir.)*

---

# 23. Degraded Navigation Fallback Order (Bozulmuş Navigasyon Geri Dönüş Sırası)

`text id="e1t6ay" Full NAVGUARD Fusion         ↓ PDR + Heading + AI         ↓ PDR + Heading         ↓ Baseline PDR         ↓ SESSION_INVALID / CONTROLLED STOP`

The exact fallback step depends on which subsystem failed. *(Kesin geri dönüş adımı hangi alt sistemin başarısız olduğuna bağlıdır.)*

---

# 24. Mandatory Versus Optional Failure (Zorunlu ve İsteğe Bağlı Hata Ayrımı)

Failure of an optional navigation source should normally lead to degradation rather than session termination. *(İsteğe bağlı bir navigasyon kaynağının başarısızlığı normalde oturum sonlandırma yerine bozulmaya yol açmalıdır.)*

Failure of a mandatory source may invalidate the formal experiment. *(Zorunlu bir kaynağın başarısızlığı resmî deneyi geçersiz kılabilir.)*

The definition of mandatory sources depends on the active experiment profile. *(Zorunlu kaynakların tanımı aktif deney profiline bağlıdır.)*

For example, ARCore is mandatory for Configuration C but not for Configuration A. *(Örneğin ARCore Yapılandırma C için zorunludur ancak Yapılandırma A için zorunlu değildir.)*

---

# 25. GNSS Recovery Philosophy (GNSS Geri Kazanım Yaklaşımı)

GNSS recovery must be treated separately from GNSS ground-truth availability. *(GNSS geri kazanımı GNSS gerçek referans kullanılabilirliğinden ayrı ele alınmalıdır.)*

In Evaluation Mode, GNSS may have remained physically available during the entire denied period. *(Değerlendirme Modunda GNSS tüm kesinti süresi boyunca fiziksel olarak kullanılabilir kalmış olabilir.)*

Recovery therefore refers to restoring estimator authorization to use GNSS, not necessarily to the receiver physically reacquiring satellites. *(Bu nedenle geri kazanım, alıcının fiziksel olarak uyduları yeniden edinmesinden ziyade tahmin motorunun GNSS kullanma yetkisinin geri verilmesini ifade eder.)*

---

# 26. GNSS_RECOVERY_PENDING State (GNSS_RECOVERY_PENDING Durumu)

GNSS_RECOVERY_PENDING begins when the experiment or navigation logic requests a return to GNSS-enabled estimation. *(GNSS_RECOVERY_PENDING, deney veya navigasyon mantığı GNSS etkin tahmine geri dönüş istediğinde başlar.)*

The estimator must not immediately accept the first available GNSS point without quality validation. *(Tahmin motoru ilk kullanılabilir GNSS noktasını kalite doğrulaması olmadan hemen kabul etmemelidir.)*

GNSS quality must be checked against the active acceptance rules. *(GNSS kalitesi aktif kabul kurallarına göre kontrol edilmelidir.)*

---

# 27. GNSS Recovery Guard (GNSS Geri Kazanım Koruma Koşulu)

The system may leave GNSS_RECOVERY_PENDING only when a GNSS measurement satisfies the configured recovery conditions. *(Sistem GNSS_RECOVERY_PENDING durumundan yalnızca bir GNSS ölçümü yapılandırılmış geri kazanım koşullarını karşıladığında çıkabilir.)*

The final recovery threshold will remain configurable until field testing provides empirical evidence. *(Nihai geri kazanım eşiği saha testleri ampirik kanıt sağlayana kadar yapılandırılabilir kalacaktır.)*

Repeated consistent GNSS measurements may be preferred over a single measurement if experiments show that this improves recovery stability. *(Deneyler bunun geri kazanım kararlılığını artırdığını gösterirse tek bir ölçüm yerine tekrarlanan tutarlı GNSS ölçümleri tercih edilebilir.)*

---

# 28. GNSS_RECOVERED State (GNSS_RECOVERED Durumu)

GNSS_RECOVERED indicates that a valid GNSS position is available and accepted for comparison with the current NAVGUARD estimate. *(GNSS_RECOVERED, geçerli bir GNSS konumunun mevcut olduğunu ve mevcut NAVGUARD tahminiyle karşılaştırma için kabul edildiğini gösterir.)*

The application must calculate and store the current position difference before any estimator state correction occurs. *(Uygulama herhangi bir tahmin motoru durum düzeltmesi gerçekleşmeden önce mevcut konum farkını hesaplamalı ve saklamalıdır.)*

This difference is an important experimental output. *(Bu fark önemli bir deneysel çıktıdır.)*

---

# 29. Recovery Error Calculation (Geri Kazanım Hata Hesabı)

The recovered GNSS coordinate will be compared with the estimated NAVGUARD coordinate at an appropriately aligned time. *(Geri kazanılan GNSS koordinatı uygun şekilde hizalanmış bir zamanda tahmini NAVGUARD koordinatıyla karşılaştırılacaktır.)*

The resulting position difference will contribute to final position error and recovery analysis. *(Ortaya çıkan konum farkı nihai konum hatası ve geri kazanım analizine katkı sağlayacaktır.)*

Relocalization must not occur before this pre-correction error has been recorded. *(Bu düzeltme öncesi hata kaydedilmeden yeniden konumlandırma gerçekleşmemelidir.)*

---

# 30. RELOCALIZING State (RELOCALIZING Durumu)

RELOCALIZING updates the active navigation reference after acceptable GNSS information becomes available again. *(RELOCALIZING, kabul edilebilir GNSS bilgisi tekrar kullanılabilir hale geldikten sonra aktif navigasyon referansını günceller.)*

The target implementation should avoid an unexplained visual teleport when a smoother correction strategy can be implemented safely. *(Hedef uygulama, daha yumuşak bir düzeltme stratejisi güvenli şekilde uygulanabiliyorsa açıklamasız görsel teleport davranışından kaçınmalıdır.)*

The historical estimated trajectory must remain unchanged. *(Geçmiş tahmini rota değişmeden kalmalıdır.)*

Relocalization applies only to the current and future estimator state. *(Yeniden konumlandırma yalnızca mevcut ve gelecekteki tahmin motoru durumuna uygulanır.)*

---

# 31. Relocalization Strategies (Yeniden Konumlandırma Stratejileri)

The first implementation may use direct re-anchoring if a more advanced strategy is not yet stable. *(Daha gelişmiş bir strateji henüz kararlı değilse ilk uygulama doğrudan yeniden çapa oluşturmayı kullanabilir.)*

A later implementation may use gradual correction over several updates. *(Daha sonraki bir uygulama birkaç güncelleme boyunca kademeli düzeltme kullanabilir.)*

An EKF implementation may perform a GNSS measurement update when the filter is allowed to consume GNSS again. *(Bir EKF uygulaması filtreye tekrar GNSS kullanma izni verildiğinde GNSS ölçüm güncellemesi gerçekleştirebilir.)*

The final strategy will be defined in **29 — GNSS Recovery & Relocalization**. *(Nihai strateji **29 — GNSS Recovery & Relocalization** bölümünde tanımlanacaktır.)*

---

# 32. Return to GNSS_NAVIGATION (GNSS_NAVIGATION Durumuna Dönüş)

The system may return to GNSS_NAVIGATION after successful relocalization. *(Sistem başarılı yeniden konumlandırmadan sonra GNSS_NAVIGATION durumuna dönebilir.)*

The estimator GNSS channel becomes authorized only after the recovery process formally completes. *(Tahmin motoru GNSS kanalı yalnızca geri kazanım işlemi resmî olarak tamamlandıktan sonra yetkilendirilir.)*

The transition must be recorded with a timestamp. *(Geçiş zaman damgasıyla kaydedilmelidir.)*

---

# 33. SESSION_STOPPING State (SESSION_STOPPING Durumu)

SESSION_STOPPING performs controlled shutdown of an active experiment. *(SESSION_STOPPING aktif bir deneyin kontrollü kapanışını gerçekleştirir.)*

New navigation updates will stop being accepted into the completed session state. *(Yeni navigasyon güncellemelerinin tamamlanan oturum durumuna kabul edilmesi durdurulacaktır.)*

Pending log buffers will be flushed. *(Bekleyen kayıt tamponları diske yazılacaktır.)*

Active native resources will be released. *(Aktif native kaynaklar serbest bırakılacaktır.)*

The session manifest will then be finalized. *(Daha sonra oturum manifest’i sonlandırılacaktır.)*

---

# 34. SESSION_COMPLETED State (SESSION_COMPLETED Durumu)

SESSION_COMPLETED indicates that the session ended normally and required finalization operations succeeded. *(SESSION_COMPLETED oturumun normal şekilde sona erdiğini ve gerekli sonlandırma işlemlerinin başarılı olduğunu gösterir.)*

A completion marker will be stored in the session manifest. *(Oturum manifest’inde bir tamamlanma işareti saklanacaktır.)*

Completed does not automatically mean scientifically valid. *(Tamamlanmış olması otomatik olarak bilimsel olarak geçerli olduğu anlamına gelmez.)*

Scientific validity will also depend on required data integrity and experiment conditions. *(Bilimsel geçerlilik ayrıca gerekli veri bütünlüğüne ve deney koşullarına bağlı olacaktır.)*

---

# 35. SESSION_INVALID State (SESSION_INVALID Durumu)

SESSION_INVALID represents a session that physically occurred but cannot be used as a valid formal benchmark. *(SESSION_INVALID fiziksel olarak gerçekleşmiş ancak geçerli bir resmî benchmark olarak kullanılamayan bir oturumu temsil eder.)*

The session data should normally be preserved for debugging and analysis. *(Oturum verisi normalde hata ayıklama ve analiz için korunmalıdır.)*

The invalidation reason must be recorded explicitly. *(Geçersiz kılma nedeni açıkça kaydedilmelidir.)*

A session must not be deleted solely because its navigation performance is poor. *(Bir oturum yalnızca navigasyon performansı düşük olduğu için silinmemelidir.)*

---

# 36. Example Session Invalidation Conditions (Örnek Oturum Geçersiz Kılma Koşulları)

Ground-truth GNSS data entering the GNSS-denied estimator invalidates the experiment. *(Gerçek referans GNSS verisinin GNSS kesintili tahmin motoruna girmesi deneyi geçersiz kılar.)*

Loss of mandatory sensor logging for an unacceptable period may invalidate the experiment. *(Zorunlu sensör kaydının kabul edilemez bir süre boyunca kaybedilmesi deneyi geçersiz kılabilir.)*

Corrupted session timestamps may invalidate the experiment. *(Bozulmuş oturum zaman damgaları deneyi geçersiz kılabilir.)*

Changing a frozen benchmark configuration without recording the change may invalidate the experiment. *(Sabitlenmiş benchmark yapılandırmasının değişiklik kaydedilmeden değiştirilmesi deneyi geçersiz kılabilir.)*

---

# 37. ERROR State (ERROR Durumu)

ERROR represents a runtime failure that prevents the current state machine path from continuing normally. *(ERROR mevcut durum makinesi yolunun normal şekilde devam etmesini engelleyen çalışma zamanı hatasını temsil eder.)*

An ERROR does not automatically require an application crash. *(Bir ERROR otomatik olarak uygulama çökmesi gerektirmez.)*

The system should attempt controlled cleanup where possible. *(Sistem mümkün olduğunda kontrollü temizlik yapmaya çalışmalıdır.)*

A recoverable error may return the application to IDLE or READINESS_CHECK. *(Kurtarılabilir bir hata uygulamayı IDLE veya READINESS_CHECK durumuna döndürebilir.)*

---

# 38. State Transition Event Model (Durum Geçiş Olay Modeli)

Every important state transition will produce a structured event. *(Her önemli durum geçişi yapılandırılmış bir olay üretecektir.)*

A logical state event may contain the following information. *(Mantıksal bir durum olayı aşağıdaki bilgileri içerebilir.)*

`text id="9m4sz8" NavigationStateEvent - timestamp - previousState - newState - navigationMode - trigger - reason - sessionId`

The final implementation may include additional diagnostic fields. *(Nihai uygulama ek tanısal alanlar içerebilir.)*

---

# 39. Transition Trigger Types (Geçiş Tetikleyici Türleri)

State transitions may be triggered by explicit user action. *(Durum geçişleri açık kullanıcı işlemiyle tetiklenebilir.)*

State transitions may be triggered by sensor or subsystem readiness changes. *(Durum geçişleri sensör veya alt sistem hazırlık değişiklikleriyle tetiklenebilir.)*

State transitions may be triggered by GNSS availability or quality changes. *(Durum geçişleri GNSS kullanılabilirliği veya kalite değişiklikleriyle tetiklenebilir.)*

State transitions may be triggered by experiment-controller logic. *(Durum geçişleri deney controller mantığıyla tetiklenebilir.)*

State transitions may be triggered by critical runtime failures. *(Durum geçişleri kritik çalışma zamanı hatalarıyla tetiklenebilir.)*

---

# 40. Transition Guard Principle (Geçiş Koruma Koşulu İlkesi)

A requested transition does not automatically have to be accepted. *(İstenen bir geçişin otomatik olarak kabul edilmesi gerekmez.)*

Every critical transition may have guard conditions. *(Her kritik geçiş koruma koşullarına sahip olabilir.)*

A guard must be evaluated before the state change occurs. *(Durum değişikliği gerçekleşmeden önce koruma koşulu değerlendirilmelidir.)*

A failed guard must leave the system in a safe and known state. *(Başarısız bir koruma koşulu sistemi güvenli ve bilinen bir durumda bırakmalıdır.)*

---

# 41. GNSS-Denied Entry Guard (GNSS Kesintili Giriş Koruma Koşulu)

The system must not enter GNSS-Denied Mode without a valid initial anchor during a formal experiment. *(Sistem resmî bir deney sırasında geçerli bir başlangıç çapası olmadan GNSS Kesintili Moda girmemelidir.)*

The logger must be active. *(Logger aktif olmalıdır.)*

The selected local estimator configuration must be operational. *(Seçilen yerel tahmin motoru yapılandırması çalışır durumda olmalıdır.)*

The GNSS ground-truth channel must be separated from the estimator path. *(GNSS gerçek referans kanalı tahmin motoru hattından ayrılmış olmalıdır.)*

---

# 42. GNSS-Denied Exit Guard (GNSS Kesintili Çıkış Koruma Koşulu)

The system must not restore GNSS estimator access merely because a GNSS sample exists. *(Sistem yalnızca bir GNSS örneği mevcut olduğu için GNSS tahmin motoru erişimini geri getirmemelidir.)*

The configured recovery conditions must be satisfied. *(Yapılandırılmış geri kazanım koşulları karşılanmalıdır.)*

The pre-correction estimate-to-GNSS error must be recorded before relocalization. *(Yeniden konumlandırmadan önce düzeltme öncesi tahmin-GNSS hatası kaydedilmelidir.)*

---

# 43. Ground Truth Firewall State (Gerçek Referans Güvenlik Duvarı Durumu)

The Ground Truth Firewall will have an explicit estimator-authorization state. *(Gerçek Referans Güvenlik Duvarı açık bir tahmin motoru yetkilendirme durumuna sahip olacaktır.)*

A simple logical representation may use ALLOWED and BLOCKED states. *(Basit bir mantıksal temsil ALLOWED ve BLOCKED durumlarını kullanabilir.)*

```text id=“7b3nfk”
GNSS Mode
Estimator GNSS Access = ALLOWED

Evaluation Armed
Estimator GNSS Access = ALLOWED

GNSS-Denied Active
Estimator GNSS Access = BLOCKED

Recovery Pending
Estimator GNSS Access = BLOCKED

Relocalization
Estimator GNSS Access = CONTROLLED

GNSS Navigation Restored
Estimator GNSS Access = ALLOWED

```

The exact controlled behavior during relocalization will be defined in the relocalization design. *(Yeniden konumlandırma sırasındaki kesin kontrollü davranış yeniden konumlandırma tasarımında tanımlanacaktır.)*

---

# 44. Evaluation Mode Data Policy (Değerlendirme Modu Veri Politikası)

Evaluation Mode will preserve GNSS ground-truth measurements for later comparison. *(Değerlendirme Modu daha sonraki karşılaştırma için GNSS gerçek referans ölçümlerini koruyacaktır.)*

The ground-truth stream must be tagged explicitly as evaluation-only data. *(Gerçek referans akışı açıkça yalnızca değerlendirme verisi olarak etiketlenmelidir.)*

Estimator input logs must make it possible to verify that no GNSS update was consumed during the denied phase. *(Tahmin motoru girdi kayıtları kesinti aşamasında hiçbir GNSS güncellemesinin kullanılmadığının doğrulanmasını mümkün kılmalıdır.)*

---

# 45. Evaluation Mode Versus Physical GNSS Loss (Değerlendirme Modu ile Fiziksel GNSS Kaybı Ayrımı)

NAVGUARD's primary controlled experiments will simulate GNSS denial in software rather than physically disrupt GNSS radio signals. *(NAVGUARD'ın temel kontrollü deneyleri GNSS radyo sinyallerini fiziksel olarak bozmak yerine GNSS kesintisini yazılımda simüle edecektir.)*

The physical receiver may continue receiving GNSS during Evaluation Mode. *(Fiziksel alıcı Değerlendirme Modunda GNSS almaya devam edebilir.)*

The estimator will behave as though GNSS were unavailable because the authorization gate blocks the measurement. *(Tahmin motoru yetkilendirme kapısı ölçümü engellediği için GNSS kullanılamıyormuş gibi davranacaktır.)*

This produces a safe and measurable experimental design. *(Bu, güvenli ve ölçülebilir bir deney tasarımı üretir.)*

---

# 46. Navigation Mode Indicator Requirements (Navigasyon Modu Gösterge Gereksinimleri)

The active navigation mode must be clearly visible during a formal session. *(Aktif navigasyon modu resmî bir oturum sırasında açıkça görünür olmalıdır.)*

The interface must distinguish GNSS-enabled navigation from GNSS-denied navigation. *(Arayüz GNSS etkin navigasyonu GNSS kesintili navigasyondan ayırmalıdır.)*

Evaluation Mode must clearly indicate that GNSS may be recorded as ground truth while not being used by the estimator. *(Değerlendirme Modu GNSS'in gerçek referans olarak kaydedilebileceğini ancak tahmin motoru tarafından kullanılmadığını açıkça göstermelidir.)*

---

# 47. Proposed User-Visible Mode Labels (Önerilen Kullanıcıya Görünen Mod Etiketleri)

### GNSS ACTIVE (GNSS AKTİF)

GNSS measurements are currently permitted to influence navigation. *(GNSS ölçümlerinin şu anda navigasyonu etkilemesine izin verilmektedir.)*

### EVALUATION READY (DEĞERLENDİRME HAZIR)

Ground truth is being prepared and GNSS-denied evaluation is ready to begin. *(Gerçek referans hazırlanıyor ve GNSS kesintili değerlendirme başlamaya hazırdır.)*

### NAVGUARD ACTIVE — GNSS DENIED (NAVGUARD AKTİF — GNSS KESİNTİLİ)

The estimator is operating without GNSS position updates. *(Tahmin motoru GNSS konum güncellemeleri olmadan çalışmaktadır.)*

### NAVGUARD DEGRADED (NAVGUARD BOZULMUŞ)

The estimator is operating with reduced sensor or tracking capability. *(Tahmin motoru azaltılmış sensör veya takip yeteneğiyle çalışmaktadır.)*

### GNSS RECOVERY (GNSS GERİ KAZANIMI)

GNSS is being validated before estimator access is restored. *(Tahmin motoru erişimi geri verilmeden önce GNSS doğrulanmaktadır.)*

---

# 48. Automatic GNSS Loss Detection Policy (Otomatik GNSS Kaybı Tespit Politikası)

Automatic detection of naturally degraded GNSS may be implemented as a target or future capability. *(Doğal olarak bozulmuş GNSS'in otomatik tespiti hedef veya gelecek yetenek olarak geliştirilebilir.)*

It is not required for the minimum controlled evaluation workflow. *(Minimum kontrollü değerlendirme iş akışı için gerekli değildir.)*

The first formal experiments will use an explicit software-triggered denial transition. *(İlk resmî deneyler açık yazılım tetiklemeli kesinti geçişi kullanacaktır.)*

This simplifies reproducibility and provides a known denial start timestamp. *(Bu tekrarlanabilirliği basitleştirir ve bilinen bir kesinti başlangıç zaman damgası sağlar.)*

---

# 49. Manual Denial Trigger (Manuel Kesinti Tetikleyicisi)

The research interface will provide an explicit action to begin simulated GNSS denial. *(Araştırma arayüzü simüle edilmiş GNSS kesintisini başlatmak için açık bir işlem sağlayacaktır.)*

The action must not disable Android's GNSS hardware or interfere with radio signals. *(İşlem Android'in GNSS donanımını devre dışı bırakmamalı veya radyo sinyallerine müdahale etmemelidir.)*

It will only change estimator authorization within NAVGUARD. *(Yalnızca NAVGUARD içerisindeki tahmin motoru yetkilendirmesini değiştirecektir.)*

---

# 50. Denial Duration Tracking (Kesinti Süresi Takibi)

NAVGUARD will record the elapsed time since the GNSS-denied transition. *(NAVGUARD GNSS kesintili geçişten itibaren geçen süreyi kaydedecektir.)*

This value may be shown in the user interface. *(Bu değer kullanıcı arayüzünde gösterilebilir.)*

The value will also support drift-per-time analysis and uncertainty logic. *(Değer ayrıca zaman başına sürüklenme analizini ve belirsizlik mantığını destekleyecektir.)*

---

# 51. Distance Since GNSS Loss (GNSS Kaybından Sonraki Mesafe)

NAVGUARD should maintain the estimated distance travelled since GNSS denial began. *(NAVGUARD GNSS kesintisi başladıktan sonra tahmini kat edilen mesafeyi tutmalıdır.)*

This value is useful for distance-normalized drift analysis. *(Bu değer mesafeye normalize edilmiş sürüklenme analizi için kullanışlıdır.)*

It may also contribute to uncertainty estimation. *(Belirsizlik tahminine de katkıda bulunabilir.)*

---

# 52. Stationary Behavior During GNSS Denial (GNSS Kesintisi Sırasında Sabit Durum Davranışı)

The state machine will not automatically exit GNSS-Denied Mode when the user stops moving. *(Kullanıcı hareket etmeyi bıraktığında durum makinesi GNSS Kesintili Moddan otomatik olarak çıkmayacaktır.)*

The motion classifier or deterministic stationary detector may suppress displacement updates. *(Hareket sınıflandırıcı veya deterministik sabit durum algılayıcı yer değiştirme güncellemelerini bastırabilir.)*

The denied-mode timer will continue because GNSS remains denied even while stationary. *(Kullanıcı sabit durumda olsa bile GNSS kesintisi devam ettiği için kesinti modu zamanlayıcısı devam edecektir.)*

---

# 53. Running Behavior During GNSS Denial (GNSS Kesintisi Sırasında Koşma Davranışı)

Running does not create a new top-level navigation mode. *(Koşma yeni bir üst seviye navigasyon modu oluşturmaz.)*

Running is a motion context inside the current navigation state. *(Koşma mevcut navigasyon durumu içerisinde bir hareket bağlamıdır.)*

The motion state may change step-length behavior, detection parameters, or estimator confidence. *(Hareket durumu adım uzunluğu davranışını, tespit parametrelerini veya tahmin motoru güvenini değiştirebilir.)*

---

# 54. Turning Behavior During GNSS Denial (GNSS Kesintisi Sırasında Dönüş Davranışı)

Turning is treated as motion context rather than a top-level navigation mode. *(Dönüş üst seviye navigasyon modu yerine hareket bağlamı olarak ele alınır.)*

Heading and gyroscope processing may receive increased importance during turn events. *(Dönüş olayları sırasında yön ve jiroskop işleme daha fazla önem kazanabilir.)*

The state machine remains in ACTIVE_LOCAL_NAVIGATION unless sensor quality causes a degradation transition. *(Sensör kalitesi bir bozulma geçişine neden olmadıkça durum makinesi ACTIVE_LOCAL_NAVIGATION durumunda kalır.)*

---

# 55. ARCore Tracking State Interaction (ARCore Takip Durumu Etkileşimi)

ARCore tracking state is a subsystem state rather than a primary navigation mode. *(ARCore takip durumu temel navigasyon modu yerine bir alt sistem durumudur.)*

When ARCore transitions from TRACKING to an unusable state, the navigation state machine may transition from ACTIVE_LOCAL_NAVIGATION to DEGRADED_LOCAL_NAVIGATION if the active profile depends on ARCore. *(ARCore TRACKING durumundan kullanılamaz bir duruma geçtiğinde aktif profil ARCore'a bağlıysa navigasyon durum makinesi ACTIVE_LOCAL_NAVIGATION durumundan DEGRADED_LOCAL_NAVIGATION durumuna geçebilir.)*

PDR must continue where technically possible. *(PDR teknik olarak mümkün olduğunda devam etmelidir.)*

---

# 56. AI Runtime State Interaction (Yapay Zekâ Çalışma Zamanı Durum Etkileşimi)

Motion AI state will remain separate from the primary navigation-state enum. *(Hareket yapay zekâsı durumu temel navigasyon durumu enum'undan ayrı kalacaktır.)*

An AI failure may cause degradation if the active profile requires AI output. *(Aktif profil yapay zekâ çıktısı gerektiriyorsa bir yapay zekâ hatası bozulmaya neden olabilir.)*

A deterministic fallback may allow continued local navigation. *(Deterministik bir geri dönüş yerel navigasyonun devam etmesine izin verebilir.)*

---

# 57. Sensor Quality State Interaction (Sensör Kalite Durumu Etkileşimi)

Sensor quality information may change estimator weighting without changing the top-level navigation state. *(Sensör kalite bilgisi üst seviye navigasyon durumunu değiştirmeden tahmin motoru ağırlıklandırmasını değiştirebilir.)*

A severe or persistent degradation may trigger DEGRADED_LOCAL_NAVIGATION. *(Ciddi veya kalıcı bozulma DEGRADED_LOCAL_NAVIGATION durumunu tetikleyebilir.)*

A critical mandatory sensor loss may trigger SESSION_INVALID or ERROR. *(Kritik zorunlu sensör kaybı SESSION_INVALID veya ERROR durumunu tetikleyebilir.)*

---

# 58. State and Mode Separation Example (Durum ve Mod Ayrımı Örneği)

```text id="4pb2s9"
Navigation Mode:
NAVGUARD_MODE

Runtime State:
ACTIVE_LOCAL_NAVIGATION

Motion State:
WALKING

ARCore State:
TRACKING

AI State:
READY

Sensor Health:
NORMAL
```

These states coexist and describe different aspects of the same runtime condition. *(Bu durumlar birlikte bulunur ve aynı çalışma koşulunun farklı yönlerini tanımlar.)*

---

# 59. Degraded State Example (Bozulmuş Durum Örneği)

```text id=“8lrf7z”
Navigation Mode:
NAVGUARD_MODE

Runtime State:
DEGRADED_LOCAL_NAVIGATION

Motion State:
WALKING

ARCore State:
PAUSED

AI State:
READY

Sensor Health:
WARNING

Fallback:
PDR + Heading + AI

```

This structure provides clearer diagnostics than one global status value. *(Bu yapı tek bir global durum değerine göre daha açık tanı sağlar.)*

---

# 60. Formal Session Validity State (Resmî Oturum Geçerlilik Durumu)

Session validity will be maintained independently from navigation mode. *(Oturum geçerliliği navigasyon modundan bağımsız olarak tutulacaktır.)*

A logical session-validity state may include VALID, DEGRADED_BUT_VALID, INVALID, and UNKNOWN. *(Mantıksal bir oturum geçerlilik durumu VALID, DEGRADED_BUT_VALID, INVALID ve UNKNOWN değerlerini içerebilir.)*

The final validity decision may be made during or after session finalization. *(Nihai geçerlilik kararı oturum sırasında veya sonlandırmadan sonra verilebilir.)*

---

# 61. Session Validity Rule (Oturum Geçerlilik Kuralı)

A poor position estimate does not make a session invalid. *(Kötü bir konum tahmini bir oturumu geçersiz yapmaz.)*

Scientific validity depends on whether the defined experiment protocol was followed and required evidence was recorded. *(Bilimsel geçerlilik tanımlanan deney protokolünün izlenip izlenmediğine ve gerekli kanıtın kaydedilip kaydedilmediğine bağlıdır.)*

This distinction prevents biased removal of poor-performing experiments. *(Bu ayrım düşük performanslı deneylerin yanlı şekilde çıkarılmasını önler.)*

---

# 62. User Stop Event (Kullanıcı Durdurma Olayı)

The user may explicitly stop an active session. *(Kullanıcı aktif bir oturumu açıkça durdurabilir.)*

A user stop will normally trigger SESSION_STOPPING. *(Kullanıcı durdurması normalde SESSION_STOPPING durumunu tetikleyecektir.)*

The reason will be recorded as USER_REQUEST. *(Neden USER_REQUEST olarak kaydedilecektir.)*

The session may remain scientifically valid if the protocol allows the observed duration. *(Protokol gözlemlenen süreye izin veriyorsa oturum bilimsel olarak geçerli kalabilir.)*

---

# 63. Emergency Controlled Stop (Acil Kontrollü Durdurma)

The application may require immediate controlled termination if a critical experiment dependency fails. *(Kritik bir deney bağımlılığı başarısız olursa uygulama hemen kontrollü sonlandırma gerektirebilir.)*

The system should preserve all safely available logged evidence before shutdown. *(Sistem kapanmadan önce güvenli şekilde mevcut tüm kayıtlı kanıtı korumalıdır.)*

The session must be marked with the reason for termination. *(Oturum sonlandırma nedeni ile işaretlenmelidir.)*

---

# 64. Application Pause Policy (Uygulama Duraklatma Politikası)

Formal experiments are designed for foreground operation. *(Resmî deneyler ön plan çalışması için tasarlanmıştır.)*

If application lifecycle changes make reliable acquisition uncertain, the event must be recorded. *(Uygulama yaşam döngüsü değişiklikleri güvenilir veri toplamayı belirsiz hale getirirse olay kaydedilmelidir.)*

Depending on measured device behavior, prolonged background transition may invalidate a formal benchmark session. *(Ölçülen cihaz davranışına bağlı olarak uzun süreli arka plan geçişi resmî bir benchmark oturumunu geçersiz kılabilir.)*

---

# 65. Screen Rotation Policy (Ekran Döndürme Politikası)

The application interface should initially use a controlled orientation during formal experiments if screen rotation creates lifecycle complexity. *(Ekran döndürme yaşam döngüsü karmaşıklığı oluşturursa uygulama arayüzü resmî deneyler sırasında başlangıçta kontrollü bir yönelim kullanmalıdır.)*

The preferred mobile orientation will be finalized in the UI/UX specification. *(Tercih edilen mobil yönelim UI/UX şartnamesinde kesinleştirilecektir.)*

The estimator itself must not use screen orientation as a substitute for physical device orientation. *(Tahmin motoru ekran yönelimini fiziksel cihaz yöneliminin yerine kullanmamalıdır.)*

---

# 66. State Persistence Policy (Durum Kalıcılığı Politikası)

Critical session metadata must be persisted independently from transient Flutter widget state. *(Kritik oturum metadata bilgisi geçici Flutter widget durumundan bağımsız olarak kalıcı hale getirilmelidir.)*

The active session identifier and completion state should survive ordinary UI rebuilds. *(Aktif oturum tanımlayıcısı ve tamamlanma durumu normal UI rebuild işlemlerinden etkilenmemelidir.)*

Full estimator crash recovery is not required for the first prototype. *(İlk prototip için tam tahmin motoru çökme kurtarması gerekli değildir.)*

---

# 67. State Machine Ownership (Durum Makinesi Sahipliği)

One application-level Navigation Mode Manager or equivalent component will own top-level navigation transitions. *(Bir uygulama seviyesi Navigasyon Mod Yöneticisi veya eşdeğer bileşen üst seviye navigasyon geçişlerinin sahibi olacaktır.)*

Individual screens must not change navigation mode independently. *(Bireysel ekranlar navigasyon modunu bağımsız olarak değiştirmemelidir.)*

Native sensor modules will report subsystem state but will not directly decide the global navigation mode. *(Native sensör modülleri alt sistem durumunu raporlayacak ancak global navigasyon moduna doğrudan karar vermeyecektir.)*

---

# 68. State Machine Command Interface (Durum Makinesi Komut Arayüzü)

The application layer may expose controlled commands such as the following. *(Uygulama katmanı aşağıdaki gibi kontrollü komutlar sunabilir.)*

```text id="f7i4oj"
checkReadiness()
initializeSession()
beginGnssNavigation()
armEvaluation()
activateGnssDeniedMode()
requestGnssRecovery()
stopSession()
abortSession()
```

The exact names may change during implementation. *(Kesin adlar geliştirme sırasında değişebilir.)*

---

# 69. Invalid Transition Handling (Geçersiz Geçiş Yönetimi)

An invalid state transition must be rejected explicitly. *(Geçersiz bir durum geçişi açıkça reddedilmelidir.)*

For example, the system must not allow `IDLE → ACTIVE_LOCAL_NAVIGATION` during a formal evaluation because initialization and anchoring would be skipped. *(Örneğin sistem resmî değerlendirme sırasında başlatma ve çapa oluşturma atlanacağı için `IDLE → ACTIVE_LOCAL_NAVIGATION` geçişine izin vermemelidir.)*

Invalid transition attempts should generate diagnostic events. *(Geçersiz geçiş girişimleri tanısal olaylar üretmelidir.)*

---

# 70. Critical State Invariants (Kritik Durum Değişmezleri)

During ACTIVE_LOCAL_NAVIGATION, estimator GNSS access must remain blocked. *(ACTIVE_LOCAL_NAVIGATION sırasında tahmin motoru GNSS erişimi engelli kalmalıdır.)*

During Evaluation Mode, GNSS ground-truth logging should remain enabled when GNSS data is available. *(Değerlendirme Modunda GNSS verisi mevcut olduğunda GNSS gerçek referans kaydı etkin kalmalıdır.)*

A formal session must have a unique session identifier before navigation logging begins. *(Resmî bir oturum navigasyon kaydı başlamadan önce benzersiz bir oturum tanımlayıcısına sahip olmalıdır.)*

A completed session must never return to an active navigation state. *(Tamamlanmış bir oturum hiçbir zaman aktif navigasyon durumuna geri dönmemelidir.)*

A session marked INVALID must not be silently changed to VALID without documented reevaluation. *(INVALID olarak işaretlenmiş bir oturum dokümante edilmiş yeniden değerlendirme olmadan sessizce VALID durumuna değiştirilmemelidir.)*

---

# 71. Configuration-Specific State Requirements (Yapılandırmaya Özgü Durum Gereksinimleri)

Configuration A requires baseline sensors and PDR readiness. *(Yapılandırma A temel sensörleri ve PDR hazırlığını gerektirir.)*

Configuration B additionally requires the selected heading-fusion source set. *(Yapılandırma B ayrıca seçilen yön füzyonu kaynak setini gerektirir.)*

Configuration C additionally requires usable ARCore tracking. *(Yapılandırma C ayrıca kullanılabilir ARCore takibini gerektirir.)*

Configuration D requires the final frozen fusion source set, including AI and other validated target components. *(Yapılandırma D, yapay zekâ ve diğer doğrulanmış hedef bileşenler dahil olmak üzere nihai sabitlenmiş füzyon kaynak setini gerektirir.)*

---

# 72. Configuration A Degradation Rule (Yapılandırma A Bozulma Kuralı)

Configuration A cannot fall back to a simpler formal navigation configuration because it already represents the baseline PDR profile. *(Yapılandırma A zaten temel PDR profilini temsil ettiği için daha basit bir resmî navigasyon yapılandırmasına geri dönemez.)*

Loss of a required PDR source may therefore invalidate the session. *(Bu nedenle gerekli bir PDR kaynağının kaybı oturumu geçersiz kılabilir.)*

---

# 73. Configuration C ARCore Failure Rule (Yapılandırma C ARCore Hata Kuralı)

If ARCore becomes unavailable during a Configuration C benchmark, the application may continue using PDR for operational continuity. *(Bir Yapılandırma C benchmark’ı sırasında ARCore kullanılamaz hale gelirse uygulama operasyonel süreklilik için PDR kullanmaya devam edebilir.)*

However, the session may no longer be valid as a pure Configuration C benchmark for the affected period. *(Ancak oturum etkilenen dönem için saf bir Yapılandırma C benchmark’ı olarak artık geçerli olmayabilir.)*

The event and fallback interval must be recorded. *(Olay ve geri dönüş aralığı kaydedilmelidir.)*

---

# 74. Configuration D Component Failure Rule (Yapılandırma D Bileşen Hata Kuralı)

The full NAVGUARD configuration may continue under degraded operation after loss of an optional advanced source. *(Tam NAVGUARD yapılandırması isteğe bağlı gelişmiş bir kaynağın kaybından sonra bozulmuş çalışma altında devam edebilir.)*

The resulting session must record which source became unavailable and for how long. *(Ortaya çıkan oturum hangi kaynağın ne kadar süreyle kullanılamaz hale geldiğini kaydetmelidir.)*

Final analysis may evaluate both the complete and degraded intervals separately. *(Nihai analiz tam ve bozulmuş aralıkları ayrı ayrı değerlendirebilir.)*

---

# 75. State Machine Logging Requirements (Durum Makinesi Kayıt Gereksinimleri)

Every state transition must include an authoritative timestamp. *(Her durum geçişi ana bir zaman damgası içermelidir.)*

The reason or trigger for the transition should be stored. *(Geçişin nedeni veya tetikleyicisi saklanmalıdır.)*

GNSS authorization changes must be recorded explicitly. *(GNSS yetkilendirme değişiklikleri açıkça kaydedilmelidir.)*

Degraded-state entry and recovery must be recorded. *(Bozulmuş duruma giriş ve geri kazanım kaydedilmelidir.)*

---

# 76. Mode Event Stream (Mod Olay Akışı)

NAVGUARD will maintain a dedicated mode-event stream in each formal session. *(NAVGUARD her resmî oturumda özel bir mod olay akışı tutacaktır.)*

This stream may include the following events. *(Bu akış aşağıdaki olayları içerebilir.)*

`text id="j86dvb" SESSION_READY GNSS_ANCHOR_ACCEPTED EVALUATION_ARMED GNSS_ESTIMATOR_BLOCKED LOCAL_NAVIGATION_STARTED NAVIGATION_DEGRADED GNSS_RECOVERY_REQUESTED GNSS_RECOVERY_ACCEPTED RELOCALIZATION_STARTED RELOCALIZATION_COMPLETED SESSION_STOP_REQUESTED SESSION_COMPLETED SESSION_INVALIDATED`

This event stream will support later reconstruction of the experiment timeline. *(Bu olay akışı daha sonra deney zaman çizelgesinin yeniden oluşturulmasını destekleyecektir.)*

---

# 77. State Duration Metrics (Durum Süresi Metrikleri)

The evaluation pipeline may calculate the duration spent in each important runtime state. *(Değerlendirme hattı her önemli çalışma zamanı durumunda geçirilen süreyi hesaplayabilir.)*

Useful metrics may include total GNSS-denied duration and degraded-navigation duration. *(Kullanışlı metrikler toplam GNSS kesintili süreyi ve bozulmuş navigasyon süresini içerebilir.)*

ARCore tracking availability may be related to these state intervals. *(ARCore takip kullanılabilirliği bu durum aralıklarıyla ilişkilendirilebilir.)*

---

# 78. GNSS-Denied Session Timeline (GNSS Kesintili Oturum Zaman Çizelgesi)

`text id="no8v6v" T0 — Session Start T1 — GNSS Anchor Accepted T2 — Calibration Complete T3 — Evaluation Armed T4 — GNSS Estimator Access Blocked T5 — NAVGUARD Local Navigation Active T6 — Optional Degradation Events T7 — GNSS Recovery Requested T8 — Recovery GNSS Accepted T9 — Pre-Correction Error Recorded T10 — Relocalization Complete T11 — Session Stop`

All formal evaluation sessions should make these events reconstructable from stored data where applicable. *(Tüm resmî değerlendirme oturumları uygulanabilir olduğu durumlarda bu olayların saklanan veriden yeniden oluşturulabilmesini sağlamalıdır.)*

---

# 79. Evaluation Boundary (Değerlendirme Sınırı)

The primary GNSS-denied evaluation interval begins when GNSS estimator access becomes BLOCKED. *(Temel GNSS kesintili değerlendirme aralığı tahmin motoru GNSS erişimi BLOCKED olduğunda başlar.)*

The interval ends before the recovered GNSS measurement is used to correct the estimator. *(Aralık geri kazanılan GNSS ölçümü tahmin motorunu düzeltmek için kullanılmadan önce sona erer.)*

This definition prevents recovery correction from contaminating the measured denied-navigation error. *(Bu tanım geri kazanım düzeltmesinin ölçülen kesintili navigasyon hatasını kirletmesini önler.)*

---

# 80. Primary Benchmark Window (Birincil Benchmark Penceresi)

`text id="v19cxs" GNSS BLOCKED      │      ▼ ===================================================       PRIMARY GNSS-DENIED EVALUATION WINDOW ===================================================                                              │                                              ▼                              RECOVERY GNSS ACCEPTED                              BEFORE CORRECTION`

All primary position-error conclusions will prioritize this uncontaminated interval. *(Tüm temel konum hata sonuçları bu kirletilmemiş aralığa öncelik verecektir.)*

---

# 81. State Machine and Uncertainty Interaction (Durum Makinesi ve Belirsizlik Etkileşimi)

The uncertainty engine may use runtime-state information as one of its inputs. *(Belirsizlik motoru çalışma zamanı durum bilgisini girdilerinden biri olarak kullanabilir.)*

Entry into GNSS-denied navigation may begin a period of increasing uncertainty. *(GNSS kesintili navigasyona giriş artan bir belirsizlik dönemini başlatabilir.)*

Entry into DEGRADED_LOCAL_NAVIGATION may increase uncertainty more rapidly. *(DEGRADED_LOCAL_NAVIGATION durumuna giriş belirsizliği daha hızlı artırabilir.)*

Successful GNSS relocalization may reduce current uncertainty. *(Başarılı GNSS yeniden konumlandırması mevcut belirsizliği azaltabilir.)*

---

# 82. State Machine and UI Interaction (Durum Makinesi ve UI Etkileşimi)

The user interface will observe state-machine output rather than define navigation truth. *(Kullanıcı arayüzü navigasyon gerçeğini tanımlamak yerine durum makinesi çıktısını gözlemleyecektir.)*

Buttons will request transitions through the navigation controller. *(Butonlar navigasyon controller’ı üzerinden geçiş isteyecektir.)*

A button must not directly modify GNSS authorization flags. *(Bir buton GNSS yetkilendirme flag’lerini doğrudan değiştirmemelidir.)*

The controller and state machine will validate the requested transition. *(Controller ve durum makinesi istenen geçişi doğrulayacaktır.)*

---

# 83. GNSS Denial UI Action Flow (GNSS Kesintisi UI İşlem Akışı)

`text id="5yuon8" User Presses "Simulate GNSS Loss"         │         ▼ Navigation Controller         │         ▼ Validate Transition Guard         │         ▼ Navigation Mode Manager         │         ▼ Record Transition         │         ▼ Ground Truth Firewall Estimator GNSS = BLOCKED         │         ▼ ACTIVE_LOCAL_NAVIGATION`

The user interface itself does not manipulate the GNSS Manager subscription. *(Kullanıcı arayüzü GNSS Manager aboneliğini doğrudan yönetmez.)*

---

# 84. GNSS Recovery UI Action Flow (GNSS Geri Kazanım UI İşlem Akışı)

`text id="s54li8" User Presses "Restore GNSS"         │         ▼ GNSS_RECOVERY_PENDING         │         ▼ Validate GNSS Quality         │         ▼ Record Estimate Error         │         ▼ RELOCALIZING         │         ▼ GNSS_NAVIGATION`

This flow preserves experimental error before correction. *(Bu akış düzeltmeden önce deneysel hatayı korur.)*

---

# 85. Automatic Safety Against Accidental GNSS Leakage (Yanlışlıkla GNSS Sızıntısına Karşı Otomatik Koruma)

The estimator interface should require explicit authorization before accepting GNSS updates. *(Tahmin motoru arayüzü GNSS güncellemelerini kabul etmeden önce açık yetkilendirme gerektirmelidir.)*

GNSS should not be treated as an always-connected default estimator input. *(GNSS her zaman bağlı varsayılan tahmin motoru girdisi olarak ele alınmamalıdır.)*

The denied state should therefore be implemented through an explicit gate rather than by asking individual estimator modules to remember to ignore GNSS. *(Bu nedenle kesinti durumu bireysel tahmin motoru modüllerinden GNSS’i göz ardı etmelerini hatırlamalarını istemek yerine açık bir kapı üzerinden uygulanmalıdır.)*

---

# 86. State Machine Testability (Durum Makinesi Test Edilebilirliği)

The navigation state machine must be testable independently from physical sensor hardware. *(Navigasyon durum makinesi fiziksel sensör donanımından bağımsız olarak test edilebilir olmalıdır.)*

Synthetic readiness states and GNSS events should be usable in unit tests. *(Sentetik hazırlık durumları ve GNSS olayları birim testlerinde kullanılabilir olmalıdır.)*

Invalid transitions must have automated tests. *(Geçersiz geçişlerin otomatik testleri olmalıdır.)*

GNSS access invariants must have automated tests. *(GNSS erişim değişmezlerinin otomatik testleri olmalıdır.)*

---

# 87. Minimum State Machine Test Cases (Minimum Durum Makinesi Test Senaryoları)

The system must test the normal startup path. *(Sistem normal başlangıç yolunu test etmelidir.)*

The system must test failed readiness. *(Sistem başarısız hazırlığı test etmelidir.)*

The system must test GNSS-denied entry. *(Sistem GNSS kesintili girişi test etmelidir.)*

The system must test GNSS ground-truth isolation. *(Sistem GNSS gerçek referans izolasyonunu test etmelidir.)*

The system must test ARCore degradation during denied navigation. *(Sistem kesintili navigasyon sırasında ARCore bozulmasını test etmelidir.)*

The system must test AI failure fallback. *(Sistem yapay zekâ hata geri dönüşünü test etmelidir.)*

The system must test recovery and relocalization. *(Sistem geri kazanım ve yeniden konumlandırmayı test etmelidir.)*

The system must test controlled session stop. *(Sistem kontrollü oturum durdurmayı test etmelidir.)*

The system must test invalid transition rejection. *(Sistem geçersiz geçiş reddini test etmelidir.)*

---

# 88. Critical GNSS Isolation Test (Kritik GNSS İzolasyon Testi)

A dedicated automated test must verify that GNSS samples emitted during ACTIVE_LOCAL_NAVIGATION reach the ground-truth logger but not the estimator. *(Özel bir otomatik test ACTIVE_LOCAL_NAVIGATION sırasında üretilen GNSS örneklerinin gerçek referans logger’ına ulaştığını ancak tahmin motoruna ulaşmadığını doğrulamalıdır.)*

This test represents one of the most important experimental-integrity tests in the project. *(Bu test projedeki en önemli deneysel bütünlük testlerinden birini temsil eder.)*

---

# 89. Transition Table (Geçiş Tablosu)

| Current State (Mevcut Durum) | Trigger (Tetikleyici) | Guard (Koruma Koşulu) | Next State (Sonraki Durum) |
| --- | --- | --- | --- |
| IDLE | Start preparation *(Hazırlığı başlat)* | None *(Yok)* | READINESS_CHECK |
| READINESS_CHECK | All required checks pass *(Tüm gerekli kontroller geçer)* | Profile valid *(Profil geçerli)* | INITIALIZING |
| READINESS_CHECK | Required check fails *(Gerekli kontrol başarısız)* | None *(Yok)* | NOT_READY |
| NOT_READY | Retry *(Tekrar dene)* | Blocking issue resolved *(Engelleyici sorun çözüldü)* | READINESS_CHECK |
| INITIALIZING | Services ready *(Servisler hazır)* | No critical startup error *(Kritik başlangıç hatası yok)* | GNSS_ACQUISITION |
| GNSS_ACQUISITION | Valid GNSS obtained *(Geçerli GNSS elde edildi)* | Acceptance criteria satisfied *(Kabul kriterleri karşılandı)* | GNSS_READY |
| GNSS_READY | Begin calibration *(Kalibrasyonu başlat)* | Anchor available *(Çapa mevcut)* | CALIBRATING |
| CALIBRATING | Calibration passes *(Kalibrasyon geçer)* | Required sources ready *(Gerekli kaynaklar hazır)* | READY_TO_START |
| READY_TO_START | Begin GNSS navigation *(GNSS navigasyonunu başlat)* | Session created *(Oturum oluşturuldu)* | GNSS_NAVIGATION |
| READY_TO_START | Arm evaluation *(Değerlendirmeyi hazırla)* | Ground truth logger ready *(Gerçek referans logger hazır)* | EVALUATION_ARMED |
| EVALUATION_ARMED | Simulate GNSS loss *(GNSS kaybını simüle et)* | Denial guard passes *(Kesinti koruma koşulu geçer)* | GNSS_DENIAL_TRANSITION |
| GNSS_DENIAL_TRANSITION | GNSS blocked *(GNSS engellendi)* | Firewall verified *(Güvenlik duvarı doğrulandı)* | ACTIVE_LOCAL_NAVIGATION |
| ACTIVE_LOCAL_NAVIGATION | Optional source lost *(İsteğe bağlı kaynak kayboldu)* | Minimum estimator remains valid *(Minimum tahmin motoru geçerli kalır)* | DEGRADED_LOCAL_NAVIGATION |
| DEGRADED_LOCAL_NAVIGATION | Source recovered *(Kaynak geri geldi)* | Full profile restored *(Tam profil geri geldi)* | ACTIVE_LOCAL_NAVIGATION |
| ACTIVE_LOCAL_NAVIGATION | Restore GNSS requested *(GNSS geri yükleme istendi)* | None *(Yok)* | GNSS_RECOVERY_PENDING |
| DEGRADED_LOCAL_NAVIGATION | Restore GNSS requested *(GNSS geri yükleme istendi)* | None *(Yok)* | GNSS_RECOVERY_PENDING |
| GNSS_RECOVERY_PENDING | GNSS accepted *(GNSS kabul edildi)* | Recovery quality passes *(Geri kazanım kalitesi geçer)* | GNSS_RECOVERED |
| GNSS_RECOVERED | Error recorded *(Hata kaydedildi)* | Pre-correction metric complete *(Düzeltme öncesi metrik tamamlandı)* | RELOCALIZING |
| RELOCALIZING | Correction complete *(Düzeltme tamamlandı)* | State consistent *(Durum tutarlı)* | GNSS_NAVIGATION |
| Any Active State *(Herhangi Bir Aktif Durum)* | Stop requested *(Durdurma istendi)* | Safe stop possible *(Güvenli durdurma mümkün)* | SESSION_STOPPING |
| SESSION_STOPPING | Finalization complete *(Sonlandırma tamamlandı)* | Required writes completed *(Gerekli yazmalar tamamlandı)* | SESSION_COMPLETED |

---

# 90. Failure Transition Table (Hata Geçiş Tablosu)

| Condition (Koşul) | Expected Result (Beklenen Sonuç) |
| --- | --- |
| Optional ARCore failure *(İsteğe bağlı ARCore hatası)* | DEGRADED_LOCAL_NAVIGATION |
| Optional AI failure with deterministic fallback *(Deterministik geri dönüşlü isteğe bağlı AI hatası)* | DEGRADED_LOCAL_NAVIGATION |
| Mandatory accelerometer loss *(Zorunlu ivmeölçer kaybı)* | SESSION_INVALID or ERROR *(SESSION_INVALID veya ERROR)* |
| Ground-truth leakage into estimator *(Gerçek referansın tahmin motoruna sızması)* | SESSION_INVALID |
| Critical logging failure *(Kritik kayıt hatası)* | SESSION_INVALID / Controlled Stop *(SESSION_INVALID / Kontrollü Durdurma)* |
| Corrupted timestamp pipeline *(Bozuk zaman damgası hattı)* | SESSION_INVALID / ERROR |
| User-requested stop *(Kullanıcı tarafından istenen durdurma)* | SESSION_STOPPING |
| Invalid transition request *(Geçersiz geçiş isteği)* | Reject transition and log warning *(Geçişi reddet ve uyarı kaydet)* |

---

# 91. Normal Evaluation Scenario (Normal Değerlendirme Senaryosu)

A normal NAVGUARD evaluation will begin with the system in IDLE. *(Normal bir NAVGUARD değerlendirmesi sistem IDLE durumundayken başlayacaktır.)*

The system will verify readiness and acquire an acceptable GNSS anchor. *(Sistem hazırlığı doğrulayacak ve kabul edilebilir bir GNSS çapası elde edecektir.)*

The selected navigation components will be calibrated and initialized. *(Seçilen navigasyon bileşenleri kalibre edilecek ve başlatılacaktır.)*

Evaluation Mode will then be armed. *(Daha sonra Değerlendirme Modu hazır hale getirilecektir.)*

The user will activate simulated GNSS denial. *(Kullanıcı simüle edilmiş GNSS kesintisini etkinleştirecektir.)*

NAVGUARD will continue local navigation while GNSS remains isolated from the estimator. *(GNSS tahmin motorundan izole kalırken NAVGUARD yerel navigasyona devam edecektir.)*

At the end of the denied interval, GNSS recovery will be requested and the pre-correction navigation error will be measured. *(Kesinti aralığının sonunda GNSS geri kazanımı istenecek ve düzeltme öncesi navigasyon hatası ölçülecektir.)*

The system will then relocalize and finalize the session. *(Daha sonra sistem yeniden konumlandırılacak ve oturum sonlandırılacaktır.)*

---

# 92. Normal Evaluation Sequence (Normal Değerlendirme Sırası)

`text id="54b98m" IDLE  ↓ READINESS_CHECK  ↓ INITIALIZING  ↓ GNSS_ACQUISITION  ↓ GNSS_READY  ↓ CALIBRATING  ↓ READY_TO_START  ↓ EVALUATION_ARMED  ↓ GNSS_DENIAL_TRANSITION  ↓ ACTIVE_LOCAL_NAVIGATION  ↓ GNSS_RECOVERY_PENDING  ↓ GNSS_RECOVERED  ↓ RELOCALIZING  ↓ GNSS_NAVIGATION  ↓ SESSION_STOPPING  ↓ SESSION_COMPLETED`

---

# 93. Degraded Evaluation Sequence (Bozulmuş Değerlendirme Sırası)

`text id="aomq8v" ACTIVE_LOCAL_NAVIGATION         ↓ Optional Sensor / ARCore Failure         ↓ DEGRADED_LOCAL_NAVIGATION         ↓ Fallback Navigation Continues         ↓ Source Recovers         ↓ ACTIVE_LOCAL_NAVIGATION`

The degraded interval must be clearly marked in the session timeline. *(Bozulmuş aralık oturum zaman çizelgesinde açıkça işaretlenmelidir.)*

---

# 94. Invalid Evaluation Sequence (Geçersiz Değerlendirme Sırası)

`text id="cnyz5g" ACTIVE_LOCAL_NAVIGATION         ↓ Critical Integrity Failure         ↓ SESSION_INVALID         ↓ Controlled Finalization         ↓ Return to IDLE`

The recorded data should remain available for diagnosis. *(Kaydedilen veri tanı için kullanılabilir kalmalıdır.)*

---

# 95. State Machine Performance Requirement (Durum Makinesi Performans Gereksinimi)

State transitions are low-frequency control operations and do not need to execute at IMU sampling frequency. *(Durum geçişleri düşük frekanslı kontrol işlemleridir ve IMU örnekleme frekansında çalışmaları gerekmez.)*

High-frequency sensor processing must remain independent from state-machine UI updates. *(Yüksek frekanslı sensör işleme durum makinesi UI güncellemelerinden bağımsız kalmalıdır.)*

The current navigation authorization state must nevertheless be accessible efficiently to the estimator input gate. *(Bununla birlikte mevcut navigasyon yetkilendirme durumu tahmin motoru giriş kapısı tarafından verimli şekilde erişilebilir olmalıdır.)*

---

# 96. State Machine Persistence Requirement (Durum Makinesi Kalıcılık Gereksinimi)

State transition events must be persisted as experiment evidence. *(Durum geçiş olayları deneysel kanıt olarak kalıcı hale getirilmelidir.)*

The application does not need to resume an interrupted benchmark exactly from its previous state after a process death. *(Uygulamanın bir process kapanışından sonra kesilmiş bir benchmark’ı tam olarak önceki durumundan devam ettirmesi gerekmez.)*

An interrupted active session should instead be detected and marked incomplete. *(Bunun yerine kesilmiş aktif bir oturum tespit edilmeli ve eksik olarak işaretlenmelidir.)*

---

# 97. State Machine Security Principle (Durum Makinesi Güvenlik İlkesi)

No external network service will control NAVGUARD navigation-mode transitions in the initial project. *(İlk projede hiçbir harici ağ hizmeti NAVGUARD navigasyon modu geçişlerini kontrol etmeyecektir.)*

Mode transitions will be initiated locally by the application, user, or validated sensor-state logic. *(Mod geçişleri yerel olarak uygulama, kullanıcı veya doğrulanmış sensör durum mantığı tarafından başlatılacaktır.)*

This keeps experimental control local and reproducible. *(Bu deneysel kontrolü yerel ve tekrarlanabilir tutar.)*

---

# 98. State Machine Non-Goals (Durum Makinesi Olmayan Hedefler)

The state machine will not control raw sensor filtering coefficients directly. *(Durum makinesi ham sensör filtre katsayılarını doğrudan kontrol etmeyecektir.)*

The state machine will not perform PDR mathematics. *(Durum makinesi PDR matematiğini gerçekleştirmeyecektir.)*

The state machine will not perform AI inference. *(Durum makinesi yapay zekâ çıkarımı gerçekleştirmeyecektir.)*

The state machine will coordinate these systems through their status and availability. *(Durum makinesi bu sistemleri durumları ve kullanılabilirlikleri üzerinden koordine edecektir.)*

---

# 99. State Machine Architecture Rule (Durum Makinesi Mimari Kuralı)

The state machine defines **when** a navigation source is allowed to participate. *(Durum makinesi bir navigasyon kaynağının **ne zaman** katılmasına izin verildiğini tanımlar.)*

The navigation algorithms define **how** that source contributes to the estimate. *(Navigasyon algoritmaları bu kaynağın tahmine **nasıl** katkıda bulunduğunu tanımlar.)*

This separation must remain intact throughout development. *(Bu ayrım geliştirme boyunca korunmalıdır.)*

---

# 100. State Machine Acceptance Criteria (Durum Makinesi Kabul Kriterleri)

The state machine must prevent formal GNSS-denied navigation from starting without a valid initial anchor. *(Durum makinesi geçerli bir başlangıç çapası olmadan resmî GNSS kesintili navigasyonun başlamasını engellemelidir.)*

The state machine must explicitly block GNSS estimator updates during the denied phase. *(Durum makinesi kesinti aşamasında GNSS tahmin motoru güncellemelerini açıkça engellemelidir.)*

The state machine must preserve independent GNSS ground-truth logging during Evaluation Mode. *(Durum makinesi Değerlendirme Modunda bağımsız GNSS gerçek referans kaydını korumalıdır.)*

The state machine must support degraded local navigation when optional sources fail. *(Durum makinesi isteğe bağlı kaynaklar başarısız olduğunda bozulmuş yerel navigasyonu desteklemelidir.)*

The state machine must support controlled GNSS recovery and relocalization. *(Durum makinesi kontrollü GNSS geri kazanımı ve yeniden konumlandırmayı desteklemelidir.)*

The state machine must record all critical navigation transitions. *(Durum makinesi tüm kritik navigasyon geçişlerini kaydetmelidir.)*

The state machine must reject invalid transitions. *(Durum makinesi geçersiz geçişleri reddetmelidir.)*

---

# 101. Formal Evaluation Invariant (Resmî Değerlendirme Değişmezi)

**During the primary GNSS-denied evaluation window, independently recorded GNSS ground-truth measurements shall remain physically available to the logging and evaluation path when possible, while being logically inaccessible to the active NAVGUARD estimator.** *(Birincil GNSS kesintili değerlendirme penceresi sırasında bağımsız olarak kaydedilen GNSS gerçek referans ölçümleri mümkün olduğunda kayıt ve değerlendirme hattı için fiziksel olarak kullanılabilir kalacak ancak aktif NAVGUARD tahmin motoru için mantıksal olarak erişilemez olacaktır.)*

This is the most important state-machine integrity rule of the NAVGUARD experimental design. *(Bu, NAVGUARD deney tasarımının en önemli durum makinesi bütünlük kuralıdır.)*

---

# 102. Final State Machine Statement (Nihai Durum Makinesi Bildirimi)

**NAVGUARD will use an explicit navigation state machine to control initialization, GNSS anchoring, calibration, GNSS-enabled operation, controlled GNSS denial, local sensor-based navigation, degraded navigation, GNSS recovery, relocalization, and session finalization.** *(NAVGUARD; başlatma, GNSS çapa oluşturma, kalibrasyon, GNSS etkin çalışma, kontrollü GNSS kesintisi, yerel sensör tabanlı navigasyon, bozulmuş navigasyon, GNSS geri kazanımı, yeniden konumlandırma ve oturum sonlandırmayı kontrol etmek için açık bir navigasyon durum makinesi kullanacaktır.)*

**GNSS access to the estimator will be controlled by an explicit authorization gate rather than by individual navigation modules independently deciding whether to ignore GNSS.** *(Tahmin motorunun GNSS erişimi, bireysel navigasyon modüllerinin GNSS’i göz ardı edip etmemeye bağımsız olarak karar vermesi yerine açık bir yetkilendirme kapısı tarafından kontrol edilecektir.)*

**Evaluation Mode will allow GNSS ground truth to continue being recorded while NAVGUARD operates as though GNSS were unavailable.** *(Değerlendirme Modu, NAVGUARD GNSS kullanılamıyormuş gibi çalışırken GNSS gerçek referansının kaydedilmeye devam etmesine izin verecektir.)*

**GNSS recovery will measure the pre-correction error before any relocalization changes the active estimator state.** *(GNSS geri kazanımı, herhangi bir yeniden konumlandırma aktif tahmin motoru durumunu değiştirmeden önce düzeltme öncesi hatayı ölçecektir.)*

---

# 103. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development Navigation State Machine Completed *(Doküman Durumu: Geliştirme Öncesi Navigasyon Durum Makinesi Tamamlandı)*

**Primary Navigation Modes:** GNSS Mode + Evaluation Mode + NAVGUARD Mode *(Temel Navigasyon Modları: GNSS Modu + Değerlendirme Modu + NAVGUARD Modu)*

**GNSS-Denied Estimator Policy:** GNSS Access BLOCKED *(GNSS Kesintili Tahmin Motoru Politikası: GNSS Erişimi BLOCKED)*

**Ground Truth Logging During Denial:** ACTIVE *(Kesinti Sırasında Gerçek Referans Kaydı: AKTİF)*

**Primary Denied State:** ACTIVE_LOCAL_NAVIGATION *(Temel Kesintili Durum: ACTIVE_LOCAL_NAVIGATION)*

**Fallback State:** DEGRADED_LOCAL_NAVIGATION *(Geri Dönüş Durumu: DEGRADED_LOCAL_NAVIGATION)*

**Recovery Sequence:** GNSS_RECOVERY_PENDING → GNSS_RECOVERED → RELOCALIZING *(Geri Kazanım Sırası: GNSS_RECOVERY_PENDING → GNSS_RECOVERED → RELOCALIZING)*

**Critical Experimental Invariant:** Ground Truth GNSS Must Never Enter the Estimator During the Denied Evaluation Window *(Kritik Deneysel Değişmez: Gerçek Referans GNSS, Kesintili Değerlendirme Penceresinde Tahmin Motoruna Asla Girmemelidir.)*

**Next Documentation Item:** 12 — Sensor & Data Acquisition System *(Sonraki Dokümantasyon Öğesi: 12 — Sensör ve Veri Toplama Sistemi)*