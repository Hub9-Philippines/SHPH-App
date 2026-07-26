import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '/services/logging_service.dart';

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance =
      PushNotificationService._();

  bool _initialized = false;
  String? _fcmToken;
  final _supabase = Supabase.instance.client;

  bool get isInitialized => _initialized;
  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
  }

  Future<void> registerToken(String? uid) async {
    if (_fcmToken == null || uid == null) return;
    try {
      await _supabase.from('user_push_tokens').upsert({
        'user_id': uid,
        'fcm_token': _fcmToken,
        'platform': defaultTargetPlatform == TargetPlatform.iOS
            ? 'ios'
            : 'android',
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      LoggingService.error('Failed to register push token: $e',
          tag: 'PushNotification');
    }
  }

  Future<void> unregisterToken(String? uid) async {
    if (_fcmToken == null || uid == null) return;
    try {
      await _supabase
          .from('user_push_tokens')
          .delete()
          .eq('user_id', uid)
          .eq('fcm_token', _fcmToken!);
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
      final response = await _supabase.functions.invoke(
        'send-notification',
        body: {
          'user_id': userId,
          'title': title,
          'body': body,
        },
      );
      return response.data != null;
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
