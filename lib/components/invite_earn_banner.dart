import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';

/// Full-width purple referral banner closing the Explore feed (section 5).
class InviteEarnBanner extends StatelessWidget {
  const InviteEarnBanner({
    super.key,
    this.title,
    this.subtitle,
    this.shareLabel,
    this.onShare,
  });

  final String? title;
  final String? subtitle;
  final String? shareLabel;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final _l10n = AppLocalizations.of(context)!;
    final effectiveTitle = title ?? _l10n.ccInviteEarn;
    final effectiveSubtitle = subtitle ?? _l10n.ccInviteSubtitle;
    final effectiveShareLabel = shareLabel ?? _l10n.ccShareLink;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppThemeData.spaceLg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
            Color(0xFF1E3A8A),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220F172A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          Positioned(
            top: -24,
            right: -24,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF38BDF8).withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -15,
            right: 12,
            child: Icon(
              Icons.card_giftcard_rounded,
              size: 80,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(AppThemeData.radiusPill),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.stars_rounded,
                        size: 13,
                        color: Color(0xFFFCD34D),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'REFERRAL PROGRAM',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.9,
                          color: const Color(0xFFFCD34D),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  effectiveTitle,
                  style: theme.titleMedium.override(
                    font: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  effectiveSubtitle,
                  style: theme.bodySmall.override(
                    font: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                    color: const Color(0xFFCBD5E1),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 38,
                  child: ElevatedButton.icon(
                    onPressed: onShare,
                    icon: const Icon(
                      Icons.share_rounded,
                      size: 15,
                      color: Color(0xFF0F172A),
                    ),
                    label: Text(effectiveShareLabel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0F172A),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppThemeData.radiusSm),
                      ),
                      textStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
