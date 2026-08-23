## 1. Palette & shared components

- [x] 1.1 Add theme statics: `actionPrimary` (alias of accentNavy #1E3A8A), `successTeal` (#0D808A), `destructiveSoft` (#EF4444) to `lib/theme/app_theme.dart`; document amber = existing accentYellow
- [x] 1.2 Create `lib/components/booking_action_row.dart`: per-status action grammar (Pending → filled blue Track Service + outlined Reschedule; Completed → filled teal Write Review + gray Book Again; Canceled/other → low-contrast View Details link) driven by status string, with callbacks
- [x] 1.3 Rebuild timeline stepper in `lib/components/booking_step_indicator.dart`: vertical steps, glowing teal checkmarks for completed with timestamp captions, muted gray dots for pending, current-step highlight

## 2. Bookings list

- [x] 2.1 Replace Cupertino sliding control + PageView with search bar + chip row (All/Pending/Completed/Canceled); move filter/search state into `BookingsModel`
- [x] 2.2 Standardize card rendering on shared anatomy (icon, service name, professional, date/time, status badge) via `booking_card.dart`, replacing the inline builder; replace hardcoded scaffold hex with theme token
- [x] 2.3 Wire card actions through `BookingActionRow`: Track Service → tracking screen (booking id), Reschedule → reschedule flow, Write Review → review composition, Book Again → booking funnel with same listing, View Details → detail screen
- [x] 2.4 Empty/error/skeleton states restyled to new anatomy; verify chips + search compose correctly

## 3. Tracking page

- [x] 3.1 Restructure `booking_details_widget.dart` into three zones: professional summary card (avatar/name/star rating/circular Call+Message floating buttons using existing contact utilities)
- [x] 3.2 Middle zone: render rebuilt stepper from server status + timestamps (`created_at`, `arrived_at`, `started_at`); unknown statuses fall back safely
- [x] 3.3 Sticky footer: filled blue "Track on Map" (opens existing map/live view for active bookings; disabled otherwise) + red "Cancel Booking" text link keeping the existing confirm dialog and cancel call
- [x] 3.4 Surface `client_address` as the service-location line when present (falls back to notes parsing)

## 4. Booking confirmed screen

- [x] 4.1 Build checkmark hero (animated scale/fade green check), bold "Booking Confirmed!" title, friendly description
- [x] 4.2 Bordered receipt card: Booking ID, Date & Time, Service Provider, Total Amount — real values from created booking with quoted-total fallback
- [x] 4.3 Stacked buttons: filled deep-blue "Track My Booking" routing to tracking screen for the booking id; outlined "Add to Calendar" via dependency-free calendar intent or documented fallback
- [x] 4.4 Add card-contained Refer & Earn widget reusing `lib/components/invite_earn_banner.dart` with Share Link action
- [x] 4.5 Consolidate success routes: payment screen and funnel completion both land on `booking_success_screen.dart`; legacy `pages/booking_success/` route redirects before deletion

## 5. Verification

- [ ] 5.1 Status-matrix pass: create bookings across pending/completed/canceled states and verify each card's exact action set and colors
- [x] 5.2 Dark-mode audit of all three screens: tokens only, no light-only hex, legibility of tints/badges
- [ ] 5.3 Navigation audit: bottom nav intact on tab screens; Bookings highlight correct; Track My Booking lands on right booking; cancel flow still confirms
- [x] 5.4 `flutter analyze` — 0 errors; `flutter test test/booking_funnel_test.dart` — no new failures
