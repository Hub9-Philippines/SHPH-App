# `feature/sync-from-shph-main` Porting Analysis

Date: 2026-07-18  
Target branch: `develop`  
Source branch: `feature/sync-from-shph-main`

## Summary

The source branch should not be merged directly into `develop`. Git reports 97 merge conflicts, and its focused follow-up commits do not apply cleanly with a three-way patch. The branch combines useful new features with large architectural replacements, generated UI rewrites, dependency changes, and deletion of legacy backend assets.

The safest approach is to manually port selected features in small, testable batches while retaining the newer API and authentication work already present on `develop`.

## Implementation tracker

Working branch: `feature/safe-sync-port`

| Batch | Status | Commit | Validation |
| --- | --- | --- | --- |
| Analysis and porting guide | Complete | `68e4e0a` | Branch comparison documented |
| Safe standalone utilities | Complete | `57bb0d2` | 10 focused tests passed; scoped analysis has no errors or warnings |
| Runtime safety guardrails | Complete | `a7db350` | 8 focused tests passed; scoped analysis reports no issues |
| App-level guardrail integration | Complete | `d559ca4` | 11 guardrail tests passed; scoped analysis has no errors or warnings |
| Sensitive-action step-up | Complete | `6b63260` | Guardrail tests pass; payout and session operations fail closed |
| Privacy-safe crash boundary | Complete | `e019296` | 15 guardrail tests passed; focused crash analysis reports no issues |
| Token and OTP protection | Complete | `8a952dc` | 22 combined guardrail tests passed; scoped analysis reports no issues |
| Realtime communication | In progress | `efe612b`, `05509ff`, `9aebee8`, `9533e9b`, `0bd121f`, `54b1e48` | Core: 33 focused tests passed; call page: 3 widget tests passed |
| Projects | Pending | - | Requires deployed API contract verification |
| Rooms | Pending | - | Requires deployed API contract verification |
| Supabase and Node cleanup | Pending | - | Requires runtime/deployment usage audit |

### Completed: safe standalone utilities

- Added shared numeric and API parsing formatters.
- Added system-sound feedback with an enable/disable control.
- Added external and WebView PDF preview support.
- Added a proper 404 page and router fallback.
- Added formatter and sound-service tests.

### Completed: runtime safety guardrails

- Added SHPH-host reachability monitoring instead of probing a third-party host.
- Added idempotent network monitoring with observable online/offline changes.
- Added inactivity warning and timeout events with activity reset and cancellation.
- Added biometric/device step-up verification that fails closed.
- Deliberately excluded the source branch's unverified password fallback.
- Kept logout and navigation outside the timer service to avoid unexpected auth mutations without a valid widget context.

### Completed: app-level guardrail integration

- Wrapped routed application content in `AppGuardrailScope`.
- Initialized SHPH reachability monitoring when the application starts.
- Added a non-blocking banner while the SHPH API host is unreachable.
- Reset authenticated inactivity timers on pointer activity and app resume.
- Displayed a two-minute session-expiry warning.
- Logged out through the existing SHPH auth manager when inactivity expires.
- Updated the auth notifier and routed expired sessions to sign-in options.
- Initialized the global scaffold messenger key so guardrail notices are visible.
- Stopped network and inactivity timers when the app wrapper is disposed.

### Source reference map

All runtime guardrail work is derived from definitions on
`feature/sync-from-shph-main`:

| Source branch reference | Safe-port implementation | Adaptation |
| --- | --- | --- |
| `lib/services/network_status_service.dart` | `lib/services/network_status_service.dart` | Replaced the `google.com` DNS probe with the configured SHPH API host; added idempotent lifecycle and injectable probes. |
| `lib/services/session_timeout_service.dart` | `lib/services/session_timeout_service.dart` | Preserved the 30-minute timeout and two-minute warning; replaced loose callbacks with typed events and explicit activity/lifecycle integration. |
| `lib/services/step_up_auth_service.dart` | `lib/services/step_up_auth_service.dart` | Preserved device-auth-first verification; removed the source password modal because it returned an unverified password without calling an API. |
| `lib/widgets/auth_prompt_modal.dart` | Step-up failure messaging at protected actions | Used as the authentication-prompt UX reference; did not reuse its login/register actions for an already authenticated user. |
| `lib/services/crash_reporting_service.dart` | `lib/services/crash_reporting_service.dart` | Preserved Flutter/platform global error capture while excluding unconfigured Firebase/Sentry SDKs, external transmission, and user identifiers. |
| `lib/flutter_flow/token_refresh_manager.dart` | `lib/flutter_flow/token_refresh_manager.dart` | Preserved JWT expiry parsing and monitoring; does not clear expired access/refresh credentials before the API interceptor can securely refresh them. |
| `lib/flutter_flow/otp_rate_limiter.dart` | `lib/flutter_flow/otp_rate_limiter.dart` | Preserved the source cooldown and daily limit while removing phone numbers from debug logs. |
| No source app-root wiring | `lib/widgets/app_guardrail_scope.dart` and `lib/main.dart` | Completes the network/session integration that the source branch defined but left unused. |

The source branch contains no call sites for `StepUpAuthService`. The safe port
adds the missing enforcement to current implementations of source-migrated
financial and session features: provider payout requests, individual/all-session
revocation, and admin payout status changes.

### Completed: sensitive-action step-up

- Requires verified device authentication before provider payout submission.
- Requires verified device authentication before revoking one or all sessions.
- Requires verified device authentication before admin payout status changes.
- Fails closed and does not call the API when verification is unavailable,
  cancelled, or unsuccessful.

### Completed: privacy-safe crash boundary

- Installs the Flutter framework error boundary used by the source branch.
- Captures uncaught platform-dispatcher errors and preserves earlier handlers.
- Supports an injectable, testable crash-report sink for a future approved
  telemetry provider.
- Performs no external transmission by default.
- Does not collect user IDs, arbitrary context, or personally identifiable
  information.
- Avoids adding Firebase/Sentry packages or build configuration until a
  telemetry provider and privacy policy are explicitly approved.

### Completed: token and OTP protection

- Restored the source branch's periodic SHPH JWT expiry monitoring.
- Parses JWT expiry locally without logging or transmitting token contents.
- Emits deduplicated expiring-soon and expired events.
- Preserves refresh credentials so the existing API interceptor can rotate an
  expired access token after a 401 response.
- Retains the source OTP limits of one request per 60 seconds and five requests
  per phone number over 24 hours.
- Removes normalized phone numbers from OTP limiter logs.

### In progress: realtime communication

The Batch B protocol foundation is adapted from these source-branch files:

- `lib/services/call/signaling_message.dart`
- `lib/services/call/call_signaling.dart`
- `lib/services/call/call_peer.dart`
- `lib/services/call/ice_config.dart`
- `lib/services/call/call_controller.dart`
- `lib/services/call/flutter_webrtc_call_peer.dart`
- `lib/pages/call/call_page.dart`
- `lib/pages/call/incoming_call_overlay.dart`
- `lib/main.dart`
- `lib/pages/chat_page/chat_page_widget.dart`

Completed foundation work:

- Added typed call signaling messages using the source wire protocol.
- Rejects unknown, incomplete, or malformed inbound signaling payloads.
- Added an injected signaling transport so tests and controllers do not depend
  directly on an unverified WebSocket endpoint.
- Added a testable peer interface for the future `flutter_webrtc` adapter.
- Made STUN and TURN URLs configurable with build-time values.
- Requires both a TURN username and credential before TURN is enabled.
- Removed the source branch's hardcoded TURN host assumption.
- Added the source-referenced `web_socket_channel` dependency.
- Added an injectable WebSocket transport using `/ws/chat/` and
  `['shph-auth', token]` authentication.
- Rejects missing and expired access tokens before opening a socket.
- Sends heartbeat pings and forces reconnect after prolonged silence.
- Uses bounded exponential reconnect and stops after an explicit disconnect.
- Discards malformed inbound JSON without terminating the message stream.
- Avoids logging JWTs and signaling payload contents.
- Added the source call state machine for caller and callee flows behind
  injected REST and peer interfaces.
- Rejects concurrent incoming calls as busy and ignores stale or cross-call
  signaling messages.
- Handles offer, answer, and ICE forwarding with fail-closed local cleanup.
- Preserves audio/video, mute, camera, reject, and end-call state transitions
  without coupling the controller to an unverified native peer implementation.
- Added the source-referenced `flutter_webrtc` peer adapter and dependency.
- Validates remote SDP and ICE fields before passing them to native WebRTC.
- Rolls back partially initialized native media resources on failure and makes
  disposal safe to repeat.
- Added Android and iOS microphone permission declarations from the source
  branch; the existing camera declarations are retained.
- Added source-referenced active-call and incoming-call interfaces.
- Hides video-only controls for audio calls, prevents dismissing an active call
  with back navigation, and exposes accessible call controls.
- Serializes incoming accept/reject actions to prevent duplicate lifecycle API
  requests and exposes a guarded post-accept navigation callback.
- Mounted one production call controller and incoming overlay at the app root.
- Connects the authenticated lifecycle to the guarded WebSocket and ends active
  calls before session teardown.
- Replaced direct chat call-record requests with controller-driven audio/video
  calls and opens the active-call interface only after initiation succeeds.
- Matched the audited `shph-web` REST contract using `thread_id` and numeric
  `callee_id`; media type remains in the signaling envelope.
- Shares concurrent WebSocket connection attempts so auth startup and a call
  action cannot race into a false connection failure.

Remaining gates before live calls can be enabled:

- Verify a successful `shph-auth` upgrade using a valid deployed JWT.
- Provision and test approved TURN servers and credentials.
- Validate native microphone, camera, and peer negotiation on physical devices.
- Complete the incoming-overlay test rerun after the slow Flutter widget-test
  bootstrap.

#### Contract audit against `shph-web`

Audited repository: `C:\Users\Administrator\dev\shph-web` (`main`)

Confirmed by the web client implementation:

- `VITE_WS_URL` is the explicit WebSocket base URL.
- When it is absent, the client derives `ws(s)://<API host>/ws` from
  `VITE_API_URL`.
- The chat singleton appends `/chat/`, producing a route shaped like
  `wss://<host>/ws/chat/`.
- JWT authentication uses WebSocket subprotocols `['shph-auth', token]`; the
  token is not placed in the URL.
- Call messages use `{'type': 'call_signal', 'data': <signal>}`.
- Supported signal types match the mobile foundation: `call_initiate`,
  `call_accept`, `call_reject`, `call_end`, `webrtc_offer`, `webrtc_answer`,
  and `ice_candidate`.
- The heartbeat sends `{'type': 'ping'}` every 30 seconds and treats inbound
  traffic as proof of life; 45 seconds of silence triggers reconnection.
- Reconnection uses exponential backoff, a five-attempt budget, and does not
  retry an authentication/server rejection that closes before opening.
- REST call lifecycle endpoints are:
  - `POST /api/chat/calls/`
  - `POST /api/chat/calls/initiate/`
  - `POST /api/chat/calls/<callId>/accept/`
  - `POST /api/chat/calls/<callId>/reject/`
  - `POST /api/chat/calls/<callId>/end/`

Not verified by the web repository:

- Django Channels route registration and production deployment of
  `/ws/chat/`.
- Server validation that the authenticated user belongs to the target thread.
- Server injection/validation of `callerUserId` rather than trusting clients.
- Production environment values for `VITE_WS_URL`.
- A working TURN deployment. The web client currently hardcodes
  `web.prepcirca.com`/`dev.prepcirca.com` and exposes only username/credential
  environment variables; it does not prove reachability or credential
  validity.
- Temporary TURN credential issuance. Static build credentials remain a
  production security and abuse risk.

Result: the mobile signaling model and REST paths are client-contract verified,
but live transport remains gated until the Django backend/deployment and TURN
service are inspected or tested directly.

#### Production WebSocket verification

Production value supplied on 2026-07-18:

```text
VITE_WS_URL=wss://serbisyohubph.com/ws
```

Mobile configuration now uses the equivalent default:

```text
SHPH_WS_URL=wss://serbisyohubph.com/ws
```

Verification results:

- DNS resolves and TCP/TLS port 443 is reachable.
- Caddy proxies the host to Daphne.
- An HTTP/1.1 WebSocket upgrade request to `/ws/chat/` with the expected
  `shph-auth` subprotocol and an intentionally invalid token receives
  `403 Forbidden`.
- The controlled rejection confirms that the production WebSocket path and
  authentication boundary are reachable without using or exposing a real JWT.

Still required before enabling live calls:

- Successful `101 Switching Protocols` with a valid test-user JWT.
- Two authorized users exchanging a `call_signal` message.
- Unauthorized thread/target tests proving server-side access control.
- TURN relay verification on separate restrictive networks.

### Known baseline issue

Full-project `flutter analyze` is currently blocked by pre-existing errors in `integration_test/feature_smoke_test.dart`, including a stale `package:serbisyo_ph/main.dart` import and incomplete syntax. New batches must continue to pass scoped analysis and must not add errors to the baseline.

## Recommended implementation order

### 1. Realtime calls and WebSocket support

Candidate areas:

- `lib/services/call/`
- `lib/services/websocket_service.dart`
- `lib/pages/call/`
- Message and chat call integration
- Call signaling, ICE configuration, controller, and widget tests

This is the strongest self-contained feature missing from `develop`. Before implementation, confirm that the deployed SHPH API provides the required WebSocket signaling endpoints and ICE/TURN configuration.

### 2. Projects and Rooms

Projects include:

- Project creation and listing
- AI quote generation
- Provider matching
- Prospect actions
- Project cancellation

Rooms include:

- Room creation and listing
- Join-token lookup
- Join and leave actions
- Lock and cancellation actions

The source branch expects routes under `/api/projects/*` and `/api/services/rooms/*`. Verify these routes and their response schemas against the deployed API before porting the models, resources, pages, and routing.

### 3. Small standalone improvements

Lower-risk candidates include:

- `NotFoundPage`
- `SoundService`
- `PdfPreviewService`
- `Formatters.toNullableDouble()`
- `Formatters.toNullableInt()`
- Associated unit tests

These should be recreated or manually extracted rather than cherry-picked because their commits also contain unrelated changes and do not apply cleanly.

### 4. Selected product features

Evaluate these individually after confirming their API dependencies:

- Explore page
- Location-permission flow
- Write-review page
- Notification preferences
- Provider availability
- Admin KYC detail
- Session timeout
- Step-up authentication
- In-app notifications
- Trust badges

## Changes that should not be ported wholesale

- Core API client, API configuration, authentication, and token-storage files
- `pubspec.yaml`, `pubspec.lock`, or generated plugin registrants
- Large generated Flutter UI rewrites
- Existing admin, provider, wallet, and migration functionality already implemented differently on `develop`
- README and development-tooling directories without a separate review
- Deletion of the Node backend, database scripts, or Supabase compatibility files as part of a feature port

The current `develop` branch contains newer SHPH API migration work. Replacing its API/authentication layer with the source branch versions could restore outdated assumptions or remove supported endpoints.

## AI assistant recommendation

Do not port the Gemini widgets as-is. The source branch's Gemini service is primarily a disabled/fallback implementation, while `develop` currently contains an OpenRouter chatbot integration.

AI requests should ultimately pass through the SHPH API. Provider credentials and provider-specific request logic should not be embedded in the mobile application or APK.

## Supabase and Node cleanup

`develop` still contains the `supabase_flutter` dependency and compatibility files under `lib/backend/supabase`. These should be audited separately.

Removal criteria:

1. Confirm there are no runtime imports or calls to `Supabase.instance`.
2. Confirm all authentication, storage, database, and realtime behavior uses the SHPH API.
3. Run static analysis and the complete test suite after removal.
4. Build Android release and debug artifacts.
5. Test login, signup, OTP, token refresh, uploads, bookings, chat, and payments against a deployed API environment.

The local Node backend and deployment assets should only be removed after confirming they are not used by development, CI, deployment, OpenRouter proxying, or operational tooling.

## Proposed delivery batches

### Batch A: Utilities

- [x] Add numeric formatters and tests.
- [x] Add `NotFoundPage`, sound, and PDF preview utilities where needed.
- [x] Run focused tests and scoped `flutter analyze`.

### Batch A2: Runtime guardrails

- [x] Add SHPH API host reachability monitoring.
- [x] Add inactivity warning and timeout primitives.
- [x] Add fail-closed biometric/device step-up verification.
- [x] Add focused tests and run scoped analysis.
- [x] Integrate network state with user-facing offline messaging.
- [x] Integrate inactivity tracking with authenticated app lifecycle.
- [x] Define and implement timeout warning and logout navigation UX.
- [x] Apply step-up verification to selected sensitive actions.

### Batch B: Realtime communication

- [x] Add validated signaling message models and envelope adapter.
- [x] Add configurable ICE/STUN/TURN foundation.
- [x] Add a transport-independent peer abstraction.
- [ ] Complete WebSocket authorization and TURN deployment verification
  (route and invalid-auth rejection are confirmed).
- [x] Add WebSocket transport and lifecycle handling.
- [x] Add and test the WebRTC call controller.
- [x] Add and validate the concrete `flutter_webrtc` peer adapter.
- [x] Add the active-call page and incoming-call overlay.
- [x] Integrate incoming/outgoing calls with authenticated app and chat flows.
- [x] Add call widget tests (call-page suite passes; incoming-overlay rerun is
  pending after its async timing correction).
- [ ] Validate with two authenticated devices against the deployed API.

### Batch C: Projects

- Verify API contract.
- Add models and API resource.
- Add list, create, detail, quote, and matching interfaces.
- Add route and API tests.

### Batch D: Rooms

- Verify API contract and identifier types.
- Add models, resource, pages, and routes.
- Test public join-token lookup and authenticated room actions.

### Batch E: Cleanup

- Audit and remove unused Supabase compatibility code.
- Decide whether Node/backend assets belong in another repository or should be archived.
- Re-run analysis, tests, and release builds.

## Validation gates

Each batch should meet the following requirements before merging:

- No new direct Supabase or Node runtime dependency
- No API credentials stored in the application
- API paths verified against the deployed SHPH backend
- Focused unit/widget tests pass
- `flutter analyze` introduces no new errors
- Existing authentication and OTP flows remain functional
- Android debug and release builds succeed

## Conclusion

`feature/sync-from-shph-main` is best treated as a feature reference rather than a merge candidate. Realtime calls, Projects, Rooms, and selected standalone utilities offer the most value. They should be manually adapted to the architecture currently on `develop`, with API verification and tests performed after every batch.
