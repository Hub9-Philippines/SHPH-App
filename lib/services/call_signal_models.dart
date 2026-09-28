/// Signaling message model for 1:1 call signaling over the SHPH websocket.
///
/// Wire format mirrors the web client (`shph-web/src/services/webrtcService.ts`)
/// exactly: the backend relays `call_signal` payloads verbatim, so keys stay
/// camelCase (`threadId`, `targetUserId`, `callId`, `mediaType`) and SDP /
/// ICE candidates keep their RTC shapes (`{ type, sdp }` / `{ candidate, ... }`).
///
/// Envelope sent over the socket:
/// `{ "type": "call_signal", "data": <CallSignalMessage> }`
library;

enum CallSignalType {
  callInitiate('call_initiate'),
  callAccept('call_accept'),
  callReject('call_reject'),
  callEnd('call_end'),
  webrtcOffer('webrtc_offer'),
  webrtcAnswer('webrtc_answer'),
  iceCandidate('ice_candidate');

  const CallSignalType(this.wireName);
  final String wireName;

  static CallSignalType? fromWire(String? value) {
    for (final t in CallSignalType.values) {
      if (t.wireName == value) {
        return t;
      }
    }
    return null;
  }
}

enum CallMediaType { audio, video }

String callMediaTypeWire(CallMediaType type) =>
    type == CallMediaType.audio ? 'audio' : 'video';

CallMediaType callMediaTypeFromWire(String? value) =>
    value == 'audio' ? CallMediaType.audio : CallMediaType.video;

/// SDP description init — matches `RTCSessionDescriptionInit`.
class SdpDescription {
  const SdpDescription({required this.type, required this.sdp});

  final String type; // 'offer' | 'answer' | 'pranswer' | 'rollback'
  final String sdp;

  Map<String, dynamic> toJson() => {'type': type, 'sdp': sdp};

  static SdpDescription fromJson(Map<String, dynamic> json) => SdpDescription(
        type: json['type']?.toString() ?? 'offer',
        sdp: json['sdp']?.toString() ?? '',
      );
}

/// ICE candidate init — matches `RTCIceCandidateInit`.
class IceCandidateInit {
  const IceCandidateInit({
    required this.candidate,
    this.sdpMid,
    this.sdpMLineIndex,
    this.usernameFragment,
  });

  final String candidate;
  final String? sdpMid;
  final int? sdpMLineIndex;
  final String? usernameFragment;

  Map<String, dynamic> toJson() => {
        'candidate': candidate,
        'sdpMid': sdpMid,
        'sdpMLineIndex': sdpMLineIndex,
        if (usernameFragment != null) 'usernameFragment': usernameFragment,
      };

  static IceCandidateInit? fromJson(Object? json) {
    if (json is! Map) {
      return null;
    }
    final candidate = json['candidate']?.toString() ?? '';
    if (candidate.isEmpty) {
      return null;
    }
    return IceCandidateInit(
      candidate: candidate,
      sdpMid: json['sdpMid']?.toString(),
      sdpMLineIndex: json['sdpMLineIndex'] is num
          ? (json['sdpMLineIndex'] as num).toInt()
          : int.tryParse(json['sdpMLineIndex']?.toString() ?? ''),
      usernameFragment: json['usernameFragment']?.toString(),
    );
  }
}

/// One signaling message (the `data` of a `call_signal` envelope).
class CallSignalMessage {
  const CallSignalMessage({
    required this.type,
    this.threadId,
    this.targetUserId,
    this.callerUserId,
    this.callId,
    this.mediaType,
    this.sdp,
    this.candidate,
  });

  final CallSignalType type;

  /// Thread the call belongs to.
  final String? threadId;

  /// The user this message is directed at (callee for outgoing signals,
  /// caller for incoming ones).
  final String? targetUserId;

  /// Sent on `call_initiate` so the callee knows who is calling.
  final String? callerUserId;

  /// REST call record id (`/api/chat/calls/initiate/` → `id`).
  final String? callId;

  final CallMediaType? mediaType;
  final SdpDescription? sdp;
  final IceCandidateInit? candidate;

  /// Full envelope for the websocket.
  Map<String, dynamic> toEnvelopeJson() => {
        'type': 'call_signal',
        'data': toJson(),
      };

  Map<String, dynamic> toJson() => {
        'type': type.wireName,
        if (threadId != null) 'threadId': threadId,
        if (targetUserId != null) 'targetUserId': targetUserId,
        if (callerUserId != null) 'callerUserId': callerUserId,
        if (callId != null) 'callId': callId,
        if (mediaType != null) 'mediaType': callMediaTypeWire(mediaType!),
        if (sdp != null) 'sdp': sdp!.toJson(),
        if (candidate != null) 'candidate': candidate!.toJson(),
      };

  /// Parses the `data` of a received `call_signal` envelope.
  static CallSignalMessage? fromEnvelopeData(Object? data) {
    if (data is! Map) {
      return null;
    }
    final type = CallSignalType.fromWire(data['type']?.toString());
    if (type == null) {
      return null;
    }
    final sdpJson = data['sdp'];
    return CallSignalMessage(
      type: type,
      threadId: data['threadId']?.toString(),
      targetUserId: data['targetUserId']?.toString(),
      callerUserId: data['callerUserId']?.toString(),
      callId: data['callId']?.toString(),
      mediaType: data['mediaType'] == null
          ? null
          : callMediaTypeFromWire(data['mediaType']?.toString()),
      sdp: sdpJson is Map ? SdpDescription.fromJson(Map.from(sdpJson)) : null,
      candidate: IceCandidateInit.fromJson(data['candidate']),
    );
  }
}
