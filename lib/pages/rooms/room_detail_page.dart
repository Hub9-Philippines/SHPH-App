import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/services/rooms_controller.dart';

class RoomDetailPage extends StatefulWidget {
  const RoomDetailPage({required this.roomId, super.key});
  final String roomId;
  static const routeName = 'RoomDetail';
  static const routePath = '/rooms/detail/:roomId';

  @override
  State<RoomDetailPage> createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.roomId.isNotEmpty) {
        unawaited(context.read<RoomsController>().open(widget.roomId));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final rooms = context.watch<RoomsController>();
    final current = rooms.currentRoom;
    final room = current?.id == widget.roomId ? current : null;
    final userId = int.tryParse(currentUserUid);
    if (widget.roomId.isEmpty) {
      return const Scaffold(body: Center(child: Text('Invalid room id.')));
    }
    return Scaffold(
      appBar: AppBar(title: Text(room?.title ?? 'Room')),
      body: room == null
          ? Center(
              child: rooms.state == RoomsState.error
                  ? Text(rooms.errorMessage ?? 'Unable to load room.')
                  : const CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async => rooms.open(widget.roomId),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(room.categoryName ?? 'Service room',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                              ),
                              Chip(label: Text(room.status)),
                            ],
                          ),
                          if (room.description.isNotEmpty)
                            Text(room.description),
                          const SizedBox(height: 12),
                          _DetailLine(Icons.calendar_month_outlined,
                              '${room.eventDate} at ${room.eventTime}'),
                          if (room.eventLocation.isNotEmpty)
                            _DetailLine(
                                Icons.location_on_outlined, room.eventLocation),
                          _DetailLine(Icons.people_outline,
                              '${room.seatsRemaining} seats remaining of ${room.headsRequired}'),
                          _DetailLine(Icons.payments_outlined,
                              '₱${room.pricePerHead.toStringAsFixed(2)} per person'),
                          if (room.organizerName?.isNotEmpty == true)
                            _DetailLine(Icons.person_outline,
                                'Organized by ${room.organizerName}'),
                        ],
                      ),
                    ),
                  ),
                  if (room.joinToken?.isNotEmpty == true &&
                      room.organizer == userId) ...[
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.key_outlined),
                        title: const Text('Join token'),
                        subtitle: Text(room.joinToken!),
                        trailing: IconButton(
                          tooltip: 'Copy join token',
                          onPressed: () async {
                            await Clipboard.setData(
                                ClipboardData(text: room.joinToken!));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Join token copied')),
                              );
                            }
                          },
                          icon: const Icon(Icons.copy_outlined),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text('Participants',
                      style: Theme.of(context).textTheme.titleMedium),
                  if (room.participants.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No participants yet.'),
                    ),
                  ...room.participants.map(
                    (participant) => ListTile(
                      leading: CircleAvatar(
                        child: Text((participant.userDisplayName ?? 'P')
                            .characters
                            .first
                            .toUpperCase()),
                      ),
                      title: Text(
                        participant.userDisplayName ?? 'Participant',
                      ),
                      subtitle:
                          Text('${participant.role} · ${participant.status}'),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (room.isOpen && room.organizer == userId)
                        FilledButton(
                          onPressed: rooms.isBusy
                              ? null
                              : () => _confirmAndRun(
                                    'Lock room?',
                                    'No new participants can join after locking.',
                                    rooms.lock,
                                    closeOnSuccess: false,
                                  ),
                          child: const Text('Lock room'),
                        ),
                      if (room.organizer != userId &&
                          room.participants.any((item) => item.user == userId))
                        OutlinedButton(
                          onPressed: rooms.isBusy
                              ? null
                              : () => _confirmAndRun(
                                    'Leave room?',
                                    'Your place in this room will be released.',
                                    rooms.leave,
                                  ),
                          child: const Text('Leave'),
                        ),
                      if (room.organizer == userId && room.isActive)
                        OutlinedButton(
                          onPressed: rooms.isBusy
                              ? null
                              : () => _confirmAndRun(
                                    'Cancel room?',
                                    'This action affects every participant and cannot be undone.',
                                    rooms.cancel,
                                  ),
                          child: const Text('Cancel room'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _confirmAndRun(
    String title,
    String message,
    Future<bool> Function() action, {
    bool closeOnSuccess = true,
  }) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Back'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    final changed = await action();
    if (changed && mounted && closeOnSuccess) Navigator.of(context).pop(true);
  }

}

class _DetailLine extends StatelessWidget {
  const _DetailLine(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ],
        ),
      );
}
