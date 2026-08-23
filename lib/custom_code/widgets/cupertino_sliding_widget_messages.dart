// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/theme/app_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter/cupertino.dart' as cupertino;
import 'package:google_fonts/google_fonts.dart'; // Direct Google Fonts access

class CupertinoSlidingWidgetMessages extends StatefulWidget {
  const CupertinoSlidingWidgetMessages({
    super.key,
    this.width,
    this.height,
    required this.initialIndex,
    required this.onChanged,
  });

  final double? width;
  final double? height;
  final int initialIndex;
  final Future<dynamic> Function(int index) onChanged;

  @override
  State<CupertinoSlidingWidgetMessages> createState() =>
      _CupertinoSlidingWidgetMessagesState();
}

class _CupertinoSlidingWidgetMessagesState
    extends State<CupertinoSlidingWidgetMessages> {
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    // 1. Initialize with the value passed from the parent
    _currentPage = widget.initialIndex;
  }

  // 2. THIS IS THE MAGIC: Listen for swipe changes from the parent PageView
  @override
  void didUpdateWidget(covariant CupertinoSlidingWidgetMessages oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the parent passes down a new index (because the user swiped), update the UI
    if (widget.initialIndex != oldWidget.initialIndex) {
      setState(() {
        _currentPage = widget.initialIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppTheme.of(context).primary;
    return SizedBox(
      width: widget.width ?? 320,
      height: widget.height ?? 50,
      child: cupertino.CupertinoSlidingSegmentedControl<int>(
        backgroundColor: AppTheme.of(context).surfaceAlt,
        thumbColor: AppTheme.of(context).primaryBackground,
        groupValue: _currentPage,
        children: {
          0: _buildSegment("Chats", 0, primary),
          1: _buildSegment("Calls history", 1, primary),
        },
        onValueChanged: (int? value) {
          // 3. Only trigger if the value actually changes
          if (value != null && value != _currentPage) {
            setState(() => _currentPage = value);
            widget.onChanged(value);
          }
        },
      ),
    );
  }

  Widget _buildSegment(String label, int index, Color primary) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          color: _currentPage == index ? primary : const Color(0xFF757575),
        ),
      ),
    );
  }
}
