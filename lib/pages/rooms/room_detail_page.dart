import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/api/models/room.dart';
import '/api/resources/rooms_api.dart';
import '/theme/app_theme.dart';

/// Detail view for a single Room (SHPH-133).
///
/// Mirrors `shph-app/src/views/services/RoomDetailPage.vue`. Shows
/// participants and exposes lock/cancel/leave/share actions. Backed by
/// `ShphRoomsApi.detail()` → POST `/api/services/rooms/<pk>/`.
class RoomDetailPage extends StatefulWidget {
  const RoomDetailPage({super.key, required this.roomId});

  final String roomId;

  static String routeName = 'RoomDetail';
  static String routePath = '/rooms/detail/:roomId';

  @override
  State<RoomDetailPage> createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  ShphRoom? _room;
  bool _isLoading = true;
  bool _isBusy = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRoom();
  }

  Future<void> _loadRoom() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final room = await ShphRoomsApi.instance.detail(widget.roomId);
      if (mounted) {
        setState(() {
          _room = room;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load room: $e';
        });
      }
    }
  }

  Future<void> _runAction(
    String label,
    Future<ShphRoom> Function() action,
  ) async {
    setState(() => _isBusy = true);
    try {
      final updated = await action();
      if (mounted) {
        setState(() {
          _room = updated;
          _isBusy = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label complete')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isBusy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label failed: $e')),
        );
      }
    }
  }

  Future<void> _confirmCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel room?'),
        content: const Text(
            'This will cancel the room and release all participants. This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Keep')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Cancel room')),
        ],
      ),
    );
    if (confirmed != true) return;
    await _runAction(
        'Cancel', () => ShphRoomsApi.instance.cancel(widget.roomId));
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _shareToken() async {
    final token = _room?.joinToken;
    if (token == null || token.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: token));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Join code copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text(_room?.title ?? 'Room',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        backgroundColor: theme.primaryBackground,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _ErrorView(message: _errorMessage!, onRetry: _loadRoom)
              : _room == null
                  ? const SizedBox.shrink()
                  : RefreshIndicator(
                      onRefresh: _loadRoom,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                        children: [
                          _HeaderCard(room: _room!, onShare: _shareToken),
                          const SizedBox(height: 16),
                          _ActionRow(
                            room: _room!,
                            isBusy: _isBusy,
                            onLock: () => _runAction(
                                'Lock',
                                () =>
                                    ShphRoomsApi.instance.lock(widget.roomId)),
                            onLeave: () => _runAction(
                                'Leave',
                                () =>
                                    ShphRoomsApi.instance.leave(widget.roomId)),
                            onCancel: _confirmCancel,
                          ),
                          const SizedBox(height: 16),
                          Text('Participants (${_room!.participants.length})',
                              style: theme.titleMedium
                                  .override(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          ..._room!.participants
                              .map((p) => _ParticipantRow(participant: p)),
                        ],
                      ),
                    ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.room, required this.onShare});
  final ShphRoom room;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(room.title,
                    style: theme.titleMedium
                        .override(fontWeight: FontWeight.w700)),
              ),
              _StatusPill(status: room.status),
            ],
          ),
          if (room.categoryName != null) ...[
            const SizedBox(height: 4),
            Text(room.categoryName!,
                style: theme.bodySmall.override(color: theme.secondaryText)),
          ],
          const SizedBox(height: 12),
          if (room.description.isNotEmpty)
            Text(room.description, style: theme.bodyMedium),
          if (room.menuOrService.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(room.menuOrService,
                style: theme.bodySmall.override(color: theme.secondaryText)),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _MetaItem(
                  icon: Icons.event,
                  label: '${room.eventDate} · ${room.eventTime}'),
              _MetaItem(
                icon: Icons.group_outlined,
                label: room.isFull
                    ? 'Full (${room.headsRequired})'
                    : '${room.participants.length}/${room.headsRequired} joined',
              ),
              _MetaItem(
                icon: Icons.payments_outlined,
                label: 'PHP ${room.pricePerHead.toStringAsFixed(0)}/head',
              ),
              if (room.eventLocation.isNotEmpty)
                _MetaItem(
                    icon: Icons.location_on_outlined,
                    label: room.eventLocation),
            ],
          ),
          if (room.joinToken != null && room.joinToken!.isNotEmpty) ...[
            const SizedBox(height: 16),
            InkWell(
              onTap: onShare,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.qr_code, color: theme.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Join code',
                              style: theme.bodySmall
                                  .override(color: theme.secondaryText)),
                          Text(room.joinToken!,
                              style: theme.bodyMedium
                                  .override(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    Icon(Icons.copy, color: theme.primary, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final color = _color(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: theme.bodySmall.override(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _color(String s) {
    switch (s) {
      case 'open':
        return Colors.green.shade700;
      case 'locked':
        return Colors.orange.shade700;
      case 'settled':
        return Colors.blue.shade700;
      case 'cancelled':
        return Colors.red.shade700;
      case 'expired':
        return Colors.grey.shade500;
      default:
        return Colors.blueGrey;
    }
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.label});
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
            style: theme.bodySmall.override(color: theme.secondaryText)),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.room,
    required this.isBusy,
    this.onLock,
    this.onLeave,
    this.onCancel,
  });

  final ShphRoom room;
  final bool isBusy;
  final VoidCallback? onLock;
  final VoidCallback? onLeave;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final canLock = room.isOpen && onLock != null;
    final canLeave = !room.isCancelled && onLeave != null;
    final canCancel = (room.isOpen || room.isLocked) && onCancel != null;
    return Wrap(
      spacing: 8,
      children: [
        if (canLock)
          FilledButton.tonalIcon(
            onPressed: isBusy ? null : onLock,
            icon: const Icon(Icons.lock_outline),
            label: const Text('Lock'),
          ),
        if (canLeave)
          OutlinedButton(
            onPressed: isBusy ? null : onLeave,
            child: const Text('Leave'),
          ),
        if (canCancel)
          OutlinedButton(
            onPressed: isBusy ? null : onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade700,
            ),
            child: const Text('Cancel room'),
          ),
      ],
    );
  }
}

class _ParticipantRow extends StatelessWidget {
  const _ParticipantRow({required this.participant});
  final ShphRoomParticipant participant;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: theme.primary.withValues(alpha: 0.15),
            child: Icon(Icons.person, size: 18, color: theme.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(participant.userDisplayName ?? 'User #${participant.user}',
                    style: theme.bodyMedium),
                Text('${participant.role} · ${participant.status}',
                    style:
                        theme.bodySmall.override(color: theme.secondaryText)),
              ],
            ),
          ),
        ],
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
