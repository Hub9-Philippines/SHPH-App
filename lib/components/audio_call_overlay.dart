import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/l10n/app_localizations.dart';
import '/services/call_session_controller.dart';
import '/theme/app_theme.dart';

/// Full-screen AUDIO call overlay — mobile port of the web app's audio-only
/// call presentation (`VideoCallOverlay.vue` in its `.audio-only` mode):
/// - centered avatar with a pulsing ring while the call is not connected,
/// - name + a single status line (ringing / connecting / duration),
/// - control tray: mute, speaker, end call,
/// - a minimize control that collapses the call to a picture-in-picture
///   bubble so the user can drop back to the chat room mid-call.
///
/// Mounted globally by `CallLayerHost` (main.dart) above the router, so it
/// covers whatever screen is underneath — the chat room, once the in-app call
/// entry points have navigated there.
class AudioCallOverlay extends StatelessWidget {
  const AudioCallOverlay({super.key});

  /// Opaque call surface. The in-call UI is a deliberate full-bleed takeover
  /// (the chat room stays visible only when minimized), so it does not use
  /// the app theme surface colors.
  static const Color _backdrop = Color(0xFF101828);

  @override
  Widget build(BuildContext context) {
    final controller = CallSessionController.instance;
    if (controller.isMinimized) {
      return _MinimizedCallBubble(
        onExpand: controller.expand,
        onEnd: controller.endCall,
      );
    }
    return const Positioned.fill(child: _ExpandedAudioCall());
  }
}

class _ExpandedAudioCall extends StatefulWidget {
  const _ExpandedAudioCall();

  @override
  State<_ExpandedAudioCall> createState() => _ExpandedAudioCallState();
}

class _ExpandedAudioCallState extends State<_ExpandedAudioCall>
    with SingleTickerProviderStateMixin {
  final _controller = CallSessionController.instance;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _controller.addListener(_onStateChanged);
    _syncPulse();
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _pulseController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (!mounted) {
      return;
    }
    _syncPulse();
    setState(() {});
  }

  /// Pulses only while the call is waiting to connect; stops once connected
  /// or terminated. Also (re)starts when the overlay is rebuilt after being
  /// minimized and restored.
  void _syncPulse() {
    switch (_controller.state) {
      case CallUiState.outgoing:
      case CallUiState.ringing:
      case CallUiState.connecting:
        if (!_pulseController.isAnimating) {
          _pulseController.repeat(reverse: true);
        }
      case CallUiState.idle:
      case CallUiState.active:
      case CallUiState.ended:
      case CallUiState.failed:
        _pulseController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final participant = _controller.remoteParticipant;
    final name = participant?.name ?? '';
    final photo = participant?.photo;
    final isActive = _controller.state == CallUiState.active;
    final isEnded = _controller.state == CallUiState.ended ||
        _controller.state == CallUiState.failed;

    return Material(
      color: AudioCallOverlay._backdrop,
      child: SafeArea(
        child: Column(
          children: [
            _TopBar(
              title: name,
              subtitle: isEnded
                  ? _failureLabel(l10n)
                  : (isActive
                      ? _controller.formattedDuration
                      : _statusLabel(l10n)),
              // Minimizing a finished call makes no sense.
              onMinimize: isEnded ? null : _controller.minimize,
            ),
            const Spacer(flex: 2),
            // ── Avatar with pulse ring while connecting ──
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final t = _pulseController.value;
                return Container(
                  width: 148 + (26 * t),
                  height: 148 + (26 * t),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06 * (1 - t)),
                  ),
                  child: Center(
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      backgroundImage: photo != null && photo.isNotEmpty
                          ? NetworkImage(photo)
                          : null,
                      child: photo == null || photo.isEmpty
                          ? Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 38,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              name,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const Spacer(flex: 3),
            // ── Control tray: mute / speaker / end ──
            if (!isEnded)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ControlButton(
                      icon: _controller.isMuted
                          ? Icons.mic_off_rounded
                          : Icons.mic_rounded,
                      label: _controller.isMuted
                          ? l10n.callBtnUnmute
                          : l10n.callBtnMute,
                      background: _controller.isMuted
                          ? Colors.white
                          : Colors.white24,
                      iconColor: _controller.isMuted
                          ? AppTheme.of(context).error
                          : Colors.white,
                      onTap: _controller.toggleMute,
                    ),
                    _ControlButton(
                      icon: _controller.isSpeakerOn
                          ? Icons.volume_up_rounded
                          : Icons.hearing_rounded,
                      label: l10n.callBtnSpeaker,
                      onTap: _controller.toggleSpeaker,
                    ),
                    _ControlButton(
                      icon: Icons.call_end_rounded,
                      label: l10n.callBtnEnd,
                      background: AppTheme.of(context).error,
                      size: 68,
                      onTap: _controller.endCall,
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _controller.dismissCallOutcome,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AudioCallOverlay._backdrop,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      l10n.ccDone,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AudioCallOverlay._backdrop,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n) {
    switch (_controller.state) {
      case CallUiState.outgoing:
      case CallUiState.ringing:
        return l10n.cpCallingRinging;
      case CallUiState.connecting:
        return l10n.cpCallingConnecting;
      case CallUiState.idle:
      case CallUiState.active:
      case CallUiState.ended:
      case CallUiState.failed:
        return '';
    }
  }

  String _failureLabel(AppLocalizations l10n) {
    switch (_controller.lastEndReason) {
      case 'noAnswer':
        return l10n.csNoAnswer;
      case 'mediaDenied':
        return l10n.csMediaDenied;
      case 'connectionFailed':
        return l10n.csConnectionFailed;
      case 'cameraRequired':
        return l10n.csCameraNeeded;
      case 'declined':
        return l10n.csCallDeclined;
      default:
        return l10n.callEndedText;
    }
  }
}

/// Shared top bar for the expanded call overlays: identity + single status
/// line on the left, minimize on the right.
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.subtitle,
    required this.onMinimize,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onMinimize;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onMinimize,
            tooltip: l10n.callBtnMinimize,
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }
}

/// Collapsed call bubble — the call stays live while the user reads the chat
/// room. Tap to restore the full panel; the end button hangs up.
class _MinimizedCallBubble extends StatelessWidget {
  const _MinimizedCallBubble({required this.onExpand, required this.onEnd});

  final VoidCallback onExpand;
  final Future<void> Function() onEnd;

  @override
  Widget build(BuildContext context) {
    final controller = CallSessionController.instance;
    final l10n = AppLocalizations.of(context)!;
    final theme = AppTheme.of(context);
    final participant = controller.remoteParticipant;
    final name = participant?.name ?? '';
    final photo = participant?.photo;
    final isActive = controller.state == CallUiState.active;
    final status = isActive
        ? controller.formattedDuration
        : (controller.state == CallUiState.connecting
            ? l10n.cpCallingConnecting
            : l10n.cpCallingRinging);

    return Positioned(
      right: 16,
      bottom: 96 + MediaQuery.of(context).padding.bottom,
      child: Material(
        color: AudioCallOverlay._backdrop,
        elevation: 8,
        shadowColor: Colors.black54,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onExpand,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white.withValues(alpha: 0.14),
                  backgroundImage:
                      photo != null && photo.isNotEmpty
                          ? NetworkImage(photo)
                          : null,
                  child: photo == null || photo.isEmpty
                      ? Icon(Icons.person_rounded,
                          color: Colors.white.withValues(alpha: 0.8))
                      : null,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      status,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 6),
                IconButton(
                  onPressed: onEnd,
                  tooltip: l10n.callBtnEnd,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.call_end_rounded,
                      color: theme.error, size: 24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.background = Colors.white24,
    this.iconColor = Colors.white,
    this.size = 62,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color iconColor;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: background,
          borderRadius: BorderRadius.circular(size / 2),
          child: InkWell(
            borderRadius: BorderRadius.circular(size / 2),
            onTap: onTap,
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(icon, color: iconColor, size: size * 0.42),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
