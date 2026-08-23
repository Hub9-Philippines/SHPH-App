import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/services/tracking_service.dart';
import 'eta_tracking_widget.dart' show EtaTrackingWidget;

class EtaTrackingModel extends FlutterFlowModel<EtaTrackingWidget> {
  Map<String, dynamic>? trackingData;
  bool isLoading = true;
  bool isExpired = false;

  @override
  void initState(BuildContext context) {}

  Future<void> loadTracking(String token) async {
    isLoading = true;
    try {
      trackingData = await TrackingService.instance.getEta(token);
      if (trackingData == null) {
        isExpired = true;
      }
    } finally {
      isLoading = false;
    }
  }

  @override
  void dispose() {}
}
