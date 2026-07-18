import 'package:flutter/material.dart';

import '/theme/app_theme.dart';

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  static String routeName = 'ThemeSettings';
  static String routePath = '/theme-settings';

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  ThemeMode _currentMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _currentMode = AppTheme.themeMode;
  }

  Future<void> _setMode(ThemeMode mode) async {
    AppTheme.saveThemeMode(mode);
    setState(() => _currentMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Appearance'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Theme',
              style: theme.titleMedium.override(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Choose how Serbisyo Hub looks to you.',
              style: theme.bodyMedium.override(color: theme.secondaryText)),
          const SizedBox(height: 24),
          _buildOption(
            theme,
            icon: Icons.light_mode,
            title: 'Light',
            subtitle: 'Always use light theme',
            selected: _currentMode == ThemeMode.light,
            onTap: () => _setMode(ThemeMode.light),
          ),
          const SizedBox(height: 12),
          _buildOption(
            theme,
            icon: Icons.dark_mode,
            title: 'Dark',
            subtitle: 'Always use dark theme',
            selected: _currentMode == ThemeMode.dark,
            onTap: () => _setMode(ThemeMode.dark),
          ),
          const SizedBox(height: 12),
          _buildOption(
            theme,
            icon: Icons.brightness_auto,
            title: 'System',
            subtitle: 'Follow system setting',
            selected: _currentMode == ThemeMode.system,
            onTap: () => _setMode(ThemeMode.system),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    AppThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? theme.primary : theme.alternate,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? theme.primary : theme.secondaryText),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: theme.bodyLarge
                          .override(fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style:
                          theme.bodySmall.override(color: theme.secondaryText)),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: theme.primary, size: 24),
          ],
        ),
      ),
    );
  }
}
