import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ai/navguard_ai.dart';
import 'ai/navguard_ai_dataset_screen.dart';
import 'demo/live_navguard_demo.dart';
import 'demo/live_navguard_map_screen.dart';
import 'diagnostics/diagnostics_access_policy.dart';
import 'navigation/arcore_enu.dart';
import 'navigation/baseline_pdr.dart';
import 'navigation/evaluation_mode.dart';
import 'navigation/full_navguard_flow.dart';
import 'navigation/gnss_anchor.dart';
import 'navigation/heading.dart';
import 'navigation/navguard_fusion.dart';
import 'navigation/navguard_benchmark.dart';
import 'navigation/navguard_accuracy_v2.dart';
import 'navigation/step_event.dart';

void main() {
  runApp(const NavguardApp());
}

enum _DiagnosticOperation {
  inventory,
  sensorTiming,
  gnssPreflight,
  gnssPermission,
  gnssTiming,
  gnssAnchorPreflight,
  gnssAnchorAcquisition,
  headingPreflight,
  headingDiagnostic,
  stepPreflight,
  stepPermission,
  stepDiagnostic,
  baselinePdrPreflight,
  baselinePdrDiagnostic,
  arCorePreflight,
  arCorePermission,
  arCoreTracking,
  arCoreEnuPreflight,
  arCoreEnuDiagnostic,
  evaluationModePreflight,
  evaluationModeDiagnostic,
  navguardFusionPreflight,
  navguardFusionDiagnostic,
  fullNavguardFlowPreflight,
  fullNavguardFlowDiagnostic,
  navguardBenchmarkPreflight,
  navguardBenchmarkDiagnostic,
  accuracyV2Preflight,
  accuracyV2Calibration,
  accuracyV2DevelopmentBenchmark,
  accuracyV2Reset,
}

enum _DashboardModule {
  sensors,
  gnssAnchor,
  headingPdr,
  arCoreEnu,
  fusionEkf,
  denialRecovery,
  evaluationGtf,
  benchmarks,
  accuracyV2,
}

extension on _DashboardModule {
  String get title => switch (this) {
    _DashboardModule.sensors => 'Sensors',
    _DashboardModule.gnssAnchor => 'GNSS & Anchor',
    _DashboardModule.headingPdr => 'Heading & PDR',
    _DashboardModule.arCoreEnu => 'ARCore & ENU',
    _DashboardModule.fusionEkf => 'Fusion & EKF',
    _DashboardModule.denialRecovery => 'Denial & Recovery',
    _DashboardModule.evaluationGtf => 'Evaluation & GTF',
    _DashboardModule.benchmarks => 'Benchmarks',
    _DashboardModule.accuracyV2 => 'Accuracy v2',
  };

  String get description => switch (this) {
    _DashboardModule.sensors => 'Capability inventory and live timing',
    _DashboardModule.gnssAnchor => 'GNSS timing and local reference',
    _DashboardModule.headingPdr => 'True north, steps, and baseline PDR',
    _DashboardModule.arCoreEnu => 'Visual tracking and ENU motion',
    _DashboardModule.fusionEkf => 'Quality engine and sensor fusion',
    _DashboardModule.denialRecovery => 'Full GNSS-denied navigation flow',
    _DashboardModule.evaluationGtf => 'Protected ground-truth evaluation',
    _DashboardModule.benchmarks => 'Matched Config A/B/C/D evaluation',
    _DashboardModule.accuracyV2 => 'Adaptive calibration research mode',
  };

  IconData get icon => switch (this) {
    _DashboardModule.sensors => Icons.sensors_outlined,
    _DashboardModule.gnssAnchor => Icons.gps_fixed,
    _DashboardModule.headingPdr => Icons.explore_outlined,
    _DashboardModule.arCoreEnu => Icons.view_in_ar_outlined,
    _DashboardModule.fusionEkf => Icons.hub_outlined,
    _DashboardModule.denialRecovery => Icons.portable_wifi_off_outlined,
    _DashboardModule.evaluationGtf => Icons.shield_outlined,
    _DashboardModule.benchmarks => Icons.analytics_outlined,
    _DashboardModule.accuracyV2 => Icons.tune_outlined,
  };
}

enum _ReadinessKind { neutral, ready, attention, unavailable, error, busy }

class _ReadinessStatus {
  const _ReadinessStatus(this.label, this.kind);

  final String label;
  final _ReadinessKind kind;
}

class _SensorOption {
  const _SensorOption({required this.key, required this.label});

  final String key;
  final String label;
}

class _GnssDisplayState {
  const _GnssDisplayState({
    required this.precisePermission,
    required this.gpsProvider,
    required this.locationServices,
    required this.canRunFormalDiagnostic,
  });

  factory _GnssDisplayState.fromSnapshot(Map<Object?, Object?> snapshot) {
    final bool preciseGranted = snapshot['preciseLocationGranted'] == true;
    final bool coarseGranted = snapshot['coarseLocationGranted'] == true;
    final bool providerAvailable = snapshot['gpsProviderAvailable'] == true;
    final bool providerEnabled = snapshot['gpsProviderEnabled'] == true;
    final Object? servicesEnabled = snapshot['locationServicesEnabled'];

    final String precisePermission = preciseGranted
        ? 'Granted'
        : coarseGranted
        ? 'Approximate only'
        : 'Not granted';
    final String gpsProvider = !providerAvailable
        ? 'Unavailable'
        : providerEnabled
        ? 'Enabled'
        : 'Disabled';
    final String locationServices = servicesEnabled == null
        ? 'Unknown (API 24–27)'
        : servicesEnabled == true
        ? 'Enabled'
        : 'Disabled';

    return _GnssDisplayState(
      precisePermission: precisePermission,
      gpsProvider: gpsProvider,
      locationServices: locationServices,
      canRunFormalDiagnostic: snapshot['canRunFormalDiagnostic'] == true,
    );
  }

  final String precisePermission;
  final String gpsProvider;
  final String locationServices;
  final bool canRunFormalDiagnostic;
}

class _ArCoreDisplayState {
  const _ArCoreDisplayState({
    required this.cameraPermission,
    required this.availability,
    required this.ready,
    required this.canRunFormalDiagnostic,
  });

  factory _ArCoreDisplayState.fromSnapshot(Map<Object?, Object?> snapshot) {
    final bool cameraPermissionGranted =
        snapshot['cameraPermissionGranted'] == true;
    final String availability =
        snapshot['availabilityRaw']?.toString() ?? 'Unknown';
    final Object? installedAndCurrent = snapshot['arCoreInstalledAndCurrent'];

    final String ready = installedAndCurrent == true
        ? 'Yes'
        : installedAndCurrent == false
        ? 'No'
        : 'Unknown';

    return _ArCoreDisplayState(
      cameraPermission: cameraPermissionGranted ? 'Granted' : 'Not granted',
      availability: availability,
      ready: ready,
      canRunFormalDiagnostic: snapshot['canRunFormalDiagnostic'] == true,
    );
  }

  final String cameraPermission;
  final String availability;
  final String ready;
  final bool canRunFormalDiagnostic;
}

const List<_SensorOption> _sensorOptions = <_SensorOption>[
  _SensorOption(key: 'accelerometer', label: 'Accelerometer'),
  _SensorOption(key: 'gyroscope', label: 'Gyroscope'),
  _SensorOption(key: 'magnetometer', label: 'Magnetometer'),
  _SensorOption(key: 'rotation_vector', label: 'Rotation Vector'),
];

class NavguardApp extends StatelessWidget {
  const NavguardApp({
    this.liveDemoPlatform = const MethodChannelLiveNavguardPlatform(),
    this.aiPlatform = const MethodChannelNavguardAiPlatform(),
    this.enableLiveMapTiles = true,
    this.diagnosticsAccessOverride,
    super.key,
  });

  final LiveNavguardPlatform liveDemoPlatform;
  final NavguardAiPlatform aiPlatform;
  final bool enableLiveMapTiles;
  final bool? diagnosticsAccessOverride;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NAVGUARD Runtime Diagnostics',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF155E95),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        cardTheme: CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFFE1E7EF)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(48, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(48, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        useMaterial3: true,
      ),
      home: SensorDiagnosticsPage(
        liveDemoPlatform: liveDemoPlatform,
        aiPlatform: aiPlatform,
        enableLiveMapTiles: enableLiveMapTiles,
        diagnosticsAccessOverride: diagnosticsAccessOverride,
      ),
    );
  }
}

class SensorDiagnosticsPage extends StatefulWidget {
  const SensorDiagnosticsPage({
    this.liveDemoPlatform = const MethodChannelLiveNavguardPlatform(),
    this.aiPlatform = const MethodChannelNavguardAiPlatform(),
    this.enableLiveMapTiles = true,
    this.diagnosticsAccessOverride,
    super.key,
  });

  final LiveNavguardPlatform liveDemoPlatform;
  final NavguardAiPlatform aiPlatform;
  final bool enableLiveMapTiles;
  final bool? diagnosticsAccessOverride;

  bool get diagnosticsAccessEnabled =>
      diagnosticsAccessOverride ?? navguardDiagnosticsEnabled;

  @override
  State<SensorDiagnosticsPage> createState() => _SensorDiagnosticsPageState();
}

class _SensorDiagnosticsPageState extends State<SensorDiagnosticsPage> {
  static const MethodChannel _sensorChannel = MethodChannel(
    'io.github.mesuttsahin.navguard/sensor_diagnostics',
  );

  static const MethodChannel _gnssChannel = MethodChannel(
    'io.github.mesuttsahin.navguard/gnss_diagnostics',
  );

  static const MethodChannel _gnssAnchorChannel = MethodChannel(
    'io.github.mesuttsahin.navguard/gnss_anchor',
  );

  static const MethodChannel _headingFoundationChannel = MethodChannel(
    'io.github.mesuttsahin.navguard/heading_foundation',
  );

  static const MethodChannel _stepEventChannel = MethodChannel(
    'io.github.mesuttsahin.navguard/step_event',
  );

  static const MethodChannel _baselinePdrChannel = MethodChannel(
    'io.github.mesuttsahin.navguard/baseline_pdr',
  );

  static const MethodChannel _arCoreChannel = MethodChannel(
    'io.github.mesuttsahin.navguard/arcore_diagnostics',
  );

  static const MethodChannel _arCoreEnuChannel = MethodChannel(
    'io.github.mesuttsahin.navguard/arcore_enu',
  );

  static const MethodChannel _evaluationModeChannel = MethodChannel(
    'io.github.mesuttsahin.navguard/evaluation_mode',
  );

  static const MethodChannel _navguardFusionChannel = MethodChannel(
    'io.github.mesuttsahin.navguard/navguard_fusion',
  );

  static const MethodChannel _fullNavguardFlowChannel = MethodChannel(
    'io.github.mesuttsahin.navguard/full_navguard_flow',
  );

  static const MethodChannel _navguardBenchmarkChannel = MethodChannel(
    'io.github.mesuttsahin.navguard/navguard_benchmark',
  );

  static const MethodChannel _accuracyV2Channel = MethodChannel(
    navguardAccuracyV2ChannelName,
  );

  static const JsonEncoder _jsonEncoder = JsonEncoder.withIndent('  ');

  _DiagnosticOperation? _activeOperation;
  _SensorOption _selectedSensor = _sensorOptions.first;
  String _preciseLocationPermission = 'Unknown';
  String _gpsProvider = 'Unknown';
  String _locationServices = 'Unknown';
  bool? _canRunFormalGnssDiagnostic;
  GnssAnchorPreflight? _gnssAnchorPreflight;
  GnssAnchorRuntimeState _gnssAnchorState = GnssAnchorRuntimeState.noAnchor;
  GnssAnchor? _gnssAnchor;
  bool _anchorCancellationRequestInFlight = false;
  HeadingFoundationPreflight? _headingPreflight;
  HeadingDiagnosticResult? _headingResult;
  String _headingDiagnosticStatus = 'Idle';
  bool _headingCancellationRequestInFlight = false;
  StepEventPreflight? _stepPreflight;
  StepEventDiagnosticResult? _stepResult;
  String _stepDiagnosticStatus = 'Idle';
  bool _stepCancellationRequestInFlight = false;
  BaselinePdrPreflight? _baselinePdrPreflight;
  BaselinePdrDiagnosticResult? _baselinePdrResult;
  String _baselinePdrStatus = 'Idle';
  bool _baselinePdrCancellationRequestInFlight = false;
  String _cameraPermission = 'Unknown';
  String _arCoreAvailability = 'Unknown';
  String _arCoreReady = 'Unknown';
  bool? _canRunFormalArCoreDiagnostic;
  ArCoreEnuPreflight? _arCoreEnuPreflight;
  ArCoreEnuDiagnosticResult? _arCoreEnuResult;
  String _arCoreEnuAlignmentStatus = 'Not started';
  String _arCoreEnuStatus = 'Idle';
  bool _arCoreEnuCancellationRequestInFlight = false;
  EvaluationModePreflight? _evaluationModePreflight;
  EvaluationModeDiagnosticResult? _evaluationModeResult;
  String _evaluationModeStatus = 'Idle';
  bool _evaluationModeCancellationRequestInFlight = false;
  _DiagnosticOperation? _lastEvaluationModeOperation;
  NavguardFusionPreflight? _navguardFusionPreflight;
  NavguardFusionDiagnosticResult? _navguardFusionResult;
  String _navguardFusionAlignmentStatus = 'Not started';
  String _navguardFusionStatus = 'Idle';
  bool _navguardFusionCancellationRequestInFlight = false;
  _DiagnosticOperation? _lastNavguardFusionOperation;
  FullNavguardFlowPreflight? _fullNavguardFlowPreflight;
  FullNavguardFlowDiagnosticResult? _fullNavguardFlowResult;
  FullNavguardFlowState _fullNavguardFlowState = FullNavguardFlowState.idle;
  bool _fullNavguardFlowCancellationRequestInFlight = false;
  _DiagnosticOperation? _lastFullNavguardFlowOperation;
  bool _fullNavguardFlowPollInFlight = false;
  Timer? _fullNavguardFlowStatePollTimer;
  NavguardBenchmarkPreflight? _navguardBenchmarkPreflight;
  NavguardBenchmarkDiagnosticResult? _navguardBenchmarkResult;
  NavguardBenchmarkPhase _navguardBenchmarkPhase = NavguardBenchmarkPhase.idle;
  bool _navguardBenchmarkCancellationRequestInFlight = false;
  bool _navguardBenchmarkPollInFlight = false;
  Timer? _navguardBenchmarkPollTimer;
  _DiagnosticOperation? _lastNavguardBenchmarkOperation;
  AccuracyV2Preflight? _accuracyV2Preflight;
  CalibrationProfile? _accuracyV2Profile;
  CalibrationResult? _accuracyV2CalibrationResult;
  AccuracyV2DevelopmentBenchmarkResult? _accuracyV2BenchmarkResult;
  AccuracyV2GnssStabilizationDiagnostics? _accuracyV2GnssFailureDiagnostics;
  Timer? _accuracyV2CalibrationProgressTimer;
  int? _accuracyV2FinalDrainRemainingSeconds;
  Timer? _accuracyV2BenchmarkProgressTimer;
  bool _accuracyV2BenchmarkPollInFlight = false;
  String _accuracyV2BenchmarkPhase = 'IDLE';
  int? _accuracyV2BenchmarkDrainRemainingSeconds;
  String? _accuracyV2DevelopmentScenario;
  _DiagnosticOperation? _lastAccuracyV2Operation;
  String? _formattedOutput;
  String? _errorMessage;
  Map<String, Object?>? _sensorInventorySnapshot;
  Map<String, Object?>? _sensorTimingSnapshot;
  _DiagnosticOperation? _lastSensorOperation;
  Map<String, Object?>? _gnssPreflightSnapshot;
  Map<String, Object?>? _gnssTimingSnapshot;
  Map<String, Object?>? _gnssAnchorPreflightSnapshot;
  _DiagnosticOperation? _lastGnssOperation;
  _DiagnosticOperation? _lastHeadingPdrOperation;
  Map<String, Object?>? _arCorePreflightSnapshot;
  Map<String, Object?>? _arCoreTrackingSnapshot;
  _DiagnosticOperation? _lastArCoreOperation;
  _DashboardModule? _activeDashboardModule;
  bool _systemRefreshInProgress = false;
  String? _systemRefreshError;
  bool? _requiredSensorsAvailable;
  NavguardAiModelStatus? _aiModelStatus;

  bool get _isBusy => _activeOperation != null;

  bool get _isInventoryLoading =>
      _activeOperation == _DiagnosticOperation.inventory;

  bool get _isSensorTimingLoading =>
      _activeOperation == _DiagnosticOperation.sensorTiming;

  bool get _isGnssPreflightLoading =>
      _activeOperation == _DiagnosticOperation.gnssPreflight;

  bool get _isGnssPermissionLoading =>
      _activeOperation == _DiagnosticOperation.gnssPermission;

  bool get _isGnssTimingLoading =>
      _activeOperation == _DiagnosticOperation.gnssTiming;

  bool get _isGnssAnchorPreflightLoading =>
      _activeOperation == _DiagnosticOperation.gnssAnchorPreflight;

  bool get _isGnssAnchorAcquisitionLoading =>
      _activeOperation == _DiagnosticOperation.gnssAnchorAcquisition;

  bool get _isHeadingPreflightLoading =>
      _activeOperation == _DiagnosticOperation.headingPreflight;

  bool get _isHeadingDiagnosticLoading =>
      _activeOperation == _DiagnosticOperation.headingDiagnostic;

  bool get _isStepPreflightLoading =>
      _activeOperation == _DiagnosticOperation.stepPreflight;

  bool get _isStepPermissionLoading =>
      _activeOperation == _DiagnosticOperation.stepPermission;

  bool get _isStepDiagnosticLoading =>
      _activeOperation == _DiagnosticOperation.stepDiagnostic;

  bool get _isBaselinePdrPreflightLoading =>
      _activeOperation == _DiagnosticOperation.baselinePdrPreflight;

  bool get _isBaselinePdrDiagnosticLoading =>
      _activeOperation == _DiagnosticOperation.baselinePdrDiagnostic;

  bool get _isArCorePreflightLoading =>
      _activeOperation == _DiagnosticOperation.arCorePreflight;

  bool get _isArCorePermissionLoading =>
      _activeOperation == _DiagnosticOperation.arCorePermission;

  bool get _isArCoreTrackingLoading =>
      _activeOperation == _DiagnosticOperation.arCoreTracking;

  bool get _isArCoreEnuPreflightLoading =>
      _activeOperation == _DiagnosticOperation.arCoreEnuPreflight;

  bool get _isArCoreEnuDiagnosticLoading =>
      _activeOperation == _DiagnosticOperation.arCoreEnuDiagnostic;

  bool get _isEvaluationModePreflightLoading =>
      _activeOperation == _DiagnosticOperation.evaluationModePreflight;

  bool get _isEvaluationModeDiagnosticLoading =>
      _activeOperation == _DiagnosticOperation.evaluationModeDiagnostic;

  bool get _isNavguardFusionPreflightLoading =>
      _activeOperation == _DiagnosticOperation.navguardFusionPreflight;

  bool get _isNavguardFusionDiagnosticLoading =>
      _activeOperation == _DiagnosticOperation.navguardFusionDiagnostic;

  bool get _isFullNavguardFlowPreflightLoading =>
      _activeOperation == _DiagnosticOperation.fullNavguardFlowPreflight;

  bool get _isFullNavguardFlowDiagnosticLoading =>
      _activeOperation == _DiagnosticOperation.fullNavguardFlowDiagnostic;

  bool get _isNavguardBenchmarkPreflightLoading =>
      _activeOperation == _DiagnosticOperation.navguardBenchmarkPreflight;

  bool get _isNavguardBenchmarkDiagnosticLoading =>
      _activeOperation == _DiagnosticOperation.navguardBenchmarkDiagnostic;

  bool get _isAccuracyV2PreflightLoading =>
      _activeOperation == _DiagnosticOperation.accuracyV2Preflight;

  bool get _isAccuracyV2CalibrationLoading =>
      _activeOperation == _DiagnosticOperation.accuracyV2Calibration;

  bool get _isAccuracyV2BenchmarkLoading =>
      _activeOperation == _DiagnosticOperation.accuracyV2DevelopmentBenchmark;

  bool get _isAccuracyV2ResetLoading =>
      _activeOperation == _DiagnosticOperation.accuracyV2Reset;

  bool get _canRunHeadingDiagnostic =>
      !_isBusy &&
      _headingPreflight?.rotationVectorAvailable == true &&
      _gnssAnchorState == GnssAnchorRuntimeState.anchorLocked &&
      _gnssAnchor != null;

  bool get _canRunStepDiagnostic =>
      !_isBusy && _stepPreflight?.canRunStepDiagnostic == true;

  bool get _canRunBaselinePdr =>
      !_isBusy &&
      _baselinePdrPreflight?.nativeSensorsReady == true &&
      _gnssAnchorState == GnssAnchorRuntimeState.anchorLocked &&
      _gnssAnchor != null;

  bool get _canRunArCoreEnuDiagnostic =>
      !_isBusy &&
      _arCoreEnuPreflight?.nativeReady == true &&
      _gnssAnchorState == GnssAnchorRuntimeState.anchorLocked &&
      _gnssAnchor != null;

  bool get _canRunEvaluationMode =>
      !_isBusy &&
      _evaluationModePreflight?.nativeReady == true &&
      _gnssAnchorState == GnssAnchorRuntimeState.anchorLocked &&
      _gnssAnchor != null;

  bool get _canRunNavguardFusion =>
      !_isBusy &&
      _navguardFusionPreflight?.nativeReady == true &&
      _gnssAnchorState == GnssAnchorRuntimeState.anchorLocked &&
      _gnssAnchor != null;

  bool get _canRunFullNavguardFlow =>
      !_isBusy &&
      _fullNavguardFlowPreflight?.nativeReady == true &&
      _gnssAnchorState == GnssAnchorRuntimeState.anchorLocked &&
      _gnssAnchor != null;

  bool get _canRunNavguardBenchmark =>
      !_isBusy &&
      _navguardBenchmarkPreflight?.nativeReady == true &&
      _gnssAnchorState == GnssAnchorRuntimeState.anchorLocked &&
      _gnssAnchor != null;

  bool get _canRunAccuracyV2 =>
      !_isBusy &&
      _accuracyV2Preflight?.nativeReady == true &&
      _gnssAnchorState == GnssAnchorRuntimeState.anchorLocked &&
      _gnssAnchor != null;

  String get _anchorCandidateCountLabel {
    return _gnssAnchor?.candidateCount.toString() ?? 'Not available';
  }

  String get _anchorReportedHorizontalAccuracyLabel {
    final double? value = _gnssAnchor?.horizontalAccuracyReportedM;

    if (value == null) {
      return 'Not available';
    }

    return '${value.toStringAsFixed(1)} m';
  }

  String get _anchorAltitudeAvailableLabel {
    final GnssAnchor? anchor = _gnssAnchor;

    if (anchor == null) {
      return 'Unknown';
    }

    return anchor.altitudeAvailable ? 'Yes' : 'No';
  }

  String get _horizontalEnuOriginReadyLabel {
    return _gnssAnchorState == GnssAnchorRuntimeState.anchorLocked
        ? 'Yes'
        : 'No';
  }

  String get _headingObservedRateLabel {
    final double? value = _headingResult?.observedSampleRateHz;
    return value == null ? 'Not available' : '${value.toStringAsFixed(2)} Hz';
  }

  String get _headingValidSampleCountLabel {
    return _headingResult?.validHeadingSampleCount.toString() ??
        'Not available';
  }

  String get _reportedHeadingAccuracyLabel {
    final HeadingDiagnosticResult? result = _headingResult;

    if (result == null) {
      return 'Not available';
    }

    if (!result.reportedHeadingAccuracyAvailable) {
      return 'Unavailable';
    }

    return _formatRadians(result.lastReportedHeadingAccuracyRad);
  }

  String get _headingTimestampMonotonicityLabel {
    final HeadingDiagnosticResult? result = _headingResult;

    if (result == null) {
      return 'Not available';
    }

    return result.nonMonotonicTimestampCount == 0
        ? 'Monotonic'
        : '${result.nonMonotonicTimestampCount} non-monotonic update(s)';
  }

  String get _cumulativeHeadingChangeLabel {
    return _formatRadians(
      _headingResult?.cumulativeUnwrappedTrueHeadingDeltaRad,
    );
  }

  String get _detectedStepEventsLabel {
    return _stepResult?.acceptedStepEventCount.toString() ?? 'Not available';
  }

  String get _invalidStepEventsLabel {
    return _stepResult?.invalidStepEventCount.toString() ?? 'Not available';
  }

  String get _stepTimestampMonotonicityLabel {
    final StepEventDiagnosticResult? result = _stepResult;

    if (result == null) {
      return 'Not available';
    }

    if (result.nonMonotonicTimestampCount == 0 &&
        result.duplicateTimestampCount == 0) {
      return 'Monotonic, duplicate-free';
    }

    return '${result.nonMonotonicTimestampCount} non-monotonic, '
        '${result.duplicateTimestampCount} duplicate';
  }

  String get _medianStepIntervalLabel {
    final double? value = _stepResult?.medianStepIntervalMs;

    return value == null ? 'Not available' : '${value.toStringAsFixed(2)} ms';
  }

  String get _observedStepCadenceLabel {
    final double? value = _stepResult?.observedCadenceStepsPerMinute;

    return value == null
        ? 'Not available'
        : '${value.toStringAsFixed(2)} steps/min';
  }

  String get _baselinePdrDetectedStepsLabel {
    return _baselinePdrResult?.acceptedStepEventCount.toString() ??
        'Not available';
  }

  String get _baselinePdrIntegratedStepsLabel {
    return _baselinePdrResult?.integratedStepCount.toString() ??
        'Not available';
  }

  String get _baselinePdrUnassociatedStepsLabel {
    return _baselinePdrResult?.unassociatedStepCount.toString() ??
        'Not available';
  }

  String get _baselinePdrFinalEastLabel {
    return _formatMeters(_baselinePdrResult?.finalEastM);
  }

  String get _baselinePdrFinalNorthLabel {
    return _formatMeters(_baselinePdrResult?.finalNorthM);
  }

  String get _baselinePdrNetDisplacementLabel {
    return _formatMeters(_baselinePdrResult?.netDisplacementM);
  }

  String get _baselinePdrNominalPathLabel {
    return _formatMeters(_baselinePdrResult?.nominalIntegratedPathLengthM);
  }

  String get _baselinePdrMedianAssociationAgeLabel {
    final double? value = _baselinePdrResult?.medianHeadingAssociationAgeMs;
    return value == null ? 'Not available' : '${value.toStringAsFixed(3)} ms';
  }

  String get _arCoreEnuTrackingFractionLabel {
    final double? value = _arCoreEnuResult?.trackingFraction;
    return value == null
        ? 'Not available'
        : '${(value * 100.0).toStringAsFixed(1)}%';
  }

  String get _arCoreEnuUsableFramesLabel {
    return _arCoreEnuResult?.usableEnuFrameCount.toString() ?? 'Not available';
  }

  String get _arCoreEnuFinalEastLabel {
    return _formatMeters(_arCoreEnuResult?.finalEastM);
  }

  String get _arCoreEnuFinalNorthLabel {
    return _formatMeters(_arCoreEnuResult?.finalNorthM);
  }

  String get _arCoreEnuFinalUpLabel {
    return _formatMeters(_arCoreEnuResult?.finalUpM);
  }

  String get _arCoreEnuHorizontalDisplacementLabel {
    return _formatMeters(_arCoreEnuResult?.finalHorizontalDisplacementM);
  }

  String get _arCoreEnu3dDisplacementLabel {
    return _formatMeters(_arCoreEnuResult?.final3dDisplacementM);
  }

  String get _arCoreEnuMaxHorizontalExcursionLabel {
    return _formatMeters(_arCoreEnuResult?.maxHorizontalDisplacementM);
  }

  String get _arCoreEnuMedianFrameIntervalLabel {
    final double? value = _arCoreEnuResult?.medianFrameDeltaMs;
    return value == null ? 'Not available' : '${value.toStringAsFixed(3)} ms';
  }

  String get _navguardFusionAnchorLabel {
    return _gnssAnchorState == GnssAnchorRuntimeState.anchorLocked &&
            _gnssAnchor != null
        ? 'Locked'
        : 'Required';
  }

  String get _fullFlowGpsLabel {
    final FullNavguardFlowPreflight? value = _fullNavguardFlowPreflight;
    if (value == null) return 'Unknown';
    if (!value.gpsProviderAvailable) return 'Unavailable';
    return value.gpsProviderEnabled ? 'Enabled' : 'Disabled';
  }

  String get _fullFlowAnchorLabel {
    return _gnssAnchorState == GnssAnchorRuntimeState.anchorLocked &&
            _gnssAnchor != null
        ? 'Locked'
        : 'Required';
  }

  String get _fullFlowArCoreLabel {
    final FullNavguardFlowPreflight? value = _fullNavguardFlowPreflight;
    if (value == null) return 'Unknown';
    if (!value.arCoreSupported) return 'Unsupported';
    return value.arCoreInstalled ? 'Ready' : 'Not installed/current';
  }

  String _formatNavguardStandardDeviation(double? variance, String unit) {
    if (variance == null || !variance.isFinite || variance < 0) {
      return 'Not available';
    }
    return '${math.sqrt(variance).toStringAsFixed(3)} $unit';
  }

  String _formatRadians(double? value) {
    return value == null ? 'Not available' : '${value.toStringAsFixed(6)} rad';
  }

  String _formatMeters(double? value) {
    return value == null ? 'Not available' : '${value.toStringAsFixed(3)} m';
  }

  _ReadinessStatus get _gnssReadiness {
    if (_canRunFormalGnssDiagnostic == null) {
      return const _ReadinessStatus('Not checked', _ReadinessKind.neutral);
    }
    if (_preciseLocationPermission != 'Granted') {
      return const _ReadinessStatus(
        'Permission required',
        _ReadinessKind.attention,
      );
    }
    if (_gpsProvider != 'Enabled' || _locationServices == 'Disabled') {
      return const _ReadinessStatus('Unavailable', _ReadinessKind.unavailable);
    }
    return _canRunFormalGnssDiagnostic == true
        ? const _ReadinessStatus('Ready', _ReadinessKind.ready)
        : const _ReadinessStatus('Unavailable', _ReadinessKind.unavailable);
  }

  _ReadinessStatus get _sensorReadiness => switch (_requiredSensorsAvailable) {
    null => const _ReadinessStatus('Not checked', _ReadinessKind.neutral),
    true => const _ReadinessStatus('Ready', _ReadinessKind.ready),
    false => const _ReadinessStatus('Unavailable', _ReadinessKind.unavailable),
  };

  _ReadinessStatus get _arCoreReadiness {
    if (_canRunFormalArCoreDiagnostic == null) {
      return const _ReadinessStatus('Not checked', _ReadinessKind.neutral);
    }
    if (_cameraPermission != 'Granted') {
      return const _ReadinessStatus(
        'Permission required',
        _ReadinessKind.attention,
      );
    }
    return _canRunFormalArCoreDiagnostic == true && _arCoreReady == 'Yes'
        ? const _ReadinessStatus('Ready', _ReadinessKind.ready)
        : const _ReadinessStatus('Unavailable', _ReadinessKind.unavailable);
  }

  _ReadinessStatus get _aiReadiness => switch (_aiModelStatus) {
    null => const _ReadinessStatus('Not checked', _ReadinessKind.neutral),
    NavguardAiModelStatus.modelReady || NavguardAiModelStatus.aiActive =>
      const _ReadinessStatus('Ready', _ReadinessKind.ready),
    NavguardAiModelStatus.warmingUp => const _ReadinessStatus(
      'Loading',
      _ReadinessKind.busy,
    ),
    NavguardAiModelStatus.modelNotAvailable ||
    NavguardAiModelStatus.heuristicFallback => const _ReadinessStatus(
      'Unavailable',
      _ReadinessKind.unavailable,
    ),
    NavguardAiModelStatus.modelInvalid => const _ReadinessStatus(
      'Error',
      _ReadinessKind.error,
    ),
    NavguardAiModelStatus.unknown => const _ReadinessStatus(
      'Error',
      _ReadinessKind.error,
    ),
  };

  _ReadinessStatus get _anchorReadiness => switch (_gnssAnchorState) {
    GnssAnchorRuntimeState.anchorLocked => const _ReadinessStatus(
      'Ready',
      _ReadinessKind.ready,
    ),
    GnssAnchorRuntimeState.acquiring => const _ReadinessStatus(
      'Acquiring',
      _ReadinessKind.busy,
    ),
    GnssAnchorRuntimeState.failed => const _ReadinessStatus(
      'Error',
      _ReadinessKind.error,
    ),
    GnssAnchorRuntimeState.noAnchor => const _ReadinessStatus(
      'Not locked',
      _ReadinessKind.attention,
    ),
  };

  Future<void> _refreshSystemStatus() async {
    if (_systemRefreshInProgress || _isBusy) return;

    setState(() {
      _systemRefreshInProgress = true;
      _systemRefreshError = null;
    });

    bool? sensorsAvailable = _requiredSensorsAvailable;
    _GnssDisplayState? gnssState;
    GnssAnchorPreflight? anchorPreflight;
    _ArCoreDisplayState? arCoreState;
    NavguardAiModelStatus? aiStatus = _aiModelStatus;
    int failureCount = 0;

    try {
      final Object? raw = await _sensorChannel.invokeMethod<Object?>(
        'getSensorCapabilityInventory',
      );
      if (raw is! Map || raw['sensors'] is! List) {
        throw const FormatException('Invalid sensor inventory.');
      }
      final Map<String, bool> availability = <String, bool>{
        for (final Object? record in raw['sensors'] as List)
          if (record is Map && record['requestedType'] is String)
            record['requestedType'] as String: record['available'] == true,
      };
      const Set<String> required = <String>{
        'TYPE_ACCELEROMETER',
        'TYPE_GYROSCOPE',
        'TYPE_ROTATION_VECTOR',
        'TYPE_STEP_DETECTOR',
      };
      sensorsAvailable = required.every(
        (String sensor) => availability[sensor] == true,
      );
    } catch (_) {
      failureCount++;
    }

    try {
      final Object? raw = await _gnssChannel.invokeMethod<Object?>(
        'getGnssDiagnosticPreflight',
      );
      if (raw is! Map) throw const FormatException('Invalid GNSS preflight.');
      gnssState = _GnssDisplayState.fromSnapshot(raw);
    } catch (_) {
      failureCount++;
    }

    try {
      final Object? raw = await _gnssAnchorChannel.invokeMethod<Object?>(
        'getGnssAnchorPreflight',
      );
      if (raw is! Map) throw const FormatException('Invalid anchor preflight.');
      anchorPreflight = GnssAnchorPreflight.fromPlatform(raw);
    } catch (_) {
      failureCount++;
    }

    try {
      final Object? raw = await _arCoreChannel.invokeMethod<Object?>(
        'getArCoreDiagnosticPreflight',
      );
      if (raw is! Map) throw const FormatException('Invalid ARCore preflight.');
      arCoreState = _ArCoreDisplayState.fromSnapshot(raw);
    } catch (_) {
      failureCount++;
    }

    try {
      final Map<String, Object?> model = await widget.aiPlatform
          .getModelStatus();
      aiStatus = NavguardAiModelStatus.parse(model['status']);
      if (aiStatus == NavguardAiModelStatus.unknown) failureCount++;
    } catch (_) {
      failureCount++;
    }

    if (!mounted) return;
    setState(() {
      _systemRefreshInProgress = false;
      _systemRefreshError = failureCount == 0
          ? null
          : 'Unable to refresh system status.';
      _requiredSensorsAvailable = sensorsAvailable;
      _aiModelStatus = aiStatus;
      if (gnssState != null) {
        _preciseLocationPermission = gnssState.precisePermission;
        _gpsProvider = gnssState.gpsProvider;
        _locationServices = gnssState.locationServices;
        _canRunFormalGnssDiagnostic = gnssState.canRunFormalDiagnostic;
      }
      if (anchorPreflight != null) {
        _gnssAnchorPreflight = anchorPreflight;
      }
      if (arCoreState != null) {
        _cameraPermission = arCoreState.cameraPermission;
        _arCoreAvailability = arCoreState.availability;
        _arCoreReady = arCoreState.ready;
        _canRunFormalArCoreDiagnostic = arCoreState.canRunFormalDiagnostic;
      }
    });
  }

  void _openDiagnosticModule(_DashboardModule module) {
    if (!widget.diagnosticsAccessEnabled) return;
    setState(() => _activeDashboardModule = module);
  }

  void _closeDiagnosticModule() {
    setState(() => _activeDashboardModule = null);
  }

  Future<void> _readSensorInventory() async {
    _lastSensorOperation = _DiagnosticOperation.inventory;
    await _runDiagnosticRequest(
      channel: _sensorChannel,
      operation: _DiagnosticOperation.inventory,
      methodName: 'getSensorCapabilityInventory',
      operationLabel: 'Sensor inventory',
      invalidResponseMessage: 'Native sensor inventory did not return a map.',
      beginMarker: 'NAVGUARD_SENSOR_INVENTORY_BEGIN',
      endMarker: 'NAVGUARD_SENSOR_INVENTORY_END',
    );

    final Map<String, Object?>? snapshot = _decodeLatestSensorSnapshot(
      'sensor_capability_inventory',
    );
    if (mounted && snapshot != null) {
      setState(() => _sensorInventorySnapshot = snapshot);
    }
  }

  Future<void> _runSensorTimingDiagnostic() async {
    _lastSensorOperation = _DiagnosticOperation.sensorTiming;
    await _runDiagnosticRequest(
      channel: _sensorChannel,
      operation: _DiagnosticOperation.sensorTiming,
      methodName: 'runSensorTimingDiagnostic',
      arguments: <String, Object?>{'sensorKey': _selectedSensor.key},
      operationLabel: 'Sensor timing diagnostic',
      invalidResponseMessage:
          'Native sensor timing diagnostic did not return a map.',
      beginMarker: 'NAVGUARD_SENSOR_TIMING_BEGIN',
      endMarker: 'NAVGUARD_SENSOR_TIMING_END',
    );

    final Map<String, Object?>? snapshot = _decodeLatestSensorSnapshot(
      'sensor_event_timing_diagnostic',
    );
    if (mounted && snapshot != null) {
      setState(() => _sensorTimingSnapshot = snapshot);
    }
  }

  Map<String, Object?>? _decodeLatestSensorSnapshot(String snapshotKind) {
    final String? output = _formattedOutput;
    if (output == null) return null;

    try {
      final Object? decoded = jsonDecode(output);
      if (decoded is Map<String, Object?> &&
          decoded['snapshotKind'] == snapshotKind) {
        return decoded;
      }
    } on FormatException {
      return null;
    }

    return null;
  }

  Future<void> _refreshGnssPreflight() async {
    _lastGnssOperation = _DiagnosticOperation.gnssPreflight;
    await _runDiagnosticRequest(
      channel: _gnssChannel,
      operation: _DiagnosticOperation.gnssPreflight,
      methodName: 'getGnssDiagnosticPreflight',
      operationLabel: 'GNSS diagnostic preflight',
      invalidResponseMessage: 'Native GNSS preflight did not return a map.',
      beginMarker: 'NAVGUARD_GNSS_PREFLIGHT_BEGIN',
      endMarker: 'NAVGUARD_GNSS_PREFLIGHT_END',
      updateGnssState: true,
    );

    final Map<String, Object?>? snapshot = _decodeLatestGnssSnapshot(
      requiredKeys: const <String>{
        'preciseLocationGranted',
        'coarseLocationGranted',
        'gpsProviderAvailable',
        'gpsProviderEnabled',
        'canRunFormalDiagnostic',
      },
    );
    if (mounted && snapshot != null) {
      setState(() => _gnssPreflightSnapshot = snapshot);
    }
  }

  Future<void> _requestGnssForegroundPermission() async {
    _lastGnssOperation = _DiagnosticOperation.gnssPermission;
    await _runDiagnosticRequest(
      channel: _gnssChannel,
      operation: _DiagnosticOperation.gnssPermission,
      methodName: 'requestGnssForegroundPermission',
      operationLabel: 'GNSS foreground permission request',
      invalidResponseMessage:
          'Native GNSS permission result did not return a map.',
      beginMarker: 'NAVGUARD_GNSS_PERMISSION_BEGIN',
      endMarker: 'NAVGUARD_GNSS_PERMISSION_END',
      updateGnssState: true,
    );

    final Map<String, Object?>? snapshot = _decodeLatestGnssSnapshot(
      requiredKeys: const <String>{
        'preciseLocationGranted',
        'coarseLocationGranted',
        'gpsProviderAvailable',
        'gpsProviderEnabled',
        'canRunFormalDiagnostic',
      },
    );
    if (mounted && snapshot != null) {
      setState(() => _gnssPreflightSnapshot = snapshot);
    }
  }

  Future<void> _runGnssTimingDiagnostic() async {
    _lastGnssOperation = _DiagnosticOperation.gnssTiming;
    await _runDiagnosticRequest(
      channel: _gnssChannel,
      operation: _DiagnosticOperation.gnssTiming,
      methodName: 'runGnssTimingDiagnostic',
      operationLabel: 'GNSS timing diagnostic',
      invalidResponseMessage:
          'Native GNSS timing diagnostic did not return a map.',
      beginMarker: 'NAVGUARD_GNSS_TIMING_BEGIN',
      endMarker: 'NAVGUARD_GNSS_TIMING_END',
    );

    final Map<String, Object?>? snapshot = _decodeLatestGnssSnapshot(
      snapshotKind: 'gnss_runtime_timing_diagnostic',
      requiredKeys: const <String>{'locationEventCount', 'validTimingSummary'},
    );
    if (mounted && snapshot != null) {
      setState(() => _gnssTimingSnapshot = snapshot);
    }
  }

  Future<void> _refreshGnssAnchorPreflight() async {
    _lastGnssOperation = _DiagnosticOperation.gnssAnchorPreflight;
    await _runDiagnosticRequest(
      channel: _gnssAnchorChannel,
      operation: _DiagnosticOperation.gnssAnchorPreflight,
      methodName: 'getGnssAnchorPreflight',
      operationLabel: 'GNSS anchor preflight',
      invalidResponseMessage:
          'Native GNSS anchor preflight did not return a map.',
      beginMarker: 'NAVGUARD_GNSS_ANCHOR_PREFLIGHT_BEGIN',
      endMarker: 'NAVGUARD_GNSS_ANCHOR_PREFLIGHT_END',
      updateGnssAnchorPreflight: true,
    );

    final Map<String, Object?>? snapshot = _decodeLatestGnssSnapshot(
      requiredKeys: const <String>{
        'fineLocationPermissionGranted',
        'acquisitionRunning',
        'canAcquireAnchor',
      },
    );
    if (mounted && snapshot != null) {
      setState(() => _gnssAnchorPreflightSnapshot = snapshot);
    }
  }

  Map<String, Object?>? _decodeLatestGnssSnapshot({
    String? snapshotKind,
    required Set<String> requiredKeys,
  }) {
    final String? output = _formattedOutput;
    if (output == null) return null;

    try {
      final Object? decoded = jsonDecode(output);
      if (decoded is! Map<String, Object?>) return null;
      if (snapshotKind != null && decoded['snapshotKind'] != snapshotKind) {
        return null;
      }
      if (!requiredKeys.every(decoded.containsKey)) return null;
      return decoded;
    } on FormatException {
      return null;
    }
  }

  Future<void> _acquireGnssAnchor() async {
    if (_isBusy || _gnssAnchor != null) {
      return;
    }

    setState(() {
      _lastGnssOperation = _DiagnosticOperation.gnssAnchorAcquisition;
      _activeOperation = _DiagnosticOperation.gnssAnchorAcquisition;
      _gnssAnchorState = GnssAnchorRuntimeState.acquiring;
      _formattedOutput = null;
      _errorMessage = null;
    });

    GnssAnchor? nextAnchor;
    String? nextOutput;
    String? nextError;
    Map<String, Object?> sanitizedLog = <String, Object?>{
      'success': false,
      'errorCategory': 'unknown_error',
    };

    try {
      final Object? rawResult = await _gnssAnchorChannel.invokeMethod<Object?>(
        'acquireGnssAnchor',
      );

      if (rawResult is! Map) {
        throw const FormatException(
          'Native GNSS anchor acquisition did not return a map.',
        );
      }

      // This runtime payload contains the selected coordinates. Parse it
      // directly and never pass it to the generic diagnostic JSON logger.
      final GnssAnchor anchor = GnssAnchor.fromPlatform(rawResult);
      nextAnchor = anchor;
      sanitizedLog = anchor.sanitizedMetadata;
      nextOutput = _jsonEncoder.convert(anchor.sanitizedMetadata);
    } on PlatformException catch (error) {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': error.code,
      };
      nextError = 'GNSS anchor acquisition failed (${error.code}).';
    } on MissingPluginException {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': 'channel_unavailable',
      };
      nextError = 'GNSS anchor channel is unavailable on this platform.';
    } on FormatException {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': 'invalid_anchor_response',
      };
      nextError = 'Native GNSS anchor response was invalid.';
    } catch (_) {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': 'unknown_error',
      };
      nextError = 'Unexpected error while acquiring the GNSS anchor.';
    }

    _printSanitizedJsonBlock(
      beginMarker: 'NAVGUARD_GNSS_ANCHOR_ACQUISITION_BEGIN',
      endMarker: 'NAVGUARD_GNSS_ANCHOR_ACQUISITION_END',
      value: sanitizedLog,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _activeOperation = null;
      _gnssAnchor = nextAnchor;
      _gnssAnchorState = nextAnchor == null
          ? GnssAnchorRuntimeState.failed
          : GnssAnchorRuntimeState.anchorLocked;
      _formattedOutput = nextOutput;
      _errorMessage = nextError;
    });
  }

  Future<void> _cancelGnssAnchorAcquisition() async {
    if (!_isGnssAnchorAcquisitionLoading ||
        _anchorCancellationRequestInFlight) {
      return;
    }

    setState(() {
      _anchorCancellationRequestInFlight = true;
    });

    try {
      await _gnssAnchorChannel.invokeMethod<Object?>(
        'cancelGnssAnchorAcquisition',
      );
    } on PlatformException catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'GNSS anchor cancellation failed (${error.code}).';
        });
      }
    } on MissingPluginException {
      if (mounted) {
        setState(() {
          _errorMessage =
              'GNSS anchor channel is unavailable on this platform.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Unexpected error while cancelling anchor acquisition.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _anchorCancellationRequestInFlight = false;
        });
      }
    }
  }

  void _clearGnssAnchor() {
    if (_isBusy || _gnssAnchor == null) {
      return;
    }

    final Map<String, Object?> sanitizedResult = <String, Object?>{
      'success': true,
      'anchorCleared': true,
      'previousState': GnssAnchorRuntimeState.anchorLocked.sanitizedName,
      'nextState': GnssAnchorRuntimeState.noAnchor.sanitizedName,
    };

    _printSanitizedJsonBlock(
      beginMarker: 'NAVGUARD_GNSS_ANCHOR_CLEAR_BEGIN',
      endMarker: 'NAVGUARD_GNSS_ANCHOR_CLEAR_END',
      value: sanitizedResult,
    );

    setState(() {
      _gnssAnchor = null;
      _gnssAnchorState = GnssAnchorRuntimeState.noAnchor;
      _headingResult = null;
      _headingDiagnosticStatus = 'Idle';
      _baselinePdrResult = null;
      _baselinePdrStatus = 'Idle';
      _arCoreEnuResult = null;
      _arCoreEnuAlignmentStatus = 'Not started';
      _arCoreEnuStatus = 'Idle';
      _formattedOutput = _jsonEncoder.convert(sanitizedResult);
      _errorMessage = null;
    });
  }

  Future<void> _refreshHeadingPreflight() async {
    _lastHeadingPdrOperation = _DiagnosticOperation.headingPreflight;
    await _runDiagnosticRequest(
      channel: _headingFoundationChannel,
      operation: _DiagnosticOperation.headingPreflight,
      methodName: 'getHeadingFoundationPreflight',
      operationLabel: 'Heading foundation preflight',
      invalidResponseMessage:
          'Native heading foundation preflight did not return a map.',
      beginMarker: 'NAVGUARD_HEADING_PREFLIGHT_BEGIN',
      endMarker: 'NAVGUARD_HEADING_PREFLIGHT_END',
      updateHeadingPreflight: true,
    );
  }

  Future<void> _runHeadingDiagnostic() async {
    final GnssAnchor? anchor = _gnssAnchor;

    if (!_canRunHeadingDiagnostic || anchor == null) {
      return;
    }

    setState(() {
      _lastHeadingPdrOperation = _DiagnosticOperation.headingDiagnostic;
      _activeOperation = _DiagnosticOperation.headingDiagnostic;
      _headingDiagnosticStatus = 'Running';
      _headingResult = null;
      _formattedOutput = null;
      _errorMessage = null;
    });

    HeadingDiagnosticResult? nextResult;
    String? nextOutput;
    String? nextError;
    Map<String, Object?> sanitizedLog = <String, Object?>{
      'success': false,
      'errorCategory': 'unknown_error',
    };

    try {
      // The coordinates are internal-only channel arguments. This argument map
      // is never sent to the generic JSON logger or rendered by the UI.
      final Object? rawResult = await _headingFoundationChannel
          .invokeMethod<Object?>(
            'runHeadingFoundationDiagnostic',
            <String, Object?>{
              'latitudeDeg': anchor.latitudeDeg,
              'longitudeDeg': anchor.longitudeDeg,
              'altitudeEllipsoidM': anchor.altitudeEllipsoidM,
            },
          );

      final HeadingDiagnosticResult parsedResult =
          HeadingDiagnosticResult.fromPlatform(rawResult);
      nextResult = parsedResult;
      sanitizedLog = parsedResult.sanitizedMetadata;
      nextOutput = _jsonEncoder.convert(parsedResult.sanitizedMetadata);
    } on PlatformException catch (error) {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': error.code,
      };
      nextError = 'Heading foundation diagnostic failed (${error.code}).';
    } on MissingPluginException {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': 'channel_unavailable',
      };
      nextError = 'Heading foundation channel is unavailable on this platform.';
    } on FormatException {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': 'invalid_heading_response',
      };
      nextError = 'Native heading foundation response was invalid.';
    } catch (_) {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': 'unknown_error',
      };
      nextError = 'Unexpected error while running the heading diagnostic.';
    }

    _printSanitizedJsonBlock(
      beginMarker: 'NAVGUARD_HEADING_DIAGNOSTIC_BEGIN',
      endMarker: 'NAVGUARD_HEADING_DIAGNOSTIC_END',
      value: sanitizedLog,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _activeOperation = null;
      _headingResult = nextResult;
      _headingDiagnosticStatus = nextResult == null ? 'Failed' : 'Success';
      _formattedOutput = nextOutput;
      _errorMessage = nextError;
    });
  }

  Future<void> _cancelHeadingDiagnostic() async {
    if (!_isHeadingDiagnosticLoading || _headingCancellationRequestInFlight) {
      return;
    }

    setState(() {
      _headingCancellationRequestInFlight = true;
    });

    try {
      await _headingFoundationChannel.invokeMethod<Object?>(
        'cancelHeadingFoundationDiagnostic',
      );
    } on PlatformException catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Heading cancellation failed (${error.code}).';
        });
      }
    } on MissingPluginException {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Heading foundation channel is unavailable on this platform.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Unexpected error while cancelling heading diagnostic.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _headingCancellationRequestInFlight = false;
        });
      }
    }
  }

  Future<void> _refreshStepPreflight() async {
    _lastHeadingPdrOperation = _DiagnosticOperation.stepPreflight;
    await _runDiagnosticRequest(
      channel: _stepEventChannel,
      operation: _DiagnosticOperation.stepPreflight,
      methodName: 'getStepEventPreflight',
      operationLabel: 'Step-event preflight',
      invalidResponseMessage:
          'Native step-event preflight did not return a map.',
      beginMarker: 'NAVGUARD_STEP_PREFLIGHT_BEGIN',
      endMarker: 'NAVGUARD_STEP_PREFLIGHT_END',
      updateStepPreflight: true,
    );
  }

  Future<void> _requestActivityRecognitionPermission() async {
    _lastHeadingPdrOperation = _DiagnosticOperation.stepPermission;
    await _runDiagnosticRequest(
      channel: _stepEventChannel,
      operation: _DiagnosticOperation.stepPermission,
      methodName: 'requestActivityRecognitionPermission',
      operationLabel: 'Physical activity permission request',
      invalidResponseMessage:
          'Native physical activity permission result did not return a map.',
      beginMarker: 'NAVGUARD_STEP_PERMISSION_BEGIN',
      endMarker: 'NAVGUARD_STEP_PERMISSION_END',
      updateStepPreflight: true,
    );
  }

  Future<void> _runStepDiagnostic() async {
    if (!_canRunStepDiagnostic) {
      return;
    }

    setState(() {
      _lastHeadingPdrOperation = _DiagnosticOperation.stepDiagnostic;
      _activeOperation = _DiagnosticOperation.stepDiagnostic;
      _stepDiagnosticStatus = 'Running';
      _stepResult = null;
      _formattedOutput = null;
      _errorMessage = null;
    });

    StepEventDiagnosticResult? nextResult;
    String? nextOutput;
    String? nextError;
    Map<String, Object?> sanitizedLog = <String, Object?>{
      'success': false,
      'errorCategory': 'unknown_error',
    };

    try {
      final Object? rawResult = await _stepEventChannel.invokeMethod<Object?>(
        'runStepEventDiagnostic',
      );

      final StepEventDiagnosticResult parsedResult =
          StepEventDiagnosticResult.fromPlatform(rawResult);

      nextResult = parsedResult;
      sanitizedLog = parsedResult.sanitizedMetadata;
      nextOutput = _jsonEncoder.convert(parsedResult.sanitizedMetadata);
    } on PlatformException catch (error) {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': error.code,
      };
      nextError = 'Step-event diagnostic failed (${error.code}).';
    } on MissingPluginException {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': 'channel_unavailable',
      };
      nextError = 'Step-event channel is unavailable on this platform.';
    } on FormatException {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': 'invalid_step_response',
      };
      nextError = 'Native step-event response was invalid.';
    } catch (_) {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': 'unknown_error',
      };
      nextError = 'Unexpected error while running the step-event diagnostic.';
    }

    _printSanitizedJsonBlock(
      beginMarker: 'NAVGUARD_STEP_DIAGNOSTIC_BEGIN',
      endMarker: 'NAVGUARD_STEP_DIAGNOSTIC_END',
      value: sanitizedLog,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _activeOperation = null;
      _stepResult = nextResult;
      _stepDiagnosticStatus = nextResult == null ? 'Failed' : 'Success';
      _formattedOutput = nextOutput;
      _errorMessage = nextError;
    });
  }

  Future<void> _cancelStepDiagnostic() async {
    if (!_isStepDiagnosticLoading || _stepCancellationRequestInFlight) {
      return;
    }

    setState(() {
      _stepCancellationRequestInFlight = true;
    });

    try {
      await _stepEventChannel.invokeMethod<Object?>(
        'cancelStepEventDiagnostic',
      );
    } on PlatformException catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Step diagnostic cancellation failed (${error.code}).';
        });
      }
    } on MissingPluginException {
      if (mounted) {
        setState(() {
          _errorMessage = 'Step-event channel is unavailable on this platform.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Unexpected error while cancelling step diagnostic.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _stepCancellationRequestInFlight = false;
        });
      }
    }
  }

  Future<void> _refreshBaselinePdrPreflight() async {
    if (_isBusy) {
      return;
    }

    setState(() {
      _lastHeadingPdrOperation = _DiagnosticOperation.baselinePdrPreflight;
      _activeOperation = _DiagnosticOperation.baselinePdrPreflight;
      _formattedOutput = null;
      _errorMessage = null;
    });

    BaselinePdrPreflight? nextPreflight;
    String? nextOutput;
    String? nextError;
    Map<String, Object?> sanitizedLog = <String, Object?>{
      'success': false,
      'errorCategory': 'unknown_error',
    };

    try {
      final Object? rawResult = await _baselinePdrChannel.invokeMethod<Object?>(
        'getBaselinePdrPreflight',
      );
      final BaselinePdrPreflight parsed = BaselinePdrPreflight.fromPlatform(
        rawResult,
      );
      nextPreflight = parsed;
      sanitizedLog = parsed.sanitizedMetadata;
      nextOutput = _jsonEncoder.convert(parsed.sanitizedMetadata);
    } on PlatformException catch (error) {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': error.code,
      };
      nextError = 'Baseline PDR preflight failed (${error.code}).';
    } on MissingPluginException {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': 'channel_unavailable',
      };
      nextError = 'Baseline PDR channel is unavailable on this platform.';
    } on FormatException {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': 'invalid_baseline_pdr_preflight',
      };
      nextError = 'Native baseline PDR preflight response was invalid.';
    } catch (_) {
      nextError = 'Unexpected error while refreshing baseline PDR preflight.';
    }

    _printSanitizedJsonBlock(
      beginMarker: 'NAVGUARD_BASELINE_PDR_PREFLIGHT_BEGIN',
      endMarker: 'NAVGUARD_BASELINE_PDR_PREFLIGHT_END',
      value: sanitizedLog,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _activeOperation = null;
      _baselinePdrPreflight = nextPreflight;
      _formattedOutput = nextOutput;
      _errorMessage = nextError;
    });
  }

  Future<void> _runBaselinePdrDiagnostic() async {
    final GnssAnchor? anchor = _gnssAnchor;
    if (!_canRunBaselinePdr || anchor == null) {
      return;
    }

    setState(() {
      _lastHeadingPdrOperation = _DiagnosticOperation.baselinePdrDiagnostic;
      _activeOperation = _DiagnosticOperation.baselinePdrDiagnostic;
      _baselinePdrStatus = 'Running';
      _baselinePdrResult = null;
      _formattedOutput = null;
      _errorMessage = null;
    });

    BaselinePdrDiagnosticResult? nextResult;
    String? nextOutput;
    String? nextError;
    Map<String, Object?> sanitizedLog = <String, Object?>{
      'success': false,
      'errorCategory': 'unknown_error',
    };

    try {
      // Locked-anchor coordinates are internal-only declination inputs. They
      // are never included in sanitized logs, result metadata, or UI output.
      final Object? rawResult = await _baselinePdrChannel
          .invokeMethod<Object?>('runBaselinePdrDiagnostic', <String, Object?>{
            'latitudeDeg': anchor.latitudeDeg,
            'longitudeDeg': anchor.longitudeDeg,
            'altitudeEllipsoidM': anchor.altitudeEllipsoidM,
          });
      final BaselinePdrDiagnosticResult parsed =
          BaselinePdrDiagnosticResult.fromPlatform(rawResult);
      nextResult = parsed;
      sanitizedLog = parsed.sanitizedMetadata;
      nextOutput = _jsonEncoder.convert(parsed.sanitizedMetadata);
    } on PlatformException catch (error) {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': error.code,
      };
      nextError = 'Baseline PDR diagnostic failed (${error.code}).';
    } on MissingPluginException {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': 'channel_unavailable',
      };
      nextError = 'Baseline PDR channel is unavailable on this platform.';
    } on FormatException {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': 'invalid_baseline_pdr_response',
      };
      nextError = 'Native baseline PDR response was invalid.';
    } catch (_) {
      nextError = 'Unexpected error while running baseline PDR.';
    }

    _printSanitizedJsonBlock(
      beginMarker: 'NAVGUARD_BASELINE_PDR_DIAGNOSTIC_BEGIN',
      endMarker: 'NAVGUARD_BASELINE_PDR_DIAGNOSTIC_END',
      value: sanitizedLog,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _activeOperation = null;
      _baselinePdrResult = nextResult;
      _baselinePdrStatus = nextResult == null ? 'Failed' : 'Success';
      _formattedOutput = nextOutput;
      _errorMessage = nextError;
    });
  }

  Future<void> _cancelBaselinePdrDiagnostic() async {
    if (!_isBaselinePdrDiagnosticLoading ||
        _baselinePdrCancellationRequestInFlight) {
      return;
    }

    setState(() {
      _baselinePdrCancellationRequestInFlight = true;
    });

    try {
      await _baselinePdrChannel.invokeMethod<Object?>(
        'cancelBaselinePdrDiagnostic',
      );
    } on PlatformException catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Baseline PDR cancellation failed (${error.code}).';
        });
      }
    } on MissingPluginException {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Baseline PDR channel is unavailable on this platform.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Unexpected error while cancelling baseline PDR.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _baselinePdrCancellationRequestInFlight = false;
        });
      }
    }
  }

  Future<void> _refreshArCorePreflight() async {
    _lastArCoreOperation = _DiagnosticOperation.arCorePreflight;
    await _runDiagnosticRequest(
      channel: _arCoreChannel,
      operation: _DiagnosticOperation.arCorePreflight,
      methodName: 'getArCoreDiagnosticPreflight',
      operationLabel: 'ARCore diagnostic preflight',
      invalidResponseMessage: 'Native ARCore preflight did not return a map.',
      beginMarker: 'NAVGUARD_ARCORE_PREFLIGHT_BEGIN',
      endMarker: 'NAVGUARD_ARCORE_PREFLIGHT_END',
      updateArCoreState: true,
    );

    final Map<String, Object?>? snapshot = _decodeArCoreSnapshot(
      requiredKeys: const <String>{
        'cameraPermissionGranted',
        'availabilityRaw',
        'arCoreInstalledAndCurrent',
        'canRunFormalDiagnostic',
      },
    );
    if (mounted && snapshot != null) {
      setState(() => _arCorePreflightSnapshot = snapshot);
    }
  }

  Future<void> _requestArCoreCameraPermission() async {
    _lastArCoreOperation = _DiagnosticOperation.arCorePermission;
    await _runDiagnosticRequest(
      channel: _arCoreChannel,
      operation: _DiagnosticOperation.arCorePermission,
      methodName: 'requestArCoreCameraPermission',
      operationLabel: 'ARCore camera permission request',
      invalidResponseMessage:
          'Native ARCore camera permission result did not return a map.',
      beginMarker: 'NAVGUARD_ARCORE_PERMISSION_BEGIN',
      endMarker: 'NAVGUARD_ARCORE_PERMISSION_END',
      updateArCoreState: true,
    );

    final Map<String, Object?>? snapshot = _decodeArCoreSnapshot(
      requiredKeys: const <String>{
        'cameraPermissionGranted',
        'availabilityRaw',
        'arCoreInstalledAndCurrent',
        'canRunFormalDiagnostic',
      },
    );
    if (mounted && snapshot != null) {
      setState(() => _arCorePreflightSnapshot = snapshot);
    }
  }

  Future<void> _runArCoreTrackingDiagnostic() async {
    _lastArCoreOperation = _DiagnosticOperation.arCoreTracking;
    await _runDiagnosticRequest(
      channel: _arCoreChannel,
      operation: _DiagnosticOperation.arCoreTracking,
      methodName: 'runArCoreTrackingDiagnostic',
      operationLabel: 'ARCore tracking diagnostic',
      invalidResponseMessage:
          'Native ARCore tracking diagnostic did not return a map.',
      beginMarker: 'NAVGUARD_ARCORE_TRACKING_BEGIN',
      endMarker: 'NAVGUARD_ARCORE_TRACKING_END',
    );

    final Map<String, Object?>? snapshot = _decodeArCoreSnapshot(
      snapshotKind: 'arcore_runtime_tracking_diagnostic',
      requiredKeys: const <String>{
        'validTrackingSummary',
        'uniqueFrameCount',
        'trackingFrameCount',
      },
    );
    if (mounted && snapshot != null) {
      setState(() => _arCoreTrackingSnapshot = snapshot);
    }
  }

  Map<String, Object?>? _decodeArCoreSnapshot({
    String? snapshotKind,
    required Set<String> requiredKeys,
  }) {
    final String? output = _formattedOutput;
    if (output == null) return null;

    try {
      final Object? decoded = jsonDecode(output);
      if (decoded is! Map<String, Object?>) return null;
      if (snapshotKind != null && decoded['snapshotKind'] != snapshotKind) {
        return null;
      }
      if (!requiredKeys.every(decoded.containsKey)) return null;
      return decoded;
    } on FormatException {
      return null;
    }
  }

  Future<void> _refreshArCoreEnuPreflight() async {
    if (_isBusy) {
      return;
    }

    setState(() {
      _lastArCoreOperation = _DiagnosticOperation.arCoreEnuPreflight;
      _activeOperation = _DiagnosticOperation.arCoreEnuPreflight;
      _formattedOutput = null;
      _errorMessage = null;
    });

    ArCoreEnuPreflight? nextPreflight;
    String? nextOutput;
    String? nextError;
    Map<String, Object?> sanitizedLog = <String, Object?>{
      'success': false,
      'errorCategory': 'unknown_error',
    };

    try {
      final Object? rawSnapshot = await _arCoreEnuChannel.invokeMethod<Object?>(
        'getArCoreEnuPreflight',
      );
      final ArCoreEnuPreflight parsed = ArCoreEnuPreflight.fromPlatform(
        rawSnapshot,
      );
      nextPreflight = parsed;
      sanitizedLog = parsed.sanitizedMetadata;
      nextOutput = _jsonEncoder.convert(parsed.sanitizedMetadata);
    } on PlatformException catch (error) {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': error.code,
      };
      nextError = 'ARCore-to-ENU preflight failed (${error.code}).';
    } on MissingPluginException {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': 'channel_unavailable',
      };
      nextError = 'ARCore-to-ENU channel is unavailable on this platform.';
    } on FormatException {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': 'invalid_arcore_enu_preflight',
      };
      nextError = 'Native ARCore-to-ENU preflight response was invalid.';
    } catch (_) {
      nextError = 'Unexpected error while refreshing ARCore-to-ENU preflight.';
    }

    _printSanitizedJsonBlock(
      beginMarker: 'NAVGUARD_ARCORE_ENU_PREFLIGHT_BEGIN',
      endMarker: 'NAVGUARD_ARCORE_ENU_PREFLIGHT_END',
      value: sanitizedLog,
    );

    if (!mounted) {
      return;
    }
    setState(() {
      _activeOperation = null;
      _arCoreEnuPreflight = nextPreflight;
      _formattedOutput = nextOutput;
      _errorMessage = nextError;
    });
  }

  Future<void> _runArCoreEnuDiagnostic() async {
    final GnssAnchor? anchor = _gnssAnchor;
    if (!_canRunArCoreEnuDiagnostic || anchor == null) {
      return;
    }

    setState(() {
      _lastArCoreOperation = _DiagnosticOperation.arCoreEnuDiagnostic;
      _activeOperation = _DiagnosticOperation.arCoreEnuDiagnostic;
      _arCoreEnuResult = null;
      _arCoreEnuAlignmentStatus = 'Aligning';
      _arCoreEnuStatus = 'Running';
      _formattedOutput = null;
      _errorMessage = null;
    });

    ArCoreEnuDiagnosticResult? nextResult;
    String? nextOutput;
    String? nextError;
    Map<String, Object?> sanitizedLog = <String, Object?>{
      'success': false,
      'errorCategory': 'unknown_error',
    };

    try {
      // Locked-anchor coordinates are internal-only declination inputs. The
      // argument map is never logged, rendered, or retained by this screen.
      final Object? rawResult = await _arCoreEnuChannel
          .invokeMethod<Object?>('runArCoreEnuDiagnostic', <String, Object?>{
            'latitudeDeg': anchor.latitudeDeg,
            'longitudeDeg': anchor.longitudeDeg,
            'altitudeEllipsoidM': anchor.altitudeEllipsoidM,
          });
      final ArCoreEnuDiagnosticResult parsed =
          ArCoreEnuDiagnosticResult.fromPlatform(rawResult);
      nextResult = parsed;
      sanitizedLog = parsed.sanitizedMetadata;
      nextOutput = _jsonEncoder.convert(parsed.sanitizedMetadata);
    } on PlatformException catch (error) {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': error.code,
      };
      nextError = 'ARCore-to-ENU diagnostic failed (${error.code}).';
    } on MissingPluginException {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': 'channel_unavailable',
      };
      nextError = 'ARCore-to-ENU channel is unavailable on this platform.';
    } on FormatException {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': 'invalid_arcore_enu_response',
      };
      nextError = 'Native ARCore-to-ENU result was invalid.';
    } catch (_) {
      nextError = 'Unexpected error while running ARCore-to-ENU diagnostics.';
    }

    _printSanitizedJsonBlock(
      beginMarker: 'NAVGUARD_ARCORE_ENU_DIAGNOSTIC_BEGIN',
      endMarker: 'NAVGUARD_ARCORE_ENU_DIAGNOSTIC_END',
      value: sanitizedLog,
    );

    if (!mounted) {
      return;
    }
    setState(() {
      _activeOperation = null;
      _arCoreEnuResult = nextResult;
      _arCoreEnuAlignmentStatus = nextResult == null ? 'Failed' : 'Completed';
      _arCoreEnuStatus = nextResult == null ? 'Failed' : 'Success';
      _formattedOutput = nextOutput;
      _errorMessage = nextError;
    });
  }

  Future<void> _cancelArCoreEnuDiagnostic() async {
    if (!_isArCoreEnuDiagnosticLoading ||
        _arCoreEnuCancellationRequestInFlight) {
      return;
    }

    setState(() {
      _arCoreEnuCancellationRequestInFlight = true;
    });

    try {
      await _arCoreEnuChannel.invokeMethod<Object?>(
        'cancelArCoreEnuDiagnostic',
      );
    } on PlatformException catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'ARCore-to-ENU cancellation failed (${error.code}).';
        });
      }
    } on MissingPluginException {
      if (mounted) {
        setState(() {
          _errorMessage =
              'ARCore-to-ENU channel is unavailable on this platform.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Unexpected error while cancelling ARCore-to-ENU diagnostics.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _arCoreEnuCancellationRequestInFlight = false;
        });
      }
    }
  }

  Future<void> _refreshEvaluationModePreflight() async {
    if (_isBusy) {
      return;
    }

    _lastEvaluationModeOperation = _DiagnosticOperation.evaluationModePreflight;
    setState(() {
      _activeOperation = _DiagnosticOperation.evaluationModePreflight;
      _formattedOutput = null;
      _errorMessage = null;
    });

    EvaluationModePreflight? nextPreflight;
    String? nextOutput;
    String? nextError;
    Map<String, Object?> sanitizedLog = <String, Object?>{
      'success': false,
      'errorCategory': 'unknown_error',
    };
    try {
      final Object? rawSnapshot = await _evaluationModeChannel
          .invokeMethod<Object?>('getEvaluationModePreflight');
      final EvaluationModePreflight parsed =
          EvaluationModePreflight.fromPlatform(rawSnapshot);
      nextPreflight = parsed;
      sanitizedLog = parsed.sanitizedMetadata;
      nextOutput = _jsonEncoder.convert(parsed.sanitizedMetadata);
    } on PlatformException catch (error) {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': error.code,
      };
      nextError = 'Evaluation Mode preflight failed (${error.code}).';
    } on MissingPluginException {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': 'channel_unavailable',
      };
      nextError = 'Evaluation Mode channel is unavailable on this platform.';
    } on FormatException {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': 'invalid_evaluation_mode_preflight',
      };
      nextError = 'Native Evaluation Mode preflight response was invalid.';
    } catch (_) {
      nextError =
          'Unexpected error while refreshing Evaluation Mode preflight.';
    }

    _printSanitizedJsonBlock(
      beginMarker: 'NAVGUARD_EVALUATION_PREFLIGHT_BEGIN',
      endMarker: 'NAVGUARD_EVALUATION_PREFLIGHT_END',
      value: sanitizedLog,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _activeOperation = null;
      _evaluationModePreflight = nextPreflight;
      _formattedOutput = nextOutput;
      _errorMessage = nextError;
    });
  }

  Future<void> _runEvaluationModeDiagnostic() async {
    final GnssAnchor? anchor = _gnssAnchor;
    if (!_canRunEvaluationMode || anchor == null) {
      return;
    }

    _lastEvaluationModeOperation =
        _DiagnosticOperation.evaluationModeDiagnostic;
    setState(() {
      _activeOperation = _DiagnosticOperation.evaluationModeDiagnostic;
      _evaluationModeResult = null;
      _evaluationModeStatus = 'Running';
      _formattedOutput = null;
      _errorMessage = null;
    });

    EvaluationModeDiagnosticResult? nextResult;
    String? nextOutput;
    String? nextError;
    String nextStatus = 'Failed';
    Map<String, Object?> sanitizedLog = <String, Object?>{
      'success': false,
      'errorCategory': 'unknown_error',
    };
    try {
      // The locked anchor is a pre-denial input. Its coordinates are never
      // included in the sanitized log, returned result, or visible UI.
      final Object? rawResult = await _evaluationModeChannel
          .invokeMethod<Object?>(
            'runEvaluationModeDiagnostic',
            <String, Object?>{
              'latitudeDeg': anchor.latitudeDeg,
              'longitudeDeg': anchor.longitudeDeg,
              'altitudeEllipsoidM': anchor.altitudeEllipsoidM,
            },
          );
      final EvaluationModeDiagnosticResult parsed =
          EvaluationModeDiagnosticResult.fromPlatform(rawResult);
      nextResult = parsed;
      sanitizedLog = parsed.sanitizedMetadata;
      nextOutput = _jsonEncoder.convert(parsed.sanitizedMetadata);
      nextStatus = 'Success';
    } on PlatformException catch (error) {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': error.code,
      };
      nextStatus = error.code == 'evaluation_cancelled'
          ? 'Cancelled'
          : 'Failed';
      nextError = 'Evaluation Mode diagnostic failed (${error.code}).';
    } on MissingPluginException {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': 'channel_unavailable',
      };
      nextError = 'Evaluation Mode channel is unavailable on this platform.';
    } on FormatException {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': 'invalid_evaluation_mode_response',
      };
      nextError = 'Native Evaluation Mode result was invalid.';
    } catch (_) {
      nextError = 'Unexpected error while running Evaluation Mode.';
    }

    _printSanitizedJsonBlock(
      beginMarker: 'NAVGUARD_EVALUATION_DIAGNOSTIC_BEGIN',
      endMarker: 'NAVGUARD_EVALUATION_DIAGNOSTIC_END',
      value: sanitizedLog,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _activeOperation = null;
      _evaluationModeResult = nextResult;
      _evaluationModeStatus = nextStatus;
      _formattedOutput = nextOutput;
      _errorMessage = nextError;
    });
  }

  Future<void> _cancelEvaluationModeDiagnostic() async {
    if (!_isEvaluationModeDiagnosticLoading ||
        _evaluationModeCancellationRequestInFlight) {
      return;
    }
    setState(() {
      _evaluationModeCancellationRequestInFlight = true;
    });
    try {
      await _evaluationModeChannel.invokeMethod<Object?>(
        'cancelEvaluationModeDiagnostic',
      );
    } on PlatformException catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Evaluation Mode cancellation failed (${error.code}).';
        });
      }
    } on MissingPluginException {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Evaluation Mode channel is unavailable on this platform.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Unexpected error while cancelling Evaluation Mode.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _evaluationModeCancellationRequestInFlight = false;
        });
      }
    }
  }

  Future<void> _refreshNavguardFusionPreflight() async {
    if (_isBusy) return;
    _lastNavguardFusionOperation = _DiagnosticOperation.navguardFusionPreflight;
    setState(() {
      _activeOperation = _DiagnosticOperation.navguardFusionPreflight;
      _formattedOutput = null;
      _errorMessage = null;
    });

    NavguardFusionPreflight? nextPreflight;
    String? nextOutput;
    String? nextError;
    Map<String, Object?> sanitizedLog = <String, Object?>{
      'success': false,
      'errorCategory': 'unknown_error',
    };
    try {
      final Object? rawSnapshot = await _navguardFusionChannel
          .invokeMethod<Object?>('getNavguardFusionPreflight');
      final NavguardFusionPreflight parsed =
          NavguardFusionPreflight.fromPlatform(rawSnapshot);
      nextPreflight = parsed;
      sanitizedLog = parsed.sanitizedMetadata;
      nextOutput = _jsonEncoder.convert(parsed.sanitizedMetadata);
    } on PlatformException catch (error) {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': error.code,
      };
      nextError = 'NAVGUARD Fusion preflight failed (${error.code}).';
    } on MissingPluginException {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': 'channel_unavailable',
      };
      nextError = 'NAVGUARD Fusion channel is unavailable on this platform.';
    } on FormatException {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': 'invalid_navguard_fusion_preflight',
      };
      nextError = 'Native NAVGUARD Fusion preflight response was invalid.';
    } catch (_) {
      nextError =
          'Unexpected error while refreshing NAVGUARD Fusion preflight.';
    }

    _printSanitizedJsonBlock(
      beginMarker: 'NAVGUARD_FUSION_PREFLIGHT_BEGIN',
      endMarker: 'NAVGUARD_FUSION_PREFLIGHT_END',
      value: sanitizedLog,
    );
    if (!mounted) return;
    setState(() {
      _activeOperation = null;
      _navguardFusionPreflight = nextPreflight;
      _formattedOutput = nextOutput;
      _errorMessage = nextError;
    });
  }

  Future<void> _runNavguardFusionDiagnostic() async {
    final GnssAnchor? anchor = _gnssAnchor;
    if (!_canRunNavguardFusion || anchor == null) return;
    _lastNavguardFusionOperation =
        _DiagnosticOperation.navguardFusionDiagnostic;
    setState(() {
      _activeOperation = _DiagnosticOperation.navguardFusionDiagnostic;
      _navguardFusionResult = null;
      _navguardFusionAlignmentStatus = 'Aligning (2 s hold)';
      _navguardFusionStatus = 'Running';
      _formattedOutput = null;
      _errorMessage = null;
    });

    NavguardFusionDiagnosticResult? nextResult;
    String? nextOutput;
    String? nextError;
    String nextAlignmentStatus = 'Not completed';
    String nextStatus = 'Failed';
    Map<String, Object?> sanitizedLog = <String, Object?>{
      'success': false,
      'errorCategory': 'unknown_error',
    };
    try {
      // The locked anchor is used only as immutable pre-denial declination
      // input. Coordinates never enter sanitized output or visible UI.
      final Object? rawResult = await _navguardFusionChannel
          .invokeMethod<Object?>(
            'runNavguardFusionDiagnostic',
            <String, Object?>{
              'latitudeDeg': anchor.latitudeDeg,
              'longitudeDeg': anchor.longitudeDeg,
              'altitudeEllipsoidM': anchor.altitudeEllipsoidM,
            },
          );
      final NavguardFusionDiagnosticResult parsed =
          NavguardFusionDiagnosticResult.fromPlatform(rawResult);
      nextResult = parsed;
      sanitizedLog = parsed.sanitizedMetadata;
      nextOutput = _jsonEncoder.convert(parsed.sanitizedMetadata);
      nextAlignmentStatus = parsed.alignmentCompleted ? 'Completed' : 'Failed';
      nextStatus = 'Success';
    } on PlatformException catch (error) {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': error.code,
      };
      nextStatus = error.code == 'navguard_fusion_cancelled'
          ? 'Cancelled'
          : 'Failed';
      nextAlignmentStatus = nextStatus == 'Cancelled'
          ? 'Cancelled'
          : 'Not completed';
      nextError = 'NAVGUARD Fusion diagnostic failed (${error.code}).';
    } on MissingPluginException {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': 'channel_unavailable',
      };
      nextError = 'NAVGUARD Fusion channel is unavailable on this platform.';
    } on FormatException {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': 'invalid_navguard_fusion_response',
      };
      nextError = 'Native NAVGUARD Fusion result was invalid.';
    } catch (_) {
      nextError = 'Unexpected error while running NAVGUARD Fusion.';
    }

    _printSanitizedJsonBlock(
      beginMarker: 'NAVGUARD_FUSION_DIAGNOSTIC_BEGIN',
      endMarker: 'NAVGUARD_FUSION_DIAGNOSTIC_END',
      value: sanitizedLog,
    );
    if (!mounted) return;
    setState(() {
      _activeOperation = null;
      _navguardFusionResult = nextResult;
      _navguardFusionAlignmentStatus = nextAlignmentStatus;
      _navguardFusionStatus = nextStatus;
      _formattedOutput = nextOutput;
      _errorMessage = nextError;
    });
  }

  Future<void> _cancelNavguardFusionDiagnostic() async {
    if (!_isNavguardFusionDiagnosticLoading ||
        _navguardFusionCancellationRequestInFlight) {
      return;
    }
    setState(() {
      _navguardFusionCancellationRequestInFlight = true;
    });
    try {
      await _navguardFusionChannel.invokeMethod<Object?>(
        'cancelNavguardFusionDiagnostic',
      );
    } on PlatformException catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'NAVGUARD Fusion cancellation failed (${error.code}).';
        });
      }
    } on MissingPluginException {
      if (mounted) {
        setState(() {
          _errorMessage =
              'NAVGUARD Fusion channel is unavailable on this platform.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Unexpected error while cancelling NAVGUARD Fusion.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _navguardFusionCancellationRequestInFlight = false;
        });
      }
    }
  }

  Future<void> _refreshFullNavguardFlowPreflight() async {
    if (_isBusy) return;
    _lastFullNavguardFlowOperation =
        _DiagnosticOperation.fullNavguardFlowPreflight;
    setState(() {
      _activeOperation = _DiagnosticOperation.fullNavguardFlowPreflight;
      _formattedOutput = null;
      _errorMessage = null;
    });
    FullNavguardFlowPreflight? nextPreflight;
    String? nextOutput;
    String? nextError;
    Map<String, Object?> sanitizedLog = <String, Object?>{
      'success': false,
      'errorCategory': 'unknown_error',
    };
    try {
      final Object? raw = await _fullNavguardFlowChannel.invokeMethod<Object?>(
        'getFullNavguardFlowPreflight',
      );
      final FullNavguardFlowPreflight parsed =
          FullNavguardFlowPreflight.fromPlatform(raw);
      nextPreflight = parsed;
      sanitizedLog = _fullFlowPreflightMetadata(parsed);
      nextOutput = _jsonEncoder.convert(sanitizedLog);
    } on PlatformException catch (error) {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': error.code,
      };
      nextError = 'Full NAVGUARD Flow preflight failed (${error.code}).';
    } on MissingPluginException {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': 'channel_unavailable',
      };
      nextError = 'Full NAVGUARD Flow channel is unavailable.';
    } on FormatException {
      nextError = 'Native Full NAVGUARD Flow preflight response was invalid.';
    } catch (_) {
      nextError = 'Unexpected error while refreshing Full NAVGUARD Flow.';
    }
    _printSanitizedJsonBlock(
      beginMarker: 'FULL_NAVGUARD_FLOW_PREFLIGHT_BEGIN',
      endMarker: 'FULL_NAVGUARD_FLOW_PREFLIGHT_END',
      value: sanitizedLog,
    );
    if (!mounted) return;
    setState(() {
      _activeOperation = null;
      _fullNavguardFlowPreflight = nextPreflight;
      if (nextPreflight != null) {
        _fullNavguardFlowState = nextPreflight.currentState;
      }
      _formattedOutput = nextOutput;
      _errorMessage = nextError;
    });
  }

  Map<String, Object?> _fullFlowPreflightMetadata(
    FullNavguardFlowPreflight value,
  ) {
    return <String, Object?>{
      'schemaVersion': 1,
      'snapshotKind': 'full_navguard_flow_preflight',
      'gpsProviderAvailable': value.gpsProviderAvailable,
      'gpsProviderEnabled': value.gpsProviderEnabled,
      'fineLocationPermissionGranted': value.fineLocationPermissionGranted,
      'rotationVectorAvailable': value.rotationVectorAvailable,
      'stepDetectorAvailable': value.stepDetectorAvailable,
      'activityRecognitionPermissionGranted':
          value.activityRecognitionPermissionGranted,
      'arCoreSupported': value.arCoreSupported,
      'arCoreInstalled': value.arCoreInstalled,
      'cameraPermissionGranted': value.cameraPermissionGranted,
      'diagnosticRunning': value.diagnosticRunning,
      'nativeReady': value.nativeReady,
      'currentState': value.currentState.wireValue,
    };
  }

  Future<void> _pollFullNavguardFlowState() async {
    if (!_isFullNavguardFlowDiagnosticLoading ||
        _fullNavguardFlowPollInFlight) {
      return;
    }
    _fullNavguardFlowPollInFlight = true;
    try {
      final Object? raw = await _fullNavguardFlowChannel.invokeMethod<Object?>(
        'getFullNavguardFlowPreflight',
      );
      final FullNavguardFlowPreflight parsed =
          FullNavguardFlowPreflight.fromPlatform(raw);
      if (mounted && _isFullNavguardFlowDiagnosticLoading) {
        setState(() {
          _fullNavguardFlowPreflight = parsed;
          _fullNavguardFlowState = parsed.currentState;
        });
      }
    } catch (_) {
      // Polling is display-only. The authoritative run future reports errors.
    } finally {
      _fullNavguardFlowPollInFlight = false;
    }
  }

  Future<void> _runFullNavguardFlowDiagnostic() async {
    final GnssAnchor? anchor = _gnssAnchor;
    if (!_canRunFullNavguardFlow || anchor == null) return;
    _lastFullNavguardFlowOperation =
        _DiagnosticOperation.fullNavguardFlowDiagnostic;
    setState(() {
      _activeOperation = _DiagnosticOperation.fullNavguardFlowDiagnostic;
      _fullNavguardFlowResult = null;
      _fullNavguardFlowState = FullNavguardFlowState.acquiringGnss;
      _formattedOutput = null;
      _errorMessage = null;
    });
    _fullNavguardFlowStatePollTimer?.cancel();
    _fullNavguardFlowStatePollTimer = Timer.periodic(
      const Duration(milliseconds: 400),
      (_) => _pollFullNavguardFlowState(),
    );

    FullNavguardFlowDiagnosticResult? nextResult;
    FullNavguardFlowState nextState = FullNavguardFlowState.failed;
    String? nextOutput;
    String? nextError;
    Map<String, Object?> sanitizedLog = <String, Object?>{
      'success': false,
      'errorCategory': 'unknown_error',
    };
    try {
      final Object? raw = await _fullNavguardFlowChannel.invokeMethod<Object?>(
        'runFullNavguardFlowDiagnostic',
        <String, Object?>{
          'latitudeDeg': anchor.latitudeDeg,
          'longitudeDeg': anchor.longitudeDeg,
          'altitudeEllipsoidM': anchor.altitudeEllipsoidM,
        },
      );
      final FullNavguardFlowDiagnosticResult parsed =
          FullNavguardFlowDiagnosticResult.fromPlatform(raw);
      nextResult = parsed;
      nextState = parsed.finalState;
      sanitizedLog = parsed.sanitizedMetadata;
      nextOutput = _jsonEncoder.convert(parsed.sanitizedMetadata);
    } on PlatformException catch (error) {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': error.code,
      };
      nextState = error.code == 'full_navguard_flow_cancelled'
          ? FullNavguardFlowState.cancelled
          : FullNavguardFlowState.failed;
      nextError = 'Full NAVGUARD Flow failed (${error.code}).';
    } on MissingPluginException {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': 'channel_unavailable',
      };
      nextError = 'Full NAVGUARD Flow channel is unavailable.';
    } on FormatException {
      nextError = 'Native Full NAVGUARD Flow result was invalid.';
    } catch (_) {
      nextError = 'Unexpected error while running Full NAVGUARD Flow.';
    } finally {
      _fullNavguardFlowStatePollTimer?.cancel();
      _fullNavguardFlowStatePollTimer = null;
    }
    _printSanitizedJsonBlock(
      beginMarker: 'FULL_NAVGUARD_FLOW_DIAGNOSTIC_BEGIN',
      endMarker: 'FULL_NAVGUARD_FLOW_DIAGNOSTIC_END',
      value: sanitizedLog,
    );
    if (!mounted) return;
    setState(() {
      _activeOperation = null;
      _fullNavguardFlowResult = nextResult;
      _fullNavguardFlowState = nextState;
      _formattedOutput = nextOutput;
      _errorMessage = nextError;
    });
  }

  Future<void> _cancelFullNavguardFlowDiagnostic() async {
    if (!_isFullNavguardFlowDiagnosticLoading ||
        _fullNavguardFlowCancellationRequestInFlight) {
      return;
    }
    setState(() {
      _fullNavguardFlowCancellationRequestInFlight = true;
    });
    try {
      await _fullNavguardFlowChannel.invokeMethod<Object?>(
        'cancelFullNavguardFlowDiagnostic',
      );
    } on PlatformException catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Full NAVGUARD Flow cancellation failed (${error.code}).';
        });
      }
    } on MissingPluginException {
      if (mounted) {
        setState(() {
          _errorMessage = 'Full NAVGUARD Flow channel is unavailable.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Unexpected error while cancelling the full flow.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _fullNavguardFlowCancellationRequestInFlight = false;
        });
      }
    }
  }

  Future<void> _refreshNavguardBenchmarkPreflight() async {
    if (_isBusy) return;
    _lastNavguardBenchmarkOperation =
        _DiagnosticOperation.navguardBenchmarkPreflight;
    setState(() {
      _activeOperation = _DiagnosticOperation.navguardBenchmarkPreflight;
      _formattedOutput = null;
      _errorMessage = null;
    });
    NavguardBenchmarkPreflight? nextPreflight;
    String? nextOutput;
    String? nextError;
    Map<String, Object?> sanitizedLog = <String, Object?>{
      'success': false,
      'errorCategory': 'unknown_error',
    };
    try {
      final Object? raw = await _navguardBenchmarkChannel.invokeMethod<Object?>(
        'getNavguardBenchmarkPreflight',
      );
      final NavguardBenchmarkPreflight parsed =
          NavguardBenchmarkPreflight.fromPlatform(raw);
      nextPreflight = parsed;
      sanitizedLog = _benchmarkPreflightMetadata(parsed);
      nextOutput = _jsonEncoder.convert(sanitizedLog);
    } on PlatformException catch (error) {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': error.code,
      };
      nextError = 'NAVGUARD Benchmark preflight failed (${error.code}).';
    } on MissingPluginException {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': 'channel_unavailable',
      };
      nextError = 'NAVGUARD Benchmark channel is unavailable.';
    } on FormatException {
      nextError = 'Native NAVGUARD Benchmark preflight response was invalid.';
    } catch (_) {
      nextError = 'Unexpected error while refreshing benchmark preflight.';
    }
    _printSanitizedJsonBlock(
      beginMarker: 'NAVGUARD_BENCHMARK_PREFLIGHT_BEGIN',
      endMarker: 'NAVGUARD_BENCHMARK_PREFLIGHT_END',
      value: sanitizedLog,
    );
    if (!mounted) return;
    setState(() {
      _activeOperation = null;
      _navguardBenchmarkPreflight = nextPreflight;
      if (nextPreflight != null) {
        _navguardBenchmarkPhase = nextPreflight.currentPhase;
      }
      _formattedOutput = nextOutput;
      _errorMessage = nextError;
    });
  }

  Map<String, Object?> _benchmarkPreflightMetadata(
    NavguardBenchmarkPreflight value,
  ) {
    return <String, Object?>{
      'schemaVersion': 1,
      'snapshotKind': 'navguard_benchmark_preflight',
      'gpsProviderAvailable': value.gpsProviderAvailable,
      'gpsProviderEnabled': value.gpsProviderEnabled,
      'fineLocationPermissionGranted': value.fineLocationPermissionGranted,
      'rotationVectorAvailable': value.rotationVectorAvailable,
      'stepDetectorAvailable': value.stepDetectorAvailable,
      'activityRecognitionPermissionGranted':
          value.activityRecognitionPermissionGranted,
      'arCoreSupported': value.arCoreSupported,
      'arCoreInstalled': value.arCoreInstalled,
      'cameraPermissionGranted': value.cameraPermissionGranted,
      'diagnosticRunning': value.diagnosticRunning,
      'nativeReady': value.nativeReady,
      'currentPhase': value.currentPhase.wireValue,
    };
  }

  Future<void> _pollNavguardBenchmarkPhase() async {
    if (!_isNavguardBenchmarkDiagnosticLoading ||
        _navguardBenchmarkPollInFlight) {
      return;
    }
    _navguardBenchmarkPollInFlight = true;
    try {
      final Object? raw = await _navguardBenchmarkChannel.invokeMethod<Object?>(
        'getNavguardBenchmarkPreflight',
      );
      final NavguardBenchmarkPreflight parsed =
          NavguardBenchmarkPreflight.fromPlatform(raw);
      if (mounted && _isNavguardBenchmarkDiagnosticLoading) {
        setState(() {
          _navguardBenchmarkPreflight = parsed;
          _navguardBenchmarkPhase = parsed.currentPhase;
        });
      }
    } catch (_) {
      // Polling is display-only. The authoritative run future reports errors.
    } finally {
      _navguardBenchmarkPollInFlight = false;
    }
  }

  Future<void> _runNavguardBenchmarkDiagnostic() async {
    final GnssAnchor? anchor = _gnssAnchor;
    if (!_canRunNavguardBenchmark || anchor == null) return;
    _lastNavguardBenchmarkOperation =
        _DiagnosticOperation.navguardBenchmarkDiagnostic;
    setState(() {
      _activeOperation = _DiagnosticOperation.navguardBenchmarkDiagnostic;
      _navguardBenchmarkResult = null;
      _navguardBenchmarkPhase = NavguardBenchmarkPhase.preparing;
      _formattedOutput = null;
      _errorMessage = null;
    });
    _navguardBenchmarkPollTimer?.cancel();
    _navguardBenchmarkPollTimer = Timer.periodic(
      const Duration(milliseconds: 400),
      (_) => _pollNavguardBenchmarkPhase(),
    );

    NavguardBenchmarkDiagnosticResult? nextResult;
    NavguardBenchmarkPhase nextPhase = NavguardBenchmarkPhase.failed;
    String? nextOutput;
    String? nextError;
    Map<String, Object?> sanitizedLog = <String, Object?>{
      'success': false,
      'errorCategory': 'unknown_error',
    };
    try {
      final Object? raw = await _navguardBenchmarkChannel.invokeMethod<Object?>(
        'runNavguardBenchmarkDiagnostic',
        <String, Object?>{
          'latitudeDeg': anchor.latitudeDeg,
          'longitudeDeg': anchor.longitudeDeg,
          'altitudeEllipsoidM': anchor.altitudeEllipsoidM,
        },
      );
      final NavguardBenchmarkDiagnosticResult parsed =
          NavguardBenchmarkDiagnosticResult.fromPlatform(raw);
      nextResult = parsed;
      nextPhase = NavguardBenchmarkPhase.complete;
      sanitizedLog = parsed.sanitizedMetadata;
      nextOutput = _jsonEncoder.convert(parsed.sanitizedMetadata);
    } on PlatformException catch (error) {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': error.code,
      };
      nextPhase = error.code == 'navguard_benchmark_cancelled'
          ? NavguardBenchmarkPhase.cancelled
          : NavguardBenchmarkPhase.failed;
      nextError = 'NAVGUARD Benchmark failed (${error.code}).';
    } on MissingPluginException {
      sanitizedLog = <String, Object?>{
        'success': false,
        'errorCategory': 'channel_unavailable',
      };
      nextError = 'NAVGUARD Benchmark channel is unavailable.';
    } on FormatException {
      nextError = 'Native NAVGUARD Benchmark result was invalid.';
    } catch (_) {
      nextError = 'Unexpected error while running NAVGUARD Benchmark.';
    } finally {
      _navguardBenchmarkPollTimer?.cancel();
      _navguardBenchmarkPollTimer = null;
    }
    _printSanitizedJsonBlock(
      beginMarker: 'NAVGUARD_BENCHMARK_BEGIN',
      endMarker: 'NAVGUARD_BENCHMARK_END',
      value: sanitizedLog,
    );
    if (!mounted) return;
    setState(() {
      _activeOperation = null;
      _navguardBenchmarkResult = nextResult;
      _navguardBenchmarkPhase = nextPhase;
      _formattedOutput = nextOutput;
      _errorMessage = nextError;
    });
  }

  Future<void> _cancelNavguardBenchmarkDiagnostic() async {
    if (!_isNavguardBenchmarkDiagnosticLoading ||
        _navguardBenchmarkCancellationRequestInFlight) {
      return;
    }
    setState(() {
      _navguardBenchmarkCancellationRequestInFlight = true;
    });
    try {
      await _navguardBenchmarkChannel.invokeMethod<Object?>(
        'cancelNavguardBenchmarkDiagnostic',
      );
    } on PlatformException catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'NAVGUARD Benchmark cancellation failed (${error.code}).';
        });
      }
    } on MissingPluginException {
      if (mounted) {
        setState(() {
          _errorMessage = 'NAVGUARD Benchmark channel is unavailable.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Unexpected error while cancelling the benchmark.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _navguardBenchmarkCancellationRequestInFlight = false;
        });
      }
    }
  }

  Map<String, Object?> _accuracyV2AnchorArguments({
    String? developmentScenario,
  }) {
    final GnssAnchor? anchor =
        _gnssAnchorState == GnssAnchorRuntimeState.anchorLocked
        ? _gnssAnchor
        : null;
    return <String, Object?>{
      'anchorAvailable': anchor != null,
      'latitudeDeg': anchor?.latitudeDeg,
      'longitudeDeg': anchor?.longitudeDeg,
      'altitudeEllipsoidM': anchor?.altitudeEllipsoidM,
      if (developmentScenario != null)
        'developmentScenario': developmentScenario,
    };
  }

  Future<void> _refreshAccuracyV2Preflight() async {
    if (_isBusy) return;
    _lastAccuracyV2Operation = _DiagnosticOperation.accuracyV2Preflight;
    setState(() {
      _activeOperation = _DiagnosticOperation.accuracyV2Preflight;
      _errorMessage = null;
      _formattedOutput = null;
    });
    AccuracyV2Preflight? preflight;
    CalibrationProfile? profile;
    String? errorMessage;
    try {
      final Object? rawPreflight = await _accuracyV2Channel
          .invokeMethod<Object?>(
            'getAccuracyV2Preflight',
            _accuracyV2AnchorArguments(),
          );
      final Object? rawProfile = await _accuracyV2Channel.invokeMethod<Object?>(
        'getCalibrationProfile',
      );
      preflight = AccuracyV2Preflight.fromPlatform(rawPreflight);
      profile = CalibrationProfile.fromPlatform(rawProfile);
    } on PlatformException catch (error) {
      errorMessage = 'Accuracy v2 preflight failed (${error.code}).';
    } on MissingPluginException {
      errorMessage = 'Accuracy v2 native channel is unavailable.';
    } on FormatException {
      errorMessage = 'Native Accuracy v2 preflight response was invalid.';
    } catch (_) {
      errorMessage = 'Unexpected error while refreshing Accuracy v2.';
    }
    if (!mounted) return;
    setState(() {
      _activeOperation = null;
      _accuracyV2Preflight = preflight;
      _accuracyV2Profile = profile;
      _formattedOutput = preflight == null || profile == null
          ? null
          : _jsonEncoder.convert(<String, Object?>{
              'preflight': preflight.sanitizedMetadata,
              'calibrationProfile': profile.sanitizedMetadata,
            });
      _errorMessage = errorMessage;
    });
  }

  Future<void> _runAccuracyV2Calibration() async {
    if (!_canRunAccuracyV2) return;
    _lastAccuracyV2Operation = _DiagnosticOperation.accuracyV2Calibration;
    setState(() {
      _activeOperation = _DiagnosticOperation.accuracyV2Calibration;
      _accuracyV2CalibrationResult = null;
      _formattedOutput = null;
      _errorMessage = null;
    });
    _startAccuracyV2CalibrationProgress();
    CalibrationResult? result;
    CalibrationProfile? profile;
    String? errorMessage;
    try {
      final Object? raw = await _accuracyV2Channel.invokeMethod<Object?>(
        'runAccuracyV2Calibration',
        _accuracyV2AnchorArguments(),
      );
      result = CalibrationResult.fromPlatform(raw);
      profile = CalibrationProfile.fromPlatform(
        await _accuracyV2Channel.invokeMethod<Object?>('getCalibrationProfile'),
      );
    } on PlatformException catch (error) {
      errorMessage = 'Accuracy v2 calibration failed (${error.code}).';
    } on MissingPluginException {
      errorMessage = 'Accuracy v2 native channel is unavailable.';
    } on FormatException {
      errorMessage = 'Native Accuracy v2 calibration result was invalid.';
    } catch (_) {
      errorMessage = 'Unexpected error while running Accuracy v2 calibration.';
    }
    _accuracyV2CalibrationProgressTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _activeOperation = null;
      _accuracyV2CalibrationResult = result;
      _accuracyV2Profile = profile ?? _accuracyV2Profile;
      _accuracyV2FinalDrainRemainingSeconds = null;
      _formattedOutput = result == null
          ? null
          : _jsonEncoder.convert(result.sanitizedMetadata);
      _errorMessage = errorMessage;
    });
  }

  Future<void> _runAccuracyV2DevelopmentBenchmark() async {
    final String? developmentScenario = _accuracyV2DevelopmentScenario;
    if (!_canRunAccuracyV2 || developmentScenario == null) return;
    _lastAccuracyV2Operation =
        _DiagnosticOperation.accuracyV2DevelopmentBenchmark;
    setState(() {
      _activeOperation = _DiagnosticOperation.accuracyV2DevelopmentBenchmark;
      _accuracyV2BenchmarkResult = null;
      _accuracyV2GnssFailureDiagnostics = null;
      _accuracyV2BenchmarkPhase = 'GNSS_STABILIZATION';
      _accuracyV2BenchmarkDrainRemainingSeconds = null;
      _formattedOutput = null;
      _errorMessage = null;
    });
    _startAccuracyV2BenchmarkProgress();
    AccuracyV2DevelopmentBenchmarkResult? result;
    String? errorMessage;
    try {
      final Object? raw = await _accuracyV2Channel.invokeMethod<Object?>(
        'runAccuracyV2DevelopmentBenchmark',
        _accuracyV2AnchorArguments(developmentScenario: developmentScenario),
      );
      result = AccuracyV2DevelopmentBenchmarkResult.fromPlatform(raw);
    } on PlatformException catch (error) {
      if (error.code ==
          'navguard_accuracy_v2_gnss_stabilization_insufficient') {
        try {
          _accuracyV2GnssFailureDiagnostics =
              AccuracyV2GnssStabilizationDiagnostics.fromPlatformErrorDetails(
                error.details,
              );
        } on FormatException {
          _accuracyV2GnssFailureDiagnostics = null;
        }
        final AccuracyV2GnssStabilizationDiagnostics? diagnostics =
            _accuracyV2GnssFailureDiagnostics;
        errorMessage = diagnostics == null
            ? 'Not enough stable GNSS fixes were available.'
            : 'Not enough stable GNSS fixes were available. '
                  'Accepted: ${diagnostics.acceptedFixCount} / minimum ${diagnostics.minimumFixCount}.';
      } else {
        errorMessage =
            'Accuracy v2 development benchmark failed (${error.code}).';
      }
    } on MissingPluginException {
      errorMessage = 'Accuracy v2 native channel is unavailable.';
    } on FormatException {
      errorMessage = 'Native Accuracy v2 benchmark result was invalid.';
    } catch (_) {
      errorMessage =
          'Unexpected error while running the Accuracy v2 benchmark.';
    }
    _accuracyV2BenchmarkProgressTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _activeOperation = null;
      _accuracyV2BenchmarkPhase = 'IDLE';
      _accuracyV2BenchmarkDrainRemainingSeconds = null;
      _accuracyV2BenchmarkResult = result;
      _formattedOutput = result == null
          ? _accuracyV2GnssFailureDiagnostics == null
                ? null
                : _jsonEncoder.convert(
                    _accuracyV2GnssFailureDiagnostics!.sanitizedMetadata,
                  )
          : _jsonEncoder.convert(result.sanitizedMetadata);
      _errorMessage = errorMessage;
    });
  }

  void _startAccuracyV2CalibrationProgress() {
    _accuracyV2CalibrationProgressTimer?.cancel();
    final DateTime startedAt = DateTime.now();
    _accuracyV2FinalDrainRemainingSeconds = null;
    _accuracyV2CalibrationProgressTimer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (!mounted ||
            _activeOperation != _DiagnosticOperation.accuracyV2Calibration) {
          timer.cancel();
          return;
        }
        final int elapsedSeconds = DateTime.now()
            .difference(startedAt)
            .inSeconds;
        final int? remaining = elapsedSeconds < 48
            ? null
            : math.max(0, 60 - elapsedSeconds);
        setState(() => _accuracyV2FinalDrainRemainingSeconds = remaining);
        if (elapsedSeconds >= 60) timer.cancel();
      },
    );
  }

  void _startAccuracyV2BenchmarkProgress() {
    _accuracyV2BenchmarkProgressTimer?.cancel();
    unawaited(_pollAccuracyV2BenchmarkProgress());
    _accuracyV2BenchmarkProgressTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => unawaited(_pollAccuracyV2BenchmarkProgress()),
    );
  }

  Future<void> _pollAccuracyV2BenchmarkProgress() async {
    if (_accuracyV2BenchmarkPollInFlight ||
        _activeOperation !=
            _DiagnosticOperation.accuracyV2DevelopmentBenchmark) {
      return;
    }
    _accuracyV2BenchmarkPollInFlight = true;
    try {
      final Object? raw = await _accuracyV2Channel.invokeMethod<Object?>(
        'getAccuracyV2OperationStatus',
      );
      if (raw is! Map<Object?, Object?> ||
          raw['schemaVersion'] != 1 ||
          raw['snapshotKind'] != 'navguard_accuracy_v2_operation_status') {
        return;
      }
      final Object? rawPhase = raw['phase'];
      final Object? rawRemaining = raw['finalDrainRemainingSeconds'];
      if (rawPhase is! String ||
          !<String>{
            'GNSS_STABILIZATION',
            'BENCHMARK_FORMAL_WINDOW',
            'BENCHMARK_FINAL_DRAIN',
            'FINALIZING',
          }.contains(rawPhase) ||
          (rawRemaining != null &&
              (rawRemaining is! num ||
                  !rawRemaining.isFinite ||
                  rawRemaining < 0 ||
                  rawRemaining.toInt() != rawRemaining))) {
        return;
      }
      if (!mounted ||
          _activeOperation !=
              _DiagnosticOperation.accuracyV2DevelopmentBenchmark) {
        return;
      }
      final int? remainingSeconds = rawRemaining is num
          ? rawRemaining.toInt()
          : null;
      setState(() {
        _accuracyV2BenchmarkPhase = rawPhase;
        _accuracyV2BenchmarkDrainRemainingSeconds = remainingSeconds;
      });
    } on PlatformException {
      // The benchmark result call remains authoritative; progress is best-effort.
    } on MissingPluginException {
      // Older native builds simply retain the preparation label.
    } finally {
      _accuracyV2BenchmarkPollInFlight = false;
    }
  }

  Future<void> _resetAccuracyV2Profile() async {
    if (_isBusy) return;
    _lastAccuracyV2Operation = _DiagnosticOperation.accuracyV2Reset;
    setState(() {
      _activeOperation = _DiagnosticOperation.accuracyV2Reset;
      _formattedOutput = null;
      _errorMessage = null;
    });
    CalibrationProfile? profile;
    String? errorMessage;
    try {
      profile = CalibrationProfile.fromPlatform(
        await _accuracyV2Channel.invokeMethod<Object?>(
          'resetAccuracyV2Calibration',
        ),
      );
    } on PlatformException catch (error) {
      errorMessage = 'Accuracy v2 profile reset failed (${error.code}).';
    } on MissingPluginException {
      errorMessage = 'Accuracy v2 native channel is unavailable.';
    } on FormatException {
      errorMessage = 'Native Accuracy v2 reset response was invalid.';
    } catch (_) {
      errorMessage =
          'Unexpected error while resetting the Accuracy v2 profile.';
    }
    if (!mounted) return;
    setState(() {
      _activeOperation = null;
      _accuracyV2Profile = profile ?? _accuracyV2Profile;
      _accuracyV2CalibrationResult = null;
      _formattedOutput = profile == null
          ? null
          : _jsonEncoder.convert(profile.sanitizedMetadata);
      _errorMessage = errorMessage;
    });
  }

  Future<void> _runDiagnosticRequest({
    required MethodChannel channel,
    required _DiagnosticOperation operation,
    required String methodName,
    required String operationLabel,
    required String invalidResponseMessage,
    required String beginMarker,
    required String endMarker,
    Map<String, Object?>? arguments,
    bool updateGnssState = false,
    bool updateGnssAnchorPreflight = false,
    bool updateHeadingPreflight = false,
    bool updateStepPreflight = false,
    bool updateArCoreState = false,
  }) async {
    if (_isBusy) {
      return;
    }

    setState(() {
      _activeOperation = operation;
      _formattedOutput = null;
      _errorMessage = null;
    });

    String? nextOutput;
    String? nextError;
    _GnssDisplayState? nextGnssState;
    GnssAnchorPreflight? nextGnssAnchorPreflight;
    HeadingFoundationPreflight? nextHeadingPreflight;
    StepEventPreflight? nextStepPreflight;
    _ArCoreDisplayState? nextArCoreState;

    try {
      final Object? rawSnapshot = await channel.invokeMethod<Object?>(
        methodName,
        arguments,
      );

      if (rawSnapshot is! Map) {
        throw FormatException(invalidResponseMessage);
      }

      if (updateGnssState) {
        nextGnssState = _GnssDisplayState.fromSnapshot(rawSnapshot);
      }

      if (updateGnssAnchorPreflight) {
        nextGnssAnchorPreflight = GnssAnchorPreflight.fromPlatform(rawSnapshot);
      }

      if (updateHeadingPreflight) {
        nextHeadingPreflight = HeadingFoundationPreflight.fromPlatform(
          rawSnapshot,
        );
      }

      if (updateStepPreflight) {
        nextStepPreflight = StepEventPreflight.fromPlatform(rawSnapshot);
      }

      if (updateArCoreState) {
        nextArCoreState = _ArCoreDisplayState.fromSnapshot(rawSnapshot);
      }

      final Object? normalizedSnapshot = _normalizeForJson(rawSnapshot);
      final String formattedJson = _jsonEncoder.convert(normalizedSnapshot);

      debugPrint(beginMarker);
      for (final String line in formattedJson.split('\n')) {
        debugPrint(line);
      }
      debugPrint(endMarker);

      nextOutput = formattedJson;
    } on PlatformException catch (error) {
      final String? nativeMessage = error.message;

      if (nativeMessage == null || nativeMessage.isEmpty) {
        nextError = '$operationLabel failed (${error.code}).';
      } else {
        nextError = '$operationLabel failed (${error.code}): $nativeMessage';
      }
    } on MissingPluginException {
      nextError = 'Runtime diagnostic channel is unavailable on this platform.';
    } on FormatException catch (error) {
      nextError = 'Invalid diagnostic response: ${error.message}';
    } catch (_) {
      nextError = 'Unexpected error while running the runtime diagnostic.';
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _activeOperation = null;
      _formattedOutput = nextOutput;
      _errorMessage = nextError;

      if (nextGnssState != null) {
        _preciseLocationPermission = nextGnssState.precisePermission;
        _gpsProvider = nextGnssState.gpsProvider;
        _locationServices = nextGnssState.locationServices;
        _canRunFormalGnssDiagnostic = nextGnssState.canRunFormalDiagnostic;
      }

      if (nextGnssAnchorPreflight != null) {
        _gnssAnchorPreflight = nextGnssAnchorPreflight;
      }

      if (nextHeadingPreflight != null) {
        _headingPreflight = nextHeadingPreflight;
      }

      if (nextStepPreflight != null) {
        _stepPreflight = nextStepPreflight;
      }

      if (nextArCoreState != null) {
        _cameraPermission = nextArCoreState.cameraPermission;
        _arCoreAvailability = nextArCoreState.availability;
        _arCoreReady = nextArCoreState.ready;
        _canRunFormalArCoreDiagnostic = nextArCoreState.canRunFormalDiagnostic;
      }
    });
  }

  Object? _normalizeForJson(Object? value) {
    if (value is Map) {
      return value.map<String, Object?>(
        (Object? key, Object? nestedValue) =>
            MapEntry(key.toString(), _normalizeForJson(nestedValue)),
      );
    }

    if (value is List) {
      return value.map<Object?>(_normalizeForJson).toList(growable: false);
    }

    return value;
  }

  void _printSanitizedJsonBlock({
    required String beginMarker,
    required String endMarker,
    required Map<String, Object?> value,
  }) {
    final String formattedJson = _jsonEncoder.convert(_normalizeForJson(value));

    debugPrint(beginMarker);
    for (final String line in formattedJson.split('\n')) {
      debugPrint(line);
    }
    debugPrint(endMarker);
  }

  @override
  void dispose() {
    _fullNavguardFlowStatePollTimer?.cancel();
    _navguardBenchmarkPollTimer?.cancel();
    _accuracyV2CalibrationProgressTimer?.cancel();
    _accuracyV2BenchmarkProgressTimer?.cancel();
    super.dispose();
  }

  Future<void> _openLiveNavguardDemo() async {
    final GnssAnchor? anchor =
        _gnssAnchorState == GnssAnchorRuntimeState.anchorLocked
        ? _gnssAnchor
        : null;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => LiveNavguardMapScreen(
          anchor: anchor == null
              ? null
              : LiveNavguardAnchor(
                  latitudeDeg: anchor.latitudeDeg,
                  longitudeDeg: anchor.longitudeDeg,
                  altitudeEllipsoidM: anchor.altitudeEllipsoidM,
                ),
          platform: widget.liveDemoPlatform,
          enableMapTiles: widget.enableLiveMapTiles,
        ),
      ),
    );
    if (mounted && anchor == null && widget.diagnosticsAccessEnabled) {
      setState(() => _activeDashboardModule = _DashboardModule.gnssAnchor);
    }
  }

  Future<void> _openAiDatasetCapture() async {
    if (!widget.diagnosticsAccessEnabled) return;
    final GnssAnchor? anchor =
        _gnssAnchorState == GnssAnchorRuntimeState.anchorLocked
        ? _gnssAnchor
        : null;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => NavguardAiDatasetScreen(
          anchorLatitudeDeg: anchor?.latitudeDeg,
          anchorLongitudeDeg: anchor?.longitudeDeg,
          anchorAltitudeEllipsoidM: anchor?.altitudeEllipsoidM,
          platform: widget.aiPlatform,
        ),
      ),
    );
  }

  List<Map<String, Object?>> get _sensorInventoryRecords {
    final Object? rawSensors = _sensorInventorySnapshot?['sensors'];
    if (rawSensors is! List) return const <Map<String, Object?>>[];

    return <Map<String, Object?>>[
      for (final Object? rawSensor in rawSensors)
        if (rawSensor is Map)
          rawSensor.map<String, Object?>(
            (Object? key, Object? value) => MapEntry(key.toString(), value),
          ),
    ];
  }

  bool? get _requiredSensorAvailability {
    if (_sensorInventorySnapshot == null) return null;

    const Set<String> requiredTypes = <String>{
      'TYPE_ACCELEROMETER',
      'TYPE_GYROSCOPE',
      'TYPE_ROTATION_VECTOR',
      'TYPE_STEP_DETECTOR',
    };
    final Map<String, bool?> availability = <String, bool?>{
      for (final Map<String, Object?> record in _sensorInventoryRecords)
        if (record['requestedType'] is String)
          record['requestedType']! as String: record['available'] as bool?,
    };

    if (!requiredTypes.every(availability.containsKey)) return null;
    return requiredTypes.every((String type) => availability[type] == true);
  }

  _ReadinessStatus get _sensorDiagnosticStatus {
    if (_isInventoryLoading || _isSensorTimingLoading) {
      return const _ReadinessStatus('Running', _ReadinessKind.busy);
    }
    if (_lastSensorOperation != null && _errorMessage != null) {
      return const _ReadinessStatus('Error', _ReadinessKind.error);
    }
    if (_requiredSensorAvailability == false ||
        _sensorTimingSnapshot?['validTimingSummary'] == false) {
      return const _ReadinessStatus(
        'Action required',
        _ReadinessKind.attention,
      );
    }
    if (_requiredSensorAvailability == true ||
        _sensorTimingSnapshot?['validTimingSummary'] == true) {
      return const _ReadinessStatus('Ready', _ReadinessKind.ready);
    }
    return const _ReadinessStatus('Not checked', _ReadinessKind.neutral);
  }

  String _sensorTypeLabel(Object? rawType) {
    final String value = rawType?.toString() ?? '';
    final String withoutPrefix = value.startsWith('TYPE_')
        ? value.substring(5)
        : value;
    if (withoutPrefix.isEmpty) return 'Unknown sensor';

    return withoutPrefix
        .split('_')
        .where((String word) => word.isNotEmpty)
        .map(
          (String word) =>
              '${word.substring(0, 1)}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String? _sensorFact(String label, Object? value, {String suffix = ''}) {
    if (value == null) return null;
    final String rendered = value is double
        ? value.toStringAsFixed(3)
        : value.toString();
    return '$label: $rendered$suffix';
  }

  String _formatFrequency(Object? value) {
    if (value is! num) return 'Not available';
    return '${value.toDouble().toStringAsFixed(1)} Hz';
  }

  String _formatNanosecondsAsMilliseconds(Object? value) {
    if (value is! num) return 'Not available';
    return '${(value.toDouble() / 1000000.0).toStringAsFixed(2)} ms';
  }

  _ReadinessStatus _sensorRecordStatus(Map<String, Object?> record) {
    if (record['platformApiSupported'] == false) {
      return const _ReadinessStatus(
        'API unsupported',
        _ReadinessKind.attention,
      );
    }
    return switch (record['available']) {
      true => const _ReadinessStatus('Available', _ReadinessKind.ready),
      false => const _ReadinessStatus(
        'Unavailable',
        _ReadinessKind.unavailable,
      ),
      _ => const _ReadinessStatus('Unknown', _ReadinessKind.neutral),
    };
  }

  Widget _buildSensorsDiagnosticModule(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final List<Map<String, Object?>> records = _sensorInventoryRecords;
    final int availableCount = records
        .where((Map<String, Object?> record) => record['available'] == true)
        .length;
    final int unavailableCount = records
        .where(
          (Map<String, Object?> record) =>
              record['platformApiSupported'] != false &&
              record['available'] == false,
        )
        .length;
    final int unsupportedCount = records
        .where(
          (Map<String, Object?> record) =>
              record['platformApiSupported'] == false,
        )
        .length;
    final Map<String, Object?>? timing = _sensorTimingSnapshot;
    final bool inventoryError =
        _lastSensorOperation == _DiagnosticOperation.inventory &&
        _errorMessage != null;
    final bool timingError =
        _lastSensorOperation == _DiagnosticOperation.sensorTiming &&
        _errorMessage != null;

    return Column(
      key: const Key('sensors-diagnostic-content'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _DashboardCard(
          emphasis: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _IconBadge(
                    icon: Icons.sensors_outlined,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Sensors',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Device capability inventory and live sensor timing diagnostics.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _DiagnosticStatusChip(status: _sensorDiagnosticStatus),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionEyebrow('SENSOR INVENTORY'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _DiagnosticSectionHeading(
                icon: Icons.memory_outlined,
                title: 'Sensor Capability',
                description:
                    'Capability metadata from Android SensorManager. Availability does not imply calibrated accuracy.',
              ),
              const SizedBox(height: 16),
              if (_isInventoryLoading)
                const _DiagnosticNotice(
                  icon: Icons.sync,
                  title: 'Reading inventory',
                  message:
                      'Collecting device capability metadata. No live sensor sampling is performed.',
                  kind: _ReadinessKind.busy,
                )
              else if (inventoryError)
                _DiagnosticNotice(
                  icon: Icons.error_outline,
                  title: 'Inventory unavailable',
                  message: _errorMessage!,
                  kind: _ReadinessKind.error,
                )
              else if (_sensorInventorySnapshot == null)
                const _DiagnosticNotice(
                  icon: Icons.inventory_2_outlined,
                  title: 'Inventory not checked',
                  message:
                      'Refresh the inventory to inspect the sensors reported by this device.',
                  kind: _ReadinessKind.neutral,
                )
              else ...<Widget>[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _FactChip('$availableCount available'),
                    _FactChip('$unavailableCount unavailable'),
                    if (unsupportedCount > 0)
                      _FactChip('$unsupportedCount API unsupported'),
                  ],
                ),
                const SizedBox(height: 14),
                for (
                  int index = 0;
                  index < records.length;
                  index++
                ) ...<Widget>[
                  _SensorCapabilityTile(
                    title: _sensorTypeLabel(records[index]['requestedType']),
                    hardwareName: records[index]['name']?.toString(),
                    status: _sensorRecordStatus(records[index]),
                    facts: <String>[
                      ?_sensorFact('Vendor', records[index]['vendor']),
                      ?_sensorFact('Resolution', records[index]['resolution']),
                      ?_sensorFact(
                        'Min delay',
                        records[index]['minDelayUs'],
                        suffix: ' µs',
                      ),
                      ?_sensorFact(
                        'Power',
                        records[index]['power'],
                        suffix: ' mA',
                      ),
                    ],
                  ),
                  if (index != records.length - 1) const SizedBox(height: 10),
                ],
                const SizedBox(height: 8),
                _TechnicalDetailsExpansion(
                  details: _jsonEncoder.convert(_sensorInventorySnapshot),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('sensor-inventory-action'),
                  onPressed: _isBusy ? null : _readSensorInventory,
                  icon: _isInventoryLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                    _isInventoryLoading
                        ? 'Reading Sensor Inventory...'
                        : 'Refresh Sensor Inventory',
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionEyebrow('LIVE SENSOR TIMING'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.timer_outlined,
                title: 'Live Sensor Timing Diagnostic',
                description:
                    'Measure delivered event timing for one selected sensor without changing the native sampling policy.',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<_SensorOption>(
                key: const Key('sensor-timing-selector'),
                initialValue: _selectedSensor,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Sensor',
                  border: OutlineInputBorder(),
                ),
                items: _sensorOptions
                    .map(
                      (_SensorOption option) => DropdownMenuItem<_SensorOption>(
                        value: option,
                        child: Text(option.label),
                      ),
                    )
                    .toList(growable: false),
                onChanged: _isBusy
                    ? null
                    : (_SensorOption? option) {
                        if (option == null) return;
                        setState(() => _selectedSensor = option);
                      },
              ),
              const SizedBox(height: 12),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _FactChip('Requested · 50 Hz'),
                  _FactChip('Window · 10 seconds'),
                  _FactChip('Report latency · 0 µs'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('sensor-timing-action'),
                  onPressed: _isBusy ? null : _runSensorTimingDiagnostic,
                  icon: _isSensorTimingLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow_rounded),
                  label: Text(
                    _isSensorTimingLoading
                        ? 'Running 10-second diagnostic...'
                        : 'Run Sensor Timing Test',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_isSensorTimingLoading)
                _DiagnosticNotice(
                  icon: Icons.sync,
                  title: 'Timing test running',
                  message:
                      'Listening to ${_selectedSensor.label} events for the existing 10-second diagnostic window.',
                  kind: _ReadinessKind.busy,
                )
              else if (timingError)
                _DiagnosticNotice(
                  icon: Icons.error_outline,
                  title: 'Timing test failed',
                  message: _errorMessage!,
                  kind: _ReadinessKind.error,
                )
              else if (timing == null)
                const _DiagnosticNotice(
                  icon: Icons.query_stats_outlined,
                  title: 'Timing not measured',
                  message:
                      'Choose a sensor and run the timing test to view delivered event metrics.',
                  kind: _ReadinessKind.neutral,
                )
              else ...<Widget>[
                _DiagnosticNotice(
                  icon: timing['validTimingSummary'] == true
                      ? Icons.check_circle_outline
                      : Icons.info_outline,
                  title: timing['validTimingSummary'] == true
                      ? 'Timing summary completed'
                      : 'Timing summary requires review',
                  message:
                      '${(timing['sensor'] as Map?)?['name'] ?? _selectedSensor.label} · '
                      '${timing['eventCount'] ?? 'Event count unavailable'} events',
                  kind: timing['validTimingSummary'] == true
                      ? _ReadinessKind.ready
                      : _ReadinessKind.attention,
                ),
                const SizedBox(height: 12),
                _DiagnosticMetricGrid(
                  key: const Key('sensor-timing-metrics'),
                  metrics: <_DiagnosticMetric>[
                    _DiagnosticMetric(
                      'Observed rate',
                      _formatFrequency(timing['meanDeliveredHz']),
                    ),
                    _DiagnosticMetric(
                      'Event count',
                      timing['eventCount']?.toString() ?? 'Not available',
                    ),
                    _DiagnosticMetric(
                      'Mean interval',
                      _formatNanosecondsAsMilliseconds(timing['meanDeltaNs']),
                    ),
                    _DiagnosticMetric(
                      'P95 interval',
                      _formatNanosecondsAsMilliseconds(timing['p95DeltaNs']),
                    ),
                    _DiagnosticMetric(
                      'Largest gap',
                      _formatNanosecondsAsMilliseconds(timing['maxDeltaNs']),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _DiagnosticStatusChip(
                  key: const Key('sensor-timestamp-status'),
                  status: timing['nonMonotonicTimestampCount'] == 0
                      ? const _ReadinessStatus(
                          'Monotonic timestamps',
                          _ReadinessKind.ready,
                        )
                      : _ReadinessStatus(
                          '${timing['nonMonotonicTimestampCount'] ?? 'Unknown'} timestamp issues',
                          _ReadinessKind.attention,
                        ),
                ),
                const SizedBox(height: 8),
                _TechnicalDetailsExpansion(
                  details: _jsonEncoder.convert(timing),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  bool get _isGnssModuleOperationActive => switch (_activeOperation) {
    _DiagnosticOperation.gnssPreflight ||
    _DiagnosticOperation.gnssPermission ||
    _DiagnosticOperation.gnssTiming ||
    _DiagnosticOperation.gnssAnchorPreflight ||
    _DiagnosticOperation.gnssAnchorAcquisition => true,
    _ => false,
  };

  _ReadinessStatus get _gnssModuleStatus {
    if (_gnssAnchorState == GnssAnchorRuntimeState.acquiring) {
      return const _ReadinessStatus('Acquiring', _ReadinessKind.busy);
    }
    if (_isGnssModuleOperationActive) {
      return const _ReadinessStatus('Running', _ReadinessKind.busy);
    }
    if (_gnssAnchorState == GnssAnchorRuntimeState.anchorLocked &&
        _gnssAnchor != null) {
      return const _ReadinessStatus('Anchor locked', _ReadinessKind.ready);
    }
    if (_gnssAnchorState == GnssAnchorRuntimeState.failed ||
        (_lastGnssOperation != null && _errorMessage != null)) {
      return const _ReadinessStatus('Error', _ReadinessKind.error);
    }
    if (_gnssPreflightSnapshot == null) {
      return const _ReadinessStatus('Not checked', _ReadinessKind.neutral);
    }
    if (_preciseLocationPermission != 'Granted') {
      return const _ReadinessStatus(
        'Permission required',
        _ReadinessKind.attention,
      );
    }
    if (_gpsProvider == 'Unavailable' ||
        _gpsProvider == 'Disabled' ||
        _locationServices == 'Disabled') {
      return const _ReadinessStatus('Unavailable', _ReadinessKind.unavailable);
    }
    if (_canRunFormalGnssDiagnostic == true) {
      return const _ReadinessStatus('Ready', _ReadinessKind.ready);
    }
    return const _ReadinessStatus('Action required', _ReadinessKind.attention);
  }

  _ReadinessStatus get _gnssPermissionStatus =>
      switch (_preciseLocationPermission) {
        'Granted' => const _ReadinessStatus(
          'Precise location granted',
          _ReadinessKind.ready,
        ),
        'Approximate only' => const _ReadinessStatus(
          'Approximate only',
          _ReadinessKind.attention,
        ),
        'Not granted' => const _ReadinessStatus(
          'Permission required',
          _ReadinessKind.attention,
        ),
        _ => const _ReadinessStatus('Not checked', _ReadinessKind.neutral),
      };

  _ReadinessStatus get _gnssProviderStatus => switch (_gpsProvider) {
    'Enabled' => const _ReadinessStatus('Enabled', _ReadinessKind.ready),
    'Disabled' => const _ReadinessStatus('Disabled', _ReadinessKind.attention),
    'Unavailable' => const _ReadinessStatus(
      'Unavailable',
      _ReadinessKind.unavailable,
    ),
    _ => const _ReadinessStatus('Not checked', _ReadinessKind.neutral),
  };

  _ReadinessStatus get _locationServicesStatus => switch (_locationServices) {
    'Enabled' => const _ReadinessStatus('Enabled', _ReadinessKind.ready),
    'Disabled' => const _ReadinessStatus(
      'Disabled',
      _ReadinessKind.unavailable,
    ),
    _ => _ReadinessStatus(_locationServices, _ReadinessKind.neutral),
  };

  _ReadinessStatus get _formalGnssStatus {
    if (_gnssPreflightSnapshot == null) {
      return const _ReadinessStatus('Not checked', _ReadinessKind.neutral);
    }
    return _canRunFormalGnssDiagnostic == true
        ? const _ReadinessStatus('Ready', _ReadinessKind.ready)
        : const _ReadinessStatus('Action required', _ReadinessKind.attention);
  }

  _ReadinessStatus get _navigationAnchorStatus => switch (_gnssAnchorState) {
    GnssAnchorRuntimeState.noAnchor => const _ReadinessStatus(
      'Not locked',
      _ReadinessKind.neutral,
    ),
    GnssAnchorRuntimeState.acquiring => const _ReadinessStatus(
      'Acquiring',
      _ReadinessKind.busy,
    ),
    GnssAnchorRuntimeState.anchorLocked => const _ReadinessStatus(
      'Anchor locked',
      _ReadinessKind.ready,
    ),
    GnssAnchorRuntimeState.failed => const _ReadinessStatus(
      'Error',
      _ReadinessKind.error,
    ),
  };

  _ReadinessStatus get _anchorPreflightStatus {
    final GnssAnchorPreflight? preflight = _gnssAnchorPreflight;
    if (preflight == null) {
      return const _ReadinessStatus('Not checked', _ReadinessKind.neutral);
    }
    if (!preflight.fineLocationPermissionGranted) {
      return const _ReadinessStatus(
        'Permission required',
        _ReadinessKind.attention,
      );
    }
    if (preflight.gpsProviderEnabled == false ||
        preflight.locationServicesEnabled == false) {
      return const _ReadinessStatus('Unavailable', _ReadinessKind.unavailable);
    }
    return preflight.canAcquireAnchor
        ? const _ReadinessStatus('Ready', _ReadinessKind.ready)
        : const _ReadinessStatus('Action required', _ReadinessKind.attention);
  }

  String _formatReportedMeters(Object? value) {
    if (value is! num) return 'Not available';
    return '${value.toDouble().toStringAsFixed(1)} m reported';
  }

  Widget _buildGnssAnchorDiagnosticModule(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Map<String, Object?>? timing = _gnssTimingSnapshot;
    final GnssAnchor? anchor = _gnssAnchor;
    final bool readinessError =
        (_lastGnssOperation == _DiagnosticOperation.gnssPreflight ||
            _lastGnssOperation == _DiagnosticOperation.gnssPermission) &&
        _errorMessage != null;
    final bool timingError =
        _lastGnssOperation == _DiagnosticOperation.gnssTiming &&
        _errorMessage != null;
    final bool anchorError =
        (_lastGnssOperation == _DiagnosticOperation.gnssAnchorPreflight ||
            _lastGnssOperation == _DiagnosticOperation.gnssAnchorAcquisition) &&
        _errorMessage != null;
    final Map<String, Object?> anchorDetails = <String, Object?>{
      'anchorState': _gnssAnchorState.sanitizedName,
      if (_gnssAnchorPreflightSnapshot != null)
        'preflight': _gnssAnchorPreflightSnapshot,
      if (anchor != null) 'anchor': anchor.sanitizedMetadata,
    };

    return Column(
      key: const Key('gnss-anchor-diagnostic-content'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _DashboardCard(
          emphasis: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _IconBadge(icon: Icons.gps_fixed, color: colors.primary),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'GNSS & Anchor',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'GNSS readiness, timing diagnostics and local navigation anchor.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _DiagnosticStatusChip(status: _gnssModuleStatus),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionEyebrow('GNSS READINESS'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.satellite_alt_outlined,
                title: 'GNSS Readiness',
                description:
                    'Check precise-location authorization and Android GPS provider readiness before formal diagnostics.',
              ),
              const SizedBox(height: 16),
              _DiagnosticStatusRow(
                label: 'Precise location',
                status: _gnssPermissionStatus,
              ),
              const SizedBox(height: 9),
              _DiagnosticStatusRow(
                label: 'GPS provider',
                status: _gnssProviderStatus,
              ),
              const SizedBox(height: 9),
              _DiagnosticStatusRow(
                label: 'Location services',
                status: _locationServicesStatus,
              ),
              const SizedBox(height: 9),
              _DiagnosticStatusRow(
                label: 'Formal GNSS preflight',
                status: _formalGnssStatus,
              ),
              if (readinessError) ...<Widget>[
                const SizedBox(height: 12),
                _DiagnosticNotice(
                  icon: Icons.error_outline,
                  title: 'GNSS readiness check failed',
                  message: _errorMessage!,
                  kind: _ReadinessKind.error,
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('gnss-preflight-action'),
                  onPressed: _isBusy ? null : _refreshGnssPreflight,
                  icon: _isGnssPreflightLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                    _isGnssPreflightLoading
                        ? 'Refreshing GNSS Preflight...'
                        : 'Refresh GNSS Readiness',
                  ),
                ),
              ),
              const SizedBox(height: 9),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('gnss-permission-action'),
                  onPressed: _isBusy ? null : _requestGnssForegroundPermission,
                  icon: _isGnssPermissionLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.location_on_outlined),
                  label: Text(
                    _isGnssPermissionLoading
                        ? 'Requesting Precise Location Permission...'
                        : 'Request Precise Location Permission',
                  ),
                ),
              ),
              if (_gnssPreflightSnapshot != null) ...<Widget>[
                const SizedBox(height: 8),
                _TechnicalDetailsExpansion(
                  expansionKey: const Key('gnss-readiness-technical-details'),
                  details: _jsonEncoder.convert(_gnssPreflightSnapshot),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionEyebrow('GNSS TIMING'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.query_stats_outlined,
                title: 'GNSS Runtime Timing Diagnostic',
                description:
                    'Measure delivered GPS fixes and monotonic update timing using the existing formal window.',
              ),
              const SizedBox(height: 14),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _FactChip('Provider · GPS_PROVIDER'),
                  _FactChip('Minimum interval · 1,000 ms'),
                  _FactChip('Minimum distance · 0 m'),
                  _FactChip('First fix timeout · 120 s'),
                  _FactChip('Collection · 60 s'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('gnss-timing-action'),
                  onPressed: !_isBusy && _canRunFormalGnssDiagnostic == true
                      ? _runGnssTimingDiagnostic
                      : null,
                  icon: _isGnssTimingLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow_rounded),
                  label: Text(
                    _isGnssTimingLoading
                        ? 'Running GNSS diagnostic...'
                        : 'Run GNSS Timing Test',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_isGnssTimingLoading)
                const _DiagnosticNotice(
                  icon: Icons.sync,
                  title: 'GNSS timing running',
                  message:
                      'Waiting for GPS_PROVIDER updates in the existing formal timing window.',
                  kind: _ReadinessKind.busy,
                )
              else if (timingError)
                _DiagnosticNotice(
                  icon: Icons.error_outline,
                  title: 'GNSS timing failed',
                  message: _errorMessage!,
                  kind: _ReadinessKind.error,
                )
              else if (timing == null)
                const _DiagnosticNotice(
                  icon: Icons.schedule_outlined,
                  title: 'Timing not tested',
                  message:
                      'Complete GNSS readiness, then run the timing test to inspect delivered fixes.',
                  kind: _ReadinessKind.neutral,
                )
              else ...<Widget>[
                _DiagnosticNotice(
                  icon: timing['validTimingSummary'] == true
                      ? Icons.check_circle_outline
                      : Icons.info_outline,
                  title: timing['validTimingSummary'] == true
                      ? 'GNSS timing completed'
                      : 'GNSS timing requires review',
                  message:
                      '${timing['locationEventCount'] ?? 'Unknown'} location updates · '
                      '${timing['provider'] ?? 'Unknown provider'}',
                  kind: timing['validTimingSummary'] == true
                      ? _ReadinessKind.ready
                      : _ReadinessKind.attention,
                ),
                const SizedBox(height: 12),
                _DiagnosticMetricGrid(
                  key: const Key('gnss-timing-metrics'),
                  metrics: <_DiagnosticMetric>[
                    _DiagnosticMetric(
                      'Fix count',
                      timing['locationEventCount']?.toString() ??
                          'Not available',
                    ),
                    _DiagnosticMetric(
                      'Observed rate',
                      _formatFrequency(timing['meanFixRateHz']),
                    ),
                    _DiagnosticMetric(
                      'Median interval',
                      _formatNanosecondsAsMilliseconds(timing['medianDeltaNs']),
                    ),
                    _DiagnosticMetric(
                      'P95 interval',
                      _formatNanosecondsAsMilliseconds(timing['p95DeltaNs']),
                    ),
                    _DiagnosticMetric(
                      'Largest interval',
                      _formatNanosecondsAsMilliseconds(timing['maxDeltaNs']),
                    ),
                    _DiagnosticMetric(
                      'Median accuracy',
                      _formatReportedMeters(
                        timing['medianHorizontalAccuracyM'],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _DiagnosticStatusChip(
                  key: const Key('gnss-timestamp-status'),
                  status: timing['nonMonotonicTimestampCount'] == 0
                      ? const _ReadinessStatus(
                          'Monotonic timestamps',
                          _ReadinessKind.ready,
                        )
                      : _ReadinessStatus(
                          '${timing['nonMonotonicTimestampCount'] ?? 'Unknown'} timestamp issues',
                          _ReadinessKind.attention,
                        ),
                ),
                const SizedBox(height: 8),
                _TechnicalDetailsExpansion(
                  expansionKey: const Key('gnss-timing-technical-details'),
                  details: _jsonEncoder.convert(timing),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionEyebrow('LOCAL NAVIGATION REFERENCE'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.add_location_alt_outlined,
                title: 'GNSS Anchor / Local Reference',
                description:
                    'Acquire the pre-denial GPS reference used to define the local horizontal ENU frame.',
              ),
              const SizedBox(height: 14),
              _DiagnosticStatusChip(status: _navigationAnchorStatus),
              const SizedBox(height: 14),
              _DiagnosticStatusRow(
                label: 'Anchor preflight',
                status: _anchorPreflightStatus,
              ),
              const SizedBox(height: 9),
              _DiagnosticStatusRow(
                label: 'Fine location',
                status: _gnssAnchorPreflight == null
                    ? const _ReadinessStatus(
                        'Not checked',
                        _ReadinessKind.neutral,
                      )
                    : _gnssAnchorPreflight!.fineLocationPermissionGranted
                    ? const _ReadinessStatus('Granted', _ReadinessKind.ready)
                    : const _ReadinessStatus(
                        'Permission required',
                        _ReadinessKind.attention,
                      ),
              ),
              const SizedBox(height: 14),
              _DiagnosticMetricGrid(
                key: const Key('gnss-anchor-metrics'),
                metrics: <_DiagnosticMetric>[
                  _DiagnosticMetric(
                    'Candidate count',
                    _anchorCandidateCountLabel,
                  ),
                  _DiagnosticMetric(
                    'Horizontal accuracy',
                    _anchorReportedHorizontalAccuracyLabel,
                  ),
                  _DiagnosticMetric(
                    'Altitude available',
                    _anchorAltitudeAvailableLabel,
                  ),
                  _DiagnosticMetric(
                    'Horizontal ENU origin',
                    _horizontalEnuOriginReadyLabel == 'Yes'
                        ? 'Ready'
                        : 'Not ready',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const _DiagnosticNotice(
                icon: Icons.shield_outlined,
                title: 'Pre-denial reference policy',
                message:
                    'Uses structurally valid, non-mock GPS_PROVIDER candidates. Selection prefers the lowest reported horizontal accuracy and then the newer elapsed-realtime fix.',
                kind: _ReadinessKind.neutral,
              ),
              if (_isGnssAnchorAcquisitionLoading) ...<Widget>[
                const SizedBox(height: 12),
                const _DiagnosticNotice(
                  icon: Icons.location_searching,
                  title: 'Anchor acquisition running',
                  message:
                      'Waiting for valid GPS candidates. Live candidate progress is not exposed by the current platform contract.',
                  kind: _ReadinessKind.busy,
                ),
              ] else if (anchorError) ...<Widget>[
                const SizedBox(height: 12),
                _DiagnosticNotice(
                  icon: Icons.error_outline,
                  title: 'Anchor action failed',
                  message: _errorMessage!,
                  kind: _ReadinessKind.error,
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('gnss-anchor-preflight-action'),
                  onPressed: _isBusy ? null : _refreshGnssAnchorPreflight,
                  icon: _isGnssAnchorPreflightLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                    _isGnssAnchorPreflightLoading
                        ? 'Refreshing Anchor Preflight...'
                        : 'Refresh Anchor Readiness',
                  ),
                ),
              ),
              const SizedBox(height: 9),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('gnss-anchor-acquire-action'),
                  onPressed:
                      !_isBusy &&
                          _gnssAnchor == null &&
                          _gnssAnchorPreflight?.canAcquireAnchor == true
                      ? _acquireGnssAnchor
                      : null,
                  icon: _isGnssAnchorAcquisitionLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_location_alt_outlined),
                  label: Text(
                    _isGnssAnchorAcquisitionLoading
                        ? 'Acquiring GNSS Anchor...'
                        : 'Acquire GNSS Anchor',
                  ),
                ),
              ),
              if (_isGnssAnchorAcquisitionLoading) ...<Widget>[
                const SizedBox(height: 9),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    key: const Key('gnss-anchor-cancel-action'),
                    onPressed: _anchorCancellationRequestInFlight
                        ? null
                        : _cancelGnssAnchorAcquisition,
                    icon: const Icon(Icons.cancel_outlined),
                    label: Text(
                      _anchorCancellationRequestInFlight
                          ? 'Cancelling Acquisition...'
                          : 'Cancel Acquisition',
                    ),
                  ),
                ),
              ],
              if (anchor != null) ...<Widget>[
                const SizedBox(height: 9),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    key: const Key('gnss-anchor-clear-action'),
                    onPressed: _isBusy ? null : _clearGnssAnchor,
                    style: TextButton.styleFrom(foregroundColor: colors.error),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Clear Anchor'),
                  ),
                ),
              ],
              if (anchorDetails.length > 1) ...<Widget>[
                const SizedBox(height: 8),
                _TechnicalDetailsExpansion(
                  expansionKey: const Key('gnss-anchor-technical-details'),
                  details: _jsonEncoder.convert(anchorDetails),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _requestPublicAnchorPermission() async {
    await _requestGnssForegroundPermission();
    if (mounted) await _refreshGnssAnchorPreflight();
  }

  Widget _buildPublicAnchorSetupCard(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final GnssAnchor? anchor = _gnssAnchor;
    final bool anchorError =
        (_lastGnssOperation == _DiagnosticOperation.gnssAnchorPreflight ||
            _lastGnssOperation == _DiagnosticOperation.gnssAnchorAcquisition ||
            _lastGnssOperation == _DiagnosticOperation.gnssPermission) &&
        _errorMessage != null;

    return _DashboardCard(
      key: const Key('public-anchor-setup'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _DiagnosticSectionHeading(
            icon: Icons.add_location_alt_outlined,
            title: 'GNSS Anchor Setup',
            description:
                'Prepare the local navigation reference required by the Live Map.',
          ),
          const SizedBox(height: 14),
          _DiagnosticStatusChip(status: _navigationAnchorStatus),
          const SizedBox(height: 14),
          _DiagnosticStatusRow(
            label: 'Anchor readiness',
            status: _anchorPreflightStatus,
          ),
          const SizedBox(height: 9),
          _DiagnosticStatusRow(
            label: 'Fine location',
            status: _gnssAnchorPreflight == null
                ? const _ReadinessStatus('Not checked', _ReadinessKind.neutral)
                : _gnssAnchorPreflight!.fineLocationPermissionGranted
                ? const _ReadinessStatus('Granted', _ReadinessKind.ready)
                : const _ReadinessStatus(
                    'Permission required',
                    _ReadinessKind.attention,
                  ),
          ),
          if (anchorError) ...<Widget>[
            const SizedBox(height: 12),
            _DiagnosticNotice(
              icon: Icons.error_outline,
              title: 'Anchor setup failed',
              message: _errorMessage!,
              kind: _ReadinessKind.error,
            ),
          ],
          const SizedBox(height: 16),
          OutlinedButton.icon(
            key: const Key('public-anchor-readiness-action'),
            onPressed: _isBusy ? null : _refreshGnssAnchorPreflight,
            icon: _isGnssAnchorPreflightLoading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            label: Text(
              _isGnssAnchorPreflightLoading
                  ? 'Refreshing Anchor Readiness...'
                  : 'Refresh Anchor Readiness',
            ),
          ),
          if (_gnssAnchorPreflight != null &&
              !_gnssAnchorPreflight!.fineLocationPermissionGranted) ...<Widget>[
            const SizedBox(height: 9),
            OutlinedButton.icon(
              key: const Key('public-anchor-permission-action'),
              onPressed: _isBusy ? null : _requestPublicAnchorPermission,
              icon: const Icon(Icons.location_on_outlined),
              label: const Text('Grant Location Permission'),
            ),
          ],
          const SizedBox(height: 9),
          FilledButton.icon(
            key: const Key('public-anchor-acquire-action'),
            onPressed:
                !_isBusy &&
                    anchor == null &&
                    _gnssAnchorPreflight?.canAcquireAnchor == true
                ? _acquireGnssAnchor
                : null,
            icon: _isGnssAnchorAcquisitionLoading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_location_alt_outlined),
            label: Text(
              _isGnssAnchorAcquisitionLoading
                  ? 'Acquiring GNSS Anchor...'
                  : 'Acquire GNSS Anchor',
            ),
          ),
          if (_isGnssAnchorAcquisitionLoading) ...<Widget>[
            const SizedBox(height: 9),
            OutlinedButton.icon(
              key: const Key('public-anchor-cancel-action'),
              onPressed: _anchorCancellationRequestInFlight
                  ? null
                  : _cancelGnssAnchorAcquisition,
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancel Acquisition'),
            ),
          ],
          if (anchor != null) ...<Widget>[
            const SizedBox(height: 9),
            TextButton.icon(
              key: const Key('public-anchor-clear-action'),
              onPressed: _isBusy ? null : _clearGnssAnchor,
              style: TextButton.styleFrom(foregroundColor: colors.error),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Clear Anchor'),
            ),
          ],
        ],
      ),
    );
  }

  String _formatHeadingAngle(double? value) {
    if (value == null) return 'Not available';
    final double degrees = value * 180.0 / math.pi;
    return '${degrees.toStringAsFixed(1)}° · ${value.toStringAsFixed(6)} rad';
  }

  String _formatRatioAsPercent(Object? value) {
    if (value is! num) return 'Not available';
    return '${(value.toDouble() * 100.0).toStringAsFixed(1)}%';
  }

  String _formatObjectMeters(Object? value) {
    if (value is! num) return 'Not available';
    return '${value.toDouble().toStringAsFixed(3)} m';
  }

  bool get _isHeadingPdrOperationActive => switch (_activeOperation) {
    _DiagnosticOperation.headingPreflight ||
    _DiagnosticOperation.headingDiagnostic ||
    _DiagnosticOperation.stepPreflight ||
    _DiagnosticOperation.stepPermission ||
    _DiagnosticOperation.stepDiagnostic ||
    _DiagnosticOperation.baselinePdrPreflight ||
    _DiagnosticOperation.baselinePdrDiagnostic => true,
    _ => false,
  };

  bool get _headingPdrHasError =>
      _errorMessage != null &&
      switch (_lastHeadingPdrOperation) {
        _DiagnosticOperation.headingPreflight ||
        _DiagnosticOperation.headingDiagnostic ||
        _DiagnosticOperation.stepPreflight ||
        _DiagnosticOperation.stepPermission ||
        _DiagnosticOperation.stepDiagnostic ||
        _DiagnosticOperation.baselinePdrPreflight ||
        _DiagnosticOperation.baselinePdrDiagnostic => true,
        _ => false,
      };

  _ReadinessStatus get _headingPdrModuleStatus {
    if (_isHeadingPdrOperationActive) {
      return const _ReadinessStatus('Running', _ReadinessKind.busy);
    }
    if (_headingPdrHasError) {
      return const _ReadinessStatus('Error', _ReadinessKind.error);
    }
    if (_headingResult != null &&
        _stepResult != null &&
        _baselinePdrResult != null) {
      return const _ReadinessStatus('Completed', _ReadinessKind.ready);
    }
    if (_headingPreflight == null &&
        _stepPreflight == null &&
        _baselinePdrPreflight == null) {
      return const _ReadinessStatus('Not checked', _ReadinessKind.neutral);
    }
    if (_headingPreflight?.rotationVectorAvailable == false ||
        _stepPreflight?.stepDetectorAvailable == false ||
        _baselinePdrPreflight?.nativeSensorsReady == false) {
      return const _ReadinessStatus(
        'Action required',
        _ReadinessKind.attention,
      );
    }
    if (_headingResult == null ||
        _stepResult == null ||
        _baselinePdrResult == null) {
      return const _ReadinessStatus(
        'Action required',
        _ReadinessKind.attention,
      );
    }
    return const _ReadinessStatus('Ready', _ReadinessKind.ready);
  }

  _ReadinessStatus get _headingFoundationStatus {
    if (_isHeadingPreflightLoading || _isHeadingDiagnosticLoading) {
      return const _ReadinessStatus('Running', _ReadinessKind.busy);
    }
    if (_headingPdrHasError &&
        (_lastHeadingPdrOperation == _DiagnosticOperation.headingPreflight ||
            _lastHeadingPdrOperation ==
                _DiagnosticOperation.headingDiagnostic)) {
      return const _ReadinessStatus('Error', _ReadinessKind.error);
    }
    if (_headingResult != null) {
      return const _ReadinessStatus('Completed', _ReadinessKind.ready);
    }
    final HeadingFoundationPreflight? preflight = _headingPreflight;
    if (preflight == null) {
      return const _ReadinessStatus('Not checked', _ReadinessKind.neutral);
    }
    if (!preflight.rotationVectorAvailable) {
      return const _ReadinessStatus('Unavailable', _ReadinessKind.unavailable);
    }
    if (_gnssAnchorState != GnssAnchorRuntimeState.anchorLocked ||
        _gnssAnchor == null) {
      return const _ReadinessStatus(
        'Anchor required',
        _ReadinessKind.attention,
      );
    }
    return const _ReadinessStatus('Ready', _ReadinessKind.ready);
  }

  _ReadinessStatus get _stepFoundationStatus {
    if (_isStepPreflightLoading ||
        _isStepPermissionLoading ||
        _isStepDiagnosticLoading) {
      return const _ReadinessStatus('Running', _ReadinessKind.busy);
    }
    if (_headingPdrHasError &&
        (_lastHeadingPdrOperation == _DiagnosticOperation.stepPreflight ||
            _lastHeadingPdrOperation == _DiagnosticOperation.stepPermission ||
            _lastHeadingPdrOperation == _DiagnosticOperation.stepDiagnostic)) {
      return const _ReadinessStatus('Error', _ReadinessKind.error);
    }
    if (_stepResult != null) {
      return const _ReadinessStatus('Completed', _ReadinessKind.ready);
    }
    final StepEventPreflight? preflight = _stepPreflight;
    if (preflight == null) {
      return const _ReadinessStatus('Not checked', _ReadinessKind.neutral);
    }
    if (!preflight.stepDetectorAvailable) {
      return const _ReadinessStatus('Unavailable', _ReadinessKind.unavailable);
    }
    if (!preflight.canRunStepDiagnostic) {
      return const _ReadinessStatus(
        'Action required',
        _ReadinessKind.attention,
      );
    }
    return const _ReadinessStatus('Ready', _ReadinessKind.ready);
  }

  _ReadinessStatus get _baselinePdrReadinessStatus {
    if (_isBaselinePdrPreflightLoading || _isBaselinePdrDiagnosticLoading) {
      return const _ReadinessStatus('Running', _ReadinessKind.busy);
    }
    if (_headingPdrHasError &&
        (_lastHeadingPdrOperation ==
                _DiagnosticOperation.baselinePdrPreflight ||
            _lastHeadingPdrOperation ==
                _DiagnosticOperation.baselinePdrDiagnostic)) {
      return const _ReadinessStatus('Error', _ReadinessKind.error);
    }
    if (_baselinePdrResult != null) {
      return const _ReadinessStatus('Completed', _ReadinessKind.ready);
    }
    final BaselinePdrPreflight? preflight = _baselinePdrPreflight;
    if (preflight == null) {
      return const _ReadinessStatus('Not checked', _ReadinessKind.neutral);
    }
    if (!preflight.nativeSensorsReady ||
        _gnssAnchorState != GnssAnchorRuntimeState.anchorLocked ||
        _gnssAnchor == null) {
      return const _ReadinessStatus(
        'Action required',
        _ReadinessKind.attention,
      );
    }
    return const _ReadinessStatus('Ready', _ReadinessKind.ready);
  }

  _ReadinessStatus _availabilityStatus(bool? value) => switch (value) {
    true => const _ReadinessStatus('Available', _ReadinessKind.ready),
    false => const _ReadinessStatus('Unavailable', _ReadinessKind.unavailable),
    null => const _ReadinessStatus('Not checked', _ReadinessKind.neutral),
  };

  Widget _buildHeadingPdrDiagnosticModule(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Map<String, Object?> headingDetails = <String, Object?>{
      'runtimeStatus': _headingDiagnosticStatus,
      if (_headingPreflight != null)
        'preflight': _headingPreflight!.sanitizedMetadata,
      if (_headingResult != null) 'result': _headingResult!.sanitizedMetadata,
    };
    final Map<String, Object?> stepDetails = <String, Object?>{
      'runtimeStatus': _stepDiagnosticStatus,
      if (_stepPreflight != null)
        'preflight': _stepPreflight!.sanitizedMetadata,
      if (_stepResult != null) 'result': _stepResult!.sanitizedMetadata,
    };
    final Map<String, Object?> baselineDetails = <String, Object?>{
      'runtimeStatus': _baselinePdrStatus,
      if (_baselinePdrPreflight != null)
        'preflight': _baselinePdrPreflight!.sanitizedMetadata,
      if (_baselinePdrResult != null)
        'result': _baselinePdrResult!.sanitizedMetadata,
    };
    final bool headingError =
        _headingPdrHasError &&
        (_lastHeadingPdrOperation == _DiagnosticOperation.headingPreflight ||
            _lastHeadingPdrOperation == _DiagnosticOperation.headingDiagnostic);
    final bool stepError =
        _headingPdrHasError &&
        (_lastHeadingPdrOperation == _DiagnosticOperation.stepPreflight ||
            _lastHeadingPdrOperation == _DiagnosticOperation.stepPermission ||
            _lastHeadingPdrOperation == _DiagnosticOperation.stepDiagnostic);
    final bool baselineError =
        _headingPdrHasError &&
        (_lastHeadingPdrOperation ==
                _DiagnosticOperation.baselinePdrPreflight ||
            _lastHeadingPdrOperation ==
                _DiagnosticOperation.baselinePdrDiagnostic);

    return Column(
      key: const Key('heading-pdr-diagnostic-content'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _DashboardCard(
          emphasis: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _IconBadge(
                    icon: Icons.explore_outlined,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Heading & PDR',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'True-north heading, pedestrian steps and baseline dead-reckoning diagnostics.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _DiagnosticStatusChip(status: _headingPdrModuleStatus),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionEyebrow('TRUE-NORTH REFERENCE'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.explore_outlined,
                title: 'Heading Foundation',
                description:
                    'Rotation-vector heading corrected with the anchor-based geomagnetic declination.',
              ),
              const SizedBox(height: 14),
              _DiagnosticStatusChip(status: _headingFoundationStatus),
              const SizedBox(height: 14),
              _DiagnosticStatusRow(
                label: 'Rotation Vector',
                status: _availabilityStatus(
                  _headingPreflight?.rotationVectorAvailable,
                ),
              ),
              const SizedBox(height: 9),
              _DiagnosticStatusRow(
                label: 'GNSS anchor',
                status:
                    _gnssAnchorState == GnssAnchorRuntimeState.anchorLocked &&
                        _gnssAnchor != null
                    ? const _ReadinessStatus('Locked', _ReadinessKind.ready)
                    : const _ReadinessStatus(
                        'Required',
                        _ReadinessKind.attention,
                      ),
              ),
              const SizedBox(height: 14),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _FactChip('Source · TYPE_ROTATION_VECTOR'),
                  _FactChip('Sampling request · 20,000 μs'),
                  _FactChip('Forward axis · device +Y / top edge'),
                  _FactChip('0° true north · clockwise positive'),
                ],
              ),
              const SizedBox(height: 14),
              _DiagnosticMetricGrid(
                key: const Key('heading-result-metrics'),
                metrics: <_DiagnosticMetric>[
                  _DiagnosticMetric(
                    'True-north heading',
                    _formatHeadingAngle(
                      _headingResult?.lastTrueNorthCorrectedHeadingRad,
                    ),
                  ),
                  _DiagnosticMetric(
                    'Magnetic heading',
                    _formatHeadingAngle(_headingResult?.lastMagneticHeadingRad),
                  ),
                  _DiagnosticMetric(
                    'Declination',
                    _formatHeadingAngle(_headingResult?.declinationRadians),
                  ),
                  _DiagnosticMetric(
                    'Valid samples',
                    _headingValidSampleCountLabel,
                  ),
                  _DiagnosticMetric(
                    'Reported accuracy',
                    _reportedHeadingAccuracyLabel,
                  ),
                  _DiagnosticMetric('Observed rate', _headingObservedRateLabel),
                  _DiagnosticMetric(
                    'Cumulative change',
                    _cumulativeHeadingChangeLabel,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_isHeadingDiagnosticLoading)
                const _DiagnosticNotice(
                  icon: Icons.sync,
                  title: 'Heading diagnostic running',
                  message:
                      'Collecting measurement-timestamped rotation-vector samples for the existing 30-second window.',
                  kind: _ReadinessKind.busy,
                )
              else if (headingError)
                _DiagnosticNotice(
                  icon: Icons.error_outline,
                  title: 'Heading action failed',
                  message: _errorMessage!,
                  kind: _ReadinessKind.error,
                )
              else if (_headingResult == null)
                const _DiagnosticNotice(
                  icon: Icons.info_outline,
                  title: 'Heading not measured',
                  message:
                      'Complete preflight and lock a GNSS anchor before running the diagnostic.',
                  kind: _ReadinessKind.neutral,
                )
              else
                _DiagnosticNotice(
                  icon: Icons.schedule_outlined,
                  title: 'Timestamp status',
                  message: _headingTimestampMonotonicityLabel,
                  kind: _headingResult!.nonMonotonicTimestampCount == 0
                      ? _ReadinessKind.ready
                      : _ReadinessKind.attention,
                ),
              const SizedBox(height: 12),
              const _DiagnosticNotice(
                icon: Icons.science_outlined,
                title: 'Research limitation',
                message:
                    'Heading and true-north accuracy are not independently validated by this diagnostic.',
                kind: _ReadinessKind.neutral,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('heading-preflight-action'),
                  onPressed: _isBusy ? null : _refreshHeadingPreflight,
                  icon: _isHeadingPreflightLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                    _isHeadingPreflightLoading
                        ? 'Refreshing Heading Preflight...'
                        : 'Refresh Heading Readiness',
                  ),
                ),
              ),
              const SizedBox(height: 9),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('heading-run-action'),
                  onPressed: _canRunHeadingDiagnostic
                      ? _runHeadingDiagnostic
                      : null,
                  icon: _isHeadingDiagnosticLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.explore_outlined),
                  label: Text(
                    _isHeadingDiagnosticLoading
                        ? 'Running Heading Diagnostic...'
                        : 'Run Heading Diagnostic',
                  ),
                ),
              ),
              if (_isHeadingDiagnosticLoading) ...<Widget>[
                const SizedBox(height: 9),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    key: const Key('heading-cancel-action'),
                    onPressed: _headingCancellationRequestInFlight
                        ? null
                        : _cancelHeadingDiagnostic,
                    icon: const Icon(Icons.cancel_outlined),
                    label: Text(
                      _headingCancellationRequestInFlight
                          ? 'Cancelling Heading Diagnostic...'
                          : 'Cancel Heading Diagnostic',
                    ),
                  ),
                ),
              ],
              if (headingDetails.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                _TechnicalDetailsExpansion(
                  expansionKey: const Key('heading-technical-details'),
                  details: _jsonEncoder.convert(headingDetails),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionEyebrow('PEDESTRIAN EVENT SOURCE'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.directions_walk,
                title: 'Step Detection',
                description:
                    'Inspect Android step-detector events, permission readiness and event timing.',
              ),
              const SizedBox(height: 14),
              _DiagnosticStatusChip(status: _stepFoundationStatus),
              const SizedBox(height: 14),
              _DiagnosticStatusRow(
                label: 'Step detector',
                status: _availabilityStatus(
                  _stepPreflight?.stepDetectorAvailable,
                ),
              ),
              const SizedBox(height: 9),
              _DiagnosticStatusRow(
                label: 'Physical activity permission',
                status: _stepPreflight == null
                    ? const _ReadinessStatus(
                        'Not checked',
                        _ReadinessKind.neutral,
                      )
                    : (!_stepPreflight!.activityRecognitionPermissionRequired ||
                          _stepPreflight!.activityRecognitionPermissionGranted)
                    ? const _ReadinessStatus('Ready', _ReadinessKind.ready)
                    : const _ReadinessStatus(
                        'Permission required',
                        _ReadinessKind.attention,
                      ),
              ),
              const SizedBox(height: 14),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _FactChip('Source · TYPE_STEP_DETECTOR'),
                  _FactChip('Timestamp · SensorEvent.timestamp'),
                  _FactChip('Formal window · 30 s'),
                ],
              ),
              const SizedBox(height: 14),
              _DiagnosticMetricGrid(
                key: const Key('step-result-metrics'),
                metrics: <_DiagnosticMetric>[
                  _DiagnosticMetric(
                    'Accepted events',
                    _detectedStepEventsLabel,
                  ),
                  _DiagnosticMetric('Invalid events', _invalidStepEventsLabel),
                  _DiagnosticMetric(
                    'Median interval',
                    _medianStepIntervalLabel,
                  ),
                  _DiagnosticMetric(
                    'Observed cadence',
                    _observedStepCadenceLabel,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_isStepDiagnosticLoading)
                const _DiagnosticNotice(
                  icon: Icons.sync,
                  title: 'Step diagnostic running',
                  message:
                      'Collecting TYPE_STEP_DETECTOR events in the existing formal window.',
                  kind: _ReadinessKind.busy,
                )
              else if (stepError)
                _DiagnosticNotice(
                  icon: Icons.error_outline,
                  title: 'Step action failed',
                  message: _errorMessage!,
                  kind: _ReadinessKind.error,
                )
              else if (_stepResult == null)
                const _DiagnosticNotice(
                  icon: Icons.info_outline,
                  title: 'Step timing not measured',
                  message:
                      'Complete preflight before starting the step-event diagnostic.',
                  kind: _ReadinessKind.neutral,
                )
              else
                _DiagnosticNotice(
                  icon: Icons.schedule_outlined,
                  title: 'Timestamp status',
                  message: _stepTimestampMonotonicityLabel,
                  kind:
                      _stepResult!.nonMonotonicTimestampCount == 0 &&
                          _stepResult!.duplicateTimestampCount == 0
                      ? _ReadinessKind.ready
                      : _ReadinessKind.attention,
                ),
              const SizedBox(height: 12),
              const _DiagnosticNotice(
                icon: Icons.science_outlined,
                title: 'Research limitation',
                message:
                    'Step-detector availability does not imply validated step-detection accuracy.',
                kind: _ReadinessKind.neutral,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('step-preflight-action'),
                  onPressed: _isBusy ? null : _refreshStepPreflight,
                  icon: _isStepPreflightLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                    _isStepPreflightLoading
                        ? 'Refreshing Step Preflight...'
                        : 'Refresh Step Readiness',
                  ),
                ),
              ),
              if (_stepPreflight?.activityRecognitionPermissionRequired ==
                      true &&
                  _stepPreflight?.activityRecognitionPermissionGranted ==
                      false) ...<Widget>[
                const SizedBox(height: 9),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    key: const Key('step-permission-action'),
                    onPressed: _isBusy
                        ? null
                        : _requestActivityRecognitionPermission,
                    icon: _isStepPermissionLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.directions_walk),
                    label: Text(
                      _isStepPermissionLoading
                          ? 'Requesting Physical Activity Permission...'
                          : 'Grant Physical Activity Permission',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 9),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('step-run-action'),
                  onPressed: _canRunStepDiagnostic ? _runStepDiagnostic : null,
                  icon: _isStepDiagnosticLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.directions_walk),
                  label: Text(
                    _isStepDiagnosticLoading
                        ? 'Running Step Diagnostic...'
                        : 'Run Step Diagnostic',
                  ),
                ),
              ),
              if (_isStepDiagnosticLoading) ...<Widget>[
                const SizedBox(height: 9),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    key: const Key('step-cancel-action'),
                    onPressed: _stepCancellationRequestInFlight
                        ? null
                        : _cancelStepDiagnostic,
                    icon: const Icon(Icons.cancel_outlined),
                    label: Text(
                      _stepCancellationRequestInFlight
                          ? 'Cancelling Step Diagnostic...'
                          : 'Cancel Step Diagnostic',
                    ),
                  ),
                ),
              ],
              if (stepDetails.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                _TechnicalDetailsExpansion(
                  expansionKey: const Key('step-technical-details'),
                  details: _jsonEncoder.convert(stepDetails),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionEyebrow('BASELINE DEAD RECKONING'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.route_outlined,
                title: 'Baseline PDR',
                description:
                    'Integrate accepted step events in local ENU with the frozen baseline stride and causal heading association.',
              ),
              const SizedBox(height: 14),
              _DiagnosticStatusChip(status: _baselinePdrReadinessStatus),
              const SizedBox(height: 14),
              _DiagnosticStatusRow(
                label: 'Rotation Vector',
                status: _availabilityStatus(
                  _baselinePdrPreflight?.rotationVectorAvailable,
                ),
              ),
              const SizedBox(height: 9),
              _DiagnosticStatusRow(
                label: 'Step detector',
                status: _availabilityStatus(
                  _baselinePdrPreflight?.stepDetectorAvailable,
                ),
              ),
              const SizedBox(height: 9),
              _DiagnosticStatusRow(
                label: 'GNSS anchor',
                status:
                    _gnssAnchorState == GnssAnchorRuntimeState.anchorLocked &&
                        _gnssAnchor != null
                    ? const _ReadinessStatus('Locked', _ReadinessKind.ready)
                    : const _ReadinessStatus(
                        'Required',
                        _ReadinessKind.attention,
                      ),
              ),
              const SizedBox(height: 14),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _FactChip('Fixed stride · 0.75 m'),
                  _FactChip('Coordinate frame · local ENU'),
                  _FactChip('Formal window · 30 s'),
                  _FactChip('Heading · latest at/before step timestamp'),
                ],
              ),
              const SizedBox(height: 14),
              _DiagnosticMetricGrid(
                key: const Key('baseline-pdr-result-metrics'),
                metrics: <_DiagnosticMetric>[
                  _DiagnosticMetric(
                    'Detected steps',
                    _baselinePdrDetectedStepsLabel,
                  ),
                  _DiagnosticMetric(
                    'Integrated steps',
                    _baselinePdrIntegratedStepsLabel,
                  ),
                  _DiagnosticMetric(
                    'Unassociated steps',
                    _baselinePdrUnassociatedStepsLabel,
                  ),
                  _DiagnosticMetric('Final East', _baselinePdrFinalEastLabel),
                  _DiagnosticMetric('Final North', _baselinePdrFinalNorthLabel),
                  _DiagnosticMetric(
                    'Net displacement',
                    _baselinePdrNetDisplacementLabel,
                  ),
                  _DiagnosticMetric(
                    'Nominal path length',
                    _baselinePdrNominalPathLabel,
                  ),
                  _DiagnosticMetric(
                    'Median heading age',
                    _baselinePdrMedianAssociationAgeLabel,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_isBaselinePdrDiagnosticLoading)
                const _DiagnosticNotice(
                  icon: Icons.sync,
                  title: 'Baseline PDR running',
                  message:
                      'Integrating accepted steps with causal measurement-time heading association.',
                  kind: _ReadinessKind.busy,
                )
              else if (baselineError)
                _DiagnosticNotice(
                  icon: Icons.error_outline,
                  title: 'Baseline PDR action failed',
                  message: _errorMessage!,
                  kind: _ReadinessKind.error,
                )
              else if (_baselinePdrResult == null)
                const _DiagnosticNotice(
                  icon: Icons.info_outline,
                  title: 'Baseline PDR not measured',
                  message:
                      'Complete preflight and lock a GNSS anchor before starting this baseline diagnostic.',
                  kind: _ReadinessKind.neutral,
                ),
              const SizedBox(height: 12),
              const _DiagnosticNotice(
                icon: Icons.science_outlined,
                title: 'Baseline scope',
                message:
                    'Adaptive body-heading offset: Outside this baseline PDR diagnostic. Step length, true-north and distance accuracy are not independently validated.',
                kind: _ReadinessKind.neutral,
              ),
              if (_baselinePdrPreflight
                          ?.activityRecognitionPermissionRequired ==
                      true &&
                  _baselinePdrPreflight?.activityRecognitionPermissionGranted ==
                      false) ...<Widget>[
                const SizedBox(height: 12),
                const _DiagnosticNotice(
                  icon: Icons.lock_outline,
                  title: 'Physical activity permission required',
                  message:
                      'Grant permission from the Step Detection section before running baseline PDR.',
                  kind: _ReadinessKind.attention,
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('baseline-pdr-preflight-action'),
                  onPressed: _isBusy ? null : _refreshBaselinePdrPreflight,
                  icon: _isBaselinePdrPreflightLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                    _isBaselinePdrPreflightLoading
                        ? 'Refreshing Baseline PDR Preflight...'
                        : 'Refresh Baseline PDR Readiness',
                  ),
                ),
              ),
              const SizedBox(height: 9),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('baseline-pdr-run-action'),
                  onPressed: _canRunBaselinePdr
                      ? _runBaselinePdrDiagnostic
                      : null,
                  icon: _isBaselinePdrDiagnosticLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.route_outlined),
                  label: Text(
                    _isBaselinePdrDiagnosticLoading
                        ? 'Running Baseline PDR...'
                        : 'Run Baseline PDR',
                  ),
                ),
              ),
              if (_isBaselinePdrDiagnosticLoading) ...<Widget>[
                const SizedBox(height: 9),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    key: const Key('baseline-pdr-cancel-action'),
                    onPressed: _baselinePdrCancellationRequestInFlight
                        ? null
                        : _cancelBaselinePdrDiagnostic,
                    icon: const Icon(Icons.cancel_outlined),
                    label: Text(
                      _baselinePdrCancellationRequestInFlight
                          ? 'Cancelling Baseline PDR...'
                          : 'Cancel Baseline PDR',
                    ),
                  ),
                ),
              ],
              if (baselineDetails.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                _TechnicalDetailsExpansion(
                  expansionKey: const Key('baseline-pdr-technical-details'),
                  details: _jsonEncoder.convert(baselineDetails),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  bool get _isArCoreModuleOperationActive => switch (_activeOperation) {
    _DiagnosticOperation.arCorePreflight ||
    _DiagnosticOperation.arCorePermission ||
    _DiagnosticOperation.arCoreTracking ||
    _DiagnosticOperation.arCoreEnuPreflight ||
    _DiagnosticOperation.arCoreEnuDiagnostic => true,
    _ => false,
  };

  bool get _arCoreHasError =>
      _errorMessage != null &&
      switch (_lastArCoreOperation) {
        _DiagnosticOperation.arCorePreflight ||
        _DiagnosticOperation.arCorePermission ||
        _DiagnosticOperation.arCoreTracking ||
        _DiagnosticOperation.arCoreEnuPreflight ||
        _DiagnosticOperation.arCoreEnuDiagnostic => true,
        _ => false,
      };

  _ReadinessStatus get _arCoreModuleStatus {
    if (_isArCoreTrackingLoading) {
      return const _ReadinessStatus('Tracking', _ReadinessKind.busy);
    }
    if (_isArCoreModuleOperationActive) {
      return const _ReadinessStatus('Running', _ReadinessKind.busy);
    }
    if (_arCoreHasError) {
      return const _ReadinessStatus('Error', _ReadinessKind.error);
    }
    if (_arCoreTrackingSnapshot != null && _arCoreEnuResult != null) {
      return const _ReadinessStatus('Completed', _ReadinessKind.ready);
    }
    if (_arCorePreflightSnapshot == null && _arCoreEnuPreflight == null) {
      return const _ReadinessStatus('Not checked', _ReadinessKind.neutral);
    }
    if (_cameraPermission != 'Granted') {
      return const _ReadinessStatus(
        'Permission required',
        _ReadinessKind.attention,
      );
    }
    if (_canRunFormalArCoreDiagnostic == false ||
        _arCoreEnuPreflight?.nativeReady == false) {
      return const _ReadinessStatus(
        'Action required',
        _ReadinessKind.attention,
      );
    }
    return const _ReadinessStatus('Ready', _ReadinessKind.ready);
  }

  _ReadinessStatus get _arCoreCameraPermissionStatus =>
      switch (_cameraPermission) {
        'Granted' => const _ReadinessStatus('Granted', _ReadinessKind.ready),
        'Not granted' => const _ReadinessStatus(
          'Permission required',
          _ReadinessKind.attention,
        ),
        _ => const _ReadinessStatus('Not checked', _ReadinessKind.neutral),
      };

  _ReadinessStatus get _arCoreInstallationStatus => switch (_arCoreReady) {
    'Yes' => const _ReadinessStatus(
      'Installed and current',
      _ReadinessKind.ready,
    ),
    'No' => const _ReadinessStatus(
      'Install or update required',
      _ReadinessKind.attention,
    ),
    _ => const _ReadinessStatus('Not checked', _ReadinessKind.neutral),
  };

  _ReadinessStatus get _arCoreFormalStatus {
    if (_arCorePreflightSnapshot == null) {
      return const _ReadinessStatus('Not checked', _ReadinessKind.neutral);
    }
    if (_cameraPermission != 'Granted') {
      return const _ReadinessStatus(
        'Permission required',
        _ReadinessKind.attention,
      );
    }
    return _canRunFormalArCoreDiagnostic == true
        ? const _ReadinessStatus('Ready', _ReadinessKind.ready)
        : const _ReadinessStatus('Unavailable', _ReadinessKind.unavailable);
  }

  _ReadinessStatus get _arCoreTrackingStatus {
    if (_isArCoreTrackingLoading) {
      return const _ReadinessStatus('Tracking', _ReadinessKind.busy);
    }
    if (_arCoreHasError &&
        _lastArCoreOperation == _DiagnosticOperation.arCoreTracking) {
      return const _ReadinessStatus('Error', _ReadinessKind.error);
    }
    final Map<String, Object?>? tracking = _arCoreTrackingSnapshot;
    if (tracking != null) {
      return tracking['validTrackingSummary'] == true
          ? const _ReadinessStatus('Completed', _ReadinessKind.ready)
          : const _ReadinessStatus('Review result', _ReadinessKind.attention);
    }
    if (_arCorePreflightSnapshot == null) {
      return const _ReadinessStatus('Not checked', _ReadinessKind.neutral);
    }
    return _canRunFormalArCoreDiagnostic == true
        ? const _ReadinessStatus('Ready', _ReadinessKind.ready)
        : const _ReadinessStatus('Action required', _ReadinessKind.attention);
  }

  _ReadinessStatus get _arCoreEnuReadinessStatus {
    if (_isArCoreEnuPreflightLoading || _isArCoreEnuDiagnosticLoading) {
      return const _ReadinessStatus('Running', _ReadinessKind.busy);
    }
    if (_arCoreHasError &&
        (_lastArCoreOperation == _DiagnosticOperation.arCoreEnuPreflight ||
            _lastArCoreOperation == _DiagnosticOperation.arCoreEnuDiagnostic)) {
      return const _ReadinessStatus('Error', _ReadinessKind.error);
    }
    if (_arCoreEnuResult != null) {
      return const _ReadinessStatus('Completed', _ReadinessKind.ready);
    }
    final ArCoreEnuPreflight? preflight = _arCoreEnuPreflight;
    if (preflight == null) {
      return const _ReadinessStatus('Not checked', _ReadinessKind.neutral);
    }
    if (!preflight.nativeReady ||
        _gnssAnchorState != GnssAnchorRuntimeState.anchorLocked ||
        _gnssAnchor == null) {
      return const _ReadinessStatus(
        'Action required',
        _ReadinessKind.attention,
      );
    }
    return const _ReadinessStatus('Ready', _ReadinessKind.ready);
  }

  Widget _buildArCoreEnuDiagnosticModule(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Map<String, Object?>? tracking = _arCoreTrackingSnapshot;
    final Map<String, Object?> enuDetails = <String, Object?>{
      'runtimeStatus': _arCoreEnuStatus,
      'alignmentStatus': _arCoreEnuAlignmentStatus,
      if (_arCoreEnuPreflight != null)
        'preflight': _arCoreEnuPreflight!.sanitizedMetadata,
      if (_arCoreEnuResult != null)
        'result': _arCoreEnuResult!.sanitizedMetadata,
    };
    final bool readinessError =
        _arCoreHasError &&
        (_lastArCoreOperation == _DiagnosticOperation.arCorePreflight ||
            _lastArCoreOperation == _DiagnosticOperation.arCorePermission);
    final bool trackingError =
        _arCoreHasError &&
        _lastArCoreOperation == _DiagnosticOperation.arCoreTracking;
    final bool enuError =
        _arCoreHasError &&
        (_lastArCoreOperation == _DiagnosticOperation.arCoreEnuPreflight ||
            _lastArCoreOperation == _DiagnosticOperation.arCoreEnuDiagnostic);

    return Column(
      key: const Key('arcore-enu-diagnostic-content'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _DashboardCard(
          emphasis: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _IconBadge(icon: Icons.view_in_ar, color: colors.primary),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'ARCore & ENU',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Visual-inertial tracking and relative motion alignment in the local ENU frame.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _DiagnosticStatusChip(status: _arCoreModuleStatus),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionEyebrow('DEVICE READINESS'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.fact_check_outlined,
                title: 'ARCore Readiness',
                description:
                    'Check device availability, installation state and camera authorization before tracking.',
              ),
              const SizedBox(height: 14),
              _DiagnosticStatusRow(
                label: 'Camera permission',
                status: _arCoreCameraPermissionStatus,
              ),
              const SizedBox(height: 9),
              _DiagnosticStatusRow(
                label: 'ARCore installation',
                status: _arCoreInstallationStatus,
              ),
              const SizedBox(height: 9),
              _DiagnosticStatusRow(
                label: 'Availability report',
                status: _arCorePreflightSnapshot == null
                    ? const _ReadinessStatus(
                        'Not checked',
                        _ReadinessKind.neutral,
                      )
                    : _ReadinessStatus(
                        _arCoreAvailability,
                        _arCoreReady == 'Yes'
                            ? _ReadinessKind.ready
                            : _ReadinessKind.attention,
                      ),
              ),
              const SizedBox(height: 9),
              _DiagnosticStatusRow(
                label: 'Formal tracking preflight',
                status: _arCoreFormalStatus,
              ),
              if (_arCorePreflightSnapshot != null) ...<Widget>[
                const SizedBox(height: 9),
                _DiagnosticStatusRow(
                  label: 'Device support',
                  status: _availabilityStatus(
                    _arCorePreflightSnapshot!['arCoreSupported'] as bool?,
                  ),
                ),
              ],
              if (readinessError) ...<Widget>[
                const SizedBox(height: 12),
                _DiagnosticNotice(
                  icon: Icons.error_outline,
                  title: 'ARCore readiness action failed',
                  message: _errorMessage!,
                  kind: _ReadinessKind.error,
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('arcore-preflight-action'),
                  onPressed: _isBusy ? null : _refreshArCorePreflight,
                  icon: _isArCorePreflightLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                    _isArCorePreflightLoading
                        ? 'Refreshing ARCore Preflight...'
                        : 'Refresh ARCore Readiness',
                  ),
                ),
              ),
              const SizedBox(height: 9),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('arcore-permission-action'),
                  onPressed: _isBusy ? null : _requestArCoreCameraPermission,
                  icon: _isArCorePermissionLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.camera_alt_outlined),
                  label: Text(
                    _isArCorePermissionLoading
                        ? 'Requesting Camera Permission...'
                        : 'Request Camera Permission',
                  ),
                ),
              ),
              if (_arCorePreflightSnapshot != null) ...<Widget>[
                const SizedBox(height: 8),
                _TechnicalDetailsExpansion(
                  expansionKey: const Key('arcore-readiness-technical-details'),
                  details: _jsonEncoder.convert(_arCorePreflightSnapshot),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionEyebrow('VISUAL-INERTIAL TRACKING'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.motion_photos_on_outlined,
                title: 'Visual-Inertial Tracking',
                description:
                    'Measure ARCore frame timing, tracking continuity and session-relative motion aggregates.',
              ),
              const SizedBox(height: 14),
              _DiagnosticStatusChip(status: _arCoreTrackingStatus),
              const SizedBox(height: 14),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _FactChip('Acquisition timeout · 30 s'),
                  _FactChip('Collection target · 30 s'),
                  _FactChip('Timestamp · Frame.timestamp'),
                ],
              ),
              const SizedBox(height: 14),
              _DiagnosticMetricGrid(
                key: const Key('arcore-tracking-metrics'),
                metrics: <_DiagnosticMetric>[
                  _DiagnosticMetric(
                    'Unique frames',
                    tracking?['uniqueFrameCount']?.toString() ??
                        'Not available',
                  ),
                  _DiagnosticMetric(
                    'Tracking frames',
                    tracking?['trackingFrameCount']?.toString() ??
                        'Not available',
                  ),
                  _DiagnosticMetric(
                    'Tracking fraction',
                    _formatRatioAsPercent(tracking?['trackingFraction']),
                  ),
                  _DiagnosticMetric(
                    'Observed rate',
                    _formatFrequency(tracking?['meanUniqueFrameRateHz']),
                  ),
                  _DiagnosticMetric(
                    'Paused frames',
                    tracking?['pausedFrameCount']?.toString() ??
                        'Not available',
                  ),
                  _DiagnosticMetric(
                    'Relative translation',
                    _formatObjectMeters(
                      tracking?['netSessionRelativeTranslationM'],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_isArCoreTrackingLoading)
                const _DiagnosticNotice(
                  icon: Icons.view_in_ar,
                  title: 'ARCore tracking running',
                  message:
                      'Waiting for tracking and collecting aggregate frame diagnostics. No raw camera frames or pose trajectory are retained.',
                  kind: _ReadinessKind.busy,
                )
              else if (trackingError)
                _DiagnosticNotice(
                  icon: Icons.error_outline,
                  title: 'ARCore tracking failed',
                  message: _errorMessage!,
                  kind: _ReadinessKind.error,
                )
              else if (tracking == null)
                const _DiagnosticNotice(
                  icon: Icons.info_outline,
                  title: 'Tracking not measured',
                  message:
                      'Complete ARCore readiness before starting the tracking diagnostic.',
                  kind: _ReadinessKind.neutral,
                )
              else
                _DiagnosticNotice(
                  icon: tracking['validTrackingSummary'] == true
                      ? Icons.check_circle_outline
                      : Icons.info_outline,
                  title: tracking['validTrackingSummary'] == true
                      ? 'Tracking summary completed'
                      : 'Tracking summary requires review',
                  message:
                      'Completion: ${tracking['completionReason'] ?? 'Unknown'}',
                  kind: tracking['validTrackingSummary'] == true
                      ? _ReadinessKind.ready
                      : _ReadinessKind.attention,
                ),
              const SizedBox(height: 12),
              const _DiagnosticNotice(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy boundary',
                message:
                    'Camera images and raw ARCore pose trajectories are not saved or returned.',
                kind: _ReadinessKind.neutral,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('arcore-tracking-run-action'),
                  onPressed: !_isBusy && _canRunFormalArCoreDiagnostic == true
                      ? _runArCoreTrackingDiagnostic
                      : null,
                  icon: _isArCoreTrackingLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.view_in_ar),
                  label: Text(
                    _isArCoreTrackingLoading
                        ? 'Running ARCore Tracking Diagnostic...'
                        : 'Run ARCore Tracking Diagnostic',
                  ),
                ),
              ),
              if (tracking != null) ...<Widget>[
                const SizedBox(height: 8),
                _TechnicalDetailsExpansion(
                  expansionKey: const Key('arcore-tracking-technical-details'),
                  details: _jsonEncoder.convert(tracking),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionEyebrow('LOCAL FRAME ALIGNMENT'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.threed_rotation,
                title: 'ARCore → ENU',
                description:
                    'Transform ARCore relative motion into the local East-North-Up frame using the existing explicit alignment.',
              ),
              const SizedBox(height: 14),
              _DiagnosticStatusChip(status: _arCoreEnuReadinessStatus),
              const SizedBox(height: 14),
              _DiagnosticStatusRow(
                label: 'ARCore support and installation',
                status: _availabilityStatus(
                  _arCoreEnuPreflight == null
                      ? null
                      : _arCoreEnuPreflight!.arCoreSupported &&
                            _arCoreEnuPreflight!.arCoreInstalled,
                ),
              ),
              const SizedBox(height: 9),
              _DiagnosticStatusRow(
                label: 'Rotation Vector',
                status: _availabilityStatus(
                  _arCoreEnuPreflight?.rotationVectorAvailable,
                ),
              ),
              const SizedBox(height: 9),
              _DiagnosticStatusRow(
                label: 'GNSS anchor',
                status:
                    _gnssAnchorState == GnssAnchorRuntimeState.anchorLocked &&
                        _gnssAnchor != null
                    ? const _ReadinessStatus('Locked', _ReadinessKind.ready)
                    : const _ReadinessStatus(
                        'Required',
                        _ReadinessKind.attention,
                      ),
              ),
              const SizedBox(height: 14),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _FactChip('Alignment hold · 2 s'),
                  _FactChip('Movement window · 30 s'),
                  _FactChip('Pose · Frame.getAndroidSensorPose()'),
                  _FactChip('Output frame · local ENU'),
                ],
              ),
              const SizedBox(height: 14),
              _DiagnosticMetricGrid(
                key: const Key('arcore-enu-result-metrics'),
                metrics: <_DiagnosticMetric>[
                  _DiagnosticMetric(
                    'Tracking fraction',
                    _arCoreEnuTrackingFractionLabel,
                  ),
                  _DiagnosticMetric(
                    'Usable ENU frames',
                    _arCoreEnuUsableFramesLabel,
                  ),
                  _DiagnosticMetric('Relative East', _arCoreEnuFinalEastLabel),
                  _DiagnosticMetric(
                    'Relative North',
                    _arCoreEnuFinalNorthLabel,
                  ),
                  _DiagnosticMetric('Relative Up', _arCoreEnuFinalUpLabel),
                  _DiagnosticMetric(
                    'Horizontal displacement',
                    _arCoreEnuHorizontalDisplacementLabel,
                  ),
                  _DiagnosticMetric(
                    '3D displacement',
                    _arCoreEnu3dDisplacementLabel,
                  ),
                  _DiagnosticMetric(
                    'Max horizontal excursion',
                    _arCoreEnuMaxHorizontalExcursionLabel,
                  ),
                  _DiagnosticMetric(
                    'Median frame interval',
                    _arCoreEnuMedianFrameIntervalLabel,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_isArCoreEnuDiagnosticLoading)
                _DiagnosticNotice(
                  icon: Icons.sync,
                  title: _arCoreEnuAlignmentStatus == 'Aligning'
                      ? 'Alignment running'
                      : 'ARCore → ENU running',
                  message:
                      'Hold the phone still during the existing alignment phase, then move within the formal window.',
                  kind: _ReadinessKind.busy,
                )
              else if (enuError)
                _DiagnosticNotice(
                  icon: Icons.error_outline,
                  title: 'ARCore → ENU action failed',
                  message: _errorMessage!,
                  kind: _ReadinessKind.error,
                )
              else if (_arCoreEnuResult == null)
                const _DiagnosticNotice(
                  icon: Icons.info_outline,
                  title: 'ENU motion not measured',
                  message:
                      'Complete preflight and lock a GNSS anchor before running the alignment diagnostic.',
                  kind: _ReadinessKind.neutral,
                ),
              const SizedBox(height: 12),
              const _DiagnosticNotice(
                icon: Icons.hub_outlined,
                title: 'Diagnostic scope',
                message:
                    'This diagnostic validates ARCore-to-ENU relative motion independently. Full PDR fusion and EKF updates are outside this diagnostic.',
                kind: _ReadinessKind.neutral,
              ),
              const SizedBox(height: 8),
              const _DiagnosticNotice(
                icon: Icons.science_outlined,
                title: 'Research limitation',
                message:
                    'ARCore position, distance, ENU alignment and true-north accuracy are not independently validated.',
                kind: _ReadinessKind.neutral,
              ),
              if (_arCoreEnuPreflight?.cameraPermissionGranted ==
                  false) ...<Widget>[
                const SizedBox(height: 12),
                const _DiagnosticNotice(
                  icon: Icons.camera_alt_outlined,
                  title: 'Camera permission required',
                  message:
                      'Grant camera permission from the ARCore Readiness section.',
                  kind: _ReadinessKind.attention,
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('arcore-enu-preflight-action'),
                  onPressed: _isBusy ? null : _refreshArCoreEnuPreflight,
                  icon: _isArCoreEnuPreflightLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                    _isArCoreEnuPreflightLoading
                        ? 'Refreshing ARCore → ENU Preflight...'
                        : 'Refresh ARCore → ENU Readiness',
                  ),
                ),
              ),
              const SizedBox(height: 9),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('arcore-enu-run-action'),
                  onPressed: _canRunArCoreEnuDiagnostic
                      ? _runArCoreEnuDiagnostic
                      : null,
                  icon: _isArCoreEnuDiagnosticLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.threed_rotation),
                  label: Text(
                    _isArCoreEnuDiagnosticLoading
                        ? 'Running ARCore → ENU Diagnostic...'
                        : 'Run ARCore → ENU Diagnostic',
                  ),
                ),
              ),
              if (_isArCoreEnuDiagnosticLoading) ...<Widget>[
                const SizedBox(height: 9),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    key: const Key('arcore-enu-cancel-action'),
                    onPressed: _arCoreEnuCancellationRequestInFlight
                        ? null
                        : _cancelArCoreEnuDiagnostic,
                    icon: const Icon(Icons.cancel_outlined),
                    label: Text(
                      _arCoreEnuCancellationRequestInFlight
                          ? 'Cancelling ARCore → ENU...'
                          : 'Cancel ARCore → ENU',
                    ),
                  ),
                ),
              ],
              if (enuDetails.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                _TechnicalDetailsExpansion(
                  expansionKey: const Key('arcore-enu-technical-details'),
                  details: _jsonEncoder.convert(enuDetails),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  _ReadinessStatus get _navguardFusionModuleStatus {
    if (_isNavguardFusionPreflightLoading ||
        _isNavguardFusionDiagnosticLoading) {
      return const _ReadinessStatus('Running', _ReadinessKind.busy);
    }
    if (_lastNavguardFusionOperation != null && _errorMessage != null) {
      return const _ReadinessStatus('Error', _ReadinessKind.error);
    }
    final NavguardFusionDiagnosticResult? result = _navguardFusionResult;
    if (result != null) {
      return switch (result.finalFusionQuality) {
        NavguardQuality.unavailable => const _ReadinessStatus(
          'Unavailable',
          _ReadinessKind.unavailable,
        ),
        NavguardQuality.degraded || NavguardQuality.unreliable =>
          const _ReadinessStatus('Degraded', _ReadinessKind.attention),
        _ => const _ReadinessStatus('Completed', _ReadinessKind.ready),
      };
    }
    if (_navguardFusionPreflight == null) {
      return const _ReadinessStatus('Not checked', _ReadinessKind.neutral);
    }
    if (_navguardFusionPreflight!.nativeReady &&
        _gnssAnchorState == GnssAnchorRuntimeState.anchorLocked &&
        _gnssAnchor != null) {
      return const _ReadinessStatus('Ready', _ReadinessKind.ready);
    }
    return const _ReadinessStatus('Unavailable', _ReadinessKind.unavailable);
  }

  _ReadinessStatus _qualityReadiness(NavguardQuality? quality) {
    return switch (quality) {
      NavguardQuality.good => const _ReadinessStatus(
        'GOOD',
        _ReadinessKind.ready,
      ),
      NavguardQuality.usable => const _ReadinessStatus(
        'USABLE',
        _ReadinessKind.ready,
      ),
      NavguardQuality.degraded => const _ReadinessStatus(
        'DEGRADED',
        _ReadinessKind.attention,
      ),
      NavguardQuality.unreliable => const _ReadinessStatus(
        'UNRELIABLE',
        _ReadinessKind.attention,
      ),
      NavguardQuality.unavailable => const _ReadinessStatus(
        'UNAVAILABLE',
        _ReadinessKind.unavailable,
      ),
      NavguardQuality.unknown ||
      null => const _ReadinessStatus('UNKNOWN', _ReadinessKind.neutral),
    };
  }

  String _formatHeadingDegreesAndRadians(double? value) {
    if (value == null) return 'Not available';
    final double degrees = value * 180 / math.pi;
    return '${degrees.toStringAsFixed(1)}° · ${value.toStringAsFixed(6)} rad';
  }

  Widget _buildFusionEkfDiagnosticModule(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final NavguardFusionPreflight? preflight = _navguardFusionPreflight;
    final NavguardFusionDiagnosticResult? result = _navguardFusionResult;
    final Map<String, Object?> metadata =
        result?.sanitizedMetadata ?? const <String, Object?>{};
    final bool actionError =
        _lastNavguardFusionOperation != null && _errorMessage != null;
    final Map<String, Object?> details = <String, Object?>{
      if (preflight != null) 'preflight': preflight.sanitizedMetadata,
      if (result != null) 'result': result.sanitizedMetadata,
    };
    String metadataValue(String key) =>
        metadata[key]?.toString() ?? 'Not available';
    _ReadinessStatus availabilityStatus(
      bool? value, {
      String readyLabel = 'Available',
      String unavailableLabel = 'Unavailable',
    }) {
      return switch (value) {
        true => _ReadinessStatus(readyLabel, _ReadinessKind.ready),
        false => _ReadinessStatus(unavailableLabel, _ReadinessKind.unavailable),
        null => const _ReadinessStatus('Not checked', _ReadinessKind.neutral),
      };
    }

    return Column(
      key: const Key('fusion-ekf-diagnostic-content'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _DashboardCard(
          emphasis: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _IconBadge(icon: Icons.hub_outlined, color: colors.primary),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Fusion & EKF',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Multi-source fusion, estimator state and uncertainty diagnostics.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _DiagnosticStatusChip(status: _navguardFusionModuleStatus),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionEyebrow('READINESS & CONFIGURATION'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.tune_outlined,
                title: 'Fusion Readiness',
                description:
                    'Native source availability and the estimator profile reported by this diagnostic.',
              ),
              const SizedBox(height: 16),
              _DiagnosticMetricGrid(
                metrics: <_DiagnosticMetric>[
                  _DiagnosticMetric(
                    'Selected configuration',
                    metadata['estimatorProfile']?.toString() ?? 'Not available',
                  ),
                  _DiagnosticMetric(
                    'State definition',
                    metadata['fusionStateDefinition']?.toString() ??
                        'Not available',
                  ),
                  _DiagnosticMetric('Anchor', _navguardFusionAnchorLabel),
                  _DiagnosticMetric(
                    'Alignment',
                    _navguardFusionAlignmentStatus,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _DiagnosticStatusRow(
                label: 'ARCore',
                status: availabilityStatus(
                  preflight == null
                      ? null
                      : preflight.arCoreSupported && preflight.arCoreInstalled,
                  readyLabel: 'Ready',
                ),
              ),
              const SizedBox(height: 8),
              _DiagnosticStatusRow(
                label: 'Camera permission',
                status: availabilityStatus(
                  preflight?.cameraPermissionGranted,
                  readyLabel: 'Granted',
                  unavailableLabel: 'Not granted',
                ),
              ),
              const SizedBox(height: 8),
              _DiagnosticStatusRow(
                label: 'Rotation Vector',
                status: availabilityStatus(preflight?.rotationVectorAvailable),
              ),
              const SizedBox(height: 8),
              _DiagnosticStatusRow(
                label: 'Step Detector',
                status: availabilityStatus(preflight?.stepDetectorAvailable),
              ),
              const SizedBox(height: 8),
              _DiagnosticStatusRow(
                label: 'Physical activity permission',
                status: availabilityStatus(
                  preflight?.activityRecognitionPermissionGranted,
                  readyLabel: 'Granted',
                  unavailableLabel: 'Not granted',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionEyebrow('ESTIMATOR'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.explore_outlined,
                title: 'Estimator State',
                description:
                    'Final local ENU state reported by the three-state fusion diagnostic.',
              ),
              const SizedBox(height: 16),
              if (result == null)
                const _DiagnosticNotice(
                  icon: Icons.info_outline,
                  title: 'Estimator state not measured',
                  message:
                      'Run the fusion diagnostic to populate the reported E, N and heading state.',
                  kind: _ReadinessKind.neutral,
                )
              else
                _DiagnosticMetricGrid(
                  key: const Key('fusion-estimator-state-metrics'),
                  metrics: <_DiagnosticMetric>[
                    _DiagnosticMetric(
                      'East',
                      _formatMeters(result.finalFusedEastM),
                    ),
                    _DiagnosticMetric(
                      'North',
                      _formatMeters(result.finalFusedNorthM),
                    ),
                    _DiagnosticMetric(
                      'Heading',
                      _formatHeadingDegreesAndRadians(
                        result.finalFusedHeadingRad,
                      ),
                    ),
                    _DiagnosticMetric(
                      'Horizontal displacement',
                      _formatMeters(result.finalFusedHorizontalDisplacementM),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionEyebrow('SOURCE CONTRIBUTIONS'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.account_tree_outlined,
                title: 'Applied Updates',
                description:
                    'Accepted estimator operations and quality-based skips reported by the completed run.',
              ),
              const SizedBox(height: 16),
              _DiagnosticMetricGrid(
                metrics: <_DiagnosticMetric>[
                  _DiagnosticMetric(
                    'Heading updates',
                    result?.headingMeasurementsApplied.toString() ??
                        'Not available',
                  ),
                  _DiagnosticMetric(
                    'PDR predictions',
                    result?.pdrPredictionsApplied.toString() ?? 'Not available',
                  ),
                  _DiagnosticMetric(
                    'ARCore updates',
                    result?.arcoreMeasurementsApplied.toString() ??
                        'Not available',
                  ),
                  _DiagnosticMetric(
                    'Heading quality skips',
                    metadataValue('headingMeasurementsSkippedByQuality'),
                  ),
                  _DiagnosticMetric(
                    'PDR quality skips',
                    metadataValue('pdrPredictionsSkippedByQuality'),
                  ),
                  _DiagnosticMetric(
                    'ARCore quality skips',
                    metadataValue('arcoreMeasurementsSkippedByQuality'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionEyebrow('QUALITY & UNCERTAINTY'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.insights_outlined,
                title: 'Quality & Uncertainty',
                description:
                    'Runtime quality classes and standard deviations derived from the reported final variances.',
              ),
              const SizedBox(height: 16),
              _DiagnosticStatusRow(
                label: 'Heading quality',
                status: _qualityReadiness(result?.finalHeadingQuality),
              ),
              const SizedBox(height: 8),
              _DiagnosticStatusRow(
                label: 'PDR quality',
                status: _qualityReadiness(result?.finalPdrQuality),
              ),
              const SizedBox(height: 8),
              _DiagnosticStatusRow(
                label: 'ARCore quality',
                status: _qualityReadiness(result?.finalArcoreQuality),
              ),
              const SizedBox(height: 8),
              _DiagnosticStatusRow(
                label: 'Fused quality',
                status: _qualityReadiness(result?.finalFusionQuality),
              ),
              const SizedBox(height: 12),
              _DiagnosticMetricGrid(
                metrics: <_DiagnosticMetric>[
                  _DiagnosticMetric(
                    'σ East',
                    _formatNavguardStandardDeviation(
                      result?.finalVarianceEastM2,
                      'm',
                    ),
                  ),
                  _DiagnosticMetric(
                    'σ North',
                    _formatNavguardStandardDeviation(
                      result?.finalVarianceNorthM2,
                      'm',
                    ),
                  ),
                  _DiagnosticMetric(
                    'σ Heading',
                    _formatNavguardStandardDeviation(
                      result?.finalVarianceHeadingRad2,
                      'rad',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const _DiagnosticNotice(
                icon: Icons.science_outlined,
                title: 'Research limitation',
                message:
                    'Fusion accuracy, quality thresholds and noise parameters are not independently validated.',
                kind: _ReadinessKind.neutral,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionEyebrow('RESULT & ACTIONS'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.fact_check_outlined,
                title: 'Diagnostic Result',
                description:
                    'Run state and integrity semantics reported by the current fusion diagnostic.',
              ),
              const SizedBox(height: 16),
              _DiagnosticMetricGrid(
                metrics: <_DiagnosticMetric>[
                  _DiagnosticMetric('Fusion state', _navguardFusionStatus),
                  _DiagnosticMetric(
                    'Joseph covariance update',
                    metadata['josephCovarianceUpdateUsed'] == null
                        ? 'Not available'
                        : metadata['josephCovarianceUpdateUsed'] == true
                        ? 'Reported active'
                        : 'Reported inactive',
                  ),
                  _DiagnosticMetric(
                    'Circular heading innovation',
                    metadata['circularHeadingInnovationUsed'] == null
                        ? 'Not available'
                        : metadata['circularHeadingInnovationUsed'] == true
                        ? 'Reported active'
                        : 'Reported inactive',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const _DiagnosticNotice(
                icon: Icons.route_outlined,
                title: 'Recovery scope',
                message:
                    'Recovery handling is evaluated in the full Denial & Recovery diagnostic.',
                kind: _ReadinessKind.neutral,
              ),
              if (_isNavguardFusionDiagnosticLoading) ...<Widget>[
                const SizedBox(height: 12),
                const _DiagnosticNotice(
                  icon: Icons.sync,
                  title: 'Fusion diagnostic running',
                  message:
                      'The existing alignment and formal fusion window are in progress.',
                  kind: _ReadinessKind.busy,
                ),
              ] else if (actionError) ...<Widget>[
                const SizedBox(height: 12),
                _DiagnosticNotice(
                  icon: Icons.error_outline,
                  title: 'Fusion action failed',
                  message: _errorMessage!,
                  kind: _ReadinessKind.error,
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('fusion-preflight-action'),
                  onPressed: _isBusy ? null : _refreshNavguardFusionPreflight,
                  icon: _isNavguardFusionPreflightLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                    _isNavguardFusionPreflightLoading
                        ? 'Refreshing Fusion Readiness...'
                        : 'Refresh Fusion Readiness',
                  ),
                ),
              ),
              const SizedBox(height: 9),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('fusion-run-action'),
                  onPressed: _canRunNavguardFusion
                      ? _runNavguardFusionDiagnostic
                      : null,
                  icon: _isNavguardFusionDiagnosticLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.hub_outlined),
                  label: Text(
                    _isNavguardFusionDiagnosticLoading
                        ? 'Running Fusion Diagnostic...'
                        : 'Run Fusion Diagnostic',
                  ),
                ),
              ),
              if (_isNavguardFusionDiagnosticLoading) ...<Widget>[
                const SizedBox(height: 9),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    key: const Key('fusion-cancel-action'),
                    onPressed: _navguardFusionCancellationRequestInFlight
                        ? null
                        : _cancelNavguardFusionDiagnostic,
                    icon: const Icon(Icons.cancel_outlined),
                    label: Text(
                      _navguardFusionCancellationRequestInFlight
                          ? 'Cancelling Fusion Diagnostic...'
                          : 'Cancel Fusion Diagnostic',
                    ),
                  ),
                ),
              ],
              if (details.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                _TechnicalDetailsExpansion(
                  expansionKey: const Key('fusion-technical-details'),
                  details: _jsonEncoder.convert(details),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  _ReadinessStatus get _fullNavguardFlowModuleStatus {
    if (_lastFullNavguardFlowOperation != null && _errorMessage != null) {
      return const _ReadinessStatus('Error', _ReadinessKind.error);
    }
    if (_isFullNavguardFlowDiagnosticLoading) {
      return switch (_fullNavguardFlowState) {
        FullNavguardFlowState.normalGnss => const _ReadinessStatus(
          'GNSS active',
          _ReadinessKind.ready,
        ),
        FullNavguardFlowState.deniedNavguard => const _ReadinessStatus(
          'GNSS denied',
          _ReadinessKind.attention,
        ),
        FullNavguardFlowState.recoveryPending => const _ReadinessStatus(
          'Recovery pending',
          _ReadinessKind.attention,
        ),
        FullNavguardFlowState.recoveredGnss => const _ReadinessStatus(
          'Recovered',
          _ReadinessKind.ready,
        ),
        _ => const _ReadinessStatus('Running', _ReadinessKind.busy),
      };
    }
    if (_isFullNavguardFlowPreflightLoading) {
      return const _ReadinessStatus('Running', _ReadinessKind.busy);
    }
    if (_fullNavguardFlowResult != null) {
      return const _ReadinessStatus('Completed', _ReadinessKind.ready);
    }
    if (_fullNavguardFlowState == FullNavguardFlowState.failed) {
      return const _ReadinessStatus('Error', _ReadinessKind.error);
    }
    if (_fullNavguardFlowPreflight == null) {
      return const _ReadinessStatus('Not checked', _ReadinessKind.neutral);
    }
    if (_fullNavguardFlowPreflight!.nativeReady &&
        _gnssAnchorState == GnssAnchorRuntimeState.anchorLocked &&
        _gnssAnchor != null) {
      return const _ReadinessStatus('Ready', _ReadinessKind.ready);
    }
    return const _ReadinessStatus('Unavailable', _ReadinessKind.unavailable);
  }

  Widget _buildDenialRecoveryDiagnosticModule(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final FullNavguardFlowPreflight? preflight = _fullNavguardFlowPreflight;
    final FullNavguardFlowDiagnosticResult? result = _fullNavguardFlowResult;
    final Map<String, Object?> metadata =
        result?.sanitizedMetadata ?? const <String, Object?>{};
    final bool actionError =
        _lastFullNavguardFlowOperation != null && _errorMessage != null;
    final Map<String, Object?> details = <String, Object?>{
      if (preflight != null) 'preflight': _fullFlowPreflightMetadata(preflight),
      if (result != null) 'result': result.sanitizedMetadata,
    };
    String reportedAccess(Object? value) => switch (value) {
      true => 'Allowed',
      false => 'Blocked',
      _ => 'Not available',
    };
    _ReadinessStatus readinessStatus(bool? value) => switch (value) {
      true => const _ReadinessStatus('Ready', _ReadinessKind.ready),
      false => const _ReadinessStatus('Not ready', _ReadinessKind.unavailable),
      null => const _ReadinessStatus('Not checked', _ReadinessKind.neutral),
    };

    return Column(
      key: const Key('denial-recovery-diagnostic-content'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _DashboardCard(
          emphasis: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _IconBadge(
                    icon: Icons.portable_wifi_off_outlined,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Denial & Recovery',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Software-defined GNSS denial, protected-reference isolation and controlled recovery diagnostics.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _DiagnosticStatusChip(status: _fullNavguardFlowModuleStatus),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionEyebrow('NAVIGATION STATE'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.navigation_outlined,
                title: 'Navigation State',
                description:
                    'Current diagnostic lifecycle state and required runtime readiness.',
              ),
              const SizedBox(height: 16),
              _DiagnosticMetricGrid(
                metrics: <_DiagnosticMetric>[
                  _DiagnosticMetric(
                    'Current state',
                    result?.finalState.wireValue ??
                        _fullNavguardFlowState.wireValue,
                  ),
                  _DiagnosticMetric('GNSS provider', _fullFlowGpsLabel),
                  _DiagnosticMetric('Anchor', _fullFlowAnchorLabel),
                  _DiagnosticMetric('ARCore', _fullFlowArCoreLabel),
                ],
              ),
              const SizedBox(height: 12),
              _DiagnosticStatusRow(
                label: 'Native full-flow readiness',
                status: readinessStatus(preflight?.nativeReady),
              ),
              const SizedBox(height: 8),
              _DiagnosticStatusRow(
                label: 'Location permission',
                status: readinessStatus(
                  preflight?.fineLocationPermissionGranted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionEyebrow('DENIAL & FIREWALL'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.shield_outlined,
                title: 'GNSS Denial & Ground Truth Firewall',
                description:
                    'Protected GNSS isolation and estimator activity reported during the denied interval.',
              ),
              const SizedBox(height: 16),
              _DiagnosticMetricGrid(
                key: const Key('denial-firewall-metrics'),
                metrics: <_DiagnosticMetric>[
                  _DiagnosticMetric(
                    'Estimator GNSS access',
                    reportedAccess(metadata['deniedGnssAvailableToEstimator']),
                  ),
                  _DiagnosticMetric(
                    'Denied GNSS used by estimator',
                    result?.deniedGnssUsedByEstimatorCount.toString() ??
                        'Not available',
                  ),
                  _DiagnosticMetric(
                    'Quarantined GNSS fixes',
                    result?.deniedGnssFixCount.toString() ?? 'Not available',
                  ),
                  _DiagnosticMetric(
                    'Firewall mutation self-test',
                    metadata['denialGnssMutationInvariancePassed'] == null
                        ? 'Not available'
                        : metadata['denialGnssMutationInvariancePassed'] == true
                        ? 'Reported passed'
                        : 'Reported failed',
                  ),
                  _DiagnosticMetric(
                    'Protected reference access',
                    metadata['protectedGroundTruthAccessed'] == null
                        ? 'Not available'
                        : metadata['protectedGroundTruthAccessed'] == true
                        ? 'Accessed'
                        : 'Not accessed',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _DiagnosticMetricGrid(
                metrics: <_DiagnosticMetric>[
                  _DiagnosticMetric(
                    'Denied PDR predictions',
                    result?.deniedPdrPredictionsApplied.toString() ??
                        'Not available',
                  ),
                  _DiagnosticMetric(
                    'Denied ARCore updates',
                    result?.deniedArcoreMeasurementsApplied.toString() ??
                        'Not available',
                  ),
                  _DiagnosticMetric(
                    'Denied heading updates',
                    result?.deniedHeadingMeasurementsApplied.toString() ??
                        'Not available',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const _DiagnosticNotice(
                icon: Icons.wifi_tethering_off_outlined,
                title: 'Software-defined denial',
                message:
                    'The physical GNSS listener may remain active while denied fixes are quarantined from estimator authorization.',
                kind: _ReadinessKind.neutral,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionEyebrow('RECOVERY'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.settings_backup_restore_outlined,
                title: 'GNSS Recovery',
                description:
                    'Fresh-fix admission, consecutive-fix gate and post-recovery observations reported by the diagnostic.',
              ),
              const SizedBox(height: 16),
              _DiagnosticMetricGrid(
                key: const Key('recovery-progress-metrics'),
                metrics: <_DiagnosticMetric>[
                  _DiagnosticMetric(
                    'Recovery state',
                    result?.finalState.wireValue ??
                        _fullNavguardFlowState.wireValue,
                  ),
                  _DiagnosticMetric(
                    'Candidate fixes',
                    result?.recoveryCandidateFixCount.toString() ??
                        'Not available',
                  ),
                  _DiagnosticMetric(
                    'Accepted fixes',
                    result?.recoveryAcceptedFixCount.toString() ??
                        'Not available',
                  ),
                  _DiagnosticMetric(
                    'Rejected fixes',
                    result?.recoveryRejectedFixCount.toString() ??
                        'Not available',
                  ),
                  _DiagnosticMetric(
                    'Consecutive recovery gate',
                    metadata['recoveryConsecutiveGoodFixesAchieved'] == null ||
                            metadata['recoveryConsecutiveGoodFixesRequired'] ==
                                null
                        ? 'Not available'
                        : '${metadata['recoveryConsecutiveGoodFixesAchieved']} / ${metadata['recoveryConsecutiveGoodFixesRequired']}',
                  ),
                  _DiagnosticMetric(
                    'Maximum reported accuracy',
                    metadata['maxOperationalGnssAccuracyM'] is num
                        ? '${(metadata['maxOperationalGnssAccuracyM']! as num).toDouble().toStringAsFixed(1)} m'
                        : 'Not available',
                  ),
                  _DiagnosticMetric(
                    'Recovered observations accepted',
                    result?.recoveredObservationAcceptedFixCount.toString() ??
                        'Not available',
                  ),
                  _DiagnosticMetric(
                    'Recovered observations rejected',
                    result?.recoveredObservationRejectedFixCount.toString() ??
                        'Not available',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.compare_arrows_outlined,
                title: 'Recovery Result',
                description:
                    'Estimator state before recovery and the accepted relocalized ENU state.',
              ),
              const SizedBox(height: 16),
              _DiagnosticMetricGrid(
                key: const Key('recovery-result-metrics'),
                metrics: <_DiagnosticMetric>[
                  _DiagnosticMetric(
                    'Recovery correction',
                    _formatMeters(result?.recoveryCorrectionDistanceM),
                  ),
                  _DiagnosticMetric(
                    'Pre-recovery East',
                    _formatMeters(result?.preRecoveryDeniedEastM),
                  ),
                  _DiagnosticMetric(
                    'Pre-recovery North',
                    _formatMeters(result?.preRecoveryDeniedNorthM),
                  ),
                  _DiagnosticMetric(
                    'Recovered East',
                    _formatMeters(result?.finalRecoveredEastM),
                  ),
                  _DiagnosticMetric(
                    'Recovered North',
                    _formatMeters(result?.finalRecoveredNorthM),
                  ),
                  _DiagnosticMetric(
                    'Recovered heading',
                    metadata['finalRecoveredHeadingRad'] is num
                        ? _formatHeadingDegreesAndRadians(
                            (metadata['finalRecoveredHeadingRad']! as num)
                                .toDouble(),
                          )
                        : 'Not available',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const _DiagnosticNotice(
                icon: Icons.straighten_outlined,
                title: 'Recovery correction',
                message:
                    'Estimator-to-recovered-GNSS discrepancy before relocalization.',
                kind: _ReadinessKind.neutral,
              ),
              const SizedBox(height: 8),
              const _DiagnosticNotice(
                icon: Icons.science_outlined,
                title: 'Research limitation',
                message:
                    'Recovery and full-flow navigation accuracy are not independently validated.',
                kind: _ReadinessKind.neutral,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionEyebrow('ACTIONS'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.play_circle_outline,
                title: 'Diagnostic Actions',
                description:
                    'Run the existing full-flow state machine or cancel the active diagnostic.',
              ),
              if (_isFullNavguardFlowDiagnosticLoading) ...<Widget>[
                const SizedBox(height: 16),
                _DiagnosticNotice(
                  icon: Icons.sync,
                  title: 'Full-flow diagnostic running',
                  message:
                      'Current lifecycle state: ${_fullNavguardFlowState.wireValue}.',
                  kind: _ReadinessKind.busy,
                ),
              ] else if (actionError) ...<Widget>[
                const SizedBox(height: 16),
                _DiagnosticNotice(
                  icon: Icons.error_outline,
                  title: 'Denial and recovery action failed',
                  message: _errorMessage!,
                  kind: _ReadinessKind.error,
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('denial-recovery-preflight-action'),
                  onPressed: _isBusy ? null : _refreshFullNavguardFlowPreflight,
                  icon: _isFullNavguardFlowPreflightLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                    _isFullNavguardFlowPreflightLoading
                        ? 'Refreshing Full-Flow Readiness...'
                        : 'Refresh Full-Flow Readiness',
                  ),
                ),
              ),
              const SizedBox(height: 9),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('denial-recovery-run-action'),
                  onPressed: _canRunFullNavguardFlow
                      ? _runFullNavguardFlowDiagnostic
                      : null,
                  icon: _isFullNavguardFlowDiagnosticLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.navigation_outlined),
                  label: Text(
                    _isFullNavguardFlowDiagnosticLoading
                        ? 'Running Denial & Recovery Diagnostic...'
                        : 'Run Denial & Recovery Diagnostic',
                  ),
                ),
              ),
              if (_isFullNavguardFlowDiagnosticLoading) ...<Widget>[
                const SizedBox(height: 9),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    key: const Key('denial-recovery-cancel-action'),
                    onPressed: _fullNavguardFlowCancellationRequestInFlight
                        ? null
                        : _cancelFullNavguardFlowDiagnostic,
                    icon: const Icon(Icons.cancel_outlined),
                    label: Text(
                      _fullNavguardFlowCancellationRequestInFlight
                          ? 'Cancelling Denial & Recovery...'
                          : 'Cancel Denial & Recovery',
                    ),
                  ),
                ),
              ],
              if (details.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                _TechnicalDetailsExpansion(
                  expansionKey: const Key('denial-recovery-technical-details'),
                  details: _jsonEncoder.convert(details),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEvaluationGtfDiagnosticModule(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final EvaluationModePreflight? preflight = _evaluationModePreflight;
    final EvaluationModeDiagnosticResult? result = _evaluationModeResult;
    final Map<String, Object?> metadata =
        result?.sanitizedMetadata ?? const <String, Object?>{};
    final bool anchorReady =
        _gnssAnchorState == GnssAnchorRuntimeState.anchorLocked &&
        _gnssAnchor != null;
    final bool actionError =
        _lastEvaluationModeOperation != null && _errorMessage != null;
    final Map<String, Object?> details = <String, Object?>{
      if (preflight != null) 'preflight': preflight.sanitizedMetadata,
      if (result != null) 'result': result.sanitizedMetadata,
    };

    _ReadinessStatus availability(
      bool? value, {
      String readyLabel = 'Available',
      String unavailableLabel = 'Unavailable',
    }) => switch (value) {
      true => _ReadinessStatus(readyLabel, _ReadinessKind.ready),
      false => _ReadinessStatus(unavailableLabel, _ReadinessKind.unavailable),
      null => const _ReadinessStatus('Not checked', _ReadinessKind.neutral),
    };

    _ReadinessStatus isolation(String key) => switch (metadata[key]) {
      false => const _ReadinessStatus('Isolated', _ReadinessKind.ready),
      true => const _ReadinessStatus('Access reported', _ReadinessKind.error),
      _ => const _ReadinessStatus('Not measured', _ReadinessKind.neutral),
    };

    final _ReadinessStatus moduleStatus = _isEvaluationModeDiagnosticLoading
        ? const _ReadinessStatus('RUNNING', _ReadinessKind.busy)
        : actionError
        ? const _ReadinessStatus('ACTION FAILED', _ReadinessKind.error)
        : result != null
        ? const _ReadinessStatus('RESULT AVAILABLE', _ReadinessKind.ready)
        : preflight == null
        ? const _ReadinessStatus('NOT CHECKED', _ReadinessKind.neutral)
        : preflight.nativeReady && anchorReady
        ? const _ReadinessStatus('READY', _ReadinessKind.ready)
        : const _ReadinessStatus(
            'ATTENTION REQUIRED',
            _ReadinessKind.attention,
          );

    return Column(
      key: const Key('evaluation-gtf-diagnostic-content'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _DashboardCard(
          emphasis: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _IconBadge(
                    icon: Icons.shield_outlined,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Evaluation & GTF',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Denied-estimator evaluation against a protected GNSS reference behind the Ground Truth Firewall.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _DiagnosticStatusChip(status: moduleStatus),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionEyebrow('READINESS'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.rule_outlined,
                title: 'Evaluation Readiness',
                description:
                    'Native prerequisites and the locked local-reference requirement for the existing evaluation flow.',
              ),
              const SizedBox(height: 16),
              _DiagnosticStatusRow(
                label: 'GNSS anchor',
                status: availability(
                  preflight == null ? null : anchorReady,
                  readyLabel: 'Locked',
                  unavailableLabel: 'Required',
                ),
              ),
              const SizedBox(height: 8),
              _DiagnosticStatusRow(
                label: 'GPS provider',
                status: availability(
                  preflight == null
                      ? null
                      : preflight.gpsProviderAvailable &&
                            preflight.gpsProviderEnabled,
                  readyLabel: 'Enabled',
                  unavailableLabel: 'Unavailable or disabled',
                ),
              ),
              const SizedBox(height: 8),
              _DiagnosticStatusRow(
                label: 'Precise location permission',
                status: availability(
                  preflight?.fineLocationPermissionGranted,
                  readyLabel: 'Granted',
                  unavailableLabel: 'Not granted',
                ),
              ),
              const SizedBox(height: 8),
              _DiagnosticStatusRow(
                label: 'Rotation Vector',
                status: availability(preflight?.rotationVectorAvailable),
              ),
              const SizedBox(height: 8),
              _DiagnosticStatusRow(
                label: 'Step Detector',
                status: availability(preflight?.stepDetectorAvailable),
              ),
              const SizedBox(height: 8),
              _DiagnosticStatusRow(
                label: 'Physical activity permission',
                status: availability(
                  preflight == null
                      ? null
                      : !preflight.activityRecognitionPermissionRequired ||
                            preflight.activityRecognitionPermissionGranted,
                  readyLabel:
                      preflight?.activityRecognitionPermissionRequired == false
                      ? 'Not required'
                      : 'Granted',
                  unavailableLabel: 'Not granted',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionEyebrow('GROUND TRUTH FIREWALL'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.lock_outline,
                title: 'Protected Reference Isolation',
                description:
                    'The physical GNSS stream remains comparator-only and must not influence the denied estimator.',
              ),
              const SizedBox(height: 16),
              _DiagnosticStatusRow(
                label: 'Estimator GNSS API access',
                status: isolation('protectedGnssAvailableToEstimatorApi'),
              ),
              const SizedBox(height: 8),
              _DiagnosticStatusRow(
                label: 'Denied estimator use',
                status: isolation('protectedGnssUsedByDeniedEstimator'),
              ),
              const SizedBox(height: 8),
              _DiagnosticStatusRow(
                label: 'Heading / step-length use',
                status: result == null
                    ? const _ReadinessStatus(
                        'Not measured',
                        _ReadinessKind.neutral,
                      )
                    : metadata['protectedGnssUsedByHeading'] == false &&
                          metadata['protectedGnssUsedByStepLength'] == false
                    ? const _ReadinessStatus('Isolated', _ReadinessKind.ready)
                    : const _ReadinessStatus(
                        'Use reported',
                        _ReadinessKind.error,
                      ),
              ),
              const SizedBox(height: 8),
              _DiagnosticStatusRow(
                label: 'Quality engine / controller use',
                status: result == null
                    ? const _ReadinessStatus(
                        'Not measured',
                        _ReadinessKind.neutral,
                      )
                    : metadata['protectedGnssUsedByQualityEngine'] == false &&
                          metadata['protectedGnssUsedByController'] == false
                    ? const _ReadinessStatus('Isolated', _ReadinessKind.ready)
                    : const _ReadinessStatus(
                        'Use reported',
                        _ReadinessKind.error,
                      ),
              ),
              const SizedBox(height: 8),
              _DiagnosticStatusRow(
                label: 'Mutation-invariance self-test',
                status: availability(
                  result == null
                      ? preflight?.firewallMutationSelfTestPassed
                      : metadata['firewallMutationSelfTestPassed'] as bool?,
                  readyLabel: 'Passed',
                  unavailableLabel: 'Failed',
                ),
              ),
              const SizedBox(height: 12),
              const _DiagnosticNotice(
                icon: Icons.privacy_tip_outlined,
                title: 'Protected reference only',
                message:
                    'Raw GNSS coordinates and trajectories are not presented. Only sanitized aggregate comparison metrics are shown.',
                kind: _ReadinessKind.neutral,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionEyebrow('ESTIMATOR VS PROTECTED REFERENCE'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.compare_arrows,
                title: 'Evaluation Result',
                description:
                    'Aggregate local-ENU estimator state and protected-reference discrepancy from the completed 30-second window.',
              ),
              const SizedBox(height: 16),
              if (result == null)
                const _DiagnosticNotice(
                  icon: Icons.info_outline,
                  title: 'Evaluation not run',
                  message:
                      'Refresh readiness, lock the anchor and run Evaluation Mode to populate protected-reference aggregates.',
                  kind: _ReadinessKind.neutral,
                )
              else
                _DiagnosticMetricGrid(
                  key: const Key('evaluation-result-metrics'),
                  metrics: <_DiagnosticMetric>[
                    _DiagnosticMetric(
                      'Denied estimator',
                      evaluationDeniedEstimatorProfile,
                    ),
                    _DiagnosticMetric(
                      'Integrated steps',
                      result.integratedStepCount.toString(),
                    ),
                    _DiagnosticMetric(
                      'Final East',
                      _formatMeters(result.finalDeniedEastM),
                    ),
                    _DiagnosticMetric(
                      'Final North',
                      _formatMeters(result.finalDeniedNorthM),
                    ),
                    _DiagnosticMetric(
                      'Protected fixes',
                      result.acceptedProtectedGtFixCount.toString(),
                    ),
                    _DiagnosticMetric(
                      'Matched fixes',
                      result.matchedGroundTruthFixCount.toString(),
                    ),
                    _DiagnosticMetric(
                      'Median discrepancy',
                      _formatMeters(result.medianHorizontalErrorM),
                    ),
                    _DiagnosticMetric(
                      'P95 discrepancy',
                      _formatMeters(result.p95HorizontalErrorM),
                    ),
                    _DiagnosticMetric(
                      'Final pre-correction discrepancy',
                      _formatMeters(result.finalDeniedPreCorrectionErrorM),
                    ),
                    _DiagnosticMetric(
                      'Median estimator age',
                      '${result.medianEstimatorAgeAtGtMs.toStringAsFixed(3)} ms',
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              const _DiagnosticNotice(
                icon: Icons.science_outlined,
                title: 'Research interpretation',
                message:
                    'These are protected-reference discrepancy measurements for this diagnostic session, not independently validated navigation accuracy.',
                kind: _ReadinessKind.neutral,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionEyebrow('ACTIONS & DETAILS'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.play_circle_outline,
                title: 'Evaluation Actions',
                description:
                    'Use the existing preflight, run and cancellation paths without changing the evaluation contract.',
              ),
              if (_isEvaluationModeDiagnosticLoading) ...<Widget>[
                const SizedBox(height: 16),
                _DiagnosticNotice(
                  icon: Icons.sync,
                  title: 'Evaluation running',
                  message: 'Current evaluation state: $_evaluationModeStatus.',
                  kind: _ReadinessKind.busy,
                ),
              ] else if (actionError) ...<Widget>[
                const SizedBox(height: 16),
                _DiagnosticNotice(
                  icon: Icons.error_outline,
                  title: 'Evaluation action failed',
                  message: _errorMessage!,
                  kind: _ReadinessKind.error,
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('evaluation-preflight-action'),
                  onPressed: _isBusy ? null : _refreshEvaluationModePreflight,
                  icon: _isEvaluationModePreflightLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                    _isEvaluationModePreflightLoading
                        ? 'Refreshing Evaluation Readiness...'
                        : 'Refresh Evaluation Readiness',
                  ),
                ),
              ),
              const SizedBox(height: 9),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('evaluation-run-action'),
                  onPressed: _canRunEvaluationMode
                      ? _runEvaluationModeDiagnostic
                      : null,
                  icon: _isEvaluationModeDiagnosticLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow),
                  label: Text(
                    _isEvaluationModeDiagnosticLoading
                        ? 'Running Evaluation Mode...'
                        : 'Run Evaluation Mode',
                  ),
                ),
              ),
              if (_isEvaluationModeDiagnosticLoading) ...<Widget>[
                const SizedBox(height: 9),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    key: const Key('evaluation-cancel-action'),
                    onPressed: _evaluationModeCancellationRequestInFlight
                        ? null
                        : _cancelEvaluationModeDiagnostic,
                    icon: const Icon(Icons.cancel_outlined),
                    label: Text(
                      _evaluationModeCancellationRequestInFlight
                          ? 'Cancelling Evaluation...'
                          : 'Cancel Evaluation',
                    ),
                  ),
                ),
              ],
              if (details.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                _TechnicalDetailsExpansion(
                  expansionKey: const Key('evaluation-technical-details'),
                  details: _jsonEncoder.convert(details),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBenchmarksDiagnosticModule(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final NavguardBenchmarkPreflight? preflight = _navguardBenchmarkPreflight;
    final NavguardBenchmarkDiagnosticResult? result = _navguardBenchmarkResult;
    final Map<String, Object?> metadata =
        result?.sanitizedMetadata ?? const <String, Object?>{};
    final bool anchorReady =
        _gnssAnchorState == GnssAnchorRuntimeState.anchorLocked &&
        _gnssAnchor != null;
    final bool actionError =
        _lastNavguardBenchmarkOperation != null && _errorMessage != null;
    final Map<String, Object?> details = <String, Object?>{
      if (preflight != null)
        'preflight': _benchmarkPreflightMetadata(preflight),
      if (result != null) 'result': result.sanitizedMetadata,
    };

    _ReadinessStatus availability(
      bool? value, {
      String readyLabel = 'Available',
      String unavailableLabel = 'Unavailable',
    }) => switch (value) {
      true => _ReadinessStatus(readyLabel, _ReadinessKind.ready),
      false => _ReadinessStatus(unavailableLabel, _ReadinessKind.unavailable),
      null => const _ReadinessStatus('Not checked', _ReadinessKind.neutral),
    };

    String configLabel(NavguardBenchmarkConfig config) => switch (config) {
      NavguardBenchmarkConfig.a => 'Config A',
      NavguardBenchmarkConfig.b => 'Config B',
      NavguardBenchmarkConfig.c => 'Config C',
      NavguardBenchmarkConfig.d => 'Config D',
    };

    final _ReadinessStatus moduleStatus = _isNavguardBenchmarkDiagnosticLoading
        ? const _ReadinessStatus('RUNNING', _ReadinessKind.busy)
        : actionError
        ? const _ReadinessStatus('ACTION FAILED', _ReadinessKind.error)
        : result != null
        ? const _ReadinessStatus('RESULT AVAILABLE', _ReadinessKind.ready)
        : preflight == null
        ? const _ReadinessStatus('NOT CHECKED', _ReadinessKind.neutral)
        : preflight.nativeReady && anchorReady
        ? const _ReadinessStatus('READY', _ReadinessKind.ready)
        : const _ReadinessStatus(
            'ATTENTION REQUIRED',
            _ReadinessKind.attention,
          );

    return Column(
      key: const Key('benchmarks-diagnostic-content'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _DashboardCard(
          emphasis: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _IconBadge(
                    icon: Icons.analytics_outlined,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Benchmarks',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Matched-session Config A/B/C/D research comparison with protected ground truth.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _DiagnosticStatusChip(status: moduleStatus),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionEyebrow('READINESS'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.rule_outlined,
                title: 'Benchmark Readiness',
                description:
                    'Same-session capture prerequisites for all four preserved benchmark configurations.',
              ),
              const SizedBox(height: 16),
              _DiagnosticMetricGrid(
                metrics: <_DiagnosticMetric>[
                  _DiagnosticMetric(
                    'Current phase',
                    _navguardBenchmarkPhase.displayLabel,
                  ),
                  _DiagnosticMetric(
                    'GNSS anchor',
                    preflight == null
                        ? 'Not checked'
                        : anchorReady
                        ? 'Locked'
                        : 'Required',
                  ),
                  _DiagnosticMetric(
                    'Denied window',
                    '${navguardBenchmarkDeniedWindowMs ~/ 1000} s',
                  ),
                  const _DiagnosticMetric(
                    'Primary comparison',
                    'Config D vs Config A',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _DiagnosticStatusRow(
                label: 'GNSS and location permission',
                status: availability(
                  preflight == null
                      ? null
                      : preflight.gpsProviderAvailable &&
                            preflight.gpsProviderEnabled &&
                            preflight.fineLocationPermissionGranted,
                  readyLabel: 'Ready',
                  unavailableLabel: 'Not ready',
                ),
              ),
              const SizedBox(height: 8),
              _DiagnosticStatusRow(
                label: 'Rotation Vector, Step Detector and activity permission',
                status: availability(
                  preflight == null
                      ? null
                      : preflight.rotationVectorAvailable &&
                            preflight.stepDetectorAvailable &&
                            preflight.activityRecognitionPermissionGranted,
                  readyLabel: 'Ready',
                  unavailableLabel: 'Not ready',
                ),
              ),
              const SizedBox(height: 8),
              _DiagnosticStatusRow(
                label: 'ARCore and camera permission',
                status: availability(
                  preflight == null
                      ? null
                      : preflight.arCoreSupported &&
                            preflight.arCoreInstalled &&
                            preflight.cameraPermissionGranted,
                  readyLabel: 'Ready',
                  unavailableLabel: 'Not ready',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionEyebrow('CONFIGURATION OVERVIEW'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.account_tree_outlined,
                title: 'Config A/B/C/D',
                description:
                    'Frozen configuration identifiers used by the existing matched-session benchmark.',
              ),
              const SizedBox(height: 16),
              _DiagnosticMetricGrid(
                key: const Key('benchmark-config-overview'),
                metrics: <_DiagnosticMetric>[
                  for (final NavguardBenchmarkConfig config
                      in NavguardBenchmarkConfig.values)
                    _DiagnosticMetric(configLabel(config), config.identifier),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionEyebrow('MATCHED RESULTS'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.query_stats_outlined,
                title: 'Protected-Reference Comparison',
                description:
                    'Per-configuration aggregate discrepancy from the same captured denial session.',
              ),
              const SizedBox(height: 16),
              if (result == null)
                const _DiagnosticNotice(
                  icon: Icons.info_outline,
                  title: 'Benchmark not run',
                  message:
                      'Run the matched benchmark to populate Config A/B/C/D aggregate results.',
                  kind: _ReadinessKind.neutral,
                )
              else ...<Widget>[
                for (final NavguardBenchmarkConfig config
                    in NavguardBenchmarkConfig.values) ...<Widget>[
                  Text(
                    '${configLabel(config)} · ${config.identifier}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _DiagnosticMetricGrid(
                    key: Key('benchmark-${config.mapKey}-metrics'),
                    metrics: <_DiagnosticMetric>[
                      _DiagnosticMetric(
                        'Matched / unmatched GT',
                        '${result.configMetrics[config]!.matchedGtCount} / ${result.configMetrics[config]!.unmatchedGtCount}',
                      ),
                      _DiagnosticMetric(
                        'Median discrepancy',
                        _formatMeters(
                          result.configMetrics[config]!.medianHorizontalErrorM,
                        ),
                      ),
                      _DiagnosticMetric(
                        'Mean discrepancy',
                        _formatMeters(
                          result.configMetrics[config]!.meanHorizontalErrorM,
                        ),
                      ),
                      _DiagnosticMetric(
                        'P95 discrepancy',
                        _formatMeters(
                          result.configMetrics[config]!.p95HorizontalErrorM,
                        ),
                      ),
                      _DiagnosticMetric(
                        'Maximum discrepancy',
                        _formatMeters(
                          result.configMetrics[config]!.maxHorizontalErrorM,
                        ),
                      ),
                      _DiagnosticMetric(
                        'Final pre-correction discrepancy',
                        _formatMeters(
                          result
                              .configMetrics[config]!
                              .finalPreCorrectionHorizontalErrorM,
                        ),
                      ),
                    ],
                  ),
                  if (config != NavguardBenchmarkConfig.d)
                    const SizedBox(height: 18),
                ],
                const SizedBox(height: 16),
                _DiagnosticNotice(
                  icon: result.dVsATargetMet
                      ? Icons.check_circle_outline
                      : Icons.info_outline,
                  title: result.dVsATargetMet
                      ? 'Research target met in this session'
                      : 'Research target not met in this session',
                  message:
                      'D vs A median improvement: ${result.dVsAMedianImprovementPercent?.toStringAsFixed(2) ?? 'Not available'}%. '
                      'The predefined research target is at least ${navguardBenchmarkTargetImprovementPercent.toStringAsFixed(0)}%.',
                  kind: result.dVsATargetMet
                      ? _ReadinessKind.ready
                      : _ReadinessKind.attention,
                ),
              ],
              const SizedBox(height: 12),
              const _DiagnosticNotice(
                icon: Icons.science_outlined,
                title: 'Research limitation',
                message:
                    'Session results and target status are descriptive research outputs. They do not establish independently validated accuracy or superiority.',
                kind: _ReadinessKind.neutral,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionEyebrow('INTEGRITY'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.verified_user_outlined,
                title: 'Benchmark Integrity',
                description:
                    'Native-reported capture fairness, causal matching and protected-reference isolation.',
              ),
              const SizedBox(height: 16),
              _DiagnosticStatusRow(
                label: 'Capture once, replay many',
                status: availability(
                  metadata['captureOnceReplayManyUsed'] as bool?,
                  readyLabel: 'Reported active',
                  unavailableLabel: 'Reported inactive',
                ),
              ),
              const SizedBox(height: 8),
              _DiagnosticStatusRow(
                label: 'Causal ground-truth matching',
                status: availability(
                  metadata['causalGroundTruthMatchingUsed'] as bool?,
                  readyLabel: 'Reported active',
                  unavailableLabel: 'Reported inactive',
                ),
              ),
              const SizedBox(height: 8),
              _DiagnosticStatusRow(
                label: 'Ground-truth mutation / removal invariance',
                status: result == null
                    ? const _ReadinessStatus(
                        'Not measured',
                        _ReadinessKind.neutral,
                      )
                    : metadata['benchmarkGroundTruthMutationInvariancePassed'] ==
                              true &&
                          metadata['benchmarkGroundTruthRemovalInvariancePassed'] ==
                              true
                    ? const _ReadinessStatus('Passed', _ReadinessKind.ready)
                    : const _ReadinessStatus('Failed', _ReadinessKind.error),
              ),
              const SizedBox(height: 8),
              _DiagnosticStatusRow(
                label: 'Protected GT estimator access',
                status: result == null
                    ? const _ReadinessStatus(
                        'Not measured',
                        _ReadinessKind.neutral,
                      )
                    : metadata['protectedGroundTruthAvailableToEstimators'] ==
                          false
                    ? const _ReadinessStatus('Isolated', _ReadinessKind.ready)
                    : const _ReadinessStatus(
                        'Access reported',
                        _ReadinessKind.error,
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionEyebrow('ACTIONS & DETAILS'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.play_circle_outline,
                title: 'Benchmark Actions',
                description:
                    'Run the existing matched A/B/C/D workflow or cancel its active diagnostic.',
              ),
              if (_isNavguardBenchmarkDiagnosticLoading) ...<Widget>[
                const SizedBox(height: 16),
                _DiagnosticNotice(
                  icon: Icons.sync,
                  title: 'Benchmark running',
                  message:
                      'Current phase: ${_navguardBenchmarkPhase.displayLabel}.',
                  kind: _ReadinessKind.busy,
                ),
              ] else if (actionError) ...<Widget>[
                const SizedBox(height: 16),
                _DiagnosticNotice(
                  icon: Icons.error_outline,
                  title: 'Benchmark action failed',
                  message: _errorMessage!,
                  kind: _ReadinessKind.error,
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('benchmark-preflight-action'),
                  onPressed: _isBusy
                      ? null
                      : _refreshNavguardBenchmarkPreflight,
                  icon: _isNavguardBenchmarkPreflightLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                    _isNavguardBenchmarkPreflightLoading
                        ? 'Refreshing Benchmark Readiness...'
                        : 'Refresh Benchmark Readiness',
                  ),
                ),
              ),
              const SizedBox(height: 9),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('benchmark-run-action'),
                  onPressed: _canRunNavguardBenchmark
                      ? _runNavguardBenchmarkDiagnostic
                      : null,
                  icon: _isNavguardBenchmarkDiagnosticLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow),
                  label: Text(
                    _isNavguardBenchmarkDiagnosticLoading
                        ? 'Running Matched Benchmark...'
                        : 'Run Matched A/B/C/D Benchmark',
                  ),
                ),
              ),
              if (_isNavguardBenchmarkDiagnosticLoading) ...<Widget>[
                const SizedBox(height: 9),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    key: const Key('benchmark-cancel-action'),
                    onPressed: _navguardBenchmarkCancellationRequestInFlight
                        ? null
                        : _cancelNavguardBenchmarkDiagnostic,
                    icon: const Icon(Icons.cancel_outlined),
                    label: Text(
                      _navguardBenchmarkCancellationRequestInFlight
                          ? 'Cancelling Benchmark...'
                          : 'Cancel Benchmark',
                    ),
                  ),
                ),
              ],
              if (details.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                _TechnicalDetailsExpansion(
                  expansionKey: const Key('benchmark-technical-details'),
                  details: _jsonEncoder.convert(details),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccuracyV2DiagnosticModule(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final AccuracyV2Preflight? preflight = _accuracyV2Preflight;
    final CalibrationProfile? profile = _accuracyV2Profile;
    final CalibrationResult? calibration = _accuracyV2CalibrationResult;
    final AccuracyV2DevelopmentBenchmarkResult? benchmark =
        _accuracyV2BenchmarkResult;
    final bool anchorReady =
        _gnssAnchorState == GnssAnchorRuntimeState.anchorLocked &&
        _gnssAnchor != null;
    final bool actionError =
        _lastAccuracyV2Operation != null && _errorMessage != null;
    final Map<String, Object?> details = <String, Object?>{
      if (preflight != null) 'preflight': preflight.sanitizedMetadata,
      if (profile != null) 'calibrationProfile': profile.sanitizedMetadata,
      if (calibration != null)
        'calibrationResult': calibration.sanitizedMetadata,
      if (benchmark != null)
        'developmentBenchmark': benchmark.sanitizedMetadata,
      if (_accuracyV2GnssFailureDiagnostics != null)
        'gnssStabilizationFailure':
            _accuracyV2GnssFailureDiagnostics!.sanitizedMetadata,
    };

    _ReadinessStatus availability(
      bool? value, {
      String readyLabel = 'Available',
      String unavailableLabel = 'Unavailable',
    }) => switch (value) {
      true => _ReadinessStatus(readyLabel, _ReadinessKind.ready),
      false => _ReadinessStatus(unavailableLabel, _ReadinessKind.unavailable),
      null => const _ReadinessStatus('Not checked', _ReadinessKind.neutral),
    };

    String percent(double? value) =>
        value == null ? 'Not available' : '${value.toStringAsFixed(2)}%';

    final _ReadinessStatus moduleStatus =
        _isAccuracyV2CalibrationLoading || _isAccuracyV2BenchmarkLoading
        ? const _ReadinessStatus('RUNNING', _ReadinessKind.busy)
        : actionError
        ? const _ReadinessStatus('ACTION FAILED', _ReadinessKind.error)
        : benchmark != null || calibration != null
        ? const _ReadinessStatus('RESULT AVAILABLE', _ReadinessKind.ready)
        : preflight == null
        ? const _ReadinessStatus('NOT CHECKED', _ReadinessKind.neutral)
        : preflight.nativeReady && anchorReady
        ? const _ReadinessStatus('READY', _ReadinessKind.ready)
        : const _ReadinessStatus(
            'ATTENTION REQUIRED',
            _ReadinessKind.attention,
          );

    return Column(
      key: const Key('accuracy-v2-diagnostic-content'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _DashboardCard(
          emphasis: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _IconBadge(icon: Icons.tune_outlined, color: colors.primary),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Accuracy v2',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Adaptive Config D-v2 calibration and development-only matched benchmark diagnostics.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _DiagnosticStatusChip(status: moduleStatus),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionEyebrow('READINESS'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.rule_outlined,
                title: 'Adaptive Runtime Readiness',
                description:
                    'Native prerequisites and conservative contract flags for Config D-v2.',
              ),
              const SizedBox(height: 16),
              _DiagnosticMetricGrid(
                metrics: <_DiagnosticMetric>[
                  const _DiagnosticMetric(
                    'Configuration',
                    navguardAdaptiveConfigId,
                  ),
                  _DiagnosticMetric(
                    'GNSS anchor',
                    preflight == null
                        ? 'Not checked'
                        : anchorReady
                        ? 'Locked'
                        : 'Required',
                  ),
                  _DiagnosticMetric(
                    'Native readiness',
                    preflight == null
                        ? 'Not checked'
                        : preflight.nativeReady
                        ? 'Ready'
                        : 'Not ready',
                  ),
                  _DiagnosticMetric(
                    'Engineering self-tests',
                    preflight == null
                        ? 'Not checked'
                        : preflight.selfTestsPassed
                        ? 'Passed'
                        : 'Failed',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _DiagnosticStatusRow(
                label: 'GNSS and precise location',
                status: availability(
                  preflight == null
                      ? null
                      : preflight.gpsProviderAvailable &&
                            preflight.gpsProviderEnabled &&
                            preflight.fineLocationPermissionGranted,
                  readyLabel: 'Ready',
                  unavailableLabel: 'Not ready',
                ),
              ),
              const SizedBox(height: 8),
              _DiagnosticStatusRow(
                label: 'Rotation Vector, Step Detector and activity permission',
                status: availability(
                  preflight == null
                      ? null
                      : preflight.rotationVectorAvailable &&
                            preflight.stepDetectorAvailable &&
                            preflight.activityRecognitionPermissionGranted,
                  readyLabel: 'Ready',
                  unavailableLabel: 'Not ready',
                ),
              ),
              const SizedBox(height: 8),
              _DiagnosticStatusRow(
                label: 'ARCore and camera permission',
                status: availability(
                  preflight == null
                      ? null
                      : preflight.arCoreSupported &&
                            preflight.arCoreInstalled &&
                            preflight.cameraPermissionGranted,
                  readyLabel: 'Ready',
                  unavailableLabel: 'Not ready',
                ),
              ),
              const SizedBox(height: 12),
              const _DiagnosticNotice(
                icon: Icons.science_outlined,
                title: 'Development-only mode',
                message:
                    'Config D-v2 is an adaptive research configuration. Accuracy is not independently validated and this screen is not a final-validation workflow.',
                kind: _ReadinessKind.neutral,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionEyebrow('CALIBRATION PROFILE'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.person_pin_circle_outlined,
                title: 'Adaptive Profile',
                description:
                    'Bounded stride and body-heading parameters returned by the existing calibration profile contract.',
              ),
              const SizedBox(height: 16),
              if (profile == null)
                const _DiagnosticNotice(
                  icon: Icons.info_outline,
                  title: 'Profile not loaded',
                  message:
                      'Refresh Accuracy v2 readiness to load the current calibration profile.',
                  kind: _ReadinessKind.neutral,
                )
              else
                _DiagnosticMetricGrid(
                  key: const Key('accuracy-v2-profile-metrics'),
                  metrics: <_DiagnosticMetric>[
                    _DiagnosticMetric(
                      'Stride estimate',
                      '${profile.strideEstimateM.toStringAsFixed(3)} m',
                    ),
                    _DiagnosticMetric(
                      'Body-heading offset',
                      '${profile.bodyHeadingOffsetDeg.toStringAsFixed(2)}°',
                    ),
                    _DiagnosticMetric(
                      'Stride samples',
                      profile.strideSampleCount.toString(),
                    ),
                    _DiagnosticMetric(
                      'Heading-offset samples',
                      profile.headingOffsetSampleCount.toString(),
                    ),
                    _DiagnosticMetric(
                      'Profile state',
                      profile.profilePersisted ? 'Persisted' : 'Default',
                    ),
                    _DiagnosticMetric('Storage', profile.profilePersistence),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionEyebrow('CALIBRATION'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.auto_fix_high_outlined,
                title: 'Adaptive Calibration',
                description:
                    'Development calibration aggregates for stride, body heading, robust ARCore updates and stationary detection.',
              ),
              if (_isAccuracyV2CalibrationLoading) ...<Widget>[
                const SizedBox(height: 16),
                _DiagnosticNotice(
                  icon: Icons.sync,
                  title: 'Calibration running',
                  message: _accuracyV2FinalDrainRemainingSeconds == null
                      ? 'Movement phase in progress. A 12-second delayed-step processing phase follows.'
                      : 'Processing delayed step events. Remain stationary (${_accuracyV2FinalDrainRemainingSeconds}s).',
                  kind: _ReadinessKind.busy,
                ),
                Text('', key: const Key('accuracy-v2-calibration-progress')),
              ],
              const SizedBox(height: 16),
              if (calibration == null)
                const _DiagnosticNotice(
                  icon: Icons.info_outline,
                  title: 'Calibration not run',
                  message:
                      'Run calibration to populate session aggregates and update the adaptive profile.',
                  kind: _ReadinessKind.neutral,
                )
              else
                _DiagnosticMetricGrid(
                  key: const Key('accuracy-v2-calibration-metrics'),
                  metrics: <_DiagnosticMetric>[
                    _DiagnosticMetric(
                      'Stride before → after',
                      '${calibration.strideEstimateBeforeM.toStringAsFixed(3)} → ${calibration.strideEstimateAfterM.toStringAsFixed(3)} m',
                    ),
                    _DiagnosticMetric(
                      'Heading offset before → after',
                      '${calibration.headingOffsetBeforeDeg.toStringAsFixed(2)}° → ${calibration.headingOffsetAfterDeg.toStringAsFixed(2)}°',
                    ),
                    _DiagnosticMetric(
                      'Steps received / applied',
                      '${calibration.stepsReceived} / ${calibration.stepsApplied}',
                    ),
                    _DiagnosticMetric(
                      'Drain-delivered steps',
                      calibration.stepsReceivedDuringFinalDrainCallbackDelivery
                          .toString(),
                    ),
                    _DiagnosticMetric(
                      'ARCore accepted / rejected',
                      '${calibration.arcoreAccepted} / ${calibration.arcoreRejected}',
                    ),
                    _DiagnosticMetric(
                      'Post-robust NIS mean / max',
                      '${calibration.arcorePostRobustNisMean.toStringAsFixed(2)} / ${calibration.arcorePostRobustNisMax.toStringAsFixed(2)}',
                    ),
                    _DiagnosticMetric(
                      'Stationary entries / duration',
                      '${calibration.stationaryEntryCount} / ${calibration.stationaryDetectedDurationMs} ms',
                    ),
                    _DiagnosticMetric(
                      'Source disagreement mean / max',
                      '${calibration.sourceDisagreementMeanM.toStringAsFixed(3)} / ${calibration.sourceDisagreementMaxM.toStringAsFixed(3)} m',
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('accuracy-v2-calibration'),
                  onPressed: _canRunAccuracyV2
                      ? _runAccuracyV2Calibration
                      : null,
                  icon: _isAccuracyV2CalibrationLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.tune),
                  label: Text(
                    _isAccuracyV2CalibrationLoading
                        ? 'Running Calibration...'
                        : 'Run Calibration',
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionEyebrow('DEVELOPMENT BENCHMARK'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.compare_arrows,
                title: 'Matched A / D-v1 / D-v2 Comparison',
                description:
                    'Development-only, same-session comparison using protected ground truth as comparator only.',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                key: const Key('accuracy-v2-development-scenario'),
                initialValue: _accuracyV2DevelopmentScenario,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Development benchmark scenario',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Select STRAIGHT, L_TURN, or MIXED'),
                items: accuracyV2DevelopmentScenarios
                    .map(
                      (String scenario) => DropdownMenuItem<String>(
                        value: scenario,
                        child: Text(scenario),
                      ),
                    )
                    .toList(growable: false),
                onChanged: _isBusy
                    ? null
                    : (String? scenario) {
                        setState(
                          () => _accuracyV2DevelopmentScenario = scenario,
                        );
                      },
              ),
              if (_isAccuracyV2BenchmarkLoading) ...<Widget>[
                const SizedBox(height: 12),
                _DiagnosticNotice(
                  icon: Icons.sync,
                  title: 'Development benchmark running',
                  message: _accuracyV2BenchmarkPhase == 'BENCHMARK_FINAL_DRAIN'
                      ? 'Processing delayed step events. Stand still (${_accuracyV2BenchmarkDrainRemainingSeconds ?? 0}s).'
                      : _accuracyV2BenchmarkPhase == 'BENCHMARK_FORMAL_WINDOW'
                      ? 'Formal movement window in progress; a 12-second stand-still processing phase follows.'
                      : _accuracyV2BenchmarkPhase == 'FINALIZING'
                      ? 'Finalizing development aggregates.'
                      : 'Stabilizing GNSS before the matched development window.',
                  kind: _ReadinessKind.busy,
                ),
                Text('', key: const Key('accuracy-v2-benchmark-progress')),
              ],
              if (_accuracyV2GnssFailureDiagnostics
                  case final AccuracyV2GnssStabilizationDiagnostics
                      failure) ...<Widget>[
                const SizedBox(height: 12),
                _DiagnosticNotice(
                  icon: Icons.gps_off_outlined,
                  title: 'GNSS stabilization incomplete',
                  message:
                      'Accepted ${failure.acceptedFixCount} of the minimum ${failure.minimumFixCount} fixes; ${failure.rejectedAccuracyCount} fixes were rejected by the accuracy gate.',
                  kind: _ReadinessKind.attention,
                ),
                Text('', key: const Key('accuracy-v2-gnss-failure')),
              ],
              const SizedBox(height: 16),
              if (benchmark == null)
                const _DiagnosticNotice(
                  icon: Icons.info_outline,
                  title: 'Development benchmark not run',
                  message:
                      'Select a scenario and run the benchmark to populate same-session A, D-v1 and D-v2 aggregates.',
                  kind: _ReadinessKind.neutral,
                )
              else ...<Widget>[
                _DiagnosticMetricGrid(
                  key: const Key('accuracy-v2-benchmark-capture-summary'),
                  metrics: <_DiagnosticMetric>[
                    _DiagnosticMetric(
                      'Scenario',
                      benchmark.developmentScenario,
                    ),
                    _DiagnosticMetric(
                      'Formal-window steps',
                      benchmark.benchmarkStepEventsInFormalWindow.toString(),
                    ),
                    _DiagnosticMetric(
                      'Included from final drain',
                      benchmark.benchmarkStepEventsIncludedFromFinalDrain
                          .toString(),
                    ),
                    _DiagnosticMetric(
                      'A / D-v1 / D-v2 steps',
                      '${benchmark.configAStepsApplied} / ${benchmark.configD1StepsApplied} / ${benchmark.configD2StepsApplied}',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _DiagnosticMetricGrid(
                  key: const Key('accuracy-v2-benchmark-summary'),
                  metrics: <_DiagnosticMetric>[
                    _DiagnosticMetric(
                      'Config A median',
                      _formatMeters(benchmark.configA.medianHorizontalErrorM),
                    ),
                    _DiagnosticMetric(
                      'Config D-v1 median',
                      _formatMeters(benchmark.configD1.medianHorizontalErrorM),
                    ),
                    _DiagnosticMetric(
                      'Config D-v2 median',
                      _formatMeters(benchmark.configD2.medianHorizontalErrorM),
                    ),
                    _DiagnosticMetric(
                      'D-v2 vs D-v1 median change',
                      percent(benchmark.d2VsD1MedianImprovementPercent),
                    ),
                    _DiagnosticMetric(
                      'D-v2 vs A median change',
                      percent(benchmark.d2VsAMedianImprovementPercent),
                    ),
                    _DiagnosticMetric(
                      'D-v2 vs D-v1 relative change',
                      percent(benchmark.d2VsD1RelativeMedianImprovementPercent),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _DiagnosticMetricGrid(
                  key: const Key('accuracy-v2-relative-summary'),
                  metrics: <_DiagnosticMetric>[
                    _DiagnosticMetric(
                      'D-v1 relative median',
                      _formatMeters(
                        benchmark.configD1.relativeMedianHorizontalErrorM,
                      ),
                    ),
                    _DiagnosticMetric(
                      'D-v2 relative median',
                      _formatMeters(
                        benchmark.configD2.relativeMedianHorizontalErrorM,
                      ),
                    ),
                    _DiagnosticMetric(
                      'D-v2 final stride',
                      '${benchmark.strideEstimateFinalM.toStringAsFixed(3)} m',
                    ),
                    _DiagnosticMetric(
                      'D-v2 final heading offset',
                      '${benchmark.bodyHeadingOffsetFinalDeg.toStringAsFixed(2)}°',
                    ),
                  ],
                ),
                Text('', key: const Key('accuracy-v2-robust-arcore-summary')),
                Text('', key: const Key('accuracy-v2-post-robust-summary')),
                Text('', key: const Key('accuracy-v2-stationary-summary')),
                Text('', key: const Key('accuracy-v2-gnss-result')),
                const SizedBox(height: 12),
                _DiagnosticStatusRow(
                  label: 'Protected GT mutation / removal invariance',
                  status:
                      benchmark.gtMutationInvariant &&
                          benchmark.gtRemovalInvariant
                      ? const _ReadinessStatus('Passed', _ReadinessKind.ready)
                      : const _ReadinessStatus('Failed', _ReadinessKind.error),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('accuracy-v2-development-benchmark'),
                  onPressed:
                      _canRunAccuracyV2 &&
                          _accuracyV2DevelopmentScenario != null
                      ? _runAccuracyV2DevelopmentBenchmark
                      : null,
                  icon: _isAccuracyV2BenchmarkLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.compare_arrows),
                  label: Text(
                    _isAccuracyV2BenchmarkLoading
                        ? 'Running Development Benchmark...'
                        : 'Run Development Benchmark',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const _DiagnosticNotice(
                icon: Icons.science_outlined,
                title: 'Development metrics only',
                message:
                    'The displayed changes are same-session development measurements. They are not final validation and do not prove real-world accuracy improvement.',
                kind: _ReadinessKind.neutral,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionEyebrow('PROFILE ACTIONS & DETAILS'),
        const SizedBox(height: 8),
        _DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DiagnosticSectionHeading(
                icon: Icons.settings_outlined,
                title: 'Profile Actions',
                description:
                    'Refresh native readiness and profile state, or invoke the existing profile reset action.',
              ),
              if (actionError) ...<Widget>[
                const SizedBox(height: 16),
                _DiagnosticNotice(
                  icon: Icons.error_outline,
                  title: 'Accuracy v2 action failed',
                  message: _errorMessage!,
                  kind: _ReadinessKind.error,
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('accuracy-v2-refresh'),
                  onPressed: _isBusy ? null : _refreshAccuracyV2Preflight,
                  icon: _isAccuracyV2PreflightLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                    _isAccuracyV2PreflightLoading
                        ? 'Refreshing Accuracy v2...'
                        : 'Refresh Accuracy v2 Readiness',
                  ),
                ),
              ),
              const SizedBox(height: 9),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('accuracy-v2-reset'),
                  onPressed: _isBusy ? null : _resetAccuracyV2Profile,
                  icon: _isAccuracyV2ResetLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.restart_alt),
                  label: Text(
                    _isAccuracyV2ResetLoading
                        ? 'Resetting Profile...'
                        : 'Reset Calibration Profile',
                  ),
                ),
              ),
              if (details.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                _TechnicalDetailsExpansion(
                  expansionKey: const Key('accuracy-v2-technical-details'),
                  details: _jsonEncoder.convert(details),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final _DashboardModule? module = _activeDashboardModule;
    if (module == null || !widget.diagnosticsAccessEnabled) {
      return _buildHomeDashboard(context);
    }

    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, void result) {
        if (!didPop) _closeDiagnosticModule();
      },
      child: _buildDiagnosticModule(context, module),
    );
  }

  Widget _buildHomeDashboard(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              key: const Key('home-dashboard-scroll'),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        key: const Key('navguard-hero'),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[
                              colors.primaryContainer,
                              colors.surface,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colors.primary.withValues(alpha: 0.14),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surface.withValues(alpha: 0.78),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Research Prototype',
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color: colors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'NAVGUARD',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: colors.onSurface,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'AI-Assisted GNSS-Denied Navigation',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: colors.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Sensor fusion, ARCore relative motion, and on-device AI for resilient mobile navigation research.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: colors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      if (widget.diagnosticsAccessEnabled) ...<Widget>[
                        const SizedBox(height: 24),
                        const _SectionEyebrow('System Readiness'),
                        const SizedBox(height: 8),
                        _DashboardCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              LayoutBuilder(
                                builder:
                                    (
                                      BuildContext context,
                                      BoxConstraints statusConstraints,
                                    ) {
                                      final int columns =
                                          statusConstraints.maxWidth >= 520
                                          ? 3
                                          : 2;
                                      final double tileWidth =
                                          (statusConstraints.maxWidth -
                                              (columns - 1) * 8) /
                                          columns;
                                      return Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: <Widget>[
                                          _ReadinessTile(
                                            width: tileWidth,
                                            icon: Icons.gps_fixed,
                                            label: 'GNSS',
                                            status: _gnssReadiness,
                                          ),
                                          _ReadinessTile(
                                            width: tileWidth,
                                            icon: Icons.sensors_outlined,
                                            label: 'Sensors',
                                            status: _sensorReadiness,
                                          ),
                                          _ReadinessTile(
                                            width: tileWidth,
                                            icon: Icons.view_in_ar_outlined,
                                            label: 'ARCore',
                                            status: _arCoreReadiness,
                                          ),
                                          _ReadinessTile(
                                            width: tileWidth,
                                            icon: Icons.psychology_outlined,
                                            label: 'AI Model',
                                            status: _aiReadiness,
                                          ),
                                          _ReadinessTile(
                                            width: tileWidth,
                                            icon: Icons.place_outlined,
                                            label: 'GNSS Anchor',
                                            status: _anchorReadiness,
                                          ),
                                        ],
                                      );
                                    },
                              ),
                              if (_systemRefreshError != null) ...<Widget>[
                                const SizedBox(height: 10),
                                Text(
                                  _systemRefreshError!,
                                  key: const Key('system-readiness-error'),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: colors.error),
                                ),
                              ],
                              const SizedBox(height: 14),
                              OutlinedButton.icon(
                                key: const Key('refresh-system-status'),
                                onPressed: _systemRefreshInProgress || _isBusy
                                    ? null
                                    : _refreshSystemStatus,
                                icon: _systemRefreshInProgress
                                    ? const SizedBox.square(
                                        dimension: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.refresh),
                                label: Text(
                                  _systemRefreshInProgress
                                      ? 'Refreshing status…'
                                      : 'Refresh System Status',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (!widget.diagnosticsAccessEnabled) ...<Widget>[
                        const SizedBox(height: 24),
                        const _SectionEyebrow('Navigation Setup'),
                        const SizedBox(height: 8),
                        _buildPublicAnchorSetupCard(context),
                      ],
                      const SizedBox(height: 24),
                      _DashboardCard(
                        emphasis: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                _IconBadge(
                                  icon: Icons.navigation_outlined,
                                  color: colors.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Live Navigation',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Real-time navigation through GNSS denial and recovery.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: colors.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            const Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: <Widget>[
                                _ModeChip('V1'),
                                _ModeChip('V2 Adaptive'),
                                _ModeChip('V3 · AI'),
                              ],
                            ),
                            const SizedBox(height: 14),
                            FilledButton.icon(
                              key: const Key('open-live-navguard-demo'),
                              onPressed: _isBusy ? null : _openLiveNavguardDemo,
                              icon: const Icon(Icons.map_outlined),
                              label: const Text('Open Live Map'),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _gnssAnchorState ==
                                          GnssAnchorRuntimeState.anchorLocked &&
                                      _gnssAnchor != null
                                  ? 'GNSS anchor locked'
                                  : 'Lock a GNSS anchor before starting Live Navigation.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: colors.onSurfaceVariant),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      if (widget.diagnosticsAccessEnabled) ...<Widget>[
                        const SizedBox(height: 28),
                        const _SectionEyebrow('Research Modules'),
                        const SizedBox(height: 8),
                        LayoutBuilder(
                          builder:
                              (
                                BuildContext context,
                                BoxConstraints gridConstraints,
                              ) {
                                final int columns =
                                    gridConstraints.maxWidth >= 340 ? 2 : 1;
                                final List<_DashboardModule> gridModules =
                                    _DashboardModule.values
                                        .where(
                                          (_DashboardModule module) =>
                                              module !=
                                              _DashboardModule.accuracyV2,
                                        )
                                        .toList(growable: false);
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    GridView.builder(
                                      key: const Key('research-modules-grid'),
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: gridModules.length,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: columns,
                                            crossAxisSpacing: 12,
                                            mainAxisSpacing: 12,
                                            mainAxisExtent: 172,
                                          ),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                            final _DashboardModule module =
                                                gridModules[index];
                                            return _ModuleCard(
                                              key: Key(
                                                'module-card-${module.name}',
                                              ),
                                              module: module,
                                              onTap: () =>
                                                  _openDiagnosticModule(module),
                                            );
                                          },
                                    ),
                                    const SizedBox(height: 12),
                                    _CompactModuleCard(
                                      key: const Key('module-card-accuracyV2'),
                                      module: _DashboardModule.accuracyV2,
                                      onTap: () => _openDiagnosticModule(
                                        _DashboardModule.accuracyV2,
                                      ),
                                    ),
                                  ],
                                );
                              },
                        ),
                        const SizedBox(height: 28),
                        const _SectionEyebrow('AI Research'),
                        const SizedBox(height: 8),
                        _DashboardCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  _IconBadge(
                                    icon: Icons.psychology_outlined,
                                    color: colors.tertiary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'V3 · Experimental AI',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        Text(
                                          'Model status: ${_aiReadiness.label}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: colors.onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              const Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: <Widget>[
                                  _FactChip('40 features'),
                                  _FactChip('4 motion classes'),
                                  _FactChip('On-device inference'),
                                ],
                              ),
                              const SizedBox(height: 14),
                              OutlinedButton.icon(
                                key: const Key('open-ai-dataset-capture'),
                                onPressed: _isBusy
                                    ? null
                                    : _openAiDatasetCapture,
                                icon: const Icon(Icons.dataset_outlined),
                                label: const Text('AI Dataset & Diagnostics'),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      const _SectionEyebrow('Research Status'),
                      const SizedBox(height: 8),
                      _DashboardCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            const Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: <Widget>[
                                _FactChip('Research Prototype'),
                                _FactChip('Software-defined denial'),
                                _FactChip('On-device AI'),
                                _FactChip('Ground Truth Firewall'),
                                _FactChip('Offline core navigation'),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Icon(
                                  Icons.info_outline,
                                  size: 18,
                                  color: colors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Navigation accuracy is not independently validated.',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDiagnosticModule(BuildContext context, _DashboardModule module) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('diagnostic-back-button'),
          tooltip: 'Back to NAVGUARD Home',
          onPressed: _closeDiagnosticModule,
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(module.title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (module != _DashboardModule.sensors &&
                  module != _DashboardModule.gnssAnchor &&
                  module != _DashboardModule.headingPdr &&
                  module != _DashboardModule.arCoreEnu &&
                  module != _DashboardModule.fusionEkf &&
                  module != _DashboardModule.denialRecovery &&
                  module != _DashboardModule.evaluationGtf &&
                  module != _DashboardModule.benchmarks &&
                  module != _DashboardModule.accuracyV2)
                Text(
                  module.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              if (module == _DashboardModule.sensors) ...<Widget>[
                _buildSensorsDiagnosticModule(context),
              ],
              if (module == _DashboardModule.gnssAnchor) ...<Widget>[
                _buildGnssAnchorDiagnosticModule(context),
              ],
              if (module == _DashboardModule.headingPdr) ...<Widget>[
                _buildHeadingPdrDiagnosticModule(context),
              ],
              if (module == _DashboardModule.arCoreEnu) ...<Widget>[
                _buildArCoreEnuDiagnosticModule(context),
              ],
              if (module == _DashboardModule.fusionEkf) ...<Widget>[
                _buildFusionEkfDiagnosticModule(context),
              ],
              if (module == _DashboardModule.denialRecovery) ...<Widget>[
                _buildDenialRecoveryDiagnosticModule(context),
              ],
              if (module == _DashboardModule.evaluationGtf) ...<Widget>[
                _buildEvaluationGtfDiagnosticModule(context),
              ],
              if (module == _DashboardModule.benchmarks) ...<Widget>[
                _buildBenchmarksDiagnosticModule(context),
              ],
              if (module == _DashboardModule.accuracyV2) ...<Widget>[
                _buildAccuracyV2DiagnosticModule(context),
              ],
              if (module != _DashboardModule.sensors &&
                  module != _DashboardModule.gnssAnchor &&
                  module != _DashboardModule.headingPdr &&
                  module != _DashboardModule.arCoreEnu &&
                  module != _DashboardModule.fusionEkf &&
                  module != _DashboardModule.denialRecovery &&
                  module != _DashboardModule.evaluationGtf &&
                  module != _DashboardModule.benchmarks &&
                  module != _DashboardModule.accuracyV2) ...<Widget>[
                const Divider(height: 32),
                Text(
                  _isBusy ? _activeOperationLabel : 'Diagnostic Output',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 280,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _buildOutput(),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String get _activeOperationLabel {
    switch (_activeOperation) {
      case _DiagnosticOperation.inventory:
        return 'Reading sensor inventory...';
      case _DiagnosticOperation.sensorTiming:
        return 'Running sensor timing diagnostic...';
      case _DiagnosticOperation.gnssPreflight:
        return 'Refreshing GNSS preflight...';
      case _DiagnosticOperation.gnssPermission:
        return 'Requesting GNSS foreground permission...';
      case _DiagnosticOperation.gnssTiming:
        return 'Running GNSS diagnostic...';
      case _DiagnosticOperation.gnssAnchorPreflight:
        return 'Refreshing GNSS anchor preflight...';
      case _DiagnosticOperation.gnssAnchorAcquisition:
        return 'Acquiring GNSS anchor...';
      case _DiagnosticOperation.headingPreflight:
        return 'Refreshing heading foundation preflight...';
      case _DiagnosticOperation.headingDiagnostic:
        return 'Running heading foundation diagnostic...';
      case _DiagnosticOperation.stepPreflight:
        return 'Refreshing step-event preflight...';
      case _DiagnosticOperation.stepPermission:
        return 'Requesting physical activity permission...';
      case _DiagnosticOperation.stepDiagnostic:
        return 'Running step-event diagnostic...';
      case _DiagnosticOperation.baselinePdrPreflight:
        return 'Refreshing baseline PDR preflight...';
      case _DiagnosticOperation.baselinePdrDiagnostic:
        return 'Running baseline PDR diagnostic...';
      case _DiagnosticOperation.arCorePreflight:
        return 'Refreshing ARCore preflight...';
      case _DiagnosticOperation.arCorePermission:
        return 'Requesting ARCore camera permission...';
      case _DiagnosticOperation.arCoreTracking:
        return 'Running ARCore tracking diagnostic...';
      case _DiagnosticOperation.arCoreEnuPreflight:
        return 'Refreshing ARCore-to-ENU preflight...';
      case _DiagnosticOperation.arCoreEnuDiagnostic:
        return 'Running ARCore-to-ENU diagnostic...';
      case _DiagnosticOperation.evaluationModePreflight:
        return 'Refreshing Evaluation Mode preflight...';
      case _DiagnosticOperation.evaluationModeDiagnostic:
        return 'Running Evaluation Mode...';
      case _DiagnosticOperation.navguardFusionPreflight:
        return 'Refreshing NAVGUARD Fusion preflight...';
      case _DiagnosticOperation.navguardFusionDiagnostic:
        return 'Running NAVGUARD Fusion diagnostic...';
      case _DiagnosticOperation.fullNavguardFlowPreflight:
        return 'Refreshing Full NAVGUARD Flow preflight...';
      case _DiagnosticOperation.fullNavguardFlowDiagnostic:
        return 'Running Full NAVGUARD Flow...';
      case _DiagnosticOperation.navguardBenchmarkPreflight:
        return 'Refreshing NAVGUARD Benchmark preflight...';
      case _DiagnosticOperation.navguardBenchmarkDiagnostic:
        return 'Running matched A/B/C/D benchmark...';
      case _DiagnosticOperation.accuracyV2Preflight:
        return 'Refreshing NAVGUARD Accuracy v2 preflight...';
      case _DiagnosticOperation.accuracyV2Calibration:
        return _accuracyV2FinalDrainRemainingSeconds == null
            ? 'Running Accuracy v2 development calibration...'
            : 'Processing delayed step events… Remain stationary '
                  '(${_accuracyV2FinalDrainRemainingSeconds}s)';
      case _DiagnosticOperation.accuracyV2DevelopmentBenchmark:
        return _accuracyV2BenchmarkPhase == 'BENCHMARK_FINAL_DRAIN'
            ? 'Processing delayed step events… Stand still. '
                  '(${_accuracyV2BenchmarkDrainRemainingSeconds ?? 0}s)'
            : _accuracyV2BenchmarkPhase == 'BENCHMARK_FORMAL_WINDOW'
            ? 'Running the 30-second formal development benchmark window...'
            : _accuracyV2BenchmarkPhase == 'FINALIZING'
            ? 'Finalizing the development benchmark...'
            : 'Stabilizing GNSS, then running the matched D-v1/D-v2 development benchmark...';
      case _DiagnosticOperation.accuracyV2Reset:
        return 'Resetting the memory-only Accuracy v2 profile...';
      case null:
        return 'Diagnostic Output';
    }
  }

  Widget _buildOutput() {
    final String? output = _formattedOutput;

    if (output != null) {
      return SingleChildScrollView(
        child: SelectableText(
          output,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
      );
    }

    final String? error = _errorMessage;

    if (error != null) {
      return SingleChildScrollView(
        child: SelectableText(error, style: const TextStyle(color: Colors.red)),
      );
    }

    return const Center(
      child: Text(
        'Run a diagnostic to display its sanitized JSON summary.',
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _DiagnosticSectionHeading extends StatelessWidget {
  const _DiagnosticSectionHeading({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 22, color: colors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DiagnosticStatusChip extends StatelessWidget {
  const _DiagnosticStatusChip({required this.status, super.key});

  final _ReadinessStatus status;

  Color _color(ColorScheme colors) => switch (status.kind) {
    _ReadinessKind.ready => const Color(0xFF137A4A),
    _ReadinessKind.attention => const Color(0xFF9A5B00),
    _ReadinessKind.error => colors.error,
    _ReadinessKind.busy => colors.primary,
    _ReadinessKind.unavailable => colors.onSurfaceVariant,
    _ReadinessKind.neutral => colors.onSurfaceVariant,
  };

  IconData get _icon => switch (status.kind) {
    _ReadinessKind.ready => Icons.check_circle_outline,
    _ReadinessKind.attention => Icons.info_outline,
    _ReadinessKind.error => Icons.error_outline,
    _ReadinessKind.busy => Icons.sync,
    _ReadinessKind.unavailable => Icons.block_outlined,
    _ReadinessKind.neutral => Icons.radio_button_unchecked,
  };

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color color = _color(colors);
    return Semantics(
      label: 'Status: ${status.label}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.26)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(_icon, size: 16, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                status.label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiagnosticNotice extends StatelessWidget {
  const _DiagnosticNotice({
    required this.icon,
    required this.title,
    required this.message,
    required this.kind,
  });

  final IconData icon;
  final String title;
  final String message;
  final _ReadinessKind kind;

  Color _color(ColorScheme colors) => switch (kind) {
    _ReadinessKind.ready => const Color(0xFF137A4A),
    _ReadinessKind.attention => const Color(0xFF9A5B00),
    _ReadinessKind.error => colors.error,
    _ReadinessKind.busy => colors.primary,
    _ReadinessKind.unavailable => colors.onSurfaceVariant,
    _ReadinessKind.neutral => colors.onSurfaceVariant,
  };

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color color = _color(colors);
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: colors.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SensorCapabilityTile extends StatelessWidget {
  const _SensorCapabilityTile({
    required this.title,
    required this.hardwareName,
    required this.status,
    required this.facts,
  });

  final String title;
  final String? hardwareName;
  final _ReadinessStatus status;
  final List<String> facts;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String? deviceName =
        hardwareName == null || hardwareName!.trim().isEmpty
        ? null
        : hardwareName!.trim();
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (deviceName != null) ...<Widget>[
            const SizedBox(height: 3),
            Text(
              deviceName,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 9),
          _DiagnosticStatusChip(status: status),
          if (facts.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: <Widget>[
                for (final String fact in facts) _FactChip(fact),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DiagnosticMetric {
  const _DiagnosticMetric(this.label, this.value);

  final String label;
  final String value;
}

class _DiagnosticMetricGrid extends StatelessWidget {
  const _DiagnosticMetricGrid({required this.metrics, super.key});

  final List<_DiagnosticMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool useTwoColumns = constraints.maxWidth >= 340;
        final double itemWidth = useTwoColumns
            ? (constraints.maxWidth - 10) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            for (final _DiagnosticMetric metric in metrics)
              SizedBox(
                width: itemWidth,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 76),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        metric.label,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: colors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        metric.value,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DiagnosticStatusRow extends StatelessWidget {
  const _DiagnosticStatusRow({required this.label, required this.status});

  final String label;
  final _ReadinessStatus status;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _DiagnosticStatusChip(status: status),
        ],
      ),
    );
  }
}

class _TechnicalDetailsExpansion extends StatelessWidget {
  const _TechnicalDetailsExpansion({required this.details, this.expansionKey});

  final String details;
  final Key? expansionKey;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: ExpansionTile(
        key: expansionKey ?? const Key('sensor-technical-details'),
        tilePadding: const EdgeInsets.symmetric(horizontal: 13),
        childrenPadding: const EdgeInsets.fromLTRB(13, 0, 13, 13),
        leading: Icon(Icons.code_outlined, color: colors.primary),
        title: const Text('Technical Details'),
        subtitle: const Text('Sanitized native diagnostic snapshot'),
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: SelectableText(
              details,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionEyebrow extends StatelessWidget {
  const _SectionEyebrow(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.child, this.emphasis = false, super.key});

  final Widget child;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Card(
      color: emphasis
          ? colors.primary.withValues(alpha: 0.045)
          : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: emphasis
              ? colors.primary.withValues(alpha: 0.24)
              : const Color(0xFFE1E7EF),
        ),
      ),
      child: Padding(padding: const EdgeInsets.all(18), child: child),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: color, size: 23),
    );
  }
}

class _ReadinessTile extends StatelessWidget {
  const _ReadinessTile({
    required this.width,
    required this.icon,
    required this.label,
    required this.status,
  });

  final double width;
  final IconData icon;
  final String label;
  final _ReadinessStatus status;

  Color _statusColor(ColorScheme colors) => switch (status.kind) {
    _ReadinessKind.ready => const Color(0xFF137A4A),
    _ReadinessKind.attention => const Color(0xFF9A5B00),
    _ReadinessKind.unavailable => colors.onSurfaceVariant,
    _ReadinessKind.error => colors.error,
    _ReadinessKind.busy => colors.primary,
    _ReadinessKind.neutral => colors.onSurfaceVariant,
  };

  IconData get _statusIcon => switch (status.kind) {
    _ReadinessKind.ready => Icons.check_circle_outline,
    _ReadinessKind.attention => Icons.info_outline,
    _ReadinessKind.unavailable => Icons.block_outlined,
    _ReadinessKind.error => Icons.error_outline,
    _ReadinessKind.busy => Icons.sync,
    _ReadinessKind.neutral => Icons.radio_button_unchecked,
  };

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color statusColor = _statusColor(colors);
    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 17, color: colors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: <Widget>[
              Icon(_statusIcon, size: 15, color: statusColor),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  status.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module, required this.onTap, super.key});

  final _DashboardModule module;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Open ${module.title} diagnostics',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _IconBadge(icon: module.icon, color: colors.primary),
                const SizedBox(height: 11),
                Text(
                  module.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: Text(
                    module.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(
                    Icons.arrow_forward,
                    size: 18,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactModuleCard extends StatelessWidget {
  const _CompactModuleCard({
    required this.module,
    required this.onTap,
    super.key,
  });

  final _DashboardModule module;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Open ${module.title} diagnostics',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: <Widget>[
                _IconBadge(icon: module.icon, color: colors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        module.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        module.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 20, color: colors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: colors.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FactChip extends StatelessWidget {
  const _FactChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: colors.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
