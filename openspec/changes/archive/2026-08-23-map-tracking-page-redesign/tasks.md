## 1. Primary color swap

- [x] 1.1 Change `primary` to `Color(0xFF1E3A8A)` in both `AppThemeData.light()` and `.dark()`; confirm `actionPrimary` alias still resolves identically
- [x] 1.2 Grep sweep for hardcoded `0xFF368EFF` literals across lib/ and migrate any stragglers to theme tokens; run analyze

## 2. Pull-to-refresh parity

- [x] 2.1 Explore: add `physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics())` to the feed ListView so the gesture matches Profile's feel
- [x] 2.2 Bookings: hoist a single RefreshIndicator around the Expanded state-switch (loading/error/empty/results all pull-able) with Profile physics on the results list; keep reload semantics via `_model.reloadBookings`

## 3. Tracking screen restructure (`status_page.dart`)

- [x] 3.1 Move GoogleMap to full-bleed `Positioned.fill` root Stack; delete the Column top-bar layout; map padding accounts for fixed sheet extent + safe area
- [x] 3.2 Add floating circular back button (44px, white, shadow, left chevron) top-left; tap = shouldPopToHome ? goHome : maybePop; preserve PopScope wrapper
- [x] 3.3 Add floating provider card top-center: avatar + name + status chip + Call/Message circular actions routing through ContactProviderWidget with inline fallbacks
- [x] 3.4 Replace DraggableScrollableSheet with fixed bottom card at 45% viewport height, 24px top radius, internal scroll; remove extent plumbing (`_collapsedSheetExtent`/`_expandedSheetExtent`/`_dynamicMaxSheetExtent`/`_handleSheetNotification`)
- [x] 3.5 Stepper cleanup: remove trailing completed check-circle glyph in `_StageRow`; single green track checkmark per completed stage remains
- [x] 3.6 Convert booking-date detail box into compact horizontal badge (calendar glyph + label + value); Reference renders as its own badge only when present
- [x] 3.7 Completed-state actions: full-width deep-emerald "Write a Review" FilledButton routing to WriteReviewWidget when reference exists (inline feedback otherwise), plus "View Invoice" text link beneath with graceful fallback; hidden for non-completed states

## 4. Call-site threading

- [x] 4.1 Bookings list `_openMap`: pass `bookingReference: booking.id` (list routes Track/View through BookingDetails, whose `_openMap` carries the id into StatusPage)
- [x] 4.2 Booking details `_openMap`: pass `bookingReference: _model.booking!.id`
- [x] 4.3 Home shortcut + live-matching StatusPage entries: pass whatever id they hold (mock ids acceptable — review button falls back)

## 5. Verification

- [ ] 5.1 Visual pass: map fills screen behind overlays; back button/provider card legible over tiles; sheet pinned at 45% with 24px corners; stepper shows exactly one checkmark per completed stage
- [ ] 5.2 Completed flow: Write a Review opens pre-bound composition; View Invoice degrades gracefully; active-state bookings show no completion actions
- [ ] 5.3 PTR parity hands-on: pull feels identical across Profile/Explore/Bookings incl. loading/error states of Bookings
- [x] 5.4 Color sweep: no #368EFF remnants; spot-check primary-driven surfaces (nav tint, buttons, links, indicators) in light + dark
- [x] 5.5 `flutter analyze` — 0 errors; `flutter test test/booking_funnel_test.dart` — no new failures
