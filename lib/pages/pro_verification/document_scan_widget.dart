import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '/auth/base_auth_user_provider.dart';
import '/api/resources/kyc_api.dart' show KycDocumentFile;
import '/components/screen_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/services/auth_service.dart';
import '/services/kyc_submission_service.dart';
import '/theme/app_theme.dart';
import 'document_scan_model.dart';

export 'document_scan_model.dart';

class DocumentScanWidget extends StatefulWidget {
  const DocumentScanWidget({super.key});

  static String routeName = 'DocumentScan';
  static String routePath = '/pro-verify-doc';

  @override
  State<DocumentScanWidget> createState() => _DocumentScanWidgetState();
}

class _DocumentScanWidgetState extends State<DocumentScanWidget> {
  late DocumentScanModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ImagePicker _imagePicker = ImagePicker();
  late final KycSubmissionService _kyc = KycSubmissionService.instance;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, DocumentScanModel.new);
    _kyc.submitterRole =
        AuthService.instance.isProvider ? 'provider' : 'customer';
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _pickImage(KycDocumentField field, ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 2048,
        maxHeight: 2048,
      );
      if (image != null) {
        final bytes = await File(image.path).readAsBytes();
        final name = '${DateTime.now().millisecondsSinceEpoch}_${field.name}.jpg';
        _kyc.setDocument(field, KycDocumentFile(bytes, name));
        safeSetState(() {});
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.of(context).error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _continueToLiveness() {
    if (!_kyc.hasRequiredDocuments) return;
    context.pushNamedAuth(
      FaceVerificationScreen.routeName,
      mounted,
      ignoreRedirect: true,
    );
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
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: ScreenHeader(title: 'Document Verification'),
                  ),
                  _buildProgressIndicator(),
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildDocSection(
                    field: KycDocumentField.idFront,
                    title: 'ID Front',
                    subtitle: 'Front side of your government-issued ID',
                    required: true,
                  ),
                  const SizedBox(height: 12),
                  _buildDocSection(
                    field: KycDocumentField.idBack,
                    title: 'ID Back',
                    subtitle: 'Back side of your government-issued ID',
                    required: true,
                  ),
                  if (_kyc.submitterRole == 'provider') ...[
                    const SizedBox(height: 12),
                    _buildDocSection(
                      field: KycDocumentField.nbiClearance,
                      title: 'NBI Clearance',
                      subtitle: 'Required for service providers',
                      required: true,
                    ),
                    const SizedBox(height: 12),
                    _buildDocSection(
                      field: KycDocumentField.portfolio,
                      title: 'Portfolio (optional)',
                      subtitle: 'Showcase your past work',
                      required: false,
                    ),
                    const SizedBox(height: 12),
                    _buildDocSection(
                      field: KycDocumentField.resume,
                      title: 'Resume (optional)',
                      subtitle: 'Your professional background',
                      required: false,
                    ),
                  ],
                  const SizedBox(height: 24),
                  _buildContinueButton(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildProgressIndicator() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit_document,
                    color: AppTheme.of(context).onPrimary,
                    size: 16,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 2,
                    color: AppTheme.of(context).primary.withValues(alpha: 0.3),
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).secondaryBackground,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.of(context).alternate,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.face,
                    color: AppTheme.of(context).secondaryText,
                    size: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Step 1 of 2: Document Upload',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppTheme.of(context).primary,
              ),
            ),
          ],
        ),
      );

  Widget _buildHeader() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Your Government ID',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: AppTheme.of(context).primaryText,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please take a clear photo of your valid government-issued ID. Capture both the front and back sides, and ensure all details are visible and readable.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppTheme.of(context).secondaryText,
              ),
            ),
          ],
        ),
      );

  Widget _buildDocSection({
    required KycDocumentField field,
    required String title,
    required String subtitle,
    required bool required,
  }) {
    final theme = AppTheme.of(context);
    final file = _kyc.document(field);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: file != null
                ? theme.success.withValues(alpha: 0.6)
                : theme.alternate,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: theme.primaryText,
                            ),
                          ),
                          if (required) ...[
                            const SizedBox(width: 6),
                            Text(
                              '*',
                              style: GoogleFonts.plusJakartaSans(
                                color: theme.error,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: theme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                if (file != null)
                  Icon(Icons.check_circle, color: theme.success, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            if (file == null)
              Row(
                children: [
                  Expanded(
                    child: _buildCaptureButton(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () => _pickImage(field, ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCaptureButton(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () => _pickImage(field, ImageSource.gallery),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _kyc.setDocument(field, null);
                        safeSetState(() {});
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retake'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.primaryText,
                        side: BorderSide(color: theme.alternate),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptureButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.of(context).primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.of(context).primary, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.of(context).primary, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppTheme.of(context).primaryText,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildContinueButton() {
    final theme = AppTheme.of(context);
    final ready = _kyc.hasRequiredDocuments;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: ready ? _continueToLiveness : null,
          icon: const Icon(Icons.arrow_forward),
          label: Text(ready ? 'Continue to Face Verification' : 'Complete required documents'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primary,
            foregroundColor: theme.onPrimary,
            disabledBackgroundColor: theme.alternate,
            disabledForegroundColor: theme.secondaryText,
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
