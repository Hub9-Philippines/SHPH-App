/// Backend data-source configuration for the SHPH REST API integration.
///
/// Enable the API layer at build time:
/// `flutter run --dart-define=USE_SHPH_API=true --dart-define=SHPH_API_BASE_URL=https://api.serbisyohub.ph`
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

  /// When true, domain services prefer the SHPH REST API and fall back to
  /// Supabase if a call fails or the user has no API token.
  static bool get preferShphApi => useShphApi && isConfigured;
}
