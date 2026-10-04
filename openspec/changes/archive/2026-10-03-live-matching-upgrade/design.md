## Context

The live dispatch experience is a mission-critical phase of the on-demand booking funnel. When a user requests on-demand service, the app searches for nearby service providers within an expanding radius ladder. Modern benchmark apps (such as Move It) provide an immersive spatial feel where the map and bottom sheet interact seamlessly: dragging the sheet shifts the map camera to keep the location pin and radar pulse in the visual center of the visible area above the sheet, users can add incentive tips directly while searching, and users can minimize the search to browse the home screen without aborting the background dispatch.

Currently in `LiveMatchingScreen`, the sheet has rigid sizing, lacks dynamic map viewport offset recentering, lacks an interactive tipping and summary breakdown unit, and Home navigation lacks a live background dispatch indicator and restoration route.

## Goals / Non-Goals

**Goals:**
- Implement a fluid `DraggableScrollableSheet` with `minChildSize: 0.15`, `initialChildSize: 0.45`, `maxChildSize: 0.85`, and snap behavior matching Move It.
- Dynamically adjust `GoogleMap` padding (`bottom: sheetHeight`) in real-time as the sheet drags, so the user pin and `MapRadarScan` circle remain visually centered in the visible viewport above the sheet.
- Implement an in-sheet tip card ("Add a tip; 100% goes to the provider") with choice chips (`₱25.00`, `₱50.00`, `₱100.00`, `Custom`) and a responsive "Submit tip" button wired to `BookingFlowController.updateTip(...)`.
- Provide structured booking summary tiles: service address (blue dot), service category/listing (red dot), payment method, and total fare breakdown.
- Retain live matching state in `BookingFlowController` across navigation pops.
- Render a floating "Finding a provider..." status pill on `HomeWidget` with a pulsing indicator that restores `LiveMatchingScreen` at the standard 0.45 extent when tapped.
- Modularize sub-views into clean internal widgets (`_TipSelectionCard`, `_BookingRouteDetailsTile`, `_MatchingHeaderBar`).
- Maintain 0 `flutter analyze` errors, `useMaterial3: false`, `AppTheme.of(context)` tokens, and `GoogleFonts.plusJakartaSans()`.

**Non-Goals:**
- Rewriting backend dispatch engines or websockets (the existing REST API and poll intervals remain the backend authority).
- Modifying provider-side apps or driver routes.
- Adding third-party gesture libraries outside of Flutter's built-in `DraggableScrollableSheet` and `google_maps_flutter`.

## Decisions

### 1. Viewport Offsetting via Map Padding vs. Camera Animation
- **Decision**: Update `GoogleMap.padding` bottom property dynamically derived from the sheet's current fractional extent (`constraints.maxHeight * extent`), paired with gentle camera animation to the user's coordinate.
- **Rationale**: In `google_maps_flutter`, bottom padding natively defines the map's viewport bounds and automatically repositions the camera center point to the vertical center of the unpadded area. This avoids manual math for latitude/longitude pixel offsets and projection transformations, ensuring the client pin and the native `MapRadarScan` circle stay perfectly centered regardless of device aspect ratio.
- **Alternative considered**: Calculating projected screen coordinates and animating `CameraPosition(target: newOffsetLatLng)`. Rejected because animating camera target coordinates on every drag frame causes lag and jitter, and misaligns the radar scan circles from the true geographic pin.

### 2. Sheet Gestures & Snap Extents (0.15 / 0.45 / 0.85)
- **Decision**: Use `DraggableScrollableSheet` with `minChildSize: 0.15`, `initialChildSize: 0.45`, `maxChildSize: 0.85`, `snap: true`, and `snapSizes: const [0.15, 0.45, 0.85]`.
- **Rationale**:
  - `0.15`: Minimized state acts as a compact bottom bar showing search status, search radius badge, and drag handle, maximizing map visibility.
  - `0.45`: Standard view displays current status, quick tips, and primary booking details without covering the map pin.
  - `0.85`: Expanded view displays full fare breakdown, instructions, and cancellation controls.
- **Alternative considered**: Third-party sheet packages (e.g. `sliding_up_panel`). Rejected to avoid unmaintained dependencies and keep full compatibility with Flutter's scroll physics and navigation stack.

### 3. Background Dispatch Persistence & Home Restoration
- **Decision**: Persist matching state (`isMatchingActive`, `tipAmount`, `lastSheetExtent`, search metadata) in `BookingFlowController` which is provided above the navigation stack in the booking flow or registered in app scope.
- **Rationale**: When the user taps the top-left chevron or minimizes to Home, the controller continues its countdown/polling quietly. `HomeWidget` observes `BookingFlowController.isMatchingActive` and renders a floating pill. When tapped, it navigates back to `LiveMatchingScreen`, which reads the existing controller state and starts at the saved extent.
- **Alternative considered**: Storing state exclusively in `FFAppState`. Rejected because `BookingFlowController` already encapsulates draft metadata, quotes, and active job tokens; keeping live dispatch logic in the controller maintains clean separation of concerns.

### 4. In-Sheet Tip Selection and Submission
- **Decision**: Build `_TipSelectionCard` with horizontal preset chips (`₱25.00`, `₱50.00`, `₱100.00`, and `Custom`), local selection state, and an asynchronous `updateTip(amount)` method on `BookingFlowController` that updates `BookingDraft` and recalculates the total quote.
- **Rationale**: Tipping is an essential incentive mechanism during on-demand dispatch in competitive mobility/service apps (Move It parity). Presenting it directly in the matching sheet lets clients increase pickup speed without cancelling.

### 5. Architectural Separation of Modular Sub-Views
- **Decision**: Split the 2,700-line monolithic screen into clear internal widgets:
  - `_MatchingHeaderBar`: Drag handle, status label, radius pill, and minimize button.
  - `_TipSelectionCard`: Tip prompt, chips, custom input, and submit button.
  - `_BookingRouteDetailsTile`: Location, service listing, payment method, and fare rows.
  - `_MatchingControls`: "Cancel Booking" secondary button and help triggers.

## Risks / Trade-offs

- **[Risk] High-frequency map rebuilding during fast sheet drag** → **Mitigation**: Use `ValueNotifier<double>` or throttle bottom padding updates so the map controller updates smoothly without invoking expensive widget tree rebuilds. Circle animations in `RadarScanController` already animate independently via `ValueListenableBuilder<Set<Circle>>`.
- **[Risk] Sheet drag vs. inner list scrolling conflict** → **Mitigation**: Pass the `scrollController` provided by `DraggableScrollableSheet.builder` directly to the inner `ListView` or `SingleChildScrollView`, enabling Flutter's native nested scrolling physics to coordinate between sheet dragging and content scrolling.
- **[Risk] Controller disposal on route pop** → **Mitigation**: Ensure `BookingFlowController` is held at an ancestor level or kept alive while matching is active (`isMatchingActive == true`), preventing cancellation of the poll timer when navigating between Home and Matching.
