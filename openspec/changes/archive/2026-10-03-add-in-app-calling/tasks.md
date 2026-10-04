## 1. Dependencies & API surface

- [x] 1.1 Add `flutter_webrtc` and `web_socket_channel` to `pubspec.yaml` (additive only; respect existing `dependency_overrides`) and run `flutter pub get`
- [x] 1.2 Extend `lib/api/resources/chat_api.dart` with `acceptCall(callId)`, `rejectCall(callId, {reason})`, `endCall(callId)`, `getSfuToken(callId)` per `SHPH API.yaml` paths `/api/chat/calls/{call_id}/accept|reject|end|sfu-token/`
- [x] 1.3 Create `lib/services/call_signal_models.dart` — typed signaling message model (`type`, `threadId`, `targetUserId`, `callId`, `sdp`, `candidate`, `mediaType`) with camelCase JSON keys matching the web client exactly

## 2. Websocket service (port of websocketService.ts)

- [x] 2.1 Create `lib/services/websocket_service.dart`: singleton, URL derived from `ApiConfig.baseUrl` (https→wss, `/ws` path), JWT via `shph-auth` subprotocol
- [x] 2.2 Implement connect/disconnect with exponential-backoff reconnect, heartbeat ping, and connection-state stream
- [x] 2.3 Implement handler registry (`addHandler(type, id, fn)` / `removeHandler`) dispatching on message `type`, including the `call_signal` envelope unwrap (deliver `message.data` to `call_signal` subscribers)

## 3. WebRTC call service (port of webrtcService.ts, direct-call subset)

- [x] 3.1 Create `lib/services/webrtc_call_service.dart` singleton with user callbacks (`onStateChange`, `onStreams`, `onIncomingCall`) and Perfect Negotiation roles (caller impolite / callee polite)
- [x] 3.2 Implement `getLocalMedia(mediaType)` (mic-only for audio; mic+camera for video) reusing a pre-acquired stream from the permission gate
- [x] 3.3 Implement `createPeerConnection` with event handlers (ontrack → remote stream, onicecandidate → `ice_candidate` signal, renegotiation → offer/answer), STUN/TURN from server defaults
- [x] 3.4 Implement `call(threadId, calleeId, mediaType, participant)`: REST initiate → local media → `call_initiate` signal → outgoing state
- [x] 3.5 Implement `acceptCall()` / `rejectCall()` / `endCall()` mirroring the web flow (REST persist + signal + cleanup; `call_end` also posts the "Video call ended" system message for parity)
- [x] 3.6 Implement signaling handlers for `call_initiate` (ring incoming UI), `call_accept` (create offer), `call_reject` / `call_end` (teardown + UI reset), `webrtc_offer` / `webrtc_answer` / `ice_candidate` (negotiation)
- [x] 3.7 Implement `toggleMute`, `toggleSpeaker` (route to speaker vs earpiece for audio calls), `toggleCamera`, and full media release on cleanup

## 4. Call state controller & UI

- [x] 4.1 Create `lib/services/call_session_controller.dart` (`ChangeNotifier`): states `idle/outgoing/ringing/connecting/active/ended/failed`, participant info, duration timer, mute/speaker/camera flags
- [x] 4.2 ~~Create `lib/pages/call/call_screen_widget.dart`: full-screen outgoing/active call page~~ — superseded by 7.2; the in-call surface is a global overlay, not a pushed page
- [x] 4.3 Create `lib/components/incoming_call_overlay.dart`: global top overlay (caller name/photo, accept → `CallAcceptPermissionSheet` → accept flow, decline), shown via the navigator overlay so it appears on any screen
- [x] 4.4 Initialize websocket + controller at app start (`lib/main.dart` or app shell), detaching on logout

## 5. Wire entry points & failure paths

- [x] 5.1 Update `_initiateInAppCall` in `lib/pages/product_page/product_page_widget.dart` to go through the shared launcher (keep direct-thread fallback chain; surface socket-unavailable error instead of silent no-op)
- [x] 5.2 Same for `lib/pages/booking_details/booking_details_widget.dart` and `lib/pages/contact_provider/contact_provider_widget.dart`
- [x] 5.3 Handle decline/remote-hangup UI resets and the websocket-down error path per spec (no half-open state)

## 6. Verification

- [x] 6.1 `flutter analyze` at 0 errors; unit test for signal model round-trip + websocket URL derivation
- [ ] 6.2 Device test: audio call app→app (two devices), web→app, app→web; mute/speaker/camera toggles; decline and remote-hangup paths
- [ ] 6.3 Confirm call record transitions (`initiated→accepted→ended` / `rejected`) visible in call history detail page

## 7. In-call overlay, minimize, and calling from the chat room

Web parity: the web app mounts `VideoCallOverlay` globally in `App.vue` (with a minimize control collapsing it to a PIP bubble) and `ContactProviderPage.vue` pushes `/chat/:id` before placing the call. The mobile app now matches that.

- [x] 7.1 Add `isMinimized` + `minimize()` / `expand()` / `toggleMinimized()` to `CallSessionController`; reset on call start, incoming ring, service `ended`, and logout
- [x] 7.2 Create `lib/components/audio_call_overlay.dart` and `lib/components/video_call_overlay.dart` (expanded panel + PiP bubble, minimize control, live duration); delete the route-based `lib/pages/call/` screens
- [x] 7.3 Rework `CallLayerHost` in `lib/main.dart` to render the overlay from controller state instead of `router.pushNamed` (it is mounted above the `Router`, so no `GoRouter.of` lookup is available there)
- [x] 7.4 Create `lib/services/in_app_call_launcher.dart`: push the direct chat room, then place the call without awaiting the navigation
- [x] 7.5 Point every external "Call using app" action at the launcher (`product_page`, `booking_details`, `contact_provider`); leave the in-room call control in `chat_page` unchanged
- [x] 7.6 Remove the `CallScreenWidget` / `AudioCallScreen` / `VideoCallScreen` routes from `lib/router/app_router.dart` and the `lib/index.dart` export
- [x] 7.7 Add `callBtnMinimize` / `callBtnExpand` to `lib/l10n/app_en.arb` + `app_fil.arb`, run `flutter gen-l10n`
- [x] 7.8 Unit test the minimize state machine (`test/call_overlay_minimize_test.dart`); `flutter analyze` at 0 errors
- [x] 7.9 Surface terminal outcomes (declined / no answer / media denied / connection failed) in the overlay with a `ccDone` dismiss action, and add `dismissCallOutcome()` + a shared auto-dismiss grace timer so `failed` can no longer park the controller in a terminal state
- [ ] 7.10 Device test: minimize to PiP from a live audio call, restore, end from the bubble, and confirm the chat room is interactive underneath

