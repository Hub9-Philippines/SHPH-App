## Purpose

Defines how the in-app call permission sheet requests the real operating-system microphone and camera permissions and reports the true outcome instead of assuming success.

## ADDED Requirements

### Requirement: Permission sheet requests the real OS permission
When the user allows the in-app call permission sheet, the system SHALL request the actual operating-system permission it advertises (microphone for an audio call; microphone and camera for a video call) and SHALL reflect the returned status in the sheet state.

#### Scenario: OS grants the permission
- **WHEN** the user taps the allow action and the operating system grants the requested permission
- **THEN** the sheet shows the access-granted state and proceeds with the call action

#### Scenario: OS denies the permission
- **WHEN** the user taps the allow action and the operating system denies the requested permission
- **THEN** the sheet shows a denial message, does not proceed with the call action, and does not report that access was granted

### Requirement: Permanently denied permission offers settings
When the requested permission is permanently denied such that the OS will not re-prompt, the system SHALL present a way for the user to open the app settings to change the permission manually rather than looping the allow prompt or faking a grant.

#### Scenario: Permanent denial
- **WHEN** the user taps the allow action and the permission is permanently denied
- **THEN** the sheet explains the permission is blocked and offers an action that opens the app settings screen