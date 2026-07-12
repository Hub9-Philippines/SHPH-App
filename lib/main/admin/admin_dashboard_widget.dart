import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/admin_service.dart';
import '/services/logging_service.dart';
import '/theme/app_theme.dart';
import 'admin_dashboard_tab.dart';
import 'admin_kyc_tab.dart';
import 'admin_disputes_tab.dart';
import 'admin_payouts_tab.dart';
import 'admin_users_tab.dart';
import 'admin_audit_tab.dart';

class AdminDashboardWidget extends StatefulWidget {
  const AdminDashboardWidget({super.key});

  static const String routeName = 'AdminDashboard';
  static const String routePath = '/admin';

  @override
  State<AdminDashboardWidget> createState() => _AdminDashboardWidgetState();
}

class _AdminDashboardWidgetState extends State<AdminDashboardWidget> {
  bool _isAdmin = false;
  bool _checking = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final admin = await AdminService.instance.isAdmin;
    if (mounted) {
      setState(() {
        _isAdmin = admin;
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return Scaffold(
        body: const Center(child: CircularProgressIndicator()),
        appBar: AppBar(title: const Text('Admin Panel')),
      );
    }

    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Panel')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline_rounded,
                    size: 64, color: Color(0xFFCBD5E1)),
                const SizedBox(height: 16),
                Text(
                  'Access Denied',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You need admin privileges to access this page.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final tabs = [
      const AdminDashboardTab(),
      const AdminKycTab(),
      const AdminDisputesTab(),
      const AdminPayoutsTab(),
      const AdminUsersTab(),
      const AdminAuditTab(),
    ];

    final tabItems = [
      const NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard_rounded),
        label: 'Dashboard',
      ),
      const NavigationDestination(
        icon: Icon(Icons.verified_user_outlined),
        selectedIcon: Icon(Icons.verified_user_rounded),
        label: 'KYC',
      ),
      const NavigationDestination(
        icon: Icon(Icons.gavel_outlined),
        selectedIcon: Icon(Icons.gavel_rounded),
        label: 'Disputes',
      ),
      const NavigationDestination(
        icon: Icon(Icons.payments_outlined),
        selectedIcon: Icon(Icons.payments_rounded),
        label: 'Payouts',
      ),
      const NavigationDestination(
        icon: Icon(Icons.people_outline_rounded),
        selectedIcon: Icon(Icons.people_rounded),
        label: 'Users',
      ),
      const NavigationDestination(
        icon: Icon(Icons.history_outlined),
        selectedIcon: Icon(Icons.history_rounded),
        label: 'Audit',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          switch (_currentIndex) {
            0 => 'Admin Dashboard',
            1 => 'KYC Verification',
            2 => 'Disputes Management',
            3 => 'Payouts Management',
            4 => 'Users Management',
            5 => 'Audit Logs',
            _ => 'Admin Panel',
          },
          style: AppTheme.of(context).titleLarge.override(
                font: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) =>
            setState(() => _currentIndex = index),
        destinations: tabItems,
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.of(context).primary.withValues(alpha: 0.1),
      ),
    );
  }
}
