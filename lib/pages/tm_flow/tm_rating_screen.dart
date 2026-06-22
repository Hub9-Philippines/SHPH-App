import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/main.dart';
import '/theme/app_theme.dart';
import 'tm_controller.dart';

class TMRatingScreen extends StatefulWidget {
  const TMRatingScreen({super.key});

  static const String routeName = 'TMRating';
  static const String routePath = '/tm/rating';

  @override
  State<TMRatingScreen> createState() => _TMRatingScreenState();
}

class _TMRatingScreenState extends State<TMRatingScreen> {
  int _selectedRating = 5;
  String? _lastShownError;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Consumer<TMFlowController>(
      builder: (context, controller, _) {
        _handleControllerErrors(controller);
        return Scaffold(
          backgroundColor: theme.primaryBackground,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rate your service',
                    style: theme.headlineMedium.override(
                      font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'How was the time-material service experience with ${controller.matchedProvider?.name ?? 'your provider'}?',
                    style: theme.bodyMedium.override(
                      color: theme.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final star = index + 1;
                        return IconButton(
                          onPressed: controller.isSubmittingRating
                              ? null
                              : () {
                                  setState(() {
                                    _selectedRating = star;
                                  });
                                },
                          iconSize: 42,
                          icon: Icon(
                            star <= _selectedRating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: const Color(0xFFF4B63D),
                          ),
                        );
                      }),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: controller.isSubmittingRating
                          ? null
                          : () async {
                              final navigator =
                                  Navigator.of(context, rootNavigator: true);
                              final success = await controller
                                  .submitRating(_selectedRating);
                              if (!mounted || !success) {
                                return;
                              }
                              await navigator.pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const NavBarPage(
                                    initialPage: 'Home',
                                    disableResizeToAvoidBottomInset: true,
                                  ),
                                ),
                                (route) => false,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: controller.isSubmittingRating
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Submit Rating',
                              style: theme.titleMedium.override(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleControllerErrors(TMFlowController controller) {
    final error = controller.lastErrorMessage;
    if (error == null || error == _lastShownError) {
      return;
    }
    _lastShownError = error;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      controller.clearLastError();
    });
  }
}
