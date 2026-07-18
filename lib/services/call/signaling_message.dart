/// WebRTC call-signaling message exchanged over the chat WebSocket as
/// `{"type":"call_signal","data": <this.toJson()>}`.
enum CallSignalType {
  callInitiate,
  callAccept,
  callReject,
  callEnd,
  webrtcOffer,
  webrtcAnswer,
  iceCandidate;

  String get wire => switch (this) {
        CallSignalType.callInitiate => 'call_initiate',
        CallSignalType.callAccept => 'call_accept',
        CallSignalType.callReject => 'call_reject',
        CallSignalType.callEnd => 'call_end',
        CallSignalType.webrtcOffer => 'webrtc_offer',
        CallSignalType.webrtcAnswer => 'webrtc_answer',
        CallSignalType.iceCandidate => 'ice_candidate',
      };

  static CallSignalType? fromWire(String? value) => switch (value) {
        'call_initiate' => CallSignalType.callInitiate,
        'call_accept' => CallSignalType.callAccept,
        'call_reject' => CallSignalType.callReject,
        'call_end' => CallSignalType.callEnd,
        'webrtc_offer' => CallSignalType.webrtcOffer,
        'webrtc_answer' => CallSignalType.webrtcAnswer,
        'ice_candidate' => CallSignalType.iceCandidate,
        _ => null,
      };
}

class SignalingMessage {
  final CallSignalType type;
  final String threadId;
  final String targetUserId;
  final String? callId;
  final String? callerUserId;
  final Map<String, dynamic>? sdp; // {'type':..., 'sdp':...}
  final Map<String, dynamic>?
      candidate; // {'candidate':..., 'sdpMid':..., 'sdpMLineIndex':...}
  final String? reason;

  // ignore: sort_constructors_first
  const SignalingMessage({
    required this.type,
    required this.threadId,
    required this.targetUserId,
    this.callId,
    this.callerUserId,
    this.sdp,
    this.candidate,
    this.reason,
  });

  Map<String, dynamic> toJson() => {
        'type': type.wire,
        'threadId': threadId,
        'targetUserId': targetUserId,
        if (callId != null) 'callId': callId,
        if (callerUserId != null) 'callerUserId': callerUserId,
        if (sdp != null) 'sdp': sdp,
        if (candidate != null) 'candidate': candidate,
        if (reason != null) 'reason': reason,
      };

  static SignalingMessage? fromJson(Map<String, dynamic> data) {
    final type = CallSignalType.fromWire(data['type'] as String?);
    if (type == null) {
      return null;
    }
    final threadId = data['threadId']?.toString();
    if (threadId == null || threadId.isEmpty) {
      return null;
    }
    return SignalingMessage(
      type: type,
      threadId: threadId,
      targetUserId: data['targetUserId']?.toString() ?? '',
      callId: data['callId']?.toString(),
      callerUserId: data['callerUserId']?.toString(),
      sdp: (data['sdp'] as Map?)?.cast<String, dynamic>(),
      candidate: (data['candidate'] as Map?)?.cast<String, dynamic>(),
      reason: data['reason']?.toString(),
    );
  }
}
