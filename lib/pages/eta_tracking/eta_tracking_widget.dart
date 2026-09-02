import 'package:flutter/material.dart';

import '/components/cupertino_ui/app_activity_indicator.dart';
import '/components/cupertino_ui/app_button.dart';
import '/components/cupertino_ui/cupertino_page_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';
import 'eta_tracking_model.dart';

export 'eta_tracking_model.dart';

class EtaTrackingWidget extends StatefulWidget {
  const EtaTrackingWidget({super.key, required this.token});

  final String token;

  static String routeName = 'EtaTracking';
  static String routePath = '/track/:token';

  @override
  State<EtaTrackingWidget> createState() => _EtaTrackingWidgetState();
}

class _EtaTrackingWidgetState extends State<EtaTrackingWidget> {
  late EtaTrackingModel _model;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, EtaTrackingModel.new);
    _model.loadTracking(widget.token).then((_) => safeSetState(() {}));
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
          backgroundColor: theme.primaryBackground,
          title: _l10n.etTitle,
          titleStyle: theme.titleMedium,
        ),
      ),
      body: _model.isLoading
          ? const Center(child: AppActivityIndicator())
          : _model.isExpired
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer_off,
                            size: 64, color: theme.secondaryText),
                        const SizedBox(height: 16),
                        Text(_l10n.etLinkExpired,
                            style: theme.titleLarge),
                        const SizedBox(height: 8),
                        Text(
                          _l10n.etLinkInvalid,
                          style: theme.bodyMedium.copyWith(
                              color: theme.secondaryText),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ))
              : _model.trackingData == null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline,
                              size: 64, color: theme.error),
                          const SizedBox(height: 16),
                          Text(_l10n.etSomethingWrong,
                              style: theme.titleLarge),
                          const SizedBox(height: 8),
                          AppButton(
                            onPressed: () {
                              _model.loadTracking(widget.token)
                                  .then((_) => safeSetState(() {}));
                            },
                            backgroundColor: theme.primary,
                            child: Text(_l10n.etRetry),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.secondaryBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: theme.border, width: 0.5),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.construction,
                                      color: theme.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _model.trackingData![
                                                  'service_title']
                                              ?.toString() ??
                                          '',
                                      style: theme.titleSmall,
                                    ),
                                  ),
                                ],
                              ),
                              if (_model.trackingData!['category'] !=
                                  null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _model.trackingData!['category']
                                      .toString(),
                                   style: theme.bodySmall.copyWith(
                                       color: theme.secondaryText),
                                ),
                              ],
                              if (_model.trackingData![
                                      'provider_first_name'] !=
                                  null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.person,
                                        size: 16,
                                        color: theme.secondaryText),
                                    const SizedBox(width: 4),
                                    Text(
                                      _model.trackingData![
                                              'provider_first_name']
                                          .toString(),
                                      style: theme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: theme.surfaceAlt,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.map,
                                    size: 48,
                                    color: theme.secondaryText),
                                const SizedBox(height: 8),
                                Text(_l10n.etMapView,
                                    style: theme.bodyMedium.copyWith(
                                        color: theme.secondaryText)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
}
