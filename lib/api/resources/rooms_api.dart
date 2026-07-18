import '/api/models/paginated_response.dart';
import '/api/models/room.dart';
import '/api/shph_api_client.dart';

/// Rooms endpoints (`/api/services/rooms/*`).
///
/// Backend: `shph-api/services/rooms.py`. Room ids are 24-char ObjectId
/// strings (same as ServiceBooking), so all detail/action endpoints take a
/// `String` id, not an `int`.
class ShphRoomsApi {
  ShphRoomsApi._();

  static final ShphRoomsApi instance = ShphRoomsApi._();
  final _client = ShphApiClient.instance;

  /// POST `/api/services/rooms/` — create a new ROOM (requires KYC approval).
  Future<ShphRoom> create(Map<String, dynamic> payload) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/rooms/',
      data: payload,
    );
    return ShphRoom.fromJson(response.data ?? {});
  }

  /// POST `/api/services/rooms/list/` — list rooms visible to the current user.
  Future<PaginatedResponse<ShphRoom>> list({
    String? status,
    int? page,
    int? pageSize,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/rooms/list/',
      data: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (page != null) 'page': page,
        if (pageSize != null) 'page_size': pageSize,
      },
    );
    return PaginatedResponse.fromJson(
      response.data ?? {},
      ShphRoom.fromJson,
    );
  }

  /// POST `/api/services/rooms/<pk>/` — fetch a single room (POST-over-GET).
  Future<ShphRoom> detail(String id) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/rooms/$id/',
    );
    return ShphRoom.fromJson(response.data ?? {});
  }

  /// POST `/api/services/rooms/<pk>/join/` — join a room as a participant.
  Future<ShphRoom> join(String id, {String? joinToken}) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/rooms/$id/join/',
      data: {if (joinToken != null) 'join_token': joinToken},
    );
    return ShphRoom.fromJson(response.data ?? {});
  }

  /// POST `/api/services/rooms/<pk>/leave/` — leave a room.
  Future<ShphRoom> leave(String id) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/rooms/$id/leave/',
    );
    return ShphRoom.fromJson(response.data ?? {});
  }

  /// POST `/api/services/rooms/<pk>/lock/` — lock a room (organizer only).
  Future<ShphRoom> lock(String id) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/rooms/$id/lock/',
    );
    return ShphRoom.fromJson(response.data ?? {});
  }

  /// POST `/api/services/rooms/<pk>/cancel/` — cancel a room (organizer only).
  Future<ShphRoom> cancel(String id) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/rooms/$id/cancel/',
    );
    return ShphRoom.fromJson(response.data ?? {});
  }

  /// GET `/api/services/rooms/by-token/<token>/` — public lookup by join token.
  ///
  /// Public endpoint (no auth) used by the RoomJoinPage preview before the
  /// user taps "Join".
  Future<ShphRoom> byToken(String token) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/services/rooms/by-token/$token/',
    );
    return ShphRoom.fromJson(response.data ?? {});
  }
}
