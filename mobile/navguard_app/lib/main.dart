import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'navigation/arcore_enu.dart';
import 'navigation/baseline_pdr.dart';
import 'navigation/evaluation_mode.dart';
import 'navigation/gnss_anchor.dart';
import 'navigation/heading.dart';
import 'navigation/navguard_fusion.dart';
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
  const NavguardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NAVGUARD Runtime Diagnostics',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const SensorDiagnosticsPage(),
    );
  }
}

class SensorDiagnosticsPage extends StatefulWidget {
  const SensorDiagnosticsPage({super.key});

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
  NavguardFusionPreflight? _navguardFusionPreflight;
  NavguardFusionDiagnosticResult? _navguardFusionResult;
  String _navguardFusionAlignmentStatus = 'Not started';
  String _navguardFusionStatus = 'Idle';
  bool _navguardFusionCancellationRequestInFlight = false;
  String? _formattedOutput;
  String? _errorMessage;

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

  String get _anchorFinePermissionLabel {
    final GnssAnchorPreflight? preflight = _gnssAnchorPreflight;

    if (preflight == null) {
      return 'Unknown';
    }

    return preflight.fineLocationPermissionGranted ? 'Granted' : 'Not granted';
  }

  String get _anchorLocationServicesLabel {
    return _booleanAvailabilityLabel(
      _gnssAnchorPreflight?.locationServicesEnabled,
    );
  }

  String get _anchorGpsProviderLabel {
    return _booleanAvailabilityLabel(_gnssAnchorPreflight?.gpsProviderEnabled);
  }

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

  String get _rotationVectorAvailabilityLabel {
    final HeadingFoundationPreflight? preflight = _headingPreflight;

    if (preflight == null) {
      return 'Unknown';
    }

    return preflight.rotationVectorAvailable ? 'Available' : 'Unavailable';
  }

  String get _headingAnchorLabel {
    return _gnssAnchorState == GnssAnchorRuntimeState.anchorLocked &&
            _gnssAnchor != null
        ? 'Locked'
        : 'Not locked';
  }

  String get _headingObservedRateLabel {
    final double? value = _headingResult?.observedSampleRateHz;
    return value == null ? 'Not available' : '${value.toStringAsFixed(2)} Hz';
  }

  String get _headingValidSampleCountLabel {
    return _headingResult?.validHeadingSampleCount.toString() ??
        'Not available';
  }

  String get _magneticHeadingLabel {
    return _formatRadians(_headingResult?.lastMagneticHeadingRad);
  }

  String get _trueNorthHeadingLabel {
    return _formatRadians(_headingResult?.lastTrueNorthCorrectedHeadingRad);
  }

  String get _declinationLabel {
    return _formatRadians(_headingResult?.declinationRadians);
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

  String get _stepDetectorAvailabilityLabel {
    final StepEventPreflight? preflight = _stepPreflight;

    if (preflight == null) {
      return 'Unknown';
    }

    return preflight.stepDetectorAvailable ? 'Available' : 'Unavailable';
  }

  String get _stepPermissionLabel {
    final StepEventPreflight? preflight = _stepPreflight;

    if (preflight == null) {
      return 'Unknown';
    }

    if (!preflight.activityRecognitionPermissionRequired) {
      return 'Not required';
    }

    return preflight.activityRecognitionPermissionGranted
        ? 'Granted'
        : 'Denied';
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

  String get _baselinePdrRotationVectorLabel {
    final BaselinePdrPreflight? preflight = _baselinePdrPreflight;
    if (preflight == null) {
      return 'Unknown';
    }
    return preflight.rotationVectorAvailable ? 'Available' : 'Unavailable';
  }

  String get _baselinePdrStepDetectorLabel {
    final BaselinePdrPreflight? preflight = _baselinePdrPreflight;
    if (preflight == null) {
      return 'Unknown';
    }
    return preflight.stepDetectorAvailable ? 'Available' : 'Unavailable';
  }

  String get _baselinePdrPermissionLabel {
    final BaselinePdrPreflight? preflight = _baselinePdrPreflight;
    if (preflight == null) {
      return 'Unknown';
    }
    if (!preflight.activityRecognitionPermissionRequired) {
      return 'Not required';
    }
    return preflight.activityRecognitionPermissionGranted
        ? 'Granted'
        : 'Denied';
  }

  String get _baselinePdrAnchorLabel {
    return _gnssAnchorState == GnssAnchorRuntimeState.anchorLocked &&
            _gnssAnchor != null
        ? 'Locked'
        : 'Required';
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

  String get _arCoreEnuAvailabilityLabel {
    final ArCoreEnuPreflight? preflight = _arCoreEnuPreflight;
    if (preflight == null) {
      return 'Unknown';
    }
    return preflight.arCoreSupported && preflight.arCoreInstalled
        ? 'Available'
        : 'Unavailable';
  }

  String get _arCoreEnuCameraPermissionLabel {
    final ArCoreEnuPreflight? preflight = _arCoreEnuPreflight;
    if (preflight == null) {
      return 'Unknown';
    }
    return preflight.cameraPermissionGranted ? 'Granted' : 'Denied';
  }

  String get _arCoreEnuRotationVectorLabel {
    final ArCoreEnuPreflight? preflight = _arCoreEnuPreflight;
    if (preflight == null) {
      return 'Unknown';
    }
    return preflight.rotationVectorAvailable ? 'Available' : 'Unavailable';
  }

  String get _arCoreEnuAnchorLabel {
    return _gnssAnchorState == GnssAnchorRuntimeState.anchorLocked &&
            _gnssAnchor != null
        ? 'Locked'
        : 'Required';
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

  String get _evaluationGpsProviderLabel {
    final EvaluationModePreflight? value = _evaluationModePreflight;
    if (value == null) {
      return 'Unknown';
    }
    if (!value.gpsProviderAvailable) {
      return 'Unavailable';
    }
    return value.gpsProviderEnabled ? 'Enabled' : 'Disabled';
  }

  String get _evaluationLocationPermissionLabel {
    final EvaluationModePreflight? value = _evaluationModePreflight;
    if (value == null) {
      return 'Unknown';
    }
    return value.fineLocationPermissionGranted ? 'Granted' : 'Not granted';
  }

  String get _evaluationRotationVectorLabel {
    final EvaluationModePreflight? value = _evaluationModePreflight;
    if (value == null) {
      return 'Unknown';
    }
    return value.rotationVectorAvailable ? 'Available' : 'Unavailable';
  }

  String get _evaluationStepDetectorLabel {
    final EvaluationModePreflight? value = _evaluationModePreflight;
    if (value == null) {
      return 'Unknown';
    }
    return value.stepDetectorAvailable ? 'Available' : 'Unavailable';
  }

  String get _evaluationActivityPermissionLabel {
    final EvaluationModePreflight? value = _evaluationModePreflight;
    if (value == null) {
      return 'Unknown';
    }
    if (!value.activityRecognitionPermissionRequired) {
      return 'Not required';
    }
    return value.activityRecognitionPermissionGranted
        ? 'Granted'
        : 'Not granted';
  }

  String get _evaluationAnchorLabel {
    return _gnssAnchorState == GnssAnchorRuntimeState.anchorLocked &&
            _gnssAnchor != null
        ? 'Locked'
        : 'Required';
  }

  String get _evaluationFirewallSelfTestLabel {
    final EvaluationModePreflight? value = _evaluationModePreflight;
    if (value == null) {
      return 'Not run';
    }
    return value.firewallMutationSelfTestPassed ? 'PASS' : 'FAIL';
  }

  String get _evaluationProtectedFixesLabel {
    return _evaluationModeResult?.acceptedProtectedGtFixCount.toString() ??
        'Not available';
  }

  String get _evaluationMatchedFixesLabel {
    return _evaluationModeResult?.matchedGroundTruthFixCount.toString() ??
        'Not available';
  }

  String get _evaluationIntegratedStepsLabel {
    return _evaluationModeResult?.integratedStepCount.toString() ??
        'Not available';
  }

  String get _evaluationFinalEastLabel {
    return _formatMeters(_evaluationModeResult?.finalDeniedEastM);
  }

  String get _evaluationFinalNorthLabel {
    return _formatMeters(_evaluationModeResult?.finalDeniedNorthM);
  }

  String get _evaluationMedianErrorLabel {
    return _formatMeters(_evaluationModeResult?.medianHorizontalErrorM);
  }

  String get _evaluationP95ErrorLabel {
    return _formatMeters(_evaluationModeResult?.p95HorizontalErrorM);
  }

  String get _evaluationFinalPreCorrectionErrorLabel {
    return _formatMeters(_evaluationModeResult?.finalDeniedPreCorrectionErrorM);
  }

  String get _evaluationMedianEstimatorAgeLabel {
    final double? value = _evaluationModeResult?.medianEstimatorAgeAtGtMs;
    return value == null ? 'Not available' : '${value.toStringAsFixed(3)} ms';
  }

  String get _navguardFusionArCoreLabel {
    final NavguardFusionPreflight? value = _navguardFusionPreflight;
    if (value == null) return 'Unknown';
    if (!value.arCoreSupported) return 'Unsupported';
    return value.arCoreInstalled ? 'Ready' : 'Not installed/current';
  }

  String get _navguardFusionCameraPermissionLabel {
    final bool? value = _navguardFusionPreflight?.cameraPermissionGranted;
    return value == null
        ? 'Unknown'
        : value
        ? 'Granted'
        : 'Not granted';
  }

  String get _navguardFusionRotationVectorLabel {
    final bool? value = _navguardFusionPreflight?.rotationVectorAvailable;
    return value == null
        ? 'Unknown'
        : value
        ? 'Available'
        : 'Unavailable';
  }

  String get _navguardFusionStepDetectorLabel {
    final bool? value = _navguardFusionPreflight?.stepDetectorAvailable;
    return value == null
        ? 'Unknown'
        : value
        ? 'Available'
        : 'Unavailable';
  }

  String get _navguardFusionActivityPermissionLabel {
    final bool? value =
        _navguardFusionPreflight?.activityRecognitionPermissionGranted;
    return value == null
        ? 'Unknown'
        : value
        ? 'Granted'
        : 'Not granted';
  }

  String get _navguardFusionAnchorLabel {
    return _gnssAnchorState == GnssAnchorRuntimeState.anchorLocked &&
            _gnssAnchor != null
        ? 'Locked'
        : 'Required';
  }

  String _formatNavguardQuality(NavguardQuality? value) {
    return value?.wireValue ?? 'UNKNOWN';
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

  String _booleanAvailabilityLabel(bool? value) {
    if (value == null) {
      return 'Unknown';
    }

    return value ? 'Enabled' : 'Disabled';
  }

  Future<void> _readSensorInventory() {
    return _runDiagnosticRequest(
      channel: _sensorChannel,
      operation: _DiagnosticOperation.inventory,
      methodName: 'getSensorCapabilityInventory',
      operationLabel: 'Sensor inventory',
      invalidResponseMessage: 'Native sensor inventory did not return a map.',
      beginMarker: 'NAVGUARD_SENSOR_INVENTORY_BEGIN',
      endMarker: 'NAVGUARD_SENSOR_INVENTORY_END',
    );
  }

  Future<void> _runSensorTimingDiagnostic() {
    return _runDiagnosticRequest(
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
  }

  Future<void> _refreshGnssPreflight() {
    return _runDiagnosticRequest(
      channel: _gnssChannel,
      operation: _DiagnosticOperation.gnssPreflight,
      methodName: 'getGnssDiagnosticPreflight',
      operationLabel: 'GNSS diagnostic preflight',
      invalidResponseMessage: 'Native GNSS preflight did not return a map.',
      beginMarker: 'NAVGUARD_GNSS_PREFLIGHT_BEGIN',
      endMarker: 'NAVGUARD_GNSS_PREFLIGHT_END',
      updateGnssState: true,
    );
  }

  Future<void> _requestGnssForegroundPermission() {
    return _runDiagnosticRequest(
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
  }

  Future<void> _runGnssTimingDiagnostic() {
    return _runDiagnosticRequest(
      channel: _gnssChannel,
      operation: _DiagnosticOperation.gnssTiming,
      methodName: 'runGnssTimingDiagnostic',
      operationLabel: 'GNSS timing diagnostic',
      invalidResponseMessage:
          'Native GNSS timing diagnostic did not return a map.',
      beginMarker: 'NAVGUARD_GNSS_TIMING_BEGIN',
      endMarker: 'NAVGUARD_GNSS_TIMING_END',
    );
  }

  Future<void> _refreshGnssAnchorPreflight() {
    return _runDiagnosticRequest(
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
  }

  Future<void> _acquireGnssAnchor() async {
    if (_isBusy || _gnssAnchor != null) {
      return;
    }

    setState(() {
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

  Future<void> _refreshHeadingPreflight() {
    return _runDiagnosticRequest(
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

  Future<void> _refreshStepPreflight() {
    return _runDiagnosticRequest(
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

  Future<void> _requestActivityRecognitionPermission() {
    return _runDiagnosticRequest(
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

  Future<void> _refreshArCorePreflight() {
    return _runDiagnosticRequest(
      channel: _arCoreChannel,
      operation: _DiagnosticOperation.arCorePreflight,
      methodName: 'getArCoreDiagnosticPreflight',
      operationLabel: 'ARCore diagnostic preflight',
      invalidResponseMessage: 'Native ARCore preflight did not return a map.',
      beginMarker: 'NAVGUARD_ARCORE_PREFLIGHT_BEGIN',
      endMarker: 'NAVGUARD_ARCORE_PREFLIGHT_END',
      updateArCoreState: true,
    );
  }

  Future<void> _requestArCoreCameraPermission() {
    return _runDiagnosticRequest(
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
  }

  Future<void> _runArCoreTrackingDiagnostic() {
    return _runDiagnosticRequest(
      channel: _arCoreChannel,
      operation: _DiagnosticOperation.arCoreTracking,
      methodName: 'runArCoreTrackingDiagnostic',
      operationLabel: 'ARCore tracking diagnostic',
      invalidResponseMessage:
          'Native ARCore tracking diagnostic did not return a map.',
      beginMarker: 'NAVGUARD_ARCORE_TRACKING_BEGIN',
      endMarker: 'NAVGUARD_ARCORE_TRACKING_END',
    );
  }

  Future<void> _refreshArCoreEnuPreflight() async {
    if (_isBusy) {
      return;
    }

    setState(() {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NAVGUARD Runtime Diagnostics')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Sensor Inventory',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Inventory: capability metadata only — no live sensor sampling.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _isBusy ? null : _readSensorInventory,
                icon: _isInventoryLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sensors),
                label: Text(
                  _isInventoryLoading
                      ? 'Reading Sensor Inventory...'
                      : 'Read Sensor Inventory',
                ),
              ),
              const Divider(height: 32),
              Text(
                'Live Sensor Timing Diagnostic',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<_SensorOption>(
                initialValue: _selectedSensor,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Sensor',
                  border: OutlineInputBorder(),
                ),
                items: _sensorOptions
                    .map((option) {
                      return DropdownMenuItem<_SensorOption>(
                        value: option,
                        child: Text(option.label),
                      );
                    })
                    .toList(growable: false),
                onChanged: _isBusy
                    ? null
                    : (_SensorOption? option) {
                        if (option == null) {
                          return;
                        }

                        setState(() {
                          _selectedSensor = option;
                        });
                      },
              ),
              const SizedBox(height: 12),
              const Text(
                'Requested period: 20,000 µs (~50 Hz requested)',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text('Duration: 10 seconds', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _isBusy ? null : _runSensorTimingDiagnostic,
                icon: _isSensorTimingLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.timer),
                label: Text(
                  _isSensorTimingLoading
                      ? 'Running 10-second diagnostic...'
                      : 'Run Timing Diagnostic',
                ),
              ),
              const Divider(height: 32),
              Text(
                'GNSS Runtime Timing Diagnostic',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text('Precise location permission: $_preciseLocationPermission'),
              const SizedBox(height: 4),
              Text('GPS provider: $_gpsProvider'),
              const SizedBox(height: 4),
              Text('Location services: $_locationServices'),
              const SizedBox(height: 12),
              OutlinedButton.icon(
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
                      : 'Refresh GNSS Preflight',
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
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
              const SizedBox(height: 16),
              const Text('Provider: GPS_PROVIDER'),
              const SizedBox(height: 4),
              const Text('Requested minimum interval: 1,000 ms'),
              const SizedBox(height: 4),
              const Text('Requested minimum distance: 0 m'),
              const SizedBox(height: 4),
              const Text('First location timeout: 120 seconds'),
              const SizedBox(height: 4),
              const Text('Collection after first location: 60 seconds'),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: !_isBusy && _canRunFormalGnssDiagnostic == true
                    ? _runGnssTimingDiagnostic
                    : null,
                icon: _isGnssTimingLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.gps_fixed),
                label: Text(
                  _isGnssTimingLoading
                      ? 'Running GNSS diagnostic...'
                      : 'Run GNSS Timing Diagnostic',
                ),
              ),
              const Divider(height: 32),
              Text(
                'GNSS Anchor / Local Reference',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text('Fine location permission: $_anchorFinePermissionLabel'),
              const SizedBox(height: 4),
              Text('Location services: $_anchorLocationServicesLabel'),
              const SizedBox(height: 4),
              Text('GPS provider: $_anchorGpsProviderLabel'),
              const SizedBox(height: 4),
              Text('Anchor state: ${_gnssAnchorState.displayLabel}'),
              const SizedBox(height: 4),
              Text('Candidate count: $_anchorCandidateCountLabel'),
              const SizedBox(height: 4),
              Text(
                'Reported horizontal accuracy: '
                '$_anchorReportedHorizontalAccuracyLabel',
              ),
              const SizedBox(height: 4),
              Text('Altitude available: $_anchorAltitudeAvailableLabel'),
              const SizedBox(height: 4),
              Text(
                'Horizontal ENU origin ready: '
                '$_horizontalEnuOriginReadyLabel',
              ),
              const SizedBox(height: 12),
              const Text(
                'Anchor source: pre-denial GPS_PROVIDER fixes only.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                'Selection: lowest reported horizontal accuracy; '
                'newer elapsed-realtime fix breaks ties.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
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
                      : 'Refresh Anchor Preflight',
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
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
              if (_isGnssAnchorAcquisitionLoading) ...<Widget>[
                const SizedBox(height: 8),
                OutlinedButton.icon(
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
              ],
              if (_gnssAnchor != null) ...<Widget>[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _isBusy ? null : _clearGnssAnchor,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Clear Anchor'),
                ),
              ],
              const Divider(height: 32),
              Text(
                'Heading / True-North Reference',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text('Rotation Vector: $_rotationVectorAvailabilityLabel'),
              const SizedBox(height: 4),
              Text('Anchor: $_headingAnchorLabel'),
              const SizedBox(height: 4),
              Text('Heading diagnostic: $_headingDiagnosticStatus'),
              const SizedBox(height: 4),
              const Text('Device forward axis: Top edge (+Y)'),
              const SizedBox(height: 4),
              const Text('Requested sampling: 50 Hz (20,000 µs request)'),
              const SizedBox(height: 4),
              Text('Observed sample rate: $_headingObservedRateLabel'),
              const SizedBox(height: 4),
              Text('Valid sample count: $_headingValidSampleCountLabel'),
              const SizedBox(height: 4),
              Text('Magnetic heading: $_magneticHeadingLabel'),
              const SizedBox(height: 4),
              Text(
                'True-north corrected heading estimate: '
                '$_trueNorthHeadingLabel',
              ),
              const SizedBox(height: 4),
              Text('Declination: $_declinationLabel'),
              const SizedBox(height: 4),
              Text('Reported heading accuracy: $_reportedHeadingAccuracyLabel'),
              const SizedBox(height: 4),
              Text(
                'Timestamp monotonicity: '
                '$_headingTimestampMonotonicityLabel',
              ),
              const SizedBox(height: 4),
              Text('Cumulative heading change: $_cumulativeHeadingChangeLabel'),
              const SizedBox(height: 8),
              const Text(
                'True-north accuracy: NOT VALIDATED',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
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
                      : 'Refresh Heading Preflight',
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
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
              if (_isHeadingDiagnosticLoading) ...<Widget>[
                const SizedBox(height: 8),
                OutlinedButton.icon(
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
              ],
              const Divider(height: 32),
              Text(
                'Step-Event Foundation',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text('Step Detector: $_stepDetectorAvailabilityLabel'),
              const SizedBox(height: 4),
              Text('Physical activity permission: $_stepPermissionLabel'),
              const SizedBox(height: 4),
              Text('Step diagnostic: $_stepDiagnosticStatus'),
              const SizedBox(height: 4),
              const Text('Formal window: 30 s'),
              const SizedBox(height: 4),
              Text('Detected step events: $_detectedStepEventsLabel'),
              const SizedBox(height: 4),
              Text('Invalid events: $_invalidStepEventsLabel'),
              const SizedBox(height: 4),
              Text(
                'Timestamp monotonicity: '
                '$_stepTimestampMonotonicityLabel',
              ),
              const SizedBox(height: 4),
              Text('Median step interval: $_medianStepIntervalLabel'),
              const SizedBox(height: 4),
              Text('Observed cadence: $_observedStepCadenceLabel'),
              const SizedBox(height: 8),
              const Text(
                'Step detection accuracy: NOT VALIDATED',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
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
                      : 'Refresh Step Preflight',
                ),
              ),
              if (_stepPreflight?.activityRecognitionPermissionRequired ==
                      true &&
                  _stepPreflight?.activityRecognitionPermissionGranted ==
                      false) ...<Widget>[
                const SizedBox(height: 8),
                OutlinedButton.icon(
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
              ],
              const SizedBox(height: 8),
              FilledButton.icon(
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
              if (_isStepDiagnosticLoading) ...<Widget>[
                const SizedBox(height: 8),
                OutlinedButton.icon(
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
              ],
              const Divider(height: 32),
              Text(
                'Baseline PDR',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text('Rotation Vector: $_baselinePdrRotationVectorLabel'),
              const SizedBox(height: 4),
              Text('Step Detector: $_baselinePdrStepDetectorLabel'),
              const SizedBox(height: 4),
              Text(
                'Physical activity permission: '
                '$_baselinePdrPermissionLabel',
              ),
              const SizedBox(height: 4),
              Text('Anchor: $_baselinePdrAnchorLabel'),
              const SizedBox(height: 4),
              Text('Baseline PDR: $_baselinePdrStatus'),
              const SizedBox(height: 4),
              const Text('Formal window: 30 s'),
              const SizedBox(height: 4),
              const Text('Step length model: Fixed 0.75 m'),
              const SizedBox(height: 4),
              Text('Detected step events: $_baselinePdrDetectedStepsLabel'),
              const SizedBox(height: 4),
              Text('Integrated steps: $_baselinePdrIntegratedStepsLabel'),
              const SizedBox(height: 4),
              Text('Unassociated steps: $_baselinePdrUnassociatedStepsLabel'),
              const SizedBox(height: 4),
              Text('Final East: $_baselinePdrFinalEastLabel'),
              const SizedBox(height: 4),
              Text('Final North: $_baselinePdrFinalNorthLabel'),
              const SizedBox(height: 4),
              Text('Net displacement: $_baselinePdrNetDisplacementLabel'),
              const SizedBox(height: 4),
              Text('Nominal path length: $_baselinePdrNominalPathLabel'),
              const SizedBox(height: 4),
              Text(
                'Median heading association age: '
                '$_baselinePdrMedianAssociationAgeLabel',
              ),
              const SizedBox(height: 8),
              const Text(
                'Step length accuracy: NOT VALIDATED\n'
                'True-north accuracy: NOT VALIDATED\n'
                'Distance accuracy: NOT VALIDATED\n'
                'Body heading: NOT IMPLEMENTED',
                textAlign: TextAlign.center,
              ),
              if (_baselinePdrPreflight
                          ?.activityRecognitionPermissionRequired ==
                      true &&
                  _baselinePdrPreflight?.activityRecognitionPermissionGranted ==
                      false) ...<Widget>[
                const SizedBox(height: 8),
                const Text(
                  'Physical activity permission required. '
                  'Grant it from Step-Event Foundation.',
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 12),
              OutlinedButton.icon(
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
                      : 'Refresh Baseline PDR Preflight',
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
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
              if (_isBaselinePdrDiagnosticLoading) ...<Widget>[
                const SizedBox(height: 8),
                OutlinedButton.icon(
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
              ],
              const Divider(height: 32),
              Text(
                'ARCore Runtime Diagnostics',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text('Camera Permission: $_cameraPermission'),
              const SizedBox(height: 4),
              Text('ARCore Availability: $_arCoreAvailability'),
              const SizedBox(height: 4),
              Text('ARCore Ready: $_arCoreReady'),
              const SizedBox(height: 12),
              OutlinedButton.icon(
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
                      : 'Refresh ARCore Preflight',
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
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
              const SizedBox(height: 16),
              const Text('Tracking Acquisition Timeout: 30 s'),
              const SizedBox(height: 4),
              const Text('Tracking Collection Duration: 30 s'),
              const SizedBox(height: 8),
              const Text(
                'Privacy: camera images and raw pose trajectories are not saved or returned.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
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
                      ? 'Running ARCore tracking diagnostic...'
                      : 'Run ARCore Tracking Diagnostic',
                ),
              ),
              const Divider(height: 32),
              Text(
                'ARCore → ENU Foundation',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text('ARCore: $_arCoreEnuAvailabilityLabel'),
              const SizedBox(height: 4),
              Text('Camera permission: $_arCoreEnuCameraPermissionLabel'),
              const SizedBox(height: 4),
              Text('Rotation Vector: $_arCoreEnuRotationVectorLabel'),
              const SizedBox(height: 4),
              Text('GNSS Anchor: $_arCoreEnuAnchorLabel'),
              const SizedBox(height: 4),
              Text('Alignment: $_arCoreEnuAlignmentStatus'),
              const SizedBox(height: 4),
              Text('ARCore → ENU: $_arCoreEnuStatus'),
              const SizedBox(height: 12),
              const Text('Alignment hold: 2 s'),
              const SizedBox(height: 4),
              const Text('Formal movement window: 30 s'),
              const SizedBox(height: 8),
              const Text(
                'Hold the phone still for the 2-second alignment phase.\n'
                'Keep the screen approximately upward and the device top edge stable.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text('Tracking fraction: $_arCoreEnuTrackingFractionLabel'),
              const SizedBox(height: 4),
              Text('Usable ENU frames: $_arCoreEnuUsableFramesLabel'),
              const SizedBox(height: 4),
              Text('Final East: $_arCoreEnuFinalEastLabel'),
              const SizedBox(height: 4),
              Text('Final North: $_arCoreEnuFinalNorthLabel'),
              const SizedBox(height: 4),
              Text('Final Up: $_arCoreEnuFinalUpLabel'),
              const SizedBox(height: 4),
              Text(
                'Horizontal displacement: '
                '$_arCoreEnuHorizontalDisplacementLabel',
              ),
              const SizedBox(height: 4),
              Text('3D displacement: $_arCoreEnu3dDisplacementLabel'),
              const SizedBox(height: 4),
              Text(
                'Max horizontal excursion: '
                '$_arCoreEnuMaxHorizontalExcursionLabel',
              ),
              const SizedBox(height: 4),
              Text(
                'Median AR frame interval: '
                '$_arCoreEnuMedianFrameIntervalLabel',
              ),
              const SizedBox(height: 8),
              const Text(
                'ARCore position accuracy: NOT VALIDATED\n'
                'ARCore distance accuracy: NOT VALIDATED\n'
                'ENU alignment accuracy: NOT VALIDATED\n'
                'True-north accuracy: NOT VALIDATED\n'
                'PDR fusion: NOT IMPLEMENTED\n'
                'EKF: NOT IMPLEMENTED',
                textAlign: TextAlign.center,
              ),
              if (_arCoreEnuPreflight?.cameraPermissionGranted ==
                  false) ...<Widget>[
                const SizedBox(height: 8),
                const Text(
                  'Camera permission required. '
                  'Grant it from ARCore Runtime Diagnostics.',
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 12),
              OutlinedButton.icon(
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
                      : 'Refresh ARCore → ENU Preflight',
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _canRunArCoreEnuDiagnostic
                    ? _runArCoreEnuDiagnostic
                    : null,
                icon: _isArCoreEnuDiagnosticLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.explore_outlined),
                label: Text(
                  _isArCoreEnuDiagnosticLoading
                      ? 'Running ARCore → ENU Diagnostic...'
                      : 'Run ARCore → ENU Diagnostic',
                ),
              ),
              if (_isArCoreEnuDiagnosticLoading) ...<Widget>[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _arCoreEnuCancellationRequestInFlight
                      ? null
                      : _cancelArCoreEnuDiagnostic,
                  icon: const Icon(Icons.cancel_outlined),
                  label: Text(
                    _arCoreEnuCancellationRequestInFlight
                        ? 'Cancelling ARCore → ENU Diagnostic...'
                        : 'Cancel ARCore → ENU Diagnostic',
                  ),
                ),
              ],
              const Divider(height: 32),
              Text(
                'Evaluation Mode + Ground Truth Firewall',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text('GPS provider: $_evaluationGpsProviderLabel'),
              const SizedBox(height: 4),
              Text('Location permission: $_evaluationLocationPermissionLabel'),
              const SizedBox(height: 4),
              Text('Rotation Vector: $_evaluationRotationVectorLabel'),
              const SizedBox(height: 4),
              Text('Step Detector: $_evaluationStepDetectorLabel'),
              const SizedBox(height: 4),
              Text(
                'Physical Activity permission: '
                '$_evaluationActivityPermissionLabel',
              ),
              const SizedBox(height: 4),
              Text('GNSS Anchor: $_evaluationAnchorLabel'),
              const SizedBox(height: 4),
              Text('Firewall self-test: $_evaluationFirewallSelfTestLabel'),
              const SizedBox(height: 4),
              Text('Evaluation state: $_evaluationModeStatus'),
              const SizedBox(height: 12),
              const Text('Protected GNSS role: Ground Truth Only'),
              const SizedBox(height: 4),
              const Text('Denied estimator: Config A Baseline PDR'),
              const SizedBox(height: 4),
              const Text('Formal evaluation: 30 s'),
              const SizedBox(height: 8),
              const Text(
                'Protected GNSS is physically active in Evaluation Mode.\n\n'
                'It is isolated from the denied estimator and used only for post-estimation evaluation.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'GNSS correction: DISABLED\n'
                'Ground Truth Firewall: ENABLED',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Lock the GNSS anchor at the physical start point before beginning Evaluation Mode.\n\n'
                'After Evaluation Mode starts, protected GNSS remains active only as an evaluation reference.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text('Protected GT fixes: $_evaluationProtectedFixesLabel'),
              const SizedBox(height: 4),
              Text('Matched GT fixes: $_evaluationMatchedFixesLabel'),
              const SizedBox(height: 4),
              Text('Integrated steps: $_evaluationIntegratedStepsLabel'),
              const SizedBox(height: 4),
              Text('Final denied East: $_evaluationFinalEastLabel'),
              const SizedBox(height: 4),
              Text('Final denied North: $_evaluationFinalNorthLabel'),
              const SizedBox(height: 4),
              Text('Median horizontal error: $_evaluationMedianErrorLabel'),
              const SizedBox(height: 4),
              Text('P95 horizontal error: $_evaluationP95ErrorLabel'),
              const SizedBox(height: 4),
              Text(
                'Final denied pre-correction error: '
                '$_evaluationFinalPreCorrectionErrorLabel',
              ),
              const SizedBox(height: 4),
              Text(
                'Median estimator age at GT: '
                '$_evaluationMedianEstimatorAgeLabel',
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
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
                      ? 'Refreshing Evaluation Preflight...'
                      : 'Refresh Evaluation Preflight',
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _canRunEvaluationMode
                    ? _runEvaluationModeDiagnostic
                    : null,
                icon: _isEvaluationModeDiagnosticLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.shield_outlined),
                label: Text(
                  _isEvaluationModeDiagnosticLoading
                      ? 'Running Evaluation Mode...'
                      : 'Run Evaluation Mode',
                ),
              ),
              if (_isEvaluationModeDiagnosticLoading) ...<Widget>[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _evaluationModeCancellationRequestInFlight
                      ? null
                      : _cancelEvaluationModeDiagnostic,
                  icon: const Icon(Icons.cancel_outlined),
                  label: Text(
                    _evaluationModeCancellationRequestInFlight
                        ? 'Cancelling Evaluation Mode...'
                        : 'Cancel Evaluation Mode',
                  ),
                ),
              ],
              const Divider(height: 32),
              Text(
                'NAVGUARD Fusion — Quality Engine + EKF',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text('ARCore readiness: $_navguardFusionArCoreLabel'),
              const SizedBox(height: 4),
              Text('Camera permission: $_navguardFusionCameraPermissionLabel'),
              const SizedBox(height: 4),
              Text('Rotation Vector: $_navguardFusionRotationVectorLabel'),
              const SizedBox(height: 4),
              Text('Step Detector: $_navguardFusionStepDetectorLabel'),
              const SizedBox(height: 4),
              Text(
                'Activity permission: $_navguardFusionActivityPermissionLabel',
              ),
              const SizedBox(height: 4),
              Text('GNSS Anchor: $_navguardFusionAnchorLabel'),
              const SizedBox(height: 4),
              Text('Alignment state: $_navguardFusionAlignmentStatus'),
              const SizedBox(height: 4),
              Text('Fusion state: $_navguardFusionStatus'),
              const SizedBox(height: 12),
              Text(
                'Heading Quality: ${_formatNavguardQuality(_navguardFusionResult?.finalHeadingQuality)}',
              ),
              const SizedBox(height: 4),
              Text(
                'PDR Quality: ${_formatNavguardQuality(_navguardFusionResult?.finalPdrQuality)}',
              ),
              const SizedBox(height: 4),
              Text(
                'ARCore Quality: ${_formatNavguardQuality(_navguardFusionResult?.finalArcoreQuality)}',
              ),
              const SizedBox(height: 4),
              Text(
                'Fusion Quality: ${_formatNavguardQuality(_navguardFusionResult?.finalFusionQuality)}',
              ),
              const SizedBox(height: 12),
              Text(
                'PDR predictions: ${_navguardFusionResult?.pdrPredictionsApplied ?? 'Not available'}',
              ),
              const SizedBox(height: 4),
              Text(
                'ARCore updates: ${_navguardFusionResult?.arcoreMeasurementsApplied ?? 'Not available'}',
              ),
              const SizedBox(height: 4),
              Text(
                'Heading updates: ${_navguardFusionResult?.headingMeasurementsApplied ?? 'Not available'}',
              ),
              const SizedBox(height: 4),
              Text(
                'Final fused East: ${_formatMeters(_navguardFusionResult?.finalFusedEastM)}',
              ),
              const SizedBox(height: 4),
              Text(
                'Final fused North: ${_formatMeters(_navguardFusionResult?.finalFusedNorthM)}',
              ),
              const SizedBox(height: 4),
              Text(
                'Final fused heading: ${_formatRadians(_navguardFusionResult?.finalFusedHeadingRad)}',
              ),
              const SizedBox(height: 4),
              Text(
                'Final fused displacement: ${_formatMeters(_navguardFusionResult?.finalFusedHorizontalDisplacementM)}',
              ),
              const SizedBox(height: 4),
              Text(
                'Final PDR displacement: ${_formatMeters(_navguardFusionResult?.finalPdrHorizontalDisplacementM)}',
              ),
              const SizedBox(height: 4),
              Text(
                'Final ARCore displacement: ${_formatMeters(_navguardFusionResult?.finalArcoreHorizontalDisplacementM)}',
              ),
              const SizedBox(height: 4),
              Text(
                'Final σE: ${_formatNavguardStandardDeviation(_navguardFusionResult?.finalVarianceEastM2, 'm')}',
              ),
              const SizedBox(height: 4),
              Text(
                'Final σN: ${_formatNavguardStandardDeviation(_navguardFusionResult?.finalVarianceNorthM2, 'm')}',
              ),
              const SizedBox(height: 4),
              Text(
                'Final σHeading: ${_formatNavguardStandardDeviation(_navguardFusionResult?.finalVarianceHeadingRad2, 'rad')}',
              ),
              const SizedBox(height: 12),
              const Text(
                'Fusion accuracy: NOT VALIDATED\n'
                'Quality thresholds: NOT VALIDATED\n'
                'Noise parameters: NOT VALIDATED\n'
                'Protected GNSS: NOT ACCESSED\n'
                'GNSS recovery: NOT IMPLEMENTED',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isBusy ? null : _refreshNavguardFusionPreflight,
                icon: _isNavguardFusionPreflightLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: const Text('Refresh NAVGUARD Fusion Preflight'),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
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
                label: const Text('Run NAVGUARD Fusion Diagnostic'),
              ),
              if (_isNavguardFusionDiagnosticLoading) ...<Widget>[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _navguardFusionCancellationRequestInFlight
                      ? null
                      : _cancelNavguardFusionDiagnostic,
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel NAVGUARD Fusion Diagnostic'),
                ),
              ],
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
