import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/cupertino_ui/app_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/l10n/app_localizations.dart';
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

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

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
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

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
        backgroundColor: AppTheme.of(context).secondaryBackground,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 480),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).primaryBackground,
                  borderRadius: BorderRadius.circular(34),
                  boxShadow: AppThemeData.shadowCard,
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
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
                        borderRadius: BorderRadius.circular(30),
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
                                  color: Colors.white.withValues(alpha: 0.36),
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
                            _l10n.bsTitle,
                            textAlign: TextAlign.center,
                            style: AppTheme.of(context).headlineMedium.override(
                                  font: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  color: Colors.white,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _l10n.bsSubtitle,
                            textAlign: TextAlign.center,
                            style: AppTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.plusJakartaSans(),
                                  color: Colors.white.withValues(alpha: 0.86),
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    _buildInfoCard(
                      icon: Icons.notifications_active_rounded,
                      title: _l10n.bsNextTitle,
                      description: _l10n.bsNextDesc,
                      accent: AppTheme.of(context).primary,
                      background: const Color(0xFFF6FBFF),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      icon: Icons.shield_outlined,
                      title: _l10n.bsProtectionTitle,
                      description: _l10n.bsProtectionDesc,
                      accent: const Color(0xFF1B74E4),
                      background: const Color(0xFFEAF4FF),
                    ),
                    const SizedBox(height: 24),
                    FFButtonWidget(
                      onPressed: () {
                        context.go('/bookings');
                      },
                      text: _l10n.bsViewBookings,
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 56,
                        color: AppTheme.of(context).primary,
                        textStyle: AppTheme.of(context).titleMedium.override(
                              font: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                              ),
                              color: AppTheme.of(context).onPrimary,
                            ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppButton(
                      onPressed: () {
                        context.go('/home');
                      },
                      variant: AppButtonVariant.outlined,
                      borderSide: BorderSide(
                        color: AppThemeData.contrastOn(
                          AppTheme.of(context).primaryBackground,
                        ).withValues(alpha: 0.4),
                      ),
                      width: double.infinity,
                      height: 52,
                      borderRadius: 18,
                      foregroundColor: AppThemeData.contrastOn(
                        AppTheme.of(context).primaryBackground,
                      ),
                      child: Text(
                        _l10n.bsBackHome,
                        style: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required Color accent,
    required Color background,
  }) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: accent.withValues(alpha: 0.16)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                  style: AppTheme.of(context).titleSmall.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                        ),
                        color: AppTheme.of(context).primaryText,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTheme.of(context).bodySmall.override(
                        font: GoogleFonts.plusJakartaSans(),
                        color: AppTheme.of(context).secondaryText,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
