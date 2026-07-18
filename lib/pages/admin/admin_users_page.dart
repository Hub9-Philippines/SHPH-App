import 'package:flutter/material.dart';

import '/api/resources/admin_api.dart';
import '/theme/app_theme.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  static String routeName = 'AdminUsers';
  static String routePath = '/admin-users';

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData({String? search}) async {
    setState(() => _isLoading = true);
    try {
      final data = await ShphAdminApi.instance.listUsers(search: search);
      if (mounted) {
        setState(() {
          _users = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load users: $e')),
        );
      }
    }
  }

  Future<void> _toggleActive(int userId) async {
    try {
      await ShphAdminApi.instance.toggleUserActive(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User status updated')),
        );
        await _loadData(
            search: _searchController.text.trim().isEmpty
                ? null
                : _searchController.text.trim());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text('Users',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        backgroundColor: theme.primaryBackground,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadData();
                        },
                      )
                    : null,
              ),
              onSubmitted: (value) =>
                  _loadData(search: value.trim().isEmpty ? null : value.trim()),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? _buildEmptyState(theme)
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                          itemCount: _users.length,
                          itemBuilder: (context, index) =>
                              _buildUserCard(theme, _users[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppThemeData theme) => Center(
        child: Text('No users found',
            style: theme.bodyMedium.override(color: theme.secondaryText)),
      );

  Widget _buildUserCard(AppThemeData theme, Map<String, dynamic> user) {
    final id = int.tryParse(user['id']?.toString() ?? '') ?? 0;
    final name = user['display_name'] as String? ??
        user['full_name'] as String? ??
        'Unknown';
    final email = user['email'] as String? ?? '';
    final isActive = user['is_active'] as bool? ?? true;
    final isProvider = user['is_provider'] as bool? ?? false;
    final isClient = user['is_client'] as bool? ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isActive ? theme.primary : theme.secondaryText,
            child: Text(name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style:
                        theme.bodyMedium.override(fontWeight: FontWeight.w700)),
                Text(email,
                    style:
                        theme.bodySmall.override(color: theme.secondaryText)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (isProvider)
                      _buildRoleChip(theme, 'Provider', theme.primary),
                    if (isProvider && isClient) const SizedBox(width: 4),
                    if (isClient)
                      _buildRoleChip(theme, 'Client', theme.secondary),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            onChanged: (_) => _toggleActive(id),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleChip(AppThemeData theme, String label, Color color) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: theme.labelSmall
                .override(color: color, fontWeight: FontWeight.w700)),
      );
}
