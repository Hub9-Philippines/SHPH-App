import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import 'client_ondemand_jobs_model.dart';

export 'client_ondemand_jobs_model.dart';

class ClientOnDemandJobsWidget extends StatefulWidget {
  const ClientOnDemandJobsWidget({super.key});

  static String routeName = 'ClientOnDemandJobs';
  static String routePath = '/client-on-demand-jobs';

  @override
  State<ClientOnDemandJobsWidget> createState() =>
      _ClientOnDemandJobsWidgetState();
}

class _ClientOnDemandJobsWidgetState
    extends State<ClientOnDemandJobsWidget> {
  late ClientOnDemandJobsModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, ClientOnDemandJobsModel.new);
    _model.loadJobs().then((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Color _statusColor(String status, AppThemeData theme) => switch (status) {
        'searching' => theme.warning,
        'accepted' => theme.success,
        'expired' => theme.textTertiary,
        'cancelled' => theme.error,
        _ => theme.secondaryText,
      };

  String _statusLabel(String status) => switch (status) {
        'searching' => 'Searching',
        'accepted' => 'Accepted',
        'expired' => 'Expired',
        'cancelled' => 'Cancelled',
        _ => status,
      };

  IconData _statusIcon(String status) => switch (status) {
        'searching' => Icons.hourglass_top,
        'accepted' => Icons.check_circle,
        'expired' => Icons.timer_off,
        'cancelled' => Icons.cancel,
        _ => Icons.help,
      };

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        title: Text('My On-Demand Jobs', style: theme.titleMedium),
        centerTitle: true,
        elevation: 0,
      ),
      body: _model.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _model.jobs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.work_off,
                          size: 64, color: theme.secondaryText),
                      const SizedBox(height: 16),
                      Text('No on-demand jobs yet',
                          style: theme.bodyMedium),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      _model.loadJobs().then((_) => safeSetState(() {})),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _model.jobs.length,
                    itemBuilder: (context, index) {
                      final job = _model.jobs[index];
                      final status =
                          job['status']?.toString() ?? 'searching';
                      final statusColor = _statusColor(status, theme);
                      final feeMin =
                          (job['estimated_fee_min'] as num?)?.toDouble();
                      final feeMax =
                          (job['estimated_fee_max'] as num?)?.toDouble();
                      final provider =
                          job['selected_provider'] as Map<String, dynamic>?;
                      final bidCount = job['bid_count'] as int? ?? 0;

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
                                      color: statusColor.withValues(alpha: 0.15),
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
                                          style: theme.bodySmall?.copyWith(
                                            color: statusColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  if (bidCount > 0)
                                    Text(
                                      '$bidCount bid${bidCount == 1 ? '' : 's'}',
                                      style: theme.bodySmall?.copyWith(
                                          color: theme.secondaryText),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                job['category_name']?.toString() ??
                                    'General',
                                style: theme.titleSmall,
                              ),
                              if (job['description'] != null &&
                                  (job['description']
                                          .toString()
                                          .isNotEmpty)) ...[
                                const SizedBox(height: 4),
                                Text(
                                  job['description'].toString(),
                                  style: theme.bodyMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              if (feeMin != null || feeMax != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Fee: ${feeMin != null ? '\$${feeMin.toStringAsFixed(0)}' : ''}${feeMin != null && feeMax != null ? ' - ' : ''}${feeMax != null ? '\$${feeMax.toStringAsFixed(0)}' : ''}',
                                  style: theme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                              if (provider != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundImage: provider[
                                                      'photo_url']
                                                  ?.toString() !=
                                              null
                                          ? NetworkImage(provider[
                                                  'photo_url']
                                              .toString())
                                          : null,
                                      child: provider['photo_url']
                                                  ?.toString() ==
                                              null
                                          ? Icon(Icons.person,
                                              size: 14,
                                              color: theme
                                                  .secondaryText)
                                          : null,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      provider['display_name']
                                              ?.toString() ??
                                          'Provider',
                                      style: theme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ],
                              if (status == 'searching') ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Resume'),
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
    );
  }
}
