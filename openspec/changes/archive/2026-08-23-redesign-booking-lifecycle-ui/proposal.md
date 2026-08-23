## Why

The booking lifecycle screens (list, active tracking, post-checkout success) grew from different eras of the app and share no visual system: the list has a two-segment slider instead of status filters, cards render identical action rows regardless of booking state, tracking scatters progress info across sections, and two competing "success" screens exist (`pages/booking_success/` legacy vs `pages/booking_funnel/booking_success_screen.dart`). This redesign unifies them under one booking-specific palette (royal-blue primary actions, teal success, red destructive, amber pending) with state-aware actions so each card/screen answers "what can I do right now?" at a glance.

## What Changes

- **Bookings List** (`lib/main/bookings/bookings_widget.dart`): replace the Cupertino sliding segment control with a search bar plus filter chips (All / Pending / Completed / Canceled); standardize `BookingCard` anatomy (service icon, name, professional, date/time, status badge); make action buttons contextual per status — Pending: filled blue "Track Service" + outlined "Reschedule"; Completed: filled teal "Write Review" + gray "Book Again"; Canceled: low-contrast "View Details" text link only.
- **Track Your Booking** (`lib/pages/booking_details/booking_details_widget.dart`): restructure into three vertical zones — top professional summary card (avatar, name, star rating, circular floating Call/Message buttons), middle vertical timeline stepper (glowing teal checkmarks for done steps with timestamps, muted gray dots for pending), bottom sticky footer (filled blue "Track on Map" + red text "Cancel Booking").
- **Booking Confirmed** (`lib/pages/booking_funnel/booking_success_screen.dart`): minimalist green checkmark hero with "Booking Confirmed!" title, bordered receipt card (Booking ID, Date & Time, Service Provider, Total), stacked primary "Track My Booking" (deep blue → tracking screen) and outlined "Add to Calendar" buttons, plus a card-contained Refer & Earn widget (reuse `lib/components/invite_earn_banner.dart`) with Share Link action.
- **Palette tokens**: add royal-blue primary-action and soft-red destructive tokens; amber and teal already exist as theme statics.
- **Consolidate** the legacy `lib/pages/booking_success/` route to point at the funnel success screen (single success surface).
- Keep the fixed five-tab bottom navigation (Messages label retained; not "Chat").

## Capabilities

### New Capabilities
- `booking-lifecycle-ui`: Visual system and interaction contract for the three client booking screens — list filtering/card anatomy/contextual actions, tracking-page zone structure and stepper semantics, confirmation-screen layout and routing.

### Modified Capabilities

## Impact

- `lib/main/bookings/bookings_widget.dart`, `bookings_model.dart`, `lib/components/booking_card.dart`
- `lib/pages/booking_details/booking_details_widget.dart`, `booking_details_model.dart`
- `lib/pages/booking_funnel/booking_success_screen.dart`; deprecation of `lib/pages/booking_success/` route
- `lib/theme/app_theme.dart` (new color statics only)
- Depends on `fix-booking-create-scheduled-at` for correct confirm flow; consumes response fields (`client_address`, timestamps) mapped there.
- No backend/API changes.
