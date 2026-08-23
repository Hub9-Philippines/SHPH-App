import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/services/projects_service.dart';
import 'project_detail_widget.dart' show ProjectDetailWidget;

class ProjectDetailModel extends FlutterFlowModel<ProjectDetailWidget> {
  Map<String, dynamic>? project;
  bool isLoading = true;

  @override
  void initState(BuildContext context) {}

  Future<void> loadProject(String id) async {
    isLoading = true;
    try {
      project = await ProjectsService.instance.getProject(id);
    } finally {
      isLoading = false;
    }
  }

  Future<Map<String, dynamic>?> quoteProject() async {
    final id = project?['id']?.toString();
    if (id == null) return null;
    final result = await ProjectsService.instance.quoteProject(id);
    if (result != null) project = result;
    return result;
  }

  Future<bool> cancelProject() async {
    final id = project?['id']?.toString();
    if (id == null) return false;
    final ok = await ProjectsService.instance.cancelProject(id);
    if (ok) project?['status'] = 'cancelled';
    return ok;
  }

  @override
  void dispose() {}
}
