import 'package:dio/dio.dart';
import '/api/shph_api_client.dart';

/// KYC endpoints from SHPH API.yaml (`/api/kyc/*`).
class ShphKycApi {
  ShphKycApi._();

  static final ShphKycApi instance = ShphKycApi._();
  final _client = ShphApiClient.instance;

  Future<Map<String, dynamic>> getStatus() async {
    final response = await _client.get<Map<String, dynamic>>('/api/kyc/status/');
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> submitKyc({
    required List<int> documentBytes,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'document': MultipartFile.fromBytes(documentBytes, filename: fileName),
    });
    final response = await _client.post<Map<String, dynamic>>(
      '/api/kyc/submit/',
      data: formData,
    );
    return response.data ?? {};
  }
}
