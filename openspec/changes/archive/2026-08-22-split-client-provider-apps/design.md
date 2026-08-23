## Context

The codebase is a FlutterFlow-pattern app: `lib/main.dart` switches between `_clientTabs` and `_providerTabs` based on `FFAppState().isProvider`; `lib/router/app_router.dart` carries ~30 provider routes guarded by `RouteGates.requiresProvider` plus `_providerHomePaths` redirect logic; `lib/auth/post_auth_navigation_flow.dart` branches providers into a 4-state verification lifecycle (profile → KYC → review → dashboard) while clients go straight to Home. Provider-only page families live under `lib/pages/` (pro_dashboard, earnings, my_services, availability_calendar, provider_bids/analytics, kyc_hub/e_k_y_c_begin/i_d_verify/pro_verification, dispatch, tm_flow). Some pages look provider-named but are client-facing and must stay (`provider_profile` renders a provider's public profile for clients; `client_ondemand_jobs` lists the client's own on-demand requests).

Backend is the single SHPH REST API for both audiences; roles come back from auth (`role` may be `client`, `provider`, or both-capable — see `_mapSignupRole` in `lib/auth/shph_auth/shph_auth_manager.dart`). No Supabase.

## Goals / Non-Goals

**Goals:**
- This repo becomes the client-only app with zero dead provider surfaces (routes, tabs, pages, services).
- The provider experience moves intact into a standalone sibling Flutter app.
- Both apps keep side-by-side installability and hit the same API.

**Non-Goals:**
- Extracting shared Dart packages / monorepo tooling (deferred; duplication accepted for now).
- Any backend/API changes, new endpoints, or data migrations.
- New provider features — parity only.
- Store listing production setup beyond application ID divergence.

## Decisions

### D1: Split strategy = copy-then-prune
Create the provider app as a full copy of this repo at its current state, then prune each side. Order matters: **copy first**, so no provider code is destroyed before it lands in the new repo; then strip this repo down to client-only and strip the copy down to provider-only.

- *Alternatives considered*: (a) extract a shared package (api/theme/components) consumed by both apps — rejected now because the FlutterFlow-style imports (`/flutter_flow/util.dart` absolute-style paths) make packaging invasive; revisit later if drift hurts. (b) One binary with runtime role switching (status quo) — this is exactly what we're removing.

### D2: Provider app location and identity
Sibling repository at `E:\Dev\shph-provider` (name adjustable without affecting the design): pubspec name `shph_provider`, Android applicationId / iOS bundle id `com.serbisyohub.provider` vs the client's existing id. Copies shared infrastructure wholesale: `lib/api/`, `lib/theme/`, `lib/components/` (only those used), `lib/services/`, `lib/flutter_flow/` utils, auth layer, plus all provider page families and `lib/main/pro_*`.

### D3: Client-app pruning surface
- `lib/main.dart`: delete `_providerTabs`, `_buildProviderItems`, provider branch getters; shell renders only the five client tabs.
- `lib/router/app_router.dart`: remove provider-only route registrations and `RouteGates.requiresProvider`; unknown/legacy deep-link paths fall through to home (existing not-found handling) instead of provider UI. Delete `_providerHomePaths`.
- `lib/auth/post_auth_navigation_flow.dart`: always route clients to Home; when `AuthService.isProvider == true`, present a "Use the SerbisyoHub Provider app" notice (with Continue-as-client + Sign-out actions) instead of the KYC lifecycle.
- Delete provider-only page directories and their models/tests after a reference audit (`grep` each candidate for inbound references from kept flows before deleting).
- Keep: booking funnel family, chat/call pages, `provider_profile`, `client_ondemand_jobs`, reviews/wallet/payment methods, favorites, disputes, addresses.
- `FFAppState.isProvider` remains solely as a sign-in-time detection flag feeding the notice; it never alters navigation again.

### D4: Mixed-capability accounts stay usable as clients
Accounts whose backend role includes both capabilities can acknowledge the notice and continue into the normal client experience (matches spec scenario); provider-only accounts get the same notice but with Sign-out emphasized. No backend call needed — decision is local UX policy.

### D5: Signup simplification
Remove the provider role option at every entry point that offers it today (`sign_options`, signup, phone/OTP verification completion) rather than hiding it conditionally — the client app cannot create providers anymore, so the branch is deleted outright.

## Risks / Trade-offs

- [Deleting a page that shared flows still reference] → Mandatory reference audit per deletion batch + `flutter analyze` 0-errors gate before commit; delete in small batches (router routes last).
- [Code drift between duplicated api/theme/services across the two repos] → Accepted short-term; document copied-file provenance in the provider repo README so a future shared-package extraction has a manifest.
- [Existing provider users stranded on an old client-app build after update] → In-app notice links to the provider app store listing (placeholder URL until release); notice text ships before any store removal.
- [Deep links/bookmarks to `/pro-dashboard` etc. after update] → Router fallback sends them to client home; acceptable since providers should migrate to the new app.
- [Stale tests referencing removed widgets] → Suite already fails via stale `widget_test.dart`; per-file test runs remain the gate, update/delete tests touching removed pages in the same task that removes them.
- [KYC/eKYC assets and services used by both sides] → `provider_verification_service` moves to the provider repo; client repo keeps only what public profile/reviews need.

## Migration Plan

1. **Fork**: copy working tree → `E:\Dev\shph-provider`; rename pubspec/package ids; verify `flutter analyze` + APK build there.
2. **Prune provider app**: remove client booking funnel, explore/home client tabs, client-only page families; provider shell becomes the entry.
3. **Prune client app (this repo)**: D3 changes in order — auth flow, main shell, signup, router, then page deletions; analyze + targeted tests green.
4. **CI**: add workflow/build job for the provider repo; keep client pipeline unchanged apart from any path assumptions.
5. **Rollback**: both repos are independent git histories post-fork; reverting the client prune is a single revert of the prune commits.

## Open Questions

- Final name/location of the provider repository and its store listing timing (does not affect approach; default `E:\Dev\shph-provider` assumed).
- Whether wallet/payout UI ships in the provider app v1 alongside earnings or stays earnings-only until payout APIs are exposed (parity says carry over what exists today).
