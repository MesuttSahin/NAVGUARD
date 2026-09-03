import 'package:flutter_test/flutter_test.dart';
import 'package:navguard/main.dart';

void main() {
  testWidgets('Sensor diagnostics initial UI smoke test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NavguardApp());

    expect(find.text('NAVGUARD Sensor Diagnostics'), findsOneWidget);

    expect(
      find.text('Capability metadata only — no live sensor sampling.'),
      findsOneWidget,
    );

    expect(find.text('Read Sensor Inventory'), findsOneWidget);

    expect(
      find.text('Press the button to read the runtime sensor inventory.'),
      findsOneWidget,
    );
  });
}
