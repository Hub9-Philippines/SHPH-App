import '/api/resources/tracking_api.dart';
import '/services/logging_service.dart';

class TrackingService {
  TrackingService._();
  static final TrackingService instance = TrackingService._();

  final _api = ShphTrackingApi.instance;

  Future<Map<String, dynamic>?> getEta(String token) async {
    try {
      return await _api.getEta(token);
    } catch (e) {
      LoggingService.error('Error fetching ETA: $e', tag: 'TrackingService');
      return null;
    }
  }
}
