# Spec Delta

## ADDED Requirements

### Requirement: Native Social Auth Prompting
The app SHALL trigger native Google (`google_sign_in`) and Apple (`sign_in_with_apple`) OAuth modal prompts when the user selects "Continue with Google" or "Continue with Apple". Upon account selection, the app SHALL retrieve the user's credential email and name. If the account exists, the user SHALL be logged in immediately. If the account is new, the system SHALL navigate to the dedicated Step 2 Social Sign Up page with the email pre-populated.

#### Scenario: Existing user signs in with Google
- **WHEN** an existing user selects "Continue with Google" and chooses their Google account
- **THEN** the app authenticates against `/api/v1/auth/google` and lands on Home

#### Scenario: New user registers with Google
- **WHEN** a new user selects "Continue with Google" and chooses their Google account
- **THEN** the app pre-fills their Google email address and navigates to Step 2 Social Sign Up form requiring First Name and Last Name

### Requirement: Dedicated Step 2 Onboarding Forms per Method
The app SHALL provide method-specific Step 2 registration pages for new accounts:
- **Google / Apple Sign Up**: Renders pre-populated Email from the OAuth prompt, plus editable `First Name` and `Last Name` fields.
- **Email Sign Up**: Renders pre-populated Email from Step 1, plus `First Name`, `Last Name`, and `Password` fields.
- **Mobile Sign Up**: Renders pre-populated Mobile Number from Step 1, plus `First Name`, `Last Name`, optional `Email`, and `Password` fields.

#### Scenario: Google/Apple Step 2 registration entry
- **WHEN** a new Google or Apple user completes the native OAuth prompt
- **THEN** the app opens the Step 2 Social Sign Up page with their email pre-filled and requires entry of First Name and Last Name

#### Scenario: Email Step 2 registration entry
- **WHEN** a new email user submits an unregistered email on Step 1
- **THEN** the app opens the Step 2 Email Sign Up page with the email pre-filled and requires First Name, Last Name, and Password

#### Scenario: Mobile Step 2 registration entry
- **WHEN** a new mobile user submits an unregistered phone number on Step 1
- **THEN** the app opens the Step 2 Mobile Sign Up page with the phone number pre-filled and requires First Name, Last Name, and Password

### Requirement: Dedicated Step 3 Verification per Method
The app SHALL enforce a dedicated Step 3 verification phase upon submitting the Step 2 registration form:
- **Email, Google, and Apple Sign Up**: The system SHALL send a 6-digit verification code to the user's email address via `POST /api/v1/auth/otp/send-email` and navigate to `EmailVerifyWidget`.
- **Mobile Sign Up**: The system SHALL send a 6-digit SMS OTP code to the user's phone number via `POST /api/v1/auth/otp/send-pin` and navigate to `PhoneVerifyUserWidget`.

#### Scenario: Email verification dispatch for Email/Google/Apple sign up
- **WHEN** a user submits the Step 2 registration form for Email, Google, or Apple sign up
- **THEN** the system dispatches a 6-digit code to the user's email address and navigates to the Email Verification page

#### Scenario: SMS verification dispatch for Mobile sign up
- **WHEN** a user submits the Step 2 registration form for Mobile sign up
- **THEN** the system dispatches a 6-digit SMS OTP to the user's phone number and navigates to the Mobile Verification page

### Requirement: Backend Email Verification Endpoints
The backend API (`serbisyo-api`) SHALL expose `POST /api/v1/auth/otp/send-email` (and alias `POST /api/auth/otp/send-email/`) to generate and send a 6-digit email OTP code, and `POST /api/v1/auth/otp/verify-email` (and alias `POST /api/auth/otp/verify-email/`) to verify the code and activate the user profile.

#### Scenario: Dispatch email OTP
- **WHEN** a client posts `{ "email": "user@example.com" }` to `/api/v1/auth/otp/send-email`
- **THEN** the backend generates a 6-digit code, stores it in pending state, sends the email, and returns `200 OK`

#### Scenario: Verify email OTP
- **WHEN** a client posts `{ "email": "user@example.com", "code": "123456" }` to `/api/v1/auth/otp/verify-email`
- **THEN** the backend validates the code, activates the account, and returns authentication JWT tokens
