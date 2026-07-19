import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/api/models/project.dart';
import '/services/projects_controller.dart';

class ProjectDetailPage extends StatefulWidget {
  const ProjectDetailPage({required this.projectId, super.key});

  final int projectId;
  static const routeName = 'ProjectDetail';
  static const routePath = '/projects/detail/:projectId';

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.projectId > 0) {
        unawaited(context.read<ProjectsController>().open(widget.projectId));
      }
    });
  }

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel project?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep project'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancel project'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final cancelled = await context.read<ProjectsController>().cancel();
      if (cancelled && mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProjectsController>();
    final currentProject = controller.currentProject;
    final project =
        currentProject?.id == widget.projectId ? currentProject : null;
    if (widget.projectId <= 0) {
      return const Scaffold(body: Center(child: Text('Invalid project id.')));
    }
    return Scaffold(
      appBar: AppBar(title: Text(project?.title ?? 'Project')),
      body: switch (controller.state) {
        ProjectsState.loading when project == null =>
          const Center(child: CircularProgressIndicator()),
        ProjectsState.error when project == null => Center(
            child: Text(controller.errorMessage ?? 'Unable to load project.'),
          ),
        _ when project == null => const SizedBox.shrink(),
        _ => RefreshIndicator(
            onRefresh: () async => controller.open(widget.projectId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(project.description),
                const SizedBox(height: 8),
                Text('Status: ${project.status}'),
                Text('Estimated team: ${project.estimatedHeadcount}'),
                if (controller.errorMessage != null)
                  Text(
                    controller.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    if (project.isDraft)
                      FilledButton(
                        key: const Key('project_quote_btn'),
                        onPressed: controller.isBusy
                            ? null
                            : () => unawaited(controller.quote()),
                        child: const Text('Generate quote'),
                      ),
                    OutlinedButton(
                      key: const Key('project_cancel_btn'),
                      onPressed: controller.isBusy || !project.isActive
                          ? null
                          : _cancel,
                      child: const Text('Cancel project'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Roles'),
                if (project.roleLines.isEmpty)
                  const Text('No role lines yet.')
                else
                  ...project.roleLines.map(
                    (role) => _RoleLineTile(
                      role: role,
                      busy: controller.isBusy,
                      onMatch: () => controller.match(role.id),
                    ),
                  ),
              ],
            ),
          ),
      },
    );
  }
}

class _RoleLineTile extends StatelessWidget {
  const _RoleLineTile({
    required this.role,
    required this.busy,
    required this.onMatch,
  });

  final ShphProjectRoleLine role;
  final bool busy;
  final Future<bool> Function() onMatch;

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(role.roleLabel),
        subtitle: Text('${role.headcount} needed'),
        trailing: TextButton(
          onPressed: busy ? null : () => unawaited(onMatch()),
          child: const Text('Match'),
        ),
      );
}
