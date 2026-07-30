import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/services/report_problem_service.dart';
import 'report_problem_widget.dart' show ReportProblemWidget;

class ReportProblemModel extends FlutterFlowModel<ReportProblemWidget> {
  String category = 'Other';
  String message = '';
  bool isSubmitting = false;
  bool? success;

  @override
  void initState(BuildContext context) {}

  Future<bool> submit() async {
    if (message.length < 10) return false;
    isSubmitting = true;
    try {
      success = await ReportProblemService.instance.submitTicket(
        category: category,
        message: message,
      );
      return success == true;
    } finally {
      isSubmitting = false;
    }
  }

  @override
  void dispose() {}
}
