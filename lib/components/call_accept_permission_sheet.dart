import 'package:flutter/material.dart';

import '/theme/app_theme.dart';

enum CallType { audio, video }

class CallAcceptPermissionSheet extends StatefulWidget {
  const CallAcceptPermissionSheet({
    super.key,
    required this.callType,
    this.onPermissionGranted,
    this.onDecline,
  });

  final CallType callType;
  final VoidCallback? onPermissionGranted;
  final VoidCallback? onDecline;

  static Future<void> show(
    BuildContext context, {
    required CallType callType,
    VoidCallback? onPermissionGranted,
    VoidCallback? onDecline,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => CallAcceptPermissionSheet(
        callType: callType,
        onPermissionGranted: onPermissionGranted,
        onDecline: onDecline,
      ),
    );
  }

  @override
  State<CallAcceptPermissionSheet> createState() => _CallAcceptPermissionSheetState();
}

class _CallAcceptPermissionSheetState extends State<CallAcceptPermissionSheet> {
  bool _granted = false;
  bool _denied = false;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final isVideo = widget.callType == CallType.video;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: theme.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              isVideo ? Icons.videocam_rounded : Icons.phone_rounded,
              size: 40, color: theme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isVideo ? 'Camera & Microphone Access' : 'Microphone Access',
            style: theme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            isVideo
              ? 'Allow camera and microphone to join the video call.'
              : 'Allow microphone access to join the audio call.',
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.secondaryText, fontSize: 14),
          ),
          const SizedBox(height: 24),
          if (_denied)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_rounded, color: theme.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Permission denied. Please enable it in your device settings.',
                      style: TextStyle(color: theme.error, fontSize: 13),
                    ),
                  ),
                ],
              ),
            )
          else if (_granted)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: theme.success, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Access granted!',
                    style: TextStyle(color: theme.success, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _granted = true;
                  _denied = false;
                });
                widget.onPermissionGranted?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: theme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                isVideo ? 'Allow Camera & Microphone' : 'Allow Microphone',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                widget.onDecline?.call();
                Navigator.of(context).pop();
              },
              child: const Text('Decline'),
            ),
          ),
        ],
      ),
    );
  }
}
