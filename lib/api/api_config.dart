/// Backend data-source configuration for the SHPH REST API integration.
///
/// The app uses the SHPH API as the primary backend and falls back
/// to Supabase when the API is unreachable.
///
/// Override via --dart-define:
///   flutter run --dart-define=USE_SHPH_API=false
///   flutter run --dart-define=SHPH_API_BASE_URL=https://staging.api.serbisyohub.ph
class ApiConfig {
  ApiConfig._();

  static const String _baseUrlFromEnv = String.fromEnvironment(
    'SHPH_API_BASE_URL',
    defaultValue: 'https://api.serbisyohub.ph',
  );

  static const bool useShphApi = bool.fromEnvironment(
    'USE_SHPH_API',
    defaultValue: true,
  );

  static String get baseUrl {
    final url = _baseUrlFromEnv.trim();
    if (url.isEmpty) {
      return 'https://api.serbisyohub.ph';
    }
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  static bool get isConfigured => baseUrl.isNotEmpty;

  /// Prefer SHPH API over Supabase. All callers fall back to Supabase on error.
  static bool get preferShphApi => useShphApi && isConfigured;
}
