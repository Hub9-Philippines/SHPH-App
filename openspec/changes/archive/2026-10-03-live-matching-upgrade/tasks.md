## 1. State Management & Persistent Dispatch in BookingFlowController

- [x] 1.1 Add active matching persistence properties to `BookingFlowController` (`tipAmount`, `isMatchingActive`, `lastSheetExtent`, and active search metadata).
- [x] 1.2 Implement `updateTip(double tip)` method in `BookingFlowController` to update the draft, adjust total estimate, and sync with the API.
- [x] 1.3 Add minimization state handling to ensure matching poll timers and stage transitions continue running in the background upon navigation pop.

## 2. Dynamic Map Viewport & Fluid Draggable Sheet Layout

- [x] 2.1 Refactor `LiveMatchingScreen` layout to layer `GoogleMap` and `DraggableScrollableSheet` in a `Stack` with snap extents `0.15`, `0.45`, and `0.85`.
- [x] 2.2 Attach a listener to sheet drag extents to dynamically adjust `GoogleMap` bottom padding (`constraints.maxHeight * extent`), keeping the client's location pin centered in the visible top viewport.
- [x] 2.3 Verify `MapRadarScan` circle animations remain smoothly anchored to the client's service address pin throughout drag gestures.

## 3. In-Sheet Tip & Incentive Section

- [x] 3.1 Implement `_TipSelectionCard` widget with "Add a tip; 100% goes to the provider" header and styling adhering to `AppTheme.of(context)`.
- [x] 3.2 Add horizontal selectable choice chips for preset amounts (`₱25.00`, `₱50.00`, `₱100.00`) and a `Custom` amount input modal.
- [x] 3.3 Add full-width "Submit tip" button with disabled/active state handling, async loading indicator, and `updateTip` invocation.

## 4. Booking Summary Details & Header Bar

- [x] 4.1 Implement `_MatchingHeaderBar` featuring top pill drag handle, "Looking for a pro..." title, search radius chip, and top-left chevron down minimize button.
- [x] 4.2 Implement `_BookingRouteDetailsTile` displaying service location (blue dot), service listing/category (red dot), payment method, and total fare breakdown.
- [x] 4.3 Implement `_MatchingControls` section with secondary "Cancel Booking" action (`theme.error`) and cancellation confirmation dialog.

## 5. Home Navigation & Floating Restoration Banner

- [x] 5.1 Connect `HomeWidget` (and `HomeRedesignWidget`) to observe `BookingFlowController.isMatchingActive`.
- [x] 5.2 Build a floating "Finding a provider..." status pill on `HomeWidget` with a pulsing icon indicator when matching is active.
- [x] 5.3 Wire the floating banner tap action to restore `LiveMatchingScreen` at the standard `0.45` extent with ongoing matching state preserved.

## 6. Verification & Quality Assurance

- [x] 6.1 Run `flutter analyze` and ensure 0 errors and zero regressions against project lints.
- [x] 6.2 Verify theming tokens, dark mode compatibility, and font enforcement (`GoogleFonts.plusJakartaSans()`).
- [x] 6.3 Test sheet drag gestures, map recentering, tip submission, background minimization, and Home restoration.
