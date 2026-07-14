import 'package:shared_preferences/shared_preferences.dart';

import '/api/resources/auth_api.dart';
import '/services/logging_service.dart';

class SessionsService {
  SessionsService._();
  static final SessionsService instance = SessionsService._();
  static const _sessionPrefKey = 'current_session_id';

  Future<String?> getCurrentSessionId() async =>
      (await SharedPreferences.getInstance()).getString(_sessionPrefKey);

  Future<void> recordSession() async {
    final sessions = await getActiveSessions();
    if (sessions.isEmpty) return;
    final id = sessions.first['id']?.toString();
    if (id != null) {
      await (await SharedPreferences.getInstance())
          .setString(_sessionPrefKey, id);
    }
  }

  Future<void> updateLastActive() async {
    // JWT session activity is updated server-side by authenticated requests.
  }

  Future<List<Map<String, dynamic>>> getActiveSessions() async {
    try {
      return await ShphAuthApi.instance.listSessions();
    } catch (e) {
      LoggingService.error('Session fetch failed: $e', tag: 'SessionsService');
      return [];
    }
  }

  Future<bool> revokeSession(String id) async {
    try {
      await ShphAuthApi.instance.revokeSession(id);
      return true;
    } catch (e) {
      LoggingService.error('Session revoke failed: $e', tag: 'SessionsService');
      return false;
    }
  }

  Future<void> clearCurrentSession() async =>
      (await SharedPreferences.getInstance()).remove(_sessionPrefKey);
}
