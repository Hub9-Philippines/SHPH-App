## Context

Both screens already exist and route correctly:

- `lib/main/profile/profile_widget.dart` (client tab in `lib/main/`) — gradient hero (currently `#0D6D78 → #63CBD6`), `_buildQuickActions()` square grid, and four sections of `_ProfileMenuTile`/`_ProfileToggleTile` widgets with per-row hardcoded hex tints.
- `lib/pages/settings/settings_widget.dart` — dark gradient banner plus three sections whose tiles use a neutral `surfaceAlt` icon background with `theme.primary` glyphs (the "mismatched" look), and an outlined Log out button.

Constraints from AGENTS.md: theme tokens only (`AppTheme.of(context)`, no hardcoded light-only hex), font stays `GoogleFonts.plusJakartaSans()`, `flutter analyze` must stay at 0 errors, pubspec `dependency_overrides` are pinned. Dark mode is live via `setDarkModeSetting`, so every color needs both modes to resolve. The existing theme already exposes `primaryBackground` (white in light mode), `secondaryBackground`, `surfaceAlt` (#F1F5F9 light / #2A2A3C dark), `border`, `secondaryText`, `textTertiary`, `error`, and `shadowCard`.

## Goals / Non-Goals

**Goals:**
- One shared tinted-icon menu-row widget used by both screens.
- Hero card polish to the exact gradient/anatomy specified, keeping avatar upload + edit-profile routing intact.
- Information architecture fix: Profile = user-specific interactions; Settings = configuration/legal. Notifications + Language move conceptually under Settings only.
- Icon uniformity: single glyph family, size box, stroke weight; tint containers derived from each row's accent at 12% alpha.

**Non-Goals:**
- No changes to routes, route names, auth flow, or backend/API calls.
- No redesign of other tabs or the provider dashboard; bottom nav untouched except confirming active tint behavior.
- No new l10n strings pipeline work (copy is English-only as today).

## Decisions

1. **Icon set: stay on Material's rounded-outline family, standardized** (all glyphs chosen from `Icons.*_rounded` filled set at fixed 22px inside 46×46 containers, or uniformly outlined — one family, never mixed). Rationale: zero new dependencies, honors the pinned-pubspec caution, and the "dual-tone" effect the brief wants comes from glyph-on-tinted-container, not from the font. Alternative considered: adding `phosphor_flutter` (native duotone weight) — rejected for this change to avoid dependency risk; can be a follow-up swap since all icons funnel through one widget.
2. **New shared component `lib/components/tinted_menu_tile.dart`** exposing `TintedMenuTile` (chevron trailing) and `TintedToggleTile` (Switch.adaptive trailing). Both screens consume it; private `_ProfileMenuTile`, `_ProfileToggleTile`, and Settings' `_buildSettingTile` are deleted. Rationale: guarantees the spec's "identical anatomy everywhere" by construction rather than by copy-paste discipline.
3. **Accent colors centralized in `AppThemeData.statusColors()`-style helper**: add a static accent map on `AppThemeData` (e.g., `accentPink`, `accentOrange`, `accentSlate`, `accentBlue`, `accentPurple`, `accentYellow`, `accentTeal`, `accentSky`, `accentNavy`, `accentBlueGray`) with light/dark variants where needed, instead of scattering `Color(0x...)` literals through page code. Rationale: AGENTS.md forbids hardcoded hex in pages; a single token home keeps dark mode correct and future re-themes cheap.
4. **Gradient tokens**: define the profile hero gradient (#0D808A → #26C6DA) and settings banner gradient as constants alongside the accents in `app_theme.dart`. These are brand gradients intentionally identical across light/dark (white text sits on them), matching the existing pattern where gradients are declared inline but now owned by the theme file.
5. **Profile IA**: delete `_buildQuickActions`; sections become Account (My addresses, Payment methods — retained so booking-critical destinations stay reachable exactly once), Preferences (Favorites, My Reviews, Dark Mode toggle), System Access (Settings, Help & Support) + destructive Log out row. "My notifications" and "Language" rows are removed from Profile — they remain reachable on Settings. "Security" moves to Settings only. Rationale: matches the brief's section lists and the route-reachability requirement while removing duplicate paths flagged in the spec.
6. **Logout styling**: reuse the menu-row component with crimson title/icon (`theme.error` softened via a fixed crimson token); keep the existing confirmation dialog and sign-out logic verbatim. On Settings, replace the full-width OutlinedButton with the same destructive row for cross-screen consistency.
7. **Surfaces**: grouped containers use `theme.primaryBackground` cards on `theme.secondaryBackground` page background (current pattern), with `surfaceAlt` reserved for subtle fills; borders use `theme.border` + `shadowCard`. This satisfies "white page / ultra-light gray surface" in light mode while dark mode keeps working without extra branches.
8. **Hero footer metrics**: keep the three-way Expanded split with hairline dividers, reduce container opacity (~10–12% white) for the "low-opacity footer" look, and drive values from existing state (`FFAppState().hasSelectedLocation`, `_model.switchValue`).

## Risks / Trade-offs

- [Material glyphs are not literally Lucide/Phosphor] → All icon usage funnels through `TintedMenuTile`, so swapping to Phosphor later is a one-widget change; document in tasks that icon choice is isolated there.
- [Removing Profile rows could hide features users knew] → Every removed destination remains reachable (notifications/language/security via Settings); verify with a route checklist task.
- [New accent constants may drift from design review] → Keep names semantic (accentPink…) so a reviewer can retune values in one file without touching pages.
- [`flutter analyze` regressions from deleted private widgets] → Delete usages and definitions together in the same task; run analyze after each screen.
