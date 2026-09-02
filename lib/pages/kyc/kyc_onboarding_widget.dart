import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '/components/cupertino_ui/app_button.dart';
import '/components/cupertino_ui/app_feedback.dart';
import '/components/cupertino_ui/cupertino_page_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/l10n/app_localizations.dart';
import '/services/client_kyc_service.dart';
import '/services/logging_service.dart';
import '/theme/app_theme.dart';
import 'kyc_document_widget.dart';
import 'kyc_onboarding_model.dart';

export 'kyc_onboarding_model.dart';

class KycOnboardingWidget extends StatefulWidget {
  const KycOnboardingWidget({super.key, this.kycService});

  static String routeName = 'KycOnboarding';
  static String routePath = '/kyc-onboarding';

  /// Injectable for tests; defaults to the real API-backed service.
  final ClientKycService? kycService;

  @override
  State<KycOnboardingWidget> createState() => _KycOnboardingWidgetState();
}

class _KycOnboardingWidgetState extends State<KycOnboardingWidget> {
  late KycOnboardingModel _model;

  ClientKycService get _kyc => widget.kycService ?? ClientKycService();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, KycOnboardingModel.new);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _startVerification() async {
    if (_model.isSkipping) return;
    context.pushNamed(KycDocumentWidget.routeName);
  }

  Future<void> _skip() async {
    if (_model.isSkipping) return;
    _model.isSkipping = true;
    safeSetState(() {});
    final ok = await _kyc.skip();
    if (!mounted) return;
    if (ok) {
      LoggingService.info('Client skipped KYC verification', tag: 'KycOnboarding');
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
                      l10n.kycIntroTitle,
                      style: theme.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.primaryText,
                      ),
                    ),
                    const SizedBox(height: AppThemeData.spaceSm),
                    Text(
                      l10n.kycIntroSubtitle,
                      style: theme.bodyMedium.copyWith(
                        color: theme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: AppThemeData.spaceXl),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        borderRadius:
                            BorderRadius.circular(AppThemeData.radiusLg),
                        border: Border.all(color: theme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.kycWhatYouNeed,
                            style: theme.titleSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.primaryText,
                            ),
                          ),
                          const SizedBox(height: AppThemeData.spaceMd),
                          _checklistRow(
                            theme,
                            Icons.badge_outlined,
                            l10n.kycIdFrontLabel,
                          ),
                          const SizedBox(height: 12),
                          _checklistRow(
                            theme,
                            Icons.face_retouching_natural,
                            l10n.kycSelfieLabel,
                          ),
                          const SizedBox(height: 12),
                          _checklistRow(
                            theme,
                            Icons.timer_outlined,
                            l10n.kycMinutesLabel,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppThemeData.spaceXl),
                    AppButton(
                      onPressed: _startVerification,
                      width: double.infinity,
                      height: 52,
                      child: Text(l10n.kycStartVerification),
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

  Widget _checklistRow(AppThemeData theme, IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 22, color: theme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.bodyMedium.copyWith(color: theme.primaryText),
          ),
        ),
      ],
    );
  }
}