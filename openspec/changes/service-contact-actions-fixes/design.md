## Context

The service page (`lib/pages/product_page/product_page_widget.dart`) routes both its Contact buttons (provider-card `OutlinedButton` and bottom-bar `FFButtonWidget`) through `_openContactProvider()` straight into the legacy `ContactProviderWidget`. The booking-details change introduced a reusable themed chooser, `lib/components/contact_action_sheet.dart`, with `showContactActionSheet(kind: call | message, ...)` — the service page needs a combined variant.

The bottom-bar Contact/Book now buttons render with `titleSmall` text (16px, w700) inside the `FFButtonWidget`, which wraps the label in `AutoSizeText`; with the custom `plusJakartaSans` font the large size makes the last character clip at the bottom edge.

`lib/components/call_accept_permission_sheet.dart:136` fakes the grant: the allow button sets `_granted = true` and calls `onPermissionGranted` without any OS permission request. `permission_handler: ^13.0.2` is already a dependency and `RECORD_AUDIO` / `CAMERA` are declared in the main manifest; `lib/flutter_flow/permissions_util.dart` already wraps `Permission.request()`.

`ChatService.getOrCreateDirectThread` (`lib/services/chat_service.dart:96`) posts to `getOrCreateThreadForBooking('')`, i.e. `POST /api/chat/threads/booking//` with an empty booking id — the backend 400s, `null` bubbles up, and every "chat in app" flow shows `cpCouldNotOpenChat` ("Could not open chat right now"). The OpenAPI spec defines exactly the needed endpoint: `POST /api/chat/threads/direct/` with body `{"provider_id": <int>}` (`DirectThreadRequestRequest`), returning `ChatThreadDetail` — "Get or create direct chat thread... No booking is required."

## Goals / Non-Goals

**Goals:**
- Contact on the service page opens a one-tap chooser (never the legacy hub): in-app chat + in-app call always, plus SMS + call-by-number when the provider's phone is resolvable.
- Contact/Book now labels fit their buttons cleanly on one line.
- The call permission sheet surfaces the true OS mic (and camera) permission result, with an open-settings path when permanently denied.
- "Chat in app" actually opens a room everywhere (service page, booking details, legacy contact hub) by using the correct direct-thread endpoint.

**Non-Goals:**
- No changes to the legacy `ContactProviderWidget` itself beyond benefiting from the shared thread fix.
- No new media/WebRTC call UI — in-app call remains permission-gated initiation of the backend call record.
- No redesign of the booking-details sheet's two-kind split; it keeps its existing `call`/`message` modes.

## Decisions

- **Extend the existing chooser with a combined mode.** Add a third `ContactActionKind` value (e.g. `all`) to `contact_action_sheet.dart` so the same themed sheet shows all four options — "Chat in app", "Call using the app", and (when `phoneAvailable`) "Text via SMS" + "Call by number". The two number actions map to the same `ContactActionChoice` values the booking-details code already dispatches. Rationale: one theme-driven component, no new sheet, and the service page dispatches through the identical switch that booking details already uses.
  - Alternative considered: a bespoke sheet in the product page — rejected (UI drift, duplicates the disabled-state + subtitle logic).
- **Service page owns dispatch, mirroring booking details.** `_openContactProvider()` becomes a chooser opener; choices dispatch to `tel:` / `sms:` via `launchURL`, in-app chat via `ChatService.getOrCreateDirectThread` + `ChatPageWidget`, in-app call via `CallAcceptPermissionSheet.show(audio)` + `ShphChatApi.initiateCall`. Provider phone is resolved once after profile load through `ShphProvidersApi.instance.getProvider(providerId)` reading `phone_number` (SHPH `User` schema; the legacy Supabase `ProfilesTable` path is deprecated per AGENTS.md). Missing phone → sheet disables the two number rows with an explanatory subtitle.
- **Shrink the action-button labels.** Replace the bottom-bar `titleSmall` `textStyle` with a smaller style (e.g. `labelLarge`/`labelMedium`, w600–w700) so `AutoSizeText` renders the full label on one line with headroom inside the 54px button; apply the same to the provider-card `OutlinedButton`/`FilledButton` label sizing where needed so labels never clip.
  - Alternative considered: raising the button height — rejected (makes a heavier footer; the real fix is the label size).
- **Permission sheet requests for real.** Import `permission_handler`; the allow handler becomes async:
  - audio → `Permission.microphone`, video → request `camera` + `microphone`.
  - On result: `granted`/`limited` → `_granted` + `onPermissionGranted`; `permanentlyDenied` → show the denial banner (existing `_denied` UI) plus an "Open settings" action (`permission_handler.openAppSettings()`); plain `denied` → show denial banner and do not proceed.
  - Add a short loading state on the allow button while the OS prompt is in flight so double-taps can't double-fire.
  - Rationale: truthful UX and it unblocks the in-app call path (previously "allowed" with no real permission).
- **Direct thread via the real endpoint.** Add `ShphChatApi.getOrCreateDirectThread(providerId)` → `POST /api/chat/threads/direct/` body `{'provider_id': providerId}`. `ChatService.getOrCreateDirectThread` parses the string provider id to `int` and calls it. On null/error the existing callers already surface their SnackBar fallbacks (`cpCouldNotOpenChat`), so no caller changes are needed beyond the shared service fix.
  - Alternative considered: keep the booking-endpoint call and pass a dummy id — rejected, the backend has a dedicated no-booking direct endpoint and the booking endpoint is for booking-scoped threads.

## Risks / Trade-offs

- `initiateCall` still only records the call server-side; no call screen exists yet. → Same mitigation as booking details: permission-first flow; full call UI is a future change.
- Provider number may be absent for unverified/legacy accounts. → Chooser degrades gracefully: number rows hidden or disabled with "phone number unavailable".
- Requesting two permissions for video may yield mixed results. → Grant handling treats each permission's actual status individually and only reports granted when the required ones for the chosen call type are granted.
- Changing a shared `ChatService` method affects legacy contact flows too. → Intended; the endpoint is the designed one and the old call was broken for direct threads. Any residual backend 4xx still falls back to the existing SnackBar.

## Migration Plan

- No data migration. Single client change; rollback = restore `_openContactProvider`, the old bottom-bar `textStyle`, the grant-faking allow handler, and the booking-endpoint call in `ChatService`.
- Regenerate `lib/l10n/*.dart` via `flutter gen-l10n` after adding any new `.arb` keys (e.g. open-settings action, "number unavailable" reuse is existing `cpPhoneUnavailable`).