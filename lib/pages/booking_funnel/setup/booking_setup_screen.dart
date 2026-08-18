import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/theme/app_theme.dart';
import '../booking_controller.dart';
import '../booking_models.dart';
import '../checkout/checkout_screen.dart';
import '../widgets/booking_flow_route.dart';

class BookingSetupScreen extends StatelessWidget {
  const BookingSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_rounded,
              size: 24, color: theme.primaryText),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step 3 of 3',
              style: theme.labelMedium.override(
                color: theme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Service setup',
              style: theme.titleLarge.override(
                font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Consumer<BookingFlowController>(
          builder: (context, controller, _) {
            final quote = controller.quote;
            return Column(
              children: [
                const _SetupProgress(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      _SetupHero(
                        subtitle:
                            'Adjust the scope in seconds. Pricing updates live as you change settings.',
                        urgencyLabel: controller.urgencyLabel,
                      ),
                      const SizedBox(height: 16),
                      const _SectionLabel(title: 'Service summary'),
                      const SizedBox(height: 10),
                      _SummaryTile(controller: controller),
                      const SizedBox(height: 16),
                      const _SectionLabel(title: 'Scope'),
                      const SizedBox(height: 10),
                      _StepperRow(
                        title: controller.draft.serviceCategoryName == null
                            ? 'Quantity'
                            : _quantityTitle(
                                controller.draft.serviceCategoryName!,
                              ),
                        value: controller.draft.rooms.toString(),
                        hint: controller.draft.serviceCategoryName == null
                            ? 'How many units or sessions do you need?'
                            : _quantityHint(
                                controller.draft.serviceCategoryName!,
                              ),
                        onMinus: controller.draft.rooms <= 1
                            ? null
                            : () =>
                                controller.setRooms(controller.draft.rooms - 1),
                        onPlus: () =>
                            controller.setRooms(controller.draft.rooms + 1),
                      ),
                      const SizedBox(height: 16),
                      const _SectionLabel(title: 'Service level'),
                      const SizedBox(height: 10),
                      _ChoiceGroup(
                        title: _serviceLevelTitle(
                          controller.draft.serviceCategoryName,
                        ),
                        options: _serviceLevelOptions(
                          controller.draft.serviceCategoryName,
                        ),
                        selected: controller.draft.cleaningType,
                        onChanged: controller.setServiceType,
                      ),
                      const SizedBox(height: 18),
                      const _SectionLabel(title: 'Live estimate'),
                      const SizedBox(height: 10),
                      _PriceBreakdown(quote: quote),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          final controller =
                              context.read<BookingFlowController>();
                          Navigator.of(context).push(
                            buildBookingFlowRoute(
                              ChangeNotifierProvider.value(
                                value: controller,
                                child: const CheckoutScreen(),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          foregroundColor: theme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Continue to checkout',
                          style: theme.titleMedium.override(
                            color: theme.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
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
                  'Finalize the job setup',
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

class _SetupProgress extends StatelessWidget {
  const _SetupProgress();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: _SetupStepPill(
                title: 'Location',
                done: true,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _SetupStepPill(
                title: 'Time',
                done: true,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _SetupStepPill(
                title: 'Setup',
                active: true,
              ),
            ),
          ],
        ),
      );
}

class _SetupStepPill extends StatelessWidget {
  const _SetupStepPill({
    required this.title,
    this.active = false,
    this.done = false,
  });

  final String title;
  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final color = done || active ? theme.primary : theme.alternate;
    final background = done || active
        ? theme.primary.withValues(alpha: active ? 0.14 : 0.08)
        : theme.secondaryBackground;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: done || active ? 0.5 : 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (done)
            Icon(
              Icons.check_circle_rounded,
              size: 16,
              color: theme.primary,
            )
          else
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: active ? theme.primary : theme.secondaryText,
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: theme.bodySmall.override(
                color: done || active ? theme.primary : theme.secondaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
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
                  'Service',
                  style: theme.labelMedium.override(
                    color: theme.secondaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  controller.selectedServiceLabel,
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
                  controller.urgencyLabel,
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
                    '${draft.scheduledDate!.month}/${draft.scheduledDate!.day} ${formatTimeOfDay(draft.scheduledTime!)}',
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

String _serviceLevelTitle(String? categoryName) {
  final normalized = (categoryName ?? '').toLowerCase();
  if (normalized.contains('clean')) {
    return 'Cleaning type';
  }
  return 'Service level';
}

String _quantityTitle(String categoryName) {
  final normalized = categoryName.toLowerCase();
  if (normalized.contains('clean')) {
    return 'Rooms';
  }
  if (normalized.contains('repair') || normalized.contains('install')) {
    return 'Items';
  }
  return 'Quantity';
}

String _quantityHint(String categoryName) {
  final normalized = categoryName.toLowerCase();
  if (normalized.contains('clean')) {
    return 'How many rooms do you want serviced?';
  }
  if (normalized.contains('repair') || normalized.contains('install')) {
    return 'How many items or tasks should be covered?';
  }
  return 'How many units, rooms, or tasks do you need?';
}

List<(ServiceType, String)> _serviceLevelOptions(String? categoryName) {
  final normalized = (categoryName ?? '').toLowerCase();
  if (normalized.contains('clean')) {
    return const [
      (ServiceType.standard, 'Standard'),
      (ServiceType.deep, 'Deep'),
      (ServiceType.premium, 'Premium'),
    ];
  }
  return const [
    (ServiceType.standard, 'Basic'),
    (ServiceType.deep, 'Priority'),
    (ServiceType.premium, 'Express'),
  ];
}

class _PriceBreakdown extends StatelessWidget {
  const _PriceBreakdown({required this.quote});

  final BookingQuote quote;

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
          _row(context, 'Base service', quote.basePrice),
          _row(context, 'Scope', quote.roomSubtotal),
          _row(context, 'Service level', quote.cleaningTypeAdjustment),
          _row(context, 'Rush factor', quote.urgencyAdjustment),
          const Divider(height: 24),
          _row(context, 'Total', quote.total, bold: true),
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
