import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:serbisyohubph/pages/booking_funnel/booking_controller.dart';
import 'package:serbisyohubph/pages/booking_funnel/booking_repository.dart';
import 'package:serbisyohubph/pages/booking_funnel/booking_models.dart';

void main() {
  group('BookingQuote API normalization', () {
    test('parses numeric strings from the estimate response', () {
      final quote = BookingQuote.fromApi({
        'base_price': '500.0',
        'time_premium': '90',
        'platform_fee': 25.5,
        'vat': '12.25',
        'total': '627.75',
        'platform_fee_percent': '10',
        'vat_percent': '12',
      });

      expect(quote.basePrice, 500);
      expect(quote.timePremium, 90);
      expect(quote.platformFee, 25.5);
      expect(quote.vat, 12.25);
      expect(quote.total, 627.75);
    });

    test('rejects an estimate without required prices', () {
      expect(
        () => BookingQuote.fromApi({'base_price': '500.0'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('accepts numbers, numeric strings, null, and invalid optional values',
        () {
      expect(bookingNumber(10), 10);
      expect(bookingNumber('10.5'), 10.5);
      expect(bookingNumber(null), isNull);
      expect(bookingNumber('not-a-number'), isNull);
    });
  });

  test('scheduled drafts require both date and time', () {
    final controller = BookingFlowController(
      repository: _NoopBookingRepository(),
      initialDraft: const BookingDraft(
        urgency: BookingUrgency.scheduled,
        rooms: 1,
        cleaningType: ServiceType.standard,
        paymentMethod: BookingPaymentMethod.gcash,
        address: BookingAddress(label: 'Home', line1: '', city: ''),
        latitude: 14.5995,
        longitude: 120.9842,
      ),
    );

    expect(controller.hasValidSchedule, isFalse);
    controller.setSchedule(
      date: DateTime(2026, 9, 10),
      time: const TimeOfDay(hour: 10, minute: 30),
    );
    expect(controller.hasValidSchedule, isTrue);
  });
}

class _NoopBookingRepository implements BookingRepository {
  @override
  Future<BookingQuote> estimateBooking(BookingDraft draft) async =>
      const BookingQuote(basePrice: 500, total: 500);

  @override
  Future<String> broadcastLiveSearch(BookingDraft draft) async => 'live-id';

  @override
  Future<String> reserveScheduledSlot(BookingDraft draft) async => 'reserve-id';
}
