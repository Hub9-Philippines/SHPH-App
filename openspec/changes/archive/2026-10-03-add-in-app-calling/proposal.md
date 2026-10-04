# Add In-App Calling

## Why

Tapping "Call using app" creates the call record via `POST /api/chat/calls/initiate/` (verified 201 in logs) but nothing happens afterwards: the Flutter app has no WebRTC stack, no websocket signaling, and no call UI, so the call record stays `initiated` and nobody is rung. The reference web app (`shph-web`) has a complete, working implementation of this exact flow against the same backend; the mobile app needs parity.

## What Changes

- Add a websocket signaling client for the app (`wss://<api-host>/ws`, JWT via `shph-auth` subprotocol) with reconnect + message-handler registry — port of the web `websocketService.ts`.
- Add a WebRTC call service (`flutter_webrtc`) implementing the direct 1:1 call flow: `call_initiate` / `call_accept` / `call_reject` / `call_end` + `webrtc_offer` / `webrtc_answer` / `ice_candidate` signaling over the socket — port of the web `webrtcService.ts` (direct-call subset; group calls out of scope).
- REST call lifecycle integration: `initiate` (exists), `accept`, `reject`, `end`, `sfu-token` (added to `ShphChatApi`).
- Add call UI: outgoing-call screen (ringing/connecting/duration), incoming-call overlay (accept/decline with the existing `CallAcceptPermissionSheet` mic/camera gate), in-call screen with mute / speaker / end controls and remote audio/video rendering.
- Wire the existing "Call using app" entry points (product page, booking details) to the new service instead of firing the REST call and doing nothing.
- Microphone/camera permissions already declared on Android/iOS; no manifest changes required.

## Capabilities

### New Capabilities
- `in-app-calling`: realtime 1:1 audio/video calling between client and provider over the SHPH websocket + WebRTC, including incoming-call handling and call lifecycle UI.

### Modified Capabilities

## Impact

- **New deps**: `flutter_webrtc` (+ `web_socket_channel` if not transitively present). Pubspec pins must not be touched.
- **New files**: `lib/services/websocket_service.dart`, `lib/services/webrtc_call_service.dart`, call pages/overlay under `lib/pages/call/` and `lib/components/`, router entries in `lib/router/app_router.dart`.
- **Modified files**: `lib/api/resources/chat_api.dart` (accept/reject/end/sfu-token), `lib/pages/product_page/product_page_widget.dart` + `lib/pages/booking_details/booking_details_widget.dart` (call entry points), `lib/main.dart` or app shell (service init), `pubspec.yaml`.
- **Backend**: none — the deployed API already provides all REST endpoints and the `/ws` signaling channel used by the web app.
- **Cross-platform note**: web-app callers can ring app users and vice versa once both sides run the signaling flow; app-side receiving requires the websocket service to be initialized at app start.
