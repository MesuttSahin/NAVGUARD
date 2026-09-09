import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:navguard/navigation/baseline_pdr.dart';

void main() {
  group('baseline PDR reference math', () {
    test('uses the frozen 0.75 m cardinal equations', () {
      final Map<double, List<double>> cases = <double, List<double>>{
        0.0: <double>[0.0, 0.75],
        math.pi / 2.0: <double>[0.75, 0.0],
        math.pi: <double>[0.0, -0.75],
        3.0 * math.pi / 2.0: <double>[-0.75, 0.0],
      };

      for (final MapEntry<double, List<double>> entry in cases.entries) {
        final PdrStepDelta delta = computeBaselinePdrStepDelta(
          headingRad: entry.key,
        );
        expect(delta.eastM, closeTo(entry.value[0], 1e-12));
        expect(delta.northM, closeTo(entry.value[1], 1e-12));
      }
    });

    test('computes a diagonal step without changing the fixed length', () {
      final PdrStepDelta delta = computeBaselinePdrStepDelta(
        headingRad: math.pi / 4.0,
      );
      final double component = 0.75 / math.sqrt(2.0);

      expect(delta.eastM, closeTo(component, 1e-12));
      expect(delta.northM, closeTo(component, 1e-12));
      expect(
        math.sqrt((delta.eastM * delta.eastM) + (delta.northM * delta.northM)),
        closeTo(0.75, 1e-12),
      );
    });

    test('integrates ten north steps to N = 7.5 m', () {
      final BaselinePdrPosition position = integrateBaselinePdrHeadings(
        List<double>.filled(10, 0.0),
      );

      expect(position.eastM, closeTo(0.0, 1e-12));
      expect(position.northM, closeTo(7.5, 1e-12));
      expect(position.nominalIntegratedPathLengthM, 7.5);
    });

    test('integrates ten east steps to E = 7.5 m', () {
      final BaselinePdrPosition position = integrateBaselinePdrHeadings(
        List<double>.filled(10, math.pi / 2.0),
      );

      expect(position.eastM, closeTo(7.5, 1e-12));
      expect(position.northM, closeTo(0.0, 1e-12));
      expect(position.nominalIntegratedPathLengthM, 7.5);
    });

    test('integrates the synthetic L path in local ENU', () {
      final BaselinePdrPosition position = integrateBaselinePdrHeadings(
        <double>[
          ...List<double>.filled(10, 0.0),
          ...List<double>.filled(10, math.pi / 2.0),
        ],
      );

      expect(position.eastM, closeTo(7.5, 1e-12));
      expect(position.northM, closeTo(7.5, 1e-12));
      expect(position.integratedStepCount, 20);
      expect(position.nominalIntegratedPathLengthM, 15.0);
      expect(position.netDisplacementM, closeTo(math.sqrt(112.5), 1e-12));
    });

    test('rejects non-finite or negative pure-math inputs', () {
      expect(
        () => computeBaselinePdrStepDelta(headingRad: double.nan),
        throwsFormatException,
      );
      expect(
        () => computeBaselinePdrStepDelta(headingRad: 0.0, stepLengthM: -0.1),
        throwsFormatException,
      );
    });
  });

  group('baseline PDR preflight contract', () {
    test('accepts both sensors with satisfied permission', () {
      final BaselinePdrPreflight preflight = BaselinePdrPreflight.fromPlatform(
        _preflight(),
      );

      expect(preflight.rotationVectorAvailable, isTrue);
      expect(preflight.stepDetectorAvailable, isTrue);
      expect(preflight.nativeSensorsReady, isTrue);
    });

    test('accepts each deterministic not-ready condition', () {
      final List<Map<String, Object?>> cases = <Map<String, Object?>>[
        _preflight(
          rotationVectorAvailable: false,
          rotationVectorName: null,
          nativeSensorsReady: false,
        ),
        _preflight(
          stepDetectorAvailable: false,
          stepDetectorName: null,
          nativeSensorsReady: false,
        ),
        _preflight(permissionGranted: false, nativeSensorsReady: false),
        _preflight(diagnosticRunning: true, nativeSensorsReady: false),
      ];

      for (final Map<String, Object?> value in cases) {
        expect(
          BaselinePdrPreflight.fromPlatform(value).nativeSensorsReady,
          isFalse,
        );
      }
    });

    test('rejects wrong schema, kind, names, and readiness', () {
      final List<Map<String, Object?>> invalid = <Map<String, Object?>>[
        <String, Object?>{..._preflight(), 'schemaVersion': 2},
        <String, Object?>{..._preflight(), 'snapshotKind': 'wrong'},
        <String, Object?>{..._preflight(), 'rotationVectorName': null},
        <String, Object?>{..._preflight(), 'stepDetectorName': null},
        <String, Object?>{..._preflight(), 'nativeSensorsReady': false},
      ];

      for (final Map<String, Object?> value in invalid) {
        expect(
          () => BaselinePdrPreflight.fromPlatform(value),
          throwsFormatException,
        );
      }
    });
  });

  group('baseline PDR result contract', () {
    test('accepts a valid zero-step result with null association ages', () {
      final BaselinePdrDiagnosticResult result =
          BaselinePdrDiagnosticResult.fromPlatform(_zeroResult());

      expect(result.integratedStepCount, 0);
      expect(result.finalEastM, 0.0);
      expect(result.finalNorthM, 0.0);
      expect(result.medianHeadingAssociationAgeMs, isNull);
    });

    test('accepts a valid straight synthetic result', () {
      final BaselinePdrDiagnosticResult result =
          BaselinePdrDiagnosticResult.fromPlatform(_straightResult());

      expect(result.integratedStepCount, 2);
      expect(result.finalNorthM, 1.5);
      expect(result.nominalIntegratedPathLengthM, 1.5);
    });

    test('accepts a multi-direction result with association ages', () {
      final double net = math.sqrt(1.125);
      final Map<String, Object?> value = <String, Object?>{
        ..._straightResult(),
        'finalEastM': 0.75,
        'finalNorthM': 0.75,
        'netDisplacementM': net,
        'minHeadingAssociationAgeMs': 2.0,
        'maxHeadingAssociationAgeMs': 12.0,
        'meanHeadingAssociationAgeMs': 7.0,
        'medianHeadingAssociationAgeMs': 7.0,
        'p95HeadingAssociationAgeMs': 12.0,
      };

      final BaselinePdrDiagnosticResult result =
          BaselinePdrDiagnosticResult.fromPlatform(value);
      expect(result.netDisplacementM, closeTo(net, 1e-12));
    });

    test('rejects wrong fixed identity and timing metadata', () {
      final Map<String, Object?> base = _zeroResult();
      final Map<String, Object?> mutations = <String, Object?>{
        'schemaVersion': 2,
        'snapshotKind': 'wrong',
        'success': false,
        'sessionDurationMs': 10,
        'coordinateFrame': 'latitude_longitude',
        'headingConvention': 'counterclockwise',
        'deviceForwardAxis': 'device_positive_x',
        'stepSource': 'TYPE_STEP_COUNTER',
        'headingSource': 'TYPE_GAME_ROTATION_VECTOR',
        'stepTimestampAuthority': 'System.currentTimeMillis',
        'headingTimestampAuthority': 'callback_arrival_order',
        'operationWindowClock': 'System.currentTimeMillis',
        'wallClockUsedForSensorTiming': true,
        'headingAssociationPolicy': 'absolute_nearest_heading',
        'futureHeadingUsed': true,
      };

      _expectMutationsRejected(base, mutations);
    });

    test('rejects negative or inconsistent step counters', () {
      final Map<String, Object?> base = _straightResult();
      _expectMutationsRejected(base, <String, Object?>{
        'stepUpdateCount': -1,
        'acceptedStepEventCount': 3,
        'uniqueStepTimestampCount': 1,
        'associatedStepCount': 1,
        'unassociatedStepCount': 1,
        'integratedStepCount': 1,
      });
    });

    test('rejects negative or inconsistent heading counters', () {
      final Map<String, Object?> base = _straightResult();
      _expectMutationsRejected(base, <String, Object?>{
        'headingUpdateCount': -1,
        'validHeadingSampleCount': 4,
        'invalidHeadingSampleCount': 1,
        'uniqueHeadingTimestampCount': 4,
        'duplicateHeadingTimestampCount': 1,
        'nonMonotonicHeadingTimestampCount': 1,
      });
    });

    test('rejects invalid association age nullability and ordering', () {
      final Map<String, Object?> base = _straightResult();
      _expectMutationsRejected(base, <String, Object?>{
        'minHeadingAssociationAgeMs': null,
        'maxHeadingAssociationAgeMs': -1.0,
        'meanHeadingAssociationAgeMs': 30.0,
        'medianHeadingAssociationAgeMs': 30.0,
        'p95HeadingAssociationAgeMs': 30.0,
      });

      expect(
        () => BaselinePdrDiagnosticResult.fromPlatform(<String, Object?>{
          ..._zeroResult(),
          'minHeadingAssociationAgeMs': 0.0,
        }),
        throwsFormatException,
      );
    });

    test('rejects wrong step model, calibration, or validation', () {
      _expectMutationsRejected(_zeroResult(), <String, Object?>{
        'stepLengthModel': 'adaptive',
        'stepLengthM': 0.8,
        'stepLengthCalibrated': true,
        'stepLengthValidated': true,
      });
    });

    test('rejects invalid origins, final coordinates, and distances', () {
      final Map<String, Object?> base = _straightResult();
      _expectMutationsRejected(base, <String, Object?>{
        'originEastM': 1.0,
        'originNorthM': 1.0,
        'finalEastM': double.nan,
        'finalNorthM': double.infinity,
        'netDisplacementM': 2.0,
        'nominalIntegratedPathLengthM': 2.0,
      });

      final Map<String, Object?> impossible = <String, Object?>{
        ..._straightResult(),
        'finalEastM': 2.0,
        'finalNorthM': 0.0,
        'netDisplacementM': 2.0,
      };
      expect(
        () => BaselinePdrDiagnosticResult.fromPlatform(impossible),
        throwsFormatException,
      );
    });

    test('rejects invalid declination metadata', () {
      _expectMutationsRejected(_zeroResult(), <String, Object?>{
        'declinationRad': double.nan,
        'declinationProvider': 'WMM2025',
        'declinationModelVersion': 'WMM2025',
        'declinationModelFreshnessValidated': true,
        'declinationAltitudeSource': 'fabricated_altitude',
      });
    });

    test('rejects overclaimed research and implementation flags', () {
      final Map<String, Object?> base = _zeroResult();
      for (final String key in <String>[
        'stepDetectionAccuracyValidated',
        'stepLengthValidated',
        'headingAccuracyValidated',
        'trueNorthAccuracyValidated',
        'distanceAccuracyValidated',
        'bodyHeadingImplemented',
        'arCoreFusionImplemented',
        'qualityEngineImplemented',
        'ekfImplemented',
        'groundTruthFirewallImplemented',
        'gnssDeniedNavigationImplemented',
      ]) {
        expect(
          () => BaselinePdrDiagnosticResult.fromPlatform(<String, Object?>{
            ...base,
            key: true,
          }),
          throwsFormatException,
          reason: key,
        );
      }
      _expectMutationsRejected(base, <String, Object?>{
        'pdrPositionImplemented': false,
        'anchorUsedForDeclination': false,
      });
    });

    test('rejects raw-data, persistence, and live-GNSS claims', () {
      final Map<String, Object?> base = _zeroResult();
      for (final String key in <String>[
        'rawTrajectoryReturned',
        'rawSensorSamplesReturned',
        'rawTimestampsReturned',
        'persistenceUsed',
        'liveGnssUsed',
      ]) {
        expect(
          () => BaselinePdrDiagnosticResult.fromPlatform(<String, Object?>{
            ...base,
            key: true,
          }),
          throwsFormatException,
          reason: key,
        );
      }
    });
  });
}

Map<String, Object?> _preflight({
  bool rotationVectorAvailable = true,
  String? rotationVectorName = 'Rotation Vector Non-wakeup',
  bool stepDetectorAvailable = true,
  String? stepDetectorName = 'pedometer  Non-wakeup',
  bool permissionGranted = true,
  bool diagnosticRunning = false,
  bool nativeSensorsReady = true,
}) {
  return <String, Object?>{
    'schemaVersion': 1,
    'snapshotKind': 'baseline_pdr_preflight',
    'rotationVectorAvailable': rotationVectorAvailable,
    'rotationVectorName': rotationVectorName,
    'stepDetectorAvailable': stepDetectorAvailable,
    'stepDetectorName': stepDetectorName,
    'activityRecognitionPermissionRequired': true,
    'activityRecognitionPermissionGranted': permissionGranted,
    'diagnosticRunning': diagnosticRunning,
    'nativeSensorsReady': nativeSensorsReady,
  };
}

Map<String, Object?> _zeroResult() {
  return <String, Object?>{
    'schemaVersion': 1,
    'snapshotKind': 'baseline_pdr_diagnostic_result',
    'success': true,
    'sessionDurationMs': 30000,
    'coordinateFrame': 'local_enu',
    'headingConvention': 'clockwise_from_north_0_to_2pi',
    'deviceForwardAxis': 'device_positive_y_top_edge',
    'stepSource': 'TYPE_STEP_DETECTOR',
    'headingSource': 'TYPE_ROTATION_VECTOR',
    'stepSensorName': 'pedometer  Non-wakeup',
    'headingSensorName': 'Rotation Vector Non-wakeup',
    'stepTimestampAuthority': 'SensorEvent.timestamp',
    'headingTimestampAuthority': 'SensorEvent.timestamp',
    'operationWindowClock': 'SystemClock.elapsedRealtimeNanos',
    'wallClockUsedForSensorTiming': false,
    'headingAssociationPolicy':
        'latest_valid_heading_at_or_before_step_timestamp',
    'futureHeadingUsed': false,
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
    'minHeadingAssociationAgeMs': null,
    'maxHeadingAssociationAgeMs': null,
    'meanHeadingAssociationAgeMs': null,
    'medianHeadingAssociationAgeMs': null,
    'p95HeadingAssociationAgeMs': null,
    'stepLengthModel': 'fixed_baseline',
    'stepLengthM': 0.75,
    'stepLengthCalibrated': false,
    'stepLengthValidated': false,
    'originEastM': 0.0,
    'originNorthM': 0.0,
    'finalEastM': 0.0,
    'finalNorthM': 0.0,
    'netDisplacementM': 0.0,
    'nominalIntegratedPathLengthM': 0.0,
    'declinationRad': 0.1,
    'declinationProvider': 'android.hardware.GeomagneticField',
    'declinationModelVersion': 'platform_managed',
    'declinationModelFreshnessValidated': false,
    'declinationAltitudeSource': 'anchor_ellipsoid_altitude',
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

Map<String, Object?> _straightResult() {
  return <String, Object?>{
    ..._zeroResult(),
    'stepUpdateCount': 2,
    'acceptedStepEventCount': 2,
    'uniqueStepTimestampCount': 2,
    'associatedStepCount': 2,
    'integratedStepCount': 2,
    'minHeadingAssociationAgeMs': 0.0,
    'maxHeadingAssociationAgeMs': 20.0,
    'meanHeadingAssociationAgeMs': 10.0,
    'medianHeadingAssociationAgeMs': 10.0,
    'p95HeadingAssociationAgeMs': 20.0,
    'finalNorthM': 1.5,
    'netDisplacementM': 1.5,
    'nominalIntegratedPathLengthM': 1.5,
  };
}

void _expectMutationsRejected(
  Map<String, Object?> base,
  Map<String, Object?> mutations,
) {
  for (final MapEntry<String, Object?> mutation in mutations.entries) {
    expect(
      () => BaselinePdrDiagnosticResult.fromPlatform(<String, Object?>{
        ...base,
        mutation.key: mutation.value,
      }),
      throwsFormatException,
      reason: mutation.key,
    );
  }
}
