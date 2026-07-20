import '/api/shph_api_client.dart';
import '/api/shph_token_storage.dart';

/// Auth endpoints from SHPH API.yaml (`/api/auth/*`).
class ShphAuthApi {
  ShphAuthApi._();

  static final ShphAuthApi instance = ShphAuthApi._();
  final _client = ShphApiClient.instance;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/login/',
      data: {'email': email, 'password': password},
    );
    final data = response.data ?? {};
    await _persistTokens(data);
    return data;
  }

  Future<Map<String, dynamic>> registerInitiate({
    required Map<String, dynamic> payload,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/register/initiate/',
      data: payload,
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> registerVerify({
    required Map<String, dynamic> payload,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/register/verify/',
      data: payload,
    );
    final data = response.data ?? {};
    await _persistTokens(data);
    return data;
  }

  Future<void> sendOtpPin({required Map<String, dynamic> payload}) async {
    await _client.post('/api/auth/otp/send-pin/', data: payload);
  }

  Future<Map<String, dynamic>> verifyOtpPin({
    required Map<String, dynamic> payload,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/otp/verify-pin/',
      data: payload,
    );
    final data = response.data ?? {};
    await _persistTokens(data);
    return data;
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response =
        await _client.get<Map<String, dynamic>>('/api/auth/me/');
    return response.data ?? {};
  }

  Future<void> logout() async {
    try {
      await _client.post('/api/auth/logout/');
    } finally {
      await ShphTokenStorage.clear();
    }
  }

  Future<void> requestPasswordReset({required String email}) async {
    await _client.post(
      '/api/auth/password-reset/',
      data: {'email': email},
    );
  }

  Future<void> confirmPasswordReset({
    required Map<String, dynamic> payload,
  }) async {
    await _client.post('/api/auth/password-reset/confirm/', data: payload);
  }

  Future<void> _persistTokens(Map<String, dynamic> data) async {
    final access = data['access'] as String? ?? data['token'] as String?;
    final refresh = data['refresh'] as String?;
    if (access != null) {
      await ShphTokenStorage.saveTokens(
        accessToken: access,
        refreshToken: refresh,
      );
    }
  }
}
