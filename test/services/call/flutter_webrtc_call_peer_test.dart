import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/services/call/flutter_webrtc_call_peer.dart';

void main() {
  group('session description validation', () {
    test('accepts offers and answers', () {
      final offer = FlutterWebrtcCallPeer.parseSessionDescription({
        'type': 'offer',
        'sdp': 'v=0',
      });
      final answer = FlutterWebrtcCallPeer.parseSessionDescription({
        'type': 'answer',
        'sdp': 'v=0',
      });

      expect(offer.type, 'offer');
      expect(offer.sdp, 'v=0');
      expect(answer.type, 'answer');
    });

    test('rejects missing, empty, and unsupported values', () {
      expect(
        () => FlutterWebrtcCallPeer.parseSessionDescription({}),
        throwsFormatException,
      );
      expect(
        () => FlutterWebrtcCallPeer.parseSessionDescription({
          'type': 'offer',
          'sdp': '',
        }),
        throwsFormatException,
      );
      expect(
        () => FlutterWebrtcCallPeer.parseSessionDescription({
          'type': 'rollback',
          'sdp': 'v=0',
        }),
        throwsFormatException,
      );
    });
  });

  group('ICE candidate validation', () {
    test('accepts a complete candidate', () {
      final candidate = FlutterWebrtcCallPeer.parseIceCandidate({
        'candidate': 'candidate:1',
        'sdpMid': '0',
        'sdpMLineIndex': 0,
      });

      expect(candidate.candidate, 'candidate:1');
      expect(candidate.sdpMid, '0');
      expect(candidate.sdpMLineIndex, 0);
    });

    test('allows nullable optional fields', () {
      final candidate = FlutterWebrtcCallPeer.parseIceCandidate({
        'candidate': 'candidate:1',
      });

      expect(candidate.sdpMid, isNull);
      expect(candidate.sdpMLineIndex, isNull);
    });

    test('rejects malformed candidate fields', () {
      expect(
        () => FlutterWebrtcCallPeer.parseIceCandidate({}),
        throwsFormatException,
      );
      expect(
        () => FlutterWebrtcCallPeer.parseIceCandidate({
          'candidate': 'candidate:1',
          'sdpMid': 0,
        }),
        throwsFormatException,
      );
      expect(
        () => FlutterWebrtcCallPeer.parseIceCandidate({
          'candidate': 'candidate:1',
          'sdpMLineIndex': '0',
        }),
        throwsFormatException,
      );
    });
  });
}
