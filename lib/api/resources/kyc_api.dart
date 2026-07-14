import 'package:dio/dio.dart';
import '/api/shph_api_client.dart';

/// KYC endpoints from SHPH API.yaml (`/api/kyc/*`).
class ShphKycApi {
  ShphKycApi._();

  static final ShphKycApi instance = ShphKycApi._();
  final _client = ShphApiClient.instance;

  Future<Map<String, dynamic>> getStatus() async {
    final response =
        await _client.get<Map<String, dynamic>>('/api/kyc/status/');
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

  Future<Map<String, dynamic>> listAdminSubmissions({int? page}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/kyc/admin/',
      queryParameters: {if (page != null) 'page': page},
    );
    return response.data ?? {};
  }

  Future<void> reviewSubmission(
    String id,
    String action, {
    String? reason,
  }) async {
    await _client.post(
      '/api/kyc/admin/$id/$action/',
      data: {if (reason != null) 'reason': reason},
    );
  }

  Future<Map<String, dynamic>> createLivenessChallenge() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/kyc/liveness/challenge/',
    );
    return response.data ?? {};
  }
}
