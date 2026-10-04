import 'package:flutter/material.dart';
import 'dart:async';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/app_state.dart';
import '/l10n/app_localizations.dart';
import '/models/service_listing.dart';
import '/services/logging_service.dart';
import '/theme/app_theme.dart';
import '/utils/geo_utils.dart';
import 'booking_models.dart';
import 'booking_repository.dart';
import 'live_matching/live_matching_screen.dart';
import 'widgets/booking_flow_route.dart';

class BookingFlowController extends ChangeNotifier {
  BookingFlowController({
    BookingRepository? repository,
    BookingDraft? initialDraft,
  })  : repository = repository ?? ShphBookingRepository(),
        _draft = _resolveInitialDraft(initialDraft),
        _isLoadingData = true {
    // Flip the loading flag after the current microtask so the skeleton
    // renders for exactly one frame before the real content appears.
    Future.microtask(() {
      _isLoadingData = false;
      notifyListeners();
    });
  }

  final BookingRepository repository;
  BookingDraft _draft;

  bool _isLoadingData;
  bool get isLoadingData => _isLoadingData;

  bool isSubmitting = false;
  bool isLoadingQuote = false;
  String? quoteError;
  BookingQuote? serverQuote;
  bool liveSearchTimedOut = false;
  bool isMatchingActive = false;
  String? activeReferenceId;
  String? lastError;

  /// Globally tracked active controller during background live matching.
  static BookingFlowController? activeInstance;

  /// ValueNotifier exposing the active background matching controller to home widgets.
  static final ValueNotifier<BookingFlowController?> activeMatchingNotifier =
      ValueNotifier<BookingFlowController?>(null);

  /// Checks if any provider search is currently active in the background.
  static bool get isAnyMatchingActive {
    final active = activeInstance ?? activeMatchingNotifier.value;
    return active != null && active.isMatchingActive && !active.liveSearchTimedOut;
  }

  /// Checks if matching is in progress, and if so shows an advisory collision dialog.
  /// Returns `true` if booking was guarded/intercepted, `false` to proceed.
  static Future<bool> checkAndGuardActiveMatching(BuildContext context) async {
    final active = activeInstance ?? activeMatchingNotifier.value;
    if (active != null && active.isMatchingActive && !active.liveSearchTimedOut) {
      final l10n = AppLocalizations.of(context)!;
      final theme = AppTheme.of(context);
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
          ),
          backgroundColor: theme.secondaryBackground,
          title: Text(
            l10n.bfSearchInProgressTitle,
            style: theme.titleMedium.override(
              font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
          content: Text(
            l10n.bfSearchInProgressBody,
            style: theme.bodyMedium.override(
              font: GoogleFonts.plusJakartaSans(),
              color: theme.secondaryText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                l10n.cancel,
                style: theme.labelLarge.override(
                  color: theme.secondaryText,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: theme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppThemeData.radiusMd),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                restoreActiveMatching(context, active);
              },
              child: Text(
                l10n.bfViewActiveSearch,
                style: theme.labelLarge.override(
                  color: theme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
      return true;
    }
    return false;
  }

  /// Restores live matching full screen from an active controller.
  static void restoreActiveMatching(
    BuildContext context,
    BookingFlowController activeBooking,
  ) {
    activeBooking
      ..setLastSheetExtent(0.45)
      ..setMinimized(false);

    Navigator.of(context, rootNavigator: true).push(
      buildBookingFlowRoute(
        ChangeNotifierProvider<BookingFlowController>.value(
          value: activeBooking,
          child: LiveMatchingScreen(
            bookingDate: activeBooking.draft.scheduledDate ?? DateTime.now(),
            serviceTitle: activeBooking.draft.serviceTitle,
          ),
        ),
      ),
    );
  }

  double _tipAmount = 0.0;
  double get tipAmount => _tipAmount;

  double lastSheetExtent = 0.45;
  int liveMatchingSecondsRemaining = 180;
  bool isMinimized = false;
  bool isSubmittingTip = false;

  void setLastSheetExtent(double extent) {
    lastSheetExtent = extent;
  }

  void setMinimized(bool value) {
    isMinimized = value;
    notifyListeners();
  }

  void setLiveMatchingSecondsRemaining(int seconds) {
    liveMatchingSecondsRemaining = seconds;
  }

  Future<bool> updateTip(double tip) async {
    isSubmittingTip = true;
    notifyListeners();
    try {
      _tipAmount = tip;
      _draft = _draft.copyWith(tipAmount: tip);
      final currentQuote = serverQuote;
      if (currentQuote != null) {
        final subtotal = currentQuote.total - currentQuote.tip;
        serverQuote = BookingQuote(
          basePrice: currentQuote.basePrice,
          roomSubtotal: currentQuote.roomSubtotal,
          cleaningTypeAdjustment: currentQuote.cleaningTypeAdjustment,
          urgencyAdjustment: currentQuote.urgencyAdjustment,
          timePremium: currentQuote.timePremium,
          platformFee: currentQuote.platformFee,
          vat: currentQuote.vat,
          platformFeePercent: currentQuote.platformFeePercent,
          vatPercent: currentQuote.vatPercent,
          tip: tip,
          total: subtotal + tip,
        );
      }
      return true;
    } finally {
      isSubmittingTip = false;
      notifyListeners();
    }
  }

  /// Real on-demand job id from POST /api/services/on-demand/ (null when the
  /// broadcast did not succeed / no category selected). Drives the live
  /// matching UI's authoritative status instead of fabricated numbers.
  String? get liveJobId => _shphRepo?.lastJobId;
  int? get liveProviderCount => _shphRepo?.lastProviderCount;
  double? get liveEstFeeMin => _shphRepo?.lastEstFeeMin;
  double? get liveEstFeeMax => _shphRepo?.lastEstFeeMax;
  bool get liveBroadcastSucceeded => _shphRepo?.lastBroadcastSucceeded ?? false;

  /// Non-null when the last on-demand broadcast attempt failed (API error or
  /// missing job id). Drives the live matching failure card.
  String? get liveBroadcastError => _shphRepo?.lastBroadcastError;

  ShphBookingRepository? get _shphRepo => repository is ShphBookingRepository
      ? repository as ShphBookingRepository
      : null;

  BookingDraft get draft => _draft;

  void setService(ServiceListing service) {
    _draft = _draft.copyWith(
      serviceListingId: service.id,
      serviceTitle: service.title,
      serviceCategoryName: service.categoryName,
      serviceCategoryId: service.category,
      serviceDescription: service.description,
      serviceImageUrl: service.thumbnail,
      serviceBasePrice: service.basePrice,
      servicePriceUnit: service.priceUnit,
    );
    notifyListeners();
    unawaited(refreshQuote());
  }

  BookingQuote get quote {
    final estimate = serverQuote;
    if (estimate != null) {
      return estimate;
    }
    // A zero quote is a loading placeholder, never a price estimate.
    final base = _draft.serviceBasePrice ?? 0.0;
    return BookingQuote(
      basePrice: base,
      total: 0,
    );
  }

  Future<void> refreshQuote() async {
    if (!hasSelectedService) {
      return;
    }
    isLoadingQuote = true;
    quoteError = null;
    notifyListeners();
    try {
      serverQuote = await repository.estimateBooking(_draft);
    } catch (error) {
      serverQuote = null;
      quoteError = error.toString();
    } finally {
      isLoadingQuote = false;
      notifyListeners();
    }
  }

  void setDispatchMode(BookingDispatchMode mode) {
    if (mode == BookingDispatchMode.onDemand) {
      _draft = _draft.copyWith(
        dispatchMode: BookingDispatchMode.onDemand,
        urgency: BookingUrgency.rightNow,
      );
    } else {
      _draft = _draft.copyWith(
        dispatchMode: BookingDispatchMode.scheduled,
        urgency: BookingUrgency.scheduled,
      );
    }
    notifyListeners();
    unawaited(refreshQuote());
  }

  void setUrgency(BookingUrgency urgency) {
    final mode = urgency == BookingUrgency.scheduled
        ? BookingDispatchMode.scheduled
        : BookingDispatchMode.onDemand;
    _draft = _draft.copyWith(
      urgency: urgency,
      dispatchMode: mode,
    );
    notifyListeners();
    unawaited(refreshQuote());
  }

  void setRooms(int rooms) {
    _draft = _draft.copyWith(rooms: rooms.clamp(1, 8));
    notifyListeners();
  }

  void setServiceType(ServiceType type) {
    _draft = _draft.copyWith(cleaningType: type);
    notifyListeners();
  }

  void setPaymentMethod(BookingPaymentMethod method) {
    _draft = _draft.copyWith(paymentMethod: method);
    notifyListeners();
  }

  // --- Checkout spine (spec: service-search-workflow) ---

  int checkoutStep = 0;

  static const int checkoutStepCount = 3;

  void goToStep(int step) {
    checkoutStep = step.clamp(0, checkoutStepCount - 1);
    notifyListeners();
  }

  bool get onFirstCheckoutStep => checkoutStep == 0;

  void setLandmarks(String value) {
    _draft = _draft.copyWith(
      address: BookingAddress(
        label: _draft.address.label,
        line1: _draft.address.line1,
        city: _draft.address.city,
        instructions: value.trim().isEmpty ? null : value.trim(),
      ),
      landmarks: value,
    );
    notifyListeners();
  }

  void setRequireArrivalCode(bool value) {
    _draft = _draft.copyWith(requireArrivalCode: value);
    notifyListeners();
  }

  void setAddress(BookingAddress address) {
    _draft = _draft.copyWith(address: address);
    notifyListeners();
  }

  void setCoordinates({
    required double latitude,
    required double longitude,
  }) {
    _draft = _draft.copyWith(
      latitude: latitude,
      longitude: longitude,
    );
    notifyListeners();
  }

  void setMatchingActive(bool value) {
    isMatchingActive = value;
    if (value) {
      BookingFlowController.activeInstance = this;
      activeMatchingNotifier.value = this;
    } else if (BookingFlowController.activeInstance == this) {
      BookingFlowController.activeInstance = null;
      activeMatchingNotifier.value = null;
    }
    notifyListeners();
  }

  void setLiveSearchTimedOut(bool value) {
    liveSearchTimedOut = value;
    notifyListeners();
  }

  void setSchedule({
    DateTime? date,
    TimeOfDay? time,
    BookingUrgency? urgency,
  }) {
    final resolvedUrgency = urgency ?? _draft.urgency;
    final mode = resolvedUrgency == BookingUrgency.scheduled
        ? BookingDispatchMode.scheduled
        : BookingDispatchMode.onDemand;
    _draft = _draft.copyWith(
      scheduledDate: date ?? _draft.scheduledDate,
      scheduledTime: time ?? _draft.scheduledTime,
      urgency: resolvedUrgency,
      dispatchMode: mode,
    );
    notifyListeners();
    unawaited(refreshQuote());
  }

  String urgencyLabel(AppLocalizations l10n) => switch (_draft.urgency) {
        BookingUrgency.rightNow => l10n.bfRightNow,
        BookingUrgency.laterToday => l10n.bfLaterToday,
        BookingUrgency.scheduled => l10n.bfScheduled,
      };

  String paymentLabel(AppLocalizations l10n) => switch (_draft.paymentMethod) {
        BookingPaymentMethod.gcash => 'GCash',
        BookingPaymentMethod.card => 'Card',
        BookingPaymentMethod.maya => 'Maya',
        BookingPaymentMethod.qrPh => 'QR Ph',
        BookingPaymentMethod.cod => l10n.bfCash,
      };

  String cleaningTypeLabel(AppLocalizations l10n) =>
      switch (_draft.cleaningType) {
        ServiceType.standard => l10n.bfStandardClean,
        ServiceType.deep => l10n.bfDeepClean,
        ServiceType.premium => l10n.bfPremiumClean,
      };

  String selectedServiceLabel(AppLocalizations l10n) =>
      _draft.serviceTitle ?? l10n.bfChooseAService;

  bool get hasSelectedService => _draft.serviceListingId != null;

  static BookingDraft _resolveInitialDraft(BookingDraft? initial) {
    if (initial == null) {
      return const BookingDraft(
        urgency: BookingUrgency.rightNow,
        rooms: 1,
        cleaningType: ServiceType.standard,
        paymentMethod: BookingPaymentMethod.gcash,
        address: BookingAddress(
          label: 'Home',
          line1: '123 Example Street',
          city: 'Metro Manila',
        ),
        latitude: 14.5995,
        longitude: 120.9842,
      );
    }
    if (initial.urgency == BookingUrgency.scheduled &&
        initial.dispatchMode != BookingDispatchMode.scheduled) {
      return initial.copyWith(dispatchMode: BookingDispatchMode.scheduled);
    }
    return initial;
  }

  bool get hasValidSchedule =>
      (_draft.dispatchMode != BookingDispatchMode.scheduled &&
          _draft.urgency != BookingUrgency.scheduled) ||
      (_draft.scheduledDate != null && _draft.scheduledTime != null);

  /// True when the draft carries a usable address for dispatch. Falls back to
  /// true so a minimal default never bricks the funnel during entry testing.
  bool get hasValidAddress =>
      _draft.address.line1.trim().isNotEmpty ||
      _draft.address.label.trim().isNotEmpty;

  Future<bool> attachLiveSearchToken(AppLocalizations l10n) async {
    if (!hasSelectedService) {
      lastError = l10n.bfPleaseChooseService;
      notifyListeners();
      return false;
    }
    if (isSubmitting) {
      return false;
    }
    isSubmitting = true;
    liveSearchTimedOut = false;
    lastError = null;
    notifyListeners();

    try {
      // --- Location validation gate ---
      final appState = FFAppState();
      final rawLat = appState.selectedLatitude;
      final rawLng = appState.selectedLongitude;

      if (!GeoUtils.hasValidLocation(rawLat, rawLng)) {
        LoggingService.debug(
          'No valid pinned location for live search — using Manila fallback',
          tag: 'BookingFlowController',
        );
      }
      final originLat = GeoUtils.hasValidLocation(rawLat, rawLng)
          ? rawLat!
          : GeoUtils.fallbackLat;
      final originLng = GeoUtils.hasValidLocation(rawLat, rawLng)
          ? rawLng!
          : GeoUtils.fallbackLng;

      _draft = _draft.copyWith(
        latitude: originLat,
        longitude: originLng,
      );

      // Proceed straight to the real booking/dispatch call. Backend provider
      // availability and matching are handled server-side; if no provider can
      // be matched the repository surfaces a clear error to the user.
      activeReferenceId = await repository.broadcastLiveSearch(_draft);
      _draft = _draft.copyWith(liveSearchToken: activeReferenceId);
      setMatchingActive(true);
      return true;
    } catch (e) {
      lastError = e.toString();
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> attachReservationToken(AppLocalizations l10n) async {
    if (!hasSelectedService) {
      lastError = l10n.bfPleaseChooseService;
      notifyListeners();
      return false;
    }
    if (!hasValidSchedule) {
      lastError = l10n.bfSelectATime;
      notifyListeners();
      return false;
    }
    if (isSubmitting) {
      return false;
    }
    isSubmitting = true;
    lastError = null;
    notifyListeners();
    try {
      activeReferenceId = await repository.reserveScheduledSlot(_draft);
      _draft = _draft.copyWith(reservationToken: activeReferenceId);
      return true;
    } catch (e) {
      lastError = e.toString();
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
