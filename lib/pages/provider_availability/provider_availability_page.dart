import 'package:flutter/material.dart';

import '/api/resources/services_api.dart';
import '/theme/app_theme.dart';

/// Manage the provider's weekly availability slots.
///
/// Mirrors `shph-app/src/views/provider/ProviderAvailabilityPage.vue`. Backed
/// by `ShphServicesApi.listAvailability()` / `createAvailabilitySlot()` /
/// `updateAvailabilitySlot()` / `deleteAvailabilitySlot()`.
class ProviderAvailabilityPage extends StatefulWidget {
  const ProviderAvailabilityPage({super.key});

  static String routeName = 'ProviderAvailability';
  static String routePath = '/provider/availability';

  @override
  State<ProviderAvailabilityPage> createState() =>
      _ProviderAvailabilityPageState();
}

class _ProviderAvailabilityPageState extends State<ProviderAvailabilityPage> {
  List<Map<String, dynamic>> _slots = const [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final slots = await ShphServicesApi.instance.listAvailability();
      if (mounted) {
        setState(() {
          _slots = slots;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load availability: $e';
        });
      }
    }
  }

  Future<void> _toggleSlot(Map<String, dynamic> slot) async {
    final id = _id(slot);
    if (id == null) return;
    final current = slot['is_available'] as bool? ?? false;
    try {
      await ShphServicesApi.instance
          .updateAvailabilitySlot(id, {'is_available': !current});
      _loadSlots();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    }
  }

  Future<void> _deleteSlot(Map<String, dynamic> slot) async {
    final id = _id(slot);
    if (id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete slot?'),
        content: const Text('This availability slot will be removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ShphServicesApi.instance.deleteAvailabilitySlot(id);
      _loadSlots();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  int? _id(Map<String, dynamic> slot) {
    final raw = slot['id'];
    if (raw is int) return raw;
    return int.tryParse(raw?.toString() ?? '');
  }

  Future<void> _addSlot() async {
    final payload = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => const _AddSlotDialog(),
    );
    if (payload == null) return;
    try {
      await ShphServicesApi.instance.createAvailabilitySlot(payload);
      _loadSlots();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Add failed: $e')),
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
        title: Text('Availability',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        backgroundColor: theme.primaryBackground,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _ErrorView(message: _errorMessage!, onRetry: _loadSlots)
              : _slots.isEmpty
                  ? _EmptyView(onAdd: _addSlot)
                  : RefreshIndicator(
                      onRefresh: _loadSlots,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                        itemCount: _slots.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final slot = _slots[i];
                          return _SlotRow(
                            slot: slot,
                            onToggle: () => _toggleSlot(slot),
                            onDelete: () => _deleteSlot(slot),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSlot,
        icon: const Icon(Icons.add),
        label: const Text('Add Slot'),
      ),
    );
  }
}

class _SlotRow extends StatelessWidget {
  const _SlotRow({
    required this.slot,
    required this.onToggle,
    required this.onDelete,
  });

  final Map<String, dynamic> slot;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final isAvailable = slot['is_available'] as bool? ?? false;
    final day =
        slot['day_of_week']?.toString() ?? slot['date']?.toString() ?? '';
    final start = slot['start_time']?.toString() ?? '';
    final end = slot['end_time']?.toString() ?? '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day,
                    style:
                        theme.bodyMedium.override(fontWeight: FontWeight.w700)),
                Text('$start – $end',
                    style:
                        theme.bodySmall.override(color: theme.secondaryText)),
              ],
            ),
          ),
          Switch(value: isAvailable, onChanged: (_) => onToggle()),
          IconButton(
            tooltip: 'Delete',
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline,
                color: Colors.red.shade700, size: 20),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_available_outlined,
                size: 64, color: theme.secondaryText),
            const SizedBox(height: 16),
            Text('No availability slots',
                style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Add time slots so clients know when you can take bookings.',
              textAlign: TextAlign.center,
              style: theme.bodyMedium.override(color: theme.secondaryText),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add Slot'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddSlotDialog extends StatefulWidget {
  const _AddSlotDialog();

  @override
  State<_AddSlotDialog> createState() => _AddSlotDialogState();
}

class _AddSlotDialogState extends State<_AddSlotDialog> {
  String _day = 'mon';
  TimeOfDay _start = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 17, minute: 0);

  static const _days = [
    ('mon', 'Monday'),
    ('tue', 'Tuesday'),
    ('wed', 'Wednesday'),
    ('thu', 'Thursday'),
    ('fri', 'Friday'),
    ('sat', 'Saturday'),
    ('sun', 'Sunday'),
  ];

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return AlertDialog(
      title: Text('Add availability slot', style: theme.titleMedium),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _day,
            decoration: const InputDecoration(labelText: 'Day of week'),
            items: _days
                .map((d) => DropdownMenuItem(value: d.$1, child: Text(d.$2)))
                .toList(),
            onChanged: (v) => setState(() => _day = v ?? 'mon'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Start'),
                  subtitle: Text(_fmt(_start)),
                  onTap: () => _pickTime(true),
                ),
              ),
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('End'),
                  subtitle: Text(_fmt(_end)),
                  onTap: () => _pickTime(false),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.of(context).pop({
            'day_of_week': _day,
            'start_time': _fmt(_start),
            'end_time': _fmt(_end),
            'is_available': true,
          }),
          child: const Text('Add'),
        ),
      ],
    );
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
