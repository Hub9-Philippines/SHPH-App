import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/services/call/call_signaling.dart';
import 'package:serbisyohubph/services/call/signaling_message.dart';

void main() {
  test('wraps outbound signals in the source protocol envelope', () {
    final sent = <Map<String, dynamic>>[];
    CallSignaling(
      send: sent.add,
      messages: const Stream.empty(),
    )..sendSignal(
        const SignalingMessage(
          type: CallSignalType.callEnd,
          threadId: 'thread-1',
          targetUserId: '42',
        ),
      );

    expect(sent.single['type'], 'call_signal');
    expect((sent.single['data'] as Map)['type'], 'call_end');
  });

  test('filters unrelated and malformed inbound messages', () async {
    final controller = StreamController<Map<String, dynamic>>();
    addTearDown(controller.close);
    final signaling = CallSignaling(send: (_) {}, messages: controller.stream);
    final received = <SignalingMessage>[];
    final subscription = signaling.incoming.listen(received.add);
    addTearDown(subscription.cancel);

    controller
      ..add({'type': 'chat_message', 'data': {}})
      ..add({
        'type': 'call_signal',
        'data': {'type': 'call_end', 'threadId': 'thread-1'},
      })
      ..add({
        'type': 'call_signal',
        'data': {
          'type': 'call_end',
          'threadId': 'thread-1',
          'targetUserId': '42',
        },
      });
    await Future<void>.delayed(Duration.zero);

    expect(received, hasLength(1));
    expect(received.single.type, CallSignalType.callEnd);
  });
}
