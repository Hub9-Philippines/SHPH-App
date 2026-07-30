import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/services/kyc_hub_service.dart';
import 'kyc_hub_widget.dart' show KycHubWidget;

class KycHubModel extends FlutterFlowModel<KycHubWidget> {
  Map<String, dynamic> status = {};
  bool isLoading = true;

  @override
  void initState(BuildContext context) {}

  Future<void> loadStatus() async {
    isLoading = true;
    try {
      status = await KycHubService.instance.getStatus();
    } finally {
      isLoading = false;
    }
  }

  @override
  void dispose() {}
}
