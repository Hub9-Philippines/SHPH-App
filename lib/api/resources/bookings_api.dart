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

  Future<void> cancelBooking(String id) async {
    await updateBooking(id, data: {'status': 'cancelled'});
  }

  Future<void> confirmArrival(String id) async {
    await _client.post('/api/services/bookings/$id/confirm-arrival/');
  }

  Future<void> startService(String id, {String? pin}) async {
    await _client.post(
      '/api/services/bookings/$id/start/',
      data: {if (pin != null) 'pin': pin},
    );
  }

  Future<void> completeJob(String id) async {
    await _client.post('/api/services/bookings/$id/complete/');
  }

  Future<void> uploadCompletionPhoto(String id, String filePath) async {
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(filePath),
    });
    await _client.post(
      '/api/services/bookings/$id/upload-photo/',
      data: formData,
    );
  }

  Future<void> updatePartsCost(
    String id, {
    required double cost,
    String? description,
  }) async {
    await _client.post(
      '/api/services/bookings/$id/parts-cost/',
      data: {
        'cost': cost,
        if (description != null && description.isNotEmpty)
          'description': description,
      },
    );
  }

  Future<void> createReview(
    String id, {
    required int rating,
    String? comment,
  }) async {
    await _client.post(
      '/api/services/bookings/$id/review/',
      data: {
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
    );
  }
}
