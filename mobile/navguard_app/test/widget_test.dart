import 'package:flutter_test/flutter_test.dart';
import 'package:navguard/main.dart';

void main() {
  testWidgets('Combined sensor diagnostic initial UI smoke test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NavguardApp());

    expect(find.text('NAVGUARD Sensor Diagnostics'), findsOneWidget);

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

    expect(
      find.text(
        'Run an inventory or timing diagnostic to display its JSON summary.',
      ),
      findsOneWidget,
    );
  });
}
