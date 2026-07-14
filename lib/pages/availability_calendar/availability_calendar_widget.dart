import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '/api/shph_api.dart';
import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/logging_service.dart';
import '/theme/app_theme.dart';
import 'availability_calendar_model.dart';

export 'availability_calendar_model.dart';

class AvailabilityCalendarWidget extends StatefulWidget {
  const AvailabilityCalendarWidget({super.key});

  static String routeName = 'AvailabilityCalendar';
  static String routePath = '/availability-calendar';

  @override
  State<AvailabilityCalendarWidget> createState() =>
      _AvailabilityCalendarWidgetState();
}

class _AvailabilityCalendarWidgetState
    extends State<AvailabilityCalendarWidget> {
  late AvailabilityCalendarModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<Map<String, dynamic>> _availabilitySlots = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, AvailabilityCalendarModel.new);
    _loadAvailability();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _loadAvailability() async {
    try {
      final slots = await ShphServicesApi.instance.listAvailability();
      if (!mounted) return;
      setState(() {
        _availabilitySlots = slots;
        _isLoading = false;
      });
    } catch (e) {
      LoggingService.error('Error loading availability: $e',
          tag: 'AvailCalendar');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addTimeSlot() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => _TimeSlotDialog(),
    );
    if (result == null || !mounted) return;
    try {
      await ShphServicesApi.instance.createAvailability(result);
      await _loadAvailability();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to add slot: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _editTimeSlot(Map<String, dynamic> slot) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => _TimeSlotDialog(initial: slot),
    );
    if (result == null || !mounted) return;
    try {
      await ShphServicesApi.instance
          .updateAvailability(slot['id'] as int, result);
      await _loadAvailability();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to update slot: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteSlot(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Slot'),
        content: const Text('Remove this availability slot?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await ShphServicesApi.instance.deleteAvailability(id);
      await _loadAvailability();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to delete slot: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  List<Map<String, dynamic>> get _slotsForSelectedDay {
    final dayOfWeek = _selectedDay.weekday;
    return _availabilitySlots.where((s) {
      final slotDay =
          s['day_of_week'] ?? s['day']?.toString().toLowerCase() ?? '';
      if (slotDay is int) return slotDay == dayOfWeek;
      if (slotDay is String) {
        const days = [
          '',
          'monday',
          'tuesday',
          'wednesday',
          'thursday',
          'friday',
          'saturday',
          'sunday'
        ];
        return days.indexOf(slotDay.toLowerCase()) == dayOfWeek;
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: AppTheme.of(context).primaryBackground,
          appBar: AppBar(
            backgroundColor: AppTheme.of(context).primary,
            leading: const BackButtonWidget(),
            title: const Text('Manage Availability'),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _isLoading ? null : _addTimeSlot,
            icon: const Icon(Icons.add),
            label: const Text('Add Time Slot'),
            backgroundColor: AppTheme.of(context).primary,
            foregroundColor: Colors.white,
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadAvailability,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Card(
                          margin: const EdgeInsets.all(16),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Work Schedule',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                TableCalendar(
                                  firstDay: DateTime.now(),
                                  lastDay: DateTime.now()
                                      .add(const Duration(days: 90)),
                                  focusedDay: _focusedDay,
                                  calendarFormat: _calendarFormat,
                                  selectedDayPredicate: (day) =>
                                      isSameDay(_selectedDay, day),
                                  onDaySelected: (selectedDay, focusedDay) {
                                    setState(() {
                                      _selectedDay = selectedDay;
                                      _focusedDay = focusedDay;
                                    });
                                  },
                                  onFormatChanged: (format) {
                                    setState(() => _calendarFormat = format);
                                  },
                                  onPageChanged: (focusedDay) =>
                                      _focusedDay = focusedDay,
                                  headerStyle: const HeaderStyle(
                                      formatButtonVisible: true,
                                      titleCentered: true),
                                  calendarStyle: CalendarStyle(
                                    selectedDecoration: BoxDecoration(
                                      color: AppTheme.of(context).primary,
                                      shape: BoxShape.circle,
                                    ),
                                    todayDecoration: BoxDecoration(
                                      color: AppTheme.of(context)
                                          .primary
                                          .withOpacity(0.3),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text(
                            'Slots for ${_dayName(_selectedDay.weekday)}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      if (_slotsForSelectedDay.isEmpty)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(
                                child: Text(
                                    'No slots for this day. Tap + to add one.')),
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final slot = _slotsForSelectedDay[index];
                              final id = slot['id'] as int;
                              final start =
                                  slot['start_time']?.toString() ?? '09:00';
                              final end =
                                  slot['end_time']?.toString() ?? '17:00';
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                child: ListTile(
                                  onTap: () => _editTimeSlot(slot),
                                  leading: CircleAvatar(
                                    backgroundColor: AppTheme.of(context)
                                        .primary
                                        .withOpacity(0.1),
                                    child: Icon(Icons.access_time,
                                        color: AppTheme.of(context).primary),
                                  ),
                                  title: Text('$start - $end'),
                                  subtitle:
                                      Text(slot['note']?.toString() ?? ''),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.red),
                                    onPressed: () => _deleteSlot(id),
                                  ),
                                ),
                              );
                            },
                            childCount: _slotsForSelectedDay.length,
                          ),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  ),
                ),
        ),
      );

  String _dayName(int weekday) {
    const names = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return names[weekday];
  }
}

class _TimeSlotDialog extends StatefulWidget {
  const _TimeSlotDialog({this.initial});

  final Map<String, dynamic>? initial;

  @override
  State<_TimeSlotDialog> createState() => _TimeSlotDialogState();
}

class _TimeSlotDialogState extends State<_TimeSlotDialog> {
  int _selectedDay = DateTime.now().weekday;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial == null) return;
    _selectedDay = initial['day_of_week'] as int? ?? _selectedDay;
    _startTime = _parseTime(initial['start_time']) ?? _startTime;
    _endTime = _parseTime(initial['end_time']) ?? _endTime;
  }

  TimeOfDay? _parseTime(Object? value) {
    final parts = value?.toString().split(':');
    if (parts == null || parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    return hour == null || minute == null
        ? null
        : TimeOfDay(hour: hour, minute: minute);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Add Time Slot' : 'Edit Time Slot'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            value: _selectedDay,
            decoration: const InputDecoration(labelText: 'Day of Week'),
            items: const [
              DropdownMenuItem(value: 1, child: Text('Monday')),
              DropdownMenuItem(value: 2, child: Text('Tuesday')),
              DropdownMenuItem(value: 3, child: Text('Wednesday')),
              DropdownMenuItem(value: 4, child: Text('Thursday')),
              DropdownMenuItem(value: 5, child: Text('Friday')),
              DropdownMenuItem(value: 6, child: Text('Saturday')),
              DropdownMenuItem(value: 7, child: Text('Sunday')),
            ],
            onChanged: (v) => setState(() => _selectedDay = v!),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Start Time'),
            trailing: Text(_startTime.format(context)),
            onTap: () async {
              final picked = await showTimePicker(
                  context: context, initialTime: _startTime);
              if (picked != null) setState(() => _startTime = picked);
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('End Time'),
            trailing: Text(_endTime.format(context)),
            onTap: () async {
              final picked =
                  await showTimePicker(context: context, initialTime: _endTime);
              if (picked != null) setState(() => _endTime = picked);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, {
              'day_of_week': _selectedDay,
              'start_time': _startTime.format(context),
              'end_time': _endTime.format(context),
            });
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
