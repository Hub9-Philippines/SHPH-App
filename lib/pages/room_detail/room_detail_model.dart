import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/services/rooms_service.dart';
import 'room_detail_widget.dart' show RoomDetailWidget;

class RoomDetailModel extends FlutterFlowModel<RoomDetailWidget> {
  Map<String, dynamic>? room;
  bool isLoading = true;

  @override
  void initState(BuildContext context) {}

  Future<void> loadRoom(String id) async {
    isLoading = true;
    try {
      room = await RoomsService.instance.getRoom(id);
    } finally {
      isLoading = false;
    }
  }

  Future<bool> lockRoom() async {
    final id = room?['id']?.toString();
    if (id == null) return false;
    final ok = await RoomsService.instance.lockRoom(id);
    if (ok) room?['status'] = 'locked';
    return ok;
  }

  Future<bool> cancelRoom() async {
    final id = room?['id']?.toString();
    if (id == null) return false;
    final ok = await RoomsService.instance.cancelRoom(id);
    if (ok) room?['status'] = 'cancelled';
    return ok;
  }

  Future<bool> leaveRoom() async {
    final id = room?['id']?.toString();
    if (id == null) return false;
    return await RoomsService.instance.leaveRoom(id);
  }

  @override
  void dispose() {}
}
