import 'package:flutter/material.dart';

import '/components/cupertino_ui/app_button.dart';
import '/l10n/app_localizations.dart';
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

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

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
            isVideo ? _l10n.ccCamMicAccess : _l10n.ccMicAccess,
            style: theme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            isVideo
              ? _l10n.ccCamMicDesc
              : _l10n.ccMicDesc,
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
                      _l10n.ccPermDenied,
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
                    _l10n.ccAccessGranted,
                    style: TextStyle(color: theme.success, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              onPressed: () {
                setState(() {
                  _granted = true;
                  _denied = false;
                });
                widget.onPermissionGranted?.call();
              },
              backgroundColor: theme.primary,
              foregroundColor: theme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              borderRadius: 14,
              child: Text(
                isVideo ? _l10n.ccAllowCamMic : _l10n.ccAllowMic,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              onPressed: () {
                widget.onDecline?.call();
                Navigator.of(context).pop();
              },
              variant: AppButtonVariant.text,
              child: Text(_l10n.ccDecline),
            ),
          ),
        ],
      ),
    );
  }
}
