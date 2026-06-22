import 'package:flutter/material.dart';

import '/backend/supabase/supabase.dart';
import '/services/logging_service.dart';
import 'booking_models.dart';

abstract class BookingRepository {
  Future<String> broadcastLiveSearch(BookingDraft draft);
  Future<String> reserveScheduledSlot(BookingDraft draft);
}

class ShphBookingRepository implements BookingRepository {
  ShphBookingRepository();

  @override
  Future<String> broadcastLiveSearch(BookingDraft draft) async {
    final booking = await _createBooking(
      draft,
      notesPrefix: 'Live provider search',
      bookingStatus: 'pending',
    );
    return booking.id;
  }

  @override
  Future<String> reserveScheduledSlot(BookingDraft draft) async {
    final booking = await _createBooking(
      draft,
      notesPrefix: 'Scheduled provider reservation',
      bookingStatus: 'pending',
    );
    return booking.id;
  }

  Future<BookingsRow> _createBooking(
    BookingDraft draft, {
    required String notesPrefix,
    required String bookingStatus,
  }) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('You must be signed in to create a booking.');
    }

    final listingId = await _resolveServiceListingId(draft);
    final scheduledDateTime = _resolveScheduledDateTime(draft);
    final notes = [
      notesPrefix,
      'Mode: ${bookingStatus == 'pending' ? 'live search' : 'scheduled reserve'}',
      'Service: ${draft.serviceTitle ?? 'Selected service'}',
      'Rooms: ${draft.rooms}',
      'Type: ${draft.cleaningType.name}',
      'Address: ${draft.address.line1}, ${draft.address.city}',
    ].join(' | ');

    try {
      final response = await supabase
          .from('bookings')
          .insert({
            'user_id': userId,
            'service_listing_id': listingId,
            'booking_date':
                scheduledDateTime.toIso8601String().split('T').first,
            'booking_time':
                '${scheduledDateTime.hour.toString().padLeft(2, '0')}:${scheduledDateTime.minute.toString().padLeft(2, '0')}:00',
            'notes': notes,
            'status': bookingStatus,
            'total_price': _estimateTotal(draft),
          })
          .select()
          .single();

      return BookingsRow(response);
    } catch (e) {
      LoggingService.error(
        'Supabase booking insert failed: $e',
        tag: 'BookingRepository',
        error: e,
      );
      rethrow;
    }
  }

  Future<int> _resolveServiceListingId(BookingDraft draft) async {
    final selectedListingId = draft.serviceListingId;
    if (selectedListingId != null) {
      return selectedListingId;
    }
    throw StateError(
        'No service selected for booking. Please choose a service first.');
  }

  DateTime _resolveScheduledDateTime(BookingDraft draft) {
    if (draft.scheduledDate != null && draft.scheduledTime != null) {
      return DateTime(
        draft.scheduledDate!.year,
        draft.scheduledDate!.month,
        draft.scheduledDate!.day,
        draft.scheduledTime!.hour,
        draft.scheduledTime!.minute,
      );
    }

    final now = DateTime.now();
    if (draft.urgency == BookingUrgency.rightNow) {
      return now.add(const Duration(minutes: 10));
    }
    if (draft.urgency == BookingUrgency.laterToday) {
      final time = draft.scheduledTime ?? TimeOfDay.now();
      return DateTime(now.year, now.month, now.day, time.hour, time.minute);
    }
    return now.add(const Duration(days: 1));
  }

  double _estimateTotal(BookingDraft draft) {
    const base = 599.0;
    final roomSubtotal = (draft.rooms - 1) * 180.0;
    final typeAdjustment = switch (draft.cleaningType) {
      ServiceType.standard => 0.0,
      ServiceType.deep => 220.0,
      ServiceType.premium => 390.0,
    };
    final urgencyAdjustment = switch (draft.urgency) {
      BookingUrgency.rightNow => 120.0,
      BookingUrgency.laterToday => 80.0,
      BookingUrgency.scheduled => -50.0,
    };

    return base + roomSubtotal + typeAdjustment + urgencyAdjustment;
  }
}
