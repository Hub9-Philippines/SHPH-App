# booking-lifecycle-ui Specification (Delta)

## MODIFIED Requirements

### Requirement: Contextual card actions by status
Card actions SHALL depend on status: Pending bookings show a filled royal-blue "Track Service" primary button beside an outlined "Reschedule" secondary button; Completed bookings show a filled teal "Write Review" primary button beside a muted gray "Book Again" secondary button; Canceled bookings show no filled buttons and only a low-contrast "View Details" text link. In-progress/active states not listed SHALL follow the Pending pattern. "Track Service" SHALL open the booking details page for that booking, which presents the Service Progress stepper; it SHALL NOT open the standalone tracking page.

#### Scenario: Pending card actions
- **WHEN** a pending booking card renders
- **THEN** tapping "Track Service" opens the booking details page for that booking (which shows Service Progress) and "Reschedule" opens rescheduling

#### Scenario: Completed card actions
- **WHEN** a completed booking card renders
- **THEN** "Write Review" opens review composition for that booking and "Book Again" starts a new booking with the same listing

#### Scenario: Canceled card has no destructive prominence
- **WHEN** a canceled booking card renders
- **THEN** it displays only the "View Details" text link with low contrast and no filled buttons

## ADDED Requirements

### Requirement: Booking details is the tracking surface
The booking details page SHALL render the booking's Service Progress stepper reflecting the current server-reported stage, and SHALL NOT present a "Track on Map" action or any button that opens the standalone tracking page.

#### Scenario: Progress reflects booking state
- **WHEN** an active booking is open on the booking details page
- **THEN** steps up to the current server-reported stage are marked complete and later stages are shown as pending

#### Scenario: No map tracking action on details
- **WHEN** the booking details page renders for any booking status
- **THEN** no "Track on Map" button or equivalent action appears and the page does not link to the standalone tracking page