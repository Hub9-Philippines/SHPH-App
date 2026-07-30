import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
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
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        title: Text('Appearance', style: theme.titleMedium),
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
                Text('Theme', style: theme.titleSmall),
                const SizedBox(height: 12),
                ...ThemeMode.values.map((mode) {
                  final selected = _model.current == mode;
                  final title = switch (mode) {
                    ThemeMode.light => 'Light',
                    ThemeMode.dark => 'Dark',
                    ThemeMode.system => 'System Default',
                  };
                  final icon = switch (mode) {
                    ThemeMode.light => Icons.light_mode,
                    ThemeMode.dark => Icons.dark_mode,
                    ThemeMode.system => Icons.settings_brightness,
                  };
                  final subtitle = switch (mode) {
                    ThemeMode.light => 'Always use light mode',
                    ThemeMode.dark => 'Always use dark mode',
                    ThemeMode.system =>
                      'Follow device settings',
                  };
                  return RadioListTile<ThemeMode>(
                    value: mode,
                    groupValue: _model.current,
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _model.setTheme(v, context));
                      }
                    },
                    activeColor: theme.primary,
                    secondary: Icon(icon,
                        color: selected
                            ? theme.primary
                            : theme.secondaryText),
                    title:
                        Text(title, style: theme.bodyMedium),
                    subtitle: Text(subtitle,
                        style: theme.bodySmall?.copyWith(
                            color: theme.secondaryText)),
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
