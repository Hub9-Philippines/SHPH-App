import '/api/shph_api_client.dart';

class ShphSupportApi {
  ShphSupportApi._();

  static final ShphSupportApi instance = ShphSupportApi._();
  final _client = ShphApiClient.instance;

  Future<List<Map<String, dynamic>>> listFaq() async {
    final response = await _client.get<dynamic>('/api/support/faq/');
    final data = response.data;
    final rows = data is List ? data : (data is Map ? data['results'] : null);
    return (rows as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  Future<Map<String, dynamic>> listTickets({int? page}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/support/tickets/',
      queryParameters: {if (page != null) 'page': page},
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> createTicket(
      Map<String, dynamic> payload) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/support/tickets/',
      data: payload,
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getTicket(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/support/tickets/$id/',
    );
    return response.data ?? {};
  }

  Future<String> chat({
    required String message,
    required List<Map<String, String>> history,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/support/chatbot/',
      data: {'message': message, 'history': history},
    );
    final reply = response.data?['reply']?.toString().trim();
    if (reply == null || reply.isEmpty) {
      throw StateError('The chat API returned an empty response');
    }
    return reply;
  }
}
