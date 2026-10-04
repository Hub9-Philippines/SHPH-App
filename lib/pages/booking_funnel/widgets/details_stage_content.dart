import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/components/cupertino_ui/app_button.dart';
import '/components/cupertino_ui/app_pickers.dart';
import '/components/cupertino_ui/app_switch.dart';
import '/components/cupertino_ui/app_text_field.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';
import '../booking_controller.dart';
import '../booking_models.dart';

/// Body of the Details booking stage (dispatch mode, service summary, scope,
/// service level, landmarks, arrival code, live estimate).
///
/// Used by `BookingSetupScreen` as a standalone scroll view and embedded
/// (non-scrollable) inside the booking funnel accordion page.
class DetailsStageContent extends StatelessWidget {
  const DetailsStageContent({super.key, this.scrollable = true});

  /// Wraps the content in its own [ListView] when `true`. Pass `false` when
  /// embedding into an outer scroll view.
  final bool scrollable;

  @override
  Widget build(BuildContext context) =>
      Consumer<BookingFlowController>(
      builder: (context, controller, _) {
        final l10n = AppLocalizations.of(context)!;
        final quote = controller.quote;
        final children = <Widget>[
          _SetupHero(
            subtitle: l10n.bfAdjustScope,
            urgencyLabel: controller.urgencyLabel(l10n),
          ),
          const SizedBox(height: 16),
          _SectionLabel(title: l10n.bfDispatchModeTitle),
          const SizedBox(height: 10),
          _DispatchModeSelector(controller: controller),
          const SizedBox(height: 16),
          _SectionLabel(title: l10n.bfServiceSummary),
          const SizedBox(height: 10),
          _SummaryTile(controller: controller),
          const SizedBox(height: 16),
          _SectionLabel(title: l10n.bfScope),
          const SizedBox(height: 10),
          _StepperRow(
            title: controller.draft.serviceCategoryName == null
                ? l10n.bfQuantity
                : _quantityTitle(
                    controller.draft.serviceCategoryName!,
                    l10n,
                  ),
            value: controller.draft.rooms.toString(),
            hint: controller.draft.serviceCategoryName == null
                ? l10n.bfQuantityHintDefault
                : _quantityHint(
                    controller.draft.serviceCategoryName!,
                    l10n,
                  ),
            onMinus: controller.draft.rooms <= 1
                ? null
                : () => controller.setRooms(controller.draft.rooms - 1),
            onPlus: () => controller.setRooms(controller.draft.rooms + 1),
          ),
          const SizedBox(height: 16),
          _SectionLabel(title: l10n.bfServiceLevel),
          const SizedBox(height: 10),
          _ChoiceGroup(
            title: _serviceLevelTitle(
              controller.draft.serviceCategoryName,
              l10n,
            ),
            options: _serviceLevelOptions(
              controller.draft.serviceCategoryName,
              l10n,
            ),
            selected: controller.draft.cleaningType,
            onChanged: controller.setServiceType,
          ),
          const SizedBox(height: 16),
          _SectionLabel(title: l10n.bfLandmarks),
          const SizedBox(height: 10),
          _LandmarksField(controller: controller),
          const SizedBox(height: 16),
          _ArrivalCodeTile(controller: controller),
          const SizedBox(height: 18),
          _SectionLabel(title: l10n.bfLiveEstimate),
          const SizedBox(height: 10),
          _EstimateSection(
            isLoading: controller.isLoadingQuote,
            error: controller.quoteError,
            quote: quote,
            onRetry: controller.refreshQuote,
          ),
        ];
        if (!scrollable) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: children,
        );
      },
    );
}

class _SetupHero extends StatelessWidget {
  const _SetupHero({
    required this.subtitle,
    required this.urgencyLabel,
  });

  final String subtitle;
  final String urgencyLabel;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: theme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.bfFinalizeJobSetup,
                  style: theme.titleSmall.override(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.bodySmall.override(
                    color: theme.secondaryText,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primaryBackground,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    urgencyLabel,
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
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Text(
      title,
      style: theme.labelLarge.override(
        color: theme.secondaryText,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _LandmarksField extends StatefulWidget {
  const _LandmarksField({required this.controller});

  final BookingFlowController controller;

  @override
  State<_LandmarksField> createState() => _LandmarksFieldState();
}

class _LandmarksFieldState extends State<_LandmarksField> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.controller.draft.landmarks,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return AppTextField(
      controller: _textController,
      onChanged: widget.controller.setLandmarks,
      placeholder: l10n.bfLandmarksPlaceholder,
      placeholderStyle: theme.bodySmall.override(
        font: GoogleFonts.plusJakartaSans(),
        color: theme.textTertiary,
      ),
      prefixIcon: Icons.landscape_rounded,
      radius: AppThemeData.radiusMd,
      fillColor: theme.primaryBackground,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      maxLines: 3,
    );
  }
}

class _ArrivalCodeTile extends StatelessWidget {
  const _ArrivalCodeTile({required this.controller});

  final BookingFlowController controller;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(20),
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
            child: Icon(Icons.password_rounded, color: theme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.bfRequireArrivalCode,
                  style: theme.bodyMedium.override(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.bfProviderMustConfirmCode,
                  style: theme.bodySmall.override(
                    color: theme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AppSwitch(
            value: controller.draft.requireArrivalCode,
            onChanged: controller.setRequireArrivalCode,
            activeColor: theme.primary,
          ),
        ],
      ),
    );
  }
}

class _EstimateSection extends StatelessWidget {
  const _EstimateSection({
    required this.isLoading,
    required this.error,
    required this.quote,
    required this.onRetry,
  });

  final bool isLoading;
  final String? error;
  final BookingQuote quote;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppTheme.of(context);
    if (isLoading && quote.total <= 0) {
      return const _EstimateSkeleton();
    }
    if (error != null) {
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
                  color: theme.warning,
                  size: 20,
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
            SizedBox(
              width: double.infinity,
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
          ],
        ),
      );
    }
    return _PriceBreakdown(quote: quote);
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

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.controller});

  final BookingFlowController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppTheme.of(context);
    final draft = controller.draft;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.alternate),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.schedule_rounded, color: theme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.bfService,
                  style: theme.labelMedium.override(
                    color: theme.secondaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  controller.selectedServiceLabel(l10n),
                  style: theme.bodyLarge.override(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if ((draft.serviceCategoryName ?? '').isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    draft.serviceCategoryName!,
                    style: theme.bodySmall.override(
                      color: theme.secondaryText,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  controller.urgencyLabel(l10n),
                  style: theme.bodySmall.override(
                    color: theme.secondaryText,
                  ),
                ),
                if ((draft.serviceDescription ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    draft.serviceDescription!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.bodySmall.override(
                      color: theme.secondaryText,
                    ),
                  ),
                ],
                if (draft.scheduledDate != null && draft.scheduledTime != null)
                  Text(
                    l10n.bfOnDateAtTime(
                      draft.scheduledDate!.month,
                      draft.scheduledDate!.day,
                      formatTimeOfDay(draft.scheduledTime!),
                    ),
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

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.title,
    required this.value,
    required this.hint,
    required this.onMinus,
    required this.onPlus,
  });

  final String title;
  final String value;
  final String hint;
  final VoidCallback? onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.alternate),
      ),
      child: Row(
        children: [
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
                  hint,
                  style: theme.bodySmall.override(
                    color: theme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          _StepperButton(icon: Icons.remove, onTap: onMinus),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              value,
              style: theme.titleLarge.override(fontWeight: FontWeight.w700),
            ),
          ),
          _StepperButton(icon: Icons.add, onTap: onPlus),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: onTap == null
              ? theme.alternate.withValues(alpha: 0.35)
              : theme.primaryBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.alternate),
        ),
        child: Icon(
          icon,
          color: onTap == null ? theme.secondaryText : theme.primaryText,
        ),
      ),
    );
  }
}

class _ChoiceGroup extends StatelessWidget {
  const _ChoiceGroup({
    required this.title,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final String title;
  final List<(ServiceType, String)> options;
  final ServiceType selected;
  final ValueChanged<ServiceType> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.bodyLarge.override(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((option) {
            final isSelected = option.$1 == selected;
            return ChoiceChip(
              label: Text(option.$2),
              selected: isSelected,
              onSelected: (_) => onChanged(option.$1),
              selectedColor: theme.primary.withValues(alpha: 0.14),
              labelStyle: theme.bodyMedium.override(
                fontWeight: FontWeight.w600,
                color: isSelected ? theme.primary : theme.primaryText,
              ),
              side: BorderSide(
                color: isSelected ? theme.primary : theme.alternate,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

String _serviceLevelTitle(String? categoryName, AppLocalizations l10n) {
  final normalized = (categoryName ?? '').toLowerCase();
  if (normalized.contains('clean')) {
    return l10n.bfCleaningType;
  }
  return l10n.bfServiceLevel;
}

String _quantityTitle(String categoryName, AppLocalizations l10n) {
  final normalized = categoryName.toLowerCase();
  if (normalized.contains('clean')) {
    return l10n.bfRooms;
  }
  if (normalized.contains('repair') || normalized.contains('install')) {
    return l10n.bfItems;
  }
  return l10n.bfQuantity;
}

String _quantityHint(String categoryName, AppLocalizations l10n) {
  final normalized = categoryName.toLowerCase();
  if (normalized.contains('clean')) {
    return l10n.bfQuantityHintRooms;
  }
  if (normalized.contains('repair') || normalized.contains('install')) {
    return l10n.bfQuantityHintItems;
  }
  return l10n.bfQuantityHintDefault;
}

List<(ServiceType, String)> _serviceLevelOptions(
  String? categoryName,
  AppLocalizations l10n,
) {
  final normalized = (categoryName ?? '').toLowerCase();
  if (normalized.contains('clean')) {
    return [
      (ServiceType.standard, l10n.bfLevelStandard),
      (ServiceType.deep, l10n.bfLevelDeep),
      (ServiceType.premium, l10n.bfLevelPremium),
    ];
  }
  return [
    (ServiceType.standard, l10n.bfLevelBasic),
    (ServiceType.deep, l10n.bfLevelPriority),
    (ServiceType.premium, l10n.bfLevelExpress),
  ];
}

class _PriceBreakdown extends StatelessWidget {
  const _PriceBreakdown({required this.quote});

  final BookingQuote quote;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          _row(context, l10n.bfBaseService, quote.basePrice),
          _row(context, l10n.bfScope, quote.roomSubtotal),
          _row(context, l10n.bfServiceLevel, quote.cleaningTypeAdjustment),
          _row(context, l10n.bfRushFactor, quote.urgencyAdjustment),
          const Divider(height: 24),
          _row(context, l10n.bfTotal, quote.total, bold: true),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, double value,
      {bool bold = false}) {
    final theme = AppTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.bodyMedium.override(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Text(
            'PHP ${value.toStringAsFixed(0)}',
            style: theme.bodyMedium.override(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: bold ? theme.primary : theme.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _DispatchModeSelector extends StatelessWidget {
  const _DispatchModeSelector({required this.controller});

  final BookingFlowController controller;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currentMode = controller.draft.dispatchMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DispatchModeCard(
          title: l10n.bfOnDemandTitle,
          subtitle: l10n.bfOnDemandSubtitle,
          tag: l10n.bfFastest,
          tagColor: theme.primary,
          icon: Icons.bolt_rounded,
          selected: currentMode == BookingDispatchMode.onDemand,
          onTap: () => controller.setDispatchMode(BookingDispatchMode.onDemand),
        ),
        const SizedBox(height: 10),
        _DispatchModeCard(
          title: l10n.bfStandardBookingTitle,
          subtitle: l10n.bfStandardBookingSubtitle,
          tag: l10n.bfScheduled,
          tagColor: theme.secondaryText,
          icon: Icons.calendar_month_rounded,
          selected: currentMode == BookingDispatchMode.scheduled,
          onTap: () => controller.setDispatchMode(BookingDispatchMode.scheduled),
        ),
        if (currentMode == BookingDispatchMode.scheduled) ...[
          const SizedBox(height: 12),
          _ScheduledSlotPicker(controller: controller),
        ] else ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.bolt_rounded, size: 18, color: theme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.bfInstantDispatchBanner,
                    style: theme.labelSmall.override(
                      color: theme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ScheduledSlotPicker extends StatelessWidget {
  const _ScheduledSlotPicker({required this.controller});

  final BookingFlowController controller;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final draft = controller.draft;
    final hasSlot = draft.scheduledDate != null && draft.scheduledTime != null;

    final displayText = hasSlot
        ? l10n.bfOnDateAtTime(
            draft.scheduledDate!.month,
            draft.scheduledDate!.day,
            formatTimeOfDay(draft.scheduledTime!),
          )
        : l10n.bfPickDateTime;

    return InkWell(
      onTap: () async {
        final date = await showAppDatePicker(
          context: context,
          initialDate: draft.scheduledDate ??
              DateTime.now().add(const Duration(days: 1)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 180)),
        );
        if (date == null || !context.mounted) {
          return;
        }

        final time = await showAppTimePicker(
          context: context,
          initialTime:
              draft.scheduledTime ?? const TimeOfDay(hour: 9, minute: 0),
        );
        if (time == null || !context.mounted) {
          return;
        }

        controller.setSchedule(
          date: date,
          time: time,
          urgency: BookingUrgency.scheduled,
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasSlot ? theme.primary : theme.alternate,
            width: hasSlot ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 20,
              color: hasSlot ? theme.primary : theme.secondaryText,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                displayText,
                style: theme.bodyMedium.override(
                  color: hasSlot ? theme.primaryText : theme.secondaryText,
                  fontWeight: hasSlot ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            Text(
              hasSlot ? l10n.bfChange : l10n.bfPickDateTime,
              style: theme.labelMedium.override(
                color: theme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DispatchModeCard extends StatelessWidget {
  const _DispatchModeCard({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.tagColor,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String tag;
  final Color tagColor;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? theme.primary.withValues(alpha: 0.08)
              : theme.secondaryBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? theme.primary : theme.alternate,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? theme.primary.withValues(alpha: 0.16)
                    : theme.primaryBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: selected ? theme.primary : theme.secondaryText,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: theme.bodyMedium.override(
                            fontWeight: FontWeight.w700,
                            color: theme.primaryText,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: tagColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag,
                          style: theme.labelSmall.override(
                            color: tagColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
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
      ),
    );
  }
}
