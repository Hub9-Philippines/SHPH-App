import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/api/resources/rooms_api.dart';

const roomId = '0123456789abcdef01234567';

void main() {
  late FakeRoomsTransport transport;
  late ShphRoomsApi api;

  setUp(() {
    transport = FakeRoomsTransport();
    api = ShphRoomsApi(transport: transport);
    transport.response = roomJson();
  });

  test('uses verified POST-over-GET room paths', () async {
    await api.detail(roomId);
    expect(transport.last.path, '/api/services/rooms/$roomId/');
    await api.lock(roomId);
    expect(transport.last.path, '/api/services/rooms/$roomId/lock/');
    await api.leave(roomId);
    expect(transport.last.path, '/api/services/rooms/$roomId/leave/');
    await api.cancel(roomId);
    expect(transport.last.path, '/api/services/rooms/$roomId/cancel/');
  });

  test('validates create and list payloads', () async {
    await api.create({
      'category': 4,
      'title': 'Room',
      'event_date': '2026-08-01',
      'event_time': '10:00',
      'heads_required': 3,
      'price_per_head': '100.00',
    });
    expect(transport.last.path, '/api/services/rooms/');

    transport.response = {
      'count': 1,
      'results': [roomJson()],
    };
    final result = await api.list(status: ' open ', page: 1, pageSize: 20);
    expect(result.results.single.id, roomId);
    expect(transport.last.data, {
      'status': 'open',
      'page': 1,
      'page_size': 20,
    });
  });

  test('joins with a trimmed token and encodes public lookup tokens', () async {
    await api.join(roomId, joinToken: ' token/value ');
    expect(transport.last.data, {'join_token': 'token/value'});

    await api.byToken(' token/value ');
    expect(
      transport.last.path,
      '/api/services/rooms/by-token/token%2Fvalue/',
    );
    expect(transport.last.method, 'GET');
  });

  test('rejects malformed identifiers, tokens, and payloads before transport',
      () async {
    expect(api.detail('bad'), throwsFormatException);
    expect(api.byToken(' '), throwsFormatException);
    expect(api.list(page: 0), throwsFormatException);
    expect(
      api.create({
        'category': 1,
        'title': 'Room',
        'event_date': '2026-08-01',
        'event_time': '10:00',
        'heads_required': 1,
        'price_per_head': 0,
      }),
      throwsFormatException,
    );
    expect(transport.requests, isEmpty);
  });
}

Map<String, dynamic> roomJson({String status = 'open'}) => {
      'id': roomId,
      'title': 'Room',
      'category': 4,
      'heads_required': 3,
      'price_per_head': '100.00',
      'event_date': '2026-08-01',
      'event_time': '10:00',
      'status': status,
      'seats_remaining': 2,
    };

class FakeRoomsTransport implements RoomsApiTransport {
  final List<RoomRequest> requests = [];
  Map<String, dynamic> response = {};
  RoomRequest get last => requests.last;

  @override
  Future<Map<String, dynamic>> get(String path) async {
    requests.add(RoomRequest('GET', path, null));
    return response;
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    requests.add(RoomRequest('POST', path, data));
    return response;
  }
}

class RoomRequest {
  const RoomRequest(this.method, this.path, this.data);
  final String method;
  final String path;
  final Map<String, dynamic>? data;
}
