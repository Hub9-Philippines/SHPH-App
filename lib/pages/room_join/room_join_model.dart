import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/l10n/app_localizations.dart';
import '/services/rooms_service.dart';
import 'room_join_widget.dart' show RoomJoinWidget;

class RoomJoinModel extends FlutterFlowModel<RoomJoinWidget> {
  String token = '';
  Map<String, dynamic>? preview;
  bool isLookingUp = false;
  bool isJoining = false;
  String? errorMsg;

  @override
  void initState(BuildContext context) {}

  Future<void> lookup(AppLocalizations l10n) async {
    if (token.trim().isEmpty) return;
    isLookingUp = true;
    errorMsg = null;
    try {
      preview = await RoomsService.instance.lookupByToken(token.trim());
      if (preview == null || preview!['id'] == null) {
        errorMsg = l10n.rjRoomNotFound;
        preview = null;
      }
    } finally {
      isLookingUp = false;
    }
  }

  Future<String?> join() async {
    final id = preview?['id']?.toString();
    if (id == null) return null;
    isJoining = true;
    try {
      final result = await RoomsService.instance.joinRoom(id, token.trim());
      return result?['id']?.toString();
    } finally {
      isJoining = false;
    }
  }

  @override
  void dispose() {}
}
