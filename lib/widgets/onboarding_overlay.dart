import 'package:flutter/material.dart';

import '/theme/app_theme.dart';

class OnboardingOverlay extends StatefulWidget {

  const OnboardingOverlay({
    required this.child,
    required this.steps,
    super.key,
  });
  final Widget child;
  final List<OnboardingStep> steps;

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class OnboardingStep {

  const OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
  });
  final String title;
  final String description;
  final IconData icon;
}

class _OnboardingOverlayState extends State<OnboardingOverlay> {
  int _currentStep = 0;
  bool _visible = true;

  void _next() {
    if (_currentStep < widget.steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      setState(() => _visible = false);
    }
  }

  void _skip() {
    setState(() => _visible = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return widget.child;

    final theme = AppTheme.of(context);
    final step = widget.steps[_currentStep];

    return Stack(
      children: [
        widget.child,
        GestureDetector(
          onTap: _skip,
          child: Container(
            color: Colors.black.withValues(alpha: 0.6),
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 24,
          left: 24,
          right: 24,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.primaryBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_currentStep + 1} of ${widget.steps.length}',
                        style: theme.bodySmall
                            .override(color: theme.secondaryText),
                      ),
                      TextButton(
                        onPressed: _skip,
                        child: Text('Skip',
                            style: TextStyle(color: theme.secondaryText)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Icon(step.icon, size: 48, color: theme.primary),
                  const SizedBox(height: 16),
                  Text(
                    step.title,
                    style: theme.titleMedium
                        .override(fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    step.description,
                    style: theme.bodyMedium
                        .override(color: theme.secondaryText),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.steps.length,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == _currentStep
                              ? theme.primary
                              : theme.alternate,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _next,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentStep < widget.steps.length - 1
                            ? 'Next'
                            : 'Got It',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
