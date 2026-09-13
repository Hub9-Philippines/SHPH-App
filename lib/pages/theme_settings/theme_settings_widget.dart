import 'package:flutter/material.dart';

import '/components/cupertino_ui/cupertino_page_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';
import 'theme_settings_model.dart';

export 'theme_settings_model.dart';

class ThemeSettingsWidget extends StatefulWidget {
  const ThemeSettingsWidget({super.key});

  static String routeName = 'ThemeSettings';
  static String routePath = '/theme-settings';

  @override
  State<ThemeSettingsWidget> createState() => _ThemeSettingsWidgetState();
}

class _ThemeSettingsWidgetState extends State<ThemeSettingsWidget> {
  late ThemeSettingsModel _model;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, ThemeSettingsModel.new);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CupertinoPageHeader(
          title: _l10n.thTitle,
          backgroundColor: theme.primaryBackground,
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
                Text(_l10n.thTheme, style: theme.titleSmall),
                const SizedBox(height: 12),
                ...ThemeMode.values.map((mode) {
                  final selected = _model.current == mode;
                  final title = switch (mode) {
                    ThemeMode.light => _l10n.thLight,
                    ThemeMode.dark => _l10n.thDark,
                    ThemeMode.system => _l10n.thSystemDefault,
                  };
                  final icon = switch (mode) {
                    ThemeMode.light => Icons.light_mode,
                    ThemeMode.dark => Icons.dark_mode,
                    ThemeMode.system => Icons.settings_brightness,
                  };
                  final subtitle = switch (mode) {
                    ThemeMode.light => _l10n.thLightSubtitle,
                    ThemeMode.dark => _l10n.thDarkSubtitle,
                    ThemeMode.system =>
                      _l10n.thSystemSubtitle,
                  };
                  return RadioGroup<ThemeMode>(
                    groupValue: _model.current,
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _model.setTheme(v, context));
                      }
                    },
                    child: RadioListTile<ThemeMode>.adaptive(
                      value: mode,
                      activeColor: theme.primary,
                      secondary: Icon(
                        icon,
                        color: selected ? theme.primary : theme.secondaryText,
                      ),
                      title: Text(
                        title, 
                        style: theme.bodyMedium,
                      ),
                      subtitle: Text(
                        subtitle,
                        style: theme.bodySmall.copyWith(
                          color: theme.secondaryText,
                        ),
                      ),
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
