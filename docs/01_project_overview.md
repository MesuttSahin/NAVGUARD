# 01 — Project Overview (Proje Genel Bakışı)

## 1. Document Purpose (Dokümanın Amacı)

This document provides a high-level overview of the NAVGUARD project and defines its identity, purpose, objectives, target use case, main capabilities, expected outputs, and fundamental development assumptions. *(Bu doküman, NAVGUARD projesinin üst seviye genel bakışını sunar ve projenin kimliğini, amacını, hedeflerini, hedef kullanım senaryosunu, temel yeteneklerini, beklenen çıktılarını ve temel geliştirme varsayımlarını tanımlar.)*

This document serves as the primary introductory reference for understanding what NAVGUARD is intended to achieve before detailed technical requirements and system design decisions are examined. *(Bu doküman, ayrıntılı teknik gereksinimler ve sistem tasarım kararları incelenmeden önce NAVGUARD'ın neyi başarmayı amaçladığını anlamak için temel giriş referansı olarak hizmet eder.)*

---

# 2. Project Identity (Proje Kimliği)

**Project Name:** NAVGUARD *(Proje Adı: NAVGUARD)*

**Full Project Name:** AI-Assisted GNSS-Denied Mobile Navigation and Sensor Fusion System *(Tam Proje Adı: Yapay Zekâ Destekli GNSS Kesintili Mobil Navigasyon ve Sensör Füzyon Sistemi)*

**Project Type:** Mobile Navigation Research and Proof-of-Concept System *(Proje Türü: Mobil Navigasyon Araştırma ve Kavram Kanıtlama Sistemi)*

**Target Platform:** Android *(Hedef Platform: Android)*

**Primary Test Device:** Xiaomi Redmi Note 9 Pro *(Birincil Test Cihazı: Xiaomi Redmi Note 9 Pro)*

**Development Duration:** 24 Business Days *(Geliştirme Süresi: 24 İş Günü)*

**Primary Development Framework:** Flutter *(Birincil Geliştirme Framework'ü: Flutter)*

**Primary Native Platform Technology:** Kotlin / Android APIs *(Birincil Native Platform Teknolojisi: Kotlin / Android API'leri)*

**Primary Machine Learning Environment:** Python *(Birincil Makine Öğrenmesi Ortamı: Python)*

**Primary AI Deployment Target:** On-Device Edge AI *(Birincil Yapay Zekâ Dağıtım Hedefi: Cihaz Üzerinde Edge AI)*

**Primary Navigation Domain:** Pedestrian Navigation *(Birincil Navigasyon Alanı: Yaya Navigasyonu)*

---

# 3. Executive Summary (Yönetici Özeti)

NAVGUARD is an Android-based mobile navigation research prototype designed to maintain approximate pedestrian position continuity when GNSS measurements become unavailable or are deliberately excluded from the navigation estimator. *(NAVGUARD, GNSS ölçümleri kullanılamaz hale geldiğinde veya navigasyon tahmin motorundan bilinçli olarak çıkarıldığında yaklaşık yaya konum sürekliliğini korumak için tasarlanmış Android tabanlı bir mobil navigasyon araştırma prototipidir.)*

The system will begin navigation using a valid GNSS position and will continue estimating user movement after GNSS loss by using sensors already available on the smartphone. *(Sistem, geçerli bir GNSS konumuyla navigasyona başlayacak ve GNSS kaybından sonra akıllı telefonda mevcut olan sensörleri kullanarak kullanıcı hareketini tahmin etmeye devam edecektir.)*

NAVGUARD will combine inertial sensor measurements, heading information, pedestrian dead reckoning, visual-inertial movement tracking, sensor fusion, and on-device artificial intelligence. *(NAVGUARD; ataletsel sensör ölçümlerini, yön bilgisini, yaya ölü hesaplamayı, görsel-ataletsel hareket takibini, sensör füzyonunu ve cihaz üzerinde çalışan yapay zekâyı birleştirecektir.)*

The primary goal is not to permanently replace GNSS, but to investigate how accurately and for how long a standard Android smartphone can continue estimating pedestrian movement after GNSS information is removed from the navigation process. *(Temel amaç GNSS'in kalıcı olarak yerini almak değil, GNSS bilgisi navigasyon sürecinden çıkarıldıktan sonra standart bir Android akıllı telefonun yaya hareketini ne kadar doğru ve ne kadar süreyle tahmin etmeye devam edebileceğini araştırmaktır.)*

The project will also experimentally compare multiple navigation approaches to determine whether artificial intelligence and visual-inertial sensor fusion can reduce accumulated position drift. *(Proje ayrıca yapay zekâ ve görsel-ataletsel sensör füzyonunun biriken konum sürüklenmesini azaltıp azaltamayacağını belirlemek için birden fazla navigasyon yaklaşımını deneysel olarak karşılaştıracaktır.)*

---

# 4. Project Vision (Proje Vizyonu)

The vision of NAVGUARD is to demonstrate that the sensors and processing capabilities available on a standard mobile device can be combined to create a resilient short-term navigation capability without requiring additional external navigation hardware. *(NAVGUARD'ın vizyonu, standart bir mobil cihazda bulunan sensörlerin ve işlem yeteneklerinin ek harici navigasyon donanımı gerektirmeden dayanıklı kısa süreli bir navigasyon yeteneği oluşturmak için birleştirilebileceğini göstermektir.)*

The project aims to transform the smartphone from a device that only consumes GNSS coordinates into a platform that can actively estimate its own movement by interpreting multiple sensor sources. *(Proje, akıllı telefonu yalnızca GNSS koordinatlarını kullanan bir cihaz olmaktan çıkarıp birden fazla sensör kaynağını yorumlayarak kendi hareketini aktif olarak tahmin edebilen bir platforma dönüştürmeyi amaçlamaktadır.)*

NAVGUARD is intended to serve as an experimental foundation for future research in resilient navigation, sensor fusion, Edge AI, mobile robotics, and autonomous systems. *(NAVGUARD'ın dayanıklı navigasyon, sensör füzyonu, Edge AI, mobil robotik ve otonom sistemler alanlarında gelecekte yapılacak araştırmalar için deneysel bir temel oluşturması amaçlanmaktadır.)*

---

# 5. Project Purpose (Projenin Amacı)

The purpose of NAVGUARD is to design, implement, and experimentally evaluate a mobile navigation system that continues estimating pedestrian movement during simulated GNSS outages. *(NAVGUARD'ın amacı, simüle edilmiş GNSS kesintileri sırasında yaya hareketini tahmin etmeye devam eden bir mobil navigasyon sistemini tasarlamak, geliştirmek ve deneysel olarak değerlendirmektir.)*

The system will use the smartphone's onboard sensors as alternative sources of motion information after the last reliable GNSS position is obtained. *(Sistem, son güvenilir GNSS konumu elde edildikten sonra akıllı telefonun cihaz içi sensörlerini alternatif hareket bilgisi kaynakları olarak kullanacaktır.)*

The project will investigate the contribution of individual navigation components and evaluate how their combination affects positioning accuracy and drift. *(Proje, bireysel navigasyon bileşenlerinin katkısını araştıracak ve bu bileşenlerin birleştirilmesinin konumlandırma doğruluğunu ve sürüklenmeyi nasıl etkilediğini değerlendirecektir.)*

---

# 6. Primary Project Objective (Birincil Proje Hedefi)

The primary objective is to develop a functional Android prototype that can estimate a pedestrian user's changing position after GNSS measurements are removed from the navigation estimator. *(Birincil hedef, GNSS ölçümleri navigasyon tahmin motorundan çıkarıldıktan sonra bir yaya kullanıcının değişen konumunu tahmin edebilen çalışan bir Android prototipi geliştirmektir.)*

The estimated trajectory will be compared against separately recorded GNSS ground truth data to quantify navigation error. *(Tahmini rota, navigasyon hatasını nicel olarak belirlemek amacıyla ayrı olarak kaydedilen GNSS gerçek referans verisiyle karşılaştırılacaktır.)*

---

# 7. Secondary Project Objectives (İkincil Proje Hedefleri)

The project will develop a reliable mobile sensor data acquisition infrastructure for accelerometer, gyroscope, magnetometer, orientation, GNSS, and visual-inertial tracking information. *(Proje; ivmeölçer, jiroskop, manyetometre, yönelim, GNSS ve görsel-ataletsel takip bilgileri için güvenilir bir mobil sensör veri toplama altyapısı geliştirecektir.)*

The project will implement a baseline Pedestrian Dead Reckoning system for GNSS-denied movement estimation. *(Proje, GNSS kesintili hareket tahmini için temel bir Yaya Ölü Hesaplama sistemi geliştirecektir.)*

The project will develop a heading estimation mechanism using multiple orientation-related sensor sources. *(Proje, yönelimle ilişkili birden fazla sensör kaynağını kullanarak bir yön tahmin mekanizması geliştirecektir.)*

The project will investigate ARCore-based visual-inertial tracking as an additional relative movement source. *(Proje, ek bir göreli hareket kaynağı olarak ARCore tabanlı görsel-ataletsel takibi araştıracaktır.)*

The project will develop an on-device artificial intelligence model for recognizing user motion states from sensor time-series data. *(Proje, sensör zaman serisi verilerinden kullanıcı hareket durumlarını tanımak için cihaz üzerinde çalışan bir yapay zekâ modeli geliştirecektir.)*

The project will investigate machine-learning-assisted step length estimation to improve pedestrian displacement calculations. *(Proje, yaya yer değiştirme hesaplamalarını iyileştirmek için makine öğrenmesi destekli adım uzunluğu tahminini araştıracaktır.)*

The project will combine multiple navigation sources through a sensor fusion mechanism. *(Proje, birden fazla navigasyon kaynağını bir sensör füzyon mekanizması aracılığıyla birleştirecektir.)*

The project will calculate navigation confidence and uncertainty indicators to avoid presenting estimated positions as perfectly accurate measurements. *(Proje, tahmini konumların tamamen doğru ölçümler gibi sunulmasını önlemek için navigasyon güveni ve belirsizlik göstergeleri hesaplayacaktır.)*

The project will evaluate navigation accuracy, AI performance, execution latency, and device resource consumption through controlled tests. *(Proje, kontrollü testler aracılığıyla navigasyon doğruluğunu, yapay zekâ performansını, çalışma gecikmesini ve cihaz kaynak tüketimini değerlendirecektir.)*

---

# 8. Problem Scenario (Problem Senaryosu)

A pedestrian user begins navigation while reliable GNSS positioning is available. *(Bir yaya kullanıcı, güvenilir GNSS konumlandırması mevcutken navigasyona başlar.)*

NAVGUARD records the initial global position and initializes the required navigation components. *(NAVGUARD, başlangıç global konumunu kaydeder ve gerekli navigasyon bileşenlerini başlatır.)*

During the test, GNSS measurements are intentionally removed from the navigation estimator. *(Test sırasında GNSS ölçümleri navigasyon tahmin motorundan bilinçli olarak çıkarılır.)*

The user continues moving while NAVGUARD estimates displacement using onboard sensors, pedestrian dead reckoning, visual-inertial tracking, and artificial intelligence. *(Kullanıcı hareket etmeye devam ederken NAVGUARD, cihaz içi sensörleri, yaya ölü hesaplamayı, görsel-ataletsel takibi ve yapay zekâyı kullanarak yer değiştirmeyi tahmin eder.)*

The application continuously updates the estimated route and the system's confidence in that estimate. *(Uygulama, tahmini rotayı ve sistemin bu tahmine olan güvenini sürekli olarak günceller.)*

Meanwhile, real GNSS measurements may continue to be recorded in a separate evaluation channel without being provided to the NAVGUARD estimator. *(Bu sırada gerçek GNSS ölçümleri, NAVGUARD tahmin motoruna verilmeden ayrı bir değerlendirme kanalında kaydedilmeye devam edilebilir.)*

At the end of the session, the estimated route and the GNSS reference route are compared. *(Oturum sonunda tahmini rota ile GNSS referans rotası karşılaştırılır.)*

---

# 9. Primary Use Case (Birincil Kullanım Senaryosu)

The primary use case is short-term pedestrian navigation continuity during temporary GNSS unavailability. *(Birincil kullanım senaryosu, geçici GNSS kullanılamazlığı sırasında kısa süreli yaya navigasyon sürekliliğidir.)*

The prototype will focus on controlled outdoor and indoor walking experiments rather than production navigation services. *(Prototip, üretim seviyesinde navigasyon hizmetleri yerine kontrollü açık alan ve kapalı alan yürüyüş deneylerine odaklanacaktır.)*

The application will be used primarily as a research and demonstration platform for evaluating GNSS-denied navigation methods on a mobile device. *(Uygulama öncelikli olarak bir mobil cihaz üzerinde GNSS kesintili navigasyon yöntemlerini değerlendirmek için bir araştırma ve gösterim platformu olarak kullanılacaktır.)*

---

# 10. Target User Profile (Hedef Kullanıcı Profili)

The initial prototype is intended for engineers, researchers, developers, and technical evaluators rather than general consumers. *(İlk prototip, genel tüketiciler yerine mühendisler, araştırmacılar, geliştiriciler ve teknik değerlendiriciler için tasarlanmıştır.)*

The user is expected to conduct controlled navigation sessions, inspect sensor and AI outputs, and evaluate the resulting position estimates. *(Kullanıcının kontrollü navigasyon oturumları gerçekleştirmesi, sensör ve yapay zekâ çıktılarını incelemesi ve ortaya çıkan konum tahminlerini değerlendirmesi beklenmektedir.)*

A simplified user-facing navigation interface will still be provided so that the system can be demonstrated without requiring access to internal debugging tools. *(Sistemin dahili hata ayıklama araçlarına erişim gerektirmeden gösterilebilmesi için yine de basitleştirilmiş kullanıcı odaklı bir navigasyon arayüzü sağlanacaktır.)*

---

# 11. Core System Capabilities (Temel Sistem Yetenekleri)

NAVGUARD will obtain and validate an initial GNSS position before starting a GNSS-denied navigation session. *(NAVGUARD, GNSS kesintili navigasyon oturumunu başlatmadan önce başlangıç GNSS konumunu elde edecek ve doğrulayacaktır.)*

NAVGUARD will collect synchronized motion and orientation sensor measurements from the Android device. *(NAVGUARD, Android cihazdan senkronize hareket ve yönelim sensörü ölçümlerini toplayacaktır.)*

NAVGUARD will detect pedestrian steps from inertial sensor data. *(NAVGUARD, ataletsel sensör verilerinden yaya adımlarını tespit edecektir.)*

NAVGUARD will estimate the user's movement direction. *(NAVGUARD, kullanıcının hareket yönünü tahmin edecektir.)*

NAVGUARD will calculate a baseline GNSS-denied trajectory using Pedestrian Dead Reckoning. *(NAVGUARD, Yaya Ölü Hesaplama yöntemini kullanarak temel bir GNSS kesintili rota hesaplayacaktır.)*

NAVGUARD will classify user motion states using an on-device artificial intelligence model. *(NAVGUARD, cihaz üzerinde çalışan bir yapay zekâ modeli kullanarak kullanıcı hareket durumlarını sınıflandıracaktır.)*

NAVGUARD will investigate dynamic step length estimation using machine learning. *(NAVGUARD, makine öğrenmesi kullanarak dinamik adım uzunluğu tahminini araştıracaktır.)*

NAVGUARD will obtain relative movement information from ARCore when visual-inertial tracking is available. *(NAVGUARD, görsel-ataletsel takip kullanılabilir olduğunda ARCore'dan göreli hareket bilgisi elde edecektir.)*

NAVGUARD will combine multiple navigation measurements through sensor fusion. *(NAVGUARD, birden fazla navigasyon ölçümünü sensör füzyonu aracılığıyla birleştirecektir.)*

NAVGUARD will display the estimated position and route on the mobile interface. *(NAVGUARD, tahmini konumu ve rotayı mobil arayüzde gösterecektir.)*

NAVGUARD will record navigation sessions for later analysis. *(NAVGUARD, daha sonra analiz edilmek üzere navigasyon oturumlarını kaydedecektir.)*

NAVGUARD will compare estimated trajectories against GNSS ground truth data after test sessions. *(NAVGUARD, test oturumlarından sonra tahmini rotaları GNSS gerçek referans verileriyle karşılaştıracaktır.)*

---

# 12. Artificial Intelligence Role (Yapay Zekânın Rolü)

Artificial intelligence will support the navigation process rather than replace the underlying navigation algorithms. *(Yapay zekâ, temel navigasyon algoritmalarının yerini almak yerine navigasyon sürecini destekleyecektir.)*

The primary AI task will be motion classification from multivariate sensor time-series data. *(Birincil yapay zekâ görevi, çok değişkenli sensör zaman serisi verilerinden hareket sınıflandırması olacaktır.)*

The planned motion classes are stationary, walking, running, and turning. *(Planlanan hareket sınıfları sabit durma, yürüme, koşma ve dönmedir.)*

The primary candidate model is a lightweight 1D Convolutional Neural Network designed for on-device inference. *(Birincil aday model, cihaz üzerinde çıkarım için tasarlanmış hafif bir 1 Boyutlu Evrişimsel Sinir Ağıdır.)*

Traditional machine learning models will also be evaluated as baseline approaches before the final model is selected. *(Nihai model seçilmeden önce geleneksel makine öğrenmesi modelleri de temel referans yaklaşımları olarak değerlendirilecektir.)*

A secondary regression model may estimate step length dynamically using motion and inertial characteristics. *(İkincil bir regresyon modeli, hareket ve ataletsel özellikleri kullanarak adım uzunluğunu dinamik olarak tahmin edebilir.)*

All final AI inference required for navigation is intended to run locally on the Android device. *(Navigasyon için gerekli tüm nihai yapay zekâ çıkarımının Android cihaz üzerinde yerel olarak çalışması amaçlanmaktadır.)*

---

# 13. Offline and Edge AI Approach (Çevrimdışı ve Edge AI Yaklaşımı)

The core NAVGUARD navigation engine will not depend on continuous internet connectivity. *(NAVGUARD'ın temel navigasyon motoru sürekli internet bağlantısına bağımlı olmayacaktır.)*

Sensor processing, motion classification, position estimation, and sensor fusion will be performed locally on the device. *(Sensör işleme, hareket sınıflandırması, konum tahmini ve sensör füzyonu cihaz üzerinde yerel olarak gerçekleştirilecektir.)*

The project will avoid mandatory cloud AI APIs for core navigation functions. *(Proje, temel navigasyon işlevleri için zorunlu bulut yapay zekâ API'lerinden kaçınacaktır.)*

This design supports predictable latency, offline operation, privacy, and independence from network availability. *(Bu tasarım; öngörülebilir gecikmeyi, çevrimdışı çalışmayı, gizliliği ve ağ kullanılabilirliğinden bağımsızlığı desteklemektedir.)*

---

# 14. Target Hardware Baseline (Hedef Donanım Referansı)

The Xiaomi Redmi Note 9 Pro will be used as the primary reference device throughout implementation and testing. *(Xiaomi Redmi Note 9 Pro, geliştirme ve test süreci boyunca birincil referans cihaz olarak kullanılacaktır.)*

The project will not assume that sensor behavior is identical across different Android devices. *(Proje, sensör davranışının farklı Android cihazlarda aynı olduğunu varsaymayacaktır.)*

Actual sensor availability, manufacturer information, sampling behavior, noise characteristics, ARCore functionality, and GNSS behavior will be measured on the physical test device before navigation algorithms are finalized. *(Gerçek sensör kullanılabilirliği, üretici bilgileri, örnekleme davranışı, gürültü özellikleri, ARCore işlevselliği ve GNSS davranışı navigasyon algoritmaları kesinleştirilmeden önce fiziksel test cihazında ölçülecektir.)*

The results of these checks will be documented separately in the Device Capability Audit. *(Bu kontrollerin sonuçları Cihaz Yetenek Denetimi bölümünde ayrı olarak dokümante edilecektir.)*

---

# 15. High-Level Technical Approach (Üst Seviye Teknik Yaklaşım)

The technical workflow of NAVGUARD will follow a layered architecture. *(NAVGUARD'ın teknik iş akışı katmanlı bir mimari izleyecektir.)*

The sensor layer will acquire GNSS, inertial, orientation, and visual-inertial measurements. *(Sensör katmanı GNSS, ataletsel, yönelim ve görsel-ataletsel ölçümleri elde edecektir.)*

The preprocessing layer will synchronize timestamps, filter noise, and transform raw measurements into usable navigation inputs. *(Ön işleme katmanı zaman damgalarını senkronize edecek, gürültüyü filtreleyecek ve ham ölçümleri kullanılabilir navigasyon girdilerine dönüştürecektir.)*

The pedestrian navigation layer will perform step detection, step length estimation, heading estimation, and dead reckoning. *(Yaya navigasyon katmanı adım tespiti, adım uzunluğu tahmini, yön tahmini ve ölü hesaplama işlemlerini gerçekleştirecektir.)*

The artificial intelligence layer will interpret sensor time-series patterns and support motion-dependent navigation decisions. *(Yapay zekâ katmanı sensör zaman serisi örüntülerini yorumlayacak ve harekete bağlı navigasyon kararlarını destekleyecektir.)*

The visual-inertial layer will provide relative device movement information through ARCore when tracking conditions are suitable. *(Görsel-ataletsel katman, takip koşulları uygun olduğunda ARCore aracılığıyla göreli cihaz hareket bilgisi sağlayacaktır.)*

The fusion layer will combine the available navigation information into the final position estimate. *(Füzyon katmanı kullanılabilir navigasyon bilgilerini nihai konum tahmininde birleştirecektir.)*

The evaluation layer will compare estimated positions against reference measurements and calculate experimental metrics. *(Değerlendirme katmanı tahmini konumları referans ölçümlerle karşılaştıracak ve deneysel metrikleri hesaplayacaktır.)*

---

# 16. Expected Project Deliverables (Beklenen Proje Çıktıları)

The project will deliver a functional Android NAVGUARD application. *(Proje, çalışan bir Android NAVGUARD uygulaması teslim edecektir.)*

The project will deliver a sensor data logging and navigation session recording infrastructure. *(Proje, bir sensör veri kayıt ve navigasyon oturumu kayıt altyapısı teslim edecektir.)*

The project will deliver a baseline Pedestrian Dead Reckoning implementation. *(Proje, temel bir Yaya Ölü Hesaplama uygulaması teslim edecektir.)*

The project will deliver an AI-based motion classification model optimized for mobile inference. *(Proje, mobil çıkarım için optimize edilmiş yapay zekâ tabanlı bir hareket sınıflandırma modeli teslim edecektir.)*

The project is expected to deliver an experimental step length estimation model if development progress allows. *(Geliştirme ilerlemesi izin verdiği takdirde projenin deneysel bir adım uzunluğu tahmin modeli teslim etmesi beklenmektedir.)*

The project will deliver a sensor fusion-based position estimation engine. *(Proje, sensör füzyonu tabanlı bir konum tahmin motoru teslim edecektir.)*

The project is expected to integrate ARCore-based relative movement tracking as an advanced navigation input. *(Projenin gelişmiş bir navigasyon girdisi olarak ARCore tabanlı göreli hareket takibini entegre etmesi beklenmektedir.)*

The project will deliver a GNSS-denied simulation and evaluation mode. *(Proje, GNSS kesinti simülasyon ve değerlendirme modu teslim edecektir.)*

The project will deliver recorded field experiment results and benchmark comparisons. *(Proje, kaydedilmiş saha deney sonuçları ve benchmark karşılaştırmaları teslim edecektir.)*

The project will deliver complete technical documentation covering design, implementation, testing, results, limitations, and future development opportunities. *(Proje; tasarım, geliştirme, test, sonuçlar, sınırlamalar ve gelecekteki geliştirme fırsatlarını kapsayan eksiksiz teknik dokümantasyon teslim edecektir.)*

---

# 17. Expected Demonstration Output (Beklenen Demo Çıktısı)

The final demonstration will begin with a valid GNSS position and an initialized NAVGUARD navigation session. *(Nihai demo, geçerli bir GNSS konumu ve başlatılmış bir NAVGUARD navigasyon oturumu ile başlayacaktır.)*

GNSS input will then be deliberately disabled for the navigation estimator while the user continues walking. *(Daha sonra kullanıcı yürümeye devam ederken GNSS girdisi navigasyon tahmin motoru için bilinçli olarak devre dışı bırakılacaktır.)*

NAVGUARD will continue updating the estimated position using its alternative navigation components. *(NAVGUARD, alternatif navigasyon bileşenlerini kullanarak tahmini konumu güncellemeye devam edecektir.)*

The application will display navigation status, motion state, heading, estimated position, route, sensor status, and confidence information. *(Uygulama; navigasyon durumunu, hareket durumunu, yönü, tahmini konumu, rotayı, sensör durumunu ve güven bilgisini gösterecektir.)*

At the end of the session, the NAVGUARD trajectory will be compared with the independently recorded GNSS reference trajectory. *(Oturum sonunda NAVGUARD rotası, bağımsız olarak kaydedilmiş GNSS referans rotasıyla karşılaştırılacaktır.)*

The demonstration will present quantitative error metrics instead of relying only on visual route comparison. *(Demo, yalnızca görsel rota karşılaştırmasına bağlı kalmak yerine nicel hata metriklerini sunacaktır.)*

---

# 18. High-Level Experimental Comparison (Üst Seviye Deneysel Karşılaştırma)

NAVGUARD will not be evaluated only as a single final system. *(NAVGUARD yalnızca tek bir nihai sistem olarak değerlendirilmeyecektir.)*

Multiple configurations will be tested to determine the contribution of each major navigation component. *(Her önemli navigasyon bileşeninin katkısını belirlemek için birden fazla yapılandırma test edilecektir.)*

The planned high-level configurations are PDR Only, PDR with improved heading estimation, PDR with ARCore assistance, and the complete NAVGUARD AI-assisted sensor fusion system. *(Planlanan üst seviye yapılandırmalar; Yalnızca PDR, geliştirilmiş yön tahminli PDR, ARCore destekli PDR ve tam NAVGUARD yapay zekâ destekli sensör füzyon sistemidir.)*

The final results will compare these configurations using identical or comparable test routes whenever possible. *(Nihai sonuçlar, mümkün olduğunda aynı veya karşılaştırılabilir test rotalarını kullanarak bu yapılandırmaları karşılaştıracaktır.)*

---

# 19. Key Measurement Areas (Temel Ölçüm Alanları)

Navigation performance will be measured using position error and drift-related metrics. *(Navigasyon performansı konum hatası ve sürüklenmeyle ilişkili metrikler kullanılarak ölçülecektir.)*

Heading performance will be evaluated independently where suitable reference data can be obtained. *(Uygun referans verisi elde edilebildiği durumlarda yön performansı bağımsız olarak değerlendirilecektir.)*

Artificial intelligence models will be evaluated using classification or regression metrics appropriate to their respective tasks. *(Yapay zekâ modelleri, kendi görevlerine uygun sınıflandırma veya regresyon metrikleri kullanılarak değerlendirilecektir.)*

Mobile deployment performance will be evaluated using inference latency and device resource consumption. *(Mobil dağıtım performansı çıkarım gecikmesi ve cihaz kaynak tüketimi kullanılarak değerlendirilecektir.)*

Visual-inertial tracking availability will be recorded to identify environments in which ARCore tracking becomes unreliable. *(ARCore takibinin güvenilmez hale geldiği ortamları belirlemek için görsel-ataletsel takip kullanılabilirliği kaydedilecektir.)*

---

# 20. Major Project Constraints (Temel Proje Kısıtları)

The project must be completed within 24 business days. *(Proje 24 iş günü içerisinde tamamlanmalıdır.)*

The application will be developed only for Android. *(Uygulama yalnızca Android için geliştirilecektir.)*

The Xiaomi Redmi Note 9 Pro will be the primary physical test device. *(Xiaomi Redmi Note 9 Pro birincil fiziksel test cihazı olacaktır.)*

The project will not depend on purchasing additional navigation hardware. *(Proje ek navigasyon donanımı satın alınmasına bağımlı olmayacaktır.)*

The core navigation system must remain functional without a continuous internet connection. *(Temel navigasyon sistemi sürekli internet bağlantısı olmadan çalışabilir durumda olmalıdır.)*

Sensor quality and availability will be limited by the hardware characteristics of the target smartphone. *(Sensör kalitesi ve kullanılabilirliği hedef akıllı telefonun donanım özellikleriyle sınırlı olacaktır.)*

GNSS-denied navigation error is expected to increase over time because dead reckoning systems inherently accumulate drift. *(Ölü hesaplama sistemleri doğası gereği sürüklenme biriktirdiği için GNSS kesintili navigasyon hatasının zamanla artması beklenmektedir.)*

ARCore performance may vary depending on lighting, camera motion, scene texture, and environmental conditions. *(ARCore performansı aydınlatma, kamera hareketi, sahne dokusu ve çevresel koşullara bağlı olarak değişebilir.)*

The project will prioritize a measurable and stable prototype over implementing every possible advanced navigation feature. *(Proje, mümkün olan tüm gelişmiş navigasyon özelliklerini uygulamak yerine ölçülebilir ve kararlı bir prototipe öncelik verecektir.)*

---

# 21. Project Boundaries at a Glance (Özet Proje Sınırları)

NAVGUARD will focus on pedestrian navigation. *(NAVGUARD yaya navigasyonuna odaklanacaktır.)*

NAVGUARD will not be designed as a production-grade certified navigation system. *(NAVGUARD üretim seviyesinde sertifikalı bir navigasyon sistemi olarak tasarlanmayacaktır.)*

NAVGUARD will not claim military-grade positioning accuracy. *(NAVGUARD askeri seviye konumlandırma doğruluğu iddiasında bulunmayacaktır.)*

NAVGUARD will not attempt to defeat, bypass, or interfere with real GNSS infrastructure. *(NAVGUARD gerçek GNSS altyapısını bozmayı, aşmayı veya bu altyapıya müdahale etmeyi amaçlamayacaktır.)*

GNSS loss will primarily be simulated by preventing GNSS measurements from entering the navigation estimator. *(GNSS kaybı temel olarak GNSS ölçümlerinin navigasyon tahmin motoruna girmesinin engellenmesiyle simüle edilecektir.)*

Detailed inclusions and exclusions will be formally defined in the Project Scope and Boundaries document. *(Ayrıntılı dahil edilen ve hariç tutulan kapsam maddeleri Proje Kapsamı ve Sınırları dokümanında resmî olarak tanımlanacaktır.)*

---

# 22. Project Value (Proje Değeri)

NAVGUARD combines mobile software development, signal processing, navigation algorithms, sensor fusion, artificial intelligence, Edge AI, computer vision, and experimental evaluation within a single project. *(NAVGUARD; mobil yazılım geliştirme, sinyal işleme, navigasyon algoritmaları, sensör füzyonu, yapay zekâ, Edge AI, bilgisayarlı görü ve deneysel değerlendirmeyi tek bir proje içerisinde birleştirir.)*

The project provides practical experience with real-world sensor imperfections instead of relying exclusively on clean simulated data. *(Proje, yalnızca temiz simüle edilmiş verilere dayanmak yerine gerçek dünya sensör kusurlarıyla pratik deneyim sağlar.)*

The project produces quantitative engineering results that can be evaluated independently from the mobile application's visual interface. *(Proje, mobil uygulamanın görsel arayüzünden bağımsız olarak değerlendirilebilen nicel mühendislik sonuçları üretir.)*

The modular architecture also creates a foundation that can be extended in future research without requiring the entire system to be redesigned. *(Modüler mimari ayrıca gelecekteki araştırmalarda tüm sistemin yeniden tasarlanmasını gerektirmeden genişletilebilecek bir temel oluşturur.)*

---

# 23. Development Philosophy (Geliştirme Felsefesi)

The project will be developed incrementally from a simple working baseline toward a more advanced sensor fusion system. *(Proje, basit çalışan bir temel sistemden daha gelişmiş bir sensör füzyon sistemine doğru kademeli olarak geliştirilecektir.)*

A working baseline will always be maintained before introducing higher-risk components. *(Daha yüksek riskli bileşenler eklenmeden önce çalışan bir temel sistem her zaman korunacaktır.)*

Each major component will be tested independently before being integrated into the final navigation pipeline. *(Her önemli bileşen, nihai navigasyon hattına entegre edilmeden önce bağımsız olarak test edilecektir.)*

Experimental evidence will be used to decide whether an advanced component improves the system sufficiently to remain in the final configuration. *(Gelişmiş bir bileşenin nihai yapılandırmada kalmasını sağlayacak kadar sistemi iyileştirip iyileştirmediğine karar vermek için deneysel kanıt kullanılacaktır.)*

Technical complexity will not be added unless it provides measurable value to the navigation system or research objectives. *(Navigasyon sistemine veya araştırma hedeflerine ölçülebilir değer sağlamadığı sürece teknik karmaşıklık eklenmeyecektir.)*

---

# 24. Project Completion Statement (Proje Tamamlanma Tanımı)

NAVGUARD will be considered successfully implemented when a stable Android prototype can complete controlled GNSS-denied pedestrian navigation experiments and generate reproducible evaluation results. *(NAVGUARD, kararlı bir Android prototipi kontrollü GNSS kesintili yaya navigasyon deneylerini tamamlayabildiğinde ve tekrarlanabilir değerlendirme sonuçları üretebildiğinde başarıyla geliştirilmiş kabul edilecektir.)*

The final project must demonstrate both a functioning mobile system and measurable experimental evidence. *(Nihai proje hem çalışan bir mobil sistemi hem de ölçülebilir deneysel kanıtları göstermelidir.)*

Detailed acceptance thresholds and Definition of Done criteria will be specified later in the dedicated verification and acceptance documentation. *(Ayrıntılı kabul eşikleri ve Tamamlanma Tanımı kriterleri daha sonra ilgili doğrulama ve kabul dokümantasyonunda belirtilecektir.)*

---

# 25. Current Project Phase (Mevcut Proje Aşaması)

**Current Phase:** Technical Documentation and Pre-Development Planning *(Mevcut Aşama: Teknik Dokümantasyon ve Geliştirme Öncesi Planlama)*

**Implementation Status:** Not Started *(Geliştirme Durumu: Başlanmadı)*

**Project Overview Status:** Completed *(Proje Genel Bakış Durumu: Tamamlandı)*

**Next Documentation Item:** 02 — Problem Definition & Motivation *(Sonraki Dokümantasyon Öğesi: 02 — Problem Tanımı ve Motivasyon)*