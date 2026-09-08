import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'navigation/gnss_anchor.dart';
import 'navigation/heading.dart';

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
  arCorePreflight,
  arCorePermission,
  arCoreTracking,
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

  static const MethodChannel _arCoreChannel = MethodChannel(
    'io.github.mesuttsahin.navguard/arcore_diagnostics',
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
  String _cameraPermission = 'Unknown';
  String _arCoreAvailability = 'Unknown';
  String _arCoreReady = 'Unknown';
  bool? _canRunFormalArCoreDiagnostic;
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

  bool get _isArCorePreflightLoading =>
      _activeOperation == _DiagnosticOperation.arCorePreflight;

  bool get _isArCorePermissionLoading =>
      _activeOperation == _DiagnosticOperation.arCorePermission;

  bool get _isArCoreTrackingLoading =>
      _activeOperation == _DiagnosticOperation.arCoreTracking;

  bool get _canRunHeadingDiagnostic =>
      !_isBusy &&
      _headingPreflight?.rotationVectorAvailable == true &&
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

  String _formatRadians(double? value) {
    return value == null ? 'Not available' : '${value.toStringAsFixed(6)} rad';
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
      case _DiagnosticOperation.arCorePreflight:
        return 'Refreshing ARCore preflight...';
      case _DiagnosticOperation.arCorePermission:
        return 'Requesting ARCore camera permission...';
      case _DiagnosticOperation.arCoreTracking:
        return 'Running ARCore tracking diagnostic...';
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
