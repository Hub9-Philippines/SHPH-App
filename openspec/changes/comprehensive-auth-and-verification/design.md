# Technical Design: Comprehensive Authentication & Pre-Verification Flow (`comprehensive-auth-and-verification`)

## Context
See `proposal.md` for motivation. Currently, submitting the registration form in `shph-app` creates an active user row in D1 `users` table via `serbisyo-api` before phone OTP verification is completed. We need to enforce a pre-verification flow where pending registrations live in a temporary table, and only upon successful OTP entry is the user migrated to `users`.

## Goals / Non-Goals

**Goals:**
- Implement `pending_registrations` D1 schema and lifecycle management in `serbisyo-api`.
- Refactor `POST /api/v1/auth/register/initiate` to store pending registration records and issue OTP without creating `users` records.
- Refactor `POST /api/v1/auth/register/verify` to validate OTP, insert active `users` record, delete pending record, and issue JWT tokens.
- Add multi-method auth endpoint support for Google Sign-In (`POST /api/v1/auth/google`), Phone + OTP, and Email/Password.
- Update `shph-app` Sign Up form to include First Name, Middle Name (optional), Last Name, Email, Mobile Number, Password, and Confirm Password with form validation.
- Implement modular SMS service dispatcher (`src/lib/sms.ts`) in `serbisyo-api` supporting Semaphore / Twilio with fallback development logging.

**Non-Goals:**
- Integrating third-party platforms like Firebase or Supabase (the hand-written Hono + D1 Worker backend is the sole source of truth).
- Native Apple Sign-In SDK configuration on iOS device build (API endpoint contract is provided, native CocoaPod binding is deferred).

## Decisions

### Decision 1: D1 Pending Registrations Table vs. Immediate User Insertion
- **Choice**: Store unverified sign-up data in a dedicated `pending_registrations` table (`id`, `phone_number`, `email`, `first_name`, `middle_name`, `last_name`, `password_hash`, `otp_code`, `role`, `expires_at`).
- **Rationale**: Prevents orphaned unverified user accounts from cluttering the main `users` table and prevents unauthorized access before phone verification.
- **Alternatives Considered**: Storing users in `users` with `is_verified = 0`. Rejected because queries across the app would require extra `WHERE is_verified = 1` checks everywhere to avoid exposing unverified profiles.

### Decision 2: SMS Gateway Integration Architecture
- **Choice**: Abstract SMS sending in `src/lib/sms.ts`. Configure primary SMS gateway to `https://smsapiph.onrender.com/api/v1/send/sms` authenticated via `SMSAPIPH_KEY` environment variable. If `SMSAPIPH_KEY` is present in Cloudflare Worker environment bindings, dispatch real SMS via HTTP POST (`{ recipient: phone_number, message: "Your Serbisyo verification code is XXXXXX" }`). If unconfigured or in development, log the 6-digit OTP code to console.
- **Rationale**: Provides free, direct Philippines SMS delivery via `smsapiph.onrender.com` without per-message charges, while keeping fallback support for Semaphore/Twilio and zero-cost local console logging.

## Risks / Trade-offs

- **[Risk]**: User retries registration with same email or phone number before previous OTP expires.
  - **Mitigation**: `POST /api/v1/auth/register/initiate` replaces any existing pending registration record matching the phone number or email, resetting the 6-digit OTP code and extending the 10-minute expiration timer.
- **[Risk]**: Stale pending registrations accumulating in D1 storage.
  - **Mitigation**: `expires_at` timestamp is set to `unixepoch() + 600` (10 minutes). Verification checks enforce `expires_at > unixepoch()`.
