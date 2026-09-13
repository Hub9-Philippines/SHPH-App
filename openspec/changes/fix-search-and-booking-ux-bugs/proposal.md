## Why

A QA pass surfaced six UI/UX defects across the search page, services listing (product) page, and booking flow that undermine visual consistency and block correctness (one crash, one failing API retry). Fixing them now keeps the app aligned with the redesigned home screen and the web parity target before broader rollout.

## What Changes

- Match the search page search bar to the home screen's pill-style search trigger (radius 16, soft shadow-only, white surface, no hard border) instead of the current hard-bordered, 24-radius input field.
- Fix the services listing (product) page location button, which currently throws `type 'Null' is not a subtype of type 'GeographicSelectionType' in type cast` when tapped, by routing to the location selection surface with the required `selectionType`.
- Make the "Book Now" CTA text render legibly (white foreground) instead of dropping its foreground color.
- Fix the booking estimate retry so the estimate request always carries `listing_id`, eliminating the `400 {"detail":"listing_id is required."}` response on the first booking-flow step.
- Remove the large gap between the map and the bottom sheet on the booking status/map screen so the map is not visually cropped.
- Fix the search empty state so both action buttons render with visible text (the second button next to "Clear filters" currently shows only a border).

## Capabilities

### New Capabilities
- `search-and-services-ux`: User-facing behavior of the search page and services listing page — search-bar visual consistency with the home pill, location-pill navigation without crashing, legible CTA ("Book Now") text, and a fully-labeled search empty state — plus the booking-flow estimate contract that must always send `listing_id`.

### Modified Capabilities
<!-- No existing spec's requirement-level behavior changes as a whole; these are defect fixes surfaced on existing surfaces. The new capability above captures the behavioral contract. -->

## Impact

- `lib/pages/search_page/search_page_widget.dart` — search bar styling (lines ~428-481) and empty-state action buttons.
- `lib/components/prototype_components.dart` — `_SearchTriggerBar` (lines ~314-376) used as the styling reference.
- `lib/router/app_router.dart:601` — the `selectionType` cast that crashes; related `geographic_selection` model/widget.
- `lib/pages/product_page/product_page_widget.dart:666,1027` — "Book Now" button foreground.
- `lib/pages/booking_funnel/booking_repository.dart:38-48` and `booking_controller.dart` — estimate request `listing_id`.
- `lib/components/explore_map_view.dart` — map/bottom-sheet layout.
- Cross-cutting `AppButton` component (shared by bugs 3 and 6) — foreground color preservation.
