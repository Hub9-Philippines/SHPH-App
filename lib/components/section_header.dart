import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.seeAllRoute,
    this.onSeeAll,
    this.padding,
    this.seeAllLabel,
  });

  final String title;
  final String? seeAllRoute;
  final VoidCallback? onSeeAll;
  final EdgeInsetsGeometry? padding;

  /// Link text for the trailing action (e.g. 'View All').
  final String? seeAllLabel;

  @override
  Widget build(BuildContext context) {
    final _l10n = AppLocalizations.of(context)!;
    final effectiveSeeAllLabel = seeAllLabel ?? _l10n.ccSeeAll;
    final showSeeAll = seeAllRoute != null || onSeeAll != null;
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTheme.of(context).titleSmall.override(
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                    color: const Color(0xFF0F172A),
                  ),
            ),
          ),
          if (showSeeAll)
            GestureDetector(
              onTap: onSeeAll ?? () => Navigator.pushNamed(context, seeAllRoute!),
              child: Text(
                effectiveSeeAllLabel,
                style: AppTheme.of(context).bodySmall.override(
                      font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                      color: AppTheme.of(context).primaryBrandText,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
