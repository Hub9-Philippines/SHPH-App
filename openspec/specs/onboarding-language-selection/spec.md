# onboarding-language-selection Specification

## Purpose

Adds a first-run language-selection step to onboarding that offers exactly English and Filipino, applies the choice immediately, and keeps the app's language pickers consistent.

## Requirements

### Requirement: Onboarding offers exactly two languages
The onboarding flow SHALL present a language-selection step that lists only English and Filipino. Choosing a language SHALL update the app's active locale immediately and persist the choice; continuing SHALL proceed through the rest of onboarding to sign-in.

#### Scenario: Exactly two options are listed
- **WHEN** the language-selection step renders
- **THEN** the only options are English and Filipino

#### Scenario: English is selected
- **WHEN** the user picks English
- **THEN** the app's locale becomes English immediately and the choice persists across restarts

#### Scenario: Filipino is selected
- **WHEN** the user picks Filipino
- **THEN** the app's locale becomes Filipino immediately and the choice persists across restarts

#### Scenario: Continuing after selection reaches sign-in
- **WHEN** the user selects a language and continues through onboarding
- **THEN** the flow proceeds to the sign-in entry

### Requirement: Settings language list matches onboarding
The Settings language screen SHALL offer the same two options as onboarding — English and Filipino only — and SHALL apply the selected language to the whole app immediately.

#### Scenario: Settings lists only the two supported languages
- **WHEN** the user opens the Settings language screen
- **THEN** only English and Filipino rows render and no other language rows appear

#### Scenario: Selection applies immediately
- **WHEN** the user changes the language on the Settings screen
- **THEN** the app's strings update in real time without a restart
