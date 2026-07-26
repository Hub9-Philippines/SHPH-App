import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.seeAllRoute,
    this.onSeeAll,
    this.padding,
  });

  final String title;
  final String? seeAllRoute;
  final VoidCallback? onSeeAll;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final showSeeAll = seeAllRoute != null || onSeeAll != null;
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTheme.of(context).titleSmall.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    color: const Color(0xFF0F172A),
                  ),
            ),
          ),
          if (showSeeAll)
            GestureDetector(
              onTap: onSeeAll ?? () => Navigator.pushNamed(context, seeAllRoute!),
              child: Text(
                'See all',
                style: AppTheme.of(context).bodySmall.override(
                      font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      color: AppTheme.of(context).primaryBrandText,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
