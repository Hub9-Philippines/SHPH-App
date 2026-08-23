## Purpose

Defines the end-to-end service search workflow: urgency-aware category discovery with a persistent quick-book entry point, the trust-signal-rich search results presentation, and the multi-step confirm-booking flow covering location context, arrival security, dual-layer payments, and the context-adaptive completion action.

### Requirement: Quick Book scaffold area
The Explore and Categories landing screens SHALL render a persistent quick-book area anchored at the base of the screen containing a high-priority "Urgent Assistance" button; activating it SHALL start an emergency booking flow scoped to the core emergency categories with immediate-dispatch urgency pre-selected.

#### Scenario: Urgent Assistance entry
- **WHEN** the user taps "Urgent Assistance" from Explore or Categories
- **THEN** the emergency booking path opens with right-now dispatch urgency preset and only emergency domains offered

### Requirement: Emergency category flagging
Electrical, Locksmith, Plumbing, and Pest Control SHALL be flagged as core emergency categories everywhere categories are presented (Explore rail, Categories page, Services rail): each flagged tile carries a visually distinct attention border or status indicator differentiating it from standard household services.

#### Scenario: Emergency tile stands out
- **WHEN** any of the four emergency categories renders among standard categories
- **THEN** it displays the attention indicator while standard categories do not

### Requirement: Instant Dispatch for emergency categories
When an emergency category is selected, the landing screen SHALL reveal an inline specialized section offering expedited "Instant Dispatch" options guaranteeing 15–30 minute provider arrival windows; choosing an option SHALL launch the booking flow with that window applied. Non-emergency categories SHALL NOT show this section.

#### Scenario: Dispatch section appears for emergency only
- **WHEN** the user selects Locksmith
- **THEN** the inline Instant Dispatch section appears with 15–30 minute arrival options

#### Scenario: Standard category stays clean
- **WHEN** the user selects a non-emergency category such as Cleaning
- **THEN** no Instant Dispatch section is shown

### Requirement: Search results header controls
The search results screen SHALL present a header row containing: a back navigation chevron button, a text input bar displaying the active search keyword, a micro-location selector pill reflecting the user's active location, and a filter actions row for sorting/layout preferences. The location pill SHALL open the location selection surface when tapped.

#### Scenario: Header composition
- **WHEN** the user lands on search results from a category or search action
- **THEN** all four header elements are visible with the keyword pre-filled in the input

#### Scenario: Location pill interaction
- **WHEN** the user taps the micro-location pill
- **THEN** the location selection surface opens and a confirmed choice updates the pill label

### Requirement: Search result card anatomy
Each search result SHALL render as a vertical-feed card featuring: an oversized square provider/workplace image showcase; the provider name accompanied by a verified checkmark badge when verification is known; distance sub-text in the form "1.2 km away"; an aggregate star-rating badge; a multi-line experience/service description; an explicit "Starting Fee" price tag; and a solid royal-blue "Book Now" button launching booking for that listing.

#### Scenario: Card anatomy complete
- **WHEN** a result card renders for a provider with rating, distance, and description data
- **THEN** every anatomy element above is visible with Book Now as the solid primary action

#### Scenario: Book Now launches booking
- **WHEN** the user taps Book Now on a card
- **THEN** the confirm-booking flow opens bound to that listing

### Requirement: Checkout progress spine
The confirm-booking flow SHALL display a progress line tracker mapping the client's movement through the checkout sequence, plus a functional back control that returns to the previous step without losing entered state.

#### Scenario: Progress reflects position
- **WHEN** the client advances or steps back through checkout
- **THEN** the tracker highlights the current step and back preserves prior entries

### Requirement: Specialist profile summary row
Checkout SHALL embed an inline summary card of the selected specialist showing their professional avatar, verified status badge, name, review ratings summary, and an active proximity marker (distance), when provider data is available for the selected listing.

#### Scenario: Summary reflects selection
- **WHEN** the client reaches confirm-booking for a listing with provider info
- **THEN** avatar, verified badge, name, rating summary, and distance appear in one inline card

### Requirement: Service selection matrix
Checkout SHALL render selectable service rows — each a checkbox row pairing the service name with its exact pricing tag; rows belonging to high-urgency selections SHALL carry an explicit "FASTEST" tag container. Selected rows contribute to the sticky total.

#### Scenario: Matrix selection drives total
- **WHEN** the user checks and unchecks service rows
- **THEN** the sticky pricing total updates to the sum of exact selected prices and FASTEST-tagged urgent rows remain visibly distinguished

### Requirement: Location context widget
Checkout SHALL include a multi-line location card stating the active delivery address, an inline "CHANGE" text trigger opening address selection, and a secondary optional text input labeled "Bldg / Room No., Floor or Landmarks (Optional)" whose value persists with the booking notes.

#### Scenario: Address change and landmark capture
- **WHEN** the user taps CHANGE and confirms a new address
- **THEN** the card updates, and text entered in the landmarks field is carried into the created booking's notes context

### Requirement: Require Arrival Code toggle
Checkout SHALL feature an isolated configuration row labeled "Require Arrival Code" with an info icon hint explaining the protection and a right-aligned switch; the chosen preference SHALL persist into the booking draft.

#### Scenario: Toggle persists preference
- **WHEN** the user toggles Require Arrival Code and completes the booking
- **THEN** the preference is recorded with the booking request

### Requirement: Dual-layer payment matrix
Payment selection SHALL present Tier 1 as two segmented paths — Cash and Digital; selecting Digital SHALL reveal a nested horizontal carousel or grouped sub-grid of four options — GCash, Maya, Card, QR Ph — each with a distinct payment glyph; exactly one payment method SHALL be active at confirmation time.

#### Scenario: Digital reveals nested options
- **WHEN** the user selects the Digital tier
- **THEN** the GCash/Maya/Card/QR Ph sub-options become visible and selectable with glyphs

#### Scenario: Single active method
- **WHEN** the client confirms the booking
- **THEN** precisely one payment method across both tiers is marked active

### Requirement: Sticky pricing footer with adaptive CTA
Checkout SHALL anchor a sticky bottom area displaying "Total Price Due:" with the computed amount beside a full-width solid royal-blue CTA whose label adapts to context using the pattern "Book {Category} Now →"; activating it submits the booking through the selected payment path.

#### Scenario: Adaptive CTA label
- **WHEN** the selected category is Locksmith
- **THEN** the CTA reads "Book Locksmith Now →"

#### Scenario: Submission uses chosen method
- **WHEN** the user activates the CTA
- **THEN** the booking submits with the active payment method and current total
