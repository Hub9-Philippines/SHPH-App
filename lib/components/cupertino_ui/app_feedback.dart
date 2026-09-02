import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';

/// Severity for [AppFeedback.showBanner].
enum AppBannerSeverity { info, success, error, warning }

/// iOS-styled transient feedback helpers replacing SnackBar/AlertDialog usage:
/// - [showBanner] shows a floating capsule that auto-dismisses (~2.5s).
/// - [confirmDialog] shows a Cupertino alert with Cancel/Confirm actions.
/// - [showAlert] shows a Cupertino alert with a single OK action.
class AppFeedback {
  AppFeedback._();

  static OverlayEntry? _currentBanner;
  static Timer? _bannerTimer;

  static Future<T?> showAlert<T>({
    required BuildContext context,
    required String title,
    String? message,
    String? okText,
    bool barrierDismissible = true,
  }) {
    final _l10n = AppLocalizations.of(context)!;
    return showCupertinoDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(title),
        content: message == null ? null : Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(null),
            child: Text(okText ?? _l10n.ccOK),
          ),
        ],
      ),
    );
  }

  /// Confirmation dialog. Returns `true` when the confirm action is tapped,
  /// `false` when cancelled/dismissed.
  static Future<bool?> confirmDialog({
    required BuildContext context,
    required String title,
    String? message,
    String? confirmText,
    String? cancelText,
    bool destructive = false,
    bool barrierDismissible = false,
  }) {
    final _l10n = AppLocalizations.of(context)!;
    return showCupertinoDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(title),
        content: message == null ? null : Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            isDefaultAction: false,
            child: Text(cancelText ?? _l10n.ccCancel),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            isDefaultAction: true,
            isDestructiveAction: destructive,
            child: Text(confirmText ?? _l10n.ccConfirm),
          ),
        ],
      ),
    );
  }

  /// Transient iOS-style banner overlay, auto-dismissed after [duration].
  /// Replaces any currently-visible banner in place.
  static void showBanner(
    BuildContext context,
    String message, {
    AppBannerSeverity severity = AppBannerSeverity.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);

    void dismiss() {
      _bannerTimer?.cancel();
      _bannerTimer = null;
      final entry = _currentBanner;
      _currentBanner = null;
      entry?.remove();
    }

    _bannerTimer?.cancel();
    final entry = OverlayEntry(
      builder: (overlayContext) => _AppBanner(
        message: message,
        severity: severity,
        actionLabel: actionLabel,
        onAction: onAction,
        onDismiss: dismiss,
      ),
    );
    _currentBanner?.remove();
    _currentBanner = entry;
    overlay.insert(entry);
    _bannerTimer = Timer(duration, dismiss);
  }
}

class _AppBanner extends StatefulWidget {
  const _AppBanner({
    required this.message,
    required this.severity,
    required this.onDismiss,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final AppBannerSeverity severity;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismiss;

  @override
  State<_AppBanner> createState() => _AppBannerState();
}

class _AppBannerState extends State<_AppBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
  );
  late final Animation<double> _slide = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().whenCompleteOrCancel(widget.onDismiss);
  }

  @override
  Widget build(BuildContext context) {
    final data = AppTheme.of(context);
    final (Color bg, Color fg) = switch (widget.severity) {
      AppBannerSeverity.info => (data.primaryDark, Colors.white),
      AppBannerSeverity.success => (const Color(0xFF16A34A), Colors.white),
      AppBannerSeverity.error => (data.error, Colors.white),
      AppBannerSeverity.warning => (const Color(0xFFF59E0B), Colors.black),
    };

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          )),
          child: Opacity(
            opacity: _slide.value,
            child: Center(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(AppThemeData.radiusPill),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        widget.message,
                        style: TextStyle(color: fg, fontSize: 14),
                      ),
                    ),
                    if (widget.actionLabel != null) ...[
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          widget.onAction?.call();
                          _dismiss();
                        },
                        child: Text(
                          widget.actionLabel!,
                          style: TextStyle(
                            color: fg,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}