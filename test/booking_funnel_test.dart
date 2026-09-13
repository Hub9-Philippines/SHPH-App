import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:serbisyohubph/pages/booking_funnel/booking_controller.dart';
import 'package:serbisyohubph/pages/booking_funnel/booking_models.dart';
import 'package:serbisyohubph/pages/booking_funnel/booking_repository.dart';
import 'package:serbisyohubph/pages/booking_funnel/checkout/checkout_screen.dart';
import 'package:serbisyohubph/pages/booking_funnel/live_matching/live_matching_screen.dart';
import 'package:serbisyohubph/l10n/app_localizations.dart';

class _FakeBookingRepository implements BookingRepository {
  _FakeBookingRepository();

  int liveSearchCalls = 0;
  int reservationCalls = 0;

  @override
  Future<BookingQuote> estimateBooking(BookingDraft draft) async {
    return const BookingQuote(basePrice: 500, total: 500);
  }

  @override
  Future<String> broadcastLiveSearch(BookingDraft draft) async {
    liveSearchCalls++;
    return 'live_fake_id';
  }

  @override
  Future<String> reserveScheduledSlot(BookingDraft draft) async {
    reservationCalls++;
    return 'reservation_fake_id';
  }
}

Widget _buildApp({
  required BookingFlowController controller,
  required Widget child,
}) =>
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ChangeNotifierProvider.value(
        value: controller,
        child: child,
      ),
    );

BookingDraft _draft({
  BookingUrgency urgency = BookingUrgency.rightNow,
  DateTime? scheduledDate,
  TimeOfDay? scheduledTime,
}) =>
    BookingDraft(
      urgency: urgency,
      rooms: 2,
      cleaningType: ServiceType.deep,
      paymentMethod: BookingPaymentMethod.gcash,
      address: const BookingAddress(
        label: 'Home',
        line1: '123 Example Street',
        city: 'Metro Manila',
      ),
      latitude: 14.5995,
      longitude: 120.9842,
      serviceListingId: 1,
      serviceTitle: 'Home cleaning',
      serviceCategoryName: 'Cleaning',
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
    );

void main() {
  testWidgets('Checkout button branches by urgency', (tester) async {
    final controller = BookingFlowController(
      repository: _FakeBookingRepository(),
      initialDraft: _draft(),
    );

    await tester.pumpWidget(
      _buildApp(
        controller: controller,
        child: const CheckoutScreen(showLiveMap: false),
      ),
    );

    expect(find.text('Find Active Cleaner Now'), findsOneWidget);

    controller.setSchedule(
      date: DateTime(2026, 6, 25),
      time: const TimeOfDay(hour: 9, minute: 30),
      urgency: BookingUrgency.scheduled,
    );
    await tester.pump();

    expect(find.text('Confirm & Reserve Slot'), findsOneWidget);
  });

  testWidgets('Checkout invokes live matching path for immediate bookings',
      (tester) async {
    final repository = _FakeBookingRepository();
    final controller = BookingFlowController(
      repository: repository,
      initialDraft: _draft(),
    );

    await tester.pumpWidget(
      _buildApp(
        controller: controller,
        child: const CheckoutScreen(showLiveMap: false),
      ),
    );

    await tester.tap(find.text('Find Active Cleaner Now'));
    await tester.pump();

    expect(repository.liveSearchCalls, 1);
    expect(repository.reservationCalls, 0);
  });

  testWidgets('Checkout invokes reservation path for scheduled bookings',
      (tester) async {
    final repository = _FakeBookingRepository();
    final controller = BookingFlowController(
      repository: repository,
      initialDraft: _draft(
        urgency: BookingUrgency.scheduled,
        scheduledDate: DateTime(2026, 6, 25),
        scheduledTime: const TimeOfDay(hour: 9, minute: 30),
      ),
    );

    await tester.pumpWidget(
      _buildApp(
        controller: controller,
        child: const CheckoutScreen(showLiveMap: false),
      ),
    );

    await tester.tap(find.text('Confirm & Reserve Slot'));
    await tester.pump();

    expect(repository.liveSearchCalls, 0);
    expect(repository.reservationCalls, 1);
  });

  testWidgets('Live matching screen times out after the search window',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LiveMatchingScreen(
          bookingDate: DateTime(2026, 7, 5),
          showMap: false,
        ),
      ),
    );

    expect(find.text('Finding the nearest provider'), findsOneWidget);

    await tester.pump(const Duration(seconds: 541));

    expect(find.text('Providers are busy, try again'), findsOneWidget);
    expect(find.text('Adjust booking'), findsOneWidget);
  });
}
