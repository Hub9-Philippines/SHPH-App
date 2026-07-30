import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import 'report_problem_model.dart';

export 'report_problem_model.dart';

class ReportProblemWidget extends StatefulWidget {
  const ReportProblemWidget({super.key});

  static String routeName = 'ReportProblem';
  static String routePath = '/report-problem';

  @override
  State<ReportProblemWidget> createState() => _ReportProblemWidgetState();
}

class _ReportProblemWidgetState extends State<ReportProblemWidget> {
  late ReportProblemModel _model;
  final _messageCtrl = TextEditingController();

  static const _categories = [
    'Booking',
    'Payment',
    'Account',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, ReportProblemModel.new);
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        title: Text('Report a Problem', style: theme.titleMedium),
        centerTitle: true,
        elevation: 0,
      ),
      body: _model.success == true
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle,
                        size: 64, color: theme.success),
                    const SizedBox(height: 16),
                    Text('Ticket Submitted',
                        style: theme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      'We\'ll get back to you as soon as possible.',
                      style: theme.bodyMedium.copyWith(
                          color: theme.secondaryText),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                      ),
                      child: const Text('Back'),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: theme.border, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Category', style: theme.titleSmall),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _model.category,
                        items: _categories
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _model.category = v ?? 'Other'),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Describe your issue',
                          style: theme.titleSmall),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _messageCtrl,
                        maxLines: 5,
                        maxLength: 2000,
                        decoration: InputDecoration(
                          hintText:
                              'Tell us what happened... (min 10 characters)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (v) {
                          _model.message = v;
                          safeSetState(() {});
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _model.message.length >= 10 &&
                                  !_model.isSubmitting
                              ? () async {
                                  await _model.submit();
                                  if (mounted) safeSetState(() {});
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primary,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                          ),
                          child: _model.isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white),
                                )
                              : const Text('Submit Ticket'),
                        ),
                      ),
                      if (_model.message.isNotEmpty &&
                          _model.message.length < 10)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Please provide at least 10 characters',
                            style: theme.bodySmall
                                .copyWith(color: theme.error),
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
