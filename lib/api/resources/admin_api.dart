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
        '/api/admin/me/',
      );
      return response.data?['is_admin'] == true;
    } catch (_) {
      return false;
    }
  }

  /// GET /api/admin/dashboard/ - get admin dashboard stats
  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/admin/dashboard/',
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
      '/api/admin/users/',
      queryParameters: {
        if (role != null) 'role': role,
        if (search != null && search.isNotEmpty) 'search': search,
        if (page != null) 'page': page,
      },
    );
    return response.data ?? {};
  }

  /// PATCH /api/admin/users/{id}/role/ - update user role
  Future<void> updateUserRole(String userId, String role) async {
    await _client.patch(
      '/api/admin/users/$userId/role/',
      data: {'role': role},
    );
  }

  /// GET /api/admin/kyc/ - list KYC submissions
  Future<Map<String, dynamic>> listKycSubmissions({String? status, int? page}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/admin/kyc/',
      queryParameters: {
        if (status != null) 'status': status,
        if (page != null) 'page': page,
      },
    );
    return response.data ?? {};
  }

  /// PATCH /api/admin/kyc/{userId}/ - update KYC status
  Future<void> updateKycStatus(String userId, String status, {String? rejectionReason}) async {
    await _client.patch(
      '/api/admin/kyc/$userId/',
      data: {
        'status': status,
        if (rejectionReason != null) 'rejection_reason': rejectionReason,
      },
    );
  }

  /// GET /api/admin/disputes/ - list all disputes
  Future<Map<String, dynamic>> listDisputes({String? status, int? page}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/admin/disputes/',
      queryParameters: {
        if (status != null) 'status': status,
        if (page != null) 'page': page,
      },
    );
    return response.data ?? {};
  }

  /// PATCH /api/admin/disputes/{id}/ - update dispute status
  Future<void> updateDisputeStatus(String disputeId, String status, {String? resolution}) async {
    await _client.patch(
      '/api/admin/disputes/$disputeId/',
      data: {
        'status': status,
        if (resolution != null) 'resolution': resolution,
      },
    );
  }

  /// GET /api/admin/payouts/ - list all payout requests
  Future<Map<String, dynamic>> listPayouts({String? status, int? page}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/admin/payouts/',
      queryParameters: {
        if (status != null) 'status': status,
        if (page != null) 'page': page,
      },
    );
    return response.data ?? {};
  }

  /// PATCH /api/admin/payouts/{id}/ - update payout status
  Future<void> updatePayoutStatus(String payoutId, String status) async {
    await _client.patch(
      '/api/admin/payouts/$payoutId/',
      data: {'status': status},
    );
  }

  /// GET /api/admin/audit-logs/ - list audit logs
  Future<Map<String, dynamic>> listAuditLogs({int? page}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/admin/audit-logs/',
      queryParameters: {if (page != null) 'page': page},
    );
    return response.data ?? {};
  }
}
