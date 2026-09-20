# Design — fix-home-booking-flow-ux

## Context

See `proposal.md` — Why. Current state that shapes the approach:

- The map-free `StatusPage` tracker (`lib/pages/booking_funnel/status_page.dart`) is pushed imperatively from home (`_openTrackingPage`, `home_redesign_widget.dart:205-221`), from booking details (`_openMap`, `booking_details_widget.dart:193-206`), from the legacy `home_widget.dart:98`, and from live matching (`live_matching_screen.dart:1143`). The booking details page already renders a Service Progress stepper (`_buildProgressCard`, `booking_details_widget.dart:395-511`) with a near-identical stage model.
- "Track Service" on the bookings tab already routes to `BookingDetailsWidget` (`/booking-details`, router `app_router.dart:529-539`), so home can adopt the same entry.
- Both home provider sections push `ProviderProfileWidget` via `_openProvider(provider.providerId)`. Trending uses `listListings` results (real `listing.provider` ids); "Recommended for you" uses `ShphRecommendationsApi.nearby`, whose embedded listing projection may omit `provider`, so `_loadNearbyRecommendations` (`home_redesign_widget.dart:652`) falls back to `'${listing.id}'` — a listing id passed as `providerId`, which the provider profile cannot resolve.
- The home "Get Help" card calls `_openEmergencyBooking` → `showModalBottomSheet(ServiceSelectionPanel)` (unscoped all-services grid) then starts express checkout with `BookingUrgency.rightNow`. Emergency scoping already exists client-side: `coreEmergencyCategories` (`lib/utils/emergency_categories.dart`) + `isEmergencyCategory()`, reused by `ServicesScreen.emergencyMode`.
- The booking setup/checkout surfaces the map through `BookingStatusScaffold` (`lib/pages/booking_funnel/widgets/booking_status_scaffold.dart`): non-draggable mode places the sheet bottom-center with `ConstrainedBox(maxHeight = 0.64 * H)` while the map is `Positioned.fill` (lines 57-81), so the map renders behind/below the sheet. Express/checkout screens use this with the Services/Location/Payment progression sheet.

## Goals / Non-Goals

**Goals:**
- One tracking surface for active bookings: booking details (Service Progress); remove the home tracker entry and the booking-details "Track on Map" CTA.
- Recommended providers open the same working provider profile as trending providers.
- Get Help opens an emergency-only service picker; urgent booking flow unchanged.
- On the setup/checkout screen, the map visually ends at the top edge of the Services/Location/Payment sheet (no map hidden behind it).
- Keep the FlutterFlow page/`_model.dart` organization and theme-token rules; pass `flutter analyze` with 0 new errors.

**Non-Goals:**
- No server/API changes (no `is_emergency` field; no new endpoints).
- No change to the confirmation screen's "Track My Booking" destination (out of scope for this change).
- No redesign of `StatusPage` itself — it remains for the live-matching path unless scope is expanded.
- No change to `BookingFlowScreen`'s stacked top-card layout (a separate surface from the Services/Location/Payment sheet).

## Decisions

### D1 — Home "Track Service" reuses the bookings-tab route to booking details
Replace `_openTrackingPage` (imperative `StatusPage` push) with `context.pushNamed(BookingDetailsWidget.routeName, extra: {'bookingId': booking.bookingId})`, mirroring `bookings_widget.dart:378-382`. `booking.bookingId` already carries the real booking id (`_openTrackingPage` line 214). Booking details already shows Service Progress, so the tracker page is no longer reachable from home.
- Alternative: port the richer `StatusPage` timeline into booking details — rejected as larger churn; `BookingStepIndicator` already satisfies the spec.
- `home_widget.dart:98` also pushes `StatusPage`; leave it (legacy/analysis-only) unless dead-code cleanup is requested.

### D2 — Remove the "Track on Map" CTA from booking details
Delete the `FilledButton.icon` primary in `_buildStickyFooter` (`booking_details_widget.dart:611-635`) and the now-unused `_openMap` (`193-206`) and `StatusPage` import. `_isTrackable` is only used by that button — remove it too if the analyzer flags it as unused. Keep the Cancel Booking link in the footer. Drop `bdTrackOnMap` from the three ARB files (en/es/fil) and regenerate `flutter gen-l10n`; remove the getter only if nothing else references it.
- Alternative: repurpose the primary button into a "Contact provider" action — rejected, scope creep; `bdCancelBooking` alone is the required footer.

### D3 — Recommended providers navigate with a real provider id
Fix provider-id resolution at the source so the recommended card opens a valid `ProviderProfileWidget`:
- In `_loadNearbyRecommendations` (`home_redesign_widget.dart:651-653`), only map to `providerId` from `listing.provider?.toString()`; drop the `'${listing.id}'` fallback and filter out items with no provider id (no dead-profile taps).
- Confirm the actual `/api/recommendations/nearby/` and `/api/listings/` payloads during implementation; if the recommendations projection lacks `provider` entirely, resolve the provider id from the listing detail endpoint before navigation, or exclude listing-id-only cards.
- Alternative: point the recommended card at the product/service page when no provider id exists — rejected; the spec requires the same provider profile as trending, so no-provider-id items are simply not shown.

### D4 — Dedicated emergency services modal picker
Add `EmergencyServicePanel` (modeled on `ServiceSelectionPanel`) in `lib/pages/booking_funnel/widgets/`:
- Fetches listings via `ServiceListingService.fetchServiceListings(pageSize: large, ordering: '-rating')` and filters with `isEmergencyCategory(service.categoryName)` so only Electrical/Locksmith/Plumbing/Pest Control services render.
- Emergency visual identity (red/tinted header copy like "Need help right now?", siren glyph, no "Search all services" — the list is emergency-scoped), reusing theme tokens.
- Empty/error state with localized copy and a dismiss path (per spec).
- Selecting a service pops the panel with the listing and starts the existing `_startBookingProcess` body with `BookingUrgency.rightNow` (already implemented as `_openEmergencyBooking` shell). Refactor `_startBookingProcess` to accept a preselected service so the picker only supplies the modal; the flow-building code stays shared with SeasonalOffer category entry.
- Alternative: server-side emergency filter — rejected, no API flag; client filter is the established pattern (`ServicesScreen.emergencyMode`).

### D5 — Map ends at the top edge of the bottom sheet
In `BookingStatusScaffold`, non-draggable mode (`booking_status_scaffold.dart:90-97`), the map layer is currently `Positioned.fill`. Change it to a `Positioned(top: 0, left: 0, right: 0, bottom: sheetMaxHeight)` when the sheet is present, so the map widget occupies exactly the visible region above the sheet and never renders behind/below it. Because the sheet is capped at `sheetMaxHeight`, the map won't overlap even when content fills the sheet. Keep the top-card overlay; drop/neutralize the GoogleMap `padding.bottom` (48 + inset) that was compensating for map-under-sheet since that region no longer exists.
- This affects both consumers of the non-draggable layout (`ExpressCheckoutScreen`, `CheckoutScreen`), consistent with "booking flow page". The draggable variant stays as-is; add the same bound later if the map needs it.
- Alternative: keep full-bleed map and add camera padding so the pin renders above the sheet — rejected; the map would still be visually cropped underneath the sheet, which is the reported defect.

## Risks / Trade-offs

- [D1/D5 remove or repurpose `StatusPage` usage] → `StatusPage` is still referenced by live matching (`live_matching_screen.dart:1143`) and legacy `home_widget.dart`; keep both intact this change, so no compile/analyze breakage. Revisit full removal as a follow-up.
- [D3 depends on real `/api/recommendations/nearby/` payload shape] → Confirm during implementation; the design degrades to hiding listing-id-only cards so no dead profile is reachable, which satisfies the spec contract either way.
- [Emergency list may be empty for some areas] → Spec'd empty state is implemented in D4; the Get Help flow still needs an exit without booking.
- [Map bound uses sheetMaxHeight, not the sheet's actual (shorter) height] → There may be a small strip of background gradient between map bottom and a short sheet; acceptable and matches "map only until the bottom scaffold sheet", with no map hidden.
- [l10n regeneration] → After ARB edits, run `flutter gen-l10n`; standard for this repo (en + es + fil).

## Migration Plan

Pure client-side UI change: builds are byte-level swaps, no rollout coordination. Verify each piece via `flutter analyze` (0 new errors) and phone-test build; nothing to roll back beyond reverting the widget edits.

## Open Questions

- Should the confirmation screen's "Track My Booking" ("booking-lifecycle-ui" tracking entry) also route to booking details for consistency? Deferrable — does not change this change's specs or task shape; note it as a follow-up.
- Is the legacy `home_widget.dart` still mounted anywhere? If dead, its `StatusPage` reference becomes removable during the follow-up removal of the tracker page.