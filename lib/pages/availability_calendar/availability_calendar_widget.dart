import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/services/availability_service.dart';
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

  @override
  void initState() {
    super.initState();
    _model = AvailabilityCalendarModel();
    _model.loadSlots();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _formatMonth(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final now = DateTime.now();
    final firstDay = DateTime(_model.selectedDate.year, _model.selectedDate.month, 1);
    final lastDay = DateTime(_model.selectedDate.year, _model.selectedDate.month + 1, 0);
    final firstWeekday = firstDay.weekday % 7;

    return Scaffold(
      backgroundColor: theme.secondaryBackground,
      appBar: AppBar(
        backgroundColor: theme.secondaryBackground,
        title: Text(
          'Availability Calendar',
          style: theme.titleLarge,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMonthHeader(context),
            const SizedBox(height: 16),
            _buildWeekdayHeader(theme),
            _buildCalendarGrid(context, firstDay, lastDay, firstWeekday, now, theme),
            const SizedBox(height: 16),
            _buildSlotsList(context, theme),
            const Spacer(),
            _buildAddSlotButton(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            _model.goToPreviousMonth();
            _model.loadSlots();
            safeSetState(() {});
          },
        ),
        Text(
          _formatMonth(_model.selectedDate),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            _model.goToNextMonth();
            _model.loadSlots();
            safeSetState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader(AppThemeData theme) {
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays
          .map((d) => SizedBox(
                width: 40,
                child: Text(
                  d,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    color: theme.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildCalendarGrid(
    BuildContext context,
    DateTime firstDay,
    DateTime lastDay,
    int firstWeekday,
    DateTime now,
    AppThemeData theme,
  ) {
    final daysInMonth = lastDay.day;
    final today = DateTime(now.year, now.month, now.day);

    return Column(
      children: [
        for (var row = 0; row < 6; row++) ...[
          if (row * 7 + 1 - firstWeekday <= daysInMonth)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (var col = 0; col < 7; col++)
                  _buildDayCellForGrid(row, col, firstWeekday, daysInMonth, today, theme),
              ],
            ),
        ],
      ],
    );
  }

  Widget _buildDayCellForGrid(
    int row,
    int col,
    int firstWeekday,
    int daysInMonth,
    DateTime today,
    AppThemeData theme,
  ) {
    final dayNum = row * 7 + col + 1 - firstWeekday;
    if (dayNum >= 1 && dayNum <= daysInMonth) {
      return _buildDayCell(context, dayNum, today, theme);
    }
    return const SizedBox(width: 40, height: 40);
  }

  Widget _buildDayCell(
      BuildContext context, int dayNum, DateTime today, AppThemeData theme) {
    final date = DateTime(
        _model.selectedDate.year, _model.selectedDate.month, dayNum);
    final isSelected = date == _model.selectedDate;
    final isToday = date == today;

    return GestureDetector(
      onTap: () {
        _model.selectDate(date);
        _model.loadSlots();
        safeSetState(() {});
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primary
              : isToday
                  ? theme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            dayNum.toString(),
            style: GoogleFonts.plusJakartaSans(
              color: isSelected ? Colors.white : theme.primaryText,
              fontSize: 14,
              fontWeight: isSelected || isToday
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlotsList(BuildContext context, AppThemeData theme) {
    if (_model.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_model.slots.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'No availability slots set for this date.',
          style: GoogleFonts.plusJakartaSans(
            color: theme.secondaryText,
            fontSize: 14,
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.separated(
        itemCount: _model.slots.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final slot = _model.slots[index];
          return _buildSlotItem(context, slot, theme);
        },
      ),
    );
  }

  Widget _buildSlotItem(
      BuildContext context, Map<String, dynamic> slot, AppThemeData theme) {
    final startTime = slot['start_time'] as String? ?? 'N/A';
    final endTime = slot['end_time'] as String? ?? 'N/A';
    final isAvailable = slot['is_available'] as bool? ?? true;
    final slotId = slot['id']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAvailable
              ? theme.success.withValues(alpha: 0.3)
              : theme.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.block,
            color: isAvailable ? theme.success : theme.textTertiary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$startTime — $endTime',
              style: GoogleFonts.plusJakartaSans(
                color: theme.primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline,
                color: theme.error, size: 20),
            onPressed: () async {
              await _model.removeSlot(slotId);
              safeSetState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddSlotButton(BuildContext context, AppThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton.icon(
        onPressed: () => _showAddSlotDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Add Time Slot',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: theme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showAddSlotDialog(BuildContext context) {
    final theme = AppTheme.of(context);
    final startController = TextEditingController();
    final endController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.secondaryBackground,
        title: Text(
          'Add Time Slot',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            color: theme.primaryText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: startController,
              decoration: InputDecoration(
                labelText: 'Start Time (HH:MM)',
                hintText: '09:00',
                filled: true,
                fillColor: theme.primaryBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: endController,
              decoration: InputDecoration(
                labelText: 'End Time (HH:MM)',
                hintText: '17:00',
                filled: true,
                fillColor: theme.primaryBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: GoogleFonts.plusJakartaSans(color: theme.secondaryText)),
          ),
          FilledButton(
            onPressed: () async {
              await _model.addSlot(
                startTime: startController.text.trim(),
                endTime: endController.text.trim(),
              );
              safeSetState(() {});
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: Text('Add',
                style: GoogleFonts.plusJakartaSans(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
