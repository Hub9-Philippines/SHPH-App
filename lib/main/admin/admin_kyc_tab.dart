import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/services/admin_service.dart';

class AdminKycTab extends StatefulWidget {
  const AdminKycTab({super.key});

  @override
  State<AdminKycTab> createState() => _AdminKycTabState();
}

class _AdminKycTabState extends State<AdminKycTab> {
  List<Map<String, dynamic>> _submissions = [];
  bool _isLoading = true;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final submissions = await AdminService.instance.getKycSubmissions(
      statusFilter: _filter,
    );
    if (mounted) {
      setState(() {
        _submissions = submissions;
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
              : _submissions.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _submissions.length,
                        itemBuilder: (context, index) =>
                            _buildKycCard(_submissions[index]),
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
      ('verified', 'Verified'),
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
          const Icon(Icons.verified_user_outlined,
              size: 64, color: Color(0xFFCBD5E1)),
          const SizedBox(height: 16),
          Text(
            'No KYC submissions',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKycCard(Map<String, dynamic> submission) {
    final status = submission['verification_status'] as String? ?? 'pending';
    final name = submission['display_name'] as String? ?? 'Unknown';
    final email = submission['email'] as String? ?? '';
    final profession = submission['skill_profession'] as String?;
    final docUrl = submission['id_document_url'] as String?;
    final faceUrl = submission['face_scan_url'] as String?;

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
                  name,
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
          if (email.isNotEmpty)
            Text(email,
                style: GoogleFonts.poppins(
                    fontSize: 13, color: const Color(0xFF64748B))),
          if (profession != null)
            Text(profession,
                style: GoogleFonts.poppins(
                    fontSize: 12, color: const Color(0xFF94A3B8))),
          if (docUrl != null) ...[
            const SizedBox(height: 8),
            Text('Document: $docUrl',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                    fontSize: 11, color: const Color(0xFF2563EB))),
          ],
          if (status == 'pending') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _updateStatus(
                        submission['id'].toString(), 'verified'),
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
                    onPressed: () => _updateStatus(
                        submission['id'].toString(), 'rejected'),
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
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final colors = {
      'pending': const Color(0xFFD97706),
      'verified': const Color(0xFF059669),
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

  Future<void> _updateStatus(String userId, String status) async {
    final success = await AdminService.instance.updateKycStatus(userId, status);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'KYC ${status == 'verified' ? 'approved' : 'rejected'}'
              : 'Failed to update KYC status'),
          backgroundColor: success ? const Color(0xFF059669) : const Color(0xFFDC2626),
        ),
      );
      if (success) _load();
    }
  }
}
