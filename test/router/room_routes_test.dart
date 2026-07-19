import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/pages/rooms/room_create_page.dart';
import 'package:serbisyohubph/pages/rooms/room_detail_page.dart';
import 'package:serbisyohubph/pages/rooms/room_join_page.dart';
import 'package:serbisyohubph/pages/rooms/room_list_page.dart';
import 'package:serbisyohubph/router/room_routes.dart';

void main() {
  test('all room route surfaces use the protected prefix', () {
    expect(isProtectedRoomPath(RoomListPage.routePath), isTrue);
    expect(isProtectedRoomPath(RoomCreatePage.routePath), isTrue);
    expect(isProtectedRoomPath(RoomJoinPage.routePath), isTrue);
    expect(isProtectedRoomPath(RoomDetailPage.routePath), isTrue);
    expect(isProtectedRoomPath('/rooms-archive'), isFalse);
  });

  test('accepts only 24-character hexadecimal room ids', () {
    const id = '0123456789abcdef01234567';
    expect(parseRoomRouteId(id), id);
    expect(parseRoomRouteId('ABCDEFABCDEFABCDEFABCDEF'), hasLength(24));
    expect(parseRoomRouteId(null), isEmpty);
    expect(parseRoomRouteId('short'), isEmpty);
    expect(parseRoomRouteId('zzzzzzzzzzzzzzzzzzzzzzzz'), isEmpty);
  });
}
