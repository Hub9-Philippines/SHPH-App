## Context

The radar scan ripple lives in `lib/components/map_radar_scan.dart`: `MapRadarScan.buildCircles` composes a circle layer (solid center dot + 3 staggered rings expanding 0 → 3000 m over a 30 s loop), and `RadarScanController` (a `ValueNotifier<Set<Circle>>`) drives it from an `AnimationController`. Consumers:

- `lib/pages/booking_funnel/live_matching/live_matching_screen.dart` — already tracks the real API radius in `_currentRadiusKm` (seeded from `radius_km` in the job-status poll, widened via the 4→24 km ladder), but creates the controller with the default 3000 m and holds a fixed near-field zoom (`_zoomNearby` 16) through most of the countdown, so the ripple boundary is never visible.
- `lib/pages/tm_flow/tm_broadcast_screen.dart` — creates the controller with defaults; `controller.searchRadiusKm` already reflects the live radius (4 → 8).

The map camera is only moved by `_mapController?.animateCamera(...)`; the GoogleMap widget is rebuilt each ripple tick under a stable `ValueKey(markers)`, so `initialCameraPosition` does not reset the camera. See proposal.md for motivation.

## Goals / Non-Goals

**Goals:**
- Ripple geometry driven by the actual API scan radius (km → meters), live-updatable mid-loop.
- Remove the filled center dot; the pin marker alone marks the location.
- Frame the map so the full scan radius / ripple is visible, re-framing on radius expansion.
- Share the mechanism across both consumers with minimal per-screen code.

**Non-Goals:**
- Changing the 30 s loop cadence, ring count, or opacity model of the ripple.
- Changing how the backend computes or returns `radius_km`.
- Altering the post-match provider-route map (it already frames route bounds).

## Decisions

### 1. Keep the circle-layer approach; make the max radius dynamic

The existing native-`Circle` approach stays (rings anchored to the pin, scale-free under zoom). The change is confined to:

- `MapRadarScan.buildCircles`: drop the `radar_center_dot` circle and its `_centerDotRadiusMeters` constant. Keep `_minRingRadiusMeters` so a phase-0 ring still reads as a small dot instead of a degenerate speck.
- Add `RadarScanController.updateMaxRadiusMeters(double)` — mirrors the existing `updateCenter` pattern: store the new value, and if animating, recompute the layer immediately (`_onTick()`). Consumers already recreate the circle set each tick, so the running animation adopts the new radius within the current cycle.
- Remove the `defaultMaxRadiusMeters = 3000` default from the *consumers'* perspective: both call sites will pass an explicit initial radius (4 km).

*Alternative considered:* re-creating the controller on every radius change. Rejected — it resets the animation phase and ticker, and the existing `updateCenter` pattern already establishes the lightweight in-place update idiom.

### 2. Radius source: meters = current km radius × 1000

- Live matching: pass `maxRadiusMeters: _currentRadiusKm * 1000` at creation (4 km) and call `updateMaxRadiusMeters` whenever `_currentRadiusKm` changes (from the poll and from the `_computeExpandTarget` ladder rungs).
- TM broadcast: pass `maxRadiusMeters: controller.searchRadiusKm * 1000` at creation and keep it in sync inside `_syncScanState`, which is already re-invoked on every build from the `Consumer`.

### 3. Frame the map by current radius: `LatLngBounds` instead of stage zoom

Replace the countdown-stage zoom ladder (`_zoomNearby`/`_zoomChecking`/`_zoomSweep`) while searching with a bounds fit computed from the ripple center and `_currentRadiusKm`:

- `LatLngBounds.fromCenter(center: center, latitudeSpan/longitudeSpan in degrees)` computed from radius m and the local latitude, then `_mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, padding))`.
- Padding of ~96 logical px so the outermost ring is comfortably inside the edge with the top status badge / bottom sheet in mind.
- Re-invoke the fit when the radius widens (each ladder rung, and on each poll where `radius_km` grew) — the spec's "re-frame on radius change."
- Keep the matched/timed-out camera behavior as-is (the assigned-route map already handles matching; timeout returns to the near-field zoom). The ripple `stop()` on terminal states already exists in both screens.

*Alternative considered:* computing an analytic zoom (ground-resolution formula) and `animateCamera(CameraUpdate.zoomTo(...))`. Rejected — the bounds fit yields the exact guarantee we need (radius fully visible) without a hand-tuned zoom table, and the codebase already uses `newLatLngBounds` for the route map.

### 4. Use the theme primary color

Keep `ringColor: AppTheme.of(context).primary` (unchanged behavior; dark mode dependency).

## Risks / Trade-offs

- `newLatLngBounds` can throw if the map view has zero size or on first creation → Mitigation: guard on `_mapController != null`, call only after `onMapCreated`, and wrap in try/catch; it mirrors the pattern already proven in `_AssignedProviderRouteMapState`.
- A ripple whose boundary is the live radius may appear to "jump" outward when the radius widens mid-cycle → Acceptable per spec ("within the same animation cycle"); rings continue from their current phase.
- Removing the center dot leaves a phase-0 ring the only visual at the very start of each cycle → Mitigated by the existing `_minRingRadiusMeters` clamp so a small ring dot persists at the pin, and the pin marker itself remains.
- Two call sites must stay in sync → Mitigation: both consumers funnel through `RadarScanController.updateMaxRadiusMeters`; no third consumer of the component exists today.
- Zoom fitting to a 24 km radius may look very far-out for the brief final sweep → Mitigation: this is the required framing per the spec (whole scan radius visible); the sheet/top-card keep nearby context readable.

## Migration Plan

Client-only Dart change, no backend/deployment coupling:
- Land the component change (`map_radar_scan.dart`) together with both consumers so behavior stays consistent across screens.
- Rollback: revert the three file changes; no data or schema effects.

## Open Questions

None.