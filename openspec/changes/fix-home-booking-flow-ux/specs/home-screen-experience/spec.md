# home-screen-experience Specification (Delta)

## ADDED Requirements

### Requirement: Get Help opens emergency services modal
The home "Get Help" card SHALL open a dedicated emergency services modal picker listing only services that belong to the emergency categories (Electrical, Locksmith, Plumbing, Pest Control). It SHALL NOT open the generic all-services selection panel used by the regular booking flow.

#### Scenario: Get Help opens the emergency picker
- **WHEN** the user taps "Get Help" on the home page
- **THEN** a modal opens listing only emergency-category services and no non-emergency services

#### Scenario: Emergency service selected
- **WHEN** the user selects an emergency service from the picker
- **THEN** the booking flow starts for that service with right-now (immediate) urgency

#### Scenario: Emergency picker dismissed
- **WHEN** the user dismisses the emergency modal
- **THEN** the modal closes and the home page remains visible without navigating away

### Requirement: Provider profiles behave consistently across home sections
Tapping a provider in "Recommended for you" SHALL open the full provider profile page exactly as "View profile" in "Trending near you" does; the two entry points SHALL deliver the same functional provider profile.

#### Scenario: Recommended provider opens the full profile
- **WHEN** the user taps a provider card in "Recommended for you"
- **THEN** the full provider profile page opens with the same content and behavior as "View profile" in "Trending near you"

#### Scenario: Trending view profile unchanged
- **WHEN** the user taps "View profile" in "Trending near you"
- **THEN** the provider profile page opens as before