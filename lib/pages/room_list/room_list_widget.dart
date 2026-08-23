import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import 'room_list_model.dart';

export 'room_list_model.dart';

class RoomListWidget extends StatefulWidget {
  const RoomListWidget({super.key});

  static String routeName = 'RoomList';
  static String routePath = '/rooms';

  @override
  State<RoomListWidget> createState() => _RoomListWidgetState();
}

class _RoomListWidgetState extends State<RoomListWidget> {
  late RoomListModel _model;

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
    _model = createModel(context, RoomListModel.new);
    _model.loadRooms().then((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        title: Text('Rooms', style: theme.titleMedium),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/rooms/create'),
          ),
        ],
      ),
      body: _model.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _model.rooms.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.meeting_room,
                          size: 64, color: theme.secondaryText),
                      const SizedBox(height: 16),
                      Text('No rooms yet', style: theme.bodyMedium),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.push('/rooms/create'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                        ),
                        child: const Text('Create Room'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      _model.loadRooms().then((_) => safeSetState(() {})),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _model.rooms.length,
                    itemBuilder: (context, index) {
                      final room = _model.rooms[index];
                      final status = room['status']?.toString() ?? 'open';
                      final statusColor = _statusColor(status, theme);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: theme.secondaryBackground,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: theme.border, width: 0.5),
                        ),
                        child: InkWell(
                          onTap: () => context.push(
                            '/rooms/${room['id']}',
                          ),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        room['title']?.toString() ?? '',
                                        style: theme.titleSmall,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        _statusLabel(status),
                                        style: theme.bodySmall?.copyWith(
                                          color: statusColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  room['category_name']?.toString() ?? '',
                                  style: theme.bodySmall?.copyWith(
                                      color: theme.secondaryText),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.people,
                                        size: 16, color: theme.secondaryText),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${room['seats_remaining'] ?? '?'}/${room['heads_required'] ?? '?'} seats',
                                      style: theme.bodySmall?.copyWith(
                                          color: theme.secondaryText),
                                    ),
                                    const Spacer(),
                                    if (room['price_per_head'] != null)
                                      Text(
                                        '\$${room['price_per_head']}',
                                        style: theme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w600),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
