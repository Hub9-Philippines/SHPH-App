# Tasks

## 1. Contract & Resolve Client

- [ ] 1.1 Record the `POST /api/v1/geocode/psgc-resolve` path, `PsgcLookupRequest`, and `PsgcLookupResponse` schemas (all nine required response fields, plus 400/422 responses) in `SHPH API.yaml`; verify the entry appears with the required fields from `opencode_openspec_psgc.md` and the file still parses as valid OpenAPI
- [ ] 1.2 Add `lib/api/models/psgc_resolve_result.dart` with `fromJson` that returns `null` unless all nine fields are present and well-formed (ids/names non-empty strings, `confidence_score` a finite number); verify with `flutter test test/psgc_resolve_result_test.dart` covering the doc's full example payload (parses, ids/names/confidence preserved), a payload missing the barangay fields (`null`), and a non-numeric confidence (`null`)
- [ ] 1.3 Add `lib/api/resources/geocode_api.dart` (`ShphGeocodeApi.instance.resolvePsgcFromCoordinates(lat, lng)`) posting the contract body through `ShphApiClient.instance` with an 8 s cap, an optional `CancelToken`, and every failure mode (400, 422, timeout, transport, malformed body) collapsing to a single unresolved outcome; verify with `flutter test test/geocode_api_test.dart` driving a fake `httpClientAdapter` for success (payload returned), 422 (unresolved), and timeout (unresolved within the 8 s budget)

## 2. Pin Screen Resolution

- [ ] 2.1 Add the two l10n strings (resolving-in-progress label, location-could-not-be-identified notice) to `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb` and run `flutter gen-l10n`; verify the generated localizations compile via `flutter analyze` (0 errors) and both keys resolve in the en/es files
- [ ] 2.2 Wire `pin_location_widget.dart` confirm to call the resolve API with a visible resolving state that keeps confirmation pending until success/failure/timeout, carry the result as a `psgc` key in the popped `{latitude, longitude, address}` map (null when unresolved), and cancel the request if the screen is disposed; verify with `flutter test test/pin_location_resolve_test.dart`: confirm shows the resolving state and completes with a populated `psgc` key on success, and completes with `psgc: null` on failure, with pinned coordinates identical to the map center in both cases

## 3. Address Form Cascade Sync

- [ ] 3.1 Extract the payload-application logic into a pure planner (payload in, ordered apply-plan or "unresolved" out) that matches ids to PSGC codes first, falls back to the existing normalized name comparison, applies region → province → city → barangay in order, treats an unmatched province as display-text-only (NCR path: cities load under the region), and refuses partial fills when region/city/barangay cannot be matched or confidence is below 0.85; verify with `flutter test test/psgc_cascade_planner_test.dart`: high-confidence province/city/barangay match produces the ordered plan, NCR payload with no province entry produces a region-cities-barangay plan with the province display name, below-threshold confidence returns unresolved, and an unmatched city returns unresolved with nothing planned
- [ ] 3.2 Consume the pin result in `address_form_widget.dart`: apply a trusted payload through the existing selection handlers (loading child lists between levels), show the non-blocking unresolved notice when `psgc` is null or the planner refuses, and leave the manual cascade and save path untouched; verify with `flutter test test/address_form_psgc_sync_test.dart` covering auto-fill of all four selectors from a trusted payload, manual override after auto-fill still selectable, and the unresolved path leaving selectors empty/manual with the notice shown and save still reachable
- [ ] 3.3 Confirm the save payload is unchanged (`label`, `street`, `barangay`, `city`, `province`, `zip_code`, `latitude`, `longitude`, `is_default`); verify by inspecting `_saveAddress` and by a test asserting the address map sent to `AddressesService.saveAddress` after an auto-filled save contains the resolved names and the exact pinned coordinates

## 4. Integration Verification

- [ ] 4.1 Run the full change-related test set — `flutter test test/psgc_resolve_result_test.dart test/geocode_api_test.dart test/pin_location_resolve_test.dart test/psgc_cascade_planner_test.dart test/address_form_psgc_sync_test.dart test/psgc_service_test.dart` — and verify all pass
- [ ] 4.2 Run `flutter analyze` and verify 0 errors (existing warnings/info are accepted noise, no new errors introduced)
- [ ] 4.3 Run `flutter build apk --release` and verify the phone-testing build succeeds (debug keystore, no release keystore yet)
