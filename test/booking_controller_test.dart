import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/l10n/app_localizations.dart';
import 'package:serbisyohubph/models/service_listing.dart';
import 'package:serbisyohubph/pages/booking_funnel/booking_controller.dart';
import 'package:serbisyohubph/pages/booking_funnel/booking_models.dart';
import 'package:serbisyohubph/pages/booking_funnel/booking_repository.dart';

void main() {
  final listing = ServiceListing(
    id: 101,
    title: 'Standard House Cleaning',
    category: 42,
    categoryName: 'Cleaning',
    basePrice: 500,
  );

  BookingDraft defaultDraft() => const BookingDraft(
        urgency: BookingUrgency.rightNow,
        rooms: 1,
        cleaningType: ServiceType.standard,
        paymentMethod: BookingPaymentMethod.gcash,
        address: BookingAddress(
          label: 'Home',
          line1: '123 Example Street',
          city: 'Metro Manila',
        ),
        latitude: 14.5995,
        longitude: 120.9842,
      );

  group('draft persistence', () {
    test('selecting a service populates the authoritative listing fields', () {
      final controller = BookingFlowController(
        repository: _FakeBookingRepository(),
        initialDraft: defaultDraft(),
      );
      controller.setService(listing);
      expect(controller.hasSelectedService, isTrue);
      expect(controller.draft.serviceListingId, 101);
      expect(controller.draft.serviceTitle, 'Standard House Cleaning');
      expect(controller.draft.serviceCategoryName, 'Cleaning');
    });

    test('landmarks and arrival-code preference are retained', () {
      final controller = BookingFlowController(
        repository: _FakeBookingRepository(),
        initialDraft: defaultDraft(),
      );
      controller.setLandmarks('Near the blue gate');
      controller.setRequireArrivalCode(true);
      expect(controller.draft.landmarks, 'Near the blue gate');
      expect(controller.draft.requireArrivalCode, isTrue);
      expect(controller.draft.address.instructions, 'Near the blue gate');
    });

    test('address updates preserve the draft without clearing other fields',
        () {
      final controller = BookingFlowController(
        repository: _FakeBookingRepository(),
        initialDraft: defaultDraft(),
      );
      controller.setService(listing);
      controller.setLandmarks('Rooftop unit');
      controller.setAddress(
        const BookingAddress(
          label: 'Office',
          line1: '456 New Street',
          city: 'Quezon City',
          instructions: 'Rooftop unit',
        ),
      );
      expect(controller.draft.address.label, 'Office');
      expect(controller.draft.serviceListingId, 101);
    });
  });

  group('timing resolution', () {
    test('scheduled draft resolves from date and time', () {
      final repository = ShphBookingRepository();
      final controller = BookingFlowController(
        repository: repository,
        initialDraft: defaultDraft(),
      );
      controller.setSchedule(
        date: DateTime(2026, 9, 20),
        time: const TimeOfDay(hour: 14, minute: 30),
        urgency: BookingUrgency.scheduled,
      );
      final resolved = repository.resolveScheduledDateTime(controller.draft);
      expect(resolved.year, 2026);
      expect(resolved.month, 9);
      expect(resolved.day, 20);
      expect(resolved.hour, 14);
      expect(resolved.minute, 30);
      expect(controller.hasValidSchedule, isTrue);
    });

    test('rightNow resolves to a short future window', () {
      final repository = ShphBookingRepository();
      final controller = BookingFlowController(
        repository: repository,
        initialDraft: defaultDraft(),
      );
      final resolved = repository.resolveScheduledDateTime(controller.draft);
      expect(resolved.isAfter(DateTime.now()), isTrue);
    });
  });

  group('estimate state', () {
    test('estimate error is captured without clearing the draft', () async {
      final controller = BookingFlowController(
        repository: _FailingEstimateRepository(),
        initialDraft: defaultDraft(),
      );
      controller.setService(listing);
      await controller.refreshQuote();
      expect(controller.quoteError, isNotNull);
      expect(controller.serverQuote, isNull);
      expect(controller.draft.serviceListingId, 101);
    });

    test('successful estimate clears the error and stores the quote',
        () async {
      final controller = BookingFlowController(
        repository: _FakeBookingRepository(),
        initialDraft: defaultDraft(),
      );
      controller.setService(listing);
      await controller.refreshQuote();
      expect(controller.quoteError, isNull);
      expect(controller.serverQuote, isNotNull);
      expect(controller.serverQuote!.total, greaterThan(0));
    });
  });

  group('path selection and duplicate-submit guards', () {
    test('live search path is selected for immediate bookings', () async {
      final repository = _FakeBookingRepository();
      final controller = BookingFlowController(
        repository: repository,
        initialDraft: defaultDraft(),
      );
      controller.setService(listing);
      final ok = await controller.attachLiveSearchToken(
        await _l10n(),
      );
      expect(ok, isTrue);
      expect(repository.liveCalls, 1);
      expect(repository.reservationCalls, 0);
    });

    test('reservation path is selected for scheduled bookings', () async {
      final repository = _FakeBookingRepository();
      final controller = BookingFlowController(
        repository: repository,
        initialDraft: defaultDraft(),
      );
      controller.setService(listing);
      controller.setSchedule(
        date: DateTime(2026, 9, 25),
        time: const TimeOfDay(hour: 9, minute: 0),
        urgency: BookingUrgency.scheduled,
      );
      final ok = await controller.attachReservationToken(await _l10n());
      expect(ok, isTrue);
      expect(repository.reservationCalls, 1);
      expect(repository.liveCalls, 0);
    });

    test('duplicate live submit is ignored while submitting', () async {
      final repository = _SlowBookingRepository();
      final controller = BookingFlowController(
        repository: repository,
        initialDraft: defaultDraft(),
      );
      controller.setService(listing);
      final first = controller.attachLiveSearchToken(await _l10n());
      final second = await controller.attachLiveSearchToken(await _l10n());
      expect(second, isFalse);
      await first;
      expect(repository.liveCalls, 1);
    });

    test('duplicate reservation submit is ignored while submitting', () async {
      final repository = _SlowBookingRepository();
      final controller = BookingFlowController(
        repository: repository,
        initialDraft: defaultDraft(),
      );
      controller.setService(listing);
      controller.setSchedule(
        date: DateTime(2026, 9, 25),
        time: const TimeOfDay(hour: 9, minute: 0),
        urgency: BookingUrgency.scheduled,
      );
      final first = controller.attachReservationToken(await _l10n());
      final second = await controller.attachReservationToken(await _l10n());
      expect(second, isFalse);
      await first;
      expect(repository.reservationCalls, 1);
    });
  });
}

Future<AppLocalizations> _l10n() async {
  return await lookupAppLocalizations(const Locale('en'));
}

class _FakeBookingRepository implements BookingRepository {
  int liveCalls = 0;
  int reservationCalls = 0;

  @override
  Future<BookingQuote> estimateBooking(BookingDraft draft) async =>
      const BookingQuote(basePrice: 500, total: 627.75);

  @override
  Future<String> broadcastLiveSearch(BookingDraft draft) async {
    liveCalls++;
    return 'live-id';
  }

  @override
  Future<String> reserveScheduledSlot(BookingDraft draft) async {
    reservationCalls++;
    return 'reserve-id';
  }
}

class _FailingEstimateRepository extends _FakeBookingRepository {
  @override
  Future<BookingQuote> estimateBooking(BookingDraft draft) async {
    throw StateError('estimate unavailable');
  }
}

class _SlowBookingRepository extends _FakeBookingRepository {
  @override
  Future<String> broadcastLiveSearch(BookingDraft draft) async {
    liveCalls++;
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return 'live-id';
  }

  @override
  Future<String> reserveScheduledSlot(BookingDraft draft) async {
    reservationCalls++;
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return 'reserve-id';
  }
}
