import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:navguard/navigation/full_navguard_flow.dart';
import 'package:navguard/navigation/navguard_fusion.dart';

void main() {
  group('Stage 8 state machine', () {
    test('accepts the exact successful order', () {
      for (
        var index = 0;
        index < fullNavguardSuccessfulStateOrder.length - 1;
        index += 1
      ) {
        expect(
          isValidFullNavguardTransition(
            fullNavguardSuccessfulStateOrder[index],
            fullNavguardSuccessfulStateOrder[index + 1],
          ),
          isTrue,
        );
      }
    });

    test('rejects skips and reverse transitions', () {
      expect(
        isValidFullNavguardTransition(
          FullNavguardFlowState.normalGnss,
          FullNavguardFlowState.recoveredGnss,
        ),
        isFalse,
      );
      expect(
        isValidFullNavguardTransition(
          FullNavguardFlowState.deniedNavguard,
          FullNavguardFlowState.normalGnss,
        ),
        isFalse,
      );
      expect(
        isValidFullNavguardTransition(
          FullNavguardFlowState.recoveryPending,
          FullNavguardFlowState.deniedNavguard,
        ),
        isFalse,
      );
    });

    test('parses exact wire states and rejects unknown state', () {
      expect(
        FullNavguardFlowState.parse('DENIED_NAVGUARD'),
        FullNavguardFlowState.deniedNavguard,
      );
      expect(
        () => FullNavguardFlowState.parse('DENIED'),
        throwsFormatException,
      );
    });
  });

  group('denied PDR causal replay', () {
    DeniedHeadingSample heading(int timestamp, double radians) =>
        DeniedHeadingSample(
          timestampNanos: timestamp,
          headingRad: radians,
          quality: NavguardQuality.good,
        );

    test(
      'delayed step uses the greatest earlier heading, never the future',
      () {
        final DeniedPdrReplayResult result = replayDeniedPdrCausally(
          headings: <DeniedHeadingSample>[
            heading(100, 0.1),
            heading(130, 0.3),
            heading(120, 0.2),
          ],
          stepTimestampsNanos: <int>[125],
        );

        expect(result.predictionsApplied, 1);
        expect(result.predictionsSkippedNoHeading, 0);
        expect(result.associations.single.headingTimestampNanos, 120);
        expect(result.associations.single.headingRad, 0.2);
      },
    );

    test('equal timestamp is replayed heading first', () {
      final DeniedPdrReplayResult result = replayDeniedPdrCausally(
        headings: <DeniedHeadingSample>[heading(100, 0.4)],
        stepTimestampsNanos: <int>[100],
      );

      expect(result.predictionsApplied, 1);
      expect(result.associations.single.headingTimestampNanos, 100);
    });

    test('multiple delayed steps each use their greatest causal heading', () {
      final DeniedPdrReplayResult result = replayDeniedPdrCausally(
        headings: <DeniedHeadingSample>[
          heading(150, 0.4),
          heading(100, 0.1),
          heading(130, 0.3),
          heading(120, 0.2),
        ],
        stepTimestampsNanos: <int>[140, 125],
      );

      expect(result.predictionsApplied, 2);
      expect(
        result.associations
            .map((DeniedStepAssociation item) => item.headingTimestampNanos)
            .toList(),
        <int?>[120, 130],
      );
    });

    test('a future-only heading is rejected', () {
      final DeniedPdrReplayResult result = replayDeniedPdrCausally(
        headings: <DeniedHeadingSample>[heading(110, 0.1)],
        stepTimestampsNanos: <int>[100],
      );

      expect(result.predictionsApplied, 0);
      expect(result.predictionsSkippedNoHeading, 1);
      expect(result.associations.single.headingTimestampNanos, isNull);
    });

    test('high-rate reordered stream predicts every causally headed step', () {
      const int startNs = 1000000000;
      const int headingIntervalNs = 20000000;
      final List<DeniedHeadingSample> deliveredHeadings =
          List<DeniedHeadingSample>.generate(
            1500,
            (int index) => heading(
              startNs + (index * headingIntervalNs),
              (index % 360) * math.pi / 180,
            ),
          ).reversed.toList();
      final List<int> deliveredSteps = <int>[
        for (var index = 50; index < 1450; index += 70)
          startNs + (index * headingIntervalNs) + 10000000,
      ].reversed.toList();

      final DeniedPdrReplayResult result = replayDeniedPdrCausally(
        headings: deliveredHeadings,
        stepTimestampsNanos: deliveredSteps,
      );

      expect(result.predictionsApplied, deliveredSteps.length);
      expect(result.predictionsSkippedNoHeading, 0);
      expect(result.predictionsSkippedByQuality, 0);
      expect(result.acceptedStepOpportunityCount, deliveredSteps.length);
      expect(result.counterInvariantHolds, isTrue);
      for (final DeniedStepAssociation association in result.associations) {
        expect(
          association.headingTimestampNanos,
          lessThanOrEqualTo(association.stepTimestampNanos),
        );
      }
    });
  });

  group('GNSS denial firewall', () {
    DeniedFirewallSnapshot fixture() => DeniedFirewallSnapshot(
      estimate: NavguardFusionEstimate.initial(math.pi / 3),
      headingQuality: NavguardQuality.good,
      pdrQuality: NavguardQuality.usable,
      arcoreQuality: NavguardQuality.degraded,
      controllerState: 7,
    );

    test('quarantined GNSS changes only its diagnostic counter', () {
      final DeniedFirewallSnapshot before = fixture();
      final DeniedFirewallSnapshot after = before.quarantineGnss(
        latitudeDeg: 41,
        longitudeDeg: 29,
      );
      expect(after.deniedGnssFixCount, 1);
      expect(after.estimate, same(before.estimate));
      expect(after.headingQuality, before.headingQuality);
      expect(after.pdrQuality, before.pdrQuality);
      expect(after.arcoreQuality, before.arcoreQuality);
      expect(after.controllerState, before.controllerState);
    });

    test('denied-coordinate mutation is estimator invariant', () {
      final DeniedFirewallSnapshot baseline = fixture();
      final DeniedFirewallSnapshot first = baseline.quarantineGnss(
        latitudeDeg: 0,
        longitudeDeg: 0,
      );
      final DeniedFirewallSnapshot second = baseline.quarantineGnss(
        latitudeDeg: 89,
        longitudeDeg: -179,
      );
      expect(deniedGnssMutationInvariant(first: first, second: second), isTrue);
    });
  });

  group('recovery gate', () {
    RecoveryFixCandidate fix(int timestamp, double accuracy) =>
        RecoveryFixCandidate(
          elapsedRealtimeNanos: timestamp,
          horizontalAccuracyM: accuracy,
        );

    test('uses fix generation time at the strict gate boundary', () {
      expect(
        classifyRecoveryFix(
          fix: fix(999, 5),
          recoveryGateElapsedRealtimeNanos: 1000,
        ),
        RecoveryFixAdmission.preGate,
      );
      expect(
        classifyRecoveryFix(
          fix: fix(1000, 5),
          recoveryGateElapsedRealtimeNanos: 1000,
        ),
        RecoveryFixAdmission.accepted,
      );
      expect(
        classifyRecoveryFix(
          fix: fix(1001, 5),
          recoveryGateElapsedRealtimeNanos: 1000,
        ),
        RecoveryFixAdmission.accepted,
      );
    });

    test('rejects a pre-gate fix even when callback is later', () {
      const int callbackReceiptAfterGate = 2000;
      expect(callbackReceiptAfterGate, greaterThan(1000));
      expect(
        classifyRecoveryFix(
          fix: fix(999, 5),
          recoveryGateElapsedRealtimeNanos: 1000,
        ),
        RecoveryFixAdmission.preGate,
      );
    });

    test('accepts 50 m inclusively and rejects over threshold', () {
      for (final double accepted in <double>[49.999, 50]) {
        expect(
          classifyRecoveryFix(
            fix: fix(1001, accepted),
            recoveryGateElapsedRealtimeNanos: 1000,
          ),
          RecoveryFixAdmission.accepted,
        );
      }
      expect(
        classifyRecoveryFix(
          fix: fix(1001, 50.001),
          recoveryGateElapsedRealtimeNanos: 1000,
        ),
        RecoveryFixAdmission.qualityRejected,
      );
    });

    test('opens only on the final three consecutive good fixes', () {
      ConsecutiveRecoveryGate gate = const ConsecutiveRecoveryGate();
      final List<RecoveryFixAdmission> sequence = <RecoveryFixAdmission>[
        RecoveryFixAdmission.accepted,
        RecoveryFixAdmission.accepted,
        RecoveryFixAdmission.qualityRejected,
        RecoveryFixAdmission.accepted,
        RecoveryFixAdmission.accepted,
        RecoveryFixAdmission.accepted,
      ];
      for (var index = 0; index < sequence.length; index += 1) {
        gate = gate.apply(sequence[index]);
        expect(gate.recovered, index == sequence.length - 1);
      }
      expect(gate.consecutiveGoodFixes, 3);
    });
  });

  group('controlled recovery reset', () {
    test('resets position/covariance and preserves sensor heading', () {
      final NavguardFusionEstimate denied = NavguardFusionEstimate(
        eastM: 10,
        northM: 5,
        headingRad: 1.25,
        covariance: NavguardMatrix3.diagonal(2, 3, 0.4),
      );
      final NavguardFusionEstimate recovered = applyRecoveryPositionReset(
        deniedEstimate: denied,
        recoveredEastM: 12,
        recoveredNorthM: 8,
        acceptedAccuracyM: 8,
      );
      expect(
        calculateRecoveryCorrectionDistanceM(
          deniedEastM: denied.eastM,
          deniedNorthM: denied.northM,
          recoveredEastM: recovered.eastM,
          recoveredNorthM: recovered.northM,
        ),
        closeTo(math.sqrt(13), 1e-12),
      );
      expect(recovered.eastM, 12);
      expect(recovered.northM, 8);
      expect(recovered.headingRad, denied.headingRad);
      expect(recovered.covariance.at(0, 0), 64);
      expect(recovered.covariance.at(1, 1), 64);
      expect(recovered.covariance.at(2, 2), 0.4);
      for (final List<int> index in <List<int>>[
        <int>[0, 1],
        <int>[1, 0],
        <int>[0, 2],
        <int>[2, 0],
        <int>[1, 2],
        <int>[2, 1],
      ]) {
        expect(recovered.covariance.at(index[0], index[1]), 0);
      }
    });
  });

  group('Stage 8 Config D regressions', () {
    test('north/east steps and quality skip retain Stage 7 semantics', () {
      final NavguardFusionEstimate north = navguardStepPredict(
        NavguardFusionEstimate.initial(0),
        quality: NavguardQuality.usable,
      );
      expect(north.eastM, closeTo(0, 1e-12));
      expect(north.northM, closeTo(0.75, 1e-12));

      final NavguardFusionEstimate east = navguardStepPredict(
        NavguardFusionEstimate.initial(math.pi / 2),
        quality: NavguardQuality.usable,
      );
      expect(east.eastM, closeTo(0.75, 1e-12));
      expect(east.northM, closeTo(0, 1e-12));
      expect(
        navguardStepPredict(east, quality: NavguardQuality.unreliable),
        same(east),
      );
    });

    test(
      'heading wrap, Joseph covariance, and ARCore correction are finite',
      () {
        final NavguardFusionEstimate initial = NavguardFusionEstimate.initial(
          (2 * math.pi) - 0.01,
        );
        final NavguardMeasurementUpdate heading = navguardHeadingUpdate(
          initial,
          measuredHeadingRad: 0.01,
          quality: NavguardQuality.good,
        );
        expect(heading.innovation.single, closeTo(0.02, 1e-12));
        expect(heading.estimate.headingRad, inInclusiveRange(0, 2 * math.pi));
        final NavguardMeasurementUpdate ar = navguardArcorePositionUpdate(
          heading.estimate,
          measuredEastM: 3,
          measuredNorthM: 4,
          quality: NavguardQuality.usable,
        );
        expect(ar.innovation, hasLength(2));
        for (final double value in ar.estimate.covariance.values) {
          expect(value.isFinite, isTrue);
        }
        expect(ar.estimate.covariance.at(0, 0), greaterThanOrEqualTo(0));
        expect(ar.estimate.covariance.at(1, 1), greaterThanOrEqualTo(0));
        expect(ar.estimate.covariance.at(2, 2), greaterThanOrEqualTo(0));
      },
    );
  });

  test('preflight parser is strict', () {
    final FullNavguardFlowPreflight parsed =
        FullNavguardFlowPreflight.fromPlatform(<String, Object?>{
          'schemaVersion': 1,
          'snapshotKind': 'full_navguard_flow_preflight',
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
          'currentState': 'IDLE',
        });
    expect(parsed.nativeReady, isTrue);
    expect(parsed.currentState, FullNavguardFlowState.idle);
    expect(
      () => FullNavguardFlowPreflight.fromPlatform(<String, Object?>{}),
      throwsFormatException,
    );
  });

  test('result parser enforces no bearing and protected-GT exclusion', () {
    final FullNavguardFlowDiagnosticResult result =
        FullNavguardFlowDiagnosticResult.fromPlatform(_validResult());
    expect(result.finalState, FullNavguardFlowState.completed);
    expect(result.deniedGnssUsedByEstimatorCount, 0);
    expect(result.sanitizedMetadata['gnssBearingUsedForRecovery'], isFalse);
    expect(result.sanitizedMetadata['protectedGroundTruthAccessed'], isFalse);

    final Map<String, Object?> violation = _validResult();
    violation['gnssBearingUsedForRecovery'] = true;
    expect(
      () => FullNavguardFlowDiagnosticResult.fromPlatform(violation),
      throwsFormatException,
    );

    final Map<String, Object?> groundTruthViolation = _validResult();
    groundTruthViolation['protectedGroundTruthAccessed'] = true;
    expect(
      () => FullNavguardFlowDiagnosticResult.fromPlatform(groundTruthViolation),
      throwsFormatException,
    );
  });

  test('result parser enforces PDR and recovery counter contracts', () {
    final FullNavguardFlowDiagnosticResult result =
        FullNavguardFlowDiagnosticResult.fromPlatform(_validResult());
    expect(result.deniedAcceptedStepOpportunityCount, 2);
    expect(result.recoveryCandidateFixCount, 3);
    expect(result.recoveryAcceptedFixCount, 3);
    expect(result.recoveryRejectedFixCount, 0);
    expect(result.recoveredObservationAcceptedFixCount, 5);

    final Map<String, Object?> invalidPdr = _validResult();
    invalidPdr['deniedAcceptedStepOpportunityCount'] = 3;
    expect(
      () => FullNavguardFlowDiagnosticResult.fromPlatform(invalidPdr),
      throwsFormatException,
    );

    final Map<String, Object?> invalidRecovery = _validResult();
    invalidRecovery['recoveryAcceptedFixCount'] = 4;
    expect(
      () => FullNavguardFlowDiagnosticResult.fromPlatform(invalidRecovery),
      throwsFormatException,
    );
  });
}

Map<String, Object?> _validResult() {
  final Map<String, Object?> result = <String, Object?>{
    'schemaVersion': 1,
    'snapshotKind': 'full_navguard_flow_diagnostic_result',
    'success': true,
    'finalState': 'COMPLETED',
    'finalNavigationMode': 'GNSS_RECOVERED',
    'gnssProvider': 'GPS_PROVIDER',
    'gnssTimestampAuthority': 'Location.getElapsedRealtimeNanos',
    'operationClock': 'SystemClock.elapsedRealtimeNanos',
    'headingAssociationPolicy':
        'latest_valid_heading_at_or_before_step_timestamp',
    'maxOperationalGnssAccuracyM': 50.0,
    'recoveryConsecutiveGoodFixesRequired': 3,
    'recoveryConsecutiveGoodFixesAchieved': 3,
    'normalGnssAcceptedFixCount': 4,
    'normalGnssRejectedFixCount': 0,
    'deniedGnssFixCount': 2,
    'deniedGnssRejectedFixCount': 0,
    'deniedGnssUsedByEstimatorCount': 0,
    'recoveryCandidateFixCount': 3,
    'recoveryAcceptedFixCount': 3,
    'recoveryRejectedFixCount': 0,
    'recoveredObservationAcceptedFixCount': 5,
    'recoveredObservationRejectedFixCount': 0,
    'deniedHeadingMeasurementsApplied': 2,
    'deniedHeadingMeasurementsSkippedByQuality': 0,
    'deniedPdrPredictionsApplied': 2,
    'deniedPdrPredictionsSkippedNoHeading': 0,
    'deniedPdrPredictionsSkippedByQuality': 0,
    'deniedAcceptedStepOpportunityCount': 2,
    'deniedArcoreMeasurementsApplied': 2,
    'deniedArcoreMeasurementsSkippedByQuality': 0,
    'stateTransitionCount': 6,
    'normalGnssDurationMs': 5000.0,
    'deniedNavigationDurationMs': 30000.0,
    'recoveryPendingDurationMs': 2000.0,
    'recoveredGnssDurationMs': 5000.0,
    'preRecoveryDeniedEastM': 10.0,
    'preRecoveryDeniedNorthM': 5.0,
    'preRecoveryDeniedHorizontalDisplacementFromDenialOriginM': 2.0,
    'preRecoveryVarianceEastM2': 1.0,
    'preRecoveryVarianceNorthM2': 1.0,
    'preRecoveryVarianceHeadingRad2': 0.2,
    'preRecoveryHeadingQuality': 'GOOD',
    'preRecoveryPdrQuality': 'USABLE',
    'preRecoveryArcoreQuality': 'USABLE',
    'preRecoveryFusionQuality': 'USABLE',
    'recoveredGnssEastM': 12.0,
    'recoveredGnssNorthM': 8.0,
    'recoveryCorrectionDistanceM': math.sqrt(13),
    'finalRecoveredEastM': 12.0,
    'finalRecoveredNorthM': 8.0,
    'finalRecoveredHorizontalFromAnchorM': math.sqrt(208),
    'finalRecoveredHeadingRad': 1.25,
    'finalRecoveredVarianceEastM2': 64.0,
    'finalRecoveredVarianceNorthM2': 64.0,
    'finalRecoveredVarianceHeadingRad2': 0.2,
  };
  for (final String key in <String>[
    'softwareDefinedGnssDenialImplemented',
    'gnssRecoveryImplemented',
    'fullGnssDeniedNavigationImplemented',
    'physicalGnssListenerActiveDuringDenial',
    'deniedGnssQuarantineImplemented',
    'denialGnssMutationInvariancePassed',
    'recoveryGateImplemented',
    'recoveryUsesFixGenerationTime',
    'recoveryRequiresFreshFixes',
    'recoveryRequiresConsecutiveFixes',
    'recoveryPositionResetApplied',
    'normalGnssEntered',
    'deniedNavguardEntered',
    'recoveryPendingEntered',
    'recoveredGnssEntered',
    'completedEntered',
    'qualityEngineImplemented',
    'ekfImplemented',
    'configDImplemented',
    'josephCovarianceUpdateUsed',
    'circularHeadingInnovationUsed',
    'gnssElapsedRealtimeComparisonUsed',
    'alignmentStationarityAssumed',
  ]) {
    result[key] = true;
  }
  for (final String key in <String>[
    'deniedGnssAvailableToEstimator',
    'deniedGnssUsedByEstimator',
    'deniedGnssUsedByHeading',
    'deniedGnssUsedByPdr',
    'deniedGnssUsedByQualityEngine',
    'deniedGnssUsedByController',
    'preGateGnssFixAcceptedForRecovery',
    'gnssBearingUsedForRecovery',
    'protectedGroundTruthAccessed',
    'rfInterferenceUsed',
    'gnssSpoofingUsed',
    'fullFlowAccuracyValidated',
    'gnssRecoveryAccuracyValidated',
    'gnssAccuracyThresholdValidated',
    'fusionAccuracyValidated',
    'qualityThresholdsValidated',
    'noiseParametersValidated',
    'stepDetectionAccuracyValidated',
    'stepLengthValidated',
    'headingAccuracyValidated',
    'trueNorthAccuracyValidated',
    'arcorePositionAccuracyValidated',
    'alignmentStationarityValidated',
    'arcoreFrameTimestampUsedForFusionOrdering',
    'unsupportedCrossClockComparisonUsed',
    'rawGnssCoordinatesReturned',
    'rawGnssFixesReturned',
    'rawSensorSamplesReturned',
    'rawArcorePosesReturned',
    'rawTrajectoryReturned',
    'rawTimestampsReturned',
    'cameraImagesReturned',
    'persistenceUsed',
  ]) {
    result[key] = false;
  }
  return result;
}
