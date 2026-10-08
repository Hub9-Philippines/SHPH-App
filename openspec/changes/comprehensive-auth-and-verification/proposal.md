# Proposal: Comprehensive Authentication & Pre-Verification Flow (`comprehensive-auth-and-verification`)

## Why
Currently in `shph-app` and `serbisyo-api`, submitting the sign-up form in the Create Account page immediately creates a full active account in the database before the user completes SMS OTP verification. This creates unverified ghost accounts and bypasses mandatory phone ownership validation. Furthermore, authentication methods across Mobile Phone + OTP, Email/Password, and Google Sign-In need unified API support and form field alignment (First Name, Middle Name, Last Name, Email, Mobile Number, Password, and Confirm Password).

## What Changes
1. **Pending Registration & Verification Bug Fix (`serbisyo-api`)**:
   - Update `POST /api/v1/auth/register/initiate` to store registration payloads (`first_name`, `middle_name`, `last_name`, `email`, `phone_number`, hashed password, role) in a `pending_registrations` table with an expiration timestamp and generated 6-digit OTP pin.
   - Users are NOT created in the `users` table upon form submission.
   - Update `POST /api/v1/auth/register/verify` to validate the OTP pin against `pending_registrations`. Upon successful verification, the user record is inserted into `users` and JWT tokens are returned.
2. **Expanded Sign Up Form Fields (`shph-app`)**:
   - Update sign-up UI in `shph-app` (`lib/pages/signup/`) to include First Name, Middle Name (optional), Last Name, Email, Mobile Number (+63 PH format), Password, and Confirm Password.
   - Ensure client-side validation enforces matching passwords, valid PH phone formats, and required field rules before calling the initiate API.
3. **Multi-Method Auth API Gateway (`serbisyo-api` & `shph-app`)**:
   - Ensure complete API endpoint support for:
     - Phone + SMS OTP (`/api/v1/auth/phone-login/send` & `/api/v1/auth/phone-login/verify`)
     - Email / Password (`/api/v1/auth/login`)
     - Google Sign-In (`/api/v1/auth/google`)
     - Apple Sign-In (`/api/v1/auth/apple` - contract ready)
4. **Third-Party & SMS Provider Architecture Clarification**:
   - **Backend**: No Firebase or Supabase is required. The `serbisyo-api` Cloudflare Worker with D1 database is the single source of truth.
   - **SMS OTP Service**: Integrated SMS provider gateway abstraction (`src/lib/sms.ts`) configured to call `https://smsapiph.onrender.com/api/v1/send/sms` using `SMSAPIPH_KEY` environment variable (with fallback to Semaphore/Twilio and dev mode console logging).

## Capabilities

### Modified Capabilities
- `user-auth`: Modify registration initiate/verify contract to ensure user accounts are created in DB only after successful SMS OTP verification, update registration payload fields, and enforce multi-method authentication support.

## Impact
- **Backend (`serbisyo-api`)**:
  - New D1 migration `0009_pending_registrations.sql` adding `pending_registrations` table (`id`, `phone_number`, `email`, `first_name`, `middle_name`, `last_name`, `password_hash`, `otp_code`, `role`, `expires_at`, `created_at`).
  - Refactored `src/routes/auth.ts` endpoints: `/register/initiate`, `/register/verify`, `/phone-login/send`, `/phone-login/verify`, `/google`, `/apple`.
  - Helper module `src/lib/sms.ts` targeting `https://smsapiph.onrender.com/api/v1/send/sms` with `SMSAPIPH_KEY` API key binding and dev fallback logging.
  - New E2E integration test block in `test-bookings-e2e.mjs`.
- **Mobile App (`shph-app`)**:
  - Updated `SignupWidget` / `SignupModel` in `lib/pages/signup/`.
  - Updated `ShphAuthApi` resource in `lib/api/resources/auth_api.dart`.
