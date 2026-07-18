import '/api/shph_api_client.dart';

/// Admin endpoints from SHPH API (`/api/admin/*`, `/api/kyc/admin/*`, etc.).
class ShphAdminApi {
  ShphAdminApi._();

  static final ShphAdminApi instance = ShphAdminApi._();
  final _client = ShphApiClient.instance;

  // Dashboard stats
  Future<Map<String, dynamic>> getStats() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/admin/stats/',
    );
    return response.data ?? {};
  }

  // KYC management
  Future<List<Map<String, dynamic>>> listKyc({
    String? status,
    int? page,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/kyc/admin/',
      queryParameters: {
        if (status != null) 'status': status,
        if (page != null) 'page': page,
      },
    );
    final data = response.data;
    final results = data?['results'];
    if (results is List) {
      return results.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> approveKyc(int id) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/kyc/admin/$id/approve/',
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> rejectKyc(int id, String rejectionReason) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/kyc/admin/$id/reject/',
      data: {'rejection_reason': rejectionReason},
    );
    return response.data ?? {};
  }

  // Disputes management
  Future<List<Map<String, dynamic>>> listAdminDisputes({
    String? status,
    int? page,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/disputes/admin/',
      queryParameters: {
        if (status != null) 'status': status,
        if (page != null) 'page': page,
      },
    );
    final data = response.data;
    final results = data?['results'];
    if (results is List) {
      return results.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> reviewDispute(int id) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/disputes/admin/$id/review/',
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> resolveDispute(
    int id,
    String adminNotes,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/disputes/admin/$id/resolve/',
      data: {'admin_notes': adminNotes},
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> closeDispute(
    int id,
    String adminNotes,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/disputes/admin/$id/close/',
      data: {'admin_notes': adminNotes},
    );
    return response.data ?? {};
  }

  // Payouts management
  Future<List<Map<String, dynamic>>> listAdminPayouts({
    String? status,
    int? page,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/earnings/admin/payouts/',
      queryParameters: {
        if (status != null) 'status': status,
        if (page != null) 'page': page,
      },
    );
    final data = response.data;
    final results = data?['results'];
    if (results is List) {
      return results.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> approvePayout(int id) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/earnings/admin/payouts/$id/approve/',
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> completePayout(int id) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/earnings/admin/payouts/$id/complete/',
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> rejectPayout(int id, String reason) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/earnings/admin/payouts/$id/reject/',
      data: {'reason': reason},
    );
    return response.data ?? {};
  }

  // Refunds
  Future<Map<String, dynamic>> refundPayment(
    String bookingId,
    String reason,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/payments/booking/$bookingId/refund/',
      data: {'reason': reason},
    );
    return response.data ?? {};
  }

  // Users management
  Future<List<Map<String, dynamic>>> listUsers({
    int? page,
    String? search,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/users/admin/list/',
      queryParameters: {
        if (page != null) 'page': page,
        if (search != null) 'search': search,
      },
    );
    final data = response.data;
    final results = data?['results'];
    if (results is List) {
      return results.whereType<Map<String, dynamic>>().toList();
    }
    final users = data?['users'];
    if (users is List) {
      return users.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> toggleUserActive(int userId) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/users/admin/$userId/toggle-active/',
    );
    return response.data ?? {};
  }

  // Audit logs
  Future<List<Map<String, dynamic>>> getAuditRecent({int limit = 50}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/audit/recent/',
      queryParameters: {'limit': limit},
    );
    final data = response.data;
    if (data is List) {
      return (data! as List).whereType<Map<String, dynamic>>().toList();
    }
    final results = data?['results'];
    if (results is List) {
      return results.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }
}
