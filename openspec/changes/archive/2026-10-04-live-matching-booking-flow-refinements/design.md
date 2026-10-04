## Context

See `proposal.md` for motivation. The mobile app currently features a live matching screen (`LiveMatchingScreen`), a multi-step booking funnel (`BookingFlowScreen`), an express checkout screen (`ExpressCheckoutScreen`), and service browsing surfaces (`services_widget.dart`, `product_page_widget.dart`). Reference parity is the web application at `dev/shph-web` (`TMBroadcastPage.vue`, `useTMFlow.ts`).

Recent user testing highlighted that:
1. Dragging the bottom modal in live matching causes the radar ripple to jump ahead of the native Google Map camera instead of staying glued to the location pin.
2. Minimizing or pressing back from live matching drops the user back into prior checkout/booking funnel screens rather than cleanly returning to the Home screen.
3. Concurrent bookings are not guarded while live matching runs in the background.
4. Action buttons (Contact, Book Now) contain extraneous icons and experience label truncation.
5. Service cards launch express checkout rather than the multi-stage booking funnel (Services, Location, Payment), and lack the dynamic pin-centering map behavior of live matching.

## Goals / Non-Goals

**Goals:**
- Glue the radar ripple animation strictly to the pinned map coordinate so drag gestures do not cause offset desynchronization.
- Guarantee that minimizing or pressing back from live matching clears prior booking routes and navigates directly to the Home screen (`/home`) while keeping the search alive in the background.
- Prevent concurrent booking creation while live matching is active through an alert dialog offering to return to the active search.
- Remove icons and optimize sizing/padding for Contact and Book Now buttons on product details and service cards.
- Align on-demand matching with `dev/shph-web` lifecycle (3s polling, 4km→24km ladder expansion, accepted/expired/cancelled status, explicit retry/schedule/cancel actions).
- Route service card "Book Now" taps to the multi-stage booking funnel with full-bleed map backing and dynamic camera padding.

**Non-Goals:**
- Rewriting the backend on-demand REST API endpoints.
- Altering the web client implementation in `dev/shph-web`.
- Modifying provider-side broadcast acceptance workflows.

## Decisions

### 1. Anchor radar ripple to settled map pin and marker projection
- **Decision**: Keep the radar ripple origin (`MapRadarPulseOverlay`) anchored to the actual pinned screen coordinate of the location pin. During bottom sheet vertical drag gestures, do not instantaneously alter the CustomPainter center based on raw uncommitted drag fractions while the underlying Google Map camera has not moved. Instead, update the camera padding and re-center the map bounds upon gesture settlement or map camera idle events, ensuring the ripple and marker move synchronously.
- **Alternatives Considered**:
  - *Streaming platform channel projection calls on every drag tick*: Invoking `GoogleMapController.getScreenCoordinate()` on every 60/120Hz frame saturates the platform channel bridge, causing UI thread lag and frame drops.
  - *Native circle overlays on GoogleMap*: Suffers from platform view re-rendering overhead and lacks the smooth multi-ring easing of the GPU-accelerated `CustomPainter`.

### 2. Route live matching minimization and back navigation directly to Home
- **Decision**: In `LiveMatchingScreen`, update `_onMinimize()` and back navigation handlers (including Android `PopScope`) to invoke `context.go('/home')` (or `popUntil((route) => route.isFirst)`). Mark the active matching session as minimized in `BookingFlowController`. The persistent floating pill on the Home screen remains the restoration gateway.
- **Alternatives Considered**:
  - *Popping routes one by one*: Exposes intermediate screens (Checkout, Booking Setup) that the client has already completed, leading to confusing duplicate submissions.

### 3. Guard against concurrent bookings during active matching
- **Decision**: Expose `isMatchingActive` on `BookingFlowController` (or `AppState`). In `product_page_widget.dart`, `services_widget.dart`, and `booking_flow_screen.dart`, intercept booking initiation taps. If matching is in progress, present an alert dialog offering "View Active Search" (which navigates to the running `LiveMatchingScreen`) or "Dismiss".
- **Alternatives Considered**:
  - *Silently ignoring taps*: Leaves the user confused as to why the button is unresponsive.
  - *Auto-cancelling the running search*: Risks discarding a valid in-flight provider dispatch without explicit user consent.

### 4. Iconless, full-text CTA buttons with responsive padding
- **Decision**: Remove leading/trailing icons from Contact and Book Now buttons on `product_page_widget.dart` and `services_widget.dart`. Use `GoogleFonts.plusJakartaSans` with font size 13.5-14px, font weight 700, and minimum height 52dp with horizontal padding of 16-20dp. This guarantees all characters render on a single line without descender clipping.
- **Alternatives Considered**:
  - *Shrinking font size to 10px to fit icons*: Decreases readability and violates typography standards in the Serbisyo design system.

### 5. Web-parity polling and radius expansion lifecycle
- **Decision**: Mirror `dev/shph-web/src/composables/useTMFlow.ts` and `TMBroadcastPage.vue`:
  - Poll `/api/services/on-demand/{id}/status/` every 3 seconds.
  - Advance search radius via the shared ladder (`INITIAL_RADIUS_KM = 4`, ladder steps up to 24km max) every 30 seconds when unmatched.
  - On `accepted` with `booking_id`: transition to confirmed booking state.
  - On `expired` or `cancelled`: transition to failure card presenting "Search Again", "Schedule Instead", and "Cancel Search".
- **Alternatives Considered**:
  - *Relying solely on local timer countdown*: Fails to reflect real server-side cancellations or early provider acceptances.

### 6. Service listing card "Book Now" stages navigation
- **Decision**: In `services_widget.dart`, update `_openExpressCheckout` to launch `BookingFlowScreen` (`/booking-flow`) with the selected service listing rather than bypassing to `ExpressCheckoutScreen`. Ensure `BookingFlowScreen` utilizes `BookingMapSheetHost` to provide the same full-bleed map backing and dynamic camera offset padding seen in live matching.
- **Alternatives Considered**:
  - *Keeping express checkout for all card taps*: Prevents the user from confirming location, selecting custom scope, or choosing on-demand vs scheduled dispatch modes.

## Risks / Trade-offs

- **[Risk]** Map camera projection offset might desynchronize if device orientation changes or window resizes during matching.
  - **Mitigation**: Recompute screen coordinates on `OrientationBuilder` / `LayoutBuilder` triggers and camera idle callbacks.
- **[Risk]** Popping to home screen might discard draft state if not preserved in controller.
  - **Mitigation**: `BookingFlowController` holds the draft and active job ID as a persistent singleton / ChangeNotifier above the router stack.
- **[Risk]** Active matching guard might block a client whose previous search timed out without cleaning state.
  - **Mitigation**: Guard checks both `isMatchingActive` and verifies that the search window hasn't expired or timed out.
