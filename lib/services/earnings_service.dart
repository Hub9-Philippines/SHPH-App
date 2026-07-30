import '/api/models/booking.dart';
import '/api/models/paginated_response.dart';
import '/api/resources/bookings_api.dart';
import '/services/logging_service.dart';

class EarningsService {
  EarningsService._();
  static final EarningsService instance = EarningsService._();

  final _bookingsApi = ShphBookingsApi.instance;

  Future<Map<String, dynamic>> getEarningsSummary() async {
    try {
      final page = await _bookingsApi.listBookings();
      final completed = page.results
          .where((b) => b.status == 'completed')
          .toList();

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

      for (final booking in completed) {
        final totalPrice = booking.totalPrice ?? booking.agreedPrice ?? 0.0;
        final completedAt = _parseDate(booking.scheduledAt);

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
          if (completedAt.isAfter(lastWeekStart) &&
              completedAt.isBefore(thisWeekStart)) {
            lastWeekEarnings += totalPrice;
          }

          for (var i = 0; i < weeklyData.length; i++) {
            final week = weeklyData[i];
            if (completedAt.isAfter(week['start']) &&
                completedAt.isBefore(week['end'].add(const Duration(days: 1)))) {
              weeklyData[i]['earnings'] =
                  (weeklyData[i]['earnings'] as double) + totalPrice;
              break;
            }
          }
        }

        if (recentTransactions.length < 10) {
          final serviceName = booking.listingTitle ?? 'Unknown Service';
          recentTransactions.add({
            'id': booking.id,
            'serviceName': serviceName,
            'clientName': booking.clientProfile?['display_name'] ?? 'Client',
            'description': 'Completed: $serviceName',
            'amount': totalPrice,
            'date': _formatDate(completedAt),
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
        'totalJobs': completed.length,
        'weeklyData': weeklyData,
        'recentTransactions': recentTransactions,
      };
    } catch (e) {
      LoggingService.error('Error fetching earnings: $e', tag: 'EarningsService');
      return {
        'totalEarnings': 0.0,
        'thisMonth': 0.0,
        'lastMonth': 0.0,
        'thisWeek': 0.0,
        'lastWeek': 0.0,
        'totalJobs': 0,
        'weeklyData': <Map<String, dynamic>>[],
        'recentTransactions': <Map<String, dynamic>>[],
      };
    }
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
