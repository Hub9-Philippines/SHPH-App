import 'package:flutter/material.dart';

import '/components/cupertino_ui/app_button.dart';
import '/components/cupertino_ui/app_switch.dart';
import '/components/cupertino_ui/app_text_field.dart';
import '/components/cupertino_ui/cupertino_page_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/l10n/app_localizations.dart';
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

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CupertinoPageHeader(
          backgroundColor: theme.primaryBackground,
          title: _l10n.pcTitle,
          titleStyle: theme.titleMedium,
        ),
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
                AppTextField(
                  controller: _titleCtrl,
                  label: _l10n.pcLabelTitle,
                  onChanged: (v) => _model.title = v,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _descCtrl,
                  maxLines: 4,
                  label: _l10n.pcLabelDescription,
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
                    labelText: _l10n.pcLabelCategory,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AppSwitchRow(
                  title: _l10n.pcB2B,
                  value: _model.isB2b,
                  onChanged: (v) =>
                      setState(() => _model.isB2b = v),
                  activeColor: theme.primary,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
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
                                  SnackBar(
                                      content: Text(
                                          _l10n.pcFailedCreate)),
                                );
                              }
                            }
                          },
                    backgroundColor: theme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    loading: _model.isSubmitting,
                    child: Text(_l10n.pcTitle),
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
