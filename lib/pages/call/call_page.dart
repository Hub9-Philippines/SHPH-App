import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/services/call/call_controller.dart';
import '/services/call/call_peer.dart';

class CallPage extends StatelessWidget {
  const CallPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CallController>();
    final peer = controller.peer;

    // Auto-close when the call is over.
    if (controller.status == CallStatus.idle ||
        controller.status == CallStatus.ended) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).maybePop();
        }
      });
    }

    final statusLabel = switch (controller.status) {
      CallStatus.outgoing => 'Calling…',
      CallStatus.connecting => 'Connecting…',
      CallStatus.connected => 'Connected',
      _ => '',
    };

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
              child:
                  peer?.remoteView() ?? const ColoredBox(color: Colors.black)),
          Positioned(
            top: 48,
            right: 16,
            width: 110,
            height: 150,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: peer?.localView() ?? const SizedBox.shrink(),
            ),
          ),
          Positioned(
            top: 56,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(controller.participant?.name ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 20)),
                Text(statusLabel,
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _CtrlButton(
                  key: const Key('call_mute_btn'),
                  icon: controller.isMuted ? Icons.mic_off : Icons.mic,
                  onTap: controller.toggleMute,
                ),
                _CtrlButton(
                  key: const Key('call_camera_btn'),
                  icon: controller.isCameraOff
                      ? Icons.videocam_off
                      : Icons.videocam,
                  onTap: controller.toggleCamera,
                ),
                _CtrlButton(
                  key: const Key('call_switch_btn'),
                  icon: Icons.cameraswitch,
                  onTap: controller.switchCamera,
                ),
                _CtrlButton(
                  key: const Key('call_hangup_btn'),
                  icon: Icons.call_end,
                  color: Colors.red,
                  onTap: controller.endCall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CtrlButton extends StatelessWidget {
  const _CtrlButton({
    required this.icon,
    required this.onTap,
    super.key,
    this.color = Colors.white24,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
            radius: 28,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white)),
      );
}
