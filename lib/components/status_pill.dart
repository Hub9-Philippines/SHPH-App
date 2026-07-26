import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/theme/app_theme.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.status,
    this.customTextColor,
    this.customBgColor,
    this.fontSize = 11,
  });

  final String label;
  final String? status;
  final Color? customTextColor;
  final Color? customBgColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final (textColor, bgColor) = status != null
        ? AppThemeData.statusColors(status!)
        : (customTextColor ?? AppTheme.of(context).primaryBrandText,
            customBgColor ?? AppTheme.of(context).primaryLight);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppThemeData.radiusPill),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: fontSize,
          color: textColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
