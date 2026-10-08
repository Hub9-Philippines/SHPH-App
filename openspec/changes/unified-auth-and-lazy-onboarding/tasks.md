# Tasks: Unified Auth & Lazy Onboarding (`unified-auth-and-lazy-onboarding`)

## 1. Backend Staging State & Account Linking (`serbisyo-api`)

- [x] 1.1 Implement edge staging helper module in `src/lib/staging.ts` (using KV or `pending_registrations` with 300s TTL) in `serbisyo-api` to store pre-verification sign-up credentials without writing active user rows into the `users` table.
- [x] 1.2 Implement `/api/v1/auth/verify-otp` endpoint in `src/routes/auth.ts` to validate the matching 6-digit OTP, commit staged registration credentials into active `users` rows, issue JWT tokens, and delete the staging reference.
- [x] 1.3 Update Google and Apple OAuth endpoints (`POST /api/v1/auth/google` and `/api/v1/auth/apple`) in `src/routes/auth.ts` to inspect target `email` strings against existing user rows and merge OAuth provider identities to prevent duplicate profiles.
- [x] 1.4 Add Block 18 E2E integration tests in `test-bookings-e2e.mjs` verifying edge staging, `/verify-otp`, and OAuth account linking, and confirm all test blocks pass cleanly via `node test-bookings-e2e.mjs`.
- [x] 1.5 Deploy the updated Cloudflare Worker backend using `npx wrangler deploy`.

## 2. Flutter UI Presentation Layers (`shph-app`)

- [x] 2.1 Create `AnimatedProgressStepper` component widget in `lib/components/animated_progress_stepper.dart` rendering a smooth 2-step onboarding progress bar.
- [x] 2.2 Create Unified Auth Screen presentation layer (`lib/pages/unified_auth/unified_auth_widget.dart` and `unified_auth_model.dart`) featuring brand logo placeholder, Google & Apple sign-in buttons, visually clean "- OR -" divider, and single "Email or Mobile Number" input field.
- [x] 2.3 Implement real-time regex parsing listener in `UnifiedAuthModel` detecting email (`AuthMode.email`) vs PH phone (`AuthMode.phone`) and auto-sanitizing `09...` inputs into standardized `+639...` format.

## 3. Flutter Lazy Onboarding Flow & API Integration (`shph-app`)

- [x] 3.1 Update `ShphAuthApi` resource in `lib/api/resources/auth_api.dart` to support `/api/v1/auth/verify-otp` and pass sanitized payloads.
- [x] 3.2 Update `AuthService` (`lib/services/auth_service.dart`) and `ShphAuthManager` (`lib/auth/shph_auth/shph_auth_manager.dart`) to execute 2-step lazy onboarding (Step 1: Auth Gate, Step 2: Verification Pass with OTP or mobile prompt for social logins missing phone numbers).
- [x] 3.3 Update `AppRouter` (`lib/router/app_router.dart`) to register `/unifiedAuth` gateway route and handle seamless post-auth navigation.

## 4. Analysis & Verification (`shph-app`)

- [x] 4.1 Run `flutter analyze` in `shph-app` and confirm 0 errors.
- [x] 4.2 Commit and push git changes in both `serbisyo-api` and `shph-app` repositories.
