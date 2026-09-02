import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '/theme/app_theme.dart';

/// Cupertino-styled on/off switch tinted with the brand primary color.
class AppSwitch extends StatelessWidget {
  const AppSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final data = AppTheme.of(context);
    return CupertinoSwitch(
      value: value,
      activeColor: activeColor ?? data.primary,
      onChanged: enabled ? onChanged : null,
    );
  }
}

/// A full-width tappable row (icon + title + optional subtitle) with an
/// [AppSwitch] trailing, replacing `SwitchListTile` call sites.
class AppSwitchRow extends StatelessWidget {
  const AppSwitchRow({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.value = false,
    this.onChanged,
    this.activeColor,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final data = AppTheme.of(context);
    final row = CupertinoListTile(
      leading: icon == null
          ? null
          : Icon(icon, size: 22, color: data.primaryBrandText),
      title: Text(title, style: data.bodyLarge),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: data.bodySmall),
      trailing: trailing ??
          AppSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor,
          ),
      onTap: onTap,
      backgroundColor: data.primaryBackground,
    );
    return Directionality(textDirection: TextDirection.ltr, child: row);
  }
}