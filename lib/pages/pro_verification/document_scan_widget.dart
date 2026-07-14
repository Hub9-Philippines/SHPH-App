import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/services/profiles_service.dart';
import '/theme/app_theme.dart';
import 'document_scan_model.dart';

export 'document_scan_model.dart';

/// Production-ready document verification widget
///
/// Combines document capture and review in a single page:
/// 1. User selects image (camera/gallery)
/// 2. Preview shown with retake/submit options
/// 3. Upload to the SHPH KYC API on submit
/// 4. Navigate to face verification on success
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, DocumentScanModel.new);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  /// Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 2048,
        maxHeight: 2048,
      );

      if (image != null) {
        setState(() {
          _model.selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  /// Retake photo - clear selection and show options again
  void _retakePhoto() {
    setState(() {
      _model.selectedImage = null;
      _model.isUploading = false;
    });
  }

  /// Upload document through the authenticated KYC endpoint.
  Future<void> _submitDocument() async {
    if (_model.selectedImage == null) {
      _showError('No image selected');
      return;
    }

    setState(() => _model.isUploading = true);

    try {
      // Submit via ProfilesService (uses SHPH API when enabled)
      final file = _model.selectedImage!;
      final fileBytes = await file.readAsBytes();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_document.jpg';

      final resp = await ProfilesService.instance
          .submitKycDocument(documentBytes: fileBytes, fileName: fileName);

      setState(() => _model.isUploading = false);

      if (resp != null) {
        if (mounted) _showSuccessAndNavigate();
      } else {
        _showError('Upload failed');
      }
    } catch (e) {
      setState(() => _model.isUploading = false);
      _showError('Upload failed: $e');
    }
  }

  /// Show error snackbar
  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Show success message and navigate to face verification
  void _showSuccessAndNavigate() {
    final parentContext = context; // Capture parent context before dialog
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Document Uploaded'),
          ],
        ),
        content: const Text(
          'Your document has been uploaded successfully. Next, we need to verify your identity with a face scan.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Use parent context for navigation after dialog closes
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  // Use pushNamedAuth with ignoreRedirect to bypass any redirect guards
                  parentContext.pushNamedAuth(
                    FaceVerificationScreen.routeName,
                    mounted,
                    ignoreRedirect: true,
                  );
                }
              });
            },
            child: const Text('Continue'),
          ),
        ],
      ),
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
          appBar: AppBar(
            backgroundColor: AppTheme.of(context).primaryBackground,
            automaticallyImplyLeading: false,
            leading: wrapWithModel(
              model: _model.backButtonModel,
              updateCallback: () => safeSetState(() {}),
              child: const BackButtonWidget(),
            ),
            title: Text(
              'Document Verification',
              style: AppTheme.of(context).titleLarge.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.bold),
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
                  // Progress indicator
                  _buildProgressIndicator(),

                  // Title and instructions
                  _buildHeader(),

                  // Document preview / placeholder
                  _buildDocumentPreview(),

                  const SizedBox(height: 24),

                  // Action buttons
                  if (_model.selectedImage == null)
                    _buildCaptureOptions()
                  else
                    _buildReviewActions(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      );

  /// Build progress indicator
  Widget _buildProgressIndicator() => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 0),
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
                  child: const Icon(
                    Icons.edit_document,
                    color: Colors.white,
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
              style: AppTheme.of(context).bodyMedium.override(
                    color: AppTheme.of(context).primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      );

  /// Build header with title and instructions
  Widget _buildHeader() => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Your Government ID',
              style: AppTheme.of(context).headlineMedium.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please take a clear photo of your valid government-issued ID (Driver\'s License, Passport, or National ID). Ensure all details are visible and readable.',
              style: AppTheme.of(context).bodyMedium.override(
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
            const SizedBox(height: 12),
            _buildRequirementsList(),
          ],
        ),
      );

  /// Build requirements list
  Widget _buildRequirementsList() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0x2D368EFF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRequirementItem(
                Icons.check_circle, 'ID must be valid and not expired'),
            _buildRequirementItem(
                Icons.check_circle, 'All text must be clearly readable'),
            _buildRequirementItem(
                Icons.check_circle, 'All four corners must be visible'),
            _buildRequirementItem(
                Icons.check_circle, 'No glare or shadows on the document'),
          ],
        ),
      );

  Widget _buildRequirementItem(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.of(context).primary, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: AppTheme.of(context).bodySmall.override(
                      color: AppTheme.of(context).primary,
                    ),
              ),
            ),
          ],
        ),
      );

  /// Build document preview or placeholder
  Widget _buildDocumentPreview() => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
        child: Container(
          width: double.infinity,
          height: 240,
          decoration: BoxDecoration(
            color: AppTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _model.selectedImage != null
                  ? AppTheme.of(context).primary
                  : AppTheme.of(context).primaryText.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: _model.selectedImage != null
                ? Image.file(
                    _model.selectedImage!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : _buildPlaceholder(),
          ),
        ),
      );

  /// Build placeholder when no image selected
  Widget _buildPlaceholder() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card,
            size: 64,
            color: AppTheme.of(context).primaryText.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'ID Card Preview',
            style: AppTheme.of(context).bodyMedium.override(
                  color: AppTheme.of(context).secondaryText,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select an option below',
            style: AppTheme.of(context).bodySmall.override(
                  color: AppTheme.of(context).secondaryText,
                ),
          ),
        ],
      );

  /// Build capture options (camera/gallery)
  Widget _buildCaptureOptions() => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
        child: Row(
          children: [
            Expanded(
              child: _buildCaptureButton(
                icon: Icons.camera_alt,
                label: 'Take Photo',
                onTap: () => _pickImage(ImageSource.camera),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCaptureButton(
                icon: Icons.photo_library,
                label: 'Gallery',
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ),
          ],
        ),
      );

  Widget _buildCaptureButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.of(context).primary,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.of(context).primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppTheme.of(context).primary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: AppTheme.of(context).bodyMedium.override(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      );

  /// Build review actions (retake/submit)
  Widget _buildReviewActions() => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
        child: Column(
          children: [
            // Preview label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.of(context).accent2,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.visibility,
                    color: AppTheme.of(context).primary,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Preview Mode',
                    style: AppTheme.of(context).bodySmall.override(
                          color: AppTheme.of(context).primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Uploading indicator
            if (_model.isUploading)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Uploading document...'),
                ],
              )
            else ...[
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _retakePhoto,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retake'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppTheme.of(context).alternate),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _submitDocument,
                      icon: const Icon(Icons.check),
                      label: const Text('Submit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.of(context).primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
}
