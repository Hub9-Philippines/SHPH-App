import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/services/face_verification/face_verification_service.dart';

/// Wrapper widget that enforces face verification for sensitive actions
///
/// Usage:
/// ```dart
/// SensitiveActionWrapper(
///   action: () async { /* payment code */ },
///   sessionTimeoutMinutes: 15,
///   child: ElevatedButton(
///     onPressed: null,
///     child: Text('Pay'),
///   ),
/// )
/// ```
class SensitiveActionWrapper extends StatefulWidget {
  const SensitiveActionWrapper({
    required this.action,
    required this.userId,
    required this.child,
    Key? key,
    this.sessionTimeoutMinutes = 15,
    this.faceScannerRoute = 'FaceVerification',
    this.loadingMessage = 'Processing...',
    this.onVerificationNeeded,
    this.onActionComplete,
  }) : super(key: key);

  /// The async action to execute after verification
  final Future<void> Function() action;

  /// User ID for session age check
  final String userId;

  /// Minutes after which session is considered old and needs re-verification
  final int sessionTimeoutMinutes;

  /// Route name for face scanner (e.g., 'FaceScanner')
  final String faceScannerRoute;

  /// Loading message shown during action execution
  final String loadingMessage;

  /// Callback when re-verification is needed
  final VoidCallback? onVerificationNeeded;

  /// Callback when action completes successfully
  final VoidCallback? onActionComplete;

  /// The button or widget to wrap
  final Widget child;

  @override
  State<SensitiveActionWrapper> createState() => _SensitiveActionWrapperState();
}

class _SensitiveActionWrapperState extends State<SensitiveActionWrapper> {
  late FaceVerificationService _faceVerificationService;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _faceVerificationService = FaceVerificationService();
  }

  Future<void> _handleSensitiveAction() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      // Check if session is older than threshold
      final isSessionStale = await _faceVerificationService.isSessionOlderThan(
        widget.userId,
        widget.sessionTimeoutMinutes,
      );

      if (isSessionStale && mounted) {
        // Session is stale, require re-verification
        widget.onVerificationNeeded?.call();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Your session has expired. Please verify your face again.'),
              duration: Duration(seconds: 3),
            ),
          );

          // Navigate to face scanner for re-verification
          context.goNamed(widget.faceScannerRoute);
          setState(() => _isProcessing = false);
          return;
        }
      }

      // Session is fresh, proceed with action
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.loadingMessage),
            duration: const Duration(seconds: 10),
          ),
        );
      }

      // Execute the sensitive action
      await widget.action();

      widget.onActionComplete?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Action completed successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: _isProcessing ? null : _handleSensitiveAction,
        child: Stack(
          children: [
            // Original widget with opacity when processing
            Opacity(
              opacity: _isProcessing ? 0.6 : 1.0,
              child: IgnorePointer(
                ignoring: _isProcessing,
                child: widget.child,
              ),
            ),
            // Loading indicator overlay
            if (_isProcessing)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}
