## Context

Six user-facing defects were found on the search page, services listing page, and booking flow. Three are single-root-cause fixes shared across surfaces; the rest are localized. See `proposal.md` — Why for the motivation. Key constraints: the bar is `flutter analyze` at 0 errors; theme tokens must be used (no hardcoded hex) for dark-mode correctness; `AppButton` (`lib/components/cupertino_ui/app_button.dart`) and the app theme (`lib/theme/app_theme.dart`) are the two shared surfaces most fixes funnel through.

## Goals / Non-Goals

**Goals:**
- Make the search page search bar visually match the redesigned home pill.
- Stop the services-listing location button from crashing and open the selection surface.
- Make CTA text legible everywhere (Book Now, empty-state buttons) in both light and dark mode.
- Make service-listings clean and ensure the estimate request always satisfies the server.
- Remove the map crop / gap between map and bottom sheet on booking status.
- Fix the invisible empty-state action button.

**Non-Goals:**
- No backend/`SHPH API.yaml` changes; the fix is purely in the Dart API client.
- No redesign of the booking flow; only the reported defects.
- No changes to the technician (tm_) flow or provider dashboard unless a shared component is touched.

## Decisions

### 1. CTA legibility — fix `AppButton` to apply its resolved foreground color (bugs 3 & 6)
`AppButton._resolveColors` computes `fg`/`fgColor` but never applies it to the label: the `content` `DefaultTextStyle` at `app_button.dart:113` sets only `fontSize`/`fontWeight`, so child `Text` inherits the ambient color instead of `fgColor`. On a filled primary button the label should be white; on an outlined button it should be `primaryText` — but today it uses the ambient text color, causing dark-on-blue (Book Now on listing page) and invisible outlined text (empty state).

Fix: set `color: fgColor` on that `DefaultTextStyle`. This one change repairs both the listing-page "Book Now" (if it used `AppButton`) and the search empty-state primary + outlined buttons. Alternative considered: hardcoding `Colors.white` in each call site — rejected because it wouldn't fix `AppButtonVariant.outlined`/`text` and would leak raw colors.

### 2. "Book Now" on the product page — add `filledButtonTheme` in the theme (bug 3)
The product page `product_page_widget.dart:663` uses Material `FilledButton.icon`, not `AppButton`. The theme (`app_theme.dart`) only configures `elevatedButtonTheme`; there is no `filledButtonTheme`, so `FilledButton` falls back to Material defaults whose `onPrimary` foreground isn't the intended white. Fix: add a `filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(backgroundColor: data.primary, foregroundColor: data.onPrimary))` in `lightTheme()` (and match in the dark theme path), mirroring the existing `elevatedButtonTheme`. This is theme-centralized and dark-mode safe.

### 3. Location button crash — pass `selectionType` from the services listing page (bug 2)
`app_router.dart:601` casts `extra?['selectionType'] as GeographicSelectionType` unconditionally. The services listing page `services_widget.dart:287-288` pushes `GeographicSelectionWidget.routeName` without supplying `selectionType`, so the cast throws `Null is not a subtype of GeographicSelectionType`. `address_form_widget.dart` already passes `selectionType` correctly. Fix: pass the appropriate `GeographicSelectionType` in the `extra` map when pushing from `services_widget.dart` (matching how `address_form_widget.dart` passes it). Alternative: make the router default the cast to `null` and have the screen handle it — rejected because the surface requires a type and the address-form precedent confirms the intended contract is to pass it.

### 4. Estimate 400 — correct the API body key (bug 4)
`bookings_api.dart:64` sends `'listing': listingId`, but the deployed serializer (`SHPH API.yaml:17337`) requires `'listing_id'` — hence `400 {"detail":"listing_id is required."}` on first estimate and on retry (which reuses `refreshQuote`). The listing id is non-null by the time `estimateBooking` is reached (the repository throws `StateError` otherwise), so this is purely a key-name mismatch. Fix: change the payload map to `{'listing_id': listingId, if-needed 'scheduled_at': ...}`. `scheduled_at` is optional per the schema; keep sending it. `FavoritesApi` already uses `'listing_id'` (line 16) as the correct precedent. Alternative: switch to favoriting's pattern — this is exactly that pattern, just at the bookings endpoint.

### 5. Map crop / gap — anchor the bottom sheet over the map in `BookingStatusScaffold` (bug 5)
`BookingStatusScaffold` renders the map in a `Positioned(top: 0, height: mapHeight)` where `mapHeight = height * mapVisibleFraction` (default 0.42, `booking_status_scaffold.dart:51-52`), and the bottom sheet is an `Align(bottomCenter)` Stack child. Because the map is height-capped and the sheet sits at the screen bottom, a `primaryBackground` band shows between the map's bottom edge and the sheet's top when the sheet's height doesn't exactly fill the remainder — the reported "map cropped / big space between bottom sheet and map".

Fix: make the map **full-bleed** (`Positioned.fill`) behind the sheet and keep the bottom sheet as an anchored overlay (the map already has the sheet-sized camera `padding`). This removes the gap and the crop. This aligns with the intended "full-bleed map" language already present in `map-tracking-screen` spec.

### 6. Search bar parity — restyle `_buildSearchBar` (bug 1)
`search_page_widget.dart:428-481` `_buildSearchBar` uses `height: 58`, `borderRadius: 24`, and `Border.all(color: theme.border)`, contrasting with the home pill (`prototype_components.dart:314-376` `_SearchTriggerBar`: height 40/48, `radiusMd` (16), `AppDesignTokens.surface` fill, shadow-only). Fix: change the search bar's height to 48, radius to `AppThemeData.radiusMd` (16), drop the hard border, and use a soft shadow + `theme.secondaryBackground`/surface fill. It must remain a real editable `TextField`.

## Risks / Trade-offs

- **Foreground color change in `AppButton` affects every button in the app** → The `DefaultTextStyle` color comes from the already-correct `fgColor`, so dark/light and all variants resolve correctly; run `flutter analyze` and spot-check a filled + outlined + text button.
- **Adding `filledButtonTheme` changes styling of `FilledButton` usages elsewhere (status_page, live_matching)** → Intentional consistency win; verify no other `FilledButton` currently relied on an explicit per-call foreground that the theme would override (they set their own `foregroundColor` inline and take precedence).
- **Map full-bleed change may shift camera framing** → The map already uses a sheet-sized `padding`; confirm the sheet's `maxHeight`/draggable fractions still align and the fixed 48+inset padding reads well.
- **Estimate body key change requires the server to accept the corrected field** → Verified against `SHPH API.yaml` `BookingEstimateRequest` (`listing_id` required, integer); the current `listing` key was wrong, so this is strictly a fix.

## Migration Plan

Pure client-side fixes; no data migration or backend deploy. Rollback is a revert of `app_button.dart`, `app_theme.dart`, `bookings_api.dart`, `services_widget.dart`, `search_page_widget.dart`, and `booking_status_scaffold.dart` changes. Ship with the next debug APK for on-device verification.

## Open Questions

None — all six root causes are confirmed against the source and the OpenAPI spec.