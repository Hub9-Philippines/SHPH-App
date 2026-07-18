import 'dart:async';

import 'signaling_message.dart';

typedef SignalSender = void Function(Map<String, dynamic> message);

/// Typed call-signaling adapter referenced from the sync branch.
///
/// Transport is deliberately injected until the deployed SHPH WebSocket URL
/// and authentication subprotocol have been verified.
class CallSignaling {
  CallSignaling({
    required SignalSender send,
    required Stream<Map<String, dynamic>> messages,
  })  : _send = send,
        _messages = messages;

  final SignalSender _send;
  final Stream<Map<String, dynamic>> _messages;

  Stream<SignalingMessage> get incoming => _messages
      .where((message) =>
          message['type'] == 'call_signal' && message['data'] is Map)
      .map((message) {
        final data = (message['data'] as Map).cast<String, dynamic>();
        return SignalingMessage.fromJson(data);
      })
      .where((message) => message != null)
      .cast<SignalingMessage>();

  void sendSignal(SignalingMessage message) {
    _send({'type': 'call_signal', 'data': message.toJson()});
  }
}
