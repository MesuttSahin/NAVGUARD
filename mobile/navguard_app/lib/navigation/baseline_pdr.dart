import 'dart:math' as math;

const int baselinePdrSchemaVersion = 1;
const int baselinePdrSessionDurationMs = 30000;
const double baselineStepLengthMeters = 0.75;
const double baselinePdrNumericalTolerance = 1e-9;
const String baselinePdrCoordinateFrame = 'local_enu';
const String baselinePdrHeadingConvention = 'clockwise_from_north_0_to_2pi';
const String baselinePdrDeviceForwardAxis = 'device_positive_y_top_edge';
const String baselinePdrStepSource = 'TYPE_STEP_DETECTOR';
const String baselinePdrHeadingSource = 'TYPE_ROTATION_VECTOR';
const String baselinePdrTimestampAuthority = 'SensorEvent.timestamp';
const String baselinePdrOperationWindowClock =
    'SystemClock.elapsedRealtimeNanos';
const String baselinePdrHeadingAssociationPolicy =
    'latest_valid_heading_at_or_before_step_timestamp';
const String baselinePdrStepLengthModel = 'fixed_baseline';
const String baselinePdrDeclinationProvider =
    'android.hardware.GeomagneticField';
const String baselinePdrDeclinationModelVersion = 'platform_managed';

class PdrStepDelta {
  const PdrStepDelta({required this.eastM, required this.northM});

  final double eastM;
  final double northM;
}

PdrStepDelta computeBaselinePdrStepDelta({
  required double headingRad,
  double stepLengthM = baselineStepLengthMeters,
}) {
  if (!headingRad.isFinite || !stepLengthM.isFinite || stepLengthM < 0.0) {
    throw const FormatException(
      'Baseline PDR inputs must be finite and valid.',
    );
  }

  return PdrStepDelta(
    eastM: stepLengthM * math.sin(headingRad),
    northM: stepLengthM * math.cos(headingRad),
  );
}

class BaselinePdrPosition {
  const BaselinePdrPosition({
    required this.eastM,
    required this.northM,
    required this.integratedStepCount,
    required this.netDisplacementM,
    required this.nominalIntegratedPathLengthM,
  });

  final double eastM;
  final double northM;
  final int integratedStepCount;
  final double netDisplacementM;
  final double nominalIntegratedPathLengthM;
}

BaselinePdrPosition integrateBaselinePdrHeadings(Iterable<double> headingsRad) {
  double eastM = 0.0;
  double northM = 0.0;
  int integratedStepCount = 0;

  for (final double headingRad in headingsRad) {
    final PdrStepDelta delta = computeBaselinePdrStepDelta(
      headingRad: headingRad,
    );
    eastM += delta.eastM;
    northM += delta.northM;
    integratedStepCount += 1;
  }

  return BaselinePdrPosition(
    eastM: eastM,
    northM: northM,
    integratedStepCount: integratedStepCount,
    netDisplacementM: math.sqrt((eastM * eastM) + (northM * northM)),
    nominalIntegratedPathLengthM:
        integratedStepCount * baselineStepLengthMeters,
  );
}

class BaselinePdrPreflight {
  const BaselinePdrPreflight._({
    required this.rotationVectorAvailable,
    required this.rotationVectorName,
    required this.stepDetectorAvailable,
    required this.stepDetectorName,
    required this.activityRecognitionPermissionRequired,
    required this.activityRecognitionPermissionGranted,
    required this.diagnosticRunning,
    required this.nativeSensorsReady,
  });

  factory BaselinePdrPreflight.fromPlatform(Object? rawSnapshot) {
    final Map<Object?, Object?> snapshot = _requiredMap(rawSnapshot);

    if (_requiredInt(snapshot, 'schemaVersion') != baselinePdrSchemaVersion) {
      throw const FormatException('Unsupported baseline PDR preflight schema.');
    }
    if (_requiredString(snapshot, 'snapshotKind') != 'baseline_pdr_preflight') {
      throw const FormatException('Unexpected baseline PDR preflight kind.');
    }

    final bool rotationVectorAvailable = _requiredBool(
      snapshot,
      'rotationVectorAvailable',
    );
    final String? rotationVectorName = _nullableString(
      snapshot,
      'rotationVectorName',
    );
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
    final bool nativeSensorsReady = _requiredBool(
      snapshot,
      'nativeSensorsReady',
    );

    if (rotationVectorAvailable != (rotationVectorName != null)) {
      throw const FormatException(
        'Rotation-vector availability metadata is inconsistent.',
      );
    }
    if (stepDetectorAvailable != (stepDetectorName != null)) {
      throw const FormatException(
        'Step-detector availability metadata is inconsistent.',
      );
    }

    final bool expectedReady =
        rotationVectorAvailable &&
        stepDetectorAvailable &&
        (!permissionRequired || permissionGranted) &&
        !diagnosticRunning;
    if (nativeSensorsReady != expectedReady) {
      throw const FormatException(
        'Baseline PDR native readiness metadata is inconsistent.',
      );
    }

    return BaselinePdrPreflight._(
      rotationVectorAvailable: rotationVectorAvailable,
      rotationVectorName: rotationVectorName,
      stepDetectorAvailable: stepDetectorAvailable,
      stepDetectorName: stepDetectorName,
      activityRecognitionPermissionRequired: permissionRequired,
      activityRecognitionPermissionGranted: permissionGranted,
      diagnosticRunning: diagnosticRunning,
      nativeSensorsReady: nativeSensorsReady,
    );
  }

  final bool rotationVectorAvailable;
  final String? rotationVectorName;
  final bool stepDetectorAvailable;
  final String? stepDetectorName;
  final bool activityRecognitionPermissionRequired;
  final bool activityRecognitionPermissionGranted;
  final bool diagnosticRunning;
  final bool nativeSensorsReady;

  Map<String, Object?> get sanitizedMetadata => <String, Object?>{
    'schemaVersion': baselinePdrSchemaVersion,
    'snapshotKind': 'baseline_pdr_preflight',
    'rotationVectorAvailable': rotationVectorAvailable,
    'rotationVectorName': rotationVectorName,
    'stepDetectorAvailable': stepDetectorAvailable,
    'stepDetectorName': stepDetectorName,
    'activityRecognitionPermissionRequired':
        activityRecognitionPermissionRequired,
    'activityRecognitionPermissionGranted':
        activityRecognitionPermissionGranted,
    'diagnosticRunning': diagnosticRunning,
    'nativeSensorsReady': nativeSensorsReady,
  };
}

class BaselinePdrDiagnosticResult {
  const BaselinePdrDiagnosticResult._({
    required this.stepSensorName,
    required this.headingSensorName,
    required this.stepUpdateCount,
    required this.acceptedStepEventCount,
    required this.invalidStepEventCount,
    required this.outOfWindowStepEventCount,
    required this.uniqueStepTimestampCount,
    required this.duplicateStepTimestampCount,
    required this.nonMonotonicStepTimestampCount,
    required this.associatedStepCount,
    required this.unassociatedStepCount,
    required this.integratedStepCount,
    required this.headingUpdateCount,
    required this.validHeadingSampleCount,
    required this.invalidHeadingSampleCount,
    required this.uniqueHeadingTimestampCount,
    required this.duplicateHeadingTimestampCount,
    required this.nonMonotonicHeadingTimestampCount,
    required this.minHeadingAssociationAgeMs,
    required this.maxHeadingAssociationAgeMs,
    required this.meanHeadingAssociationAgeMs,
    required this.medianHeadingAssociationAgeMs,
    required this.p95HeadingAssociationAgeMs,
    required this.finalEastM,
    required this.finalNorthM,
    required this.netDisplacementM,
    required this.nominalIntegratedPathLengthM,
    required this.declinationRad,
    required this.declinationAltitudeSource,
  });

  factory BaselinePdrDiagnosticResult.fromPlatform(Object? rawSnapshot) {
    final Map<Object?, Object?> snapshot = _requiredMap(rawSnapshot);

    _requireExactInt(snapshot, 'schemaVersion', baselinePdrSchemaVersion);
    _requireExactString(
      snapshot,
      'snapshotKind',
      'baseline_pdr_diagnostic_result',
    );
    if (!_requiredBool(snapshot, 'success')) {
      throw const FormatException(
        'Baseline PDR result did not report success.',
      );
    }
    _requireExactInt(
      snapshot,
      'sessionDurationMs',
      baselinePdrSessionDurationMs,
    );
    _requireExactString(
      snapshot,
      'coordinateFrame',
      baselinePdrCoordinateFrame,
    );
    _requireExactString(
      snapshot,
      'headingConvention',
      baselinePdrHeadingConvention,
    );
    _requireExactString(
      snapshot,
      'deviceForwardAxis',
      baselinePdrDeviceForwardAxis,
    );
    _requireExactString(snapshot, 'stepSource', baselinePdrStepSource);
    _requireExactString(snapshot, 'headingSource', baselinePdrHeadingSource);
    _requireExactString(
      snapshot,
      'stepTimestampAuthority',
      baselinePdrTimestampAuthority,
    );
    _requireExactString(
      snapshot,
      'headingTimestampAuthority',
      baselinePdrTimestampAuthority,
    );
    _requireExactString(
      snapshot,
      'operationWindowClock',
      baselinePdrOperationWindowClock,
    );
    _requireFalse(snapshot, 'wallClockUsedForSensorTiming');
    _requireExactString(
      snapshot,
      'headingAssociationPolicy',
      baselinePdrHeadingAssociationPolicy,
    );
    _requireFalse(snapshot, 'futureHeadingUsed');

    final String stepSensorName = _requiredString(snapshot, 'stepSensorName');
    final String headingSensorName = _requiredString(
      snapshot,
      'headingSensorName',
    );

    final int stepUpdateCount = _requiredNonNegativeInt(
      snapshot,
      'stepUpdateCount',
    );
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
    final int uniqueStepTimestampCount = _requiredNonNegativeInt(
      snapshot,
      'uniqueStepTimestampCount',
    );
    final int duplicateStepTimestampCount = _requiredNonNegativeInt(
      snapshot,
      'duplicateStepTimestampCount',
    );
    final int nonMonotonicStepTimestampCount = _requiredNonNegativeInt(
      snapshot,
      'nonMonotonicStepTimestampCount',
    );
    final int associatedStepCount = _requiredNonNegativeInt(
      snapshot,
      'associatedStepCount',
    );
    final int unassociatedStepCount = _requiredNonNegativeInt(
      snapshot,
      'unassociatedStepCount',
    );
    final int integratedStepCount = _requiredNonNegativeInt(
      snapshot,
      'integratedStepCount',
    );

    final int classifiedStepCount =
        acceptedStepEventCount +
        invalidStepEventCount +
        outOfWindowStepEventCount +
        duplicateStepTimestampCount +
        nonMonotonicStepTimestampCount;
    if (stepUpdateCount != classifiedStepCount ||
        uniqueStepTimestampCount != acceptedStepEventCount ||
        acceptedStepEventCount != associatedStepCount + unassociatedStepCount ||
        integratedStepCount != associatedStepCount) {
      throw const FormatException(
        'Baseline PDR step counters are inconsistent.',
      );
    }

    final int headingUpdateCount = _requiredNonNegativeInt(
      snapshot,
      'headingUpdateCount',
    );
    final int validHeadingSampleCount = _requiredNonNegativeInt(
      snapshot,
      'validHeadingSampleCount',
    );
    final int invalidHeadingSampleCount = _requiredNonNegativeInt(
      snapshot,
      'invalidHeadingSampleCount',
    );
    final int uniqueHeadingTimestampCount = _requiredNonNegativeInt(
      snapshot,
      'uniqueHeadingTimestampCount',
    );
    final int duplicateHeadingTimestampCount = _requiredNonNegativeInt(
      snapshot,
      'duplicateHeadingTimestampCount',
    );
    final int nonMonotonicHeadingTimestampCount = _requiredNonNegativeInt(
      snapshot,
      'nonMonotonicHeadingTimestampCount',
    );
    final int classifiedHeadingCount =
        validHeadingSampleCount +
        invalidHeadingSampleCount +
        duplicateHeadingTimestampCount +
        nonMonotonicHeadingTimestampCount;
    if (headingUpdateCount != classifiedHeadingCount ||
        uniqueHeadingTimestampCount != validHeadingSampleCount) {
      throw const FormatException(
        'Baseline PDR heading counters are inconsistent.',
      );
    }

    final double? minHeadingAssociationAgeMs = _nullableFiniteDouble(
      snapshot,
      'minHeadingAssociationAgeMs',
    );
    final double? maxHeadingAssociationAgeMs = _nullableFiniteDouble(
      snapshot,
      'maxHeadingAssociationAgeMs',
    );
    final double? meanHeadingAssociationAgeMs = _nullableFiniteDouble(
      snapshot,
      'meanHeadingAssociationAgeMs',
    );
    final double? medianHeadingAssociationAgeMs = _nullableFiniteDouble(
      snapshot,
      'medianHeadingAssociationAgeMs',
    );
    final double? p95HeadingAssociationAgeMs = _nullableFiniteDouble(
      snapshot,
      'p95HeadingAssociationAgeMs',
    );
    final List<double?> associationAges = <double?>[
      minHeadingAssociationAgeMs,
      maxHeadingAssociationAgeMs,
      meanHeadingAssociationAgeMs,
      medianHeadingAssociationAgeMs,
      p95HeadingAssociationAgeMs,
    ];

    if (associatedStepCount == 0) {
      if (associationAges.any((double? value) => value != null)) {
        throw const FormatException(
          'Association ages must be null without associated steps.',
        );
      }
    } else {
      if (associationAges.any((double? value) => value == null)) {
        throw const FormatException('Association age statistics are missing.');
      }
      final double minAge = minHeadingAssociationAgeMs!;
      final double maxAge = maxHeadingAssociationAgeMs!;
      if (associationAges.any((double? value) => value! < 0.0) ||
          maxAge < minAge ||
          meanHeadingAssociationAgeMs! < minAge ||
          meanHeadingAssociationAgeMs > maxAge ||
          medianHeadingAssociationAgeMs! < minAge ||
          medianHeadingAssociationAgeMs > maxAge ||
          p95HeadingAssociationAgeMs! < minAge ||
          p95HeadingAssociationAgeMs > maxAge) {
        throw const FormatException(
          'Association age statistics are inconsistent.',
        );
      }
    }

    _requireExactString(
      snapshot,
      'stepLengthModel',
      baselinePdrStepLengthModel,
    );
    final double stepLengthM = _requiredFiniteDouble(snapshot, 'stepLengthM');
    if (!_nearlyEqual(stepLengthM, baselineStepLengthMeters)) {
      throw const FormatException('Unexpected baseline PDR step length.');
    }
    _requireFalse(snapshot, 'stepLengthCalibrated');
    _requireFalse(snapshot, 'stepLengthValidated');

    final double originEastM = _requiredFiniteDouble(snapshot, 'originEastM');
    final double originNorthM = _requiredFiniteDouble(snapshot, 'originNorthM');
    if (!_nearlyEqual(originEastM, 0.0) || !_nearlyEqual(originNorthM, 0.0)) {
      throw const FormatException(
        'Baseline PDR origin must be local ENU zero.',
      );
    }

    final double finalEastM = _requiredFiniteDouble(snapshot, 'finalEastM');
    final double finalNorthM = _requiredFiniteDouble(snapshot, 'finalNorthM');
    final double netDisplacementM = _requiredFiniteDouble(
      snapshot,
      'netDisplacementM',
    );
    final double nominalIntegratedPathLengthM = _requiredFiniteDouble(
      snapshot,
      'nominalIntegratedPathLengthM',
    );
    if (netDisplacementM < 0.0 || nominalIntegratedPathLengthM < 0.0) {
      throw const FormatException(
        'Baseline PDR distances must be nonnegative.',
      );
    }
    final double expectedNet = math.sqrt(
      (finalEastM * finalEastM) + (finalNorthM * finalNorthM),
    );
    final double expectedNominalPath =
        integratedStepCount * baselineStepLengthMeters;
    if (!_nearlyEqual(netDisplacementM, expectedNet) ||
        !_nearlyEqual(nominalIntegratedPathLengthM, expectedNominalPath) ||
        netDisplacementM >
            nominalIntegratedPathLengthM + baselinePdrNumericalTolerance) {
      throw const FormatException('Baseline PDR position metadata is invalid.');
    }

    final double declinationRad = _requiredFiniteDouble(
      snapshot,
      'declinationRad',
    );
    _requireExactString(
      snapshot,
      'declinationProvider',
      baselinePdrDeclinationProvider,
    );
    _requireExactString(
      snapshot,
      'declinationModelVersion',
      baselinePdrDeclinationModelVersion,
    );
    _requireFalse(snapshot, 'declinationModelFreshnessValidated');
    final String declinationAltitudeSource = _requiredString(
      snapshot,
      'declinationAltitudeSource',
    );
    if (declinationAltitudeSource != 'anchor_ellipsoid_altitude' &&
        declinationAltitudeSource != 'deterministic_zero_fallback') {
      throw const FormatException('Unexpected declination altitude source.');
    }

    _requireTrue(snapshot, 'pdrPositionImplemented');
    for (final String key in <String>[
      'stepDetectionAccuracyValidated',
      'headingAccuracyValidated',
      'trueNorthAccuracyValidated',
      'distanceAccuracyValidated',
      'bodyHeadingImplemented',
      'arCoreFusionImplemented',
      'qualityEngineImplemented',
      'ekfImplemented',
      'groundTruthFirewallImplemented',
      'gnssDeniedNavigationImplemented',
      'rawTrajectoryReturned',
      'rawSensorSamplesReturned',
      'rawTimestampsReturned',
      'persistenceUsed',
      'liveGnssUsed',
    ]) {
      _requireFalse(snapshot, key);
    }
    _requireTrue(snapshot, 'anchorUsedForDeclination');

    return BaselinePdrDiagnosticResult._(
      stepSensorName: stepSensorName,
      headingSensorName: headingSensorName,
      stepUpdateCount: stepUpdateCount,
      acceptedStepEventCount: acceptedStepEventCount,
      invalidStepEventCount: invalidStepEventCount,
      outOfWindowStepEventCount: outOfWindowStepEventCount,
      uniqueStepTimestampCount: uniqueStepTimestampCount,
      duplicateStepTimestampCount: duplicateStepTimestampCount,
      nonMonotonicStepTimestampCount: nonMonotonicStepTimestampCount,
      associatedStepCount: associatedStepCount,
      unassociatedStepCount: unassociatedStepCount,
      integratedStepCount: integratedStepCount,
      headingUpdateCount: headingUpdateCount,
      validHeadingSampleCount: validHeadingSampleCount,
      invalidHeadingSampleCount: invalidHeadingSampleCount,
      uniqueHeadingTimestampCount: uniqueHeadingTimestampCount,
      duplicateHeadingTimestampCount: duplicateHeadingTimestampCount,
      nonMonotonicHeadingTimestampCount: nonMonotonicHeadingTimestampCount,
      minHeadingAssociationAgeMs: minHeadingAssociationAgeMs,
      maxHeadingAssociationAgeMs: maxHeadingAssociationAgeMs,
      meanHeadingAssociationAgeMs: meanHeadingAssociationAgeMs,
      medianHeadingAssociationAgeMs: medianHeadingAssociationAgeMs,
      p95HeadingAssociationAgeMs: p95HeadingAssociationAgeMs,
      finalEastM: finalEastM,
      finalNorthM: finalNorthM,
      netDisplacementM: netDisplacementM,
      nominalIntegratedPathLengthM: nominalIntegratedPathLengthM,
      declinationRad: declinationRad,
      declinationAltitudeSource: declinationAltitudeSource,
    );
  }

  final String stepSensorName;
  final String headingSensorName;
  final int stepUpdateCount;
  final int acceptedStepEventCount;
  final int invalidStepEventCount;
  final int outOfWindowStepEventCount;
  final int uniqueStepTimestampCount;
  final int duplicateStepTimestampCount;
  final int nonMonotonicStepTimestampCount;
  final int associatedStepCount;
  final int unassociatedStepCount;
  final int integratedStepCount;
  final int headingUpdateCount;
  final int validHeadingSampleCount;
  final int invalidHeadingSampleCount;
  final int uniqueHeadingTimestampCount;
  final int duplicateHeadingTimestampCount;
  final int nonMonotonicHeadingTimestampCount;
  final double? minHeadingAssociationAgeMs;
  final double? maxHeadingAssociationAgeMs;
  final double? meanHeadingAssociationAgeMs;
  final double? medianHeadingAssociationAgeMs;
  final double? p95HeadingAssociationAgeMs;
  final double finalEastM;
  final double finalNorthM;
  final double netDisplacementM;
  final double nominalIntegratedPathLengthM;
  final double declinationRad;
  final String declinationAltitudeSource;

  Map<String, Object?> get sanitizedMetadata => <String, Object?>{
    'schemaVersion': baselinePdrSchemaVersion,
    'snapshotKind': 'baseline_pdr_diagnostic_result',
    'success': true,
    'sessionDurationMs': baselinePdrSessionDurationMs,
    'coordinateFrame': baselinePdrCoordinateFrame,
    'headingConvention': baselinePdrHeadingConvention,
    'deviceForwardAxis': baselinePdrDeviceForwardAxis,
    'stepSource': baselinePdrStepSource,
    'headingSource': baselinePdrHeadingSource,
    'stepSensorName': stepSensorName,
    'headingSensorName': headingSensorName,
    'stepTimestampAuthority': baselinePdrTimestampAuthority,
    'headingTimestampAuthority': baselinePdrTimestampAuthority,
    'operationWindowClock': baselinePdrOperationWindowClock,
    'wallClockUsedForSensorTiming': false,
    'headingAssociationPolicy': baselinePdrHeadingAssociationPolicy,
    'futureHeadingUsed': false,
    'stepUpdateCount': stepUpdateCount,
    'acceptedStepEventCount': acceptedStepEventCount,
    'invalidStepEventCount': invalidStepEventCount,
    'outOfWindowStepEventCount': outOfWindowStepEventCount,
    'uniqueStepTimestampCount': uniqueStepTimestampCount,
    'duplicateStepTimestampCount': duplicateStepTimestampCount,
    'nonMonotonicStepTimestampCount': nonMonotonicStepTimestampCount,
    'associatedStepCount': associatedStepCount,
    'unassociatedStepCount': unassociatedStepCount,
    'integratedStepCount': integratedStepCount,
    'headingUpdateCount': headingUpdateCount,
    'validHeadingSampleCount': validHeadingSampleCount,
    'invalidHeadingSampleCount': invalidHeadingSampleCount,
    'uniqueHeadingTimestampCount': uniqueHeadingTimestampCount,
    'duplicateHeadingTimestampCount': duplicateHeadingTimestampCount,
    'nonMonotonicHeadingTimestampCount': nonMonotonicHeadingTimestampCount,
    'minHeadingAssociationAgeMs': minHeadingAssociationAgeMs,
    'maxHeadingAssociationAgeMs': maxHeadingAssociationAgeMs,
    'meanHeadingAssociationAgeMs': meanHeadingAssociationAgeMs,
    'medianHeadingAssociationAgeMs': medianHeadingAssociationAgeMs,
    'p95HeadingAssociationAgeMs': p95HeadingAssociationAgeMs,
    'stepLengthModel': baselinePdrStepLengthModel,
    'stepLengthM': baselineStepLengthMeters,
    'stepLengthCalibrated': false,
    'stepLengthValidated': false,
    'originEastM': 0.0,
    'originNorthM': 0.0,
    'finalEastM': finalEastM,
    'finalNorthM': finalNorthM,
    'netDisplacementM': netDisplacementM,
    'nominalIntegratedPathLengthM': nominalIntegratedPathLengthM,
    'declinationRad': declinationRad,
    'declinationProvider': baselinePdrDeclinationProvider,
    'declinationModelVersion': baselinePdrDeclinationModelVersion,
    'declinationModelFreshnessValidated': false,
    'declinationAltitudeSource': declinationAltitudeSource,
    'pdrPositionImplemented': true,
    'stepDetectionAccuracyValidated': false,
    'headingAccuracyValidated': false,
    'trueNorthAccuracyValidated': false,
    'distanceAccuracyValidated': false,
    'bodyHeadingImplemented': false,
    'arCoreFusionImplemented': false,
    'qualityEngineImplemented': false,
    'ekfImplemented': false,
    'groundTruthFirewallImplemented': false,
    'gnssDeniedNavigationImplemented': false,
    'rawTrajectoryReturned': false,
    'rawSensorSamplesReturned': false,
    'rawTimestampsReturned': false,
    'persistenceUsed': false,
    'anchorUsedForDeclination': true,
    'liveGnssUsed': false,
  };
}

Map<Object?, Object?> _requiredMap(Object? value) {
  if (value is! Map) {
    throw const FormatException(
      'Baseline PDR platform response must be a map.',
    );
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

void _requireTrue(Map<Object?, Object?> snapshot, String key) {
  if (!_requiredBool(snapshot, key)) {
    throw FormatException('$key must be true.');
  }
}

void _requireFalse(Map<Object?, Object?> snapshot, String key) {
  if (_requiredBool(snapshot, key)) {
    throw FormatException('$key must be false.');
  }
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

double? _nullableFiniteDouble(Map<Object?, Object?> snapshot, String key) {
  if (snapshot[key] == null) {
    return null;
  }
  return _requiredFiniteDouble(snapshot, key);
}

void _requireExactString(
  Map<Object?, Object?> snapshot,
  String key,
  String expected,
) {
  if (_requiredString(snapshot, key) != expected) {
    throw FormatException('$key has an unexpected value.');
  }
}

void _requireExactInt(
  Map<Object?, Object?> snapshot,
  String key,
  int expected,
) {
  if (_requiredInt(snapshot, key) != expected) {
    throw FormatException('$key has an unexpected value.');
  }
}

bool _nearlyEqual(double first, double second) {
  return (first - second).abs() <= baselinePdrNumericalTolerance;
}
