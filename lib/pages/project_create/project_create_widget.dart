import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import 'project_create_model.dart';

export 'project_create_model.dart';

class ProjectCreateWidget extends StatefulWidget {
  const ProjectCreateWidget({super.key});

  static String routeName = 'ProjectCreate';
  static String routePath = '/projects/create';

  @override
  State<ProjectCreateWidget> createState() => _ProjectCreateWidgetState();
}

class _ProjectCreateWidgetState extends State<ProjectCreateWidget> {
  late ProjectCreateModel _model;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, ProjectCreateModel.new);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final isValid = _model.title.isNotEmpty &&
        _model.description.isNotEmpty &&
        _model.category != null;

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        title: Text('Create Project', style: theme.titleMedium),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.border, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                  onChanged: (v) => _model.title = v,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descCtrl,
                  maxLines: 4,
                  decoration:
                      const InputDecoration(labelText: 'Description'),
                  onChanged: (v) => _model.description = v,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: _model.category,
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Cleaning')),
                    DropdownMenuItem(value: 2, child: Text('Plumbing')),
                    DropdownMenuItem(value: 3, child: Text('Electrical')),
                    DropdownMenuItem(
                        value: 4, child: Text('Handyman')),
                  ],
                  onChanged: (v) =>
                      setState(() => _model.category = v),
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('B2B Project'),
                  value: _model.isB2b,
                  onChanged: (v) =>
                      setState(() => _model.isB2b = v),
                  activeColor: theme.primary,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: !isValid || _model.isSubmitting
                        ? null
                        : () async {
                            final result = await _model.submit();
                            if (mounted) {
                              if (result != null &&
                                  result['id'] != null) {
                                context.replace(
                                    '/projects/${result['id']}');
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Failed to create project')),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _model.isSubmitting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: theme.onPrimary),
                          )
                        : const Text('Create Project'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
