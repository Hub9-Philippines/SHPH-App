## Why

The Flutter app's post-auth and eKYC flows do not match the web app's behavior:
client accounts are funneled through the provider path (complete profile → eKYC),
the complete-profile / eKYC / auth→home wiring is broken or un-API'd, and the
eKYC implementation (single document upload, local-only face verification) is a
pale shadow of the web's server-driven liveness + document flow. Two UI bugs
(enabled checkbox tick invisible, enabled submit text invisible) compound the
onboarding friction.

## What Changes

- **Role-aware post-auth routing (client vs provider).** After login/register/OTP,
  route by the real account capabilities returned by `/auth/me/` (`is_provider`,
  `is_client`, `role`), not by a broken local table query. Clients land on Home;
  providers go through the 4-state lifecycle (profile → KYC → review → dashboard)
  exactly like the web.
- **Fix `PostAuthNavigationFlow` / role gating.** Rewire to `ShphUsersApi.getMe()`
  (drop the unregistered `ProfilesTable` query that always forces CreateProfile).
  Align role vocabulary to the backend (`provider`/`client` instead of `pro`/`both`),
  set `FFAppState().isProvider` from `/auth/me/`, and surface `is_verified` /
  `is_face_verified` / KYC status in the router's profile fetch so verified
  providers can actually reach the pro dashboard.
- **Honor the sign-up role selection.** Signup currently hardcodes `role: 'client'`;
  pass the role chosen on SignOptions (`client`/`provider`/`both` → `is_provider`
  / `is_client` flags) into `registerInitiate`, matching web `RegisterPage.vue`.
- **Complete-profile parity.** CreateProfile must POST `display_name`, first/last
  name, bio via `/users/me/update/` and route providers to KYC intro / clients to
  Home after submit (web parity, `CreateProfilePage.vue`).
- **Web-parity eKYC.** Replace single-`document` upload with the web flow:
  ID front + back (scanner), provider-only NBI clearance + portfolio + resume,
  server-driven liveness challenge (`POST /kyc/liveness/challenge/`), `selfie` +
  `challenge_nonce` + liveness metadata, multipart submit to `POST /kyc/submit/`,
  and the `/kyc/status/` vocabulary (`not_submitted`/`rejected`/`pending`/`kyc_skipped`).
  Face verification must persist to the backend, not just SharedPreferences.
- **KYC skip + review.** Add `POST /auth/me/skip-kyc/` ("I'll do this later") with
  web's semantics (skippable only when `not_submitted`; rejected is not skippable),
  and a pending/review state that polls status and advances to the dashboard on
  approval.
- **Fix on-boarding UI bugs.** Checkbox tick and submit button text must be visible
  when enabled (use `theme.onPrimary`/white instead of `theme.info` where `info ==
  primary` in light mode).
- **Fix dead routes.** `/kyc` hub's `context.go('/document-scan')` → real route;
  register the `IDVerifyWidget` route if kept.
- **Role-based route gating meta** (`requiresProvider`/`requiresClient`/
  `requiresKyc`) in GoRouter, mirroring web's `beforeEach` guards, and wire the
  provider tab bar (`FFAppState().isProvider`).

## Capabilities

### New Capabilities

- `user-auth`: role-aware authentication and post-auth navigation — role
  selection at signup, real-capability routing after login/register/OTP, the
  provider 4-state lifecycle (profile → KYC → review → dashboard), KYC skip
  semantics, and role-gated route access, mirroring the web app's `auth.ts` +
  `usePostAuthNavigation` + `useProviderVerification` + router guards.
- `ekyc-verification`: web-parity identity verification — document collection
  (ID front/back, provider NBI/portfolio/resume), server-driven liveness
  challenge, multipart KYC submit, and status polling/surfacing using the
  `/kyc/*` API contract.

### Modified Capabilities

- (none — no existing specs; both capabilities are new)

## Impact

- **Flutter:** `lib/services/auth_service.dart`, `lib/auth/post_auth_navigation_flow.dart`,
  `lib/router/app_router.dart`, `lib/main/app_state.dart`, `lib/pages/signup/*`,
  `lib/pages/signin/*`, `lib/pages/phone_verify_user/*`, `lib/pages/create_profile/*`,
  `lib/pages/pro_verification/*` (document scan, face verification, verification
  review), `lib/pages/kyc_hub/*`, `lib/pages/e_k_y_c_begin/*`, `lib/api/resources/kyc_api.dart`,
  `lib/api/resources/users_api.dart`, `lib/theme/app_theme.dart`, `lib/components/`.
- **New API surface:** `POST /kyc/liveness/challenge/`, multipart fields on
  `POST /kyc/submit/` (`id_front`, `id_back`, `selfie`, `nbi_clearance`,
  `portfolio`, `resume`, `challenge_nonce`, `liveness_metadata`,
  `liveness_score`, `submitter_role`), `POST /auth/me/skip-kyc/`, `POST /kyc/status/`.
- **Reference:** web `src/stores/auth.ts`, `src/stores/kyc.ts`,
  `src/composables/usePostAuthNavigation.ts`, `src/composables/useProviderVerification.ts`,
  `src/views/auth/` (CreateProfile, Register, Login, Otp), `src/views/kyc/`,
  `src/router/index.ts`, `SHPH API.yaml` (auth + KYC sections).
- **Dependencies:** document scanner and liveness packages already present
  (`google_mlkit_face_detection`, camera); no new pub packages expected.
