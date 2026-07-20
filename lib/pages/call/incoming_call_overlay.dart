import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/services/call/call_controller.dart';
import '/services/call/call_peer.dart';

/// Full-screen incoming call prompt. Mount once inside the app guardrail scope.
class IncomingCallOverlay extends StatefulWidget {
  const IncomingCallOverlay({
    super.key,
    this.onAccepted,
  });

  final FutureOr<void> Function()? onAccepted;

  @override
  State<IncomingCallOverlay> createState() => _IncomingCallOverlayState();
}

class _IncomingCallOverlayState extends State<IncomingCallOverlay> {
  bool _handlingAction = false;

  Future<void> _accept(CallController controller) async {
    if (_handlingAction) {
      return;
    }
    setState(() => _handlingAction = true);
    final accepted = await controller.acceptIncomingCall();
    if (accepted) {
      await widget.onAccepted?.call();
    }
    if (mounted) {
      setState(() => _handlingAction = false);
    }
  }

  Future<void> _reject(CallController controller) async {
    if (_handlingAction) {
      return;
    }
    setState(() => _handlingAction = true);
    await controller.rejectIncomingCall(reason: 'declined');
    if (mounted) {
      setState(() => _handlingAction = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CallController>();
    final call = controller.incomingCall;
    if (controller.status != CallStatus.ringing || call == null) {
      return const SizedBox.shrink();
    }

    final photoUrl = call.participant.photoUrl;
    final isVideo = call.mediaType == CallMediaType.video;
    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.92),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 48),
              Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white24,
                    backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl)
                        : null,
                    child: photoUrl == null || photoUrl.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 48,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    call.participant.name.isEmpty
                        ? 'Incoming call'
                        : call.participant.name,
                    style: const TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isVideo ? 'Incoming video call' : 'Incoming audio call',
                    key: const Key('incoming_call_type'),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 48),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _IncomingActionButton(
                      key: const Key('call_reject_btn'),
                      label: 'Decline call',
                      color: Colors.red,
                      icon: Icons.call_end,
                      onPressed:
                          _handlingAction ? null : () => _reject(controller),
                    ),
                    _IncomingActionButton(
                      key: const Key('call_accept_btn'),
                      label: 'Accept call',
                      color: Colors.green,
                      icon: isVideo ? Icons.videocam : Icons.call,
                      onPressed:
                          _handlingAction ? null : () => _accept(controller),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IncomingActionButton extends StatelessWidget {
  const _IncomingActionButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton.filled(
        tooltip: label,
        onPressed: onPressed,
        icon: Icon(icon),
        color: Colors.white,
        style: IconButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: color.withValues(alpha: 0.5),
          minimumSize: const Size(64, 64),
        ),
      );
}
