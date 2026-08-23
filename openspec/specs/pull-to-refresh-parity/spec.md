## Purpose

Makes the Profile page's pull-to-refresh mechanism the single canonical pattern, so Explore and Bookings refresh identically to Profile in every UI state.

### Requirement: Canonical pull-to-refresh pattern
Explore and Bookings SHALL implement pull-to-refresh exactly as the Profile page does: a RefreshIndicator tinted with the theme primary color wrapping a scroll view whose physics are bouncing scroll physics rooted in always-scrollable physics, triggering the screen's reload on pull.

#### Scenario: Refresh gesture matches Profile
- **WHEN** the user pulls down on Explore or Bookings content
- **THEN** the same indicator style, color, physics feel, and reload trigger as the Profile page occur

### Requirement: Refresh available in every state
The Bookings screen SHALL keep the refresh gesture functional in every state — loading skeletons, error, empty, and populated results — not only on the populated list; Explore SHALL retain refresh across its feed states.

#### Scenario: Pull works before data arrives
- **WHEN** the Bookings screen is showing skeleton rows or an error message
- **THEN** pulling down still triggers the refresh flow

### Requirement: No behavioral regression to reloads
Adopting the canonical pattern MUST NOT change what each screen's reload actually does: Explore re-runs its feed load, Bookings re-fetches bookings (and listings), Profile keeps its existing snapshot refresh.

#### Scenario: Reload semantics unchanged
- **WHEN** a pull-to-refresh completes on each of the three screens
- **THEN** the visible data reflects that screen's own reload logic, identical to pre-change behavior
