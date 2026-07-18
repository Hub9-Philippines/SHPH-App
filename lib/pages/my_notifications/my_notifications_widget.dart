import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/shph_auth/auth_util.dart';
import '/backend/shph_db/shph_db.dart';
import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/services/logging_service.dart';
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

class _MyNotificationsWidgetState extends State<MyNotificationsWidget> {
  late MyNotificationsModel _model;
  late Future<List<NotificationsRow>> _notificationsFuture;
  bool _isMarkingAllRead = false;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, MyNotificationsModel.new);
    _loadNotifications();
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

  Future<List<NotificationsRow>> _fetchNotifications() async {
    if (currentUserUid.isEmpty) {
      return [];
    }

    try {
      return await NotificationsTable().queryRows(
        queryFn: (q) => q
            .eq('user_id', currentUserUid)
            .order('created_at', ascending: false),
      );
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
    String notificationId, {
    bool refresh = true,
  }) async {
    try {
      await NotificationsTable().update(
        data: {
          'is_read': true,
          'read_at': DateTime.now().toIso8601String(),
        },
        matchingRows: (rows) => rows.eq('id', notificationId),
      );
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
      await NotificationsTable().update(
        data: {
          'is_read': true,
          'read_at': DateTime.now().toIso8601String(),
        },
        matchingRows: (rows) =>
            rows.eq('user_id', currentUserUid).eq('is_read', false),
      );
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

  Future<void> _handleNotificationTap(NotificationsRow notification) async {
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

  bool _openNotificationDestination(NotificationsRow notification) {
    final actionUrl = notification.actionUrl?.trim() ?? '';
    final metadata = notification.metadata ?? const <String, dynamic>{};

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

    switch (notification.type.toLowerCase()) {
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
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: const Color(0xFFF4F7FB),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        child: wrapWithModel(
                          model: _model.backButtonModel,
                          updateCallback: () => safeSetState(() {}),
                          child: const BackButtonWidget(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notifications',
                              style: AppTheme.of(context).titleLarge.override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    color: const Color(0xFF14213D),
                                  ),
                            ),
                            Text(
                              'Updates about bookings, messages, and payments.',
                              style: AppTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.poppins(),
                                    color: const Color(0xFF64748B),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<NotificationsRow>>(
                    future: _notificationsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
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

                      final notifications = snapshot.data ?? [];
                      final unreadCount =
                          notifications.where((item) => !item.isRead).length;
                      if (notifications.isEmpty) {
                        return _buildMessageState(
                          context,
                          icon: Icons.notifications_none_rounded,
                          title: 'No notifications',
                          subtitle: 'You are all caught up right now.',
                        );
                      }

                      return RefreshIndicator(
                        color: AppTheme.of(context).primary,
                        onRefresh: _refreshNotifications,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                          itemCount: notifications.length + 1,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return _buildSummaryCard(
                                context,
                                totalCount: notifications.length,
                                unreadCount: unreadCount,
                              );
                            }
                            return _buildNotificationCard(
                              notifications[index - 1],
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildSummaryCard(
    BuildContext context, {
    required int totalCount,
    required int unreadCount,
  }) =>
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF17212B),
              Color(0xFF27455F),
              Color(0xFF4A7C96),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A17212B),
              blurRadius: 20,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stay on top of every update',
              style: AppTheme.of(context).titleMedium.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              unreadCount == 0
                  ? 'You are caught up right now.'
                  : '$unreadCount unread notifications still need your attention.',
              style: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.poppins(),
                    color: Colors.white.withValues(alpha: 0.84),
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SummaryMetric(
                    label: 'Unread',
                    value: '$unreadCount',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryMetric(
                    label: 'Total',
                    value: '$totalCount',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: unreadCount == 0 || _isMarkingAllRead
                    ? null
                    : _markAllAsRead,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.34),
                  ),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  _isMarkingAllRead ? 'Marking...' : 'Mark all as read',
                  style: AppTheme.of(context).labelLarge.override(
                        font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                        color: Colors.white,
                      ),
                ),
              ),
            ),
          ],
        ),
      );

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
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
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
                  child:
                      Icon(icon, size: 30, color: AppTheme.of(context).primary),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTheme.of(context).titleMedium.override(
                        font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                        color: const Color(0xFF14213D),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.poppins(),
                        color: const Color(0xFF64748B),
                      ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildNotificationCard(NotificationsRow notification) =>
      GestureDetector(
        onTap: () => _handleNotificationTap(notification),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: notification.isRead
                ? null
                : Border.all(
                    color: AppTheme.of(context).primary.withValues(alpha: 0.28),
                    width: 1.4,
                  ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.of(context).primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getIconForType(notification.type),
                  color: AppTheme.of(context).primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  color: const Color(0xFF14213D),
                                ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.of(context).primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.body?.trim().isNotEmpty == true
                          ? notification.body!
                          : 'Open this update to see more details.',
                      style: AppTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.poppins(),
                            color: const Color(0xFF64748B),
                          ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _formatTime(notification.createdAt),
                      style: AppTheme.of(context).labelSmall.override(
                            font: GoogleFonts.poppins(),
                            color: const Color(0xFF94A3B8),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

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

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTheme.of(context).titleMedium.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTheme.of(context).bodySmall.override(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
            ),
          ],
        ),
      );
}
