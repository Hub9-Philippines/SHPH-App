## Why

The services-listing booking funnel (`/booking-flow`) is a full-screen Google Map with a draggable bottom sheet that shows a numbered step label ("Step X of 4") and a spine indicator, then pushes the client through two more screens (`BookingSetupScreen` → `CheckoutScreen`) before submission. Product wants a single whole page with one-at-a-time accordion stages modeled on the legacy `/booking` page: no step numbers, no Google Maps inside the booking stages (location becomes an address picker), and a final CTA that hands off to the payment page. Two UI defects ship alongside it: in light mode, filled buttons render dark labels because theme text tokens bake in `primaryText`, and the live-matching radar ripple drifts away from the pin whenever the map's inset padding or camera changes.

## What Changes

- **Single-page accordion booking funnel**: `BookingFlowScreen` becomes one page containing four stages — Location, Time, Details, Review — presented as an accordion with exactly one stage expanded, tappable completed-stage headers, and later stages locked until prerequisites validate. **BREAKING**: the funnel no longer pushes `BookingSetupScreen` or `CheckoutScreen` (they remain as thin, test-covered shells).
- **No numbered step indicators**: remove "Step X of 4" labels and numbered/stage-count badges from every funnel surface.
- **Mapless booking stages**: remove `GoogleMap`, `BookingMapSheetHost`, geolocator, and the pin-editing action from the funnel; location is captured only through the address picker (`EditAddressWidget`). Maps remain in live matching, booking status, and express checkout.
- **Payment-page handoff**: the Review stage's "Proceed to Payment" action navigates to `/booking-payment` with service, schedule, price, notes, and provider extras; the payment page becomes the only place the funnel's booking is created and paid. **BREAKING**: immediate/urgent funnel bookings no longer broadcast the on-demand live search from checkout (express checkout retains that path).
- **Estimate bootstrap**: the funnel requests the server estimate on entry (previously only after a draft mutation) and gates "Proceed to Payment" on an available estimate.
- **Light-mode filled button labels**: filled-background buttons across the booking funnel and related surfaces render labels with the theme's on-primary contrast token in both themes.
- **Pin-anchored radar ripple**: the live-matching ripple center re-synchronizes to the pinned marker's screen projection after map padding changes, camera moves, and camera-fit animations — not only on camera idle.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `booking-flow-redesign`: funnel stage presentation becomes a mapless single-page accordion without numbered steps; the Review confirmation action hands off to the payment page; submission-path and dispatch-mode requirements are rescoped to the payment handoff; map full-bleed/camera-padding requirements for the booking stages are removed; the services entry-point requirement drops its map-centering contract; the estimate requirement gains entry bootstrap behavior.
- `map-scan-radius-effect`: adds a requirement that the ripple center tracks the pinned marker across viewport changes (padding, camera moves, camera fits).
- `cupertino-widget-adoption`: adds a requirement that filled action buttons render theme-contrast labels in light and dark modes.

## Impact

- `lib/pages/booking_funnel/booking_flow_screen.dart`: rewritten as the accordion stages page (removes map, sheet host, geolocator, step labels).
- `lib/pages/booking_funnel/setup/booking_setup_screen.dart`, `lib/pages/booking_funnel/checkout/checkout_screen.dart`: content extracted into shared stage widgets; remain as thin shells (no longer navigated to).
- New: `lib/pages/booking_funnel/widgets/details_stage_content.dart`, `widgets/review_stage_content.dart`, `widgets/address_banner.dart`; `widgets/time_selection_panel.dart` gains a hidden-next-button option.
- `lib/pages/booking_payment/booking_payment_widget.dart`, `lib/router/app_router.dart`: destination of the new handoff (extras contract unchanged).
- Filled-button call sites in `lib/pages/booking_funnel/` (checkout, setup, live matching, express sheet, status, success, controller snackbar).
- `lib/pages/booking_funnel/live_matching/live_matching_screen.dart`: ripple offset re-sync events.
- Tests: `test/booking_funnel_test.dart`, `test/booking_setup_widget_test.dart`, `test/booking_controller_test.dart` stay green; new tests for accordion progression, payment handoff extras, and map-free rendering.
- OpenSpec: supersedes the map-era `booking-flow-redesign` requirements archived from `live-matching-booking-flow-refinements`.
