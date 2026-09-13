import 'package:flutter/material.dart';

import '/components/cupertino_ui/app_activity_indicator.dart';
import '/components/cupertino_ui/app_button.dart';
import '/components/cupertino_ui/cupertino_page_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';
import 'disputes_model.dart';

export 'disputes_model.dart';

class DisputesWidget extends StatefulWidget {
  const DisputesWidget({super.key});

  static String routeName = 'Disputes';
  static String routePath = '/disputes';

  @override
  State<DisputesWidget> createState() => _DisputesWidgetState();
}

class _DisputesWidgetState extends State<DisputesWidget> {
  late DisputesModel _model;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, DisputesModel.new);
    _model.loadDisputes().then((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Color _statusColor(String status, AppThemeData theme) => switch (status) {
        'open' => theme.warning,
        'under_review' => theme.primary,
        'resolved' => theme.success,
        'rejected' => theme.error,
        'closed' => theme.textTertiary,
        'escalated' => theme.error,
        _ => theme.secondaryText,
      };

  String _statusLabel(String status) => switch (status) {
        'open' => _l10n.dpStatusOpen,
        'under_review' => _l10n.dpStatusReview,
        'resolved' => _l10n.dpStatusResolved,
        'rejected' => _l10n.dpStatusRejected,
        'closed' => _l10n.dpStatusClosed,
        'escalated' => _l10n.dpStatusEscalated,
        _ => status,
      };

  IconData _statusIcon(String status) => switch (status) {
        'open' => Icons.flag,
        'under_review' => Icons.rate_review,
        'resolved' => Icons.check_circle,
        'rejected' => Icons.cancel,
        'closed' => Icons.lock,
        'escalated' => Icons.warning,
        _ => Icons.help,
      };

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CupertinoPageHeader(
          backgroundColor: theme.primaryBackground,
          title: _l10n.dpTitle,
          titleStyle: theme.titleMedium,
        ),
      ),
      body: _model.isLoading
          ? const Center(child: AppActivityIndicator())
          : _model.disputes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_user,
                          size: 64, color: theme.secondaryText),
                      const SizedBox(height: 16),
                      Text(_l10n.dpNoDisputes, style: theme.bodyMedium),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      _model.loadDisputes().then((_) => safeSetState(() {})),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _model.disputes.length,
                    itemBuilder: (context, index) {
                      final dispute = _model.disputes[index];
                      final status =
                          dispute['status']?.toString() ?? 'open';
                      final statusColor = _statusColor(status, theme);
                      final reason =
                          dispute['reason']?.toString() ?? '';
                      final description =
                          dispute['description']?.toString() ?? '';
                      final evidence =
                          dispute['evidence']?.toString();
                      final bookingId =
                          dispute['booking']?.toString() ?? '';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: theme.secondaryBackground,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                              color: theme.border, width: 0.5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor
                                          .withValues(alpha: 0.15),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(_statusIcon(status),
                                            size: 14,
                                            color: statusColor),
                                        const SizedBox(width: 4),
                                        Text(
                                          _statusLabel(status),
                                          style: theme.bodySmall.copyWith(
                                            color: statusColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (bookingId.isNotEmpty) ...[
                                    const Spacer(),
                                    AppButton(
                                      onPressed: () {},
                                      variant: AppButtonVariant.text,
                                      child: Text(_l10n.dpViewBooking),
                                    ),
                                  ],
                                ],
                              ),
                              if (reason.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  reason.replaceAll('_', ' '),
                                  style: theme.titleSmall,
                                ),
                              ],
                              if (description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(description,
                                    style: theme.bodyMedium),
                              ],
                              if (evidence != null &&
                                  evidence.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(8),
                                  child: Image.network(
                                    evidence,
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) => const SizedBox(),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: theme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
