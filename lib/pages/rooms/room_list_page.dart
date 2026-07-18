import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/api/models/paginated_response.dart';
import '/api/models/room.dart';
import '/api/resources/rooms_api.dart';
import '/index.dart';
import '/theme/app_theme.dart';

/// Lists rooms visible to the current user (SHPH-133).
///
/// Mirrors `shph-app/src/views/services/RoomListPage.vue`. Backed by
/// `ShphRoomsApi.list()` → POST `/api/services/rooms/list/`.
class RoomListPage extends StatefulWidget {
  const RoomListPage({super.key});

  static String routeName = 'RoomList';
  static String routePath = '/rooms';

  @override
  State<RoomListPage> createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> {
  List<ShphRoom> _rooms = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final PaginatedResponse<ShphRoom> response =
          await ShphRoomsApi.instance.list();
      if (mounted) {
        setState(() {
          _rooms = response.results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load rooms: $e';
        });
      }
    }
  }

  Future<void> _openCreate() async {
    final created = await context.push<bool>(RoomCreatePage.routePath);
    if (created == true) {
      _loadRooms();
    }
  }

  Future<void> _openJoin() async {
    final joined = await context.push<bool>(RoomJoinPage.routePath);
    if (joined == true) {
      _loadRooms();
    }
  }

  Future<void> _openDetail(ShphRoom room) async {
    final refreshed = await context.push<bool>('/rooms/detail/${room.id}');
    if (refreshed == true) {
      _loadRooms();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text('Rooms',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        backgroundColor: theme.primaryBackground,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Join with code',
            onPressed: _openJoin,
            icon: const Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _ErrorView(message: _errorMessage!, onRetry: _loadRooms)
              : _rooms.isEmpty
                  ? _EmptyView(onCreate: _openCreate, onJoin: _openJoin)
                  : RefreshIndicator(
                      onRefresh: _loadRooms,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                        itemCount: _rooms.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) =>
                            _RoomCard(room: _rooms[i], onTap: _openDetail),
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.add),
        label: const Text('New Room'),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({required this.room, required this.onTap});
  final ShphRoom room;
  final void Function(ShphRoom) onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Material(
      color: theme.primaryBackground,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onTap(room),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      room.title,
                      style: theme.titleMedium
                          .override(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _StatusChip(status: room.status),
                ],
              ),
              if (room.categoryName != null) ...[
                const SizedBox(height: 4),
                Text(room.categoryName!,
                    style:
                        theme.bodySmall.override(color: theme.secondaryText)),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  _MetaPill(
                    icon: Icons.event,
                    label: '${room.eventDate} · ${room.eventTime}',
                  ),
                  const SizedBox(width: 12),
                  _MetaPill(
                    icon: Icons.group_outlined,
                    label: room.isFull
                        ? 'Full'
                        : '${room.seatsRemaining}/${room.headsRequired} seats',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _MetaPill(
                    icon: Icons.payments_outlined,
                    label: 'PHP ${room.pricePerHead.toStringAsFixed(0)}/head',
                  ),
                  if (room.eventLocation.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetaPill(
                        icon: Icons.location_on_outlined,
                        label: room.eventLocation,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final (label, color) = _style(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: theme.bodySmall.override(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  (String, Color) _style(String status) {
    switch (status) {
      case 'open':
        return ('Open', Colors.green.shade700);
      case 'locked':
        return ('Locked', Colors.orange.shade700);
      case 'settled':
        return ('Settled', Colors.blue.shade700);
      case 'cancelled':
        return ('Cancelled', Colors.red.shade700);
      case 'expired':
        return ('Expired', Colors.grey.shade500);
      default:
        return (status, Colors.blueGrey);
    }
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.secondaryText),
        const SizedBox(width: 4),
        Text(label,
            style: theme.bodySmall.override(color: theme.secondaryText),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onCreate, required this.onJoin});
  final VoidCallback onCreate;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.groups, size: 64, color: theme.secondaryText),
            const SizedBox(height: 16),
            Text('No rooms yet',
                style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Create a group ROOM to share a service slot with others, or join with a code.',
              textAlign: TextAlign.center,
              style: theme.bodyMedium.override(color: theme.secondaryText),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: onCreate,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Room'),
                ),
                OutlinedButton.icon(
                  onPressed: onJoin,
                  icon: const Icon(Icons.qr_code),
                  label: const Text('Join with Code'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.error),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: theme.bodyMedium.override(color: theme.secondaryText)),
            const SizedBox(height: 20),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
