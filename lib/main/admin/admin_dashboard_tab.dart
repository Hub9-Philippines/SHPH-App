import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/services/admin_service.dart';

class AdminDashboardTab extends StatefulWidget {
  const AdminDashboardTab({super.key});

  @override
  State<AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<AdminDashboardTab> {
  Map<String, int> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stats = await AdminService.instance.getDashboardStats();
    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
        children: [
          _buildStatCard(
            'Total Users',
            _stats['totalUsers'] ?? 0,
            Icons.people_rounded,
            const Color(0xFF2563EB),
          ),
          _buildStatCard(
            'Providers',
            _stats['totalProviders'] ?? 0,
            Icons.work_rounded,
            const Color(0xFF7C3AED),
          ),
          _buildStatCard(
            'Pending KYC',
            _stats['pendingKyc'] ?? 0,
            Icons.verified_user_rounded,
            const Color(0xFFD97706),
          ),
          _buildStatCard(
            'Open Disputes',
            _stats['openDisputes'] ?? 0,
            Icons.gavel_rounded,
            const Color(0xFFDC2626),
          ),
          _buildStatCard(
            'Pending Payouts',
            _stats['pendingPayouts'] ?? 0,
            Icons.payments_rounded,
            const Color(0xFF059669),
          ),
          _buildStatCard(
            'Active Listings',
            _stats['activeListings'] ?? 0,
            Icons.storefront_rounded,
            const Color(0xFF0891B2),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    int value,
    IconData icon,
    Color color,
  ) {
    return Container(
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Text(
                value.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
