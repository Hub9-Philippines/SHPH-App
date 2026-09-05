import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/theme/app_theme.dart';

/// Shared search input used by the Bookings and Messages tabs so both look
/// identical. Mirrors the filled, rounded field style that Bookings renders,
/// including the auto-hiding clear button.
class SearchBarField extends StatelessWidget {
  const SearchBarField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          onChanged: (value) => onChanged?.call(value),
          onSubmitted: onSubmitted,
          style: theme.bodyMedium.override(
            font: GoogleFonts.plusJakartaSans(),
            color: theme.primaryText,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText,
            hintStyle: theme.bodyMedium.override(
              font: GoogleFonts.plusJakartaSans(),
              color: theme.textTertiary,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: theme.secondaryText,
              size: 22,
            ),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: theme.secondaryText,
                    ),
                    onPressed: () {
                      controller.clear();
                      onChanged?.call('');
                    },
                  ),
            filled: true,
            fillColor: theme.primaryBackground,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
              borderSide: BorderSide(color: theme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
              borderSide: const BorderSide(color: AppThemeData.actionPrimary),
            ),
          ),
        );
      },
    );
  }
}