import '/api/resources/biometric_api.dart';
import '/services/logging_service.dart';

class BiometricService {
  BiometricService._();
  static final BiometricService instance = BiometricService._();

  final _api = ShphBiometricApi.instance;

  Future<Map<String, dynamic>?> getRegisterOptions() async {
    try {
      return await _api.getRegisterOptions();
    } catch (e) {
      LoggingService.error('Error fetching biometric options: $e',
          tag: 'BiometricService');
      return null;
    }
  }

  Future<bool> verifyRegistration(Map<String, dynamic> credential) async {
    try {
      final resp = await _api.verifyRegistration(credential);
      return resp['status'] == 'ok' || resp['id'] != null;
    } catch (e) {
      LoggingService.error('Error verifying biometric: $e',
          tag: 'BiometricService');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> listCredentials() async {
    try {
      final resp = await _api.listCredentials();
      final results = resp['results'] ?? resp['credentials'];
      if (results is List) {
        return results.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      LoggingService.error('Error listing biometric credentials: $e',
          tag: 'BiometricService');
      return [];
    }
  }

  Future<bool> deleteCredential(int pk) async {
    try {
      await _api.deleteCredential(pk);
      return true;
    } catch (e) {
      LoggingService.error('Error deleting biometric credential: $e',
          tag: 'BiometricService');
      return false;
    }
  }
}
