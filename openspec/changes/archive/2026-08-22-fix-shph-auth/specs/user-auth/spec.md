## Purpose

Defines how the mobile app authenticates against the SHPH API so sign-in and sign-up round-trip successfully, matching the behavior of the web reference app.

## ADDED Requirements

### Requirement: Email/password sign-in
The system SHALL authenticate a user with email and password against `POST /api/auth/login/`, sending `device_info` in the payload, and on success SHALL persist the returned access token, refresh token, and session id and expose the returned user to the app.

#### Scenario: Successful sign-in
- **WHEN** the user submits a valid email and password on the sign-in page
- **THEN** the system calls the login endpoint with email, password, and device_info, stores the access token, refresh token, and session id, and the app is authenticated

#### Scenario: Invalid credentials
- **WHEN** the user submits an email or password the backend rejects
- **THEN** the login request fails and the system shows the server's error detail without authenticating

#### Scenario: Server unreachable
- **WHEN** the login request cannot reach the server (connection, DNS, or TLS failure with no HTTP response)
- **THEN** the system shows a friendly "cannot reach the server" message rather than a raw exception

### Requirement: Registration via initiate then verify
The system SHALL register a new account using the two-step flow the web app uses: `POST /api/auth/register/initiate/` with the profile payload (`first_name`, `middle_name`, `last_name`, `email`, `phone_number` with country code, `password`, `role`, and `device_info`), then `POST /api/auth/register/verify/` with `{ phone_number, pin }`. On successful verification the system SHALL store the returned tokens and session id and authenticate the user.

#### Scenario: Successful initiate
- **WHEN** the user submits the registration form with valid profile details
- **THEN** the system calls `/api/auth/register/initiate/`, receives the `delivery_method` (`sms` or `email`), and the user is taken to OTP entry

#### Scenario: Successful verification
- **WHEN** the user enters the correct pin for their phone number
- **THEN** the system calls `/api/auth/register/verify/` with phone_number and pin, stores tokens and session id, and the app is authenticated

#### Scenario: Duplicate phone or email
- **WHEN** the submitted phone number or email is already registered
- **THEN** registration fails and the system surfaces the server's field-error detail

### Requirement: Session restore from stored token
The system SHALL restore the authenticated session at startup when a stored access token exists by fetching the current user via `POST /api/auth/me/` with an empty body, and SHALL clear stored tokens and treat the user as signed out if that call fails.

#### Scenario: Valid stored session
- **WHEN** the app starts with a stored access token
- **THEN** the system calls `/api/auth/me/` and marks the session authenticated when the user is returned

#### Scenario: Expired or invalid stored session
- **WHEN** the app starts with a stored access token that is expired or rejected
- **THEN** the system clears stored tokens and the user is signed out

### Requirement: Token refresh
The system SHALL refresh the access token via `POST /api/auth/token/refresh/` using the stored refresh token and session id, update stored tokens on success, and SHALL retry a request that failed with 401 once after a successful refresh.

#### Scenario: Expired access token with valid refresh token
- **WHEN** an API request returns 401 and a refresh token is stored
- **THEN** the system refreshes the access token, stores the new tokens, and retries the original request

#### Scenario: Refresh failure
- **WHEN** the refresh token is invalid or missing
- **THEN** the failed original request propagates and the session is treated as unauthenticated

### Requirement: Logout
The system SHALL sign the user out by calling `POST /api/auth/logout/` with the session id and clearing the stored access token, refresh token, and session id.

#### Scenario: Logout
- **WHEN** the user signs out
- **THEN** the system calls the logout endpoint and clears all stored tokens and session id

### Requirement: Phone/OTP verification
The system SHALL support phone-based OTP flows using the web payload contract (`phone_number`, and `code`/`pin`) via `/api/auth/otp/send-pin/`, `/api/auth/otp/verify-pin/`, `/api/auth/phone-login/send/`, and `/api/auth/phone-login/verify/`, and SHALL persist tokens and session id on successful verification.

#### Scenario: Verify OTP with a valid pin
- **WHEN** the user enters the correct pin for their phone number
- **THEN** the system calls the verify endpoint with phone_number and pin, stores tokens and session id, and authenticates the user

### Requirement: Error detail surfacing
The system SHALL unwrap DRF error responses of the shape `{ error: true, detail: <original> }` so the user-visible message is the server's actual detail or first field error, and SHALL never render raw exception text or a null status code in the UI.

#### Scenario: DRF-wrapped error
- **WHEN** the API returns a non-2xx response wrapped as `{ error: true, detail: { detail: "Invalid credentials" } }`
- **THEN** the user sees "Invalid credentials" (or the equivalent field message)

#### Scenario: No parseable error body
- **WHEN** the API fails with a non-2xx response and no parseable error body
- **THEN** the user sees a generic server error message, never `ShphApiException(null)`
