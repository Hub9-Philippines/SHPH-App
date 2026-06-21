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
        backgroundColor: const Color(0xFFF5F7FA),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 460),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF0F8A6C),
                            Color(0xFF17B890),
                            Color(0xFF73D8B4),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        children: [
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.38),
                                ),
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 62,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Booking Confirmed!',
                            textAlign: TextAlign.center,
                            style: AppTheme.of(context).headlineMedium.override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  color: Colors.white,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your booking has been created successfully and the provider will be notified shortly.',
                            textAlign: TextAlign.center,
                            style: AppTheme.of(context).bodyMedium.override(
                                  color: Colors.white.withValues(alpha: 0.84),
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6FBFF),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: AppTheme.of(context)
                              .primary
                              .withValues(alpha: 0.16),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppTheme.of(context)
                                  .primary
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.notifications_active_rounded,
                              color: AppTheme.of(context).primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'What happens next',
                                  style:
                                      AppTheme.of(context).titleSmall.override(
                                            font: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w700,
                                            ),
                                            color: const Color(0xFF16202A),
                                          ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'You can track the request from your bookings page and we will keep you updated as the status changes.',
                                  style:
                                      AppTheme.of(context).bodySmall.override(
                                            color: const Color(0xFF6F7B86),
                                          ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
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
                                fontWeight: FontWeight.w700,
                              ),
                              color: Colors.white,
                            ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextButton(
                      onPressed: () {
                        context.go('/home');
                      },
                      child: Text(
                        'Back to Home',
                        style: AppTheme.of(context).bodyMedium.override(
                              color: AppTheme.of(context).primary,
                              font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
