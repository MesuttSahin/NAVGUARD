import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'navguard_ai.dart';

class NavguardAiDatasetScreen extends StatefulWidget {
  const NavguardAiDatasetScreen({
    required this.anchorLatitudeDeg,
    required this.anchorLongitudeDeg,
    required this.anchorAltitudeEllipsoidM,
    this.platform = const MethodChannelNavguardAiPlatform(),
    super.key,
  });

  final double? anchorLatitudeDeg;
  final double? anchorLongitudeDeg;
  final double? anchorAltitudeEllipsoidM;
  final NavguardAiPlatform platform;

  @override
  State<NavguardAiDatasetScreen> createState() =>
      _NavguardAiDatasetScreenState();
}

enum _UiStatus { success, warning, danger, active, neutral }

class _CapturePresentation {
  const _CapturePresentation({
    required this.label,
    required this.title,
    required this.description,
    required this.status,
    required this.icon,
  });

  final String label;
  final String title;
  final String description;
  final _UiStatus status;
  final IconData icon;
}

class _NavguardAiDatasetScreenState extends State<NavguardAiDatasetScreen> {
  NavguardAiMotionLabel _motion = NavguardAiMotionLabel.stationary;
  int _durationSeconds = 25;
  Map<String, Object?> _preflight = const <String, Object?>{};
  Map<String, Object?> _summary = const <String, Object?>{};
  Map<String, Object?> _status = const <String, Object?>{'phase': 'IDLE'};
  Map<String, Object?> _lastCaptureResult = const <String, Object?>{};
  Map<String, Object?> _model = const <String, Object?>{};
  bool _busy = false;
  bool _datasetDetailsExpanded = false;
  bool _captureDiagnosticsExpanded = false;
  String? _message;
  Timer? _statusTimer;

  Map<String, Object?> get _anchor => navguardAiAnchorArguments(
    latitudeDeg: widget.anchorLatitudeDeg,
    longitudeDeg: widget.anchorLongitudeDeg,
    altitudeEllipsoidM: widget.anchorAltitudeEllipsoidM,
  );

  NavguardAiCapturePreflight get _capturePreflight =>
      NavguardAiCapturePreflight.fromMap(_preflight);
  bool get _canStart => _capturePreflight.captureReady && !_busy;
  NavguardAiModelStatus get _modelStatus => NavguardAiModelStatus.parse(
    _model['status'] ?? _preflight['modelStatus'],
  );

  @override
  void initState() {
    super.initState();
    unawaited(_refresh());
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  Future<void> _refresh({bool preserveMessage = false}) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      if (!preserveMessage) _message = null;
    });
    try {
      final List<Map<String, Object?>> values =
          await Future.wait(<Future<Map<String, Object?>>>[
            widget.platform.getPreflight(_anchor),
            widget.platform.getDatasetSummary(),
            widget.platform.getModelStatus(),
          ]);
      if (!mounted) return;
      setState(() {
        _preflight = values[0];
        _summary = values[1];
        _model = values[2];
      });
    } on PlatformException catch (error) {
      _setMessage('AI preflight failed (${error.code}).');
    } catch (_) {
      _setMessage('AI preflight could not be read.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pollStatus() async {
    try {
      final Map<String, Object?> value = await widget.platform
          .getCaptureStatus();
      if (mounted) setState(() => _status = value);
    } catch (_) {
      // The start call carries the terminal error. Polling is display-only.
    }
  }

  Future<void> _requestCapturePermissions() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await widget.platform.requestCapturePermissions();
      if (!mounted) return;
      setState(() => _busy = false);
      await _refresh();
      _setMessage('Capture permissions refreshed.');
    } on PlatformException catch (error) {
      if (mounted) setState(() => _busy = false);
      _setMessage('Permission request failed (${error.code}).');
    } catch (_) {
      if (mounted) setState(() => _busy = false);
      _setMessage('Capture permissions could not be requested.');
    }
  }

  Future<void> _startCapture() async {
    if (!_canStart) return;
    setState(() {
      _busy = true;
      _message = null;
      _lastCaptureResult = const <String, Object?>{};
      _status = <String, Object?>{
        'phase': 'COUNTDOWN',
        'remainingSeconds': 3,
        'featureWindowCount': 0,
      };
    });
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => unawaited(_pollStatus()),
    );
    try {
      final Map<String, Object?> result = await widget.platform
          .startCapture(<String, Object?>{
            ..._anchor,
            'motionLabel': _motion.platformName,
            'durationSeconds': _durationSeconds,
          });
      if (!mounted) return;
      setState(() {
        _status = <String, Object?>{
          'phase': 'COMPLETED',
          'remainingSeconds': 0,
          'featureWindowCount': result['featureWindowCount'] ?? 0,
        };
        _lastCaptureResult = result;
        _message = 'Capture saved locally.';
      });
    } on PlatformException catch (error) {
      if (mounted) {
        setState(() => _status = const <String, Object?>{'phase': 'FAILED'});
      }
      _setMessage('Capture failed (${error.code}).');
    } catch (_) {
      if (mounted) {
        setState(() => _status = const <String, Object?>{'phase': 'FAILED'});
      }
      _setMessage('Capture failed.');
    } finally {
      _statusTimer?.cancel();
      if (mounted) {
        setState(() => _busy = false);
        await _refresh(preserveMessage: true);
      }
    }
  }

  Future<void> _cancelCapture() async {
    try {
      await widget.platform.cancelCapture();
    } finally {
      _statusTimer?.cancel();
      if (mounted) {
        setState(() {
          _busy = false;
          _status = const <String, Object?>{'phase': 'CANCELLED'};
        });
      }
    }
  }

  Future<void> _confirmClear() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Clear local AI dataset?'),
        content: const Text(
          'This removes all locally captured AI dataset CSV files from this device. This action cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('ai-confirm-clear'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear Dataset'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final Map<String, Object?> value = await widget.platform.clearDataset();
      if (!mounted) return;
      setState(() {
        _summary = value;
        _message = 'Local AI dataset cleared.';
      });
    } catch (_) {
      _setMessage('Local AI dataset could not be cleared.');
    }
  }

  void _setMessage(String value) {
    if (mounted) setState(() => _message = value);
  }

  String _yesNo(Object? value) => value == true ? 'Yes' : 'No';

  @override
  Widget build(BuildContext context) {
    final NavguardAiCapturePreflight preflight = _capturePreflight;
    final String phase = _status['phase']?.toString() ?? 'IDLE';
    final int remaining = (_status['remainingSeconds'] as num?)?.toInt() ?? 0;
    final int windowCount =
        (_status['featureWindowCount'] as num?)?.toInt() ?? 0;
    final String featureSchemaVersion =
        (_preflight['featureSchemaVersion'] ??
                _summary['featureSchemaVersion'] ??
                navguardAiFeatureSchema)
            .toString();
    final int featureCount =
        (_preflight['featureCount'] as num?)?.toInt() ??
        navguardAiFeatureOrder.length;
    final bool captureRunning = _captureIsRunning(phase);
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('NAVGUARD AI Dataset'),
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colors.surface,
      ),
      body: SafeArea(
        child: ListView(
          key: const Key('ai-dataset-scroll'),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: <Widget>[
            _buildOverviewCard(context, featureCount),
            const SizedBox(height: 16),
            _buildReadinessCard(context, preflight, featureSchemaVersion),
            const SizedBox(height: 16),
            _buildMotionClassCard(context),
            const SizedBox(height: 16),
            _buildCaptureCard(
              context,
              phase: phase,
              remaining: remaining,
              windowCount: windowCount,
              captureRunning: captureRunning,
            ),
            if (_lastCaptureResult.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              _buildCaptureDiagnostics(context),
            ],
            const SizedBox(height: 16),
            _buildLocalDatasetCard(context),
            const SizedBox(height: 16),
            _buildDatasetDetailsCard(
              context,
              featureSchemaVersion: featureSchemaVersion,
              featureCount: featureCount,
            ),
            const SizedBox(height: 16),
            _buildPrivacyCard(context),
            if (_message case final String message) ...<Widget>[
              const SizedBox(height: 12),
              _buildMessageBanner(context, message),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, int featureCount) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Card(
      key: const Key('ai-dataset-overview'),
      margin: EdgeInsets.zero,
      elevation: 0,
      color: const Color(0xFFF4F2FF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFDCD6FE)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4DEFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.dataset_outlined,
                    color: Color(0xFF5B21B6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'V3 · Motion Dataset',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF312E81),
                        ),
                      ),
                      Text(
                        'On-device motion feature capture for NAVGUARD AI research.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _overviewChip(
                  const Key('ai-feature-count'),
                  Icons.hub_outlined,
                  '$featureCount Features',
                ),
                _overviewChip(
                  const Key('ai-motion-class-count'),
                  Icons.category_outlined,
                  '4 Motion Classes',
                ),
                _overviewChip(
                  const Key('ai-local-only-chip'),
                  Icons.lock_outline,
                  'Local Only',
                ),
                _overviewChip(
                  const Key('ai-feature-schema'),
                  Icons.science_outlined,
                  'V3 Schema',
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Research Dataset · Experimental AI',
              style: TextStyle(
                color: Color(0xFF5B21B6),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _overviewChip(Key key, IconData icon, String label) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(220),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFDCD6FE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 15, color: const Color(0xFF5B21B6)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildReadinessCard(
    BuildContext context,
    NavguardAiCapturePreflight preflight,
    String featureSchemaVersion,
  ) {
    final bool checked = _preflight.isNotEmpty;
    final bool sensorsReady =
        preflight.accelerometerAvailable &&
        preflight.gyroscopeAvailable &&
        preflight.rotationVectorAvailable &&
        preflight.stepDetectorAvailable;
    final bool pipelineReady =
        checked &&
        featureSchemaVersion == navguardAiFeatureSchema &&
        (_preflight['featureCount'] as num?)?.toInt() ==
            navguardAiFeatureOrder.length &&
        preflight.selfTestsPassed;
    final bool storageReady = _summary.isNotEmpty;
    final bool refreshing =
        _busy && !_captureIsRunning(_status['phase']?.toString() ?? 'IDLE');
    final Map<String, NavguardAiSelfTestFailureDetail> failureDetailsByTest =
        <String, NavguardAiSelfTestFailureDetail>{
          for (final NavguardAiSelfTestFailureDetail detail
              in preflight.nativeSelfTestFailures)
            detail.test: detail,
        };
    return _sectionCard(
      context,
      key: const Key('ai-preflight-details'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _sectionHeading(
                  context,
                  'CAPTURE READINESS',
                  'Real device and pipeline checks',
                ),
              ),
              _statusBadge(
                context,
                checked
                    ? preflight.captureReady
                          ? 'READY'
                          : 'ACTION REQUIRED'
                    : 'NOT CHECKED',
                checked
                    ? preflight.captureReady
                          ? _UiStatus.success
                          : _UiStatus.warning
                    : _UiStatus.neutral,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _readinessRow(
            context,
            Icons.sensors,
            'Sensors',
            _readinessLabel(checked, sensorsReady),
            _readinessStatus(checked, sensorsReady),
          ),
          _readinessRow(
            context,
            Icons.account_tree_outlined,
            'Feature Pipeline',
            _readinessLabel(checked, pipelineReady),
            _readinessStatus(checked, pipelineReady),
          ),
          _readinessRow(
            context,
            Icons.storage_outlined,
            'Storage',
            storageReady ? 'Ready' : 'Not checked',
            storageReady ? _UiStatus.success : _UiStatus.neutral,
          ),
          _readinessRow(
            context,
            Icons.memory,
            'Native Runtime',
            _readinessLabel(checked, preflight.captureReady),
            _readinessStatus(checked, preflight.captureReady),
          ),
          if (checked && !preflight.captureReady) ...<Widget>[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7E6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Capture not ready',
                    style: TextStyle(
                      color: Color(0xFF92400E),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Blocking reason: ${preflight.blockingReasons.isEmpty ? 'NONE' : preflight.blockingReasons.join(', ')}',
                    key: const Key('ai-blocking-reasons'),
                    style: const TextStyle(fontSize: 12),
                  ),
                  if (!preflight.selfTestsPassed)
                    for (final String test
                        in preflight.failedNativeSelfTests) ...<Widget>[
                      Text(
                        'Failed self-test: $test',
                        key: Key('ai-failed-self-test-$test'),
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Self-test reason: ${failureDetailsByTest[test]?.reason ?? 'SELF_TEST_ASSERTION_FAILED'}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (failureDetailsByTest[test]
                          case final detail?) ...<Widget>[
                        Text(
                          'Expected: ${detail.expected}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Actual: ${detail.actual}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ],
                ],
              ),
            ),
          ] else if (checked)
            const Text(
              'Blocking reason: NONE',
              key: Key('ai-blocking-reasons'),
              style: TextStyle(fontSize: 12, color: Color(0xFF166534)),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const Key('ai-refresh-preflight'),
            onPressed: _busy ? null : _refresh,
            icon: refreshing
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            label: const Text('Refresh Capture Readiness'),
          ),
          if (checked && !preflight.permissionsReady) ...<Widget>[
            const SizedBox(height: 8),
            FilledButton.icon(
              key: const Key('ai-request-capture-permissions'),
              onPressed: _busy ? null : _requestCapturePermissions,
              icon: const Icon(Icons.security),
              label: const Text('Grant Capture Permissions'),
            ),
          ] else
            Offstage(
              offstage: true,
              child: FilledButton(
                key: const Key('ai-request-capture-permissions'),
                onPressed: null,
                child: const Text('Grant Capture Permissions'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _readinessRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    _UiStatus status,
  ) {
    final Color color = _statusColor(status);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Icon(
            status == _UiStatus.success
                ? Icons.check_circle
                : status == _UiStatus.warning
                ? Icons.warning_amber_rounded
                : Icons.radio_button_unchecked,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotionClassCard(BuildContext context) {
    return _sectionCard(
      context,
      key: const Key('ai-motion-selector'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _sectionHeading(
            context,
            'MOTION CLASS',
            'Choose the ground-truth label for this capture.',
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double width = (constraints.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: NavguardAiMotionLabel.values
                    .map(
                      (NavguardAiMotionLabel value) => SizedBox(
                        width: width,
                        child: _motionClassTile(context, value),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(
                Icons.info_outline,
                size: 17,
                color: Color(0xFF5B21B6),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  _motion.instruction,
                  key: const Key('ai-motion-instruction'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _motionClassTile(BuildContext context, NavguardAiMotionLabel value) {
    final bool selected = _motion == value;
    final ColorScheme colors = Theme.of(context).colorScheme;
    final IconData icon = switch (value) {
      NavguardAiMotionLabel.stationary => Icons.pause_circle_outline,
      NavguardAiMotionLabel.straightWalk => Icons.directions_walk,
      NavguardAiMotionLabel.turning => Icons.turn_right,
      NavguardAiMotionLabel.unstableMotion => Icons.vibration,
    };
    return Semantics(
      selected: selected,
      button: true,
      label: '${value.displayName} motion class',
      child: Material(
        color: selected ? const Color(0xFFF1EDFF) : colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected ? const Color(0xFF6D28D9) : colors.outlineVariant,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: InkWell(
          key: Key('ai-motion-${value.platformName}'),
          borderRadius: BorderRadius.circular(14),
          onTap: _busy ? null : () => setState(() => _motion = value),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: <Widget>[
                  Icon(
                    icon,
                    size: 21,
                    color: selected
                        ? const Color(0xFF5B21B6)
                        : colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _motionDisplayName(value),
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: selected ? const Color(0xFF4C1D95) : null,
                      ),
                    ),
                  ),
                  if (selected)
                    const Icon(
                      Icons.check_circle,
                      size: 17,
                      color: Color(0xFF6D28D9),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _captureIsRunning(String phase) =>
      _busy &&
      const <String>{
        'COUNTDOWN',
        'CAPTURE',
        'FINAL_DRAIN',
        'FINALIZING',
      }.contains(phase);

  int get _expectedWindowCount =>
      ((_durationSeconds * 1000 - navguardAiFeatureWindowMs) ~/
          navguardAiFeatureHopMs) +
      1;

  Widget _buildCaptureCard(
    BuildContext context, {
    required String phase,
    required int remaining,
    required int windowCount,
    required bool captureRunning,
  }) {
    final _CapturePresentation presentation = _capturePresentation(phase);
    final int totalSeconds = switch (phase) {
      'COUNTDOWN' => 3,
      'CAPTURE' => _durationSeconds,
      'FINAL_DRAIN' => 12,
      _ => 0,
    };
    final double? progress = totalSeconds > 0
        ? ((totalSeconds - remaining) / totalSeconds).clamp(0.0, 1.0)
        : phase == 'FINALIZING'
        ? null
        : phase == 'COMPLETED'
        ? 1
        : 0;

    return _sectionCard(
      context,
      key: const Key('ai-capture-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _sectionHeading(
                  context,
                  'CAPTURE SESSION',
                  'Labelled, fixed-window feature capture',
                ),
              ),
              _statusBadge(context, presentation.label, presentation.status),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            key: const Key('ai-capture-phase'),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _statusColor(presentation.status).withAlpha(18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _statusColor(presentation.status).withAlpha(70),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      presentation.icon,
                      size: 20,
                      color: _statusColor(presentation.status),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        presentation.title,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    if (captureRunning && remaining > 0)
                      Text(
                        '$remaining s remaining',
                        key: const Key('ai-capture-remaining'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  presentation.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (captureRunning || phase == 'COMPLETED') ...<Widget>[
                  const SizedBox(height: 10),
                  LinearProgressIndicator(value: progress),
                ],
                if (phase == 'COMPLETED') ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    '$windowCount windows saved locally',
                    key: const Key('ai-capture-saved-windows'),
                    style: const TextStyle(
                      color: Color(0xFF166534),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          _metricRow('Selected motion', _motionDisplayName(_motion)),
          _metricRow('Formal capture', '$_durationSeconds s'),
          _metricRow('Final processing', '12 s'),
          _metricRow('Expected windows', '$_expectedWindowCount'),
          const SizedBox(height: 12),
          Text(
            'Capture Duration',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Container(
            key: const Key('ai-duration-selector'),
            child: Row(
              children: <Widget>[
                for (final int duration in const <int>[20, 25, 30]) ...<Widget>[
                  if (duration != 20) const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () => setState(() => _durationSeconds = duration),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        foregroundColor: _durationSeconds == duration
                            ? const Color(0xFF4C1D95)
                            : null,
                        backgroundColor: _durationSeconds == duration
                            ? const Color(0xFFF1EDFF)
                            : null,
                        side: BorderSide(
                          color: _durationSeconds == duration
                              ? const Color(0xFF6D28D9)
                              : Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: Text('$duration s'),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (captureRunning)
            OutlinedButton.icon(
              key: const Key('ai-cancel-capture'),
              onPressed: _cancelCapture,
              icon: const Icon(Icons.stop_circle_outlined),
              label: const Text('Cancel Capture'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                minimumSize: const Size.fromHeight(48),
              ),
            )
          else
            FilledButton.icon(
              key: const Key('ai-start-capture'),
              onPressed: _canStart ? _startCapture : null,
              icon: const Icon(Icons.fiber_manual_record),
              label: const Text('Start Dataset Capture'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
        ],
      ),
    );
  }

  _CapturePresentation _capturePresentation(String phase) => switch (phase) {
    'COUNTDOWN' => const _CapturePresentation(
      label: 'GET READY',
      title: 'Capture starts after the countdown',
      description: 'Hold the phone in normal demo orientation.',
      status: _UiStatus.active,
      icon: Icons.timer_outlined,
    ),
    'CAPTURE' => _CapturePresentation(
      label: 'CAPTURING',
      title: 'Perform ${_motionDisplayName(_motion).toLowerCase()}',
      description: _motion.instruction,
      status: _UiStatus.active,
      icon: Icons.motion_photos_on_outlined,
    ),
    'FINAL_DRAIN' => const _CapturePresentation(
      label: 'FINAL PROCESSING',
      title: 'Processing delayed step events',
      description: 'Remain still while fixed-lag events are finalized.',
      status: _UiStatus.warning,
      icon: Icons.hourglass_bottom,
    ),
    'FINALIZING' => const _CapturePresentation(
      label: 'FINAL PROCESSING',
      title: 'Finalizing feature windows',
      description: 'The session is being committed to local storage.',
      status: _UiStatus.warning,
      icon: Icons.sync,
    ),
    'COMPLETED' => const _CapturePresentation(
      label: 'SESSION SAVED',
      title: 'Capture completed',
      description: 'Derived V3 feature windows were stored locally.',
      status: _UiStatus.success,
      icon: Icons.check_circle_outline,
    ),
    'FAILED' => const _CapturePresentation(
      label: 'CAPTURE FAILED',
      title: 'Capture was not saved',
      description: 'Review readiness and try again.',
      status: _UiStatus.danger,
      icon: Icons.error_outline,
    ),
    'CANCELLED' => const _CapturePresentation(
      label: 'CAPTURE CANCELLED',
      title: 'Capture cancelled',
      description: 'No incomplete session was added to the dataset.',
      status: _UiStatus.neutral,
      icon: Icons.cancel_outlined,
    ),
    _ => const _CapturePresentation(
      label: 'READY TO CAPTURE',
      title: 'Start a labelled motion session',
      description: 'Choose a motion class, then begin the capture.',
      status: _UiStatus.neutral,
      icon: Icons.radio_button_checked,
    ),
  };

  Widget _buildCaptureDiagnostics(BuildContext context) {
    return _sectionCard(
      context,
      key: const Key('ai-step-diagnostics'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          InkWell(
            key: const Key('ai-capture-diagnostics-toggle'),
            borderRadius: BorderRadius.circular(10),
            onTap: () => setState(
              () => _captureDiagnosticsExpanded = !_captureDiagnosticsExpanded,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.analytics_outlined),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Capture Diagnostics',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Icon(
                    _captureDiagnosticsExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                  ),
                ],
              ),
            ),
          ),
          if (_captureDiagnosticsExpanded) ...<Widget>[
            const Divider(),
            _metricRow(
              'Step events received',
              '${_lastCaptureResult['stepEventsReceived'] ?? 0}',
            ),
            _metricRow(
              'Steps in formal window',
              '${_lastCaptureResult['stepEventsFormalWindow'] ?? 0}',
            ),
            _metricRow(
              'Steps delivered in final drain',
              '${_lastCaptureResult['stepEventsDeliveredDuringFinalDrain'] ?? 0}',
            ),
            _metricRow(
              'Steps applied to features',
              '${_lastCaptureResult['stepEventsAppliedToFeatures'] ?? 0}',
            ),
            _metricRow(
              'Post-window steps excluded',
              '${_lastCaptureResult['stepEventsExcludedPostWindow'] ?? 0}',
            ),
            _metricRow(
              'Duplicate steps rejected',
              '${_lastCaptureResult['stepEventsDuplicateRejected'] ?? 0}',
            ),
            _metricRow(
              'Out-of-history steps rejected',
              '${_lastCaptureResult['stepEventsOutOfHistoryRejected'] ?? 0}',
            ),
            _metricRow(
              'Callback latency mean / max',
              '${_lastCaptureResult['callbackLatencyMeanMs'] ?? 0} / ${_lastCaptureResult['callbackLatencyMaxMs'] ?? 0} ms',
            ),
            _metricRow(
              'Windows with / without steps',
              '${_lastCaptureResult['featureWindowsWithSteps'] ?? 0} / ${_lastCaptureResult['featureWindowsWithoutSteps'] ?? 0}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocalDatasetCard(BuildContext context) {
    final int sessions =
        (_summary['datasetSessionCount'] as num?)?.toInt() ?? 0;
    final int windows = (_summary['featureRowCount'] as num?)?.toInt() ?? 0;
    final bool empty = sessions == 0 && windows == 0;
    return _sectionCard(
      context,
      key: const Key('ai-local-dataset-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _sectionHeading(
            context,
            'LOCAL DATASET',
            empty
                ? 'No local sessions yet. Start a capture to add V3 windows.'
                : 'Stored locally · V3 feature schema',
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final Widget sessionTile = _metricTile(
                context,
                key: const Key('ai-dataset-sessions'),
                icon: Icons.folder_copy_outlined,
                value: '$sessions',
                label: 'Sessions',
              );
              final Widget windowTile = _metricTile(
                context,
                key: const Key('ai-dataset-windows'),
                icon: Icons.view_timeline_outlined,
                value: '$windows',
                label: 'Windows',
              );
              if (constraints.maxWidth < 310) {
                return Column(
                  children: <Widget>[
                    sessionTile,
                    const SizedBox(height: 10),
                    windowTile,
                  ],
                );
              }
              return Row(
                children: <Widget>[
                  Expanded(child: sessionTile),
                  const SizedBox(width: 10),
                  Expanded(child: windowTile),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const Key('ai-clear-dataset'),
            onPressed: _busy || empty ? null : _confirmClear,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear Local Dataset'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatasetDetailsCard(
    BuildContext context, {
    required String featureSchemaVersion,
    required int featureCount,
  }) {
    return _sectionCard(
      context,
      key: const Key('ai-dataset-details-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          InkWell(
            key: const Key('ai-dataset-details-toggle'),
            borderRadius: BorderRadius.circular(10),
            onTap: () => setState(
              () => _datasetDetailsExpanded = !_datasetDetailsExpanded,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.data_object),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Dataset Details',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Icon(
                    _datasetDetailsExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                  ),
                ],
              ),
            ),
          ),
          if (_datasetDetailsExpanded) ...<Widget>[
            const Divider(),
            _metricRow('Dataset schema', navguardAiDatasetSchema),
            _metricRow('Feature schema', featureSchemaVersion),
            _metricRow('Feature count', '$featureCount'),
            _metricRow('Window', '$navguardAiFeatureWindowMs ms'),
            _metricRow('Hop', '$navguardAiFeatureHopMs ms'),
            _metricRow('Formal duration', '25 s'),
            _metricRow('Final drain', '12 s'),
            _metricRow('Expected nominal windows', '24'),
            _metricRow('Fixed-lag association', 'Enabled'),
            const Divider(),
            Text(
              'Runtime model: ${_modelStatus.label}',
              key: const Key('ai-model-status'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Config E selectable: ${_yesNo(_model['configESelectable'])}',
              key: const Key('ai-config-e-selectable'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Fallback: Config D-v2 adaptive navigation',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrivacyCard(BuildContext context) {
    const List<(IconData, String)> protections = <(IconData, String)>[
      (Icons.location_off_outlined, 'No coordinates'),
      (Icons.videocam_off_outlined, 'No camera frames'),
      (Icons.stream_outlined, 'No raw sensor streams'),
      (Icons.cloud_off_outlined, 'No telemetry'),
    ];
    return _sectionCard(
      context,
      key: const Key('ai-privacy-notice'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _sectionHeading(
            context,
            'PRIVACY',
            'Captured datasets remain local to the device and contain derived features only.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: protections
                .map(
                  ((IconData, String) protection) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          protection.$1,
                          size: 15,
                          color: const Color(0xFF166534),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          protection.$2,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBanner(BuildContext context, String message) {
    final bool failed =
        message.toLowerCase().contains('failed') ||
        message.toLowerCase().contains('could not');
    final Color color = failed
        ? Theme.of(context).colorScheme.error
        : const Color(0xFF166534);
    return Container(
      key: const Key('ai-message'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            failed ? Icons.error_outline : Icons.check_circle_outline,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required Key key,
    required Widget child,
  }) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Card(
      key: key,
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outlineVariant.withAlpha(150)),
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }

  Widget _sectionHeading(BuildContext context, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(BuildContext context, String label, _UiStatus status) {
    final Color color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.35,
        ),
      ),
    );
  }

  Widget _metricTile(
    BuildContext context, {
    required Key key,
    required IconData icon,
    required String value,
    required String label,
  }) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      key: key,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, size: 20, color: const Color(0xFF5B21B6)),
          const SizedBox(height: 5),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _metricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  String _readinessLabel(bool checked, bool ready) => !checked
      ? 'Not checked'
      : ready
      ? 'Ready'
      : 'Action required';

  _UiStatus _readinessStatus(bool checked, bool ready) => !checked
      ? _UiStatus.neutral
      : ready
      ? _UiStatus.success
      : _UiStatus.warning;

  Color _statusColor(_UiStatus status) => switch (status) {
    _UiStatus.success => const Color(0xFF15803D),
    _UiStatus.warning => const Color(0xFFB45309),
    _UiStatus.danger => const Color(0xFFB91C1C),
    _UiStatus.active => const Color(0xFF5B21B6),
    _UiStatus.neutral => const Color(0xFF64748B),
  };

  String _motionDisplayName(NavguardAiMotionLabel value) => switch (value) {
    NavguardAiMotionLabel.stationary => 'Stationary',
    NavguardAiMotionLabel.straightWalk => 'Straight Walk',
    NavguardAiMotionLabel.turning => 'Turning',
    NavguardAiMotionLabel.unstableMotion => 'Unstable Motion',
  };
}
