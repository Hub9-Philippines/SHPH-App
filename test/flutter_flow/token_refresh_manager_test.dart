import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/api/shph_token_storage.dart';
import 'package:serbisyohubph/flutter_flow/token_refresh_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TokenRefreshManager().stopTokenRefreshMonitoring();
  });

  tearDown(TokenRefreshManager().stopTokenRefreshMonitoring);

  test('extracts an expiry from a valid JWT payload', () {
    final expiry = DateTime.now().toUtc().add(const Duration(hours: 1));
    final token = _jwt(expiry);

    final parsed = TokenRefreshManager.extractExpiry(token);

    expect(parsed, isNotNull);
    expect(parsed!.millisecondsSinceEpoch ~/ 1000,
        expiry.millisecondsSinceEpoch ~/ 1000);
  });

  test('rejects malformed or missing expiry payloads', () {
    expect(TokenRefreshManager.extractExpiry('not-a-token'), isNull);
    expect(TokenRefreshManager.extractExpiry('a.b.c'), isNull);
    expect(TokenRefreshManager.extractExpiry(_jwtWithoutExpiry()), isNull);
  });

  test('reports remaining lifetime without exposing or clearing tokens',
      () async {
    final token = _jwt(DateTime.now().toUtc().add(const Duration(minutes: 10)));
    await ShphTokenStorage.saveTokens(
      accessToken: token,
      refreshToken: 'refresh-secret',
    );

    final remaining = await TokenRefreshManager().checkTokenNow();

    expect(remaining, isNotNull);
    expect(remaining!.inMinutes, inInclusiveRange(9, 10));
    expect(await ShphTokenStorage.getAccessToken(), token);
    expect(await ShphTokenStorage.getRefreshToken(), 'refresh-secret');
  });

  test('emits expired once and preserves the refresh token', () async {
    await ShphTokenStorage.saveTokens(
      accessToken:
          _jwt(DateTime.now().toUtc().subtract(const Duration(minutes: 1))),
      refreshToken: 'refresh-secret',
    );
    final manager = TokenRefreshManager();
    final events = <TokenExpiryEvent>[];
    final subscription = manager.events.listen(events.add);
    addTearDown(subscription.cancel);

    await manager.checkTokenNow();
    await manager.checkTokenNow();
    await Future<void>.delayed(Duration.zero);

    expect(events, [TokenExpiryEvent.expired]);
    expect(await ShphTokenStorage.getRefreshToken(), 'refresh-secret');
  });
}

String _jwt(DateTime expiry) {
  final payload = base64Url.encode(
    utf8.encode(jsonEncode({'exp': expiry.millisecondsSinceEpoch ~/ 1000})),
  );
  return 'header.$payload.signature';
}

String _jwtWithoutExpiry() {
  final payload = base64Url.encode(utf8.encode(jsonEncode({'sub': 'test'})));
  return 'header.$payload.signature';
}
