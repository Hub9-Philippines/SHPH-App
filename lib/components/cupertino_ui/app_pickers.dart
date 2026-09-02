import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';

/// iOS-style date picker presented in a rounded modal sheet.
/// Mirrors Material's `showDatePicker` signature; returns the picked date or
/// `null` when cancelled.
Future<DateTime?> showAppDatePicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  CupertinoDatePickerMode mode = CupertinoDatePickerMode.date,
}) {
  return showCupertinoModalPopup<DateTime>(
    context: context,
    builder: (_) => _DatePickerSheet(
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
      mode: mode,
    ),
  );
}

/// iOS-style time picker presented in a rounded modal sheet.
/// Returns the picked time or `null` when cancelled.
Future<TimeOfDay?> showAppTimePicker({
  required BuildContext context,
  TimeOfDay? initialTime,
}) {
  final initial = initialTime ?? TimeOfDay.now();
  return showCupertinoModalPopup<TimeOfDay>(
    context: context,
    builder: (_) => _TimePickerSheet(initial: initial),
  );
}

class _PickerSheetBase extends StatelessWidget {
  const _PickerSheetBase({
    required this.child,
    required this.onCancel,
    required this.onDone,
    required this.canSubmit,
  });

  final Widget child;
  final bool canSubmit;
  final VoidCallback onCancel;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final data = AppTheme.of(context);
    final _l10n = AppLocalizations.of(context)!;
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: data.primaryBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: onCancel,
                    child: Text(_l10n.ccCancel),
                  ),
                  CupertinoButton(
                    onPressed: canSubmit ? onDone : null,
                    child: Text(_l10n.ccDone),
                  ),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _DatePickerSheet extends StatefulWidget {
  const _DatePickerSheet({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.mode,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final CupertinoDatePickerMode mode;

  @override
  State<_DatePickerSheet> createState() => _DatePickerSheetState();
}

class _DatePickerSheetState extends State<_DatePickerSheet> {
  late DateTime _picked = widget.initialDate;

  @override
  Widget build(BuildContext context) {
    return _PickerSheetBase(
      canSubmit: true,
      onCancel: () => Navigator.of(context).pop(),
      onDone: () => Navigator.of(context).pop(_picked),
      child: CupertinoDatePicker(
        mode: widget.mode,
        initialDateTime: _picked,
        minimumDate: widget.firstDate,
        maximumDate: widget.lastDate,
        onDateTimeChanged: (value) => setState(() => _picked = value),
      ),
    );
  }
}

class _TimePickerSheet extends StatefulWidget {
  const _TimePickerSheet({required this.initial});

  final TimeOfDay initial;

  @override
  State<_TimePickerSheet> createState() => _TimePickerSheetState();
}

class _TimePickerSheetState extends State<_TimePickerSheet> {
  late Duration _picked =
      Duration(hours: widget.initial.hour, minutes: widget.initial.minute);

  @override
  Widget build(BuildContext context) {
    return _PickerSheetBase(
      canSubmit: true,
      onCancel: () => Navigator.of(context).pop(),
      onDone: () {
        final time = TimeOfDay(
          hour: _picked.inHours % 24,
          minute: _picked.inMinutes % 60,
        );
        Navigator.of(context).pop(time);
      },
      child: CupertinoTimerPicker(
        mode: CupertinoTimerPickerMode.hm,
        initialTimerDuration: _picked,
        onTimerDurationChanged: (value) => setState(() => _picked = value),
      ),
    );
  }
}