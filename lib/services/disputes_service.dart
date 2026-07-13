import 'package:supabase_flutter/supabase_flutter.dart';

import '/api/bridges/api_row_mapper.dart';
import '/api/resources/disputes_api.dart';
import '/api/resources/users_api.dart';
import '/services/logging_service.dart';

class DisputesService {
  DisputesService._();
  static final DisputesService instance = DisputesService._();

  final _supabase = Supabase.instance.client;
  final _api = ShphDisputesApi.instance;

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  Future<List<Map<String, dynamic>>> getDisputes() async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        return await _api.listDisputes();
      } catch (e) {
        LoggingService.error(
          'SHPH API getDisputes failed, falling back: $e',
          tag: 'DisputesService',
        );
      }
    }

    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      final result = await _supabase
          .from('disputes')
          .select('''
            id,
            booking_id,
            raised_by,
            provider_id,
            reason,
            description,
            status,
            resolution,
            created_at,
            updated_at,
            dispute_evidence(id, file_url, file_type, description, created_at)
          ''')
          .or('raised_by.eq.$userId,provider_id.eq.$userId')
          .order('created_at', ascending: false);

      return result.cast<Map<String, dynamic>>();
    } catch (e) {
      LoggingService.error('Error fetching disputes: $e',
          tag: 'DisputesService');
      return [];
    }
  }

  Future<bool> createDispute({
    String? bookingId,
    required String reason,
    String? description,
    String? providerId,
  }) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        await _api.createDispute({
          if (bookingId != null) 'booking_id': bookingId,
          'reason': reason,
          if (description != null) 'description': description,
          if (providerId != null) 'provider_id': providerId,
        });
        return true;
      } catch (e) {
        LoggingService.error(
          'SHPH API createDispute failed, falling back: $e',
          tag: 'DisputesService',
        );
      }
    }

    final userId = _currentUserId;
    if (userId == null) return false;

    try {
      await _supabase.from('disputes').insert({
        'raised_by': userId,
        'booking_id': bookingId,
        'provider_id': providerId,
        'reason': reason,
        'description': description,
        'status': 'open',
      });
      return true;
    } catch (e) {
      LoggingService.error('Error creating dispute: $e',
          tag: 'DisputesService');
      return false;
    }
  }

  Future<bool> uploadEvidence({
    required String disputeId,
    required String fileUrl,
    String? fileType,
    String? description,
  }) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        await _api.uploadEvidence(disputeId, payload: {
          'file_url': fileUrl,
          if (fileType != null) 'file_type': fileType,
          if (description != null) 'description': description,
        });
        return true;
      } catch (e) {
        LoggingService.error(
          'SHPH API uploadEvidence failed, falling back: $e',
          tag: 'DisputesService',
        );
      }
    }

    final userId = _currentUserId;
    if (userId == null) return false;

    try {
      await _supabase.from('dispute_evidence').insert({
        'dispute_id': disputeId,
        'uploaded_by': userId,
        'file_url': fileUrl,
        'file_type': fileType,
        'description': description,
      });
      return true;
    } catch (e) {
      LoggingService.error('Error uploading evidence: $e',
          tag: 'DisputesService');
      return false;
    }
  }
}

class NotificationPreferencesService {
  NotificationPreferencesService._();
  static final NotificationPreferencesService instance =
      NotificationPreferencesService._();

  final _supabase = Supabase.instance.client;
  final _usersApi = ShphUsersApi.instance;

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  Future<Map<String, dynamic>> getPreferences() async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        return await _usersApi.getNotificationPreferences();
      } catch (e) {
        LoggingService.error(
          'SHPH API getPreferences failed, falling back: $e',
          tag: 'NotifPrefs',
        );
      }
    }

    final userId = _currentUserId;
    if (userId == null) return _defaults();

    try {
      final result = await _supabase
          .from('notification_preferences')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (result != null) {
        return result;
      }

      await _supabase.from('notification_preferences').insert({
        'user_id': userId,
      });

      return _defaults();
    } catch (e) {
      LoggingService.error('Error fetching notif prefs: $e',
          tag: 'NotifPrefs');
      return _defaults();
    }
  }

  Future<bool> updatePreferences(Map<String, dynamic> prefs) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        await _usersApi.updateNotificationPreferences(prefs);
        return true;
      } catch (e) {
        LoggingService.error(
          'SHPH API updatePreferences failed, falling back: $e',
          tag: 'NotifPrefs',
        );
      }
    }

    final userId = _currentUserId;
    if (userId == null) return false;

    try {
      prefs['updated_at'] = DateTime.now().toIso8601String();

      await _supabase
          .from('notification_preferences')
          .upsert({'user_id': userId, ...prefs});
      return true;
    } catch (e) {
      LoggingService.error('Error updating notif prefs: $e',
          tag: 'NotifPrefs');
      return false;
    }
  }

  Map<String, dynamic> _defaults() => {
        'push_enabled': true,
        'email_enabled': true,
        'sms_enabled': false,
        'booking_updates': true,
        'payment_updates': true,
        'promo_offers': false,
        'provider_alerts': true,
      };
}
