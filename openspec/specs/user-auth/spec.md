## Purpose

Role-aware authentication and post-auth navigation for the SHPH app: users land
in the correct shell (client or provider) after login/register/OTP, providers
are walked through profile and KYC completion before reaching their dashboard,
and role-gated routes enforce access — mirroring the web app.

### Requirement: Sign-up captures the intended role
The sign-up flow SHALL capture the role the user chooses before the form
appears (client, provider, or both) and SHALL send that role to the backend on
`register/initiate`. The payload MUST use the backend vocabulary `provider` /
`client`; choosing "both" MUST set both `is_provider` and `is_client`.

#### Scenario: User signs up as provider
- **WHEN** a user selects "Sign Up as Service Provider" and completes
  registration up to OTP verification
- **THEN** the initiate payload contains `role: "provider"` and `is_provider: true`

#### Scenario: User signs up as both
- **WHEN** a user selects "Sign Up as Both" and registers
- **THEN** the payload contains `role: "provider"`, `is_provider: true`, and
  `is_client: true`

#### Scenario: User signs up as client
- **WHEN** a user selects "Sign Up as Client" and registers
- **THEN** the payload contains `role: "client"` and does not set
  `is_provider`

### Requirement: Post-auth routing uses real account capabilities
After a successful login, registration-verification, or phone-login
verification, the app SHALL route the user based on the capabilities returned
by `/auth/me/` (`role`, `is_provider`, `is_client`), not on any locally stored
or legacy-table state. Client-only accounts land on the client Home; provider
accounts enter the provider lifecycle.

#### Scenario: Client account logs in and lands on client Home
- **WHEN** a client-only account (is_client true, is_provider false) completes login
- **THEN** the app navigates to the client Home tab

#### Scenario: Provider account logs in and enters provider lifecycle
- **WHEN** a provider account (is_provider true) completes login
- **THEN** the app runs the provider lifecycle check and routes to the
  appropriate provider stage (profile, KYC, review, or dashboard)

#### Scenario: Both-role account can reach either shell
- **WHEN** an account with both `is_provider` and `is_client` logs in
- **THEN** the app lands the user in the shell matching the role used at login
  (provider sign-in → provider shell, client sign-in → client shell)

### Requirement: Provider four-state lifecycle
The app SHALL determine a provider account's current onboarding state from the
profile (`display_name`) and the KYC status, and SHALL route the user to the
matching stage:

- no `display_name` → complete profile page
- KYC `not_submitted` and not skipped → KYC intro
- KYC `not_submitted` but `kyc_skipped` → provider dashboard
- KYC `rejected` → KYC intro (rejected is not skippable)
- KYC `pending` → KYC review/pending page
- KYC `approved` → provider dashboard

#### Scenario: New provider without a profile is sent to profile completion
- **WHEN** a provider account has no `display_name` after auth
- **THEN** the app routes to the complete-profile page

#### Scenario: Provider with pending KYC sees the review page
- **WHEN** a provider account has a `display_name` and KYC status `pending`
- **THEN** the app routes to the KYC review/pending page

#### Scenario: Verified provider reaches the dashboard
- **WHEN** a provider account has a `display_name` and KYC status `approved`
- **THEN** the app routes to the provider dashboard

### Requirement: KYC can be deferred only when never submitted
The app SHALL offer a "do this later" option that persists `kyc_skipped` via
`POST /auth/me/skip-kyc/`. A deferred user SHALL reach the provider dashboard,
but gated provider actions (e.g., post-service) SHALL still route them to KYC.
Deferral MUST NOT be offered when a previous submission was rejected.

#### Scenario: New provider defers KYC and reaches the dashboard
- **WHEN** a provider with KYC status `not_submitted` chooses "I'll do this later"
- **THEN** the app calls the skip-KYC endpoint and routes to the provider dashboard

#### Scenario: Rejected provider cannot defer
- **WHEN** a provider's KYC submission has been rejected
- **THEN** the app does not offer skip and routes them to the KYC intro to resubmit

#### Scenario: Deferred provider attempting a gated action returns to KYC
- **WHEN** a `kyc_skipped` provider navigates to a KYC-gated route
- **THEN** the app redirects them to the KYC intro

### Requirement: Complete-profile page writes to the backend
The complete-profile page SHALL submit the profile (display name, first name,
last name, bio, optional photo) to the backend update endpoint and then run the
post-auth navigation again. `display_name` MUST be sent explicitly.

#### Scenario: Provider completes profile and continues
- **WHEN** a provider fills first and last name (and optional bio/photo) and submits
- **THEN** the app persists the profile via the update endpoint and routes by
  the next lifecycle stage

#### Scenario: Client completes profile and lands on Home
- **WHEN** a client fills in the required profile fields and submits
- **THEN** the app routes to the client Home

### Requirement: Role-gated route access
Routes that require a provider (or a client) SHALL be guarded so that users
without the matching real capability are redirected to their home shell. KYC
lifecycle checks SHALL run before provider-gated routes are reached.

#### Scenario: Client tries to open a provider route
- **WHEN** a client-only user navigates to a provider-only route
- **THEN** the app redirects them to the client Home

#### Scenario: Provider with incomplete onboarding opens a provider route
- **WHEN** a provider-only user navigates to a provider route while their
  profile or KYC is incomplete
- **THEN** the app redirects them to the matching onboarding stage (profile or
  KYC intro)

### Requirement: Enabled controls remain legible
Form controls used across the onboarding flows (checkbox, primary submit
buttons) SHALL keep their interactive affordances visible in both light and
dark mode: the checked state SHALL show a visible check mark and enabled button
text SHALL be readable against its background.

#### Scenario: Checked checkbox shows a visible check mark
- **WHEN** a checkbox in an onboarding form is checked in light mode
- **THEN** the check mark is visible against the checkbox fill

#### Scenario: Enabled submit button shows readable text
- **WHEN** a primary submit button is enabled
- **THEN** its label is legible against the button background in light and dark mode

### Requirement: Client and provider shells follow role state
The app SHALL maintain a role/mode state derived from the real account
capabilities and SHALL render the correct tab shell (client tabs vs provider
tabs) and default home for the active role.

#### Scenario: Provider account shows provider shell
- **WHEN** a provider account is authenticated
- **THEN** the app shows the provider tab shell and provider dashboard as home

#### Scenario: Client account shows client shell
- **WHEN** a client-only account is authenticated
- **THEN** the app shows the client tab shell and client Home as home

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
