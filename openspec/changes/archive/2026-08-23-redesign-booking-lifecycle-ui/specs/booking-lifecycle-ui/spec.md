## Purpose

Defines the shared visual language and per-screen interaction contract for the client booking lifecycle: how the bookings list filters and acts on bookings by status, how the tracking page organizes progress, and what the confirmation screen shows and routes to.

## ADDED Requirements

### Requirement: Booking list search and status filters
The Bookings tab SHALL present a search bar filtering visible cards by service or provider name, plus a horizontal filter-chip row (All, Pending, Completed, Canceled) that scopes the list; the previous two-segment sliding control SHALL NOT remain as the primary filter.

#### Scenario: Filtering by chip
- **WHEN** the user taps the "Completed" chip
- **THEN** only bookings with completed status are listed, and the chip shows an active tint while others stay muted

#### Scenario: Searching
- **WHEN** the user types "clean" in the search bar
- **THEN** the visible set narrows to bookings whose service title or provider name matches, within the active chip scope

### Requirement: Standardized booking card anatomy
Every booking card SHALL render, in order: a leading service icon, the service name, the professional's name, date and time metadata, and a status badge using the shared status colors — with identical corner radius, padding, and typography scale across all cards.

#### Scenario: Card renders uniformly
- **WHEN** any booking card is displayed in any filter state
- **THEN** it shows all five anatomy elements with consistent layout, differing only in status badge color and action row

### Requirement: Contextual card actions by status
Card actions SHALL depend on status: Pending bookings show a filled royal-blue "Track Service" primary button beside an outlined "Reschedule" secondary button; Completed bookings show a filled teal "Write Review" primary button beside a muted gray "Book Again" secondary button; Canceled bookings show no filled buttons and only a low-contrast "View Details" text link. In-progress/active states not listed SHALL follow the Pending pattern.

#### Scenario: Pending card actions
- **WHEN** a pending booking card renders
- **THEN** tapping "Track Service" opens the tracking screen for that booking and "Reschedule" opens rescheduling

#### Scenario: Completed card actions
- **WHEN** a completed booking card renders
- **THEN** "Write Review" opens review composition for that booking and "Book Again" starts a new booking with the same listing

#### Scenario: Canceled card has no destructive prominence
- **WHEN** a canceled booking card renders
- **THEN** it displays only the "View Details" text link with low contrast and no filled buttons

### Requirement: Tracking page three-zone structure
The tracking screen SHALL be organized vertically into: a top summary zone with the assigned professional's avatar, name, and star rating plus circular floating instant-action buttons for Call and Message; a middle vertical timeline stepper of service progress where completed steps show glowing teal checkmark indicators with printed timestamps and pending steps show muted gray dots; and a bottom sticky footer containing a filled blue "Track on Map" primary button and an explicitly red secondary "Cancel Booking" text link that confirms before cancelling.

#### Scenario: Progress reflects booking state
- **WHEN** an active booking is open on the tracking screen
- **THEN** steps up to the current server-reported stage show teal checkmarks with their timestamps and later stages show gray dots

#### Scenario: Sticky footer actions
- **WHEN** the user scrolls the tracking screen
- **THEN** the Track on Map button and Cancel Booking link remain pinned at the bottom

#### Scenario: Cancel requires confirmation
- **WHEN** the user taps Cancel Booking
- **THEN** a confirmation dialog appears before any cancellation request is sent

### Requirement: Confirmation screen layout and routing
The post-checkout success screen SHALL render, top to bottom: an animated green checkmark hero with bold "Booking Confirmed!" title and friendly description; a bordered receipt card listing Booking ID, Date & Time, Service Provider, and Total Amount; stacked buttons — filled deep-blue "Track My Booking" routing to the tracking screen for the created booking, above an outlined "Add to Calendar"; and a visually separate card-contained Refer & Earn widget with a Share Link action.

#### Scenario: Track My Booking routes correctly
- **WHEN** the user completes checkout and taps "Track My Booking"
- **THEN** the tracking screen opens for the just-created booking id

#### Scenario: Receipt data present
- **WHEN** the success screen renders
- **THEN** all four receipt fields display real values from the created booking (Total falling back to quoted amount until the server returns one)

### Requirement: Shared booking palette tokens
All three screens SHALL draw action colors from theme statics — royal blue (#1E3A8A) for primary actions, brand teal/emerald (#0D808A) for success states, soft red (#EF4444) for destructive/cancel affordances, amber (#F59E0B) for pending/warning highlights — with no hardcoded hex values in screen code, preserving dark mode.

#### Scenario: Token-only coloring
- **WHEN** any of the three screens renders in light or dark mode
- **THEN** action colors resolve from theme constants and surfaces/text from existing theme tokens

### Requirement: Bottom navigation preserved
All three screens SHALL keep the app's fixed five-tab bottom navigation (Home, Explore, Bookings, Messages, Profile) with the Bookings tab highlighted while on the list; pushed detail screens (tracking, confirmation) may run without the bar but MUST NOT alter its definition.

#### Scenario: Bookings tab active state
- **WHEN** the user is on the Bookings tab
- **THEN** the bottom bar highlights Bookings and shows the other four targets muted
