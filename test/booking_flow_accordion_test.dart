import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:serbisyohubph/components/cupertino_ui/app_button.dart';
import 'package:serbisyohubph/l10n/app_localizations.dart';
import 'package:serbisyohubph/models/service_listing.dart';
import 'package:serbisyohubph/pages/booking_funnel/booking_controller.dart';
import 'package:serbisyohubph/pages/booking_funnel/booking_flow_screen.dart';
import 'package:serbisyohubph/pages/booking_funnel/booking_models.dart';
import 'package:serbisyohubph/pages/booking_funnel/widgets/address_banner.dart';
import 'package:serbisyohubph/pages/booking_funnel/widgets/details_stage_content.dart';
import 'package:serbisyohubph/pages/booking_funnel/widgets/review_stage_content.dart';
import 'package:serbisyohubph/pages/booking_funnel/widgets/time_selection_panel.dart';
import 'package:serbisyohubph/pages/booking_payment/booking_payment_widget.dart';

ServiceListing _listing() => ServiceListing(
      id: 7,
      title: 'Home Cleaning',
      categoryName: 'Cleaning',
      description: 'Deep clean',
      basePrice: 500,
    );

Widget _app(Widget home) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );

BookingFlowController _controllerOf(WidgetTester tester) =>
    tester.element(find.byType(AddressBanner)).read<BookingFlowController>();

Future<void> _flushEntryQuote(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets(
      'accordion advances Location → Time → Details → Review one stage at a time',
      (tester) async {
    await tester.pumpWidget(_app(BookingFlowScreen(selectedService: _listing())));
    await _flushEntryQuote(tester);

    expect(find.byType(AddressBanner), findsOneWidget);
    expect(find.byType(TimeSelectionPanel), findsNothing);
    expect(find.byType(DetailsStageContent), findsNothing);
    expect(find.byType(ReviewStageContent), findsNothing);

    await tester.tap(find.widgetWithText(AppButton, 'Continue'));
    await tester.pumpAndSettle();
    expect(find.byType(TimeSelectionPanel), findsOneWidget);
    expect(find.byType(AddressBanner), findsNothing);

    await tester.tap(find.widgetWithText(AppButton, 'Continue'));
    await tester.pumpAndSettle();
    expect(find.byType(DetailsStageContent), findsOneWidget);
    expect(find.byType(TimeSelectionPanel), findsNothing);

    await tester.tap(find.widgetWithText(AppButton, 'Continue'));
    await tester.pumpAndSettle();
    expect(find.byType(ReviewStageContent), findsOneWidget);
    expect(find.byType(DetailsStageContent), findsNothing);
    expect(find.widgetWithText(AppButton, 'Proceed to Payment'), findsOneWidget);
  });

  testWidgets('scheduled drafts block Time advance with a schedule snackbar',
      (tester) async {
    await tester.pumpWidget(_app(BookingFlowScreen(
      selectedService: _listing(),
      initialUrgency: BookingUrgency.scheduled,
    )));
    await _flushEntryQuote(tester);

    await tester.tap(find.widgetWithText(AppButton, 'Continue'));
    await tester.pumpAndSettle();
    expect(find.byType(TimeSelectionPanel), findsOneWidget);

    await tester.tap(find.widgetWithText(AppButton, 'Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 750));

    expect(
      find.text(
        'Please select a scheduled date and time before proceeding.',
      ),
      findsOneWidget,
    );
    expect(find.byType(TimeSelectionPanel), findsOneWidget);
    expect(find.byType(DetailsStageContent), findsNothing);
  });

  testWidgets('Proceed pushes the payment route with the router extras',
      (tester) async {
    Map<String, dynamic>? capturedExtra;
    BuildContext? paymentContext;
    final scheduledDate = DateTime(2026, 10, 4);
    const scheduledTime = TimeOfDay(hour: 10, minute: 30);

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => BookingFlowScreen(
            selectedService: _listing(),
            initialUrgency: BookingUrgency.scheduled,
            initialScheduledDate: scheduledDate,
            initialScheduledTime: scheduledTime,
          ),
        ),
        GoRoute(
          path: '/booking-payment',
          name: BookingPaymentWidget.routeName,
          builder: (context, state) {
            paymentContext = context;
            capturedExtra = state.extra as Map<String, dynamic>?;
            return const SizedBox.shrink();
          },
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await _flushEntryQuote(tester);

    final controller = _controllerOf(tester);
    expect(controller.isLoadingQuote, isFalse);
    // Seed the quote; notify without setSchedule — schedule changes re-trigger
    // a quote refresh, which would overwrite the seeded server quote above.
    controller
      ..serverQuote = const BookingQuote(basePrice: 500, total: 500)
      ..setRooms(2);
    await tester.pump();

    await tester.tap(find.widgetWithText(AppButton, 'Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(AppButton, 'Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(AppButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppButton, 'Proceed to Payment'), findsOneWidget);
    await tester.tap(find.widgetWithText(AppButton, 'Proceed to Payment'));
    await tester.pumpAndSettle();

    expect(capturedExtra, isNotNull);
    expect(capturedExtra!['serviceId'], 7);
    expect(capturedExtra!['serviceName'], 'Home Cleaning');
    expect(capturedExtra!['category'], 'Cleaning');
    expect(capturedExtra!['price'], 'PHP 500');
    expect(capturedExtra!['imageUrl'], isNull);
    expect(capturedExtra!['providerName'], isNull);
    expect(capturedExtra!['providerPhoto'], isNull);
    expect(capturedExtra!['notes'], isNull);
    expect(capturedExtra!['bookingDate'], scheduledDate.toIso8601String());
    expect(
      capturedExtra!['bookingTime'],
      scheduledTime.format(paymentContext!),
    );
  });

  testWidgets('the funnel page renders no GoogleMap', (tester) async {
    await tester.pumpWidget(_app(BookingFlowScreen(selectedService: _listing())));
    await _flushEntryQuote(tester);

    expect(find.byType(GoogleMap), findsNothing);
    expect(find.byType(AddressBanner), findsOneWidget);
  });
}
