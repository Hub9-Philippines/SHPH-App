## 1. Permission gate + media handoff (every call works on first use)

- [x] 1.1 Extend `CallAcceptPermissionSheet`: after OS permission grant, acquire local media via `ShphWebRTCCallService.getLocalMedia(callType)`, add `onMediaAcquired(stream)` callback, verify video calls actually got a video track (else stop tracks + show camera-required denied state), and stop tracks on dismiss-without-grant
- [x] 1.2 Add `preAcquiredStream` pass-through: `CallSessionController.call()` accepts an optional acquired stream and forwards it to the engine (engine field already exists)
- [x] 1.3 Route booking details' in-app-call choice through `CallAcceptPermissionSheet` (same pattern as product page), handing the acquired stream to `call()`
- [x] 1.4 Route contact provider's in-app-call choice through the permission sheet the same way
- [x] 1.5 Wire the chat room's incoming-call accept flow to hand off the sheet-acquired stream instead of letting the engine re-prompt

## 2. Bounded ring timers

- [x] 2.1 Add `_ringTimer` to `CallSessionController`: start on outgoing `call()` and on incoming `ringing`; cancel on connected/ended/user action/resetAfterLogout
- [x] 2.2 Outgoing timeout (45s): show localized no-answer feedback, run the existing `endCall()` cleanup path (REST end + `call_end` + reset), set `lastEndReason = 'noAnswer'`
- [x] 2.3 Incoming timeout (45s): run `declineIncomingCall()` and dismiss the banner
- [x] 2.4 Add no-answer l10n keys (en/fil) and run `flutter gen-l10n`

## 3. Honest failure states

- [x] 3.1 Add `onCallFailed(String reason)` callback to `ShphWebRTCCallService`, invoked on peer-connection failure and media errors; controller maps it to `CallUiState.failed` + `lastEndReason` (`connectionFailed`, `mediaDenied`)
- [x] 3.2 Wrap the accept-path media acquisition: on failure, REST-reject the call, set failed state, reset session
- [x] 3.3 Update `call_screen_widget` to treat `failed` like `ended` (reason-derived message, auto-pop after the 600ms settle) and map the new reasons to localized text
- [x] 3.4 Add failure l10n keys (en/fil) and run `flutter gen-l10n`

## 4. Socket liveness on resume

- [x] 4.1 Add `ensureAlive()` to `ShphWebSocketService`: null channel → connect; inbound silence > heartbeat interval → force-close (bounded reconnect); healthy → no-op (immediate ping when a call is active)
- [x] 4.2 Add an app-lifecycle observer in `main.dart` calling `ensureAlive()` on `resumed`

## 5. Speaker routing

- [x] 5.1 In `CallSessionController._onServiceStatus('connected')`: push `setSpeakerphoneOn(video ? isSpeakerOn : false)` so video defaults to loudspeaker and audio to earpiece; keep the toggle applying live

## 6. Verification

- [x] 6.1 Run `flutter analyze` — 0 errors
- [x] 6.2 Run existing test files that touch calls/booking funnel; add a unit test for the ring timers using fake async
- [ ] 6.3 Manual two-device matrix: audio+video × caller+callee × first-permission+subsequent, plus background/foreground mid-ring (requires devices — left for the user)
