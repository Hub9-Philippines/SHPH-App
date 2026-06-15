import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/database/tables/notifications.dart';
import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
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

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, MyNotificationsModel.new);
    _loadNotifications();
  }

  void _loadNotifications() {
    // TODO: Replace with actual database query when notifications table is available
    // For testing, return sample data
    _notificationsFuture = Future.value(_getSampleNotifications());
  }

  List<NotificationsRow> _getSampleNotifications() {
    // Sample notification data for testing
    return [
      NotificationsRow({
        'id': '00000000-0000-0000-0000-000000000001',
        'user_id': currentUserUid,
        'title': 'Booking Confirmed',
        'body': 'Your home cleaning service has been confirmed for tomorrow at 10:00 AM.',
        'type': 'booking',
        'is_read': false,
        'created_at': DateTime.now().subtract(const Duration(hours: 2)),
      }),
      NotificationsRow({
        'id': '00000000-0000-0000-0000-000000000002',
        'user_id': currentUserUid,
        'title': 'New Message',
        'body': 'You have a new message from your service provider.',
        'type': 'message',
        'is_read': false,
        'created_at': DateTime.now().subtract(const Duration(hours: 5)),
      }),
      NotificationsRow({
        'id': '00000000-0000-0000-0000-000000000003',
        'user_id': currentUserUid,
        'title': 'Payment Successful',
        'body': 'Your payment of ₱500.00 for cleaning service was successful.',
        'type': 'payment',
        'is_read': true,
        'created_at': DateTime.now().subtract(const Duration(days: 1)),
      }),
      NotificationsRow({
        'id': '00000000-0000-0000-0000-000000000004',
        'user_id': currentUserUid,
        'title': 'Review Request',
        'body': 'Please rate your recent experience with the plumbing service.',
        'type': 'review',
        'is_read': true,
        'created_at': DateTime.now().subtract(const Duration(days: 2)),
      }),
      NotificationsRow({
        'id': '00000000-0000-0000-0000-000000000005',
        'user_id': currentUserUid,
        'title': 'System Update',
        'body': 'We have improved our app performance. Check out the new features!',
        'type': 'system',
        'is_read': true,
        'created_at': DateTime.now().subtract(const Duration(days: 3)),
      }),
    ];
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await NotificationsTable().update(
        data: {'is_read': true},
        matchingRows: (rows) => rows.eq('id', notificationId),
      );
      _loadNotifications();
      safeSetState(() {});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
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
          backgroundColor: AppTheme.of(context).primaryBackground,
          appBar: AppBar(
            backgroundColor: AppTheme.of(context).primaryBackground,
            automaticallyImplyLeading: false,
            leading: wrapWithModel(
              model: _model.backButtonModel,
              updateCallback: () => safeSetState(() {}),
              child: const BackButtonWidget(),
            ),
            title: Text(
              'Notifications',
              style: AppTheme.of(context).titleLarge.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
            ),
            centerTitle: true,
            elevation: 0,
          ),
          body: FutureBuilder<List<NotificationsRow>>(
            future: _notificationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading notifications',
                    style: AppTheme.of(context).bodyMedium,
                  ),
                );
              }

              final notifications = snapshot.data ?? [];

              if (notifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: AppTheme.of(context).secondaryText,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications',
                        style: AppTheme.of(context).titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You\'re all caught up!',
                        style: AppTheme.of(context).bodySmall,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _buildNotificationCard(notification);
                },
              );
            },
          ),
        ),
      );

  Widget _buildNotificationCard(NotificationsRow notification) => GestureDetector(
        onTap: () {
          if (!notification.isRead) {
            _markAsRead(notification.id);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead
                ? AppTheme.of(context).secondaryBackground
                : AppTheme.of(context).primaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: notification.isRead
                ? null
                : Border.all(
                    color: AppTheme.of(context).primary,
                    width: 1,
                  ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0x1A368EFF),
                  borderRadius: BorderRadius.circular(12),
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
                    Text(
                      notification.title,
                      style: AppTheme.of(context).titleSmall.override(
                            font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body ?? '',
                      style: AppTheme.of(context).bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(notification.createdAt),
                      style: AppTheme.of(context).bodySmall.override(
                            color: AppTheme.of(context).secondaryText,
                          ),
                    ),
                  ],
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
        ),
      );

  IconData _getIconForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'booking':
        return Icons.calendar_today;
      case 'message':
        return Icons.message;
      case 'payment':
        return Icons.payment;
      case 'review':
        return Icons.star;
      case 'system':
        return Icons.settings;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'Just now';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
