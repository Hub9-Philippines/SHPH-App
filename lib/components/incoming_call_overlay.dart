import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/call_accept_permission_sheet.dart';
import '/l10n/app_localizations.dart';
import '/services/call_signal_models.dart';
import '/services/call_session_controller.dart';
import '/theme/app_theme.dart';

/// Top banner overlay shown when a `call_initiate` signal rings the app.
/// Mirrors the web's `IncomingCallOverlay.vue`: accept routes through the
/// mic/camera permission sheet before connecting; decline rejects via REST +
/// signal.
class IncomingCallOverlay extends StatelessWidget {
  const IncomingCallOverlay({super.key});

  /// Pushes the overlay above everything on the root navigator.
  static Future<void> show(BuildContext context) {
    return Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: false,
        pageBuilder: (_, __, ___) => const IncomingCallOverlay(),
        transitionsBuilder: (_, animation, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = CallSessionController.instance;
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final caller = controller.incomingCaller;
    final isVideo = controller.mediaType == CallMediaType.video;
    final callerName = caller?.name ?? l10n.csIncomingCall;
    final photo = caller?.photo;

    return WillPopScope(
      onWillPop: () async => false,
      child: Material(
        color: Colors.black54,
        child: Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: theme.primary.withValues(alpha: 0.12),
                        backgroundImage:
                            photo != null && photo.isNotEmpty
                                ? NetworkImage(photo)
                                : null,
                        child: photo == null || photo.isEmpty
                            ? Text(
                                callerName.isNotEmpty
                                    ? callerName[0].toUpperCase()
                                    : '?',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  color: theme.primary,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.csIncomingCall,
                              style: theme.labelSmall.override(
                                font: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w600,
                                ),
                                color: theme.secondaryText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              callerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isVideo
                            ? Icons.videocam_rounded
                            : Icons.phone_rounded,
                        color: theme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final navigator = Navigator.of(context);
                            await controller.declineIncomingCall();
                            navigator.pop();
                          },
                          icon: const Icon(Icons.call_end_rounded, size: 18),
                          label: Text(l10n.callBtnEnd),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFE5484D),
                            side: const BorderSide(color: Color(0xFFE5484D)),
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () async {
                            final navigator = Navigator.of(context);
                            // Accept is gated on mic (and camera) permissions;
                            // the gate also acquires the media stream so the
                            // call never starts without working input devices.
                            await CallAcceptPermissionSheet.show(
                              context,
                              callType: isVideo
                                  ? CallType.video
                                  : CallType.audio,
                              onMediaAcquired: (stream) {
                                navigator.pop(); // remove the overlay first
                                CallSessionController.instance
                                    .acceptIncomingCall(
                                  preAcquiredStream: stream,
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.call_rounded, size: 18),
                          label: Text(l10n.callPermAllow),
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.primary,
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
