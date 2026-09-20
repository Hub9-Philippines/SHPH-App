# map-scan-radius-effect Specification

## Purpose

Defines how the map radar scan ripple communicates the live provider-search radius, so the visible ripple matches the radius the backend endpoint is scanning and the map is framed to show that radius.

## Requirements

### Requirement: Ripple extent matches the current scan radius

While a provider search is active, the map SHALL render a looping radar scan ripple anchored at the pinned location whose outermost ring reaches the radius currently being scanned by the API endpoint (the `radius_km` value for the on-demand job; 4 km at start, widening to 24 km). When the scan radius changes, the ripple SHALL recompute its geometry so the outermost ring matches the new radius.

#### Scenario: Initial scan radius

- **WHEN** a provider search starts from the pinned location with the API scanning a 4 km radius
- **THEN** the ripple's outermost ring extends to 4 km from the pinned location and loops indefinitely

#### Scenario: Radius widens via the endpoint

- **WHEN** the backend reports a wider scan radius (`radius_km`) such as 8 km
- **THEN** the ripple's outermost ring extends to the updated radius within the same animation cycle

#### Scenario: Ripple extent is capped

- **WHEN** the scan radius exceeds the largest supported value (24 km)
- **THEN** the outermost ring never extends beyond 24 km from the pinned location

### Requirement: No solid center dot under the pin

While the scan ripple is displayed, the map SHALL NOT render a filled circle beneath the pinned-location marker. The pinned location SHALL be indicated only by the location marker itself.

#### Scenario: Searching with the ripple visible

- **WHEN** the map shows the scan ripple centered on the pinned location
- **THEN** no filled solid circle is rendered below or underneath the location marker

### Requirement: Map framing shows the full scan radius

The map camera SHALL be framed so the entire current scan radius (and therefore the full ripple) is visible within the viewport whenever a search is active, and SHALL re-frame when the radius changes. This framing remains the active zoom while searching.

#### Scenario: Search begins

- **WHEN** a provider search starts with a 4 km scan radius
- **THEN** the map is zoomed such that the outer ripple bound (4 km) fits fully inside the visible area

#### Scenario: Radius expands during search

- **WHEN** the scan radius widens to a larger value during the search
- **THEN** the map re-frames to fit the enlarged ripple within the visible area

#### Scenario: Terminal state

- **WHEN** the search leaves the actively-searching state (matched, timed out, or cancelled)
- **THEN** the ripple stops, and the map is not required to keep the scan-radius framing