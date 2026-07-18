import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/services/call/ice_config.dart';

void main() {
  group('IceConfig.iceServers', () {
    test('returns only STUN when no TURN creds', () {
      final servers = IceConfig.iceServers(turnUser: '', turnCred: '');
      expect(servers.length, 1);
      expect(servers.first['urls'], contains('stun:stun.l.google.com:19302'));
    });

    test('adds TURN when creds provided', () {
      final servers =
          IceConfig.iceServers(turnUser: 'root', turnCred: 'secret');
      expect(servers.length, 2);
      final turn = servers[1];
      expect(turn['username'], 'root');
      expect(turn['credential'], 'secret');
      expect(
        (turn['urls'] as List)
            .any((u) => u.toString().startsWith('turn:web.prepcirca.com')),
        isTrue,
      );
    });
  });

  group('IceConfig.configuration', () {
    test('uses unified-plan and includes iceServers', () {
      final config = IceConfig.configuration();
      expect(config['sdpSemantics'], 'unified-plan');
      expect(config['iceServers'], isA<List>());
    });
  });
}
