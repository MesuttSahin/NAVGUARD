import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navguard/demo/live_navguard_demo.dart';
import 'package:navguard/main.dart';

void main() {
  testWidgets('shows the initial runtime diagnostics UI', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NavguardApp());

    expect(find.text('NAVGUARD Runtime Diagnostics'), findsOneWidget);
    expect(find.text('Open NAVGUARD Live Map Demo'), findsOneWidget);
    expect(
      find.text(
        'Inventory: capability metadata only — no live sensor sampling.',
      ),
      findsOneWidget,
    );
    expect(find.text('Read Sensor Inventory'), findsOneWidget);
    expect(find.text('Live Sensor Timing Diagnostic'), findsOneWidget);
    expect(find.text('Accelerometer'), findsOneWidget);
    expect(
      find.text('Requested period: 20,000 µs (~50 Hz requested)'),
      findsOneWidget,
    );
    expect(find.text('Duration: 10 seconds'), findsOneWidget);
    expect(find.text('Run Timing Diagnostic'), findsOneWidget);

    expect(find.text('GNSS Runtime Timing Diagnostic'), findsOneWidget);
    expect(find.text('Precise location permission: Unknown'), findsOneWidget);
    expect(find.text('GPS provider: Unknown'), findsNWidgets(5));
    expect(find.text('Location services: Unknown'), findsNWidgets(2));
    expect(find.text('Refresh GNSS Preflight'), findsOneWidget);
    expect(find.text('Request Precise Location Permission'), findsOneWidget);
    expect(find.text('Provider: GPS_PROVIDER'), findsOneWidget);
    expect(find.text('Requested minimum interval: 1,000 ms'), findsOneWidget);
    expect(find.text('Requested minimum distance: 0 m'), findsOneWidget);
    expect(find.text('First location timeout: 120 seconds'), findsOneWidget);
    expect(
      find.text('Collection after first location: 60 seconds'),
      findsOneWidget,
    );
    expect(find.text('Run GNSS Timing Diagnostic'), findsOneWidget);

    expect(find.text('GNSS Anchor / Local Reference'), findsOneWidget);
    expect(find.text('Fine location permission: Unknown'), findsOneWidget);
    expect(find.text('Anchor state: No Anchor'), findsOneWidget);
    expect(find.text('Candidate count: Not available'), findsOneWidget);
    expect(
      find.text('Reported horizontal accuracy: Not available'),
      findsOneWidget,
    );
    expect(find.text('Altitude available: Unknown'), findsOneWidget);
    expect(find.text('Horizontal ENU origin ready: No'), findsOneWidget);
    expect(find.text('Refresh Anchor Preflight'), findsOneWidget);
    expect(find.text('Acquire GNSS Anchor'), findsOneWidget);

    expect(find.text('Heading / True-North Reference'), findsOneWidget);
    expect(find.text('Rotation Vector: Unknown'), findsNWidgets(7));
    expect(find.text('Anchor: Not locked'), findsOneWidget);
    expect(find.text('Heading diagnostic: Idle'), findsOneWidget);
    expect(find.text('Device forward axis: Top edge (+Y)'), findsOneWidget);
    expect(
      find.text('Requested sampling: 50 Hz (20,000 µs request)'),
      findsOneWidget,
    );
    expect(find.text('Observed sample rate: Not available'), findsOneWidget);
    expect(find.text('Valid sample count: Not available'), findsOneWidget);
    expect(find.text('Magnetic heading: Not available'), findsOneWidget);
    expect(
      find.text('True-north corrected heading estimate: Not available'),
      findsOneWidget,
    );
    expect(find.text('Declination: Not available'), findsOneWidget);
    expect(
      find.text('Reported heading accuracy: Not available'),
      findsOneWidget,
    );
    expect(
      find.text('Timestamp monotonicity: Not available'),
      findsNWidgets(2),
    );
    expect(
      find.text('Cumulative heading change: Not available'),
      findsOneWidget,
    );
    expect(find.text('True-north accuracy: NOT VALIDATED'), findsOneWidget);
    expect(find.text('Refresh Heading Preflight'), findsOneWidget);
    expect(find.text('Run Heading Diagnostic'), findsOneWidget);
    expect(find.text('Step-Event Foundation'), findsOneWidget);
    expect(find.text('Step Detector: Unknown'), findsNWidgets(6));
    expect(
      find.text('Physical activity permission: Unknown'),
      findsNWidgets(2),
    );
    expect(find.text('Step diagnostic: Idle'), findsOneWidget);
    expect(find.text('Formal window: 30 s'), findsNWidgets(2));
    expect(find.text('Detected step events: Not available'), findsNWidgets(2));
    expect(find.text('Invalid events: Not available'), findsOneWidget);
    expect(find.text('Median step interval: Not available'), findsOneWidget);
    expect(find.text('Observed cadence: Not available'), findsOneWidget);
    expect(find.text('Step detection accuracy: NOT VALIDATED'), findsOneWidget);
    expect(find.text('Refresh Step Preflight'), findsOneWidget);
    expect(find.text('Run Step Diagnostic'), findsOneWidget);

    expect(find.text('Baseline PDR'), findsOneWidget);
    expect(find.text('Anchor: Required'), findsOneWidget);
    expect(find.text('Baseline PDR: Idle'), findsOneWidget);
    expect(find.text('Step length model: Fixed 0.75 m'), findsOneWidget);
    expect(find.text('Integrated steps: Not available'), findsNWidgets(2));
    expect(find.text('Unassociated steps: Not available'), findsOneWidget);
    expect(find.text('Final East: Not available'), findsNWidgets(2));
    expect(find.text('Final North: Not available'), findsNWidgets(2));
    expect(find.text('Net displacement: Not available'), findsOneWidget);
    expect(find.text('Nominal path length: Not available'), findsOneWidget);
    expect(
      find.text('Median heading association age: Not available'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Step length accuracy: NOT VALIDATED'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Body heading: NOT IMPLEMENTED'),
      findsOneWidget,
    );
    expect(find.text('Refresh Baseline PDR Preflight'), findsOneWidget);
    expect(find.text('Run Baseline PDR'), findsOneWidget);

    expect(find.text('ARCore Runtime Diagnostics'), findsOneWidget);
    expect(find.text('Camera Permission: Unknown'), findsOneWidget);
    expect(find.text('ARCore Availability: Unknown'), findsOneWidget);
    expect(find.text('ARCore Ready: Unknown'), findsOneWidget);
    expect(find.text('Refresh ARCore Preflight'), findsOneWidget);
    expect(find.text('Request Camera Permission'), findsOneWidget);
    expect(find.text('Tracking Acquisition Timeout: 30 s'), findsOneWidget);
    expect(find.text('Tracking Collection Duration: 30 s'), findsOneWidget);
    expect(find.text('Run ARCore Tracking Diagnostic'), findsOneWidget);

    expect(find.text('ARCore → ENU Foundation'), findsOneWidget);
    expect(find.text('ARCore: Unknown'), findsNWidgets(2));
    expect(find.text('Camera permission: Unknown'), findsNWidgets(3));
    expect(find.text('GNSS Anchor: Required'), findsNWidgets(5));
    expect(find.text('Alignment: Not started'), findsOneWidget);
    expect(find.text('ARCore → ENU: Idle'), findsOneWidget);
    expect(find.text('Alignment hold: 2 s'), findsOneWidget);
    expect(find.text('Formal movement window: 30 s'), findsOneWidget);
    expect(find.text('Tracking fraction: Not available'), findsOneWidget);
    expect(find.text('Usable ENU frames: Not available'), findsOneWidget);
    expect(find.text('Final Up: Not available'), findsOneWidget);
    expect(find.text('Horizontal displacement: Not available'), findsOneWidget);
    expect(find.text('3D displacement: Not available'), findsOneWidget);
    expect(
      find.text('Max horizontal excursion: Not available'),
      findsOneWidget,
    );
    expect(
      find.text('Median AR frame interval: Not available'),
      findsOneWidget,
    );
    expect(
      find.textContaining('ARCore position accuracy: NOT VALIDATED'),
      findsOneWidget,
    );
    expect(find.textContaining('PDR fusion: NOT IMPLEMENTED'), findsOneWidget);
    expect(
      find.text('Refresh ARCore → ENU Preflight', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.text('Run ARCore → ENU Diagnostic', skipOffstage: false),
      findsOneWidget,
    );

    expect(
      find.text('Evaluation Mode + Ground Truth Firewall', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('Location permission: Unknown'), findsNWidgets(3));
    expect(find.text('Physical Activity permission: Unknown'), findsOneWidget);
    expect(find.text('Firewall self-test: Not run'), findsOneWidget);
    expect(find.text('Evaluation state: Idle'), findsOneWidget);
    expect(find.text('Protected GNSS role: Ground Truth Only'), findsOneWidget);
    expect(
      find.text('Denied estimator: Config A Baseline PDR'),
      findsOneWidget,
    );
    expect(find.text('Formal evaluation: 30 s'), findsOneWidget);
    expect(
      find.textContaining(
        'Protected GNSS is physically active in Evaluation Mode.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('GNSS correction: DISABLED'), findsOneWidget);
    expect(
      find.textContaining('Ground Truth Firewall: ENABLED'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Lock the GNSS anchor at the physical start point'),
      findsOneWidget,
    );
    expect(find.text('Protected GT fixes: Not available'), findsOneWidget);
    expect(find.text('Matched GT fixes: Not available'), findsOneWidget);
    expect(find.text('Final denied East: Not available'), findsOneWidget);
    expect(find.text('Final denied North: Not available'), findsOneWidget);
    expect(find.text('Median horizontal error: Not available'), findsOneWidget);
    expect(find.text('P95 horizontal error: Not available'), findsOneWidget);
    expect(
      find.text('Final denied pre-correction error: Not available'),
      findsOneWidget,
    );
    expect(
      find.text('Median estimator age at GT: Not available'),
      findsOneWidget,
    );
    expect(
      find.text('Refresh Evaluation Preflight', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.text('Run Evaluation Mode', skipOffstage: false),
      findsOneWidget,
    );

    expect(
      find.text('NAVGUARD Fusion — Quality Engine + EKF', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('ARCore readiness: Unknown'), findsOneWidget);
    expect(find.text('Activity permission: Unknown'), findsOneWidget);
    expect(find.text('Alignment state: Not started'), findsOneWidget);
    expect(find.text('Fusion state: Idle'), findsOneWidget);
    expect(find.text('Heading Quality: UNKNOWN'), findsOneWidget);
    expect(find.text('PDR Quality: UNKNOWN'), findsOneWidget);
    expect(find.text('ARCore Quality: UNKNOWN'), findsOneWidget);
    expect(find.text('Fusion Quality: UNKNOWN'), findsOneWidget);
    expect(find.text('PDR predictions: Not available'), findsOneWidget);
    expect(find.text('ARCore updates: Not available'), findsOneWidget);
    expect(find.text('Heading updates: Not available'), findsOneWidget);
    expect(find.text('Final fused East: Not available'), findsOneWidget);
    expect(find.text('Final fused North: Not available'), findsOneWidget);
    expect(find.text('Final fused heading: Not available'), findsOneWidget);
    expect(
      find.text('Final fused displacement: Not available'),
      findsOneWidget,
    );
    expect(find.text('Final PDR displacement: Not available'), findsOneWidget);
    expect(
      find.text('Final ARCore displacement: Not available'),
      findsOneWidget,
    );
    expect(find.text('Final σE: Not available'), findsOneWidget);
    expect(find.text('Final σN: Not available'), findsOneWidget);
    expect(find.text('Final σHeading: Not available'), findsOneWidget);
    expect(
      find.textContaining('Fusion accuracy: NOT VALIDATED'),
      findsOneWidget,
    );
    expect(find.textContaining('Protected GNSS: NOT ACCESSED'), findsOneWidget);
    expect(
      find.text('Refresh NAVGUARD Fusion Preflight', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.text('Run NAVGUARD Fusion Diagnostic', skipOffstage: false),
      findsOneWidget,
    );

    expect(
      find.text(
        'Full NAVGUARD Flow — GNSS Denial & Recovery',
        skipOffstage: false,
      ),
      findsOneWidget,
    );
    expect(find.text('Native ready: Unknown'), findsNWidgets(3));
    expect(
      find.textContaining(
        'final 12-second processing phase',
        skipOffstage: false,
      ),
      findsOneWidget,
    );
    final Finder scenarioSelector = find.byKey(
      const Key('accuracy-v2-development-scenario'),
      skipOffstage: false,
    );
    final DropdownButton<String> scenarioDropdown = tester
        .widget<DropdownButton<String>>(
          find.descendant(
            of: scenarioSelector,
            matching: find.byType(DropdownButton<String>),
          ),
        );
    expect(
      scenarioDropdown.items!.map(
        (DropdownMenuItem<String> item) => item.value,
      ),
      orderedEquals(<String>['STRAIGHT', 'L_TURN', 'MIXED']),
    );
    expect(
      find.byKey(const Key('full-navguard-flow-live-state')),
      findsOneWidget,
    );
    expect(find.text('IDLE'), findsOneWidget);
    expect(
      find.text('Normal GNSS accepted fixes: Not available'),
      findsOneWidget,
    );
    expect(
      find.text('Denied GNSS quarantined fixes: Not available'),
      findsOneWidget,
    );
    expect(
      find.text('Denied GNSS used by estimator: MUST BE 0'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Denial type: SOFTWARE-DEFINED'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Denied GNSS estimator access: BLOCKED'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Protected Ground Truth: NOT ACCESSED'),
      findsOneWidget,
    );
    expect(
      find.text('Refresh Full NAVGUARD Flow Preflight', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.text('Run Full NAVGUARD Flow', skipOffstage: false),
      findsOneWidget,
    );

    expect(
      find.text('NAVGUARD Benchmark — Config A/B/C/D', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('navguard-benchmark-live-phase')),
      findsOneWidget,
    );
    final Text benchmarkPhase = tester.widget<Text>(
      find.byKey(const Key('navguard-benchmark-live-phase')),
    );
    expect(benchmarkPhase.data, 'Idle');
    expect(find.text('Matched denied window: 30 s'), findsOneWidget);
    expect(find.text('Config'), findsOneWidget);
    expect(find.text('Median'), findsOneWidget);
    expect(find.text('Mean'), findsOneWidget);
    expect(find.text('P95'), findsOneWidget);
    expect(find.text('Final'), findsOneWidget);
    expect(find.text('D vs A improvement: Not available'), findsOneWidget);
    expect(find.text('Target: >=20%'), findsOneWidget);
    expect(find.text('Target met: Not available'), findsOneWidget);
    expect(
      find.text('Protected GT reported accuracy median: Not available'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Protected GNSS: EVALUATION ONLY'),
      findsOneWidget,
    );
    expect(find.textContaining('Estimator access: BLOCKED'), findsOneWidget);
    expect(find.textContaining('GT correction: NONE'), findsOneWidget);
    expect(find.textContaining('Results: SESSION-SPECIFIC'), findsOneWidget);
    expect(
      find.textContaining('Accuracy validation: NOT FINAL'),
      findsOneWidget,
    );
    expect(
      find.text('Refresh Benchmark Preflight', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.text('Run A/B/C/D Benchmark', skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('opens explicit no-anchor preparation UI without real services', (
    WidgetTester tester,
  ) async {
    final _WidgetFakeLivePlatform platform = _WidgetFakeLivePlatform();
    await tester.pumpWidget(
      NavguardApp(liveDemoPlatform: platform, enableLiveMapTiles: false),
    );

    await tester.tap(find.text('Open NAVGUARD Live Map Demo'));
    await tester.pumpAndSettle();
    expect(find.text('NAVGUARD Live Map Demo'), findsOneWidget);
    expect(find.text('GNSS Anchor Required'), findsOneWidget);
    expect(
      find.text('Lock a GNSS anchor before starting the live navigation demo.'),
      findsOneWidget,
    );
    expect(find.text('Return to Prepare GNSS Anchor'), findsOneWidget);
    expect(find.text('Start Live Demo'), findsNothing);
    expect(find.byKey(const Key('live-navguard-map')), findsNothing);
    expect(platform.preflightCallCount, 0);
    expect(platform.startCallCount, 0);
    expect(platform.realServicesUsed, isFalse);

    await tester.tap(find.text('Return to Prepare GNSS Anchor'));
    await tester.pumpAndSettle();
    expect(find.text('NAVGUARD Runtime Diagnostics'), findsOneWidget);
    expect(find.text('GNSS Anchor / Local Reference'), findsOneWidget);
    expect(find.text('Acquire GNSS Anchor'), findsOneWidget);
  });
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
  Future<void> stop() async => emitState('STOPPED');

  void emitState(String state) {
    _events.add(<String, Object?>{
      'schemaVersion': 1,
      'kind': 'state',
      'state': state,
    });
  }

  void emitPosition() {
    _events.add(<String, Object?>{
      'schemaVersion': 1,
      'kind': 'position',
      'sequence': 1,
      'state': 'NAVGUARD_ACTIVE',
      'navigationSource': 'NAVGUARD',
      'eastM': 1.0,
      'northM': 2.0,
      'headingRad': 0.5,
      'displacementM': 2.24,
      'headingQuality': 'GOOD',
      'pdrQuality': 'USABLE',
      'arCoreQuality': 'GOOD',
      'fusionQuality': 'GOOD',
      'headingUpdateCount': 1,
      'pdrPredictionCount': 1,
      'pdrPredictionsApplied': 1,
      'arCoreUpdateCount': 1,
      'receivedStepEventCount': 1,
      'stepEventsRejectedNoCausalHeading': 0,
      'duplicateStepEventCount': 0,
      'pendingStepEventCount': 0,
      'historicalStepReplayCount': 1,
      'fixedLagReplayCount': 1,
      'fixedLagHistoryEventCount': 25,
      'fixedLagHistoryWindowMs': 12000,
      'fixedLagHistoryBounded': true,
      'stepCounterInvariantHolds': true,
      'stepCallbackLatencyLastMs': 450.0,
      'stepCallbackLatencyMaxMs': 450.0,
      'stepCallbackLatencyMeanMs': 450.0,
      'normalGnssAcceptedFixCount': 3,
      'deniedGnssQuarantinedFixCount': 4,
      'deniedGnssUsedByEstimatorCount': 0,
      'lateHeadingEventCount': 0,
      'lateStepEventCount': 0,
      'lateArcoreEventCount': 0,
      'recoveryGoodFixCount': 0,
    });
  }
}
