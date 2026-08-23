import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/theme/app_theme.dart';

/// Full-width purple referral banner closing the Explore feed (section 5).
class InviteEarnBanner extends StatelessWidget {
  const InviteEarnBanner({
    super.key,
    this.title = 'Invite & Earn',
    this.subtitle = 'Refer a friend and get a PHP 100 cash bonus '
        'when they complete their first booking.',
    this.shareLabel = 'Share Link',
    this.onShare,
  });

  final String title;
  final String subtitle;
  final String shareLabel;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      // Grid: horizontal inset owned here (16px); vertical rhythm supplied
      // by the host feed's block separators.
      margin: const EdgeInsets.symmetric(horizontal: AppThemeData.spaceLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppThemeData.referralGradient,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.card_giftcard_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.titleMedium.override(
                      font: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                      ),
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: theme.bodySmall.override(
                font: GoogleFonts.plusJakartaSans(),
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 38,
              child: OutlinedButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.ios_share_rounded, size: 16),
                label: Text(shareLabel),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.7)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
