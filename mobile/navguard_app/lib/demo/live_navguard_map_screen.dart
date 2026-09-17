import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'live_navguard_demo.dart';

class LiveNavguardMapScreen extends StatefulWidget {
  const LiveNavguardMapScreen({
    required this.anchor,
    this.platform = const MethodChannelLiveNavguardPlatform(),
    this.enableMapTiles = true,
    super.key,
  });

  final LiveNavguardAnchor? anchor;
  final LiveNavguardPlatform platform;
  final bool enableMapTiles;

  @override
  State<LiveNavguardMapScreen> createState() => _LiveNavguardMapScreenState();
}

class _LiveNavguardMapScreenState extends State<LiveNavguardMapScreen>
    with WidgetsBindingObserver {
  final MapController _mapController = MapController();
  final LiveRouteModel _route = LiveRouteModel();
  Wgs84EnuProjection? _projection;
  StreamSubscription<Object?>? _eventSubscription;
  LiveNavguardState _state = LiveNavguardState.idle;
  LiveNavguardPreflight? _preflight;
  LiveNavguardPosition? _latestPosition;
  LiveFusionMode _fusionMode = LiveFusionMode.navguardV1;
  String? _error;
  bool _commandPending = false;
  bool _follow = true;
  bool _mapReady = false;
  bool _mapTilesUnavailable = false;
  int _recoveryGoodFixCount = 0;
  int _recoveryRequiredFixCount = 3;
  double? _recoveryCorrectionM;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final LiveNavguardAnchor? anchor = widget.anchor;
    if (anchor == null || !anchor.isValid) return;
    _projection = Wgs84EnuProjection(anchor);
    _eventSubscription = widget.platform.events.listen(
      _handleRawEvent,
      onError: (Object error) {
        if (!mounted) return;
        setState(() {
          _error = 'Live event stream unavailable: $error';
          _state = LiveNavguardState.error;
        });
      },
    );
    unawaited(_refreshPreflight());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_stop(silent: true));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _eventSubscription?.cancel();
    if (_state.isRunning) unawaited(widget.platform.stop());
    _mapController.dispose();
    _route.reset();
    super.dispose();
  }

  Future<void> _refreshPreflight() async {
    final LiveNavguardAnchor? anchor = widget.anchor;
    if (anchor == null || !anchor.isValid) return;
    try {
      final LiveNavguardPreflight value = await widget.platform.getPreflight(
        anchor,
      );
      if (!mounted) return;
      setState(() => _preflight = value);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Live demo preflight failed: $error');
    }
  }

  void _handleRawEvent(Object? raw) {
    try {
      final LiveNavguardEvent event = LiveNavguardEvent.fromRaw(raw);
      if (!mounted) return;
      setState(() {
        _state = event.state;
        _error = event.kind == 'error'
            ? event.message ?? 'Native live demo error.'
            : _error;
        _recoveryGoodFixCount = event.recoveryGoodFixCount;
        _recoveryRequiredFixCount = event.recoveryRequiredFixCount;
        _recoveryCorrectionM =
            event.recoveryCorrectionM ?? _recoveryCorrectionM;
        final LiveNavguardPosition? position = event.position;
        if (position != null) {
          _latestPosition = position;
          _route.add(position);
        }
        if (event.preRecoveryEastM != null &&
            event.preRecoveryNorthM != null &&
            event.recoveredEastM != null &&
            event.recoveredNorthM != null) {
          _route.setRecoveryConnector(
            sequence: _latestPosition?.sequence ?? 0,
            preEastM: event.preRecoveryEastM!,
            preNorthM: event.preRecoveryNorthM!,
            recoveredEastM: event.recoveredEastM!,
            recoveredNorthM: event.recoveredNorthM!,
          );
        }
      });
      if (_follow && event.position != null) _followLatest();
    } on FormatException catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Rejected invalid live event: ${error.message}');
    }
  }

  Future<void> _start() async {
    if (_commandPending || _state.isRunning) return;
    final LiveNavguardAnchor? anchor = widget.anchor;
    if (anchor == null || !anchor.isValid) return;
    setState(() {
      _commandPending = true;
      _error = null;
      _state = LiveNavguardState.idle;
      _latestPosition = null;
      _recoveryGoodFixCount = 0;
      _recoveryCorrectionM = null;
      _follow = true;
      _route.reset();
    });
    try {
      final LiveNavguardPreflight preflight = await widget.platform
          .getPreflight(anchor);
      if (!preflight.nativeReady) {
        throw StateError(_preflightFailure(preflight));
      }
      await widget.platform.start(anchor, _fusionMode);
      if (!mounted) return;
      setState(() => _preflight = preflight);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to start live demo: $error';
        _state = LiveNavguardState.error;
      });
    } finally {
      if (mounted) setState(() => _commandPending = false);
    }
  }

  Future<void> _beginDenial() => _runCommand(widget.platform.beginDenial);

  Future<void> _recover() => _runCommand(widget.platform.requestRecovery);

  Future<void> _stop({bool silent = false}) async {
    if (_commandPending || !_state.isRunning) return;
    await _runCommand(widget.platform.stop, silent: silent);
  }

  Future<void> _runCommand(
    Future<void> Function() command, {
    bool silent = false,
  }) async {
    if (_commandPending) return;
    if (mounted) setState(() => _commandPending = true);
    try {
      await command();
    } catch (error) {
      if (!silent && mounted) setState(() => _error = 'Command failed: $error');
    } finally {
      if (mounted) setState(() => _commandPending = false);
    }
  }

  Future<void> _close() async {
    if (_state.isRunning) await _stop(silent: true);
    if (mounted) Navigator.of(context).pop();
  }

  void _followLatest() {
    final LiveNavguardPosition? position = _latestPosition;
    if (!_mapReady || position == null) return;
    final LatLng point = _latLng(position.eastM, position.northM);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _follow && _mapReady) {
        _mapController.move(point, _mapController.camera.zoom);
      }
    });
  }

  void _reportMapFailure() {
    if (_mapTilesUnavailable || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_mapTilesUnavailable) {
        setState(() => _mapTilesUnavailable = true);
      }
    });
  }

  LatLng _latLng(double eastM, double northM) {
    final Wgs84EnuProjection? projection = _projection;
    if (projection == null) {
      throw StateError('A valid locked GNSS anchor is required.');
    }
    final GeodeticPoint value = projection.fromEnu(EnuPoint(eastM, northM));
    return LatLng(value.latitudeDeg, value.longitudeDeg);
  }

  String _preflightFailure(LiveNavguardPreflight value) {
    final List<String> missing = <String>[
      if (!value.anchorAvailable) 'locked GNSS anchor',
      if (!value.gpsProviderAvailable || !value.gpsProviderEnabled)
        'enabled GPS provider',
      if (!value.fineLocationPermissionGranted) 'precise location permission',
      if (!value.rotationVectorAvailable) 'rotation vector',
      if (!value.stepDetectorAvailable) 'step detector',
      if (!value.activityRecognitionPermissionGranted)
        'physical activity permission',
      if (!value.arCoreSupported || !value.arCoreInstalled) 'ARCore',
      if (!value.cameraPermissionGranted) 'camera permission',
    ];
    return 'Not ready: ${missing.join(', ')}.';
  }

  String get _statusText => switch (_state) {
    LiveNavguardState.idle => 'Idle — start the live demo',
    LiveNavguardState.preparing => 'Preparing sensors, GNSS, and ARCore',
    LiveNavguardState.gnssActive => 'GNSS active — establishing live track',
    LiveNavguardState.navguardReady => 'NAVGUARD ready — GNSS denial can begin',
    LiveNavguardState.navguardActive =>
      'GNSS denied — NAVGUARD navigation active',
    LiveNavguardState.recoveryPending =>
      'GNSS recovery pending — NAVGUARD remains active',
    LiveNavguardState.gnssRecovered => 'GNSS recovered',
    LiveNavguardState.stopped => 'Demo stopped',
    LiveNavguardState.error => 'Demo error',
  };

  @override
  Widget build(BuildContext context) {
    final LiveNavguardAnchor? anchor = widget.anchor;
    if (anchor == null ||
        !anchor.isValid ||
        _preflight?.anchorAvailable == false) {
      return _buildAnchorRequiredScaffold(context);
    }
    final LatLng anchorPoint = LatLng(anchor.latitudeDeg, anchor.longitudeDeg);
    final List<LatLng> routePoints = _route.points
        .map((LiveRoutePoint point) => _latLng(point.eastM, point.northM))
        .toList(growable: false);
    final List<Polyline<Object>> polylines = <Polyline<Object>>[
      if (routePoints.length >= 2)
        Polyline<Object>(
          points: routePoints,
          strokeWidth: 5,
          color: Colors.indigo,
        ),
      if (_route.preRecovery case final LiveRoutePoint before?)
        if (_route.recovered case final LiveRoutePoint after?)
          Polyline<Object>(
            points: <LatLng>[
              _latLng(before.eastM, before.northM),
              _latLng(after.eastM, after.northM),
            ],
            strokeWidth: 4,
            color: Colors.orange,
          ),
    ];
    final List<Marker> markers = <Marker>[
      if (_route.denialStart case final LiveRoutePoint point)
        _marker(
          key: const Key('denial-start-marker'),
          point: _latLng(point.eastM, point.northM),
          color: Colors.red,
          icon: Icons.gps_off,
          tooltip: 'Denial Start',
        ),
      if (_route.recovered case final LiveRoutePoint point)
        _marker(
          key: const Key('gnss-recovered-marker'),
          point: _latLng(point.eastM, point.northM),
          color: Colors.green,
          icon: Icons.gps_fixed,
          tooltip: 'GNSS Recovered',
        ),
      if (_latestPosition case final LiveNavguardPosition position)
        _marker(
          key: const Key('live-position-marker'),
          point: _latLng(position.eastM, position.northM),
          color: position.navigationSource == LiveNavigationSource.gnss
              ? Colors.blue
              : Colors.deepPurple,
          icon: position.navigationSource == LiveNavigationSource.gnss
              ? Icons.my_location
              : Icons.navigation,
          tooltip: position.navigationSource.wireName,
        ),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) unawaited(_close());
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('NAVGUARD Live Map Demo'),
          leading: IconButton(
            onPressed: _close,
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back',
          ),
        ),
        body: Stack(
          children: <Widget>[
            FlutterMap(
              key: const Key('live-navguard-map'),
              mapController: _mapController,
              options: MapOptions(
                initialCenter: anchorPoint,
                initialZoom: 18,
                minZoom: 3,
                maxZoom: 20,
                onMapReady: () {
                  _mapReady = true;
                  _followLatest();
                },
                onPositionChanged: (MapCamera camera, bool hasGesture) {
                  if (hasGesture && _follow && mounted) {
                    setState(() => _follow = false);
                  }
                },
              ),
              children: <Widget>[
                if (widget.enableMapTiles)
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'io.github.mesuttsahin.navguard',
                    errorTileCallback: (_, _, _) => _reportMapFailure(),
                  ),
                PolylineLayer<Object>(polylines: polylines),
                MarkerLayer(markers: markers),
              ],
            ),
            Positioned(
              left: 8,
              right: 8,
              top: 8,
              child: _buildStatusCard(context),
            ),
            Positioned(
              left: 8,
              bottom: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withAlpha(230),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    '© OpenStreetMap contributors',
                    key: Key('osm-attribution'),
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  FloatingActionButton.small(
                    heroTag: 'live-follow',
                    onPressed: () {
                      setState(() => _follow = true);
                      _followLatest();
                    },
                    tooltip: 'Follow position',
                    child: Icon(
                      _follow ? Icons.gps_fixed : Icons.gps_not_fixed,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPrimaryControl(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnchorRequiredScaffold(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) unawaited(_close());
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('NAVGUARD Live Map Demo'),
          leading: IconButton(
            onPressed: _close,
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back',
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Card(
                  key: const Key('gnss-anchor-required-view'),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.location_searching,
                          size: 56,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'GNSS Anchor Required',
                          key: const Key('gnss-anchor-required-status'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Lock a GNSS anchor before starting the live navigation demo.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          key: const Key('return-to-prepare-anchor'),
                          onPressed: _close,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Return to Prepare GNSS Anchor'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final LiveNavguardPosition? position = _latestPosition;
    return Card(
      color: Theme.of(context).colorScheme.surface.withAlpha(238),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              _statusText,
              key: const Key('live-demo-status'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (_state == LiveNavguardState.navguardActive ||
                _state == LiveNavguardState.recoveryPending) ...<Widget>[
              const SizedBox(height: 4),
              const Text(
                'Software-defined GNSS denial / Estimator GNSS access: BLOCKED',
                key: Key('live-integrity-banner'),
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            if (_mapTilesUnavailable) ...<Widget>[
              const SizedBox(height: 4),
              const Text(
                'Map tiles unavailable — NAVGUARD estimator is still running',
                key: Key('map-unavailable-banner'),
                style: TextStyle(color: Colors.orange),
              ),
            ],
            if (_state == LiveNavguardState.recoveryPending) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                'Recovery progress: $_recoveryGoodFixCount/$_recoveryRequiredFixCount',
                key: const Key('recovery-progress'),
              ),
            ],
            if (_recoveryCorrectionM case final double correction) ...<Widget>[
              const SizedBox(height: 4),
              Text('Recovery correction: ${correction.toStringAsFixed(2)} m'),
            ],
            if (position != null) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                'Fusion mode: ${position.fusionMode.displayName}',
                key: const Key('live-fusion-mode-status'),
              ),
              Text(
                'Source ${position.navigationSource.wireName} · '
                'E ${position.eastM.toStringAsFixed(2)} m · '
                'N ${position.northM.toStringAsFixed(2)} m · '
                'Heading ${(position.headingRad * 180 / 3.141592653589793).toStringAsFixed(1)}°',
              ),
              Text(
                'Quality H/P/AR/F: ${position.headingQuality.wireName} / '
                '${position.pdrQuality.wireName} / '
                '${position.arCoreQuality.wireName} / '
                '${position.fusionQuality.wireName}',
              ),
              Text(
                'Updates H/PDR/AR: ${position.headingUpdateCount} / '
                '${position.pdrPredictionCount} / ${position.arCoreUpdateCount}',
              ),
              Text(
                'Steps received/applied/pending: '
                '${position.receivedStepEventCount} / '
                '${position.pdrPredictionsApplied} / '
                '${position.pendingStepEventCount}',
                key: const Key('live-step-counters'),
              ),
              Text(
                'Step rejected no-heading/late/duplicate: '
                '${position.stepEventsRejectedNoCausalHeading} / '
                '${position.lateStepEventCount} / '
                '${position.duplicateStepEventCount}',
              ),
              Text(
                'Fixed-lag step replays/history: '
                '${position.historicalStepReplayCount} / '
                '${position.fixedLagReplayCount} / '
                '${position.fixedLagHistoryEventCount}',
                key: const Key('live-fixed-lag-replay'),
              ),
              if (position.stepCallbackLatencyLastMs case final double lastMs)
                Text(
                  'Step callback latency: last/max/mean '
                  '${lastMs.toStringAsFixed(1)} / '
                  '${position.stepCallbackLatencyMaxMs!.toStringAsFixed(1)} / '
                  '${position.stepCallbackLatencyMeanMs!.toStringAsFixed(1)} ms',
                  key: const Key('live-step-latency'),
                ),
              Text(
                'GNSS accepted/quarantined: '
                '${position.normalGnssAcceptedFixCount} / '
                '${position.deniedGnssQuarantinedFixCount}',
              ),
              Text(
                'Denied GNSS used: ${position.deniedGnssUsedByEstimatorCount}',
                key: const Key('live-denied-gnss-used'),
              ),
              Text(
                'Late H/Step/AR: ${position.lateHeadingEventCount} / '
                '${position.lateStepEventCount} / '
                '${position.lateArcoreEventCount}',
              ),
              if (position.fusionMode == LiveFusionMode.adaptiveV2) ...<Widget>[
                Text(
                  'Adaptive stride/heading offset: '
                  '${position.strideEstimateM?.toStringAsFixed(3) ?? '—'} m / '
                  '${position.walkingHeadingOffsetDeg?.toStringAsFixed(2) ?? '—'}°',
                  key: const Key('live-v2-calibration-status'),
                ),
                Text(
                  'Stationary: ${position.stationaryDetected == true ? 'YES' : 'NO'} · '
                  'entries/duration: ${position.stationaryEntryCount} / ${position.stationaryDurationMs} ms · '
                  'AR sigma/NIS/disagreement: '
                  '${position.adaptiveArcoreSigmaM?.toStringAsFixed(2) ?? '—'} / '
                  '${position.arcoreNisLast?.toStringAsFixed(2) ?? '—'}→${position.arcorePostRobustNisLast?.toStringAsFixed(2) ?? '—'} / '
                  '${position.sourceDisagreementM?.toStringAsFixed(2) ?? '—'} m',
                  key: const Key('live-v2-adaptive-status'),
                ),
                Text(
                  'Stationary candidates/blockers step-heading-AR: '
                  '${position.stationaryCandidateCount} / '
                  '${position.stationaryBlockedRecentStepCount}-'
                  '${position.stationaryBlockedHeadingMotionCount}-'
                  '${position.stationaryBlockedArcoreMotionCount}',
                  key: const Key('live-v2-stationary-diagnostics'),
                ),
              ],
            ],
            if (_error case final String error) ...<Widget>[
              const SizedBox(height: 4),
              Text(error, style: const TextStyle(color: Colors.red)),
            ],
            if (_preflight != null && !_preflight!.nativeReady) ...<Widget>[
              const SizedBox(height: 4),
              Text(_preflightFailure(_preflight!)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryControl() {
    final bool busy = _commandPending;
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (!_state.isRunning) ...<Widget>[
                DropdownButtonFormField<LiveFusionMode>(
                  key: const Key('live-fusion-mode-selector'),
                  initialValue: _fusionMode,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Fusion Mode',
                    isDense: true,
                  ),
                  items: LiveFusionMode.values
                      .map(
                        (LiveFusionMode mode) =>
                            DropdownMenuItem<LiveFusionMode>(
                              value: mode,
                              child: Text(mode.displayName),
                            ),
                      )
                      .toList(growable: false),
                  onChanged: busy
                      ? null
                      : (LiveFusionMode? value) {
                          if (value != null) {
                            setState(() => _fusionMode = value);
                          }
                        },
                ),
                const SizedBox(height: 6),
              ],
              if (_state == LiveNavguardState.navguardReady)
                FilledButton.icon(
                  onPressed: busy ? null : _beginDenial,
                  icon: const Icon(Icons.gps_off),
                  label: const Text('Start GNSS Denial'),
                ),
              if (_state == LiveNavguardState.navguardActive)
                FilledButton.icon(
                  onPressed: busy ? null : _recover,
                  icon: const Icon(Icons.gps_fixed),
                  label: const Text('Recover GNSS'),
                ),
              if (_state.isRunning) ...<Widget>[
                if (_state == LiveNavguardState.navguardReady ||
                    _state == LiveNavguardState.navguardActive)
                  const SizedBox(height: 4),
                OutlinedButton.icon(
                  onPressed: busy ? null : _stop,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop Demo'),
                ),
              ] else
                FilledButton.icon(
                  onPressed: busy ? null : _start,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Live Demo'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Marker _marker({
    required Key key,
    required LatLng point,
    required Color color,
    required IconData icon,
    required String tooltip,
  }) {
    return Marker(
      key: key,
      point: point,
      width: 44,
      height: 44,
      child: Tooltip(
        message: tooltip,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
