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

  Future<void> _quote() async {
    final hint = TextEditingController();
    final maxRoles = TextEditingController(text: '5');
    final submit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate project quote'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: hint,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Additional context (optional)',
              ),
            ),
            TextField(
              controller: maxRoles,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Maximum role lines'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Back'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Generate'),
          ),
        ],
      ),
    );
    if (submit == true && mounted) {
      final success = await context.read<ProjectsController>().quote(
            contextHint: hint.text,
            maxRoleLines: int.tryParse(maxRoles.text),
          );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project quote generated.')),
        );
      }
    }
    hint.dispose();
    maxRoles.dispose();
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(project.categoryName ?? 'Project',
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                            ),
                            Chip(label: Text(project.status)),
                          ],
                        ),
                        Text(project.description),
                        const SizedBox(height: 12),
                        Text('Estimated team: ${project.estimatedHeadcount}'),
                        if (project.estimatedBudgetMin != null)
                          Text(
                            'Budget: ₱${project.estimatedBudgetMin!.toStringAsFixed(2)} – '
                            '₱${(project.estimatedBudgetMax ?? project.estimatedBudgetMin!).toStringAsFixed(2)}',
                          ),
                        if (project.expiresAt?.isNotEmpty == true)
                          Text('Expires: ${project.expiresAt}'),
                      ],
                    ),
                  ),
                ),
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
                        onPressed: controller.isBusy ? null : _quote,
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
                Text('Roles & provider matches',
                    style: Theme.of(context).textTheme.titleMedium),
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
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(top: 10),
        child: ExpansionTile(
          title: Text(role.roleLabel),
          subtitle: Text(
            '${role.headcount} needed · '
            '${_moneyRange(role.estRateMin, role.estRateMax)} each',
          ),
          trailing: TextButton(
            onPressed: busy ? null : () => unawaited(onMatch()),
            child: Text(role.prospects.isEmpty ? 'Find matches' : 'Refresh'),
          ),
          children: [
            if (role.prospects.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No provider prospects yet.'),
              )
            else
              ...role.prospects.map(
                (prospect) => _ProspectTile(prospect: prospect, busy: busy),
              ),
          ],
        ),
      );

  static String _moneyRange(double? min, double? max) {
    if (min == null) return 'Not quoted';
    return '₱${min.toStringAsFixed(0)}–₱${(max ?? min).toStringAsFixed(0)}';
  }
}

class _ProspectTile extends StatelessWidget {
  const _ProspectTile({required this.prospect, required this.busy});
  final ShphProjectProspect prospect;
  final bool busy;

  Future<void> _act(BuildContext context, String action) async {
    double? agreedPrice;
    if (action == 'accept') {
      final controller = TextEditingController(
        text: prospect.agreedPrice?.toStringAsFixed(2) ?? '',
      );
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Accept provider'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Agreed price'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Back'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Accept'),
            ),
          ],
        ),
      );
      agreedPrice = double.tryParse(controller.text.trim());
      controller.dispose();
      if (confirmed != true || agreedPrice == null || agreedPrice <= 0) return;
    }
    if (!context.mounted) return;
    await context.read<ProjectsController>().actOnProspect(
          prospectId: prospect.id,
          action: action,
          agreedPrice: agreedPrice,
        );
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(prospect.providerName ?? 'Provider'),
              subtitle: Text(
                '${prospect.listingTitle ?? 'Service listing'}\n'
                'Rating ${prospect.ratingSnapshot?.toStringAsFixed(1) ?? '—'} · '
                '${prospect.completedJobsSnapshot} jobs · '
                '${prospect.distanceKm?.toStringAsFixed(1) ?? '—'} km',
              ),
              isThreeLine: true,
              trailing: Chip(label: Text(prospect.status)),
            ),
            Wrap(
              spacing: 8,
              children: [
                if (prospect.isPending)
                  OutlinedButton(
                    onPressed: busy ? null : () => _act(context, 'shortlist'),
                    child: const Text('Shortlist'),
                  ),
                if (prospect.isShortlisted)
                  FilledButton(
                    onPressed: busy ? null : () => _act(context, 'invite'),
                    child: const Text('Invite'),
                  ),
                if (prospect.isInvited)
                  FilledButton(
                    onPressed: busy ? null : () => _act(context, 'accept'),
                    child: const Text('Accept'),
                  ),
                if (prospect.isPending ||
                    prospect.isShortlisted ||
                    prospect.isInvited)
                  TextButton(
                    onPressed: busy ? null : () => _act(context, 'decline'),
                    child: const Text('Decline'),
                  ),
              ],
            ),
          ],
        ),
      );
}
