See proposal.md for motivation. Current mobile surfaces diverge from the Vue 3 + Ionic web reference (`E:\Dev\shph-web`):

- **Chat room** (`lib/pages/chat_detail/`): a bare CupertinoPageHeader + ListView + text field/send IconButton. No search, no calls, no attach, no date separators. The web room (`src/views/chat/ChatPage.vue`) has header actions (search, audio/video call, overflow popover), a composer pill (attach + input + emoji) with a round send button, quick replies, date separators, system-message styling, and an online indicator.
- **Product page** (`lib/pages/product_page/product_page_widget.dart`): provider card renders inline Contact/Book Now rows (lines ~719/739) AND the bottom bar repeats Contact/Book Now (~1084/1106). Web shows CTAs once.
- **Provider profile** (`lib/pages/provider_profile/provider_profile_widget.dart`): no contact entry point at all; the product page already has a reusable `showContactActionSheet` flow.
- **Live matching** (`lib/pages/booking_funnel/`): `_broadcastOnDemandJob` swallows every error (`catch (e) { lastBroadcastSucceeded = false; ... }`) and the screen falls back to an honest-but-useless "Live matching unavailable — this is a preview" countdown whenever `_isRealJob` is false. Web (`OnDemandBookingPage.vue` + `useOnDemandRequest.ts`) treats a failed create as a hard error with retry, and sends a minimal payload (`category`, `description`, `photo_url`, `client_lat`, `client_lng`, `radius_km`, optional `address_detail`/`scheduled_for`/`voucher_code`/`urgency`).
- **Home header** (`lib/main/home/home_redesign_widget.dart` + `lib/components/prototype_components.dart`): binary `_isHeaderCompact` flip at offset > 28 via setState on every scroll tick crossing the threshold; the header itself is an `AnimatedContainer` that only knows two states.

## Goals / Non-Goals

**Goals**
- Chat room reaches visual + functional parity with the web room for the affordances the mobile data layer can support today.
- Single source of truth for product-page CTAs (bottom bar, with icons).
- Provider profile gets a contact entry point reusing the existing contact sheet.
- Live matching: broadcast failures are surfaced with retry; success polls the real job. Payload matches the web create payload semantics.
- Home header collapse animates continuously with scroll offset.

**Non-Goals**
- No WebSocket chat transport on mobile (5s polling stays); no read receipts, replies, pins, mentions, voice notes, or group-call joins in this change — those need deeper service work and are follow-ups.
- No backend changes; no new endpoints beyond what `ShphChatApi` / `ShphOnDemandJobsApi` already expose.
- No changes to the scheduled-booking (reserve) path.
- No redesign of the chat thread list page (`chat_page`), only the room.

## Decisions

**D1 — Rebuild the routed chat room (`chat_page`), not the orphaned `chat_detail` page.**
Implementation discovered that `lib/pages/chat_detail/` is dead code: the router (`/chat/:roomId`) and every entry point (messages tab, booking details, product page, contact provider, notifications) use `ChatPageWidget`. Parity work therefore lands in `chat_page_widget.dart`/`chat_page_model.dart`, growing a custom header (replacing the old card header) and footer composer. `chat_detail_*` remains untouched. Alternative (rebuilding `chat_detail` per the original plan) would have shipped parity to a screen no user can reach.

**D2 — Header actions map to existing mobile capabilities.**
- Search: in-thread filter — a search bar expands under the header; query filters the loaded message list client-side (the web hits a server search endpoint; mobile message volume per thread is small enough, and `ChatDetailService` has no search method — adding one is out of scope per Non-Goals).
- Audio/video call: reuse `showContactActionSheet`-adjacent call plumbing — `call_session_controller.dart` + `lib/pages/call/`. Buttons disabled when `call_session_controller` reports an active call.
- Overflow menu: `showModalBottomSheet` with View booking (only when thread details expose a booking id — `ChatDetailService.getThreadDetails` payload checked at implementation; hide the row otherwise) and Block user (calls the existing block endpoint if present in `ShphChatApi`, else shows a localized "unavailable" snack — verify at implementation time against `chat_api.dart`).

**D3 — Composer ships attach + emoji now, voice later.**
Attach: `image_picker` is not currently a direct dependency of the chat page; check `pubspec.yaml` — the project already uses image picking elsewhere (profile photo upload path), so reuse that package/version rather than adding a new one. Picked image is sent via the chat attachment endpoint if `ShphChatApi` exposes one, else uploaded per the pattern used by the existing avatar upload. Emoji: a small built-in grid of common emoji inserted into the text field (no sticker package dependency). Voice notes are explicitly deferred (web has them; mobile needs record/stream plumbing — follow-up).

**D4 — Broadcast failure becomes a first-class state.**
`ShphBookingRepository` gets `lastBroadcastError` (String?) set in the existing catch, and `broadcastLiveSearch` keeps returning the booking id (the booking exists even when the broadcast fails — that's what makes retry meaningful). `BookingFlowController` exposes `lastBroadcastError`. `live_matching_screen` already receives `broadcastFailed: !_isRealJob`; it now also distinguishes:
- broadcast failed (no job id AND `lastBroadcastError != null`) → localized failure card with Retry (re-calls broadcast with the stored draft) + "View booking details" escape,
- preview/fallback (no job id, no error — e.g. draft had no category) → existing countdown preview.
Retry re-runs `_broadcastOnDemandJob` only (booking already exists), flipping the screen back to polling on success.

**D5 — Create payload aligned with web `buildCreatePayload()`.**
Drop the client-side `'booking_ref': bookingId` and the `'scheduled_for': _nowIso()` hack for on-demand jobs (web only sends `scheduled_for` in the scheduled branch). Keep `category`, `client_lat`, `client_lng`, `description`, `address_detail`, `radius_km`. If the backend creates the booking itself on the scheduled branch (`data.scheduled` + `booking_id` per `OnDemandJobCreateResponse`), live matching respects `status`/`expires_at` from the response instead of inventing a countdown start. Risk noted: if the backend actually requires `booking_ref`, retry after observing real API behavior — the fix is removing *silently wrong* fields, not guessing.

**D6 — Header collapse: scroll-fraction driven, no new widgets.**
`home_redesign_widget` computes a collapse progress `t = (offset / 96).clamp(0.0, 1.0)` on scroll (throttled by only emitting when `t` changes by > 0.01) and passes it to `PrototypeAppHeader` as `collapseProgress` alongside the existing `isCompact` (kept for the fully-compact surface color flip). The header interpolates paddings/greeting opacity between expanded and compact from `t` using `AnimatedContainer`-friendly values plus `Opacity`/`Transform`. Rationale vs. alternatives: a `SliverAppBar` rewrite would fight the current `Positioned`-in-`Stack` layout; a raw `AnimationController` adds state for what is a pure function of scroll offset.

**D7 — CTA cleanup is deletion + icon addition, nothing else.**
Remove the provider-card Row (product_page_widget.dart ~716-748) and add `Icons.chat_bubble_outline_rounded` / keep the calendar icon on the bottom-bar buttons (Contact currently has none — FFButtonWidget takes an `icon:`; Book Now already has one).

## Risks / Trade-offs

- [Chat parity is partial: no WS, no replies/pins/voice] → Documented as Non-Goals; the spec scopes parity to header actions, composer basics, chrome, quick replies.
- [Backend may reject a broadcast payload without `booking_ref`] → D5 keeps `lastBroadcastError` visible in logs and the UI; if rejection is observed, restoring the field is a one-line revert inside the retry flow.
- [Client-side search misses messages beyond the loaded window] → Threads on mobile are short (pagination exists but is not exercised); if needed, a server search method can be added to `ShphChatApi` later without spec change (behavior contract is "search within the room").
- [Header interpolation may jank on low-end devices] → Progress updates are quantized (0.01 steps) and the header is a small widget subtree; no per-frame setState beyond quantization changes.
- [Removing inline CTAs could reduce conversion if users relied on them] → The bottom bar is persistent and now carries icons, matching web where conversion lives in the single bottom CTA.

## Migration Plan

No data migration. Ship as a normal feature branch; chat room changes are isolated to `chat_detail*` files, so a revert is per-feature. Verify `flutter analyze` (0 errors) and `flutter test test/booking_funnel_test.dart` (live matching failure-state tests may need updating to the new failure card).

## Open Questions

- Whether `ShphChatApi` already exposes a message-attachment upload and a block-user endpoint — decided at implementation from `chat_api.dart`; if absent, attach falls back to text-only with the attach button hidden (spec scenario degrades gracefully) and Block shows unavailable.
