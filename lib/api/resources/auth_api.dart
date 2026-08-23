import '/api/shph_api_client.dart';
import '/api/shph_token_storage.dart';

/// Auth endpoints from SHPH API.yaml (`/api/auth/*`).
///
/// Aligned with the web app's `authApi` (`src/services/api.ts`): all auth
/// calls are POST, `session_id` is persisted and sent on refresh/logout, and
/// OTP/phone payloads use `phone_number` + `code`/`pin`.
class ShphAuthApi {
  ShphAuthApi._();

  static final ShphAuthApi instance = ShphAuthApi._();
  final _client = ShphApiClient.instance;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required Map<String, dynamic> deviceInfo,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/login/',
      data: {'email': email, 'password': password, 'device_info': deviceInfo},
    );
    final data = response.data ?? {};
    await _persistTokens(data);
    return data;
  }

  Future<Map<String, dynamic>> registerInitiate({
    required Map<String, dynamic> payload,
    Map<String, dynamic>? deviceInfo,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/register/initiate/',
      data: {
        ...payload,
        if (deviceInfo != null) 'device_info': deviceInfo,
      },
    );
    final data = response.data ?? {};
    await _persistTokens(data);
    return data;
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

  Future<void> registerResend({required String phoneNumber}) async {
    await _client.post(
      '/api/auth/register/resend/',
      data: {'phone_number': phoneNumber},
    );
  }

  Future<void> sendOtpPin({required String phoneNumber}) async {
    await _client.post(
      '/api/auth/otp/send-pin/',
      data: {'phone_number': phoneNumber},
    );
  }

  Future<Map<String, dynamic>> verifyOtpPin({
    required String phoneNumber,
    required String pin,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/otp/verify-pin/',
      data: {'phone_number': phoneNumber, 'pin': pin},
    );
    final data = response.data ?? {};
    await _persistTokens(data);
    return data;
  }

  Future<void> otpSend({required String phoneNumber}) async {
    await _client.post(
      '/api/auth/otp/send/',
      data: {'phone_number': phoneNumber},
    );
  }

  Future<Map<String, dynamic>> otpVerify({
    required String phoneNumber,
    required String code,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/otp/verify/',
      data: {'phone_number': phoneNumber, 'code': code},
    );
    final data = response.data ?? {};
    await _persistTokens(data);
    return data;
  }

  Future<void> phoneLoginSend({required String phoneNumber}) async {
    await _client.post(
      '/api/auth/phone-login/send/',
      data: {'phone_number': phoneNumber},
    );
  }

  Future<Map<String, dynamic>> phoneLoginVerify({
    required String phoneNumber,
    required String pin,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/phone-login/verify/',
      data: {'phone_number': phoneNumber, 'pin': pin},
    );
    final data = response.data ?? {};
    await _persistTokens(data);
    return data;
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/me/',
      data: <String, dynamic>{},
    );
    return response.data ?? {};
  }

  Future<void> logout() async {
    try {
      final sessionId = await ShphTokenStorage.getSessionId();
      await _client.post(
        '/api/auth/logout/',
        data: {'session_id': sessionId},
      );
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
    final sessionId = data['session_id'] as String?;
    if (access != null) {
      await ShphTokenStorage.saveTokens(
        accessToken: access,
        refreshToken: refresh,
        sessionId: sessionId,
      );
    }
  }
}
