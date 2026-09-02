import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/components/cupertino_ui/app_activity_indicator.dart';
import '/components/cupertino_ui/app_button.dart';
import '/components/cupertino_ui/cupertino_page_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';
import 'room_detail_model.dart';

export 'room_detail_model.dart';

class RoomDetailWidget extends StatefulWidget {
  const RoomDetailWidget({super.key, required this.roomId});

  final String roomId;

  static String routeName = 'RoomDetail';
  static String routePath = '/rooms/:roomId';

  @override
  State<RoomDetailWidget> createState() => _RoomDetailWidgetState();
}

class _RoomDetailWidgetState extends State<RoomDetailWidget> {
  late RoomDetailModel _model;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  int? currentUserId;

  Color _statusColor(String status, AppThemeData theme) => switch (status) {
        'open' => theme.success,
        'locked' => theme.warning,
        'settled' => theme.primary,
        'cancelled' => theme.error,
        'expired' => theme.textTertiary,
        _ => theme.secondaryText,
      };

  String _statusLabel(String status) => switch (status) {
        'open' => _l10n.rlStatusOpen,
        'locked' => _l10n.rlStatusLocked,
        'settled' => _l10n.rlStatusSettled,
        'cancelled' => _l10n.rlStatusCancelled,
        'expired' => _l10n.rlStatusExpired,
        _ => status,
      };

  @override
  void initState() {
    super.initState();
    _model = createModel(context, RoomDetailModel.new);
    _model.loadRoom(widget.roomId).then((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final room = _model.room;
    final isOrganizer =
        room?['organizer']?.toString() == currentUserId?.toString();

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(44),
        child: CupertinoPageHeader(
          backgroundColor: theme.primaryBackground,
          title: _l10n.rdTitle,
          titleStyle: theme.titleMedium,
        ),
      ),
      body: _model.isLoading
          ? const Center(child: AppActivityIndicator())
          : room == null
              ? Center(
                  child: Text(_l10n.rdRoomNotFound, style: theme.bodyMedium))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: theme.border, width: 0.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  room['title']?.toString() ?? '',
                                  style: theme.titleLarge,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _statusColor(
                                          room['status']?.toString() ?? '',
                                          theme)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _statusLabel(
                                      room['status']?.toString() ?? ''),
                                  style: theme.bodySmall?.copyWith(
                                    color: _statusColor(
                                        room['status']?.toString() ?? '',
                                        theme),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            room['category_name']?.toString() ?? '',
                            style: theme.bodySmall?.copyWith(
                                color: theme.secondaryText),
                          ),
                          if (room['description']?.toString().isNotEmpty ==
                              true) ...[
                            const SizedBox(height: 8),
                            Text(room['description'].toString(),
                                style: theme.bodyMedium),
                          ],
                          const Divider(height: 24),
                          _infoRow(theme, Icons.calendar_today,
                              '${room['event_date'] ?? ''} ${room['event_time'] ?? ''}'),
                          if (room['event_location']
                                  ?.toString()
                                  .isNotEmpty ==
                              true)
                            _infoRow(theme, Icons.location_on,
                                room['event_location'].toString()),
                          _infoRow(
                            theme,
                            Icons.people,
                            _l10n.rdJoined(
                              (room['participants'] as List?)?.length ?? 0,
                              room['heads_required'] ?? '?',
                            ),
                          ),
                          if (room['price_per_head'] != null)
                            _infoRow(theme, Icons.attach_money,
                                '\$${room['price_per_head']}/head'),
                        ],
                      ),
                    ),
                    if (room['participants'] is List &&
                        (room['participants'] as List).isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(_l10n.rdParticipants, style: theme.titleSmall),
                      const SizedBox(height: 8),
                      ...(room['participants'] as List).map((p) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: theme.secondaryBackground,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color: theme.border, width: 0.5),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    theme.primary.withValues(alpha: 0.1),
                                child: Icon(Icons.person,
                                    color: theme.primary),
                              ),
                              title: Text(
                                p['user_display_name']?.toString() ?? '',
                                style: theme.bodyMedium,
                              ),
                              trailing: p['role'] == 'organizer'
                                  ? Icon(Icons.star,
                                      color: theme.warning, size: 20)
                                  : null,
                            ),
                          )),
                    ],
                    const SizedBox(height: 24),
                    if (isOrganizer && room['status'] == 'open') ...[
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                                text: room['join_token']?.toString() ?? ''));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(_l10n.rdJoinCodeCopied)),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.share, size: 18,
                                  color: Colors.white),
                              SizedBox(width: 8),
                              Text(_l10n.rdShareJoinCode),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          variant: AppButtonVariant.outlined,
                          onPressed: () async {
                            final ok = await _model.lockRoom();
                            if (mounted) {
                              safeSetState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        ok ? _l10n.rdRoomLocked : _l10n.rdFailed)),
                              );
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock, size: 18,
                                  color: theme.primaryText),
                              const SizedBox(width: 8),
                              Text(_l10n.rdLockRoom),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          variant: AppButtonVariant.text,
                          foregroundColor: theme.error,
                          onPressed: () async {
                            final ok = await _model.cancelRoom();
                            if (mounted) {
                              safeSetState(() {});
                              if (ok) context.pop();
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.cancel,
                                  size: 18, color: theme.error),
                              const SizedBox(width: 8),
                              Text(_l10n.rdCancelRoom),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (!isOrganizer && room['status'] == 'open') ...[
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          variant: AppButtonVariant.outlined,
                          onPressed: () async {
                            final ok = await _model.leaveRoom();
                            if (mounted) {
                              if (ok) context.pop();
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.exit_to_app, size: 18,
                                  color: theme.primaryText),
                              const SizedBox(width: 8),
                              Text(_l10n.rdLeaveRoom),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
    );
  }

  Widget _infoRow(AppThemeData theme, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.secondaryText),
          const SizedBox(width: 8),
          Expanded(
            child:
                Text(text, style: theme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
