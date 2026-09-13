## MODIFIED Requirements

### Requirement: Post-auth routing uses real account capabilities
After a successful login, registration-verification, or phone-login
verification, the app SHALL route the user based on the capabilities returned
by `/auth/me/` (`role`, `is_provider`, `is_client`), not on any locally stored
or legacy-table state. Client-only accounts land on the client Home, except
that a client whose profile is complete but whose KYC has neither been
submitted nor skipped SHALL be routed through the client KYC flow before Home;
provider accounts enter the provider lifecycle.

#### Scenario: Client account logs in and lands on client Home
- **WHEN** a client-only account (is_client true, is_provider false) completes login and has submitted or skipped KYC
- **THEN** the app navigates to the client Home tab

#### Scenario: Provider account logs in and enters provider lifecycle
- **WHEN** a provider account (is_provider true) completes login
- **THEN** the app runs the provider lifecycle check and routes to the
  appropriate provider stage (profile, KYC, review, or dashboard)

#### Scenario: Both-role account can reach either shell
- **WHEN** an account with both `is_provider` and `is_client` logs in
- **THEN** the app lands the user in the shell matching the role used at login
  (provider sign-in → provider shell, client sign-in → client shell)

#### Scenario: Client with a complete profile but no KYC goes to the KYC flow
- **WHEN** a client-only account completes login with a complete profile whose KYC status is `not_submitted` and no skip is recorded
- **THEN** the app opens the client KYC onboarding screen instead of Home

#### Scenario: Client completes profile and continues to KYC
- **WHEN** a client finishes the profile-completion step and their KYC is neither submitted nor skipped
- **THEN** post-auth navigation routes them to the client KYC onboarding screen before Home