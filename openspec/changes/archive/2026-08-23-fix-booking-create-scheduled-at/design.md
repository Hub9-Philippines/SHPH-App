## Context

Evidence chain from exploration:

- `SHPH API.yaml` `BookingRequest`: only documented-required field is `listing`; `scheduled_date`/`scheduled_time`/`scheduled_at` are all listed nullable/optional — but this understates the deployed serializer.
- Live parity evidence (`E:\Dev\shph-web\src\views\services\BookingPaymentPage.vue`): web always sends `{ listing, scheduled_at, notes, [voucher_code] }` and its catch-handler explicitly reads `e.response?.data?.scheduled_at?.[0]` — the server returns field errors keyed on `scheduled_at`.
- Flutter sends `listing`, `scheduled_date`, `scheduled_time`, `notes`, `total_price` (`lib/api/models/booking.dart:64`) → 400 "This field is required".
- No address field exists on create; response `Booking.client_address` is readOnly and derived by the server from `/api/profiles/addresses/`.
- The Express code in `backend/` does not implement bookings; the live API is the DRF service the yaml documents.

Call sites that build bookings today:
1. `lib/pages/booking_funnel/booking_repository.dart` → `ShphBookingsApi.createBooking` directly (resolves its own DateTime).
2. `lib/services/bookings_service.dart::createBooking` ← used by `lib/pages/booking_payment/booking_payment_widget.dart` (4 variants), `dispatch_repository.dart`, `tm_repository.dart`.

## Goals / Non-Goals

**Goals:**
- Every booking-create request carries a correct `scheduled_at`.
- One canonical place resolves date+time+urgency → DateTime.
- Payload matches the observed-live contract (no readOnly keys).
- Server field errors reach the user.

**Non-Goals:**
- Payment/escrow state sync (`paymentStatus` param remains client-only; documented as follow-up — the documented create contract has nowhere to put it).
- Voucher support (web has it; needs product decision + estimate endpoint work).
- Structured address on bookings (server-owned via profile addresses).
- Any UI redesign (tracked separately in `redesign-booking-lifecycle-ui`).

## Decisions

1. **Send `scheduled_at` in addition to `scheduled_date`/`scheduled_time`.** Mirrors the working web client's key field while keeping existing splits for any legacy consumers. Alternative (splits only) is what already fails. Cost: one redundant-but-harmless field pair the server accepts.
2. **Single `DateTime scheduledAt` parameter** through `ShphBookingsApi.createBooking` and `BookingsService.createBooking`; callers pass their resolved DateTime instead of separate date/time strings. The funnel repository's `_resolveScheduledDateTime` stays the single resolver for the funnel; dispatch/TM keep using `DateTime.now()`-based values they already compute.
3. **Drop `total_price` from the create payload.** It is readOnly in both `Booking` and absent from `BookingRequest`; DRF ignores it today. Removing prevents false confidence that client-side totals are persisted (server computes `fee_breakdown` itself). Callers may still pass estimates into notes if needed later.
4. **Parse `client_address` (+ `service_lat/service_lng` while touching fromJson) into `ShphBooking`.** Zero-risk additive mapping enabling the tracking redesign to show real addresses later.
5. **Error surfacing:** `BookingsService.createBooking` currently returns `null` on any failure after logging; funnel rethrows raw exceptions. Keep signatures stable but ensure `lastError`/snackbar text includes `ShphApiException.message` when present (the exception extractor already unwraps DRF bodies — no parser changes needed).

## Risks / Trade-offs

- [Yaml/spec drift: maybe server also demands something else tomorrow] → Fix targets the empirically confirmed missing field only; error-surfacing requirement makes any future rejection self-explanatory instead of silent 400s.
- [Redundant schedule fields could diverge] → All three derive from the same `DateTime` at one call site per flow; document in `toCreateJson`.
- [Removing total_price changes nothing server-side but callers may expect it echoed] → Response `total_price` is parsed already; no caller reads the request echo.

## Migration Plan

Pure client change, single PR: model → api → service → call sites, compile-ordered. Rollback = revert commit. No data migration; previously failed bookings simply never existed server-side.

## Open Questions

None blocking. Vouchers and escrow-status persistence are deliberate non-goals pending product input.
