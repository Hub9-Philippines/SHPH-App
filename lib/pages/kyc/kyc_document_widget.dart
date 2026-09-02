import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '/components/cupertino_ui/app_button.dart';
import '/components/cupertino_ui/app_feedback.dart';
import '/components/cupertino_ui/cupertino_page_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/l10n/app_localizations.dart';
import '/services/client_kyc_service.dart';
import '/services/logging_service.dart';
import '/theme/app_theme.dart';
import 'kyc_document_model.dart';
import 'kyc_face_liveness_widget.dart';

export 'kyc_document_model.dart';

class KycDocumentWidget extends StatefulWidget {
  const KycDocumentWidget({super.key});

  static String routeName = 'KycDocuments';
  static String routePath = '/kyc-documents';

  @override
  State<KycDocumentWidget> createState() => _KycDocumentWidgetState();
}

class _KycDocumentWidgetState extends State<KycDocumentWidget> {
  late KycDocumentModel _model;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, KycDocumentModel.new);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _pickFor(
    void Function(ClientKycFile file) assign,
  ) async {
    final source = await _pickSource();
    if (source == null || !mounted) return;
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 2048,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;
      final bytes = await file.readAsBytes();
      assign(ClientKycFile(bytes, file.name));
      safeSetState(() {});
    } catch (e) {
      LoggingService.error('KYC capture failed: $e', tag: 'KycDocuments');
    }
  }

  Future<ImageSource?> _pickSource() {
    final theme = AppTheme.of(context);
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: theme.primaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(_l10n.kycCamera),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(_l10n.kycGallery),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _continue() async {
    if (!_model.complete || _model.isSkipping) return;
    context.pushNamed(
      KycFaceLivenessWidget.routeName,
      extra: {
        'idFront': _model.idFront,
        'idBack': _model.idBack,
      },
    );
  }

  Future<void> _skip() async {
    if (_model.isSkipping) return;
    _model.isSkipping = true;
    safeSetState(() {});
    final ok = await ClientKycService().skip();
    if (!mounted) return;
    if (ok) {
      LoggingService.info('Client skipped KYC documents', tag: 'KycDocuments');
      context.goNamedAuth(HomeWidget.routeName, context.mounted);
    } else {
      _model.isSkipping = false;
      safeSetState(() {});
      AppFeedback.showBanner(
        context,
        AppLocalizations.of(context)!.kycSkipError,
        severity: AppBannerSeverity.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: CupertinoPageHeader(
                title: l10n.kycIntroTitle,
                actions: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _skip,
                    child: Text(
                      l10n.skipForNow,
                      style: TextStyle(
                        color: theme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.kycIntroSubtitle,
                      style: theme.bodyMedium.copyWith(
                        color: theme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: AppThemeData.spaceXl),
                    _buildSlot(
                      theme,
                      label: l10n.kycIdFrontLabel,
                      file: _model.idFront,
                      onCapture: () => _pickFor(
                        (file) => _model.idFront = file,
                      ),
                    ),
                    const SizedBox(height: AppThemeData.spaceLg),
                    _buildSlot(
                      theme,
                      label: l10n.kycIdBackLabel,
                      file: _model.idBack,
                      onCapture: () => _pickFor(
                        (file) => _model.idBack = file,
                      ),
                    ),
                    const SizedBox(height: AppThemeData.spaceLg),
                    _buildSlot(
                      theme,
                      label: l10n.kycSelfieLabel,
                      file: _model.selfie,
                      onCapture: () => _pickFor(
                        (file) => _model.selfie = file,
                      ),
                    ),
                    const SizedBox(height: AppThemeData.spaceXl),
                    AppButton(
                      onPressed: _model.complete && !_model.isSkipping
                          ? _continue
                          : null,
                      width: double.infinity,
                      height: 52,
                      child: Text(l10n.kycContinue),
                    ),
                    const SizedBox(height: AppThemeData.spaceSm),
                    AppButton(
                      variant: AppButtonVariant.text,
                      onPressed: _skip,
                      loading: _model.isSkipping,
                      width: double.infinity,
                      height: 48,
                      child: Text(l10n.skipForNow),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlot(
    AppThemeData theme, {
    required String label,
    required ClientKycFile? file,
    required VoidCallback onCapture,
  }) {
    final hasCapture = file != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
        border: Border.all(
          color: hasCapture ? theme.primary : theme.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: hasCapture
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      Uint8List.fromList(file!.bytes),
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.add_a_photo_outlined,
                      size: 28,
                      color: theme.secondaryText,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.primaryText,
                  ),
                ),
                const SizedBox(height: AppThemeData.spaceSm),
                AppButton(
                  variant: hasCapture
                      ? AppButtonVariant.secondary
                      : AppButtonVariant.primary,
                  onPressed: onCapture,
                  minWidth: 0,
                  height: 40,
                  child: Text(
                    hasCapture
                        ? AppLocalizations.of(context)!.kycRetake
                        : AppLocalizations.of(context)!.kycCapture,
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