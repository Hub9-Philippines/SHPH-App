import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/api/resources/notifications_api.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/services/logging_service.dart';

/// Manages FCM push notification lifecycle:
/// - Initializes Firebase Messaging
/// - Requests permission (iOS / Android 13+)
/// - Registers / unregisters device token with backend
/// - Handles foreground messages via local notifications
/// - Routes notification taps to the correct screen
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  static const _kTokenKey = 'fcm_token';
  static const _kEnabledKey = 'push_enabled';

  final _firebaseMessaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  String? _cachedToken;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _onMessageSub;

  // For routing from background isolate
  static GlobalKey<NavigatorState>? navigatorKey;

  /// Initialize FCM. Call once at app startup.
  Future<void> initialize({GlobalKey<NavigatorState>? navKey}) async {
    if (_initialized) return;
    navigatorKey = navKey;

    try {
      await Firebase.initializeApp();
    } catch (e) {
      LoggingService.warning(
        'Firebase init failed — push disabled: $e',
        tag: 'Push',
      );
      return;
    }

    // Request permission
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      LoggingService.info('Push permission denied', tag: 'Push');
      return;
    }

    // Initialize local notifications for foreground display
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // Create Android notification channels
    if (Platform.isAndroid) {
      await _createAndroidChannels();
    }

    // Get FCM token
    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      _cachedToken = token;
      await _saveToken(token);
      await _registerWithBackend(token);
    }

    // Listen for token refresh
    _tokenRefreshSub = _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _cachedToken = newToken;
      _saveToken(newToken);
      _registerWithBackend(newToken);
    });

    // Foreground message handler
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

    // Notification tap when app was terminated
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageTap(initialMessage);
    }

    // Set background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    _initialized = true;
    LoggingService.info('Push notifications initialized', tag: 'Push');
  }

  /// Manually register for push (e.g. from settings)
  Future<String?> register() async {
    await initialize();
    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      _cachedToken = token;
      await _saveToken(token);
      await _registerWithBackend(token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kEnabledKey, true);
    }
    return token;
  }

  /// Unregister from push
  Future<void> unregister() async {
    final token = _cachedToken ?? await _getToken();
    if (token != null) {
      try {
        await ShphNotificationsApi.instance.unregisterDevice(token: token);
      } catch (e) {
        LoggingService.error('Unregister failed: $e', tag: 'Push');
      }
    }
    await _firebaseMessaging.deleteToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenKey);
    await prefs.setBool(_kEnabledKey, false);
    _cachedToken = null;
    LoggingService.info('Push unregistered', tag: 'Push');
  }

  /// Re-register an existing token (e.g. after login)
  Future<void> reRegisterToken() async {
    final token = await _getToken();
    if (token != null) {
      await _registerWithBackend(token);
    }
  }

  /// Check if push is enabled
  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kEnabledKey) ?? false;
  }

  /// Get stored token
  Future<String?> getToken() async => _getToken();

  void dispose() {
    _tokenRefreshSub?.cancel();
    _onMessageSub?.cancel();
  }

  // ── Private helpers ──────────────────────────────────────────────

  Future<void> _registerWithBackend(String token) async {
    if (!loggedIn) {
      LoggingService.debug(
        'Skipping token registration — not authenticated',
        tag: 'Push',
      );
      return;
    }
    try {
      final platform = Platform.isIOS ? 'ios' : 'android';
      await ShphNotificationsApi.instance.registerDevice(
        token: token,
        platform: platform,
      );
      LoggingService.info('Token registered with backend', tag: 'Push');
    } catch (e) {
      LoggingService.error('Token registration failed: $e', tag: 'Push');
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTokenKey, token);
  }

  Future<String?> _getToken() async {
    if (_cachedToken != null) return _cachedToken;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kTokenKey);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final title = message.notification?.title ?? message.data['title'] ?? '';
    final body =
        message.notification?.body ?? message.data['body'] ?? '';

    LoggingService.debug(
      'Foreground message: $title',
      tag: 'Push',
    );

    // Show local notification
    _localNotifications.show(
      message.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'default',
          'Default',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: _encodePayload(message.data),
    );
  }

  void _handleMessageTap(RemoteMessage message) {
    final data = _normalizeData(message.data);
    LoggingService.debug(
      'Notification tap: type=${data['type']}',
      tag: 'Push',
    );
    _routeNotification(data);
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;
    final data = _decodePayload(response.payload!);
    _routeNotification(data);
  }

  void _routeNotification(Map<String, String> data) {
    final context = navigatorKey?.currentContext;
    if (context == null) {
      LoggingService.warning(
        'No navigator context for routing',
        tag: 'Push',
      );
      return;
    }

    final type = data['type'] ?? '';
    switch (type) {
      case 'booking':
        final bookingId = data['bookingId'];
        if (bookingId != null) {
          GoRouter.of(context).push('/bookings/$bookingId');
        }
        break;
      case 'message':
        final chatId = data['chatId'] ?? data['bookingId'];
        if (chatId != null) {
          GoRouter.of(context).push('/messages/$chatId');
        }
        break;
      case 'service':
        final serviceId = data['serviceId'];
        if (serviceId != null) {
          GoRouter.of(context).push('/services/$serviceId');
        }
        break;
      case 'review':
        final bookingId = data['bookingId'];
        if (bookingId != null) {
          GoRouter.of(context).push('/bookings/$bookingId');
        } else {
          GoRouter.of(context).push('/my-notifications');
        }
        break;
      case 'earnings':
        GoRouter.of(context).push('/pro-dashboard');
        break;
      case 'dispute':
        final bookingId = data['bookingId'];
        if (bookingId != null) {
          GoRouter.of(context).push('/bookings/$bookingId');
        }
        break;
      case 'on_demand':
        GoRouter.of(context).push('/on-demand/provider-bids');
        break;
      case 'kyc':
        GoRouter.of(context).push('/pro-verification');
        break;
      default:
        GoRouter.of(context).push('/my-notifications');
    }
  }

  Map<String, String> _normalizeData(Map<String, dynamic> raw) {
    final normalized = <String, String>{};
    for (final entry in raw.entries) {
      normalized[entry.key] = entry.value?.toString() ?? '';
    }

    // snake_case → camelCase
    const keyMap = {
      'booking_id': 'bookingId',
      'listing_id': 'listingId',
      'thread_id': 'chatId',
      'sender_id': 'senderId',
      'service_id': 'serviceId',
      'dispute_id': 'disputeId',
      'job_id': 'jobId',
      'client_lat': 'clientLat',
      'client_lng': 'clientLng',
      'distance_km': 'distanceKm',
      'estimated_fee_min': 'estimatedFeeMin',
      'estimated_fee_max': 'estimatedFeeMax',
      'expires_at': 'expiresAt',
      'kyc_status': 'kycStatus',
    };
    for (final entry in keyMap.entries) {
      if (normalized.containsKey(entry.key) &&
          !normalized.containsKey(entry.value)) {
        normalized[entry.value] = normalized[entry.key]!;
      }
    }

    // Derive type from key presence
    if (!normalized.containsKey('type') || normalized['type']!.isEmpty) {
      if (normalized.containsKey('chatId')) {
        normalized['type'] = 'message';
      } else if (normalized.containsKey('kycStatus')) {
        normalized['type'] = 'kyc';
      } else if (normalized.containsKey('bookingId')) {
        normalized['type'] = 'booking';
      } else if (normalized.containsKey('serviceId')) {
        normalized['type'] = 'service';
      } else if (normalized.containsKey('jobId')) {
        normalized['type'] = 'on_demand';
      } else {
        normalized['type'] = 'notification';
      }
    }

    return normalized;
  }

  String _encodePayload(Map<String, dynamic> data) {
    final normalized = _normalizeData(data);
    return normalized.entries.map((e) => '${e.key}=${e.value}').join('&');
  }

  Map<String, String> _decodePayload(String payload) {
    final result = <String, String>{};
    for (final part in payload.split('&')) {
      final idx = part.indexOf('=');
      if (idx > 0) {
        result[part.substring(0, idx)] = part.substring(idx + 1);
      }
    }
    return result;
  }

  Future<void> _createAndroidChannels() async {
    const channels = [
      (
        id: 'default',
        name: 'Default',
        description: 'Default notification channel',
        importance: Importance.high,
      ),
      (
        id: 'bookings',
        name: 'Booking Updates',
        description: 'Booking status changes and reminders',
        importance: Importance.high,
      ),
      (
        id: 'messages',
        name: 'Messages',
        description: 'New message notifications',
        importance: Importance.high,
      ),
      (
        id: 'calls',
        name: 'Incoming Calls',
        description: 'Incoming video call notifications',
        importance: Importance.max,
      ),
      (
        id: 'promotions',
        name: 'Promotions',
        description: 'Promotional offers',
        importance: Importance.defaultImportance,
      ),
    ];

    for (final ch in channels) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
        AndroidNotificationChannel(
          ch.id,
          ch.name,
          description: ch.description,
          importance: ch.importance,
        ),
      );
    }
  }
}

/// Top-level background handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  LoggingService.debug(
    'Background message: ${message.messageId}',
    tag: 'PushBG',
  );
}
