import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/theme/app_theme.dart';
import '../booking_controller.dart';
import '../widgets/booking_flow_route.dart';
import 'live_matching_screen.dart';

class LiveMatchingFloatingBanner extends StatefulWidget {
  const LiveMatchingFloatingBanner({super.key});

  @override
  State<LiveMatchingFloatingBanner> createState() =>
      _LiveMatchingFloatingBannerState();
}

class _LiveMatchingFloatingBannerState extends State<LiveMatchingFloatingBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;
  late final Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 1, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseOpacity = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _restoreLiveMatching(
    BuildContext context,
    BookingFlowController activeBooking,
  ) {
    activeBooking
      ..setLastSheetExtent(0.45)
      ..setMinimized(false);

    Navigator.of(context).push(
      buildBookingFlowRoute(
        ChangeNotifierProvider<BookingFlowController>.value(
          value: activeBooking,
          child: LiveMatchingScreen(
            bookingDate: activeBooking.draft.scheduledDate ?? DateTime.now(),
            serviceTitle: activeBooking.draft.serviceTitle,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<BookingFlowController?>(
      valueListenable: BookingFlowController.activeMatchingNotifier,
      builder: (context, activeBooking, _) {
        if (activeBooking == null || !activeBooking.isMatchingActive) {
          return const SizedBox.shrink();
        }

        return ListenableBuilder(
          listenable: activeBooking,
          builder: (context, _) {
            if (!activeBooking.isMatchingActive) {
              return const SizedBox.shrink();
            }

            final theme = AppTheme.of(context);
            final serviceTitle =
                activeBooking.draft.serviceTitle ?? 'Service request';

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _restoreLiveMatching(context, activeBooking),
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primaryBackground,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: theme.primary.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primary.withValues(alpha: 0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Pulsing radar icon
                      AnimatedBuilder(
                        animation: _pulseController,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: theme.primary.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.radar_rounded,
                            color: theme.primary,
                            size: 22,
                          ),
                        ),
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseScale.value,
                            child: Opacity(
                              opacity: _pulseOpacity.value,
                              child: child,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Finding a provider...',
                                  style: theme.titleSmall.override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    color: theme.primaryText,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: theme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$serviceTitle • Live matching in progress',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.bodySmall.override(
                                color: theme.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: theme.secondaryBackground,
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.alternate),
                        ),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: theme.primaryText,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
