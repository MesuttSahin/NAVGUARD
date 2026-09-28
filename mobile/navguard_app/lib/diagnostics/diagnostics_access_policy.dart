import 'package:flutter/foundation.dart';

const bool navguardInternalDiagnosticsEnabled = bool.fromEnvironment(
  'NAVGUARD_INTERNAL_DIAGNOSTICS',
  defaultValue: false,
);

bool navguardDiagnosticsAccessAllowed({
  required bool isDebugMode,
  required bool isProfileMode,
  required bool internalDiagnosticsEnabled,
}) => isDebugMode || isProfileMode || internalDiagnosticsEnabled;

bool get navguardDiagnosticsEnabled => navguardDiagnosticsAccessAllowed(
  isDebugMode: kDebugMode,
  isProfileMode: kProfileMode,
  internalDiagnosticsEnabled: navguardInternalDiagnosticsEnabled,
);
