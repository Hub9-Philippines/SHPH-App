import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/services/disputes_service.dart';
import 'disputes_widget.dart' show DisputesWidget;

class DisputesModel extends FlutterFlowModel<DisputesWidget> {
  List<Map<String, dynamic>> disputes = [];
  bool isLoading = true;

  @override
  void initState(BuildContext context) {}

  Future<void> loadDisputes() async {
    isLoading = true;
    try {
      disputes = await DisputesService.instance.getDisputes();
    } finally {
      isLoading = false;
    }
  }

  @override
  void dispose() {}
}
