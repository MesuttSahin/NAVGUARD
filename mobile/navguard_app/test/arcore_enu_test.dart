import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:navguard/navigation/arcore_enu.dart';

void main() {
  group('ARCore-to-ENU reference math', () {
    const List<double> identity = <double>[
      1.0,
      0.0,
      0.0,
      0.0,
      1.0,
      0.0,
      0.0,
      0.0,
      1.0,
    ];

    test('identity matrix leaves a vector unchanged', () {
      expect(multiplyMatrix3Vector(identity, <double>[1.0, 2.0, 3.0]), <double>[
        1.0,
        2.0,
        3.0,
      ]);
      expect(multiplyMatrix3(identity, identity), identity);
    });

    test('maps device +Y displacement to true north', () {
      final EnuVector result = transformRelativeDeviceDisplacementToEnu(
        enuFromInitialDeviceRotation: identity,
        relativeDeviceDisplacementM: <double>[0.0, 5.0, 0.0],
      );
      expect(result.eastM, closeTo(0.0, 1e-12));
      expect(result.northM, closeTo(5.0, 1e-12));
      expect(result.upM, closeTo(0.0, 1e-12));
    });

    test('maps device +X displacement to true east', () {
      final EnuVector result = transformRelativeDeviceDisplacementToEnu(
        enuFromInitialDeviceRotation: identity,
        relativeDeviceDisplacementM: <double>[5.0, 0.0, 0.0],
      );
      expect(result.eastM, closeTo(5.0, 1e-12));
      expect(result.northM, closeTo(0.0, 1e-12));
      expect(result.upM, closeTo(0.0, 1e-12));
    });

    test('maps device +Z displacement to true up', () {
      final EnuVector result = transformRelativeDeviceDisplacementToEnu(
        enuFromInitialDeviceRotation: identity,
        relativeDeviceDisplacementM: <double>[0.0, 0.0, 2.0],
      );
      expect(result.eastM, closeTo(0.0, 1e-12));
      expect(result.northM, closeTo(0.0, 1e-12));
      expect(result.upM, closeTo(2.0, 1e-12));
    });

    test('90-degree initial heading maps device +Y to east', () {
      final EnuVector result = transformRelativeDeviceDisplacementToEnu(
        enuFromInitialDeviceRotation: createDeclinationCorrectionMatrix(
          math.pi / 2.0,
        ),
        relativeDeviceDisplacementM: <double>[0.0, 5.0, 0.0],
      );
      expect(result.eastM, closeTo(5.0, 1e-12));
      expect(result.northM, closeTo(0.0, 1e-12));
    });

    test('declination correction preserves heading plus declination sign', () {
      const double magneticHeading = 0.4;
      const double declination = -0.15;
      final List<double> magneticRotation = createDeclinationCorrectionMatrix(
        magneticHeading,
      );
      final List<double> trueRotation = magneticDeviceRotationToTrueEnu(
        magneticDeviceRotation: magneticRotation,
        declinationRad: declination,
      );
      final List<double> topEdge = multiplyMatrix3Vector(trueRotation, <double>[
        0.0,
        1.0,
        0.0,
      ]);
      final double resultingHeading = math.atan2(topEdge[0], topEdge[1]);
      expect(resultingHeading, closeTo(magneticHeading + declination, 1e-12));
    });

    test('rejects invalid dimensions and non-finite math inputs', () {
      expect(
        () => multiplyMatrix3Vector(<double>[1.0], <double>[1.0, 2.0, 3.0]),
        throwsFormatException,
      );
      expect(
        () => multiplyMatrix3Vector(identity, <double>[1.0, 2.0]),
        throwsFormatException,
      );
      expect(
        () => multiplyMatrix3(<double>[...identity, 1.0], identity),
        throwsFormatException,
      );
      expect(
        () => multiplyMatrix3Vector(
          <double>[...identity.take(8), double.nan],
          <double>[1.0, 2.0, 3.0],
        ),
        throwsFormatException,
      );
      expect(
        () => createDeclinationCorrectionMatrix(double.infinity),
        throwsFormatException,
      );
    });
  });

  group('ARCore-to-ENU preflight contract', () {
    test('accepts a fully ready preflight', () {
      final ArCoreEnuPreflight preflight = ArCoreEnuPreflight.fromPlatform(
        _preflight(),
      );
      expect(preflight.nativeReady, isTrue);
      expect(preflight.rotationVectorName, 'Rotation Vector');
    });

    test('accepts every deterministic not-ready prerequisite', () {
      final List<Map<String, Object?>> cases = <Map<String, Object?>>[
        _preflight(
          arCoreSupported: false,
          arCoreInstalled: false,
          nativeReady: false,
        ),
        _preflight(arCoreInstalled: false, nativeReady: false),
        _preflight(cameraPermissionGranted: false, nativeReady: false),
        _preflight(
          rotationVectorAvailable: false,
          rotationVectorName: null,
          nativeReady: false,
        ),
        _preflight(diagnosticRunning: true, nativeReady: false),
      ];

      for (final Map<String, Object?> value in cases) {
        expect(ArCoreEnuPreflight.fromPlatform(value).nativeReady, isFalse);
      }
    });

    test('rejects malformed identity, names, availability, and readiness', () {
      _expectMutationsRejected(_preflight(), <String, Object?>{
        'schemaVersion': 2,
        'snapshotKind': 'wrong',
        'rotationVectorName': null,
        'nativeReady': false,
      }, ArCoreEnuPreflight.fromPlatform);
      expect(
        () => ArCoreEnuPreflight.fromPlatform(
          _preflight(arCoreSupported: false, arCoreInstalled: true),
        ),
        throwsFormatException,
      );
    });
  });

  group('ARCore-to-ENU result contract', () {
    test('accepts a zero-motion result with no timing deltas', () {
      final ArCoreEnuDiagnosticResult result =
          ArCoreEnuDiagnosticResult.fromPlatform(_zeroMotionResult());
      expect(result.finalEastM, 0.0);
      expect(result.finalNorthM, 0.0);
      expect(result.finalUpM, 0.0);
      expect(result.deltaCount, 0);
      expect(result.medianFrameDeltaMs, isNull);
    });

    test('accepts a nonzero local ENU result with aggregate timing', () {
      final ArCoreEnuDiagnosticResult result =
          ArCoreEnuDiagnosticResult.fromPlatform(_motionResult());
      expect(result.finalEastM, 3.0);
      expect(result.finalNorthM, 4.0);
      expect(result.finalUpM, 12.0);
      expect(result.finalHorizontalDisplacementM, 5.0);
      expect(result.final3dDisplacementM, 13.0);
      expect(result.trackingFraction, 0.75);
    });

    test('rejects wrong architecture and timestamp contract values', () {
      _expectMutationsRejected(_motionResult(), <String, Object?>{
        'schemaVersion': 2,
        'snapshotKind': 'wrong',
        'success': false,
        'alignmentHoldMs': 1999,
        'measurementWindowMs': 29999,
        'coordinateFrame': 'arcore_world',
        'arcorePoseSource': 'Camera.getDisplayOrientedPose',
        'referenceStrategy': 'saved_world_translation',
        'relativePoseStrategy': 'translation_subtraction',
        'enuAlignmentSource': 'camera_forward',
        'rotationVectorSource': 'TYPE_GAME_ROTATION_VECTOR',
        'rotationVectorTimestampAuthority': 'Frame.getTimestamp',
        'arFrameTimestampAuthority': 'SensorEvent.timestamp',
        'arFrameTimestampTimeBase': 'android_sensor_epoch',
        'operationWindowClock': 'System.currentTimeMillis',
        'crossClockTimestampComparisonUsed': true,
      }, ArCoreEnuDiagnosticResult.fromPlatform);
    });

    test('rejects false alignment claims and live GNSS', () {
      _expectMutationsRejected(_motionResult(), <String, Object?>{
        'alignmentCompleted': false,
        'alignmentStationarityAssumed': false,
        'alignmentStationarityValidated': true,
        'trueNorthAlignmentUsed': false,
        'anchorUsedForDeclination': false,
        'liveGnssUsed': true,
        'declinationModelFreshnessValidated': true,
        'declinationAltitudeSource': 'live_gnss_altitude',
      }, ArCoreEnuDiagnosticResult.fromPlatform);
    });

    test('rejects non-finite declination and wrong declination identity', () {
      _expectMutationsRejected(_motionResult(), <String, Object?>{
        'declinationRad': double.nan,
        'declinationProvider': 'cloud_service',
        'declinationModelVersion': 'WMM2025',
      }, ArCoreEnuDiagnosticResult.fromPlatform);
    });

    test('rejects negative and inconsistent rotation counters', () {
      _expectMutationsRejected(_motionResult(), <String, Object?>{
        'rotationVectorUpdateCount': -1,
        'validRotationVectorSampleCount': 0,
        'invalidRotationVectorSampleCount': 2,
        'uniqueRotationVectorTimestampCount': 4,
        'duplicateRotationVectorTimestampCount': 2,
        'nonMonotonicRotationVectorTimestampCount': 2,
      }, ArCoreEnuDiagnosticResult.fromPlatform);
    });

    test('rejects negative and inconsistent ARCore counters', () {
      _expectMutationsRejected(_motionResult(), <String, Object?>{
        'arFrameUpdateCount': -1,
        'trackingFrameCount': 5,
        'pausedFrameCount': 2,
        'stoppedFrameCount': 1,
        'usableEnuFrameCount': 4,
        'uniqueArFrameTimestampCount': 5,
        'duplicateArFrameTimestampCount': 4,
        'nonMonotonicArFrameTimestampCount': 4,
        'deltaCount': 2,
      }, ArCoreEnuDiagnosticResult.fromPlatform);
    });

    test('rejects invalid tracking fractions', () {
      for (final Object value in <Object>[-0.1, 1.1, double.nan, 0.5]) {
        expect(
          () => ArCoreEnuDiagnosticResult.fromPlatform(<String, Object?>{
            ..._motionResult(),
            'trackingFraction': value,
          }),
          throwsFormatException,
        );
      }
    });

    test('rejects incomplete or inconsistent frame timing aggregates', () {
      _expectMutationsRejected(_motionResult(), <String, Object?>{
        'minFrameDeltaMs': null,
        'maxFrameDeltaMs': -1.0,
        'meanFrameDeltaMs': 41.0,
        'medianFrameDeltaMs': 20.0,
        'p95FrameDeltaMs': 50.0,
        'observedTrackingFrameRateHz': double.infinity,
        'trackingFractionDenominator': 'tracking_frames',
      }, ArCoreEnuDiagnosticResult.fromPlatform);
      expect(
        () => ArCoreEnuDiagnosticResult.fromPlatform(<String, Object?>{
          ..._zeroMotionResult(),
          'minFrameDeltaMs': 33.0,
        }),
        throwsFormatException,
      );
    });

    test('rejects non-finite position components', () {
      _expectMutationsRejected(_motionResult(), <String, Object?>{
        'finalEastM': double.nan,
        'finalNorthM': double.infinity,
        'finalUpM': double.negativeInfinity,
      }, ArCoreEnuDiagnosticResult.fromPlatform);
    });

    test('rejects position norms and excursion inconsistencies', () {
      _expectMutationsRejected(_motionResult(), <String, Object?>{
        'finalHorizontalDisplacementM': 4.9,
        'final3dDisplacementM': 12.9,
        'maxHorizontalDisplacementM': 4.0,
        'maxAbsUpM': 11.0,
      }, ArCoreEnuDiagnosticResult.fromPlatform);
    });

    test('rejects implementation underclaims and forbidden overclaims', () {
      _expectMutationsRejected(_motionResult(), <String, Object?>{
        'arcoreRelativeMotionImplemented': false,
        'arcoreToEnuImplemented': false,
        'arcorePositionAccuracyValidated': true,
        'arcoreDistanceAccuracyValidated': true,
        'enuAlignmentAccuracyValidated': true,
        'headingAccuracyValidated': true,
        'trueNorthAccuracyValidated': true,
        'pdrFusionImplemented': true,
        'qualityEngineImplemented': true,
        'ekfImplemented': true,
        'groundTruthFirewallImplemented': true,
        'gnssDeniedNavigationImplemented': true,
      }, ArCoreEnuDiagnosticResult.fromPlatform);
    });

    test('rejects privacy, frame, persistence, and cloud overclaims', () {
      _expectMutationsRejected(_motionResult(), <String, Object?>{
        'rawTrajectoryReturned': true,
        'rawArcorePosesReturned': true,
        'rawRotationVectorSamplesReturned': true,
        'rawTimestampsReturned': true,
        'cameraImagesReturned': true,
        'persistenceUsed': true,
        'pathLengthCalculated': true,
        'displayRotationRemappingUsed': true,
        'cameraOpticalForwardUsed': true,
        'geospatialApiUsed': true,
        'cloudServiceUsed': true,
      }, ArCoreEnuDiagnosticResult.fromPlatform);
    });
  });
}

Map<String, Object?> _preflight({
  bool arCoreSupported = true,
  bool arCoreInstalled = true,
  bool cameraPermissionGranted = true,
  bool rotationVectorAvailable = true,
  String? rotationVectorName = 'Rotation Vector',
  bool diagnosticRunning = false,
  bool nativeReady = true,
}) => <String, Object?>{
  'schemaVersion': 1,
  'snapshotKind': 'arcore_enu_preflight',
  'arCoreSupported': arCoreSupported,
  'arCoreInstalled': arCoreInstalled,
  'cameraPermissionGranted': cameraPermissionGranted,
  'rotationVectorAvailable': rotationVectorAvailable,
  'rotationVectorName': rotationVectorName,
  'diagnosticRunning': diagnosticRunning,
  'nativeReady': nativeReady,
};

Map<String, Object?> _baseResult() => <String, Object?>{
  'schemaVersion': 1,
  'snapshotKind': 'arcore_enu_diagnostic_result',
  'success': true,
  'alignmentHoldMs': 2000,
  'measurementWindowMs': 30000,
  'coordinateFrame': 'local_enu',
  'arcorePoseSource': 'Frame.getAndroidSensorPose',
  'referenceStrategy': 'local_arcore_anchor',
  'relativePoseStrategy': 'anchor_inverse_compose_android_sensor_pose',
  'enuAlignmentSource': 'rotation_vector_plus_geomagnetic_declination',
  'rotationVectorSource': 'TYPE_ROTATION_VECTOR',
  'rotationVectorTimestampAuthority': 'SensorEvent.timestamp',
  'arFrameTimestampAuthority': 'Frame.getTimestamp',
  'arFrameTimestampTimeBase': 'undefined_by_arcore_api',
  'operationWindowClock': 'SystemClock.elapsedRealtimeNanos',
  'crossClockTimestampComparisonUsed': false,
  'alignmentCompleted': true,
  'alignmentStationarityAssumed': true,
  'alignmentStationarityValidated': false,
  'trueNorthAlignmentUsed': true,
  'anchorUsedForDeclination': true,
  'liveGnssUsed': false,
  'declinationRad': 0.1,
  'declinationProvider': 'android.hardware.GeomagneticField',
  'declinationModelVersion': 'platform_managed',
  'declinationModelFreshnessValidated': false,
  'declinationAltitudeSource': 'anchor_ellipsoid_altitude',
  'rotationVectorUpdateCount': 5,
  'validRotationVectorSampleCount': 5,
  'invalidRotationVectorSampleCount': 0,
  'uniqueRotationVectorTimestampCount': 5,
  'duplicateRotationVectorTimestampCount': 0,
  'nonMonotonicRotationVectorTimestampCount': 0,
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

Map<String, Object?> _zeroMotionResult() => <String, Object?>{
  ..._baseResult(),
  'arFrameUpdateCount': 1,
  'trackingFrameCount': 1,
  'pausedFrameCount': 0,
  'stoppedFrameCount': 0,
  'usableEnuFrameCount': 1,
  'uniqueArFrameTimestampCount': 1,
  'duplicateArFrameTimestampCount': 0,
  'nonMonotonicArFrameTimestampCount': 0,
  'deltaCount': 0,
  'minFrameDeltaMs': null,
  'maxFrameDeltaMs': null,
  'meanFrameDeltaMs': null,
  'medianFrameDeltaMs': null,
  'p95FrameDeltaMs': null,
  'observedTrackingFrameRateHz': null,
  'trackingFraction': 1.0,
  'trackingFractionDenominator': 'arFrameUpdateCount_formal_window',
  'finalEastM': 0.0,
  'finalNorthM': 0.0,
  'finalUpM': 0.0,
  'finalHorizontalDisplacementM': 0.0,
  'final3dDisplacementM': 0.0,
  'maxHorizontalDisplacementM': 0.0,
  'maxAbsUpM': 0.0,
};

Map<String, Object?> _motionResult() => <String, Object?>{
  ..._baseResult(),
  'arFrameUpdateCount': 4,
  'trackingFrameCount': 3,
  'pausedFrameCount': 1,
  'stoppedFrameCount': 0,
  'usableEnuFrameCount': 3,
  'uniqueArFrameTimestampCount': 4,
  'duplicateArFrameTimestampCount': 0,
  'nonMonotonicArFrameTimestampCount': 0,
  'deltaCount': 3,
  'minFrameDeltaMs': 30.0,
  'maxFrameDeltaMs': 40.0,
  'meanFrameDeltaMs': 33.0,
  'medianFrameDeltaMs': 32.0,
  'p95FrameDeltaMs': 40.0,
  'observedTrackingFrameRateHz': 1000.0 / 33.0,
  'trackingFraction': 0.75,
  'trackingFractionDenominator': 'arFrameUpdateCount_formal_window',
  'finalEastM': 3.0,
  'finalNorthM': 4.0,
  'finalUpM': 12.0,
  'finalHorizontalDisplacementM': 5.0,
  'final3dDisplacementM': 13.0,
  'maxHorizontalDisplacementM': 6.0,
  'maxAbsUpM': 12.0,
};

void _expectMutationsRejected(
  Map<String, Object?> base,
  Map<String, Object?> mutations,
  Object Function(Object?) parser,
) {
  for (final MapEntry<String, Object?> mutation in mutations.entries) {
    expect(
      () => parser(<String, Object?>{...base, mutation.key: mutation.value}),
      throwsFormatException,
      reason: mutation.key,
    );
  }
}
