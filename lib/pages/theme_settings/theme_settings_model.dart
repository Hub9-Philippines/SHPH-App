import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import 'theme_settings_widget.dart' show ThemeSettingsWidget;

class ThemeSettingsModel extends FlutterFlowModel<ThemeSettingsWidget> {
  late ThemeMode _current;

  ThemeMode get current => _current;

  @override
  void initState(BuildContext context) {
    _current = AppTheme.themeMode;
  }

  void setTheme(ThemeMode mode, BuildContext context) {
    _current = mode;
    setDarkModeSetting(context, mode);
  }

  @override
  void dispose() {}
}
