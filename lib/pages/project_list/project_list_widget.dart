import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import 'project_list_model.dart';

export 'project_list_model.dart';

class ProjectListWidget extends StatefulWidget {
  const ProjectListWidget({super.key});

  static String routeName = 'ProjectList';
  static String routePath = '/projects';

  @override
  State<ProjectListWidget> createState() => _ProjectListWidgetState();
}

class _ProjectListWidgetState extends State<ProjectListWidget> {
  late ProjectListModel _model;

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
        'draft' => 'Draft',
        'quoted' => 'Quoted',
        'matching' => 'Matching',
        'committed' => 'Committed',
        'cancelled' => 'Cancelled',
        'expired' => 'Expired',
        _ => status,
      };

  @override
  void initState() {
    super.initState();
    _model = createModel(context, ProjectListModel.new);
    _model.loadProjects().then((_) => safeSetState(() {}));
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
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        title: Text('Projects', style: theme.titleMedium),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/projects/create'),
          ),
        ],
      ),
      body: _model.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _model.projects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.work_outline,
                          size: 64, color: theme.secondaryText),
                      const SizedBox(height: 16),
                      Text('No projects yet', style: theme.bodyMedium),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.push('/projects/create'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                        ),
                        child: const Text('Create a Project'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      _model.loadProjects().then((_) => safeSetState(() {})),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _model.projects.length,
                    itemBuilder: (context, index) {
                      final project = _model.projects[index];
                      final status = project['status']?.toString() ?? 'draft';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: theme.secondaryBackground,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                              color: theme.border, width: 0.5),
                        ),
                        child: InkWell(
                          onTap: () => context.push(
                            '/projects/${project['id']}',
                          ),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        project['title']?.toString() ??
                                            '',
                                        style: theme.titleSmall,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        project['category_name']
                                                ?.toString() ??
                                            '',
                                        style: theme.bodySmall?.copyWith(
                                            color:
                                                theme.secondaryText),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _statusColor(status, theme)
                                        .withValues(alpha: 0.15),
                                    borderRadius:
                                        BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _statusLabel(status),
                                    style: theme.bodySmall?.copyWith(
                                      color:
                                          _statusColor(status, theme),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
