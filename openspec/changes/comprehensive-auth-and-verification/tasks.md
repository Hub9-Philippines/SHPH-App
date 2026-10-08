# Implementation Tasks: Comprehensive Authentication & Pre-Verification Flow (`comprehensive-auth-and-verification`)

## 1. Backend Migration & Pre-Verification Data Layer (`serbisyo-api`)
- [x] 1.1 Create D1 database migration `migrations/0009_pending_registrations.sql` creating `pending_registrations` table with fields `id`, `phone_number`, `email`, `first_name`, `middle_name`, `last_name`, `password_hash`, `otp_code`, `role`, `expires_at`, `created_at`, and verify migration executes cleanly using `npx wrangler d1 execute serbisyo-db --local --file=...`.
- [x] 1.2 Implement SMS provider module `src/lib/sms.ts` targeting `https://smsapiph.onrender.com/api/v1/send/sms` with `SMSAPIPH_KEY` API key header/payload binding, keeping fallback to Semaphore/Twilio and dev logging mode when API keys are unconfigured.

## 2. Refactor Registration & Multi-Method Auth Routes (`serbisyo-api`)
- [x] 2.1 Update `POST /api/v1/auth/register/initiate` in `src/routes/auth.ts` to validate profile fields (`first_name`, `middle_name`, `last_name`, `email`, `phone_number`, `password`), check for existing active users, store pending registration record in `pending_registrations`, and dispatch 6-digit OTP code without creating a user record in `users`.
- [x] 2.2 Update `POST /api/v1/auth/register/verify` in `src/routes/auth.ts` to validate 6-digit OTP code against `pending_registrations`, migrate pending payload into `users` table, remove pending record, and return JWT access/refresh tokens.
- [x] 2.3 Verify and enhance Google Sign-In (`POST /api/v1/auth/google`) and Phone OTP (`/phone-login/send` & `/phone-login/verify`) endpoints in `src/routes/auth.ts`.
- [x] 2.4 Add Block 17 integration test in `test-bookings-e2e.mjs` verifying pending registration initiate, OTP verification, user creation, and multi-method auth endpoints, and verify all test blocks pass using `node test-bookings-e2e.mjs`.
- [x] 2.5 Deploy updated Cloudflare Worker using `npx wrangler deploy`.

## 3. Flutter Sign Up Form & Auth API Integration (`shph-app`)
- [x] 3.1 Update `ShphAuthApi` resource in `lib/api/resources/auth_api.dart` to support expanded registration initiate/verify payloads (`first_name`, `middle_name`, `last_name`, `email`, `phone_number`, `password`).
- [x] 3.2 Update Sign Up UI and model in `lib/pages/signup/` (`signup_widget.dart` and `signup_model.dart`) to render input fields for First Name, Middle Name (optional), Last Name, Email, Mobile Number, Password, and Confirm Password.
- [x] 3.3 Enforce client-side form validation in `signup_widget.dart` (password matching, required fields, PH mobile number formatting) before calling `ShphAuthApi.instance.registerInitiate()`.
- [x] 3.4 Wire OTP Verification screen (`lib/pages/otp_page/`) to call `ShphAuthApi.instance.registerVerify()` with phone number and 6-digit pin upon OTP submission.

## 4. Analysis & Verification (`shph-app`)
- [x] 4.1 Run `flutter analyze` in `shph-app` and confirm 0 errors.
- [ ] 4.2 Commit and push git changes in both `serbisyo-api` and `shph-app` repositories.
