# Tasks: Align Serbisyo API Auth (`align-serbisyo-api-auth`)

## 1. Backend Account Lookup & OTP Routing (`dev/serbisyo-api/src/routes/`)

- [x] 1.1 Implement `POST /api/v1/auth/check-account` (and DRF `/api/auth/check-account/`) in `src/routes/auth.ts` and `src/routes/compat.ts` to look up users by email or phone.
- [x] 1.2 Align `POST /api/v1/auth/otp/send-pin` and `POST /api/v1/auth/otp/verify-pin` (and DRF aliases `/api/auth/otp/send-pin/` and `/api/auth/otp/verify-pin/`) in `src/routes/auth.ts` and `src/routes/compat.ts` for mobile OTP login using SMSAPIPH.

## 2. Edge Staging & OAuth Account Linking (`dev/serbisyo-api/src/routes/`)

- [x] 2.1 Verify 2-step edge registration staging (`/register/initiate` & `/register/verify`) dispatches 6-digit OTP via SMSAPIPH and commits user data to D1 on verification.
- [x] 2.2 Update Google and Apple OAuth handlers (`/google` & `/apple`) to search by email and automatically link identities to existing user records.

## 3. Flutter Client Wiring & Verification (`shph-app`)

- [x] 3.1 Update `ShphAuthApi` (`lib/api/resources/auth_api.dart`) to add `checkAccount(identifier)` client resource call.
- [x] 3.2 Run `flutter analyze` in `shph-app` and verify 0 errors.
- [x] 3.3 Commit and push git changes in `shph-app` repository.
