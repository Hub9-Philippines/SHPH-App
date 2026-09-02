import 'package:flutter/material.dart';

import '/components/cupertino_ui/app_button.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';

class OnboardingStep {
  const OnboardingStep({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

class OnboardingOverlay extends StatefulWidget {
  const OnboardingOverlay({
    super.key,
    required this.steps,
    this.onComplete,
    this.onSkip,
  });

  final List<OnboardingStep> steps;
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;

  static Future<void> show(
    BuildContext context, {
    required List<OnboardingStep> steps,
    VoidCallback? onComplete,
    VoidCallback? onSkip,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => OnboardingOverlay(
        steps: steps,
        onComplete: onComplete,
        onSkip: onSkip,
      ),
    );
  }

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay> {
  late PageController _pageController;
  int _currentStep = 0;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep < widget.steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete?.call();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return PopScope(
      canPop: false,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: theme.primaryBackground,
            borderRadius: BorderRadius.circular(28),
            boxShadow: AppThemeData.shadowLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 280,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentStep = i),
                  itemCount: widget.steps.length,
                  itemBuilder: (_, i) {
                    final step = widget.steps[i];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            color: theme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(step.icon, size: 40, color: theme.primary),
                        ),
                        const SizedBox(height: 24),
                        Text(step.title, style: theme.titleLarge, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        Text(
                          step.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: theme.secondaryText, fontSize: 14, height: 1.5),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.steps.length, (i) {
                  final isActive = i == _currentStep;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? theme.primary : theme.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  onPressed: _next,
                  backgroundColor: theme.primary,
                  foregroundColor: theme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  borderRadius: 14,
                  child: Text(
                    _currentStep < widget.steps.length - 1
                        ? _l10n.ccNext
                        : _l10n.ccGetStarted,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
              if (_currentStep > 0) ...[
                const SizedBox(height: 8),
                AppButton(
                  onPressed: () {
                    _pageController.animateToPage(
                      _currentStep - 1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  variant: AppButtonVariant.text,
                  child: Text(_l10n.ccBack),
                ),
              ] else ...[
                const SizedBox(height: 8),
                AppButton(
                  onPressed: () {
                    widget.onSkip?.call();
                    Navigator.of(context).pop();
                  },
                  variant: AppButtonVariant.text,
                  foregroundColor: theme.secondaryText,
                  child: Text(_l10n.ccSkip),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
