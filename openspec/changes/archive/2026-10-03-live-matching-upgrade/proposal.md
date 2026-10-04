## Why

The current Live Matching / Finding Nearby Pros experience in the booking funnel lacks the fluid sheet physics, real-time map viewport offset re-centering, interactive in-sheet tipping/details, and seamless background minimization/restoration workflow seen in modern on-demand apps like Move It. Upgrading this screen elevates the dispatch experience to benchmark standard: users maintain spatial awareness as the map dynamically recenters above the sheet, can incentivize pros with immediate tips or review complete fare and route details, and can minimize the search to browse Home while an active floating status pill provides quick one-tap restoration.

## What Changes

- **Fluid Draggable Bottom Sheet**: Replace rigid sheet layouts with a smooth `DraggableScrollableSheet` configured with three snap/boundary extents: `0.15` (minimized banner mode), `0.45` (standard matching view), and `0.85` (expanded booking details).
- **Map & Camera Fluidity via Dynamic Viewport Padding**: Listen to `DraggableScrollableNotification` / `DraggableScrollableController` and dynamically offset `GoogleMapController.setPadding` (and camera target bounds) so the client's service address pin and `MapRadarScan` pulsing circle remain visually centered in the visible top viewport above the sheet.
- **Tip & Incentive Unit**: Embed an in-sheet tip card with "Add a tip; 100% goes to the provider", selectable horizontal choice chips (`₱25.00`, `₱50.00`, `₱100.00`, and `Custom`), and an interactive "Submit tip" full-width button updating the booking/dispatch quote via `BookingFlowController.updateTip(...)`.
- **Comprehensive Booking Summary Details**: Render clear structured summary tiles inside the expanded sheet:
  - Service Location Tile (`ShphAddress` with blue indicator dot).
  - Target Provider / Category Tile (`ShphServiceListing` / `ShphCategory` with red indicator dot).
  - Payment Method Tile (`ShphPaymentMethod` / card brand + last 4 digits or e-wallet).
  - Total Fare / Price breakdown (`ShphBooking.totalPrice` / estimated fee).
- **Minimization & Cancellation Controls**: Add a prominent top-left chevron down control to minimize the sheet or navigate back while preserving background dispatch, paired with a distinct "Cancel Booking" secondary button with confirmation dialog.
- **Persistent Background Dispatch & Home Restoration Banner**: Persist live matching state in `BookingFlowController` across navigation pops. On `HomeWidget`, display a floating bottom bar/pill showing "Finding a provider..." with a pulsing status badge, seamlessly navigating back to `LiveMatchingScreen` with the sheet restored at standard extent (`0.45`).
- **Clean Sub-Widget Architecture**: Refactor monolithic sheet sections into modular internal widgets (`_TipSelectionCard`, `_BookingRouteDetailsTile`, `_MatchingHeaderBar`).

## Capabilities

### New Capabilities
- `live-matching-experience`: Fluid interactive live matching screen with draggable sheet extents (0.15, 0.45, 0.85), dynamic map padding offset, radar scan, in-sheet tip selection, booking summary breakdown, and persistent minimization/restoration banner on Home.

### Modified Capabilities
<!-- None -->

## Impact

- **Affected Code**:
  - `lib/pages/booking_funnel/live_matching/live_matching_screen.dart`: Complete reconstruction of the matching layout, draggable sheet controller, dynamic map padding, tip selection, and modular sub-widgets.
  - `lib/pages/booking_funnel/booking_controller.dart`: Support for active background matching state persistence, tip management (`updateTip`), and sheet restoration state.
  - `lib/main/home/home_widget.dart` & `lib/main/home/home_redesign_widget.dart`: Live dispatch shortcut banner dynamically driven by `BookingFlowController.isMatchingActive`.
  - `lib/router/app_router.dart`: Named route/navigation support for direct restoration into `LiveMatchingScreen`.
- **Dependencies**: Uses existing `google_maps_flutter`, `provider`, `GoogleFonts.plusJakartaSans()`, and `AppTheme.of(context)`. No new packages required.
- **Design System**: Fully conforms to `useMaterial3: false`, `AppThemeData` design tokens, and banned `GoogleFonts.poppins`.
