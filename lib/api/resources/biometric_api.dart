import '/api/shph_api_client.dart';

class ShphBiometricApi {
  ShphBiometricApi._();

  static final ShphBiometricApi instance = ShphBiometricApi._();
  final _client = ShphApiClient.instance;

  Future<Map<String, dynamic>> getRegisterOptions() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/biometric/register/options/',
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> verifyRegistration(
      Map<String, dynamic> credential) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/biometric/register/verify/',
      data: credential,
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> listCredentials() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/biometric/credentials/',
    );
    return response.data ?? {};
  }

  Future<void> deleteCredential(int pk) async {
    await _client.delete('/api/auth/biometric/credentials/$pk/');
  }
}
