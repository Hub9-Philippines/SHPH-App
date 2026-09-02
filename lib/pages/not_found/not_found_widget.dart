import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';
import 'not_found_model.dart';

export 'not_found_model.dart';

class NotFoundWidget extends StatefulWidget {
  const NotFoundWidget({super.key});

  static String routeName = 'NotFound';
  static String routePath = '/404';

  @override
  State<NotFoundWidget> createState() => _NotFoundWidgetState();
}

class _NotFoundWidgetState extends State<NotFoundWidget> {
  late NotFoundModel _model;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, NotFoundModel.new);
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(Icons.search_off_rounded,
                    color: theme.primary, size: 48),
              ),
              const SizedBox(height: 24),
              Text(_l10n.nfTitle,
                  style: theme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(
                _l10n.nfBody,
                style: theme.bodyMedium?.copyWith(color: theme.secondaryText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home_rounded, size: 18),
                label: Text(_l10n.nfGoHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
