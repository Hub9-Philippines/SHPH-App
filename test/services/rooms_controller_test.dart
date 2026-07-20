import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/api/resources/rooms_api.dart';
import 'package:serbisyohubph/services/rooms_controller.dart';

import '../api/resources/rooms_api_test.dart'
    show FakeRoomsTransport, roomId, roomJson;

void main() {
  late FakeRoomsTransport transport;
  late RoomsController controller;

  setUp(() {
    transport = FakeRoomsTransport()..response = roomJson();
    controller = RoomsController(api: ShphRoomsApi(transport: transport));
  });

  test('loads, opens, and locks rooms', () async {
    transport.response = {
      'count': 1,
      'results': [roomJson()],
    };
    expect(await controller.load(), isTrue);
    transport.response = roomJson();
    expect(await controller.open(roomId), isTrue);
    transport.response = roomJson(status: 'locked');
    expect(await controller.lock(), isTrue);

    expect(controller.currentRoom?.isLocked, isTrue);
    expect(controller.rooms.single.isLocked, isTrue);
  });

  test('public preview is separate until a successful join', () async {
    expect(await controller.lookup('join-token'), isTrue);
    expect(controller.previewRoom?.id, roomId);
    expect(controller.currentRoom, isNull);

    expect(await controller.joinPreview('join-token'), isTrue);
    expect(controller.previewRoom, isNull);
    expect(controller.currentRoom?.id, roomId);
  });

  test('leave and cancel remove the selected room', () async {
    await controller.open(roomId);
    expect(await controller.leave(), isTrue);
    expect(controller.currentRoom, isNull);

    await controller.open(roomId);
    expect(await controller.cancel(), isTrue);
    expect(controller.currentRoom, isNull);
  });

  test('invalid ids fail before transport and expose no backend details',
      () async {
    expect(await controller.open('bad'), isFalse);
    expect(transport.requests, isEmpty);

    transport.response = {};
    expect(await controller.lookup('token'), isFalse);
    expect(controller.previewRoom, isNull);
    expect(controller.errorMessage, 'Unable to find a room for this token.');
  });
}
