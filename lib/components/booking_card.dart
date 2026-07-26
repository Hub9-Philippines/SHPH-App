import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/status_pill.dart';
import '/components/user_avatar.dart';
import '/theme/app_theme.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.serviceName,
    required this.status,
    required this.date,
    required this.price,
    this.providerName,
    this.providerPhoto,
    this.onTap,
  });

  final String serviceName;
  final String status;
  final String date;
  final String price;
  final String? providerName;
  final String? providerPhoto;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
          boxShadow: AppThemeData.shadowCard,
        ),
        child: Row(
          children: [
            UserAvatar(
              photoUrl: providerPhoto,
              name: providerName,
              size: 52,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.titleSmall.override(
                      font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      color: theme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: theme.bodySmall.override(color: theme.textTertiary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      StatusPill(label: status, status: status),
                      const Spacer(),
                      Text(
                        price,
                        style: theme.titleSmall.override(
                          font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                          color: theme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
