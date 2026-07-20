import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/services/projects_controller.dart';

import 'project_create_page.dart';

/// Minimal project list surface adapted from `feature/sync-from-shph-main`.
class ProjectListPage extends StatefulWidget {
  const ProjectListPage({super.key});

  static const routeName = 'ProjectList';
  static const routePath = '/projects';

  @override
  State<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  String? _status;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(context.read<ProjectsController>().load());
      }
    });
  }

  Future<void> _openCreate() async {
    final created = await context.push<bool>(ProjectCreatePage.routePath);
    if (created == true && mounted) {
      unawaited(context.read<ProjectsController>().load());
    }
  }

  Future<void> _filter(String? status) async {
    setState(() => _status = status);
    await context.read<ProjectsController>().load(status: status);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProjectsController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('project_create_btn'),
        onPressed: controller.isBusy ? null : _openCreate,
        icon: const Icon(Icons.add),
        label: const Text('New project'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 58,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                for (final entry in const <String?, String>{
                  null: 'All',
                  'draft': 'Drafts',
                  'quoted': 'Quoted',
                  'matching': 'Matching',
                  'committed': 'Committed',
                  'cancelled': 'Cancelled',
                }.entries)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(entry.value),
                      selected: _status == entry.key,
                      onSelected: controller.isBusy
                          ? null
                          : (_) => unawaited(_filter(entry.key)),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: switch (controller.state) {
              ProjectsState.loading when controller.projects.isEmpty =>
                const Center(child: CircularProgressIndicator()),
              ProjectsState.error when controller.projects.isEmpty =>
                _MessageView(
                  message:
                      controller.errorMessage ?? 'Unable to load projects.',
                  actionLabel: 'Retry',
                  onAction: () => _filter(_status),
                ),
              _ when controller.projects.isEmpty => _MessageView(
                  message: 'No projects yet.',
                  actionLabel: 'Create project',
                  onAction: _openCreate,
                ),
              _ => RefreshIndicator(
                  onRefresh: () async => controller.load(status: _status),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    itemCount: controller.projects.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final project = controller.projects[index];
                      final budget = project.estimatedBudgetMin == null
                          ? 'Awaiting quote'
                          : '₱${project.estimatedBudgetMin!.toStringAsFixed(0)}–'
                              '₱${(project.estimatedBudgetMax ?? project.estimatedBudgetMin!).toStringAsFixed(0)}';
                      return Card(
                        child: ListTile(
                          key: Key('project_${project.id}'),
                          contentPadding: const EdgeInsets.all(16),
                          leading: const CircleAvatar(
                            child: Icon(Icons.assignment_outlined),
                          ),
                          title: Text(project.title),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '${project.categoryName ?? 'Project'}\n'
                              '$budget · ${project.estimatedHeadcount} people',
                            ),
                          ),
                          isThreeLine: true,
                          trailing: Chip(label: Text(project.status)),
                          onTap: () => context.push<bool>(
                            '/projects/detail/${project.id}',
                          ),
                        ),
                      );
                    },
                  ),
                ),
            },
          ),
        ],
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final FutureOr<void> Function() onAction;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => unawaited(Future.sync(onAction)),
              child: Text(actionLabel),
            ),
          ],
        ),
      );
}
