/// Backend data-source configuration for the SHPH REST API integration.
///
/// The app uses the deployed SHPH API as its backend.
///
/// Override via --dart-define:
///   flutter run --dart-define=USE_SHPH_API=false
///   flutter run --dart-define=SHPH_API_BASE_URL=https://staging.api.serbisyohub.ph
class ApiConfig {
  ApiConfig._();

  static const String _baseUrlFromEnv = String.fromEnvironment(
    'SHPH_API_BASE_URL',
    defaultValue: 'https://serbisyohubph.com',
  );

  static const bool useShphApi = bool.fromEnvironment(
    'USE_SHPH_API',
    defaultValue: true,
  );

  /// WebSocket base URL. The realtime service appends `/chat/`.
  ///
  /// Confirmed against `shph-web` production configuration on 2026-07-18.
  /// Override for local/staging builds with `SHPH_WS_URL`.
  static const String _wsUrlFromEnv = String.fromEnvironment(
    'SHPH_WS_URL',
    defaultValue: 'wss://serbisyohubph.com/ws',
  );

  static String get baseUrl {
    final url = _baseUrlFromEnv.trim();
    if (url.isEmpty) {
      return 'https://serbisyohubph.com';
    }
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  static bool get isConfigured => baseUrl.isNotEmpty;

  static String get wsUrl => normalizeWebSocketUrl(
        _wsUrlFromEnv,
        restBaseUrl: baseUrl,
      );

  static bool get isWebSocketConfigured => wsUrl.isNotEmpty;

  static String normalizeWebSocketUrl(
    String? explicit, {
    required String restBaseUrl,
  }) {
    final configured = explicit?.trim() ?? '';
    if (configured.isNotEmpty) {
      final uri = Uri.tryParse(configured);
      if (uri == null ||
          !uri.hasAuthority ||
          (uri.scheme != 'ws' && uri.scheme != 'wss')) {
        return '';
      }
      return configured.endsWith('/')
          ? configured.substring(0, configured.length - 1)
          : configured;
    }

    final rest = Uri.tryParse(restBaseUrl.trim());
    if (rest == null || !rest.hasAuthority) {
      return '';
    }
    final scheme = switch (rest.scheme) {
      'https' => 'wss',
      'http' => 'ws',
      _ => '',
    };
    if (scheme.isEmpty) {
      return '';
    }
    return rest
        .replace(scheme: scheme, path: '/ws', query: null, fragment: null)
        .toString();
  }

  /// Retained for callers that gate SHPH API access through configuration.
  static bool get preferShphApi => useShphApi && isConfigured;
}
