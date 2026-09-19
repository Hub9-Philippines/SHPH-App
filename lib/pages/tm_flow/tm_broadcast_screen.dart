import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '/app_state.dart';
import '/components/map_radar_scan.dart';
import '/components/smooth_progress_bar.dart';
import '/l10n/app_localizations.dart';
import '/main.dart';
import '/theme/app_theme.dart';
import '../booking_funnel/booking_flow_screen.dart';
import '../booking_funnel/booking_models.dart';
import '../booking_funnel/widgets/booking_flow_route.dart';
import '../booking_funnel/widgets/booking_status_scaffold.dart';
import 'tm_active_job_screen.dart';
import 'tm_controller.dart';

class TMBroadcastScreen extends StatefulWidget {
  const TMBroadcastScreen({super.key});

  static const String routeName = 'TMBroadcast';
  static const String routePath = '/tm/broadcast';

  @override
  State<TMBroadcastScreen> createState() => _TMBroadcastScreenState();
}

class _TMBroadcastScreenState extends State<TMBroadcastScreen>
    with TickerProviderStateMixin {
  String? _lastNotice;
  String? _lastError;
  bool _shownFailureDialog = false;
  bool _navigatedToActiveJob = false;
  RadarScanController? _scanController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<TMFlowController>().startBroadcast(
        AppLocalizations.of(context),
      );
    });
  }

  RadarScanController? _scanControllerFor(BuildContext context) {
    _scanController ??= RadarScanController(
      vsync: this,
      center: _currentLocation(),
      ringColor: AppTheme.of(context).primary,
    );
    _syncScanState(context.read<TMFlowController>());
    return _scanController;
  }

  LatLng _currentLocation() {
    final appState = FFAppState();
    return LatLng(
      appState.selectedLatitude ?? 14.5995,
      appState.selectedLongitude ?? 120.9842,
    );
  }

  /// Ripple runs while broadcasting; cleared on failure or match (the match
  /// path navigates away, which disposes the controller).
  void _syncScanState(TMFlowController controller) {
    final scan = _scanController;
    if (scan == null) {
      return;
    }
    scan.updateCenter(_currentLocation());
    if (controller.hasFailed || controller.hasMatchedProvider) {
      scan.stop();
    } else if (!scan.isAnimating) {
      scan.restart();
    }
  }

  @override
  void dispose() {
    _scanController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = _currentLocation();

    return Consumer<TMFlowController>(
      builder: (context, controller, _) {
        _handleTransientUi(context, controller);

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              return;
            }
            _backToPreviousStep(context, controller);
          },
          child: BookingStatusScaffold(
            location: location,
            markerHue: BitmapDescriptor.hueAzure,
            radarScan: _scanControllerFor(context),
            topCard: _TMBroadcastTopCard(
              controller: controller,
              onBack: () {
                unawaited(_backToPreviousStep(context, controller));
              },
            ),
            bottomSheet: BookingStatusBottomSheet(
              child: _TMBroadcastSheet(
                controller: controller,
                onCancel: () {
                  unawaited(_backHome(context, controller));
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleTransientUi(BuildContext context, TMFlowController controller) {
    final notice = controller.broadcastNotice;
    if (notice != null && notice != _lastNotice) {
      _lastNotice = notice;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(notice)));
        controller.clearBroadcastNotice();
      });
    }

    final error = controller.lastErrorMessage;
    if (error != null && error != _lastError) {
      _lastError = error;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
        controller.clearLastError();
      });
    }

    if (controller.hasFailed && !_shownFailureDialog) {
      _shownFailureDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) {
          return;
        }
        await showModalBottomSheet<void>(
          context: context,
          backgroundColor: Colors.transparent,
          isDismissible: false,
          enableDrag: false,
          builder: (sheetContext) => _NoProviderFoundModal(
            onSearchAgain: () {
              Navigator.of(sheetContext).pop();
              controller.retryBroadcast(AppLocalizations.of(context));
              _shownFailureDialog = false;
            },
            onSchedule: () async {
              Navigator.of(sheetContext).pop();
              await controller.cancelBroadcastRequest(
                reason: 'switched_to_scheduled',
                l10n: AppLocalizations.of(context),
              );
              if (!context.mounted) {
                return;
              }
              await Navigator.of(context).pushReplacement(
                buildBookingFlowRoute(
                  BookingFlowScreen(
                    selectedService: controller.selectedService,
                    initialUrgency: BookingUrgency.scheduled,
                    initialScheduledDate: DateTime.now().add(
                      const Duration(days: 1),
                    ),
                    initialScheduledTime: const TimeOfDay(hour: 9, minute: 0),
                  ),
                ),
              );
            },
            onCancelSearch: () async {
              Navigator.of(sheetContext).pop();
              await _backHome(context, controller);
            },
          ),
        );
      });
    }

    if (controller.hasMatchedProvider && !_navigatedToActiveJob) {
      _navigatedToActiveJob = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        unawaited(
          Navigator.of(context).pushReplacement(
            buildBookingFlowRoute(
              ChangeNotifierProvider.value(
                value: controller,
                child: const TMActiveJobScreen(),
              ),
            ),
          ),
        );
      });
    }
  }

  Future<void> _backToPreviousStep(
    BuildContext context,
    TMFlowController controller,
  ) async {
    final success = await controller.cancelBroadcastRequest(
      l10n: AppLocalizations.of(context),
    );
    if (!context.mounted || !success) {
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _backHome(
    BuildContext context,
    TMFlowController controller,
  ) async {
    final success = await controller.cancelBroadcastRequest(
      l10n: AppLocalizations.of(context),
    );
    if (!context.mounted || !success) {
      return;
    }
    await Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const NavBarPage(
          initialPage: 'Home',
          disableResizeToAvoidBottomInset: true,
        ),
      ),
      (route) => false,
    );
  }
}

class _TMBroadcastTopCard extends StatelessWidget {
  const _TMBroadcastTopCard({required this.controller, required this.onBack});

  final TMFlowController controller;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final stageLabel = switch (controller.broadcastStage) {
      TMBroadcastStage.expandedSearch => l10n.tmExpandedRadiusSearch,
      TMBroadcastStage.failed => l10n.tmNoProviderFoundYet,
      _ => l10n.tmSearchingNearbyProviders,
    };

    final subtitle = switch (controller.broadcastStage) {
      TMBroadcastStage.expandedSearch => l10n.tmWidenedSearchRadius,
      TMBroadcastStage.failed => l10n.tmNearbyExpandedTimedOut,
      _ => l10n.tmBroadcastingRequest,
    };

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.primaryBackground.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(26),
              boxShadow: AppThemeData.shadowCard,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      controller.selectedServiceLabel,
                      style: theme.bodyLarge.override(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                stageLabel,
                style: theme.titleMedium.override(
                  font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.bodyMedium.override(color: theme.secondaryText),
              ),
              const SizedBox(height: 12),
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
                      l10n.tmRadiusLabel(controller.searchRadiusKm.toString()),
                      style: theme.labelMedium.override(
                        color: theme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (controller.dispatchMode != null) ...[
                    const SizedBox(width: 8),
                    _TMDispatchModeChip(controller: controller),
                  ],
                  const Spacer(),
                  if (controller.hasFailed)
                    Text(
                      l10n.tmTimedOut,
                      style: theme.labelLarge.override(
                        color: theme.secondaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
              if (!controller.hasFailed) ...[
                const SizedBox(height: 10),
                SmoothProgress(
                  value: controller.secondsRemaining / 60,
                  builder: (context, value) => LinearProgressIndicator(
                    value: value,
                    minHeight: 7,
                    backgroundColor: theme.alternate.withValues(alpha: 0.25),
                    color: theme.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TMBroadcastSheet extends StatelessWidget {
  const _TMBroadcastSheet({required this.controller, required this.onCancel});

  final TMFlowController controller;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final subCategory = controller.selectedSubCategory;

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
          l10n.tmLookingForProvider,
          style: theme.titleMedium.override(
            font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          controller.hasFailed
              ? l10n.tmCouldNotSecureProvider
              : l10n.tmStayOnScreen,
          style: theme.bodyMedium.override(color: theme.secondaryText),
        ),
        const SizedBox(height: 16),
        if (subCategory != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.surfaceAlt,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.primary.withValues(alpha: 0.16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(subCategory.icon, color: theme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subCategory.title,
                        style: theme.bodyMedium.override(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${l10n.tmEstimate} ${subCategory.estimateLabel}',
                        style: theme.bodySmall.override(
                          color: theme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 14),
        _TMFactRow(
          icon: Icons.place_rounded,
          title: l10n.tmSearchRadius,
          subtitle: l10n.tmCurrentlyScanning,
        ),
        const SizedBox(height: 12),
        _TMFactRow(
          icon: Icons.info_outline_rounded,
          title: l10n.tmDynamicFees,
          subtitle: l10n.tmExpandedMayIncreaseFee,
        ),
        if ((controller.searchReferenceId ?? '').isNotEmpty) ...[
          const SizedBox(height: 12),
          _TMFactRow(
            icon: Icons.tag_rounded,
            title: l10n.tmSearchReference,
            subtitle: controller.searchReferenceId!,
          ),
        ],
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton(
            onPressed: controller.isCancellingBroadcast ? null : onCancel,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: controller.isCancellingBroadcast
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.tmCancelSearch),
          ),
        ),
      ],
    );
  }
}

class _TMFactRow extends StatelessWidget {
  const _TMFactRow({
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
                style: theme.bodyMedium.override(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.bodySmall.override(color: theme.secondaryText),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TMDispatchModeChip extends StatelessWidget {
  const _TMDispatchModeChip({required this.controller});

  final TMFlowController controller;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isServer = controller.isServerDispatchMode;
    final label = switch (controller.dispatchMode) {
      'server' => l10n.tmModeServer,
      'fallback' => l10n.tmModeFallback,
      _ => l10n.tmModePending,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isServer ? const Color(0xFFEFF9F1) : const Color(0xFFFFF5E8),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isServer ? const Color(0xFF87C995) : const Color(0xFFE3B46E),
        ),
      ),
      child: Text(
        label,
        style: theme.labelMedium.override(
          color: isServer ? const Color(0xFF246B38) : const Color(0xFF8A5A16),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _NoProviderFoundModal extends StatelessWidget {
  const _NoProviderFoundModal({
    required this.onSearchAgain,
    required this.onSchedule,
    required this.onCancelSearch,
  });

  final VoidCallback onSearchAgain;
  final VoidCallback onSchedule;
  final VoidCallback onCancelSearch;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.primaryBackground,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
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
              const SizedBox(height: 18),
              Text(
                l10n.tmNoProviderFound,
                style: theme.titleMedium.override(
                  font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.tmFinishedSearchWindows,
                style: theme.bodyMedium.override(color: theme.secondaryText),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: onSearchAgain,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: theme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(l10n.tmSearchAgain),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: onSchedule,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(l10n.tmScheduleInstead),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: TextButton(
                  onPressed: onCancelSearch,
                  child: Text(l10n.tmCancelSearch),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
