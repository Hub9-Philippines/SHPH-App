import '/api/bridges/api_row_mapper.dart';
import '/api/resources/bookings_api.dart';
import '/backend/supabase/supabase.dart';
import '/services/logging_service.dart';

/// Service for managing pro/provider bookings, jobs, schedule and earnings
class ProBookingsService {
  ProBookingsService._();
  static final ProBookingsService instance = ProBookingsService._();

  final _supabase = Supabase.instance.client;
  final _bookingsApi = ShphBookingsApi.instance;

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  Future<List<Map<String, dynamic>>> _fetchProviderBookingsFromApi() async {
    final page = await _bookingsApi.listBookings();
    return page.results
        .map((booking) => ApiRowMapper.bookingToRow(booking).data)
        .toList();
  }

  /// Get pending job requests for the provider
  Future<List<Map<String, dynamic>>> getPendingJobRequests() async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        final bookings = await _fetchProviderBookingsFromApi();
        return bookings
            .where((booking) => booking['status'] == 'pending')
            .toList();
      } catch (e) {
        LoggingService.error(
          'SHPH API getPendingJobRequests failed, falling back to Supabase: $e',
          tag: 'ProBookingsService',
        );
      }
    }

    try {
      final userId = _currentUserId;
      if (userId == null) {
        return [];
      }

      final response = await _supabase
          .from('bookings')
          .select('''
            *,
            service_listings(*),
            profiles!bookings_user_id_fkey(*)
          ''')
          .eq('provider_id', userId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return response;
    } catch (e) {
      LoggingService.error('Error fetching pending job requests: $e',
          tag: 'ProBookingsService');
      return [];
    }
  }

  /// Get scheduled/accepted jobs for the provider
  Future<List<Map<String, dynamic>>> getScheduledJobs() async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        final bookings = await _fetchProviderBookingsFromApi();
        return bookings
            .where((booking) {
              final status = booking['status'] as String?;
              return status == 'accepted' ||
                  status == 'confirmed' ||
                  status == 'in_progress' ||
                  status == 'completed';
            })
            .toList();
      } catch (e) {
        LoggingService.error(
          'SHPH API getScheduledJobs failed, falling back to Supabase: $e',
          tag: 'ProBookingsService',
        );
      }
    }

    try {
      final userId = _currentUserId;
      if (userId == null) {
        return [];
      }

      final response = await _supabase
          .from('bookings')
          .select('''
            *,
            service_listings(*),
            profiles!bookings_user_id_fkey(*)
          ''')
          .eq('provider_id', userId)
          .inFilter('status', ['accepted', 'in_progress', 'completed'])
          .order('booking_date', ascending: true);

      return response;
    } catch (e) {
      LoggingService.error('Error fetching scheduled jobs: $e',
          tag: 'ProBookingsService');
      return [];
    }
  }

  /// Get earnings summary for the provider
  Future<Map<String, dynamic>> getEarningsSummary() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
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

      // Get all completed bookings with related data
      final completedBookings = await _supabase
          .from('bookings')
          .select('''
            *,
            service_listings(*),
            profiles!bookings_user_id_fkey(*)
          ''')
          .eq('provider_id', userId)
          .eq('status', 'completed')
          .order('completed_at', ascending: false);

      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month);
      final lastMonth = DateTime(now.year, now.month - 1);
      final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));

      double totalEarnings = 0;
      double thisMonthEarnings = 0;
      double lastMonthEarnings = 0;
      double thisWeekEarnings = 0;
      double lastWeekEarnings = 0;

      // Weekly data for chart
      final weeklyData = <Map<String, dynamic>>[];
      for (int i = 4; i >= 0; i--) {
        final weekStart = thisWeekStart.subtract(Duration(days: i * 7));
        final weekEnd = weekStart.add(const Duration(days: 6));
        weeklyData.add({
          'week': 'Week ${5 - i}',
          'start': weekStart,
          'end': weekEnd,
          'earnings': 0.0,
        });
      }

      // Recent transactions
      final recentTransactions = <Map<String, dynamic>>[];

      for (final booking in completedBookings) {
        final totalPrice = (booking['total_price'] as num?)?.toDouble() ?? 0.0;
        final completedAt = booking['completed_at'] != null
            ? DateTime.parse(booking['completed_at'])
            : null;
        final serviceName = booking['service_listings']?['name'] as String? ??
            'Unknown Service';
        final profileData = booking['profiles'] as Map<String, dynamic>?;
        final clientName = profileData?['display_name'] ??
            profileData?['first_name'] ??
            'Unknown Client';

        totalEarnings += totalPrice;

        if (completedAt != null) {
          // This month
          if (completedAt.year == thisMonth.year &&
              completedAt.month == thisMonth.month) {
            thisMonthEarnings += totalPrice;
          }

          // Last month
          if (completedAt.year == lastMonth.year &&
              completedAt.month == lastMonth.month) {
            lastMonthEarnings += totalPrice;
          }

          // This week
          if (completedAt.isAfter(thisWeekStart) ||
              completedAt.isAtSameMomentAs(thisWeekStart)) {
            thisWeekEarnings += totalPrice;
          }

          // Last week (7-14 days ago)
          final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
          final lastWeekEnd = thisWeekStart.subtract(const Duration(days: 1));
          if (completedAt.isAfter(lastWeekStart) &&
              completedAt.isBefore(lastWeekEnd.add(const Duration(days: 1)))) {
            lastWeekEarnings += totalPrice;
          }

          // Weekly data
          for (int i = 0; i < weeklyData.length; i++) {
            final week = weeklyData[i];
            if (completedAt.isAfter(week['start']) &&
                completedAt
                    .isBefore(week['end'].add(const Duration(days: 1)))) {
              weeklyData[i]['earnings'] =
                  (weeklyData[i]['earnings'] as double) + totalPrice;
              break;
            }
          }
        }

        // Add to recent transactions (limit to 10)
        if (recentTransactions.length < 10) {
          // Format date as string
          String dateStr;
          if (completedAt != null) {
            dateStr =
                '${completedAt.month}/${completedAt.day}/${completedAt.year}';
          } else if (booking['created_at'] != null) {
            try {
              final createdAt = DateTime.parse(booking['created_at'] as String);
              dateStr = '${createdAt.month}/${createdAt.day}/${createdAt.year}';
            } catch (e) {
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
      LoggingService.error('Error calculating earnings: $e',
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
    if (await ApiRowMapper.canUseApi()) {
      try {
        await _bookingsApi.acceptBooking(bookingId);
        LoggingService.info('Job accepted via API: $bookingId',
            tag: 'ProBookingsService');
        return true;
      } catch (e) {
        LoggingService.error(
          'SHPH API acceptJob failed, falling back to Supabase: $e',
          tag: 'ProBookingsService',
        );
      }
    }

    try {
      await _supabase.from('bookings').update({
        'status': 'accepted',
        'accepted_at': DateTime.now().toIso8601String(),
      }).eq('id', bookingId);

      LoggingService.info('Job accepted: $bookingId',
          tag: 'ProBookingsService');
      return true;
    } catch (e) {
      LoggingService.error('Error accepting job: $e',
          tag: 'ProBookingsService');
      return false;
    }
  }

  /// Reject a job request
  Future<bool> rejectJob(String bookingId, {String? reason}) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        await _bookingsApi.rejectBooking(bookingId, reason: reason);
        LoggingService.info('Job rejected via API: $bookingId',
            tag: 'ProBookingsService');
        return true;
      } catch (e) {
        LoggingService.error(
          'SHPH API rejectJob failed, falling back to Supabase: $e',
          tag: 'ProBookingsService',
        );
      }
    }

    try {
      await _supabase.from('bookings').update({
        'status': 'rejected',
        'rejected_at': DateTime.now().toIso8601String(),
        'rejection_reason': reason,
      }).eq('id', bookingId);

      LoggingService.info('Job rejected: $bookingId',
          tag: 'ProBookingsService');
      return true;
    } catch (e) {
      LoggingService.error('Error rejecting job: $e',
          tag: 'ProBookingsService');
      return false;
    }
  }

  /// Mark job as completed
  Future<bool> completeJob(String bookingId) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        await _bookingsApi.updateBooking(
          bookingId,
          data: {'status': 'completed'},
        );
        LoggingService.info('Job completed via API: $bookingId',
            tag: 'ProBookingsService');
        return true;
      } catch (e) {
        LoggingService.error(
          'SHPH API completeJob failed, falling back to Supabase: $e',
          tag: 'ProBookingsService',
        );
      }
    }

    try {
      await _supabase.from('bookings').update({
        'status': 'completed',
        'completed_at': DateTime.now().toIso8601String(),
      }).eq('id', bookingId);

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
    if (await ApiRowMapper.canUseApi()) {
      try {
        final bookings = await _fetchProviderBookingsFromApi();
        int pending = 0;
        int accepted = 0;
        int completed = 0;

        for (final booking in bookings) {
          final status = booking['status'] as String?;
          if (status == 'pending') pending++;
          if (status == 'accepted' ||
              status == 'confirmed' ||
              status == 'in_progress') {
            accepted++;
          }
          if (status == 'completed') completed++;
        }

        return {
          'pending': pending,
          'accepted': accepted,
          'completed': completed,
          'total': bookings.length,
        };
      } catch (e) {
        LoggingService.error(
          'SHPH API getBookingCounts failed, falling back to Supabase: $e',
          tag: 'ProBookingsService',
        );
      }
    }

    try {
      final userId = _currentUserId;
      if (userId == null) {
        return {'pending': 0, 'accepted': 0, 'completed': 0, 'total': 0};
      }

      final response = await _supabase
          .from('bookings')
          .select('status')
          .eq('provider_id', userId);

      int pending = 0;
      int accepted = 0;
      int completed = 0;

      for (final booking in response) {
        final status = booking['status'] as String?;
        if (status == 'pending') pending++;
        if (status == 'accepted' || status == 'in_progress') accepted++;
        if (status == 'completed') completed++;
      }

      return {
        'pending': pending,
        'accepted': accepted,
        'completed': completed,
        'total': response.length,
      };
    } catch (e) {
      LoggingService.error('Error fetching booking counts: $e',
          tag: 'ProBookingsService');
      return {'pending': 0, 'accepted': 0, 'completed': 0, 'total': 0};
    }
  }
}
