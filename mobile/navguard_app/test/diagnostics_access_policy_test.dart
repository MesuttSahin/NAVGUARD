import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navguard/diagnostics/diagnostics_access_policy.dart';
import 'package:navguard/main.dart';

void main() {
  group('diagnostics access policy', () {
    test('debug and profile builds allow diagnostics', () {
      expect(
        navguardDiagnosticsAccessAllowed(
          isDebugMode: true,
          isProfileMode: false,
          internalDiagnosticsEnabled: false,
        ),
        isTrue,
      );
      expect(
        navguardDiagnosticsAccessAllowed(
          isDebugMode: false,
          isProfileMode: true,
          internalDiagnosticsEnabled: false,
        ),
        isTrue,
      );
    });

    test('default release denies diagnostics', () {
      expect(
        navguardDiagnosticsAccessAllowed(
          isDebugMode: false,
          isProfileMode: false,
          internalDiagnosticsEnabled: false,
        ),
        isFalse,
      );
      expect(navguardInternalDiagnosticsEnabled, isFalse);
    });

    test('explicit internal release flag allows diagnostics', () {
      expect(
        navguardDiagnosticsAccessAllowed(
          isDebugMode: false,
          isProfileMode: false,
          internalDiagnosticsEnabled: true,
        ),
        isTrue,
      );
    });
  });

  testWidgets('public release surface hides internal research controls', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const NavguardApp(
        diagnosticsAccessOverride: false,
        enableLiveMapTiles: false,
      ),
    );

    expect(find.byKey(const Key('public-anchor-setup')), findsOneWidget);
    expect(find.byKey(const Key('open-live-navguard-demo')), findsOneWidget);
    expect(find.byKey(const Key('research-modules-grid')), findsNothing);
    expect(find.byKey(const Key('module-card-accuracyV2')), findsNothing);
    expect(find.byKey(const Key('open-ai-dataset-capture')), findsNothing);
    expect(find.byKey(const Key('accuracy-v2-reset')), findsNothing);
    expect(find.byKey(const Key('ai-clear-dataset')), findsNothing);
  });
}
