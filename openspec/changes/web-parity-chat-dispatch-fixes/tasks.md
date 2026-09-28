## 1. Live matching broadcast fix (highest user impact)

- [x] 1.1 Add `lastBroadcastError` to `ShphBookingRepository`; set it (and clear it on success) in `_broadcastOnDemandJob` instead of only flipping `lastBroadcastSucceeded`; expose it through `BookingFlowController`
- [x] 1.2 Align the create payload in `_broadcastOnDemandJob` with web `buildCreatePayload()`: drop `booking_ref` and the on-demand `scheduled_for`, keep category/lat/lng/description/address_detail/radius_km
- [x] 1.3 In `live_matching_screen.dart`, split the current `broadcastFailed` branch into (a) real failure (no job id + `lastBroadcastError != null`) showing a localized failure card with Retry (re-runs the broadcast only, then resumes polling) and View-booking escape, and (b) preview fallback (no job id, no error)
- [x] 1.4 Add/refresh l10n keys for the failure card (en/es/fil) and run `flutter gen-l10n`
- [x] 1.5 Update `test/booking_funnel_test.dart` expectations for the new failure state and run `flutter test test/booking_funnel_test.dart`

## 2. Chat room web parity

- [x] 2.1 Inspect `ShphChatApi`/`ChatDetailService` for attachment-upload and block-user endpoints; record which composer/menu features degrade gracefully (per design Open Questions)
- [x] 2.2 Rebuild `chat_detail_widget.dart` header: back button, avatar + name + online indicator, search / audio-call / video-call / overflow actions (call buttons disabled during an active call via `call_session_controller`)
- [x] 2.3 Implement overflow menu (View booking when thread has one, Block user or graceful unavailable) and the in-thread search bar filtering loaded messages
- [x] 2.4 Rebuild the composer as the web-style pill: attach (image pick → send; hide button if no upload endpoint), text input, emoji picker (built-in grid), round send button enabled only with content
- [x] 2.5 Add message-list chrome: day separators, incoming-sender avatars, system/call message styling, quick-reply chips on empty threads
- [x] 2.6 Extend `ChatDetailModel` with search state, picker/emoji handling, and call/booking/block navigation callbacks; add new l10n keys (en/es/fil) and run `flutter gen-l10n`

## 3. Product page CTA cleanup

- [x] 3.1 Remove the inline Contact/Book Now row from the provider section card in `product_page_widget.dart`
- [x] 3.2 Add a chat/contact icon to the bottom-bar Contact button (Book Now already has its calendar icon) and confirm both keep their existing handlers

## 4. Provider profile contact button

- [x] 4.1 Add a Contact button to the provider profile hero wired to `showContactActionSheet` with the provider's name/phone availability, matching product-page behavior

## 5. Home header auto-collapse

- [x] 5.1 Replace the binary `_isHeaderCompact` flip with a scroll-fraction `collapseProgress` (quantized ~0.01) passed from `home_redesign_widget.dart` to `PrototypeAppHeader`
- [x] 5.2 Interpolate header padding/greeting opacity between expanded and compact from `collapseProgress` in `prototype_components.dart`, keeping `isCompact` for the surface-color flip and preserving all header actions

## 6. Verification

- [x] 6.1 Run `flutter analyze` — 0 errors
- [x] 6.2 Run `flutter test test/booking_funnel_test.dart`
- [ ] 6.3 Manual pass: chat room affordances vs web, product page CTAs, provider contact, live matching retry, home header scroll feel (requires a device/emulator — left for the user)
