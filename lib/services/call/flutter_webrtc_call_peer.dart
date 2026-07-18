import 'package:flutter/widgets.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'call_peer.dart';
import 'ice_config.dart';

class FlutterWebrtcCallPeer implements CallPeer {
  RTCPeerConnection? _pc;
  MediaStream? _localStream;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  void Function(Map<String, dynamic>)? _onCandidate;
  // ignore: avoid_positional_boolean_parameters
  void Function(bool connected)? _onConnection;

  @override
  Future<void> initialize({required bool video}) async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    _pc = await createPeerConnection(IceConfig.configuration());

    _pc!.onIceCandidate = (c) {
      _onCandidate?.call({
        'candidate': c.candidate,
        'sdpMid': c.sdpMid,
        'sdpMLineIndex': c.sdpMLineIndex,
      });
    };
    _pc!.onTrack = (e) {
      if (e.streams.isNotEmpty) {
        _remoteRenderer.srcObject = e.streams.first;
      }
    };
    // Phase 1: end only on failed/closed. 'disconnected' is usually a transient
    // blip that recovers (or escalates to failed); ending on it drops calls on
    // brief network hiccups. (Vue does ICE-restart here; that's a Phase-2 item.)
    _pc!.onConnectionState = (s) {
      final connected =
          s == RTCPeerConnectionState.RTCPeerConnectionStateConnected;
      final dropped =
          s == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
              s == RTCPeerConnectionState.RTCPeerConnectionStateClosed;
      if (connected) {
        _onConnection?.call(true);
      }
      if (dropped) {
        _onConnection?.call(false);
      }
    };

    final constraints = <String, dynamic>{
      'audio': true,
      'video': video
          ? {'facingMode': 'user', 'mandatory': {}, 'optional': []}
          : false,
    };
    _localStream = await navigator.mediaDevices.getUserMedia(constraints);
    _localRenderer.srcObject = _localStream;
    for (final track in _localStream!.getTracks()) {
      await _pc!.addTrack(track, _localStream!);
    }
  }

  @override
  Future<Map<String, dynamic>> createOffer() async {
    final offer = await _pc!.createOffer(<String, dynamic>{});
    await _pc!.setLocalDescription(offer);
    return {'type': offer.type, 'sdp': offer.sdp};
  }

  @override
  Future<Map<String, dynamic>> createAnswer() async {
    final answer = await _pc!.createAnswer(<String, dynamic>{});
    await _pc!.setLocalDescription(answer);
    return {'type': answer.type, 'sdp': answer.sdp};
  }

  @override
  Future<void> applyRemoteDescription(Map<String, dynamic> sdp) async {
    await _pc!.setRemoteDescription(
      RTCSessionDescription(sdp['sdp'] as String?, sdp['type'] as String?),
    );
  }

  @override
  Future<void> addRemoteCandidate(Map<String, dynamic> candidate) async {
    await _pc!.addCandidate(RTCIceCandidate(
      candidate['candidate'] as String?,
      candidate['sdpMid'] as String?,
      candidate['sdpMLineIndex'] as int?,
    ));
  }

  @override
  void onLocalCandidate(void Function(Map<String, dynamic>) cb) =>
      _onCandidate = cb;

  @override
  // ignore: avoid_positional_boolean_parameters
  void onConnectionState(void Function(bool connected) cb) =>
      _onConnection = cb;

  @override
  void setMuted(bool muted) {
    for (final t in _localStream?.getAudioTracks() ?? const []) {
      t.enabled = !muted;
    }
  }

  @override
  void setCameraEnabled(bool enabled) {
    for (final t in _localStream?.getVideoTracks() ?? const []) {
      t.enabled = enabled;
    }
  }

  @override
  Future<void> switchCamera() async {
    final tracks = _localStream?.getVideoTracks() ?? const [];
    if (tracks.isNotEmpty) {
      await Helper.switchCamera(tracks.first);
    }
  }

  @override
  Widget localView() => RTCVideoView(_localRenderer, mirror: true);

  @override
  Widget remoteView() => RTCVideoView(
        _remoteRenderer,
        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
      );

  @override
  Future<void> dispose() async {
    for (final t in _localStream?.getTracks() ?? const []) {
      await t.stop();
    }
    await _localStream?.dispose();
    await _pc?.close();
    await _localRenderer.dispose();
    await _remoteRenderer.dispose();
    _pc = null;
    _localStream = null;
    _onCandidate = null;
    _onConnection = null;
  }
}
