## Context

See proposal.md for motivation. The Flutter implementation currently spans `BookingFlowController`, `BookingDraft`, `ShphBookingRepository`, setup, checkout, live matching, and success screens. The Vue reference in `E:\Dev\shph-web` demonstrates the intended API semantics: a reactive multi-step draft, server-side estimate loading, schedule resolution, booking creation with address context, and distinct live/reservation outcomes. Its Ionic layout is not a visual reference for this change.

## Goals / Non-Goals

**Goals:**

- Make one controller-owned draft the source of truth across all booking screens.
- Separate user-editable request state from server-derived quote, submission, matching, and error state.
- Use the API's estimate and booking responses as authoritative and normalize numeric/string response variants at the boundary.
- Make all asynchronous states recoverable and preserve the draft across route/modal transitions.
- Establish a mobile-first visual system using existing theme tokens and shared components, with a compact step spine, clear review surface, and sticky action area.
- Keep live/on-demand and scheduled reservation paths explicit while sharing common request construction and response normalization.

**Non-Goals:**

- Copying Vue/Ionic component structure, CSS, or visual styling.
- Changing backend endpoints or introducing a second booking API.
- Rebuilding unrelated booking history, tracking, provider, or payment-after-accept screens.
- Adding client-side price formulas that compete with server estimates.
- Supporting offline booking submission.

## Decisions

- **Controller-owned immutable draft:** Keep the existing `ChangeNotifier` flow boundary but make draft updates explicit and centralized. This is lower risk than introducing a new state-management framework and avoids duplicating state across setup, checkout, and matching routes. A route-local form model was rejected because it loses data when navigating backward or closing a modal.
- **Server estimate before confirmation:** Add an estimate request at the controller/repository boundary and store a nullable quote with loading/error state. The existing local adjustment formula remains useful only as a transitional comparison during implementation and must not be shown as the authoritative total. A client-only estimate was rejected because the web reference documents a mismatch between calculated and charged totals.
- **Boundary normalization:** Convert numeric fields through one tolerant parser accepting `num`, numeric strings, null, and invalid values. This prevents the observed `String`-to-`num?` crash and keeps UI code typed. Scattered casts in widgets were rejected because they repeat the same API-shape risk.
- **Shared request builder with distinct submit modes:** Build common listing, schedule, address, notes, and preference data once, then route immediate/later-today requests through live dispatch and scheduled requests through reservation. This preserves backend semantics while preventing the two paths from drifting.
- **Mobile-first step shell:** Keep the flow as navigable screens/routes with a compact progress spine, a single primary action per step, bottom-safe sticky actions, and summary cards. This gives the mobile flow its own design instead of mirroring the web's desktop/Ionic composition.
- **Truthful matching/success states:** Render only identifiers and metadata returned by the API; represent unavailable values as pending/unknown states. Fabricated provider counts, fee ranges, or booking IDs are explicitly excluded.
- **Focused test seams:** Inject the existing `BookingRepository` interface for controller tests, add response-normalization tests, and use widget tests for step persistence, validation, review, and recovery. Full end-to-end API tests remain outside unit/widget scope.

## Risks / Trade-offs

- [Risk] Adding a server estimate request can make the review step feel slower. -> Mitigation: use a skeleton breakdown, disable only confirmation, and preserve all entered values while retrying.
- [Risk] Existing backend responses vary between numeric and string representations. -> Mitigation: normalize at API/repository boundaries and cover representative string payloads in tests.
- [Risk] Changing the flow shell may break existing route transitions or controller provider scope. -> Mitigation: preserve the current controller injection pattern, migrate one step at a time, and retain focused booking funnel tests.
- [Risk] Live matching metadata may be absent on partial backend responses. -> Mitigation: show explicit pending/unknown states and never invent values.
- [Risk] Existing payment wording may imply payment at booking time. -> Mitigation: align review/success copy with the backend's deferred payment behavior and keep payment preference separate from charge completion.

## Migration Plan

1. Add typed quote and normalization seams while preserving the current repository interface.
2. Update draft/request construction and controller transitions with focused tests.
3. Rebuild setup, checkout/review, matching, and success surfaces around the shared state.
4. Run booking funnel tests, API-shape tests, static analysis, and an Android debug smoke test through immediate and scheduled paths.
5. Roll back by restoring the prior funnel screen composition; no database migration is required.
