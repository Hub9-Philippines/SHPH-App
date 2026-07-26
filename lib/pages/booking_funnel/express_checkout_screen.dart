import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:provider/provider.dart';

import '/app_state.dart';
import '/backend/supabase/supabase.dart';
import '/components/edit_address/edit_address_widget.dart';
import '/models/service_listing.dart';
import '/theme/app_theme.dart';
import 'booking_controller.dart';
import 'booking_models.dart';
import 'booking_success_screen.dart';
import 'live_matching/live_matching_screen.dart';
import 'widgets/booking_flow_route.dart';
import 'widgets/booking_status_scaffold.dart';
import 'widgets/express_shimmer.dart';

class ExpressCheckoutScreen extends StatelessWidget {
  const ExpressCheckoutScreen({
    super.key,
    required this.service,
  });

  final ServiceListing service;

  @override
  Widget build(BuildContext context) => Consumer<BookingFlowController>(
        builder: (context, controller, _) {
          final draft = controller.draft;
          final quote = controller.quote;
          final isScheduled = draft.urgency == BookingUrgency.scheduled;
          final location = gmaps.LatLng(draft.latitude, draft.longitude);

          void onBack() => Navigator.of(context).pop();

          Future<void> onConfirm() async {
            await _handleConfirm(context, controller);
          }

          return PopScope(
            canPop: !controller.isSubmitting,
            child: BookingStatusScaffold(
              showMap: true,
              location: location,
              markerHue: gmaps.BitmapDescriptor.hueRose,
              bottomSheet: BookingStatusBottomSheet(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: controller.isLoadingData
                      ? const ExpressCheckoutSkeleton(
                          key: ValueKey('skeleton'),
                        )
                      : _ExpressSheet(
                          key: ValueKey('content'),
                          controller: controller,
                          quote: quote,
                          isScheduled: isScheduled,
                          service: service,
                          onBack: onBack,
                          onConfirm: onConfirm,
                        ),
                ),
              ),
            ),
          );
        },
      );

  Future<void> _handleConfirm(
    BuildContext context,
    BookingFlowController controller,
  ) async {
    final urgency = controller.draft.urgency;

    // ASAP: bypass buffer, go straight to LiveMatchingScreen
    if (urgency == BookingUrgency.rightNow) {
      await _startLiveSearch(context, controller);
      return;
    }

    // Custom schedule: check 2-hour buffer
    final now = DateTime.now();
    final scheduledDateTime = _scheduledDateTime(controller.draft);
    if (scheduledDateTime != null) {
      final diffMinutes = scheduledDateTime.difference(now).inMinutes;
      if (diffMinutes < 120) {
        final appState = FFAppState();
        if (appState.nearestProviderDistance > 4.0) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Our closest professional needs at least 2 hours to prepare '
                'and travel to your location. Please adjust your time selection.',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
      }
    }

    // Schedule or within-range: proceed with reservation
    final success = await controller.attachReservationToken();
    if (!context.mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.lastError ?? 'Could not reserve. Please try again.',
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
  }

  Future<void> _startLiveSearch(
    BuildContext context,
    BookingFlowController controller,
  ) async {
    final success = await controller.attachLiveSearchToken();
    if (!context.mounted) return;
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
              serviceTitle: controller.selectedServiceLabel,
            ),
          ),
        ),
      ),
    );
  }

  DateTime? _scheduledDateTime(BookingDraft draft) {
    if (draft.scheduledDate != null && draft.scheduledTime != null) {
      return DateTime(
        draft.scheduledDate!.year,
        draft.scheduledDate!.month,
        draft.scheduledDate!.day,
        draft.scheduledTime!.hour,
        draft.scheduledTime!.minute,
      );
    }
    return null;
  }

  DateTime _liveMatchingDate(BookingDraft draft) =>
      _scheduledDateTime(draft) ?? draft.scheduledDate ?? DateTime.now();
}

class _ExpressSheet extends StatelessWidget {
  const _ExpressSheet({
    super.key,
    required this.controller,
    required this.quote,
    required this.isScheduled,
    required this.service,
    required this.onBack,
    required this.onConfirm,
  });

  final BookingFlowController controller;
  final BookingQuote quote;
  final bool isScheduled;
  final ServiceListing service;
  final VoidCallback onBack;
  final Future<void> Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final draft = controller.draft;
    final urgencyLabel = draft.urgency == BookingUrgency.rightNow
        ? 'ASAP'
        : draft.urgency == BookingUrgency.laterToday
            ? 'Later today'
            : 'Scheduled';

    return Column(
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
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: controller.isSubmitting ? null : onBack,
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
                    service.title,
                    style: theme.titleMedium.override(
                      font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Confirm your booking details below.',
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
                _SectionRow(
                  icon: Icons.place_rounded,
                  title: draft.address.label,
                  subtitle: '${draft.address.line1}, ${draft.address.city}',
                  onTap: () => _editLocation(context, controller),
                ),
                const SizedBox(height: 10),
                _SectionRow(
                  icon: Icons.schedule_rounded,
                  title: urgencyLabel,
                  subtitle: _timeSubtitle(draft),
                  onTap: () => _editTime(context, controller),
                ),
                const SizedBox(height: 10),
                _SectionRow(
                  icon: Icons.tune_rounded,
                  title: '${draft.rooms} ${_unitLabel(draft)}',
                  subtitle: controller.cleaningTypeLabel,
                  onTap: () => _editScope(context, controller),
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
            onPressed: controller.isSubmitting ? null : onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: controller.isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    isScheduled ? 'Confirm & Reserve Slot' : 'Confirm Booking',
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

  String _unitLabel(BookingDraft draft) {
    final category = (draft.serviceCategoryName ?? '').toLowerCase();
    if (category.contains('clean')) return 'rooms';
    if (category.contains('repair') || category.contains('install')) {
      return 'items';
    }
    return 'units';
  }

  String _timeSubtitle(BookingDraft draft) {
    if (draft.urgency == BookingUrgency.rightNow) {
      return 'Finding nearest provider now';
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

  Future<void> _editLocation(
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
    if (!context.mounted || result == null) return;

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
    final lat = appState.selectedLatitude ?? result.latitude;
    final lng = appState.selectedLongitude ?? result.longitude;
    if (lat != null && lng != null) {
      controller.setCoordinates(latitude: lat, longitude: lng);
    }
  }

  Future<void> _editTime(
    BuildContext context,
    BookingFlowController controller,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TimeEditSheet(controller: controller),
    );
  }

  Future<void> _editScope(
    BuildContext context,
    BookingFlowController controller,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ScopeEditSheet(controller: controller),
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

class _SectionRow extends StatelessWidget {
  const _SectionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return InkWell(
      onTap: onTap,
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
                    style:
                        theme.bodyMedium.override(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.bodySmall.override(color: theme.secondaryText),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: theme.textTertiary),
          ],
        ),
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
        border: Border.all(color: theme.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Estimated total',
            style: theme.bodyLarge.override(fontWeight: FontWeight.w600),
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

// ── Time edit bottom sheet ──

class _TimeEditSheet extends StatelessWidget {
  const _TimeEditSheet({required this.controller});

  final BookingFlowController controller;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
          Text(
            'When do you need the service?',
            style: theme.titleLarge.override(
              font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 16),
          _TimeOption(
            icon: Icons.flash_on_rounded,
            title: 'Right now',
            subtitle: 'ASAP dispatch — nearest provider',
            selected: controller.draft.urgency == BookingUrgency.rightNow,
            onTap: () {
              controller.setUrgency(BookingUrgency.rightNow);
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 10),
          _TimeOption(
            icon: Icons.today_rounded,
            title: 'Later today',
            subtitle: 'Schedule for a specific time today',
            selected: controller.draft.urgency == BookingUrgency.laterToday,
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (time != null) {
                controller.setSchedule(
                  time: time,
                  urgency: BookingUrgency.laterToday,
                );
                if (context.mounted) Navigator.of(context).pop();
              }
            },
          ),
          const SizedBox(height: 10),
          _TimeOption(
            icon: Icons.calendar_month_rounded,
            title: 'Schedule another day',
            subtitle: 'Pick a future date and time',
            selected: controller.draft.urgency == BookingUrgency.scheduled,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 60)),
              );
              if (date == null || !context.mounted) return;
              final time = await showTimePicker(
                context: context,
                initialTime: const TimeOfDay(hour: 9, minute: 0),
              );
              if (time != null) {
                controller.setSchedule(
                  date: date,
                  time: time,
                  urgency: BookingUrgency.scheduled,
                );
                if (context.mounted) Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _TimeOption extends StatelessWidget {
  const _TimeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? theme.primary.withValues(alpha: 0.08)
              : theme.secondaryBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? theme.primary : theme.alternate,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: selected
                    ? theme.primary.withValues(alpha: 0.14)
                    : theme.alternate.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: selected ? theme.primary : null),
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
                      color: selected ? theme.primary : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.bodySmall.override(color: theme.secondaryText),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: theme.primary, size: 22),
          ],
        ),
      ),
    );
  }
}

// ── Scope edit bottom sheet ──

class _ScopeEditSheet extends StatefulWidget {
  const _ScopeEditSheet({required this.controller});

  final BookingFlowController controller;

  @override
  State<_ScopeEditSheet> createState() => _ScopeEditSheetState();
}

class _ScopeEditSheetState extends State<_ScopeEditSheet> {
  late int _rooms;
  late int _serviceTypeIndex;

  static const List<ServiceType> _serviceTypes = [
    ServiceType.standard,
    ServiceType.deep,
    ServiceType.premium,
  ];

  @override
  void initState() {
    super.initState();
    _rooms = widget.controller.draft.rooms;
    _serviceTypeIndex =
        _serviceTypes.indexOf(widget.controller.draft.cleaningType);
    if (_serviceTypeIndex < 0) _serviceTypeIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final draft = widget.controller.draft;
    final category = (draft.serviceCategoryName ?? '').toLowerCase();
    final unitLabel = category.contains('clean') ? 'rooms' : 'units';
    final levelLabel =
        category.contains('clean') ? 'Cleaning type' : 'Service level';

    return Container(
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
          Text(
            'Scope & level',
            style: theme.titleLarge.override(
              font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 16),
          // Quantity stepper
          Row(
            children: [
              Text(
                'Quantity ($unitLabel)',
                style: theme.bodyLarge.override(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              IconButton(
                onPressed: _rooms > 1 ? () => setState(() => _rooms--) : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$_rooms',
                  style: theme.titleLarge.override(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: _rooms < 8 ? () => setState(() => _rooms++) : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            levelLabel,
            style: theme.bodyLarge.override(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(3, (index) {
              final type = _serviceTypes[index];
              final selected = index == _serviceTypeIndex;
              return ChoiceChip(
                label: Text(_serviceTypeLabel(type)),
                selected: selected,
                onSelected: (_) => setState(() => _serviceTypeIndex = index),
                selectedColor: theme.primary.withValues(alpha: 0.14),
                labelStyle: theme.bodyMedium.override(
                  fontWeight: FontWeight.w600,
                  color: selected ? theme.primary : theme.primaryText,
                ),
                side: BorderSide(
                  color: selected ? theme.primary : theme.alternate,
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                widget.controller.setRooms(_rooms);
                widget.controller
                    .setServiceType(_serviceTypes[_serviceTypeIndex]);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }

  String _serviceTypeLabel(ServiceType type) => switch (type) {
        ServiceType.standard => 'Standard',
        ServiceType.deep => 'Deep',
        ServiceType.premium => 'Premium',
      };
}
