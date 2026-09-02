# 26 — Machine Learning Training & Evaluation (Makine Öğrenmesi Eğitim ve Değerlendirme)

## 1. Document Purpose (Dokümanın Amacı)

This document defines the complete machine-learning training, validation, hyperparameter optimization, model comparison, calibration, held-out testing, statistical aggregation, experiment tracking, reproducibility, model promotion, failure analysis, and final evidence protocol for NAVGUARD. *(Bu doküman NAVGUARD için tam makine öğrenmesi eğitimini, doğrulamayı, hiperparametre optimizasyonunu, model karşılaştırmasını, kalibrasyonu, ayrılmış testi, istatistiksel toplulaştırmayı, deney takibini, tekrarlanabilirliği, model promotion sürecini, hata analizini ve nihai kanıt protokolünü tanımlar.)*

The protocol applies primarily to Motion Classification and Step Length Estimation. *(Protokol temel olarak Hareket Sınıflandırması ve Adım Uzunluğu Tahminine uygulanır.)*

The objective is to ensure that final AI claims are supported by unseen-session evidence rather than by accidental data leakage or repeated test tuning. *(Amaç nihai yapay zekâ iddialarının yanlışlıkla oluşan veri sızıntısı veya tekrarlanan test ayarı yerine görülmemiş oturum kanıtıyla desteklenmesini sağlamaktır.)*

---

# 2. Training Philosophy (Eğitim Felsefesi)

NAVGUARD will prefer reproducible experiments over uncontrolled trial-and-error training. *(NAVGUARD kontrolsüz deneme-yanılma eğitimi yerine tekrarlanabilir deneyleri tercih edecektir.)*

Every important model result must be traceable to a dataset version, split manifest, preprocessing version, model configuration, and training run. *(Her önemli model sonucu bir veri seti sürümüne, ayrım manifest'ine, ön işleme sürümüne, model yapılandırmasına ve eğitim run'ına izlenebilir olmalıdır.)*

---

# 3. Evidence Before Complexity (Karmaşıklıktan Önce Kanıt)

A more complex model will be introduced only when simpler baselines leave measurable performance available. *(Daha karmaşık model yalnızca daha basit temel yöntemler ölçülebilir performans fırsatı bıraktığında eklenecektir.)*

Model complexity is not itself a project success criterion. *(Model karmaşıklığı kendi başına proje başarı kriteri değildir.)*

---

# 4. Main ML Tasks (Temel ML Görevleri)

NAVGUARD contains two primary supervised-learning tasks. *(NAVGUARD iki temel supervised-learning görevi içerir.)*

The first is multi-class Motion Classification. *(Birincisi çok sınıflı Hareket Sınıflandırmasıdır.)*

The second is Step Length Regression if reference quality permits supervised regression. *(İkincisi referans kalitesi supervised regresyona izin veriyorsa Adım Uzunluğu Regresyonudur.)*

---

# 5. Motion Classification Model Set (Hareket Sınıflandırma Model Seti)

The planned Motion Classification comparison will include Logistic Regression as a simple baseline. *(Planlanan Hareket Sınıflandırma karşılaştırması basit temel olarak Logistic Regression içerecektir.)*

It will include Random Forest as the primary classical nonlinear baseline. *(Temel klasik doğrusal olmayan model olarak Random Forest içerecektir.)*

It will include at least one lightweight 1D-CNN candidate. *(En az bir hafif 1D-CNN adayı içerecektir.)*

---

# 6. Step Length Model Set (Adım Uzunluğu Model Seti)

The Step Length comparison will include a calibrated fixed-step baseline. *(Adım Uzunluğu karşılaştırması kalibre edilmiş sabit adım temelini içerecektir.)*

It will include a deterministic variable-step baseline. *(Deterministik değişken adım temelini içerecektir.)*

It will include Linear Regression and Random Forest Regressor when supervised labels are adequate. *(Supervised etiketler yeterli olduğunda Linear Regression ve Random Forest Regressor içerecektir.)*

A small neural regressor will remain optional. *(Küçük sinir ağı regresörü isteğe bağlı kalacaktır.)*

---

# 7. Dataset Freeze Before Formal Training (Resmî Eğitimden Önce Veri Seti Sabitleme)

Formal model comparison will use a versioned dataset snapshot. *(Resmî model karşılaştırması sürümlenmiş veri seti anlık görüntüsünü kullanacaktır.)*

The source-session inventory and split manifest will be frozen for that experiment cycle. *(Kaynak oturum envanteri ve ayrım manifest'i o deney döngüsü için sabitlenecektir.)*

---

# 8. Pilot Modeling Versus Formal Modeling (Pilot Modelleme ile Resmî Modelleme)

Exploratory pilot models may be trained before final dataset freeze. *(Keşif amaçlı pilot modeller nihai veri seti sabitlemesinden önce eğitilebilir.)*

Pilot results must not be confused with final benchmark evidence. *(Pilot sonuçlar nihai benchmark kanıtıyla karıştırılmamalıdır.)*

---

# 9. Fundamental Split Rule (Temel Ayrım Kuralı)

The physical recording session remains the fundamental grouping unit. *(Fiziksel kayıt oturumu temel gruplama birimi olarak kalır.)*

No model-ready sample from one physical session may cross train, validation, and final test boundaries. *(Tek fiziksel oturumdan modele hazır hiçbir örnek train, validation ve nihai test sınırlarını geçemez.)*

---

# 10. Group-Aware Splitting (Grup Farkındalıklı Ayrım)

All validation and cross-validation procedures will preserve session groups. *(Tüm doğrulama ve cross-validation prosedürleri oturum gruplarını koruyacaktır.)*

A group identifier will normally correspond to `session_id`. *(Grup tanımlayıcısı normalde `session_id` değerine karşılık gelecektir.)*

---

# 11. Route-Group Alternative (Rota Grubu Alternatifi)

A stricter experiment may use `route_session_id` or route identity as the grouping variable. *(Daha katı deney `route_session_id` veya rota kimliğini gruplama değişkeni olarak kullanabilir.)*

This will be used when route generalization is specifically being evaluated. *(Bu rota genellemesi özellikle değerlendirildiğinde kullanılacaktır.)*

---

# 12. Train Split (Train Ayrımı)

The training split will be used to fit model parameters. *(Train ayrımı model parametrelerini fit etmek için kullanılacaktır.)*

Training-derived statistics will also be calculated only from this split. *(Eğitimden türetilen istatistikler de yalnızca bu ayrımdan hesaplanacaktır.)*

---

# 13. Validation Split (Validation Ayrımı)

The validation split will support architecture selection, hyperparameter tuning, threshold selection, early stopping, and model comparison. *(Validation ayrımı mimari seçimini, hiperparametre ayarını, eşik seçimini, early stopping'i ve model karşılaştırmasını destekleyecektir.)*

---

# 14. Final Test Split (Nihai Test Ayrımı)

The final test split will be used only after the candidate model and preprocessing pipeline have been frozen. *(Nihai test ayrımı yalnızca aday model ve ön işleme hattı sabitlendikten sonra kullanılacaktır.)*

It will provide the principal held-out performance evidence. *(Temel ayrılmış performans kanıtını sağlayacaktır.)*

---

# 15. Test Set Is Not a Tuning Resource (Test Seti Ayar Kaynağı Değildir)

Final test performance must not become an optimization target. *(Nihai test performansı optimizasyon hedefi haline gelmemelidir.)*

Repeatedly changing the model after inspecting final test results destroys the interpretation of the set as untouched evidence. *(Nihai test sonuçları incelendikten sonra modeli tekrar tekrar değiştirmek setin dokunulmamış kanıt olarak yorumlanmasını bozar.)*

---

# 16. New Model After Test Inspection (Test İncelemesinden Sonra Yeni Model)

A materially changed model after final test inspection will be treated as a new experimental cycle. *(Nihai test incelemesinden sonra anlamlı şekilde değiştirilmiş model yeni deney döngüsü olarak ele alınacaktır.)*

Fresh held-out evidence should be used when practical. *(Uygulanabilir olduğunda yeni ayrılmış kanıt kullanılmalıdır.)*

---

# 17. Training Pipeline Overview (Eğitim Hattı Genel Görünümü)

```text id="ml26_01"
Frozen Raw/Derived Dataset
(Sabitlenmiş Ham/Türetilmiş Veri Seti)
        ↓
Leakage Audit
(Veri Sızıntısı Denetimi)
        ↓
Train / Validation / Test Groups
        ↓
Training-Only Preprocessing Fit
        ↓
Baseline Training
        ↓
Candidate Training
        ↓
Validation Comparison
        ↓
Model Selection
        ↓
Configuration Freeze
        ↓
Held-Out Test
        ↓
Mobile Export / Parity
        ↓
Navigation-Level Evaluation
```

---

# 18. Pre-Training Dataset Audit (Eğitim Öncesi Veri Seti Denetimi)

The training pipeline will verify split integrity before fitting any model. *(Eğitim hattı herhangi bir modeli fit etmeden önce ayrım bütünlüğünü doğrulayacaktır.)*

It will verify label validity and sample provenance. *(Etiket geçerliliğini ve örnek kökenini doğrulayacaktır.)*

---

# 19. Required Pre-Training Audits (Gerekli Eğitim Öncesi Denetimler)

The audit will check that no `session_id` appears in multiple splits. *(Denetim hiçbir `session_id` değerinin birden fazla ayrımda bulunmadığını kontrol edecektir.)*

The audit will check that all samples resolve to a known source session. *(Tüm örneklerin bilinen kaynak oturuma çözümlendiğini kontrol edecektir.)*

The audit will check for NaN and infinite feature values. *(NaN ve sonsuz özellik değerlerini kontrol edecektir.)*

---

# 20. Duplicate Audit (Duplicate Denetimi)

Exact duplicate samples across train and test are forbidden. *(Train ve test arasında tam duplicate örnekler yasaktır.)*

Potential near-duplicate cases may also be investigated if dataset-generation logic can create them. *(Veri seti üretim mantığı oluşturabiliyorsa potansiyel near-duplicate durumları da araştırılabilir.)*

---

# 21. Preprocessing Fit Order (Ön İşleme Fit Sırası)

Dataset splitting will occur before normalization or scaling statistics are calculated. *(Veri seti ayrımı normalizasyon veya ölçekleme istatistikleri hesaplanmadan önce gerçekleşecektir.)*

This prevents validation and test information from entering the training representation. *(Bu validation ve test bilgisinin eğitim temsiline girmesini önler.)*

---

# 22. Standardization Example (Standardizasyon Örneği)

```text id="ml26_02"
x_norm =
(x - μ_train) / σ_train
```

Only training data may determine `μ_train` and `σ_train`. *(Yalnızca training verisi `μ_train` ve `σ_train` değerlerini belirleyebilir.)*

---

# 23. Validation and Test Transformation (Validation ve Test Dönüşümü)

Validation and test data will use the frozen training-derived preprocessing parameters. *(Validation ve test verisi sabitlenmiş eğitimden türetilen ön işleme parametrelerini kullanacaktır.)*

They will not calculate their own normalization statistics. *(Kendi normalizasyon istatistiklerini hesaplamayacaklardır.)*

---

# 24. Preprocessing Artifact (Ön İşleme Artifact'ı)

Every formal run will reference a preprocessing artifact or configuration containing the parameters required to reproduce model input. *(Her resmî run model girdisini yeniden üretmek için gerekli parametreleri içeren ön işleme artifact'ına veya yapılandırmasına referans verecektir.)*

---

# 25. Random Seed Policy (Random Seed Politikası)

Important training experiments will record random seeds. *(Önemli eğitim deneyleri random seed'leri kaydedecektir.)*

The seed will cover dataset-order randomization and model initialization where practical. *(Seed uygulanabilir olduğunda veri seti sırası randomizasyonunu ve model başlatmayı kapsayacaktır.)*

---

# 26. Seed Does Not Guarantee Perfect Reproducibility (Seed Kusursuz Tekrarlanabilirliği Garanti Etmez)

A fixed seed improves reproducibility but does not guarantee bit-for-bit identical neural-network execution across every platform and library version. *(Sabit seed tekrarlanabilirliği iyileştirir ancak her platform ve kütüphane sürümünde bit-for-bit aynı sinir ağı çalışmasını garanti etmez.)*

The software environment must therefore also be recorded. *(Bu nedenle yazılım ortamı da kaydedilmelidir.)*

---

# 27. Multiple-Seed Evaluation (Birden Fazla Seed Değerlendirmesi)

Promising neural architectures should be evaluated across multiple seeds when project time permits. *(Umut verici sinir ağı mimarileri proje süresi izin verdiğinde birden fazla seed üzerinde değerlendirilmelidir.)*

This reduces the chance that one unusually favorable initialization determines the winning model. *(Bu tek olağan dışı avantajlı başlatmanın kazanan modeli belirlemesi olasılığını azaltır.)*

---

# 28. Final Seed Policy (Nihai Seed Politikası)

The final benchmark model will reference the exact training seed or seed set that produced the deployed artifact. *(Nihai benchmark modeli deployment artifact'ını üreten kesin eğitim seed'ine veya seed setine referans verecektir.)*

---

# 29. Baseline-First Training (Önce Temel Model Eğitimi)

Formal training will begin with simple baseline methods. *(Resmî eğitim basit temel yöntemlerle başlayacaktır.)*

This establishes the performance level that more complex models must exceed or justify. *(Bu daha karmaşık modellerin geçmesi veya gerekçelendirmesi gereken performans seviyesini oluşturur.)*

---

# 30. Motion Baseline Order (Hareket Temel Model Sırası)

The preferred Motion Classification order is Logistic Regression, Random Forest, then lightweight 1D-CNN. *(Tercih edilen Hareket Sınıflandırma sırası Logistic Regression, Random Forest ve ardından hafif 1D-CNN şeklindedir.)*

---

# 31. Step Length Baseline Order (Adım Uzunluğu Temel Model Sırası)

The preferred Step Length order is calibrated fixed step, deterministic variable step, Linear Regression, and Random Forest Regressor. *(Tercih edilen Adım Uzunluğu sırası kalibre edilmiş sabit adım, deterministik değişken adım, Linear Regression ve Random Forest Regressor şeklindedir.)*

---

# 32. Baseline Configuration Freeze (Temel Model Yapılandırma Sabitleme)

A baseline model will have its own frozen configuration and evaluation evidence. *(Bir temel model kendi sabitlenmiş yapılandırmasına ve değerlendirme kanıtına sahip olacaktır.)*

Baselines will not be changed silently whenever a new candidate is tested. *(Yeni aday her test edildiğinde temel modeller sessizce değiştirilmeyecektir.)*

---

# 33. Motion Classification Training Objective (Hareket Sınıflandırma Eğitim Hedefi)

The classifier will learn to map a causal inertial window to one operational motion class. *(Sınıflandırıcı nedensel ataletsel pencereyi tek operasyonel hareket sınıfına eşlemeyi öğrenecektir.)*

---

# 34. Motion Classification Target Classes (Hareket Sınıflandırma Hedef Sınıfları)

The planned classes remain `STATIONARY`, `WALKING`, `RUNNING`, and `TURNING`. *(Planlanan sınıflar `STATIONARY`, `WALKING`, `RUNNING` ve `TURNING` olarak kalmaktadır.)*

---

# 35. Class Count Review (Sınıf Sayısı İncelemesi)

Training will begin only after per-class independent-session coverage is reviewed. *(Eğitim yalnızca sınıf başına bağımsız oturum kapsamı incelendikten sonra başlayacaktır.)*

Window count alone will not determine whether one class has enough data. *(Tek başına pencere sayısı bir sınıfın yeterli veriye sahip olup olmadığını belirlemeyecektir.)*

---

# 36. Class Imbalance Handling (Sınıf Dengesizliği Yönetimi)

Class imbalance will first be measured. *(Önce sınıf dengesizliği ölçülecektir.)*

NAVGUARD will not apply class weighting automatically before determining whether it is needed. *(NAVGUARD gerekli olup olmadığını belirlemeden class weighting'i otomatik olarak uygulamayacaktır.)*

---

# 37. Class Weighting Candidate (Class Weighting Adayı)

Training-only class weights may be used when imbalance materially affects minority-class performance. *(Dengesizlik azınlık sınıf performansını anlamlı şekilde etkilediğinde yalnızca eğitim verisinden türetilen class weight'ler kullanılabilir.)*

---

# 38. Balanced Sampling Candidate (Dengeli Sampling Adayı)

Balanced sampling may be evaluated as an alternative. *(Dengeli sampling alternatif olarak değerlendirilebilir.)*

Its effect will be judged on validation sessions rather than assumed to be beneficial. *(Etkisi faydalı varsayılmak yerine validation oturumlarında değerlendirilecektir.)*

---

# 39. No Test-Based Rebalancing (Test Tabanlı Yeniden Dengeleme Olmaması)

Final test confusion patterns will not be used to change class weights while preserving the same test as untouched evidence. *(Nihai test confusion örüntüleri aynı testi dokunulmamış kanıt olarak korurken class weight'leri değiştirmek için kullanılmayacaktır.)*

---

# 40. Motion Classification Loss (Hareket Sınıflandırma Loss'u)

A neural classifier may use categorical or sparse categorical cross-entropy depending on label encoding. *(Sinir ağı sınıflandırıcı etiket kodlamasına bağlı olarak categorical veya sparse categorical cross-entropy kullanabilir.)*

---

# 41. Motion Classifier Optimizer (Hareket Sınıflandırıcı Optimizer'ı)

Adam is the initial neural optimizer candidate. *(Adam ilk sinir ağı optimizer adayıdır.)*

The optimizer and learning rate will be part of the stored experiment configuration. *(Optimizer ve learning rate saklanan deney yapılandırmasının parçası olacaktır.)*

---

# 42. Learning Rate Tuning (Learning Rate Ayarı)

Learning rate will be selected using development evidence only. *(Learning rate yalnızca geliştirme kanıtı kullanılarak seçilecektir.)*

Candidate values will not be optimized against final held-out test performance. *(Aday değerler nihai ayrılmış test performansına göre optimize edilmeyecektir.)*

---

# 43. Batch Size Tuning (Batch Boyutu Ayarı)

Batch size may be adjusted for training stability and computational efficiency. *(Batch boyutu eğitim kararlılığı ve hesaplama verimliliği için ayarlanabilir.)*

Batch size will not be treated as a mobile inference property. *(Batch boyutu mobil çıkarım özelliği olarak ele alınmayacaktır.)*

---

# 44. Epoch Limit (Epoch Sınırı)

Every neural training configuration will specify a maximum epoch count. *(Her sinir ağı eğitim yapılandırması maksimum epoch sayısını belirtecektir.)*

This ensures that runs remain reproducible and bounded. *(Bu run'ların tekrarlanabilir ve sınırlı kalmasını sağlar.)*

---

# 45. Early Stopping (Early Stopping)

Early stopping may terminate neural training when the monitored validation metric stops improving. *(İzlenen validation metriği iyileşmeyi durdurduğunda early stopping sinir ağı eğitimini sonlandırabilir.)*

The exact patience and monitored metric will be recorded. *(Kesin patience ve izlenen metrik kaydedilecektir.)*

---

# 46. Early Stopping Does Not Use Test Data (Early Stopping Test Verisini Kullanmaz)

Final test loss or test Macro F1 will never be used as an early-stopping signal. *(Nihai test loss veya test Macro F1 hiçbir zaman early-stopping sinyali olarak kullanılmayacaktır.)*

---

# 47. Best Checkpoint (En İyi Checkpoint)

The best neural checkpoint will be selected according to the predefined validation criterion. *(En iyi sinir ağı checkpoint'i önceden tanımlanmış validation kriterine göre seçilecektir.)*

The final epoch will not automatically be assumed to be the best model. *(Son epoch otomatik olarak en iyi model kabul edilmeyecektir.)*

---

# 48. Regularization (Regularization)

Dropout or weight regularization may be introduced only if training-validation behavior suggests overfitting. *(Dropout veya weight regularization yalnızca training-validation davranışı overfitting gösterirse eklenebilir.)*

---

# 49. Overfitting Evidence (Overfitting Kanıtı)

A sustained improvement in training metrics combined with degraded validation performance may indicate overfitting. *(Training metriklerinde sürekli iyileşme ile birlikte validation performansında bozulma overfitting'i gösterebilir.)*

---

# 50. Underfitting Evidence (Underfitting Kanıtı)

Poor training and validation performance together may indicate insufficient model capacity, poor features, noisy labels, or inadequate data. *(Training ve validation performansının birlikte kötü olması yetersiz model kapasitesini, kötü özellikleri, gürültülü etiketleri veya yetersiz veriyi gösterebilir.)*

---

# 51. Hyperparameter Optimization Philosophy (Hiperparametre Optimizasyonu Felsefesi)

Hyperparameter optimization will be bounded and evidence-driven. *(Hiperparametre optimizasyonu sınırlı ve kanıt güdümlü olacaktır.)*

The project will not launch unnecessarily large search spaces that exceed the value of the problem. *(Proje problemin değerini aşan gereksiz büyük arama uzayları çalıştırmayacaktır.)*

---

# 52. HPO Search Space Must Be Declared (HPO Arama Uzayı Tanımlanmalıdır)

The search space for every formal optimization will be stored before the run. *(Her resmî optimizasyon için arama uzayı run öncesinde saklanacaktır.)*

---

# 53. Random Forest Classification HPO (Random Forest Sınıflandırma HPO'su)

Candidate hyperparameters may include tree count, maximum depth, minimum samples per leaf, and feature-subsampling policy. *(Aday hiperparametreler ağaç sayısını, maksimum derinliği, leaf başına minimum örnek sayısını ve feature-subsampling politikasını içerebilir.)*

---

# 54. 1D-CNN HPO (1D-CNN HPO'su)

Candidate neural hyperparameters may include filter count, kernel size, number of convolution blocks, learning rate, dropout, and dense-head size. *(Aday sinir ağı hiperparametreleri filter sayısını, kernel boyutunu, convolution block sayısını, learning rate'i, dropout'u ve dense-head boyutunu içerebilir.)*

---

# 55. Step Length HPO (Adım Uzunluğu HPO'su)

Random Forest Regressor tuning may include tree count, depth, minimum leaf size, and feature-subsampling settings. *(Random Forest Regressor ayarı ağaç sayısını, derinliği, minimum leaf boyutunu ve feature-subsampling ayarlarını içerebilir.)*

---

# 56. Deterministic Parameter Calibration Is Also Tuning (Deterministik Parametre Kalibrasyonu da Ayardır)

Parameters such as fixed step length or the Weinberg coefficient must be calibrated only on development data. *(Sabit adım uzunluğu veya Weinberg katsayısı gibi parametreler yalnızca geliştirme verisinde kalibre edilmelidir.)*

They must not receive special treatment that bypasses the train-test separation rules. *(Train-test ayrım kurallarını atlayan özel muamele görmemelidirler.)*

---

# 57. Group-Aware Validation During HPO (HPO Sırasında Grup Farkındalıklı Validation)

If cross-validation is used for HPO, folds will preserve session groups. *(HPO için cross-validation kullanılırsa fold'lar oturum gruplarını koruyacaktır.)*

---

# 58. Group Cross-Validation Principle (Group Cross-Validation İlkesi)

No windows or steps derived from one source session may appear in both training and validation folds of the same cross-validation iteration. *(Tek kaynak oturumdan türetilen hiçbir pencere veya adım aynı cross-validation iterasyonunda hem training hem validation fold'unda bulunamaz.)*

---

# 59. Stratification Candidate (Stratification Adayı)

Where group counts allow, class balance may be considered while constructing group-aware validation folds. *(Grup sayıları izin verdiğinde group-aware validation fold'ları oluşturulurken sınıf dengesi dikkate alınabilir.)*

Perfect stratification will not be forced if doing so breaks group isolation. *(Grup izolasyonunu bozuyorsa kusursuz stratification zorlanmayacaktır.)*

---

# 60. Small Dataset Strategy (Küçük Veri Seti Stratejisi)

If the number of independent sessions is limited, repeated group-aware development splits may provide more informative validation than one fragile random split. *(Bağımsız oturum sayısı sınırlıysa tekrarlanan group-aware geliştirme ayrımları tek kırılgan rastgele ayrıma göre daha bilgilendirici validation sağlayabilir.)*

Final held-out evidence will still remain isolated. *(Nihai ayrılmış kanıt yine de izole kalacaktır.)*

---

# 61. Model Selection Metric for Classification (Sınıflandırma İçin Model Seçim Metriği)

Macro F1 will remain the primary Motion Classification model-selection metric. *(Macro F1 Hareket Sınıflandırması için temel model seçim metriği olarak kalacaktır.)*

---

# 62. Why Accuracy Is Secondary (Accuracy Neden İkincildir)

Accuracy can hide weak minority-class performance when class frequencies are uneven. *(Sınıf frekansları eşit olmadığında Accuracy zayıf azınlık sınıf performansını gizleyebilir.)*

Macro F1 gives every class equal contribution to the average. *(Macro F1 ortalamada her sınıfa eşit katkı verir.)*

---

# 63. Required Classification Metrics (Gerekli Sınıflandırma Metrikleri)

The final evaluation will report Accuracy. *(Nihai değerlendirme Accuracy raporlayacaktır.)*

It will report Macro F1. *(Macro F1 raporlayacaktır.)*

It will report per-class precision, recall, and F1. *(Sınıf başına precision, recall ve F1 raporlayacaktır.)*

---

# 64. Confusion Matrix Requirement (Confusion Matrix Gereksinimi)

A confusion matrix is mandatory for final Motion Classification evaluation. *(Confusion matrix nihai Hareket Sınıflandırma değerlendirmesi için zorunludur.)*

Both raw counts and normalized views may be stored. *(Hem ham sayılar hem normalize edilmiş görünümler saklanabilir.)*

---

# 65. Per-Session Classification Metrics (Oturum Başına Sınıflandırma Metrikleri)

NAVGUARD will inspect classification performance at the independent-session level in addition to pooled window metrics. *(NAVGUARD birleştirilmiş pencere metriklerine ek olarak bağımsız oturum seviyesinde sınıflandırma performansını inceleyecektir.)*

---

# 66. Why Session-Level Metrics Matter (Oturum Seviyesi Metrikler Neden Önemlidir)

A high pooled score can hide one session with severe failure. *(Yüksek birleştirilmiş skor ciddi başarısızlığa sahip tek bir oturumu gizleyebilir.)*

Session-level analysis reveals this instability. *(Oturum seviyesi analiz bu kararsızlığı ortaya çıkarır.)*

---

# 67. Provisional Classification Success Gate (Geçici Sınıflandırma Başarı Kapısı)

The provisional held-out target remains Macro F1 `≥ 0.90`. *(Geçici ayrılmış hedef Macro F1 `≥ 0.90` olarak kalmaktadır.)*

This value is a target and not a fabricated measured result. *(Bu değer hedeftir ve uydurulmuş ölçülmüş sonuç değildir.)*

---

# 68. Aggregate Target Is Not Sufficient Alone (Aggregate Hedef Tek Başına Yeterli Değildir)

A classifier may still be withheld from navigation if one navigation-critical class performs unacceptably despite passing the aggregate Macro F1 gate. *(Bir sınıflandırıcı aggregate Macro F1 kapısını geçmesine rağmen navigasyon açısından kritik bir sınıf kabul edilemez performans gösteriyorsa yine de navigasyondan uzak tutulabilir.)*

---

# 69. Critical Error Analysis (Kritik Hata Analizi)

Errors such as `STATIONARY → WALKING` will be analyzed because they may cause false movement propagation. *(`STATIONARY → WALKING` gibi hatalar yanlış hareket ilerletmesine neden olabilecekleri için analiz edilecektir.)*

---

# 70. TURNING Error Analysis (TURNING Hata Analizi)

`TURNING` errors will be reviewed separately because they can affect heading-context behavior. *(`TURNING` hataları yön bağlamı davranışını etkileyebilecekleri için ayrı incelenecektir.)*

---

# 71. RUNNING Error Analysis (RUNNING Hata Analizi)

`RUNNING` performance will determine whether running-specific PDR logic is safe to enable. *(`RUNNING` performansı koşmaya özgü PDR mantığının güvenli şekilde etkinleştirilip etkinleştirilemeyeceğini belirleyecektir.)*

---

# 72. Classification Calibration (Sınıflandırma Kalibrasyonu)

Confidence calibration may be evaluated after a strong classifier exists. *(Güçlü sınıflandırıcı mevcut olduktan sonra güven kalibrasyonu değerlendirilebilir.)*

Calibration is not required merely to report class predictions. *(Kalibrasyon yalnızca sınıf tahminlerini raporlamak için gerekli değildir.)*

---

# 73. Why Calibration May Matter (Kalibrasyon Neden Önemli Olabilir)

If confidence is used to control navigation transitions, the quality of confidence values becomes operationally important. *(Güven navigasyon geçişlerini kontrol etmek için kullanılırsa güven değerlerinin kalitesi operasyonel olarak önemli hale gelir.)*

---

# 74. Uncalibrated Confidence (Kalibre Edilmemiş Güven)

Uncalibrated Softmax output will be treated as a model score rather than a guaranteed correctness probability. *(Kalibre edilmemiş Softmax çıktısı garantili doğruluk olasılığı yerine model skoru olarak ele alınacaktır.)*

---

# 75. Calibration Data Rule (Kalibrasyon Verisi Kuralı)

Any calibration model or confidence threshold will be fitted using development data only. *(Herhangi bir kalibrasyon modeli veya güven eşiği yalnızca geliştirme verisi kullanılarak fit edilecektir.)*

---

# 76. Calibration Methods Candidate (Kalibrasyon Yöntemleri Adayı)

Temperature scaling may be considered for neural classification confidence. *(Temperature scaling sinir ağı sınıflandırma güveni için değerlendirilebilir.)*

Other simple calibration methods may be considered only if they add measurable value. *(Diğer basit kalibrasyon yöntemleri yalnızca ölçülebilir fayda eklerse değerlendirilebilir.)*

---

# 77. Confidence Gate Tuning (Güven Kapısı Ayarı)

A navigation confidence threshold will be selected on validation data if such a threshold is retained. *(Böyle bir eşik korunursa navigasyon güven eşiği validation verisinde seçilecektir.)*

---

# 78. Temporal Smoothing Evaluation (Zamansal Smoothing Değerlendirmesi)

Raw classification performance and smoothed operational classification performance will be distinguished. *(Ham sınıflandırma performansı ile smoothing uygulanmış operasyonel sınıflandırma performansı ayrılacaktır.)*

---

# 79. Smoothing Is a Post-Model Component (Smoothing Model Sonrası Bileşendir)

Temporal smoothing does not change the underlying model probabilities but changes how predictions become navigation context. *(Zamansal smoothing temel model olasılıklarını değiştirmez ancak tahminlerin nasıl navigasyon bağlamına dönüştüğünü değiştirir.)*

---

# 80. Transition Metrics (Geçiş Metrikleri)

Transition latency will be measured. *(Geçiş gecikmesi ölçülecektir.)*

False rapid state changes will also be measured. *(Yanlış hızlı durum değişiklikleri de ölçülecektir.)*

---

# 81. Step Length Evaluation Principle (Adım Uzunluğu Değerlendirme İlkesi)

Step Length evaluation metrics will depend on reference-label granularity. *(Adım Uzunluğu değerlendirme metrikleri referans etiket granülerliğine bağlı olacaktır.)*

NAVGUARD will not report unsupported per-step precision. *(NAVGUARD desteklenmeyen adım başına hassasiyet raporlamayacaktır.)*

---

# 82. Per-Step Regression Metrics (Adım Başına Regresyon Metrikleri)

When valid per-step references exist, MAE may be reported. *(Geçerli adım başına referanslar mevcut olduğunda MAE raporlanabilir.)*

RMSE and signed bias may also be reported. *(RMSE ve işaretli bias da raporlanabilir.)*

---

# 83. Segment-Level Evaluation (Segment Seviyesi Değerlendirme)

If labels are segment averages, error will be evaluated at segment level. *(Etiketler segment ortalamalarıysa hata segment seviyesinde değerlendirilecektir.)*

---

# 84. Route-Level Evaluation (Rota Seviyesi Değerlendirme)

If only route-level reference is reliable, total predicted travelled distance will be compared with route reference distance. *(Yalnızca rota seviyesi referans güvenilir ise toplam tahmin edilen kat edilen mesafe rota referans mesafesiyle karşılaştırılacaktır.)*

---

# 85. Route Distance Formula (Rota Mesafe Formülü)

```text id="ml26_03"
D_hat =
Σ L_hat_k
```

---

# 86. Route Distance Error (Rota Mesafe Hatası)

```text id="ml26_04"
E_route =
|D_hat - D_ref|
```

---

# 87. Signed Distance Bias (İşaretli Mesafe Bias'ı)

Signed error will be preserved to detect systematic overestimation or underestimation. *(Sistematik fazla veya eksik tahmini tespit etmek için işaretli hata korunacaktır.)*

---

# 88. Step Length Model Selection Metric (Adım Uzunluğu Model Seçim Metriği)

The final step-length model will not be selected by one regression metric alone. *(Nihai adım uzunluğu modeli tek bir regresyon metriğiyle seçilmeyecektir.)*

Route-level error, bias, consistency, runtime cost, and downstream PDR effect will also be considered. *(Rota seviyesi hata, bias, tutarlılık, çalışma zamanı maliyeti ve aşağı akış PDR etkisi de değerlendirilecektir.)*

---

# 89. Deterministic Baseline Comparison (Deterministik Temel Karşılaştırması)

A learned step-length model must be compared with the selected deterministic variable-step baseline. *(Öğrenilmiş adım uzunluğu modeli seçilen deterministik değişken adım temeliyle karşılaştırılmalıdır.)*

---

# 90. Learned Model Retention Rule (Öğrenilmiş Model Koruma Kuralı)

The learned model will be retained only if held-out improvement is consistent and practically meaningful. *(Öğrenilmiş model yalnızca ayrılmış iyileştirme tutarlı ve pratik olarak anlamlıysa korunacaktır.)*

---

# 91. No Arbitrary Improvement Percentage (Keyfi İyileştirme Yüzdesi Olmaması)

No fixed percentage improvement will be invented before experimental data exists. *(Deneysel veri mevcut olmadan sabit yüzde iyileştirme uydurulmayacaktır.)*

---

# 92. Session-Level Regression Review (Oturum Seviyesi Regresyon İncelemesi)

Step-length results will be inspected per independent route session. *(Adım uzunluğu sonuçları bağımsız rota oturumu başına incelenecektir.)*

---

# 93. Regression Residual Analysis (Regresyon Residual Analizi)

Residuals will be analyzed by motion context and route characteristics where reference quality permits. *(Referans kalitesi izin verdiğinde residual'lar hareket bağlamına ve rota özelliklerine göre analiz edilecektir.)*

---

# 94. Motion-Conditioned Regression (Harekete Koşullu Regresyon)

Walking and running may be analyzed separately when sufficient data exists. *(Yeterli veri mevcut olduğunda yürüyüş ve koşma ayrı analiz edilebilir.)*

---

# 95. Turning Regression Analysis (Dönüş Regresyon Analizi)

Turning steps may be inspected separately to determine whether the standard walking model has systematic error. *(Dönüş adımları standart yürüyüş modelinin sistematik hataya sahip olup olmadığını belirlemek için ayrı incelenebilir.)*

---

# 96. HPO Objective for Classification (Sınıflandırma İçin HPO Hedefi)

Classification HPO will optimize a validation metric aligned with project goals. *(Sınıflandırma HPO'su proje hedefleriyle uyumlu validation metriğini optimize edecektir.)*

Macro F1 is the preferred primary objective. *(Macro F1 tercih edilen temel hedeftir.)*

---

# 97. HPO Objective for Regression (Regresyon İçin HPO Hedefi)

Regression HPO will use a metric consistent with available reference quality. *(Regresyon HPO'su mevcut referans kalitesiyle uyumlu metrik kullanacaktır.)*

MAE may be used where valid per-sample targets exist. *(Geçerli örnek başına hedefler mevcut olduğunda MAE kullanılabilir.)*

---

# 98. Composite Model Selection (Bileşik Model Seçimi)

Final promotion decisions may consider multiple metrics rather than a single optimization objective. *(Nihai promotion kararları tek optimizasyon hedefi yerine birden fazla metriği değerlendirebilir.)*

---

# 99. Experiment Configuration Object (Deney Yapılandırma Nesnesi)

```text id="ml26_05"
ExperimentConfig
- experimentId
- task
- datasetId
- splitManifestId
- preprocessingVersion
- modelType
- modelHyperparameters
- trainingSeed
- trainingParameters
- selectionMetric
- calibrationPolicy
- notes
```

---

# 100. Unique Experiment ID (Benzersiz Deney ID'si)

Every formal training run will have a unique experiment identifier. *(Her resmî eğitim run'ı benzersiz deney tanımlayıcısına sahip olacaktır.)*

---

# 101. Experiment Directory Candidate (Deney Klasör Adayı)

```text id="ml26_06"
ml/
└── experiments/
    └── <experiment_id>/
        ├── config.json
        ├── metrics.json
        ├── logs/
        ├── checkpoints/
        ├── plots/
        └── artifacts/
```

---

# 102. Training Environment Manifest (Eğitim Ortam Manifest'i)

Important software environment information will be recorded. *(Önemli yazılım ortam bilgisi kaydedilecektir.)*

This includes Python and major ML-library versions. *(Bu Python ve temel ML kütüphane sürümlerini içerir.)*

---

# 103. Exact Version Freeze Timing (Kesin Sürüm Sabitleme Zamanı)

Exact package versions will be frozen during environment bootstrap rather than guessed before implementation. *(Kesin paket sürümleri uygulama öncesinde tahmin edilmek yerine ortam bootstrap sırasında sabitlenecektir.)*

---

# 104. Training Logs (Eğitim Kayıtları)

Neural training runs will record training and validation loss by epoch. *(Sinir ağı eğitim run'ları epoch başına training ve validation loss kaydedecektir.)*

Relevant classification metrics may also be recorded by epoch. *(İlgili sınıflandırma metrikleri de epoch başına kaydedilebilir.)*

---

# 105. Classical Model Logs (Klasik Model Kayıtları)

Classical model runs will preserve hyperparameters, training duration, validation metrics, and feature schema. *(Klasik model run'ları hiperparametreleri, eğitim süresini, validation metriklerini ve özellik şemasını koruyacaktır.)*

---

# 106. Failed Runs Are Evidence (Başarısız Run'lar Kanıttır)

Failed training runs will not necessarily be deleted. *(Başarısız eğitim run'ları mutlaka silinmeyecektir.)*

Important failures may be preserved with failure reason and configuration. *(Önemli başarısızlıklar başarısızlık nedeni ve yapılandırmayla korunabilir.)*

---

# 107. Training Failure Codes (Eğitim Hata Kodları)

```text id="ml26_07"
DATASET_VALIDATION_FAILED
SPLIT_LEAKAGE_DETECTED
INVALID_LABELS
NUMERICAL_FAILURE
TRAINING_DIVERGED
OUT_OF_MEMORY
EXPORT_FAILED
PARITY_FAILED
MODEL_PROMOTION_REJECTED
```

---

# 108. Neural Divergence Handling (Sinir Ağı Divergence Yönetimi)

NaN loss or unstable optimization will invalidate the corresponding run. *(NaN loss veya kararsız optimizasyon ilgili run'ı geçersiz kılacaktır.)*

The cause will be investigated before retrying. *(Tekrar denemeden önce neden araştırılacaktır.)*

---

# 109. Training Duration Is Diagnostic (Eğitim Süresi Tanısaldır)

Training duration may be recorded for engineering convenience. *(Eğitim süresi mühendislik kolaylığı için kaydedilebilir.)*

It will not be treated as a primary research-performance metric. *(Temel araştırma performans metriği olarak ele alınmayacaktır.)*

---

# 110. Feature Ablation Experiments (Özellik Ablation Deneyleri)

NAVGUARD will use controlled ablation experiments to determine whether optional features add value. *(NAVGUARD isteğe bağlı özelliklerin değer katıp katmadığını belirlemek için kontrollü ablation deneyleri kullanacaktır.)*

---

# 111. Motion Feature Ablation (Hareket Özellik Ablation)

The Motion Classification model may compare accelerometer-only input with accelerometer-plus-gyroscope input. *(Hareket Sınıflandırma modeli yalnızca ivmeölçer girdisini ivmeölçer-artı-jiroskop girdisiyle karşılaştırabilir.)*

---

# 112. Derived Magnitude Ablation (Türetilmiş Büyüklük Ablation)

Derived acceleration or gyroscope magnitude channels may be enabled and disabled under the same split. *(Türetilmiş ivme veya jiroskop büyüklük kanalları aynı ayrım altında açılıp kapatılabilir.)*

---

# 113. Window Length Ablation (Pencere Uzunluğu Ablation)

Motion window lengths may be compared using the same source-session partitions. *(Hareket pencere uzunlukları aynı kaynak oturum bölümleri kullanılarak karşılaştırılabilir.)*

---

# 114. Overlap Ablation (Örtüşme Ablation)

Window overlap may be evaluated for its effect on prediction cadence, runtime, and transition stability. *(Pencere örtüşmesi tahmin kadansı, çalışma zamanı ve geçiş kararlılığı üzerindeki etkisi açısından değerlendirilebilir.)*

---

# 115. Step Length Feature Ablation (Adım Uzunluğu Özellik Ablation)

Cadence, acceleration range, detector confidence, motion class, and other candidate features may be removed one at a time. *(Kadans, ivme aralığı, algılayıcı güveni, hareket sınıfı ve diğer aday özellikler birer birer kaldırılabilir.)*

---

# 116. Ablation Must Use Comparable Data (Ablation Karşılaştırılabilir Veri Kullanmalıdır)

Ablation experiments must use the same relevant train-validation groups when possible. *(Ablation deneyleri mümkün olduğunda aynı ilgili train-validation gruplarını kullanmalıdır.)*

---

# 117. Model Ablation (Model Ablation)

Classification model architecture comparison will use the same frozen dataset version and split manifest. *(Sınıflandırma model mimarisi karşılaştırması aynı sabitlenmiş veri seti sürümünü ve ayrım manifest'ini kullanacaktır.)*

---

# 118. Navigation-Level Ablation Is Separate (Navigasyon Seviyesi Ablation Ayrıdır)

A model can win the ML comparison but still fail to provide meaningful downstream navigation improvement. *(Bir model ML karşılaştırmasını kazanabilir ancak yine de anlamlı aşağı akış navigasyon iyileştirmesi sağlayamayabilir.)*

Navigation-level evaluation will therefore occur after model-level validation. *(Bu nedenle navigasyon seviyesi değerlendirme model seviyesi doğrulamadan sonra gerçekleşecektir.)*

---

# 119. Motion AI Navigation Ablation (Hareket Yapay Zekâsı Navigasyon Ablation)

The same recorded session may be replayed with motion-AI navigation effects disabled and enabled. *(Aynı kaydedilmiş oturum hareket yapay zekâ navigasyon etkileri kapalı ve açık olarak replay edilebilir.)*

---

# 120. Step Length Navigation Ablation (Adım Uzunluğu Navigasyon Ablation)

The same accepted steps and heading sequence may be replayed using different step-length estimators. *(Aynı kabul edilmiş adımlar ve yön dizisi farklı adım uzunluğu tahmin motorları kullanılarak replay edilebilir.)*

---

# 121. Model Promotion Lifecycle (Model Promotion Yaşam Döngüsü)

```text id="ml26_08"
EXPERIMENTAL
↓
VALIDATION_CANDIDATE
↓
OFFLINE_VALIDATED
↓
SHADOW_VALIDATED
↓
NAVIGATION_ENABLED
```

A model may stop at any stage. *(Bir model herhangi bir aşamada durabilir.)*

---

# 122. EXPERIMENTAL State (EXPERIMENTAL Durumu)

A newly trained model starts as experimental. *(Yeni eğitilmiş model experimental olarak başlar.)*

It is not allowed to affect formal navigation. *(Resmî navigasyonu etkilemesine izin verilmez.)*

---

# 123. VALIDATION_CANDIDATE State (VALIDATION_CANDIDATE Durumu)

A model becomes a validation candidate after basic correctness and data-integrity checks pass. *(Bir model temel doğruluk ve veri bütünlüğü kontrolleri geçtikten sonra validation adayı olur.)*

---

# 124. OFFLINE_VALIDATED State (OFFLINE_VALIDATED Durumu)

A model reaches offline validation after satisfying the predefined development-performance criteria. *(Bir model önceden tanımlanmış geliştirme performans kriterlerini karşıladıktan sonra offline validation durumuna ulaşır.)*

---

# 125. SHADOW_VALIDATED State (SHADOW_VALIDATED Durumu)

A model reaches shadow validation after successful mobile execution without affecting active navigation. *(Bir model aktif navigasyonu etkilemeden başarılı mobil çalıştırma sonrasında shadow validation durumuna ulaşır.)*

---

# 126. NAVIGATION_ENABLED State (NAVIGATION_ENABLED Durumu)

Only a model passing both model-level and mobile-runtime gates may become navigation-enabled. *(Yalnızca hem model seviyesi hem mobil çalışma zamanı kapılarını geçen model navigation-enabled olabilir.)*

---

# 127. Promotion Is Not Automatic (Promotion Otomatik Değildir)

Passing one metric does not automatically promote a model. *(Tek metriği geçmek modeli otomatik olarak promote etmez.)*

All mandatory integrity and runtime gates must also pass. *(Tüm zorunlu bütünlük ve çalışma zamanı kapıları da geçmelidir.)*

---

# 128. Motion Classifier Offline Promotion Gate (Hareket Sınıflandırıcı Offline Promotion Kapısı)

The provisional main performance gate is held-out development Macro F1 consistent with the project target. *(Geçici temel performans kapısı proje hedefiyle tutarlı ayrılmış geliştirme Macro F1 değeridir.)*

The target remains `≥ 0.90`. *(Hedef `≥ 0.90` olarak kalmaktadır.)*

---

# 129. Per-Class Promotion Review (Sınıf Başına Promotion İncelemesi)

No critical class may show clearly unacceptable behavior hidden by the aggregate score. *(Hiçbir kritik sınıf aggregate skor tarafından gizlenen açık şekilde kabul edilemez davranış göstermemelidir.)*

---

# 130. Step Length Promotion Gate (Adım Uzunluğu Promotion Kapısı)

A learned step-length model must outperform or meaningfully improve upon the retained deterministic baseline on held-out development evidence. *(Öğrenilmiş adım uzunluğu modeli ayrılmış geliştirme kanıtında korunan deterministik temel yöntemi geçmeli veya anlamlı şekilde iyileştirmelidir.)*

---

# 131. Runtime Promotion Gate (Çalışma Zamanı Promotion Kapısı)

A model must load and execute reliably on the Redmi Note 9 Pro before navigation enablement. *(Bir model navigasyon etkinleştirmesinden önce Redmi Note 9 Pro üzerinde güvenilir şekilde yüklenip çalışmalıdır.)*

---

# 132. Preprocessing Parity Gate (Ön İşleme Eşdeğerlik Kapısı)

Python and Android input preprocessing must match within the defined numerical tolerance. *(Python ve Android girdi ön işlemesi tanımlanan sayısal tolerans içerisinde eşleşmelidir.)*

---

# 133. Output Parity Gate (Çıktı Eşdeğerlik Kapısı)

Equivalent model input must produce equivalent reference and Android outputs within accepted tolerance. *(Eşdeğer model girdisi kabul edilmiş tolerans içerisinde eşdeğer referans ve Android çıktıları üretmelidir.)*

---

# 134. Latency Gate (Gecikme Kapısı)

The provisional motion-inference runtime target remains below `50 ms` per inference on the Redmi Note 9 Pro. *(Geçici hareket çıkarım çalışma zamanı hedefi Redmi Note 9 Pro üzerinde çıkarım başına `50 ms` altı olarak kalmaktadır.)*

---

# 135. Latency Is Not the Only Runtime Metric (Gecikme Tek Çalışma Zamanı Metriği Değildir)

Sustained stability, queue behavior, memory, and thermal impact will also be evaluated. *(Sürekli kararlılık, kuyruk davranışı, bellek ve termal etki de değerlendirilecektir.)*

---

# 136. Mobile Shadow Evaluation (Mobil Gölge Değerlendirmesi)

Shadow-mode logs will compare mobile predictions with offline reference predictions and annotated activity where available. *(Gölge modu kayıtları mobil tahminleri çevrimdışı referans tahminleri ve mevcut olduğunda annotate edilmiş aktiviteyle karşılaştıracaktır.)*

---

# 137. Distribution Shift Review (Dağılım Kayması İncelemesi)

Large performance differences between offline and live-device sessions may indicate preprocessing mismatch or distribution shift. *(Çevrimdışı ve canlı cihaz oturumları arasındaki büyük performans farkları ön işleme uyuşmazlığını veya dağılım kaymasını gösterebilir.)*

---

# 138. Dataset Shift Is Not Automatically a Model Bug (Veri Seti Kayması Otomatik Olarak Model Hatası Değildir)

A live environment may differ from the controlled training data. *(Canlı ortam kontrollü eğitim verisinden farklı olabilir.)*

The root cause must therefore be analyzed before changing the model. *(Bu nedenle model değiştirilmeden önce temel neden analiz edilmelidir.)*

---

# 139. Confidence Threshold Validation (Güven Eşiği Doğrulaması)

If a confidence gate is used, its effect on classification coverage and error rate will be reported. *(Güven kapısı kullanılırsa sınıflandırma kapsamı ve hata oranı üzerindeki etkisi raporlanacaktır.)*

---

# 140. Prediction Coverage Metric (Tahmin Kapsama Metriği)

```text id="ml26_09"
Coverage =
accepted_predictions
────────────────── × 100
all_predictions
```

A very strict confidence gate may improve precision while reducing useful coverage. *(Çok katı güven kapısı precision'ı iyileştirirken kullanışlı kapsamı azaltabilir.)*

---

# 141. Unknown-State Rate (UNKNOWN Durumu Oranı)

If low-confidence predictions map to `UNKNOWN`, the frequency of `UNKNOWN` will be measured. *(Düşük güvenli tahminler `UNKNOWN` durumuna eşlenirse `UNKNOWN` sıklığı ölçülecektir.)*

---

# 142. Confusion Matrix by Session (Oturum Bazlı Confusion Matrix)

Difficult sessions may receive their own confusion matrix for diagnostic analysis. *(Zor oturumlar tanısal analiz için kendi confusion matrix'lerini alabilir.)*

---

# 143. Confusion Matrix by Environment (Ortam Bazlı Confusion Matrix)

If sufficient data exists, indoor and outdoor confusion patterns may be compared. *(Yeterli veri mevcutsa iç ve dış mekân confusion örüntüleri karşılaştırılabilir.)*

This remains secondary analysis. *(Bu ikincil analiz olarak kalır.)*

---

# 144. Statistical Aggregation Philosophy (İstatistiksel Toplulaştırma Felsefesi)

NAVGUARD will not rely only on one pooled average. *(NAVGUARD yalnızca tek bir birleştirilmiş ortalamaya dayanmayacaktır.)*

Independent-session variability will also be visible. *(Bağımsız oturum değişkenliği de görünür olacaktır.)*

---

# 145. Classification Aggregation (Sınıflandırma Toplulaştırması)

Pooled window metrics will be reported for standard ML comparison. *(Standart ML karşılaştırması için birleştirilmiş pencere metrikleri raporlanacaktır.)*

Session-level metrics will provide complementary robustness evidence. *(Oturum seviyesi metrikler tamamlayıcı dayanıklılık kanıtı sağlayacaktır.)*

---

# 146. Regression Aggregation (Regresyon Toplulaştırması)

Regression results will preserve route-session-level error in addition to pooled residual metrics. *(Regresyon sonuçları birleştirilmiş residual metriklere ek olarak rota-oturumu seviyesi hatayı koruyacaktır.)*

---

# 147. Median as Robust Summary (Robust Özet Olarak Medyan)

Median session performance may be used as a robust summary when distributions are skewed. *(Dağılımlar çarpık olduğunda medyan oturum performansı robust özet olarak kullanılabilir.)*

---

# 148. Percentiles (Yüzdelikler)

Selected percentiles may be reported for latency, error, or confidence where useful. *(Kullanışlı olduğunda gecikme, hata veya güven için seçilmiş yüzdelikler raporlanabilir.)*

---

# 149. No False Statistical Significance (Sahte İstatistiksel Anlamlılık Olmaması)

NAVGUARD will not claim strong statistical significance from a very small number of independent sessions without appropriate justification. *(NAVGUARD uygun gerekçe olmadan çok az sayıda bağımsız oturumdan güçlü istatistiksel anlamlılık iddia etmeyecektir.)*

---

# 150. Effect Size Before Significance (Anlamlılıktan Önce Etki Büyüklüğü)

Practical effect size and consistency across sessions will be emphasized. *(Pratik etki büyüklüğü ve oturumlar arası tutarlılık vurgulanacaktır.)*

---

# 151. Bootstrap Candidate (Bootstrap Adayı)

Bootstrap confidence intervals may be considered for descriptive uncertainty if the independent-session count becomes sufficient. *(Bağımsız oturum sayısı yeterli hale gelirse tanımlayıcı belirsizlik için bootstrap güven aralıkları değerlendirilebilir.)*

Session-level resampling is preferred over naive window-level resampling for independence-sensitive analysis. *(Bağımsızlık hassas analiz için saf pencere seviyesi yeniden örnekleme yerine oturum seviyesi yeniden örnekleme tercih edilir.)*

---

# 152. Model Comparison Table — Classification (Model Karşılaştırma Tablosu — Sınıflandırma)

```text id="ml26_10"
Model
Validation Macro F1
Validation Accuracy
STATIONARY F1
WALKING F1
RUNNING F1
TURNING F1
Model Size
Median Mobile Latency
P95 Mobile Latency
Navigation Status
```

---

# 153. Model Comparison Table — Regression (Model Karşılaştırma Tablosu — Regresyon)

```text id="ml26_11"
Method
Label Level
MAE
RMSE
Bias
Route Error
Route Error %
PDR Error
Runtime Cost
Fallback Rate
```

---

# 154. Baseline Must Appear in Final Tables (Temel Model Nihai Tablolarda Görünmelidir)

Final reports will retain baseline results rather than presenting only the winning model. *(Nihai raporlar yalnızca kazanan modeli sunmak yerine temel yöntem sonuçlarını koruyacaktır.)*

This makes improvement claims auditable. *(Bu iyileştirme iddialarını denetlenebilir hale getirir.)*

---

# 155. Final Test Is Performed After Freeze (Nihai Test Sabitlemeden Sonra Yapılır)

The selected model, preprocessing pipeline, thresholds, smoothing rules, and class mapping will be frozen before final test execution. *(Seçilen model, ön işleme hattı, eşikler, smoothing kuralları ve sınıf eşlemesi nihai test çalıştırılmadan önce sabitlenecektir.)*

---

# 156. Test Configuration Snapshot (Test Yapılandırma Anlık Görüntüsü)

```text id="ml26_12"
modelId
modelVersion
datasetId
testSplitManifestId
preprocessingVersion
thresholdConfig
smoothingConfig
runtimeConfig
```

---

# 157. Held-Out Classification Output (Ayrılmış Sınıflandırma Çıktısı)

Every final test prediction will be stored. *(Her nihai test tahmini saklanacaktır.)*

This allows metrics to be recomputed independently. *(Bu metriklerin bağımsız olarak yeniden hesaplanmasına izin verir.)*

---

# 158. Held-Out Regression Output (Ayrılmış Regresyon Çıktısı)

Every available test reference and corresponding prediction will be preserved according to its label granularity. *(Mevcut her test referansı ve karşılık gelen tahmin etiket granülerliğine göre korunacaktır.)*

---

# 159. No Hidden Sample Removal (Gizli Örnek Silme Olmaması)

Final test samples will not be removed because the model predicts them poorly. *(Nihai test örnekleri model onları kötü tahmin ettiği için kaldırılmayacaktır.)*

---

# 160. Valid Exclusions Must Predate Model Result Review (Geçerli Hariç Tutmalar Model Sonucu İncelemesinden Önce Olmalıdır)

Final test exclusion rules should be defined before model predictions are examined. *(Nihai test hariç tutma kuralları model tahminleri incelenmeden önce tanımlanmalıdır.)*

---

# 161. Post-Test Error Analysis (Test Sonrası Hata Analizi)

After final metrics are frozen, qualitative and quantitative error analysis may be performed. *(Nihai metrikler sabitlendikten sonra nitel ve nicel hata analizi yapılabilir.)*

This analysis will identify limitations rather than retroactively improve the reported test result. *(Bu analiz raporlanan test sonucunu geriye dönük iyileştirmek yerine sınırlamaları belirleyecektir.)*

---

# 162. Failure Case Categories (Hata Durumu Kategorileri)

Motion errors may be grouped by transition, environment, class pair, confidence, and session. *(Hareket hataları geçiş, ortam, sınıf çifti, güven ve oturuma göre gruplanabilir.)*

Step-length errors may be grouped by gait intensity, turning, route, and feature range. *(Adım uzunluğu hataları gait yoğunluğu, dönüş, rota ve özellik aralığına göre gruplanabilir.)*

---

# 163. Model Promotion Can Still Be Rejected After Good Test Score (İyi Test Skorundan Sonra Bile Model Promotion Reddedilebilir)

A model with good ML metrics may still be unsuitable for mobile navigation because of latency, instability, or poor operational transitions. *(İyi ML metriklerine sahip model gecikme, kararsızlık veya kötü operasyonel geçişler nedeniyle yine de mobil navigasyon için uygun olmayabilir.)*

---

# 164. Navigation Impact Gate (Navigasyon Etkisi Kapısı)

AI will affect final navigation only when its integration demonstrates acceptable behavior in replay and live tests. *(Yapay zekâ yalnızca entegrasyonu replay ve canlı testlerde kabul edilebilir davranış gösterdiğinde nihai navigasyonu etkileyecektir.)*

---

# 165. Motion AI System-Level Evaluation (Hareket Yapay Zekâsı Sistem Seviyesi Değerlendirme)

The system may compare false step propagation during stationary intervals with motion AI disabled and enabled. *(Sistem hareket yapay zekâsı kapalı ve açıkken sabit aralıklardaki yanlış adım ilerletmesini karşılaştırabilir.)*

---

# 166. Step Length System-Level Evaluation (Adım Uzunluğu Sistem Seviyesi Değerlendirme)

The system will compare PDR distance or position error across retained step-length methods under matched sensor inputs. *(Sistem eşleştirilmiş sensör girdileri altında korunan adım uzunluğu yöntemleri arasında PDR mesafe veya konum hatasını karşılaştıracaktır.)*

---

# 167. Combined AI Evaluation (Birleşik Yapay Zekâ Değerlendirmesi)

A final full NAVGUARD configuration may combine motion classification and the retained step-length estimator. *(Nihai tam NAVGUARD yapılandırması hareket sınıflandırmasını ve korunan adım uzunluğu tahmin motorunu birleştirebilir.)*

Its contribution will be evaluated within the wider A-D navigation benchmark framework. *(Katkısı daha geniş A-D navigasyon benchmark çerçevesi içerisinde değerlendirilecektir.)*

---

# 168. Configuration A Relationship (Yapılandırma A İlişkisi)

Configuration A remains the PDR-only baseline. *(Yapılandırma A yalnızca PDR temelidir.)*

---

# 169. Configuration B Relationship (Yapılandırma B İlişkisi)

Configuration B adds improved or fused heading. *(Yapılandırma B geliştirilmiş veya füzyonlu yön ekler.)*

---

# 170. Configuration C Relationship (Yapılandırma C İlişkisi)

Configuration C adds ARCore relative-motion support. *(Yapılandırma C ARCore göreli hareket desteği ekler.)*

---

# 171. Configuration D Relationship (Yapılandırma D İlişkisi)

Configuration D represents the complete validated NAVGUARD fusion stack and may include AI-assisted motion context and learned step length if they pass retention gates. *(Yapılandırma D tam doğrulanmış NAVGUARD füzyon yığınını temsil eder ve retention kapılarını geçerlerse yapay zekâ destekli hareket bağlamını ve öğrenilmiş adım uzunluğunu içerebilir.)*

---

# 172. AI Is Not Mandatory for Every Configuration (Yapay Zekâ Her Yapılandırma İçin Zorunlu Değildir)

Baseline configurations will remain available without AI to isolate AI contribution. *(Yapay zekâ katkısını izole etmek için temel yapılandırmalar yapay zekâ olmadan kullanılabilir kalacaktır.)*

---

# 173. Reproducible Export (Tekrarlanabilir Export)

The final selected neural model will be exported through a documented conversion pipeline. *(Nihai seçilen sinir ağı modeli dokümante edilmiş conversion hattı üzerinden export edilecektir.)*

The exported binary will receive its own hash and model registry entry. *(Export edilen binary kendi hash değerini ve model registry girdisini alacaktır.)*

---

# 174. Export Is Part of Evaluation (Export Değerlendirmenin Parçasıdır)

A training-framework model that cannot be reproduced accurately in the mobile runtime is not deployment-ready. *(Mobil çalışma zamanında doğru şekilde yeniden üretilemeyen training-framework modeli deployment'a hazır değildir.)*

---

# 175. Python Reference Predictions (Python Referans Tahminleri)

A fixed parity dataset will contain Python reference preprocessing outputs and model predictions. *(Sabit eşdeğerlik veri seti Python referans ön işleme çıktılarını ve model tahminlerini içerecektir.)*

---

# 176. Android Parity Predictions (Android Eşdeğerlik Tahminleri)

The same examples will be executed on the Android deployment runtime. *(Aynı örnekler Android deployment çalışma zamanında çalıştırılacaktır.)*

---

# 177. Parity Failure Blocks Promotion (Eşdeğerlik Hatası Promotion'ı Engeller)

A significant Python-to-Android mismatch blocks navigation promotion until its cause is resolved. *(Anlamlı Python-Android uyuşmazlığı nedeni çözülene kadar navigasyon promotion'ını engeller.)*

---

# 178. Quantization Evaluation (Quantization Değerlendirmesi)

Quantization may be evaluated only after a stable floating-point reference model exists. *(Quantization yalnızca kararlı floating-point referans model mevcut olduktan sonra değerlendirilebilir.)*

---

# 179. Quantization Comparison (Quantization Karşılaştırması)

The quantized model will be compared with the floating-point model on predictive quality, model size, latency, and mobile stability. *(Quantize edilmiş model floating-point modelle tahmin kalitesi, model boyutu, gecikme ve mobil kararlılık açısından karşılaştırılacaktır.)*

---

# 180. Quantized Model Is a New Version (Quantize Model Yeni Sürümdür)

A quantized artifact will receive a distinct model identity or version. *(Quantize edilmiş artifact ayrı model kimliği veya sürümü alacaktır.)*

---

# 181. CPU Baseline First (Önce CPU Temeli)

Mobile AI benchmarking will begin with the standard CPU execution path. *(Mobil yapay zekâ benchmark'ı standart CPU çalıştırma yoluyla başlayacaktır.)*

---

# 182. Delegate Comparison (Delegate Karşılaştırması)

Alternative acceleration delegates will be evaluated only if measured evidence justifies them. *(Alternatif hızlandırma delegate'leri yalnızca ölçülmüş kanıt gerekçelendirirse değerlendirilecektir.)*

---

# 183. Runtime Metrics (Çalışma Zamanı Metrikleri)

Runtime evaluation may include median inference latency. *(Çalışma zamanı değerlendirmesi medyan çıkarım gecikmesini içerebilir.)*

It may include P95 latency. *(P95 gecikmesini içerebilir.)*

It may include memory and sustained CPU behavior. *(Bellek ve sürekli CPU davranışını içerebilir.)*

---

# 184. Combined Runtime Load (Birleşik Çalışma Zamanı Yükü)

Final runtime tests will occur while other NAVGUARD components are active. *(Nihai çalışma zamanı testleri diğer NAVGUARD bileşenleri aktifken gerçekleşecektir.)*

AI will not be benchmarked only in isolation. *(Yapay zekâ yalnızca izole olarak benchmark edilmeyecektir.)*

---

# 185. Battery and Thermal Evidence (Batarya ve Termal Kanıt)

Longer representative sessions will be used to inspect whether AI creates unacceptable resource cost. *(Daha uzun temsili oturumlar yapay zekânın kabul edilemez kaynak maliyeti oluşturup oluşturmadığını incelemek için kullanılacaktır.)*

---

# 186. Model Registry Requirement (Model Registry Gereksinimi)

Every model considered for formal deployment will have a registry entry. *(Resmî deployment için değerlendirilen her model registry girdisine sahip olacaktır.)*

---

# 187. Model Registry Fields (Model Registry Alanları)

```text id="ml26_13"
modelId
task
version
algorithm
datasetId
splitManifestId
preprocessingVersion
trainingRunId
trainingSeed
validationMetrics
testMetrics
fileHash
deploymentStatus
```

---

# 188. Training Run Manifest (Eğitim Run Manifest'i)

```text id="ml26_14"
trainingRunId
experimentId
startTime
endTime
environmentVersion
datasetId
seed
hyperparameters
checkpoint
status
```

---

# 189. Evaluation Report Artifact (Değerlendirme Rapor Artifact'ı)

Every formal model candidate will have an evaluation report. *(Her resmî model adayı değerlendirme raporuna sahip olacaktır.)*

---

# 190. Motion Evaluation Report Contents (Hareket Değerlendirme Raporu İçeriği)

The report will contain Macro F1, Accuracy, per-class metrics, and confusion matrix. *(Rapor Macro F1, Accuracy, sınıf başına metrikler ve confusion matrix içerecektir.)*

It will also contain independent-session results. *(Ayrıca bağımsız oturum sonuçlarını içerecektir.)*

---

# 191. Step Length Evaluation Report Contents (Adım Uzunluğu Değerlendirme Raporu İçeriği)

The report will contain the metrics supported by actual reference granularity. *(Rapor gerçek referans granülerliğinin desteklediği metrikleri içerecektir.)*

It will include route-level error and bias. *(Rota seviyesi hata ve bias'ı içerecektir.)*

---

# 192. Final Evidence Package (Nihai Kanıt Paketi)

The final AI evidence package will combine dataset, training, evaluation, mobile, and navigation evidence. *(Nihai yapay zekâ kanıt paketi veri seti, eğitim, değerlendirme, mobil ve navigasyon kanıtını birleştirecektir.)*

---

# 193. Final Evidence Package Contents (Nihai Kanıt Paketi İçeriği)

```text id="ml26_15"
dataset_manifest
split_manifest
preprocessing_config
experiment_config
training_logs
validation_results
held_out_predictions
confusion_matrix
regression_results
model_registry_entry
model_hash
mobile_parity_results
latency_results
navigation_ablation_results
```

---

# 194. Evidence Package Must Be Self-Consistent (Kanıt Paketi Kendi İçinde Tutarlı Olmalıdır)

The model hash in the mobile evidence must match the model artifact referenced by the evaluation report. *(Mobil kanıttaki model hash'i değerlendirme raporunun referans verdiği model artifact'ıyla eşleşmelidir.)*

---

# 195. Results Cannot Be Reconstructed from Memory (Sonuçlar Hafızadan Yeniden Oluşturulmaz)

Final metrics must come from stored predictions or evaluation artifacts rather than manually remembered values. *(Nihai metrikler elle hatırlanan değerler yerine saklanan tahminlerden veya değerlendirme artifact'larından gelmelidir.)*

---

# 196. Automated Metric Recalculation (Otomatik Metrik Yeniden Hesaplama)

Where practical, final metrics will be reproducibly recalculated from stored prediction files. *(Uygulanabilir olduğunda nihai metrikler saklanan tahmin dosyalarından tekrarlanabilir şekilde yeniden hesaplanacaktır.)*

---

# 197. Training and Evaluation Code Separation (Eğitim ve Değerlendirme Kodu Ayrımı)

Training code and final evaluation logic should remain logically separated. *(Eğitim kodu ve nihai değerlendirme mantığı mantıksal olarak ayrı kalmalıdır.)*

This reduces accidental reuse of test information. *(Bu test bilgisinin yanlışlıkla yeniden kullanılmasını azaltır.)*

---

# 198. Final Evaluation Script (Nihai Değerlendirme Script'i)

The final evaluation script should accept a frozen model and frozen test manifest and produce deterministic report artifacts. *(Nihai değerlendirme script'i sabitlenmiş model ve sabitlenmiş test manifest'ini almalı ve deterministik rapor artifact'ları üretmelidir.)*

---

# 199. Evaluation Configuration Is Read-Only During Final Test (Nihai Test Sırasında Değerlendirme Yapılandırması Salt Okunurdur)

Final test execution should not modify thresholds, normalization, labels, or model weights. *(Nihai test çalıştırma eşikleri, normalizasyonu, etiketleri veya model ağırlıklarını değiştirmemelidir.)*

---

# 200. Model Comparison Integrity (Model Karşılaştırma Bütünlüğü)

Competing models must be compared on equivalent data partitions. *(Rakip modeller eşdeğer veri bölümleri üzerinde karşılaştırılmalıdır.)*

A model must not receive an easier test split than another model. *(Bir model başka modele göre daha kolay test ayrımı almamalıdır.)*

---

# 201. Feature-Set Comparison Integrity (Özellik Seti Karşılaştırma Bütünlüğü)

Feature-set experiments will preserve the same relevant training and validation groups. *(Özellik seti deneyleri aynı ilgili training ve validation gruplarını koruyacaktır.)*

---

# 202. Preprocessing Comparison Integrity (Ön İşleme Karşılaştırma Bütünlüğü)

Filtering or resampling variants will be compared under the same underlying source sessions. *(Filtreleme veya yeniden örnekleme varyantları aynı temel kaynak oturumlar altında karşılaştırılacaktır.)*

---

# 203. No Cherry-Picking Runs (Run Cherry-Picking Olmaması)

NAVGUARD will not report only the best random seed if several seeds were intentionally evaluated. *(NAVGUARD birkaç seed bilinçli olarak değerlendirildiyse yalnızca en iyi random seed'i raporlamayacaktır.)*

The selection policy will be explicit. *(Seçim politikası açık olacaktır.)*

---

# 204. Multiple-Seed Reporting Candidate (Birden Fazla Seed Raporlama Adayı)

Mean and variability across seeds may be reported for development experiments when useful. *(Kullanışlı olduğunda geliştirme deneyleri için seed'ler arası ortalama ve değişkenlik raporlanabilir.)*

---

# 205. Final Deployment Seed (Nihai Deployment Seed'i)

The exact run used to generate the deployed model will always be identifiable. *(Deployment edilen modeli üreten kesin run her zaman tanımlanabilir olacaktır.)*

---

# 206. Early Test Access Prevention (Erken Test Erişimi Önleme)

Training notebooks or scripts should avoid automatically printing final test metrics during routine development runs. *(Eğitim notebook veya script'leri rutin geliştirme run'ları sırasında nihai test metriklerini otomatik yazdırmaktan kaçınmalıdır.)*

This reduces accidental test-driven iteration. *(Bu yanlışlıkla test güdümlü iterasyonu azaltır.)*

---

# 207. Validation as the Development Decision Surface (Geliştirme Karar Yüzeyi Olarak Validation)

Model-development decisions will be based on validation evidence. *(Model geliştirme kararları validation kanıtına dayanacaktır.)*

---

# 208. Model Freeze Record (Model Sabitleme Kaydı)

Before final testing, a model-freeze record will identify the exact candidate. *(Nihai testten önce model sabitleme kaydı kesin adayı tanımlayacaktır.)*

---

# 209. Model Freeze Record Fields (Model Sabitleme Kaydı Alanları)

```text id="ml26_16"
freeze_id
model_id
model_version
model_hash
dataset_id
preprocessing_version
selection_reason
freeze_timestamp
```

---

# 210. Threshold Freeze Record (Eşik Sabitleme Kaydı)

Confidence gates, temporal hysteresis, and other post-processing thresholds will be frozen alongside the model. *(Güven kapıları, zamansal hysteresis ve diğer son işleme eşikleri modelle birlikte sabitlenecektir.)*

---

# 211. Step Length Parameter Freeze (Adım Uzunluğu Parametre Sabitleme)

Fixed-step calibration, Weinberg coefficient, regression model, and uncertainty profile will be frozen before final benchmark use. *(Sabit adım kalibrasyonu, Weinberg katsayısı, regresyon modeli ve belirsizlik profili nihai benchmark kullanımından önce sabitlenecektir.)*

---

# 212. Calibration and Final Evaluation Separation (Kalibrasyon ile Nihai Değerlendirme Ayrımı)

Calibration sessions and final benchmark sessions must remain distinct. *(Kalibrasyon oturumları ile nihai benchmark oturumları ayrı kalmalıdır.)*

---

# 213. Model Retraining After Mobile Conversion (Mobil Conversion Sonrası Model Yeniden Eğitimi)

Mobile conversion itself should not trigger model retraining unless conversion problems reveal a real modeling issue. *(Mobil conversion kendi başına model yeniden eğitimini tetiklememelidir, yalnızca conversion problemleri gerçek modelleme problemi ortaya çıkarırsa tetikleyebilir.)*

---

# 214. Mobile Failure Is an Engineering Failure Category (Mobil Hata Mühendislik Hata Kategorisidir)

A model may be statistically strong but operationally unusable because of deployment constraints. *(Bir model istatistiksel olarak güçlü ancak deployment kısıtları nedeniyle operasyonel olarak kullanılamaz olabilir.)*

This outcome will be reported transparently. *(Bu sonuç şeffaf şekilde raporlanacaktır.)*

---

# 215. Fallback if Motion AI Fails Promotion (Hareket Yapay Zekâsı Promotion Başarısızsa Geri Dönüş)

If the Motion Classification model fails final promotion gates, deterministic motion logic remains available. *(Hareket Sınıflandırma modeli nihai promotion kapılarını geçemezse deterministik hareket mantığı kullanılabilir kalır.)*

---

# 216. Fallback if Step Length AI Fails Promotion (Adım Uzunluğu Yapay Zekâsı Promotion Başarısızsa Geri Dönüş)

If learned Step Length Estimation fails promotion, the best deterministic step-length method will remain active. *(Öğrenilmiş Adım Uzunluğu Tahmini promotion başarısız olursa en iyi deterministik adım uzunluğu yöntemi aktif kalacaktır.)*

---

# 217. Negative Results Are Valid Results (Negatif Sonuçlar Geçerli Sonuçlardır)

A simpler baseline outperforming an AI model is an acceptable research outcome. *(Daha basit temel yöntemin bir yapay zekâ modelini geçmesi kabul edilebilir araştırma sonucudur.)*

---

# 218. No Forced AI Success (Zorlanmış Yapay Zekâ Başarısı Olmaması)

The project will not manipulate splits, labels, or thresholds to force an AI model to appear successful. *(Proje yapay zekâ modelini başarılı göstermek için ayrımları, etiketleri veya eşikleri manipüle etmeyecektir.)*

---

# 219. Final Classification Reporting (Nihai Sınıflandırma Raporlama)

The final report will state which classifier was selected and why. *(Nihai rapor hangi sınıflandırıcının seçildiğini ve nedenini belirtecektir.)*

It will include baseline comparisons. *(Temel model karşılaştırmalarını içerecektir.)*

---

# 220. Final Regression Reporting (Nihai Regresyon Raporlama)

The final report will state whether learned step-length estimation was retained. *(Nihai rapor öğrenilmiş adım uzunluğu tahmininin korunup korunmadığını belirtecektir.)*

If not retained, the selected deterministic method will be reported. *(Korunmadıysa seçilen deterministik yöntem raporlanacaktır.)*

---

# 221. Final AI Claim Boundaries (Nihai Yapay Zekâ İddia Sınırları)

Model claims will be limited to the tested device, participant scope, phone-placement protocol, motion classes, and experimental environments. *(Model iddiaları test edilen cihaz, katılımcı kapsamı, telefon yerleşim protokolü, hareket sınıfları ve deneysel ortamlarla sınırlı olacaktır.)*

---

# 222. Cross-Device Generalization Is Not Assumed (Cihazlar Arası Genelleme Varsayılmaz)

Performance on the Xiaomi Redmi Note 9 Pro will not be presented as proof of equivalent performance on all Android phones. *(Xiaomi Redmi Note 9 Pro üzerindeki performans tüm Android telefonlarda eşdeğer performans kanıtı olarak sunulmayacaktır.)*

---

# 223. Cross-User Generalization Is Not Assumed (Kullanıcılar Arası Genelleme Varsayılmaz)

A primarily single-participant dataset will not support population-level claims. *(Temel olarak tek katılımcılı veri seti popülasyon seviyesi iddiaları desteklemeyecektir.)*

---

# 224. Experiment Completion Gate (Deney Tamamlama Kapısı)

A formal ML experiment is complete only when configuration, outputs, metrics, and artifacts are all persisted. *(Resmî ML deneyi yalnızca yapılandırma, çıktılar, metrikler ve artifact'lar tamamen saklandığında tamamlanmış olur.)*

---

# 225. Incomplete Experiment State (Tamamlanmamış Deney Durumu)

A run missing required artifacts will be marked incomplete rather than silently promoted. *(Gerekli artifact'ları eksik olan run sessizce promote edilmek yerine tamamlanmamış olarak işaretlenecektir.)*

---

# 226. Experiment Status Values (Deney Durum Değerleri)

```text id="ml26_17"
CREATED
RUNNING
COMPLETED
FAILED
INVALID
ARCHIVED
```

---

# 227. ML Test IDs (ML Test ID'leri)

```text id="ml26_18"
ML-DATA-001   Dataset version validation
ML-DATA-002   Split leakage audit
ML-DATA-003   Sample provenance audit
ML-DATA-004   Training-only preprocessing fit

ML-CLS-001    Logistic Regression baseline
ML-CLS-002    Random Forest baseline
ML-CLS-003    1D-CNN candidate
ML-CLS-004    Class imbalance experiment
ML-CLS-005    Multi-seed stability
ML-CLS-006    Held-out Macro F1
ML-CLS-007    Confusion matrix
ML-CLS-008    Per-session metrics

ML-REG-001    Fixed-step baseline
ML-REG-002    Deterministic variable baseline
ML-REG-003    Linear Regression
ML-REG-004    Random Forest Regressor
ML-REG-005    Residual analysis
ML-REG-006    Route-level distance error

ML-HPO-001    Group-aware validation
ML-HPO-002    Search-space integrity
ML-HPO-003    Test-isolation audit

ML-CAL-001    Confidence calibration if enabled
ML-CAL-002    Confidence gate validation
ML-CAL-003    Temporal smoothing validation

ML-EXP-001    Experiment manifest completeness
ML-EXP-002    Seed recording
ML-EXP-003    Training artifact completeness
ML-EXP-004    Model freeze record

ML-MOB-001    Export validation
ML-MOB-002    Python/Android preprocessing parity
ML-MOB-003    Python/Android output parity
ML-MOB-004    Mobile latency
ML-MOB-005    Sustained runtime

ML-NAV-001    Motion AI navigation ablation
ML-NAV-002    Step-length navigation ablation
ML-NAV-003    Final AI-enabled configuration
```

---

# 228. Dataset Integrity Acceptance Criteria (Veri Seti Bütünlüğü Kabul Kriterleri)

No physical session may cross train, validation, and test boundaries. *(Hiçbir fiziksel oturum train, validation ve test sınırlarını geçemez.)*

All model samples must remain traceable to source sessions. *(Tüm model örnekleri kaynak oturumlara izlenebilir kalmalıdır.)*

---

# 229. Preprocessing Acceptance Criteria (Ön İşleme Kabul Kriterleri)

All fitted preprocessing statistics must come from training data only. *(Fit edilen tüm ön işleme istatistikleri yalnızca training verisinden gelmelidir.)*

The final preprocessing configuration must be versioned and frozen. *(Nihai ön işleme yapılandırması sürümlenmiş ve sabitlenmiş olmalıdır.)*

---

# 230. Classification Acceptance Criteria (Sınıflandırma Kabul Kriterleri)

At least one simple classical and one stronger candidate model must be compared. *(En az bir basit klasik ve bir daha güçlü aday model karşılaştırılmalıdır.)*

Macro F1 must be reported. *(Macro F1 raporlanmalıdır.)*

A confusion matrix must be stored. *(Confusion matrix saklanmalıdır.)*

---

# 231. Motion Target Acceptance Criterion (Hareket Hedef Kabul Kriteri)

The provisional target remains held-out Macro F1 `≥ 0.90`. *(Geçici hedef ayrılmış Macro F1 `≥ 0.90` olarak kalmaktadır.)*

Failure to reach the target will be reported transparently. *(Hedefe ulaşılamaması şeffaf şekilde raporlanacaktır.)*

---

# 232. Regression Acceptance Criteria (Regresyon Kabul Kriterleri)

Regression metrics must match the actual label granularity. *(Regresyon metrikleri gerçek etiket granülerliğiyle eşleşmelidir.)*

Learned methods must be compared against deterministic baselines. *(Öğrenilmiş yöntemler deterministik temel yöntemlerle karşılaştırılmalıdır.)*

---

# 233. Model Promotion Acceptance Criteria (Model Promotion Kabul Kriterleri)

A model cannot become navigation-enabled before offline validation, mobile parity validation, and runtime stability checks pass. *(Bir model offline validation, mobil eşdeğerlik doğrulaması ve çalışma zamanı kararlılık kontrolleri geçmeden navigasyon etkin hale gelemez.)*

---

# 234. Test Isolation Acceptance Criteria (Test İzolasyon Kabul Kriterleri)

Final test data must not be used for HPO, normalization fitting, threshold tuning, architecture selection, or feature selection. *(Nihai test verisi HPO, normalizasyon fit işlemi, eşik ayarı, mimari seçimi veya özellik seçimi için kullanılmamalıdır.)*

---

# 235. Reproducibility Acceptance Criteria (Tekrarlanabilirlik Kabul Kriterleri)

Every final result must reference the dataset version, split manifest, preprocessing version, experiment ID, model version, and model hash where applicable. *(Her nihai sonuç uygun olduğunda veri seti sürümüne, ayrım manifest'ine, ön işleme sürümüne, deney ID'sine, model sürümüne ve model hash'ine referans vermelidir.)*

---

# 236. Evidence Acceptance Criteria (Kanıt Kabul Kriterleri)

Final metrics must be reproducible from stored predictions or equivalent evaluation artifacts. *(Nihai metrikler saklanan tahminlerden veya eşdeğer değerlendirme artifact'larından yeniden üretilebilir olmalıdır.)*

---

# 237. Negative Result Acceptance Criteria (Negatif Sonuç Kabul Kriterleri)

An AI model that fails promotion will remain documented rather than being omitted from the research history. *(Promotion başarısız olan yapay zekâ modeli araştırma geçmişinden çıkarılmak yerine dokümante edilmiş olarak kalacaktır.)*

---

# 238. Minimum Successful ML Pipeline (Minimum Başarılı ML Hattı)

The minimum successful ML pipeline will provide a leakage-safe Motion Classification comparison using session-wise isolation and held-out evaluation. *(Minimum başarılı ML hattı oturum bazlı izolasyon ve ayrılmış değerlendirme kullanarak veri sızıntısına karşı güvenli Hareket Sınıflandırma karşılaştırması sağlayacaktır.)*

It will also provide at least deterministic Step Length baselines. *(Ayrıca en az deterministik Adım Uzunluğu temel yöntemleri sağlayacaktır.)*

---

# 239. Target Successful ML Pipeline (Hedef Başarılı ML Hattı)

The target pipeline will include group-aware HPO, multiple model comparisons, mobile parity validation, model registry promotion, and downstream navigation ablation. *(Hedef hat group-aware HPO, birden fazla model karşılaştırması, mobil eşdeğerlik doğrulaması, model registry promotion ve aşağı akış navigasyon ablation içerecektir.)*

---

# 240. Optional ML Enhancements (İsteğe Bağlı ML İyileştirmeleri)

Optional enhancements may include probability calibration. *(İsteğe bağlı iyileştirmeler olasılık kalibrasyonunu içerebilir.)*

Optional enhancements may include multi-seed statistical summaries. *(İsteğe bağlı iyileştirmeler çok seed'li istatistiksel özetleri içerebilir.)*

Optional enhancements may include quantization comparison. *(İsteğe bağlı iyileştirmeler quantization karşılaştırmasını içerebilir.)*

---

# 241. ML Non-Goals (ML Olmayan Hedefler)

NAVGUARD will not optimize models against final test data. *(NAVGUARD modelleri nihai test verisine göre optimize etmeyecektir.)*

NAVGUARD will not claim cross-device or cross-population generalization without evidence. *(NAVGUARD kanıt olmadan cihazlar arası veya popülasyonlar arası genelleme iddia etmeyecektir.)*

NAVGUARD will not retain a learned model solely because it is more sophisticated than a baseline. *(NAVGUARD öğrenilmiş modeli yalnızca temel yöntemden daha gelişmiş olduğu için korumayacaktır.)*

---

# 242. Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kararlar)

All formal ML development will use group-aware session isolation. *(Tüm resmî ML geliştirme group-aware oturum izolasyonu kullanacaktır.)*

The final test set will remain outside development decisions. *(Nihai test seti geliştirme kararlarının dışında kalacaktır.)*

---

# 243. Classification Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Sınıflandırma Kararları)

Macro F1 will remain the primary Motion Classification model-selection metric. *(Macro F1 Hareket Sınıflandırması temel model seçim metriği olarak kalacaktır.)*

Accuracy, per-class precision, recall, F1, and confusion matrix will also be required. *(Accuracy, sınıf başına precision, recall, F1 ve confusion matrix de gerekli olacaktır.)*

---

# 244. Motion Target Frozen by This Document (Bu Dokümanla Sabitlenen Hareket Hedefi)

The provisional held-out Motion Classification target remains Macro F1 `≥ 0.90`. *(Geçici ayrılmış Hareket Sınıflandırma hedefi Macro F1 `≥ 0.90` olarak kalmaktadır.)*

---

# 245. Baseline Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Temel Model Kararları)

Motion Classification will compare Logistic Regression, Random Forest, and at least one lightweight 1D-CNN. *(Hareket Sınıflandırması Logistic Regression, Random Forest ve en az bir hafif 1D-CNN'i karşılaştıracaktır.)*

Step Length will compare fixed and deterministic variable baselines before learned regression is retained. *(Adım Uzunluğu öğrenilmiş regresyon korunmadan önce sabit ve deterministik değişken temel yöntemleri karşılaştıracaktır.)*

---

# 246. HPO Decisions Frozen by This Document (Bu Dokümanla Sabitlenen HPO Kararları)

Hyperparameter tuning will use development data only. *(Hiperparametre ayarı yalnızca geliştirme verisini kullanacaktır.)*

Group isolation must be preserved inside validation and cross-validation procedures. *(Grup izolasyonu validation ve cross-validation prosedürleri içerisinde korunmalıdır.)*

---

# 247. Seed Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Seed Kararları)

Important training runs will record random seeds. *(Önemli eğitim run'ları random seed'leri kaydedecektir.)*

Promising neural models may be evaluated under multiple seeds when schedule permits. *(Umut verici sinir ağı modelleri takvim izin verdiğinde birden fazla seed altında değerlendirilebilir.)*

---

# 248. Early Stopping Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Early Stopping Kararları)

Early stopping may use validation evidence only. *(Early stopping yalnızca validation kanıtını kullanabilir.)*

Final test metrics will never control training termination. *(Nihai test metrikleri eğitim sonlandırmasını hiçbir zaman kontrol etmeyecektir.)*

---

# 249. Model Promotion Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Model Promotion Kararları)

A model must pass offline evaluation before mobile shadow validation. *(Bir model mobil gölge doğrulamasından önce çevrimdışı değerlendirmeyi geçmelidir.)*

It must pass mobile parity and runtime checks before navigation enablement. *(Navigasyon etkinleştirmesinden önce mobil eşdeğerlik ve çalışma zamanı kontrollerini geçmelidir.)*

---

# 250. Step Length Promotion Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Adım Uzunluğu Promotion Kararları)

A learned step-length estimator will be retained only if it demonstrates consistent held-out benefit over the selected deterministic baseline. *(Öğrenilmiş adım uzunluğu tahmin motoru yalnızca seçilen deterministik temele göre tutarlı ayrılmış fayda gösterirse korunacaktır.)*

---

# 251. Reproducibility Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Tekrarlanabilirlik Kararları)

Every final model will reference its dataset, preprocessing, experiment configuration, model version, and artifact hash. *(Her nihai model veri setine, ön işlemeye, deney yapılandırmasına, model sürümüne ve artifact hash'ine referans verecektir.)*

---

# 252. Decisions Pending Dataset Size (Veri Seti Boyutunu Bekleyen Kararlar)

The final train-validation-test proportions remain pending the number of usable independent sessions. *(Nihai train-validation-test oranları kullanılabilir bağımsız oturum sayısını beklemektedir.)*

The final group-aware cross-validation fold count also remains pending dataset size. *(Nihai group-aware cross-validation fold sayısı da veri seti boyutunu beklemektedir.)*

---

# 253. Decisions Pending Model Experiments (Model Deneylerini Bekleyen Kararlar)

The final 1D-CNN architecture remains pending validation comparison. *(Nihai 1D-CNN mimarisi validation karşılaştırmasını beklemektedir.)*

The final Random Forest hyperparameters remain pending HPO. *(Nihai Random Forest hiperparametreleri HPO'yu beklemektedir.)*

---

# 254. Decisions Pending Calibration (Kalibrasyon Bekleyen Kararlar)

The final motion confidence threshold remains pending validation analysis. *(Nihai hareket güven eşiği validation analizini beklemektedir.)*

The final temporal smoothing parameters remain pending transition evaluation. *(Nihai zamansal smoothing parametreleri geçiş değerlendirmesini beklemektedir.)*

---

# 255. Decisions Pending Regression Evaluation (Regresyon Değerlendirmesini Bekleyen Kararlar)

The final learned Step Length model remains pending held-out development comparison. *(Nihai öğrenilmiş Adım Uzunluğu modeli ayrılmış geliştirme karşılaştırmasını beklemektedir.)*

The final Step Length uncertainty profiles remain pending residual analysis. *(Nihai Adım Uzunluğu belirsizlik profilleri residual analizini beklemektedir.)*

---

# 256. Decisions Pending Mobile Benchmarking (Mobil Benchmark Bekleyen Kararlar)

The final LiteRT delegate remains pending Redmi Note 9 Pro runtime measurements. *(Nihai LiteRT delegate Redmi Note 9 Pro çalışma zamanı ölçümlerini beklemektedir.)*

The final quantization decision remains pending predictive and runtime comparison. *(Nihai quantization kararı tahmin ve çalışma zamanı karşılaştırmasını beklemektedir.)*

---

# 257. Final Machine Learning Training & Evaluation Statement (Nihai Makine Öğrenmesi Eğitim ve Değerlendirme Bildirimi)

**NAVGUARD will train and evaluate all machine-learning models under a session-grouped experimental design in which windows, steps, and derived features from one physical recording session can never leak across train, validation, and final test boundaries.** *(NAVGUARD tüm makine öğrenmesi modellerini tek fiziksel kayıt oturumundan pencerelerin, adımların ve türetilmiş özelliklerin train, validation ve nihai test sınırları arasında hiçbir zaman sızamayacağı oturum gruplu deneysel tasarım altında eğitecek ve değerlendirecektir.)*

**Training-only statistics will define normalization and preprocessing parameters, validation evidence will control model and hyperparameter selection, and final held-out sessions will remain isolated until the model, thresholds, preprocessing, and post-processing configuration have been frozen.** *(Yalnızca eğitim istatistikleri normalizasyon ve ön işleme parametrelerini tanımlayacak, validation kanıtı model ve hiperparametre seçimini kontrol edecek ve nihai ayrılmış oturumlar model, eşikler, ön işleme ve son işleme yapılandırması sabitlenene kadar izole kalacaktır.)*

**Motion Classification will compare simple and strong classical baselines against a lightweight 1D-CNN under identical group-aware data partitions, with Macro F1 as the primary model-selection metric and `≥ 0.90` as the provisional held-out performance target.** *(Hareket Sınıflandırması basit ve güçlü klasik temel modelleri aynı group-aware veri bölümleri altında hafif bir 1D-CNN'e karşı karşılaştıracak, Macro F1 temel model seçim metriği ve `≥ 0.90` geçici ayrılmış performans hedefi olacaktır.)*

**Step Length Estimation will compare learned regressors only after calibrated fixed and deterministic variable-step baselines have been established, and a learned estimator will be retained only if held-out route, regression, or downstream PDR evidence demonstrates consistent practical benefit.** *(Adım Uzunluğu Tahmini öğrenilmiş regresörleri yalnızca kalibre edilmiş sabit ve deterministik değişken adım temel yöntemleri oluşturulduktan sonra karşılaştıracak ve öğrenilmiş tahmin motoru yalnızca ayrılmış rota, regresyon veya aşağı akış PDR kanıtı tutarlı pratik fayda gösterirse korunacaktır.)*

**Every candidate model will pass through explicit promotion stages from experimental training to offline validation, mobile shadow validation, and navigation enablement, and no model will affect formal navigation until Python-to-Android preprocessing parity, output parity, runtime stability, and relevant performance gates have passed.** *(Her aday model deneysel eğitimden çevrimdışı doğrulamaya, mobil gölge doğrulamaya ve navigasyon etkinleştirmesine açık promotion aşamalarından geçecek ve hiçbir model Python-Android ön işleme eşdeğerliği, çıktı eşdeğerliği, çalışma zamanı kararlılığı ve ilgili performans kapıları geçmeden resmî navigasyonu etkilemeyecektir.)*

**Final results will remain reproducible through dataset manifests, split manifests, experiment configurations, training seeds, model registries, artifact hashes, stored predictions, mobile parity evidence, and navigation-level ablation outputs.** *(Nihai sonuçlar veri seti manifestleri, ayrım manifestleri, deney yapılandırmaları, eğitim seed'leri, model registry'leri, artifact hash'leri, saklanan tahminler, mobil eşdeğerlik kanıtı ve navigasyon seviyesi ablation çıktıları üzerinden tekrarlanabilir kalacaktır.)*

**Negative results will remain part of the research record, and NAVGUARD will prefer a deterministic or simpler model whenever a more complex AI model fails to demonstrate enough real-world benefit to justify its additional complexity.** *(Negatif sonuçlar araştırma kaydının parçası olarak kalacak ve NAVGUARD daha karmaşık yapay zekâ modeli ek karmaşıklığını gerekçelendirecek yeterli gerçek dünya faydası gösteremezse deterministik veya daha basit modeli tercih edecektir.)*

---

# 258. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development Machine Learning Training & Evaluation Protocol Completed *(Doküman Durumu: Geliştirme Öncesi Makine Öğrenmesi Eğitim ve Değerlendirme Protokolü Tamamlandı)*

**Primary ML Tasks:** Motion Classification + Step Length Estimation *(Temel ML Görevleri: Hareket Sınıflandırması + Adım Uzunluğu Tahmini)*

**Fundamental Group Unit:** Physical Session *(Temel Grup Birimi: Fiziksel Oturum)*

**Train/Test Leakage:** Forbidden *(Train/Test Veri Sızıntısı: Yasak)*

**Validation Strategy:** Group-Aware *(Validation Stratejisi: Group-Aware)*

**Final Test Role:** Held-Out Evidence Only *(Nihai Test Rolü: Yalnızca Ayrılmış Kanıt)*

**Normalization Fit Source:** Training Split Only *(Normalizasyon Fit Kaynağı: Yalnızca Training Ayrımı)*

**Motion Baselines:** Logistic Regression + Random Forest *(Hareket Temel Modelleri: Logistic Regression + Random Forest)*

**Primary Motion Neural Candidate:** Lightweight 1D-CNN *(Temel Hareket Sinir Ağı Adayı: Hafif 1D-CNN)*

**Primary Motion Metric:** Macro F1 *(Temel Hareket Metriği: Macro F1)*

**Provisional Motion Target:** Held-Out Macro F1 `≥ 0.90` *(Geçici Hareket Hedefi: Ayrılmış Macro F1 `≥ 0.90`)*

**Required Classification Evidence:** Accuracy + Per-Class Precision / Recall / F1 + Confusion Matrix *(Gerekli Sınıflandırma Kanıtı: Accuracy + Sınıf Başına Precision / Recall / F1 + Confusion Matrix)*

**Step Length Baselines:** Calibrated Fixed + Deterministic Variable *(Adım Uzunluğu Temel Modelleri: Kalibre Edilmiş Sabit + Deterministik Değişken)*

**Learned Step Length Candidates:** Linear Regression + Random Forest Regressor *(Öğrenilmiş Adım Uzunluğu Adayları: Linear Regression + Random Forest Regressor)*

**Neural Step Length Model:** Optional *(Sinir Ağı Adım Uzunluğu Modeli: İsteğe Bağlı)*

**Step Length Retention Rule:** Consistent Held-Out Benefit Required *(Adım Uzunluğu Koruma Kuralı: Tutarlı Ayrılmış Fayda Gerekli)*

**Hyperparameter Tuning:** Development Data Only *(Hiperparametre Ayarı: Yalnızca Geliştirme Verisi)*

**Cross-Validation:** Group-Aware if Used *(Cross-Validation: Kullanılırsa Group-Aware)*

**Random Seed Logging:** Required for Important Runs *(Random Seed Kaydı: Önemli Run'lar İçin Gerekli)*

**Multiple-Seed Neural Evaluation:** Preferred Where Schedule Permits *(Birden Fazla Seed Sinir Ağı Değerlendirmesi: Takvim İzin Verdiğinde Tercih Edilir)*

**Early Stopping Source:** Validation Only *(Early Stopping Kaynağı: Yalnızca Validation)*

**Test-Driven Early Stopping:** Forbidden *(Test Güdümlü Early Stopping: Yasak)*

**Class Imbalance Handling:** Evidence-Driven *(Sınıf Dengesizliği Yönetimi: Kanıt Güdümlü)*

**Confidence Calibration:** Optional / Validation-Based *(Güven Kalibrasyonu: İsteğe Bağlı / Validation Tabanlı)*

**Temporal Smoothing:** Evaluated Separately from Raw Model *(Zamansal Smoothing: Ham Modelden Ayrı Değerlendirilir)*

**Model Promotion Path:** `EXPERIMENTAL → VALIDATION_CANDIDATE → OFFLINE_VALIDATED → SHADOW_VALIDATED → NAVIGATION_ENABLED` *(Model Promotion Yolu: `EXPERIMENTAL → VALIDATION_CANDIDATE → OFFLINE_VALIDATED → SHADOW_VALIDATED → NAVIGATION_ENABLED`)*

**Python-to-Android Preprocessing Parity:** Mandatory *(Python-Android Ön İşleme Eşdeğerliği: Zorunlu)*

**Python-to-Android Output Parity:** Mandatory *(Python-Android Çıktı Eşdeğerliği: Zorunlu)*

**Initial Mobile Execution Baseline:** CPU *(İlk Mobil Çalıştırma Temeli: CPU)*

**Provisional Motion Inference Target:** `< 50 ms` per inference *(Geçici Hareket Çıkarım Hedefi: Çıkarım Başına `< 50 ms`)*

**Quantization:** Optional, Pending Benchmark *(Quantization: İsteğe Bağlı, Benchmark Bekleniyor)*

**Final Evidence Package:** Mandatory *(Nihai Kanıt Paketi: Zorunlu)*

**Final Model Hash:** Mandatory for Deployment Artifact *(Nihai Model Hash'i: Deployment Artifact'ı İçin Zorunlu)*

**Negative Result Preservation:** Mandatory *(Negatif Sonuç Koruma: Zorunlu)*

**Final Split Ratios:** Pending Independent Session Count *(Nihai Ayrım Oranları: Bağımsız Oturum Sayısı Bekleniyor)*

**Final Cross-Validation Fold Count:** Pending Dataset Size *(Nihai Cross-Validation Fold Sayısı: Veri Seti Boyutu Bekleniyor)*

**Final 1D-CNN Architecture:** Pending Validation Comparison *(Nihai 1D-CNN Mimarisi: Validation Karşılaştırması Bekleniyor)*

**Final Confidence Gate:** Pending Validation Analysis *(Nihai Güven Kapısı: Validation Analizi Bekleniyor)*

**Final Step Length Learned Model:** Pending Held-Out Comparison *(Nihai Öğrenilmiş Adım Uzunluğu Modeli: Ayrılmış Karşılaştırma Bekleniyor)*

**Final LiteRT Delegate:** Pending Redmi Note 9 Pro Benchmark *(Nihai LiteRT Delegate: Redmi Note 9 Pro Benchmark'ı Bekleniyor)*

**Next Documentation Item:** 27 — On-Device Edge AI Deployment *(Sonraki Dokümantasyon Öğesi: 27 — Cihaz Üzeri Edge AI Deployment)*
