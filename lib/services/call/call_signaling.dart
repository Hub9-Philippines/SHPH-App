import '/services/websocket_service.dart';
import 'signaling_message.dart';

/// Sends and receives WebRTC call signals over the existing chat WebSocket.
/// Reuses [ShphWebSocketService]'s connection, reconnect, and heartbeat.
class CallSignaling {
  CallSignaling({
    required void Function(Map<String, dynamic>) send,
    required Stream<Map<String, dynamic>> messages,
  })  : _send = send,
        _messages = messages;

  factory CallSignaling.fromWebSocket() {
    final ws = ShphWebSocketService.instance;
    return CallSignaling(send: ws.send, messages: ws.messages);
  }

  final void Function(Map<String, dynamic>) _send;
  final Stream<Map<String, dynamic>> _messages;

  Stream<SignalingMessage> get incoming => _messages
      .where((m) => m['type'] == 'call_signal' && m['data'] is Map)
      .map((m) =>
          SignalingMessage.fromJson((m['data'] as Map).cast<String, dynamic>()))
      .where((m) => m != null)
      .cast<SignalingMessage>();

  void sendSignal(SignalingMessage msg) {
    _send({'type': 'call_signal', 'data': msg.toJson()});
  }
}
