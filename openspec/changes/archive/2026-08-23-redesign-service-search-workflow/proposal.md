## Why

The service search journey — category discovery → results → checkout — is functional but generic: nothing surfaces emergency help when seconds matter, results lack the trust signals (verified badges, distance, ratings) users need to choose, and checkout scatters essentials (address context, arrival security, digital payment choices) across screens without a clear progress spine or a decisive final CTA. This redesign rebuilds the workflow around urgency-aware discovery and a confident multi-step checkout.

## What Changes

- **Explore / Category landing (Screen 1)**
  - Root-level pull-to-refresh container (canonical app pattern).
  - Persistent Quick Book scaffold area at the base with a high-priority "Urgent Assistance" button for emergency bookings.
  - Emergency flagging: Electrical, Locksmith, Plumbing, and Pest Control categories get an attention border + indicator wherever categories render.
  - Selecting an emergency category reveals an inline "Instant Dispatch" section offering expedited 15–30 minute arrival windows that launch a pre-set urgent booking.
- **Search Results (Screen 2, `/services`)**
  - Header: back chevron + search input showing the active keyword + micro-location selector pill + filter actions row.
  - Result cards: oversized square image showcase, provider name with verified badge, distance sub-text ("1.2 km away"), aggregate star-rating badge, multi-line experience description, "Starting Fee" price tag, solid royal-blue "Book Now" button.
- **Confirm Booking (Screen 3, funnel checkout rework)**
  - Progress line tracker across the checkout sequence with a working back button.
  - Profile summary row: specialist avatar, verified badge, name, ratings summary, proximity marker.
  - Service selection matrix: checkbox rows with exact pricing; urgent selections carry a "FASTEST" tag.
  - Location context widget: delivery address card + inline CHANGE trigger + optional "Bldg / Room No., Floor or Landmarks" input.
  - "Require Arrival Code" configuration row with info hint and right-aligned switch.
  - Dual-layer payment matrix: Cash / Digital tier; Digital reveals a GCash · Maya · Card · QR Ph sub-option carousel with payment glyphs.
  - Sticky footer: "Total Price Due:" display + full-width royal-blue CTA whose label adapts to context ("Book Locksmith Now →").
- Visual language stays on the Deep Royal Blue (#1E3A8A) primary with neutral/cool grays; no teal variants are introduced in this workflow.

## Capabilities

### New Capabilities
- `service-search-workflow`: The end-to-end contract for category discovery with emergency prioritization and quick-book access, the search-results presentation contract, and the multi-step confirm-booking flow including payments and completion actions.

### Modified Capabilities

## Impact

- `lib/main/explore/explore_widget.dart` — quick-book scaffold area, emergency flags in the category rail
- `lib/pages/categories/categories_widget.dart` (+ `lib/components/categories_widget/`) — pull-to-refresh, emergency flags, quick-book area
- `lib/main/services/services_widget.dart` (+ model) — header additions (location pill, filters), result-card anatomy, emergency rail behavior
- `lib/pages/booking_funnel/express_checkout_screen.dart` / `checkout_screen.dart` / `booking_controller.dart` / `booking_models.dart` — progress tracker, summary row, service matrix, location widget, arrival-code toggle, payment matrix, sticky CTA
- New shared pieces: emergency-category constants/helper, instant-dispatch section widget, payment-option glyphs component
- No backend changes required for UI structure; GCash/QR Ph intents ride existing e-wallet processing until dedicated providers exist (documented fallback). Arrival-code preference stored client-side into the booking draft (server start-PIN flow already exists).
