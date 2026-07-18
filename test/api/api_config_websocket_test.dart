import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/api/api_config.dart';

void main() {
  test('production WebSocket base is configured without the chat suffix', () {
    expect(ApiConfig.wsUrl, 'wss://serbisyohubph.com/ws');
    expect(ApiConfig.isWebSocketConfigured, isTrue);
  });

  test('normalizes an explicit WebSocket URL', () {
    expect(
      ApiConfig.normalizeWebSocketUrl(
        ' wss://example.com/ws/ ',
        restBaseUrl: 'https://unused.example.com',
      ),
      'wss://example.com/ws',
    );
  });

  test('derives a WebSocket URL when an explicit value is absent', () {
    expect(
      ApiConfig.normalizeWebSocketUrl(
        '',
        restBaseUrl: 'https://api.example.com/api',
      ),
      'wss://api.example.com/ws',
    );
    expect(
      ApiConfig.normalizeWebSocketUrl(
        null,
        restBaseUrl: 'http://localhost:8000',
      ),
      'ws://localhost:8000/ws',
    );
  });

  test('rejects unsafe or malformed explicit schemes', () {
    expect(
      ApiConfig.normalizeWebSocketUrl(
        'https://example.com/ws',
        restBaseUrl: 'https://api.example.com',
      ),
      isEmpty,
    );
    expect(
      ApiConfig.normalizeWebSocketUrl(
        'not a url',
        restBaseUrl: 'https://api.example.com',
      ),
      isEmpty,
    );
  });
}
