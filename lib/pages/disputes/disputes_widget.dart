import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/services/disputes_service.dart';
import '/services/logging_service.dart';
import '/theme/app_theme.dart';

class DisputesWidget extends StatefulWidget {
  const DisputesWidget({super.key});

  static String routeName = 'Disputes';
  static String routePath = '/disputes';

  @override
  State<DisputesWidget> createState() => _DisputesWidgetState();
}

class _DisputesWidgetState extends State<DisputesWidget> {
  List<Map<String, dynamic>> _disputes = [];
  bool _isLoading = true;
  final _service = DisputesService.instance;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      _disputes = await _service.getDisputes();
    } catch (e) {
      LoggingService.error('Disputes load error: $e', tag: 'Disputes');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Color _statusColor(String status) {
    return switch (status) {
      'open' => const Color(0xFFD97706),
      'under_review' => const Color(0xFF2563EB),
      'resolved' => const Color(0xFF059669),
      'closed' => const Color(0xFF6B7280),
      'rejected' => const Color(0xFFDC2626),
      _ => const Color(0xFF6B7280),
    };
  }

  String _statusLabel(String status) {
    return switch (status) {
      'open' => 'Open',
      'under_review' => 'Under Review',
      'resolved' => 'Resolved',
      'closed' => 'Closed',
      'rejected' => 'Rejected',
      _ => status,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Disputes', style: theme.titleMedium),
            Text(
              'File & track booking disputes',
              style: theme.bodySmall.copyWith(color: const Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: _load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _disputes.isEmpty
              ? _buildEmpty(context)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount: _disputes.length,
                    itemBuilder: (context, index) =>
                        _buildDisputeCard(context, _disputes[index]),
                  ),
                ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.gavel_outlined, size: 64, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            Text(
              'No Disputes',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'File a dispute if you have an issue with a booking.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisputeCard(BuildContext context, Map<String, dynamic> dispute) {
    final status = dispute['status'] as String? ?? 'open';
    final reason = dispute['reason'] as String? ?? 'Unknown reason';
    final description = dispute['description'] as String?;
    final createdRaw = dispute['created_at'] as String?;
    final created = createdRaw != null ? DateTime.tryParse(createdRaw) : null;
    final evidence = (dispute['dispute_evidence'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  reason,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _statusLabel(status),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _statusColor(status),
                  ),
                ),
              ),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
          if (evidence.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.attach_file_rounded,
                    size: 14, color: const Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Text(
                  '${evidence.length} evidence file(s)',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ],
          if (created != null) ...[
            const SizedBox(height: 8),
            Text(
              'Filed: ${created.month}/${created.day}/${created.year}',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showCreateDialog() async {
    final reasonController = TextEditingController();
    final descController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('File a Dispute'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reasonController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Reason',
                hintText: 'e.g. Service not completed',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Describe the issue...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) return;
              Navigator.pop(ctx, {
                'reason': reason,
                'description': descController.text.trim(),
              });
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (result == null || !mounted) return;

    final success = await _service.createDispute(
      reason: result['reason']!,
      description: result['description'],
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dispute filed successfully'),
          backgroundColor: Color(0xFF059669),
        ),
      );
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to file dispute')),
      );
    }
  }
}
