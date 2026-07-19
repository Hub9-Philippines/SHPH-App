import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Status: ${room.status}'),
                Text('Date: ${room.eventDate} ${room.eventTime}'),
                Text('${room.seatsRemaining} seats remaining'),
                ...room.participants.map(
                  (participant) => ListTile(
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
                    if (room.isOpen)
                      FilledButton(
                        onPressed:
                            rooms.isBusy ? null : () => unawaited(rooms.lock()),
                        child: const Text('Lock room'),
                      ),
                    OutlinedButton(
                      onPressed: rooms.isBusy
                          ? null
                          : () => unawaited(_finish(rooms.leave)),
                      child: const Text('Leave'),
                    ),
                    OutlinedButton(
                      onPressed: rooms.isBusy
                          ? null
                          : () => unawaited(_finish(rooms.cancel)),
                      child: const Text('Cancel room'),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Future<void> _finish(Future<bool> Function() action) async {
    final changed = await action();
    if (changed && mounted) {
      Navigator.of(context).pop(true);
    }
  }
}
