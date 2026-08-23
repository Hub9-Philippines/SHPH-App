import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
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
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        title: Text(isVideo ? 'Camera & Microphone' : 'Microphone',
            style: theme.titleMedium),
        centerTitle: true,
        elevation: 0,
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
                    ? 'Allow camera & microphone'
                    : 'Allow microphone',
                style: theme.titleLarge,
              ),
              if (widget.participantName != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Calling ${widget.participantName}',
                  style: theme.bodyMedium.copyWith(
                      color: theme.secondaryText),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _model.micGranted = true;
                      _model.cameraGranted = !isVideo || true;
                    });
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Allow'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
