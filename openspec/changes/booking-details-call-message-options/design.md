## Context

The booking details page (`lib/pages/booking_details/booking_details_widget.dart`) currently routes both the floating Call and Message buttons through `_openContact()` → the legacy `ContactProviderWidget` page. The app already has the building blocks for an in-app communication system:

- `ShphChatApi.initiateCall()` → `POST /api/chat/calls/initiate/` (requires `thread_id`, `callee_id`, `media_type`) — see `SHPH API.yaml:2609`.
- `ChatService.getOrCreateDirectThread()` + `ChatPageWidget` for the in-app chat room (pattern proven in `contact_provider_widget.dart:_openChatThread`).
- `CallService` (state stub) + `CallAcceptPermissionSheet` (mic/camera permission flow, `CallType.audio`).

Provider phone resolution: the loaded listing map (`serviceListing`) carries `provider_id`/`provider_name`/`provider_photo` but NOT a phone number. `ProviderProfileResponse` (`/api/providers/{id}/`, `SHPH API.yaml:21923`) has no phone field; `/api/users/{id}/` returns the `User` schema which includes `phone_number` (`SHPH API.yaml:23817`). `ShphProvidersApi.getProvider(id)` already wraps `/api/users/{id}/`. The legacy `ContactProviderWidget` resolves phones via `ProfilesTable()` (Supabase) which is deprecated per AGENTS.md — the new path must use the SHPH user endpoint.

## Goals / Non-Goals

**Goals:**
- Make both floating buttons on booking details show a two-option chooser instead of one grabbing the whole screen.
- Provide a working dial-by-number (`tel:`), text-via-SMS (`sms:`), in-app chat (existing room), and in-app call (existing initiate-call API) path.
- Resolve the provider number through the SHPH API only (no Supabase).

**Non-Goals:**
- Building the WebRTC/media call UI — only initiating the app's backend call record via the existing `initiateCall` endpoint, permission-gated with `CallAcceptPermissionSheet`.
- Redesigning or removing `ContactProviderWidget`; it stays reachable from other screens.

## Decisions

- **Reusable chooser component.** New `lib/components/contact_action_sheet.dart` exposing `showContactActionSheet(context, type: ContactActionKind.call | .message, {...})`. It presents the two options as a themed bottom sheet and returns the chosen `ContactActionChoice` (enum) via `Navigator.pop`. Booking details acts on the returned choice. Reuses `AppTheme.of(context)` tokens — no hardcoded hex (AGENTS.md theming rule).
- **Booking details owns the actions.** Instead of a full screen, `_BookingDetailsWidgetState` gets `_onCallPressed()` and `_onMessagePressed()` which open the sheet, then dispatch:
  - `callByNumber` → `launchURL('tel:$phone')`
  - `sms` → `launchURL('sms:$phone')`
  - `inAppChat` → ensure direct thread (`ChatService.getOrCreateDirectThread`) then `context.pushNamed(ChatPageWidget.routeName, pathParameters:{'roomId': roomId}, extra: {providerName, providerPhoto})`
  - `inAppCall` → `CallAcceptPermissionSheet.show(context, callType: CallType.audio)` then `ShphChatApi.initiateCall({thread_id, callee_id, media_type: 'audio'})`; falls back to a SnackBar if thread cannot be created.
- **Phone resolved once via SHPH user endpoint.** Add a `_providerPhone` field resolved in `_loadBookingDetails()` after the listing loads, using `ShphProvidersApi.instance.getProvider(providerId)`, reading `phone_number` from the response. Cache on the model (add `providerPhone` to `BookingDetailsModel`) to avoid refetching per tap. On failure, the phone-dependent sheet options are disabled with an explanatory subtitle (keeps `callByNumber`/`sms` from no-op).
- **Why `/api/users/{id}/` over the provider profile endpoint:** `ProviderProfileResponse` does not expose the phone; the `User` schema does. `ShphProvidersApi.getProvider` already targets that endpoint, so no new client resource is needed.
- **Why a sheet with two rows over jumping straight into ContactProvider:** the user asked for explicit options, and the sheet keeps the booking context visible (the summary card and progress stepper remain on screen); it also lets the two buttons behave differently (call vs message) instead of both being identical.

## Risks / Trade-offs

- `initiateCall` creates a backend call record but there is no in-app WebRTC screen yet; the caller experience may end at the permission sheet + API call. → Mitigation: gate with `CallAcceptPermissionSheet` (audio) so the flow is real but permission-first; call this out as a follow-up if a full call UI is needed.
- Provider number may be absent (unverified/legacy accounts) → Both choosers degrade gracefully: option disabled + "number unavailable" subtitle.
- `getOrCreateDirectThread` currently posts to `/api/chat/threads/booking/` with an empty booking id internally; if the backend regresses there, in-app chat fails. → Mitigation: same call path `ContactProviderWidget` already uses successfully (shared pattern), plus SnackBar on null thread.
- Sheet is a new shared component; its first consumer is booking details only. → Theme-driven so later screens (explore provider cards) can reuse it without visual drift.

## Migration Plan

- No data migration. Deploy is a single client change; rollback = restore the previous `_openContact()` handlers.

## Open Questions

- None that block implementation — the call UI depth (permission-only vs full media screen) is explicitly a non-goal and can be a future change.