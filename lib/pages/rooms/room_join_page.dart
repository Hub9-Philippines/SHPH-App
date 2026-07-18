import 'package:flutter/material.dart';

import '/api/models/room.dart';
import '/api/resources/rooms_api.dart';
import '/theme/app_theme.dart';

/// Join a Room via token (SHPH-133).
///
/// Mirrors `shph-app/src/views/services/RoomJoinPage.vue`. Looks up the room
/// by its join token via the public `by-token` endpoint, then calls `join()`.
class RoomJoinPage extends StatefulWidget {
  const RoomJoinPage({super.key});

  static String routeName = 'RoomJoin';
  static String routePath = '/rooms/join';

  @override
  State<RoomJoinPage> createState() => _RoomJoinPageState();
}

class _RoomJoinPageState extends State<RoomJoinPage> {
  final _tokenCtrl = TextEditingController();
  ShphRoom? _preview;
  bool _isLookingUp = false;
  bool _isJoining = false;
  String? _errorMessage;

  @override
  void dispose() {
    _tokenCtrl.dispose();
    super.dispose();
  }

  Future<void> _lookup() async {
    final token = _tokenCtrl.text.trim();
    if (token.isEmpty) {
      setState(() => _errorMessage = 'Enter a join code');
      return;
    }
    setState(() {
      _isLookingUp = true;
      _errorMessage = null;
      _preview = null;
    });
    try {
      final room = await ShphRoomsApi.instance.byToken(token);
      if (mounted) {
        setState(() {
          _preview = room;
          _isLookingUp = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLookingUp = false;
          _errorMessage = 'No room found for that code: $e';
        });
      }
    }
  }

  Future<void> _join() async {
    final room = _preview;
    if (room == null) return;
    setState(() {
      _isJoining = true;
      _errorMessage = null;
    });
    try {
      await ShphRoomsApi.instance.join(room.id, joinToken: room.joinToken);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Joined room')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isJoining = false;
          _errorMessage = 'Failed to join: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text('Join Room',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        backgroundColor: theme.primaryBackground,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Text('Enter the join code shared with you',
              style: theme.bodyMedium.override(color: theme.secondaryText)),
          const SizedBox(height: 12),
          TextField(
            controller: _tokenCtrl,
            decoration: InputDecoration(
              hintText: 'Paste join code',
              border: const OutlineInputBorder(),
              suffixIcon: _isLookingUp
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _lookup,
                    ),
            ),
            onSubmitted: (_) => _lookup(),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(_errorMessage!,
                style: theme.bodyMedium.override(color: theme.error)),
          ],
          if (_preview != null) ...[
            const SizedBox(height: 20),
            _PreviewCard(room: _preview!),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isJoining ? null : _join,
              icon: _isJoining
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.login),
              label: Text(_isJoining ? 'Joining…' : 'Join Room'),
            ),
          ],
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.room});
  final ShphRoom room;

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
          Text(room.title,
              style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
          if (room.categoryName != null) ...[
            const SizedBox(height: 4),
            Text(room.categoryName!,
                style: theme.bodySmall.override(color: theme.secondaryText)),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _Meta(
                  icon: Icons.event,
                  label: '${room.eventDate} · ${room.eventTime}'),
              _Meta(
                icon: Icons.group_outlined,
                label: room.isFull
                    ? 'Full'
                    : '${room.seatsRemaining}/${room.headsRequired} seats left',
              ),
              _Meta(
                icon: Icons.payments_outlined,
                label: 'PHP ${room.pricePerHead.toStringAsFixed(0)}/head',
              ),
            ],
          ),
          if (room.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(room.description, style: theme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});
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
