import '/api/resources/bookings_api.dart';
import '/services/logging_service.dart';

class ProviderBookingsService {
  ProviderBookingsService._();
  static final ProviderBookingsService instance =
      ProviderBookingsService._();

  final _bookingsApi = ShphBookingsApi.instance;

  Future<Map<String, dynamic>?> getBooking(String id) async {
    try {
      final booking = await _bookingsApi.getBooking(id);
      return {
        'id': booking.id,
        'listing': booking.listing,
        'status': booking.status,
        'listing_title': booking.listingTitle,
        'provider_name': booking.providerName,
        'provider_photo': booking.providerPhoto,
        'client_id': booking.clientId,
        'provider_id': booking.providerId,
        'scheduled_date': booking.scheduledDate,
        'scheduled_time': booking.scheduledTime,
        'scheduled_at': booking.scheduledAt,
        'notes': booking.notes,
        'agreed_price': booking.agreedPrice,
        'total_price': booking.totalPrice,
        'created_at': booking.createdAt,
        'service_listing': booking.serviceListing,
        'client_profile': booking.clientProfile,
      };
    } catch (e) {
      LoggingService.error('Failed to fetch booking: $e',
          tag: 'ProviderBookingsService');
      return null;
    }
  }

  Future<bool> acceptBooking(String id) async {
    try {
      await _bookingsApi.acceptBooking(id);
      return true;
    } catch (e) {
      LoggingService.error('Failed to accept booking: $e',
          tag: 'ProviderBookingsService');
      return false;
    }
  }

  Future<bool> confirmArrival(String id) async {
    try {
      await _bookingsApi.confirmArrival(id);
      return true;
    } catch (e) {
      LoggingService.error('Failed to confirm arrival: $e',
          tag: 'ProviderBookingsService');
      return false;
    }
  }

  Future<bool> startService(String id, {String? pin}) async {
    try {
      await _bookingsApi.startService(id, pin: pin);
      return true;
    } catch (e) {
      LoggingService.error('Failed to start service: $e',
          tag: 'ProviderBookingsService');
      return false;
    }
  }

  Future<bool> completeJob(String id) async {
    try {
      await _bookingsApi.completeJob(id);
      return true;
    } catch (e) {
      LoggingService.error('Failed to complete job: $e',
          tag: 'ProviderBookingsService');
      return false;
    }
  }

  Future<Map<String, dynamic>> updateBooking(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _bookingsApi.updateBooking(id, data: data);
      return data;
    } catch (e) {
      LoggingService.error('Failed to update booking: $e',
          tag: 'ProviderBookingsService');
      return data;
    }
  }

  Future<bool> createReview(
    String bookingId, {
    required int rating,
    String? comment,
  }) async {
    try {
      await _bookingsApi.createReview(bookingId, rating: rating, comment: comment);
      return true;
    } catch (e) {
      LoggingService.error('Failed to create review: $e',
          tag: 'ProviderBookingsService');
      return false;
    }
  }
}
