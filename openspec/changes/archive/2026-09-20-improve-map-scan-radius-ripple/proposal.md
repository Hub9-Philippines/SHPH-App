## Why

The map radar ripple shown while searching for a nearby provider is hardcoded to a fixed 3 km max radius, so it never matches the radius the API endpoint is actually scanning (which starts at 4 km and widens to 24 km as the on-demand job expands). The map also holds a tight zoom (16) that clips the ripple, and the solid center-dot circle renders on top of the pin. Users cannot see how far the scan is reaching.

## What Changes

- The radar ripple's max radius becomes dynamic: it tracks the current scan radius returned by the on-demand job status endpoint (`radius_km`) and the client-side radius ladder (4 → 24 km), instead of a hardcoded 3 km.
- The solid center-dot circle (the `radar_center_dot` circle rendered under the pin marker) is removed; only the pin marker remains at the location.
- The map zoom is adjusted (fit-to-bounds / computed zoom) so the full current scan radius — and the ripple rings — are visible on screen, and re-zooms as the radius expands.
- Ring rendering is tightened so the outermost ring reads clearly as the scan boundary for the current radius.

## Capabilities

### New Capabilities
- `map-scan-radius-effect`: Behavior of the map radar scan ripple — how its extent, animation, and map framing communicate the live provider-search radius from the API endpoint.

### Modified Capabilities
<!-- None: no existing spec describes the radar ripple behavior. -->

## Impact

- `lib/components/map_radar_scan.dart` — shared circle-layer builder + loop controller (dynamic radius, remove center dot).
- `lib/pages/booking_funnel/live_matching/live_matching_screen.dart` — drives ripple radius from `_currentRadiusKm` and re-frames the map (zoom targets, `_animateMapZoom`).
- `lib/pages/tm_flow/tm_broadcast_screen.dart` — passes `controller.searchRadiusKm` as the ripple radius.
- `lib/pages/booking_funnel/widgets/booking_status_scaffold.dart` — accepts/passes the dynamic radius for its radar layer.
- No API or dependency changes; purely Dart client-side.