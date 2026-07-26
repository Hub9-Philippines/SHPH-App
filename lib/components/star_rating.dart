import 'package:flutter/material.dart';

import '/theme/app_theme.dart';

class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.rating,
    this.size = 16,
    this.showValue = false,
    this.count,
  });

  final double rating;
  final double size;
  final bool showValue;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final stars = List.generate(5, (i) {
      final fill = (rating - i).clamp(0.0, 1.0);
      if (fill >= 0.75) {
        return Icons.star;
      } else if (fill >= 0.25) {
        return Icons.star_half;
      }
      return Icons.star_border;
    });

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...stars.map((icon) => Padding(
              padding: const EdgeInsets.only(right: 1),
              child: Icon(icon, size: size, color: theme.warning),
            )),
        if (showValue)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              rating.toStringAsFixed(1),
              style: theme.bodySmall.override(
                color: theme.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (count != null)
          Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Text(
              '($count)',
              style: theme.bodySmall.override(color: theme.textTertiary),
            ),
          ),
      ],
    );
  }
}
