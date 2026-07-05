import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/theme/app_theme.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({
    required this.bookingStatus,
    required this.bookingDate,
    required this.providerName,
    required this.serviceTitle,
    super.key,
  });

  final String bookingStatus;
  final DateTime bookingDate;
  final String providerName;
  final String serviceTitle;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        foregroundColor: theme.primaryText,
        elevation: 0,
        title: Text(
          'Booking Status',
          style: theme.titleMedium.override(
            font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: theme.secondaryBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.alternate),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.track_changes_rounded,
                          color: theme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              serviceTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.titleMedium.override(
                                font: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              providerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.bodyMedium.override(
                                color: theme.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _StatusChip(status: bookingStatus, theme: theme),
                  const SizedBox(height: 16),
                  _StatusMetaRow(
                    theme: theme,
                    icon: Icons.calendar_today_rounded,
                    title: 'Booking date',
                    subtitle:
                        '${bookingDate.month}/${bookingDate.day}/${bookingDate.year}',
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.status,
    required this.theme,
  });

  final String status;
  final AppThemeData theme;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final color = switch (normalized) {
      'booking confirmed' || 'confirmed' => const Color(0xFF16A34A),
      'booking cancelled' || 'cancelled' => const Color(0xFFDC2626),
      _ => const Color(0xFFF59E0B),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        _titleCaseStatus(normalized),
        style: theme.bodySmall.override(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusMetaRow extends StatelessWidget {
  const _StatusMetaRow({
    required this.theme,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final AppThemeData theme;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.secondaryText),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.bodySmall.override(
                    color: theme.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.bodyMedium.override(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}

String _titleCaseStatus(String status) => status
    .split(' ')
    .map((word) => word.isEmpty
        ? word
        : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
    .join(' ');
