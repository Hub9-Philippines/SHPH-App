import '/backend/supabase/supabase.dart';
import '/services/logging_service.dart';

class BookingsService {
  BookingsService._();
  static final BookingsService instance = BookingsService._();

  final _supabase = Supabase.instance.client;

  // Get current user ID
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  // Create a new booking
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
      final userId = _currentUserId;
      if (userId == null) {
        return null;
      }

      // Get service listing to get provider info
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

  // Get all bookings for current user
  Future<List<BookingsRow>> getUserBookings() async {
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

  // Get bookings for provider
  Future<List<BookingsRow>> getProviderBookings() async {
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

  // Update booking status
  Future<bool> updateBookingStatus(String bookingId, String status) async {
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

  // Cancel booking
  Future<bool> cancelBooking(String bookingId) async {
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

  // Get booking by ID
  Future<BookingsRow?> getBookingById(String bookingId) async {
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
