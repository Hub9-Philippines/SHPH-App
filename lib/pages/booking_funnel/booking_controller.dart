import 'package:flutter/material.dart';

import '/app_state.dart';
import '/l10n/app_localizations.dart';
import '/models/service_listing.dart';
import '/services/logging_service.dart';
import '/utils/geo_utils.dart';
import 'booking_models.dart';
import 'booking_repository.dart';

class BookingFlowController extends ChangeNotifier {
  BookingFlowController({
    BookingRepository? repository,
    BookingDraft? initialDraft,
  })  : repository = repository ?? ShphBookingRepository(),
        _draft = initialDraft ??
            const BookingDraft(
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
            ),
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
  bool liveSearchTimedOut = false;
  bool isMatchingActive = false;
  String? activeReferenceId;
  String? lastError;

  /// Real on-demand job id from POST /api/services/on-demand/ (null when the
  /// broadcast did not succeed / no category selected). Drives the live
  /// matching UI's authoritative status instead of fabricated numbers.
  String? get liveJobId =>
      _shphRepo?.lastJobId;
  int? get liveProviderCount => _shphRepo?.lastProviderCount;
  double? get liveEstFeeMin => _shphRepo?.lastEstFeeMin;
  double? get liveEstFeeMax => _shphRepo?.lastEstFeeMax;
  bool get liveBroadcastSucceeded => _shphRepo?.lastBroadcastSucceeded ?? false;

  ShphBookingRepository? get _shphRepo =>
      repository is ShphBookingRepository
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
  }

  BookingQuote get quote {
    // Anchor the estimate to the service's real base price. There is no
    // server-side quote endpoint, so the room/type/urgency adjustments are
    // client-side estimates; the authoritative total comes from the API after
    // the booking is created. No fabricated flat price is used.
    final base = _draft.serviceBasePrice ?? 0.0;
    final roomIncrement = (base * 0.18).clamp(90.0, 320.0);
    final roomSubtotal = (_draft.rooms - 1) * roomIncrement;
    final cleaningTypeAdjustment = switch (_draft.cleaningType) {
      ServiceType.standard => 0.0,
      ServiceType.deep => base * 0.25,
      ServiceType.premium => base * 0.45,
    };
    final urgencyAdjustment = switch (_draft.urgency) {
      BookingUrgency.rightNow => (base * 0.18).clamp(100.0, 180.0),
      BookingUrgency.laterToday => (base * 0.12).clamp(60.0, 140.0),
      BookingUrgency.scheduled => -(base * 0.08).clamp(40.0, 90.0),
    };

    return BookingQuote(
      basePrice: base,
      roomSubtotal: roomSubtotal,
      cleaningTypeAdjustment: cleaningTypeAdjustment,
      urgencyAdjustment: urgencyAdjustment,
      total: base + roomSubtotal + cleaningTypeAdjustment + urgencyAdjustment,
    );
  }

  void setUrgency(BookingUrgency urgency) {
    _draft = _draft.copyWith(urgency: urgency);
    notifyListeners();
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
    _draft = _draft.copyWith(
      scheduledDate: date ?? _draft.scheduledDate,
      scheduledTime: time ?? _draft.scheduledTime,
      urgency: urgency ?? _draft.urgency,
    );
    notifyListeners();
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

  String cleaningTypeLabel(AppLocalizations l10n) => switch (_draft.cleaningType) {
        ServiceType.standard => l10n.bfStandardClean,
        ServiceType.deep => l10n.bfDeepClean,
        ServiceType.premium => l10n.bfPremiumClean,
      };

  String selectedServiceLabel(AppLocalizations l10n) =>
      _draft.serviceTitle ?? l10n.bfChooseAService;

  bool get hasSelectedService => _draft.serviceListingId != null;

  Future<bool> attachLiveSearchToken(AppLocalizations l10n) async {
    if (!hasSelectedService) {
      lastError = l10n.bfPleaseChooseService;
      notifyListeners();
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
