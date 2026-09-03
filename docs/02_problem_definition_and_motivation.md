# 02 — Problem Definition & Motivation (Problem Tanımı ve Motivasyon)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the navigation problem addressed by NAVGUARD and explains the technical motivation behind the project. *(Bu doküman, NAVGUARD tarafından ele alınan navigasyon problemini tanımlar ve projenin arkasındaki teknik motivasyonu açıklar.)*

The document focuses on the limitations of GNSS-dependent mobile navigation, the challenges introduced by temporary GNSS unavailability, the limitations of standalone smartphone sensors, and the motivation for combining multiple navigation information sources. *(Doküman, GNSS'e bağımlı mobil navigasyonun sınırlamalarına, geçici GNSS kullanılamazlığının oluşturduğu zorluklara, bağımsız akıllı telefon sensörlerinin sınırlamalarına ve birden fazla navigasyon bilgi kaynağının birleştirilmesine yönelik motivasyona odaklanır.)*

Detailed implementation decisions, algorithms, mathematical models, and system architecture are intentionally defined in later technical documents. *(Ayrıntılı uygulama kararları, algoritmalar, matematiksel modeller ve sistem mimarisi bilinçli olarak sonraki teknik dokümanlarda tanımlanacaktır.)*

---

# 2. Background (Arka Plan)

Modern mobile navigation applications primarily rely on Global Navigation Satellite Systems to obtain absolute geographic position information. *(Modern mobil navigasyon uygulamaları, mutlak coğrafi konum bilgisi elde etmek için temel olarak Küresel Navigasyon Uydu Sistemlerine dayanır.)*

GNSS provides latitude, longitude, altitude, velocity, timing, and related positioning information by processing signals received from navigation satellites. *(GNSS, navigasyon uydularından alınan sinyalleri işleyerek enlem, boylam, yükseklik, hız, zamanlama ve ilgili konumlandırma bilgilerini sağlar.)*

For ordinary outdoor mobile applications, GNSS generally provides a convenient and sufficiently accurate source of global position information. *(Günlük açık alan mobil uygulamalarında GNSS genellikle kullanışlı ve yeterince doğru bir global konum bilgisi kaynağı sağlar.)*

However, GNSS availability and accuracy cannot be assumed to remain constant in every environment. *(Ancak GNSS kullanılabilirliğinin ve doğruluğunun her ortamda sabit kalacağı varsayılamaz.)*

A navigation system that depends exclusively on GNSS may therefore experience degraded positioning performance or complete loss of position updates under unfavorable conditions. *(Bu nedenle yalnızca GNSS'e bağımlı bir navigasyon sistemi, elverişsiz koşullarda konumlandırma performansında bozulma veya konum güncellemelerinin tamamen kaybolmasıyla karşılaşabilir.)*

---

# 3. Core Problem Statement (Temel Problem Tanımı)

The core problem addressed by NAVGUARD is the loss of continuous position estimation when reliable GNSS measurements are temporarily unavailable. *(NAVGUARD tarafından ele alınan temel problem, güvenilir GNSS ölçümleri geçici olarak kullanılamadığında sürekli konum tahmininin kaybolmasıdır.)*

When GNSS measurements disappear from a conventional mobile navigation system, the device may retain its last known position but cannot determine subsequent displacement accurately without additional information sources. *(GNSS ölçümleri geleneksel bir mobil navigasyon sisteminden kaybolduğunda cihaz son bilinen konumunu koruyabilir ancak ek bilgi kaynakları olmadan sonraki yer değiştirmeyi doğru şekilde belirleyemez.)*

The user may continue moving even though the navigation system no longer receives reliable absolute position updates. *(Navigasyon sistemi artık güvenilir mutlak konum güncellemeleri alamasa bile kullanıcı hareket etmeye devam edebilir.)*

This creates a growing difference between the user's actual position and the last position known by the navigation application. *(Bu durum, kullanıcının gerçek konumu ile navigasyon uygulaması tarafından bilinen son konum arasında giderek büyüyen bir fark oluşturur.)*

NAVGUARD investigates whether the smartphone can estimate this movement using information available locally on the device until reliable GNSS information becomes available again. *(NAVGUARD, güvenilir GNSS bilgisi tekrar kullanılabilir hale gelene kadar akıllı telefonun cihaz üzerinde yerel olarak bulunan bilgileri kullanarak bu hareketi tahmin edip edemeyeceğini araştırır.)*

---

# 4. GNSS Dependency Problem (GNSS Bağımlılığı Problemi)

A conventional smartphone navigation application often treats GNSS as its primary absolute positioning source. *(Geleneksel bir akıllı telefon navigasyon uygulaması genellikle GNSS'i birincil mutlak konumlandırma kaynağı olarak kullanır.)*

This dependency works effectively while satellite measurements remain sufficiently available and reliable. *(Bu bağımlılık, uydu ölçümleri yeterli düzeyde kullanılabilir ve güvenilir olduğu sürece etkili şekilde çalışır.)*

The problem begins when the quality or availability of these measurements decreases. *(Problem, bu ölçümlerin kalitesi veya kullanılabilirliği azaldığında başlar.)*

If no alternative positioning mechanism exists, the navigation application cannot maintain accurate knowledge of the user's movement after the last reliable GNSS update. *(Alternatif bir konumlandırma mekanizması mevcut değilse navigasyon uygulaması son güvenilir GNSS güncellemesinden sonra kullanıcının hareketine ilişkin doğru bilgiyi sürdüremez.)*

This represents a single-source dependency in the navigation architecture. *(Bu durum, navigasyon mimarisinde tek kaynağa bağımlılığı temsil eder.)*

NAVGUARD is motivated by the idea that the failure or degradation of one positioning source should not immediately eliminate all navigation capability. *(NAVGUARD, tek bir konumlandırma kaynağının başarısız olması veya bozulmasının tüm navigasyon yeteneğini anında ortadan kaldırmaması gerektiği fikrinden hareket eder.)*

---

# 5. Conditions That Can Reduce GNSS Reliability (GNSS Güvenilirliğini Azaltabilecek Koşullar)

GNSS performance may degrade when satellite signals are obstructed, reflected, weakened, or otherwise difficult for the receiver to use reliably. *(Uydu sinyalleri engellendiğinde, yansıtıldığında, zayıfladığında veya alıcının güvenilir şekilde kullanmasını zorlaştıran başka koşullar oluştuğunda GNSS performansı bozulabilir.)*

Dense urban environments can create limited sky visibility and multiple signal reflections from surrounding structures. *(Yoğun kentsel ortamlar sınırlı gökyüzü görüşü ve çevredeki yapılardan kaynaklanan çoklu sinyal yansımaları oluşturabilir.)*

Indoor environments can significantly reduce the direct visibility of navigation satellites. *(Kapalı ortamlar navigasyon uydularının doğrudan görünürlüğünü önemli ölçüde azaltabilir.)*

Tunnels, underground areas, covered structures, and environments surrounded by large obstacles can also interrupt normal GNSS reception. *(Tüneller, yer altı alanları, kapalı yapılar ve büyük engellerle çevrili ortamlar da normal GNSS alımını kesintiye uğratabilir.)*

Temporary receiver or environmental conditions may also produce low-quality position measurements even when GNSS has not been completely lost. *(Geçici alıcı veya çevresel koşullar, GNSS tamamen kaybolmamış olsa bile düşük kaliteli konum ölçümleri üretebilir.)*

For NAVGUARD, these conditions are treated as motivation for studying navigation continuity rather than as targets for recreating or manipulating real GNSS disruptions. *(NAVGUARD için bu koşullar, gerçek GNSS kesintilerini yeniden oluşturma veya manipüle etme hedefleri olarak değil navigasyon sürekliliğini araştırma motivasyonu olarak ele alınır.)*

---

# 6. GNSS-Denied Condition in NAVGUARD (NAVGUARD'da GNSS Kesintili Durum)

NAVGUARD will use a controlled software-based GNSS-denied condition during development and evaluation. *(NAVGUARD, geliştirme ve değerlendirme sırasında kontrollü yazılım tabanlı bir GNSS kesintili durum kullanacaktır.)*

The system will obtain a valid GNSS position before the test begins. *(Sistem, test başlamadan önce geçerli bir GNSS konumu elde edecektir.)*

After the simulated outage begins, GNSS measurements will no longer be provided to the NAVGUARD navigation estimator. *(Simüle edilmiş kesinti başladıktan sonra GNSS ölçümleri artık NAVGUARD navigasyon tahmin motoruna sağlanmayacaktır.)*

The physical GNSS receiver may continue operating in the background so that reference data can be recorded for experimental evaluation. *(Fiziksel GNSS alıcısı, deneysel değerlendirme için referans verilerinin kaydedilebilmesi amacıyla arka planda çalışmaya devam edebilir.)*

This design makes it possible to test GNSS-independent estimation safely and repeatedly without requiring hardware-based signal interruption. *(Bu tasarım, donanım tabanlı sinyal kesintisi gerektirmeden GNSS'ten bağımsız tahminin güvenli ve tekrarlanabilir şekilde test edilmesini mümkün kılar.)*

---

# 7. Position Continuity Problem (Konum Sürekliliği Problemi)

The central navigation requirement during GNSS loss is not immediate perfect positioning accuracy but continued estimation of user movement. *(GNSS kaybı sırasında temel navigasyon gereksinimi anında kusursuz konum doğruluğu değil, kullanıcı hareketinin tahmin edilmeye devam edilmesidir.)*

The system must estimate how far the user has moved and in which direction the movement occurred. *(Sistem, kullanıcının ne kadar hareket ettiğini ve hareketin hangi yönde gerçekleştiğini tahmin etmelidir.)*

These relative movement estimates must then be applied to the last reliable global position. *(Bu göreli hareket tahminleri daha sonra son güvenilir global konuma uygulanmalıdır.)*

Small errors in distance or direction estimation accumulate over time and cause the estimated trajectory to separate from the true trajectory. *(Mesafe veya yön tahminindeki küçük hatalar zamanla birikir ve tahmini rotanın gerçek rotadan ayrılmasına neden olur.)*

The primary technical challenge is therefore maintaining useful position continuity while limiting the rate at which this error grows. *(Bu nedenle temel teknik zorluk, hatanın büyüme hızını sınırlandırırken kullanışlı konum sürekliliğini korumaktır.)*

---

# 8. Dead Reckoning and Accumulated Drift (Ölü Hesaplama ve Biriken Sürüklenme)

Dead reckoning estimates a new position from a previously known position using estimated movement and direction. *(Ölü hesaplama, tahmin edilen hareket ve yönü kullanarak daha önce bilinen bir konumdan yeni bir konum tahmin eder.)*

This approach is suitable for maintaining relative navigation when external absolute positioning information is temporarily unavailable. *(Bu yaklaşım, harici mutlak konumlandırma bilgisi geçici olarak kullanılamadığında göreli navigasyonu sürdürmek için uygundur.)*

However, dead reckoning does not inherently correct its own accumulated errors. *(Ancak ölü hesaplama, biriken hatalarını doğası gereği kendi kendine düzeltmez.)*

An error introduced during one movement update influences later position estimates. *(Bir hareket güncellemesi sırasında oluşan hata daha sonraki konum tahminlerini etkiler.)*

As the navigation session continues, these errors accumulate and create position drift. *(Navigasyon oturumu devam ettikçe bu hatalar birikir ve konum sürüklenmesi oluşturur.)*

Reducing this drift is one of the central engineering problems of NAVGUARD. *(Bu sürüklenmeyi azaltmak NAVGUARD'ın temel mühendislik problemlerinden biridir.)*

---

# 9. Why Accelerometer Integration Alone Is Insufficient (Neden Yalnızca İvmeölçer Entegrasyonu Yeterli Değildir)

A smartphone accelerometer measures acceleration rather than position directly. *(Bir akıllı telefon ivmeölçeri konumu doğrudan ölçmek yerine ivmeyi ölçer.)*

In theory, acceleration can be integrated once to estimate velocity and integrated again to estimate position. *(Teorik olarak ivme bir kez integral alınarak hız, ikinci kez integral alınarak konum tahmin edilebilir.)*

In practice, small sensor bias, measurement noise, gravity estimation errors, timing inaccuracies, and device orientation errors can grow rapidly after repeated integration. *(Pratikte küçük sensör bias değerleri, ölçüm gürültüsü, yerçekimi tahmin hataları, zamanlama hataları ve cihaz yönelim hataları tekrarlanan integrasyon sonrasında hızla büyüyebilir.)*

For this reason, raw double integration of smartphone acceleration is not selected as the primary pedestrian positioning method for NAVGUARD. *(Bu nedenle akıllı telefon ivme verisinin doğrudan çift integrasyonu NAVGUARD için birincil yaya konumlandırma yöntemi olarak seçilmemiştir.)*

The project will instead investigate step-based displacement estimation combined with heading and additional movement information. *(Proje bunun yerine yön ve ek hareket bilgileriyle birleştirilmiş adım tabanlı yer değiştirme tahminini araştıracaktır.)*

---

# 10. Smartphone Sensor Limitations (Akıllı Telefon Sensörlerinin Sınırlamaları)

Smartphone sensors are low-cost embedded sensors designed for general mobile applications rather than precision inertial navigation. *(Akıllı telefon sensörleri, hassas ataletsel navigasyon yerine genel mobil uygulamalar için tasarlanmış düşük maliyetli gömülü sensörlerdir.)*

Their measurements contain noise, bias, drift, quantization effects, and hardware-dependent characteristics. *(Bu sensörlerin ölçümleri gürültü, bias, sürüklenme, kuantizasyon etkileri ve donanıma bağlı özellikler içerir.)*

Sensor characteristics may also differ between different phone models and even between different hardware revisions. *(Sensör özellikleri farklı telefon modelleri arasında ve hatta farklı donanım revizyonları arasında değişebilir.)*

Sampling frequency requested by software may not exactly match the sampling frequency delivered by the physical sensor. *(Yazılım tarafından talep edilen örnekleme frekansı, fiziksel sensör tarafından sağlanan örnekleme frekansıyla tam olarak eşleşmeyebilir.)*

Sensor timestamps, operating system scheduling, and application-level processing can introduce additional timing complexity. *(Sensör zaman damgaları, işletim sistemi zamanlaması ve uygulama seviyesindeki işlemler ek zamanlama karmaşıklığı oluşturabilir.)*

NAVGUARD must therefore be designed around measured device behavior rather than idealized sensor assumptions. *(Bu nedenle NAVGUARD, idealize edilmiş sensör varsayımları yerine ölçülmüş cihaz davranışına göre tasarlanmalıdır.)*

---

# 11. Device-Specific Motivation (Cihaza Özgü Motivasyon)

The Xiaomi Redmi Note 9 Pro is the primary physical platform for NAVGUARD development and evaluation. *(Xiaomi Redmi Note 9 Pro, NAVGUARD geliştirme ve değerlendirme sürecinin birincil fiziksel platformudur.)*

The project will therefore characterize the actual sensor behavior of this device before finalizing navigation parameters. *(Bu nedenle proje, navigasyon parametrelerini kesinleştirmeden önce bu cihazın gerçek sensör davranışını karakterize edecektir.)*

The software will not assume that theoretical sensor specifications automatically represent real runtime behavior. *(Yazılım, teorik sensör özelliklerinin gerçek çalışma zamanı davranışını otomatik olarak temsil ettiğini varsaymayacaktır.)*

This device-specific approach is necessary because navigation performance depends directly on the quality and timing characteristics of the measurements entering the estimator. *(Bu cihaza özgü yaklaşım gereklidir çünkü navigasyon performansı doğrudan tahmin motoruna giren ölçümlerin kalite ve zamanlama özelliklerine bağlıdır.)*

The Device Capability Audit will establish the validated hardware baseline before advanced algorithm development begins. *(Cihaz Yetenek Denetimi, gelişmiş algoritma geliştirme başlamadan önce doğrulanmış donanım temel referansını oluşturacaktır.)*

---

# 12. Heading Estimation Problem (Yön Tahmini Problemi)

Estimating travelled distance alone is insufficient for pedestrian navigation because the system must also determine the direction of movement. *(Yalnızca kat edilen mesafeyi tahmin etmek yaya navigasyonu için yeterli değildir çünkü sistem hareket yönünü de belirlemelidir.)*

A small heading error can produce a significant lateral position error as travelled distance increases. *(Küçük bir yön hatası, kat edilen mesafe arttıkça önemli bir yanal konum hatası oluşturabilir.)*

The gyroscope can provide short-term rotational information but gradually accumulates orientation drift. *(Jiroskop kısa süreli dönüş bilgisi sağlayabilir ancak zamanla yönelim sürüklenmesi biriktirir.)*

The magnetometer can provide an external directional reference but may be affected by nearby magnetic materials and electromagnetic conditions. *(Manyetometre harici bir yön referansı sağlayabilir ancak yakındaki manyetik malzemelerden ve elektromanyetik koşullardan etkilenebilir.)*

Orientation information derived from multiple sensors may therefore be more useful than depending on a single directional measurement source. *(Bu nedenle birden fazla sensörden türetilen yönelim bilgisi tek bir yön ölçüm kaynağına bağımlı olmaktan daha kullanışlı olabilir.)*

NAVGUARD must account for both short-term rotational accuracy and long-term directional stability. *(NAVGUARD hem kısa süreli dönüş doğruluğunu hem de uzun süreli yön kararlılığını dikkate almalıdır.)*

---

# 13. Step Detection Problem (Adım Tespiti Problemi)

Pedestrian Dead Reckoning requires the system to determine when valid pedestrian steps occur. *(Yaya Ölü Hesaplama, sistemin geçerli yaya adımlarının ne zaman gerçekleştiğini belirlemesini gerektirir.)*

Simple acceleration peaks do not always correspond to valid walking steps. *(Basit ivme tepe noktaları her zaman geçerli yürüyüş adımlarına karşılık gelmez.)*

Device movements unrelated to walking can produce acceleration patterns that resemble steps. *(Yürüyüşle ilişkili olmayan cihaz hareketleri adımlara benzeyen ivme örüntüleri oluşturabilir.)*

Failure to detect a real step causes travelled distance to be underestimated. *(Gerçek bir adımın tespit edilememesi kat edilen mesafenin olduğundan az tahmin edilmesine neden olur.)*

Detecting a false step causes the estimated position to move even though no corresponding pedestrian displacement occurred. *(Yanlış bir adımın tespit edilmesi, karşılık gelen bir yaya yer değiştirmesi gerçekleşmediği halde tahmini konumun hareket etmesine neden olur.)*

Reliable step detection is therefore a fundamental requirement for the PDR component. *(Bu nedenle güvenilir adım tespiti PDR bileşeni için temel bir gereksinimdir.)*

---

# 14. Step Length Estimation Problem (Adım Uzunluğu Tahmin Problemi)

Counting steps alone does not provide travelled distance because different steps have different lengths. *(Yalnızca adımları saymak kat edilen mesafeyi sağlamaz çünkü farklı adımlar farklı uzunluklara sahiptir.)*

A fixed step length can provide a simple baseline but cannot fully represent changes in walking speed, running, cadence, or individual movement characteristics. *(Sabit bir adım uzunluğu basit bir temel referans sağlayabilir ancak yürüme hızı, koşma, kadans veya bireysel hareket özelliklerindeki değişiklikleri tam olarak temsil edemez.)*

Repeated step length estimation errors accumulate directly into PDR position error. *(Tekrarlanan adım uzunluğu tahmin hataları doğrudan PDR konum hatasında birikir.)*

NAVGUARD is therefore motivated to investigate whether sensor-derived features and machine learning can improve step length estimation over a simple constant-length assumption. *(Bu nedenle NAVGUARD, sensörlerden türetilen özelliklerin ve makine öğrenmesinin basit sabit uzunluk varsayımına göre adım uzunluğu tahminini iyileştirip iyileştiremeyeceğini araştırmayı amaçlar.)*

---

# 15. Human Motion Variability Problem (İnsan Hareketi Değişkenliği Problemi)

Human motion is not constant throughout a navigation session. *(İnsan hareketi bir navigasyon oturumu boyunca sabit değildir.)*

A user may remain stationary, begin walking, increase walking speed, run, stop, or change direction. *(Bir kullanıcı sabit durabilir, yürümeye başlayabilir, yürüme hızını artırabilir, koşabilir, durabilir veya yön değiştirebilir.)*

Applying the same motion assumptions to every sensor window can reduce navigation accuracy. *(Her sensör penceresine aynı hareket varsayımlarını uygulamak navigasyon doğruluğunu azaltabilir.)*

A navigation system can potentially improve its behavior if it first determines the current motion state. *(Bir navigasyon sistemi öncelikle mevcut hareket durumunu belirlerse davranışını potansiyel olarak iyileştirebilir.)*

This motivates the use of an artificial intelligence model for motion classification within NAVGUARD. *(Bu durum NAVGUARD içerisinde hareket sınıflandırması için bir yapay zekâ modeli kullanılmasını motive eder.)*

---

# 16. Why Artificial Intelligence Is Relevant (Yapay Zekâ Neden İlgilidir)

NAVGUARD contains sensor patterns that vary over time and may be difficult to represent using only fixed thresholds. *(NAVGUARD, zaman içerisinde değişen ve yalnızca sabit eşiklerle temsil edilmesi zor olabilecek sensör örüntüleri içerir.)*

Walking, running, turning, and stationary states produce different temporal patterns across accelerometer and gyroscope measurements. *(Yürüme, koşma, dönme ve sabit durma durumları ivmeölçer ve jiroskop ölçümleri üzerinde farklı zamansal örüntüler üretir.)*

Machine learning models can learn relationships between these multivariate time-series patterns and user motion states. *(Makine öğrenmesi modelleri bu çok değişkenli zaman serisi örüntüleri ile kullanıcı hareket durumları arasındaki ilişkileri öğrenebilir.)*

The AI model can therefore provide contextual information to the navigation system rather than directly predicting global coordinates. *(Bu nedenle yapay zekâ modeli doğrudan global koordinatları tahmin etmek yerine navigasyon sistemine bağlamsal bilgi sağlayabilir.)*

This design gives artificial intelligence a defined engineering role inside the navigation pipeline. *(Bu tasarım yapay zekâya navigasyon hattı içerisinde tanımlı bir mühendislik rolü verir.)*

NAVGUARD will evaluate whether this additional context produces measurable improvements in navigation performance. *(NAVGUARD, bu ek bağlamın navigasyon performansında ölçülebilir iyileştirmeler üretip üretmediğini değerlendirecektir.)*

---

# 17. Why a Lightweight 1D-CNN Is Considered (Neden Hafif Bir 1D-CNN Değerlendirilmektedir)

The primary artificial intelligence problem in NAVGUARD is based on time-series sensor measurements rather than static images. *(NAVGUARD'daki temel yapay zekâ problemi statik görüntüler yerine zaman serisi sensör ölçümlerine dayanmaktadır.)*

A one-dimensional convolutional neural network can learn local temporal patterns across sequential sensor measurements. *(Bir boyutlu evrişimsel sinir ağı, ardışık sensör ölçümleri içerisindeki yerel zamansal örüntüleri öğrenebilir.)*

A lightweight 1D-CNN can also be designed with a sufficiently small computational footprint for on-device inference. *(Hafif bir 1D-CNN aynı zamanda cihaz üzerinde çıkarım için yeterince küçük hesaplama yüküne sahip olacak şekilde tasarlanabilir.)*

The final model choice will not be made solely on theoretical preference. *(Nihai model seçimi yalnızca teorik tercihe göre yapılmayacaktır.)*

Traditional machine learning baselines and candidate neural network models will be compared experimentally before deployment. *(Geleneksel makine öğrenmesi temel modelleri ve aday sinir ağı modelleri dağıtımdan önce deneysel olarak karşılaştırılacaktır.)*

---

# 18. Visual-Inertial Tracking Motivation (Görsel-Ataletsel Takip Motivasyonu)

PDR estimates movement using pedestrian steps and heading, but it does not directly observe the geometric movement of the device through the environment. *(PDR hareketi yaya adımları ve yön kullanarak tahmin eder ancak cihazın ortam içerisindeki geometrik hareketini doğrudan gözlemlemez.)*

Camera-based tracking can provide an additional source of relative displacement information by observing changes in visual features between frames. *(Kamera tabanlı takip, kareler arasındaki görsel özellik değişikliklerini gözlemleyerek ek bir göreli yer değiştirme bilgisi kaynağı sağlayabilir.)*

Visual information has different error characteristics from purely step-based pedestrian navigation. *(Görsel bilgi, yalnızca adım tabanlı yaya navigasyonundan farklı hata özelliklerine sahiptir.)*

Combining information sources with different strengths and weaknesses may produce a more robust estimate than depending on either source independently. *(Farklı güçlü ve zayıf yönlere sahip bilgi kaynaklarını birleştirmek, kaynaklardan herhangi birine bağımsız olarak güvenmekten daha dayanıklı bir tahmin üretebilir.)*

This motivates the evaluation of ARCore visual-inertial tracking as an additional relative movement source within NAVGUARD. *(Bu durum, ARCore görsel-ataletsel takibinin NAVGUARD içerisinde ek bir göreli hareket kaynağı olarak değerlendirilmesini motive eder.)*

---

# 19. Visual Tracking Limitations (Görsel Takibin Sınırlamaları)

Visual tracking is not reliable under every environmental condition. *(Görsel takip her çevresel koşul altında güvenilir değildir.)*

Poor lighting can reduce the quality of camera observations. *(Yetersiz aydınlatma kamera gözlemlerinin kalitesini azaltabilir.)*

Rapid camera movement can make visual feature tracking more difficult. *(Hızlı kamera hareketi görsel özellik takibini daha zor hale getirebilir.)*

Scenes containing limited visual texture may provide insufficient stable features for reliable tracking. *(Sınırlı görsel doku içeren sahneler güvenilir takip için yeterli kararlı özellik sağlamayabilir.)*

Temporary visual tracking degradation must therefore not cause the entire NAVGUARD navigation pipeline to fail. *(Bu nedenle geçici görsel takip bozulması tüm NAVGUARD navigasyon hattının başarısız olmasına neden olmamalıdır.)*

This limitation directly motivates a multi-source and confidence-aware navigation design. *(Bu sınırlama doğrudan çok kaynaklı ve güven farkındalıklı bir navigasyon tasarımını motive eder.)*

---

# 20. Single-Sensor Reliability Problem (Tek Sensör Güvenilirliği Problemi)

No individual smartphone sensor can be assumed to provide perfect navigation information continuously. *(Hiçbir bireysel akıllı telefon sensörünün sürekli olarak kusursuz navigasyon bilgisi sağladığı varsayılamaz.)*

Gyroscope measurements can drift over time. *(Jiroskop ölçümleri zamanla sürüklenebilir.)*

Magnetometer measurements can be disturbed by the surrounding environment. *(Manyetometre ölçümleri çevredeki ortam tarafından bozulabilir.)*

Accelerometer measurements contain motion-independent effects and measurement noise that require preprocessing. *(İvmeölçer ölçümleri ön işleme gerektiren hareketten bağımsız etkiler ve ölçüm gürültüsü içerir.)*

Visual tracking quality can decrease when environmental conditions become unfavorable. *(Çevresel koşullar elverişsiz hale geldiğinde görsel takip kalitesi düşebilir.)*

GNSS itself can vary in accuracy and availability. *(GNSS'in kendisi de doğruluk ve kullanılabilirlik açısından değişkenlik gösterebilir.)*

This means that reliable navigation should be based on the combined behavior of multiple sources rather than blind trust in one measurement stream. *(Bu durum, güvenilir navigasyonun tek bir ölçüm akışına körü körüne güvenmek yerine birden fazla kaynağın birleşik davranışına dayanması gerektiği anlamına gelir.)*

---

# 21. Sensor Fusion Motivation (Sensör Füzyonu Motivasyonu)

Sensor fusion is motivated by the complementary characteristics of the available navigation information sources. *(Sensör füzyonu, mevcut navigasyon bilgi kaynaklarının birbirini tamamlayan özelliklerinden kaynaklanan bir gereksinimdir.)*

One sensor may provide useful information in conditions where another sensor becomes unreliable. *(Bir sensör, başka bir sensörün güvenilmez hale geldiği koşullarda kullanışlı bilgi sağlayabilir.)*

Short-term gyroscope information may complement long-term directional references. *(Kısa süreli jiroskop bilgisi uzun süreli yön referanslarını tamamlayabilir.)*

PDR displacement estimates may continue operating when visual tracking is temporarily unavailable. *(PDR yer değiştirme tahminleri görsel takip geçici olarak kullanılamadığında çalışmaya devam edebilir.)*

Visual-inertial displacement may provide an additional correction source when PDR begins to drift. *(Görsel-ataletsel yer değiştirme, PDR sürüklenmeye başladığında ek bir düzeltme kaynağı sağlayabilir.)*

A properly designed fusion mechanism can use the strengths of each source while reducing the effect of unreliable measurements. *(Doğru tasarlanmış bir füzyon mekanizması, güvenilmez ölçümlerin etkisini azaltırken her kaynağın güçlü yönlerini kullanabilir.)*

This is one of the primary technical motivations behind the NAVGUARD architecture. *(Bu, NAVGUARD mimarisinin arkasındaki temel teknik motivasyonlardan biridir.)*

---

# 22. Sensor Confidence Motivation (Sensör Güvenilirlik Motivasyonu)

Sensor measurements should not automatically be treated as equally reliable at all times. *(Sensör ölçümleri her zaman otomatik olarak eşit derecede güvenilir kabul edilmemelidir.)*

A magnetometer affected by environmental disturbance should not have the same influence as a stable measurement source. *(Çevresel bozulmadan etkilenen bir manyetometre kararlı bir ölçüm kaynağıyla aynı etkiye sahip olmamalıdır.)*

ARCore tracking should contribute less to the final estimate when its tracking state becomes degraded. *(ARCore takip durumu bozulduğunda nihai tahmine daha az katkıda bulunmalıdır.)*

GNSS accuracy information should also be considered before treating a measurement as a reliable absolute position reference. *(Bir ölçüm güvenilir bir mutlak konum referansı olarak kabul edilmeden önce GNSS doğruluk bilgisi de dikkate alınmalıdır.)*

NAVGUARD is therefore motivated to include a lightweight quality and confidence mechanism around its major sensor sources. *(Bu nedenle NAVGUARD, temel sensör kaynaklarının çevresinde hafif bir kalite ve güven mekanizması içermeyi amaçlamaktadır.)*

---

# 23. Uncertainty Problem (Belirsizlik Problemi)

A GNSS-denied navigation estimate is inherently uncertain. *(GNSS kesintili bir navigasyon tahmini doğası gereği belirsizlik içerir.)*

The estimated coordinate should therefore not be presented as if it were an exact measurement. *(Bu nedenle tahmini koordinat kesin bir ölçümmüş gibi sunulmamalıdır.)*

Position uncertainty is expected to increase as the duration and distance travelled without an absolute position correction increase. *(Mutlak konum düzeltmesi olmadan geçen süre ve kat edilen mesafe arttıkça konum belirsizliğinin artması beklenmektedir.)*

A navigation system that reports its uncertainty is more informative than a system that only reports a coordinate. *(Belirsizliğini raporlayan bir navigasyon sistemi yalnızca koordinat raporlayan bir sistemden daha bilgilendiricidir.)*

NAVGUARD is therefore motivated to estimate or represent confidence together with its position output. *(Bu nedenle NAVGUARD, konum çıktısıyla birlikte güven seviyesini tahmin etmeyi veya temsil etmeyi amaçlar.)*

---

# 24. Why Offline Operation Matters (Çevrimdışı Çalışma Neden Önemlidir)

A navigation continuity system should not require network connectivity to compensate for the loss of another external positioning dependency. *(Bir navigasyon sürekliliği sistemi, başka bir harici konumlandırma bağımlılığının kaybını telafi etmek için ağ bağlantısına ihtiyaç duymamalıdır.)*

Core sensor processing and position estimation should therefore remain available even when the mobile device is offline. *(Bu nedenle temel sensör işleme ve konum tahmini mobil cihaz çevrimdışıyken bile kullanılabilir kalmalıdır.)*

On-device processing also reduces communication latency between sensor acquisition and navigation decisions. *(Cihaz üzerindeki işlem, sensör veri toplama ile navigasyon kararları arasındaki iletişim gecikmesini de azaltır.)*

Local AI inference prevents the motion classification component from depending on an external cloud service. *(Yerel yapay zekâ çıkarımı, hareket sınıflandırma bileşeninin harici bir bulut hizmetine bağımlı olmasını önler.)*

This motivates the Edge AI architecture planned for NAVGUARD. *(Bu durum NAVGUARD için planlanan Edge AI mimarisini motive eder.)*

---

# 25. Why a Mobile Prototype Is Appropriate (Neden Mobil Bir Prototip Uygundur)

A modern Android smartphone already contains several sensors required for experimental pedestrian navigation research. *(Modern bir Android akıllı telefon deneysel yaya navigasyon araştırması için gerekli olan çeşitli sensörleri zaten içerir.)*

The same device provides GNSS, inertial measurements, orientation sensors, camera input, local processing capability, storage, and a user interface. *(Aynı cihaz GNSS, ataletsel ölçümler, yönelim sensörleri, kamera girdisi, yerel işlem yeteneği, depolama ve kullanıcı arayüzü sağlar.)*

This makes the smartphone a self-contained experimental platform for collecting data, executing algorithms, running AI models, displaying results, and recording test sessions. *(Bu durum akıllı telefonu veri toplama, algoritmaları çalıştırma, yapay zekâ modellerini yürütme, sonuçları gösterme ve test oturumlarını kaydetme için bağımsız bir deney platformu haline getirir.)*

Using existing smartphone hardware also keeps the initial project scope independent from additional sensor purchases. *(Mevcut akıllı telefon donanımını kullanmak aynı zamanda başlangıç proje kapsamını ek sensör satın alımlarından bağımsız tutar.)*

---

# 26. Engineering Motivation (Mühendislik Motivasyonu)

NAVGUARD provides an opportunity to study the complete path from physical sensor measurements to a final navigation estimate. *(NAVGUARD, fiziksel sensör ölçümlerinden nihai navigasyon tahminine kadar olan tüm süreci inceleme fırsatı sağlar.)*

The project requires interaction between mobile software, signal processing, coordinate mathematics, state estimation, machine learning, computer vision, and experimental testing. *(Proje mobil yazılım, sinyal işleme, koordinat matematiği, durum tahmini, makine öğrenmesi, bilgisayarlı görü ve deneysel testler arasında etkileşim gerektirir.)*

The success of the project cannot be determined only by whether the application interface works. *(Projenin başarısı yalnızca uygulama arayüzünün çalışıp çalışmadığına göre belirlenemez.)*

The navigation output must be compared quantitatively with reference data. *(Navigasyon çıktısı referans verilerle nicel olarak karşılaştırılmalıdır.)*

This makes NAVGUARD an engineering measurement problem as well as a software development project. *(Bu durum NAVGUARD'ı bir yazılım geliştirme projesi olmasının yanında bir mühendislik ölçüm problemi haline getirir.)*

---

# 27. Artificial Intelligence Motivation (Yapay Zekâ Motivasyonu)

Artificial intelligence is included because user motion introduces nonlinear and time-dependent patterns into smartphone sensor measurements. *(Yapay zekâ projeye dahil edilmiştir çünkü kullanıcı hareketi akıllı telefon sensör ölçümlerinde doğrusal olmayan ve zamana bağlı örüntüler oluşturur.)*

A learned model may distinguish motion conditions that would otherwise require numerous manually defined thresholds and rules. *(Öğrenilmiş bir model, aksi halde çok sayıda elle tanımlanmış eşik ve kural gerektirecek hareket koşullarını ayırt edebilir.)*

Motion-aware navigation can potentially adapt step detection or step length assumptions according to the current activity. *(Hareket farkındalıklı navigasyon, adım tespiti veya adım uzunluğu varsayımlarını mevcut aktiviteye göre potansiyel olarak uyarlayabilir.)*

The project will therefore evaluate AI as a navigation-support component rather than use AI only for presentation purposes. *(Bu nedenle proje yapay zekâyı yalnızca gösterim amacıyla kullanmak yerine navigasyonu destekleyen bir bileşen olarak değerlendirecektir.)*

Any AI component retained in the final system must demonstrate measurable utility or justified engineering value. *(Nihai sistemde tutulacak herhangi bir yapay zekâ bileşeni ölçülebilir fayda veya gerekçelendirilmiş mühendislik değeri göstermelidir.)*

---

# 28. Research Motivation (Araştırma Motivasyonu)

The project creates a controlled environment for comparing multiple approaches to GNSS-denied pedestrian navigation on the same mobile device. *(Proje, aynı mobil cihaz üzerinde GNSS kesintili yaya navigasyonuna yönelik birden fazla yaklaşımı karşılaştırmak için kontrollü bir ortam oluşturur.)*

A basic PDR configuration can establish a baseline level of performance. *(Temel bir PDR yapılandırması referans performans seviyesini oluşturabilir.)*

Heading fusion can then be evaluated to determine whether directional stability improves. *(Daha sonra yön kararlılığının iyileşip iyileşmediğini belirlemek için yön füzyonu değerlendirilebilir.)*

Visual-inertial information can be added to measure its contribution to reducing drift. *(Sürüklenmeyi azaltmaya olan katkısını ölçmek için görsel-ataletsel bilgi eklenebilir.)*

Artificial intelligence can then be incorporated to determine whether motion-aware estimation provides additional measurable benefit. *(Daha sonra hareket farkındalıklı tahminin ek ölçülebilir fayda sağlayıp sağlamadığını belirlemek için yapay zekâ dahil edilebilir.)*

This progressive comparison allows conclusions to be based on measured evidence rather than assumptions. *(Bu aşamalı karşılaştırma, sonuçların varsayımlar yerine ölçülmüş kanıtlara dayanmasını sağlar.)*

---

# 29. Relevance to Resilient and Autonomous Systems (Dayanıklı ve Otonom Sistemlerle İlişkisi)

Navigation continuity is a fundamental requirement for many autonomous and semi-autonomous systems. *(Navigasyon sürekliliği birçok otonom ve yarı otonom sistem için temel bir gereksinimdir.)*

Systems that depend on a single external positioning source can become vulnerable to environmental or operational loss of that source. *(Tek bir harici konumlandırma kaynağına bağımlı sistemler, bu kaynağın çevresel veya operasyonel olarak kaybedilmesine karşı savunmasız hale gelebilir.)*

Sensor redundancy, sensor fusion, local inference, uncertainty estimation, and fallback navigation are general engineering concepts used to improve system resilience. *(Sensör yedekliliği, sensör füzyonu, yerel çıkarım, belirsizlik tahmini ve yedek navigasyon sistem dayanıklılığını artırmak için kullanılan genel mühendislik kavramlarıdır.)*

NAVGUARD investigates these concepts at the scale of a standard Android mobile device. *(NAVGUARD bu kavramları standart bir Android mobil cihaz ölçeğinde araştırır.)*

The project does not attempt to reproduce a certified aviation, military, or industrial inertial navigation system. *(Proje sertifikalı bir havacılık, askeri veya endüstriyel ataletsel navigasyon sistemini yeniden üretmeyi amaçlamaz.)*

Instead, it provides an accessible research prototype for studying the underlying engineering principles. *(Bunun yerine temel mühendislik prensiplerini incelemek için erişilebilir bir araştırma prototipi sağlar.)*

---

# 30. Why Additional Hardware Is Not Required for the Initial Prototype (İlk Prototip İçin Neden Ek Donanım Gerekmemektedir)

The initial NAVGUARD prototype will use sensors already integrated into the target smartphone. *(İlk NAVGUARD prototipi hedef akıllı telefona zaten entegre edilmiş sensörleri kullanacaktır.)*

This allows the project to focus on software architecture, signal interpretation, artificial intelligence, and sensor fusion rather than hardware integration. *(Bu durum projenin donanım entegrasyonu yerine yazılım mimarisi, sinyal yorumlama, yapay zekâ ve sensör füzyonuna odaklanmasını sağlar.)*

Avoiding external hardware also improves portability and reduces development complexity within the 24-business-day schedule. *(Harici donanımdan kaçınmak aynı zamanda taşınabilirliği artırır ve 24 iş günlük takvim içerisinde geliştirme karmaşıklığını azaltır.)*

External high-grade IMU or GNSS hardware may be considered only as future research equipment and is not required for the defined project scope. *(Harici yüksek seviye IMU veya GNSS donanımı yalnızca gelecekteki araştırma ekipmanı olarak değerlendirilebilir ve tanımlanan proje kapsamı için gerekli değildir.)*

---

# 31. Evaluation Motivation (Değerlendirme Motivasyonu)

A visual demonstration of an estimated path is not sufficient to determine whether NAVGUARD is technically successful. *(Tahmini bir rotanın görsel gösterimi NAVGUARD'ın teknik olarak başarılı olup olmadığını belirlemek için yeterli değildir.)*

The estimated position must be compared against an independent reference. *(Tahmini konum bağımsız bir referansla karşılaştırılmalıdır.)*

Controlled GNSS-denied simulation allows the GNSS receiver to provide this reference without influencing the estimator. *(Kontrollü GNSS kesinti simülasyonu, GNSS alıcısının tahmin motorunu etkilemeden bu referansı sağlamasına olanak tanır.)*

This makes it possible to calculate position error, drift, final displacement error, and other quantitative metrics. *(Bu durum konum hatası, sürüklenme, nihai yer değiştirme hatası ve diğer nicel metriklerin hesaplanmasını mümkün kılar.)*

The project is therefore designed around experimental validation from the beginning rather than adding evaluation only after implementation is complete. *(Bu nedenle proje değerlendirmeyi yalnızca geliştirme tamamlandıktan sonra eklemek yerine baştan itibaren deneysel doğrulama etrafında tasarlanmıştır.)*

---

# 32. Formalized Problem Input (Biçimsel Problem Girdisi)

The system begins from a known global geographic position obtained from reliable GNSS measurements. *(Sistem güvenilir GNSS ölçümlerinden elde edilen bilinen bir global coğrafi konumdan başlar.)*

After the GNSS-denied phase begins, the navigation estimator receives time-varying measurements from available onboard sensors and visual-inertial tracking components. *(GNSS kesintili aşama başladıktan sonra navigasyon tahmin motoru mevcut cihaz içi sensörlerden ve görsel-ataletsel takip bileşenlerinden zamana bağlı ölçümler alır.)*

The estimator does not receive GNSS position updates during this phase. *(Tahmin motoru bu aşamada GNSS konum güncellemelerini almaz.)*

---

# 33. Formalized Problem Output (Biçimsel Problem Çıktısı)

The primary output is an estimated pedestrian trajectory beginning from the last reliable GNSS position. *(Birincil çıktı, son güvenilir GNSS konumundan başlayan tahmini bir yaya rotasıdır.)*

Each position estimate should be associated with a timestamp. *(Her konum tahmini bir zaman damgasıyla ilişkilendirilmelidir.)*

The system should also provide information describing the confidence or uncertainty associated with the estimated position whenever feasible. *(Sistem ayrıca mümkün olduğunda tahmini konumla ilişkili güven veya belirsizliği açıklayan bilgi sağlamalıdır.)*

Additional outputs include motion state, heading, detected steps, estimated travelled distance, sensor quality indicators, and navigation mode. *(Ek çıktılar hareket durumu, yön, tespit edilen adımlar, tahmini kat edilen mesafe, sensör kalite göstergeleri ve navigasyon modunu içerir.)*

---

# 34. Formalized Engineering Problem (Biçimsel Mühendislik Problemi)

Given a reliable initial geographic position and a sequence of smartphone sensor measurements, estimate the user's subsequent pedestrian trajectory while GNSS measurements are unavailable to the navigation estimator. *(Güvenilir bir başlangıç coğrafi konumu ve bir akıllı telefon sensör ölçümleri dizisi verildiğinde, GNSS ölçümleri navigasyon tahmin motoru tarafından kullanılamazken kullanıcının sonraki yaya rotasını tahmin et.)*

The estimator should minimize accumulated position error while operating entirely on the target Android device during the navigation session. *(Tahmin motoru, navigasyon oturumu sırasında tamamen hedef Android cihaz üzerinde çalışırken biriken konum hatasını en aza indirmelidir.)*

The system should degrade gracefully when one information source becomes temporarily unreliable or unavailable. *(Bir bilgi kaynağı geçici olarak güvenilmez veya kullanılamaz hale geldiğinde sistem kontrollü şekilde performans kaybetmelidir.)*

The estimator should provide measurable outputs that can be compared against an independent GNSS reference after the session. *(Tahmin motoru, oturum sonrasında bağımsız bir GNSS referansıyla karşılaştırılabilecek ölçülebilir çıktılar sağlamalıdır.)*

---

# 35. Desired System Behavior (İstenen Sistem Davranışı)

NAVGUARD should operate normally while reliable GNSS information is available. *(NAVGUARD, güvenilir GNSS bilgisi mevcutken normal şekilde çalışmalıdır.)*

When the GNSS-denied condition begins, the system should transition to local motion-based positioning without terminating the navigation session. *(GNSS kesintili durum başladığında sistem navigasyon oturumunu sonlandırmadan yerel hareket tabanlı konumlandırmaya geçmelidir.)*

The estimated position should continue to update while the user moves. *(Kullanıcı hareket ederken tahmini konum güncellenmeye devam etmelidir.)*

The system should stop accumulating pedestrian displacement when the user is confidently classified as stationary. *(Kullanıcı güvenilir şekilde sabit olarak sınıflandırıldığında sistem yaya yer değiştirmesi biriktirmeyi durdurmalıdır.)*

The system should adapt its movement interpretation when the detected motion state changes. *(Tespit edilen hareket durumu değiştiğinde sistem hareket yorumlamasını uyarlamalıdır.)*

The system should reduce dependence on any navigation source whose quality becomes degraded. *(Sistem, kalitesi bozulmuş herhangi bir navigasyon kaynağına olan bağımlılığını azaltmalıdır.)*

The system should maintain a record of both estimated and reference trajectories for later analysis. *(Sistem daha sonraki analizler için hem tahmini hem de referans rotaların kaydını tutmalıdır.)*

---

# 36. Undesired System Behavior (İstenmeyen Sistem Davranışı)

The estimated position should not continue moving significantly while the device and user are stationary. *(Cihaz ve kullanıcı sabit durumdayken tahmini konum önemli ölçüde hareket etmeye devam etmemelidir.)*

A temporary ARCore tracking failure should not terminate the entire navigation session. *(Geçici bir ARCore takip başarısızlığı tüm navigasyon oturumunu sonlandırmamalıdır.)*

A temporary magnetometer disturbance should not immediately cause an uncontrolled heading change in the final navigation output. *(Geçici bir manyetometre bozulması nihai navigasyon çıktısında kontrolsüz bir yön değişikliğine anında neden olmamalıdır.)*

The AI model should not be required to access a remote cloud service during navigation. *(Yapay zekâ modelinin navigasyon sırasında uzak bir bulut hizmetine erişmesi gerekmemelidir.)*

The GNSS measurements reserved for ground-truth evaluation must not leak into the GNSS-denied position estimator. *(Gerçek referans değerlendirmesi için ayrılan GNSS ölçümleri GNSS kesintili konum tahmin motoruna sızmamalıdır.)*

The application should not present high-confidence position information when the estimator has insufficient reliable evidence. *(Tahmin motorunun yeterli güvenilir kanıtı olmadığında uygulama yüksek güvenli konum bilgisi sunmamalıdır.)*

---

# 37. Main Sources of Expected Error (Beklenen Temel Hata Kaynakları)

The primary expected error sources include step detection error, step length estimation error, heading error, sensor noise, sensor bias, timing error, coordinate transformation error, and visual tracking drift. *(Beklenen temel hata kaynakları; adım tespit hatası, adım uzunluğu tahmin hatası, yön hatası, sensör gürültüsü, sensör bias değeri, zamanlama hatası, koordinat dönüşüm hatası ve görsel takip sürüklenmesini içerir.)*

Errors from different components may interact with each other rather than remain independent. *(Farklı bileşenlerden kaynaklanan hatalar birbirinden bağımsız kalmak yerine birbirleriyle etkileşebilir.)*

For example, a correct step length combined with an incorrect heading still produces an incorrect position update. *(Örneğin doğru bir adım uzunluğunun yanlış bir yönle birleştirilmesi yine hatalı bir konum güncellemesi üretir.)*

Likewise, highly accurate motion classification does not guarantee accurate navigation if the underlying displacement model is poorly calibrated. *(Benzer şekilde yüksek doğruluklu hareket sınıflandırması, temel yer değiştirme modeli kötü kalibre edilmişse doğru navigasyonu garanti etmez.)*

The project must therefore evaluate both individual component performance and end-to-end navigation performance. *(Bu nedenle proje hem bireysel bileşen performansını hem de uçtan uca navigasyon performansını değerlendirmelidir.)*

---

# 38. Main Technical Challenge (Temel Teknik Zorluk)

The primary technical challenge is not reading the smartphone sensors but converting imperfect sensor measurements into a stable and useful navigation estimate. *(Temel teknik zorluk akıllı telefon sensörlerini okumak değil, kusurlu sensör ölçümlerini kararlı ve kullanışlı bir navigasyon tahminine dönüştürmektir.)*

Sensor data acquisition alone does not solve the navigation problem. *(Yalnızca sensör verisi toplamak navigasyon problemini çözmez.)*

The measurements must be synchronized, filtered, interpreted, transformed into a common reference frame, and combined appropriately. *(Ölçümler senkronize edilmeli, filtrelenmeli, yorumlanmalı, ortak bir referans koordinat sistemine dönüştürülmeli ve uygun şekilde birleştirilmelidir.)*

The final system must also remain computationally practical on the target smartphone. *(Nihai sistem aynı zamanda hedef akıllı telefon üzerinde hesaplama açısından uygulanabilir kalmalıdır.)*

This combination of accuracy, robustness, and mobile resource constraints defines the central engineering difficulty of NAVGUARD. *(Doğruluk, dayanıklılık ve mobil kaynak kısıtlarının bu birleşimi NAVGUARD'ın temel mühendislik zorluğunu tanımlar.)*

---

# 39. Project Motivation Summary (Proje Motivasyonu Özeti)

NAVGUARD is motivated by the need to investigate navigation continuity when the primary absolute positioning source becomes temporarily unavailable. *(NAVGUARD, birincil mutlak konumlandırma kaynağı geçici olarak kullanılamaz hale geldiğinde navigasyon sürekliliğini araştırma ihtiyacından doğmuştur.)*

A standard Android smartphone already provides multiple independent sources of motion and environmental information that may partially compensate for this loss. *(Standart bir Android akıllı telefon, bu kaybı kısmen telafi edebilecek birden fazla bağımsız hareket ve çevresel bilgi kaynağını zaten sağlar.)*

No single onboard source is sufficiently reliable to solve the problem alone under all conditions. *(Hiçbir cihaz içi kaynak tüm koşullar altında problemi tek başına çözebilecek kadar güvenilir değildir.)*

This creates a natural engineering problem involving sensor fusion, uncertainty, motion understanding, and adaptive estimation. *(Bu durum sensör füzyonu, belirsizlik, hareket anlayışı ve uyarlanabilir tahmini içeren doğal bir mühendislik problemi oluşturur.)*

Artificial intelligence is introduced where learned motion patterns can provide useful context to conventional navigation algorithms. *(Yapay zekâ, öğrenilmiş hareket örüntülerinin geleneksel navigasyon algoritmalarına kullanışlı bağlam sağlayabileceği noktalarda sisteme dahil edilir.)*

The mobile device is selected as both the experimental sensor platform and the final execution environment. *(Mobil cihaz hem deneysel sensör platformu hem de nihai çalışma ortamı olarak seçilmiştir.)*

The final objective is to determine through measurable experiments how much useful navigation capability can be preserved using only the resources available on the mobile device. *(Nihai amaç, yalnızca mobil cihaz üzerinde bulunan kaynaklar kullanılarak ne kadar kullanışlı navigasyon yeteneğinin korunabileceğini ölçülebilir deneylerle belirlemektir.)*

---

# 40. Problem Definition Statement (Problem Tanımı Bildirimi)

**NAVGUARD addresses the problem of maintaining short-term pedestrian position continuity on an Android smartphone when reliable GNSS position measurements are temporarily unavailable to the navigation estimator.** *(NAVGUARD, güvenilir GNSS konum ölçümleri navigasyon tahmin motoru tarafından geçici olarak kullanılamadığında bir Android akıllı telefonda kısa süreli yaya konum sürekliliğini koruma problemini ele alır.)*

**The project investigates whether pedestrian dead reckoning, multi-sensor heading estimation, visual-inertial tracking, sensor fusion, and on-device artificial intelligence can collectively reduce accumulated navigation drift compared with simpler smartphone-based dead reckoning approaches.** *(Proje; yaya ölü hesaplama, çoklu sensör yön tahmini, görsel-ataletsel takip, sensör füzyonu ve cihaz üzerinde çalışan yapay zekânın daha basit akıllı telefon tabanlı ölü hesaplama yaklaşımlarına kıyasla biriken navigasyon sürüklenmesini birlikte azaltıp azaltamayacağını araştırır.)*

---

# 41. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Completed *(Doküman Durumu: Tamamlandı)*

**Project Phase:** Flutter Android Bootstrap Completed; Navigation Subsystems Not Started *(Proje Aşaması: Flutter Android Bootstrap Tamamlandı; Navigasyon Alt Sistemleri Başlamadı)*

**Implementation Impact:** This document defines the problem context but does not authorize specific implementation choices by itself. *(Uygulamaya Etkisi: Bu doküman problem bağlamını tanımlar ancak tek başına belirli uygulama tercihlerini yetkilendirmez.)*

**Next Documentation Item:** 03 — Project Scope & Boundaries *(Sonraki Dokümantasyon Öğesi: 03 — Proje Kapsamı ve Sınırları)*
