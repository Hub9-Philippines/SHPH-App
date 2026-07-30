import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/services/projects_service.dart';
import 'project_list_widget.dart' show ProjectListWidget;

class ProjectListModel extends FlutterFlowModel<ProjectListWidget> {
  List<Map<String, dynamic>> projects = [];
  bool isLoading = true;

  @override
  void initState(BuildContext context) {}

  Future<void> loadProjects() async {
    isLoading = true;
    try {
      projects = await ProjectsService.instance.getProjects();
    } finally {
      isLoading = false;
    }
  }

  @override
  void dispose() {}
}
