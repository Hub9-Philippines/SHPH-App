import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/cupertino_ui/app_button.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';
import '../booking_models.dart';

class TimeSelectionPanel extends StatelessWidget {
  const TimeSelectionPanel({
    required this.serviceTitle,
    required this.urgency,
    required this.onUrgencyChanged,
    required this.onPickLaterToday,
    required this.onPickScheduledSlot,
    required this.onNext,
    super.key,
    this.scheduledDate,
    this.scheduledTime,
  });

  final String serviceTitle;
  final BookingUrgency urgency;
  final DateTime? scheduledDate;
  final TimeOfDay? scheduledTime;
  final ValueChanged<BookingUrgency> onUrgencyChanged;
  final Future<void> Function(BuildContext context) onPickLaterToday;
  final Future<void> Function(BuildContext context) onPickScheduledSlot;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final scheduleSummary = _buildSummary(l10n);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: theme.primaryBackground.withValues(alpha: 0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: theme.alternate.withValues(alpha: 0.35)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: theme.alternate,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              l10n.bfChooseTiming,
              style: theme.labelMedium.override(
                color: theme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.bfWhenNeedService(serviceTitle.toLowerCase()),
            style: theme.titleMedium.override(
              font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.bfPickDispatchSpeed,
            style: theme.bodySmall.override(
              color: theme.secondaryText,
            ),
          ),
          if (scheduleSummary != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: theme.primary.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 18,
                    color: theme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      scheduleSummary,
                      style: theme.labelMedium.override(
                        color: theme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          _TimeCard(
            title: l10n.bfRightNowTitle,
            subtitle: l10n.bfInstantDispatch,
            icon: Icons.bolt_rounded,
            selected: urgency == BookingUrgency.rightNow,
            onTap: () => onUrgencyChanged(BookingUrgency.rightNow),
          ),
          const SizedBox(height: 10),
          _TimeCard(
            title: l10n.bfLaterTodayTitle,
            subtitle: l10n.bfPickSpecificTime,
            icon: Icons.schedule_rounded,
            selected: urgency == BookingUrgency.laterToday,
            onTap: () async {
              onUrgencyChanged(BookingUrgency.laterToday);
              await onPickLaterToday(context);
            },
          ),
          const SizedBox(height: 10),
          _TimeCard(
            title: l10n.bfScheduleAnotherDay,
            subtitle: l10n.bfChooseAnyFutureSlot,
            icon: Icons.calendar_month_rounded,
            selected: urgency == BookingUrgency.scheduled,
            onTap: () async {
              onUrgencyChanged(BookingUrgency.scheduled);
              await onPickScheduledSlot(context);
            },
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: AppButton(
              onPressed: onNext,
              backgroundColor: theme.primary,
              foregroundColor: theme.onPrimary,
              borderRadius: 18,
              width: double.infinity,
              child: Text(
                l10n.bfContinueToSetup,
                style: theme.titleMedium.override(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _buildSummary(AppLocalizations l10n) {
    if (urgency == BookingUrgency.rightNow) {
      return l10n.bfInstantDispatch;
    }
    if (urgency == BookingUrgency.laterToday && scheduledTime != null) {
      return l10n.bfTodayAtTime(formatTimeOfDay(scheduledTime!));
    }
    if (urgency == BookingUrgency.scheduled &&
        scheduledDate != null &&
        scheduledTime != null) {
      return '${scheduledDate!.month}/${scheduledDate!.day} at ${formatTimeOfDay(scheduledTime!)}';
    }
    return null;
  }
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? theme.primary.withValues(alpha: 0.12)
              : theme.secondaryBackground,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? theme.primary : theme.alternate,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? theme.primary.withValues(alpha: 0.16)
                    : theme.primaryBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: selected ? theme.primary : theme.secondaryText,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.bodyLarge.override(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.bodySmall.override(
                      color: theme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle_rounded : Icons.arrow_forward_ios,
              size: selected ? 22 : 16,
              color: selected ? theme.primary : theme.secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}
