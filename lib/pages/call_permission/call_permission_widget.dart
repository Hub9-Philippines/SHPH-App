import 'package:flutter/material.dart';

import '/components/cupertino_ui/app_button.dart';
import '/components/cupertino_ui/cupertino_page_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';
import 'call_permission_model.dart';

export 'call_permission_model.dart';

class CallPermissionWidget extends StatefulWidget {
  const CallPermissionWidget({
    super.key,
    this.mediaType = 'audio',
    this.participantName,
  });

  final String mediaType;
  final String? participantName;

  static String routeName = 'CallPermission';
  static String routePath = '/call-permission';

  @override
  State<CallPermissionWidget> createState() => _CallPermissionWidgetState();
}

class _CallPermissionWidgetState extends State<CallPermissionWidget> {
  late CallPermissionModel _model;
  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, CallPermissionModel.new);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final isVideo = widget.mediaType == 'video';

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CupertinoPageHeader(
          title: isVideo ? _l10n.callPermTitleVideo : _l10n.callPermTitleAudio,
          backgroundColor: theme.primaryBackground,
          titleStyle: theme.titleMedium,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isVideo ? Icons.videocam : Icons.call,
                  size: 40,
                  color: theme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isVideo
                    ? _l10n.callPermAllowBoth
                    : _l10n.callPermAllowMic,
                style: theme.titleLarge,
              ),
              if (widget.participantName != null) ...[
                const SizedBox(height: 8),
                Text(
                  _l10n.callPermCalling(widget.participantName!),
                  style: theme.bodyMedium.copyWith(
                      color: theme.secondaryText),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  onPressed: () {
                    setState(() {
                      _model.micGranted = true;
                      _model.cameraGranted = !isVideo || true;
                    });
                  },
                  backgroundColor: theme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check),
                      SizedBox(width: 8),
                      Text(_l10n.callPermAllow),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AppButton(
                onPressed: () => context.pop(),
                variant: AppButtonVariant.text,
                child: Text(_l10n.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
