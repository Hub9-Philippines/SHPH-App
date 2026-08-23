import '/api/resources/notifications_prefs_api.dart';
import '/services/logging_service.dart';

class NotificationsPrefsService {
  NotificationsPrefsService._();
  static final NotificationsPrefsService instance =
      NotificationsPrefsService._();

  final _api = ShphNotificationsPrefsApi.instance;

  Future<Map<String, dynamic>> getPreferences() async {
    try {
      return await _api.getPreferences();
    } catch (e) {
      LoggingService.error('Error fetching notification prefs: $e',
          tag: 'NotificationsPrefsService');
      return {};
    }
  }

  Future<bool> updatePreferences(Map<String, dynamic> payload) async {
    try {
      final resp = await _api.updatePreferences(payload);
      return resp['status'] == 'ok' || resp['status'] == 'success';
    } catch (e) {
      LoggingService.error('Error updating notification prefs: $e',
          tag: 'NotificationsPrefsService');
      return false;
    }
  }
}
