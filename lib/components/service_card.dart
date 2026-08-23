import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/star_rating.dart';
import '/theme/app_theme.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.title,
    required this.price,
    required this.category,
    this.imageUrl,
    this.rating,
    this.reviewCount,
    this.duration,
    this.onTap,
    this.width,
  });

  final String title;
  final String price;
  final String category;
  final String? imageUrl;
  final double? rating;
  final int? reviewCount;
  final String? duration;
  final VoidCallback? onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return SizedBox(
      width: width ?? 200,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: theme.primaryBackground,
            borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
            boxShadow: AppThemeData.shadowCard,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: theme.bodySmall.override(
                        color: theme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.titleSmall.override(
                        font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                        color: theme.primaryText,
                      ),
                    ),
                    if (duration != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        duration!,
                        style: theme.bodySmall.override(
                          color: theme.textTertiary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    if (rating != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: StarRating(
                          rating: rating!,
                          size: 14,
                          showValue: true,
                          count: reviewCount,
                        ),
                      ),
                    Text(
                      price,
                      style: theme.titleMedium.override(
                        font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                        color: theme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final theme = AppTheme.of(context);
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Container(
      height: 130,
      width: double.infinity,
      decoration: BoxDecoration(
        color: hasImage ? null : theme.primary.withValues(alpha: 0.08),
      ),
      child: hasImage
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildPlaceholder(theme),
            )
          : _buildPlaceholder(theme),
    );
  }

  Widget _buildPlaceholder(AppThemeData theme) {
    return Center(
      child: Icon(Icons.build_rounded, color: theme.primary, size: 40),
    );
  }
}
