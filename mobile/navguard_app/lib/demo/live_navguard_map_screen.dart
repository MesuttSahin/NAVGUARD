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
  LiveFusionMode _confirmedFusionMode = LiveFusionMode.navguardV1;
  LiveFusionMode? _queuedFusionMode;
  String? _error;
  bool _commandPending = false;
  bool _modeSwitchPending = false;
  bool _stopPending = false;
  bool _follow = true;
  bool _mapReady = false;
  bool _mapTilesUnavailable = false;
  bool _diagnosticsExpanded = false;
  bool _legendExpanded = false;
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
      setState(() {
        _preflight = preflight;
        _confirmedFusionMode = _fusionMode;
      });
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
    if (_stopPending || !_state.isRunning) return;
    setState(() {
      _stopPending = true;
      _queuedFusionMode = null;
    });
    try {
      await widget.platform.stop().timeout(const Duration(seconds: 5));
      if (!mounted) return;
      setState(() {
        _state = LiveNavguardState.stopped;
        _recoveryGoodFixCount = 0;
        _latestPosition = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _state = LiveNavguardState.stopped;
        _recoveryGoodFixCount = 0;
        _latestPosition = null;
        if (!silent) {
          _error = 'Stop completed with lifecycle timeout protection: $error';
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _stopPending = false;
          _commandPending = false;
        });
      }
    }
  }

  void _selectFusionMode(LiveFusionMode mode) {
    if (_stopPending || mode == _fusionMode) return;
    setState(() {
      _fusionMode = mode;
      _error = null;
      if (_state.isRunning) {
        _queuedFusionMode = mode;
      } else {
        _confirmedFusionMode = mode;
      }
    });
    if (_state.isRunning && !_modeSwitchPending) {
      unawaited(_drainFusionModeSwitches());
    }
  }

  Future<void> _drainFusionModeSwitches() async {
    if (_modeSwitchPending || _stopPending || !_state.isRunning) return;
    setState(() => _modeSwitchPending = true);
    try {
      while (mounted && _state.isRunning && !_stopPending) {
        final LiveFusionMode? target = _queuedFusionMode;
        _queuedFusionMode = null;
        if (target == null) break;
        if (target == _confirmedFusionMode) continue;
        try {
          await widget.platform
              .setFusionMode(target)
              .timeout(const Duration(seconds: 5));
          if (!mounted || _stopPending || !_state.isRunning) return;
          setState(() => _confirmedFusionMode = target);
        } catch (error) {
          if (!mounted || _stopPending || !_state.isRunning) return;
          setState(() {
            _fusionMode = _confirmedFusionMode;
            _queuedFusionMode = null;
            _error = 'Unable to switch fusion mode: $error';
          });
          break;
        }
      }
    } finally {
      if (mounted) setState(() => _modeSwitchPending = false);
    }
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
              left: 12,
              right: 12,
              top: 10,
              child: Align(
                alignment: Alignment.topCenter,
                child: _buildStatusCard(context),
              ),
            ),
            Positioned(left: 12, bottom: 234, child: _buildMapLegend(context)),
            Positioned(
              right: 12,
              bottom: 234,
              child: FloatingActionButton.small(
                heroTag: 'live-follow',
                key: const Key('live-recenter-control'),
                onPressed: () {
                  setState(() => _follow = true);
                  _followLatest();
                },
                tooltip: 'Follow position',
                child: Icon(_follow ? Icons.gps_fixed : Icons.gps_not_fixed),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                child: _buildPrimaryControl(context),
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
    final ColorScheme colors = Theme.of(context).colorScheme;
    final _StatusPresentation status = _statusPresentation(colors);
    final double diagnosticsHeight = (MediaQuery.sizeOf(context).height * 0.3)
        .clamp(180.0, 300.0);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Card(
        key: const Key('live-navigation-status-card'),
        margin: EdgeInsets.zero,
        elevation: 1,
        color: colors.surface.withAlpha(250),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: colors.outlineVariant.withAlpha(130)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Flexible(
                    child: Semantics(
                      label: 'Navigation status ${status.label}',
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: status.background,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                status.icon,
                                size: 15,
                                color: status.foreground,
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  status.label,
                                  key: const Key('live-gnss-status-badge'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: status.foreground,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: _fusionMode == LiveFusionMode.experimentalAiV3
                          ? const Color(0xFFEDE9FE)
                          : colors.primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Text(
                        _modeLabel(_fusionMode),
                        key: const Key('live-fusion-mode-status'),
                        style: TextStyle(
                          color: _fusionMode == LiveFusionMode.experimentalAiV3
                              ? const Color(0xFF5B21B6)
                              : colors.onPrimaryContainer,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                _statusText,
                key: const Key('live-demo-status'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: _summaryMetric(
                      context,
                      'Source',
                      position?.navigationSource.wireName ?? '—',
                      key: const Key('live-source-summary'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _summaryMetric(
                      context,
                      'Heading',
                      position == null
                          ? '—'
                          : '${_headingDeg(position).toStringAsFixed(1)}°',
                      key: const Key('live-heading-summary'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _summaryMetric(
                      context,
                      'Fusion quality',
                      position?.fusionQuality.wireName ?? 'UNKNOWN',
                      valueColor: _qualityColor(
                        position?.fusionQuality ?? LiveQuality.unknown,
                      ),
                      key: const Key('live-fusion-quality-summary'),
                    ),
                  ),
                ],
              ),
              if (_state == LiveNavguardState.navguardActive ||
                  _state == LiveNavguardState.recoveryPending) ...<Widget>[
                const SizedBox(height: 10),
                Container(
                  key: const Key('live-integrity-banner'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.shield_outlined,
                        size: 18,
                        color: Color(0xFFB91C1C),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'Estimator GNSS access: BLOCKED',
                              style: TextStyle(
                                color: Color(0xFF991B1B),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Denied GNSS used: ${position?.deniedGnssUsedByEstimatorCount ?? '—'}',
                              key: const Key('live-denied-gnss-used'),
                              style: const TextStyle(
                                color: Color(0xFF991B1B),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_state == LiveNavguardState.recoveryPending) ...<Widget>[
                const SizedBox(height: 8),
                _recoveryProgress(context),
              ],
              if (_recoveryCorrectionM
                  case final double correction) ...<Widget>[
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Icon(Icons.compare_arrows, size: 17, color: colors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Recovery correction',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${correction.toStringAsFixed(2)} m',
                      key: const Key('recovery-correction'),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
              if (_fusionMode == LiveFusionMode.experimentalAiV3) ...<Widget>[
                const SizedBox(height: 10),
                _buildAiStatus(context, position),
              ],
              if (_mapTilesUnavailable) ...<Widget>[
                const SizedBox(height: 7),
                const Text(
                  'Map tiles unavailable — NAVGUARD estimator is still running',
                  key: Key('map-unavailable-banner'),
                  style: TextStyle(color: Color(0xFF9A6700), fontSize: 12),
                ),
              ],
              if (_error case final String error) ...<Widget>[
                const SizedBox(height: 7),
                Text(
                  error,
                  key: const Key('live-error-message'),
                  style: TextStyle(color: colors.error, fontSize: 12),
                ),
              ],
              if (_preflight != null && !_preflight!.nativeReady) ...<Widget>[
                const SizedBox(height: 7),
                Text(
                  _preflightFailure(_preflight!),
                  style: TextStyle(color: colors.error, fontSize: 12),
                ),
              ],
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                child: _diagnosticsExpanded
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: SizedBox(
                          height: diagnosticsHeight,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colors.outlineVariant),
                            ),
                            child: position == null
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Text(
                                        'Detailed runtime metrics appear after the demo starts.',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                : SingleChildScrollView(
                                    key: const Key('live-diagnostics-scroll'),
                                    padding: const EdgeInsets.all(12),
                                    child: _buildDiagnostics(context, position),
                                  ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryControl(BuildContext context) {
    final bool busy = _commandPending;
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Card(
        key: const Key('live-bottom-control-card'),
        margin: EdgeInsets.zero,
        elevation: 2,
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: colors.outlineVariant.withAlpha(150)),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      'Fusion Mode',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    if (_modeSwitchPending) ...<Widget>[
                      const SizedBox.square(
                        dimension: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Switching',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                SegmentedButton<LiveFusionMode>(
                  key: const Key('live-fusion-mode-selector'),
                  showSelectedIcon: false,
                  segments: LiveFusionMode.values
                      .map(
                        (LiveFusionMode mode) => ButtonSegment<LiveFusionMode>(
                          value: mode,
                          label: Text(
                            _modeLabel(mode),
                            key: Key('live-mode-${mode.wireName}'),
                            maxLines: 1,
                          ),
                        ),
                      )
                      .toList(growable: false),
                  selected: <LiveFusionMode>{_fusionMode},
                  onSelectionChanged: _stopPending
                      ? null
                      : (Set<LiveFusionMode> selection) {
                          if (selection.isNotEmpty) {
                            _selectFusionMode(selection.first);
                          }
                        },
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
                      EdgeInsets.symmetric(horizontal: 7),
                    ),
                    textStyle: WidgetStatePropertyAll<TextStyle>(
                      TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _modeDescription,
                        key: const Key('live-ai-model-status'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (!_state.isRunning) ...<Widget>[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Anchor locked',
                        style: Theme.of(
                          context,
                        ).textTheme.labelSmall?.copyWith(color: colors.primary),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                _buildRuntimeActions(context, busy),
                SizedBox(
                  height: 48,
                  child: TextButton.icon(
                    key: const Key('live-diagnostics-toggle'),
                    onPressed: () => setState(
                      () => _diagnosticsExpanded = !_diagnosticsExpanded,
                    ),
                    icon: Icon(
                      _diagnosticsExpanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                    ),
                    label: Text(
                      _diagnosticsExpanded ? 'Hide Diagnostics' : 'Diagnostics',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRuntimeActions(BuildContext context, bool busy) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    Widget? primary;
    if (_state == LiveNavguardState.navguardReady) {
      primary = FilledButton.icon(
        key: const Key('live-start-denial'),
        onPressed: busy ? null : _beginDenial,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        icon: const Icon(Icons.gps_off, size: 18),
        label: const Text('Start GNSS Denial', maxLines: 1),
      );
    } else if (_state == LiveNavguardState.navguardActive) {
      primary = FilledButton.icon(
        key: const Key('live-recover-gnss'),
        onPressed: busy ? null : _recover,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        icon: const Icon(Icons.gps_fixed, size: 18),
        label: const Text('Recover GNSS', maxLines: 1),
      );
    }
    final Widget stopButton = OutlinedButton.icon(
      key: const Key('live-stop-demo'),
      onPressed: _stopPending ? null : _stop,
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.error,
        side: BorderSide(color: colors.error.withAlpha(150)),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
      icon: _stopPending
          ? const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.stop_circle_outlined, size: 18),
      label: Text(_stopPending ? 'Stopping…' : 'Stop Demo', maxLines: 1),
    );
    if (_state.isRunning) {
      return SizedBox(
        height: 48,
        child: primary == null
            ? stopButton
            : Row(
                children: <Widget>[
                  Expanded(child: primary),
                  const SizedBox(width: 8),
                  Expanded(child: stopButton),
                ],
              ),
      );
    }
    return SizedBox(
      height: 48,
      child: FilledButton.icon(
        key: const Key('live-start-demo'),
        onPressed: busy ? null : _start,
        icon: const Icon(Icons.play_arrow),
        label: const Text('Start Live Demo'),
      ),
    );
  }

  Widget _buildMapLegend(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Card(
      key: const Key('live-map-legend'),
      margin: EdgeInsets.zero,
      elevation: 1,
      color: colors.surface.withAlpha(248),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        key: const Key('live-map-legend-toggle'),
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _legendExpanded = !_legendExpanded),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 160),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.map_outlined, size: 16, color: colors.primary),
                      const SizedBox(width: 5),
                      const Text(
                        'Map legend',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Icon(
                        _legendExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 16,
                      ),
                    ],
                  ),
                  if (_legendExpanded) ...<Widget>[
                    const SizedBox(height: 7),
                    _legendItem(Colors.blue, Icons.my_location, 'GNSS'),
                    _legendItem(
                      Colors.deepPurple,
                      Icons.navigation,
                      'NAVGUARD',
                    ),
                    _legendItem(Colors.red, Icons.gps_off, 'Denial point'),
                    _legendItem(Colors.green, Icons.gps_fixed, 'Recovered'),
                    _legendLine(Colors.indigo, 'Trajectory'),
                    _legendLine(Colors.orange, 'Recovery link'),
                  ],
                  const SizedBox(height: 3),
                  const Text(
                    '© OpenStreetMap contributors',
                    key: Key('osm-attribution'),
                    style: TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _legendItem(Color color, IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Icon(icon, color: Colors.white, size: 11),
            ),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _legendLine(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 17,
            child: Divider(height: 2, thickness: 3, color: color),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _summaryMetric(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
    Key? key,
  }) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _recoveryProgress(BuildContext context) {
    final int required = _recoveryRequiredFixCount <= 0
        ? 1
        : _recoveryRequiredFixCount;
    final double progress = (_recoveryGoodFixCount / required).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              'Recovery progress',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const Spacer(),
            Text(
              '$_recoveryGoodFixCount/$_recoveryRequiredFixCount',
              key: const Key('recovery-progress'),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF92400E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        LinearProgressIndicator(
          value: progress,
          minHeight: 5,
          borderRadius: BorderRadius.circular(999),
          color: const Color(0xFFF59E0B),
          backgroundColor: const Color(0xFFFFF3C4),
        ),
      ],
    );
  }

  Widget _buildAiStatus(BuildContext context, LiveNavguardPosition? position) {
    final _AiPresentation ai = _aiPresentation(position);
    return Container(
      key: const Key('live-ai-status-card'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: ai.background,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: ai.accent.withAlpha(70)),
      ),
      child: Row(
        children: <Widget>[
          Icon(ai.icon, size: 18, color: ai.accent),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  ai.title,
                  key: const Key('live-v3-ai-status'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ai.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Experimental AI · ${ai.detail}',
                  key: const Key('live-v3-ai-detail'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
          if (ai.motion != null || ai.confidence != null) ...<Widget>[
            const SizedBox(width: 8),
            Text(
              <String>[
                if (ai.motion != null) ai.motion!,
                if (ai.confidence != null) '${(ai.confidence! * 100).round()}%',
              ].join(' · '),
              key: const Key('live-v3-ai-motion'),
              textAlign: TextAlign.right,
              style: TextStyle(
                color: ai.accent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDiagnostics(
    BuildContext context,
    LiveNavguardPosition position,
  ) {
    final double? latencyLast = position.stepCallbackLatencyLastMs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _diagnosticSection(
          context,
          'POSITION',
          const Key('diagnostics-position-group'),
          <Widget>[
            _diagnosticRow('Source', position.navigationSource.wireName),
            _diagnosticRow('East', '${position.eastM.toStringAsFixed(2)} m'),
            _diagnosticRow('North', '${position.northM.toStringAsFixed(2)} m'),
            _diagnosticRow(
              'Heading',
              '${_headingDeg(position).toStringAsFixed(1)}°',
            ),
            _diagnosticRow(
              'Displacement',
              '${position.displacementM.toStringAsFixed(2)} m',
            ),
            if (_recoveryCorrectionM case final double correction)
              _diagnosticRow(
                'Recovery correction',
                '${correction.toStringAsFixed(2)} m',
              ),
          ],
        ),
        _diagnosticSection(
          context,
          'QUALITY',
          const Key('diagnostics-quality-group'),
          <Widget>[
            _diagnosticRow('Heading quality', position.headingQuality.wireName),
            _diagnosticRow('PDR quality', position.pdrQuality.wireName),
            _diagnosticRow('ARCore quality', position.arCoreQuality.wireName),
            _diagnosticRow('Fusion quality', position.fusionQuality.wireName),
          ],
        ),
        _diagnosticSection(
          context,
          'UPDATES',
          const Key('diagnostics-updates-group'),
          <Widget>[
            _diagnosticRow('Heading updates', '${position.headingUpdateCount}'),
            _diagnosticRow('PDR updates', '${position.pdrPredictionCount}'),
            _diagnosticRow('ARCore updates', '${position.arCoreUpdateCount}'),
            _diagnosticRow('Late heading', '${position.lateHeadingEventCount}'),
            _diagnosticRow('Late step', '${position.lateStepEventCount}'),
            _diagnosticRow('Late ARCore', '${position.lateArcoreEventCount}'),
          ],
        ),
        _diagnosticSection(context, 'STEPS', const Key('diagnostics-steps-group'), <
          Widget
        >[
          _diagnosticRow('Received', '${position.receivedStepEventCount}'),
          _diagnosticRow('Applied', '${position.pdrPredictionsApplied}'),
          _diagnosticRow('Pending', '${position.pendingStepEventCount}'),
          _diagnosticRow(
            'Rejected no-heading',
            '${position.stepEventsRejectedNoCausalHeading}',
          ),
          _diagnosticRow('Rejected late', '${position.lateStepEventCount}'),
          _diagnosticRow(
            'Rejected duplicate',
            '${position.duplicateStepEventCount}',
          ),
          _diagnosticRow(
            'Historical replay',
            '${position.historicalStepReplayCount}',
          ),
          _diagnosticRow('Fixed-lag replay', '${position.fixedLagReplayCount}'),
          _diagnosticRow(
            'History events',
            '${position.fixedLagHistoryEventCount}',
          ),
          _diagnosticRow(
            'History window',
            '${position.fixedLagHistoryWindowMs} ms',
          ),
          _diagnosticRow(
            'Callback latency last/max/mean',
            latencyLast == null
                ? '—'
                : '${latencyLast.toStringAsFixed(1)} / '
                      '${position.stepCallbackLatencyMaxMs!.toStringAsFixed(1)} / '
                      '${position.stepCallbackLatencyMeanMs!.toStringAsFixed(1)} ms',
          ),
        ]),
        _diagnosticSection(
          context,
          'GNSS',
          const Key('diagnostics-gnss-group'),
          <Widget>[
            _diagnosticRow(
              'Accepted',
              '${position.normalGnssAcceptedFixCount}',
            ),
            _diagnosticRow(
              'Quarantined',
              '${position.deniedGnssQuarantinedFixCount}',
            ),
            _diagnosticRow(
              'Denied GNSS used',
              '${position.deniedGnssUsedByEstimatorCount}',
            ),
            _diagnosticRow(
              'Recovery good fixes',
              '${position.recoveryGoodFixCount}',
            ),
          ],
        ),
        if (_fusionMode != LiveFusionMode.navguardV1)
          _diagnosticSection(
            context,
            'ADAPTIVE',
            const Key('diagnostics-adaptive-group'),
            <Widget>[
              _diagnosticRow(
                'Stride estimate',
                '${position.strideEstimateM?.toStringAsFixed(3) ?? '—'} m',
              ),
              _diagnosticRow(
                'Heading offset',
                '${position.walkingHeadingOffsetDeg?.toStringAsFixed(2) ?? '—'}°',
              ),
              _diagnosticRow(
                'Stationary',
                position.stationaryDetected == true ? 'YES' : 'NO',
              ),
              _diagnosticRow(
                'Stationary entries',
                '${position.stationaryEntryCount}',
              ),
              _diagnosticRow(
                'Stationary duration',
                '${position.stationaryDurationMs} ms',
              ),
              _diagnosticRow(
                'Stationary candidates',
                '${position.stationaryCandidateCount}',
              ),
              _diagnosticRow(
                'Blockers step / heading / AR',
                '${position.stationaryBlockedRecentStepCount} / '
                    '${position.stationaryBlockedHeadingMotionCount} / '
                    '${position.stationaryBlockedArcoreMotionCount}',
              ),
              _diagnosticRow(
                'AR sigma',
                position.adaptiveArcoreSigmaM?.toStringAsFixed(2) ?? '—',
              ),
              _diagnosticRow(
                'NIS before → after',
                '${position.arcoreNisLast?.toStringAsFixed(2) ?? '—'} → '
                    '${position.arcorePostRobustNisLast?.toStringAsFixed(2) ?? '—'}',
              ),
              _diagnosticRow(
                'Robust accept / reject',
                '${position.arcoreAcceptedAfterRobustInflationCount} / '
                    '${position.arcoreRejectedAfterMaxInflationCount}',
              ),
              _diagnosticRow(
                'Source disagreement',
                '${position.sourceDisagreementM?.toStringAsFixed(2) ?? '—'} m',
              ),
            ],
          ),
        if (_fusionMode == LiveFusionMode.experimentalAiV3)
          _diagnosticSection(
            context,
            'AI',
            const Key('diagnostics-ai-group'),
            <Widget>[
              _diagnosticRow('Runtime status', position.aiRuntimeStatus),
              _diagnosticRow('Motion', position.aiMotionState ?? '—'),
              _diagnosticRow(
                'Confidence',
                position.aiMotionConfidence?.toStringAsFixed(3) ?? '—',
              ),
              _diagnosticRow('Fallback config', position.aiFallbackConfigId),
            ],
          ),
      ],
    );
  }

  Widget _diagnosticSection(
    BuildContext context,
    String title,
    Key key,
    List<Widget> rows,
  ) {
    return Padding(
      key: key,
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          ...rows,
        ],
      ),
    );
  }

  Widget _diagnosticRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF596273)),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  _StatusPresentation _statusPresentation(ColorScheme colors) {
    return switch (_state) {
      LiveNavguardState.gnssActive ||
      LiveNavguardState.navguardReady => const _StatusPresentation(
        'GNSS ACTIVE',
        Color(0xFFE7F7EE),
        Color(0xFF166534),
        Icons.gps_fixed,
      ),
      LiveNavguardState.navguardActive => const _StatusPresentation(
        'GNSS DENIED',
        Color(0xFFFFE7E7),
        Color(0xFFB91C1C),
        Icons.gps_off,
      ),
      LiveNavguardState.recoveryPending => const _StatusPresentation(
        'RECOVERING',
        Color(0xFFFFF3D6),
        Color(0xFF92400E),
        Icons.sync,
      ),
      LiveNavguardState.gnssRecovered => const _StatusPresentation(
        'GNSS RECOVERED',
        Color(0xFFE6F4FF),
        Color(0xFF075985),
        Icons.check_circle_outline,
      ),
      LiveNavguardState.preparing => _StatusPresentation(
        'PREPARING',
        colors.primaryContainer,
        colors.onPrimaryContainer,
        Icons.tune,
      ),
      LiveNavguardState.error => _StatusPresentation(
        'ERROR',
        colors.errorContainer,
        colors.onErrorContainer,
        Icons.error_outline,
      ),
      LiveNavguardState.stopped => _StatusPresentation(
        'STOPPED',
        colors.surfaceContainerHighest,
        colors.onSurfaceVariant,
        Icons.stop_circle_outlined,
      ),
      LiveNavguardState.idle => _StatusPresentation(
        'IDLE',
        colors.surfaceContainerHighest,
        colors.onSurfaceVariant,
        Icons.pause_circle_outline,
      ),
    };
  }

  _AiPresentation _aiPresentation(LiveNavguardPosition? position) {
    final String rawStatus;
    if (_modeSwitchPending ||
        (position != null && position.fusionMode != _fusionMode)) {
      rawStatus = 'WARMING_UP';
    } else if (position != null) {
      rawStatus = position.aiRuntimeStatus;
    } else {
      rawStatus = _preflight?.aiModelStatus ?? 'MODEL_NOT_AVAILABLE';
    }
    final String? motion = position?.fusionMode == _fusionMode
        ? _motionLabel(position?.aiMotionState)
        : null;
    final double? confidence = position?.fusionMode == _fusionMode
        ? position?.aiMotionConfidence
        : null;
    return switch (rawStatus) {
      'AI_ACTIVE' => _AiPresentation(
        title: 'AI Active',
        detail: 'AI-assisted motion reliability active',
        background: const Color(0xFFF3E8FF),
        accent: const Color(0xFF6D28D9),
        icon: Icons.auto_awesome,
        motion: motion,
        confidence: confidence,
      ),
      'WARMING_UP' => const _AiPresentation(
        title: 'Warming Up',
        detail: 'D-v2 active during transition',
        background: Color(0xFFF5F3FF),
        accent: Color(0xFF6D28D9),
        icon: Icons.hourglass_top,
      ),
      'MODEL_READY' => const _AiPresentation(
        title: 'Model Ready',
        detail: 'Ready for runtime inference',
        background: Color(0xFFF5F3FF),
        accent: Color(0xFF5B21B6),
        icon: Icons.memory,
      ),
      'MODEL_INVALID' => const _AiPresentation(
        title: 'AI Fallback',
        detail: 'Model Invalid · D-v2 active',
        background: Color(0xFFFFF7E6),
        accent: Color(0xFF9A6700),
        icon: Icons.warning_amber_rounded,
      ),
      'MODEL_NOT_AVAILABLE' => const _AiPresentation(
        title: 'AI Fallback',
        detail: 'AI Unavailable · D-v2 active',
        background: Color(0xFFFFF7E6),
        accent: Color(0xFF9A6700),
        icon: Icons.info_outline,
      ),
      _ => const _AiPresentation(
        title: 'AI Fallback',
        detail: 'D-v2 active',
        background: Color(0xFFFFF7E6),
        accent: Color(0xFF9A6700),
        icon: Icons.alt_route,
      ),
    };
  }

  String get _modeDescription => switch (_fusionMode) {
    LiveFusionMode.navguardV1 => 'Baseline EKF',
    LiveFusionMode.adaptiveV2 => 'Adaptive deterministic',
    LiveFusionMode.experimentalAiV3 => 'Experimental AI-assisted',
  };

  String _modeLabel(LiveFusionMode mode) => switch (mode) {
    LiveFusionMode.navguardV1 => 'V1',
    LiveFusionMode.adaptiveV2 => 'V2 Adaptive',
    LiveFusionMode.experimentalAiV3 => 'V3 · AI',
  };

  String? _motionLabel(String? motion) => switch (motion) {
    'STATIONARY' => 'Stationary',
    'STRAIGHT_WALK' => 'Straight Walk',
    'TURNING' => 'Turning',
    'UNSTABLE_MOTION' => 'Unstable Motion',
    null => null,
    _ => motion,
  };

  double _headingDeg(LiveNavguardPosition position) =>
      position.headingRad * 180 / 3.141592653589793;

  Color _qualityColor(LiveQuality quality) => switch (quality) {
    LiveQuality.good => const Color(0xFF15803D),
    LiveQuality.usable => const Color(0xFF0369A1),
    LiveQuality.degraded => const Color(0xFFB45309),
    LiveQuality.unreliable => const Color(0xFFB91C1C),
    LiveQuality.unavailable => const Color(0xFF6B7280),
    LiveQuality.unknown => const Color(0xFF6B7280),
  };

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

class _StatusPresentation {
  const _StatusPresentation(
    this.label,
    this.background,
    this.foreground,
    this.icon,
  );

  final String label;
  final Color background;
  final Color foreground;
  final IconData icon;
}

class _AiPresentation {
  const _AiPresentation({
    required this.title,
    required this.detail,
    required this.background,
    required this.accent,
    required this.icon,
    this.motion,
    this.confidence,
  });

  final String title;
  final String detail;
  final Color background;
  final Color accent;
  final IconData icon;
  final String? motion;
  final double? confidence;
}
