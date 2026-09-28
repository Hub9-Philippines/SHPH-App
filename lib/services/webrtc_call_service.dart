import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;

import '/api/resources/chat_api.dart';
import '/services/call_signal_models.dart';
import '/services/logging_service.dart';
import '/services/websocket_service.dart';

/// 1:1 direct audio/video call engine — port of the web app's
/// `webrtcService.ts` (direct-call subset; group/SFU calls are out of scope).
///
/// Signaling interop contract (must match the web client byte-for-byte):
/// - Envelope: `{ "type": "call_signal", "data": <CallSignalMessage> }`
/// - Message keys are camelCase (`threadId`, `targetUserId`, `callId`,
///   `mediaType`); the backend relays payloads verbatim.
/// - Call flow: `call_initiate` → callee `call_accept` → caller
///   `webrtc_offer` → callee `webrtc_answer` → `ice_candidate` both ways.
/// - Perfect negotiation: caller is impolite, callee is polite.
class ShphWebRTCCallService {
  ShphWebRTCCallService._() {
    ShphWebSocketService.instance.addHandler('call_signal', _onCallSignal);
  }

  static final ShphWebRTCCallService instance = ShphWebRTCCallService._();

  final _chatApi = ShphChatApi.instance;

  // Peer connection state.
  webrtc.RTCPeerConnection? _pc;
  webrtc.MediaStream? _localStream;
  webrtc.MediaStream? _remoteStream;
  final List<IceCandidateInit> _pendingCandidates = [];

  // Session state.
  bool _isInitiator = false;
  bool _polite = false;
  bool _makingOffer = false;
  String? _threadId;
  String? _targetUserId;
  String? _callerUserId;
  String? _currentCallId;
  CallMediaType _currentMediaType = CallMediaType.video;
  bool _ignoreOffer = false;

  /// Pre-acquired local media from the permission gate, used as-is by the
  /// next `call()` / `acceptCall()` to avoid a second getUserMedia prompt.
  webrtc.MediaStream? preAcquiredStream;

  // ---- Callbacks (web parity with setCallbacks) ----
  void Function(String status)? onStatusChange;
  void Function(webrtc.MediaStream? local, webrtc.MediaStream? remote)?
      onStreamChange;
  void Function(
          String callerId, String threadId, CallMediaType mediaType)? onIncomingCall;

  /// Fired when the peer connection fails mid-call (reason string for the
  /// session controller's failure mapping).
  void Function(String reason)? onCallFailed;

  String? get callId => _currentCallId;
  String? get activeThreadId => _threadId;
  CallMediaType get mediaType => _currentMediaType;
  webrtc.MediaStream? get localStream => _localStream;
  webrtc.MediaStream? get remoteStream => _remoteStream;

  // ---- Public API ----

  /// Places a call: REST initiate → local media → `call_initiate` signal.
  /// Pass [preAcquiredStream] from the permission gate to skip the second
  /// getUserMedia prompt.
  Future<void> call({
    required String threadId,
    required String calleeId,
    required String callerId,
    required CallMediaType mediaType,
    webrtc.MediaStream? preAcquiredStream,
  }) async {
    if (_threadId != null) {
      throw StateError('A call is already in progress');
    }

    _threadId = threadId;
    _targetUserId = calleeId;
    _callerUserId = callerId;
    _isInitiator = true;
    _polite = false; // caller is impolite
    _currentMediaType = mediaType;

    _notifyStatus('outgoing');

    // 1. Create the call record via REST.
    try {
      final response = await _chatApi.initiateCall({
        'thread_id': threadId,
        'callee_id': int.tryParse(calleeId) ?? calleeId,
        'media_type': callMediaTypeWire(mediaType),
      });
      _currentCallId = response['id']?.toString();
      LoggingService.info(
        'Call record created: $_currentCallId',
        tag: 'WebRTC',
      );
    } catch (e) {
      LoggingService.error(
        'Failed to create call record',
        tag: 'WebRTC',
        error: e,
      );
      _resetSession();
      rethrow;
    }

    // 2. Attach the gate's stream or acquire media (non-fatal on failure —
    // a later accept retry still applies).
    if (preAcquiredStream != null) {
      _localStream = preAcquiredStream;
      this.preAcquiredStream = null;
      _notifyStreams();
    } else {
      try {
        _localStream = await getLocalMedia(mediaType);
        _notifyStreams();
      } catch (e) {
        LoggingService.warning(
          'Local media pre-acquisition failed (will retry on accept): $e',
          tag: 'WebRTC',
        );
      }
    }

    // 3. Ring the callee.
    await _sendSignal(CallSignalMessage(
      type: CallSignalType.callInitiate,
      threadId: threadId,
      targetUserId: calleeId,
      callerUserId: callerId,
      callId: _currentCallId,
      mediaType: mediaType,
    ));
  }

  /// Accepts the pending incoming call: REST accept → media → peer
  /// connection → `call_accept` signal. The caller then sends the offer.
  /// Throws when local media cannot be acquired so the session controller
  /// can abort the accept honestly (REST reject + failed state).
  Future<void> acceptCall() async {
    if (_threadId == null || _targetUserId == null) {
      LoggingService.warning(
        'acceptCall aborted — missing threadId or targetUserId',
        tag: 'WebRTC',
      );
      return;
    }

    _notifyStatus('connecting');

    // Local media first: aborting BEFORE the REST accept avoids a phantom
    // accepted call when media is unavailable (web parity on ordering).
    _localStream = preAcquiredStream ?? await getLocalMedia(_currentMediaType);
    preAcquiredStream = null;
    _notifyStreams();

    // Persist acceptance via REST (web parity).
    if (_currentCallId != null) {
      try {
        await _chatApi.acceptCall(_currentCallId!);
      } catch (e) {
        LoggingService.error(
          'Failed to accept call via API',
          tag: 'WebRTC',
          error: e,
        );
      }
    }

    await _createPeerConnection();

    await _sendSignal(CallSignalMessage(
      type: CallSignalType.callAccept,
      threadId: _threadId,
      targetUserId: _targetUserId,
      callId: _currentCallId,
    ));
  }

  /// Declines the incoming call: REST reject + `call_reject` signal.
  Future<void> rejectCall() async {
    if (_threadId == null || _targetUserId == null) {
      return;
    }
    if (_currentCallId != null) {
      try {
        await _chatApi.rejectCall(_currentCallId!);
      } catch (e) {
        LoggingService.error(
          'Failed to reject call via API',
          tag: 'WebRTC',
          error: e,
        );
      }
    }
    await _sendSignal(CallSignalMessage(
      type: CallSignalType.callReject,
      threadId: _threadId,
      targetUserId: _targetUserId,
      callId: _currentCallId,
    ));
    _notifyStatus('ended');
    cleanup();
  }

  /// Ends the active call: system message + REST end + `call_end` signal.
  Future<void> endCall() async {
    if (_threadId == null || _targetUserId == null) {
      return;
    }

    await _sendSystemMessage('Video call ended');

    if (_currentCallId != null) {
      try {
        await _chatApi.endCall(_currentCallId!);
      } catch (e) {
        LoggingService.error(
          'Failed to end call via API',
          tag: 'WebRTC',
          error: e,
        );
      }
    }

    await _sendSignal(CallSignalMessage(
      type: CallSignalType.callEnd,
      threadId: _threadId,
      targetUserId: _targetUserId,
      callId: _currentCallId,
    ));

    _notifyStatus('ended');
    cleanup();
  }

  /// Toggles mic capture. Returns the new muted state.
  bool toggleMute() {
    final stream = _localStream;
    if (stream == null) {
      return false;
    }
    final tracks = stream.getAudioTracks();
    final wasEnabled = tracks.isNotEmpty && tracks.first.enabled;
    for (final track in tracks) {
      track.enabled = !track.enabled;
    }
    return !wasEnabled;
  }

  /// Toggles the camera. Returns the new camera-on state.
  bool toggleCamera() {
    final stream = _localStream;
    if (stream == null) {
      return false;
    }
    final tracks = stream.getVideoTracks();
    final wasEnabled = tracks.isNotEmpty && tracks.first.enabled;
    for (final track in tracks) {
      track.enabled = !track.enabled;
    }
    return !wasEnabled;
  }

  /// Flips the local camera between front and rear (video calls only).
  /// Returns true when the switch was requested successfully.
  Future<bool> switchCamera() async {
    final stream = _localStream;
    final track = stream?.getVideoTracks().isNotEmpty == true
        ? stream!.getVideoTracks().first
        : null;
    if (track == null) {
      return false;
    }
    try {
      await webrtc.Helper.switchCamera(track);
      return true;
    } catch (e) {
      LoggingService.warning(
        'switchCamera failed: $e',
        tag: 'WebRTC',
      );
      return false;
    }
  }

  /// Routes audio to the loudspeaker (true) or earpiece (false).
  Future<bool> setSpeakerphoneOn(bool enabled) async {
    try {
      await webrtc.Helper.setSpeakerphoneOn(enabled);
      return true;
    } catch (e) {
      LoggingService.warning(
        'setSpeakerphoneOn($enabled) failed: $e',
        tag: 'WebRTC',
      );
      return false;
    }
  }

  /// Releases all media/peer state. Called after every call termination.
  void cleanup() {
    _pc?.close();
    _pc = null;
    _localStream?.getTracks().forEach((track) => track.stop());
    _localStream?.dispose();
    _localStream = null;
    _remoteStream?.dispose();
    _remoteStream = null;
    _pendingCandidates.clear();
    _notifyStreams();
    _resetSession();
  }

  /// Acquires mic (audio calls) or mic+camera (video calls) streams.
  Future<webrtc.MediaStream> getLocalMedia(CallMediaType mediaType) async {
    try {
      final isAudio = mediaType == CallMediaType.audio;
      final stream = await webrtc.navigator.mediaDevices.getUserMedia({
        'audio': true,
        if (!isAudio)
          'video': {
            'facingMode': 'user',
            'width': {'ideal': 1280},
            'height': {'ideal': 720},
          },
      });
      return stream;
    } catch (e) {
      LoggingService.error(
        'Failed to get local media',
        tag: 'WebRTC',
        error: e,
      );
      rethrow;
    }
  }

  // ---- Signaling handlers ----

  void _onCallSignal(Map<String, dynamic> data) {
    final signal = CallSignalMessage.fromEnvelopeData(data);
    if (signal == null) {
      LoggingService.warning(
        'Received call_signal with invalid payload: $data',
        tag: 'WebRTC',
      );
      return;
    }
    switch (signal.type) {
      case CallSignalType.callInitiate:
        _handleCallInitiate(signal);
      case CallSignalType.callAccept:
        _handleCallAccept(signal);
      case CallSignalType.callReject:
        _handleCallReject();
      case CallSignalType.callEnd:
        _handleCallEnd();
      case CallSignalType.webrtcOffer:
        _handleOffer(signal);
      case CallSignalType.webrtcAnswer:
        _handleAnswer(signal);
      case CallSignalType.iceCandidate:
        _handleIceCandidate(signal);
    }
  }

  Future<void> _handleCallInitiate(CallSignalMessage msg) async {
    final callerId = msg.callerUserId;
    if (callerId == null || callerId.isEmpty) {
      return;
    }
    // A second incoming call while busy is declined implicitly by ignoring
    // it (UI shows only one call); the caller gives up on no-answer.
    if (_threadId != null) {
      LoggingService.warning(
        'Ignoring incoming call — already in a call',
        tag: 'WebRTC',
      );
      return;
    }

    _threadId = msg.threadId;
    _targetUserId = msg.callerUserId;
    _callerUserId = callerId;
    _isInitiator = false;
    _polite = true; // callee is polite
    _currentMediaType = msg.mediaType ?? CallMediaType.video;
    if (msg.callId != null) {
      _currentCallId = msg.callId;
    }

    onIncomingCall?.call(callerId, msg.threadId ?? '', _currentMediaType);
    _notifyStatus('ringing');
  }

  Future<void> _handleCallAccept(CallSignalMessage msg) async {
    if (!_isInitiator) {
      return;
    }
    await _createPeerConnection();
    _notifyStatus('connecting');
    await _createOffer();
  }

  void _handleCallReject() {
    _notifyStatus('ended');
    cleanup();
  }

  void _handleCallEnd() {
    _notifyStatus('ended');
    cleanup();
  }

  Future<void> _handleOffer(CallSignalMessage msg) async {
    final sdp = msg.sdp;
    if (sdp == null) {
      return;
    }
    if (_pc == null) {
      await _createPeerConnection();
    }
    final pc = _pc;
    if (pc == null) {
      return;
    }

    // Glare handling (perfect negotiation).
    final isCollision = _makingOffer && !_polite;
    if (isCollision) {
      _ignoreOffer = true;
      return;
    }

    try {
      await pc.setRemoteDescription(
        webrtc.RTCSessionDescription(sdp.sdp, sdp.type),
      );
      await _createAnswer();
    } catch (e) {
      LoggingService.error(
        'Error handling offer',
        tag: 'WebRTC',
        error: e,
      );
    } finally {
      _ignoreOffer = false;
    }
  }

  Future<void> _handleAnswer(CallSignalMessage msg) async {
    final sdp = msg.sdp;
    final pc = _pc;
    if (sdp == null || pc == null) {
      return;
    }
    // Validate signaling state before applying the remote answer.
    if (pc.signalingState != webrtc.RTCSignalingState.RTCSignalingStateHaveLocalOffer) {
      LoggingService.warning(
        'handleAnswer aborted — unexpected signaling state',
        tag: 'WebRTC',
      );
      return;
    }
    try {
      await pc.setRemoteDescription(
        webrtc.RTCSessionDescription(sdp.sdp, sdp.type),
      );
      await _drainPendingCandidates(pc);
    } catch (e) {
      LoggingService.error(
        'Error handling answer',
        tag: 'WebRTC',
        error: e,
      );
    }
  }

  Future<void> _handleIceCandidate(CallSignalMessage msg) async {
    final candidate = msg.candidate;
    final pc = _pc;
    if (candidate == null) {
      return;
    }
    if (pc == null) {
      // Buffer until the peer connection exists and signaling is stable.
      _pendingCandidates.add(candidate);
      return;
    }
    final remoteDescSet = pc.getRemoteDescription() != null;
    if (!remoteDescSet) {
      _pendingCandidates.add(candidate);
      return;
    }
    try {
      await pc.addCandidate(webrtc.RTCIceCandidate(
        candidate.candidate,
        candidate.sdpMid,
        candidate.sdpMLineIndex,
      ));
    } catch (e) {
      if (!_ignoreOffer) {
        LoggingService.warning(
          'ICE candidate add failed: $e',
          tag: 'WebRTC',
        );
      }
    }
  }

  Future<void> _drainPendingCandidates(webrtc.RTCPeerConnection pc) async {
    if (_pendingCandidates.isEmpty) {
      return;
    }
    final pending = List<IceCandidateInit>.from(_pendingCandidates);
    _pendingCandidates.clear();
    for (final candidate in pending) {
      try {
        await pc.addCandidate(webrtc.RTCIceCandidate(
          candidate.candidate,
          candidate.sdpMid,
          candidate.sdpMLineIndex,
        ));
      } catch (e) {
        LoggingService.warning(
          'Pending ICE candidate add failed: $e',
          tag: 'WebRTC',
        );
      }
    }
  }

  // ---- Peer connection ----

  Future<void> _createPeerConnection() async {
    if (_pc != null) {
      return;
    }
    if (_localStream == null) {
      _localStream = await getLocalMedia(_currentMediaType);
      _notifyStreams();
    }

    final pc = await webrtc.createPeerConnection({
      'iceServers': [
        {
          'urls': [
            'stun:stun.l.google.com:19302',
            'stun:stun1.l.google.com:19302',
          ],
        },
        // TURN is added when the environment provides credentials; the web
        // client does the same via VITE_TURN_USERNAME/VITE_TURN_CREDENTIAL.
        if (const String.fromEnvironment('TURN_USERNAME').isNotEmpty)
          {
            'urls': [
              'turn:app.serbisyohubph.com:3478?transport=udp',
              'turn:app.serbisyohubph.com:3478?transport=tcp',
              'turns:app.serbisyohubph.com:5349?transport=tcp',
            ],
            'username': const String.fromEnvironment('TURN_USERNAME'),
            'credential': const String.fromEnvironment('TURN_CREDENTIAL'),
          },
      ],
      'iceCandidatePoolSize': 10,
      'bundlePolicy': 'max-bundle',
      'rtcpMuxPolicy': 'require',
    });
    _pc = pc;

    // Add local tracks.
    for (final track in _localStream!.getTracks()) {
      await pc.addTrack(track, _localStream!);
    }

    // Remote tracks.
    pc.onTrack = (event) async {
      final stream = event.streams.isNotEmpty ? event.streams.first : null;
      if (stream != null) {
        _remoteStream = stream;
      } else {
        final factory = webrtc.RTCFactoryNative.instance;
        _remoteStream = await factory.createLocalMediaStream('remote');
        _remoteStream!.addTrack(event.track);
      }
      _notifyStreams();
      _notifyStatus('connected');
    };

    // Send our ICE candidates to the remote peer.
    pc.onIceCandidate = (candidate) {
      final candidateStr = candidate.candidate;
      if (candidateStr == null || candidateStr.isEmpty) {
        return; // gathering complete
      }
      if (_threadId == null || _targetUserId == null) {
        return;
      }
      unawaited(_sendSignal(CallSignalMessage(
        type: CallSignalType.iceCandidate,
        threadId: _threadId,
        targetUserId: _targetUserId,
        candidate: IceCandidateInit(
          candidate: candidateStr,
          sdpMid: candidate.sdpMid,
          sdpMLineIndex: candidate.sdpMLineIndex,
        ),
      )));
    };

    // Connection state → UI.
    pc.onConnectionState = (state) {
      LoggingService.info(
        'Peer connection state: $state',
        tag: 'WebRTC',
      );
      switch (state) {
        case webrtc.RTCPeerConnectionState.RTCPeerConnectionStateConnected:
          _notifyStatus('connected');
        case webrtc.RTCPeerConnectionState.RTCPeerConnectionStateFailed:
          onCallFailed?.call('connectionFailed');
          _notifyStatus('ended');
          cleanup();
        case webrtc.RTCPeerConnectionState.RTCPeerConnectionStateClosed:
          _notifyStatus('ended');
          cleanup();
        default:
          break;
      }
    };

    // Renegotiation (caller side).
    pc.onRenegotiationNeeded = () {
      if (_isInitiator && !_makingOffer) {
        unawaited(_createOffer());
      }
    };
  }

  Future<void> _createOffer() async {
    final pc = _pc;
    if (pc == null || _makingOffer) {
      return;
    }
    _makingOffer = true;
    try {
      final offer = await pc.createOffer();
      await pc.setLocalDescription(offer);
      await _sendSignal(CallSignalMessage(
        type: CallSignalType.webrtcOffer,
        threadId: _threadId,
        targetUserId: _targetUserId,
        sdp: SdpDescription(type: offer.type ?? 'offer', sdp: offer.sdp ?? ''),
      ));
    } catch (e) {
      LoggingService.error(
        'Error creating offer',
        tag: 'WebRTC',
        error: e,
      );
    } finally {
      _makingOffer = false;
    }
  }

  Future<void> _createAnswer() async {
    final pc = _pc;
    if (pc == null) {
      return;
    }
    try {
      final answer = await pc.createAnswer();
      await pc.setLocalDescription(answer);
      await _sendSignal(CallSignalMessage(
        type: CallSignalType.webrtcAnswer,
        threadId: _threadId,
        targetUserId: _targetUserId,
        sdp: SdpDescription(
            type: answer.type ?? 'answer', sdp: answer.sdp ?? ''),
      ));
    } catch (e) {
      LoggingService.error(
        'Error creating answer',
        tag: 'WebRTC',
        error: e,
      );
    }
  }

  // ---- Helpers ----

  Future<void> _sendSignal(CallSignalMessage msg) async {
    final sent = await ShphWebSocketService.instance.send(msg.toEnvelopeJson());
    if (!sent) {
      LoggingService.warning(
        'Signaling message queued (socket down): ${msg.type.wireName}',
        tag: 'WebRTC',
      );
    }
  }

  Future<void> _sendSystemMessage(String content) async {
    final threadId = _threadId;
    if (threadId == null) {
      return;
    }
    try {
      await _chatApi.sendMessageExtended(
        threadId,
        content: content,
        isSystemMessage: true,
      );
    } catch (e) {
      LoggingService.warning(
        'Failed to send call system message: $e',
        tag: 'WebRTC',
      );
    }
  }

  void _resetSession() {
    _isInitiator = false;
    _polite = false;
    _makingOffer = false;
    _ignoreOffer = false;
    _threadId = null;
    _targetUserId = null;
    _callerUserId = null;
    _currentCallId = null;
    _currentMediaType = CallMediaType.video;
  }

  void _notifyStatus(String status) {
    onStatusChange?.call(status);
  }

  void _notifyStreams() {
    onStreamChange?.call(_localStream, _remoteStream);
  }
}
