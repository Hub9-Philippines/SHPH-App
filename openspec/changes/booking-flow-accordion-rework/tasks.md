## 1. Shared Stage Content Extraction
- [x] 1.1 Extract the Details stage body and its private helpers from `lib/pages/booking_funnel/setup/booking_setup_screen.dart` into `lib/pages/booking_funnel/widgets/details_stage_content.dart`, and recompose `BookingSetupScreen` from it so `test/booking_setup_widget_test.dart` passes unchanged

- [x] 1.2 Extract the Review summary content (service, timing, address, landmarks, scope, arrival-code, estimate breakdown/total — no payment-method pills) from `checkout_screen.dart`'s sheet into `lib/pages/booking_funnel/widgets/review_stage_content.dart`, and recompose `CheckoutScreen` from it so its tests in `test/booking_funnel_test.dart` pass unchanged
- [x] 1.3 Move `_AddressBanner` into `lib/pages/booking_funnel/widgets/address_banner.dart`

- [x] 1.4 Add a `showNextButton` parameter (default `true`) to `TimeSelectionPanel` that hides its internal Continue button when `false`
## 2. Single-Page Accordion Funnel

- [x] 2.1 Rewrite `_CleaningBookingFlowView` in `lib/pages/booking_funnel/booking_flow_screen.dart` as a plain `Scaffold` (no `GoogleMap`, no `BookingMapSheetHost`, no geolocator, no `PinLocationWidget`/`_editBookingPin`, no `PopScope` location special-case) keeping the service title header, `_heroSubtitle`, constructor params, and the `checkAndGuardActiveMatching` entry guard
- [x] 2.2 Implement four accordion stage cards (Location, Time, Details, Review) with exactly one expanded, tappable headers showing collapsed summary state and done checks, `maxUnlocked` gating, and no step numbers — removing `bfStepOfCount` and `BookingStepSpine` from every funnel surface
- [x] 2.3 Implement the persistent bottom bar with the estimate total and a single action button (`bfContinue` on stages 0–2, `bkProceed` on stage 3)
- [x] 2.4 Wire stage validation: 0→1 `hasValidAddress` (snackbar `bkErrSelectAddress`), 1→2 `hasValidSchedule` (snackbar `bfScheduleMandatoryError`), 2→3 always; draft values must survive collapsing/re-expanding stages
- [x] 2.5 Wire the Location stage to `_AddressBanner` → `EditAddressWidget` modal (reusing `_editBookingAddress` without map state), the Time stage to `TimeSelectionPanel(embedded: true, showNextButton: false)` with the existing date/time pickers, and Details/Review to the extracted content widgets
- [x] 2.6 Bootstrap the estimate on entry (`refreshQuote()` in `initState` when no server quote exists) and keep the Details/Review estimate error + retry state visible without losing the draft

## 3. Payment Handoff

- [x] 3.1 Implement Proceed → `context.pushNamed(BookingPaymentWidget.routeName, extra: …)` with exactly the router-read keys: `serviceId`, `serviceName`, `category`, `imageUrl`, `providerName`, `providerPhoto` from `selectedService`, `notes` from landmarks (null when empty), `price` as the formatted quote total (fallback listing base price)
- [x] 3.2 Pass concrete schedule values (`scheduledDate ?? DateTime.now()` as ISO-8601, `scheduledTime ?? TimeOfDay.now()` formatted) so payment never resolves to midnight; gate Proceed on `serverQuote != null && !isLoadingQuote` with the estimate retry shown otherwise
- [x] 3.3 Verify express checkout, live matching, booking status, and the legacy `/booking` page are untouched by the funnel rework, and that entry points (`services_widget`, `tm_broadcast_screen`, live-matching retry) still push `BookingFlowScreen` correctly

## 4. Light-Mode Filled Button Labels

- [x] 4.1 Fix known offenders with an explicit light label color (`color: theme.onPrimary` / `Colors.white`): `checkout_screen.dart:510`, `booking_setup_screen.dart:182`, `live_matching_screen.dart:3212` and `_SheetPrimaryButton`, `express_checkout_sheet.dart:809`, `status_page.dart:691`, `booking_success_screen.dart:144`, `booking_controller.dart:100`
- [x] 4.2 Sweep `lib/pages/booking_funnel/` (and shared components it renders) for any remaining `AppButton` with a filled background whose label style lacks an explicit contrast color; fix each, and write all new accordion-page buttons with explicit colors

## 5. Ripple Pin Anchoring

- [x] 5.1 In `LiveMatchingScreen`, recompute `_pinScreenOffset` in an `addPostFrameCallback` whenever the GoogleMap `padding` value changes between builds (plus one delayed confirmation pass)
- [x] 5.2 Add a throttled `onCameraMove` recompute (~100 ms) and a post-frame recompute after `_fitCameraToRadius()` starts animating, keeping the existing `onCameraIdle`/`onMapCreated` updates
- [x] 5.3 Verify the ring center lands on the marker anchor (`Offset(0.5, 1)` — the pin tip/location point) across sheet drags, camera fits, and settle events

## 6. Verification & Quality Assurance

- [x] 6.1 Add tests: accordion progression Location→Time→Details→Review, schedule-validation snackbar blocks Time advance, Proceed pushes the payment route with the expected extras (mini GoRouter harness), and the funnel renders no `GoogleMap`
- [x] 6.2 Run `flutter test test/booking_funnel_test.dart test/booking_setup_widget_test.dart test/booking_controller_test.dart` plus the new tests — all pass
- [x] 6.3 Run `flutter analyze` and confirm 0 errors
- [x] 6.4 Confirm no new l10n keys are required (reuse `bfLocation`/`bfTime`/`bfDetails`/`bfReview`/`bfContinue`/`bkProceed`/`bfScheduleMandatoryError`/`bkErrSelectAddress`); if any new key is added, edit only `app_en.arb` + `app_es.arb` and run `flutter gen-l10n`
- [x] 6.5 Update `docs/ui-ux-reconstruction-plan.md` with the accordion funnel status note
- [x] 6.6 Validate OpenSpec change integrity with `openspec validate booking-flow-accordion-rework`
