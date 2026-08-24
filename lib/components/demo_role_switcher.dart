import 'package:flutter/material.dart';

import '/demo/demo_data.dart';
import '/demo/demo_session.dart';
import '/services/auth_service.dart';
import '/services/error_handler.dart';
import '/theme/app_theme.dart';

class DemoRoleSwitcher extends StatefulWidget {
  const DemoRoleSwitcher({super.key});

  @override
  State<DemoRoleSwitcher> createState() => _DemoRoleSwitcherState();
}

class _DemoRoleSwitcherState extends State<DemoRoleSwitcher> {
  bool _expanded = false;

  void _select(String role) {
    setState(() => _expanded = false);
    if ((AuthService.instance.isProvider ? 'provider' : 'client') == role) {
      return;
    }
    DemoSession.switchRole(role);
    ErrorHandler.scaffoldMessengerKey?.currentState?.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.of(context).secondaryBackground,
        content: Text(
          'Previewing as ${role == 'provider' ? 'Provider (Maria Santos)' : 'Client (Juan Dela Cruz)'}',
          style: AppTheme.of(context).bodyMedium,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return ListenableBuilder(
      listenable: AuthService.instance,
      builder: (context, _) {
        final isProvider = AuthService.instance.isProvider;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_expanded)
              Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 0, 0, 8),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryText.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _roleTile(context, 'client', 'Client', 'Juan Dela Cruz',
                          !isProvider),
                      _roleTile(context, 'provider', 'Provider',
                          'Maria Santos', isProvider),
                    ],
                  ),
                ),
              ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 0, 0, 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isProvider ? Icons.handyman : Icons.person_outline,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'DEMO · ${isProvider ? 'Provider' : 'Client'}',
                        style: theme.labelSmall.override(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _roleTile(BuildContext context, String role, String title,
      String subtitle, bool active) {
    final theme = AppTheme.of(context);
    return InkWell(
      onTap: () => _select(role),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Icon(
              active ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16,
              color: active ? theme.primary : theme.secondaryText,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.bodyMedium),
                Text(subtitle, style: theme.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
