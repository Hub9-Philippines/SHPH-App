# Design

## Context

See `proposal.md` for motivation. The Cloudflare Worker API (`serbisyo-api` at `C:\Users\Administrator\dev\serbisyo-api`) handles auth via Hono framework, D1 SQLite database, and KV staging storage. We need to expose account checking endpoints, standardize OTP pin endpoints to use SMSAPIPH, ensure 2-step edge registration staging works cleanly, and link OAuth accounts by email.

## Goals / Non-Goals

**Goals:**
- Implement `POST /api/v1/auth/check-account` (and DRF `/api/auth/check-account/`) to return user existence and auth setup parameters.
- Standardize `POST /api/v1/auth/otp/send-pin` and `POST /api/v1/auth/otp/verify-pin` (and DRF aliases `/api/auth/otp/send-pin/` and `/api/auth/otp/verify-pin/`).
- Ensure `POST /api/v1/auth/register/initiate` dispatches 6-digit PIN via SMSAPIPH and stages payload in Cloudflare KV without premature database insertion.
- Ensure OAuth handlers (`/google` & `/apple`) perform email-based account linking into pre-existing user records.
- Wire client resource `ShphAuthApi` in `shph-app` to consume `checkAccount`.

**Non-Goals:**
- Schema breaking changes to D1 `users` or `pending_registrations` tables.

## Decisions

### 1. Account Check Endpoint (`/api/v1/auth/check-account`)
- **Handler**: Checks `users` table for email or phone match.
- **Return format**: `{ exists: true, user_id, has_password, has_phone }` or `{ exists: false }`.

### 2. Standardized OTP Pin Endpoints (`/api/v1/auth/otp/send-pin` & `/api/v1/auth/otp/verify-pin`)
- **send-pin**: Generates 6-digit OTP code, stores in KV staging/cache, dispatches via `sendSmsOtp`.
- **verify-pin**: Validates code against KV staging/cache or active user phone OTP, returns JWT access and refresh tokens.

### 3. OAuth Account Linking
- If Google or Apple payload email exists in `users` table, return JWT token for that user id instead of failing with `409 CONFLICT`.

## Risks / Trade-offs

- **[Risk]**: KV staging expiration before SMS delivery.
  - *Mitigation*: Set KV expiration TTL to 600 seconds (10 minutes) and allow dev fallback pin (`123456`) in non-production environments.
