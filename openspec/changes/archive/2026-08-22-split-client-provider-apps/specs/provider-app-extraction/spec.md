## Purpose

Defines the behavior contract for the standalone SerbisyoHub Provider app extracted from this codebase: it serves provider accounts exclusively, carries over today's provider capabilities without functional loss, and points client accounts back to the SerbisyoHub client app.

## ADDED Requirements

### Requirement: Provider-only account experience
The Provider app SHALL treat every signed-in session as a service-provider session and MUST NOT offer client booking surfaces (service browsing, booking funnel as a customer).

#### Scenario: Provider signs in
- **WHEN** a provider-capable account signs in to the Provider app
- **THEN** the main shell shows the provider tab set (Jobs, Schedule, Earnings, Messages, Profile)

#### Scenario: Client-only account signs in
- **WHEN** an account with no provider capabilities signs in to the Provider app
- **THEN** the app displays a notice directing the user to the SerbisyoHub client app instead of entering the provider shell

### Requirement: Provider capability parity
The Provider app SHALL carry over the provider features available before the split: incoming job requests and bids management, schedule/availability calendar, earnings dashboard and history, own-service listing (create/edit/manage), provider analytics, reviews of the provider's work, and the provider KYC/identity-verification flow.

#### Scenario: Provider manages availability after migration
- **WHEN** a previously onboarded provider opens the Schedule tab in the Provider app
- **THEN** their existing availability data loads from the same backend and can be edited as before

#### Scenario: Provider completes verification
- **WHEN** a provider starts or resumes identity verification in the Provider app
- **THEN** document capture and submission succeed against the same backend verification endpoints

#### Scenario: Provider responds to a job request
- **WHEN** a new job request arrives while the provider is using the app
- **THEN** the provider can view, accept/bid on, or decline it exactly as before the split

### Requirement: Independent application identity
The Provider app SHALL be distributed under its own application ID/package name so it installs side-by-side with the client app, with its own store listing metadata.

#### Scenario: Both apps installed on one device
- **WHEN** a device has both the SerbisyoHub client app and the Provider app installed
- **THEN** neither installation replaces or conflicts with the other

### Requirement: Shared backend contract
The Provider app SHALL consume the same SHPH REST API (`https://serbisyohubph.com`, overridable for development) used by the client app; no backend endpoint changes are required solely because of the split.

#### Scenario: API base URL override in development
- **WHEN** the Provider app is launched with a custom API base URL for local testing
- **THEN** all provider features operate against that environment identically to the client app's override mechanism
