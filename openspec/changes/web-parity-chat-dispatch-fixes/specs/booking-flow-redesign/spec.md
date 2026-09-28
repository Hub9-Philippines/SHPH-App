## MODIFIED Requirements

### Requirement: Matching and success states reflect real booking state
After submission, live matching SHALL show the authoritative booking/job reference and any provider count or fee range returned by the API, distinguish loading, active, timeout, and failure states, and provide a route to tracking or booking details. Scheduled success SHALL show the created booking details and next actions without claiming payment was completed when payment is deferred. When the on-demand broadcast request fails or returns no job reference, the app SHALL surface that failure explicitly (localized failure state with a retry path) instead of silently degrading to a preview-style countdown; the preview/fallback state SHALL be reserved for confirmed transport-level unreachability and SHALL be distinguishable from an active search.

#### Scenario: Matching receives API metadata
- **WHEN** the live/on-demand API returns a job reference or provider metadata
- **THEN** the matching state displays those values and does not fabricate provider counts or identifiers

#### Scenario: Matching times out
- **WHEN** no provider is found within the matching timeout
- **THEN** the app shows a clear retry or alternative action while preserving the created booking reference

#### Scenario: Scheduled booking reaches success
- **WHEN** a scheduled booking is created successfully
- **THEN** the success state displays its real booking reference, schedule, service, and next action while indicating payment timing accurately

#### Scenario: Broadcast fails at submission
- **WHEN** the on-demand broadcast API call fails or returns no job reference while the booking itself was created
- **THEN** the app reports the broadcast failure with a localized message and a retry action, and never presents the failed search as an active preview

#### Scenario: Broadcast succeeds at submission
- **WHEN** the on-demand broadcast API call returns a job reference
- **THEN** live matching polls the real job status and transitions to matched/expired/timeout based on server responses only
