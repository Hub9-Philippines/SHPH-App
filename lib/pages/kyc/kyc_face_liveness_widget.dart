import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '/components/cupertino_ui/app_button.dart';
import '/components/cupertino_ui/app_feedback.dart';
import '/components/cupertino_ui/app_activity_indicator.dart';
import '/components/cupertino_ui/cupertino_page_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/l10n/app_localizations.dart';
import '/services/client_kyc_service.dart';
import '/services/logging_service.dart';
import '/theme/app_theme.dart';
import 'kyc_face_liveness_model.dart';

export 'kyc_face_liveness_model.dart';

class KycFaceLivenessWidget extends StatefulWidget {
  const KycFaceLivenessWidget({
    super.key,
    this.idFront,
    this.idBack,
    this.kycService,
  });

  static String routeName = 'KycFaceLiveness';
  static String routePath = '/kyc-liveness';

  /// Front/back ID captures from the documents screen.
  final ClientKycFile? idFront;
  final ClientKycFile? idBack;

  /// Injectable for tests; defaults to the real API-backed service.
  final ClientKycService? kycService;

  @override
  State<KycFaceLivenessWidget> createState() => _KycFaceLivenessWidgetState();
}

class _KycFaceLivenessWidgetState extends State<KycFaceLivenessWidget> {
  late KycFaceLivenessModel _model;

  ClientKycService get _kyc => widget.kycService ?? ClientKycService();

  static const List<String> _fallbackPlan = [
    'kycPlanCenter',
    'kycPlanBlink',
    'kycPlanSmile',
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, KycFaceLivenessModel.new);
    _loadChallenge();
    _initCamera();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _loadChallenge() async {
    try {
      final resp = await _kyc.requestLivenessChallenge();
      _model.challengeNonce = resp['nonce'] as String?;
      final plan = resp['plan'];
      _model.challengePlan = plan is List
          ? List<String>.from(plan.whereType<String>())
          : const [];
      _model.challengeFailed = false;
    } catch (e) {
      LoggingService.warning(
        'Liveness challenge unavailable, using fallback plan: $e',
        tag: 'KycFaceLiveness',
      );
      _model.challengeNonce = null;
      _model.challengePlan = _fallbackPlan;
      _model.challengeFailed = true;
    }
    if (mounted) safeSetState(() {});
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _model.isFallbackMode = true;
        if (mounted) safeSetState(() {});
        return;
      }
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller =
          CameraController(camera, ResolutionPreset.low, enableAudio: false);
      _model.cameraController = controller;
      await controller.initialize();
      if (mounted) _model.isCameraReady = true;
    } catch (e) {
      LoggingService.warning('Camera unavailable, using picker fallback: $e',
          tag: 'KycFaceLiveness');
      _model.isFallbackMode = true;
    }
    if (mounted) safeSetState(() {});
  }

  Future<void> _capture() async {
    try {
      if (_model.isCameraReady) {
        final shot = await _model.cameraController!.takePicture();
        final bytes = await shot.readAsBytes();
        _model.selfie = ClientKycFile(bytes, shot.name);
      } else {
        final shot = await ImagePicker().pickImage(
          source: ImageSource.camera,
          maxWidth: 2048,
          imageQuality: 85,
        );
        if (shot == null) return;
        final bytes = await shot.readAsBytes();
        _model.selfie = ClientKycFile(bytes, shot.name);
      }
      if (mounted) safeSetState(() {});
    } catch (e) {
      LoggingService.error('Liveness capture failed: $e', tag: 'KycFaceLiveness');
    }
  }

  Future<void> _submit() async {
    if (widget.idFront == null || widget.idBack == null) {
      AppFeedback.showBanner(
        context,
        AppLocalizations.of(context)!.kycSubmitError,
        severity: AppBannerSeverity.error,
      );
      return;
    }
    final selfie = _model.selfie;
    if (selfie == null || _model.isSubmitting || _model.isSkipping) return;

    _model.isSubmitting = true;
    safeSetState(() {});
    try {
      await _kyc.submit(
        idFrontBytes: widget.idFront!.bytes,
        idFrontName: widget.idFront!.name,
        idBackBytes: widget.idBack!.bytes,
        idBackName: widget.idBack!.name,
        selfieBytes: selfie.bytes,
        selfieName: selfie.name,
        challengeNonce: _model.challengeNonce,
        livenessMetadata: {
          'challenge_plan': _model.challengePlan,
          'capture_mode': _model.isCameraReady ? 'camera' : 'image_picker',
        },
        livenessScore: 1.0,
      );
      if (!mounted) return;
      AppFeedback.showBanner(
        context,
        AppLocalizations.of(context)!.kycSubmissionPending,
        severity: AppBannerSeverity.success,
      );
      context.goNamedAuth(HomeWidget.routeName, context.mounted);
    } catch (e) {
      LoggingService.error('Client KYC submission failed: $e',
          tag: 'KycFaceLiveness');
      if (!mounted) return;
      _model.isSubmitting = false;
      safeSetState(() {});
      AppFeedback.showBanner(
        context,
        AppLocalizations.of(context)!.kycSubmitError,
        severity: AppBannerSeverity.error,
      );
    }
  }

  Future<void> _skip() async {
    if (_model.isSkipping) return;
    _model.isSkipping = true;
    safeSetState(() {});
    final ok = await _kyc.skip();
    if (!mounted) return;
    if (ok) {
      LoggingService.info('Client skipped KYC liveness', tag: 'KycFaceLiveness');
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
    final plan = _model.challengePlan.isNotEmpty
        ? _model.challengePlan
        : _fallbackPlan;
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: CupertinoPageHeader(
                title: l10n.kycLivenessTitle,
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
                      l10n.kycLivenessTitle,
                      style: theme.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.primaryText,
                      ),
                    ),
                    const SizedBox(height: AppThemeData.spaceSm),
                    Text(
                      l10n.kycLivenessSubtitle,
                      style: theme.bodyMedium.copyWith(
                        color: theme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: AppThemeData.spaceLg),
                    for (final step in plan) ...[
                      Row(
                        children: [
                          Icon(Icons.check_rounded,
                              size: 18, color: theme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _localizedPlan(l10n, step),
                              style: theme.bodyMedium.copyWith(
                                color: theme.primaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: AppThemeData.spaceLg),
                    _buildPreviewArea(theme),
                    const SizedBox(height: AppThemeData.spaceLg),
                    AppButton(
                      onPressed: (_model.isSubmitting || _model.isSkipping)
                          ? null
                          : _capture,
                      width: double.infinity,
                      height: 52,
                      child: Text(
                        _model.selfie != null
                            ? l10n.kycRetake
                            : l10n.kycCapture,
                      ),
                    ),
                    const SizedBox(height: AppThemeData.spaceSm),
                    AppButton(
                      onPressed: _model.selfie != null &&
                              !_model.isSubmitting &&
                              !_model.isSkipping
                          ? _submit
                          : null,
                      loading: _model.isSubmitting,
                      variant: AppButtonVariant.secondary,
                      width: double.infinity,
                      height: 52,
                      child: Text(l10n.kycSubmitNow),
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

  String _localizedPlan(AppLocalizations l10n, String key) {
    switch (key) {
      case 'kycPlanBlink':
        return l10n.kycPlanBlink;
      case 'kycPlanSmile':
        return l10n.kycPlanSmile;
      case 'kycPlanCenter':
      default:
        return l10n.kycPlanCenter;
    }
  }

  Widget _buildPreviewArea(AppThemeData theme) {
    final controller = _model.cameraController;
    if (_model.isCameraReady && controller != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
        child: SizedBox(
          height: 260,
          width: double.infinity,
          child: CameraPreview(controller),
        ),
      );
    }
    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
        border: Border.all(color: theme.border),
      ),
      child: _model.selfie != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
              child: Image.memory(
                Uint8List.fromList(_model.selfie!.bytes),
                fit: BoxFit.cover,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_model.isFallbackMode) ...[
                  Icon(Icons.videocam_off_outlined,
                      size: 32, color: theme.secondaryText),
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)!.kycStartVerification,
                    textAlign: TextAlign.center,
                    style: theme.bodySmall.copyWith(
                      color: theme.secondaryText,
                    ),
                  ),
                ] else
                  const AppActivityIndicator(radius: 20),
              ],
            ),
    );
  }
}