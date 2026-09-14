import 'dart:math' as math;

import 'navguard_fusion.dart';

const int navguardBenchmarkDeniedWindowMs = 30000;
const double navguardBenchmarkTargetImprovementPercent = 20;
const String navguardBenchmarkPercentilePolicy = 'nearest_rank';

enum NavguardBenchmarkConfig {
  a('configA', 'config_a_deterministic_pdr'),
  b('configB', 'config_b_pdr_heading_ekf'),
  c('configC', 'config_c_arcore_relative'),
  d('configD', 'config_d_navguard_ekf_v1');

  const NavguardBenchmarkConfig(this.mapKey, this.identifier);

  final String mapKey;
  final String identifier;
}

enum NavguardBenchmarkPhase {
  idle('IDLE', 'Idle'),
  preparing('PREPARING', 'Preparing'),
  preDenial('PRE_DENIAL', 'Pre-denial'),
  benchmarkDenial('BENCHMARK_DENIAL', 'Benchmark Denial'),
  comparing('COMPARING', 'Comparing'),
  complete('COMPLETE', 'Complete'),
  cancelled('CANCELLED', 'Cancelled'),
  failed('FAILED', 'Failed');

  const NavguardBenchmarkPhase(this.wireValue, this.displayLabel);

  final String wireValue;
  final String displayLabel;

  static NavguardBenchmarkPhase parse(Object? raw) {
    for (final NavguardBenchmarkPhase phase in values) {
      if (raw == phase.wireValue) {
        return phase;
      }
    }
    throw const FormatException('Invalid benchmark phase.');
  }
}

double benchmarkHorizontalErrorM({
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
    throw const FormatException('Benchmark coordinates must be finite.');
  }
  final double east = estimatorEastM - groundTruthEastM;
  final double north = estimatorNorthM - groundTruthNorthM;
  return math.sqrt((east * east) + (north * north));
}

double benchmarkMedian(Iterable<double> values) {
  final List<double> sorted = _finiteValues(values)..sort();
  if (sorted.isEmpty) {
    throw const FormatException('Median requires at least one value.');
  }
  final int middle = sorted.length ~/ 2;
  return sorted.length.isOdd
      ? sorted[middle]
      : (sorted[middle - 1] + sorted[middle]) / 2;
}

double benchmarkPercentileNearestRank(
  Iterable<double> values,
  double percentile,
) {
  final List<double> sorted = _finiteValues(values)..sort();
  if (sorted.isEmpty ||
      !percentile.isFinite ||
      percentile <= 0 ||
      percentile > 100) {
    throw const FormatException('Invalid nearest-rank percentile input.');
  }
  final int rank = ((percentile / 100) * sorted.length).ceil();
  return sorted[rank.clamp(1, sorted.length) - 1];
}

double? benchmarkImprovementPercent({
  required double baselineMedianM,
  required double candidateMedianM,
}) {
  if (!baselineMedianM.isFinite ||
      !candidateMedianM.isFinite ||
      baselineMedianM < 0 ||
      candidateMedianM < 0) {
    throw const FormatException(
      'Benchmark medians must be finite and non-negative.',
    );
  }
  if (baselineMedianM.abs() <= 1e-12) {
    return null;
  }
  return 100 * (baselineMedianM - candidateMedianM) / baselineMedianM;
}

bool benchmarkTargetMet(
  double? improvementPercent, {
  double targetPercent = navguardBenchmarkTargetImprovementPercent,
}) {
  if (!targetPercent.isFinite) {
    throw const FormatException('Benchmark target must be finite.');
  }
  return improvementPercent != null &&
      improvementPercent.isFinite &&
      improvementPercent >= targetPercent;
}

List<double> _finiteValues(Iterable<double> values) {
  final List<double> result = List<double>.of(values);
  if (result.any((double value) => !value.isFinite)) {
    throw const FormatException('Benchmark metrics must be finite.');
  }
  return result;
}

class BenchmarkEstimatorSnapshot {
  const BenchmarkEstimatorSnapshot({
    required this.timestampNanos,
    required this.eastM,
    required this.northM,
  });

  final int timestampNanos;
  final double eastM;
  final double northM;
}

class BenchmarkGroundTruthPoint {
  const BenchmarkGroundTruthPoint({
    required this.timestampNanos,
    required this.eastM,
    required this.northM,
  });

  final int timestampNanos;
  final double eastM;
  final double northM;
}

class BenchmarkCausalMatchSummary {
  BenchmarkCausalMatchSummary({
    required List<double> horizontalErrorsM,
    required this.matchedCount,
    required this.unmatchedCount,
    required this.latestMatchedEstimatorTimestampNanos,
  }) : horizontalErrorsM = List<double>.unmodifiable(horizontalErrorsM);

  final List<double> horizontalErrorsM;
  final int matchedCount;
  final int unmatchedCount;
  final int? latestMatchedEstimatorTimestampNanos;
}

BenchmarkCausalMatchSummary matchBenchmarkStatesCausally({
  required Iterable<BenchmarkEstimatorSnapshot> states,
  required Iterable<BenchmarkGroundTruthPoint> groundTruth,
}) {
  final List<BenchmarkEstimatorSnapshot> orderedStates =
      List<BenchmarkEstimatorSnapshot>.of(states)..sort(
        (BenchmarkEstimatorSnapshot left, BenchmarkEstimatorSnapshot right) =>
            left.timestampNanos.compareTo(right.timestampNanos),
      );
  final List<BenchmarkGroundTruthPoint> orderedGroundTruth =
      List<BenchmarkGroundTruthPoint>.of(groundTruth)..sort(
        (BenchmarkGroundTruthPoint left, BenchmarkGroundTruthPoint right) =>
            left.timestampNanos.compareTo(right.timestampNanos),
      );
  if (orderedStates.any(
        (BenchmarkEstimatorSnapshot value) =>
            value.timestampNanos <= 0 ||
            !value.eastM.isFinite ||
            !value.northM.isFinite,
      ) ||
      orderedGroundTruth.any(
        (BenchmarkGroundTruthPoint value) =>
            value.timestampNanos <= 0 ||
            !value.eastM.isFinite ||
            !value.northM.isFinite,
      )) {
    throw const FormatException('Invalid causal benchmark sample.');
  }

  final List<double> errors = <double>[];
  var unmatched = 0;
  var stateIndex = 0;
  BenchmarkEstimatorSnapshot? latest;
  int? latestMatchedTimestamp;
  for (final BenchmarkGroundTruthPoint gt in orderedGroundTruth) {
    while (stateIndex < orderedStates.length &&
        orderedStates[stateIndex].timestampNanos <= gt.timestampNanos) {
      latest = orderedStates[stateIndex];
      stateIndex += 1;
    }
    if (latest == null) {
      unmatched += 1;
      continue;
    }
    latestMatchedTimestamp = latest.timestampNanos;
    errors.add(
      benchmarkHorizontalErrorM(
        estimatorEastM: latest.eastM,
        estimatorNorthM: latest.northM,
        groundTruthEastM: gt.eastM,
        groundTruthNorthM: gt.northM,
      ),
    );
  }
  return BenchmarkCausalMatchSummary(
    horizontalErrorsM: errors,
    matchedCount: errors.length,
    unmatchedCount: unmatched,
    latestMatchedEstimatorTimestampNanos: latestMatchedTimestamp,
  );
}

class BenchmarkHeadingSample {
  const BenchmarkHeadingSample({
    required this.timestampNanos,
    required this.headingRad,
  });

  final int timestampNanos;
  final double headingRad;
}

class BenchmarkConfigAReplayResult {
  const BenchmarkConfigAReplayResult({
    required this.finalEastM,
    required this.finalNorthM,
    required this.stepOpportunities,
    required this.stepsApplied,
    required this.stepsSkippedNoHeading,
  });

  final double finalEastM;
  final double finalNorthM;
  final int stepOpportunities;
  final int stepsApplied;
  final int stepsSkippedNoHeading;

  bool get counterInvariantHolds =>
      stepsApplied + stepsSkippedNoHeading == stepOpportunities;
}

BenchmarkConfigAReplayResult replayBenchmarkConfigA({
  required double initialEastM,
  required double initialNorthM,
  required Iterable<BenchmarkHeadingSample> headings,
  required Iterable<int> stepTimestampsNanos,
}) {
  if (!initialEastM.isFinite || !initialNorthM.isFinite) {
    throw const FormatException('Config A origin must be finite.');
  }
  final List<BenchmarkHeadingSample> orderedHeadings =
      List<BenchmarkHeadingSample>.of(headings)..sort(
        (BenchmarkHeadingSample left, BenchmarkHeadingSample right) =>
            left.timestampNanos.compareTo(right.timestampNanos),
      );
  final List<int> orderedSteps = List<int>.of(stepTimestampsNanos)..sort();
  if (orderedHeadings.any(
        (BenchmarkHeadingSample value) =>
            value.timestampNanos <= 0 || !value.headingRad.isFinite,
      ) ||
      orderedSteps.any((int value) => value <= 0)) {
    throw const FormatException('Invalid Config A replay event.');
  }

  var east = initialEastM;
  var north = initialNorthM;
  var headingIndex = 0;
  BenchmarkHeadingSample? latestHeading;
  var applied = 0;
  var skipped = 0;
  for (final int stepTimestamp in orderedSteps) {
    while (headingIndex < orderedHeadings.length &&
        orderedHeadings[headingIndex].timestampNanos <= stepTimestamp) {
      latestHeading = orderedHeadings[headingIndex];
      headingIndex += 1;
    }
    if (latestHeading == null) {
      skipped += 1;
      continue;
    }
    east += navguardStepLengthM * math.sin(latestHeading.headingRad);
    north += navguardStepLengthM * math.cos(latestHeading.headingRad);
    applied += 1;
  }
  return BenchmarkConfigAReplayResult(
    finalEastM: east,
    finalNorthM: north,
    stepOpportunities: orderedSteps.length,
    stepsApplied: applied,
    stepsSkippedNoHeading: skipped,
  );
}

BenchmarkEstimatorSnapshot benchmarkConfigCPosition({
  required int timestampNanos,
  required double denialOriginEastM,
  required double denialOriginNorthM,
  required double relativeEastM,
  required double relativeNorthM,
}) {
  return BenchmarkEstimatorSnapshot(
    timestampNanos: timestampNanos,
    eastM: denialOriginEastM + relativeEastM,
    northM: denialOriginNorthM + relativeNorthM,
  );
}

class NavguardBenchmarkPreflight {
  const NavguardBenchmarkPreflight({
    required this.gpsProviderAvailable,
    required this.gpsProviderEnabled,
    required this.fineLocationPermissionGranted,
    required this.rotationVectorAvailable,
    required this.stepDetectorAvailable,
    required this.activityRecognitionPermissionGranted,
    required this.arCoreSupported,
    required this.arCoreInstalled,
    required this.cameraPermissionGranted,
    required this.diagnosticRunning,
    required this.nativeReady,
    required this.currentPhase,
  });

  factory NavguardBenchmarkPreflight.fromPlatform(Object? raw) {
    final Map<Object?, Object?> map = _strictMap(raw);
    _expectInt(map, 'schemaVersion', 1);
    _expectString(map, 'snapshotKind', 'navguard_benchmark_preflight');
    final NavguardBenchmarkPreflight result = NavguardBenchmarkPreflight(
      gpsProviderAvailable: _bool(map, 'gpsProviderAvailable'),
      gpsProviderEnabled: _bool(map, 'gpsProviderEnabled'),
      fineLocationPermissionGranted: _bool(
        map,
        'fineLocationPermissionGranted',
      ),
      rotationVectorAvailable: _bool(map, 'rotationVectorAvailable'),
      stepDetectorAvailable: _bool(map, 'stepDetectorAvailable'),
      activityRecognitionPermissionGranted: _bool(
        map,
        'activityRecognitionPermissionGranted',
      ),
      arCoreSupported: _bool(map, 'arCoreSupported'),
      arCoreInstalled: _bool(map, 'arCoreInstalled'),
      cameraPermissionGranted: _bool(map, 'cameraPermissionGranted'),
      diagnosticRunning: _bool(map, 'diagnosticRunning'),
      nativeReady: _bool(map, 'nativeReady'),
      currentPhase: NavguardBenchmarkPhase.parse(map['currentPhase']),
    );
    final bool expectedReady =
        result.gpsProviderAvailable &&
        result.gpsProviderEnabled &&
        result.fineLocationPermissionGranted &&
        result.rotationVectorAvailable &&
        result.stepDetectorAvailable &&
        result.activityRecognitionPermissionGranted &&
        result.arCoreSupported &&
        result.arCoreInstalled &&
        result.cameraPermissionGranted &&
        !result.diagnosticRunning;
    if (result.nativeReady != expectedReady) {
      throw const FormatException('Inconsistent benchmark preflight.');
    }
    if (!result.diagnosticRunning &&
        result.currentPhase != NavguardBenchmarkPhase.idle) {
      throw const FormatException('Inconsistent idle benchmark preflight.');
    }
    return result;
  }

  final bool gpsProviderAvailable;
  final bool gpsProviderEnabled;
  final bool fineLocationPermissionGranted;
  final bool rotationVectorAvailable;
  final bool stepDetectorAvailable;
  final bool activityRecognitionPermissionGranted;
  final bool arCoreSupported;
  final bool arCoreInstalled;
  final bool cameraPermissionGranted;
  final bool diagnosticRunning;
  final bool nativeReady;
  final NavguardBenchmarkPhase currentPhase;
}

class NavguardBenchmarkConfigMetrics {
  const NavguardBenchmarkConfigMetrics({
    required this.config,
    required this.matchedGtCount,
    required this.unmatchedGtCount,
    required this.meanHorizontalErrorM,
    required this.medianHorizontalErrorM,
    required this.p95HorizontalErrorM,
    required this.maxHorizontalErrorM,
    required this.finalPreCorrectionHorizontalErrorM,
    required this.finalEastM,
    required this.finalNorthM,
  });

  factory NavguardBenchmarkConfigMetrics.fromPlatform(
    Object? raw,
    NavguardBenchmarkConfig config,
  ) {
    final Map<Object?, Object?> map = _strictMap(raw);
    _expectString(map, 'configId', config.identifier);
    final int matched = _nonNegativeInt(map, 'matchedGtCount');
    if (matched < 1) {
      throw const FormatException('A valid benchmark config needs a GT match.');
    }
    return NavguardBenchmarkConfigMetrics(
      config: config,
      matchedGtCount: matched,
      unmatchedGtCount: _nonNegativeInt(map, 'unmatchedGtCount'),
      meanHorizontalErrorM: _finiteNonNegativeDouble(
        map,
        'meanHorizontalErrorM',
      ),
      medianHorizontalErrorM: _finiteNonNegativeDouble(
        map,
        'medianHorizontalErrorM',
      ),
      p95HorizontalErrorM: _finiteNonNegativeDouble(map, 'p95HorizontalErrorM'),
      maxHorizontalErrorM: _finiteNonNegativeDouble(map, 'maxHorizontalErrorM'),
      finalPreCorrectionHorizontalErrorM: _finiteNonNegativeDouble(
        map,
        'finalPreCorrectionHorizontalErrorM',
      ),
      finalEastM: _finiteDouble(map, 'finalEastM'),
      finalNorthM: _finiteDouble(map, 'finalNorthM'),
    );
  }

  final NavguardBenchmarkConfig config;
  final int matchedGtCount;
  final int unmatchedGtCount;
  final double meanHorizontalErrorM;
  final double medianHorizontalErrorM;
  final double p95HorizontalErrorM;
  final double maxHorizontalErrorM;
  final double finalPreCorrectionHorizontalErrorM;
  final double finalEastM;
  final double finalNorthM;
}

class NavguardBenchmarkDiagnosticResult {
  NavguardBenchmarkDiagnosticResult({
    required Map<NavguardBenchmarkConfig, NavguardBenchmarkConfigMetrics>
    configMetrics,
    required this.dVsAMedianImprovementPercent,
    required this.dVsATargetMet,
    required this.protectedGtReportedAccuracyMedianM,
    required this.sanitizedMetadata,
  }) : configMetrics =
           Map<
             NavguardBenchmarkConfig,
             NavguardBenchmarkConfigMetrics
           >.unmodifiable(configMetrics);

  factory NavguardBenchmarkDiagnosticResult.fromPlatform(Object? raw) {
    final Map<Object?, Object?> map = _strictMap(raw);
    _expectInt(map, 'schemaVersion', 1);
    _expectString(map, 'snapshotKind', 'navguard_benchmark_diagnostic_result');
    _expectBool(map, 'success', true);
    _expectBool(map, 'benchmarkSessionValid', true);
    _expectInt(map, 'benchmarkDeniedWindowMs', navguardBenchmarkDeniedWindowMs);
    _expectString(
      map,
      'primaryMetric',
      'matched_session_median_horizontal_error_m',
    );
    _expectString(map, 'primaryComparison', 'config_d_vs_config_a');
    _expectString(map, 'percentilePolicy', navguardBenchmarkPercentilePolicy);

    for (final String key in <String>[
      'matchedSessionBenchmarkImplemented',
      'configAImplemented',
      'configBImplemented',
      'configCImplemented',
      'configDImplemented',
      'protectedGroundTruthCollectorImplemented',
      'benchmarkComparatorImplemented',
      'benchmarkGroundTruthMutationInvariancePassed',
      'benchmarkGroundTruthRemovalInvariancePassed',
      'captureOnceReplayManyUsed',
      'identicalDenialOriginUsed',
      'initialDenialSnapshotUsed',
      'causalGroundTruthMatchingUsed',
      'josephCovarianceUpdateUsed',
      'circularHeadingInnovationUsed',
    ]) {
      _expectBool(map, key, true);
    }
    for (final String key in <String>[
      'protectedGroundTruthAvailableToEstimators',
      'protectedGroundTruthUsedByConfigA',
      'protectedGroundTruthUsedByConfigB',
      'protectedGroundTruthUsedByConfigC',
      'protectedGroundTruthUsedByConfigD',
      'protectedGroundTruthUsedByQualityEngine',
      'groundTruthCorrectionApplied',
      'gnssRecoveryAppliedDuringBenchmark',
      'futureEstimatorStateUsedForGroundTruthMatch',
      'groundTruthInterpolationUsed',
      'arcoreFrameTimestampUsedForFusionOrdering',
      'benchmarkAccuracyValidated',
      'protectedGroundTruthAccuracyValidated',
      'stepDetectionAccuracyValidated',
      'stepLengthValidated',
      'headingAccuracyValidated',
      'arcorePositionAccuracyValidated',
      'noiseParametersValidated',
      'qualityThresholdsValidated',
      'rawGnssCoordinatesReturned',
      'rawProtectedGroundTruthReturned',
      'rawSensorSamplesReturned',
      'rawArcorePosesReturned',
      'rawTrajectoryReturned',
      'rawTimestampsReturned',
      'cameraImagesReturned',
      'persistenceUsed',
    ]) {
      _expectBool(map, key, false);
    }

    final Map<NavguardBenchmarkConfig, NavguardBenchmarkConfigMetrics> metrics =
        <NavguardBenchmarkConfig, NavguardBenchmarkConfigMetrics>{
          for (final NavguardBenchmarkConfig config
              in NavguardBenchmarkConfig.values)
            config: NavguardBenchmarkConfigMetrics.fromPlatform(
              map[config.mapKey],
              config,
            ),
        };
    final int protectedGtCount = _positiveInt(
      map,
      'protectedGroundTruthAcceptedFixCount',
    );
    for (final NavguardBenchmarkConfigMetrics value in metrics.values) {
      if (value.matchedGtCount + value.unmatchedGtCount != protectedGtCount) {
        throw const FormatException('Inconsistent benchmark match counts.');
      }
    }

    final double? dVsA = _nullableFiniteDouble(
      map,
      'dVsAMedianImprovementPercent',
    );
    final double aMedian =
        metrics[NavguardBenchmarkConfig.a]!.medianHorizontalErrorM;
    final double dMedian =
        metrics[NavguardBenchmarkConfig.d]!.medianHorizontalErrorM;
    final double? expectedImprovement = benchmarkImprovementPercent(
      baselineMedianM: aMedian,
      candidateMedianM: dMedian,
    );
    if ((dVsA == null) != (expectedImprovement == null) ||
        (dVsA != null && (dVsA - expectedImprovement!).abs() > 1e-9)) {
      throw const FormatException('Inconsistent D-vs-A improvement.');
    }
    _nullableFiniteDouble(map, 'bVsAMedianImprovementPercent');
    _nullableFiniteDouble(map, 'cVsAMedianImprovementPercent');
    _nullableFiniteDouble(map, 'dVsBMedianImprovementPercent');
    _nullableFiniteDouble(map, 'dVsCMedianImprovementPercent');
    _expectDouble(
      map,
      'targetImprovementPercent',
      navguardBenchmarkTargetImprovementPercent,
    );
    final bool targetMet = _bool(map, 'dVsATargetMet');
    if (targetMet != benchmarkTargetMet(dVsA)) {
      throw const FormatException('Inconsistent benchmark target flag.');
    }

    for (final String key in <String>[
      'protectedGtReportedAccuracyMinM',
      'protectedGtReportedAccuracyMeanM',
      'protectedGtReportedAccuracyMedianM',
      'protectedGtReportedAccuracyMaxM',
    ]) {
      _finiteNonNegativeDouble(map, key);
    }
    final int configAStepOpportunities = _nonNegativeInt(
      map,
      'configAStepOpportunities',
    );
    final int configAStepsApplied = _nonNegativeInt(map, 'configAStepsApplied');
    final int configAStepsSkippedNoHeading = _nonNegativeInt(
      map,
      'configAStepsSkippedNoHeading',
    );
    if (configAStepsApplied + configAStepsSkippedNoHeading !=
        configAStepOpportunities) {
      throw const FormatException('Inconsistent Config A counters.');
    }
    for (final String key in <String>[
      'configBStepPredictionsApplied',
      'configBHeadingMeasurementsApplied',
      'configBHeadingMeasurementsSkipped',
      'configCArcoreMeasurementsApplied',
      'configCArcoreMeasurementsSkipped',
      'configDStepPredictionsApplied',
      'configDHeadingMeasurementsApplied',
      'configDArcoreMeasurementsApplied',
      'configDStepPredictionsSkippedByQuality',
      'configDHeadingMeasurementsSkippedByQuality',
      'configDArcoreMeasurementsSkippedByQuality',
    ]) {
      _nonNegativeInt(map, key);
    }
    final Map<String, Object?> sanitized = <String, Object?>{
      for (final MapEntry<Object?, Object?> entry in map.entries)
        if (entry.key is String && !_sensitiveBenchmarkKeys.contains(entry.key))
          entry.key! as String: entry.value,
    };
    return NavguardBenchmarkDiagnosticResult(
      configMetrics: metrics,
      dVsAMedianImprovementPercent: dVsA,
      dVsATargetMet: targetMet,
      protectedGtReportedAccuracyMedianM: _finiteNonNegativeDouble(
        map,
        'protectedGtReportedAccuracyMedianM',
      ),
      sanitizedMetadata: Map<String, Object?>.unmodifiable(sanitized),
    );
  }

  final Map<NavguardBenchmarkConfig, NavguardBenchmarkConfigMetrics>
  configMetrics;
  final double? dVsAMedianImprovementPercent;
  final bool dVsATargetMet;
  final double protectedGtReportedAccuracyMedianM;
  final Map<String, Object?> sanitizedMetadata;
}

Map<Object?, Object?> _strictMap(Object? raw) {
  if (raw is! Map<Object?, Object?>) {
    throw const FormatException('Expected a platform map.');
  }
  return raw;
}

bool _bool(Map<Object?, Object?> map, String key) {
  final Object? value = map[key];
  if (value is! bool) {
    throw const FormatException('Expected a boolean benchmark field.');
  }
  return value;
}

void _expectBool(Map<Object?, Object?> map, String key, bool expected) {
  if (_bool(map, key) != expected) {
    throw const FormatException('Unexpected boolean benchmark field.');
  }
}

void _expectInt(Map<Object?, Object?> map, String key, int expected) {
  final Object? value = map[key];
  if (value is! int || value != expected) {
    throw const FormatException('Unexpected integer benchmark field.');
  }
}

int _nonNegativeInt(Map<Object?, Object?> map, String key) {
  final Object? value = map[key];
  if (value is! int || value < 0) {
    throw const FormatException('Expected a non-negative benchmark count.');
  }
  return value;
}

int _positiveInt(Map<Object?, Object?> map, String key) {
  final int value = _nonNegativeInt(map, key);
  if (value < 1) {
    throw const FormatException('Expected a positive benchmark count.');
  }
  return value;
}

void _expectString(Map<Object?, Object?> map, String key, String expected) {
  if (map[key] != expected) {
    throw const FormatException('Unexpected benchmark string field.');
  }
}

double _finiteDouble(Map<Object?, Object?> map, String key) {
  final Object? value = map[key];
  if (value is! num || !value.toDouble().isFinite) {
    throw const FormatException('Expected a finite benchmark number.');
  }
  return value.toDouble();
}

double _finiteNonNegativeDouble(Map<Object?, Object?> map, String key) {
  final double value = _finiteDouble(map, key);
  if (value < 0) {
    throw const FormatException('Expected a non-negative benchmark number.');
  }
  return value;
}

double? _nullableFiniteDouble(Map<Object?, Object?> map, String key) {
  final Object? value = map[key];
  if (value == null) {
    return null;
  }
  if (value is! num || !value.toDouble().isFinite) {
    throw const FormatException('Expected a nullable finite benchmark number.');
  }
  return value.toDouble();
}

void _expectDouble(Map<Object?, Object?> map, String key, double expected) {
  if ((_finiteDouble(map, key) - expected).abs() > 1e-12) {
    throw const FormatException('Unexpected numeric benchmark field.');
  }
}

const Set<String> _sensitiveBenchmarkKeys = <String>{
  'latitude',
  'longitude',
  'rawProtectedGroundTruth',
  'rawGnssFixes',
  'rawSensorSamples',
  'rawArcorePoses',
  'rawTrajectory',
  'rawTimestamps',
  'denialStartElapsedRealtimeNanos',
};
