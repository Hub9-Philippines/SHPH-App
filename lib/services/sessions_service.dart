import '/api/resources/sessions_api.dart';
import '/services/logging_service.dart';

class SessionsService {
  SessionsService._();
  static final SessionsService instance = SessionsService._();

  final _api = ShphSessionsApi.instance;

  Future<List<Map<String, dynamic>>> getSessions() async {
    try {
      final resp = await _api.listSessions();
      final results = resp['results'] ?? resp['sessions'];
      if (results is List) {
        return results.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      LoggingService.error('Error fetching sessions: $e',
          tag: 'SessionsService');
      return [];
    }
  }

  Future<bool> revokeSession(String sessionId) async {
    try {
      await _api.revokeSession(sessionId);
      return true;
    } catch (e) {
      LoggingService.error('Error revoking session: $e',
          tag: 'SessionsService');
      return false;
    }
  }

  Future<bool> revokeAllSessions() async {
    try {
      await _api.revokeAllSessions();
      return true;
    } catch (e) {
      LoggingService.error('Error revoking all sessions: $e',
          tag: 'SessionsService');
      return false;
    }
  }
}
