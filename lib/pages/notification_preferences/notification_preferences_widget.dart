import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';
import 'notification_preferences_model.dart';

export 'notification_preferences_model.dart';

class NotificationPreferencesWidget extends StatefulWidget {
  const NotificationPreferencesWidget({super.key});

  static String routeName = 'NotificationPreferences';
  static String routePath = '/notification-preferences';

  @override
  State<NotificationPreferencesWidget> createState() =>
      _NotificationPreferencesWidgetState();
}

class _NotificationPreferencesWidgetState
    extends State<NotificationPreferencesWidget> {
  late NotificationPreferencesModel _model;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  static const _categories = [
    ('bookings', 'Bookings', Icons.calendar_today),
    ('messages', 'Messages', Icons.message),
    ('payments', 'Payments', Icons.payment),
    ('recommendations', 'Recommendations', Icons.recommend),
    ('promotions', 'Promotions', Icons.discount),
    ('system', 'System', Icons.settings),
    ('reviews', 'Reviews', Icons.star),
    ('earnings', 'Earnings', Icons.trending_up),
    ('disputes', 'Disputes', Icons.gavel),
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, NotificationPreferencesModel.new);
    _model.loadPreferences().then((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _toggleCategory(String key, bool value) async {
    setState(() => _model.preferences['${key}_enabled'] = value);
    await _model.updatePreferences({});
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        title: Text(_l10n.npTitle, style: theme.titleMedium),
        centerTitle: true,
        elevation: 0,
      ),
      body: _model.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
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
                      Row(
                        children: [
                          Icon(Icons.notifications,
                              color: theme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(_l10n.npPush,
                              style: theme.titleSmall),
                          const Spacer(),
                          Switch(
                            value: _model.preferences['push_enabled'] as bool? ??
                                true,
                            onChanged: (v) {
                              setState(() =>
                                  _model.preferences['push_enabled'] = v);
                              _model.updatePreferences({
                                'push_enabled': v,
                              });
                            },
                            activeColor: theme.primary,
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      ..._categories.map((cat) {
                        final key = cat.$1;
                        final label = cat.$2;
                        final icon = cat.$3;
                        final prefKey = '${key}_enabled';
                        final value = _model.preferences[prefKey] as bool? ??
                            true;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(icon,
                                  size: 18, color: theme.secondaryText),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(label,
                                    style: theme.bodyMedium),
                              ),
                              Switch(
                                value: value,
                                onChanged: _model.isSaving
                                    ? null
                                    : (v) {
                                        setState(() =>
                                            _model.preferences[prefKey] =
                                                v);
                                        _model.updatePreferences({});
                                      },
                                activeColor: theme.primary,
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
