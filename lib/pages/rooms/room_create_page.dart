import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/services/rooms_controller.dart';

class RoomCreatePage extends StatefulWidget {
  const RoomCreatePage({super.key});
  static const routeName = 'RoomCreate';
  static const routePath = '/rooms/new';

  @override
  State<RoomCreatePage> createState() => _RoomCreatePageState();
}

class _RoomCreatePageState extends State<RoomCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _category = TextEditingController();
  final _title = TextEditingController();
  final _date = TextEditingController();
  final _time = TextEditingController();
  final _heads = TextEditingController(text: '3');
  final _price = TextEditingController(text: '100.00');

  @override
  void dispose() {
    for (final controller in [
      _category,
      _title,
      _date,
      _time,
      _heads,
      _price
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final room = await context.read<RoomsController>().create({
      'category': int.tryParse(_category.text.trim()),
      'title': _title.text.trim(),
      'event_date': _date.text.trim(),
      'event_time': _time.text.trim(),
      'heads_required': int.tryParse(_heads.text.trim()),
      'price_per_head': _price.text.trim(),
    });
    if (room != null && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rooms = context.watch<RoomsController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Create room')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field(_category, 'Category ID', numeric: true),
            _field(_title, 'Title'),
            _field(_date, 'Event date (YYYY-MM-DD)'),
            _field(_time, 'Event time (HH:MM)'),
            _field(_heads, 'Heads required', numeric: true),
            _field(_price, 'Price per head', numeric: true),
            if (rooms.errorMessage != null)
              Text(rooms.errorMessage!,
                  style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: rooms.isBusy ? null : _submit,
              child: const Text('Create room'),
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
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label),
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Required' : null,
      );
}
