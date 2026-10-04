## ADDED Requirements

### Requirement: Filled action buttons render theme-contrast labels
Buttons rendered with a filled background from the theme palette (primary, secondary, action, or success colors) SHALL display their label text using the theme's on-primary contrast color token in both light and dark modes. Theme text tokens that resolve to the primary text color SHALL NOT be applied as the label style over a filled background without an explicit contrast color.

#### Scenario: Filled button in light mode
- **WHEN** the app renders a filled primary action button while the theme is in light mode
- **THEN** the button label uses the light on-primary contrast color rather than the near-black primary text color, keeping the label legible against the filled background

#### Scenario: Filled button in dark mode
- **WHEN** the same filled button renders while the theme is in dark mode
- **THEN** the label continues to use the on-primary contrast token and remains legible
