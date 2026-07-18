import 'package:flutter/material.dart';

import '/api/models/session.dart';
import '/api/resources/auth_api.dart';
import '/theme/app_theme.dart';

/// Manage active sessions/devices.
///
/// Mirrors `shph-app/src/views/profile/SessionsPage.vue`. Backed by
/// `ShphAuthApi.listSessions()` / `revokeSession()` / `revokeAllSessions()`.
/// Replaces the empty stub in `security_settings_widget.dart`.
class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  static String routeName = 'Sessions';
  static String routePath = '/sessions';

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  List<ShphSession> _sessions = const [];
  bool _isLoading = true;
  bool _isBusy = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final sessions = await ShphAuthApi.instance.listSessions();
      if (mounted) {
        setState(() {
          _sessions = sessions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load sessions: $e';
        });
      }
    }
  }

  Future<void> _revoke(ShphSession session) async {
    if (session.isCurrent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Use Sign Out to end your current session')),
      );
      return;
    }
    setState(() => _isBusy = true);
    try {
      await ShphAuthApi.instance.revokeSession(session.sessionId);
      _loadSessions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session revoked')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Revoke failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _revokeAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revoke all other sessions?'),
        content: const Text(
            'This will sign out every other device. Your current session will remain active.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Revoke all')),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _isBusy = true);
    try {
      await ShphAuthApi.instance.revokeAllSessions();
      _loadSessions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All other sessions revoked')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Revoke-all failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text('Sessions',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        backgroundColor: theme.primaryBackground,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _ErrorView(message: _errorMessage!, onRetry: _loadSessions)
              : RefreshIndicator(
                  onRefresh: _loadSessions,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                    children: [
                      if (_sessions.isEmpty)
                        _EmptyCard(label: 'No active sessions found')
                      else
                        ..._sessions.map((s) => _SessionRow(
                              session: s,
                              isBusy: _isBusy,
                              onRevoke: () => _revoke(s),
                            )),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _isBusy ? null : _revokeAll,
                        icon: const Icon(Icons.logout),
                        label: const Text('Revoke all other sessions'),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({
    required this.session,
    required this.isBusy,
    required this.onRevoke,
  });

  final ShphSession session;
  final bool isBusy;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            session.isCurrent ? Icons.phone_iphone : Icons.devices,
            color: session.isCurrent ? theme.primary : theme.secondaryText,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.deviceInfo ?? 'Session ${session.sessionId}',
                  style: theme.bodyMedium.override(fontWeight: FontWeight.w700),
                ),
                if (session.ipAddress != null)
                  Text(session.ipAddress!,
                      style:
                          theme.bodySmall.override(color: theme.secondaryText)),
                if (session.lastActivity != null)
                  Text('Last active: ${session.lastActivity}',
                      style:
                          theme.bodySmall.override(color: theme.secondaryText)),
              ],
            ),
          ),
          if (session.isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('This device',
                  style: theme.bodySmall.override(
                    color: theme.primary,
                    fontWeight: FontWeight.w700,
                  )),
            )
          else
            IconButton(
              tooltip: 'Revoke',
              onPressed: isBusy ? null : onRevoke,
              icon: Icon(Icons.logout, color: Colors.red.shade700, size: 20),
            ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          textAlign: TextAlign.center,
          style: theme.bodyMedium.override(color: theme.secondaryText)),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.error),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: theme.bodyMedium.override(color: theme.secondaryText)),
            const SizedBox(height: 20),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
