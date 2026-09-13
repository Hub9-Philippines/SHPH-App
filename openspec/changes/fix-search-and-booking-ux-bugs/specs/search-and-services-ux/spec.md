## Purpose

Defines the user-facing behavior of the search page and services listing page, and the booking-flow estimate contract, ensuring the search bar and empty-state match the redesigned home experience, the location pill and "Book Now" CTA behave without crashes or illegible text, and estimates always submit a valid `listing_id`.

## ADDED Requirements

### Requirement: Search bar matches home pill
The search page SHALL render its search entry control with the same visual language as the home screen's search pill: a compact soft-height input with a 16-unit corner radius, light drop shadow only (no hard border), and a white surface fill, contrasting with the services listing background. It SHALL remain a functional editable input.

#### Scenario: Search bar renders consistently
- **WHEN** the user opens the search page
- **THEN** the search bar shows a white rounded pill (16-unit radius, shadow-only edge, no hard border) visually consistent with the home screen pill rather than a hard-bordered 24-unit-radius field

#### Scenario: Search input works
- **WHEN** the user taps the search bar and types a term
- **THEN** the text is accepted and submitting it opens search results for that term

### Requirement: Location pill opens selection without crashing
Tapping the location control on the services listing page SHALL open the location selection surface bound to the current context. It SHALL NOT throw a runtime type-cast error when the selection type is not supplied.

#### Scenario: Location selection opens
- **WHEN** the user taps the location button on the services listing page
- **THEN** the location selection surface opens without error and a confirmed choice updates the displayed location

### Requirement: CTA text is legible
All solid action buttons across the search and services listing surfaces ("Book Now" on the listing page and any filled buttons in the search empty state) SHALL render their label in a legible contrasting foreground (white on the royal-blue action fill) rather than appearing as a bordered button with no visible text.

#### Scenario: Book Now label visible
- **WHEN** the "Book Now" button renders on the services listing page
- **THEN** its text displays in white on the blue action fill with full contrast in both light and dark mode

#### Scenario: Empty-state buttons labeled
- **WHEN** the search empty state renders
- **THEN** both action buttons (the "Clear filters" button and the adjacent secondary button) display their text legibly instead of showing only a border

### Requirement: Estimate request always sends listing_id
The booking flow SHALL include the selected listing's identifier in every estimate request payload, including on the first step and on retries, so the estimate endpoint never rejects the request for a missing `listing_id`.

#### Scenario: Initial estimate succeeds
- **WHEN** the user reaches the first booking-flow step with a listing selected and requests an estimate
- **THEN** the request includes `listing_id` and returns an estimate instead of a `400 {"detail":"listing_id is required."}` error

#### Scenario: Estimate retry succeeds
- **WHEN** the user retries the estimate on the first step
- **THEN** the retry also carries `listing_id` and returns an estimate without a missing-field error

### Requirement: Map is not cropped on booking status
On the booking status map screen, the map canvas SHALL extend to the bottom sheet without a large vertical gap or cropping between the map and the bottom sheet, so the full visible map area is usable and the sheet sits directly against the map.

#### Scenario: No gap between map and sheet
- **WHEN** the booking status map screen renders
- **THEN** the map fills the region above the bottom sheet with no oversized empty band separating them
