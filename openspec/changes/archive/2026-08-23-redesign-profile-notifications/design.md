## Context

- **Profile** (`lib/main/profile/profile_widget.dart`): current hero is the teal-gradient card (per archived `profile-settings-ui` spec) with Account/Saved Places/Theme footer and a Dark Mode `TintedToggleTile`; sections are Account/Preferences/System Access with rows already on the shared tinted-row language. Avatar tap-to-upload + Edit Profile pill exist.
- **Notifications** (`lib/pages/my_notifications/my_notifications_widget.dart`, 673 lines): polling every 15s, mark-read/mark-all, tap routing via `_openNotificationDestination`; `AppNotification` carries `type?/route?/title/body/isRead/createdAt`. UI today has no filter chips and no badge-coded rows.
- Theme: `primary` = #1E3A8A app-wide; spacing/radius tokens exist; `TintedMenuTile`-style rows established. Dark mode exists globally — the brief removes dark-mode UI from these two screens only.

## Goals / Non-Goals

**Goals:**
- Profile: light professional header replacing the gradient; task-based section groups incl. provider switch; zero dark-mode controls.
- Notifications: header bar, type-filter chips, badge-coded divider list — with all read/route/poll behavior untouched.

**Non-Goals:**
- Removing the app's global dark theme machinery (other tabs unaffected).
- Changing notification backend/polling or destinations.
- Re-theming the linked Settings screen (keeps its own look per existing capability).
- New provider-role switching logic — the toggle routes to the existing provider entry path; actual role migration stays a backend concern.

## Decisions

1. **Header block**: white canvas Row — 72px avatar in a 2px royal-blue ring (2px gap ring via border+padding), then Column(name headlineSmall w800 / phone bodyMedium / email labelSmall muted) and the outlined pencil pill right-aligned under the text column. Gradient constants (`profileHeroGradient`) become unused by this screen but stay in theme for other consumers (none currently — leave token, note cleanup candidate).
2. **Strict-light enforcement**: Profile scaffold forces `theme.primaryBackground`-independent white via `Theme(data: lightTheme())` wrapper? No — simpler and honest: build colors from fixed light tokens (`Colors.white`, `#F8F9FA` card const added to AppThemeData as `cardTintLight`) so the screen renders identically regardless of app mode. The global dark switch elsewhere keeps working for other tabs. Documented trade-off: Profile ignores app dark preference until a product decision unifies them.
3. **Section groups**: reuse section-header pattern (uppercase muted slate labels) + containers `#F8F9FA` radius 16 holding `TintedMenuTile`s. Row mapping:
   - ACCOUNT: My Bookings → Bookings tab route; Payment & Invoices → PaymentMethods (invoice download rides existing surfaces); Language Preference → LanguageSettings ("English, Filipino" copy per brief).
   - PREFERENCES & UTILITIES: Favorites → Favorites; My Reviews → MyReviews; Referral Program → existing invite/referral surface (InviteEarn flow route) ; Notification Settings → MyNotifications settings entry (gear destination = same notifications-settings target as feed gear); Help Center → HelpPage.
   - SYSTEM ACCESS: provider switch row (switch ON routes to provider account entry — existing post-auth role path; toggling OFF returns to client) using `Switch.adaptive`; Log out destructive crimson row reusing `_handleLogout`.
4. **Dark-mode removal**: delete the Dark Mode `TintedToggleTile` + `_model.switchValue` usage; hero footer (which displayed Theme label) disappears with the gradient. No other dark references remain on the screen after rebuild (verified by grep task).
5. **Notifications header**: replace ScreenHeader usage with bespoke white bar Row [back IconButton → pop, Expanded(center bold "Notification"), gear IconButton → notifications settings destination]. Bar sits on white regardless of app mode (same strict-light approach as Profile, Decision 2).
6. **Filter chips**: `NotificationFilter` enum {all, bookings, offers, system} in model; mapping heuristic from `AppNotification.type`: contains 'book'/'confirm'/'remind' → bookings; 'offer'/'promo'/'discount' → offers; everything else → system (null type → system). Chips row height ~40 horizontal scroll; active chip solid `theme.primary`.
7. **Feed rows**: ListView.separated with `Divider(height:1, thickness:0.5)`; leading 44px circle `surfaceAlt` bg holding two-letter code derived from title initials (fallback icon glyph when title <2 alpha chars); title row = bold title + right timestamp (relative formatter reused from messages pattern — extract tiny helper locally); description bodySmall clamped 2 lines; unread dot indicator retained next to timestamp if `!isRead`.
8. **Behavior preservation**: keep all existing methods (`_markAsRead/_markAllAsRead/_openNotificationDestination/_refreshNotifications`, poll timer) verbatim; only presentation layer changes.

## Risks / Trade-offs

- [Profile ignoring app dark preference may look inconsistent for dark-mode users] → Brief explicitly demands strict light here; revisit if product later wants forced-dark parity.
- [Type heuristics may misfile unknown notification types] → Defaults to System bucket, which is the safest catch-all; mapping lives in one function for tuning.
- [Provider switch without real role migration] → Toggle reflects intent and routes to provider entry; actual role change remains server-driven (existing flows).

## Migration Plan

Two slices: Profile rebuild first, Notifications second; each analyze-green. Rollback per slice.

## Open Questions

None blocking.
