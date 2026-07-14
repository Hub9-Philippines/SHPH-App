import '/api/resources/admin_api.dart';
import '/services/logging_service.dart';

class AdminService {
  AdminService._();
  static final AdminService instance = AdminService._();
  final _api = ShphAdminApi.instance;

  Future<bool> get isAdmin => _api.isAdmin();

  Future<Map<String, int>> getDashboardStats() async {
    try {
      final data = await _api.getDashboardStats();
      int value(String snake, String camel) =>
          (data[snake] ?? data[camel] ?? 0) as int;
      return {
        'totalUsers': value('total_users', 'totalUsers'),
        'totalProviders': value('total_providers', 'totalProviders'),
        'pendingKyc': value('pending_kyc', 'pendingKyc'),
        'openDisputes': value('open_disputes', 'openDisputes'),
        'pendingPayouts': value('pending_payouts', 'pendingPayouts'),
        'activeListings': value('active_listings', 'activeListings'),
      };
    } catch (e) {
      LoggingService.error('API dashboard stats failed: $e',
          tag: 'AdminService');
      return {};
    }
  }

  List<Map<String, dynamic>> _results(Map<String, dynamic> data) {
    final raw = data['results'] ?? data['data'];
    return raw is List
        ? raw.whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];
  }

  Future<List<Map<String, dynamic>>> getKycSubmissions(
      {String? statusFilter}) async {
    try {
      return _results(await _api.listKycSubmissions(status: statusFilter));
    } catch (e) {
      LoggingService.error('API KYC list failed: $e', tag: 'AdminService');
      return [];
    }
  }

  Future<bool> updateKycStatus(String userId, String status) =>
      _run(() => _api.updateKycStatus(userId, status), 'update KYC status');

  Future<List<Map<String, dynamic>>> getAllDisputes(
      {String? statusFilter}) async {
    try {
      return _results(await _api.listDisputes(status: statusFilter));
    } catch (e) {
      LoggingService.error('API disputes list failed: $e', tag: 'AdminService');
      return [];
    }
  }

  Future<bool> updateDisputeStatus(
          String disputeId, String status, String? resolution) =>
      _run(
          () => _api.updateDisputeStatus(disputeId, status,
              resolution: resolution),
          'update dispute');

  Future<List<Map<String, dynamic>>> getAllPayouts(
      {String? statusFilter}) async {
    try {
      return _results(await _api.listPayouts(status: statusFilter));
    } catch (e) {
      LoggingService.error('API payouts list failed: $e', tag: 'AdminService');
      return [];
    }
  }

  Future<bool> updatePayoutStatus(String payoutId, String status) =>
      _run(() => _api.updatePayoutStatus(payoutId, status), 'update payout');

  Future<List<Map<String, dynamic>>> getAllUsers(
      {String? roleFilter, String? search}) async {
    try {
      return _results(await _api.listUsers(role: roleFilter, search: search));
    } catch (e) {
      LoggingService.error('API users list failed: $e', tag: 'AdminService');
      return [];
    }
  }

  Future<bool> toggleUserActive(String userId) =>
      _run(() => _api.toggleUserActive(userId), 'toggle user status');

  Future<List<Map<String, dynamic>>> getAuditLogs({int limit = 50}) async {
    try {
      return _results(await _api.listAuditLogs()).take(limit).toList();
    } catch (e) {
      LoggingService.error('API audit log list failed: $e',
          tag: 'AdminService');
      return [];
    }
  }

  Future<bool> _run(Future<void> Function() action, String label) async {
    try {
      await action();
      return true;
    } catch (e) {
      LoggingService.error('API $label failed: $e', tag: 'AdminService');
      return false;
    }
  }
}
