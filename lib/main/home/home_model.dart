import 'package:flutter/material.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/api/resources/notifications_api.dart';
import '/components/categoriesgrid/categoriesgrid_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'home_widget.dart' show HomeWidget;

class HomeModel extends FlutterFlowModel<HomeWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for categoriesgrid component.
  late CategoriesgridModel categoriesgridModel;

  bool isLoadingNotifications = false;

  // Favorites tracking (local state - needs database integration)
  final Set<int> favorites = <int>{};

  @override
  void initState(BuildContext context) {
    categoriesgridModel = createModel(context, CategoriesgridModel.new);
    loadNotificationCount();
  }

  /// Load notification count from backend
  Future<void> loadNotificationCount() async {
    isLoadingNotifications = true;

    try {
      if (currentUserUid.isEmpty) {
        FFAppState().notificationCount = 0;
        return;
      }

      final response = await ShphNotificationsApi.instance.listNotifications();
      final rows = (response['results'] as List?) ?? const [];
      FFAppState().notificationCount = rows
          .whereType<Map<String, dynamic>>()
          .where((notification) => notification['is_read'] != true)
          .length;
    } catch (e) {
      // On error, default to 0
      FFAppState().notificationCount = 0;
    } finally {
      isLoadingNotifications = false;
    }
  }

  @override
  void dispose() {
    categoriesgridModel.dispose();
  }
}
