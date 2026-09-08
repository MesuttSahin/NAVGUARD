import 'package:flutter_test/flutter_test.dart';
import 'package:navguard/navigation/step_event.dart';

void main() {
  group('StepEventPreflight', () {
    test('accepts an available detector with granted permission', () {
      final StepEventPreflight result = StepEventPreflight.fromPlatform(
        _validPreflight(),
      );

      expect(result.stepDetectorAvailable, isTrue);
      expect(result.activityRecognitionPermissionGranted, isTrue);
      expect(result.canRunStepDiagnostic, isTrue);
    });

    test('accepts an available detector with denied permission', () {
      final StepEventPreflight result = StepEventPreflight.fromPlatform(
        _validPreflight(permissionGranted: false),
      );

      expect(result.stepDetectorAvailable, isTrue);
      expect(result.activityRecognitionPermissionGranted, isFalse);
      expect(result.canRunStepDiagnostic, isFalse);
    });

    test('accepts an unavailable detector', () {
      final StepEventPreflight result = StepEventPreflight.fromPlatform(
        _validPreflight(detectorAvailable: false),
      );

      expect(result.stepDetectorAvailable, isFalse);
      expect(result.stepDetectorName, isNull);
      expect(result.canRunStepDiagnostic, isFalse);
    });

    test('rejects a wrong schema', () {
      final Map<String, Object?> value = _validPreflight();
      value['schemaVersion'] = 2;

      expect(
        () => StepEventPreflight.fromPlatform(value),
        throwsFormatException,
      );
    });

    test('rejects a wrong snapshot kind', () {
      final Map<String, Object?> value = _validPreflight();
      value['snapshotKind'] = 'wrong_kind';

      expect(
        () => StepEventPreflight.fromPlatform(value),
        throwsFormatException,
      );
    });

    test('rejects inconsistent canRunStepDiagnostic', () {
      final Map<String, Object?> value = _validPreflight();
      value['canRunStepDiagnostic'] = false;

      expect(
        () => StepEventPreflight.fromPlatform(value),
        throwsFormatException,
      );
    });
  });

  group('StepEventDiagnosticResult valid contracts', () {
    test('accepts a zero-step result', () {
      final StepEventDiagnosticResult result =
          StepEventDiagnosticResult.fromPlatform(_validResult(0));

      expect(result.acceptedStepEventCount, 0);
      expect(result.deltaCount, 0);
      expect(result.medianStepIntervalMs, isNull);
      expect(result.observedCadenceStepsPerMinute, isNull);
    });

    test('accepts a one-step result', () {
      final StepEventDiagnosticResult result =
          StepEventDiagnosticResult.fromPlatform(_validResult(1));

      expect(result.acceptedStepEventCount, 1);
      expect(result.deltaCount, 0);
      expect(result.medianStepIntervalMs, isNull);
    });

    test('accepts a multi-step result', () {
      final StepEventDiagnosticResult result =
          StepEventDiagnosticResult.fromPlatform(_validResult(3));

      expect(result.acceptedStepEventCount, 3);
      expect(result.deltaCount, 2);
      expect(result.medianStepIntervalMs, 600.0);
      expect(result.observedCadenceStepsPerMinute, 100.0);
    });
  });

  group('StepEventDiagnosticResult invalid contracts', () {
    test('rejects a wrong schema', () {
      _expectInvalidResult('schemaVersion', 2);
    });

    test('rejects a wrong snapshot kind', () {
      _expectInvalidResult('snapshotKind', 'wrong_kind');
    });

    test('rejects success false', () {
      _expectInvalidResult('success', false);
    });

    test('rejects a wrong sensor type', () {
      _expectInvalidResult('sensorType', 'TYPE_STEP_COUNTER');
    });

    test('rejects a wrong duration', () {
      _expectInvalidResult('sessionDurationMs', 10000);
    });

    test('rejects a wrong timestamp authority', () {
      _expectInvalidResult(
        'stepTimestampAuthority',
        'System.currentTimeMillis',
      );
    });

    test('rejects a wrong operation clock', () {
      _expectInvalidResult('operationWindowClock', 'Handler callback time');
    });

    test('rejects wall-clock step timing', () {
      _expectInvalidResult('wallClockUsedForStepTiming', true);
    });

    test('rejects negative counts', () {
      _expectInvalidResult('updateCount', -1);
    });

    test('rejects accepted count above update count', () {
      _expectInvalidResult('acceptedStepEventCount', 4);
    });

    test('rejects a unique timestamp mismatch', () {
      _expectInvalidResult('uniqueTimestampCount', 2);
    });

    test('rejects a duplicate count inconsistency', () {
      _expectInvalidResult('duplicateTimestampCount', 1);
    });

    test('rejects a non-monotonic count inconsistency', () {
      _expectInvalidResult('nonMonotonicTimestampCount', 1);
    });

    test('rejects a delta-count mismatch', () {
      _expectInvalidResult('deltaCount', 1);
    });

    for (final int acceptedCount in <int>[0, 1]) {
      test('rejects interval values for $acceptedCount accepted events', () {
        final Map<String, Object?> value = _validResult(acceptedCount);
        value['minStepIntervalMs'] = 500.0;

        expect(
          () => StepEventDiagnosticResult.fromPlatform(value),
          throwsFormatException,
        );
      });
    }

    test('rejects missing intervals for a multi-step result', () {
      _expectInvalidResult('medianStepIntervalMs', null);
    });

    test('rejects non-finite intervals', () {
      _expectInvalidResult('meanStepIntervalMs', double.infinity);
    });

    test('rejects negative intervals', () {
      _expectInvalidResult('minStepIntervalMs', -1.0);
    });

    test('rejects inconsistent interval ordering', () {
      _expectInvalidResult('medianStepIntervalMs', 800.0);
    });

    test('rejects invalid cadence', () {
      _expectInvalidResult('observedCadenceStepsPerMinute', 0.0);
    });

    test('rejects validated step-detection accuracy', () {
      _expectInvalidResult('stepDetectionAccuracyValidated', true);
    });

    test('rejects implemented step length', () {
      _expectInvalidResult('stepLengthImplemented', true);
    });

    test('rejects implemented PDR position', () {
      _expectInvalidResult('pdrPositionImplemented', true);
    });

    test('rejects returned raw step events', () {
      _expectInvalidResult('rawStepEventsReturned', true);
    });

    test('rejects returned raw sensor samples', () {
      _expectInvalidResult('rawSensorSamplesReturned', true);
    });

    test('rejects persistence use', () {
      _expectInvalidResult('persistenceUsed', true);
    });
  });
}

Map<String, Object?> _validPreflight({
  bool detectorAvailable = true,
  bool permissionRequired = true,
  bool permissionGranted = true,
  bool diagnosticRunning = false,
}) {
  final bool permissionSatisfied = !permissionRequired || permissionGranted;

  return <String, Object?>{
    'schemaVersion': stepEventSchemaVersion,
    'snapshotKind': 'step_event_preflight',
    'stepDetectorAvailable': detectorAvailable,
    'stepDetectorName': detectorAvailable ? 'Synthetic Step Detector' : null,
    'activityRecognitionPermissionRequired': permissionRequired,
    'activityRecognitionPermissionGranted': permissionGranted,
    'diagnosticRunning': diagnosticRunning,
    'canRunStepDiagnostic':
        detectorAvailable && permissionSatisfied && !diagnosticRunning,
  };
}

Map<String, Object?> _validResult(int acceptedCount) {
  final bool hasIntervals = acceptedCount >= 2;

  return <String, Object?>{
    'schemaVersion': stepEventSchemaVersion,
    'snapshotKind': 'step_event_diagnostic_result',
    'success': true,
    'sensorType': stepEventSensorType,
    'sensorName': 'Synthetic Step Detector',
    'sessionDurationMs': stepEventSessionDurationMs,
    'stepTimestampAuthority': stepEventTimestampAuthority,
    'operationWindowClock': stepEventOperationWindowClock,
    'wallClockUsedForStepTiming': false,
    'updateCount': acceptedCount,
    'acceptedStepEventCount': acceptedCount,
    'invalidStepEventCount': 0,
    'outOfWindowStepEventCount': 0,
    'uniqueTimestampCount': acceptedCount,
    'duplicateTimestampCount': 0,
    'nonMonotonicTimestampCount': 0,
    'deltaCount': hasIntervals ? acceptedCount - 1 : 0,
    'minStepIntervalMs': hasIntervals ? 500.0 : null,
    'maxStepIntervalMs': hasIntervals ? 700.0 : null,
    'meanStepIntervalMs': hasIntervals ? 600.0 : null,
    'medianStepIntervalMs': hasIntervals ? 600.0 : null,
    'p95StepIntervalMs': hasIntervals ? 700.0 : null,
    'observedCadenceStepsPerMinute': hasIntervals ? 100.0 : null,
    'stepDetectionAccuracyValidated': false,
    'stepLengthImplemented': false,
    'pdrPositionImplemented': false,
    'rawStepEventsReturned': false,
    'rawSensorSamplesReturned': false,
    'persistenceUsed': false,
  };
}

void _expectInvalidResult(String key, Object? replacement) {
  final Map<String, Object?> value = _validResult(3);
  value[key] = replacement;

  expect(
    () => StepEventDiagnosticResult.fromPlatform(value),
    throwsFormatException,
  );
}
