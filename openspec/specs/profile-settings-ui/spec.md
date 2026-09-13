## Purpose

Defines the unified visual system and information architecture for the client Profile hub and the linked Settings screen: a clean professional header block on a strict light canvas, one reusable tinted-icon menu-row pattern, strict typographic hierarchy, and removal of duplicated navigation entry points, so both screens read as one coherent product.

### Requirement: Profile screen shows no duplicate navigation entries
The Profile screen SHALL NOT render any quick-action grid or button group that navigates to a destination already reachable from the screen's list sections (previously "Locations", "Payments", "Settings" square buttons).

#### Scenario: Quick actions removed
- **WHEN** the user views the Profile screen below the hero card
- **THEN** no square grid of "Locations", "Payments", or "Settings" shortcut buttons appears between the hero card and the list sections

#### Scenario: Destinations remain reachable exactly once
- **WHEN** the user scans all tappable rows on the Profile screen
- **THEN** each destination is offered by at most one row

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
- **WHEN** the user taps the avatar or the Edit Profile pill
- **THEN** the photo pick-and-upload flow / edit-profile routing opens as before the redesign

#### Scenario: No gradient remnant
- **WHEN** the header block renders
- **THEN** no teal gradient surface, Account Status/Saved Places/Theme footer segments, or legacy hero chrome appear on the screen

### Requirement: Unified menu-row component on Profile and Settings
Every list item on the Profile and Settings screens SHALL render as a full-width card row with rounded corners featuring: a left-anchored icon inside a soft container tinted at 12% opacity with the row's own accent color, a medium-weight bold title, a single-line muted helper description, and a trailing chevron-right accessory — using one consistent glyph style, stroke weight, and bounding box across every row on both screens.

#### Scenario: Row anatomy is uniform
- **WHEN** any menu row is displayed on either screen
- **THEN** it shows the tinted icon container on the left, title above description in the middle, and a chevron-right at the trailing edge, with identical corner radius, padding, and icon sizing as every other row

#### Scenario: Toggle row replaces chevron with switch
- **WHEN** a row's behavior is an on/off setting (the provider-account switch)
- **THEN** the row shows a clean toggle switch aligned right instead of a chevron, keeping the same icon-container, title, and description anatomy

### Requirement: Profile lower-section structure
The Profile screen below the header block SHALL contain exactly these grouped sections in order, each enclosed in containers with 16px rounded corners — ACCOUNT: "My Bookings" described "View past and upcoming jobs", "Payment & Invoices" described "View history and download invoices", "Language Preference" described "English, Filipino"; PREFERENCES & UTILITIES: "Favorites" described "Jump back into the services you saved", "My Reviews" described "See the feedback you have left", "Referral Program" described "Share and earn rewards", "Notification Settings" described "Control alerts and reminders", "Help Center" described "FAQs and chat with our support team"; SYSTEM ACCESS: "Are you a service provider?" described "Switch to Provider Account" with a right-aligned toggle switch instead of a chevron, followed by the destructive "Log out" row described "Sign out of your account on this device". No Dark Mode entry MAY appear on this screen.

#### Scenario: Account section contents
- **WHEN** the user views the ACCOUNT section
- **THEN** exactly My Bookings, Payment & Invoices, and Language Preference appear in that order, each navigating to its existing destination

#### Scenario: Preferences section contents
- **WHEN** the user views the PREFERENCES & UTILITIES section
- **THEN** exactly Favorites, My Reviews, Referral Program, Notification Settings, and Help Center appear in that order

#### Scenario: System Access contents
- **WHEN** the user views the SYSTEM ACCESS section
- **THEN** the "Are you a service provider?" row renders its right-aligned toggle switch, and tapping Log out shows the destructive crimson styling with confirmation before sign-out

#### Scenario: No dark mode controls
- **WHEN** the full Profile screen is scanned
- **THEN** no Dark Mode toggle, option, or theme status label is present

### Requirement: Settings screen structure
The Settings screen SHALL open with a polished dark-gradient header banner titled "Control your app experience" carrying a gear-and-shield glyph, followed by two grouped sections — General & Account Configuration: "Language" (globe, purple), "Notifications" (bell, yellow), "Security" (shield/lock, teal), "Edit Profile" (pencil, sky blue); Legal & Feedback: "Send Feedback" (message-plus, blue), "Terms of Service" (document, navy), "Privacy Policy" (shield-check, blue-gray) — each row following the unified menu-row anatomy.

#### Scenario: Banner and sections render
- **WHEN** the user opens the Settings screen
- **THEN** the dark gradient banner with gear-and-shield icon appears above the General & Account Configuration section (Language, Notifications, Security, Edit Profile) and the Legal & Feedback section (Send Feedback, Terms of Service, Privacy Policy)

#### Scenario: Rows navigate to existing destinations
- **WHEN** the user taps any Settings row
- **THEN** it routes to the same destination as before (language, notifications, security, edit profile, mailto feedback, terms, privacy)

### Requirement: Shared visual tokens across both screens
The Profile hub SHALL enforce a strict light theme on the white canvas (#FFFFFF) with grouped list containers tinted #F8F9FA at 16px rounded corners, royal-blue primary accents, neutral/cool-gray typography, and NO dark-mode controls or labels; the linked Settings screen retains its existing token-driven theming. Both screens keep muted slate semi-bold section headers and regular neutral-gray helper text expressed through theme tokens.

#### Scenario: Strict light theme on Profile hub
- **WHEN** the Profile hub renders regardless of any app-level theme preference
- **THEN** the canvas is white, grouped containers are #F8F9FA at 16px radius, primary accents are royal blue, and no dark-mode UI exists on this screen

#### Scenario: Consistent hierarchy
- **WHEN** the user compares section headers, item titles, and descriptions
- **THEN** section headers are semi-bold muted slate, item titles medium-weight bold dark, and descriptions regular muted gray

### Requirement: Bottom navigation preserved
The app's fixed bottom tab bar SHALL continue showing five targets — Home, Explore, Bookings, Messages, Profile — with the active tab highlighted in the primary tint and inactive tabs muted; the Profile/Settings redesign MUST NOT alter this bar.

#### Scenario: Profile tab highlighted from redesigned screens
- **WHEN** the user is on the Profile screen (or pushes Settings from it)
- **THEN** the bottom bar still shows all five tabs with Profile active-tinted while others remain muted
