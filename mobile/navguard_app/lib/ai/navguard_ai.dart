import 'package:flutter/services.dart';

const String navguardAiChannelName =
    'io.github.mesuttsahin.navguard/navguard_ai';
const String navguardAiDatasetSchemaV1 = 'navguard_ai_dataset_v1';
const String navguardAiDatasetSchemaV2 = 'navguard_ai_dataset_v2';
const String navguardAiDatasetSchemaV3 = 'navguard_ai_dataset_v3';
const String navguardAiDatasetSchema = navguardAiDatasetSchemaV3;
const String navguardAiFeatureSchemaV1 = 'navguard_ai_features_v1';
const String navguardAiFeatureSchemaV2 = 'navguard_ai_features_v2';
const String navguardAiFeatureSchemaV3 = 'navguard_ai_features_v3';
const String navguardAiFeatureSchema = navguardAiFeatureSchemaV3;
const String navguardAiConfigEId = 'config_e_ai_assisted_navguard_v1';
const int navguardAiFeatureWindowMs = 2000;
const int navguardAiFeatureHopMs = 1000;

const List<String> navguardAiFeatureOrderV1 = <String>[
  'accel_mag_mean',
  'accel_mag_std',
  'accel_mag_rms',
  'gyro_mag_mean',
  'gyro_mag_std',
  'gyro_mag_rms',
  'heading_circular_std_rad',
  'heading_rate_abs_mean_rad_s',
  'heading_rate_abs_max_rad_s',
  'step_count',
  'step_cadence_hz',
  'step_interval_std_s',
  'arcore_displacement_m',
  'arcore_speed_mean_mps',
  'arcore_speed_std_mps',
  'arcore_tracking_fraction',
  'arcore_frame_gap_mean_ms',
  'arcore_pre_robust_nis_mean',
  'arcore_post_robust_nis_mean',
  'source_disagreement_mean_m',
  'source_disagreement_max_m',
  'stride_estimate_m',
  'stationary_candidate_fraction',
  'turning_heuristic_fraction',
  'arcore_robust_sigma_mean_m',
  'heading_unreliable_fraction',
];

const List<String> navguardAiFeatureOrderV2 = <String>[
  ...navguardAiFeatureOrderV1,
  'heading_net_change_abs_rad',
  'heading_turn_consistency',
  'sustained_turn_fraction',
  'arcore_path_length_m',
  'arcore_straightness_ratio',
  'arcore_net_turn_abs_rad',
  'arcore_turn_consistency',
  'arcore_curvature_abs_rad_per_m',
];

const List<String> navguardAiFeatureOrderV3 = <String>[
  ...navguardAiFeatureOrderV2,
  'heading_signed_net_turn_rad',
  'arcore_signed_net_turn_rad',
  'heading_path_turn_direction_agreement',
  'heading_path_turn_magnitude_difference_ratio',
  'heading_path_turn_coherence',
  'arcore_cross_track_rms_m',
];

const List<String> navguardAiFeatureOrder = navguardAiFeatureOrderV3;

enum NavguardAiMotionLabel {
  stationary(
    'STATIONARY',
    'Stationary',
    'Keep the phone in normal demo orientation and remain still.',
  ),
  straightWalk(
    'STRAIGHT_WALK',
    'Straight walk',
    'Walk normally in a straight line while keeping the phone in normal demo orientation.',
  ),
  turning(
    'TURNING',
    'Turning',
    'Walk continuously while making repeated controlled turns. Avoid standing and rotating only in place for the entire session.',
  ),
  unstableMotion(
    'UNSTABLE_MOTION',
    'Unstable motion',
    'Walk normally while introducing realistic handheld orientation changes. Do not shake the phone violently.',
  );

  const NavguardAiMotionLabel(
    this.platformName,
    this.displayName,
    this.instruction,
  );

  final String platformName;
  final String displayName;
  final String instruction;
}

enum NavguardAiModelStatus {
  modelNotAvailable,
  modelInvalid,
  modelReady,
  warmingUp,
  aiActive,
  heuristicFallback,
  unknown;

  static NavguardAiModelStatus parse(Object? raw) => switch (raw?.toString()) {
    'MODEL_NOT_AVAILABLE' => NavguardAiModelStatus.modelNotAvailable,
    'MODEL_INVALID' => NavguardAiModelStatus.modelInvalid,
    'MODEL_READY' => NavguardAiModelStatus.modelReady,
    'WARMING_UP' => NavguardAiModelStatus.warmingUp,
    'AI_ACTIVE' => NavguardAiModelStatus.aiActive,
    'HEURISTIC_FALLBACK' => NavguardAiModelStatus.heuristicFallback,
    _ => NavguardAiModelStatus.unknown,
  };

  String get label => switch (this) {
    NavguardAiModelStatus.modelNotAvailable => 'MODEL_NOT_AVAILABLE',
    NavguardAiModelStatus.modelInvalid => 'MODEL_INVALID',
    NavguardAiModelStatus.modelReady => 'MODEL_READY',
    NavguardAiModelStatus.warmingUp => 'WARMING_UP',
    NavguardAiModelStatus.aiActive => 'AI_ACTIVE',
    NavguardAiModelStatus.heuristicFallback => 'HEURISTIC_FALLBACK',
    NavguardAiModelStatus.unknown => 'UNKNOWN',
  };
}

Map<String, Object?> navguardAiAnchorArguments({
  required double? latitudeDeg,
  required double? longitudeDeg,
  required double? altitudeEllipsoidM,
}) => <String, Object?>{
  'anchorAvailable': latitudeDeg != null && longitudeDeg != null,
  'latitudeDeg': latitudeDeg,
  'longitudeDeg': longitudeDeg,
  'altitudeEllipsoidM': altitudeEllipsoidM,
};

Map<String, Object?> _asStringMap(Object? value) {
  final Map<Object?, Object?> raw = value as Map<Object?, Object?>? ?? const {};
  return raw.map(
    (Object? key, Object? value) => MapEntry(key.toString(), value),
  );
}

class NavguardAiSelfTestFailureDetail {
  const NavguardAiSelfTestFailureDetail({
    required this.test,
    required this.expected,
    required this.actual,
    required this.reason,
  });

  factory NavguardAiSelfTestFailureDetail.fromMap(Map<Object?, Object?> raw) =>
      NavguardAiSelfTestFailureDetail(
        test: raw['test']?.toString() ?? 'unknown',
        expected: raw['expected']?.toString() ?? 'true',
        actual: raw['actual']?.toString() ?? 'false',
        reason: raw['reason']?.toString() ?? 'SELF_TEST_ASSERTION_FAILED',
      );

  final String test;
  final String expected;
  final String actual;
  final String reason;
}

class NavguardAiCapturePreflight {
  const NavguardAiCapturePreflight._({
    required this.accelerometerAvailable,
    required this.gyroscopeAvailable,
    required this.rotationVectorAvailable,
    required this.stepDetectorAvailable,
    required this.arCoreSupported,
    required this.arCoreInstalled,
    required this.cameraPermissionGranted,
    required this.activityRecognitionPermissionGranted,
    required this.fineLocationPermissionGranted,
    required this.gpsProviderAvailable,
    required this.gpsProviderEnabled,
    required this.anchorAvailable,
    required this.operationAvailable,
    required this.selfTestsPassed,
    required this.nativeSelfTests,
    required this.failedNativeSelfTests,
    required this.nativeSelfTestFailures,
    required this.captureReady,
    required this.blockingReasons,
  });

  factory NavguardAiCapturePreflight.fromMap(Map<String, Object?> raw) {
    bool flag(String key) => raw[key] == true;

    final bool accelerometerAvailable = flag('accelerometerAvailable');
    final bool gyroscopeAvailable = flag('gyroscopeAvailable');
    final bool rotationVectorAvailable = flag('rotationVectorAvailable');
    final bool stepDetectorAvailable = flag('stepDetectorAvailable');
    final bool arCoreSupported = flag('arCoreSupported');
    final bool arCoreInstalled = flag('arCoreInstalled');
    final bool cameraPermissionGranted = flag('cameraPermissionGranted');
    final bool activityRecognitionPermissionGranted = flag(
      'activityRecognitionPermissionGranted',
    );
    final bool fineLocationPermissionGranted = flag(
      'fineLocationPermissionGranted',
    );
    final bool gpsProviderAvailable = flag('gpsProviderAvailable');
    final bool gpsProviderEnabled = flag('gpsProviderEnabled');
    final bool anchorAvailable = flag('anchorAvailable');
    final bool operationAvailable = raw.containsKey('operationAvailable')
        ? flag('operationAvailable')
        : raw['operationBusy'] != true;
    final bool selfTestsPassed = raw.containsKey('nativeSelfTestsPassed')
        ? flag('nativeSelfTestsPassed')
        : flag('selfTestsPassed');
    final Map<String, bool> nativeSelfTests = switch (raw['nativeSelfTests'] ??
        raw['selfTests']) {
      final Map<Object?, Object?> values => values.map(
        (Object? key, Object? value) => MapEntry(key.toString(), value == true),
      ),
      _ => const <String, bool>{},
    };
    final List<String> reportedFailedNativeSelfTests =
        switch (raw['failedNativeSelfTests']) {
          final List<Object?> values =>
            values
                .whereType<Object>()
                .map((Object value) => value.toString())
                .toList(growable: false),
          _ => const <String>[],
        };
    final List<String> failedNativeSelfTests =
        reportedFailedNativeSelfTests.isNotEmpty
        ? reportedFailedNativeSelfTests
        : nativeSelfTests.entries
              .where((MapEntry<String, bool> entry) => !entry.value)
              .map((MapEntry<String, bool> entry) => entry.key)
              .toList(growable: false);
    final List<NavguardAiSelfTestFailureDetail> nativeSelfTestFailures =
        switch (raw['nativeSelfTestFailures']) {
          final List<Object?> values =>
            values
                .whereType<Map<Object?, Object?>>()
                .map(NavguardAiSelfTestFailureDetail.fromMap)
                .toList(growable: false),
          _ => const <NavguardAiSelfTestFailureDetail>[],
        };
    final Object? reportedReady = raw['captureReady'] ?? raw['nativeReady'];
    final bool everyRequiredGateReady =
        accelerometerAvailable &&
        gyroscopeAvailable &&
        rotationVectorAvailable &&
        stepDetectorAvailable &&
        arCoreSupported &&
        arCoreInstalled &&
        cameraPermissionGranted &&
        activityRecognitionPermissionGranted &&
        fineLocationPermissionGranted &&
        gpsProviderAvailable &&
        gpsProviderEnabled &&
        anchorAvailable &&
        operationAvailable &&
        selfTestsPassed;
    final List<String> derivedReasons = <String>[
      if (!accelerometerAvailable) 'ACCELEROMETER_UNAVAILABLE',
      if (!gyroscopeAvailable) 'GYROSCOPE_UNAVAILABLE',
      if (!rotationVectorAvailable) 'ROTATION_VECTOR_UNAVAILABLE',
      if (!stepDetectorAvailable) 'STEP_DETECTOR_UNAVAILABLE',
      if (!arCoreSupported) 'ARCORE_UNSUPPORTED',
      if (arCoreSupported && !arCoreInstalled) 'ARCORE_NOT_INSTALLED',
      if (!cameraPermissionGranted) 'CAMERA_PERMISSION_MISSING',
      if (!activityRecognitionPermissionGranted)
        'ACTIVITY_RECOGNITION_PERMISSION_MISSING',
      if (!fineLocationPermissionGranted) 'FINE_LOCATION_PERMISSION_MISSING',
      if (!gpsProviderAvailable) 'GPS_PROVIDER_UNAVAILABLE',
      if (gpsProviderAvailable && !gpsProviderEnabled) 'GPS_PROVIDER_DISABLED',
      if (!anchorAvailable) 'ANCHOR_UNAVAILABLE',
      if (!operationAvailable) 'OPERATION_BUSY',
      if (!selfTestsPassed) 'NATIVE_SELF_TEST_FAILED',
    ];
    final List<String> nativeReasons = switch (raw['blockingReasons']) {
      final List<Object?> values =>
        values
            .whereType<Object>()
            .map((Object value) => value.toString())
            .toList(growable: false),
      _ => const <String>[],
    };
    return NavguardAiCapturePreflight._(
      accelerometerAvailable: accelerometerAvailable,
      gyroscopeAvailable: gyroscopeAvailable,
      rotationVectorAvailable: rotationVectorAvailable,
      stepDetectorAvailable: stepDetectorAvailable,
      arCoreSupported: arCoreSupported,
      arCoreInstalled: arCoreInstalled,
      cameraPermissionGranted: cameraPermissionGranted,
      activityRecognitionPermissionGranted:
          activityRecognitionPermissionGranted,
      fineLocationPermissionGranted: fineLocationPermissionGranted,
      gpsProviderAvailable: gpsProviderAvailable,
      gpsProviderEnabled: gpsProviderEnabled,
      anchorAvailable: anchorAvailable,
      operationAvailable: operationAvailable,
      selfTestsPassed: selfTestsPassed,
      nativeSelfTests: nativeSelfTests,
      failedNativeSelfTests: failedNativeSelfTests,
      nativeSelfTestFailures: nativeSelfTestFailures,
      captureReady: reportedReady == true && everyRequiredGateReady,
      blockingReasons: nativeReasons.isNotEmpty
          ? nativeReasons
          : derivedReasons,
    );
  }

  final bool accelerometerAvailable;
  final bool gyroscopeAvailable;
  final bool rotationVectorAvailable;
  final bool stepDetectorAvailable;
  final bool arCoreSupported;
  final bool arCoreInstalled;
  final bool cameraPermissionGranted;
  final bool activityRecognitionPermissionGranted;
  final bool fineLocationPermissionGranted;
  final bool gpsProviderAvailable;
  final bool gpsProviderEnabled;
  final bool anchorAvailable;
  final bool operationAvailable;
  final bool selfTestsPassed;
  final Map<String, bool> nativeSelfTests;
  final List<String> failedNativeSelfTests;
  final List<NavguardAiSelfTestFailureDetail> nativeSelfTestFailures;
  final bool captureReady;
  final List<String> blockingReasons;

  bool get arCoreReady => arCoreSupported && arCoreInstalled;
  bool get gpsProviderReady => gpsProviderAvailable && gpsProviderEnabled;
  bool get permissionsReady =>
      cameraPermissionGranted &&
      activityRecognitionPermissionGranted &&
      fineLocationPermissionGranted;
}

abstract interface class NavguardAiPlatform {
  Future<Map<String, Object?>> getPreflight(Map<String, Object?> anchor);
  Future<Map<String, Object?>> requestCapturePermissions();
  Future<Map<String, Object?>> getDatasetSummary();
  Future<Map<String, Object?>> getCaptureStatus();
  Future<Map<String, Object?>> getModelStatus();
  Future<Map<String, Object?>> startCapture(Map<String, Object?> arguments);
  Future<Map<String, Object?>> cancelCapture();
  Future<Map<String, Object?>> clearDataset();
  Future<Map<String, Object?>> runDevelopmentBenchmark();
}

class MethodChannelNavguardAiPlatform implements NavguardAiPlatform {
  const MethodChannelNavguardAiPlatform();

  static const MethodChannel _channel = MethodChannel(navguardAiChannelName);

  Future<Map<String, Object?>> _invoke(
    String method, [
    Map<String, Object?>? arguments,
  ]) async =>
      _asStringMap(await _channel.invokeMethod<Object?>(method, arguments));

  @override
  Future<Map<String, Object?>> getPreflight(Map<String, Object?> anchor) =>
      _invoke('getAiPreflight', anchor);

  @override
  Future<Map<String, Object?>> requestCapturePermissions() =>
      _invoke('requestAiCapturePermissions');

  @override
  Future<Map<String, Object?>> getDatasetSummary() =>
      _invoke('getAiDatasetSummary');

  @override
  Future<Map<String, Object?>> getCaptureStatus() =>
      _invoke('getAiCaptureStatus');

  @override
  Future<Map<String, Object?>> getModelStatus() => _invoke('getAiModelStatus');

  @override
  Future<Map<String, Object?>> startCapture(Map<String, Object?> arguments) =>
      _invoke('startAiDatasetCapture', arguments);

  @override
  Future<Map<String, Object?>> cancelCapture() =>
      _invoke('cancelAiDatasetCapture');

  @override
  Future<Map<String, Object?>> clearDataset() => _invoke('clearAiDataset');

  @override
  Future<Map<String, Object?>> runDevelopmentBenchmark() =>
      _invoke('runAiDevelopmentBenchmark');
}

double navguardAiReliabilityMultiplier(double? reliability) {
  if (reliability == null || !reliability.isFinite) return 1.0;
  final double bounded = reliability.clamp(0.0, 1.0);
  final double complement = 1.0 - bounded;
  return (1.0 + 1.5 * complement * complement).clamp(1.0, 2.5);
}

bool navguardAiDatasetColumnsArePrivate(Iterable<String> columns) {
  const List<String> forbidden = <String>[
    'latitude',
    'longitude',
    'altitude',
    'raw_gnss',
    'raw_accel',
    'raw_gyro',
    'magnetometer',
    'arcore_pose',
    'quaternion',
    'trajectory',
    'timestamp',
    'camera',
    'image',
    'audio',
    'device_serial',
    'mac',
    'advertising',
    'account',
    'user_name',
  ];
  return columns.every(
    (String column) =>
        !forbidden.any((String value) => column.toLowerCase().contains(value)),
  );
}
