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
