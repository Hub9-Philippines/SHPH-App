import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/services/rooms_controller.dart';

import 'room_create_page.dart';
import 'room_join_page.dart';

class RoomListPage extends StatefulWidget {
  const RoomListPage({super.key});
  static const routeName = 'RoomList';
  static const routePath = '/rooms';

  @override
  State<RoomListPage> createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> {
  String? _status;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(context.read<RoomsController>().load());
      }
    });
  }

  Future<void> _open(String path) async {
    final changed = await context.push<bool>(path);
    if (changed == true && mounted) {
      unawaited(context.read<RoomsController>().load());
    }
  }

  Future<void> _filter(String? status) async {
    setState(() => _status = status);
    await context.read<RoomsController>().load(status: status);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RoomsController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rooms'),
        actions: [
          IconButton(
            tooltip: 'Join room',
            onPressed: () => _open(RoomJoinPage.routePath),
            icon: const Icon(Icons.login),
          ),
          IconButton(
            tooltip: 'Create room',
            onPressed: () => _open(RoomCreatePage.routePath),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 58,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                for (final entry in const <String?, String>{
                  null: 'All',
                  'open': 'Open',
                  'locked': 'Locked',
                  'settled': 'Settled',
                  'cancelled': 'Cancelled',
                }.entries)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(entry.value),
                      selected: _status == entry.key,
                      onSelected: controller.isBusy
                          ? null
                          : (_) => unawaited(_filter(entry.key)),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: controller.isBusy && controller.rooms.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : controller.rooms.isEmpty
                    ? _RoomEmptyState(
                        message: controller.errorMessage ?? 'No rooms found.',
                        onRetry: () => _filter(_status),
                        onCreate: () => _open(RoomCreatePage.routePath),
                      )
                    : RefreshIndicator(
                        onRefresh: () async => controller.load(status: _status),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: controller.rooms.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final room = controller.rooms[index];
                            return Card(
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  child: Icon(room.isOpen
                                      ? Icons.groups_rounded
                                      : Icons.lock_outline),
                                ),
                                title: Text(room.title),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    '${room.categoryName ?? 'Service'}\n'
                                    '${room.eventDate} ${room.eventTime} · '
                                    '${room.seatsRemaining} seats · '
                                    '₱${room.pricePerHead.toStringAsFixed(2)}',
                                  ),
                                ),
                                isThreeLine: true,
                                trailing: Chip(label: Text(room.status)),
                                onTap: () => context.push<bool>(
                                  '/rooms/detail/${room.id}',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _RoomEmptyState extends StatelessWidget {
  const _RoomEmptyState({
    required this.message,
    required this.onRetry,
    required this.onCreate,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.groups_outlined, size: 52),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(
                      onPressed: onRetry, child: const Text('Retry')),
                  FilledButton(
                      onPressed: onCreate, child: const Text('Create')),
                ],
              ),
            ],
          ),
        ),
      );
}
