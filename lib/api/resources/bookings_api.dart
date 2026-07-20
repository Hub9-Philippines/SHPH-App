import 'package:dio/dio.dart';
import '/api/models/booking.dart';
import '/api/models/paginated_response.dart';
import '/api/shph_api_client.dart';

/// Bookings endpoints from SHPH API.yaml (`/api/services/bookings/*`).
class ShphBookingsApi {
  ShphBookingsApi._();

  static final ShphBookingsApi instance = ShphBookingsApi._();
  final _client = ShphApiClient.instance;

  Future<PaginatedResponse<ShphBooking>> listBookings({int? page}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/services/bookings/',
      queryParameters: {if (page != null) 'page': page},
    );
    return PaginatedResponse.fromJson(
      response.data ?? {},
      ShphBooking.fromJson,
    );
  }

  Future<PaginatedResponse<ShphBooking>> listUserBookings({int? page}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/services/bookings/list/',
      queryParameters: {if (page != null) 'page': page},
    );
    return PaginatedResponse.fromJson(
      response.data ?? {},
      ShphBooking.fromJson,
    );
  }

  Future<ShphBooking> createBooking({
    required int listingId,
    String? scheduledDate,
    String? scheduledTime,
    String? notes,
    double? totalPrice,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/bookings/',
      data: ShphBooking(
        id: '',
        listing: listingId,
        status: 'pending',
      ).toCreateJson(
        listingId: listingId,
        scheduledDate: scheduledDate,
        scheduledTime: scheduledTime,
        notes: notes,
        totalPrice: totalPrice,
      ),
    );
    return ShphBooking.fromJson(response.data ?? {});
  }

  Future<ShphBooking> getBooking(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/services/bookings/$id/',
    );
    return ShphBooking.fromJson(response.data ?? {});
  }

  Future<ShphBooking> updateBooking(
    String id, {
    required Map<String, dynamic> data,
  }) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/api/services/bookings/$id/',
      data: data,
    );
    return ShphBooking.fromJson(response.data ?? {});
  }

  Future<void> acceptBooking(String id) async {
    await _client.post('/api/services/bookings/$id/accept/');
  }

  Future<void> rejectBooking(String id, {String? reason}) async {
    await _client.post(
      '/api/services/bookings/$id/reject/',
      data: {if (reason != null) 'reason': reason},
    );
  }

  /// POST /api/services/bookings/{id}/cancel/ - cancel a booking
  Future<void> cancelBooking(String id, {String? reason}) async {
    await _client.post(
      '/api/services/bookings/$id/cancel/',
      data: {if (reason != null) 'reason': reason},
    );
  }

  /// POST /api/services/bookings/estimate/ - get booking price estimate
  Future<Map<String, dynamic>> estimateBooking({
    required int listingId,
    String? scheduledDate,
    String? scheduledTime,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/bookings/estimate/',
      data: {
        'listing_id': listingId,
        if (scheduledDate != null) 'scheduled_date': scheduledDate,
        if (scheduledTime != null) 'scheduled_time': scheduledTime,
      },
    );
    return response.data ?? {};
  }

  /// POST /api/services/bookings/{id}/reschedule/ - reschedule a booking
  Future<ShphBooking> rescheduleBooking(
    String id, {
    required String newDate,
    String? newTime,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/bookings/$id/reschedule/',
      data: {
        'new_date': newDate,
        if (newTime != null) 'new_time': newTime,
      },
    );
    return ShphBooking.fromJson(response.data ?? {});
  }

  /// POST /api/services/bookings/{id}/review/ - leave a review for a booking
  Future<Map<String, dynamic>> reviewBooking(
    String id, {
    required int rating,
    String? comment,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/bookings/$id/review/',
      data: {
        'rating': rating,
        if (comment != null) 'comment': comment,
      },
    );
    return response.data ?? {};
  }

  /// POST /api/services/bookings/{id}/share-eta/ - create/reuse ETA share token
  Future<Map<String, dynamic>> shareEta(String id) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/bookings/$id/share-eta/',
      data: {},
    );
    return response.data ?? {};
  }

  /// GET /api/services/eta/{token}/ - public ETA tracking (no auth required)
  Future<Map<String, dynamic>> getEtaPublic(String token) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/services/eta/$token/',
    );
    return response.data ?? {};
  }

  /// GET /api/services/bookings/{id}/invoice/ - get booking invoice
  Future<Map<String, dynamic>> getInvoice(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/services/bookings/$id/invoice/',
    );
    return response.data ?? {};
  }

  /// POST /api/services/bookings/{id}/approve-parts-cost/ - approve parts cost
  Future<void> approvePartsCost(String id) async {
    await _client.post('/api/services/bookings/$id/approve-parts-cost/');
  }

  /// POST /api/services/bookings/{id}/reject-parts-cost/ - reject parts cost
  Future<void> rejectPartsCost(String id, {String? reason}) async {
    await _client.post(
      '/api/services/bookings/$id/reject-parts-cost/',
      data: {if (reason != null) 'reason': reason},
    );
  }

  /// POST /api/services/bookings/{id}/complete-photo/ - upload completion photo
  Future<void> completePhoto(
    String id, {
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'photo': MultipartFile.fromBytes(fileBytes, filename: fileName),
    });
    await _client.post(
      '/api/services/bookings/$id/complete-photo/',
      data: formData,
    );
  }

  /// PATCH /api/services/bookings/{id}/location/ - update provider location
  Future<void> updateBookingLocation(
    String id, {
    required double lat,
    required double lng,
  }) async {
    await _client.patch(
      '/api/services/bookings/$id/location/',
      data: {'lat': lat, 'lng': lng},
    );
  }
}
