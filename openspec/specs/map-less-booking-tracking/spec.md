# map-less-booking-tracking Specification

## Purpose

Defines the booking status tracking page behavior without a map: users track the confirmed / en route / on site / in progress / completed lifecycle through a status timeline and provider card, with no map canvas, markers, or route overlays present.

## Requirements

### Requirement: Booking tracking page renders without any map
The booking status page (confirmed → en_route → on_site → in_progress → completed) SHALL NOT include a map canvas, map markers, route polylines, or any map-related UI. Tracking progress SHALL be conveyed by the status timeline and provider info UI alone.

#### Scenario: No map view is constructed
- **WHEN** the booking status page is opened for any booking status
- **THEN** no `GoogleMap` widget is built anywhere on the page and no map handles/controllers are created

#### Scenario: Timeline remains the primary tracking element
- **WHEN** the status page is rendered
- **THEN** the confirmed/en route/on site/in progress/completed stages are visible in a timeline with the active stage highlighted

### Requirement: Real booking status polling unchanged
Removing the map SHALL NOT change how the page obtains status: when a booking reference is provided, the page SHALL keep polling the booking record and update the active timeline stage on status change.

#### Scenario: Status updates reflected in timeline
- **WHEN** the polled booking status changes from `en_route` to `on_site`
- **THEN** the timeline moves the active stage accordingly without a map present

#### Scenario: Provider on-site location still resolved
- **WHEN** a provider moves to on-site/in progress with a service location in the booking record
- **THEN** the page continues to resolve/use that location where provider positioning is needed elsewhere, without rendering a map

### Requirement: Map-free layout uses the full canvas
Without the map, the page SHALL use the freed canvas for the tracking content (timeline, provider card, actions) so the layout reads as a designed tracker rather than empty space left by the removed map.

#### Scenario: Tracking content fills the freed space
- **WHEN** the map is removed
- **THEN** the timeline/provider/action layout expands into the previously map-covered region and no dead empty area remains

### Requirement: No map-related l10n or assets required
The map-less tracking page SHALL not depend on map-related localizations, icons as map placeholders, or map API keys.

#### Scenario: No map assets loaded
- **WHEN** the status page initializes
- **THEN** no map SDK or map-related asset initialization occurs