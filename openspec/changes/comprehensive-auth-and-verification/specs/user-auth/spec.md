# Spec Delta

## MODIFIED Requirements

### Requirement: Registration via initiate then verify
The system SHALL register a new account using a strict two-step verification flow: `POST /api/v1/auth/register/initiate` with the complete profile payload (`first_name`, `middle_name`, `last_name`, `email`, `phone_number` with PH country code `+63`, `password`, `role`, and `device_info`), which stores the pending registration and dispatches a 6-digit OTP code without creating a user record in the main users database. Then `POST /api/v1/auth/register/verify` with `{ phone_number, pin }` SHALL validate the pin against pending registrations, insert the active user into the database, return JWT tokens, and authenticate the session.

#### Scenario: Successful initiate
- **WHEN** the user submits the sign-up form with valid details (first_name, optional middle_name, last_name, email, phone_number, password)
- **THEN** the system stores a pending registration record, sends an OTP pin via SMS/SMS-gateway abstraction, and redirects the user to OTP verification screen without creating a database user record

#### Scenario: Successful verification
- **WHEN** the user enters the correct 6-digit pin for their phone number
- **THEN** the system validates the pin, creates the active user account in the `users` table, stores JWT access/refresh tokens, and authenticates the user into the app

#### Scenario: Duplicate phone or email
- **WHEN** the submitted phone number or email is already registered in the active users table
- **THEN** registration initiation fails and the system surfaces the server's field-error detail without sending OTP

## ADDED Requirements

### Requirement: Multi-Method Third-Party & Provider Authentication Gateway
The system SHALL support Google Sign-In (`POST /api/v1/auth/google`) and Apple Sign-In (`POST /api/v1/auth/apple`) using identity token validation against the API backend, persisting tokens and creating/authenticating user accounts.

#### Scenario: Successful Google Sign-In
- **WHEN** a user completes Google Sign-In authentication on their device and submits the ID token to `POST /api/v1/auth/google`
- **THEN** the system verifies the token, resolves or registers the user, returns JWT tokens, and logs the user into the app shell
