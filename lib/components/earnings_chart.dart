import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/theme/app_theme.dart';

class EarningsChart extends StatelessWidget {
  const EarningsChart({
    super.key,
    required this.data,
    required this.labels,
    this.height = 180,
  });

  final List<double> data;
  final List<String> labels;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    if (data.isEmpty) return const SizedBox.shrink();

    final maxVal = data.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(data.length, (i) {
          final fraction = maxVal > 0 ? data[i] / maxVal : 0.0;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '₱${data[i].toInt()}',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: theme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: 0.15 + fraction * 0.45),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: (fraction * (height - 50)).clamp(4, height - 50),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: theme.primary,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    labels.length > i ? labels[i] : '',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: theme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
