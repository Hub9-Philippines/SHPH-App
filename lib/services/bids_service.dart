import '/api/resources/bids_api.dart';
import '/services/logging_service.dart';

class BidsService {
  BidsService._();
  static final BidsService instance = BidsService._();

  final _api = ShphBidsApi.instance;

  Future<List<Map<String, dynamic>>> getBids() async {
    try {
      final resp = await _api.listBids();
      final results = resp['results'];
      if (results is List) {
        return results.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      LoggingService.error('Error fetching bids: $e', tag: 'BidsService');
      return [];
    }
  }

  Future<bool> withdrawBid(String bidId) async {
    try {
      await _api.withdrawBid(bidId);
      return true;
    } catch (e) {
      LoggingService.error('Error withdrawing bid: $e', tag: 'BidsService');
      return false;
    }
  }
}
