import '/api/api_config.dart';
import '/api/resources/auth_api.dart';
import '/api/shph_api_client.dart';
import '/api/shph_token_storage.dart';
import '/services/logging_service.dart';

/// Bridges Supabase auth flows with SHPH REST API JWT tokens.
class ShphAuthBridge {
  ShphAuthBridge._();

  static final ShphAuthBridge instance = ShphAuthBridge._();

  /// After a successful Supabase email sign-in, obtain SHPH API tokens so
  /// domain services can call the REST API.
  Future<void> syncAfterEmailSignIn({
    required String email,
    required String password,
  }) async {
    if (!ApiConfig.preferShphApi) return;

    try {
      await ShphAuthApi.instance.login(email: email, password: password);
      LoggingService.info('SHPH API tokens synced after sign-in',
          tag: 'ShphAuthBridge');
    } catch (e) {
      LoggingService.error(
        'SHPH API login failed after Supabase sign-in; Supabase fallback remains active: $e',
        tag: 'ShphAuthBridge',
      );
    }
  }

  Future<void> clearOnSignOut() async {
    if (!ApiConfig.preferShphApi) return;
    await ShphTokenStorage.clear();
  }

  /// After social sign-in (Google, Apple, GitHub), exchange the provider token for SHPH JWTs.
  ///
  /// This method handles the token exchange with the SHPH API after successful OAuth.
  /// If [idToken] is provided, it uses the actual provider token. Otherwise, it attempts
  /// to sync using the Supabase session (provider parameter indicates which OAuth provider).
  Future<void> syncAfterSocialSignIn(String providerOrToken,
      {String? provider}) async {
    if (!ApiConfig.preferShphApi) return;

    try {
      final endpoint = provider != null
          ? '/api/auth/social/$provider/'
          : '/api/auth/social/';

      // If idToken is provided (direct provider token), use it
      final data = provider == null
          ? {'id_token': providerOrToken}
          : {'id_token': providerOrToken};

      final resp = await ShphApiClient.instance.post<Map<String, dynamic>>(
        endpoint,
        data: data,
      );

      final responseData = resp.data ?? {};
      final access =
          responseData['access'] as String? ?? responseData['token'] as String?;
      final refresh = responseData['refresh'] as String?;

      if (access != null) {
        await ShphTokenStorage.saveTokens(
            accessToken: access, refreshToken: refresh);
        LoggingService.info('SHPH API tokens synced after social sign-in',
            tag: 'ShphAuthBridge');
      }
    } catch (e) {
      LoggingService.error(
        'SHPH API social token exchange failed; Supabase fallback remains active: $e',
        tag: 'ShphAuthBridge',
      );
    }
  }

  /// After phone OTP verification via Supabase, exchange the code for SHPH JWTs.
  Future<void> syncAfterPhoneSignIn(String phoneNumber, String smsCode) async {
    if (!ApiConfig.preferShphApi) return;

    try {
      await ShphAuthApi.instance.verifyOtpPin(
        payload: {'phone_number': phoneNumber, 'pin': smsCode},
      );
      LoggingService.info('SHPH API tokens synced after phone sign-in',
          tag: 'ShphAuthBridge');
    } catch (e) {
      LoggingService.error(
        'SHPH API OTP verify failed; Supabase fallback remains active: $e',
        tag: 'ShphAuthBridge',
      );
    }
  }
}
