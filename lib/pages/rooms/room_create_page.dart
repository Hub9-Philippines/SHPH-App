import 'package:flutter/material.dart';

import '/api/models/category.dart';
import '/api/resources/rooms_api.dart';
import '/api/resources/services_api.dart';
import '/theme/app_theme.dart';

/// Create a new group ROOM (SHPH-133).
///
/// Mirrors `shph-app/src/views/services/RoomCreatePage.vue`. Backed by
/// `ShphRoomsApi.create()` → POST `/api/services/rooms/`. Requires KYC
/// approval on the backend (IsKycApproved permission).
class RoomCreatePage extends StatefulWidget {
  const RoomCreatePage({super.key});

  static String routeName = 'RoomCreate';
  static String routePath = '/rooms/new';

  @override
  State<RoomCreatePage> createState() => _RoomCreatePageState();
}

class _RoomCreatePageState extends State<RoomCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _menuCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _headsCtrl = TextEditingController(text: '2');
  final _priceCtrl = TextEditingController();

  List<ShphCategory> _categories = [];
  ShphCategory? _selectedCategory;
  DateTime? _eventDate;
  TimeOfDay? _eventTime;
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
    _menuCtrl.dispose();
    _locationCtrl.dispose();
    _headsCtrl.dispose();
    _priceCtrl.dispose();
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _eventDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _eventTime = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      setState(() => _errorMessage = 'Please select a category');
      return;
    }
    if (_eventDate == null || _eventTime == null) {
      setState(() => _errorMessage = 'Please pick an event date and time');
      return;
    }
    final heads = int.tryParse(_headsCtrl.text);
    final price = double.tryParse(_priceCtrl.text);
    if (heads == null || heads < 2) {
      setState(() => _errorMessage = 'Heads required must be at least 2');
      return;
    }
    if (price == null || price <= 0) {
      setState(() => _errorMessage = 'Price per head must be greater than 0');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await ShphRoomsApi.instance.create({
        'category': _selectedCategory!.id,
        'title': _titleCtrl.text.trim(),
        'description': _descriptionCtrl.text.trim(),
        'menu_or_service': _menuCtrl.text.trim(),
        'event_date':
            '${_eventDate!.year}-${_eventDate!.month.toString().padLeft(2, '0')}-${_eventDate!.day.toString().padLeft(2, '0')}',
        'event_time':
            '${_eventTime!.hour.toString().padLeft(2, '0')}:${_eventTime!.minute.toString().padLeft(2, '0')}',
        'event_location': _locationCtrl.text.trim(),
        'heads_required': heads,
        'price_per_head': price,
      });
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = 'Failed to create room: $e';
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
        title: Text('New Room',
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
                      hintText: 'e.g. Saturday catering for 8 pax',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel(theme: theme, text: 'Category'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<ShphCategory>(
                    initialValue: _selectedCategory,
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
                  const SizedBox(height: 16),
                  _FieldLabel(theme: theme, text: 'Description'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _descriptionCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'What is this room for?',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel(theme: theme, text: 'Menu / Service details'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _menuCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Items, packages, or service scope',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _DateButton(
                          label: 'Event date',
                          value: _eventDate == null
                              ? null
                              : '${_eventDate!.year}-${_eventDate!.month.toString().padLeft(2, '0')}-${_eventDate!.day.toString().padLeft(2, '0')}',
                          onTap: _pickDate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DateButton(
                          label: 'Event time',
                          value: _eventTime == null
                              ? null
                              : '${_eventTime!.hour.toString().padLeft(2, '0')}:${_eventTime!.minute.toString().padLeft(2, '0')}',
                          onTap: _pickTime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel(theme: theme, text: 'Event location'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _locationCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Address or venue',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _headsCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Heads required',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _priceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Price / head (PHP)',
                            prefixText: 'PHP ',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                    ],
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
                    label: Text(_isSubmitting ? 'Creating…' : 'Create Room'),
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

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          value ?? 'Pick',
          style: theme.bodyMedium.override(
            color: value == null ? theme.secondaryText : null,
          ),
        ),
      ),
    );
  }
}
