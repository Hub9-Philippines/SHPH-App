## Why

In the current booking funnel, the Google Maps view in `BookingFlowScreen` can have its pinned location obscured by the bottom modal sheet across varying device aspect ratios. Additionally, the existing map radar scan animation (`MapRadarScan` / `RadarScanController`) repeatedly rebuilds native Google Maps `Circle` objects across the platform channel at 60Hz, causing severe CPU/GPU frame drops and slow performance on mobile devices. Furthermore, users currently lack a clear option under the services step to differentiate between an immediate on-demand dispatch (for emergency/urgent jobs) and a standard scheduled booking (for future dates), leading to inconsistent API dispatch behavior during live matching.

## What Changes

- **Map Layout & Camera Padding Alignment**: Apply the dynamic bottom-padding camera framing pattern from `live_matching_screen.dart` to `BookingFlowScreen` and its sheet host, ensuring the pin location is always centered in the visible map region and never covered by bottom sheets.
- **Hardware-Optimized Canvas Radar Pulse**: Replace the 60FPS platform-channel native Google Maps circle updates with a GPU-accelerated Flutter `CustomPainter` overlay (`RadarPulsePainter` / `MapRadarPulseOverlay`), eliminating platform bridge bottlenecks and achieving 60/120 FPS on all devices.
- **Service Dispatch Mode Selection**: Add an option in the booking flow services setup allowing the user to select between:
  - **On-Demand Dispatch** (Right now / Urgent / Emergency) targeting the SHPH On-Demand API (`/api/services/on-demand/`).
  - **Standard Booking Reservation** (Scheduled for later / specific dates) targeting the SHPH Bookings API (`/api/bookings/`).
- **Live Matching Endpoint Routing Fix**: Update `BookingFlowController` and `BookingRepository` (`ShphBookingRepository`) so that live matching dispatches to `/api/services/on-demand/` for immediate jobs (polling on-demand status) or `/api/bookings/` for scheduled slot reservations.

## Capabilities

### Modified Capabilities

- `booking-flow-redesign`: Align Google Maps layout and dynamic viewport framing with `LiveMatchingScreen` so pins are never obscured by bottom modals, and add the on-demand vs scheduled booking choice to the services configuration step.
- `native-radar-scan`: Replace native Google Map circle diffing with a lightweight, GPU-optimized Flutter canvas pulse overlay for zero-lag radar scanning across all devices.
- `booking-create-contract`: Branch live matching and booking dispatch between the `/api/services/on-demand/` endpoint (immediate broadcast) and `/api/bookings/` endpoint (scheduled reservation).

## Impact

- **Affected Files**:
  - `lib/pages/booking_funnel/booking_flow_screen.dart`
  - `lib/pages/booking_funnel/widgets/booking_map_sheet_host.dart`
  - `lib/pages/booking_funnel/setup/booking_setup_screen.dart`
  - `lib/pages/booking_funnel/checkout/checkout_screen.dart`
  - `lib/pages/booking_funnel/live_matching/live_matching_screen.dart`
  - `lib/pages/booking_funnel/booking_controller.dart`
  - `lib/pages/booking_funnel/booking_repository.dart`
  - `lib/pages/booking_funnel/booking_models.dart`
  - `lib/components/map_radar_scan.dart`
- **APIs**:
  - `POST /api/services/on-demand/` (On-demand job broadcast)
  - `GET /api/services/on-demand/{id}/status/` (On-demand polling)
  - `POST /api/bookings/` (Standard booking reservation)
- **Tests**:
  - `test/booking_funnel_test.dart`
  - `test/booking_controller_test.dart`
