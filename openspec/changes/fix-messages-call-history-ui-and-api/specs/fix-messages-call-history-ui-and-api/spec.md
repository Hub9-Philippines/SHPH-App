# Spec Delta

## Purpose
Provides complete chat participant profile rendering in the messages list, past call history querying and rendering, and removes skip controls from identity verification.

## ADDED Requirements

### Requirement: Complete Chat Participant Profile Rendering
The system SHALL return and render complete participant details (name, avatar, role, last message snippet, unread count) in the messages chat list.

#### Scenario: User opens messages tab
- **WHEN** a client or provider views the messages chat list
- **THEN** each conversation item displays the other participant's verified name, avatar image, role indicator, last message text, and unread badge

### Requirement: Historical Call Logs Querying & Display
The system SHALL store, fetch, and display past 1-on-1 audio and video call sessions in the call history tab.

#### Scenario: User views call history tab
- **WHEN** a user selects the Call History tab in the Messages page
- **THEN** the system fetches and displays past calls with the participant's name, avatar, call type (audio/video), call status (`accepted`, `missed`, `ended`), and duration

### Requirement: Mandatory Identity Verification Flow
The system SHALL require completion of identity verification without providing a header skip action button.

#### Scenario: User opens Verify Your Identity page
- **WHEN** a user navigates to the Verify Your Identity screen
- **THEN** the screen renders without a "Skip for now" header button, requiring formal verification submission or back navigation
