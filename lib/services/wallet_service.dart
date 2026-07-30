import '/api/models/booking.dart';
import '/api/resources/bookings_api.dart';
import '/services/logging_service.dart';

class WalletService {
  WalletService._();
  static final WalletService instance = WalletService._();

  final _bookingsApi = ShphBookingsApi.instance;

  Future<Map<String, dynamic>> getWalletData() async {
    try {
      final userBookings = await _bookingsApi.listUserBookings();
      final providerBookings = await _bookingsApi.listBookings();

      final allTransactions = <Map<String, dynamic>>[];

      var totalSpent = 0.0;
      for (final booking in userBookings.results) {
        if (booking.status != 'completed') continue;
        final amount = booking.totalPrice ?? booking.agreedPrice ?? 0.0;
        totalSpent += amount;
        allTransactions.add(_txFromBooking(booking, 'debit'));
      }

      var totalEarnings = 0.0;
      for (final booking in providerBookings.results) {
        if (booking.status != 'completed') continue;
        final amount = booking.totalPrice ?? booking.agreedPrice ?? 0.0;
        totalEarnings += amount;
        allTransactions.add(_txFromBooking(booking, 'credit'));
      }

      allTransactions.sort((a, b) {
        final aDate = _parseDate(a['rawDate']);
        final bDate = _parseDate(b['rawDate']);
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });

      return {
        'balance': totalEarnings - totalSpent,
        'totalEarnings': totalEarnings,
        'totalSpent': totalSpent,
        'transactions': allTransactions,
      };
    } catch (e) {
      LoggingService.error('Error fetching wallet data: $e',
          tag: 'WalletService');
      return _emptyWallet();
    }
  }

  Map<String, dynamic> _txFromBooking(ShphBooking booking, String type) {
    final amount = booking.totalPrice ?? booking.agreedPrice ?? 0.0;
    final serviceName = booking.listingTitle ?? 'Unknown Service';
    final rawDate = booking.scheduledAt ?? booking.createdAt;
    final date = _formatDate(rawDate);
    final clientName =
        booking.clientProfile?['display_name']?.toString() ?? 'Client';

    return {
      'type': type,
      'description': type == 'debit'
          ? 'Payment to Provider — $serviceName'
          : 'Service Payment — $serviceName ($clientName)',
      'date': date,
      'amount': amount,
      'bookingId': booking.id,
      'rawDate': rawDate,
    };
  }

  Map<String, dynamic> _emptyWallet() => {
        'balance': 0.0,
        'totalEarnings': 0.0,
        'totalSpent': 0.0,
        'transactions': <Map<String, dynamic>>[],
      };

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return 'N/A';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }
}
