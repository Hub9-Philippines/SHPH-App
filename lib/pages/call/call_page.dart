import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/services/call/call_controller.dart';
import '/services/call/call_peer.dart';

class CallPage extends StatefulWidget {
  const CallPage({super.key});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  Timer? _durationTimer;
  Duration _elapsed = Duration.zero;

  @override
  void dispose() {
    _durationTimer?.cancel();
    super.dispose();
  }

  void _startTimer(DateTime connectedAt) {
    _durationTimer?.cancel();
    _elapsed = DateTime.now().difference(connectedAt);
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _elapsed = DateTime.now().difference(connectedAt);
        });
      }
    });
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CallController>();
    final peer = controller.peer;

    // Auto-close when the call is over.
    if (controller.status == CallStatus.idle ||
        controller.status == CallStatus.ended) {
      _durationTimer?.cancel();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).maybePop();
        }
      });
    }

    // Start/stop duration timer based on connection state.
    if (controller.status == CallStatus.connected &&
        controller.connectedAt != null &&
        _durationTimer == null) {
      _startTimer(controller.connectedAt!);
    } else if (controller.status != CallStatus.connected) {
      _durationTimer?.cancel();
      _durationTimer = null;
      _elapsed = Duration.zero;
    }

    final statusLabel = switch (controller.status) {
      CallStatus.outgoing => 'Calling…',
      CallStatus.connecting => 'Connecting…',
      CallStatus.connected => _formatDuration(_elapsed),
      _ => '',
    };

    final photoUrl = controller.participant?.photoUrl;

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
                if (photoUrl != null && photoUrl.isNotEmpty)
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: NetworkImage(photoUrl),
                  )
                else
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white, size: 32),
                  ),
                const SizedBox(height: 12),
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
