import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '/theme/app_theme.dart';

/// Visual variants for [AppButton], mirroring the common iOS button styles.
enum AppButtonVariant {
  /// Filled with the brand primary color (royal blue), white label.
  primary,

  /// Tinted primary (subtle blue fill, brand-colored label) — iOS "tinted".
  secondary,

  /// Filled with the destructive red.
  destructive,

  /// Transparent fill with a hairline border — iOS outline buttons.
  outlined,

  /// Plain text button (no fill, no border).
  text,
}

/// Cupertino-styled action button that preserves the API shape used across
/// the app's pages and shared components (label, onPressed, disabled when
/// null, optional icon, loading spinner) while rendering as an iOS button.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.child,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.backgroundColor,
    this.foregroundColor,
    this.borderSide,
    this.borderRadius,
    this.padding,
    this.height,
    this.width,
    this.minWidth,
    this.loading = false,
    this.loadingColor,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderSide? borderSide;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? width;
  final double? minWidth;
  final bool loading;
  final Color? loadingColor;
  final String? semanticLabel;

  (Color, Color) _resolveColors(BuildContext context, AppThemeData data) {
    final brightness = Theme.of(context).brightness;
    final bg = backgroundColor ??
        switch (variant) {
          AppButtonVariant.primary => data.primary,
          AppButtonVariant.secondary => data.primary.withValues(alpha: 0.12),
          AppButtonVariant.destructive => data.error,
          AppButtonVariant.outlined || AppButtonVariant.text => Colors.transparent,
        };
    final fg = foregroundColor ??
        switch (variant) {
          AppButtonVariant.primary || AppButtonVariant.destructive =>
            Colors.white,
          AppButtonVariant.secondary => brightness == Brightness.light
              ? data.primary
              : data.primaryBrandText,
          AppButtonVariant.outlined || AppButtonVariant.text => data.primaryText,
        };
    return (bg, fg);
  }

  @override
  Widget build(BuildContext context) {
    final data = AppTheme.of(context);
    final (bg, fg) = _resolveColors(context, data);
    final radiusVal = borderRadius ?? AppThemeData.radiusMd;
    final radius = BorderRadius.circular(radiusVal);
    final disabled = onPressed == null || loading;
    final bgColor = disabled ? bg.withValues(alpha: 0.4) : bg;
    final fgColor = disabled ? fg.withValues(alpha: 0.45) : fg;
    final effectiveBorder = variant == AppButtonVariant.outlined
        ? Border.fromBorderSide(
            borderSide ?? BorderSide(color: data.border, width: 1.25),
          )
        : null;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                loadingColor ?? fgColor,
              ),
            ),
          )
        else
          DefaultTextStyle(
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            child: child,
          ),
      ],
    );

    Widget button = Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: radius,
        border: effectiveBorder,
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: minWidth != null
            ? BoxConstraints(minWidth: minWidth!)
            : const BoxConstraints(),
        child: CupertinoButton(
          onPressed: disabled
              ? null
              : () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  onPressed!();
                },
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          disabledColor: bgColor,
          child: Align(
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );

    if (height != null || width != null) {
      button = SizedBox(height: height, width: width, child: button);
    }

    return Semantics(
      button: true,
      label: semanticLabel,
      enabled: !disabled,
      child: button,
    );
  }
}