import 'package:flutter/material.dart';

import '/components/cupertino_ui/app_button.dart';
import '/components/cupertino_ui/app_pickers.dart';
import '/components/cupertino_ui/app_text_field.dart';
import '/components/cupertino_ui/cupertino_page_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/l10n/app_localizations.dart';
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

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

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
    final date = await showAppDatePicker(
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
    final time = await showAppTimePicker(
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(44),
        child: CupertinoPageHeader(
          backgroundColor: theme.primaryBackground,
          title: _l10n.rcTitle,
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
                  label: _l10n.rcLabelTitle,
                  onChanged: (v) => _model.title = v,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _descCtrl,
                  maxLines: 3,
                  label: _l10n.rcLabelDescription,
                  onChanged: (v) => _model.description = v,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _menuCtrl,
                  maxLines: 2,
                  label: _l10n.rcLabelMenuService,
                  onChanged: (v) => _model.menuOrService = v,
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: _l10n.rcLabelEventDate),
                    child: Text(_model.eventDate.isEmpty
                        ? _l10n.rcTapToSelect
                        : _model.eventDate),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickTime,
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: _l10n.rcLabelEventTime),
                    child: Text(_model.eventTime.isEmpty
                        ? _l10n.rcTapToSelect
                        : _model.eventTime),
                  ),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _locationCtrl,
                  label: _l10n.rcLabelLocation,
                  onChanged: (v) => _model.eventLocation = v,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _headsCtrl,
                  keyboardType: TextInputType.number,
                  label: _l10n.rcHeadsRequired,
                  onChanged: (v) =>
                      _model.headsRequired = int.tryParse(v) ?? 3,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _priceCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  label: _l10n.rcPricePerHead,
                  onChanged: (v) =>
                      _model.pricePerHead = double.tryParse(v) ?? 100.0,
                ),
                const SizedBox(height: 24),
                AppButton(
                  width: double.infinity,
                  backgroundColor: theme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  loading: _model.isSubmitting,
                  loadingColor: theme.onPrimary,
                  onPressed: !isValid || _model.isSubmitting
                      ? null
                      : () async {
                          final result = await _model.submit();
                          if (mounted) {
                            if (result != null && result['id'] != null) {
                              context.replace('/rooms/${result['id']}');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(_l10n.rcFailedCreate)),
                              );
                            }
                          }
                        },
                  child: Text(_l10n.rcTitle),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
