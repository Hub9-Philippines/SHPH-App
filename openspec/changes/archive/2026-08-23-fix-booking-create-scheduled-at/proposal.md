## Why

Confirming a booking always fails with `ShphApiException(400): This field is required` — the funnel, payment, dispatch, and TM flows all POST `/api/services/bookings/` without the `scheduled_at` field the deployed serializer requires. The parity web app (`shph-web`) always sends `scheduled_at` and even reads `data.scheduled_at[0]` field errors, confirming the live contract. Users misattribute the failure to their selected address (the create payload has no address field; the server attaches the profile's default address server-side).

## What Changes

- **Fix** `ShphBooking.toCreateJson` to send `scheduled_at` as an ISO-8601 datetime alongside (or in place of) the split `scheduled_date`/`scheduled_time` fields.
- **Rework** `createBooking` signatures end-to-end (`bookings_api.dart` → `bookings_service.dart` → booking-funnel/dispatch/tm repositories) to carry a single resolved `DateTime`.
- **Stop sending** `total_price` on create — it is readOnly per the API spec and silently ignored by the server.
- **Map** the response's readOnly `client_address` into `ShphBooking` so screens can display the real service address instead of parsing notes text.
- **Document** (not fix) that `paymentStatus` passed by callers is currently swallowed client-side: the documented create contract has no payment-status field, so escrow/payment state remains a separate follow-up.

## Capabilities

### New Capabilities
- `booking-create-contract`: The client-to-server contract for creating bookings via `POST /api/services/bookings/` — required fields (`listing`, `scheduled_at`), optional notes, and mapping of server-derived response fields.

### Modified Capabilities

## Impact

- `lib/api/models/booking.dart` (`toCreateJson`, new `clientAddress` parse)
- `lib/api/resources/bookings_api.dart` (`createBooking` signature)
- `lib/services/bookings_service.dart` (`createBooking` signature)
- `lib/pages/booking_funnel/booking_repository.dart`, `lib/pages/dispatch/dispatch_repository.dart`, `lib/pages/tm_flow/tm_repository.dart` (call sites)
- No backend changes; no route changes; UI untouched except error-free confirm flow.
