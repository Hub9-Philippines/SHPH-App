import 'package:flutter/material.dart';

import '/api/resources/bookings_api.dart';
import '/api/resources/ondemand_jobs_api.dart';
import '/backend/supabase/supabase.dart';
import '/services/logging_service.dart';
import 'booking_models.dart';

abstract class BookingRepository {
  Future<String> broadcastLiveSearch(BookingDraft draft);
  Future<String> reserveScheduledSlot(BookingDraft draft);
}

class ShphBookingRepository implements BookingRepository {
  ShphBookingRepository();

  /// Real on-demand job id returned by POST /api/services/on-demand/ (when the
  /// broadcast succeeds). Null when the client is in the fallback path.
  String? lastJobId;
  int? lastProviderCount;
  double? lastEstFeeMin;
  double? lastEstFeeMax;
  bool lastBroadcastSucceeded = false;

  void _resetBroadcastResult() {
    lastJobId = null;
    lastProviderCount = null;
    lastEstFeeMin = null;
    lastEstFeeMax = null;
    lastBroadcastSucceeded = false;
  }

  @override
  Future<String> broadcastLiveSearch(BookingDraft draft) async {
    _resetBroadcastResult();
    final booking = await _createBooking(
      draft,
      notesPrefix: 'Live on-demand broadcast',
      bookingStatus: 'pending',
    );

    await _broadcastOnDemandJob(draft, booking.id);
    return booking.id;
  }

  /// Broadcasts a real on-demand job to nearby providers via the SHPH API.
  /// Populates the real [lastJobId] / [lastProviderCount] / fee estimate so the
  /// UI can show authoritative matching info instead of fabricated numbers.
  Future<void> _broadcastOnDemandJob(BookingDraft draft, String bookingId) async {
    final categoryId = draft.serviceCategoryId;
    if (categoryId == null) {
      LoggingService.warning(
        'On-demand broadcast skipped: no service category id on draft',
        tag: 'BookingRepository',
      );
      return;
    }
    try {
      final payload = <String, dynamic>{
        'category': categoryId,
        'client_lat': draft.latitude,
        'client_lng': draft.longitude,
        'description': draft.serviceTitle ?? 'Service request',
        if ((draft.address.line1).trim().isNotEmpty ||
            (draft.address.city).trim().isNotEmpty)
          'address_detail':
              '${draft.address.line1}, ${draft.address.city}'.trim(),
        'radius_km': _broadcastRadiusKm(draft),
        if (draft.urgency == BookingUrgency.rightNow ||
            draft.urgency == BookingUrgency.laterToday)
          'scheduled_for': _nowIso(),
        'booking_ref': bookingId,
      };

      final response = await ShphOnDemandJobsApi.instance.createJob(payload);
      final jobId = response['job_id'] as String?;
      if (jobId == null || jobId.isEmpty) {
        LoggingService.warning(
          'On-demand broadcast returned no job_id',
          tag: 'BookingRepository',
        );
        return;
      }
      lastJobId = jobId;
      lastProviderCount = (response['provider_count'] as num?)?.toInt();
      lastEstFeeMin = _toDouble(response['estimated_fee_min']);
      lastEstFeeMax = _toDouble(response['estimated_fee_max']);
      lastBroadcastSucceeded = true;
      LoggingService.debug(
        'On-demand broadcast ok: job=$jobId providers=$lastProviderCount',
        tag: 'BookingRepository',
      );
    } catch (e) {
      lastBroadcastSucceeded = false;
      LoggingService.error(
        'On-demand broadcast failed: $e',
        tag: 'BookingRepository',
        error: e,
      );
    }
  }

  static int _broadcastRadiusKm(BookingDraft draft) {
    // Keep the client honest: start with a small radius for ASAP, and let the
    // server drive expand-radius during the search.
    return 4;
  }

  static String _nowIso() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}T'
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:00';
  }

  static double? _toDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
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
      final booking = await ShphBookingsApi.instance.createBooking(
        listingId: listingId,
        scheduledAt: scheduledDateTime,
        notes: notes,
      );

      // Reflect the server-authoritative booking object; the backend computes
      // total_price (readOnly) and owns the real ID.
      return BookingsRow({
        'id': booking.id,
        'listing_id': listingId,
        'scheduled_date': scheduledDateTime.toIso8601String(),
        'notes': notes,
        'status': booking.status.isNotEmpty ? booking.status : bookingStatus,
        'total_price': booking.totalPrice,
      });
    } catch (e) {
      LoggingService.error(
        'SHPH booking creation failed: $e',
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
}
