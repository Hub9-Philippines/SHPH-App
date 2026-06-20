import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '/main/home/home_widget.dart';
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

    return BookingStatusScaffold(
      showMap: widget.showMap,
      location: location,
      topCard: _StatusCard(
        secondsRemaining: _secondsRemaining,
        timedOut: _timedOut,
        serviceTitle: serviceTitle,
        stageLabel: matchingStage.label,
        stageSubtitle: matchingStage.subtitle,
      ),
      center: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final progress = _controller.value * 3.0;
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
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).primary.withValues(alpha: 0.28),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomSheet: BookingStatusBottomSheet(
        child: _timedOut
            ? _TimeoutSheet(
                onAdjustBooking: () => Navigator.of(context).pop(),
                onBackHome: () => context.goNamed(HomeWidget.routeName),
              )
            : _SearchingSheet(
                stageLabel: matchingStage.label,
                stageSubtitle: matchingStage.subtitle,
                addressLabel: draft?.address.label ?? 'Pinned location',
                addressLine:
                    '${draft?.address.line1 ?? 'Location loading'}${(draft?.address.city ?? '').isNotEmpty ? ', ${draft!.address.city}' : ''}',
                referenceId: booking?.activeReferenceId,
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
    final size = 34 + (progress * 92);
    final opacity = math.max(0, 1.0 - progress);

    return Opacity(
      opacity: opacity *
          (ringIndex == 0
              ? 0.34
              : ringIndex == 1
                  ? 0.24
                  : 0.16),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.primary.withValues(alpha: 0.12),
          border: Border.all(
            color: theme.primary.withValues(alpha: 0.22),
            width: 1.4,
          ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryBackground.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: secondsRemaining / 30,
              minHeight: 6,
              backgroundColor: theme.alternate.withValues(alpha: 0.25),
              color: theme.primary,
            ),
            const SizedBox(height: 6),
            Text(
              '$secondsRemaining s remaining',
              style: theme.labelMedium.override(
                color: theme.secondaryText,
              ),
            ),
          ],
        ],
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
    this.referenceId,
  });

  final String stageLabel;
  final String stageSubtitle;
  final String addressLabel;
  final String addressLine;
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
        const SizedBox(height: 14),
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
                child: const Text('Adjust booking'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: onBackHome,
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
