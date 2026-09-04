import 'package:flutter_test/flutter_test.dart';
import 'package:navguard/main.dart';

void main() {
  testWidgets('shows the initial runtime diagnostics UI', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NavguardApp());

    expect(find.text('NAVGUARD Runtime Diagnostics'), findsOneWidget);
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
    expect(find.text('GPS provider: Unknown'), findsOneWidget);
    expect(find.text('Location services: Unknown'), findsOneWidget);
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
  });
}
