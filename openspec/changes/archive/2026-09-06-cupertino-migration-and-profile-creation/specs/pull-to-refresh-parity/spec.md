## MODIFIED Requirements

### Requirement: Canonical pull-to-refresh pattern
Explore and Bookings SHALL implement pull-to-refresh exactly as the Profile page does: an iOS-style refresh control tinted with the theme primary color wrapping a scroll view whose physics are bouncing scroll physics rooted in always-scrollable physics, triggering the screen's reload on pull. The per-screen reload logic SHALL remain identical to the previous `RefreshIndicator` behavior.

#### Scenario: Refresh gesture matches Profile
- **WHEN** the user pulls down on Explore or Bookings content
- **THEN** the same iOS indicator style, primary color, physics feel, and reload trigger as the Profile page occur

#### Scenario: Reload semantics unchanged
- **WHEN** a pull-to-refresh completes on each of the three screens
- **THEN** the visible data reflects that screen's own reload logic, identical to pre-change behavior