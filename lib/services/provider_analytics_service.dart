import 'package:supabase_flutter/supabase_flutter.dart';

import '/api/bridges/api_row_mapper.dart';
import '/api/resources/analytics_api.dart';
import '/services/logging_service.dart';

class ProviderAnalyticsService {
  ProviderAnalyticsService._();
  static final ProviderAnalyticsService instance = ProviderAnalyticsService._();

  final _supabase = Supabase.instance.client;
  final _api = ShphAnalyticsApi.instance;

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  Future<Map<String, dynamic>> getAnalytics() async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        final apiData = await _api.getProviderAnalytics();
        if (apiData.isNotEmpty) {
          return _apiToAnalytics(apiData);
        }
      } catch (e) {
        LoggingService.error(
          'SHPH API getAnalytics failed, falling back: $e',
          tag: 'ProviderAnalyticsService',
        );
      }
    }

    final userId = _currentUserId;
    if (userId == null) return _emptyAnalytics();

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

  Map<String, dynamic> _apiToAnalytics(Map<String, dynamic> data) => {
    'totalEarnings': (data['total_earnings'] ?? data['totalEarnings'] ?? 0).toDouble(),
    'totalJobs': data['total_jobs'] ?? data['totalJobs'] ?? 0,
    'avgRating': (data['avg_rating'] ?? data['avgRating'] ?? 0).toDouble(),
    'totalReviews': data['total_reviews'] ?? data['totalReviews'] ?? 0,
    'completionRate': (data['completion_rate'] ?? data['completionRate'] ?? 0).toDouble(),
    'monthlyRevenue': (data['monthly_revenue'] ?? data['monthlyRevenue'] ?? <Map<String, dynamic>>[]).cast<Map<String, dynamic>>(),
    'bookingInsights': {
      'completed': (data['booking_insights']?['completed'] ?? 0),
      'cancelled': (data['booking_insights']?['cancelled'] ?? 0),
      'pending': (data['booking_insights']?['pending'] ?? 0),
    },
    'performanceMetrics': {
      'repeatClients': (data['performance_metrics']?['repeat_clients'] ?? data['performanceMetrics']?['repeatClients'] ?? 0).toDouble(),
      'avgJobValue': (data['performance_metrics']?['avg_job_value'] ?? data['performanceMetrics']?['avgJobValue'] ?? 0).toDouble(),
    },
  };

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

    final clientJobs = <String, int>{};
    for (final booking in completedBookings) {
      final price = (booking['total_price'] as num?)?.toDouble() ?? 0.0;
      totalEarnings += price;
      final completedAt = booking['completed_at'] != null
          ? DateTime.tryParse(booking['completed_at'] as String) : null;
      if (completedAt != null) {
        for (var i = 0; i < monthlyRevenue.length; i++) {
          final m = monthlyRevenue[i];
          if (completedAt.year == m['year'] && completedAt.month == _monthFromAbbr(m['month'] as String)) {
            monthlyRevenue[i]['revenue'] = (monthlyRevenue[i]['revenue'] as double) + price;
            monthlyRevenue[i]['jobs'] = (monthlyRevenue[i]['jobs'] as int) + 1;
            break;
          }
        }
      }
      final clientId = booking['user_id'] as String?;
      if (clientId != null) clientJobs[clientId] = (clientJobs[clientId] ?? 0) + 1;
    }

    var completed = 0, cancelled = 0, pending = 0;
    for (final b in allBookings) {
      final status = b['status'] as String?;
      if (status == 'completed') completed++;
      else if (status == 'cancelled' || status == 'rejected') cancelled++;
      else if (status == 'pending') pending++;
    }
    final total = allBookings.length;
    final completionRate = total > 0 ? completed / total : 0.0;

    var totalRating = 0.0;
    for (final r in reviews) totalRating += (r['rating'] as num?)?.toDouble() ?? 0.0;
    final avgRating = reviews.isNotEmpty ? totalRating / reviews.length : 0.0;
    final repeatClients = clientJobs.values.where((c) => c > 1).length;
    final repeatRate = clientJobs.isNotEmpty ? repeatClients / clientJobs.length : 0.0;
    final avgJobValue = completedBookings.isNotEmpty ? totalEarnings / completedBookings.length : 0.0;

    return {
      'totalEarnings': totalEarnings,
      'totalJobs': completedBookings.length,
      'avgRating': double.parse(avgRating.toStringAsFixed(1)),
      'totalReviews': reviews.length,
      'completionRate': double.parse(completionRate.toStringAsFixed(2)),
      'monthlyRevenue': monthlyRevenue,
      'bookingInsights': {'completed': completed, 'cancelled': cancelled, 'pending': pending},
      'performanceMetrics': {
        'repeatClients': double.parse(repeatRate.toStringAsFixed(2)),
        'avgJobValue': double.parse(avgJobValue.toStringAsFixed(2)),
      },
    };
  }

  String _monthAbbr(int month) => ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][month - 1];
  int _monthFromAbbr(String abbr) => {'Jan':1,'Feb':2,'Mar':3,'Apr':4,'May':5,'Jun':6,'Jul':7,'Aug':8,'Sep':9,'Oct':10,'Nov':11,'Dec':12}[abbr] ?? 1;
}
