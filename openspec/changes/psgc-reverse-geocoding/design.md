# Design

## Context

- `lib/pages/pin_location/pin_location_widget.dart` shows a fixed center-pin map; on confirm it pops `{latitude, longitude, address}` where `address` is only present if the user ran a Places search. There is no reverse geocoding anywhere in the app.
- `lib/pages/address_form/address_form_widget.dart` already owns the region → province → city/municipality → barangay cascade backed by `PSGCService` (psgc.gitlab.io), including `_restoreGeographicSelectionFromNames` (name-drill fallback for edit mode) and an NCR-aware path that loads cities directly under a region when the region has no provinces (verified: `/regions/130000000/provinces.json` returns `[]`).
- The save contract (`addressData` at `address_form_widget.dart:365`) sends **name strings** (`barangay`, `city`, `province`, `zip_code`) plus `latitude`/`longitude` — no PSGC codes are persisted, and the server contract is unchanged by this work.
- HTTP goes through the singleton `ShphApiClient` (Dio, 30 s default timeouts, bearer interceptor); resources follow the `Shph*Api.instance` pattern (`lib/api/resources/`), models live in `lib/api/models/` with `fromJson`.
- The resolve endpoint `POST /api/v1/geocode/psgc-resolve` is built first as a separate API change (per `opencode_openspec_psgc.md`); this change only consumes it. See proposal.md for motivation, specs/psgc-geocoding for requirements.

## Goals / Non-Goals

**Goals:**
- Deterministic, single-shot resolution of a confirmed pin into PSGC entities with a confidence gate.
- Reliable cascade auto-fill in the address form driven by PSGC codes first, names second.
- Zero regressions when resolution is unavailable: manual selection must behave exactly as today.

**Non-Goals:**
- Implementing the backend endpoint itself, or persisting PSGC codes server-side (address save payload unchanged).
- Reverse geocoding in other surfaces (booking funnel, home location sheet, saved-address list) — those keep current behavior.
- Replacing `PSGCService`'s data source or adding a local PSGC database.
- Draggable markers or changes to how the pin/camera interaction works.

## Decisions

1. **Resolve once, at pin confirmation — not on camera idle.** The confirm action triggers one resolve call; camera movement never calls the API. *Alternative:* debounce `onCameraIdle` resolution (rejected: per-move API cost, rate-limit risk, and UI churn for values the user hasn't committed to).
2. **New `ShphGeocodeApi` resource + `PsgcResolveResult` model.** A singleton resource in `lib/api/resources/geocode_api.dart` posting the contract body through `ShphApiClient.instance` (inherits auth interceptor and `ShphApiException` mapping), with `PsgcResolveResult.fromJson` validating that all required fields are present and well-formed. *Alternative:* raw Dio/`http` inside the page (rejected: bypasses the client's interceptors/exception mapping and the repo's resource convention).
3. **Short per-call budget: 8 s cap + cancellation.** The call runs with a client-side 8 s timeout (well under the global 30 s) and a `CancelToken` cancelled when the pin screen is disposed, so a dead network never strands the confirm button. Failures of any kind (400/422/timeout/transport) collapse into one `unresolved` outcome consumed by the UI.
4. **Confidence threshold = `0.85`, single named constant.** At or above, the payload auto-fills; below, it is withheld with the notice (spec's "configured confidence threshold"). *Alternative:* per-level thresholds (rejected: over-engineering for one endpoint whose scores we don't yet control) — the constant lives beside the parsing so tuning is a one-line change.
5. **Payload travels in the pin result map (`psgc` key).** `PinLocation` returns the existing `{latitude, longitude, address}` plus `psgc: PsgcResolveResult?`; `_openPinLocation` in the address form then applies it synchronously. *Alternative:* the form re-resolves from the returned coordinates (rejected: duplicate API call and a race where the user starts editing before the second response lands). The unresolved case ships `psgc: null` plus a flag/notified state so the form can show the notice.
6. **Cascade application: codes first, names second, all-or-nothing (province exempt).** A new apply path in the form resolves each level against already-loaded/local `PSGCService` data — match payload id to `code`, else fall back to the existing normalized `_namesMatch` comparison (strips `Brgy.`/`City of`, case, punctuation). Levels are applied strictly in order using the existing `onRegionChanged`/`onProvinceChanged`/city/`onBarangayChanged` handlers so child lists reload between steps. If region, city, or barangay cannot be matched, nothing is applied (all-or-nothing); an unmatched province is the documented exception — its name is written into the province display field while cities load under the region (the NCR path the form already has). *Rationale:* partial fills are what corrupt cascade state today; matching by id absorbs spelling drift ("Dila-Dila" vs official spellings) without fuzzy-string machinery.
7. **Resolution failure is visible but never blocking.** The confirm button shows a resolving spinner while in flight; on failure the pin still completes with raw coordinates and the form shows one non-blocking SnackBar-style notice (new l10n key, en + es) with every selector manually selectable — save is untouched.

## Risks / Trade-offs

- [PSGC code vintage mismatch between the API's codes and psgc.gitlab.io codes] → id match fails → name-level normalized match still succeeds; if both fail, all-or-nothing fallback to manual (spec scenario "Matched identifiers absent from local PSGC data").
- [API returns a province the local dataset can't represent (NCR "Metro Manila")] → exempt province from the all-or-nothing rule and use the existing load-cities-by-region path; the value still lands in the saved `province` string.
- [8 s cap feels long on a slow network] → spinner state keeps the UI honest; the cap is a constant next to the threshold for tuning; cancellation on dispose prevents ghost updates.
- [Endpoint not deployed yet when app work starts] → any non-2xx/absent-endpoint response follows the unresolved path, so the feature degrades to today's behavior instead of breaking; land API contract in `SHPH API.yaml` alongside the resource.
- [User's brief and the deployed API drift from the app's expectations] → contract captured in `SHPH API.yaml` as the single source of truth; the model's strict field validation turns drift into "unresolved" rather than a crash.

## Migration Plan

1. User lands the API endpoint first; its contract is recorded in `SHPH API.yaml`.
2. App change ships behind no flag — worst case (endpoint down) it is behaviorally identical to today.
3. Rollback = revert the app commit; no data migration, no server dependency in the save path.

## Open Questions

- None blocking. The confidence threshold (0.85) and the 8 s cap are constants deliberately placed for later tuning once real endpoint scores are observable.
