import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/components/cupertino_ui/app_button.dart';
import '/components/cupertino_ui/app_text_field.dart';
import '/components/cupertino_ui/cupertino_page_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/l10n/app_localizations.dart';
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

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  String _rpCategoryLabel(String cat) => switch (cat) {
        'Booking' => _l10n.rpCategoryBooking,
        'Payment' => _l10n.rpCategoryPayment,
        'Account' => _l10n.rpCategoryAccount,
        _ => _l10n.rpCategoryOther,
      };

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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CupertinoPageHeader(
          backgroundColor: theme.primaryBackground,
          title: _l10n.rpTitle,
          titleStyle: theme.titleMedium,
        ),
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
                    Text(_l10n.rpTicketSubmitted,
                        style: theme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      _l10n.rpWillRespond,
                      style: theme.bodyMedium.copyWith(
                          color: theme.secondaryText),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      onPressed: () => context.pop(),
                      backgroundColor: theme.primary,
                      child: Text(_l10n.rpBack),
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
                      Text(_l10n.rpCategory, style: theme.titleSmall),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _model.category,
                        items: _categories
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(_rpCategoryLabel(c)),
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
                      Text(_l10n.rpDescribeIssue,
                          style: theme.titleSmall),
                      const SizedBox(height: 8),
                      AppTextField(
                        controller: _messageCtrl,
                        maxLines: 5,
                        maxLength: 2000,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        placeholder: _l10n.rpPlaceholder,
                        radius: 8,
                        onChanged: (v) {
                          _model.message = v;
                          safeSetState(() {});
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          onPressed: _model.message.length >= 10 &&
                                  !_model.isSubmitting
                              ? () async {
                                  await _model.submit();
                                  if (mounted) safeSetState(() {});
                                }
                              : null,
                          backgroundColor: theme.primary,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                          loading: _model.isSubmitting,
                          child: Text(_l10n.rpSubmit),
                        ),
                      ),
                      if (_model.message.isNotEmpty &&
                          _model.message.length < 10)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _l10n.rpMinChars,
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
