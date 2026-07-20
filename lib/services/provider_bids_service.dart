import '/services/logging_service.dart';
import '/services/pro_bookings_service.dart';

class ProviderBidsService {
  ProviderBidsService._();
  static final ProviderBidsService instance = ProviderBidsService._();

  Future<List<Map<String, dynamic>>> getProviderBids() async {
    try {
      return ProBookingsService.instance.getPendingJobRequests();
    } catch (e) {
      LoggingService.error('Error fetching provider jobs: $e',
          tag: 'ProviderBidsService');
      return [];
    }
  }

  Future<bool> withdrawBid(String bookingId) =>
      ProBookingsService.instance.rejectJob(bookingId);
}
