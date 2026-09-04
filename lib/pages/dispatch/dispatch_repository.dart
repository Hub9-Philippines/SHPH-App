import 'dart:async';
import 'dart:convert';

import '/api/resources/ondemand_jobs_api.dart';
import '/api/resources/providers_api.dart';
import '/auth/base_auth_user_provider.dart';
import '/models/service_listing.dart';
import '/pages/tm_flow/tm_models.dart';
import '/pages/tm_flow/tm_repository.dart';
import '/services/bookings_service.dart';
import '/services/logging_service.dart';
import '/utils/geo_utils.dart';

/// A [TMRepository] implementation that uses the server-authoritative
/// dispatch engine (job_requests + dispatch_offers + match_best_provider).
///
/// Instead of client-side provider matching, it delegates to the database
/// function `match_best_provider` and the Edge Function for timeouts.
///
/// Drop this in anywhere `PersistentMockTMRepository` was used:
/// ```dart
/// TMFlowController(
///   repository: DispatchTMRepository(),
///   ...
/// )
/// ```
class DispatchTMRepository implements TMRepository {
  DispatchTMRepository({
    BookingsService? bookingsService,
    this.matchPollInterval = const Duration(seconds: 3),
    this.matchTimeout = const Duration(seconds: 120),
    double? clientLatitude,
    double? clientLongitude,
  })  : _bookingsService = bookingsService ?? BookingsService.instance,
        _clientLatitude = clientLatitude,
        _clientLongitude = clientLongitude;

  static const _metaPrefix = 'TM_META:';

  final BookingsService _bookingsService;
  final Duration matchPollInterval;
  final Duration matchTimeout;
  final double? _clientLatitude;
  final double? _clientLongitude;
  bool _dispatchJobAvailable = true;

  static const _terminalStages = {
    'cancelled',
    'completed',
    'paid',
    'rated',
    'rejected',
    'timed_out',
  };

  // ---------------------------------------------------------------
  //  TMRepository implementation
  // ---------------------------------------------------------------

  @override
  Future<String> createBroadcastRequest({
    required ServiceListing service,
    required TMSubCategoryOption subCategory,
  }) async {
    // 1. Create the booking (existing behaviour)
    final booking = await _bookingsService.createBooking(
      serviceListingId: service.id,
      bookingDateTime: DateTime.now(),
      notes: _buildNotes(
        service: service,
        subCategory: subCategory,
        metadata: {
          'flow': 'tm',
          'stage': 'broadcast',
          'search_radius_km': 4,
          'sub_category_id': subCategory.id,
          'sub_category_title': subCategory.title,
          'estimate_min': subCategory.estimateMin,
          'estimate_max': subCategory.estimateMax,
        },
      ),
      totalPrice: (subCategory.estimateMin + subCategory.estimateMax) / 2,
      paymentStatus: 'tm_pending',
    );

    if (booking == null) {
      throw StateError('Failed to create booking for dispatch.');
    }

    // 2. Create a job_request linked to the booking via the SHPH on-demand API
    try {
      final userId = currentUser?.uid;

      if (_clientLatitude == null || _clientLongitude == null) {
        LoggingService.warning(
          'Client coordinates not provided for dispatch — '
          'matching may be inaccurate',
          tag: 'DispatchTMRepository',
        );
      }

      await ShphOnDemandJobsApi.instance.createJob({
        'client_id': userId,
        'service_type': subCategory.title.toLowerCase(),
        'location_lat': _clientLatitude ?? 14.5995,
        'location_lng': _clientLongitude ?? 120.9842,
        'requested_time': DateTime.now().toIso8601String(),
        'status': 'searching',
        'booking_id': booking.id,
      });
    } catch (e) {
      _dispatchJobAvailable = false;
      LoggingService.error(
        'Failed to create job_request for dispatch: $e',
        tag: 'DispatchTMRepository',
      );
      await _persistMetadata(
        booking.id,
        service: service,
        subCategory: subCategory,
        metadata: {'flow': 'tm', 'dispatch_mode': 'fallback'},
      );
    }

    return booking.id;
  }

  @override
  Future<void> updateBroadcastStage({
    required String requestId,
    required ServiceListing service,
    required TMSubCategoryOption subCategory,
    required String stage,
    required int searchRadiusKm,
    required int attempt,
  }) =>
      _persistMetadata(
        requestId,
        service: service,
        subCategory: subCategory,
        metadata: {
          'flow': 'tm',
          'stage': stage,
          'search_radius_km': searchRadiusKm,
          'search_attempt': attempt,
        },
      );

  /// Waits for the server to match a provider via the dispatch engine.
  ///
  /// Polls the linked job_request every [matchPollInterval] until either:
  ///   - a provider is assigned (`status == 'assigned'`),
  ///   - the job times out (`status == 'timed_out'`), or
  ///   - the [matchTimeout] elapses.
  @override
  Future<TMProviderProfile?> findProvider({
    required String requestId,
    required ServiceListing service,
    required TMSubCategoryOption subCategory,
    required int searchRadiusKm,
    required int attempt,
  }) async {
    // Check existing booking first
    final booking = await _bookingsService.getBookingById(requestId);
    if (booking == null) {
      return null;
    }

    final bookingMetadata = _extractMetadata(booking.notes);
    final existingStage = bookingMetadata['stage']?.toString();
    final dispatchMode = bookingMetadata['dispatch_mode']?.toString();
    if (_terminalStages.contains(existingStage) ||
        booking.status == 'cancelled' ||
        booking.status == 'rejected') {
      return null;
    }

    // If already matched (e.g. from a previous attempt), return cached
    final existingProvider = _providerFromMetadata(bookingMetadata);
    if (existingProvider != null && (booking.providerId?.isNotEmpty ?? false)) {
      return existingProvider;
    }

    if (!_dispatchJobAvailable || dispatchMode == 'fallback') {
      return _matchProviderFallback(
        requestId: requestId,
        service: service,
        subCategory: subCategory,
        searchRadiusKm: searchRadiusKm,
        attempt: attempt,
      );
    }

    // Poll the job_request until server matches or times out.
    final timeoutAt = DateTime.now().add(matchTimeout);
    var missingJobRequestCount = 0;

    while (DateTime.now().isBefore(timeoutAt)) {
      await Future<void>.delayed(matchPollInterval);

      // Look up the job_request linked to this booking
      final jobResp =
          await ShphOnDemandJobsApi.instance.getJobStatus(requestId);

      final status = jobResp['status'] as String?;
      final providerId = jobResp['assigned_provider_id'] as String?;

      if (jobResp.isEmpty) {
        missingJobRequestCount++;
        if (missingJobRequestCount >= 2) {
          _dispatchJobAvailable = false;
          return _matchProviderFallback(
            requestId: requestId,
            service: service,
            subCategory: subCategory,
            searchRadiusKm: searchRadiusKm,
            attempt: attempt,
          );
        }
        continue;
      }

      if (status == 'timed_out' || status == 'cancelled') {
        await _persistMetadata(
          requestId,
          service: service,
          subCategory: subCategory,
          metadata: {
            'flow': 'tm',
            'stage': 'timed_out',
            'dispatch_mode': 'server',
          },
        );
        return null;
      }

      if (status == 'assigned' && providerId != null) {
        // Provider was assigned server-side — fetch their profile
        final provider = await _buildProviderProfile(
          providerId,
          searchRadiusKm,
        );
        if (provider == null) {
          return null;
        }
        await _persistMetadata(
          requestId,
          service: service,
          subCategory: subCategory,
          metadata: {
            'flow': 'tm',
            'stage': 'matched',
            'dispatch_mode': 'server',
            'search_radius_km': searchRadiusKm,
            'provider': {
              'id': provider.id,
              'name': provider.name,
              'specialty': provider.specialty,
              'rating': provider.rating,
              'completed_jobs': provider.completedJobs,
              'eta_minutes': provider.etaMinutes,
              'vehicle_label': provider.vehicleLabel,
              'latitude': provider.latitude,
              'longitude': provider.longitude,
            },
          },
          status: 'accepted',
          extraData: {
            'provider_id': provider.id,
            'accepted_at': DateTime.now().toIso8601String(),
          },
        );
        return provider;
      }
    }

    return null;
  }

  @override
  Future<TMHardwareRequest?> getHardwareRequest({
    required String requestId,
    required ServiceListing service,
    required TMSubCategoryOption subCategory,
    required TMProviderProfile provider,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 8));
    final shouldSuggestPart = !subCategory.id.contains('diagnostic');
    if (!shouldSuggestPart) {
      return null;
    }

    final request = TMHardwareRequest(
      id: 'hardware-${service.id}-${subCategory.id}',
      title: 'Hardware Parts Required',
      description:
          '${provider.name} recommends replacing a worn component to complete the ${subCategory.title.toLowerCase()} safely.',
      additionalCost: subCategory.estimateMin <= 500 ? 350 : 480,
    );

    await _persistMetadata(
      requestId,
      service: service,
      subCategory: subCategory,
      metadata: {
        'flow': 'tm',
        'stage': 'hardware_pending',
        'hardware_request': {
          'id': request.id,
          'title': request.title,
          'description': request.description,
          'additional_cost': request.additionalCost,
        },
      },
    );

    return request;
  }

  @override
  Future<bool> updateHardwareApproval({
    required String requestId,
    required ServiceListing service,
    required TMSubCategoryOption subCategory,
    required TMHardwareRequest request,
    required bool approved,
    required double totalPrice,
  }) async {
    try {
      final booking = await _bookingsService.getBookingById(requestId);
      if (booking == null) {
        return false;
      }

      final metadata = _extractMetadata(booking.notes)
        ..['hardware_request_status'] = approved ? 'approved' : 'rejected'
        ..['stage'] = approved ? 'hardware_approved' : 'in_progress'
        ..['hardware_request_reviewed_at'] = DateTime.now().toIso8601String();
      if (approved) {
        metadata['approved_hardware_total'] = totalPrice;
      }

      return await _bookingsService.updateBookingData(requestId, {
        'total_price': approved ? totalPrice : booking.totalPrice,
        'notes': _replaceMetadata(
          booking.notes,
          metadata,
          fallbackHumanReadable: _humanSummary(service, subCategory),
        ),
      });
    } catch (e) {
      LoggingService.error(
        'TM hardware approval persist failed: $e',
        tag: 'DispatchTMRepository',
      );
      return false;
    }
  }

  @override
  Future<bool> completeJob({
    required String requestId,
    required ServiceListing service,
    required TMSubCategoryOption subCategory,
  }) async {
    // Update booking
    final bookingUpdated = await _persistMetadata(
      requestId,
      service: service,
      subCategory: subCategory,
      metadata: {'flow': 'tm', 'stage': 'completed'},
      status: 'completed',
      extraData: {'completed_at': DateTime.now().toIso8601String()},
    );

    // Also mark job_request as completed
    try {
      await ShphOnDemandJobsApi.instance.cancelJob(requestId);
    } catch (e) {
      LoggingService.error(
        'Failed to mark job_request completed: $e',
        tag: 'DispatchTMRepository',
      );
    }

    return bookingUpdated;
  }

  @override
  Future<bool> cancelBroadcast({
    required String requestId,
    required ServiceListing service,
    required TMSubCategoryOption subCategory,
    required String reason,
  }) async {
    // Cancel the job_request first (which triggers server-side cleanup)
    try {
      await ShphOnDemandJobsApi.instance.cancelJob(requestId);
    } catch (e) {
      LoggingService.error(
        'Failed to cancel job_request: $e',
        tag: 'DispatchTMRepository',
      );
    }

    return _persistMetadata(
      requestId,
      service: service,
      subCategory: subCategory,
      metadata: {
        'flow': 'tm',
        'stage': 'cancelled',
        'cancel_reason': reason,
        'cancelled_at': DateTime.now().toIso8601String(),
      },
      status: 'cancelled',
      extraData: {'cancelled_at': DateTime.now().toIso8601String()},
    );
  }

  @override
  Future<bool> processPayment({
    required String requestId,
    required double amount,
    required String paymentMethod,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    final baseUpdated = await _bookingsService.updateBookingData(requestId, {
      'payment_status': 'tm_paid',
      'total_price': amount,
      'completed_at': DateTime.now().toIso8601String(),
    });
    if (!baseUpdated) {
      return false;
    }

    try {
      final booking = await _bookingsService.getBookingById(requestId);
      if (booking == null) {
        return false;
      }
      final metadata = _extractMetadata(booking.notes)
        ..['payment_method'] = paymentMethod
        ..['stage'] = 'paid';
      return await _bookingsService.updateBookingData(requestId, {
        'notes': _replaceMetadata(booking.notes, metadata),
      });
    } catch (e) {
      LoggingService.error(
        'TM payment metadata persist failed: $e',
        tag: 'DispatchTMRepository',
      );
      return false;
    }
  }

  @override
  Future<bool> submitRating({
    required String requestId,
    required String providerId,
    required int rating,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    try {
      final booking = await _bookingsService.getBookingById(requestId);
      if (booking == null) {
        return false;
      }
      final metadata = _extractMetadata(booking.notes)
        ..['provider_rating'] = rating
        ..['provider_id_ref'] = providerId
        ..['stage'] = 'rated';
      return await _bookingsService.updateBookingData(requestId, {
        'notes': _replaceMetadata(booking.notes, metadata),
      });
    } catch (e) {
      LoggingService.error(
        'TM rating persist failed: $e',
        tag: 'DispatchTMRepository',
      );
      return false;
    }
  }

  @override
  Future<TMBookingSnapshot?> fetchBookingSnapshot(String requestId) async {
    try {
      final booking = await _bookingsService.getBookingById(requestId);
      if (booking == null) {
        return null;
      }

      final metadata = _extractMetadata(booking.notes);
      final providerMap = metadata['provider'] as Map<String, dynamic>?;
      final hardwareMap = metadata['hardware_request'] as Map<String, dynamic>?;

      return TMBookingSnapshot(
        requestId: booking.id,
        status: booking.status,
        stage: metadata['stage'] as String?,
        dispatchMode: metadata['dispatch_mode'] as String?,
        paymentStatus: booking.paymentStatus,
        totalPrice: booking.totalPrice,
        provider: _providerFromMap(providerMap),
        hardwareRequest: hardwareMap == null
            ? null
            : TMHardwareRequest(
                id: hardwareMap['id']?.toString() ?? 'hardware',
                title: hardwareMap['title']?.toString() ??
                    'Hardware Parts Required',
                description: hardwareMap['description']?.toString() ?? '',
                additionalCost: _toDouble(hardwareMap['additional_cost']) ?? 0,
              ),
      );
    } catch (e) {
      LoggingService.error(
        'TM snapshot fetch failed: $e',
        tag: 'DispatchTMRepository',
      );
      return null;
    }
  }

  @override
  Stream<TMBookingSnapshot?> watchBookingSnapshot(String requestId) async* {
    while (true) {
      try {
        final booking = await _bookingsService.getBookingById(requestId);
        if (booking == null) {
          yield null;
        } else {
          final metadata = _extractMetadata(booking.notes);
          final providerMap = metadata['provider'] as Map<String, dynamic>?;
          final hardwareMap =
              metadata['hardware_request'] as Map<String, dynamic>?;

          yield TMBookingSnapshot(
            requestId: booking.id,
            status: booking.status,
            stage: metadata['stage'] as String?,
            dispatchMode: metadata['dispatch_mode'] as String?,
            paymentStatus: booking.paymentStatus,
            totalPrice: booking.totalPrice,
            provider: _providerFromMap(providerMap),
            hardwareRequest: hardwareMap == null
                ? null
                : TMHardwareRequest(
                    id: hardwareMap['id']?.toString() ?? 'hardware',
                    title: hardwareMap['title']?.toString() ??
                        'Hardware Parts Required',
                    description: hardwareMap['description']?.toString() ?? '',
                    additionalCost:
                        _toDouble(hardwareMap['additional_cost']) ?? 0,
                  ),
          );
        }
      } catch (e) {
        LoggingService.error(
          'TM snapshot watch failed: $e',
          tag: 'DispatchTMRepository',
        );
        yield null;
      }
      await Future<void>.delayed(matchPollInterval);
    }
  }

  // ---------------------------------------------------------------
  //  Private helpers
  // ---------------------------------------------------------------

  Future<TMProviderProfile?> _buildProviderProfile(
    String providerId,
    int searchRadiusKm,
  ) async {
    try {
      final data = await ShphProvidersApi.instance.getProvider(providerId);
      final profile = data['profile'] is Map<String, dynamic>
          ? data['profile'] as Map<String, dynamic>
          : data;

      if (profile.isEmpty) {
        return null;
      }

      final pLat = (profile['latitude'] as num?)?.toDouble();
      final pLng = (profile['longitude'] as num?)?.toDouble();

      final originLat = _clientLatitude ?? GeoUtils.fallbackLat;
      final originLng = _clientLongitude ?? GeoUtils.fallbackLng;

      final distanceKm = (pLat != null && pLng != null)
          ? GeoUtils.calculateDistance(originLat, originLng, pLat, pLng)
          : searchRadiusKm.toDouble();

      return TMProviderProfile(
        id: providerId,
        name: (profile['display_name'] ?? profile['first_name'] ?? 'Provider')
            .toString(),
        specialty:
            (profile['skill_profession'] ?? 'Service Provider').toString(),
        rating: 0,
        completedJobs: 0,
        etaMinutes: GeoUtils.calculateETA(distanceKm),
        vehicleLabel: distanceKm <= 4
            ? 'Nearby service unit'
            : 'Expanded-area service unit',
        latitude: pLat,
        longitude: pLng,
      );
    } catch (e) {
      LoggingService.error(
        'Failed to build provider profile: $e',
        tag: 'DispatchTMRepository',
      );
      return null;
    }
  }

  Future<bool> _persistMetadata(
    String requestId, {
    required ServiceListing service,
    required TMSubCategoryOption subCategory,
    required Map<String, dynamic> metadata,
    String? status,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      final booking = await _bookingsService.getBookingById(requestId);
      if (booking == null) {
        return false;
      }
      final merged = _extractMetadata(booking.notes)..addAll(metadata);
      return await _bookingsService.updateBookingData(requestId, {
        if (status != null) 'status': status,
        if (extraData != null) ...extraData,
        'notes': _replaceMetadata(
          booking.notes,
          merged,
          fallbackHumanReadable: _humanSummary(service, subCategory),
        ),
      });
    } catch (e) {
      LoggingService.error(
        'TM metadata persist failed: $e',
        tag: 'DispatchTMRepository',
      );
      return false;
    }
  }

  TMProviderProfile? _providerFromMetadata(Map<String, dynamic> metadata) =>
      _providerFromMap(metadata['provider'] as Map<String, dynamic>?);

  TMProviderProfile? _providerFromMap(Map<String, dynamic>? providerMap) {
    if (providerMap == null) {
      return null;
    }
    return TMProviderProfile(
      id: providerMap['id']?.toString() ?? '',
      name: providerMap['name']?.toString() ?? 'Provider',
      specialty: providerMap['specialty']?.toString() ?? '',
      rating: _toDouble(providerMap['rating']) ?? 0,
      completedJobs: (providerMap['completed_jobs'] as num?)?.toInt() ?? 0,
      etaMinutes: (providerMap['eta_minutes'] as num?)?.toInt() ?? 0,
      vehicleLabel: providerMap['vehicle_label']?.toString() ?? 'Service unit',
      latitude: _toDouble(providerMap['latitude']),
      longitude: _toDouble(providerMap['longitude']),
    );
  }

  Future<TMProviderProfile?> _matchProviderFallback({
    required String requestId,
    required ServiceListing service,
    required TMSubCategoryOption subCategory,
    required int searchRadiusKm,
    required int attempt,
  }) async {
    final provider = await _findRealProvider(
      service: service,
      subCategory: subCategory,
      searchRadiusKm: searchRadiusKm,
      attempt: attempt,
    );
    if (provider == null) {
      return null;
    }

    await _persistMetadata(
      requestId,
      service: service,
      subCategory: subCategory,
      metadata: {
        'flow': 'tm',
        'stage': 'matched',
        'dispatch_mode': 'fallback',
        'search_radius_km': searchRadiusKm,
        'provider': {
          'id': provider.id,
          'name': provider.name,
          'specialty': provider.specialty,
          'rating': provider.rating,
          'completed_jobs': provider.completedJobs,
          'eta_minutes': provider.etaMinutes,
          'vehicle_label': provider.vehicleLabel,
          'latitude': provider.latitude,
          'longitude': provider.longitude,
        },
      },
      status: 'accepted',
      extraData: {
        'provider_id': provider.id,
        'accepted_at': DateTime.now().toIso8601String(),
      },
    );

    return provider;
  }

  Future<TMProviderProfile?> _findRealProvider({
    required ServiceListing service,
    required TMSubCategoryOption subCategory,
    required int searchRadiusKm,
    required int attempt,
  }) async {
    try {
      // No SHPH endpoint lists nearby providers by geo radius; fallback
      // matching is disabled until one exists.
      return null;
    } catch (e) {
      LoggingService.error(
        'TM dispatch fallback provider match failed: $e',
        tag: 'DispatchTMRepository',
      );
      return null;
    }
  }

  String _buildNotes({
    required ServiceListing service,
    required TMSubCategoryOption subCategory,
    required Map<String, dynamic> metadata,
  }) {
    final humanReadable = _humanSummary(service, subCategory);
    return '$humanReadable\n$_metaPrefix${jsonEncode(metadata)}';
  }

  String _replaceMetadata(
    String? existingNotes,
    Map<String, dynamic> metadata, {
    String? fallbackHumanReadable,
  }) {
    final raw = existingNotes ?? '';
    final index = raw.indexOf(_metaPrefix);
    final humanReadable = index >= 0
        ? raw.substring(0, index).trimRight()
        : (raw.trim().isNotEmpty ? raw.trim() : fallbackHumanReadable ?? '');
    if (humanReadable.isEmpty) {
      return '$_metaPrefix${jsonEncode(metadata)}';
    }
    return '$humanReadable\n$_metaPrefix${jsonEncode(metadata)}';
  }

  Map<String, dynamic> _extractMetadata(String? notes) {
    final raw = notes ?? '';
    final index = raw.indexOf(_metaPrefix);
    if (index < 0) {
      return <String, dynamic>{};
    }
    final jsonText = raw.substring(index + _metaPrefix.length).trim();
    try {
      final decoded = jsonDecode(jsonText);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {}
    return <String, dynamic>{};
  }

  String _humanSummary(
    ServiceListing service,
    TMSubCategoryOption subCategory,
  ) =>
      [
        'Time-material service request',
        'Service: ${service.title}',
        'Sub-category: ${subCategory.title}',
        'Estimate: ${subCategory.estimateLabel}',
      ].join(' | ');

  double? _toDouble(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }
}
