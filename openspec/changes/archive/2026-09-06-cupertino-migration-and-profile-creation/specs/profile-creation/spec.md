## Purpose

Defines the dedicated post-signup step where a new client completes their profile — avatar photo, display name, and optional details — and how navigation and the Profile hub surface incomplete-profile state until that step is finished.

## ADDED Requirements

### Requirement: Post-verification routing into profile completion
After an account with an incomplete profile completes signup verification, the app SHALL route the client to the profile-completion step before reaching the Home shell. A profile SHALL be considered incomplete when it lacks a display name or is not flagged complete on the backend. Clients whose profiles are already complete SHALL proceed directly to Home.

#### Scenario: New account with incomplete profile
- **WHEN** a freshly verified new account has no display name or an incomplete profile flag
- **THEN** the app lands the client on the profile-completion step instead of the Home shell

#### Scenario: Complete profile skips the step
- **WHEN** a verified account already has a complete profile
- **THEN** sign-in proceeds directly to the Home shell with no profile-completion interruption

#### Scenario: Finishing later is allowed
- **WHEN** the client chooses to finish the step later
- **THEN** the client proceeds to Home and the profile remains marked incomplete

### Requirement: Profile-completion step content
The profile-completion step SHALL let the client upload or replace their profile photo and confirm their display name, and MAY collect optional bio and skill/interest details. Email and password SHALL NOT be re-collected (they are established at signup), and the legacy terms checkbox SHALL NOT appear. Finishing SHALL be blocked until the display name is non-empty, and photo upload SHALL show progress and the resulting photo in the avatar circle.

#### Scenario: Avatar upload with progress
- **WHEN** the client picks and uploads a profile photo from the step
- **THEN** the photo uploads to the profile endpoint with visible progress and the resulting photo is rendered in the avatar circle

#### Scenario: Display name required to finish
- **WHEN** the client attempts to finish with an empty display name
- **THEN** the finish action is disabled until a display name is entered

#### Scenario: No re-collected credentials
- **WHEN** the completion step renders
- **THEN** it contains no email field, password field, or legacy terms checkbox

### Requirement: Completion persisted
Finishing the step SHALL persist the display name, any uploaded photo, and optional bio through the backend profile endpoints, and SHALL mark the profile complete so that later sessions route directly to the Home shell.

#### Scenario: Save and continue
- **WHEN** the client finishes the step
- **THEN** the profile is updated (including photo if one was uploaded), marked complete, and the client lands on the Home shell

#### Scenario: Subsequent sessions skip the step
- **WHEN** a client whose profile was completed via the step signs in again
- **THEN** the step is not re-shown

### Requirement: Profile hub reflects incomplete state
Until the profile is complete, the Profile hub SHALL show a "Complete your profile" affordance that routes back to the completion step; once complete it SHALL show only the standard "Edit Profile" affordance.

#### Scenario: Incomplete profile prompt
- **WHEN** a client with an incomplete profile opens the Profile hub
- **THEN** a "Complete your profile" prompt is visible and routes to the completion step

#### Scenario: Completed profile state
- **WHEN** a client's profile is complete
- **THEN** the Profile hub shows only the standard Edit Profile affordance and no completion prompt