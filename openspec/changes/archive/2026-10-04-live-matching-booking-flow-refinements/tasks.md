## 1. Ripple Effect Synchronization & Marker Projection Pinning

- [x] 1.1 Update `MapRadarPulseOverlay` and `RadarScanController` in `lib/components/map_radar_scan.dart` to support stable screen coordinate anchoring during gestures
- [x] 1.2 In `LiveMatchingScreen` (`lib/pages/booking_funnel/live_matching/live_matching_screen.dart`), decouple live drag sheet padding from the pulse center so the ripple origin remains strictly glued to the pinned location marker on the map throughout drag gestures
- [x] 1.3 Re-sync camera padding and refit map bounds only upon gesture release or settled extent snapping, ensuring ripple and native map move synchronously

## 2. Live Matching Minimization & Direct Home Navigation

- [x] 2.1 Update `_onMinimize()` and `_onBackOrCancel()` in `LiveMatchingScreen` to route directly to the Home screen (`/home` or pop until root) and clear intermediate booking funnel screens
- [x] 2.2 Wrap `LiveMatchingScreen` in a `PopScope` that intercepts system back gestures and directs the user to the Home screen without popping into the previous funnel screen
- [x] 2.3 Verify and ensure that `FFAppState().isMatchingActive` / `BookingFlowController.isMatchingActive` remains true when minimized and the persistent floating pill restores the live matching view on Home

## 3. Active Live Matching Booking Guard

- [x] 3.1 Expose an active matching verification helper (`isAnyMatchingActive`) in `BookingFlowController` or `AppState`
- [x] 3.2 Add active matching collision guard to `_openBooking` in `lib/pages/product_page/product_page_widget.dart`, displaying an advisory dialog with "View Active Search" and "Dismiss" options
- [x] 3.3 Add active matching collision guard to `_openExpressCheckout` / service card taps in `lib/main/services/services_widget.dart`
- [x] 3.4 Add active matching collision guard to direct booking entry points in `lib/pages/booking_funnel/booking_flow_screen.dart`

## 4. Contact and Book Now Buttons Styling

- [x] 4.1 Remove icons (`Icons.chat_bubble_outline_rounded` and `Icons.calendar_today_rounded`) from Contact and Book Now buttons in `lib/pages/product_page/product_page_widget.dart`
- [x] 4.2 Adjust padding, height, and font styling for Contact and Book Now buttons on the product page to ensure unclipped, single-line text legibility across all screen sizes
- [x] 4.3 Remove `Icons.arrow_forward_rounded` from the Book Now button on service cards in `lib/main/services/services_widget.dart` and optimize button horizontal/vertical padding
- [x] 4.4 Review other service CTA button occurrences to guarantee consistent iconless, unclipped styling

## 5. Web Parity On-Demand Matching Dispatch & Recovery

- [x] 5.1 Verify on-demand job broadcast payload against `dev/shph-web` (`POST /api/services/on-demand/` with category_id, lat, lng, radius, description)
- [x] 5.2 Align 3-second status polling against `/api/services/on-demand/{id}/status/` in `LiveMatchingScreen` and handle `accepted`, `expired`, and `cancelled` states
- [x] 5.3 Implement laddered radius expansion (4km to 24km max) triggered on interval when unassigned, calling `expandRadius` on backend
- [x] 5.4 Provide explicit failure recovery actions ("Search Again", "Schedule Instead", "Cancel Search") on the timeout/failure card

## 6. Services Listing "Book Now" Stages & Map Behavior

- [x] 6.1 Update service card "Book Now" action in `lib/main/services/services_widget.dart` to launch `BookingFlowScreen` (multi-stage flow) instead of directly opening `ExpressCheckoutScreen`
- [x] 6.2 Ensure `BookingFlowScreen` applies the full-bleed Google Map backing with dynamic camera padding derived from `BookingMapSheetHost`, keeping the pinned coordinate framed and centered above the bottom modal
- [x] 6.3 Verify smooth stage progression across Location, Time/Urgency, Services Setup, and Review/Payment with responsive map pin framing

## 7. Verification & Quality Assurance

- [x] 7.1 Run `flutter analyze` and ensure 0 errors
- [x] 7.2 Run targeted tests (`flutter test test/booking_funnel_test.dart`) and verify all pass
- [x] 7.3 Validate OpenSpec change integrity with `openspec validate live-matching-booking-flow-refinements`
