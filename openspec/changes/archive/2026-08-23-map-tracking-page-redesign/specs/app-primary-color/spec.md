## Purpose

Establishes one primary brand color for the entire application — the royal blue used by the Bookings screen's primary actions — replacing the previous light blue in both light and dark modes.

## ADDED Requirements

### Requirement: Royal blue is the single app primary
The application theme SHALL resolve `primary` to the bookings royal blue (#1E3A8A) in both light and dark factories, so every consumer of the theme primary — buttons, links, chips, tints, indicators, refresh controls — renders the same royal blue; the previous light blue (#368EFF) SHALL no longer appear as any theme-driven color.

#### Scenario: Primary resolves consistently
- **WHEN** any screen in light or dark mode renders a theme-primary element (e.g., filled buttons, active nav tint, refresh indicator, link text)
- **THEN** its color equals #1E3A8A or a theme-derived opacity of it, never the former light blue

#### Scenario: Bookings actions remain aligned
- **WHEN** the Bookings screens render their primary action color alongside other app surfaces using theme primary
- **THEN** the two blues are identical, confirming one shared source rather than parallel constants
