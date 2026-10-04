## 1. High-Performance Canvas Radar Pulse

- [x] 1.1 Implement `MapRadarPulseOverlay` with a hardware-accelerated Flutter `CustomPainter` to render expanding radar ripple rings without generating native Google Map circle diffs.
- [x] 1.2 Deprecate or replace `RadarScanController`'s 60 FPS platform channel `Set<Circle>` bridging in `lib/components/map_radar_scan.dart`.
- [x] 1.3 Wire `MapRadarPulseOverlay` into `LiveMatchingScreen` and `BookingMapSheetHost`, verifying zero-lag rendering at 60/120 FPS across all device tiers.

## 2. Dynamic Viewport Camera Framing in Booking Flow

- [x] 2.1 Update `BookingMapSheetHost` to dynamically observe the measured height of bottom modal sheets and compute exact camera bottom padding.
- [x] 2.2 Update `BookingFlowScreen` to re-frame the camera to the pinned service location whenever steps advance or bottom sheet height changes.
- [x] 2.3 Verify that the pinned location is never occluded or clipped by bottom modal widgets across small-screen and large-screen viewports.

## 3. On-Demand vs Standard Booking Mode Selection in Services Step

- [x] 3.1 Add `BookingDispatchMode` enum (`onDemand`, `scheduled`) and wire it to `BookingDraft` and `BookingFlowController`.
- [x] 3.2 Add the dispatch mode option card/selector to `BookingSetupScreen` under the service configuration step.
- [x] 3.3 Ensure selecting on-demand sets urgency to `rightNow` and hides/bypasses scheduled date pickers, while standard booking mandates date and time selection.

## 4. Live Matching and Booking API Dispatch Alignment

- [x] 4.1 Update `ShphBookingRepository.broadcastLiveSearch` to call the On-Demand API (`POST /api/services/on-demand/`) with required category ID and coordinates.
- [x] 4.2 Update `ShphBookingRepository.reserveScheduledSlot` to call the Standard Booking API (`POST /api/bookings/`) with listing ID and ISO-8601 `scheduled_at`.
- [x] 4.3 Update `LiveMatchingScreen` and `CheckoutScreen` to branch live matching execution based on the user's selected dispatch mode.

## 5. Testing & Verification

- [x] 5.1 Update `test/booking_funnel_test.dart` to cover on-demand vs scheduled dispatch selection and non-obscured camera framing.
- [x] 5.2 Update `test/booking_controller_test.dart` to test `dispatchMode` transitions and API routing.
- [x] 5.3 Run `flutter analyze` and `flutter test` to ensure 0 errors and 100% green test suite.
