# Design: Unified Auth & Lazy Onboarding Architecture (`unified-auth-and-lazy-onboarding`)

## Context
See [`proposal.md`](file:///C:/Users/Administrator/dev/shph-app/openspec/changes/unified-auth-and-lazy-onboarding/proposal.md) and [`specs/user-auth/spec.md`](file:///C:/Users/Administrator/dev/shph-app/openspec/changes/unified-auth-and-lazy-onboarding/specs/user-auth/spec.md).

Currently, registration creates active user rows in D1 prior to SMS verification, and sign-in requires separate screens for email vs phone auth. Additionally, Google/Apple OAuth sign-in does not check for pre-existing email accounts, leading to duplicate profiles.

## Goals / Non-Goals

**Goals:**
- Implement `UnifiedAuthWidget` with a single intelligent input field dynamically switching between `AuthMode.email` and `AuthMode.phone`.
- Implement `AnimatedProgressStepper` providing a smooth 2-step onboarding visual bar (`Step 1: Auth Gate`, `Step 2: Verification Pass`).
- Implement Cloudflare Worker KV staging for registration payloads with a 300s expiration TTL, postponing database insertion until `/api/v1/auth/verify-otp` succeeds.
- Implement OAuth Account Linking middleware in `serbisyo-api` to merge Google/Apple sign-ins with pre-existing email accounts.

**Non-Goals:**
- Changing existing KYC onboarding procedures (KYC photo/liveness stays post-auth).
- Requesting middle names, home addresses, or billing files during the onboarding flow.

## Decisions

### 1. Unified Auth Input Discrimination Architecture
- **Choice:** Single `TextEditingController` with real-time `onChanged` listener evaluating regex patterns:
  - Email Regex: `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`
  - PH Phone Regex: `^(09|\+?639)\d{9}$`
- **Sanitization:** Numbers matching `09...` (e.g. `09171234567`) are converted to `+639171234567` upon submission.
- **Rationale:** Minimizes UI clutter and provides immediate visual feedback to the user on whether they are entering an email or mobile number.

### 2. Edge Staging with Cloudflare KV vs D1 Staging Table
- **Choice:** Cloudflare KV edge cache (`env.REGISTRATION_KV` or D1 fallback table `pending_registrations`) with a 300s expiration TTL (`expirationTtl: 300`).
- **Key Pattern:** `pending_reg:${sanitizedPhone}`
- **Payload Structure:**
  ```json
  {
    "phone_number": "+639171234567",
    "email": "user@example.com",
    "first_name": "Juan",
    "last_name": "Dela Cruz",
    "password_hash": "$2a$10$...",
    "otp_code": "123456",
    "role": "client",
    "created_at": 1712345678
  }
  ```
- **Rationale:** Ensures zero database clutter from unverified sign-ups. Expired sign-up attempts automatically drop out of KV storage after 5 minutes.

### 3. OAuth Account Linking Middleware Execution
- **Choice:** Inject account lookup logic directly in `POST /api/v1/auth/google` and `POST /api/v1/auth/apple`:
  1. Extract `email` from OAuth provider payload.
  2. Query D1: `SELECT id, email, role, name, phone_number FROM users WHERE email = ?`.
  3. If existing row exists: update `google_id` / `apple_id` on the existing user row and return JWT token for that user.
  4. If no row exists: create a new user profile.
- **Rationale:** Completely prevents duplicate user profiles when a user signs up with email/password first and later clicks "Continue with Google".

## Risks / Trade-offs

- **[Risk] Cloudflare KV propagation delay / TTL expiry:** If SMS takes longer than 300 seconds to arrive, the staged registration record will expire.
  - *Mitigation:* Resend OTP extends KV TTL by another 300 seconds.
- **[Risk] OAuth email mismatch:** User registers with email `a@gmail.com` and signs in with Google using `b@gmail.com`.
  - *Mitigation:* Handled via standard OAuth flow (treated as separate account unless linked explicitly in profile settings).
