import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/theme/app_theme.dart';
import 'booking_success_model.dart';

export 'booking_success_model.dart';

class BookingSuccessWidget extends StatefulWidget {
  const BookingSuccessWidget({super.key});

  static String routeName = 'BookingSuccess';
  static String routePath = '/booking-success';

  @override
  State<BookingSuccessWidget> createState() => _BookingSuccessWidgetState();
}

class _BookingSuccessWidgetState extends State<BookingSuccessWidget>
    with SingleTickerProviderStateMixin {
  late BookingSuccessModel _model;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, BookingSuccessModel.new);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _model.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppTheme.of(context).primaryBackground,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Success Animation
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Success Message
                  Text(
                    'Booking Confirmed!',
                    style: AppTheme.of(context).headlineMedium.override(
                          font:
                              GoogleFonts.poppins(fontWeight: FontWeight.bold),
                          color: AppTheme.of(context).primaryText,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your booking has been successfully created. The service provider will be notified shortly.',
                    textAlign: TextAlign.center,
                    style: AppTheme.of(context).bodyMedium.override(
                          color: AppTheme.of(context).secondaryText,
                        ),
                  ),
                  const SizedBox(height: 48),
                  // View Bookings Button
                  FFButtonWidget(
                    onPressed: () {
                      context.go('/bookings');
                    },
                    text: 'View Bookings',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 56,
                      color: AppTheme.of(context).primary,
                      textStyle: AppTheme.of(context).titleMedium.override(
                            font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600),
                            color: AppTheme.of(context).primaryText,
                          ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Back to Home Button
                  TextButton(
                    onPressed: () {
                      context.go('/home');
                    },
                    child: Text(
                      'Back to Home',
                      style: AppTheme.of(context).bodyMedium.override(
                            color: AppTheme.of(context).primary,
                            font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
