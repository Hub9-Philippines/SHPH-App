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

  /// POST /api/auth/register/ - direct registration (non-two-step)
  Future<Map<String, dynamic>> register({
    required Map<String, dynamic> payload,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/register/',
      data: payload,
    );
    final data = response.data ?? {};
    await _persistTokens(data);
    return data;
  }

  /// POST /api/auth/register/resend/ - resend registration OTP
  Future<void> registerResend({required Map<String, dynamic> payload}) async {
    await _client.post('/api/auth/register/resend/', data: payload);
  }

  /// POST /api/auth/otp/send/ - send OTP (Firebase-based)
  Future<void> sendOtp({required Map<String, dynamic> payload}) async {
    await _client.post('/api/auth/otp/send/', data: payload);
  }

  /// POST /api/auth/otp/verify/ - verify OTP (Firebase-based)
  Future<Map<String, dynamic>> verifyOtp({
    required Map<String, dynamic> payload,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/otp/verify/',
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

  /// POST /api/auth/phone-login/send/ - send OTP for phone login
  Future<void> sendPhoneLoginOtp({required String phoneNumber}) async {
    await _client.post(
      '/api/auth/phone-login/send/',
      data: {'phone_number': phoneNumber},
    );
  }

  /// POST /api/auth/phone-login/verify/ - verify OTP and login with phone
  Future<Map<String, dynamic>> verifyPhoneLoginOtp({
    required String phoneNumber,
    required String code,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/phone-login/verify/',
      data: {'phone_number': phoneNumber, 'code': code},
    );
    final data = response.data ?? {};
    await _persistTokens(data);
    return data;
  }

  /// POST /api/auth/social/google/ - Google social login via SHPH API
  Future<Map<String, dynamic>> socialGoogle({required String idToken}) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/social/google/',
      data: {'id_token': idToken},
    );
    final data = response.data ?? {};
    await _persistTokens(data);
    return data;
  }

  /// POST /api/auth/supabase-exchange/ - exchange Supabase session for Django tokens
  Future<Map<String, dynamic>> supabaseExchange({
    required String accessToken,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/supabase-exchange/',
      data: {'access_token': accessToken},
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

  /// POST /api/auth/me/skip-kyc/ - skip KYC process
  Future<void> skipKyc() async {
    await _client.post('/api/auth/me/skip-kyc/');
  }

  /// POST /api/auth/biometric/register/options/ - get WebAuthn registration options
  Future<Map<String, dynamic>> biometricRegisterOptions({
    required Map<String, dynamic> payload,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/biometric/register/options/',
      data: payload,
    );
    return response.data ?? {};
  }

  /// POST /api/auth/biometric/register/verify/ - verify WebAuthn registration
  Future<Map<String, dynamic>> biometricRegisterVerify({
    required Map<String, dynamic> payload,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/biometric/register/verify/',
      data: payload,
    );
    return response.data ?? {};
  }

  /// GET /api/auth/biometric/credentials/ - list registered credentials
  Future<List<Map<String, dynamic>>> biometricListCredentials() async {
    final response = await _client.get<List<dynamic>>(
      '/api/auth/biometric/credentials/',
    );
    final data = response.data ?? [];
    return data.whereType<Map<String, dynamic>>().toList();
  }

  /// DELETE /api/auth/biometric/credentials/{id}/ - remove a credential
  Future<void> biometricDeleteCredential(String id) async {
    await _client.delete('/api/auth/biometric/credentials/$id/');
  }

  /// POST /api/auth/biometric/auth/options/ - get WebAuthn auth options
  Future<Map<String, dynamic>> biometricAuthOptions({
    required Map<String, dynamic> payload,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/biometric/auth/options/',
      data: payload,
    );
    return response.data ?? {};
  }

  /// POST /api/auth/biometric/auth/verify/ - verify WebAuthn auth
  Future<Map<String, dynamic>> biometricAuthVerify({
    required Map<String, dynamic> payload,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/biometric/auth/verify/',
      data: payload,
    );
    return response.data ?? {};
  }

  /// GET /api/auth/sessions/ - list active sessions
  Future<List<Map<String, dynamic>>> listSessions() async {
    final response = await _client.get<List<dynamic>>(
      '/api/auth/sessions/',
    );
    final data = response.data ?? [];
    return data.whereType<Map<String, dynamic>>().toList();
  }

  /// DELETE /api/auth/sessions/{sessionId}/ - revoke a specific session
  Future<void> revokeSession(String sessionId) async {
    await _client.delete('/api/auth/sessions/$sessionId/');
  }

  /// DELETE /api/auth/sessions/revoke-all/ - revoke all sessions
  Future<void> revokeAllSessions() async {
    await _client.delete('/api/auth/sessions/revoke-all/');
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
