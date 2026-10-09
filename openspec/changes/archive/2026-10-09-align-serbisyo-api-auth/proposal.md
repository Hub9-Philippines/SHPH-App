# Proposal

## Why

The backend API (`serbisyo-api`, deployed on Cloudflare Workers) needs full alignment with the newly implemented Unified Auth gateway and 2-step onboarding setup in the Flutter app (`shph-app`). The mobile app requires standardized account lookup, phone OTP dispatching via SMSAPIPH, 2-step edge registration staging without premature database insertion, and seamless OAuth account linking.

## What Changes

- **Account Lookup Endpoint**: Add `POST /api/v1/auth/check-account` (and `/api/auth/check-account/`) accepting `{ identifier }` (email or sanitized phone) to return whether an account exists and its setup flags (`has_password`, `has_phone`).
- **OTP Pin Endpoints**: Align `POST /api/v1/auth/otp/send-pin` and `POST /api/v1/auth/otp/verify-pin` (with DRF `/api/auth/otp/send-pin/` and `/api/auth/otp/verify-pin/` aliases) to handle SMS OTP dispatching and verification for mobile login.
- **Registration Edge Staging**: Verify `POST /api/v1/auth/register/initiate` stages user details in Cloudflare KV without creating an active production user row, sending a 6-digit OTP via SMSAPIPH.
- **Commit Transaction**: Ensure `POST /api/v1/auth/register/verify` (and `/api/v1/auth/verify-otp`) verifies the PIN, commits the staged user into D1 `users` table, and returns JWT auth tokens.
- **OAuth Account Linking**: Ensure `POST /api/v1/auth/google` and `POST /api/v1/auth/apple` search for existing user profiles by email and merge OAuth identifiers into existing accounts.

## Capabilities

### Modified Capabilities
- `user-auth`: Align backend auth routes (`serbisyo-api`) with mobile Unified Auth setup, providing account lookup, phone OTP dispatching via SMSAPIPH, edge registration staging, and OAuth account linking.

## Impact

- **Backend (`C:\Users\Administrator\dev\serbisyo-api`)**:
  - `src/routes/auth.ts`
  - `src/routes/compat.ts`
  - `src/lib/staging.ts`
  - `src/lib/sms.ts`
- **Frontend (`shph-app`)**:
  - `lib/api/resources/auth_api.dart`
  - `lib/services/auth_service.dart`
