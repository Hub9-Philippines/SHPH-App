## Why

The booking funnel's map/sheet layout is driven by hardcoded guesses instead of the bottom sheet's real height, so the map frames itself wrong on each step and a band of empty background shows between the map and the sheet. Users see a white gap instead of the continuous full-bleed map that ride-hailing and logistics apps (Grab, MoveIt, Angkas) use, which makes the funnel read as unfinished and hides part of the map the client is pinning a location on.

## What Changes

- Replace the hardcoded `sheetOverlap = 300.0` in `BookingFlowScreen` with a value measured from the currently-rendered step panel, so the map camera padding tracks the real sheet height when the funnel swaps between `LocationConfirmationPanel` and `TimeSelectionPanel`.
- Make the map in `BookingStatusScaffold` full-bleed (`Positioned.fill`) instead of being bounded by `bottom: sheetMaxHeight`, removing the dead background band that appears whenever the sheet is shorter than its 64% max-height budget. Affects the checkout and express-checkout screens.
- Replace the draggable-mode `EdgeInsets.only(bottom: 48 + bottomInset)` magic offset with the live sheet extent so the camera padding follows the sheet while it is dragged.
- Extract the measurement and camera-padding logic that `LiveMatchingScreen` already implements (`_sheetContentHeight` → `_dynamicMaxSheetExtent` → extent-derived `mapPadding`) into one shared host widget, and migrate `BookingFlowScreen`, `BookingStatusScaffold`, and `LiveMatchingScreen` onto it so the three screens cannot drift apart again.
- Invert the existing `booking-flow-redesign` requirement "Booking setup map bounded by bottom sheet", which currently mandates that the map SHALL NOT render behind the sheet, to mandate adaptive full-bleed rendering instead. This resolves a contradiction in the spec set: `map-tracking-screen` already requires the map to extend edge-to-edge behind its bottom sheet.
- Keep the non-map (`showMap: false`) tracking path and the radar/ripple layers unchanged in behavior, including the "only circle data rebuilds per tick" performance rule.

### BREAKING

- The `booking-flow-redesign` requirement "Booking setup map bounded by bottom sheet" is replaced. Any consumer relying on "map is clipped at the sheet's top edge" loses that contract; this is intentional and is the point of the change.

## Capabilities

### New Capabilities
- `booking-map-sheet-host`: A shared bottom-sheet host for booking screens that keeps a map full-bleed behind the sheet and derives the map's camera padding from the sheet's measured height and current drag extent, per step and per viewport.

### Modified Capabilities
- `booking-flow-redesign`: The requirement "Booking setup map bounded by bottom sheet" is replaced by one requiring the map to render full-bleed behind the step's bottom panel with camera padding that adapts to the panel's measured height.

## Impact

- Affected code:
  - `lib/pages/booking_funnel/booking_flow_screen.dart` — remove `sheetOverlap` magic number; consume the shared host.
  - `lib/pages/booking_funnel/widgets/booking_status_scaffold.dart` — map becomes full-bleed; replace the `48 + bottomInset` offset; delegate to the shared host.
  - `lib/pages/booking_funnel/live_matching/live_matching_screen.dart` — migrate its bespoke measurement logic to the shared host without changing behavior.
  - `lib/pages/booking_funnel/checkout/checkout_screen.dart` and `lib/pages/booking_funnel/express_checkout_screen.dart` — benefit through `BookingStatusScaffold`; expected to need no signature changes.
  - New shared host widget under `lib/pages/booking_funnel/widgets/`.
- Specs: `booking-flow-redesign` delta inverts an existing requirement; `booking-map-sheet-host` is new. Constraints carried forward unchanged from `native-radar-scan`, `map-scan-radius-effect`, and `map-less-booking-tracking`.
- No API, backend, route, or `BookingFlowController` changes. No new dependencies. Layout-only, so the risk is visual regression rather than data loss.
- Must be verified across small phones, tall devices, both locales (longer strings change panel height), and large text scale — the exact conditions the hardcoded values broke on.
