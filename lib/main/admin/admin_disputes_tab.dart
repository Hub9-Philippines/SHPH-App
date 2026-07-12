import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/services/admin_service.dart';

class AdminDisputesTab extends StatefulWidget {
  const AdminDisputesTab({super.key});

  @override
  State<AdminDisputesTab> createState() => _AdminDisputesTabState();
}

class _AdminDisputesTabState extends State<AdminDisputesTab> {
  List<Map<String, dynamic>> _disputes = [];
  bool _isLoading = true;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final disputes = await AdminService.instance.getAllDisputes(
      statusFilter: _filter,
    );
    if (mounted) {
      setState(() {
        _disputes = disputes;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _disputes.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _disputes.length,
                        itemBuilder: (context, index) =>
                            _buildDisputeCard(_disputes[index]),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    final filters = [
      ('all', 'All'),
      ('open', 'Open'),
      ('under_review', 'Under Review'),
      ('resolved', 'Resolved'),
      ('closed', 'Closed'),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final isSelected = _filter == f.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(f.$2),
                selected: isSelected,
                onSelected: (_) {
                  setState(() => _filter = f.$1);
                  _load();
                },
                selectedColor: const Color(0xFF2563EB),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.gavel_outlined, size: 64, color: Color(0xFFCBD5E1)),
          const SizedBox(height: 16),
          Text(
            'No disputes found',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisputeCard(Map<String, dynamic> dispute) {
    final status = dispute['status'] as String? ?? 'open';
    final reason = dispute['reason'] as String? ?? 'Unknown';
    final description = dispute['description'] as String?;
    final resolution = dispute['resolution'] as String?;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              _buildStatusBadge(status),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(description,
                style: GoogleFonts.poppins(
                    fontSize: 13, color: const Color(0xFF64748B))),
          ],
          if (resolution != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Resolution: $resolution',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: const Color(0xFF059669))),
            ),
          ],
          if (status == 'open' || status == 'under_review') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        _showResolveDialog(dispute['id'].toString()),
                    child: const Text('Resolve'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateStatus(
                        dispute['id'].toString(), 'closed', null),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final colors = {
      'open': const Color(0xFFD97706),
      'under_review': const Color(0xFF2563EB),
      'resolved': const Color(0xFF059669),
      'closed': const Color(0xFF6B7280),
    };
    final color = colors[status] ?? const Color(0xFF6B7280);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.replaceAll('_', ' ').split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' '),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Future<void> _showResolveDialog(String disputeId) async {
    final resolutionController = TextEditingController();
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resolve Dispute'),
        content: TextField(
          controller: resolutionController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Resolution details',
            hintText: 'Describe how the dispute was resolved...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final text = resolutionController.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(ctx, {'resolution': text});
            },
            child: const Text('Resolve'),
          ),
        ],
      ),
    );

    if (result == null) return;
    await _updateStatus(disputeId, 'resolved', result['resolution']);
  }

  Future<void> _updateStatus(
      String disputeId, String status, String? resolution) async {
    final success = await AdminService.instance
        .updateDisputeStatus(disputeId, status, resolution);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Dispute updated' : 'Failed to update dispute'),
          backgroundColor: success ? const Color(0xFF059669) : const Color(0xFFDC2626),
        ),
      );
      if (success) _load();
    }
  }
}
