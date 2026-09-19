# booking-flow-redesign Specification (Delta)

## ADDED Requirements

### Requirement: Booking setup map bounded by bottom sheet
On the booking setup/checkout screen showing the map together with the bottom sheet that advances through Services / Location / Payment, the map SHALL occupy the area from the top of the screen down to the top edge of the bottom sheet. The map SHALL NOT render behind or below the bottom sheet, and the selected-location pin SHALL remain centered in the visible map area.

#### Scenario: Map does not extend behind the sheet
- **WHEN** the booking setup/checkout screen renders with the Services / Location / Payment bottom sheet open
- **THEN** the map's visible bottom boundary is the top edge of the sheet and no map area is hidden behind or below it

#### Scenario: Pin stays centered
- **WHEN** the map is bounded by the bottom sheet
- **THEN** the selected-location pin remains centered within the visible portion of the map