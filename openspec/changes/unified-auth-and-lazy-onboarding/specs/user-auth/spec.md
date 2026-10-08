# Spec Delta: `user-auth`

## ADDED Requirements

### Requirement: Unified Auth Screen Real-Time Input Parsing
The system SHALL render a unified authentication gateway interface featuring brand logo header, Google & Apple sign-in options, and a single "Email or Mobile Number" input field with real-time format detection. The input parsing MUST set the auth mode to `AuthMode.email` when matching an email regex, and to `AuthMode.phone` when matching Philippine phone formats (`09...`, `639...`, `+639...`). Philippine mobile numbers starting with `09` MUST be automatically sanitized to `+639` country code format before triggering authentication requests.

#### Scenario: Real-time detection of email input
- **WHEN** the user types `user@example.com` into the single input field
- **THEN** the system sets runtime auth mode to `AuthMode.email` and enables the Continue action to proceed to the Password entry screen

#### Scenario: Real-time detection and sanitization of PH phone input
- **WHEN** the user types `09171234567` into the single input field
- **THEN** the system sets runtime auth mode to `AuthMode.phone`, sanitizes the input to `+639171234567`, and enables the Continue action to send an SMS OTP

### Requirement: Lazy Onboarding & 2-Step Gate
The system SHALL enforce a two-step onboarding workflow featuring an animated progress bar. Step 1 handles initial authentication (Social, Email/Password, or Phone OTP), and Step 2 handles phone verification. Users logging in via Email/Password or Phone MUST transition directly to SMS OTP verification. Users signing in via Google/Apple whose identity payload lacks a verified mobile number MUST be prompted for their mobile number in Step 2, immediately followed by SMS OTP verification. The flow MUST NOT request middle names, home addresses, or billing documents.

#### Scenario: Direct OTP transition for Email and Phone login
- **WHEN** a user completes initial Email/Password or Phone authentication in Step 1
- **THEN** the system immediately transitions the user to the SMS OTP Verification screen in Step 2

#### Scenario: Phone collection prompt for Google/Apple sign-in
- **WHEN** a user signs in via Google or Apple without a verified phone number attached to their OAuth payload
- **THEN** the system displays a mobile number input field in Step 2, immediately followed by the SMS OTP screen

### Requirement: Edge Staging of Pre-Verification Registration Data
The Cloudflare Worker API SHALL stage pre-verification registration details (first name, last name, email, phone number, hashed password) in Cloudflare KV edge cache with a 300-second expiration TTL keyed by phone number or registration UUID. The worker MUST NOT insert an active record into the production database table during initial registration submission.

#### Scenario: Staging registration payload in Cloudflare KV
- **WHEN** a user submits initial sign-up credentials
- **THEN** the Cloudflare Worker stores the registration payload in KV edge cache with a 300-second TTL and dispatches a 6-digit SMS OTP without creating a user record in the production database

### Requirement: Transaction Commitment via OTP Verification
The Cloudflare Worker API SHALL provide a `/api/v1/auth/verify-otp` endpoint to validate the 6-digit OTP code against the staged KV record. Upon valid verification, the worker MUST extract the staged registration payload, insert an active user record into the production database, issue JWT authentication tokens, and purge the KV cache key.

#### Scenario: Successful OTP verification and account creation
- **WHEN** the client submits a matching 6-digit OTP to `/api/v1/auth/verify-otp`
- **THEN** the Cloudflare Worker creates an active user row in the database, returns JWT access/refresh tokens, and deletes the temporary KV cache key

### Requirement: OAuth Account Linking
The Cloudflare Worker API OAuth handler SHALL intercept Google and Apple authentication payloads, extract the verified email address, and query the production database for existing user profiles matching that email. If a matching email exists under an Email/Password account, the worker MUST link the new OAuth identity provider to the existing account row and return an authentication token for the existing account. If no match exists, the worker MUST provision a fresh user profile.

#### Scenario: Account linking for existing email user
- **WHEN** a user signs in with Google or Apple using an email that already exists in the production database
- **THEN** the Cloudflare Worker merges the OAuth provider identity into the existing user record and returns an authentication token bound to that historical user account
