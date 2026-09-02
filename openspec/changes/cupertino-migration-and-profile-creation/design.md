## Context

The app is a single Flutter codebase (Material + `MaterialApp.router` + GoRouter) that builds for Android (phone-testing) and iOS. There is zero framework Cupertino usage in `lib/`, and the theme sets no iOS page transitions or Cupertino overrides. See `proposal.md` — Why for the audit numbers that motivate this change. The two new capabilities (`cupertino-widget-adoption`, `profile-creation`) and one delta (`pull-to-refresh-parity`) define the required behavior; this document covers how to implement them.

Constraint recap that shapes the design:
- Whole-app iOS look on **both** platforms (user decision), while keeping `AppTheme.of(context)` tokens, Plus Jakarta Sans, the five-tab shell, and the 16/24px grid.
- `lib/pages/create_profile/create_profile_widget.dart` already exists and is routable but orphaned — it is reused/redesigned rather than built from scratch.
- Backend writes go through `ShphUsersApi.updateMe` (`PATCH /api/users/me/update/`) and `ShphUsersApi.uploadPhoto` (`POST /api/users/me/photo/`). No backend changes.

## Goals / Non-Goals

**Goals:**
- Establish a single source of iOS look (theme plumbing + one shared Cupertino component layer) so pages migrate by swapping in components with a near-1:1 API mirror.
- Land the change in shippable, per-widget-family phases, each keeping `flutter analyze` at 0 errors and non-stale tests green.
- Make profile completion reachable: post-verification routing + Profile-hub prompt, persisted via existing endpoints.

**Non-Goals:**
- Full `CupertinoApp` / `CupertinoTabScaffold` rewrite: the Material router shell and existing custom widgets stay; only their look and targeted widgets change.
- Replacing every custom/branded component with a stock Cupertino widget (branded cards, banners, timers stay, restyled).
- Adding backend endpoints or a new state-management layer.
- Platform-adaptive branching (`Platform.isIOS`): the look is uniform on both platforms by design.

## Decisions

### D1. Keep `MaterialApp.router`, style through theme + widget swap
Removing the Material root would break GoRouter integration, `Theme`/`AppTheme.of` reads, and hundreds of custom widgets. Instead: keep the root, add `pageTransitionsTheme` with `CupertinoPageTransitionsBuilder` for **all** platforms, add `cupertinoOverrideTheme`, and add a `cupertinoTheme` override at the `MaterialApp.builder` level so every subtree's `CupertinoTheme.of(context)` is tinted with the app primary key and Plus Jakarta Sans font.
- Alternative: full `CupertinoApp` — rejected, too invasive for this codebase.
- Alternative: platform-conditioned look — rejected by the user (whole-app iOS style).

### D2. One shared Cupertino component layer in `lib/components/cupertino_ui/`
Create small wrapper components with APIs that mirror current usage so pages migrate mechanically:
- `AppButton` → `CupertinoButton` (filled primary, tinted secondary, destructive/red, disabled; ~46px height, ~14px radius; optional full-width; trailing `CupertinoActivityIndicator` loading state).
- `AppTextField` → `CupertinoTextField` (padding, radius, optional prefix icon, `placeholderStyle`), plus optional inline label/error row to preserve the existing validation copy that Material `errorText` provided.
- `AppSwitch` → `CupertinoSwitch` (`activeColor` = primary token; preserves switch semantics for `SwitchListTile` rows via the same component).
- `showAppAlert(...)` → `CupertinoAlertDialog` + `CupertinoDialogAction` with destructive styling; a `confirmDialog` helper for the existing confirm flows.
- `showAppBanner(...)` → transient iOS-style overlay (top/center rounded capsule, auto-dismiss ~2.5s, optional action) replacing `SnackBar`/`ScaffoldMessenger` call sites; a thin `AppFeedback` singleton to keep one implementation.
- `showAppDatePicker(...)` / `showAppTimePicker(...)` → `CupertinoDatePicker` / `CupertinoTimerPicker` inside a rounded modal sheet with Cancel/Done.
- `AppActivityIndicator` → `CupertinoActivityIndicator` with color mapping.
- `CupertinoPageHeader` → `CupertinoNavigationBar`-based header (title centered, `CupertinoNavigationBarBackButton`, automaticallyImplyLeading handled explicitly) replacing `AppBar` — with an accent-extension to keep the existing tinted appbar style where a page used `backgroundColor`.
Rationale: a 1:1-ish component API lets each of the ~189 button sites and ~100 banner sites swap in one edit line with no layout rework.

### D3. Mvnite in per-widget-family passes, gated by analyze/tests
Order that maximizes visible value per low-risk step:
1. Theme plumbing (transitions, CupertinoTheme override) — instant iOS feel, no widget edits.
2. Shared component layer (D2).
3. Families in order: buttons → text inputs → switches → alerts/dialogs → banners/snackbars → pickers → activity indicators → page headers → tab shell → refresh control.
For each pass: swap call sites (audit lists in proposal), then `flutter analyze` (0 errors) + affected tests. Rollback of any pass is a revert of that pass.

### D4. Tab shell: style swap, not scaffold swap
Replace the `BottomNavigationBar` in the shell with a `CupertinoTabBar`-styled bottom bar (same five destinations, active = primary tint, muted inactive; wrapped with `SafeArea`). Keep the existing `IndexedStack` body and `NavBarPage` component model untouched — the shell still "is" Material under the hood, only the bar renders iOS-styled.

### D5. Refresh: `CupertinoSliverRefreshControl` on Profile/Explore/Bookings
Swap the canonical pattern's `RefreshIndicator` to `CupertinoSliverRefreshControl` (primary-tinted foreground) across Profile, Explore, and Bookings, keeping the wrapping scroll physics and per-screen reload logic byte-identical (covered by the `pull-to-refresh-parity` delta). Any shared refresh wrapper in `lib/components/refreshable_page.dart` is updated once.

### D6. Profile creation: redesign the existing page + wire routing
- **Routing** (`lib/auth/post_auth_navigation_flow.dart`): centralize on `checkProfileStatus(userId)`. A profile is incomplete when `displayName` is empty or `isProfileComplete != true`. Incomplete after verification → `context.goNamed(CreateProfileWidget.routeName)`; complete → Home. `client_auth_flow_test.dart`'s `checkProfileStatus always ready_home` assertion is updated to cover the two outcomes (mock complete vs incomplete).
- **Redesign** (`lib/pages/create_profile/create_profile_widget.dart` + model): strip the email/password/terms capture (already collected at signup); keep prefilled display name (from profile first/last); add avatar upload (image_picker → `ShphUsersApi.uploadPhoto` → show in avatar circle with progress) and an optional bio field. Finish → `ShphUsersApi.updateMe({display_name, bio_details, is_profile_complete: true, ...})`; Skip → Home with profile marked incomplete.
- **Profile hub prompt** (`lib/main/profile/profile_widget.dart`): when incomplete, the hero shows a "Complete your profile" pill routed to the completion step instead of the standard Edit pill.
- Route `/createProfile` stays; the provider-era alias route `/pro-profile-setup-form` is left as-is (dead but harmless) to avoid unrelated churn.

## Risks / Trade-offs

- [Large swap volume (189 buttons, 43 app bars, ~100 snackbar sites)] → component layer + per-family passes; each pass stays green and reviewable.
- [CupertinoTextField has no built-in error decoration] → `AppTextField` carries label/error rows so existing validator copy is preserved.
- [iOS has no snackbar; auto-dismiss UX differs] → `showAppBanner` with ~2.5s auto-dismiss + optional action; document the change in feedback feel. For the ~100 legacy `SnackBar` sites we ship a global iOS-capsule `snackBarTheme` in `app_theme.dart` (behavior/material swapped, toast-styled) instead of rewriting each call site; new code should use `AppFeedback.showBanner`.
- NullRoute refreshes (`RefreshIndicator` sites beyond Profile/Explore/Bookings) are left untouched — conversion is scoped to the shared wrapper + those three surfaces; the rest stay Material and are out of scope.
- [`CupertinoNavigationBar` back/automaticallyImplyLeading differs from `AppBar`] → explicit `leading` handling in `CupertinoPageHeader`; verify each header in the pass.
- [Whole-app iOS look on Android is a big visual change] → intended (user-confirmed); note in release notes; dark-mode mappings validated for both `AppTheme.lightTheme()`/`darkTheme()`.
- [Routing change could surprise existing users with incomplete profiles] → routing only redirects genuinely incomplete profiles; skip path always available; Profile hub keeps a visible prompt.

## Migration Plan

Ship as phases, each independently revertable:
1. Theme plumbing (transitions + CupertinoTheme override + tap targets).
2. Cupertino component layer.
3. Buttons → inputs → switches → dialogs → banners → pickers → indicators → headers (family-by-family swaps).
4. Tab shell + safe area.
5. Refresh control parity (Profile/Explore/Bookings).
6. Profile creation: redesign page + routing + Profile-hub prompt + test updates.
Each phase ends with `flutter analyze` (0 errors) and the relevant non-stale test files green, then a manual smoke test on the Android debug build. Rollback = revert the phase's commit.

## Open Questions

None that would change specs, approach, or task breakdown. (Left to implementation judgment: exact banner animation/duration defaults, and whether the `CupertinoTheme` override lives in a new `lib/components/cupertino_ui/cupertino_theme_scope.dart` or in `lib/main.dart` — either satisfies D1.)