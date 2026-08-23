import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:provider/provider.dart';

import '/app_state.dart';
import '/backend/supabase/supabase.dart';
import '/components/edit_address/edit_address_widget.dart';
import '/theme/app_theme.dart';
import '../booking_controller.dart';
import '../booking_models.dart';
import '../booking_success_screen.dart';
import '../live_matching/live_matching_screen.dart';
import '../widgets/booking_flow_route.dart';
import '../widgets/booking_status_scaffold.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({
    super.key,
    this.showLiveMap = true,
  });

  final bool showLiveMap;

  @override
  Widget build(BuildContext context) => Consumer<BookingFlowController>(
        builder: (context, controller, _) {
          final draft = controller.draft;
          final quote = controller.quote;
          final isScheduled = draft.urgency == BookingUrgency.scheduled;
          final isImmediate = !isScheduled;
          final location = gmaps.LatLng(draft.latitude, draft.longitude);

          final showWaiting = controller.isMatchingActive;

          return BookingStatusScaffold(
            showMap: showLiveMap,
            location: location,
            markerHue: gmaps.BitmapDescriptor.hueRose,
            bottomSheet: BookingStatusBottomSheet(
              child: showWaiting
                  ? _MatchingWaitingSheet(
                      controller: controller,
                      quote: quote,
                      isScheduled: isScheduled,
                      scheduleLabel: isScheduled
                          ? _formatSchedule(draft)
                          : _asapLabel(draft),
                      serviceLevelLabel:
                          _serviceLevelLabel(draft.serviceCategoryName),
                      quantityLabel: _quantityLabel(draft.serviceCategoryName),
                      onResume: () {
                        controller.setMatchingActive(false);
                        unawaited(
                          Navigator.of(context).push(
                            buildBookingFlowRoute(
                              ChangeNotifierProvider.value(
                                value: controller,
                                child: LiveMatchingScreen(
                                  bookingDate: _liveMatchingDate(draft),
                                  showMap: showLiveMap,
                                  serviceTitle: controller.selectedServiceLabel,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      onCancel: () {
                        controller.setMatchingActive(false);
                        controller.setLiveSearchTimedOut(false);
                      },
                    )
                  : _CheckoutSheet(
                      controller: controller,
                      quote: quote,
                      isScheduled: isScheduled,
                      isImmediate: isImmediate,
                      title: isScheduled
                          ? 'Review scheduled booking'
                          : 'Review live request',
                      subtitle: isScheduled
                          ? 'Confirm the slot, pinned address, and payment before we reserve it.'
                          : 'Confirm the pinned address and payment before we start searching nearby providers.',
                      onSubmit: controller.isSubmitting
                          ? null
                          : () async {
                              await _submit(context, controller);
                            },
                      onPickAddress: () async {
                        await _pickAddress(context, controller);
                      },
                      onBack: () => Navigator.of(context).pop(),
                      buttonLabel: _buttonLabel(draft),
                      scheduleLabel: isScheduled
                          ? _formatSchedule(draft)
                          : _asapLabel(draft),
                      quantityLabel: _quantityLabel(draft.serviceCategoryName),
                      serviceLevelLabel:
                          _serviceLevelLabel(draft.serviceCategoryName),
                    ),
            ),
          );
        },
      );

  Future<void> _submit(
    BuildContext context,
    BookingFlowController controller,
  ) async {
    final urgency = controller.draft.urgency;

    if (urgency == BookingUrgency.scheduled) {
      final success = await controller.attachReservationToken();
      if (!context.mounted) {
        return;
      }
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              controller.lastError ??
                  'Could not reserve the slot. Please try again.',
            ),
          ),
        );
        return;
      }
      unawaited(
        Navigator.of(context).pushReplacement(
          buildBookingFlowRoute(
            ChangeNotifierProvider.value(
              value: controller,
              child: const BookingSuccessScreen(),
            ),
          ),
        ),
      );
      return;
    }

    final success = await controller.attachLiveSearchToken();
    if (!context.mounted) {
      return;
    }
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.lastError ??
                'Could not start live matching. Please try again.',
          ),
        ),
      );
      return;
    }
    unawaited(
      Navigator.of(context).push(
        buildBookingFlowRoute(
          ChangeNotifierProvider.value(
            value: controller,
            child: LiveMatchingScreen(
              bookingDate: _liveMatchingDate(controller.draft),
              showMap: showLiveMap,
              serviceTitle: controller.selectedServiceLabel,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAddress(
    BuildContext context,
    BookingFlowController controller,
  ) async {
    final result = await showModalBottomSheet<AddressesRow>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: false,
      builder: (context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: MediaQuery.viewInsetsOf(context),
          child: const EditAddressWidget(),
        ),
      ),
    );
    if (!context.mounted || result == null) {
      return;
    }

    final appState = FFAppState();
    controller.setAddress(
      BookingAddress(
        label: appState.selectedAddressLabel.isNotEmpty
            ? appState.selectedAddressLabel
            : (result.addressLine2 ?? 'Address'),
        line1: appState.selectedAddressLine1.isNotEmpty
            ? appState.selectedAddressLine1
            : (result.addressLine1 ?? ''),
        city: appState.selectedAddressCity.isNotEmpty
            ? appState.selectedAddressCity
            : (result.city ?? ''),
      ),
    );

    final latitude = appState.selectedLatitude ?? result.latitude;
    final longitude = appState.selectedLongitude ?? result.longitude;
    if (latitude != null && longitude != null) {
      controller.setCoordinates(
        latitude: latitude,
        longitude: longitude,
      );
    }
  }

  String _buttonLabel(BookingDraft draft) {
    if (draft.urgency == BookingUrgency.scheduled) {
      return 'Confirm & Reserve Slot';
    }

    final category = (draft.serviceCategoryName ?? '').toLowerCase();
    if (category.contains('clean')) {
      return 'Find Active Cleaner Now';
    }
    return 'Find Active Provider Now';
  }

  DateTime _liveMatchingDate(BookingDraft draft) {
    if (draft.scheduledDate != null && draft.scheduledTime != null) {
      return DateTime(
        draft.scheduledDate!.year,
        draft.scheduledDate!.month,
        draft.scheduledDate!.day,
        draft.scheduledTime!.hour,
        draft.scheduledTime!.minute,
      );
    }
    return draft.scheduledDate ?? DateTime.now();
  }

  String _asapLabel(BookingDraft draft) {
    if (draft.urgency == BookingUrgency.laterToday &&
        draft.scheduledTime != null) {
      return 'ASAP today after ${formatTimeOfDay(draft.scheduledTime!)}';
    }
    if (draft.urgency == BookingUrgency.laterToday) {
      return 'Later today';
    }
    return 'ASAP - Finding nearest provider';
  }

  String _formatSchedule(BookingDraft draft) {
    if (draft.urgency == BookingUrgency.rightNow) {
      return 'Now';
    }
    if (draft.urgency == BookingUrgency.laterToday &&
        draft.scheduledTime != null) {
      return 'Today at ${formatTimeOfDay(draft.scheduledTime!)}';
    }
    if (draft.urgency == BookingUrgency.scheduled &&
        draft.scheduledDate != null &&
        draft.scheduledTime != null) {
      return '${draft.scheduledDate!.month}/${draft.scheduledDate!.day} at ${formatTimeOfDay(draft.scheduledTime!)}';
    }
    return 'Select a time';
  }

  String _quantityLabel(String? categoryName) {
    final normalized = (categoryName ?? '').toLowerCase();
    if (normalized.contains('clean')) {
      return 'Rooms';
    }
    if (normalized.contains('repair') || normalized.contains('install')) {
      return 'Items';
    }
    return 'Quantity';
  }

  String _serviceLevelLabel(String? categoryName) {
    final normalized = (categoryName ?? '').toLowerCase();
    if (normalized.contains('clean')) {
      return 'Cleaning type';
    }
    return 'Service level';
  }
}

class _CheckoutSheet extends StatelessWidget {
  const _CheckoutSheet({
    required this.controller,
    required this.quote,
    required this.isScheduled,
    required this.isImmediate,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.scheduleLabel,
    required this.quantityLabel,
    required this.serviceLevelLabel,
    required this.onPickAddress,
    required this.onBack,
    required this.onSubmit,
  });

  final BookingFlowController controller;
  final BookingQuote quote;
  final bool isScheduled;
  final bool isImmediate;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final String scheduleLabel;
  final String quantityLabel;
  final String serviceLevelLabel;
  final Future<void> Function() onPickAddress;
  final VoidCallback onBack;
  final Future<void> Function()? onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final draft = controller.draft;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 5,
          decoration: BoxDecoration(
            color: theme.alternate,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: onBack,
              style: IconButton.styleFrom(
                backgroundColor: theme.secondaryBackground,
              ),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.titleMedium.override(
                      font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                    ),
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
        const SizedBox(height: 14),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ModeBanner(
                  isScheduled: isScheduled,
                  title: isScheduled
                      ? 'Scheduled reservation'
                      : 'Instant provider search',
                  subtitle: isScheduled
                      ? 'We will lock in your selected slot and keep this pinned location for the visit.'
                      : 'We will search nearby providers around this saved pin as soon as you continue.',
                ),
                const SizedBox(height: 14),
                _SummaryGrid(
                  rows: [
                    _SummaryItem(
                      label: 'Service',
                      value: controller.selectedServiceLabel,
                    ),
                    _SummaryItem(
                      label: isScheduled
                          ? 'Scheduled date & time'
                          : 'Dispatch mode',
                      value: scheduleLabel,
                    ),
                    _SummaryItem(
                      label: quantityLabel,
                      value: '${draft.rooms}',
                    ),
                    _SummaryItem(
                      label: serviceLevelLabel,
                      value: controller.cleaningTypeLabel,
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
                const _SectionTitle(title: 'Payment method'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _Pill(
                      label: 'GCash',
                      selected:
                          draft.paymentMethod == BookingPaymentMethod.gcash,
                      onTap: () => controller
                          .setPaymentMethod(BookingPaymentMethod.gcash),
                    ),
                    _Pill(
                      label: 'Card',
                      selected:
                          draft.paymentMethod == BookingPaymentMethod.card,
                      onTap: () => controller
                          .setPaymentMethod(BookingPaymentMethod.card),
                    ),
                    _Pill(
                      label: 'COD',
                      selected: draft.paymentMethod == BookingPaymentMethod.cod,
                      onTap: () =>
                          controller.setPaymentMethod(BookingPaymentMethod.cod),
                    ),
                  ],
                ),
                if (isImmediate) ...[
                  const SizedBox(height: 14),
                  const _SectionTitle(title: 'Matching flow'),
                  const SizedBox(height: 10),
                  const _SimpleNote(
                    title: 'Provider assignment',
                    subtitle: 'Nearest available provider',
                    icon: Icons.bolt_rounded,
                  ),
                ],
                const SizedBox(height: 14),
                _TotalCard(total: quote.total),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: onSubmit == null
                ? null
                : () async {
                    await onSubmit!();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: theme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(
              buttonLabel,
              style: theme.titleMedium.override(
                color: theme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MatchingWaitingSheet extends StatelessWidget {
  const _MatchingWaitingSheet({
    required this.controller,
    required this.quote,
    required this.isScheduled,
    required this.scheduleLabel,
    required this.quantityLabel,
    required this.serviceLevelLabel,
    required this.onResume,
    required this.onCancel,
  });

  final BookingFlowController controller;
  final BookingQuote quote;
  final bool isScheduled;
  final String scheduleLabel;
  final String quantityLabel;
  final String serviceLevelLabel;
  final VoidCallback onResume;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final draft = controller.draft;

    return Column(
      mainAxisSize: MainAxisSize.min,
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
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Live matching active',
              style: theme.labelLarge.override(
                color: theme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          draft.serviceTitle ?? 'Service request',
          style: theme.titleMedium.override(
            font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.place_rounded, size: 16, color: theme.secondaryText),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '${draft.address.label} — ${draft.address.line1}, ${draft.address.city}',
                style: theme.bodySmall.override(color: theme.secondaryText),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.alternate),
          ),
          child: Column(
            children: [
              _WaitingInfoRow(label: 'Dispatch', value: scheduleLabel),
              const SizedBox(height: 8),
              _WaitingInfoRow(label: quantityLabel, value: '${draft.rooms}'),
              const SizedBox(height: 8),
              _WaitingInfoRow(
                label: serviceLevelLabel,
                value: controller.cleaningTypeLabel,
              ),
              const Divider(height: 20),
              _WaitingInfoRow(
                label: 'Estimated total',
                value: 'PHP ${quote.total.toStringAsFixed(0)}',
                valueStyle: theme.titleMedium.override(
                  fontWeight: FontWeight.w700,
                  color: theme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: onResume,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Return to live matching',
              style: theme.titleSmall.override(
                fontWeight: FontWeight.w700,
                color: theme.onPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: TextButton(
            onPressed: onCancel,
            child: Text(
              'Cancel matching',
              style: theme.bodyMedium.override(
                color: theme.secondaryText,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WaitingInfoRow extends StatelessWidget {
  const _WaitingInfoRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.bodySmall.override(color: theme.secondaryText),
        ),
        Text(
          value,
          style: valueStyle ??
              theme.bodySmall.override(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Text(
      title,
      style: theme.titleSmall.override(fontWeight: FontWeight.w700),
    );
  }
}

class _SimpleNote extends StatelessWidget {
  const _SimpleNote({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: theme.primary, size: 20),
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

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.total});

  final double total;

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Estimated total',
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

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: theme.primary.withValues(alpha: 0.14),
      labelStyle: theme.bodyMedium.override(
        fontWeight: FontWeight.w600,
        color: selected ? theme.primary : theme.primaryText,
      ),
      side: BorderSide(color: selected ? theme.primary : theme.alternate),
    );
  }
}
