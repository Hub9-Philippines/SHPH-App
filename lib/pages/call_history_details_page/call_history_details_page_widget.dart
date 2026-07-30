import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/theme/app_theme.dart';
import 'call_history_details_page_model.dart';

export 'call_history_details_page_model.dart';

class CallHistoryDetailsPageWidget extends StatefulWidget {
  const CallHistoryDetailsPageWidget({
    super.key,
    this.callId,
    this.providerName,
    this.providerPhoto,
    this.callType,
    this.callStatus,
    this.durationSeconds,
    this.createdAt,
  });

  final String? callId;
  final String? providerName;
  final String? providerPhoto;
  final String? callType;
  final String? callStatus;
  final int? durationSeconds;
  final DateTime? createdAt;

  static String routeName = 'CallHistoryDetailsPage';
  static String routePath = '/call-details/:callId';

  @override
  State<CallHistoryDetailsPageWidget> createState() => _CallHistoryDetailsPageWidgetState();
}

class _CallHistoryDetailsPageWidgetState extends State<CallHistoryDetailsPageWidget> {
  late CallHistoryDetailsPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, CallHistoryDetailsPageModel.new);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _formatDuration(int? seconds) {
    if (seconds == null || seconds == 0) return '0:00';
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: AppTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          leading: wrapWithModel(
            model: _model.backButtonModel,
            updateCallback: () => safeSetState(() {}),
            child: const BackButtonWidget(),
          ),
          title: Text(
            'Call Details',
            style: AppTheme.of(context).titleLarge.override(
                  font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                ),
          ),
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Provider Info Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 24),
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).secondaryBackground,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        color: Colors.black.withValues(alpha: 0.1),
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.of(context).primary,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: Image.network(
                              widget.providerPhoto ?? 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
                            ).image,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.providerName ?? 'Unknown Provider',
                        style: AppTheme.of(context).headlineMedium.override(
                              font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.callType == 'video' ? Icons.videocam : Icons.phone,
                            size: 16,
                            color: AppTheme.of(context).secondaryText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.callType?.toUpperCase() ?? 'VOICE',
                            style: AppTheme.of(context).bodyMedium.override(
                                  color: AppTheme.of(context).secondaryText,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Call Details
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 20),
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4,
                          color: Colors.black.withValues(alpha: 0.1),
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Call Information',
                          style: AppTheme.of(context).titleMedium.override(
                                font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                              ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          context,
                          'Status',
                          widget.callStatus?.toUpperCase() ?? 'UNKNOWN',
                          statusColor: widget.callStatus == 'missed'
                              ? AppTheme.of(context).error
                              : widget.callStatus == 'incoming'
                                  ? AppTheme.of(context).success
                                  : AppTheme.of(context).primary,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          context,
                          'Duration',
                          _formatDuration(widget.durationSeconds),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          context,
                          'Date & Time',
                          _formatDateTime(widget.createdAt),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Action Buttons
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: FFButtonWidget(
                          onPressed: () {
                            // Call back action
                            debugPrint('Call back: ${widget.providerName}');
                          },
                          text: 'Call Back',
                          icon: const Icon(
                            Icons.phone,
                            size: 20,
                          ),
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 50,
                            padding: EdgeInsetsDirectional.zero,
                            iconPadding: EdgeInsetsDirectional.zero,
                            color: AppTheme.of(context).primary,
                            textStyle: AppTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                                  color: Colors.white,
                                ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FFButtonWidget(
                          onPressed: () {
                            // Message action
                            debugPrint('Message: ${widget.providerName}');
                          },
                          text: 'Message',
                          icon: const Icon(
                            Icons.chat_bubble_outline,
                            size: 20,
                          ),
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 50,
                            padding: EdgeInsetsDirectional.zero,
                            iconPadding: EdgeInsetsDirectional.zero,
                            color: AppTheme.of(context).secondaryBackground,
                            textStyle: AppTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                                  color: AppTheme.of(context).primaryText,
                                ),
                            borderSide: BorderSide(
                              color: AppTheme.of(context).primary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    Color? statusColor,
  }) => Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.of(context).bodyMedium.override(
                color: AppTheme.of(context).secondaryText,
              ),
        ),
        Text(
          value,
          style: AppTheme.of(context).bodyMedium.override(
                color: statusColor ?? AppTheme.of(context).primaryText,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
}
