import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:serbisyohubph/demo/demo_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final routes = <(String, String)>[
    ('POST', '/api/auth/login/'),
    ('POST', '/api/auth/register/initiate/'),
    ('POST', '/api/auth/register/verify/'),
    ('POST', '/api/auth/register/resend/'),
    ('POST', '/api/auth/otp/send-pin/'),
    ('POST', '/api/auth/otp/verify-pin/'),
    ('POST', '/api/auth/phone-login/send/'),
    ('POST', '/api/auth/phone-login/verify/'),
    ('GET', '/api/auth/me/'),
    ('POST', '/api/auth/me/'),
    ('POST', '/api/auth/logout/'),
    ('POST', '/api/auth/password-reset/'),
    ('POST', '/api/auth/password-reset/confirm/'),
    ('POST', '/api/auth/sessions/'),
    ('DELETE', '/api/auth/sessions/sess-demo-1/'),
    ('DELETE', '/api/auth/sessions/revoke-all/'),
    ('POST', '/api/auth/biometric/register/options/'),
    ('POST', '/api/auth/biometric/register/verify/'),
    ('POST', '/api/auth/biometric/credentials/'),
    ('DELETE', '/api/auth/biometric/credentials/1/'),
    ('POST', '/api/auth/me/skip-kyc/'),
    ('POST', '/api/auth/token/refresh/'),
    ('GET', '/api/users/me/'),
    ('PATCH', '/api/users/me/update/'),
    ('POST', '/api/users/me/photo/'),
    ('DELETE', '/api/users/me/delete/'),
    ('GET', '/api/users/201/'),
    ('GET', '/api/profiles/addresses/'),
    ('POST', '/api/profiles/addresses/'),
    ('GET', '/api/profiles/addresses/81/'),
    ('PATCH', '/api/profiles/addresses/81/'),
    ('DELETE', '/api/profiles/addresses/82/'),
    ('POST', '/api/profiles/addresses/81/set-default/'),
    ('GET', '/api/services/categories/'),
    ('GET', '/api/services/categories/1/subcategories/'),
    ('GET', '/api/services/listings/'),
    ('GET', '/api/services/listings/?search=clean&page=1'),
    ('GET', '/api/services/listings/?category=2'),
    ('GET', '/api/services/listings/mine/'),
    ('GET', '/api/services/listings/3/'),
    ('POST', '/api/services/listings/'),
    ('PATCH', '/api/services/listings/3/'),
    ('DELETE', '/api/services/listings/3/'),
    ('POST', '/api/services/listings/3/archive/'),
    ('POST', '/api/services/listings/3/unarchive/'),
    ('POST', '/api/services/listings/3/upload-thumbnail/'),
    ('GET', '/api/services/listings/3/reviews/'),
    ('GET', '/api/services/reviews/mine/'),
    ('POST', '/api/favorites/'),
    ('DELETE', '/api/favorites/3/'),
    ('POST', '/api/favorites/list/'),
    ('GET', '/api/services/bids/'),
    ('POST', '/api/services/bids/'),
    ('POST', '/api/services/bids/5/withdraw/'),
    ('GET', '/api/services/bookings/'),
    ('GET', '/api/services/bookings/list/'),
    ('POST', '/api/services/bookings/'),
    ('GET', '/api/services/bookings/301/'),
    ('PATCH', '/api/services/bookings/301/'),
    ('POST', '/api/services/bookings/301/accept/'),
    ('POST', '/api/services/bookings/301/reject/'),
    ('POST', '/api/services/bookings/301/confirm-arrival/'),
    ('POST', '/api/services/bookings/301/start/'),
    ('POST', '/api/services/bookings/301/complete/'),
    ('POST', '/api/services/bookings/301/upload-photo/'),
    ('POST', '/api/services/bookings/301/parts-cost/'),
    ('POST', '/api/services/bookings/305/review/'),
    ('GET', '/api/services/availability/'),
    ('GET', '/api/services/availability/slots/'),
    ('POST', '/api/services/availability/slots/'),
    ('PATCH', '/api/services/availability/slots/401/'),
    ('DELETE', '/api/services/availability/slots/401/'),
    ('GET', '/api/chat/threads/'),
    ('GET', '/api/chat/threads/501/'),
    ('GET', '/api/chat/threads/501/messages/'),
    ('POST', '/api/chat/threads/501/send/'),
    ('POST', '/api/chat/threads/501/read/'),
    ('POST', '/api/chat/calls/initiate/'),
    ('POST', '/api/chat/threads/booking/301/'),
    ('GET', '/api/notifications/'),
    ('POST', '/api/notifications/91/read/'),
    ('POST', '/api/notifications/mark-all-read/'),
    ('POST', '/api/notifications/preferences/'),
    ('POST', '/api/notifications/preferences/update/'),
    ('POST', '/api/projects/list/'),
    ('POST', '/api/projects/'),
    ('POST', '/api/projects/701/'),
    ('POST', '/api/projects/701/quote/'),
    ('POST', '/api/projects/701/match/'),
    ('POST', '/api/projects/701/cancel/'),
    ('POST', '/api/services/rooms/list/'),
    ('POST', '/api/services/rooms/'),
    ('POST', '/api/services/rooms/801/'),
    ('POST', '/api/services/rooms/801/join/'),
    ('POST', '/api/services/rooms/801/leave/'),
    ('POST', '/api/services/rooms/801/lock/'),
    ('POST', '/api/services/rooms/801/cancel/'),
    ('GET', '/api/services/rooms/by-token/demo-room-801/'),
    ('POST', '/api/disputes/list/'),
    ('POST', '/api/disputes/'),
    ('POST', '/api/disputes/851/'),
    ('POST', '/api/disputes/booking/307/'),
    ('POST', '/api/services/on-demand/client/jobs/'),
    ('POST', '/api/services/on-demand/'),
    ('POST', '/api/services/on-demand/861/'),
    ('POST', '/api/services/on-demand/861/cancel/'),
    ('GET', '/api/services/eta/some-token/'),
    ('GET', '/api/earnings/summary/'),
    ('GET', '/api/earnings/transactions/'),
    ('GET', '/api/earnings/payouts/'),
    ('POST', '/api/earnings/request-payout/'),
    ('GET', '/api/analytics/provider/?period=month'),
    ('GET', '/api/analytics/revenue-breakdown/'),
    ('GET', '/api/analytics/services/3/metrics/'),
    ('POST', '/api/kyc/status/'),
    ('POST', '/api/kyc/liveness/challenge/'),
    ('POST', '/api/kyc/submit/'),
    ('POST', '/api/support/tickets/'),
  ];

  RequestOptions request(String method, String rawPath) {
    final uri = Uri.parse('https://demo.local$rawPath');
    return RequestOptions(
      path: uri.path,
      method: method,
      baseUrl: 'https://demo.local',
      queryParameters: uri.queryParameters,
    );
  }

  test('every known endpoint resolves without throwing', () {
    for (final (method, path) in routes) {
      final reply = DemoData.resolve(request(method, path));
      expect(reply.status, inInclusiveRange(200, 299),
          reason: '$method $path -> ${reply.status}');
      expect(reply.body, anyOf(isNull, isMap, isList),
          reason: '$method $path returned ${reply.body.runtimeType}');
    }
  });

  test('list envelopes are DRF-shaped or bare arrays where required', () {
    expect(DemoData.resolve(request('GET', '/api/services/listings/')).body,
        isA<Map<String, dynamic>>());
    expect(
        (DemoData.resolve(request('GET', '/api/services/listings/')).body
                as Map)['results'],
        isA<List>());
    expect(DemoData.resolve(request('GET', '/api/notifications/')).body,
        isA<List>());
    expect(DemoData.resolve(request('POST', '/api/favorites/list/')).body,
        isA<List>());
    expect(
        (DemoData.resolve(request('GET', '/api/auth/me/')).body
                as Map)['display_name'],
        isNotEmpty);
  });

  test('role switch flips identity-dependent payloads', () {
    DemoData.currentRole = 'provider';
    final providerMe =
        DemoData.resolve(request('GET', '/api/auth/me/')).body as Map;
    expect(providerMe['is_provider'], true);
    final mineReply = DemoData.resolve(
      request('GET', '/api/services/listings/mine/'),
    );
    final mineResults = (mineReply.body as Map)['results'] as List;
    expect(mineResults.firstWhere((l) => (l as Map)['provider'] == 201),
        isNotNull);

    DemoData.currentRole = 'client';
    final clientMe =
        DemoData.resolve(request('GET', '/api/auth/me/')).body as Map;
    expect(clientMe['is_provider'], false);
  });

  test('booking create appends state and echoes listing data', () {
    final before = DemoData.bookings.length;
    final reply = DemoData.resolve(request('POST', '/api/services/bookings/'));
    expect(reply.status, 201);
    expect((reply.body as Map)['listing_title'], isNotEmpty);
    expect(DemoData.bookings.length, before + 1);
  });
}
