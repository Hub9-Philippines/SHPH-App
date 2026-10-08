import '/api/shph_api_client.dart';

/// Calls endpoints from SHPH API (`/api/v1/calls/*`).
class ShphCallsApi {
  ShphCallsApi._();

  static final ShphCallsApi instance = ShphCallsApi._();
  final _client = ShphApiClient.instance;

  /// Fetches historical call sessions for the authenticated user (`GET /api/v1/calls/history`).
  Future<List<dynamic>> getCallHistory() async {
    try {
      final response = await _client.get<dynamic>('/api/v1/calls/history');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        return data['data'] as List<dynamic>;
      } else if (data is List) {
        return data;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Initiates an audio or video call (`POST /api/v1/calls/initiate`).
  Future<Map<String, dynamic>> initiateCall({
    required String receiverId,
    String? bookingId,
    String callType = 'video',
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/calls/initiate',
      data: {
        'receiver_id': receiverId,
        if (bookingId != null) 'booking_id': bookingId,
        'call_type': callType,
      },
    );
    return response.data ?? {};
  }

  /// Fetches current active ringing incoming call (`GET /api/v1/calls/active`).
  Future<Map<String, dynamic>?> getActiveCall() async {
    final response = await _client.get<Map<String, dynamic>>('/api/v1/calls/active');
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      return data['data'] as Map<String, dynamic>?;
    }
    return data;
  }

  /// Updates call lifecycle status (`PATCH /api/v1/calls/:id/status`).
  Future<Map<String, dynamic>> updateCallStatus(String callId, String status) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/api/v1/calls/$callId/status',
      data: {'status': status},
    );
    return response.data ?? {};
  }
}
