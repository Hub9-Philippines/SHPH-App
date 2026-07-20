import 'dart:async';

import 'package:flutter/foundation.dart';

import '/services/logging_service.dart';

import 'call_peer.dart';
import 'call_signaling.dart';
import 'signaling_message.dart';

typedef InitiateCallApi = Future<Map<String, dynamic>> Function({
  required String threadId,
  required String participantId,
  required CallMediaType mediaType,
});
typedef AcceptCallApi = Future<void> Function(String callId);
typedef RejectCallApi = Future<void> Function(String callId, {String? reason});
typedef EndCallApi = Future<void> Function(
  String callId, {
  String? reason,
  int? durationSeconds,
});
typedef ResolveParticipant = Future<CallParticipant> Function(
  String threadId,
  String userId,
);

/// Drives the source-branch 1:1 call state machine over injected signaling,
/// REST lifecycle callbacks, and a testable peer implementation.
class CallController extends ChangeNotifier {
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
    _subscription = _signaling.incoming.listen(
      (message) => unawaited(_onSignal(message)),
    );
  }

  final CallSignaling _signaling;
  final CallPeer Function() _peerFactory;
  final InitiateCallApi _initiateCallApi;
  final AcceptCallApi _acceptCallApi;
  final RejectCallApi _rejectCallApi;
  final EndCallApi _endCallApi;
  final ResolveParticipant _resolveParticipant;

  // Cancelled in [dispose].
  // ignore: cancel_subscriptions
  StreamSubscription<SignalingMessage>? _subscription;
  CallStatus _status = CallStatus.idle;
  CallParticipant? _participant;
  IncomingCall? _incomingCall;
  CallPeer? _peer;
  CallMediaType _mediaType = CallMediaType.video;
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isCaller = false;
  String? _callId;
  String? _threadId;
  String? _targetUserId;
  DateTime? _connectedAt;
  Object? _lastError;

  CallStatus get status => _status;
  CallParticipant? get participant => _participant;
  IncomingCall? get incomingCall => _incomingCall;
  CallPeer? get peer => _peer;
  CallMediaType get mediaType => _mediaType;
  bool get isMuted => _isMuted;
  bool get isCameraOff => _isCameraOff;
  bool get isBusy => _status != CallStatus.idle && _status != CallStatus.ended;
  DateTime? get connectedAt => _connectedAt;
  Object? get lastError => _lastError;

  Future<bool> initiateCall({
    required String threadId,
    required CallParticipant participant,
    required CallMediaType mediaType,
  }) async {
    if (isBusy || threadId.isEmpty || participant.userId.isEmpty) {
      return false;
    }
    _lastError = null;
    _isCaller = true;
    _threadId = threadId;
    _targetUserId = participant.userId;
    _participant = participant;
    _mediaType = mediaType;
    _setStatus(CallStatus.outgoing);

    try {
      final record = await _initiateCallApi(
        threadId: threadId,
        participantId: participant.userId,
        mediaType: mediaType,
      );
      final callId = record['id']?.toString();
      if (callId == null || callId.isEmpty) {
        throw StateError('Call initiation did not return an id');
      }
      _callId = callId;
      await _createPeer();
      _signaling.sendSignal(
        SignalingMessage(
          type: CallSignalType.callInitiate,
          threadId: threadId,
          targetUserId: participant.userId,
          callId: callId,
          callType: mediaType.name,
        ),
      );
      notifyListeners();
      return true;
    } catch (error, stackTrace) {
      await _fail(error, stackTrace);
      return false;
    }
  }

  Future<bool> acceptIncomingCall() async {
    final incoming = _incomingCall;
    if (incoming == null || incoming.callId.isEmpty) {
      return false;
    }
    _lastError = null;
    _isCaller = false;
    _callId = incoming.callId;
    _threadId = incoming.threadId;
    _targetUserId = incoming.participant.userId;
    _participant = incoming.participant;
    _mediaType = incoming.mediaType;
    _incomingCall = null;
    _setStatus(CallStatus.connecting);

    try {
      await _acceptCallApi(incoming.callId);
      await _createPeer();
      _signaling.sendSignal(
        SignalingMessage(
          type: CallSignalType.callAccept,
          threadId: incoming.threadId,
          targetUserId: incoming.participant.userId,
          callId: incoming.callId,
          callType: incoming.mediaType.name,
        ),
      );
      notifyListeners();
      return true;
    } catch (error, stackTrace) {
      await _fail(error, stackTrace);
      return false;
    }
  }

  Future<bool> rejectIncomingCall({String? reason}) async {
    final incoming = _incomingCall;
    if (incoming == null || incoming.callId.isEmpty) {
      return false;
    }
    try {
      await _rejectCallApi(incoming.callId, reason: reason);
      _signaling.sendSignal(
        SignalingMessage(
          type: CallSignalType.callReject,
          threadId: incoming.threadId,
          targetUserId: incoming.participant.userId,
          callId: incoming.callId,
          reason: reason,
        ),
      );
      await _finish();
      return true;
    } catch (error, stackTrace) {
      await _fail(error, stackTrace);
      return false;
    }
  }

  Future<void> endCall({String? reason}) async {
    final duration = _connectedAt == null
        ? null
        : DateTime.now().difference(_connectedAt!).inSeconds;
    try {
      if (_callId != null) {
        await _endCallApi(
          _callId!,
          reason: reason,
          durationSeconds: duration,
        );
      }
      if (_threadId != null && _targetUserId != null) {
        _signaling.sendSignal(
          SignalingMessage(
            type: CallSignalType.callEnd,
            threadId: _threadId!,
            targetUserId: _targetUserId!,
            callId: _callId,
            reason: reason,
          ),
        );
      }
    } catch (error, stackTrace) {
      _lastError = error;
      LoggingService.warning(
        'Call end persistence failed',
        tag: 'CallController',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      await _finish();
    }
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    _peer?.setMuted(_isMuted);
    notifyListeners();
  }

  void toggleCamera() {
    if (_mediaType != CallMediaType.video) {
      return;
    }
    _isCameraOff = !_isCameraOff;
    _peer?.setCameraEnabled(!_isCameraOff);
    notifyListeners();
  }

  Future<void> switchCamera() async {
    if (_mediaType == CallMediaType.video) {
      await _peer?.switchCamera();
    }
  }

  Future<void> _createPeer() async {
    final peer = _peerFactory();
    _peer = peer;
    _wirePeer(peer);
    await peer.initialize(mediaType: _mediaType);
  }

  Future<void> _onSignal(SignalingMessage message) async {
    if (message.type != CallSignalType.callInitiate &&
        !_matchesActiveCall(message)) {
      return;
    }

    try {
      switch (message.type) {
        case CallSignalType.callInitiate:
          await _handleIncomingInitiate(message);
        case CallSignalType.callAccept:
          if (_isCaller && _peer != null) {
            _setStatus(CallStatus.connecting);
            final offer = await _peer!.createOffer();
            _sendActive(CallSignalType.webrtcOffer, sdp: offer);
          }
        case CallSignalType.webrtcOffer:
          if (!_isCaller && _peer != null && message.sdp != null) {
            await _peer!.applyRemoteDescription(message.sdp!);
            final answer = await _peer!.createAnswer();
            _sendActive(CallSignalType.webrtcAnswer, sdp: answer);
          }
        case CallSignalType.webrtcAnswer:
          if (_isCaller && _peer != null && message.sdp != null) {
            await _peer!.applyRemoteDescription(message.sdp!);
          }
        case CallSignalType.iceCandidate:
          if (_peer != null && message.candidate != null) {
            await _peer!.addRemoteCandidate(message.candidate!);
          }
        case CallSignalType.callReject:
        case CallSignalType.callEnd:
          await _finish();
      }
    } catch (error, stackTrace) {
      await _fail(error, stackTrace);
    }
  }

  Future<void> _handleIncomingInitiate(SignalingMessage message) async {
    final callerId = message.callerUserId;
    final callId = message.callId;
    if (callerId == null ||
        callerId.isEmpty ||
        callId == null ||
        callId.isEmpty) {
      return;
    }
    if (isBusy) {
      await _rejectCallApi(callId, reason: 'busy');
      _signaling.sendSignal(
        SignalingMessage(
          type: CallSignalType.callReject,
          threadId: message.threadId,
          targetUserId: callerId,
          callId: callId,
          reason: 'busy',
        ),
      );
      return;
    }
    final participant = await _resolveParticipant(message.threadId, callerId);
    final mediaType = message.callType == CallMediaType.audio.name
        ? CallMediaType.audio
        : CallMediaType.video;
    _incomingCall = IncomingCall(
      callId: callId,
      threadId: message.threadId,
      participant: participant,
      mediaType: mediaType,
    );
    _mediaType = mediaType;
    _setStatus(CallStatus.ringing);
  }

  bool _matchesActiveCall(SignalingMessage message) {
    if (_threadId == null || message.threadId != _threadId) {
      return false;
    }
    return _callId == null ||
        message.callId == null ||
        message.callId == _callId;
  }

  void _sendActive(
    CallSignalType type, {
    Map<String, dynamic>? sdp,
    Map<String, dynamic>? candidate,
  }) {
    if (_threadId == null || _targetUserId == null) {
      return;
    }
    _signaling.sendSignal(
      SignalingMessage(
        type: type,
        threadId: _threadId!,
        targetUserId: _targetUserId!,
        callId: _callId,
        sdp: sdp,
        candidate: candidate,
      ),
    );
  }

  void _wirePeer(CallPeer peer) {
    peer
      ..onLocalCandidate(
        (candidate) => _sendActive(
          CallSignalType.iceCandidate,
          candidate: candidate,
        ),
      )
      ..onConnectionState((connected) {
        if (connected && _status != CallStatus.connected) {
          _connectedAt = DateTime.now();
          _setStatus(CallStatus.connected);
        } else if (!connected && _status == CallStatus.connected) {
          unawaited(_finish());
        }
      });
  }

  Future<void> _fail(Object error, StackTrace stackTrace) async {
    _lastError = error;
    LoggingService.warning(
      'Call state transition failed',
      tag: 'CallController',
      error: error,
      stackTrace: stackTrace,
    );
    await _finish();
  }

  Future<void> _finish() async {
    final peer = _peer;
    _peer = null;
    await peer?.dispose();
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

  void _setStatus(CallStatus value) {
    if (_status != value) {
      _status = value;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    unawaited(_peer?.dispose());
    super.dispose();
  }
}
