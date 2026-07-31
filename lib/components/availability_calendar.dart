import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/theme/app_theme.dart';

class AvailabilityCalendar extends StatefulWidget {
  const AvailabilityCalendar({
    super.key,
    this.onDaySelected,
    this.unavailableDates,
  });

  final void Function(DateTime date)? onDaySelected;
  final List<DateTime>? unavailableDates;

  @override
  State<AvailabilityCalendar> createState() => _AvailabilityCalendarState();
}

class _AvailabilityCalendarState extends State<AvailabilityCalendar> {
  late DateTime _focusedMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday % 7;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
        boxShadow: AppThemeData.shadowCard,
      ),
      child: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          _buildWeekdayHeaders(context),
          const SizedBox(height: 8),
          Wrap(
            children: [
              for (int i = 0; i < firstWeekday; i++)
                SizedBox(width: (MediaQuery.of(context).size.width - 64) / 7),
              for (int day = 1; day <= daysInMonth; day++) ...[
                _buildDayCell(context, day, todayDate),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = AppTheme.of(context);
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return Row(
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
            });
          },
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: Text(
            '${months[_focusedMonth.month - 1]} ${_focusedMonth.year}',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: theme.primaryText,
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
            });
          },
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaders(BuildContext context) {
    final theme = AppTheme.of(context);
    const headers = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      children: headers.map((h) => Expanded(
        child: Text(
          h,
          textAlign: TextAlign.center,
          style: theme.bodySmall.override(
            fontWeight: FontWeight.w600,
            color: theme.textTertiary,
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildDayCell(BuildContext context, int day, DateTime today) {
    final theme = AppTheme.of(context);
    final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
    final isToday = date == today;
    final isSelected = _selectedDate == date;
    final isUnavailable = widget.unavailableDates?.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day) ?? false;
    final cellWidth = (MediaQuery.of(context).size.width - 64) / 7;

    return SizedBox(
      width: cellWidth,
      height: 42,
      child: GestureDetector(
        onTap: isUnavailable ? null : () {
          setState(() => _selectedDate = date);
          widget.onDaySelected?.call(date);
        },
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.primary
                : isToday
                    ? theme.primary.withValues(alpha: 0.1)
                    : null,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            '$day',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
              color: isSelected
                  ? Colors.white
                  : isUnavailable
                      ? theme.textTertiary
                      : theme.primaryText,
            ),
          ),
        ),
      ),
    );
  }
}
