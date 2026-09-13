import 'package:flutter/material.dart';

import '/components/cupertino_ui/app_button.dart';
import '/components/cupertino_ui/app_text_field.dart';
import '/components/cupertino_ui/cupertino_page_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/l10n/app_localizations.dart';
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

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  final _tokenCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, RoomJoinModel.new);
    if (widget.initialToken != null && widget.initialToken!.isNotEmpty) {
      _tokenCtrl.text = widget.initialToken!;
      _model.token = widget.initialToken!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _model.lookup(_l10n).then((_) => safeSetState(() {}));
        }
      });
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CupertinoPageHeader(
          backgroundColor: theme.primaryBackground,
          title: _l10n.rjTitle,
          titleStyle: theme.titleMedium,
        ),
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
                Text(_l10n.rjEnterJoinCode,
                    style: theme.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _tokenCtrl,
                        placeholder: _l10n.rjJoinCodePlaceholder,
                        radius: 8,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        onChanged: (v) => _model.token = v,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AppButton(
                      onPressed: _model.isLookingUp
                          ? null
                          : () => _model.lookup(_l10n)
                              .then((_) => safeSetState(() {})),
                      backgroundColor: theme.primary,
                      loading: _model.isLookingUp,
                      child: Text(_l10n.rjLookUp),
                    ),
                  ],
                ),
                if (_model.errorMsg != null) ...[
                  const SizedBox(height: 8),
                  Text(_model.errorMsg!,
                      style: theme.bodySmall
                          .copyWith(color: theme.error)),
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
                          .copyWith(color: theme.secondaryText)),
                  const SizedBox(height: 8),
                  Text(
                    _l10n.rjSeats(
                      preview['heads_required'] ?? '?',
                      preview['seats_remaining'] ?? '?',
                    ),
                    style: theme.bodyMedium,
                  ),
                  Text(
                    '${preview['event_date'] ?? ''} ${preview['event_time'] ?? ''}',
                    style: theme.bodySmall
                        .copyWith(color: theme.secondaryText),
                  ),
                  if (preview['price_per_head'] != null)
                    Text('\$${preview['price_per_head']}/head',
                        style: theme.bodyMedium),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
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
                                    SnackBar(
                                        content:
                                            Text(_l10n.rjFailedJoin)),
                                  );
                                }
                              }
                            },
                      backgroundColor:
                          canJoin ? theme.primary : theme.textTertiary,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      loading: _model.isJoining,
                      child: Text(canJoin
                          ? _l10n.rjJoinRoom
                          : _l10n.rjCannotJoin),
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
