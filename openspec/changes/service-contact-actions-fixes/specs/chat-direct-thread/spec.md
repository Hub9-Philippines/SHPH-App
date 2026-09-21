## Purpose

Defines how the app resolves a direct chat thread with a provider (fetching an existing one or creating a new one) so "chat in app" flows open a real chat room.

## ADDED Requirements

### Requirement: Direct chat thread resolved without a booking
When any contact flow needs the provider's chat room, the system SHALL get an existing direct chat thread with that provider or create one, without requiring a booking, so the resulting room can be opened.

#### Scenario: Thread exists
- **WHEN** the user chooses "chat in app" and a direct thread with the provider already exists
- **THEN** the app opens the existing chat room

#### Scenario: Thread does not exist
- **WHEN** the user chooses "chat in app" and no direct thread with the provider exists yet
- **THEN** the app creates the direct thread and opens the new chat room

#### Scenario: No signed-in user or provider
- **WHEN** the user is not signed in or the provider id is missing
- **THEN** the app does not open a room and the flow ends with an error message to the user