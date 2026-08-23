## Purpose

Defines the map tracking screen as a full-bleed map canvas with floating overlays and a fixed bottom sheet: where the back control, provider card, progress stepper, date badge, and completion actions live, and how each behaves.

### Requirement: Full-bleed map canvas
The tracking screen SHALL render the Google Maps container as the full background layer of the screen — extending edge-to-edge behind all floating overlays and the bottom sheet — with no solid bar above it consuming layout space.

#### Scenario: Map fills the screen
- **WHEN** the tracking screen is open
- **THEN** the map is visible behind and around every overlay, including above the bottom sheet and beside the floating controls

### Requirement: Floating back button
The tracking screen SHALL pin a circular floating back button in its top-left corner over the map: a left-chevron glyph on a white circular surface with a subtle drop shadow for visibility. Activating it SHALL navigate back; when the screen was entered as a flow root, activation SHALL route to Home instead.

#### Scenario: Back over the map
- **WHEN** the user taps the floating back button after navigating from bookings
- **THEN** the screen pops back to the previous page

#### Scenario: Flow-root back behavior preserved
- **WHEN** the screen was opened with shouldPopToHome semantics (funnel entry)
- **WHEN** the user taps the floating back button
- **THEN** the user lands on Home rather than an empty stack

### Requirement: Floating provider card
A provider card SHALL hover near the top-center of the map with rounded corners containing: the provider's avatar, name, current status chip, and two instant-action icons — Call and Message. Call SHALL open the phone dialer when a number is available and Message SHALL open the provider conversation flow, both falling back to non-breaking inline feedback when contact data is unavailable.

#### Scenario: Card floats over the map
- **WHEN** the tracking screen renders
- **THEN** the provider card hovers over the map near the top-center with rounded corners and remains visible regardless of sheet position

#### Scenario: Instant actions
- **WHEN** the user taps Call or Message on the card
- **THEN** dialer or conversation opens respectively, or inline feedback appears if contact details are unavailable

### Requirement: Non-collapsible bottom sheet
The tracking screen SHALL anchor a clean white bottom card occupying the lower 45% of the viewport with 24px top corner radius. The card SHALL NOT collapse, drag-resize, or expand; content taller than the card scrolls inside it, and the map camera padding accounts for the fixed extent.

#### Scenario: Fixed sheet extent
- **WHEN** the user drags upward on the bottom card
- **THEN** the card stays anchored at 45% height while inner content scrolls

#### Scenario: Sheet profile
- **WHEN** the bottom card renders
- **THEN** its top corners measure 24px radius on a white surface

### Requirement: Single-checkmark stepper
The vertical progress stepper (Confirmed → Provider En Route → On Site → Service In Progress → Completed) SHALL show exactly one green checkmark indicator per completed stage, positioned on the left track line; no secondary checkmark glyph MAY appear next to a completed stage title. Pending stages keep muted dots, and any active-stage emphasis remains singular.

#### Scenario: One checkmark per completed stage
- **WHEN** any set of stages is completed
- **THEN** each completed row shows only the track-line green checkmark and no additional check icon beside its title

### Requirement: Compact booking-date badge
The booking-date detail area SHALL render as a compact polished horizontal badge — a single-row pill-style container combining a calendar glyph, the "Booking date" label, and the formatted value — replacing the previous multi-row detail box.

#### Scenario: Date badge anatomy
- **WHEN** the bottom card renders
- **THEN** the booking date appears as one compact horizontal badge row rather than a boxed detail list

### Requirement: Completed-state actions
When the tracked status is Completed, the bottom card SHALL append a prominent full-width primary action labeled "Write a Review" with a deep emerald background, routing to review composition for that booking when its reference is available, plus a secondary "View Invoice" text link beneath it; activating the invoice link SHALL open invoice output for the booking when available and otherwise present inline feedback without erroring.

#### Scenario: Review action routes with reference
- **WHEN** a completed booking with a known id shows the tracking screen and the user taps Write a Review
- **THEN** review composition opens pre-bound to that booking

#### Scenario: Invoice link degrades gracefully
- **WHEN** the user taps View Invoice and no invoice surface can be resolved
- **THEN** inline feedback confirms availability status instead of a crash or silent dead tap
