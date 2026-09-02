import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:provider/provider.dart';

import '/app_state.dart';
import '/l10n/app_localizations.dart';
import '/models/service_listing.dart';
import 'booking_controller.dart';
import 'booking_models.dart';
import 'booking_success_screen.dart';
import 'live_matching/live_matching_screen.dart';
import 'widgets/booking_flow_route.dart';
import 'widgets/booking_status_scaffold.dart';
import 'widgets/express_checkout_sheet.dart';
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
                      : ExpressCheckoutSheet(
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
    final l10n = AppLocalizations.of(context)!;
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
              content: Text(l10n.bfProviderPrepTime),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
      }
    }

    // Schedule or within-range: proceed with reservation
    final success = await controller.attachReservationToken(l10n);
    if (!context.mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.lastError ?? l10n.bfCouldNotReserve,
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
    final l10n = AppLocalizations.of(context)!;
    final success = await controller.attachLiveSearchToken(l10n);
    if (!context.mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.lastError ?? l10n.bfCouldNotStartLiveMatching,
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
              serviceTitle: controller.selectedServiceLabel(l10n),
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

