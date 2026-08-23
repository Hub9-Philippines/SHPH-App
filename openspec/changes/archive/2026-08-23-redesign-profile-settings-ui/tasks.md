## 1. Theme & shared tokens

- [x] 1.1 Add accent color constants to `lib/theme/app_theme.dart` (accentPink, accentOrange, accentSlate, accentBlue, accentPurple, accentYellow, accentTeal, accentSky, accentNavy, accentBlueGray, destructive crimson) plus the profile hero gradient (#0D808A → #26C6DA) and settings banner gradient as `AppThemeData` statics
- [x] 1.2 Create `lib/components/tinted_menu_tile.dart` with `TintedMenuTile` (46×46 icon container at 12% tint alpha, bold title, muted description, chevron-right trailing, 16px rounded corners, 16px padding) and `TintedToggleTile` (Switch.adaptive trailing), both resolving colors via theme tokens so dark mode works

## 2. Profile screen redesign (`lib/main/profile/`)

- [x] 2.1 Rebuild `_buildProfileHero`: update gradient to the new token, avatar with crisp outer ring, outlined "Edit Profile" pill, low-opacity three-way footer (Account Status / Saved Places / Theme); keep tap-to-upload avatar flow and edit-profile routing
- [x] 2.2 Delete `_buildQuickActions()` and its `_ProfileQuickAction` widget class; remove the call site
- [x] 2.3 Restructure sections to Account (My addresses/teal, Payment methods/sky), Preferences (Favorites/pink, My Reviews/orange, Dark Mode toggle/dark-gray) and System Access (Settings/slate → Settings route, Help & Support/blue → Help route) using `TintedMenuTile`/`TintedToggleTile`; remove "My notifications", "Language", and "Security" rows from Profile
- [x] 2.4 Convert Log out row to the destructive crimson menu-row style; keep confirmation dialog + sign-out logic unchanged
- [x] 2.5 Delete now-unused private widgets (`_ProfileMenuTile`, `_ProfileToggleTile`, `_ProfileMetric` if superseded) and hardcoded hex tints; run `flutter analyze` — 0 errors

## 3. Settings screen redesign (`lib/pages/settings/`)

- [x] 3.1 Polish hero banner: keep dark gradient card + "Control your app experience" copy, swap glyph to gear-and-shield composition using gradient tokens from theme
- [x] 3.2 Regroup into General & Account Configuration (Language/purple globe, Notifications/yellow bell, Security/teal shield-lock, Edit Profile/sky-blue pencil) and Legal & Feedback (Send Feedback/blue message-plus with existing mailto, Terms of Service/navy document, Privacy Policy/blue-gray shield-check) using `TintedMenuTile`
- [x] 3.3 Replace the OutlinedButton log-out with the destructive crimson `TintedMenuTile`; keep dialog/sign-out logic unchanged
- [x] 3.4 Remove old `_buildSettingTile` and neutral-tile styling; run `flutter analyze` — 0 errors

## 4. Verification

- [x] 4.1 Route checklist: every destination previously on Profile (addresses, payments, favorites, reviews, notifications, language, security, settings, help, edit profile, terms, privacy) is reachable exactly once across the two screens
- [x] 4.2 Manual dark-mode pass on both screens: backgrounds, cards, borders, text, tints legible; toggle switches theme live and hero footer Theme label updates
- [x] 4.3 Run `flutter test test/booking_funnel_test.dart` (existing suite) and confirm no regressions; run `flutter analyze` final — 0 errors
