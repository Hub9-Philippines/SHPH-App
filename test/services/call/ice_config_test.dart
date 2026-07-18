import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/services/call/ice_config.dart';

void main() {
  test('accepts only valid STUN schemes and removes duplicates', () {
    final servers = IceConfig.iceServers(
      stunUrls: 'stun:one.example:3478,https://invalid,stun:one.example:3478',
      turnUrls: '',
    );

    expect(servers, [
      {
        'urls': ['stun:one.example:3478'],
      },
    ]);
  });

  test('requires both TURN username and credential', () {
    expect(
      IceConfig.iceServers(
        stunUrls: '',
        turnUrls: 'turn:turn.example:3478',
        turnUsername: 'user',
      ),
      isEmpty,
    );
  });

  test('adds configured TURN servers without exposing them elsewhere', () {
    final servers = IceConfig.iceServers(
      stunUrls: '',
      turnUrls: 'turn:turn.example:3478,turns:turn.example:5349',
      turnUsername: 'user',
      turnCredential: 'secret',
    );

    expect(servers.single['username'], 'user');
    expect(servers.single['credential'], 'secret');
    expect(servers.single['urls'], hasLength(2));
  });
}
