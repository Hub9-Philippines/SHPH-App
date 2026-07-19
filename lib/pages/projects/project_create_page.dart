import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/api/models/category.dart';
import '/api/resources/services_api.dart';
import '/services/projects_controller.dart';

class ProjectCreatePage extends StatefulWidget {
  const ProjectCreatePage({super.key});

  static const routeName = 'ProjectCreate';
  static const routePath = '/projects/new';

  @override
  State<ProjectCreatePage> createState() => _ProjectCreatePageState();
}

class _ProjectCreatePageState extends State<ProjectCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<ShphCategory> _categories = const [];
  int? _categoryId;
  bool _isB2b = false;
  bool _loadingCategories = true;
  String? _categoryError;

  @override
  void initState() {
    super.initState();
    unawaited(_loadCategories());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final response = await ShphServicesApi.instance.listCategories();
      if (mounted) {
        setState(() {
          _categories = response.results.where((item) => item.id > 0).toList();
          _loadingCategories = false;
          _categoryError = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingCategories = false;
          _categoryError = 'Unable to load project categories.';
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final categoryId = _categoryId;
    if (categoryId == null) {
      setState(() => _categoryError = 'Select a project category.');
      return;
    }
    final created = await context.read<ProjectsController>().create({
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'category': categoryId,
      'is_b2b': _isB2b,
    });
    if (created != null && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProjectsController>();
    return Scaffold(
      appBar: AppBar(title: const Text('New project')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              key: const Key('project_title_field'),
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              maxLength: 200,
              validator: requiredProjectText,
            ),
            TextFormField(
              key: const Key('project_description_field'),
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 5,
              maxLength: 4000,
              validator: requiredProjectText,
            ),
            if (_loadingCategories)
              const LinearProgressIndicator()
            else
              DropdownButtonFormField<int>(
                key: const Key('project_category_field'),
                initialValue: _categoryId,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    )
                    .toList(),
                onChanged: controller.isBusy
                    ? null
                    : (value) => setState(() => _categoryId = value),
              ),
            if (_categoryError != null) ...[
              const SizedBox(height: 8),
              Text(_categoryError!, style: const TextStyle(color: Colors.red)),
              if (_categories.isEmpty)
                TextButton(
                  onPressed: _loadCategories,
                  child: const Text('Retry categories'),
                ),
            ],
            SwitchListTile(
              title: const Text('Business project'),
              value: _isB2b,
              onChanged: controller.isBusy
                  ? null
                  : (value) => setState(() => _isB2b = value),
            ),
            if (controller.errorMessage != null)
              Text(
                controller.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('project_submit_btn'),
              onPressed:
                  controller.isBusy || _loadingCategories ? null : _submit,
              child: Text(controller.isBusy ? 'Creating…' : 'Create project'),
            ),
          ],
        ),
      ),
    );
  }
}

String? requiredProjectText(String? value) =>
    value == null || value.trim().isEmpty ? 'Required' : null;
