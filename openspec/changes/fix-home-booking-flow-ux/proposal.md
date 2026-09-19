# Proposal: fix-home-booking-flow-ux

## Why

QA on the redesigned home and booking flow surfaced four UX defects: the home "Track Service" opens a separate map-free tracker page (`StatusPage`) that duplicates the Service Progress already shown on the booking details page, and the booking details page still offers a redundant "Track on Map" button into that same tracker; selecting a provider in "Recommended for you" does not behave like "View profile" in "Trending near you"; the home "Get Help" card opens the generic all-services picker instead of an emergency-scoped picker; and the map on the booking setup/checkout screen extends behind/below the bottom sheet, hiding its lower area.

## What Changes

- Home "Track Service" on an active booking card SHALL open the booking details page (which renders the Service Progress stepper) instead of the standalone service tracker page.
- The "Track on Map" primary button on the booking details page SHALL be removed; the standalone service tracker (`StatusPage`) is no longer reachable from home track service or booking details.
- Selecting a provider in "Recommended for you" on the home page SHALL open the full provider profile exactly like "View profile" in "Trending near you".
- The home "Get Help" card SHALL open a dedicated emergency services modal picker that lists only services from the emergency categories (Electrical, Locksmith, Plumbing, Pest Control), replacing the current generic `ServiceSelectionPanel` bottom sheet.
- The map on the booking setup/checkout screen (the bottom sheet with Services / Location / Payment) SHALL extend only down to the top edge of the bottom sheet and SHALL NOT render behind/below it.

## Capabilities

### New Capabilities
- `emergency-services-picker`: The dedicated emergency services modal presented by the home "Get Help" card, listing only services flagged as emergency and starting the booking flow with right-now urgency.

### Modified Capabilities
- `booking-lifecycle-ui`: Home "Track Service" routes to booking details instead of the standalone tracking page, and the booking details screen no longer offers a "Track on Map" action.
- `home-screen-experience`: The "Get Help" card opens the emergency services modal, and a provider chosen from "Recommended for you" opens the same functional provider profile as "Trending near you".
- `booking-flow-redesign`: On the booking setup/checkout screen the map is bounded by the top edge of the bottom sheet and does not extend behind/below it.

## Impact

- `lib/main/home/home_redesign_widget.dart` — `_openTrackingPage` (Track Service), `_openEmergencyBooking` (Get Help modal), `_RecommendedProviderCard` (recommended provider navigation). `lib/main/home/home_widget.dart:98` also references `StatusPage` and must be reconciled.
- `lib/pages/booking_details/booking_details_widget.dart:193-206, 597-657` — remove `_openMap` and the "Track on Map" CTA (l10n key `bdTrackOnMap`).
- `lib/pages/booking_funnel/status_page.dart` — still referenced by `live_matching_screen.dart:1143` `_openStatusPage`; decide keep-with-no-new-entry-points vs. full removal and re-route live matching.
- `lib/pages/booking_funnel/widgets/booking_status_scaffold.dart` + `express_checkout_sheet.dart` (+ `express_checkout_screen.dart`) — map bounds relative to the Services/Location/Payment bottom sheet.
- `lib/pages/booking_funnel/widgets/service_selection_panel.dart` — replaced by the emergency picker for the Get Help path.
- `lib/utils/emergency_categories.dart` — source of the emergency service list for the new picker.
- `lib/components/prototype_components.dart` — `ActiveBookingCard`/`EmergencyHelpCard` surfaces.
- l10n: drop/repurpose `bdTrackOnMap` (en/es/fil) and add emergency-picker strings.