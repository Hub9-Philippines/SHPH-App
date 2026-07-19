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
      body: switch (controller.state) {
        ProjectsState.loading when controller.projects.isEmpty =>
          const Center(child: CircularProgressIndicator()),
        ProjectsState.error when controller.projects.isEmpty => _MessageView(
            message: controller.errorMessage ?? 'Unable to load projects.',
            actionLabel: 'Retry',
            onAction: controller.load,
          ),
        _ when controller.projects.isEmpty => _MessageView(
            message: 'No projects yet.',
            actionLabel: 'Create project',
            onAction: _openCreate,
          ),
        _ => RefreshIndicator(
            onRefresh: () async => controller.load(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: controller.projects.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final project = controller.projects[index];
                return ListTile(
                  key: Key('project_${project.id}'),
                  title: Text(project.title),
                  subtitle: Text(
                    '${project.status} · ${project.estimatedHeadcount} people',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push<bool>(
                    '/projects/detail/${project.id}',
                  ),
                );
              },
            ),
          ),
      },
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
