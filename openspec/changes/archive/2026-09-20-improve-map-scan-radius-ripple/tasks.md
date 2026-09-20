## 1. Shared ripple component (`lib/components/map_radar_scan.dart`)

- [x] 1.1 Remove the solid center dot: delete `_centerDotRadiusMeters` and the `radar_center_dot` circle from `buildCircles`, keeping the `_minRingRadiusMeters` clamp.
- [x] 1.2 Make `updateMaxRadiusMeters(double)` on `RadarScanController`: stores the value and, when animating, recomputes the circle layer immediately (mirroring `updateCenter`).
- [x] 1.3 Relax/adjust the `maxRadiusMeters` handling so callers always pass an explicit km-derived value (4 km initial) — remove reliance on the 3000 m default where it configures behavior.

## 2. Live matching screen (`lib/pages/booking_funnel/live_matching/live_matching_screen.dart`)

- [x] 2.1 Create the radar controller with `maxRadiusMeters: _currentRadiusKm * 1000` (4 km at start).
- [x] 2.2 In `_pollJobStatus` (and `_maybeExpandRadius`/`_computeExpandTarget` path), after `_currentRadiusKm` changes call `_scanController?.updateMaxRadiusMeters(_currentRadiusKm * 1000)`.
- [x] 2.3 Replace the countdown-stage zoom ladder while searching with a radius fit: add a helper computing `LatLngBounds.fromCenter(..., radius: _currentRadiusKm)` and animate `CameraUpdate.newLatLngBounds(bounds, ~96)` via `_mapController`; keep matched/timed-out camera behavior.
- [x] 2.4 Re-run the radius-fit whenever the radius widens (on poll and on ladder expansion) so the ripple stays visible.

## 3. TM broadcast screen (`lib/pages/tm_flow/tm_broadcast_screen.dart`)

- [x] 3.1 Create the radar controller with `maxRadiusMeters: controller.searchRadiusKm * 1000`.
- [x] 3.2 In `_syncScanState`, sync the ripple radius from `controller.searchRadiusKm` via `updateMaxRadiusMeters`.

## 4. Verify

- [x] 4.1 Run `flutter analyze` — confirm 0 new errors.
- [x] 4.2 Sanity-check that no other call sites of `MapRadarScan`/`RadarScanController` need the dynamic radius (search for usages).