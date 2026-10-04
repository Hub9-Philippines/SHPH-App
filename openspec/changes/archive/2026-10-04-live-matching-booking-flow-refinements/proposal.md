## Why

During live matching and booking flow interactions, several usability and behavioral flaws degrade the client experience: the map radar ripple effect adjusts ahead of Google Maps when the bottom sheet is dragged rather than remaining glued to the pin; minimizing or pressing back from live matching reveals prior funnel screens instead of returning directly to the home screen; users can start conflicting bookings while a search is already active; and CTA buttons display redundant icons with constrained label text. Aligning the mobile matching function and booking stages with the web platform (`dev/shph-web`) ensures robust on-demand broadcast dispatch, strict pin-anchored map synchronization, and reliable booking funnel navigation.

## What Changes

- **Synchronized Map Pin Ripple Projection**: Glue the radar ripple animation overlay strictly to the Google Map marker coordinate so that dragging the bottom modal does not cause the ripple to detach or adjust ahead of the map.
- **Home Navigation on Live Matching Dismissal**: When the client minimizes live matching or presses the back control, route immediately to the Home screen (`/home`) and clear the prior booking funnel stack, while keeping the background dispatch active and displaying the floating restoration pill on Home.
- **Active Live Matching Guard**: Prevent clients from initiating another booking when a live matching search is already active, displaying an advisory dialog with direct navigation to restore the active search.
- **Iconless, High-Legibility CTA Buttons**: Remove icons from Contact and Book Now buttons on the service detail page and service listing cards, adjusting button heights and padding so full label text renders clearly without truncation or clipping.
- **Web-Parity Live Matching Dispatch & Lifecycle**: Align mobile live matching with `dev/shph-web` (`TMBroadcastPage.vue`, `useTMFlow.ts`), supporting on-demand broadcast creation, 3-second status polling against `/api/services/on-demand/{id}/status/`, laddered radius expansion up to 24km, and explicit failure recovery actions (Retry, Schedule Instead, Cancel).
- **Services Listing "Book Now" Stages Integration**: Update service card "Book Now" actions in `services_widget.dart` to open the multi-step booking stages flow (Services, Location, Payment) backed by full-bleed Google Maps with dynamic camera padding that keeps the pin centered above the bottom modal.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `live-matching-experience`: Anchors radar ripple strictly to map pin coordinate during gestures, routes minimize and back navigation directly to Home, blocks conflicting new bookings when matching is active, and aligns status polling and radius expansion with web on-demand dispatch.
- `booking-flow-redesign`: Routes service listing card "Book Now" actions into the multi-stage booking flow (Services, Location, Payment) with full-bleed Google Maps backing, dynamic camera padding preventing pin occlusion, and active matching collision guards.
- `detail-pages-cta-and-header`: Removes icons from Contact and Book Now CTA buttons and optimizes sizing/padding for complete, unclipped label legibility.

## Impact

- `lib/pages/booking_funnel/live_matching/live_matching_screen.dart`: Update minimization and back button navigation to route to Home; glue radar ripple overlay to marker coordinates during sheet dragging; ensure 3s polling parity with web.
- `lib/components/map_radar_scan.dart`: Support screen coordinate projection anchoring to eliminate gesture-time offset drift.
- `lib/main/services/services_widget.dart`: Change "Book Now" on service cards to launch `BookingFlowScreen` with active matching guard; remove arrow icon and enhance button sizing.
- `lib/pages/product_page/product_page_widget.dart`: Remove icons from Contact and Book Now buttons in the bottom bar; guard booking entry against active matching sessions.
- `lib/pages/booking_funnel/booking_controller.dart`: Expose active matching verification helper for route guards.
- `lib/pages/booking_funnel/booking_flow_screen.dart`: Ensure multi-stage Services/Location/Payment flow adopts the full-bleed live matching map behavior with dynamic camera padding.
