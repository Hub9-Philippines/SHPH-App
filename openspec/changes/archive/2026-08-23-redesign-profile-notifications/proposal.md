## Why

The Profile hub still leads with the teal gradient hero from the previous generation while the app's brand has moved to Deep Royal Blue (#1E3A8A), and its section list no longer matches how clients actually use the app. The Notifications page lacks any filtering and presents messages as uniform boxes without scannable category badges. This redesign aligns both screens to the royal-blue light theme, restructures Profile into task-based groups (including a provider-account switch), and turns Notifications into a filterable, badge-coded feed.

## What Changes

- **Profile Hub**
  - Teal gradient hero block removed entirely; replaced by an ultra-clean white header: circular photo with 2px royal-blue ring, large bold username, phone number, muted email, and an inline blue-outlined "Edit Profile" pill (pencil icon).
  - Card containers use #F8F9FA on the white canvas with 16px corner radius.
  - Sections rebuilt: ACCOUNT (My Bookings, Payment & Invoices, Language Preference), PREFERENCES & UTILITIES (Favorites, My Reviews, Referral Program, Notification Settings, Help Center), SYSTEM ACCESS ("Are you a service provider?" switch row, destructive Log out row) — all rows using the established tinted-icon menu-row anatomy.
  - Dark Mode toggle/labels removed from this screen; strict light theme enforced.
- **Notifications Feed** (`/my-notifications`)
  - White header bar: back chevron left, centered bold "Notification" title, settings gear absolute-right.
  - Horizontally scrolling capsule filter chips — All (solid royal-blue active), Bookings, Offers, System — filtering the feed by notification type.
  - Feed rows in an unbounded list separated by ultra-thin dividers: left-anchored circular badge with two-letter service code or icon glyph, bold title with right-aligned muted timestamp, 1–2 line description detail.
  - Existing mark-read/tap-routing/polling behavior preserved unchanged.
- **Strict light theme** enforced across both screens: no dark-mode switches, options, or status labels.

## Capabilities

### New Capabilities
- `notifications-feed`: Header, filter-chip segmentation, and feed-row presentation contract for the client Notifications page.

### Modified Capabilities
- `profile-settings-ui`: Profile hero replaced by a light professional header block; lower-section structure rebuilt around Account / Preferences & Utilities / System Access (with provider switch); strict light-theme tokens applied to the Profile hub.

## Impact

- `lib/main/profile/profile_widget.dart` (+ model) — hero removal/replacement, section rebuild, dark-mode toggle removal, provider-switch row (routes to provider entry per existing auth role flows)
- `lib/pages/my_notifications/my_notifications_widget.dart` (+ model) — header bar, filter chips + type mapping, feed-row rebuild
- Reuses existing `TintedMenuTile`-style row language; new small pieces only where needed (notification badge coder, filter chips)
- No backend changes; notification type data already arrives via `AppNotification.type`
