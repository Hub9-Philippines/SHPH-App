import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/theme/app_theme.dart';

/// Wraps a subtree with a [CupertinoTheme] tinted with the app's brand tokens
/// so Cupertino widgets (buttons, fields, navigation bars) pick up the royal
/// blue primary color and Plus Jakarta Sans font in both light and dark mode.
///
/// Applied once at the `MaterialApp.builder` level; `CupertinoTheme.of(context)`
/// anywhere below it reflects the active [ThemeData.brightness].
class CupertinoThemeScope extends StatelessWidget {
  const CupertinoThemeScope({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = AppTheme.of(context);
    return CupertinoTheme(
      data: CupertinoThemeData(
        brightness: theme.brightness,
        primaryColor: data.primary,
        scaffoldBackgroundColor: data.primaryBackground,
        barBackgroundColor: data.primaryBackground,
        textTheme: CupertinoTextThemeData(
          primaryColor: data.primary,
          textStyle: GoogleFonts.plusJakartaSans(
            color: data.primaryText,
            fontSize: 16,
          ),
        ),
      ),
      child: child,
    );
  }
}