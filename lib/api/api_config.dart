/// Backend data-source configuration for the SHPH REST API integration.
///
/// The app currently uses Supabase as the primary backend.
/// Flip `preferShphApi` back on later when the SHPH API is ready for use.
class ApiConfig {
  ApiConfig._();

  /// Live deployed backend (web build's `VITE_API_URL=https://serbisyohubph.com/api`).
  /// Overridable via `--dart-define=SHPH_API_BASE_URL=...`.
  static const String _defaultBaseUrl = 'https://serbisyohubph.com';

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
}
