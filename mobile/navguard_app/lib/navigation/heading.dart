import 'dart:math' as math;

const int headingFoundationSchemaVersion = 1;
const int headingRequestedSamplingPeriodUs = 20000;
const int headingFirstValidSampleTimeoutMs = 10000;
const int headingMeasurementWindowMs = 30000;
const String headingSensorType = 'TYPE_ROTATION_VECTOR';
const String headingTimestampAuthority = 'SensorEvent.timestamp';
const String headingDeclinationProvider = 'android.hardware.GeomagneticField';
const String headingDeclinationModelVersion = 'platform_managed';
const String headingDeviceForwardAxis = 'device_positive_y_top_edge';
const String headingConvention = 'clockwise_from_north_0_to_2pi';

double normalizeHeadingRadians(double angle) {
  if (!angle.isFinite) {
    throw const FormatException('Heading angle must be finite.');
  }

  final double twoPi = 2.0 * math.pi;
  double normalized = angle % twoPi;

  if (normalized < 0.0) {
    normalized += twoPi;
  }

  return normalized >= twoPi ? 0.0 : normalized;
}

double shortestSignedHeadingDeltaRadians(double from, double to) {
  if (!from.isFinite || !to.isFinite) {
    throw const FormatException('Heading delta inputs must be finite.');
  }

  final double twoPi = 2.0 * math.pi;
  double delta = (to - from + math.pi) % twoPi;

  if (delta < 0.0) {
    delta += twoPi;
  }

  // The deterministic half-turn convention is [-pi, pi), so +pi maps to -pi.
  return delta - math.pi;
}

class HeadingFoundationPreflight {
  const HeadingFoundationPreflight._({
    required this.rotationVectorAvailable,
    required this.rotationVectorName,
    required this.diagnosticRunning,
  });

  factory HeadingFoundationPreflight.fromPlatform(Object? rawSnapshot) {
    final Map<Object?, Object?> snapshot = _requiredMap(rawSnapshot);

    if (_requiredInt(snapshot, 'schemaVersion') !=
        headingFoundationSchemaVersion) {
      throw const FormatException('Unsupported heading preflight schema.');
    }

    if (_requiredString(snapshot, 'snapshotKind') !=
        'heading_foundation_preflight') {
      throw const FormatException('Unexpected heading preflight kind.');
    }

    if (_requiredInt(snapshot, 'requestedSamplingPeriodUs') !=
        headingRequestedSamplingPeriodUs) {
      throw const FormatException(
        'Unexpected heading preflight sampling request.',
      );
    }

    final bool rotationVectorAvailable = _requiredBool(
      snapshot,
      'rotationVectorAvailable',
    );
    final String? rotationVectorName = _nullableString(
      snapshot,
      'rotationVectorName',
    );

    if (rotationVectorAvailable && rotationVectorName == null) {
      throw const FormatException(
        'Available rotation vector must include a sensor name.',
      );
    }

    if (!rotationVectorAvailable && rotationVectorName != null) {
      throw const FormatException(
        'Unavailable rotation vector cannot include a sensor name.',
      );
    }

    return HeadingFoundationPreflight._(
      rotationVectorAvailable: rotationVectorAvailable,
      rotationVectorName: rotationVectorName,
      diagnosticRunning: _requiredBool(snapshot, 'diagnosticRunning'),
    );
  }

  final bool rotationVectorAvailable;
  final String? rotationVectorName;
  final bool diagnosticRunning;

  Map<String, Object?> get sanitizedMetadata {
    return <String, Object?>{
      'schemaVersion': headingFoundationSchemaVersion,
      'snapshotKind': 'heading_foundation_preflight',
      'rotationVectorAvailable': rotationVectorAvailable,
      'rotationVectorName': rotationVectorName,
      'requestedSamplingPeriodUs': headingRequestedSamplingPeriodUs,
      'diagnosticRunning': diagnosticRunning,
    };
  }
}

class HeadingDiagnosticResult {
  const HeadingDiagnosticResult._({
    required this.sensorName,
    required this.updateCount,
    required this.validHeadingSampleCount,
    required this.uniqueTimestampCount,
    required this.deltaCount,
    required this.nonMonotonicTimestampCount,
    required this.duplicateTimestampCount,
    required this.durationNanos,
    required this.minDeltaMs,
    required this.maxDeltaMs,
    required this.meanDeltaMs,
    required this.medianDeltaMs,
    required this.p95DeltaMs,
    required this.observedSampleRateHz,
    required this.firstMagneticHeadingRad,
    required this.lastMagneticHeadingRad,
    required this.firstTrueNorthCorrectedHeadingRad,
    required this.lastTrueNorthCorrectedHeadingRad,
    required this.cumulativeUnwrappedTrueHeadingDeltaRad,
    required this.maxConsecutiveCircularDeltaRad,
    required this.reportedHeadingAccuracyAvailable,
    required this.lastReportedHeadingAccuracyRad,
    required this.declinationRadians,
    required this.declinationAltitudeSource,
  });

  factory HeadingDiagnosticResult.fromPlatform(Object? rawSnapshot) {
    final Map<Object?, Object?> snapshot = _requiredMap(rawSnapshot);

    if (_requiredInt(snapshot, 'schemaVersion') !=
        headingFoundationSchemaVersion) {
      throw const FormatException('Unsupported heading result schema.');
    }

    if (_requiredString(snapshot, 'snapshotKind') !=
        'heading_foundation_diagnostic') {
      throw const FormatException('Unexpected heading result kind.');
    }

    if (!_requiredBool(snapshot, 'success')) {
      throw const FormatException('Heading result did not report success.');
    }

    if (_requiredString(snapshot, 'sensorType') != headingSensorType) {
      throw const FormatException('Unexpected heading sensor type.');
    }

    final String sensorName = _requiredString(snapshot, 'sensorName');

    if (_requiredInt(snapshot, 'requestedSamplingPeriodUs') !=
        headingRequestedSamplingPeriodUs) {
      throw const FormatException('Unexpected heading sampling request.');
    }

    if (_requiredInt(snapshot, 'firstValidSampleTimeoutMs') !=
        headingFirstValidSampleTimeoutMs) {
      throw const FormatException('Unexpected first-valid heading timeout.');
    }

    if (_requiredInt(snapshot, 'measurementWindowMs') !=
        headingMeasurementWindowMs) {
      throw const FormatException('Unexpected heading measurement window.');
    }

    if (_requiredString(snapshot, 'sensorTimestampAuthority') !=
        headingTimestampAuthority) {
      throw const FormatException('Unexpected heading timestamp authority.');
    }

    if (_requiredBool(snapshot, 'wallClockUsedForSensorTiming')) {
      throw const FormatException(
        'Wall clock cannot be used for heading sensor timing.',
      );
    }

    if (_requiredString(snapshot, 'declinationTimeSource') !=
        'System.currentTimeMillis') {
      throw const FormatException('Unexpected declination time source.');
    }

    final int updateCount = _requiredNonNegativeInt(snapshot, 'updateCount');
    final int validHeadingSampleCount = _requiredInt(
      snapshot,
      'validHeadingSampleCount',
    );
    final int uniqueTimestampCount = _requiredInt(
      snapshot,
      'uniqueTimestampCount',
    );
    final int deltaCount = _requiredNonNegativeInt(snapshot, 'deltaCount');
    final int nonMonotonicTimestampCount = _requiredNonNegativeInt(
      snapshot,
      'nonMonotonicTimestampCount',
    );
    final int duplicateTimestampCount = _requiredNonNegativeInt(
      snapshot,
      'duplicateTimestampCount',
    );
    final int durationNanos = _requiredInt(snapshot, 'durationNanos');

    if (validHeadingSampleCount < 2 || uniqueTimestampCount < 2) {
      throw const FormatException(
        'Heading result requires at least two unique valid samples.',
      );
    }

    if (updateCount < validHeadingSampleCount ||
        uniqueTimestampCount + duplicateTimestampCount !=
            validHeadingSampleCount ||
        deltaCount != uniqueTimestampCount - 1 ||
        durationNanos <= 0) {
      throw const FormatException('Heading timestamp counts are inconsistent.');
    }

    final double minDeltaMs = _requiredPositiveFiniteDouble(
      snapshot,
      'minDeltaMs',
    );
    final double maxDeltaMs = _requiredPositiveFiniteDouble(
      snapshot,
      'maxDeltaMs',
    );
    final double meanDeltaMs = _requiredPositiveFiniteDouble(
      snapshot,
      'meanDeltaMs',
    );
    final double medianDeltaMs = _requiredPositiveFiniteDouble(
      snapshot,
      'medianDeltaMs',
    );
    final double p95DeltaMs = _requiredPositiveFiniteDouble(
      snapshot,
      'p95DeltaMs',
    );
    final double observedSampleRateHz = _requiredPositiveFiniteDouble(
      snapshot,
      'observedSampleRateHz',
    );

    if (maxDeltaMs < minDeltaMs ||
        meanDeltaMs < minDeltaMs ||
        meanDeltaMs > maxDeltaMs ||
        medianDeltaMs < minDeltaMs ||
        medianDeltaMs > maxDeltaMs ||
        p95DeltaMs < minDeltaMs ||
        p95DeltaMs > maxDeltaMs) {
      throw const FormatException(
        'Heading timing statistics are inconsistent.',
      );
    }

    final double firstMagneticHeadingRad = _requiredNormalizedHeading(
      snapshot,
      'firstMagneticHeadingRad',
    );
    final double lastMagneticHeadingRad = _requiredNormalizedHeading(
      snapshot,
      'lastMagneticHeadingRad',
    );
    final double firstTrueNorthCorrectedHeadingRad = _requiredNormalizedHeading(
      snapshot,
      'firstTrueNorthCorrectedHeadingRad',
    );
    final double lastTrueNorthCorrectedHeadingRad = _requiredNormalizedHeading(
      snapshot,
      'lastTrueNorthCorrectedHeadingRad',
    );
    final double cumulativeUnwrappedTrueHeadingDeltaRad = _requiredFiniteDouble(
      snapshot,
      'cumulativeUnwrappedTrueHeadingDeltaRad',
    );
    final double maxConsecutiveCircularDeltaRad = _requiredFiniteDouble(
      snapshot,
      'maxConsecutiveCircularDeltaRad',
    );

    if (maxConsecutiveCircularDeltaRad < 0.0 ||
        maxConsecutiveCircularDeltaRad > math.pi) {
      throw const FormatException(
        'Maximum circular heading delta is outside [0, pi].',
      );
    }

    final bool reportedHeadingAccuracyAvailable = _requiredBool(
      snapshot,
      'reportedHeadingAccuracyAvailable',
    );
    final double? lastReportedHeadingAccuracyRad = _nullableFiniteDouble(
      snapshot,
      'lastReportedHeadingAccuracyRad',
    );

    if (reportedHeadingAccuracyAvailable !=
            (lastReportedHeadingAccuracyRad != null) ||
        (lastReportedHeadingAccuracyRad != null &&
            lastReportedHeadingAccuracyRad < 0.0)) {
      throw const FormatException(
        'Reported heading accuracy metadata is inconsistent.',
      );
    }

    final double declinationRadians = _requiredFiniteDouble(
      snapshot,
      'declinationRadians',
    );

    if (_requiredString(snapshot, 'declinationProvider') !=
        headingDeclinationProvider) {
      throw const FormatException('Unexpected declination provider.');
    }

    if (_requiredString(snapshot, 'declinationModelVersion') !=
        headingDeclinationModelVersion) {
      throw const FormatException('Unexpected declination model version.');
    }

    if (_requiredBool(snapshot, 'declinationModelFreshnessValidated')) {
      throw const FormatException(
        'Declination model freshness cannot be reported as validated.',
      );
    }

    final String declinationAltitudeSource = _requiredString(
      snapshot,
      'declinationAltitudeSource',
    );

    if (declinationAltitudeSource != 'anchor_ellipsoid_altitude' &&
        declinationAltitudeSource != 'deterministic_zero_fallback') {
      throw const FormatException('Unexpected declination altitude source.');
    }

    if (_requiredBool(snapshot, 'headingAccuracyValidated') ||
        _requiredBool(snapshot, 'trueNorthAccuracyValidated') ||
        _requiredBool(snapshot, 'bodyHeadingImplemented')) {
      throw const FormatException(
        'Heading research limitation flags are inconsistent.',
      );
    }

    if (_requiredString(snapshot, 'deviceForwardAxis') !=
        headingDeviceForwardAxis) {
      throw const FormatException('Unexpected device forward axis.');
    }

    if (_requiredString(snapshot, 'headingConvention') != headingConvention) {
      throw const FormatException('Unexpected heading convention.');
    }

    return HeadingDiagnosticResult._(
      sensorName: sensorName,
      updateCount: updateCount,
      validHeadingSampleCount: validHeadingSampleCount,
      uniqueTimestampCount: uniqueTimestampCount,
      deltaCount: deltaCount,
      nonMonotonicTimestampCount: nonMonotonicTimestampCount,
      duplicateTimestampCount: duplicateTimestampCount,
      durationNanos: durationNanos,
      minDeltaMs: minDeltaMs,
      maxDeltaMs: maxDeltaMs,
      meanDeltaMs: meanDeltaMs,
      medianDeltaMs: medianDeltaMs,
      p95DeltaMs: p95DeltaMs,
      observedSampleRateHz: observedSampleRateHz,
      firstMagneticHeadingRad: firstMagneticHeadingRad,
      lastMagneticHeadingRad: lastMagneticHeadingRad,
      firstTrueNorthCorrectedHeadingRad: firstTrueNorthCorrectedHeadingRad,
      lastTrueNorthCorrectedHeadingRad: lastTrueNorthCorrectedHeadingRad,
      cumulativeUnwrappedTrueHeadingDeltaRad:
          cumulativeUnwrappedTrueHeadingDeltaRad,
      maxConsecutiveCircularDeltaRad: maxConsecutiveCircularDeltaRad,
      reportedHeadingAccuracyAvailable: reportedHeadingAccuracyAvailable,
      lastReportedHeadingAccuracyRad: lastReportedHeadingAccuracyRad,
      declinationRadians: declinationRadians,
      declinationAltitudeSource: declinationAltitudeSource,
    );
  }

  final String sensorName;
  final int updateCount;
  final int validHeadingSampleCount;
  final int uniqueTimestampCount;
  final int deltaCount;
  final int nonMonotonicTimestampCount;
  final int duplicateTimestampCount;
  final int durationNanos;
  final double minDeltaMs;
  final double maxDeltaMs;
  final double meanDeltaMs;
  final double medianDeltaMs;
  final double p95DeltaMs;
  final double observedSampleRateHz;
  final double firstMagneticHeadingRad;
  final double lastMagneticHeadingRad;
  final double firstTrueNorthCorrectedHeadingRad;
  final double lastTrueNorthCorrectedHeadingRad;
  final double cumulativeUnwrappedTrueHeadingDeltaRad;
  final double maxConsecutiveCircularDeltaRad;
  final bool reportedHeadingAccuracyAvailable;
  final double? lastReportedHeadingAccuracyRad;
  final double declinationRadians;
  final String declinationAltitudeSource;

  Map<String, Object?> get sanitizedMetadata {
    return <String, Object?>{
      'schemaVersion': headingFoundationSchemaVersion,
      'snapshotKind': 'heading_foundation_diagnostic',
      'success': true,
      'sensorType': headingSensorType,
      'sensorName': sensorName,
      'requestedSamplingPeriodUs': headingRequestedSamplingPeriodUs,
      'firstValidSampleTimeoutMs': headingFirstValidSampleTimeoutMs,
      'measurementWindowMs': headingMeasurementWindowMs,
      'sensorTimestampAuthority': headingTimestampAuthority,
      'wallClockUsedForSensorTiming': false,
      'declinationTimeSource': 'System.currentTimeMillis',
      'updateCount': updateCount,
      'validHeadingSampleCount': validHeadingSampleCount,
      'uniqueTimestampCount': uniqueTimestampCount,
      'deltaCount': deltaCount,
      'nonMonotonicTimestampCount': nonMonotonicTimestampCount,
      'duplicateTimestampCount': duplicateTimestampCount,
      'durationNanos': durationNanos,
      'minDeltaMs': minDeltaMs,
      'maxDeltaMs': maxDeltaMs,
      'meanDeltaMs': meanDeltaMs,
      'medianDeltaMs': medianDeltaMs,
      'p95DeltaMs': p95DeltaMs,
      'observedSampleRateHz': observedSampleRateHz,
      'firstMagneticHeadingRad': firstMagneticHeadingRad,
      'lastMagneticHeadingRad': lastMagneticHeadingRad,
      'firstTrueNorthCorrectedHeadingRad': firstTrueNorthCorrectedHeadingRad,
      'lastTrueNorthCorrectedHeadingRad': lastTrueNorthCorrectedHeadingRad,
      'cumulativeUnwrappedTrueHeadingDeltaRad':
          cumulativeUnwrappedTrueHeadingDeltaRad,
      'maxConsecutiveCircularDeltaRad': maxConsecutiveCircularDeltaRad,
      'reportedHeadingAccuracyAvailable': reportedHeadingAccuracyAvailable,
      'lastReportedHeadingAccuracyRad': lastReportedHeadingAccuracyRad,
      'declinationRadians': declinationRadians,
      'declinationProvider': headingDeclinationProvider,
      'declinationModelVersion': headingDeclinationModelVersion,
      'declinationModelFreshnessValidated': false,
      'declinationAltitudeSource': declinationAltitudeSource,
      'headingAccuracyValidated': false,
      'trueNorthAccuracyValidated': false,
      'bodyHeadingImplemented': false,
      'deviceForwardAxis': headingDeviceForwardAxis,
      'headingConvention': headingConvention,
    };
  }
}

Map<Object?, Object?> _requiredMap(Object? value) {
  if (value is! Map) {
    throw const FormatException('Heading platform response must be a map.');
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

double _requiredFiniteDouble(Map<Object?, Object?> snapshot, String key) {
  final Object? value = snapshot[key];

  if (value is! num) {
    throw FormatException('$key must be numeric.');
  }

  final double converted = value.toDouble();

  if (!converted.isFinite) {
    throw FormatException('$key must be finite.');
  }

  return converted;
}

double _requiredPositiveFiniteDouble(
  Map<Object?, Object?> snapshot,
  String key,
) {
  final double value = _requiredFiniteDouble(snapshot, key);

  if (value <= 0.0) {
    throw FormatException('$key must be positive.');
  }

  return value;
}

double? _nullableFiniteDouble(Map<Object?, Object?> snapshot, String key) {
  if (snapshot[key] == null) {
    return null;
  }

  return _requiredFiniteDouble(snapshot, key);
}

double _requiredNormalizedHeading(Map<Object?, Object?> snapshot, String key) {
  final double value = _requiredFiniteDouble(snapshot, key);

  if (value < 0.0 || value >= 2.0 * math.pi) {
    throw FormatException('$key must be in [0, 2pi).');
  }

  return value;
}
