import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import '/backend/supabase/supabase.dart';
import '/models/service_listing.dart';
import '/services/bookings_service.dart';
import '/services/logging_service.dart';

import 'tm_models.dart';

abstract class TMRepository {
  Future<String> createBroadcastRequest({
    required ServiceListing service,
    required TMSubCategoryOption subCategory,
  });

  Future<void> updateBroadcastStage({
    required String requestId,
    required ServiceListing service,
    required TMSubCategoryOption subCategory,
    required String stage,
    required int searchRadiusKm,
    required int attempt,
  });

  Future<TMProviderProfile?> findProvider({
    required String requestId,
    required ServiceListing service,
    required TMSubCategoryOption subCategory,
    required int searchRadiusKm,
    required int attempt,
  });

  Future<TMHardwareRequest?> getHardwareRequest({
    required String requestId,
    required ServiceListing service,
    required TMSubCategoryOption subCategory,
    required TMProviderProfile provider,
  });

  Future<bool> updateHardwareApproval({
    required String requestId,
    required ServiceListing service,
    required TMSubCategoryOption subCategory,
    required TMHardwareRequest request,
    required bool approved,
    required double totalPrice,
  });

  Future<bool> completeJob({
    required String requestId,
    required ServiceListing service,
    required TMSubCategoryOption subCategory,
  });

  Future<bool> cancelBroadcast({
    required String requestId,
    required ServiceListing service,
    required TMSubCategoryOption subCategory,
    required String reason,
  });

  Future<bool> processPayment({
    required String requestId,
    required double amount,
    required String paymentMethod,
  });

  Future<bool> submitRating({
    required String requestId,
    required String providerId,
    required int rating,
  });

  Future<TMBookingSnapshot?> fetchBookingSnapshot(String requestId);

  Stream<TMBookingSnapshot?> watchBookingSnapshot(String requestId);
}

class PersistentMockTMRepository implements TMRepository {
  PersistentMockTMRepository({
    BookingsService? bookingsService,
    this.broadcastLatency = const Duration(milliseconds: 500),
    this.providerMatchLatency = const Duration(seconds: 10),
    this.hardwareLatency = const Duration(seconds: 8),
    this.paymentLatency = const Duration(seconds: 2),
  }) : _bookingsService = bookingsService ?? BookingsService.instance;

  static const _metaPrefix = 'TM_META:';

  final BookingsService _bookingsService;
  final Duration broadcastLatency;
  final Duration providerMatchLatency;
  final Duration hardwareLatency;
  final Duration paymentLatency;
  final _random = math.Random();

  static const _terminalStages = {
    'cancelled',
    'completed',
    'paid',
    'rated',
    'rejected',
  };

  @override
  Future<String> createBroadcastRequest({
    required ServiceListing service,
    required TMSubCategoryOption subCategory,
  }) async {
    await Future<void>.delayed(broadcastLatency);

    final booking = await _bookingsService.createBooking(
      serviceListingId: service.id,
      bookingDate: DateTime.now(),
      bookingTime: _timeString(DateTime.now()),
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

    if (booking != null) {
      return booking.id;
    }

    return 'tm_local_${service.id}_${subCategory.id}_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<void> updateBroadcastStage({
    required String requestId,
    required ServiceListing service,
    required TMSubCategoryOption subCategory,
    required String stage,
    required int searchRadiusKm,
    required int attempt,
  }) => _persistMetadata(
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

  @override
  Future<TMProviderProfile?> findProvider({
    required String requestId,
    required ServiceListing service,
    required TMSubCategoryOption subCategory,
    required int searchRadiusKm,
    required int attempt,
  }) async {
    await Future<void>.delayed(providerMatchLatency);

    final booking = await _bookingsService.getBookingById(requestId);
    if (booking == null) {
      return null;
    }

    final existingMetadata = _extractMetadata(booking.notes);
    final existingStage = existingMetadata['stage']?.toString();
    if (_terminalStages.contains(existingStage) ||
        booking.status == 'cancelled' ||
        booking.status == 'rejected') {
      return null;
    }

    final existingProvider = _providerFromMetadata(existingMetadata);
    if (existingProvider != null && (booking.providerId?.isNotEmpty ?? false)) {
      return existingProvider;
    }

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
        'search_radius_km': searchRadiusKm,
        'provider': {
          'id': provider.id,
          'name': provider.name,
          'specialty': provider.specialty,
          'rating': provider.rating,
          'completed_jobs': provider.completedJobs,
          'eta_minutes': provider.etaMinutes,
          'vehicle_label': provider.vehicleLabel,
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

  @override
  Future<TMHardwareRequest?> getHardwareRequest({
    required String requestId,
    required ServiceListing service,
    required TMSubCategoryOption subCategory,
    required TMProviderProfile provider,
  }) async {
    await Future<void>.delayed(hardwareLatency);
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

      final updated = await _bookingsService.updateBookingData(requestId, {
        'total_price': approved ? totalPrice : booking.totalPrice,
        'notes': _replaceMetadata(
          booking.notes,
          metadata,
          fallbackHumanReadable: _humanSummary(service, subCategory),
        ),
      });
      return updated;
    } catch (e) {
      LoggingService.error(
        'TM hardware approval persist failed: $e',
        tag: 'TMRepository',
      );
      return false;
    }
  }

  @override
  Future<bool> completeJob({
    required String requestId,
    required ServiceListing service,
    required TMSubCategoryOption subCategory,
  }) => _persistMetadata(
    requestId,
    service: service,
    subCategory: subCategory,
    metadata: {'flow': 'tm', 'stage': 'completed'},
    status: 'completed',
    extraData: {'completed_at': DateTime.now().toIso8601String()},
  );

  @override
  Future<bool> cancelBroadcast({
    required String requestId,
    required ServiceListing service,
    required TMSubCategoryOption subCategory,
    required String reason,
  }) => _persistMetadata(
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

  @override
  Future<bool> processPayment({
    required String requestId,
    required double amount,
    required String paymentMethod,
  }) async {
    await Future<void>.delayed(paymentLatency);
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
        tag: 'TMRepository',
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
      LoggingService.error('TM rating persist failed: $e', tag: 'TMRepository');
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
                title:
                    hardwareMap['title']?.toString() ??
                    'Hardware Parts Required',
                description: hardwareMap['description']?.toString() ?? '',
                additionalCost: _toDouble(hardwareMap['additional_cost']) ?? 0,
              ),
      );
    } catch (e) {
      LoggingService.error('TM snapshot fetch failed: $e', tag: 'TMRepository');
      return null;
    }
  }

  @override
  Stream<TMBookingSnapshot?> watchBookingSnapshot(String requestId) => Supabase
      .instance
      .client
      .from('bookings')
      .stream(primaryKey: ['id'])
      .eq('id', requestId)
      .map((rows) {
        if (rows.isEmpty) {
          return null;
        }

        final booking = BookingsRow(rows.first);
        final metadata = _extractMetadata(booking.notes);
        final providerMap = metadata['provider'] as Map<String, dynamic>?;
        final hardwareMap =
            metadata['hardware_request'] as Map<String, dynamic>?;

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
                  title:
                      hardwareMap['title']?.toString() ??
                      'Hardware Parts Required',
                  description: hardwareMap['description']?.toString() ?? '',
                  additionalCost:
                      _toDouble(hardwareMap['additional_cost']) ?? 0,
                ),
        );
      });

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
        tag: 'TMRepository',
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
    );
  }

  Future<TMProviderProfile?> _findRealProvider({
    required ServiceListing service,
    required TMSubCategoryOption subCategory,
    required int searchRadiusKm,
    required int attempt,
  }) async {
    try {
      final profiles = await Supabase.instance.client
          .from('profiles')
          .select(
            'id, display_name, first_name, skill_profession, latitude, longitude, is_verified',
          )
          .eq('role', 'provider')
          .limit(attempt == 1 ? 25 : 50);

      final candidates =
          List<Map<String, dynamic>>.from(
            profiles,
          ).where(_isEligibleProvider).toList()..sort(
            (a, b) =>
                _providerScore(
                  b,
                  service: service,
                  subCategory: subCategory,
                ).compareTo(
                  _providerScore(a, service: service, subCategory: subCategory),
                ),
          );

      if (candidates.isEmpty) {
        return null;
      }

      final best = candidates.first;
      return TMProviderProfile(
        id: best['id']?.toString() ?? '',
        name: (best['display_name'] ?? best['first_name'] ?? 'Provider')
            .toString(),
        specialty: (best['skill_profession'] ?? subCategory.title).toString(),
        rating: best['is_verified'] == true ? 4.9 : 4.7,
        completedJobs: 120 + _random.nextInt(120),
        etaMinutes: searchRadiusKm <= 4 ? 12 : 18,
        vehicleLabel: searchRadiusKm <= 4
            ? 'Nearby service unit'
            : 'Expanded-area service unit',
      );
    } catch (e) {
      LoggingService.error(
        'TM real provider match failed: $e',
        tag: 'TMRepository',
      );
      return null;
    }
  }

  bool _isEligibleProvider(Map<String, dynamic> profile) {
    final id = profile['id']?.toString();
    if (id == null || id.isEmpty) {
      return false;
    }
    return true;
  }

  int _providerScore(
    Map<String, dynamic> profile, {
    required ServiceListing service,
    required TMSubCategoryOption subCategory,
  }) {
    final profession = (profile['skill_profession']?.toString() ?? '')
        .toLowerCase();
    final serviceTitle = service.title.toLowerCase();
    final category = (service.categoryName ?? '').toLowerCase();
    final subCategoryTitle = subCategory.title.toLowerCase();

    var score = 0;
    if (profession.contains(subCategoryTitle)) {
      score += 6;
    }
    if (profession.contains(serviceTitle)) {
      score += 4;
    }
    if (category.isNotEmpty && profession.contains(category)) {
      score += 3;
    }
    if (profile['is_verified'] == true) {
      score += 2;
    }
    return score;
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
  ) => [
    'Time-material service request',
    'Service: ${service.title}',
    'Sub-category: ${subCategory.title}',
    'Estimate: ${subCategory.estimateLabel}',
  ].join(' | ');

  String _timeString(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

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
