import 'package:flutter_test/flutter_test.dart';

import 'package:serbisyohubph/services/call_signal_models.dart';
import 'package:serbisyohubph/services/websocket_service.dart';

void main() {
  group('CallSignalMessage', () {
    test('call_initiate envelope matches web client wire format', () {
      final msg = CallSignalMessage(
        type: CallSignalType.callInitiate,
        threadId: 'thread-1',
        targetUserId: '7',
        callerUserId: '24',
        callId: 'call-1',
        mediaType: CallMediaType.audio,
      );

      final envelope = msg.toEnvelopeJson();
      expect(envelope['type'], 'call_signal');
      final data = envelope['data'] as Map<String, dynamic>;
      // camelCase keys exactly as the web client sends them.
      expect(data['type'], 'call_initiate');
      expect(data['threadId'], 'thread-1');
      expect(data['targetUserId'], '7');
      expect(data['callerUserId'], '24');
      expect(data['callId'], 'call-1');
      expect(data['mediaType'], 'audio');
      expect(data.containsKey('sdp'), isFalse);
      expect(data.containsKey('candidate'), isFalse);
    });

    test('offer message carries RTC-shaped sdp', () {
      final msg = CallSignalMessage(
        type: CallSignalType.webrtcOffer,
        threadId: 'thread-1',
        targetUserId: '7',
        sdp: SdpDescription(type: 'offer', sdp: 'v=0...'),
      );

      final data = msg.toEnvelopeJson()['data'] as Map<String, dynamic>;
      final sdp = data['sdp'] as Map<String, dynamic>;
      expect(sdp['type'], 'offer');
      expect(sdp['sdp'], 'v=0...');
    });

    test('ice_candidate omits null usernameFragment', () {
      final msg = CallSignalMessage(
        type: CallSignalType.iceCandidate,
        threadId: 't',
        targetUserId: '7',
        candidate: IceCandidateInit(
          candidate: 'candidate:1 1 udp 2130706431 10.0.0.1 8443 typ host',
          sdpMid: '0',
          sdpMLineIndex: 0,
        ),
      );

      final candidate = msg.toEnvelopeJson()['data']['candidate']
          as Map<String, dynamic>;
      expect(candidate['candidate'], startsWith('candidate:1'));
      expect(candidate['sdpMid'], '0');
      expect(candidate.containsKey('usernameFragment'), isFalse);
    });

    test('round-trip: envelope → fromEnvelopeData preserves fields', () {
      final original = CallSignalMessage(
        type: CallSignalType.callInitiate,
        threadId: 'thread-9',
        targetUserId: '42',
        callerUserId: '24',
        callId: 'call-9',
        mediaType: CallMediaType.video,
        sdp: const SdpDescription(type: 'offer', sdp: 'v=0'),
        candidate: const IceCandidateInit(
          candidate: 'candidate:2 2 tcp 1 192.168.0.2 9 typ host',
          sdpMid: '1',
          sdpMLineIndex: 1,
          usernameFragment: 'uf',
        ),
      );

      final parsed = CallSignalMessage.fromEnvelopeData(
        original.toEnvelopeJson()['data'],
      );

      expect(parsed, isNotNull);
      expect(parsed!.type, CallSignalType.callInitiate);
      expect(parsed.threadId, 'thread-9');
      expect(parsed.targetUserId, '42');
      expect(parsed.callerUserId, '24');
      expect(parsed.callId, 'call-9');
      expect(parsed.mediaType, CallMediaType.video);
      expect(parsed.sdp?.type, 'offer');
      expect(parsed.sdp?.sdp, 'v=0');
      expect(parsed.candidate?.candidate, startsWith('candidate:2'));
      expect(parsed.candidate?.sdpMid, '1');
      expect(parsed.candidate?.sdpMLineIndex, 1);
      expect(parsed.candidate?.usernameFragment, 'uf');
    });

    test('fromEnvelopeData returns null for unknown/invalid payloads', () {
      expect(CallSignalMessage.fromEnvelopeData(null), isNull);
      expect(CallSignalMessage.fromEnvelopeData('nope'), isNull);
      expect(CallSignalMessage.fromEnvelopeData(<String, dynamic>{}), isNull);
      expect(
        CallSignalMessage.fromEnvelopeData(<String, dynamic>{
          'type': 'not_a_signal',
        }),
        isNull,
      );
    });
  });

  group('ShphWebSocketService.deriveWsUrl', () {
    test('derives wss URL from https base', () {
      expect(
        ShphWebSocketService.deriveWsUrl('https://serbisyohubph.com'),
        'wss://serbisyohubph.com/ws/',
      );
    });

    test('strips trailing slash and keeps path segments', () {
      expect(
        ShphWebSocketService.deriveWsUrl('https://example.com/api/'),
        'wss://example.com/api/ws/',
      );
    });

    test('http base yields ws scheme', () {
      expect(
        ShphWebSocketService.deriveWsUrl('http://10.0.2.2:8000'),
        'ws://10.0.2.2:8000/ws/',
      );
    });
  });
}
