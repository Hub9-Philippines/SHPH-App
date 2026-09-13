## MODIFIED Requirements

### Requirement: Profile hero card anatomy
The Profile screen SHALL present the user identity in an ultra-clean professional header block on the white canvas — no gradient card — containing, from left to right: a crisp circular profile photo bordered by a subtle 2px royal-blue ring; and a text column with the display name in large bold type, the phone number string beneath it, and the smaller muted email under that. The inline action pill varies with account state:
- profile incomplete (no display name or `is_profile_complete` false) — a "Complete your profile" pill routed to the completion step;
- profile complete but not verified — a "Verify now" pill routed to the client KYC flow;
- verified — no action pill, and a "Verified" badge accompanies the identity block.

A separate compact "Edit Profile" control (pencil pill) remains available so editing stays reachable in every state.

#### Scenario: Header renders identity and metadata
- **WHEN** the Profile screen loads with profile data
- **THEN** the avatar renders as a crisp circle with a 2px royal-blue ring, and the display name appears large and bold with phone number and muted email beneath

#### Scenario: Profile incomplete shows the completion pill
- **WHEN** the profile is incomplete (`is_profile_complete` false or no display name)
- **THEN** the inline action pill reads "Complete your profile" and routes to the profile-completion step

#### Scenario: Complete but unverified shows Verify now
- **WHEN** the profile is complete and the account is not verified
- **THEN** the inline action pill reads "Verify now" and routes to the client KYC flow

#### Scenario: Verified shows the badge and no action pill
- **WHEN** the account is verified
- **THEN** no Complete/Verify action pill renders and the identity block shows the "Verified" badge

#### Scenario: Avatar edit remains available
- **WHEN** the user taps the avatar or the Edit Profile control
- **THEN** the photo pick-and-upload flow / edit-profile routing opens as before the redesign

#### Scenario: No gradient remnant
- **WHEN** the header block renders
- **THEN** no teal gradient surface, Account Status/Saved Places/Theme footer segments, or legacy hero chrome appear on the screen