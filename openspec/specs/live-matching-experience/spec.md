# live-matching-experience Specification

## Purpose

Provides a fluid, interactive live matching and provider dispatch experience featuring draggable multi-extent bottom sheets, dynamic map recentering, in-sheet tipping, comprehensive booking summary details, and seamless background search persistence with one-tap home screen restoration.

## Requirements

### Requirement: Draggable bottom sheet with three snap extents
The live matching screen SHALL present a draggable bottom sheet supporting three distinct viewport extents: minimized banner mode at approximately 0.15 of screen height, standard matching overview at 0.45 of screen height, and expanded detail view at 0.85 of screen height. The sheet SHALL support continuous vertical drag gestures, smooth inner content scrolling, and snapping to these key extents upon gesture release.

#### Scenario: Sheet drags to minimized extent
- **WHEN** the client drags the bottom sheet down to the minimized threshold (0.15)
- **THEN** the sheet collapses into a compact status banner displaying matching progress while maximizing visible map area

#### Scenario: Sheet drags to expanded extent
- **WHEN** the client drags the sheet upward past the standard threshold toward 0.85
- **THEN** the sheet expands smoothly to reveal the full booking summary, tip incentive section, and action controls

#### Scenario: Momentum release snaps to closest extent
- **WHEN** the client releases a drag gesture near any of the snap points (0.15, 0.45, or 0.85)
- **THEN** the sheet animates smoothly to rest at that snap extent without visual stutter

### Requirement: Dynamic map viewport re-centering during sheet gestures
As the bottom sheet is dragged vertically, the system SHALL dynamically adjust the map viewport padding so that the client's service location pin and active radar ripple effect remain vertically centered in the visible upper portion of the screen above the sheet. The radar ripple effect SHALL remain strictly glued to the pinned service location's map projection at all times during drag gestures, adjusting synchronously with the native Google Map camera rather than shifting ahead of the map.

#### Scenario: Sheet drag dynamically offsets map padding
- **WHEN** the client drags the bottom sheet up or down
- **THEN** the map's bottom padding updates in real-time proportional to the sheet's current height, shifting the visible camera center upward or downward accordingly

#### Scenario: Service pin and radar ripple stay centered
- **WHEN** the bottom sheet rests at either the minimized (0.15), standard (0.45), or expanded (0.85) extent
- **THEN** the client's service location pin and surrounding pulsing radar scan are visibly centered within the unobstructed map area above the sheet

#### Scenario: Ripple effect remains glued to map pin during drag gestures
- **WHEN** the client drags the bottom modal sheet continuously between extents
- **THEN** the radar ripple origin remains anchored precisely to the location marker on screen and does not move ahead of or independently from the native Google Map

### Requirement: In-sheet tipping and provider incentive selection
The live matching bottom sheet SHALL present a dedicated tip and incentive card with the title "Add a tip; 100% goes to the provider", horizontal selectable choice chips for preset amounts (₱25.00, ₱50.00, ₱100.00) and a Custom amount option, alongside a full-width "Submit tip" action button.

#### Scenario: Client selects preset tip chip
- **WHEN** the client taps a preset tip chip (such as ₱50.00)
- **THEN** the chip highlights as selected and the "Submit tip" button activates

#### Scenario: Client submits tip
- **WHEN** the client taps "Submit tip" with an active tip selection
- **THEN** the system applies the tip to the active booking request, updates the total estimate display, and provides confirmation feedback

### Requirement: Structured booking details breakdown
Inside the expanded sheet, the system SHALL display structured booking tiles including: the client's service location address marked with a blue indicator, the target service listing or category marked with a red indicator, the active payment method showing card brand and masked account number or e-wallet name, and the total fare/fee price breakdown.

#### Scenario: Expanded sheet displays full booking context
- **WHEN** the client expands the bottom sheet to standard or expanded extents
- **THEN** the service address, target service category, selected payment method, and price breakdown are visibly rendered in clear structured rows

### Requirement: Minimization and cancellation controls
The live matching screen SHALL provide a top-left chevron down control to minimize the sheet or navigate back, and a secondary action button to cancel the search. Minimization or back navigation from the live matching screen SHALL navigate directly to the Home screen, clearing the preceding booking screens from the navigation stack while maintaining the active dispatch job and search timer in the background. Cancellation SHALL require confirmation before halting the search and returning to Home.

#### Scenario: Client taps top-left minimize control
- **WHEN** the client taps the top-left chevron down button
- **THEN** the screen navigates directly to the Home screen, bypassing and clearing previous booking funnel screens, while maintaining the active dispatch job and search timer in the background

#### Scenario: Client presses back button during live matching
- **WHEN** the client triggers a system back gesture or back button while on the live matching screen
- **THEN** the app navigates directly to the Home screen instead of exposing the prior checkout or service setup screen, keeping the search running in the background

#### Scenario: Client initiates search cancellation
- **WHEN** the client taps the "Cancel Booking" button
- **THEN** a confirmation dialog appears warning that the provider search will be terminated

#### Scenario: Client confirms cancellation
- **WHEN** the client confirms cancellation in the dialog
- **THEN** the system halts the search request, stops radar animations, cancels on-demand broadcast on the backend, and safely returns to the Home screen

### Requirement: Persistent background dispatch and home restoration banner
When an active live matching search is minimized or the user returns to the Home screen, the system SHALL maintain active search progress in a background controller. The Home screen SHALL render a floating bottom status pill displaying "Finding a provider..." with a pulsing icon, which restores the live matching screen when tapped.

#### Scenario: Active search persists when navigating to Home
- **WHEN** a provider search is actively running and the user navigates to the Home screen
- **THEN** a floating bottom banner appears on the Home screen indicating that a provider search is currently underway

#### Scenario: Tapping home banner restores matching screen
- **WHEN** the user taps the floating "Finding a provider..." banner on Home
- **THEN** the app navigates back to the active live matching screen with the bottom sheet restored at its standard 0.45 extent and radar scan actively pulsing

### Requirement: Active matching session guard against concurrent bookings
When a live matching provider search is currently in progress, the system SHALL prevent the client from initiating another booking until the active search is completed, cancelled, or timed out.

#### Scenario: Client attempts to book while matching is in progress
- **WHEN** an active live matching search is running and the client taps "Book Now" on a service card or service details page
- **THEN** the system displays an advisory dialog informing the client that a search is already active, offering an action to return to the active search or dismiss the dialog

#### Scenario: Client restores active search from guard dialog
- **WHEN** the client taps the view active search action in the collision dialog
- **THEN** the app transitions immediately to the running live matching screen

### Requirement: Web-parity on-demand status polling and laddered radius expansion
The live matching screen SHALL poll the on-demand job status against `/api/services/on-demand/{id}/status/` every 3 seconds, synchronize expiry and radius values, expand radius up to 24km following the shared ladder when unassigned, and present explicit retry, schedule instead, and cancellation options upon search failure.

#### Scenario: Polling detects accepted provider
- **WHEN** polling returns status "accepted" with an assigned booking ID
- **THEN** live matching terminates polling, stops radar scan animations, and transitions to the confirmed booking details view

#### Scenario: Radius auto-expands on ladder interval
- **WHEN** the search remains unassigned across the 30-second interval
- **THEN** the client requests radius expansion via the on-demand API up to the 24km ceiling and updates the map bounds accordingly

#### Scenario: Broadcast search expires or fails
- **WHEN** polling returns status "expired" or "cancelled" or matching reaches timeout
- **THEN** the screen displays failure recovery controls offering "Search Again", "Schedule Instead", and "Cancel Search"
