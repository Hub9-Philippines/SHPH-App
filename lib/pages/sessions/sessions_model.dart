import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/services/sessions_service.dart';
import 'sessions_widget.dart' show SessionsWidget;

class SessionsModel extends FlutterFlowModel<SessionsWidget> {
  List<Map<String, dynamic>> sessions = [];
  bool isLoading = true;
  bool isRevokingAll = false;

  @override
  void initState(BuildContext context) {}

  Future<void> loadSessions() async {
    isLoading = true;
    try {
      sessions = await SessionsService.instance.getSessions();
    } finally {
      isLoading = false;
    }
  }

  Future<bool> revokeSession(String sessionId) async {
    final ok = await SessionsService.instance.revokeSession(sessionId);
    if (ok) {
      sessions.removeWhere((s) => s['session_id'] == sessionId);
    }
    return ok;
  }

  Future<bool> revokeAllSessions() async {
    isRevokingAll = true;
    try {
      return await SessionsService.instance.revokeAllSessions();
    } finally {
      isRevokingAll = false;
    }
  }

  @override
  void dispose() {}
}
