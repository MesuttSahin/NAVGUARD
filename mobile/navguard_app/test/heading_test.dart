import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:navguard/navigation/heading.dart';

void main() {
  group('normalizeHeadingRadians', () {
    test('normalizes canonical and wrapped angles to [0, 2pi)', () {
      expect(normalizeHeadingRadians(0.0), closeTo(0.0, 1e-12));
      expect(normalizeHeadingRadians(2.0 * math.pi), closeTo(0.0, 1e-12));
      expect(normalizeHeadingRadians(-2.0 * math.pi), closeTo(0.0, 1e-12));
      expect(
        normalizeHeadingRadians(math.pi / 2.0),
        closeTo(math.pi / 2.0, 1e-12),
      );
      expect(
        normalizeHeadingRadians(-0.1),
        closeTo((2.0 * math.pi) - 0.1, 1e-12),
      );
      expect(
        normalizeHeadingRadians((4.0 * math.pi) + 0.25),
        closeTo(0.25, 1e-12),
      );
    });

    test('rejects non-finite angles', () {
      expect(() => normalizeHeadingRadians(double.nan), throwsFormatException);
      expect(
        () => normalizeHeadingRadians(double.infinity),
        throwsFormatException,
      );
      expect(
        () => normalizeHeadingRadians(double.negativeInfinity),
        throwsFormatException,
      );
    });
  });

  group('shortestSignedHeadingDeltaRadians', () {
    double degrees(double value) => value * math.pi / 180.0;

    test('uses clockwise-positive circular differences', () {
      expect(
        shortestSignedHeadingDeltaRadians(degrees(10), degrees(20)),
        closeTo(degrees(10), 1e-12),
      );
      expect(
        shortestSignedHeadingDeltaRadians(degrees(20), degrees(10)),
        closeTo(degrees(-10), 1e-12),
      );
      expect(
        shortestSignedHeadingDeltaRadians(degrees(350), degrees(10)),
        closeTo(degrees(20), 1e-12),
      );
      expect(
        shortestSignedHeadingDeltaRadians(degrees(10), degrees(350)),
        closeTo(degrees(-20), 1e-12),
      );
    });

    test('freezes the half-turn boundary at negative pi', () {
      expect(
        shortestSignedHeadingDeltaRadians(0.0, math.pi),
        closeTo(-math.pi, 1e-12),
      );
      expect(
        shortestSignedHeadingDeltaRadians(math.pi, 0.0),
        closeTo(-math.pi, 1e-12),
      );
    });

    test('rejects non-finite inputs', () {
      expect(
        () => shortestSignedHeadingDeltaRadians(double.nan, 0.0),
        throwsFormatException,
      );
      expect(
        () => shortestSignedHeadingDeltaRadians(0.0, double.infinity),
        throwsFormatException,
      );
    });
  });

  group('HeadingFoundationPreflight', () {
    test('accepts the sanitized native contract', () {
      final HeadingFoundationPreflight preflight =
          HeadingFoundationPreflight.fromPlatform(<String, Object?>{
            'schemaVersion': 1,
            'snapshotKind': 'heading_foundation_preflight',
            'rotationVectorAvailable': true,
            'rotationVectorName': 'Synthetic Rotation Vector',
            'requestedSamplingPeriodUs': 20000,
            'diagnosticRunning': false,
          });

      expect(preflight.rotationVectorAvailable, isTrue);
      expect(preflight.rotationVectorName, 'Synthetic Rotation Vector');
      expect(preflight.diagnosticRunning, isFalse);
    });

    test('rejects inconsistent availability metadata', () {
      expect(
        () => HeadingFoundationPreflight.fromPlatform(<String, Object?>{
          'schemaVersion': 1,
          'snapshotKind': 'heading_foundation_preflight',
          'rotationVectorAvailable': true,
          'rotationVectorName': null,
          'requestedSamplingPeriodUs': 20000,
          'diagnosticRunning': false,
        }),
        throwsFormatException,
      );
    });
  });

  group('HeadingDiagnosticResult', () {
    test('accepts a valid synthetic aggregate', () {
      final HeadingDiagnosticResult result =
          HeadingDiagnosticResult.fromPlatform(_validHeadingResult());

      expect(result.validHeadingSampleCount, 1500);
      expect(result.observedSampleRateHz, closeTo(50.0, 1e-12));
      expect(result.lastTrueNorthCorrectedHeadingRad, closeTo(1.25, 1e-12));
      expect(result.reportedHeadingAccuracyAvailable, isTrue);
      expect(result.sanitizedMetadata, isNot(contains('latitudeDeg')));
      expect(result.sanitizedMetadata, isNot(contains('longitudeDeg')));
      expect(result.sanitizedMetadata, isNot(contains('altitudeEllipsoidM')));
    });

    final List<(String, void Function(Map<String, Object?>))> invalidCases =
        <(String, void Function(Map<String, Object?>))>[
          ('wrong schema', (map) => map['schemaVersion'] = 2),
          ('wrong snapshot kind', (map) => map['snapshotKind'] = 'wrong'),
          ('unsuccessful result', (map) => map['success'] = false),
          (
            'wrong sensor type',
            (map) => map['sensorType'] = 'TYPE_GAME_ROTATION_VECTOR',
          ),
          (
            'wrong requested period',
            (map) => map['requestedSamplingPeriodUs'] = 10000,
          ),
          ('wrong timeout', (map) => map['firstValidSampleTimeoutMs'] = 9999),
          ('wrong window', (map) => map['measurementWindowMs'] = 10000),
          (
            'wrong timestamp authority',
            (map) => map['sensorTimestampAuthority'] = 'wall_clock',
          ),
          (
            'wall-clock timing',
            (map) => map['wallClockUsedForSensorTiming'] = true,
          ),
          ('too few samples', (map) => map['validHeadingSampleCount'] = 1),
          (
            'impossible timestamp counts',
            (map) => map['uniqueTimestampCount'] = 1498,
          ),
          ('negative timing', (map) => map['minDeltaMs'] = -1.0),
          (
            'non-finite heading',
            (map) => map['lastMagneticHeadingRad'] = double.nan,
          ),
          (
            'heading at 2pi',
            (map) => map['lastMagneticHeadingRad'] = 2.0 * math.pi,
          ),
          (
            'wrong declination provider',
            (map) => map['declinationProvider'] = 'synthetic',
          ),
          (
            'freshness claimed',
            (map) => map['declinationModelFreshnessValidated'] = true,
          ),
          (
            'heading accuracy claimed',
            (map) => map['headingAccuracyValidated'] = true,
          ),
          (
            'true north accuracy claimed',
            (map) => map['trueNorthAccuracyValidated'] = true,
          ),
          (
            'body heading claimed',
            (map) => map['bodyHeadingImplemented'] = true,
          ),
          (
            'wrong forward axis',
            (map) => map['deviceForwardAxis'] = 'device_negative_z',
          ),
          (
            'wrong convention',
            (map) => map['headingConvention'] = 'counterclockwise',
          ),
        ];

    for (final (String description, void Function(Map<String, Object?>) mutate)
        in invalidCases) {
      test('rejects $description', () {
        final Map<String, Object?> snapshot = _validHeadingResult();
        mutate(snapshot);

        expect(
          () => HeadingDiagnosticResult.fromPlatform(snapshot),
          throwsFormatException,
        );
      });
    }
  });
}

Map<String, Object?> _validHeadingResult() {
  return <String, Object?>{
    'schemaVersion': 1,
    'snapshotKind': 'heading_foundation_diagnostic',
    'success': true,
    'sensorType': 'TYPE_ROTATION_VECTOR',
    'sensorName': 'Synthetic Rotation Vector',
    'requestedSamplingPeriodUs': 20000,
    'firstValidSampleTimeoutMs': 10000,
    'measurementWindowMs': 30000,
    'sensorTimestampAuthority': 'SensorEvent.timestamp',
    'wallClockUsedForSensorTiming': false,
    'declinationTimeSource': 'System.currentTimeMillis',
    'updateCount': 1502,
    'validHeadingSampleCount': 1500,
    'uniqueTimestampCount': 1499,
    'deltaCount': 1498,
    'nonMonotonicTimestampCount': 2,
    'duplicateTimestampCount': 1,
    'durationNanos': 29960000000,
    'minDeltaMs': 20.0,
    'maxDeltaMs': 20.0,
    'meanDeltaMs': 20.0,
    'medianDeltaMs': 20.0,
    'p95DeltaMs': 20.0,
    'observedSampleRateHz': 50.0,
    'firstMagneticHeadingRad': 1.0,
    'lastMagneticHeadingRad': 1.2,
    'firstTrueNorthCorrectedHeadingRad': 1.05,
    'lastTrueNorthCorrectedHeadingRad': 1.25,
    'cumulativeUnwrappedTrueHeadingDeltaRad': 0.2,
    'maxConsecutiveCircularDeltaRad': 0.02,
    'reportedHeadingAccuracyAvailable': true,
    'lastReportedHeadingAccuracyRad': 0.1,
    'declinationRadians': 0.05,
    'declinationProvider': 'android.hardware.GeomagneticField',
    'declinationModelVersion': 'platform_managed',
    'declinationModelFreshnessValidated': false,
    'declinationAltitudeSource': 'anchor_ellipsoid_altitude',
    'headingAccuracyValidated': false,
    'trueNorthAccuracyValidated': false,
    'bodyHeadingImplemented': false,
    'deviceForwardAxis': 'device_positive_y_top_edge',
    'headingConvention': 'clockwise_from_north_0_to_2pi',
  };
}
