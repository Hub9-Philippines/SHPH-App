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
      body: controller.isBusy && controller.rooms.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : controller.rooms.isEmpty
              ? Center(
                  child: Text(controller.errorMessage ?? 'No rooms yet.'),
                )
              : RefreshIndicator(
                  onRefresh: () async => controller.load(),
                  child: ListView.builder(
                    itemCount: controller.rooms.length,
                    itemBuilder: (context, index) {
                      final room = controller.rooms[index];
                      return ListTile(
                        title: Text(room.title),
                        subtitle: Text(
                          '${room.status} · ${room.seatsRemaining} seats left',
                        ),
                        onTap: () => context.push<bool>(
                          '/rooms/detail/${room.id}',
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
