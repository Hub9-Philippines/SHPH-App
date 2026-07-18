import '/api/bridges/api_row_mapper.dart';
import '/api/resources/bookings_api.dart';
import '/backend/shph_db/database/tables/bookings.dart';
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
      LoggingService.error('createBooking failed: $e', tag: 'BookingsService');
      return null;
    }
  }

  Future<List<BookingsRow>> getUserBookings() async {
    try {
      final page = await _bookingsApi.listUserBookings();
      return page.results.map(ApiRowMapper.bookingToRow).toList();
    } catch (e) {
      LoggingService.error('getUserBookings failed: $e',
          tag: 'BookingsService');
      return [];
    }
  }

  Future<List<BookingsRow>> getProviderBookings() async {
    try {
      final page = await _bookingsApi.listBookings();
      return page.results.map(ApiRowMapper.bookingToRow).toList();
    } catch (e) {
      LoggingService.error('getProviderBookings failed: $e',
          tag: 'BookingsService');
      return [];
    }
  }

  Future<bool> updateBookingStatus(String bookingId, String status) async {
    try {
      await _bookingsApi.updateBooking(
        bookingId,
        data: {'status': status},
      );
      return true;
    } catch (e) {
      LoggingService.error('updateBookingStatus failed: $e',
          tag: 'BookingsService');
      return false;
    }
  }

  Future<bool> updateBookingData(
    String bookingId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _bookingsApi.updateBooking(
        bookingId,
        data: data,
      );
      return true;
    } catch (e) {
      LoggingService.error('updateBookingData failed: $e',
          tag: 'BookingsService');
      return false;
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _bookingsApi.cancelBooking(bookingId);
      return true;
    } catch (e) {
      LoggingService.error('cancelBooking failed: $e', tag: 'BookingsService');
      return false;
    }
  }

  Future<BookingsRow?> getBookingById(String bookingId) async {
    try {
      final booking = await _bookingsApi.getBooking(bookingId);
      return ApiRowMapper.bookingToRow(booking);
    } catch (e) {
      LoggingService.error('getBookingById failed: $e', tag: 'BookingsService');
      return null;
    }
  }
}
