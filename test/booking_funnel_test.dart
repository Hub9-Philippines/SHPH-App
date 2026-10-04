import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:serbisyohubph/pages/booking_funnel/booking_controller.dart';
import 'package:serbisyohubph/pages/booking_funnel/booking_models.dart';
import 'package:serbisyohubph/pages/booking_funnel/booking_repository.dart';
import 'package:serbisyohubph/pages/booking_funnel/checkout/checkout_screen.dart';
import 'package:serbisyohubph/pages/booking_funnel/live_matching/live_matching_screen.dart';
import 'package:serbisyohubph/pages/booking_funnel/widgets/booking_map_sheet_host.dart';
import 'package:serbisyohubph/l10n/app_localizations.dart';
import 'package:serbisyohubph/models/service_listing.dart';
import 'package:serbisyohubph/pages/booking_funnel/booking_flow_screen.dart';

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
    expect(find.text('Search again'), findsOneWidget);
    expect(find.text('Schedule instead'), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(0, -200));
    await tester.pump();
    expect(find.text('Cancel search'), findsOneWidget);
  });

  testWidgets('Live matching shows retryable failure card after broadcast error',
      (tester) async {
    final repo = ShphBookingRepository()..lastBroadcastError = 'boom';
    final controller = BookingFlowController(
      repository: repo,
      initialDraft: _draft(),
    );

    await tester.pumpWidget(
      _buildApp(
        controller: controller,
        child: LiveMatchingScreen(
          bookingDate: DateTime(2026, 7, 5),
          showMap: false,
        ),
      ),
    );
    expect(find.text('Live matching unavailable'), findsOneWidget);
    expect(find.text('Retry live search'), findsOneWidget);
    expect(find.text('View booking details'), findsOneWidget);
  });

  testWidgets('Checkout button branches by dispatchMode', (tester) async {
    final controller = BookingFlowController(
      repository: _FakeBookingRepository(),
      initialDraft: _draft(urgency: BookingUrgency.rightNow),
    );

    await tester.pumpWidget(
      _buildApp(
        controller: controller,
        child: const CheckoutScreen(showLiveMap: false),
      ),
    );

    expect(find.text('Find Active Cleaner Now'), findsOneWidget);

    controller.setDispatchMode(BookingDispatchMode.scheduled);
    controller.setSchedule(
      date: DateTime(2026, 6, 25),
      time: const TimeOfDay(hour: 9, minute: 30),
      urgency: BookingUrgency.scheduled,
    );
    await tester.pump();

    expect(find.text('Confirm & Reserve Slot'), findsOneWidget);
  });

  testWidgets(
      'BookingMapSheetHost derives camera padding keeping pin area unoccluded',
      (tester) async {
    EdgeInsets? derivedPadding;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 800,
            width: 400,
            child: BookingMapSheetHost(
              includeBottomSafeArea: false,
              includeTopSafeArea: false,
              topCameraPadding: 80,
              bottomCameraPadding: 20,
              maxSheetFraction: 0.7,
              mapBuilder: (context, padding) {
                derivedPadding = padding;
                return const SizedBox.expand();
              },
              sheet: const SizedBox(height: 300, key: Key('bottom_sheet')),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(derivedPadding, isNotNull);
    // Bottom padding equals sheet height (300) + bottomCameraPadding (20) = 320
    expect(derivedPadding!.bottom, 320);
    // Top padding equals 80
    expect(derivedPadding!.top, 80);
    // Visible map area height: 800 - 320 - 80 = 400px entirely free of occlusion!
    final visibleHeight = 800 - derivedPadding!.bottom - derivedPadding!.top;
    expect(visibleHeight, 400);
  });

  testWidgets('BookingFlowScreen renders without error', (tester) async {
    final listing = ServiceListing(
      id: 1,
      title: 'Home Cleaning',
      categoryName: 'Cleaning',
      description: 'Test description',
      basePrice: 500,
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BookingFlowScreen(selectedService: listing),
      ),
    );
    await tester.pump();
    expect(find.byType(BookingFlowScreen), findsOneWidget);
  });
}
