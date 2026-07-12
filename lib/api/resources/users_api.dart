import 'package:dio/dio.dart';
import '/api/shph_api_client.dart';

/// Users endpoints from SHPH API.yaml (`/api/users/*`).
class ShphUsersApi {
  ShphUsersApi._();

  static final ShphUsersApi instance = ShphUsersApi._();
  final _client = ShphApiClient.instance;

  Future<Map<String, dynamic>> getMe() async {
    final response = await _client.get<Map<String, dynamic>>('/api/users/me/');
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> updateMe(Map<String, dynamic> data) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/api/users/me/update/',
      data: data,
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> uploadPhoto(List<int> fileBytes, String fileName) async {
    final formData = FormData.fromMap({
      'photo': MultipartFile.fromBytes(fileBytes, filename: fileName),
    });
    final response = await _client.post<Map<String, dynamic>>(
      '/api/users/me/photo/',
      data: formData,
    );
    return response.data ?? {};
  }

  Future<void> deleteMe() async {
    await _client.delete('/api/users/me/delete/');
  }

  /// POST /api/users/apply-provider/ - apply to become a provider
  Future<Map<String, dynamic>> applyProvider(
    Map<String, dynamic> payload,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/users/apply-provider/',
      data: payload,
    );
    return response.data ?? {};
  }

  /// POST /api/users/enable-client/ - enable client account
  Future<void> enableClient() async {
    await _client.post('/api/users/enable-client/');
  }

  /// POST /api/users/me/phone-change/initiate/ - initiate phone change
  Future<String> initiatePhoneChange({required String newPhone}) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/users/me/phone-change/initiate/',
      data: {'new_phone': newPhone},
    );
    return (response.data?['session_id'] as String?) ?? '';
  }

  /// POST /api/users/me/phone-change/verify/ - verify phone change OTP
  Future<void> verifyPhoneChange({
    required String code,
    required String sessionId,
  }) async {
    await _client.post(
      '/api/users/me/phone-change/verify/',
      data: {'code': code, 'session_id': sessionId},
    );
  }

  /// GET /api/users/payment-methods/ - list payment methods
  Future<List<Map<String, dynamic>>> listPaymentMethods() async {
    final response = await _client.get<List<dynamic>>(
      '/api/users/payment-methods/',
    );
    final data = response.data ?? [];
    return data.whereType<Map<String, dynamic>>().toList();
  }

  /// POST /api/users/payment-methods/ - add a payment method
  Future<Map<String, dynamic>> addPaymentMethod(
    Map<String, dynamic> payload,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/users/payment-methods/',
      data: payload,
    );
    return response.data ?? {};
  }

  /// DELETE /api/users/payment-methods/{id}/ - delete a payment method
  Future<void> deletePaymentMethod(String id) async {
    await _client.delete('/api/users/payment-methods/$id/');
  }

  /// POST /api/users/payment-methods/{id}/set-default/ - set default payment method
  Future<void> setDefaultPaymentMethod(String id) async {
    await _client.post('/api/users/payment-methods/$id/set-default/');
  }

  /// GET /api/users/notification-preferences/ - get notification preferences
  Future<Map<String, dynamic>> getNotificationPreferences() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/users/notification-preferences/',
    );
    return response.data ?? {};
  }

  /// PATCH /api/users/notification-preferences/ - update notification preferences
  Future<Map<String, dynamic>> updateNotificationPreferences(
    Map<String, dynamic> payload,
  ) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/api/users/notification-preferences/',
      data: payload,
    );
    return response.data ?? {};
  }
}
