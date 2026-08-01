import 'dart:async';

import 'package:flutter/foundation.dart';

import '/api/shph_api_client.dart';
import '/services/logging_service.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.type,
    this.route,
    this.metadata = const <String, dynamic>{},
  });

  final int id;
  final String title;
  final String body;
  final bool isRead;
  final String createdAt;
  final String? type;
  final String? route;
  final Map<String, dynamic> metadata;

  DateTime? get createdAtDateTime => DateTime.tryParse(createdAt);

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final info = json['info'];
    return AppNotification(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? json['message'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? json['read'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? json['createdAt'] as String? ?? '',
      type: json['type'] as String?,
      route: json['redirect_url'] as String? ?? json['route'] as String?,
      metadata: {
        if (data is Map<String, dynamic>) ...data,
        if (info is Map<String, dynamic>) ...info,
      },
    );
  }
}

class NotificationStore extends ChangeNotifier {
  NotificationStore._();
  static final NotificationStore instance = NotificationStore._();

  final _client = ShphApiClient.instance;

  List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _client.get<List<dynamic>>('/api/notifications/');
      final data = response.data ?? [];
      _notifications = data
          .map((json) => AppNotification.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString();
      LoggingService.error('Failed to fetch notifications: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await _client.post('/api/notifications/$notificationId/read/');
      final idx = _notifications.indexWhere((n) => n.id == notificationId);
      if (idx != -1) {
        _notifications[idx] = AppNotification(
          id: _notifications[idx].id,
          title: _notifications[idx].title,
          body: _notifications[idx].body,
          isRead: true,
          createdAt: _notifications[idx].createdAt,
          type: _notifications[idx].type,
          route: _notifications[idx].route,
          metadata: _notifications[idx].metadata,
        );
        notifyListeners();
      }
    } catch (e) {
      LoggingService.error('Failed to mark notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _client.post('/api/notifications/mark-all-read/');
      _notifications = _notifications
          .map((n) => AppNotification(
                id: n.id,
                title: n.title,
                body: n.body,
                isRead: true,
                createdAt: n.createdAt,
                type: n.type,
                route: n.route,
                metadata: n.metadata,
              ))
          .toList();
      notifyListeners();
    } catch (e) {
      LoggingService.error('Failed to mark all notifications as read: $e');
    }
  }
}
