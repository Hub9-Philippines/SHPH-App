## Purpose

Defines how the service page lets a user contact its provider through a chooser (in-app chat, in-app call, and phone-number actions when available) and how the Contact / Book now button labels are rendered.

## ADDED Requirements

### Requirement: Service page Contact button offers contact choices
When the user taps the Contact action on the service page, the system SHALL present a chooser offering at least "chat in app" and "call using the app" instead of navigating directly to a separate contact page, and neither choice SHALL route through the legacy contact hub.

#### Scenario: Contact opens the chooser not the legacy hub
- **WHEN** the user taps the Contact button on the service page
- **THEN** a chooser appears with "chat in app" and "call using the app" options, and the legacy contact hub page is not opened

#### Scenario: Chat in app chosen
- **WHEN** the user taps Contact and selects "chat in app"
- **THEN** the app opens the provider's in-app chat room

#### Scenario: Call using the app chosen
- **WHEN** the user taps Contact and selects "call using the app"
- **THEN** the app initiates an in-app audio call to the provider through its communication system

### Requirement: Phone-number actions appear when the provider number is available
When the service page can resolve the provider's phone number, the Contact chooser SHALL additionally offer "text via SMS" and "call by number"; the system SHALL explain when the number is unavailable instead of showing non-actionable options.

#### Scenario: Number available
- **WHEN** the provider's phone number is resolvable and the user opens the Contact chooser
- **THEN** the chooser additionally shows "text via SMS" and "call by number"

#### Scenario: Call by number chosen
- **WHEN** the user taps Contact and selects "call by number"
- **THEN** the OS dialer opens pre-filled with the provider's phone number

#### Scenario: SMS chosen
- **WHEN** the user taps Contact and selects "text via SMS"
- **THEN** the OS SMS app opens with the provider's phone number as the recipient

#### Scenario: Number unavailable
- **WHEN** the provider's phone number is not resolvable and the user opens the Contact chooser
- **THEN** "text via SMS" and "call by number" are not offered and the chooser explains the number is unavailable

### Requirement: Service page action button labels fit the button
The service page Contact and Book now buttons SHALL render their labels at a size that fits fully on a single line so the final character does not clip or overflow below the button edge.

#### Scenario: Labels render on one line
- **WHEN** the service page renders the Contact and Book now buttons
- **THEN** each label is fully visible within the button bounds with no descending character clipped at the bottom