import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';

/// Wide promotional banner for the Explore feed (section 2).
///
/// Vibrant blue gradient card with offer copy and a dark-blue "Book Now" CTA.
class HeroOfferBanner extends StatelessWidget {
  const HeroOfferBanner({
    super.key,
    this.title,
    this.highlight,
    this.imageAsset,
    this.onBookNow,
  });

  final String? title;
  final String? highlight;

  /// Optional technician/marketing artwork; omitted renders the icon badge.
  final String? imageAsset;
  final VoidCallback? onBookNow;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final _l10n = AppLocalizations.of(context)!;
    final effectiveTitle = title ?? _l10n.ccSeasonalDeals;
    final effectiveHighlight = highlight ?? _l10n.cc60Off;
    return Container(
      // Grid: no horizontal margin owned here — the feed supplies the 16px
      // grid and the 24px block separator around this banner.
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppThemeData.promoGradient,
        ),
        borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppThemeData.promoGradient.first.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppThemeData.spaceLg),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    effectiveTitle,
                    style: theme.headlineSmall.override(
                      font: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                      ),
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: AppThemeData.spaceXs),
                  Text(
                    effectiveHighlight,
                    style: theme.titleMedium.override(
                      font: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                      ),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppThemeData.spaceLg),
                  Material(
                    color: AppThemeData.promoCta,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: onBookNow,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 10,
                        ),
                        child: Text(
                          _l10n.ccBookNow,
                          style: theme.titleSmall.override(
                            font: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                            ),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (imageAsset != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  imageAsset!,
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.home_repair_service_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
