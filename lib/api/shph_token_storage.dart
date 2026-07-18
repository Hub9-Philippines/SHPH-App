import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists JWT access/refresh tokens for the SHPH REST API.
class ShphTokenStorage {
  ShphTokenStorage._();

  static const _accessTokenKey = 'shph_api_access_token';
  static const _refreshTokenKey = 'shph_api_refresh_token';

  static Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    if (refreshToken != null) {
      await prefs.setString(_refreshTokenKey, refreshToken);
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

  static Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Decode the user ID from the stored access token payload.
  /// Returns `null` if no token is stored or it cannot be parsed.
  static Future<int?> getCurrentUserId() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) {
      return null;
    }
    return _decodeUserId(token);
  }

  static int? _decodeUserId(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }
      final normalized = base64Url.normalize(parts[1]);
      final decoded = base64Url.decode(normalized);
      final payload = jsonDecode(utf8.decode(decoded)) as Map<String, dynamic>;
      final userId = payload['user_id'];
      if (userId is int) {
        return userId;
      }
      if (userId is String) {
        return int.tryParse(userId);
      }
      final sub = payload['sub'];
      if (sub is int) {
        return sub;
      }
      if (sub is String) {
        return int.tryParse(sub);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }
}
