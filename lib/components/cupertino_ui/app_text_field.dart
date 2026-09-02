import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/theme/app_theme.dart';

/// Cupertino-styled text field with Material `TextFormField`-style validation:
/// it is a real [FormField], so `Form.validate()` includes it, and inline
/// error copy renders below the field in the theme's error color.
class AppTextField extends FormField<String> {
  AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onTapOutside,
    this.onEditingComplete,
    this.obscureText = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.maxLengthEnforcement,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.autofocus = false,
    this.enabled = true,
    this.placeholder,
    this.placeholderStyle,
    this.style,
    this.prefixIcon,
    this.suffixIcon,
    this.suffix,
    this.label,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.radius,
    this.fillColor,
this.autofillHints,
    super.validator,
    super.onSaved,
    this.errorText,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    String? initialValue,
  })  : assert(maxLines >= 1),
        super(initialValue: controller?.text ?? initialValue, builder: _defaultBuilder);

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onTap;
  final TapRegionCallback? onTapOutside;
  final VoidCallback? onEditingComplete;
  final bool obscureText;
  final bool readOnly;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final bool autofocus;
  final bool enabled;
  final String? placeholder;
  final TextStyle? placeholderStyle;
  final TextStyle? style;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? suffix;
  final String? label;
  final EdgeInsetsGeometry padding;
  final double? radius;
  final Color? fillColor;
  final Iterable<String>? autofillHints;
  final String? errorText;

  static Widget _defaultBuilder(FormFieldState<String> state) {
    final field = state.widget as AppTextField;
    final context = state.context;
    final data = AppTheme.of(context);
    final error = field.errorText ?? state.errorText;

    final textField = CupertinoTextField(
      controller: field.controller,
      focusNode: field.focusNode,
      onChanged: (value) {
        state.didChange(value);
        field.onChanged?.call(value);
      },
      onSubmitted: field.onSubmitted,
      onTap: field.onTap,
      onTapOutside: field.onTapOutside,
      onEditingComplete: field.onEditingComplete,
      obscureText: field.obscureText,
      readOnly: field.readOnly,
      enabled: field.enabled,
      maxLines: field.maxLines,
      minLines: field.minLines,
      maxLength: field.maxLength,
      maxLengthEnforcement: field.maxLengthEnforcement,
      keyboardType: field.keyboardType,
      textInputAction: field.textInputAction,
      textCapitalization: field.textCapitalization,
      textAlign: field.textAlign,
      autofocus: field.autofocus,
      autofillHints: field.autofillHints,
      placeholder: field.placeholder,
      placeholderStyle: field.placeholderStyle ??
          TextStyle(color: data.secondaryText.withValues(alpha: 0.8)),
      style: field.style ?? data.bodyMedium,
      prefix: field.prefixIcon == null
          ? null
          : Icon(
              field.prefixIcon,
              size: 20,
              color: data.secondaryText,
            ),
      suffix: field.suffix ??
          (field.suffixIcon == null
              ? null
              : Icon(
                  field.suffixIcon,
                  size: 20,
                  color: data.secondaryText,
                )),
      padding: field.padding,
      decoration: BoxDecoration(
        color: field.fillColor ?? data.secondaryBackground,
        borderRadius:
            BorderRadius.circular(field.radius ?? AppThemeData.radiusMd),
        border: Border.all(
          color: error == null ? data.border : data.error,
          width: 1,
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (field.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(field.label!, style: data.labelMedium),
          ),
        textField,
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              error,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: data.error),
            ),
          ),
      ],
    );
  }
}