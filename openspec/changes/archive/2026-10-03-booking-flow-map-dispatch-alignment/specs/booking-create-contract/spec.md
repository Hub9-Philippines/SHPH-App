## ADDED Requirements

### Requirement: Booking creation routes between on-demand broadcast and scheduled reservation
The client SHALL route booking creation based on the user's selected dispatch mode and schedule urgency:
1. **On-Demand Dispatch**: When the user requests immediate or emergency service, the client SHALL call `POST /api/services/on-demand/` with the category ID, coordinates (`latitude`, `longitude`), and service description/notes, and enter live matching using the returned on-demand `job_id`.
2. **Scheduled Reservation**: When the user selects a scheduled date and time, the client SHALL call `POST /api/bookings/` with the `listing` ID and ISO-8601 `scheduled_at` timestamp, and track the confirmed booking reservation.

#### Scenario: Submitting immediate on-demand job
- **WHEN** the user confirms an on-demand/urgent request
- **THEN** the client calls `/api/services/on-demand/`, stores the returned job identifier, and starts live matching polling on `/api/services/on-demand/{id}/status/`

#### Scenario: Submitting scheduled booking reservation
- **WHEN** the user confirms a scheduled booking
- **THEN** the client calls `/api/bookings/`, stores the returned booking identifier, and transitions to the booking confirmation/scheduled view
