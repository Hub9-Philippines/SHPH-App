## Why

The client Profile screen (`lib/main/profile/profile_widget.dart`) and Settings screen (`lib/pages/settings/settings_widget.dart`) duplicate navigation paths to the same destinations (Locations/Payments/Settings quick-action grid vs. list tiles), and their list rows mix mismatched icon styles (filled rounded Material glyphs, outline glyphs, one-off pastel backgrounds). This clutters the Profile hub and makes the two screens read as different products instead of one system.

## What Changes

- **Remove** the three square quick-action buttons ("Locations", "Payments", "Settings") from the Profile screen to eliminate duplicate navigation paths.
- **Redesign** the Profile hero card around the premium teal/emerald gradient (#0D808A → #26C6DA): crisp circular avatar with outer ring, clean outlined "Edit Profile" pill, and a balanced low-opacity footer split showing Account Status / Saved Places / Theme.
- **Restructure** the Profile screen's lower sections:
  - Account: My addresses (teal pin tint) and Payment methods (sky wallet tint) — kept as the single entry points for booking-critical destinations.
  - Preferences: Favorites (pink heart tint), My Reviews (orange star/chat tint), Dark Mode toggle (dark-gray moon tint).
  - System Access: Settings (slate gear tint) and Help & Support (blue question tint).
  - Log out row rendered with soft crimson title/icon as a destructive action.
- **Polish** the Settings screen: dark gradient header banner ("Control your app experience") with a gear-and-shield glyph; General & Account Configuration section (Language purple globe, Notifications yellow bell, Security teal shield/lock, Edit Profile sky-blue pencil); Legal & Feedback section (Send Feedback blue message-plus, Terms of Service navy document, Privacy Policy blue-gray shield-check).
- **Unify iconography** across both screens: every list icon renders inside a soft 12%-opacity tinted container matching its own color, at a single uniform glyph style, stroke weight, and bounding box (Lucide/Phosphor-style minimal set).
- **Standardize containers and type**: full-width card rows with 16px rounded corners, 16px inner padding, subtle spacing between groups; strict hierarchy of bold page titles, semi-bold muted section headers, medium dark item titles, and regular muted helper descriptions — all via theme tokens so dark mode keeps working.
- Keep the fixed five-tab bottom navigation (Home, Explore, Bookings, Messages, Profile) with the Profile tab active-tinted; no behavioral navigation changes.

## Capabilities

### New Capabilities
- `profile-settings-ui`: Unified visual system and information architecture for the client Profile hub and Settings screen — hero card anatomy, menu-row component spec, icon tint system, section structure, destructive-action styling, and removal of duplicated quick actions.

### Modified Capabilities

## Impact

- `lib/main/profile/profile_widget.dart` + `profile_model.dart` — hero card, section layout, tile components, removal of `_buildQuickActions`.
- `lib/pages/settings/settings_widget.dart` (+ model) — hero banner polish, re-tinted tiles, regrouped sections.
- Possibly a new shared widget in `lib/components/` for the tinted-icon menu row reused by both screens.
- `pubspec.yaml` — optional new icon-font dependency if a Lucide/Phosphor set is adopted (see design.md decision); no other dependency changes.
- No backend/API changes; all routes and destinations stay as-is.
