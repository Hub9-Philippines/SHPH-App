import '/api/resources/rooms_api.dart';
import '/services/logging_service.dart';

class RoomsService {
  RoomsService._();
  static final RoomsService instance = RoomsService._();

  final _api = ShphRoomsApi.instance;

  Future<List<Map<String, dynamic>>> getRooms() async {
    try {
      final resp = await _api.list();
      final results = resp['results'] ?? resp['rooms'];
      if (results is List) {
        return results.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      LoggingService.error('Error fetching rooms: $e', tag: 'RoomsService');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getRoom(String id) async {
    try {
      return await _api.detail(id);
    } catch (e) {
      LoggingService.error('Error fetching room: $e', tag: 'RoomsService');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createRoom(Map<String, dynamic> payload) async {
    try {
      return await _api.create(payload);
    } catch (e) {
      LoggingService.error('Error creating room: $e', tag: 'RoomsService');
      return null;
    }
  }

  Future<Map<String, dynamic>?> joinRoom(String id, String token) async {
    try {
      return await _api.join(id, token);
    } catch (e) {
      LoggingService.error('Error joining room: $e', tag: 'RoomsService');
      return null;
    }
  }

  Future<bool> leaveRoom(String id) async {
    try {
      await _api.leave(id);
      return true;
    } catch (e) {
      LoggingService.error('Error leaving room: $e', tag: 'RoomsService');
      return false;
    }
  }

  Future<bool> lockRoom(String id) async {
    try {
      await _api.lock(id);
      return true;
    } catch (e) {
      LoggingService.error('Error locking room: $e', tag: 'RoomsService');
      return false;
    }
  }

  Future<bool> cancelRoom(String id) async {
    try {
      await _api.cancel(id);
      return true;
    } catch (e) {
      LoggingService.error('Error cancelling room: $e', tag: 'RoomsService');
      return false;
    }
  }

  Future<Map<String, dynamic>?> lookupByToken(String token) async {
    try {
      return await _api.byToken(token);
    } catch (e) {
      LoggingService.error('Error looking up room by token: $e',
          tag: 'RoomsService');
      return null;
    }
  }
}
