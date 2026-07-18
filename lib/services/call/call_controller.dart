import 'dart:async';

import 'package:flutter/foundation.dart';

import 'call_peer.dart';
import 'call_signaling.dart';
import 'signaling_message.dart';

typedef InitiateCallApi = Future<Map<String, dynamic>> Function({
  required String threadId,
  required int calleeId,
});
typedef AcceptCallApi = Future<void> Function(String callId);
typedef RejectCallApi = Future<void> Function(String callId, {String? reason});
typedef EndCallApi = Future<void> Function(String callId,
    {String? reason, int? duration});
typedef ResolveParticipant = Future<CallParticipant> Function(
    String threadId, String fallbackUserId);

/// Drives the 1:1 call state machine over [CallSignaling] + a [CallPeer].
/// The caller is always the SDP offerer; the offer is created only after
/// the callee's `call_accept` arrives.
class CallController extends ChangeNotifier {
  final CallSignaling _signaling;
  final CallPeer Function() _peerFactory;
  final InitiateCallApi _initiateCallApi;
  final AcceptCallApi _acceptCallApi;
  final RejectCallApi _rejectCallApi;
  final EndCallApi _endCallApi;
  final ResolveParticipant _resolveParticipant;

  StreamSubscription<SignalingMessage>? _sub;

  CallStatus _status = CallStatus.idle;
  CallParticipant? _participant;
  IncomingCall? _incomingCall;
  bool _isMuted = false;
  bool _isCameraOff = false;
  CallPeer? _peer;

  // Active-call bookkeeping.
  String? _callId;
  String? _threadId;
  String? _targetUserId;
  bool _isCaller = false;
  DateTime? _connectedAt;

  // ignore: sort_constructors_first
  CallController({
    required CallSignaling signaling,
    required CallPeer Function() peerFactory,
    required InitiateCallApi initiateCallApi,
    required AcceptCallApi acceptCallApi,
    required RejectCallApi rejectCallApi,
    required EndCallApi endCallApi,
    required ResolveParticipant resolveParticipant,
  })  : _signaling = signaling,
        _peerFactory = peerFactory,
        _initiateCallApi = initiateCallApi,
        _acceptCallApi = acceptCallApi,
        _rejectCallApi = rejectCallApi,
        _endCallApi = endCallApi,
        _resolveParticipant = resolveParticipant {
    _sub = _signaling.incoming.listen(_onSignal);
  }

  CallStatus get status => _status;
  CallParticipant? get participant => _participant;
  IncomingCall? get incomingCall => _incomingCall;
  bool get isMuted => _isMuted;
  bool get isCameraOff => _isCameraOff;
  CallPeer? get peer => _peer;
  bool get isBusy => _status != CallStatus.idle && _status != CallStatus.ended;

  // ---- Caller ----
  Future<void> initiateCall({
    required String threadId,
    required CallParticipant callee,
  }) async {
    if (isBusy) {
      return;
    }
    _isCaller = true;
    _threadId = threadId;
    _targetUserId = callee.userId;
    _participant = callee;
    _setStatus(CallStatus.outgoing);

    try {
      final calleeId = int.tryParse(callee.userId) ?? 0;
      final record =
          await _initiateCallApi(threadId: threadId, calleeId: calleeId);
      _callId = record['id']?.toString();

      _peer = _peerFactory();
      _wirePeer(_peer!);
      await _peer!.initialize(video: true);

      _signaling.sendSignal(SignalingMessage(
        type: CallSignalType.callInitiate,
        threadId: threadId,
        targetUserId: callee.userId,
        callId: _callId,
      ));
      notifyListeners();
    } catch (_) {
      _finish();
    }
  }

  // ---- Callee ----
  Future<void> acceptIncomingCall() async {
    final call = _incomingCall;
    if (call == null) {
      return;
    }
    _isCaller = false;
    _callId = call.callId;
    _threadId = call.threadId;
    _targetUserId = call.participant.userId;
    _participant = call.participant;
    _incomingCall = null;
    _setStatus(CallStatus.connecting);

    try {
      await _acceptCallApi(call.callId);
      _peer = _peerFactory();
      _wirePeer(_peer!);
      await _peer!.initialize(video: true);

      _signaling.sendSignal(SignalingMessage(
        type: CallSignalType.callAccept,
        threadId: call.threadId,
        targetUserId: call.participant.userId,
        callId: call.callId,
      ));
      notifyListeners();
    } catch (_) {
      _finish();
    }
  }

  Future<void> rejectIncomingCall({String? reason}) async {
    final call = _incomingCall;
    if (call == null) {
      return;
    }
    await _rejectCallApi(call.callId, reason: reason);
    _signaling.sendSignal(SignalingMessage(
      type: CallSignalType.callReject,
      threadId: call.threadId,
      targetUserId: call.participant.userId,
      callId: call.callId,
      reason: reason,
    ));
    _incomingCall = null;
    _finish();
  }

  // ---- Either side ----
  Future<void> endCall({String? reason}) async {
    final callId = _callId;
    final threadId = _threadId;
    final target = _targetUserId;
    final duration = _connectedAt == null
        ? null
        : DateTime.now().difference(_connectedAt!).inSeconds;
    if (callId != null) {
      await _endCallApi(callId, reason: reason, duration: duration);
    }
    if (threadId != null && target != null) {
      _signaling.sendSignal(SignalingMessage(
        type: CallSignalType.callEnd,
        threadId: threadId,
        targetUserId: target,
        callId: callId,
        reason: reason,
      ));
    }
    _finish();
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    _peer?.setMuted(_isMuted);
    notifyListeners();
  }

  void toggleCamera() {
    _isCameraOff = !_isCameraOff;
    _peer?.setCameraEnabled(!_isCameraOff);
    notifyListeners();
  }

  Future<void> switchCamera() async => _peer?.switchCamera();

  // ---- Signal handling ----
  Future<void> _onSignal(SignalingMessage msg) async {
    switch (msg.type) {
      case CallSignalType.callInitiate:
        if (isBusy) {
          // Auto-reject a second incoming call while busy.
          if (msg.callId != null) {
            await _rejectCallApi(msg.callId!, reason: 'busy');
            _signaling.sendSignal(SignalingMessage(
              type: CallSignalType.callReject,
              threadId: msg.threadId,
              targetUserId: msg.callerUserId ?? '',
              callId: msg.callId,
              reason: 'busy',
            ));
          }
          return;
        }
        final callerId = msg.callerUserId ?? msg.targetUserId;
        final participant = await _resolveParticipant(msg.threadId, callerId);
        _incomingCall = IncomingCall(
          callId: msg.callId ?? '',
          threadId: msg.threadId,
          participant: participant,
        );
        _setStatus(CallStatus.ringing);
        break;

      case CallSignalType.callAccept:
        // Caller: peer accepted -> create and send the offer.
        if (_isCaller && _peer != null) {
          _setStatus(CallStatus.connecting);
          final offer = await _peer!.createOffer();
          _signaling.sendSignal(SignalingMessage(
            type: CallSignalType.webrtcOffer,
            threadId: _threadId!,
            targetUserId: _targetUserId!,
            callId: _callId,
            sdp: offer,
          ));
        }
        break;

      case CallSignalType.webrtcOffer:
        // Callee: apply offer, answer.
        if (!_isCaller && _peer != null && msg.sdp != null) {
          await _peer!.applyRemoteDescription(msg.sdp!);
          final answer = await _peer!.createAnswer();
          _signaling.sendSignal(SignalingMessage(
            type: CallSignalType.webrtcAnswer,
            threadId: msg.threadId,
            targetUserId: _targetUserId ?? msg.callerUserId ?? '',
            callId: _callId,
            sdp: answer,
          ));
        }
        break;

      case CallSignalType.webrtcAnswer:
        if (_isCaller && _peer != null && msg.sdp != null) {
          await _peer!.applyRemoteDescription(msg.sdp!);
        }
        break;

      case CallSignalType.iceCandidate:
        if (_peer != null && msg.candidate != null) {
          await _peer!.addRemoteCandidate(msg.candidate!);
        }
        break;

      case CallSignalType.callReject:
        _finish();
        break;

      case CallSignalType.callEnd:
        _finish();
        break;
    }
  }

  void _wirePeer(CallPeer peer) {
    peer
      ..onLocalCandidate((candidate) {
        if (_threadId != null && _targetUserId != null) {
          _signaling.sendSignal(SignalingMessage(
            type: CallSignalType.iceCandidate,
            threadId: _threadId!,
            targetUserId: _targetUserId!,
            callId: _callId,
            candidate: candidate,
          ));
        }
      })
      ..onConnectionState((connected) {
        if (connected && _status != CallStatus.connected) {
          _connectedAt = DateTime.now();
          _setStatus(CallStatus.connected);
        } else if (!connected && _status == CallStatus.connected) {
          _finish();
        }
      });
  }

  void _setStatus(CallStatus s) {
    _status = s;
    notifyListeners();
  }

  void _finish() {
    _peer?.dispose();
    _peer = null;
    _participant = null;
    _incomingCall = null;
    _callId = null;
    _threadId = null;
    _targetUserId = null;
    _isCaller = false;
    _isMuted = false;
    _isCameraOff = false;
    _connectedAt = null;
    _setStatus(CallStatus.ended);
  }

  @override
  void dispose() {
    _sub?.cancel();
    _peer?.dispose();
    super.dispose();
  }
}
