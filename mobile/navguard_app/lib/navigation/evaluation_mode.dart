import 'dart:math' as math;

const int evaluationModeSchemaVersion = 1;
const int evaluationModeWindowMs = 30000;
const int evaluationProtectedGtFirstFixTimeoutMs = 15000;
const double evaluationConfigAStepLengthM = 0.75;
const double evaluationNumericalTolerance = 1e-9;
const String evaluationCoordinateFrame = 'local_enu';
const String evaluationDeniedEstimatorProfile = 'config_a_baseline_pdr';
const String evaluationPhysicalGnssRole = 'protected_ground_truth_only';
const String evaluationStepSource = 'TYPE_STEP_DETECTOR';
const String evaluationHeadingSource = 'TYPE_ROTATION_VECTOR';
const String evaluationHeadingConvention = 'clockwise_from_north_0_to_2pi';
const String evaluationDeviceForwardAxis = 'device_positive_y_top_edge';
const String evaluationStepLengthModel = 'fixed_baseline';
const String evaluationHeadingAssociationPolicy =
    'latest_valid_heading_at_or_before_step_timestamp';
const String evaluationSensorTimestampAuthority = 'SensorEvent.timestamp';
const String evaluationProtectedGtTimestampAuthority =
    'Location.getElapsedRealtimeNanos';
const String evaluationOperationWindowClock =
    'SystemClock.elapsedRealtimeNanos';

class EvaluationModePreflight {
  const EvaluationModePreflight._({
    required this.gpsProviderAvailable,
    required this.gpsProviderEnabled,
    required this.fineLocationPermissionGranted,
    required this.rotationVectorAvailable,
    required this.rotationVectorName,
    required this.stepDetectorAvailable,
    required this.stepDetectorName,
    required this.activityRecognitionPermissionRequired,
    required this.activityRecognitionPermissionGranted,
    required this.firewallMutationSelfTestPassed,
    required this.diagnosticRunning,
    required this.nativeReady,
  });

  factory EvaluationModePreflight.fromPlatform(Object? rawSnapshot) {
    final Map<Object?, Object?> snapshot = _requiredMap(rawSnapshot);
    _requireExactInt(snapshot, 'schemaVersion', evaluationModeSchemaVersion);
    _requireExactString(
      snapshot,
      'snapshotKind',
      'evaluation_mode_preflight',
    );

    final bool gpsAvailable = _requiredBool(
      snapshot,
      'gpsProviderAvailable',
    );
    final bool gpsEnabled = _requiredBool(snapshot, 'gpsProviderEnabled');
    final bool finePermission = _requiredBool(
      snapshot,
      'fineLocationPermissionGranted',
    );
    final bool rotationAvailable = _requiredBool(
      snapshot,
      'rotationVectorAvailable',
    );
    final String? rotationName = _nullableString(
      snapshot,
      'rotationVectorName',
    );
    final bool stepAvailable = _requiredBool(
      snapshot,
      'stepDetectorAvailable',
    );
    final String? stepName = _nullableString(snapshot, 'stepDetectorName');
    final bool activityRequired = _requiredBool(
      snapshot,
      'activityRecognitionPermissionRequired',
    );
    final bool activityGranted = _requiredBool(
      snapshot,
      'activityRecognitionPermissionGranted',
    );
    final bool selfTestPassed = _requiredBool(
      snapshot,
      'firewallMutationSelfTestPassed',
    );
    final bool running = _requiredBool(snapshot, 'diagnosticRunning');
    final bool nativeReady = _requiredBool(snapshot, 'nativeReady');

    if (gpsEnabled && !gpsAvailable) {
      throw const FormatException('GPS provider metadata is inconsistent.');
    }
    if (rotationAvailable != (rotationName != null) ||
        stepAvailable != (stepName != null)) {
      throw const FormatException('Evaluation sensor metadata is inconsistent.');
    }
    final bool expectedReady =
        gpsAvailable &&
        gpsEnabled &&
        finePermission &&
        rotationAvailable &&
        stepAvailable &&
        (!activityRequired || activityGranted) &&
        selfTestPassed &&
        !running;
    if (nativeReady != expectedReady) {
      throw const FormatException('Evaluation readiness metadata is inconsistent.');
    }

    return EvaluationModePreflight._(
      gpsProviderAvailable: gpsAvailable,
      gpsProviderEnabled: gpsEnabled,
      fineLocationPermissionGranted: finePermission,
      rotationVectorAvailable: rotationAvailable,
      rotationVectorName: rotationName,
      stepDetectorAvailable: stepAvailable,
      stepDetectorName: stepName,
      activityRecognitionPermissionRequired: activityRequired,
      activityRecognitionPermissionGranted: activityGranted,
      firewallMutationSelfTestPassed: selfTestPassed,
      diagnosticRunning: running,
      nativeReady: nativeReady,
    );
  }

  final bool gpsProviderAvailable;
  final bool gpsProviderEnabled;
  final bool fineLocationPermissionGranted;
  final bool rotationVectorAvailable;
  final String? rotationVectorName;
  final bool stepDetectorAvailable;
  final String? stepDetectorName;
  final bool activityRecognitionPermissionRequired;
  final bool activityRecognitionPermissionGranted;
  final bool firewallMutationSelfTestPassed;
  final bool diagnosticRunning;
  final bool nativeReady;

  Map<String, Object?> get sanitizedMetadata => <String, Object?>{
    'schemaVersion': evaluationModeSchemaVersion,
    'snapshotKind': 'evaluation_mode_preflight',
    'gpsProviderAvailable': gpsProviderAvailable,
    'gpsProviderEnabled': gpsProviderEnabled,
    'fineLocationPermissionGranted': fineLocationPermissionGranted,
    'rotationVectorAvailable': rotationVectorAvailable,
    'rotationVectorName': rotationVectorName,
    'stepDetectorAvailable': stepDetectorAvailable,
    'stepDetectorName': stepDetectorName,
    'activityRecognitionPermissionRequired':
        activityRecognitionPermissionRequired,
    'activityRecognitionPermissionGranted':
        activityRecognitionPermissionGranted,
    'firewallMutationSelfTestPassed': firewallMutationSelfTestPassed,
    'diagnosticRunning': diagnosticRunning,
    'nativeReady': nativeReady,
  };
}

class ConfigADeniedStepInput {
  const ConfigADeniedStepInput({
    required this.timestampNanos,
    required this.headingRad,
  });

  final int timestampNanos;
  final double headingRad;
}

class DeniedEstimatorSnapshot {
  const DeniedEstimatorSnapshot({
    required this.timestampNanos,
    required this.eastM,
    required this.northM,
    required this.integratedStepCount,
  });

  final int timestampNanos;
  final double eastM;
  final double northM;
  final int integratedStepCount;

  @override
  bool operator ==(Object other) {
    return other is DeniedEstimatorSnapshot &&
        timestampNanos == other.timestampNanos &&
        eastM == other.eastM &&
        northM == other.northM &&
        integratedStepCount == other.integratedStepCount;
  }

  @override
  int get hashCode => Object.hash(
    timestampNanos,
    eastM,
    northM,
    integratedStepCount,
  );
}

class ProtectedEvaluationReference {
  const ProtectedEvaluationReference({
    required this.timestampNanos,
    required this.eastM,
    required this.northM,
  });

  final int timestampNanos;
  final double eastM;
  final double northM;
}

class EvaluationMatch {
  const EvaluationMatch({
    required this.estimatorState,
    required this.reference,
    required this.estimatorAgeNanos,
    required this.horizontalErrorM,
  });

  final DeniedEstimatorSnapshot estimatorState;
  final ProtectedEvaluationReference reference;
  final int estimatorAgeNanos;
  final double horizontalErrorM;
}

class EvaluationStatistics {
  const EvaluationStatistics({
    required this.min,
    required this.max,
    required this.mean,
    required this.median,
    required this.p95,
  });

  final double min;
  final double max;
  final double mean;
  final double median;
  final double p95;
}

class FirewallMutationFixtureResult {
  const FirewallMutationFixtureResult({
    required this.estimatorInvariant,
    required this.evaluationMetricsDiffer,
  });

  final bool estimatorInvariant;
  final bool evaluationMetricsDiffer;

  bool get passed => estimatorInvariant && evaluationMetricsDiffer;
}

List<DeniedEstimatorSnapshot> buildConfigADeniedSnapshots({
  required int formalWindowStartNanos,
  required Iterable<ConfigADeniedStepInput> acceptedSteps,
}) {
  if (formalWindowStartNanos <= 0) {
    throw const FormatException('Formal start timestamp must be positive.');
  }
  double eastM = 0.0;
  double northM = 0.0;
  int count = 0;
  int previousTimestamp = formalWindowStartNanos;
  final List<DeniedEstimatorSnapshot> states = <DeniedEstimatorSnapshot>[
    DeniedEstimatorSnapshot(
      timestampNanos: formalWindowStartNanos,
      eastM: 0.0,
      northM: 0.0,
      integratedStepCount: 0,
    ),
  ];

  for (final ConfigADeniedStepInput step in acceptedSteps) {
    if (step.timestampNanos < previousTimestamp || !step.headingRad.isFinite) {
      throw const FormatException('Denied estimator input is invalid.');
    }
    eastM += evaluationConfigAStepLengthM * math.sin(step.headingRad);
    northM += evaluationConfigAStepLengthM * math.cos(step.headingRad);
    count += 1;
    states.add(
      DeniedEstimatorSnapshot(
        timestampNanos: step.timestampNanos,
        eastM: eastM,
        northM: northM,
        integratedStepCount: count,
      ),
    );
    previousTimestamp = step.timestampNanos;
  }
  return List<DeniedEstimatorSnapshot>.unmodifiable(states);
}

List<EvaluationMatch> matchLatestEstimatorAtOrBeforeGroundTruth({
  required List<DeniedEstimatorSnapshot> estimatorStates,
  required List<ProtectedEvaluationReference> groundTruthReferences,
}) {
  if (estimatorStates.isEmpty) {
    return const <EvaluationMatch>[];
  }
  _validateEstimatorStates(estimatorStates);
  _validateGroundTruthReferences(groundTruthReferences);
  int estimatorIndex = 0;
  DeniedEstimatorSnapshot? latest;
  final List<EvaluationMatch> matches = <EvaluationMatch>[];

  for (final ProtectedEvaluationReference reference in groundTruthReferences) {
    while (estimatorIndex < estimatorStates.length &&
        estimatorStates[estimatorIndex].timestampNanos <=
            reference.timestampNanos) {
      latest = estimatorStates[estimatorIndex];
      estimatorIndex += 1;
    }
    final DeniedEstimatorSnapshot? selected = latest;
    if (selected == null) {
      continue;
    }
    final int age = reference.timestampNanos - selected.timestampNanos;
    if (age < 0) {
      throw const FormatException('Estimator matching age cannot be negative.');
    }
    matches.add(
      EvaluationMatch(
        estimatorState: selected,
        reference: reference,
        estimatorAgeNanos: age,
        horizontalErrorM: calculateHorizontalErrorM(
          estimatorEastM: selected.eastM,
          estimatorNorthM: selected.northM,
          groundTruthEastM: reference.eastM,
          groundTruthNorthM: reference.northM,
        ),
      ),
    );
  }
  return List<EvaluationMatch>.unmodifiable(matches);
}

double calculateHorizontalErrorM({
  required double estimatorEastM,
  required double estimatorNorthM,
  required double groundTruthEastM,
  required double groundTruthNorthM,
}) {
  final List<double> values = <double>[
    estimatorEastM,
    estimatorNorthM,
    groundTruthEastM,
    groundTruthNorthM,
  ];
  if (values.any((double value) => !value.isFinite)) {
    throw const FormatException('Horizontal error inputs must be finite.');
  }
  final double errorE = estimatorEastM - groundTruthEastM;
  final double errorN = estimatorNorthM - groundTruthNorthM;
  return math.sqrt((errorE * errorE) + (errorN * errorN));
}

EvaluationStatistics calculateEvaluationStatistics(Iterable<double> values) {
  final List<double> sorted = values.toList()..sort();
  if (sorted.isEmpty ||
      sorted.any((double value) => !value.isFinite || value < 0.0)) {
    throw const FormatException('Evaluation statistics require valid values.');
  }
  final int middle = sorted.length ~/ 2;
  final double median = sorted.length.isEven
      ? (sorted[middle - 1] + sorted[middle]) / 2.0
      : sorted[middle];
  final int p95Index =
      (math.max(1, (sorted.length * 0.95).ceil()) - 1).clamp(
        0,
        sorted.length - 1,
      );
  return EvaluationStatistics(
    min: sorted.first,
    max: sorted.last,
    mean: sorted.reduce((double first, double second) => first + second) /
        sorted.length,
    median: median,
    p95: sorted[p95Index],
  );
}

FirewallMutationFixtureResult runFirewallMutationFixture() {
  const int start = 1000000000;
  const List<ConfigADeniedStepInput> inputs = <ConfigADeniedStepInput>[
    ConfigADeniedStepInput(timestampNanos: 1200000000, headingRad: 0.0),
    ConfigADeniedStepInput(
      timestampNanos: 1400000000,
      headingRad: math.pi / 2.0,
    ),
  ];
  final List<DeniedEstimatorSnapshot> statesA = buildConfigADeniedSnapshots(
    formalWindowStartNanos: start,
    acceptedSteps: inputs,
  );
  final List<DeniedEstimatorSnapshot> statesB = buildConfigADeniedSnapshots(
    formalWindowStartNanos: start,
    acceptedSteps: inputs,
  );
  const List<ProtectedEvaluationReference> gtA =
      <ProtectedEvaluationReference>[
        ProtectedEvaluationReference(
          timestampNanos: 1250000000,
          eastM: 0.0,
          northM: 0.0,
        ),
        ProtectedEvaluationReference(
          timestampNanos: 1450000000,
          eastM: 0.0,
          northM: 0.0,
        ),
      ];
  const List<ProtectedEvaluationReference> gtB =
      <ProtectedEvaluationReference>[
        ProtectedEvaluationReference(
          timestampNanos: 1250000000,
          eastM: 100.0,
          northM: -100.0,
        ),
        ProtectedEvaluationReference(
          timestampNanos: 1450000000,
          eastM: -200.0,
          northM: 200.0,
        ),
      ];
  final List<EvaluationMatch> matchesA =
      matchLatestEstimatorAtOrBeforeGroundTruth(
        estimatorStates: statesA,
        groundTruthReferences: gtA,
      );
  final List<EvaluationMatch> matchesB =
      matchLatestEstimatorAtOrBeforeGroundTruth(
        estimatorStates: statesB,
        groundTruthReferences: gtB,
      );
  return FirewallMutationFixtureResult(
    estimatorInvariant: _listsEqual(statesA, statesB),
    evaluationMetricsDiffer:
        !_listsEqual(
          matchesA.map((EvaluationMatch value) => value.horizontalErrorM).toList(),
          matchesB.map((EvaluationMatch value) => value.horizontalErrorM).toList(),
        ),
  );
}

class EvaluationModeDiagnosticResult {
  const EvaluationModeDiagnosticResult._({
    required this.protectedGtUpdateCount,
    required this.acceptedProtectedGtFixCount,
    required this.matchedGroundTruthFixCount,
    required this.integratedStepCount,
    required this.finalDeniedEastM,
    required this.finalDeniedNorthM,
    required this.medianHorizontalErrorM,
    required this.p95HorizontalErrorM,
    required this.finalDeniedPreCorrectionErrorM,
    required this.medianEstimatorAgeAtGtMs,
    required this.sanitizedMetadata,
  });

  factory EvaluationModeDiagnosticResult.fromPlatform(Object? rawSnapshot) {
    final Map<Object?, Object?> snapshot = _requiredMap(rawSnapshot);
    _validateFixedResultContract(snapshot);

    final Map<String, int> counters = <String, int>{
      for (final String key in _counterKeys)
        key: _requiredNonNegativeInt(snapshot, key),
    };
    _validateCounters(counters);

    final Map<String, double> errors = <String, double>{
      for (final String key in _errorMetricKeys)
        key: _requiredNonNegativeFiniteDouble(snapshot, key),
    };
    _validateOrderedStatistics(errors, 'HorizontalErrorM');
    final Map<String, double> ages = <String, double>{
      for (final String key in _ageMetricKeys)
        key: _requiredNonNegativeFiniteDouble(snapshot, key),
    };
    _validateOrderedStatistics(ages, 'EstimatorAgeAtGtMs');

    final List<double?> reportedAccuracy = <double?>[
      _nullableNonNegativeFiniteDouble(snapshot, 'minReportedGtAccuracyM'),
      _nullableNonNegativeFiniteDouble(snapshot, 'maxReportedGtAccuracyM'),
      _nullableNonNegativeFiniteDouble(snapshot, 'meanReportedGtAccuracyM'),
      _nullableNonNegativeFiniteDouble(snapshot, 'medianReportedGtAccuracyM'),
    ];
    if (reportedAccuracy.any((double? value) => value == null) &&
        reportedAccuracy.any((double? value) => value != null)) {
      throw const FormatException('Reported GT accuracy metadata is incomplete.');
    }
    if (reportedAccuracy.first != null) {
      final double min = reportedAccuracy[0]!;
      final double max = reportedAccuracy[1]!;
      final double mean = reportedAccuracy[2]!;
      final double median = reportedAccuracy[3]!;
      if (min > median || median > max || min > mean || mean > max) {
        throw const FormatException('Reported GT accuracy ordering is invalid.');
      }
    }

    final double finalEast = _requiredFiniteDouble(
      snapshot,
      'finalDeniedEastM',
    );
    final double finalNorth = _requiredFiniteDouble(
      snapshot,
      'finalDeniedNorthM',
    );
    final double finalHorizontal = _requiredNonNegativeFiniteDouble(
      snapshot,
      'finalDeniedHorizontalDisplacementM',
    );
    final double expectedHorizontal = math.sqrt(
      (finalEast * finalEast) + (finalNorth * finalNorth),
    );
    if (!_nearlyEqual(finalHorizontal, expectedHorizontal)) {
      throw const FormatException('Final denied-state norm is inconsistent.');
    }
    final double nominalPath = _requiredNonNegativeFiniteDouble(
      snapshot,
      'nominalDeniedIntegratedPathLengthM',
    );
    if (!_nearlyEqual(
      nominalPath,
      counters['integratedStepCount']! * evaluationConfigAStepLengthM,
    )) {
      throw const FormatException('Nominal denied path length is inconsistent.');
    }

    final Map<String, Object?> sanitized = <String, Object?>{
      for (final String key in _resultSanitizedKeys) key: snapshot[key],
    };
    return EvaluationModeDiagnosticResult._(
      protectedGtUpdateCount: counters['protectedGtUpdateCount']!,
      acceptedProtectedGtFixCount: counters['acceptedProtectedGtFixCount']!,
      matchedGroundTruthFixCount: counters['matchedGroundTruthFixCount']!,
      integratedStepCount: counters['integratedStepCount']!,
      finalDeniedEastM: finalEast,
      finalDeniedNorthM: finalNorth,
      medianHorizontalErrorM: errors['medianHorizontalErrorM']!,
      p95HorizontalErrorM: errors['p95HorizontalErrorM']!,
      finalDeniedPreCorrectionErrorM:
          errors['finalDeniedPreCorrectionErrorM']!,
      medianEstimatorAgeAtGtMs: ages['medianEstimatorAgeAtGtMs']!,
      sanitizedMetadata: Map<String, Object?>.unmodifiable(sanitized),
    );
  }

  final int protectedGtUpdateCount;
  final int acceptedProtectedGtFixCount;
  final int matchedGroundTruthFixCount;
  final int integratedStepCount;
  final double finalDeniedEastM;
  final double finalDeniedNorthM;
  final double medianHorizontalErrorM;
  final double p95HorizontalErrorM;
  final double finalDeniedPreCorrectionErrorM;
  final double medianEstimatorAgeAtGtMs;
  final Map<String, Object?> sanitizedMetadata;
}

void _validateFixedResultContract(Map<Object?, Object?> snapshot) {
  _requireExactInt(snapshot, 'schemaVersion', evaluationModeSchemaVersion);
  _requireExactString(
    snapshot,
    'snapshotKind',
    'evaluation_mode_diagnostic_result',
  );
  _requireTrue(snapshot, 'success');
  _requireExactInt(snapshot, 'evaluationWindowMs', evaluationModeWindowMs);
  _requireExactInt(
    snapshot,
    'protectedGtFirstFixTimeoutMs',
    evaluationProtectedGtFirstFixTimeoutMs,
  );
  _requireExactString(snapshot, 'coordinateFrame', evaluationCoordinateFrame);
  _requireTrue(snapshot, 'physicalGnssAvailable');
  _requireExactString(snapshot, 'physicalGnssRole', evaluationPhysicalGnssRole);
  for (final String key in _requiredTrueResultFlags) {
    _requireTrue(snapshot, key);
  }
  for (final String key in _requiredFalseResultFlags) {
    _requireFalse(snapshot, key);
  }
  _requireExactString(
    snapshot,
    'deniedEstimatorProfile',
    evaluationDeniedEstimatorProfile,
  );
  _requireExactString(snapshot, 'stepSource', evaluationStepSource);
  _requireExactString(snapshot, 'headingSource', evaluationHeadingSource);
  _requireExactString(
    snapshot,
    'headingConvention',
    evaluationHeadingConvention,
  );
  _requireExactString(
    snapshot,
    'deviceForwardAxis',
    evaluationDeviceForwardAxis,
  );
  _requireExactString(snapshot, 'stepLengthModel', evaluationStepLengthModel);
  final double stepLength = _requiredFiniteDouble(snapshot, 'stepLengthM');
  if (!_nearlyEqual(stepLength, evaluationConfigAStepLengthM)) {
    throw const FormatException('Config A step length is invalid.');
  }
  _requireExactString(
    snapshot,
    'headingAssociationPolicy',
    evaluationHeadingAssociationPolicy,
  );
  _requireExactString(
    snapshot,
    'stepTimestampAuthority',
    evaluationSensorTimestampAuthority,
  );
  _requireExactString(
    snapshot,
    'headingTimestampAuthority',
    evaluationSensorTimestampAuthority,
  );
  _requireExactString(
    snapshot,
    'protectedGroundTruthTimestampAuthority',
    evaluationProtectedGtTimestampAuthority,
  );
  _requireExactString(
    snapshot,
    'operationWindowClock',
    evaluationOperationWindowClock,
  );
}

void _validateCounters(Map<String, int> value) {
  if (value['protectedGtUpdateCount'] !=
          value['acceptedProtectedGtFixCount']! +
              value['invalidProtectedGtFixCount']! +
              value['outOfWindowProtectedGtFixCount']! +
              value['duplicateProtectedGtTimestampCount']! +
              value['nonMonotonicProtectedGtTimestampCount']! ||
      value['uniqueProtectedGtTimestampCount'] !=
          value['acceptedProtectedGtFixCount'] ||
      value['mockProtectedGtFixCount']! >
          value['invalidProtectedGtFixCount']! ||
      value['matchedGroundTruthFixCount']! <= 0 ||
      value['matchedGroundTruthFixCount']! +
              value['unmatchedGroundTruthFixCount']! >
          value['acceptedProtectedGtFixCount']!) {
    throw const FormatException('Protected GT counters are inconsistent.');
  }
  if (value['stepUpdateCount'] !=
          value['acceptedStepEventCount']! +
              value['invalidStepEventCount']! +
              value['outOfWindowStepEventCount']! +
              value['duplicateStepTimestampCount']! +
              value['nonMonotonicStepTimestampCount']! ||
      value['uniqueStepTimestampCount'] != value['acceptedStepEventCount'] ||
      value['acceptedStepEventCount'] !=
          value['associatedStepCount']! + value['unassociatedStepCount']! ||
      value['integratedStepCount'] != value['associatedStepCount']) {
    throw const FormatException('Denied step counters are inconsistent.');
  }
  if (value['headingUpdateCount'] !=
          value['validHeadingSampleCount']! +
              value['invalidHeadingSampleCount']! +
              value['duplicateHeadingTimestampCount']! +
              value['nonMonotonicHeadingTimestampCount']! ||
      value['uniqueHeadingTimestampCount'] !=
          value['validHeadingSampleCount']) {
    throw const FormatException('Denied heading counters are inconsistent.');
  }
}

void _validateOrderedStatistics(Map<String, double> values, String suffix) {
  final double min = values['min$suffix']!;
  final double max = values['max$suffix']!;
  final double mean = values['mean$suffix']!;
  final double median = values['median$suffix']!;
  final double p95 = values['p95$suffix']!;
  if (min > median || median > max || min > mean || mean > max || min > p95 || p95 > max) {
    throw FormatException('$suffix statistics ordering is invalid.');
  }
}

void _validateEstimatorStates(List<DeniedEstimatorSnapshot> states) {
  int previousTimestamp = -1;
  int previousCount = -1;
  for (final DeniedEstimatorSnapshot state in states) {
    if (state.timestampNanos <= 0 ||
        state.timestampNanos < previousTimestamp ||
        !state.eastM.isFinite ||
        !state.northM.isFinite ||
        state.integratedStepCount < 0 ||
        state.integratedStepCount < previousCount) {
      throw const FormatException('Estimator snapshot sequence is invalid.');
    }
    previousTimestamp = state.timestampNanos;
    previousCount = state.integratedStepCount;
  }
}

void _validateGroundTruthReferences(
  List<ProtectedEvaluationReference> references,
) {
  int previousTimestamp = -1;
  for (final ProtectedEvaluationReference value in references) {
    if (value.timestampNanos <= 0 ||
        value.timestampNanos < previousTimestamp ||
        !value.eastM.isFinite ||
        !value.northM.isFinite) {
      throw const FormatException('Protected evaluation reference is invalid.');
    }
    previousTimestamp = value.timestampNanos;
  }
}

bool _listsEqual<T>(List<T> first, List<T> second) {
  if (first.length != second.length) {
    return false;
  }
  for (int index = 0; index < first.length; index += 1) {
    if (first[index] != second[index]) {
      return false;
    }
  }
  return true;
}

Map<Object?, Object?> _requiredMap(Object? value) {
  if (value is! Map) {
    throw const FormatException('Evaluation Mode platform response must be a map.');
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

double _requiredNonNegativeFiniteDouble(
  Map<Object?, Object?> snapshot,
  String key,
) {
  final double value = _requiredFiniteDouble(snapshot, key);
  if (value < 0.0) {
    throw FormatException('$key must be nonnegative.');
  }
  return value;
}

double? _nullableNonNegativeFiniteDouble(
  Map<Object?, Object?> snapshot,
  String key,
) {
  if (snapshot[key] == null) {
    return null;
  }
  return _requiredNonNegativeFiniteDouble(snapshot, key);
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
  return (first - second).abs() <= evaluationNumericalTolerance;
}

const List<String> _requiredTrueResultFlags = <String>[
  'evaluationModeImplemented',
  'groundTruthFirewallImplemented',
  'protectedGroundTruthGnssActive',
  'softwareDefinedEstimatorGnssDenial',
  'firewallMutationSelfTestPassed',
  'liveGnssPhysicallyActive',
  'liveGnssUsedForProtectedGroundTruth',
  'elapsedRealtimeSharedTimeBaseUsed',
  'gnssSensorElapsedRealtimeComparisonUsed',
];

const List<String> _requiredFalseResultFlags = <String>[
  'protectedGnssAvailableToEstimatorApi',
  'protectedGnssUsedByDeniedEstimator',
  'protectedGnssUsedByHeading',
  'protectedGnssUsedByStepLength',
  'protectedGnssUsedByQualityEngine',
  'protectedGnssUsedByController',
  'gnssCorrectionApplied',
  'liveGnssUsedByDeniedEstimator',
  'unsupportedCrossClockComparisonUsed',
  'stepLengthCalibrated',
  'stepLengthValidated',
  'futureHeadingUsed',
  'baselinePdrAccuracyValidated',
  'stepDetectionAccuracyValidated',
  'headingAccuracyValidated',
  'trueNorthAccuracyValidated',
  'protectedGnssGroundTruthAccuracyValidated',
  'qualityEngineImplemented',
  'ekfImplemented',
  'pdrArcoreFusionImplemented',
  'gnssRecoveryImplemented',
  'fullGnssDeniedNavigationImplemented',
  'rawGroundTruthTrajectoryReturned',
  'rawDeniedTrajectoryReturned',
  'rawGnssCoordinatesReturned',
  'rawTimestampsReturned',
  'persistenceUsed',
];

const List<String> _counterKeys = <String>[
  'protectedGtUpdateCount',
  'acceptedProtectedGtFixCount',
  'invalidProtectedGtFixCount',
  'outOfWindowProtectedGtFixCount',
  'uniqueProtectedGtTimestampCount',
  'duplicateProtectedGtTimestampCount',
  'nonMonotonicProtectedGtTimestampCount',
  'mockProtectedGtFixCount',
  'matchedGroundTruthFixCount',
  'unmatchedGroundTruthFixCount',
  'stepUpdateCount',
  'acceptedStepEventCount',
  'invalidStepEventCount',
  'outOfWindowStepEventCount',
  'uniqueStepTimestampCount',
  'duplicateStepTimestampCount',
  'nonMonotonicStepTimestampCount',
  'associatedStepCount',
  'unassociatedStepCount',
  'integratedStepCount',
  'headingUpdateCount',
  'validHeadingSampleCount',
  'invalidHeadingSampleCount',
  'uniqueHeadingTimestampCount',
  'duplicateHeadingTimestampCount',
  'nonMonotonicHeadingTimestampCount',
];

const List<String> _errorMetricKeys = <String>[
  'minHorizontalErrorM',
  'maxHorizontalErrorM',
  'meanHorizontalErrorM',
  'medianHorizontalErrorM',
  'p95HorizontalErrorM',
  'finalDeniedPreCorrectionErrorM',
];

const List<String> _ageMetricKeys = <String>[
  'minEstimatorAgeAtGtMs',
  'maxEstimatorAgeAtGtMs',
  'meanEstimatorAgeAtGtMs',
  'medianEstimatorAgeAtGtMs',
  'p95EstimatorAgeAtGtMs',
];

const List<String> _resultSanitizedKeys = <String>[
  'schemaVersion',
  'snapshotKind',
  'success',
  'evaluationWindowMs',
  'protectedGtFirstFixTimeoutMs',
  'coordinateFrame',
  'physicalGnssAvailable',
  'physicalGnssRole',
  ..._requiredTrueResultFlags,
  ..._requiredFalseResultFlags,
  ..._counterKeys,
  'minReportedGtAccuracyM',
  'maxReportedGtAccuracyM',
  'meanReportedGtAccuracyM',
  'medianReportedGtAccuracyM',
  ..._errorMetricKeys,
  ..._ageMetricKeys,
  'finalDeniedEastM',
  'finalDeniedNorthM',
  'finalDeniedHorizontalDisplacementM',
  'nominalDeniedIntegratedPathLengthM',
  'deniedEstimatorProfile',
  'stepSource',
  'headingSource',
  'headingConvention',
  'deviceForwardAxis',
  'stepLengthModel',
  'stepLengthM',
  'headingAssociationPolicy',
  'stepTimestampAuthority',
  'headingTimestampAuthority',
  'protectedGroundTruthTimestampAuthority',
  'operationWindowClock',
];
