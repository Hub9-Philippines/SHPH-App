bool isProtectedRoomPath(String path) =>
    path == '/rooms' || path.startsWith('/rooms/');

String parseRoomRouteId(String? value) {
  final id = value?.trim() ?? '';
  return RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(id) ? id : '';
}
