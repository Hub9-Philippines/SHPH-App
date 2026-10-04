## Context

See `proposal.md` for background and motivation.

The Serbisyo mobile client has two distinct booking interactions:
1. `BookingFlowScreen`: A multi-step flow (Location confirmation, Time selection, Service setup, Checkout) over a background Google Map. Currently, `BookingMapSheetHost` uses static top and bottom padding that fails to prevent the pin from being occluded when sheet sizes vary or text inputs expand.
2. `LiveMatchingScreen`: An active matching screen with full-bleed Google Map, dynamic camera padding derived from bottom sheet extent, and radar ripple animation. Currently, its radar animation (`RadarScanController` in `lib/components/map_radar_scan.dart`) pushes new native `Set<Circle>` objects over the Flutter-to-platform channel 60 times per second, causing severe frame drops.
3. API Divergence: The backend provides both `POST /api/services/on-demand/` (real-time broadcast to nearby providers with bids/acceptances) and `POST /api/bookings/` (scheduled date-time slot reservations). The booking funnel needs explicit user selection between these two distinct flows.

## Goals / Non-Goals

**Goals:**
- Implement dynamic camera padding in `BookingFlowScreen` that derives its bottom inset from the exact measured height of the active bottom sheet panel, keeping the pin centered in the visible viewport.
- Replace platform-channel native map circles in `MapRadarScan` with a high-performance Flutter canvas `CustomPainter` overlay that runs at 60/120 FPS on all device tiers.
- Add an explicit dispatch mode selector (On-Demand / Urgent vs Standard Scheduled) in the booking funnel services setup.
- Route live matching and booking submission to `/api/services/on-demand/` for immediate jobs and `/api/bookings/` for scheduled reservations.

**Non-Goals:**
- Rewriting backend endpoints in `backend/` (client integration adheres to `SHPH API.yaml`).
- Modifying provider-side bid acceptance logic (handled on web and provider dashboard).

## Decisions

### Decision 1: Measured-Height Camera Framing over Fixed Aspect Ratios
- **Approach**: In `BookingFlowScreen` and `BookingMapSheetHost`, listen to child layout size changes via `NotificationListener<SizeChangedLayoutNotification>` or frame callbacks, computing:
  `cameraPadding = EdgeInsets.only(top: mediaQuery.padding.top + 72, bottom: measuredPanelHeight + 16)`
  When the panel height changes, animate the Google Map camera to the pinned `LatLng` with the updated padding.
- **Alternative Considered**: Fixed camera padding percentage (rejected: causes pin drift on tablets, compact phones, and varying font scales).

### Decision 2: Flutter Canvas Overlay (`CustomPainter`) for Radar Pulse
- **Approach**: Implement `MapRadarPulseOverlay` using a Flutter `CustomPainter` directly inside a `Stack` above the `GoogleMap` widget. Center the ripple pulse at the screen offset of the pin.
- **Rationale**:
  - Native Google Maps `Circle` method channel calls take 2–5 ms per frame, dropping frame rates below 30 FPS on Android devices.
  - A Flutter `CustomPainter` paints directly via Skia/Impeller hardware acceleration with 0 platform channel crossings, consuming less than 0.2 ms per frame.
- **Alternative Considered**: Throttle native circle updates to 10 FPS (rejected: visible stutter and still consumes platform channel bandwidth).

### Decision 3: Explicit Dispatch Mode in Services Step
- **Approach**: In `BookingSetupScreen` and `BookingFlowController`, introduce:
  ```dart
  enum BookingDispatchMode {
    onDemand,   // Immediate / urgent / emergency -> POST /api/services/on-demand/
    scheduled,  // Later / specific date & time   -> POST /api/bookings/
  }
  ```
  Expose a segmented selector under the Services setup step. Selecting "On-Demand" presets urgency to `rightNow` and hides future date pickers; selecting "Standard" requires date and time selection.

### Decision 4: Branching Live Matching by Dispatch Mode
- **Approach**: In `ShphBookingRepository`:
  - `broadcastLiveSearch(draft)` invokes `/api/services/on-demand/` with `category_id`, `latitude`, `longitude`, `notes`, returning `job_id`.
  - `reserveScheduledSlot(draft)` invokes `/api/bookings/` with `listing`, `scheduled_at`, `notes`, returning `booking_id`.
  In `LiveMatchingScreen`:
  - When backed by an on-demand job, poll `/api/services/on-demand/{id}/status/` and listen for bids.
  - When backed by a scheduled booking, display the confirmed reservation card and provider assignment details.

## Risks / Trade-offs

- **[Risk]** Screen-space radar pulse could drift if the user pans an interactive map.
  - **Mitigation**: Panning gestures are disabled during live matching; if gestures are enabled, derive the pulse center from `GoogleMapController.getScreenCoordinate(pinLatLng)`.
- **[Risk]** On-demand job API requires category ID while standard booking requires listing ID.
  - **Mitigation**: `BookingDraft` retains both `serviceListingId` and `serviceCategoryId`, populating whichever is authoritative for the selected dispatch mode.
