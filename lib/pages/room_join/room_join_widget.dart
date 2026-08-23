import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import 'room_join_model.dart';

export 'room_join_model.dart';

class RoomJoinWidget extends StatefulWidget {
  const RoomJoinWidget({super.key, this.initialToken});

  final String? initialToken;

  static String routeName = 'RoomJoin';
  static String routePath = '/rooms/join';

  @override
  State<RoomJoinWidget> createState() => _RoomJoinWidgetState();
}

class _RoomJoinWidgetState extends State<RoomJoinWidget> {
  late RoomJoinModel _model;
  final _tokenCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, RoomJoinModel.new);
    if (widget.initialToken != null && widget.initialToken!.isNotEmpty) {
      _tokenCtrl.text = widget.initialToken!;
      _model.token = widget.initialToken!;
      _model.lookup().then((_) => safeSetState(() {}));
    }
  }

  @override
  void dispose() {
    _tokenCtrl.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final preview = _model.preview;
    final canJoin = preview != null &&
        preview['status']?.toString() == 'open' &&
        preview['is_full'] != true;

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        title: Text('Join Room', style: theme.titleMedium),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.border, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Enter Join Code',
                    style: theme.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _tokenCtrl,
                        decoration: InputDecoration(
                          hintText: 'Join code',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        onChanged: (v) => _model.token = v,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _model.isLookingUp
                          ? null
                          : () => _model.lookup()
                              .then((_) => safeSetState(() {})),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                      ),
                      child: _model.isLookingUp
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: theme.onPrimary),
                            )
                          : const Text('Look Up'),
                    ),
                  ],
                ),
                if (_model.errorMsg != null) ...[
                  const SizedBox(height: 8),
                  Text(_model.errorMsg!,
                      style: theme.bodySmall
                          ?.copyWith(color: theme.error)),
                ],
              ],
            ),
          ),
          if (preview != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.secondaryBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.border, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(preview['title']?.toString() ?? '',
                      style: theme.titleSmall),
                  const SizedBox(height: 4),
                  Text(preview['category_name']?.toString() ?? '',
                      style: theme.bodySmall
                          ?.copyWith(color: theme.secondaryText)),
                  const SizedBox(height: 8),
                  Text(
                    'Seats: ${preview['seats_remaining'] ?? '?'}/${preview['heads_required'] ?? '?'}',
                    style: theme.bodyMedium,
                  ),
                  Text(
                    '${preview['event_date'] ?? ''} ${preview['event_time'] ?? ''}',
                    style: theme.bodySmall
                        ?.copyWith(color: theme.secondaryText),
                  ),
                  if (preview['price_per_head'] != null)
                    Text('\$${preview['price_per_head']}/head',
                        style: theme.bodyMedium),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: !canJoin || _model.isJoining
                          ? null
                          : () async {
                              final id = await _model.join();
                              if (mounted) {
                                if (id != null) {
                                  context.replace('/rooms/$id');
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Failed to join room')),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            canJoin ? theme.primary : theme.textTertiary,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _model.isJoining
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: theme.onPrimary),
                            )
                          : Text(canJoin
                              ? 'Join Room'
                              : 'Cannot Join'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
