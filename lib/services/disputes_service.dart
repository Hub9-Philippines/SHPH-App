import '/api/resources/disputes_api.dart';
import '/services/logging_service.dart';

class DisputesService {
  DisputesService._();
  static final DisputesService instance = DisputesService._();

  final _api = ShphDisputesApi.instance;

  Future<List<Map<String, dynamic>>> getDisputes() async {
    try {
      final resp = await _api.listDisputes();
      final results = resp['results'];
      if (results is List) {
        return results.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      LoggingService.error('Error fetching disputes: $e',
          tag: 'DisputesService');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getDispute(String disputeId) async {
    try {
      return await _api.getDispute(disputeId);
    } catch (e) {
      LoggingService.error('Error fetching dispute: $e',
          tag: 'DisputesService');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createDispute(
      Map<String, dynamic> payload) async {
    try {
      final resp = await _api.createDispute(payload);
      return resp['id'] != null ? resp : null;
    } catch (e) {
      LoggingService.error('Error creating dispute: $e',
          tag: 'DisputesService');
      return null;
    }
  }
}
