import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:permission_handler/permission_handler.dart';

import '/components/cupertino_ui/app_button.dart';
import '/l10n/app_localizations.dart';
import '/services/call_signal_models.dart';
import '/services/logging_service.dart';
import '/services/webrtc_call_service.dart';
import '/theme/app_theme.dart';

enum CallType { audio, video }

/// Bottom sheet that gates every call start/accept on media access.
///
/// Flow (web parity with CallPermissionPage + useCallMediaPermission):
/// 1. If the required OS permissions are already granted, media is acquired
///    immediately and [onPermissionGranted] fires — no sheet flash.
/// 2. Otherwise the sheet prompts; after the OS grant it acquires the local
///    stream and fires [onPermissionGranted].
/// 3. The acquired stream is delivered via [onMediaAcquired] so the caller
///    can hand it to `CallSessionController` (engine `preAcquiredStream`) —
///    the call then never starts without media.
/// 4. A video call REQUIRES a video track. If the camera is blocked/busy the
///    acquisition degrades to audio-only; that result is treated as denied
///    with a camera-required message instead of entering a tile-less video
///    call.
class CallAcceptPermissionSheet extends StatefulWidget {
  const CallAcceptPermissionSheet({
    super.key,
    required this.callType,
    this.onPermissionGranted,
    this.onMediaAcquired,
    this.onDecline,
  });

  final CallType callType;

  /// Fired when OS permissions are granted AND media was acquired (or the
  /// acquisition explicitly failed with `mediaAcquired == null` — check the
  /// handed-off stream before starting a call).
  final VoidCallback? onPermissionGranted;

  /// Receives the acquired local stream. Null means acquisition failed (the
  /// sheet shows the error state); the callback fires after
  /// [onPermissionGranted].
  final ValueChanged<webrtc.MediaStream?>? onMediaAcquired;

  final VoidCallback? onDecline;

  static Future<void> show(
    BuildContext context, {
    required CallType callType,
    VoidCallback? onPermissionGranted,
    ValueChanged<webrtc.MediaStream?>? onMediaAcquired,
    VoidCallback? onDecline,
  }) async {
    final required = <Permission>[
      if (callType == CallType.video) Permission.camera,
      Permission.microphone,
    ];
    final statuses = await Future.wait(required.map((p) => p.status));
    if (!context.mounted) {
      return;
    }
    if (statuses.every(_statusGranted)) {
      // Fast path: permissions already granted — acquire media without
      // flashing the sheet (web parity: hasExistingPermission skip).
      final stream = await _acquireMedia(callType);
      if (!context.mounted) {
        stream?.getTracks().forEach((t) => t.stop());
        return;
      }
      onMediaAcquired?.call(stream);
      onPermissionGranted?.call();
      return;
    }

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => CallAcceptPermissionSheet(
        callType: callType,
        onPermissionGranted: onPermissionGranted,
        onMediaAcquired: onMediaAcquired,
        onDecline: onDecline,
      ),
    );
  }

  /// Acquires mic (audio) or mic+camera (video) through the WebRTC plugin.
  /// Returns null on failure. Camera-required validation is the caller's job
  /// (sheet state or fast-path check).
  static Future<webrtc.MediaStream?> _acquireMedia(CallType callType) async {
    try {
      return await ShphWebRTCCallService.instance
          .getLocalMedia(callType == CallType.video
              ? CallMediaType.video
              : CallMediaType.audio);
    } catch (e) {
      LoggingService.warning(
        'Media acquisition failed in permission gate: $e',
        tag: 'CallPermission',
      );
      return null;
    }
  }

  @override
  State<CallAcceptPermissionSheet> createState() =>
      _CallAcceptPermissionSheetState();

  static bool _statusGranted(PermissionStatus status) =>
      status == PermissionStatus.granted || status == PermissionStatus.limited;
}

class _CallAcceptPermissionSheetState extends State<CallAcceptPermissionSheet> {
  bool _granted = false;
  bool _denied = false;
  bool _permanentlyDenied = false;
  bool _isRequesting = false;
  bool _cameraRequired = false;

  /// Stream acquired after the OS grant; handed off via [widget.onMediaAcquired].
  webrtc.MediaStream? _acquiredStream;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  List<Permission> get _requiredPermissions =>
      widget.callType == CallType.video
          ? [Permission.camera, Permission.microphone]
          : [Permission.microphone];

  bool _isGranted(PermissionStatus status) =>
      CallAcceptPermissionSheet._statusGranted(status);

  Future<void> _requestPermissions() async {
    setState(() {
      _isRequesting = true;
      _granted = false;
      _denied = false;
      _permanentlyDenied = false;
      _cameraRequired = false;
    });

    final statuses = <PermissionStatus>[];
    for (final permission in _requiredPermissions) {
      statuses.add(await permission.request());
    }

    if (!mounted) {
      return;
    }

    final granted = statuses.every(_isGranted);
    if (!granted) {
      setState(() {
        _isRequesting = false;
        _denied = true;
        _permanentlyDenied = statuses
            .any((status) => status == PermissionStatus.permanentlyDenied);
      });
      return;
    }

    // OS granted — now acquire the actual media so the call starts with a
    // working stream (web parity: acquireLocalMedia inside the gate).
    final stream = await CallAcceptPermissionSheet._acquireMedia(
      widget.callType,
    );
    if (!mounted) {
      stream?.getTracks().forEach((t) => t.stop());
      return;
    }

    // Video calls need a real video track: getUserMedia can degrade to
    // audio-only when the camera is busy/blocked, and entering a video call
    // with an empty local tile is the exact bug this gate prevents.
    final videoOk = widget.callType != CallType.video ||
        (stream?.getVideoTracks().isNotEmpty ?? false);
    if (stream != null && !videoOk) {
      stream.getTracks().forEach((t) => t.stop());
      setState(() {
        _isRequesting = false;
        _denied = true;
        _cameraRequired = true;
      });
      return;
    }
    if (stream == null) {
      setState(() {
        _isRequesting = false;
        _denied = true;
      });
      return;
    }

    _acquiredStream = stream;
    setState(() {
      _isRequesting = false;
      _granted = true;
    });
    widget.onMediaAcquired?.call(stream);
    widget.onPermissionGranted?.call();
  }

  Future<void> _openAppSettings() async {
    final opened = await openAppSettings();
    if (!mounted) {
      return;
    }
    if (opened) {
      Navigator.of(context).pop();
    }
  }

  void _disposeAcquiredStream() {
    // Sheet closing without a call starting (decline / dismiss): release the
    // mic/camera so the OS indicators turn off promptly.
    _acquiredStream?.getTracks().forEach((t) => t.stop());
    _acquiredStream = null;
  }

  @override
  void dispose() {
    // Only release when the stream was NOT handed off — after a successful
    // handoff the call service owns the tracks.
    _disposeAcquiredStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final isVideo = widget.callType == CallType.video;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && !_granted) {
          _disposeAcquiredStream();
        }
      },
      child: Padding(
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
                        _cameraRequired
                            ? _l10n.callPermCameraNeeded
                            : _l10n.ccPermDenied,
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
            if (_permanentlyDenied) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: _openAppSettings,
                  icon: const Icon(Icons.settings_rounded, size: 18),
                  label: Text(_l10n.ccOpenSettings),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                onPressed: _isRequesting || _granted ? null : _requestPermissions,
                loading: _isRequesting,
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
                onPressed: _isRequesting
                    ? null
                    : () {
                        widget.onDecline?.call();
                        Navigator.of(context).pop();
                      },
                variant: AppButtonVariant.text,
                child: Text(_l10n.ccDecline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
