import 'package:supabase_flutter/supabase_flutter.dart';

import '/api/bridges/api_row_mapper.dart';
import '/api/resources/admin_api.dart';
import '/services/logging_service.dart';

class AdminService {
  AdminService._();
  static final AdminService instance = AdminService._();

  final _supabase = Supabase.instance.client;
  final _api = ShphAdminApi.instance;

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  Future<bool> get isAdmin async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        return await _api.isAdmin();
      } catch (e) {
        LoggingService.error(
          'SHPH API isAdmin failed, falling back: $e',
          tag: 'AdminService',
        );
      }
    }

    final userId = _currentUserId;
    if (userId == null) return false;
    try {
      final result = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();
      return result?['role'] == 'admin';
    } catch (e) {
      LoggingService.error('Admin check failed: $e', tag: 'AdminService');
      return false;
    }
  }

  // ── Dashboard stats ──
  Future<Map<String, int>> getDashboardStats() async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        final data = await _api.getDashboardStats();
        return {
          'totalUsers': data['total_users'] ?? data['totalUsers'] ?? 0,
          'totalProviders': data['total_providers'] ?? data['totalProviders'] ?? 0,
          'pendingKyc': data['pending_kyc'] ?? data['pendingKyc'] ?? 0,
          'openDisputes': data['open_disputes'] ?? data['openDisputes'] ?? 0,
          'pendingPayouts': data['pending_payouts'] ?? data['pendingPayouts'] ?? 0,
          'activeListings': data['active_listings'] ?? data['activeListings'] ?? 0,
        } as Map<String, int>;
      } catch (e) {
        LoggingService.error(
          'SHPH API getDashboardStats failed, falling back: $e',
          tag: 'AdminService',
        );
      }
    }

    try {
      final users = await _supabase.from('profiles').select('id');
      final providers = await _supabase
          .from('profiles').select('id').eq('role', 'provider');
      final pendingKyc = await _supabase
          .from('profiles').select('id').eq('verification_status', 'pending');
      final openDisputes = await _supabase
          .from('disputes').select('id').eq('status', 'open');
      final pendingPayouts = await _supabase
          .from('payouts').select('id').eq('status', 'pending');
      final activeListings = await _supabase
          .from('service_listings').select('id').eq('status', 'active');

      return {
        'totalUsers': (users as List).length,
        'totalProviders': (providers as List).length,
        'pendingKyc': (pendingKyc as List).length,
        'openDisputes': (openDisputes as List).length,
        'pendingPayouts': (pendingPayouts as List).length,
        'activeListings': (activeListings as List).length,
      };
    } catch (e) {
      LoggingService.error('Error fetching dashboard stats: $e', tag: 'AdminService');
      return {};
    }
  }

  // ── KYC management ──
  Future<List<Map<String, dynamic>>> getKycSubmissions({String? statusFilter}) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        final data = await _api.listKycSubmissions(status: statusFilter);
        return (data['results'] as List?)?.cast<Map<String, dynamic>>() ??
               (data['data'] as List?)?.cast<Map<String, dynamic>>() ??
               [];
      } catch (e) {
        LoggingService.error(
          'SHPH API getKycSubmissions failed, falling back: $e',
          tag: 'AdminService',
        );
      }
    }

    try {
      final query = _supabase.from('profiles').select('''
        id, display_name, email, role, verification_status,
        id_document_url, face_scan_url, submitted_at, skill_profession
      ''');
      final filtered = (statusFilter != null && statusFilter != 'all')
          ? query.eq('verification_status', statusFilter)
          : query.neq('verification_status', 'not_submitted');
      final result = await filtered.order('submitted_at', ascending: false);
      return (result as List).cast<Map<String, dynamic>>();
    } catch (e) {
      LoggingService.error('Error fetching KYC submissions: $e', tag: 'AdminService');
      return [];
    }
  }

  Future<bool> updateKycStatus(String userId, String status) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        await _api.updateKycStatus(userId, status);
        return true;
      } catch (e) {
        LoggingService.error('SHPH API updateKycStatus failed, falling back: $e', tag: 'AdminService');
      }
    }

    try {
      await _supabase.from('profiles').update({
        'verification_status': status,
        'is_verified': status == 'verified',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      await _logAuditAction('kyc_status_update', targetUserId: userId, details: {'status': status});
      return true;
    } catch (e) {
      LoggingService.error('Error updating KYC status: $e', tag: 'AdminService');
      return false;
    }
  }

  // ── Disputes management ──
  Future<List<Map<String, dynamic>>> getAllDisputes({String? statusFilter}) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        final data = await _api.listDisputes(status: statusFilter);
        return (data['results'] as List?)?.cast<Map<String, dynamic>>() ??
               (data['data'] as List?)?.cast<Map<String, dynamic>>() ??
               [];
      } catch (e) {
        LoggingService.error('SHPH API getAllDisputes failed, falling back: $e', tag: 'AdminService');
      }
    }

    try {
      final query = _supabase.from('disputes').select('''
        id, booking_id, raised_by, provider_id, reason, description, status, resolution, created_at, updated_at
      ''');
      final filtered = (statusFilter != null && statusFilter != 'all')
          ? query.eq('status', statusFilter)
          : query;
      final result = await filtered.order('created_at', ascending: false);
      return (result as List).cast<Map<String, dynamic>>();
    } catch (e) {
      LoggingService.error('Error fetching all disputes: $e', tag: 'AdminService');
      return [];
    }
  }

  Future<bool> updateDisputeStatus(String disputeId, String status, String? resolution) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        await _api.updateDisputeStatus(disputeId, status, resolution: resolution);
        return true;
      } catch (e) {
        LoggingService.error('SHPH API updateDisputeStatus failed, falling back: $e', tag: 'AdminService');
      }
    }

    try {
      final updates = <String, dynamic>{'status': status, 'updated_at': DateTime.now().toIso8601String()};
      if (resolution != null) updates['resolution'] = resolution;
      await _supabase.from('disputes').update(updates).eq('id', disputeId);
      await _logAuditAction('dispute_status_update', targetId: disputeId, details: {'status': status});
      return true;
    } catch (e) {
      LoggingService.error('Error updating dispute: $e', tag: 'AdminService');
      return false;
    }
  }

  // ── Payouts management ──
  Future<List<Map<String, dynamic>>> getAllPayouts({String? statusFilter}) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        final data = await _api.listPayouts(status: statusFilter);
        return (data['results'] as List?)?.cast<Map<String, dynamic>>() ??
               (data['data'] as List?)?.cast<Map<String, dynamic>>() ??
               [];
      } catch (e) {
        LoggingService.error('SHPH API getAllPayouts failed, falling back: $e', tag: 'AdminService');
      }
    }

    try {
      final query = _supabase.from('payouts').select('''
        id, provider_id, amount, status, ewallet_id, note, created_at, processed_at
      ''');
      final filtered = (statusFilter != null && statusFilter != 'all')
          ? query.eq('status', statusFilter)
          : query;
      final result = await filtered.order('created_at', ascending: false);
      return (result as List).cast<Map<String, dynamic>>();
    } catch (e) {
      LoggingService.error('Error fetching payouts: $e', tag: 'AdminService');
      return [];
    }
  }

  Future<bool> updatePayoutStatus(String payoutId, String status) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        await _api.updatePayoutStatus(payoutId, status);
        return true;
      } catch (e) {
        LoggingService.error('SHPH API updatePayoutStatus failed, falling back: $e', tag: 'AdminService');
      }
    }

    try {
      final updates = <String, dynamic>{'status': status, 'processed_at': DateTime.now().toIso8601String()};
      await _supabase.from('payouts').update(updates).eq('id', payoutId);
      await _logAuditAction('payout_status_update', targetId: payoutId, details: {'status': status});
      return true;
    } catch (e) {
      LoggingService.error('Error updating payout: $e', tag: 'AdminService');
      return false;
    }
  }

  // ── Users management ──
  Future<List<Map<String, dynamic>>> getAllUsers({String? roleFilter, String? search}) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        final data = await _api.listUsers(role: roleFilter, search: search);
        return (data['results'] as List?)?.cast<Map<String, dynamic>>() ??
               (data['data'] as List?)?.cast<Map<String, dynamic>>() ??
               [];
      } catch (e) {
        LoggingService.error('SHPH API getAllUsers failed, falling back: $e', tag: 'AdminService');
      }
    }

    try {
      final query = _supabase.from('profiles').select('''
        id, display_name, email, role, phone_number, verification_status, is_verified, skill_profession, created_at
      ''');
      var filtered = query;
      if (roleFilter != null && roleFilter != 'all') {
        filtered = filtered.eq('role', roleFilter);
      }
      if (search != null && search.isNotEmpty) {
        filtered = filtered.or('display_name.ilike.%$search%,email.ilike.%$search%');
      }
      final result = await filtered.order('created_at', ascending: false);
      return (result as List).cast<Map<String, dynamic>>();
    } catch (e) {
      LoggingService.error('Error fetching users: $e', tag: 'AdminService');
      return [];
    }
  }

  Future<bool> updateUserRole(String userId, String role) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        await _api.updateUserRole(userId, role);
        return true;
      } catch (e) {
        LoggingService.error('SHPH API updateUserRole failed, falling back: $e', tag: 'AdminService');
      }
    }

    try {
      await _supabase.from('profiles').update({
        'role': role, 'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      await _logAuditAction('user_role_update', targetUserId: userId, details: {'role': role});
      return true;
    } catch (e) {
      LoggingService.error('Error updating user role: $e', tag: 'AdminService');
      return false;
    }
  }

  // ── Audit logs ──
  Future<List<Map<String, dynamic>>> getAuditLogs({int limit = 50}) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        final data = await _api.listAuditLogs();
        return (data['results'] as List?)?.cast<Map<String, dynamic>>() ??
               (data['data'] as List?)?.cast<Map<String, dynamic>>() ??
               [];
      } catch (e) {
        LoggingService.error('SHPH API getAuditLogs failed, falling back: $e', tag: 'AdminService');
      }
    }

    try {
      final result = await _supabase.from('audit_logs').select('''
        id, admin_id, action, target_id, target_user_id, details, created_at
      ''').order('created_at', ascending: false).limit(limit);
      return (result as List).cast<Map<String, dynamic>>();
    } catch (e) {
      LoggingService.error('Error fetching audit logs: $e', tag: 'AdminService');
      return [];
    }
  }

  Future<void> _logAuditAction(String action, {String? targetId, String? targetUserId, Map<String, dynamic>? details}) async {
    final adminId = _currentUserId;
    if (adminId == null) return;
    try {
      await _supabase.from('audit_logs').insert({
        'admin_id': adminId, 'action': action,
        'target_id': targetId, 'target_user_id': targetUserId,
        'details': details, 'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      LoggingService.error('Error logging audit action: $e', tag: 'AdminService');
    }
  }
}
