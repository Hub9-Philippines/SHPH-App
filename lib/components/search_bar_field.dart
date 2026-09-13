import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/theme/app_theme.dart';

/// Shared search input used by the Bookings, Messages, Search and Services
/// surfaces so all of them look identical. A filled 52px pill with a subtle
/// border that brightens into a primary focus ring, plus auto-hiding circular
/// clear and optional voice-search buttons.
class SearchBarField extends StatelessWidget {
  const SearchBarField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.onMicTap,
    this.micActive = false,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;

  /// When provided, shows a trailing mic button for voice search.
  final VoidCallback? onMicTap;

  /// Highlights the mic (and pulses) while a listening session is active.
  final bool micActive;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          textInputAction: TextInputAction.search,
          onChanged: (value) => onChanged?.call(value),
          onSubmitted: onSubmitted,
          style: theme.bodyMedium.override(
            font: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w500,
            ),
            color: theme.primaryText,
          ),
          cursorColor: theme.primary,
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
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.text.isNotEmpty)
                  InkWell(
                    onTap: () {
                      controller.clear();
                      onChanged?.call('');
                    },
                    borderRadius: BorderRadius.circular(999),
                    child: Icon(
                      Icons.cancel_rounded,
                      size: 20,
                      color: theme.textTertiary,
                    ),
                  ),
                if (onMicTap != null) ...[
                  if (controller.text.isNotEmpty)
                    const SizedBox(width: 4),
                  InkWell(
                    onTap: onMicTap,
                    borderRadius: BorderRadius.circular(999),
                    child: micActive
                        ? Container(
                            width: 28,
                            height: 28,
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: theme.primary.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.graphic_eq_rounded,
                              size: 18,
                              color: theme.primary,
                            ),
                          )
                        : Icon(
                            Icons.mic_none_rounded,
                            size: 20,
                            color: theme.secondaryText,
                          ),
                  ),
                  // Keep the mic from sitting flush against the pill edge
                  // when the clear button is shown next to it.
                  const SizedBox(width: 8),
                ],
              ],
            ),
            filled: true,
            fillColor: theme.primaryBackground,
            constraints: const BoxConstraints(minHeight: 52),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppThemeData.radiusPill),
              borderSide: BorderSide(color: theme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppThemeData.radiusPill),
              borderSide: BorderSide(
                color: theme.primary,
                width: 1.6,
              ),
            ),
          ),
        );
      },
    );
  }
}
