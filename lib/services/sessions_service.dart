import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '/services/logging_service.dart';

class SessionsService {
  SessionsService._();
  static final SessionsService instance = SessionsService._();

  final _supabase = Supabase.instance.client;
  static const _sessionPrefKey = 'current_session_id';

  Future<String> get _deviceInfo async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        return '${info.brand} ${info.model}';
      } else if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        return info.utsname.machine ?? 'iOS Device';
      }
      return 'Unknown Device';
    } catch (e) {
      return 'Unknown Device';
    }
  }

  Future<String> get _platformName async {
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    return 'Unknown';
  }

  Future<String?> getCurrentSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionPrefKey);
  }

  Future<void> recordSession() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final deviceName = await _deviceInfo;
      final platform = await _platformName;
      final sessionId =
          '${userId}_${DateTime.now().millisecondsSinceEpoch}';

      await _supabase.from('user_sessions').insert({
        'id': sessionId,
        'user_id': userId,
        'device_name': deviceName,
        'platform': platform,
        'last_active': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionPrefKey, sessionId);
    } catch (e) {
      LoggingService.error('Error recording session: $e',
          tag: 'SessionsService');
    }
  }

  Future<void> updateLastActive() async {
    final sessionId = await getCurrentSessionId();
    if (sessionId == null) return;

    try {
      await _supabase
          .from('user_sessions')
          .update({'last_active': DateTime.now().toIso8601String()})
          .eq('id', sessionId);
    } catch (e) {
      LoggingService.error('Error updating last active: $e',
          tag: 'SessionsService');
    }
  }

  Future<List<Map<String, dynamic>>> getActiveSessions() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final result = await _supabase
          .from('user_sessions')
          .select('id, device_name, platform, last_active, created_at')
          .eq('user_id', userId)
          .order('last_active', ascending: false);
      return (result as List).cast<Map<String, dynamic>>();
    } catch (e) {
      LoggingService.error('Error fetching sessions: $e',
          tag: 'SessionsService');
      return [];
    }
  }

  Future<bool> revokeSession(String sessionId) async {
    try {
      await _supabase
          .from('user_sessions')
          .delete()
          .eq('id', sessionId);
      return true;
    } catch (e) {
      LoggingService.error('Error revoking session: $e',
          tag: 'SessionsService');
      return false;
    }
  }

  Future<void> clearCurrentSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionPrefKey);
  }
}
