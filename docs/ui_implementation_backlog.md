# Remaining UI Implementation Backlog

Date: 2026-07-19  
Branch audited: `feature/safe-sync-port`

## Summary

The guardrail delivery batches are not UI-heavy, and their required runtime UI
already exists: offline/session notices, active and incoming call surfaces, and
minimal Projects and Rooms pages.

Additional UI is still needed before Projects, Rooms, and phone registration
are product-ready. The work below is separate from the remaining live API,
physical-device, TURN, and release-build verification.

## P0: Required for usable flows

### 1. Complete phone signup

Current state:

- The phone signup screen only collects a phone number.
- It calls `/api/auth/otp/send-pin/`, which requires an authenticated user and
  returns HTTP 401 for signup attempts.
- Production registration starts through `/api/auth/register/initiate/` and
  requires first name, last name, email, password, phone number, and role.

Build:

- Replace the phone-only signup action with a complete registration form or a
  multi-step registration flow.
- Collect and validate first name, last name, email, password/confirmation,
  phone number, and client/provider role.
- Submit the full payload through `registerInitiate`.
- Route to a registration-specific OTP page and complete through
  `registerVerify`.
- Preserve entered data safely across the OTP step without logging passwords or
  OTP values.
- Display field-level API validation errors and resend/cooldown state.
- Keep phone login separate from phone registration.

Acceptance criteria:

- A new client and provider can each complete registration against production.
- Existing phone login remains functional.
- Test-phone presets remain opt-in and never bypass OTP verification.

### 2. Add discoverable Projects and Rooms navigation

Current state:

- `/projects` and `/rooms` routes are protected and functional.
- No normal home, profile, client, or provider navigation entry points were
  found; users must reach the routes programmatically.

Build:

- Add role-appropriate entry points for Projects and Rooms.
- Define whether they belong in Home shortcuts, Profile/More, provider tools,
  or a dedicated service-management section.
- Add labels, icons, semantics, and signed-out behavior consistent with the
  existing navigation system.

Acceptance criteria:

- Eligible users can reach both features without a deep link.
- Back navigation returns to the expected originating surface.

## P1: Required for product-ready Projects

The existing project pages expose creation, quote generation, matching, and
cancellation, but present mostly raw text and buttons.

Build:

- Replace plain list tiles with project cards showing category, status badge,
  budget range, headcount, and relevant dates.
- Add list filters for active, draft, committed, completed, and cancelled work.
- Show quote progress, success feedback, generated budget totals, and role-line
  estimates after `Generate quote`.
- Expand role lines to display category, rate/subtotal range, required count,
  and match state.
- Display matched prospects with provider name, listing, score, distance,
  rating, completed jobs, and status.
- Add the controller-supported prospect actions with confirmation and agreed
  price input where required.
- Improve empty, retry, stale-data, and mutation-success states.
- Add destructive-action confirmation and progress treatment consistent with
  the rest of the application.

Acceptance criteria:

- Every API-backed project and prospect action is available through the UI.
- Users can understand quote and matching results without reading raw status
  strings.
- Actions cannot be submitted twice while a mutation is active.

## P1: Required for product-ready Rooms

The existing room pages support the core controller actions but expose raw API
fields and insufficient permission context.

Build:

- Replace `Category ID` with an API-backed category selector.
- Replace raw date/time text fields with date and time pickers.
- Add description, menu/service, event location, radius, host listing, and fee
  breakdown fields where allowed by the verified contract.
- Add field-specific validation for future dates, headcount, price, and required
  room data.
- Present room cards with status, category, schedule, organizer, price, and seat
  availability.
- Add room list filters and explicit loading, retry, and empty states.
- Show participant roles and payment/status indicators clearly.
- Show Lock and Cancel only to the organizer; show Leave only to eligible
  participants.
- Add confirmation dialogs for lock, leave, and cancel.
- Add join-token copy/share UI for organizers and token paste/scan support for
  joiners.
- Add clear feedback for full, locked, expired, cancelled, and already-joined
  rooms.

Acceptance criteria:

- Users never need to know a numeric category ID or manually format dates.
- Unauthorized room actions are not offered by the interface.
- Organizers can share a join token and participants can join from it.

## P2: Call UI polish

The active-call page and incoming-call overlay already exist and do not need a
new foundational UI.

Potential polish after two-device verification:

- Add permission-denied and media-initialization recovery screens.
- Add reconnecting, remote-media unavailable, busy, rejected, and failed-call
  states.
- Add speaker/Bluetooth audio-route controls if supported by the native peer.
- Add local-video drag/resize and safe-area/orientation handling.
- Add an explicit post-call summary or return-to-chat transition if product
  requirements call for it.

Do not build these ahead of physical-device testing where the native behavior
and failure modes can be observed.

## P2: Guardrail UI polish

No new guardrail screens are required. Optional improvements are:

- A dedicated session-expiry explanation after forced logout.
- An offline details/retry action beyond the current non-blocking banner.
- Consistent step-up authentication progress and cancellation messaging across
  all protected actions.

## Not UI work

The following remaining gates should not be tracked as UI implementation:

- Valid-JWT WebSocket upgrade and two-user signaling tests.
- TURN provisioning and restrictive-network relay tests.
- Physical-device microphone, camera, and WebRTC negotiation tests.
- Authorized live Projects and Rooms API validation.
- Slow Flutter widget-test bootstrap investigation.
- Android release APK build and smoke test.
- Replacement of the retained Supabase/PostgREST compatibility types.
- Removal or consolidation of the unused legacy `lib/services/webrtc_service.dart`
  stub after confirming it has no callers.

## Recommended UI delivery order

1. Complete phone signup because the current UI cannot call the correct API
   contract.
2. Add Projects and Rooms navigation so the shipped surfaces are discoverable.
3. Finish Rooms creation, permissions, and join/share UX.
4. Finish Projects quote, role-line, and prospect UX.
5. Polish call and guardrail states based on live-device findings.

