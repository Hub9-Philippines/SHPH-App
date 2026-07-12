import 'package:flutter/material.dart';

import '/app_state.dart';
import '/models/service_listing.dart';
import '/services/bookings_service.dart';
import '/services/logging_service.dart';
import '/services/nearby_pro_mock_data.dart';
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

  Map<String, dynamic>? _estimate;

  bool isSubmitting = false;
  bool liveSearchTimedOut = false;
  bool isMatchingActive = false;
  String? activeReferenceId;
  String? lastError;

  BookingDraft get draft => _draft;

  Future<void> loadEstimate() async {
    final listingId = _draft.serviceListingId;
    if (listingId == null) return;

    try {
      final result = await BookingsService.instance.estimateBooking(
        listingId: listingId,
        scheduledDate: _draft.scheduledDate
            ?.toIso8601String()
            .split('T')
            .first,
        scheduledTime: _draft.scheduledTime != null
            ? '${_draft.scheduledTime!.hour.toString().padLeft(2, '0')}:${_draft.scheduledTime!.minute.toString().padLeft(2, '0')}'
            : null,
      );
      _estimate = result;
      notifyListeners();
    } catch (_) {
      // Silently fall back to local estimate
    }
  }

  void setService(ServiceListing service) {
    _draft = _draft.copyWith(
      serviceListingId: service.id,
      serviceTitle: service.title,
      serviceCategoryName: service.categoryName,
      serviceDescription: service.description,
      serviceImageUrl: service.thumbnail,
      serviceBasePrice: service.basePrice,
      servicePriceUnit: service.priceUnit,
    );
    notifyListeners();
  }

  BookingQuote get quote {
    if (_estimate != null) {
      final apiTotal = (_estimate!['total_price'] as num?)?.toDouble();
      final apiBase = (_estimate!['base_price'] as num?)?.toDouble();
      final apiAdjustments =
          (_estimate!['adjustments'] as num?)?.toDouble();
      if (apiTotal != null) {
        return BookingQuote(
          basePrice: apiBase ?? _draft.serviceBasePrice ?? 599.0,
          roomSubtotal: 0,
          cleaningTypeAdjustment: apiAdjustments ?? 0,
          urgencyAdjustment: 0,
          total: apiTotal,
        );
      }
    }

    final base = _draft.serviceBasePrice ?? 599.0;
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

  String get urgencyLabel => switch (_draft.urgency) {
        BookingUrgency.rightNow => 'Right now',
        BookingUrgency.laterToday => 'Later today',
        BookingUrgency.scheduled => 'Scheduled',
      };

  String get paymentLabel => switch (_draft.paymentMethod) {
        BookingPaymentMethod.gcash => 'GCash',
        BookingPaymentMethod.card => 'Card',
        BookingPaymentMethod.cod => 'COD',
      };

  String get cleaningTypeLabel => switch (_draft.cleaningType) {
        ServiceType.standard => 'Standard clean',
        ServiceType.deep => 'Deep clean',
        ServiceType.premium => 'Premium clean',
      };

  String get selectedServiceLabel => _draft.serviceTitle ?? 'Choose a service';

  bool get hasSelectedService => _draft.serviceListingId != null;

  Future<bool> attachLiveSearchToken() async {
    if (!hasSelectedService) {
      lastError = 'Please choose a service before continuing.';
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

      // --- Proximity gate: ensure at least one provider exists within 10 km ---
      const nearbyThresholdKm = 10.0;
      final mockNearby = NearbyProMockData.instance.generateNearbyPros(
        serviceId: _draft.serviceListingId ?? 0,
        category: _draft.serviceCategoryName ?? 'Service',
        count: 3,
      );
      final hasProviderNearby = mockNearby.any((pro) {
        final proLat = pro['providerLatitude'] as double?;
        final proLng = pro['providerLongitude'] as double?;
        if (proLat == null || proLng == null) return false;
        final dist = GeoUtils.calculateDistance(
          originLat, originLng, proLat, proLng,
        );
        return dist <= nearbyThresholdKm;
      });

      if (!hasProviderNearby) {
        lastError =
            'No providers available within 10 km of your location. '
            'Try expanding your search area or scheduling for later.';
        isSubmitting = false;
        notifyListeners();
        return false;
      }
      // --- End proximity gate ---

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

  Future<bool> attachReservationToken() async {
    if (!hasSelectedService) {
      lastError = 'Please choose a service before continuing.';
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
