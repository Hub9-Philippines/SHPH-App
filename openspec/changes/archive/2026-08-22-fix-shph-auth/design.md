## Context

See `proposal.md` — Why. The Flutter auth path (`lib/api/resources/auth_api.dart`, `lib/api/shph_api_client.dart`, `lib/services/auth_service.dart`, `lib/auth/shph_auth/shph_auth_manager.dart`, `lib/pages/signin|signup/`) diverges from the working web reference (`src/services/api.ts` → `authApi`, `src/stores/auth.ts`). The OpenAPI spec documents Post-over-GET and the web client exercises the real deployed backend, so the web client is the source of truth. Auth also fails at the network layer right now (`ShphApiException(null)` = no HTTP response), so error handling must distinguish "can't reach server" from "bad credentials".

## Goals / Non-Goals

**Goals:**
- Round-trip sign-in, registration, session restore, refresh, and logout against the SHPH API exactly as the web app does.
- Surface the server's real error `detail` and a friendly message on connection failures instead of raw `ShphApiException(null)`.

**Non-Goals:**
- Rebuilding the sign-up form UX wholesale — only the fields/payload needed for web parity.
- Admin auth, biometric, or social login (stubs stay as-is).
- Fixing the deployed host/DNS/TLS — that is an ops/backend verification the user must confirm (see Open Questions).

## Decisions

### D1. Align every auth endpoint/payload to the web `authApi` contract
Map Flutter `ShphAuthApi` methods to web's `authApi`/store calls and change payloads to the exact keys the backend expects:

| Flutter method (current) | Web reference | Change |
|---|---|---|
| `login({email,password})` → POST `/api/auth/login/` | `authApi.login` sends `{email,password,device_info}` | add `device_info` |
| `getCurrentUser()` → GET `/api/auth/me/` | `authApi.me()` → **POST** `/auth/me/` with `{}` | switch to POST |
| `registerInitiate({email,password})` | `registerInitiate(payload)` with names/email/`phone_number`/`password`/`role` | full profile payload + `device_info`; `+63` normalization |
| `registerVerify(payload)` | `registerVerify(phone,pin)` → `{phone_number, pin}` | payload keys `phone_number`,`pin` |
| `sendOtpPin({phone})` | `{phone_number}` | key fix |
| `verifyOtpPin({pin,phone})` | `{phone_number, pin}` (and `code` for `/otp/verify/`) | key fix |
| `logout()` (no body) | `{session_id}` | send `session_id` |
| refresh (no `session_id`) | `{refresh, session_id}` | add `session_id` |

Rationale: the web client is proven against the live backend; DRF serializers are strict about field names. Alternatives (keeping current keys) rejected — they would keep returning 400/validation errors.

### D2. Persist `session_id` alongside tokens
Add `session_id` to `ShphTokenStorage` (`saveTokens`, getter, `clear`). `ShphAuthApi._persistTokens` reads `data['session_id']` (web: `data.access/refresh/session_id`). Sent on logout and token refresh. Rationale: web requires it for session management; the spec requires logout/refresh to include it.

### D3. `device_info` via a small service
New `lib/services/device_info_service.dart` using `device_info_plus` (already a dependency) to build the web-compatible payload: `platform`, `platformType`, `osVersion`, `deviceModel`, `deviceName`, `appVersion`, and a stable `deviceFingerprint` (hash of platform+model+id). Attached to login/register/initiate. Rationale: the backend uses it for session/device-mismatch detection; web sends it on both flows. Alternative (omit) rejected — login may require it.

### D4. DRF error unwrap + friendly connection error
Extend `ShphApiException.fromDio` to mirror web `unwrapApiError`: when response data is `{ error: true, detail: <x> }`, use `<x>` (string, or first field-error string). Add a small helper (in `lib/services/error_handler.dart` or the auth pages) that maps connection-level failures (`ShphApiException` with `statusCode == null`, Dio `connectionError`/`connectionTimeout`) to "Cannot reach the server. Check your internet connection and try again." Rationale: the spec requires never showing `ShphApiException(null)`; server `detail` must reach the user.

### D5. Registration flow = initiate → OTP → verify (web parity)
Sign-up page collects the web RegisterPage fields (names, email, `+63` phone, password, role default client) and calls `registerInitiate`; on `delivery_method` it navigates to OTP; `registerVerify({phone_number, pin})` completes auth. Remove the legacy Supabase `ProfilesTable()` duplicate-phone check in `signup_widget.dart`. Rationale: matches the actual used web flow and spec Requirement "Registration via initiate then verify".

## Risks / Trade-offs

- [Backend host unreachable during dev] → keep base URL `--dart-define SHPH_API_BASE_URL` overridable; app must show the connection message. The live host was confirmed by probing the deployed backend: `https://serbisyohubph.com` (from web `.gitlab-ci.yml` `VITE_API_URL=https://serbisyohubph.com/api`); `POST /api/auth/login/` returns 400/`{"detail":"Invalid credentials"}` there, while `https://api.serbisyohub.ph` fails TLS and `api.shph.com` accepts no connections.
- [Backend rejects `device_info` or extra fields] → start with web's exact keys; if the backend is stricter, drop fields during apply without changing the spec.
- [`session_id`/`delivery_method` shape unknown until live] → treat as nullable String; code defensively, verify against the live API.
- [Changing `me` to POST touches session restore] → covered by existing `AuthService.initialize()` path; verify app cold-start stays authenticated.

## Migration Plan

- Client-only, no schema/migration. Ship as one change on `feat/ui-ux-reconstruction`.
- Rollback: revert the touched auth files; behavior reverts to today's (connection-error) state.

## Open Questions

- **Live API URL** — RESOLVED by probing the deployed backend: `https://serbisyohubph.com` (web `.gitlab-ci.yml` `VITE_API_URL=https://serbisyohubph.com/api`). `POST https://serbisyohubph.com/api/auth/login/` → 400 `{"detail":"Invalid credentials"}` (alive), `POST /api/auth/me/` → 401 wrapper (confirms POST me). The current Flutter default `https://api.serbisyohub.ph` fails TLS and is wrong; change the `ApiConfig` default to `https://serbisyohubph.com`.
