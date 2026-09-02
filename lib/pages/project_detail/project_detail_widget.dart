import 'package:flutter/material.dart';

import '/components/cupertino_ui/app_activity_indicator.dart';
import '/components/cupertino_ui/app_button.dart';
import '/components/cupertino_ui/cupertino_page_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';
import 'project_detail_model.dart';

export 'project_detail_model.dart';

class ProjectDetailWidget extends StatefulWidget {
  const ProjectDetailWidget({super.key, required this.projectId});

  final String projectId;

  static String routeName = 'ProjectDetail';
  static String routePath = '/projects/:projectId';

  @override
  State<ProjectDetailWidget> createState() => _ProjectDetailWidgetState();
}

class _ProjectDetailWidgetState extends State<ProjectDetailWidget> {
  late ProjectDetailModel _model;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  Color _statusColor(String status, AppThemeData theme) => switch (status) {
        'draft' => theme.textTertiary,
        'quoted' => theme.primary,
        'matching' => theme.warning,
        'committed' => theme.success,
        'cancelled' => theme.error,
        'expired' => theme.textTertiary,
        _ => theme.secondaryText,
      };

  String _statusLabel(String status) => switch (status) {
        'draft' => _l10n.pjStatusDraft,
        'quoted' => _l10n.pjStatusQuoted,
        'matching' => _l10n.pjStatusMatching,
        'committed' => _l10n.pjStatusCommitted,
        'cancelled' => _l10n.pjStatusCancelled,
        'expired' => _l10n.pjStatusExpired,
        _ => status,
      };

  @override
  void initState() {
    super.initState();
    _model = createModel(context, ProjectDetailModel.new);
    _model.loadProject(widget.projectId).then((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final project = _model.project;
    final status = project?['status']?.toString() ?? 'draft';
    final roleLines = (project?['role_lines'] as List?) ?? [];

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(44),
        child: CupertinoPageHeader(
          backgroundColor: theme.primaryBackground,
          title: _l10n.pdTitle,
          titleStyle: theme.titleMedium,
        ),
      ),
      body: _model.isLoading
          ? const Center(child: AppActivityIndicator())
          : project == null
              ? Center(
                  child: Text(_l10n.pdProjectNotFound,
                      style: theme.bodyMedium))
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  project['title']?.toString() ?? '',
                                  style: theme.titleLarge,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _statusColor(status, theme)
                                      .withValues(alpha: 0.15),
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _statusLabel(status),
                                  style: theme.bodySmall?.copyWith(
                                    color: _statusColor(status, theme),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            project['category_name']?.toString() ??
                                '',
                            style: theme.bodySmall?.copyWith(
                                color: theme.secondaryText),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            project['description']?.toString() ?? '',
                            style: theme.bodyMedium,
                          ),
                          const Divider(height: 24),
                          if (project['estimated_budget_min'] !=
                                  null ||
                              project['estimated_budget_max'] !=
                                  null)
                            _infoRow(
                              theme,
                              Icons.attach_money,
                              _l10n.pdBudget(
                                project['estimated_budget_min'] ?? '?',
                                project['estimated_budget_max'] ?? '?',
                              ),
                            ),
                          if (project['estimated_headcount'] != null)
                            _infoRow(
                              theme,
                              Icons.people,
                              _l10n.pdHeadcount(project['estimated_headcount']),
                            ),
                          if (project['expires_at'] != null)
                            _infoRow(
                              theme,
                              Icons.schedule,
                              _l10n.pdExpires(project['expires_at']),
                            ),
                        ],
                      ),
                    ),
                    if (roleLines.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(_l10n.pdRoleLines,
                          style: theme.titleSmall),
                      const SizedBox(height: 8),
                      ...roleLines.map((rl) {
                        final prospects =
                            (rl['prospects'] as List?) ?? [];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: theme.secondaryBackground,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                            side: BorderSide(
                                color: theme.border, width: 0.5),
                          ),
                          child: ExpansionTile(
                            title: Text(
                              rl['role_label']?.toString() ?? '',
                              style: theme.bodyMedium
                                  ?.copyWith(
                                      fontWeight:
                                          FontWeight.w600),
                            ),
                            subtitle: Text(
                              '${rl['headcount']} x \$${rl['est_rate_min'] ?? '?'}-\$${rl['est_rate_max'] ?? '?'}',
                              style: theme.bodySmall,
                            ),
                            children: prospects.isEmpty
                                ? [
                                    Padding(
                                      padding:
                                          const EdgeInsets.all(16),
                                      child: Text(
                                        _l10n.pdNoProspects,
                                        style: theme.bodySmall
                                            ?.copyWith(
                                                color: theme
                                                    .secondaryText),
                                      ),
                                    ),
                                  ]
                                : prospects.map<Widget>((p) {
                                    return ListTile(
                                      key: ValueKey(
                                          p['provider_id']?.toString()),
                                      leading: CircleAvatar(
                                        backgroundColor: theme
                                            .primary
                                            .withValues(alpha: 0.1),
                                        child: Icon(Icons.person,
                                            color: theme.primary),
                                      ),
                                      title: Text(
                                        p['provider_name']
                                                ?.toString() ??
                                            '',
                                        style: theme.bodyMedium,
                                      ),
                                      subtitle: Text(
                                        _l10n.pdScore(p['score'] ?? '?'),
                                        style: theme.bodySmall,
                                      ),
                                      trailing: Container(
                                        padding:
                                            const EdgeInsets
                                                .symmetric(
                                                horizontal: 6,
                                                vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _prospectColor(
                                                  p['status']
                                                      ?.toString(),
                                                  theme)
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          p['status']
                                                  ?.toString() ??
                                              '',
                                          style: theme
                                              .bodySmall
                                              ?.copyWith(
                                            color: _prospectColor(
                                                p['status']
                                                    ?.toString(),
                                                theme),
                                            fontSize: 10,
                                            fontWeight:
                                                FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                          ),
                        );
                      }),
                    ],
                    const SizedBox(height: 24),
                    if (status == 'draft') ...[
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          onPressed: () async {
                            final result =
                                await _model.quoteProject();
                            if (mounted) {
                              safeSetState(() {});
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                    content: Text(
                                        result != null
                                            ? _l10n.pdQuoteGenerated
                                            : _l10n.pdFailed)),
                              );
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.description,
                                  size: 18, color: Colors.white),
                              SizedBox(width: 8),
                              Text(_l10n.pdGenerateQuote),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (status != 'committed' &&
                        status != 'cancelled') ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          variant: AppButtonVariant.text,
                          foregroundColor: theme.error,
                          onPressed: () async {
                            final ok =
                                await _model.cancelProject();
                            if (mounted) {
                              safeSetState(() {});
                              if (ok) context.pop();
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.cancel,
                                  size: 18, color: theme.error),
                              const SizedBox(width: 8),
                              Text(_l10n.pdCancelProject),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
    );
  }

  Color _prospectColor(String? status, AppThemeData theme) =>
      switch (status) {
        'pending' => theme.textTertiary,
        'shortlisted' => theme.primary,
        'invited' => theme.warning,
        'accepted' => theme.success,
        'declined' => theme.error,
        _ => theme.secondaryText,
      };

  Widget _infoRow(AppThemeData theme, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.secondaryText),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: theme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
