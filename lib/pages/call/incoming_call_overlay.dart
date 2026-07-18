import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/services/call/call_controller.dart';
import '/services/call/call_peer.dart';

/// A global overlay that appears while an incoming call is ringing.
/// Mount once near the app root.
class IncomingCallOverlay extends StatelessWidget {
  const IncomingCallOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CallController>();
    if (controller.status != CallStatus.ringing ||
        controller.incomingCall == null) {
      return const SizedBox.shrink();
    }
    final call = controller.incomingCall!;

    return Material(
      color: Colors.black.withValues(alpha: 0.85),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 48),
            Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage:
                      (call.participant.photoUrl?.isNotEmpty ?? false)
                          ? NetworkImage(call.participant.photoUrl!)
                          : null,
                  child: (call.participant.photoUrl?.isEmpty ?? true)
                      ? const Icon(Icons.person, size: 48)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  call.participant.name.isNotEmpty
                      ? call.participant.name
                      : 'Incoming call',
                  style: const TextStyle(color: Colors.white, fontSize: 22),
                ),
                const SizedBox(height: 8),
                const Text('Incoming call',
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _RoundButton(
                    key: const Key('call_reject_btn'),
                    color: Colors.red,
                    icon: Icons.call_end,
                    onTap: () =>
                        controller.rejectIncomingCall(reason: 'declined'),
                  ),
                  _RoundButton(
                    key: const Key('call_accept_btn'),
                    color: Colors.green,
                    icon: Icons.videocam,
                    onTap: controller.acceptIncomingCall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton(
      {required this.color,
      required this.icon,
      required this.onTap,
      super.key});
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
            radius: 32,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white)),
      );
}
