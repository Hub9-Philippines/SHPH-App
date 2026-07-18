# `feature/sync-from-shph-main` Porting Analysis

Date: 2026-07-18  
Target branch: `develop`  
Source branch: `feature/sync-from-shph-main`

## Summary

The source branch should not be merged directly into `develop`. Git reports 97 merge conflicts, and its focused follow-up commits do not apply cleanly with a three-way patch. The branch combines useful new features with large architectural replacements, generated UI rewrites, dependency changes, and deletion of legacy backend assets.

The safest approach is to manually port selected features in small, testable batches while retaining the newer API and authentication work already present on `develop`.

## Recommended implementation order

### 1. Realtime calls and WebSocket support

Candidate areas:

- `lib/services/call/`
- `lib/services/websocket_service.dart`
- `lib/pages/call/`
- Message and chat call integration
- Call signaling, ICE configuration, controller, and widget tests

This is the strongest self-contained feature missing from `develop`. Before implementation, confirm that the deployed SHPH API provides the required WebSocket signaling endpoints and ICE/TURN configuration.

### 2. Projects and Rooms

Projects include:

- Project creation and listing
- AI quote generation
- Provider matching
- Prospect actions
- Project cancellation

Rooms include:

- Room creation and listing
- Join-token lookup
- Join and leave actions
- Lock and cancellation actions

The source branch expects routes under `/api/projects/*` and `/api/services/rooms/*`. Verify these routes and their response schemas against the deployed API before porting the models, resources, pages, and routing.

### 3. Small standalone improvements

Lower-risk candidates include:

- `NotFoundPage`
- `SoundService`
- `PdfPreviewService`
- `Formatters.toNullableDouble()`
- `Formatters.toNullableInt()`
- Associated unit tests

These should be recreated or manually extracted rather than cherry-picked because their commits also contain unrelated changes and do not apply cleanly.

### 4. Selected product features

Evaluate these individually after confirming their API dependencies:

- Explore page
- Location-permission flow
- Write-review page
- Notification preferences
- Provider availability
- Admin KYC detail
- Session timeout
- Step-up authentication
- In-app notifications
- Trust badges

## Changes that should not be ported wholesale

- Core API client, API configuration, authentication, and token-storage files
- `pubspec.yaml`, `pubspec.lock`, or generated plugin registrants
- Large generated Flutter UI rewrites
- Existing admin, provider, wallet, and migration functionality already implemented differently on `develop`
- README and development-tooling directories without a separate review
- Deletion of the Node backend, database scripts, or Supabase compatibility files as part of a feature port

The current `develop` branch contains newer SHPH API migration work. Replacing its API/authentication layer with the source branch versions could restore outdated assumptions or remove supported endpoints.

## AI assistant recommendation

Do not port the Gemini widgets as-is. The source branch's Gemini service is primarily a disabled/fallback implementation, while `develop` currently contains an OpenRouter chatbot integration.

AI requests should ultimately pass through the SHPH API. Provider credentials and provider-specific request logic should not be embedded in the mobile application or APK.

## Supabase and Node cleanup

`develop` still contains the `supabase_flutter` dependency and compatibility files under `lib/backend/supabase`. These should be audited separately.

Removal criteria:

1. Confirm there are no runtime imports or calls to `Supabase.instance`.
2. Confirm all authentication, storage, database, and realtime behavior uses the SHPH API.
3. Run static analysis and the complete test suite after removal.
4. Build Android release and debug artifacts.
5. Test login, signup, OTP, token refresh, uploads, bookings, chat, and payments against a deployed API environment.

The local Node backend and deployment assets should only be removed after confirming they are not used by development, CI, deployment, OpenRouter proxying, or operational tooling.

## Proposed delivery batches

### Batch A: Utilities

- Add numeric formatters and tests.
- Add `NotFoundPage`, sound, and PDF preview utilities where needed.
- Run focused tests and `flutter analyze`.

### Batch B: Realtime communication

- Add WebSocket transport and lifecycle handling.
- Add WebRTC signaling and call controller.
- Integrate incoming/outgoing calls with chat.
- Add unit and widget tests.
- Validate with two authenticated devices against the deployed API.

### Batch C: Projects

- Verify API contract.
- Add models and API resource.
- Add list, create, detail, quote, and matching interfaces.
- Add route and API tests.

### Batch D: Rooms

- Verify API contract and identifier types.
- Add models, resource, pages, and routes.
- Test public join-token lookup and authenticated room actions.

### Batch E: Cleanup

- Audit and remove unused Supabase compatibility code.
- Decide whether Node/backend assets belong in another repository or should be archived.
- Re-run analysis, tests, and release builds.

## Validation gates

Each batch should meet the following requirements before merging:

- No new direct Supabase or Node runtime dependency
- No API credentials stored in the application
- API paths verified against the deployed SHPH backend
- Focused unit/widget tests pass
- `flutter analyze` introduces no new errors
- Existing authentication and OTP flows remain functional
- Android debug and release builds succeed

## Conclusion

`feature/sync-from-shph-main` is best treated as a feature reference rather than a merge candidate. Realtime calls, Projects, Rooms, and selected standalone utilities offer the most value. They should be manually adapted to the architecture currently on `develop`, with API verification and tests performed after every batch.
