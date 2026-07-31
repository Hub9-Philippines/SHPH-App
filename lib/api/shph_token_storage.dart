import 'package:shared_preferences/shared_preferences.dart';

/// Persists JWT access/refresh tokens and the session id for the SHPH REST API.
class ShphTokenStorage {
  ShphTokenStorage._();

  static const _accessTokenKey = 'shph_api_access_token';
  static const _refreshTokenKey = 'shph_api_refresh_token';
  static const _sessionIdKey = 'shph_api_session_id';

  static Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    String? sessionId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    if (refreshToken != null) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }
    if (sessionId != null) {
      await prefs.setString(_sessionIdKey, sessionId);
    }
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  static Future<String?> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionIdKey);
  }

  static Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_sessionIdKey);
  }
}
