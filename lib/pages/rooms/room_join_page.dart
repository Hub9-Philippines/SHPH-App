import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/services/rooms_controller.dart';

class RoomJoinPage extends StatefulWidget {
  const RoomJoinPage({super.key});
  static const routeName = 'RoomJoin';
  static const routePath = '/rooms/join';

  @override
  State<RoomJoinPage> createState() => _RoomJoinPageState();
}

class _RoomJoinPageState extends State<RoomJoinPage> {
  final _token = TextEditingController();

  @override
  void dispose() {
    _token.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rooms = context.watch<RoomsController>();
    final preview = rooms.previewRoom;
    return Scaffold(
      appBar: AppBar(title: const Text('Join room')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _token,
            decoration: const InputDecoration(labelText: 'Join token'),
          ),
          FilledButton(
            onPressed: rooms.isBusy
                ? null
                : () => unawaited(rooms.lookup(_token.text)),
            child: const Text('Look up room'),
          ),
          if (rooms.errorMessage != null)
            Text(rooms.errorMessage!,
                style: const TextStyle(color: Colors.red)),
          if (preview != null) ...[
            const SizedBox(height: 16),
            Text(preview.title),
            Text('${preview.seatsRemaining} seats remaining'),
            FilledButton(
              onPressed: rooms.isBusy || !preview.canJoin
                  ? null
                  : () async {
                      final joined = await rooms.joinPreview(_token.text);
                      if (joined && context.mounted) {
                        Navigator.of(context).pop(true);
                      }
                    },
              child: const Text('Join'),
            ),
          ],
        ],
      ),
    );
  }
}
