# emergency-services-picker Specification

## Purpose

Defines the dedicated emergency services modal that the home "Get Help" card opens, listing only emergency-category services and starting urgent booking, so help-seeking users are scoped to relevant services instead of the generic catalog.

## ADDED Requirements

### Requirement: Picker lists only emergency services
The emergency services modal SHALL list only services belonging to the emergency categories (Electrical, Locksmith, Plumbing, Pest Control) and SHALL NOT list any non-emergency service.

#### Scenario: Emergency-only content
- **WHEN** the emergency services modal opens
- **THEN** every listed service belongs to an emergency category and no other services appear

#### Scenario: No emergency services available
- **WHEN** no emergency services can be loaded for the user's area
- **THEN** the modal shows a localized empty state with a way back and does not crash

### Requirement: Selecting a service starts an urgent booking
Selecting an emergency service in the modal SHALL start the booking flow for that service with right-now (immediate) urgency.

#### Scenario: Start urgent booking
- **WHEN** the user selects an emergency service from the modal
- **THEN** the booking flow opens for that service with immediate dispatch

#### Scenario: Booking flow carries the service
- **WHEN** the urgent booking flow opens from the picker
- **THEN** the selected service and its listing context are loaded into the booking draft

### Requirement: Dismissal leaves home intact
Dismissing the emergency services modal SHALL close it without navigating or showing residual overlays, returning the user to the home page.

#### Scenario: Dismiss picker
- **WHEN** the user dismisses the emergency modal
- **THEN** the modal closes and the home page remains visible