## ADDED Requirements

### Requirement: Ripple center tracks the pinned marker across viewport changes
While the scan ripple is displayed, the ripple's center SHALL coincide with the pinned marker's anchor position in screen coordinates, and SHALL be re-synchronized whenever the map camera moves, becomes idle, or the map's inset padding changes (for example when a bottom sheet changes extent). The padded visible-band center SHALL be used as a fallback only when the map cannot project the pinned coordinate.

#### Scenario: Sheet padding changes the map viewport
- **WHEN** a bottom sheet changes extent and the map's inset padding changes
- **THEN** the ripple center is recomputed after the layout settles and coincides with the pinned marker's screen position rather than a stale viewport center

#### Scenario: Camera fit animation completes
- **WHEN** the map camera finishes framing the scan radius around the pinned location
- **THEN** the ripple center follows the pinned marker to its new screen position

#### Scenario: Projection is unavailable
- **WHEN** the map cannot project the pinned coordinate to screen coordinates
- **THEN** the ripple falls back to the center of the padded visible map area
