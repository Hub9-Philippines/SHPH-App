import 'package:flutter/material.dart';

import '/api/models/category.dart';
import '/api/resources/projects_api.dart';
import '/api/resources/services_api.dart';
import '/theme/app_theme.dart';

/// Create a new Project Demand (SHPH-134).
///
/// Mirrors `shph-app/src/views/services/ProjectCreatePage.vue`. Backed by
/// `ShphProjectsApi.create()` → POST `/api/projects/`.
class ProjectCreatePage extends StatefulWidget {
  const ProjectCreatePage({super.key});

  static String routeName = 'ProjectCreate';
  static String routePath = '/projects/new';

  @override
  State<ProjectCreatePage> createState() => _ProjectCreatePageState();
}

class _ProjectCreatePageState extends State<ProjectCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  List<ShphCategory> _categories = [];
  ShphCategory? _selectedCategory;
  bool _isB2b = false;
  bool _isSubmitting = false;
  bool _isLoadingCategories = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final response = await ShphServicesApi.instance.listCategories();
      if (mounted) {
        setState(() {
          _categories = response.results;
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
          _errorMessage = 'Failed to load categories: $e';
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      setState(() => _errorMessage = 'Please select a category');
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await ShphProjectsApi.instance.create({
        'title': _titleCtrl.text.trim(),
        'description': _descriptionCtrl.text.trim(),
        'category': _selectedCategory!.id,
        'is_b2b': _isB2b,
      });
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = 'Failed to create project: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text('New Project',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        backgroundColor: theme.primaryBackground,
        elevation: 0,
      ),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: [
                  _FieldLabel(theme: theme, text: 'Title'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Office renovation needing 3 masons',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  _FieldLabel(theme: theme, text: 'Description'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _descriptionCtrl,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText:
                          'Describe the work, scope, location, and any timing constraints. The AI quote engine parses this to suggest role lines.',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  _FieldLabel(theme: theme, text: 'Category'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<ShphCategory>(
                    value: _selectedCategory,
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                    items: _categories
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.name),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v),
                    hint: const Text('Select a category'),
                  ),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    title: Text('B2B project', style: theme.bodyMedium),
                    subtitle: Text(
                      'Mark this as a business-to-business project demand.',
                      style:
                          theme.bodySmall.override(color: theme.secondaryText),
                    ),
                    value: _isB2b,
                    onChanged: (v) => setState(() => _isB2b = v),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(_errorMessage!,
                        style: theme.bodyMedium.override(color: theme.error)),
                  ],
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: Text(_isSubmitting ? 'Creating…' : 'Create Project'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.theme, required this.text});
  final AppThemeData theme;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: theme.bodyMedium.override(fontWeight: FontWeight.w700));
  }
}
