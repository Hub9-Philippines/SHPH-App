import '/api/resources/disputes_api.dart';
import '/api/resources/users_api.dart';
import '/services/logging_service.dart';

class DisputesService {
  DisputesService._();
  static final DisputesService instance = DisputesService._();
  final _api = ShphDisputesApi.instance;

  Future<List<Map<String, dynamic>>> getDisputes() async {
    try {
      return await _api.listDisputes();
    } catch (e) {
      LoggingService.error('Dispute fetch failed: $e', tag: 'DisputesService');
      return [];
    }
  }

  Future<bool> createDispute(
          {String? bookingId,
          required String reason,
          String? description,
          String? providerId}) =>
      _run(() => _api.createDispute({
            if (bookingId != null) 'booking_id': bookingId,
            'reason': reason,
            if (description != null) 'description': description,
            if (providerId != null) 'provider_id': providerId,
          }));

  Future<bool> uploadEvidence(
          {required String disputeId,
          required String fileUrl,
          String? fileType,
          String? description}) =>
      _run(() => _api.uploadEvidence(disputeId, payload: {
            'file_url': fileUrl,
            if (fileType != null) 'file_type': fileType,
            if (description != null) 'description': description,
          }));

  Future<bool> _run(Future<Object?> Function() operation) async {
    try {
      await operation();
      return true;
    } catch (e) {
      LoggingService.error('Dispute operation failed: $e',
          tag: 'DisputesService');
      return false;
    }
  }
}

class NotificationPreferencesService {
  NotificationPreferencesService._();
  static final NotificationPreferencesService instance =
      NotificationPreferencesService._();
  final _api = ShphUsersApi.instance;

  Future<Map<String, dynamic>> getPreferences() async {
    try {
      return await _api.getNotificationPreferences();
    } catch (e) {
      LoggingService.error('Preference fetch failed: $e', tag: 'NotifPrefs');
      return _defaults();
    }
  }

  Future<bool> updatePreferences(Map<String, dynamic> prefs) async {
    try {
      await _api.updateNotificationPreferences(prefs);
      return true;
    } catch (e) {
      LoggingService.error('Preference update failed: $e', tag: 'NotifPrefs');
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
        'provider_alerts': true
      };
}
