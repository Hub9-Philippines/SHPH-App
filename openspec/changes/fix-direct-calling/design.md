See proposal.md for motivation. The engine (`ShphWebRTCCallService`) is already a faithful port of the web `webrtcService.ts` — signaling envelope, perfect-negotiation roles, ICE handling, and REST call lifecycle all match. The defects are in the layers around it.

Current-state facts driving the design:

- `CallAcceptPermissionSheet` exists and works (used by product page's `_startInAppCall` and the chat room's accept flow), but booking details' `_initiateInAppCall` and contact provider call `CallSessionController.call()` directly — `getUserMedia` then throws `NotAllowedError` on a fresh install and the controller only shows a generic `csCallFailed` snack after the fact.
- The sheet requests OS permissions but does NOT acquire media; `preAcquiredStream` in `ShphWebRTCCallService` exists for exactly this handoff and is currently never set by any caller.
- Neither side has a ring timer: web relies on the caller giving up manually, which on mobile means an "outgoing" screen with no exit except back-press, and an incoming banner that can persist after a dropped socket ate the `call_end`.
- `_onServiceStatus('ended')` schedules a 600ms reset-to-idle; but media failures inside `acceptCall` throw into `CallUiState.failed` with no UI path out (the call screen auto-pops only on `idle`/`ended`, not `failed`).
- `isSpeakerOn` defaults true and `setSpeakerphoneOn` exists, but nothing calls it on connect; Android routes WebRTC output to the earpiece by default.
- `main.dart` connects the socket on auth and app start only; no lifecycle observer exists anywhere, so a resumed app can sit on a half-dead socket until the 45s silence window trips the reconnect.

## Goals / Non-Goals

**Goals**
- Every call entry point produces a working call on first use.
- Bounded, honest call states: no infinite spinner, no immortal banner.
- Missed-call window after backgrounding closed.
- Speaker routing matches the UI.

**Non-Goals**
- No group/SFU calls, captions, call settings, or bitrate capping (web has them; mobile tracks them separately).
- No push-notification-driven call UX (needs FCM plumbing, separate change).
- No changes to signaling wire format or backend.
- No audio-session management beyond speaker routing (Bluetooth headsets, etc. — `flutter_webrtc` handles the basics; deeper `audio_session` config is a follow-up if field testing shows issues).

## Decisions

**D1 — Permission sheet acquires media; every entry goes through it.**
Extend `CallAcceptPermissionSheet`: after OS permissions grant, call `ShphWebRTCCallService.instance.getLocalMedia(callType)` and hold the stream; on sheet close-without-grant, stop the tracks. Add a `preAcquiredStream` handoff (the engine field already exists) via a callback `onMediaAcquired(stream)` — entry points pass it to `CallSessionController.call(preAcquiredStream: ...)`, which forwards to the engine. For the video-without-camera rule: after acquisition, check `stream.getVideoTracks().isNotEmpty` when `callType == video`; if empty, stop tracks and show the sheet's denied state with a camera-required message.
Booking details, contact provider, and product page switch to: `CallAcceptPermissionSheet.show(... onPermissionGranted → controller.call(...))`. The chat room's incoming-accept path already does this — it just gains the media handoff. Alternative (requesting permissions inside the controller) was rejected: the sheet is the UX web parity and already handles permanently-denied → open-settings.

**D2 — 45s timers in `CallSessionController`, not the engine.**
The controller owns UX state, so it owns the ring timers: `Timer? _ringTimer` started in `call()` (outgoing) and on `state == ringing` (incoming); cancelled on `connected`/`ended`/explicit user action. Outgoing timeout: show localized "no answer" feedback, call `endCall()` (which already does REST end + `call_end` + cleanup), then idle. Incoming timeout: call `declineIncomingCall()` (REST reject + `call_reject` + reset) and dismiss the banner. 45s chosen to match the heartbeat-silence reconnect window so a dead-socket caller does not ring a phone that cannot answer. Timers are cancelled in `resetAfterLogout`.

**D3 — `failed` becomes a real terminal state in the call screen.**
`call_screen_widget` treats `CallUiState.failed` like `ended` (show `_controller.lastEndReason`-derived message + auto-pop after the same 600ms settle), and `lastEndReason` gains values: `noAnswer`, `mediaDenied`, `cameraRequired`, `connectionFailed`. The controller maps engine failures: wrap the `acceptCall` media acquisition — on throw, REST-reject the call, set `failed` + `mediaDenied`, notify. Peer-connection failure already notifies `'ended'` via `onConnectionState`; the engine change is to surface *why* — add an optional failure callback `onCallFailed(String reason)` invoked from `onConnectionState(failed)` and from media errors, which the controller translates to state + reason.

**D4 — Lifecycle observer calls a socket liveness probe.**
Add `AppLifecycleObserver` (a `WidgetsBindingObserver` in `main.dart`'s app shell state) that on `resumed` calls `ShphWebSocketService.instance.ensureAlive()`: if `_channel == null` → `connect()`; else if `DateTime.now().difference(_lastInbound) > heartbeat interval` → force-close (triggers the existing bounded reconnect). Healthy sockets do nothing — no churn. This mirrors the web's visibilitychange handler without duplicating its full reconnect logic. Also: while a call is active, `ensureAlive` additionally pings immediately so ICE/media don't fight a reconnecting socket.

**D5 — Speaker routing applied on connect and on toggle.**
In `_onServiceStatus('connected')`: `setSpeakerphoneOn(mediaType == video ? isSpeakerOn : false)` — audio calls keep earpiece default (phone-call convention), video calls force speaker. The existing speaker toggle button already calls `toggleSpeaker()` which applies via `setSpeakerphoneOn`; it stays, but now the initial state is actually pushed. iOS: `flutter_webrtc`'s `Helper.setSpeakerphoneOn` routes through AVAudioSession on iOS 13+; verified the plugin handles it — no platform channel work needed.

**D6 — Engine keeps its public API; one new callback.**
`ShphWebRTCCallService` gains `onCallFailed` and a small guard: `acceptCall()` rethrows media errors (it currently propagates from `getLocalMedia` — controller catches). No renegotiation of the wire format; `call_signal` payloads stay byte-compatible with web.

## Risks / Trade-offs

- [45s auto-decline may cut off a callee who was about to answer on a slow network] → Matches web's practical behavior (caller gives up) and the socket reconnect window; constant is a single `static const` if field testing wants 60s.
- [`ensureAlive` force-close could drop a healthy-but-quiet socket on a network that buffers pings] → Threshold is one full heartbeat interval (30s) of *total* inbound silence — a socket that missed that is already effectively dead; the heartbeat reconnect would fire within 15s anyway, so the probe only accelerates it.
- [Sheet-acquired media held while the user idles on the sheet] → Tracks are stopped when the sheet is dismissed without proceeding (dispose hook); camera/mic indicator lights off promptly.
- [Failed-state auto-pop may surprise a user mid-retry] → Same 600ms settle as `ended`; retry is one tap away via the original entry point.

## Migration Plan

No data or API migration. All changes are client-side; ship on the feature branch, verify with `flutter analyze` (0 errors) and existing call-related tests, then a two-device manual pass (task list includes the matrix: audio/video × caller/callee × first-permission/subsequent).

## Open Questions

- None — entry points, timer value, and failure reasons are settled from the web reference and existing mobile UX.
