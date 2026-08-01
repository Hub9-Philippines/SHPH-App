import '/api/resources/kyc_api.dart';
import '/services/logging_service.dart';

/// KYC status wrapper: fetches `POST /kyc/status/` with a 60s TTL (web parity)
/// and normalizes the mixed historical vocabularies into the web set
/// (`not_submitted`/`rejected`/`pending`/`approved`).
class KycHubService {
  KycHubService._();
  static final KycHubService instance = KycHubService._();

  final _api = ShphKycApi.instance;

  static const Duration kycStatusTtl = Duration(seconds: 60);

  DateTime? _lastFetchedAt;
  Map<String, dynamic> _status = {};
  String _statusValue = 'not_submitted';

  /// Normalized KYC status value (web vocabulary).
  String get statusValue => _statusValue;

  /// The last raw KYC status response map.
  Map<String, dynamic> get status => _status;

  /// Normalize any raw status value the API or legacy code may produce into
  /// the web vocabulary: `not_submitted`/`rejected`/`pending`/`approved`.
  static String normalizeStatus(dynamic raw) {
    final value = raw?.toString().toLowerCase().trim() ?? '';
    switch (value) {
      case 'approved':
      case 'verified':
        return 'approved';
      case 'pending':
      case 'under_review':
      case 'reviewing':
        return 'pending';
      case 'rejected':
        return 'rejected';
      case 'not_submitted':
      case 'not_started':
      case 'unverified':
      case '':
      default:
        return 'not_submitted';
    }
  }

  /// Fetch KYC status, honoring the 60s TTL. `force` bypasses the cache.
  Future<Map<String, dynamic>> getStatus({bool force = false}) async {
    final now = DateTime.now();
    final isStale =
        _lastFetchedAt == null || now.difference(_lastFetchedAt!) > kycStatusTtl;
    if (!force && !isStale) {
      return _status;
    }
    try {
      final resp = await _api.getStatus();
      _status = resp;
      _statusValue =
          normalizeStatus(resp['status'] ?? resp['verification_status']);
      _lastFetchedAt = now;
    } catch (e) {
      LoggingService.error('Error fetching KYC status: $e',
          tag: 'KycHubService');
      _status = {};
      _statusValue = 'not_submitted';
      _lastFetchedAt = now;
    }
    return _status;
  }

  Future<bool> skipKyc() async {
    try {
      await _api.skipKyc();
      _statusValue = 'not_submitted';
      return true;
    } catch (e) {
      LoggingService.error('Error skipping KYC: $e', tag: 'KycHubService');
      return false;
    }
  }
}
