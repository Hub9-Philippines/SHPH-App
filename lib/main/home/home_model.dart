import 'package:flutter/material.dart';

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
      // TODO: Replace with actual database query when notifications table is available
      // For testing, return sample count
      FFAppState().notificationCount = 2; // Sample: 2 unread notifications
      
      // Uncomment when notifications table is available:
      // final notifications = await NotificationsTable().queryRows(
      //   queryFn: (q) => q
      //       .eq('user_id', currentUserUid)
      //       .eq('is_read', false),
      // );
      // FFAppState().notificationCount = notifications.length;
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
