# Phase 2 — Provider Experience & Profile Hub: Implementation Spec

**Status:** Pre-execution | **Effort:** ~1 week | **Dependencies:** Phase 1 (design tokens, shared components)
**Reference:** Web app at `C:\Users\Administrator\dev\shph-web`

---

## 2.1 Role-Aware Bottom Navigation — `lib/main.dart`

### 2.1.1 Current State

A single fixed 5-tab bar: Home, Explore, Bookings, Messages, Profile.

### 2.1.2 Target Behavior

When `FFAppState().isProvider` is `true`, swap the tab bar items:

| # | Client Tabs | Provider Tabs |
|---|-------------|---------------|
| 0 | Home (`home_outlined`) | Jobs (`work_outlined`) |
| 1 | Explore (`explore_outlined`) | Earnings (`account_balance_wallet_outlined`) |
| 2 | Bookings (`content_paste_outlined`) | Wallet (`wallet_outlined`) |
| 3 | Messages (`chat_outlined`) | Messages (`chat_outlined`) |
| 4 | Profile (`person_outline`) | Profile (`person_outline`) |

### 2.1.3 Implementation

- Tabs map gets two variants: `_clientTabs` and `_providerTabs`
- Current tab index is tracked per role (preserve position when switching)
- Provider tabs point to existing pro dashboard screens:
  - Jobs → `ProDashboardWidget` (already has its own sub-tabs)
  - Earnings → `ProEarningsWidget`
  - Wallet → `WalletPage` (or `PaymentMethodsWidget`)
  - Messages → `MessagesWidget` (shared with client)
  - Profile → `ProfileWidget` (shared with client)
- No persona simulation banner

### 2.1.4 Files Changed

| File | Change |
|------|--------|
| `lib/main.dart` | Add `_clientTabs`/`_providerTabs` maps; swap based on `FFAppState().isProvider`; add provider tab widgets to imports |

---

## 2.2 Provider Dashboard Polish — `lib/main/pro_dashboard/`

### 2.2.1 Current State

4172-line widget with its own BottomNavigationBar (Jobs, Schedule, Earnings, Messages, Profile). Minimal model. Status pills and metrics use hardcoded hex colors.

### 2.2.2 Target

Apply Phase 1 design tokens to the dashboard:
- Replace status pill hex values with `AppThemeData.status*` colors
- Use `AppThemeData.border`, `surfaceAlt`, `textTertiary` for card/background styling
- Use `ContentContainer` for responsive layout
- Use `ScreenHeader` on sub-pages

### 2.2.3 Status Colors Migration

| Current Hex | Token |
|-------------|-------|
| `#F59E0B` (pending) | `AppThemeData.statusPending` / `statusPendingBg` |
| `#2563EB` (confirmed) | `AppThemeData.statusConfirmed` / `statusConfirmedBg` |
| `#16A34A` (in progress) | `AppThemeData.statusActive` / `statusActiveBg` |
| `#64748B` (completed) | `AppThemeData.statusCompleted` / `statusCompletedBg` |
| `#EF4444` (cancelled) | `AppThemeData.statusCancelled` / `statusCancelledBg` |

### 2.2.4 Files Changed

| File | Change |
|------|--------|
| `lib/main/pro_dashboard/pro_dashboard_widget.dart` | Replace hex → tokens; apply ContentContainer; fix status pills |
| `lib/main/pro_dashboard/pro_dashboard_model.dart` | Minor if needed |

---

## 2.3 Booking Status Pills — `lib/main/bookings/`, `lib/pages/booking_details/`, `lib/pages/tm_flow/`

### 2.3.1 Current State

Each file has its own `switch` on status with hardcoded hex values (three copies of the same mapping).

### 2.3.2 Target

Unify to a shared helper or use `AppThemeData.status*` tokens directly:

```dart
// Shared helper — could live in lib/theme/app_theme.dart or a new lib/theme/status_colors.dart
(Color text, Color bg) statusColors(String status) => switch (status) {
  'confirmed'   => (AppThemeData.statusConfirmed, AppThemeData.statusConfirmedBg),
  'in_progress' => (AppThemeData.statusActive, AppThemeData.statusActiveBg),
  'completed'   => (AppThemeData.statusCompleted, AppThemeData.statusCompletedBg),
  'cancelled'   => (AppThemeData.statusCancelled, AppThemeData.statusCancelledBg),
  'pending'     => (AppThemeData.statusPending, AppThemeData.statusPendingBg),
  _             => (AppThemeData.statusCompleted, AppThemeData.statusCompletedBg),
};
```

### 2.3.3 Files Changed

| File | Change |
|------|--------|
| `lib/main/bookings/bookings_widget.dart` | Replace hex → statusColors() helper |
| `lib/pages/booking_details/booking_details_widget.dart` | Replace hex → statusColors() helper |
| `lib/pages/tm_flow/tm_*.dart` (files with status display) | Replace hex → tokens |

---

## 2.4 Profile Page Redesign — `lib/main/profile/`

### 2.4.1 Current State

992-line widget with green gradient hero card (`#0F8A6C` → `#17B890`), menu sections, photo upload.

### 2.4.2 Target

- Replace green gradient with the web's profile hero gradient (`#0d6d78` → `#63cbd6` — the teal gradient matching Phase 1's new `primaryBrandText`)
- Apply `ScreenHeader`
- Apply `ContentContainer` for layout
- Use `AppThemeData.border`/`surfaceAlt` for menu item backgrounds
- Keep existing structure (avatar, stats row, quick actions, menu sections)

### 2.4.3 Files Changed

| File | Change |
|------|--------|
| `lib/main/profile/profile_widget.dart` | Swap gradient colors; apply ScreenHeader, ContentContainer, border tokens |
| `lib/main/profile/profile_model.dart` | Minor if needed |

---

## 2.5 Dark Mode Pass

### 2.5.1 Scope

Verify and fix dark mode on all pages touched above:
- NavBar tab bar background/selected/unselected colors
- Provider dashboard cards and status pills
- Booking cards and details
- Profile page hero and menu items

Ensure all colors reference `AppTheme.of(context)` or `AppThemeData` tokens instead of hardcoded hex.

---

## 2.6 File Change Inventory

| File | Action | Description |
|------|--------|-------------|
| `lib/main.dart` | **Edit** | Role-aware bottom nav: two tab maps, swap on `isProvider` |
| `lib/main/pro_dashboard/pro_dashboard_widget.dart` | **Edit** | Replace hex → tokens; apply ContentContainer; fix status pills |
| `lib/main/pro_dashboard/pro_dashboard_model.dart` | **Edit** | Minor if needed |
| `lib/main/bookings/bookings_widget.dart` | **Edit** | Replace hex → statusColors() |
| `lib/pages/booking_details/booking_details_widget.dart` | **Edit** | Replace hex → statusColors() |
| `lib/pages/tm_flow/tm_*.dart` | **Edit** | Replace hex status colors |
| `lib/main/profile/profile_widget.dart` | **Edit** | New hero gradient; ScreenHeader; ContentContainer; border tokens |
| `lib/main/profile/profile_model.dart` | **Edit** | Minor if needed |

---

## 2.7 Dependencies

- Phase 1 must be fully merged (all `AppThemeData` tokens, shared components, `isProvider` flag)

---

## 2.8 Non-Goals

- TM flow state machine changes (keep existing logic — visual polish only)
- Admin pages or persona simulation
- Multi-step booking funnel redesign
- TM flow screen redesign beyond status pill colors
- Full app dark mode audit (only pages touched above)

---

## 2.9 Acceptance Criteria

- [ ] `isProvider = true` swaps bottom nav tabs (Jobs, Earnings, Wallet, Messages, Profile)
- [ ] Switching back to `isProvider = false` restores client tabs
- [ ] Tab position is preserved per role
- [ ] All status pills across bookings, booking details, TM flow use `AppThemeData.status*` tokens
- [ ] Provider dashboard cards use `ContentContainer`, `border`, `surfaceAlt` tokens
- [ ] Profile page uses teal hero gradient (`#0d6d78` → `#63cbd6`), ScreenHeader, ContentContainer
- [ ] Dark mode renders correctly on all touched pages
- [ ] No admin features or persona simulation banner added
