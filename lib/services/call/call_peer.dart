import 'package:flutter/widgets.dart';

enum CallStatus { idle, outgoing, ringing, connecting, connected, ended }

class CallParticipant {
  const CallParticipant({
    required this.userId,
    required this.name,
    this.photoUrl,
  });

  final String userId;
  final String name;
  final String? photoUrl;
}

class IncomingCall {
  const IncomingCall({
    required this.callId,
    required this.threadId,
    required this.participant,
  });

  final String callId;
  final String threadId;
  final CallParticipant participant;
}

/// Plain-Dart WebRTC peer abstraction. The concrete implementation wraps
/// `flutter_webrtc`; video surfaces are returned as `Widget` so callers never
/// touch plugin types (keeps `CallController` unit-testable with a fake).
abstract class CallPeer {
  /// Acquire local media and prepare renderers. [video] false = voice only.
  Future<void> initialize({required bool video});

  /// Caller side: create + set local offer; returns the SDP map to send.
  Future<Map<String, dynamic>> createOffer();

  /// Callee side: create + set local answer (call [applyRemoteDescription] first).
  Future<Map<String, dynamic>> createAnswer();

  /// Apply a received offer/answer SDP map.
  Future<void> applyRemoteDescription(Map<String, dynamic> sdp);

  /// Add a received ICE candidate map.
  Future<void> addRemoteCandidate(Map<String, dynamic> candidate);

  /// Register a callback fired when a local ICE candidate is gathered.
  void onLocalCandidate(void Function(Map<String, dynamic> candidate) cb);

  /// Register a callback fired when the connection becomes (dis)connected.
  // ignore: avoid_positional_boolean_parameters
  void onConnectionState(void Function(bool connected) cb);

  // ignore: avoid_positional_boolean_parameters
  void setMuted(bool muted);
  // ignore: avoid_positional_boolean_parameters
  void setCameraEnabled(bool enabled);
  Future<void> switchCamera();

  Widget localView();
  Widget remoteView();

  Future<void> dispose();
}
