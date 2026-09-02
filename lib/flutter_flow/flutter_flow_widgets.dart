import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '/theme/app_theme.dart';

class FFButtonOptions {
  const FFButtonOptions({
    this.textAlign,
    this.textStyle,
    this.elevation,
    this.height,
    this.width,
    this.padding,
    this.color,
    this.disabledColor,
    this.disabledTextColor,
    this.splashColor,
    this.iconSize,
    this.iconColor,
    this.iconAlignment,
    this.iconPadding,
    this.borderRadius,
    this.borderSide,
    this.hoverColor,
    this.hoverBorderSide,
    this.hoverTextColor,
    this.hoverElevation,
    this.maxLines,
  });

  final TextAlign? textAlign;
  final TextStyle? textStyle;
  final double? elevation;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? disabledColor;
  final Color? disabledTextColor;
  final int? maxLines;
  final Color? splashColor;
  final double? iconSize;
  final Color? iconColor;
  final IconAlignment? iconAlignment;
  final EdgeInsetsGeometry? iconPadding;
  final BorderRadius? borderRadius;
  final BorderSide? borderSide;
  final Color? hoverColor;
  final BorderSide? hoverBorderSide;
  final Color? hoverTextColor;
  final double? hoverElevation;
}

class FFButtonWidget extends StatefulWidget {
  const FFButtonWidget({
    required this.text, required this.onPressed, required this.options, super.key,
    this.icon,
    this.iconData,
    this.showLoadingIndicator = true,
    this.focusNode,
  });

  final String text;
  final Widget? icon;
  final IconData? iconData;
  final Function()? onPressed;
  final FFButtonOptions options;
  final bool showLoadingIndicator;
  final FocusNode? focusNode;

  @override
  State<FFButtonWidget> createState() => _FFButtonWidgetState();
}

class _FFButtonWidgetState extends State<FFButtonWidget> {
  bool loading = false;
  late FocusNode _internalFocusNode;

  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode;

  int get maxLines => widget.options.maxLines ?? 1;
  String? get text =>
      widget.options.textStyle?.fontSize == 0 ? null : widget.text;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _internalFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = AppTheme.of(context);
    final textWidget = loading
        ? SizedBox(
            width: widget.options.width == null
                ? _getTextWidth(text, widget.options.textStyle, maxLines)
                : null,
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.options.textStyle?.color ?? Colors.white,
                  ),
                ),
              ),
            ),
          )
        : AutoSizeText(
            text ?? '',
            style:
                text == null ? null : widget.options.textStyle?.withoutColor(),
            textAlign: widget.options.textAlign,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          );

    final onPressed = widget.onPressed != null
        ? (widget.showLoadingIndicator
            ? () async {
                if (loading) {
                  return;
                }
                setState(() => loading = true);
                try {
                  await widget.onPressed!();
                } finally {
                  if (mounted) {
                    setState(() => loading = false);
                  }
                }
              }
            : widget.onPressed)
        : null;

    final bg = widget.options.color ?? data.primary;
    final fg = widget.options.textStyle?.color ??
        (widget.options.color != null ? Colors.white : data.onPrimary);
    final radius = widget.options.borderRadius ?? BorderRadius.circular(12);
    final iconFill = widget.options.iconColor ??
        widget.options.textStyle?.color ??
        fg;
    final hasIcon =
        !loading && (widget.icon != null || widget.iconData != null);
    final isIconOnly = hasIcon && text == null;

    Widget content;
    if (isIconOnly) {
      final icon = widget.icon ??
          Icon(
            widget.iconData!,
            size: widget.options.iconSize,
            color: iconFill,
          );
      content = Padding(
        padding: widget.options.iconPadding ?? EdgeInsets.zero,
        child: icon,
      );
    } else if (hasIcon) {
      final icon = widget.icon ??
          Icon(
            widget.iconData!,
            size: widget.options.iconSize,
            color: iconFill,
          );
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: widget.options.iconAlignment == IconAlignment.end
            ? [
                Flexible(child: textWidget),
                const SizedBox(width: 8),
                icon,
              ]
            : [
                icon,
                const SizedBox(width: 8),
                Flexible(child: textWidget),
              ],
      );
    } else {
      content = textWidget;
    }

    final disabled = onPressed == null;
    final disabledBg =
        widget.options.disabledColor ?? bg.withValues(alpha: 0.4);
    final baseFg = widget.options.textStyle?.color ?? fg;
    final disabledFg =
        widget.options.disabledTextColor ?? baseFg.withValues(alpha: 0.45);

    Widget button = Container(
      decoration: BoxDecoration(
        color: disabled ? disabledBg : bg,
        borderRadius: radius,
        border: widget.options.borderSide == null
            ? null
            : Border.fromBorderSide(widget.options.borderSide!),
      ),
      clipBehavior: Clip.antiAlias,
      child: CupertinoButton(
        onPressed: onPressed,
        padding: widget.options.padding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        disabledColor: disabledBg,
        child: DefaultTextStyle(
          style: TextStyle(
            color: disabled ? disabledFg : fg,
            fontSize: widget.options.textStyle?.fontSize,
          ),
          child: content,
        ),
      ),
    );

    if (widget.options.width != null || widget.options.height != null) {
      button = SizedBox(
        width: widget.options.width,
        height: widget.options.height,
        child: button,
      );
    }
    return button;
  }
}

extension _WithoutColorExtension on TextStyle {
  TextStyle withoutColor() => TextStyle(
        inherit: inherit,
        color: null,
        backgroundColor: backgroundColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        textBaseline: textBaseline,
        height: height,
        leadingDistribution: leadingDistribution,
        locale: locale,
        foreground: foreground,
        background: background,
        shadows: shadows,
        fontFeatures: fontFeatures,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        decorationThickness: decorationThickness,
        debugLabel: debugLabel,
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
        // The _package field is private so unfortunately we can't set it here,
        // but it's almost always unset anyway.
        // package: _package,
        overflow: overflow,
      );
}

// Slightly hacky method of getting the layout width of the provided text.
double? _getTextWidth(String? text, TextStyle? style, int maxLines) =>
    text != null
        ? (TextPainter(
            text: TextSpan(text: text, style: style),
            textDirection: TextDirection.ltr,
            maxLines: maxLines,
          )..layout())
            .size
            .width
        : null;

class FFFocusIndicator extends StatefulWidget {

  const FFFocusIndicator({
    super.key,
    this.builder,
    this.child,
    this.border,
    this.borderRadius,
    this.padding,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
  }) : assert(
          builder != null || child != null,
          'Either builder or child must be provided',
        );
  final Widget Function(FocusNode focusNode)? builder;
  final Widget? child;
  final Border? border;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final void Function()? onTap;
  final void Function()? onLongPress;
  final void Function()? onDoubleTap;

  @override
  State<FFFocusIndicator> createState() => _FFFocusIndicatorState();
}

class _FFFocusIndicatorState extends State<FFFocusIndicator> {
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasInteractions = widget.onTap != null ||
        widget.onLongPress != null ||
        widget.onDoubleTap != null;

    Widget childWidget;
    if (widget.builder != null) {
      // Builder mode: pass focus node to builder
      childWidget = widget.builder!(_focusNode);
    } else if (hasInteractions) {
      // Child mode with interactions: wrap in InkWell
      childWidget = InkWell(
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        focusNode: _focusNode,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onDoubleTap: widget.onDoubleTap,
        child: widget.child!,
      );
    } else {
      // Child mode without interactions: just use child
      childWidget = widget.child!;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: widget.padding,
      decoration: BoxDecoration(
        border: _hasFocus ? widget.border : null,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
      ),
      child: childWidget,
    );
  }
}