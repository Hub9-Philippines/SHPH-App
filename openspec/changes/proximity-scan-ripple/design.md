## Context

See `proposal.md` — Why. Current state:

- The app uses **only** `google_maps_flutter` (no `flutter_map`), so the native-geometry option is Google Maps `Circle` layers (the user-requested "Option A").
- `LiveMatchingScreen` (`lib/pages/booking_funnel/live_matching/live_matching_screen.dart`) renders a full-screen `GoogleMap` in `_mapBody()`, overlays a screen-pixel `_RadarPulse`/`_RadarPainter` CustomPainter (3 rings, 4.8 s loop, pixel radii), runs a 180 s search window (`_searchWindowSeconds`) with a `secondsRemaining` countdown shown as `bfSecondsRemaining` text in `_StatusBadge` and `_SearchingSheet`, and drains a `_GradientBar` by whole seconds.
- `TMBroadcastScreen` (`lib/pages/tm_flow/tm_broadcast_screen.dart`) uses the shared `BookingStatusScaffold` (`lib/pages/booking_funnel/widgets/booking_status_scaffold.dart`) which is a `StatelessWidget` with a `GoogleMap`; it overlays the pixel `_TMLivePulse`/`_PulseRing` (1.8 s loop, container-scaled rings) as the `center` widget, and shows `'${controller.secondsRemaining}s'` + a `LinearProgressIndicator(secondsRemaining/60)` in `_TMBroadcastTopCard`.
- `StatusPage` (`lib/pages/booking_funnel/status_page.dart`) stacks a full-bleed `GoogleMap` (markers, polylines, camera-bounds) beneath a 5-stage timeline sheet (confirmed → en_route → on_site → in_progress → completed) plus a provider card; `_mapController`/`_mapReady`/`_polylines`/`_scheduleBoundsUpdate` exist only for the map.
- Both screens already mix `TickerProviderStateMixin` where needed; `BookingStatusScaffold` is stateless.

## Goals / Non-Goals

**Goals:**
- A reusable, geoprojected ripple built from native `Circle` layers: 0→3000 m over exactly 30 s, looped, with 3 staggered ease-out rings that fade to near-zero opacity at max radius.
- Ripple updates at 60 fps by rebuilding only the `GoogleMap` widget's `circles` set — markers/tiles/camera stay untouched.
- Countdown **text** removed on both search screens; progress bars glide smoothly between updates; server timeout/expiry semantics unchanged.
- `StatusPage` tracking without any map: timeline + provider card + actions use the full canvas.

**Non-Goals:**
- No `flutter_map` (Option B) implementation — package not in the project; `google_maps_flutter` is pinned.
- No change to the 180 s radius-ladder or TM dispatch window math, polling cadence, or failure/timeout flows.
- No change to `status_page` polling or stage semantics — only the map presentation goes away.
- No new l10n keys added (existing counter keys may become unused and are removed only if `flutter analyze`/`gen-l10n` stays clean).

## Decisions

### D1. Shared native radar-scan component: `lib/components/map_radar_scan.dart`
New file exposing two pieces used by both search maps:

1. **`MapRadarScan`** — a static pure function `buildCircles(LatLng center, double t, {maxRadiusMeters, ringCount, ease, colors})` that maps an animation fraction `t ∈ [0,1)` to a `Set<Circle>` of `ringCount` staggered rings. Per ring `i`:
   - `phase = (t + i / ringCount) % 1.0`
   - `eased = Curves.easeOutCubic.transform(phase)`
   - `radiusMeters = max(minRadiusMeters, eased * 3000)` (`minRadiusMeters ≈ 80` so a phase-0 ring renders as a dot instead of a degenerate zero-radius circle)
   - `strokeColor`/`fillColor` opacity = `(1 - eased) * baseOpacity` scaled per ring (e.g. 0.42 / 0.30 / 0.20 stroke, ~0.10/0.06/0.03 fill) — radar fade
   - plus one small solid center `Circle` (radius ≈ 60 m, full theme-primary fill) as the pinned-location dot.
   - Keeps `onTap` unset, `consumeTapEvents: false`.

2. **`RadarScanController`** — `ValueNotifier<Set<Circle>>` (ChangeNotifier) that owns an `AnimationController(vsync, duration: 30 s)` calling `repeat()`, listens on every tick, recomputes via `MapRadarScan.buildCircles`, and stores the result in `value`. `stop()`/`dispose()` release the ticker. Consumer screens create it in `initState`, destroy it in `dispose`, and pass it into the map widget wrapped in a `ValueListenableBuilder`.

**Rationale:** google_maps_flutter's `GoogleMap` is an opaque platform view; passing a fresh `Set<Circle>` each tick lets the platform diff **only** the circle layer — no tile/marker/camera churn, no clipping at widget bounds under zoom/rotation (native geometry). A `ValueNotifier` + `ValueListenableBuilder` around just the `GoogleMap` widget scopes rebuilds to the map instead of the whole screen. Alternatives considered: (a) keep pixel `CustomPainter` — rejected: clips/misaligns under zoom+rotation and can't encode real meters; (b) `flutter_map` `CircleLayer` — rejected: new dependency, native Google Maps already integrated.

### D2. Ripple wiring in `LiveMatchingScreen._mapBody`
- Add `RadarScanController _scanController` created in `initState` when `widget.showMap` (skip if no map), disposed in `dispose`.
- `_mapBody` wraps the `GoogleMap` in a `ValueListenableBuilder<Set<Circle>>` and passes `circles: scanCircles`. Markers stay a stable `Set` (same instance) so the diff touches only circles.
- Delete the `Positioned.fill(IgnorePointer(_RadarPulse(...)))` overlay (`Layer 2`), and remove `_RadarPulse`/`_RadarPainter` classes and the `dart:ui`/`_radarController` overlay use. `_radarController` is kept only if still referenced for success reveal (match appears with a one-shot pulse?) — otherwise deleted; the native scan becomes the active visual.
- Stop/clear the scan (`_scanController.stop()`; rebuild with empty circles) on `_finishTimedOut()` and on match (`_onJobAccepted`/`_matchedPro != null`), so no residual rings linger.

### D3. Ripple wiring in `BookingStatusScaffold` + `TMBroadcastScreen`
- `BookingStatusScaffold` gains an optional `RadarScanController? radarScan` param. When non-null its `GoogleMap` is wrapped in a `ValueListenableBuilder` passing `circles: radarScan.value`; the `center` overlay slot is left for non-scan content only.
- `TMBroadcastScreen` (already a `StatefulWidget`) creates the `RadarScanController` in `initState`, passes it to the scaffold, starts/stops it off `controller.hasFailed` / `controller.hasMatchedProvider`, and disposes it in `dispose`.
- Delete `_TMLivePulse`/`_PulseRing` and the `center: ... const _TMLivePulse()` usage; the native rings + center dot replace them.

### D4. Timer removal + smooth progress (both screens)
- Keep all internal `secondsRemaining` accounting, async expiry sync (`_syncCountdownFromExpiry`), `_decrementCountdown`, `_finishTimedOut`, radius rungs and the 3 s poll — these are behavior, not UI.
- `LiveMatchingScreen`: remove the `bfSecondsRemaining(secondsRemaining)` text in `_StatusBadge` (and the `bfSearching`+count `Row` in `_SearchingSheet`). The `_GradientBar` keeps receiving `progress = secondsRemaining / 180`, but its `FractionallySizedBox.widthFactor` is wrapped in a `TweenAnimationBuilder<double>` (`tween: Tween(end: progress)`, ~600 ms, `easeOutCubic`) so the bar always glides toward the target instead of snapping each tick. Same glide applies in `_StatusBadge`.
- `TMBroadcastScreen`: remove `'${controller.secondsRemaining}s'` from `_TMBroadcastTopCard` (keep the radius chip + dispatch chip; on timeout still show `tmTimedOut` label). Wrap `LinearProgressIndicator.value` in the same `TweenAnimationBuilder`. Optionally extract a tiny shared `_SmoothProgressBar` helper into `lib/components/` used by both.
- `_gradientController` (per-rung color morph) stays untouched.

### D5. Map-less `StatusPage`
- Remove `GoogleMap` import, `GoogleMapController _mapController`, `_mapReady`, `_polylines`, `_currentProviderLocation` map role, `_scheduleBoundsUpdate`, the map `markers`/`polylines` layers, and the `Positioned.fill(GoogleMap(...))` stack entry. Delete `dart:math` only if unused after bounds math goes.
- Replace the map layer with a themed `LinearGradient` background (`primaryBackground → secondaryBackground`, same tokens as `BookingStatusScaffold`'s no-map branch) so the page keeps its visual identity.
- Rework `build` from `Stack` to a map-free layout: floating back/home + provider card as the top section, the existing `_TrackingSheet` (5-stage timeline, `_pulseController` animation, action row) as the main flexed body, review/invoice buttons preserved. Remove the now-meaningless `_sheetHeightFactor` fixed 45% anchoring so content uses the full canvas.
- Keep `TickerProviderStateMixin`, `_pulseController`, `_startStatusPolling`, `_stageIndexForStatus`, and the on-site location resolution for polling (state only; nothing renders a map).

## Risks / Trade-offs

- **`Set<Circle>` per tick cost** (3–4 circle objects rebuilt 60×/s) → circles are cheap immutable value objects and the platform diffs only changed layers; if profiling shows jank on low-end devices, throttle updates to every other frame or drive the ticker at 30 Hz (still visibly smooth).
- **Circle opacity/resize on Android vs iOS parity** → google_maps_flutter renders stroke/fill the same on both platforms; verify on-device because stroke-width styling differs slightly from the pixel painter's glow look.
- **`StatusPage` layout regressions** (provider card overlap, sheet anchoring) → full rework of the build method; keep widget composition (`_TrackingSheet`, `_ProviderCard`, `_FloatingCircleButton`) unchanged and only restructure the container so behavior stays identical.
- **Leaving unused l10n keys** (`bfSecondsRemaining`) referenced by `AppLocalizations` → after removing all usages, delete the key from the three `.arb` files only if `flutter gen-l10n` stays clean; otherwise leave it (unused keys are non-blocking) to avoid churn.
- **`analyze` bar (0 errors)** → edits must not introduce new analyzer errors (strict lints like `always_declare_return_types`, `use_build_context_synchronously`); run `flutter analyze` after each task.
- **`_radarController` entanglement** (success reveal may reuse it) → before deleting, grep usages; if still needed for the post-match reveal pulse, repurpose it rather than delete.

## Migration Plan

- Implement on `feat/ui-ux-reconstruction` (current feature branch). Landing order: shared component (D1) → ripples on both search maps (D2/D3) → timer/progress (D4) → status page (D5) → `flutter analyze` / targeted `flutter test` runs.
- Rollback is per-commit: revert this change's commits; behavior (polling, matching, timeout) is untouched by the visual changes, so no data/API migration risk.
- No keystore/CI build changes; `flutter build apk --release` smoke test at the end.

## Open Questions

None — the specs, approach, and task breakdown are fully determined above.