import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:navguard/navigation/evaluation_mode.dart';

void main() {
  group('Evaluation Mode preflight contract', () {
    test('accepts a fully ready native preflight', () {
      final EvaluationModePreflight value =
          EvaluationModePreflight.fromPlatform(_preflight());
      expect(value.nativeReady, isTrue);
      expect(value.firewallMutationSelfTestPassed, isTrue);
    });

    test('accepts each deterministic not-ready prerequisite', () {
      final List<Map<String, Object?>> values = <Map<String, Object?>>[
        _preflight(gpsAvailable: false, gpsEnabled: false, ready: false),
        _preflight(gpsEnabled: false, ready: false),
        _preflight(finePermission: false, ready: false),
        _preflight(rotationAvailable: false, rotationName: null, ready: false),
        _preflight(stepAvailable: false, stepName: null, ready: false),
        _preflight(activityGranted: false, ready: false),
        _preflight(selfTestPassed: false, ready: false),
        _preflight(running: true, ready: false),
      ];
      for (final Map<String, Object?> value in values) {
        expect(
          EvaluationModePreflight.fromPlatform(value).nativeReady,
          isFalse,
        );
      }
    });

    test('rejects wrong schema, snapshot, or inconsistent readiness', () {
      _expectPreflightMutationsRejected(<String, Object?>{
        'schemaVersion': 2,
        'snapshotKind': 'wrong',
        'nativeReady': false,
        'gpsProviderAvailable': false,
        'rotationVectorName': null,
        'stepDetectorName': null,
      });
    });
  });

  group('pure denied estimator and evaluation helpers', () {
    test('Config A creates a legitimate zero-step initial state', () {
      final List<DeniedEstimatorSnapshot> states = buildConfigADeniedSnapshots(
        formalWindowStartNanos: 100,
        acceptedSteps: const <ConfigADeniedStepInput>[],
      );
      expect(states, hasLength(1));
      expect(states.single.eastM, 0.0);
      expect(states.single.northM, 0.0);
      expect(states.single.integratedStepCount, 0);
    });

    test('Config A reproduces the frozen 0.75 m equations', () {
      final List<DeniedEstimatorSnapshot> states = buildConfigADeniedSnapshots(
        formalWindowStartNanos: 100,
        acceptedSteps: const <ConfigADeniedStepInput>[
          ConfigADeniedStepInput(timestampNanos: 200, headingRad: 0.0),
          ConfigADeniedStepInput(
            timestampNanos: 300,
            headingRad: math.pi / 2.0,
          ),
        ],
      );
      expect(states.last.eastM, closeTo(0.75, 1e-12));
      expect(states.last.northM, closeTo(0.75, 1e-12));
      expect(states.last.integratedStepCount, 2);
    });

    test(
      'associates the greatest previous heading after callback inversion',
      () {
        final _AssociationFixtureResult result =
            _associateDeliveredEvents(const <_DeliveredSensorEvent>[
              _DeliveredSensorEvent.heading(100, 0.0),
              _DeliveredSensorEvent.heading(120, math.pi / 4.0),
              _DeliveredSensorEvent.heading(140, math.pi / 2.0),
              _DeliveredSensorEvent.heading(160, math.pi),
              _DeliveredSensorEvent.step(145),
            ]);
        expect(result.associatedHeadingTimestamps, const <int?>[140]);
        expect(result.associatedStepCount, 1);
        expect(result.unassociatedStepCount, 0);
        final List<DeniedEstimatorSnapshot> states =
            buildConfigADeniedSnapshots(
              formalWindowStartNanos: 50,
              acceptedSteps: result.associatedSteps,
            );
        expect(states.last.eastM, closeTo(0.75, 1e-12));
        expect(states.last.northM, closeTo(0.0, 1e-12));
      },
    );

    test('associates a heading immediately before a step', () {
      final _AssociationFixtureResult result = _associateDeliveredEvents(
        const <_DeliveredSensorEvent>[
          _DeliveredSensorEvent.heading(200, 0.0),
          _DeliveredSensorEvent.step(201),
        ],
      );
      expect(result.associatedHeadingTimestamps, const <int?>[200]);
      expect(result.associatedStepCount, 1);
      expect(result.unassociatedStepCount, 0);
    });

    test('never associates a future heading with an earlier step', () {
      final _AssociationFixtureResult result = _associateDeliveredEvents(
        const <_DeliveredSensorEvent>[
          _DeliveredSensorEvent.step(300),
          _DeliveredSensorEvent.heading(301, 0.0),
        ],
      );
      expect(result.associatedHeadingTimestamps, const <int?>[null]);
      expect(result.associatedStepCount, 0);
      expect(result.unassociatedStepCount, 1);
      expect(result.associatedSteps, isEmpty);
    });

    test('normal 50 Hz heading stream associates every delayed step', () {
      final _AssociationFixtureResult result =
          _associateDeliveredEvents(const <_DeliveredSensorEvent>[
            _DeliveredSensorEvent.heading(100, 0.0),
            _DeliveredSensorEvent.heading(120, 0.0),
            _DeliveredSensorEvent.heading(140, 0.0),
            _DeliveredSensorEvent.step(115),
            _DeliveredSensorEvent.heading(160, math.pi / 2.0),
            _DeliveredSensorEvent.heading(180, math.pi / 2.0),
            _DeliveredSensorEvent.step(155),
            _DeliveredSensorEvent.heading(200, math.pi),
            _DeliveredSensorEvent.heading(220, math.pi),
            _DeliveredSensorEvent.step(195),
          ]);
      final List<DeniedEstimatorSnapshot> states = buildConfigADeniedSnapshots(
        formalWindowStartNanos: 50,
        acceptedSteps: result.associatedSteps,
      );
      final int integratedStepCount = states.last.integratedStepCount;
      expect(result.acceptedStepEventCount, greaterThan(0));
      expect(result.associatedStepCount, result.acceptedStepEventCount);
      expect(result.unassociatedStepCount, 0);
      expect(integratedStepCount, result.associatedStepCount);
      expect(result.associatedHeadingTimestamps, const <int?>[100, 140, 180]);
    });

    test('causal matcher uses latest estimator state at or before GT', () {
      final List<DeniedEstimatorSnapshot> states = buildConfigADeniedSnapshots(
        formalWindowStartNanos: 100,
        acceptedSteps: const <ConfigADeniedStepInput>[
          ConfigADeniedStepInput(timestampNanos: 200, headingRad: 0.0),
          ConfigADeniedStepInput(timestampNanos: 400, headingRad: 0.0),
        ],
      );
      final List<EvaluationMatch> matches =
          matchLatestEstimatorAtOrBeforeGroundTruth(
            estimatorStates: states,
            groundTruthReferences: const <ProtectedEvaluationReference>[
              ProtectedEvaluationReference(
                timestampNanos: 150,
                eastM: 0.0,
                northM: 0.0,
              ),
              ProtectedEvaluationReference(
                timestampNanos: 300,
                eastM: 0.0,
                northM: 0.75,
              ),
            ],
          );
      expect(matches[0].estimatorState.integratedStepCount, 0);
      expect(matches[1].estimatorState.integratedStepCount, 1);
      expect(matches[1].estimatorState.timestampNanos, 200);
      expect(matches[1].estimatorAgeNanos, 100);
    });

    test('matcher never selects a future estimator state', () {
      const List<DeniedEstimatorSnapshot> states = <DeniedEstimatorSnapshot>[
        DeniedEstimatorSnapshot(
          timestampNanos: 200,
          eastM: 0.0,
          northM: 0.0,
          integratedStepCount: 0,
        ),
      ];
      final List<EvaluationMatch> matches =
          matchLatestEstimatorAtOrBeforeGroundTruth(
            estimatorStates: states,
            groundTruthReferences: const <ProtectedEvaluationReference>[
              ProtectedEvaluationReference(
                timestampNanos: 100,
                eastM: 0.0,
                northM: 0.0,
              ),
            ],
          );
      expect(matches, isEmpty);
    });

    test('horizontal error uses Euclidean EN distance', () {
      expect(
        calculateHorizontalErrorM(
          estimatorEastM: 4.0,
          estimatorNorthM: 6.0,
          groundTruthEastM: 1.0,
          groundTruthNorthM: 2.0,
        ),
        5.0,
      );
    });

    test('aggregate statistics use median and nearest-rank p95', () {
      final EvaluationStatistics value = calculateEvaluationStatistics(<double>[
        1,
        2,
        3,
        4,
        100,
      ]);
      expect(value.min, 1.0);
      expect(value.max, 100.0);
      expect(value.mean, 22.0);
      expect(value.median, 3.0);
      expect(value.p95, 100.0);
    });

    test('mutation fixture preserves estimator while metrics change', () {
      final FirewallMutationFixtureResult result = runFirewallMutationFixture();
      expect(result.estimatorInvariant, isTrue);
      expect(result.evaluationMetricsDiffer, isTrue);
      expect(result.passed, isTrue);
    });

    test('pure helpers reject malformed or non-finite inputs', () {
      expect(
        () => buildConfigADeniedSnapshots(
          formalWindowStartNanos: 0,
          acceptedSteps: const <ConfigADeniedStepInput>[],
        ),
        throwsFormatException,
      );
      expect(
        () => calculateHorizontalErrorM(
          estimatorEastM: double.nan,
          estimatorNorthM: 0,
          groundTruthEastM: 0,
          groundTruthNorthM: 0,
        ),
        throwsFormatException,
      );
      expect(
        () => calculateEvaluationStatistics(const <double>[]),
        throwsFormatException,
      );
    });
  });

  group('Evaluation Mode result contract', () {
    test('accepts a valid stationary zero-step result', () {
      final EvaluationModeDiagnosticResult result =
          EvaluationModeDiagnosticResult.fromPlatform(_result());
      expect(result.integratedStepCount, 0);
      expect(result.finalDeniedEastM, 0.0);
      expect(result.finalDeniedNorthM, 0.0);
      expect(result.matchedGroundTruthFixCount, 2);
    });

    test('accepts a valid moving result and final pre-correction error', () {
      final EvaluationModeDiagnosticResult result =
          EvaluationModeDiagnosticResult.fromPlatform(_movingResult());
      expect(result.integratedStepCount, 2);
      expect(result.finalDeniedNorthM, 1.5);
      expect(result.finalDeniedPreCorrectionErrorM, 2.0);
    });

    test('rejects wrong identity, timing authorities, and clocks', () {
      _expectResultMutationsRejected(<String, Object?>{
        'schemaVersion': 2,
        'snapshotKind': 'wrong',
        'success': false,
        'evaluationWindowMs': 10,
        'protectedGtFirstFixTimeoutMs': 10,
        'coordinateFrame': 'latitude_longitude',
        'physicalGnssAvailable': false,
        'physicalGnssRole': 'estimator_input',
        'stepTimestampAuthority': 'callback_order',
        'headingTimestampAuthority': 'callback_order',
        'protectedGroundTruthTimestampAuthority': 'Location.getTime',
        'operationWindowClock': 'System.currentTimeMillis',
        'elapsedRealtimeSharedTimeBaseUsed': false,
        'gnssSensorElapsedRealtimeComparisonUsed': false,
        'unsupportedCrossClockComparisonUsed': true,
      });
    });

    test('rejects every Ground Truth Firewall violation', () {
      for (final String key in <String>[
        'protectedGnssAvailableToEstimatorApi',
        'protectedGnssUsedByDeniedEstimator',
        'protectedGnssUsedByHeading',
        'protectedGnssUsedByStepLength',
        'protectedGnssUsedByQualityEngine',
        'protectedGnssUsedByController',
        'gnssCorrectionApplied',
      ]) {
        expect(
          () => EvaluationModeDiagnosticResult.fromPlatform(<String, Object?>{
            ..._result(),
            key: true,
          }),
          throwsFormatException,
          reason: key,
        );
      }
      for (final String key in <String>[
        'evaluationModeImplemented',
        'groundTruthFirewallImplemented',
        'protectedGroundTruthGnssActive',
        'softwareDefinedEstimatorGnssDenial',
        'firewallMutationSelfTestPassed',
      ]) {
        expect(
          () => EvaluationModeDiagnosticResult.fromPlatform(<String, Object?>{
            ..._result(),
            key: false,
          }),
          throwsFormatException,
          reason: key,
        );
      }
    });

    test('rejects raw-data return and persistence violations', () {
      for (final String key in <String>[
        'rawGroundTruthTrajectoryReturned',
        'rawDeniedTrajectoryReturned',
        'rawGnssCoordinatesReturned',
        'rawTimestampsReturned',
        'persistenceUsed',
      ]) {
        expect(
          () => EvaluationModeDiagnosticResult.fromPlatform(<String, Object?>{
            ..._result(),
            key: true,
          }),
          throwsFormatException,
          reason: key,
        );
      }
    });

    test('rejects overclaimed future-stage and accuracy flags', () {
      for (final String key in <String>[
        'baselinePdrAccuracyValidated',
        'stepDetectionAccuracyValidated',
        'stepLengthValidated',
        'headingAccuracyValidated',
        'trueNorthAccuracyValidated',
        'protectedGnssGroundTruthAccuracyValidated',
        'qualityEngineImplemented',
        'ekfImplemented',
        'pdrArcoreFusionImplemented',
        'gnssRecoveryImplemented',
        'fullGnssDeniedNavigationImplemented',
      ]) {
        expect(
          () => EvaluationModeDiagnosticResult.fromPlatform(<String, Object?>{
            ..._result(),
            key: true,
          }),
          throwsFormatException,
          reason: key,
        );
      }
    });

    test('rejects Config A drift and future-heading claims', () {
      _expectResultMutationsRejected(<String, Object?>{
        'deniedEstimatorProfile': 'adaptive',
        'stepSource': 'TYPE_STEP_COUNTER',
        'headingSource': 'TYPE_GAME_ROTATION_VECTOR',
        'headingConvention': 'counterclockwise',
        'deviceForwardAxis': 'device_positive_x',
        'stepLengthModel': 'calibrated',
        'stepLengthM': 0.8,
        'stepLengthCalibrated': true,
        'futureHeadingUsed': true,
        'headingAssociationPolicy': 'nearest_heading',
      });
    });

    test('rejects negative and inconsistent protected GT counters', () {
      _expectResultMutationsRejected(<String, Object?>{
        'protectedGtUpdateCount': -1,
        'acceptedProtectedGtFixCount': 1,
        'uniqueProtectedGtTimestampCount': 1,
        'mockProtectedGtFixCount': 1,
        'matchedGroundTruthFixCount': 3,
        'unmatchedGroundTruthFixCount': 2,
      });
    });

    test('rejects negative and inconsistent estimator counters', () {
      _expectResultMutationsRejected(<String, Object?>{
        'stepUpdateCount': -1,
        'acceptedStepEventCount': 1,
        'uniqueStepTimestampCount': 1,
        'associatedStepCount': 1,
        'unassociatedStepCount': 1,
        'integratedStepCount': 1,
        'headingUpdateCount': -1,
        'validHeadingSampleCount': 1,
        'uniqueHeadingTimestampCount': 1,
      });
    });

    test('rejects zero matched pairs on a successful result', () {
      expect(
        () => EvaluationModeDiagnosticResult.fromPlatform(<String, Object?>{
          ..._result(),
          'matchedGroundTruthFixCount': 0,
          'unmatchedGroundTruthFixCount': 2,
        }),
        throwsFormatException,
      );
    });

    test('rejects invalid final norm and nominal path length', () {
      _expectResultMutationsRejected(<String, Object?>{
        'finalDeniedHorizontalDisplacementM': 1.0,
        'nominalDeniedIntegratedPathLengthM': 1.0,
      });
    });

    test('rejects non-finite or misordered error and age metrics', () {
      _expectResultMutationsRejected(<String, Object?>{
        'minHorizontalErrorM': double.nan,
        'meanHorizontalErrorM': 3.0,
        'medianHorizontalErrorM': 3.0,
        'p95HorizontalErrorM': 3.0,
        'minEstimatorAgeAtGtMs': -1.0,
        'meanEstimatorAgeAtGtMs': 30.0,
        'medianEstimatorAgeAtGtMs': 30.0,
        'p95EstimatorAgeAtGtMs': 30.0,
      });
    });

    test('accepts unavailable accuracy and rejects incomplete accuracy', () {
      expect(
        EvaluationModeDiagnosticResult.fromPlatform(_result()),
        isA<EvaluationModeDiagnosticResult>(),
      );
      expect(
        () => EvaluationModeDiagnosticResult.fromPlatform(<String, Object?>{
          ..._result(),
          'minReportedGtAccuracyM': 1.0,
        }),
        throwsFormatException,
      );
    });
  });
}

class _DeliveredSensorEvent {
  const _DeliveredSensorEvent.heading(this.timestampNanos, this.headingRad)
    : isHeading = true;

  const _DeliveredSensorEvent.step(this.timestampNanos)
    : headingRad = null,
      isHeading = false;

  final int timestampNanos;
  final double? headingRad;
  final bool isHeading;
}

class _HeadingFixture {
  const _HeadingFixture(this.timestampNanos, this.headingRad);

  final int timestampNanos;
  final double headingRad;
}

class _AssociationFixtureResult {
  const _AssociationFixtureResult({
    required this.acceptedStepEventCount,
    required this.associatedStepCount,
    required this.unassociatedStepCount,
    required this.associatedHeadingTimestamps,
    required this.associatedSteps,
  });

  final int acceptedStepEventCount;
  final int associatedStepCount;
  final int unassociatedStepCount;
  final List<int?> associatedHeadingTimestamps;
  final List<ConfigADeniedStepInput> associatedSteps;
}

_AssociationFixtureResult _associateDeliveredEvents(
  List<_DeliveredSensorEvent> deliveredEvents,
) {
  final List<_HeadingFixture> headings = <_HeadingFixture>[];
  final List<int> steps = <int>[];
  for (final _DeliveredSensorEvent event in deliveredEvents) {
    if (event.isHeading) {
      headings.add(_HeadingFixture(event.timestampNanos, event.headingRad!));
    } else {
      steps.add(event.timestampNanos);
    }
  }

  int headingIndex = 0;
  _HeadingFixture? latestHeading;
  final List<int?> associatedHeadingTimestamps = <int?>[];
  final List<ConfigADeniedStepInput> associatedSteps =
      <ConfigADeniedStepInput>[];
  for (final int stepTimestamp in steps) {
    while (headingIndex < headings.length &&
        headings[headingIndex].timestampNanos <= stepTimestamp) {
      latestHeading = headings[headingIndex];
      headingIndex += 1;
    }
    associatedHeadingTimestamps.add(latestHeading?.timestampNanos);
    if (latestHeading != null) {
      associatedSteps.add(
        ConfigADeniedStepInput(
          timestampNanos: stepTimestamp,
          headingRad: latestHeading.headingRad,
        ),
      );
    }
  }

  return _AssociationFixtureResult(
    acceptedStepEventCount: steps.length,
    associatedStepCount: associatedSteps.length,
    unassociatedStepCount: steps.length - associatedSteps.length,
    associatedHeadingTimestamps: List<int?>.unmodifiable(
      associatedHeadingTimestamps,
    ),
    associatedSteps: List<ConfigADeniedStepInput>.unmodifiable(associatedSteps),
  );
}

Map<String, Object?> _preflight({
  bool gpsAvailable = true,
  bool gpsEnabled = true,
  bool finePermission = true,
  bool rotationAvailable = true,
  String? rotationName = 'Rotation Vector Non-wakeup',
  bool stepAvailable = true,
  String? stepName = 'Step Detector Non-wakeup',
  bool activityGranted = true,
  bool selfTestPassed = true,
  bool running = false,
  bool ready = true,
}) {
  return <String, Object?>{
    'schemaVersion': 1,
    'snapshotKind': 'evaluation_mode_preflight',
    'gpsProviderAvailable': gpsAvailable,
    'gpsProviderEnabled': gpsEnabled,
    'fineLocationPermissionGranted': finePermission,
    'rotationVectorAvailable': rotationAvailable,
    'rotationVectorName': rotationName,
    'stepDetectorAvailable': stepAvailable,
    'stepDetectorName': stepName,
    'activityRecognitionPermissionRequired': true,
    'activityRecognitionPermissionGranted': activityGranted,
    'firewallMutationSelfTestPassed': selfTestPassed,
    'diagnosticRunning': running,
    'nativeReady': ready,
  };
}

Map<String, Object?> _result() {
  return <String, Object?>{
    'schemaVersion': 1,
    'snapshotKind': 'evaluation_mode_diagnostic_result',
    'success': true,
    'evaluationWindowMs': 30000,
    'protectedGtFirstFixTimeoutMs': 15000,
    'coordinateFrame': 'local_enu',
    'physicalGnssAvailable': true,
    'physicalGnssRole': 'protected_ground_truth_only',
    'evaluationModeImplemented': true,
    'groundTruthFirewallImplemented': true,
    'protectedGroundTruthGnssActive': true,
    'softwareDefinedEstimatorGnssDenial': true,
    'protectedGnssAvailableToEstimatorApi': false,
    'protectedGnssUsedByDeniedEstimator': false,
    'protectedGnssUsedByHeading': false,
    'protectedGnssUsedByStepLength': false,
    'protectedGnssUsedByQualityEngine': false,
    'protectedGnssUsedByController': false,
    'gnssCorrectionApplied': false,
    'firewallMutationSelfTestPassed': true,
    'liveGnssPhysicallyActive': true,
    'liveGnssUsedByDeniedEstimator': false,
    'liveGnssUsedForProtectedGroundTruth': true,
    'protectedGtUpdateCount': 3,
    'acceptedProtectedGtFixCount': 2,
    'invalidProtectedGtFixCount': 0,
    'outOfWindowProtectedGtFixCount': 1,
    'uniqueProtectedGtTimestampCount': 2,
    'duplicateProtectedGtTimestampCount': 0,
    'nonMonotonicProtectedGtTimestampCount': 0,
    'mockProtectedGtFixCount': 0,
    'matchedGroundTruthFixCount': 2,
    'unmatchedGroundTruthFixCount': 0,
    'minReportedGtAccuracyM': null,
    'maxReportedGtAccuracyM': null,
    'meanReportedGtAccuracyM': null,
    'medianReportedGtAccuracyM': null,
    'minHorizontalErrorM': 1.0,
    'maxHorizontalErrorM': 2.0,
    'meanHorizontalErrorM': 1.5,
    'medianHorizontalErrorM': 1.5,
    'p95HorizontalErrorM': 2.0,
    'finalDeniedPreCorrectionErrorM': 2.0,
    'minEstimatorAgeAtGtMs': 10.0,
    'maxEstimatorAgeAtGtMs': 20.0,
    'meanEstimatorAgeAtGtMs': 15.0,
    'medianEstimatorAgeAtGtMs': 15.0,
    'p95EstimatorAgeAtGtMs': 20.0,
    'stepUpdateCount': 0,
    'acceptedStepEventCount': 0,
    'invalidStepEventCount': 0,
    'outOfWindowStepEventCount': 0,
    'uniqueStepTimestampCount': 0,
    'duplicateStepTimestampCount': 0,
    'nonMonotonicStepTimestampCount': 0,
    'associatedStepCount': 0,
    'unassociatedStepCount': 0,
    'integratedStepCount': 0,
    'headingUpdateCount': 2,
    'validHeadingSampleCount': 2,
    'invalidHeadingSampleCount': 0,
    'uniqueHeadingTimestampCount': 2,
    'duplicateHeadingTimestampCount': 0,
    'nonMonotonicHeadingTimestampCount': 0,
    'finalDeniedEastM': 0.0,
    'finalDeniedNorthM': 0.0,
    'finalDeniedHorizontalDisplacementM': 0.0,
    'nominalDeniedIntegratedPathLengthM': 0.0,
    'deniedEstimatorProfile': 'config_a_baseline_pdr',
    'stepSource': 'TYPE_STEP_DETECTOR',
    'headingSource': 'TYPE_ROTATION_VECTOR',
    'headingConvention': 'clockwise_from_north_0_to_2pi',
    'deviceForwardAxis': 'device_positive_y_top_edge',
    'stepLengthModel': 'fixed_baseline',
    'stepLengthM': 0.75,
    'stepLengthCalibrated': false,
    'stepLengthValidated': false,
    'headingAssociationPolicy':
        'latest_valid_heading_at_or_before_step_timestamp',
    'futureHeadingUsed': false,
    'stepTimestampAuthority': 'SensorEvent.timestamp',
    'headingTimestampAuthority': 'SensorEvent.timestamp',
    'protectedGroundTruthTimestampAuthority':
        'Location.getElapsedRealtimeNanos',
    'operationWindowClock': 'SystemClock.elapsedRealtimeNanos',
    'elapsedRealtimeSharedTimeBaseUsed': true,
    'gnssSensorElapsedRealtimeComparisonUsed': true,
    'unsupportedCrossClockComparisonUsed': false,
    'baselinePdrAccuracyValidated': false,
    'stepDetectionAccuracyValidated': false,
    'headingAccuracyValidated': false,
    'trueNorthAccuracyValidated': false,
    'protectedGnssGroundTruthAccuracyValidated': false,
    'qualityEngineImplemented': false,
    'ekfImplemented': false,
    'pdrArcoreFusionImplemented': false,
    'gnssRecoveryImplemented': false,
    'fullGnssDeniedNavigationImplemented': false,
    'rawGroundTruthTrajectoryReturned': false,
    'rawDeniedTrajectoryReturned': false,
    'rawGnssCoordinatesReturned': false,
    'rawTimestampsReturned': false,
    'persistenceUsed': false,
  };
}

Map<String, Object?> _movingResult() {
  return <String, Object?>{
    ..._result(),
    'stepUpdateCount': 2,
    'acceptedStepEventCount': 2,
    'uniqueStepTimestampCount': 2,
    'associatedStepCount': 2,
    'integratedStepCount': 2,
    'finalDeniedNorthM': 1.5,
    'finalDeniedHorizontalDisplacementM': 1.5,
    'nominalDeniedIntegratedPathLengthM': 1.5,
  };
}

void _expectPreflightMutationsRejected(Map<String, Object?> mutations) {
  for (final MapEntry<String, Object?> mutation in mutations.entries) {
    expect(
      () => EvaluationModePreflight.fromPlatform(<String, Object?>{
        ..._preflight(),
        mutation.key: mutation.value,
      }),
      throwsFormatException,
      reason: mutation.key,
    );
  }
}

void _expectResultMutationsRejected(Map<String, Object?> mutations) {
  for (final MapEntry<String, Object?> mutation in mutations.entries) {
    expect(
      () => EvaluationModeDiagnosticResult.fromPlatform(<String, Object?>{
        ..._result(),
        mutation.key: mutation.value,
      }),
      throwsFormatException,
      reason: mutation.key,
    );
  }
}
