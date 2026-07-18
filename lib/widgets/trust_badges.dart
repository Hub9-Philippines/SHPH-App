import 'package:flutter/material.dart';

import '/theme/app_theme.dart';

enum TrustBadgeType { topRated, verified, popular, highlyRated }

class TrustBadge {
  const TrustBadge({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
  });
  final TrustBadgeType type;
  final String label;
  final IconData icon;
  final Color color;
}

class TrustBadgeInput {
  const TrustBadgeInput({
    this.rating = 0,
    this.reviewCount = 0,
    this.providerPhoto,
    this.kycVerified = false,
  });
  final double rating;
  final int reviewCount;
  final String? providerPhoto;
  final bool kycVerified;
}

List<TrustBadge> computeTrustBadges(TrustBadgeInput data, AppThemeData theme) {
  final badges = <TrustBadge>[];
  final rating = data.rating;
  final reviewCount = data.reviewCount;

  if (rating >= 4.8 && reviewCount >= 10) {
    badges.add(const TrustBadge(
      type: TrustBadgeType.topRated,
      label: 'Top Rated',
      icon: Icons.star,
      color: Color(0xFFFFB300),
    ));
  } else if (rating >= 4.5 && reviewCount >= 5) {
    badges.add(const TrustBadge(
      type: TrustBadgeType.highlyRated,
      label: 'Highly Rated',
      icon: Icons.star,
      color: Color(0xFFFFB300),
    ));
  }

  if (reviewCount >= 20) {
    badges.add(TrustBadge(
      type: TrustBadgeType.popular,
      label: 'Popular',
      icon: Icons.local_fire_department,
      color: theme.error,
    ));
  }

  if (data.kycVerified ||
      (data.providerPhoto != null && data.providerPhoto!.isNotEmpty)) {
    badges.add(TrustBadge(
      type: TrustBadgeType.verified,
      label: 'Verified',
      icon: Icons.verified,
      color: theme.success,
    ));
  }

  return badges;
}

Widget trustBadgeRow(List<TrustBadge> badges) {
  if (badges.isEmpty) return const SizedBox.shrink();
  return Wrap(
    spacing: 8,
    runSpacing: 4,
    children: badges
        .map((badge) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badge.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: badge.color.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(badge.icon, size: 14, color: badge.color),
                  const SizedBox(width: 4),
                  Text(
                    badge.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: badge.color,
                    ),
                  ),
                ],
              ),
            ))
        .toList(),
  );
}
