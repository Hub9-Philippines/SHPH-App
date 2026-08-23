## Purpose

Defines the unified visual system and information architecture for the client Profile hub and the linked Settings screen: a single hero-card anatomy, one reusable tinted-icon menu-row pattern, strict typographic hierarchy, and removal of duplicated navigation entry points, so both screens read as one coherent product.

## ADDED Requirements

### Requirement: Profile screen shows no duplicate navigation entries
The Profile screen SHALL NOT render any quick-action grid or button group that navigates to a destination already reachable from the screen's list sections (previously "Locations", "Payments", "Settings" square buttons).

#### Scenario: Quick actions removed
- **WHEN** the user views the Profile screen below the hero card
- **THEN** no square grid of "Locations", "Payments", or "Settings" shortcut buttons appears between the hero card and the list sections

#### Scenario: Destinations remain reachable exactly once
- **WHEN** the user scans all tappable rows on the Profile screen
- **THEN** each destination (addresses, payment methods, favorites, reviews, settings, help) is offered by at most one row

### Requirement: Profile hero card anatomy
The Profile screen SHALL present the user identity in a single gradient hero card using the premium teal/emerald gradient (#0D808A to #26C6DA) containing, in order: a circular avatar with a subtle outer ring, the display name and contact line, an outlined pill "Edit Profile" action, and a horizontal footer split into three equal low-opacity segments labeled Account Status, Saved Places, and Theme.

#### Scenario: Hero renders identity and metadata
- **WHEN** the Profile screen loads with profile data
- **THEN** the avatar renders as a crisp circle with an outer ring, the display name and email/phone are shown, an outlined "Edit Profile" pill is visible, and the footer shows three evenly balanced columns for Account Status ("Active"), Saved Places ("Set"/"Add"), and Theme ("Light"/"Dark")

#### Scenario: Avatar edit remains available
- **WHEN** the user taps the avatar
- **THEN** the photo pick-and-upload flow opens as before the redesign

### Requirement: Unified menu-row component on Profile and Settings
Every list item on the Profile and Settings screens SHALL render as a full-width card row with rounded corners featuring: a left-anchored icon inside a soft container tinted at 12% opacity with the row's own accent color, a medium-weight bold title, a single-line muted helper description, and a trailing chevron-right accessory — using one consistent glyph style, stroke weight, and bounding box across every row on both screens.

#### Scenario: Row anatomy is uniform
- **WHEN** any menu row is displayed on either screen
- **THEN** it shows the tinted icon container on the left, title above description in the middle, and a chevron-right at the trailing edge, with identical corner radius, padding, and icon sizing as every other row

#### Scenario: Toggle row replaces chevron with switch
- **WHEN** a row's behavior is an on/off setting (Dark Mode)
- **THEN** the row shows a clean toggle switch aligned right instead of a chevron, keeping the same icon-container, title, and description anatomy

### Requirement: Profile lower-section structure
The Profile screen below the hero card SHALL contain exactly these grouped sections in order — Account: "My addresses" (location-pin glyph, teal tint) described "Save, edit, and choose service locations", "Payment methods" (wallet glyph, sky tint) described "Add cards and manage checkout options"; Preferences: "Favorites" (heart glyph, pink tint) described "Jump back into the services you saved", "My Reviews" (star/chat glyph, orange tint) described "See the feedback you have left", "Dark Mode" (moon glyph, dark-gray tint) described "Switch between light and dark appearance"; System Access: "Settings" (gear glyph, slate tint) described "Adjust your language, security, and app preferences", "Help & Support" (question-mark glyph, blue tint) described "FAQs and chat with our support team"; followed by a destructive "Log out" row.

#### Scenario: Account section contents
- **WHEN** the user views the Account section on Profile
- **THEN** exactly My addresses and Payment methods appear with their specified icons, tints, and descriptions, each navigating to its existing destination

#### Scenario: Preferences section contents
- **WHEN** the user views the Preferences section
- **THEN** exactly Favorites, My Reviews, and Dark Mode appear in that order with their specified icons, tints, and descriptions

#### Scenario: System Access section contents
- **WHEN** the user views the System Access section
- **THEN** exactly Settings and Help & Support appear with their specified icons, tints, and descriptions, and tapping Settings opens the Settings screen while Help & Support opens support

#### Scenario: Destructive logout styling
- **WHEN** the Log out row renders
- **THEN** its exit icon, tinted container, and title use soft crimson red, and confirming the dialog still signs the user out

### Requirement: Settings screen structure
The Settings screen SHALL open with a polished dark-gradient header banner titled "Control your app experience" carrying a gear-and-shield glyph, followed by two grouped sections — General & Account Configuration: "Language" (globe, purple), "Notifications" (bell, yellow), "Security" (shield/lock, teal), "Edit Profile" (pencil, sky blue); Legal & Feedback: "Send Feedback" (message-plus, blue), "Terms of Service" (document, navy), "Privacy Policy" (shield-check, blue-gray) — each row following the unified menu-row anatomy.

#### Scenario: Banner and sections render
- **WHEN** the user opens the Settings screen
- **THEN** the dark gradient banner with gear-and-shield icon appears above the General & Account Configuration section (Language, Notifications, Security, Edit Profile) and the Legal & Feedback section (Send Feedback, Terms of Service, Privacy Policy)

#### Scenario: Rows navigate to existing destinations
- **WHEN** the user taps any Settings row
- **THEN** it routes to the same destination as before (language, notifications, security, edit profile, mailto feedback, terms, privacy)

### Requirement: Shared visual tokens across both screens
Both screens SHALL share one token set: white page background, ultra-light gray surface for grouped containers, 16px rounded corners with 16px inner padding on cards, small consistent spacing between groups, muted slate semi-bold section headers, and regular neutral-gray helper text — expressed through theme tokens so dark mode continues to work without hardcoded light-only colors.

#### Scenario: Theme-token compliance
- **WHEN** either screen renders in dark mode
- **THEN** backgrounds, surfaces, borders, and text colors resolve from theme tokens (no hardcoded light-mode hex values), preserving legibility

#### Scenario: Consistent hierarchy
- **WHEN** the user compares page title, section headers, item titles, and descriptions on either screen
- **THEN** page titles are large and bold, section headers are smaller semi-bold muted slate, item titles are medium-weight dark, and descriptions are regular muted gray

### Requirement: Bottom navigation preserved
The app's fixed bottom tab bar SHALL continue showing five targets — Home, Explore, Bookings, Messages, Profile — with the active tab highlighted in the primary tint and inactive tabs muted; the Profile/Settings redesign MUST NOT alter this bar.

#### Scenario: Profile tab highlighted from redesigned screens
- **WHEN** the user is on the Profile screen (or pushes Settings from it)
- **THEN** the bottom bar still shows all five tabs with Profile active-tinted while others remain muted
