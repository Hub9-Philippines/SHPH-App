import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import 'room_create_model.dart';

export 'room_create_model.dart';

class RoomCreateWidget extends StatefulWidget {
  const RoomCreateWidget({super.key});

  static String routeName = 'RoomCreate';
  static String routePath = '/rooms/create';

  @override
  State<RoomCreateWidget> createState() => _RoomCreateWidgetState();
}

class _RoomCreateWidgetState extends State<RoomCreateWidget> {
  late RoomCreateModel _model;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _menuCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _headsCtrl = TextEditingController(text: '3');
  final _priceCtrl = TextEditingController(text: '100.00');

  @override
  void initState() {
    super.initState();
    _model = createModel(context, RoomCreateModel.new);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _menuCtrl.dispose();
    _locationCtrl.dispose();
    _headsCtrl.dispose();
    _priceCtrl.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _model.eventDate =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}');
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _model.eventTime =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final isValid = _model.title.isNotEmpty &&
        _model.eventDate.isNotEmpty &&
        _model.eventTime.isNotEmpty &&
        _model.headsRequired >= 2 &&
        _model.pricePerHead > 0;

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        title: Text('Create Room', style: theme.titleMedium),
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
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                  onChanged: (v) => _model.description = v,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _menuCtrl,
                  maxLines: 2,
                  decoration:
                      const InputDecoration(labelText: 'Menu / Service'),
                  onChanged: (v) => _model.menuOrService = v,
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Event Date'),
                    child: Text(_model.eventDate.isEmpty
                        ? 'Tap to select'
                        : _model.eventDate),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickTime,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Event Time'),
                    child: Text(_model.eventTime.isEmpty
                        ? 'Tap to select'
                        : _model.eventTime),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _locationCtrl,
                  decoration: const InputDecoration(labelText: 'Location'),
                  onChanged: (v) => _model.eventLocation = v,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _headsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Heads Required'),
                  onChanged: (v) =>
                      _model.headsRequired = int.tryParse(v) ?? 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _priceCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Price per Head'),
                  onChanged: (v) =>
                      _model.pricePerHead = double.tryParse(v) ?? 100.0,
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
                              if (result != null && result['id'] != null) {
                                context.replace('/rooms/${result['id']}');
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Failed to create room')),
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
                        : const Text('Create Room'),
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
