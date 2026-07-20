import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/services/call/signaling_message.dart';

void main() {
  test('all signal types round-trip through their wire values', () {
    for (final type in CallSignalType.values) {
      expect(CallSignalType.fromWire(type.wire), type);
    }
  });

  test('serializes required fields without null optionals', () {
    const message = SignalingMessage(
      type: CallSignalType.callInitiate,
      threadId: 'thread-1',
      targetUserId: '42',
      callId: 'call-1',
    );

    expect(message.toJson(), {
      'type': 'call_initiate',
      'threadId': 'thread-1',
      'targetUserId': '42',
      'callId': 'call-1',
    });
  });

  test('rejects malformed and incomplete inbound messages', () {
    expect(
      SignalingMessage.fromJson({'type': 'unknown', 'threadId': 'thread-1'}),
      isNull,
    );
    expect(
      SignalingMessage.fromJson({
        'type': 'call_end',
        'threadId': 'thread-1',
      }),
      isNull,
    );
    expect(
      SignalingMessage.fromJson({
        'type': 'webrtc_offer',
        'threadId': 'thread-1',
        'targetUserId': '42',
      }),
      isNull,
    );
  });

  test('parses a valid offer', () {
    final message = SignalingMessage.fromJson({
      'type': 'webrtc_offer',
      'threadId': 'thread-1',
      'targetUserId': 42,
      'callerUserId': 7,
      'sdp': {'type': 'offer', 'sdp': 'v=0'},
    });

    expect(message, isNotNull);
    expect(message!.targetUserId, '42');
    expect(message.callerUserId, '7');
    expect(message.sdp, {'type': 'offer', 'sdp': 'v=0'});
  });
}
