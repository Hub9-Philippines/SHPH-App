import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/services/call/call_controller.dart';
import 'package:serbisyohubph/services/call/call_peer.dart';
import 'package:serbisyohubph/services/call/call_signaling.dart';
import 'package:serbisyohubph/services/call/signaling_message.dart';

void main() {
  late ControllerHarness harness;

  setUp(() => harness = ControllerHarness());
  tearDown(() async => harness.dispose());

  test('caller creates a REST record and sends call_initiate', () async {
    final started = await harness.controller.initiateCall(
      threadId: 'thread-1',
      participant: const CallParticipant(userId: '42', name: 'Provider'),
      mediaType: CallMediaType.audio,
    );

    expect(started, isTrue);
    expect(harness.controller.status, CallStatus.outgoing);
    expect(harness.peer.initializedWith, CallMediaType.audio);
    expect(harness.apiCalls, ['initiate:thread-1:42:audio']);
    expect(harness.lastSignal.type, CallSignalType.callInitiate);
    expect(harness.lastSignal.callType, 'audio');
  });

  test('accepted caller creates an offer and reaches connected', () async {
    await harness.startOutgoing();
    harness.sent.clear();

    harness.inbound({
      'type': 'call_accept',
      'threadId': 'thread-1',
      'targetUserId': 'self',
      'callId': 'call-1',
    });
    await Future<void>.delayed(Duration.zero);

    expect(harness.controller.status, CallStatus.connecting);
    expect(harness.lastSignal.type, CallSignalType.webrtcOffer);
    harness.peer.fireConnection(connected: true);
    expect(harness.controller.status, CallStatus.connected);
  });

  test('forwards locally gathered ICE candidates', () async {
    await harness.startOutgoing();
    harness.sent.clear();

    harness.peer.fireCandidate({'candidate': 'candidate-1'});

    expect(harness.lastSignal.type, CallSignalType.iceCandidate);
    expect(harness.lastSignal.candidate, {'candidate': 'candidate-1'});
  });

  test('callee accepts, applies offer, and sends answer', () async {
    harness.inbound(harness.incomingSignal());
    await Future<void>.delayed(Duration.zero);
    expect(harness.controller.status, CallStatus.ringing);

    expect(await harness.controller.acceptIncomingCall(), isTrue);
    expect(harness.apiCalls, contains('accept:call-2'));
    harness.inbound({
      'type': 'webrtc_offer',
      'threadId': 'thread-2',
      'targetUserId': 'self',
      'callId': 'call-2',
      'sdp': {'type': 'offer', 'sdp': 'remote'},
    });
    await Future<void>.delayed(Duration.zero);

    expect(harness.peer.remoteDescriptions, hasLength(1));
    expect(harness.lastSignal.type, CallSignalType.webrtcAnswer);
  });

  test('ignores stale signals for a different thread or call', () async {
    await harness.startOutgoing();
    harness.sent.clear();

    harness
      ..inbound({
        'type': 'call_accept',
        'threadId': 'other-thread',
        'targetUserId': 'self',
        'callId': 'call-1',
      })
      ..inbound({
        'type': 'call_accept',
        'threadId': 'thread-1',
        'targetUserId': 'self',
        'callId': 'other-call',
      });
    await Future<void>.delayed(Duration.zero);

    expect(harness.sent, isEmpty);
    expect(harness.controller.status, CallStatus.outgoing);
  });

  test('rejects a second incoming call while busy', () async {
    await harness.startOutgoing();
    harness.sent.clear();

    harness.inbound(harness.incomingSignal());
    await Future<void>.delayed(Duration.zero);

    expect(harness.apiCalls, contains('reject:call-2:busy'));
    expect(harness.lastSignal.type, CallSignalType.callReject);
    expect(harness.controller.status, CallStatus.outgoing);
  });

  test('end persists, signals, disposes, and always ends locally', () async {
    await harness.startOutgoing();
    harness.sent.clear();

    await harness.controller.endCall(reason: 'user');

    expect(harness.apiCalls, contains('end:call-1:user'));
    expect(harness.lastSignal.type, CallSignalType.callEnd);
    expect(harness.peer.disposed, isTrue);
    expect(harness.controller.status, CallStatus.ended);
  });

  test('initiation failure is fail-closed and exposes an error', () async {
    harness.failInitiate = true;

    final started = await harness.controller.initiateCall(
      threadId: 'thread-1',
      participant: const CallParticipant(userId: '42', name: 'Provider'),
      mediaType: CallMediaType.video,
    );

    expect(started, isFalse);
    expect(harness.controller.status, CallStatus.ended);
    expect(harness.controller.lastError, isA<StateError>());
  });
}

class ControllerHarness {
  ControllerHarness() {
    controller = CallController(
      signaling: CallSignaling(send: sent.add, messages: incoming.stream),
      peerFactory: () => peer,
      initiateCallApi: ({
        required threadId,
        required participantId,
        required mediaType,
      }) async {
        apiCalls.add('initiate:$threadId:$participantId:${mediaType.name}');
        if (failInitiate) {
          throw StateError('REST unavailable');
        }
        return {'id': 'call-1'};
      },
      acceptCallApi: (callId) async => apiCalls.add('accept:$callId'),
      rejectCallApi: (callId, {reason}) async =>
          apiCalls.add('reject:$callId:$reason'),
      endCallApi: (callId, {reason, durationSeconds}) async =>
          apiCalls.add('end:$callId:$reason'),
      resolveParticipant: (threadId, userId) async =>
          CallParticipant(userId: userId, name: 'User $userId'),
    );
  }

  final StreamController<Map<String, dynamic>> incoming =
      StreamController<Map<String, dynamic>>.broadcast();
  final List<Map<String, dynamic>> sent = [];
  final List<String> apiCalls = [];
  final FakeCallPeer peer = FakeCallPeer();
  late final CallController controller;
  bool failInitiate = false;

  SignalingMessage get lastSignal => SignalingMessage.fromJson(
        (sent.last['data'] as Map).cast<String, dynamic>(),
      )!;

  Future<void> startOutgoing() => controller.initiateCall(
        threadId: 'thread-1',
        participant: const CallParticipant(userId: '42', name: 'Provider'),
        mediaType: CallMediaType.video,
      );

  void inbound(Map<String, dynamic> data) {
    incoming.add({'type': 'call_signal', 'data': data});
  }

  Map<String, dynamic> incomingSignal() => {
        'type': 'call_initiate',
        'threadId': 'thread-2',
        'targetUserId': 'self',
        'callerUserId': '77',
        'callId': 'call-2',
        'callType': 'video',
      };

  Future<void> dispose() async {
    controller.dispose();
    await incoming.close();
  }
}

class FakeCallPeer implements CallPeer {
  CallMediaType? initializedWith;
  bool disposed = false;
  bool? muted;
  bool? cameraEnabled;
  final List<Map<String, dynamic>> remoteDescriptions = [];
  final List<Map<String, dynamic>> remoteCandidates = [];
  void Function(Map<String, dynamic>)? _candidateCallback;
  void Function(bool)? _connectionCallback;

  void fireConnection({required bool connected}) {
    _connectionCallback?.call(connected);
  }

  void fireCandidate(Map<String, dynamic> candidate) {
    _candidateCallback?.call(candidate);
  }

  @override
  Future<void> initialize({required CallMediaType mediaType}) async {
    initializedWith = mediaType;
  }

  @override
  Future<Map<String, dynamic>> createOffer() async =>
      {'type': 'offer', 'sdp': 'local-offer'};

  @override
  Future<Map<String, dynamic>> createAnswer() async =>
      {'type': 'answer', 'sdp': 'local-answer'};

  @override
  Future<void> applyRemoteDescription(Map<String, dynamic> sdp) async {
    remoteDescriptions.add(sdp);
  }

  @override
  Future<void> addRemoteCandidate(Map<String, dynamic> candidate) async {
    remoteCandidates.add(candidate);
  }

  @override
  void onLocalCandidate(
    void Function(Map<String, dynamic> candidate) callback,
  ) {
    _candidateCallback = callback;
  }

  @override
  void onConnectionState(void Function(bool connected) callback) {
    _connectionCallback = callback;
  }

  @override
  void setMuted(bool muted) => this.muted = muted;

  @override
  void setCameraEnabled(bool enabled) => cameraEnabled = enabled;

  @override
  Future<void> switchCamera() async {}

  @override
  Widget localView() => const SizedBox.shrink();

  @override
  Widget remoteView() => const SizedBox.shrink();

  @override
  Future<void> dispose() async => disposed = true;
}
