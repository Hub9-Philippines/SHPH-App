## Context

The Flutter app already talks to the real SHPH API for auth (login,
two-step register, phone login, `/auth/me/`), and the previous auth-fix change
(`fix-shph-auth`) aligned that client with the web contract. But everything
downstream of a successful session is out of sync with the web app:

- `lib/auth/post_auth_navigation_flow.dart` queries the legacy `ProfilesTable`
  (from the removed Supabase stack) which has no registered `TableDataSource`,
  so it always returns an empty profile and always sends every user to
  CreateProfile — the rest of its branches are dead code.
- Role vocabulary is split: the backend and web use `provider`/`client` (plus
  `is_provider`/`is_client` booleans), while Flutter uses `pro`/`both` and
  checks `FFAppState().isProvider`, which is never assigned anywhere.
- `app_router.dart`'s `_fetchUserProfile()` drops `is_verified` /
  `is_face_verified`, so the pro-redirect guard can never reach the dashboard;
  there are no route-level `requiresProvider`/`requiresClient`/`requiresKyc`
  meta like the web's `beforeEach` guard.
- eKYC is shallow: one `document` file to `/kyc/submit/`, no liveness
  challenge endpoint, face verification recorded only in SharedPreferences.

Reference for parity: `E:\Dev\shph-web` — `src/stores/auth.ts`,
`src/stores/kyc.ts`, `src/composables/usePostAuthNavigation.ts`,
`src/composables/useProviderVerification.ts`, `src/views/auth/`,
`src/views/kyc/`, `src/router/index.ts`, and `SHPH API.yaml`.

## Goals / Non-Goals

**Goals:**
- Post-auth navigation decided by real `/auth/me/` capabilities
  (`is_provider`, `is_client`, `role`, `display_name`, `kyc_skipped`).
- Role vocabulary unified on the backend terms; `FFAppState().isProvider`
  actually maintained; provider/client shells render correctly.
- Provider four-state lifecycle + KYC skip + role/kyc-gated routing in GoRouter.
- eKYC parity: server-driven liveness, web field names on multipart submit,
  backend-persisted verification, web status vocabulary with polling.
- Fix checkbox-tick and submit-button legibility in the onboarding pages.

**Non-Goals:**
- Admin persona simulation, biometric sign-in, admin KYC review queue.
- Migration to Capacitor-native document scanner (Flutter uses camera/
  `google_mlkit_face_detection`; native scanner is already present and reused).
- Real-time KYC status push over WebSockets (polling is sufficient, matching
  the Flutter app's existing polling patterns).
- Legacy `/auth/otp/send|verify/` Firebase-ID-token flow (kept, untouched).

## Decisions

### D1 — One role/navigation source of truth: `AuthService` + a derived role
`AuthService` (`lib/services/auth_service.dart`) already holds `_currentUser`
from `/auth/me/`. Extend it with typed role getters (`isProvider`,
`isClient`, `role`, `isProfileComplete`, `kycSkipped`) computed from
`_currentUser`, and notify on change. `PostAuthNavigationFlow` and the router
guard both read from `AuthService` — never from `ProfilesTable`.
- Rationale: the web keeps role on `auth.user` and derives everything from it;
  one source prevents the "always CreateProfile" bug class.
- Alternative rejected: keep a separate profile fetch. Two sources drift.

### D2 — Delete the legacy-table path in post-auth flow
Rewrite `handlePostAuthNavigation()` / `checkProfileStatus()` in
`lib/auth/post_auth_navigation_flow.dart` to call `ShphUsersApi.getMe()` (or
reuse the user already in `AuthService`), checking `display_name` for profile
completeness and KYC status for the provider lifecycle. Preserve the function
signatures so callers (signin, phone_verify_user, debug skip-login) keep working.
- This mirrors web `usePostAuthNavigation.navigateAfterAuth()`.

### D3 — Provider lifecycle as a small state machine
Port web `useProviderVerification.getVerificationState()`:
```
no display_name                      → incomplete_profile → /createProfile
kyc not_submitted && !kyc_skipped    → kyc_required      → /eKYCBegin (intro)
kyc not_submitted && kyc_skipped     → kyc_skipped       → /pro-dashboard
kyc rejected                         → kyc_required      → /eKYCBegin
kyc pending                          → kyc_pending       → /pro-verification-progress
kyc approved                         → verified          → /pro-dashboard
```
KYC status from `KycHubService.getStatus()` (now hitting `POST /kyc/status/`),
with a 60s TTL like the web. `_fetchUserProfile()` in the router gains the KYC
fields so the guard is not gated on stale/missing keys.

### D4 — Role vocabulary aligned to backend; `isProvider` maintained
- Signup: pass the SignOptions choice through `tempsignuprole` and map
  `client|provider|both` → `{role: provider|client, is_provider?, is_client?}`
  in `ShphAuthManager.createAccountWithEmail` (replace the hardcoded
  `role: 'client'`). Update `signup_widget.dart` accordingly.
- `FFAppState().isProvider` assigned from `AuthService.isProvider` on
  login/register-verify/refresh (in `main.dart`/`app_state.dart` or the auth
  listeners), so `NavBarPage` picks the correct shell.
- Router guard and post-auth flow use `AuthService.isProvider`, not
  `tempsignuprole`/`'pro'` string checks.

### D5 — Route-level gating in GoRouter
Add optional `requiresProvider` / `requiresClient` / `requiresKyc` flags to
GoRoute definitions and enforce them in `RoleBasedRedirectGuard` (or a second
redirect), mirroring web `beforeEach` steps:
1. auth/expired → `/signin`
2. requiresProvider && !isProvider → client Home
3. requiresClient && !isClient → client Home
4. requiresProvider && isProvider → run provider lifecycle (profile→kyc→review→dashboard)
5. kyc_skipped + requiresKyc → `/eKYCBegin`
Mark `/pro-*` routes `requiresProvider`; keep `/` → splash/home logic intact.
Fix the dead `context.go('/document-scan')` in `kyc_hub_widget.dart` to the
real route and register the `IDVerifyWidget` route if it stays.

### D6 — eKYC: port the web KYC store shape into a service
Create a `KycSubmissionService` (or extend `KycHubService`) holding in-memory
documents + liveness result, mirroring web `stores/kyc.ts`:
- Add `ShphKycApi.requestLivenessChallenge()` → `POST /kyc/liveness/challenge/`
  returning `{nonce, plan, expiresAt}`; `getStatus` switches GET → POST.
- Face verification: request challenge → run plan via existing
  `google_mlkit_face_detection` (center face, blink, smile, left/right) →
  capture selfie frame → produce `{decision, score, metadata}`; on challenge
  failure use a local fallback plan with no nonce. Persist to backend only via
  submit (remove the SharedPreferences-only "markAsVerified" path).
- Submit multipart with web field names: `id_front`, `id_back`, `selfie`,
  `nbi_clearance`, `portfolio`, `resume`, `submitter_role`
  (`provider`/`customer`), `challenge_nonce`, `liveness_metadata`,
  `liveness_score`.
- Document step collects ID front+back (scanner/camera); provider-only adds
  NBI clearance (required) + optional portfolio/resume. Disable review until
  required docs are present.
- `verification_reviewing_widget` polls `POST /kyc/status/` and maps web
  vocabulary; on `pending`→`approved` route to `/pro-dashboard`; `rejected`
  surfaces the reason and allows resubmit.

### D7 — UI legibility fixes
In `create_profile_widget.dart` (the affected checkbox + submit button), use
`theme.onPrimary` (or `Colors.white`) for both `Checkbox.checkColor` and
`FFButtonWidget` text when enabled, instead of `theme.info` (which equals
`primary` in light mode). Keep disabled colors as-is. Add the same check to any
other onboarding buttons that inherit `info` as text color.

### D8 — Keep existing services untouched where possible
`auth_service.dart`, `shph_auth_manager.dart`, `shph_api_client.dart` stay as
the auth fix left them; this change only adds role getters / KYC API methods
and rewires callers. Token persistence, refresh, and error handling are
unchanged.

## Risks / Trade-offs

- **[Role state derived at wrong time]** → Always derive `AuthService.isProvider`
  from the current user and refresh after login/register-verify/fetchMe; the
  router guard re-reads on every navigation.
- **[KYC vocabulary drift]** → Flutter previously mixed three vocabularies
  (`unverified/pending/…`, `not_started/…`, web `not_submitted/rejected/pending/…`).
  Centralize the mapping in `KycHubService`/`KycSubmissionService` so only one
  mapping exists.
- **[Liveness complexity]** → Mirroring web's full engine is large. Scope to the
  same actions + decision/score output; treat the web engine as the behavior
  contract, not a code copy. Reuse existing camera + mlkit code.
- **[Multipart field-name mismatch]** → Keep a single builder (web parity list)
  in the KYC service; a typo in one field silently drops a doc on the backend,
  so unit-test the built FormData field set.
- **[Rollback]** → All changes are behind feature pages already reachable;
  reverting this change restores current behavior. No data migration needed
  (server-owned state).

## Migration Plan

1. Land in order: role getters + post-auth flow fix → router gating → signup
   role → shell/isProvider → eKYC API + service → pages (create-profile,
   kyc hub, face verification, review) → UI fixes → cleanup dead routes.
2. Verify each stage with `flutter analyze` (0 errors) and targeted tests
   (`flutter test test/...` individually; the full suite's stale boilerplate
   failure is pre-existing).
3. Manual device pass: client sign-up→home, provider sign-up→profile→KYC
   intro→(skip|submit)→dashboard; phone build via
   `flutter build apk --release`.

## Open Questions

- Whether the backend requires `id_type` on `POST /kyc/submit/` in practice
  (web never sends it and works) — assume omitted until proven otherwise.
- Exact liveness metadata schema expected by the backend — mirror web's
  `liveness_metadata` JSON keys and verify against an actual submission.
