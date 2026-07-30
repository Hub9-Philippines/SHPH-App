import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/services/notifications_prefs_service.dart';
import 'notification_preferences_widget.dart'
    show NotificationPreferencesWidget;

class NotificationPreferencesModel
    extends FlutterFlowModel<NotificationPreferencesWidget> {
  Map<String, dynamic> preferences = {};
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState(BuildContext context) {}

  Future<void> loadPreferences() async {
    isLoading = true;
    try {
      preferences = await NotificationsPrefsService.instance.getPreferences();
    } finally {
      isLoading = false;
    }
  }

  Future<bool> updatePreferences(Map<String, dynamic> updates) async {
    isSaving = true;
    try {
      final ok =
          await NotificationsPrefsService.instance.updatePreferences(updates);
      if (ok) {
        preferences.addAll(updates);
      }
      return ok;
    } finally {
      isSaving = false;
    }
  }

  @override
  void dispose() {}
}
