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
    expect(find.text('GPS provider: Unknown'), findsNWidgets(2));
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
    expect(find.text('Rotation Vector: Unknown'), findsNWidgets(2));
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
    expect(find.text('Step Detector: Unknown'), findsNWidgets(2));
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
    expect(find.text('Integrated steps: Not available'), findsOneWidget);
    expect(find.text('Unassociated steps: Not available'), findsOneWidget);
    expect(find.text('Final East: Not available'), findsOneWidget);
    expect(find.text('Final North: Not available'), findsOneWidget);
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
  });
}
