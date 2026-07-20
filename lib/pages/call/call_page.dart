import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/services/call/call_controller.dart';
import '/services/call/call_peer.dart';

/// Active audio/video call surface adapted from `feature/sync-from-shph-main`.
class CallPage extends StatefulWidget {
  const CallPage({super.key});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  Timer? _durationTimer;
  Duration _elapsed = Duration.zero;
  DateTime? _timerStartedAt;

  @override
  void dispose() {
    _durationTimer?.cancel();
    super.dispose();
  }

  void _syncTimer(DateTime? connectedAt) {
    if (connectedAt == null) {
      _durationTimer?.cancel();
      _durationTimer = null;
      _timerStartedAt = null;
      _elapsed = Duration.zero;
      return;
    }
    if (_timerStartedAt == connectedAt && _durationTimer != null) {
      return;
    }
    _durationTimer?.cancel();
    _timerStartedAt = connectedAt;
    _elapsed = DateTime.now().difference(connectedAt);
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _elapsed = DateTime.now().difference(connectedAt));
      }
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CallController>();
    final peer = controller.peer;
    final isVideo = controller.mediaType == CallMediaType.video;

    if (controller.status == CallStatus.connected) {
      _syncTimer(controller.connectedAt);
    } else {
      _syncTimer(null);
    }

    if (controller.status == CallStatus.idle ||
        (controller.status == CallStatus.ended &&
            controller.lastError == null)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
    }

    final statusLabel = switch (controller.status) {
      CallStatus.outgoing => 'Calling…',
      CallStatus.ringing => 'Ringing…',
      CallStatus.connecting => 'Connecting…',
      CallStatus.connected => _formatDuration(_elapsed),
      CallStatus.ended => 'Call ended',
      CallStatus.idle => '',
    };
    final participant = controller.participant;
    final photoUrl = participant?.photoUrl;

    if (controller.status == CallStatus.ended && controller.lastError != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.call_end_rounded,
                      color: Colors.white, size: 64),
                  const SizedBox(height: 20),
                  const Text(
                    'Call could not be connected',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Check microphone and camera permissions, then try again from the conversation.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Return to conversation'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return PopScope(
      canPop: controller.status == CallStatus.idle ||
          controller.status == CallStatus.ended,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: isVideo
                    ? peer?.remoteView() ??
                        const ColoredBox(color: Colors.black)
                    : const ColoredBox(color: Colors.black),
              ),
              if (isVideo)
                Positioned(
                  top: 12,
                  right: 16,
                  width: 110,
                  height: 150,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: peer?.localView() ?? const SizedBox.shrink(),
                  ),
                ),
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white24,
                      backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                          ? NetworkImage(photoUrl)
                          : null,
                      child: photoUrl == null || photoUrl.isEmpty
                          ? const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 32,
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      participant?.name ?? 'Call',
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    Text(
                      statusLabel,
                      key: const Key('call_status_label'),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 28,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _CallControlButton(
                      key: const Key('call_mute_btn'),
                      label: controller.isMuted ? 'Unmute' : 'Mute',
                      icon: controller.isMuted ? Icons.mic_off : Icons.mic,
                      onPressed: controller.toggleMute,
                    ),
                    if (isVideo) ...[
                      _CallControlButton(
                        key: const Key('call_camera_btn'),
                        label: controller.isCameraOff
                            ? 'Enable camera'
                            : 'Disable camera',
                        icon: controller.isCameraOff
                            ? Icons.videocam_off
                            : Icons.videocam,
                        onPressed: controller.toggleCamera,
                      ),
                      _CallControlButton(
                        key: const Key('call_switch_btn'),
                        label: 'Switch camera',
                        icon: Icons.cameraswitch,
                        onPressed: () => unawaited(controller.switchCamera()),
                      ),
                    ],
                    _CallControlButton(
                      key: const Key('call_hangup_btn'),
                      label: 'End call',
                      icon: Icons.call_end,
                      color: Colors.red,
                      onPressed: () => unawaited(
                        controller.endCall(reason: 'user_ended'),
                      ),
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

class _CallControlButton extends StatelessWidget {
  const _CallControlButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    super.key,
    this.color = Colors.white24,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: IconButton.filled(
          tooltip: label,
          onPressed: onPressed,
          icon: Icon(icon),
          color: Colors.white,
          style: IconButton.styleFrom(
            backgroundColor: color,
            minimumSize: const Size(56, 56),
          ),
        ),
      );
}
