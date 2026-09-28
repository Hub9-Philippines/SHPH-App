import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;

import '/auth/base_auth_user_provider.dart';
import '/services/call_signal_models.dart';
import '/services/logging_service.dart';
import '/services/webrtc_call_service.dart';

/// UI-facing state machine for the active call. Bridges the WebRTC service's
/// callbacks into a single `ChangeNotifier` the call screen and incoming
/// overlay listen to.
enum CallUiState { idle, outgoing, ringing, connecting, active, ended, failed }

class CallParticipant {
  const CallParticipant({required this.id, required this.name, this.photo});

  final String id;
  final String name;
  final String? photo;
}

class CallSessionController extends ChangeNotifier {
  CallSessionController._() {
    final service = ShphWebRTCCallService.instance;
    service.onStatusChange = _onServiceStatus;
    service.onStreamChange = _onStreams;
    service.onIncomingCall = _onIncomingCall;
    service.onCallFailed = _onCallFailed;
  }

  /// How long a caller waits for an accept and a callee waits for user
  /// action before the call is torn down (matches the heartbeat reconnect
  /// window so a dead-socket caller never rings a phone that cannot answer).
  static const Duration ringTimeout = Duration(seconds: 45);

  Timer? _ringTimer;

  static final CallSessionController instance = CallSessionController._();

  final webrtc.RTCVideoRenderer localRenderer = webrtc.RTCVideoRenderer();
  final webrtc.RTCVideoRenderer remoteRenderer = webrtc.RTCVideoRenderer();
  bool _renderersInitialized = false;

  CallUiState state = CallUiState.idle;
  CallParticipant? remoteParticipant;
  CallParticipant? incomingCaller;
  CallMediaType mediaType = CallMediaType.audio;

  bool isMuted = false;
  bool isSpeakerOn = true;
  bool isCameraOff = false;

  /// Whether the in-call overlay is collapsed to its picture-in-picture bubble.
  /// Web parity: `VideoCallOverlay` keeps the call alive in a minimized PiP so
  /// the user can drop back to the chat room without ending the call.
  bool isMinimized = false;

  /// Collapses the in-call overlay to the PiP bubble.
  void minimize() {
    if (isMinimized) {
      return;
    }
    isMinimized = true;
    notifyListeners();
  }

  /// Restores the in-call overlay from the PiP bubble to the full panel.
  void expand() {
    if (!isMinimized) {
      return;
    }
    isMinimized = false;
    notifyListeners();
  }

  /// Flips between the full panel and the PiP bubble.
  void toggleMinimized() => isMinimized ? expand() : minimize();

  /// Set when a call ends with a user-relevant outcome (declined, failed,
  /// remote hangup) so the entry point can show a fitting SnackBar.
  String? lastEndReason;

  Timer? _durationTimer;
  Duration callDuration = Duration.zero;

  /// Auto-dismiss timer for the terminal outcome panel (`ended` / `failed`).
  /// `ended` used to settle on its own; `failed` had no settle path at all and
  /// would otherwise leave the controller parked in a terminal state.
  Timer? _outcomeTimer;
  static const Duration _outcomeGrace = Duration(seconds: 3);

  bool get isCallActive =>
      state == CallUiState.outgoing ||
      state == CallUiState.ringing ||
      state == CallUiState.connecting ||
      state == CallUiState.active;

  bool get isIncoming => state == CallUiState.ringing;

  // ---- Outgoing flow ----

  /// Places a call through the WebRTC service. Throws when the socket is
  /// unavailable so the caller can surface an error (spec: no half-open
  /// calls). Pass the permission gate's [preAcquiredStream] so the call
  /// never starts without working media.
  Future<void> call({
    required String threadId,
    required String calleeId,
    required CallParticipant participant,
    required CallMediaType mediaType,
    webrtc.MediaStream? preAcquiredStream,
  }) async {
    if (isCallActive) {
      throw StateError('A call is already in progress');
    }
    lastEndReason = null;
    remoteParticipant = participant;
    this.mediaType = mediaType;
    isMinimized = false;
    state = CallUiState.outgoing;
    notifyListeners();

    try {
      await ShphWebRTCCallService.instance.call(
        threadId: threadId,
        calleeId: calleeId,
        callerId: currentUser?.uid ?? '',
        mediaType: mediaType,
        preAcquiredStream: preAcquiredStream,
      );
      _startRingTimer();
    } catch (e) {
      state = CallUiState.failed;
      lastEndReason = 'callFailed';
      notifyListeners();
      rethrow;
    }
  }

  // ---- Incoming flow ----

  void _onIncomingCall(String callerId, String threadId, CallMediaType type) {
    if (isCallActive) {
      // Already busy: ignore — caller times out / gets no answer.
      return;
    }
    incomingCaller = CallParticipant(id: callerId, name: 'Incoming call');
    mediaType = type;
    isMinimized = false;
    state = CallUiState.ringing;
    _startRingTimer();
    notifyListeners();
  }

  /// Bounds the ring: caller waits [ringTimeout] for an accept, callee waits
  /// [ringTimeout] for user action. Cancelled on connect, end, user action,
  /// and logout.
  void _startRingTimer() {
    _cancelRingTimer();
    _ringTimer = Timer(ringTimeout, _onRingTimeout);
  }

  void _cancelRingTimer() {
    _ringTimer?.cancel();
    _ringTimer = null;
  }

  Future<void> _onRingTimeout() async {
    _ringTimer = null;
    switch (state) {
      case CallUiState.outgoing:
      case CallUiState.connecting:
        // Caller gave up: honest no-answer teardown via the normal end path
        // (REST end + call_end signal + session reset).
        LoggingService.info(
          'Outgoing call timed out — no answer',
          tag: 'CallSession',
        );
        lastEndReason = 'noAnswer';
        state = CallUiState.ended;
        notifyListeners();
        await endCall();
      case CallUiState.ringing:
        // User ignored the banner: auto-decline so a lost call_end frame
        // cannot leave a stuck overlay.
        LoggingService.info(
          'Incoming call timed out — auto-declining',
          tag: 'CallSession',
        );
        await declineIncomingCall();
      default:
        break;
    }
  }

  /// Accepts the incoming call after the permission gate granted media.
  Future<void> acceptIncomingCall({webrtc.MediaStream? preAcquiredStream}) async {
    if (state != CallUiState.ringing) {
      return;
    }
    _cancelRingTimer();
    remoteParticipant = incomingCaller;
    incomingCaller = null;
    if (preAcquiredStream != null) {
      ShphWebRTCCallService.instance.preAcquiredStream = preAcquiredStream;
    }
    try {
      await ShphWebRTCCallService.instance.acceptCall();
    } catch (e) {
      LoggingService.error(
        'acceptCall failed',
        tag: 'CallSession',
        error: e,
      );
      // Abort honestly: REST-reject so the caller is not left waiting on a
      // phantom accepted call, then surface the failure.
      await ShphWebRTCCallService.instance.rejectCall();
      _enterTerminalState(CallUiState.failed);
      lastEndReason = 'mediaDenied';
      notifyListeners();
    }
  }

  /// Declines the incoming call.
  Future<void> declineIncomingCall() async {
    if (state != CallUiState.ringing) {
      return;
    }
    _cancelRingTimer();
    await ShphWebRTCCallService.instance.rejectCall();
    state = CallUiState.idle;
    incomingCaller = null;
    notifyListeners();
  }

  /// Maps engine failures to the UI's terminal failed state.
  void _onCallFailed(String reason) {
    if (state == CallUiState.idle || state == CallUiState.ended) {
      return;
    }
    LoggingService.warning(
      'Call failed: $reason',
      tag: 'CallSession',
    );
    _cancelRingTimer();
    lastEndReason = reason;
    _enterTerminalState(CallUiState.failed);
  }

  // ---- In-call controls ----

  void toggleMute() {
    // toggleMute returns the NEW muted state.
    isMuted = ShphWebRTCCallService.instance.toggleMute();
    notifyListeners();
  }

  Future<void> toggleSpeaker() async {
    isSpeakerOn = !isSpeakerOn;
    await ShphWebRTCCallService.instance.setSpeakerphoneOn(isSpeakerOn);
    notifyListeners();
  }

  void toggleCamera() {
    isCameraOff = ShphWebRTCCallService.instance.toggleCamera();
    notifyListeners();
  }

  /// Flips the local camera between front and rear (video calls).
  Future<void> switchCamera() async {
    await ShphWebRTCCallService.instance.switchCamera();
    notifyListeners();
  }

  /// Hangs up the active call.
  Future<void> endCall() async {
    await ShphWebRTCCallService.instance.endCall();
  }

  /// Clears all call UI state on logout (socket is dropped by main.dart).
  void resetAfterLogout() {
    _cancelRingTimer();
    _stopDurationTimer();
    _cancelOutcomeTimer();
    ShphWebRTCCallService.instance.cleanup();
    state = CallUiState.idle;
    incomingCaller = null;
    remoteParticipant = null;
    isMuted = false;
    isSpeakerOn = true;
    isCameraOff = false;
    isMinimized = false;
    callDuration = Duration.zero;
    notifyListeners();
  }

  /// Dismisses a terminal call outcome (`ended` / `failed`) and returns the
  /// overlay to idle. The outcome panel auto-dismisses after a grace period,
  /// but the user can also close it immediately.
  void dismissCallOutcome() {
    if (state != CallUiState.ended && state != CallUiState.failed) {
      return;
    }
    _cancelOutcomeTimer();
    state = CallUiState.idle;
    remoteParticipant = null;
    isMinimized = false;
    notifyListeners();
  }

  // ---- Service callbacks ----

  void _onServiceStatus(String status) {
    switch (status) {
      case 'outgoing':
        state = CallUiState.outgoing;
      case 'ringing':
        state = CallUiState.ringing;
      case 'connecting':
        state = CallUiState.connecting;
        // For the caller: the callee answered (call_accept received). For
        // the callee: the user tapped accept. Either way the ring timer's
        // job is done — only the connection remains.
        _cancelRingTimer();
      case 'connected':
        state = CallUiState.active;
        _cancelRingTimer();
        _startDurationTimer();
        // Audio routing (task 5.1): video calls default to loudspeaker,
        // audio calls to the earpiece; the toggle applies user intent live.
        unawaited(
          ShphWebRTCCallService.instance.setSpeakerphoneOn(
            mediaType == CallMediaType.video ? isSpeakerOn : false,
          ),
        );
      case 'ended':
        _enterTerminalState(CallUiState.ended);
      default:
        break;
    }
    notifyListeners();
  }

  void _onStreams(
      webrtc.MediaStream? local, webrtc.MediaStream? remote) async {
    // Only video calls need the native renderers. An audio call's streams
    // carry no video track, so initializing them would spin up two EGL
    // surfaces that can never receive a frame — libwebrtc then logs 0-fps
    // `EglRenderer` stats once per second for the rest of the call and the
    // GPU holds two idle surfaces. Audio call UI reads no renderer, and no
    // call state travels on this callback, so returning early is safe.
    if (mediaType != CallMediaType.video) {
      return;
    }
    if (!_renderersInitialized) {
      await _initRenderers();
    }
    if (local != null) {
      localRenderer.srcObject = local;
    }
    if (remote != null) {
      remoteRenderer.srcObject = remote;
    }
    notifyListeners();
  }

  Future<void> _initRenderers() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
    _renderersInitialized = true;
  }

  void _disposeRenderers() {
    if (_renderersInitialized) {
      localRenderer.srcObject = null;
      remoteRenderer.srcObject = null;
    }
  }

  void _startDurationTimer() {
    _stopDurationTimer();
    callDuration = Duration.zero;
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      callDuration += const Duration(seconds: 1);
      notifyListeners();
    });
  }

  void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  void _cancelOutcomeTimer() {
    _outcomeTimer?.cancel();
    _outcomeTimer = null;
  }

  /// Shows the terminal outcome panel and schedules its auto-dismiss.
  void _enterTerminalState(CallUiState terminal) {
    state = terminal;
    isMinimized = false;
    _cancelRingTimer();
    _stopDurationTimer();
    _disposeRenderers();
    _cancelOutcomeTimer();
    _outcomeTimer = Timer(_outcomeGrace, dismissCallOutcome);
  }

  String get formattedDuration {
    final m = callDuration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = callDuration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = callDuration.inHours;
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  void dispose() {
    _cancelRingTimer();
    _stopDurationTimer();
    _cancelOutcomeTimer();
    localRenderer.dispose();
    remoteRenderer.dispose();
    super.dispose();
  }
}
