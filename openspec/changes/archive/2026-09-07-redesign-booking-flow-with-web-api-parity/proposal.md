## Why

The current Flutter booking flow has a fragmented, implementation-led experience and derives its displayed estimate locally even though the backend owns booking pricing. The Vue web flow provides a proven API and state-management reference, so the mobile flow should adopt those behavioral contracts while receiving a new mobile-first UI designed for clarity, confidence, and recovery from partial input.

## What Changes

- Redesign the booking funnel as a clear, resumable sequence from service confirmation through location, timing, request details, review/estimate, submission, matching, and success.
- Align Flutter booking requests with the SHPH API behavior used by the web flow, including server-authoritative estimates, normalized numeric response values, address/landmark context, schedule resolution, and booking identifiers.
- Preserve entered state when moving backward, recovering from transient errors, or returning from address/date-time selection.
- Make urgency, schedule, service scope, arrival-code preference, payment preference, and final review explicit and accessible on mobile.
- Improve loading, validation, error, empty, submit, matching, timeout, and success states without copying the Vue/Ionic visual design.
- Add focused controller/repository/widget coverage for state transitions, payloads, estimate handling, and API responses containing numeric strings.

## Capabilities

### New Capabilities

- `booking-flow-redesign`: Defines the mobile booking funnel's user-visible stages, state preservation, server-authoritative pricing, submission, matching, and recovery behavior.

### Modified Capabilities

- None.

## Impact

- Flutter booking funnel screens, controller, draft/quote models, repository, address/date-time selection, payment/review surfaces, live matching, and success routing.
- SHPH REST API integration for estimate, booking creation, on-demand dispatch, and response normalization.
- Existing shared theme/components and booking tests; no new backend dependency is expected.
- The Vue app at `E:\Dev\shph-web` is a behavioral/API reference only; its UI structure and styling will not be copied.
