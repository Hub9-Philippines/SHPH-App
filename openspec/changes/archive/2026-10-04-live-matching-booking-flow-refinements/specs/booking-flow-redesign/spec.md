## MODIFIED Requirements

### Requirement: Booking setup map is adaptive and full-bleed
On the booking setup and booking flow screens showing the map together with the bottom sheet that advances through Services, Location, and Payment stages, the map SHALL render full-bleed, extending edge-to-edge and behind the entire bottom sheet, with no background, gutter, or gap between the map's lower region and the sheet's top edge. The map's camera padding SHALL be derived from the bottom sheet's measured height for the currently displayed step rather than a fixed constant, and the selected-location pin SHALL remain framed and centered within the map region visible above the sheet.

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

## ADDED Requirements

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
