import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/cupertino_ui/app_button.dart';
import '/components/user_avatar.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';

/// Provider card for the Explore "Top Rated Near You" carousel (section 3).
///
/// Shows avatar, green star-rating badge, provider name, service type,
/// distance in km (omitted when null), starting fee and a blue Book Now CTA.
class ProviderProximityCard extends StatelessWidget {
  const ProviderProximityCard({
    super.key,
    required this.providerName,
    required this.serviceType,
    required this.startingFee,
    this.rating,
    this.distanceKm,
    this.photoUrl,
    this.onBookNow,
    this.onTap,
  });

  final String providerName;
  final String serviceType;
  final String startingFee;

  /// Aggregate rating rendered in the green badge; omitted when null.
  final double? rating;

  /// Distance from the user's location; the metric row is hidden when null
  /// so no blank/placeholder distance is ever shown.
  final double? distanceKm;
  final String? photoUrl;
  final VoidCallback? onBookNow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final _l10n = AppLocalizations.of(context)!;
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: AppThemeData.spaceMd),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.border, width: 0.5),
        boxShadow: AppThemeData.shadowSoft,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  UserAvatar(photoUrl: photoUrl, name: providerName, size: 44),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      providerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.titleSmall.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (rating != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppThemeData.ratingBadgeGreenBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded,
                          size: 14, color: AppThemeData.ratingBadgeGreen),
                      const SizedBox(width: 2),
                      Text(
                        rating!.toStringAsFixed(1),
                        style: theme.labelSmall.override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                          ),
                          color: AppThemeData.ratingBadgeGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                serviceType,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.bodySmall.override(
                  font: GoogleFonts.plusJakartaSans(),
                  color: theme.secondaryText,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  if (distanceKm != null) ...[
                    Icon(Icons.near_me_rounded,
                        size: 13, color: theme.secondaryText),
                    const SizedBox(width: 3),
                    Text(
                      _l10n.ccKmAway(distanceKm!.toStringAsFixed(1)),
                      style: theme.bodySmall.override(
                        font: GoogleFonts.plusJakartaSans(),
                        color: theme.secondaryText,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      _l10n.ccStarting(startingFee),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.titleSmall.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                        ),
                        // 1px below titleSmall so the full price string
                        // clears the distance label inside the 240px card.
                        fontSize: 15,
                        color: theme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 34,
                child: AppButton(
                  onPressed: onBookNow,
                  backgroundColor: theme.primary,
                  foregroundColor: theme.onPrimary,
                  padding: EdgeInsets.zero,
                  borderRadius: 10,
                  width: double.infinity,
                  child: Text(
                    _l10n.ccBookNow,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
