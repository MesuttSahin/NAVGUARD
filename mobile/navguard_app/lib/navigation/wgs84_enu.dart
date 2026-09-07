import 'dart:math' as math;

class GeodeticPoint {
  GeodeticPoint({
    required this.latitudeDeg,
    required this.longitudeDeg,
    this.altitudeEllipsoidM,
  }) {
    _validateLatitude(latitudeDeg);
    _validateLongitude(longitudeDeg);

    final double? altitude = altitudeEllipsoidM;
    if (altitude != null && !altitude.isFinite) {
      throw ArgumentError('Ellipsoid altitude must be finite when provided.');
    }
  }

  final double latitudeDeg;
  final double longitudeDeg;
  final double? altitudeEllipsoidM;
}

class EcefPoint {
  EcefPoint({required this.xM, required this.yM, required this.zM}) {
    _validateFinite(xM, 'ECEF X');
    _validateFinite(yM, 'ECEF Y');
    _validateFinite(zM, 'ECEF Z');
  }

  final double xM;
  final double yM;
  final double zM;
}

class EnuPoint2D {
  EnuPoint2D({required this.eastM, required this.northM}) {
    _validateFinite(eastM, 'ENU East');
    _validateFinite(northM, 'ENU North');
  }

  final double eastM;
  final double northM;
}

class EnuPoint3D {
  EnuPoint3D({required this.eastM, required this.northM, required this.upM}) {
    _validateFinite(eastM, 'ENU East');
    _validateFinite(northM, 'ENU North');
    _validateFinite(upM, 'ENU Up');
  }

  final double eastM;
  final double northM;
  final double upM;
}

class Wgs84EnuConverter {
  const Wgs84EnuConverter._();

  static const double semiMajorAxisM = 6378137.0;
  static const double flattening = 1.0 / 298.257223563;
  static const double eccentricitySquared = flattening * (2.0 - flattening);

  static EcefPoint geodeticToEcef(GeodeticPoint point) {
    final double? altitudeEllipsoidM = point.altitudeEllipsoidM;

    if (altitudeEllipsoidM == null) {
      throw ArgumentError('Full ECEF conversion requires ellipsoid altitude.');
    }

    return _geodeticToEcefAtAltitude(point, altitudeEllipsoidM);
  }

  static EnuPoint3D toEnu3D({
    required GeodeticPoint anchor,
    required GeodeticPoint target,
  }) {
    if (anchor.altitudeEllipsoidM == null) {
      throw ArgumentError(
        'Full 3D ENU conversion requires anchor ellipsoid altitude.',
      );
    }

    if (target.altitudeEllipsoidM == null) {
      throw ArgumentError(
        'Full 3D ENU conversion requires target ellipsoid altitude.',
      );
    }

    final EcefPoint anchorEcef = geodeticToEcef(anchor);
    final EcefPoint targetEcef = geodeticToEcef(target);
    final _EnuComponents components = _rotateEcefDeltaToEnu(
      anchor: anchor,
      anchorEcef: anchorEcef,
      targetEcef: targetEcef,
    );

    return EnuPoint3D(
      eastM: components.eastM,
      northM: components.northM,
      upM: components.upM,
    );
  }

  static EnuPoint2D toHorizontalEnu({
    required GeodeticPoint anchor,
    required GeodeticPoint target,
  }) {
    // Horizontal mode deliberately uses the same h = 0 reference for both
    // points. It neither fabricates nor returns a measured Up component.
    final EcefPoint anchorEcef = _geodeticToEcefAtAltitude(anchor, 0.0);
    final EcefPoint targetEcef = _geodeticToEcefAtAltitude(target, 0.0);
    final _EnuComponents components = _rotateEcefDeltaToEnu(
      anchor: anchor,
      anchorEcef: anchorEcef,
      targetEcef: targetEcef,
    );

    return EnuPoint2D(eastM: components.eastM, northM: components.northM);
  }

  static EcefPoint _geodeticToEcefAtAltitude(
    GeodeticPoint point,
    double altitudeEllipsoidM,
  ) {
    final double latitudeRad = _degreesToRadians(point.latitudeDeg);
    final double longitudeRad = _degreesToRadians(point.longitudeDeg);
    final double sinLatitude = math.sin(latitudeRad);
    final double cosLatitude = math.cos(latitudeRad);
    final double sinLongitude = math.sin(longitudeRad);
    final double cosLongitude = math.cos(longitudeRad);

    final double primeVerticalRadiusM =
        semiMajorAxisM /
        math.sqrt(1.0 - eccentricitySquared * sinLatitude * sinLatitude);

    final double xM =
        (primeVerticalRadiusM + altitudeEllipsoidM) *
        cosLatitude *
        cosLongitude;
    final double yM =
        (primeVerticalRadiusM + altitudeEllipsoidM) *
        cosLatitude *
        sinLongitude;
    final double zM =
        (primeVerticalRadiusM * (1.0 - eccentricitySquared) +
            altitudeEllipsoidM) *
        sinLatitude;

    return EcefPoint(xM: xM, yM: yM, zM: zM);
  }

  static _EnuComponents _rotateEcefDeltaToEnu({
    required GeodeticPoint anchor,
    required EcefPoint anchorEcef,
    required EcefPoint targetEcef,
  }) {
    final double anchorLatitudeRad = _degreesToRadians(anchor.latitudeDeg);
    final double anchorLongitudeRad = _degreesToRadians(anchor.longitudeDeg);

    final double sinLatitude = math.sin(anchorLatitudeRad);
    final double cosLatitude = math.cos(anchorLatitudeRad);
    final double sinLongitude = math.sin(anchorLongitudeRad);
    final double cosLongitude = math.cos(anchorLongitudeRad);

    final double deltaX = targetEcef.xM - anchorEcef.xM;
    final double deltaY = targetEcef.yM - anchorEcef.yM;
    final double deltaZ = targetEcef.zM - anchorEcef.zM;

    final double eastM = -sinLongitude * deltaX + cosLongitude * deltaY;
    final double northM =
        -sinLatitude * cosLongitude * deltaX -
        sinLatitude * sinLongitude * deltaY +
        cosLatitude * deltaZ;
    final double upM =
        cosLatitude * cosLongitude * deltaX +
        cosLatitude * sinLongitude * deltaY +
        sinLatitude * deltaZ;

    return _EnuComponents(eastM: eastM, northM: northM, upM: upM);
  }

  static double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }
}

class _EnuComponents {
  const _EnuComponents({
    required this.eastM,
    required this.northM,
    required this.upM,
  });

  final double eastM;
  final double northM;
  final double upM;
}

void _validateLatitude(double latitudeDeg) {
  _validateFinite(latitudeDeg, 'Latitude');

  if (latitudeDeg < -90.0 || latitudeDeg > 90.0) {
    throw ArgumentError('Latitude must be within [-90, 90] degrees.');
  }
}

void _validateLongitude(double longitudeDeg) {
  _validateFinite(longitudeDeg, 'Longitude');

  if (longitudeDeg < -180.0 || longitudeDeg > 180.0) {
    throw ArgumentError('Longitude must be within [-180, 180] degrees.');
  }
}

void _validateFinite(double value, String name) {
  if (!value.isFinite) {
    throw ArgumentError('$name must be finite.');
  }
}
