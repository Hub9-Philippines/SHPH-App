## 1. API and State Foundation

- [x] 1.1 Audit the existing Flutter booking funnel against the Vue reference and map every current step, route/provider scope, API call, response field, and state transition.
- [x] 1.2 Extend `BookingDraft` and its update methods to retain schedule, address/landmarks, scope, service level, arrival-code preference, payment preference, and authoritative booking references without losing existing callers.
- [x] 1.3 Add a shared tolerant numeric normalization seam for API values that may arrive as numbers, numeric strings, null, or invalid strings, and cover representative booking/estimate fields.
- [x] 1.4 Add server-authoritative estimate state to the booking controller/repository boundary, including loading, success, invalid response, retry, and stale-response protection when timing changes.
- [x] 1.5 Refactor live and scheduled request construction so both paths share listing, schedule, address, notes, and preference serialization while retaining distinct API submission behavior.

## 2. Funnel Interaction and UI Redesign

- [x] 2.1 Rebuild the booking funnel shell with a compact mobile step spine, explicit back behavior, safe-area-aware sticky primary actions, and preserved controller scope across routes.
- [x] 2.2 Redesign the service/location step with a clear selected-service summary, address state, edit/retry actions, loading state, and validation before continuation.
- [x] 2.3 Redesign the timing step for immediate, later-today, and scheduled choices with valid date/time selection, future-date validation, and preserved draft state.
- [x] 2.4 Redesign the details step for quantity/scope, service level, landmarks, and arrival-code preference with accessible controls and clear validation.
- [x] 2.5 Redesign the review step around the server estimate, request summary, payment preference, edit affordances, estimate loading/error states, and duplicate-submit prevention.
- [x] 2.6 Update live matching and scheduled success states to show only authoritative booking/job identifiers and returned metadata, with truthful pending, timeout, retry, and next-action states.

## 3. Recovery, Localization, and Compatibility

- [x] 3.1 Preserve the current booking route transitions and controller injection contracts while migrating each funnel screen, including address/date-time modal return paths.
- [x] 3.2 Replace booking-flow hardcoded user-facing copy introduced or changed by the redesign with `AppLocalizations` keys in English and Filipino.
- [x] 3.3 Ensure failed listing, estimate, address, booking, and matching requests preserve the draft and expose localized retry/back recovery rather than crashing or clearing input.
- [x] 3.4 Remove or isolate any local price formula shown to users so only server-returned estimates are presented as authoritative.

## 4. Tests and Verification

- [x] 4.1 Add controller/repository tests for draft persistence, timing resolution, address/landmark serialization, arrival-code preference, live/reservation path selection, and duplicate-submit guards.
- [x] 4.2 Add API-shape tests for numeric and numeric-string estimate/booking fields, missing optional metadata, malformed responses, and recoverable errors.
- [x] 4.3 Add focused widget tests for step progression/back navigation, validation gates, review updates, estimate loading/error states, matching timeout, and scheduled success.
- [x] 4.4 Run the focused booking tests and `flutter analyze`, then fix all new errors while documenting accepted baseline info diagnostics.
- [x] 4.5 Run an Android debug smoke test through service selection, immediate booking, scheduled booking, estimate failure/retry, and back-navigation state preservation.
