## Why

Direct audio/video calls exist end-to-end on mobile (WebRTC port, signaling, call screen, incoming overlay, chat-room buttons from the previous change), but they fail in the field: the entry points that call `CallSessionController.call()` directly bypass the media-permission gate, so `getUserMedia` fails on the first call and the UI sticks in "connecting"; neither side has a timeout, so unanswered calls hang forever; the socket is not refreshed on app resume, so incoming calls are missed after backgrounding; and the speakerphone flag is never applied to the device, so video calls play through the earpiece. The web reference (`shph-web`) gates every call entry through a permission sheet that pre-acquires media before the call starts, and its store tears down on ended state — mobile must match that reliability.

## What Changes

- **Permission gate on every call entry point** — the in-app-call choices in product page, booking details, and contact provider route through the existing `CallAcceptPermissionSheet` (as the chat room already does), pre-acquiring the local stream (`preAcquiredStream`) so the call never starts without media. Video calls require a camera track: a videoless acquisition (camera blocked/busy) is treated as denied, not silently degraded to audio.
- **Honest media-failure handling** — when local media or the peer connection fails, the call UI reports a failed state with a clear message instead of an indefinite spinner; the session controller resets so the user can retry immediately.
- **Caller no-answer timeout** — if the callee does not accept within 45s of `call_initiate`, the caller's UI ends with a "no answer" outcome (call record ended via REST, `call_end` signal, session reset). Web has no timer; this is a mobile-appropriate bounded ring adopted from standard call UX.
- **Callee ring timeout** — if the user does not act on an incoming call within 45s, the overlay auto-declines (REST reject + `call_reject`), so a lost `call_end` frame cannot leave a stuck banner.
- **Socket lifecycle on app resume** — when the app returns to foreground, the websocket service verifies liveness (fresh heartbeat) and reconnects immediately if the socket is stale, closing the window where incoming `call_initiate` frames are missed.
- **Speakerphone routing applied** — the session controller pushes `setSpeakerphoneOn(true)` for video calls (and the user's speaker toggle during any call) to the device audio stack when the call connects.
- **Accept-path media retry** — if media acquisition fails on accept (permission revoked mid-ring), the accept is aborted with a failed state and REST rejection, rather than connecting with no local stream.

## Capabilities

### New Capabilities
- `direct-calling-reliability`: Reliability contract for 1:1 WebRTC calling on mobile — permission-gated media acquisition on every entry point, bounded ring timeouts on both sides, honest failure states for media/connection errors, foreground socket liveness, and device audio routing.

### Modified Capabilities

## Impact

- `lib/services/call_session_controller.dart` (timeouts, failure states, speaker push, media handoff), `lib/services/webrtc_call_service.dart` (media-failure surfacing, no-answer hook), `lib/services/websocket_service.dart` (resume liveness check)
- Call entry points: `lib/pages/product_page/product_page_widget.dart`, `lib/pages/booking_details/booking_details_widget.dart`, `lib/pages/contact_provider/contact_provider_widget.dart` (route through permission sheet)
- `lib/components/incoming_call_overlay.dart` (ring timeout auto-decline), `lib/pages/call/call_screen_widget.dart` (failed state UI)
- `lib/main.dart` (lifecycle observer wiring)
- No backend changes; no new dependencies (`permission_handler` and `flutter_webrtc` already present; iOS plist and Android manifest permissions already declared).
