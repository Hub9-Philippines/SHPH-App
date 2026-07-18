import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '/api/resources/support_api.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/logging_service.dart';
import '/theme/app_theme.dart';

class ReportProblemWidget extends StatefulWidget {
  const ReportProblemWidget({super.key});

  static const String routeName = 'ReportProblem';
  static const String routePath = '/report-problem';

  @override
  State<ReportProblemWidget> createState() => _ReportProblemWidgetState();
}

class _ReportProblemWidgetState extends State<ReportProblemWidget> {
  final _formKey = GlobalKey<FormState>();
  String _category = 'other';
  final _messageController = TextEditingController();
  final List<XFile> _attachments = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  final _categories = [
    ('booking', 'Booking'),
    ('payment', 'Payment'),
    ('account', 'Account'),
    ('other', 'Other'),
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      safeSetState(() => _attachments.add(image));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    safeSetState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final files = await Future.wait(
        _attachments.map(
          (x) async => dio.MultipartFile.fromFileSync(
            x.path,
            filename: x.name,
          ),
        ),
      );
      await ShphSupportApi.instance.createTicket(
        category: _category,
        message: _messageController.text.trim(),
        attachments: files.isEmpty ? null : files,
      );
      safeSetState(() {
        _successMessage = 'Ticket submitted. Our team will get back to you.';
        _messageController.clear();
        _attachments.clear();
      });
    } catch (e) {
      LoggingService.error('Failed to submit support ticket', error: e);
      safeSetState(
          () => _errorMessage = 'Failed to submit ticket. Please try again.');
    } finally {
      safeSetState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: theme.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Report a Problem',
          style: theme.titleMedium.override(
            font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Let us know what went wrong',
                  style: theme.displaySmall.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a category and describe the issue. You can attach a screenshot if helpful.',
                  style: theme.bodyMedium.copyWith(color: theme.secondaryText),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: theme.primaryBackground,
                  ),
                  items: _categories
                      .map((c) =>
                          DropdownMenuItem(value: c.$1, child: Text(c.$2)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _category = value ?? 'other'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please select a category'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _messageController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Describe the issue',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: theme.primaryBackground,
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) {
                      return 'Please describe the issue';
                    }
                    if (text.length < 10) {
                      return 'Please provide at least 10 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (_attachments.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children: _attachments
                        .map(
                          (x) => Chip(
                            label: Text(x.name),
                            deleteIcon: const Icon(Icons.close),
                            onDeleted: () =>
                                setState(() => _attachments.remove(x)),
                          ),
                        )
                        .toList(),
                  ),
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.image, color: theme.primary),
                  label: Text(
                    'Attach screenshot',
                    style: theme.bodyMedium.copyWith(color: theme.primary),
                  ),
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null)
                  Text(_errorMessage!,
                      style: theme.bodyMedium.copyWith(color: theme.error)),
                if (_successMessage != null)
                  Text(_successMessage!,
                      style: theme.bodyMedium.copyWith(color: theme.success)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary,
                      foregroundColor: theme.info,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text('Submit', style: theme.titleSmall),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
