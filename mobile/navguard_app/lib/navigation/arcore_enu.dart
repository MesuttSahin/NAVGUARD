import 'dart:math' as math;

const int arCoreEnuSchemaVersion = 1;
const int arCoreEnuAlignmentHoldMs = 2000;
const int arCoreEnuMeasurementWindowMs = 30000;
const double arCoreEnuNumericalTolerance = 1e-9;
const String arCoreEnuCoordinateFrame = 'local_enu';
const String arCoreEnuPoseSource = 'Frame.getAndroidSensorPose';
const String arCoreEnuReferenceStrategy = 'local_arcore_anchor';
const String arCoreEnuRelativePoseStrategy =
    'anchor_inverse_compose_android_sensor_pose';
const String arCoreEnuAlignmentSource =
    'rotation_vector_plus_geomagnetic_declination';
const String arCoreEnuRotationVectorSource = 'TYPE_ROTATION_VECTOR';
const String arCoreEnuRotationTimestampAuthority = 'SensorEvent.timestamp';
const String arCoreEnuFrameTimestampAuthority = 'Frame.getTimestamp';
const String arCoreEnuFrameTimestampTimeBase = 'undefined_by_arcore_api';
const String arCoreEnuOperationWindowClock = 'SystemClock.elapsedRealtimeNanos';
const String arCoreEnuTrackingFractionDenominator =
    'arFrameUpdateCount_formal_window';
const String arCoreEnuDeclinationProvider = 'android.hardware.GeomagneticField';
const String arCoreEnuDeclinationModelVersion = 'platform_managed';

class EnuVector {
  const EnuVector({
    required this.eastM,
    required this.northM,
    required this.upM,
  });

  final double eastM;
  final double northM;
  final double upM;
}

List<double> multiplyMatrix3Vector(List<double> matrix, List<double> vector) {
  _validateFiniteList(matrix, 9, 'matrix');
  _validateFiniteList(vector, 3, 'vector');

  return List<double>.generate(3, (int row) {
    double value = 0.0;
    for (int column = 0; column < 3; column += 1) {
      value += matrix[(row * 3) + column] * vector[column];
    }
    return value;
  }, growable: false);
}

List<double> multiplyMatrix3(List<double> left, List<double> right) {
  _validateFiniteList(left, 9, 'left matrix');
  _validateFiniteList(right, 9, 'right matrix');

  return List<double>.generate(9, (int index) {
    final int row = index ~/ 3;
    final int column = index % 3;
    double value = 0.0;
    for (int inner = 0; inner < 3; inner += 1) {
      value += left[(row * 3) + inner] * right[(inner * 3) + column];
    }
    return value;
  }, growable: false);
}

List<double> createDeclinationCorrectionMatrix(double declinationRad) {
  if (!declinationRad.isFinite) {
    throw const FormatException('Declination must be finite.');
  }
  final double cosine = math.cos(declinationRad);
  final double sine = math.sin(declinationRad);
  return <double>[cosine, sine, 0.0, -sine, cosine, 0.0, 0.0, 0.0, 1.0];
}

List<double> magneticDeviceRotationToTrueEnu({
  required List<double> magneticDeviceRotation,
  required double declinationRad,
}) {
  return multiplyMatrix3(
    createDeclinationCorrectionMatrix(declinationRad),
    magneticDeviceRotation,
  );
}

EnuVector transformRelativeDeviceDisplacementToEnu({
  required List<double> enuFromInitialDeviceRotation,
  required List<double> relativeDeviceDisplacementM,
}) {
  final List<double> result = multiplyMatrix3Vector(
    enuFromInitialDeviceRotation,
    relativeDeviceDisplacementM,
  );
  return EnuVector(eastM: result[0], northM: result[1], upM: result[2]);
}

class ArCoreEnuPreflight {
  const ArCoreEnuPreflight._({
    required this.arCoreSupported,
    required this.arCoreInstalled,
    required this.cameraPermissionGranted,
    required this.rotationVectorAvailable,
    required this.rotationVectorName,
    required this.diagnosticRunning,
    required this.nativeReady,
  });

  factory ArCoreEnuPreflight.fromPlatform(Object? rawSnapshot) {
    final Map<Object?, Object?> snapshot = _requiredMap(rawSnapshot);
    _requireExactInt(snapshot, 'schemaVersion', arCoreEnuSchemaVersion);
    _requireExactString(snapshot, 'snapshotKind', 'arcore_enu_preflight');

    final bool arCoreSupported = _requiredBool(snapshot, 'arCoreSupported');
    final bool arCoreInstalled = _requiredBool(snapshot, 'arCoreInstalled');
    final bool cameraPermissionGranted = _requiredBool(
      snapshot,
      'cameraPermissionGranted',
    );
    final bool rotationVectorAvailable = _requiredBool(
      snapshot,
      'rotationVectorAvailable',
    );
    final String? rotationVectorName = _nullableString(
      snapshot,
      'rotationVectorName',
    );
    final bool diagnosticRunning = _requiredBool(snapshot, 'diagnosticRunning');
    final bool nativeReady = _requiredBool(snapshot, 'nativeReady');

    if (rotationVectorAvailable != (rotationVectorName != null)) {
      throw const FormatException(
        'Rotation-vector availability metadata is inconsistent.',
      );
    }
    if (arCoreInstalled && !arCoreSupported) {
      throw const FormatException('ARCore availability metadata is invalid.');
    }
    final bool expectedReady =
        arCoreSupported &&
        arCoreInstalled &&
        cameraPermissionGranted &&
        rotationVectorAvailable &&
        !diagnosticRunning;
    if (nativeReady != expectedReady) {
      throw const FormatException('ARCore-to-ENU readiness is inconsistent.');
    }

    return ArCoreEnuPreflight._(
      arCoreSupported: arCoreSupported,
      arCoreInstalled: arCoreInstalled,
      cameraPermissionGranted: cameraPermissionGranted,
      rotationVectorAvailable: rotationVectorAvailable,
      rotationVectorName: rotationVectorName,
      diagnosticRunning: diagnosticRunning,
      nativeReady: nativeReady,
    );
  }

  final bool arCoreSupported;
  final bool arCoreInstalled;
  final bool cameraPermissionGranted;
  final bool rotationVectorAvailable;
  final String? rotationVectorName;
  final bool diagnosticRunning;
  final bool nativeReady;

  Map<String, Object?> get sanitizedMetadata => <String, Object?>{
    'schemaVersion': arCoreEnuSchemaVersion,
    'snapshotKind': 'arcore_enu_preflight',
    'arCoreSupported': arCoreSupported,
    'arCoreInstalled': arCoreInstalled,
    'cameraPermissionGranted': cameraPermissionGranted,
    'rotationVectorAvailable': rotationVectorAvailable,
    'rotationVectorName': rotationVectorName,
    'diagnosticRunning': diagnosticRunning,
    'nativeReady': nativeReady,
  };
}

class ArCoreEnuDiagnosticResult {
  const ArCoreEnuDiagnosticResult._({
    required this.arFrameUpdateCount,
    required this.trackingFrameCount,
    required this.pausedFrameCount,
    required this.stoppedFrameCount,
    required this.usableEnuFrameCount,
    required this.uniqueArFrameTimestampCount,
    required this.duplicateArFrameTimestampCount,
    required this.nonMonotonicArFrameTimestampCount,
    required this.deltaCount,
    required this.minFrameDeltaMs,
    required this.maxFrameDeltaMs,
    required this.meanFrameDeltaMs,
    required this.medianFrameDeltaMs,
    required this.p95FrameDeltaMs,
    required this.observedTrackingFrameRateHz,
    required this.trackingFraction,
    required this.finalEastM,
    required this.finalNorthM,
    required this.finalUpM,
    required this.finalHorizontalDisplacementM,
    required this.final3dDisplacementM,
    required this.maxHorizontalDisplacementM,
    required this.maxAbsUpM,
    required this.declinationRad,
    required this.declinationAltitudeSource,
    required this.rotationVectorUpdateCount,
    required this.validRotationVectorSampleCount,
    required this.invalidRotationVectorSampleCount,
    required this.uniqueRotationVectorTimestampCount,
    required this.duplicateRotationVectorTimestampCount,
    required this.nonMonotonicRotationVectorTimestampCount,
  });

  factory ArCoreEnuDiagnosticResult.fromPlatform(Object? rawSnapshot) {
    final Map<Object?, Object?> snapshot = _requiredMap(rawSnapshot);

    _requireExactInt(snapshot, 'schemaVersion', arCoreEnuSchemaVersion);
    _requireExactString(
      snapshot,
      'snapshotKind',
      'arcore_enu_diagnostic_result',
    );
    _requireTrue(snapshot, 'success');
    _requireExactInt(snapshot, 'alignmentHoldMs', arCoreEnuAlignmentHoldMs);
    _requireExactInt(
      snapshot,
      'measurementWindowMs',
      arCoreEnuMeasurementWindowMs,
    );
    _requireExactString(snapshot, 'coordinateFrame', arCoreEnuCoordinateFrame);
    _requireExactString(snapshot, 'arcorePoseSource', arCoreEnuPoseSource);
    _requireExactString(
      snapshot,
      'referenceStrategy',
      arCoreEnuReferenceStrategy,
    );
    _requireExactString(
      snapshot,
      'relativePoseStrategy',
      arCoreEnuRelativePoseStrategy,
    );
    _requireExactString(
      snapshot,
      'enuAlignmentSource',
      arCoreEnuAlignmentSource,
    );
    _requireExactString(
      snapshot,
      'rotationVectorSource',
      arCoreEnuRotationVectorSource,
    );
    _requireExactString(
      snapshot,
      'rotationVectorTimestampAuthority',
      arCoreEnuRotationTimestampAuthority,
    );
    _requireExactString(
      snapshot,
      'arFrameTimestampAuthority',
      arCoreEnuFrameTimestampAuthority,
    );
    _requireExactString(
      snapshot,
      'arFrameTimestampTimeBase',
      arCoreEnuFrameTimestampTimeBase,
    );
    _requireExactString(
      snapshot,
      'operationWindowClock',
      arCoreEnuOperationWindowClock,
    );
    _requireFalse(snapshot, 'crossClockTimestampComparisonUsed');

    _requireTrue(snapshot, 'alignmentCompleted');
    _requireTrue(snapshot, 'alignmentStationarityAssumed');
    _requireFalse(snapshot, 'alignmentStationarityValidated');
    _requireTrue(snapshot, 'trueNorthAlignmentUsed');
    _requireTrue(snapshot, 'anchorUsedForDeclination');
    _requireFalse(snapshot, 'liveGnssUsed');

    final double declinationRad = _requiredFiniteDouble(
      snapshot,
      'declinationRad',
    );
    _requireExactString(
      snapshot,
      'declinationProvider',
      arCoreEnuDeclinationProvider,
    );
    _requireExactString(
      snapshot,
      'declinationModelVersion',
      arCoreEnuDeclinationModelVersion,
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

    final int rotationVectorUpdateCount = _requiredNonNegativeInt(
      snapshot,
      'rotationVectorUpdateCount',
    );
    final int validRotationVectorSampleCount = _requiredNonNegativeInt(
      snapshot,
      'validRotationVectorSampleCount',
    );
    final int invalidRotationVectorSampleCount = _requiredNonNegativeInt(
      snapshot,
      'invalidRotationVectorSampleCount',
    );
    final int uniqueRotationVectorTimestampCount = _requiredNonNegativeInt(
      snapshot,
      'uniqueRotationVectorTimestampCount',
    );
    final int duplicateRotationVectorTimestampCount = _requiredNonNegativeInt(
      snapshot,
      'duplicateRotationVectorTimestampCount',
    );
    final int nonMonotonicRotationVectorTimestampCount =
        _requiredNonNegativeInt(
          snapshot,
          'nonMonotonicRotationVectorTimestampCount',
        );
    if (rotationVectorUpdateCount !=
            validRotationVectorSampleCount +
                invalidRotationVectorSampleCount +
                duplicateRotationVectorTimestampCount +
                nonMonotonicRotationVectorTimestampCount ||
        uniqueRotationVectorTimestampCount != validRotationVectorSampleCount ||
        validRotationVectorSampleCount == 0) {
      throw const FormatException('Rotation-vector counters are inconsistent.');
    }

    final int arFrameUpdateCount = _requiredNonNegativeInt(
      snapshot,
      'arFrameUpdateCount',
    );
    final int trackingFrameCount = _requiredNonNegativeInt(
      snapshot,
      'trackingFrameCount',
    );
    final int pausedFrameCount = _requiredNonNegativeInt(
      snapshot,
      'pausedFrameCount',
    );
    final int stoppedFrameCount = _requiredNonNegativeInt(
      snapshot,
      'stoppedFrameCount',
    );
    final int usableEnuFrameCount = _requiredNonNegativeInt(
      snapshot,
      'usableEnuFrameCount',
    );
    final int uniqueArFrameTimestampCount = _requiredNonNegativeInt(
      snapshot,
      'uniqueArFrameTimestampCount',
    );
    final int duplicateArFrameTimestampCount = _requiredNonNegativeInt(
      snapshot,
      'duplicateArFrameTimestampCount',
    );
    final int nonMonotonicArFrameTimestampCount = _requiredNonNegativeInt(
      snapshot,
      'nonMonotonicArFrameTimestampCount',
    );
    final int deltaCount = _requiredNonNegativeInt(snapshot, 'deltaCount');
    if (trackingFrameCount + pausedFrameCount + stoppedFrameCount !=
            arFrameUpdateCount ||
        usableEnuFrameCount > trackingFrameCount ||
        uniqueArFrameTimestampCount > arFrameUpdateCount ||
        uniqueArFrameTimestampCount +
                duplicateArFrameTimestampCount +
                nonMonotonicArFrameTimestampCount >
            arFrameUpdateCount ||
        deltaCount !=
            (uniqueArFrameTimestampCount > 0
                ? uniqueArFrameTimestampCount - 1
                : 0)) {
      throw const FormatException('ARCore frame counters are inconsistent.');
    }

    final double? minFrameDeltaMs = _nullableFiniteDouble(
      snapshot,
      'minFrameDeltaMs',
    );
    final double? maxFrameDeltaMs = _nullableFiniteDouble(
      snapshot,
      'maxFrameDeltaMs',
    );
    final double? meanFrameDeltaMs = _nullableFiniteDouble(
      snapshot,
      'meanFrameDeltaMs',
    );
    final double? medianFrameDeltaMs = _nullableFiniteDouble(
      snapshot,
      'medianFrameDeltaMs',
    );
    final double? p95FrameDeltaMs = _nullableFiniteDouble(
      snapshot,
      'p95FrameDeltaMs',
    );
    final double? observedTrackingFrameRateHz = _nullableFiniteDouble(
      snapshot,
      'observedTrackingFrameRateHz',
    );
    final List<double?> timingValues = <double?>[
      minFrameDeltaMs,
      maxFrameDeltaMs,
      meanFrameDeltaMs,
      medianFrameDeltaMs,
      p95FrameDeltaMs,
      observedTrackingFrameRateHz,
    ];
    if (deltaCount == 0) {
      if (timingValues.any((double? value) => value != null)) {
        throw const FormatException(
          'Frame timing must be null without deltas.',
        );
      }
    } else {
      if (timingValues.any((double? value) => value == null)) {
        throw const FormatException('Frame timing metadata is incomplete.');
      }
      final double minimum = minFrameDeltaMs!;
      final double maximum = maxFrameDeltaMs!;
      if (timingValues.any((double? value) => value! <= 0.0) ||
          maximum < minimum ||
          meanFrameDeltaMs! < minimum ||
          meanFrameDeltaMs > maximum ||
          medianFrameDeltaMs! < minimum ||
          medianFrameDeltaMs > maximum ||
          p95FrameDeltaMs! < minimum ||
          p95FrameDeltaMs > maximum) {
        throw const FormatException('Frame timing metadata is inconsistent.');
      }
    }

    _requireExactString(
      snapshot,
      'trackingFractionDenominator',
      arCoreEnuTrackingFractionDenominator,
    );
    final double trackingFraction = _requiredFiniteDouble(
      snapshot,
      'trackingFraction',
    );
    final double expectedTrackingFraction = arFrameUpdateCount == 0
        ? 0.0
        : trackingFrameCount / arFrameUpdateCount;
    if (trackingFraction < 0.0 ||
        trackingFraction > 1.0 ||
        !_nearlyEqual(trackingFraction, expectedTrackingFraction)) {
      throw const FormatException('Tracking fraction is inconsistent.');
    }

    final double finalEastM = _requiredFiniteDouble(snapshot, 'finalEastM');
    final double finalNorthM = _requiredFiniteDouble(snapshot, 'finalNorthM');
    final double finalUpM = _requiredFiniteDouble(snapshot, 'finalUpM');
    final double finalHorizontalDisplacementM = _requiredFiniteDouble(
      snapshot,
      'finalHorizontalDisplacementM',
    );
    final double final3dDisplacementM = _requiredFiniteDouble(
      snapshot,
      'final3dDisplacementM',
    );
    final double maxHorizontalDisplacementM = _requiredFiniteDouble(
      snapshot,
      'maxHorizontalDisplacementM',
    );
    final double maxAbsUpM = _requiredFiniteDouble(snapshot, 'maxAbsUpM');
    final double expectedHorizontal = math.sqrt(
      (finalEastM * finalEastM) + (finalNorthM * finalNorthM),
    );
    final double expected3d = math.sqrt(
      (finalEastM * finalEastM) +
          (finalNorthM * finalNorthM) +
          (finalUpM * finalUpM),
    );
    if (finalHorizontalDisplacementM < 0.0 ||
        final3dDisplacementM < 0.0 ||
        maxHorizontalDisplacementM < 0.0 ||
        maxAbsUpM < 0.0 ||
        !_nearlyEqual(finalHorizontalDisplacementM, expectedHorizontal) ||
        !_nearlyEqual(final3dDisplacementM, expected3d) ||
        maxHorizontalDisplacementM + arCoreEnuNumericalTolerance <
            finalHorizontalDisplacementM ||
        maxAbsUpM + arCoreEnuNumericalTolerance < finalUpM.abs()) {
      throw const FormatException(
        'ARCore-to-ENU position metadata is invalid.',
      );
    }

    _requireTrue(snapshot, 'arcoreRelativeMotionImplemented');
    _requireTrue(snapshot, 'arcoreToEnuImplemented');
    for (final String key in <String>[
      'arcorePositionAccuracyValidated',
      'arcoreDistanceAccuracyValidated',
      'enuAlignmentAccuracyValidated',
      'headingAccuracyValidated',
      'trueNorthAccuracyValidated',
      'pdrFusionImplemented',
      'qualityEngineImplemented',
      'ekfImplemented',
      'groundTruthFirewallImplemented',
      'gnssDeniedNavigationImplemented',
      'rawTrajectoryReturned',
      'rawArcorePosesReturned',
      'rawRotationVectorSamplesReturned',
      'rawTimestampsReturned',
      'cameraImagesReturned',
      'persistenceUsed',
      'pathLengthCalculated',
      'displayRotationRemappingUsed',
      'cameraOpticalForwardUsed',
      'geospatialApiUsed',
      'cloudServiceUsed',
    ]) {
      _requireFalse(snapshot, key);
    }

    return ArCoreEnuDiagnosticResult._(
      arFrameUpdateCount: arFrameUpdateCount,
      trackingFrameCount: trackingFrameCount,
      pausedFrameCount: pausedFrameCount,
      stoppedFrameCount: stoppedFrameCount,
      usableEnuFrameCount: usableEnuFrameCount,
      uniqueArFrameTimestampCount: uniqueArFrameTimestampCount,
      duplicateArFrameTimestampCount: duplicateArFrameTimestampCount,
      nonMonotonicArFrameTimestampCount: nonMonotonicArFrameTimestampCount,
      deltaCount: deltaCount,
      minFrameDeltaMs: minFrameDeltaMs,
      maxFrameDeltaMs: maxFrameDeltaMs,
      meanFrameDeltaMs: meanFrameDeltaMs,
      medianFrameDeltaMs: medianFrameDeltaMs,
      p95FrameDeltaMs: p95FrameDeltaMs,
      observedTrackingFrameRateHz: observedTrackingFrameRateHz,
      trackingFraction: trackingFraction,
      finalEastM: finalEastM,
      finalNorthM: finalNorthM,
      finalUpM: finalUpM,
      finalHorizontalDisplacementM: finalHorizontalDisplacementM,
      final3dDisplacementM: final3dDisplacementM,
      maxHorizontalDisplacementM: maxHorizontalDisplacementM,
      maxAbsUpM: maxAbsUpM,
      declinationRad: declinationRad,
      declinationAltitudeSource: declinationAltitudeSource,
      rotationVectorUpdateCount: rotationVectorUpdateCount,
      validRotationVectorSampleCount: validRotationVectorSampleCount,
      invalidRotationVectorSampleCount: invalidRotationVectorSampleCount,
      uniqueRotationVectorTimestampCount: uniqueRotationVectorTimestampCount,
      duplicateRotationVectorTimestampCount:
          duplicateRotationVectorTimestampCount,
      nonMonotonicRotationVectorTimestampCount:
          nonMonotonicRotationVectorTimestampCount,
    );
  }

  final int arFrameUpdateCount;
  final int trackingFrameCount;
  final int pausedFrameCount;
  final int stoppedFrameCount;
  final int usableEnuFrameCount;
  final int uniqueArFrameTimestampCount;
  final int duplicateArFrameTimestampCount;
  final int nonMonotonicArFrameTimestampCount;
  final int deltaCount;
  final double? minFrameDeltaMs;
  final double? maxFrameDeltaMs;
  final double? meanFrameDeltaMs;
  final double? medianFrameDeltaMs;
  final double? p95FrameDeltaMs;
  final double? observedTrackingFrameRateHz;
  final double trackingFraction;
  final double finalEastM;
  final double finalNorthM;
  final double finalUpM;
  final double finalHorizontalDisplacementM;
  final double final3dDisplacementM;
  final double maxHorizontalDisplacementM;
  final double maxAbsUpM;
  final double declinationRad;
  final String declinationAltitudeSource;
  final int rotationVectorUpdateCount;
  final int validRotationVectorSampleCount;
  final int invalidRotationVectorSampleCount;
  final int uniqueRotationVectorTimestampCount;
  final int duplicateRotationVectorTimestampCount;
  final int nonMonotonicRotationVectorTimestampCount;

  Map<String, Object?> get sanitizedMetadata => <String, Object?>{
    'schemaVersion': arCoreEnuSchemaVersion,
    'snapshotKind': 'arcore_enu_diagnostic_result',
    'success': true,
    'alignmentHoldMs': arCoreEnuAlignmentHoldMs,
    'measurementWindowMs': arCoreEnuMeasurementWindowMs,
    'coordinateFrame': arCoreEnuCoordinateFrame,
    'arcorePoseSource': arCoreEnuPoseSource,
    'referenceStrategy': arCoreEnuReferenceStrategy,
    'relativePoseStrategy': arCoreEnuRelativePoseStrategy,
    'enuAlignmentSource': arCoreEnuAlignmentSource,
    'rotationVectorSource': arCoreEnuRotationVectorSource,
    'rotationVectorTimestampAuthority': arCoreEnuRotationTimestampAuthority,
    'arFrameTimestampAuthority': arCoreEnuFrameTimestampAuthority,
    'arFrameTimestampTimeBase': arCoreEnuFrameTimestampTimeBase,
    'operationWindowClock': arCoreEnuOperationWindowClock,
    'crossClockTimestampComparisonUsed': false,
    'alignmentCompleted': true,
    'alignmentStationarityAssumed': true,
    'alignmentStationarityValidated': false,
    'trueNorthAlignmentUsed': true,
    'anchorUsedForDeclination': true,
    'liveGnssUsed': false,
    'declinationRad': declinationRad,
    'declinationProvider': arCoreEnuDeclinationProvider,
    'declinationModelVersion': arCoreEnuDeclinationModelVersion,
    'declinationModelFreshnessValidated': false,
    'declinationAltitudeSource': declinationAltitudeSource,
    'rotationVectorUpdateCount': rotationVectorUpdateCount,
    'validRotationVectorSampleCount': validRotationVectorSampleCount,
    'invalidRotationVectorSampleCount': invalidRotationVectorSampleCount,
    'uniqueRotationVectorTimestampCount': uniqueRotationVectorTimestampCount,
    'duplicateRotationVectorTimestampCount':
        duplicateRotationVectorTimestampCount,
    'nonMonotonicRotationVectorTimestampCount':
        nonMonotonicRotationVectorTimestampCount,
    'arFrameUpdateCount': arFrameUpdateCount,
    'trackingFrameCount': trackingFrameCount,
    'pausedFrameCount': pausedFrameCount,
    'stoppedFrameCount': stoppedFrameCount,
    'usableEnuFrameCount': usableEnuFrameCount,
    'uniqueArFrameTimestampCount': uniqueArFrameTimestampCount,
    'duplicateArFrameTimestampCount': duplicateArFrameTimestampCount,
    'nonMonotonicArFrameTimestampCount': nonMonotonicArFrameTimestampCount,
    'deltaCount': deltaCount,
    'minFrameDeltaMs': minFrameDeltaMs,
    'maxFrameDeltaMs': maxFrameDeltaMs,
    'meanFrameDeltaMs': meanFrameDeltaMs,
    'medianFrameDeltaMs': medianFrameDeltaMs,
    'p95FrameDeltaMs': p95FrameDeltaMs,
    'observedTrackingFrameRateHz': observedTrackingFrameRateHz,
    'trackingFraction': trackingFraction,
    'trackingFractionDenominator': arCoreEnuTrackingFractionDenominator,
    'finalEastM': finalEastM,
    'finalNorthM': finalNorthM,
    'finalUpM': finalUpM,
    'finalHorizontalDisplacementM': finalHorizontalDisplacementM,
    'final3dDisplacementM': final3dDisplacementM,
    'maxHorizontalDisplacementM': maxHorizontalDisplacementM,
    'maxAbsUpM': maxAbsUpM,
    'arcoreRelativeMotionImplemented': true,
    'arcoreToEnuImplemented': true,
    'arcorePositionAccuracyValidated': false,
    'arcoreDistanceAccuracyValidated': false,
    'enuAlignmentAccuracyValidated': false,
    'headingAccuracyValidated': false,
    'trueNorthAccuracyValidated': false,
    'pdrFusionImplemented': false,
    'qualityEngineImplemented': false,
    'ekfImplemented': false,
    'groundTruthFirewallImplemented': false,
    'gnssDeniedNavigationImplemented': false,
    'rawTrajectoryReturned': false,
    'rawArcorePosesReturned': false,
    'rawRotationVectorSamplesReturned': false,
    'rawTimestampsReturned': false,
    'cameraImagesReturned': false,
    'persistenceUsed': false,
    'pathLengthCalculated': false,
    'displayRotationRemappingUsed': false,
    'cameraOpticalForwardUsed': false,
    'geospatialApiUsed': false,
    'cloudServiceUsed': false,
  };
}

void _validateFiniteList(List<double> values, int length, String label) {
  if (values.length != length ||
      values.any((double value) => !value.isFinite)) {
    throw FormatException('$label must contain $length finite values.');
  }
}

Map<Object?, Object?> _requiredMap(Object? value) {
  if (value is! Map) {
    throw const FormatException(
      'ARCore-to-ENU platform response must be a map.',
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
  if (value is! num || !value.toDouble().isFinite) {
    throw FormatException('$key must be finite and numeric.');
  }
  return value.toDouble();
}

double? _nullableFiniteDouble(Map<Object?, Object?> snapshot, String key) {
  return snapshot[key] == null ? null : _requiredFiniteDouble(snapshot, key);
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
  return (first - second).abs() <= arCoreEnuNumericalTolerance;
}
