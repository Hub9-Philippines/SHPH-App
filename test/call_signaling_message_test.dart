import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/services/call/signaling_message.dart';

void main() {
  group('CallSignalType wire mapping', () {
    test('every type round-trips through wire/fromWire', () {
      for (final t in CallSignalType.values) {
        expect(CallSignalType.fromWire(t.wire), t);
      }
    });

    test('known wire strings map correctly', () {
      expect(CallSignalType.fromWire('call_initiate'),
          CallSignalType.callInitiate);
      expect(
          CallSignalType.fromWire('webrtc_offer'), CallSignalType.webrtcOffer);
      expect(CallSignalType.fromWire('ice_candidate'),
          CallSignalType.iceCandidate);
    });

    test('unknown wire string returns null', () {
      expect(CallSignalType.fromWire('nope'), isNull);
      expect(CallSignalType.fromWire(null), isNull);
    });
  });

  group('SignalingMessage.toJson', () {
    test('includes required fields and omits null optionals', () {
      const msg = SignalingMessage(
        type: CallSignalType.callInitiate,
        threadId: 't1',
        targetUserId: '42',
        callId: 'c1',
      );
      final json = msg.toJson();
      expect(json['type'], 'call_initiate');
      expect(json['threadId'], 't1');
      expect(json['targetUserId'], '42');
      expect(json['callId'], 'c1');
      expect(json.containsKey('sdp'), isFalse);
      expect(json.containsKey('candidate'), isFalse);
      expect(json.containsKey('reason'), isFalse);
    });

    test('includes sdp/candidate when present', () {
      const msg = SignalingMessage(
        type: CallSignalType.webrtcOffer,
        threadId: 't1',
        targetUserId: '42',
        sdp: {'type': 'offer', 'sdp': 'v=0...'},
      );
      expect(msg.toJson()['sdp'], {'type': 'offer', 'sdp': 'v=0...'});
    });
  });

  group('SignalingMessage.fromJson', () {
    test('parses a valid inbound offer with injected callerUserId', () {
      final msg = SignalingMessage.fromJson({
        'type': 'webrtc_offer',
        'threadId': 't1',
        'targetUserId': '42',
        'callerUserId': '7',
        'sdp': {'type': 'offer', 'sdp': 'v=0...'},
      });
      expect(msg, isNotNull);
      expect(msg!.type, CallSignalType.webrtcOffer);
      expect(msg.callerUserId, '7');
      expect(msg.sdp, {'type': 'offer', 'sdp': 'v=0...'});
    });

    test('coerces non-string ids to string', () {
      final msg = SignalingMessage.fromJson({
        'type': 'call_initiate',
        'threadId': 't1',
        'targetUserId': 42,
        'callId': 99,
      });
      expect(msg!.targetUserId, '42');
      expect(msg.callId, '99');
    });

    test('returns null for unknown type', () {
      expect(SignalingMessage.fromJson({'type': 'nope', 'threadId': 't1'}),
          isNull);
    });

    test('returns null when threadId is missing', () {
      expect(
          SignalingMessage.fromJson({'type': 'call_end', 'targetUserId': '42'}),
          isNull);
    });
  });
}
