import '/api/models/session.dart';
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
    final response = await _client.get<Map<String, dynamic>>('/api/auth/me/');
    return response.data ?? {};
  }

  /// Exchange a refresh token for a new access token.
  Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
    String? sessionId,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/token/refresh/',
      data: {
        'refresh': refreshToken,
        if (sessionId != null) 'session_id': sessionId,
      },
    );
    final data = response.data ?? {};
    await _persistTokens(data);
    return data;
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

  Future<void> updateEmail({required String email}) async {
    await _client.post<Map<String, dynamic>>(
      '/api/auth/update-email/',
      data: {'email': email},
    );
  }

  Future<void> updatePassword({required String newPassword}) async {
    await _client.post<Map<String, dynamic>>(
      '/api/auth/update-password/',
      data: {'new_password': newPassword},
    );
  }

  Future<void> sendEmailVerification() async {
    await _client.post('/api/auth/verify-email/resend/');
  }

  // ─── Sessions ─────────────────────────────────────────────────────────────

  /// POST `/api/auth/sessions/` — list active sessions (POST-over-GET).
  Future<List<ShphSession>> listSessions() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/sessions/',
    );
    final data = response.data;
    final results = data?['results'];
    if (results is List) {
      return results
          .whereType<Map<String, dynamic>>()
          .map(ShphSession.fromJson)
          .toList();
    }
    if (data is List) {
      return (data as List)
          .whereType<Map<String, dynamic>>()
          .map(ShphSession.fromJson)
          .toList();
    }
    return [];
  }

  /// POST `/api/auth/sessions/<sessionId>/` — revoke a single session.
  Future<void> revokeSession(String sessionId) async {
    await _client.post('/api/auth/sessions/$sessionId/');
  }

  /// POST `/api/auth/sessions/revoke-all/` — revoke all other sessions.
  Future<void> revokeAllSessions() async {
    await _client.post('/api/auth/sessions/revoke-all/');
  }

  // ─── Biometric (WebAuthn passkeys) ────────────────────────────────────────

  /// POST `/api/auth/biometric/register/options/` — start passkey enrollment.
  Future<Map<String, dynamic>> biometricRegisterOptions({
    required String deviceName,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/biometric/register/options/',
      data: {'device_name': deviceName},
    );
    return response.data ?? {};
  }

  /// POST `/api/auth/biometric/register/verify/` — complete passkey enrollment.
  Future<Map<String, dynamic>> biometricRegisterVerify({
    required Map<String, dynamic> attestation,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/biometric/register/verify/',
      data: attestation,
    );
    return response.data ?? {};
  }

  /// POST `/api/auth/biometric/auth/options/` — start passkey auth.
  Future<Map<String, dynamic>> biometricAuthOptions() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/biometric/auth/options/',
    );
    return response.data ?? {};
  }

  /// POST `/api/auth/biometric/auth/verify/` — complete passkey auth (login).
  Future<Map<String, dynamic>> biometricAuthVerify({
    required Map<String, dynamic> assertion,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/biometric/auth/verify/',
      data: assertion,
    );
    final data = response.data ?? {};
    await _persistTokens(data);
    return data;
  }

  /// POST `/api/auth/biometric/credentials/` — list registered passkeys.
  Future<List<ShphBiometricCredential>> listBiometricCredentials() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/biometric/credentials/',
    );
    final data = response.data;
    final results = data?['results'];
    if (results is List) {
      return results
          .whereType<Map<String, dynamic>>()
          .map(ShphBiometricCredential.fromJson)
          .toList();
    }
    if (data is List) {
      return (data as List)
          .whereType<Map<String, dynamic>>()
          .map(ShphBiometricCredential.fromJson)
          .toList();
    }
    return [];
  }

  /// DELETE `/api/auth/biometric/credentials/<pk>/` — remove a passkey.
  Future<void> deleteBiometricCredential(int id) async {
    await _client.delete('/api/auth/biometric/credentials/$id/');
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
