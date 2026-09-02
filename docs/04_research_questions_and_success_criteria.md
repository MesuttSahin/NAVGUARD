# 04 — Research Questions & Success Criteria (Araştırma Soruları ve Başarı Kriterleri)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the research questions, hypotheses, measurable objectives, evaluation logic, and success criteria of the NAVGUARD project. *(Bu doküman, NAVGUARD projesinin araştırma sorularını, hipotezlerini, ölçülebilir hedeflerini, değerlendirme mantığını ve başarı kriterlerini tanımlar.)*

The purpose of this document is to ensure that the project is evaluated using measurable engineering evidence rather than subjective visual impressions. *(Bu dokümanın amacı, projenin öznel görsel izlenimler yerine ölçülebilir mühendislik kanıtları kullanılarak değerlendirilmesini sağlamaktır.)*

The project will therefore define success in terms of navigation accuracy, drift reduction, motion understanding, mobile inference performance, robustness, and reproducibility. *(Bu nedenle proje başarısını navigasyon doğruluğu, sürüklenme azaltımı, hareket anlayışı, mobil çıkarım performansı, dayanıklılık ve tekrarlanabilirlik açısından tanımlayacaktır.)*

---

# 2. Research Objective (Araştırma Hedefi)

The central research objective of NAVGUARD is to determine whether a standard Android smartphone can maintain useful short-term pedestrian position estimates after GNSS measurements are removed from the navigation estimator. *(NAVGUARD'ın temel araştırma hedefi, GNSS ölçümleri navigasyon tahmin motorundan çıkarıldıktan sonra standart bir Android akıllı telefonun kullanışlı kısa süreli yaya konum tahminlerini sürdürebilip sürdüremeyeceğini belirlemektir.)*

The project will investigate whether combining pedestrian dead reckoning, multi-sensor heading estimation, visual-inertial tracking, sensor fusion, and artificial intelligence produces a measurable improvement over simpler dead reckoning approaches. *(Proje, yaya ölü hesaplama, çoklu sensör yön tahmini, görsel-ataletsel takip, sensör füzyonu ve yapay zekânın birleştirilmesinin daha basit ölü hesaplama yaklaşımlarına göre ölçülebilir bir iyileşme sağlayıp sağlamadığını araştıracaktır.)*

The research will focus on comparative performance rather than attempting to achieve a predefined military-grade or survey-grade absolute positioning accuracy. *(Araştırma, önceden belirlenmiş askeri seviye veya ölçüm seviye mutlak konumlandırma doğruluğuna ulaşmaya çalışmak yerine karşılaştırmalı performansa odaklanacaktır.)*

---

# 3. Primary Research Question — RQ-01 (Birincil Araştırma Sorusu — RQ-01)

**RQ-01: Can AI-assisted pedestrian dead reckoning and visual-inertial sensor fusion reduce position drift during simulated GNSS outages on the Xiaomi Redmi Note 9 Pro compared with a baseline PDR-only approach?** *(RQ-01: Yapay zekâ destekli yaya ölü hesaplama ve görsel-ataletsel sensör füzyonu, Xiaomi Redmi Note 9 Pro üzerinde simüle edilmiş GNSS kesintileri sırasında yalnızca PDR kullanan temel yaklaşıma kıyasla konum sürüklenmesini azaltabilir mi?)*

This is the primary research question of the project and will receive the highest evaluation priority. *(Bu, projenin birincil araştırma sorusudur ve en yüksek değerlendirme önceliğine sahip olacaktır.)*

The final NAVGUARD configuration must be compared directly with the baseline configuration using the same or equivalent recorded test sessions. *(Nihai NAVGUARD yapılandırması, aynı veya eşdeğer kaydedilmiş test oturumları kullanılarak temel yapılandırmayla doğrudan karşılaştırılmalıdır.)*

---

# 4. Secondary Research Question — RQ-02 (İkincil Araştırma Sorusu — RQ-02)

**RQ-02: How much does improved heading estimation contribute to reducing pedestrian dead reckoning error?** *(RQ-02: Geliştirilmiş yön tahmini, yaya ölü hesaplama hatasının azaltılmasına ne kadar katkı sağlar?)*

This question will compare basic heading usage with a fused heading approach based on available orientation-related sensors. *(Bu soru, temel yön kullanımını mevcut yönelimle ilişkili sensörlere dayalı füzyonlu yön yaklaşımıyla karşılaştıracaktır.)*

The objective is to determine whether heading improvement produces a measurable reduction in lateral trajectory error. *(Amaç, yön iyileştirmesinin yanal rota hatasında ölçülebilir bir azalma sağlayıp sağlamadığını belirlemektir.)*

---

# 5. Secondary Research Question — RQ-03 (İkincil Araştırma Sorusu — RQ-03)

**RQ-03: Does ARCore-based visual-inertial relative movement information reduce accumulated drift compared with PDR-based navigation alone?** *(RQ-03: ARCore tabanlı görsel-ataletsel göreli hareket bilgisi, yalnızca PDR tabanlı navigasyona kıyasla biriken sürüklenmeyi azaltır mı?)*

The contribution of ARCore will be evaluated independently before it is accepted as a permanent component of the final fusion architecture. *(ARCore'un katkısı, nihai füzyon mimarisinin kalıcı bir bileşeni olarak kabul edilmeden önce bağımsız olarak değerlendirilecektir.)*

ARCore will be considered beneficial only if its additional complexity provides measurable navigation value or useful robustness. *(ARCore, yalnızca ek karmaşıklığının ölçülebilir navigasyon değeri veya faydalı dayanıklılık sağlaması durumunda yararlı kabul edilecektir.)*

---

# 6. Secondary Research Question — RQ-04 (İkincil Araştırma Sorusu — RQ-04)

**RQ-04: Can an on-device motion classification model reliably distinguish stationary, walking, running, and turning states using smartphone inertial sensor data?** *(RQ-04: Cihaz üzerinde çalışan bir hareket sınıflandırma modeli, akıllı telefon ataletsel sensör verilerini kullanarak sabit durma, yürüme, koşma ve dönme durumlarını güvenilir şekilde ayırt edebilir mi?)*

The model will be evaluated using held-out test sessions that are not used during training. *(Model, eğitim sırasında kullanılmayan ayrılmış test oturumları kullanılarak değerlendirilecektir.)*

The evaluation will prioritize macro F1 score in addition to overall accuracy so that performance across all motion classes is considered. *(Değerlendirme, tüm hareket sınıflarındaki performansın dikkate alınması için genel doğruluğa ek olarak macro F1 skoruna öncelik verecektir.)*

---

# 7. Secondary Research Question — RQ-05 (İkincil Araştırma Sorusu — RQ-05)

**RQ-05: Does motion-aware navigation improve the behavior of the pedestrian positioning system compared with fixed motion assumptions?** *(RQ-05: Hareket farkındalıklı navigasyon, sabit hareket varsayımlarına kıyasla yaya konumlandırma sisteminin davranışını iyileştirir mi?)*

The project will examine whether motion classification prevents unnecessary position updates while stationary and improves navigation behavior during changes between walking, running, stopping, and turning. *(Proje, hareket sınıflandırmasının sabit durumdayken gereksiz konum güncellemelerini önleyip önlemediğini ve yürüme, koşma, durma ve dönme arasındaki geçişlerde navigasyon davranışını iyileştirip iyileştirmediğini inceleyecektir.)*

The AI component must demonstrate practical influence on the navigation pipeline rather than functioning only as a displayed classification output. *(Yapay zekâ bileşeni yalnızca ekranda gösterilen bir sınıflandırma çıktısı olarak çalışmak yerine navigasyon hattı üzerinde pratik bir etki göstermelidir.)*

---

# 8. Secondary Research Question — RQ-06 (İkincil Araştırma Sorusu — RQ-06)

**RQ-06: Can dynamic step length estimation reduce travelled-distance error compared with a constant step length assumption?** *(RQ-06: Dinamik adım uzunluğu tahmini, sabit adım uzunluğu varsayımına kıyasla kat edilen mesafe hatasını azaltabilir mi?)*

This question will be evaluated only if the step length estimation model reaches sufficient implementation maturity within the project schedule. *(Bu soru yalnızca adım uzunluğu tahmin modeli proje takvimi içerisinde yeterli geliştirme olgunluğuna ulaşırsa değerlendirilecektir.)*

The constant step length approach will serve as the baseline. *(Sabit adım uzunluğu yaklaşımı temel referans olarak kullanılacaktır.)*

---

# 9. Secondary Research Question — RQ-07 (İkincil Araştırma Sorusu — RQ-07)

**RQ-07: Can the complete navigation pipeline operate in real time on the Xiaomi Redmi Note 9 Pro without relying on cloud inference?** *(RQ-07: Tam navigasyon hattı, bulut çıkarımına bağlı olmadan Xiaomi Redmi Note 9 Pro üzerinde gerçek zamanlı çalışabilir mi?)*

The navigation engine, sensor processing, artificial intelligence inference, and core fusion functions are expected to execute locally on the device. *(Navigasyon motorunun, sensör işlemenin, yapay zekâ çıkarımının ve temel füzyon işlevlerinin cihaz üzerinde yerel olarak çalışması beklenmektedir.)*

Real-time feasibility will be evaluated using execution latency, application responsiveness, and device resource consumption. *(Gerçek zamanlı uygulanabilirlik; çalışma gecikmesi, uygulama tepki süresi ve cihaz kaynak tüketimi kullanılarak değerlendirilecektir.)*

---

# 10. Secondary Research Question — RQ-08 (İkincil Araştırma Sorusu — RQ-08)

**RQ-08: How does NAVGUARD performance change across different pedestrian movement and environmental conditions?** *(RQ-08: NAVGUARD performansı farklı yaya hareketi ve çevresel koşullarda nasıl değişir?)*

The system will be evaluated on multiple route geometries and movement patterns rather than a single ideal test route. *(Sistem tek bir ideal test rotası yerine birden fazla rota geometrisi ve hareket örüntüsü üzerinde değerlendirilecektir.)*

The objective is to identify conditions under which the system performs reliably and conditions under which navigation error increases significantly. *(Amaç, sistemin güvenilir çalıştığı koşullar ile navigasyon hatasının önemli ölçüde arttığı koşulları belirlemektir.)*

---

# 11. Secondary Research Question — RQ-09 (İkincil Araştırma Sorusu — RQ-09)

**RQ-09: Can a sensor confidence mechanism reduce the negative impact of temporarily unreliable sensor measurements?** *(RQ-09: Bir sensör güven mekanizması, geçici olarak güvenilmez sensör ölçümlerinin olumsuz etkisini azaltabilir mi?)*

The system will evaluate whether reducing the contribution of degraded sources improves final position stability. *(Sistem, bozulmuş kaynakların katkısını azaltmanın nihai konum kararlılığını iyileştirip iyileştirmediğini değerlendirecektir.)*

This research question is secondary to the core navigation objectives and may be evaluated with focused fault or degradation scenarios. *(Bu araştırma sorusu temel navigasyon hedeflerine göre ikincildir ve odaklanmış arıza veya bozulma senaryolarıyla değerlendirilebilir.)*

---

# 12. Primary Hypothesis — H1 (Birincil Hipotez — H1)

**H1: The complete NAVGUARD fusion configuration will produce lower median position error and lower final position error than the PDR-only baseline during matched GNSS-denied test sessions.** *(H1: Tam NAVGUARD füzyon yapılandırması, eşleştirilmiş GNSS kesintili test oturumlarında yalnızca PDR kullanan temel yaklaşıma göre daha düşük medyan konum hatası ve daha düşük nihai konum hatası üretecektir.)*

This hypothesis represents the main technical expectation of the project. *(Bu hipotez projenin temel teknik beklentisini temsil eder.)*

---

# 13. Null Hypothesis — H0 (Sıfır Hipotezi — H0)

**H0: The complete NAVGUARD fusion configuration will not provide a meaningful reduction in navigation error compared with the PDR-only baseline.** *(H0: Tam NAVGUARD füzyon yapılandırması, yalnızca PDR kullanan temel yaklaşıma kıyasla navigasyon hatasında anlamlı bir azalma sağlamayacaktır.)*

The project will accept the measured result even if the final system does not outperform the baseline. *(Nihai sistem temel yaklaşımı geçemese bile proje ölçülen sonucu kabul edecektir.)*

A negative result will be documented as an experimental finding rather than hidden or artificially optimized. *(Olumsuz bir sonuç gizlenmek veya yapay olarak optimize edilmek yerine deneysel bir bulgu olarak dokümante edilecektir.)*

---

# 14. Motion Classification Hypothesis — H2 (Hareket Sınıflandırma Hipotezi — H2)

**H2: A lightweight on-device model can classify the defined pedestrian motion states with sufficient accuracy for use as contextual navigation information.** *(H2: Hafif bir cihaz üzeri model, tanımlanan yaya hareket durumlarını navigasyon bağlam bilgisi olarak kullanılabilecek yeterli doğrulukla sınıflandırabilir.)*

The final motion model should demonstrate balanced performance across motion classes rather than achieving high accuracy by favoring the most common class. *(Nihai hareket modeli, en yaygın sınıfı kayırarak yüksek doğruluk elde etmek yerine hareket sınıfları arasında dengeli performans göstermelidir.)*

---

# 15. Step Length Hypothesis — H3 (Adım Uzunluğu Hipotezi — H3)

**H3: A motion-aware or learned step length model can reduce distance estimation error compared with a single fixed step length value.** *(H3: Hareket farkındalıklı veya öğrenilmiş bir adım uzunluğu modeli, tek bir sabit adım uzunluğu değerine kıyasla mesafe tahmin hatasını azaltabilir.)*

This hypothesis is considered an enhancement hypothesis rather than a mandatory condition for overall project success. *(Bu hipotez genel proje başarısı için zorunlu bir koşul yerine geliştirme hipotezi olarak kabul edilir.)*

---

# 16. Edge AI Hypothesis — H4 (Edge AI Hipotezi — H4)

**H4: The selected artificial intelligence model can execute locally on the Redmi Note 9 Pro with sufficiently low latency to support real-time navigation.** *(H4: Seçilen yapay zekâ modeli, gerçek zamanlı navigasyonu destekleyecek kadar düşük gecikmeyle Redmi Note 9 Pro üzerinde yerel olarak çalışabilir.)*

The model must therefore be evaluated not only for predictive performance but also for mobile execution efficiency. *(Bu nedenle model yalnızca tahmin performansı açısından değil mobil çalışma verimliliği açısından da değerlendirilmelidir.)*

---

# 17. Experimental Comparison Structure (Deneysel Karşılaştırma Yapısı)

The research will use an incremental configuration comparison to isolate the contribution of major system components. *(Araştırma, temel sistem bileşenlerinin katkısını izole etmek için kademeli bir yapılandırma karşılaştırması kullanacaktır.)*

The same recorded sessions should be processed by multiple estimators whenever technically possible. *(Teknik olarak mümkün olduğunda aynı kaydedilmiş oturumlar birden fazla tahmin motoru tarafından işlenmelidir.)*

This approach reduces environmental variation between configurations and improves fairness of comparison. *(Bu yaklaşım yapılandırmalar arasındaki çevresel değişkenliği azaltır ve karşılaştırmanın adaletini artırır.)*

### Configuration A — PDR Only (Yapılandırma A — Yalnızca PDR)

This configuration represents the minimum dead reckoning baseline. *(Bu yapılandırma minimum ölü hesaplama temel referansını temsil eder.)*

### Configuration B — PDR + Heading Fusion (Yapılandırma B — PDR + Yön Füzyonu)

This configuration measures the contribution of improved heading estimation. *(Bu yapılandırma geliştirilmiş yön tahmininin katkısını ölçer.)*

### Configuration C — PDR + ARCore (Yapılandırma C — PDR + ARCore)

This configuration measures the contribution of visual-inertial relative displacement information. *(Bu yapılandırma görsel-ataletsel göreli yer değiştirme bilgisinin katkısını ölçer.)*

### Configuration D — NAVGUARD AI Fusion (Yapılandırma D — NAVGUARD AI Füzyonu)

This configuration represents the intended final integrated navigation system. *(Bu yapılandırma planlanan nihai entegre navigasyon sistemini temsil eder.)*

---

# 18. Evaluation Philosophy (Değerlendirme Felsefesi)

Relative improvement will be prioritized over arbitrary absolute positioning claims. *(Keyfi mutlak konumlandırma iddiaları yerine göreli iyileşmeye öncelik verilecektir.)*

Absolute error will still be measured and reported for every experiment. *(Mutlak hata yine de her deney için ölçülecek ve raporlanacaktır.)*

The final system will not be declared successful simply because an estimated trajectory visually resembles the reference route. *(Nihai sistem yalnızca tahmini rota görsel olarak referans rotaya benzediği için başarılı ilan edilmeyecektir.)*

Quantitative metrics must support all major performance conclusions. *(Tüm önemli performans sonuçları nicel metriklerle desteklenmelidir.)*

---

# 19. Primary Navigation Success Criterion — SC-NAV-01 (Birincil Navigasyon Başarı Kriteri — SC-NAV-01)

**The complete NAVGUARD configuration should reduce median position error by at least 20% compared with the PDR-only baseline across the final matched evaluation sessions.** *(Tam NAVGUARD yapılandırması, nihai eşleştirilmiş değerlendirme oturumlarında yalnızca PDR kullanan temel yaklaşıma göre medyan konum hatasını en az %20 azaltmalıdır.)*

This threshold is a provisional engineering target and may be reviewed after the initial device audit and pilot experiments if the measured hardware characteristics justify a revision. *(Bu eşik geçici bir mühendislik hedefidir ve ölçülen donanım özellikleri bir revizyonu gerekçelendirirse ilk cihaz denetimi ve pilot deneylerden sonra gözden geçirilebilir.)*

Any revision must be documented before final evaluation begins. *(Herhangi bir revizyon nihai değerlendirme başlamadan önce dokümante edilmelidir.)*

---

# 20. Secondary Navigation Success Criterion — SC-NAV-02 (İkincil Navigasyon Başarı Kriteri — SC-NAV-02)

**The complete NAVGUARD configuration should produce a lower median final position error than the PDR-only baseline.** *(Tam NAVGUARD yapılandırması yalnızca PDR kullanan temel yaklaşıma göre daha düşük medyan nihai konum hatası üretmelidir.)*

This criterion evaluates whether the system limits accumulated drift at the end of a GNSS-denied session. *(Bu kriter sistemin GNSS kesintili bir oturumun sonunda biriken sürüklenmeyi sınırlayıp sınırlamadığını değerlendirir.)*

---

# 21. Navigation Continuity Success Criterion — SC-NAV-03 (Navigasyon Sürekliliği Başarı Kriteri — SC-NAV-03)

**The application must continue producing position estimates after GNSS input is removed from the navigation estimator.** *(GNSS girdisi navigasyon tahmin motorundan çıkarıldıktan sonra uygulama konum tahminleri üretmeye devam etmelidir.)*

The navigation session must not terminate solely because GNSS updates are unavailable to the estimator. *(Navigasyon oturumu yalnızca GNSS güncellemeleri tahmin motoru tarafından kullanılamadığı için sonlanmamalıdır.)*

This is a mandatory functional success condition. *(Bu zorunlu bir fonksiyonel başarı koşuludur.)*

---

# 22. Ground Truth Isolation Criterion — SC-NAV-04 (Gerçek Referans İzolasyon Kriteri — SC-NAV-04)

**GNSS measurements recorded for ground-truth evaluation must not influence the estimator during the GNSS-denied phase.** *(Gerçek referans değerlendirmesi için kaydedilen GNSS ölçümleri GNSS kesintili aşamada tahmin motorunu etkilememelidir.)*

The project must provide a verifiable architectural separation between evaluation GNSS data and estimator input. *(Proje değerlendirme GNSS verisi ile tahmin motoru girdisi arasında doğrulanabilir bir mimari ayrım sağlamalıdır.)*

Failure to maintain this separation invalidates the corresponding GNSS-denied experiment. *(Bu ayrımın korunamaması ilgili GNSS kesintili deneyi geçersiz kılar.)*

---

# 23. Step Detection Success Criterion — SC-PDR-01 (Adım Tespit Başarı Kriteri — SC-PDR-01)

**The step detection subsystem should achieve an absolute step count error of no more than 5% during controlled walking tests.** *(Adım tespit alt sistemi, kontrollü yürüyüş testlerinde %5'ten fazla olmayan mutlak adım sayısı hatasına ulaşmalıdır.)*

Manual counting or another independently verified reference will be used for selected validation sessions. *(Seçilen doğrulama oturumları için manuel sayım veya bağımsız olarak doğrulanmış başka bir referans kullanılacaktır.)*

Running and irregular movement will be evaluated separately from normal walking where necessary. *(Koşma ve düzensiz hareket gerektiğinde normal yürüyüşten ayrı olarak değerlendirilecektir.)*

---

# 24. Heading Success Criterion — SC-HDG-01 (Yön Başarı Kriteri — SC-HDG-01)

**The fused heading solution should outperform or demonstrate greater stability than the simplest single-source heading baseline during controlled turning and walking experiments.** *(Füzyonlu yön çözümü, kontrollü dönme ve yürüyüş deneylerinde en basit tek kaynaklı yön temel yaklaşımından daha iyi performans göstermeli veya daha yüksek kararlılık sergilemelidir.)*

A fixed absolute heading threshold will not be finalized until the device-specific sensor audit and initial reference measurements are completed. *(Cihaza özgü sensör denetimi ve ilk referans ölçümleri tamamlanana kadar sabit bir mutlak yön hata eşiği kesinleştirilmeyecektir.)*

Heading performance will be measured using angular error statistics whenever a suitable reference is available. *(Uygun bir referans mevcut olduğunda yön performansı açısal hata istatistikleri kullanılarak ölçülecektir.)*

---

# 25. Motion Classification Success Criterion — SC-AI-01 (Hareket Sınıflandırma Başarı Kriteri — SC-AI-01)

**The final motion classification model should achieve a macro F1 score of at least 0.90 on held-out test sessions.** *(Nihai hareket sınıflandırma modeli ayrılmış test oturumlarında en az 0,90 macro F1 skoruna ulaşmalıdır.)*

No test session may be used during model training or hyperparameter selection. *(Hiçbir test oturumu model eğitimi veya hiperparametre seçimi sırasında kullanılamaz.)*

Per-class precision, recall, F1 score, and the confusion matrix must also be reported. *(Her sınıf için precision, recall, F1 skoru ve confusion matrix de raporlanmalıdır.)*

If the 0.90 target cannot be achieved, the highest-performing model may still be used experimentally, but the limitation must be explicitly documented. *(0,90 hedefi elde edilemezse en yüksek performanslı model deneysel olarak yine kullanılabilir ancak sınırlama açıkça dokümante edilmelidir.)*

---

# 26. Motion-Aware Navigation Success Criterion — SC-AI-02 (Hareket Farkındalıklı Navigasyon Başarı Kriteri — SC-AI-02)

**When the user is classified as stationary with high confidence, the system should suppress unnecessary pedestrian displacement updates.** *(Kullanıcı yüksek güvenle sabit olarak sınıflandırıldığında sistem gereksiz yaya yer değiştirme güncellemelerini bastırmalıdır.)*

Stationary tests will be used to quantify unintended position movement. *(İstenmeyen konum hareketini nicel olarak ölçmek için sabit durma testleri kullanılacaktır.)*

The AI model will be considered practically useful only if its output changes navigation behavior in a defined and testable way. *(Yapay zekâ modeli yalnızca çıktısı navigasyon davranışını tanımlı ve test edilebilir bir şekilde değiştiriyorsa pratik olarak yararlı kabul edilecektir.)*

---

# 27. Step Length Success Criterion — SC-AI-03 (Adım Uzunluğu Başarı Kriteri — SC-AI-03)

**If the learned step length model is included in the final system, it should reduce median travelled-distance estimation error relative to the fixed step length baseline.** *(Öğrenilmiş adım uzunluğu modeli nihai sisteme dahil edilirse sabit adım uzunluğu temel yaklaşımına göre medyan kat edilen mesafe tahmin hatasını azaltmalıdır.)*

No mandatory improvement percentage will be imposed before the initial dataset and calibration experiments are completed. *(İlk veri seti ve kalibrasyon deneyleri tamamlanmadan önce zorunlu bir iyileşme yüzdesi uygulanmayacaktır.)*

The model will not remain in the final navigation architecture if it increases complexity without measurable benefit. *(Model ölçülebilir fayda sağlamadan karmaşıklığı artırırsa nihai navigasyon mimarisinde tutulmayacaktır.)*

---

# 28. ARCore Success Criterion — SC-AR-01 (ARCore Başarı Kriteri — SC-AR-01)

**ARCore integration must provide timestamped relative pose or displacement information that can be aligned with the NAVGUARD local coordinate system.** *(ARCore entegrasyonu NAVGUARD yerel koordinat sistemiyle hizalanabilecek zaman damgalı göreli poz veya yer değiştirme bilgisi sağlamalıdır.)*

ARCore tracking loss must be detected by the application. *(ARCore takip kaybı uygulama tarafından tespit edilmelidir.)*

Loss of ARCore tracking must not terminate the navigation session. *(ARCore takibinin kaybolması navigasyon oturumunu sonlandırmamalıdır.)*

ARCore will remain part of the final fusion configuration only if experimental results justify its inclusion. *(ARCore yalnızca deneysel sonuçlar sisteme dahil edilmesini gerekçelendirirse nihai füzyon yapılandırmasının parçası olarak kalacaktır.)*

---

# 29. Sensor Fusion Success Criterion — SC-FUS-01 (Sensör Füzyonu Başarı Kriteri — SC-FUS-01)

**The sensor fusion subsystem must accept multiple navigation information sources and produce a single consistent position estimate.** *(Sensör füzyon alt sistemi birden fazla navigasyon bilgi kaynağını kabul etmeli ve tek bir tutarlı konum tahmini üretmelidir.)*

The fusion system must continue operating when an optional information source becomes temporarily unavailable. *(Füzyon sistemi isteğe bağlı bir bilgi kaynağı geçici olarak kullanılamaz hale geldiğinde çalışmaya devam etmelidir.)*

The fusion architecture must expose enough internal state for debugging and experimental analysis. *(Füzyon mimarisi hata ayıklama ve deneysel analiz için yeterli dahili durumu erişilebilir hale getirmelidir.)*

---

# 30. Sensor Confidence Success Criterion — SC-FUS-02 (Sensör Güveni Başarı Kriteri — SC-FUS-02)

**The system should detect at least the major quality states required to reduce dependence on obviously degraded measurements.** *(Sistem açıkça bozulmuş ölçümlere olan bağımlılığı azaltmak için gereken en azından temel kalite durumlarını tespit etmelidir.)*

The first implementation may use deterministic quality indicators rather than a separate machine learning model. *(İlk uygulama ayrı bir makine öğrenmesi modeli yerine deterministik kalite göstergeleri kullanabilir.)*

The objective is reliable navigation behavior rather than unnecessary algorithmic complexity. *(Amaç gereksiz algoritmik karmaşıklık yerine güvenilir navigasyon davranışıdır.)*

---

# 31. Uncertainty Success Criterion — SC-UNC-01 (Belirsizlik Başarı Kriteri — SC-UNC-01)

**NAVGUARD must expose a position confidence or uncertainty representation during GNSS-denied navigation.** *(NAVGUARD, GNSS kesintili navigasyon sırasında bir konum güveni veya belirsizlik temsili sunmalıdır.)*

The displayed uncertainty does not need to represent certified probabilistic accuracy in the prototype stage. *(Gösterilen belirsizliğin prototip aşamasında sertifikalı olasılıksal doğruluğu temsil etmesi gerekmez.)*

However, the uncertainty representation must respond logically to navigation duration, sensor quality, and tracking degradation. *(Ancak belirsizlik temsili navigasyon süresine, sensör kalitesine ve takip bozulmasına mantıklı şekilde tepki vermelidir.)*

---

# 32. On-Device AI Success Criterion — SC-EDGE-01 (Cihaz Üzeri AI Başarı Kriteri — SC-EDGE-01)

**The final motion classification model must execute locally on the Android device without requiring a network connection.** *(Nihai hareket sınıflandırma modeli ağ bağlantısı gerektirmeden Android cihaz üzerinde yerel olarak çalışmalıdır.)*

The mobile application must not depend on a cloud AI API for real-time navigation decisions. *(Mobil uygulama gerçek zamanlı navigasyon kararları için bir bulut yapay zekâ API'sine bağımlı olmamalıdır.)*

This is a mandatory architectural criterion. *(Bu zorunlu bir mimari kriterdir.)*

---

# 33. AI Inference Latency Success Criterion — SC-EDGE-02 (AI Çıkarım Gecikmesi Başarı Kriteri — SC-EDGE-02)

**The target motion classification inference latency is less than 50 milliseconds per inference on the Xiaomi Redmi Note 9 Pro under normal test conditions.** *(Hedef hareket sınıflandırma çıkarım gecikmesi, normal test koşullarında Xiaomi Redmi Note 9 Pro üzerinde çıkarım başına 50 milisaniyeden azdır.)*

The final acceptable threshold may be revised after the actual model architecture and device runtime are measured. *(Nihai kabul edilebilir eşik gerçek model mimarisi ve cihaz çalışma süresi ölçüldükten sonra revize edilebilir.)*

The model must not introduce noticeable user-interface blocking during normal navigation. *(Model normal navigasyon sırasında fark edilir kullanıcı arayüzü bloklamasına neden olmamalıdır.)*

---

# 34. Mobile Application Responsiveness Criterion — SC-MOB-01 (Mobil Uygulama Tepki Kriteri — SC-MOB-01)

**The application must remain responsive while simultaneously collecting sensors, running navigation logic, recording the session, and performing AI inference.** *(Uygulama sensörleri toplarken, navigasyon mantığını çalıştırırken, oturumu kaydederken ve yapay zekâ çıkarımı gerçekleştirirken aynı anda tepki verebilir durumda kalmalıdır.)*

Critical navigation operations must not be executed in a way that repeatedly blocks the Flutter user interface thread. *(Kritik navigasyon işlemleri Flutter kullanıcı arayüzü thread'ini tekrar tekrar bloke edecek şekilde çalıştırılmamalıdır.)*

---

# 35. Stability Success Criterion — SC-STB-01 (Kararlılık Başarı Kriteri — SC-STB-01)

**NAVGUARD must complete the planned final field-test session without application crashes or unrecoverable navigation engine failures.** *(NAVGUARD, planlanan nihai saha test oturumunu uygulama çökmesi veya kurtarılamaz navigasyon motoru hatası olmadan tamamlamalıdır.)*

Temporary loss of an optional subsystem must be handled without corrupting the entire session whenever technically possible. *(İsteğe bağlı bir alt sistemin geçici kaybı teknik olarak mümkün olduğunda tüm oturumu bozmadan yönetilmelidir.)*

---

# 36. Logging Success Criterion — SC-DATA-01 (Kayıt Başarı Kriteri — SC-DATA-01)

**Every evaluation session must produce synchronized records containing sufficient information to reproduce the navigation analysis.** *(Her değerlendirme oturumu navigasyon analizini yeniden üretmek için yeterli bilgiyi içeren senkronize kayıtlar üretmelidir.)*

The recorded information must include timestamps, relevant sensor measurements, estimator outputs, navigation modes, and ground-truth GNSS data when evaluation mode is active. *(Kaydedilen bilgiler zaman damgalarını, ilgili sensör ölçümlerini, tahmin motoru çıktılarını, navigasyon modlarını ve değerlendirme modu aktifken gerçek referans GNSS verisini içermelidir.)*

A session with incomplete critical logging may be excluded from the final benchmark. *(Kritik kayıtları eksik olan bir oturum nihai benchmark'tan çıkarılabilir.)*

---

# 37. Reproducibility Success Criterion — SC-DATA-02 (Tekrarlanabilirlik Başarı Kriteri — SC-DATA-02)

**Recorded sessions should be reusable for offline replay and comparison of multiple estimator configurations whenever possible.** *(Kaydedilen oturumlar mümkün olduğunda birden fazla tahmin motoru yapılandırmasının çevrimdışı yeniden oynatılması ve karşılaştırılması için yeniden kullanılabilir olmalıdır.)*

This requirement allows algorithm changes to be compared against identical sensor inputs. *(Bu gereksinim algoritma değişikliklerinin aynı sensör girdileri üzerinde karşılaştırılmasını sağlar.)*

Replaying identical sessions will reduce the need to physically repeat every field test for every algorithm version. *(Aynı oturumların yeniden oynatılması her algoritma sürümü için her saha testini fiziksel olarak tekrarlama ihtiyacını azaltacaktır.)*

---

# 38. Field Evaluation Success Criterion — SC-EXP-01 (Saha Değerlendirme Başarı Kriteri — SC-EXP-01)

**The final evaluation must include more than one route geometry and more than one repeated session.** *(Nihai değerlendirme birden fazla rota geometrisini ve birden fazla tekrarlanan oturumu içermelidir.)*

At minimum, the final evaluation should include a straight route, a route containing multiple turns, and a closed or approximately closed route. *(Nihai değerlendirme en azından düz bir rota, birden fazla dönüş içeren bir rota ve kapalı veya yaklaşık kapalı bir rota içermelidir.)*

Each primary route type should be repeated at least three times if time and environmental conditions permit. *(Zaman ve çevresel koşullar izin verirse her temel rota türü en az üç kez tekrarlanmalıdır.)*

This produces a preferred minimum of nine principal evaluation sessions. *(Bu, tercih edilen minimum dokuz temel değerlendirme oturumu üretir.)*

---

# 39. Route Replay Evaluation Criterion — SC-EXP-02 (Rota Yeniden Oynatma Değerlendirme Kriteri — SC-EXP-02)

**The same principal sensor sessions should be evaluated using Configurations A, B, C, and D whenever the required data sources are available.** *(Gerekli veri kaynakları mevcut olduğunda aynı temel sensör oturumları A, B, C ve D yapılandırmaları kullanılarak değerlendirilmelidir.)*

This paired evaluation will be preferred over comparing unrelated physical walking sessions. *(Bu eşleştirilmiş değerlendirme ilgisiz fiziksel yürüyüş oturumlarının karşılaştırılmasına tercih edilecektir.)*

---

# 40. Position Error Metrics (Konum Hata Metrikleri)

The following metrics will be used to evaluate navigation performance. *(Navigasyon performansını değerlendirmek için aşağıdaki metrikler kullanılacaktır.)*

- **Mean Position Error** *(Ortalama Konum Hatası)*
- **Median Position Error** *(Medyan Konum Hatası)*
- **Root Mean Square Error — RMSE** *(Kök Ortalama Kare Hata — RMSE)*
- **Final Position Error** *(Nihai Konum Hatası)*
- **95th Percentile Position Error** *(95. Yüzdelik Konum Hatası)*
- **Drift per Minute** *(Dakika Başına Sürüklenme)*
- **Drift Relative to Travelled Distance** *(Kat Edilen Mesafeye Göre Sürüklenme)*

Median error will be emphasized because a small number of extreme GNSS or estimator outliers can strongly influence the arithmetic mean. *(Az sayıda aşırı GNSS veya tahmin motoru aykırı değeri aritmetik ortalamayı güçlü şekilde etkileyebileceği için medyan hataya özellikle önem verilecektir.)*

Mean and RMSE will still be reported to preserve visibility of large errors. *(Büyük hataların görünürlüğünü korumak için ortalama ve RMSE yine de raporlanacaktır.)*

---

# 41. Motion Classification Metrics (Hareket Sınıflandırma Metrikleri)

The motion classification model will be evaluated using multiple metrics. *(Hareket sınıflandırma modeli birden fazla metrik kullanılarak değerlendirilecektir.)*

- **Accuracy** *(Doğruluk)*
- **Macro Precision** *(Makro Precision)*
- **Macro Recall** *(Makro Recall)*
- **Macro F1 Score** *(Makro F1 Skoru)*
- **Per-Class F1 Score** *(Sınıf Bazlı F1 Skoru)*
- **Confusion Matrix** *(Karışıklık Matrisi)*

Macro F1 will be the primary model-selection metric unless later data characteristics justify another choice. *(Daha sonraki veri özellikleri başka bir seçimi gerekçelendirmediği sürece Macro F1 temel model seçim metriği olacaktır.)*

---

# 42. Step Length Metrics (Adım Uzunluğu Metrikleri)

If a learned step length model is developed, its predictions will be evaluated using regression and distance-level metrics. *(Öğrenilmiş bir adım uzunluğu modeli geliştirilirse tahminleri regresyon ve mesafe seviyesindeki metrikler kullanılarak değerlendirilecektir.)*

- **Mean Absolute Error — MAE** *(Ortalama Mutlak Hata — MAE)*
- **Root Mean Square Error — RMSE** *(Kök Ortalama Kare Hata — RMSE)*
- **Total Travelled Distance Error** *(Toplam Kat Edilen Mesafe Hatası)*
- **Relative Distance Error** *(Göreli Mesafe Hatası)*

---

# 43. Runtime Metrics (Çalışma Zamanı Metrikleri)

The following runtime metrics will be recorded where technically practical. *(Teknik olarak uygulanabilir olduğu durumlarda aşağıdaki çalışma zamanı metrikleri kaydedilecektir.)*

- **AI Inference Latency** *(Yapay Zekâ Çıkarım Gecikmesi)*
- **Navigation Update Latency** *(Navigasyon Güncelleme Gecikmesi)*
- **CPU Usage** *(CPU Kullanımı)*
- **Memory Usage** *(Bellek Kullanımı)*
- **Battery Consumption** *(Batarya Tüketimi)*
- **Application Stability** *(Uygulama Kararlılığı)*
- **ARCore Tracking Availability** *(ARCore Takip Kullanılabilirliği)*

These measurements are secondary to positioning performance but are necessary to demonstrate mobile feasibility. *(Bu ölçümler konumlandırma performansına göre ikincildir ancak mobil uygulanabilirliği göstermek için gereklidir.)*

---

# 44. Minimum Viable Research Success (Minimum Araştırma Başarısı)

NAVGUARD will achieve minimum research success if the project produces a stable Android application capable of executing controlled GNSS-denied PDR experiments and calculating reproducible navigation errors. *(NAVGUARD, kontrollü GNSS kesintili PDR deneylerini gerçekleştirebilen ve tekrarlanabilir navigasyon hatalarını hesaplayabilen kararlı bir Android uygulama üretirse minimum araştırma başarısına ulaşacaktır.)*

The system must also include a trained and evaluated on-device motion classification model. *(Sistem ayrıca eğitilmiş ve değerlendirilmiş cihaz üzerinde çalışan bir hareket sınıflandırma modeli içermelidir.)*

Ground-truth GNSS data must remain separated from the navigation estimator during the denied phase. *(Gerçek referans GNSS verisi kesinti aşamasında navigasyon tahmin motorundan ayrı kalmalıdır.)*

These conditions represent the minimum acceptable project outcome if advanced fusion components encounter unexpected technical limitations. *(Bu koşullar gelişmiş füzyon bileşenleri beklenmeyen teknik sınırlamalarla karşılaşırsa minimum kabul edilebilir proje sonucunu temsil eder.)*

---

# 45. Target Project Success (Hedef Proje Başarısı)

NAVGUARD will achieve target-level success if the baseline PDR system, improved heading estimation, ARCore tracking, on-device motion AI, and sensor fusion operate together in the final mobile application. *(NAVGUARD; temel PDR sistemi, geliştirilmiş yön tahmini, ARCore takibi, cihaz üzeri hareket yapay zekâsı ve sensör füzyonu nihai mobil uygulamada birlikte çalışırsa hedef seviye başarıya ulaşacaktır.)*

The final integrated configuration should demonstrate measurable navigation improvement over the PDR-only baseline. *(Nihai entegre yapılandırma yalnızca PDR kullanan temel yaklaşıma göre ölçülebilir navigasyon iyileşmesi göstermelidir.)*

The project should also provide repeatable experimental evidence supporting the reported improvement. *(Proje ayrıca raporlanan iyileşmeyi destekleyen tekrarlanabilir deneysel kanıt sağlamalıdır.)*

---

# 46. Extended Project Success (Genişletilmiş Proje Başarısı)

NAVGUARD will achieve extended success if all target-level objectives are completed and additional improvements such as dynamic step length estimation, confidence-aware fusion, robust relocalization, or detailed resource profiling are successfully validated. *(NAVGUARD, tüm hedef seviye amaçlar tamamlanır ve dinamik adım uzunluğu tahmini, güven farkındalıklı füzyon, dayanıklı yeniden konumlandırma veya ayrıntılı kaynak profilleme gibi ek iyileştirmeler başarıyla doğrulanırsa genişletilmiş başarıya ulaşacaktır.)*

Extended success is desirable but is not required for the 24-business-day project to be considered complete. *(Genişletilmiş başarı arzu edilir ancak 24 iş günlük projenin tamamlanmış kabul edilmesi için zorunlu değildir.)*

---

# 47. Failure Conditions (Başarısızlık Koşulları)

The project will not be considered successful if it only displays smartphone sensor values without producing a functioning navigation estimate. *(Proje çalışan bir navigasyon tahmini üretmeden yalnızca akıllı telefon sensör değerlerini gösterirse başarılı kabul edilmeyecektir.)*

The project will not be considered experimentally valid if ground-truth GNSS coordinates influence the estimator during the GNSS-denied phase. *(Gerçek referans GNSS koordinatları GNSS kesintili aşamada tahmin motorunu etkilerse proje deneysel olarak geçerli kabul edilmeyecektir.)*

The project will not be considered complete if no quantitative comparison with reference data is performed. *(Referans verilerle hiçbir nicel karşılaştırma gerçekleştirilmezse proje tamamlanmış kabul edilmeyecektir.)*

The project will not be considered an AI-integrated system if the AI model is only displayed in the interface and does not participate in the navigation logic or experimental analysis. *(Yapay zekâ modeli yalnızca arayüzde gösterilir ve navigasyon mantığına veya deneysel analize katılmazsa proje yapay zekâ entegreli bir sistem olarak kabul edilmeyecektir.)*

---

# 48. Provisional Threshold Policy (Geçici Eşik Politikası)

Some numerical success thresholds in this document are provisional because the physical sensor characteristics of the Xiaomi Redmi Note 9 Pro have not yet been measured by NAVGUARD. *(Bu dokümandaki bazı sayısal başarı eşikleri geçicidir çünkü Xiaomi Redmi Note 9 Pro'nun fiziksel sensör özellikleri henüz NAVGUARD tarafından ölçülmemiştir.)*

The Device Capability Audit and initial pilot experiments may reveal constraints that justify adjusting specific thresholds. *(Cihaz Yetenek Denetimi ve ilk pilot deneyler belirli eşiklerin ayarlanmasını gerekçelendiren kısıtları ortaya çıkarabilir.)*

Thresholds may only be revised before the final benchmark dataset and evaluation protocol are frozen. *(Eşikler yalnızca nihai benchmark veri seti ve değerlendirme protokolü sabitlenmeden önce revize edilebilir.)*

Thresholds must not be changed after final results are observed simply to make the project appear successful. *(Eşikler nihai sonuçlar görüldükten sonra yalnızca projeyi başarılı göstermek amacıyla değiştirilmemelidir.)*

Every threshold revision must be recorded in the Technical Decisions and Change Log. *(Her eşik revizyonu Teknik Kararlar ve Değişiklik Günlüğünde kaydedilmelidir.)*

---

# 49. Research Integrity Rules (Araştırma Bütünlüğü Kuralları)

Training, validation, and test data must remain appropriately separated. *(Eğitim, doğrulama ve test verileri uygun şekilde ayrı tutulmalıdır.)*

The same recorded motion session must not be split across training and test sets in a way that creates data leakage. *(Aynı kaydedilmiş hareket oturumu veri sızıntısı oluşturacak şekilde eğitim ve test setleri arasında bölünmemelidir.)*

Failed experiments must not be silently removed unless a documented technical reason invalidates the measurement. *(Başarısız deneyler, dokümante edilmiş teknik bir neden ölçümü geçersiz kılmadığı sürece sessizce çıkarılmamalıdır.)*

Outlier removal procedures must be defined before final statistical analysis whenever possible. *(Aykırı değer çıkarma prosedürleri mümkün olduğunda nihai istatistiksel analizden önce tanımlanmalıdır.)*

Reported values must be calculated from stored experimental records rather than manually selected examples. *(Raporlanan değerler elle seçilmiş örnekler yerine saklanan deneysel kayıtlardan hesaplanmalıdır.)*

---

# 50. Decision Rule for Advanced Components (Gelişmiş Bileşenler İçin Karar Kuralı)

An advanced component will not automatically remain in the final architecture merely because it was successfully implemented. *(Gelişmiş bir bileşen yalnızca başarıyla geliştirildiği için otomatik olarak nihai mimaride kalmayacaktır.)*

The component must provide measurable navigation benefit, meaningful robustness, useful diagnostic information, or another clearly justified engineering advantage. *(Bileşen ölçülebilir navigasyon faydası, anlamlı dayanıklılık, kullanışlı tanısal bilgi veya açıkça gerekçelendirilmiş başka bir mühendislik avantajı sağlamalıdır.)*

A simpler architecture will be preferred when two approaches provide practically equivalent performance. *(İki yaklaşım pratik olarak eşdeğer performans sağladığında daha basit mimari tercih edilecektir.)*

This rule applies particularly to ARCore integration, learned step length estimation, and confidence-aware fusion enhancements. *(Bu kural özellikle ARCore entegrasyonu, öğrenilmiş adım uzunluğu tahmini ve güven farkındalıklı füzyon geliştirmeleri için geçerlidir.)*

---

# 51. Research Question to Evidence Mapping (Araştırma Sorusu ve Kanıt Eşleştirmesi)

| Research Question (Araştırma Sorusu) | Required Evidence (Gerekli Kanıt) |
| --- | --- |
| RQ-01 | PDR baseline versus final NAVGUARD position error comparison *(PDR temel yaklaşımı ile nihai NAVGUARD konum hata karşılaştırması)* |
| RQ-02 | Heading baseline versus fused heading measurements *(Temel yön ile füzyonlu yön ölçümleri karşılaştırması)* |
| RQ-03 | PDR versus PDR + ARCore trajectory metrics *(PDR ile PDR + ARCore rota metrikleri karşılaştırması)* |
| RQ-04 | Held-out motion classification test metrics *(Ayrılmış hareket sınıflandırma test metrikleri)* |
| RQ-05 | Navigation behavior with and without motion-aware logic *(Hareket farkındalıklı mantık ile ve olmadan navigasyon davranışı)* |
| RQ-06 | Fixed versus learned step length distance error *(Sabit ve öğrenilmiş adım uzunluğu mesafe hata karşılaştırması)* |
| RQ-07 | On-device latency and resource measurements *(Cihaz üzeri gecikme ve kaynak ölçümleri)* |
| RQ-08 | Multi-route and repeated field-test results *(Çoklu rota ve tekrarlı saha test sonuçları)* |
| RQ-09 | Controlled degraded-sensor comparison *(Kontrollü bozulmuş sensör karşılaştırması)* |

---

# 52. Overall Project Success Matrix (Genel Proje Başarı Matrisi)

| Area (Alan) | Minimum Success (Minimum Başarı) | Target Success (Hedef Başarı) | Extended Success (Genişletilmiş Başarı) |
| --- | --- | --- | --- |
| Navigation (Navigasyon) | Functional PDR *(Çalışan PDR)* | AI-assisted fused navigation *(AI destekli füzyonlu navigasyon)* | Advanced confidence-aware fusion *(Gelişmiş güven farkındalıklı füzyon)* |
| GNSS-Denied Testing (GNSS Kesintili Test) | Functional simulation *(Çalışan simülasyon)* | Reproducible benchmark *(Tekrarlanabilir benchmark)* | Automated comparative analysis *(Otomatik karşılaştırmalı analiz)* |
| Artificial Intelligence (Yapay Zekâ) | Trained on-device classifier *(Eğitilmiş cihaz üzeri sınıflandırıcı)* | Macro F1 ≥ 0.90 *(Macro F1 ≥ 0,90)* | Motion + step-length models *(Hareket + adım uzunluğu modelleri)* |
| ARCore | Optional *(İsteğe Bağlı)* | Integrated and evaluated *(Entegre edilmiş ve değerlendirilmiş)* | Confidence-aware integration *(Güven farkındalıklı entegrasyon)* |
| Fusion (Füzyon) | Basic heading fusion *(Temel yön füzyonu)* | Multi-source position fusion *(Çok kaynaklı konum füzyonu)* | Adaptive weighting *(Uyarlanabilir ağırlıklandırma)* |
| Evaluation (Değerlendirme) | Quantitative error calculation *(Nicel hata hesaplama)* | Matched multi-route comparison *(Eşleştirilmiş çoklu rota karşılaştırması)* | Extensive robustness study *(Kapsamlı dayanıklılık çalışması)* |
| Edge AI | Offline inference *(Çevrimdışı çıkarım)* | Real-time efficient inference *(Gerçek zamanlı verimli çıkarım)* | Detailed power optimization *(Ayrıntılı güç optimizasyonu)* |

---

# 53. Overall Success Statement (Genel Başarı Bildirimi)

**NAVGUARD will be considered technically successful if it produces a stable Android prototype that continues estimating pedestrian position after GNSS input is removed, executes its primary AI model locally, records reproducible evaluation data, and demonstrates measurable navigation performance against an independently recorded GNSS reference.** *(NAVGUARD, GNSS girdisi çıkarıldıktan sonra yaya konumunu tahmin etmeye devam eden, temel yapay zekâ modelini yerel olarak çalıştıran, tekrarlanabilir değerlendirme verileri kaydeden ve bağımsız olarak kaydedilmiş GNSS referansına karşı ölçülebilir navigasyon performansı gösteren kararlı bir Android prototipi üretirse teknik olarak başarılı kabul edilecektir.)*

**Target-level success will additionally require the integrated NAVGUARD configuration to outperform the PDR-only baseline across the final matched evaluation sessions.** *(Hedef seviye başarı ayrıca entegre NAVGUARD yapılandırmasının nihai eşleştirilmiş değerlendirme oturumlarında yalnızca PDR kullanan temel yaklaşımı geçmesini gerektirecektir.)*

---

# 54. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Completed *(Doküman Durumu: Tamamlandı)*

**Threshold Status:** Provisional Until Device Audit and Pilot Testing *(Eşik Durumu: Cihaz Denetimi ve Pilot Testlere Kadar Geçici)*

**Primary Research Question:** RQ-01 *(Birincil Araştırma Sorusu: RQ-01)*

**Primary Navigation Target:** At Least 20% Median Position Error Reduction Relative to PDR Baseline *(Birincil Navigasyon Hedefi: PDR Temel Yaklaşımına Göre En Az %20 Medyan Konum Hatası Azaltımı)*

**Primary AI Target:** Macro F1 ≥ 0.90 *(Birincil Yapay Zekâ Hedefi: Macro F1 ≥ 0,90)*

**Next Documentation Item:** 05 — Target Platform & Device Baseline *(Sonraki Dokümantasyon Öğesi: 05 — Hedef Platform ve Cihaz Temel Referansı)*