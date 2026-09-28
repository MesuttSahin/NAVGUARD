import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navguard/ai/navguard_ai.dart';
import 'package:navguard/ai/navguard_ai_dataset_screen.dart';
import 'package:navguard/demo/live_navguard_demo.dart';

class _FakeAiPlatform implements NavguardAiPlatform {
  _FakeAiPlatform({
    this.preflightOverrides = const <String, Object?>{},
    this.summaryOverrides = const <String, Object?>{},
    this.captureCompleter,
    this.startError,
    Map<String, Object?> initialCaptureStatus = const <String, Object?>{
      'phase': 'CAPTURE',
      'remainingSeconds': 20,
      'featureWindowCount': 2,
    },
  }) : captureStatus = Map<String, Object?>.from(initialCaptureStatus);

  final Map<String, Object?> preflightOverrides;
  final Map<String, Object?> summaryOverrides;
  final Completer<Map<String, Object?>>? captureCompleter;
  final PlatformException? startError;
  Map<String, Object?> captureStatus;
  Map<String, Object?>? startArguments;
  bool permissionsRequested = false;
  bool clearCalled = false;

  @override
  Future<Map<String, Object?>> cancelCapture() async => <String, Object?>{
    'phase': 'CANCELLED',
  };

  @override
  Future<Map<String, Object?>> clearDataset() async {
    clearCalled = true;
    return <String, Object?>{'datasetSessionCount': 0, 'featureRowCount': 0};
  }

  @override
  Future<Map<String, Object?>> getCaptureStatus() async => captureStatus;

  @override
  Future<Map<String, Object?>> getDatasetSummary() async => <String, Object?>{
    'datasetSessionCount': 2,
    'featureRowCount': 48,
    'datasetLocation': '/private/app/navguard_ai',
    ...summaryOverrides,
  };

  @override
  Future<Map<String, Object?>> getModelStatus() async => <String, Object?>{
    'status': 'MODEL_NOT_AVAILABLE',
    'modelAvailable': false,
    'configESelectable': false,
  };

  @override
  Future<Map<String, Object?>> getPreflight(
    Map<String, Object?> anchor,
  ) async => _readyCapturePreflight(<String, Object?>{
    'anchorAvailable': anchor['anchorAvailable'],
    ...preflightOverrides,
  });

  @override
  Future<Map<String, Object?>> requestCapturePermissions() async {
    permissionsRequested = true;
    return <String, Object?>{
      'requestOutcome': 'granted',
      'cameraPermissionGranted': true,
      'activityRecognitionPermissionGranted': true,
      'fineLocationPermissionGranted': true,
    };
  }

  @override
  Future<Map<String, Object?>> runDevelopmentBenchmark() async =>
      <String, Object?>{'executable': false};

  @override
  Future<Map<String, Object?>> startCapture(
    Map<String, Object?> arguments,
  ) async {
    startArguments = arguments;
    if (startError case final PlatformException error) throw error;
    if (captureCompleter case final Completer<Map<String, Object?>> completer) {
      return completer.future;
    }
    return <String, Object?>{
      'featureWindowCount': 24,
      'stepEventsReceived': 18,
      'stepEventsFormalWindow': 18,
      'stepEventsDeliveredDuringFinalDrain': 3,
      'stepEventsAppliedToFeatures': 18,
      'stepEventsExcludedPostWindow': 0,
      'stepEventsDuplicateRejected': 0,
      'stepEventsOutOfHistoryRejected': 0,
      'callbackLatencyMeanMs': 6500.0,
      'callbackLatencyMaxMs': 10600.0,
      'featureWindowsWithSteps': 20,
      'featureWindowsWithoutSteps': 4,
    };
  }
}

Map<String, Object?> _readyCapturePreflight([
  Map<String, Object?> overrides = const <String, Object?>{},
]) => <String, Object?>{
  'schemaVersion': navguardAiDatasetSchema,
  'featureSchemaVersion': navguardAiFeatureSchema,
  'featureCount': navguardAiFeatureOrder.length,
  'accelerometerAvailable': true,
  'gyroscopeAvailable': true,
  'rotationVectorAvailable': true,
  'stepDetectorAvailable': true,
  'arCoreSupported': true,
  'arCoreInstalled': true,
  'cameraPermissionGranted': true,
  'activityRecognitionPermissionGranted': true,
  'fineLocationPermissionGranted': true,
  'gpsProviderAvailable': true,
  'gpsProviderEnabled': true,
  'anchorAvailable': true,
  'operationAvailable': true,
  'nativeSelfTests': const <String, bool>{
    'liveInferenceHopInfrastructure': true,
  },
  'nativeSelfTestsPassed': true,
  'failedNativeSelfTests': const <String>[],
  'nativeSelfTestFailures': const <Map<String, String>>[],
  'selfTestsPassed': true,
  'captureReady': true,
  'nativeReady': true,
  'blockingReasons': const <String>[],
  'modelStatus': 'MODEL_NOT_AVAILABLE',
  'modelAvailable': false,
  ...overrides,
};

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  final Finder scrollable = find.byType(Scrollable).last;
  tester.state<ScrollableState>(scrollable).position.jumpTo(0);
  await tester.pump();
  await tester.scrollUntilVisible(finder, 180, scrollable: scrollable);
  await Scrollable.ensureVisible(
    tester.element(finder),
    alignment: 0.5,
    duration: Duration.zero,
  );
  await tester.pump(const Duration(milliseconds: 20));
}

void main() {
  test('preserves V1/V2 and freezes the exact 40-feature V3 schema', () {
    expect(navguardAiFeatureSchemaV1, 'navguard_ai_features_v1');
    expect(navguardAiDatasetSchemaV1, 'navguard_ai_dataset_v1');
    expect(navguardAiFeatureOrderV1, hasLength(26));
    expect(navguardAiFeatureSchemaV2, 'navguard_ai_features_v2');
    expect(navguardAiDatasetSchemaV2, 'navguard_ai_dataset_v2');
    expect(navguardAiFeatureOrderV2, hasLength(34));
    expect(navguardAiFeatureOrderV2.take(26), navguardAiFeatureOrderV1);
    expect(navguardAiFeatureSchema, 'navguard_ai_features_v3');
    expect(navguardAiDatasetSchema, 'navguard_ai_dataset_v3');
    expect(navguardAiFeatureOrder, hasLength(40));
    expect(navguardAiFeatureOrder.take(34), navguardAiFeatureOrderV2);
    expect(navguardAiFeatureOrder.skip(34), <String>[
      'heading_signed_net_turn_rad',
      'arcore_signed_net_turn_rad',
      'heading_path_turn_direction_agreement',
      'heading_path_turn_magnitude_difference_ratio',
      'heading_path_turn_coherence',
      'arcore_cross_track_rms_m',
    ]);
    expect(navguardAiFeatureOrder.first, 'accel_mag_mean');
    expect(navguardAiFeatureOrder.last, 'arcore_cross_track_rms_m');
    expect(navguardAiDatasetColumnsArePrivate(navguardAiFeatureOrder), isTrue);
    expect(navguardAiDatasetColumnsArePrivate(<String>['latitude']), isFalse);
  });

  test('keeps the reliability multiplier bounded', () {
    expect(navguardAiReliabilityMultiplier(1), 1);
    expect(navguardAiReliabilityMultiplier(0), 2.5);
    expect(navguardAiReliabilityMultiplier(-10), 2.5);
    expect(navguardAiReliabilityMultiplier(10), 1);
    expect(navguardAiReliabilityMultiplier(double.nan), 1);
  });

  test('uses exact human motion labels and instructions', () {
    expect(
      NavguardAiMotionLabel.values.map((value) => value.platformName),
      <String>['STATIONARY', 'STRAIGHT_WALK', 'TURNING', 'UNSTABLE_MOTION'],
    );
    expect(
      NavguardAiMotionLabel.turning.instruction,
      contains('repeated controlled turns'),
    );
    expect(
      NavguardAiMotionLabel.unstableMotion.instruction,
      contains('Do not shake the phone violently'),
    );
  });

  test('live preflight defaults to the safe missing-model state', () {
    final LiveNavguardPreflight value =
        LiveNavguardPreflight.fromMap(<Object?, Object?>{
          'schemaVersion': 1,
          'gpsProviderAvailable': true,
          'gpsProviderEnabled': true,
          'fineLocationPermissionGranted': true,
          'rotationVectorAvailable': true,
          'stepDetectorAvailable': true,
          'activityRecognitionPermissionGranted': true,
          'arCoreSupported': true,
          'arCoreInstalled': true,
          'cameraPermissionGranted': true,
          'anchorAvailable': true,
          'nativeReady': true,
          'demoRunning': false,
          'aiModelStatus': 'MODEL_NOT_AVAILABLE',
          'aiModelAvailable': false,
          'aiConfigESelectable': false,
        });
    expect(value.aiModelStatus, 'MODEL_NOT_AVAILABLE');
    expect(value.aiModelAvailable, isFalse);
    expect(value.aiConfigESelectable, isFalse);
    expect(
      LiveFusionMode.values.map((LiveFusionMode mode) => mode.wireName),
      contains(navguardAiConfigEId),
    );
  });

  test('missing model does not block an otherwise ready capture', () {
    final NavguardAiCapturePreflight value = NavguardAiCapturePreflight.fromMap(
      _readyCapturePreflight(),
    );
    expect(value.captureReady, isTrue);
    expect(value.blockingReasons, isEmpty);
  });

  test('anchor absence blocks capture with the exact reason', () {
    final NavguardAiCapturePreflight value = NavguardAiCapturePreflight.fromMap(
      _readyCapturePreflight(<String, Object?>{
        'anchorAvailable': false,
        'captureReady': false,
        'nativeReady': false,
        'blockingReasons': const <String>['ANCHOR_UNAVAILABLE'],
      }),
    );
    expect(value.captureReady, isFalse);
    expect(value.blockingReasons, <String>['ANCHOR_UNAVAILABLE']);
  });

  test('activity permission absence blocks capture with the exact reason', () {
    final NavguardAiCapturePreflight value = NavguardAiCapturePreflight.fromMap(
      _readyCapturePreflight(<String, Object?>{
        'activityRecognitionPermissionGranted': false,
        'captureReady': false,
        'nativeReady': false,
        'blockingReasons': const <String>[
          'ACTIVITY_RECOGNITION_PERMISSION_MISSING',
        ],
      }),
    );
    expect(value.captureReady, isFalse);
    expect(value.blockingReasons, <String>[
      'ACTIVITY_RECOGNITION_PERMISSION_MISSING',
    ]);
  });

  test('ARCore absence blocks capture with the exact reason', () {
    final NavguardAiCapturePreflight value = NavguardAiCapturePreflight.fromMap(
      _readyCapturePreflight(<String, Object?>{
        'arCoreSupported': false,
        'arCoreInstalled': false,
        'captureReady': false,
        'nativeReady': false,
        'blockingReasons': const <String>['ARCORE_UNSUPPORTED'],
      }),
    );
    expect(value.captureReady, isFalse);
    expect(value.blockingReasons, <String>['ARCORE_UNSUPPORTED']);
  });

  test('busy operation slot blocks capture with the exact reason', () {
    final NavguardAiCapturePreflight value = NavguardAiCapturePreflight.fromMap(
      _readyCapturePreflight(<String, Object?>{
        'operationAvailable': false,
        'captureReady': false,
        'nativeReady': false,
        'blockingReasons': const <String>['OPERATION_BUSY'],
      }),
    );
    expect(value.captureReady, isFalse);
    expect(value.blockingReasons, <String>['OPERATION_BUSY']);
  });

  test('propagates an exact sanitized native self-test failure', () {
    final NavguardAiCapturePreflight value = NavguardAiCapturePreflight.fromMap(
      _readyCapturePreflight(<String, Object?>{
        'nativeSelfTests': const <String, bool>{
          'liveInferenceHopInfrastructure': false,
        },
        'nativeSelfTestsPassed': false,
        'selfTestsPassed': false,
        'failedNativeSelfTests': const <String>[
          'liveInferenceHopInfrastructure',
        ],
        'nativeSelfTestFailures': const <Map<String, String>>[
          <String, String>{
            'test': 'liveInferenceHopInfrastructure',
            'expected': 'finite probabilities and status = AI_ACTIVE',
            'actual': 'motionConfidence=0.538000, status=HEURISTIC_FALLBACK',
            'reason': 'LIVE_INFERENCE_STATUS_NOT_ACTIVE',
          },
        ],
        'captureReady': false,
        'nativeReady': false,
        'blockingReasons': const <String>['NATIVE_SELF_TEST_FAILED'],
      }),
    );

    expect(value.captureReady, isFalse);
    expect(value.nativeSelfTests['liveInferenceHopInfrastructure'], isFalse);
    expect(value.failedNativeSelfTests, <String>[
      'liveInferenceHopInfrastructure',
    ]);
    expect(
      value.nativeSelfTestFailures.single.reason,
      'LIVE_INFERENCE_STATUS_NOT_ACTIVE',
    );
    expect(value.blockingReasons, <String>['NATIVE_SELF_TEST_FAILED']);
  });

  testWidgets('renders the polished dataset workflow and real saved result', (
    WidgetTester tester,
  ) async {
    final _FakeAiPlatform platform = _FakeAiPlatform();
    await tester.pumpWidget(
      MaterialApp(
        home: NavguardAiDatasetScreen(
          anchorLatitudeDeg: 41,
          anchorLongitudeDeg: 29,
          anchorAltitudeEllipsoidM: 10,
          platform: platform,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('NAVGUARD AI Dataset'), findsOneWidget);
    expect(find.text('V3 · Motion Dataset'), findsOneWidget);
    expect(find.text('40 Features'), findsOneWidget);
    expect(find.text('4 Motion Classes'), findsOneWidget);
    expect(find.text('Local Only'), findsOneWidget);
    expect(find.text('READY'), findsOneWidget);
    expect(find.text('Blocking reason: NONE'), findsOneWidget);
    expect(find.byKey(const Key('ai-motion-selector')), findsOneWidget);
    for (final String label in <String>[
      'Stationary',
      'Straight Walk',
      'Turning',
      'Unstable Motion',
    ]) {
      expect(find.text(label), findsOneWidget);
    }

    await _reveal(tester, find.byKey(const Key('ai-start-capture')));
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('ai-start-capture')))
          .onPressed,
      isNotNull,
    );

    await tester.tap(find.byKey(const Key('ai-start-capture')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pump();

    expect(platform.startArguments?['motionLabel'], 'STATIONARY');
    expect(platform.startArguments?['durationSeconds'], 25);
    expect(platform.startArguments?['latitudeDeg'], 41);
    expect(find.text('SESSION SAVED'), findsOneWidget);
    expect(find.text('24 windows saved locally'), findsOneWidget);

    await _reveal(tester, find.byKey(const Key('ai-step-diagnostics')));
    await _reveal(
      tester,
      find.byKey(const Key('ai-capture-diagnostics-toggle')),
    );
    await tester.tap(find.byKey(const Key('ai-capture-diagnostics-toggle')));
    await tester.pump();
    expect(find.text('Steps applied to features'), findsOneWidget);
    expect(find.text('Windows with / without steps'), findsOneWidget);
    expect(find.text('20 / 4'), findsOneWidget);
  });

  testWidgets('shows the permission blocker and requests runtime permissions', (
    WidgetTester tester,
  ) async {
    final _FakeAiPlatform platform = _FakeAiPlatform(
      preflightOverrides: const <String, Object?>{
        'activityRecognitionPermissionGranted': false,
        'captureReady': false,
        'nativeReady': false,
        'blockingReasons': <String>['ACTIVITY_RECOGNITION_PERMISSION_MISSING'],
      },
    );
    await tester.pumpWidget(
      MaterialApp(
        home: NavguardAiDatasetScreen(
          anchorLatitudeDeg: 41,
          anchorLongitudeDeg: 29,
          anchorAltitudeEllipsoidM: 10,
          platform: platform,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ACTION REQUIRED'), findsOneWidget);
    expect(
      find.text('Blocking reason: ACTIVITY_RECOGNITION_PERMISSION_MISSING'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('ai-request-capture-permissions')),
      findsOneWidget,
    );

    await _reveal(tester, find.byKey(const Key('ai-start-capture')));
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('ai-start-capture')))
          .onPressed,
      isNull,
    );

    await _reveal(
      tester,
      find.byKey(const Key('ai-request-capture-permissions')),
    );
    await tester.tap(find.byKey(const Key('ai-request-capture-permissions')));
    await tester.pumpAndSettle();
    expect(platform.permissionsRequested, isTrue);
  });

  testWidgets('shows the exact sanitized native self-test failure', (
    WidgetTester tester,
  ) async {
    final _FakeAiPlatform platform = _FakeAiPlatform(
      preflightOverrides: const <String, Object?>{
        'nativeSelfTests': <String, bool>{
          'liveInferenceHopInfrastructure': false,
        },
        'nativeSelfTestsPassed': false,
        'selfTestsPassed': false,
        'failedNativeSelfTests': <String>['liveInferenceHopInfrastructure'],
        'nativeSelfTestFailures': <Map<String, String>>[
          <String, String>{
            'test': 'liveInferenceHopInfrastructure',
            'expected': 'finite probabilities and status = AI_ACTIVE',
            'actual': 'motionConfidence=0.538000, status=HEURISTIC_FALLBACK',
            'reason': 'LIVE_INFERENCE_STATUS_NOT_ACTIVE',
          },
        ],
        'captureReady': false,
        'nativeReady': false,
        'blockingReasons': <String>['NATIVE_SELF_TEST_FAILED'],
      },
    );
    await tester.pumpWidget(
      MaterialApp(
        home: NavguardAiDatasetScreen(
          anchorLatitudeDeg: 41,
          anchorLongitudeDeg: 29,
          anchorAltitudeEllipsoidM: 10,
          platform: platform,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Failed self-test: liveInferenceHopInfrastructure'),
      findsOneWidget,
    );
    expect(
      find.text('Self-test reason: LIVE_INFERENCE_STATUS_NOT_ACTIVE'),
      findsOneWidget,
    );
    expect(
      find.text('Blocking reason: NATIVE_SELF_TEST_FAILED'),
      findsOneWidget,
    );
  });

  testWidgets('maps every visible motion class to the exact native label', (
    WidgetTester tester,
  ) async {
    final _FakeAiPlatform platform = _FakeAiPlatform();
    await tester.pumpWidget(
      MaterialApp(
        home: NavguardAiDatasetScreen(
          anchorLatitudeDeg: 41,
          anchorLongitudeDeg: 29,
          anchorAltitudeEllipsoidM: 10,
          platform: platform,
        ),
      ),
    );
    await tester.pumpAndSettle();

    const Map<String, String> expected = <String, String>{
      'STATIONARY': 'Stationary',
      'STRAIGHT_WALK': 'Straight Walk',
      'TURNING': 'Turning',
      'UNSTABLE_MOTION': 'Unstable Motion',
    };
    for (final MapEntry<String, String> entry in expected.entries) {
      final Finder tile = find.byKey(Key('ai-motion-${entry.key}'));
      await _reveal(tester, tile);
      await tester.tap(tile);
      await tester.pump();

      final Finder start = find.byKey(const Key('ai-start-capture'));
      await _reveal(tester, start);
      await tester.tap(start);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));
      await tester.pump();

      expect(platform.startArguments?['motionLabel'], entry.key);
      expect(find.text(entry.value), findsWidgets);
    }
  });

  testWidgets('presents actual countdown capture drain and completion phases', (
    WidgetTester tester,
  ) async {
    final Completer<Map<String, Object?>> capture =
        Completer<Map<String, Object?>>();
    final _FakeAiPlatform platform = _FakeAiPlatform(
      captureCompleter: capture,
      initialCaptureStatus: const <String, Object?>{
        'phase': 'CAPTURE',
        'remainingSeconds': 18,
        'featureWindowCount': 5,
      },
    );
    await tester.pumpWidget(
      MaterialApp(
        home: NavguardAiDatasetScreen(
          anchorLatitudeDeg: 41,
          anchorLongitudeDeg: 29,
          anchorAltitudeEllipsoidM: 10,
          platform: platform,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _reveal(tester, find.byKey(const Key('ai-start-capture')));
    await tester.tap(find.byKey(const Key('ai-start-capture')));
    await tester.pump();
    expect(find.text('GET READY'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 550));
    await tester.pump();
    expect(find.text('CAPTURING'), findsOneWidget);
    expect(find.text('18 s remaining'), findsOneWidget);

    platform.captureStatus = const <String, Object?>{
      'phase': 'FINAL_DRAIN',
      'remainingSeconds': 8,
      'featureWindowCount': 24,
    };
    await tester.pump(const Duration(milliseconds: 550));
    await tester.pump();
    expect(find.text('FINAL PROCESSING'), findsOneWidget);
    expect(find.text('8 s remaining'), findsOneWidget);
    expect(find.text('Processing delayed step events'), findsOneWidget);

    capture.complete(<String, Object?>{
      'featureWindowCount': 24,
      'stepEventsAppliedToFeatures': 12,
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pump();
    expect(find.text('SESSION SAVED'), findsOneWidget);
    expect(find.text('24 windows saved locally'), findsOneWidget);
  });

  testWidgets('shows a concise capture failure state', (
    WidgetTester tester,
  ) async {
    final _FakeAiPlatform platform = _FakeAiPlatform(
      startError: PlatformException(code: 'CAPTURE_FAILED'),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: NavguardAiDatasetScreen(
          anchorLatitudeDeg: 41,
          anchorLongitudeDeg: 29,
          anchorAltitudeEllipsoidM: 10,
          platform: platform,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _reveal(tester, find.byKey(const Key('ai-start-capture')));
    await tester.tap(find.byKey(const Key('ai-start-capture')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pump();

    expect(find.text('CAPTURE FAILED'), findsOneWidget);
    expect(find.text('Capture was not saved'), findsOneWidget);
    await _reveal(tester, find.byKey(const Key('ai-message')));
    expect(find.text('Capture failed (CAPTURE_FAILED).'), findsOneWidget);
  });

  testWidgets('shows local totals and clears only after confirmation', (
    WidgetTester tester,
  ) async {
    final _FakeAiPlatform platform = _FakeAiPlatform();
    await tester.pumpWidget(
      MaterialApp(
        home: NavguardAiDatasetScreen(
          anchorLatitudeDeg: 41,
          anchorLongitudeDeg: 29,
          anchorAltitudeEllipsoidM: 10,
          platform: platform,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _reveal(tester, find.byKey(const Key('ai-local-dataset-card')));
    expect(
      find.descendant(
        of: find.byKey(const Key('ai-dataset-sessions')),
        matching: find.text('2'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('ai-dataset-windows')),
        matching: find.text('48'),
      ),
      findsOneWidget,
    );

    await _reveal(tester, find.byKey(const Key('ai-clear-dataset')));
    await tester.tap(find.byKey(const Key('ai-clear-dataset')));
    await tester.pumpAndSettle();
    expect(find.text('Clear local AI dataset?'), findsOneWidget);
    expect(
      find.textContaining('all locally captured AI dataset CSV files'),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(platform.clearCalled, isFalse);

    await _reveal(tester, find.byKey(const Key('ai-clear-dataset')));
    await tester.tap(find.byKey(const Key('ai-clear-dataset')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ai-confirm-clear')));
    await tester.pumpAndSettle();
    expect(platform.clearCalled, isTrue);
    expect(
      find.text('No local sessions yet. Start a capture to add V3 windows.'),
      findsOneWidget,
    );
  });

  testWidgets('keeps technical details collapsed and hides paths', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NavguardAiDatasetScreen(
          anchorLatitudeDeg: 41,
          anchorLongitudeDeg: 29,
          anchorAltitudeEllipsoidM: 10,
          platform: _FakeAiPlatform(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _reveal(tester, find.byKey(const Key('ai-dataset-details-card')));
    expect(find.text(navguardAiDatasetSchema), findsNothing);
    expect(find.text('/private/app/navguard_ai'), findsNothing);
    expect(find.text('Export Dataset / Show Dataset Location'), findsNothing);

    await _reveal(tester, find.byKey(const Key('ai-dataset-details-toggle')));
    await tester.tap(find.byKey(const Key('ai-dataset-details-toggle')));
    await tester.pumpAndSettle();
    expect(find.text(navguardAiDatasetSchema), findsOneWidget);
    expect(find.text(navguardAiFeatureSchema), findsOneWidget);
    expect(find.text('2000 ms'), findsOneWidget);
    expect(find.text('1000 ms'), findsOneWidget);
    expect(find.text('25 s'), findsWidgets);
    expect(find.text('12 s'), findsWidgets);
    expect(find.text('24'), findsOneWidget);
    expect(find.text('Enabled'), findsOneWidget);
    expect(find.text('Runtime model: MODEL_NOT_AVAILABLE'), findsOneWidget);
    expect(find.text('Config E selectable: No'), findsOneWidget);

    await _reveal(tester, find.byKey(const Key('ai-privacy-notice')));
    expect(find.text('No coordinates'), findsOneWidget);
    expect(find.text('No camera frames'), findsOneWidget);
    expect(find.text('No raw sensor streams'), findsOneWidget);
    expect(find.text('No telemetry'), findsOneWidget);
  });

  testWidgets('empty dataset disables destructive clear action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NavguardAiDatasetScreen(
          anchorLatitudeDeg: 41,
          anchorLongitudeDeg: 29,
          anchorAltitudeEllipsoidM: 10,
          platform: _FakeAiPlatform(
            summaryOverrides: const <String, Object?>{
              'datasetSessionCount': 0,
              'featureRowCount': 0,
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _reveal(tester, find.byKey(const Key('ai-local-dataset-card')));

    expect(
      find.text('No local sessions yet. Start a capture to add V3 windows.'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<OutlinedButton>(find.byKey(const Key('ai-clear-dataset')))
          .onPressed,
      isNull,
    );
  });

  for (final Size size in <Size>[
    const Size(360, 800),
    const Size(393, 873),
    const Size(412, 915),
    const Size(430, 932),
  ]) {
    testWidgets('AI Dataset has no overflow at ${size.width.toInt()} dp', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
          home: NavguardAiDatasetScreen(
            anchorLatitudeDeg: 41,
            anchorLongitudeDeg: 29,
            anchorAltitudeEllipsoidM: 10,
            platform: _FakeAiPlatform(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      for (final Key key in <Key>[
        const Key('ai-dataset-overview'),
        const Key('ai-preflight-details'),
        const Key('ai-motion-selector'),
        const Key('ai-capture-card'),
        const Key('ai-local-dataset-card'),
        const Key('ai-dataset-details-card'),
        const Key('ai-privacy-notice'),
      ]) {
        await _reveal(tester, find.byKey(key));
        expect(
          tester.takeException(),
          isNull,
          reason: 'Unexpected overflow while showing $key',
        );
      }
    });
  }
}
