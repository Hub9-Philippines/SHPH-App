import '/api/resources/kyc_api.dart';
import '/services/logging_service.dart';

class KycHubService {
  KycHubService._();
  static final KycHubService instance = KycHubService._();

  final _api = ShphKycApi.instance;

  Future<Map<String, dynamic>> getStatus() async {
    try {
      return await _api.getStatus();
    } catch (e) {
      LoggingService.error('Error fetching KYC status: $e',
          tag: 'KycHubService');
      return {};
    }
  }

  Future<bool> skipKyc() async {
    try {
      await _api.skipKyc();
      return true;
    } catch (e) {
      LoggingService.error('Error skipping KYC: $e', tag: 'KycHubService');
      return false;
    }
  }
}
