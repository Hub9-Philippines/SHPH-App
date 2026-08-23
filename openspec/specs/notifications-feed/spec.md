## Purpose

Defines the client Notifications feed presentation: a clean header bar, capsule filter segmentation over notification types, and badge-coded feed rows that keep existing read-state and routing behavior intact.

## ADDED Requirements

### Requirement: Notifications header bar
The Notifications screen SHALL open with a white header bar containing: a back navigation chevron button on the left, a centered bold "Notification" page title, and a settings gear icon on the absolute right edge.

#### Scenario: Header composition
- **WHEN** the user opens the Notifications screen
- **THEN** back chevron, centered bold title, and right-edge gear icon are all visible on a white bar

#### Scenario: Gear opens settings
- **WHEN** the user taps the settings gear
- **THEN** the notification settings surface (existing notifications-settings destination) opens

### Requirement: Capsule filter chips
Directly below the header, the screen SHALL render a horizontally scrolling row of capsule filter chips — All, Bookings, Offers, System — where the active chip is highlighted in solid royal blue with white text and inactive chips use subtle gray backgrounds with dark text; selecting a chip SHALL scope the feed to notifications of the matching type (All shows everything).

#### Scenario: Active chip styling
- **WHEN** the user selects the "Bookings" chip
- **THEN** it renders solid royal blue with white label while other chips revert to gray backgrounds with dark text

#### Scenario: Feed scoping follows chip
- **WHEN** each chip is activated in turn
- **THEN** only notifications matching that type category are listed; All restores the full feed

### Requirement: Notification feed row anatomy
Notification items SHALL render as full-width rows inside an unbounded list separated by ultra-thin dividers. Each row contains: a left-anchored circular badge container holding a two-letter service code or icon glyph; a bold notification title with a right-aligned muted timestamp on the same line; and one-to-two lines of regular-weight description text beneath the title. Unread items remain visually distinguishable per existing behavior.

#### Scenario: Row anatomy complete
- **WHEN** a notification renders
- **THEN** its circular code/icon badge, bold title, right-aligned muted timestamp, and up-to-two-line description are all present with thin dividers separating rows

#### Scenario: Badge codes derive from context
- **WHEN** a notification belongs to a known service or category
- **THEN** its circular badge shows either the two-letter service code (e.g., "LC") or a fitting icon glyph

### Requirement: Preserved notification behaviors
Adopting the new presentation MUST NOT alter existing notification behavior: tap-through routing to notification destinations, individual mark-as-read on tap, mark-all-as-read availability, and periodic polling for new items all continue working as before.

#### Scenario: Tap marks read and routes
- **WHEN** the user taps an unread notification with a destination
- **THEN** it is marked read and routed exactly as in the prior implementation
