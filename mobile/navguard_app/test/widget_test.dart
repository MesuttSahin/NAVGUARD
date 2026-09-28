import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navguard/ai/navguard_ai.dart';
import 'package:navguard/demo/live_navguard_demo.dart';
import 'package:navguard/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows the polished NAVGUARD home dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      NavguardApp(
        liveDemoPlatform: _WidgetFakeLivePlatform(),
        aiPlatform: _WidgetFakeAiPlatform(),
        enableLiveMapTiles: false,
      ),
    );

    expect(find.byKey(const Key('navguard-hero')), findsOneWidget);
    expect(find.text('NAVGUARD'), findsOneWidget);
    expect(find.text('AI-Assisted GNSS-Denied Navigation'), findsOneWidget);
    expect(find.text('Research Prototype'), findsNWidgets(2));
    expect(find.text('System Readiness'), findsOneWidget);
    expect(find.text('GNSS'), findsOneWidget);
    expect(find.text('Sensors'), findsWidgets);
    expect(find.text('ARCore'), findsOneWidget);
    expect(find.text('AI Model'), findsOneWidget);
    expect(find.text('GNSS Anchor'), findsOneWidget);
    expect(find.text('Not checked'), findsNWidgets(4));
    expect(find.text('Not locked'), findsOneWidget);
    expect(find.text('Refresh System Status'), findsOneWidget);

    expect(find.text('Live Navigation'), findsOneWidget);
    expect(find.text('V1'), findsOneWidget);
    expect(find.text('V2 Adaptive'), findsOneWidget);
    expect(find.text('V3 · AI'), findsOneWidget);
    expect(find.text('Open Live Map'), findsOneWidget);
    expect(
      find.text('Real-time navigation through GNSS denial and recovery.'),
      findsOneWidget,
    );
    expect(
      find.text('Run the real-time GNSS → denial → NAVGUARD → recovery flow.'),
      findsNothing,
    );

    expect(find.text('Research Modules'), findsOneWidget);
    for (final String title in <String>[
      'Sensors',
      'GNSS & Anchor',
      'Heading & PDR',
      'ARCore & ENU',
      'Fusion & EKF',
      'Denial & Recovery',
      'Evaluation & GTF',
      'Benchmarks',
      'Accuracy v2',
    ]) {
      expect(
        find.text(title),
        title == 'Sensors' ? findsWidgets : findsOneWidget,
      );
    }

    expect(find.text('AI Research'), findsOneWidget);
    expect(find.text('V3 · Experimental AI'), findsOneWidget);
    expect(find.text('40 features'), findsOneWidget);
    expect(find.text('4 motion classes'), findsOneWidget);
    expect(find.text('On-device inference'), findsOneWidget);
    expect(find.text('AI Dataset & Diagnostics'), findsOneWidget);

    expect(find.text('Research Status'), findsOneWidget);
    expect(find.text('Software-defined denial'), findsOneWidget);
    expect(find.text('Ground Truth Firewall'), findsOneWidget);
    expect(find.text('On-device AI'), findsOneWidget);
    expect(
      find.text('Navigation accuracy is not independently validated.'),
      findsOneWidget,
    );
  });

  testWidgets('each research module reaches its existing diagnostics', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      NavguardApp(
        liveDemoPlatform: _WidgetFakeLivePlatform(),
        aiPlatform: _WidgetFakeAiPlatform(),
        enableLiveMapTiles: false,
      ),
    );

    const Map<String, List<String>> expectations = <String, List<String>>{
      'sensors': <String>['Sensor Capability', 'Live Sensor Timing Diagnostic'],
      'gnssAnchor': <String>[
        'GNSS Runtime Timing Diagnostic',
        'GNSS Anchor / Local Reference',
      ],
      'headingPdr': <String>[
        'Heading Foundation',
        'Step Detection',
        'Baseline PDR',
      ],
      'arCoreEnu': <String>[
        'ARCore Readiness',
        'Visual-Inertial Tracking',
        'ARCore → ENU',
      ],
      'fusionEkf': <String>[
        'Fusion Readiness',
        'Estimator State',
        'Quality & Uncertainty',
      ],
      'denialRecovery': <String>[
        'Navigation State',
        'GNSS Denial & Ground Truth Firewall',
        'GNSS Recovery',
      ],
      'evaluationGtf': <String>[
        'Evaluation Readiness',
        'Protected Reference Isolation',
        'Evaluation Result',
      ],
      'benchmarks': <String>[
        'Benchmark Readiness',
        'Config A/B/C/D',
        'Protected-Reference Comparison',
      ],
      'accuracyV2': <String>[
        'Adaptive Runtime Readiness',
        'Adaptive Profile',
        'Matched A / D-v1 / D-v2 Comparison',
      ],
    };

    for (final MapEntry<String, List<String>> entry in expectations.entries) {
      final Finder card = find.byKey(Key('module-card-${entry.key}'));
      await tester.ensureVisible(card);
      await tester.tap(card);
      await tester.pumpAndSettle();

      for (final String expected in entry.value) {
        expect(find.text(expected, skipOffstage: false), findsOneWidget);
      }
      if (entry.key == 'sensors') {
        expect(find.text('Diagnostic Output'), findsNothing);
        expect(find.text('Refresh Sensor Inventory'), findsOneWidget);
        expect(find.text('Run Sensor Timing Test'), findsOneWidget);
      } else if (entry.key == 'gnssAnchor') {
        expect(find.text('Diagnostic Output'), findsNothing);
        expect(find.text('Refresh GNSS Readiness'), findsOneWidget);
        expect(find.text('Acquire GNSS Anchor'), findsOneWidget);
      } else if (entry.key == 'headingPdr') {
        expect(find.text('Diagnostic Output'), findsNothing);
        expect(find.text('Refresh Heading Readiness'), findsOneWidget);
        expect(find.text('Run Baseline PDR'), findsOneWidget);
      } else if (entry.key == 'arCoreEnu') {
        expect(find.text('Diagnostic Output'), findsNothing);
        expect(find.text('Refresh ARCore Readiness'), findsOneWidget);
        expect(find.text('Run ARCore → ENU Diagnostic'), findsOneWidget);
      } else if (entry.key == 'fusionEkf') {
        expect(find.text('Diagnostic Output'), findsNothing);
        expect(find.text('Refresh Fusion Readiness'), findsOneWidget);
        expect(find.text('Run Fusion Diagnostic'), findsOneWidget);
      } else if (entry.key == 'denialRecovery') {
        expect(find.text('Diagnostic Output'), findsNothing);
        expect(find.text('Refresh Full-Flow Readiness'), findsOneWidget);
        expect(find.text('Run Denial & Recovery Diagnostic'), findsOneWidget);
      } else if (entry.key == 'evaluationGtf') {
        expect(find.text('Diagnostic Output'), findsNothing);
        expect(find.text('Refresh Evaluation Readiness'), findsOneWidget);
        expect(find.text('Run Evaluation Mode'), findsOneWidget);
      } else if (entry.key == 'benchmarks') {
        expect(find.text('Diagnostic Output'), findsNothing);
        expect(find.text('Refresh Benchmark Readiness'), findsOneWidget);
        expect(find.text('Run Matched A/B/C/D Benchmark'), findsOneWidget);
      } else if (entry.key == 'accuracyV2') {
        expect(find.text('Diagnostic Output'), findsNothing);
        expect(find.text('Refresh Accuracy v2 Readiness'), findsOneWidget);
        expect(find.text('Run Development Benchmark'), findsOneWidget);
      } else {
        expect(find.text('Diagnostic Output'), findsOneWidget);
      }

      await tester.tap(find.byKey(const Key('diagnostic-back-button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('navguard-hero')), findsOneWidget);
    }
  });

  testWidgets(
    'Sensors diagnostic preserves native methods and presents structured results',
    (WidgetTester tester) async {
      final TestDefaultBinaryMessenger messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      const MethodChannel sensorChannel = MethodChannel(
        'io.github.mesuttsahin.navguard/sensor_diagnostics',
      );
      int inventoryCalls = 0;
      int timingCalls = 0;

      messenger.setMockMethodCallHandler(sensorChannel, (
        MethodCall call,
      ) async {
        switch (call.method) {
          case 'getSensorCapabilityInventory':
            inventoryCalls++;
            return <String, Object?>{
              'schemaVersion': 1,
              'snapshotKind': 'sensor_capability_inventory',
              'capabilityMetadataOnly': true,
              'sensors': <Map<String, Object?>>[
                <String, Object?>{
                  'requestedType': 'TYPE_ACCELEROMETER',
                  'platformApiSupported': true,
                  'available': true,
                  'name': 'Test Accelerometer',
                  'vendor': 'NAVGUARD Test',
                  'resolution': 0.01,
                  'minDelayUs': 5000,
                  'power': 0.2,
                },
                <String, Object?>{
                  'requestedType': 'TYPE_GYROSCOPE',
                  'platformApiSupported': true,
                  'available': true,
                  'name': 'Test Gyroscope',
                },
                <String, Object?>{
                  'requestedType': 'TYPE_ROTATION_VECTOR',
                  'platformApiSupported': true,
                  'available': true,
                  'name': 'Test Rotation Vector',
                },
                <String, Object?>{
                  'requestedType': 'TYPE_STEP_DETECTOR',
                  'platformApiSupported': true,
                  'available': true,
                  'name': 'Test Step Detector',
                },
                <String, Object?>{
                  'requestedType': 'TYPE_PRESSURE',
                  'platformApiSupported': true,
                  'available': false,
                },
              ],
            };
          case 'runSensorTimingDiagnostic':
            timingCalls++;
            expect(call.arguments, <String, Object?>{
              'sensorKey': 'accelerometer',
            });
            return <String, Object?>{
              'schemaVersion': 1,
              'snapshotKind': 'sensor_event_timing_diagnostic',
              'status': 'completed',
              'validTimingSummary': true,
              'sensor': <String, Object?>{
                'requestedType': 'TYPE_ACCELEROMETER',
                'name': 'Test Accelerometer',
                'vendor': 'NAVGUARD Test',
              },
              'requestedNominalRateHz': 50.0,
              'meanDeliveredHz': 50.0,
              'eventCount': 501,
              'meanDeltaNs': 20000000.0,
              'p95DeltaNs': 22000000,
              'maxDeltaNs': 25000000,
              'nonMonotonicTimestampCount': 0,
            };
          default:
            fail('Unexpected sensor method: ${call.method}');
        }
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(sensorChannel, null),
      );

      await tester.pumpWidget(
        NavguardApp(
          liveDemoPlatform: _WidgetFakeLivePlatform(),
          aiPlatform: _WidgetFakeAiPlatform(),
          enableLiveMapTiles: false,
        ),
      );

      final Finder sensorModule = find.byKey(const Key('module-card-sensors'));
      await tester.ensureVisible(sensorModule);
      await tester.tap(sensorModule);
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Device capability inventory and live sensor timing diagnostics.',
        ),
        findsOneWidget,
      );
      expect(find.text('Not checked'), findsOneWidget);
      expect(find.text('Sensor Capability'), findsOneWidget);
      expect(find.text('Timing not measured'), findsOneWidget);

      await tester.tap(find.byKey(const Key('sensor-inventory-action')));
      await tester.pumpAndSettle();

      expect(inventoryCalls, 1);
      expect(find.text('4 available'), findsOneWidget);
      expect(find.text('1 unavailable'), findsOneWidget);
      expect(find.text('Test Accelerometer'), findsOneWidget);
      expect(find.text('Unavailable'), findsOneWidget);

      final Finder timingAction = find.byKey(const Key('sensor-timing-action'));
      await tester.ensureVisible(timingAction);
      await tester.tap(timingAction);
      await tester.pumpAndSettle();

      expect(timingCalls, 1);
      expect(find.text('Timing summary completed'), findsOneWidget);
      final Finder timingMetrics = find.byKey(
        const Key('sensor-timing-metrics'),
      );
      expect(timingMetrics, findsOneWidget);
      await tester.ensureVisible(timingMetrics);
      await tester.pump();
      final List<String?> metricTexts = tester
          .widgetList<Text>(
            find.descendant(
              of: timingMetrics,
              matching: find.byType(Text),
              skipOffstage: false,
            ),
          )
          .map((Text text) => text.data)
          .toList(growable: false);
      expect(metricTexts, containsAll(<String>['50.0 Hz', '501']));
      final Finder timestampStatus = find.byKey(
        const Key('sensor-timestamp-status'),
      );
      await tester.ensureVisible(timestampStatus);
      await tester.pump();
      expect(
        find.text('Monotonic timestamps', skipOffstage: false),
        findsOneWidget,
      );
      expect(find.text('Ready', skipOffstage: false), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'GNSS and anchor preserve native contracts and present sanitized results',
    (WidgetTester tester) async {
      final TestDefaultBinaryMessenger messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      const MethodChannel gnssChannel = MethodChannel(
        'io.github.mesuttsahin.navguard/gnss_diagnostics',
      );
      const MethodChannel anchorChannel = MethodChannel(
        'io.github.mesuttsahin.navguard/gnss_anchor',
      );
      int readinessCalls = 0;
      int permissionCalls = 0;
      int timingCalls = 0;
      int anchorPreflightCalls = 0;
      int anchorAcquireCalls = 0;
      int anchorCancelCalls = 0;
      Completer<Object?>? pendingAnchor;

      messenger.setMockMethodCallHandler(gnssChannel, (MethodCall call) async {
        switch (call.method) {
          case 'getGnssDiagnosticPreflight':
            readinessCalls++;
            return _readyGnssPreflight();
          case 'requestGnssForegroundPermission':
            permissionCalls++;
            return _readyGnssPreflight();
          case 'runGnssTimingDiagnostic':
            timingCalls++;
            return _validGnssTimingPayload();
          default:
            fail('Unexpected GNSS method: ${call.method}');
        }
      });
      messenger.setMockMethodCallHandler(anchorChannel, (
        MethodCall call,
      ) async {
        switch (call.method) {
          case 'getGnssAnchorPreflight':
            anchorPreflightCalls++;
            return _readyAnchorPreflight();
          case 'acquireGnssAnchor':
            anchorAcquireCalls++;
            return pendingAnchor?.future ?? _validAnchorPayload();
          case 'cancelGnssAnchorAcquisition':
            anchorCancelCalls++;
            pendingAnchor?.completeError(
              PlatformException(code: 'gnss_anchor_acquisition_cancelled'),
            );
            return null;
          default:
            fail('Unexpected anchor method: ${call.method}');
        }
      });
      addTearDown(() async {
        messenger.setMockMethodCallHandler(gnssChannel, null);
        messenger.setMockMethodCallHandler(anchorChannel, null);
      });

      await tester.pumpWidget(
        NavguardApp(
          liveDemoPlatform: _WidgetFakeLivePlatform(),
          aiPlatform: _WidgetFakeAiPlatform(),
          enableLiveMapTiles: false,
        ),
      );

      final Finder module = find.byKey(const Key('module-card-gnssAnchor'));
      await tester.ensureVisible(module);
      await tester.tap(module);
      await tester.pumpAndSettle();

      expect(
        find.text(
          'GNSS readiness, timing diagnostics and local navigation anchor.',
        ),
        findsOneWidget,
      );
      expect(find.text('Diagnostic Output'), findsNothing);
      expect(find.text('Not locked'), findsWidgets);

      final Finder readinessAction = find.byKey(
        const Key('gnss-preflight-action'),
      );
      await tester.ensureVisible(readinessAction);
      await tester.tap(readinessAction);
      await tester.pumpAndSettle();
      expect(readinessCalls, 1);
      expect(find.text('Precise location granted'), findsOneWidget);
      expect(find.text('Ready'), findsWidgets);

      final Finder permissionAction = find.byKey(
        const Key('gnss-permission-action'),
      );
      await tester.ensureVisible(permissionAction);
      await tester.tap(permissionAction);
      await tester.pumpAndSettle();
      expect(permissionCalls, 1);

      final Finder timingAction = find.byKey(const Key('gnss-timing-action'));
      await tester.ensureVisible(timingAction);
      await tester.tap(timingAction);
      await tester.pumpAndSettle();
      expect(timingCalls, 1);
      expect(find.text('GNSS timing completed'), findsOneWidget);
      final Finder timingMetrics = find.byKey(const Key('gnss-timing-metrics'));
      await tester.ensureVisible(timingMetrics);
      await tester.pump();
      expect(find.text('61', skipOffstage: false), findsOneWidget);
      expect(find.text('1.0 Hz', skipOffstage: false), findsOneWidget);
      expect(
        find.text('Monotonic timestamps', skipOffstage: false),
        findsOneWidget,
      );

      final Finder anchorPreflightAction = find.byKey(
        const Key('gnss-anchor-preflight-action'),
      );
      await tester.ensureVisible(anchorPreflightAction);
      await tester.tap(anchorPreflightAction);
      await tester.pumpAndSettle();
      expect(anchorPreflightCalls, 1);

      final Finder acquireAction = find.byKey(
        const Key('gnss-anchor-acquire-action'),
      );
      await tester.ensureVisible(acquireAction);
      await tester.tap(acquireAction);
      await tester.pumpAndSettle();
      expect(anchorAcquireCalls, 1);
      expect(find.text('Anchor locked'), findsWidgets);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('4.8 m'), findsOneWidget);
      expect(find.text('38.123456789', skipOffstage: false), findsNothing);
      expect(find.text('27.987654321', skipOffstage: false), findsNothing);

      final Finder clearAction = find.byKey(
        const Key('gnss-anchor-clear-action'),
      );
      await tester.ensureVisible(clearAction);
      await tester.tap(clearAction);
      await tester.pumpAndSettle();
      expect(find.text('Anchor locked'), findsNothing);
      expect(find.text('Not locked'), findsWidgets);

      pendingAnchor = Completer<Object?>();
      await tester.ensureVisible(acquireAction);
      await tester.tap(acquireAction);
      await tester.pump();
      expect(find.text('Anchor acquisition running'), findsOneWidget);
      expect(
        find.text(
          'Waiting for valid GPS candidates. Live candidate progress is not exposed by the current platform contract.',
        ),
        findsOneWidget,
      );
      final Finder cancelAction = find.byKey(
        const Key('gnss-anchor-cancel-action'),
      );
      await tester.ensureVisible(cancelAction);
      await tester.tap(cancelAction);
      await tester.pumpAndSettle();
      expect(anchorAcquireCalls, 2);
      expect(anchorCancelCalls, 1);
      expect(
        find.textContaining('gnss_anchor_acquisition_cancelled'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('opens Live Map and returns to GNSS anchor preparation', (
    WidgetTester tester,
  ) async {
    final _WidgetFakeLivePlatform platform = _WidgetFakeLivePlatform();
    await tester.pumpWidget(
      NavguardApp(
        liveDemoPlatform: platform,
        aiPlatform: _WidgetFakeAiPlatform(),
        enableLiveMapTiles: false,
      ),
    );

    final Finder liveMapAction = find.byKey(
      const Key('open-live-navguard-demo'),
    );
    await tester.ensureVisible(liveMapAction);
    await tester.tap(liveMapAction);
    await tester.pumpAndSettle();
    expect(find.text('NAVGUARD Live Map Demo'), findsOneWidget);
    expect(find.text('GNSS Anchor Required'), findsOneWidget);
    expect(
      find.text('Lock a GNSS anchor before starting the live navigation demo.'),
      findsOneWidget,
    );
    expect(find.text('Return to Prepare GNSS Anchor'), findsOneWidget);
    expect(platform.preflightCallCount, 0);
    expect(platform.startCallCount, 0);
    expect(platform.realServicesUsed, isFalse);

    await tester.tap(find.text('Return to Prepare GNSS Anchor'));
    await tester.pumpAndSettle();
    expect(find.text('GNSS & Anchor'), findsWidgets);
    expect(find.text('GNSS Anchor / Local Reference'), findsOneWidget);
    expect(find.text('Acquire GNSS Anchor'), findsOneWidget);
  });

  testWidgets('opens the existing AI Dataset screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      NavguardApp(
        liveDemoPlatform: _WidgetFakeLivePlatform(),
        aiPlatform: _WidgetFakeAiPlatform(),
        enableLiveMapTiles: false,
      ),
    );

    final Finder action = find.byKey(const Key('open-ai-dataset-capture'));
    await tester.ensureVisible(action);
    await tester.tap(action);
    await tester.pumpAndSettle();
    expect(find.text('NAVGUARD AI Dataset'), findsOneWidget);
    expect(find.text('V3 · Motion Dataset'), findsOneWidget);
    expect(find.text('40 Features'), findsOneWidget);
    expect(find.text('Local Only'), findsOneWidget);
  });

  testWidgets('refreshes readiness from safe capability preflights', (
    WidgetTester tester,
  ) async {
    final TestDefaultBinaryMessenger messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const MethodChannel sensorChannel = MethodChannel(
      'io.github.mesuttsahin.navguard/sensor_diagnostics',
    );
    const MethodChannel gnssChannel = MethodChannel(
      'io.github.mesuttsahin.navguard/gnss_diagnostics',
    );
    const MethodChannel anchorChannel = MethodChannel(
      'io.github.mesuttsahin.navguard/gnss_anchor',
    );
    const MethodChannel arCoreChannel = MethodChannel(
      'io.github.mesuttsahin.navguard/arcore_diagnostics',
    );

    messenger.setMockMethodCallHandler(sensorChannel, (MethodCall call) async {
      expect(call.method, 'getSensorCapabilityInventory');
      return <String, Object?>{
        'sensors': <Map<String, Object?>>[
          <String, Object?>{
            'requestedType': 'TYPE_ACCELEROMETER',
            'available': true,
          },
          <String, Object?>{
            'requestedType': 'TYPE_GYROSCOPE',
            'available': true,
          },
          <String, Object?>{
            'requestedType': 'TYPE_ROTATION_VECTOR',
            'available': true,
          },
          <String, Object?>{
            'requestedType': 'TYPE_STEP_DETECTOR',
            'available': true,
          },
        ],
      };
    });
    messenger.setMockMethodCallHandler(gnssChannel, (MethodCall call) async {
      expect(call.method, 'getGnssDiagnosticPreflight');
      return <String, Object?>{
        'preciseLocationGranted': true,
        'coarseLocationGranted': true,
        'gpsProviderAvailable': true,
        'gpsProviderEnabled': true,
        'locationServicesEnabled': true,
        'canRunFormalDiagnostic': true,
      };
    });
    messenger.setMockMethodCallHandler(anchorChannel, (MethodCall call) async {
      expect(call.method, 'getGnssAnchorPreflight');
      return <String, Object?>{
        'fineLocationPermissionGranted': true,
        'locationServicesEnabled': true,
        'gpsProviderEnabled': true,
        'acquisitionRunning': false,
        'canAcquireAnchor': true,
      };
    });
    messenger.setMockMethodCallHandler(arCoreChannel, (MethodCall call) async {
      expect(call.method, 'getArCoreDiagnosticPreflight');
      return <String, Object?>{
        'cameraPermissionGranted': true,
        'availabilityRaw': 'SUPPORTED_INSTALLED',
        'arCoreInstalledAndCurrent': true,
        'canRunFormalDiagnostic': true,
      };
    });
    addTearDown(() async {
      messenger.setMockMethodCallHandler(sensorChannel, null);
      messenger.setMockMethodCallHandler(gnssChannel, null);
      messenger.setMockMethodCallHandler(anchorChannel, null);
      messenger.setMockMethodCallHandler(arCoreChannel, null);
    });

    await tester.pumpWidget(
      NavguardApp(
        liveDemoPlatform: _WidgetFakeLivePlatform(),
        aiPlatform: _WidgetFakeAiPlatform(),
        enableLiveMapTiles: false,
      ),
    );
    await tester.tap(find.byKey(const Key('refresh-system-status')));
    await tester.pumpAndSettle();

    expect(find.text('Ready'), findsNWidgets(4));
    expect(find.text('Not locked'), findsOneWidget);
    expect(find.byKey(const Key('system-readiness-error')), findsNothing);
  });

  testWidgets(
    'Heading PDR preserves platform methods and presents structured results',
    (WidgetTester tester) async {
      final TestDefaultBinaryMessenger messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      const MethodChannel anchorChannel = MethodChannel(
        'io.github.mesuttsahin.navguard/gnss_anchor',
      );
      const MethodChannel headingChannel = MethodChannel(
        'io.github.mesuttsahin.navguard/heading_foundation',
      );
      const MethodChannel stepChannel = MethodChannel(
        'io.github.mesuttsahin.navguard/step_event',
      );
      const MethodChannel baselineChannel = MethodChannel(
        'io.github.mesuttsahin.navguard/baseline_pdr',
      );
      final List<String> headingMethods = <String>[];
      final List<String> stepMethods = <String>[];
      final List<String> baselineMethods = <String>[];

      messenger.setMockMethodCallHandler(anchorChannel, (
        MethodCall call,
      ) async {
        return switch (call.method) {
          'getGnssAnchorPreflight' => _readyAnchorPreflight(),
          'acquireGnssAnchor' => _validAnchorPayload(),
          _ => fail('Unexpected anchor method: ${call.method}'),
        };
      });
      messenger.setMockMethodCallHandler(headingChannel, (
        MethodCall call,
      ) async {
        headingMethods.add(call.method);
        return switch (call.method) {
          'getHeadingFoundationPreflight' => _readyHeadingPreflight(),
          'runHeadingFoundationDiagnostic' => _validHeadingUiResult(),
          _ => fail('Unexpected heading method: ${call.method}'),
        };
      });
      messenger.setMockMethodCallHandler(stepChannel, (MethodCall call) async {
        stepMethods.add(call.method);
        return switch (call.method) {
          'getStepEventPreflight' => _readyStepPreflight(),
          'runStepEventDiagnostic' => _validStepUiResult(),
          _ => fail('Unexpected step method: ${call.method}'),
        };
      });
      messenger.setMockMethodCallHandler(baselineChannel, (
        MethodCall call,
      ) async {
        baselineMethods.add(call.method);
        return switch (call.method) {
          'getBaselinePdrPreflight' => _readyBaselinePdrPreflight(),
          'runBaselinePdrDiagnostic' => _validBaselinePdrUiResult(),
          _ => fail('Unexpected baseline method: ${call.method}'),
        };
      });
      addTearDown(() async {
        messenger.setMockMethodCallHandler(anchorChannel, null);
        messenger.setMockMethodCallHandler(headingChannel, null);
        messenger.setMockMethodCallHandler(stepChannel, null);
        messenger.setMockMethodCallHandler(baselineChannel, null);
      });

      await tester.pumpWidget(
        NavguardApp(
          liveDemoPlatform: _WidgetFakeLivePlatform(),
          aiPlatform: _WidgetFakeAiPlatform(),
          enableLiveMapTiles: false,
        ),
      );
      await _lockNavigationAnchor(tester);

      final Finder module = find.byKey(const Key('module-card-headingPdr'));
      await tester.ensureVisible(module);
      await tester.tap(module);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('heading-pdr-diagnostic-content')),
        findsOneWidget,
      );
      expect(find.text('Body heading: NOT IMPLEMENTED'), findsNothing);
      expect(
        find.textContaining(
          'Adaptive body-heading offset: Outside this baseline PDR diagnostic.',
        ),
        findsOneWidget,
      );

      await _tapVisible(tester, const Key('heading-preflight-action'));
      await _tapVisible(tester, const Key('heading-run-action'));
      expect(headingMethods, <String>[
        'getHeadingFoundationPreflight',
        'runHeadingFoundationDiagnostic',
      ]);
      expect(find.text('71.6° · 1.250000 rad'), findsOneWidget);
      expect(find.text('50.00 Hz'), findsOneWidget);

      await _tapVisible(tester, const Key('step-preflight-action'));
      await _tapVisible(tester, const Key('step-run-action'));
      expect(stepMethods, <String>[
        'getStepEventPreflight',
        'runStepEventDiagnostic',
      ]);
      expect(find.text('3'), findsWidgets);
      expect(find.text('100.00 steps/min'), findsOneWidget);

      await _tapVisible(tester, const Key('baseline-pdr-preflight-action'));
      await _tapVisible(tester, const Key('baseline-pdr-run-action'));
      expect(baselineMethods, <String>[
        'getBaselinePdrPreflight',
        'runBaselinePdrDiagnostic',
      ]);
      expect(find.text('1.500 m'), findsNWidgets(3));
      expect(find.text('10.000 ms'), findsOneWidget);
      expect(find.text('Diagnostic Output'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'ARCore ENU preserves platform methods and presents structured results',
    (WidgetTester tester) async {
      final TestDefaultBinaryMessenger messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      const MethodChannel anchorChannel = MethodChannel(
        'io.github.mesuttsahin.navguard/gnss_anchor',
      );
      const MethodChannel arCoreChannel = MethodChannel(
        'io.github.mesuttsahin.navguard/arcore_diagnostics',
      );
      const MethodChannel enuChannel = MethodChannel(
        'io.github.mesuttsahin.navguard/arcore_enu',
      );
      final List<String> arCoreMethods = <String>[];
      final List<String> enuMethods = <String>[];

      messenger.setMockMethodCallHandler(anchorChannel, (
        MethodCall call,
      ) async {
        return switch (call.method) {
          'getGnssAnchorPreflight' => _readyAnchorPreflight(),
          'acquireGnssAnchor' => _validAnchorPayload(),
          _ => fail('Unexpected anchor method: ${call.method}'),
        };
      });
      messenger.setMockMethodCallHandler(arCoreChannel, (
        MethodCall call,
      ) async {
        arCoreMethods.add(call.method);
        return switch (call.method) {
          'getArCoreDiagnosticPreflight' => _readyArCorePreflight(),
          'requestArCoreCameraPermission' => _readyArCorePermissionResult(),
          'runArCoreTrackingDiagnostic' => _validArCoreTrackingUiResult(),
          _ => fail('Unexpected ARCore method: ${call.method}'),
        };
      });
      messenger.setMockMethodCallHandler(enuChannel, (MethodCall call) async {
        enuMethods.add(call.method);
        return switch (call.method) {
          'getArCoreEnuPreflight' => _readyArCoreEnuPreflight(),
          'runArCoreEnuDiagnostic' => _validArCoreEnuUiResult(),
          _ => fail('Unexpected ARCore ENU method: ${call.method}'),
        };
      });
      addTearDown(() async {
        messenger.setMockMethodCallHandler(anchorChannel, null);
        messenger.setMockMethodCallHandler(arCoreChannel, null);
        messenger.setMockMethodCallHandler(enuChannel, null);
      });

      await tester.pumpWidget(
        NavguardApp(
          liveDemoPlatform: _WidgetFakeLivePlatform(),
          aiPlatform: _WidgetFakeAiPlatform(),
          enableLiveMapTiles: false,
        ),
      );
      await _lockNavigationAnchor(tester);

      final Finder module = find.byKey(const Key('module-card-arCoreEnu'));
      await tester.ensureVisible(module);
      await tester.tap(module);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('arcore-enu-diagnostic-content')),
        findsOneWidget,
      );
      expect(find.text('PDR fusion: NOT IMPLEMENTED'), findsNothing);
      expect(find.text('EKF: NOT IMPLEMENTED'), findsNothing);
      expect(
        find.textContaining(
          'Full PDR fusion and EKF updates are outside this diagnostic.',
        ),
        findsOneWidget,
      );

      await _tapVisible(tester, const Key('arcore-preflight-action'));
      await _tapVisible(tester, const Key('arcore-permission-action'));
      await _tapVisible(tester, const Key('arcore-tracking-run-action'));
      expect(arCoreMethods, <String>[
        'getArCoreDiagnosticPreflight',
        'requestArCoreCameraPermission',
        'runArCoreTrackingDiagnostic',
      ]);
      expect(find.text('75.0%'), findsWidgets);
      expect(find.text('30.0 Hz'), findsOneWidget);

      await _tapVisible(tester, const Key('arcore-enu-preflight-action'));
      await _tapVisible(tester, const Key('arcore-enu-run-action'));
      expect(enuMethods, <String>[
        'getArCoreEnuPreflight',
        'runArCoreEnuDiagnostic',
      ]);
      expect(find.text('3.000 m'), findsOneWidget);
      expect(find.text('4.000 m'), findsOneWidget);
      expect(find.text('13.000 m'), findsOneWidget);
      expect(find.text('Diagnostic Output'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Fusion EKF preserves platform methods and presents structured results',
    (WidgetTester tester) async {
      final TestDefaultBinaryMessenger messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      const MethodChannel anchorChannel = MethodChannel(
        'io.github.mesuttsahin.navguard/gnss_anchor',
      );
      const MethodChannel fusionChannel = MethodChannel(
        'io.github.mesuttsahin.navguard/navguard_fusion',
      );
      final List<String> methods = <String>[];

      messenger.setMockMethodCallHandler(anchorChannel, (
        MethodCall call,
      ) async {
        return switch (call.method) {
          'getGnssAnchorPreflight' => _readyAnchorPreflight(),
          'acquireGnssAnchor' => _validAnchorPayload(),
          _ => fail('Unexpected anchor method: ${call.method}'),
        };
      });
      messenger.setMockMethodCallHandler(fusionChannel, (
        MethodCall call,
      ) async {
        methods.add(call.method);
        return switch (call.method) {
          'getNavguardFusionPreflight' => _readyFusionPreflight(),
          'runNavguardFusionDiagnostic' => _validFusionUiResult(),
          _ => fail('Unexpected fusion method: ${call.method}'),
        };
      });
      addTearDown(() async {
        messenger.setMockMethodCallHandler(anchorChannel, null);
        messenger.setMockMethodCallHandler(fusionChannel, null);
      });

      await tester.pumpWidget(
        NavguardApp(
          liveDemoPlatform: _WidgetFakeLivePlatform(),
          aiPlatform: _WidgetFakeAiPlatform(),
          enableLiveMapTiles: false,
        ),
      );
      await _lockNavigationAnchor(tester);

      final Finder module = find.byKey(const Key('module-card-fusionEkf'));
      await tester.ensureVisible(module);
      await tester.tap(module);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('fusion-ekf-diagnostic-content')),
        findsOneWidget,
      );
      expect(find.text('GNSS recovery: NOT IMPLEMENTED'), findsNothing);
      expect(
        find.text(
          'Recovery handling is evaluated in the full Denial & Recovery diagnostic.',
        ),
        findsOneWidget,
      );

      await _tapVisible(tester, const Key('fusion-preflight-action'));
      await _tapVisible(tester, const Key('fusion-run-action'));
      expect(methods, <String>[
        'getNavguardFusionPreflight',
        'runNavguardFusionDiagnostic',
      ]);
      expect(find.text('config_d_navguard_ekf_v1'), findsOneWidget);
      expect(find.text('E,N,heading'), findsOneWidget);
      expect(find.text('3.000 m'), findsOneWidget);
      expect(find.text('4.000 m'), findsOneWidget);
      expect(find.text('28.6° · 0.500000 rad'), findsOneWidget);
      expect(find.text('Diagnostic Output'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Denial recovery preserves platform methods and presents firewall results',
    (WidgetTester tester) async {
      final TestDefaultBinaryMessenger messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      const MethodChannel anchorChannel = MethodChannel(
        'io.github.mesuttsahin.navguard/gnss_anchor',
      );
      const MethodChannel flowChannel = MethodChannel(
        'io.github.mesuttsahin.navguard/full_navguard_flow',
      );
      final List<String> methods = <String>[];

      messenger.setMockMethodCallHandler(anchorChannel, (
        MethodCall call,
      ) async {
        return switch (call.method) {
          'getGnssAnchorPreflight' => _readyAnchorPreflight(),
          'acquireGnssAnchor' => _validAnchorPayload(),
          _ => fail('Unexpected anchor method: ${call.method}'),
        };
      });
      messenger.setMockMethodCallHandler(flowChannel, (MethodCall call) async {
        methods.add(call.method);
        return switch (call.method) {
          'getFullNavguardFlowPreflight' => _readyFullFlowPreflight(),
          'runFullNavguardFlowDiagnostic' => _validFullFlowUiResult(),
          _ => fail('Unexpected full-flow method: ${call.method}'),
        };
      });
      addTearDown(() async {
        messenger.setMockMethodCallHandler(anchorChannel, null);
        messenger.setMockMethodCallHandler(flowChannel, null);
      });

      await tester.pumpWidget(
        NavguardApp(
          liveDemoPlatform: _WidgetFakeLivePlatform(),
          aiPlatform: _WidgetFakeAiPlatform(),
          enableLiveMapTiles: false,
        ),
      );
      await _lockNavigationAnchor(tester);

      final Finder module = find.byKey(const Key('module-card-denialRecovery'));
      await tester.ensureVisible(module);
      await tester.tap(module);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('denial-recovery-diagnostic-content')),
        findsOneWidget,
      );

      await _tapVisible(tester, const Key('denial-recovery-preflight-action'));
      await _tapVisible(tester, const Key('denial-recovery-run-action'));
      expect(methods, <String>[
        'getFullNavguardFlowPreflight',
        'runFullNavguardFlowDiagnostic',
      ]);
      expect(find.text('Blocked'), findsOneWidget);
      expect(find.text('3 / 3'), findsOneWidget);
      expect(find.text('3.606 m'), findsOneWidget);
      expect(
        find.text(
          'Estimator-to-recovered-GNSS discrepancy before relocalization.',
        ),
        findsOneWidget,
      );
      expect(find.text('GNSS recovery: NOT IMPLEMENTED'), findsNothing);
      expect(find.text('Position error'), findsNothing);
      expect(find.text('Diagnostic Output'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  for (final Size size in <Size>[
    const Size(360, 800),
    const Size(393, 873),
    const Size(430, 932),
  ]) {
    testWidgets('home has no overflow at ${size.width.toInt()} dp', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        NavguardApp(
          liveDemoPlatform: _WidgetFakeLivePlatform(),
          aiPlatform: _WidgetFakeAiPlatform(),
          enableLiveMapTiles: false,
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('navguard-hero')), findsOneWidget);
      final Text anchorLabel = tester.widget<Text>(find.text('GNSS Anchor'));
      expect(anchorLabel.overflow, isNot(TextOverflow.ellipsis));
      expect(anchorLabel.maxLines, 1);

      final Finder accuracyCard = find.byKey(
        const Key('module-card-accuracyV2'),
      );
      expect(accuracyCard, findsOneWidget);
      expect(find.text('Accuracy v2'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('research-modules-grid')),
          matching: accuracyCard,
        ),
        findsNothing,
      );
      final Size accuracySize = tester.getSize(accuracyCard);
      final Size heroSize = tester.getSize(
        find.byKey(const Key('navguard-hero')),
      );
      expect(accuracySize.width, closeTo(heroSize.width, 0.1));
      expect(accuracySize.height, lessThan(100));
      expect(tester.takeException(), isNull);
    });
  }

  for (final Size size in <Size>[
    const Size(360, 800),
    const Size(393, 873),
    const Size(430, 932),
  ]) {
    testWidgets('Sensors diagnostic has no overflow at ${size.width.toInt()} dp', (
      WidgetTester tester,
    ) async {
      final TestDefaultBinaryMessenger messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      const MethodChannel sensorChannel = MethodChannel(
        'io.github.mesuttsahin.navguard/sensor_diagnostics',
      );
      messenger.setMockMethodCallHandler(sensorChannel, (
        MethodCall call,
      ) async {
        if (call.method == 'getSensorCapabilityInventory') {
          return <String, Object?>{
            'schemaVersion': 1,
            'snapshotKind': 'sensor_capability_inventory',
            'capabilityMetadataOnly': true,
            'sensors': <Map<String, Object?>>[
              for (final String type in <String>[
                'TYPE_ACCELEROMETER',
                'TYPE_GYROSCOPE',
                'TYPE_ROTATION_VECTOR',
                'TYPE_STEP_DETECTOR',
              ])
                <String, Object?>{
                  'requestedType': type,
                  'platformApiSupported': true,
                  'available': true,
                  'name':
                      'Long research-grade sensor name for responsive verification',
                  'vendor': 'NAVGUARD Responsive Test Vendor',
                  'resolution': 0.000123,
                  'minDelayUs': 5000,
                  'power': 0.25,
                },
            ],
          };
        }
        if (call.method == 'runSensorTimingDiagnostic') {
          return <String, Object?>{
            'schemaVersion': 1,
            'snapshotKind': 'sensor_event_timing_diagnostic',
            'status': 'completed',
            'validTimingSummary': true,
            'sensor': <String, Object?>{
              'requestedType': 'TYPE_ACCELEROMETER',
              'name':
                  'Long research-grade sensor name for responsive verification',
            },
            'requestedNominalRateHz': 50.0,
            'meanDeliveredHz': 49.875,
            'eventCount': 500,
            'meanDeltaNs': 20050125.0,
            'p95DeltaNs': 24500125,
            'maxDeltaNs': 60125125,
            'nonMonotonicTimestampCount': 0,
          };
        }
        fail('Unexpected sensor method: ${call.method}');
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(sensorChannel, null),
      );

      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        NavguardApp(
          liveDemoPlatform: _WidgetFakeLivePlatform(),
          aiPlatform: _WidgetFakeAiPlatform(),
          enableLiveMapTiles: false,
        ),
      );
      final Finder sensorModule = find.byKey(const Key('module-card-sensors'));
      await tester.ensureVisible(sensorModule);
      await tester.tap(sensorModule);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('sensors-diagnostic-content')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('sensor-inventory-action')));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Long research-grade sensor name for responsive verification',
          skipOffstage: false,
        ),
        findsNWidgets(4),
      );

      final Finder timingAction = find.byKey(const Key('sensor-timing-action'));
      await tester.ensureVisible(timingAction);
      await tester.tap(timingAction);
      await tester.pumpAndSettle();

      final Finder timingMetrics = find.byKey(
        const Key('sensor-timing-metrics'),
      );
      await tester.ensureVisible(timingMetrics);
      await tester.pump();
      expect(find.text('49.9 Hz', skipOffstage: false), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final Size size in <Size>[
    const Size(360, 800),
    const Size(393, 873),
    const Size(430, 932),
  ]) {
    testWidgets(
      'GNSS and anchor diagnostic has no overflow at ${size.width.toInt()} dp',
      (WidgetTester tester) async {
        final TestDefaultBinaryMessenger messenger =
            TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
        const MethodChannel gnssChannel = MethodChannel(
          'io.github.mesuttsahin.navguard/gnss_diagnostics',
        );
        const MethodChannel anchorChannel = MethodChannel(
          'io.github.mesuttsahin.navguard/gnss_anchor',
        );
        messenger.setMockMethodCallHandler(gnssChannel, (
          MethodCall call,
        ) async {
          return switch (call.method) {
            'getGnssDiagnosticPreflight' => _readyGnssPreflight(),
            'runGnssTimingDiagnostic' => _validGnssTimingPayload(),
            _ => fail('Unexpected GNSS method: ${call.method}'),
          };
        });
        messenger.setMockMethodCallHandler(anchorChannel, (
          MethodCall call,
        ) async {
          return switch (call.method) {
            'getGnssAnchorPreflight' => _readyAnchorPreflight(),
            'acquireGnssAnchor' => _validAnchorPayload(),
            _ => fail('Unexpected anchor method: ${call.method}'),
          };
        });
        addTearDown(() async {
          messenger.setMockMethodCallHandler(gnssChannel, null);
          messenger.setMockMethodCallHandler(anchorChannel, null);
        });

        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          NavguardApp(
            liveDemoPlatform: _WidgetFakeLivePlatform(),
            aiPlatform: _WidgetFakeAiPlatform(),
            enableLiveMapTiles: false,
          ),
        );
        final Finder module = find.byKey(const Key('module-card-gnssAnchor'));
        await tester.ensureVisible(module);
        await tester.tap(module);
        await tester.pumpAndSettle();

        final Finder readinessAction = find.byKey(
          const Key('gnss-preflight-action'),
        );
        await tester.ensureVisible(readinessAction);
        await tester.tap(readinessAction);
        await tester.pumpAndSettle();

        final Finder timingAction = find.byKey(const Key('gnss-timing-action'));
        await tester.ensureVisible(timingAction);
        await tester.tap(timingAction);
        await tester.pumpAndSettle();

        final Finder anchorPreflightAction = find.byKey(
          const Key('gnss-anchor-preflight-action'),
        );
        await tester.ensureVisible(anchorPreflightAction);
        await tester.tap(anchorPreflightAction);
        await tester.pumpAndSettle();

        final Finder acquireAction = find.byKey(
          const Key('gnss-anchor-acquire-action'),
        );
        await tester.ensureVisible(acquireAction);
        await tester.tap(acquireAction);
        await tester.pumpAndSettle();

        final Finder anchorMetrics = find.byKey(
          const Key('gnss-anchor-metrics'),
        );
        await tester.ensureVisible(anchorMetrics);
        await tester.pump();
        expect(find.text('Anchor locked', skipOffstage: false), findsWidgets);
        expect(find.text('4.8 m', skipOffstage: false), findsOneWidget);
        expect(
          find.text(
            'Uses structurally valid, non-mock GPS_PROVIDER candidates. Selection prefers the lowest reported horizontal accuracy and then the newer elapsed-realtime fix.',
            skipOffstage: false,
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final Size size in <Size>[
    const Size(360, 800),
    const Size(393, 873),
    const Size(430, 932),
  ]) {
    testWidgets(
      'Heading PDR diagnostic has no overflow at ${size.width.toInt()} dp',
      (WidgetTester tester) async {
        final TestDefaultBinaryMessenger messenger =
            TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
        const MethodChannel anchorChannel = MethodChannel(
          'io.github.mesuttsahin.navguard/gnss_anchor',
        );
        const MethodChannel headingChannel = MethodChannel(
          'io.github.mesuttsahin.navguard/heading_foundation',
        );
        const MethodChannel stepChannel = MethodChannel(
          'io.github.mesuttsahin.navguard/step_event',
        );
        const MethodChannel baselineChannel = MethodChannel(
          'io.github.mesuttsahin.navguard/baseline_pdr',
        );
        messenger.setMockMethodCallHandler(anchorChannel, (
          MethodCall call,
        ) async {
          return switch (call.method) {
            'getGnssAnchorPreflight' => _readyAnchorPreflight(),
            'acquireGnssAnchor' => _validAnchorPayload(),
            _ => fail('Unexpected anchor method: ${call.method}'),
          };
        });
        messenger.setMockMethodCallHandler(headingChannel, (
          MethodCall call,
        ) async {
          return switch (call.method) {
            'getHeadingFoundationPreflight' => _readyHeadingPreflight(),
            'runHeadingFoundationDiagnostic' => _validHeadingUiResult(),
            _ => fail('Unexpected heading method: ${call.method}'),
          };
        });
        messenger.setMockMethodCallHandler(stepChannel, (
          MethodCall call,
        ) async {
          return switch (call.method) {
            'getStepEventPreflight' => _readyStepPreflight(),
            'runStepEventDiagnostic' => _validStepUiResult(),
            _ => fail('Unexpected step method: ${call.method}'),
          };
        });
        messenger.setMockMethodCallHandler(baselineChannel, (
          MethodCall call,
        ) async {
          return switch (call.method) {
            'getBaselinePdrPreflight' => _readyBaselinePdrPreflight(),
            'runBaselinePdrDiagnostic' => _validBaselinePdrUiResult(),
            _ => fail('Unexpected baseline method: ${call.method}'),
          };
        });
        addTearDown(() async {
          messenger.setMockMethodCallHandler(anchorChannel, null);
          messenger.setMockMethodCallHandler(headingChannel, null);
          messenger.setMockMethodCallHandler(stepChannel, null);
          messenger.setMockMethodCallHandler(baselineChannel, null);
        });

        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          NavguardApp(
            liveDemoPlatform: _WidgetFakeLivePlatform(),
            aiPlatform: _WidgetFakeAiPlatform(),
            enableLiveMapTiles: false,
          ),
        );
        await _lockNavigationAnchor(tester);
        final Finder module = find.byKey(const Key('module-card-headingPdr'));
        await tester.ensureVisible(module);
        await tester.tap(module);
        await tester.pumpAndSettle();
        await _tapVisible(tester, const Key('heading-preflight-action'));
        await _tapVisible(tester, const Key('heading-run-action'));
        await _tapVisible(tester, const Key('step-preflight-action'));
        await _tapVisible(tester, const Key('step-run-action'));
        await _tapVisible(tester, const Key('baseline-pdr-preflight-action'));
        await _tapVisible(tester, const Key('baseline-pdr-run-action'));

        final Finder metrics = find.byKey(
          const Key('baseline-pdr-result-metrics'),
        );
        await tester.ensureVisible(metrics);
        await tester.pump();
        expect(find.text('1.500 m', skipOffstage: false), findsNWidgets(3));
        expect(
          find.textContaining(
            'Adaptive body-heading offset: Outside this baseline PDR diagnostic.',
            skipOffstage: false,
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final Size size in <Size>[
    const Size(360, 800),
    const Size(393, 873),
    const Size(430, 932),
  ]) {
    testWidgets(
      'ARCore ENU diagnostic has no overflow at ${size.width.toInt()} dp',
      (WidgetTester tester) async {
        final TestDefaultBinaryMessenger messenger =
            TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
        const MethodChannel anchorChannel = MethodChannel(
          'io.github.mesuttsahin.navguard/gnss_anchor',
        );
        const MethodChannel arCoreChannel = MethodChannel(
          'io.github.mesuttsahin.navguard/arcore_diagnostics',
        );
        const MethodChannel enuChannel = MethodChannel(
          'io.github.mesuttsahin.navguard/arcore_enu',
        );
        messenger.setMockMethodCallHandler(anchorChannel, (
          MethodCall call,
        ) async {
          return switch (call.method) {
            'getGnssAnchorPreflight' => _readyAnchorPreflight(),
            'acquireGnssAnchor' => _validAnchorPayload(),
            _ => fail('Unexpected anchor method: ${call.method}'),
          };
        });
        messenger.setMockMethodCallHandler(arCoreChannel, (
          MethodCall call,
        ) async {
          return switch (call.method) {
            'getArCoreDiagnosticPreflight' => _readyArCorePreflight(),
            'runArCoreTrackingDiagnostic' => _validArCoreTrackingUiResult(),
            _ => fail('Unexpected ARCore method: ${call.method}'),
          };
        });
        messenger.setMockMethodCallHandler(enuChannel, (MethodCall call) async {
          return switch (call.method) {
            'getArCoreEnuPreflight' => _readyArCoreEnuPreflight(),
            'runArCoreEnuDiagnostic' => _validArCoreEnuUiResult(),
            _ => fail('Unexpected ARCore ENU method: ${call.method}'),
          };
        });
        addTearDown(() async {
          messenger.setMockMethodCallHandler(anchorChannel, null);
          messenger.setMockMethodCallHandler(arCoreChannel, null);
          messenger.setMockMethodCallHandler(enuChannel, null);
        });

        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          NavguardApp(
            liveDemoPlatform: _WidgetFakeLivePlatform(),
            aiPlatform: _WidgetFakeAiPlatform(),
            enableLiveMapTiles: false,
          ),
        );
        await _lockNavigationAnchor(tester);
        final Finder module = find.byKey(const Key('module-card-arCoreEnu'));
        await tester.ensureVisible(module);
        await tester.tap(module);
        await tester.pumpAndSettle();
        await _tapVisible(tester, const Key('arcore-preflight-action'));
        await _tapVisible(tester, const Key('arcore-tracking-run-action'));
        await _tapVisible(tester, const Key('arcore-enu-preflight-action'));
        await _tapVisible(tester, const Key('arcore-enu-run-action'));

        final Finder metrics = find.byKey(
          const Key('arcore-enu-result-metrics'),
        );
        await tester.ensureVisible(metrics);
        await tester.pump();
        expect(find.text('75.0%', skipOffstage: false), findsWidgets);
        expect(find.text('13.000 m', skipOffstage: false), findsOneWidget);
        expect(
          find.textContaining(
            'Full PDR fusion and EKF updates are outside this diagnostic.',
            skipOffstage: false,
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final Size size in <Size>[
    const Size(360, 800),
    const Size(393, 873),
    const Size(430, 932),
  ]) {
    testWidgets(
      'Fusion EKF diagnostic has no overflow at ${size.width.toInt()} dp',
      (WidgetTester tester) async {
        final TestDefaultBinaryMessenger messenger =
            TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
        const MethodChannel anchorChannel = MethodChannel(
          'io.github.mesuttsahin.navguard/gnss_anchor',
        );
        const MethodChannel fusionChannel = MethodChannel(
          'io.github.mesuttsahin.navguard/navguard_fusion',
        );
        messenger.setMockMethodCallHandler(anchorChannel, (
          MethodCall call,
        ) async {
          return switch (call.method) {
            'getGnssAnchorPreflight' => _readyAnchorPreflight(),
            'acquireGnssAnchor' => _validAnchorPayload(),
            _ => fail('Unexpected anchor method: ${call.method}'),
          };
        });
        messenger.setMockMethodCallHandler(fusionChannel, (
          MethodCall call,
        ) async {
          return switch (call.method) {
            'getNavguardFusionPreflight' => _readyFusionPreflight(),
            'runNavguardFusionDiagnostic' => _validFusionUiResult(),
            _ => fail('Unexpected fusion method: ${call.method}'),
          };
        });
        addTearDown(() async {
          messenger.setMockMethodCallHandler(anchorChannel, null);
          messenger.setMockMethodCallHandler(fusionChannel, null);
        });

        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          NavguardApp(
            liveDemoPlatform: _WidgetFakeLivePlatform(),
            aiPlatform: _WidgetFakeAiPlatform(),
            enableLiveMapTiles: false,
          ),
        );
        await _lockNavigationAnchor(tester);
        final Finder module = find.byKey(const Key('module-card-fusionEkf'));
        await tester.ensureVisible(module);
        await tester.tap(module);
        await tester.pumpAndSettle();
        await _tapVisible(tester, const Key('fusion-preflight-action'));
        await _tapVisible(tester, const Key('fusion-run-action'));

        final Finder metrics = find.byKey(
          const Key('fusion-estimator-state-metrics'),
        );
        await tester.ensureVisible(metrics);
        await tester.pump();
        expect(
          find.text('28.6° · 0.500000 rad', skipOffstage: false),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final Size size in <Size>[
    const Size(360, 800),
    const Size(393, 873),
    const Size(430, 932),
  ]) {
    testWidgets(
      'Denial recovery diagnostic has no overflow at ${size.width.toInt()} dp',
      (WidgetTester tester) async {
        final TestDefaultBinaryMessenger messenger =
            TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
        const MethodChannel anchorChannel = MethodChannel(
          'io.github.mesuttsahin.navguard/gnss_anchor',
        );
        const MethodChannel flowChannel = MethodChannel(
          'io.github.mesuttsahin.navguard/full_navguard_flow',
        );
        messenger.setMockMethodCallHandler(anchorChannel, (
          MethodCall call,
        ) async {
          return switch (call.method) {
            'getGnssAnchorPreflight' => _readyAnchorPreflight(),
            'acquireGnssAnchor' => _validAnchorPayload(),
            _ => fail('Unexpected anchor method: ${call.method}'),
          };
        });
        messenger.setMockMethodCallHandler(flowChannel, (
          MethodCall call,
        ) async {
          return switch (call.method) {
            'getFullNavguardFlowPreflight' => _readyFullFlowPreflight(),
            'runFullNavguardFlowDiagnostic' => _validFullFlowUiResult(),
            _ => fail('Unexpected full-flow method: ${call.method}'),
          };
        });
        addTearDown(() async {
          messenger.setMockMethodCallHandler(anchorChannel, null);
          messenger.setMockMethodCallHandler(flowChannel, null);
        });

        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          NavguardApp(
            liveDemoPlatform: _WidgetFakeLivePlatform(),
            aiPlatform: _WidgetFakeAiPlatform(),
            enableLiveMapTiles: false,
          ),
        );
        await _lockNavigationAnchor(tester);
        final Finder module = find.byKey(
          const Key('module-card-denialRecovery'),
        );
        await tester.ensureVisible(module);
        await tester.tap(module);
        await tester.pumpAndSettle();
        await _tapVisible(
          tester,
          const Key('denial-recovery-preflight-action'),
        );
        await _tapVisible(tester, const Key('denial-recovery-run-action'));

        final Finder metrics = find.byKey(const Key('recovery-result-metrics'));
        await tester.ensureVisible(metrics);
        await tester.pump();
        expect(find.text('3.606 m', skipOffstage: false), findsOneWidget);
        expect(
          find.textContaining(
            'Estimator-to-recovered-GNSS discrepancy before relocalization.',
            skipOffstage: false,
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Evaluation GTF preserves platform methods and presents protected aggregates',
    (WidgetTester tester) async {
      final List<String> methods = <String>[];
      _installReadyAnchorMock();
      _installEvaluationMock(methods);

      await _openEvaluationResult(tester);

      expect(
        methods,
        containsAllInOrder(<String>[
          'getEvaluationModePreflight',
          'runEvaluationModeDiagnostic',
        ]),
      );
      expect(find.text('Protected Reference Isolation'), findsOneWidget);
      expect(find.text('Isolated'), findsWidgets);
      expect(find.text('1.500 m'), findsOneWidget);
      expect(find.text('2.000 m'), findsWidgets);
      expect(find.text('Diagnostic Output'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Benchmarks preserve A B C D contracts and present matched results',
    (WidgetTester tester) async {
      final List<String> methods = <String>[];
      _installReadyAnchorMock();
      _installBenchmarkMock(methods);

      await _openBenchmarkResult(tester);

      expect(
        methods,
        containsAllInOrder(<String>[
          'getNavguardBenchmarkPreflight',
          'runNavguardBenchmarkDiagnostic',
        ]),
      );
      for (final String id in <String>[
        'config_a_deterministic_pdr',
        'config_b_pdr_heading_ekf',
        'config_c_arcore_relative',
        'config_d_navguard_ekf_v1',
      ]) {
        expect(find.text(id, skipOffstage: false), findsWidgets);
      }
      expect(
        find.text('Research target met in this session', skipOffstage: false),
        findsOneWidget,
      );
      expect(find.text('Diagnostic Output'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Accuracy v2 preserves calibration and development benchmark contracts',
    (WidgetTester tester) async {
      final List<String> methods = <String>[];
      _installReadyAnchorMock();
      _installAccuracyV2Mock(methods);

      await _openAccuracyV2Result(tester);

      expect(
        methods,
        containsAll(<String>[
          'getAccuracyV2Preflight',
          'getCalibrationProfile',
          'runAccuracyV2Calibration',
          'runAccuracyV2DevelopmentBenchmark',
        ]),
      );
      expect(find.text('0.780 m', skipOffstage: false), findsWidgets);
      expect(find.text('-4.00°', skipOffstage: false), findsWidgets);
      expect(find.text('22.22%', skipOffstage: false), findsOneWidget);
      expect(find.text('Development metrics only'), findsOneWidget);
      expect(find.text('Diagnostic Output'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  for (final Size size in <Size>[
    const Size(360, 800),
    const Size(393, 873),
    const Size(430, 932),
  ]) {
    testWidgets(
      'Evaluation GTF result has no overflow at ${size.width.toInt()} dp',
      (WidgetTester tester) async {
        _installReadyAnchorMock();
        _installEvaluationMock(<String>[]);
        _setTestViewport(tester, size);

        await _openEvaluationResult(tester);
        await tester.ensureVisible(
          find.byKey(const Key('evaluation-result-metrics')),
        );
        await tester.pump();

        expect(find.text('1.500 m', skipOffstage: false), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final Size size in <Size>[
    const Size(360, 800),
    const Size(393, 873),
    const Size(430, 932),
  ]) {
    testWidgets(
      'Benchmark result has no overflow at ${size.width.toInt()} dp',
      (WidgetTester tester) async {
        _installReadyAnchorMock();
        _installBenchmarkMock(<String>[]);
        _setTestViewport(tester, size);

        await _openBenchmarkResult(tester);
        await tester.ensureVisible(
          find.byKey(const Key('benchmark-configD-metrics')),
        );
        await tester.pump();

        expect(find.text('7.000 m', skipOffstage: false), findsWidgets);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final Size size in <Size>[
    const Size(360, 800),
    const Size(393, 873),
    const Size(430, 932),
  ]) {
    testWidgets(
      'Accuracy v2 result has no overflow at ${size.width.toInt()} dp',
      (WidgetTester tester) async {
        _installReadyAnchorMock();
        _installAccuracyV2Mock(<String>[]);
        _setTestViewport(tester, size);

        await _openAccuracyV2Result(tester);
        await tester.ensureVisible(
          find.byKey(const Key('accuracy-v2-benchmark-summary')),
        );
        await tester.pump();

        expect(find.text('22.22%', skipOffstage: false), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

Future<void> _tapVisible(WidgetTester tester, Key key) async {
  final Finder action = find.byKey(key);
  await tester.ensureVisible(action);
  await tester.tap(action);
  await tester.pumpAndSettle();
}

Future<void> _lockNavigationAnchor(WidgetTester tester) async {
  final Finder module = find.byKey(const Key('module-card-gnssAnchor'));
  await tester.ensureVisible(module);
  await tester.tap(module);
  await tester.pumpAndSettle();
  await _tapVisible(tester, const Key('gnss-anchor-preflight-action'));
  await _tapVisible(tester, const Key('gnss-anchor-acquire-action'));
  await tester.tap(find.byKey(const Key('diagnostic-back-button')));
  await tester.pumpAndSettle();
}

void _setTestViewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void _installReadyAnchorMock() {
  final TestDefaultBinaryMessenger messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const MethodChannel channel = MethodChannel(
    'io.github.mesuttsahin.navguard/gnss_anchor',
  );
  messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
    return switch (call.method) {
      'getGnssAnchorPreflight' => _readyAnchorPreflight(),
      'acquireGnssAnchor' => _validAnchorPayload(),
      _ => fail('Unexpected anchor method: ${call.method}'),
    };
  });
  addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
}

void _installEvaluationMock(List<String> methods) {
  final TestDefaultBinaryMessenger messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const MethodChannel channel = MethodChannel(
    'io.github.mesuttsahin.navguard/evaluation_mode',
  );
  messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
    methods.add(call.method);
    return switch (call.method) {
      'getEvaluationModePreflight' => _readyEvaluationUiPreflight(),
      'runEvaluationModeDiagnostic' => _validEvaluationUiResult(),
      'cancelEvaluationModeDiagnostic' => null,
      _ => fail('Unexpected evaluation method: ${call.method}'),
    };
  });
  addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
}

void _installBenchmarkMock(List<String> methods) {
  final TestDefaultBinaryMessenger messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const MethodChannel channel = MethodChannel(
    'io.github.mesuttsahin.navguard/navguard_benchmark',
  );
  messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
    methods.add(call.method);
    return switch (call.method) {
      'getNavguardBenchmarkPreflight' => _readyBenchmarkUiPreflight(),
      'runNavguardBenchmarkDiagnostic' => _validBenchmarkUiResult(),
      'cancelNavguardBenchmarkDiagnostic' => null,
      _ => fail('Unexpected benchmark method: ${call.method}'),
    };
  });
  addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
}

void _installAccuracyV2Mock(List<String> methods) {
  final TestDefaultBinaryMessenger messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const MethodChannel channel = MethodChannel(
    'io.github.mesuttsahin.navguard/navguard_accuracy_v2',
  );
  messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
    methods.add(call.method);
    return switch (call.method) {
      'getAccuracyV2Preflight' => _readyAccuracyV2UiPreflight(),
      'getCalibrationProfile' => _accuracyV2UiProfile(),
      'runAccuracyV2Calibration' => _accuracyV2UiCalibration(),
      'runAccuracyV2DevelopmentBenchmark' => _accuracyV2UiBenchmark(),
      'getAccuracyV2OperationStatus' => <String, Object?>{
        'schemaVersion': 1,
        'snapshotKind': 'navguard_accuracy_v2_operation_status',
        'phase': 'BENCHMARK_FORMAL_WINDOW',
        'finalDrainRemainingSeconds': null,
      },
      'resetAccuracyV2Calibration' => _accuracyV2UiProfile(),
      _ => fail('Unexpected Accuracy v2 method: ${call.method}'),
    };
  });
  addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
}

Future<void> _openEvaluationResult(WidgetTester tester) async {
  await tester.pumpWidget(
    NavguardApp(
      liveDemoPlatform: _WidgetFakeLivePlatform(),
      aiPlatform: _WidgetFakeAiPlatform(),
      enableLiveMapTiles: false,
    ),
  );
  await _lockNavigationAnchor(tester);
  final Finder module = find.byKey(const Key('module-card-evaluationGtf'));
  await tester.ensureVisible(module);
  await tester.tap(module);
  await tester.pumpAndSettle();
  await _tapVisible(tester, const Key('evaluation-preflight-action'));
  await _tapVisible(tester, const Key('evaluation-run-action'));
}

Future<void> _openBenchmarkResult(WidgetTester tester) async {
  await tester.pumpWidget(
    NavguardApp(
      liveDemoPlatform: _WidgetFakeLivePlatform(),
      aiPlatform: _WidgetFakeAiPlatform(),
      enableLiveMapTiles: false,
    ),
  );
  await _lockNavigationAnchor(tester);
  final Finder module = find.byKey(const Key('module-card-benchmarks'));
  await tester.ensureVisible(module);
  await tester.tap(module);
  await tester.pumpAndSettle();
  await _tapVisible(tester, const Key('benchmark-preflight-action'));
  await _tapVisible(tester, const Key('benchmark-run-action'));
}

Future<void> _openAccuracyV2Result(WidgetTester tester) async {
  await tester.pumpWidget(
    NavguardApp(
      liveDemoPlatform: _WidgetFakeLivePlatform(),
      aiPlatform: _WidgetFakeAiPlatform(),
      enableLiveMapTiles: false,
    ),
  );
  await _lockNavigationAnchor(tester);
  final Finder module = find.byKey(const Key('module-card-accuracyV2'));
  await tester.ensureVisible(module);
  await tester.tap(module);
  await tester.pumpAndSettle();
  await _tapVisible(tester, const Key('accuracy-v2-refresh'));
  await _tapVisible(tester, const Key('accuracy-v2-calibration'));

  final Finder scenario = find.byKey(
    const Key('accuracy-v2-development-scenario'),
  );
  await tester.ensureVisible(scenario);
  await tester.tap(scenario);
  await tester.pumpAndSettle();
  await tester.tap(find.text('L_TURN').last);
  await tester.pumpAndSettle();
  await _tapVisible(tester, const Key('accuracy-v2-development-benchmark'));
}

Map<String, Object?> _readyEvaluationUiPreflight() => <String, Object?>{
  'schemaVersion': 1,
  'snapshotKind': 'evaluation_mode_preflight',
  'gpsProviderAvailable': true,
  'gpsProviderEnabled': true,
  'fineLocationPermissionGranted': true,
  'rotationVectorAvailable': true,
  'rotationVectorName': 'Rotation Vector Non-wakeup',
  'stepDetectorAvailable': true,
  'stepDetectorName': 'Step Detector Non-wakeup',
  'activityRecognitionPermissionRequired': true,
  'activityRecognitionPermissionGranted': true,
  'firewallMutationSelfTestPassed': true,
  'diagnosticRunning': false,
  'nativeReady': true,
};

Map<String, Object?> _validEvaluationUiResult() => <String, Object?>{
  'schemaVersion': 1,
  'snapshotKind': 'evaluation_mode_diagnostic_result',
  'success': true,
  'evaluationWindowMs': 30000,
  'protectedGtFirstFixTimeoutMs': 15000,
  'coordinateFrame': 'local_enu',
  'physicalGnssAvailable': true,
  'physicalGnssRole': 'protected_ground_truth_only',
  'evaluationModeImplemented': true,
  'groundTruthFirewallImplemented': true,
  'protectedGroundTruthGnssActive': true,
  'softwareDefinedEstimatorGnssDenial': true,
  'protectedGnssAvailableToEstimatorApi': false,
  'protectedGnssUsedByDeniedEstimator': false,
  'protectedGnssUsedByHeading': false,
  'protectedGnssUsedByStepLength': false,
  'protectedGnssUsedByQualityEngine': false,
  'protectedGnssUsedByController': false,
  'gnssCorrectionApplied': false,
  'firewallMutationSelfTestPassed': true,
  'liveGnssPhysicallyActive': true,
  'liveGnssUsedByDeniedEstimator': false,
  'liveGnssUsedForProtectedGroundTruth': true,
  'protectedGtUpdateCount': 3,
  'acceptedProtectedGtFixCount': 2,
  'invalidProtectedGtFixCount': 0,
  'outOfWindowProtectedGtFixCount': 1,
  'uniqueProtectedGtTimestampCount': 2,
  'duplicateProtectedGtTimestampCount': 0,
  'nonMonotonicProtectedGtTimestampCount': 0,
  'mockProtectedGtFixCount': 0,
  'matchedGroundTruthFixCount': 2,
  'unmatchedGroundTruthFixCount': 0,
  'minReportedGtAccuracyM': null,
  'maxReportedGtAccuracyM': null,
  'meanReportedGtAccuracyM': null,
  'medianReportedGtAccuracyM': null,
  'minHorizontalErrorM': 1.0,
  'maxHorizontalErrorM': 2.0,
  'meanHorizontalErrorM': 1.5,
  'medianHorizontalErrorM': 1.5,
  'p95HorizontalErrorM': 2.0,
  'finalDeniedPreCorrectionErrorM': 2.0,
  'minEstimatorAgeAtGtMs': 10.0,
  'maxEstimatorAgeAtGtMs': 20.0,
  'meanEstimatorAgeAtGtMs': 15.0,
  'medianEstimatorAgeAtGtMs': 15.0,
  'p95EstimatorAgeAtGtMs': 20.0,
  'stepUpdateCount': 0,
  'acceptedStepEventCount': 0,
  'invalidStepEventCount': 0,
  'outOfWindowStepEventCount': 0,
  'uniqueStepTimestampCount': 0,
  'duplicateStepTimestampCount': 0,
  'nonMonotonicStepTimestampCount': 0,
  'associatedStepCount': 0,
  'unassociatedStepCount': 0,
  'integratedStepCount': 0,
  'headingUpdateCount': 2,
  'validHeadingSampleCount': 2,
  'invalidHeadingSampleCount': 0,
  'uniqueHeadingTimestampCount': 2,
  'duplicateHeadingTimestampCount': 0,
  'nonMonotonicHeadingTimestampCount': 0,
  'finalDeniedEastM': 0.0,
  'finalDeniedNorthM': 0.0,
  'finalDeniedHorizontalDisplacementM': 0.0,
  'nominalDeniedIntegratedPathLengthM': 0.0,
  'deniedEstimatorProfile': 'config_a_baseline_pdr',
  'stepSource': 'TYPE_STEP_DETECTOR',
  'headingSource': 'TYPE_ROTATION_VECTOR',
  'headingConvention': 'clockwise_from_north_0_to_2pi',
  'deviceForwardAxis': 'device_positive_y_top_edge',
  'stepLengthModel': 'fixed_baseline',
  'stepLengthM': 0.75,
  'stepLengthCalibrated': false,
  'stepLengthValidated': false,
  'headingAssociationPolicy':
      'latest_valid_heading_at_or_before_step_timestamp',
  'futureHeadingUsed': false,
  'stepTimestampAuthority': 'SensorEvent.timestamp',
  'headingTimestampAuthority': 'SensorEvent.timestamp',
  'protectedGroundTruthTimestampAuthority': 'Location.getElapsedRealtimeNanos',
  'operationWindowClock': 'SystemClock.elapsedRealtimeNanos',
  'elapsedRealtimeSharedTimeBaseUsed': true,
  'gnssSensorElapsedRealtimeComparisonUsed': true,
  'unsupportedCrossClockComparisonUsed': false,
  'baselinePdrAccuracyValidated': false,
  'stepDetectionAccuracyValidated': false,
  'headingAccuracyValidated': false,
  'trueNorthAccuracyValidated': false,
  'protectedGnssGroundTruthAccuracyValidated': false,
  'qualityEngineImplemented': false,
  'ekfImplemented': false,
  'pdrArcoreFusionImplemented': false,
  'gnssRecoveryImplemented': false,
  'fullGnssDeniedNavigationImplemented': false,
  'rawGroundTruthTrajectoryReturned': false,
  'rawDeniedTrajectoryReturned': false,
  'rawGnssCoordinatesReturned': false,
  'rawTimestampsReturned': false,
  'persistenceUsed': false,
};

Map<String, Object?> _readyBenchmarkUiPreflight() => <String, Object?>{
  'schemaVersion': 1,
  'snapshotKind': 'navguard_benchmark_preflight',
  'gpsProviderAvailable': true,
  'gpsProviderEnabled': true,
  'fineLocationPermissionGranted': true,
  'rotationVectorAvailable': true,
  'stepDetectorAvailable': true,
  'activityRecognitionPermissionGranted': true,
  'arCoreSupported': true,
  'arCoreInstalled': true,
  'cameraPermissionGranted': true,
  'diagnosticRunning': false,
  'nativeReady': true,
  'currentPhase': 'IDLE',
};

Map<String, Object?> _validBenchmarkUiResult() {
  Map<String, Object?> metrics(String id, double median) => <String, Object?>{
    'configId': id,
    'matchedGtCount': 1,
    'unmatchedGtCount': 1,
    'meanHorizontalErrorM': median,
    'medianHorizontalErrorM': median,
    'p95HorizontalErrorM': median,
    'maxHorizontalErrorM': median,
    'finalPreCorrectionHorizontalErrorM': median,
    'finalEastM': 1,
    'finalNorthM': 2,
  };

  return <String, Object?>{
    'schemaVersion': 1,
    'snapshotKind': 'navguard_benchmark_diagnostic_result',
    'success': true,
    'benchmarkSessionValid': true,
    'benchmarkDeniedWindowMs': 30000,
    'primaryMetric': 'matched_session_median_horizontal_error_m',
    'primaryComparison': 'config_d_vs_config_a',
    'percentilePolicy': 'nearest_rank',
    'matchedSessionBenchmarkImplemented': true,
    'configAImplemented': true,
    'configBImplemented': true,
    'configCImplemented': true,
    'configDImplemented': true,
    'protectedGroundTruthCollectorImplemented': true,
    'benchmarkComparatorImplemented': true,
    'benchmarkGroundTruthMutationInvariancePassed': true,
    'benchmarkGroundTruthRemovalInvariancePassed': true,
    'captureOnceReplayManyUsed': true,
    'identicalDenialOriginUsed': true,
    'initialDenialSnapshotUsed': true,
    'causalGroundTruthMatchingUsed': true,
    'josephCovarianceUpdateUsed': true,
    'circularHeadingInnovationUsed': true,
    'protectedGroundTruthAvailableToEstimators': false,
    'protectedGroundTruthUsedByConfigA': false,
    'protectedGroundTruthUsedByConfigB': false,
    'protectedGroundTruthUsedByConfigC': false,
    'protectedGroundTruthUsedByConfigD': false,
    'protectedGroundTruthUsedByQualityEngine': false,
    'groundTruthCorrectionApplied': false,
    'gnssRecoveryAppliedDuringBenchmark': false,
    'futureEstimatorStateUsedForGroundTruthMatch': false,
    'groundTruthInterpolationUsed': false,
    'arcoreFrameTimestampUsedForFusionOrdering': false,
    'benchmarkAccuracyValidated': false,
    'protectedGroundTruthAccuracyValidated': false,
    'stepDetectionAccuracyValidated': false,
    'stepLengthValidated': false,
    'headingAccuracyValidated': false,
    'arcorePositionAccuracyValidated': false,
    'noiseParametersValidated': false,
    'qualityThresholdsValidated': false,
    'rawGnssCoordinatesReturned': false,
    'rawProtectedGroundTruthReturned': false,
    'rawSensorSamplesReturned': false,
    'rawArcorePosesReturned': false,
    'rawTrajectoryReturned': false,
    'rawTimestampsReturned': false,
    'cameraImagesReturned': false,
    'persistenceUsed': false,
    'protectedGroundTruthAcceptedFixCount': 2,
    'configA': metrics('config_a_deterministic_pdr', 10),
    'configB': metrics('config_b_pdr_heading_ekf', 8),
    'configC': metrics('config_c_arcore_relative', 9),
    'configD': metrics('config_d_navguard_ekf_v1', 7),
    'dVsAMedianImprovementPercent': 30,
    'bVsAMedianImprovementPercent': 20,
    'cVsAMedianImprovementPercent': 10,
    'dVsBMedianImprovementPercent': 12.5,
    'dVsCMedianImprovementPercent': 22.22222222222222,
    'targetImprovementPercent': 20,
    'dVsATargetMet': true,
    'protectedGtReportedAccuracyMinM': 10,
    'protectedGtReportedAccuracyMeanM': 12,
    'protectedGtReportedAccuracyMedianM': 12,
    'protectedGtReportedAccuracyMaxM': 14,
    'configAStepOpportunities': 1,
    'configAStepsApplied': 1,
    'configAStepsSkippedNoHeading': 0,
    'configBStepPredictionsApplied': 1,
    'configBHeadingMeasurementsApplied': 1,
    'configBHeadingMeasurementsSkipped': 0,
    'configCArcoreMeasurementsApplied': 1,
    'configCArcoreMeasurementsSkipped': 0,
    'configDStepPredictionsApplied': 1,
    'configDHeadingMeasurementsApplied': 1,
    'configDArcoreMeasurementsApplied': 1,
    'configDStepPredictionsSkippedByQuality': 0,
    'configDHeadingMeasurementsSkippedByQuality': 0,
    'configDArcoreMeasurementsSkippedByQuality': 0,
  };
}

Map<String, bool> _accuracyV2UiSelfTests() => <String, bool>{
  'robustGnssOrigin': true,
  'smallGnssCandidateFallback': true,
  'dynamicStride': true,
  'strideBounds': true,
  'degradedStrideFreeze': true,
  'headingOffsetCalibration': true,
  'headingOffsetBounds': true,
  'headingOffsetTurnProtection': true,
  'headingCircularInnovation': true,
  'headingTurnProtection': true,
  'headingOutlierRejection': true,
  'nisFinite': true,
  'nisKnownCase': true,
  'nisUnsafeRejectedSafely': true,
  'arcoreConsistentAccepted': true,
  'arcoreSoftInflation': true,
  'arcoreHardRejection': true,
  'arcoreModerateRobustUpdate': true,
  'arcoreExtremeHardRejection': true,
  'arcorePostRobustRecovery': true,
  'arcorePostRobustExtremeRejection': true,
  'arcoreTurnAwareRobustUpdate': true,
  'stationaryDetection': true,
  'stationaryDriftSuppression': true,
  'stationaryExitOnStep': true,
  'stationaryExitOnTurn': true,
  'stationaryReplayActivation': true,
  'stationaryDelayedStepEventTime': true,
  'stationaryCandidateDiagnostics': true,
  'stationaryDelayedStepExit': true,
  'syntheticAgreementRegression': true,
  'syntheticArcoreOutlierImprovement': true,
  'syntheticStationaryDriftSuppression': true,
  'syntheticRobustV2Regression': true,
  'syntheticVariableStride': true,
  'gtMutationInvariant': true,
  'gtRemovalInvariant': true,
  'profileRestartReload': true,
  'profileResetPersistence': true,
  'profileCorruptionFallback': true,
  'calibrationDelayedCallbacks': true,
  'calibrationHistoricalPhaseAssignment': true,
  'calibrationHistoryBound': true,
  'calibrationDuplicateSuppression': true,
  'calibrationNoFutureHeading': true,
  'calibrationDrainLearningSuppressed': true,
  'benchmarkDelayedInWindowCallback': true,
  'benchmarkPostWindowExclusion': true,
  'benchmarkMultipleDelayedCallbacks': true,
  'benchmarkGtWindowBounded': true,
  'benchmarkFairStepInput': true,
  'relativeConstantOffsetRemoved': true,
  'relativeCausalMatching': true,
  'relativeGtFirewall': true,
  'gnssTargetStabilization': true,
  'gnssDegradedStabilization': true,
  'gnssInsufficientFailure': true,
  'gnssAccuracyRejectionAccounting': true,
  'gnssRobustMedianOrigin': true,
};

Map<String, Object?> _readyAccuracyV2UiPreflight() => <String, Object?>{
  'schemaVersion': 1,
  'snapshotKind': 'navguard_accuracy_v2_preflight',
  'configId': 'config_d_v2_adaptive_navguard',
  'fineLocationPermissionGranted': true,
  'gpsProviderAvailable': true,
  'gpsProviderEnabled': true,
  'rotationVectorAvailable': true,
  'stepDetectorAvailable': true,
  'activityRecognitionPermissionGranted': true,
  'arCoreSupported': true,
  'arCoreInstalled': true,
  'cameraPermissionGranted': true,
  'anchorAvailable': true,
  'nativeReady': true,
  'operationBusy': false,
  'selfTests': _accuracyV2UiSelfTests(),
  'selfTestsPassed': true,
  'developmentOnly': true,
  'accuracyValidated': false,
  'aiModelImplemented': false,
};

Map<String, Object?> _accuracyV2UiProfile() => <String, Object?>{
  'schemaVersion': 1,
  'snapshotKind': 'navguard_accuracy_v2_calibration_profile',
  'configId': 'config_d_v2_adaptive_navguard',
  'strideEstimateM': 0.78,
  'bodyHeadingOffsetRad': -0.06981317007977318,
  'bodyHeadingOffsetDeg': -4.0,
  'strideSampleCount': 3,
  'headingOffsetSampleCount': 2,
  'profilePersistence': 'android_shared_preferences',
  'profilePersisted': true,
  'rawLocationPersisted': false,
  'rawSensorPersisted': false,
  'rawArcorePosePersisted': false,
  'rawTrajectoryPersisted': false,
  'cloudUploadEnabled': false,
  'telemetryEnabled': false,
};

Map<String, Object?> _accuracyV2UiCalibration() => <String, Object?>{
  'schemaVersion': 1,
  'snapshotKind': 'navguard_accuracy_v2_calibration_result',
  'configId': 'config_d_v2_adaptive_navguard',
  'sessionLabel': 'DEVELOPMENT_CALIBRATION_SESSION',
  'stationaryDetected': true,
  'stationaryCurrentlyDetected': false,
  'stationaryEverDetected': true,
  'stationaryEntryCount': 2,
  'stationaryDetectedDurationMs': 9000,
  'stationaryCandidateCount': 3,
  'stationaryBlockedRecentStepCount': 7,
  'stationaryBlockedHeadingMotionCount': 4,
  'stationaryBlockedArcoreMotionCount': 5,
  'stationaryBlockedOtherMotionCount': 0,
  'stationaryDriftM': 0.08,
  'stepsReceived': 24,
  'stepsApplied': 24,
  'finalDrainDurationMs': 12000,
  'stepsReceivedDuringFinalDrainCallbackDelivery': 7,
  'strideEstimateBeforeM': 0.75,
  'strideEstimateAfterM': 0.78,
  'strideCalibrationSamples': 3,
  'headingOffsetBeforeDeg': 0.0,
  'headingOffsetAfterDeg': -4.0,
  'headingOffsetSamples': 2,
  'arcoreAccepted': 100,
  'arcoreRejected': 3,
  'arcoreNisMean': 1.2,
  'arcoreNisMax': 8.5,
  'arcorePreRobustNisMean': 12.0,
  'arcorePreRobustNisMax': 40.0,
  'arcorePostRobustNisMean': 6.0,
  'arcorePostRobustNisMax': 20.0,
  'arcoreAcceptedAfterRobustInflationCount': 30,
  'arcoreRejectedAfterMaxInflationCount': 1,
  'headingAccepted': 200,
  'headingRejected': 1,
  'sourceDisagreementMeanM': 0.4,
  'sourceDisagreementMaxM': 2.2,
  'profilePersisted': true,
  'profilePersistence': 'android_shared_preferences',
  'rawLocationReturned': false,
  'rawSensorStreamReturned': false,
  'rawArcorePoseReturned': false,
  'rawTimestampsReturned': false,
  'rawTrajectoryReturned': false,
  'accuracyValidated': false,
};

Map<String, Object?> _accuracyV2UiMetrics(String id, double median) =>
    <String, Object?>{
      'configId': id,
      'matchedGtCount': 30,
      'meanHorizontalErrorM': median + 0.5,
      'medianHorizontalErrorM': median,
      'p95HorizontalErrorM': median + 1.0,
      'maxHorizontalErrorM': median + 1.5,
      'finalPreCorrectionHorizontalErrorM': median + 0.25,
      'relativeMeanHorizontalErrorM': 1.5,
      'relativeMedianHorizontalErrorM': 1.0,
      'relativeP95HorizontalErrorM': 2.0,
      'relativeMaxHorizontalErrorM': 2.5,
      'relativeFinalHorizontalErrorM': 1.25,
    };

Map<String, Object?> _accuracyV2UiBenchmark() => <String, Object?>{
  'schemaVersion': 1,
  'snapshotKind': 'navguard_accuracy_v2_development_benchmark_result',
  'sessionLabel': 'DEVELOPMENT_SESSION_NOT_FINAL_VALIDATION',
  'developmentScenario': 'L_TURN',
  'sameSessionCapture': true,
  'eventOrdering': 'HEADING_STEP_ARCORE_POSITION_INSERTION_SEQUENCE',
  'developmentBenchmarkFinalDrainMs': 12000,
  'benchmarkStepEventsReceivedTotal': 14,
  'benchmarkStepEventsInFormalWindow': 12,
  'benchmarkStepEventsDeliveredDuringFinalDrain': 4,
  'benchmarkStepEventsIncludedFromFinalDrain': 3,
  'benchmarkStepEventsExcludedPostWindow': 1,
  'configAStepsApplied': 12,
  'configD1StepsApplied': 12,
  'configD2StepsApplied': 12,
  'configA': _accuracyV2UiMetrics('config_a_deterministic_pdr', 9.0),
  'configD1': _accuracyV2UiMetrics('config_d_navguard_ekf_v1', 8.0),
  'configD2': _accuracyV2UiMetrics('config_d_v2_adaptive_navguard', 7.0),
  'd2VsD1MedianImprovementPercent': 12.5,
  'd2VsAMedianImprovementPercent': 22.222222222,
  'd2VsD1RelativeMedianImprovementPercent': 10.0,
  'd2VsARelativeMedianImprovementPercent': 20.0,
  'configAInitialMatchedBiasM': 10.0,
  'configD1InitialMatchedBiasM': 9.0,
  'configD2InitialMatchedBiasM': 8.5,
  'strideEstimateFinalM': 0.78,
  'strideEstimateMeanM': 0.77,
  'strideCalibrationSampleCount': 3,
  'bodyHeadingOffsetFinalDeg': -4.0,
  'arcoreAcceptedCount': 100,
  'arcoreAcceptedNominalCount': 70,
  'arcoreAcceptedInflatedCount': 30,
  'arcoreRejectedByQualityCount': 2,
  'arcoreRejectedByInnovationCount': 1,
  'arcoreAcceptedAfterRobustInflationCount': 30,
  'arcoreRejectedAfterMaxInflationCount': 1,
  'arcorePreRobustNisMean': 12.0,
  'arcorePreRobustNisMax': 40.0,
  'arcorePostRobustNisMean': 6.0,
  'arcorePostRobustNisMax': 20.0,
  'arcoreAdaptiveSigmaMeanM': 0.75,
  'arcoreAdaptiveSigmaMaxM': 2.0,
  'arcoreRobustSigmaMeanM': 0.75,
  'arcoreRobustSigmaMaxM': 2.0,
  'headingAcceptedCount': 200,
  'headingRejectedCount': 1,
  'stationaryDetectedDurationMs': 6000,
  'stationaryEntryCount': 1,
  'stationaryCandidateCount': 2,
  'stationaryBlockedRecentStepCount': 10,
  'stationaryBlockedHeadingMotionCount': 5,
  'stationaryBlockedArcoreMotionCount': 7,
  'stationaryBlockedOtherMotionCount': 0,
  'stationaryArcoreSuppressedCount': 12,
  'sourceDisagreementMeanM': 0.4,
  'sourceDisagreementMaxM': 2.2,
  'gnssStabilizationFixCount': 8,
  'gnssStabilizationReceivedFixCount': 13,
  'gnssStabilizationAcceptedFixCount': 8,
  'gnssStabilizationRejectedStructuralCount': 1,
  'gnssStabilizationRejectedAccuracyCount': 2,
  'gnssStabilizationRejectedMockCount': 1,
  'gnssStabilizationRejectedNonMonotonicCount': 1,
  'gnssStabilizationReportedAccuracyMinM': 4.0,
  'gnssStabilizationReportedAccuracyMaxM': 60.0,
  'gnssStabilizationObservedDurationMs': 7000,
  'gnssStabilizationTargetFixCount': 5,
  'gnssStabilizationMinimumFixCount': 3,
  'gnssStabilizationDegraded': false,
  'gnssStabilizationReason': 'target_met',
  'gnssStabilizationEastSpreadM': 2.0,
  'gnssStabilizationNorthSpreadM': 1.5,
  'gnssStabilizationHorizontalSpreadM': 2.5,
  'gnssStabilizationReportedAccuracyMedianM': 6.0,
  'protectedGtEstimatorAccessCount': 0,
  'gtMutationInvariant': true,
  'gtRemovalInvariant': true,
  'protectedGroundTruthComparatorOnly': true,
  'rawLocationReturned': false,
  'rawSensorStreamReturned': false,
  'rawArcorePoseReturned': false,
  'rawTimestampsReturned': false,
  'rawTrajectoryReturned': false,
  'developmentMetricsOnly': true,
  'finalValidation': false,
  'accuracyValidated': false,
};

Map<String, Object?> _readyHeadingPreflight() => <String, Object?>{
  'schemaVersion': 1,
  'snapshotKind': 'heading_foundation_preflight',
  'rotationVectorAvailable': true,
  'rotationVectorName': 'Synthetic Rotation Vector',
  'requestedSamplingPeriodUs': 20000,
  'diagnosticRunning': false,
};

Map<String, Object?> _validHeadingUiResult() => <String, Object?>{
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

Map<String, Object?> _readyStepPreflight() => <String, Object?>{
  'schemaVersion': 1,
  'snapshotKind': 'step_event_preflight',
  'stepDetectorAvailable': true,
  'stepDetectorName': 'Synthetic Step Detector',
  'activityRecognitionPermissionRequired': true,
  'activityRecognitionPermissionGranted': true,
  'diagnosticRunning': false,
  'canRunStepDiagnostic': true,
};

Map<String, Object?> _validStepUiResult() => <String, Object?>{
  'schemaVersion': 1,
  'snapshotKind': 'step_event_diagnostic_result',
  'success': true,
  'sensorType': 'TYPE_STEP_DETECTOR',
  'sensorName': 'Synthetic Step Detector',
  'sessionDurationMs': 30000,
  'stepTimestampAuthority': 'SensorEvent.timestamp',
  'operationWindowClock': 'SystemClock.elapsedRealtimeNanos',
  'wallClockUsedForStepTiming': false,
  'updateCount': 3,
  'acceptedStepEventCount': 3,
  'invalidStepEventCount': 0,
  'outOfWindowStepEventCount': 0,
  'uniqueTimestampCount': 3,
  'duplicateTimestampCount': 0,
  'nonMonotonicTimestampCount': 0,
  'deltaCount': 2,
  'minStepIntervalMs': 500.0,
  'maxStepIntervalMs': 700.0,
  'meanStepIntervalMs': 600.0,
  'medianStepIntervalMs': 600.0,
  'p95StepIntervalMs': 700.0,
  'observedCadenceStepsPerMinute': 100.0,
  'stepDetectionAccuracyValidated': false,
  'stepLengthImplemented': false,
  'pdrPositionImplemented': false,
  'rawStepEventsReturned': false,
  'rawSensorSamplesReturned': false,
  'persistenceUsed': false,
};

Map<String, Object?> _readyBaselinePdrPreflight() => <String, Object?>{
  'schemaVersion': 1,
  'snapshotKind': 'baseline_pdr_preflight',
  'rotationVectorAvailable': true,
  'rotationVectorName': 'Rotation Vector Non-wakeup',
  'stepDetectorAvailable': true,
  'stepDetectorName': 'Synthetic Step Detector',
  'activityRecognitionPermissionRequired': true,
  'activityRecognitionPermissionGranted': true,
  'diagnosticRunning': false,
  'nativeSensorsReady': true,
};

Map<String, Object?> _validBaselinePdrUiResult() => <String, Object?>{
  'schemaVersion': 1,
  'snapshotKind': 'baseline_pdr_diagnostic_result',
  'success': true,
  'sessionDurationMs': 30000,
  'coordinateFrame': 'local_enu',
  'headingConvention': 'clockwise_from_north_0_to_2pi',
  'deviceForwardAxis': 'device_positive_y_top_edge',
  'stepSource': 'TYPE_STEP_DETECTOR',
  'headingSource': 'TYPE_ROTATION_VECTOR',
  'stepSensorName': 'Synthetic Step Detector',
  'headingSensorName': 'Rotation Vector Non-wakeup',
  'stepTimestampAuthority': 'SensorEvent.timestamp',
  'headingTimestampAuthority': 'SensorEvent.timestamp',
  'operationWindowClock': 'SystemClock.elapsedRealtimeNanos',
  'wallClockUsedForSensorTiming': false,
  'headingAssociationPolicy':
      'latest_valid_heading_at_or_before_step_timestamp',
  'futureHeadingUsed': false,
  'stepUpdateCount': 2,
  'acceptedStepEventCount': 2,
  'invalidStepEventCount': 0,
  'outOfWindowStepEventCount': 0,
  'uniqueStepTimestampCount': 2,
  'duplicateStepTimestampCount': 0,
  'nonMonotonicStepTimestampCount': 0,
  'associatedStepCount': 2,
  'unassociatedStepCount': 0,
  'integratedStepCount': 2,
  'headingUpdateCount': 2,
  'validHeadingSampleCount': 2,
  'invalidHeadingSampleCount': 0,
  'uniqueHeadingTimestampCount': 2,
  'duplicateHeadingTimestampCount': 0,
  'nonMonotonicHeadingTimestampCount': 0,
  'minHeadingAssociationAgeMs': 0.0,
  'maxHeadingAssociationAgeMs': 20.0,
  'meanHeadingAssociationAgeMs': 10.0,
  'medianHeadingAssociationAgeMs': 10.0,
  'p95HeadingAssociationAgeMs': 20.0,
  'stepLengthModel': 'fixed_baseline',
  'stepLengthM': 0.75,
  'stepLengthCalibrated': false,
  'stepLengthValidated': false,
  'originEastM': 0.0,
  'originNorthM': 0.0,
  'finalEastM': 0.0,
  'finalNorthM': 1.5,
  'netDisplacementM': 1.5,
  'nominalIntegratedPathLengthM': 1.5,
  'declinationRad': 0.1,
  'declinationProvider': 'android.hardware.GeomagneticField',
  'declinationModelVersion': 'platform_managed',
  'declinationModelFreshnessValidated': false,
  'declinationAltitudeSource': 'anchor_ellipsoid_altitude',
  'pdrPositionImplemented': true,
  'stepDetectionAccuracyValidated': false,
  'headingAccuracyValidated': false,
  'trueNorthAccuracyValidated': false,
  'distanceAccuracyValidated': false,
  'bodyHeadingImplemented': false,
  'arCoreFusionImplemented': false,
  'qualityEngineImplemented': false,
  'ekfImplemented': false,
  'groundTruthFirewallImplemented': false,
  'gnssDeniedNavigationImplemented': false,
  'rawTrajectoryReturned': false,
  'rawSensorSamplesReturned': false,
  'rawTimestampsReturned': false,
  'persistenceUsed': false,
  'anchorUsedForDeclination': true,
  'liveGnssUsed': false,
};

Map<String, Object?> _readyArCorePreflight() => <String, Object?>{
  'schemaVersion': 1,
  'snapshotKind': 'arcore_diagnostic_preflight',
  'cameraPermissionGranted': true,
  'availabilityRaw': 'SUPPORTED_INSTALLED',
  'availabilityCategory': 'ready',
  'arCoreSupported': true,
  'arCoreInstalledAndCurrent': true,
  'canRunFormalDiagnostic': true,
};

Map<String, Object?> _readyArCorePermissionResult() => <String, Object?>{
  ..._readyArCorePreflight(),
  'snapshotKind': 'arcore_camera_permission_result',
  'requestOutcome': 'already_granted',
};

Map<String, Object?> _validArCoreTrackingUiResult() => <String, Object?>{
  'schemaVersion': 1,
  'snapshotKind': 'arcore_runtime_tracking_diagnostic',
  'status': 'completed',
  'completionReason': 'measurement_window_completed',
  'validTrackingSummary': true,
  'cameraPermissionGranted': true,
  'availabilityRaw': 'SUPPORTED_INSTALLED',
  'availabilityCategory': 'ready',
  'arCoreSupported': true,
  'arCoreInstalledAndCurrent': true,
  'sessionCreationSucceeded': true,
  'sessionConfigurationSucceeded': true,
  'sessionResumeSucceeded': true,
  'glInitializationSucceeded': true,
  'cameraTextureSetupSucceeded': true,
  'trackingAcquisitionTimeoutMs': 30000,
  'trackingCollectionDurationTargetMs': 30000,
  'timestampSource': 'Frame.timestamp',
  'timestampDomain': 'arcore_frame_timebase_undefined',
  'frameGapThresholdApplied': false,
  'sessionUpdateCallCount': 120,
  'uniqueFrameCount': 120,
  'deltaCount': 119,
  'durationNs': 3966666667,
  'minDeltaNs': 30000000,
  'maxDeltaNs': 40000000,
  'meanDeltaNs': 33333333.0,
  'medianDeltaNs': 33000000,
  'p95DeltaNs': 40000000,
  'meanUniqueFrameRateHz': 30.0,
  'medianIntervalDerivedHz': 30.3,
  'nonMonotonicTimestampCount': 0,
  'duplicateFrameTimestampCount': 0,
  'trackingFrameCount': 90,
  'pausedFrameCount': 30,
  'stoppedFrameCount': 0,
  'firstTrackingFrameTimestampNs': 1000000000,
  'lastTrackingFrameTimestampNs': 4966666667,
  'trackingTransitionCount': 2,
  'trackingFraction': 0.75,
  'trackingFailureReasonCounts': <String, int>{},
  'trackingPoseSampleCount': 90,
  'firstTrackingPoseAvailable': true,
  'lastTrackingPoseAvailable': true,
  'netSessionRelativeTranslationM': 1.25,
  'maxDisplacementFromFirstTrackingPoseM': 1.5,
  'poseCoordinateFrame': 'arcore_local_session_coordinates',
  'rawCameraFramesPersisted': false,
  'rawPoseTrajectoryPersisted': false,
  'terminalSessionError': null,
};

Map<String, Object?> _readyArCoreEnuPreflight() => <String, Object?>{
  'schemaVersion': 1,
  'snapshotKind': 'arcore_enu_preflight',
  'arCoreSupported': true,
  'arCoreInstalled': true,
  'cameraPermissionGranted': true,
  'rotationVectorAvailable': true,
  'rotationVectorName': 'Rotation Vector',
  'diagnosticRunning': false,
  'nativeReady': true,
};

Map<String, Object?> _validArCoreEnuUiResult() => <String, Object?>{
  'schemaVersion': 1,
  'snapshotKind': 'arcore_enu_diagnostic_result',
  'success': true,
  'alignmentHoldMs': 2000,
  'measurementWindowMs': 30000,
  'coordinateFrame': 'local_enu',
  'arcorePoseSource': 'Frame.getAndroidSensorPose',
  'referenceStrategy': 'local_arcore_anchor',
  'relativePoseStrategy': 'anchor_inverse_compose_android_sensor_pose',
  'enuAlignmentSource': 'rotation_vector_plus_geomagnetic_declination',
  'rotationVectorSource': 'TYPE_ROTATION_VECTOR',
  'rotationVectorTimestampAuthority': 'SensorEvent.timestamp',
  'arFrameTimestampAuthority': 'Frame.getTimestamp',
  'arFrameTimestampTimeBase': 'undefined_by_arcore_api',
  'operationWindowClock': 'SystemClock.elapsedRealtimeNanos',
  'crossClockTimestampComparisonUsed': false,
  'alignmentCompleted': true,
  'alignmentStationarityAssumed': true,
  'alignmentStationarityValidated': false,
  'trueNorthAlignmentUsed': true,
  'anchorUsedForDeclination': true,
  'liveGnssUsed': false,
  'declinationRad': 0.1,
  'declinationProvider': 'android.hardware.GeomagneticField',
  'declinationModelVersion': 'platform_managed',
  'declinationModelFreshnessValidated': false,
  'declinationAltitudeSource': 'anchor_ellipsoid_altitude',
  'rotationVectorUpdateCount': 5,
  'validRotationVectorSampleCount': 5,
  'invalidRotationVectorSampleCount': 0,
  'uniqueRotationVectorTimestampCount': 5,
  'duplicateRotationVectorTimestampCount': 0,
  'nonMonotonicRotationVectorTimestampCount': 0,
  'arFrameUpdateCount': 4,
  'trackingFrameCount': 3,
  'pausedFrameCount': 1,
  'stoppedFrameCount': 0,
  'usableEnuFrameCount': 3,
  'uniqueArFrameTimestampCount': 4,
  'duplicateArFrameTimestampCount': 0,
  'nonMonotonicArFrameTimestampCount': 0,
  'deltaCount': 3,
  'minFrameDeltaMs': 30.0,
  'maxFrameDeltaMs': 40.0,
  'meanFrameDeltaMs': 33.0,
  'medianFrameDeltaMs': 32.0,
  'p95FrameDeltaMs': 40.0,
  'observedTrackingFrameRateHz': 1000.0 / 33.0,
  'trackingFraction': 0.75,
  'trackingFractionDenominator': 'arFrameUpdateCount_formal_window',
  'finalEastM': 3.0,
  'finalNorthM': 4.0,
  'finalUpM': 12.0,
  'finalHorizontalDisplacementM': 5.0,
  'final3dDisplacementM': 13.0,
  'maxHorizontalDisplacementM': 6.0,
  'maxAbsUpM': 12.0,
  'arcoreRelativeMotionImplemented': true,
  'arcoreToEnuImplemented': true,
  'arcorePositionAccuracyValidated': false,
  'arcoreDistanceAccuracyValidated': false,
  'enuAlignmentAccuracyValidated': false,
  'headingAccuracyValidated': false,
  'trueNorthAccuracyValidated': false,
  'pdrFusionImplemented': false,
  'qualityEngineImplemented': false,
  'ekfImplemented': false,
  'groundTruthFirewallImplemented': false,
  'gnssDeniedNavigationImplemented': false,
  'rawTrajectoryReturned': false,
  'rawArcorePosesReturned': false,
  'rawRotationVectorSamplesReturned': false,
  'rawTimestampsReturned': false,
  'cameraImagesReturned': false,
  'persistenceUsed': false,
  'pathLengthCalculated': false,
  'displayRotationRemappingUsed': false,
  'cameraOpticalForwardUsed': false,
  'geospatialApiUsed': false,
  'cloudServiceUsed': false,
};

Map<String, Object?> _readyFusionPreflight() => <String, Object?>{
  'schemaVersion': 1,
  'snapshotKind': 'navguard_fusion_preflight',
  'arCoreSupported': true,
  'arCoreInstalled': true,
  'cameraPermissionGranted': true,
  'rotationVectorAvailable': true,
  'rotationVectorName': 'Synthetic Rotation Vector',
  'stepDetectorAvailable': true,
  'stepDetectorName': 'Synthetic Step Detector',
  'activityRecognitionPermissionGranted': true,
  'diagnosticRunning': false,
  'nativeReady': true,
};

Map<String, Object?> _validFusionUiResult() => <String, Object?>{
  'schemaVersion': 1,
  'snapshotKind': 'navguard_fusion_diagnostic_result',
  'success': true,
  'fusionWindowMs': 30000,
  'alignmentHoldMs': 2000,
  'alignmentAcquisitionTimeoutMs': 15000,
  'coordinateFrame': 'local_enu',
  'estimatorProfile': 'config_d_navguard_ekf_v1',
  'alignmentCompleted': true,
  'alignmentStationarityAssumed': true,
  'alignmentStationarityValidated': false,
  'headingConvention': 'clockwise_from_north_0_to_2pi',
  'arcorePoseSource': 'Frame.getAndroidSensorPose',
  'referenceStrategy': 'local_arcore_anchor',
  'relativePoseStrategy': 'anchor_inverse_compose_android_sensor_pose',
  'headingTimestampAuthority': 'SensorEvent.timestamp',
  'stepTimestampAuthority': 'SensorEvent.timestamp',
  'arcoreFrameTimestampAuthority': 'Frame.getTimestamp',
  'arcoreFrameTimestampTimeBase': 'undefined_by_arcore_api',
  'operationWindowClock': 'SystemClock.elapsedRealtimeNanos',
  'qualityEngineImplemented': true,
  'ekfImplemented': true,
  'pdrArcoreFusionImplemented': true,
  'fusionStateDimension': 3,
  'fusionStateDefinition': 'E,N,heading',
  'josephCovarianceUpdateUsed': true,
  'circularHeadingInnovationUsed': true,
  'configDImplemented': true,
  'arcoreFrameTimestampUsedForFusionOrdering': false,
  'arcoreFusionOrderingTimestampAuthority': 'SystemClock.elapsedRealtimeNanos',
  'arcoreFusionTimestampSemantics':
      'processing_time_after_frame_update_not_camera_capture_time',
  'elapsedRealtimeFusionOrderingUsed': true,
  'unsupportedCrossClockComparisonUsed': false,
  'deterministicOfflineReplayUsed': true,
  'equalTimestampPriority': 'heading,step,arcore',
  'headingAssociationPolicy':
      'latest_valid_heading_at_or_before_step_timestamp',
  'preDenialAnchorUsedForDeclination': true,
  'declinationProvider': 'android.hardware.GeomagneticField',
  'declinationModelVersion': 'platform_managed',
  'declinationAltitudeSource': 'anchor_ellipsoid_altitude',
  'declinationRad': 0.1,
  'baseStepLengthM': 0.75,
  'baseStepLengthSigmaM': 0.20,
  'baseStepHeadingProcessSigmaRad': 0.08726646259971647,
  'baseHeadingMeasurementSigmaRad': 0.2617993877991494,
  'baseArcorePositionSigmaM': 0.35,
  'protectedGroundTruthAccessed': false,
  'liveGnssRequested': false,
  'fusionAccuracyValidated': false,
  'qualityThresholdsValidated': false,
  'noiseParametersValidated': false,
  'gnssRecoveryImplemented': false,
  'fullGnssDeniedNavigationImplemented': false,
  'rawSensorSamplesReturned': false,
  'rawArcorePosesReturned': false,
  'rawTrajectoryReturned': false,
  'rawTimestampsReturned': false,
  'cameraImagesReturned': false,
  'persistenceUsed': false,
  'stepDetectionAccuracyValidated': false,
  'stepLengthValidated': false,
  'headingAccuracyValidated': false,
  'trueNorthAccuracyValidated': false,
  'arcorePositionAccuracyValidated': false,
  'arcoreDistanceAccuracyValidated': false,
  'finalHeadingQuality': 'GOOD',
  'finalPdrQuality': 'USABLE',
  'finalArcoreQuality': 'USABLE',
  'finalFusionQuality': 'USABLE',
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
  ])
    key: 0,
  'headingMeasurementsApplied': 2,
  'pdrPredictionsApplied': 3,
  'arcoreMeasurementsApplied': 4,
  'finalFusedEastM': 3.0,
  'finalFusedNorthM': 4.0,
  'finalFusedHeadingRad': 0.5,
  'finalFusedHorizontalDisplacementM': 5.0,
  'finalVarianceEastM2': 0.2,
  'finalVarianceNorthM2': 0.3,
  'finalVarianceHeadingRad2': 0.1,
  'finalCovarianceEastNorth': 0.01,
  'finalCovarianceEastHeading': 0.02,
  'finalCovarianceNorthHeading': 0.03,
  'finalPdrEastM': 2.0,
  'finalPdrNorthM': 1.0,
  'finalPdrHorizontalDisplacementM': 2.23606797749979,
  'finalArcoreEastM': 3.1,
  'finalArcoreNorthM': 4.1,
  'finalArcoreHorizontalDisplacementM': 5.140038910358559,
  'meanAbsHeadingInnovationRad': null,
  'medianAbsHeadingInnovationRad': null,
  'maxAbsHeadingInnovationRad': null,
  'meanArcoreInnovationNormM': null,
  'medianArcoreInnovationNormM': null,
  'maxArcoreInnovationNormM': null,
};

Map<String, Object?> _readyFullFlowPreflight() => <String, Object?>{
  'schemaVersion': 1,
  'snapshotKind': 'full_navguard_flow_preflight',
  'gpsProviderAvailable': true,
  'gpsProviderEnabled': true,
  'fineLocationPermissionGranted': true,
  'rotationVectorAvailable': true,
  'stepDetectorAvailable': true,
  'activityRecognitionPermissionGranted': true,
  'arCoreSupported': true,
  'arCoreInstalled': true,
  'cameraPermissionGranted': true,
  'diagnosticRunning': false,
  'nativeReady': true,
  'currentState': 'IDLE',
};

Map<String, Object?> _validFullFlowUiResult() {
  final Map<String, Object?> result = <String, Object?>{
    'schemaVersion': 1,
    'snapshotKind': 'full_navguard_flow_diagnostic_result',
    'success': true,
    'finalState': 'COMPLETED',
    'finalNavigationMode': 'GNSS_RECOVERED',
    'gnssProvider': 'GPS_PROVIDER',
    'gnssTimestampAuthority': 'Location.getElapsedRealtimeNanos',
    'operationClock': 'SystemClock.elapsedRealtimeNanos',
    'headingAssociationPolicy':
        'latest_valid_heading_at_or_before_step_timestamp',
    'maxOperationalGnssAccuracyM': 50.0,
    'recoveryConsecutiveGoodFixesRequired': 3,
    'recoveryConsecutiveGoodFixesAchieved': 3,
    'normalGnssAcceptedFixCount': 4,
    'normalGnssRejectedFixCount': 0,
    'deniedGnssFixCount': 2,
    'deniedGnssRejectedFixCount': 0,
    'deniedGnssUsedByEstimatorCount': 0,
    'recoveryCandidateFixCount': 3,
    'recoveryAcceptedFixCount': 3,
    'recoveryRejectedFixCount': 0,
    'recoveredObservationAcceptedFixCount': 5,
    'recoveredObservationRejectedFixCount': 0,
    'deniedHeadingMeasurementsApplied': 2,
    'deniedHeadingMeasurementsSkippedByQuality': 0,
    'deniedPdrPredictionsApplied': 2,
    'deniedPdrPredictionsSkippedNoHeading': 0,
    'deniedPdrPredictionsSkippedByQuality': 0,
    'deniedAcceptedStepOpportunityCount': 2,
    'deniedArcoreMeasurementsApplied': 2,
    'deniedArcoreMeasurementsSkippedByQuality': 0,
    'stateTransitionCount': 6,
    'normalGnssDurationMs': 5000.0,
    'deniedNavigationDurationMs': 30000.0,
    'recoveryPendingDurationMs': 2000.0,
    'recoveredGnssDurationMs': 5000.0,
    'preRecoveryDeniedEastM': 10.0,
    'preRecoveryDeniedNorthM': 5.0,
    'preRecoveryDeniedHorizontalDisplacementFromDenialOriginM': 2.0,
    'preRecoveryVarianceEastM2': 1.0,
    'preRecoveryVarianceNorthM2': 1.0,
    'preRecoveryVarianceHeadingRad2': 0.2,
    'preRecoveryHeadingQuality': 'GOOD',
    'preRecoveryPdrQuality': 'USABLE',
    'preRecoveryArcoreQuality': 'USABLE',
    'preRecoveryFusionQuality': 'USABLE',
    'recoveredGnssEastM': 12.0,
    'recoveredGnssNorthM': 8.0,
    'recoveryCorrectionDistanceM': 3.605551275463989,
    'finalRecoveredEastM': 12.0,
    'finalRecoveredNorthM': 8.0,
    'finalRecoveredHorizontalFromAnchorM': 14.422205101855956,
    'finalRecoveredHeadingRad': 1.25,
    'finalRecoveredVarianceEastM2': 64.0,
    'finalRecoveredVarianceNorthM2': 64.0,
    'finalRecoveredVarianceHeadingRad2': 0.2,
  };
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
    result[key] = true;
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
    result[key] = false;
  }
  return result;
}

Map<String, Object?> _readyGnssPreflight() => <String, Object?>{
  'schemaVersion': 1,
  'snapshotKind': 'gnss_diagnostic_preflight',
  'preciseLocationGranted': true,
  'coarseLocationGranted': true,
  'gpsProviderAvailable': true,
  'gpsProviderEnabled': true,
  'locationServicesEnabled': true,
  'canRunFormalDiagnostic': true,
};

Map<String, Object?> _validGnssTimingPayload() => <String, Object?>{
  'schemaVersion': 1,
  'snapshotKind': 'gnss_runtime_timing_diagnostic',
  'validTimingSummary': true,
  'provider': 'gps',
  'locationEventCount': 61,
  'meanFixRateHz': 1.0,
  'medianDeltaNs': 1000000000,
  'p95DeltaNs': 1200000000,
  'maxDeltaNs': 1500000000,
  'nonMonotonicTimestampCount': 0,
  'minimumHorizontalAccuracyM': 3.9,
  'medianHorizontalAccuracyM': 4.5,
  'maximumHorizontalAccuracyM': 6.1,
};

Map<String, Object?> _readyAnchorPreflight() => <String, Object?>{
  'schemaVersion': 1,
  'snapshotKind': 'gnss_anchor_preflight',
  'fineLocationPermissionGranted': true,
  'locationServicesEnabled': true,
  'gpsProviderAvailable': true,
  'gpsProviderEnabled': true,
  'acquisitionRunning': false,
  'canAcquireAnchor': true,
};

Map<String, Object?> _validAnchorPayload() => <String, Object?>{
  'schemaVersion': 1,
  'snapshotKind': 'gnss_anchor_acquisition_result',
  'success': true,
  'latitudeDeg': 38.123456789,
  'longitudeDeg': 27.987654321,
  'altitudeEllipsoidM': null,
  'horizontalAccuracyReportedM': 4.8,
  'verticalAccuracyReportedM': null,
  'selectedReportedHorizontalAccuracyM': 4.8,
  'selectedReportedVerticalAccuracyM': null,
  'elapsedRealtimeNanos': 123456789,
  'provider': 'gps',
  'candidateCount': 3,
  'selectionPolicy':
      'lowest_reported_horizontal_accuracy_then_newer_elapsed_realtime',
  'altitudeAvailable': false,
  'coordinateAccuracyValidated': false,
  'selectedCandidateStructurallyValid': true,
  'selectedCandidateMock': false,
  'firstValidFixTimeoutMs': 120000,
  'candidateCollectionWindowMs': 10000,
  'minimumValidCandidateCount': 3,
  'rawCandidateListReturned': false,
};

class _WidgetFakeAiPlatform implements NavguardAiPlatform {
  @override
  Future<Map<String, Object?>> cancelCapture() async => <String, Object?>{
    'phase': 'CANCELLED',
  };

  @override
  Future<Map<String, Object?>> clearDataset() async => <String, Object?>{
    'datasetSessionCount': 0,
    'featureRowCount': 0,
  };

  @override
  Future<Map<String, Object?>> getCaptureStatus() async => <String, Object?>{
    'phase': 'IDLE',
  };

  @override
  Future<Map<String, Object?>> getDatasetSummary() async => <String, Object?>{
    'datasetSessionCount': 0,
    'featureRowCount': 0,
  };

  @override
  Future<Map<String, Object?>> getModelStatus() async => <String, Object?>{
    'status': 'MODEL_READY',
    'modelAvailable': true,
    'configESelectable': true,
  };

  @override
  Future<Map<String, Object?>> getPreflight(
    Map<String, Object?> anchor,
  ) async => <String, Object?>{
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
    'anchorAvailable': anchor['anchorAvailable'] == true,
    'operationAvailable': true,
    'nativeSelfTests': const <String, bool>{
      'liveInferenceHopInfrastructure': true,
    },
    'nativeSelfTestsPassed': true,
    'failedNativeSelfTests': const <String>[],
    'nativeSelfTestFailures': const <Map<String, String>>[],
    'selfTestsPassed': true,
    'captureReady': anchor['anchorAvailable'] == true,
    'nativeReady': true,
    'blockingReasons': const <String>[],
    'modelStatus': 'MODEL_READY',
    'modelAvailable': true,
  };

  @override
  Future<Map<String, Object?>> requestCapturePermissions() async =>
      <String, Object?>{};

  @override
  Future<Map<String, Object?>> runDevelopmentBenchmark() async =>
      <String, Object?>{'executable': false};

  @override
  Future<Map<String, Object?>> startCapture(
    Map<String, Object?> arguments,
  ) async => <String, Object?>{};
}

class _WidgetFakeLivePlatform implements LiveNavguardPlatform {
  final StreamController<Object?> _events =
      StreamController<Object?>.broadcast();
  bool realServicesUsed = false;
  int preflightCallCount = 0;
  int startCallCount = 0;

  @override
  Stream<Object?> get events => _events.stream;

  @override
  Future<LiveNavguardPreflight> getPreflight(LiveNavguardAnchor anchor) async {
    preflightCallCount++;
    return LiveNavguardPreflight.fromMap(<String, Object?>{
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
    });
  }

  @override
  Future<void> start(
    LiveNavguardAnchor anchor, [
    LiveFusionMode fusionMode = LiveFusionMode.navguardV1,
  ]) async {
    startCallCount++;
    emitState('PREPARING');
  }

  @override
  Future<void> beginDenial() async => emitState('NAVGUARD_ACTIVE');

  @override
  Future<void> requestRecovery() async => emitState('RECOVERY_PENDING');

  @override
  Future<void> setFusionMode(LiveFusionMode fusionMode) async {}

  @override
  Future<void> stop() async => emitState('STOPPED');

  void emitState(String state) {
    _events.add(<String, Object?>{
      'schemaVersion': 1,
      'kind': 'state',
      'state': state,
    });
  }
}
