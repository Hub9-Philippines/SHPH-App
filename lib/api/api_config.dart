/// Backend data-source configuration for the SHPH REST API integration.
///
/// The app currently uses Supabase as the primary backend.
/// Flip `preferShphApi` back on later when the SHPH API is ready for use.
class ApiConfig {
  ApiConfig._();

  static const String _baseUrlFromEnv = String.fromEnvironment(
    'SHPH_API_BASE_URL',
    defaultValue: 'https://api.serbisyohub.ph',
  );

  static const bool useShphApi = bool.fromEnvironment(
    'USE_SHPH_API',
    defaultValue: false,
  );

  static String get baseUrl {
    final url = _baseUrlFromEnv.trim();
    if (url.isEmpty) {
      return 'https://api.serbisyohub.ph';
    }
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  static bool get isConfigured => baseUrl.isNotEmpty;

  /// The SHPH REST API is now the sole backend; Supabase has been removed.
  static bool get preferShphApi => true;
}
