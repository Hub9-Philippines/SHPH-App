import 'package:flutter/foundation.dart';

import '/api/resources/kyc_api.dart';

/// Document field slots for the KYC submission (web `stores/kyc.ts` parity).
enum KycDocumentField {
  idFront,
  idBack,
  selfie,
  nbiClearance,
  portfolio,
  resume,
}

/// In-memory KYC submission state — holds the collected ID documents, the
/// liveness result, and the submitter role until the review page submits them
/// as one multipart request (web `stores/kyc.ts` parity).
class KycSubmissionService extends ChangeNotifier {
  KycSubmissionService._();
  static final KycSubmissionService instance = KycSubmissionService._();

  final _api = ShphKycApi.instance;

  final Map<KycDocumentField, KycDocumentFile> _documents = {};

  String submitterRole = 'provider';

  String? challengeNonce;
  List<String> livenessPlan = [];
  String? livenessDecision; // 'pass' | 'flag_review' | 'block'
  double? livenessScore;
  Map<String, dynamic>? livenessMetadata;

  KycDocumentFile? document(KycDocumentField field) => _documents[field];

  bool get hasIdDocuments =>
      _documents[KycDocumentField.idFront] != null &&
      _documents[KycDocumentField.idBack] != null;

  /// Required docs gate: both ID sides always; providers additionally need NBI.
  bool get hasRequiredDocuments {
    if (!hasIdDocuments) return false;
    if (submitterRole == 'provider') {
      return _documents[KycDocumentField.nbiClearance] != null;
    }
    return true;
  }

  /// A `block` decision must never be submitted — the caller surfaces a
  /// "redo liveness" error instead.
  bool get isLivenessBlocked => livenessDecision == 'block';

  void setDocument(KycDocumentField field, KycDocumentFile? file) {
    if (file == null) {
      _documents.remove(field);
    } else {
      _documents[field] = file;
    }
    notifyListeners();
  }

  void setLivenessResult({
    String? nonce,
    List<String>? plan,
    String? decision,
    double? score,
    Map<String, dynamic>? metadata,
    KycDocumentFile? selfie,
  }) {
    challengeNonce = nonce;
    if (plan != null) livenessPlan = plan;
    livenessDecision = decision;
    livenessScore = score;
    livenessMetadata = metadata;
    if (selfie != null) {
      _documents[KycDocumentField.selfie] = selfie;
    }
    notifyListeners();
  }

  void resetLiveness() {
    challengeNonce = null;
    livenessPlan = [];
    livenessDecision = null;
    livenessScore = null;
    livenessMetadata = null;
    _documents.remove(KycDocumentField.selfie);
    notifyListeners();
  }

  void reset() {
    _documents.clear();
    submitterRole = 'provider';
    resetLiveness();
    notifyListeners();
  }

  /// Submit the full package. On success the in-memory state is cleared so a
  /// re-submission starts fresh.
  Future<Map<String, dynamic>> submit() async {
    final payload = KycSubmitPayload(
      submitterRole: submitterRole,
      idFront: _documents[KycDocumentField.idFront],
      idBack: _documents[KycDocumentField.idBack],
      selfie: _documents[KycDocumentField.selfie],
      nbiClearance: _documents[KycDocumentField.nbiClearance],
      portfolio: _documents[KycDocumentField.portfolio],
      resume: _documents[KycDocumentField.resume],
      challengeNonce: challengeNonce,
      livenessMetadata: livenessMetadata,
      livenessScore: livenessScore,
    );
    final resp = await _api.submitKycDocs(payload);
    reset();
    return resp;
  }
}
