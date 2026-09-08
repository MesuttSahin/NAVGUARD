const int stepEventSchemaVersion = 1;
const int stepEventSessionDurationMs = 30000;
const String stepEventSensorType = 'TYPE_STEP_DETECTOR';
const String stepEventTimestampAuthority = 'SensorEvent.timestamp';
const String stepEventOperationWindowClock = 'SystemClock.elapsedRealtimeNanos';

class StepEventPreflight {
  const StepEventPreflight._({
    required this.stepDetectorAvailable,
    required this.stepDetectorName,
    required this.activityRecognitionPermissionRequired,
    required this.activityRecognitionPermissionGranted,
    required this.diagnosticRunning,
    required this.canRunStepDiagnostic,
  });

  factory StepEventPreflight.fromPlatform(Object? rawSnapshot) {
    final Map<Object?, Object?> snapshot = _requiredMap(rawSnapshot);

    if (_requiredInt(snapshot, 'schemaVersion') != stepEventSchemaVersion) {
      throw const FormatException('Unsupported step preflight schema.');
    }

    if (_requiredString(snapshot, 'snapshotKind') != 'step_event_preflight') {
      throw const FormatException('Unexpected step preflight kind.');
    }

    final bool stepDetectorAvailable = _requiredBool(
      snapshot,
      'stepDetectorAvailable',
    );
    final String? stepDetectorName = _nullableString(
      snapshot,
      'stepDetectorName',
    );
    final bool permissionRequired = _requiredBool(
      snapshot,
      'activityRecognitionPermissionRequired',
    );
    final bool permissionGranted = _requiredBool(
      snapshot,
      'activityRecognitionPermissionGranted',
    );
    final bool diagnosticRunning = _requiredBool(snapshot, 'diagnosticRunning');
    final bool canRunStepDiagnostic = _requiredBool(
      snapshot,
      'canRunStepDiagnostic',
    );

    if (stepDetectorAvailable != (stepDetectorName != null)) {
      throw const FormatException(
        'Step-detector availability metadata is inconsistent.',
      );
    }

    final bool permissionSatisfied = !permissionRequired || permissionGranted;
    final bool expectedCanRun =
        stepDetectorAvailable && permissionSatisfied && !diagnosticRunning;

    if (canRunStepDiagnostic != expectedCanRun) {
      throw const FormatException(
        'Step diagnostic readiness metadata is inconsistent.',
      );
    }

    return StepEventPreflight._(
      stepDetectorAvailable: stepDetectorAvailable,
      stepDetectorName: stepDetectorName,
      activityRecognitionPermissionRequired: permissionRequired,
      activityRecognitionPermissionGranted: permissionGranted,
      diagnosticRunning: diagnosticRunning,
      canRunStepDiagnostic: canRunStepDiagnostic,
    );
  }

  final bool stepDetectorAvailable;
  final String? stepDetectorName;
  final bool activityRecognitionPermissionRequired;
  final bool activityRecognitionPermissionGranted;
  final bool diagnosticRunning;
  final bool canRunStepDiagnostic;

  Map<String, Object?> get sanitizedMetadata {
    return <String, Object?>{
      'schemaVersion': stepEventSchemaVersion,
      'snapshotKind': 'step_event_preflight',
      'stepDetectorAvailable': stepDetectorAvailable,
      'stepDetectorName': stepDetectorName,
      'activityRecognitionPermissionRequired':
          activityRecognitionPermissionRequired,
      'activityRecognitionPermissionGranted':
          activityRecognitionPermissionGranted,
      'diagnosticRunning': diagnosticRunning,
      'canRunStepDiagnostic': canRunStepDiagnostic,
    };
  }
}

class StepEventDiagnosticResult {
  const StepEventDiagnosticResult._({
    required this.sensorName,
    required this.updateCount,
    required this.acceptedStepEventCount,
    required this.invalidStepEventCount,
    required this.outOfWindowStepEventCount,
    required this.uniqueTimestampCount,
    required this.duplicateTimestampCount,
    required this.nonMonotonicTimestampCount,
    required this.deltaCount,
    required this.minStepIntervalMs,
    required this.maxStepIntervalMs,
    required this.meanStepIntervalMs,
    required this.medianStepIntervalMs,
    required this.p95StepIntervalMs,
    required this.observedCadenceStepsPerMinute,
  });

  factory StepEventDiagnosticResult.fromPlatform(Object? rawSnapshot) {
    final Map<Object?, Object?> snapshot = _requiredMap(rawSnapshot);

    if (_requiredInt(snapshot, 'schemaVersion') != stepEventSchemaVersion) {
      throw const FormatException('Unsupported step result schema.');
    }

    if (_requiredString(snapshot, 'snapshotKind') !=
        'step_event_diagnostic_result') {
      throw const FormatException('Unexpected step result kind.');
    }

    if (!_requiredBool(snapshot, 'success')) {
      throw const FormatException('Step result did not report success.');
    }

    if (_requiredString(snapshot, 'sensorType') != stepEventSensorType) {
      throw const FormatException('Unexpected step sensor type.');
    }

    final String sensorName = _requiredString(snapshot, 'sensorName');

    if (_requiredInt(snapshot, 'sessionDurationMs') !=
        stepEventSessionDurationMs) {
      throw const FormatException('Unexpected step session duration.');
    }

    if (_requiredString(snapshot, 'stepTimestampAuthority') !=
        stepEventTimestampAuthority) {
      throw const FormatException('Unexpected step timestamp authority.');
    }

    if (_requiredString(snapshot, 'operationWindowClock') !=
        stepEventOperationWindowClock) {
      throw const FormatException('Unexpected step operation clock.');
    }

    if (_requiredBool(snapshot, 'wallClockUsedForStepTiming')) {
      throw const FormatException('Wall clock cannot be used for step timing.');
    }

    final int updateCount = _requiredNonNegativeInt(snapshot, 'updateCount');
    final int acceptedStepEventCount = _requiredNonNegativeInt(
      snapshot,
      'acceptedStepEventCount',
    );
    final int invalidStepEventCount = _requiredNonNegativeInt(
      snapshot,
      'invalidStepEventCount',
    );
    final int outOfWindowStepEventCount = _requiredNonNegativeInt(
      snapshot,
      'outOfWindowStepEventCount',
    );
    final int uniqueTimestampCount = _requiredNonNegativeInt(
      snapshot,
      'uniqueTimestampCount',
    );
    final int duplicateTimestampCount = _requiredNonNegativeInt(
      snapshot,
      'duplicateTimestampCount',
    );
    final int nonMonotonicTimestampCount = _requiredNonNegativeInt(
      snapshot,
      'nonMonotonicTimestampCount',
    );
    final int deltaCount = _requiredNonNegativeInt(snapshot, 'deltaCount');

    final int classifiedUpdateCount =
        acceptedStepEventCount +
        invalidStepEventCount +
        outOfWindowStepEventCount +
        duplicateTimestampCount +
        nonMonotonicTimestampCount;

    if (acceptedStepEventCount > updateCount ||
        uniqueTimestampCount != acceptedStepEventCount ||
        classifiedUpdateCount != updateCount) {
      throw const FormatException('Step event counts are inconsistent.');
    }

    final int expectedDeltaCount = acceptedStepEventCount >= 2
        ? acceptedStepEventCount - 1
        : 0;

    if (deltaCount != expectedDeltaCount) {
      throw const FormatException('Step interval count is inconsistent.');
    }

    final double? minStepIntervalMs = _nullableFiniteDouble(
      snapshot,
      'minStepIntervalMs',
    );
    final double? maxStepIntervalMs = _nullableFiniteDouble(
      snapshot,
      'maxStepIntervalMs',
    );
    final double? meanStepIntervalMs = _nullableFiniteDouble(
      snapshot,
      'meanStepIntervalMs',
    );
    final double? medianStepIntervalMs = _nullableFiniteDouble(
      snapshot,
      'medianStepIntervalMs',
    );
    final double? p95StepIntervalMs = _nullableFiniteDouble(
      snapshot,
      'p95StepIntervalMs',
    );
    final double? observedCadenceStepsPerMinute = _nullableFiniteDouble(
      snapshot,
      'observedCadenceStepsPerMinute',
    );

    final List<double?> intervalStatistics = <double?>[
      minStepIntervalMs,
      maxStepIntervalMs,
      meanStepIntervalMs,
      medianStepIntervalMs,
      p95StepIntervalMs,
    ];

    if (acceptedStepEventCount < 2) {
      if (intervalStatistics.any((double? value) => value != null) ||
          observedCadenceStepsPerMinute != null) {
        throw const FormatException(
          'Step interval statistics require at least two accepted events.',
        );
      }
    } else {
      if (intervalStatistics.any((double? value) => value == null) ||
          observedCadenceStepsPerMinute == null) {
        throw const FormatException('Step interval statistics are missing.');
      }

      if (intervalStatistics.any((double? value) => value! <= 0.0) ||
          observedCadenceStepsPerMinute <= 0.0) {
        throw const FormatException(
          'Step interval statistics must be positive.',
        );
      }

      if (maxStepIntervalMs! < minStepIntervalMs! ||
          meanStepIntervalMs! < minStepIntervalMs ||
          meanStepIntervalMs > maxStepIntervalMs ||
          medianStepIntervalMs! < minStepIntervalMs ||
          medianStepIntervalMs > maxStepIntervalMs ||
          p95StepIntervalMs! < minStepIntervalMs ||
          p95StepIntervalMs > maxStepIntervalMs) {
        throw const FormatException(
          'Step interval statistics are inconsistent.',
        );
      }
    }

    if (_requiredBool(snapshot, 'stepDetectionAccuracyValidated') ||
        _requiredBool(snapshot, 'stepLengthImplemented') ||
        _requiredBool(snapshot, 'pdrPositionImplemented') ||
        _requiredBool(snapshot, 'rawStepEventsReturned') ||
        _requiredBool(snapshot, 'rawSensorSamplesReturned') ||
        _requiredBool(snapshot, 'persistenceUsed')) {
      throw const FormatException(
        'Step-event research or privacy flags are inconsistent.',
      );
    }

    return StepEventDiagnosticResult._(
      sensorName: sensorName,
      updateCount: updateCount,
      acceptedStepEventCount: acceptedStepEventCount,
      invalidStepEventCount: invalidStepEventCount,
      outOfWindowStepEventCount: outOfWindowStepEventCount,
      uniqueTimestampCount: uniqueTimestampCount,
      duplicateTimestampCount: duplicateTimestampCount,
      nonMonotonicTimestampCount: nonMonotonicTimestampCount,
      deltaCount: deltaCount,
      minStepIntervalMs: minStepIntervalMs,
      maxStepIntervalMs: maxStepIntervalMs,
      meanStepIntervalMs: meanStepIntervalMs,
      medianStepIntervalMs: medianStepIntervalMs,
      p95StepIntervalMs: p95StepIntervalMs,
      observedCadenceStepsPerMinute: observedCadenceStepsPerMinute,
    );
  }

  final String sensorName;
  final int updateCount;
  final int acceptedStepEventCount;
  final int invalidStepEventCount;
  final int outOfWindowStepEventCount;
  final int uniqueTimestampCount;
  final int duplicateTimestampCount;
  final int nonMonotonicTimestampCount;
  final int deltaCount;
  final double? minStepIntervalMs;
  final double? maxStepIntervalMs;
  final double? meanStepIntervalMs;
  final double? medianStepIntervalMs;
  final double? p95StepIntervalMs;
  final double? observedCadenceStepsPerMinute;

  Map<String, Object?> get sanitizedMetadata {
    return <String, Object?>{
      'schemaVersion': stepEventSchemaVersion,
      'snapshotKind': 'step_event_diagnostic_result',
      'success': true,
      'sensorType': stepEventSensorType,
      'sensorName': sensorName,
      'sessionDurationMs': stepEventSessionDurationMs,
      'stepTimestampAuthority': stepEventTimestampAuthority,
      'operationWindowClock': stepEventOperationWindowClock,
      'wallClockUsedForStepTiming': false,
      'updateCount': updateCount,
      'acceptedStepEventCount': acceptedStepEventCount,
      'invalidStepEventCount': invalidStepEventCount,
      'outOfWindowStepEventCount': outOfWindowStepEventCount,
      'uniqueTimestampCount': uniqueTimestampCount,
      'duplicateTimestampCount': duplicateTimestampCount,
      'nonMonotonicTimestampCount': nonMonotonicTimestampCount,
      'deltaCount': deltaCount,
      'minStepIntervalMs': minStepIntervalMs,
      'maxStepIntervalMs': maxStepIntervalMs,
      'meanStepIntervalMs': meanStepIntervalMs,
      'medianStepIntervalMs': medianStepIntervalMs,
      'p95StepIntervalMs': p95StepIntervalMs,
      'observedCadenceStepsPerMinute': observedCadenceStepsPerMinute,
      'stepDetectionAccuracyValidated': false,
      'stepLengthImplemented': false,
      'pdrPositionImplemented': false,
      'rawStepEventsReturned': false,
      'rawSensorSamplesReturned': false,
      'persistenceUsed': false,
    };
  }
}

Map<Object?, Object?> _requiredMap(Object? value) {
  if (value is! Map) {
    throw const FormatException('Step platform response must be a map.');
  }

  return value;
}

bool _requiredBool(Map<Object?, Object?> snapshot, String key) {
  final Object? value = snapshot[key];

  if (value is! bool) {
    throw FormatException('$key must be a boolean.');
  }

  return value;
}

String _requiredString(Map<Object?, Object?> snapshot, String key) {
  final Object? value = snapshot[key];

  if (value is! String || value.isEmpty) {
    throw FormatException('$key must be a non-empty string.');
  }

  return value;
}

String? _nullableString(Map<Object?, Object?> snapshot, String key) {
  final Object? value = snapshot[key];

  if (value == null) {
    return null;
  }

  if (value is! String || value.isEmpty) {
    throw FormatException('$key must be a non-empty string or null.');
  }

  return value;
}

int _requiredInt(Map<Object?, Object?> snapshot, String key) {
  final Object? value = snapshot[key];

  if (value is! int) {
    throw FormatException('$key must be an integer.');
  }

  return value;
}

int _requiredNonNegativeInt(Map<Object?, Object?> snapshot, String key) {
  final int value = _requiredInt(snapshot, key);

  if (value < 0) {
    throw FormatException('$key must be nonnegative.');
  }

  return value;
}

double? _nullableFiniteDouble(Map<Object?, Object?> snapshot, String key) {
  final Object? value = snapshot[key];

  if (value == null) {
    return null;
  }

  if (value is! num) {
    throw FormatException('$key must be numeric or null.');
  }

  final double converted = value.toDouble();

  if (!converted.isFinite) {
    throw FormatException('$key must be finite or null.');
  }

  return converted;
}
