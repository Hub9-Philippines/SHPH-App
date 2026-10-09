# Spec Delta

## ADDED Requirements

### Requirement: Backend Account Lookup Endpoint
The backend API (`serbisyo-api`) SHALL expose `POST /api/v1/auth/check-account` and alias `POST /api/auth/check-account/` accepting a JSON payload with `{ identifier }` (email string or sanitized phone number). The endpoint SHALL query active user records and pending registration stages to return `{ exists: boolean, user_id?: string, has_password?: boolean, has_phone?: boolean }`.

#### Scenario: Query existing email account
- **WHEN** a client sends `{ "identifier": "juan@example.com" }` to `/api/v1/auth/check-account`
- **THEN** the API returns `200 OK` with `{ "exists": true, "user_id": "...", "has_password": true }`

#### Scenario: Query unregistered identifier
- **WHEN** a client sends `{ "identifier": "newuser@example.com" }` to `/api/v1/auth/check-account`
- **THEN** the API returns `200 OK` with `{ "exists": false }`

### Requirement: Standardized Mobile OTP Dispatch and Verification
The backend API SHALL expose `POST /api/v1/auth/otp/send-pin` and alias `POST /api/auth/otp/send-pin/` to dispatch a secure 6-digit OTP code via SMSAPIPH to the requested phone number. The API SHALL expose `POST /api/v1/auth/otp/verify-pin` and alias `POST /api/auth/otp/verify-pin/` accepting `{ phone_number, pin }` to verify the pin and return JWT authentication tokens.

#### Scenario: OTP send-pin dispatches SMS via SMSAPIPH
- **WHEN** a client sends `{ "phone_number": "+639171234567" }` to `/api/v1/auth/otp/send-pin`
- **THEN** the backend dispatches a 6-digit OTP code to `+639171234567` using the configured `SMSAPIPH_KEY` environment secret and returns success

#### Scenario: OTP verify-pin authenticates user
- **WHEN** a client submits a valid matching pin for `+639171234567` to `/api/v1/auth/otp/verify-pin`
- **THEN** the backend verifies the PIN and returns access and refresh JWT tokens

### Requirement: OAuth Account Linking by Email
When a client invokes `POST /api/v1/auth/google` or `POST /api/v1/auth/apple`, the system SHALL query existing user profiles by normalized email. If an existing profile matches, the backend SHALL merge the OAuth authentication event into the existing profile and return tokens mapped to that user profile instead of returning a duplicate profile error.

#### Scenario: Social Google auth with pre-existing email account
- **WHEN** a user triggers Google sign-in with an email that exists under an email/password account
- **THEN** the backend merges the identity and returns valid JWT tokens mapped to the existing user profile
