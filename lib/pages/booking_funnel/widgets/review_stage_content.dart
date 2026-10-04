import 'package:flutter/material.dart';

import '/components/cupertino_ui/app_button.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';
import '../booking_controller.dart';
import '../booking_models.dart';

/// Body of the Review booking stage: mode banner, request summary (service,
/// timing, address, landmarks, scope, arrival-code and payment preference)
/// and the server estimate (breakdown, total, or retry).
///
/// Used by `CheckoutScreen`'s sheet and embedded inside the booking funnel
/// accordion page. Payment-method *selection* happens on the payment page —
/// this widget only displays the draft's current preference.
class ReviewStageContent extends StatelessWidget {
  const ReviewStageContent({
    required this.controller,
    required this.onPickAddress,
    super.key,
    this.onBack,
  });

  final BookingFlowController controller;
  final Future<void> Function() onPickAddress;

  /// Shown by the estimate retry banner. `null` hides the back action.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppTheme.of(context);
    final draft = controller.draft;
    final quote = controller.quote;
    final isScheduled = draft.dispatchMode == BookingDispatchMode.scheduled ||
        draft.urgency == BookingUrgency.scheduled;
    final scheduleLabel = isScheduled
        ? formatScheduleLabel(draft, l10n)
        : formatAsapLabel(draft, l10n);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _ModeBanner(
          isScheduled: isScheduled,
          title: isScheduled
              ? l10n.bfScheduledReservation
              : l10n.bfInstantProviderSearch,
          subtitle: isScheduled
              ? l10n.bfLockInSlot
              : l10n.bfSearchSavedPin,
        ),
        const SizedBox(height: 14),
        _SummaryGrid(
          rows: [
            _SummaryItem(
              label: l10n.bfService,
              value: controller.selectedServiceLabel(l10n),
            ),
            _SummaryItem(
              label: isScheduled
                  ? l10n.bfScheduledDateTime
                  : l10n.bfDispatchMode,
              value: scheduleLabel,
            ),
            _SummaryItem(
              label: quantityLabelFor(draft.serviceCategoryName, l10n),
              value: '${draft.rooms}',
            ),
            _SummaryItem(
              label: serviceLevelLabelFor(draft.serviceCategoryName, l10n),
              value: controller.cleaningTypeLabel(l10n),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _ActionRowCard(
          icon: Icons.place_rounded,
          title: draft.address.label,
          subtitle: '${draft.address.line1}, ${draft.address.city}',
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onPickAddress,
        ),
        const SizedBox(height: 14),
        _SummaryGrid(
          rows: [
            if (draft.landmarks.trim().isNotEmpty)
              _SummaryItem(
                label: l10n.bfLandmarks,
                value: draft.landmarks.trim(),
              ),
            _SummaryItem(
              label: l10n.bfRequireArrivalCode,
              value: draft.requireArrivalCode ? l10n.bdYes : l10n.bfNo,
            ),
            _SummaryItem(
              label: l10n.bfPaymentMethod,
              value: controller.paymentLabel(l10n),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (controller.quoteError != null) ...[
          _EstimateRetryBanner(
            onRetry: controller.refreshQuote,
            onBack: onBack,
          ),
        ] else if (controller.isLoadingQuote && quote.total <= 0) ...[
          const _EstimateSkeleton(),
        ] else ...[
          _EstimateBreakdownCard(quote: quote),
          const SizedBox(height: 14),
          _TotalCard(total: quote.total),
        ],
      ],
    );
  }
}

/// Schedule summary for a scheduled draft (e.g. "Jun 25, 9:30 AM").
String formatScheduleLabel(BookingDraft draft, AppLocalizations l10n) {
  if (draft.urgency == BookingUrgency.rightNow) {
    return l10n.bfNow;
  }
  if (draft.urgency == BookingUrgency.laterToday && draft.scheduledTime != null) {
    return l10n.bfTodayAtTime(formatTimeOfDay(draft.scheduledTime!));
  }
  if (draft.urgency == BookingUrgency.scheduled &&
      draft.scheduledDate != null &&
      draft.scheduledTime != null) {
    return l10n.bfOnDateAtTime(
      draft.scheduledDate!.month,
      draft.scheduledDate!.day,
      formatTimeOfDay(draft.scheduledTime!),
    );
  }
  return l10n.bfSelectATime;
}

/// Schedule summary for an immediate draft (e.g. "ASAP — finding provider").
String formatAsapLabel(BookingDraft draft, AppLocalizations l10n) {
  if (draft.urgency == BookingUrgency.laterToday && draft.scheduledTime != null) {
    return l10n.bfAsapTodayAfter(formatTimeOfDay(draft.scheduledTime!));
  }
  if (draft.urgency == BookingUrgency.laterToday) {
    return l10n.bfLaterToday;
  }
  return l10n.bfAsapFindingProvider;
}

/// Localized label for the quantity stepper's value (rooms/items/quantity).
String quantityLabelFor(String? categoryName, AppLocalizations l10n) {
  final normalized = (categoryName ?? '').toLowerCase();
  if (normalized.contains('clean')) {
    return l10n.bfRooms;
  }
  if (normalized.contains('repair') || normalized.contains('install')) {
    return l10n.bfItems;
  }
  return l10n.bfQuantity;
}

/// Localized label for the service-level choice (cleaning type vs level).
String serviceLevelLabelFor(String? categoryName, AppLocalizations l10n) {
  final normalized = (categoryName ?? '').toLowerCase();
  if (normalized.contains('clean')) {
    return l10n.bfCleaningType;
  }
  return l10n.bfServiceLevel;
}

class _ModeBanner extends StatelessWidget {
  const _ModeBanner({
    required this.isScheduled,
    required this.title,
    required this.subtitle,
  });

  final bool isScheduled;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isScheduled
            ? theme.primary.withValues(alpha: 0.08)
            : theme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isScheduled
              ? theme.primary.withValues(alpha: 0.28)
              : theme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isScheduled
                  ? theme.primary.withValues(alpha: 0.14)
                  : theme.alternate,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isScheduled ? Icons.event_available_rounded : Icons.bolt_rounded,
              color: theme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.titleSmall.override(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.bodySmall.override(
                    color: theme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.rows});

  final List<_SummaryItem> rows;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.alternate),
      ),
      child: Column(
        children: rows
            .map(
              (row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        row.label,
                        style: theme.bodyMedium.override(
                          color: theme.secondaryText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        row.value,
                        textAlign: TextAlign.right,
                        style: theme.bodyMedium.override(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SummaryItem {
  const _SummaryItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class _ActionRowCard extends StatelessWidget {
  const _ActionRowCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return InkWell(
      onTap: () async {
        await onTap();
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: theme.alternate),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: theme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.bodyMedium.override(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.bodySmall.override(
                      color: theme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _EstimateBreakdownCard extends StatelessWidget {
  const _EstimateBreakdownCard({required this.quote});

  final BookingQuote quote;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppTheme.of(context);
    final rows = <(String, double)>[
      (l10n.bfBaseService, quote.basePrice),
      if (quote.roomSubtotal != 0) (l10n.bfScope, quote.roomSubtotal),
      if (quote.cleaningTypeAdjustment != 0)
        (l10n.bfServiceLevel, quote.cleaningTypeAdjustment),
      if (quote.urgencyAdjustment != 0)
        (l10n.bfRushFactor, quote.urgencyAdjustment),
      if (quote.timePremium != 0)
        ('Time adjustment', quote.timePremium),
      if (quote.platformFee != 0) ('Platform fee', quote.platformFee),
      if (quote.vat != 0) ('VAT', quote.vat),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.alternate),
      ),
      child: Column(
        children: [
          for (final (label, value) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: theme.bodyMedium.override(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    'PHP ${value.toStringAsFixed(0)}',
                    style: theme.bodyMedium.override(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _EstimateSkeleton extends StatelessWidget {
  const _EstimateSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.alternate),
      ),
      child: Column(
        children: [
          for (var index = 0; index < 3; index++) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 90,
                  height: 12,
                  decoration: BoxDecoration(
                    color: theme.alternate.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Container(
                  width: 48,
                  height: 12,
                  decoration: BoxDecoration(
                    color: theme.alternate.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ),
            if (index < 2) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.bfEstimatedTotal,
            style: theme.bodyLarge.override(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'PHP ${total.toStringAsFixed(0)}',
            style: theme.titleLarge.override(
              fontWeight: FontWeight.w700,
              color: theme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EstimateRetryBanner extends StatelessWidget {
  const _EstimateRetryBanner({
    required this.onRetry,
    required this.onBack,
  });

  final Future<void> Function() onRetry;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.warning.withValues(alpha: 0.30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 20,
                color: theme.warning,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.bfEstimateUnavailable,
                  style: theme.bodySmall.override(
                    color: theme.secondaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: AppButton(
                    onPressed: () async {
                      await onRetry();
                    },
                    variant: AppButtonVariant.outlined,
                    borderSide: BorderSide(color: theme.alternate),
                    foregroundColor: theme.primary,
                    borderRadius: 14,
                    child: Text(
                      l10n.bfRetry,
                      style: theme.bodyMedium.override(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              if (onBack != null) ...[
                const SizedBox(width: 10),
                TextButton(
                  onPressed: onBack,
                  child: Text(
                    l10n.bfBack,
                    style: theme.bodyMedium.override(
                      color: theme.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
