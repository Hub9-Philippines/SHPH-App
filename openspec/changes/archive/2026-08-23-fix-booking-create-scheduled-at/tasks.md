## 1. API model & client

- [x] 1.1 Add `scheduledAt` ISO-8601 output to `ShphBooking.toCreateJson` (derived from a required `DateTime scheduledAt` param; keep `scheduled_date`/`scheduled_time` splits emitted from the same value) and remove `total_price` from the payload
- [x] 1.2 Change `ShphBookingsApi.createBooking` signature to accept `required DateTime scheduledAt` (+ optional `notes`) and drop `totalPrice`
- [x] 1.3 Extend `ShphBooking.fromJson` with `clientAddress` (`client_address`) and `serviceLat`/`serviceLng` parsing

## 2. Service layer

- [x] 2.1 Update `BookingsService.createBooking` to take `required DateTime bookingDateTime`, forward it as `scheduledAt`, and stop passing `totalPrice`; keep the `paymentStatus` param but mark deprecated-in-docs (client-only, no server target)

## 3. Call sites

- [x] 3.1 `booking_funnel/booking_repository.dart`: pass `_resolveScheduledDateTime(draft)` result directly as `scheduledAt`; delete manual date/time string formatting
- [x] 3.2 `dispatch_repository.dart` + `tm_repository.dart`: replace `bookingDate`/`bookingTime` pair with single DateTime argument
- [x] 3.3 `booking_payment_widget.dart`: pass `DateTime.parse(widget.bookingDate!)` (with time-of-day from `widget.bookingTime` merged) as the single DateTime in all four branches

## 4. Error surfacing

- [x] 4.1 Payment screen catch path: include `ShphApiException.message` in `_model.errorMessage` when the thrown object is one, instead of bare `Error: ...`
- [x] 4.2 Funnel: confirm `lastError = e.toString()` already surfaces the field message to checkout UI; adjust copy only if it hides the server detail

## 5. Verification

- [x] 5.1 Manual confirm run: funnel ASAP + scheduled paths and payment-screen cash path all create bookings without 400; created bookings appear on Bookings tab
- [x] 5.2 Verify response mapping: booking detail shows server `client_address` when present
- [x] 5.3 `flutter analyze` — 0 errors; `flutter test test/booking_funnel_test.dart` — no new failures
