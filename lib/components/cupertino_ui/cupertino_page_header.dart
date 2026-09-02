import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '/theme/app_theme.dart';

/// Cupertino-styled page bar replacing `AppBar` call sites. Centered title,
/// automatic iOS back chevron when a previous route exists, optional leading
/// override and trailing action widgets. Inherits Cupertino navigation-bar
/// safe-area handling (status bar / home indicator).
class CupertinoPageHeader extends StatelessWidget {
  const CupertinoPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.automaticallyImplyLeading = true,
    this.titleStyle,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool automaticallyImplyLeading;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final data = AppTheme.of(context);
    return CupertinoNavigationBar(
      backgroundColor: backgroundColor ?? data.primaryBackground,
      automaticallyImplyLeading: automaticallyImplyLeading && leading == null,
      leading: leading ??
          (automaticallyImplyLeading && Navigator.of(context).canPop()
              ? CupertinoNavigationBarBackButton(
                  onPressed: () => Navigator.of(context).pop(),
                  color: data.primary,
                )
              : null),
      middle: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: titleStyle ??
                data.titleMedium.copyWith(color: data.primaryText),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: data.labelSmall.copyWith(color: data.secondaryText),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      trailing: actions == null
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: actions!,
            ),
    );
  }
}