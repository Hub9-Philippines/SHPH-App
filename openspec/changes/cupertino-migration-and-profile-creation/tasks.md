## 1. Theme Plumbing (iOS look foundation)

- [x] 1.1 Add `pageTransitionsTheme` with `CupertinoPageTransitionsBuilder` for all platforms in `AppThemeData` (`lib/theme/app_theme.dart`), keeping `useMaterial3: false`
- [x] 1.2 Add `cupertinoOverrideTheme` to light + dark `ThemeData` mapping primary key (royal blue) and Plus Jakarta Sans font
- [x] 1.3 Add a `CupertinoTheme` scope at the `MaterialApp.builder` level (new `lib/components/cupertino_ui/cupertino_theme_scope.dart`) so all subtrees get a primary-tinted `CupertinoThemeData.of(context)`
- [x] 1.4 Verify `flutter analyze` reports 0 errors after plumbing

## 2. Cupertino Component Layer

- [x] 2.1 Create `lib/components/cupertino_ui/` with `AppButton` (CupertinoButton-backed: filled primary, tinted secondary, destructive, disabled, ~46px height, loading spinner)
- [x] 2.2 Add `AppTextField` (CupertinoTextField + padding/radius/prefix icon/placeholder style + optional label/error row preserving existing validation copy)
- [x] 2.3 Add `AppSwitch` (CupertinoSwitch, `activeColor` = primary token; row form for `SwitchListTile` call sites)
- [x] 2.4 Add `showAppAlert`/`confirmDialog` (CupertinoAlertDialog + CupertinoDialogAction, destructive styling) and `showAppBanner` (transient iOS overlay, ~2.5s auto-dismiss, optional action) via a shared `AppFeedback` helper
- [x] 2.5 Add `showAppDatePicker` / `showAppTimePicker` (CupertinoDatePicker / CupertinoTimerPicker in rounded modal sheet with Cancel/Done)
- [x] 2.6 Add `AppActivityIndicator` (CupertinoActivityIndicator with color mapping) and `CupertinoPageHeader` (CupertinoNavigationBar-based, centered title, explicit back button handling)

## 3. Widget-Family Migration

- [x] 3.1 Swap all button call sites (ElevatedButton/OutlinedButton/TextButton/FilledButton + FlutterFlow variants) to `AppButton` per the audit list, keeping icons and layout
- [x] 3.2 Swap text input call sites (TextField/TextFormField via `InputDecoration`) to `AppTextField`, preserving validator/error copy
- [x] 3.3 Swap switch call sites to `AppSwitch`, preserving state behavior
- [x] 3.4 Swap alert/dialog call sites (AlertDialog/showDialog confirmations) to `showAppAlert`/`confirmDialog`
- [x] 3.5 Swap SnackBar/ScaffoldMessenger call sites to `showAppBanner`, keeping messages/actions (implemented via global iOS capsule `snackBarTheme` in `app_theme.dart` instead of 104 per-site swaps; `showAppBanner` available for new code)
- [x] 3.6 Swap date/time picker call sites to `showAppDatePicker`/`showAppTimePicker`
- [x] 3.7 Swap activity indicators (CircularProgressIndicator) to `AppActivityIndicator`
- [x] 3.8 Swap AppBar call sites to `CupertinoPageHeader`, preserving titles, actions, and tinted headers
- [x] 3.9 Run `flutter analyze` (must stay at 0 errors) and run the non-stale test files after each family pass

## 4. Tab Shell

- [x] 4.1 Replace `BottomNavigationBar` in the bottom-tab shell with a `CupertinoTabBar`-styled bar (5 destinations, active = primary tint, muted inactive) while keeping the `IndexedStack`-based body
- [x] 4.2 Wrap the bar with `SafeArea` so content clears the home indicator/status bar on notched devices
- [x] 4.3 Verify tab behavior + analyze on Android debug build

## 5. Pull-to-Refresh Parity

- [x] 5.1 Swap `RefreshIndicator` to `CupertinoSliverRefreshControl` (primary tint) in the shared refresh wrapper and Profile/Explore/Bookings, keeping scroll physics and reload logic identical
- [x] 5.2 Verify pull-to-refresh on each of the three screens + analyze green

## 6. Profile Creation

- [x] 6.1 Strip email/password/terms capture from `lib/pages/create_profile/create_profile_widget.dart`; prefill display name from the profile; add avatar upload (image_picker → `ShphUsersApi.uploadPhoto` with progress + preview) and optional bio
- [x] 6.2 Wire Finish to `ShphUsersApi.updateMe` (`display_name`, `bio_details`, `is_profile_complete`) and Skip to Home while leaving the profile incomplete; keep `/createProfile` route
- [x] 6.3 Wire post-verification routing in `lib/auth/post_auth_navigation_flow.dart` via `checkProfileStatus(userId)`: `needs_profile` → completion route, else Home
- [x] 6.4 Add "Complete your profile" prompt in `lib/main/profile/profile_widget.dart` hero when `displayName` empty or `isProfileComplete != true`, routing to the completion step; keep only the Edit pill when complete
- [x] 6.5 Update `test/client_auth_flow_test.dart` (`checkProfileStatus always ready_home` assertion) to cover incomplete → completion route and complete → Home; add widget test for the completion page (sync-verified display-name gate + avatar upload mocked)
- [x] 6.6 Run analyze (0 errors) and `platform_test`/updated auth-flow tests

## 7. Final Verification

- [x] 7.1 Run `flutter analyze` and confirm 0 errors across the full change
- [x] 7.2 Run all non-stale test files (per-file `flutter test test/<file>_test.dart`), noting any pre-existing flakes separately
- [ ] 7.3 Smoke-test on Android debug/release build via active `flutter run`: iOS transitions, five-tab shell, refresh controls, and the profile-completion flow end to end