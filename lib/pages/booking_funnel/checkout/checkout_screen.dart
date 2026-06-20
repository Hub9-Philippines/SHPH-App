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

          return BookingStatusScaffold(
            showMap: showLiveMap,
            location: location,
            topCard: _CheckoutTopCard(
              serviceTitle: controller.selectedServiceLabel,
              title: isScheduled
                  ? 'Review scheduled booking'
                  : 'Review live request',
              subtitle: isScheduled
                  ? 'Confirm the slot, pinned address, and payment before we reserve it.'
                  : 'Confirm the pinned address and payment before we start searching nearby providers.',
              onBack: () => Navigator.of(context).pop(),
            ),
            center: const _CheckoutPin(),
            bottomSheet: BookingStatusBottomSheet(
              child: _CheckoutSheet(
                controller: controller,
                quote: quote,
                isScheduled: isScheduled,
                isImmediate: isImmediate,
                onSubmit: controller.isSubmitting
                    ? null
                    : () async {
                        await _submit(context, controller);
                      },
                onPickAddress: () async {
                  await _pickAddress(context, controller);
                },
                buttonLabel: _buttonLabel(draft),
                scheduleLabel:
                    isScheduled ? _formatSchedule(draft) : _asapLabel(draft),
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

class _CheckoutTopCard extends StatelessWidget {
  const _CheckoutTopCard({
    required this.serviceTitle,
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  final String serviceTitle;
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryBackground.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
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
                  serviceTitle,
                  style: theme.bodyLarge.override(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: theme.titleMedium.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
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
    );
  }
}

class _CheckoutPin extends StatelessWidget {
  const _CheckoutPin();

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return IgnorePointer(
      child: Container(
        width: 92,
        height: 92,
        decoration: BoxDecoration(
          color: theme.primaryBackground.withValues(alpha: 0.94),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Icon(
          Icons.location_on_rounded,
          color: theme.primary,
          size: 48,
        ),
      ),
    );
  }
}

class _CheckoutSheet extends StatelessWidget {
  const _CheckoutSheet({
    required this.controller,
    required this.quote,
    required this.isScheduled,
    required this.isImmediate,
    required this.buttonLabel,
    required this.scheduleLabel,
    required this.quantityLabel,
    required this.serviceLevelLabel,
    required this.onPickAddress,
    required this.onSubmit,
  });

  final BookingFlowController controller;
  final BookingQuote quote;
  final bool isScheduled;
  final bool isImmediate;
  final String buttonLabel;
  final String scheduleLabel;
  final String quantityLabel;
  final String serviceLevelLabel;
  final Future<void> Function() onPickAddress;
  final Future<void> Function()? onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final draft = controller.draft;

    return Column(
      mainAxisSize: MainAxisSize.min,
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
                      : 'We will search nearby providers around this pinned location as soon as you continue.',
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
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(
              buttonLabel,
              style: theme.titleMedium.override(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
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
            : const Color(0xFFF6FBFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isScheduled
              ? theme.primary.withValues(alpha: 0.28)
              : const Color(0xFFD8E8F8),
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
                  : const Color(0xFFE6F3FF),
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
