## Purpose

Defines how the "finding nearby providers" screens present search progress: a smooth progress indicator instead of a numeric countdown timer, on both the booking-funnel live-matching screen and the TM-flow broadcast screen.

## ADDED Requirements

### Requirement: No numeric countdown on proximity search screens
While a proximity search is running, the system SHALL NOT display any numeric countdown text (e.g. "Xs", "179s", "seconds remaining") on the booking live-matching screen or the TM broadcast screen. The only progress feedback SHALL be a progress bar/indicator.

#### Scenario: Search in progress on booking live-matching screen
- **WHEN** the booking live-matching screen is searching and the countdown is decrementing
- **THEN** no `seconds remaining` numeric text appears anywhere on the screen, and the progress indicator advances

#### Scenario: Search in progress on TM broadcast screen
- **WHEN** the TM broadcast screen is broadcasting and the search timer is ticking
- **THEN** no `Ns` countdown text appears in the status card, and the progress indicator advances

#### Scenario: Timeout still enforced after timer text removed
- **WHEN** the search window reaches zero seconds
- **THEN** the screen still transitions to the timed-out/failed state exactly as before, with no numeric text shown

### Requirement: Smooth progress indicator
The progress indicator on both proximity search screens SHALL advance smoothly at display frequency (no visible 1-second step jumps caused by countdown setState notifications).

#### Scenario: Progress advances between whole seconds
- **WHEN** the search window has advanced by, e.g., 100 ms within the current second
- **THEN** the indicator reflects the fractional progress value rather than snapping to the last whole-second boundary

#### Scenario: Progress indicator reaches full width at window end
- **WHEN** the search window completes
- **THEN** the indicator has reached its full extent (100 %) before the timed-out UI replaces the searching UI

### Requirement: Backend search-window semantics preserved
Removing the visible timer SHALL NOT change the underlying search window behavior (180-second window on booking live matching, radius-ladder expansion rungs, expiry-based countdown sync).

#### Scenario: Expiry sync still clamps remaining time
- **WHEN** a live job response carries a server `expires_at` that differs from the local estimate
- **THEN** the internal remaining-time accounting is still synced to the server value even though no number is rendered