import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:navguard/navigation/navguard_benchmark.dart';
import 'package:navguard/navigation/navguard_fusion.dart';

void main() {
  group('benchmark metric helpers', () {
    test('horizontal error uses the two-dimensional Euclidean norm', () {
      expect(
        benchmarkHorizontalErrorM(
          estimatorEastM: 3,
          estimatorNorthM: 4,
          groundTruthEastM: 0,
          groundTruthNorthM: 0,
        ),
        5,
      );
    });

    test('median supports odd and even sample counts', () {
      expect(benchmarkMedian(<double>[1, 2, 3]), 2);
      expect(benchmarkMedian(<double>[1, 2, 3, 4]), 2.5);
    });

    test('p95 uses the frozen nearest-rank policy', () {
      expect(
        benchmarkPercentileNearestRank(
          List<double>.generate(20, (int index) => index + 1),
          95,
        ),
        19,
      );
    });

    test('D versus A improvement and target are computed', () {
      final double? improvement = benchmarkImprovementPercent(
        baselineMedianM: 10,
        candidateMedianM: 7,
      );
      expect(improvement, closeTo(30, 1e-12));
      expect(benchmarkTargetMet(improvement), isTrue);
    });

    test('negative improvement is preserved', () {
      expect(
        benchmarkImprovementPercent(baselineMedianM: 10, candidateMedianM: 12),
        closeTo(-20, 1e-12),
      );
    });

    test('zero denominator produces null without infinity or NaN', () {
      expect(
        benchmarkImprovementPercent(baselineMedianM: 0, candidateMedianM: 1),
        isNull,
      );
      expect(benchmarkTargetMet(null), isFalse);
    });
  });

  group('causal comparator', () {
    test('GT at 150 matches state at 100 and never future state at 200', () {
      final BenchmarkCausalMatchSummary result = matchBenchmarkStatesCausally(
        states: const <BenchmarkEstimatorSnapshot>[
          BenchmarkEstimatorSnapshot(timestampNanos: 100, eastM: 1, northM: 0),
          BenchmarkEstimatorSnapshot(
            timestampNanos: 200,
            eastM: 100,
            northM: 0,
          ),
        ],
        groundTruth: const <BenchmarkGroundTruthPoint>[
          BenchmarkGroundTruthPoint(timestampNanos: 150, eastM: 0, northM: 0),
        ],
      );
      expect(result.matchedCount, 1);
      expect(result.unmatchedCount, 0);
      expect(result.latestMatchedEstimatorTimestampNanos, 100);
      expect(result.horizontalErrorsM.single, 1);
    });

    test('initial denial snapshot causally matches early GT', () {
      final BenchmarkCausalMatchSummary result = matchBenchmarkStatesCausally(
        states: const <BenchmarkEstimatorSnapshot>[
          BenchmarkEstimatorSnapshot(
            timestampNanos: 100,
            eastM: 10,
            northM: 20,
          ),
        ],
        groundTruth: const <BenchmarkGroundTruthPoint>[
          BenchmarkGroundTruthPoint(timestampNanos: 101, eastM: 13, northM: 24),
        ],
      );
      expect(result.horizontalErrorsM.single, 5);
    });

    test('match-count invariant includes unmatched GT', () {
      final BenchmarkCausalMatchSummary result = matchBenchmarkStatesCausally(
        states: const <BenchmarkEstimatorSnapshot>[
          BenchmarkEstimatorSnapshot(timestampNanos: 100, eastM: 0, northM: 0),
        ],
        groundTruth: const <BenchmarkGroundTruthPoint>[
          BenchmarkGroundTruthPoint(timestampNanos: 50, eastM: 0, northM: 0),
          BenchmarkGroundTruthPoint(timestampNanos: 150, eastM: 0, northM: 0),
        ],
      );
      expect(result.matchedCount + result.unmatchedCount, 2);
      expect(result.matchedCount, 1);
      expect(result.unmatchedCount, 1);
    });
  });

  group('frozen Config regressions', () {
    test('Config A applies north and east 0.75 m causal steps', () {
      final BenchmarkConfigAReplayResult result = replayBenchmarkConfigA(
        initialEastM: 0,
        initialNorthM: 0,
        headings: <BenchmarkHeadingSample>[
          const BenchmarkHeadingSample(timestampNanos: 100, headingRad: 0),
          BenchmarkHeadingSample(timestampNanos: 200, headingRad: math.pi / 2),
        ],
        stepTimestampsNanos: const <int>[150, 250],
      );
      expect(result.finalEastM, closeTo(0.75, 1e-12));
      expect(result.finalNorthM, closeTo(0.75, 1e-12));
      expect(result.stepsApplied, 2);
      expect(result.stepsSkippedNoHeading, 0);
      expect(result.counterInvariantHolds, isTrue);
    });

    test('Config A rejects a future-only heading', () {
      final BenchmarkConfigAReplayResult result = replayBenchmarkConfigA(
        initialEastM: 5,
        initialNorthM: 6,
        headings: const <BenchmarkHeadingSample>[
          BenchmarkHeadingSample(timestampNanos: 200, headingRad: 0),
        ],
        stepTimestampsNanos: const <int>[150],
      );
      expect(result.finalEastM, 5);
      expect(result.finalNorthM, 6);
      expect(result.stepsApplied, 0);
      expect(result.stepsSkippedNoHeading, 1);
      expect(result.counterInvariantHolds, isTrue);
    });

    test('Config B uses circular heading EKF and Joseph covariance only', () {
      final NavguardFusionEstimate initial = NavguardFusionEstimate.initial(
        (2 * math.pi) - 0.02,
      );
      final NavguardMeasurementUpdate heading = navguardHeadingUpdate(
        initial,
        measuredHeadingRad: 0.02,
        quality: NavguardQuality.good,
      );
      final NavguardFusionEstimate stepped = navguardStepPredict(
        heading.estimate,
        quality: NavguardQuality.usable,
      );
      expect(heading.innovation.single.abs(), lessThan(0.05));
      expect(stepped.covariance.isApproximatelySymmetric, isTrue);
      expect(
        stepped.covariance.values.every((double value) => value.isFinite),
        isTrue,
      );
    });

    test('Config C offsets ARCore relative motion by the denial origin', () {
      final BenchmarkEstimatorSnapshot state = benchmarkConfigCPosition(
        timestampNanos: 100,
        denialOriginEastM: 10,
        denialOriginNorthM: 20,
        relativeEastM: 3,
        relativeNorthM: 4,
      );
      expect(state.eastM, 13);
      expect(state.northM, 24);
    });

    test('Config D heading, step, and ARCore updates remain finite', () {
      NavguardFusionEstimate estimate = NavguardFusionEstimate.initial(0);
      estimate = navguardHeadingUpdate(
        estimate,
        measuredHeadingRad: 0.1,
        quality: NavguardQuality.good,
      ).estimate;
      estimate = navguardStepPredict(estimate, quality: NavguardQuality.usable);
      estimate = navguardArcorePositionUpdate(
        estimate,
        measuredEastM: 0.2,
        measuredNorthM: 0.8,
        quality: NavguardQuality.good,
      ).estimate;
      expect(estimate.eastM.isFinite, isTrue);
      expect(estimate.northM.isFinite, isTrue);
      expect(estimate.headingRad.isFinite, isTrue);
      expect(estimate.covariance.isApproximatelySymmetric, isTrue);
    });
  });

  group('ground-truth firewall invariants', () {
    List<BenchmarkEstimatorSnapshot> estimatorReplay() {
      final BenchmarkConfigAReplayResult result = replayBenchmarkConfigA(
        initialEastM: 10,
        initialNorthM: -4,
        headings: const <BenchmarkHeadingSample>[
          BenchmarkHeadingSample(timestampNanos: 100, headingRad: 0.2),
        ],
        stepTimestampsNanos: const <int>[150],
      );
      return <BenchmarkEstimatorSnapshot>[
        BenchmarkEstimatorSnapshot(
          timestampNanos: 150,
          eastM: result.finalEastM,
          northM: result.finalNorthM,
        ),
      ];
    }

    test('GT mutation changes comparator error but not estimator output', () {
      final List<BenchmarkEstimatorSnapshot> firstReplay = estimatorReplay();
      final List<BenchmarkEstimatorSnapshot> secondReplay = estimatorReplay();
      expect(firstReplay.single.eastM, secondReplay.single.eastM);
      expect(firstReplay.single.northM, secondReplay.single.northM);

      final double nearError = matchBenchmarkStatesCausally(
        states: firstReplay,
        groundTruth: const <BenchmarkGroundTruthPoint>[
          BenchmarkGroundTruthPoint(timestampNanos: 160, eastM: 10, northM: -3),
        ],
      ).horizontalErrorsM.single;
      final double mutatedError = matchBenchmarkStatesCausally(
        states: secondReplay,
        groundTruth: const <BenchmarkGroundTruthPoint>[
          BenchmarkGroundTruthPoint(
            timestampNanos: 160,
            eastM: 1010,
            northM: -1003,
          ),
        ],
      ).horizontalErrorsM.single;
      expect(mutatedError, isNot(nearError));
    });

    test('removing GT leaves estimator prediction unchanged', () {
      final BenchmarkEstimatorSnapshot withGt = estimatorReplay().single;
      final BenchmarkEstimatorSnapshot withoutGt = estimatorReplay().single;
      expect(withGt.eastM, withoutGt.eastM);
      expect(withGt.northM, withoutGt.northM);
      expect(
        matchBenchmarkStatesCausally(
          states: <BenchmarkEstimatorSnapshot>[withoutGt],
          groundTruth: const <BenchmarkGroundTruthPoint>[],
        ).matchedCount,
        0,
      );
    });
  });

  group('typed platform contracts', () {
    test('preflight parses a consistent typed map', () {
      final NavguardBenchmarkPreflight preflight =
          NavguardBenchmarkPreflight.fromPlatform(<String, Object?>{
            'schemaVersion': 1,
            'snapshotKind': 'navguard_benchmark_preflight',
            'gpsProviderAvailable': true,
            'gpsProviderEnabled': true,
            'fineLocationPermissionGranted': true,
            'rotationVectorAvailable': true,
            'stepDetectorAvailable': true,
            'activityRecognitionPermissionGranted': true,
            'arCoreSupported': true,
            'arCoreInstalled': true,
            'cameraPermissionGranted': true,
            'diagnosticRunning': false,
            'nativeReady': true,
            'currentPhase': 'IDLE',
          });
      expect(preflight.nativeReady, isTrue);
    });

    test('diagnostic result validates all config and firewall contracts', () {
      final NavguardBenchmarkDiagnosticResult result =
          NavguardBenchmarkDiagnosticResult.fromPlatform(_validResultMap());
      expect(result.configMetrics.length, 4);
      expect(result.dVsAMedianImprovementPercent, closeTo(30, 1e-12));
      expect(result.dVsATargetMet, isTrue);
      expect(result.protectedGtReportedAccuracyMedianM, 12);
    });

    test('malformed native result throws FormatException', () {
      final Map<String, Object?> invalid = _validResultMap();
      invalid['groundTruthCorrectionApplied'] = true;
      expect(
        () => NavguardBenchmarkDiagnosticResult.fromPlatform(invalid),
        throwsFormatException,
      );
    });
  });
}

Map<String, Object?> _validResultMap() {
  Map<String, Object?> metrics(String id, double median) => <String, Object?>{
    'configId': id,
    'matchedGtCount': 1,
    'unmatchedGtCount': 1,
    'meanHorizontalErrorM': median,
    'medianHorizontalErrorM': median,
    'p95HorizontalErrorM': median,
    'maxHorizontalErrorM': median,
    'finalPreCorrectionHorizontalErrorM': median,
    'finalEastM': 1,
    'finalNorthM': 2,
  };

  return <String, Object?>{
    'schemaVersion': 1,
    'snapshotKind': 'navguard_benchmark_diagnostic_result',
    'success': true,
    'benchmarkSessionValid': true,
    'benchmarkDeniedWindowMs': navguardBenchmarkDeniedWindowMs,
    'primaryMetric': 'matched_session_median_horizontal_error_m',
    'primaryComparison': 'config_d_vs_config_a',
    'percentilePolicy': navguardBenchmarkPercentilePolicy,
    'matchedSessionBenchmarkImplemented': true,
    'configAImplemented': true,
    'configBImplemented': true,
    'configCImplemented': true,
    'configDImplemented': true,
    'protectedGroundTruthCollectorImplemented': true,
    'benchmarkComparatorImplemented': true,
    'benchmarkGroundTruthMutationInvariancePassed': true,
    'benchmarkGroundTruthRemovalInvariancePassed': true,
    'captureOnceReplayManyUsed': true,
    'identicalDenialOriginUsed': true,
    'initialDenialSnapshotUsed': true,
    'causalGroundTruthMatchingUsed': true,
    'josephCovarianceUpdateUsed': true,
    'circularHeadingInnovationUsed': true,
    'protectedGroundTruthAvailableToEstimators': false,
    'protectedGroundTruthUsedByConfigA': false,
    'protectedGroundTruthUsedByConfigB': false,
    'protectedGroundTruthUsedByConfigC': false,
    'protectedGroundTruthUsedByConfigD': false,
    'protectedGroundTruthUsedByQualityEngine': false,
    'groundTruthCorrectionApplied': false,
    'gnssRecoveryAppliedDuringBenchmark': false,
    'futureEstimatorStateUsedForGroundTruthMatch': false,
    'groundTruthInterpolationUsed': false,
    'arcoreFrameTimestampUsedForFusionOrdering': false,
    'benchmarkAccuracyValidated': false,
    'protectedGroundTruthAccuracyValidated': false,
    'stepDetectionAccuracyValidated': false,
    'stepLengthValidated': false,
    'headingAccuracyValidated': false,
    'arcorePositionAccuracyValidated': false,
    'noiseParametersValidated': false,
    'qualityThresholdsValidated': false,
    'rawGnssCoordinatesReturned': false,
    'rawProtectedGroundTruthReturned': false,
    'rawSensorSamplesReturned': false,
    'rawArcorePosesReturned': false,
    'rawTrajectoryReturned': false,
    'rawTimestampsReturned': false,
    'cameraImagesReturned': false,
    'persistenceUsed': false,
    'protectedGroundTruthAcceptedFixCount': 2,
    'configA': metrics('config_a_deterministic_pdr', 10),
    'configB': metrics('config_b_pdr_heading_ekf', 8),
    'configC': metrics('config_c_arcore_relative', 9),
    'configD': metrics('config_d_navguard_ekf_v1', 7),
    'dVsAMedianImprovementPercent': 30,
    'bVsAMedianImprovementPercent': 20,
    'cVsAMedianImprovementPercent': 10,
    'dVsBMedianImprovementPercent': 12.5,
    'dVsCMedianImprovementPercent': 22.22222222222222,
    'targetImprovementPercent': navguardBenchmarkTargetImprovementPercent,
    'dVsATargetMet': true,
    'protectedGtReportedAccuracyMinM': 10,
    'protectedGtReportedAccuracyMeanM': 12,
    'protectedGtReportedAccuracyMedianM': 12,
    'protectedGtReportedAccuracyMaxM': 14,
    'configAStepOpportunities': 1,
    'configAStepsApplied': 1,
    'configAStepsSkippedNoHeading': 0,
    'configBStepPredictionsApplied': 1,
    'configBHeadingMeasurementsApplied': 1,
    'configBHeadingMeasurementsSkipped': 0,
    'configCArcoreMeasurementsApplied': 1,
    'configCArcoreMeasurementsSkipped': 0,
    'configDStepPredictionsApplied': 1,
    'configDHeadingMeasurementsApplied': 1,
    'configDArcoreMeasurementsApplied': 1,
    'configDStepPredictionsSkippedByQuality': 0,
    'configDHeadingMeasurementsSkippedByQuality': 0,
    'configDArcoreMeasurementsSkippedByQuality': 0,
  };
}
