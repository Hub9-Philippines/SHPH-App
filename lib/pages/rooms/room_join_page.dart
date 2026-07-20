import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              labelText: 'Join token',
              hintText: 'Paste a token shared by the organizer',
              prefixIcon: const Icon(Icons.key_outlined),
              suffixIcon: IconButton(
                tooltip: 'Paste token',
                onPressed: rooms.isBusy
                    ? null
                    : () async {
                        final data = await Clipboard.getData('text/plain');
                        if (data?.text != null)
                          _token.text = data!.text!.trim();
                      },
                icon: const Icon(Icons.content_paste_outlined),
              ),
            ),
            onSubmitted: rooms.isBusy
                ? null
                : (_) => unawaited(rooms.lookup(_token.text)),
          ),
          const SizedBox(height: 12),
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(preview.title,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(preview.categoryName ?? 'Service room'),
                    Text('${preview.eventDate} at ${preview.eventTime}'),
                    Text('${preview.seatsRemaining} seats remaining'),
                    Text(
                        '₱${preview.pricePerHead.toStringAsFixed(2)} per person'),
                    if (!preview.canJoin)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('This room is not accepting participants.'),
                      ),
                  ],
                ),
              ),
            ),
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
