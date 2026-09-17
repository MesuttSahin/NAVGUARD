import 'package:flutter_test/flutter_test.dart';
import 'package:navguard/navigation/navguard_accuracy_v2.dart';

void main() {
  group('Accuracy v2 preflight and native self-test contract', () {
    test(
      'requires every adaptive engineering self-test and conservative claims',
      () {
        final AccuracyV2Preflight value = AccuracyV2Preflight.fromPlatform(
          _preflightPayload(),
        );

        expect(value.nativeReady, isTrue);
        expect(value.selfTestsPassed, isTrue);
        expect(value.selfTests['robustGnssOrigin'], isTrue);
        expect(value.selfTests['smallGnssCandidateFallback'], isTrue);
        expect(value.selfTests['dynamicStride'], isTrue);
        expect(value.selfTests['strideBounds'], isTrue);
        expect(value.selfTests['degradedStrideFreeze'], isTrue);
        expect(value.selfTests['headingOffsetCalibration'], isTrue);
        expect(value.selfTests['headingOffsetBounds'], isTrue);
        expect(value.selfTests['headingOffsetTurnProtection'], isTrue);
        expect(value.selfTests['headingCircularInnovation'], isTrue);
        expect(value.selfTests['headingTurnProtection'], isTrue);
        expect(value.selfTests['headingOutlierRejection'], isTrue);
        expect(value.selfTests['nisFinite'], isTrue);
        expect(value.selfTests['nisKnownCase'], isTrue);
        expect(value.selfTests['nisUnsafeRejectedSafely'], isTrue);
        expect(value.selfTests['arcoreConsistentAccepted'], isTrue);
        expect(value.selfTests['arcoreSoftInflation'], isTrue);
        expect(value.selfTests['arcoreHardRejection'], isTrue);
        expect(value.selfTests['arcorePostRobustRecovery'], isTrue);
        expect(value.selfTests['arcorePostRobustExtremeRejection'], isTrue);
        expect(value.selfTests['stationaryDetection'], isTrue);
        expect(value.selfTests['stationaryDriftSuppression'], isTrue);
        expect(value.selfTests['stationaryExitOnStep'], isTrue);
        expect(value.selfTests['stationaryExitOnTurn'], isTrue);
        expect(value.selfTests['stationaryDelayedStepEventTime'], isTrue);
        expect(value.selfTests['stationaryCandidateDiagnostics'], isTrue);
        expect(value.selfTests['stationaryDelayedStepExit'], isTrue);
        expect(value.selfTests['syntheticAgreementRegression'], isTrue);
        expect(value.selfTests['syntheticArcoreOutlierImprovement'], isTrue);
        expect(value.selfTests['syntheticStationaryDriftSuppression'], isTrue);
        expect(value.selfTests['syntheticVariableStride'], isTrue);
        expect(value.selfTests['gtMutationInvariant'], isTrue);
        expect(value.selfTests['gtRemovalInvariant'], isTrue);
        expect(value.selfTests['profileRestartReload'], isTrue);
        expect(value.selfTests['profileResetPersistence'], isTrue);
        expect(value.selfTests['profileCorruptionFallback'], isTrue);
        expect(value.selfTests['calibrationDelayedCallbacks'], isTrue);
        expect(value.selfTests['calibrationHistoricalPhaseAssignment'], isTrue);
        expect(value.selfTests['calibrationHistoryBound'], isTrue);
        expect(value.selfTests['calibrationDuplicateSuppression'], isTrue);
        expect(value.selfTests['calibrationNoFutureHeading'], isTrue);
        expect(value.selfTests['calibrationDrainLearningSuppressed'], isTrue);
        expect(value.selfTests['gnssTargetStabilization'], isTrue);
        expect(value.selfTests['gnssDegradedStabilization'], isTrue);
        expect(value.selfTests['gnssInsufficientFailure'], isTrue);
        expect(value.selfTests['gnssAccuracyRejectionAccounting'], isTrue);
        expect(value.selfTests['gnssRobustMedianOrigin'], isTrue);
        expect(value.developmentOnly, isTrue);
        expect(value.accuracyValidated, isFalse);
        expect(value.aiModelImplemented, isFalse);
      },
    );

    test('rejects an inconsistent self-test aggregate', () {
      final Map<String, Object?> payload = _preflightPayload();
      payload['selfTestsPassed'] = false;
      expect(
        () => AccuracyV2Preflight.fromPlatform(payload),
        throwsFormatException,
      );
    });

    test('rejects missing robust-origin coverage', () {
      final Map<String, Object?> payload = _preflightPayload();
      final Map<String, bool> tests = Map<String, bool>.from(
        payload['selfTests']! as Map<String, bool>,
      )..remove('robustGnssOrigin');
      payload['selfTests'] = tests;
      expect(
        () => AccuracyV2Preflight.fromPlatform(payload),
        throwsFormatException,
      );
    });
  });

  group('Calibration profile and aggregate result', () {
    test('accepts bounded derived persisted profile', () {
      final CalibrationProfile profile = CalibrationProfile.fromPlatform(
        _profilePayload(),
      );

      expect(profile.strideEstimateM, 0.78);
      expect(profile.bodyHeadingOffsetDeg, -4.0);
      expect(profile.profilePersistence, 'android_shared_preferences');
      expect(profile.profilePersisted, isTrue);
      expect(profile.sanitizedMetadata['rawLocationPersisted'], isFalse);
      expect(profile.sanitizedMetadata['rawSensorPersisted'], isFalse);
    });

    test('enforces stride and heading-offset safety bounds', () {
      final Map<String, Object?> badStride = _profilePayload();
      badStride['strideEstimateM'] = 1.051;
      expect(
        () => CalibrationProfile.fromPlatform(badStride),
        throwsFormatException,
      );

      final Map<String, Object?> badOffset = _profilePayload();
      badOffset['bodyHeadingOffsetDeg'] = 25.1;
      expect(
        () => CalibrationProfile.fromPlatform(badOffset),
        throwsFormatException,
      );
    });

    test(
      'parses stationary, stride, heading, NIS and disagreement aggregates',
      () {
        final CalibrationResult result = CalibrationResult.fromPlatform(
          _calibrationPayload(),
        );

        expect(result.stationaryDetected, isTrue);
        expect(result.stationaryEverDetected, isTrue);
        expect(result.stationaryCurrentlyDetected, isFalse);
        expect(result.stationaryEntryCount, 2);
        expect(result.stationaryDetectedDurationMs, 9000);
        expect(result.stepsReceived, 24);
        expect(result.stepsApplied, 24);
        expect(result.finalDrainDurationMs, 12000);
        expect(result.stepsReceivedDuringFinalDrainCallbackDelivery, 7);
        expect(result.strideEstimateAfterM, inInclusiveRange(0.45, 1.05));
        expect(result.headingOffsetAfterDeg.abs(), lessThanOrEqualTo(25));
        expect(result.arcoreAccepted, 100);
        expect(result.arcoreRejected, 3);
        expect(result.arcoreNisMax, 8.5);
        expect(result.arcorePreRobustNisMax, 40.0);
        expect(result.arcorePostRobustNisMax, 20.0);
        expect(result.arcoreAcceptedAfterRobustInflationCount, 30);
        expect(result.profilePersisted, isTrue);
        expect(result.sourceDisagreementMaxM, 2.2);
        expect(result.sanitizedMetadata['rawDataReturned'], isFalse);
      },
    );

    test('rejects raw-data or validation overclaim flags', () {
      final Map<String, Object?> rawLeak = _calibrationPayload();
      rawLeak['rawTrajectoryReturned'] = true;
      expect(
        () => CalibrationResult.fromPlatform(rawLeak),
        throwsFormatException,
      );

      final Map<String, Object?> overclaim = _calibrationPayload();
      overclaim['accuracyValidated'] = true;
      expect(
        () => CalibrationResult.fromPlatform(overclaim),
        throwsFormatException,
      );
    });

    test('rejects an inconsistent final-drain aggregate', () {
      final Map<String, Object?> invalid = _calibrationPayload();
      invalid['stepsReceivedDuringFinalDrainCallbackDelivery'] = 25;
      expect(
        () => CalibrationResult.fromPlatform(invalid),
        throwsFormatException,
      );
    });
  });

  group('D-v1 versus D-v2 development benchmark contract', () {
    test('parses same-session A/D1/D2 metrics and adaptive diagnostics', () {
      final AccuracyV2DevelopmentBenchmarkResult result =
          AccuracyV2DevelopmentBenchmarkResult.fromPlatform(
            _benchmarkPayload(),
          );

      expect(result.configA.configId, deterministicPdrConfigId);
      expect(result.configD1.configId, navguardV1ConfigId);
      expect(result.configD2.configId, navguardAdaptiveConfigId);
      expect(result.developmentScenario, 'L_TURN');
      expect(result.developmentBenchmarkFinalDrainMs, 12000);
      expect(result.benchmarkStepEventsReceivedTotal, 14);
      expect(result.benchmarkStepEventsInFormalWindow, 12);
      expect(result.benchmarkStepEventsDeliveredDuringFinalDrain, 4);
      expect(result.benchmarkStepEventsIncludedFromFinalDrain, 3);
      expect(result.benchmarkStepEventsExcludedPostWindow, 1);
      expect(<int>[
        result.configAStepsApplied,
        result.configD1StepsApplied,
        result.configD2StepsApplied,
      ], everyElement(12));
      expect(result.configD1.matchedGtCount, 30);
      expect(result.configD2.matchedGtCount, 30);
      expect(result.d2VsD1MedianImprovementPercent, 12.5);
      expect(result.d2VsD1RelativeMedianImprovementPercent, 10.0);
      expect(result.configD1.relativeMedianHorizontalErrorM, 1.0);
      expect(result.configD2.relativeFinalHorizontalErrorM, 1.25);
      expect(result.configD2InitialMatchedBiasM, 8.5);
      expect(result.strideEstimateFinalM, inInclusiveRange(0.45, 1.05));
      expect(result.bodyHeadingOffsetFinalDeg.abs(), lessThanOrEqualTo(25));
      expect(result.arcoreAdaptiveSigmaMeanM, greaterThanOrEqualTo(0.35));
      expect(result.arcoreAdaptiveSigmaMaxM, lessThanOrEqualTo(5.0));
      expect(result.arcoreAcceptedNominalCount, 70);
      expect(result.arcoreAcceptedInflatedCount, 30);
      expect(result.arcoreRobustSigmaMeanM, 0.75);
      expect(result.arcorePreRobustNisMax, 40.0);
      expect(result.arcorePostRobustNisMax, 20.0);
      expect(result.arcoreAcceptedAfterRobustInflationCount, 30);
      expect(result.arcoreRejectedAfterMaxInflationCount, 1);
      expect(result.stationaryEntryCount, 1);
      expect(result.stationaryCandidateCount, 2);
      expect(result.stationaryDetectedDurationMs, 6000);
      expect(result.stationaryArcoreSuppressedCount, 12);
      expect(result.gtMutationInvariant, isTrue);
      expect(result.gtRemovalInvariant, isTrue);
      expect(result.gnssStabilization.acceptedFixCount, 8);
      expect(result.gnssStabilization.degraded, isFalse);
      expect(result.gnssStabilization.reason, 'target_met');
      expect(result.sanitizedMetadata['protectedGtEstimatorAccessCount'], 0);
      expect(result.sanitizedMetadata['accuracyValidated'], isFalse);
    });

    test('accepts a degraded 3–4 fix stabilization result', () {
      final Map<String, Object?> payload = _benchmarkPayload();
      payload['gnssStabilizationFixCount'] = 4;
      payload['gnssStabilizationAcceptedFixCount'] = 4;
      payload['gnssStabilizationReceivedFixCount'] = 9;
      payload['gnssStabilizationDegraded'] = true;
      payload['gnssStabilizationReason'] = 'accepted_less_than_target';

      final AccuracyV2DevelopmentBenchmarkResult result =
          AccuracyV2DevelopmentBenchmarkResult.fromPlatform(payload);

      expect(result.gnssStabilization.degraded, isTrue);
      expect(result.gnssStabilization.acceptedFixCount, 4);
    });

    test('parses sanitized insufficient-fix error diagnostics', () {
      final AccuracyV2GnssStabilizationDiagnostics diagnostics =
          AccuracyV2GnssStabilizationDiagnostics.fromPlatformErrorDetails(
            _stabilizationFailurePayload(),
          );

      expect(diagnostics.acceptedFixCount, 2);
      expect(diagnostics.minimumFixCount, 3);
      expect(diagnostics.rejectedAccuracyCount, 4);
      expect(diagnostics.reason, 'accepted_below_minimum');
      expect(diagnostics.sanitizedMetadata['rawCoordinatesReturned'], isFalse);
    });

    test('rejects GT estimator access and non-development labeling', () {
      final Map<String, Object?> access = _benchmarkPayload();
      access['protectedGtEstimatorAccessCount'] = 1;
      expect(
        () => AccuracyV2DevelopmentBenchmarkResult.fromPlatform(access),
        throwsFormatException,
      );

      final Map<String, Object?> finalClaim = _benchmarkPayload();
      finalClaim['finalValidation'] = true;
      expect(
        () => AccuracyV2DevelopmentBenchmarkResult.fromPlatform(finalClaim),
        throwsFormatException,
      );
    });

    test('requires exact frozen config identifiers', () {
      final Map<String, Object?> payload = _benchmarkPayload();
      final Map<String, Object?> d1 = Map<String, Object?>.from(
        payload['configD1']! as Map<String, Object?>,
      );
      d1['configId'] = 'renamed_v1';
      payload['configD1'] = d1;
      expect(
        () => AccuracyV2DevelopmentBenchmarkResult.fromPlatform(payload),
        throwsFormatException,
      );
    });

    test('requires labeled scenarios and fair formal-window step input', () {
      for (final String scenario in accuracyV2DevelopmentScenarios) {
        final Map<String, Object?> payload = _benchmarkPayload();
        payload['developmentScenario'] = scenario;
        expect(
          AccuracyV2DevelopmentBenchmarkResult.fromPlatform(
            payload,
          ).developmentScenario,
          scenario,
        );
      }

      final Map<String, Object?> invalidScenario = _benchmarkPayload();
      invalidScenario['developmentScenario'] = 'UNLABELED';
      expect(
        () =>
            AccuracyV2DevelopmentBenchmarkResult.fromPlatform(invalidScenario),
        throwsFormatException,
      );

      final Map<String, Object?> unfair = _benchmarkPayload();
      unfair['configD2StepsApplied'] = 11;
      expect(
        () => AccuracyV2DevelopmentBenchmarkResult.fromPlatform(unfair),
        throwsFormatException,
      );
    });

    test('requires bounded robust ARCore diagnostics', () {
      final Map<String, Object?> inconsistentCounts = _benchmarkPayload();
      inconsistentCounts['arcoreAcceptedInflatedCount'] = 29;
      expect(
        () => AccuracyV2DevelopmentBenchmarkResult.fromPlatform(
          inconsistentCounts,
        ),
        throwsFormatException,
      );

      final Map<String, Object?> excessiveSigma = _benchmarkPayload();
      excessiveSigma['arcoreRobustSigmaMaxM'] = 5.01;
      expect(
        () => AccuracyV2DevelopmentBenchmarkResult.fromPlatform(excessiveSigma),
        throwsFormatException,
      );
    });

    test('malformed numeric payload produces sanitized FormatException', () {
      final Map<String, Object?> payload = _benchmarkPayload();
      payload['sourceDisagreementMeanM'] = double.nan;
      try {
        AccuracyV2DevelopmentBenchmarkResult.fromPlatform(payload);
        fail('Expected FormatException');
      } on FormatException catch (error) {
        expect(error.message, isNot(contains('sourceDisagreementMeanM')));
        expect(error.message, isNot(contains('NaN')));
      }
    });
  });
}

Map<String, bool> _selfTests() => <String, bool>{
  'robustGnssOrigin': true,
  'smallGnssCandidateFallback': true,
  'dynamicStride': true,
  'strideBounds': true,
  'degradedStrideFreeze': true,
  'headingOffsetCalibration': true,
  'headingOffsetBounds': true,
  'headingOffsetTurnProtection': true,
  'headingCircularInnovation': true,
  'headingTurnProtection': true,
  'headingOutlierRejection': true,
  'nisFinite': true,
  'nisKnownCase': true,
  'nisUnsafeRejectedSafely': true,
  'arcoreConsistentAccepted': true,
  'arcoreSoftInflation': true,
  'arcoreHardRejection': true,
  'arcoreModerateRobustUpdate': true,
  'arcoreExtremeHardRejection': true,
  'arcorePostRobustRecovery': true,
  'arcorePostRobustExtremeRejection': true,
  'arcoreTurnAwareRobustUpdate': true,
  'stationaryDetection': true,
  'stationaryDriftSuppression': true,
  'stationaryExitOnStep': true,
  'stationaryExitOnTurn': true,
  'stationaryReplayActivation': true,
  'stationaryDelayedStepEventTime': true,
  'stationaryCandidateDiagnostics': true,
  'stationaryDelayedStepExit': true,
  'syntheticAgreementRegression': true,
  'syntheticArcoreOutlierImprovement': true,
  'syntheticStationaryDriftSuppression': true,
  'syntheticRobustV2Regression': true,
  'syntheticVariableStride': true,
  'gtMutationInvariant': true,
  'gtRemovalInvariant': true,
  'profileRestartReload': true,
  'profileResetPersistence': true,
  'profileCorruptionFallback': true,
  'calibrationDelayedCallbacks': true,
  'calibrationHistoricalPhaseAssignment': true,
  'calibrationHistoryBound': true,
  'calibrationDuplicateSuppression': true,
  'calibrationNoFutureHeading': true,
  'calibrationDrainLearningSuppressed': true,
  'benchmarkDelayedInWindowCallback': true,
  'benchmarkPostWindowExclusion': true,
  'benchmarkMultipleDelayedCallbacks': true,
  'benchmarkGtWindowBounded': true,
  'benchmarkFairStepInput': true,
  'relativeConstantOffsetRemoved': true,
  'relativeCausalMatching': true,
  'relativeGtFirewall': true,
  'gnssTargetStabilization': true,
  'gnssDegradedStabilization': true,
  'gnssInsufficientFailure': true,
  'gnssAccuracyRejectionAccounting': true,
  'gnssRobustMedianOrigin': true,
};

Map<String, Object?> _preflightPayload() => <String, Object?>{
  'schemaVersion': 1,
  'snapshotKind': 'navguard_accuracy_v2_preflight',
  'configId': navguardAdaptiveConfigId,
  'fineLocationPermissionGranted': true,
  'gpsProviderAvailable': true,
  'gpsProviderEnabled': true,
  'rotationVectorAvailable': true,
  'stepDetectorAvailable': true,
  'activityRecognitionPermissionGranted': true,
  'arCoreSupported': true,
  'arCoreInstalled': true,
  'cameraPermissionGranted': true,
  'anchorAvailable': true,
  'nativeReady': true,
  'operationBusy': false,
  'selfTests': _selfTests(),
  'selfTestsPassed': true,
  'developmentOnly': true,
  'accuracyValidated': false,
  'aiModelImplemented': false,
};

Map<String, Object?> _profilePayload() => <String, Object?>{
  'schemaVersion': 1,
  'snapshotKind': 'navguard_accuracy_v2_calibration_profile',
  'configId': navguardAdaptiveConfigId,
  'strideEstimateM': 0.78,
  'bodyHeadingOffsetRad': -0.06981317007977318,
  'bodyHeadingOffsetDeg': -4.0,
  'strideSampleCount': 3,
  'headingOffsetSampleCount': 2,
  'profilePersistence': 'android_shared_preferences',
  'profilePersisted': true,
  'rawLocationPersisted': false,
  'rawSensorPersisted': false,
  'rawArcorePosePersisted': false,
  'rawTrajectoryPersisted': false,
  'cloudUploadEnabled': false,
  'telemetryEnabled': false,
};

Map<String, Object?> _calibrationPayload() => <String, Object?>{
  'schemaVersion': 1,
  'snapshotKind': 'navguard_accuracy_v2_calibration_result',
  'configId': navguardAdaptiveConfigId,
  'sessionLabel': 'DEVELOPMENT_CALIBRATION_SESSION',
  'stationaryDetected': true,
  'stationaryCurrentlyDetected': false,
  'stationaryEverDetected': true,
  'stationaryEntryCount': 2,
  'stationaryDetectedDurationMs': 9000,
  'stationaryCandidateCount': 3,
  'stationaryBlockedRecentStepCount': 7,
  'stationaryBlockedHeadingMotionCount': 4,
  'stationaryBlockedArcoreMotionCount': 5,
  'stationaryBlockedOtherMotionCount': 0,
  'stationaryDriftM': 0.08,
  'stepsReceived': 24,
  'stepsApplied': 24,
  'finalDrainDurationMs': 12000,
  'stepsReceivedDuringFinalDrainCallbackDelivery': 7,
  'strideEstimateBeforeM': 0.75,
  'strideEstimateAfterM': 0.78,
  'strideCalibrationSamples': 3,
  'headingOffsetBeforeDeg': 0.0,
  'headingOffsetAfterDeg': -4.0,
  'headingOffsetSamples': 2,
  'arcoreAccepted': 100,
  'arcoreRejected': 3,
  'arcoreNisMean': 1.2,
  'arcoreNisMax': 8.5,
  'arcorePreRobustNisMean': 12.0,
  'arcorePreRobustNisMax': 40.0,
  'arcorePostRobustNisMean': 6.0,
  'arcorePostRobustNisMax': 20.0,
  'arcoreAcceptedAfterRobustInflationCount': 30,
  'arcoreRejectedAfterMaxInflationCount': 1,
  'headingAccepted': 200,
  'headingRejected': 1,
  'sourceDisagreementMeanM': 0.4,
  'sourceDisagreementMaxM': 2.2,
  'profilePersisted': true,
  'profilePersistence': 'android_shared_preferences',
  'rawLocationReturned': false,
  'rawSensorStreamReturned': false,
  'rawArcorePoseReturned': false,
  'rawTimestampsReturned': false,
  'rawTrajectoryReturned': false,
  'accuracyValidated': false,
};

Map<String, Object?> _metrics(String id, double median) => <String, Object?>{
  'configId': id,
  'matchedGtCount': 30,
  'meanHorizontalErrorM': median + 0.5,
  'medianHorizontalErrorM': median,
  'p95HorizontalErrorM': median + 1.0,
  'maxHorizontalErrorM': median + 1.5,
  'finalPreCorrectionHorizontalErrorM': median + 0.25,
  'relativeMeanHorizontalErrorM': 1.5,
  'relativeMedianHorizontalErrorM': 1.0,
  'relativeP95HorizontalErrorM': 2.0,
  'relativeMaxHorizontalErrorM': 2.5,
  'relativeFinalHorizontalErrorM': 1.25,
};

Map<String, Object?> _benchmarkPayload() => <String, Object?>{
  'schemaVersion': 1,
  'snapshotKind': 'navguard_accuracy_v2_development_benchmark_result',
  'sessionLabel': 'DEVELOPMENT_SESSION_NOT_FINAL_VALIDATION',
  'developmentScenario': 'L_TURN',
  'sameSessionCapture': true,
  'eventOrdering': 'HEADING_STEP_ARCORE_POSITION_INSERTION_SEQUENCE',
  'developmentBenchmarkFinalDrainMs': 12000,
  'benchmarkStepEventsReceivedTotal': 14,
  'benchmarkStepEventsInFormalWindow': 12,
  'benchmarkStepEventsDeliveredDuringFinalDrain': 4,
  'benchmarkStepEventsIncludedFromFinalDrain': 3,
  'benchmarkStepEventsExcludedPostWindow': 1,
  'configAStepsApplied': 12,
  'configD1StepsApplied': 12,
  'configD2StepsApplied': 12,
  'configA': _metrics(deterministicPdrConfigId, 9.0),
  'configD1': _metrics(navguardV1ConfigId, 8.0),
  'configD2': _metrics(navguardAdaptiveConfigId, 7.0),
  'd2VsD1MedianImprovementPercent': 12.5,
  'd2VsAMedianImprovementPercent': 22.222222222,
  'd2VsD1RelativeMedianImprovementPercent': 10.0,
  'd2VsARelativeMedianImprovementPercent': 20.0,
  'configAInitialMatchedBiasM': 10.0,
  'configD1InitialMatchedBiasM': 9.0,
  'configD2InitialMatchedBiasM': 8.5,
  'strideEstimateFinalM': 0.78,
  'strideEstimateMeanM': 0.77,
  'strideCalibrationSampleCount': 3,
  'bodyHeadingOffsetFinalDeg': -4.0,
  'arcoreAcceptedCount': 100,
  'arcoreAcceptedNominalCount': 70,
  'arcoreAcceptedInflatedCount': 30,
  'arcoreRejectedByQualityCount': 2,
  'arcoreRejectedByInnovationCount': 1,
  'arcoreAcceptedAfterRobustInflationCount': 30,
  'arcoreRejectedAfterMaxInflationCount': 1,
  'arcorePreRobustNisMean': 12.0,
  'arcorePreRobustNisMax': 40.0,
  'arcorePostRobustNisMean': 6.0,
  'arcorePostRobustNisMax': 20.0,
  'arcoreAdaptiveSigmaMeanM': 0.75,
  'arcoreAdaptiveSigmaMaxM': 2.0,
  'arcoreRobustSigmaMeanM': 0.75,
  'arcoreRobustSigmaMaxM': 2.0,
  'headingAcceptedCount': 200,
  'headingRejectedCount': 1,
  'stationaryDetectedDurationMs': 6000,
  'stationaryEntryCount': 1,
  'stationaryCandidateCount': 2,
  'stationaryBlockedRecentStepCount': 10,
  'stationaryBlockedHeadingMotionCount': 5,
  'stationaryBlockedArcoreMotionCount': 7,
  'stationaryBlockedOtherMotionCount': 0,
  'stationaryArcoreSuppressedCount': 12,
  'sourceDisagreementMeanM': 0.4,
  'sourceDisagreementMaxM': 2.2,
  'gnssStabilizationFixCount': 8,
  'gnssStabilizationReceivedFixCount': 13,
  'gnssStabilizationAcceptedFixCount': 8,
  'gnssStabilizationRejectedStructuralCount': 1,
  'gnssStabilizationRejectedAccuracyCount': 2,
  'gnssStabilizationRejectedMockCount': 1,
  'gnssStabilizationRejectedNonMonotonicCount': 1,
  'gnssStabilizationReportedAccuracyMinM': 4.0,
  'gnssStabilizationReportedAccuracyMaxM': 60.0,
  'gnssStabilizationObservedDurationMs': 7000,
  'gnssStabilizationTargetFixCount': 5,
  'gnssStabilizationMinimumFixCount': 3,
  'gnssStabilizationDegraded': false,
  'gnssStabilizationReason': 'target_met',
  'gnssStabilizationEastSpreadM': 2.0,
  'gnssStabilizationNorthSpreadM': 1.5,
  'gnssStabilizationHorizontalSpreadM': 2.5,
  'gnssStabilizationReportedAccuracyMedianM': 6.0,
  'protectedGtEstimatorAccessCount': 0,
  'gtMutationInvariant': true,
  'gtRemovalInvariant': true,
  'protectedGroundTruthComparatorOnly': true,
  'rawLocationReturned': false,
  'rawSensorStreamReturned': false,
  'rawArcorePoseReturned': false,
  'rawTimestampsReturned': false,
  'rawTrajectoryReturned': false,
  'developmentMetricsOnly': true,
  'finalValidation': false,
  'accuracyValidated': false,
};

Map<String, Object?> _stabilizationFailurePayload() => <String, Object?>{
  'schemaVersion': 1,
  'snapshotKind': 'navguard_accuracy_v2_gnss_stabilization_diagnostics',
  'gnssStabilizationReceivedFixCount': 8,
  'gnssStabilizationAcceptedFixCount': 2,
  'gnssStabilizationRejectedStructuralCount': 1,
  'gnssStabilizationRejectedAccuracyCount': 4,
  'gnssStabilizationRejectedMockCount': 1,
  'gnssStabilizationRejectedNonMonotonicCount': 0,
  'gnssStabilizationReportedAccuracyMinM': 5.0,
  'gnssStabilizationReportedAccuracyMedianM': 75.0,
  'gnssStabilizationReportedAccuracyMaxM': 90.0,
  'gnssStabilizationObservedDurationMs': 1000,
  'gnssStabilizationTargetFixCount': 5,
  'gnssStabilizationMinimumFixCount': 3,
  'gnssStabilizationDegraded': false,
  'gnssStabilizationReason': 'accepted_below_minimum',
  'rawCoordinatesReturned': false,
  'rawTimestampsReturned': false,
};
