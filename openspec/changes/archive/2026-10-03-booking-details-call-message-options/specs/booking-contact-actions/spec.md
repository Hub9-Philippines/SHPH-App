## Purpose

Defines how the booking details page offers contact options to the user: choosing between a phone-number action and the app's own communication system for both calling and messaging, plus how the provider's contact details are resolved.

## ADDED Requirements

### Requirement: Call button offers dial-by-number and in-app call
When the user taps the Call action on the booking details page, the system SHALL present both a "call by number" option that opens the OS dialer with the provider's phone number and a "call using the app" option that initiates an in-app call through the app's communication system.

#### Scenario: Call by number chosen
- **WHEN** the user taps Call and selects "call by number"
- **THEN** the OS dialer opens pre-filled with the provider's phone number

#### Scenario: In-app call chosen
- **WHEN** the user taps Call and selects "call using the app"
- **THEN** the app initiates an in-app call to the provider through its communication system instead of opening the dialer

#### Scenario: No phone number available
- **WHEN** the user taps Call and the provider's phone number is not resolvable
- **THEN** the "call by number" option is not actionable and the system explains the number is unavailable

### Requirement: Message button offers SMS and in-app chat
When the user taps the Message action on the booking details page, the system SHALL present both a "text via SMS" option that opens the OS SMS app addressed to the provider's phone number and a "chat in app" option that opens the provider's in-app chat room.

#### Scenario: SMS chosen
- **WHEN** the user taps Message and selects "text via SMS"
- **THEN** the OS SMS app opens with the provider's phone number as the recipient

#### Scenario: In-app chat chosen
- **WHEN** the user taps Message and selects "chat in app"
- **THEN** the app opens the provider's in-app chat room

#### Scenario: No phone number available
- **WHEN** the user taps Message and the provider's phone number is not resolvable
- **THEN** the "text via SMS" option is not actionable and the system explains the number is unavailable

### Requirement: Provider contact details resolved
The booking details page SHALL resolve the provider's phone number and provider id from the loaded booking's listing or the provider profile API so the dial-by-number and SMS options can be carried out.

#### Scenario: Number resolved from booking data
- **WHEN** the booking details page loads a booking whose listing carries the provider's phone number
- **THEN** that number is used for the call-by-number and SMS actions

#### Scenario: Number resolved from provider profile
- **WHEN** the listing does not carry the phone number but a provider id is present
- **THEN** the page fetches the provider profile and uses the returned phone number