import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import 'sessions_model.dart';

export 'sessions_model.dart';

class SessionsWidget extends StatefulWidget {
  const SessionsWidget({super.key});

  static String routeName = 'Sessions';
  static String routePath = '/sessions';

  @override
  State<SessionsWidget> createState() => _SessionsWidgetState();
}

class _SessionsWidgetState extends State<SessionsWidget> {
  late SessionsModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, SessionsModel.new);
    _model.loadSessions().then((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _confirmRevokeAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out All Devices'),
        content: const Text(
          'This will sign you out of all active sessions except this one.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out All'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final ok = await _model.revokeAllSessions();
      if (mounted) {
        if (ok) {
          setState(() => _model.sessions.clear());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All other sessions revoked')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to revoke sessions')),
          );
        }
      }
    }
  }

  Future<void> _revokeSingle(String sessionId) async {
    final ok = await _model.revokeSession(sessionId);
    if (mounted) {
      if (ok) {
        safeSetState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session revoked')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to revoke session')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        title: Text('Active Sessions', style: theme.titleMedium),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_model.sessions.isNotEmpty)
            IconButton(
              onPressed: _model.isRevokingAll ? null : _confirmRevokeAll,
              icon: Icon(Icons.logout,
                  color: _model.isRevokingAll
                      ? theme.textTertiary
                      : theme.error),
              tooltip: 'Sign Out All',
            ),
        ],
      ),
      body: _model.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _model.sessions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.devices,
                          size: 64, color: theme.secondaryText),
                      const SizedBox(height: 16),
                      Text('No active sessions',
                          style: theme.bodyMedium),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _model.sessions.length,
                  itemBuilder: (context, index) {
                    final session = _model.sessions[index];
                    final sessionId =
                        session['session_id']?.toString() ?? '';
                    final device =
                        session['device']?.toString() ?? 'Unknown';
                    final platform =
                        session['platform']?.toString() ?? '';
                    final loginAt =
                        session['login_at']?.toString() ?? '';
                    final ip = session['ip']?.toString() ?? '';
                    final isCurrent = index == 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: theme.secondaryBackground,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                            color: isCurrent
                                ? theme.primary.withValues(alpha: 0.5)
                                : theme.border,
                            width: isCurrent ? 1.5 : 0.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: theme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                platform.toLowerCase().contains('ios') ||
                                        platform.toLowerCase().contains('iphone')
                                    ? Icons.phone_iphone
                                    : platform.toLowerCase().contains('android')
                                        ? Icons.android
                                        : Icons.devices,
                                color: theme.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(device,
                                          style: theme.bodyMedium
                                              ?.copyWith(
                                                  fontWeight:
                                                      FontWeight.w600)),
                                      if (isCurrent) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2),
                                          decoration: BoxDecoration(
                                            color: theme.success
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text('Current',
                                              style: theme.bodySmall
                                                  ?.copyWith(
                                                      color:
                                                          theme.success,
                                                      fontSize: 10)),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  if (loginAt.isNotEmpty)
                                    Text(loginAt,
                                        style: theme.bodySmall?.copyWith(
                                            color: theme.secondaryText)),
                                  if (ip.isNotEmpty)
                                    Text(ip,
                                        style: theme.bodySmall?.copyWith(
                                            color: theme.secondaryText)),
                                ],
                              ),
                            ),
                            if (!isCurrent)
                              IconButton(
                                onPressed: () =>
                                    _revokeSingle(sessionId),
                                icon: Icon(Icons.logout,
                                    color: theme.error, size: 20),
                                tooltip: 'Revoke',
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
