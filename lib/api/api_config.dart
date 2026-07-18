/// Backend data-source configuration for the SHPH REST API integration.
///
/// The app points exclusively to the shph-api Django backend.
///
/// Override for local development at build time:
///   --dart-define=SHPH_API_BASE_URL=http://localhost:8000
class ApiConfig {
  ApiConfig._();

  /// Base URL of the SHPH API backend. Must NOT include a trailing slash and
  /// must NOT include the `/api` path prefix, because all endpoints already
  /// start with `/api/` (e.g., `/api/auth/login/`).
  ///
  /// Production: `https://serbisyohubph.com` -> full URL `https://serbisyohubph.com/api/auth/login/`
  /// Local dev:   `http://localhost:8000`    -> full URL `http://localhost:8000/api/auth/login/`
  static const String _baseUrlFromEnv = String.fromEnvironment(
    'SHPH_API_BASE_URL',
    defaultValue: 'https://serbisyohubph.com',
  );

  /// WebSocket URL for real-time chat. Must NOT include a trailing slash and
  /// must NOT include the `/chat` path prefix; the service appends `/chat/` and
  /// sends the JWT via the `Sec-WebSocket-Protocol` subprotocol header.
  ///
  /// Production: `wss://serbisyohubph.com:8011/ws` -> full URL `wss://serbisyohubph.com:8011/ws/chat/`
  /// Local dev:   `ws://localhost:8000/ws`          -> full URL `ws://localhost:8000/ws/chat/`
  ///
  /// If omitted, we derive it from [baseUrl] by swapping `http`->`ws` and `https`->`wss`.
  static const String _wsUrlFromEnv = String.fromEnvironment(
    'SHPH_WS_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    final url = _baseUrlFromEnv.trim();
    if (url.isEmpty) {
      return 'https://serbisyohubph.com';
    }
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  static String get wsUrl {
    final explicit = _wsUrlFromEnv.trim();
    if (explicit.isNotEmpty) {
      return explicit.endsWith('/')
          ? explicit.substring(0, explicit.length - 1)
          : explicit;
    }
    // Derive from REST base URL
    final rest = baseUrl;
    if (rest.startsWith('https://')) {
      return 'wss://${rest.substring(8)}:8011/ws';
    }
    if (rest.startsWith('http://')) {
      return 'ws://${rest.substring(7)}:8010/ws';
    }
    return 'wss://$rest:8011/ws';
  }

  static bool get isConfigured => baseUrl.isNotEmpty;

  static bool get isWebSocketConfigured => wsUrl.isNotEmpty;
}
