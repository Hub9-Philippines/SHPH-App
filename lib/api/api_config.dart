/// Backend data-source configuration for the SHPH REST API integration.
///
/// The app currently uses Supabase as the primary backend.
/// Flip `preferShphApi` back on later when the SHPH API is ready for use.
class ApiConfig {
  ApiConfig._();

  /// Live deployed Cloudflare Worker API.
  /// Overridable via `--dart-define=SHPH_API_BASE_URL=...`.
  static const String _defaultBaseUrl = 'https://api.serbisyo.workers.dev';

  static const String _baseUrlFromEnv = String.fromEnvironment(
    'SHPH_API_BASE_URL',
    defaultValue: _defaultBaseUrl,
  );

  static const bool useShphApi = bool.fromEnvironment(
    'USE_SHPH_API',
    defaultValue: false,
  );

  static String get baseUrl {
    final url = _baseUrlFromEnv.trim();
    if (url.isEmpty) {
      return _defaultBaseUrl;
    }
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  static bool get isConfigured => baseUrl.isNotEmpty;

  /// The SHPH REST API is now the sole backend; Supabase has been removed.
  static bool get preferShphApi => true;

  /// Google OAuth Web Client ID for Android/Web serverClientId.
  /// Overridable via `--dart-define=GOOGLE_SERVER_CLIENT_ID=...`.
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '191564688667-drcjh8fg6dhncb37bgka4hu320mor1pp.apps.googleusercontent.com',
  );
}
