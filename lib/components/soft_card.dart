import 'package:flutter/material.dart';

import '/theme/app_theme.dart';

class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? theme.surfaceAlt,
        borderRadius: BorderRadius.circular(borderRadius ?? AppThemeData.radiusLg),
      ),
      child: child,
    );
  }
}
