import 'package:flutter/widgets.dart';

enum CallStatus { idle, outgoing, ringing, connecting, connected, ended }

enum CallMediaType { audio, video }

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
    required this.mediaType,
  });

  final String callId;
  final String threadId;
  final CallParticipant participant;
  final CallMediaType mediaType;
}

/// Testable peer abstraction from `feature/sync-from-shph-main`.
abstract class CallPeer {
  Future<void> initialize({required CallMediaType mediaType});
  Future<Map<String, dynamic>> createOffer();
  Future<Map<String, dynamic>> createAnswer();
  Future<void> applyRemoteDescription(Map<String, dynamic> sdp);
  Future<void> addRemoteCandidate(Map<String, dynamic> candidate);
  void onLocalCandidate(void Function(Map<String, dynamic> candidate) callback);
  void onConnectionState(void Function(bool connected) callback);
  void setMuted(bool muted);
  void setCameraEnabled(bool enabled);
  Future<void> switchCamera();
  Widget localView();
  Widget remoteView();
  Future<void> dispose();
}
