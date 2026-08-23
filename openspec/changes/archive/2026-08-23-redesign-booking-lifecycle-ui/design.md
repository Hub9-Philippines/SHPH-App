## Context

Current surfaces:

- **List** (`lib/main/bookings/bookings_widget.dart`, 574 lines): hardcoded `0xFFF4F7FB` scaffold, `custom_widgets.CupertinoSlidingWidgetBookings` two-segment control driving a `PageView` (Active/Finished), inline card builder using `AppThemeData.statusColors()`; no search. `lib/components/booking_card.dart` exists separately.
- **Tracking** (`lib/pages/booking_details/booking_details_widget.dart`, 613 lines): loads via `BookingsService.getBookingById`, has status formatting and cancel dialog, but progress/timeline presentation is ad hoc; `lib/components/booking_step_indicator.dart` exists as a prior stepper.
- **Success**: funnel screen `lib/pages/booking_funnel/booking_success_screen.dart` (post-funnel) vs legacy route `lib/pages/booking_success/booking_success_widget.dart`; payment screen navigates to `/booking-success`.
- Theme already carries: `accentNavy == 0xFF1E3A8A` (exactly the brief's royal blue), `accentYellow == 0xFFF59E0B` (the amber), `error = DC2626` (darker than the brief's soft red), brand teal `0xFF0D808A` inside `profileHeroGradient.first`. AGENTS.md forbids hex in screens; dark mode must keep working.

## Goals / Non-Goals

**Goals:**
- One state-aware action grammar across list cards and detail footers.
- Palette expressed only through new/existing theme statics.
- Single success surface after checkout.

**Non-Goals:**
- Provider-side booking screens.
- Real-time provider location infrastructure ("Track on Map" routes to existing map/live views; no new tracking backend).
- Add-to-calendar backend integration (device calendar intent is enough).
- Changing booking data contracts (owned by `fix-booking-create-scheduled-at`).

## Decisions

1. **Chips replace the sliding segment control.** The Cupertino custom widget encodes a binary Active/Finished model that cannot express All/Pending/Completed/Canceled. Filter state lives in `BookingsModel` (`selectedFilter` + `searchQuery`), applied client-side over already-loaded bookings; server-side search is a non-goal this iteration.
2. **Royal blue = existing `accentNavy` token, aliased.** Values are identical; add `static const actionPrimary = accentNavy` for semantic call sites rather than renaming across the app. New statics needed: `successTeal = Color(0xFF0D808A)` and `destructiveSoft = Color(0xFFEF4444)` (kept distinct from `error`, which stays for form/validation errors). Amber reuses `accentYellow`.
3. **One shared `BookingActionRow` widget** in `lib/components/` renders the per-status button/link grammar so cards, detail footer, and success screen stay consistent by construction — same pattern that made the profile/settings tiles uniform.
4. **Timeline stepper rebuilt from `booking_step_indicator.dart`** rather than reused as-is: needs timestamps per completed step and the glowing teal treatment (BoxShadow pulse), which the current indicator doesn't support. Step source: map server status enum → fixed step list (Pending → Confirmed/Assigned → Arrived → In Progress → Completed), timestamps from response fields (`arrived_at`, `started_at`, `created_at`) mapped in the bugfix change's fromJson work.
5. **Success consolidation:** point both entry paths (payment screen `/booking-success`, funnel completion) at `booking_success_screen.dart`; delete the legacy `pages/booking_success/` widgets and their router entries. Receipt reads the created booking via controller/draft state with graceful fallbacks (quoted total) when server fields are still null.
6. **Add to Calendar:** use device calendar intent via platform channel-free approach (`add_2_calendar`-style plugin is NOT added; instead generate an .ics-style intent through existing share/url-launch utilities if available). If no dependency-free path exists, fall back to a "Saved" snackbar + follow-up note — do not block the redesign on a new dependency.
7. **Track on Map routing:** active bookings open the existing live-tracking/map view (`live_matching_screen.dart` map mode or `provider_map_view.dart` host) with the booking id; completed/canceled bookings disable the button.
8. **Bottom nav untouched** except verifying Bookings highlight; pushed screens use full-screen routes without the shell bar where the current router already behaves that way.

## Risks / Trade-offs

- [Client-side filtering misses pagination edges] → Acceptable at current volume; spec scopes filter to loaded set. Revisit server query params if lists exceed ~50 rows.
- [Stepper mapping may not cover every status enum value] → Unknown statuses fall back to Pending-pattern rendering; add a mapping test task.
- [Legacy success-route deletion could break deep links] → Keep the legacy route name registered but redirecting to the funnel screen before removing in a later cleanup pass.
- [Calendar without new deps may be limited on Android intents] → Decision 6 fallback keeps scope honest; product can approve a plugin later.

## Migration Plan

Three independently landable slices in order: palette + shared action row → list screen → tracking/success. Each slice ends analyze-green. Rollback per-slice.

## Open Questions

- Does "Reschedule" reuse the existing reschedule endpoint flow or reopen the funnel date picker? (Lean: funnel picker writing through the reschedule endpoint; confirm during apply.)
