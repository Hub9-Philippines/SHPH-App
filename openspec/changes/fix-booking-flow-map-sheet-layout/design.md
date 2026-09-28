## Context

See proposal.md — Why. This is the technical shape of the fix and the constraints it must respect.

Three booking screens currently paint a map plus a bottom sheet, each with its own hardcoded approximation of the sheet's height:

| Screen | Current map geometry | Problem |
|---|---|---|
| `BookingFlowScreen` | `GoogleMap` already `Positioned.fill`; camera padding uses `final sheetOverlap = 300.0` | Full-bleed is already correct, but the camera framing uses a constant. `LocationConfirmationPanel` and `TimeSelectionPanel` have different real heights, so the pin drifts out of the visible band on at least one step. |
| `BookingStatusScaffold` (non-draggable) | `Positioned(top:0, left:0, right:0, bottom: sheetMaxHeight)` | `sheetMaxHeight = constraints.maxHeight * 0.64` is a *budget*, not the sheet's real height. When the sheet is shorter, the map's bottom edge sits above the sheet's top edge and a band of `theme.primaryBackground` shows through. This is the reported white gap. |
| `BookingStatusScaffold` (draggable) | `padding: EdgeInsets.only(bottom: 48 + bottomInset)` | Another magic offset, and unlike `LiveMatchingScreen` it never tracks the live drag extent. |
| `LiveMatchingScreen` | `Positioned.fill` + `mapPadding` derived from `_dynamicMaxSheetExtent(...)` driven by measured `_sheetContentHeight` and `DraggableScrollableNotification` | Already implements the target behavior. It is the reference, but it is private to that screen's `State`. |

`BookingStatusScaffold` is the shared host behind `checkout_screen.dart` and `express_checkout_screen.dart`, so fixing it fixes both.

Constraints carried from existing specs that this change must not break:

- `native-radar-scan` — the ripple must not cause full-map rebuilds per tick, and must stay pinned under zoom/rotation.
- `map-scan-radius-effect` — active searches re-frame to fit the current scan radius (4 km → 24 km) inside the visible map region.
- `map-less-booking-tracking` — the `showMap: false` path must build no map at all.
- `booking-flow-redesign` — estimate authority, draft preservation, and submission behavior are untouched; this change is layout-only.
- Project rules: use `AppTheme.of(context)` tokens (never hardcoded hex/`Colors.*` for surfaces), and keep `flutter analyze` at 0 errors.

## Goals / Non-Goals

**Goals:**
- One reusable widget that owns "full-bleed map + bottom sheet + sheet-derived camera padding" so the three screens share a single implementation.
- Replace every hardcoded sheet-height constant in the booking funnel with a measured value.
- Keep the ripple/radar layers' per-tick isolation intact when they move into the shared host.
- Make the layout correct across viewports, locales, and text scales without per-screen tuning.

**Non-Goals:**
- Not redesigning the step panels' visual style, corner radii, or the grab-handle treatment.
- Not changing the map's default zoom, marker glyphs, marker hue, or which markers appear on which screen.
- Not changing `BookingFlowController`, any API contract, routing, or the backend.
- Not introducing a draggable sheet to `BookingFlowScreen` — its steps are intentionally fixed-height panels.
- Not touching `booking_status_scaffold.dart`'s `center`, `topCard`, or gradient-layer ordering beyond what the geometry change requires.

## Decisions

### 1. Extract the proven pattern rather than inventing a new one

`LiveMatchingScreen` already solves this correctly with three pieces: capture the sheet's natural content height, convert it to an extent fraction clamped to `[collapsed, expanded]`, and derive `mapPadding` from the *current live* extent.

**Decision:** Promote that logic into a shared host widget in `lib/pages/booking_funnel/widgets/`, parameterized by the map child and the sheet child, and have all three screens delegate to it.

**Alternatives considered:**
- *A shared pure function/utility for padding math, each screen keeping its own layout.* Rejected: it would not have removed `bottom: sheetMaxHeight` from the scaffold, so the actual white-gap bug could regress independently of the padding math. The bug is in the layout tree, not just the arithmetic.
- *Replace the panels with a single `DraggableScrollableSheet` everywhere.* Rejected: it changes the interaction model of the setup steps and the express checkout, which is a much larger behavioral change than the reported visual defect.

### 2. The map is always `Positioned.fill`; the sheet occludes it

**Decision:** Every screen using the shared host paints the map as a `Positioned.fill` child of a `Stack`, with the sheet layered on top. Full-bleed coverage becomes structural — there is no code path that can bound the map's bottom edge, so the white-gap class of bug becomes unrepresentable.

The camera padding is the only thing that varies per screen, and it is always derived from the sheet's extent. This matches what `map-tracking-screen` already mandates for the tracking screen.

### 3. Measure the sheet, don't guess it

For the fixed-height setup panels, the host needs the panel's real height. Two viable mechanisms:

- **Chosen:** have the host render the sheet child inside a `NotificationListener`/`MeasureSize`-style capture (the same `onHeightChanged` callback shape `_handleSheetContentHeightChanged` already uses) so the host learns the height regardless of which panel is swapped in. This keeps the panels themselves unchanged and works for any future step panel.
- **Rejected: `GlobalKey` + `RenderBox.size` read in the host's `build`.** Reading a `RenderBox` during build is fragile — the value is stale on the first frame and throws if the child has not been laid out. It also forces the host to reach into its child's internals.

For the initial frame before a measurement lands, the host uses a conservative padding fallback derived from the viewport (not a magic pixel count), then re-frames once the real height arrives. A one-frame camera shift is acceptable; a visible error or layout break is not.

### 4. Keep the extent fractions, drop the pixel offsets

`sheetMaxFraction` (default `0.64`) is meaningful — it is the "how tall may this sheet ever get" budget and it also caps content that overflows the viewport. It is `bottom: sheetMaxHeight` used as a *layout* bound that is wrong, plus the `48 + bottomInset` pixel offset, that get removed.

**Decision:** retain the min/initial/max fraction API for extent clamping and overflow capping, but the map always fills and only the padding is derived from the extent. `bottomInset` continues to come from `MediaQuery.padding.bottom` for gesture/nav-bar clearance, and `SafeArea` continues to guard the sheet's bottom padding — those are correct and stay.

### 5. Preserve ripple isolation across the host boundary

`native-radar-scan` requires that per-tick ripple updates rebuild only the circle data. Today `_RadarMapLayer` achieves this by taking a `RadarScanController?` and rebuilding itself from a `ValueListenableBuilder` on the circles.

**Decision:** the shared host must accept the already-built map child and must not re-wrap it in a `Consumer`/`AnimatedBuilder` that would rebuild it on every sheet-height change or every ripple tick. The sheet height flows *down* into padding computation, and the map child is passed through as a stable widget subtree.

**Risk mitigation:** the sheet-height state changes only on step change or drag, not per animation frame, so even a rebuild would be bounded — but the pass-through keeps the existing per-tick guarantee intact rather than relying on that.

## Risks / Trade-offs

- **First-frame camera jump** — before the sheet measures itself, the camera uses a fallback padding, then re-frames once measured → Mitigate with the viewport-derived fallback; the shift is a single small pan, and a golden test asserts the final padding matches the measured height.
- **Ripple/radar regressions from the move into the host** — the `ValueListenableBuilder` isolation is easy to break when re-wrapping the map → Mitigate by passing the map child through unmodified and keeping `_RadarMapLayer` intact; verify with the radar specs' scenarios.
- **`map-less-booking-tracking` regression** — a shared host could tempt constructing a map on the map-free path → Mitigate by keeping `showMap: false` short-circuiting before any map widget is built, and leaving the map-free screen outside the host entirely.
- **Inverted spec requirement** — `booking-flow-redesign` previously forbade rendering behind the sheet, so the delta removes and replaces it → Mitigate with an explicit `REMOVED` entry carrying Reason/Migration so the archive is auditable; already validated with `openspec validate --strict`.
- **Text scale / locale blowout** — a long address or large text scale can make a panel taller than the viewport → Mitigate by clamping the extent to the permitted maximum and letting sheet content scroll; verified at 1.0 and 2.0 text scale in both `en` and `fil`.
- **Reduced available height (keyboard open)** — `MediaQuery.viewInsets` shrinks the usable viewport during address/time entry → Mitigate by deriving padding from the same constraints the layout uses so the two stay consistent; check the address-edit and date-picker modals.

## Migration Plan

Layout-only, no persistence and no API surface, so there is nothing to migrate. Rollback is a single revert of the three screen files plus the new host widget; the removed requirement stays removed in `openspec/specs/` only once this change is archived, so a rollback should also revert the spec delta in the same commit.

Verification before archiving: `flutter analyze` at 0 errors, the booking/call test subset green, and a manual pass over the setup steps, checkout, express checkout, and live matching on at least one small phone and one tall device, in both locales.

## Open Questions

None that affect the specs, the approach, or the task breakdown. The remaining unknowns are visual-tuning values (exact fallback padding fraction, whether the top card's camera inset should also become measured) that can be adjusted during implementation without changing any requirement.
