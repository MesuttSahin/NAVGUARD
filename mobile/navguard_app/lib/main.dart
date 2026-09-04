import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const NavguardApp());
}

enum _DiagnosticOperation { inventory, timing }

class _SensorOption {
  const _SensorOption({required this.key, required this.label});

  final String key;
  final String label;
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
      title: 'NAVGUARD Sensor Diagnostics',
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
  static const MethodChannel _channel = MethodChannel(
    'io.github.mesuttsahin.navguard/sensor_diagnostics',
  );

  static const JsonEncoder _jsonEncoder = JsonEncoder.withIndent('  ');

  _DiagnosticOperation? _activeOperation;
  _SensorOption _selectedSensor = _sensorOptions.first;
  String? _formattedOutput;
  String? _errorMessage;

  bool get _isBusy => _activeOperation != null;

  bool get _isInventoryLoading =>
      _activeOperation == _DiagnosticOperation.inventory;

  bool get _isTimingLoading => _activeOperation == _DiagnosticOperation.timing;

  Future<void> _readSensorInventory() {
    return _runDiagnosticRequest(
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
      operation: _DiagnosticOperation.timing,
      methodName: 'runSensorTimingDiagnostic',
      arguments: <String, Object?>{'sensorKey': _selectedSensor.key},
      operationLabel: 'Sensor timing diagnostic',
      invalidResponseMessage:
          'Native sensor timing diagnostic did not return a map.',
      beginMarker: 'NAVGUARD_SENSOR_TIMING_BEGIN',
      endMarker: 'NAVGUARD_SENSOR_TIMING_END',
    );
  }

  Future<void> _runDiagnosticRequest({
    required _DiagnosticOperation operation,
    required String methodName,
    required String operationLabel,
    required String invalidResponseMessage,
    required String beginMarker,
    required String endMarker,
    Map<String, Object?>? arguments,
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

    try {
      final Object? rawSnapshot = await _channel.invokeMethod<Object?>(
        methodName,
        arguments,
      );

      if (rawSnapshot is! Map) {
        throw FormatException(invalidResponseMessage);
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
      nextError = 'Sensor diagnostic channel is unavailable on this platform.';
    } on FormatException catch (error) {
      nextError = 'Invalid diagnostic response: ${error.message}';
    } catch (_) {
      nextError = 'Unexpected error while running the sensor diagnostic.';
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _activeOperation = null;
      _formattedOutput = nextOutput;
      _errorMessage = nextError;
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
      appBar: AppBar(title: const Text('NAVGUARD Sensor Diagnostics')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
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
                icon: _isTimingLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.timer),
                label: Text(
                  _isTimingLoading
                      ? 'Running 10-second diagnostic...'
                      : 'Run Timing Diagnostic',
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
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
        'Run an inventory or timing diagnostic to display its JSON summary.',
        textAlign: TextAlign.center,
      ),
    );
  }
}
