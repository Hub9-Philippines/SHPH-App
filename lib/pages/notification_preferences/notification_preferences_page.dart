import 'package:flutter/material.dart';

import '/api/resources/users_api.dart';
import '/theme/app_theme.dart';

/// Configure notification preferences.
///
/// Mirrors `shph-app/src/views/profile/NotificationPreferencesPage.vue`. Backed
/// by `ShphUsersApi.getNotificationPreferences()` /
/// `updateNotificationPreferences()` → PATCH `/api/users/notification-preferences/`.
class NotificationPreferencesPage extends StatefulWidget {
  const NotificationPreferencesPage({super.key});

  static String routeName = 'NotificationPreferences';
  static String routePath = '/notification-preferences';

  @override
  State<NotificationPreferencesPage> createState() =>
      _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState
    extends State<NotificationPreferencesPage> {
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  // Master + category toggles. Defaults are conservative (all on).
  bool _pushEnabled = true;
  bool _bookingUpdates = true;
  bool _chatMessages = true;
  bool _promotions = false;
  bool _doNotDisturb = false;
  String _dndStart = '22:00';
  String _dndEnd = '07:00';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final prefs = await ShphUsersApi.instance.getNotificationPreferences();
      if (mounted) {
        setState(() {
          _pushEnabled = prefs['push_notifications_enabled'] as bool? ?? true;
          _bookingUpdates = prefs['booking_updates_enabled'] as bool? ?? true;
          _chatMessages = prefs['chat_messages_enabled'] as bool? ?? true;
          _promotions = prefs['promotions_enabled'] as bool? ?? false;
          _doNotDisturb = prefs['do_not_disturb'] as bool? ?? false;
          _dndStart = prefs['dnd_start'] as String? ?? '22:00';
          _dndEnd = prefs['dnd_end'] as String? ?? '07:00';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load preferences: $e';
        });
      }
    }
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    try {
      await ShphUsersApi.instance.updateNotificationPreferences({
        'push_notifications_enabled': _pushEnabled,
        'booking_updates_enabled': _bookingUpdates,
        'chat_messages_enabled': _chatMessages,
        'promotions_enabled': _promotions,
        'do_not_disturb': _doNotDisturb,
        'dnd_start': _dndStart,
        'dnd_end': _dndEnd,
      });
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = 'Save failed: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text('Notification Preferences',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        backgroundColor: theme.primaryBackground,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _ErrorView(message: _errorMessage!, onRetry: _loadPreferences)
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  children: [
                    SwitchListTile(
                      title: Text('Push notifications',
                          style: theme.bodyMedium
                              .override(fontWeight: FontWeight.w700)),
                      subtitle: Text('Master toggle for all push notifications',
                          style: theme.bodySmall
                              .override(color: theme.secondaryText)),
                      value: _pushEnabled,
                      onChanged: (v) => setState(() => _pushEnabled = v),
                    ),
                    const Divider(),
                    _CategorySwitch(
                      label: 'Booking updates',
                      description: 'Acceptance, rejection, status changes',
                      value: _bookingUpdates,
                      onChanged: _pushEnabled
                          ? (v) => setState(() => _bookingUpdates = v)
                          : null,
                    ),
                    _CategorySwitch(
                      label: 'Chat messages',
                      description: 'New messages and call invitations',
                      value: _chatMessages,
                      onChanged: _pushEnabled
                          ? (v) => setState(() => _chatMessages = v)
                          : null,
                    ),
                    _CategorySwitch(
                      label: 'Promotions',
                      description: 'Offers, announcements, recommendations',
                      value: _promotions,
                      onChanged: _pushEnabled
                          ? (v) => setState(() => _promotions = v)
                          : null,
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: Text('Do not disturb',
                          style: theme.bodyMedium
                              .override(fontWeight: FontWeight.w700)),
                      subtitle: Text(
                          'Silence notifications between $_dndStart and $_dndEnd',
                          style: theme.bodySmall
                              .override(color: theme.secondaryText)),
                      value: _doNotDisturb,
                      onChanged: _pushEnabled
                          ? (v) => setState(() => _doNotDisturb = v)
                          : null,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _isSaving ? null : _save,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(_isSaving ? 'Saving…' : 'Save Preferences'),
                    ),
                  ],
                ),
    );
  }
}

class _CategorySwitch extends StatelessWidget {
  const _CategorySwitch({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return SwitchListTile(
      title: Text(label, style: theme.bodyMedium),
      subtitle: Text(description,
          style: theme.bodySmall.override(color: theme.secondaryText)),
      value: value,
      onChanged: onChanged,
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
