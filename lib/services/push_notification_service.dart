import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '/api/resources/users_api.dart';
import '/services/logging_service.dart';

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance =
      PushNotificationService._();

  bool _initialized = false;
  String? _fcmToken;
  final _usersApi = ShphUsersApi.instance;

  bool get isInitialized => _initialized;
  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
  }

  Future<void> registerToken(String? uid) async {
    if (_fcmToken == null || uid == null) return;
    try {
      await _usersApi.updateMe({
        'fcm_token': _fcmToken,
        'push_platform': defaultTargetPlatform == TargetPlatform.iOS
            ? 'ios'
            : 'android',
      });
    } catch (e) {
      LoggingService.error('Failed to register push token: $e',
          tag: 'PushNotification');
    }
  }

  Future<void> unregisterToken(String? uid) async {
    if (_fcmToken == null || uid == null) return;
    try {
      await _usersApi.updateMe({'fcm_token': null});
    } catch (e) {
      LoggingService.error('Failed to unregister push token: $e',
          tag: 'PushNotification');
    }
  }

  Future<bool> sendTestNotification({
    required String userId,
    required String title,
    required String body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.serbisyohub.ph/api/notifications/send/'),
        body: jsonEncode({
          'user_id': userId,
          'title': title,
          'body': body,
        }),
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      LoggingService.error('Failed to send test notification: $e',
          tag: 'PushNotification');
      return false;
    }
  }

  void handleNotificationTap(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final targetId = data['target_id'] as String?;
    if (type == null || targetId == null) return;

    LoggingService.info(
      'Notification tap: type=$type, targetId=$targetId',
      tag: 'PushNotification',
    );
  }
}
