import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import '/l10n/app_localizations.dart';
import 'reset_link_sent_model.dart';

export 'reset_link_sent_model.dart';

class ResetLinkSentWidget extends StatefulWidget {
  const ResetLinkSentWidget({super.key});

  @override
  State<ResetLinkSentWidget> createState() => _ResetLinkSentWidgetState();
}

class _ResetLinkSentWidgetState extends State<ResetLinkSentWidget> {
  late ResetLinkSentModel _model;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, ResetLinkSentModel.new);
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.of(context).alternate,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppTheme.of(context).success,
                  size: 24,
                ),
                Expanded(
                  child: Text(
                    _l10n.rlsTitle,
                    style: AppTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            fontStyle: AppTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          letterSpacing: 0,
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              AppTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                ),
              ].divide(const SizedBox(width: 12)),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
              child: Text(
                _l10n.rlsBody,
                style: AppTheme.of(context).bodySmall.override(
                      font: GoogleFonts.plusJakartaSans(
                        fontWeight:
                            AppTheme.of(context).bodySmall.fontWeight,
                        fontStyle:
                            AppTheme.of(context).bodySmall.fontStyle,
                      ),
                      color: AppTheme.of(context).secondaryText,
                      letterSpacing: 0,
                      fontWeight:
                          AppTheme.of(context).bodySmall.fontWeight,
                      fontStyle:
                          AppTheme.of(context).bodySmall.fontStyle,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
}
