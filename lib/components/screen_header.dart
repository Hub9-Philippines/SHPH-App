import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/theme/app_theme.dart';

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    /// Tab-screen grid default: 16px side margins, no bottom padding — the
    /// element following the header owns its own 16px top gap.
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 0),
  });

  final String title;
  final String? subtitle;
  final Widget? action;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.of(context).headlineSmall.override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                          ),
                          color: const Color(0xFF0F172A),
                        ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        subtitle!,
                        style: AppTheme.of(context).bodySmall.override(
                              font: GoogleFonts.plusJakartaSans(),
                              color: const Color(0xFF64748B),
                            ),
                      ),
                    ),
                ],
              ),
            ),
            if (action != null)
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppThemeData.shadowCard,
                ),
                child: action,
              ),
          ],
        ),
      );
}
