import '/api/shph_api_client.dart';

/// Admin endpoints (`/api/admin/*`).
class ShphAdminApi {
  ShphAdminApi._();

  static final ShphAdminApi instance = ShphAdminApi._();
  final _client = ShphApiClient.instance;

  /// GET /api/admin/me/ - check if current user is admin
  Future<bool> isAdmin() async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/api/users/me/',
      );
      final data = response.data ?? {};
      return data['is_admin'] == true ||
          data['is_staff'] == true ||
          data['role'] == 'admin';
    } catch (_) {
      return false;
    }
  }

  /// GET /api/admin/dashboard/ - get admin dashboard stats
  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/admin/stats/',
    );
    return response.data ?? {};
  }

  /// GET /api/admin/users/ - list all users (admin)
  Future<Map<String, dynamic>> listUsers({
    String? role,
    String? search,
    int? page,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/users/admin/list/',
      queryParameters: {
        if (role != null) 'role': role,
        if (search != null && search.isNotEmpty) 'search': search,
        if (page != null) 'page': page,
      },
    );
    return response.data ?? {};
  }

  /// POST /api/users/admin/{id}/toggle-active/ - activate/deactivate a user.
  Future<void> toggleUserActive(String userId) async {
    await _client.post('/api/users/admin/$userId/toggle-active/');
  }

  /// GET /api/admin/kyc/ - list KYC submissions
  Future<Map<String, dynamic>> listKycSubmissions(
      {String? status, int? page}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/kyc/admin/',
      queryParameters: {
        if (status != null) 'status': status,
        if (page != null) 'page': page,
      },
    );
    return response.data ?? {};
  }

  /// POST /api/kyc/admin/{id}/{action}/ - approve or reject KYC.
  Future<void> updateKycStatus(String userId, String status,
      {String? rejectionReason}) async {
    final action = status == 'verified' || status == 'approved'
        ? 'approve'
        : status == 'rejected'
            ? 'reject'
            : status;
    await _client.post(
      '/api/kyc/admin/$userId/$action/',
      data: {if (rejectionReason != null) 'reason': rejectionReason},
    );
  }

  /// GET /api/admin/disputes/ - list all disputes
  Future<Map<String, dynamic>> listDisputes({String? status, int? page}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/disputes/admin/',
      queryParameters: {
        if (status != null) 'status': status,
        if (page != null) 'page': page,
      },
    );
    return response.data ?? {};
  }

  /// POST /api/disputes/admin/{id}/{action}/ - update dispute status.
  Future<void> updateDisputeStatus(String disputeId, String status,
      {String? resolution}) async {
    await _client.post(
      '/api/disputes/admin/$disputeId/$status/',
      data: {if (resolution != null) 'admin_notes': resolution},
    );
  }

  /// GET /api/admin/payouts/ - list all payout requests
  Future<Map<String, dynamic>> listPayouts({String? status, int? page}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/earnings/admin/payouts/',
      queryParameters: {
        if (status != null) 'status': status,
        if (page != null) 'page': page,
      },
    );
    return response.data ?? {};
  }

  /// POST /api/earnings/admin/payouts/{id}/{action}/ - payout action.
  Future<void> updatePayoutStatus(String payoutId, String status) async {
    await _client.post('/api/earnings/admin/payouts/$payoutId/$status/');
  }

  /// GET /api/admin/audit-logs/ - list audit logs
  Future<Map<String, dynamic>> listAuditLogs({int? page}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/audit/recent/',
      queryParameters: {if (page != null) 'page': page},
    );
    return response.data ?? {};
  }
}
