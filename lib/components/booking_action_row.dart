import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/theme/app_theme.dart';

/// Per-status action grammar for booking cards and detail footers.
///
/// - Pending/active: filled royal-blue primary + outlined secondary.
/// - Completed: filled teal primary + muted gray secondary.
/// - Canceled (and any unrecognized status): a single low-contrast
///   "View Details" text link.
class BookingActionRow extends StatelessWidget {
  const BookingActionRow({
    super.key,
    required this.status,
    this.onTrack,
    this.onReschedule,
    this.onReview,
    this.onBookAgain,
    this.onViewDetails,
  });

  final String status;

  /// Pending/active primary — "Track Service".
  final VoidCallback? onTrack;

  /// Pending/active secondary — "Reschedule".
  final VoidCallback? onReschedule;

  /// Completed primary — "Write Review".
  final VoidCallback? onReview;

  /// Completed secondary — "Book Again".
  final VoidCallback? onBookAgain;

  /// Canceled/fallback — "View Details" text link.
  final VoidCallback? onViewDetails;

  static bool _isCompleted(String normalized) => normalized == 'completed';

  static bool _isCanceled(String normalized) =>
      normalized == 'cancelled' || normalized == 'canceled';

  /// True for statuses that behave like Pending (trackable + reschedulable).
  static bool isTrackable(String status) {
    final normalized = status.trim().toLowerCase();
    return !_isCompleted(normalized) && !_isCanceled(normalized);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final normalized = status.trim().toLowerCase();

    if (_isCompleted(normalized)) {
      return Row(
        children: [
          Expanded(
            child: _FilledAction(
              label: 'Write Review',
              icon: Icons.rate_review_rounded,
              background: AppThemeData.successTeal,
              foreground: Colors.white,
              onPressed: onReview,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onBookAgain,
              icon: const Icon(Icons.replay_rounded, size: 16),
              label: Text(
                'Book Again',
                style: theme.labelMedium.override(
                  font: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                  ),
                  color: theme.secondaryText,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.secondaryText,
                side: BorderSide(color: theme.border),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppThemeData.radiusMd),
                ),
                minimumSize: const Size.fromHeight(44),
              ),
            ),
          ),
        ],
      );
    }

    if (_isCanceled(normalized)) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: onViewDetails,
          icon: Icon(
            Icons.visibility_outlined,
            size: 16,
            color: theme.textTertiary,
          ),
          label: Text(
            'View Details',
            style: theme.labelMedium.override(
              font: GoogleFonts.plusJakartaSans(),
              color: theme.textTertiary,
            ),
          ),
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: _FilledAction(
            label: 'Track Service',
            icon: Icons.location_searching_rounded,
            background: AppThemeData.actionPrimary,
            foreground: Colors.white,
            onPressed: onTrack,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onReschedule,
            icon: const Icon(Icons.edit_calendar_rounded, size: 16),
            label: Text(
              'Reschedule',
              style: theme.labelMedium.override(
                font: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                ),
                color: AppThemeData.actionPrimary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppThemeData.actionPrimary,
              side: const BorderSide(
                color: AppThemeData.actionPrimary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppThemeData.radiusMd),
              ),
              minimumSize: const Size.fromHeight(44),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilledAction extends StatelessWidget {
  const _FilledAction({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(
          label,
          style: AppTheme.of(context).labelMedium.override(
                font: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                ),
                color: foreground,
              ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemeData.radiusMd),
          ),
          minimumSize: const Size.fromHeight(44),
        ),
      );
}
