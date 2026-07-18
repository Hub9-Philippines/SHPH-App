import 'dart:convert';

import '/api/bridges/api_row_mapper.dart';
import '/api/resources/bookings_api.dart';
import '/services/logging_service.dart';

/// Service for managing pro/provider bookings, jobs, schedule and earnings
class ProBookingsService {
  ProBookingsService._();
  static final ProBookingsService instance = ProBookingsService._();
  static const _tmMetaPrefix = 'TM_META:';

  final _bookingsApi = ShphBookingsApi.instance;

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
      final allBookings = await _fetchProviderBookingsFromApi();
      final completedBookings =
          allBookings.where((b) => b['status'] == 'completed').toList();

      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month);
      final lastMonth = DateTime(now.year, now.month - 1);
      final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));

      var totalEarnings = 0.0;
      var thisMonthEarnings = 0.0;
      var lastMonthEarnings = 0.0;
      var thisWeekEarnings = 0.0;
      var lastWeekEarnings = 0.0;

      final weeklyData = <Map<String, dynamic>>[];
      for (var i = 4; i >= 0; i--) {
        final weekStart = thisWeekStart.subtract(Duration(days: i * 7));
        final weekEnd = weekStart.add(const Duration(days: 6));
        weeklyData.add({
          'week': 'Week ${5 - i}',
          'start': weekStart,
          'end': weekEnd,
          'earnings': 0.0,
        });
      }

      final recentTransactions = <Map<String, dynamic>>[];

      for (final booking in completedBookings) {
        final totalPrice = (booking['total_price'] as num?)?.toDouble() ?? 0.0;
        final completedAt = booking['completed_at'] != null
            ? DateTime.tryParse(booking['completed_at'].toString())
            : null;
        final serviceName = booking['service_listings']?['name'] as String? ??
            'Unknown Service';
        final profileData = booking['profiles'] as Map<String, dynamic>?;
        final clientName = profileData?['display_name'] ??
            profileData?['first_name'] ??
            'Unknown Client';

        totalEarnings += totalPrice;

        if (completedAt != null) {
          if (completedAt.year == thisMonth.year &&
              completedAt.month == thisMonth.month) {
            thisMonthEarnings += totalPrice;
          }
          if (completedAt.year == lastMonth.year &&
              completedAt.month == lastMonth.month) {
            lastMonthEarnings += totalPrice;
          }
          if (completedAt.isAfter(thisWeekStart) ||
              completedAt.isAtSameMomentAs(thisWeekStart)) {
            thisWeekEarnings += totalPrice;
          }
          final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
          final lastWeekEnd = thisWeekStart.subtract(const Duration(days: 1));
          if (completedAt.isAfter(lastWeekStart) &&
              completedAt.isBefore(lastWeekEnd.add(const Duration(days: 1)))) {
            lastWeekEarnings += totalPrice;
          }
          for (var i = 0; i < weeklyData.length; i++) {
            final week = weeklyData[i];
            if (completedAt.isAfter(week['start'] as DateTime) &&
                completedAt.isBefore(
                    (week['end'] as DateTime).add(const Duration(days: 1)))) {
              weeklyData[i]['earnings'] =
                  (weeklyData[i]['earnings'] as double) + totalPrice;
              break;
            }
          }
        }

        if (recentTransactions.length < 10) {
          String dateStr;
          if (completedAt != null) {
            dateStr =
                '${completedAt.month}/${completedAt.day}/${completedAt.year}';
          } else if (booking['created_at'] != null) {
            try {
              final createdAt =
                  DateTime.parse(booking['created_at'].toString());
              dateStr = '${createdAt.month}/${createdAt.day}/${createdAt.year}';
            } catch (_) {
              dateStr = 'Unknown Date';
            }
          } else {
            dateStr = 'Unknown Date';
          }

          recentTransactions.add({
            'id': booking['id'],
            'serviceName': serviceName,
            'clientName': clientName,
            'description': 'Completed: $serviceName',
            'amount': totalPrice,
            'date': dateStr,
            'type': 'earning',
            'status': 'completed',
          });
        }
      }

      return {
        'totalEarnings': totalEarnings,
        'thisMonth': thisMonthEarnings,
        'lastMonth': lastMonthEarnings,
        'thisWeek': thisWeekEarnings,
        'lastWeek': lastWeekEarnings,
        'totalJobs': completedBookings.length,
        'weeklyData': weeklyData,
        'recentTransactions': recentTransactions,
      };
    } catch (e) {
      LoggingService.error('getEarningsSummary failed: $e',
          tag: 'ProBookingsService');
      return {
        'totalEarnings': 0.0,
        'thisMonth': 0.0,
        'lastMonth': 0.0,
        'thisWeek': 0.0,
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
      LoggingService.info('Job accepted: $bookingId',
          tag: 'ProBookingsService');
      return true;
    } catch (e) {
      LoggingService.error('acceptJob failed: $e', tag: 'ProBookingsService');
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
      LoggingService.info('Job rejected: $bookingId',
          tag: 'ProBookingsService');
      return true;
    } catch (e) {
      LoggingService.error('rejectJob failed: $e', tag: 'ProBookingsService');
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
      LoggingService.error('completeJob failed: $e', tag: 'ProBookingsService');
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
      // Fetch current booking to get existing notes
      final booking = await _bookingsApi.getBooking(bookingId);
      final existingNotes = booking.notes;
      final mergedNotes = metadataUpdates == null
          ? existingNotes
          : _mergeTmMetadata(existingNotes, metadataUpdates);

      final updateData = <String, dynamic>{
        if (status != null) 'status': status,
        if (extraData != null) ...extraData,
        if (mergedNotes != null) 'notes': mergedNotes,
      };

      if (updateData.isEmpty) {
        return true;
      }

      await _bookingsApi.updateBooking(bookingId, data: updateData);
      return true;
    } catch (e) {
      LoggingService.error('_updateBookingAndTmMetadata failed: $e',
          tag: 'ProBookingsService');
      return false;
    }
  }

  String _mergeTmMetadata(
    String? existingNotes,
    Map<String, dynamic> updates,
  ) {
    final raw = existingNotes ?? '';
    final index = raw.indexOf(_tmMetaPrefix);
    final humanReadable =
        index >= 0 ? raw.substring(0, index).trimRight() : raw.trim();
    final current = tmMetadata({'notes': existingNotes})..addAll(updates);
    if (humanReadable.isEmpty) {
      return '$_tmMetaPrefix${jsonEncode(current)}';
    }
    return '$humanReadable\n$_tmMetaPrefix${jsonEncode(current)}';
  }
}
