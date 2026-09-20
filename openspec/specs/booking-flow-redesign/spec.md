# booking-flow-redesign Specification

## Purpose

Defines a trustworthy, resumable mobile booking funnel that uses the SHPH API as the authority for estimates and booking state while giving clients a clearer, more forgiving path from service selection to confirmation and live matching.

## Requirements

### Requirement: Booking funnel presents explicit mobile steps
The booking flow SHALL present a clear ordered sequence for the selected service: confirm service and location, choose urgency or schedule, provide service details, review the server estimate and booking summary, submit, and observe matching or success. The current step and available back navigation SHALL be visible on every pre-submit step.

#### Scenario: Client advances through the funnel
- **WHEN** a client completes the required fields on the current step
- **THEN** the next step opens with the previously entered service, location, timing, and detail values preserved

#### Scenario: Client goes back a step
- **WHEN** a client uses the back control before submission
- **THEN** the prior step opens without clearing any values already entered

#### Scenario: Client reopens a booking step after an interruption
- **WHEN** the client returns from address or date-time selection, or a transient UI interruption closes a modal
- **THEN** the funnel remains on the same logical step with the draft intact

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
The flow SHALL create a booking through the SHPH booking API using the selected listing, resolved schedule, address context, notes, and booking preferences. Immediate/later-today requests SHALL use the live/on-demand path when applicable; scheduled requests SHALL use the reservation path. The created booking identifier SHALL become the authoritative reference for later screens.

#### Scenario: Live request succeeds
- **WHEN** the client confirms an immediate or later-today request
- **THEN** the app creates the booking, retains the returned booking reference, and opens live matching with the request state

#### Scenario: Scheduled reservation succeeds
- **WHEN** the client confirms a scheduled request
- **THEN** the app creates the reservation, retains the returned booking reference, and opens the booking-success or confirmation state

#### Scenario: Submission fails
- **WHEN** booking creation fails
- **THEN** the app remains in the review flow, displays a user-readable error, prevents duplicate submission while the request is active, and allows retry

### Requirement: Matching and success states reflect real booking state
After submission, live matching SHALL show the authoritative booking/job reference and any provider count or fee range returned by the API, distinguish loading, active, timeout, and failure states, and provide a route to tracking or booking details. Scheduled success SHALL show the created booking details and next actions without claiming payment was completed when payment is deferred.

#### Scenario: Matching receives API metadata
- **WHEN** the live/on-demand API returns a job reference or provider metadata
- **THEN** the matching state displays those values and does not fabricate provider counts or identifiers

#### Scenario: Matching times out
- **WHEN** no provider is found within the matching timeout
- **THEN** the app shows a clear retry or alternative action while preserving the created booking reference

#### Scenario: Scheduled booking reaches success
- **WHEN** a scheduled booking is created successfully
- **THEN** the success state displays its real booking reference, schedule, service, and next action while indicating payment timing accurately

### Requirement: Booking flow handles loading and recovery states
Each asynchronous booking operation SHALL expose an intentional loading state, prevent conflicting duplicate actions, surface a localized error or empty state, and provide a retry or safe back action whenever recovery is possible. No failed network operation SHALL erase the current draft.

#### Scenario: Service or estimate is loading
- **WHEN** the flow is waiting for listing or estimate data
- **THEN** a layout-preserving loading state appears and confirmation controls are disabled

#### Scenario: Network request fails during the funnel
- **WHEN** a booking-related request fails
- **THEN** the current draft remains available and the user can retry or return safely without a crash

### Requirement: Booking setup map bounded by bottom sheet
On the booking setup/checkout screen showing the map together with the bottom sheet that advances through Services / Location / Payment, the map SHALL occupy the area from the top of the screen down to the top edge of the bottom sheet. The map SHALL NOT render behind or below the bottom sheet, and the selected-location pin SHALL remain centered in the visible map area.

#### Scenario: Map does not extend behind the sheet
- **WHEN** the booking setup/checkout screen renders with the Services / Location / Payment bottom sheet open
- **THEN** the map's visible bottom boundary is the top edge of the sheet and no map area is hidden behind or below it

#### Scenario: Pin stays centered
- **WHEN** the map is bounded by the bottom sheet
- **THEN** the selected-location pin remains centered within the visible portion of the map
