import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '/app_state.dart';
import '/components/cupertino_ui/app_activity_indicator.dart';
import '/components/cupertino_ui/app_button.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';
import '../booking_funnel/widgets/booking_flow_route.dart';
import 'tm_controller.dart';
import 'tm_invoice_screen.dart';
import 'tm_models.dart';

class TMActiveJobScreen extends StatefulWidget {
  const TMActiveJobScreen({super.key});

  static const String routeName = 'TMActiveJob';
  static const String routePath = '/tm/active-job';

  @override
  State<TMActiveJobScreen> createState() => _TMActiveJobScreenState();
}

class _TMActiveJobScreenState extends State<TMActiveJobScreen> {
  StreamSubscription<TMHardwareRequest>? _hardwareSubscription;
  bool _dialogVisible = false;
  bool _navigatedToInvoice = false;
  String? _lastShownError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final controller = context.read<TMFlowController>()..beginActiveJob();
      _hardwareSubscription = controller.hardwareRequests.listen(
        _showHardwareDialog,
      );
    });
  }

  @override
  void dispose() {
    _hardwareSubscription?.cancel();
    super.dispose();
  }

  Future<void> _showHardwareDialog(TMHardwareRequest request) async {
    if (!mounted || _dialogVisible) {
      return;
    }
    _dialogVisible = true;
    await showCupertinoDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => HardwareApprovalDialog(request: request),
    );
    _dialogVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final appState = FFAppState();
    final location = LatLng(
      appState.selectedLatitude ?? 14.5995,
      appState.selectedLongitude ?? 120.9842,
    );

    return Consumer<TMFlowController>(
      builder: (context, controller, _) {
        _handleControllerErrors(controller);
        final l10n = AppLocalizations.of(context)!;
        final provider = controller.matchedProvider;
        if (provider == null) {
          return const SizedBox.shrink();
        }

        if (controller.jobCompleted && !_navigatedToInvoice) {
          _navigatedToInvoice = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            Navigator.of(context).push(
              buildBookingFlowRoute(
                ChangeNotifierProvider.value(
                  value: controller,
                  child: const TMInvoiceScreen(),
                ),
              ),
            );
          });
        }

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: theme.primaryBackground,
            appBar: AppBar(
              backgroundColor: theme.primaryBackground,
              elevation: 0,
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              title: Text(
                l10n.tmActiveJob,
                style: theme.titleLarge.override(
                  font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                ),
              ),
              bottom: TabBar(
                labelColor: theme.primary,
                unselectedLabelColor: theme.secondaryText,
                indicatorColor: theme.primary,
                tabs: [
                  Tab(text: l10n.tmTabMap),
                  Tab(text: l10n.tmTabChat),
                  Tab(text: l10n.tmTabProvider),
                ],
              ),
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Column(
                    children: [
                      _TMProviderArrivalCard(provider: provider),
                      if (controller.dispatchMode != null) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _TMDispatchStatusPill(controller: controller),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _TMTrackingTab(
                        location: location,
                        provider: provider,
                        onComplete: () async {
                          await controller.completeJob(l10n);
                        },
                      ),
                      _TMChatTab(provider: provider),
                      _TMProviderProfileTab(provider: provider),
                    ],
                  ),
                ),
              ],
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      controller.clearLastError();
    });
  }
}

class _TMDispatchStatusPill extends StatelessWidget {
  const _TMDispatchStatusPill({required this.controller});

  final TMFlowController controller;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isServer = controller.isServerDispatchMode;
    final label = switch (controller.dispatchMode) {
      'server' => l10n.tmDispatchServer,
      'fallback' => l10n.tmDispatchFallback,
      _ => l10n.tmDispatchPending,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

class HardwareApprovalDialog extends StatelessWidget {
  const HardwareApprovalDialog({required this.request, super.key});

  final TMHardwareRequest request;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final controller = context.read<TMFlowController>();
    return CupertinoAlertDialog(
      title: Text(
        l10n.tmHwTitle,
        style: theme.titleMedium.override(
          font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request.description,
              style: theme.bodyMedium.override(color: theme.secondaryText),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.surfaceAlt,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: theme.primary.withValues(alpha: 0.18)),
              ),
              child: Text(
                l10n.tmAdditionalCost(
                  request.additionalCost.toStringAsFixed(0),
                ),
                style: theme.titleSmall.override(
                  color: theme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: controller.isUpdatingHardware
              ? null
              : () async {
                  final success = await controller.rejectHardwareRequest(l10n);
                  if (context.mounted && success) {
                    Navigator.of(context).pop();
                  }
                },
          child: controller.isUpdatingHardware
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: AppActivityIndicator(radius: 9),
                )
              : Text(l10n.tmReject),
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: controller.isUpdatingHardware
              ? null
              : () async {
                  final success = await controller.approveHardwareRequest(l10n);
                  if (context.mounted && success) {
                    Navigator.of(context).pop();
                  }
                },
          child: controller.isUpdatingHardware
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: AppActivityIndicator(radius: 9),
                )
              : Text(l10n.tmApprove),
        ),
      ],
    );
  }
}

class _TMProviderArrivalCard extends StatelessWidget {
  const _TMProviderArrivalCard({required this.provider});

  final TMProviderProfile provider;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.alternate),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: theme.primary.withValues(alpha: 0.12),
            child: Icon(
              Icons.person_rounded,
              size: 26,
              color: theme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.name.isEmpty ? l10n.tmProviderFallback : provider.name,
                  style: theme.bodyLarge.override(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '${provider.specialty.isEmpty ? l10n.tmProviderDefault : provider.specialty} • ${l10n.tmEtaFormat(provider.etaMinutes.toString())}',
                  style: theme.bodySmall.override(color: theme.secondaryText),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              l10n.tmOnTheWay,
              style: theme.labelMedium.override(
                color: theme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TMTrackingTab extends StatelessWidget {
  const _TMTrackingTab({
    required this.location,
    required this.provider,
    required this.onComplete,
  });

  final LatLng location;
  final TMProviderProfile provider;
  final Future<void> Function() onComplete;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Stack(
      children: [
        Positioned.fill(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(target: location, zoom: 16),
            zoomControlsEnabled: false,
            compassEnabled: false,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            scrollGesturesEnabled: false,
            zoomGesturesEnabled: false,
            markers: {
              Marker(
                markerId: const MarkerId('tm_job_pin'),
                position: location,
              ),
            },
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Consumer<TMFlowController>(
            builder: (context, controller, _) => Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: theme.primaryBackground.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppThemeData.shadowCard,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.tmLiveJobTracking,
                    style: theme.titleSmall.override(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.tmHeadingToLocation(provider.name),
                    style: theme.bodySmall.override(
                      color: theme.secondaryText,
                    ),
                  ),
                  if (controller.approvedHardwareCost > 0) ...[
                    const SizedBox(height: 12),
                    Text(
                      l10n.tmApprovedHardware(
                        controller.approvedHardwareCost.toStringAsFixed(0),
                      ),
                      style: theme.bodyMedium.override(
                        color: theme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: AppButton(
                      onPressed:
                          controller.isCompletingJob ? null : onComplete,
                      backgroundColor: theme.primary,
                      borderRadius: 16,
                      loading: controller.isCompletingJob,
                      child: Text(l10n.tmMarkJobComplete),
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

class _TMChatTab extends StatelessWidget {
  const _TMChatTab({required this.provider});

  final TMProviderProfile provider;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    const messages = [
      ('Provider', 'I’m on the way to your location now.'),
      ('You', 'Thanks, I’ll keep my phone nearby.'),
      ('Provider', 'I may need to inspect the hardware first before I start.'),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final message = messages[index];
        final isUser = message.$1 == 'You';
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 280),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isUser
                  ? theme.primary.withValues(alpha: 0.12)
                  : theme.secondaryBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isUser
                    ? theme.primary.withValues(alpha: 0.20)
                    : theme.alternate,
              ),
            ),
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  message.$1,
                  style: theme.labelMedium.override(
                    color: theme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(message.$2, style: theme.bodyMedium),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TMProviderProfileTab extends StatelessWidget {
  const _TMProviderProfileTab({required this.provider});

  final TMProviderProfile provider;

  String _localizedVehicleLabel(AppLocalizations l10n, String label) {
    switch (label) {
      case 'Nearby service unit':
        return l10n.tmVehicleNearby;
      case 'Expanded-area service unit':
        return l10n.tmVehicleExpanded;
      case 'Service unit':
        return l10n.tmVehicleFallback;
      default:
        return label;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.alternate),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                provider.name.isEmpty ? l10n.tmProviderFallback : provider.name,
                style: theme.titleMedium.override(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                provider.specialty.isEmpty ? l10n.tmProviderDefault : provider.specialty,
                style: theme.bodyMedium.override(color: theme.secondaryText),
              ),
              const SizedBox(height: 16),
              _ProfileStat(
                label: l10n.tmRating,
                value: provider.rating.toStringAsFixed(1),
              ),
              const SizedBox(height: 10),
              _ProfileStat(
                label: l10n.tmCompletedJobs,
                value: provider.completedJobs.toString(),
              ),
              const SizedBox(height: 10),
              _ProfileStat(
                label: l10n.tmVehicle,
                value: _localizedVehicleLabel(l10n, provider.vehicleLabel),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.bodySmall.override(color: theme.secondaryText),
          ),
        ),
        Text(
          value,
          style: theme.bodyMedium.override(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
