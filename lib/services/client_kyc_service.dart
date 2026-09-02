import '/api/resources/kyc_api.dart';
import '/services/kyc_hub_service.dart';

/// A captured KYC file (raw bytes + multipart filename).
class ClientKycFile {
  const ClientKycFile(this.bytes, this.name);

  final List<int> bytes;
  final String name;
}

/// Client (`customer`-role) KYC wrapper around `ShphKycApi`.
///
/// Deliberately stateless — the backend stays the single source of
/// verification truth, so nothing here is recorded as verified locally
/// (web `stores/kyc.ts` parity, `submitterRole: 'customer'`).
class ClientKycService {
  ClientKycService({ShphKycApi? api}) : _api = api ?? ShphKycApi.instance;

  final ShphKycApi _api;

  /// Normalized KYC status (`not_submitted`/`pending`/`approved`/`rejected`)
  /// plus whether the user previously skipped the flow (server-side truth).
  Future<({String status, bool skipped})> status() async {
    final raw = await _api.getStatus();
    final status =
        KycHubService.normalizeStatus(raw['status'] ?? raw['verification_status']);
    final skipped = raw['skipped'] == true || raw['kyc_skipped'] == true;
    return (status: status, skipped: skipped);
  }

  /// Record a server-side skip so later sessions do not force KYC again.
  Future<bool> skip() async {
    try {
      await _api.skipKyc();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> requestLivenessChallenge() =>
      _api.requestLivenessChallenge();

  /// Build the `customer`-role submission payload (exposed for tests).
  KycSubmitPayload buildSubmitPayload({
    required List<int> idFrontBytes,
    required String idFrontName,
    required List<int> idBackBytes,
    required String idBackName,
    required List<int> selfieBytes,
    required String selfieName,
    String? challengeNonce,
    Map<String, dynamic>? livenessMetadata,
    double? livenessScore,
  }) {
    return KycSubmitPayload(
      submitterRole: 'customer',
      idFront: KycDocumentFile(idFrontBytes, idFrontName),
      idBack: KycDocumentFile(idBackBytes, idBackName),
      selfie: KycDocumentFile(selfieBytes, selfieName),
      challengeNonce: challengeNonce,
      livenessMetadata: livenessMetadata,
      livenessScore: livenessScore,
    );
  }

  Future<Map<String, dynamic>> submit({
    required List<int> idFrontBytes,
    required String idFrontName,
    required List<int> idBackBytes,
    required String idBackName,
    required List<int> selfieBytes,
    required String selfieName,
    String? challengeNonce,
    Map<String, dynamic>? livenessMetadata,
    double? livenessScore,
  }) {
    return _api.submitKycDocs(
      buildSubmitPayload(
        idFrontBytes: idFrontBytes,
        idFrontName: idFrontName,
        idBackBytes: idBackBytes,
        idBackName: idBackName,
        selfieBytes: selfieBytes,
        selfieName: selfieName,
        challengeNonce: challengeNonce,
        livenessMetadata: livenessMetadata,
        livenessScore: livenessScore,
      ),
    );
  }
}