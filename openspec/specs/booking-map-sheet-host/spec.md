# booking-map-sheet-host Specification

## Purpose

Defines the shared booking-screen layout contract where a map is always drawn full-bleed behind a variable-height bottom sheet, with the map's camera padding derived from the sheet's measured height and current drag extent rather than hardcoded constants.

## Requirements

### Requirement: Booking map renders full-bleed behind the bottom sheet
Any booking screen that shows a map together with a bottom sheet SHALL render the map as a full-bleed background layer that extends edge-to-edge and downward behind the entire bottom sheet, including the region the sheet covers and the region below it to the bottom of the viewport. No background, gutter, or gap SHALL appear between the map's lower region and the top edge of the bottom sheet.

#### Scenario: Sheet is shorter than its maximum height
- **WHEN** a booking screen renders a bottom sheet whose actual height is smaller than the screen's maximum permitted sheet height
- **THEN** the map still fills the entire viewport behind and below the sheet, and no strip of plain background is visible in the area the sheet does not cover

#### Scenario: Sheet grows to maximum height
- **WHEN** a client drags a resizable bottom sheet up to its maximum permitted height
- **THEN** the map remains full-bleed behind the sheet and the covered region is hidden by the sheet's surface rather than by any layout gap

#### Scenario: Visual continuity across the sheet edge
- **WHEN** a client looks at the boundary where the map meets the top edge of the bottom sheet
- **THEN** map imagery continues up to that edge with no discontinuity, blank band, or contrasting background strip

### Requirement: Map camera padding adapts to the bottom sheet's measured height
The map's camera padding SHALL be computed from the bottom sheet's actual measured height for the currently displayed step, so that the map's primary marker is framed within the region of the map left visible above the sheet. When the displayed step swaps to a bottom sheet of a different height, the camera padding SHALL be recomputed to match the new sheet. The system SHALL NOT rely on a fixed constant to approximate the sheet's height.

#### Scenario: Step changes to a taller sheet
- **WHEN** a booking step is replaced by a subsequent step whose bottom panel is taller than the previous one
- **THEN** the map's camera padding increases to match the new panel's measured height and the marker is re-framed within the newly visible region

#### Scenario: Step changes to a shorter sheet
- **WHEN** a booking step is replaced by a subsequent step whose bottom panel is shorter than the previous one
- **THEN** the map's camera padding decreases to match the new panel's measured height, revealing more map and re-framing the marker accordingly

#### Scenario: Marker remains visible above the sheet
- **WHEN** the camera padding has been applied for the current sheet
- **THEN** the primary map marker remains within the portion of the map visible above the bottom sheet and is not obscured by it

#### Scenario: First frame before measurement completes
- **WHEN** a booking screen renders before the bottom sheet's height has been measured
- **THEN** the map renders at full bleed with a conservative padding value and re-frames once the sheet's measured height becomes available, without a visible error state or layout break

### Requirement: Camera padding follows the live extent of a resizable sheet
For a bottom sheet that can be dragged between a minimum and maximum extent, the map's camera padding SHALL track the sheet's current extent as it changes, so the map stays framed correctly while the sheet is being dragged and after the client settles it at a new extent.

#### Scenario: Sheet is dragged to a new extent
- **WHEN** a client drags a resizable bottom sheet and leaves it at a different extent
- **THEN** the map's camera padding reflects that final extent and the marker is framed in the visible region above the sheet

#### Scenario: Sheet settles without a further drag
- **WHEN** a resizable bottom sheet is released and comes to rest
- **THEN** the camera padding matches the resting extent with no further oscillation or repeated re-framing

#### Scenario: Viewport is too short for the sheet content
- **WHEN** the sheet's natural content height exceeds the maximum extent permitted by the viewport
- **THEN** the sheet is capped at its maximum extent, the camera padding is derived from that capped extent, and the sheet's content scrolls inside it

### Requirement: Shared layout is applied consistently across booking map screens
All booking screens that display a map with a bottom sheet SHALL obtain the full-bleed layout and the sheet-derived camera padding from one shared layout mechanism, so that adding or changing a booking step cannot reintroduce per-screen hardcoded map sizing.

#### Scenario: Setup and matching screens agree
- **WHEN** a client moves between the booking setup screen, the checkout and express-checkout screens, and the live matching screen
- **THEN** the map's full-bleed coverage and sheet-derived camera framing are visually consistent across all of those screens

#### Scenario: New step inherits the behavior
- **WHEN** a new booking step is added that presents a map with a bottom sheet using the shared layout mechanism
- **THEN** the new step receives full-bleed map coverage and sheet-derived camera padding without adding any hardcoded map offset of its own

### Requirement: Non-map content and map effects are preserved
The shared layout SHALL NOT change booking behavior that does not depend on map geometry: the absence of a map on map-free tracking screens SHALL be preserved, and map effect layers such as proximity-scan radar ripples SHALL remain centered on the pinned location and SHALL update without rebuilding the surrounding map, markers, or sheet content.

#### Scenario: Map-free screen stays map-free
- **WHEN** a booking screen is configured to present no map
- **THEN** no map surface is constructed and the freed space continues to be used by that screen's tracking content

#### Scenario: Radar ripple stays centered and stays smooth
- **WHEN** a proximity-search radar ripple animates inside the shared layout
- **THEN** the ripple remains centered on the pinned location, scales correctly with the map under zoom and rotation, and animates without rebuilding the surrounding map, markers, or bottom sheet

#### Scenario: Scan-radius framing is preserved
- **WHEN** an active provider search widens its scan radius and the map is re-framed to fit it
- **THEN** the enlarged ripple remains fully inside the visible map region above the bottom sheet
