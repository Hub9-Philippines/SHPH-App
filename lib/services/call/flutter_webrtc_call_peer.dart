import 'package:flutter/widgets.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'call_peer.dart';
import 'ice_config.dart';

/// Native WebRTC peer adapted from `feature/sync-from-shph-main`.
class FlutterWebrtcCallPeer implements CallPeer {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  void Function(Map<String, dynamic>)? _onCandidate;
  // ignore: avoid_positional_boolean_parameters
  void Function(bool connected)? _onConnection;
  bool _renderersInitialized = false;

  @override
  Future<void> initialize({required CallMediaType mediaType}) async {
    if (_peerConnection != null || _localStream != null) {
      throw StateError('Call peer is already initialized');
    }

    try {
      await _localRenderer.initialize();
      await _remoteRenderer.initialize();
      _renderersInitialized = true;

      final peerConnection =
          await createPeerConnection(IceConfig.configuration());
      _peerConnection = peerConnection;
      _wirePeerConnection(peerConnection);

      final video = mediaType == CallMediaType.video;
      final constraints = <String, dynamic>{
        'audio': true,
        'video': video
            ? <String, dynamic>{
                'facingMode': 'user',
                'mandatory': <String, dynamic>{},
                'optional': <dynamic>[],
              }
            : false,
      };
      final stream = await navigator.mediaDevices.getUserMedia(constraints);
      _localStream = stream;
      _localRenderer.srcObject = stream;
      for (final track in stream.getTracks()) {
        await peerConnection.addTrack(track, stream);
      }
    } catch (_) {
      await dispose();
      rethrow;
    }
  }

  void _wirePeerConnection(RTCPeerConnection peerConnection) {
    peerConnection.onIceCandidate = (candidate) {
      final value = candidate.candidate;
      if (value == null || value.isEmpty) {
        return;
      }
      _onCandidate?.call({
        'candidate': value,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });
    };
    peerConnection.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _remoteRenderer.srcObject = event.streams.first;
      }
    };
    peerConnection.onConnectionState = (state) {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        _onConnection?.call(true);
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        _onConnection?.call(false);
      }
    };
  }

  RTCPeerConnection get _requiredPeerConnection =>
      _peerConnection ?? (throw StateError('Call peer is not initialized'));

  @override
  Future<Map<String, dynamic>> createOffer() async {
    final peerConnection = _requiredPeerConnection;
    final offer = await peerConnection.createOffer(<String, dynamic>{});
    await peerConnection.setLocalDescription(offer);
    return {'type': offer.type, 'sdp': offer.sdp};
  }

  @override
  Future<Map<String, dynamic>> createAnswer() async {
    final peerConnection = _requiredPeerConnection;
    final answer = await peerConnection.createAnswer(<String, dynamic>{});
    await peerConnection.setLocalDescription(answer);
    return {'type': answer.type, 'sdp': answer.sdp};
  }

  @override
  Future<void> applyRemoteDescription(Map<String, dynamic> sdp) async {
    final description = parseSessionDescription(sdp);
    await _requiredPeerConnection.setRemoteDescription(description);
  }

  @override
  Future<void> addRemoteCandidate(Map<String, dynamic> candidate) async {
    final parsed = parseIceCandidate(candidate);
    await _requiredPeerConnection.addCandidate(parsed);
  }

  @override
  void onLocalCandidate(
    void Function(Map<String, dynamic> candidate) callback,
  ) {
    _onCandidate = callback;
  }

  @override
  // ignore: avoid_positional_boolean_parameters
  void onConnectionState(void Function(bool connected) callback) {
    _onConnection = callback;
  }

  @override
  void setMuted(bool muted) {
    for (final track in _localStream?.getAudioTracks() ?? const []) {
      track.enabled = !muted;
    }
  }

  @override
  void setCameraEnabled(bool enabled) {
    for (final track in _localStream?.getVideoTracks() ?? const []) {
      track.enabled = enabled;
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
    final stream = _localStream;
    final peerConnection = _peerConnection;
    _localStream = null;
    _peerConnection = null;
    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;

    for (final track in stream?.getTracks() ?? const []) {
      await track.stop();
    }
    await stream?.dispose();
    await peerConnection?.close();
    if (_renderersInitialized) {
      await _localRenderer.dispose();
      await _remoteRenderer.dispose();
      _renderersInitialized = false;
    }
    _onCandidate = null;
    _onConnection = null;
  }

  static RTCSessionDescription parseSessionDescription(
    Map<String, dynamic> value,
  ) {
    final type = value['type'];
    final sdp = value['sdp'];
    if (type is! String || type.isEmpty || sdp is! String || sdp.isEmpty) {
      throw const FormatException('Invalid WebRTC session description');
    }
    if (type != 'offer' && type != 'answer') {
      throw const FormatException('Unsupported WebRTC session type');
    }
    return RTCSessionDescription(sdp, type);
  }

  static RTCIceCandidate parseIceCandidate(Map<String, dynamic> value) {
    final candidate = value['candidate'];
    final sdpMid = value['sdpMid'];
    final lineIndex = value['sdpMLineIndex'];
    if (candidate is! String || candidate.isEmpty) {
      throw const FormatException('Invalid WebRTC ICE candidate');
    }
    if (sdpMid != null && sdpMid is! String) {
      throw const FormatException('Invalid WebRTC ICE media identifier');
    }
    if (lineIndex != null && lineIndex is! int) {
      throw const FormatException('Invalid WebRTC ICE line index');
    }
    return RTCIceCandidate(candidate, sdpMid as String?, lineIndex as int?);
  }
}
