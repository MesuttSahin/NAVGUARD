import 'dart:math' as math;

import 'package:flutter/services.dart';

const String liveNavguardMethodChannelName =
    'io.github.mesuttsahin.navguard/live_navguard_demo';
const String liveNavguardEventChannelName =
    'io.github.mesuttsahin.navguard/live_navguard_demo/events';

enum LiveNavguardState {
  idle('IDLE'),
  preparing('PREPARING'),
  gnssActive('GNSS_ACTIVE'),
  navguardReady('NAVGUARD_READY'),
  navguardActive('NAVGUARD_ACTIVE'),
  recoveryPending('RECOVERY_PENDING'),
  gnssRecovered('GNSS_RECOVERED'),
  stopped('STOPPED'),
  error('ERROR');

  const LiveNavguardState(this.wireName);
  final String wireName;

  static LiveNavguardState parse(Object? value) {
    return values.firstWhere(
      (LiveNavguardState state) => state.wireName == value,
      orElse: () => throw FormatException('Unknown live state: $value'),
    );
  }

  bool get isRunning => switch (this) {
    idle || stopped || error => false,
    _ => true,
  };
}

enum LiveNavigationSource {
  gnss('GNSS'),
  navguard('NAVGUARD');

  const LiveNavigationSource(this.wireName);
  final String wireName;

  static LiveNavigationSource parse(Object? value) {
    return values.firstWhere(
      (LiveNavigationSource source) => source.wireName == value,
      orElse: () => throw FormatException('Unknown navigation source: $value'),
    );
  }
}

enum LiveFusionMode {
  navguardV1('config_d_navguard_ekf_v1', 'NAVGUARD v1'),
  adaptiveV2('config_d_v2_adaptive_navguard', 'NAVGUARD v2 (Adaptive)');

  const LiveFusionMode(this.wireName, this.displayName);

  final String wireName;
  final String displayName;

  static LiveFusionMode parse(Object? value) {
    if (value == null) return LiveFusionMode.navguardV1;
    return values.firstWhere(
      (LiveFusionMode mode) => mode.wireName == value,
      orElse: () => throw const FormatException('Unknown live fusion mode.'),
    );
  }
}

enum LiveQuality {
  good('GOOD'),
  usable('USABLE'),
  degraded('DEGRADED'),
  unreliable('UNRELIABLE'),
  unavailable('UNAVAILABLE'),
  unknown('UNKNOWN');

  const LiveQuality(this.wireName);
  final String wireName;

  static LiveQuality parse(Object? value) {
    return values.firstWhere(
      (LiveQuality quality) => quality.wireName == value,
      orElse: () => LiveQuality.unknown,
    );
  }
}

class LiveNavguardAnchor {
  const LiveNavguardAnchor({
    required this.latitudeDeg,
    required this.longitudeDeg,
    this.altitudeEllipsoidM,
    this.locked = true,
  });

  final double latitudeDeg;
  final double longitudeDeg;
  final double? altitudeEllipsoidM;
  final bool locked;

  bool get isValid => locked && coordinatesAreValid;

  bool get coordinatesAreValid =>
      latitudeDeg.isFinite &&
      latitudeDeg >= -90 &&
      latitudeDeg <= 90 &&
      longitudeDeg.isFinite &&
      longitudeDeg >= -180 &&
      longitudeDeg <= 180 &&
      (altitudeEllipsoidM?.isFinite ?? true);

  Map<String, Object?> toArguments() => <String, Object?>{
    'latitudeDeg': latitudeDeg,
    'longitudeDeg': longitudeDeg,
    'altitudeEllipsoidM': altitudeEllipsoidM,
    'anchorAvailable': isValid,
  };
}

class LiveNavguardPreflight {
  const LiveNavguardPreflight({
    required this.gpsProviderAvailable,
    required this.gpsProviderEnabled,
    required this.fineLocationPermissionGranted,
    required this.rotationVectorAvailable,
    required this.stepDetectorAvailable,
    required this.activityRecognitionPermissionGranted,
    required this.arCoreSupported,
    required this.arCoreInstalled,
    required this.cameraPermissionGranted,
    required this.anchorAvailable,
    required this.nativeReady,
    required this.demoRunning,
  });

  factory LiveNavguardPreflight.fromMap(Object? raw) {
    final Map<Object?, Object?> map = _map(raw, 'preflight');
    _schema(map);
    return LiveNavguardPreflight(
      gpsProviderAvailable: map['gpsProviderAvailable'] == true,
      gpsProviderEnabled: map['gpsProviderEnabled'] == true,
      fineLocationPermissionGranted:
          map['fineLocationPermissionGranted'] == true,
      rotationVectorAvailable: map['rotationVectorAvailable'] == true,
      stepDetectorAvailable: map['stepDetectorAvailable'] == true,
      activityRecognitionPermissionGranted:
          map['activityRecognitionPermissionGranted'] == true,
      arCoreSupported: map['arCoreSupported'] == true,
      arCoreInstalled: map['arCoreInstalled'] == true,
      cameraPermissionGranted: map['cameraPermissionGranted'] == true,
      anchorAvailable: map['anchorAvailable'] == true,
      nativeReady: map['nativeReady'] == true,
      demoRunning: map['demoRunning'] == true,
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
  final bool anchorAvailable;
  final bool nativeReady;
  final bool demoRunning;
}

class LiveNavguardPosition {
  const LiveNavguardPosition({
    required this.sequence,
    required this.state,
    required this.navigationSource,
    required this.eastM,
    required this.northM,
    required this.headingRad,
    required this.displacementM,
    required this.headingQuality,
    required this.pdrQuality,
    required this.arCoreQuality,
    required this.fusionQuality,
    required this.headingUpdateCount,
    required this.pdrPredictionCount,
    required this.arCoreUpdateCount,
    required this.receivedStepEventCount,
    required this.stepEventsRejectedNoCausalHeading,
    required this.duplicateStepEventCount,
    required this.pendingStepEventCount,
    required this.historicalStepReplayCount,
    required this.fixedLagReplayCount,
    required this.fixedLagHistoryEventCount,
    required this.fixedLagHistoryWindowMs,
    required this.normalGnssAcceptedFixCount,
    required this.deniedGnssQuarantinedFixCount,
    required this.deniedGnssUsedByEstimatorCount,
    required this.lateHeadingEventCount,
    required this.lateStepEventCount,
    required this.lateArcoreEventCount,
    required this.recoveryGoodFixCount,
    required this.fusionMode,
    this.stepCallbackLatencyLastMs,
    this.stepCallbackLatencyMaxMs,
    this.stepCallbackLatencyMeanMs,
    this.recoveryCorrectionM,
    this.strideEstimateM,
    this.walkingHeadingOffsetDeg,
    this.stationaryDetected,
    required this.stationaryEntryCount,
    required this.stationaryDurationMs,
    required this.stationaryCandidateCount,
    required this.stationaryBlockedRecentStepCount,
    required this.stationaryBlockedHeadingMotionCount,
    required this.stationaryBlockedArcoreMotionCount,
    this.adaptiveArcoreSigmaM,
    this.arcoreNisLast,
    this.arcorePostRobustNisLast,
    required this.arcoreAcceptedAfterRobustInflationCount,
    required this.arcoreRejectedAfterMaxInflationCount,
    this.sourceDisagreementM,
  });

  factory LiveNavguardPosition.fromMap(Map<Object?, Object?> map) {
    final LiveNavguardPosition value = LiveNavguardPosition(
      sequence: _integer(map, 'sequence'),
      state: LiveNavguardState.parse(map['state']),
      navigationSource: LiveNavigationSource.parse(map['navigationSource']),
      eastM: _number(map, 'eastM'),
      northM: _number(map, 'northM'),
      headingRad: _number(map, 'headingRad'),
      displacementM: _number(map, 'displacementM'),
      headingQuality: LiveQuality.parse(map['headingQuality']),
      pdrQuality: LiveQuality.parse(map['pdrQuality']),
      arCoreQuality: LiveQuality.parse(map['arCoreQuality']),
      fusionQuality: LiveQuality.parse(map['fusionQuality']),
      headingUpdateCount: _integer(map, 'headingUpdateCount'),
      pdrPredictionCount: _integer(map, 'pdrPredictionCount'),
      arCoreUpdateCount: _integer(map, 'arCoreUpdateCount'),
      receivedStepEventCount: _integer(map, 'receivedStepEventCount'),
      stepEventsRejectedNoCausalHeading: _integer(
        map,
        'stepEventsRejectedNoCausalHeading',
      ),
      duplicateStepEventCount: _integer(map, 'duplicateStepEventCount'),
      pendingStepEventCount: _integer(map, 'pendingStepEventCount'),
      historicalStepReplayCount: _integer(map, 'historicalStepReplayCount'),
      fixedLagReplayCount: _integer(map, 'fixedLagReplayCount'),
      fixedLagHistoryEventCount: _integer(map, 'fixedLagHistoryEventCount'),
      fixedLagHistoryWindowMs: _integer(map, 'fixedLagHistoryWindowMs'),
      normalGnssAcceptedFixCount: _integer(map, 'normalGnssAcceptedFixCount'),
      deniedGnssQuarantinedFixCount: _integer(
        map,
        'deniedGnssQuarantinedFixCount',
      ),
      deniedGnssUsedByEstimatorCount: _integer(
        map,
        'deniedGnssUsedByEstimatorCount',
      ),
      lateHeadingEventCount: _integer(map, 'lateHeadingEventCount'),
      lateStepEventCount: _integer(map, 'lateStepEventCount'),
      lateArcoreEventCount: _integer(map, 'lateArcoreEventCount'),
      recoveryGoodFixCount: _integer(map, 'recoveryGoodFixCount'),
      fusionMode: LiveFusionMode.parse(map['fusionMode']),
      stepCallbackLatencyLastMs: _optionalNumber(
        map,
        'stepCallbackLatencyLastMs',
      ),
      stepCallbackLatencyMaxMs: _optionalNumber(
        map,
        'stepCallbackLatencyMaxMs',
      ),
      stepCallbackLatencyMeanMs: _optionalNumber(
        map,
        'stepCallbackLatencyMeanMs',
      ),
      recoveryCorrectionM: _optionalNumber(map, 'recoveryCorrectionM'),
      strideEstimateM: _optionalNumber(map, 'strideEstimateM'),
      walkingHeadingOffsetDeg: _optionalNumber(map, 'walkingHeadingOffsetDeg'),
      stationaryDetected: _optionalBool(map, 'stationaryDetected'),
      stationaryEntryCount: _optionalInteger(map, 'stationaryEntryCount', 0),
      stationaryDurationMs: _optionalInteger(map, 'stationaryDurationMs', 0),
      stationaryCandidateCount: _optionalInteger(
        map,
        'stationaryCandidateCount',
        0,
      ),
      stationaryBlockedRecentStepCount: _optionalInteger(
        map,
        'stationaryBlockedRecentStepCount',
        0,
      ),
      stationaryBlockedHeadingMotionCount: _optionalInteger(
        map,
        'stationaryBlockedHeadingMotionCount',
        0,
      ),
      stationaryBlockedArcoreMotionCount: _optionalInteger(
        map,
        'stationaryBlockedArcoreMotionCount',
        0,
      ),
      adaptiveArcoreSigmaM: _optionalNumber(map, 'adaptiveArcoreSigmaM'),
      arcoreNisLast: _optionalNumber(map, 'arcoreNisLast'),
      arcorePostRobustNisLast: _optionalNumber(map, 'arcorePostRobustNisLast'),
      arcoreAcceptedAfterRobustInflationCount: _optionalInteger(
        map,
        'arcoreAcceptedAfterRobustInflationCount',
        0,
      ),
      arcoreRejectedAfterMaxInflationCount: _optionalInteger(
        map,
        'arcoreRejectedAfterMaxInflationCount',
        0,
      ),
      sourceDisagreementM: _optionalNumber(map, 'sourceDisagreementM'),
    );
    if (_integer(map, 'pdrPredictionsApplied') != value.pdrPredictionCount ||
        map['stepCounterInvariantHolds'] != true ||
        map['fixedLagHistoryBounded'] != true ||
        value.fixedLagHistoryWindowMs != 12000 ||
        value.fixedLagHistoryEventCount > 4096 ||
        value.historicalStepReplayCount > value.pdrPredictionsApplied ||
        !value.countersAreNonNegative ||
        !value.stepCounterInvariantHolds) {
      throw const FormatException('Invalid live step counter contract');
    }
    final List<double?> latencies = <double?>[
      value.stepCallbackLatencyLastMs,
      value.stepCallbackLatencyMaxMs,
      value.stepCallbackLatencyMeanMs,
    ];
    if (latencies.whereType<double>().any((double latency) => latency < 0) ||
        (latencies.any((double? latency) => latency == null) &&
            latencies.any((double? latency) => latency != null)) ||
        (value.receivedStepEventCount == 0) !=
            latencies.every((double? latency) => latency == null)) {
      throw const FormatException('Invalid live step callback latency');
    }
    return value;
  }

  final int sequence;
  final LiveNavguardState state;
  final LiveNavigationSource navigationSource;
  final double eastM;
  final double northM;
  final double headingRad;
  final double displacementM;
  final LiveQuality headingQuality;
  final LiveQuality pdrQuality;
  final LiveQuality arCoreQuality;
  final LiveQuality fusionQuality;
  final int headingUpdateCount;
  final int pdrPredictionCount;
  int get pdrPredictionsApplied => pdrPredictionCount;
  final int arCoreUpdateCount;
  final int receivedStepEventCount;
  final int stepEventsRejectedNoCausalHeading;
  final int duplicateStepEventCount;
  final int pendingStepEventCount;
  final int historicalStepReplayCount;
  final int fixedLagReplayCount;
  final int fixedLagHistoryEventCount;
  final int fixedLagHistoryWindowMs;
  final int normalGnssAcceptedFixCount;
  final int deniedGnssQuarantinedFixCount;
  final int deniedGnssUsedByEstimatorCount;
  final int lateHeadingEventCount;
  final int lateStepEventCount;
  final int lateArcoreEventCount;
  final int recoveryGoodFixCount;
  final LiveFusionMode fusionMode;
  final double? stepCallbackLatencyLastMs;
  final double? stepCallbackLatencyMaxMs;
  final double? stepCallbackLatencyMeanMs;
  final double? recoveryCorrectionM;
  final double? strideEstimateM;
  final double? walkingHeadingOffsetDeg;
  final bool? stationaryDetected;
  final int stationaryEntryCount;
  final int stationaryDurationMs;
  final int stationaryCandidateCount;
  final int stationaryBlockedRecentStepCount;
  final int stationaryBlockedHeadingMotionCount;
  final int stationaryBlockedArcoreMotionCount;
  final double? adaptiveArcoreSigmaM;
  final double? arcoreNisLast;
  final double? arcorePostRobustNisLast;
  final int arcoreAcceptedAfterRobustInflationCount;
  final int arcoreRejectedAfterMaxInflationCount;
  final double? sourceDisagreementM;

  bool get stepCounterInvariantHolds =>
      pdrPredictionCount +
          stepEventsRejectedNoCausalHeading +
          lateStepEventCount +
          duplicateStepEventCount +
          pendingStepEventCount ==
      receivedStepEventCount;

  bool get countersAreNonNegative => <int>[
    headingUpdateCount,
    pdrPredictionCount,
    arCoreUpdateCount,
    receivedStepEventCount,
    stepEventsRejectedNoCausalHeading,
    duplicateStepEventCount,
    pendingStepEventCount,
    historicalStepReplayCount,
    fixedLagReplayCount,
    fixedLagHistoryEventCount,
    fixedLagHistoryWindowMs,
    normalGnssAcceptedFixCount,
    deniedGnssQuarantinedFixCount,
    deniedGnssUsedByEstimatorCount,
    lateHeadingEventCount,
    lateStepEventCount,
    lateArcoreEventCount,
    recoveryGoodFixCount,
  ].every((int value) => value >= 0);
}

class LiveNavguardEvent {
  const LiveNavguardEvent({
    required this.kind,
    required this.state,
    this.position,
    this.message,
    this.recoveryGoodFixCount = 0,
    this.recoveryRequiredFixCount = 3,
    this.preRecoveryEastM,
    this.preRecoveryNorthM,
    this.recoveredEastM,
    this.recoveredNorthM,
    this.recoveryCorrectionM,
  });

  factory LiveNavguardEvent.fromRaw(Object? raw) {
    final Map<Object?, Object?> map = _map(raw, 'event');
    _schema(map);
    final String kind = map['kind']?.toString() ?? '';
    const Set<String> kinds = <String>{
      'state',
      'position',
      'recovery_progress',
      'completed',
      'error',
    };
    if (!kinds.contains(kind)) {
      throw FormatException('Unknown live event kind: $kind');
    }
    final LiveNavguardPosition? position = kind == 'position'
        ? LiveNavguardPosition.fromMap(map)
        : null;
    return LiveNavguardEvent(
      kind: kind,
      state: LiveNavguardState.parse(map['state']),
      position: position,
      message: map['message']?.toString(),
      recoveryGoodFixCount: _optionalInteger(map, 'recoveryGoodFixCount', 0),
      recoveryRequiredFixCount: _optionalInteger(
        map,
        'recoveryRequiredFixCount',
        3,
      ),
      preRecoveryEastM: _optionalNumber(map, 'preRecoveryEastM'),
      preRecoveryNorthM: _optionalNumber(map, 'preRecoveryNorthM'),
      recoveredEastM: _optionalNumber(map, 'recoveredEastM'),
      recoveredNorthM: _optionalNumber(map, 'recoveredNorthM'),
      recoveryCorrectionM: _optionalNumber(map, 'recoveryCorrectionM'),
    );
  }

  final String kind;
  final LiveNavguardState state;
  final LiveNavguardPosition? position;
  final String? message;
  final int recoveryGoodFixCount;
  final int recoveryRequiredFixCount;
  final double? preRecoveryEastM;
  final double? preRecoveryNorthM;
  final double? recoveredEastM;
  final double? recoveredNorthM;
  final double? recoveryCorrectionM;
}

abstract interface class LiveNavguardPlatform {
  Stream<Object?> get events;
  Future<LiveNavguardPreflight> getPreflight(LiveNavguardAnchor anchor);
  Future<void> start(
    LiveNavguardAnchor anchor, [
    LiveFusionMode fusionMode = LiveFusionMode.navguardV1,
  ]);
  Future<void> beginDenial();
  Future<void> requestRecovery();
  Future<void> stop();
}

class MethodChannelLiveNavguardPlatform implements LiveNavguardPlatform {
  const MethodChannelLiveNavguardPlatform();

  static const MethodChannel _methods = MethodChannel(
    liveNavguardMethodChannelName,
  );
  static const EventChannel _eventChannel = EventChannel(
    liveNavguardEventChannelName,
  );

  @override
  Stream<Object?> get events => _eventChannel.receiveBroadcastStream();

  @override
  Future<LiveNavguardPreflight> getPreflight(LiveNavguardAnchor anchor) async {
    final Object? raw = await _methods.invokeMethod<Object?>(
      'getLiveNavguardDemoPreflight',
      anchor.toArguments(),
    );
    return LiveNavguardPreflight.fromMap(raw);
  }

  @override
  Future<void> start(
    LiveNavguardAnchor anchor, [
    LiveFusionMode fusionMode = LiveFusionMode.navguardV1,
  ]) => _invoke('startLiveNavguardDemo', <String, Object?>{
    ...anchor.toArguments(),
    'fusionMode': fusionMode.wireName,
  });

  @override
  Future<void> beginDenial() => _invoke('beginLiveGnssDenial');

  @override
  Future<void> requestRecovery() => _invoke('requestLiveGnssRecovery');

  @override
  Future<void> stop() => _invoke('stopLiveNavguardDemo');

  Future<void> _invoke(String method, [Object? arguments]) async {
    await _methods.invokeMethod<Object?>(method, arguments);
  }
}

class LiveNavguardStateMachine {
  LiveNavguardStateMachine([this.state = LiveNavguardState.idle]);
  LiveNavguardState state;

  bool canTransition(LiveNavguardState next) {
    if (next == LiveNavguardState.error) {
      return state != LiveNavguardState.stopped;
    }
    return switch (state) {
      LiveNavguardState.idle => next == LiveNavguardState.preparing,
      LiveNavguardState.preparing =>
        next == LiveNavguardState.gnssActive ||
            next == LiveNavguardState.stopped,
      LiveNavguardState.gnssActive =>
        next == LiveNavguardState.navguardReady ||
            next == LiveNavguardState.stopped,
      LiveNavguardState.navguardReady =>
        next == LiveNavguardState.gnssActive ||
            next == LiveNavguardState.navguardActive ||
            next == LiveNavguardState.stopped,
      LiveNavguardState.navguardActive =>
        next == LiveNavguardState.recoveryPending ||
            next == LiveNavguardState.stopped,
      LiveNavguardState.recoveryPending =>
        next == LiveNavguardState.gnssRecovered ||
            next == LiveNavguardState.stopped,
      LiveNavguardState.gnssRecovered => next == LiveNavguardState.stopped,
      LiveNavguardState.stopped ||
      LiveNavguardState.error => next == LiveNavguardState.preparing,
    };
  }

  void transition(LiveNavguardState next) {
    if (!canTransition(next)) {
      throw StateError(
        'Invalid live transition: ${state.wireName} → ${next.wireName}',
      );
    }
    state = next;
  }
}

class GeodeticPoint {
  const GeodeticPoint(this.latitudeDeg, this.longitudeDeg, this.altitudeM);
  final double latitudeDeg;
  final double longitudeDeg;
  final double altitudeM;
}

class EnuPoint {
  const EnuPoint(this.eastM, this.northM, [this.upM = 0]);
  final double eastM;
  final double northM;
  final double upM;
}

class Wgs84EnuProjection {
  Wgs84EnuProjection(this.anchor)
    : assert(anchor.coordinatesAreValid),
      _anchorEcef = _toEcef(
        anchor.latitudeDeg,
        anchor.longitudeDeg,
        anchor.altitudeEllipsoidM ?? 0,
      );

  static const double _a = 6378137;
  static const double _e2 = 6.69437999014e-3;
  final LiveNavguardAnchor anchor;
  final List<double> _anchorEcef;

  GeodeticPoint fromEnu(EnuPoint enu) {
    final double latitude = _radians(anchor.latitudeDeg);
    final double longitude = _radians(anchor.longitudeDeg);
    final double sinLat = math.sin(latitude);
    final double cosLat = math.cos(latitude);
    final double sinLon = math.sin(longitude);
    final double cosLon = math.cos(longitude);
    final double dx =
        -sinLon * enu.eastM -
        sinLat * cosLon * enu.northM +
        cosLat * cosLon * enu.upM;
    final double dy =
        cosLon * enu.eastM -
        sinLat * sinLon * enu.northM +
        cosLat * sinLon * enu.upM;
    final double dz = cosLat * enu.northM + sinLat * enu.upM;
    return _fromEcef(
      _anchorEcef[0] + dx,
      _anchorEcef[1] + dy,
      _anchorEcef[2] + dz,
    );
  }

  EnuPoint toEnu(GeodeticPoint point) {
    final List<double> ecef = _toEcef(
      point.latitudeDeg,
      point.longitudeDeg,
      point.altitudeM,
    );
    final double dx = ecef[0] - _anchorEcef[0];
    final double dy = ecef[1] - _anchorEcef[1];
    final double dz = ecef[2] - _anchorEcef[2];
    final double latitude = _radians(anchor.latitudeDeg);
    final double longitude = _radians(anchor.longitudeDeg);
    final double sinLat = math.sin(latitude);
    final double cosLat = math.cos(latitude);
    final double sinLon = math.sin(longitude);
    final double cosLon = math.cos(longitude);
    return EnuPoint(
      -sinLon * dx + cosLon * dy,
      -sinLat * cosLon * dx - sinLat * sinLon * dy + cosLat * dz,
      cosLat * cosLon * dx + cosLat * sinLon * dy + sinLat * dz,
    );
  }

  static List<double> _toEcef(double latDeg, double lonDeg, double altitude) {
    final double lat = _radians(latDeg);
    final double lon = _radians(lonDeg);
    final double sinLat = math.sin(lat);
    final double cosLat = math.cos(lat);
    final double radius = _a / math.sqrt(1 - _e2 * sinLat * sinLat);
    return <double>[
      (radius + altitude) * cosLat * math.cos(lon),
      (radius + altitude) * cosLat * math.sin(lon),
      (radius * (1 - _e2) + altitude) * sinLat,
    ];
  }

  static GeodeticPoint _fromEcef(double x, double y, double z) {
    final double longitude = math.atan2(y, x);
    final double p = math.sqrt(x * x + y * y);
    var latitude = math.atan2(z, p * (1 - _e2));
    var altitude = 0.0;
    for (var iteration = 0; iteration < 12; iteration++) {
      final double sinLat = math.sin(latitude);
      final double radius = _a / math.sqrt(1 - _e2 * sinLat * sinLat);
      altitude = p / math.cos(latitude) - radius;
      final double next = math.atan2(
        z,
        p * (1 - _e2 * radius / (radius + altitude)),
      );
      if ((next - latitude).abs() < 1e-13) {
        latitude = next;
        break;
      }
      latitude = next;
    }
    return GeodeticPoint(
      latitude * 180 / math.pi,
      longitude * 180 / math.pi,
      altitude,
    );
  }

  static double _radians(double degrees) => degrees * math.pi / 180;
}

class LiveRoutePoint {
  const LiveRoutePoint({
    required this.sequence,
    required this.eastM,
    required this.northM,
    required this.source,
  });
  final int sequence;
  final double eastM;
  final double northM;
  final LiveNavigationSource source;
}

class LiveRouteModel {
  LiveRouteModel({this.maximumPoints = 1000});
  final int maximumPoints;
  final List<LiveRoutePoint> _points = <LiveRoutePoint>[];
  List<LiveRoutePoint> get points => List<LiveRoutePoint>.unmodifiable(_points);
  LiveRoutePoint? denialStart;
  LiveRoutePoint? preRecovery;
  LiveRoutePoint? recovered;

  bool add(LiveNavguardPosition position) {
    if ((position.state == LiveNavguardState.navguardActive ||
            position.state == LiveNavguardState.recoveryPending) &&
        position.navigationSource == LiveNavigationSource.gnss) {
      return false;
    }
    final LiveRoutePoint next = LiveRoutePoint(
      sequence: position.sequence,
      eastM: position.eastM,
      northM: position.northM,
      source: position.navigationSource,
    );
    if (position.state == LiveNavguardState.navguardActive &&
        denialStart == null) {
      denialStart = next;
    }
    final LiveRoutePoint? last = _points.isEmpty ? null : _points.last;
    if (last != null) {
      final double distance = math.sqrt(
        math.pow(next.eastM - last.eastM, 2) +
            math.pow(next.northM - last.northM, 2),
      );
      if (distance < 0.25 && next.sequence - last.sequence < 5) return false;
    }
    _points.add(next);
    if (_points.length > maximumPoints) _points.removeAt(0);
    return true;
  }

  void setRecoveryConnector({
    required int sequence,
    required double preEastM,
    required double preNorthM,
    required double recoveredEastM,
    required double recoveredNorthM,
  }) {
    preRecovery = LiveRoutePoint(
      sequence: sequence,
      eastM: preEastM,
      northM: preNorthM,
      source: LiveNavigationSource.navguard,
    );
    recovered = LiveRoutePoint(
      sequence: sequence + 1,
      eastM: recoveredEastM,
      northM: recoveredNorthM,
      source: LiveNavigationSource.gnss,
    );
  }

  void reset() {
    _points.clear();
    denialStart = null;
    preRecovery = null;
    recovered = null;
  }
}

enum LiveTimedEventType { heading, step, arcorePosition }

class LiveTimedEvent {
  const LiveTimedEvent(
    this.timestampNs,
    this.type,
    this.insertionIndex, {
    this.headingRad = 0,
    this.eastM = 0,
    this.northM = 0,
  });
  final int timestampNs;
  final LiveTimedEventType type;
  final int insertionIndex;
  final double headingRad;
  final double eastM;
  final double northM;
}

class LiveReorderBuffer {
  LiveReorderBuffer({this.windowNs = 250000000});
  final int windowNs;
  final List<LiveTimedEvent> _pending = <LiveTimedEvent>[];
  final Set<int> _seenStepTimestamps = <int>{};
  final Set<int> _classifiedStepTimestamps = <int>{};
  int committedWatermarkNs = -1;
  int lateHeadingEventCount = 0;
  int lateStepEventCount = 0;
  int lateArcoreEventCount = 0;
  int receivedStepEventCount = 0;
  int pdrPredictionsApplied = 0;
  int stepEventsRejectedNoCausalHeading = 0;
  int duplicateStepEventCount = 0;

  int get pendingStepEventCount => _pending
      .where((LiveTimedEvent event) => event.type == LiveTimedEventType.step)
      .length;

  bool get stepCounterInvariantHolds =>
      pdrPredictionsApplied +
          stepEventsRejectedNoCausalHeading +
          lateStepEventCount +
          duplicateStepEventCount +
          pendingStepEventCount ==
      receivedStepEventCount;

  bool add(LiveTimedEvent event) {
    if (event.type == LiveTimedEventType.step) {
      receivedStepEventCount++;
      if (!_seenStepTimestamps.add(event.timestampNs)) {
        duplicateStepEventCount++;
        return false;
      }
    }
    if (event.timestampNs < committedWatermarkNs) {
      switch (event.type) {
        case LiveTimedEventType.heading:
          lateHeadingEventCount++;
        case LiveTimedEventType.step:
          lateStepEventCount++;
        case LiveTimedEventType.arcorePosition:
          lateArcoreEventCount++;
      }
      return false;
    }
    _pending.add(event);
    return true;
  }

  void markStepApplied(LiveTimedEvent event) {
    _classifyStep(event);
    pdrPredictionsApplied++;
  }

  void markStepRejectedNoCausalHeading(LiveTimedEvent event) {
    _classifyStep(event);
    stepEventsRejectedNoCausalHeading++;
  }

  List<LiveTimedEvent> commitThrough(int nowNs) {
    final int threshold = nowNs - windowNs;
    final List<LiveTimedEvent> ready = _pending
        .where((LiveTimedEvent event) => event.timestampNs <= threshold)
        .toList();
    _pending.removeWhere(
      (LiveTimedEvent event) => event.timestampNs <= threshold,
    );
    return _commit(ready);
  }

  List<LiveTimedEvent> drainAll() {
    final List<LiveTimedEvent> ready = List<LiveTimedEvent>.from(_pending);
    _pending.clear();
    return _commit(ready);
  }

  List<LiveTimedEvent> _commit(List<LiveTimedEvent> ready) {
    ready.sort((LiveTimedEvent first, LiveTimedEvent second) {
      final int timestamp = first.timestampNs.compareTo(second.timestampNs);
      if (timestamp != 0) return timestamp;
      final int type = first.type.index.compareTo(second.type.index);
      return type != 0
          ? type
          : first.insertionIndex.compareTo(second.insertionIndex);
    });
    for (final LiveTimedEvent event in ready) {
      committedWatermarkNs = math.max(committedWatermarkNs, event.timestampNs);
    }
    return ready;
  }

  void _classifyStep(LiveTimedEvent event) {
    if (event.type != LiveTimedEventType.step ||
        !_seenStepTimestamps.contains(event.timestampNs) ||
        !_classifiedStepTimestamps.add(event.timestampNs)) {
      throw StateError('Step outcome must be recorded exactly once.');
    }
  }
}

class LiveFixedLagReplayModel {
  LiveFixedLagReplayModel({
    required int startTimestampNs,
    this.historyWindowNs = 12000000000,
    this.maximumHistoryEvents = 4096,
  }) : _baseWatermarkNs = startTimestampNs - 1;

  final int historyWindowNs;
  final int maximumHistoryEvents;
  final List<_LiveReplayHistoryEntry> _history = <_LiveReplayHistoryEntry>[];
  final Set<int> _seenStepTimestamps = <int>{};
  _LiveReplaySnapshot _base = const _LiveReplaySnapshot();

  double eastM = 0;
  double northM = 0;
  double headingRad = 0;
  double covarianceTrace = 3;
  int? latestHeadingTimestampNs;
  int _baseWatermarkNs;
  int committedWatermarkNs = -1;
  int receivedStepEventCount = 0;
  int pdrPredictionsApplied = 0;
  int stepEventsRejectedNoCausalHeading = 0;
  int lateStepEventCount = 0;
  int duplicateStepEventCount = 0;
  int historicalStepReplayCount = 0;
  int fixedLagReplayCount = 0;
  final Map<int, int> _stepHeadingTimestampNs = <int, int>{};

  int get historyEventCount => _history.length;
  bool get stateIsFinite =>
      eastM.isFinite &&
      northM.isFinite &&
      headingRad.isFinite &&
      covarianceTrace.isFinite &&
      covarianceTrace > 0;
  bool get stepCounterInvariantHolds =>
      pdrPredictionsApplied +
          stepEventsRejectedNoCausalHeading +
          lateStepEventCount +
          duplicateStepEventCount ==
      receivedStepEventCount;

  int? headingTimestampForStep(int stepTimestampNs) =>
      _stepHeadingTimestampNs[stepTimestampNs];

  void applyLiveEvent(
    LiveTimedEvent event, {
    required int callbackTimestampNs,
  }) {
    if (event.type == LiveTimedEventType.step) {
      throw ArgumentError('Use deliverStep for step events.');
    }
    if (event.timestampNs < committedWatermarkNs) return;
    final _LiveReplaySnapshot before = _capture();
    _apply(event);
    _history.add(_LiveReplayHistoryEntry(event, before));
    committedWatermarkNs = event.timestampNs;
    _prune(callbackTimestampNs);
  }

  bool deliverStep(LiveTimedEvent step, {required int callbackTimestampNs}) {
    if (step.type != LiveTimedEventType.step) {
      throw ArgumentError('Expected a step event.');
    }
    receivedStepEventCount++;
    if (callbackTimestampNs - step.timestampNs > historyWindowNs ||
        step.timestampNs <= _baseWatermarkNs) {
      lateStepEventCount++;
      return false;
    }
    if (!_seenStepTimestamps.add(step.timestampNs)) {
      duplicateStepEventCount++;
      return false;
    }
    if (step.timestampNs > committedWatermarkNs) {
      final _LiveReplaySnapshot before = _capture();
      _apply(step);
      _history.add(_LiveReplayHistoryEntry(step, before));
      committedWatermarkNs = step.timestampNs;
      _prune(callbackTimestampNs);
      return true;
    }

    final int appliedBefore = pdrPredictionsApplied;
    final List<LiveTimedEvent> events =
        _history.map((_LiveReplayHistoryEntry entry) => entry.event).toList()
          ..add(step)
          ..sort(_compareLiveEvents);
    _restore(_base);
    _history.clear();
    for (final LiveTimedEvent event in events) {
      final _LiveReplaySnapshot before = _capture();
      _apply(event);
      _history.add(_LiveReplayHistoryEntry(event, before));
    }
    fixedLagReplayCount++;
    if (pdrPredictionsApplied > appliedBefore) historicalStepReplayCount++;
    _prune(callbackTimestampNs);
    return true;
  }

  void _apply(LiveTimedEvent event) {
    switch (event.type) {
      case LiveTimedEventType.heading:
        headingRad = event.headingRad;
        latestHeadingTimestampNs = event.timestampNs;
        covarianceTrace = math.max(0.01, covarianceTrace * 0.999);
      case LiveTimedEventType.step:
        final int? headingTimestamp = latestHeadingTimestampNs;
        if (headingTimestamp == null ||
            headingTimestamp > event.timestampNs ||
            event.timestampNs - headingTimestamp > 150000000) {
          stepEventsRejectedNoCausalHeading++;
          return;
        }
        eastM += 0.75 * math.sin(headingRad);
        northM += 0.75 * math.cos(headingRad);
        covarianceTrace += 0.04;
        pdrPredictionsApplied++;
        _stepHeadingTimestampNs[event.timestampNs] = headingTimestamp;
      case LiveTimedEventType.arcorePosition:
        eastM = (eastM * 0.8) + (event.eastM * 0.2);
        northM = (northM * 0.8) + (event.northM * 0.2);
        covarianceTrace = math.max(0.01, covarianceTrace * 0.95);
    }
  }

  _LiveReplaySnapshot _capture() => _LiveReplaySnapshot(
    eastM: eastM,
    northM: northM,
    headingRad: headingRad,
    covarianceTrace: covarianceTrace,
    latestHeadingTimestampNs: latestHeadingTimestampNs,
    pdrPredictionsApplied: pdrPredictionsApplied,
    stepEventsRejectedNoCausalHeading: stepEventsRejectedNoCausalHeading,
    stepHeadingTimestampNs: Map<int, int>.from(_stepHeadingTimestampNs),
  );

  void _restore(_LiveReplaySnapshot snapshot) {
    eastM = snapshot.eastM;
    northM = snapshot.northM;
    headingRad = snapshot.headingRad;
    covarianceTrace = snapshot.covarianceTrace;
    latestHeadingTimestampNs = snapshot.latestHeadingTimestampNs;
    pdrPredictionsApplied = snapshot.pdrPredictionsApplied;
    stepEventsRejectedNoCausalHeading =
        snapshot.stepEventsRejectedNoCausalHeading;
    _stepHeadingTimestampNs
      ..clear()
      ..addAll(snapshot.stepHeadingTimestampNs);
  }

  void _prune(int nowNs) {
    final int cutoffNs = nowNs - historyWindowNs;
    int removeCount = _history.indexWhere(
      (_LiveReplayHistoryEntry entry) => entry.event.timestampNs >= cutoffNs,
    );
    if (removeCount < 0) removeCount = _history.length;
    removeCount = math.max(removeCount, _history.length - maximumHistoryEvents);
    if (removeCount > 0) {
      _baseWatermarkNs = math.max(
        _baseWatermarkNs,
        _history[removeCount - 1].event.timestampNs,
      );
      _base = removeCount < _history.length
          ? _history[removeCount].before
          : _capture();
      _history.removeRange(0, removeCount);
    }
    _seenStepTimestamps.removeWhere((int timestamp) => timestamp < cutoffNs);
  }
}

class _LiveReplayHistoryEntry {
  const _LiveReplayHistoryEntry(this.event, this.before);
  final LiveTimedEvent event;
  final _LiveReplaySnapshot before;
}

class _LiveReplaySnapshot {
  const _LiveReplaySnapshot({
    this.eastM = 0,
    this.northM = 0,
    this.headingRad = 0,
    this.covarianceTrace = 3,
    this.latestHeadingTimestampNs,
    this.pdrPredictionsApplied = 0,
    this.stepEventsRejectedNoCausalHeading = 0,
    this.stepHeadingTimestampNs = const <int, int>{},
  });

  final double eastM;
  final double northM;
  final double headingRad;
  final double covarianceTrace;
  final int? latestHeadingTimestampNs;
  final int pdrPredictionsApplied;
  final int stepEventsRejectedNoCausalHeading;
  final Map<int, int> stepHeadingTimestampNs;
}

int _compareLiveEvents(LiveTimedEvent first, LiveTimedEvent second) {
  final int timestamp = first.timestampNs.compareTo(second.timestampNs);
  if (timestamp != 0) return timestamp;
  final int type = first.type.index.compareTo(second.type.index);
  return type != 0
      ? type
      : first.insertionIndex.compareTo(second.insertionIndex);
}

class LiveStepLatencyAccumulator {
  int sampleCount = 0;
  double? lastMs;
  double? maxMs;
  double _totalMs = 0;

  double? get meanMs => sampleCount == 0 ? null : _totalMs / sampleCount;

  void observe({
    required int eventTimestampNs,
    required int callbackTimestampNs,
  }) {
    if (eventTimestampNs <= 0 || callbackTimestampNs < eventTimestampNs) {
      throw ArgumentError('Invalid elapsed-realtime step timestamps.');
    }
    final double latencyMs =
        (callbackTimestampNs - eventTimestampNs) / 1000000.0;
    sampleCount++;
    lastMs = latencyMs;
    maxMs = math.max(maxMs ?? 0, latencyMs);
    _totalMs += latencyMs;
  }
}

class LiveHeadingSample {
  const LiveHeadingSample(this.timestampNs, this.headingRad);
  final int timestampNs;
  final double headingRad;
}

LiveHeadingSample? causalHeadingForStep(
  Iterable<LiveHeadingSample> samples,
  int stepTimestampNs,
) {
  LiveHeadingSample? selected;
  for (final LiveHeadingSample sample in samples) {
    if (sample.timestampNs <= stepTimestampNs &&
        (selected == null || sample.timestampNs > selected.timestampNs)) {
      selected = sample;
    }
  }
  return selected;
}

class LiveGnssFirewall {
  int normalAcceptedFixCount = 0;
  int deniedQuarantinedFixCount = 0;
  int deniedUsedByEstimatorCount = 0;

  bool acceptForEstimator(LiveNavguardState state) {
    if (state == LiveNavguardState.navguardActive ||
        state == LiveNavguardState.recoveryPending) {
      deniedQuarantinedFixCount++;
      return false;
    }
    normalAcceptedFixCount++;
    return true;
  }
}

class LiveRecoveryGate {
  LiveRecoveryGate({this.requiredGoodFixes = 3});
  final int requiredGoodFixes;
  int gateGenerationNs = -1;
  int consecutiveGoodFixes = 0;

  void open(int generationNs) {
    gateGenerationNs = generationNs;
    consecutiveGoodFixes = 0;
  }

  bool observe({required int generationNs, required double accuracyM}) {
    if (generationNs < gateGenerationNs) return false;
    if (!accuracyM.isFinite || accuracyM < 0 || accuracyM > 50) {
      consecutiveGoodFixes = 0;
      return false;
    }
    consecutiveGoodFixes++;
    return consecutiveGoodFixes >= requiredGoodFixes;
  }
}

class LiveMapAvailability {
  bool tilesUnavailable = false;
  void reportTileFailure() => tilesUnavailable = true;
}

const Map<String, bool> liveResearchFlags = <String, bool>{
  'liveMapDemoImplemented': true,
  'softwareDefinedGnssDenialImplemented': true,
  'recoveryVisualizationImplemented': true,
  'softwareDefinedGnssDenial': true,
  'rfInterferenceUsed': false,
  'gnssSpoofingUsed': false,
  'protectedGroundTruthAccessed': false,
  'mapUsedAsEstimatorInput': false,
  'liveDemoAccuracyValidated': false,
  'stepLengthValidated': false,
  'headingAccuracyValidated': false,
  'arcorePositionAccuracyValidated': false,
  'noiseParametersValidated': false,
  'qualityThresholdsValidated': false,
  'liveResearchValidationCompleted': false,
  'formalOutdoorBenchmarkCompleted': false,
  'finalAccuracyClaimAuthorized': false,
};

const Map<String, bool> livePrivacyFlags = <String, bool>{
  'routePersisted': false,
  'routeUploaded': false,
  'rawSensorDataStreamedToFlutter': false,
  'rawArcorePoseStreamedToFlutter': false,
  'rawTimestampsStreamedToFlutter': false,
};

Map<Object?, Object?> _map(Object? raw, String label) {
  if (raw is! Map<Object?, Object?>) {
    throw FormatException('Invalid $label payload');
  }
  return raw;
}

void _schema(Map<Object?, Object?> map) {
  final Object? raw = map['schemaVersion'];
  if (raw is! num || raw.toInt() != 1) {
    throw const FormatException('Unsupported live demo schema');
  }
}

double _number(Map<Object?, Object?> map, String key) {
  final Object? raw = map[key];
  if (raw is! num || !raw.toDouble().isFinite) {
    throw FormatException('Invalid $key');
  }
  return raw.toDouble();
}

double? _optionalNumber(Map<Object?, Object?> map, String key) {
  final Object? raw = map[key];
  if (raw == null) return null;
  if (raw is! num || !raw.toDouble().isFinite) {
    throw FormatException('Invalid $key');
  }
  return raw.toDouble();
}

int _integer(Map<Object?, Object?> map, String key) {
  final Object? value = map[key];
  if (value is! num) throw FormatException('Invalid $key');
  return value.toInt();
}

int _optionalInteger(Map<Object?, Object?> map, String key, int fallback) {
  final Object? value = map[key];
  return value is num ? value.toInt() : fallback;
}

bool? _optionalBool(Map<Object?, Object?> map, String key) {
  final Object? value = map[key];
  if (value == null) return null;
  if (value is! bool) throw FormatException('Invalid $key');
  return value;
}
