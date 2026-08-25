import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:serbisyohubph/api/shph_api_client.dart';
import 'package:serbisyohubph/index.dart' show BookingDetailsWidget;
import 'package:serbisyohubph/pages/booking_funnel/status_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await ShphApiClient.initialize();
  });

  testWidgets('BookingDetailsWidget renders fixture booking 301',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: const BookingDetailsWidget(bookingId: '301')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final ex1 = tester.takeException();
    expect(ex1, isNull, reason: '$ex1');
    await tester.pump(const Duration(seconds: 1));
    final ex2 = tester.takeException();
    expect(ex2, isNull, reason: '$ex2');
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('StatusPage tracking screen renders', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: StatusPage(
          bookingStatus: 'confirmed',
          bookingDate: DateTime(2026, 8, 28),
          providerName: 'Maria Santos',
          serviceTitle: 'Home Electrical Wiring Check',
          bookingReference: '301',
        ),
      ),
    );
    await tester.pump();
    final ex = tester.takeException();
    expect(ex, isNull, reason: '$ex');
    await tester.pump(const Duration(seconds: 1));
    final ex2 = tester.takeException();
    expect(ex2, isNull, reason: '$ex2');
  });
}
