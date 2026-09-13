import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:serbisyohubph/l10n/app_localizations.dart';
import 'package:serbisyohubph/pages/booking_funnel/booking_controller.dart';
import 'package:serbisyohubph/pages/booking_funnel/booking_models.dart';
import 'package:serbisyohubph/pages/booking_funnel/booking_repository.dart';
import 'package:serbisyohubph/pages/booking_funnel/setup/booking_setup_screen.dart';

void main() {
  Widget wrap(BookingFlowController controller, Widget child) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ChangeNotifierProvider.value(value: controller, child: child),
      );

  BookingFlowController controller({
    BookingRepository? repository,
    BookingUrgency urgency = BookingUrgency.scheduled,
  }) =>
      BookingFlowController(
        repository: repository ?? _FakeBookingRepository(),
        initialDraft: BookingDraft(
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
          scheduledDate: DateTime(2026, 9, 20),
          scheduledTime: const TimeOfDay(hour: 10, minute: 30),
        ),
      );

  testWidgets('details step renders landmarks and arrival-code control',
      (tester) async {
    final ctrl = controller();
    await tester.pumpWidget(wrap(ctrl, const BookingSetupScreen()));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byType(CupertinoSwitch),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Landmarks'), findsWidgets);
    expect(find.byType(CupertinoSwitch), findsOneWidget);
  });

  testWidgets('details step preserves landmarks typed by the user',
      (tester) async {
    final ctrl = controller();
    await tester.pumpWidget(wrap(ctrl, const BookingSetupScreen()));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byType(CupertinoTextField),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(
      find.byType(CupertinoTextField).first,
      'Near the blue gate',
    );
    await tester.pump();
    expect(ctrl.draft.landmarks, 'Near the blue gate');
  });

  testWidgets('estimate error shows retry and does not clear the draft',
      (tester) async {
    final ctrl = controller(repository: _FailingEstimateRepository());
    await ctrl.refreshQuote();
    expect(ctrl.quoteError, isNotNull);

    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(ctrl, const BookingSetupScreen()));
    await tester.pumpAndSettle();

    expect(
      find.text("Couldn't load the price estimate. Your draft is saved - retry or go back."),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
    expect(ctrl.draft.serviceListingId, 1);
  });
}

class _FakeBookingRepository implements BookingRepository {
  @override
  Future<BookingQuote> estimateBooking(BookingDraft draft) async =>
      const BookingQuote(basePrice: 500, total: 627.75);

  @override
  Future<String> broadcastLiveSearch(BookingDraft draft) async => 'live-id';

  @override
  Future<String> reserveScheduledSlot(BookingDraft draft) async => 'reserve-id';
}

class _FailingEstimateRepository extends _FakeBookingRepository {
  @override
  Future<BookingQuote> estimateBooking(BookingDraft draft) async {
    throw StateError('estimate unavailable');
  }
}
