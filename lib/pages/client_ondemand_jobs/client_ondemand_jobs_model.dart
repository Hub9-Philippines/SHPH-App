import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/services/ondemand_jobs_service.dart';
import 'client_ondemand_jobs_widget.dart' show ClientOnDemandJobsWidget;

class ClientOnDemandJobsModel
    extends FlutterFlowModel<ClientOnDemandJobsWidget> {
  List<Map<String, dynamic>> jobs = [];
  bool isLoading = true;

  @override
  void initState(BuildContext context) {}

  Future<void> loadJobs() async {
    isLoading = true;
    try {
      jobs = await OnDemandJobsService.instance.getClientJobs();
    } finally {
      isLoading = false;
    }
  }

  @override
  void dispose() {}
}
