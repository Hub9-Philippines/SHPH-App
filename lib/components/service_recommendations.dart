import 'package:flutter/material.dart';

import '/components/recommendation_card.dart';

class ServiceRecommendations extends StatelessWidget {
  const ServiceRecommendations({
    super.key,
    required this.title,
    required this.items,
    this.onItemTap,
  });

  final String title;
  final List<RecommendationItem> items;
  final void Function(int index)? onItemTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 8),
        ...items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return RecommendationCard(
            serviceName: item.serviceName,
            providerName: item.providerName,
            price: item.price,
            providerPhoto: item.providerPhoto,
            rating: item.rating,
            reviewCount: item.reviewCount,
            category: item.category,
            trustBadges: item.trustBadges,
            onTap: onItemTap != null ? () => onItemTap!(i) : null,
          );
        }),
      ],
    );
  }
}

class RecommendationItem {
  const RecommendationItem({
    required this.serviceName,
    required this.providerName,
    required this.price,
    this.providerPhoto,
    this.rating,
    this.reviewCount,
    this.category,
    this.trustBadges,
  });

  final String serviceName;
  final String providerName;
  final String price;
  final String? providerPhoto;
  final double? rating;
  final int? reviewCount;
  final String? category;
  final List<String>? trustBadges;
}
