import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/services/logging_service.dart';
import '/services/notification_store.dart';
import '/theme/app_theme.dart';
import 'my_notifications_model.dart';

export 'my_notifications_model.dart';

class MyNotificationsWidget extends StatefulWidget {
  const MyNotificationsWidget({super.key});

  static String routeName = 'MyNotifications';
  static String routePath = '/my-notifications';

  @override
  State<MyNotificationsWidget> createState() => _MyNotificationsWidgetState();
}

enum NotificationFilter { all, bookings, offers, system }

enum _TypeBucket { bookings, offers, system }

class _MyNotificationsWidgetState extends State<MyNotificationsWidget> {
  late MyNotificationsModel _model;
  late Future<List<AppNotification>> _notificationsFuture;
  Timer? _pollTimer;
  bool _isMarkingAllRead = false;
  NotificationFilter _filter = NotificationFilter.all;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, MyNotificationsModel.new);
    _loadNotifications();
    _subscribeRealtime();
  }

  void _subscribeRealtime() {
    // Realtime not available via SHPH REST; poll for updates.
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) {
        _reloadFromRealtime();
      }
    });
  }

  void _reloadFromRealtime() {
    _loadNotifications();
    safeSetState(() {});
  }

  void _loadNotifications() {
    _notificationsFuture = _fetchNotifications();
  }

  Future<void> _refreshNotifications() async {
    _loadNotifications();
    await _notificationsFuture;
    if (mounted) {
      safeSetState(() {});
    }
  }

  Future<List<AppNotification>> _fetchNotifications() async {
    if (currentUserUid.isEmpty) {
      return [];
    }

    try {
      await NotificationStore.instance.fetchNotifications();
      return NotificationStore.instance.notifications;
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to load notifications',
        tag: 'Notifications',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> _markAsRead(
    int notificationId, {
    bool refresh = true,
  }) async {
    try {
      await NotificationStore.instance.markAsRead(notificationId);
      if (refresh) {
        _loadNotifications();
        safeSetState(() {});
      }
    } catch (e) {
      LoggingService.error(
        'Error marking notification as read',
        tag: 'Notifications',
        error: e,
      );
    }
  }

  Future<void> _markAllAsRead() async {
    if (_isMarkingAllRead || currentUserUid.isEmpty) {
      return;
    }

    safeSetState(() => _isMarkingAllRead = true);
    try {
      await NotificationStore.instance.markAllAsRead();
      await _refreshNotifications();
    } catch (e, stackTrace) {
      LoggingService.error(
        'Error marking all notifications as read',
        tag: 'Notifications',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not mark notifications as read.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        safeSetState(() => _isMarkingAllRead = false);
      }
    }
  }

  Future<void> _handleNotificationTap(AppNotification notification) async {
    if (!notification.isRead) {
      await _markAsRead(notification.id, refresh: false);
    }
    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final handled = _openNotificationDestination(notification);
    if (!handled) {
      _loadNotifications();
      safeSetState(() {});
      messenger.showSnackBar(
        const SnackBar(
          content: Text('This notification has no linked destination yet.'),
        ),
      );
      return;
    }

    _loadNotifications();
    safeSetState(() {});
  }

  bool _openNotificationDestination(AppNotification notification) {
    final actionUrl = notification.route?.trim() ?? '';
    final metadata = notification.metadata;

    final bookingId = _stringFromMap(
      metadata,
      const ['booking_id', 'bookingId', 'job_booking_id'],
    );
    final roomId = _stringFromMap(
      metadata,
      const ['room_id', 'roomId', 'chat_room_id'],
    );
    final providerName = _stringFromMap(
      metadata,
      const ['provider_name', 'providerName', 'sender_name'],
    );
    final providerPhoto = _stringFromMap(
      metadata,
      const ['provider_photo', 'providerPhoto', 'sender_photo'],
    );

    if (actionUrl.isNotEmpty) {
      if (_isExternalAction(actionUrl)) {
        launchURL(actionUrl);
        return true;
      }

      if (actionUrl.contains('/booking-details') && bookingId != null) {
        context.pushNamed(
          BookingDetailsWidget.routeName,
          extra: <String, dynamic>{'bookingId': bookingId},
        );
        return true;
      }

      if (actionUrl.contains('/bookings')) {
        context.pushNamed(BookingsWidget.routeName);
        return true;
      }

      if (actionUrl.contains('/messages')) {
        context.pushNamed(MessagesWidget.routeName);
        return true;
      }

      if (actionUrl.contains('/payment-methods')) {
        context.pushNamed(PaymentMethodsWidget.routeName);
        return true;
      }
    }

    if (bookingId != null) {
      context.pushNamed(
        BookingDetailsWidget.routeName,
        extra: <String, dynamic>{'bookingId': bookingId},
      );
      return true;
    }

    if (roomId != null) {
      context.pushNamed(
        ChatPageWidget.routeName,
        pathParameters: <String, String>{'roomId': roomId},
        extra: <String, dynamic>{
          'providerName': providerName,
          'providerPhoto': providerPhoto,
        },
      );
      return true;
    }

    switch ((notification.type ?? '').toLowerCase()) {
      case 'booking':
        context.pushNamed(BookingsWidget.routeName);
        return true;
      case 'message':
        context.pushNamed(MessagesWidget.routeName);
        return true;
      case 'payment':
        context.pushNamed(PaymentMethodsWidget.routeName);
        return true;
      case 'review':
        context.pushNamed(MyReviewsWidget.routeName);
        return true;
      default:
        return false;
    }
  }

  bool _isExternalAction(String value) =>
      value.startsWith('http://') ||
      value.startsWith('https://') ||
      value.startsWith('mailto:') ||
      value.startsWith('tel:');

  String? _stringFromMap(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Strict light theme for this screen.
    return Theme(
      data: AppTheme.lightTheme(),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeaderBar(context),
                _buildFilterChips(context),
                const SizedBox(height: 4),
                Divider(height: 1, thickness: 0.5, color: theme_divider),
                Expanded(
                  child: FutureBuilder<List<AppNotification>>(
                    future: _notificationsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return _buildMessageState(
                          context,
                          icon: Icons.error_outline_rounded,
                          title: 'Error loading notifications',
                          subtitle:
                              'Something went wrong while fetching your updates.',
                        );
                      }

                      final notifications =
                          _applyFilter(snapshot.data ?? []);
                      if (notifications.isEmpty) {
                        return RefreshIndicator(
                          color: AppTheme.of(context).primary,
                          onRefresh: _refreshNotifications,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: MediaQuery.sizeOf(context).height * 0.5,
                                child: _buildMessageState(
                                  context,
                                  icon: Icons.notifications_none_rounded,
                                  title: 'No notifications',
                                  subtitle: _emptySubtitleFor(_filter),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        color: AppTheme.of(context).primary,
                        onRefresh: _refreshNotifications,
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: notifications.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            thickness: 0.5,
                            color: theme_divider.withValues(alpha: 0.6),
                          ),
                          itemBuilder: (context, index) =>
                              _buildNotificationRow(notifications[index]),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color get theme_divider => Theme.of(context).dividerColor;

  Widget _buildHeaderBar(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
            icon: const Icon(Icons.chevron_left_rounded, size: 28),
            color: theme.primaryText,
          ),
          Expanded(
            child: Center(
              child: Text(
                'Notification',
                style: theme.titleMedium.override(
                  font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
                  color: theme.primaryText,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _openSettingsSheet,
            icon: const Icon(Icons.settings_outlined),
            color: theme.primaryText,
          ),
        ],
      ),
    );
  }

  void _openSettingsSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notification settings',
                style: AppTheme.of(sheetContext).titleMedium.override(
                      font: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700),
                    ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Icon(Icons.done_all_rounded,
                    color: AppTheme.of(sheetContext).primary),
                title: Text(
                  _isMarkingAllRead ? 'Marking...' : 'Mark all as read',
                  style: AppTheme.of(sheetContext).bodyLarge,
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _markAllAsRead();
                },
              ),
              ListTile(
                leading: Icon(Icons.tune_rounded,
                    color: AppTheme.of(sheetContext).primary),
                title: Text(
                  'Granular controls live inside each service update.',
                  style: AppTheme.of(sheetContext).bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final theme = AppTheme.of(context);
    final chips = <(NotificationFilter, String)>[
      (NotificationFilter.all, 'All'),
      (NotificationFilter.bookings, 'Bookings'),
      (NotificationFilter.offers, 'Offers'),
      (NotificationFilter.system, 'System'),
    ];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (filter, label) = chips[index];
          final active = _filter == filter;
          return GestureDetector(
            onTap: () => safeSetState(() => _filter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active
                    ? theme.primary
                    : theme.surfaceAlt,
                borderRadius:
                    BorderRadius.circular(AppThemeData.radiusPill),
              ),
              child: Text(
                label,
                style: theme.labelMedium.override(
                  font: GoogleFonts.plusJakartaSans(
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  ),
                  color: active ? Colors.white : theme.secondaryText,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<AppNotification> _applyFilter(List<AppNotification> source) =>
      source.where((n) => _matchesFilter(n, _filter)).toList();

  bool _matchesFilter(AppNotification n, NotificationFilter filter) {
    switch (filter) {
      case NotificationFilter.all:
        return true;
      case NotificationFilter.bookings:
        return _typeBucket(n) == _TypeBucket.bookings;
      case NotificationFilter.offers:
        return _typeBucket(n) == _TypeBucket.offers;
      case NotificationFilter.system:
        return _typeBucket(n) == _TypeBucket.system;
    }
  }

  /// Heuristic bucketing of server notification types into the three chips.
  _TypeBucket _typeBucket(AppNotification n) {
    final haystack =
        '${n.type ?? ''} ${n.title} ${n.route ?? ''}'.toLowerCase();
    if (haystack.contains('offer') ||
        haystack.contains('promo') ||
        haystack.contains('discount') ||
        haystack.contains('reward')) {
      return _TypeBucket.offers;
    }
    if (haystack.contains('book') ||
        haystack.contains('confirm') ||
        haystack.contains('remind') ||
        haystack.contains('schedule') ||
        haystack.contains('arriv') ||
        haystack.contains('en_route') ||
        haystack.contains('complete')) {
      return _TypeBucket.bookings;
    }
    return _TypeBucket.system;
  }

  String _emptySubtitleFor(NotificationFilter filter) => switch (filter) {
        NotificationFilter.bookings =>
          'Booking updates will land here as providers respond.',
        NotificationFilter.offers =>
          'Promos and special offers will show up here.',
        NotificationFilter.system =>
          'System updates will appear here when available.',
        NotificationFilter.all => 'You are all caught up right now.',
      };

  Widget _buildMessageState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) =>
      Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
              border: Border.all(color: theme_divider),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icon,
                      size: 30, color: AppTheme.of(context).primary),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTheme.of(context).titleMedium.override(
                        font: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700),
                        color: AppTheme.of(context).primaryText,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.plusJakartaSans(),
                        color: AppTheme.of(context).secondaryText,
                      ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildNotificationRow(AppNotification notification) {
    final theme = AppTheme.of(context);
    final code = _badgeCode(notification);
    return InkWell(
      onTap: () => _handleNotificationTap(notification),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: code == null
                  ? Icon(_getIconForType(notification.type),
                      size: 20, color: theme.primary)
                  : Text(
                      code,
                      style: theme.labelSmall.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                        ),
                        color: theme.primary,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.bodyLarge.override(
                            font: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                            ),
                            color: theme.primaryText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!notification.isRead)
                        Container(
                          width: 7,
                          height: 7,
                          margin: const EdgeInsets.only(top: 5, right: 6),
                          decoration: BoxDecoration(
                            color: theme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      Text(
                        _formatTime(notification.createdAtDateTime),
                        style: theme.labelSmall.override(
                          font: GoogleFonts.plusJakartaSans(),
                          color: theme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body.trim().isNotEmpty
                        ? notification.body
                        : 'Open this update to see more details.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.bodySmall.override(
                      font: GoogleFonts.plusJakartaSans(),
                      color: theme.secondaryText,
                      lineHeight: 1.35,
                    ),
                  ),                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Two-letter service code from the title's initials; null falls back to
  /// the type icon glyph.
  String? _badgeCode(AppNotification notification) {
    final words = notification.title
        .toUpperCase()
        .replaceAll(RegExp('[^A-Z ]'), '')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return null;
    if (words.length == 1) {
      return words.first.substring(0, words.first.length.clamp(1, 2));
    }
    return '${words.first[0]}${words[1][0]}';
  }

  IconData _getIconForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'booking':
        return Icons.calendar_today_rounded;
      case 'message':
        return Icons.message_outlined;
      case 'payment':
        return Icons.payments_outlined;
      case 'review':
        return Icons.star_outline_rounded;
      case 'system':
        return Icons.settings_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Just now';
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
