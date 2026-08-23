import 'dart:convert';

import '/api/bridges/api_row_mapper.dart';
import '/api/resources/bookings_api.dart';
import '/api/resources/earnings_api.dart';
import '/services/logging_service.dart';

/// Service for managing pro/provider bookings, jobs, schedule and earnings
class ProBookingsService {
  ProBookingsService._();
  static final ProBookingsService instance = ProBookingsService._();
  static const _tmMetaPrefix = 'TM_META:';

  final _bookingsApi = ShphBookingsApi.instance;
  final _earningsApi = ShphEarningsApi.instance;

  bool isTimeMaterialBooking(Map<String, dynamic> booking) =>
      tmMetadata(booking)['flow'] == 'tm';

  Map<String, dynamic> tmMetadata(Map<String, dynamic> booking) {
    final notes = booking['notes'] as String?;
    if (notes == null || !notes.contains(_tmMetaPrefix)) {
      return <String, dynamic>{};
    }
    final index = notes.indexOf(_tmMetaPrefix);
    final jsonText = notes.substring(index + _tmMetaPrefix.length).trim();
    try {
      final decoded = jsonDecode(jsonText);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }
    } catch (_) {}
    return <String, dynamic>{};
  }

  String? tmSubCategoryTitle(Map<String, dynamic> booking) =>
      tmMetadata(booking)['sub_category_title'] as String?;

  String? tmStage(Map<String, dynamic> booking) =>
      tmMetadata(booking)['stage'] as String?;

  String tmStageLabel(Map<String, dynamic> booking) {
    final stage = tmStage(booking) ?? '';
    return switch (stage) {
      'broadcast' => 'Awaiting provider',
      'matched' => 'Matched',
      'provider_accepted' => 'Accepted',
      'in_progress' => 'In progress',
      'hardware_pending' => 'Hardware pending',
      'hardware_approved' => 'Hardware approved',
      'completed' => 'Completed',
      'paid' => 'Paid',
      'rated' => 'Rated',
      _ => 'TM request',
    };
  }

  Future<bool> markJobInProgress(String bookingId) =>
      _updateBookingAndTmMetadata(
        bookingId,
        status: 'in_progress',
        metadataUpdates: {
          'flow': 'tm',
          'stage': 'in_progress',
        },
      );

  Future<bool> requestTMHardware({
    required String bookingId,
    required String title,
    required String description,
    required double additionalCost,
  }) =>
      _updateBookingAndTmMetadata(
        bookingId,
        status: 'in_progress',
        metadataUpdates: {
          'flow': 'tm',
          'stage': 'hardware_pending',
          'hardware_request': {
            'id': 'provider-${DateTime.now().millisecondsSinceEpoch}',
            'title': title,
            'description': description,
            'additional_cost': additionalCost,
          },
        },
      );

  Future<List<Map<String, dynamic>>> _fetchProviderBookingsFromApi() async {
    final page = await _bookingsApi.listBookings();
    return page.results
        .map((booking) => ApiRowMapper.bookingToRow(booking).data)
        .toList();
  }

  /// Get pending job requests for the provider
  Future<List<Map<String, dynamic>>> getPendingJobRequests() async {
    try {
      final bookings = await _fetchProviderBookingsFromApi();
      return bookings
          .where((booking) => booking['status'] == 'pending')
          .toList();
    } catch (e) {
      LoggingService.error('getPendingJobRequests failed: $e',
          tag: 'ProBookingsService');
      return [];
    }
  }

  /// Get scheduled/accepted jobs for the provider
  Future<List<Map<String, dynamic>>> getScheduledJobs() async {
    try {
      final bookings = await _fetchProviderBookingsFromApi();
      return bookings.where((booking) {
        final status = booking['status'] as String?;
        return status == 'accepted' ||
            status == 'confirmed' ||
            status == 'in_progress' ||
            status == 'completed';
      }).toList();
    } catch (e) {
      LoggingService.error('getScheduledJobs failed: $e',
          tag: 'ProBookingsService');
      return [];
    }
  }

  /// Get earnings summary for the provider
  Future<Map<String, dynamic>> getEarningsSummary() async {
    try {
      final summary = await _earningsApi.getSummary();
      return {
        'totalEarnings':
            _toDouble(summary['total_earnings']) ?? _toDouble(summary['total']) ?? 0.0,
        'thisMonth': _toDouble(summary['this_month']) ?? 0.0,
        'lastMonth': _toDouble(summary['last_month']) ?? 0.0,
        'thisWeek': _toDouble(summary['this_week']) ?? 0.0,
        'lastWeek': _toDouble(summary['last_week']) ?? 0.0,
        'totalJobs': summary['total_jobs'] as num? ?? 0,
        'weeklyData': summary['weekly_data'] as List? ?? [],
        'recentTransactions':
            summary['recent_transactions'] as List? ?? [],
      };
    } catch (e) {
      LoggingService.error('getEarningsSummary failed: $e',
          tag: 'ProBookingsService');
      return {
        'totalEarnings': 0.0,
        'thisMonth': 0.0,
        'lastMonth': 0.0,
        'thisWeek': 0.0,
        'lastWeek': 0.0,
        'totalJobs': 0,
        'weeklyData': [],
        'recentTransactions': [],
      };
    }
  }

  /// Accept a job request
  Future<bool> acceptJob(String bookingId) async {
    try {
      await _bookingsApi.acceptBooking(bookingId);
      await _updateBookingAndTmMetadata(
        bookingId,
        metadataUpdates: {
          'flow': 'tm',
          'stage': 'provider_accepted',
        },
      );
      LoggingService.info('Job accepted: $bookingId', tag: 'ProBookingsService');
      return true;
    } catch (e) {
      LoggingService.error('Error accepting job: $e',
          tag: 'ProBookingsService');
      return false;
    }
  }

  /// Reject a job request
  Future<bool> rejectJob(String bookingId, {String? reason}) async {
    try {
      await _bookingsApi.rejectBooking(bookingId, reason: reason);
      await _updateBookingAndTmMetadata(
        bookingId,
        metadataUpdates: {
          'flow': 'tm',
          'stage': 'rejected',
          if (reason != null && reason.isNotEmpty) 'rejection_reason': reason,
        },
      );
      LoggingService.info('Job rejected: $bookingId', tag: 'ProBookingsService');
      return true;
    } catch (e) {
      LoggingService.error('Error rejecting job: $e',
          tag: 'ProBookingsService');
      return false;
    }
  }

  /// Mark job as completed
  Future<bool> completeJob(String bookingId) async {
    try {
      await _bookingsApi.updateBooking(
        bookingId,
        data: {'status': 'completed'},
      );
      await _updateBookingAndTmMetadata(
        bookingId,
        metadataUpdates: {
          'flow': 'tm',
          'stage': 'completed',
        },
      );
      LoggingService.info('Job completed: $bookingId',
          tag: 'ProBookingsService');
      return true;
    } catch (e) {
      LoggingService.error('Error completing job: $e',
          tag: 'ProBookingsService');
      return false;
    }
  }

  /// Get booking counts by status
  Future<Map<String, int>> getBookingCounts() async {
    try {
      final bookings = await _fetchProviderBookingsFromApi();
      var pending = 0;
      var accepted = 0;
      var completed = 0;

      for (final booking in bookings) {
        final status = booking['status'] as String?;
        if (status == 'pending') {
          pending++;
        }
        if (status == 'accepted' ||
            status == 'confirmed' ||
            status == 'in_progress') {
          accepted++;
        }
        if (status == 'completed') {
          completed++;
        }
      }

      return {
        'pending': pending,
        'accepted': accepted,
        'completed': completed,
        'total': bookings.length,
      };
    } catch (e) {
      LoggingService.error('getBookingCounts failed: $e',
          tag: 'ProBookingsService');
      return {'pending': 0, 'accepted': 0, 'completed': 0, 'total': 0};
    }
  }

  Future<bool> _updateBookingAndTmMetadata(
    String bookingId, {
    String? status,
    Map<String, dynamic>? extraData,
    Map<String, dynamic>? metadataUpdates,
  }) async {
    try {
      var existingNotes = <String, dynamic>{};
      try {
        final booking = await _bookingsApi.getBooking(bookingId);
        existingNotes = tmMetadata({'notes': booking.notes});
      } catch (_) {}

      final merged = <String, dynamic>{...existingNotes};
      if (metadataUpdates != null) {
        merged.addAll(metadataUpdates);
      }

      final notesValue = jsonEncode(merged);
      final updateData = <String, dynamic>{
        if (status != null) 'status': status,
        if (extraData != null) ...extraData,
        'notes': '$_tmMetaPrefix$notesValue',
      };

      await _bookingsApi.updateBooking(bookingId, data: updateData);
      return true;
    } catch (e) {
      LoggingService.error('Error updating TM booking metadata: $e',
          tag: 'ProBookingsService');
      return false;
    }
  }

  static double? _toDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
