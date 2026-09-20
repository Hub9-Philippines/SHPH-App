## Why

The on-demand matching and tracking screens ship legacy visuals that feel unfinished: a 1-second-ticking numeric countdown next to the progress bar ("Xs" + seconds) reads as a broken clock, the radar pulse is a screen-pixel CustomPainter that clips and distorts under map zoom/rotation, and the booking tracking page still carries a full map canvas even though the statuses (confirmed → en route → on site → in progress → completed) are what users actually track. The ripple must also represent a real geographic sweep (0→3000 m) so the scan reads as a true radius, not a decorative pulsing circle.

## What Changes

- **Remove countdown timers on both finding-nearby-pro screens** (`LiveMatchingScreen` in the booking funnel and `TMBroadcastScreen` in the TM flow): no numeric `Ns`/seconds text anywhere; the only progress feedback is the progress bar/indicator, driven smoothly by an animation (no 1-second setState jumps). Backend timeout semantics (180s window, radius ladder) are preserved — only the visible counter disappears.
- **Map-less booking tracking page** (`StatusPage`, the confirmed/en_route/on_site/in_progress/completed tracker): remove the full-bleed `GoogleMap` canvas, provider location markers, route polylines, camera-bounds logic, and map controller state. The page becomes a status-timeline + provider card + actions layout with no map dependency. Polling of real booking status is unchanged.
- **Native-geometry radar ripple replacing pixel CustomPainters**: new map-scan ripple implemented with native Google Maps `Circle` layers (google_maps_flutter) on the two search maps — `LiveMatchingScreen._mapBody` and the shared `BookingStatusScaffold` (used by `TMBroadcastScreen`). Replaces `_RadarPainter` (booking funnel) and `_TMLivePulse`/`_PulseRing` (TM flow). Behavior:
  - Rings expand from 0 to 3000 m in exactly 30 s, looping indefinitely.
  - 3 staggered rings fade out in opacity as they approach max radius (radar-scan look).
  - Rings are native geometry — they scale/rotate/zoom with the tiles and never clip or drift relative to the pinned location.
  - Runs at 60 fps on a dedicated ticker; only circle layer data updates each tick, never the whole map widget tree.
  - Controllers/tickers disposed on unmount.
  - Rings centered on the pinned booking/client location so the visual radius matches real-world meters.

## Capabilities

### New Capabilities
- `proximity-scan-progress`: Searching/proximity screens show only a smooth progress indicator while scanning; no numeric countdown text is shown.
- `native-radar-scan`: A looping, geographically-true radar ripple rendered via native map geometry (radius 0→3000 m, 30 s period, staggered fading rings, zoom/rotation stable, smooth 60 fps updates, clean disposal).
- `map-less-booking-tracking`: The booking status page tracks confirmed/en_route/on_site/in_progress/completed progress without any map UI.

### Modified Capabilities
<!-- None — no existing openspec/specs/ capability changes requirement behavior. -->

## Impact

- **Files rewritten**: `lib/pages/booking_funnel/live_matching/live_matching_screen.dart` (progress bar smoothness, countdown removal, native ripple on `_mapBody`), `lib/pages/tm_flow/tm_broadcast_screen.dart` (countdown removal, `_TMLivePulse`/`_PulseRing` removed in favor of native ripple), `lib/pages/booking_funnel/widgets/booking_status_scaffold.dart` (native ripple layer), `lib/pages/booking_funnel/status_page.dart` (map removed).
- **New shared code**: a reusable native radar ripple widget/controller (Google Maps `Circle` set + `Ticker`/`AnimationController`) plus reusable smooth progress indicator, likely under `lib/components/` or `lib/pages/booking_funnel/live_matching/`.
- **Removed**: `_RadarPainter` / `_RadarPulse` / `_GradientBar` time-driven countdown math, `_TMLivePulse` / `_PulseRing` screen-pixel pulses, `StatusPage` map controller / markers / polylines / camera logic.
- **Dependencies**: `google_maps_flutter` already in use; no new packages.
- **Risk**: `flutter analyze` must stay at 0 errors; l10n keys `bfSecondsRemaining`, `tmTimedOut` remain (still used as stage text elsewhere) — verify before deleting any key.