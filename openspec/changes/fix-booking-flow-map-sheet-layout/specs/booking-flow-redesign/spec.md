## REMOVED Requirements

### Requirement: Booking setup map bounded by bottom sheet
**Reason**: This requirement mandated that the map SHALL NOT render behind or below the bottom sheet, which is the opposite of the intended full-bleed treatment. Bounding the map to the top edge of the sheet is what produces the empty background band whenever the sheet is shorter than its maximum height budget, and it contradicts the full-bleed map canvas already required by `map-tracking-screen`.
**Migration**: Replaced by "Booking setup map is adaptive and full-bleed" below. Clients that depended on the map being clipped at the sheet's top edge now get a map that extends behind the sheet; no data, API, or routing contract changes.

## ADDED Requirements

### Requirement: Booking setup map is adaptive and full-bleed
On the booking setup/checkout screen showing the map together with the bottom sheet that advances through Services / Location / Payment, the map SHALL render full-bleed, extending edge-to-edge and behind the entire bottom sheet, with no background, gutter, or gap between the map's lower region and the sheet's top edge. The map's camera padding SHALL be derived from the bottom sheet's measured height for the currently displayed step rather than a fixed constant, and the selected-location pin SHALL remain framed within the map region visible above the sheet.

#### Scenario: Map extends behind the sheet

- **WHEN** the booking setup/checkout screen renders with the Services / Location / Payment bottom sheet open
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
