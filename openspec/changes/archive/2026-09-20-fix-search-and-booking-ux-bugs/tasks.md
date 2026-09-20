## 1. CTA text legibility

- [x] 1.1 In `lib/components/cupertino_ui/app_button.dart`, apply `fgColor` to the `DefaultTextStyle` in the button `content` (line 113) so child `Text` renders in the resolved foreground instead of the ambient text color.
- [x] 1.2 Add a `filledButtonTheme` in `lib/theme/app_theme.dart` `lightTheme()` (matching the existing `elevatedButtonTheme`) with `backgroundColor: data.primary` and `foregroundColor: data.onPrimary` so Material `FilledButton` "Book Now" on the product page renders white.
- [x] 1.3 Verify dark-mode: confirm the `AppButton` foreground and filled button remain legible under `AppThemeData.dark()`.

## 2. Location button crash

- [x] 2.1 In `lib/main/services/services_widget.dart` `_buildLocationPill` (lines ~287-288), pass the required `selectionType` in the `extra` map when pushing `GeographicSelectionWidget.routeName`, matching the `address_form_widget.dart` contract.
- [x] 2.2 Confirm the router cast at `app_router.dart:601` no longer throws `Null is not a subtype of GeographicSelectionType` when the services-listing location pill is tapped.

## 3. Estimate request contract

- [x] 3.1 In `lib/api/resources/bookings_api.dart` `estimateBooking` (line 64), change the payload key from `'listing'` to `'listing_id'` (keeping `scheduled_at`), matching `BookingEstimateRequest` in `SHPH API.yaml`.
- [x] 3.2 Verify a booking estimate no longer returns `400 {"detail":"listing_id is required."}` on first estimate and on retry.

## 4. Map crop / bottom-sheet gap

- [x] 4.1 In `lib/pages/booking_funnel/widgets/booking_status_scaffold.dart`, change the map from a height-capped `Positioned(top, height: mapHeight)` to a full-bleed `Positioned.fill` background behind the bottom sheet, keeping the sheet-sized camera `padding`.
- [x] 4.2 Verify there is no `primaryBackground` band between the map and the bottom sheet and that the sheet's draggable/anchored behavior and camera framing still work.

## 5. Search bar parity

- [x] 5.1 In `lib/pages/search_page/search_page_widget.dart` `_buildSearchBar` (lines ~428-481), match the home pill: height 48, radius `AppThemeData.radiusLg` (16), remove the hard `Border.all`, and use a soft shadow with a surface-fill color; keep the editable `TextField` behavior.

## 6. Verification

- [ ] 6.1 Run `flutter analyze` and confirm no new errors (the bar is 0 errors).
- [ ] 6.2 Build and install the debug APK on the emulator and spot-check the six fixes.