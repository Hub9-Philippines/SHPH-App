## 1. Role source of truth in AuthService

- [x] 1.1 Add typed role getters to `lib/services/auth_service.dart` (`role`, `isProvider`, `isClient`, `isProfileComplete`, `kycSkipped`) computed from `_currentUser` and emit notify on change
- [x] 1.2 Ensure `_currentUser` is refreshed after login, registerVerify, phone-login verify, and fetchMe so role getters are always current

## 2. Fix post-auth navigation flow

- [x] 2.1 Rewrite `lib/auth/post_auth_navigation_flow.dart` to use `ShphUsersApi.getMe()` / `AuthService` user instead of the legacy `ProfilesTable` query (preserve function signatures for existing callers)
- [x] 2.2 Port the web `useProviderVerification` state machine into the flow: `incomplete_profile` → `/createProfile`, `kyc_required` → `/eKYCBegin`, `kyc_skipped` → `/pro-dashboard`, `kyc_pending` → `/pro-verification-progress`, `verified` → `/pro-dashboard`
- [x] 2.3 Base profile completeness on `display_name` being non-empty and read `kyc_skipped` from the user, matching web
- [x] 2.4 Confirm clients route to client Home and providers to the lifecycle after login (signin email tab), register-verify (phone_verify_user), and debug skip-login

## 3. Router profile fetch + role gating

- [x] 3.1 Add `is_provider`, `is_client`, `kyc_skipped`, and KYC status fields to `_fetchUserProfile()` in `lib/router/app_router.dart`
- [x] 3.2 Fix `_getProUserRedirect()` to use `is_provider` (not `role == 'pro'`) and the corrected KYC status so verified providers reach `/pro-dashboard`
- [x] 3.3 Add `requiresProvider` / `requiresClient` / `requiresKyc` support to GoRoute definitions and enforce in the redirect guard (web `beforeEach` parity: auth → role → kyc lifecycle → home-by-mode)
- [x] 3.4 Mark `/pro-*` routes `requiresProvider`; ensure kyc_skipped providers on `requiresKyc` routes are sent to KYC intro
- [x] 3.5 Register the `IDVerifyWidget` route if kept, and fix `context.go('/document-scan')` dead link in `kyc_hub_widget.dart` to the real route

## 4. Signup role selection

- [x] 4.1 Map SignOptions choice (`client`/`provider`/`both`) → backend payload (`role: provider|client`, `is_provider`, `is_client`) in `lib/auth/shph_auth/shph_auth_manager.dart` `createAccountWithEmail`
- [x] 4.2 Pass `tempsignuprole` through `lib/pages/signup/signup_widget.dart` instead of the hardcoded `role: 'client'`

## 5. Shell / isProvider state

- [x] 5.1 Assign `FFAppState().isProvider` from `AuthService.isProvider` on auth state changes (login, register-verify, refresh, logout)
- [x] 5.2 Verify `NavBarPage` renders provider tabs (Jobs/Schedule/Earnings) for providers and client tabs otherwise; provider dashboard reachable as home for providers

## 6. eKYC API surface

- [x] 6.1 Add `ShphKycApi.requestLivenessChallenge()` → `POST /kyc/liveness/challenge/` returning `{nonce, plan, expiresAt}` in `lib/api/resources/kyc_api.dart`
- [x] 6.2 Change `getStatus` to `POST /kyc/status/` (web parity) and keep the response mapping
- [x] 6.3 Add `ShphKycApi.submitKycDocs()` multipart builder using web field names: `id_front`, `id_back`, `selfie`, `nbi_clearance`, `portfolio`, `resume`, `submitter_role`, `challenge_nonce`, `liveness_metadata`, `liveness_score`

## 7. eKYC service + pages

- [x] 7.1 Create `KycSubmissionService` holding documents + liveness result (web `stores/kyc.ts` parity) with a single submitter-role + vocabulary mapping
- [x] 7.2 Wire document scan page to collect ID front + back (reuse scanner/camera); provider flow adds NBI clearance (required) + optional portfolio/resume
- [x] 7.3 Face verification: request server challenge → run plan actions (center face, blink, smile, left/right) via `google_mlkit_face_detection` → capture selfie; fall back to local plan when challenge fails
- [x] 7.4 Remove SharedPreferences-only "markAsVerified" path in face verification; verification is persisted only via KYC submit to the backend
- [x] 7.5 Submit KYC multipart from the review page; on success show pending state; on `redoLiveness`-style rejection reset liveness and retry
- [x] 7.6 `verification_reviewing_widget`: poll `POST /kyc/status/` (60s TTL), route to `/pro-dashboard` on approval, surface rejection reason + resubmit on rejected

## 8. eKYC status surfacing

- [x] 8.1 `kyc_hub_widget.dart`: use web status vocabulary (`not_submitted`/`rejected`/`pending`/approved) and show verified / under review / rejected / not-started states with correct actions
- [x] 8.2 Add skip-KYC ("I'll do this later") calling `POST /auth/me/skip-kyc/`, honoring web semantics (skippable only when `not_submitted`; not offered when rejected)

## 9. Onboarding UI legibility

- [x] 9.1 Fix `create_profile_widget.dart` checkbox: `Checkbox.checkColor` uses `theme.onPrimary`/white so the tick is visible when checked in light mode
- [x] 9.2 Fix `create_profile_widget.dart` submit button: enabled text uses `theme.onPrimary`/white instead of `theme.info`
- [x] 9.3 Audit other onboarding buttons for `theme.info`-as-text-color and fix any that are invisible when enabled

## 10. Verification

- [x] 10.1 `flutter analyze` reports 0 errors
- [x] 10.2 Unit-test the KYC multipart FormData field set (web parity names present)
- [x] 10.3 Targeted widget/flow tests pass (run test files individually)
- [ ] 10.4 Manual device pass: client sign-up → Home; provider sign-up → profile → KYC intro → (skip | submit docs + liveness) → review → dashboard
- [x] 10.5 `flutter build apk --release` succeeds
