## Purpose

Brings the mobile profile-completion step to parity with the web signup form (photo, first name, last name, bio with a progress indicator) and removes the confusing blank field that silently opened the gallery.

## ADDED Requirements

### Requirement: Photo picker is a clearly labeled control
The completion page SHALL present the profile-photo picker as an obvious, labeled tappable control — a photo preview or placeholder plus an explicit caption such as "Add Photo" / "Change Photo" rendered in a contrast-visible color — and SHALL NOT render any full-width empty-looking field whose only affordance is opening the gallery when tapped.

#### Scenario: Initial state shows a labeled picker
- **WHEN** the completion page first renders with no photo chosen
- **THEN** a clearly labeled photo control (placeholder + "Add Photo" caption) is visible and tappable, with the caption readable on the page background

#### Scenario: Picked photo shows preview and change label
- **WHEN** the user has picked a photo
- **THEN** the control shows the photo preview with an explicit "Change Photo" caption still readable on the background

### Requirement: Completion form matches web signup fields
The completion step SHALL contain a profile photo, a required first name, a required last name, and an optional bio. Submitting SHALL persist `first_name`, `last_name`, a `display_name` computed from the trimmed first and last name, `bio_details`, `is_profile_complete: true`, and `photo_url` when a photo exists.

#### Scenario: Fields render in web order
- **WHEN** the user opens the completion step
- **THEN** first name and last name fields (required), the optional bio, and the photo picker are present

#### Scenario: Finish gates on required names
- **WHEN** either the first name or the last name is empty
- **THEN** the Finish action is disabled

#### Scenario: Finish writes web-parity payload
- **WHEN** first and last name are filled and the user submits
- **THEN** the app persists first_name, last_name, display_name ("<first> <last>" trimmed), bio_details, is_profile_complete true, and photo_url when present

### Requirement: Required-field progress indicator
The completion step SHALL show a progress indicator that reflects which required fields (first name, last name) are filled, mirroring the web CreateProfile step, and SHALL keep Finish enabled only at full required-field progress.

#### Scenario: Empty form shows no progress
- **WHEN** no required fields are filled
- **THEN** the progress indicator shows the empty state and Finish stays disabled

#### Scenario: All required fields filled shows full progress
- **WHEN** both first and last name are filled
- **THEN** the progress indicator reaches full and Finish becomes enabled