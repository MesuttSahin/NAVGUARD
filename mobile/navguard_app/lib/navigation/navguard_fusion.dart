import 'dart:math' as math;

const double navguardStepLengthM = 0.75;
const double navguardBaseStepLengthSigmaM = 0.20;
const double navguardBaseStepHeadingProcessSigmaRad = 5 * math.pi / 180;
const double navguardBaseHeadingMeasurementSigmaRad = 15 * math.pi / 180;
const double navguardBaseArcorePositionSigmaM = 0.35;

enum NavguardQuality {
  unknown('UNKNOWN'),
  good('GOOD'),
  usable('USABLE'),
  degraded('DEGRADED'),
  unreliable('UNRELIABLE'),
  unavailable('UNAVAILABLE');

  const NavguardQuality(this.wireValue);

  final String wireValue;

  static NavguardQuality parse(Object? value) {
    for (final NavguardQuality quality in values) {
      if (value == quality.wireValue) {
        return quality;
      }
    }
    throw const FormatException('Invalid NAVGUARD quality.');
  }
}

double? navguardQualityMultiplier(NavguardQuality quality) {
  return switch (quality) {
    NavguardQuality.good => 1,
    NavguardQuality.usable => 2,
    NavguardQuality.degraded => 6,
    NavguardQuality.unreliable ||
    NavguardQuality.unavailable ||
    NavguardQuality.unknown => null,
  };
}

NavguardQuality classifyHeadingQuality({
  required bool sensorAvailable,
  required bool sampleValid,
  double? reportedAccuracyRad,
}) {
  if (!sensorAvailable) {
    return NavguardQuality.unavailable;
  }
  if (!sampleValid ||
      (reportedAccuracyRad != null && !reportedAccuracyRad.isFinite)) {
    return NavguardQuality.unreliable;
  }
  if (reportedAccuracyRad == null || reportedAccuracyRad == -1) {
    return NavguardQuality.usable;
  }
  if (reportedAccuracyRad < 0) {
    return NavguardQuality.unreliable;
  }
  final double accuracyDeg = reportedAccuracyRad * 180 / math.pi;
  if (accuracyDeg <= 15) {
    return NavguardQuality.good;
  }
  if (accuracyDeg <= 30) {
    return NavguardQuality.usable;
  }
  if (accuracyDeg <= 45) {
    return NavguardQuality.degraded;
  }
  return NavguardQuality.unreliable;
}

NavguardQuality classifyPdrQuality({
  required NavguardQuality headingQuality,
  required double? headingAgeMs,
}) {
  if (headingQuality == NavguardQuality.unavailable || headingAgeMs == null) {
    return NavguardQuality.unavailable;
  }
  if (!headingAgeMs.isFinite ||
      headingAgeMs < 0 ||
      headingQuality == NavguardQuality.unreliable ||
      headingQuality == NavguardQuality.unknown) {
    return NavguardQuality.unreliable;
  }
  if (headingAgeMs > 150) {
    return NavguardQuality.unreliable;
  }
  if (headingQuality == NavguardQuality.degraded || headingAgeMs > 50) {
    return NavguardQuality.degraded;
  }
  return NavguardQuality.usable;
}

NavguardQuality classifyArcoreQuality({
  required bool sourceAvailable,
  required bool cameraTracking,
  required bool referenceTracking,
  required bool sampleValid,
  required bool firstUsableEvent,
  double? processingGapMs,
}) {
  if (!sourceAvailable || !cameraTracking || !referenceTracking) {
    return NavguardQuality.unavailable;
  }
  if (!sampleValid) {
    return NavguardQuality.unreliable;
  }
  if (firstUsableEvent) {
    return NavguardQuality.usable;
  }
  if (processingGapMs == null ||
      !processingGapMs.isFinite ||
      processingGapMs < 0) {
    return NavguardQuality.unreliable;
  }
  if (processingGapMs <= 75) {
    return NavguardQuality.good;
  }
  if (processingGapMs <= 150) {
    return NavguardQuality.usable;
  }
  if (processingGapMs <= 300) {
    return NavguardQuality.degraded;
  }
  return NavguardQuality.unreliable;
}

NavguardQuality classifyFusionQuality({
  required NavguardQuality heading,
  required NavguardQuality pdr,
  required NavguardQuality arcore,
  required bool anyAcceptedSourceUpdate,
  required bool sourcesObserved,
}) {
  if (arcore == NavguardQuality.good &&
      pdr == NavguardQuality.usable &&
      (heading == NavguardQuality.good || heading == NavguardQuality.usable)) {
    return NavguardQuality.good;
  }
  if ((arcore == NavguardQuality.good || arcore == NavguardQuality.usable) &&
      (pdr == NavguardQuality.usable || pdr == NavguardQuality.degraded) &&
      heading != NavguardQuality.unreliable &&
      heading != NavguardQuality.unavailable &&
      heading != NavguardQuality.unknown) {
    return NavguardQuality.usable;
  }
  if (anyAcceptedSourceUpdate) {
    return NavguardQuality.degraded;
  }
  if (sourcesObserved) {
    return NavguardQuality.unreliable;
  }
  if (heading == NavguardQuality.unavailable &&
      pdr == NavguardQuality.unavailable &&
      arcore == NavguardQuality.unavailable) {
    return NavguardQuality.unavailable;
  }
  return NavguardQuality.unknown;
}

double normalizeNavguardHeading(double angleRad) {
  if (!angleRad.isFinite) {
    throw const FormatException('Heading must be finite.');
  }
  final double normalized = angleRad % (2 * math.pi);
  return normalized < 0 ? normalized + (2 * math.pi) : normalized;
}

double navguardCircularDifference(double measuredRad, double predictedRad) {
  var difference =
      (measuredRad - predictedRad + math.pi) % (2 * math.pi) - math.pi;
  if (difference <= -math.pi) {
    difference += 2 * math.pi;
  }
  return difference;
}

class NavguardMatrix3 {
  NavguardMatrix3(List<double> values)
    : values = List<double>.unmodifiable(values) {
    if (values.length != 9 || values.any((double value) => !value.isFinite)) {
      throw const FormatException('A finite 3x3 matrix is required.');
    }
  }

  factory NavguardMatrix3.diagonal(double a, double b, double c) {
    return NavguardMatrix3(<double>[a, 0, 0, 0, b, 0, 0, 0, c]);
  }

  factory NavguardMatrix3.identity() => NavguardMatrix3.diagonal(1, 1, 1);

  final List<double> values;

  double at(int row, int column) => values[(row * 3) + column];

  bool get isApproximatelySymmetric {
    const double tolerance = 1e-10;
    return (at(0, 1) - at(1, 0)).abs() <= tolerance &&
        (at(0, 2) - at(2, 0)).abs() <= tolerance &&
        (at(1, 2) - at(2, 1)).abs() <= tolerance;
  }

  NavguardMatrix3 symmetrized() {
    final List<double> output = List<double>.of(values);
    for (var row = 0; row < 3; row += 1) {
      for (var column = row + 1; column < 3; column += 1) {
        final double average = (at(row, column) + at(column, row)) / 2;
        output[(row * 3) + column] = average;
        output[(column * 3) + row] = average;
      }
    }
    for (final int index in <int>[0, 4, 8]) {
      if (output[index] < 0 && output[index] > -1e-12) {
        output[index] = 0;
      }
      if (output[index] < 0) {
        throw const FormatException('Covariance has a negative variance.');
      }
    }
    return NavguardMatrix3(output);
  }
}

class NavguardFusionEstimate {
  const NavguardFusionEstimate({
    required this.eastM,
    required this.northM,
    required this.headingRad,
    required this.covariance,
  });

  factory NavguardFusionEstimate.initial(double headingRad) {
    return NavguardFusionEstimate(
      eastM: 0,
      northM: 0,
      headingRad: normalizeNavguardHeading(headingRad),
      covariance: NavguardMatrix3.diagonal(
        0.1 * 0.1,
        0.1 * 0.1,
        navguardBaseHeadingMeasurementSigmaRad *
            navguardBaseHeadingMeasurementSigmaRad,
      ),
    );
  }

  final double eastM;
  final double northM;
  final double headingRad;
  final NavguardMatrix3 covariance;
}

NavguardMatrix3 _multiply3(NavguardMatrix3 left, NavguardMatrix3 right) {
  return NavguardMatrix3(<double>[
    for (var row = 0; row < 3; row += 1)
      for (var column = 0; column < 3; column += 1)
        List<double>.generate(
          3,
          (int inner) => left.at(row, inner) * right.at(inner, column),
        ).reduce((double a, double b) => a + b),
  ]);
}

NavguardMatrix3 _transpose3(NavguardMatrix3 matrix) {
  return NavguardMatrix3(<double>[
    for (var row = 0; row < 3; row += 1)
      for (var column = 0; column < 3; column += 1) matrix.at(column, row),
  ]);
}

NavguardMatrix3 _add3(NavguardMatrix3 left, NavguardMatrix3 right) {
  return NavguardMatrix3(<double>[
    for (var index = 0; index < 9; index += 1)
      left.values[index] + right.values[index],
  ]);
}

NavguardFusionEstimate navguardStepPredict(
  NavguardFusionEstimate estimate, {
  double stepLengthM = navguardStepLengthM,
  required NavguardQuality quality,
}) {
  final double? multiplier = navguardQualityMultiplier(quality);
  if (multiplier == null) {
    return estimate;
  }
  final double heading = estimate.headingRad;
  final double sinHeading = math.sin(heading);
  final double cosHeading = math.cos(heading);
  final NavguardMatrix3 jacobian = NavguardMatrix3(<double>[
    1,
    0,
    stepLengthM * cosHeading,
    0,
    1,
    -stepLengthM * sinHeading,
    0,
    0,
    1,
  ]);
  final double sigmaLength2 =
      navguardBaseStepLengthSigmaM * navguardBaseStepLengthSigmaM * multiplier;
  final double sigmaHeading2 =
      navguardBaseStepHeadingProcessSigmaRad *
      navguardBaseStepHeadingProcessSigmaRad *
      multiplier;
  final NavguardMatrix3 process = NavguardMatrix3(<double>[
    sigmaLength2 * sinHeading * sinHeading,
    sigmaLength2 * sinHeading * cosHeading,
    0,
    sigmaLength2 * sinHeading * cosHeading,
    sigmaLength2 * cosHeading * cosHeading,
    0,
    0,
    0,
    sigmaHeading2,
  ]);
  final NavguardMatrix3 covariance = _add3(
    _multiply3(
      _multiply3(jacobian, estimate.covariance),
      _transpose3(jacobian),
    ),
    process,
  ).symmetrized();
  return NavguardFusionEstimate(
    eastM: estimate.eastM + (stepLengthM * sinHeading),
    northM: estimate.northM + (stepLengthM * cosHeading),
    headingRad: heading,
    covariance: covariance,
  );
}

class NavguardMeasurementUpdate {
  const NavguardMeasurementUpdate({
    required this.estimate,
    required this.innovation,
  });

  final NavguardFusionEstimate estimate;
  final List<double> innovation;
}

NavguardMeasurementUpdate navguardHeadingUpdate(
  NavguardFusionEstimate estimate, {
  required double measuredHeadingRad,
  required NavguardQuality quality,
}) {
  final double? multiplier = navguardQualityMultiplier(quality);
  if (multiplier == null) {
    return NavguardMeasurementUpdate(estimate: estimate, innovation: const []);
  }
  final double variance =
      navguardBaseHeadingMeasurementSigmaRad *
      navguardBaseHeadingMeasurementSigmaRad *
      multiplier;
  final double innovation = navguardCircularDifference(
    measuredHeadingRad,
    estimate.headingRad,
  );
  final double innovationVariance = estimate.covariance.at(2, 2) + variance;
  if (!innovationVariance.isFinite || innovationVariance <= 0) {
    throw const FormatException('Invalid heading innovation covariance.');
  }
  final List<double> gain = <double>[
    estimate.covariance.at(0, 2) / innovationVariance,
    estimate.covariance.at(1, 2) / innovationVariance,
    estimate.covariance.at(2, 2) / innovationVariance,
  ];
  final NavguardMatrix3 covariance = _josephScalarHeading(
    estimate.covariance,
    gain,
    variance,
  );
  return NavguardMeasurementUpdate(
    estimate: NavguardFusionEstimate(
      eastM: estimate.eastM + (gain[0] * innovation),
      northM: estimate.northM + (gain[1] * innovation),
      headingRad: normalizeNavguardHeading(
        estimate.headingRad + (gain[2] * innovation),
      ),
      covariance: covariance,
    ),
    innovation: <double>[innovation],
  );
}

NavguardMatrix3 _josephScalarHeading(
  NavguardMatrix3 covariance,
  List<double> gain,
  double variance,
) {
  final List<double> ikhValues = List<double>.of(
    NavguardMatrix3.identity().values,
  );
  for (var row = 0; row < 3; row += 1) {
    ikhValues[(row * 3) + 2] -= gain[row];
  }
  final NavguardMatrix3 ikh = NavguardMatrix3(ikhValues);
  final NavguardMatrix3 first = _multiply3(
    _multiply3(ikh, covariance),
    _transpose3(ikh),
  );
  final NavguardMatrix3 second = NavguardMatrix3(<double>[
    for (var row = 0; row < 3; row += 1)
      for (var column = 0; column < 3; column += 1)
        gain[row] * variance * gain[column],
  ]);
  return _add3(first, second).symmetrized();
}

NavguardMeasurementUpdate navguardArcorePositionUpdate(
  NavguardFusionEstimate estimate, {
  required double measuredEastM,
  required double measuredNorthM,
  required NavguardQuality quality,
}) {
  final double? multiplier = navguardQualityMultiplier(quality);
  if (multiplier == null) {
    return NavguardMeasurementUpdate(estimate: estimate, innovation: const []);
  }
  final double variance =
      navguardBaseArcorePositionSigmaM *
      navguardBaseArcorePositionSigmaM *
      multiplier;
  final double s00 = estimate.covariance.at(0, 0) + variance;
  final double s01 = estimate.covariance.at(0, 1);
  final double s10 = estimate.covariance.at(1, 0);
  final double s11 = estimate.covariance.at(1, 1) + variance;
  final double determinant = (s00 * s11) - (s01 * s10);
  if (!determinant.isFinite || determinant <= 0) {
    throw const FormatException('Invalid ARCore innovation covariance.');
  }
  final List<double> inverseS = <double>[
    s11 / determinant,
    -s01 / determinant,
    -s10 / determinant,
    s00 / determinant,
  ];
  final List<double> gain = List<double>.filled(6, 0);
  for (var row = 0; row < 3; row += 1) {
    gain[(row * 2)] =
        (estimate.covariance.at(row, 0) * inverseS[0]) +
        (estimate.covariance.at(row, 1) * inverseS[2]);
    gain[(row * 2) + 1] =
        (estimate.covariance.at(row, 0) * inverseS[1]) +
        (estimate.covariance.at(row, 1) * inverseS[3]);
  }
  final List<double> innovation = <double>[
    measuredEastM - estimate.eastM,
    measuredNorthM - estimate.northM,
  ];
  final NavguardMatrix3 covariance = _josephArcore(
    estimate.covariance,
    gain,
    variance,
  );
  return NavguardMeasurementUpdate(
    estimate: NavguardFusionEstimate(
      eastM:
          estimate.eastM +
          (gain[0] * innovation[0]) +
          (gain[1] * innovation[1]),
      northM:
          estimate.northM +
          (gain[2] * innovation[0]) +
          (gain[3] * innovation[1]),
      headingRad: normalizeNavguardHeading(
        estimate.headingRad +
            (gain[4] * innovation[0]) +
            (gain[5] * innovation[1]),
      ),
      covariance: covariance,
    ),
    innovation: innovation,
  );
}

NavguardMatrix3 _josephArcore(
  NavguardMatrix3 covariance,
  List<double> gain,
  double variance,
) {
  final List<double> ikhValues = List<double>.of(
    NavguardMatrix3.identity().values,
  );
  for (var row = 0; row < 3; row += 1) {
    ikhValues[row * 3] -= gain[row * 2];
    ikhValues[(row * 3) + 1] -= gain[(row * 2) + 1];
  }
  final NavguardMatrix3 ikh = NavguardMatrix3(ikhValues);
  final NavguardMatrix3 first = _multiply3(
    _multiply3(ikh, covariance),
    _transpose3(ikh),
  );
  final NavguardMatrix3 second = NavguardMatrix3(<double>[
    for (var row = 0; row < 3; row += 1)
      for (var column = 0; column < 3; column += 1)
        variance *
            ((gain[row * 2] * gain[column * 2]) +
                (gain[(row * 2) + 1] * gain[(column * 2) + 1])),
  ]);
  return _add3(first, second).symmetrized();
}

enum NavguardFusionEventType { heading, step, arcore }

class NavguardFusionEvent {
  const NavguardFusionEvent({
    required this.timestampNanos,
    required this.type,
    required this.insertionIndex,
    this.headingRad,
  });

  final int timestampNanos;
  final NavguardFusionEventType type;
  final int insertionIndex;
  final double? headingRad;
}

List<NavguardFusionEvent> sortNavguardFusionEvents(
  Iterable<NavguardFusionEvent> events,
) {
  final List<NavguardFusionEvent> sorted = List<NavguardFusionEvent>.of(events);
  sorted.sort((NavguardFusionEvent left, NavguardFusionEvent right) {
    final int timestampOrder = left.timestampNanos.compareTo(
      right.timestampNanos,
    );
    if (timestampOrder != 0) {
      return timestampOrder;
    }
    final int priorityOrder = left.type.index.compareTo(right.type.index);
    if (priorityOrder != 0) {
      return priorityOrder;
    }
    return left.insertionIndex.compareTo(right.insertionIndex);
  });
  return sorted;
}

List<double?> associateCausalStepHeadings(
  Iterable<NavguardFusionEvent> events,
) {
  double? latestHeading;
  final List<double?> associations = <double?>[];
  for (final NavguardFusionEvent event in sortNavguardFusionEvents(events)) {
    if (event.type == NavguardFusionEventType.heading) {
      latestHeading = event.headingRad;
    } else if (event.type == NavguardFusionEventType.step) {
      associations.add(latestHeading);
    }
  }
  return associations;
}

class NavguardFusionPreflight {
  const NavguardFusionPreflight({
    required this.arCoreSupported,
    required this.arCoreInstalled,
    required this.cameraPermissionGranted,
    required this.rotationVectorAvailable,
    required this.rotationVectorName,
    required this.stepDetectorAvailable,
    required this.stepDetectorName,
    required this.activityRecognitionPermissionGranted,
    required this.diagnosticRunning,
    required this.nativeReady,
    required this.sanitizedMetadata,
  });

  factory NavguardFusionPreflight.fromPlatform(Object? raw) {
    final Map<Object?, Object?> map = _strictMap(raw);
    _expectInt(map, 'schemaVersion', 1);
    _expectString(map, 'snapshotKind', 'navguard_fusion_preflight');
    final bool arCoreSupported = _bool(map, 'arCoreSupported');
    final bool arCoreInstalled = _bool(map, 'arCoreInstalled');
    final bool cameraPermissionGranted = _bool(map, 'cameraPermissionGranted');
    final bool rotationVectorAvailable = _bool(map, 'rotationVectorAvailable');
    final String? rotationVectorName = _nullableString(
      map,
      'rotationVectorName',
    );
    final bool stepDetectorAvailable = _bool(map, 'stepDetectorAvailable');
    final String? stepDetectorName = _nullableString(map, 'stepDetectorName');
    final bool activityRecognitionPermissionGranted = _bool(
      map,
      'activityRecognitionPermissionGranted',
    );
    final bool diagnosticRunning = _bool(map, 'diagnosticRunning');
    final bool nativeReady = _bool(map, 'nativeReady');
    if (nativeReady !=
        (arCoreSupported &&
            arCoreInstalled &&
            cameraPermissionGranted &&
            rotationVectorAvailable &&
            stepDetectorAvailable &&
            activityRecognitionPermissionGranted &&
            !diagnosticRunning)) {
      throw const FormatException('Inconsistent NAVGUARD fusion preflight.');
    }
    final Map<String, Object?> sanitized = <String, Object?>{
      'schemaVersion': 1,
      'snapshotKind': 'navguard_fusion_preflight',
      'arCoreSupported': arCoreSupported,
      'arCoreInstalled': arCoreInstalled,
      'cameraPermissionGranted': cameraPermissionGranted,
      'rotationVectorAvailable': rotationVectorAvailable,
      'rotationVectorName': rotationVectorName,
      'stepDetectorAvailable': stepDetectorAvailable,
      'stepDetectorName': stepDetectorName,
      'activityRecognitionPermissionGranted':
          activityRecognitionPermissionGranted,
      'diagnosticRunning': diagnosticRunning,
      'nativeReady': nativeReady,
    };
    return NavguardFusionPreflight(
      arCoreSupported: arCoreSupported,
      arCoreInstalled: arCoreInstalled,
      cameraPermissionGranted: cameraPermissionGranted,
      rotationVectorAvailable: rotationVectorAvailable,
      rotationVectorName: rotationVectorName,
      stepDetectorAvailable: stepDetectorAvailable,
      stepDetectorName: stepDetectorName,
      activityRecognitionPermissionGranted:
          activityRecognitionPermissionGranted,
      diagnosticRunning: diagnosticRunning,
      nativeReady: nativeReady,
      sanitizedMetadata: Map<String, Object?>.unmodifiable(sanitized),
    );
  }

  final bool arCoreSupported;
  final bool arCoreInstalled;
  final bool cameraPermissionGranted;
  final bool rotationVectorAvailable;
  final String? rotationVectorName;
  final bool stepDetectorAvailable;
  final String? stepDetectorName;
  final bool activityRecognitionPermissionGranted;
  final bool diagnosticRunning;
  final bool nativeReady;
  final Map<String, Object?> sanitizedMetadata;
}

class NavguardFusionDiagnosticResult {
  const NavguardFusionDiagnosticResult({
    required this.alignmentCompleted,
    required this.finalHeadingQuality,
    required this.finalPdrQuality,
    required this.finalArcoreQuality,
    required this.finalFusionQuality,
    required this.headingMeasurementsApplied,
    required this.pdrPredictionsApplied,
    required this.arcoreMeasurementsApplied,
    required this.finalFusedEastM,
    required this.finalFusedNorthM,
    required this.finalFusedHeadingRad,
    required this.finalFusedHorizontalDisplacementM,
    required this.finalPdrHorizontalDisplacementM,
    required this.finalArcoreHorizontalDisplacementM,
    required this.finalVarianceEastM2,
    required this.finalVarianceNorthM2,
    required this.finalVarianceHeadingRad2,
    required this.sanitizedMetadata,
  });

  factory NavguardFusionDiagnosticResult.fromPlatform(Object? raw) {
    final Map<Object?, Object?> map = _strictMap(raw);
    _expectInt(map, 'schemaVersion', 1);
    _expectString(map, 'snapshotKind', 'navguard_fusion_diagnostic_result');
    _expectBool(map, 'success', true);
    _expectInt(map, 'fusionWindowMs', 30000);
    _expectString(map, 'coordinateFrame', 'local_enu');
    _expectString(map, 'estimatorProfile', 'config_d_navguard_ekf_v1');
    _expectBool(map, 'alignmentCompleted', true);
    _expectInt(map, 'alignmentHoldMs', 2000);
    _expectInt(map, 'alignmentAcquisitionTimeoutMs', 15000);
    _expectBool(map, 'alignmentStationarityAssumed', true);
    _expectBool(map, 'alignmentStationarityValidated', false);
    _expectString(map, 'headingConvention', 'clockwise_from_north_0_to_2pi');
    _expectString(map, 'arcorePoseSource', 'Frame.getAndroidSensorPose');
    _expectString(map, 'referenceStrategy', 'local_arcore_anchor');
    _expectString(
      map,
      'relativePoseStrategy',
      'anchor_inverse_compose_android_sensor_pose',
    );
    _expectString(map, 'headingTimestampAuthority', 'SensorEvent.timestamp');
    _expectString(map, 'stepTimestampAuthority', 'SensorEvent.timestamp');
    _expectString(map, 'arcoreFrameTimestampAuthority', 'Frame.getTimestamp');
    _expectString(
      map,
      'arcoreFrameTimestampTimeBase',
      'undefined_by_arcore_api',
    );
    _expectString(
      map,
      'operationWindowClock',
      'SystemClock.elapsedRealtimeNanos',
    );
    _expectBool(map, 'qualityEngineImplemented', true);
    _expectBool(map, 'ekfImplemented', true);
    _expectBool(map, 'pdrArcoreFusionImplemented', true);
    _expectInt(map, 'fusionStateDimension', 3);
    _expectString(map, 'fusionStateDefinition', 'E,N,heading');
    _expectBool(map, 'josephCovarianceUpdateUsed', true);
    _expectBool(map, 'circularHeadingInnovationUsed', true);
    _expectBool(map, 'configDImplemented', true);
    _expectBool(map, 'arcoreFrameTimestampUsedForFusionOrdering', false);
    _expectString(
      map,
      'arcoreFusionOrderingTimestampAuthority',
      'SystemClock.elapsedRealtimeNanos',
    );
    _expectString(
      map,
      'arcoreFusionTimestampSemantics',
      'processing_time_after_frame_update_not_camera_capture_time',
    );
    _expectBool(map, 'elapsedRealtimeFusionOrderingUsed', true);
    _expectBool(map, 'unsupportedCrossClockComparisonUsed', false);
    _expectBool(map, 'deterministicOfflineReplayUsed', true);
    _expectString(map, 'equalTimestampPriority', 'heading,step,arcore');
    _expectString(
      map,
      'headingAssociationPolicy',
      'latest_valid_heading_at_or_before_step_timestamp',
    );
    _expectBool(map, 'preDenialAnchorUsedForDeclination', true);
    _expectString(
      map,
      'declinationProvider',
      'android.hardware.GeomagneticField',
    );
    _expectString(map, 'declinationModelVersion', 'platform_managed');
    final Object? declinationAltitudeSource = map['declinationAltitudeSource'];
    if (declinationAltitudeSource != 'anchor_ellipsoid_altitude' &&
        declinationAltitudeSource != 'deterministic_zero_fallback') {
      throw const FormatException('Invalid declination altitude source.');
    }
    _finiteDouble(map, 'declinationRad');
    _expectDouble(map, 'baseStepLengthM', navguardStepLengthM);
    _expectDouble(map, 'baseStepLengthSigmaM', navguardBaseStepLengthSigmaM);
    _expectDouble(
      map,
      'baseStepHeadingProcessSigmaRad',
      navguardBaseStepHeadingProcessSigmaRad,
    );
    _expectDouble(
      map,
      'baseHeadingMeasurementSigmaRad',
      navguardBaseHeadingMeasurementSigmaRad,
    );
    _expectDouble(
      map,
      'baseArcorePositionSigmaM',
      navguardBaseArcorePositionSigmaM,
    );
    _expectBool(map, 'protectedGroundTruthAccessed', false);
    _expectBool(map, 'liveGnssRequested', false);
    _expectBool(map, 'fusionAccuracyValidated', false);
    _expectBool(map, 'qualityThresholdsValidated', false);
    _expectBool(map, 'noiseParametersValidated', false);
    _expectBool(map, 'gnssRecoveryImplemented', false);
    _expectBool(map, 'fullGnssDeniedNavigationImplemented', false);
    for (final String key in <String>[
      'rawSensorSamplesReturned',
      'rawArcorePosesReturned',
      'rawTrajectoryReturned',
      'rawTimestampsReturned',
      'cameraImagesReturned',
      'persistenceUsed',
      'stepDetectionAccuracyValidated',
      'stepLengthValidated',
      'headingAccuracyValidated',
      'trueNorthAccuracyValidated',
      'arcorePositionAccuracyValidated',
      'arcoreDistanceAccuracyValidated',
    ]) {
      _expectBool(map, key, false);
    }

    final bool alignmentCompleted = _bool(map, 'alignmentCompleted');
    final NavguardQuality finalHeadingQuality = NavguardQuality.parse(
      map['finalHeadingQuality'],
    );
    final NavguardQuality finalPdrQuality = NavguardQuality.parse(
      map['finalPdrQuality'],
    );
    final NavguardQuality finalArcoreQuality = NavguardQuality.parse(
      map['finalArcoreQuality'],
    );
    final NavguardQuality finalFusionQuality = NavguardQuality.parse(
      map['finalFusionQuality'],
    );
    final int headingMeasurementsApplied = _nonNegativeInt(
      map,
      'headingMeasurementsApplied',
    );
    final int pdrPredictionsApplied = _nonNegativeInt(
      map,
      'pdrPredictionsApplied',
    );
    final int arcoreMeasurementsApplied = _nonNegativeInt(
      map,
      'arcoreMeasurementsApplied',
    );
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
    ]) {
      _nonNegativeInt(map, key);
    }

    final double finalFusedEastM = _finiteDouble(map, 'finalFusedEastM');
    final double finalFusedNorthM = _finiteDouble(map, 'finalFusedNorthM');
    final double finalFusedHeadingRad = _finiteDouble(
      map,
      'finalFusedHeadingRad',
    );
    if (finalFusedHeadingRad < 0 || finalFusedHeadingRad >= 2 * math.pi) {
      throw const FormatException('Invalid final fused heading.');
    }
    final double finalFusedHorizontalDisplacementM = _finiteNonNegativeDouble(
      map,
      'finalFusedHorizontalDisplacementM',
    );
    final double calculatedHorizontal = math.sqrt(
      (finalFusedEastM * finalFusedEastM) +
          (finalFusedNorthM * finalFusedNorthM),
    );
    if ((calculatedHorizontal - finalFusedHorizontalDisplacementM).abs() >
        1e-6) {
      throw const FormatException('Inconsistent fused displacement.');
    }
    final double finalPdrHorizontalDisplacementM = _finiteNonNegativeDouble(
      map,
      'finalPdrHorizontalDisplacementM',
    );
    final double? finalArcoreHorizontalDisplacementM = _nullableFiniteDouble(
      map,
      'finalArcoreHorizontalDisplacementM',
      nonNegative: true,
    );
    final double finalVarianceEastM2 = _finiteNonNegativeDouble(
      map,
      'finalVarianceEastM2',
    );
    final double finalVarianceNorthM2 = _finiteNonNegativeDouble(
      map,
      'finalVarianceNorthM2',
    );
    final double finalVarianceHeadingRad2 = _finiteNonNegativeDouble(
      map,
      'finalVarianceHeadingRad2',
    );
    for (final String key in <String>[
      'finalCovarianceEastNorth',
      'finalCovarianceEastHeading',
      'finalCovarianceNorthHeading',
    ]) {
      _finiteDouble(map, key);
    }
    _finiteDouble(map, 'finalPdrEastM');
    _finiteDouble(map, 'finalPdrNorthM');
    _nullableFiniteDouble(map, 'finalArcoreEastM');
    _nullableFiniteDouble(map, 'finalArcoreNorthM');
    for (final String key in <String>[
      'meanAbsHeadingInnovationRad',
      'medianAbsHeadingInnovationRad',
      'maxAbsHeadingInnovationRad',
      'meanArcoreInnovationNormM',
      'medianArcoreInnovationNormM',
      'maxArcoreInnovationNormM',
    ]) {
      _nullableFiniteDouble(map, key, nonNegative: true);
    }

    final Map<String, Object?> sanitized = <String, Object?>{
      for (final MapEntry<Object?, Object?> entry in map.entries)
        if (entry.key is String &&
            _navguardFusionSanitizedKeys.contains(entry.key))
          entry.key! as String: entry.value,
    };
    return NavguardFusionDiagnosticResult(
      alignmentCompleted: alignmentCompleted,
      finalHeadingQuality: finalHeadingQuality,
      finalPdrQuality: finalPdrQuality,
      finalArcoreQuality: finalArcoreQuality,
      finalFusionQuality: finalFusionQuality,
      headingMeasurementsApplied: headingMeasurementsApplied,
      pdrPredictionsApplied: pdrPredictionsApplied,
      arcoreMeasurementsApplied: arcoreMeasurementsApplied,
      finalFusedEastM: finalFusedEastM,
      finalFusedNorthM: finalFusedNorthM,
      finalFusedHeadingRad: finalFusedHeadingRad,
      finalFusedHorizontalDisplacementM: finalFusedHorizontalDisplacementM,
      finalPdrHorizontalDisplacementM: finalPdrHorizontalDisplacementM,
      finalArcoreHorizontalDisplacementM: finalArcoreHorizontalDisplacementM,
      finalVarianceEastM2: finalVarianceEastM2,
      finalVarianceNorthM2: finalVarianceNorthM2,
      finalVarianceHeadingRad2: finalVarianceHeadingRad2,
      sanitizedMetadata: Map<String, Object?>.unmodifiable(sanitized),
    );
  }

  final bool alignmentCompleted;
  final NavguardQuality finalHeadingQuality;
  final NavguardQuality finalPdrQuality;
  final NavguardQuality finalArcoreQuality;
  final NavguardQuality finalFusionQuality;
  final int headingMeasurementsApplied;
  final int pdrPredictionsApplied;
  final int arcoreMeasurementsApplied;
  final double finalFusedEastM;
  final double finalFusedNorthM;
  final double finalFusedHeadingRad;
  final double finalFusedHorizontalDisplacementM;
  final double finalPdrHorizontalDisplacementM;
  final double? finalArcoreHorizontalDisplacementM;
  final double finalVarianceEastM2;
  final double finalVarianceNorthM2;
  final double finalVarianceHeadingRad2;
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

void _expectDouble(Map<Object?, Object?> map, String key, double expected) {
  final double value = _finiteDouble(map, key);
  if ((value - expected).abs() > 1e-12) {
    throw const FormatException('Unexpected numeric contract field.');
  }
}

String? _nullableString(Map<Object?, Object?> map, String key) {
  final Object? value = map[key];
  if (value != null && value is! String) {
    throw const FormatException('Expected a nullable string field.');
  }
  return value as String?;
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

double? _nullableFiniteDouble(
  Map<Object?, Object?> map,
  String key, {
  bool nonNegative = false,
}) {
  final Object? value = map[key];
  if (value == null) {
    return null;
  }
  if (value is! num || !value.toDouble().isFinite) {
    throw const FormatException('Expected a nullable finite numeric field.');
  }
  final double result = value.toDouble();
  if (nonNegative && result < 0) {
    throw const FormatException('Expected a non-negative numeric field.');
  }
  return result;
}

const Set<String> _navguardFusionSanitizedKeys = <String>{
  'schemaVersion',
  'snapshotKind',
  'success',
  'fusionWindowMs',
  'alignmentHoldMs',
  'alignmentAcquisitionTimeoutMs',
  'coordinateFrame',
  'estimatorProfile',
  'headingConvention',
  'alignmentCompleted',
  'alignmentStationarityAssumed',
  'alignmentStationarityValidated',
  'arcorePoseSource',
  'referenceStrategy',
  'relativePoseStrategy',
  'headingTimestampAuthority',
  'stepTimestampAuthority',
  'arcoreFrameTimestampAuthority',
  'arcoreFrameTimestampTimeBase',
  'operationWindowClock',
  'arcoreFrameTimestampUsedForFusionOrdering',
  'arcoreFusionOrderingTimestampAuthority',
  'arcoreFusionTimestampSemantics',
  'elapsedRealtimeFusionOrderingUsed',
  'unsupportedCrossClockComparisonUsed',
  'deterministicOfflineReplayUsed',
  'equalTimestampPriority',
  'headingAssociationPolicy',
  'preDenialAnchorUsedForDeclination',
  'declinationProvider',
  'declinationModelVersion',
  'declinationAltitudeSource',
  'declinationRad',
  'baseStepLengthM',
  'baseStepLengthSigmaM',
  'baseStepHeadingProcessSigmaRad',
  'baseHeadingMeasurementSigmaRad',
  'baseArcorePositionSigmaM',
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
  'finalHeadingQuality',
  'finalPdrQuality',
  'finalArcoreQuality',
  'finalFusionQuality',
  'headingMeasurementsApplied',
  'headingMeasurementsSkippedByQuality',
  'pdrPredictionsApplied',
  'pdrPredictionsSkippedNoHeading',
  'pdrPredictionsSkippedByQuality',
  'arcoreMeasurementsApplied',
  'arcoreMeasurementsSkippedByQuality',
  'headingEventCount',
  'stepEventCount',
  'invalidStepEventCount',
  'arFrameUpdateCount',
  'arTrackingFrameCount',
  'duplicateHeadingTimestampCount',
  'nonMonotonicHeadingTimestampCount',
  'duplicateStepTimestampCount',
  'nonMonotonicStepTimestampCount',
  'duplicateArFrameTimestampCount',
  'nonMonotonicArFrameTimestampCount',
  'finalFusedEastM',
  'finalFusedNorthM',
  'finalFusedHeadingRad',
  'finalFusedHorizontalDisplacementM',
  'finalVarianceEastM2',
  'finalVarianceNorthM2',
  'finalVarianceHeadingRad2',
  'finalCovarianceEastNorth',
  'finalCovarianceEastHeading',
  'finalCovarianceNorthHeading',
  'finalPdrEastM',
  'finalPdrNorthM',
  'finalPdrHorizontalDisplacementM',
  'finalArcoreEastM',
  'finalArcoreNorthM',
  'finalArcoreHorizontalDisplacementM',
  'headingInnovationCount',
  'meanAbsHeadingInnovationRad',
  'medianAbsHeadingInnovationRad',
  'maxAbsHeadingInnovationRad',
  'arcoreInnovationCount',
  'meanArcoreInnovationNormM',
  'medianArcoreInnovationNormM',
  'maxArcoreInnovationNormM',
  'qualityEngineImplemented',
  'ekfImplemented',
  'pdrArcoreFusionImplemented',
  'fusionStateDimension',
  'fusionStateDefinition',
  'josephCovarianceUpdateUsed',
  'circularHeadingInnovationUsed',
  'configDImplemented',
  'fusionAccuracyValidated',
  'qualityThresholdsValidated',
  'noiseParametersValidated',
  'stepDetectionAccuracyValidated',
  'stepLengthValidated',
  'headingAccuracyValidated',
  'trueNorthAccuracyValidated',
  'arcorePositionAccuracyValidated',
  'arcoreDistanceAccuracyValidated',
  'protectedGroundTruthAccessed',
  'liveGnssRequested',
  'gnssRecoveryImplemented',
  'fullGnssDeniedNavigationImplemented',
  'rawSensorSamplesReturned',
  'rawArcorePosesReturned',
  'rawTrajectoryReturned',
  'rawTimestampsReturned',
  'cameraImagesReturned',
  'persistenceUsed',
};
