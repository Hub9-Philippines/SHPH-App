import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '/main.dart';
import '/theme/app_theme.dart';
import '../booking_controller.dart';
import '../widgets/booking_status_scaffold.dart';

class LiveMatchingScreen extends StatefulWidget {
  const LiveMatchingScreen({
    super.key,
    this.showMap = true,
    this.serviceTitle,
  });

  final bool showMap;
  final String? serviceTitle;

  @override
  State<LiveMatchingScreen> createState() => _LiveMatchingScreenState();
}

class _LiveMatchingScreenState extends State<LiveMatchingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;
  int _secondsRemaining = 30;
  bool _timedOut = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        return;
      }
      setState(() {
        _secondsRemaining--;
        if (_secondsRemaining <= 0) {
          _timedOut = true;
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingFlowController?>();
    final draft = booking?.draft;
    final location = LatLng(
      draft?.latitude ?? 14.5995,
      draft?.longitude ?? 120.9842,
    );
    final serviceTitle =
        widget.serviceTitle ?? draft?.serviceTitle ?? 'Service request';
    final matchingStage = _matchingStage(_secondsRemaining);

    void _onBackOrCancel() {
      booking?.setMatchingActive(true);
      booking?.setLiveSearchTimedOut(true);
      if (mounted) Navigator.of(context).pop();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBackOrCancel();
      },
      child: BookingStatusScaffold(
        showMap: widget.showMap,
        location: location,
        markerHue: BitmapDescriptor.hueAzure,
        isDraggable: true,
        topCard: _StatusCard(
          secondsRemaining: _secondsRemaining,
          timedOut: _timedOut,
          serviceTitle: serviceTitle,
          stageLabel: matchingStage.label,
          stageSubtitle: matchingStage.subtitle,
        ),
        center: _timedOut
            ? null
            : AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final progress = _controller.value * 3;
                  return IgnorePointer(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        for (var ringIndex = 0; ringIndex < 3; ringIndex++)
                          _RippleRing(
                            progress: (progress + ringIndex * 0.33) % 1.0,
                            ringIndex: ringIndex,
                          ),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppTheme.of(context)
                                .primary
                                .withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppTheme.of(context)
                                .primary
                                .withValues(alpha: 0.34),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppTheme.of(context).primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.of(context)
                                    .primary
                                    .withValues(alpha: 0.45),
                                blurRadius: 18,
                                spreadRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
        bottomSheet: _timedOut
            ? _TimeoutSheet(
                onAdjustBooking: () => Navigator.of(context).pop(),
                onBackHome: () =>
                    Navigator.of(context, rootNavigator: true)
                        .pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const NavBarPage(
                      initialPage: 'Home',
                      disableResizeToAvoidBottomInset: true,
                    ),
                  ),
                  (route) => false,
                ),
              )
            : _SearchingSheet(
                stageLabel: matchingStage.label,
                stageSubtitle: matchingStage.subtitle,
                addressLabel: draft?.address.label ?? 'Pinned location',
                addressLine:
                    '${draft?.address.line1 ?? 'Location loading'}${(draft?.address.city ?? '').isNotEmpty ? ', ${draft!.address.city}' : ''}',
                referenceId: booking?.activeReferenceId,
                onCancel: _onBackOrCancel,
              ),
      ),
    );
  }

  _MatchingStage _matchingStage(int secondsRemaining) {
    if (secondsRemaining > 20) {
      return const _MatchingStage(
        label: 'Broadcasting request',
        subtitle: 'Alerting nearby active providers around your pin.',
      );
    }
    if (secondsRemaining > 10) {
      return const _MatchingStage(
        label: 'Checking availability',
        subtitle: 'Comparing who can reach you the fastest.',
      );
    }
    return const _MatchingStage(
      label: 'Final nearby sweep',
      subtitle: 'Running one last pass before the request times out.',
    );
  }
}

class _MatchingStage {
  const _MatchingStage({
    required this.label,
    required this.subtitle,
  });

  final String label;
  final String subtitle;
}

class _RippleRing extends StatelessWidget {
  const _RippleRing({
    required this.progress,
    required this.ringIndex,
  });

  final double progress;
  final int ringIndex;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final size = 52 + (progress * 160);
    final opacity = math.max(0, 1.0 - progress);

    return Opacity(
      opacity: opacity *
          (ringIndex == 0
              ? 0.64
              : ringIndex == 1
                  ? 0.46
                  : 0.30),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.primary.withValues(alpha: 0.18),
          border: Border.all(
            color: theme.primary.withValues(alpha: 0.42),
            width: 2.2,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.primary.withValues(alpha: 0.18),
              blurRadius: 14,
              spreadRadius: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.secondsRemaining,
    required this.timedOut,
    required this.serviceTitle,
    required this.stageLabel,
    required this.stageSubtitle,
  });

  final int secondsRemaining;
  final bool timedOut;
  final String serviceTitle;
  final String stageLabel;
  final String stageSubtitle;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.primaryBackground.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                serviceTitle,
                style: theme.bodyLarge.override(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                timedOut ? 'Search timed out' : 'Finding the nearest provider',
                style: theme.titleMedium.override(
                  font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                timedOut
                    ? 'We could not find an active provider in time.'
                    : stageSubtitle,
                style: theme.bodyMedium.override(
                  color: theme.secondaryText,
                ),
              ),
              if (!timedOut) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        stageLabel,
                        style: theme.labelMedium.override(
                          color: theme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$secondsRemaining s',
                      style: theme.labelLarge.override(
                        color: theme.secondaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: secondsRemaining / 30,
                  minHeight: 7,
                  backgroundColor: theme.alternate.withValues(alpha: 0.25),
                  color: theme.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchingSheet extends StatelessWidget {
  const _SearchingSheet({
    required this.stageLabel,
    required this.stageSubtitle,
    required this.addressLabel,
    required this.addressLine,
    required this.onCancel,
    this.referenceId,
  });

  final String stageLabel;
  final String stageSubtitle;
  final String addressLabel;
  final String addressLine;
  final VoidCallback onCancel;
  final String? referenceId;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: theme.alternate,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.primary.withValues(alpha: 0.18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stageLabel,
                style: theme.labelLarge.override(
                  color: theme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stageSubtitle,
                style: theme.bodySmall.override(
                  color: theme.secondaryText,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Searching nearby providers',
          style: theme.titleMedium.override(
            font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Stay on this screen while we look for the closest available professional.',
          style: theme.bodyMedium.override(
            color: theme.secondaryText,
          ),
        ),
        const SizedBox(height: 16),
        _MetaRow(
          icon: Icons.place_rounded,
          title: addressLabel,
          subtitle: addressLine,
        ),
        if ((referenceId ?? '').isNotEmpty) ...[
          const SizedBox(height: 12),
          _MetaRow(
            icon: Icons.tag_rounded,
            title: 'Search reference',
            subtitle: referenceId!,
          ),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Cancel search'),
          ),
        ),
      ],
    );
  }
}

class _TimeoutSheet extends StatelessWidget {
  const _TimeoutSheet({
    required this.onAdjustBooking,
    required this.onBackHome,
  });

  final VoidCallback onAdjustBooking;
  final VoidCallback onBackHome;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 5,
          decoration: BoxDecoration(
            color: theme.alternate,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Providers are busy, try again',
          style: theme.titleMedium.override(
            font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You can adjust the booking details and retry, or head back home for now.',
          textAlign: TextAlign.center,
          style: theme.bodyMedium.override(
            color: theme.secondaryText,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onAdjustBooking,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Adjust booking'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: onBackHome,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Back home'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: theme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.bodyMedium.override(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.bodySmall.override(
                  color: theme.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
