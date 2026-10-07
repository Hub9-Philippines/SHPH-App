# Proposal

## Why

Pinning a location on the map (`/pinLocation`) currently yields only raw latitude/longitude — a usable address string appears only if the user also ran a Places search, and the structured geography (region / province / city / barangay) is never resolved at all. As a result the AddressForm's cascading PSGC selectors stay fully manual after pinning, so the saved address can disagree with the pinned coordinates (wrong barangay codes, cascades that fail to restore), which corrupts dispatch, proximity filtering, and server-derived booking addresses. A new resolve API turns a coordinate pin into verified PSGC entities so the selectors synchronize automatically.

## What Changes

- **New resolve API integration**: a `ShphGeocodeApi` resource calling `POST /api/v1/geocode/psgc-resolve` with `{latitude, longitude}` and returning the PSGC payload (`psgc_region_id`, `region_name`, `psgc_province_id`, `province_name`, `psgc_city_id`, `city_name`, `psgc_barangay_id`, `barangay_name`, `confidence_score`) per the contract in `opencode_openspec_psgc.md`. The endpoint itself is a prerequisite built first as a separate API change; this change consumes it.
- **PinLocation resolves on submit**: when the client confirms a pinned center, the app resolves the coordinates and returns the PSGC payload alongside the existing `{latitude, longitude, address}` result, with an in-progress state while resolution runs.
- **AddressForm cascade synchronization**: on receiving a resolved payload, the form selects region → province → city/municipality → barangay in its existing PSGC cascade (via `PSGCService` data and the existing name-fallback matching), so every selector ID is valid and ordered before the address is saved. Manual re-selection always remains possible afterwards.
- **Graceful failure handling**: coordinates outside the Philippines (422), bad payloads (400), timeouts, and low-confidence matches degrade to today's behavior — manual cascade selection — with a non-blocking message, never blocking form submission.
- **Confidence surfacing**: `confidence_score` drives whether the auto-fill is applied or the user is left to pick manually (threshold decided in design).

## Capabilities

### New Capabilities
- `psgc-geocoding`: resolving a pinned map coordinate into verified PSGC entities (region/province/city/barangay + confidence) and synchronizing the address form's cascading selectors from that result, including degradation when resolution fails or is untrusted.

### Modified Capabilities

(No existing spec-level behavior changes — no current spec covers the pin-location page or the address form cascade.)

## Impact

- **App code**: new `lib/api/resources/` geocode resource wired into `lib/api/shph_api_client.dart`; new resolution service in `lib/services/`; `lib/pages/pin_location/` (resolve-on-submit + loading state); `lib/pages/address_form/` (consume payload, cascade sync, failure message).
- **API dependency**: requires the new `POST /api/v1/geocode/psgc-resolve` endpoint (created first, outside this change) and a contract entry in `SHPH API.yaml`.
- **UX/localization**: minor new strings (resolving, unresolved/fallback notice) in `lib/l10n/` (en + es, then `flutter gen-l10n`).
- **Unaffected**: booking funnel, home location sheet, saved-address CRUD, and `PSGCService`'s own data source (psgc.gitlab.io) keep their current behavior.
- **Tests**: unit tests for the response mapping/fuzzy-name fallback and widget tests for pin → form synchronization and failure fallback.
