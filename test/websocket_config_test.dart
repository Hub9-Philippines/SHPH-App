import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/api/api_config.dart';
import 'package:serbisyohubph/api/shph_token_storage.dart';
import 'package:serbisyohubph/services/websocket_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ApiConfig.wsUrl', () {
    test('derives production wss URL from https base URL', () {
      // The default env is production: https://serbisyohubph.com
      expect(ApiConfig.wsUrl, 'wss://serbisyohubph.com:8011/ws');
    });

    test('does not embed the JWT in the WebSocket path', () {
      // JWT must travel via Sec-WebSocket-Protocol, not the URL path, so that
      // tokens do not leak into reverse-proxy / CDN access logs or browser
      // history. See ShphWebSocketService._initiateConnection.
      expect(
        ShphWebSocketService.connectionUrl(ApiConfig.wsUrl),
        'wss://serbisyohubph.com:8011/ws/chat/',
      );
    });
  });

  group('ShphTokenStorage.getCurrentUserId', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('returns null when no token is stored', () async {
      final userId = await ShphTokenStorage.getCurrentUserId();
      expect(userId, isNull);
    });

    test('decodes user_id from a valid JWT', () async {
      // Header: {"alg":"none","typ":"JWT"}
      // Payload: {"user_id":42,"exp":9999999999}
      const token = 'eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.'
          'eyJ1c2VyX2lkIjo0MiwiZXhwIjo5OTk5OTk5OTk5fQ.';
      await ShphTokenStorage.saveTokens(accessToken: token);
      final userId = await ShphTokenStorage.getCurrentUserId();
      expect(userId, 42);
    });

    test('decodes sub claim when user_id is absent', () async {
      // Payload: {"sub":"123"}
      const token = 'eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.'
          'eyJzdWIiOiIxMjMifQ.';
      await ShphTokenStorage.saveTokens(accessToken: token);
      final userId = await ShphTokenStorage.getCurrentUserId();
      expect(userId, 123);
    });

    test('returns null for malformed token', () async {
      await ShphTokenStorage.saveTokens(accessToken: 'not-a-jwt');
      final userId = await ShphTokenStorage.getCurrentUserId();
      expect(userId, isNull);
    });
  });
}
