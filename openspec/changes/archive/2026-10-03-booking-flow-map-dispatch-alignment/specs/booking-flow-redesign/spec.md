## MODIFIED Requirements

### Requirement: Booking funnel presents explicit mobile steps
The booking flow SHALL present a clear ordered sequence for the selected service: confirm service and location, choose urgency or schedule, provide service details, review the server estimate and booking summary, submit, and observe matching or success. The current step and available back navigation SHALL be visible on every pre-submit step. The Google Map backing the flow SHALL dynamically offset its camera padding so the pinned service location is never obscured or clipped by the bottom step modal on any device.

#### Scenario: Client advances through the funnel
- **WHEN** a client completes the required fields on the current step
- **THEN** the next step opens with the previously entered service, location, timing, and detail values preserved, and the map camera re-centers the pin within the newly uncovered upper viewport

#### Scenario: Client goes back a step
- **WHEN** a client uses the back control before submission
- **THEN** the prior step opens without clearing any values already entered, with map camera padding adjusting smoothly to the prior panel height

#### Scenario: Client reopens a booking step after an interruption
- **WHEN** the client returns from address or date-time selection, or a transient UI interruption closes a modal
- **THEN** the funnel remains on the same logical step with the draft intact and the pin centered in the visible area

### Requirement: Submission follows distinct live and scheduled API paths
The flow SHALL create a booking through the SHPH booking API using the selected listing, resolved schedule, address context, notes, and booking preferences. Immediate/urgent/emergency requests SHALL use the On-Demand API path (`/api/services/on-demand/`); scheduled requests SHALL use the standard booking reservation path (`/api/bookings/`). The created booking or job identifier SHALL become the authoritative reference for live matching or tracking.

#### Scenario: On-demand request succeeds
- **WHEN** the client confirms an immediate or emergency request
- **THEN** the app creates the job via `/api/services/on-demand/`, retains the returned job reference, and opens live matching in on-demand polling mode

#### Scenario: Scheduled reservation succeeds
- **WHEN** the client confirms a scheduled request
- **THEN** the app creates the reservation via `/api/bookings/`, retains the returned booking reference, and opens the booking confirmation state

#### Scenario: Submission fails
- **WHEN** booking creation fails
- **THEN** the app remains in the review flow, displays a user-readable error, prevents duplicate submission while the request is active, and allows retry

## ADDED Requirements

### Requirement: Map viewport dynamic camera padding
The Google Maps view in the booking flow SHALL calculate its visible viewport padding dynamically from the measured height and bottom safe area of whichever modal sheet is presented. The pinned target coordinate SHALL be framed within the visible map area above the modal sheet edge at all times.

#### Scenario: Step modal changes height
- **WHEN** the user switches between steps with differing panel heights (e.g., location confirmation vs time selection)
- **THEN** the Google Map camera padding updates to match the current panel height plus safe area margins, keeping the pin visible and centered above the sheet

#### Scenario: Keyboard or bottom sheet resize
- **WHEN** the bottom modal expands or a text field requests keyboard focus
- **THEN** the map camera adjusts padding and animates the pin into the remaining visible viewport area

### Requirement: Services step exposes on-demand and scheduled dispatch mode
Under the services configuration step in the booking flow, the UI SHALL present an explicit dispatch option allowing the client to choose between:
1. **On-Demand (Urgent / Right Now / Emergency)**: Prioritizes immediate provider broadcast and real-time live matching.
2. **Standard Booking (Scheduled for Later / Specific Date)**: Reserves a guaranteed provider slot for an upcoming date and time.

#### Scenario: User selects on-demand under services tab
- **WHEN** the user selects the on-demand dispatch option
- **THEN** the draft urgency is set to immediate/right-now, scheduling date/time pickers are disabled or preset to immediate window, and the checkout action routes to the live on-demand broadcast endpoint

#### Scenario: User selects standard scheduled booking under services tab
- **WHEN** the user selects the standard scheduled booking option
- **THEN** the draft urgency is set to scheduled, date and time pickers become mandatory, and the checkout action routes to the standard reservation endpoint
