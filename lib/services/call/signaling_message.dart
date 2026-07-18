/// Call-signaling protocol referenced from `feature/sync-from-shph-main`.
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

  static CallSignalType? fromWire(Object? value) => switch (value) {
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

  final CallSignalType type;
  final String threadId;
  final String targetUserId;
  final String? callId;
  final String? callerUserId;
  final Map<String, dynamic>? sdp;
  final Map<String, dynamic>? candidate;
  final String? reason;

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
    final type = CallSignalType.fromWire(data['type']);
    final threadId = data['threadId']?.toString().trim();
    final targetUserId = data['targetUserId']?.toString().trim();
    if (type == null || threadId == null || threadId.isEmpty) {
      return null;
    }
    if (targetUserId == null || targetUserId.isEmpty) {
      return null;
    }

    final sdp = _stringMap(data['sdp']);
    final candidate = _stringMap(data['candidate']);
    if ((type == CallSignalType.webrtcOffer ||
            type == CallSignalType.webrtcAnswer) &&
        sdp == null) {
      return null;
    }
    if (type == CallSignalType.iceCandidate && candidate == null) {
      return null;
    }

    return SignalingMessage(
      type: type,
      threadId: threadId,
      targetUserId: targetUserId,
      callId: data['callId']?.toString(),
      callerUserId: data['callerUserId']?.toString(),
      sdp: sdp,
      candidate: candidate,
      reason: data['reason']?.toString(),
    );
  }

  static Map<String, dynamic>? _stringMap(Object? value) {
    if (value is! Map) {
      return null;
    }
    try {
      return value.cast<String, dynamic>();
    } on TypeError {
      return null;
    }
  }
}
