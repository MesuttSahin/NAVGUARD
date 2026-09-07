import 'package:flutter_test/flutter_test.dart';
import 'package:navguard/navigation/gnss_anchor.dart';

void main() {
  group('GnssAnchor.fromPlatform', () {
    test('accepts a complete valid Stage 3A payload', () {
      final GnssAnchor anchor = GnssAnchor.fromPlatform(_validPayload());

      expect(anchor.provider, 'gps');
      expect(anchor.candidateCount, 5);
      expect(anchor.horizontalAccuracyReportedM, 8.5);
      expect(anchor.altitudeAvailable, isTrue);
      expect(
        anchor.selectionPolicy,
        'lowest_reported_horizontal_accuracy_then_newer_elapsed_realtime',
      );

      final Map<String, Object?> sanitized = anchor.sanitizedMetadata;
      expect(sanitized['coordinateAccuracyValidated'], isFalse);
      expect(sanitized.containsKey('latitudeDeg'), isFalse);
      expect(sanitized.containsKey('longitudeDeg'), isFalse);
      expect(sanitized.containsKey('altitudeEllipsoidM'), isFalse);
      expect(sanitized.containsKey('elapsedRealtimeNanos'), isFalse);
    });

    test('accepts a valid anchor without altitude', () {
      final Map<Object?, Object?> payload = _validPayload()
        ..['altitudeEllipsoidM'] = null
        ..['verticalAccuracyReportedM'] = null
        ..['selectedReportedVerticalAccuracyM'] = null
        ..['altitudeAvailable'] = false;

      final GnssAnchor anchor = GnssAnchor.fromPlatform(payload);

      expect(anchor.altitudeAvailable, isFalse);
      expect(anchor.altitudeEllipsoidM, isNull);
      expect(anchor.verticalAccuracyReportedM, isNull);
    });

    test('rejects a wrong schema version', () {
      final Map<Object?, Object?> payload = _validPayload()
        ..['schemaVersion'] = 2;

      expect(() => GnssAnchor.fromPlatform(payload), throwsFormatException);
    });

    test('rejects a wrong snapshot kind', () {
      final Map<Object?, Object?> payload = _validPayload()
        ..['snapshotKind'] = 'unexpected_snapshot';

      expect(() => GnssAnchor.fromPlatform(payload), throwsFormatException);
    });

    test('rejects success other than true', () {
      final Map<Object?, Object?> payload = _validPayload()
        ..['success'] = false;

      expect(() => GnssAnchor.fromPlatform(payload), throwsFormatException);
    });

    test('rejects a non-GPS provider', () {
      final Map<Object?, Object?> payload = _validPayload()
        ..['provider'] = 'network';

      expect(() => GnssAnchor.fromPlatform(payload), throwsFormatException);
    });

    test('rejects candidate count below three', () {
      final Map<Object?, Object?> payload = _validPayload()
        ..['candidateCount'] = 2;

      expect(() => GnssAnchor.fromPlatform(payload), throwsFormatException);
    });

    test('rejects the wrong minimum candidate contract', () {
      final Map<Object?, Object?> payload = _validPayload()
        ..['minimumValidCandidateCount'] = 4;

      expect(() => GnssAnchor.fromPlatform(payload), throwsFormatException);
    });

    test('rejects a wrong selection policy', () {
      final Map<Object?, Object?> payload = _validPayload()
        ..['selectionPolicy'] = 'coordinate_average';

      expect(() => GnssAnchor.fromPlatform(payload), throwsFormatException);
    });

    test('rejects a validated-coordinate-accuracy claim', () {
      final Map<Object?, Object?> payload = _validPayload()
        ..['coordinateAccuracyValidated'] = true;

      expect(() => GnssAnchor.fromPlatform(payload), throwsFormatException);
    });

    test('rejects a candidate not marked structurally valid', () {
      final Map<Object?, Object?> payload = _validPayload()
        ..['selectedCandidateStructurallyValid'] = false;

      expect(() => GnssAnchor.fromPlatform(payload), throwsFormatException);
    });

    test('rejects a candidate marked as mock', () {
      final Map<Object?, Object?> payload = _validPayload()
        ..['selectedCandidateMock'] = true;

      expect(() => GnssAnchor.fromPlatform(payload), throwsFormatException);
    });

    test('rejects a raw-candidate-list-returned contract violation', () {
      final Map<Object?, Object?> payload = _validPayload()
        ..['rawCandidateListReturned'] = true;

      expect(() => GnssAnchor.fromPlatform(payload), throwsFormatException);
    });

    test('rejects a wrong first-valid-fix timeout', () {
      final Map<Object?, Object?> payload = _validPayload()
        ..['firstValidFixTimeoutMs'] = 60000;

      expect(() => GnssAnchor.fromPlatform(payload), throwsFormatException);
    });

    test('rejects a wrong candidate-window duration', () {
      final Map<Object?, Object?> payload = _validPayload()
        ..['candidateCollectionWindowMs'] = 15000;

      expect(() => GnssAnchor.fromPlatform(payload), throwsFormatException);
    });

    test('rejects a non-positive elapsed-realtime timestamp', () {
      final Map<Object?, Object?> payload = _validPayload()
        ..['elapsedRealtimeNanos'] = 0;

      expect(() => GnssAnchor.fromPlatform(payload), throwsFormatException);
    });

    test('rejects invalid reported horizontal accuracy', () {
      final Map<Object?, Object?> payload = _validPayload()
        ..['horizontalAccuracyReportedM'] = 0.0
        ..['selectedReportedHorizontalAccuracyM'] = 0.0;

      expect(() => GnssAnchor.fromPlatform(payload), throwsFormatException);
    });

    test('rejects inconsistent horizontal-accuracy metadata', () {
      final Map<Object?, Object?> payload = _validPayload()
        ..['selectedReportedHorizontalAccuracyM'] = 9.5;

      expect(() => GnssAnchor.fromPlatform(payload), throwsFormatException);
    });

    test('rejects inconsistent altitude availability metadata', () {
      final Map<Object?, Object?> payload = _validPayload()
        ..['altitudeAvailable'] = false;

      expect(() => GnssAnchor.fromPlatform(payload), throwsFormatException);
    });
  });
}

Map<Object?, Object?> _validPayload() {
  return <Object?, Object?>{
    'schemaVersion': 1,
    'snapshotKind': 'gnss_anchor_acquisition_result',
    'success': true,
    'latitudeDeg': 12.25,
    'longitudeDeg': 34.75,
    'altitudeEllipsoidM': 125.0,
    'horizontalAccuracyReportedM': 8.5,
    'verticalAccuracyReportedM': 12.0,
    'selectedReportedHorizontalAccuracyM': 8.5,
    'selectedReportedVerticalAccuracyM': 12.0,
    'elapsedRealtimeNanos': 50000000000,
    'provider': 'gps',
    'candidateCount': 5,
    'selectionPolicy':
        'lowest_reported_horizontal_accuracy_then_newer_elapsed_realtime',
    'altitudeAvailable': true,
    'coordinateAccuracyValidated': false,
    'selectedCandidateStructurallyValid': true,
    'selectedCandidateMock': false,
    'firstValidFixTimeoutMs': 120000,
    'candidateCollectionWindowMs': 10000,
    'minimumValidCandidateCount': 3,
    'rawCandidateListReturned': false,
  };
}
