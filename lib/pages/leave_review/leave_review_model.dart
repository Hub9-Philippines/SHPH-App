import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'leave_review_widget.dart' show LeaveReviewWidget;

class LeaveReviewModel extends FlutterFlowModel<LeaveReviewWidget> {
  int rating = 0;
  bool isSubmitting = false;

  late TextEditingController commentController;
  FocusNode? commentFocusNode;

  @override
  void initState(BuildContext context) {
    commentController = TextEditingController();
    commentFocusNode = FocusNode();
  }

  @override
  void dispose() {
    commentController.dispose();
    commentFocusNode?.dispose();
  }
}
