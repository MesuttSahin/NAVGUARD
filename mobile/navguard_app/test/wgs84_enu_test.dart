import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:navguard/navigation/wgs84_enu.dart';

void main() {
  group('Wgs84EnuConverter', () {
    test('same geodetic point produces zero 3D ENU displacement', () {
      final GeodeticPoint point = GeodeticPoint(
        latitudeDeg: 0.0,
        longitudeDeg: 0.0,
        altitudeEllipsoidM: 100.0,
      );

      final EnuPoint3D enu = Wgs84EnuConverter.toEnu3D(
        anchor: point,
        target: point,
      );

      expect(enu.eastM, closeTo(0.0, 1e-9));
      expect(enu.northM, closeTo(0.0, 1e-9));
      expect(enu.upM, closeTo(0.0, 1e-9));
    });

    test('positive longitude displacement points east', () {
      final EnuPoint2D enu = Wgs84EnuConverter.toHorizontalEnu(
        anchor: GeodeticPoint(latitudeDeg: 0.0, longitudeDeg: 0.0),
        target: GeodeticPoint(latitudeDeg: 0.0, longitudeDeg: 0.0001),
      );

      expect(enu.eastM, greaterThan(0.0));
      expect(enu.eastM.abs(), greaterThan(enu.northM.abs() * 100.0));
    });

    test('negative longitude displacement points west', () {
      final EnuPoint2D enu = Wgs84EnuConverter.toHorizontalEnu(
        anchor: GeodeticPoint(latitudeDeg: 0.0, longitudeDeg: 0.0),
        target: GeodeticPoint(latitudeDeg: 0.0, longitudeDeg: -0.0001),
      );

      expect(enu.eastM, lessThan(0.0));
      expect(enu.eastM.abs(), greaterThan(enu.northM.abs() * 100.0));
    });

    test('positive latitude displacement points north', () {
      final EnuPoint2D enu = Wgs84EnuConverter.toHorizontalEnu(
        anchor: GeodeticPoint(latitudeDeg: 0.0, longitudeDeg: 0.0),
        target: GeodeticPoint(latitudeDeg: 0.0001, longitudeDeg: 0.0),
      );

      expect(enu.northM, greaterThan(0.0));
      expect(enu.northM.abs(), greaterThan(enu.eastM.abs() * 100.0));
    });

    test('negative latitude displacement points south', () {
      final EnuPoint2D enu = Wgs84EnuConverter.toHorizontalEnu(
        anchor: GeodeticPoint(latitudeDeg: 0.0, longitudeDeg: 0.0),
        target: GeodeticPoint(latitudeDeg: -0.0001, longitudeDeg: 0.0),
      );

      expect(enu.northM, lessThan(0.0));
      expect(enu.northM.abs(), greaterThan(enu.eastM.abs() * 100.0));
    });

    test('positive ellipsoid altitude difference points up', () {
      final EnuPoint3D enu = Wgs84EnuConverter.toEnu3D(
        anchor: GeodeticPoint(
          latitudeDeg: 0.0,
          longitudeDeg: 0.0,
          altitudeEllipsoidM: 100.0,
        ),
        target: GeodeticPoint(
          latitudeDeg: 0.0,
          longitudeDeg: 0.0,
          altitudeEllipsoidM: 125.0,
        ),
      );

      expect(enu.eastM, closeTo(0.0, 1e-9));
      expect(enu.northM, closeTo(0.0, 1e-9));
      expect(enu.upM, closeTo(25.0, 1e-6));
    });

    test('horizontal conversion returns no fabricated Up component', () {
      final EnuPoint2D result = Wgs84EnuConverter.toHorizontalEnu(
        anchor: GeodeticPoint(latitudeDeg: 10.0, longitudeDeg: 20.0),
        target: GeodeticPoint(latitudeDeg: 10.0001, longitudeDeg: 20.0001),
      );

      expect(result, isA<EnuPoint2D>());
      expect(result.eastM.isFinite, isTrue);
      expect(result.northM.isFinite, isTrue);
    });

    test('full 3D mode requires both altitude values', () {
      final GeodeticPoint withoutAltitude = GeodeticPoint(
        latitudeDeg: 0.0,
        longitudeDeg: 0.0,
      );
      final GeodeticPoint withAltitude = GeodeticPoint(
        latitudeDeg: 0.0,
        longitudeDeg: 0.0,
        altitudeEllipsoidM: 10.0,
      );

      expect(
        () => Wgs84EnuConverter.toEnu3D(
          anchor: withoutAltitude,
          target: withAltitude,
        ),
        throwsArgumentError,
      );
      expect(
        () => Wgs84EnuConverter.toEnu3D(
          anchor: withAltitude,
          target: withoutAltitude,
        ),
        throwsArgumentError,
      );
    });

    test('non-equatorial positive deltas preserve East/North signs', () {
      final GeodeticPoint anchor = GeodeticPoint(
        latitudeDeg: 45.0,
        longitudeDeg: 30.0,
      );

      final EnuPoint2D eastResult = Wgs84EnuConverter.toHorizontalEnu(
        anchor: anchor,
        target: GeodeticPoint(latitudeDeg: 45.0, longitudeDeg: 30.0001),
      );

      final EnuPoint2D northResult = Wgs84EnuConverter.toHorizontalEnu(
        anchor: anchor,
        target: GeodeticPoint(latitudeDeg: 45.0001, longitudeDeg: 30.0),
      );

      expect(eastResult.eastM, greaterThan(0.0));
      expect(
        eastResult.eastM.abs(),
        greaterThan(eastResult.northM.abs() * 100.0),
      );

      expect(northResult.northM, greaterThan(0.0));
      expect(
        northResult.northM.abs(),
        greaterThan(northResult.eastM.abs() * 100.0),
      );
    });
  });

  group('GeodeticPoint validation', () {
    test('rejects invalid latitude values', () {
      for (final double latitude in <double>[
        90.0001,
        -90.0001,
        double.nan,
        double.infinity,
        double.negativeInfinity,
      ]) {
        expect(
          () => GeodeticPoint(latitudeDeg: latitude, longitudeDeg: 0.0),
          throwsArgumentError,
        );
      }
    });

    test('rejects invalid longitude values', () {
      for (final double longitude in <double>[
        180.0001,
        -180.0001,
        double.nan,
        double.infinity,
        double.negativeInfinity,
      ]) {
        expect(
          () => GeodeticPoint(latitudeDeg: 0.0, longitudeDeg: longitude),
          throwsArgumentError,
        );
      }
    });

    test('uses the frozen WGS84 constants', () {
      expect(Wgs84EnuConverter.semiMajorAxisM, 6378137.0);
      expect(Wgs84EnuConverter.flattening, closeTo(1.0 / 298.257223563, 1e-18));
      expect(
        Wgs84EnuConverter.eccentricitySquared,
        closeTo(
          Wgs84EnuConverter.flattening * (2.0 - Wgs84EnuConverter.flattening),
          math.pow(10.0, -18).toDouble(),
        ),
      );
    });
  });
}
