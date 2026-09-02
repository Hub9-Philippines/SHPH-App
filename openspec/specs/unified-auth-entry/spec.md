## Purpose

Defines the merged welcome + sign-in experience: a single auth entry screen greets every user with the Serbisyo brand and welcome artwork, serves both sign-in (phone/email) and the path to sign-up, and replaces the former standalone welcome page.

### Requirement: Single auth entry screen
The app SHALL route unauthenticated users from splash and onboarding directly to the merged sign-in screen; a separate welcome/role-selection page MUST NOT exist between them.

#### Scenario: Cold start while signed out
- **WHEN** the app launches with no active session
- **THEN** the user lands on the merged sign-in screen without an intermediate welcome step

#### Scenario: Onboarding completion
- **WHEN** the user finishes the onboarding carousel
- **THEN** navigation proceeds directly to the merged sign-in screen

### Requirement: Branded welcome header
The sign-in screen SHALL present a welcome header containing "Welcome to Serbisyo" branding and a compact version of the existing welcome illustration above the sign-in form, without pushing the form below the fold on common phone sizes.

#### Scenario: Sign-in screen renders
- **WHEN** the merged sign-in screen is displayed
- **THEN** the user sees the welcome artwork (smaller than the removed welcome page's) together with the "Welcome to Serbisyo" headline and the phone/email tabs in one scrollable view

### Requirement: Direct path to sign-up
From the merged sign-in screen, the "Sign Up" affordance SHALL navigate users directly to the signup screen without passing through any intermediate page.

#### Scenario: New user taps Sign Up
- **WHEN** a user taps "Sign Up" on the merged sign-in screen
- **THEN** the signup screen opens immediately

### Requirement: Legacy welcome route retired
The `/signOptions` route SHALL be removed; attempts to open it SHALL resolve to the merged sign-in screen rather than an error or dead end.

#### Scenario: Deep link or stale reference to /signOptions
- **WHEN** the app receives navigation to the removed welcome route
- **THEN** the user is shown the merged sign-in screen
