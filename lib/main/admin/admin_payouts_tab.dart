import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/services/admin_service.dart';

class AdminPayoutsTab extends StatefulWidget {
  const AdminPayoutsTab({super.key});

  @override
  State<AdminPayoutsTab> createState() => _AdminPayoutsTabState();
}

class _AdminPayoutsTabState extends State<AdminPayoutsTab> {
  List<Map<String, dynamic>> _payouts = [];
  bool _isLoading = true;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final payouts = await AdminService.instance.getAllPayouts(
      statusFilter: _filter,
    );
    if (mounted) {
      setState(() {
        _payouts = payouts;
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
              : _payouts.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _payouts.length,
                        itemBuilder: (context, index) =>
                            _buildPayoutCard(_payouts[index]),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    final filters = [
      ('all', 'All'),
      ('pending', 'Pending'),
      ('approved', 'Approved'),
      ('completed', 'Completed'),
      ('rejected', 'Rejected'),
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
          const Icon(Icons.payments_outlined,
              size: 64, color: Color(0xFFCBD5E1)),
          const SizedBox(height: 16),
          Text(
            'No payouts found',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutCard(Map<String, dynamic> payout) {
    final status = payout['status'] as String? ?? 'pending';
    final amount = (payout['amount'] as num?)?.toDouble() ?? 0.0;
    final note = payout['note'] as String?;
    final createdRaw = payout['created_at'] as String?;
    final created = createdRaw != null ? DateTime.tryParse(createdRaw) : null;

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
              Text(
                '₱${amount.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              _buildStatusBadge(status),
            ],
          ),
          if (note != null && note.isNotEmpty)
            Text(note,
                style: GoogleFonts.poppins(
                    fontSize: 13, color: const Color(0xFF64748B))),
          if (created != null)
            Text('Requested: ${created.month}/${created.day}/${created.year}',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: const Color(0xFF94A3B8))),
          if (status == 'pending') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () =>
                        _updateStatus(payout['id'].toString(), 'approved'),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approve'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _updateStatus(payout['id'].toString(), 'rejected'),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (status == 'approved') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () =>
                    _updateStatus(payout['id'].toString(), 'completed'),
                icon: const Icon(Icons.task_alt, size: 18),
                label: const Text('Mark Completed'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final colors = {
      'pending': const Color(0xFFD97706),
      'approved': const Color(0xFF2563EB),
      'completed': const Color(0xFF059669),
      'rejected': const Color(0xFFDC2626),
    };
    final color = colors[status] ?? const Color(0xFF6B7280);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Future<void> _updateStatus(String payoutId, String status) async {
    final success =
        await AdminService.instance.updatePayoutStatus(payoutId, status);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Payout updated' : 'Failed to update payout'),
          backgroundColor: success ? const Color(0xFF059669) : const Color(0xFFDC2626),
        ),
      );
      if (success) _load();
    }
  }
}
