## Context

- `StatusPage` (965 lines) currently stacks `_StatusTopBar` above the map in a Column, then a `Stack` with map + `DraggableScrollableSheet` (0.30–0.55 extent, radius 28). The sheet's stepper rows render a green track-line checkmark AND a trailing `check_circle` glyph for completed stages. Booking date sits in a boxed two-row detail container. Callers: bookings list (`_openMap`, no reference passed), booking details (same), home shortcut, live-matching flow (`shouldPopToHome: true`). `bookingReference` param exists but is rarely supplied.
- Refresh today: Profile = `RefreshIndicator(theme.primary)` + `CustomScrollView(BouncingScrollPhysics + AlwaysScrollableScrollPhysics)`; Explore = `RefreshablePage.wrapWithRefresh` (bare indicator, ListView default physics); Bookings = indicator only on the populated/skeleton results list, not error state.
- Theme: `primary = #368EFF` in both factories; `actionPrimary`/`accentNavy` already equal #1E3A8A; `successTeal #0D808A` is the established deep emerald. Invoice has no Flutter surface (web-only endpoint `/services/bookings/{id}/invoice/`). WriteReviewWidget requires a `bookingId` path parameter.

## Goals / Non-Goals

**Goals:**
- Full-bleed map with three floating layers: back button, provider card, fixed bottom sheet.
- Stepper de-duplication and completed-state actions on the tracking screen.
- One pull-to-refresh feel across Profile/Explore/Bookings.
- Single royal-blue primary app-wide.

**Non-Goals:**
- Real-time location infrastructure changes (mock progression stays as-is).
- Building an invoice viewer (link ships with graceful fallback, mirroring the Add-to-Calendar precedent).
- Touching provider-side screens or the funnel's live-matching internals beyond call-site threading.
- Re-theming non-primary accent tokens.

## Decisions

1. **Layout restructure to a single Stack**: body becomes `Stack[Positioned.fill(GoogleMap), overlays]`. Back button = `SafeArea`+`Positioned(top:16,left:16)` circular 44px white surface with `shadowSoft`; tap resolves via `shouldPopToHome ? _goHome : Navigator.maybePop`, keeping the existing `PopScope` wrapper. Alternative (appbar-style translucent bar) rejected — brief demands floating circle over map.
2. **Provider card**: positioned top-center (`Positioned(top: safeTop+16, left/right: 16)` constrained maxWidth ~420). Contents: avatar (existing `UserAvatar`), name + status chip row, subtitle line, and two 40px circular instant-action buttons reusing the `_FloatingCircleButton` visual from booking_details (Call → tel via ContactProviderWidget route with name/photo extras; Message → same contact flow). Fallback snackbar when no number/thread — matches existing contact utilities' behavior.
3. **Sheet as fixed fraction**: replace `DraggableScrollableSheet` + notification listener + dynamic-extent plumbing with `Align(bottomCenter)` + `FractionallySizedBox(heightFactor: .45)` white container, vertical-top radius 24 (`AppThemeData.radiusLg` is 16 — use explicit `Radius.circular(24)` token comment or add `radiusSheet`? Use literal 24 documented against grid constants since no 24-radius token exists), inner `SingleChildScrollView`. Map padding bottom = `0.45 * height + bottomInset`. Dead code removed: `_collapsedSheetExtent/_expandedSheetExtent/_dynamicMaxSheetExtent/_handleSheetNotification/_bottomSheetExtent`.
4. **Stepper**: delete the trailing `check_circle` icon block in `_StageRow`; completed rows keep only the 22px green track checkmark. Everything else (pulse, ETA chip, muted pending dots) unchanged.
5. **Date badge**: replace detail box with one horizontal pill: `Container(radiusPill, surfaceAlt bg)` containing calendar icon, "Booking date" label, value; Reference moves into its own identical badge beside/below only when present.
6. **Completed actions**: `FilledButton` full-width, `AppThemeData.successTeal` background, label "Write a Review", `onPressed` routes `WriteReviewWidget(bookingId: widget.bookingReference!)` when reference present, else disabled-with-snackbar fallback; beneath it a centered `TextButton` "View Invoice" that attempts launch of the invoice surface and otherwise shows inline feedback (documented non-goal keeps this dependency-free). Actions visible ONLY when `_isTerminal && status == completed`.
7. **Reference threading**: callers pass `bookingReference: <real id>` where known — bookings list passes `booking.id`, booking details passes its loaded id; home/live-matching pass what they hold (mock ids acceptable — fallback covers them).
8. **PTR parity**: canonical definition = Profile's exact composition. Explore: add `physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics())` to feed ListView (mixin stays, still supplies indicator). Bookings: hoist a single `RefreshIndicator(onRefresh: reloadBookings)` around the Expanded state-switch so loading/error/empty/results all support pull; results list gains Profile physics pair. Profile untouched as the reference implementation.
9. **Primary swap**: change `primary` in both light/dark factories to `Color(0xFF1E3A8A)`; `actionPrimary` alias now equals primary by value (kept for semantic naming). Sweep for hardcoded `0xFF368EFF` literals outside theme (none expected — grep task verifies).

## Risks / Trade-offs

- [Royal navy lowers vibrancy on small tints] → 12%-alpha tints darken slightly but stay legible; contrast improves on white.
- [Fixed 45% sheet loses drag affordance some users liked] → Brief mandates non-collapsible; inner scrolling preserves access to all content.
- [Write a Review without a real id (home mock shortcuts)] → Disabled-state + inline feedback prevents dead navigation until real ids flow through.
- [Primary swap touches every screen implicitly] → Single-token change; grep sweep plus analyze catch stray old-hex literals; visual QA task included.

## Migration Plan

Three slices: theme color first (isolated, instantly verifiable), PTR parity second, tracking redesign third (largest). Each ends analyze-green; rollback per slice.

## Open Questions

None blocking. Invoice surface remains a documented graceful-fallback until product prioritizes an invoice viewer.
