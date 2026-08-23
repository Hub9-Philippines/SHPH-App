import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/services/rooms_service.dart';
import 'room_list_widget.dart' show RoomListWidget;

class RoomListModel extends FlutterFlowModel<RoomListWidget> {
  List<Map<String, dynamic>> rooms = [];
  bool isLoading = true;

  @override
  void initState(BuildContext context) {}

  Future<void> loadRooms() async {
    isLoading = true;
    try {
      rooms = await RoomsService.instance.getRooms();
    } finally {
      isLoading = false;
    }
  }

  @override
  void dispose() {}
}
