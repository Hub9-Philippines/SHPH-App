import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/cupertino_ui/app_button.dart';
import '/components/cupertino_ui/app_text_field.dart';
import '/components/cupertino_ui/cupertino_page_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';
import 'ai_booking_composer_model.dart';

export 'ai_booking_composer_model.dart';

class AiBookingComposerWidget extends StatefulWidget {
  const AiBookingComposerWidget({super.key});

  static String routeName = 'AiBookingComposer';
  static String routePath = '/ai-booking-composer';

  @override
  State<AiBookingComposerWidget> createState() =>
      _AiBookingComposerWidgetState();
}

class _AiBookingComposerWidgetState extends State<AiBookingComposerWidget> {
  late AiBookingComposerModel _model;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, AiBookingComposerModel.new);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.primaryBackground,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: CupertinoPageHeader(
            title: _l10n.abcTitle,
            backgroundColor: theme.primaryBackground,
            titleStyle: theme.titleLarge,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _l10n.abcDescribe,
                        style: theme.titleMedium.override(
                          fontWeight: FontWeight.w600,
                          color: theme.primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AppTextField(
                        controller: _model.promptController,
                        maxLines: 5,
                        placeholder:
                            _l10n.abcPlaceholder,
                        placeholderStyle: GoogleFonts.plusJakartaSans(
                          color: theme.textTertiary,
                          fontSize: 14,
                        ),
                        fillColor: theme.secondaryBackground,
                        radius: 12,
                        padding: const EdgeInsets.all(16),
                        style: GoogleFonts.plusJakartaSans(
                          color: theme.primaryText,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        width: double.infinity,
                        height: 48,
                        borderRadius: 12,
                        loading: _model.isLoading,
                        onPressed: _model.isLoading
                            ? null
                            : () async {
                                await _model.composeBooking();
                                safeSetState(() {});
                              },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _model.isLoading
                                  ? _l10n.abcAnalyzing
                                  : _l10n.abcCompose,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_model.bookingData != null) ...[
                        const SizedBox(height: 24),
                        _buildResultCard(context),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context) {
    final theme = AppTheme.of(context);
    final data = _model.bookingData!;
    final hasData = data.values.any((v) => v != null);

    if (!hasData) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _l10n.abcExtractError,
          style: GoogleFonts.plusJakartaSans(
            color: theme.error,
            fontSize: 14,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _l10n.abcExtracted,
            style: theme.titleMedium.override(
              fontWeight: FontWeight.w600,
              color: theme.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          if (data['service_name'] != null)
            _buildDetailRow(
                theme, 'Service', data['service_name']!),
          if (data['description'] != null)
            _buildDetailRow(
                theme, 'Description', data['description']!),
          if (data['estimated_budget'] != null)
            _buildDetailRow(
                theme, 'Budget', '₱${data['estimated_budget']}'),
          if (data['preferred_date'] != null)
            _buildDetailRow(
                theme, 'Date', data['preferred_date']!),
          if (data['preferred_time'] != null)
            _buildDetailRow(
                theme, 'Time', data['preferred_time']!),
          if (data['location_notes'] != null)
            _buildDetailRow(
                theme, 'Location', data['location_notes']!),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      AppThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: theme.secondaryText,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                color: theme.primaryText,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
