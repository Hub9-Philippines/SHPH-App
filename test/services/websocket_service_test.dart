import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/services/websocket_service.dart';

void main() {
  test('connects to /chat/ with JWT subprotocol authentication', () async {
    late Uri connectedUri;
    late List<String> connectedProtocols;
    final socket = FakeSocket();
    final service = ShphWebSocketService(
      connector: (uri, protocols) {
        connectedUri = uri;
        connectedProtocols = protocols;
        return socket;
      },
      tokenProvider: () async => 'test-token',
      urlProvider: () => 'wss://serbisyohubph.com/ws',
      heartbeatInterval: const Duration(hours: 1),
    );
    addTearDown(service.dispose);

    expect(await service.connect(), isTrue);
    expect(connectedUri.toString(), 'wss://serbisyohubph.com/ws/chat/');
    expect(connectedProtocols, ['shph-auth', 'test-token']);
    expect(service.state, ShphConnectionState.connected);
  });

  test('does not connect without a token', () async {
    var connectorCalls = 0;
    final service = ShphWebSocketService(
      connector: (_, __) {
        connectorCalls++;
        return FakeSocket();
      },
      tokenProvider: () async => null,
      urlProvider: () => 'wss://serbisyohubph.com/ws',
    );
    addTearDown(service.dispose);

    expect(await service.connect(), isFalse);
    expect(connectorCalls, 0);
  });

  test('publishes valid JSON and discards malformed messages', () async {
    final socket = FakeSocket();
    final service = ShphWebSocketService(
      connector: (_, __) => socket,
      tokenProvider: () async => 'test-token',
      urlProvider: () => 'wss://serbisyohubph.com/ws',
      heartbeatInterval: const Duration(hours: 1),
    );
    addTearDown(service.dispose);
    final received = <Map<String, dynamic>>[];
    final subscription = service.messages.listen(received.add);
    addTearDown(subscription.cancel);
    await service.connect();

    socket.controller
      ..add('not-json')
      ..add(jsonEncode({'type': 'connected'}));
    await Future<void>.delayed(Duration.zero);

    expect(received, [
      {'type': 'connected'},
    ]);
  });

  test('sends heartbeat pings and stops after disconnect', () async {
    final socket = FakeSocket();
    final service = ShphWebSocketService(
      connector: (_, __) => socket,
      tokenProvider: () async => 'test-token',
      urlProvider: () => 'wss://serbisyohubph.com/ws',
      heartbeatInterval: const Duration(milliseconds: 20),
      silenceTimeout: const Duration(seconds: 1),
    );
    addTearDown(service.dispose);
    await service.connect();

    await Future<void>.delayed(const Duration(milliseconds: 45));
    expect(
      socket.sent.map(jsonDecode).any(
            (value) => value is Map && value['type'] == 'ping',
          ),
      isTrue,
    );

    await service.disconnect();
    final count = socket.sent.length;
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(socket.sent, hasLength(count));
  });

  test('manual disconnect does not reconnect', () async {
    var connectorCalls = 0;
    final socket = FakeSocket();
    final service = ShphWebSocketService(
      connector: (_, __) {
        connectorCalls++;
        return socket;
      },
      tokenProvider: () async => 'test-token',
      urlProvider: () => 'wss://serbisyohubph.com/ws',
      initialReconnectDelay: const Duration(milliseconds: 10),
    );
    addTearDown(service.dispose);
    await service.connect();
    await service.disconnect();
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(connectorCalls, 1);
  });

  test('connectionUrl normalizes trailing slashes', () {
    expect(
      ShphWebSocketService.connectionUrl('wss://example.com/ws/'),
      'wss://example.com/ws/chat/',
    );
  });
}

class FakeSocket implements ShphSocket {
  final StreamController<dynamic> controller = StreamController<dynamic>();
  final List<String> sent = [];
  bool closed = false;

  @override
  Future<void> get ready async {}

  @override
  Stream<dynamic> get stream => controller.stream;

  @override
  void add(String data) => sent.add(data);

  @override
  Future<void> close() async {
    if (!closed) {
      closed = true;
      await controller.close();
    }
  }
}
