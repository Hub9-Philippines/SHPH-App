# booking-flow-redesign Specification

## Purpose

Defines a trustworthy, resumable mobile booking funnel that uses the SHPH API as the authority for estimates and booking state while giving clients a clearer, more forgiving path from service selection to confirmation and live matching.

## Requirements

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

### Requirement: Booking draft captures the complete request context
The booking draft SHALL retain the selected listing identity and service metadata, urgency, optional schedule, quantity/scope, service level, address, latitude/longitude, landmarks or instructions, arrival-code preference, payment preference, and generated booking reference where applicable.

#### Scenario: Address context is edited
- **WHEN** a client changes the address and adds optional landmarks
- **THEN** the review step displays the new address context and the submitted booking includes the landmarks in its request notes or supported address fields

#### Scenario: Arrival-code preference changes
- **WHEN** a client toggles the arrival-code requirement
- **THEN** the selected preference remains active through review and is included in the booking request contract

### Requirement: Timing choices resolve to valid API schedule values
The flow SHALL support immediate, later-today, and scheduled timing modes. Immediate and later-today requests SHALL resolve to a valid future `scheduled_at` value, while scheduled requests SHALL require a selected date and time before review or submission.

#### Scenario: Immediate request
- **WHEN** the client chooses the immediate option
- **THEN** the API request contains a future scheduled value based on the immediate booking policy

#### Scenario: Scheduled request is incomplete
- **WHEN** the client chooses scheduled timing without a valid date and time
- **THEN** the flow blocks continuation and identifies the missing schedule fields

#### Scenario: Scheduled request is submitted
- **WHEN** the client selects a valid date and time and confirms the booking
- **THEN** the API receives the resolved date-time in the expected format and timezone policy

### Requirement: Estimate is server-authoritative
Before confirmation, the flow SHALL request the backend estimate for the selected listing and resolved schedule, display the returned breakdown and total when available, and SHALL NOT present a locally invented total as authoritative. Numeric API values represented as numbers or numeric strings SHALL be normalized consistently.

#### Scenario: Estimate loads successfully
- **WHEN** the selected listing and schedule are valid
- **THEN** the review step displays the server-returned base price, fees, taxes or premiums when supplied, and total

#### Scenario: Estimate response uses numeric strings
- **WHEN** the API returns a price or fee such as `"500.0"`
- **THEN** the flow parses and displays it as a numeric amount without a type-cast error

#### Scenario: Estimate fails
- **WHEN** the estimate endpoint fails or returns unusable data
- **THEN** the flow shows a recoverable error state, prevents confirmation, and offers retry without losing the draft

### Requirement: Review step exposes the final request before submission
The review step SHALL summarize the selected service, provider/listing context when available, timing, address, landmarks, scope, arrival-code preference, payment preference, estimate breakdown, and the context-specific confirmation action. The client SHALL be able to return to edit any preceding value before submitting.

#### Scenario: Client reviews a complete request
- **WHEN** all required booking fields are valid and the estimate is available
- **THEN** the review step shows the complete request summary and enables the confirmation action

#### Scenario: Client edits from review
- **WHEN** the client changes timing, address, scope, or payment preference from the review flow
- **THEN** the affected summary and estimate are refreshed before confirmation

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

### Requirement: Matching and success states reflect real booking state
After submission, live matching SHALL show the authoritative booking/job reference and any provider count or fee range returned by the API, distinguish loading, active, timeout, and failure states, and provide a route to tracking or booking details. Scheduled success SHALL show the created booking details and next actions without claiming payment was completed when payment is deferred. When the on-demand broadcast request fails or returns no job reference, the app SHALL surface that failure explicitly (localized failure state with a retry path) instead of silently degrading to a preview-style countdown; the preview/fallback state SHALL be reserved for confirmed transport-level unreachability and SHALL be distinguishable from an active search.

#### Scenario: Matching receives API metadata
- **WHEN** the live/on-demand API returns a job reference or provider metadata
- **THEN** the matching state displays those values and does not fabricate provider counts or identifiers

#### Scenario: Matching times out
- **WHEN** no provider is found within the matching timeout
- **THEN** the app shows a clear retry or alternative action while preserving the created booking reference

#### Scenario: Scheduled booking reaches success
- **WHEN** a scheduled booking is created successfully
- **THEN** the success state displays its real booking reference, schedule, service, and next action while indicating payment timing accurately

#### Scenario: Broadcast fails at submission
- **WHEN** the on-demand broadcast API call fails or returns no job reference while the booking itself was created
- **THEN** the app reports the broadcast failure with a localized message and a retry action, and never presents the failed search as an active preview

#### Scenario: Broadcast succeeds at submission
- **WHEN** the on-demand broadcast API call returns a job reference
- **THEN** live matching polls the real job status and transitions to matched/expired/timeout based on server responses only

### Requirement: Booking flow handles loading and recovery states
Each asynchronous booking operation SHALL expose an intentional loading state, prevent conflicting duplicate actions, surface a localized error or empty state, and provide a retry or safe back action whenever recovery is possible. No failed network operation SHALL erase the current draft.

#### Scenario: Service or estimate is loading
- **WHEN** the flow is waiting for listing or estimate data
- **THEN** a layout-preserving loading state appears and confirmation controls are disabled

#### Scenario: Network request fails during the funnel
- **WHEN** a booking-related request fails
- **THEN** the current draft remains available and the user can retry or return safely without a crash

### Requirement: Booking setup map is adaptive and full-bleed
On the booking setup and booking flow screens showing the map together with the bottom sheet that advances through Services, Location, and Payment, the map SHALL render full-bleed, extending edge-to-edge and behind the entire bottom sheet, with no background, gutter, or gap between the map's lower region and the sheet's top edge. The map's camera padding SHALL be derived from the bottom sheet's measured height for the currently displayed step rather than a fixed constant, and the selected-location pin SHALL remain framed and centered within the map region visible above the sheet.

#### Scenario: Map extends behind the sheet
- **WHEN** the booking stages screen renders with the Services, Location, or Payment bottom sheet open
- **THEN** the map fills the entire viewport including the region behind and below the sheet, and the sheet's surface is what occludes the map rather than a layout boundary

#### Scenario: No gap when the sheet is short
- **WHEN** the displayed bottom sheet is shorter than the screen's maximum permitted sheet height
- **THEN** no strip of plain background appears between the map and the sheet, and map imagery continues up to the sheet's top edge

#### Scenario: Camera padding tracks the current step
- **WHEN** the setup screen advances from one bottom sheet to another of a different height
- **THEN** the map's camera padding is recomputed from the newly displayed sheet's measured height

#### Scenario: Pin stays framed above the sheet
- **WHEN** the map camera padding has been applied for the current sheet
- **THEN** the selected-location pin remains within the portion of the map visible above the bottom sheet and is not obscured by it

#### Scenario: Per-step measurement replaces fixed constants
- **WHEN** the setup screen's map layout is inspected
- **THEN** the camera padding derives from the measured sheet height and no hardcoded approximation of the sheet height remains in that screen's layout

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

### Requirement: Services listing entry point launches multi-stage booking flow
When the client taps the "Book Now" action on any service card within the services listing page, the system SHALL launch the multi-stage booking funnel (Services, Location, Payment) rather than bypassing steps directly to express checkout. The booking stages view SHALL apply the live matching Google Map behavior: rendering full-bleed behind the bottom modal, calculating camera padding dynamically from the active stage modal height, and centering the location pin in the unobstructed visible map area above the modal.

#### Scenario: Client taps Book Now on service card
- **WHEN** the client taps "Book Now" on a service card in the services listing
- **THEN** the system navigates to the multi-stage booking flow initialized with the selected service listing and current client address coordinates

#### Scenario: Map camera centers pin above modal across booking stages
- **WHEN** the client transitions between stages (Location confirmation, Time/urgency selection, Services setup, and Payment review)
- **THEN** the Google Map camera padding updates dynamically to match the height of the active stage modal, keeping the pinned service coordinate framed and visible above the modal edge

#### Scenario: Active matching guard intercepts booking entry
- **WHEN** the client taps "Book Now" while a live matching search is already active
- **THEN** entry into the booking funnel is blocked and an advisory prompt is displayed offering to view the active search
