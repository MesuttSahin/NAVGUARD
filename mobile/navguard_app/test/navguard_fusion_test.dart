import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:navguard/navigation/navguard_fusion.dart';

void main() {
  group('NAVGUARD Config D EKF', () {
    test('one north-facing step advances north by 0.75 m', () {
      final NavguardFusionEstimate result = navguardStepPredict(
        NavguardFusionEstimate.initial(0),
        quality: NavguardQuality.usable,
      );
      expect(result.eastM, closeTo(0, 1e-12));
      expect(result.northM, closeTo(0.75, 1e-12));
      expect(result.headingRad, closeTo(0, 1e-12));
    });

    test('one east-facing step advances east by 0.75 m', () {
      final NavguardFusionEstimate result = navguardStepPredict(
        NavguardFusionEstimate.initial(math.pi / 2),
        quality: NavguardQuality.usable,
      );
      expect(result.eastM, closeTo(0.75, 1e-12));
      expect(result.northM, closeTo(0, 1e-12));
    });

    test('heading innovation wraps 359 to 1 degrees forward', () {
      final double innovation = navguardCircularDifference(
        _radians(1),
        _radians(359),
      );
      expect(innovation, closeTo(_radians(2), 1e-12));
    });

    test('heading innovation wraps 1 to 359 degrees backward', () {
      final double innovation = navguardCircularDifference(
        _radians(359),
        _radians(1),
      );
      expect(innovation, closeTo(_radians(-2), 1e-12));
    });

    test('ARCore correction moves state toward measurement', () {
      final NavguardFusionEstimate predicted = NavguardFusionEstimate(
        eastM: 4,
        northM: -2,
        headingRad: 0,
        covariance: NavguardMatrix3.diagonal(1, 1, 0.2),
      );
      final NavguardMeasurementUpdate result = navguardArcorePositionUpdate(
        predicted,
        measuredEastM: 1,
        measuredNorthM: 1,
        quality: NavguardQuality.good,
      );
      expect(result.estimate.eastM, inExclusiveRange(1, 4));
      expect(result.estimate.northM, inExclusiveRange(-2, 1));
      expect(result.estimate.covariance.at(0, 0), lessThanOrEqualTo(1));
      expect(result.estimate.covariance.at(1, 1), lessThanOrEqualTo(1));
    });

    test('Joseph updates preserve finite symmetric covariance', () {
      NavguardFusionEstimate estimate = NavguardFusionEstimate.initial(6.2);
      estimate = navguardStepPredict(
        estimate,
        quality: NavguardQuality.degraded,
      );
      estimate = navguardHeadingUpdate(
        estimate,
        measuredHeadingRad: 0.05,
        quality: NavguardQuality.good,
      ).estimate;
      estimate = navguardArcorePositionUpdate(
        estimate,
        measuredEastM: 0.2,
        measuredNorthM: 0.6,
        quality: NavguardQuality.usable,
      ).estimate;
      expect(estimate.covariance.isApproximatelySymmetric, isTrue);
      for (final double value in estimate.covariance.values) {
        expect(value.isFinite, isTrue);
      }
      expect(estimate.covariance.at(0, 0), greaterThanOrEqualTo(0));
      expect(estimate.covariance.at(1, 1), greaterThanOrEqualTo(0));
      expect(estimate.covariance.at(2, 2), greaterThanOrEqualTo(0));
    });
  });

  group('NAVGUARD quality boundaries', () {
    test('heading uses exact 15, 30, and 45 degree boundaries', () {
      NavguardQuality classify(double degrees) => classifyHeadingQuality(
        sensorAvailable: true,
        sampleValid: true,
        reportedAccuracyRad: _radians(degrees),
      );

      expect(classify(15), NavguardQuality.good);
      expect(classify(15.01), NavguardQuality.usable);
      expect(classify(30), NavguardQuality.usable);
      expect(classify(30.01), NavguardQuality.degraded);
      expect(classify(45), NavguardQuality.degraded);
      expect(classify(45.01), NavguardQuality.unreliable);
    });

    test('missing and -1 heading accuracy are usable', () {
      expect(
        classifyHeadingQuality(sensorAvailable: true, sampleValid: true),
        NavguardQuality.usable,
      );
      expect(
        classifyHeadingQuality(
          sensorAvailable: true,
          sampleValid: true,
          reportedAccuracyRad: -1,
        ),
        NavguardQuality.usable,
      );
    });

    test('unavailable and malformed heading samples are rejected', () {
      expect(
        classifyHeadingQuality(sensorAvailable: false, sampleValid: true),
        NavguardQuality.unavailable,
      );
      expect(
        classifyHeadingQuality(sensorAvailable: true, sampleValid: false),
        NavguardQuality.unreliable,
      );
    });

    test('PDR uses exact 50 and 150 ms boundaries and never GOOD', () {
      expect(
        classifyPdrQuality(
          headingQuality: NavguardQuality.good,
          headingAgeMs: 50,
        ),
        NavguardQuality.usable,
      );
      expect(
        classifyPdrQuality(
          headingQuality: NavguardQuality.usable,
          headingAgeMs: 50.01,
        ),
        NavguardQuality.degraded,
      );
      expect(
        classifyPdrQuality(
          headingQuality: NavguardQuality.good,
          headingAgeMs: 150,
        ),
        NavguardQuality.degraded,
      );
      expect(
        classifyPdrQuality(
          headingQuality: NavguardQuality.good,
          headingAgeMs: 150.01,
        ),
        NavguardQuality.unreliable,
      );
    });

    test('degraded and unreliable heading cap PDR quality', () {
      expect(
        classifyPdrQuality(
          headingQuality: NavguardQuality.degraded,
          headingAgeMs: 10,
        ),
        NavguardQuality.degraded,
      );
      expect(
        classifyPdrQuality(
          headingQuality: NavguardQuality.unreliable,
          headingAgeMs: 10,
        ),
        NavguardQuality.unreliable,
      );
    });

    test('ARCore uses first-event and exact gap boundaries', () {
      NavguardQuality classify({bool first = false, double? gap}) =>
          classifyArcoreQuality(
            sourceAvailable: true,
            cameraTracking: true,
            referenceTracking: true,
            sampleValid: true,
            firstUsableEvent: first,
            processingGapMs: gap,
          );

      expect(classify(first: true), NavguardQuality.usable);
      expect(classify(gap: 75), NavguardQuality.good);
      expect(classify(gap: 75.01), NavguardQuality.usable);
      expect(classify(gap: 150), NavguardQuality.usable);
      expect(classify(gap: 150.01), NavguardQuality.degraded);
      expect(classify(gap: 300), NavguardQuality.degraded);
      expect(classify(gap: 300.01), NavguardQuality.unreliable);
    });

    test('ARCore tracking loss is unavailable', () {
      expect(
        classifyArcoreQuality(
          sourceAvailable: true,
          cameraTracking: false,
          referenceTracking: true,
          sampleValid: true,
          firstUsableEvent: false,
          processingGapMs: 10,
        ),
        NavguardQuality.unavailable,
      );
    });

    test('quality multipliers are exactly 1, 2, and 6', () {
      expect(navguardQualityMultiplier(NavguardQuality.good), 1);
      expect(navguardQualityMultiplier(NavguardQuality.usable), 2);
      expect(navguardQualityMultiplier(NavguardQuality.degraded), 6);
    });

    test('unreliable, unavailable, and unknown skip EKF updates', () {
      expect(navguardQualityMultiplier(NavguardQuality.unreliable), isNull);
      expect(navguardQualityMultiplier(NavguardQuality.unavailable), isNull);
      expect(navguardQualityMultiplier(NavguardQuality.unknown), isNull);
    });
  });

  group('deterministic fusion replay helpers', () {
    test('step uses latest causal heading and never a future heading', () {
      final List<double?> associated =
          associateCausalStepHeadings(<NavguardFusionEvent>[
            const NavguardFusionEvent(
              timestampNanos: 100,
              type: NavguardFusionEventType.heading,
              insertionIndex: 0,
              headingRad: 1,
            ),
            const NavguardFusionEvent(
              timestampNanos: 120,
              type: NavguardFusionEventType.heading,
              insertionIndex: 1,
              headingRad: 2,
            ),
            const NavguardFusionEvent(
              timestampNanos: 125,
              type: NavguardFusionEventType.step,
              insertionIndex: 2,
            ),
            const NavguardFusionEvent(
              timestampNanos: 130,
              type: NavguardFusionEventType.heading,
              insertionIndex: 3,
              headingRad: 3,
            ),
          ]);
      expect(associated, <double?>[2]);
    });

    test('multiple causally associated steps are all retained', () {
      final List<double?> associated =
          associateCausalStepHeadings(<NavguardFusionEvent>[
            const NavguardFusionEvent(
              timestampNanos: 100,
              type: NavguardFusionEventType.heading,
              insertionIndex: 0,
              headingRad: 1,
            ),
            const NavguardFusionEvent(
              timestampNanos: 110,
              type: NavguardFusionEventType.step,
              insertionIndex: 1,
            ),
            const NavguardFusionEvent(
              timestampNanos: 120,
              type: NavguardFusionEventType.step,
              insertionIndex: 2,
            ),
          ]);
      expect(associated, <double?>[1, 1]);
    });

    test('equal timestamps resolve heading, step, then ARCore', () {
      final List<NavguardFusionEvent> sorted =
          sortNavguardFusionEvents(<NavguardFusionEvent>[
            const NavguardFusionEvent(
              timestampNanos: 10,
              type: NavguardFusionEventType.arcore,
              insertionIndex: 0,
            ),
            const NavguardFusionEvent(
              timestampNanos: 10,
              type: NavguardFusionEventType.step,
              insertionIndex: 1,
            ),
            const NavguardFusionEvent(
              timestampNanos: 10,
              type: NavguardFusionEventType.heading,
              insertionIndex: 2,
              headingRad: 0,
            ),
          ]);
      expect(
        sorted.map((NavguardFusionEvent event) => event.type),
        <NavguardFusionEventType>[
          NavguardFusionEventType.heading,
          NavguardFusionEventType.step,
          NavguardFusionEventType.arcore,
        ],
      );
    });
  });

  group('strict platform contract', () {
    test('preflight accepts internally consistent readiness', () {
      final NavguardFusionPreflight preflight =
          NavguardFusionPreflight.fromPlatform(<Object?, Object?>{
            'schemaVersion': 1,
            'snapshotKind': 'navguard_fusion_preflight',
            'arCoreSupported': true,
            'arCoreInstalled': true,
            'cameraPermissionGranted': true,
            'rotationVectorAvailable': true,
            'rotationVectorName': 'Rotation Vector',
            'stepDetectorAvailable': true,
            'stepDetectorName': 'Step Detector',
            'activityRecognitionPermissionGranted': true,
            'diagnosticRunning': false,
            'nativeReady': true,
          });
      expect(preflight.nativeReady, isTrue);
    });

    test('result rejects ARCore Frame timestamp fusion ordering', () {
      final Map<Object?, Object?> result = _validResult();
      result['arcoreFrameTimestampUsedForFusionOrdering'] = true;
      expect(
        () => NavguardFusionDiagnosticResult.fromPlatform(result),
        throwsFormatException,
      );
    });

    test('result requires elapsed-realtime processing-time authority', () {
      final Map<Object?, Object?> result = _validResult();
      result['arcoreFusionOrderingTimestampAuthority'] = 'Frame.getTimestamp';
      expect(
        () => NavguardFusionDiagnosticResult.fromPlatform(result),
        throwsFormatException,
      );
    });

    test('result accepts frozen Config D contract', () {
      final NavguardFusionDiagnosticResult result =
          NavguardFusionDiagnosticResult.fromPlatform(_validResult());
      expect(result.finalFusionQuality, NavguardQuality.usable);
      expect(result.finalFusedHorizontalDisplacementM, closeTo(5, 1e-12));
    });
  });
}

double _radians(double degrees) => degrees * math.pi / 180;

Map<Object?, Object?> _validResult() {
  return <Object?, Object?>{
    'schemaVersion': 1,
    'snapshotKind': 'navguard_fusion_diagnostic_result',
    'success': true,
    'fusionWindowMs': 30000,
    'alignmentHoldMs': 2000,
    'alignmentAcquisitionTimeoutMs': 15000,
    'coordinateFrame': 'local_enu',
    'estimatorProfile': 'config_d_navguard_ekf_v1',
    'alignmentCompleted': true,
    'alignmentStationarityAssumed': true,
    'alignmentStationarityValidated': false,
    'headingConvention': 'clockwise_from_north_0_to_2pi',
    'arcorePoseSource': 'Frame.getAndroidSensorPose',
    'referenceStrategy': 'local_arcore_anchor',
    'relativePoseStrategy': 'anchor_inverse_compose_android_sensor_pose',
    'headingTimestampAuthority': 'SensorEvent.timestamp',
    'stepTimestampAuthority': 'SensorEvent.timestamp',
    'arcoreFrameTimestampAuthority': 'Frame.getTimestamp',
    'arcoreFrameTimestampTimeBase': 'undefined_by_arcore_api',
    'operationWindowClock': 'SystemClock.elapsedRealtimeNanos',
    'qualityEngineImplemented': true,
    'ekfImplemented': true,
    'pdrArcoreFusionImplemented': true,
    'fusionStateDimension': 3,
    'fusionStateDefinition': 'E,N,heading',
    'josephCovarianceUpdateUsed': true,
    'circularHeadingInnovationUsed': true,
    'configDImplemented': true,
    'arcoreFrameTimestampUsedForFusionOrdering': false,
    'arcoreFusionOrderingTimestampAuthority':
        'SystemClock.elapsedRealtimeNanos',
    'arcoreFusionTimestampSemantics':
        'processing_time_after_frame_update_not_camera_capture_time',
    'elapsedRealtimeFusionOrderingUsed': true,
    'unsupportedCrossClockComparisonUsed': false,
    'deterministicOfflineReplayUsed': true,
    'equalTimestampPriority': 'heading,step,arcore',
    'headingAssociationPolicy':
        'latest_valid_heading_at_or_before_step_timestamp',
    'preDenialAnchorUsedForDeclination': true,
    'declinationProvider': 'android.hardware.GeomagneticField',
    'declinationModelVersion': 'platform_managed',
    'declinationAltitudeSource': 'anchor_ellipsoid_altitude',
    'declinationRad': 0.1,
    'baseStepLengthM': navguardStepLengthM,
    'baseStepLengthSigmaM': navguardBaseStepLengthSigmaM,
    'baseStepHeadingProcessSigmaRad': navguardBaseStepHeadingProcessSigmaRad,
    'baseHeadingMeasurementSigmaRad': navguardBaseHeadingMeasurementSigmaRad,
    'baseArcorePositionSigmaM': navguardBaseArcorePositionSigmaM,
    'protectedGroundTruthAccessed': false,
    'liveGnssRequested': false,
    'fusionAccuracyValidated': false,
    'qualityThresholdsValidated': false,
    'noiseParametersValidated': false,
    'gnssRecoveryImplemented': false,
    'fullGnssDeniedNavigationImplemented': false,
    'rawSensorSamplesReturned': false,
    'rawArcorePosesReturned': false,
    'rawTrajectoryReturned': false,
    'rawTimestampsReturned': false,
    'cameraImagesReturned': false,
    'persistenceUsed': false,
    'stepDetectionAccuracyValidated': false,
    'stepLengthValidated': false,
    'headingAccuracyValidated': false,
    'trueNorthAccuracyValidated': false,
    'arcorePositionAccuracyValidated': false,
    'arcoreDistanceAccuracyValidated': false,
    'finalHeadingQuality': 'GOOD',
    'finalPdrQuality': 'USABLE',
    'finalArcoreQuality': 'USABLE',
    'finalFusionQuality': 'USABLE',
    for (final String key in <String>[
      'headingGoodCount',
      'headingUsableCount',
      'headingDegradedCount',
      'headingUnreliableCount',
      'headingUnavailableCount',
      'pdrGoodCount',
      'pdrUsableCount',
      'pdrDegradedCount',
      'pdrUnreliableCount',
      'pdrUnavailableCount',
      'arcoreGoodCount',
      'arcoreUsableCount',
      'arcoreDegradedCount',
      'arcoreUnreliableCount',
      'arcoreUnavailableCount',
      'headingMeasurementsSkippedByQuality',
      'pdrPredictionsSkippedNoHeading',
      'pdrPredictionsSkippedByQuality',
      'arcoreMeasurementsSkippedByQuality',
      'headingInnovationCount',
      'arcoreInnovationCount',
    ])
      key: 0,
    'headingMeasurementsApplied': 2,
    'pdrPredictionsApplied': 3,
    'arcoreMeasurementsApplied': 4,
    'finalFusedEastM': 3.0,
    'finalFusedNorthM': 4.0,
    'finalFusedHeadingRad': 0.5,
    'finalFusedHorizontalDisplacementM': 5.0,
    'finalVarianceEastM2': 0.2,
    'finalVarianceNorthM2': 0.3,
    'finalVarianceHeadingRad2': 0.1,
    'finalCovarianceEastNorth': 0.01,
    'finalCovarianceEastHeading': 0.02,
    'finalCovarianceNorthHeading': 0.03,
    'finalPdrEastM': 2.0,
    'finalPdrNorthM': 1.0,
    'finalPdrHorizontalDisplacementM': math.sqrt(5),
    'finalArcoreEastM': 3.1,
    'finalArcoreNorthM': 4.1,
    'finalArcoreHorizontalDisplacementM': math.sqrt((3.1 * 3.1) + (4.1 * 4.1)),
    'meanAbsHeadingInnovationRad': null,
    'medianAbsHeadingInnovationRad': null,
    'maxAbsHeadingInnovationRad': null,
    'meanArcoreInnovationNormM': null,
    'medianArcoreInnovationNormM': null,
    'maxArcoreInnovationNormM': null,
  };
}
