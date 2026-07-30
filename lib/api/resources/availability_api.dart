import '/api/shph_api_client.dart';

/// Provider availability endpoints for the SHPH API.
class ShphAvailabilityApi {
  ShphAvailabilityApi._();

  static final ShphAvailabilityApi instance = ShphAvailabilityApi._();
  final _client = ShphApiClient.instance;

  Future<Map<String, dynamic>> getAvailability({
    String? providerId,
    String? date,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/services/availability/',
      queryParameters: {
        if (providerId != null) 'provider': providerId,
        if (date != null) 'date': date,
      },
    );
    return response.data ?? {};
  }

  Future<List<Map<String, dynamic>>> listSlots({
    String? providerId,
    String? date,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/services/availability/slots/',
      queryParameters: {
        if (providerId != null) 'provider': providerId,
        if (date != null) 'date': date,
      },
    );
    final results = response.data?['results'];
    if (results is List) {
      return results.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> createSlot({
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/availability/slots/',
      data: {
        'date': date,
        'start_time': startTime,
        'end_time': endTime,
      },
    );
    return response.data ?? {};
  }

  Future<void> deleteSlot(String slotId) async {
    await _client.delete('/api/services/availability/slots/$slotId/');
  }

  Future<void> toggleSlot(String slotId, {bool? isAvailable}) async {
    await _client.patch(
      '/api/services/availability/slots/$slotId/',
      data: {if (isAvailable != null) 'is_available': isAvailable},
    );
  }
}
