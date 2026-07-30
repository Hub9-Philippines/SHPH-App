import '/services/bids_service.dart';
import '/services/logging_service.dart';

class ProviderBidsModel {
  List<Map<String, dynamic>> bids = [];
  bool isLoading = true;

  Future<void> loadBids() async {
    isLoading = true;
    try {
      bids = await BidsService.instance.getBids();
    } catch (e) {
      LoggingService.error('Error loading bids: $e', tag: 'ProviderBidsModel');
    } finally {
      isLoading = false;
    }
  }

  Future<bool> withdrawBid(String bidId) async {
    final success = await BidsService.instance.withdrawBid(bidId);
    if (success) {
      bids.removeWhere((b) => b['id']?.toString() == bidId);
    }
    return success;
  }

  void dispose() {}
}
