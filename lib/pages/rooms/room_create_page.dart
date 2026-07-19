import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '/api/models/category.dart';
import '/api/resources/services_api.dart';
import '/services/rooms_controller.dart';
import '/theme/app_theme.dart';

class RoomCreatePage extends StatefulWidget {
  const RoomCreatePage({super.key});
  static const routeName = 'RoomCreate';
  static const routePath = '/rooms/new';

  @override
  State<RoomCreatePage> createState() => _RoomCreatePageState();
}

class _RoomCreatePageState extends State<RoomCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _menu = TextEditingController();
  final _location = TextEditingController();
  final _heads = TextEditingController(text: '3');
  final _price = TextEditingController(text: '100.00');
  List<ShphCategory> _categories = const [];
  int? _categoryId;
  DateTime? _date;
  TimeOfDay? _time;
  String? _categoryError;
  bool _loadingCategories = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadCategories());
  }

  @override
  void dispose() {
    for (final controller in [
      _title,
      _description,
      _menu,
      _location,
      _heads,
      _price,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final result = await ShphServicesApi.instance.listCategories();
      if (mounted) {
        setState(() {
          _categories = result.results.where((item) => item.id > 0).toList();
          _loadingCategories = false;
          _categoryError = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingCategories = false;
          _categoryError = 'Unable to load categories.';
        });
      }
    }
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final value = await showDatePicker(
      context: context,
      firstDate: today,
      lastDate: today.add(const Duration(days: 730)),
      initialDate: _date ?? today,
    );
    if (value != null && mounted) setState(() => _date = value);
  }

  Future<void> _pickTime() async {
    final value = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (value != null && mounted) setState(() => _time = value);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null || _date == null || _time == null) {
      setState(() => _categoryError = 'Select a category, date, and time.');
      return;
    }
    final room = await context.read<RoomsController>().create({
      'category': _categoryId,
      'title': _title.text.trim(),
      'description': _description.text.trim(),
      'menu_or_service': _menu.text.trim(),
      'event_location': _location.text.trim(),
      'event_date': _date!.toIso8601String().split('T').first,
      'event_time':
          '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}',
      'heads_required': int.tryParse(_heads.text.trim()),
      'price_per_head': _price.text.trim(),
    });
    if (room != null && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final rooms = context.watch<RoomsController>();
    final theme = AppTheme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Create service room')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Room details', style: theme.titleLarge),
            const SizedBox(height: 16),
            if (_loadingCategories)
              const LinearProgressIndicator()
            else
              DropdownButtonFormField<int>(
                initialValue: _categoryId,
                decoration: const InputDecoration(
                  labelText: 'Service category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _categories
                    .map((item) => DropdownMenuItem(
                          value: item.id,
                          child: Text(item.name),
                        ))
                    .toList(),
                onChanged: rooms.isBusy
                    ? null
                    : (value) => setState(() => _categoryId = value),
              ),
            if (_categoryError != null) ...[
              Text(_categoryError!, style: TextStyle(color: theme.error)),
              if (_categories.isEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: _loadCategories,
                    child: const Text('Retry categories'),
                  ),
                ),
            ],
            const SizedBox(height: 12),
            _field(_title, 'Room title', icon: Icons.title),
            _field(_description, 'Description', maxLines: 3, required: false),
            _field(_menu, 'Menu or service', required: false),
            _field(_location, 'Event location',
                icon: Icons.location_on_outlined),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: rooms.isBusy ? null : _pickDate,
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(_date == null
                        ? 'Select date'
                        : _date!.toIso8601String().split('T').first),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: rooms.isBusy ? null : _pickTime,
                    icon: const Icon(Icons.schedule_outlined),
                    label: Text(_time?.format(context) ?? 'Select time'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _field(
                    _heads,
                    'People needed',
                    numeric: true,
                    min: 2,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(
                    _price,
                    'Price per person',
                    numeric: true,
                    min: 0.01,
                  ),
                ),
              ],
            ),
            if (rooms.errorMessage != null)
              Text(rooms.errorMessage!, style: TextStyle(color: theme.error)),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: rooms.isBusy ? null : _submit,
              icon: const Icon(Icons.groups_rounded),
              label: Text(rooms.isBusy ? 'Creating…' : 'Create room'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool numeric = false,
    bool required = true,
    int maxLines = 1,
    double? min,
    IconData? icon,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: numeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          inputFormatters: numeric
              ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
              : null,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: icon == null ? null : Icon(icon),
          ),
          validator: (value) {
            final text = value?.trim() ?? '';
            if (required && text.isEmpty) return 'Required';
            if (numeric && text.isNotEmpty && double.tryParse(text) == null) {
              return 'Invalid number';
            }
            if (min != null && (double.tryParse(text) ?? 0) < min) {
              return 'Minimum ${min == min.roundToDouble() ? min.toInt() : min}';
            }
            return null;
          },
        ),
      );
}
