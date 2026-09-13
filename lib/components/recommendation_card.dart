import 'package:flutter/material.dart';

import '/components/star_rating.dart';
import '/components/trust_badge.dart';
import '/components/user_avatar.dart';
import '/theme/app_theme.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.serviceName,
    required this.providerName,
    required this.price,
    this.providerPhoto,
    this.rating,
    this.reviewCount,
    this.category,
    this.trustBadges,
    this.onTap,
  });

  final String serviceName;
  final String providerName;
  final String price;
  final String? providerPhoto;
  final double? rating;
  final int? reviewCount;
  final String? category;
  final List<String>? trustBadges;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.secondaryBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.border, width: 0.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(
                photoUrl: providerPhoto,
                name: providerName,
                size: 48,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (category != null)
                      Text(category!,
                          style: theme.bodySmall.copyWith(
                              color: theme.primary,
                              fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(serviceName,
                        style: theme.titleSmall
                            .copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(providerName,
                        style: theme.bodySmall
                            .copyWith(color: theme.secondaryText)),
                    if (rating != null) ...[
                      const SizedBox(height: 4),
                      StarRating(
                        rating: rating!,
                        size: 12,
                        showValue: true,
                        count: reviewCount,
                      ),
                    ],
                    if (trustBadges != null && trustBadges!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: trustBadges!
                            .map((b) => TrustBadge(label: b))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                children: [
                  Text(price,
                      style: theme.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.primary,
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
