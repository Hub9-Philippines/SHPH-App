import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/services/call/call_signaling.dart';
import 'package:serbisyohubph/services/call/signaling_message.dart';

void main() {
  group('CallSignaling.sendSignal', () {
    test('wraps the message as {type:call_signal, data:...}', () {
      final sent = <Map<String, dynamic>>[];
      CallSignaling(
        send: sent.add,
        messages: const Stream.empty(),
      ).sendSignal(const SignalingMessage(
        type: CallSignalType.callInitiate,
        threadId: 't1',
        targetUserId: '42',
        callId: 'c1',
      ));

      expect(sent, hasLength(1));
      expect(sent.first['type'], 'call_signal');
      expect(sent.first['data']['type'], 'call_initiate');
      expect(sent.first['data']['threadId'], 't1');
    });
  });

  group('CallSignaling.incoming', () {
    test('emits parsed call_signal messages only', () async {
      final controller = StreamController<Map<String, dynamic>>();
      final signaling =
          CallSignaling(send: (_) {}, messages: controller.stream);

      final received = <SignalingMessage>[];
      final sub = signaling.incoming.listen(received.add);

      controller
        ..add({'type': 'chat.message', 'message': {}}) // ignored
        ..add({
          'type': 'call_signal',
          'data': {
            'type': 'call_accept',
            'threadId': 't1',
            'targetUserId': '42',
            'callId': 'c1'
          },
        })
        ..add({
          'type': 'call_signal',
          'data': {
            'type': 'garbage',
            'threadId': 't1'
          }, // unparseable -> dropped
        });
      await Future<void>.delayed(Duration.zero);

      expect(received, hasLength(1));
      expect(received.first.type, CallSignalType.callAccept);
      expect(received.first.callId, 'c1');

      await sub.cancel();
      await controller.close();
    });
  });
}
