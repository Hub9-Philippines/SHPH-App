import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/services/call/call_controller.dart';
import 'package:serbisyohubph/services/call/call_peer.dart';
import 'package:serbisyohubph/services/call/call_signaling.dart';
import 'package:serbisyohubph/services/call/signaling_message.dart';

/// Records local-candidate/connection callbacks so the test can drive them.
class FakeCallPeer implements CallPeer {
  bool initialized = false;
  bool disposed = false;
  bool? muted;
  bool? cameraEnabled;
  // ignore: avoid_positional_boolean_parameters
  void Function(bool connected)? _onConn;
  void Function(Map<String, dynamic>)? _onCand;

  void fireConnected() => _onConn?.call(true);
  void fireCandidate(Map<String, dynamic> candidate) =>
      _onCand?.call(candidate);

  @override
  Future<void> initialize({required bool video}) async => initialized = true;
  @override
  Future<Map<String, dynamic>> createOffer() async =>
      {'type': 'offer', 'sdp': 'x'};
  @override
  Future<Map<String, dynamic>> createAnswer() async =>
      {'type': 'answer', 'sdp': 'y'};
  @override
  Future<void> applyRemoteDescription(Map<String, dynamic> sdp) async {}
  @override
  Future<void> addRemoteCandidate(Map<String, dynamic> candidate) async {}
  @override
  void onLocalCandidate(void Function(Map<String, dynamic>) cb) => _onCand = cb;
  @override
  // ignore: avoid_positional_boolean_parameters
  void onConnectionState(void Function(bool connected) cb) => _onConn = cb;
  @override
  void setMuted(bool m) => muted = m;
  @override
  void setCameraEnabled(bool e) => cameraEnabled = e;
  @override
  Future<void> switchCamera() async {}
  @override
  Widget localView() => const SizedBox();
  @override
  Widget remoteView() => const SizedBox();
  @override
  Future<void> dispose() async => disposed = true;
}

class Harness {
  Harness() {
    final signaling = CallSignaling(send: sent.add, messages: ws.stream);
    controller = CallController(
      signaling: signaling,
      peerFactory: () => peer,
      initiateCallApi: ({required threadId, required calleeId}) async {
        apiCalls.add('initiate');
        return {'id': 'call-1'};
      },
      acceptCallApi: (id) async => apiCalls.add('accept:$id'),
      rejectCallApi: (id, {reason}) async => apiCalls.add('reject:$id'),
      endCallApi: (id, {reason, duration}) async => apiCalls.add('end:$id'),
      resolveParticipant: (threadId, fallback) async =>
          CallParticipant(userId: fallback, name: 'Caller $fallback'),
    );
  }
  final StreamController<Map<String, dynamic>> ws =
      StreamController.broadcast();
  final List<Map<String, dynamic>> sent = [];
  final FakeCallPeer peer = FakeCallPeer();
  final List<String> apiCalls = [];
  late final CallController controller;

  /// Simulate an inbound signal from the backend.
  void inbound(Map<String, dynamic> data) =>
      ws.add({'type': 'call_signal', 'data': data});
}

void main() {
  late Harness h;
  setUp(() => h = Harness());
  tearDown(() => h.ws.close());

  SignalingMessage lastSent(List<Map<String, dynamic>> sent) =>
      SignalingMessage.fromJson(
          (sent.last['data'] as Map).cast<String, dynamic>())!;

  test('initiateCall -> outgoing, creates call record, sends call_initiate',
      () async {
    await h.controller.initiateCall(
      threadId: 't1',
      callee: const CallParticipant(userId: '42', name: 'Bob'),
    );

    expect(h.controller.status, CallStatus.outgoing);
    expect(h.apiCalls, contains('initiate'));
    expect(h.peer.initialized, isTrue);
    expect(lastSent(h.sent).type, CallSignalType.callInitiate);
    expect(lastSent(h.sent).callId, 'call-1');
    expect(lastSent(h.sent).targetUserId, '42');
  });

  test('on call_accept -> creates offer, sends webrtc_offer, status connecting',
      () async {
    await h.controller.initiateCall(
      threadId: 't1',
      callee: const CallParticipant(userId: '42', name: 'Bob'),
    );
    h.sent.clear();

    h.inbound({
      'type': 'call_accept',
      'threadId': 't1',
      'targetUserId': '99',
      'callId': 'call-1',
      'callerUserId': '42'
    });
    await Future<void>.delayed(Duration.zero);

    expect(h.controller.status, CallStatus.connecting);
    expect(lastSent(h.sent).type, CallSignalType.webrtcOffer);
    expect(lastSent(h.sent).sdp, {'type': 'offer', 'sdp': 'x'});
  });

  test('peer connected callback -> status connected', () async {
    await h.controller.initiateCall(
      threadId: 't1',
      callee: const CallParticipant(userId: '42', name: 'Bob'),
    );
    h.inbound({
      'type': 'call_accept',
      'threadId': 't1',
      'targetUserId': '99',
      'callId': 'call-1'
    });
    await Future<void>.delayed(Duration.zero);

    h.peer.fireConnected();
    expect(h.controller.status, CallStatus.connected);
  });

  test('endCall -> calls end API, sends call_end, disposes peer, status ended',
      () async {
    await h.controller.initiateCall(
      threadId: 't1',
      callee: const CallParticipant(userId: '42', name: 'Bob'),
    );
    h.sent.clear();

    await h.controller.endCall();

    expect(h.apiCalls, contains('end:call-1'));
    expect(lastSent(h.sent).type, CallSignalType.callEnd);
    expect(h.peer.disposed, isTrue);
    expect(h.controller.status, CallStatus.ended);
  });

  test('inbound call_initiate -> ringing + incomingCall populated', () async {
    h.inbound({
      'type': 'call_initiate',
      'threadId': 't1',
      'targetUserId': '99',
      'callId': 'call-9',
      'callerUserId': '42'
    });
    await Future<void>.delayed(Duration.zero);

    expect(h.controller.status, CallStatus.ringing);
    expect(h.controller.incomingCall, isNotNull);
    expect(h.controller.incomingCall!.callId, 'call-9');
    expect(h.controller.incomingCall!.participant.userId, '42');
  });

  test(
      'acceptIncomingCall -> accept API + call_accept; answers an inbound offer',
      () async {
    h.inbound({
      'type': 'call_initiate',
      'threadId': 't1',
      'targetUserId': '99',
      'callId': 'call-9',
      'callerUserId': '42'
    });
    await Future<void>.delayed(Duration.zero);
    h.sent.clear();

    await h.controller.acceptIncomingCall();
    expect(h.apiCalls, contains('accept:call-9'));
    expect(lastSent(h.sent).type, CallSignalType.callAccept);
    expect(h.controller.status, CallStatus.connecting);

    h.inbound({
      'type': 'webrtc_offer',
      'threadId': 't1',
      'targetUserId': '99',
      'callId': 'call-9',
      'callerUserId': '42',
      'sdp': {'type': 'offer', 'sdp': 'x'}
    });
    await Future<void>.delayed(Duration.zero);
    expect(lastSent(h.sent).type, CallSignalType.webrtcAnswer);
    expect(lastSent(h.sent).sdp, {'type': 'answer', 'sdp': 'y'});
  });

  test('rejectIncomingCall -> reject API + call_reject + ended', () async {
    h.inbound({
      'type': 'call_initiate',
      'threadId': 't1',
      'targetUserId': '99',
      'callId': 'call-9',
      'callerUserId': '42'
    });
    await Future<void>.delayed(Duration.zero);
    h.sent.clear();

    await h.controller.rejectIncomingCall(reason: 'busy');
    expect(h.apiCalls, contains('reject:call-9'));
    expect(lastSent(h.sent).type, CallSignalType.callReject);
    expect(h.controller.status, CallStatus.ended);
  });

  test('toggleMute flips flag and tells the peer', () async {
    await h.controller.initiateCall(
      threadId: 't1',
      callee: const CallParticipant(userId: '42', name: 'Bob'),
    );
    expect(h.controller.isMuted, isFalse);
    h.controller.toggleMute();
    expect(h.controller.isMuted, isTrue);
    expect(h.peer.muted, isTrue);
  });
}
