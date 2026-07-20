import '/api/resources/chat_api.dart';
import '/services/websocket_service.dart';

import 'call_controller.dart';
import 'call_peer.dart';
import 'call_signaling.dart';
import 'flutter_webrtc_call_peer.dart';

typedef ThreadDetailsLoader = Future<Map<String, dynamic>> Function(
  String threadId,
);

/// Builds the production call graph against the verified SHPH REST/WS contract.
CallController buildProductionCallController({
  ShphChatApi? api,
  ShphWebSocketService? socket,
  CallPeer Function()? peerFactory,
}) {
  final chatApi = api ?? ShphChatApi.instance;
  final webSocket = socket ?? ShphWebSocketService.instance;
  return CallController(
    signaling: CallSignaling.fromWebSocket(webSocket),
    peerFactory: peerFactory ?? FlutterWebrtcCallPeer.new,
    initiateCallApi: ({
      required threadId,
      required participantId,
      required mediaType,
    }) async {
      if (!webSocket.isConnected && !await webSocket.connect()) {
        throw StateError('Realtime connection is unavailable');
      }
      final calleeId = int.tryParse(participantId);
      if (calleeId == null || calleeId <= 0) {
        throw const FormatException('Invalid call participant id');
      }
      return chatApi.initiateCall(threadId: threadId, calleeId: calleeId);
    },
    acceptCallApi: chatApi.acceptCall,
    rejectCallApi: chatApi.rejectCall,
    endCallApi: (
      callId, {
      reason,
      durationSeconds,
    }) =>
        chatApi.endCall(
      callId,
      reason: reason,
      durationSeconds: durationSeconds,
    ),
    resolveParticipant: (threadId, fallbackUserId) => resolveThreadParticipant(
      threadId,
      fallbackUserId: fallbackUserId,
      loadThread: chatApi.getThreadDetails,
    ),
  );
}

Future<CallParticipant> resolveThreadParticipant(
  String threadId, {
  required String fallbackUserId,
  required ThreadDetailsLoader loadThread,
  String fallbackName = 'Incoming call',
}) async {
  try {
    final thread = await loadThread(threadId);
    final raw = thread['other_participant'];
    final participant =
        raw is Map ? raw.cast<String, dynamic>() : const <String, dynamic>{};
    final id = (participant['id'] ?? fallbackUserId).toString().trim();
    final name =
        (participant['display_name'] ?? participant['name'] ?? fallbackName)
            .toString()
            .trim();
    return CallParticipant(
      userId: id.isEmpty ? fallbackUserId : id,
      name: name.isEmpty ? fallbackName : name,
      photoUrl:
          (participant['photo_url'] ?? participant['avatar_url'])?.toString(),
    );
  } catch (_) {
    return CallParticipant(userId: fallbackUserId, name: fallbackName);
  }
}
