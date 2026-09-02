# 30 — Data Storage, Logging & Session Management (Veri Depolama, Logging ve Oturum Yönetimi)

## 1. Document Purpose (Dokümanın Amacı)

This document defines how NAVGUARD will create, identify, persist, validate, finalize, recover, export, replay, version, and audit experiment sessions and their associated navigation data. *(Bu doküman NAVGUARD'ın deney oturumlarını ve bunlarla ilişkili navigasyon verilerini nasıl oluşturacağını, tanımlayacağını, kalıcı olarak saklayacağını, doğrulayacağını, finalize edeceğini, kurtaracağını, dışa aktaracağını, replay edeceğini, sürümleyeceğini ve denetleyeceğini tanımlar.)*

The storage architecture must preserve both high-frequency sensor evidence and lower-frequency structured session metadata without allowing logging complexity to interfere with real-time navigation. *(Depolama mimarisi yüksek frekanslı sensör kanıtını ve daha düşük frekanslı yapılandırılmış oturum metadata bilgisini korurken logging karmaşıklığının gerçek zamanlı navigasyona müdahale etmesine izin vermemelidir.)*

---

# 2. Core Storage Principle (Temel Depolama İlkesi)

NAVGUARD will separate experiment metadata from high-frequency time-series evidence. *(NAVGUARD deney metadata bilgisini yüksek frekanslı zaman serisi kanıtından ayıracaktır.)*

SQLite will primarily store structured metadata, session indexes, configuration references, status, and summary information. *(SQLite temel olarak yapılandırılmış metadata bilgisini, oturum index'lerini, yapılandırma referanslarını, durumları ve özet bilgileri saklayacaktır.)*

Append-oriented files will primarily store high-frequency sensor, estimator, GNSS, ARCore, AI, and diagnostic streams. *(Append odaklı dosyalar temel olarak yüksek frekanslı sensör, tahmin motoru, GNSS, ARCore, yapay zekâ ve diagnostic akışlarını saklayacaktır.)*

---

# 3. Why a Hybrid Storage Architecture Is Required (Neden Hibrit Depolama Mimarisi Gereklidir)

Writing every accelerometer and gyroscope sample as an individual relational-database transaction would add unnecessary overhead and implementation complexity. *(Her ivmeölçer ve jiroskop örneğini ayrı relational-database transaction olarak yazmak gereksiz yük ve uygulama karmaşıklığı oluşturacaktır.)*

Storing all session metadata only inside CSV files would make indexing, session discovery, configuration lookup, and lifecycle management unnecessarily difficult. *(Tüm oturum metadata bilgisini yalnızca CSV dosyaları içerisinde saklamak indexleme, oturum keşfi, yapılandırma lookup ve yaşam döngüsü yönetimini gereksiz şekilde zorlaştıracaktır.)*

The hybrid design combines the strengths of both approaches. *(Hibrit tasarım iki yaklaşımın güçlü yönlerini birleştirir.)*

---

# 4. Storage Layers (Depolama Katmanları)

NAVGUARD storage will be divided conceptually into four layers. *(NAVGUARD depolaması kavramsal olarak dört katmana ayrılacaktır.)*

```text
SESSION METADATA
(Oturum Metadata Bilgisi)

RAW EVIDENCE
(Ham Kanıt)

PROCESSED / DERIVED DATA
(İşlenmiş / Türetilmiş Veri)

EXPORT / REPLAY PACKAGE
(Export / Replay Paketi)
```

---

# 5. Session Metadata Layer (Oturum Metadata Katmanı)

The metadata layer will contain structured information required to identify and interpret a session. *(Metadata katmanı bir oturumu tanımlamak ve yorumlamak için gerekli yapılandırılmış bilgiyi içerecektir.)*

---

# 6. Raw Evidence Layer (Ham Kanıt Katmanı)

The raw evidence layer will contain measurements as close as practical to their authoritative acquisition sources. *(Ham kanıt katmanı ölçümleri mümkün olduğunca ana veri toplama kaynaklarına yakın biçimde içerecektir.)*

---

# 7. Processed Data Layer (İşlenmiş Veri Katmanı)

The processed layer will contain synchronized, filtered, detected, classified, estimated, or fused outputs derived from raw evidence. *(İşlenmiş katman ham kanıttan türetilen senkronize edilmiş, filtrelenmiş, tespit edilmiş, sınıflandırılmış, tahmin edilmiş veya füzyonlanmış çıktıları içerecektir.)*

---

# 8. Export Layer (Export Katmanı)

The export layer will package selected session artifacts for Python analysis, replay, evidence review, model development, or report generation. *(Export katmanı seçilen oturum artifact'larını Python analizi, replay, kanıt inceleme, model geliştirme veya rapor üretimi için paketleyecektir.)*

---

# 9. Raw Data Immutability (Ham Veri Değişmezliği)

Raw session evidence will be treated as immutable after it has been committed to storage. *(Ham oturum kanıtı depolamaya kesinleştirildikten sonra değişmez olarak ele alınacaktır.)*

Later preprocessing changes will generate new derived artifacts instead of modifying original raw records. *(Daha sonraki ön işleme değişiklikleri orijinal ham kayıtları değiştirmek yerine yeni türetilmiş artifact'lar oluşturacaktır.)*

---

# 10. Append-Only Philosophy (Append-Only Felsefesi)

High-frequency logs will follow an append-oriented design. *(Yüksek frekanslı loglar append odaklı tasarım izleyecektir.)*

Existing raw rows will not normally be edited during a live session. *(Mevcut ham satırlar canlı oturum sırasında normalde düzenlenmeyecektir.)*

---

# 11. Session as the Primary Storage Unit (Temel Depolama Birimi Olarak Oturum)

Every formal recording operation will belong to exactly one `session_id`. *(Her resmî kayıt işlemi tam olarak bir `session_id` değerine ait olacaktır.)*

All session-specific files, database records, logs, configuration references, and derived outputs will remain traceable to that identifier. *(Tüm oturuma özgü dosyalar, veritabanı kayıtları, loglar, yapılandırma referansları ve türetilmiş çıktılar bu tanımlayıcıya izlenebilir kalacaktır.)*

---

# 12. Session Identifier Requirements (Oturum Tanımlayıcı Gereksinimleri)

A session identifier must be unique within the application data store. *(Oturum tanımlayıcısı uygulama veri deposu içerisinde benzersiz olmalıdır.)*

It must not depend only on a user-visible session name. *(Yalnızca kullanıcı tarafından görülen oturum adına bağlı olmamalıdır.)*

---

# 13. Candidate Session ID Format (Aday Oturum ID Formatı)

```text
NG_<YYYYMMDD>_<HHMMSS>_<SHORT_RANDOM_ID>
```

A simpler UUID-backed internal identifier may also be used while retaining a readable display code. *(Okunabilir display kodu korunurken daha basit UUID tabanlı dahili tanımlayıcı da kullanılabilir.)*

---

# 14. Display Name and Internal ID Are Different (Display Adı ile Dahili ID Farklıdır)

A user-visible session label may be edited. *(Kullanıcı tarafından görülen oturum etiketi düzenlenebilir.)*

The internal `session_id` will remain immutable. *(Dahili `session_id` değişmez kalacaktır.)*

---

# 15. Session Lifecycle (Oturum Yaşam Döngüsü)

The storage lifecycle will align with the application lifecycle previously defined for navigation sessions. *(Depolama yaşam döngüsü daha önce navigasyon oturumları için tanımlanan uygulama yaşam döngüsüyle hizalanacaktır.)*

```text
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
RECORDING
↓
STOPPING
↓
FINALIZING
↓
COMPLETED
```

Failure branches may produce `INCOMPLETE`, `INVALID`, or `ERROR` session states. *(Hata dalları `INCOMPLETE`, `INVALID` veya `ERROR` oturum durumlarını üretebilir.)*

---

# 16. Storage Session States (Depolama Oturum Durumları)

```text
CREATED
PREPARING
ACTIVE
STOPPING
FINALIZING
COMPLETED
INCOMPLETE
INVALID
ARCHIVED
DELETED
ERROR
```

`DELETED` may represent a logical deletion state before physical cleanup depending on the final implementation policy. *(`DELETED`, nihai uygulama politikasına bağlı olarak fiziksel temizleme öncesindeki mantıksal silme durumunu temsil edebilir.)*

---

# 17. CREATED State (CREATED Durumu)

`CREATED` means a session record and session directory have been allocated but recording has not started. *(`CREATED`, oturum kaydının ve oturum klasörünün oluşturulduğu ancak kaydın başlamadığı anlamına gelir.)*

---

# 18. ACTIVE State (ACTIVE Durumu)

`ACTIVE` means the session is currently accepting data. *(`ACTIVE`, oturumun şu anda veri kabul ettiği anlamına gelir.)*

---

# 19. FINALIZING State (FINALIZING Durumu)

`FINALIZING` means acquisition has stopped but buffered logs, summaries, manifests, and integrity checks are still being completed. *(`FINALIZING`, veri toplamanın durduğu ancak buffer'lanmış logların, özetlerin, manifestlerin ve bütünlük kontrollerinin hâlâ tamamlandığı anlamına gelir.)*

---

# 20. COMPLETED State (COMPLETED Durumu)

`COMPLETED` means all mandatory session artifacts were successfully finalized. *(`COMPLETED`, tüm zorunlu oturum artifact'larının başarıyla finalize edildiği anlamına gelir.)*

---

# 21. INCOMPLETE State (INCOMPLETE Durumu)

`INCOMPLETE` means recording began but the normal finalization sequence did not complete. *(`INCOMPLETE`, kaydın başladığı ancak normal finalization dizisinin tamamlanmadığı anlamına gelir.)*

---

# 22. INVALID State (INVALID Durumu)

`INVALID` means the session exists and may contain useful evidence, but it violates one or more conditions required for the intended formal evaluation. *(`INVALID`, oturumun mevcut olduğu ve faydalı kanıt içerebildiği ancak amaçlanan resmî değerlendirme için gerekli bir veya daha fazla koşulu ihlal ettiği anlamına gelir.)*

---

# 23. Session Validity and Storage Completeness Are Separate (Oturum Geçerliliği ile Depolama Tamlığı Ayrıdır)

A session may be completely stored but scientifically invalid. *(Bir oturum tamamen saklanmış ancak bilimsel olarak geçersiz olabilir.)*

A session may also be scientifically interesting but technically incomplete because the application crashed before finalization. *(Bir oturum uygulama finalization öncesinde çöktüğü için teknik olarak tamamlanmamış ancak bilimsel olarak ilginç olabilir.)*

---

# 24. Session Database (Oturum Veritabanı)

A local SQLite database will provide the structured session index. *(Yerel SQLite veritabanı yapılandırılmış oturum index'ini sağlayacaktır.)*

The exact SQLite library and schema-migration implementation will be selected during project bootstrap. *(Kesin SQLite kütüphanesi ve schema migration uygulaması proje bootstrap sırasında seçilecektir.)*

---

# 25. Database Role (Veritabanı Rolü)

SQLite will not be the authoritative high-frequency accelerometer store. *(SQLite ana yüksek frekanslı ivmeölçer deposu olmayacaktır.)*

Its primary role will be session discovery, metadata, lifecycle state, configuration references, summaries, and artifact indexing. *(Temel rolü oturum keşfi, metadata, yaşam döngüsü durumu, yapılandırma referansları, özetler ve artifact indexleme olacaktır.)*

---

# 26. Candidate Core Database Tables (Aday Temel Veritabanı Tabloları)

```text
sessions
session_artifacts
session_configs
session_events
anchors
denied_intervals
recovery_events
dataset_labels
export_jobs
```

The final schema may merge or split tables while preserving these responsibilities. *(Nihai schema bu sorumlulukları koruyarak tabloları birleştirebilir veya bölebilir.)*

---

# 27. `sessions` Table ( `sessions` Tablosu)

The `sessions` table will contain one row per session. *(`sessions` tablosu oturum başına bir satır içerecektir.)*

---

# 28. Candidate `sessions` Fields (Aday `sessions` Alanları)

```text
session_id
display_name
created_at
started_at
stopped_at
finalized_at
status
runtime_mode
navigation_profile
device_config_id
sensor_profile_id
recovery_config_id
preprocessing_version
app_version
notes
```

---

# 29. Session Summary Fields (Oturum Özet Alanları)

The session row may include compact summary values for fast UI listing. *(Oturum satırı hızlı UI listeleme için kompakt özet değerleri içerebilir.)*

```text
duration_seconds
total_steps
distance_estimated_m
denied_duration_seconds
denied_distance_m
final_position_error_m
has_ground_truth
has_arcore
has_ai
quality_state
```

Summary values do not replace authoritative detailed logs. *(Özet değerler ana ayrıntılı logların yerini almaz.)*

---

# 30. `session_artifacts` Table ( `session_artifacts` Tablosu)

The artifact table will index physical files belonging to a session. *(Artifact tablosu bir oturuma ait fiziksel dosyaları indexleyecektir.)*

---

# 31. Candidate Artifact Fields (Aday Artifact Alanları)

```text
artifact_id
session_id
artifact_type
relative_path
schema_version
created_at
byte_size
row_count
hash
status
```

---

# 32. Artifact Types (Artifact Türleri)

```text
RAW_ACCELEROMETER
RAW_GYROSCOPE
RAW_MAGNETOMETER
RAW_ROTATION_VECTOR
RAW_GNSS
RAW_GNSS_STATUS
RAW_ARCORE
PROCESSED_PDR
PROCESSED_HEADING
PROCESSED_AI
PROCESSED_FUSED_POSITION
RECOVERY_EVENTS
SESSION_MANIFEST
EXPORT_PACKAGE
```

---

# 33. `session_configs` Table ( `session_configs` Tablosu)

A session must reference the exact configuration that governed it. *(Bir oturum kendisini yöneten kesin yapılandırmaya referans vermelidir.)*

---

# 34. Configuration Snapshot Principle (Yapılandırma Snapshot İlkesi)

Formal session behavior must remain reproducible even if application defaults change later. *(Uygulama varsayılanları daha sonra değişse bile resmî oturum davranışı yeniden üretilebilir kalmalıdır.)*

Therefore each session will store or reference a frozen configuration snapshot. *(Bu nedenle her oturum sabitlenmiş yapılandırma snapshot'ını saklayacak veya referans verecektir.)*

---

# 35. Candidate Configuration Snapshot (Aday Yapılandırma Snapshot'ı)

```text
SessionConfiguration
- sensorProfile
- navigationMode
- estimatorProfile
- headingProfile
- stepDetectionProfile
- stepLengthProfile
- aiProfile
- fusionProfile
- recoveryProfile
- loggingProfile
- runtimeMode
```

---

# 36. Configuration IDs (Yapılandırma ID'leri)

Each reusable configuration may have its own versioned identifier. *(Her yeniden kullanılabilir yapılandırma kendi sürümlenmiş tanımlayıcısına sahip olabilir.)*

---

# 37. Session Manifest (Oturum Manifest'i)

Every formal session will contain a machine-readable manifest file. *(Her resmî oturum machine-readable manifest dosyası içerecektir.)*

The manifest will act as the portable identity and interpretation record for the session outside SQLite. *(Manifest SQLite dışında oturum için taşınabilir kimlik ve yorumlama kaydı olarak görev yapacaktır.)*

---

# 38. Why a Manifest Is Required (Manifest Neden Gereklidir)

An exported session should remain interpretable even if it is copied to another machine without the original application database. *(Export edilmiş oturum orijinal uygulama veritabanı olmadan başka bilgisayara kopyalansa bile yorumlanabilir kalmalıdır.)*

---

# 39. Candidate Session Manifest (Aday Oturum Manifest'i)

```text
{
  "schemaVersion": "...",
  "sessionId": "...",
  "status": "...",
  "device": {},
  "application": {},
  "timing": {},
  "configuration": {},
  "anchors": [],
  "deniedIntervals": [],
  "artifacts": [],
  "quality": {},
  "integrity": {},
  "notes": ""
}
```

---

# 40. Manifest Is Finalized, Not Continuously Rewritten (Manifest Sürekli Yeniden Yazılmaz, Finalize Edilir)

The final manifest will normally be written or atomically replaced during session finalization. *(Nihai manifest normalde oturum finalization sırasında yazılacak veya atomik olarak değiştirilecektir.)*

A temporary active-session state file may be used while recording. *(Kayıt sırasında geçici aktif oturum state dosyası kullanılabilir.)*

---

# 41. Active Session Marker (Aktif Oturum İşaretleyicisi)

A session directory may contain a marker indicating that recording is not yet finalized. *(Oturum klasörü kaydın henüz finalize edilmediğini belirten marker içerebilir.)*

```text
.session_active
```

---

# 42. Finalization Marker (Finalization İşaretleyicisi)

Successful finalization may remove the active marker and create a completion marker or update the manifest state. *(Başarılı finalization aktif marker'ı kaldırabilir ve completion marker oluşturabilir veya manifest durumunu güncelleyebilir.)*

---

# 43. Session Directory Structure (Oturum Klasör Yapısı)

Each session will have one root directory. *(Her oturum tek root klasörüne sahip olacaktır.)*

```text
sessions/
└── <session_id>/
    ├── manifest.json
    ├── config/
    ├── raw/
    ├── processed/
    ├── events/
    ├── diagnostics/
    ├── summaries/
    └── export/
```

---

# 44. `config/` Directory ( `config/` Klasörü)

The `config/` directory will contain frozen configuration snapshots required to replay the session. *(`config/` klasörü oturumu replay etmek için gerekli sabitlenmiş yapılandırma snapshot'larını içerecektir.)*

---

# 45. `raw/` Directory ( `raw/` Klasörü)

The `raw/` directory will contain authoritative acquisition streams. *(`raw/` klasörü ana veri toplama akışlarını içerecektir.)*

---

# 46. `processed/` Directory ( `processed/` Klasörü)

The `processed/` directory will contain deterministic or versioned derived outputs. *(`processed/` klasörü deterministik veya sürümlenmiş türetilmiş çıktıları içerecektir.)*

---

# 47. `events/` Directory ( `events/` Klasörü)

The `events/` directory may contain state transitions, recovery events, labels, operator markers, and other discrete events. *(`events/` klasörü durum geçişlerini, recovery olaylarını, etiketleri, operatör marker'larını ve diğer ayrık olayları içerebilir.)*

---

# 48. `diagnostics/` Directory ( `diagnostics/` Klasörü)

The `diagnostics/` directory may contain high-detail runtime-health evidence not required by every production session. *(`diagnostics/` klasörü her production oturumu için gerekli olmayan yüksek ayrıntılı runtime health kanıtlarını içerebilir.)*

---

# 49. `summaries/` Directory ( `summaries/` Klasörü)

The `summaries/` directory will contain generated compact reports and aggregate metrics. *(`summaries/` klasörü oluşturulmuş kompakt raporları ve aggregate metrikleri içerecektir.)*

---

# 50. `export/` Directory ( `export/` Klasörü)

The `export/` directory may contain generated portable packages derived from the session. *(`export/` klasörü oturumdan türetilen taşınabilir paketleri içerebilir.)*

---

# 51. Raw Sensor File Separation (Ham Sensör Dosya Ayrımı)

Different authoritative sensor streams will normally be stored in separate files. *(Farklı ana sensör akışları normalde ayrı dosyalarda saklanacaktır.)*

This avoids forcing asynchronous sensors into artificial rows with fabricated simultaneous values. *(Bu asynchronous sensörleri uydurulmuş eş zamanlı değerlere sahip yapay satırlara zorlamayı önler.)*

---

# 52. Candidate Raw Files (Aday Ham Dosyalar)

```text
raw/accelerometer.csv
raw/gyroscope.csv
raw/magnetometer.csv
raw/rotation_vector.csv
raw/gnss_ground_truth.csv
raw/gnss_status.csv
raw/arcore_pose.csv
```

Files will be created only when the relevant stream is enabled and available. *(Dosyalar yalnızca ilgili akış etkin ve kullanılabilir olduğunda oluşturulacaktır.)*

---

# 53. Accelerometer Raw Schema (İvmeölçer Ham Şeması)

```text
timestamp_ns,
sequence_number,
x,
y,
z,
accuracy
```

---

# 54. Gyroscope Raw Schema (Jiroskop Ham Şeması)

```text
timestamp_ns,
sequence_number,
x,
y,
z,
accuracy
```

---

# 55. Magnetometer Raw Schema (Manyetometre Ham Şeması)

```text
timestamp_ns,
sequence_number,
x,
y,
z,
accuracy
```

---

# 56. Rotation Vector Raw Schema (Rotation Vector Ham Şeması)

The exact fields will depend on the Android sensor type retained after device audit. *(Kesin alanlar cihaz denetimi sonrasında korunan Android sensör türüne bağlı olacaktır.)*

No unavailable component will be silently substituted with zero. *(Kullanılamayan hiçbir bileşen sessizce sıfırla değiştirilmeyecektir.)*

---

# 57. GNSS Ground Truth Raw File (GNSS Ground Truth Ham Dosyası)

```text
raw/gnss_ground_truth.csv
```

This file remains logically independent from estimator outputs. *(Bu dosya tahmin motoru çıktılarından mantıksal olarak bağımsız kalacaktır.)*

---

# 58. GNSS Candidate Schema (GNSS Aday Şeması)

```text
timestamp_ns,
sequence_number,
provider,
latitude_deg,
longitude_deg,
horizontal_accuracy_m,
has_altitude,
altitude_m,
has_speed,
speed_mps,
has_bearing,
bearing_deg
```

Additional availability and accuracy fields may be added where Android provides them. *(Android sağladığında ek kullanılabilirlik ve accuracy alanları eklenebilir.)*

---

# 59. GNSS Status File (GNSS Status Dosyası)

```text
raw/gnss_status.csv
```

Satellite diagnostics will remain diagnostic evidence rather than direct position ground truth. *(Uydu diagnostics doğrudan konum ground truth yerine tanısal kanıt olarak kalacaktır.)*

---

# 60. ARCore Raw File (ARCore Ham Dosyası)

```text
raw/arcore_pose.csv
```

---

# 61. ARCore Candidate Schema (ARCore Aday Şeması)

```text
frame_timestamp_ns,
native_receive_timestamp_ns,
sequence_number,
tx,
ty,
tz,
qx,
qy,
qz,
qw,
tracking_state
```

The raw quaternion ordering will be documented explicitly. *(Ham quaternion sırası açık şekilde dokümante edilecektir.)*

---

# 62. Raw Camera Frames Are Not Stored by Default (Ham Kamera Kareleri Varsayılan Olarak Saklanmaz)

NAVGUARD does not require persistent raw camera video for the core navigation experiment. *(NAVGUARD temel navigasyon deneyi için kalıcı ham kamera videosu gerektirmez.)*

ARCore pose evidence will be preferred over saving full image streams. *(Tam görüntü akışlarını kaydetmek yerine ARCore pose kanıtı tercih edilecektir.)*

---

# 63. Processed Files (İşlenmiş Dosyalar)

Processed outputs will be organized by subsystem. *(İşlenmiş çıktılar alt sisteme göre düzenlenecektir.)*

---

# 64. Step Detection Output (Adım Tespit Çıktısı)

```text
processed/step_events.csv
```

---

# 65. Step Event Candidate Schema (Adım Olayı Aday Şeması)

```text
step_id,
timestamp_ns,
detector_version,
confidence,
motion_context,
accepted
```

Optional feature values may be stored when needed for diagnostics. *(İsteğe bağlı özellik değerleri diagnostics için gerektiğinde saklanabilir.)*

---

# 66. Heading Output (Yön Çıktısı)

```text
processed/heading.csv
```

---

# 67. Heading Candidate Schema (Yön Aday Şeması)

```text
timestamp_ns,
heading_rad_true,
heading_source,
confidence,
quality_state,
declination_rad
```

---

# 68. Step Length Output (Adım Uzunluğu Çıktısı)

```text
processed/step_length.csv
```

---

# 69. Step Length Candidate Schema (Adım Uzunluğu Aday Şeması)

```text
step_id,
timestamp_ns,
step_length_m,
method_id,
model_id,
quality_state,
fallback_used
```

---

# 70. PDR Output (PDR Çıktısı)

```text
processed/pdr_state.csv
```

---

# 71. PDR Candidate Schema (PDR Aday Şeması)

```text
timestamp_ns,
step_index,
step_event_id,
heading_rad,
heading_source,
step_length_m,
step_length_source,
delta_e_m,
delta_n_m,
east_m,
north_m,
path_distance_m,
motion_class,
quality_state
```

---

# 72. Motion AI Output (Hareket Yapay Zekâsı Çıktısı)

```text
processed/motion_ai.csv
```

---

# 73. Motion AI Candidate Schema (Hareket Yapay Zekâsı Aday Şeması)

```text
prediction_id,
window_start_ns,
window_end_ns,
model_id,
predicted_class,
confidence,
latency_us,
quality_state,
accepted_operationally
```

---

# 74. Fused Position Output (Füzyonlu Konum Çıktısı)

```text
processed/fused_position.csv
```

---

# 75. Fused Position Candidate Schema (Füzyonlu Konum Aday Şeması)

```text
timestamp_ns,
east_m,
north_m,
latitude_deg,
longitude_deg,
quality_state,
validity_state,
cov_ee,
cov_en,
cov_nn,
horizontal_uncertainty_m,
anchor_id,
mode
```

---

# 76. GNSS Processed ENU Reference (GNSS İşlenmiş ENU Referansı)

```text
processed/gnss_ground_truth_enu.csv
```

---

# 77. GNSS Ground Truth Must Not Share Estimator Output File (GNSS Ground Truth Tahmin Motoru Çıktı Dosyasını Paylaşmamalıdır)

Keeping ground truth in a separate artifact reinforces the Ground Truth Firewall concept. *(Ground truth'u ayrı artifact içerisinde tutmak Ground Truth Firewall kavramını güçlendirir.)*

---

# 78. Recovery Output (Recovery Çıktısı)

```text
processed/gnss_recovery_events.csv
```

---

# 79. Relocalization Output (Relocalization Çıktısı)

```text
processed/relocalization_events.csv
```

---

# 80. Event Log (Olay Logu)

The system will maintain a timestamped event stream for important discrete transitions. *(Sistem önemli ayrık geçişler için zaman damgalı olay akışı tutacaktır.)*

---

# 81. Candidate Event File (Aday Olay Dosyası)

```text
events/session_events.csv
```

---

# 82. Event Schema (Olay Şeması)

```text
event_id,
timestamp_ns,
event_type,
source,
payload_json
```

---

# 83. Event Types (Olay Türleri)

Candidate event types include session start, session stop, denial start, recovery request, recovery accepted, relocalization, ARCore tracking loss, AI fallback, logging error, and session invalidation. *(Aday olay türleri oturum başlangıcını, oturum bitişini, kesinti başlangıcını, recovery isteğini, recovery kabulünü, relocalization'ı, ARCore tracking kaybını, yapay zekâ fallback'ini, logging hatasını ve oturum geçersizleştirmeyi içerir.)*

---

# 84. Event Payload Must Remain Structured (Olay Payload'u Yapılandırılmış Kalmalıdır)

Free-form human-readable text may accompany events. *(Free-form insan tarafından okunabilir metin olaylara eşlik edebilir.)*

Critical machine interpretation must not depend only on free-form text. *(Kritik machine interpretation yalnızca free-form metne bağlı olmamalıdır.)*

---

# 85. Session Timing Domain (Oturum Zamanlama Domain'i)

All high-frequency experimental records will use the common monotonic session timing conventions defined in Page 13. *(Tüm yüksek frekanslı deney kayıtları Page 13'te tanımlanan ortak monotonik oturum zamanlama kurallarını kullanacaktır.)*

---

# 86. Wall Clock as Metadata (Metadata Olarak Duvar Saati)

Wall-clock timestamps may be stored for human readability and file organization. *(Duvar saati zaman damgaları insan okunabilirliği ve dosya organizasyonu için saklanabilir.)*

They will not replace the authoritative monotonic measurement timestamps. *(Ana monotonik ölçüm zaman damgalarının yerini almayacaktır.)*

---

# 87. Boot Dependency (Boot Bağımlılığı)

Android elapsed-realtime timestamps are only directly meaningful within the same device boot context. *(Android elapsed-realtime zaman damgaları yalnızca aynı cihaz boot bağlamı içerisinde doğrudan anlamlıdır.)*

The session manifest should therefore retain boot-related context or enough timing metadata to prevent accidental cross-boot alignment. *(Bu nedenle oturum manifest'i yanlışlıkla boot'lar arası hizalamayı önlemek için boot ile ilişkili bağlamı veya yeterli zamanlama metadata bilgisini korumalıdır.)*

---

# 88. Writer Queue Architecture (Writer Queue Mimarisi)

High-frequency producers will not synchronously perform heavy disk work inside sensor callbacks. *(Yüksek frekanslı producer'lar sensör callback'leri içerisinde senkron olarak ağır disk işlemi gerçekleştirmeyecektir.)*

A dedicated logging writer path will receive queued records. *(Özel logging writer yolu kuyruklanmış kayıtları alacaktır.)*

---

# 89. Producer-Consumer Pattern (Producer-Consumer Deseni)

```text
Sensors / GNSS / ARCore / AI / Estimator
                 ↓
           Log Record Queue
                 ↓
            Writer Worker
                 ↓
              Files
```

---

# 90. Writer Queue Must Be Bounded (Writer Queue Sınırlı Olmalıdır)

The logging queue must have a finite capacity. *(Logging kuyruğu sonlu kapasiteye sahip olmalıdır.)*

An unbounded queue could eventually consume application memory if storage becomes slower than data production. *(Sınırsız kuyruk depolama veri üretiminden daha yavaş hale gelirse sonunda uygulama belleğini tüketebilir.)*

---

# 91. Logging Backpressure (Logging Backpressure)

The system will monitor whether log production is outpacing disk writes. *(Sistem log üretiminin disk yazımını geçip geçmediğini izleyecektir.)*

---

# 92. No Silent Sample Dropping (Sessiz Örnek Düşürme Olmaması)

If logging records must be dropped because of a severe backpressure condition, the drop must be counted and surfaced. *(Ciddi backpressure koşulu nedeniyle logging kayıtları düşürülmek zorunda kalırsa düşüş sayılmalı ve görünür hale getirilmelidir.)*

---

# 93. Drop Counters (Drop Counter'ları)

```text
sensorLogDroppedCount
gnssLogDroppedCount
arcoreLogDroppedCount
aiLogDroppedCount
positionLogDroppedCount
eventLogDroppedCount
```

---

# 94. Logging Failure May Affect Session Validity (Logging Hatası Oturum Geçerliliğini Etkileyebilir)

Loss of mandatory evidence can invalidate a formal benchmark session even when navigation itself continues. *(Zorunlu kanıt kaybı navigasyon devam etse bile resmî benchmark oturumunu geçersiz kılabilir.)*

---

# 95. Navigation and Logging Failure Isolation (Navigasyon ve Logging Hata İzolasyonu)

A logging error should not unnecessarily crash navigation. *(Logging hatası navigasyonu gereksiz şekilde çökertmemelidir.)*

The session may continue with a clearly degraded research-validity state. *(Oturum açık şekilde bozulmuş araştırma geçerlilik durumuyla devam edebilir.)*

---

# 96. Critical Versus Non-Critical Logs (Kritik ve Kritik Olmayan Loglar)

Not every diagnostic log has equal importance. *(Her diagnostic log eşit öneme sahip değildir.)*

The logging profile will classify streams by priority. *(Logging profili akışları önceliğe göre sınıflandıracaktır.)*

---

# 97. Candidate Logging Priorities (Aday Logging Öncelikleri)

```text
CRITICAL
HIGH
NORMAL
OPTIONAL
```

---

# 98. CRITICAL Logging Examples (CRITICAL Logging Örnekleri)

Critical evidence includes mandatory IMU data, estimator state required for the target configuration, denial boundaries, and protected ground-truth evidence in Evaluation Mode. *(Kritik kanıt zorunlu IMU verisini, hedef yapılandırma için gerekli tahmin motoru durumunu, kesinti sınırlarını ve Evaluation Mode içerisindeki korunan ground-truth kanıtını içerir.)*

---

# 99. OPTIONAL Logging Examples (OPTIONAL Logging Örnekleri)

Optional evidence may include detailed satellite diagnostics or extended runtime profiling during ordinary non-benchmark sessions. *(İsteğe bağlı kanıt normal benchmark dışı oturumlarda ayrıntılı uydu diagnostics veya genişletilmiş runtime profiling içerebilir.)*

---

# 100. Logging Profile (Logging Profili)

```text
LoggingProfile
- rawAccelerometer
- rawGyroscope
- rawMagnetometer
- rotationVector
- gnss
- gnssStatus
- arcore
- stepEvents
- heading
- motionAi
- stepLength
- pdr
- fusedPosition
- covariance
- runtimeDiagnostics
```

---

# 101. Runtime Modes and Logging (Runtime Modları ve Logging)

Development Mode may enable richer diagnostic logging. *(Development Mode daha zengin diagnostic logging etkinleştirebilir.)*

Benchmark Mode will freeze the mandatory evidence set. *(Benchmark Mode zorunlu kanıt setini sabitleyecektir.)*

Demo Mode may reduce low-value diagnostics while preserving navigation-critical records. *(Demo Mode navigasyon açısından kritik kayıtları korurken düşük değerli diagnostics'i azaltabilir.)*

---

# 102. CSV as the Initial High-Frequency Format (İlk Yüksek Frekans Formatı Olarak CSV)

CSV will be the preferred initial research format for many high-frequency streams because it is simple, inspectable, and directly usable from Python. *(CSV basit, incelenebilir ve Python'dan doğrudan kullanılabilir olduğu için birçok yüksek frekanslı akış için tercih edilen ilk araştırma formatı olacaktır.)*

---

# 103. CSV Limitations (CSV Sınırlamaları)

CSV is not the most storage-efficient format for large time-series datasets. *(CSV büyük zaman serisi veri setleri için en depolama verimli format değildir.)*

If actual session sizes become problematic, a binary or columnar research format may be evaluated later. *(Gerçek oturum boyutları problem oluşturursa daha sonra binary veya columnar araştırma formatı değerlendirilebilir.)*

---

# 104. No Premature Binary Optimization (Erken Binary Optimizasyonu Olmaması)

NAVGUARD will not introduce complex binary serialization before measurements show that CSV is insufficient. *(NAVGUARD ölçümler CSV'nin yetersiz olduğunu göstermeden karmaşık binary serialization eklemeyecektir.)*

---

# 105. CSV Formatting Rules (CSV Formatlama Kuralları)

CSV files will use a fixed header per schema version. *(CSV dosyaları schema sürümü başına sabit header kullanacaktır.)*

Numerical formatting must be locale-independent. *(Sayısal formatlama locale bağımsız olmalıdır.)*

---

# 106. Decimal Separator (Ondalık Ayırıcı)

Decimal values will use `.` as the serialized decimal separator. *(Ondalık değerler serialize edilmiş ondalık ayırıcı olarak `.` kullanacaktır.)*

---

# 107. No Locale-Dependent Number Formatting (Locale Bağımlı Sayı Formatı Olmaması)

A Turkish device locale must not cause serialized floating-point numbers to use commas as decimal separators inside CSV values. *(Türkçe cihaz locale'i serialize edilmiş floating-point sayıların CSV değerleri içerisinde ondalık ayırıcı olarak virgül kullanmasına neden olmamalıdır.)*

---

# 108. Text Encoding (Metin Kodlama)

Text-based artifacts will use UTF-8. *(Metin tabanlı artifact'lar UTF-8 kullanacaktır.)*

---

# 109. Line Endings (Satır Sonları)

The writer will use a consistent line-ending policy. *(Writer tutarlı satır sonu politikası kullanacaktır.)*

Python analysis code must tolerate normal platform-safe line ending differences. *(Python analiz kodu normal platform güvenli satır sonu farklılıklarını tolere etmelidir.)*

---

# 110. Flush Strategy (Flush Stratejisi)

The writer will buffer records for efficiency but flush frequently enough to limit evidence loss during an unexpected crash. *(Writer verimlilik için kayıtları buffer'layacak ancak beklenmedik crash sırasında kanıt kaybını sınırlayacak kadar sık flush edecektir.)*

---

# 111. No Flush on Every Sensor Sample (Her Sensör Örneğinde Flush Olmaması)

Flushing storage synchronously after every 50 Hz sensor sample would be unnecessarily expensive. *(Her 50 Hz sensör örneğinden sonra depolamayı senkron şekilde flush etmek gereksiz derecede pahalı olacaktır.)*

---

# 112. Flush Interval Pending Profiling (Flush Aralığı Profiling Bekliyor)

The final record-count or time-based flush interval will be selected after device storage tests. *(Nihai kayıt sayısı veya zaman tabanlı flush aralığı cihaz depolama testlerinden sonra seçilecektir.)*

---

# 113. Explicit Flush on Critical Events (Kritik Olaylarda Açık Flush)

Important boundaries such as denial start, recovery evidence capture, session stop, and session invalidation may request an immediate controlled flush. *(Kesinti başlangıcı, recovery kanıt yakalama, oturum bitişi ve oturum invalidation gibi önemli sınırlar anında kontrollü flush isteyebilir.)*

---

# 114. Session Start Sequence (Oturum Başlatma Sırası)

```text
1. Generate session ID
2. Create database record
3. Create session directory
4. Write configuration snapshot
5. Create active marker
6. Open required log writers
7. Perform storage readiness check
8. Start acquisition
9. Mark session ACTIVE
```

Each step must have clear failure handling. *(Her adım açık hata yönetimine sahip olmalıdır.)*

---

# 115. Storage Readiness Check (Depolama Hazırlık Kontrolü)

The system will verify that the session directory is writable before formal acquisition begins. *(Sistem resmî veri toplama başlamadan önce oturum klasörünün yazılabilir olduğunu doğrulayacaktır.)*

---

# 116. Available Storage Check (Kullanılabilir Depolama Kontrolü)

The application may check available storage before a benchmark session. *(Uygulama benchmark oturumu öncesinde kullanılabilir depolamayı kontrol edebilir.)*

Exact minimum-free-space thresholds remain pending measured session sizes. *(Kesin minimum boş alan eşikleri ölçülmüş oturum boyutlarını beklemektedir.)*

---

# 117. No Guaranteed Session Duration Without Storage Evidence (Depolama Kanıtı Olmadan Garantili Oturum Süresi Olmaması)

The application will not claim that a given free-space amount supports a specific recording duration until actual byte rates have been measured. *(Uygulama gerçek byte hızları ölçülmeden belirli boş alan miktarının belirli kayıt süresini desteklediğini iddia etmeyecektir.)*

---

# 118. Session Stop Sequence (Oturum Durdurma Sırası)

```text
1. Stop accepting new session commands
2. Stop acquisition producers
3. Complete queued processing
4. Stop derived-event generation
5. Drain writer queues
6. Flush writers
7. Close files
8. Generate summaries
9. Run integrity checks
10. Finalize manifest
11. Remove active marker
12. Mark session COMPLETED
```

---

# 119. Producer Stop Before Writer Close (Writer Kapanmadan Önce Producer Durdurma)

The writer must not be closed while producers can still enqueue mandatory records. *(Producer'lar hâlâ zorunlu kayıtları kuyruğa ekleyebilirken writer kapatılmamalıdır.)*

---

# 120. Drain Before Close (Kapatmadan Önce Drain)

The normal finalization path will allow queued mandatory records to drain before file handles are closed. *(Normal finalization yolu dosya handle'ları kapanmadan önce kuyruktaki zorunlu kayıtların drain edilmesine izin verecektir.)*

---

# 121. Finalization Integrity Checks (Finalization Bütünlük Kontrolleri)

The finalization process will verify the existence of mandatory files. *(Finalization süreci zorunlu dosyaların varlığını doğrulayacaktır.)*

It will verify that mandatory files are readable. *(Zorunlu dosyaların okunabilir olduğunu doğrulayacaktır.)*

It will verify basic timestamp and row-count plausibility. *(Temel zaman damgası ve satır sayısı makullüğünü doğrulayacaktır.)*

---

# 122. Session Completion Is Conditional (Oturum Tamamlanması Koşulludur)

A session will not be marked `COMPLETED` merely because the user pressed Stop. *(Kullanıcı Stop'a bastığı için oturum yalnızca bu nedenle `COMPLETED` işaretlenmeyecektir.)*

Mandatory finalization must succeed. *(Zorunlu finalization başarılı olmalıdır.)*

---

# 123. Crash Recovery Principle (Crash Recovery İlkesi)

NAVGUARD will assume that unexpected process termination can occur during a recording session. *(NAVGUARD kayıt oturumu sırasında beklenmedik process termination gerçekleşebileceğini varsayacaktır.)*

---

# 124. Incomplete Session Detection (Tamamlanmamış Oturum Tespiti)

On application launch, the session manager will inspect database state and active-session markers for sessions that were not finalized. *(Uygulama başlatıldığında oturum yöneticisi finalize edilmemiş oturumlar için veritabanı durumunu ve aktif oturum marker'larını inceleyecektir.)*

---

# 125. Crash-Recovered Session Is Not Automatically Completed (Crash Sonrası Kurtarılan Oturum Otomatik Olarak Tamamlanmaz)

An interrupted session will initially be marked `INCOMPLETE`. *(Kesintiye uğramış oturum başlangıçta `INCOMPLETE` işaretlenecektir.)*

---

# 126. Recovery Inspection (Kurtarma İncelemesi)

The system may inspect which files exist, their sizes, final readable lines, and available metadata. *(Sistem hangi dosyaların mevcut olduğunu, boyutlarını, son okunabilir satırlarını ve mevcut metadata bilgisini inceleyebilir.)*

---

# 127. Partial Last Line Handling (Kısmi Son Satır Yönetimi)

A crash may leave an incomplete final CSV line. *(Crash tamamlanmamış son CSV satırı bırakabilir.)*

The recovery parser may safely ignore or quarantine only the malformed incomplete tail rather than discarding the entire file. *(Recovery parser tüm dosyayı atmak yerine yalnızca bozuk tamamlanmamış tail'i güvenli şekilde yok sayabilir veya quarantine edebilir.)*

---

# 128. Raw Evidence Must Not Be Fabricated During Recovery (Recovery Sırasında Ham Kanıt Uydurulmamalıdır)

Missing records will not be reconstructed and inserted into raw files. *(Eksik kayıtlar yeniden oluşturulup ham dosyalara eklenmeyecektir.)*

---

# 129. Incomplete Session Preservation (Tamamlanmamış Oturumu Koruma)

An incomplete session will normally remain available for diagnostics rather than being deleted automatically. *(Tamamlanmamış oturum otomatik silinmek yerine normalde diagnostics için kullanılabilir kalacaktır.)*

---

# 130. User Cleanup Is Separate (Kullanıcı Temizliği Ayrıdır)

The user may later choose to delete incomplete sessions through explicit UI controls. *(Kullanıcı daha sonra açık UI kontrolleri üzerinden tamamlanmamış oturumları silmeyi seçebilir.)*

---

# 131. Automatic Deletion Is Forbidden for Evidence (Kanıt İçin Otomatik Silme Yasaktır)

Formal benchmark evidence will not be automatically deleted merely because a session failed. *(Resmî benchmark kanıtı oturum başarısız oldu diye otomatik olarak silinmeyecektir.)*

---

# 132. Session Invalidity Reasons (Oturum Geçersizlik Nedenleri)

A session may retain structured invalidity reasons. *(Oturum yapılandırılmış geçersizlik nedenlerini koruyabilir.)*

```text
GROUND_TRUTH_FIREWALL_VIOLATION
CRITICAL_SENSOR_LOSS
LOGGING_FAILURE
TIMESTAMP_CORRUPTION
RECOVERY_EVIDENCE_FAILURE
CONFIGURATION_MISMATCH
MANUAL_INVALIDATION
OTHER_DOCUMENTED_REASON
```

---

# 133. Multiple Invalidity Reasons (Birden Fazla Geçersizlik Nedeni)

A session may contain more than one invalidity reason. *(Oturum birden fazla geçersizlik nedeni içerebilir.)*

---

# 134. Invalidity Timestamp (Geçersizlik Zaman Damgası)

Whenever possible, the exact time at which validity was lost will be recorded. *(Mümkün olduğunda geçerliliğin kaybedildiği kesin zaman kaydedilecektir.)*

---

# 135. Session May Contain Valid Sub-Intervals (Oturum Geçerli Alt Aralıklar İçerebilir)

A later invalidation does not necessarily make earlier data technically unusable for every analysis. *(Daha sonraki invalidation daha önceki veriyi her analiz için teknik olarak kullanılamaz hale getirmeyebilir.)*

The intended evaluation policy will decide which intervals remain eligible. *(Amaçlanan değerlendirme politikası hangi aralıkların uygun kalacağına karar verecektir.)*

---

# 136. Session Event Timeline (Oturum Olay Zaman Çizgisi)

The full session lifecycle will be reconstructible from structured events. *(Tam oturum yaşam döngüsü yapılandırılmış olaylardan yeniden oluşturulabilir olacaktır.)*

---

# 137. Candidate Lifecycle Events (Aday Yaşam Döngüsü Olayları)

```text
SESSION_CREATED
SESSION_STARTED
GNSS_ANCHOR_ACCEPTED
CALIBRATION_STARTED
CALIBRATION_COMPLETED
DENIAL_STARTED
RECOVERY_REQUESTED
RECOVERY_REFERENCE_ACCEPTED
RELOCALIZATION_STARTED
RELOCALIZATION_COMPLETED
SESSION_STOP_REQUESTED
SESSION_FINALIZED
SESSION_INVALIDATED
```

---

# 138. Denied Interval Table (Kesintili Aralık Tablosu)

Each formal denied interval will have its own structured record. *(Her resmî kesintili aralık kendi yapılandırılmış kaydına sahip olacaktır.)*

---

# 139. Candidate Denied Interval Fields (Aday Kesintili Aralık Alanları)

```text
denied_interval_id
session_id
start_timestamp_ns
end_timestamp_ns
anchor_id
estimator_profile
ground_truth_logging_enabled
recovery_event_id
validity_state
```

---

# 140. Multiple Denied Intervals (Birden Fazla Kesintili Aralık)

The data model will not assume that a session can contain only one denied interval. *(Veri modeli bir oturumun yalnızca tek kesintili aralık içerebileceğini varsaymayacaktır.)*

---

# 141. Anchor Table (Anchor Tablosu)

All anchors will remain explicitly stored. *(Tüm anchor'lar açık şekilde saklanacaktır.)*

---

# 142. Candidate Anchor Fields (Aday Anchor Alanları)

```text
anchor_id
session_id
timestamp_ns
latitude_deg
longitude_deg
altitude_m
horizontal_accuracy_m
source_fix_count
selection_method
predecessor_anchor_id
creation_reason
```

---

# 143. Historical Anchor Preservation (Geçmiş Anchor Koruma)

A later re-anchor must not overwrite the original anchor database record. *(Daha sonraki re-anchor orijinal anchor veritabanı kaydının üzerine yazmamalıdır.)*

---

# 144. Recovery Event Table (Recovery Olay Tablosu)

Recovery events will be indexed both in files and structured metadata. *(Recovery olayları hem dosyalarda hem yapılandırılmış metadata içerisinde indexlenecektir.)*

---

# 145. Why Duplicate Indexing Is Acceptable (Neden Çift Indexleme Kabul Edilebilir)

SQLite provides convenient lookup and UI presentation. *(SQLite kullanışlı lookup ve UI sunumu sağlar.)*

Portable event files preserve replay and external-analysis independence. *(Taşınabilir olay dosyaları replay ve harici analiz bağımsızlığını korur.)*

---

# 146. Database Is an Index, Not the Sole Evidence Store (Veritabanı Bir Index'tir, Tek Kanıt Deposu Değildir)

A corrupted SQLite database should not necessarily destroy the ability to interpret exported session directories. *(Bozulmuş SQLite veritabanı export edilmiş oturum klasörlerini yorumlama yeteneğini zorunlu olarak yok etmemelidir.)*

---

# 147. Schema Versioning (Schema Sürümleme)

Every structured storage format will have an explicit schema version. *(Her yapılandırılmış depolama formatı açık schema sürümüne sahip olacaktır.)*

---

# 148. Schema Version Types (Schema Sürüm Türleri)

```text
database_schema_version
manifest_schema_version
raw_sensor_schema_version
processed_schema_version
event_schema_version
export_schema_version
```

---

# 149. Schema Version Must Be Stored with Artifact (Schema Sürümü Artifact ile Saklanmalıdır)

The parser should not infer schema version only from file name. *(Parser schema sürümünü yalnızca dosya isminden çıkarmamalıdır.)*

---

# 150. Database Migration (Veritabanı Migration)

SQLite schema changes will use explicit migrations. *(SQLite schema değişiklikleri açık migration kullanacaktır.)*

---

# 151. No Silent Destructive Migration (Sessiz Yıkıcı Migration Olmaması)

A development migration must not silently discard historical benchmark session metadata. *(Geliştirme migration'ı geçmiş benchmark oturum metadata bilgisini sessizce atmamalıdır.)*

---

# 152. File Schema Compatibility (Dosya Schema Uyumluluğu)

Python analysis and replay tools will recognize supported historical file schema versions. *(Python analiz ve replay araçları desteklenen geçmiş dosya schema sürümlerini tanıyacaktır.)*

---

# 153. New Schema Does Not Rewrite Old Raw Files (Yeni Schema Eski Ham Dosyaları Yeniden Yazmaz)

Schema evolution will normally affect newly produced artifacts. *(Schema evolution normalde yeni üretilen artifact'ları etkileyecektir.)*

Older raw evidence remains preserved with its original schema identifier. *(Eski ham kanıt orijinal schema tanımlayıcısıyla korunmuş kalacaktır.)*

---

# 154. Derived Regeneration (Türetilmiş Veriyi Yeniden Üretme)

If preprocessing logic changes, new processed outputs may be regenerated from raw evidence. *(Ön işleme mantığı değişirse yeni işlenmiş çıktılar ham kanıttan yeniden üretilebilir.)*

---

# 155. Processed Output Versioning (İşlenmiş Çıktı Sürümleme)

Different processed runs must remain distinguishable. *(Farklı işlenmiş run'lar ayırt edilebilir kalmalıdır.)*

---

# 156. Candidate Derived Run Structure (Aday Türetilmiş Run Yapısı)

```text
processed/
└── run_<processing_id>/
    ├── preprocessing.json
    ├── step_events.csv
    ├── heading.csv
    ├── pdr_state.csv
    └── fused_position.csv
```

The first implementation may use a simpler single active processed directory if explicit versioning is preserved elsewhere. *(İlk uygulama açık sürümleme başka yerde korunuyorsa daha basit tek aktif processed klasörü kullanabilir.)*

---

# 157. Replay Does Not Modify Raw Session (Replay Ham Oturumu Değiştirmez)

Replay will read session evidence and write its results to a distinct derived area. *(Replay oturum kanıtını okuyacak ve sonuçlarını ayrı türetilmiş alana yazacaktır.)*

---

# 158. Replay Run Identity (Replay Run Kimliği)

Every formal replay may have a `replay_id`. *(Her resmî replay bir `replay_id` değerine sahip olabilir.)*

---

# 159. Candidate Replay Manifest (Aday Replay Manifest'i)

```text
replay_id
source_session_id
created_at
configuration
software_version
input_artifacts
output_artifacts
ground_truth_firewall_policy
```

---

# 160. Ground Truth Firewall in Storage (Depolamada Ground Truth Firewall)

The storage system may physically contain both estimator data and ground-truth GNSS. *(Depolama sistemi fiziksel olarak hem tahmin motoru verisini hem ground-truth GNSS'i içerebilir.)*

Separation is enforced through typed artifact roles and replay authorization rather than by pretending the ground-truth file does not exist. *(Ayrım ground-truth dosyası yokmuş gibi davranmak yerine typed artifact rolleri ve replay authorization üzerinden uygulanacaktır.)*

---

# 161. Ground Truth Artifact Classification (Ground Truth Artifact Sınıflandırması)

Ground-truth artifacts will be explicitly marked as `REFERENCE_ONLY` or equivalent. *(Ground-truth artifact'ları açık şekilde `REFERENCE_ONLY` veya eşdeğer olarak işaretlenecektir.)*

---

# 162. Estimator Input Classification (Tahmin Motoru Girdi Sınıflandırması)

Replay inputs will be categorized by whether they are authorized to enter the estimator under a specific navigation mode. *(Replay girdileri belirli navigasyon modu altında tahmin motoruna girmesine izin verilip verilmediğine göre sınıflandırılacaktır.)*

---

# 163. Unauthorized Reference Access Detection (Yetkisiz Referans Erişimi Tespiti)

If a replay pipeline attempts to expose a protected reference artifact to a denied estimator, the run should fail or be marked invalid. *(Replay hattı korunan referans artifact'ını kesintili tahmin motoruna sunmaya çalışırsa run başarısız olmalı veya geçersiz işaretlenmelidir.)*

---

# 164. Session Export (Oturum Export'u)

The user will be able to export a session for external analysis. *(Kullanıcı harici analiz için oturumu export edebilecektir.)*

---

# 165. Export Package Goals (Export Paket Hedefleri)

An export must preserve enough context to interpret data independently. *(Export veriyi bağımsız yorumlamak için yeterli bağlamı korumalıdır.)*

---

# 166. Candidate Export Package (Aday Export Paketi)

```text
NAVGUARD_<session_id>.zip

manifest.json
config/
raw/
processed/
events/
summaries/
checksums.json
```

The exact archive format may remain ZIP for simplicity. *(Kesin archive formatı basitlik için ZIP olarak kalabilir.)*

---

# 167. Export Does Not Delete Source (Export Kaynağı Silmez)

Creating an export package will not remove the original local session. *(Export paketi oluşturmak orijinal yerel oturumu kaldırmayacaktır.)*

---

# 168. Export Snapshot Principle (Export Snapshot İlkesi)

An exported package represents the session state at export time. *(Export edilmiş paket export anındaki oturum durumunu temsil eder.)*

---

# 169. Export of Incomplete Sessions (Tamamlanmamış Oturum Export'u)

Incomplete sessions may be exportable for diagnostics. *(Tamamlanmamış oturumlar diagnostics için export edilebilir.)*

Their manifest must clearly identify them as incomplete. *(Manifest'leri onları açık şekilde tamamlanmamış olarak tanımlamalıdır.)*

---

# 170. Checksums (Checksum'lar)

Formal export packages may include file hashes. *(Resmî export paketleri dosya hash'leri içerebilir.)*

---

# 171. Candidate Checksum Manifest (Aday Checksum Manifest'i)

```text
{
  "algorithm": "SHA-256",
  "files": {
    "raw/accelerometer.csv": "...",
    "raw/gyroscope.csv": "...",
    "manifest.json": "..."
  }
}
```

---

# 172. Hashing Raw Evidence (Ham Kanıtı Hash'leme)

Important raw files may be hashed after session finalization. *(Önemli ham dosyalar oturum finalization sonrasında hash'lenebilir.)*

This allows later integrity checks. *(Bu daha sonraki bütünlük kontrollerine izin verir.)*

---

# 173. Hashing Is Not Encryption (Hash'leme Encryption Değildir)

Checksums detect modification but do not make sensitive location data private. *(Checksum'lar değişikliği tespit eder ancak hassas konum verisini gizli hale getirmez.)*

Privacy and security controls will be defined in Page 32. *(Gizlilik ve güvenlik kontrolleri Page 32'de tanımlanacaktır.)*

---

# 174. Session Import (Oturum Import'u)

A development-only import capability may be added so exported sessions can be loaded for replay. *(Export edilmiş oturumların replay için yüklenebilmesi amacıyla development-only import yeteneği eklenebilir.)*

---

# 175. Imported Session Provenance (Import Edilmiş Oturum Kökeni)

Imported data must retain its original session identity and must not masquerade as newly collected live evidence. *(Import edilmiş veri orijinal oturum kimliğini korumalı ve yeni toplanmış canlı kanıt gibi davranmamalıdır.)*

---

# 176. Storage Root Location (Depolama Root Konumu)

The initial application will use app-controlled local storage appropriate for Android. *(İlk uygulama Android için uygun uygulama kontrollü yerel depolamayı kullanacaktır.)*

The exact directory strategy will be frozen during Android implementation and permission design. *(Kesin klasör stratejisi Android uygulaması ve permission tasarımı sırasında sabitlenecektir.)*

---

# 177. Internal Versus User-Accessible Storage (Dahili ve Kullanıcı Erişilebilir Depolama)

Internal application storage may be preferred for active session integrity. *(Aktif oturum bütünlüğü için dahili uygulama depolaması tercih edilebilir.)*

Explicit export can then create user-accessible copies. *(Açık export daha sonra kullanıcı tarafından erişilebilir kopyalar oluşturabilir.)*

---

# 178. No Direct User Editing During Recording (Kayıt Sırasında Doğrudan Kullanıcı Düzenlemesi Olmaması)

Active raw files should not be exposed through a workflow that encourages editing while a formal session is recording. *(Aktif ham dosyalar resmî oturum kaydı sırasında düzenlemeyi teşvik eden workflow üzerinden sunulmamalıdır.)*

---

# 179. Storage Permission Minimization (Depolama Permission Minimizasyonu)

The application will avoid unnecessary broad storage permissions when app-controlled storage and explicit export are sufficient. *(Uygulama kontrollü depolama ve açık export yeterli olduğunda uygulama gereksiz geniş depolama permission'larından kaçınacaktır.)*

Detailed Android permission behavior belongs to Page 32. *(Ayrıntılı Android permission davranışı Page 32'ye aittir.)*

---

# 180. Session History UI (Oturum Geçmişi UI'ı)

The application will provide a session-history view backed primarily by SQLite metadata. *(Uygulama temel olarak SQLite metadata bilgisi tarafından desteklenen oturum geçmişi görünümü sağlayacaktır.)*

---

# 181. Session History Candidate Fields (Oturum Geçmişi Aday Alanları)

```text
Session name
Date
Duration
Mode
Status
Denied duration
Estimated distance
Ground truth availability
Quality
```

---

# 182. Opening a Session (Oturum Açma)

Selecting a session may show summary, configuration, trajectory, errors, and available artifacts. *(Bir oturum seçmek özet, yapılandırma, trajectory, hatalar ve mevcut artifact'ları gösterebilir.)*

---

# 183. Session Detail Does Not Recompute Automatically (Oturum Detayı Otomatik Yeniden Hesaplama Yapmaz)

Opening a historical session in the UI should not silently rerun new preprocessing and replace its original recorded summary. *(UI içerisinde geçmiş oturumu açmak sessizce yeni ön işleme çalıştırıp orijinal kaydedilmiş özetinin yerini almamalıdır.)*

---

# 184. Explicit Reprocessing (Açık Yeniden İşleme)

If reprocessing is supported, it will be an explicit action producing a new derived run. *(Yeniden işleme desteklenirse yeni türetilmiş run üreten açık işlem olacaktır.)*

---

# 185. Session Deletion (Oturum Silme)

Session deletion will require an explicit user action. *(Oturum silme açık kullanıcı işlemi gerektirecektir.)*

---

# 186. Deletion of Formal Evidence (Resmî Kanıtın Silinmesi)

Benchmark sessions should be protected from accidental deletion through additional confirmation or archival policy. *(Benchmark oturumları ek confirmation veya archival politikasıyla yanlışlıkla silinmekten korunmalıdır.)*

---

# 187. Archive State (Archive Durumu)

An archived session remains stored but is protected from routine modification or cleanup. *(Arşivlenmiş oturum saklanmış kalır ancak rutin değişiklik veya temizlemeden korunur.)*

---

# 188. Automatic Cleanup (Otomatik Temizleme)

Automatic deletion of old formal sessions will be disabled by default. *(Eski resmî oturumların otomatik silinmesi varsayılan olarak devre dışı olacaktır.)*

---

# 189. Storage Usage Reporting (Depolama Kullanımı Raporlama)

The application may report approximate disk usage per session. *(Uygulama oturum başına yaklaşık disk kullanımını raporlayabilir.)*

---

# 190. Session Size (Oturum Boyutu)

```text
sessionSizeBytes =
Σ artifactFileSize
```

---

# 191. Byte Rate Measurement (Byte Hızı Ölçümü)

Development sessions will measure approximate storage growth per minute. *(Geliştirme oturumları dakika başına yaklaşık depolama büyümesini ölçecektir.)*

---

# 192. Byte Rate Helps Storage Planning (Byte Hızı Depolama Planlamasına Yardımcı Olur)

Measured byte rate can later support meaningful free-space warnings. *(Ölçülmüş byte hızı daha sonra anlamlı boş alan uyarılarını destekleyebilir.)*

---

# 193. Storage Performance Audit (Depolama Performans Denetimi)

A representative five-minute logging test will be part of the device audit or implementation validation. *(Temsili beş dakikalık logging testi cihaz denetiminin veya uygulama doğrulamasının parçası olacaktır.)*

---

# 194. Combined Logging Test (Birleşik Logging Testi)

Storage behavior will be tested while mandatory sensors and navigation processing are active simultaneously. *(Depolama davranışı zorunlu sensörler ve navigasyon işleme aynı anda aktifken test edilecektir.)*

---

# 195. Writer Latency Metrics (Writer Gecikme Metrikleri)

Development diagnostics may measure queue depth and writer throughput. *(Development diagnostics kuyruk derinliğini ve writer throughput'u ölçebilir.)*

---

# 196. Candidate Writer Health Metrics (Aday Writer Health Metrikleri)

```text
queueDepth
maxQueueDepth
recordsWritten
recordsDropped
writeErrors
flushCount
lastSuccessfulWriteNs
```

---

# 197. No UI Dependency on File Writes (UI'ın Dosya Yazımlarına Bağımlı Olmaması)

The navigation UI must not block waiting for high-frequency log records to reach disk. *(Navigasyon UI'ı yüksek frekanslı log kayıtlarının diske ulaşmasını bekleyerek block olmamalıdır.)*

---

# 198. Writer Thread / Coroutine Separation (Writer Thread / Coroutine Ayrımı)

File writing will run outside the main Flutter UI execution path. *(Dosya yazma ana Flutter UI execution yolunun dışında çalışacaktır.)*

The exact Kotlin coroutine or executor implementation will be selected after architecture profiling. *(Kesin Kotlin coroutine veya executor uygulaması mimari profiling sonrasında seçilecektir.)*

---

# 199. Logging From Dart and Kotlin (Dart ve Kotlin'den Logging)

Hardware-authoritative raw streams will preferably be logged close to the native acquisition source. *(Donanım ana ham akışları tercihen native veri toplama kaynağına yakın loglanacaktır.)*

Domain-level processed outputs may be logged from the layer that owns them. *(Domain seviyesi işlenmiş çıktılar sahip olan katmandan loglanabilir.)*

---

# 200. Single Session Logging Coordinator (Tek Oturum Logging Coordinator'ı)

A single session logging coordinator will own session-level writer lifecycle. *(Tek oturum logging coordinator'ı oturum seviyesi writer yaşam döngüsünün sahibi olacaktır.)*

---

# 201. Logging Coordinator Responsibilities (Logging Coordinator Sorumlulukları)

The coordinator will open required writers. *(Coordinator gerekli writer'ları açacaktır.)*

It will track writer health. *(Writer health durumunu takip edecektir.)*

It will coordinate flush and shutdown. *(Flush ve shutdown işlemlerini koordine edecektir.)*

---

# 202. No Independent Writer Lifecycle per UI Screen (UI Ekranı Başına Bağımsız Writer Yaşam Döngüsü Olmaması)

Opening or closing a diagnostics screen must not start or stop authoritative experiment logging. *(Diagnostics ekranını açmak veya kapatmak ana deney logging'ini başlatmamalı veya durdurmamalıdır.)*

---

# 203. Session Manager Responsibilities (Oturum Yöneticisi Sorumlulukları)

The Session Manager will own creation, start, stop, finalization, status, recovery detection, and historical session indexing. *(Oturum Yöneticisi oluşturma, başlatma, durdurma, finalization, durum, recovery detection ve geçmiş oturum indexleme işlemlerinin sahibi olacaktır.)*

---

# 204. Session Manager Does Not Own Estimation (Oturum Yöneticisi Tahmin Motorunun Sahibi Değildir)

The Session Manager coordinates lifecycle but does not calculate PDR or EKF states itself. *(Oturum Yöneticisi yaşam döngüsünü koordine eder ancak PDR veya EKF durumlarını kendisi hesaplamaz.)*

---

# 205. Session Service Candidate (Oturum Servis Adayı)

```text
SessionService

createSession(...)
prepareSession(...)
startSession(...)
stopSession(...)
finalizeSession(...)
markInvalid(...)
recoverIncompleteSession(...)
deleteSession(...)
exportSession(...)
```

---

# 206. Session Repository Candidate (Oturum Repository Adayı)

```text
SessionRepository

insert(...)
updateStatus(...)
getSession(...)
listSessions(...)
getArtifacts(...)
getDeniedIntervals(...)
getRecoveryEvents(...)
```

---

# 207. Session Configuration Is Frozen at Start (Oturum Yapılandırması Başlangıçta Sabitlenir)

Formal configuration changes after recording begins must be represented as explicit events or new segments. *(Kayıt başladıktan sonra resmî yapılandırma değişiklikleri açık olaylar veya yeni segmentler olarak temsil edilmelidir.)*

---

# 208. Major Mid-Session Configuration Changes (Oturum Ortasında Büyük Yapılandırma Değişiklikleri)

Major sensor-rate, estimator-profile, or logging-profile changes should normally start a new formal session. *(Büyük sensör hızı, tahmin motoru profili veya logging profili değişiklikleri normalde yeni resmî oturum başlatmalıdır.)*

---

# 209. Runtime Configuration Transition Event (Runtime Yapılandırma Geçiş Olayı)

If a change must occur mid-session, its exact timestamp and before/after configuration must be logged. *(Değişiklik oturum ortasında gerçekleşmek zorundaysa kesin zaman damgası ile önceki ve sonraki yapılandırma kaydedilmelidir.)*

---

# 210. No Hidden Configuration Drift (Gizli Yapılandırma Drift'i Olmaması)

A session must not silently change algorithms or thresholds without leaving traceable evidence. *(Oturum izlenebilir kanıt bırakmadan algoritmaları veya eşikleri sessizce değiştirmemelidir.)*

---

# 211. Model Identity Logging (Model Kimliği Logging)

Any AI-enabled session must record the exact active model identity. *(Yapay zekâ etkin her oturum kesin aktif model kimliğini kaydetmelidir.)*

---

# 212. AI Model Hash (Yapay Zekâ Model Hash'i)

Formal benchmark sessions will retain the model artifact hash defined in Page 27. *(Resmî benchmark oturumları Page 27'de tanımlanan model artifact hash'ini koruyacaktır.)*

---

# 213. Algorithm Version Logging (Algoritma Sürüm Logging)

Step detector, heading estimator, PDR, fusion, quality engine, and recovery subsystem should each expose a version or configuration identifier. *(Adım algılayıcı, yön tahmin motoru, PDR, füzyon, kalite motoru ve recovery alt sistemi ayrı ayrı sürüm veya yapılandırma tanımlayıcısı sunmalıdır.)*

---

# 214. Software Version Logging (Yazılım Sürüm Logging)

The manifest will record application version and build identity. *(Manifest uygulama sürümünü ve build kimliğini kaydedecektir.)*

---

# 215. Git Commit Candidate (Git Commit Adayı)

Development or Benchmark Mode may record the source-control commit identifier used to build the application. *(Development veya Benchmark Mode uygulamayı build etmek için kullanılan source-control commit tanımlayıcısını kaydedebilir.)*

This strongly improves reproducibility. *(Bu tekrarlanabilirliği güçlü şekilde artırır.)*

---

# 216. Dirty Working Tree Candidate (Dirty Working Tree Adayı)

During controlled benchmark builds, it may also be useful to record whether the source tree contained uncommitted changes. *(Kontrollü benchmark build'lerinde source tree'nin commit edilmemiş değişiklikler içerip içermediğini kaydetmek de kullanışlı olabilir.)*

---

# 217. Device Metadata (Cihaz Metadata Bilgisi)

Each formal session will reference the device configuration established by the Device Capability Audit. *(Her resmî oturum Cihaz Yetenek Denetimi tarafından oluşturulan cihaz yapılandırmasına referans verecektir.)*

---

# 218. Candidate Device Metadata (Aday Cihaz Metadata Bilgisi)

```text
device_model
manufacturer
android_version
api_level
build_identifier
sensor_inventory_id
application_version
```

Exact fields will remain limited to what is necessary for reproducibility and diagnostics. *(Kesin alanlar tekrarlanabilirlik ve diagnostics için gerekli olanlarla sınırlı kalacaktır.)*

---

# 219. Privacy-Aware Metadata (Gizlilik Farkındalıklı Metadata)

The storage system will avoid collecting unnecessary personally identifying device information. *(Depolama sistemi gereksiz kişisel olarak tanımlayıcı cihaz bilgisi toplamaktan kaçınacaktır.)*

Detailed privacy requirements belong to Page 32. *(Ayrıntılı gizlilik gereksinimleri Page 32'ye aittir.)*

---

# 220. Notes Field (Not Alanı)

The user may attach experimental notes to a session. *(Kullanıcı oturuma deneysel notlar ekleyebilir.)*

Notes remain supplementary and do not replace structured fields. *(Notlar tamamlayıcı kalır ve yapılandırılmış alanların yerini almaz.)*

---

# 221. Experimental Labels (Deneysel Etiketler)

A session may contain route, environment, motion, or field-test labels. *(Oturum rota, ortam, hareket veya saha testi etiketleri içerebilir.)*

---

# 222. Labels Are Versioned Evidence (Etiketler Sürümlenmiş Kanıttır)

Formal ML labels must retain their annotation version and provenance as defined in Page 25. *(Resmî ML etiketleri Page 25'te tanımlanan anotasyon sürümünü ve köken bilgisini korumalıdır.)*

---

# 223. User Manual Marker Events (Kullanıcı Manuel Marker Olayları)

The application may support manual experiment markers. *(Uygulama manuel deney marker'larını destekleyebilir.)*

Examples include `START_WALKING`, `STOP_WALKING`, `TURN_START`, or `KNOWN_DISTANCE_END`. *(Örnekler `START_WALKING`, `STOP_WALKING`, `TURN_START` veya `KNOWN_DISTANCE_END` olabilir.)*

---

# 224. Marker Timestamps (Marker Zaman Damgaları)

Manual markers will use the common monotonic timeline. *(Manuel marker'lar ortak monotonik zaman çizgisini kullanacaktır.)*

---

# 225. Marker Latency Awareness (Marker Gecikme Farkındalığı)

Manual button timing is not assumed to equal the exact biomechanical event time. *(Manuel buton zamanlamasının kesin biyomekanik olay zamanına eşit olduğu varsayılmayacaktır.)*

Offline annotation may refine boundaries later. *(Çevrimdışı anotasyon sınırları daha sonra iyileştirebilir.)*

---

# 226. Data Integrity Report (Veri Bütünlük Raporu)

Every finalized formal session will produce an integrity summary. *(Finalize edilmiş her resmî oturum bütünlük özeti üretecektir.)*

---

# 227. Candidate Integrity Fields (Aday Bütünlük Alanları)

```text
mandatoryFilesPresent
timestampChecksPassed
groundTruthIsolationPassed
sensorDropCounts
writerErrorCounts
recoveryEvidenceComplete
manifestComplete
hashesGenerated
```

---

# 228. Integrity Status (Bütünlük Durumu)

```text
PASS
PASS_WITH_WARNINGS
FAIL
```

---

# 229. Integrity PASS Does Not Mean Good Navigation Accuracy (Bütünlük PASS İyi Navigasyon Doğruluğu Anlamına Gelmez)

Integrity only confirms that required evidence and structural conditions are satisfied. *(Bütünlük yalnızca gerekli kanıtın ve yapısal koşulların karşılandığını doğrular.)*

Navigation accuracy is evaluated separately. *(Navigasyon doğruluğu ayrı değerlendirilir.)*

---

# 230. Session Summary Generation (Oturum Özeti Üretimi)

After finalization, NAVGUARD may generate a human-readable summary. *(Finalization sonrasında NAVGUARD insan tarafından okunabilir özet oluşturabilir.)*

---

# 231. Candidate Session Summary (Aday Oturum Özeti)

```text
Session ID
Duration
Device
Navigation profile
GNSS anchor
Denied intervals
Step count
Estimated distance
ARCore availability
AI model
Recovery result
Final error
Integrity status
```

---

# 232. Summary Values Must Be Recomputable (Özet Değerler Yeniden Hesaplanabilir Olmalıdır)

Important benchmark summary values should be derivable again from authoritative stored artifacts. *(Önemli benchmark özet değerleri ana saklanmış artifact'lardan tekrar türetilebilir olmalıdır.)*

---

# 233. No Manual-Only Benchmark Metrics (Yalnızca Manuel Benchmark Metrikleri Olmaması)

A final metric must not exist only as manually typed text in the UI. *(Nihai metrik yalnızca UI içerisinde elle yazılmış metin olarak bulunmamalıdır.)*

---

# 234. Exported Analysis Readiness (Export Edilmiş Analiz Hazırlığı)

Python scripts should be able to identify the session, schemas, timing, configuration, and available streams from the exported manifest. *(Python script'leri export edilmiş manifest'ten oturumu, schema'ları, zamanlamayı, yapılandırmayı ve mevcut akışları tanımlayabilmelidir.)*

---

# 235. Python Loader Candidate (Python Loader Adayı)

A future Python analysis package may expose a session loader abstraction. *(Gelecekteki Python analiz paketi session loader abstraction sunabilir.)*

```text
NavguardSession.load(path)
```

The exact implementation belongs to the analysis toolchain rather than the mobile storage core. *(Kesin uygulama mobil depolama core'undan çok analiz toolchain'ine aittir.)*

---

# 236. Replay Source Compatibility (Replay Kaynak Uyumluluğu)

The same exported session structure should support replay without requiring private application-internal state. *(Aynı export edilmiş oturum yapısı private uygulama dahili state'i gerektirmeden replay'i desteklemelidir.)*

---

# 237. Deterministic Replay Inputs (Deterministik Replay Girdileri)

Replay must know the exact raw input artifacts and frozen configuration. *(Replay kesin ham girdi artifact'larını ve sabitlenmiş yapılandırmayı bilmelidir.)*

---

# 238. Replay Outputs Are New Artifacts (Replay Çıktıları Yeni Artifact'lardır)

Replay results will not overwrite the original live outputs. *(Replay sonuçları orijinal canlı çıktıların üzerine yazmayacaktır.)*

---

# 239. Live Versus Replay Provenance (Canlı ile Replay Kökeni)

Every derived trajectory or model result should indicate whether it originated from `LIVE` or `REPLAY`. *(Her türetilmiş trajectory veya model sonucu `LIVE` veya `REPLAY` kaynaklı olup olmadığını belirtmelidir.)*

---

# 240. Candidate Processing Provenance (Aday İşleme Kökeni)

```text
processing_origin =
LIVE
REPLAY
OFFLINE_ANALYSIS
```

---

# 241. No Mixing Live and Replay Rows (Canlı ve Replay Satırlarını Karıştırmama)

Replay-generated rows must not be appended to the original live processed files without explicit separation. *(Replay tarafından oluşturulan satırlar açık ayrım olmadan orijinal canlı işlenmiş dosyalara append edilmemelidir.)*

---

# 242. Transactional Metadata Updates (Transactional Metadata Update'leri)

Critical SQLite lifecycle changes will use transactions where appropriate. *(Kritik SQLite yaşam döngüsü değişiklikleri uygun olduğunda transaction kullanacaktır.)*

---

# 243. File and Database Atomicity Challenge (Dosya ve Veritabanı Atomiklik Zorluğu)

SQLite transactions cannot make external CSV file writes atomically commit as part of the same database transaction. *(SQLite transaction'ları harici CSV dosya yazımlarını aynı veritabanı transaction'ının parçası olarak atomik şekilde commit edemez.)*

The application must therefore use explicit session states and recovery checks instead of pretending complete cross-resource atomicity exists. *(Bu nedenle uygulama tam kaynaklar arası atomiklik varmış gibi davranmak yerine açık oturum durumları ve recovery kontrolleri kullanmalıdır.)*

---

# 244. Finalization as Two-Phase-Like Workflow (İki Aşamalı Benzeri Workflow Olarak Finalization)

A practical pattern is to mark the session `FINALIZING`, finish files, verify them, then mark `COMPLETED`. *(Pratik desen oturumu `FINALIZING` işaretlemek, dosyaları tamamlamak, doğrulamak ve ardından `COMPLETED` işaretlemektir.)*

---

# 245. Interrupted Finalization Recovery (Kesintiye Uğramış Finalization Recovery)

If the application crashes during `FINALIZING`, the next launch can inspect the files and decide whether finalization can be resumed or the session must remain incomplete. *(Uygulama `FINALIZING` sırasında çökerse sonraki başlatma dosyaları inceleyip finalization'ın devam ettirilip ettirilemeyeceğine veya oturumun tamamlanmamış kalması gerekip gerekmediğine karar verebilir.)*

---

# 246. File Naming Consistency (Dosya İsimlendirme Tutarlılığı)

Canonical artifact file names will be stable across sessions for the same schema version. *(Canonical artifact dosya isimleri aynı schema sürümü için oturumlar arasında kararlı olacaktır.)*

---

# 247. No Human-Entered Dynamic Raw File Names (İnsan Tarafından Girilmiş Dinamik Ham Dosya İsimleri Olmaması)

User-provided session names will not become arbitrary raw file names. *(Kullanıcı tarafından sağlanan oturum isimleri keyfi ham dosya isimleri haline gelmeyecektir.)*

---

# 248. Path Safety (Path Güvenliği)

User-visible names will be sanitized before any optional inclusion in export filenames. *(Kullanıcı tarafından görülen isimler export dosya isimlerine isteğe bağlı dahil edilmeden önce sanitize edilecektir.)*

---

# 249. Temporary Files (Geçici Dosyalar)

Files generated during export or finalization may use temporary names until successfully completed. *(Export veya finalization sırasında oluşturulan dosyalar başarıyla tamamlanana kadar geçici isimler kullanabilir.)*

---

# 250. Atomic Rename Candidate (Atomik Rename Adayı)

Where supported by the Android filesystem, a completed temporary manifest or export may be moved to its final name through an atomic rename-like operation. *(Android filesystem desteklediğinde tamamlanmış geçici manifest veya export atomik rename benzeri işlem üzerinden nihai ismine taşınabilir.)*

---

# 251. Partial Export Protection (Kısmi Export Koruması)

A failed export should not appear as a valid completed export package. *(Başarısız export geçerli tamamlanmış export paketi olarak görünmemelidir.)*

---

# 252. Export Status (Export Durumu)

```text
CREATED
BUILDING
COMPLETED
FAILED
```

---

# 253. Export Hash Verification (Export Hash Doğrulaması)

Completed export packages may be verified immediately after creation. *(Tamamlanmış export paketleri oluşturulduktan hemen sonra doğrulanabilir.)*

---

# 254. Session Storage Tests (Oturum Depolama Testleri)

NAVGUARD will include automated tests for session creation and finalization. *(NAVGUARD oturum oluşturma ve finalization için otomatik testler içerecektir.)*

---

# 255. Storage Unit Test — Session ID (Depolama Birim Testi — Oturum ID)

Generated session identifiers must be unique in repeated test generation. *(Üretilen oturum tanımlayıcıları tekrarlanan test üretiminde benzersiz olmalıdır.)*

---

# 256. Storage Unit Test — Manifest Serialization (Depolama Birim Testi — Manifest Serialization)

A known session manifest must serialize and deserialize without losing required fields. *(Bilinen oturum manifest'i gerekli alanları kaybetmeden serialize ve deserialize edilmelidir.)*

---

# 257. Storage Unit Test — Schema Version (Depolama Birim Testi — Schema Sürümü)

An unsupported schema version must not be interpreted silently as the current schema. *(Desteklenmeyen schema sürümü sessizce mevcut schema olarak yorumlanmamalıdır.)*

---

# 258. Storage Unit Test — CSV Formatting (Depolama Birim Testi — CSV Formatlama)

Floating-point serialization must remain locale-independent. *(Floating-point serialization locale bağımsız kalmalıdır.)*

---

# 259. Storage Unit Test — Event Ordering (Depolama Birim Testi — Olay Sıralaması)

Stored event timestamps must preserve their defined ordering semantics. *(Saklanan olay zaman damgaları tanımlanan sıralama semantiğini korumalıdır.)*

---

# 260. Storage Unit Test — Artifact Index (Depolama Birim Testi — Artifact Index)

Every indexed artifact must resolve to the expected session and relative path. *(Indexlenen her artifact beklenen oturuma ve relative path'e çözümlenmelidir.)*

---

# 261. Logging Integration Test — Continuous IMU (Logging Entegrasyon Testi — Sürekli IMU)

A controlled sensor session must write continuous accelerometer and gyroscope logs without unbounded queue growth. *(Kontrollü sensör oturumu sınırsız kuyruk büyümesi olmadan sürekli ivmeölçer ve jiroskop logları yazmalıdır.)*

---

# 262. Logging Integration Test — Multi-Stream (Logging Entegrasyon Testi — Multi-Stream)

Accelerometer, gyroscope, magnetometer, GNSS, and derived position logging must operate concurrently. *(İvmeölçer, jiroskop, manyetometre, GNSS ve türetilmiş konum logging eş zamanlı çalışmalıdır.)*

---

# 263. Logging Integration Test — Writer Failure (Logging Entegrasyon Testi — Writer Hatası)

A forced write failure must produce an observable logging error and the correct session-validity response. *(Zorlanmış yazma hatası gözlemlenebilir logging hatası ve doğru oturum geçerlilik tepkisini üretmelidir.)*

---

# 264. Logging Integration Test — Queue Overflow (Logging Entegrasyon Testi — Queue Overflow)

Artificially slowed storage must not cause uncontrolled memory growth. *(Yapay olarak yavaşlatılmış depolama kontrolsüz bellek büyümesine neden olmamalıdır.)*

---

# 265. Logging Integration Test — Drop Counter (Logging Entegrasyon Testi — Drop Counter)

Any deliberately induced dropped record must increment the correct counter. *(Bilinçli olarak oluşturulan her düşürülmüş kayıt doğru counter'ı artırmalıdır.)*

---

# 266. Session Integration Test — Normal Completion (Oturum Entegrasyon Testi — Normal Tamamlama)

A normal session must progress from creation through finalization to `COMPLETED`. *(Normal oturum oluşturulmadan finalization'a ve `COMPLETED` durumuna kadar ilerlemelidir.)*

---

# 267. Session Integration Test — Crash (Oturum Entegrasyon Testi — Crash)

A simulated process termination during recording must leave enough markers to identify the session as incomplete on next launch. *(Kayıt sırasında simüle edilmiş process termination sonraki başlatmada oturumu tamamlanmamış olarak tanımlamak için yeterli marker bırakmalıdır.)*

---

# 268. Session Integration Test — Finalization Crash (Oturum Entegrasyon Testi — Finalization Crash)

A simulated interruption during finalization must not produce a false `COMPLETED` state. *(Finalization sırasında simüle edilmiş kesinti yanlış `COMPLETED` durumu üretmemelidir.)*

---

# 269. Session Integration Test — Recovery Evidence (Oturum Entegrasyon Testi — Recovery Kanıtı)

A formal recovery event must persist pre-correction evidence before relocalization completion is recorded. *(Resmî recovery olayı relocalization tamamlanması kaydedilmeden önce düzeltme öncesi kanıtı persist etmelidir.)*

---

# 270. Session Integration Test — Ground Truth Isolation (Oturum Entegrasyon Testi — Ground Truth İzolasyonu)

Ground-truth GNSS must be stored while remaining distinguishable from estimator-authorized streams. *(Ground-truth GNSS tahmin motoru için izin verilen akışlardan ayırt edilebilir kalırken saklanmalıdır.)*

---

# 271. Export Integration Test — Complete Session (Export Entegrasyon Testi — Tam Oturum)

A completed session export must contain its manifest and all mandatory artifacts. *(Tamamlanmış oturum export'u manifest'ini ve tüm zorunlu artifact'ları içermelidir.)*

---

# 272. Export Integration Test — Hashes (Export Entegrasyon Testi — Hash'ler)

Generated checksums must validate against exported files. *(Üretilen checksum'lar export edilmiş dosyalara karşı doğrulanmalıdır.)*

---

# 273. Replay Integration Test — Source Discovery (Replay Entegrasyon Testi — Kaynak Keşfi)

Replay must discover authoritative input artifacts through the manifest rather than through hard-coded assumptions only. *(Replay ana girdi artifact'larını yalnızca hard-coded varsayımlar yerine manifest üzerinden keşfetmelidir.)*

---

# 274. Replay Integration Test — Live Immutability (Replay Entegrasyon Testi — Canlı Değişmezlik)

A replay run must not alter original live raw or processed artifacts. *(Replay run'ı orijinal canlı ham veya işlenmiş artifact'ları değiştirmemelidir.)*

---

# 275. Replay Integration Test — Firewall (Replay Entegrasyon Testi — Firewall)

Replay of a denied interval must not expose protected GNSS to the estimator. *(Kesintili aralığın replay'i korunan GNSS'i tahmin motoruna sunmamalıdır.)*

---

# 276. Storage Performance Test (Depolama Performans Testi)

A representative multi-minute session will measure writer throughput, queue depth, file growth, and dropped-record counts. *(Temsili çok dakikalık oturum writer throughput, queue derinliği, dosya büyümesi ve düşürülen kayıt sayılarını ölçecektir.)*

---

# 277. Combined Runtime Storage Test (Birleşik Runtime Depolama Testi)

The storage benchmark will be repeated while AI, PDR, EKF, GNSS, and ARCore are active where applicable. *(Depolama benchmark'ı uygulanabilir olduğunda yapay zekâ, PDR, EKF, GNSS ve ARCore aktifken tekrarlanacaktır.)*

---

# 278. Storage Test IDs (Depolama Test ID'leri)

```text
STO-SES-001   Session creation
STO-SES-002   Session start
STO-SES-003   Normal finalization
STO-SES-004   Incomplete-session detection
STO-SES-005   Invalid-session handling

STO-DB-001    SQLite schema initialization
STO-DB-002    Migration integrity
STO-DB-003    Artifact indexing
STO-DB-004    Session listing

STO-RAW-001   Accelerometer logging
STO-RAW-002   Gyroscope logging
STO-RAW-003   Magnetometer logging
STO-RAW-004   GNSS logging
STO-RAW-005   ARCore logging

STO-LOG-001   Bounded writer queue
STO-LOG-002   Queue overflow visibility
STO-LOG-003   Controlled flush
STO-LOG-004   Writer failure
STO-LOG-005   Drop counters

STO-MAN-001   Manifest generation
STO-MAN-002   Configuration snapshot
STO-MAN-003   Schema versions
STO-MAN-004   Artifact list completeness

STO-INT-001   Mandatory file integrity
STO-INT-002   Timestamp integrity
STO-INT-003   Ground-truth role integrity
STO-INT-004   Recovery evidence integrity

STO-CRS-001   Crash during recording
STO-CRS-002   Crash during finalization
STO-CRS-003   Partial CSV tail recovery

STO-EXP-001   Session export
STO-EXP-002   Export checksum
STO-EXP-003   Incomplete-session export

STO-REP-001   Replay input discovery
STO-REP-002   Replay output separation
STO-REP-003   Replay Ground Truth Firewall

STO-PERF-001  Five-minute logging
STO-PERF-002  Combined-stack logging
STO-PERF-003  Storage growth rate
STO-PERF-004  Writer queue depth
```

---

# 279. Session Creation Acceptance Criteria (Oturum Oluşturma Kabul Kriterleri)

Every formal session must receive a unique immutable internal identifier. *(Her resmî oturum benzersiz değişmez dahili tanımlayıcı almalıdır.)*

A session database record and session directory must be created successfully before recording begins. *(Kayıt başlamadan önce oturum veritabanı kaydı ve oturum klasörü başarıyla oluşturulmalıdır.)*

---

# 280. Configuration Acceptance Criteria (Yapılandırma Kabul Kriterleri)

Every formal session must preserve a frozen configuration snapshot. *(Her resmî oturum sabitlenmiş yapılandırma snapshot'ını korumalıdır.)*

---

# 281. Raw Data Acceptance Criteria (Ham Veri Kabul Kriterleri)

Mandatory raw streams must preserve measurement timestamps and must not fabricate missing values. *(Zorunlu ham akışlar ölçüm zaman damgalarını korumalı ve eksik değerleri uydurmamalıdır.)*

---

# 282. Logging Acceptance Criteria (Logging Kabul Kriterleri)

High-frequency logging must not require synchronous disk work inside authoritative sensor callbacks. *(Yüksek frekanslı logging ana sensör callback'leri içerisinde senkron disk işlemi gerektirmemelidir.)*

The writer queue must remain bounded. *(Writer kuyruğu sınırlı kalmalıdır.)*

---

# 283. Drop Visibility Acceptance Criteria (Düşürme Görünürlüğü Kabul Kriterleri)

Any dropped mandatory log record must be observable through counters or integrity state. *(Düşürülen her zorunlu log kaydı counter'lar veya bütünlük durumu üzerinden gözlemlenebilir olmalıdır.)*

---

# 284. Finalization Acceptance Criteria (Finalization Kabul Kriterleri)

A session may become `COMPLETED` only after mandatory writers are closed, required artifacts exist, manifest generation succeeds, and final integrity checks pass. *(Bir oturum yalnızca zorunlu writer'lar kapandıktan, gerekli artifact'lar mevcut olduktan, manifest üretimi başarılı olduktan ve nihai bütünlük kontrolleri geçtikten sonra `COMPLETED` olabilir.)*

---

# 285. Crash Recovery Acceptance Criteria (Crash Recovery Kabul Kriterleri)

An interrupted active session must be detectable on the next application launch. *(Kesintiye uğramış aktif oturum sonraki uygulama başlatmada tespit edilebilir olmalıdır.)*

It must not be silently reported as completed. *(Sessizce tamamlanmış olarak raporlanmamalıdır.)*

---

# 286. Raw Immutability Acceptance Criteria (Ham Değişmezlik Kabul Kriterleri)

Replay or reprocessing must not modify authoritative raw session evidence. *(Replay veya yeniden işleme ana ham oturum kanıtını değiştirmemelidir.)*

---

# 287. Ground Truth Acceptance Criteria (Ground Truth Kabul Kriterleri)

Ground-truth GNSS must remain clearly identified as an independent reference artifact. *(Ground-truth GNSS açık şekilde bağımsız referans artifact'ı olarak tanımlanmış kalmalıdır.)*

Its presence in storage must not imply estimator authorization. *(Depolamada bulunması tahmin motoru authorization anlamına gelmemelidir.)*

---

# 288. Recovery Evidence Acceptance Criteria (Recovery Kanıt Kabul Kriterleri)

Critical pre-correction recovery evidence must be persisted before formal relocalization completion is committed in Benchmark Mode. *(Benchmark Modunda resmî relocalization tamamlanması commit edilmeden önce kritik düzeltme öncesi recovery kanıtı persist edilmelidir.)*

---

# 289. Manifest Acceptance Criteria (Manifest Kabul Kriterleri)

A completed formal session must have a valid manifest identifying its configuration, artifacts, timing, anchors, denied intervals, and integrity state. *(Tamamlanmış resmî oturum yapılandırmasını, artifact'larını, zamanlamasını, anchor'larını, kesintili aralıklarını ve bütünlük durumunu tanımlayan geçerli manifest'e sahip olmalıdır.)*

---

# 290. Export Acceptance Criteria (Export Kabul Kriterleri)

A formal export must contain sufficient metadata to interpret the session without the original SQLite database. *(Resmî export oturumu orijinal SQLite veritabanı olmadan yorumlamak için yeterli metadata içermelidir.)*

---

# 291. Replay Acceptance Criteria (Replay Kabul Kriterleri)

Replay must consume explicit source artifacts and configuration. *(Replay açık kaynak artifact'larını ve yapılandırmayı kullanmalıdır.)*

Replay outputs must remain separate from original live evidence. *(Replay çıktıları orijinal canlı kanıttan ayrı kalmalıdır.)*

---

# 292. Schema Version Acceptance Criteria (Schema Sürüm Kabul Kriterleri)

Every formal structured artifact must be associated with an explicit schema version. *(Her resmî yapılandırılmış artifact açık schema sürümüyle ilişkili olmalıdır.)*

---

# 293. Performance Acceptance Criteria (Performans Kabul Kriterleri)

Representative multi-stream logging must operate without uncontrolled memory growth. *(Temsili çoklu akış logging kontrolsüz bellek büyümesi olmadan çalışmalıdır.)*

Mandatory dropped-record counts should remain zero under the intended benchmark configuration. *(Amaçlanan benchmark yapılandırması altında zorunlu düşürülen kayıt sayıları sıfır kalmalıdır.)*

---

# 294. Minimum Successful Storage System (Minimum Başarılı Depolama Sistemi)

The minimum successful implementation will provide SQLite session metadata, per-session directories, append-oriented raw CSV logging, processed PDR and position logs, session manifests, controlled finalization, incomplete-session detection, and manual export. *(Minimum başarılı uygulama SQLite oturum metadata bilgisini, oturum başına klasörleri, append odaklı ham CSV logging'i, işlenmiş PDR ve konum loglarını, oturum manifestlerini, kontrollü finalization'ı, tamamlanmamış oturum tespitini ve manuel export'u sağlayacaktır.)*

---

# 295. Target Successful Storage System (Hedef Başarılı Depolama Sistemi)

The target implementation will additionally provide bounded asynchronous writer queues, integrity hashing, recovery evidence transactions, detailed artifact indexing, replay manifests, schema migrations, diagnostic writer health, and reproducible export packages. *(Hedef uygulama ek olarak sınırlı asynchronous writer kuyruklarını, bütünlük hash'lemeyi, recovery kanıt transaction'larını, ayrıntılı artifact indexlemeyi, replay manifestlerini, schema migration'larını, diagnostic writer health bilgisini ve tekrarlanabilir export paketlerini sağlayacaktır.)*

---

# 296. Optional Enhancements (İsteğe Bağlı İyileştirmeler)

Optional enhancements may include binary or columnar time-series formats if CSV becomes a measured bottleneck. *(İsteğe bağlı iyileştirmeler CSV ölçülmüş bottleneck haline gelirse binary veya columnar zaman serisi formatlarını içerebilir.)*

Optional enhancements may include development-only session import. *(İsteğe bağlı iyileştirmeler development-only session import özelliğini içerebilir.)*

Optional enhancements may include automatic integrity checksum verification during replay. *(İsteğe bağlı iyileştirmeler replay sırasında otomatik bütünlük checksum doğrulamasını içerebilir.)*

---

# 297. Storage Non-Goals (Depolama Olmayan Hedefler)

NAVGUARD will not require a cloud backend for core session storage. *(NAVGUARD temel oturum depolaması için cloud backend gerektirmeyecektir.)*

NAVGUARD will not require Firebase for minimum functionality. *(NAVGUARD minimum işlevsellik için Firebase gerektirmeyecektir.)*

NAVGUARD will not store raw camera video by default. *(NAVGUARD varsayılan olarak ham kamera videosu saklamayacaktır.)*

---

# 298. Additional Storage Non-Goals (Ek Depolama Olmayan Hedefler)

NAVGUARD will not silently reconstruct missing raw sensor records. *(NAVGUARD eksik ham sensör kayıtlarını sessizce yeniden oluşturmayacaktır.)*

NAVGUARD will not silently delete failed formal sessions. *(NAVGUARD başarısız resmî oturumları sessizce silmeyecektir.)*

NAVGUARD will not merge ground-truth and estimator trajectories into one indistinguishable file. *(NAVGUARD ground-truth ve tahmin motoru trajectory'lerini ayırt edilemez tek dosyada birleştirmeyecektir.)*

---

# 299. Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Kararlar)

NAVGUARD will use a hybrid local-storage architecture. *(NAVGUARD hibrit yerel depolama mimarisi kullanacaktır.)*

SQLite will store structured metadata and indexes. *(SQLite yapılandırılmış metadata ve index'leri saklayacaktır.)*

High-frequency evidence will primarily use append-oriented files. *(Yüksek frekanslı kanıt temel olarak append odaklı dosyaları kullanacaktır.)*

---

# 300. Raw Data Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Ham Veri Kararları)

Raw sensor streams will remain separate and asynchronous rather than being forced into artificially synchronized rows. *(Ham sensör akışları yapay olarak senkronize edilmiş satırlara zorlanmak yerine ayrı ve asynchronous kalacaktır.)*

Raw evidence will be immutable after commitment. *(Ham kanıt commit sonrasında değişmez olacaktır.)*

---

# 301. Session Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Oturum Kararları)

Every formal recording will belong to one immutable internal `session_id`. *(Her resmî kayıt tek değişmez dahili `session_id` değerine ait olacaktır.)*

Session status will explicitly distinguish `COMPLETED`, `INCOMPLETE`, and `INVALID`. *(Oturum durumu `COMPLETED`, `INCOMPLETE` ve `INVALID` durumlarını açık şekilde ayıracaktır.)*

---

# 302. Manifest Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Manifest Kararları)

Every completed formal session will contain a portable machine-readable manifest. *(Tamamlanmış her resmî oturum taşınabilir machine-readable manifest içerecektir.)*

---

# 303. Logging Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Logging Kararları)

High-frequency disk writes will not run directly inside critical sensor callbacks. *(Yüksek frekanslı disk yazımları kritik sensör callback'leri içerisinde doğrudan çalışmayacaktır.)*

Writer queues will be bounded. *(Writer kuyrukları sınırlı olacaktır.)*

Dropped records will never be silent. *(Düşürülen kayıtlar hiçbir zaman sessiz olmayacaktır.)*

---

# 304. Finalization Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Finalization Kararları)

Pressing Stop will not by itself mark a session complete. *(Stop'a basmak tek başına oturumu tamamlanmış işaretlemeyecektir.)*

Mandatory writer drain, flush, file close, manifest generation, and integrity checks must complete first. *(Önce zorunlu writer drain, flush, dosya kapatma, manifest üretimi ve bütünlük kontrolleri tamamlanmalıdır.)*

---

# 305. Crash Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Crash Kararları)

Interrupted sessions will be detected on the next application launch. *(Kesintiye uğramış oturumlar sonraki uygulama başlatmada tespit edilecektir.)*

They will not be silently promoted to completed sessions. *(Sessizce tamamlanmış oturumlara yükseltilmeyecektir.)*

---

# 306. Ground Truth Storage Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Ground Truth Depolama Kararları)

Evaluation GNSS ground truth will be stored independently from estimator outputs. *(Evaluation GNSS ground truth tahmin motoru çıktılarından bağımsız saklanacaktır.)*

Ground-truth presence in storage does not grant estimator access. *(Ground-truth'un depolamada bulunması tahmin motoru erişimi vermez.)*

---

# 307. Replay Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Replay Kararları)

Replay will consume frozen session evidence without modifying original live artifacts. *(Replay sabitlenmiş oturum kanıtını orijinal canlı artifact'ları değiştirmeden kullanacaktır.)*

Replay-generated outputs will have separate provenance. *(Replay tarafından üretilen çıktılar ayrı köken bilgisine sahip olacaktır.)*

---

# 308. Schema Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Schema Kararları)

All formal structured artifacts will be explicitly schema-versioned. *(Tüm resmî yapılandırılmış artifact'lar açık şekilde schema sürümlü olacaktır.)*

---

# 309. Export Decisions Frozen by This Document (Bu Dokümanla Sabitlenen Export Kararları)

Session export will create a portable package containing manifest, configuration, evidence, and selected derived outputs. *(Oturum export'u manifest, yapılandırma, kanıt ve seçilen türetilmiş çıktıları içeren taşınabilir paket oluşturacaktır.)*

Export will not delete or alter the original session. *(Export orijinal oturumu silmeyecek veya değiştirmeyecektir.)*

---

# 310. Decisions Pending Device Storage Tests (Cihaz Depolama Testlerini Bekleyen Kararlar)

The final writer-buffer size remains pending Redmi Note 9 Pro profiling. *(Nihai writer buffer boyutu Redmi Note 9 Pro profiling'ini beklemektedir.)*

The final writer-queue capacity remains pending profiling. *(Nihai writer queue kapasitesi profiling'i beklemektedir.)*

The final flush interval remains pending storage tests. *(Nihai flush aralığı depolama testlerini beklemektedir.)*

---

# 311. Decisions Pending Session Size Measurements (Oturum Boyutu Ölçümlerini Bekleyen Kararlar)

The final free-space warning threshold remains pending measured bytes per minute. *(Nihai boş alan uyarı eşiği ölçülmüş dakika başına byte miktarını beklemektedir.)*

---

# 312. Decisions Pending Android Implementation (Android Uygulamasını Bekleyen Kararlar)

The exact SQLite Flutter/Android library remains pending environment bootstrap. *(Kesin SQLite Flutter/Android kütüphanesi ortam bootstrap sürecini beklemektedir.)*

The exact app-private and user-export directory strategy remains pending Android permission and storage implementation. *(Kesin uygulama-private ve kullanıcı-export klasör stratejisi Android permission ve depolama uygulamasını beklemektedir.)*

---

# 313. Decisions Pending Performance Evidence (Performans Kanıtını Bekleyen Kararlar)

CSV will remain the initial high-frequency research format unless measured evidence shows a need for a more efficient representation. *(Ölçülmüş kanıt daha verimli temsil ihtiyacı göstermedikçe CSV ilk yüksek frekanslı araştırma formatı olarak kalacaktır.)*

---

# 314. Final Data Storage, Logging & Session Management Architecture Statement (Nihai Veri Depolama, Logging ve Oturum Yönetimi Mimarisi Bildirimi)

**NAVGUARD will use a hybrid offline-first storage architecture in which SQLite acts as the structured session and artifact index while high-frequency sensor, GNSS, ARCore, AI, PDR, fusion, and uncertainty evidence is persisted through append-oriented per-session files.** *(NAVGUARD SQLite'ın yapılandırılmış oturum ve artifact index'i olarak görev yaptığı, yüksek frekanslı sensör, GNSS, ARCore, yapay zekâ, PDR, füzyon ve belirsizlik kanıtının ise oturum başına append odaklı dosyalar üzerinden persist edildiği hibrit çevrimdışı öncelikli depolama mimarisi kullanacaktır.)*

**Every formal recording will receive an immutable session identity, a dedicated directory, a frozen configuration snapshot, explicit lifecycle state, a portable machine-readable manifest, and traceable artifact records so that the complete experiment can be interpreted independently of temporary application memory.** *(Her resmî kayıt değişmez oturum kimliği, özel klasör, sabitlenmiş yapılandırma snapshot'ı, açık yaşam döngüsü durumu, taşınabilir machine-readable manifest ve izlenebilir artifact kayıtları alacak; böylece tam deney geçici uygulama belleğinden bağımsız olarak yorumlanabilecektir.)*

**Raw asynchronous sensor streams will remain separate and immutable, while synchronization, filtering, step detection, heading estimation, AI inference, PDR, EKF fusion, uncertainty, GNSS recovery, and other downstream outputs will be stored as clearly versioned derived artifacts rather than written back into raw evidence.** *(Ham asynchronous sensör akışları ayrı ve değişmez kalırken senkronizasyon, filtreleme, adım tespiti, yön tahmini, yapay zekâ çıkarımı, PDR, EKF füzyonu, belirsizlik, GNSS recovery ve diğer downstream çıktılar ham kanıtın üzerine yazılmak yerine açık şekilde sürümlenmiş türetilmiş artifact'lar olarak saklanacaktır.)*

**High-frequency logging will use bounded asynchronous writer queues so sensor callbacks and navigation processing do not block on disk operations, and any dropped mandatory evidence, queue overflow, writer failure, or storage backpressure will remain explicitly observable rather than being hidden.** *(Yüksek frekanslı logging sınırlı asynchronous writer kuyrukları kullanacak; böylece sensör callback'leri ve navigasyon işleme disk işlemleri üzerinde block olmayacak ve düşürülen zorunlu kanıt, kuyruk overflow, writer hatası veya depolama backpressure'ı gizlenmek yerine açık şekilde gözlemlenebilir kalacaktır.)*

**A session will not become `COMPLETED` when recording merely stops; NAVGUARD will first stop producers, drain mandatory queues, flush and close writers, generate summaries, run integrity checks, finalize the manifest, and only then commit the completed lifecycle state.** *(Oturum yalnızca kayıt durduğunda `COMPLETED` olmayacak; NAVGUARD önce producer'ları durduracak, zorunlu kuyrukları drain edecek, writer'ları flush edip kapatacak, özetleri üretecek, bütünlük kontrollerini çalıştıracak, manifest'i finalize edecek ve yalnızca bundan sonra tamamlanmış yaşam döngüsü durumunu commit edecektir.)*

**Unexpected application termination will leave recoverable session evidence and explicit incomplete-session markers so the next launch can identify interrupted recordings without silently fabricating missing records or falsely promoting them to completed experiments.** *(Beklenmedik uygulama termination kurtarılabilir oturum kanıtı ve açık tamamlanmamış oturum marker'ları bırakacak; böylece sonraki başlatma eksik kayıtları sessizce uydurmadan veya onları yanlış şekilde tamamlanmış deneylere yükseltmeden kesintiye uğramış kayıtları tanımlayabilecektir.)*

**Evaluation Mode GNSS ground truth will remain stored as an independent reference artifact, physically available for later comparison but logically excluded from denied-estimator input by the Ground Truth Firewall and replay authorization rules.** *(Evaluation Mode GNSS ground truth bağımsız referans artifact'ı olarak saklanmaya devam edecek, daha sonraki karşılaştırma için fiziksel olarak mevcut ancak Ground Truth Firewall ve replay authorization kuralları tarafından kesintili tahmin motoru girdisinden mantıksal olarak hariç tutulacaktır.)*

**Exports and replay runs will preserve configuration, schema, timing, provenance, hashes, and artifact identities so alternative algorithms can be evaluated later without changing the original live-session evidence or losing the ability to reproduce the exact experiment that produced the original result.** *(Export ve replay run'ları yapılandırmayı, schema'yı, zamanlamayı, köken bilgisini, hash'leri ve artifact kimliklerini koruyacak; böylece alternatif algoritmalar orijinal canlı oturum kanıtını değiştirmeden veya orijinal sonucu üreten kesin deneyi yeniden üretme yeteneğini kaybetmeden daha sonra değerlendirilebilecektir.)*

---

# 315. Current Document Status (Mevcut Doküman Durumu)

**Document Status:** Pre-Development Data Storage, Logging & Session Management Architecture Completed *(Doküman Durumu: Geliştirme Öncesi Veri Depolama, Logging ve Oturum Yönetimi Mimarisi Tamamlandı)*

**Storage Philosophy:** Offline-First + Hybrid *(Depolama Felsefesi: Çevrimdışı Öncelikli + Hibrit)*

**Structured Metadata Store:** SQLite *(Yapılandırılmış Metadata Deposu: SQLite)*

**High-Frequency Evidence Store:** Append-Oriented Files *(Yüksek Frekanslı Kanıt Deposu: Append Odaklı Dosyalar)*

**Initial High-Frequency Research Format:** CSV *(İlk Yüksek Frekanslı Araştırma Formatı: CSV)*

**Raw Evidence Policy:** Immutable *(Ham Kanıt Politikası: Değişmez)*

**Raw Sensor Stream Layout:** Separate Per Source *(Ham Sensör Akış Düzeni: Kaynak Başına Ayrı)*

**Artificial Sensor Synchronization in Raw Files:** Forbidden *(Ham Dosyalarda Yapay Sensör Senkronizasyonu: Yasak)*

**Processed Outputs:** Separate + Versioned *(İşlenmiş Çıktılar: Ayrı + Sürümlenmiş)*

**Session Identifier:** Unique + Immutable *(Oturum Tanımlayıcısı: Benzersiz + Değişmez)*

**Session Manifest:** Mandatory *(Oturum Manifest'i: Zorunlu)*

**Configuration Snapshot:** Mandatory *(Yapılandırma Snapshot'ı: Zorunlu)*

**Schema Versioning:** Mandatory *(Schema Sürümleme: Zorunlu)*

**Session States:** Explicit *(Oturum Durumları: Açık)*

**Completed / Incomplete / Invalid Separation:** Mandatory *(Completed / Incomplete / Invalid Ayrımı: Zorunlu)*

**High-Frequency Writer:** Asynchronous / Dedicated *(Yüksek Frekanslı Writer: Asynchronous / Özel)*

**Writer Queue:** Bounded *(Writer Kuyruğu: Sınırlı)*

**Silent Dropped Records:** Forbidden *(Sessiz Düşürülen Kayıtlar: Yasak)*

**Drop Counters:** Mandatory *(Drop Counter'ları: Zorunlu)*

**Critical Logging Failure Visibility:** Mandatory *(Kritik Logging Hatası Görünürlüğü: Zorunlu)*

**Stop Button Means Immediate COMPLETED:** Forbidden *(Stop Butonu Anında COMPLETED Anlamına Gelir: Yasak)*

**Controlled Finalization:** Mandatory *(Kontrollü Finalization: Zorunlu)*

**Crash / Incomplete Session Detection:** Mandatory *(Crash / Tamamlanmamış Oturum Tespiti: Zorunlu)*

**Automatic Deletion of Failed Formal Sessions:** Forbidden *(Başarısız Resmî Oturumları Otomatik Silme: Yasak)*

**Ground Truth GNSS Storage:** Independent Reference Artifact *(Ground Truth GNSS Depolama: Bağımsız Referans Artifact'ı)*

**Ground Truth Presence Grants Estimator Access:** False *(Ground Truth Varlığı Tahmin Motoru Erişimi Verir: Yanlış)*

**Recovery Pre-Correction Evidence Persistence:** Mandatory in Benchmark Mode *(Recovery Düzeltme Öncesi Kanıt Persist Etme: Benchmark Modunda Zorunlu)*

**Replay Modifies Raw Evidence:** Forbidden *(Replay Ham Kanıtı Değiştirir: Yasak)*

**Replay Output Provenance:** Separate *(Replay Çıktı Kökeni: Ayrı)*

**Export Package:** Supported *(Export Paketi: Destekleniyor)*

**Export Alters Original Session:** Forbidden *(Export Orijinal Oturumu Değiştirir: Yasak)*

**Integrity Checks:** Mandatory for Formal Completion *(Bütünlük Kontrolleri: Resmî Tamamlama İçin Zorunlu)*

**Optional File Hashing:** Target Design *(İsteğe Bağlı Dosya Hash'leme: Hedef Tasarım)*

**Final SQLite Library:** Pending Environment Bootstrap *(Nihai SQLite Kütüphanesi: Ortam Bootstrap Bekleniyor)*

**Final Writer Queue Capacity:** Pending Redmi Note 9 Pro Profiling *(Nihai Writer Queue Kapasitesi: Redmi Note 9 Pro Profiling Bekleniyor)*

**Final Flush Interval:** Pending Storage Benchmark *(Nihai Flush Aralığı: Depolama Benchmark'ı Bekleniyor)*

**Final Free-Space Warning Threshold:** Pending Measured Session Byte Rate *(Nihai Boş Alan Uyarı Eşiği: Ölçülmüş Oturum Byte Hızı Bekleniyor)*

**Final Active Storage Directory Strategy:** Pending Android Storage / Permission Implementation *(Nihai Aktif Depolama Klasör Stratejisi: Android Depolama / Permission Uygulaması Bekleniyor)*

**Binary / Columnar Storage Migration:** Only if CSV Becomes a Measured Bottleneck *(Binary / Columnar Depolamaya Geçiş: Yalnızca CSV Ölçülmüş Bottleneck Haline Gelirse)*

**Next Documentation Item:** 31 — Mobile UI/UX Specification *(Sonraki Dokümantasyon Öğesi: 31 — Mobil UI/UX Spesifikasyonu)*
