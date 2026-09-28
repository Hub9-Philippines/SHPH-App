## Why

The Flutter chat room, product-page contact/booking CTAs, and home header behavior drifted from the Vue 3 + Ionic web reference (`E:\Dev\shph-web`), and live matching after checkout falls back to a "preview" state because the on-demand broadcast silently swallows every failure. Users get a bare chat room (text + send only), duplicate CTAs stacked on the product page, and bookings that can never match a provider in the wild.

## What Changes

- **Chat room web parity** — rebuild `lib/pages/chat_detail/` to mirror the web `ChatPage.vue` room layout: header with back button, avatar + name + online indicator, and end-side action buttons (search, audio call, video call, overflow menu); footer composer with attach, text input, sticker/emoji button, and round send button; quick-reply chips above the composer.
  - Wire the header buttons to the existing mobile surfaces: search opens in-thread message search, audio/video call route to the existing call flow (`lib/pages/call/`, `call_session_controller.dart`), overflow menu offers View booking / Block user.
  - Composer: attach button (image picker → send as image message), sticker/emoji picker button, voice-note button + round send button per web; message list gains date separators, sender avatar for incoming bubbles, and system/call message styling.
- **Product page CTA cleanup** — remove the Contact and Book Now buttons from the provider section card (`_buildProviderCard`-area rows at product_page_widget.dart:719/739) and add matching icons to the bottom bar Contact / Book Now buttons (bottom bar at product_page_widget.dart:1064-1120).
- **Provider profile contact button** — add a Contact button to `lib/pages/provider_profile/provider_profile_widget.dart` hero, reusing the existing `showContactActionSheet` flow.
- **Live matching broadcast fix** — stop the silent-failure path in `booking_repository.dart:_broadcastOnDemandJob`: surface broadcast errors to the controller (`lastBroadcastError`), align the create payload with the web `OnDemandBookingPage.vue` `buildCreatePayload()` (no client-side `booking_ref`/`scheduled_for` for on-demand; server returns `scheduled` branch), and only show the "Live matching unavailable / preview" state when the API call actually failed or returned no `job_id`.
- **Home header auto-collapse** — improve the collapse behavior of `PrototypeAppHeader` on home: continuously animate collapse/expand with scroll offset instead of the current binary flip at a 28px threshold, so the greeting compresses progressively and the compact bar fades in as the user scrolls.

## Capabilities

### New Capabilities
- `chat-room-parity`: The mobile chat room (thread detail) matches the web chat room's affordances — header actions (search, audio/video call, overflow menu with view-booking/block), composer (attach, emoji/sticker, voice, send), quick replies, date separators, and online indicator — using the SHPH API chat endpoints already wired in `ShphChatApi`.
- `detail-pages-cta-and-header`: Where contact/booking CTAs live on the product page (bottom bar only, with icons), the provider profile's contact entry point, and the home header's scroll-driven collapse animation.

### Modified Capabilities
- `booking-flow-redesign`: Live matching after checkout must reflect real broadcast outcomes — a failed broadcast shows the failure state, a successful one polls the real job; silent fallback to "preview" mode is only allowed for genuine API-unreachable cases and must be reported.

## Impact

- `lib/pages/chat_detail/` (widget + model), `lib/services/chat_detail_service.dart` / `chat_service.dart`, call entry points in `lib/pages/call/` and `lib/services/call_session_controller.dart`, new l10n keys (en/es/fil).
- `lib/pages/product_page/product_page_widget.dart` (provider-card row + bottom bar).
- `lib/pages/provider_profile/provider_profile_widget.dart` (hero + contact sheet reuse).
- `lib/pages/booking_funnel/booking_repository.dart`, `booking_controller.dart`, `live_matching/live_matching_screen.dart` (failure-state surfacing), checkout screens' error copy.
- `lib/main/home/home_redesign_widget.dart` + `lib/components/prototype_components.dart` (scroll-driven collapse).
- No backend changes — all fixes consume the existing `/api/services/on-demand/*`, `/api/chat/*`, and `/api/services/*` endpoints per `SHPH API.yaml`.
