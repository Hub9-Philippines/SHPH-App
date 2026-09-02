# Design System — Serbisyo (Flutter)

Source of truth for the Flutter app's visual design system. The single canonical
implementation lives in `lib/theme/app_theme.dart` plus the shared widgets in
`lib/components/`. **Reference/parity target is the Vue 3 + Ionic web app** at
`E:\Dev\shph-web` (CSS custom properties `--shph-*` in `src/theme/variables.css`).

## Golden rules

- **Always use theme tokens. Never hardcode hex / `Colors.*` / `const Color(0x…)`**
  for text, surfaces, or borders — dark mode depends on it. Theme-driven surfaces
  must come from `AppTheme.of(context)` (`AppThemeData.light()` / `.dark()`).
- **Font is `GoogleFonts.plusJakartaSans()`. `GoogleFonts.poppins` is banned.**
- **Access theme via `AppTheme.of(context)`** — returns the right `AppThemeData`
  for the current brightness. `ThemeData.of(context)` is only for Material
  component defaults (buttons, inputs, etc.) via `AppTheme.lightTheme()`/`darkTheme()`.
- **Reuse shared widgets in `lib/components/` instead of inlining new UI** so
  screens cannot drift apart (e.g. `ScreenHeader`, `StatusPill`, `SegmentedControl`,
  `ContentContainer`, `SoftCard`, `EmptyState`).

## Color tokens (`AppThemeData`)

### Light (`AppThemeData.light()`)

| Token | Value | Usage |
| --- | --- | --- |
| `primary` | `#1E3A8A` | Brand blue — primary CTAs, active tabs, links |
| `onPrimary` | `#FFFFFF` | Text/icons on `primary` |
| `secondary` | `#7C5CFC` | Secondary brand accent (violet) |
| `tertiary` | `#EE8B60` | Tertiary accent |
| `alternate` | `#E0E3E7` | Default input border (Material) |
| `primaryText` | `#0F172A` | Headings / body emphasis |
| `secondaryText` | `#64748B` | Body copy, muted |
| `textTertiary` | `#94A3B8` | Hints, timestamps, placeholders |
| `primaryBackground` | `#FFFFFF` | Cards, thumbnails, main surface |
| `secondaryBackground` | `#F7F7F7` | Scaffold behind cards (Bookings/Scaffold) |
| `bgPage` | `#F8FAFC` | Page canvas page (Explore) |
| `surfaceAlt` | `#F1F5F9` | Segmented track, chips, inset surfaces |
| `border` | `#E2E8F0` | Card/control borders |
| `success` / `warning` / `error` / `info` | violet / amber / `#DC2626` / blue | Semantic states (info = brand) |
| `iconBackground` | `#E0E7FF` | Tinted icon chips |
| `primaryLight` | `#E0E7FF` | Soft brand-tinted background |
| `primaryDark` | `#4338CA` | Brand dark accent |
| `primaryBrandText` | `#4F46E5` | Text on `primaryLight` |

### Dark (`AppThemeData.dark()`)

Pattern-mirrors light; key values: `primaryBackground #1D2428`,
`secondaryBackground #14181B`, `bgPage #0F172A`, `primaryText #FFFFFF`,
`secondaryText #95A1AC`, `border #3A3A4E`, `surfaceAlt #2A2A3C`,
`textTertiary #94A3B8`. Brand `primary`/`onPrimary`/`secondary`/`tertiary`
stays the same across both modes.

## Status colors (`AppThemeData.statusColors(status)`)

Returns `(Color text, Color bg)` — always use the helper, never the raw values:

| Status | Text | Bg |
| --- | --- | --- |
| `confirmed` | `#4338CA` | `#E0E7FF` |
| `en_route` / `arrived` / `in_progress` / `on_site` | `#166534` | `#E7F6EC` |
| `completed` | `#475569` | `#EEF1F5` |
| `cancelled` / `disputed` | `#B91C1C` | `#FDE9E9` |
| `pending` / `inquiry` / `searching` | `#92400E` | `#FDF0DD` |
| default | `#475569` | `#EEF1F5` |

## Action / lifecycle colors

- `actionPrimary` = `accentNavy` (`#1E3A8A`) — active filter pills/chips.
- `successBrand` = `#7C5CFC` (violet) — success/complete states, empty-state icons.
- `destructiveSoft` = `#EF4444` — destructive affordances (distinct from `error`,
  which stays reserved for form/validation errors).

## Layout tokens (`AppThemeData`)

| Token | Value |
| --- | --- |
| `radiusSm` / `radiusMd` / `radiusLg` / `radiusCard` / `radiusPill` | `10` / `14` / `16` / `24` / `9999` |
| `spaceXs` / `spaceSm` / `spaceMd` / `spaceLg` / `spaceXl` | `4` / `8` / `12` / `16` / `24` |
| `containerNarrow` / `readable` / `wide` / `dashboard` | `560` / `760` / `1100` / `1200` |
| `shadowSoft` / `shadowMd` / `shadowCard` / `shadowLg` | subtle → strong elevation |

**Tab-screen grid (Explore / Bookings / Messages):** 16px horizontal margins &
card insets, 24px between standalone page blocks, 12px carousel gutters. Use the
`space*` tokens instead of raw literals.

## Shared components (`lib/components/`)

Prefer these over bespoke UI:

- `ScreenHeader` — title + optional subtitle + action square (white, `shadowCard`).
- `SegmentedControl<T>` — theme-driven pill tab picker (track `surfaceAlt` +
  `border`, white active thumb + `shadowSoft`, `primary` active / `secondaryText`
  inactive). Replaces ad-hoc `CupertinoSliding*` widgets. Use `SegmentedOption<T>`.
- `StatusPill` — status label chip using `statusColors()`.
- `ContentContainer` — width-constrained wrapper (`ContentVariant`).
- `SoftCard`, `EmptyState`, `ErrorState`, `SkeletonLoading`, `SectionHeader`,
  `CategoryPill`, `ServiceCard`, `BookingCard`.

## Typography

All weight/size variants live on `AppThemeData` getters (`displayLarge` →
`labelSmall`). Text is Plus Jakarta Sans throughout. Override via
`TextStyle.override(font: GoogleFonts.plusJakartaSans(...))`.

## Status bar / safe area

- The **global** `MaterialApp.router` builder must **not** wrap content in
  `SafeArea` — screens stretch behind the status bar; page themes paint naturally.
- Status bar styling is injected globally via `AnnotatedRegion<SystemUiOverlayStyle>`
  in `lib/main.dart` (transparent status bar, dark icons on light theme).
- `ConnectivityBanner` owns its own `SafeArea(bottom: false)` so the offline
  banner stays visible under the camera notch.

## Adding tokens / components

1. Add the token to **both** `AppThemeData.light()` and `.dark()` in
   `lib/theme/app_theme.dart` (add a field + constructor param).
2. For reusable UI, create it in `lib/components/` using tokens only, then use it
   across pages — do not copy-paste inline styles.
3. Run `dart analyze lib/theme/app_theme.dart lib/components/` — **0 errors**.
4. Keep `docs/ui-ux-reconstruction-plan.md` in sync when landing theme/component work.
