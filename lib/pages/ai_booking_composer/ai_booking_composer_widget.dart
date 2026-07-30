import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_util.dart';
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
        appBar: AppBar(
          backgroundColor: theme.primaryBackground,
          title: Text(
            'AI Booking Composer',
            style: theme.titleLarge,
          ),
          centerTitle: true,
          elevation: 0,
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
                        'Describe what you need',
                        style: theme.titleMedium.override(
                          fontWeight: FontWeight.w600,
                          color: theme.primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _model.promptController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText:
                              'e.g., I need a plumber to fix a leaking pipe under my kitchen sink',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            color: theme.textTertiary,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: theme.secondaryBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        style: GoogleFonts.plusJakartaSans(
                          color: theme.primaryText,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton.icon(
                          onPressed: _model.isLoading
                              ? null
                              : () async {
                                  await _model.composeBooking();
                                  safeSetState(() {});
                                },
                          icon: _model.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.auto_awesome_rounded),
                          label: Text(
                            _model.isLoading ? 'Analyzing...' : 'Compose Booking',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
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
          'Could not extract booking details. Please try again with more specific information.',
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
            'Extracted Details',
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
                theme, 'Budget', 'â‚±${data['estimated_budget']}'),
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
