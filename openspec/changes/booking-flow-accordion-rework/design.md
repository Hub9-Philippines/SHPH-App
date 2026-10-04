## Context

See `proposal.md` — Why. The current `BookingFlowScreen` is a full-screen `GoogleMap` + `BookingMapSheetHost` with a two-stage bottom sheet (Location → Time), a "Step X of 4" label, and a `BookingStepSpine`, which then pushes `BookingSetupScreen` (Details) and `CheckoutScreen` (Review/submit). That map-era behavior was just recorded in the main specs via the archive of `live-matching-booking-flow-refinements`; this change supersedes it.

Relevant facts discovered while planning:

- Entry points (`services_widget.dart`, `tm_broadcast_screen`, live-matching retry) construct `BookingFlowScreen(selectedService: …)` and push it with `Navigator` + `buildBookingFlowRoute`; the constructor signature must stay.
- `BookingSetupScreen` and `CheckoutScreen` are directly pumped by `test/booking_setup_widget_test.dart` (3 tests) and `test/booking_funnel_test.dart` (5 tests) — deleting them breaks tests that encode real behaviors (landmarks field, arrival-code switch, estimate retry, submit branching still used by express checkout).
- `BookingPaymentWidget` reads a fixed extras map (`app_router.dart:500-518`) and `_resolveBookingDateTime()` (line 214) falls back to `00:00` when `bookingTime` is null — the handoff must always pass concrete date and time.
- `BookingFlowController.quote` falls back to `BookingQuote(basePrice: base, total: 0)` until a setter triggers `refreshQuote()` (lines 230/277/289/387) — entering the funnel without mutating the draft yields total 0.
- Light-mode label bug root cause: `AppTheme` text getters bake `color: primaryText` (near-black in light mode) into `theme.titleMedium` etc.; an explicit `Text.style.color` beats `AppButton`'s `DefaultTextStyle` foreground color.
- Ripple bug root cause: `_pinScreenOffset` in `LiveMatchingScreen` is only refreshed on `onMapCreated`/`onCameraIdle` and synchronously right after starting `animateCamera`; GoogleMap `padding` changes (sheet extent) may not fire `onCameraIdle`, leaving the rings at a stale position or at the padded-band fallback center.
- Constraints: `flutter analyze` at 0 errors; en+es l10n only (run `flutter gen-l10n` after arb edits); theme tokens only, no hardcoded hex; existing tests in `booking_funnel_test.dart`, `booking_setup_widget_test.dart`, `booking_controller_test.dart`, `booking_map_sheet_host_test.dart` must stay green.

## Goals / Non-Goals

**Goals:**
- One whole funnel page with a one-at-a-time accordion of Location/Time/Details/Review, no step numbers, no map in the stages.
- A validated, extras-correct handoff from Review to `/booking-payment`.
- Server estimate available (and gating Proceed) from the moment the funnel opens.
- Correct label contrast on every filled-background button in light and dark modes.
- Ripple center provably re-synced to the pin on every viewport change that can move the marker.

**Non-Goals:**
- Reworking express checkout, booking status tracking, or live matching navigation/behavior beyond the ripple fix.
- Removing maps from live matching, status, or express checkout surfaces.
- Changing the legacy `/booking` page (it remains the visual reference only).
- Deleting `BookingSetupScreen`/`CheckoutScreen` (they stay as thin, tested shells; removal is a follow-up).
- Backend/API changes, payment-method UX on the payment page, or l10n copy changes beyond reusing existing keys.

## Decisions

### 1. Single-page accordion with a persistent bottom action bar
- **Decision**: Rewrite `_CleaningBookingFlowView` as a `Scaffold` with a scrollable column of four stage cards. Exactly one stage is expanded; each header shows an icon, the stage name, a collapsed summary value, and a done check; headers are tappable when `stageIndex <= maxUnlocked`. One persistent bottom bar renders the estimate total plus a single button: `bfContinue` for stages 0–2, `bkProceed` on stage 3.
- **Alternatives considered**: *Stacked all-open like legacy `/booking`* — rejected: product explicitly chose accordion one-at-a-time. *Tab bar/stage switcher* — rejected: same product choice, and tabs don't convey prerequisites. *Per-stage buttons inside each card* — rejected: duplicates controls and puts the primary action far from the thumb zone.

### 2. Extract shared stage content; keep setup/checkout as thin shells
- **Decision**: Move the Details body from `booking_setup_screen.dart` into `widgets/details_stage_content.dart` and the Review summary out of `checkout_screen.dart`'s sheet into `widgets/review_stage_content.dart`; both screens compose the extracted widgets so their existing tests pass unchanged. Move `_AddressBanner` to `widgets/address_banner.dart` and give `TimeSelectionPanel` a `showNextButton` flag (default `true`) that the funnel sets to `false`.
- **Alternatives considered**: *Deleting the two screens and rewriting their tests* — rejected: higher diff/risk for zero user-visible gain, and their tests still encode contracts. *Duplicating the content in the new page* — rejected: two sources of truth drift immediately.

### 3. Payment handoff carries the full contract, always with concrete schedule values
- **Decision**: Proceed calls `context.pushNamed(BookingPaymentWidget.routeName, extra: …)` with exactly the keys the router reads: `serviceId/serviceName/category/imageUrl` from the draft's listing fields, `providerName/providerPhoto` from the `selectedService` (the draft has no provider fields), `notes` from landmarks, `price` as the formatted quote total (fallback: listing base price), and `bookingDate`/`bookingTime` resolved to concrete values (`scheduledDate ?? now`, `scheduledTime ?? now`) because `_resolveBookingDateTime` otherwise builds midnight.
- **Alternatives considered**: *Passing null date/time for immediate requests* — rejected: silently books at 00:00. *Pushing with `Navigator` + a hand-built page* — rejected: bypasses the registered route/extras contract; `context.pushNamed` is already used elsewhere in this screen (`PinLocationWidget`).

### 4. Accordion unlock rules mirror existing controller validation
- **Decision**: Stage 0→1 requires `hasValidAddress` (else `bkErrSelectAddress` snackbar); 1→2 requires `hasValidSchedule` (else `bfScheduleMandatoryError` snackbar — same gate the setup screen uses); 2→3 always unlocks; stage 3 requires a loaded server estimate (`serverQuote != null`, `isLoadingQuote == false`) before Proceed enables. The estimate is bootstrapped in `initState` via `unawaited(refreshQuote())` when no server quote exists. Keep `BookingFlowController.checkAndGuardActiveMatching` on entry.
- **Alternatives considered**: *Blocking stage 2 on estimate success* — rejected: the setup screen today lets users continue past estimate errors with retry available; Review is where the total matters, so gating there preserves both safety and flow.

### 5. Map and GPS removal is total for the funnel
- **Decision**: Delete `GoogleMap`, `BookingMapSheetHost`, `_reframeCamera`, `_loadLocation` (geolocator), `_editBookingPin`/`PinLocationWidget`, the `bfEditPin` button, `PopScope` location special-casing, `bfStepOfCount`, and `BookingStepSpine` from `booking_flow_screen.dart`. Coordinates come from `FFAppState` defaults and the `EditAddressWidget` result (the existing `_editBookingAddress` minus map state updates). `BookingMapSheetHost` itself stays — live matching and `booking_status_scaffold` still use it.
- **Alternatives considered**: *Keeping a small inset map for pin adjustment* — rejected: product said remove maps from the stages entirely.

### 6. Fix button contrast at call sites, not in the theme getters
- **Decision**: Give every filled-background button's label an explicit `color: theme.onPrimary` (or `Colors.white` for `AppButtonVariant.primary` defaults), sweeping the known offenders plus any found by audit; new page buttons are written with explicit colors.
- **Alternatives considered**: *Stripping `color` from the theme text getters* — rejected: they are correct for body/heading text; removing the baked color would change typography app-wide. *Making `AppButton` strip colors from descendants* — rejected: fragile widget-tree surgery; explicit call-site colors are greppable and testable.

### 7. Ripple re-sync on four event sources, throttled
- **Decision**: In `LiveMatchingScreen`, recompute `_pinScreenOffset` from `getScreenCoordinate(_rippleCenter())` on: (a) `onCameraIdle` and `onMapCreated` (existing), (b) a throttled `onCameraMove` (~100 ms), (c) `addPostFrameCallback` after any build where the GoogleMap `padding` changed, and (d) a short post-frame delay after `_fitCameraToRadius()` starts animating. Keep marker `anchor: Offset(0.5, 1)` so rings center on the pin tip = the location point.
- **Alternatives considered**: *Projecting on every frame* — rejected: saturates the platform channel, the exact reason the prior change moved to idle-only updates. *Deriving the offset analytically from camera + padding math* — rejected: duplicates Google Maps internals and drifts on projection changes.

### 8. Supersession of the archived map-era requirements
- **Decision**: This change's `booking-flow-redesign` delta MODIFIES the requirements just synced from `live-matching-booking-flow-refinements` (services entry point) and REMOVES the two map requirements it relied on, so archiving this change later converges the main specs to the mapless accordion state without conflicting open changes.

## Risks / Trade-offs

- **[Risk]** Immediate/urgent funnel bookings no longer reach live matching (they go through payment instead), changing on-demand UX for the services-listing entry point.
  - **Mitigation**: Product decision, recorded in the proposal (**BREAKING**) and in the rescoped submission spec; express checkout keeps the broadcast path, and booking status/tracking still surfaces provider acceptance.
- **[Risk]** Extracting Details/Review content could subtly change setup/checkout rendering and fail their tests.
  - **Mitigation**: Pure code moves; `booking_setup_widget_test.dart` and the checkout tests run unchanged as the acceptance gate.
- **[Risk]** Handoff extras mismatch (price format, date/time shape) breaks payment display or `scheduled_at`.
  - **Mitigation**: Mirror the legacy `/booking` extras shape exactly; add a test that captures the pushed route's extras; payment's own `_parsePrice`/`_resolveBookingDateTime` tolerances are documented above.
- **[Risk]** Ripple fix still depends on `getScreenCoordinate` fidelity per device.
  - **Mitigation**: Multi-event resync bounds the staleness window to one frame; padded-band fallback keeps the effect reasonable if projection fails.
- **[Risk]** Dead shells (`BookingSetupScreen`/`CheckoutScreen`) may confuse future contributors.
  - **Mitigation**: They remain intentionally tested; a follow-up change can delete them together with their tests once the accordion has soaked.

## Open Questions

- None blocking. Whether the `price` string uses `'PHP 1,234'` grouping vs plain decimals is a display detail resolvable during implementation by matching the value the payment page renders (it prints `widget.price` verbatim) — it does not change the spec or task breakdown.
