import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/theme/app_theme.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  static String routeName = 'NotFound';
  static String routePath = '/not-found';

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 80,
                  color: theme.secondaryText,
                ),
                const SizedBox(height: 24),
                Text(
                  '404',
                  style: theme.displaySmall.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Page Not Found',
                  style: theme.titleLarge.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The page you are looking for doesn\'t exist or has been moved.',
                  textAlign: TextAlign.center,
                  style: theme.bodyMedium.override(
                    color: theme.secondaryText,
                  ),
                ),
                const SizedBox(height: 32),
                FFButtonWidget(
                  onPressed: () => context.go('/'),
                  text: 'Go Home',
                  options: FFButtonOptions(
                    width: 200,
                    height: 48,
                    color: theme.primary,
                    textStyle: theme.titleSmall.override(
                      color: Colors.white,
                      font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
