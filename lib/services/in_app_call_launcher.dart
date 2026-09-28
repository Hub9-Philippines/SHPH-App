import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:go_router/go_router.dart';

import '/l10n/app_localizations.dart';
import '/pages/chat_page/chat_page_widget.dart';
import '/services/call_session_controller.dart';
import '/services/call_signal_models.dart';
import '/services/logging_service.dart';

/// Single entry point for every "Call using the app" action outside a chat
/// room (service/product page, booking details, provider profile and the
/// contact-provider hand-off).
///
/// The call always happens *from inside* the direct chat room: the room is
/// pushed first, then the call is placed. The in-call surface is a global
/// overlay (`CallLayerHost` in `main.dart`), so the user can minimize it back
/// to a picture-in-picture bubble and keep reading the conversation. This is
/// the web app's behaviour — `ContactProviderPage.vue` calls
/// `router.push('/chat/:id')` and relies on the globally mounted
/// `VideoCallOverlay`, which has its own minimize control.
class InAppCallLauncher {
  const InAppCallLauncher._();

  /// Pushes the chat room for [threadId] and then places the call.
  ///
  /// [context] is only used for navigation and error snackbars, so callers
  /// should pass a still-mounted context and not await this from a `dispose`
  /// path. Errors are logged and surfaced via the messenger — the call
  /// failures are already reported inside the overlay.
  static Future<void> startInChatRoom({
    required BuildContext context,
    required String threadId,
    required String calleeId,
    required CallParticipant participant,
    webrtc.MediaStream? preAcquiredStream,
    CallMediaType mediaType = CallMediaType.audio,
  }) async {
    if (threadId.isEmpty || calleeId.isEmpty) {
      preAcquiredStream?._stopTracks();
      _showError(
        ScaffoldMessenger.maybeOf(context),
        AppLocalizations.of(context)?.csCallFailed,
      );
      return;
    }

    // Capture messenger + localized message before the first await: the
    // caller may be torn down while the route is being pushed.
    final messenger = ScaffoldMessenger.maybeOf(context);
    final failureMessage = AppLocalizations.of(context)?.csCallFailed;

    // Fire-and-forget on purpose. `pushNamed` completes only when the user
    // leaves the room, so awaiting it would delay the call until they back
    // out — the opposite of what we want. `.ignore()` discards the result and
    // any error: this navigation is fire-and-forget by design, and the call
    // below reports its own failures.
    context
        .pushNamed(
          ChatPageWidget.routeName,
          pathParameters: {'roomId': threadId},
          extra: <String, dynamic>{
            'providerName': participant.name,
            'providerPhoto': participant.photo,
          },
        )
        .ignore();

    try {
      await CallSessionController.instance.call(
        threadId: threadId,
        calleeId: calleeId,
        participant: participant,
        mediaType: mediaType,
        preAcquiredStream: preAcquiredStream,
      );
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to initiate in-app call',
        tag: 'InAppCallLauncher',
        error: e,
        stackTrace: stackTrace,
      );
      _showError(messenger, failureMessage);
    }
  }

  static void _showError(ScaffoldMessengerState? messenger, String? message) {
    if (message == null) {
      return;
    }
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }
}

extension on webrtc.MediaStream? {
  void _stopTracks() => this?.getTracks().forEach((t) => t.stop());
}
