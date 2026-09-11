import 'dart:math' as math;

import 'navguard_fusion.dart';

const double maxOperationalGnssAccuracyM = 50;
const int initialRequiredConsecutiveGnssFixes = 3;
const int recoveryRequiredConsecutiveGoodFixes = 3;

enum FullNavguardFlowState {
  idle('IDLE'),
  acquiringGnss('ACQUIRING_GNSS'),
  normalGnss('NORMAL_GNSS'),
  deniedNavguard('DENIED_NAVGUARD'),
  recoveryPending('RECOVERY_PENDING'),
  recoveredGnss('RECOVERED_GNSS'),
  completed('COMPLETED'),
  cancelled('CANCELLED'),
  failed('FAILED');

  const FullNavguardFlowState(this.wireValue);

  final String wireValue;

  static FullNavguardFlowState parse(Object? raw) {
    for (final FullNavguardFlowState state in values) {
      if (raw == state.wireValue) {
        return state;
      }
    }
    throw const FormatException('Invalid full-flow state.');
  }
}

const List<FullNavguardFlowState> fullNavguardSuccessfulStateOrder =
    <FullNavguardFlowState>[
      FullNavguardFlowState.idle,
      FullNavguardFlowState.acquiringGnss,
      FullNavguardFlowState.normalGnss,
      FullNavguardFlowState.deniedNavguard,
      FullNavguardFlowState.recoveryPending,
      FullNavguardFlowState.recoveredGnss,
      FullNavguardFlowState.completed,
    ];

bool isValidFullNavguardTransition(
  FullNavguardFlowState from,
  FullNavguardFlowState to,
) {
  if (to == FullNavguardFlowState.cancelled ||
      to == FullNavguardFlowState.failed) {
    return from != FullNavguardFlowState.completed &&
        from != FullNavguardFlowState.cancelled &&
        from != FullNavguardFlowState.failed;
  }
  final int index = fullNavguardSuccessfulStateOrder.indexOf(from);
  return index >= 0 &&
      index + 1 < fullNavguardSuccessfulStateOrder.length &&
      fullNavguardSuccessfulStateOrder[index + 1] == to;
}

class RecoveryFixCandidate {
  const RecoveryFixCandidate({
    required this.elapsedRealtimeNanos,
    required this.horizontalAccuracyM,
    this.providerIsGps = true,
    this.coordinatesStructurallyValid = true,
    this.hasAccuracy = true,
    this.isMock = false,
  });

  final int elapsedRealtimeNanos;
  final double horizontalAccuracyM;
  final bool providerIsGps;
  final bool coordinatesStructurallyValid;
  final bool hasAccuracy;
  final bool isMock;
}

enum RecoveryFixAdmission {
  accepted,
  preGate,
  structurallyInvalid,
  duplicateOrNonMonotonic,
  qualityRejected,
}

RecoveryFixAdmission classifyRecoveryFix({
  required RecoveryFixCandidate fix,
  required int recoveryGateElapsedRealtimeNanos,
  int? previousAcceptedElapsedRealtimeNanos,
}) {
  if (fix.elapsedRealtimeNanos < recoveryGateElapsedRealtimeNanos) {
    return RecoveryFixAdmission.preGate;
  }
  if (!fix.providerIsGps ||
      !fix.coordinatesStructurallyValid ||
      !fix.hasAccuracy ||
      fix.isMock ||
      fix.elapsedRealtimeNanos <= 0 ||
      !fix.horizontalAccuracyM.isFinite ||
      fix.horizontalAccuracyM <= 0) {
    return RecoveryFixAdmission.structurallyInvalid;
  }
  if (previousAcceptedElapsedRealtimeNanos != null &&
      fix.elapsedRealtimeNanos <= previousAcceptedElapsedRealtimeNanos) {
    return RecoveryFixAdmission.duplicateOrNonMonotonic;
  }
  if (fix.horizontalAccuracyM > maxOperationalGnssAccuracyM) {
    return RecoveryFixAdmission.qualityRejected;
  }
  return RecoveryFixAdmission.accepted;
}

class ConsecutiveRecoveryGate {
  const ConsecutiveRecoveryGate({
    this.consecutiveGoodFixes = 0,
    this.recovered = false,
  });

  final int consecutiveGoodFixes;
  final bool recovered;

  ConsecutiveRecoveryGate apply(RecoveryFixAdmission admission) {
    if (recovered) {
      return this;
    }
    if (admission == RecoveryFixAdmission.accepted) {
      final int next = consecutiveGoodFixes + 1;
      return ConsecutiveRecoveryGate(
        consecutiveGoodFixes: next,
        recovered: next >= recoveryRequiredConsecutiveGoodFixes,
      );
    }
    if (admission == RecoveryFixAdmission.qualityRejected) {
      return const ConsecutiveRecoveryGate();
    }
    return this;
  }
}

double calculateRecoveryCorrectionDistanceM({
  required double deniedEastM,
  required double deniedNorthM,
  required double recoveredEastM,
  required double recoveredNorthM,
}) {
  final double eastDelta = recoveredEastM - deniedEastM;
  final double northDelta = recoveredNorthM - deniedNorthM;
  return math.sqrt((eastDelta * eastDelta) + (northDelta * northDelta));
}

NavguardFusionEstimate applyRecoveryPositionReset({
  required NavguardFusionEstimate deniedEstimate,
  required double recoveredEastM,
  required double recoveredNorthM,
  required double acceptedAccuracyM,
}) {
  if (!recoveredEastM.isFinite ||
      !recoveredNorthM.isFinite ||
      !acceptedAccuracyM.isFinite ||
      acceptedAccuracyM <= 0) {
    throw const FormatException('Invalid recovery reset input.');
  }
  final double horizontalVariance = acceptedAccuracyM * acceptedAccuracyM;
  final double headingVariance = deniedEstimate.covariance.at(2, 2);
  if (!headingVariance.isFinite || headingVariance < 0) {
    throw const FormatException('Invalid recovery heading variance.');
  }
  return NavguardFusionEstimate(
    eastM: recoveredEastM,
    northM: recoveredNorthM,
    headingRad: deniedEstimate.headingRad,
    covariance: NavguardMatrix3.diagonal(
      horizontalVariance,
      horizontalVariance,
      headingVariance,
    ),
  );
}

class DeniedHeadingSample {
  const DeniedHeadingSample({
    required this.timestampNanos,
    required this.headingRad,
    required this.quality,
  });

  final int timestampNanos;
  final double headingRad;
  final NavguardQuality quality;
}

class DeniedStepAssociation {
  const DeniedStepAssociation({
    required this.stepTimestampNanos,
    required this.headingTimestampNanos,
    required this.headingRad,
    required this.pdrQuality,
    required this.applied,
  });

  final int stepTimestampNanos;
  final int? headingTimestampNanos;
  final double? headingRad;
  final NavguardQuality pdrQuality;
  final bool applied;
}

class DeniedPdrReplayResult {
  DeniedPdrReplayResult({
    required List<DeniedStepAssociation> associations,
    required this.predictionsApplied,
    required this.predictionsSkippedNoHeading,
    required this.predictionsSkippedByQuality,
    required this.acceptedStepOpportunityCount,
  }) : associations = List<DeniedStepAssociation>.unmodifiable(associations);

  final List<DeniedStepAssociation> associations;
  final int predictionsApplied;
  final int predictionsSkippedNoHeading;
  final int predictionsSkippedByQuality;
  final int acceptedStepOpportunityCount;

  bool get counterInvariantHolds =>
      predictionsApplied +
          predictionsSkippedNoHeading +
          predictionsSkippedByQuality ==
      acceptedStepOpportunityCount;
}

DeniedPdrReplayResult replayDeniedPdrCausally({
  required List<DeniedHeadingSample> headings,
  required List<int> stepTimestampsNanos,
}) {
  final List<_DeniedReplayEvent> events = <_DeniedReplayEvent>[];
  final Set<int> headingTimestamps = <int>{};
  final Set<int> stepTimestamps = <int>{};
  var insertionIndex = 0;

  for (final DeniedHeadingSample heading in headings) {
    if (heading.timestampNanos <= 0 || !heading.headingRad.isFinite) {
      throw const FormatException('Invalid denied heading sample.');
    }
    if (headingTimestamps.add(heading.timestampNanos)) {
      events.add(_DeniedHeadingReplayEvent(heading, insertionIndex++));
    }
  }
  for (final int timestamp in stepTimestampsNanos) {
    if (timestamp <= 0) {
      throw const FormatException('Invalid denied step timestamp.');
    }
    if (stepTimestamps.add(timestamp)) {
      events.add(_DeniedStepReplayEvent(timestamp, insertionIndex++));
    }
  }
  events.sort((_DeniedReplayEvent first, _DeniedReplayEvent second) {
    final int timestampOrder = first.timestampNanos.compareTo(
      second.timestampNanos,
    );
    if (timestampOrder != 0) {
      return timestampOrder;
    }
    final int priorityOrder = first.priority.compareTo(second.priority);
    if (priorityOrder != 0) {
      return priorityOrder;
    }
    return first.insertionIndex.compareTo(second.insertionIndex);
  });

  DeniedHeadingSample? latestHeading;
  final List<DeniedStepAssociation> associations = <DeniedStepAssociation>[];
  var predictionsApplied = 0;
  var predictionsSkippedNoHeading = 0;
  var predictionsSkippedByQuality = 0;

  for (final _DeniedReplayEvent event in events) {
    if (event is _DeniedHeadingReplayEvent) {
      latestHeading = event.sample;
      continue;
    }
    final DeniedHeadingSample? heading = latestHeading;
    if (heading == null || heading.timestampNanos > event.timestampNanos) {
      predictionsSkippedNoHeading += 1;
      associations.add(
        DeniedStepAssociation(
          stepTimestampNanos: event.timestampNanos,
          headingTimestampNanos: null,
          headingRad: null,
          pdrQuality: NavguardQuality.unavailable,
          applied: false,
        ),
      );
      continue;
    }
    final NavguardQuality quality = classifyPdrQuality(
      headingQuality: heading.quality,
      headingAgeMs: (event.timestampNanos - heading.timestampNanos) / 1000000.0,
    );
    final bool applied = navguardQualityMultiplier(quality) != null;
    if (applied) {
      predictionsApplied += 1;
    } else {
      predictionsSkippedByQuality += 1;
    }
    associations.add(
      DeniedStepAssociation(
        stepTimestampNanos: event.timestampNanos,
        headingTimestampNanos: heading.timestampNanos,
        headingRad: heading.headingRad,
        pdrQuality: quality,
        applied: applied,
      ),
    );
  }

  final DeniedPdrReplayResult result = DeniedPdrReplayResult(
    associations: associations,
    predictionsApplied: predictionsApplied,
    predictionsSkippedNoHeading: predictionsSkippedNoHeading,
    predictionsSkippedByQuality: predictionsSkippedByQuality,
    acceptedStepOpportunityCount: stepTimestamps.length,
  );
  if (!result.counterInvariantHolds) {
    throw StateError('Denied PDR counter invariant failed.');
  }
  return result;
}

abstract class _DeniedReplayEvent {
  const _DeniedReplayEvent(
    this.timestampNanos,
    this.insertionIndex,
    this.priority,
  );

  final int timestampNanos;
  final int insertionIndex;
  final int priority;
}

class _DeniedHeadingReplayEvent extends _DeniedReplayEvent {
  _DeniedHeadingReplayEvent(this.sample, int insertionIndex)
    : super(sample.timestampNanos, insertionIndex, 0);

  final DeniedHeadingSample sample;
}

class _DeniedStepReplayEvent extends _DeniedReplayEvent {
  const _DeniedStepReplayEvent(int timestampNanos, int insertionIndex)
    : super(timestampNanos, insertionIndex, 1);
}

class DeniedFirewallSnapshot {
  const DeniedFirewallSnapshot({
    required this.estimate,
    required this.headingQuality,
    required this.pdrQuality,
    required this.arcoreQuality,
    required this.controllerState,
    this.deniedGnssFixCount = 0,
  });

  final NavguardFusionEstimate estimate;
  final NavguardQuality headingQuality;
  final NavguardQuality pdrQuality;
  final NavguardQuality arcoreQuality;
  final int controllerState;
  final int deniedGnssFixCount;

  DeniedFirewallSnapshot quarantineGnss({
    required double latitudeDeg,
    required double longitudeDeg,
  }) {
    if (!latitudeDeg.isFinite || !longitudeDeg.isFinite) {
      throw const FormatException('Invalid quarantined GNSS fixture.');
    }
    return DeniedFirewallSnapshot(
      estimate: estimate,
      headingQuality: headingQuality,
      pdrQuality: pdrQuality,
      arcoreQuality: arcoreQuality,
      controllerState: controllerState,
      deniedGnssFixCount: deniedGnssFixCount + 1,
    );
  }
}

bool deniedGnssMutationInvariant({
  required DeniedFirewallSnapshot first,
  required DeniedFirewallSnapshot second,
  double tolerance = 1e-12,
}) {
  bool close(double a, double b) => (a - b).abs() <= tolerance;
  return close(first.estimate.eastM, second.estimate.eastM) &&
      close(first.estimate.northM, second.estimate.northM) &&
      close(first.estimate.headingRad, second.estimate.headingRad) &&
      List<bool>.generate(
        9,
        (int index) => close(
          first.estimate.covariance.values[index],
          second.estimate.covariance.values[index],
        ),
      ).every((bool value) => value) &&
      first.headingQuality == second.headingQuality &&
      first.pdrQuality == second.pdrQuality &&
      first.arcoreQuality == second.arcoreQuality &&
      first.controllerState == second.controllerState;
}

class FullNavguardFlowPreflight {
  const FullNavguardFlowPreflight({
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
    required this.currentState,
  });

  factory FullNavguardFlowPreflight.fromPlatform(Object? raw) {
    final Map<Object?, Object?> map = _strictMap(raw);
    _expectInt(map, 'schemaVersion', 1);
    _expectString(map, 'snapshotKind', 'full_navguard_flow_preflight');
    final bool gpsProviderAvailable = _bool(map, 'gpsProviderAvailable');
    final bool gpsProviderEnabled = _bool(map, 'gpsProviderEnabled');
    final bool fineLocationPermissionGranted = _bool(
      map,
      'fineLocationPermissionGranted',
    );
    final bool rotationVectorAvailable = _bool(map, 'rotationVectorAvailable');
    final bool stepDetectorAvailable = _bool(map, 'stepDetectorAvailable');
    final bool activityRecognitionPermissionGranted = _bool(
      map,
      'activityRecognitionPermissionGranted',
    );
    final bool arCoreSupported = _bool(map, 'arCoreSupported');
    final bool arCoreInstalled = _bool(map, 'arCoreInstalled');
    final bool cameraPermissionGranted = _bool(map, 'cameraPermissionGranted');
    final bool diagnosticRunning = _bool(map, 'diagnosticRunning');
    final bool nativeReady = _bool(map, 'nativeReady');
    final FullNavguardFlowState currentState = FullNavguardFlowState.parse(
      map['currentState'],
    );
    final bool expectedNativeReady =
        gpsProviderAvailable &&
        gpsProviderEnabled &&
        fineLocationPermissionGranted &&
        rotationVectorAvailable &&
        stepDetectorAvailable &&
        activityRecognitionPermissionGranted &&
        arCoreSupported &&
        arCoreInstalled &&
        cameraPermissionGranted &&
        !diagnosticRunning;
    if (nativeReady != expectedNativeReady ||
        (!diagnosticRunning && currentState != FullNavguardFlowState.idle)) {
      throw const FormatException('Inconsistent full-flow preflight.');
    }
    return FullNavguardFlowPreflight(
      gpsProviderAvailable: gpsProviderAvailable,
      gpsProviderEnabled: gpsProviderEnabled,
      fineLocationPermissionGranted: fineLocationPermissionGranted,
      rotationVectorAvailable: rotationVectorAvailable,
      stepDetectorAvailable: stepDetectorAvailable,
      activityRecognitionPermissionGranted:
          activityRecognitionPermissionGranted,
      arCoreSupported: arCoreSupported,
      arCoreInstalled: arCoreInstalled,
      cameraPermissionGranted: cameraPermissionGranted,
      diagnosticRunning: diagnosticRunning,
      nativeReady: nativeReady,
      currentState: currentState,
    );
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
  final FullNavguardFlowState currentState;
}

class FullNavguardFlowDiagnosticResult {
  const FullNavguardFlowDiagnosticResult({
    required this.finalState,
    required this.normalGnssAcceptedFixCount,
    required this.deniedGnssFixCount,
    required this.deniedGnssUsedByEstimatorCount,
    required this.deniedPdrPredictionsApplied,
    required this.deniedAcceptedStepOpportunityCount,
    required this.deniedArcoreMeasurementsApplied,
    required this.deniedHeadingMeasurementsApplied,
    required this.preRecoveryDeniedEastM,
    required this.preRecoveryDeniedNorthM,
    required this.recoveryCandidateFixCount,
    required this.recoveryAcceptedFixCount,
    required this.recoveryRejectedFixCount,
    required this.recoveredObservationAcceptedFixCount,
    required this.recoveredObservationRejectedFixCount,
    required this.recoveryCorrectionDistanceM,
    required this.finalRecoveredEastM,
    required this.finalRecoveredNorthM,
    required this.sanitizedMetadata,
  });

  factory FullNavguardFlowDiagnosticResult.fromPlatform(Object? raw) {
    final Map<Object?, Object?> map = _strictMap(raw);
    _expectInt(map, 'schemaVersion', 1);
    _expectString(map, 'snapshotKind', 'full_navguard_flow_diagnostic_result');
    _expectBool(map, 'success', true);
    _expectString(map, 'finalState', 'COMPLETED');
    _expectString(map, 'finalNavigationMode', 'GNSS_RECOVERED');

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
      _expectBool(map, key, true);
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
      _expectBool(map, key, false);
    }
    _expectString(map, 'gnssProvider', 'GPS_PROVIDER');
    _expectString(
      map,
      'gnssTimestampAuthority',
      'Location.getElapsedRealtimeNanos',
    );
    _expectString(map, 'operationClock', 'SystemClock.elapsedRealtimeNanos');
    _expectString(
      map,
      'headingAssociationPolicy',
      'latest_valid_heading_at_or_before_step_timestamp',
    );
    _expectInt(
      map,
      'recoveryConsecutiveGoodFixesRequired',
      recoveryRequiredConsecutiveGoodFixes,
    );
    _expectInt(map, 'deniedGnssUsedByEstimatorCount', 0);
    _expectInt(map, 'stateTransitionCount', 6);
    final int achieved = _nonNegativeInt(
      map,
      'recoveryConsecutiveGoodFixesAchieved',
    );
    if (achieved < recoveryRequiredConsecutiveGoodFixes) {
      throw const FormatException('Recovery gate was not achieved.');
    }
    _expectDouble(
      map,
      'maxOperationalGnssAccuracyM',
      maxOperationalGnssAccuracyM,
    );
    for (final String key in <String>[
      'normalGnssRejectedFixCount',
      'deniedGnssRejectedFixCount',
      'recoveryCandidateFixCount',
      'recoveryRejectedFixCount',
      'deniedHeadingMeasurementsSkippedByQuality',
      'deniedPdrPredictionsSkippedNoHeading',
      'deniedPdrPredictionsSkippedByQuality',
      'deniedArcoreMeasurementsSkippedByQuality',
    ]) {
      _nonNegativeInt(map, key);
    }
    for (final String key in <String>[
      'normalGnssDurationMs',
      'deniedNavigationDurationMs',
      'recoveryPendingDurationMs',
      'recoveredGnssDurationMs',
      'preRecoveryDeniedHorizontalDisplacementFromDenialOriginM',
      'preRecoveryVarianceEastM2',
      'preRecoveryVarianceNorthM2',
      'preRecoveryVarianceHeadingRad2',
      'finalRecoveredHorizontalFromAnchorM',
      'finalRecoveredVarianceEastM2',
      'finalRecoveredVarianceNorthM2',
      'finalRecoveredVarianceHeadingRad2',
    ]) {
      _finiteNonNegativeDouble(map, key);
    }
    NavguardQuality.parse(map['preRecoveryHeadingQuality']);
    NavguardQuality.parse(map['preRecoveryPdrQuality']);
    NavguardQuality.parse(map['preRecoveryArcoreQuality']);
    NavguardQuality.parse(map['preRecoveryFusionQuality']);

    final double preRecoveryEastM = _finiteDouble(
      map,
      'preRecoveryDeniedEastM',
    );
    final double preRecoveryNorthM = _finiteDouble(
      map,
      'preRecoveryDeniedNorthM',
    );
    final double recoveredGnssEastM = _finiteDouble(map, 'recoveredGnssEastM');
    final double recoveredGnssNorthM = _finiteDouble(
      map,
      'recoveredGnssNorthM',
    );
    final double correctionDistance = _finiteNonNegativeDouble(
      map,
      'recoveryCorrectionDistanceM',
    );
    final double calculatedCorrection = calculateRecoveryCorrectionDistanceM(
      deniedEastM: preRecoveryEastM,
      deniedNorthM: preRecoveryNorthM,
      recoveredEastM: recoveredGnssEastM,
      recoveredNorthM: recoveredGnssNorthM,
    );
    if ((correctionDistance - calculatedCorrection).abs() > 1e-6) {
      throw const FormatException('Inconsistent recovery correction.');
    }
    final double finalRecoveredEastM = _finiteDouble(
      map,
      'finalRecoveredEastM',
    );
    final double finalRecoveredNorthM = _finiteDouble(
      map,
      'finalRecoveredNorthM',
    );
    final double finalHorizontal = _finiteNonNegativeDouble(
      map,
      'finalRecoveredHorizontalFromAnchorM',
    );
    final double calculatedFinalHorizontal = math.sqrt(
      (finalRecoveredEastM * finalRecoveredEastM) +
          (finalRecoveredNorthM * finalRecoveredNorthM),
    );
    if ((finalHorizontal - calculatedFinalHorizontal).abs() > 1e-6) {
      throw const FormatException('Inconsistent final recovered position.');
    }
    final double finalRecoveredHeadingRad = _finiteDouble(
      map,
      'finalRecoveredHeadingRad',
    );
    if (finalRecoveredHeadingRad < 0 ||
        finalRecoveredHeadingRad >= 2 * math.pi) {
      throw const FormatException('Invalid final recovered heading.');
    }

    final int normalAccepted = _nonNegativeInt(
      map,
      'normalGnssAcceptedFixCount',
    );
    final int deniedCount = _nonNegativeInt(map, 'deniedGnssFixCount');
    final int deniedPdr = _nonNegativeInt(map, 'deniedPdrPredictionsApplied');
    final int deniedPdrSkippedNoHeading = _nonNegativeInt(
      map,
      'deniedPdrPredictionsSkippedNoHeading',
    );
    final int deniedPdrSkippedByQuality = _nonNegativeInt(
      map,
      'deniedPdrPredictionsSkippedByQuality',
    );
    final int deniedAcceptedStepOpportunities = _nonNegativeInt(
      map,
      'deniedAcceptedStepOpportunityCount',
    );
    if (deniedPdr + deniedPdrSkippedNoHeading + deniedPdrSkippedByQuality !=
        deniedAcceptedStepOpportunities) {
      throw const FormatException('Inconsistent denied PDR counters.');
    }
    final int deniedArcore = _nonNegativeInt(
      map,
      'deniedArcoreMeasurementsApplied',
    );
    final int deniedHeading = _nonNegativeInt(
      map,
      'deniedHeadingMeasurementsApplied',
    );
    final int recoveryAccepted = _nonNegativeInt(
      map,
      'recoveryAcceptedFixCount',
    );
    final int recoveryCandidate = _nonNegativeInt(
      map,
      'recoveryCandidateFixCount',
    );
    final int recoveryRejected = _nonNegativeInt(
      map,
      'recoveryRejectedFixCount',
    );
    if (recoveryAccepted + recoveryRejected > recoveryCandidate) {
      throw const FormatException('Inconsistent recovery-gate counters.');
    }
    final int recoveredObservationAccepted = _nonNegativeInt(
      map,
      'recoveredObservationAcceptedFixCount',
    );
    final int recoveredObservationRejected = _nonNegativeInt(
      map,
      'recoveredObservationRejectedFixCount',
    );
    final Map<String, Object?> sanitized = <String, Object?>{
      for (final MapEntry<Object?, Object?> entry in map.entries)
        if (entry.key is String && !_sensitiveFullFlowKeys.contains(entry.key))
          entry.key! as String: entry.value,
    };
    return FullNavguardFlowDiagnosticResult(
      finalState: FullNavguardFlowState.parse(map['finalState']),
      normalGnssAcceptedFixCount: normalAccepted,
      deniedGnssFixCount: deniedCount,
      deniedGnssUsedByEstimatorCount: 0,
      deniedPdrPredictionsApplied: deniedPdr,
      deniedAcceptedStepOpportunityCount: deniedAcceptedStepOpportunities,
      deniedArcoreMeasurementsApplied: deniedArcore,
      deniedHeadingMeasurementsApplied: deniedHeading,
      preRecoveryDeniedEastM: preRecoveryEastM,
      preRecoveryDeniedNorthM: preRecoveryNorthM,
      recoveryCandidateFixCount: recoveryCandidate,
      recoveryAcceptedFixCount: recoveryAccepted,
      recoveryRejectedFixCount: recoveryRejected,
      recoveredObservationAcceptedFixCount: recoveredObservationAccepted,
      recoveredObservationRejectedFixCount: recoveredObservationRejected,
      recoveryCorrectionDistanceM: correctionDistance,
      finalRecoveredEastM: finalRecoveredEastM,
      finalRecoveredNorthM: finalRecoveredNorthM,
      sanitizedMetadata: Map<String, Object?>.unmodifiable(sanitized),
    );
  }

  final FullNavguardFlowState finalState;
  final int normalGnssAcceptedFixCount;
  final int deniedGnssFixCount;
  final int deniedGnssUsedByEstimatorCount;
  final int deniedPdrPredictionsApplied;
  final int deniedAcceptedStepOpportunityCount;
  final int deniedArcoreMeasurementsApplied;
  final int deniedHeadingMeasurementsApplied;
  final double preRecoveryDeniedEastM;
  final double preRecoveryDeniedNorthM;
  final int recoveryCandidateFixCount;
  final int recoveryAcceptedFixCount;
  final int recoveryRejectedFixCount;
  final int recoveredObservationAcceptedFixCount;
  final int recoveredObservationRejectedFixCount;
  final double recoveryCorrectionDistanceM;
  final double finalRecoveredEastM;
  final double finalRecoveredNorthM;
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
    throw const FormatException('Expected a boolean field.');
  }
  return value;
}

void _expectBool(Map<Object?, Object?> map, String key, bool expected) {
  if (_bool(map, key) != expected) {
    throw const FormatException('Unexpected boolean contract field.');
  }
}

void _expectInt(Map<Object?, Object?> map, String key, int expected) {
  final Object? value = map[key];
  if (value is! int || value != expected) {
    throw const FormatException('Unexpected integer contract field.');
  }
}

int _nonNegativeInt(Map<Object?, Object?> map, String key) {
  final Object? value = map[key];
  if (value is! int || value < 0) {
    throw const FormatException('Expected a non-negative integer field.');
  }
  return value;
}

void _expectString(Map<Object?, Object?> map, String key, String expected) {
  if (map[key] != expected) {
    throw const FormatException('Unexpected string contract field.');
  }
}

double _finiteDouble(Map<Object?, Object?> map, String key) {
  final Object? value = map[key];
  if (value is! num || !value.toDouble().isFinite) {
    throw const FormatException('Expected a finite numeric field.');
  }
  return value.toDouble();
}

double _finiteNonNegativeDouble(Map<Object?, Object?> map, String key) {
  final double value = _finiteDouble(map, key);
  if (value < 0) {
    throw const FormatException('Expected a non-negative numeric field.');
  }
  return value;
}

void _expectDouble(Map<Object?, Object?> map, String key, double expected) {
  if ((_finiteDouble(map, key) - expected).abs() > 1e-12) {
    throw const FormatException('Unexpected numeric contract field.');
  }
}

const Set<String> _sensitiveFullFlowKeys = <String>{
  'latitude',
  'longitude',
  'rawGnssFixes',
  'rawSensorSamples',
  'rawArcorePoses',
  'rawTrajectory',
  'rawTimestamps',
  'denialStartElapsedRealtimeNanos',
  'recoveryGateOpenElapsedRealtimeNanos',
};
