import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/api/models/paginated_response.dart';
import '/api/models/project.dart';
import '/api/resources/projects_api.dart';
import '/index.dart';
import '/theme/app_theme.dart';

/// Lists the current user's Project Demands (SHPH-134).
///
/// Mirrors `shph-app/src/views/services/ProjectListPage.vue`. Backed by
/// `ShphProjectsApi.list()` → POST `/api/projects/list/`.
class ProjectListPage extends StatefulWidget {
  const ProjectListPage({super.key});

  static String routeName = 'ProjectList';
  static String routePath = '/projects';

  @override
  State<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  List<ShphProject> _projects = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final PaginatedResponse<ShphProject> response =
          await ShphProjectsApi.instance.list();
      if (mounted) {
        setState(() {
          _projects = response.results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load projects: $e';
        });
      }
    }
  }

  Future<void> _openCreate() async {
    final created = await context.push<bool>(ProjectCreatePage.routePath);
    if (created == true) {
      _loadProjects();
    }
  }

  Future<void> _openDetail(ShphProject project) async {
    final refreshed = await context.push<bool>(
      '/projects/detail/${project.id}',
    );
    if (refreshed == true) {
      _loadProjects();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text('Projects',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        backgroundColor: theme.primaryBackground,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _ErrorView(message: _errorMessage!, onRetry: _loadProjects)
              : _projects.isEmpty
                  ? _EmptyView(onCreate: _openCreate)
                  : RefreshIndicator(
                      onRefresh: _loadProjects,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                        itemCount: _projects.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) => _ProjectCard(
                            project: _projects[i], onTap: _openDetail),
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.add),
        label: const Text('New Project'),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project, required this.onTap});
  final ShphProject project;
  final void Function(ShphProject) onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Material(
      color: theme.primaryBackground,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onTap(project),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.title,
                      style: theme.titleMedium
                          .override(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _StatusChip(status: project.status),
                ],
              ),
              const SizedBox(height: 6),
              if (project.categoryName != null)
                Text(project.categoryName!,
                    style:
                        theme.bodySmall.override(color: theme.secondaryText)),
              const SizedBox(height: 8),
              Text(
                project.description,
                style: theme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (project.estimatedBudgetMin != null ||
                      project.estimatedBudgetMax != null)
                    _MetaPill(
                      icon: Icons.payments_outlined,
                      label: _budgetRange(project),
                    )
                  else
                    const SizedBox.shrink(),
                  const SizedBox(width: 8),
                  _MetaPill(
                    icon: Icons.group_outlined,
                    label: '${project.estimatedHeadcount} heads',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _budgetRange(ShphProject p) {
    final min = p.estimatedBudgetMin;
    final max = p.estimatedBudgetMax;
    if (min == null && max == null) return 'Budget TBD';
    if (min == null) return 'Up to PHP ${max!.toStringAsFixed(0)}';
    if (max == null) return 'From PHP ${min.toStringAsFixed(0)}';
    return 'PHP ${min.toStringAsFixed(0)}–${max.toStringAsFixed(0)}';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final (label, color) = _style(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: theme.bodySmall.override(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  (String, Color) _style(String status) {
    switch (status) {
      case 'draft':
        return ('Draft', Colors.grey.shade700);
      case 'quoted':
        return ('Quoted', Colors.blue.shade700);
      case 'matching':
        return ('Matching', Colors.orange.shade700);
      case 'committed':
        return ('Committed', Colors.green.shade700);
      case 'cancelled':
        return ('Cancelled', Colors.red.shade700);
      case 'expired':
        return ('Expired', Colors.grey.shade500);
      default:
        return (status, themeFallback);
    }
  }

  Color get themeFallback => Colors.blueGrey;
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.secondaryText),
        const SizedBox(width: 4),
        Text(label,
            style: theme.bodySmall.override(color: theme.secondaryText)),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.work_outline, size: 64, color: theme.secondaryText),
            const SizedBox(height: 16),
            Text('No projects yet',
                style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Create a project demand to get AI-generated quotes and match with providers.',
              textAlign: TextAlign.center,
              style: theme.bodyMedium.override(color: theme.secondaryText),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Create Project'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.error),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: theme.bodyMedium.override(color: theme.secondaryText)),
            const SizedBox(height: 20),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
