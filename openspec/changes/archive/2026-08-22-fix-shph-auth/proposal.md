## Why

Sign-in and sign-up fail on the phone with `ShphApiException(null): request failed` — a connection-level failure (no HTTP status, no server response). Two problems compound: the deployed SHPH API is not reachable from outside (`api.serbisyohub.ph` fails its TLS handshake, and `api.shph.com`, the domain used by the CDK deploy in `deploy-backend.yml`, accepts no connections), and the Flutter auth client diverges from the working web reference (`E:\Dev\shph-web`) so it would not authenticate correctly even when the API is up.

## What Changes

- Align the Flutter auth client with the web app's auth API contract so a working backend round-trips end-to-end:
  - `GET /api/auth/me/` → `POST /api/auth/me/` with empty body (web uses POST; the OpenAPI spec documents Post-over-GET as the accepted alternative).
  - Add `device_info` to `login` and `register` payloads (web sends it; the backend uses it for session/device tracking and mismatch detection).
  - Email/password sign-up should hit `/api/auth/register/` (one-shot, returns tokens + user) instead of the phone-based two-step `/api/auth/register/initiate/`.
  - Persist `session_id` alongside access/refresh tokens and send it on `logout` and `token/refresh` (web does both).
  - Fix OTP payload keys to match web (`phone_number`/`code`, not `phone`/`pin`) and use the `/auth/otp/send|verify/` and `/auth/phone-login/send|verify/` contract.
- Add DRF error-body unwrapping (`{ error: true, detail: ... }`) to `ShphApiException.fromDio` and surface the server `detail` message in the UI instead of swallowing errors as `null`.
- Show a friendly, actionable message on connection failures ("cannot reach the server") instead of a raw exception snackbar.
- Keep the API base URL overridable via `--dart-define` and verify it matches the real deployed backend host.

## Capabilities

### New Capabilities
- `user-auth`: The contract for client authentication against the SHPH API — email/password login, one-shot registration, session restore (`me`), OTP/phone verification, token refresh, logout, and how authentication errors are surfaced.

### Modified Capabilities
- (none — no existing specs in `openspec/specs/`)

## Impact

- `lib/api/resources/auth_api.dart` — endpoints, methods, payloads, `session_id` persistence.
- `lib/api/shph_token_storage.dart` — store/return `session_id`.
- `lib/api/shph_api_exception.dart` — DRF error unwrap.
- `lib/api/api_config.dart` — base URL documentation/verification.
- `lib/services/auth_service.dart` — `me` POST, user parsing (`data['user']`), `register` one-shot.
- `lib/auth/shph_auth/shph_auth_manager.dart` — register/login wiring, error propagation.
- `lib/pages/signin/signin_widget.dart`, `lib/pages/signup/signup_widget.dart` — error surfacing, phone/OTP payload keys.
- Deployment/ops (user-verifiable): the API host reachable by the phone, TLS cert for that host, `VITE_API_URL`/base URL parity with the web build.
