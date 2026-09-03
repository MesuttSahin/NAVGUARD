import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const NavguardApp());
}

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

  bool _isLoading = false;
  String? _formattedInventory;
  String? _errorMessage;

  Future<void> _readSensorInventory() async {
    setState(() {
      _isLoading = true;
      _formattedInventory = null;
      _errorMessage = null;
    });

    String? nextInventory;
    String? nextError;

    try {
      final Object? rawSnapshot = await _channel.invokeMethod<Object?>(
        'getSensorCapabilityInventory',
      );

      if (rawSnapshot is! Map) {
        throw const FormatException(
          'Native sensor inventory did not return a map.',
        );
      }

      final Object? normalizedSnapshot = _normalizeForJson(rawSnapshot);
      final String formattedJson = _jsonEncoder.convert(normalizedSnapshot);

      debugPrint('NAVGUARD_SENSOR_INVENTORY_BEGIN');
      for (final String line in formattedJson.split('\n')) {
        debugPrint(line);
      }
      debugPrint('NAVGUARD_SENSOR_INVENTORY_END');

      nextInventory = formattedJson;
    } on PlatformException catch (error) {
      final String? nativeMessage = error.message;

      if (nativeMessage == null || nativeMessage.isEmpty) {
        nextError = 'Sensor inventory failed (${error.code}).';
      } else {
        nextError = 'Sensor inventory failed (${error.code}): $nativeMessage';
      }
    } on MissingPluginException {
      nextError = 'Sensor diagnostic channel is unavailable on this platform.';
    } on FormatException catch (error) {
      nextError = 'Invalid sensor inventory response: ${error.message}';
    } catch (_) {
      nextError = 'Unexpected error while reading the sensor inventory.';
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
      _formattedInventory = nextInventory;
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
                'Capability metadata only — no live sensor sampling.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isLoading ? null : _readSensorInventory,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sensors),
                label: Text(
                  _isLoading
                      ? 'Reading Sensor Inventory...'
                      : 'Read Sensor Inventory',
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
    final String? inventory = _formattedInventory;

    if (inventory != null) {
      return SingleChildScrollView(
        child: SelectableText(
          inventory,
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
        'Press the button to read the runtime sensor inventory.',
        textAlign: TextAlign.center,
      ),
    );
  }
}
