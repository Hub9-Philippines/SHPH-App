import '/api/resources/availability_api.dart';
import '/services/logging_service.dart';

class AvailabilityService {
  AvailabilityService._();
  static final AvailabilityService instance = AvailabilityService._();

  final _api = ShphAvailabilityApi.instance;

  Future<List<Map<String, dynamic>>> getSlots({
    String? providerId,
    String? date,
  }) async {
    try {
      return await _api.listSlots(providerId: providerId, date: date);
    } catch (e) {
      LoggingService.error('Error fetching slots: $e',
          tag: 'AvailabilityService');
      return [];
    }
  }

  Future<Map<String, dynamic>?> createSlot({
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    try {
      return await _api.createSlot(
        date: date,
        startTime: startTime,
        endTime: endTime,
      );
    } catch (e) {
      LoggingService.error('Error creating slot: $e',
          tag: 'AvailabilityService');
      return null;
    }
  }

  Future<bool> deleteSlot(String slotId) async {
    try {
      await _api.deleteSlot(slotId);
      return true;
    } catch (e) {
      LoggingService.error('Error deleting slot: $e',
          tag: 'AvailabilityService');
      return false;
    }
  }

  Future<bool> toggleSlot(String slotId, {bool? isAvailable}) async {
    try {
      await _api.toggleSlot(slotId, isAvailable: isAvailable);
      return true;
    } catch (e) {
      LoggingService.error('Error toggling slot: $e',
          tag: 'AvailabilityService');
      return false;
    }
  }
}
