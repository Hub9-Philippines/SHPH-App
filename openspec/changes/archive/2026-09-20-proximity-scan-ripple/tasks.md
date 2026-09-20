## 1. Shared native radar-scan component

- [x] 1.1 Create `lib/components/map_radar_scan.dart` with a pure `MapRadarScan.buildCircles(...)` helper that, given a `LatLng center`, fraction `t`, `maxRadiusMeters` (3000), `ringCount` (3) and theme colors, returns a `Set<Circle>` of staggered ease-out rings (phase = `(t + i/ringCount) % 1`, radius = eased*3000 clamped to a ~80 m min, stroke/fill opacity fading to ~0 at max radius) plus a small solid center-dot circle.
- [x] 1.2 Add `RadarScanController` (`ValueNotifier<Set<Circle>>`) that owns an `AnimationController` of exactly `Duration(seconds: 30)`, `repeat()` looping, recomputes circles on every tick, exposes `stop()`/`dispose()` that release the ticker cleanly.
- [x] 1.3 Verify `lib/components/map_radar_scan.dart` compiles clean (imports `google_maps_flutter`; no analyzer errors).

## 2. Native ripple on the booking live-matching map

- [x] 2.1 In `live_matching_screen.dart` create the `RadarScanController` in `initState` (only when `widget.showMap`), dispose it in `dispose`, and stop it on `_finishTimedOut()` and when a provider matches.
- [x] 2.2 In `_mapBody`, wrap the `GoogleMap` in a `ValueListenableBuilder<Set<Circle>>` bound to the scan controller and pass `circles:`; keep marker set stable so only the circle layer updates per tick.
- [x] 2.3 Remove the `Positioned.fill(IgnorePointer(_RadarPulse(...)))` overlay in `build` and delete `_RadarPulse`/`_RadarPainter` classes and their now-unused controller/imports (verify `_radarController` has no other use before deleting).
- [x] 2.4 Confirm matched/timeout states clear the ripple (rings removed from map) and the native scan replays cleanly on `_retryProviderSearch`.

## 3. Native ripple on the TM broadcast map

- [x] 3.1 Add optional `RadarScanController? radarScan` param to `BookingStatusScaffold`; when non-null wrap its `GoogleMap` in a `ValueListenableBuilder` passing `circles: radarScan.value`.
- [x] 3.2 In `tm_broadcast_screen.dart` create the scan controller in `initState`, pass it to the scaffold, start on broadcast / stop on `hasFailed` and `hasMatchedProvider`, dispose in `dispose`.
- [x] 3.3 Delete `_TMLivePulse`/`_PulseRing` and the `center: ... _TMLivePulse()` usage (the native center dot replaces it).
- [x] 3.4 Confirm the ripple loops at ~60 fps over the 30 s cycle on both the booking and TM maps without clipping when zooming or rotating.

## 4. Smooth progress + timer removal (both search screens)

- [x] 4.1 In `live_matching_screen.dart` remove the `bfSecondsRemaining(secondsRemaining)` countdown text from `_StatusBadge` and the `bfSearching` + count `Row` from `_SearchingSheet`; keep all internal `secondsRemaining` accounting, expiry sync, rung logic, and 3 s polling.
- [x] 4.2 Make `_GradientBar` smooth: wrap its `FractionallySizedBox.widthFactor` in a `TweenAnimationBuilder<double>` (~600 ms, easeOutCubic) gliding toward `progress` so no 1-second step jump is visible.
- [x] 4.3 In `tm_broadcast_screen.dart` remove the `'${controller.secondsRemaining}s'` text from `_TMBroadcastTopCard` (keep the radius chip, dispatch chip, and `tmTimedOut` label) and smooth the `LinearProgressIndicator` value with the same `TweenAnimationBuilder`.
- [x] 4.4 Optionally extract the shared smoothing into `lib/components/smooth_progress_bar.dart` used by both screens; verify no numeric countdown text remains on either screen (`flutter analyze` clean).

## 5. Map-less booking tracking page

- [x] 5.1 In `status_page.dart` remove the `GoogleMap` layer, `_mapController`, `_mapReady`, `_polylines`, `_scheduleBoundsUpdate`, map `markers`/`polylines` props, and the now-unused map imports/state; verify `dart:math` is still needed before removing it.
- [x] 5.2 Replace the map with a themed `LinearGradient` background (primaryBackground → secondaryBackground tokens) matching `BookingStatusScaffold`'s no-map branch.
- [x] 5.3 Restructure `build` from `Stack` into a map-free layout (floating back/home + provider card top section, `_TrackingSheet` timeline as the flexed main body, action row preserved); drop the fixed `_sheetHeightFactor` 45% anchor so content uses the full canvas.
- [x] 5.4 Keep `_pulseController`, `_startStatusPolling`, `_stageIndexForStatus`, and on-site location resolution working; verify stage advance (confirmed → en_route → on_site → in_progress → completed) renders via the timeline with zero map UI.
- [x] 5.5 Clean up now-unused l10n counter keys (`bfSecondsRemaining`) if `flutter gen-l10n` stays clean after our edits; otherwise leave them.

## 6. Verification

- [x] 6.1 Run `flutter analyze` — confirms 0 new errors (existing warning/info noise accepted).
- [x] 6.2 Run `flutter test test/booking_funnel_test.dart` (and any other targeted affected tests) — pass.
- [ ] 6.3 `flutter build apk --release` smoke build succeeds.
- [ ] 6.4 Manually verify on a phone: timer text gone on both search screens, smooth bar, native ripple loops 30 s / 3000 m stable across zoom+rotation, status page map-free, ripple and controllers cleaned up on back-navigation (no leaked tickers).
- [x] 6.5 Update `docs/ui-ux-reconstruction-plan.md` with the completed work items.