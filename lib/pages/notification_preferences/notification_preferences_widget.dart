import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/services/disputes_service.dart';
import '/services/logging_service.dart';
import '/theme/app_theme.dart';

class NotificationPreferencesWidget extends StatefulWidget {
  const NotificationPreferencesWidget({super.key});

  static String routeName = 'NotificationPreferences';
  static String routePath = '/notification-preferences';

  @override
  State<NotificationPreferencesWidget> createState() =>
      _NotificationPreferencesWidgetState();
}

class _NotificationPreferencesWidgetState
    extends State<NotificationPreferencesWidget> {
  Map<String, dynamic> _prefs = {};
  bool _isLoading = true;
  final _service = NotificationPreferencesService.instance;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      _prefs = await _service.getPreferences();
    } catch (e) {
      LoggingService.error('Notif prefs load error: $e', tag: 'NotifPrefs');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _toggle(String key, bool value) async {
    setState(() => _prefs[key] = value);
    final success = await _service.updatePreferences({key: value});
    if (!mounted) return;
    if (!success) {
      setState(() => _prefs[key] = !value);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update preference')),
      );
    }
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
        title: Text('Notification Preferences', style: theme.titleMedium),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _buildSection(context, 'Channels', [
                  _PrefTile(
                    icon: Icons.notifications_active_rounded,
                    title: 'Push Notifications',
                    subtitle: 'Receive alerts on your device',
                    value: _prefs['push_enabled'] ?? true,
                    onChanged: (v) => _toggle('push_enabled', v),
                  ),
                  _PrefTile(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    subtitle: 'Receive updates via email',
                    value: _prefs['email_enabled'] ?? true,
                    onChanged: (v) => _toggle('email_enabled', v),
                  ),
                  _PrefTile(
                    icon: Icons.sms_outlined,
                    title: 'SMS',
                    subtitle: 'Receive updates via text message',
                    value: _prefs['sms_enabled'] ?? false,
                    onChanged: (v) => _toggle('sms_enabled', v),
                  ),
                ]),
                const SizedBox(height: 16),
                _buildSection(context, 'Categories', [
                  _PrefTile(
                    icon: Icons.book_online_rounded,
                    title: 'Booking Updates',
                    subtitle: 'Status changes, confirmations, reminders',
                    value: _prefs['booking_updates'] ?? true,
                    onChanged: (v) => _toggle('booking_updates', v),
                  ),
                  _PrefTile(
                    icon: Icons.payments_outlined,
                    title: 'Payment Updates',
                    subtitle: 'Payment confirmations, refunds, payouts',
                    value: _prefs['payment_updates'] ?? true,
                    onChanged: (v) => _toggle('payment_updates', v),
                  ),
                  _PrefTile(
                    icon: Icons.campaign_outlined,
                    title: 'Promo Offers',
                    subtitle: 'Deals, discounts, and promotions',
                    value: _prefs['promo_offers'] ?? false,
                    onChanged: (v) => _toggle('promo_offers', v),
                  ),
                  _PrefTile(
                    icon: Icons.work_history_outlined,
                    title: 'Provider Alerts',
                    subtitle: 'New job offers, bid updates, reviews',
                    value: _prefs['provider_alerts'] ?? true,
                    onChanged: (v) => _toggle('provider_alerts', v),
                  ),
                ]),
              ],
            ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> tiles,
  ) {
    final theme = AppTheme.of(context);
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.titleSmall.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...tiles,
        ],
      ),
    );
  }
}

class _PrefTile extends StatelessWidget {
  const _PrefTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF64748B)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2563EB),
          ),
        ],
      ),
    );
  }
}
