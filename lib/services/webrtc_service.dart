import '/services/logging_service.dart';

/// WebRTC Video Call Service (Stub — Phase 5 Deferred)
///
/// This is a placeholder service for WebRTC video calls.
/// The web app uses Django Channels + WebRTC for signaling.
/// The mobile app will need a signaling server (either Supabase Realtime
/// or a dedicated WebSocket server) to fully implement this feature.
///
/// To complete this feature:
/// 1. Add `flutter_webrtc` dependency to pubspec.yaml
/// 2. Set up signaling via Supabase Realtime (subscribe to call events)
/// 3. Create a `video_calls` table for call metadata
/// 4. Implement call screen with local/remote video rendering
/// 5. Handle ICE candidate exchange via realtime channels
class WebRTCService {
  WebRTCService._();
  static final WebRTCService instance = WebRTCService._();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    // TODO: Initialize WebRTC peer connection factory
    // await FlutterWebRTC.createPeerConnection(configuration);
    _isInitialized = true;
    LoggingService.info('WebRTC service initialized (stub)',
        tag: 'WebRTCService');
  }

  Future<void> startCall(String recipientId) async {
    // TODO: Create offer SDP, set local description, send via signaling
    LoggingService.info('WebRTC startCall to $recipientId (stub — not implemented)',
        tag: 'WebRTCService');
    throw UnimplementedError(
        'WebRTC video calls are not yet implemented. '
        'See WebRTCService documentation for implementation steps.');
  }

  Future<void> endCall() async {
    // TODO: Close peer connection, notify remote party
    LoggingService.info('WebRTC endCall (stub)', tag: 'WebRTCService');
  }

  Future<void> acceptCall(String callId) async {
    // TODO: Create answer SDP, set local description, send via signaling
    LoggingService.info('WebRTC acceptCall $callId (stub — not implemented)',
        tag: 'WebRTCService');
    throw UnimplementedError(
        'WebRTC video calls are not yet implemented. '
        'See WebRTCService documentation for implementation steps.');
  }

  Future<void> declineCall(String callId) async {
    // TODO: Notify caller of decline via signaling
    LoggingService.info('WebRTC declineCall $callId (stub)',
        tag: 'WebRTCService');
  }

  void dispose() {
    _isInitialized = false;
  }
}
