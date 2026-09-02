## Why

The app renders an Android-flavored Material look everywhere (189 button call sites, ~100 SnackBar/ScaffoldMessenger sites, 43 AppBars, 13 switches, 18 dialog triggers, 28 TextFields, a single `BottomNavigationBar` shell) with no iOS-native styling at all — zero framework Cupertino widgets are used and the theme sets no `pageTransitionsTheme`, `cupertinoOverrideTheme`, or platform-aware behavior. Separately, profile creation is a hard gap: `lib/pages/create_profile/create_profile_widget.dart` exists and is routable (`/createProfile`) but is orphaned — a newly verified account is always routed straight to Home by `PostAuthNavigationFlow`, so no user ever completes a dedicated profile step.

This change gives the app a cohesive iOS-style (Cupertino) experience on both platforms and turns profile creation into a real, wired post-signup step.

## What Changes

- **Adopt Cupertino widgets app-wide (iOS look on both Android and iOS):** replace themed Material widget families with their Cupertino equivalents while preserving brand tokens (royal-blue primary, Plus Jakarta Sans, five-tab shell, 16px grid, empty-state copy):
  - Buttons: `ElevatedButton`/`OutlinedButton`/`TextButton`/`FilledButton` → `CupertinoButton` (filled/rounded variants).
  - Text inputs: `TextField`/`TextFormField` + `OutlineInputBorder`/`InputDecoration` → `CupertinoTextField` (rounded, per-field decoration in a single `CupertinoTextFormFieldRow` where forms group fields).
  - Switches: `Switch`/`SwitchListTile` → `CupertinoSwitch`.
  - Dialogs & confirmations: `AlertDialog`/`showDialog` → `CupertinoAlertDialog` + `CupertinoDialogAction`.
  - Snackbars/affordances: `SnackBar` → a Cupertino-styled transient overlay/banner (in-app notification pattern).
  - Bottom shell: `BottomNavigationBar` → Cupertino tab-bar styling (still five tabs, primary-tinted active item) inside a `CupertinoPageScaffold`-compatible shell; keeps `SafeArea`.
  - Pickers: `showDatePicker`/`showTimePicker` → Cupertino date/time pickers presented in modal sheets.
  - Indicators: `CircularProgressIndicator` → `CupertinoActivityIndicator`; `RefreshIndicator` → `CupertinoSliverRefreshControl` (reload semantics unchanged).
  - Navigation bars: `AppBar` → `CupertinoNavigationBar` with `CupertinoIconButton.back`; keep the existing grid/spacing tokens.
  - Icons stay `Icons.*` (Cupertino glyph set is thin); segmented controls adopt `CupertinoSegmentedControl` where the existing custom sliding segmented control does not already cover the case.
- **Theme plumbing:** set iOS page transitions for every platform (`CupertinoPageTransitionsBuilder` in `pageTransitionsTheme`), add `cupertinoOverrideTheme` and `materialTapTargetSize`, and keep `useMaterial3: false`.
- **Wire profile creation:** redesign the existing create-profile page into a Cupertino-styled "Complete your profile" step (avatar upload, confirm display name, optional bio) and route users with incomplete profiles into it from post-auth navigation; the step may be skipped and re-prompted later. Remove the redundant email/password/terms capture (already collected at signup).
- **BREAKING (visual):** the entire app's look changes from Material to iOS style on Android devices too (phone-testing build) — this is the intended outcome, not a regression.
- Existing behaviors preserved: five-tab shell, 16px/24px layout grid, empty-state copy, reload semantics of pull-to-refresh, brand color/typography tokens.

## Capabilities

### New Capabilities
- `cupertino-widget-adoption`: app-wide iOS-style widget behavior on both platforms — which Material widgets are replaced, the theme plumbing that makes transitions/overrides/tap targets iOS-like, and the rules for preserving the brand tokens, five-tab shell, layout grid, and icon set.
- `profile-creation`: the post-signup profile-completion step — when it is triggered (incomplete profile after verification), what it collects (avatar upload, display name, optional bio), how completion is persisted (`updateMe` + photo upload), and how the Profile hub reflects incomplete/complete state.

### Modified Capabilities
- `pull-to-refresh-parity`: the canonical pull-to-refresh pattern changes its widget/style from `RefreshIndicator` to the iOS `CupertinoSliverRefreshControl`, while the refresh gesture's "works in every state" and "reload semantics unchanged" requirements stay intact.

## Impact

- **Code:** `lib/main.dart` (shell/transitions/theme), `lib/theme/app_theme.dart` (theme plumbing), all `lib/pages/*` and `lib/main/*` widget files with Material widget call sites (buttons, inputs, dialogs, snackbars, switches, app bars, indicators, pickers), `lib/auth/post_auth_navigation_flow.dart` (profile-creation routing), `lib/pages/create_profile/*` (redesign), `lib/pages/profile/*` + `lib/main/profile/profile_widget.dart` (incomplete-profile state + routing), shared plane in `lib/components/`.
- **APIs:** no backend contract changes — reuse `ShphUsersApi.updateMe` (`PATCH /api/users/me/update/`), `uploadPhoto` (`POST /api/users/me/photo/`), and `ProfilesService`.
- **Dependencies:** no new packages expected (Cupertino widgets ship with Flutter).
- **Docs/specs:** delta spec for `pull-to-refresh-parity`; the `create_profile` route stays but its duplicate signup fields are removed; `docs/design-system.md` updated to reflect Cupertino look.