import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/theme/app_theme.dart';

class ProviderStatusToggle extends StatelessWidget {
  const ProviderStatusToggle({
    super.key,
    required this.isOnline,
    this.onToggle,
    this.compact = false,
  });

  final bool isOnline;
  final void Function(bool online)? onToggle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    if (compact) {
      return GestureDetector(
        onTap: () => onToggle?.call(!isOnline),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isOnline ? theme.success.withValues(alpha: 0.12) : theme.surfaceAlt,
            borderRadius: BorderRadius.circular(AppThemeData.radiusPill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isOnline ? theme.success : theme.textTertiary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isOnline ? 'Online' : 'Offline',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isOnline ? theme.success : theme.textTertiary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
        boxShadow: AppThemeData.shadowCard,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isOnline
                  ? theme.success.withValues(alpha: 0.12)
                  : theme.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
              color: isOnline ? theme.success : theme.textTertiary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline ? 'You\'re Online' : 'You\'re Offline',
                  style: theme.titleSmall.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    color: theme.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isOnline
                      ? 'Ready to receive service requests'
                      : 'New requests won\'t reach you',
                  style: theme.bodySmall.override(color: theme.textTertiary),
                ),
              ],
            ),
          ),
          Switch(
            value: isOnline,
            activeColor: theme.success,
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }
}
