import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const NavguardApp());
}

enum _DiagnosticOperation {
  inventory,
  sensorTiming,
  gnssPreflight,
  gnssPermission,
  gnssTiming,
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

  static const JsonEncoder _jsonEncoder = JsonEncoder.withIndent('  ');

  _DiagnosticOperation? _activeOperation;
  _SensorOption _selectedSensor = _sensorOptions.first;
  String _preciseLocationPermission = 'Unknown';
  String _gpsProvider = 'Unknown';
  String _locationServices = 'Unknown';
  bool? _canRunFormalGnssDiagnostic;
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
