import '/api/bridges/api_row_mapper.dart';
import '/api/resources/bookings_api.dart';
import '/backend/supabase/supabase.dart';
import '/services/logging_service.dart';

class BookingsService {
  BookingsService._();
  static final BookingsService instance = BookingsService._();

  final _supabase = Supabase.instance.client;
  final _bookingsApi = ShphBookingsApi.instance;

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  Future<BookingsRow?> createBooking({
    required int serviceListingId,
    required DateTime bookingDate,
    required String bookingTime,
    int? addressId,
    String? notes,
    double? totalPrice,
    String? paymentStatus,
  }) async {
    if (await ApiRowMapper.canUseApi()) {
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
        LoggingService.error(
          'SHPH API createBooking failed, falling back to Supabase: $e',
          tag: 'BookingsService',
        );
      }
    }

    try {
      final userId = _currentUserId;
      if (userId == null) {
        return null;
      }

      final serviceListing = await _supabase
          .from('service_listings')
          .select()
          .eq('id', serviceListingId)
          .single();

      final booking = await _supabase
          .from('bookings')
          .insert({
            'user_id': userId,
            'service_listing_id': serviceListingId,
            'provider_id': serviceListing['provider'],
            'booking_date': bookingDate.toIso8601String(),
            'booking_time': bookingTime,
            'address_id': addressId,
            'notes': notes,
            'status': 'pending',
            'total_price': totalPrice,
            'payment_status': paymentStatus ?? 'pending',
          })
          .select()
          .single();

      return BookingsRow(booking);
    } catch (e) {
      LoggingService.error('Error creating booking: $e',
          tag: 'BookingsService');
      return null;
    }
  }

  Future<List<BookingsRow>> getUserBookings() async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        final page = await _bookingsApi.listUserBookings();
        return page.results.map(ApiRowMapper.bookingToRow).toList();
      } catch (e) {
        LoggingService.error(
          'SHPH API getUserBookings failed, falling back to Supabase: $e',
          tag: 'BookingsService',
        );
      }
    }

    try {
      final userId = _currentUserId;
      if (userId == null) {
        return [];
      }

      final response = await _supabase
          .from('bookings')
          .select('*, service_listings(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map(BookingsRow.new).toList();
    } catch (e) {
      LoggingService.error('Error fetching bookings: $e',
          tag: 'BookingsService');
      return [];
    }
  }

  Future<List<BookingsRow>> getProviderBookings() async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        final page = await _bookingsApi.listBookings();
        return page.results.map(ApiRowMapper.bookingToRow).toList();
      } catch (e) {
        LoggingService.error(
          'SHPH API getProviderBookings failed, falling back to Supabase: $e',
          tag: 'BookingsService',
        );
      }
    }

    try {
      final userId = _currentUserId;
      if (userId == null) {
        return [];
      }

      final response = await _supabase
          .from('bookings')
          .select('*, service_listings(*), profiles!bookings_user_id_fkey(*)')
          .eq('provider_id', userId)
          .order('created_at', ascending: false);

      return response.map(BookingsRow.new).toList();
    } catch (e) {
      LoggingService.error('Error fetching provider bookings: $e',
          tag: 'BookingsService');
      return [];
    }
  }

  Future<bool> updateBookingStatus(String bookingId, String status) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        await _bookingsApi.updateBooking(
          bookingId,
          data: {'status': status},
        );
        return true;
      } catch (e) {
        LoggingService.error(
          'SHPH API updateBookingStatus failed, falling back to Supabase: $e',
          tag: 'BookingsService',
        );
      }
    }

    try {
      await _supabase
          .from('bookings')
          .update({'status': status}).eq('id', bookingId);

      return true;
    } catch (e) {
      LoggingService.error('Error updating booking status: $e',
          tag: 'BookingsService');
      return false;
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        await _bookingsApi.cancelBooking(bookingId);
        return true;
      } catch (e) {
        LoggingService.error(
          'SHPH API cancelBooking failed, falling back to Supabase: $e',
          tag: 'BookingsService',
        );
      }
    }

    try {
      await _supabase.from('bookings').update({
        'status': 'cancelled',
        'cancelled_at': DateTime.now().toIso8601String(),
      }).eq('id', bookingId);

      return true;
    } catch (e) {
      LoggingService.error('Error cancelling booking: $e',
          tag: 'BookingsService');
      return false;
    }
  }

  Future<BookingsRow?> getBookingById(String bookingId) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        final booking = await _bookingsApi.getBooking(bookingId);
        return ApiRowMapper.bookingToRow(booking);
      } catch (e) {
        LoggingService.error(
          'SHPH API getBookingById failed, falling back to Supabase: $e',
          tag: 'BookingsService',
        );
      }
    }

    try {
      final response = await _supabase
          .from('bookings')
          .select('*, service_listings(*)')
          .eq('id', bookingId)
          .maybeSingle();

      if (response == null) {
        return null;
      }
      return BookingsRow(response);
    } catch (e) {
      LoggingService.error('Error fetching booking: $e',
          tag: 'BookingsService');
      return null;
    }
  }
}
