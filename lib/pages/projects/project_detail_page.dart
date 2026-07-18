import 'package:flutter/material.dart';

import '/api/models/project.dart';
import '/api/resources/projects_api.dart';
import '/theme/app_theme.dart';

/// Detail view for a single Project Demand (SHPH-134).
///
/// Mirrors `shph-app/src/views/services/ProjectDetailPage.vue`. Shows role
/// lines (with prospects) and exposes the quote/match/cancel actions. Backed
/// by `ShphProjectsApi.detail()` → POST `/api/projects/<pk>/`.
class ProjectDetailPage extends StatefulWidget {
  const ProjectDetailPage({super.key, required this.projectId});

  final int projectId;

  static String routeName = 'ProjectDetail';
  static String routePath = '/projects/detail/:projectId';

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  ShphProject? _project;
  bool _isLoading = true;
  bool _isBusy = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProject();
  }

  Future<void> _loadProject() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final project = await ShphProjectsApi.instance.detail(widget.projectId);
      if (mounted) {
        setState(() {
          _project = project;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load project: $e';
        });
      }
    }
  }

  Future<void> _runAction(
    String label,
    Future<ShphProject> Function() action,
  ) async {
    setState(() => _isBusy = true);
    try {
      final updated = await action();
      if (mounted) {
        setState(() {
          _project = updated;
          _isBusy = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label complete')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isBusy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label failed: $e')),
        );
      }
    }
  }

  Future<void> _confirmCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel project?'),
        content: const Text(
            'This will cancel the project demand. This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Keep')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Cancel project')),
        ],
      ),
    );
    if (confirmed != true) return;
    await _runAction(
        'Cancel', () => ShphProjectsApi.instance.cancel(widget.projectId));
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text(_project?.title ?? 'Project',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        backgroundColor: theme.primaryBackground,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _ErrorView(message: _errorMessage!, onRetry: _loadProject)
              : _project == null
                  ? const SizedBox.shrink()
                  : RefreshIndicator(
                      onRefresh: _loadProject,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                        children: [
                          _HeaderCard(project: _project!),
                          const SizedBox(height: 16),
                          if (_project!.isDraft)
                            _ActionRow(
                              isBusy: _isBusy,
                              onQuote: () => _runAction(
                                  'Quote',
                                  () => ShphProjectsApi.instance
                                      .quote(widget.projectId)),
                              onCancel: _confirmCancel,
                            )
                          else if (_project!.isQuoted || _project!.isMatching)
                            _ActionRow(
                              isBusy: _isBusy,
                              onMatchFirst: () => _runAction(
                                'Match',
                                () => ShphProjectsApi.instance.match(
                                  widget.projectId,
                                  roleLineId: _project!.roleLines.first.id,
                                ),
                              ),
                              onCancel: _confirmCancel,
                            ),
                          const SizedBox(height: 16),
                          Text('Role Lines',
                              style: theme.titleMedium
                                  .override(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          if (_project!.roleLines.isEmpty)
                            _EmptyRolesCard(
                              onQuote: () => _runAction(
                                  'Quote',
                                  () => ShphProjectsApi.instance
                                      .quote(widget.projectId)),
                            )
                          else
                            ..._project!.roleLines
                                .map((rl) => _RoleLineCard(roleLine: rl)),
                        ],
                      ),
                    ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.project});
  final ShphProject project;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(project.title,
                    style: theme.titleMedium
                        .override(fontWeight: FontWeight.w700)),
              ),
              _StatusPill(status: project.status),
            ],
          ),
          if (project.categoryName != null) ...[
            const SizedBox(height: 4),
            Text(project.categoryName!,
                style: theme.bodySmall.override(color: theme.secondaryText)),
          ],
          const SizedBox(height: 12),
          Text(project.description, style: theme.bodyMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _MetaItem(
                icon: Icons.payments_outlined,
                label: _budget(project),
              ),
              _MetaItem(
                icon: Icons.group_outlined,
                label: '${project.estimatedHeadcount} heads',
              ),
              if (project.isB2b) _MetaItem(icon: Icons.business, label: 'B2B'),
              if (project.expiresAt != null)
                _MetaItem(
                  icon: Icons.schedule,
                  label: 'Expires ${_shortDate(project.expiresAt!)}',
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _budget(ShphProject p) {
    final min = p.estimatedBudgetMin;
    final max = p.estimatedBudgetMax;
    if (min == null && max == null) return 'Budget pending quote';
    if (min == null) return 'Up to PHP ${max!.toStringAsFixed(0)}';
    if (max == null) return 'From PHP ${min.toStringAsFixed(0)}';
    return 'PHP ${min.toStringAsFixed(0)}–${max.toStringAsFixed(0)}';
  }

  String _shortDate(String iso) {
    try {
      return iso.substring(0, 10);
    } catch (_) {
      return iso;
    }
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final color = _color(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: theme.bodySmall.override(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _color(String s) {
    switch (s) {
      case 'draft':
        return Colors.grey.shade700;
      case 'quoted':
        return Colors.blue.shade700;
      case 'matching':
        return Colors.orange.shade700;
      case 'committed':
        return Colors.green.shade700;
      case 'cancelled':
        return Colors.red.shade700;
      case 'expired':
        return Colors.grey.shade500;
      default:
        return Colors.blueGrey;
    }
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.label});
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

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.isBusy,
    this.onQuote,
    this.onMatchFirst,
    this.onCancel,
  });

  final bool isBusy;
  final VoidCallback? onQuote;
  final VoidCallback? onMatchFirst;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onQuote != null)
          Expanded(
            child: FilledButton.icon(
              onPressed: isBusy ? null : onQuote,
              icon: const Icon(Icons.auto_fix_high),
              label: const Text('Generate Quote'),
            ),
          ),
        if (onMatchFirst != null)
          Expanded(
            child: FilledButton.icon(
              onPressed: isBusy ? null : onMatchFirst,
              icon: const Icon(Icons.people_alt_outlined),
              label: const Text('Match Providers'),
            ),
          ),
        if (onCancel != null) ...[
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: isBusy ? null : onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade700,
            ),
            child: const Text('Cancel'),
          ),
        ],
      ],
    );
  }
}

class _EmptyRolesCard extends StatelessWidget {
  const _EmptyRolesCard({required this.onQuote});
  final VoidCallback onQuote;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(Icons.assignment_outlined, size: 48, color: theme.secondaryText),
          const SizedBox(height: 12),
          Text('No role lines yet',
              style: theme.bodyMedium.override(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            'Generate a quote to let the AI parse your description into role lines.',
            textAlign: TextAlign.center,
            style: theme.bodySmall.override(color: theme.secondaryText),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onQuote,
            icon: const Icon(Icons.auto_fix_high),
            label: const Text('Generate Quote'),
          ),
        ],
      ),
    );
  }
}

class _RoleLineCard extends StatelessWidget {
  const _RoleLineCard({required this.roleLine});
  final ShphProjectRoleLine roleLine;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(roleLine.roleLabel,
                    style:
                        theme.bodyMedium.override(fontWeight: FontWeight.w700)),
              ),
              Text('×${roleLine.headcount}',
                  style: theme.bodyMedium.override(color: theme.secondaryText)),
            ],
          ),
          if (roleLine.categoryName != null)
            Text(roleLine.categoryName!,
                style: theme.bodySmall.override(color: theme.secondaryText)),
          if (roleLine.estSubtotalMin != null ||
              roleLine.estSubtotalMax != null) ...[
            const SizedBox(height: 6),
            Text(
              _subtotal(roleLine),
              style: theme.bodySmall.override(color: theme.secondaryText),
            ),
          ],
          if (roleLine.prospects.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Prospects (${roleLine.prospects.length})',
                style: theme.bodySmall.override(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            ...roleLine.prospects.map((p) => _ProspectRow(prospect: p)),
          ],
        ],
      ),
    );
  }

  String _subtotal(ShphProjectRoleLine rl) {
    final min = rl.estSubtotalMin;
    final max = rl.estSubtotalMax;
    if (min == null && max == null) return 'Estimate pending';
    if (min == null) return 'Up to PHP ${max!.toStringAsFixed(0)}';
    if (max == null) return 'From PHP ${min.toStringAsFixed(0)}';
    return 'PHP ${min.toStringAsFixed(0)}–${max.toStringAsFixed(0)}';
  }
}

class _ProspectRow extends StatelessWidget {
  const _ProspectRow({required this.prospect});
  final ShphProjectProspect prospect;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: theme.primary.withValues(alpha: 0.15),
            child: Icon(Icons.person, size: 16, color: theme.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(prospect.providerName ?? 'Provider #${prospect.provider}',
                    style: theme.bodyMedium),
                if (prospect.distanceKm != null)
                  Text('${prospect.distanceKm!.toStringAsFixed(1)} km away',
                      style:
                          theme.bodySmall.override(color: theme.secondaryText)),
              ],
            ),
          ),
          if (prospect.ratingSnapshot != null)
            Row(
              children: [
                Icon(Icons.star, size: 14, color: Colors.amber.shade700),
                const SizedBox(width: 2),
                Text(prospect.ratingSnapshot!.toStringAsFixed(1),
                    style: theme.bodySmall),
              ],
            ),
          const SizedBox(width: 8),
          _ProspectStatusPill(status: prospect.status),
        ],
      ),
    );
  }
}

class _ProspectStatusPill extends StatelessWidget {
  const _ProspectStatusPill({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final color = _color(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: theme.bodySmall.override(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _color(String s) {
    switch (s) {
      case 'suggested':
        return Colors.grey.shade700;
      case 'shortlisted':
        return Colors.blue.shade700;
      case 'invited':
        return Colors.orange.shade700;
      case 'accepted':
        return Colors.green.shade700;
      case 'declined':
        return Colors.red.shade700;
      default:
        return Colors.blueGrey;
    }
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
