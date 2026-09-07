import 'wgs84_enu.dart';

enum GnssAnchorRuntimeState { noAnchor, acquiring, anchorLocked, failed }

extension GnssAnchorRuntimeStateLabel on GnssAnchorRuntimeState {
  String get displayLabel {
    switch (this) {
      case GnssAnchorRuntimeState.noAnchor:
        return 'No Anchor';
      case GnssAnchorRuntimeState.acquiring:
        return 'Acquiring';
      case GnssAnchorRuntimeState.anchorLocked:
        return 'Locked';
      case GnssAnchorRuntimeState.failed:
        return 'Failed';
    }
  }

  String get sanitizedName {
    switch (this) {
      case GnssAnchorRuntimeState.noAnchor:
        return 'no_anchor';
      case GnssAnchorRuntimeState.acquiring:
        return 'acquiring';
      case GnssAnchorRuntimeState.anchorLocked:
        return 'anchor_locked';
      case GnssAnchorRuntimeState.failed:
        return 'failed';
    }
  }
}

class GnssAnchorPreflight {
  const GnssAnchorPreflight({
    required this.fineLocationPermissionGranted,
    required this.locationServicesEnabled,
    required this.gpsProviderEnabled,
    required this.acquisitionRunning,
    required this.canAcquireAnchor,
  });

  factory GnssAnchorPreflight.fromPlatform(Map<Object?, Object?> snapshot) {
    return GnssAnchorPreflight(
      fineLocationPermissionGranted: _requiredBool(
        snapshot,
        'fineLocationPermissionGranted',
      ),
      locationServicesEnabled: _nullableBool(
        snapshot,
        'locationServicesEnabled',
      ),
      gpsProviderEnabled: _nullableBool(snapshot, 'gpsProviderEnabled'),
      acquisitionRunning: _requiredBool(snapshot, 'acquisitionRunning'),
      canAcquireAnchor: _requiredBool(snapshot, 'canAcquireAnchor'),
    );
  }

  final bool fineLocationPermissionGranted;
  final bool? locationServicesEnabled;
  final bool? gpsProviderEnabled;
  final bool acquisitionRunning;
  final bool canAcquireAnchor;
}

class GnssAnchor {
  const GnssAnchor._({
    required this.latitudeDeg,
    required this.longitudeDeg,
    required this.altitudeEllipsoidM,
    required this.horizontalAccuracyReportedM,
    required this.verticalAccuracyReportedM,
    required this.elapsedRealtimeNanos,
    required this.provider,
    required this.candidateCount,
    required this.selectionPolicy,
    required this.altitudeAvailable,
    required this.firstValidFixTimeoutMs,
    required this.candidateCollectionWindowMs,
    required this.minimumValidCandidateCount,
  });

  factory GnssAnchor.fromPlatform(Map<Object?, Object?> snapshot) {
    if (_requiredInt(snapshot, 'schemaVersion') != 1) {
      throw const FormatException('Unsupported GNSS anchor schema version.');
    }

    if (_requiredString(snapshot, 'snapshotKind') !=
        'gnss_anchor_acquisition_result') {
      throw const FormatException('Unexpected GNSS anchor snapshot kind.');
    }

    if (_requiredBool(snapshot, 'success') != true) {
      throw const FormatException('GNSS anchor result is not successful.');
    }

    final String provider = _requiredString(snapshot, 'provider');

    if (provider != 'gps') {
      throw const FormatException('GNSS anchor provider is not GPS_PROVIDER.');
    }

    final int candidateCount = _requiredInt(snapshot, 'candidateCount');
    final int minimumValidCandidateCount = _requiredInt(
      snapshot,
      'minimumValidCandidateCount',
    );

    if (candidateCount < 3) {
      throw const FormatException(
        'GNSS anchor candidate count is below the required minimum.',
      );
    }

    if (minimumValidCandidateCount != 3) {
      throw const FormatException(
        'GNSS anchor minimum candidate contract is invalid.',
      );
    }

    final String selectionPolicy = _requiredString(snapshot, 'selectionPolicy');

    if (selectionPolicy !=
        'lowest_reported_horizontal_accuracy_then_newer_elapsed_realtime') {
      throw const FormatException(
        'GNSS anchor selection policy is unsupported.',
      );
    }

    if (_requiredBool(snapshot, 'coordinateAccuracyValidated') != false) {
      throw const FormatException(
        'GNSS anchor must not claim validated coordinate accuracy.',
      );
    }

    if (_requiredBool(snapshot, 'selectedCandidateStructurallyValid') != true) {
      throw const FormatException(
        'Selected GNSS anchor candidate is not structurally valid.',
      );
    }

    if (_requiredBool(snapshot, 'selectedCandidateMock') != false) {
      throw const FormatException('Mock locations cannot become GNSS anchors.');
    }

    if (_requiredBool(snapshot, 'rawCandidateListReturned') != false) {
      throw const FormatException(
        'GNSS anchor result must not contain a raw candidate list.',
      );
    }

    final int firstValidFixTimeoutMs = _requiredInt(
      snapshot,
      'firstValidFixTimeoutMs',
    );

    if (firstValidFixTimeoutMs != 120000) {
      throw const FormatException(
        'GNSS anchor first-valid-fix timeout contract is invalid.',
      );
    }

    final int candidateCollectionWindowMs = _requiredInt(
      snapshot,
      'candidateCollectionWindowMs',
    );

    if (candidateCollectionWindowMs != 10000) {
      throw const FormatException(
        'GNSS anchor candidate-window contract is invalid.',
      );
    }

    final double latitudeDeg = _requiredFiniteDouble(snapshot, 'latitudeDeg');
    final double longitudeDeg = _requiredFiniteDouble(snapshot, 'longitudeDeg');

    if (latitudeDeg < -90.0 || latitudeDeg > 90.0) {
      throw const FormatException(
        'GNSS anchor latitude is outside the valid range.',
      );
    }

    if (longitudeDeg < -180.0 || longitudeDeg > 180.0) {
      throw const FormatException(
        'GNSS anchor longitude is outside the valid range.',
      );
    }

    final double? altitudeEllipsoidM = _nullableFiniteDouble(
      snapshot,
      'altitudeEllipsoidM',
    );
    final bool altitudeAvailable = _requiredBool(snapshot, 'altitudeAvailable');

    if (altitudeAvailable != (altitudeEllipsoidM != null)) {
      throw const FormatException(
        'GNSS anchor altitude availability metadata is inconsistent.',
      );
    }

    final double horizontalAccuracyReportedM = _requiredPositiveFiniteDouble(
      snapshot,
      'horizontalAccuracyReportedM',
    );
    final double selectedReportedHorizontalAccuracyM =
        _requiredPositiveFiniteDouble(
          snapshot,
          'selectedReportedHorizontalAccuracyM',
        );

    if (horizontalAccuracyReportedM != selectedReportedHorizontalAccuracyM) {
      throw const FormatException(
        'GNSS anchor horizontal-accuracy metadata is inconsistent.',
      );
    }

    final double? verticalAccuracyReportedM = _nullablePositiveFiniteDouble(
      snapshot,
      'verticalAccuracyReportedM',
    );
    final double? selectedReportedVerticalAccuracyM =
        _nullablePositiveFiniteDouble(
          snapshot,
          'selectedReportedVerticalAccuracyM',
        );

    if (verticalAccuracyReportedM != selectedReportedVerticalAccuracyM) {
      throw const FormatException(
        'GNSS anchor vertical-accuracy metadata is inconsistent.',
      );
    }

    final int elapsedRealtimeNanos = _requiredInt(
      snapshot,
      'elapsedRealtimeNanos',
    );

    if (elapsedRealtimeNanos <= 0) {
      throw const FormatException(
        'GNSS anchor elapsed-realtime timestamp is invalid.',
      );
    }

    return GnssAnchor._(
      latitudeDeg: latitudeDeg,
      longitudeDeg: longitudeDeg,
      altitudeEllipsoidM: altitudeEllipsoidM,
      horizontalAccuracyReportedM: horizontalAccuracyReportedM,
      verticalAccuracyReportedM: verticalAccuracyReportedM,
      elapsedRealtimeNanos: elapsedRealtimeNanos,
      provider: provider,
      candidateCount: candidateCount,
      selectionPolicy: selectionPolicy,
      altitudeAvailable: altitudeAvailable,
      firstValidFixTimeoutMs: firstValidFixTimeoutMs,
      candidateCollectionWindowMs: candidateCollectionWindowMs,
      minimumValidCandidateCount: minimumValidCandidateCount,
    );
  }

  final double latitudeDeg;
  final double longitudeDeg;
  final double? altitudeEllipsoidM;
  final double horizontalAccuracyReportedM;
  final double? verticalAccuracyReportedM;
  final int elapsedRealtimeNanos;
  final String provider;
  final int candidateCount;
  final String selectionPolicy;
  final bool altitudeAvailable;
  final int firstValidFixTimeoutMs;
  final int candidateCollectionWindowMs;
  final int minimumValidCandidateCount;

  GeodeticPoint toGeodeticPoint() {
    return GeodeticPoint(
      latitudeDeg: latitudeDeg,
      longitudeDeg: longitudeDeg,
      altitudeEllipsoidM: altitudeEllipsoidM,
    );
  }

  // Coordinates, altitude value, elapsed timestamp and raw Location data are
  // deliberately excluded from this logging/display representation.
  Map<String, Object?> get sanitizedMetadata {
    return <String, Object?>{
      'success': true,
      'candidateCount': candidateCount,
      'selectedReportedHorizontalAccuracyM': horizontalAccuracyReportedM,
      'altitudeAvailable': altitudeAvailable,
      'selectionPolicy': selectionPolicy,
      'coordinateAccuracyValidated': false,
      'firstValidFixTimeoutMs': firstValidFixTimeoutMs,
      'candidateCollectionWindowMs': candidateCollectionWindowMs,
      'minimumValidCandidateCount': minimumValidCandidateCount,
    };
  }
}

bool _requiredBool(Map<Object?, Object?> snapshot, String key) {
  final Object? value = snapshot[key];

  if (value is! bool) {
    throw FormatException('$key must be a boolean.');
  }

  return value;
}

bool? _nullableBool(Map<Object?, Object?> snapshot, String key) {
  final Object? value = snapshot[key];

  if (value == null) {
    return null;
  }

  if (value is! bool) {
    throw FormatException('$key must be a boolean or null.');
  }

  return value;
}

String _requiredString(Map<Object?, Object?> snapshot, String key) {
  final Object? value = snapshot[key];

  if (value is! String || value.isEmpty) {
    throw FormatException('$key must be a non-empty string.');
  }

  return value;
}

int _requiredInt(Map<Object?, Object?> snapshot, String key) {
  final Object? value = snapshot[key];

  if (value is! int) {
    throw FormatException('$key must be an integer.');
  }

  return value;
}

double _requiredFiniteDouble(Map<Object?, Object?> snapshot, String key) {
  final Object? value = snapshot[key];

  if (value is! num) {
    throw FormatException('$key must be numeric.');
  }

  final double converted = value.toDouble();

  if (!converted.isFinite) {
    throw FormatException('$key must be finite.');
  }

  return converted;
}

double _requiredPositiveFiniteDouble(
  Map<Object?, Object?> snapshot,
  String key,
) {
  final double value = _requiredFiniteDouble(snapshot, key);

  if (value <= 0.0) {
    throw FormatException('$key must be positive.');
  }

  return value;
}

double? _nullableFiniteDouble(Map<Object?, Object?> snapshot, String key) {
  if (snapshot[key] == null) {
    return null;
  }

  return _requiredFiniteDouble(snapshot, key);
}

double? _nullablePositiveFiniteDouble(
  Map<Object?, Object?> snapshot,
  String key,
) {
  if (snapshot[key] == null) {
    return null;
  }

  return _requiredPositiveFiniteDouble(snapshot, key);
}
