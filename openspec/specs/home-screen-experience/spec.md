# home-screen-experience Specification

## Purpose

Defines the client home page's content prioritization and profile-action behavior so the page stays relevant for users at different booking stages and uses a mobile-appropriate interaction surface.

## Requirements

### Requirement: Conditional home bookings section
The home page SHALL render the "Your bookings" section only when the signed-in user has at least one booking available to display. When the user has no bookings, the section, including its heading and empty-state content, SHALL be absent from the home-page layout.

#### Scenario: User has bookings
- **WHEN** the home page loads with one or more bookings available for the user
- **THEN** the "Your bookings" section is visible with the available booking content

#### Scenario: User has no bookings
- **WHEN** the home page loads with no bookings available for the user
- **THEN** the "Your bookings" section is not rendered and the next home-page section occupies its place

### Requirement: Always-visible trending section order
The home page SHALL render the "Trending near you" section without requiring a separate visibility condition, and it SHALL place that section immediately before "Need help right now" in the page's vertical content order.

#### Scenario: Trending content is available
- **WHEN** the home page renders with nearby trending items
- **THEN** "Trending near you" appears above "Need help right now" and displays the available items

#### Scenario: Trending content is empty or unavailable
- **WHEN** the home page renders without nearby trending items
- **THEN** the "Trending near you" section remains present according to the home-page layout contract and does not disappear because of the former visibility condition

### Requirement: Profile action uses a modal bottom sheet
Activating the home-page profile button SHALL open the profile action content in a modal bottom sheet anchored to the bottom of the viewport, while preserving the existing profile actions and allowing the user to dismiss the sheet.

#### Scenario: User opens profile actions
- **WHEN** the user taps the profile button on the home page
- **THEN** a modal bottom sheet opens from the bottom and presents the existing profile actions

#### Scenario: User dismisses profile actions
- **WHEN** the profile action bottom sheet is open and the user dismisses it
- **THEN** the sheet closes and the home page remains visible without navigating away

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

### Requirement: Home page skeleton loading state
While the home feed is loading, the home page SHALL render shimmer skeleton placeholders in place of its always-visible data-driven sections — the "Trending near you" provider rail and the "EXPLORE SERVICES" category rail — instead of empty rails, and SHALL swap those placeholders for the loaded content once the feed resolves. Static sections (emergency help, seasonal offer, referral banner) SHALL remain visible during loading. A pull-to-refresh gesture SHALL keep the currently displayed content on screen and must not replace it with skeleton placeholders.

#### Scenario: Initial load shows skeleton placeholders
- **WHEN** the home page begins loading its initial feed and the trending/category data is not yet available
- **THEN** the "Trending near you" and "EXPLORE SERVICES" sections render shimmer skeleton placeholders (matching the Bookings/Messages skeleton pattern) instead of empty horizontal rails

#### Scenario: Skeletons replaced by loaded content
- **WHEN** the initial feed finishes loading
- **THEN** the skeleton placeholders are replaced by the real trending-provider and category content

#### Scenario: Refresh preserves visible content
- **WHEN** the user triggers a pull-to-refresh while content is already displayed
- **THEN** the displayed content stays on screen with the refresh indicator, and skeleton placeholders do not appear
