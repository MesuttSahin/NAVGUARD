import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navguard/demo/live_navguard_demo.dart';
import 'package:navguard/demo/live_navguard_map_screen.dart';

void main() {
  group('live payload parsing', () {
    test('parses preflight and sanitized position event', () {
      final LiveNavguardPreflight preflight = LiveNavguardPreflight.fromMap(
        _readyPreflightMap(),
      );
      expect(preflight.nativeReady, isTrue);
      expect(preflight.anchorAvailable, isTrue);

      final LiveNavguardEvent event = LiveNavguardEvent.fromRaw(
        _positionMap(
          state: 'NAVGUARD_ACTIVE',
          source: 'NAVGUARD',
          east: 10,
          north: 20,
        ),
      );
      expect(event.kind, 'position');
      expect(event.position?.state, LiveNavguardState.navguardActive);
      expect(event.position?.eastM, 10);
      expect(event.position?.deniedGnssUsedByEstimatorCount, 0);
      expect(event.position?.pdrPredictionsApplied, 1);
      expect(event.position?.historicalStepReplayCount, 1);
      expect(event.position?.fixedLagReplayCount, 1);
      expect(event.position?.fixedLagHistoryEventCount, 25);
      expect(event.position?.fixedLagHistoryWindowMs, 12000);
      expect(event.position?.stepCounterInvariantHolds, isTrue);
    });

    test('rejects a broken step counter invariant', () {
      final Map<String, Object?> payload = _positionMap(
        state: 'NAVGUARD_ACTIVE',
        source: 'NAVGUARD',
        east: 0,
        north: 0,
      );
      payload['receivedStepEventCount'] = 2;
      payload['stepCounterInvariantHolds'] = false;
      expect(() => LiveNavguardEvent.fromRaw(payload), throwsFormatException);
    });

    test(
      'rejects unsupported schema and raw timestamp-free contract holds',
      () {
        expect(
          () => LiveNavguardEvent.fromRaw(<String, Object?>{
            'schemaVersion': 2,
            'kind': 'state',
            'state': 'IDLE',
          }),
          throwsFormatException,
        );
        final Map<String, Object?> payload = _positionMap(
          state: 'GNSS_ACTIVE',
          source: 'GNSS',
          east: 0,
          north: 0,
        );
        expect(payload.containsKey('timestampNs'), isFalse);
        expect(payload.containsKey('rawPose'), isFalse);
        expect(payload.containsKey('rawSensorValues'), isFalse);
      },
    );
  });

  group('state machine', () {
    test('accepts the complete live flow', () {
      final LiveNavguardStateMachine machine = LiveNavguardStateMachine();
      for (final LiveNavguardState next in <LiveNavguardState>[
        LiveNavguardState.preparing,
        LiveNavguardState.gnssActive,
        LiveNavguardState.navguardReady,
        LiveNavguardState.navguardActive,
        LiveNavguardState.recoveryPending,
        LiveNavguardState.gnssRecovered,
        LiveNavguardState.stopped,
      ]) {
        machine.transition(next);
      }
      expect(machine.state, LiveNavguardState.stopped);
    });

    test('rejects invalid denial and recovery transitions', () {
      final LiveNavguardStateMachine machine = LiveNavguardStateMachine();
      expect(
        () => machine.transition(LiveNavguardState.navguardActive),
        throwsStateError,
      );
      machine.transition(LiveNavguardState.preparing);
      machine.transition(LiveNavguardState.gnssActive);
      expect(
        () => machine.transition(LiveNavguardState.recoveryPending),
        throwsStateError,
      );
    });
  });

  group('exact WGS84 ENU projection', () {
    final LiveNavguardAnchor anchor = const LiveNavguardAnchor(
      latitudeDeg: 41.015137,
      longitudeDeg: 28.97953,
      altitudeEllipsoidM: 42,
    );
    final Wgs84EnuProjection projection = Wgs84EnuProjection(anchor);

    test('zero ENU returns the anchor', () {
      final GeodeticPoint point = projection.fromEnu(const EnuPoint(0, 0));
      expect(point.latitudeDeg, closeTo(anchor.latitudeDeg, 1e-9));
      expect(point.longitudeDeg, closeTo(anchor.longitudeDeg, 1e-9));
    });

    test('positive east and north move in their expected directions', () {
      final GeodeticPoint east = projection.fromEnu(const EnuPoint(10, 0));
      final GeodeticPoint north = projection.fromEnu(const EnuPoint(0, 10));
      expect(east.longitudeDeg, greaterThan(anchor.longitudeDeg));
      expect(north.latitudeDeg, greaterThan(anchor.latitudeDeg));
    });

    for (final double distance in <double>[10, 50, 100]) {
      test('$distance m ENU is finite and round-trips', () {
        final EnuPoint expected = EnuPoint(distance, distance * 0.6, 0);
        final GeodeticPoint geodetic = projection.fromEnu(expected);
        final EnuPoint actual = projection.toEnu(geodetic);
        expect(geodetic.latitudeDeg.isFinite, isTrue);
        expect(geodetic.longitudeDeg.isFinite, isTrue);
        expect(actual.eastM, closeTo(expected.eastM, 1e-4));
        expect(actual.northM, closeTo(expected.northM, 1e-4));
      });
    }
  });

  test('denial starts continuously at the last GNSS E10/N20 point', () {
    final LiveRouteModel route = LiveRouteModel();
    route.add(
      _position(state: LiveNavguardState.gnssActive, east: 10, north: 20),
    );
    route.add(
      _position(
        sequence: 2,
        state: LiveNavguardState.navguardActive,
        source: LiveNavigationSource.navguard,
        east: 10,
        north: 20,
      ),
    );
    expect(route.denialStart?.eastM, 10);
    expect(route.denialStart?.northM, 20);
  });

  test('step at 125 uses causal heading at 120, never future 130', () {
    final LiveHeadingSample? heading = causalHeadingForStep(
      const <LiveHeadingSample>[
        LiveHeadingSample(100, 1),
        LiveHeadingSample(120, 2),
        LiveHeadingSample(130, 3),
      ],
      125,
    );
    expect(heading?.timestampNs, 120);
    expect(heading?.headingRad, 2);
  });

  test('reorder buffer delivers h100, step125, h130', () {
    final LiveReorderBuffer buffer = LiveReorderBuffer();
    buffer.add(const LiveTimedEvent(100, LiveTimedEventType.heading, 0));
    buffer.add(const LiveTimedEvent(130, LiveTimedEventType.heading, 1));
    buffer.add(const LiveTimedEvent(125, LiveTimedEventType.step, 2));
    final List<LiveTimedEvent> result = buffer.drainAll();
    expect(result.map((LiveTimedEvent value) => value.timestampNs), <int>[
      100,
      125,
      130,
    ]);
  });

  test('six-second delayed step is replayed with its causal heading', () {
    final LiveFixedLagReplayModel model = LiveFixedLagReplayModel(
      startTimestampNs: _ms(1000),
    );
    _populateReplayTimeline(model, endMs: 8000);

    expect(
      model.deliverStep(
        LiveTimedEvent(_ms(2000), LiveTimedEventType.step, 10000),
        callbackTimestampNs: _ms(8000),
      ),
      isTrue,
    );
    expect(model.headingTimestampForStep(_ms(2000)), _ms(2000));
    expect(model.pdrPredictionsApplied, 1);
    expect(model.historicalStepReplayCount, 1);
    expect(model.fixedLagReplayCount, 1);
    expect(model.lateStepEventCount, 0);
    expect(model.stepCounterInvariantHolds, isTrue);
    expect(model.stateIsFinite, isTrue);
  });

  test('10.5-second delayed step remains inside fixed-lag history', () {
    final LiveFixedLagReplayModel model = LiveFixedLagReplayModel(
      startTimestampNs: _ms(1000),
    );
    _populateReplayTimeline(model, endMs: 12500);

    expect(
      model.deliverStep(
        LiveTimedEvent(_ms(2000), LiveTimedEventType.step, 10001),
        callbackTimestampNs: _ms(12500),
      ),
      isTrue,
    );
    expect(model.headingTimestampForStep(_ms(2000)), _ms(2000));
    expect(model.pdrPredictionsApplied, 1);
    expect(model.lateStepEventCount, 0);
    expect(model.historyEventCount, lessThanOrEqualTo(4096));
    expect(model.stepCounterInvariantHolds, isTrue);
  });

  test('12.5-second delayed step is rejected without changing state', () {
    final LiveFixedLagReplayModel model = LiveFixedLagReplayModel(
      startTimestampNs: _ms(1000),
    );
    _populateReplayTimeline(model, endMs: 14500);
    final List<double> before = <double>[
      model.eastM,
      model.northM,
      model.headingRad,
      model.covarianceTrace,
    ];

    expect(
      model.deliverStep(
        LiveTimedEvent(_ms(2000), LiveTimedEventType.step, 10002),
        callbackTimestampNs: _ms(14500),
      ),
      isFalse,
    );
    expect(<double>[
      model.eastM,
      model.northM,
      model.headingRad,
      model.covarianceTrace,
    ], before);
    expect(model.lateStepEventCount, 1);
    expect(model.fixedLagReplayCount, 0);
    expect(model.stepCounterInvariantHolds, isTrue);
  });

  test('batched delayed steps replay in event order, not arrival order', () {
    LiveFixedLagReplayModel run(List<int> arrivalOrderMs) {
      final LiveFixedLagReplayModel model = LiveFixedLagReplayModel(
        startTimestampNs: _ms(1000),
      );
      _populateReplayTimeline(model, endMs: 9000);
      var insertion = 20000;
      for (final int eventMs in arrivalOrderMs) {
        expect(
          model.deliverStep(
            LiveTimedEvent(_ms(eventMs), LiveTimedEventType.step, insertion++),
            callbackTimestampNs: _ms(10500),
          ),
          isTrue,
        );
      }
      return model;
    }

    final LiveFixedLagReplayModel reversed = run(<int>[4000, 3000, 2500]);
    final LiveFixedLagReplayModel chronological = run(<int>[2500, 3000, 4000]);
    expect(reversed.pdrPredictionsApplied, 3);
    expect(reversed.historicalStepReplayCount, 3);
    expect(reversed.fixedLagReplayCount, 3);
    expect(reversed.eastM, closeTo(chronological.eastM, 1e-12));
    expect(reversed.northM, closeTo(chronological.northM, 1e-12));
    expect(reversed.headingRad, closeTo(chronological.headingRad, 1e-12));
    expect(
      reversed.covarianceTrace,
      closeTo(chronological.covarianceTrace, 1e-12),
    );
    expect(reversed.stepCounterInvariantHolds, isTrue);
  });

  test('duplicate, no-heading, and late outcomes preserve the invariant', () {
    final LiveFixedLagReplayModel model = LiveFixedLagReplayModel(
      startTimestampNs: _ms(1000),
    );
    model.applyLiveEvent(
      LiveTimedEvent(_ms(2000), LiveTimedEventType.heading, 0, headingRad: 0.4),
      callbackTimestampNs: _ms(2000),
    );
    final LiveTimedEvent applied = LiveTimedEvent(
      _ms(2000),
      LiveTimedEventType.step,
      1,
    );
    expect(model.deliverStep(applied, callbackTimestampNs: _ms(8000)), isTrue);
    expect(model.deliverStep(applied, callbackTimestampNs: _ms(8000)), isFalse);
    expect(
      model.deliverStep(
        LiveTimedEvent(_ms(3000), LiveTimedEventType.step, 2),
        callbackTimestampNs: _ms(8000),
      ),
      isTrue,
    );
    expect(
      model.deliverStep(
        LiveTimedEvent(_ms(2500), LiveTimedEventType.step, 3),
        callbackTimestampNs: _ms(15000),
      ),
      isFalse,
    );

    expect(model.receivedStepEventCount, 4);
    expect(model.pdrPredictionsApplied, 1);
    expect(model.duplicateStepEventCount, 1);
    expect(model.stepEventsRejectedNoCausalHeading, 1);
    expect(model.lateStepEventCount, 1);
    expect(model.stepCounterInvariantHolds, isTrue);

    final LiveReorderBuffer pending = LiveReorderBuffer();
    expect(
      pending.add(LiveTimedEvent(_ms(4000), LiveTimedEventType.step, 4)),
      isTrue,
    );
    expect(pending.pendingStepEventCount, 1);
    expect(pending.stepCounterInvariantHolds, isTrue);
  });

  test(
    'high-rate 16-second replay stays bounded, finite, and deterministic',
    () {
      LiveFixedLagReplayModel run() {
        final LiveFixedLagReplayModel model = LiveFixedLagReplayModel(
          startTimestampNs: _ms(1000),
        );
        final List<MapEntry<int, LiveTimedEvent>> callbacks =
            <MapEntry<int, LiveTimedEvent>>[];
        var insertion = 0;
        for (var timeMs = 1000; timeMs <= 17000; timeMs += 10) {
          if ((timeMs - 1000) % 20 == 0) {
            callbacks.add(
              MapEntry<int, LiveTimedEvent>(
                _ms(timeMs),
                LiveTimedEvent(
                  _ms(timeMs),
                  LiveTimedEventType.heading,
                  insertion++,
                  headingRad: (timeMs % 360) * math.pi / 180,
                ),
              ),
            );
          }
          if ((timeMs - 1000) % 30 == 0) {
            callbacks.add(
              MapEntry<int, LiveTimedEvent>(
                _ms(timeMs),
                LiveTimedEvent(
                  _ms(timeMs),
                  LiveTimedEventType.arcorePosition,
                  insertion++,
                  eastM: (timeMs - 1000) / 1000,
                  northM: (timeMs - 1000) / 2000,
                ),
              ),
            );
          }
        }
        for (final (int, int) timing in <(int, int)>[
          (3000, 13500),
          (7000, 13000),
          (5000, 15000),
          (6500, 15000),
        ]) {
          callbacks.add(
            MapEntry<int, LiveTimedEvent>(
              _ms(timing.$2),
              LiveTimedEvent(
                _ms(timing.$1),
                LiveTimedEventType.step,
                insertion++,
              ),
            ),
          );
        }
        callbacks.sort((
          MapEntry<int, LiveTimedEvent> a,
          MapEntry<int, LiveTimedEvent> b,
        ) {
          final int callbackOrder = a.key.compareTo(b.key);
          return callbackOrder != 0
              ? callbackOrder
              : a.value.insertionIndex.compareTo(b.value.insertionIndex);
        });
        for (final MapEntry<int, LiveTimedEvent> callback in callbacks) {
          if (callback.value.type == LiveTimedEventType.step) {
            expect(
              model.deliverStep(
                callback.value,
                callbackTimestampNs: callback.key,
              ),
              isTrue,
            );
          } else {
            model.applyLiveEvent(
              callback.value,
              callbackTimestampNs: callback.key,
            );
          }
        }
        return model;
      }

      final LiveFixedLagReplayModel first = run();
      final LiveFixedLagReplayModel second = run();
      expect(first.receivedStepEventCount, 4);
      expect(first.pdrPredictionsApplied, 4);
      expect(first.historicalStepReplayCount, 4);
      expect(first.fixedLagReplayCount, 4);
      expect(first.historyEventCount, lessThanOrEqualTo(4096));
      expect(first.historyEventCount, lessThan(1100));
      expect(first.stateIsFinite, isTrue);
      expect(first.stepCounterInvariantHolds, isTrue);
      expect(first.eastM, closeTo(second.eastM, 1e-12));
      expect(first.northM, closeTo(second.northM, 1e-12));
      expect(first.headingRad, closeTo(second.headingRad, 1e-12));
      expect(first.covarianceTrace, closeTo(second.covarianceTrace, 1e-12));
    },
  );

  test('step callback latency exposes aggregate milliseconds only', () {
    final LiveStepLatencyAccumulator latency = LiveStepLatencyAccumulator();
    latency.observe(
      eventTimestampNs: _ms(1000),
      callbackTimestampNs: _ms(1450),
    );
    latency.observe(
      eventTimestampNs: _ms(2000),
      callbackTimestampNs: _ms(2700),
    );
    expect(latency.sampleCount, 2);
    expect(latency.lastMs, 700);
    expect(latency.maxMs, 700);
    expect(latency.meanMs, 575);
  });

  test(
    'GNSS firewall quarantines denied fixes and estimator use remains zero',
    () {
      final LiveGnssFirewall firewall = LiveGnssFirewall();
      expect(firewall.acceptForEstimator(LiveNavguardState.gnssActive), isTrue);
      expect(
        firewall.acceptForEstimator(LiveNavguardState.navguardActive),
        isFalse,
      );
      expect(
        firewall.acceptForEstimator(LiveNavguardState.recoveryPending),
        isFalse,
      );
      expect(firewall.normalAcceptedFixCount, 1);
      expect(firewall.deniedQuarantinedFixCount, 2);
      expect(firewall.deniedUsedByEstimatorCount, 0);
    },
  );

  test(
    'recovery gate rejects stale fixes and recovers after three good fixes',
    () {
      final LiveRecoveryGate gate = LiveRecoveryGate()..open(1000);
      expect(gate.observe(generationNs: 999, accuracyM: 4), isFalse);
      expect(gate.consecutiveGoodFixes, 0);
      expect(gate.observe(generationNs: 1000, accuracyM: 4), isFalse);
      expect(gate.observe(generationNs: 1001, accuracyM: 5), isFalse);
      expect(gate.observe(generationNs: 1002, accuracyM: 6), isTrue);
    },
  );

  test('fixed-lag replay preserves the GNSS firewall and recovery flow', () {
    final LiveFixedLagReplayModel model = LiveFixedLagReplayModel(
      startTimestampNs: _ms(1000),
    );
    _populateReplayTimeline(model, endMs: 8000);
    final LiveGnssFirewall firewall = LiveGnssFirewall();
    expect(firewall.acceptForEstimator(LiveNavguardState.gnssActive), isTrue);
    expect(
      firewall.acceptForEstimator(LiveNavguardState.navguardActive),
      isFalse,
    );
    expect(
      model.deliverStep(
        LiveTimedEvent(_ms(2000), LiveTimedEventType.step, 30000),
        callbackTimestampNs: _ms(8000),
      ),
      isTrue,
    );
    final List<double> replayedState = <double>[
      model.eastM,
      model.northM,
      model.covarianceTrace,
    ];
    expect(
      firewall.acceptForEstimator(LiveNavguardState.recoveryPending),
      isFalse,
    );
    expect(<double>[
      model.eastM,
      model.northM,
      model.covarianceTrace,
    ], replayedState);
    expect(firewall.deniedUsedByEstimatorCount, 0);

    final LiveRecoveryGate gate = LiveRecoveryGate()..open(_ms(9000));
    expect(gate.observe(generationNs: _ms(8999), accuracyM: 4), isFalse);
    expect(gate.observe(generationNs: _ms(9000), accuracyM: 4), isFalse);
    expect(gate.observe(generationNs: _ms(9001), accuracyM: 5), isFalse);
    expect(gate.observe(generationNs: _ms(9002), accuracyM: 6), isTrue);
    expect(model.pdrPredictionsApplied, 1);
    expect(model.stepCounterInvariantHolds, isTrue);
  });

  test(
    'route starts, filters denied GNSS, caps, connects recovery, and resets',
    () {
      final LiveRouteModel route = LiveRouteModel(maximumPoints: 3);
      route.add(_position(east: 0, north: 0));
      route.add(_position(sequence: 2, east: 1, north: 0));
      expect(
        route.add(
          _position(
            sequence: 3,
            state: LiveNavguardState.navguardActive,
            source: LiveNavigationSource.gnss,
            east: 2,
            north: 0,
          ),
        ),
        isFalse,
      );
      for (var index = 3; index <= 6; index++) {
        route.add(
          _position(
            sequence: index,
            state: LiveNavguardState.navguardActive,
            source: LiveNavigationSource.navguard,
            east: index.toDouble(),
            north: 0,
          ),
        );
      }
      expect(route.points, hasLength(3));
      route.setRecoveryConnector(
        sequence: 6,
        preEastM: 6,
        preNorthM: 0,
        recoveredEastM: 5,
        recoveredNorthM: 1,
      );
      expect(route.preRecovery, isNotNull);
      expect(route.recovered, isNotNull);
      route.reset();
      expect(route.points, isEmpty);
      expect(route.denialStart, isNull);
    },
  );

  test('map tile failure does not mutate navigation state', () {
    final LiveNavguardStateMachine machine = LiveNavguardStateMachine(
      LiveNavguardState.navguardActive,
    );
    final LiveMapAvailability map = LiveMapAvailability()..reportTileFailure();
    expect(map.tilesUnavailable, isTrue);
    expect(machine.state, LiveNavguardState.navguardActive);
  });

  test('research and privacy flags remain conservative', () {
    expect(liveResearchFlags['liveMapDemoImplemented'], isTrue);
    expect(liveResearchFlags['softwareDefinedGnssDenial'], isTrue);
    expect(liveResearchFlags['rfInterferenceUsed'], isFalse);
    expect(liveResearchFlags['gnssSpoofingUsed'], isFalse);
    expect(liveResearchFlags['protectedGroundTruthAccessed'], isFalse);
    expect(liveResearchFlags['mapUsedAsEstimatorInput'], isFalse);
    expect(liveResearchFlags['liveDemoAccuracyValidated'], isFalse);
    expect(liveResearchFlags['stepLengthValidated'], isFalse);
    expect(liveResearchFlags['headingAccuracyValidated'], isFalse);
    expect(liveResearchFlags['arcorePositionAccuracyValidated'], isFalse);
    expect(liveResearchFlags['noiseParametersValidated'], isFalse);
    expect(liveResearchFlags['qualityThresholdsValidated'], isFalse);
    expect(liveResearchFlags['liveResearchValidationCompleted'], isFalse);
    expect(liveResearchFlags['formalOutdoorBenchmarkCompleted'], isFalse);
    expect(liveResearchFlags['finalAccuracyClaimAuthorized'], isFalse);
    expect(livePrivacyFlags.values, everyElement(isFalse));
  });

  testWidgets('controls follow valid states and recovery progress is visible', (
    WidgetTester tester,
  ) async {
    final FakeLiveNavguardPlatform platform = FakeLiveNavguardPlatform();
    await tester.pumpWidget(
      MaterialApp(
        home: LiveNavguardMapScreen(
          anchor: const LiveNavguardAnchor(latitudeDeg: 41, longitudeDeg: 29),
          platform: platform,
          enableMapTiles: false,
        ),
      ),
    );
    await tester.pump();
    expect(find.byKey(const Key('live-navguard-map')), findsOneWidget);
    expect(find.text('Start Live Demo'), findsOneWidget);
    expect(find.text('© OpenStreetMap contributors'), findsOneWidget);

    await tester.tap(find.text('Start Live Demo'));
    await tester.pumpAndSettle();
    platform.emitState('GNSS_ACTIVE');
    await tester.pumpAndSettle();
    expect(find.text('Stop Demo'), findsOneWidget);

    platform.emitState('NAVGUARD_READY');
    await tester.pumpAndSettle();
    expect(find.text('Start GNSS Denial'), findsOneWidget);

    platform.emitState('NAVGUARD_ACTIVE');
    await tester.pumpAndSettle();
    expect(find.text('Recover GNSS'), findsOneWidget);
    expect(
      find.text(
        'Software-defined GNSS denial / Estimator GNSS access: BLOCKED',
      ),
      findsOneWidget,
    );

    platform.emitPosition();
    await tester.pumpAndSettle();
    expect(
      find.text('Steps received/applied/pending: 1 / 1 / 0'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Step callback latency: last/max/mean 450.0 / 450.0 / 450.0 ms',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Fixed-lag step replays/history: 1 / 1 / 25'),
      findsOneWidget,
    );
    expect(find.text('Denied GNSS used: 0'), findsOneWidget);

    platform.emitRecoveryProgress(2);
    await tester.pumpAndSettle();
    expect(find.text('Recovery progress: 2/3'), findsOneWidget);
  });

  testWidgets('no anchor shows preparation UI without creating a map', (
    WidgetTester tester,
  ) async {
    final FakeLiveNavguardPlatform platform = FakeLiveNavguardPlatform();
    await tester.pumpWidget(
      MaterialApp(
        home: LiveNavguardMapScreen(
          anchor: null,
          platform: platform,
          enableMapTiles: false,
        ),
      ),
    );
    await tester.pump();

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
  });

  testWidgets('anchor-unavailable preflight replaces map with preparation UI', (
    WidgetTester tester,
  ) async {
    final FakeLiveNavguardPlatform platform = FakeLiveNavguardPlatform(
      anchorAvailable: false,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: LiveNavguardMapScreen(
          anchor: const LiveNavguardAnchor(latitudeDeg: 41, longitudeDeg: 29),
          platform: platform,
          enableMapTiles: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('GNSS Anchor Required'), findsOneWidget);
    expect(find.text('Return to Prepare GNSS Anchor'), findsOneWidget);
    expect(find.text('Start Live Demo'), findsNothing);
    expect(find.byKey(const Key('live-navguard-map')), findsNothing);
    expect(platform.startCallCount, 0);
  });
}

class FakeLiveNavguardPlatform implements LiveNavguardPlatform {
  FakeLiveNavguardPlatform({this.anchorAvailable = true});

  final StreamController<Object?> _events =
      StreamController<Object?>.broadcast();
  final bool anchorAvailable;
  int preflightCallCount = 0;
  int startCallCount = 0;

  @override
  Stream<Object?> get events => _events.stream;

  @override
  Future<LiveNavguardPreflight> getPreflight(LiveNavguardAnchor anchor) async {
    preflightCallCount++;
    final Map<String, Object?> value = _readyPreflightMap();
    value['anchorAvailable'] = anchorAvailable;
    value['nativeReady'] = anchorAvailable;
    return LiveNavguardPreflight.fromMap(value);
  }

  @override
  Future<void> start(LiveNavguardAnchor anchor) async {
    startCallCount++;
    emitState('PREPARING');
  }

  @override
  Future<void> beginDenial() async => emitState('NAVGUARD_ACTIVE');

  @override
  Future<void> requestRecovery() async => emitRecoveryProgress(0);

  @override
  Future<void> stop() async => emitState('STOPPED');

  void emitState(String state) {
    _events.add(<String, Object?>{
      'schemaVersion': 1,
      'kind': 'state',
      'state': state,
    });
  }

  void emitRecoveryProgress(int count) {
    _events.add(<String, Object?>{
      'schemaVersion': 1,
      'kind': 'recovery_progress',
      'state': 'RECOVERY_PENDING',
      'recoveryGoodFixCount': count,
      'recoveryRequiredFixCount': 3,
    });
  }

  void emitPosition() {
    _events.add(
      _positionMap(
        state: 'NAVGUARD_ACTIVE',
        source: 'NAVGUARD',
        east: 1,
        north: 2,
      ),
    );
  }
}

Map<String, Object?> _readyPreflightMap() => <String, Object?>{
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
};

Map<String, Object?> _positionMap({
  required String state,
  required String source,
  required double east,
  required double north,
}) => <String, Object?>{
  'schemaVersion': 1,
  'kind': 'position',
  'sequence': 1,
  'state': state,
  'navigationSource': source,
  'eastM': east,
  'northM': north,
  'headingRad': math.pi / 4,
  'displacementM': math.sqrt(east * east + north * north),
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
  'deniedGnssQuarantinedFixCount': 1,
  'deniedGnssUsedByEstimatorCount': 0,
  'lateHeadingEventCount': 0,
  'lateStepEventCount': 0,
  'lateArcoreEventCount': 0,
  'recoveryGoodFixCount': 0,
};

LiveNavguardPosition _position({
  int sequence = 1,
  LiveNavguardState state = LiveNavguardState.gnssActive,
  LiveNavigationSource source = LiveNavigationSource.gnss,
  double east = 0,
  double north = 0,
}) {
  return LiveNavguardPosition.fromMap(
    _positionMap(
      state: state.wireName,
      source: source.wireName,
      east: east,
      north: north,
    )..['sequence'] = sequence,
  );
}

int _ms(int value) => value * 1000000;

void _populateReplayTimeline(
  LiveFixedLagReplayModel model, {
  required int endMs,
}) {
  var insertion = 0;
  for (var timeMs = 1000; timeMs <= endMs; timeMs += 10) {
    if ((timeMs - 1000) % 20 == 0) {
      model.applyLiveEvent(
        LiveTimedEvent(
          _ms(timeMs),
          LiveTimedEventType.heading,
          insertion++,
          headingRad: (timeMs % 360) * math.pi / 180,
        ),
        callbackTimestampNs: _ms(timeMs),
      );
    }
    if ((timeMs - 1000) % 30 == 0) {
      model.applyLiveEvent(
        LiveTimedEvent(
          _ms(timeMs),
          LiveTimedEventType.arcorePosition,
          insertion++,
          eastM: (timeMs - 1000) / 1000,
          northM: (timeMs - 1000) / 2000,
        ),
        callbackTimestampNs: _ms(timeMs),
      );
    }
  }
}
