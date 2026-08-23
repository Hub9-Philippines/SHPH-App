## 1. Confirm live API endpoint

- [x] 1.1 Host confirmed by probing the deployed backend: `https://serbisyohubph.com` (from web `.gitlab-ci.yml` `VITE_API_URL=https://serbisyohubph.com/api`); `POST /api/auth/login/` returned 400 `{"detail":"Invalid credentials"}` and `POST /api/auth/me/` returned the 401 error wrapper — server is live and the contract matches
- [x] 1.2 Change `lib/api/api_config.dart` default `SHPH_API_BASE_URL` from `https://api.serbisyohub.ph` to `https://serbisyohubph.com` (keep `--dart-define` override) and record the change in `docs/ui-ux-reconstruction-plan.md`

## 2. Auth API client alignment (`lib/api/resources/auth_api.dart`)

- [x] 2.1 Add `session_id` persistence: change `_persistTokens` to also save `data['session_id']`; add `session_id`/`delivery_method` handling in `registerInitiate`
- [x] 2.2 Add `device_info` to `login()` and `registerInitiate()` payloads
- [x] 2.3 Change `getCurrentUser()` from `GET /api/auth/me/` to `POST /api/auth/me/` with empty body `{}`
- [x] 2.4 Fix OTP payload keys to web contract: `sendOtpPin` → `{phone_number}`, `verifyOtpPin` → `{phone_number, pin}` (and `code` for `/otp/verify/` if added)
- [x] 2.5 Add `phoneLoginSend`/`phoneLoginVerify` (`/api/auth/phone-login/send/`, `/api/auth/phone-login/verify/`) per web contract
- [x] 2.6 Make `logout()` send `{session_id}` and `_refreshAccessToken()` send `{refresh, session_id}`

## 3. Token storage (`lib/api/shph_token_storage.dart`)

- [x] 3.1 Add `_sessionIdKey`, persist `sessionId` in `saveTokens`, add `getSessionId()`, and clear it in `clear()`

## 4. Error handling (`lib/api/shph_api_exception.dart`, `lib/services/error_handler.dart`)

- [x] 4.1 In `ShphApiException.fromDio`, unwrap DRF `{ error: true, detail: <x> }` bodies (string or first field-error) before falling back to `error.message`
- [x] 4.2 Add a helper that maps connection-level failures (`statusCode == null`, Dio `connectionError`/`connectionTimeout`) to "Cannot reach the server. Check your internet connection." and use it in sign-in/sign-up catch blocks instead of raw `e.toString()`

## 5. Auth service + manager (`lib/services/auth_service.dart`, `lib/auth/shph_auth/shph_auth_manager.dart`)

- [x] 5.1 `AuthService.login`/`registerVerify`: set `_currentUser = data['user']` (with fallback to whole `data`), keep `data['user']` parsing consistent with web
- [x] 5.2 `ShphAuthManager.createAccountWithEmail`: send the web RegisterPage payload (names, email, `+63` phone, password, role) to `registerInitiate` and propagate the returned `delivery_method`; `signInWithEmail` should rethrow/surface errors instead of returning `null` silently (align with `auth_util.dart` error handling)
- [x] 5.3 Verify `AuthService.initialize()` cold-start restore still works with the POST `/me/` change and clears tokens on failure

## 6. Sign-up / OTP page parity (`lib/pages/signup/`, `lib/pages/otp_page/`, `lib/pages/phone_verify_user/`)

- [x] 6.1 Replace the legacy `ProfilesTable()` duplicate-phone check in `signup_widget.dart` with the API-driven registration flow (web RegisterPage parity)
- [x] 6.2 Ensure sign-up calls `registerInitiate` with names/email/`+63` phone/password/role and routes to OTP on `delivery_method`
- [x] 6.3 Align OTP/phone-verify pages to send `phone_number` + `pin` (web `registerVerify`) and show server `detail` errors

## 7. Sign-in page parity (`lib/pages/signin/signin_widget.dart`)

- [x] 7.1 Wire email/password submit through `AuthService.login` and surface server `detail`/connection message (no raw `ShphApiException` text)
- [x] 7.2 Wire phone/OTP submit through `phoneLoginSend`/`phoneLoginVerify` (web contract) with the same error surfacing

## 8. Verify

- [x] 8.1 `flutter analyze` passes with 0 errors
- [x] 8.2 `flutter test test/booking_funnel_test.dart` and `flutter test test/proximity_scoring_test.dart` pass (individual files; the full suite's `widget_test.dart` is stale and fails by design). NOTE: `proximity_scoring_test` 20/20 pass; `booking_funnel_test` 3/4 pass — the one failure ("Live matching screen times out after 30 seconds") is pre-existing and unrelated to this change (verified it fails on clean HEAD too; it's caused by an Unsplash `NetworkImage` load erroring in the test env)
- [ ] 8.3 Manual phone test: sign-in and sign-up round-trip against the confirmed live host (success + wrong-credentials + airplane-mode paths)
