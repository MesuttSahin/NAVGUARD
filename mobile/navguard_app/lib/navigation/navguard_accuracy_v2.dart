const String navguardAccuracyV2ChannelName =
    'io.github.mesuttsahin.navguard/navguard_accuracy_v2';
const String navguardAdaptiveConfigId = 'config_d_v2_adaptive_navguard';
const String navguardV1ConfigId = 'config_d_navguard_ekf_v1';
const String deterministicPdrConfigId = 'config_a_deterministic_pdr';
const int accuracyV2CalibrationFinalDrainMs = 12000;
const int accuracyV2DevelopmentBenchmarkFinalDrainMs = 12000;
const Set<String> accuracyV2DevelopmentScenarios = <String>{
  'STRAIGHT',
  'L_TURN',
  'MIXED',
};

class AccuracyV2Preflight {
  const AccuracyV2Preflight({
    required this.fineLocationPermissionGranted,
    required this.gpsProviderAvailable,
    required this.gpsProviderEnabled,
    required this.rotationVectorAvailable,
    required this.stepDetectorAvailable,
    required this.activityRecognitionPermissionGranted,
    required this.arCoreSupported,
    required this.arCoreInstalled,
    required this.cameraPermissionGranted,
    required this.anchorAvailable,
    required this.nativeReady,
    required this.operationBusy,
    required this.selfTests,
    required this.selfTestsPassed,
    required this.developmentOnly,
    required this.accuracyValidated,
    required this.aiModelImplemented,
  });

  factory AccuracyV2Preflight.fromPlatform(Object? raw) {
    final Map<Object?, Object?> map = _strictMap(raw);
    _expectSchema(map, 'navguard_accuracy_v2_preflight');
    _expectString(map, 'configId', navguardAdaptiveConfigId);
    final Map<Object?, Object?> tests = _strictMap(map['selfTests']);
    final Map<String, bool> parsedTests = <String, bool>{};
    for (final MapEntry<Object?, Object?> entry in tests.entries) {
      if (entry.key is! String || entry.value is! bool) {
        throw const FormatException('Invalid Accuracy v2 preflight response.');
      }
      parsedTests[entry.key! as String] = entry.value! as bool;
    }
    const Set<String> requiredSelfTests = <String>{
      'robustGnssOrigin',
      'smallGnssCandidateFallback',
      'dynamicStride',
      'strideBounds',
      'degradedStrideFreeze',
      'headingOffsetCalibration',
      'headingOffsetBounds',
      'headingOffsetTurnProtection',
      'headingCircularInnovation',
      'headingTurnProtection',
      'headingOutlierRejection',
      'nisFinite',
      'nisKnownCase',
      'nisUnsafeRejectedSafely',
      'arcoreConsistentAccepted',
      'arcoreSoftInflation',
      'arcoreHardRejection',
      'arcoreModerateRobustUpdate',
      'arcoreExtremeHardRejection',
      'arcorePostRobustRecovery',
      'arcorePostRobustExtremeRejection',
      'arcoreTurnAwareRobustUpdate',
      'stationaryDetection',
      'stationaryDriftSuppression',
      'stationaryExitOnStep',
      'stationaryExitOnTurn',
      'stationaryReplayActivation',
      'stationaryDelayedStepEventTime',
      'stationaryCandidateDiagnostics',
      'stationaryDelayedStepExit',
      'syntheticAgreementRegression',
      'syntheticArcoreOutlierImprovement',
      'syntheticStationaryDriftSuppression',
      'syntheticRobustV2Regression',
      'syntheticVariableStride',
      'gtMutationInvariant',
      'gtRemovalInvariant',
      'profileRestartReload',
      'profileResetPersistence',
      'profileCorruptionFallback',
      'calibrationDelayedCallbacks',
      'calibrationHistoricalPhaseAssignment',
      'calibrationHistoryBound',
      'calibrationDuplicateSuppression',
      'calibrationNoFutureHeading',
      'calibrationDrainLearningSuppressed',
      'benchmarkDelayedInWindowCallback',
      'benchmarkPostWindowExclusion',
      'benchmarkMultipleDelayedCallbacks',
      'benchmarkGtWindowBounded',
      'benchmarkFairStepInput',
      'relativeConstantOffsetRemoved',
      'relativeCausalMatching',
      'relativeGtFirewall',
      'gnssTargetStabilization',
      'gnssDegradedStabilization',
      'gnssInsufficientFailure',
      'gnssAccuracyRejectionAccounting',
      'gnssRobustMedianOrigin',
    };
    final bool reportedSelfTestsPassed = _bool(map, 'selfTestsPassed');
    if (!parsedTests.keys.toSet().containsAll(requiredSelfTests) ||
        reportedSelfTestsPassed !=
            parsedTests.values.every((bool value) => value)) {
      throw const FormatException('Invalid Accuracy v2 self-test contract.');
    }
    return AccuracyV2Preflight(
      fineLocationPermissionGranted: _bool(
        map,
        'fineLocationPermissionGranted',
      ),
      gpsProviderAvailable: _bool(map, 'gpsProviderAvailable'),
      gpsProviderEnabled: _bool(map, 'gpsProviderEnabled'),
      rotationVectorAvailable: _bool(map, 'rotationVectorAvailable'),
      stepDetectorAvailable: _bool(map, 'stepDetectorAvailable'),
      activityRecognitionPermissionGranted: _bool(
        map,
        'activityRecognitionPermissionGranted',
      ),
      arCoreSupported: _bool(map, 'arCoreSupported'),
      arCoreInstalled: _bool(map, 'arCoreInstalled'),
      cameraPermissionGranted: _bool(map, 'cameraPermissionGranted'),
      anchorAvailable: _bool(map, 'anchorAvailable'),
      nativeReady: _bool(map, 'nativeReady'),
      operationBusy: _bool(map, 'operationBusy'),
      selfTests: Map<String, bool>.unmodifiable(parsedTests),
      selfTestsPassed: reportedSelfTestsPassed,
      developmentOnly: _expectTrue(map, 'developmentOnly'),
      accuracyValidated: _expectFalse(map, 'accuracyValidated'),
      aiModelImplemented: _expectFalse(map, 'aiModelImplemented'),
    );
  }

  final bool fineLocationPermissionGranted;
  final bool gpsProviderAvailable;
  final bool gpsProviderEnabled;
  final bool rotationVectorAvailable;
  final bool stepDetectorAvailable;
  final bool activityRecognitionPermissionGranted;
  final bool arCoreSupported;
  final bool arCoreInstalled;
  final bool cameraPermissionGranted;
  final bool anchorAvailable;
  final bool nativeReady;
  final bool operationBusy;
  final Map<String, bool> selfTests;
  final bool selfTestsPassed;
  final bool developmentOnly;
  final bool accuracyValidated;
  final bool aiModelImplemented;

  Map<String, Object?> get sanitizedMetadata => <String, Object?>{
    'configId': navguardAdaptiveConfigId,
    'fineLocationPermissionGranted': fineLocationPermissionGranted,
    'gpsProviderAvailable': gpsProviderAvailable,
    'gpsProviderEnabled': gpsProviderEnabled,
    'rotationVectorAvailable': rotationVectorAvailable,
    'stepDetectorAvailable': stepDetectorAvailable,
    'activityRecognitionPermissionGranted':
        activityRecognitionPermissionGranted,
    'arCoreSupported': arCoreSupported,
    'arCoreInstalled': arCoreInstalled,
    'cameraPermissionGranted': cameraPermissionGranted,
    'anchorAvailable': anchorAvailable,
    'nativeReady': nativeReady,
    'operationBusy': operationBusy,
    'selfTests': selfTests,
    'selfTestsPassed': selfTestsPassed,
    'developmentOnly': developmentOnly,
    'accuracyValidated': accuracyValidated,
    'aiModelImplemented': aiModelImplemented,
  };
}

class CalibrationProfile {
  const CalibrationProfile({
    required this.strideEstimateM,
    required this.bodyHeadingOffsetRad,
    required this.bodyHeadingOffsetDeg,
    required this.strideSampleCount,
    required this.headingOffsetSampleCount,
    required this.profilePersistence,
    required this.profilePersisted,
  });

  factory CalibrationProfile.fromPlatform(Object? raw) {
    final Map<Object?, Object?> map = _strictMap(raw);
    _expectSchema(map, 'navguard_accuracy_v2_calibration_profile');
    _expectString(map, 'configId', navguardAdaptiveConfigId);
    final double stride = _finiteDouble(map, 'strideEstimateM');
    final double offsetRad = _finiteDouble(map, 'bodyHeadingOffsetRad');
    final double offsetDeg = _finiteDouble(map, 'bodyHeadingOffsetDeg');
    if (stride < 0.45 || stride > 1.05 || offsetDeg.abs() > 25.000001) {
      throw const FormatException('Invalid Accuracy v2 calibration profile.');
    }
    final bool profilePersisted = _bool(map, 'profilePersisted');
    _expectFalse(map, 'rawLocationPersisted');
    _expectFalse(map, 'rawSensorPersisted');
    _expectFalse(map, 'rawArcorePosePersisted');
    _expectFalse(map, 'rawTrajectoryPersisted');
    _expectFalse(map, 'cloudUploadEnabled');
    _expectFalse(map, 'telemetryEnabled');
    return CalibrationProfile(
      strideEstimateM: stride,
      bodyHeadingOffsetRad: offsetRad,
      bodyHeadingOffsetDeg: offsetDeg,
      strideSampleCount: _nonNegativeInt(map, 'strideSampleCount'),
      headingOffsetSampleCount: _nonNegativeInt(
        map,
        'headingOffsetSampleCount',
      ),
      profilePersistence: _expectString(
        map,
        'profilePersistence',
        'android_shared_preferences',
      ),
      profilePersisted: profilePersisted,
    );
  }

  final double strideEstimateM;
  final double bodyHeadingOffsetRad;
  final double bodyHeadingOffsetDeg;
  final int strideSampleCount;
  final int headingOffsetSampleCount;
  final String profilePersistence;
  final bool profilePersisted;

  Map<String, Object?> get sanitizedMetadata => <String, Object?>{
    'configId': navguardAdaptiveConfigId,
    'strideEstimateM': strideEstimateM,
    'bodyHeadingOffsetRad': bodyHeadingOffsetRad,
    'bodyHeadingOffsetDeg': bodyHeadingOffsetDeg,
    'strideSampleCount': strideSampleCount,
    'headingOffsetSampleCount': headingOffsetSampleCount,
    'profilePersistence': profilePersistence,
    'profilePersisted': profilePersisted,
    'rawLocationPersisted': false,
    'rawSensorPersisted': false,
  };
}

class CalibrationResult {
  const CalibrationResult({
    required this.stationaryDetected,
    required this.stationaryCurrentlyDetected,
    required this.stationaryEverDetected,
    required this.stationaryEntryCount,
    required this.stationaryDetectedDurationMs,
    required this.stationaryCandidateCount,
    required this.stationaryBlockedRecentStepCount,
    required this.stationaryBlockedHeadingMotionCount,
    required this.stationaryBlockedArcoreMotionCount,
    required this.stationaryBlockedOtherMotionCount,
    required this.stationaryDriftM,
    required this.stepsReceived,
    required this.stepsApplied,
    required this.finalDrainDurationMs,
    required this.stepsReceivedDuringFinalDrainCallbackDelivery,
    required this.strideEstimateBeforeM,
    required this.strideEstimateAfterM,
    required this.strideCalibrationSamples,
    required this.headingOffsetBeforeDeg,
    required this.headingOffsetAfterDeg,
    required this.headingOffsetSamples,
    required this.arcoreAccepted,
    required this.arcoreRejected,
    required this.arcoreNisMean,
    required this.arcoreNisMax,
    required this.arcorePreRobustNisMean,
    required this.arcorePreRobustNisMax,
    required this.arcorePostRobustNisMean,
    required this.arcorePostRobustNisMax,
    required this.arcoreAcceptedAfterRobustInflationCount,
    required this.arcoreRejectedAfterMaxInflationCount,
    required this.headingAccepted,
    required this.headingRejected,
    required this.sourceDisagreementMeanM,
    required this.sourceDisagreementMaxM,
    required this.profilePersisted,
  });

  factory CalibrationResult.fromPlatform(Object? raw) {
    final Map<Object?, Object?> map = _strictMap(raw);
    _expectSchema(map, 'navguard_accuracy_v2_calibration_result');
    _expectString(map, 'configId', navguardAdaptiveConfigId);
    _expectString(map, 'sessionLabel', 'DEVELOPMENT_CALIBRATION_SESSION');
    final bool profilePersisted = _bool(map, 'profilePersisted');
    _expectFalse(map, 'rawLocationReturned');
    _expectFalse(map, 'rawSensorStreamReturned');
    _expectFalse(map, 'rawArcorePoseReturned');
    _expectFalse(map, 'rawTimestampsReturned');
    _expectFalse(map, 'rawTrajectoryReturned');
    _expectFalse(map, 'accuracyValidated');
    final double strideBefore = _finiteDouble(map, 'strideEstimateBeforeM');
    final double strideAfter = _finiteDouble(map, 'strideEstimateAfterM');
    final double headingBefore = _finiteDouble(map, 'headingOffsetBeforeDeg');
    final double headingAfter = _finiteDouble(map, 'headingOffsetAfterDeg');
    final int stepsReceived = _nonNegativeInt(map, 'stepsReceived');
    final int stepsApplied = _nonNegativeInt(map, 'stepsApplied');
    final int finalDrainDurationMs = _nonNegativeInt(
      map,
      'finalDrainDurationMs',
    );
    final int drainDeliveredSteps = _nonNegativeInt(
      map,
      'stepsReceivedDuringFinalDrainCallbackDelivery',
    );
    if (strideBefore < 0.45 ||
        strideBefore > 1.05 ||
        strideAfter < 0.45 ||
        strideAfter > 1.05 ||
        headingBefore.abs() > 25.000001 ||
        headingAfter.abs() > 25.000001 ||
        stepsApplied > stepsReceived ||
        drainDeliveredSteps > stepsReceived ||
        finalDrainDurationMs != accuracyV2CalibrationFinalDrainMs) {
      throw const FormatException('Invalid Accuracy v2 calibration result.');
    }
    return CalibrationResult(
      stationaryDetected: _bool(map, 'stationaryDetected'),
      stationaryCurrentlyDetected: _bool(map, 'stationaryCurrentlyDetected'),
      stationaryEverDetected: _bool(map, 'stationaryEverDetected'),
      stationaryEntryCount: _nonNegativeInt(map, 'stationaryEntryCount'),
      stationaryDetectedDurationMs: _nonNegativeInt(
        map,
        'stationaryDetectedDurationMs',
      ),
      stationaryCandidateCount: _nonNegativeInt(
        map,
        'stationaryCandidateCount',
      ),
      stationaryBlockedRecentStepCount: _nonNegativeInt(
        map,
        'stationaryBlockedRecentStepCount',
      ),
      stationaryBlockedHeadingMotionCount: _nonNegativeInt(
        map,
        'stationaryBlockedHeadingMotionCount',
      ),
      stationaryBlockedArcoreMotionCount: _nonNegativeInt(
        map,
        'stationaryBlockedArcoreMotionCount',
      ),
      stationaryBlockedOtherMotionCount: _nonNegativeInt(
        map,
        'stationaryBlockedOtherMotionCount',
      ),
      stationaryDriftM: _nonNegativeDouble(map, 'stationaryDriftM'),
      stepsReceived: stepsReceived,
      stepsApplied: stepsApplied,
      finalDrainDurationMs: finalDrainDurationMs,
      stepsReceivedDuringFinalDrainCallbackDelivery: drainDeliveredSteps,
      strideEstimateBeforeM: strideBefore,
      strideEstimateAfterM: strideAfter,
      strideCalibrationSamples: _nonNegativeInt(
        map,
        'strideCalibrationSamples',
      ),
      headingOffsetBeforeDeg: headingBefore,
      headingOffsetAfterDeg: headingAfter,
      headingOffsetSamples: _nonNegativeInt(map, 'headingOffsetSamples'),
      arcoreAccepted: _nonNegativeInt(map, 'arcoreAccepted'),
      arcoreRejected: _nonNegativeInt(map, 'arcoreRejected'),
      arcoreNisMean: _nonNegativeDouble(map, 'arcoreNisMean'),
      arcoreNisMax: _nonNegativeDouble(map, 'arcoreNisMax'),
      arcorePreRobustNisMean: _nonNegativeDouble(map, 'arcorePreRobustNisMean'),
      arcorePreRobustNisMax: _nonNegativeDouble(map, 'arcorePreRobustNisMax'),
      arcorePostRobustNisMean: _nonNegativeDouble(
        map,
        'arcorePostRobustNisMean',
      ),
      arcorePostRobustNisMax: _nonNegativeDouble(map, 'arcorePostRobustNisMax'),
      arcoreAcceptedAfterRobustInflationCount: _nonNegativeInt(
        map,
        'arcoreAcceptedAfterRobustInflationCount',
      ),
      arcoreRejectedAfterMaxInflationCount: _nonNegativeInt(
        map,
        'arcoreRejectedAfterMaxInflationCount',
      ),
      headingAccepted: _nonNegativeInt(map, 'headingAccepted'),
      headingRejected: _nonNegativeInt(map, 'headingRejected'),
      sourceDisagreementMeanM: _nonNegativeDouble(
        map,
        'sourceDisagreementMeanM',
      ),
      sourceDisagreementMaxM: _nonNegativeDouble(map, 'sourceDisagreementMaxM'),
      profilePersisted: profilePersisted,
    );
  }

  final bool stationaryDetected;
  final bool stationaryCurrentlyDetected;
  final bool stationaryEverDetected;
  final int stationaryEntryCount;
  final int stationaryDetectedDurationMs;
  final int stationaryCandidateCount;
  final int stationaryBlockedRecentStepCount;
  final int stationaryBlockedHeadingMotionCount;
  final int stationaryBlockedArcoreMotionCount;
  final int stationaryBlockedOtherMotionCount;
  final double stationaryDriftM;
  final int stepsReceived;
  final int stepsApplied;
  final int finalDrainDurationMs;
  final int stepsReceivedDuringFinalDrainCallbackDelivery;
  final double strideEstimateBeforeM;
  final double strideEstimateAfterM;
  final int strideCalibrationSamples;
  final double headingOffsetBeforeDeg;
  final double headingOffsetAfterDeg;
  final int headingOffsetSamples;
  final int arcoreAccepted;
  final int arcoreRejected;
  final double arcoreNisMean;
  final double arcoreNisMax;
  final double arcorePreRobustNisMean;
  final double arcorePreRobustNisMax;
  final double arcorePostRobustNisMean;
  final double arcorePostRobustNisMax;
  final int arcoreAcceptedAfterRobustInflationCount;
  final int arcoreRejectedAfterMaxInflationCount;
  final int headingAccepted;
  final int headingRejected;
  final double sourceDisagreementMeanM;
  final double sourceDisagreementMaxM;
  final bool profilePersisted;

  Map<String, Object?> get sanitizedMetadata => <String, Object?>{
    'sessionLabel': 'DEVELOPMENT_CALIBRATION_SESSION',
    'stationaryDetected': stationaryDetected,
    'stationaryCurrentlyDetected': stationaryCurrentlyDetected,
    'stationaryEverDetected': stationaryEverDetected,
    'stationaryEntryCount': stationaryEntryCount,
    'stationaryDetectedDurationMs': stationaryDetectedDurationMs,
    'stationaryCandidateCount': stationaryCandidateCount,
    'stationaryBlockedRecentStepCount': stationaryBlockedRecentStepCount,
    'stationaryBlockedHeadingMotionCount': stationaryBlockedHeadingMotionCount,
    'stationaryBlockedArcoreMotionCount': stationaryBlockedArcoreMotionCount,
    'stationaryBlockedOtherMotionCount': stationaryBlockedOtherMotionCount,
    'stationaryDriftM': stationaryDriftM,
    'stepsReceived': stepsReceived,
    'stepsApplied': stepsApplied,
    'finalDrainDurationMs': finalDrainDurationMs,
    'stepsReceivedDuringFinalDrainCallbackDelivery':
        stepsReceivedDuringFinalDrainCallbackDelivery,
    'strideEstimateBeforeM': strideEstimateBeforeM,
    'strideEstimateAfterM': strideEstimateAfterM,
    'strideCalibrationSamples': strideCalibrationSamples,
    'headingOffsetBeforeDeg': headingOffsetBeforeDeg,
    'headingOffsetAfterDeg': headingOffsetAfterDeg,
    'headingOffsetSamples': headingOffsetSamples,
    'arcoreAccepted': arcoreAccepted,
    'arcoreRejected': arcoreRejected,
    'arcoreNisMean': arcoreNisMean,
    'arcoreNisMax': arcoreNisMax,
    'arcorePreRobustNisMean': arcorePreRobustNisMean,
    'arcorePreRobustNisMax': arcorePreRobustNisMax,
    'arcorePostRobustNisMean': arcorePostRobustNisMean,
    'arcorePostRobustNisMax': arcorePostRobustNisMax,
    'arcoreAcceptedAfterRobustInflationCount':
        arcoreAcceptedAfterRobustInflationCount,
    'arcoreRejectedAfterMaxInflationCount':
        arcoreRejectedAfterMaxInflationCount,
    'headingAccepted': headingAccepted,
    'headingRejected': headingRejected,
    'sourceDisagreementMeanM': sourceDisagreementMeanM,
    'sourceDisagreementMaxM': sourceDisagreementMaxM,
    'profilePersisted': profilePersisted,
    'rawDataReturned': false,
    'accuracyValidated': false,
  };
}

class AccuracyV2GnssStabilizationDiagnostics {
  const AccuracyV2GnssStabilizationDiagnostics({
    required this.receivedFixCount,
    required this.acceptedFixCount,
    required this.rejectedStructuralCount,
    required this.rejectedAccuracyCount,
    required this.rejectedMockCount,
    required this.rejectedNonMonotonicCount,
    required this.reportedAccuracyMinM,
    required this.reportedAccuracyMedianM,
    required this.reportedAccuracyMaxM,
    required this.observedDurationMs,
    required this.targetFixCount,
    required this.minimumFixCount,
    required this.degraded,
    required this.reason,
  });

  factory AccuracyV2GnssStabilizationDiagnostics.fromPlatformErrorDetails(
    Object? raw,
  ) {
    final Map<Object?, Object?> map = _strictMap(raw);
    _expectSchema(map, 'navguard_accuracy_v2_gnss_stabilization_diagnostics');
    _expectFalse(map, 'rawCoordinatesReturned');
    _expectFalse(map, 'rawTimestampsReturned');
    return AccuracyV2GnssStabilizationDiagnostics._fromMap(map);
  }

  factory AccuracyV2GnssStabilizationDiagnostics.fromBenchmarkMap(
    Map<Object?, Object?> map,
  ) => AccuracyV2GnssStabilizationDiagnostics._fromMap(map);

  factory AccuracyV2GnssStabilizationDiagnostics._fromMap(
    Map<Object?, Object?> map,
  ) {
    final int received = _nonNegativeInt(
      map,
      'gnssStabilizationReceivedFixCount',
    );
    final int accepted = _nonNegativeInt(
      map,
      'gnssStabilizationAcceptedFixCount',
    );
    final int structural = _nonNegativeInt(
      map,
      'gnssStabilizationRejectedStructuralCount',
    );
    final int accuracy = _nonNegativeInt(
      map,
      'gnssStabilizationRejectedAccuracyCount',
    );
    final int mock = _nonNegativeInt(map, 'gnssStabilizationRejectedMockCount');
    final int nonMonotonic = _nonNegativeInt(
      map,
      'gnssStabilizationRejectedNonMonotonicCount',
    );
    final double? accuracyMin = _nullableNonNegativeDouble(
      map,
      'gnssStabilizationReportedAccuracyMinM',
    );
    final double? accuracyMedian = _nullableNonNegativeDouble(
      map,
      'gnssStabilizationReportedAccuracyMedianM',
    );
    final double? accuracyMax = _nullableNonNegativeDouble(
      map,
      'gnssStabilizationReportedAccuracyMaxM',
    );
    final int target = _nonNegativeInt(map, 'gnssStabilizationTargetFixCount');
    final int minimum = _nonNegativeInt(
      map,
      'gnssStabilizationMinimumFixCount',
    );
    final bool degraded = _bool(map, 'gnssStabilizationDegraded');
    final Object? rawReason = map['gnssStabilizationReason'];
    if (rawReason is! String ||
        !<String>{
          'target_met',
          'accepted_less_than_target',
          'accepted_below_minimum',
        }.contains(rawReason) ||
        target != 5 ||
        minimum != 3 ||
        accepted + structural + accuracy + mock + nonMonotonic != received ||
        (accuracyMin == null) != (accuracyMedian == null) ||
        (accuracyMedian == null) != (accuracyMax == null) ||
        (accuracyMin != null &&
            (accuracyMin > accuracyMedian! || accuracyMedian > accuracyMax!)) ||
        (rawReason == 'target_met' && (degraded || accepted < target)) ||
        (rawReason == 'accepted_less_than_target' &&
            (!degraded || accepted < minimum || accepted >= target)) ||
        (rawReason == 'accepted_below_minimum' &&
            (degraded || accepted >= minimum))) {
      throw const FormatException('Invalid GNSS stabilization diagnostics.');
    }
    return AccuracyV2GnssStabilizationDiagnostics(
      receivedFixCount: received,
      acceptedFixCount: accepted,
      rejectedStructuralCount: structural,
      rejectedAccuracyCount: accuracy,
      rejectedMockCount: mock,
      rejectedNonMonotonicCount: nonMonotonic,
      reportedAccuracyMinM: accuracyMin,
      reportedAccuracyMedianM: accuracyMedian,
      reportedAccuracyMaxM: accuracyMax,
      observedDurationMs: _nonNegativeInt(
        map,
        'gnssStabilizationObservedDurationMs',
      ),
      targetFixCount: target,
      minimumFixCount: minimum,
      degraded: degraded,
      reason: rawReason,
    );
  }

  final int receivedFixCount;
  final int acceptedFixCount;
  final int rejectedStructuralCount;
  final int rejectedAccuracyCount;
  final int rejectedMockCount;
  final int rejectedNonMonotonicCount;
  final double? reportedAccuracyMinM;
  final double? reportedAccuracyMedianM;
  final double? reportedAccuracyMaxM;
  final int observedDurationMs;
  final int targetFixCount;
  final int minimumFixCount;
  final bool degraded;
  final String reason;

  Map<String, Object?> get sanitizedMetadata => <String, Object?>{
    'gnssStabilizationReceivedFixCount': receivedFixCount,
    'gnssStabilizationAcceptedFixCount': acceptedFixCount,
    'gnssStabilizationRejectedStructuralCount': rejectedStructuralCount,
    'gnssStabilizationRejectedAccuracyCount': rejectedAccuracyCount,
    'gnssStabilizationRejectedMockCount': rejectedMockCount,
    'gnssStabilizationRejectedNonMonotonicCount': rejectedNonMonotonicCount,
    'gnssStabilizationReportedAccuracyMinM': reportedAccuracyMinM,
    'gnssStabilizationReportedAccuracyMedianM': reportedAccuracyMedianM,
    'gnssStabilizationReportedAccuracyMaxM': reportedAccuracyMaxM,
    'gnssStabilizationObservedDurationMs': observedDurationMs,
    'gnssStabilizationTargetFixCount': targetFixCount,
    'gnssStabilizationMinimumFixCount': minimumFixCount,
    'gnssStabilizationDegraded': degraded,
    'gnssStabilizationReason': reason,
    'rawCoordinatesReturned': false,
    'rawTimestampsReturned': false,
  };
}

class DevelopmentBenchmarkConfigMetrics {
  const DevelopmentBenchmarkConfigMetrics({
    required this.configId,
    required this.matchedGtCount,
    required this.meanHorizontalErrorM,
    required this.medianHorizontalErrorM,
    required this.p95HorizontalErrorM,
    required this.maxHorizontalErrorM,
    required this.finalPreCorrectionHorizontalErrorM,
    required this.relativeMeanHorizontalErrorM,
    required this.relativeMedianHorizontalErrorM,
    required this.relativeP95HorizontalErrorM,
    required this.relativeMaxHorizontalErrorM,
    required this.relativeFinalHorizontalErrorM,
  });

  factory DevelopmentBenchmarkConfigMetrics.fromPlatform(
    Object? raw,
    String expectedId,
  ) {
    final Map<Object?, Object?> map = _strictMap(raw);
    final String configId = _expectString(map, 'configId', expectedId);
    return DevelopmentBenchmarkConfigMetrics(
      configId: configId,
      matchedGtCount: _nonNegativeInt(map, 'matchedGtCount'),
      meanHorizontalErrorM: _nullableNonNegativeDouble(
        map,
        'meanHorizontalErrorM',
      ),
      medianHorizontalErrorM: _nullableNonNegativeDouble(
        map,
        'medianHorizontalErrorM',
      ),
      p95HorizontalErrorM: _nullableNonNegativeDouble(
        map,
        'p95HorizontalErrorM',
      ),
      maxHorizontalErrorM: _nullableNonNegativeDouble(
        map,
        'maxHorizontalErrorM',
      ),
      finalPreCorrectionHorizontalErrorM: _nullableNonNegativeDouble(
        map,
        'finalPreCorrectionHorizontalErrorM',
      ),
      relativeMeanHorizontalErrorM: _nullableNonNegativeDouble(
        map,
        'relativeMeanHorizontalErrorM',
      ),
      relativeMedianHorizontalErrorM: _nullableNonNegativeDouble(
        map,
        'relativeMedianHorizontalErrorM',
      ),
      relativeP95HorizontalErrorM: _nullableNonNegativeDouble(
        map,
        'relativeP95HorizontalErrorM',
      ),
      relativeMaxHorizontalErrorM: _nullableNonNegativeDouble(
        map,
        'relativeMaxHorizontalErrorM',
      ),
      relativeFinalHorizontalErrorM: _nullableNonNegativeDouble(
        map,
        'relativeFinalHorizontalErrorM',
      ),
    );
  }

  final String configId;
  final int matchedGtCount;
  final double? meanHorizontalErrorM;
  final double? medianHorizontalErrorM;
  final double? p95HorizontalErrorM;
  final double? maxHorizontalErrorM;
  final double? finalPreCorrectionHorizontalErrorM;
  final double? relativeMeanHorizontalErrorM;
  final double? relativeMedianHorizontalErrorM;
  final double? relativeP95HorizontalErrorM;
  final double? relativeMaxHorizontalErrorM;
  final double? relativeFinalHorizontalErrorM;

  Map<String, Object?> get sanitizedMetadata => <String, Object?>{
    'configId': configId,
    'matchedGtCount': matchedGtCount,
    'meanHorizontalErrorM': meanHorizontalErrorM,
    'medianHorizontalErrorM': medianHorizontalErrorM,
    'p95HorizontalErrorM': p95HorizontalErrorM,
    'maxHorizontalErrorM': maxHorizontalErrorM,
    'finalPreCorrectionHorizontalErrorM': finalPreCorrectionHorizontalErrorM,
    'relativeMeanHorizontalErrorM': relativeMeanHorizontalErrorM,
    'relativeMedianHorizontalErrorM': relativeMedianHorizontalErrorM,
    'relativeP95HorizontalErrorM': relativeP95HorizontalErrorM,
    'relativeMaxHorizontalErrorM': relativeMaxHorizontalErrorM,
    'relativeFinalHorizontalErrorM': relativeFinalHorizontalErrorM,
  };
}

class AccuracyV2DevelopmentBenchmarkResult {
  const AccuracyV2DevelopmentBenchmarkResult({
    required this.developmentScenario,
    required this.developmentBenchmarkFinalDrainMs,
    required this.benchmarkStepEventsReceivedTotal,
    required this.benchmarkStepEventsInFormalWindow,
    required this.benchmarkStepEventsDeliveredDuringFinalDrain,
    required this.benchmarkStepEventsIncludedFromFinalDrain,
    required this.benchmarkStepEventsExcludedPostWindow,
    required this.configAStepsApplied,
    required this.configD1StepsApplied,
    required this.configD2StepsApplied,
    required this.configA,
    required this.configD1,
    required this.configD2,
    required this.d2VsD1MedianImprovementPercent,
    required this.d2VsAMedianImprovementPercent,
    required this.d2VsD1RelativeMedianImprovementPercent,
    required this.d2VsARelativeMedianImprovementPercent,
    required this.configAInitialMatchedBiasM,
    required this.configD1InitialMatchedBiasM,
    required this.configD2InitialMatchedBiasM,
    required this.strideEstimateFinalM,
    required this.strideEstimateMeanM,
    required this.strideCalibrationSampleCount,
    required this.bodyHeadingOffsetFinalDeg,
    required this.arcoreAcceptedCount,
    required this.arcoreAcceptedNominalCount,
    required this.arcoreAcceptedInflatedCount,
    required this.arcoreRejectedByQualityCount,
    required this.arcoreRejectedByInnovationCount,
    required this.arcoreAcceptedAfterRobustInflationCount,
    required this.arcoreRejectedAfterMaxInflationCount,
    required this.arcorePreRobustNisMean,
    required this.arcorePreRobustNisMax,
    required this.arcorePostRobustNisMean,
    required this.arcorePostRobustNisMax,
    required this.arcoreAdaptiveSigmaMeanM,
    required this.arcoreAdaptiveSigmaMaxM,
    required this.arcoreRobustSigmaMeanM,
    required this.arcoreRobustSigmaMaxM,
    required this.headingAcceptedCount,
    required this.headingRejectedCount,
    required this.stationaryDetectedDurationMs,
    required this.stationaryEntryCount,
    required this.stationaryCandidateCount,
    required this.stationaryBlockedRecentStepCount,
    required this.stationaryBlockedHeadingMotionCount,
    required this.stationaryBlockedArcoreMotionCount,
    required this.stationaryBlockedOtherMotionCount,
    required this.stationaryArcoreSuppressedCount,
    required this.sourceDisagreementMeanM,
    required this.sourceDisagreementMaxM,
    required this.gnssStabilization,
    required this.gnssStabilizationFixCount,
    required this.gnssStabilizationEastSpreadM,
    required this.gnssStabilizationNorthSpreadM,
    required this.gnssStabilizationHorizontalSpreadM,
    required this.gnssStabilizationReportedAccuracyMedianM,
    required this.gtMutationInvariant,
    required this.gtRemovalInvariant,
  });

  factory AccuracyV2DevelopmentBenchmarkResult.fromPlatform(Object? raw) {
    final Map<Object?, Object?> map = _strictMap(raw);
    _expectSchema(map, 'navguard_accuracy_v2_development_benchmark_result');
    _expectString(
      map,
      'sessionLabel',
      'DEVELOPMENT_SESSION_NOT_FINAL_VALIDATION',
    );
    _expectString(
      map,
      'eventOrdering',
      'HEADING_STEP_ARCORE_POSITION_INSERTION_SEQUENCE',
    );
    _expectTrue(map, 'sameSessionCapture');
    _expectTrue(map, 'protectedGroundTruthComparatorOnly');
    if (_nonNegativeInt(map, 'protectedGtEstimatorAccessCount') != 0) {
      throw const FormatException('Invalid Accuracy v2 benchmark firewall.');
    }
    _expectFalse(map, 'rawLocationReturned');
    _expectFalse(map, 'rawSensorStreamReturned');
    _expectFalse(map, 'rawArcorePoseReturned');
    _expectFalse(map, 'rawTimestampsReturned');
    _expectFalse(map, 'rawTrajectoryReturned');
    _expectTrue(map, 'developmentMetricsOnly');
    _expectFalse(map, 'finalValidation');
    _expectFalse(map, 'accuracyValidated');
    final double strideFinal = _finiteDouble(map, 'strideEstimateFinalM');
    final double headingOffset = _finiteDouble(
      map,
      'bodyHeadingOffsetFinalDeg',
    );
    if (strideFinal < 0.45 ||
        strideFinal > 1.05 ||
        headingOffset.abs() > 25.000001) {
      throw const FormatException('Invalid Accuracy v2 benchmark result.');
    }
    final AccuracyV2GnssStabilizationDiagnostics stabilization =
        AccuracyV2GnssStabilizationDiagnostics.fromBenchmarkMap(map);
    final int stabilizationFixCount = _nonNegativeInt(
      map,
      'gnssStabilizationFixCount',
    );
    if (stabilizationFixCount != stabilization.acceptedFixCount ||
        stabilization.reason == 'accepted_below_minimum') {
      throw const FormatException('Invalid GNSS stabilization result.');
    }
    final Object? rawScenario = map['developmentScenario'];
    final int finalDrainMs = _nonNegativeInt(
      map,
      'developmentBenchmarkFinalDrainMs',
    );
    final int receivedTotal = _nonNegativeInt(
      map,
      'benchmarkStepEventsReceivedTotal',
    );
    final int inFormalWindow = _nonNegativeInt(
      map,
      'benchmarkStepEventsInFormalWindow',
    );
    final int deliveredDuringDrain = _nonNegativeInt(
      map,
      'benchmarkStepEventsDeliveredDuringFinalDrain',
    );
    final int includedFromDrain = _nonNegativeInt(
      map,
      'benchmarkStepEventsIncludedFromFinalDrain',
    );
    final int excludedPostWindow = _nonNegativeInt(
      map,
      'benchmarkStepEventsExcludedPostWindow',
    );
    final int configASteps = _nonNegativeInt(map, 'configAStepsApplied');
    final int configD1Steps = _nonNegativeInt(map, 'configD1StepsApplied');
    final int configD2Steps = _nonNegativeInt(map, 'configD2StepsApplied');
    if (rawScenario is! String ||
        !accuracyV2DevelopmentScenarios.contains(rawScenario) ||
        finalDrainMs != accuracyV2DevelopmentBenchmarkFinalDrainMs ||
        inFormalWindow > receivedTotal ||
        deliveredDuringDrain > receivedTotal ||
        includedFromDrain > deliveredDuringDrain ||
        includedFromDrain > inFormalWindow ||
        excludedPostWindow > receivedTotal ||
        configASteps != inFormalWindow ||
        configD1Steps != inFormalWindow ||
        configD2Steps != inFormalWindow) {
      throw const FormatException(
        'Invalid development benchmark capture contract.',
      );
    }
    final int acceptedArcore = _nonNegativeInt(map, 'arcoreAcceptedCount');
    final int nominalArcore = _nonNegativeInt(
      map,
      'arcoreAcceptedNominalCount',
    );
    final int inflatedArcore = _nonNegativeInt(
      map,
      'arcoreAcceptedInflatedCount',
    );
    final double robustSigmaMean = _nonNegativeDouble(
      map,
      'arcoreRobustSigmaMeanM',
    );
    final double robustSigmaMax = _nonNegativeDouble(
      map,
      'arcoreRobustSigmaMaxM',
    );
    final int acceptedAfterRobustInflation = _nonNegativeInt(
      map,
      'arcoreAcceptedAfterRobustInflationCount',
    );
    final int rejectedAfterMaxInflation = _nonNegativeInt(
      map,
      'arcoreRejectedAfterMaxInflationCount',
    );
    final int rejectedByInnovation = _nonNegativeInt(
      map,
      'arcoreRejectedByInnovationCount',
    );
    final double preRobustNisMean = _nonNegativeDouble(
      map,
      'arcorePreRobustNisMean',
    );
    final double preRobustNisMax = _nonNegativeDouble(
      map,
      'arcorePreRobustNisMax',
    );
    final double postRobustNisMean = _nonNegativeDouble(
      map,
      'arcorePostRobustNisMean',
    );
    final double postRobustNisMax = _nonNegativeDouble(
      map,
      'arcorePostRobustNisMax',
    );
    if (acceptedArcore != nominalArcore + inflatedArcore ||
        acceptedAfterRobustInflation != inflatedArcore ||
        rejectedAfterMaxInflation > rejectedByInnovation ||
        robustSigmaMean < 0.35 ||
        robustSigmaMean > robustSigmaMax ||
        robustSigmaMax > 5.0 ||
        preRobustNisMean > preRobustNisMax ||
        postRobustNisMean > postRobustNisMax) {
      throw const FormatException('Invalid robust ARCore diagnostics.');
    }
    return AccuracyV2DevelopmentBenchmarkResult(
      developmentScenario: rawScenario,
      developmentBenchmarkFinalDrainMs: finalDrainMs,
      benchmarkStepEventsReceivedTotal: receivedTotal,
      benchmarkStepEventsInFormalWindow: inFormalWindow,
      benchmarkStepEventsDeliveredDuringFinalDrain: deliveredDuringDrain,
      benchmarkStepEventsIncludedFromFinalDrain: includedFromDrain,
      benchmarkStepEventsExcludedPostWindow: excludedPostWindow,
      configAStepsApplied: configASteps,
      configD1StepsApplied: configD1Steps,
      configD2StepsApplied: configD2Steps,
      configA: DevelopmentBenchmarkConfigMetrics.fromPlatform(
        map['configA'],
        deterministicPdrConfigId,
      ),
      configD1: DevelopmentBenchmarkConfigMetrics.fromPlatform(
        map['configD1'],
        navguardV1ConfigId,
      ),
      configD2: DevelopmentBenchmarkConfigMetrics.fromPlatform(
        map['configD2'],
        navguardAdaptiveConfigId,
      ),
      d2VsD1MedianImprovementPercent: _nullableFiniteDouble(
        map,
        'd2VsD1MedianImprovementPercent',
      ),
      d2VsAMedianImprovementPercent: _nullableFiniteDouble(
        map,
        'd2VsAMedianImprovementPercent',
      ),
      d2VsD1RelativeMedianImprovementPercent: _nullableFiniteDouble(
        map,
        'd2VsD1RelativeMedianImprovementPercent',
      ),
      d2VsARelativeMedianImprovementPercent: _nullableFiniteDouble(
        map,
        'd2VsARelativeMedianImprovementPercent',
      ),
      configAInitialMatchedBiasM: _nullableNonNegativeDouble(
        map,
        'configAInitialMatchedBiasM',
      ),
      configD1InitialMatchedBiasM: _nullableNonNegativeDouble(
        map,
        'configD1InitialMatchedBiasM',
      ),
      configD2InitialMatchedBiasM: _nullableNonNegativeDouble(
        map,
        'configD2InitialMatchedBiasM',
      ),
      strideEstimateFinalM: strideFinal,
      strideEstimateMeanM: _finiteDouble(map, 'strideEstimateMeanM'),
      strideCalibrationSampleCount: _nonNegativeInt(
        map,
        'strideCalibrationSampleCount',
      ),
      bodyHeadingOffsetFinalDeg: headingOffset,
      arcoreAcceptedCount: acceptedArcore,
      arcoreAcceptedNominalCount: nominalArcore,
      arcoreAcceptedInflatedCount: inflatedArcore,
      arcoreRejectedByQualityCount: _nonNegativeInt(
        map,
        'arcoreRejectedByQualityCount',
      ),
      arcoreRejectedByInnovationCount: rejectedByInnovation,
      arcoreAcceptedAfterRobustInflationCount: acceptedAfterRobustInflation,
      arcoreRejectedAfterMaxInflationCount: rejectedAfterMaxInflation,
      arcorePreRobustNisMean: preRobustNisMean,
      arcorePreRobustNisMax: preRobustNisMax,
      arcorePostRobustNisMean: postRobustNisMean,
      arcorePostRobustNisMax: postRobustNisMax,
      arcoreAdaptiveSigmaMeanM: _nonNegativeDouble(
        map,
        'arcoreAdaptiveSigmaMeanM',
      ),
      arcoreAdaptiveSigmaMaxM: _nonNegativeDouble(
        map,
        'arcoreAdaptiveSigmaMaxM',
      ),
      arcoreRobustSigmaMeanM: robustSigmaMean,
      arcoreRobustSigmaMaxM: robustSigmaMax,
      headingAcceptedCount: _nonNegativeInt(map, 'headingAcceptedCount'),
      headingRejectedCount: _nonNegativeInt(map, 'headingRejectedCount'),
      stationaryDetectedDurationMs: _nonNegativeInt(
        map,
        'stationaryDetectedDurationMs',
      ),
      stationaryEntryCount: _nonNegativeInt(map, 'stationaryEntryCount'),
      stationaryCandidateCount: _nonNegativeInt(
        map,
        'stationaryCandidateCount',
      ),
      stationaryBlockedRecentStepCount: _nonNegativeInt(
        map,
        'stationaryBlockedRecentStepCount',
      ),
      stationaryBlockedHeadingMotionCount: _nonNegativeInt(
        map,
        'stationaryBlockedHeadingMotionCount',
      ),
      stationaryBlockedArcoreMotionCount: _nonNegativeInt(
        map,
        'stationaryBlockedArcoreMotionCount',
      ),
      stationaryBlockedOtherMotionCount: _nonNegativeInt(
        map,
        'stationaryBlockedOtherMotionCount',
      ),
      stationaryArcoreSuppressedCount: _nonNegativeInt(
        map,
        'stationaryArcoreSuppressedCount',
      ),
      sourceDisagreementMeanM: _nonNegativeDouble(
        map,
        'sourceDisagreementMeanM',
      ),
      sourceDisagreementMaxM: _nonNegativeDouble(map, 'sourceDisagreementMaxM'),
      gnssStabilization: stabilization,
      gnssStabilizationFixCount: stabilizationFixCount,
      gnssStabilizationEastSpreadM: _nonNegativeDouble(
        map,
        'gnssStabilizationEastSpreadM',
      ),
      gnssStabilizationNorthSpreadM: _nonNegativeDouble(
        map,
        'gnssStabilizationNorthSpreadM',
      ),
      gnssStabilizationHorizontalSpreadM: _nonNegativeDouble(
        map,
        'gnssStabilizationHorizontalSpreadM',
      ),
      gnssStabilizationReportedAccuracyMedianM: _nonNegativeDouble(
        map,
        'gnssStabilizationReportedAccuracyMedianM',
      ),
      gtMutationInvariant: _expectTrue(map, 'gtMutationInvariant'),
      gtRemovalInvariant: _expectTrue(map, 'gtRemovalInvariant'),
    );
  }

  final String developmentScenario;
  final int developmentBenchmarkFinalDrainMs;
  final int benchmarkStepEventsReceivedTotal;
  final int benchmarkStepEventsInFormalWindow;
  final int benchmarkStepEventsDeliveredDuringFinalDrain;
  final int benchmarkStepEventsIncludedFromFinalDrain;
  final int benchmarkStepEventsExcludedPostWindow;
  final int configAStepsApplied;
  final int configD1StepsApplied;
  final int configD2StepsApplied;
  final DevelopmentBenchmarkConfigMetrics configA;
  final DevelopmentBenchmarkConfigMetrics configD1;
  final DevelopmentBenchmarkConfigMetrics configD2;
  final double? d2VsD1MedianImprovementPercent;
  final double? d2VsAMedianImprovementPercent;
  final double? d2VsD1RelativeMedianImprovementPercent;
  final double? d2VsARelativeMedianImprovementPercent;
  final double? configAInitialMatchedBiasM;
  final double? configD1InitialMatchedBiasM;
  final double? configD2InitialMatchedBiasM;
  final double strideEstimateFinalM;
  final double strideEstimateMeanM;
  final int strideCalibrationSampleCount;
  final double bodyHeadingOffsetFinalDeg;
  final int arcoreAcceptedCount;
  final int arcoreAcceptedNominalCount;
  final int arcoreAcceptedInflatedCount;
  final int arcoreRejectedByQualityCount;
  final int arcoreRejectedByInnovationCount;
  final int arcoreAcceptedAfterRobustInflationCount;
  final int arcoreRejectedAfterMaxInflationCount;
  final double arcorePreRobustNisMean;
  final double arcorePreRobustNisMax;
  final double arcorePostRobustNisMean;
  final double arcorePostRobustNisMax;
  final double arcoreAdaptiveSigmaMeanM;
  final double arcoreAdaptiveSigmaMaxM;
  final double arcoreRobustSigmaMeanM;
  final double arcoreRobustSigmaMaxM;
  final int headingAcceptedCount;
  final int headingRejectedCount;
  final int stationaryDetectedDurationMs;
  final int stationaryEntryCount;
  final int stationaryCandidateCount;
  final int stationaryBlockedRecentStepCount;
  final int stationaryBlockedHeadingMotionCount;
  final int stationaryBlockedArcoreMotionCount;
  final int stationaryBlockedOtherMotionCount;
  final int stationaryArcoreSuppressedCount;
  final double sourceDisagreementMeanM;
  final double sourceDisagreementMaxM;
  final AccuracyV2GnssStabilizationDiagnostics gnssStabilization;
  final int gnssStabilizationFixCount;
  final double gnssStabilizationEastSpreadM;
  final double gnssStabilizationNorthSpreadM;
  final double gnssStabilizationHorizontalSpreadM;
  final double gnssStabilizationReportedAccuracyMedianM;
  final bool gtMutationInvariant;
  final bool gtRemovalInvariant;

  Map<String, Object?> get sanitizedMetadata => <String, Object?>{
    'sessionLabel': 'DEVELOPMENT_SESSION_NOT_FINAL_VALIDATION',
    'developmentScenario': developmentScenario,
    'developmentBenchmarkFinalDrainMs': developmentBenchmarkFinalDrainMs,
    'benchmarkStepEventsReceivedTotal': benchmarkStepEventsReceivedTotal,
    'benchmarkStepEventsInFormalWindow': benchmarkStepEventsInFormalWindow,
    'benchmarkStepEventsDeliveredDuringFinalDrain':
        benchmarkStepEventsDeliveredDuringFinalDrain,
    'benchmarkStepEventsIncludedFromFinalDrain':
        benchmarkStepEventsIncludedFromFinalDrain,
    'benchmarkStepEventsExcludedPostWindow':
        benchmarkStepEventsExcludedPostWindow,
    'configAStepsApplied': configAStepsApplied,
    'configD1StepsApplied': configD1StepsApplied,
    'configD2StepsApplied': configD2StepsApplied,
    'configA': configA.sanitizedMetadata,
    'configD1': configD1.sanitizedMetadata,
    'configD2': configD2.sanitizedMetadata,
    'd2VsD1MedianImprovementPercent': d2VsD1MedianImprovementPercent,
    'd2VsAMedianImprovementPercent': d2VsAMedianImprovementPercent,
    'd2VsD1RelativeMedianImprovementPercent':
        d2VsD1RelativeMedianImprovementPercent,
    'd2VsARelativeMedianImprovementPercent':
        d2VsARelativeMedianImprovementPercent,
    'configAInitialMatchedBiasM': configAInitialMatchedBiasM,
    'configD1InitialMatchedBiasM': configD1InitialMatchedBiasM,
    'configD2InitialMatchedBiasM': configD2InitialMatchedBiasM,
    'strideEstimateFinalM': strideEstimateFinalM,
    'strideEstimateMeanM': strideEstimateMeanM,
    'strideCalibrationSampleCount': strideCalibrationSampleCount,
    'bodyHeadingOffsetFinalDeg': bodyHeadingOffsetFinalDeg,
    'arcoreAcceptedCount': arcoreAcceptedCount,
    'arcoreAcceptedNominalCount': arcoreAcceptedNominalCount,
    'arcoreAcceptedInflatedCount': arcoreAcceptedInflatedCount,
    'arcoreRejectedByQualityCount': arcoreRejectedByQualityCount,
    'arcoreRejectedByInnovationCount': arcoreRejectedByInnovationCount,
    'arcoreAcceptedAfterRobustInflationCount':
        arcoreAcceptedAfterRobustInflationCount,
    'arcoreRejectedAfterMaxInflationCount':
        arcoreRejectedAfterMaxInflationCount,
    'arcorePreRobustNisMean': arcorePreRobustNisMean,
    'arcorePreRobustNisMax': arcorePreRobustNisMax,
    'arcorePostRobustNisMean': arcorePostRobustNisMean,
    'arcorePostRobustNisMax': arcorePostRobustNisMax,
    'arcoreAdaptiveSigmaMeanM': arcoreAdaptiveSigmaMeanM,
    'arcoreAdaptiveSigmaMaxM': arcoreAdaptiveSigmaMaxM,
    'arcoreRobustSigmaMeanM': arcoreRobustSigmaMeanM,
    'arcoreRobustSigmaMaxM': arcoreRobustSigmaMaxM,
    'headingAcceptedCount': headingAcceptedCount,
    'headingRejectedCount': headingRejectedCount,
    'stationaryDetectedDurationMs': stationaryDetectedDurationMs,
    'stationaryEntryCount': stationaryEntryCount,
    'stationaryCandidateCount': stationaryCandidateCount,
    'stationaryBlockedRecentStepCount': stationaryBlockedRecentStepCount,
    'stationaryBlockedHeadingMotionCount': stationaryBlockedHeadingMotionCount,
    'stationaryBlockedArcoreMotionCount': stationaryBlockedArcoreMotionCount,
    'stationaryBlockedOtherMotionCount': stationaryBlockedOtherMotionCount,
    'stationaryArcoreSuppressedCount': stationaryArcoreSuppressedCount,
    'sourceDisagreementMeanM': sourceDisagreementMeanM,
    'sourceDisagreementMaxM': sourceDisagreementMaxM,
    ...gnssStabilization.sanitizedMetadata,
    'gnssStabilizationFixCount': gnssStabilizationFixCount,
    'gnssStabilizationEastSpreadM': gnssStabilizationEastSpreadM,
    'gnssStabilizationNorthSpreadM': gnssStabilizationNorthSpreadM,
    'gnssStabilizationHorizontalSpreadM': gnssStabilizationHorizontalSpreadM,
    'gnssStabilizationReportedAccuracyMedianM':
        gnssStabilizationReportedAccuracyMedianM,
    'gtMutationInvariant': gtMutationInvariant,
    'gtRemovalInvariant': gtRemovalInvariant,
    'protectedGtEstimatorAccessCount': 0,
    'developmentMetricsOnly': true,
    'accuracyValidated': false,
  };
}

Map<Object?, Object?> _strictMap(Object? raw) {
  if (raw is! Map<Object?, Object?>) {
    throw const FormatException('Invalid Accuracy v2 native response.');
  }
  return raw;
}

void _expectSchema(Map<Object?, Object?> map, String kind) {
  if (map['schemaVersion'] != 1 || map['snapshotKind'] != kind) {
    throw const FormatException('Unsupported Accuracy v2 native response.');
  }
}

String _expectString(Map<Object?, Object?> map, String key, String expected) {
  final Object? value = map[key];
  if (value != expected) {
    throw const FormatException('Invalid Accuracy v2 native response.');
  }
  return value! as String;
}

bool _bool(Map<Object?, Object?> map, String key) {
  final Object? value = map[key];
  if (value is! bool) {
    throw const FormatException('Invalid Accuracy v2 native response.');
  }
  return value;
}

bool _expectTrue(Map<Object?, Object?> map, String key) {
  if (_bool(map, key) != true) {
    throw const FormatException('Invalid Accuracy v2 integrity contract.');
  }
  return true;
}

bool _expectFalse(Map<Object?, Object?> map, String key) {
  if (_bool(map, key) != false) {
    throw const FormatException('Invalid Accuracy v2 privacy contract.');
  }
  return false;
}

int _nonNegativeInt(Map<Object?, Object?> map, String key) {
  final Object? raw = map[key];
  if (raw is! num || !raw.isFinite || raw < 0 || raw.toInt() != raw) {
    throw const FormatException('Invalid Accuracy v2 aggregate counter.');
  }
  return raw.toInt();
}

double _finiteDouble(Map<Object?, Object?> map, String key) {
  final Object? raw = map[key];
  if (raw is! num || !raw.isFinite) {
    throw const FormatException('Invalid Accuracy v2 aggregate metric.');
  }
  return raw.toDouble();
}

double _nonNegativeDouble(Map<Object?, Object?> map, String key) {
  final double value = _finiteDouble(map, key);
  if (value < 0) {
    throw const FormatException('Invalid Accuracy v2 aggregate metric.');
  }
  return value;
}

double? _nullableFiniteDouble(Map<Object?, Object?> map, String key) {
  if (map[key] == null) return null;
  return _finiteDouble(map, key);
}

double? _nullableNonNegativeDouble(Map<Object?, Object?> map, String key) {
  if (map[key] == null) return null;
  return _nonNegativeDouble(map, key);
}
