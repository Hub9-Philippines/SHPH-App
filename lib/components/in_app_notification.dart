import 'dart:async';

import 'package:flutter/material.dart';

import '/theme/app_theme.dart';

enum InAppNotificationType { info, success, warning, error }

class InAppNotification extends StatefulWidget {
  const InAppNotification({
    super.key,
    required this.title,
    required this.body,
    this.type = InAppNotificationType.info,
    this.duration = const Duration(seconds: 5),
    this.onTap,
    this.onDismiss,
  });

  final String title;
  final String body;
  final InAppNotificationType type;
  final Duration duration;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  static void show(
    BuildContext context, {
    required String title,
    required String body,
    InAppNotificationType type = InAppNotificationType.info,
    Duration duration = const Duration(seconds: 5),
    VoidCallback? onTap,
  }) {
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _InAppNotificationOverlay(
        title: title,
        body: body,
        type: type,
        duration: duration,
        onTap: () {
          onTap?.call();
          entry.remove();
        },
        onDismiss: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
    Future.delayed(duration + const Duration(milliseconds: 300), () {
      if (entry.mounted) entry.remove();
    });
  }

  @override
  State<InAppNotification> createState() => _InAppNotificationState();
}

class _InAppNotificationState extends State<InAppNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _progressAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
    _controller.forward();
    Future.delayed(widget.duration, () {
      if (mounted) _controller.reverse().then((_) => widget.onDismiss?.call());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final (Color bg, Color fg, IconData icon) = switch (widget.type) {
      InAppNotificationType.info => (theme.primary, Colors.white, Icons.info_rounded),
      InAppNotificationType.success => (theme.success, Colors.white, Icons.check_circle_rounded),
      InAppNotificationType.warning => (theme.warning, const Color(0xFF0F172A), Icons.warning_rounded),
      InAppNotificationType.error => (theme.error, Colors.white, Icons.error_rounded),
    };

    return SlideTransition(
      position: _slideAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppThemeData.shadowLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: fg, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            color: fg,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.body,
                          style: TextStyle(color: fg.withValues(alpha: 0.9), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onDismiss,
                    child: Icon(Icons.close_rounded, color: fg.withValues(alpha: 0.7), size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (_, __) => LinearProgressIndicator(
                    value: _progressAnimation.value,
                    backgroundColor: fg.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(fg.withValues(alpha: 0.5)),
                    minHeight: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InAppNotificationOverlay extends StatelessWidget {
  const _InAppNotificationOverlay({
    required this.title,
    required this.body,
    required this.type,
    required this.duration,
    this.onTap,
    this.onDismiss,
  });

  final String title;
  final String body;
  final InAppNotificationType type;
  final Duration duration;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: InAppNotification(
          title: title,
          body: body,
          type: type,
          duration: duration,
          onTap: onTap,
          onDismiss: onDismiss,
        ),
      ),
    );
  }
}
