import 'package:flutter/material.dart';

import '/theme/app_theme.dart';

enum InAppNotificationType { success, error, warning, info }

class InAppNotification {
  final String message;
  final InAppNotificationType type;
  final Duration duration;

  const InAppNotification({
    required this.message,
    this.type = InAppNotificationType.info,
    this.duration = const Duration(seconds: 3),
  });
}

class InAppNotificationOverlay extends StatefulWidget {
  final Widget child;

  const InAppNotificationOverlay({
    required this.child,
    super.key,
  });

  static void show(
    BuildContext context, {
    required String message,
    InAppNotificationType type = InAppNotificationType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _InAppNotificationView(
        message: message,
        type: type,
        duration: duration,
        onDismiss: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  @override
  State<InAppNotificationOverlay> createState() =>
      _InAppNotificationOverlayState();
}

class _InAppNotificationOverlayState extends State<InAppNotificationOverlay> {
  @override
  Widget build(BuildContext context) => widget.child;
}

class _InAppNotificationView extends StatefulWidget {
  final String message;
  final InAppNotificationType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const _InAppNotificationView({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_InAppNotificationView> createState() => _InAppNotificationViewState();
}

class _InAppNotificationViewState extends State<_InAppNotificationView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _bgColor(AppThemeData theme) {
    switch (widget.type) {
      case InAppNotificationType.success:
        return theme.success;
      case InAppNotificationType.error:
        return theme.error;
      case InAppNotificationType.warning:
        return theme.warning;
      case InAppNotificationType.info:
        return theme.primary;
    }
  }

  IconData _icon() {
    switch (widget.type) {
      case InAppNotificationType.success:
        return Icons.check_circle;
      case InAppNotificationType.error:
        return Icons.error;
      case InAppNotificationType.warning:
        return Icons.warning;
      case InAppNotificationType.info:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _bgColor(theme),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(_icon(), color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _controller.reverse().then((_) => widget.onDismiss());
                  },
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
