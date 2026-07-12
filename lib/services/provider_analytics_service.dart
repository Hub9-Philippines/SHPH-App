import 'package:supabase_flutter/supabase_flutter.dart';

import '/services/logging_service.dart';

class ProviderAnalyticsService {
  ProviderAnalyticsService._();
  static final ProviderAnalyticsService instance = ProviderAnalyticsService._();

  final _supabase = Supabase.instance.client;

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  Future<Map<String, dynamic>> getAnalytics() async {
    final userId = _currentUserId;
    if (userId == null) {
      return _emptyAnalytics();
    }

    try {
      final completedBookings = await _supabase
          .from('bookings')
          .select('id, total_price, completed_at, created_at, status')
          .eq('provider_id', userId)
          .eq('status', 'completed')
          .order('completed_at', ascending: false);

      final allBookings = await _supabase
          .from('bookings')
          .select('id, status')
          .eq('provider_id', userId);

      final reviews = await _supabase
          .from('reviews')
          .select('rating')
          .eq('provider_id', userId);

      return _computeAnalytics(completedBookings, allBookings, reviews);
    } catch (e) {
      LoggingService.error('Error fetching analytics: $e',
          tag: 'ProviderAnalyticsService');
      return _emptyAnalytics();
    }
  }

  Map<String, dynamic> _emptyAnalytics() => {
        'totalEarnings': 0.0,
        'totalJobs': 0,
        'avgRating': 0.0,
        'totalReviews': 0,
        'completionRate': 0.0,
        'monthlyRevenue': <Map<String, dynamic>>[],
        'bookingInsights': <String, int>{
          'completed': 0,
          'cancelled': 0,
          'pending': 0,
        },
        'performanceMetrics': <String, double>{
          'repeatClients': 0.0,
          'avgJobValue': 0.0,
        },
      };

  Map<String, dynamic> _computeAnalytics(
    List<dynamic> completedBookings,
    List<dynamic> allBookings,
    List<dynamic> reviews,
  ) {
    var totalEarnings = 0.0;
    final now = DateTime.now();

    // 12-month revenue
    final monthlyRevenue = <Map<String, dynamic>>[];
    for (var i = 11; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      monthlyRevenue.add({
        'month': _monthAbbr(month.month),
        'year': month.year,
        'revenue': 0.0,
        'jobs': 0,
      });
    }

    // Client tracking for repeat rate
    final clientJobs = <String, int>{};

    for (final booking in completedBookings) {
      final price = (booking['total_price'] as num?)?.toDouble() ?? 0.0;
      totalEarnings += price;

      final completedAt = booking['completed_at'] != null
          ? DateTime.tryParse(booking['completed_at'] as String)
          : null;

      if (completedAt != null) {
        for (var i = 0; i < monthlyRevenue.length; i++) {
          final m = monthlyRevenue[i];
          if (completedAt.year == m['year'] &&
              completedAt.month ==
                  _monthFromAbbr(m['month'] as String)) {
            monthlyRevenue[i]['revenue'] =
                (monthlyRevenue[i]['revenue'] as double) + price;
            monthlyRevenue[i]['jobs'] =
                (monthlyRevenue[i]['jobs'] as int) + 1;
            break;
          }
        }
      }

      // Track client for repeat rate
      final clientId = booking['user_id'] as String?;
      if (clientId != null) {
        clientJobs[clientId] = (clientJobs[clientId] ?? 0) + 1;
      }
    }

    // Booking insights
    var completed = 0;
    var cancelled = 0;
    var pending = 0;
    for (final b in allBookings) {
      final status = b['status'] as String?;
      if (status == 'completed') {
        completed++;
      } else if (status == 'cancelled' || status == 'rejected') {
        cancelled++;
      } else if (status == 'pending') {
        pending++;
      }
    }

    // Completion rate
    final total = allBookings.length;
    final completionRate = total > 0 ? completed / total : 0.0;

    // Average rating
    var totalRating = 0.0;
    for (final r in reviews) {
      totalRating += (r['rating'] as num?)?.toDouble() ?? 0.0;
    }
    final avgRating =
        reviews.isNotEmpty ? totalRating / reviews.length : 0.0;

    // Repeat client rate
    final repeatClients =
        clientJobs.values.where((c) => c > 1).length;
    final repeatRate = clientJobs.isNotEmpty
        ? repeatClients / clientJobs.length
        : 0.0;

    // Average job value
    final avgJobValue =
        completedBookings.isNotEmpty ? totalEarnings / completedBookings.length : 0.0;

    return {
      'totalEarnings': totalEarnings,
      'totalJobs': completedBookings.length,
      'avgRating': double.parse(avgRating.toStringAsFixed(1)),
      'totalReviews': reviews.length,
      'completionRate': double.parse(completionRate.toStringAsFixed(2)),
      'monthlyRevenue': monthlyRevenue,
      'bookingInsights': {
        'completed': completed,
        'cancelled': cancelled,
        'pending': pending,
      },
      'performanceMetrics': {
        'repeatClients': double.parse(repeatRate.toStringAsFixed(2)),
        'avgJobValue': double.parse(avgJobValue.toStringAsFixed(2)),
      },
    };
  }

  String _monthAbbr(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }

  int _monthFromAbbr(String abbr) {
    const months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4,
      'May': 5, 'Jun': 6, 'Jul': 7, 'Aug': 8,
      'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
    };
    return months[abbr] ?? 1;
  }
}
