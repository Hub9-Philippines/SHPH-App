# Design — Add In-App Calling

## Context

The backend already implements the whole call pipeline the web app uses: REST lifecycle (`/api/chat/calls/initiate|accept|reject|end|sfu-token/`) plus a websocket at `wss://<api-host>/ws` that carries `call_signal` envelopes. The Flutter app currently fires only the REST initiate (201 in logs) and has no realtime layer — no websocket, no WebRTC (`flutter_webrtc` absent from pubspec), no call UI. The web app (`shph-web`) is the parity reference: `websocketService.ts` (~1,000 lines), `webrtcService.ts` (~1,450 lines, direct + group), store, and overlay components (`IncomingCallOverlay.vue`, `VideoCallOverlay.vue`). Permissions (mic/camera) are already declared and gated in-app via `CallAcceptPermissionSheet`.

## Goals / Non-Goals

**Goals:**
- 1:1 direct audio + video calls between app users, and between an app user and a web user (same signaling protocol).
- Faithful port of the web signaling protocol so both clients interoperate against the same backend.
- Call UX: outgoing (ringing → connecting → in-call), incoming overlay with accept/decline, in-call controls (mute, speaker/camera, end, duration).
- Graceful failure: no half-open calls when the socket is down, permissions denied, or the remote hangs up.

**Non-Goals:**
- Group calls (`groupCallService.ts` / mediasoup SFU topology) — direct mesh calls only.
- Push-notification-driven incoming calls while the app is killed/backgrounded (web parity for `__SHPH_PENDING_CALL__` is deferred; the app has no FCM wiring yet).
- Call history UI beyond what already exists (`call_history_details_page`).

## Decisions

- **Port the web protocol, not the web code.** The signaling contract (`{ type: "call_signal", data: { type, threadId, targetUserId, callId, sdp, candidate, mediaType } }`, snake_case over the wire — see below) is copied exactly; the implementation is idiomatic Dart singletons, not a class-for-class transliteration. Rationale: the web service carries browser-specific baggage (visibility handling, IndexedDB cache integration, group/SFU branches) that doesn't apply.
- **Websocket**: `web_socket_channel` with the JWT passed as the `shph-auth` subprotocol (matches web; keeps the token out of URLs). Auto-reconnect with exponential backoff + heartbeat; a handler registry keyed by message `type` so chat/call features subscribe independently (mirrors `addMessageHandler`). URL derived from `ApiConfig.baseUrl` (https→wss, host preserved, path `/ws`).
- **WebRTC**: `flutter_webrtc` (de-facto standard; RTCPeerConnection API mirrors the web's, making the port mechanical). Mesh topology (no SFU) for 1:1; `sfu-token` endpoint left unused until group calls. Perfect-negotiation pattern (polite/impolite) as in the web service: caller = impolite, callee = polite.
- **State**: `CallSessionController` (plain `ChangeNotifier`, consistent with the app's provider usage) exposing `callState` (`idle/outgoing/ringing/connecting/active/ended/failed`), participant info, mute/speaker flags, duration. UI screens/overlay watch it; the service owns the connection lifecycle.
- **UI surfaces**: a full-screen outgoing/in-call page (`lib/pages/call/call_screen_widget.dart`) pushed onto the navigator, and a top incoming-call overlay widget shown globally (navigator observer / overlay insertion) so any screen can receive a call — mirroring the web's `IncomingCallOverlay.vue` mounted in the app shell. Incoming flow reuses `CallAcceptPermissionSheet` before accept.
- **Wire format detail**: the web client sends camelCase keys (`threadId`, `targetUserId`, `callId`, `mediaType`) inside `call_signal.data`; the backend relays them verbatim. The Dart port sends/parses the same camelCase keys for interoperability.
- **Call entry points**: product page and booking details switch `_initiateInAppCall` from "REST initiate only" to `CallSessionController.call(...)` which performs permission gate → REST initiate → socket signal → UI. The existing direct-thread resolution (incl. the 404 fallback chain added earlier) is reused.

## Risks / Trade-offs

- **`flutter_webrtc` binary size** (~15–20 MB per ABI). Accepted; calling is a core marketplace feature. Mitigation: none needed beyond awareness for APK size CI artifact.
- **Background/locked-screen incoming calls won't ring** (no FCM/data-push path yet) — the websocket only delivers while the app is foregrounded. Documented limitation until push is added; web has the same gap on some browsers.
- **Android audio focus / speakerphone routing** needs `flutter_webrtc`'s audio manager configuration (speaker vs earpiece for audio-only). Include a manual device-lab check on the tasks list.
- **iOS CallKit not included**: calls won't show as native UI. Deferred; acceptable for parity-first scope.
- **NAT traversal**: backend TURN/STICE config is whatever the server hands out; no local ICE servers hardcoded. If the web app works in the same networks, this should too.
- **Pubspec pin discipline**: only additive deps; existing `dependency_overrides` untouched.
