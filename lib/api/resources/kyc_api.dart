import 'dart:convert';

import 'package:dio/dio.dart';
import '/api/shph_api_client.dart';

/// A single KYC document to upload (bytes + multipart filename).
class KycDocumentFile {
  const KycDocumentFile(this.bytes, this.fileName);

  final List<int> bytes;
  final String fileName;
}

/// Multipart payload for `POST /api/kyc/submit/` using web field names
/// (`E:\Dev\shph-web\src\stores\kyc.ts` `submitKycDocs`).
class KycSubmitPayload {
  const KycSubmitPayload({
    required this.submitterRole,
    this.idFront,
    this.idBack,
    this.selfie,
    this.nbiClearance,
    this.portfolio,
    this.resume,
    this.challengeNonce,
    this.livenessMetadata,
    this.livenessScore,
  });

  /// `provider` | `customer`.
  final String submitterRole;
  final KycDocumentFile? idFront;
  final KycDocumentFile? idBack;
  final KycDocumentFile? selfie;
  final KycDocumentFile? nbiClearance;
  final KycDocumentFile? portfolio;
  final KycDocumentFile? resume;
  final String? challengeNonce;
  final Map<String, dynamic>? livenessMetadata;
  final double? livenessScore;
}

/// KYC endpoints from SHPH API.yaml (`/api/kyc/*`).
class ShphKycApi {
  ShphKycApi._();

  static final ShphKycApi instance = ShphKycApi._();
  final _client = ShphApiClient.instance;

  /// Issue a single-use liveness challenge → `{nonce, plan, expiresAt}`.
  Future<Map<String, dynamic>> requestLivenessChallenge() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/kyc/liveness/challenge/',
    );
    return response.data ?? {};
  }

  /// Get KYC submission status. Uses POST (web parity) — the POST variant is
  /// the documented alternative that mirrors the GET response.
  Future<Map<String, dynamic>> getStatus() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/kyc/status/',
    );
    return response.data ?? {};
  }

  Future<void> skipKyc() async {
    await _client.post('/api/auth/me/skip-kyc/');
  }

  /// Build the multipart FormData for `POST /api/kyc/submit/` with web field
  /// names. Exposed (over the network call) so the field set is unit-testable.
  FormData buildFormData(KycSubmitPayload payload) {
    final fields = <String, dynamic>{
      'submitter_role': payload.submitterRole,
    };
    void addFile(String field, KycDocumentFile? file) {
      if (file != null) {
        fields[field] =
            MultipartFile.fromBytes(file.bytes, filename: file.fileName);
      }
    }

    addFile('id_front', payload.idFront);
    addFile('id_back', payload.idBack);
    addFile('selfie', payload.selfie);
    addFile('nbi_clearance', payload.nbiClearance);
    addFile('portfolio', payload.portfolio);
    addFile('resume', payload.resume);

    if (payload.challengeNonce != null) {
      fields['challenge_nonce'] = payload.challengeNonce;
    }
    if (payload.livenessMetadata != null) {
      fields['liveness_metadata'] = jsonEncode(payload.livenessMetadata);
    }
    if (payload.livenessScore != null) {
      fields['liveness_score'] = payload.livenessScore.toString();
    }

    return FormData.fromMap(fields);
  }

  /// Submit the full KYC package (ID front/back, selfie, provider docs,
  /// liveness proof) as multipart/form-data with web field names.
  Future<Map<String, dynamic>> submitKycDocs(KycSubmitPayload payload) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/kyc/submit/',
      data: buildFormData(payload),
    );
    return response.data ?? {};
  }

  /// Legacy single-document submit (kept for the existing `ProfilesService`
  /// callers that upload one ID image at a time).
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
