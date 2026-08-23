import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/services/projects_service.dart';
import 'project_create_widget.dart' show ProjectCreateWidget;

class ProjectCreateModel extends FlutterFlowModel<ProjectCreateWidget> {
  String title = '';
  String description = '';
  int? category;
  bool isB2b = false;
  bool isSubmitting = false;

  @override
  void initState(BuildContext context) {}

  Map<String, dynamic> toPayload() => {
        'title': title,
        'description': description,
        'category': category,
        'is_b2b': isB2b,
      };

  Future<Map<String, dynamic>?> submit() async {
    isSubmitting = true;
    try {
      return await ProjectsService.instance.createProject(toPayload());
    } finally {
      isSubmitting = false;
    }
  }

  @override
  void dispose() {}
}
