## MODIFIED Requirements

### Requirement: Booking funnel presents explicit mobile steps
The booking flow SHALL present its stages — Location, Time, Details, Review — for the selected service on a single page as an accordion: exactly one stage expanded at a time, completed stages collapsed into tappable headers that show their summary state, and later stages locked until their prerequisites validate. The current stage and available back navigation SHALL be visible on every stage, and no numbered step indicators (such as "Step X of 4" or numbered badges) SHALL be shown. The stages page SHALL NOT embed a Google Map; location SHALL be captured through the address picker. A persistent bottom action bar SHALL advance stages and, on Review, proceed to payment.

#### Scenario: Client advances through the funnel
- **WHEN** a client completes the required fields on the current stage and uses the bottom action bar
- **THEN** the next stage expands with the previously entered service, location, timing, and detail values preserved

#### Scenario: Client returns to an earlier stage
- **WHEN** a client taps a completed stage header before submission
- **THEN** that stage expands, the current stage collapses, and no values already entered are cleared

#### Scenario: Client goes back a step
- **WHEN** a client uses the back control before submission
- **THEN** the prior stage opens without clearing any values already entered

#### Scenario: Client reopens a booking step after an interruption
- **WHEN** the client returns from address or date-time selection, or a transient UI interruption closes a modal
- **THEN** the funnel remains on the same logical stage with the draft intact

#### Scenario: Scheduled stage cannot advance without a schedule
- **WHEN** the client attempts to leave the Time stage while scheduled timing lacks a date and time
- **THEN** the funnel shows a localized validation message and stays on the Time stage

#### Scenario: Stages render without a map
- **WHEN** the booking stages page renders
- **THEN** no Google Map or map platform view is created, and the address is shown and edited through the address picker

#### Scenario: No numbered step indicators
- **WHEN** any funnel surface renders
- **THEN** no "Step X of 4" label or numbered step badge appears

### Requirement: Estimate is server-authoritative
Before confirmation, the flow SHALL request the backend estimate for the selected listing and resolved schedule, display the returned breakdown and total when available, and SHALL NOT present a locally invented total as authoritative. Numeric API values represented as numbers or numeric strings SHALL be normalized consistently. The funnel SHALL request the estimate on entry when the draft has no server estimate yet, without requiring a draft mutation first.

#### Scenario: Estimate loads successfully
- **WHEN** the selected listing and schedule are valid
- **THEN** the review step displays the server-returned base price, fees, taxes or premiums when supplied, and total

#### Scenario: Estimate response uses numeric strings
- **WHEN** the API returns a price or fee such as `"500.0"`
- **THEN** the flow parses and displays it as a numeric amount without a type-cast error

#### Scenario: Estimate fails
- **WHEN** the estimate endpoint fails or returns unusable data
- **THEN** the flow shows a recoverable error state, prevents confirmation, and offers retry without losing the draft

#### Scenario: Estimate is requested on funnel entry
- **WHEN** the client opens the booking funnel and no server estimate exists for the draft yet
- **THEN** the funnel requests the estimate automatically so the review stage can show a real total

### Requirement: Review step exposes the final request before submission
The review step SHALL summarize the selected service, provider/listing context when available, timing, address, landmarks, scope, arrival-code preference, payment preference, and estimate breakdown, and SHALL offer a "Proceed to Payment" confirmation action that navigates to the booking payment page carrying the listing identity, resolved schedule, formatted estimate total, landmarks as notes, and provider context. Payment method selection SHALL occur on the payment page rather than in the funnel. The client SHALL be able to return to edit any preceding stage before proceeding.

#### Scenario: Client reviews a complete request
- **WHEN** all required booking fields are valid and the estimate is available
- **THEN** the review stage shows the complete request summary and enables the Proceed to Payment action

#### Scenario: Client proceeds to payment
- **WHEN** the client taps Proceed to Payment with an available estimate
- **THEN** the app navigates to the booking payment page carrying the selected listing, a concrete resolved schedule date and time (even for immediate requests), the formatted estimate total, landmarks as notes, and provider name and photo context

#### Scenario: Proceed is gated on the estimate
- **WHEN** the estimate is still loading or unavailable
- **THEN** the Proceed to Payment action stays disabled and the review stage offers the estimate retry without losing the draft

#### Scenario: Client edits from review
- **WHEN** the client changes timing, address, or scope from the review stage
- **THEN** the affected summary and estimate are refreshed before proceeding

### Requirement: Submission follows distinct live and scheduled API paths
The services-listing funnel SHALL NOT create the booking itself; its confirmation action SHALL hand off to the booking payment page, which creates the booking through the SHPH booking API using the selected listing, resolved schedule, address context, notes, and the payment completed there. The created booking identifier SHALL become the authoritative reference for tracking. The On-Demand API path (`/api/services/on-demand/`) SHALL remain available through express checkout for immediate and urgent requests launched from home and search, while funnel bookings are created via the standard booking path (`/api/bookings/`) on the payment page.

#### Scenario: On-demand request succeeds
- **WHEN** the client confirms an immediate or emergency request
- **THEN** the app creates the job via `/api/services/on-demand/`, retains the returned job reference, and opens live matching in on-demand polling mode

#### Scenario: Scheduled reservation succeeds
- **WHEN** the client confirms a scheduled request
- **THEN** the app creates the reservation via `/api/bookings/`, retains the returned booking reference, and opens the booking confirmation state

#### Scenario: Funnel booking is created on the payment page
- **WHEN** the client completes payment for a booking handed off from the funnel
- **THEN** the payment page creates the booking via the standard booking API, retains the returned booking reference, and opens the booking confirmation state

#### Scenario: Express checkout still broadcasts immediate requests
- **WHEN** the client confirms an immediate request through express checkout
- **THEN** the app creates the job via `/api/services/on-demand/`, retains the returned job reference, and opens live matching in on-demand polling mode

#### Scenario: Submission fails
- **WHEN** booking creation fails on the payment page
- **THEN** the app remains in the payment flow, displays a user-readable error, prevents duplicate submission while the request is active, and allows retry

### Requirement: Services step exposes on-demand and scheduled dispatch mode
Under the services configuration stage in the booking flow, the UI SHALL present an explicit dispatch option allowing the client to choose between:
1. **On-Demand (Urgent / Right Now / Emergency)**: Prioritizes immediate dispatch to the nearest available provider.
2. **Standard Booking (Scheduled for Later / Specific Date)**: Reserves a guaranteed provider slot for an upcoming date and time.

#### Scenario: User selects on-demand under services tab
- **WHEN** the user selects the on-demand dispatch option
- **THEN** the draft urgency is set to immediate/right-now, scheduling date/time pickers are disabled or preset to immediate window, and the review action proceeds to payment with a resolved immediate schedule

#### Scenario: User selects standard scheduled booking under services tab
- **WHEN** the user selects the standard scheduled booking option
- **THEN** the draft urgency is set to scheduled, date and time pickers become mandatory, and the review action proceeds to payment with the selected schedule

## REMOVED Requirements

### Requirement: Services listing entry point launches multi-stage booking flow
**Reason**: This entry-point requirement bundled Google Map camera behavior (full-bleed map behind the stage modal, dynamic padding, pin framing) that no longer exists on the booking stages — the funnel stages page has no map. The entry point is re-specified below as an accordion launch without map behavior.
**Migration**: Map camera behavior for surfaces that still pair a map with a sheet is specified by `booking-map-sheet-host` and `live-matching-experience`; the accordion entry point is specified by the added requirement below.

### Requirement: Booking setup map is adaptive and full-bleed
**Reason**: The booking setup and flow screens no longer embed a Google Map — location is captured through the address picker — so a full-bleed map behind a bottom sheet no longer exists on these surfaces.
**Migration**: The sheet-hosted map behavior remains specified by the `booking-map-sheet-host` capability for surfaces that still pair a map with a sheet (live matching and booking status tracking).

### Requirement: Map viewport dynamic camera padding
**Reason**: Removed together with the funnel's map; the booking flow's stages page has no Google Maps view to pad.
**Migration**: Camera-padding behavior for remaining map surfaces is specified by `booking-map-sheet-host` and `live-matching-experience`.

## ADDED Requirements

### Requirement: Services listing entry point launches the accordion booking funnel
When the client taps the "Book Now" action on any service card within the services listing page, the system SHALL launch the single-page accordion booking funnel (Location, Time, Details, Review) rather than bypassing steps directly to express checkout.

#### Scenario: Client taps Book Now on service card
- **WHEN** the client taps "Book Now" on a service card in the services listing
- **THEN** the system navigates to the accordion booking flow initialized with the selected service listing and current client address coordinates

#### Scenario: Active matching guard intercepts booking entry
- **WHEN** the client taps "Book Now" while a live matching search is already active
- **THEN** entry into the booking funnel is blocked and an advisory prompt is displayed offering to view the active search
