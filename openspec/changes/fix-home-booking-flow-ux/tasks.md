# Tasks — fix-home-booking-flow-ux

## 1. Home "Track Service" routes to booking details

- [x] 1.1 Replace `_openTrackingPage` in `lib/main/home/home_redesign_widget.dart` (lines 205-221) with a `context.pushNamed(BookingDetailsWidget.routeName, extra: {'bookingId': booking.bookingId})` push, mirroring `bookings_widget.dart:378-382`, so "Track Service" opens the booking details page with its Service Progress stepper instead of `StatusPage`.
- [x] 1.2 Remove the now-unused `status_page.dart` import from `home_redesign_widget.dart` and confirm `ActiveBookingCard.onTrackTap` still passes a non-empty `booking.bookingId`; remove dead code flagged by the analyzer without affecting the bookings-tab/confirmation/live-matching consumers of `StatusPage`.

## 2. Remove "Track on Map" from booking details

- [x] 2.1 Delete the primary `FilledButton.icon` ("Track on Map") from `_buildStickyFooter` (`booking_details_widget.dart:611-635`), keeping the Cancel Booking link; remove `_openMap` (lines 193-206), `_isTrackable` (lines 164-170), and the `status_page.dart` import if nothing else uses them.
- [x] 2.2 Remove the `bdTrackOnMap` key from `lib/l10n/app_localizations_en.arb`, `_es.arb`, `_fil.arb` (where present) and regenerate localizations with `flutter gen-l10n`; run `flutter analyze` to confirm no dangling getter references.

## 3. Recommended provider profile behaves like trending

- [x] 3.1 Confirm the API payloads: inspect the actual `ShphRecommendationsApi.nearby` response for whether the embedded `ShphServiceListing.provider` id is populated, versus `listListings` used by trending (`home_redesign_widget.dart:595-621`).
- [x] 3.2 Fix provider-id resolution in `_loadNearbyRecommendations` (lines 633-673): derive `providerId` only from `listing.provider`; drop the `'${listing.id}'` fallback and filter out items with no provider id; if the projection omits `provider` entirely, resolve the id from the listing detail endpoint before navigation or hide the card.
- [x] 3.3 Verify a tap on a "Recommended for you" card opens the same functioning `ProviderProfileWidget` as "View profile" in "Trending near you", with no dead taps or empty-profile states.

## 4. Emergency services modal picker for Get Help

- [x] 4.1 Create `EmergencyServicePanel` in `lib/pages/booking_funnel/widgets/` modeled on `service_selection_panel.dart`: fetch listings via `ServiceListingService.fetchServiceListings` (large `pageSize`), client-filter with `isEmergencyCategory(service.categoryName)`, emergency visual identity (red tinted header, siren glyph, emergency copy) using theme tokens, localized empty/error state with dismiss, and `Navigator.pop(service)` on selection.
- [x] 4.2 Refactor `_startBookingProcess` in `home_redesign_widget.dart` to accept a preselected `ServiceListing` so the picker only supplies the modal; rewire `_openEmergencyBooking` to open `EmergencyServicePanel` and reuse the existing right-now express checkout path (keeping `SeasonalOfferCard` behavior intact).
- [x] 4.3 Add emergency-modal strings to `lib/l10n/*.arb` (en/es/fil) and regenerate with `flutter gen-l10n`; verify no selected service leaves the flow without starting a booking.

## 5. Map bounded by the bottom sheet on the booking setup/checkout screen

- [x] 5.1 In `BookingStatusScaffold` (`booking_status_scaffold.dart:90-97`), change the non-draggable map layer from `Positioned.fill` to `Positioned(top: 0, left: 0, right: 0, bottom: sheetMaxHeight)` so the map ends at the top edge of the Services/Location/Payment sheet and never renders behind/below it.
- [x] 5.2 Remove/neutralize the GoogleMap `padding.bottom` (48 + `bottomInset`) that compensated for map-under-sheet in `_RadarMapLayer`, and verify on `ExpressCheckoutScreen` and `CheckoutScreen` that the selected-location pin stays centered in the visible map area.

## 6. Verification

- [x] 6.1 `flutter analyze` reports 0 errors (existing warning/info lints accepted).
- [x] 6.2 `flutter build apk --release` succeeds, and a QA pass confirms: home Track Service → booking details with progress; no Track on Map on details; recommended provider opens the working profile; Get Help lists only emergency services and starts an urgent booking; the setup/checkout map stops at the sheet's top edge.