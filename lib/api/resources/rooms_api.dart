import '/api/models/paginated_response.dart';
import '/api/models/room.dart';
import '/api/shph_api_client.dart';

abstract interface class RoomsApiTransport {
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  });

  Future<Map<String, dynamic>> get(String path);
}

class ShphRoomsApiTransport implements RoomsApiTransport {
  const ShphRoomsApiTransport();

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    final response = await ShphApiClient.instance.post<Map<String, dynamic>>(
      path,
      data: data,
    );
    return response.data ?? {};
  }

  @override
  Future<Map<String, dynamic>> get(String path) async {
    final response =
        await ShphApiClient.instance.get<Map<String, dynamic>>(path);
    return response.data ?? {};
  }
}

class ShphRoomsApi {
  ShphRoomsApi({RoomsApiTransport? transport})
      : _transport = transport ?? const ShphRoomsApiTransport();

  static final ShphRoomsApi instance = ShphRoomsApi();
  final RoomsApiTransport _transport;

  Future<ShphRoom> create(Map<String, dynamic> payload) async {
    _validateCreate(payload);
    return _room(
      await _transport.post('/api/services/rooms/', data: payload),
    );
  }

  Future<PaginatedResponse<ShphRoom>> list({
    String? status,
    int? page,
    int? pageSize,
  }) async {
    _validatePage(page, pageSize);
    final normalizedStatus = status?.trim();
    final data = await _transport.post(
      '/api/services/rooms/list/',
      data: {
        if (normalizedStatus != null && normalizedStatus.isNotEmpty)
          'status': normalizedStatus,
        if (page != null) 'page': page,
        if (pageSize != null) 'page_size': pageSize,
      },
    );
    return PaginatedResponse.fromJson(data, _room);
  }

  Future<ShphRoom> detail(String id) async => _room(
        await _transport.post('/api/services/rooms/${validRoomId(id)}/'),
      );

  Future<ShphRoom> join(String id, {required String joinToken}) async {
    final token = validJoinToken(joinToken);
    return _room(
      await _transport.post(
        '/api/services/rooms/${validRoomId(id)}/join/',
        data: {'join_token': token},
      ),
    );
  }

  Future<ShphRoom> leave(String id) async => _room(
        await _transport.post('/api/services/rooms/${validRoomId(id)}/leave/'),
      );

  Future<ShphRoom> lock(String id) async => _room(
        await _transport.post('/api/services/rooms/${validRoomId(id)}/lock/'),
      );

  Future<ShphRoom> cancel(String id) async => _room(
        await _transport.post('/api/services/rooms/${validRoomId(id)}/cancel/'),
      );

  Future<ShphRoom> byToken(String token) async => _room(
        await _transport.get(
          '/api/services/rooms/by-token/${Uri.encodeComponent(validJoinToken(token))}/',
        ),
      );

  static String validRoomId(String value) {
    final id = value.trim();
    if (!RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(id)) {
      throw const FormatException('Invalid room id');
    }
    return id;
  }

  static String validJoinToken(String value) {
    final token = value.trim();
    if (token.isEmpty || token.length > 256) {
      throw const FormatException('Invalid room join token');
    }
    return token;
  }

  static void _validatePage(int? page, int? pageSize) {
    if (page != null && page <= 0) {
      throw const FormatException('Page must be positive');
    }
    if (pageSize != null && (pageSize <= 0 || pageSize > 100)) {
      throw const FormatException('Page size must be between 1 and 100');
    }
  }

  static void _validateCreate(Map<String, dynamic> payload) {
    final category = int.tryParse(payload['category']?.toString() ?? '');
    final title = payload['title']?.toString().trim() ?? '';
    final date = payload['event_date']?.toString().trim() ?? '';
    final time = payload['event_time']?.toString().trim() ?? '';
    final heads = int.tryParse(payload['heads_required']?.toString() ?? '');
    final price = double.tryParse(payload['price_per_head']?.toString() ?? '');
    if (category == null ||
        category <= 0 ||
        title.isEmpty ||
        date.isEmpty ||
        time.isEmpty ||
        heads == null ||
        heads < 2 ||
        price == null ||
        !price.isFinite ||
        price <= 0) {
      throw const FormatException('Invalid room creation payload');
    }
  }

  static ShphRoom _room(Map<String, dynamic> data) {
    final room = ShphRoom.fromJson(data);
    validRoomId(room.id);
    return room;
  }
}
