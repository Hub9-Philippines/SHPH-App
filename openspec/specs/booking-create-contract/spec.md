## Purpose

Defines how the client creates bookings against `POST /api/services/bookings/`: which fields are mandatory for the deployed serializer to accept the request, and which response fields the client must surface so downstream screens show accurate booking data.

### Requirement: Booking creation sends scheduled_at
The client SHALL include a `scheduled_at` ISO-8601 datetime in every create-booking request payload, resolved from the user's chosen date/time (or urgency default), because the deployed API rejects payloads without it.

#### Scenario: Confirming a scheduled booking
- **WHEN** the user confirms a booking with a chosen date and time
- **THEN** the create payload contains `scheduled_at` as a full ISO-8601 datetime matching that choice

#### Scenario: Confirming an ASAP booking
- **WHEN** the user confirms an immediate booking without an explicit time
- **THEN** the client resolves a near-term datetime (existing urgency defaults) and still sends `scheduled_at`

### Requirement: Create payload matches server contract
The client SHALL NOT send fields the create contract defines as read-only or unknown (currently `total_price`), and SHALL keep the address out of structured create fields — the service location is attached by the server from the profile's saved addresses, with any user-typed context confined to free-text notes.

#### Scenario: Payload contents
- **WHEN** a create-booking request is built
- **THEN** it carries `listing`, `scheduled_at`, and optional `notes` only (plus documented optional schedule splits if kept), with no `total_price` key

### Requirement: Failed creation surfaces actionable errors
When the create call returns 400, the client SHALL surface the server's field error message to the UI rather than a generic failure string.

#### Scenario: Server rejects payload
- **WHEN** the API responds 400 with a field-error body
- **THEN** the visible error includes the server's message (e.g. naming the missing/invalid field) instead of "Failed to create booking"

### Requirement: Response address is mapped
The client SHALL parse the response's readOnly `client_address` field into the booking model so booking-detail and tracking screens can display the server-derived service address when present.

#### Scenario: Booking detail shows service address
- **WHEN** a created/retrieved booking includes a non-empty `client_address`
- **THEN** the booking model exposes it and detail surfaces prefer it over notes-derived text
