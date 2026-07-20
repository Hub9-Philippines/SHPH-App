import '/api/bridges/api_row_mapper.dart';
import '/api/resources/bookings_api.dart';
import '/api/resources/payments_api.dart';
import '/api/resources/services_api.dart';
import '/api/resources/wallet_api.dart';
import '/backend/supabase/supabase.dart';
import '/services/logging_service.dart';

class BookingsService {
  BookingsService._();
  static final BookingsService instance = BookingsService._();

  final _bookingsApi = ShphBookingsApi.instance;

  Future<BookingsRow?> createBooking({
    required int serviceListingId,
    required DateTime bookingDate,
    required String bookingTime,
    int? addressId,
    String? notes,
    double? totalPrice,
    String? paymentStatus,
  }) async {
    try {
      final booking = await _bookingsApi.createBooking(
        listingId: serviceListingId,
        scheduledDate: bookingDate.toIso8601String().split('T').first,
        scheduledTime: bookingTime,
        notes: notes,
        totalPrice: totalPrice,
      );
      return ApiRowMapper.bookingToRow(booking);
    } catch (e) {
      LoggingService.error('Error creating booking: $e', tag: 'BookingsService');
      return null;
    }
  }

  Future<List<BookingsRow>> getUserBookings() async {
    try {
      final page = await _bookingsApi.listUserBookings();
      return page.results.map(ApiRowMapper.bookingToRow).toList();
    } catch (e) {
      LoggingService.error('Error fetching bookings: $e', tag: 'BookingsService');
      return [];
    }
  }

  Future<List<BookingsRow>> getProviderBookings() async {
    try {
      final page = await _bookingsApi.listBookings();
      return page.results.map(ApiRowMapper.bookingToRow).toList();
    } catch (e) {
      LoggingService.error('Error fetching provider bookings: $e', tag: 'BookingsService');
      return [];
    }
  }

  Future<Map<String, dynamic>> estimateBooking({
    required int listingId,
    String? scheduledDate,
    String? scheduledTime,
  }) async {
    return _bookingsApi.estimateBooking(
      listingId: listingId,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
    );
  }

  Future<Map<String, dynamic>> rescheduleBooking(
    String id, {
    required String newDate,
    String? newTime,
  }) async {
    final booking = await _bookingsApi.rescheduleBooking(
      id,
      newDate: newDate,
      newTime: newTime,
    );
    return booking.toCreateJson(
      listingId: booking.listing,
      scheduledDate: booking.scheduledDate,
      scheduledTime: booking.scheduledTime,
    );
  }

  Future<List<Map<String, dynamic>>> getAvailableTimeSlots({
    required int listingId,
    required String date,
  }) async {
    return ShphServicesApi.instance.getTimeSlots(
      listingId: listingId,
      date: date,
    );
  }

  Future<bool> updateBookingStatus(String bookingId, String status) async {
    try {
      await _bookingsApi.updateBooking(bookingId, data: {'status': status});
      return true;
    } catch (e) {
      LoggingService.error('Error updating booking status: $e', tag: 'BookingsService');
      return false;
    }
  }

  Future<bool> updateBookingData(
    String bookingId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _bookingsApi.updateBooking(bookingId, data: data);
      return true;
    } catch (e) {
      LoggingService.error('Error updating booking data: $e', tag: 'BookingsService');
      return false;
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _bookingsApi.cancelBooking(bookingId);
      return true;
    } catch (e) {
      LoggingService.error('Error cancelling booking: $e', tag: 'BookingsService');
      return false;
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent({
    required int amount,
    required String currency,
  }) async {
    return ShphPaymentsApi.instance.createPaymentIntent(
      amount: amount,
      currency: currency,
    );
  }

  Future<Map<String, dynamic>> confirmPayment({
    required String paymentIntentId,
    required Map<String, dynamic> paymentDetails,
  }) async {
    return ShphPaymentsApi.instance.confirmPayment(
      paymentIntentId: paymentIntentId,
      paymentDetails: paymentDetails,
    );
  }

  Future<Map<String, dynamic>> getWallet() async {
    return ShphWalletApi.instance.getWallet();
  }

  Future<bool> payWithWallet(String bookingId) async {
    try {
      await ShphWalletApi.instance.payBookingWithWallet(bookingId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<BookingsRow?> getBookingById(String bookingId) async {
    try {
      final booking = await _bookingsApi.getBooking(bookingId);
      return ApiRowMapper.bookingToRow(booking);
    } catch (e) {
      LoggingService.error('Error fetching booking: $e', tag: 'BookingsService');
      return null;
    }
  }
}
