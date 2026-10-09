# Tasks

## 1. Backend Email OTP Endpoints in serbisyo-api

- [ ] 1.1 Implement `POST /api/v1/auth/otp/send-email` and `POST /api/v1/auth/otp/verify-email` in `serbisyo-api` (`src/routes/auth.ts` and `src/routes/compat.ts`) and verify with `curl` / postman request tests.

## 2. Native OAuth Integration in shph-app

- [ ] 2.1 Update `ShphAuthManager.signInWithGoogle` and `signInWithApple` in `lib/auth/shph_auth/shph_auth_manager.dart` to trigger native `GoogleSignIn` / `SignInWithApple` account selection modal prompts and retrieve Google/Apple account details (email and name).
- [ ] 2.2 Wire `UnifiedAuthWidget` social buttons to trigger native OAuth prompt and check account existence via `/api/v1/auth/check-account`.

## 3. Method-Dedicated Step 2 Onboarding Forms

- [ ] 3.1 Update `SignupWidget` (`lib/pages/signup/signup_widget.dart` and `signup_model.dart`) to support method-dedicated Step 2 views:
  - `Google/Apple`: Pre-filled Email + First Name + Last Name fields.
  - `Email`: Pre-filled Email + First Name + Last Name + Password fields.
  - `Mobile`: Pre-filled Mobile Number + First Name + Last Name + optional Email + Password fields.
- [ ] 3.2 Verify form validation and pre-population logic in `SignupWidget`.

## 4. Method-Dedicated Step 3 Verification Views

- [ ] 4.1 Implement `EmailVerifyWidget` (`lib/pages/email_verify/email_verify_widget.dart`) to accept 6-digit email OTP codes and verify via `/api/v1/auth/otp/verify-email`.
- [ ] 4.2 Wire Step 2 submit actions to dispatch Email OTP (`send-email`) for Email/Google/Apple flows, and SMS OTP (`send-pin`) for Mobile flows, navigating to the corresponding Step 3 verification widget.

## 5. Verification and Integration

- [ ] 5.1 Run `flutter analyze` to ensure zero analysis errors across all updated auth widgets and services.
