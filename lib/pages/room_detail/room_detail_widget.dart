import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import 'room_detail_model.dart';

export 'room_detail_model.dart';

class RoomDetailWidget extends StatefulWidget {
  const RoomDetailWidget({super.key, required this.roomId});

  final String roomId;

  static String routeName = 'RoomDetail';
  static String routePath = '/rooms/:roomId';

  @override
  State<RoomDetailWidget> createState() => _RoomDetailWidgetState();
}

class _RoomDetailWidgetState extends State<RoomDetailWidget> {
  late RoomDetailModel _model;
  int? currentUserId;

  Color _statusColor(String status, AppThemeData theme) => switch (status) {
        'open' => theme.success,
        'locked' => theme.warning,
        'settled' => theme.primary,
        'cancelled' => theme.error,
        'expired' => theme.textTertiary,
        _ => theme.secondaryText,
      };

  String _statusLabel(String status) => switch (status) {
        'open' => 'Open',
        'locked' => 'Locked',
        'settled' => 'Settled',
        'cancelled' => 'Cancelled',
        'expired' => 'Expired',
        _ => status,
      };

  @override
  void initState() {
    super.initState();
    _model = createModel(context, RoomDetailModel.new);
    _model.loadRoom(widget.roomId).then((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final room = _model.room;
    final isOrganizer =
        room?['organizer']?.toString() == currentUserId?.toString();

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        title: Text('Room Details', style: theme.titleMedium),
        centerTitle: true,
        elevation: 0,
      ),
      body: _model.isLoading
          ? const Center(child: CircularProgressIndicator())
          : room == null
              ? Center(
                  child: Text('Room not found', style: theme.bodyMedium))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: theme.border, width: 0.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  room['title']?.toString() ?? '',
                                  style: theme.titleLarge,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _statusColor(
                                          room['status']?.toString() ?? '',
                                          theme)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _statusLabel(
                                      room['status']?.toString() ?? ''),
                                  style: theme.bodySmall?.copyWith(
                                    color: _statusColor(
                                        room['status']?.toString() ?? '',
                                        theme),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            room['category_name']?.toString() ?? '',
                            style: theme.bodySmall?.copyWith(
                                color: theme.secondaryText),
                          ),
                          if (room['description']?.toString().isNotEmpty ==
                              true) ...[
                            const SizedBox(height: 8),
                            Text(room['description'].toString(),
                                style: theme.bodyMedium),
                          ],
                          const Divider(height: 24),
                          _infoRow(theme, Icons.calendar_today,
                              '${room['event_date'] ?? ''} ${room['event_time'] ?? ''}'),
                          if (room['event_location']
                                  ?.toString()
                                  .isNotEmpty ==
                              true)
                            _infoRow(theme, Icons.location_on,
                                room['event_location'].toString()),
                          _infoRow(
                            theme,
                            Icons.people,
                            '${(room['participants'] as List?)?.length ?? 0} / ${room['heads_required']} joined',
                          ),
                          if (room['price_per_head'] != null)
                            _infoRow(theme, Icons.attach_money,
                                '\$${room['price_per_head']}/head'),
                        ],
                      ),
                    ),
                    if (room['participants'] is List &&
                        (room['participants'] as List).isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text('Participants', style: theme.titleSmall),
                      const SizedBox(height: 8),
                      ...(room['participants'] as List).map((p) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: theme.secondaryBackground,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color: theme.border, width: 0.5),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    theme.primary.withValues(alpha: 0.1),
                                child: Icon(Icons.person,
                                    color: theme.primary),
                              ),
                              title: Text(
                                p['user_display_name']?.toString() ?? '',
                                style: theme.bodyMedium,
                              ),
                              trailing: p['role'] == 'organizer'
                                  ? Icon(Icons.star,
                                      color: theme.warning, size: 20)
                                  : null,
                            ),
                          )),
                    ],
                    const SizedBox(height: 24),
                    if (isOrganizer && room['status'] == 'open') ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                                text: room['join_token']?.toString() ?? ''));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Join code copied')),
                            );
                          },
                          icon: const Icon(Icons.share, size: 18),
                          label: const Text('Share Join Code'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final ok = await _model.lockRoom();
                            if (mounted) {
                              safeSetState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        ok ? 'Room locked' : 'Failed')),
                              );
                            }
                          },
                          icon: const Icon(Icons.lock, size: 18),
                          label: const Text('Lock Room'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () async {
                            final ok = await _model.cancelRoom();
                            if (mounted) {
                              safeSetState(() {});
                              if (ok) context.pop();
                            }
                          },
                          icon: Icon(Icons.cancel,
                              size: 18, color: theme.error),
                          label: Text('Cancel Room',
                              style:
                                  TextStyle(color: theme.error)),
                        ),
                      ),
                    ],
                    if (!isOrganizer && room['status'] == 'open') ...[
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final ok = await _model.leaveRoom();
                            if (mounted) {
                              if (ok) context.pop();
                            }
                          },
                          icon: const Icon(Icons.exit_to_app, size: 18),
                          label: const Text('Leave Room'),
                        ),
                      ),
                    ],
                  ],
                ),
    );
  }

  Widget _infoRow(AppThemeData theme, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.secondaryText),
          const SizedBox(width: 8),
          Expanded(
            child:
                Text(text, style: theme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
