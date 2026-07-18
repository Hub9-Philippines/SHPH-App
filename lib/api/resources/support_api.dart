import 'package:dio/dio.dart';

import '/api/models/paginated_response.dart';
import '/api/models/support_ticket.dart';
import '/api/shph_api_client.dart';

/// Support endpoints (`/api/support/*`).
class ShphSupportApi {
  ShphSupportApi._();

  static final ShphSupportApi instance = ShphSupportApi._();
  final _client = ShphApiClient.instance;

  /// POST `/api/support/tickets/` — list the current user's support tickets.
  ///
  /// Uses POST (POST-over-GET) since the endpoint returns authenticated data.
  Future<PaginatedResponse<ShphSupportTicket>> listTickets({
    int? page,
    String? status,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/support/tickets/',
      data: {
        if (page != null) 'page': page,
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );
    return PaginatedResponse.fromJson(
      response.data ?? {},
      ShphSupportTicket.fromJson,
    );
  }

  /// GET `/api/support/tickets/<pk>/` — fetch a single ticket.
  Future<ShphSupportTicket> getTicket(int id) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/support/tickets/$id/',
    );
    return ShphSupportTicket.fromJson(response.data ?? {});
  }

  /// POST `/api/support/faq/` — list FAQ entries (POST-over-GET).
  Future<List<ShphFaq>> listFaq({String? category}) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/support/faq/',
      data: {if (category != null && category.isNotEmpty) 'category': category},
    );
    final data = response.data;
    final results = data?['results'];
    if (results is List) {
      return results
          .whereType<Map<String, dynamic>>()
          .map(ShphFaq.fromJson)
          .toList();
    }
    if (data is List) {
      return (data as List)
          .whereType<Map<String, dynamic>>()
          .map(ShphFaq.fromJson)
          .toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> createTicket({
    required String category,
    required String message,
    int? bookingId,
    List<MultipartFile>? attachments,
  }) async {
    final formData = FormData.fromMap({
      'category': category,
      'message': message,
      if (bookingId != null) 'booking': bookingId,
      if (attachments != null && attachments.isNotEmpty)
        'attachments': attachments,
    });

    final response = await _client.post<Map<String, dynamic>>(
      '/api/support/tickets/',
      data: formData,
    );
    return response.data ?? {};
  }
}
